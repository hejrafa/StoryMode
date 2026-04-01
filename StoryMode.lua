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

local function GetChapterProgress(ch)
    local total, done = 0, 0
    for _, q in ipairs(ch.quests) do
        total = total + 1
        if IsQuestComplete(q.id) then done = done + 1 end
    end
    return done, total
end

local function FindNextQuest(data)
    local chapters = GetAllChapters(data)

    -- Check if player has completed any prereq chapters (meaning they've progressed)
    local hasPrereqProgress = false
    if data.prereqs then
        for _, ch in ipairs(data.prereqs) do
            local d, t = GetChapterProgress(ch)
            if d > 0 then hasPrereqProgress = true; break end
        end
    end

    local logCandidates = {}    -- quests in the quest log
    local readyCandidates = {}  -- quests ready to pick up

    for chIdx, ch in ipairs(chapters) do
        local chDone, chTotal = GetChapterProgress(ch)
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
                elseif not IsQuestComplete(q.id) then
                    -- Skip stuck quests: if the quest AFTER this one is already
                    -- done, the player bypassed it (rep gate, resource gate, etc.)
                    local nextQuest = ch.quests[j + 1]
                    if nextQuest and IsQuestComplete(nextQuest.id) then
                        -- Stuck/bypassed — keep scanning this chapter
                    elseif j == 1 then
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
                    elseif IsQuestComplete(ch.quests[j - 1].id) then
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

local function SetWaypointForQuest(data, quest)
    if not quest then return "no_location" end

    if IsQuestInLog(quest.id) then
        C_QuestLog.AddQuestWatch(quest.id)
        C_SuperTrack.SetSuperTrackedQuestID(quest.id)
        return "supertracked"
    end

    if Enum.SuperTrackingMapPinType and Enum.SuperTrackingMapPinType.QuestOffer then
        C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.QuestOffer, quest.id)
        return "map_pin"
    end

    local loc = data.npcLocations and data.npcLocations[quest.npc]
    if loc and C_Map.CanSetUserWaypointOnMap(loc.mapID) then
        local point = UiMapPoint.CreateFromCoordinates(loc.mapID, loc.x, loc.y)
        C_Map.SetUserWaypoint(point)
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        return "waypoint"
    end

    return "no_location"
end

local function PrintTrackResult(result, quest, data)
    local P = "|cff64b5f6StoryMode:|r "
    if result == "supertracked" then
        print(P .. "Tracking: " .. quest.name)
    elseif result == "map_pin" then
        print(P .. "Tracking quest: |cffffd200" .. quest.name .. "|r — follow the navigation arrow.")
    elseif result == "waypoint" then
        print(P .. "Waypoint set for |cffffd200" .. quest.npc .. "|r — open your map to see it.")
    else
        print(P .. "Next: " .. quest.name .. " from |cffffd200" .. quest.npc .. "|r")
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
    f:SetFrameLevel(section:GetFrameLevel())   -- keep behind child content
    NineSliceUtil.ApplyLayout(f, PERKS_LAYOUT)
    -- Tint border pieces to gold-bronze (matching companion card border)
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

-- ─── Major divider (Trading Post style: center-out fade) ───────────────────
local function CreateMajorDivider(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(12)
    -- Left half: transparent → bright at center
    local left = f:CreateTexture(nil, "OVERLAY")
    left:SetTexture(SOLID)
    left:SetHeight(1)
    left:SetPoint("LEFT",  f, "LEFT",   0, 0)
    left:SetPoint("RIGHT", f, "CENTER", 0, 0)
    left:SetGradient("HORIZONTAL",
        CreateColor(1.0, 0.80, 0.45, 0),
        CreateColor(1.0, 0.80, 0.45, 0.6))
    -- Right half: bright at center → transparent
    local right = f:CreateTexture(nil, "OVERLAY")
    right:SetTexture(SOLID)
    right:SetHeight(1)
    right:SetPoint("LEFT",  f, "CENTER", 0, 0)
    right:SetPoint("RIGHT", f, "RIGHT",  0, 0)
    right:SetGradient("HORIZONTAL",
        CreateColor(1.0, 0.80, 0.45, 0.6),
        CreateColor(1.0, 0.80, 0.45, 0))
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
headerDiv:SetPoint("LEFT",  rightHeader, "BOTTOMLEFT",  32, 0)
headerDiv:SetPoint("RIGHT", rightHeader, "BOTTOMRIGHT", -32, 0)

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
    "A story companion for World of Warcraft. "
    .."Step-by-step quest guidance like RestedXP, "
    .."built for narrative instead of speed \194\183 "
    .."paired with the immersive presentation of Dialogue UI."
    .."\n\nEvery campaign is laid out chapter by chapter, "
    .."quest by quest. Key characters, story context, "
    .."and your progress in one place \194\183 "
    .."no wiki tabs, no spoilers, no guesswork."
    .."\n\nPick a story on the left to get started.")

