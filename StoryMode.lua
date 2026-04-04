local addonName, SM = ...

-- ============================================================================
-- Saved Variables
-- ============================================================================

local defaults = {
    version = "0.1.0",
    selectedQuestline = 1,
}

-- ============================================================================
-- Achievement Resolver — find achievement ID by name at runtime
-- ============================================================================

local function ResolveAchievementID(data)
    if data.achievementID then
        local _, name = GetAchievementInfo(data.achievementID)
        if name then return end  -- ID is valid
    end
    -- Search by name across achievement ID ranges
    if data.achievementName then
        for id = 1, 50000 do
            local _, name = GetAchievementInfo(id)
            if name == data.achievementName then
                data.achievementID = id
                return
            end
        end
    end
end

-- ============================================================================
-- Quest Utility Functions
-- ============================================================================

local function IsQuestComplete(questID)
    return C_QuestLog.IsQuestFlaggedCompleted(questID)
end

-- A quest is "effectively complete" if flagged complete OR if any later
-- quest in the same chapter is complete (handles skipped breadcrumbs).
-- However, if the quest is currently in the player's quest log it is
-- NOT complete — they are actively working on it.
-- Optional: pass nextChapterQuests to handle edge cases where the last
-- quest in a chapter is repeatable/unflagged but later chapters have progress.
local function IsQuestEffectivelyComplete(questIndex, chapterQuests, nextChapterQuests)
    local qid = chapterQuests[questIndex].id
    if C_QuestLog.IsOnQuest(qid) then return false end
    if IsQuestComplete(qid) then return true end
    for i = questIndex + 1, #chapterQuests do
        if IsQuestComplete(chapterQuests[i].id) then return true end
    end
    -- If this is the last quest in the chapter and all prior quests are done,
    -- check if ANY quest in the next chapter has progress — implies this one was done.
    if nextChapterQuests and questIndex == #chapterQuests then
        local allPriorDone = true
        for i = 1, questIndex - 1 do
            if not IsQuestComplete(chapterQuests[i].id) and not C_QuestLog.IsOnQuest(chapterQuests[i].id) then
                -- Check if a later quest covers it
                local covered = false
                for j = i + 1, #chapterQuests do
                    if IsQuestComplete(chapterQuests[j].id) then covered = true; break end
                end
                if not covered then allPriorDone = false; break end
            end
        end
        if allPriorDone then
            for _, nq in ipairs(nextChapterQuests) do
                if IsQuestComplete(nq.id) or C_QuestLog.IsOnQuest(nq.id) then return true end
            end
        end
    end
    return false
end

local function IsQuestInLog(questID)
    return C_QuestLog.GetLogIndexForQuestID(questID) ~= nil
end