-- ══════════════════════════════════════════════════════════════════════════════
-- Detail view — circular portrait hero + structured sections with dividers
-- ══════════════════════════════════════════════════════════════════════════════

local HERO_ICON = 64

-- ── Hero: circular portrait + title + subtitle (shared across tabs) ─────────
local heroFrame = CreateFrame("Frame", nil, detailChild)
heroFrame:SetPoint("TOPLEFT",  detailChild, "TOPLEFT",  CP, -20)
heroFrame:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", -CP, 0)
heroFrame:SetHeight(HERO_ICON + 8)

local heroPort = CreateFrame("Frame", nil, heroFrame)
heroPort:SetSize(HERO_ICON, HERO_ICON)
heroPort:SetPoint("LEFT", heroFrame, "LEFT", 0, 0)

local heroIcon = heroPort:CreateTexture(nil, "ARTWORK")
heroIcon:SetSize(HERO_ICON - 8, HERO_ICON - 8)
heroIcon:SetPoint("CENTER")
heroIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

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

-- Title + subtitle vertically centered against portrait
local heroTextAnchor = CreateFrame("Frame", nil, heroFrame)
heroTextAnchor:SetPoint("LEFT",  heroPort, "RIGHT", 14, 0)
heroTextAnchor:SetPoint("RIGHT", heroFrame, "RIGHT", 0,  0)
heroTextAnchor:SetPoint("TOP",   heroPort,  "TOP",   0,  0)
heroTextAnchor:SetPoint("BOTTOM",heroPort,  "BOTTOM",0,  0)

local dTitle = NoShadow(heroTextAnchor:CreateFontString(nil, "OVERLAY", "QuestFont_Huge"))
dTitle:SetPoint("LEFT",  heroTextAnchor, "LEFT",   0, 0)
dTitle:SetPoint("RIGHT", heroTextAnchor, "RIGHT",  0, 0)
dTitle:SetPoint("BOTTOM",heroTextAnchor, "CENTER", 0, 1)
dTitle:SetJustifyH("LEFT"); dTitle:SetJustifyV("BOTTOM"); dTitle:SetWordWrap(false)
dTitle:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])

local dSub = NoShadow(heroTextAnchor:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"))
dSub:SetPoint("TOPLEFT", dTitle, "BOTTOMLEFT", 0, -2)
dSub:SetJustifyH("LEFT")
dSub:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])

-- ════════════════════════════════════════════════════════════════════════════
-- STORY TAB elements
-- ════════════════════════════════════════════════════════════════════════════

local sDiv1 = CreateMajorDivider(detailChild)

-- Story intro paragraph
local sIntro = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
sIntro:SetJustifyH("LEFT"); sIntro:SetSpacing(4); sIntro:SetWordWrap(true)
sIntro:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])

local sDiv2 = CreateMajorDivider(detailChild)

-- "At a Glance" line (expansion · zone · N chapters)
local sGlanceLabel = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
sGlanceLabel:SetJustifyH("LEFT")
sGlanceLabel:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])

local sDiv3 = CreateMajorDivider(detailChild)

-- Key Characters header + entries
local sCharHeader = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
sCharHeader:SetJustifyH("LEFT")
sCharHeader:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])
sCharHeader:SetText("Key Characters")

local sCharText = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
sCharText:SetJustifyH("LEFT"); sCharText:SetSpacing(4); sCharText:SetWordWrap(true)
sCharText:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])

local sDiv4 = CreateMajorDivider(detailChild)

-- CTA button on story tab
local sTrackBtn = CreateFrame("Button", nil, detailChild, "UIPanelButtonTemplate")
sTrackBtn:SetSize(260, 40)
sTrackBtn:SetText("Begin This Story")

local sCompleteText = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
sCompleteText:SetTextColor(0.40, 0.82, 0.35)
sCompleteText:SetText("|A:common-icon-checkmark:0:0|a Campaign Complete")

local storyElements = { sDiv1, sIntro, sDiv2, sGlanceLabel, sDiv3, sCharHeader, sCharText, sDiv4, sTrackBtn, sCompleteText }

-- ════════════════════════════════════════════════════════════════════════════
-- PROGRESS TAB elements
-- ════════════════════════════════════════════════════════════════════════════

local pDiv1 = CreateMajorDivider(detailChild)

local dProgLine = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
dProgLine:SetJustifyH("CENTER")
dProgLine:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])

local dCompleteText = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
dCompleteText:SetTextColor(0.40, 0.82, 0.35)
dCompleteText:SetText("|A:common-icon-checkmark:0:0|a Campaign Complete")

local pDiv2 = CreateMajorDivider(detailChild)

local chapHeader = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
chapHeader:SetJustifyH("CENTER")
chapHeader:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])
chapHeader:SetText("Chapters")

-- Chapter rows as interactive line items with hover + tooltip
local dChapterRows = {}   -- array of Button frames
local CH_ROW_H = 28
local CH_GAP   = 2
local CH_PORT  = 22       -- portrait circle size
local CH_LIST_W = 340     -- fixed width for chapter list (centered in panel)

-- Set a 2D NPC portrait from a pre-stored creature display ID
local function SetChapterPortrait(portraitTex, displayID)
    if displayID then
        SetPortraitTextureFromCreatureDisplayID(portraitTex, displayID)
    else
        portraitTex:SetTexture(nil)
    end
end

local function CreateChapterRow(parent, index)
    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetHeight(CH_ROW_H)

    -- Rounded hover background via tooltip backdrop
    row:SetBackdrop({
        bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 8,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    row:SetBackdropColor(1, 1, 1, 0)
    row:SetBackdropBorderColor(1, 1, 1, 0)

    -- Portrait container
    local portFrame = CreateFrame("Frame", nil, row)
    portFrame:SetSize(CH_PORT, CH_PORT)
    portFrame:SetPoint("LEFT", row, "LEFT", 6, 0)

    -- NPC portrait texture (ARTWORK layer — behind OVERLAY ring)
    local portrait = portFrame:CreateTexture(nil, "ARTWORK")
    portrait:SetSize(CH_PORT - 2, CH_PORT - 2)
    portrait:SetPoint("CENTER")
    portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)

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

    -- Chapter title label (left-aligned, after portrait)
    local label = NoShadow(row:CreateFontString(nil, "ARTWORK", "GameFontNormal"))
    label:SetPoint("LEFT", portFrame, "RIGHT", 8, 0)
    label:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    label:SetJustifyH("LEFT"); label:SetWordWrap(false)
    row.label = label

    -- Hover / tooltip
    row:SetScript("OnEnter", function(self)
        self:SetBackdropColor(1, 1, 1, 0.07)
        self:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.06)
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
        self:SetBackdropColor(1, 1, 1, 0)
        self:SetBackdropBorderColor(1, 1, 1, 0)
        GameTooltip:Hide()
    end)

    return row
end

local progressElements = { pDiv1, dProgLine, dCompleteText, pDiv2, chapHeader }

local function ShowDetail(show)
    heroFrame[show and "Show" or "Hide"](heroFrame)
end