local function GetAllChapters(data)
    local all = {}
    if data.prereqs then
        for _, ch in ipairs(data.prereqs) do
            ch._section = 1  -- prereqs (lowest priority)
            all[#all + 1] = ch
        end
    end
    if data.chapters then
        for _, ch in ipairs(data.chapters) do
            ch._section = 2  -- main story
            all[#all + 1] = ch
        end
    end
    if data.insurrection then
        for _, ch in ipairs(data.insurrection) do
            ch._section = 3  -- finale (highest priority)
            all[#all + 1] = ch
        end
    end
    return all
end

local function IsQuestlineActive(data)
    for _, ch in ipairs(GetAllChapters(data)) do
        for _, q in ipairs(ch.quests) do
            if IsQuestInLog(q.id) then return true end
        end
    end
    return false
end

local function GetCampaignProgress(data)
    local total, done = 0, 0
    for _, ch in ipairs(GetAllChapters(data)) do
        for _, q in ipairs(ch.quests) do
            total = total + 1
            if IsQuestComplete(q.id) then done = done + 1 end
        end
    end
    return done, total
end

-- Check if an achievement criterion is complete for THIS character (not warbound)
-- Drills into sub-achievements and checks actual quest flags
local function IsCriterionDoneForCharacter(achID, criteriaIdx)
    local _, criteriaType, _, _, _, _, _, assetID = GetAchievementCriteriaInfo(achID, criteriaIdx)

    if criteriaType == 8 then  -- sub-achievement: check its quest criteria
        local subNum = GetAchievementNumCriteria(assetID)
        if subNum == 0 then
            local _, _, _, completed = GetAchievementInfo(assetID)
            return completed
        end
        for j = 1, subNum do
            local _, subType, _, _, _, _, _, subAsset = GetAchievementCriteriaInfo(assetID, j)
            if subType == 27 then  -- quest
                if not IsQuestComplete(subAsset) then return false end
            end
        end
        return true
    elseif criteriaType == 27 then  -- direct quest
        return IsQuestComplete(assetID)
    else
        local _, _, completed = GetAchievementCriteriaInfo(achID, criteriaIdx)
        return completed
    end
end

local function GetChapterProgress(ch, nextChapter)
    local total, done = 0, 0
    local nextQuests = nextChapter and nextChapter.quests or nil
    for i, q in ipairs(ch.quests) do
        total = total + 1
        if IsQuestEffectivelyComplete(i, ch.quests, nextQuests) then done = done + 1 end
    end
    return done, total
end

local function FindNextQuest(data)
    local chapters = GetAllChapters(data)

    -- Check if player has completed any prereq chapters (meaning they've progressed)
    -- If there are no prereqs at all, the gate is open — treat as already satisfied
    local hasPrereqProgress = not data.prereqs
    if data.prereqs then
        for _, ch in ipairs(data.prereqs) do
            local d, t = GetChapterProgress(ch)
            if d > 0 then hasPrereqProgress = true; break end
        end
    end

    local logCandidates = {}    -- quests in the quest log
    local readyCandidates = {}  -- quests ready to pick up

    for chIdx, ch in ipairs(chapters) do
        local chDone, chTotal = GetChapterProgress(ch, chapters[chIdx + 1])
        if chDone >= chTotal then
            -- Chapter complete, skip
        else
            local section = ch._section or 1

            for j, q in ipairs(ch.quests) do
                if IsQuestInLog(q.id) then
                    logCandidates[#logCandidates + 1] = {
                        quest = q, chapter = ch.chapter,
                        section = section, depth = j, order = chIdx,
                    }
                    break
                elseif not IsQuestEffectivelyComplete(j, ch.quests) then
                    -- Quest not done and no later quest is done either
                    if j == 1 then
                        -- First quest in chapter: candidate if it's a main story
                        -- chapter and the player has made prereq progress
                        if section >= 2 and hasPrereqProgress then
                            readyCandidates[#readyCandidates + 1] = {
                                quest = q, chapter = ch.chapter,
                                section = section, depth = j, order = chIdx,
                            }
                        elseif section == 1 and chDone == 0 and not hasPrereqProgress then
                            -- Very start of the questline
                            readyCandidates[#readyCandidates + 1] = {
                                quest = q, chapter = ch.chapter,
                                section = section, depth = j, order = chIdx,
                            }
                        end
                        break
                    elseif IsQuestEffectivelyComplete(j - 1, ch.quests) then
                        -- Predecessor done, not stuck → ready to pick up
                        readyCandidates[#readyCandidates + 1] = {
                            quest = q, chapter = ch.chapter,
                            section = section, depth = j, order = chIdx,
                        }
                        break
                    else
                        break  -- predecessor not done, can't start here
                    end
                end
            end
        end
    end

    -- Track which sections have any quest progress at all
    local sectionHasProgress = {}
    for _, ch in ipairs(chapters) do
        local s = ch._section or 1
        if not sectionHasProgress[s] then
            local d = GetChapterProgress(ch)
            if d > 0 then sectionHasProgress[s] = true end
        end
    end

    -- Track the last completed chapter order per section.
    -- Used to prefer the chapter right after the player's furthest completion.
    local lastCompleteOrder = {}
    for chIdx, ch in ipairs(chapters) do
        local d, t = GetChapterProgress(ch)
        local s = ch._section or 1
        if d >= t and t > 0 then
            if not lastCompleteOrder[s] or chIdx > lastCompleteOrder[s] then
                lastCompleteOrder[s] = chIdx
            end
        end
    end

    -- Log candidates: prefer higher section, then deeper quest, then earlier chapter
    local function sortLogCandidates(a, b)
        if a.section ~= b.section then return a.section > b.section end
        if a.depth ~= b.depth then return a.depth > b.depth end
        return a.order < b.order
    end

    -- Ready candidates sorting:
    -- 1. Sections with progress beat sections without
    -- 2. Within that, prefer quests mid-chapter (depth > 1) over chapter starts
    -- 3. For chapter starts (depth == 1), prefer the one right after the last
    --    completed chapter (the natural next step) over random unstarted ones
    -- 4. Tiebreaker: earlier chapter order
    local function sortReadyCandidates(a, b)
        local aP = sectionHasProgress[a.section] and true or false
        local bP = sectionHasProgress[b.section] and true or false
        if aP ~= bP then return aP end
        if aP then
            if a.section ~= b.section then return a.section > b.section end
        else
            if a.section ~= b.section then return a.section < b.section end
        end

        -- Prefer mid-chapter quests (predecessor confirmed complete)
        if a.depth ~= b.depth then return a.depth > b.depth end

        -- Both at depth 1 (unstarted chapters): prefer the one closest
        -- after the last completed chapter in this section
        local aLast = lastCompleteOrder[a.section] or 0
        local bLast = lastCompleteOrder[b.section] or 0
        local aAfter = a.order > aLast
        local bAfter = b.order > bLast
        if aAfter ~= bAfter then return aAfter end

        -- Both after (or both before) last complete: pick closest
        return a.order < b.order
    end

    -- Priority 1: quest in log
    if #logCandidates > 0 then
        table.sort(logCandidates, sortLogCandidates)
        return logCandidates[1].quest, logCandidates[1].chapter
    end

    -- Priority 2: ready quest
    if #readyCandidates > 0 then
        table.sort(readyCandidates, sortReadyCandidates)
        return readyCandidates[1].quest, readyCandidates[1].chapter
    end

    return nil, nil
end

-- ============================================================================
-- Waypoint / Tracking
-- ============================================================================

-- Ensure trivial (low-level) quest markers are visible on the minimap & map
local function EnsureTrivialQuestsVisible()
    for i = 1, C_Minimap.GetNumTrackingTypes() do
        local info = C_Minimap.GetTrackingInfo(i)
        if info and not info.active then
            -- Match by the global string constant or by known English name
            local isTrivial = (MINIMAP_TRACKING_TRIVIAL_QUESTS and info.name == MINIMAP_TRACKING_TRIVIAL_QUESTS)
                or info.name == "Trivial Quests"
                or info.name == "Low Level Quests"
            if isTrivial then
                C_Minimap.SetTracking(i, true)
                print("|cff64b5f6StoryMode:|r Enabled |cffffd200" .. info.name .. "|r tracking so you can see quest markers for this storyline.")
                return
            end
        end
    end
end

-- ── Map ping animation (expanding gold ring at waypoint) ──────────────────
local pingFrame
local function GetPingFrame()
    if pingFrame then return pingFrame end

    local f = CreateFrame("Frame")
    f:SetSize(32, 32)
    f:SetFrameStrata("TOOLTIP")
    f:Hide()

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
    tex:SetVertexColor(1, 0.78, 0.1)
    f.tex = tex

    local ag = f:CreateAnimationGroup()
    ag:SetLooping("NONE")

    local s = ag:CreateAnimation("Scale")
    s:SetScaleFrom(0.6, 0.6)
    s:SetScaleTo(3.0, 3.0)
    s:SetDuration(0.75)
    s:SetSmoothing("OUT")

    local a = ag:CreateAnimation("Alpha")
    a:SetFromAlpha(0.9)
    a:SetToAlpha(0)
    a:SetDuration(0.75)
    a:SetSmoothing("OUT")

    ag:SetScript("OnFinished", function() f:Hide() end)
    f.anim = ag

    pingFrame = f
    return f
end

local function PingOnWorldMap(mapID, x, y)
    if not WorldMapFrame then return end
    OpenWorldMap(mapID)
    PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_SUPER_TRACK_ON or 167425)

    C_Timer.After(0.15, function()
        if not WorldMapFrame:IsShown() then return end
        local canvas = WorldMapFrame.ScrollContainer.Child
        if not canvas then return end

        local f = GetPingFrame()
        f:SetParent(canvas)
        f:ClearAllPoints()
        f:SetPoint("CENTER", canvas, "TOPLEFT",
            canvas:GetWidth() * x, -canvas:GetHeight() * y)
        f:SetAlpha(1)
        f:SetScale(1)
        f:Show()
        f.anim:Stop()
        f.anim:Play()
    end)
end

local function SetWaypointForQuest(data, quest)
    if not quest then return "no_location", nil, nil end

    -- Make sure low-level quest markers are visible (critical for legacy content)
    EnsureTrivialQuestsVisible()

    -- Quest already in log → super-track it directly
    if IsQuestInLog(quest.id) then
        C_QuestLog.AddQuestWatch(quest.id)
        C_SuperTrack.SetSuperTrackedQuestID(quest.id)
        -- Open map to the quest's zone if we know it
        local loc = data.npcLocations and data.npcLocations[quest.npc]
        if loc then
            PingOnWorldMap(loc.mapID, loc.x, loc.y)
        end
        return "supertracked", loc and loc.mapID, loc
    end

    -- Quest not in log → place a user waypoint on the quest giver's location
    local loc = data.npcLocations and data.npcLocations[quest.npc]
    if loc and C_Map.CanSetUserWaypointOnMap(loc.mapID) then
        local point = UiMapPoint.CreateFromCoordinates(loc.mapID, loc.x, loc.y)
        C_Map.SetUserWaypoint(point)
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        PingOnWorldMap(loc.mapID, loc.x, loc.y)
        return "waypoint", loc.mapID, loc
    end

    -- Fallback: try quest offer map pin + still open the map if we know the location
    if Enum.SuperTrackingMapPinType and Enum.SuperTrackingMapPinType.QuestOffer then
        C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.QuestOffer, quest.id)
    end
    if loc then
        PingOnWorldMap(loc.mapID, loc.x, loc.y)
        return "waypoint_approx", loc.mapID, loc
    end

    -- Last resort: open the questline's start map so the player has SOME orientation
    if data.startMapID then
        OpenWorldMap(data.startMapID)
    end
    return "no_location", nil, nil
end

local function GetZoneName(mapID)
    local info = mapID and C_Map.GetMapInfo(mapID)
    return info and info.name or nil
end

local function PrintTrackResult(result, quest, data)
    local P = "|cff64b5f6StoryMode:|r "
    local loc = data.npcLocations and data.npcLocations[quest.npc]
    local zone = loc and GetZoneName(loc.mapID) or nil

    if result == "supertracked" then
        -- Quest is in the log, player already has it
        if zone then
            print(P .. "Tracking: |cffffd200" .. quest.name .. "|r — check your map.")
        else
            print(P .. "Tracking: |cffffd200" .. quest.name .. "|r")
        end
    elseif result == "waypoint" or result == "waypoint_approx" then
        -- Quest not picked up yet — tell them exactly where to go
        if zone then
            print(P .. "Find |cffffd200" .. quest.npc .. "|r in |cff64b5f6" .. zone .. "|r to accept: " .. quest.name)
        else
            print(P .. "Find |cffffd200" .. quest.npc .. "|r to accept: " .. quest.name)
        end
    else
        if zone then
            print(P .. "Next: |cffffd200" .. quest.name .. "|r from " .. quest.npc .. " in |cff64b5f6" .. zone .. "|r")
        else
            print(P .. "Next: |cffffd200" .. quest.name .. "|r from |cffffd200" .. quest.npc .. "|r")
        end
    end
end

-- ============================================================================
-- UI Constants & Helpers
-- ============================================================================

local LEFT_WIDTH = 220
local PAD = 14
local ROW_HEIGHT = 42

local function HexColor(r, g, b)
    return string.format("%02x%02x%02x",
        math.min(255, math.floor(r * 255)),
        math.min(255, math.floor(g * 255)),
        math.min(255, math.floor(b * 255)))
end

-- Creates a horizontal line that fades from transparent at edges to visible
-- at center. Returns the two texture halves + a Show/Hide controller.
local function CreateFadingLine(parent, r, g, b, peakAlpha, height, layer, sublayer)
    height = height or 1
    layer = layer or "ARTWORK"
    sublayer = sublayer or 0
    peakAlpha = peakAlpha or 0.4

    local left = parent:CreateTexture(nil, layer, nil, sublayer)
    left:SetTexture(SOLID)
    left:SetHeight(height)
    left:SetGradient("HORIZONTAL", CreateColor(r, g, b, 0), CreateColor(r, g, b, peakAlpha))

    local right = parent:CreateTexture(nil, layer, nil, sublayer)
    right:SetTexture(SOLID)
    right:SetHeight(height)
    right:SetGradient("HORIZONTAL", CreateColor(r, g, b, peakAlpha), CreateColor(r, g, b, 0))

    return left, right
end

-- ============================================================================
-- Category & Questline Registry
-- ============================================================================

local categories = {
    { name = "Epic Storylines", questlines = {} },
    { name = "Class Identity", questlines = {} },
    { name = "More Coming Soon", disabled = true, questlines = {} },
}

local allQuestlines = {}

local function RegisterQuestline(data, categoryName)
    allQuestlines[#allQuestlines + 1] = data
    for _, cat in ipairs(categories) do
        if cat.name == categoryName then
            cat.questlines[#cat.questlines + 1] = data
            break
        end
    end
end

-- ============================================================================
-- Register Questlines
-- ============================================================================

RegisterQuestline(SM.SuramarData, "Epic Storylines")
RegisterQuestline(SM.LilianVossData, "Epic Storylines")
RegisterQuestline(SM.RogueCampaignData, "Class Identity")


-- ============================================================================
-- Story Mode Window  —  Trading-Post-style clean dark panels
-- ============================================================================

local FRAME_W  = 1012
local FRAME_H  = 550
local LEFT_W   = 274
local GAP      = 6
local RIGHT_W  = 732   -- FRAME_W - LEFT_W - GAP
local HEADER_H = 68
local SOLID    = "Interface\\Buttons\\WHITE8x8"

-- Color palette
local C_BG   = {0, 0, 0}               -- pure black panel background (Trading Post style)
local C_BODY = {0.922, 0.871, 0.761}
local C_GOLD = {1,     0.82,  0}
local C_DIM  = {0.50,  0.50,  0.50}
local C_BOR  = {0.35,  0.24,  0.12}

local function NoShadow(fs) fs:SetShadowOffset(0,0); return fs end

-- ─── Panel frame (Trading Post NineSlice — actual Blizzard atlas textures) ───
local PERKS_LAYOUT = {
    TopLeftCorner     = { atlas = "Perks-List-NineSlice-CornerTopLeft", x = -31, y = 31 },
    TopRightCorner    = { atlas = "Perks-List-NineSlice-CornerTopLeft", mirrorLayout = true, x = 31, y = 31 },
    BottomLeftCorner  = { atlas = "Perks-List-NineSlice-CornerTopLeft", mirrorLayout = true, x = -31, y = -31 },
    BottomRightCorner = { atlas = "Perks-List-NineSlice-CornerTopLeft", mirrorLayout = true, x = 31, y = -31 },
    TopEdge           = { atlas = "_Perks-List-NineSlice-EdgeTop" },
    BottomEdge        = { atlas = "_Perks-List-NineSlice-EdgeTop", mirrorLayout = true },
    LeftEdge          = { atlas = "!Perks-List-NineSlice-EdgeLeft" },
    RightEdge         = { atlas = "!Perks-List-NineSlice-EdgeLeft", mirrorLayout = true },
    Center            = { atlas = "Perks-List-NineSlice-Center" },
}

local function CreateStoryPanel(section)
    local f = CreateFrame("Frame", nil, section, "NineSlicePanelTemplate")
    f:SetAllPoints(section)
    f:SetFrameLevel(section:GetFrameLevel())
    NineSliceUtil.ApplyLayout(f, PERKS_LAYOUT)
    -- Tint border pieces gold-bronze
    local br, bg, bb = 1.0, 0.80, 0.45
    for _, key in ipairs({"TopLeftCorner","TopRightCorner","BottomLeftCorner","BottomRightCorner",
                          "TopEdge","BottomEdge","LeftEdge","RightEdge"}) do
        if f[key] then f[key]:SetVertexColor(br, bg, bb) end
    end
    return f
end

-- Blizzard scrollbar: ScrollFrameTemplate already provides one; just add
-- mouse-wheel support (the default template doesn't always wire it up).
local SCROLL_STEP = 40

local function EnableMouseWheelScroll(scrollFrame)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local range = self:GetVerticalScrollRange() or 0
        if range <= 0 then return end
        local cur = self:GetVerticalScroll() or 0
        local new = math.max(0, math.min(range, cur - delta * SCROLL_STEP))
        self:SetVerticalScroll(new)
    end)
end

-- ─── Major divider (Journeys renown divider atlas) ─────────────────────────
local function CreateMajorDivider(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(16)
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAtlas("ui-journeys-renown-divider", false)
    tex:SetPoint("LEFT",  f, "LEFT",  0, 0)
    tex:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    tex:SetHeight(16)
    return f
end

-- ─── Section label + gradient line (category / chapter headers) ───────────────
local function MakeSectionLabel(parent, text)
    local lbl = NoShadow(parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
    lbl:SetJustifyH("LEFT")
    lbl:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])
    if text then lbl:SetText(text) end
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetTexture(SOLID); line:SetHeight(1)
    line:SetPoint("LEFT",  lbl,    "RIGHT",  6,  0)
    line:SetPoint("RIGHT", parent, "RIGHT", -20, 0)
    line:SetPoint("TOP",   lbl,    "CENTER", 0,  0)
    line:SetGradient("HORIZONTAL",
        CreateColor(1.0, 0.80, 0.45, 0.6),
        CreateColor(1.0, 0.80, 0.45, 0))
    return lbl, line
end

-- ════════════════════════════════════════════════════════════════════════════
-- Outer container  (invisible, handles dragging + ESC close)
-- ════════════════════════════════════════════════════════════════════════════

local storyFrame = CreateFrame("Frame", "StoryModeFrame", UIParent)
storyFrame:SetSize(FRAME_W, FRAME_H)
storyFrame:SetPoint("CENTER")
storyFrame:SetMovable(true); storyFrame:EnableMouse(true)
storyFrame:RegisterForDrag("LeftButton")
storyFrame:SetScript("OnDragStart", storyFrame.StartMoving)
storyFrame:SetScript("OnDragStop",  storyFrame.StopMovingOrSizing)
storyFrame:SetFrameStrata("HIGH")
storyFrame:Hide()
tinsert(UISpecialFrames, "StoryModeFrame")

-- ════════════════════════════════════════════════════════════════════════════
-- Left section  (274 × 550, card list)
-- ════════════════════════════════════════════════════════════════════════════

local leftSection = CreateFrame("Frame", nil, storyFrame)
leftSection:SetSize(LEFT_W, FRAME_H)
leftSection:SetPoint("TOPLEFT", storyFrame, "TOPLEFT", 0, 0)
local leftPanel = CreateStoryPanel(leftSection)

-- Scrollable card list (no scrollbar — mousewheel only)
local leftScroll = CreateFrame("ScrollFrame", nil, leftSection, "ScrollFrameTemplate")
leftScroll:SetPoint("TOPLEFT",     leftSection, "TOPLEFT",     12, -14)
leftScroll:SetPoint("BOTTOMRIGHT", leftSection, "BOTTOMRIGHT", -12,  12)
if leftScroll.ScrollBar then leftScroll.ScrollBar:Hide() end
local leftChild = CreateFrame("Frame", nil, leftScroll)
leftChild:SetWidth(LEFT_W - 24)
leftScroll:SetScrollChild(leftChild)
EnableMouseWheelScroll(leftScroll)

-- ════════════════════════════════════════════════════════════════════════════
-- Right section  (732 × 550, header + detail)
-- ════════════════════════════════════════════════════════════════════════════

local rightSection = CreateFrame("Frame", nil, storyFrame)
rightSection:SetSize(RIGHT_W, FRAME_H)
rightSection:SetPoint("TOPLEFT", leftSection, "TOPRIGHT", GAP, 0)
local rightPanel = CreateStoryPanel(rightSection)

-- ── Close button (standard Blizzard X) ──────────────────────────────────────
local closeBtn = CreateFrame("Button", nil, rightSection, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", rightSection, "TOPRIGHT", -4, -4)
closeBtn:SetScript("OnClick", function() storyFrame:Hide() end)

-- ── Right header  (68px, title + selected story name) ────────────────────────
local rightHeader = CreateFrame("Frame", nil, rightSection)
rightHeader:SetPoint("TOPLEFT",  rightSection, "TOPLEFT",  0, 0)
rightHeader:SetPoint("TOPRIGHT", rightSection, "TOPRIGHT", 0, 0)
rightHeader:SetHeight(HEADER_H)

-- Tab labels
local tabStoryLabel = NoShadow(rightHeader:CreateFontString(nil, "OVERLAY", "QuestFont_Large"))
tabStoryLabel:SetPoint("LEFT", rightHeader, "LEFT", 56, 0)
tabStoryLabel:SetPoint("BOTTOM", rightHeader, "BOTTOM", 0, 18)
tabStoryLabel:SetText("Story")
tabStoryLabel:SetTextColor(1, 1, 1)

local tabProgressLabel = NoShadow(rightHeader:CreateFontString(nil, "OVERLAY", "QuestFont_Large"))
tabProgressLabel:SetPoint("LEFT", tabStoryLabel, "RIGHT", 24, 0)
tabProgressLabel:SetPoint("BOTTOM", rightHeader, "BOTTOM", 0, 18)
tabProgressLabel:SetText("Progress")
tabProgressLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])

-- Clickable hit areas over tab labels
local tabStoryHit = CreateFrame("Button", nil, rightHeader)
tabStoryHit:SetPoint("TOPLEFT", tabStoryLabel, "TOPLEFT", -4, 4)
tabStoryHit:SetPoint("BOTTOMRIGHT", tabStoryLabel, "BOTTOMRIGHT", 4, -4)

local tabProgressHit = CreateFrame("Button", nil, rightHeader)
tabProgressHit:SetPoint("TOPLEFT", tabProgressLabel, "TOPLEFT", -4, 4)
tabProgressHit:SetPoint("BOTTOMRIGHT", tabProgressLabel, "BOTTOMRIGHT", 4, -4)

local activeTab = "story"

-- Kept for backward compat in UpdateStoryDetail
local smHeaderSub = NoShadow(rightHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
smHeaderSub:SetPoint("RIGHT", rightHeader, "RIGHT", -56, 0)
smHeaderSub:SetPoint("BOTTOM", rightHeader, "BOTTOM", 0, 18)
smHeaderSub:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])
smHeaderSub:SetJustifyH("RIGHT")

-- Divider at bottom of header
local headerDiv = CreateMajorDivider(rightSection)
headerDiv:SetPoint("LEFT",  rightHeader, "BOTTOMLEFT",  28, 0)
headerDiv:SetPoint("RIGHT", rightHeader, "BOTTOMRIGHT", -36, 0)

-- ── Tab container  (fills right section below header) ────────────────────────
local tabContainer = CreateFrame("Frame", nil, rightSection)
tabContainer:SetPoint("TOPLEFT",     rightHeader,  "BOTTOMLEFT",  0,  0)
tabContainer:SetPoint("BOTTOMRIGHT", rightSection, "BOTTOMRIGHT", 0,  0)

-- ════════════════════════════════════════════════════════════════════════════
-- Detail pane  (scrollable, lives inside tabContainer)
-- ════════════════════════════════════════════════════════════════════════════

local detailScroll = CreateFrame("ScrollFrame", nil, tabContainer, "ScrollFrameTemplate")
detailScroll:SetPoint("TOPLEFT",     tabContainer, "TOPLEFT",     0,   0)
detailScroll:SetPoint("BOTTOMRIGHT", tabContainer, "BOTTOMRIGHT", -8,  8)
local detailChild = CreateFrame("Frame", nil, detailScroll)
detailChild:SetWidth(RIGHT_W)
detailScroll:SetScrollChild(detailChild)
EnableMouseWheelScroll(detailScroll)

-- Move scrollbar inside the panel, 8px from right edge
if detailScroll.ScrollBar then
    detailScroll.ScrollBar:ClearAllPoints()
    detailScroll.ScrollBar:SetPoint("TOPRIGHT",    detailScroll, "TOPRIGHT",    -5, -16)
    detailScroll.ScrollBar:SetPoint("BOTTOMRIGHT", detailScroll, "BOTTOMRIGHT", -5,  16)
end

local DP  = 32   -- divider padding (left/right)
local CP  = 80   -- content padding (left/right) — narrower than dividers

-- ── Intro (visible when no story is selected) ──────────────────────────────
local introIcon2 = detailChild:CreateTexture(nil, "ARTWORK")
introIcon2:SetSize(96, 96)
introIcon2:SetPoint("TOP", detailChild, "TOP", 0, -30)
introIcon2:SetAtlas("majorfactions_icons_flame512", false)

local introTitle = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
introTitle:SetPoint("TOP", introIcon2, "BOTTOM", 0, -12)
introTitle:SetJustifyH("CENTER")
introTitle:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
introTitle:SetText("Story Mode")

local introText = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
introText:SetPoint("TOPLEFT",  detailChild, "TOPLEFT",  CP, -180)
introText:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", -CP, -180)
introText:SetJustifyH("LEFT"); introText:SetSpacing(5)
introText:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
introText:SetText(
    "Story Mode is a quest companion that walks you through "
    .."Azeroth's campaigns from start to finish. "
    .."Think of it as a narrative guide: "
    .."the structure and direction of RestedXP, "
    .."with the story-first mindset of Dialogue UI."
    .."\n\nEach questline is broken down into chapters. "
    .."You get the key characters, the context, "
    .."and a clear path forward. "
    .."No wiki tabs. No spoilers. No guesswork."
    .."\n\nSelect a story on the left to begin.")

-- ══════════════════════════════════════════════════════════════════════════════
-- Detail view — centered portrait hero + clean sections
-- ══════════════════════════════════════════════════════════════════════════════

local HERO_ICON = 96

-- ── Hero: centered circular portrait + title below (shared across tabs) ─────
local heroFrame = CreateFrame("Frame", nil, detailChild)
heroFrame:SetPoint("TOPLEFT",  detailChild, "TOPLEFT",  0, 0)
heroFrame:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", 0, 0)
heroFrame:SetHeight(HERO_ICON + 60)  -- icon + gap + title

local heroPort = CreateFrame("Frame", nil, heroFrame)
heroPort:SetSize(HERO_ICON, HERO_ICON)
heroPort:SetPoint("TOP", heroFrame, "TOP", 0, -30)

local heroIcon = heroPort:CreateTexture(nil, "ARTWORK")
heroIcon:SetSize(HERO_ICON - 8, HERO_ICON - 8)
heroIcon:SetPoint("CENTER")
heroIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
heroIcon:SetTexelSnappingBias(0)
heroIcon:SetSnapToPixelGrid(false)

local heroMask = heroPort:CreateMaskTexture()
heroMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask",
    "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
heroMask:SetAllPoints(heroIcon)
heroIcon:AddMaskTexture(heroMask)

local heroRing = heroPort:CreateTexture(nil, "OVERLAY")
heroRing:SetAtlas("ui-frame-genericplayerchoice-portrait-border", false)
heroRing:SetPoint("TOPLEFT",     heroIcon, "TOPLEFT",     -3,  3)
heroRing:SetPoint("BOTTOMRIGHT", heroIcon, "BOTTOMRIGHT",  3, -3)
heroRing:SetVertexColor(1.0, 0.82, 0.5)
heroRing:SetAlpha(0.85)

local dTitle = NoShadow(heroFrame:CreateFontString(nil, "OVERLAY", "QuestFont_Huge"))
dTitle:SetPoint("TOP", heroPort, "BOTTOM", 0, -12)
dTitle:SetJustifyH("CENTER"); dTitle:SetWordWrap(false)
dTitle:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])