local function ShowTab(tab)
    -- Hide all tab-specific elements
    for _, el in ipairs(storyElements) do el:Hide() end
    for _, el in ipairs(progressElements) do el:Hide() end
    for _, row in ipairs(dChapterRows) do row:Hide() end
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
local currentStoryData = nil   -- cached for tab switching

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
        -- Simple top-down chain. Each element anchors TOPLEFT to BOTTOMLEFT
        -- of the previous. Dividers use DP offset, content uses CP offset.

        local cpOff = CP - DP  -- from divider left to content left

        -- sDiv1 below hero
        sDiv1:ClearAllPoints()
        sDiv1:SetPoint("TOPLEFT", heroFrame, "BOTTOMLEFT", DP - CP, -10)
        sDiv1:SetWidth(divW)

        -- Story intro
        sIntro:ClearAllPoints()
        sIntro:SetPoint("TOPLEFT", sDiv1, "BOTTOMLEFT", cpOff, -14)
        if contentW > 20 then sIntro:SetWidth(contentW) end

        -- sDiv2 below intro
        sDiv2:ClearAllPoints()
        sDiv2:SetPoint("TOPLEFT", sIntro, "BOTTOMLEFT", -cpOff, -14)
        sDiv2:SetWidth(divW)

        -- At a Glance line
        local chapters = GetAllChapters(data)
        local glanceParts = {}
        if data.expansion then table.insert(glanceParts, data.expansion) end
        if data.zone then table.insert(glanceParts, data.zone) end
        table.insert(glanceParts, #chapters .. " chapters")
        sGlanceLabel:SetText(table.concat(glanceParts, "  \194\183  "))
        sGlanceLabel:ClearAllPoints()
        sGlanceLabel:SetPoint("TOPLEFT", sDiv2, "BOTTOMLEFT", cpOff, -12)

        -- sDiv3 below at-a-glance
        sDiv3:ClearAllPoints()
        sDiv3:SetPoint("TOPLEFT", sGlanceLabel, "BOTTOMLEFT", -cpOff, -12)
        sDiv3:SetWidth(divW)

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

        local lastAnchor = sDiv3
        local lastIsDiv = true
        if #npcNames > 0 then
            sCharHeader:ClearAllPoints()
            sCharHeader:SetPoint("TOPLEFT", sDiv3, "BOTTOMLEFT", cpOff, -12)
            sCharHeader:Show()

            sCharText:ClearAllPoints()
            sCharText:SetPoint("TOPLEFT", sCharHeader, "BOTTOMLEFT", 0, -6)
            if contentW > 20 then sCharText:SetWidth(contentW) end
            sCharText:SetText(table.concat(npcNames, "  \194\183  "))
            sCharText:Show()

            sDiv4:ClearAllPoints()
            sDiv4:SetPoint("TOPLEFT", sCharText, "BOTTOMLEFT", -cpOff, -14)
            sDiv4:SetWidth(divW)
            sDiv4:Show()
            lastAnchor = sDiv4
            lastIsDiv = true
        else
            sCharHeader:Hide(); sCharText:Hide(); sDiv4:Hide()
        end

        -- CTA button
        local quest = FindNextQuest(data)
        local done = select(1, GetCampaignProgress(data))
        if quest then
            sTrackBtn:SetText(done > 0 and "Continue Story" or "Begin This Story")
            sTrackBtn:ClearAllPoints()
            sTrackBtn:SetPoint("TOP", lastAnchor, "BOTTOM", 0, -18)
            sTrackBtn:SetScript("OnClick", function()
                local result = SetWaypointForQuest(data, quest)
                PrintTrackResult(result, quest, data)
            end)
            sTrackBtn:Show(); sCompleteText:Hide()
        else
            sCompleteText:ClearAllPoints()
            sCompleteText:SetPoint("TOP", lastAnchor, "BOTTOM", 0, -18)
            sCompleteText:Show(); sTrackBtn:Hide()
        end

        local storyBottomEl = quest and sTrackBtn or sCompleteText
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
        local done, total = GetCampaignProgress(data)
        local chapters = GetAllChapters(data)
        local chapDone = 0
        for _, ch in ipairs(chapters) do
            local cd, ct = GetChapterProgress(ch)
            if cd == ct and ct > 0 then chapDone = chapDone + 1 end
        end
        dProgLine:SetText("Chapter " .. chapDone .. " of " .. #chapters
            .. "  \194\183  " .. done .. "/" .. total .. " quests")

        -- CTA
        local quest = FindNextQuest(data)
        if not quest then
            dCompleteText:Show()
        else
            dCompleteText:Hide()
        end

        -- Chapter rows (single-column list with hover + tooltip)
        for _, row in ipairs(dChapterRows) do row:Hide() end
        for i, ch in ipairs(chapters) do
            if not dChapterRows[i] then
                dChapterRows[i] = CreateChapterRow(detailChild, i)
            end
            local row = dChapterRows[i]
            local cDone, cTotal = GetChapterProgress(ch)

            if cDone == cTotal and cTotal > 0 then
                row.label:SetText("|A:common-icon-checkmark:0:0|a " .. ch.chapter)
                row.label:SetTextColor(0.35, 0.78, 0.28)
            elseif cDone > 0 then
                row.label:SetText(ch.chapter)
                row.label:SetTextColor(1, 1, 1)
            else
                row.label:SetText(ch.chapter)
                row.label:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])
            end

            -- Set NPC portrait from first quest's quest giver
            local npcName = ch.quests and ch.quests[1] and ch.quests[1].npc
            local displayID = npcName and data.npcDisplayIDs
                and data.npcDisplayIDs[npcName]
            SetChapterPortrait(row.portrait, displayID)

            row.tooltipTitle = ch.chapter
            row.tooltipBody = ch.summary or nil
            row.tooltipProgress = cDone .. " / " .. cTotal .. " quests"

            row:Show()
        end
        for i = #chapters + 1, #dChapterRows do dChapterRows[i]:Hide() end

        local cpOff = CP - DP

        -- Layout progress elements top-to-bottom
        pDiv1:ClearAllPoints()
        pDiv1:SetPoint("TOPLEFT", heroFrame, "BOTTOMLEFT", DP - CP, -10)
        pDiv1:SetWidth(divW)

        dProgLine:ClearAllPoints()
        dProgLine:SetPoint("TOP", pDiv1, "BOTTOM", 0, -14)

        local ctaAnchor
        if not quest then
            dCompleteText:ClearAllPoints()
            dCompleteText:SetPoint("TOP", dProgLine, "BOTTOM", 0, -16)
            ctaAnchor = dCompleteText
        else
            ctaAnchor = dProgLine
        end

        pDiv2:ClearAllPoints()
        pDiv2:SetPoint("TOP", ctaAnchor, "BOTTOM", 0, -16)
        pDiv2:SetWidth(divW)

        chapHeader:ClearAllPoints()
        chapHeader:SetPoint("TOP", pDiv2, "BOTTOM", 0, -10)

        -- Layout chapter rows single-column below header (fixed width, centered)
        for i = 1, #chapters do
            local row = dChapterRows[i]
            row:ClearAllPoints()
            if i == 1 then
                row:SetPoint("TOP", chapHeader, "BOTTOM", 0, -8)
            else
                row:SetPoint("TOP", dChapterRows[i-1], "BOTTOM", 0, -CH_GAP)
            end
            row:SetWidth(CH_LIST_W)
            row:SetPoint("LEFT", detailChild, "LEFT",
                math.floor((detailChild:GetWidth() - CH_LIST_W) / 2), 0)
        end

        -- Set scroll height
        local lastRow = dChapterRows[#chapters]
        C_Timer.After(0, function()
            local bot = lastRow and lastRow:GetBottom() or nil
            local top = detailChild:GetTop()
            if bot and top then
                detailChild:SetHeight(math.max(top - bot + 30, 400))
            else
                detailChild:SetHeight(500)
            end
        end)
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
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
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
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
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
        for _, el in ipairs(progressElements) do el:Hide() end
        for _, row in ipairs(dChapterRows) do row:Hide() end
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

    -- Portrait icon
    local iconID
    if data.achievementID then
        local _,_,_,_,_,_,_,_,_,achIcon = GetAchievementInfo(data.achievementID)
        if achIcon and achIcon ~= 0 then iconID = achIcon end
    end
    iconID = iconID or data.icon
    if iconID and iconID ~= 0 then heroIcon:SetTexture(iconID) else heroIcon:SetTexture(nil) end

    local displayTitle = data.title
    if data.achievementID then
        local _, achName = GetAchievementInfo(data.achievementID)
        if achName then displayTitle = achName end
    end

    smHeaderSub:SetText("")
    dTitle:SetText(displayTitle)
    dSub:SetText((data.expansion or "") .. "  \194\183  " .. (data.zone or ""))
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
    storySelectedIdx = index
    for i, row in pairs(storyLeftRows) do
        local sel = (i == index)
        row.bg:SetAtlas("ui-journeys-delve-companion-button", false)
        row.bg:SetAlpha(sel and 1.0 or 0.80)
        if row.cr then row.bg:SetVertexColor(row.cr*0.35+0.65, row.cg*0.35+0.65, row.cb*0.35+0.65) end
        row.portBorder:SetAlpha(sel and 1.0 or 0.75)
        -- text brightness
        local tb = sel and 1.0 or 0.80
        row.nameLabel:SetTextColor(C_BODY[1]*tb, C_BODY[2]*tb, C_BODY[3]*tb)
        row.zoneLabel:SetTextColor(C_DIM[1]*tb,  C_DIM[2]*tb,  C_DIM[3]*tb)
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

    local introCard = CreateFrame("Frame", nil, leftChild)
    introCard:EnableMouse(true); introCard:SetHeight(CARD_H)
    introCard:SetPoint("TOPLEFT",  leftChild, "TOPLEFT",  CARD_PAD, yOffset)
    introCard:SetPoint("TOPRIGHT", leftChild, "TOPRIGHT", -CARD_PAD, yOffset)

    local introBg = introCard:CreateTexture(nil, "BACKGROUND")
    introBg:SetAtlas("ui-journeys-delve-companion-button", false)
    introBg:SetAllPoints()
    introBg:SetVertexColor(0.75, 0.70, 0.65)
    introBg:SetAlpha(0.80)

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
    introName:SetPoint("LEFT",   introPort, "RIGHT",  1,  0)
    introName:SetPoint("RIGHT",  introCard, "RIGHT", -8,  0)
    introName:SetPoint("BOTTOM", introCard, "CENTER", 0,  1)
    introName:SetJustifyH("LEFT"); introName:SetJustifyV("BOTTOM")
    introName:SetText("Introduction")
    introName:SetTextColor(C_BODY[1]*0.80, C_BODY[2]*0.80, C_BODY[3]*0.80)

    local introZone = NoShadow(introCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
    introZone:SetPoint("TOPLEFT", introName, "BOTTOMLEFT", 0, -2)
    introZone:SetPoint("RIGHT",   introCard, "RIGHT",     -8,  0)
    introZone:SetJustifyH("LEFT")
    introZone:SetText("What is Story Mode?")
    introZone:SetTextColor(C_DIM[1]*0.80, C_DIM[2]*0.80, C_DIM[3]*0.80)

    introCard:SetScript("OnEnter", function()
        if storySelectedIdx ~= 0 then
            introBg:SetAlpha(1.0)
            introBg:SetVertexColor(1, 1, 1)
            introName:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
            introZone:SetTextColor(C_DIM[1],  C_DIM[2],  C_DIM[3])
        end
    end)
    introCard:SetScript("OnLeave", function()
        if storySelectedIdx ~= 0 then
            introBg:SetAlpha(0.80)
            introBg:SetVertexColor(0.75, 0.70, 0.65)
            introName:SetTextColor(C_BODY[1]*0.80, C_BODY[2]*0.80, C_BODY[3]*0.80)
            introZone:SetTextColor(C_DIM[1]*0.80,  C_DIM[2]*0.80,  C_DIM[3]*0.80)
        end
    end)
    introCard:SetScript("OnMouseUp", function() SelectStory(0) end)

    -- Store intro card for select styling
    storyLeftRows[0] = {
        bg        = introBg,
        portBorder= introRing,
        nameLabel = introName,
        zoneLabel = introZone,
        cr=0.75, cg=0.70, cb=0.65,
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
                local card = CreateFrame("Frame", nil, leftChild)
                card:EnableMouse(true); card:SetHeight(CARD_H)
                card:SetPoint("TOPLEFT",  leftChild, "TOPLEFT",  CARD_PAD, yOffset)
                card:SetPoint("TOPRIGHT", leftChild, "TOPRIGHT", -CARD_PAD, yOffset)

                -- Journeys delve card background, tinted with questline colour
                local bg = card:CreateTexture(nil, "BACKGROUND")
                bg:SetAtlas("ui-journeys-delve-companion-button", false)
                bg:SetAllPoints()
                bg:SetVertexColor(cr*0.35 + 0.65, cg*0.35 + 0.65, cb*0.35 + 0.65)
                bg:SetAlpha(0.80)

                -- ── Portrait circle (Delve companion card style) ──────────────
                local portFrame = CreateFrame("Frame", nil, card)
                portFrame:SetSize(PORT, PORT)
                portFrame:SetPoint("LEFT", card, "LEFT", 16, 2)

                -- Circular-masked achievement icon
                local iconTex = portFrame:CreateTexture(nil, "ARTWORK")
                iconTex:SetSize(ICON, ICON)
                iconTex:SetPoint("CENTER", portFrame, "CENTER", 0, 0)
                iconTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

                local iconMask = portFrame:CreateMaskTexture()
                iconMask:SetTexture(
                    "Interface/CHARACTERFRAME/TempPortraitAlphaMask",
                    "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                iconMask:SetAllPoints(iconTex)
                iconTex:AddMaskTexture(iconMask)

                if data.achievementID then
                    local _,_,_,_,_,_,_,_,_,achIcon = GetAchievementInfo(data.achievementID)
                    if achIcon and achIcon ~= 0 then iconTex:SetTexture(achIcon) end
                elseif data.icon then
                    iconTex:SetTexture(data.icon)
                end

                -- Gold circle border around the portrait (tinted gold, thin)
                local portBorder = portFrame:CreateTexture(nil, "OVERLAY")
                portBorder:SetAtlas("ui-frame-genericplayerchoice-portrait-border", false)
                portBorder:SetPoint("TOPLEFT",     iconTex, "TOPLEFT",     -3,  3)
                portBorder:SetPoint("BOTTOMRIGHT", iconTex, "BOTTOMRIGHT",  3, -3)
                portBorder:SetVertexColor(1.0, 0.82, 0.5)
                portBorder:SetAlpha(0.85)

                -- ── Text labels (vertically centred on card) ──────────────────
                -- Anchor group: name sits just above card center, zone just below
                local nameLabel = NoShadow(card:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
                nameLabel:SetPoint("LEFT",   portFrame, "RIGHT",  1,  0)
                nameLabel:SetPoint("RIGHT",  card,      "RIGHT", -8,  0)
                nameLabel:SetPoint("BOTTOM", card,      "CENTER", 0,  1)
                nameLabel:SetJustifyH("LEFT"); nameLabel:SetJustifyV("BOTTOM")
                nameLabel:SetMaxLines(1); nameLabel:SetWordWrap(false)
                nameLabel:SetText(data.title)
                nameLabel:SetTextColor(C_BODY[1]*0.80, C_BODY[2]*0.80, C_BODY[3]*0.80)

                local zoneLabel = NoShadow(card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
                zoneLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -2)
                zoneLabel:SetPoint("RIGHT",   card,      "RIGHT",     -8,  0)
                zoneLabel:SetJustifyH("LEFT")
                zoneLabel:SetText(data.zone or "")
                zoneLabel:SetTextColor(C_DIM[1]*0.80, C_DIM[2]*0.80, C_DIM[3]*0.80)

                -- ── Hover / select scripts ─────────────────────────────────────
                card:SetScript("OnEnter", function()
                    if idx ~= storySelectedIdx then
                        bg:SetAlpha(1.0)
                        bg:SetVertexColor(1, 1, 1)
                        portBorder:SetAlpha(1.0)
                        nameLabel:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
                        zoneLabel:SetTextColor(C_DIM[1],  C_DIM[2],  C_DIM[3])
                    end
                end)
                card:SetScript("OnLeave", function()
                    if idx ~= storySelectedIdx then
                        bg:SetAlpha(0.80)
                        bg:SetVertexColor(cr*0.35 + 0.65, cg*0.35 + 0.65, cb*0.35 + 0.65)
                        portBorder:SetAlpha(0.55)
                        nameLabel:SetTextColor(C_BODY[1]*0.80, C_BODY[2]*0.80, C_BODY[3]*0.80)
                        zoneLabel:SetTextColor(C_DIM[1]*0.80,  C_DIM[2]*0.80,  C_DIM[3]*0.80)
                    end
                end)
                card:SetScript("OnMouseUp", function() SelectStory(idx) end)

                storyLeftRows[idx] = {
                    bg        = bg,
                    portBorder= portBorder,
                    nameLabel = nameLabel,
                    zoneLabel = zoneLabel,
                    cr=cr, cg=cg, cb=cb,
                }
                yOffset = yOffset - CARD_H - 5
            end
        end
        yOffset = yOffset - 8
    end
    leftChild:SetHeight(math.abs(yOffset) + 16)
end

storyFrame:SetScript("OnShow", function()
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


SLASH_STORYMODE1 = "/sm"
SLASH_STORYMODE2 = "/storymode"
SlashCmdList["STORYMODE"] = function(msg)
    msg = msg and msg:trim():lower() or ""
    if msg == "track" or msg == "next" then
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
-- Initialization
-- ============================================================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon == addonName then
        StoryModeDB = StoryModeDB or CopyTable(defaults)
    end
end)