-- ════════════════════════════════════════════════════════════════════════════
-- STORY TAB elements
-- ════════════════════════════════════════════════════════════════════════════

-- Story intro paragraph
local sIntro = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
sIntro:SetJustifyH("LEFT"); sIntro:SetSpacing(4); sIntro:SetWordWrap(true)
sIntro:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])

-- Key Characters header + entries (centered, title style)
local sCharHeader = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
sCharHeader:SetJustifyH("CENTER")
sCharHeader:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
sCharHeader:SetText("Key Characters")

local sCharText = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
sCharText:SetJustifyH("LEFT"); sCharText:SetSpacing(4); sCharText:SetWordWrap(true)
sCharText:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])

-- CTA button on story tab (big red Trading Post style)
local sTrackBtnTemplate = C_XMLUtil and C_XMLUtil.GetTemplateInfo
    and C_XMLUtil.GetTemplateInfo("SharedButtonLargeTemplate")
    and "SharedButtonLargeTemplate" or "UIPanelButtonTemplate"
local sTrackBtn = CreateFrame("Button", nil, detailChild, sTrackBtnTemplate)
sTrackBtn:SetSize(240, 40)
sTrackBtn:SetText("Begin This Story")
sTrackBtn:RegisterForClicks("AnyUp")

local sCompleteText = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
sCompleteText:SetTextColor(0.40, 0.82, 0.35)
sCompleteText:SetText("|A:common-icon-checkmark:0:0|a Campaign Complete")

-- Progressive story journal entries (chapter recaps, revealed as quests are completed)
local sJournalHeader = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
sJournalHeader:SetJustifyH("CENTER")
sJournalHeader:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
sJournalHeader:SetText("Your Story So Far")

local sJournalEntries = {}  -- pool of { title = FontString, body = FontString }

local function GetJournalEntry(idx)
    if sJournalEntries[idx] then return sJournalEntries[idx] end
    local title = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Large"))
    title:SetJustifyH("CENTER")
    title:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
    local body = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
    body:SetJustifyH("LEFT"); body:SetSpacing(4); body:SetWordWrap(true)
    body:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
    sJournalEntries[idx] = { title = title, body = body }
    return sJournalEntries[idx]
end

local storyElements = { sIntro, sCharHeader, sCharText, sTrackBtn, sCompleteText, sJournalHeader }

-- ════════════════════════════════════════════════════════════════════════════
-- PROGRESS TAB elements
-- ════════════════════════════════════════════════════════════════════════════

local dCompleteText = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
dCompleteText:SetTextColor(0.40, 0.82, 0.35)
dCompleteText:SetText("|A:common-icon-checkmark:0:0|a Campaign Complete")

-- Progress summary (shown at top of progress tab, under hero)
local dProgSummary = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
dProgSummary:SetJustifyH("CENTER")
dProgSummary:SetTextColor(C_BODY[1]*0.80, C_BODY[2]*0.80, C_BODY[3]*0.80)

-- Chapter rows as interactive line items with hover + tooltip
local dChapterRows = {}   -- array of Button frames
local CH_ROW_H = 40
local CH_GAP   = 4
local CH_PORT  = 26       -- portrait circle size
local CH_LIST_W = 380     -- fixed width for chapter list (centered in panel)

-- Set a 2D NPC portrait from a pre-stored creature display ID
local function SetChapterPortrait(portraitTex, displayID)
    if displayID then
        SetPortraitTextureFromCreatureDisplayID(portraitTex, displayID)
    else
        portraitTex:SetTexture(nil)
    end
end

local function CreateChapterRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:EnableMouse(true)
    row:SetHeight(CH_ROW_H)

    -- Hover: Blizzard list highlight (has natural fade built in) + top/bottom lines
    local hBg = row:CreateTexture(nil, "HIGHLIGHT")
    hBg:SetTexture("Interface/BUTTONS/UI-Listbox-Highlight2")
    hBg:SetBlendMode("ADD")
    hBg:SetPoint("TOPLEFT", row, "TOPLEFT", -30, 0)
    hBg:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 30, 0)
    hBg:SetVertexColor(1.0, 0.82, 0.50, 0.15)

    local W8 = "Interface/Buttons/WHITE8x8"
    local BLK = CreateColor(0, 0, 0)
    local lC = CreateColor(0.15, 0.13, 0.09)

    local hLineTopL = row:CreateTexture(nil, "HIGHLIGHT")
    hLineTopL:SetTexture(W8); hLineTopL:SetBlendMode("ADD")
    hLineTopL:SetHeight(1)
    hLineTopL:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    hLineTopL:SetPoint("TOPRIGHT", row, "TOP", 0, 0)
    hLineTopL:SetGradient("HORIZONTAL", BLK, lC)

    local hLineTopR = row:CreateTexture(nil, "HIGHLIGHT")
    hLineTopR:SetTexture(W8); hLineTopR:SetBlendMode("ADD")
    hLineTopR:SetHeight(1)
    hLineTopR:SetPoint("TOPLEFT", row, "TOP", 0, 0)
    hLineTopR:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
    hLineTopR:SetGradient("HORIZONTAL", lC, BLK)

    local hLineBotL = row:CreateTexture(nil, "HIGHLIGHT")
    hLineBotL:SetTexture(W8); hLineBotL:SetBlendMode("ADD")
    hLineBotL:SetHeight(1)
    hLineBotL:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    hLineBotL:SetPoint("BOTTOMRIGHT", row, "BOTTOM", 0, 0)
    hLineBotL:SetGradient("HORIZONTAL", BLK, lC)

    local hLineBotR = row:CreateTexture(nil, "HIGHLIGHT")
    hLineBotR:SetTexture(W8); hLineBotR:SetBlendMode("ADD")
    hLineBotR:SetHeight(1)
    hLineBotR:SetPoint("BOTTOMLEFT", row, "BOTTOM", 0, 0)
    hLineBotR:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
    hLineBotR:SetGradient("HORIZONTAL", lC, BLK)

    -- Portrait container
    local portFrame = CreateFrame("Frame", nil, row)
    portFrame:SetSize(CH_PORT, CH_PORT)
    portFrame:SetPoint("LEFT", row, "LEFT", 12, 0)

    -- NPC portrait texture (ARTWORK layer — behind OVERLAY ring)
    local portrait = portFrame:CreateTexture(nil, "ARTWORK")
    portrait:SetSize(CH_PORT - 2, CH_PORT - 2)
    portrait:SetPoint("CENTER")
    portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    portrait:SetTexelSnappingBias(0)
    portrait:SetSnapToPixelGrid(false)

    -- Circular mask for portrait
    local mask = portFrame:CreateMaskTexture()
    mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(portrait)
    portrait:AddMaskTexture(mask)

    row.portrait = portrait
    row.portFrame = portFrame

    -- Circular ring border around portrait (OVERLAY — on top of portrait)
    local ring = portFrame:CreateTexture(nil, "OVERLAY")
    ring:SetAtlas("ui-frame-genericplayerchoice-portrait-border", false)
    ring:SetPoint("TOPLEFT", portrait, "TOPLEFT", -3, 3)
    ring:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 3, -3)
    ring:SetVertexColor(0.8, 0.68, 0.45)
    ring:SetAlpha(0.6)
    row.ring = ring

    -- Checkmark overlay on portrait (shown when chapter is complete)
    local checkmark = portFrame:CreateTexture(nil, "OVERLAY", nil, 2)
    checkmark:SetAtlas("common-icon-checkmark", false)
    checkmark:SetSize(CH_PORT * 0.6, CH_PORT * 0.6)
    checkmark:SetPoint("CENTER", portFrame, "CENTER", 0, 0)
    checkmark:Hide()
    row.checkmark = checkmark

    -- Text anchor (vertically centered pair: title + subtitle)
    local textAnchor = CreateFrame("Frame", nil, row)
    textAnchor:SetPoint("LEFT",   portFrame, "RIGHT", 10, 0)
    textAnchor:SetPoint("RIGHT",  row,       "RIGHT", -12, 0)
    textAnchor:SetPoint("TOP",    row,       "TOP",    0, 0)
    textAnchor:SetPoint("BOTTOM", row,       "BOTTOM", 0, 0)

    -- Chapter title label
    local label = NoShadow(textAnchor:CreateFontString(nil, "ARTWORK", "GameFontNormal"))
    label:SetPoint("LEFT",   textAnchor, "LEFT",   0, 0)
    label:SetPoint("RIGHT",  textAnchor, "RIGHT",  0, 0)
    label:SetPoint("BOTTOM", textAnchor, "CENTER", 0, 0)
    label:SetJustifyH("LEFT"); label:SetJustifyV("BOTTOM"); label:SetWordWrap(false)
    row.label = label

    -- Progress subtitle (e.g. "3 / 5 quests") in divider text color
    local progressLabel = NoShadow(textAnchor:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
    progressLabel:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -1)
    progressLabel:SetJustifyH("LEFT")
    progressLabel:SetTextColor(C_BODY[1]*0.80, C_BODY[2]*0.80, C_BODY[3]*0.80)
    row.progressLabel = progressLabel

    -- Hover / tooltip
    row:SetScript("OnEnter", function(self)
        if self.tooltipTitle then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.tooltipTitle, 1, 1, 1)
            if self.tooltipBody then
                GameTooltip:AddLine(self.tooltipBody, C_BODY[1], C_BODY[2], C_BODY[3], true)
            end
            if self.tooltipProgress then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(self.tooltipProgress, C_DIM[1], C_DIM[2], C_DIM[3])
            end
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    return row
end

-- Forward declarations for cross-referenced variables
local currentStoryData = nil   -- set by UpdateStoryDetail, read by LayoutSelectedChapter

-- ══ Renown-Track Style Chapter Selector + Quest Cards ══════════════════
-- Horizontal chapter track with quest detail cards below

local TRACK_NODE_SIZE = 40      -- portrait circle diameter
local TRACK_ARROW_GAP = 20     -- space between nodes (contains arrow)
local TRACK_STEP = TRACK_NODE_SIZE + TRACK_ARROW_GAP  -- 60px per step
local TRACK_H = 60              -- track container height

local QCARD_H = 44 + 8         -- quest card height (44 + 4px top/bottom padding)
local QCARD_GAP = 3            -- gap between cards

-- (quest cards now use housefinder atlas, no backdrop needed)

-- State
local dSelectedChapter = 1
local dTrackScrollOffset = 0
local dTrackMaxScroll = 0
local dTrackChapterCount = 0

-- Forward-declare pools (used by CenterTrackOnSelected)
local dTrackNodes = {}
local dTrackArrows = {}

-- ── Track container (persistent, created once) ──────────────────────
local dTrackContainer = CreateFrame("Frame", nil, detailChild)
dTrackContainer:SetHeight(TRACK_H)
dTrackContainer:Hide()

-- Clip frame — full width, fades are done via node alpha instead of overlays
local dTrackClip = CreateFrame("Frame", nil, dTrackContainer)
dTrackClip:SetClipsChildren(true)
dTrackClip:SetPoint("TOPLEFT", dTrackContainer, "TOPLEFT", 0, 0)
dTrackClip:SetPoint("BOTTOMRIGHT", dTrackContainer, "BOTTOMRIGHT", 0, 0)

-- Inner frame that slides left/right
local dTrackInner = CreateFrame("Frame", nil, dTrackClip)
dTrackInner:SetPoint("LEFT", dTrackClip, "LEFT", 0, 0)
dTrackInner:SetHeight(TRACK_H)

-- Centers the track so selected chapter is in the middle of the clip
-- Also applies distance-based alpha fade to each node
local function CenterTrackOnSelected(clipW)
    if clipW <= 0 then clipW = 350 end
    local selCenterX = (dSelectedChapter - 1) * TRACK_STEP + TRACK_NODE_SIZE / 2
    local offset = selCenterX - clipW / 2
    dTrackInner:ClearAllPoints()
    dTrackInner:SetPoint("LEFT", dTrackClip, "LEFT", -offset, 0)
    -- Apply distance-based alpha fade to nodes
    local center = clipW / 2
    local fadeStart = center - TRACK_NODE_SIZE  -- start fading past this distance
    local fadeEnd = clipW / 2 + 10             -- fully faded at edge
    for i, node in ipairs(dTrackNodes) do
        if not node:IsShown() then break end
        local nodeCenter = (i - 1) * TRACK_STEP + TRACK_NODE_SIZE / 2 - offset
        local dist = math.abs(nodeCenter - center)
        if dist <= fadeStart then
            node:SetAlpha(1.0)
        elseif dist >= fadeEnd then
            node:SetAlpha(0.0)
        else
            node:SetAlpha(1.0 - (dist - fadeStart) / (fadeEnd - fadeStart))
        end
    end
    -- Same for between-node arrows
    for i, arrow in ipairs(dTrackArrows) do
        if not arrow:IsShown() then break end
        local arrowX = (i - 1) * TRACK_STEP + TRACK_NODE_SIZE + TRACK_ARROW_GAP / 2 - offset
        local dist = math.abs(arrowX - center)
        if dist <= fadeStart then
            arrow:SetAlpha(1.0)
        elseif dist >= fadeEnd then
            arrow:SetAlpha(0.0)
        else
            arrow:SetAlpha(1.0 - (dist - fadeStart) / (fadeEnd - fadeStart))
        end
    end
end

-- Navigation arrows — always visible, navigate between chapters
local LayoutSelectedChapter  -- forward declare for arrow callbacks

local NAV_ARROW_SIZE = 22
local NAV_ARROW_INSET = 12

-- Left arrow
local dTrackLeftBtn = CreateFrame("Button", nil, dTrackContainer)
dTrackLeftBtn:SetSize(NAV_ARROW_SIZE + 16, NAV_ARROW_SIZE + 16)
dTrackLeftBtn:SetPoint("LEFT", dTrackContainer, "LEFT", NAV_ARROW_INSET, 5)
dTrackLeftBtn:SetFrameLevel(dTrackClip:GetFrameLevel() + 20)
local dTrackLeftTex = dTrackLeftBtn:CreateTexture(nil, "ARTWORK")
dTrackLeftTex:SetAtlas("common-icon-forwardarrow", false)
dTrackLeftTex:SetSize(NAV_ARROW_SIZE, NAV_ARROW_SIZE)
dTrackLeftTex:SetPoint("CENTER")
dTrackLeftTex:SetRotation(math.pi)
dTrackLeftTex:SetVertexColor(0.85, 0.75, 0.55)
dTrackLeftBtn:SetScript("OnEnter", function() dTrackLeftTex:SetVertexColor(1, 0.90, 0.65) end)
dTrackLeftBtn:SetScript("OnLeave", function() dTrackLeftTex:SetVertexColor(0.85, 0.75, 0.55) end)
dTrackLeftBtn:SetScript("OnClick", function()
    if dSelectedChapter > 1 then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        dSelectedChapter = dSelectedChapter - 1
        LayoutSelectedChapter()
        C_Timer.After(0, function() CenterTrackOnSelected(dTrackClip:GetWidth()) end)
    end
end)

-- Right arrow
local dTrackRightBtn = CreateFrame("Button", nil, dTrackContainer)
dTrackRightBtn:SetSize(NAV_ARROW_SIZE + 16, NAV_ARROW_SIZE + 16)
dTrackRightBtn:SetPoint("RIGHT", dTrackContainer, "RIGHT", -NAV_ARROW_INSET, 5)
dTrackRightBtn:SetFrameLevel(dTrackClip:GetFrameLevel() + 20)
local dTrackRightTex = dTrackRightBtn:CreateTexture(nil, "ARTWORK")
dTrackRightTex:SetAtlas("common-icon-forwardarrow", false)
dTrackRightTex:SetSize(NAV_ARROW_SIZE, NAV_ARROW_SIZE)
dTrackRightTex:SetPoint("CENTER")
dTrackRightTex:SetVertexColor(0.85, 0.75, 0.55)
dTrackRightBtn:SetScript("OnEnter", function() dTrackRightTex:SetVertexColor(1, 0.90, 0.65) end)
dTrackRightBtn:SetScript("OnLeave", function() dTrackRightTex:SetVertexColor(0.85, 0.75, 0.55) end)
dTrackRightBtn:SetScript("OnClick", function()
    if dSelectedChapter < dTrackChapterCount then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        dSelectedChapter = dSelectedChapter + 1
        LayoutSelectedChapter()
        C_Timer.After(0, function() CenterTrackOnSelected(dTrackClip:GetWidth()) end)
    end
end)

-- Mousewheel on track changes selection
dTrackContainer:EnableMouseWheel(true)
dTrackContainer:SetScript("OnMouseWheel", function(_, delta)
    if delta > 0 and dSelectedChapter > 1 then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        dSelectedChapter = dSelectedChapter - 1
        LayoutSelectedChapter()
        C_Timer.After(0, function() CenterTrackOnSelected(dTrackClip:GetWidth()) end)
    elseif delta < 0 and dSelectedChapter < dTrackChapterCount then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        dSelectedChapter = dSelectedChapter + 1
        LayoutSelectedChapter()
        C_Timer.After(0, function() CenterTrackOnSelected(dTrackClip:GetWidth()) end)
    end
end)

-- Chapter title + summary below track
local dChapterTitle = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
dChapterTitle:SetJustifyH("CENTER")
dChapterTitle:Hide()

local dChapterSummary = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
dChapterSummary:SetJustifyH("LEFT"); dChapterSummary:SetSpacing(4); dChapterSummary:SetWordWrap(true)
dChapterSummary:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
dChapterSummary:Hide()

-- ── Track node pool ─────────────────────────────────────────────────
local function CreateTrackNode(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(TRACK_NODE_SIZE, TRACK_NODE_SIZE)

    -- Portrait
    local portrait = btn:CreateTexture(nil, "ARTWORK")
    portrait:SetSize(TRACK_NODE_SIZE - 4, TRACK_NODE_SIZE - 4)
    portrait:SetPoint("TOP", btn, "TOP", 0, 0)
    portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    portrait:SetTexelSnappingBias(0)
    portrait:SetSnapToPixelGrid(false)

    local mask = btn:CreateMaskTexture()
    mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(portrait)
    portrait:AddMaskTexture(mask)
    btn.portrait = portrait

    -- Ring
    local ring = btn:CreateTexture(nil, "OVERLAY")
    ring:SetAtlas("ui-frame-genericplayerchoice-portrait-border", false)
    ring:SetPoint("TOPLEFT", portrait, "TOPLEFT", -3, 3)
    ring:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 3, -3)
    btn.ring = ring

    -- Number badge
    -- Checkmark badge (top-right)
    local checkmark = btn:CreateTexture(nil, "OVERLAY", nil, 2)
    checkmark:SetAtlas("common-icon-checkmark", false)
    checkmark:SetSize(14, 14)
    checkmark:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 4, -4)
    checkmark:Hide()
    btn.checkmark = checkmark

    -- Hover highlight (masked to circle)
    local hl = btn:CreateTexture(nil, "HIGHLIGHT")
    hl:SetTexture("Interface/Buttons/WHITE8x8")
    hl:SetAllPoints(portrait)
    hl:SetVertexColor(1, 0.82, 0.50, 0.2)
    local hlMask = btn:CreateMaskTexture()
    hlMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    hlMask:SetAllPoints(portrait)
    hl:AddMaskTexture(hlMask)

    -- Active glow (same as hover but always-on for selected node)
    local activeGlow = btn:CreateTexture(nil, "ARTWORK", nil, 3)
    activeGlow:SetTexture("Interface/Buttons/WHITE8x8")
    activeGlow:SetAllPoints(portrait)
    activeGlow:SetVertexColor(1, 0.82, 0.50, 0.25)
    local glowMask = btn:CreateMaskTexture()
    glowMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    glowMask:SetAllPoints(portrait)
    activeGlow:AddMaskTexture(glowMask)
    activeGlow:Hide()
    btn.activeGlow = activeGlow

    -- Down-arrow indicator (below node, points to quest cards)
    local downArrow = btn:CreateTexture(nil, "OVERLAY", nil, 3)
    downArrow:SetAtlas("common-icon-forwardarrow", false)
    downArrow:SetSize(14, 14)
    downArrow:SetPoint("TOP", portrait, "BOTTOM", 0, 2)
    downArrow:SetRotation(-math.pi / 2) -- rotate 90° clockwise to point down
    downArrow:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
    downArrow:Hide()
    btn.downArrow = downArrow

    -- Tooltip
    btn:SetScript("OnEnter", function(self)
        if self.tooltipTitle then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.tooltipTitle, 1, 1, 1)
            if self.tooltipBody then
                GameTooltip:AddLine(self.tooltipBody, C_BODY[1], C_BODY[2], C_BODY[3], true)
            end
            if self.tooltipProgress then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(self.tooltipProgress, C_DIM[1], C_DIM[2], C_DIM[3])
            end
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return btn
end

-- ── Quest card pool ─────────────────────────────────────────────────
local dQuestCards = {}

local function CreateQuestCard(parent)
    local card = CreateFrame("Button", nil, parent)
    card:EnableMouse(true)
    card:SetHeight(QCARD_H)

    -- Housing endeavor-style card background
    local bg = card:CreateTexture(nil, "BACKGROUND")
    bg:SetAtlas("housing-dashboard-initiatives-tasks-listitem-bg", false)
    bg:SetAllPoints()
    card.bg = bg

    -- Hover highlight
    card:SetHighlightAtlas("housing-dashboard-initiatives-tasks-listitem-bg")
    card:GetHighlightTexture():SetAllPoints()
    card:GetHighlightTexture():SetAlpha(0.3)

    -- Status icon (always 14x14 for consistent text alignment)
    local ICON_LEFT = 10
    local TEXT_LEFT = ICON_LEFT + 14 + 8  -- icon width + gap
    local icon = card:CreateTexture(nil, "ARTWORK")
    icon:SetSize(14, 14)
    icon:SetPoint("LEFT", card, "LEFT", ICON_LEFT, 0)
    card.icon = icon

    -- Quest name (top line)
    local title = NoShadow(card:CreateFontString(nil, "ARTWORK", "GameFontNormal"))
    title:SetPoint("LEFT", card, "LEFT", TEXT_LEFT, 0)
    title:SetPoint("RIGHT", card, "RIGHT", -10, 0)
    title:SetPoint("BOTTOM", card, "CENTER", 0, 1)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("BOTTOM")
    title:SetWordWrap(false)
    card.title = title

    -- NPC name (bottom line, same left edge as title)
    local npcLabel = NoShadow(card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
    npcLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    npcLabel:SetPoint("RIGHT", card, "RIGHT", -10, 0)
    npcLabel:SetJustifyH("LEFT")
    npcLabel:SetWordWrap(false)
    card.npcLabel = npcLabel

    -- Tooltip — native quest tooltip with requirements lines removed
    card:SetScript("OnEnter", function(self)
        if not self.questID then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        -- Quest name
        local qName = QuestUtils_GetQuestName(self.questID) or self.tooltipTitle or ""
        GameTooltip:AddLine(qName, 1, 1, 1)
        -- Quest giver
        if self.tooltipNPC then
            GameTooltip:AddLine(self.tooltipNPC, C_BODY[1], C_BODY[2], C_BODY[3])
        end
        -- Objectives
        local objectives = C_QuestLog.GetQuestObjectives(self.questID)
        if objectives and #objectives > 0 then
            GameTooltip:AddLine(" ")
            for _, obj in ipairs(objectives) do
                if obj.text and obj.text ~= "" then
                    if obj.finished then
                        GameTooltip:AddLine(obj.text, 0.45, 0.90, 0.35, true)
                    else
                        GameTooltip:AddLine(obj.text, 0.9, 0.9, 0.9, true)
                    end
                end
            end
        end
        -- Status
        if self.tooltipStatus then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(self.tooltipStatus)
        end

        GameTooltip:Show()
    end)
    card:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return card
end

-- ── Render quest cards for selected chapter ─────────────────────────
LayoutSelectedChapter = function()
    local data = currentStoryData
    if not data then return end
    local chapters = GetAllChapters(data)
    local ch = chapters[dSelectedChapter]
    if not ch then return end

    -- Update nav arrow enabled state
    local canGoLeft = dSelectedChapter > 1
    local canGoRight = dSelectedChapter < dTrackChapterCount
    dTrackLeftBtn:SetEnabled(canGoLeft)
    dTrackLeftTex:SetVertexColor(canGoLeft and 0.85 or 0.3, canGoLeft and 0.75 or 0.25, canGoLeft and 0.55 or 0.2)
    dTrackLeftTex:SetAlpha(canGoLeft and 1.0 or 0.3)
    dTrackRightBtn:SetEnabled(canGoRight)
    dTrackRightTex:SetVertexColor(canGoRight and 0.85 or 0.3, canGoRight and 0.75 or 0.25, canGoRight and 0.55 or 0.2)
    dTrackRightTex:SetAlpha(canGoRight and 1.0 or 0.3)

    -- Update track selection visuals
    for i, node in ipairs(dTrackNodes) do
        if not node:IsShown() then break end
        if i == dSelectedChapter then
            node.ring:SetAlpha(1.0)
            node.ring:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
            node.activeGlow:Show()
            node.downArrow:Show()
        else
            node.activeGlow:Hide()
            node.downArrow:Hide()
        end
    end

    -- Chapter title + summary
    dChapterTitle:SetText(ch.chapter)
    dChapterTitle:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
    dChapterTitle:Show()

    if ch.summary then
        dChapterSummary:SetText(ch.summary)
        dChapterSummary:Show()
    else
        dChapterSummary:Hide()
    end

    -- Quest cards
    local nextQuest = FindNextQuest(data)
    local nextQuestID = nextQuest and nextQuest.id

    for i, q in ipairs(ch.quests) do
        if not dQuestCards[i] then
            dQuestCards[i] = CreateQuestCard(detailChild)
        end
        local card = dQuestCards[i]
        local nextCh = chapters[dSelectedChapter + 1]
        local qDone = IsQuestEffectivelyComplete(i, ch.quests, nextCh and nextCh.quests)
        local qInLog = not qDone and IsQuestInLog(q.id)
        local qIsCurrent = (q.id == nextQuestID) or qInLog

        card.title:SetText(q.name)
        card.npcLabel:SetText(q.npc or "")
        card.questID = q.id
        card.tooltipTitle = q.name
        card.tooltipNPC = q.npc
        card.tooltipStatus = qDone and "|cff59c746Completed|r" or qIsCurrent and "|cffffd223In Progress|r" or "|cff808080Not yet available|r"

        card.icon:SetSize(14, 14)
        card.icon:SetDesaturation(0)
        if qDone then
            card.icon:SetAtlas("common-icon-checkmark", false)
            card.icon:SetVertexColor(0.45, 0.90, 0.35)
            card.icon:Show()
            card.title:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3], 0.8)
            card.npcLabel:SetTextColor(C_BODY[1] * 0.8, C_BODY[2] * 0.8, C_BODY[3] * 0.8, 0.6)
            card:SetAlpha(1.0)
        elseif qIsCurrent then
            card.icon:SetAtlas("common-icon-forwardarrow", false)
            card.icon:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
            card.icon:Show()
            card.title:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
            card.npcLabel:SetTextColor(C_BODY[1] * 0.8, C_BODY[2] * 0.8, C_BODY[3] * 0.8, 0.7)
            card:SetAlpha(1.0)
        else
            card.icon:Hide()
            card.title:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3], 0.6)
            card.npcLabel:SetTextColor(C_BODY[1] * 0.8, C_BODY[2] * 0.8, C_BODY[3] * 0.8, 0.4)
            card:SetAlpha(0.8)
        end

        card:Show()
    end
    for i = #ch.quests + 1, #dQuestCards do dQuestCards[i]:Hide() end

    -- Position cards below summary (centered, fixed width)
    local CARD_W = 280
    for i = 1, #ch.quests do
        local card = dQuestCards[i]
        card:ClearAllPoints()
        card:SetWidth(CARD_W)
        if i == 1 then
            local anchor = dChapterSummary:IsShown() and dChapterSummary or dChapterTitle
            card:SetPoint("TOP", anchor, "BOTTOM", 0, -20)
        else
            card:SetPoint("TOP", dQuestCards[i - 1], "BOTTOM", 0, -QCARD_GAP)
        end
        -- Center horizontally: anchor LEFT relative to detailChild center
        card:SetPoint("LEFT", detailChild, "CENTER", -CARD_W / 2, 0)
    end

    -- Update scroll height
    local lastCard = dQuestCards[#ch.quests]
    C_Timer.After(0, function()
        if lastCard then
            local bot = lastCard:GetBottom()
            local top = detailChild:GetTop()
            if bot and top then
                detailChild:SetHeight(math.max(top - bot + 30, 400))
            end
        end
    end)
end

local progressElements = { dCompleteText, dProgSummary, dTrackContainer, dChapterTitle, dChapterSummary }

local function ShowDetail(show)
    heroFrame[show and "Show" or "Hide"](heroFrame)
end

local function ShowTab(tab)
    -- Hide all tab-specific elements
    for _, el in ipairs(storyElements) do el:Hide() end
    for _, entry in ipairs(sJournalEntries) do entry.title:Hide(); entry.body:Hide() end
    for _, el in ipairs(progressElements) do el:Hide() end
    for _, row in ipairs(dChapterRows) do row:Hide() end
    for _, node in ipairs(dTrackNodes) do node:Hide() end
    for _, arrow in ipairs(dTrackArrows) do arrow:Hide() end
    for _, card in ipairs(dQuestCards) do card:Hide() end
    sTrackBtn:Hide(); sCompleteText:Hide()
    dCompleteText:Hide()

    if tab == "story" then
        for _, el in ipairs(storyElements) do el:Show() end
    else
        for _, el in ipairs(progressElements) do el:Show() end
    end
end

local function SetActiveTab(tab)
    activeTab = tab
    if tab == "story" then
        tabStoryLabel:SetTextColor(1, 1, 1)
        tabProgressLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
    else
        tabStoryLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        tabProgressLabel:SetTextColor(1, 1, 1)
    end
end

ShowDetail(false)
for _, el in ipairs(storyElements) do el:Hide() end
for _, el in ipairs(progressElements) do el:Hide() end

-- ════════════════════════════════════════════════════════════════════════════
-- UpdateStoryDetail  +  LayoutDetailTab
-- ════════════════════════════════════════════════════════════════════════════

local storySelectedIdx = nil

-- ── Layout the currently active tab ─────────────────────────────────────────
local function LayoutDetailTab()
    local data = currentStoryData
    if not data then return end

    local w = detailChild:GetWidth()
    local contentW = w - CP * 2

    ShowTab(activeTab)

    local divW = w - DP * 2
    if divW < 20 then divW = 400 end

    if activeTab == "story" then
        -- ── STORY TAB layout ────────────────────────────────────────────
        -- Clean top-down chain: hero → intro → CTA → journal recaps

        -- Story intro below hero
        sIntro:ClearAllPoints()
        sIntro:SetPoint("TOPLEFT",  heroFrame, "BOTTOMLEFT",  CP, -10)
        sIntro:SetPoint("TOPRIGHT", heroFrame, "BOTTOMRIGHT", -CP, -10)
        if contentW > 20 then sIntro:SetWidth(contentW) end

        -- Key Characters
        local npcNames = {}
        local seen = {}
        if data.npcLocations then
            for name in pairs(data.npcLocations) do
                if not seen[name] then
                    seen[name] = true
                    table.insert(npcNames, name)
                end
            end
            table.sort(npcNames)
        end

        local lastAnchor = sIntro
        if #npcNames > 0 then
            sCharHeader:ClearAllPoints()
            sCharHeader:SetPoint("TOP", sIntro, "BOTTOM", 0, -20)
            sCharHeader:Show()

            sCharText:ClearAllPoints()
            sCharText:SetPoint("TOP", sCharHeader, "BOTTOM", 0, -8)
            if contentW > 20 then sCharText:SetWidth(contentW) end
            sCharText:SetText(table.concat(npcNames, "  \194\183  "))
            sCharText:Show()

            lastAnchor = sCharText
        else
            sCharHeader:Hide(); sCharText:Hide()
        end

        -- CTA button
        local quest = FindNextQuest(data)
        local done = select(1, GetCampaignProgress(data))
        if quest then
            sTrackBtn:SetText(done > 0 and "Continue Story" or "Begin This Story")
            sTrackBtn:ClearAllPoints()
            sTrackBtn:SetPoint("TOP", lastAnchor, "BOTTOM", 0, -24)
            sTrackBtn:SetScript("OnClick", function()
                local result = SetWaypointForQuest(data, quest)
                PrintTrackResult(result, quest, data)
                storyFrame:Hide()
            end)
            sTrackBtn:Show(); sCompleteText:Hide()
            lastAnchor = sTrackBtn
        else
            sCompleteText:ClearAllPoints()
            sCompleteText:SetPoint("TOP", lastAnchor, "BOTTOM", 0, -24)
            sCompleteText:Show(); sTrackBtn:Hide()
            lastAnchor = sCompleteText
        end

        -- ── Progressive story journal ───────────────────────────────────
        -- Show recap for each completed chapter (no spoilers for future ones)
        local chapters = GetAllChapters(data)
        local journalIdx = 0
        local hasAnyRecap = false

        for ci, ch in ipairs(chapters) do
            local cd, ct = GetChapterProgress(ch, chapters[ci + 1])
            local chComplete = cd == ct and ct > 0
            if chComplete and ch.recap then
                journalIdx = journalIdx + 1
                hasAnyRecap = true
                local entry = GetJournalEntry(journalIdx)

                -- Chapter title
                entry.title:ClearAllPoints()
                if journalIdx == 1 then
                    -- First entry anchors to the journal header
                    sJournalHeader:ClearAllPoints()
                    sJournalHeader:SetPoint("TOP", lastAnchor, "BOTTOM", 0, -30)
                    sJournalHeader:Show()
                    entry.title:SetPoint("TOP", sJournalHeader, "BOTTOM", 0, -16)
                else
                    local prev = sJournalEntries[journalIdx - 1]
                    entry.title:SetPoint("TOP", prev.body, "BOTTOM", 0, -20)
                end
                entry.title:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
                entry.title:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
                entry.title:SetText(ch.chapter)
                entry.title:Show()

                -- Recap body
                entry.body:ClearAllPoints()
                entry.body:SetPoint("TOP", entry.title, "BOTTOM", 0, -6)
                entry.body:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
                entry.body:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
                entry.body:SetText(ch.recap)
                entry.body:Show()

                lastAnchor = entry.body
            end
        end

        if not hasAnyRecap then
            sJournalHeader:Hide()
        end

        -- Hide unused journal entries
        for i = journalIdx + 1, #sJournalEntries do
            sJournalEntries[i].title:Hide()
            sJournalEntries[i].body:Hide()
        end

        local storyBottomEl = lastAnchor
        -- Set scroll height
        C_Timer.After(0, function()
            local bot = storyBottomEl:GetBottom()
            local top = detailChild:GetTop()
            if bot and top then
                detailChild:SetHeight(math.max(top - bot + 40, 400))
            else
                detailChild:SetHeight(500)
            end
        end)

    else
        -- ── PROGRESS TAB layout ─────────────────────────────────────────
        local chapters = GetAllChapters(data)

        -- CTA
        -- Progress summary line
        local done, total = GetCampaignProgress(data)
        local chapDone = 0
        for ci, ch in ipairs(chapters) do
            local cd, ct = GetChapterProgress(ch, chapters[ci + 1])
            if cd == ct and ct > 0 then chapDone = chapDone + 1 end
        end
        dProgSummary:SetText("Chapter " .. chapDone .. " of " .. #chapters
            .. "  \194\183  " .. done .. "/" .. total .. " quests")
        dProgSummary:ClearAllPoints()
        dProgSummary:SetPoint("TOP", heroFrame, "BOTTOM", 0, -6)
        dProgSummary:Show()

        -- CTA
        local quest = FindNextQuest(data)
        if not quest then
            dCompleteText:Show()
            dCompleteText:ClearAllPoints()
            dCompleteText:SetPoint("TOP", dProgSummary, "BOTTOM", 0, -10)
        else
            dCompleteText:Hide()
        end

        -- ── Horizontal chapter track + quest cards ────────────────────
        local GREEN_R, GREEN_G, GREEN_B = 0.35, 0.78, 0.28
        local GOLD_R, GOLD_G, GOLD_B = 1.0, 0.82, 0.35
        local DIM_R, DIM_G, DIM_B = C_DIM[1], C_DIM[2], C_DIM[3]

        -- Hide old pools
        for _, node in ipairs(dTrackNodes) do node:Hide() end
        for _, arrow in ipairs(dTrackArrows) do arrow:Hide() end
        for _, card in ipairs(dQuestCards) do card:Hide() end

        -- Determine which chapter to auto-select (first incomplete, or last)
        local autoSelect = #chapters
        for i, ch in ipairs(chapters) do
            local cd, ct = GetChapterProgress(ch, chapters[i + 1])
            if cd < ct or ct == 0 then autoSelect = i; break end
        end
        dSelectedChapter = autoSelect
        dTrackChapterCount = #chapters

        -- Build horizontal track nodes
        local totalTrackW = #chapters * TRACK_NODE_SIZE + math.max(0, #chapters - 1) * TRACK_ARROW_GAP
        dTrackInner:SetWidth(totalTrackW)
        local lineY = math.floor(TRACK_NODE_SIZE / 2)

        for i, ch in ipairs(chapters) do
            if not dTrackNodes[i] then
                dTrackNodes[i] = CreateTrackNode(dTrackInner)
            end
            local node = dTrackNodes[i]
            local cDone, cTotal = GetChapterProgress(ch, chapters[i + 1])
            local isComplete = cDone == cTotal and cTotal > 0
            local isActive = cDone > 0 and not isComplete

            -- NPC portrait
            local npcName = ch.quests and ch.quests[1] and ch.quests[1].npc
            local displayID = npcName and data.npcDisplayIDs and data.npcDisplayIDs[npcName]
            SetChapterPortrait(node.portrait, displayID)

            -- Tooltip
            node.tooltipTitle = ch.chapter
            node.tooltipBody = ch.summary or nil
            node.tooltipProgress = cDone .. " / " .. cTotal .. " quests"

            -- Status styling
            if isComplete then
                node.portrait:SetVertexColor(1, 1, 1)
                node.portrait:SetDesaturation(0)
                node.ring:SetVertexColor(GREEN_R, GREEN_G, GREEN_B)
                node.ring:SetAlpha(0.8)
                node.checkmark:Show()
            elseif isActive then
                node.portrait:SetVertexColor(1, 1, 1)
                node.portrait:SetDesaturation(0)
                node.ring:SetVertexColor(GOLD_R, GOLD_G, GOLD_B)
                node.ring:SetAlpha(0.9)
                node.checkmark:Hide()
            else
                node.portrait:SetVertexColor(0.6, 0.6, 0.6)
                node.portrait:SetDesaturation(0.7)
                node.ring:SetVertexColor(0.4, 0.35, 0.30)
                node.ring:SetAlpha(0.5)
                node.checkmark:Hide()
            end

            -- Position
            node:ClearAllPoints()
            local x = (i - 1) * TRACK_STEP
            node:SetPoint("TOP", dTrackInner, "TOPLEFT", x + TRACK_NODE_SIZE / 2, -6)

            -- Click handler
            local idx = i
            node:SetScript("OnClick", function()
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                dSelectedChapter = idx
                LayoutSelectedChapter()
                C_Timer.After(0, function() CenterTrackOnSelected(dTrackClip:GetWidth()) end)
            end)

            node:Show()

            -- Arrow between nodes (except after last)
            if i < #chapters then
                if not dTrackArrows[i] then
                    dTrackArrows[i] = dTrackInner:CreateTexture(nil, "ARTWORK")
                    dTrackArrows[i]:SetAtlas("common-icon-forwardarrow", false)
                    dTrackArrows[i]:SetSize(10, 10)
                end
                local arrow = dTrackArrows[i]
                arrow:ClearAllPoints()
                arrow:SetPoint("LEFT", dTrackInner, "TOPLEFT",
                    x + TRACK_NODE_SIZE + (TRACK_ARROW_GAP - 10) / 2, -(lineY + 6))

                -- Arrow color
                local nextCh = chapters[i + 1]
                local nd, nt = GetChapterProgress(nextCh)
                if isComplete then
                    arrow:SetVertexColor(GREEN_R, GREEN_G, GREEN_B, 0.6)
                else
                    arrow:SetVertexColor(DIM_R, DIM_G, DIM_B, 0.3)
                end
                arrow:Show()
            end
        end
        for i = #chapters + 1, #dTrackNodes do dTrackNodes[i]:Hide() end
        for i = #chapters, #dTrackArrows do if dTrackArrows[i] then dTrackArrows[i]:Hide() end end

        -- Position track container
        dTrackContainer:ClearAllPoints()
        dTrackContainer:SetPoint("TOP", dProgSummary, "BOTTOM", 0, -10)
        dTrackContainer:SetPoint("LEFT", detailChild, "LEFT", 0, 0)
        dTrackContainer:SetPoint("RIGHT", detailChild, "RIGHT", 0, 0)
        dTrackContainer:Show()

        -- Center track on selected chapter + apply node fading
        C_Timer.After(0, function()
            local clipW = dTrackClip:GetWidth()
            CenterTrackOnSelected(clipW)
            dTrackLeftBtn:Show()
            dTrackRightBtn:Show()
        end)

        -- Chapter title + summary below track
        dChapterTitle:ClearAllPoints()
        dChapterTitle:SetPoint("TOPLEFT", dTrackContainer, "BOTTOMLEFT", CP, -10)
        dChapterTitle:SetPoint("TOPRIGHT", dTrackContainer, "BOTTOMRIGHT", -CP, -10)

        dChapterSummary:ClearAllPoints()
        dChapterSummary:SetPoint("TOPLEFT", dChapterTitle, "BOTTOMLEFT", 0, -4)
        dChapterSummary:SetPoint("TOPRIGHT", dChapterTitle, "BOTTOMRIGHT", 0, -4)

        -- Render quest cards for selected chapter
        LayoutSelectedChapter()
    end
end

-- ── Tab hover + click handlers ──────────────────────────────────────────────
tabStoryHit:SetScript("OnEnter", function()
    if activeTab ~= "story" then tabStoryLabel:SetTextColor(1, 1, 1) end
end)
tabStoryHit:SetScript("OnLeave", function()
    if activeTab ~= "story" then tabStoryLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3]) end
end)
tabStoryHit:SetScript("OnClick", function()
    if activeTab ~= "story" and currentStoryData then
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        SetActiveTab("story")
        detailScroll:SetVerticalScroll(0)
        LayoutDetailTab()
    end
end)

tabProgressHit:SetScript("OnEnter", function()
    if activeTab ~= "progress" then tabProgressLabel:SetTextColor(1, 1, 1) end
end)
tabProgressHit:SetScript("OnLeave", function()
    if activeTab ~= "progress" then tabProgressLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3]) end
end)
tabProgressHit:SetScript("OnClick", function()
    if activeTab ~= "progress" and currentStoryData then
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        SetActiveTab("progress")
        detailScroll:SetVerticalScroll(0)
        LayoutDetailTab()
    end
end)

-- ── Main entry point ────────────────────────────────────────────────────────
local function UpdateStoryDetail(data)
    if not data then
        currentStoryData = nil
        ShowDetail(false)
        -- Hide all tab elements
        for _, el in ipairs(storyElements) do el:Hide() end
        for _, entry in ipairs(sJournalEntries) do entry.title:Hide(); entry.body:Hide() end
        for _, el in ipairs(progressElements) do el:Hide() end
        for _, row in ipairs(dChapterRows) do row:Hide() end
        for _, node in ipairs(dTrackNodes) do node:Hide() end
        for _, arrow in ipairs(dTrackArrows) do arrow:Hide() end
        for _, card in ipairs(dQuestCards) do card:Hide() end
        sTrackBtn:Hide(); sCompleteText:Hide()
        dCompleteText:Hide()
        introIcon2:Show(); introTitle:Show(); introText:Show()
        heroIcon:SetTexture(nil)
        smHeaderSub:SetText("")
        SetActiveTab("story")
        -- Hide tabs on intro page
        tabStoryLabel:Hide(); tabProgressLabel:Hide()
        tabStoryHit:Hide(); tabProgressHit:Hide()
        C_Timer.After(0, function()
            local w = detailScroll:GetWidth()
            if w > 20 then
                detailChild:SetWidth(w)
                introText:SetWidth(w - CP * 2)
            end
            C_Timer.After(0, function()
                local h = introText:GetStringHeight()
                detailChild:SetHeight(math.max((h or 0) + 80, 400))
            end)
        end)
        return
    end

    currentStoryData = data
    introIcon2:Hide(); introTitle:Hide(); introText:Hide(); ShowDetail(true)
    -- Show tabs when a story is selected
    tabStoryLabel:Show(); tabProgressLabel:Show()
    tabStoryHit:Show(); tabProgressHit:Show()

    -- Portrait icon (creature portrait or texture)
    if data.portraitDisplayID then
        SetPortraitTextureFromCreatureDisplayID(heroIcon, data.portraitDisplayID)
    else
        local iconID
        if data.achievementID then
            local _,_,_,_,_,_,_,_,_,achIcon = GetAchievementInfo(data.achievementID)
            if achIcon and achIcon ~= 0 then iconID = achIcon end
        end
        iconID = iconID or data.icon
        if iconID and iconID ~= 0 then heroIcon:SetTexture(iconID) else heroIcon:SetTexture(nil) end
    end

    local displayTitle = data.title
    if data.achievementID then
        local _, achName = GetAchievementInfo(data.achievementID)
        if achName then displayTitle = achName end
    end

    smHeaderSub:SetText("")
    dTitle:SetText(displayTitle)
    sIntro:SetText(data.description or "")

    -- Layout the active tab
    C_Timer.After(0, function()
        local w = detailChild:GetWidth()
        if w > 20 then sIntro:SetWidth(w - CP * 2) end
        C_Timer.After(0, function()
            LayoutDetailTab()
        end)
    end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- Left panel: category dividers + card building
-- ════════════════════════════════════════════════════════════════════════════

local storyLeftRows    = {}
local storyContentBuilt = false

-- Portrait circle sizes (Delve companion style)
local PORT = 46
local ICON = 34

local function SelectStory(index)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    storySelectedIdx = index
    for i, row in pairs(storyLeftRows) do
        local sel = (i == index)
        if row.btn then
            if sel then
                row.btn:LockHighlight()
            else
                row.btn:UnlockHighlight()
            end
        end
        row.bg:SetAlpha(sel and 1.0 or 0.6)
        row.portBorder:SetAlpha(sel and 1.0 or 0.5)
        local tb = sel and 1.0 or 0.60
        row.nameLabel:SetTextColor(C_BODY[1]*tb, C_BODY[2]*tb, C_BODY[3]*tb)
        if row.zoneLabel then row.zoneLabel:SetTextColor(C_DIM[1]*tb, C_DIM[2]*tb, C_DIM[3]*tb) end
    end
    if index == 0 or not allQuestlines[index] then
        UpdateStoryDetail(nil)
    else
        UpdateStoryDetail(allQuestlines[index])
    end
end

-- Category header (Trading Post style: label with thin ruled lines)
local function CreateCatDivider(parent, text, yOff)
    local CAT_H = 26
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(CAT_H)
    f:SetPoint("TOPLEFT",  parent, "TOPLEFT",  4, yOff)
    f:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, yOff)

    local lbl = NoShadow(f:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
    lbl:SetPoint("CENTER", f, "CENTER", 0, 0)
    lbl:SetJustifyH("CENTER")
    lbl:SetText(text)
    lbl:SetTextColor(C_BODY[1]*0.80, C_BODY[2]*0.80, C_BODY[3]*0.80)

    -- Thin ruled lines flanking the label (fade out toward edges)
    local lineL = f:CreateTexture(nil, "BACKGROUND")
    lineL:SetTexture(SOLID)
    lineL:SetHeight(1)
    lineL:SetPoint("LEFT",  f,   "LEFT",  6, 0)
    lineL:SetPoint("RIGHT", lbl, "LEFT", -8, 0)
    lineL:SetGradient("HORIZONTAL",
        CreateColor(1.0, 0.80, 0.45, 0),
        CreateColor(1.0, 0.80, 0.45, 0.5))

    local lineR = f:CreateTexture(nil, "BACKGROUND")
    lineR:SetTexture(SOLID)
    lineR:SetHeight(1)
    lineR:SetPoint("LEFT",  lbl, "RIGHT", 8, 0)
    lineR:SetPoint("RIGHT", f,   "RIGHT", -6, 0)
    lineR:SetGradient("HORIZONTAL",
        CreateColor(1.0, 0.80, 0.45, 0.5),
        CreateColor(1.0, 0.80, 0.45, 0))

    return CAT_H
end

local function BuildStoryWindow()
    if storyContentBuilt then return end
    storyContentBuilt = true
    for _, data in ipairs(allQuestlines) do ResolveAchievementID(data) end

    local CARD_H   = 78
    local CARD_PAD = 4
    local yOffset  = -8
    local globalIdx = 0

    -- ── Introduction card (index 0 = show intro text on right) ───────────
    local introDivH = CreateCatDivider(leftChild, "Story Mode", yOffset)
    yOffset = yOffset - introDivH - 4

    local introCard = CreateFrame("Button", nil, leftChild)
    introCard:SetHeight(CARD_H)
    introCard:SetPoint("TOPLEFT",  leftChild, "TOPLEFT",  CARD_PAD, yOffset)
    introCard:SetPoint("TOPRIGHT", leftChild, "TOPRIGHT", -CARD_PAD, yOffset)
    introCard:RegisterForClicks("AnyUp")

    local introBg = introCard:CreateTexture(nil, "BACKGROUND")
    introBg:SetAtlas("housefinder_neighborhood-list-item-default", false)
    introBg:SetAllPoints()

    introCard:SetHighlightAtlas("housefinder_neighborhood-list-item-highlight")
    introCard:GetHighlightTexture():SetAllPoints()

    local introPort = CreateFrame("Frame", nil, introCard)
    introPort:SetSize(PORT, PORT)
    introPort:SetPoint("LEFT", introCard, "LEFT", 16, 2)

    local introIcon = introPort:CreateTexture(nil, "ARTWORK")
    introIcon:SetSize(ICON, ICON)
    introIcon:SetPoint("CENTER")
    introIcon:SetAtlas("majorfactions_icons_flame512", false)

    local introIconMask = introPort:CreateMaskTexture()
    introIconMask:SetTexture(
        "Interface/CHARACTERFRAME/TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    introIconMask:SetAllPoints(introIcon)
    introIcon:AddMaskTexture(introIconMask)

    local introRing = introPort:CreateTexture(nil, "OVERLAY")
    introRing:SetAtlas("ui-frame-genericplayerchoice-portrait-border", false)
    introRing:SetPoint("TOPLEFT",     introIcon, "TOPLEFT",     -3,  3)
    introRing:SetPoint("BOTTOMRIGHT", introIcon, "BOTTOMRIGHT",  3, -3)
    introRing:SetVertexColor(1.0, 0.82, 0.5)
    introRing:SetAlpha(0.85)

    local introName = NoShadow(introCard:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
    introName:SetPoint("LEFT",  introPort, "RIGHT",  1,  0)
    introName:SetPoint("RIGHT", introCard, "RIGHT", -8,  0)
    introName:SetJustifyH("LEFT"); introName:SetJustifyV("MIDDLE")
    introName:SetText("Introduction")
    introName:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])

    local introZone = nil  -- no subline

    introCard:SetScript("OnClick", function() SelectStory(0) end)

    -- Store intro card for select styling
    storyLeftRows[0] = {
        btn       = introCard,
        bg        = introBg,
        portBorder= introRing,
        nameLabel = introName,
        zoneLabel = introZone,
    }

    yOffset = yOffset - CARD_H - 4

    -- ── Questline cards ──────────────────────────────────────────────────
    for _, cat in ipairs(categories) do
        local divH = CreateCatDivider(leftChild, cat.name, yOffset)
        yOffset = yOffset - divH - 4

        if not cat.disabled then
            for _, data in ipairs(cat.questlines) do
                globalIdx = globalIdx + 1
                local idx = globalIdx
                local cr, cg, cb = unpack(data.color or {0.5, 0.3, 0.9})

                -- ── Card frame ────────────────────────────────────────────────
                local card = CreateFrame("Button", nil, leftChild)
                card:SetHeight(CARD_H)
                card:SetPoint("TOPLEFT",  leftChild, "TOPLEFT",  CARD_PAD, yOffset)
                card:SetPoint("TOPRIGHT", leftChild, "TOPRIGHT", -CARD_PAD, yOffset)
                card:RegisterForClicks("AnyUp")

                -- House Finder card background
                local bg = card:CreateTexture(nil, "BACKGROUND")
                bg:SetAtlas("housefinder_neighborhood-list-item-default", false)
                bg:SetAllPoints()

                card:SetHighlightAtlas("housefinder_neighborhood-list-item-highlight")
                card:GetHighlightTexture():SetAllPoints()

                -- ── Portrait circle ───────────────────────────────────────────
                local portFrame = CreateFrame("Frame", nil, card)
                portFrame:SetSize(PORT, PORT)
                portFrame:SetPoint("LEFT", card, "LEFT", 16, 2)

                local iconTex = portFrame:CreateTexture(nil, "ARTWORK")
                iconTex:SetSize(ICON, ICON)
                iconTex:SetPoint("CENTER", portFrame, "CENTER", 0, 0)
                iconTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                iconTex:SetTexelSnappingBias(0)
                iconTex:SetSnapToPixelGrid(false)

                local iconMask = portFrame:CreateMaskTexture()
                iconMask:SetTexture(
                    "Interface/CHARACTERFRAME/TempPortraitAlphaMask",
                    "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                iconMask:SetAllPoints(iconTex)
                iconTex:AddMaskTexture(iconMask)

                if data.portraitDisplayID then
                    SetPortraitTextureFromCreatureDisplayID(iconTex, data.portraitDisplayID)
                elseif data.achievementID then
                    local _,_,_,_,_,_,_,_,_,achIcon = GetAchievementInfo(data.achievementID)
                    if achIcon and achIcon ~= 0 then iconTex:SetTexture(achIcon) end
                elseif data.icon then
                    iconTex:SetTexture(data.icon)
                end

                -- Gold circle border around the portrait
                local portBorder = portFrame:CreateTexture(nil, "OVERLAY")
                portBorder:SetAtlas("ui-frame-genericplayerchoice-portrait-border", false)
                portBorder:SetPoint("TOPLEFT",     iconTex, "TOPLEFT",     -3,  3)
                portBorder:SetPoint("BOTTOMRIGHT", iconTex, "BOTTOMRIGHT",  3, -3)
                portBorder:SetVertexColor(1.0, 0.82, 0.5)
                portBorder:SetAlpha(0.85)

                -- ── Text labels (vertically centred on card) ──────────────────
                local nameLabel = NoShadow(card:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
                nameLabel:SetPoint("LEFT",   portFrame, "RIGHT",  1,  0)
                nameLabel:SetPoint("RIGHT",  card,      "RIGHT", -8,  0)
                nameLabel:SetPoint("BOTTOM", card,      "CENTER", 0,  1)
                nameLabel:SetJustifyH("LEFT"); nameLabel:SetJustifyV("BOTTOM")
                nameLabel:SetMaxLines(1); nameLabel:SetWordWrap(false)
                nameLabel:SetText(data.title)
                nameLabel:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])

                local zoneLabel = NoShadow(card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
                zoneLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -2)
                zoneLabel:SetPoint("RIGHT",   card,      "RIGHT",     -8,  0)
                zoneLabel:SetJustifyH("LEFT")
                zoneLabel:SetText(data.zone or "")
                zoneLabel:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])

                -- ── Click ──────────────────────────────────────────────────────
                card:SetScript("OnClick", function() SelectStory(idx) end)

                storyLeftRows[idx] = {
                    btn       = card,
                    bg        = bg,
                    portBorder= portBorder,
                    nameLabel = nameLabel,
                    zoneLabel = zoneLabel,
                }
                yOffset = yOffset - CARD_H - 5
            end
        end
        yOffset = yOffset - 8
    end
    leftChild:SetHeight(math.abs(yOffset) + 16)
end

storyFrame:SetScript("OnShow", function()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    BuildStoryWindow()
    -- Frame 1: let layout settle so detailScroll has a real width
    C_Timer.After(0, function()
        local w = detailScroll:GetWidth()
        if w > 20 then detailChild:SetWidth(w) end
        -- Frame 2: now word-wrap can measure properly
        C_Timer.After(0, function()
            SelectStory(0)  -- default to Introduction card
        end)
    end)
end)

storyFrame:SetScript("OnHide", function()
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
end)


local ShowStoryBanner  -- forward declaration (defined in Banner section below)

SLASH_STORYMODE1 = "/sm"
SLASH_STORYMODE2 = "/storymode"
SlashCmdList["STORYMODE"] = function(msg)
    msg = msg and msg:trim():lower() or ""
    if msg == "banner" then
        local data = allQuestlines[1]
        if data then
            ShowStoryBanner("QUEST COMPLETE", data.title, data, nil, false)
        else
            print("|cff64b5f6StoryMode:|r No questline data to test banner.")
        end
        return
    elseif msg == "banner chapter" then
        local data = allQuestlines[1]
        if data then
            ShowStoryBanner("CHAPTER COMPLETE", data.title, data, nil, true)
        else
            print("|cff64b5f6StoryMode:|r No questline data to test banner.")
        end
        return
    elseif msg == "track" or msg == "next" then
        for _, data in ipairs(allQuestlines) do
            local quest, chapter = FindNextQuest(data)
            if quest then
                local result = SetWaypointForQuest(data, quest)
                local cr, cg, cb = unpack(data.color or { 1, 0.82, 0 })
                local hex = HexColor(cr, cg, cb)
                print("|cff64b5f6StoryMode:|r |cff" .. hex .. data.title .. " — " .. chapter .. "|r")
                PrintTrackResult(result, quest, data)
                return
            end
        end
        print("|cff64b5f6StoryMode:|r All questlines complete!")
    else
        if storyFrame:IsShown() then
            storyFrame:Hide()
        else
            storyFrame:Show()
        end
    end
end

-- ============================================================================
-- Minimap Button
-- ============================================================================

local minimapBtn = CreateFrame("Button", nil, Minimap)
minimapBtn:SetSize(42, 42)
minimapBtn:SetFrameStrata("MEDIUM")
minimapBtn:SetFrameLevel(9)

-- Soft shadow (multiple offset copies for fake blur)
for _, s in ipairs({{0.5, -0.5, 0.25}, {-0.5, -0.5, 0.15}, {0, -1, 0.3}, {1, 0, 0.15}}) do
    local sh = minimapBtn:CreateTexture(nil, "ARTWORK", nil, 1)
    sh:SetSize(38, 38)
    sh:SetPoint("CENTER", s[1], s[2])
    sh:SetAtlas("majorfactions_icons_flame512", false)
    sh:SetVertexColor(0, 0, 0)
    sh:SetAlpha(s[3])
end

-- Icon
local minimapIcon = minimapBtn:CreateTexture(nil, "ARTWORK", nil, 2)
minimapIcon:SetSize(36, 36)
minimapIcon:SetPoint("CENTER", 0, 2)
minimapIcon:SetAtlas("majorfactions_icons_flame512", false)

-- Circular mask
local minimapMask = minimapBtn:CreateMaskTexture()
minimapMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
    "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
minimapMask:SetAllPoints(minimapIcon)
minimapIcon:AddMaskTexture(minimapMask)


local function MinimapButton_UpdatePosition(angle)
    local r = (Minimap:GetWidth() / 2) + 8  -- sit on the edge
    local x = math.cos(angle) * r
    local y = math.sin(angle) * r
    minimapBtn:ClearAllPoints()
    minimapBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

minimapBtn:RegisterForDrag("LeftButton")
minimapBtn:SetScript("OnDragStart", function(self)
    self.dragging = true
    self:SetScript("OnUpdate", function(s)
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        cx, cy = cx / scale, cy / scale
        local angle = math.atan2(cy - my, cx - mx)
        MinimapButton_UpdatePosition(angle)
        StoryModeDB.minimapAngle = angle
    end)
end)
minimapBtn:SetScript("OnDragStop", function(self)
    self.dragging = false
    self:SetScript("OnUpdate", nil)
end)

minimapBtn:SetScript("OnClick", function()
    if storyFrame:IsShown() then
        storyFrame:Hide()
    else
        storyFrame:Show()
    end
end)

minimapBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("StoryMode", 1, 1, 1)
    GameTooltip:AddLine("Click to toggle", C_BODY[1], C_BODY[2], C_BODY[3])
    GameTooltip:Show()
end)
minimapBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Idle hide: invisible until cursor is near the minimap
minimapBtn:SetAlpha(0)
local mmFadeIn = minimapBtn:CreateAnimationGroup()
local mmFiAlpha = mmFadeIn:CreateAnimation("Alpha")
mmFiAlpha:SetFromAlpha(0); mmFiAlpha:SetToAlpha(1); mmFiAlpha:SetDuration(0.25); mmFiAlpha:SetSmoothing("OUT")
mmFadeIn:SetScript("OnFinished", function() minimapBtn:SetAlpha(1) end)

local mmFadeOut = minimapBtn:CreateAnimationGroup()
local mmFoAlpha = mmFadeOut:CreateAnimation("Alpha")
mmFoAlpha:SetFromAlpha(1); mmFoAlpha:SetToAlpha(0); mmFoAlpha:SetDuration(0.4); mmFoAlpha:SetSmoothing("IN")
mmFadeOut:SetScript("OnFinished", function() minimapBtn:SetAlpha(0) end)

local mmProximity = CreateFrame("Frame", nil, Minimap)
mmProximity:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -30, 30)
mmProximity:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 30, -30)
mmProximity.isNear = false
mmProximity:SetScript("OnUpdate", function(self, dt)
    local cx, cy = GetCursorPosition()
    local scale = self:GetEffectiveScale()
    cx, cy = cx / scale, cy / scale
    local l, b, w, h = self:GetRect()
    local inside = cx >= l and cx <= l + w and cy >= b and cy <= b + h
    if inside and not self.isNear then
        self.isNear = true
        if self.fadeTimer then self.fadeTimer:Cancel(); self.fadeTimer = nil end
        mmFadeOut:Stop()
        mmFadeIn:Play()
    elseif not inside and self.isNear then
        self.isNear = false
        mmFadeIn:Stop()
        if not self.fadeTimer then
            self.fadeTimer = C_Timer.NewTimer(1.0, function()
                mmProximity.fadeTimer = nil
                if not mmProximity.isNear then mmFadeOut:Play() end
            end)
        end
    end
end)

-- Position is loaded after ADDON_LOADED via StoryModeDB.minimapAngle
local function MinimapButton_Init()
    local angle = StoryModeDB and StoryModeDB.minimapAngle or 4.4  -- default: bottom
    MinimapButton_UpdatePosition(angle)
end

-- ============================================================================
-- Chapter / Quest Completion Alert  (minimal top-center text fade)
-- ============================================================================

local alertFrame = CreateFrame("Frame", nil, UIParent)
alertFrame:SetPoint("TOP", UIParent, "TOP", 0, -24)
alertFrame:SetSize(400, 60)
alertFrame:SetFrameStrata("FULLSCREEN_DIALOG")
alertFrame:Hide()

local alertHeader = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
alertHeader:SetPoint("BOTTOM", alertFrame, "CENTER", 0, 2)
alertHeader:SetJustifyH("CENTER")
alertHeader:SetTextColor(0.95, 0.85, 0.55)
alertHeader:SetShadowOffset(1, -1)

local alertTitle = alertFrame:CreateFontString(nil, "OVERLAY", "QuestFont_Huge")
alertTitle:SetPoint("TOP", alertFrame, "CENTER", 0, -2)
alertTitle:SetJustifyH("CENTER")
alertTitle:SetTextColor(1, 1, 1)
alertTitle:SetShadowOffset(1, -1)

local alertFadeIn = alertFrame:CreateAnimationGroup()
local alphaIn = alertFadeIn:CreateAnimation("Alpha")
alphaIn:SetFromAlpha(0)
alphaIn:SetToAlpha(1)
alphaIn:SetDuration(0.6)
alphaIn:SetSmoothing("OUT")
alertFadeIn:SetScript("OnFinished", function() alertFrame:SetAlpha(1) end)

local alertFadeOut = alertFrame:CreateAnimationGroup()
local alphaOut = alertFadeOut:CreateAnimation("Alpha")
alphaOut:SetFromAlpha(1)
alphaOut:SetToAlpha(0)
alphaOut:SetDuration(1.0)
alphaOut:SetSmoothing("IN")
alertFadeOut:SetScript("OnFinished", function() alertFrame:Hide(); alertFrame:SetAlpha(1) end)

ShowStoryBanner = function(headerText, titleText, questlineData, npcName, isChapter)
    alertHeader:SetText(string.upper(headerText))
    alertTitle:SetText(titleText)

    alertFadeOut:Stop()
    alertFadeIn:Stop()
    alertFrame:SetAlpha(0)
    alertFrame:Show()
    alertFadeIn:Play()

    local hold = isChapter and 4.0 or 3.0
    C_Timer.After(hold, function()
        if alertFrame:IsShown() then alertFadeOut:Play() end
    end)
end

-- ============================================================================
-- Quest Completion Tracking — detect chapter completion
-- ============================================================================

local chapterCompletionCache = {}  -- [questlineTitle..chapterName] = true if already fired

local function CheckQuestCompletion(completedQuestID)
    for _, data in ipairs(allQuestlines) do
        for _, ch in ipairs(GetAllChapters(data)) do
            local questName, questNpc
            for _, q in ipairs(ch.quests) do
                if q.id == completedQuestID then
                    questName = q.name
                    questNpc = q.npc
                    break
                end
            end
            if not questName then
                -- quest not in this chapter, skip
            else
                -- Check if entire chapter is now complete
                local done, total = GetChapterProgress(ch)
                local isChapterDone = done >= total and total > 0
                local key = (data.title or "") .. "|" .. (ch.chapter or "")

                if isChapterDone and not chapterCompletionCache[key] then
                    -- Chapter just completed — show chapter banner
                    chapterCompletionCache[key] = true
                    local chName = ch.chapter
                    local npc = questNpc
                    C_Timer.After(1.5, function()
                        ShowStoryBanner("CHAPTER COMPLETE", chName, data, npc, true)
                    end)
                else
                    -- Individual quest — show quest banner
                    local qName = questName
                    local npc = questNpc
                    local qData = data
                    C_Timer.After(1.0, function()
                        ShowStoryBanner("QUEST COMPLETE", qName, qData, npc, false)
                    end)
                end
                break
            end
        end
    end
end

-- ============================================================================
-- Initialization
-- ============================================================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("QUEST_TURNED_IN")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        StoryModeDB = StoryModeDB or CopyTable(defaults)
        MinimapButton_Init()
        -- Pre-populate cache so already-completed chapters don't re-fire
        for _, data in ipairs(allQuestlines) do
            for _, ch in ipairs(GetAllChapters(data)) do
                local d, t = GetChapterProgress(ch)
                if d >= t and t > 0 then
                    chapterCompletionCache[(data.title or "") .. "|" .. (ch.chapter or "")] = true
                end
            end
        end
    elseif event == "QUEST_TURNED_IN" then
        CheckQuestCompletion(arg1)
    end
end)

