local addonName, SM = ...

-- ============================================================================
-- Saved Variables
-- ============================================================================

local defaults = {
    version = "1.3.0",
    selectedQuestline = 1,
    viewedLoreChapters = {},
}

-- Forward-declared here so GetChapterProgress (below) can access it as an upvalue.
local currentStoryData = nil  -- assigned by UpdateStoryDetail

local function IsLoreChapterViewed(storylineTitle, chapterName)
    if not StoryModeDB or not StoryModeDB.viewedLoreChapters then return false end
    return StoryModeDB.viewedLoreChapters[storylineTitle .. "|" .. chapterName] == true
end

local function SetLoreChapterViewed(storylineTitle, chapterName)
    if not StoryModeDB then return end
    if not StoryModeDB.viewedLoreChapters then StoryModeDB.viewedLoreChapters = {} end
    StoryModeDB.viewedLoreChapters[storylineTitle .. "|" .. chapterName] = true
end

local function IsChapterPlayed(storylineTitle, chapterName)
    if not StoryModeDB or not StoryModeDB.playedChapters then return false end
    return StoryModeDB.playedChapters[storylineTitle .. "|" .. chapterName] == true
end

local function SetChapterPlayed(storylineTitle, chapterName)
    if not StoryModeDB then return end
    if not StoryModeDB.playedChapters then StoryModeDB.playedChapters = {} end
    StoryModeDB.playedChapters[storylineTitle .. "|" .. chapterName] = true
end

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
-- Note: we intentionally do NOT infer completion from next-chapter progress.
-- Some campaigns have optional/out-of-order chapters, which can cause false
-- "Completed" states for an active final quest in the current chapter.
local playerFaction = UnitFactionGroup("player")

local function IsQuestForPlayer(q)
    return not q.faction or q.faction == playerFaction
end

local function ShouldHideQuest(q)
    if q.showIf then
        if not IsQuestComplete(q.showIf) then return true end
    elseif q.hideIf then
        local ids = type(q.hideIf) == "table" and q.hideIf or { q.hideIf }
        for _, hid in ipairs(ids) do
            if IsQuestComplete(hid) then return true end
        end
    end
    return false
end

local function IsQuestEffectivelyComplete(questIndex, chapterQuests, nextChapterQuests)
    local q = chapterQuests[questIndex]
    -- Quests for the opposing faction are irrelevant — treat as complete.
    if not IsQuestForPlayer(q) then return true end
    local qid = q.id
    -- IsOnQuest can be unreliable for some campaign steps; log index is safer.
    if C_QuestLog.GetLogIndexForQuestID(qid) ~= nil then return false end
    if IsQuestComplete(qid) then return true end
    -- Before inferring completion from a later done quest, check that no
    -- earlier quest in the chain is still in progress. If the player is
    -- actively working through step N, quests after N can't be inferred done
    -- from a later flag — that flag is from a previous run or another character.
    for i = 1, questIndex - 1 do
        if IsQuestForPlayer(chapterQuests[i]) and C_QuestLog.GetLogIndexForQuestID(chapterQuests[i].id) ~= nil then
            return false
        end
    end
    for i = questIndex + 1, #chapterQuests do
        if IsQuestForPlayer(chapterQuests[i]) and IsQuestComplete(chapterQuests[i].id) then return true end
    end
    -- Keep completion strictly local to this quest/chapter to avoid
    -- out-of-order chapter progress causing false positives.
    return false
end

local function IsQuestInLog(questID)
    return C_QuestLog.GetLogIndexForQuestID(questID) ~= nil
end

local function GetAllChapters(data)
    local all = {}
    local playerFaction = UnitFactionGroup("player")

    local function ShouldShowChapter(ch)
        if not ch.faction then return true end
        return ch.faction == playerFaction
    end

    if data.prereqs then
        for _, ch in ipairs(data.prereqs) do
            if ShouldShowChapter(ch) then
                ch._section = 1  -- prereqs (lowest priority)
                all[#all + 1] = ch
            end
        end
    end
    if data.chapters then
        for _, ch in ipairs(data.chapters) do
            if ShouldShowChapter(ch) then
                ch._section = 2  -- main story
                all[#all + 1] = ch
            end
        end
    end
    if data.insurrection then
        for _, ch in ipairs(data.insurrection) do
            if ShouldShowChapter(ch) then
                ch._section = 3  -- finale (highest priority)
                all[#all + 1] = ch
            end
        end
    end
    if #all == 0 and data.startQuest then
        all[#all + 1] = {
            chapter = data.title,
            summary = data.description,
            recap = data.description,
            quests = { data.startQuest },
            _section = 2,
        }
    end
    return all
end

local function GetStoryAchievements(data)
    local ids, seen = {}, {}
    local function add(id)
        if id and not seen[id] then
            seen[id] = true
            local _, name = GetAchievementInfo(id)
            if name then ids[#ids + 1] = id end
        end
    end
    if data.achievements then
        for _, id in ipairs(data.achievements) do add(id) end
    else
        add(data.achievementID)
    end
    for _, ch in ipairs(GetAllChapters(data)) do
        add(ch.achievementID)
    end
    return ids
end

local achievementElements = {}
local aAchCards     = {}
local aAchDividers  = {}

local function IsQuestlineActive(data)
    for _, ch in ipairs(GetAllChapters(data)) do
        for _, q in ipairs(ch.quests) do
            if IsQuestInLog(q.id) then return true end
        end
    end
    return false
end

local FindNextQuest

local function GetCampaignProgress(data)
    local total, done = 0, 0
    for _, ch in ipairs(GetAllChapters(data)) do
        for _, q in ipairs(ch.quests) do
            total = total + 1
            if IsQuestComplete(q.id) then done = done + 1 end
        end
    end
    -- Keep progress text consistent with "Story Finished" state.
    -- Some campaigns have variant/legacy quest IDs that may never flag on
    -- the character despite the chain being fully complete.
    local nextQuest = FindNextQuest(data)
    if not nextQuest and total > 0 then
        done = total
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
    -- loreOnly chapters: complete only when the player has explicitly marked them viewed.
    -- Unviewed (0,0) makes them the "current" chapter in the track; viewed (1,1) advances past them.
    if ch.loreOnly then
        if currentStoryData and IsLoreChapterViewed(currentStoryData.title, ch.chapter) then
            return 1, 1
        end
        return 0, 0
    end
    if ch.replayable and currentStoryData and IsChapterPlayed(currentStoryData.title, ch.chapter) then
        return 1, 1
    end
    -- Achievement override: if the chapter names an achievementID and it is earned,
    -- treat the chapter as fully complete regardless of quest flags. This handles
    -- chapters like raid encounters or Archivist Sylvia replays that don't re-flag quests.
    if ch.achievementID then
        local _, _, _, completed = GetAchievementInfo(ch.achievementID)
        if completed then return 1, 1 end
    end
    local total, done = 0, 0
    local nextQuests = nextChapter and nextChapter.quests or nil
    for i, q in ipairs(ch.quests) do
        if not q.optional and IsQuestForPlayer(q) and not ShouldHideQuest(q) then
            total = total + 1
            if IsQuestEffectivelyComplete(i, ch.quests, nextQuests) then done = done + 1 end
        end
    end
    return done, total
end


local function GetFirstUnmetChapterPrerequisite(ch)
    if not ch or not ch.prerequisites then return nil end
    for _, req in ipairs(ch.prerequisites) do
        if req.id and not IsQuestComplete(req.id) and not IsQuestInLog(req.id) then
            return req
        end
    end
    return nil
end

local function GetQuestLockReason(data, ch, questIndex, nextChapterQuests)
    if not data or not ch then return nil end

    local playerLevel = UnitLevel("player") or 0
    if data.requiredLevel and playerLevel < data.requiredLevel then
        return string.format("Reach level %d to begin this story.", data.requiredLevel)
    end

    local unmetPrereq = GetFirstUnmetChapterPrerequisite(ch)
    if unmetPrereq then
        local questName = unmetPrereq.name or ("Quest ID " .. tostring(unmetPrereq.id))
        if unmetPrereq.npc and unmetPrereq.npc ~= "" then
            return "Pick up \"" .. questName .. "\" from " .. unmetPrereq.npc .. " to unlock this chapter."
        end
        return "Complete \"" .. questName .. "\" to unlock this chapter."
    end


    if questIndex and questIndex > 1 then
        local prevQuest = ch.quests and ch.quests[questIndex - 1]
        if prevQuest and not IsQuestEffectivelyComplete(questIndex - 1, ch.quests, nextChapterQuests) then
            return "Complete \"" .. (prevQuest.name or ("Quest ID " .. tostring(prevQuest.id))) .. "\" first."
        end
    end

    return nil
end

local function GetQuestlineGateReason(data)
    if not data then return nil end

    local playerLevel = UnitLevel("player") or 0
    if data.requiredLevel and playerLevel < data.requiredLevel then
        return string.format("Reach level %d to begin this story.", data.requiredLevel)
    end

    return nil
end

FindNextQuest = function(data)
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
        local unmetPrereq = GetFirstUnmetChapterPrerequisite(ch)
        if unmetPrereq then
            local prereqQuest = {
                id = unmetPrereq.id,
                name = unmetPrereq.name,
                npc = unmetPrereq.npc,
                _isPrerequisiteForChapter = ch.chapter,
            }
            local section = ch._section or 1
            readyCandidates[#readyCandidates + 1] = {
                quest = prereqQuest, chapter = ch.chapter,
                section = section, depth = 0, order = chIdx,
            }
        else
            local chDone, chTotal = GetChapterProgress(ch, chapters[chIdx + 1])
            if chDone >= chTotal then
                -- Chapter complete, skip
            else
            local section = ch._section or 1

            for j, q in ipairs(ch.quests) do
                if not IsQuestForPlayer(q) then
                    -- skip opposing-faction variant
                elseif IsQuestInLog(q.id) then
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
                local idx, name = i, info.name
                C_Timer.After(0, function()
                    C_Minimap.SetTracking(idx, true)
                    print("|cff64b5f6Story Mode:|r Enabled |cffffd200" .. name .. "|r tracking so you can see quest markers for this storyline.")
                end)
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
    f:SetFrameStrata("HIGH")
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

    ag:SetScript("OnFinished", function() f:Hide(); f:SetParent(UIParent) end)
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

    -- Quest already in log → super-track it directly.
    -- Called from StoryMode_ExecuteSecureTrack() (secure macro context),
    -- so these API calls are trusted and must NOT be deferred via C_Timer.
    if IsQuestInLog(quest.id) then
        local qid = quest.id
        C_QuestLog.AddQuestWatch(qid)
        C_SuperTrack.SetSuperTrackedQuestID(qid)
        -- Open map to the quest's zone if we know it
        local loc = data.npcLocations and data.npcLocations[quest.npc]
        if loc then
            PingOnWorldMap(loc.mapID, loc.x, loc.y)
        end
        return "supertracked", loc and loc.mapID, loc
    end

    -- Quest not in log → try native quest-offer tracking first, then user waypoint
    local loc = data.npcLocations and data.npcLocations[quest.npc]
    local qid = quest.id

    -- 1. Mark with the native QuestOffer super-track pin so WoW's own tracking
    --    system lights up the "!" on the minimap and map.
    if Enum.SuperTrackingMapPinType and Enum.SuperTrackingMapPinType.QuestOffer then
        C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.QuestOffer, qid)
    end

    -- 2. Also set an explicit user waypoint so there's a visible arrow to follow.
    if loc and C_Map.CanSetUserWaypointOnMap(loc.mapID) then
        local point = UiMapPoint.CreateFromCoordinates(loc.mapID, loc.x, loc.y)
        C_Map.SetUserWaypoint(point)
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        PingOnWorldMap(loc.mapID, loc.x, loc.y)
        return "waypoint", loc.mapID, loc
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
    local P = "|cff64b5f6Story Mode:|r "
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
        if quest._isPrerequisiteForChapter then
            if zone then
                print(P .. "Chapter lock: complete |cffffd200" .. quest.name .. "|r in |cff64b5f6" .. zone .. "|r first, then continue |cffffd200" .. quest._isPrerequisiteForChapter .. "|r.")
            else
                print(P .. "Chapter lock: complete |cffffd200" .. quest.name .. "|r first, then continue |cffffd200" .. quest._isPrerequisiteForChapter .. "|r.")
            end
            return
        end
        if zone then
            print(P .. "Find |cffffd200" .. quest.npc .. "|r in |cff64b5f6" .. zone .. "|r to accept: " .. quest.name)
        else
            print(P .. "Find |cffffd200" .. quest.npc .. "|r to accept: " .. quest.name)
        end
    else
        if quest._isPrerequisiteForChapter then
            if zone then
                print(P .. "Chapter lock: complete |cffffd200" .. quest.name .. "|r from " .. quest.npc .. " in |cff64b5f6" .. zone .. "|r first.")
            else
                print(P .. "Chapter lock: complete |cffffd200" .. quest.name .. "|r first.")
            end
            return
        end
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
    { name = "Character Stories", questlines = {} },
    { name = "Short Stories", questlines = {} },
    { name = "Identity", questlines = {} },
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
-- Player filtering helpers
-- ============================================================================

_, playerClass = UnitClass("player")   -- English token: "ROGUE", "WARRIOR", etc.
playerFaction = UnitFactionGroup("player")  -- "Horde" or "Alliance"
playerRace = select(2, UnitRace("player"))  -- English token: "Human", "Orc", etc.

local function CanShowQuestline(data)
    if data.class and data.class ~= playerClass then return false end
    if data.faction and data.faction ~= playerFaction then return false end
    if data.race and data.race ~= playerRace then return false end
    return true
end

-- Returns false for quests tagged with the opposing faction — used to skip
-- Alliance quests for Horde players and vice versa within mixed chapters.
IsQuestForPlayer = function(q)
    return not q.faction or q.faction == playerFaction
end

-- ============================================================================
-- Register Questlines
-- ============================================================================

if CanShowQuestline(SM.FrozenThroneData) then
    RegisterQuestline(SM.FrozenThroneData, "Epic Storylines")
end
if CanShowQuestline(SM.JadeForestData) then
    RegisterQuestline(SM.JadeForestData, "Epic Storylines")
end
if CanShowQuestline(SM.SuramarData) then
    RegisterQuestline(SM.SuramarData, "Epic Storylines")
end
if CanShowQuestline(SM.NazmirData) then
    RegisterQuestline(SM.NazmirData, "Epic Storylines")
end
if CanShowQuestline(SM.DrustvarData) then
    RegisterQuestline(SM.DrustvarData, "Epic Storylines")
end
-- if CanShowQuestline(SM.DreadWastesData) then
--     RegisterQuestline(SM.DreadWastesData, "Epic Storylines")
-- end
if CanShowQuestline(SM.SylvanasData) then
    RegisterQuestline(SM.SylvanasData, "Character Stories")
end
if CanShowQuestline(SM.JainaData) then
    RegisterQuestline(SM.JainaData, "Character Stories")
end
if CanShowQuestline(SM.LilianVossData) then
    RegisterQuestline(SM.LilianVossData, "Character Stories")
end
if CanShowQuestline(SM.TeddiesAndTeaData) then
    RegisterQuestline(SM.TeddiesAndTeaData, "Short Stories")
end
local classCampaigns = {
    SM.DeathKnightCampaignData,
    SM.DemonHunterCampaignData,
    SM.DruidCampaignData,
    SM.HunterCampaignData,
    SM.MageCampaignData,
    SM.MonkCampaignData,
    SM.PaladinCampaignData,
    SM.PriestCampaignData,
    SM.RogueCampaignData,
    SM.ShamanCampaignData,
    SM.WarlockCampaignData,
    SM.WarriorCampaignData,
}
for _, data in ipairs(classCampaigns) do
    if CanShowQuestline(data) then
        RegisterQuestline(data, "Identity")
    end
end

if SM.ForsakenHeritageData then
    if CanShowQuestline(SM.ForsakenHeritageData) then
        RegisterQuestline(SM.ForsakenHeritageData, "Identity")
    end
end

local heritageQuestlines = {
    SM.BloodElfHeritageData,
    SM.GoblinHeritageData,
    SM.TrollHeritageData,
    SM.OrcHeritageData,
    SM.TaurenHeritageData,
    SM.HumanHeritageData,
    SM.DwarfHeritageData,
    SM.GnomeHeritageData,
    SM.NightElfHeritageData,
    SM.WorgenHeritageData,
    SM.DraeneiHeritageData,
    SM.PandarenHeritageData,
    SM.DarkIronHeritageData,
}
for _, data in ipairs(heritageQuestlines) do
    if data and CanShowQuestline(data) then
        RegisterQuestline(data, "Identity")
    end
end


-- ============================================================================
-- Story Mode Window  —  Trading-Post-style clean dark panels
-- ============================================================================

-- Private tooltip — plain Frame, never touches the GameTooltip C layer so we
-- cannot taint MoneyFrame or EmbeddedItemTooltip arithmetic in Blizzard code.
-- do/end scopes the helpers so they don't count against the 200-local limit.
local SMTooltip
do
    local TTPAD  = 10
    local TTLSP  = 3
    local TTWRAP = 380
    local TTMIN  = 220

    SMTooltip = CreateFrame("Frame", "StoryModeTooltip", UIParent, "BackdropTemplate")
    SMTooltip:SetFrameStrata("TOOLTIP")
    SMTooltip:SetToplevel(true)
    SMTooltip:SetClampedToScreen(true)
    SMTooltip:Hide()
    SMTooltip:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    SMTooltip:SetBackdropColor(0.09, 0.09, 0.19, 1)
    SMTooltip:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)

    local ttLines = {}
    local ttLineN = 0

    local function TTLine(i)
        if not ttLines[i] then
            local fs = SMTooltip:CreateFontString(nil, "OVERLAY")
            fs:SetFont("Fonts/FRIZQT__.TTF", 12, "")
            fs:SetJustifyH("LEFT")
            ttLines[i] = fs
        end
        return ttLines[i]
    end

    local _frameShow = SMTooltip.Show

    function SMTooltip:SetOwner(frame, anchor)
        self:ClearAllPoints()
        if anchor == "ANCHOR_LEFT" then
            self:SetPoint("TOPRIGHT", frame, "TOPLEFT", -5, 0)
        else
            self:SetPoint("TOPLEFT", frame, "TOPRIGHT", 5, 0)
        end
    end

    function SMTooltip:ClearLines()
        ttLineN = 0
        for _, fs in ipairs(ttLines) do fs:Hide() end
        ttWraps = {}
    end

    local ttWraps = {}  -- parallel bool array: ttWraps[i] = true if line i wraps

    function SMTooltip:AddLine(text, r, g, b, wrap)
        ttLineN = ttLineN + 1
        local fs = TTLine(ttLineN)
        fs:SetTextColor(r or 1, g or 1, b or 1)
        fs:SetWordWrap(wrap and true or false)
        fs:SetWidth(wrap and TTWRAP or 0)
        fs:SetText(text or "")
        ttWraps[ttLineN] = wrap and true or false
        fs:Show()
    end

    function SMTooltip:Show()
        local maxW = self._minW ~= nil and self._minW or TTMIN
        self._minW = nil
        for i = 1, ttLineN do
            local fs = ttLines[i]
            if fs and fs:IsShown() and not ttWraps[i] then
                local w = fs:GetStringWidth()
                if w > maxW then maxW = w end
            end
        end
        local innerW = math.min(maxW, TTWRAP)

        local yOff = -TTPAD
        for i = 1, ttLineN do
            local fs = ttLines[i]
            if fs and fs:IsShown() then
                fs:ClearAllPoints()
                fs:SetPoint("TOPLEFT", self, "TOPLEFT", TTPAD, yOff)
                if ttWraps[i] then fs:SetWidth(innerW) end
                yOff = yOff - fs:GetStringHeight() - TTLSP
            end
        end

        self:SetWidth(innerW + TTPAD * 2)
        self:SetHeight(math.abs(yOff) - TTLSP + TTPAD)
        _frameShow(self)
    end
end

-- Node ring colors — module-scoped so both the track builder and
-- LayoutSelectedChapter can restore per-state colors after selection changes.
local RING_GREEN_R, RING_GREEN_G, RING_GREEN_B = 0.35, 0.78, 0.28
local RING_GOLD_R,  RING_GOLD_G,  RING_GOLD_B  = 1.0,  0.82, 0.35

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

local tabAchievementsLabel = NoShadow(rightHeader:CreateFontString(nil, "OVERLAY", "QuestFont_Large"))
tabAchievementsLabel:SetPoint("LEFT", tabProgressLabel, "RIGHT", 24, 0)
tabAchievementsLabel:SetPoint("BOTTOM", rightHeader, "BOTTOM", 0, 18)
tabAchievementsLabel:SetText("Achievements")
tabAchievementsLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])

local tabAchievementsHit = CreateFrame("Button", nil, rightHeader)
tabAchievementsHit:SetPoint("TOPLEFT",     tabAchievementsLabel, "TOPLEFT",     -4,  4)
tabAchievementsHit:SetPoint("BOTTOMRIGHT", tabAchievementsLabel, "BOTTOMRIGHT",  4, -4)

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
detailScroll:SetPoint("TOPLEFT",     tabContainer, "TOPLEFT",      2,  -2)
detailScroll:SetPoint("BOTTOMRIGHT", tabContainer, "BOTTOMRIGHT", -2,   2)
local detailChild = CreateFrame("Frame", nil, detailScroll)
detailChild:SetWidth(RIGHT_W)
detailScroll:SetScrollChild(detailChild)
EnableMouseWheelScroll(detailScroll)

-- Move scrollbar inside the panel, 8px from right edge
if detailScroll.ScrollBar then
    detailScroll.ScrollBar:ClearAllPoints()
    detailScroll.ScrollBar:SetPoint("TOPRIGHT",    detailScroll, "TOPRIGHT",    -13, -16)
    detailScroll.ScrollBar:SetPoint("BOTTOMRIGHT", detailScroll, "BOTTOMRIGHT", -13,  16)
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
    "Warcraft has told some extraordinary stories. "
    .."Most of them are buried in quest chains that are easy to miss "
    .."and hard to find your way back to."
    .."\n\nThis is a personal collection — questlines I played and thought "
    .."were worth going back to. Each one is laid out chapter by chapter: "
    .."the characters, the context, and your next step. "
    .."As you progress, your story is written into a journal "
    .."you can revisit any time."
    .."\n\nFor the best experience, pair this with Dialogue UI — "
    .."it transforms quest text into a conversation you actually want to read."
    .."\n\nChoose a story on the left.")

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
-- The visible button is a standard (non-secure) Button so it can anchor
-- freely to FontStrings during layout. A separate invisible secure overlay
-- (sTrackBtnSecure, created further below) is anchored on top of it with
-- SetAllPoints — that overlay is what actually receives clicks and fires
-- the macro in a secure execution context, keeping the tainting calls
-- (OpenWorldMap / AddQuestWatch / SetSuperTracked* / SetUserWaypoint)
-- out of Blizzard's quest-reward money-frame path.
local sTrackBtnTemplate = C_XMLUtil and C_XMLUtil.GetTemplateInfo
    and C_XMLUtil.GetTemplateInfo("SharedButtonLargeTemplate")
    and "SharedButtonLargeTemplate" or "UIPanelButtonTemplate"
local sTrackBtn = CreateFrame("Button", nil, detailChild, sTrackBtnTemplate)
sTrackBtn:SetSize(240, 40)
sTrackBtn:SetText("Begin This Story")
sTrackBtn:RegisterForClicks("AnyUp")
sTrackBtn.lockReason = nil

-- Pending action queued by PreClick; consumed by the secure macro.
local pendingSecureTrack = nil

-- Called from the macro via /run — runs in secure context, so its calls to
-- OpenWorldMap / AddQuestWatch / SetSuperTrackedQuestID / SetUserWaypoint
-- don't taint the execution path. Upvalues SetWaypointForQuest,
-- PrintTrackResult and storyFrame resolve at call time.
function StoryMode_ExecuteSecureTrack()
    local pending = pendingSecureTrack
    pendingSecureTrack = nil
    if not pending then return end
    local result = SetWaypointForQuest(pending.data, pending.quest)
    PrintTrackResult(result, pending.quest, pending.data)
    if storyFrame then storyFrame:Hide() end
end

-- Invisible SecureActionButtonTemplate overlay. Parented to detailChild, and
-- its anchor points are computed manually from sTrackBtn's rect so there is
-- NO anchor dependency in either direction. (If the overlay anchored to
-- sTrackBtn, sTrackBtn would inherit the protected-frame anchor rules and
-- could no longer be anchored to FontStrings during layout — raising
-- "Cannot anchor protected frames to regions". If sTrackBtn anchored to
-- the overlay, the same thing would happen.) SyncSecureOverlay() keeps it
-- positioned on top of sTrackBtn; it's called after every layout pass and
-- is a no-op during combat (SetPoint on protected frames is combat-
-- restricted — minor cosmetic drift is acceptable).
local sTrackBtnSecure = CreateFrame("Button", "StoryModeTrackButton", detailChild, "SecureActionButtonTemplate")
sTrackBtnSecure:SetSize(240, 40)
sTrackBtnSecure:SetPoint("TOPLEFT", detailChild, "TOPLEFT", 0, 0)
sTrackBtnSecure:RegisterForClicks("AnyUp")
sTrackBtnSecure:SetAttribute("type", "macro")
sTrackBtnSecure:SetAttribute("macrotext", "/run StoryMode_ExecuteSecureTrack()")
sTrackBtnSecure:SetFrameLevel((sTrackBtn:GetFrameLevel() or 0) + 5)

local function SyncSecureOverlay()
    if InCombatLockdown() then return end
    local btnLeft, btnTop = sTrackBtn:GetLeft(), sTrackBtn:GetTop()
    local parLeft, parTop = detailChild:GetLeft(), detailChild:GetTop()
    if not (btnLeft and btnTop and parLeft and parTop) then return end
    sTrackBtnSecure:ClearAllPoints()
    sTrackBtnSecure:SetPoint("TOPLEFT", detailChild, "TOPLEFT",
        btnLeft - parLeft, btnTop - parTop)
    sTrackBtnSecure:SetSize(sTrackBtn:GetWidth(), sTrackBtn:GetHeight())
end

-- Re-sync when sTrackBtn resizes (content fonts reflowing, etc.).
-- Layout code calls SyncSecureOverlay() explicitly after re-anchoring.
sTrackBtn:HookScript("OnSizeChanged", SyncSecureOverlay)
sTrackBtn:HookScript("OnShow", SyncSecureOverlay)
-- Always visible; enable/disable is effectively controlled by whether PreClick
-- queues a pending action. No pending action → the macro is a no-op.

-- Forward hover events to the visible button so its template highlight and
-- lock-reason tooltip keep working while the overlay sits on top.
sTrackBtnSecure:SetScript("OnEnter", function()
    local fn = sTrackBtn:GetScript("OnEnter")
    if fn then fn(sTrackBtn) end
end)
sTrackBtnSecure:SetScript("OnLeave", function()
    local fn = sTrackBtn:GetScript("OnLeave")
    if fn then fn(sTrackBtn) end
end)
sTrackBtn:SetScript("OnEnter", function(self)
    if self.lockReason then
        SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
        SMTooltip:ClearLines()
        SMTooltip:AddLine("Story is locked", 1, 1, 1)
        SMTooltip:AddLine(self.lockReason, 1.0, 0.82, 0.35, true)
        SMTooltip:Show()
    end
end)
sTrackBtn:SetScript("OnLeave", function() SMTooltip:Hide() end)

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
local HERITAGE_ICON_BY_RACE = {
    BloodElf = 2459464,
    Goblin = "Interface\\Icons\\inv_misc_tabard_goblin",
    Troll = "Interface\\Icons\\inv_misc_tabard_darkspear",
    Orc = "Interface\\Icons\\inv_misc_tabard_orgrimmar",
    Tauren = "Interface\\Icons\\inv_misc_tabard_thunderbluff",
    Human = "Interface\\Icons\\inv_misc_tabard_stormwind",
    Dwarf = "Interface\\Icons\\inv_misc_tabard_ironforge",
    Gnome = "Interface\\Icons\\inv_misc_tabard_gnomeregan",
    NightElf = "Interface\\Icons\\inv_misc_tabard_darnassus",
    Worgen = "Interface\\Icons\\inv_misc_tabard_gilneas",
    Draenei = "Interface\\Icons\\inv_misc_tabard_exodar",
    Pandaren = "Interface\\Icons\\inv_misc_tabard_tushui",
    DarkIronDwarf = "Interface\\Icons\\inv_misc_tabard_darkiron",
    Scourge = "Interface\\Icons\\inv_misc_tabard_forsaken",
}
local HERITAGE_ICON_FALLBACK = "Interface\\Icons\\inv_misc_cape_18"
local PANDAREN_TABARD_ICON = "Interface\\Icons\\inv_misc_tabard_tushui"

local function SafeSetTexture(tex, path)
    tex:SetTexture(path)
    return tex:GetTexture() ~= nil
end

local function SetChapterPortrait(portraitTex, displayID, iconPath)
    -- Prevent stale portrait reuse when a source fails to resolve.
    portraitTex:SetTexture(nil)

    local fallbackID = currentStoryData and currentStoryData.portraitDisplayID
    local tryID = nil
    if displayID and displayID ~= 0 then
        tryID = displayID
    elseif fallbackID then
        tryID = fallbackID
    end
    if tryID then
        -- Creature portraits look best with a slight center crop.
        portraitTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        SetPortraitTextureFromCreatureDisplayID(portraitTex, tryID)
        if not portraitTex:GetTexture() then
            -- If creature display lookup fails, try chapter icon before question mark.
            if iconPath then
                portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
                if not SafeSetTexture(portraitTex, iconPath) then
                    SafeSetTexture(portraitTex, "Interface\\Icons\\INV_Misc_QuestionMark")
                end
            else
                SafeSetTexture(portraitTex, "Interface\\Icons\\INV_Misc_QuestionMark")
            end
        end
    elseif currentStoryData and currentStoryData.race and not currentStoryData.class then
        -- Heritage tracks: prefer achievement art, then cloak/tabard fallback.
        portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
        local achIcon
        if currentStoryData.achievementID then
            local _,_,_,_,_,_,_,_,_,icon = GetAchievementInfo(currentStoryData.achievementID)
            if icon and icon ~= 0 then achIcon = icon end
        end
        if not (achIcon and SafeSetTexture(portraitTex, achIcon)) then
            local heritageIcon = HERITAGE_ICON_BY_RACE[currentStoryData.race]
            if not (heritageIcon and SafeSetTexture(portraitTex, heritageIcon)) then
                if currentStoryData.race == "Pandaren" then
                    SafeSetTexture(portraitTex, PANDAREN_TABARD_ICON)
                elseif not SafeSetTexture(portraitTex, HERITAGE_ICON_FALLBACK) then
                    SafeSetTexture(portraitTex, "Interface\\Icons\\INV_Misc_QuestionMark")
                end
            end
        end
    elseif iconPath then
        -- Chapter icon override (non-NPC visual) when a campaign defines one.
        portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
        if not SafeSetTexture(portraitTex, iconPath) then
            SafeSetTexture(portraitTex, "Interface\\Icons\\INV_Misc_QuestionMark")
        end
    elseif currentStoryData and currentStoryData.icon then
        -- Tabard/banner icons often have transparent outer margins; crop inward for chapter portraits.
        portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
        if not SafeSetTexture(portraitTex, currentStoryData.icon) then
            local fallback = currentStoryData.race and HERITAGE_ICON_BY_RACE[currentStoryData.race]
            if not (fallback and SafeSetTexture(portraitTex, fallback)) then
                SafeSetTexture(portraitTex, "Interface\\Icons\\INV_Misc_QuestionMark")
            end
        end
    else
        portraitTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        local fallback = currentStoryData and currentStoryData.race and HERITAGE_ICON_BY_RACE[currentStoryData.race]
        if fallback then
            portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
            SafeSetTexture(portraitTex, fallback)
        else
            portraitTex:SetTexture(nil)
        end
    end
end

-- Resolve chapter portrait source: explicit chapter override first, then first quest's NPC portrait.
local function GetChapterPortraitSource(data, chapter)
    if not data or not chapter then
        return nil, nil
    end

    -- Heritage chains: use explicit chapter override when provided, otherwise first-quest NPC.
    if data.race and not data.class then
        if data.chapterDisplayIDs then
            local chapterDisplayID = data.chapterDisplayIDs[chapter.chapter]
            if chapterDisplayID and chapterDisplayID ~= 0 then
                return chapterDisplayID, nil
            end
        end
        if data.chapterIcons then
            local chapterIcon = data.chapterIcons[chapter.chapter]
            if chapterIcon and chapterIcon ~= "" then
                return nil, chapterIcon
            end
        end
        if data.npcDisplayIDs and chapter.quests then
            for _, q in ipairs(chapter.quests) do
                if not q.faction or q.faction == playerFaction then
                    local id = q.npc and data.npcDisplayIDs[q.npc]
                    if id and id ~= 0 then
                        return id, nil
                    end
                end
            end
        end
        return nil, nil
    end

    if data.chapterDisplayIDs then
        local chapterDisplayID = data.chapterDisplayIDs[chapter.chapter]
        if chapterDisplayID and chapterDisplayID ~= 0 then
            return chapterDisplayID, nil
        end
    end

    if data.chapterIcons then
        local chapterIcon = data.chapterIcons[chapter.chapter]
        if chapterIcon and chapterIcon ~= "" then
            return nil, chapterIcon
        end
    end

    if data.npcDisplayIDs and chapter.quests then
        -- Walk the quest list to find the first quest whose faction matches (or has no faction).
        for _, q in ipairs(chapter.quests) do
            if not q.faction or q.faction == playerFaction then
                local id = q.npc and data.npcDisplayIDs[q.npc]
                if id and id ~= 0 then
                    return id, nil
                end
            end
        end
    end

    return nil, nil
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
            SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
            SMTooltip:ClearLines()
            SMTooltip:AddLine(self.tooltipTitle, 1, 1, 1)
            if self.tooltipBody then
                SMTooltip:AddLine(self.tooltipBody, C_BODY[1], C_BODY[2], C_BODY[3], true)
            end
            if self.tooltipProgress then
                SMTooltip:AddLine(" ")
                SMTooltip:AddLine(self.tooltipProgress, C_DIM[1], C_DIM[2], C_DIM[3])
            end
            SMTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function(self)
        SMTooltip:Hide()
    end)

    return row
end

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

-- Prerequisite note — shown when a chapter has a .note field
local dChapterNote = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Shadow_Small"))
dChapterNote:SetJustifyH("LEFT"); dChapterNote:SetSpacing(3); dChapterNote:SetWordWrap(true)
dChapterNote:SetTextColor(1.0, 0.82, 0.35)
dChapterNote:Hide()

-- Mark as Viewed button — shown for loreOnly chapters (same template as story CTA)
local dMarkViewedBtn = CreateFrame("Button", nil, detailChild, sTrackBtnTemplate)
dMarkViewedBtn:SetSize(240, 40)
dMarkViewedBtn:SetText("Mark as Viewed")
dMarkViewedBtn:Hide()

-- Achievement reward line — clickable, shown when a chapter has an achievementID
local dChapterAchievement = CreateFrame("Button", nil, detailChild)
dChapterAchievement:SetHeight(18)
dChapterAchievement:Hide()
do
    local icon = dChapterAchievement:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", dChapterAchievement, "LEFT", 0, -1)
    dChapterAchievement.icon = icon

    local label = NoShadow(dChapterAchievement:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
    label:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    label:SetJustifyH("LEFT")
    dChapterAchievement.label = label

    dChapterAchievement:SetScript("OnClick", function(self)
        if self.achID then
            if AchievementFrame_ShowAchievement then
                AchievementFrame_ShowAchievement(self.achID)
            elseif AchievementFrame then
                ShowUIPanel(AchievementFrame)
            else
                ToggleAchievementFrame()
            end
        end
    end)
    dChapterAchievement:SetScript("OnEnter", function(self)
        self.label:SetTextColor(1, 1, 0.6)
    end)
    dChapterAchievement:SetScript("OnLeave", function(self)
        if self.achieved then
            self.label:SetTextColor(0.45, 0.90, 0.35)
        else
            self.label:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        end
    end)
end

-- Full-size achievement card for chapters that have no quest list.
-- Reuses CreateAchievementRow (defined later) — forward-created after that function.
local dChapterAchievementCard  -- assigned after CreateAchievementRow is defined

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
    btn.portraitMask = mask

    -- Ring (circle border, shown for normal chapters)
    local ring = btn:CreateTexture(nil, "OVERLAY")
    ring:SetAtlas("ui-frame-genericplayerchoice-portrait-border", false)
    ring:SetPoint("TOPLEFT", portrait, "TOPLEFT", -3, 3)
    ring:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 3, -3)
    btn.ring = ring

    -- Square border (shown instead of ring for gated/prerequisite chapters).
    -- Hosted in a child frame above btn's frame level so it always renders
    -- on top of the HIGHLIGHT draw layer (which only shows on hover).
    local squareBorderFrame = CreateFrame("Frame", nil, btn)
    squareBorderFrame:SetPoint("TOPLEFT", portrait, "TOPLEFT", -3, 3)
    squareBorderFrame:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 3, -3)
    squareBorderFrame:SetFrameLevel(btn:GetFrameLevel() + 5)
    local squareBorder = squareBorderFrame:CreateTexture(nil, "OVERLAY")
    squareBorder:SetAtlas("talents-node-square-gray", false)
    squareBorder:SetAllPoints(squareBorderFrame)
    squareBorder:Hide()
    btn.squareBorder = squareBorder

    -- Number badge
    -- Checkmark badge (top-right)
    local checkmark = btn:CreateTexture(nil, "OVERLAY", nil, 2)
    checkmark:SetAtlas("common-icon-checkmark", false)
    checkmark:SetSize(14, 14)
    checkmark:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 4, -4)
    checkmark:Hide()
    btn.checkmark = checkmark

    -- Hover highlight (masked to circle). In OVERLAY sublevel -1 so the ring
    -- and squareBorder child frame always render above it regardless of hover.
    local hl = btn:CreateTexture(nil, "OVERLAY", nil, -1)
    hl:SetTexture("Interface/Buttons/WHITE8x8")
    hl:SetAllPoints(portrait)
    hl:SetVertexColor(1, 0.82, 0.50, 0.2)
    hl:Hide()
    local hlMask = btn:CreateMaskTexture()
    hlMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    hlMask:SetAllPoints(portrait)
    hl:AddMaskTexture(hlMask)
    btn.hl = hl
    btn.hlMask = hlMask

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
    btn.glowMask = glowMask

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
        self.hl:Show()
        if self.tooltipTitle then
            SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
            SMTooltip:ClearLines()
            SMTooltip:AddLine(self.tooltipTitle, 1, 1, 1)
            if self.tooltipBody then
                SMTooltip:AddLine(self.tooltipBody, C_BODY[1], C_BODY[2], C_BODY[3], true)
            end
            if self.tooltipProgress then
                SMTooltip:AddLine(" ")
                SMTooltip:AddLine(self.tooltipProgress, C_DIM[1], C_DIM[2], C_DIM[3])
            end
            if self.tooltipAchievementID then
                local _, achName, _, achDone = GetAchievementInfo(self.tooltipAchievementID)
                if achName then
                    SMTooltip:AddLine(" ")
                    if achDone then
                        SMTooltip:AddLine(achName, 0.45, 0.90, 0.35)
                    else
                        SMTooltip:AddLine(achName, C_GOLD[1], C_GOLD[2], C_GOLD[3])
                    end
                end
            end
            SMTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function(self) self.hl:Hide(); SMTooltip:Hide() end)

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
        SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
        SMTooltip:ClearLines()
        -- Quest name
        local qName = QuestUtils_GetQuestName(self.questID) or self.tooltipTitle or ""
        SMTooltip:AddLine(qName, 1, 1, 1)
        -- Quest giver
        if self.tooltipNPC then
            SMTooltip:AddLine(self.tooltipNPC, C_BODY[1], C_BODY[2], C_BODY[3])
        end
        -- Objectives — skip for completed quests; the log no longer tracks
        -- their counters so they always show stale "0/1" text.
        local qComplete = C_QuestLog.IsQuestFlaggedCompleted(self.questID)
        if not qComplete then
            local objectives = C_QuestLog.GetQuestObjectives(self.questID)
            if objectives and #objectives > 0 then
                SMTooltip:AddLine(" ")
                for _, obj in ipairs(objectives) do
                    if obj.text and obj.text ~= "" then
                        if obj.finished then
                            SMTooltip:AddLine(obj.text, 0.45, 0.90, 0.35, true)
                        else
                            SMTooltip:AddLine(obj.text, 0.9, 0.9, 0.9, true)
                        end
                    end
                end
            end
        end
        -- Status
        if self.tooltipStatus then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine(self.tooltipStatus)
        end
        if self.tooltipRequirement then
            SMTooltip:AddLine(self.tooltipRequirement, 1.0, 0.82, 0.35, true)
        end

        SMTooltip:Show()
    end)
    card:SetScript("OnLeave", function() SMTooltip:Hide() end)

    return card
end

-- ── Achievement row ──────────────────────────────────────────────────
local AROW_H     = 44    -- row height
local AROW_MAX_W = 300   -- max row width, centered in the panel
local AICON_SZ   = 32    -- icon size
local AROW_PAD   = 16    -- inner left/right padding

local function CreateAchievementRow(parent)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(AROW_H)
    row:EnableMouse(true)

    -- Hover: fading gradient tint (transparent → tint → transparent), shown/hidden manually
    local hlL = row:CreateTexture(nil, "BACKGROUND")
    hlL:SetTexture(SOLID)
    hlL:SetPoint("LEFT",  row, "LEFT",   0, 0)
    hlL:SetPoint("RIGHT", row, "CENTER", 0, 0)
    hlL:SetHeight(AROW_H)
    hlL:SetGradient("HORIZONTAL",
        CreateColor(C_BODY[1], C_BODY[2], C_BODY[3], 0),
        CreateColor(C_BODY[1], C_BODY[2], C_BODY[3], 0.12))
    hlL:Hide()
    local hlR = row:CreateTexture(nil, "BACKGROUND")
    hlR:SetTexture(SOLID)
    hlR:SetPoint("LEFT",  row, "CENTER", 0, 0)
    hlR:SetPoint("RIGHT", row, "RIGHT",  0, 0)
    hlR:SetHeight(AROW_H)
    hlR:SetGradient("HORIZONTAL",
        CreateColor(C_BODY[1], C_BODY[2], C_BODY[3], 0.12),
        CreateColor(C_BODY[1], C_BODY[2], C_BODY[3], 0))
    hlR:Hide()
    row.hlL, row.hlR = hlL, hlR

    -- Icon
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(AICON_SZ, AICON_SZ)
    icon:SetPoint("LEFT", row, "LEFT", AROW_PAD, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    row.icon = icon

    -- Talent node square border, tinted gold
    local iconBorder = row:CreateTexture(nil, "OVERLAY")
    iconBorder:SetAtlas("talents-node-square-gray", false)
    iconBorder:SetSize(AICON_SZ + 8, AICON_SZ + 8)
    iconBorder:SetPoint("CENTER", icon, "CENTER", 0, 0)
    iconBorder:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])

    -- Achievement name
    local title = NoShadow(row:CreateFontString(nil, "ARTWORK", "GameFontNormal"))
    title:SetPoint("LEFT",  icon, "RIGHT",  10,        0)
    title:SetPoint("RIGHT", row,  "RIGHT",  -AROW_PAD, 0)
    title:SetJustifyH("LEFT")
    title:SetWordWrap(false)
    row.title = title

    -- Tooltip + hover
    row:SetScript("OnEnter", function(self)
        hlL:Show(); hlR:Show()
        if not self.achievementID then return end
        local _, achName, _, completed, month, day, year, description, _, _, _, rewardText =
            GetAchievementInfo(self.achievementID)
        SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
        SMTooltip:ClearLines()
        SMTooltip:AddLine(achName or "", 1, 1, 1)
        -- Completion status
        if completed then
            local dateStr = (month and month > 0)
                and (" — " .. month .. "/" .. day .. "/" .. year) or ""
            SMTooltip:AddLine("Earned" .. dateStr, 0.2, 0.83, 0.2)
        else
            SMTooltip:AddLine("Not yet earned", C_DIM[1], C_DIM[2], C_DIM[3])
        end
        -- Description
        if description and description ~= "" then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine(description, C_BODY[1], C_BODY[2], C_BODY[3], true)
        end
        -- Criteria
        local numCriteria = GetAchievementNumCriteria(self.achievementID)
        if numCriteria and numCriteria > 0 then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine("Criteria:", C_GOLD[1], C_GOLD[2], C_GOLD[3])
            for i = 1, numCriteria do
                local criteriaName, _, critCompleted = GetAchievementCriteriaInfo(self.achievementID, i)
                if criteriaName and criteriaName ~= "" then
                    local check = critCompleted and "|TInterface\\RaidFrame\\ReadyCheck-Ready:12:12|t" or "|TInterface\\RaidFrame\\ReadyCheck-NotReady:12:12|t"
                    local r, g, b = critCompleted and 0.2 or C_BODY[1], critCompleted and 0.83 or C_BODY[2], critCompleted and 0.2 or C_BODY[3]
                    SMTooltip:AddLine(check .. " " .. criteriaName, r, g, b, true)
                end
            end
        end
        -- Reward
        if rewardText and rewardText ~= "" then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine("Reward: " .. rewardText, C_GOLD[1], C_GOLD[2], C_GOLD[3], true)
        end
        SMTooltip:AddLine(" ")
        SMTooltip:AddLine("Click to open in Achievement log", 0.5, 0.5, 0.5)
        SMTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
        hlL:Hide(); hlR:Hide()
        SMTooltip:Hide()
    end)
    row:SetScript("OnClick", function(self)
        if not self.achievementID then return end
        SMTooltip:Hide()
        storyFrame:Hide()
        if not AchievementFrame then C_AddOns.LoadAddOn("Blizzard_AchievementUI") end
        ShowUIPanel(AchievementFrame)
        AchievementFrame_SelectAchievement(self.achievementID)
    end)

    return row
end

-- Assign the forward-declared chapter achievement card now that CreateAchievementRow exists.
dChapterAchievementCard = CreateAchievementRow(detailChild)
dChapterAchievementCard:Hide()

-- ── No-achievements placeholder label ───────────────────────────────
local aNoAchLabel = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
aNoAchLabel:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])
aNoAchLabel:SetText("No achievements tracked for this story.")
aNoAchLabel:Hide()
achievementElements[#achievementElements + 1] = aNoAchLabel

-- ── Layout achievements tab (centered list with fading dividers) ─────
local function LayoutAchievementsTab(data)
    local ids    = GetStoryAchievements(data)
    local numDiv = math.max(0, #ids - 1)

    -- Pool-expand rows
    while #aAchCards < #ids do
        local r = CreateAchievementRow(detailChild)
        aAchCards[#aAchCards + 1] = r
        achievementElements[#achievementElements + 1] = r
    end

    -- Pool-expand dividers.
    -- KEY: use a Frame as container positioned with TOPLEFT+TOPRIGHT, then textures
    -- inside anchored LEFT+RIGHT only. Raw textures with 3 anchor points (TOP+LEFT+RIGHT)
    -- do not render reliably in WoW — this is the proven pattern from CreateCatDivider.
    while #aAchDividers < numDiv do
        local f = CreateFrame("Frame", nil, detailChild)
        f:SetHeight(1)
        local tL = f:CreateTexture(nil, "ARTWORK")
        tL:SetTexture(SOLID)
        tL:SetHeight(1)
        tL:SetPoint("LEFT",   f, "LEFT",   0, 0)
        tL:SetPoint("RIGHT",  f, "CENTER", 0, 0)
        tL:SetGradient("HORIZONTAL",
            CreateColor(1.0, 0.80, 0.45, 0),
            CreateColor(1.0, 0.80, 0.45, 0.2))
        local tR = f:CreateTexture(nil, "ARTWORK")
        tR:SetTexture(SOLID)
        tR:SetHeight(1)
        tR:SetPoint("LEFT",   f, "CENTER", 0, 0)
        tR:SetPoint("RIGHT",  f, "RIGHT",  0, 0)
        tR:SetGradient("HORIZONTAL",
            CreateColor(1.0, 0.80, 0.45, 0.2),
            CreateColor(1.0, 0.80, 0.45, 0))
        f:Hide()
        aAchDividers[#aAchDividers + 1] = f
        achievementElements[#achievementElements + 1] = f
    end

    if #ids == 0 then
        aNoAchLabel:ClearAllPoints()
        aNoAchLabel:SetPoint("TOP", heroFrame, "BOTTOM", 0, -24)
        aNoAchLabel:Show()
        return
    end

    local halfW = math.floor(AROW_MAX_W / 2)
    -- yOff counts downward from heroFrame BOTTOM; all positions are absolute, no chained anchors
    local yOff  = -20
    -- spacing: 8 px gap → 2 px divider → 8 px gap = 18 px between row bottoms and next row tops
    local DIV_ABOVE = 8
    local DIV_H     = 2
    local DIV_BELOW = 8

    for i, achID in ipairs(ids) do
        local row = aAchCards[i]
        local _, achName, _, completed, _, _, _, _, _, icon = GetAchievementInfo(achID)

        row.achievementID = achID
        row.icon:SetTexture(icon)
        row.icon:SetDesaturated(not completed)
        row.title:SetText(achName or "")
        row.title:SetTextColor(
            completed and C_BODY[1] or C_DIM[1],
            completed and C_BODY[2] or C_DIM[2],
            completed and C_BODY[3] or C_DIM[3])

        row:ClearAllPoints()
        row:SetWidth(AROW_MAX_W)
        row:SetPoint("TOP",  heroFrame,   "BOTTOM", 0,      yOff)
        row:SetPoint("LEFT", detailChild, "CENTER", -halfW, 0)
        row:Show()

        yOff = yOff - AROW_H

        -- Divider frame below this row (not after the last row)
        if i < #ids then
            local dY = yOff - DIV_ABOVE
            local f  = aAchDividers[i]
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT",  heroFrame, "BOTTOMLEFT",  DP + 80,  dY)
            f:SetPoint("TOPRIGHT", heroFrame, "BOTTOMRIGHT", -(DP + 80), dY)
            f:Show()
            yOff = yOff - DIV_ABOVE - DIV_H - DIV_BELOW
        end
    end

    -- Resize scroll child to fit
    local listH = math.abs(yOff) + 24
    C_Timer.After(0, function()
        local heroBot  = heroFrame:GetBottom()
        local childTop = detailChild:GetTop()
        if heroBot and childTop then
            detailChild:SetHeight(math.max((childTop - heroBot) + listH, 400))
        end
    end)
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

    -- Update track selection visuals: selected node gets gold ring + glow.
    -- Deselected nodes get their completion-state ring color restored.
    -- Gated nodes (with prerequisites) use squareBorder instead of ring.
    local function SetNodeBorder(node, r, g, b, a)
        node.ring:SetVertexColor(r, g, b)
        node.ring:SetAlpha(a)
        if node.isGated then
            node.squareBorder:SetVertexColor(r, g, b)
            node.squareBorder:SetAlpha(a)
        end
    end
    for i, node in ipairs(dTrackNodes) do
        if not node:IsShown() then break end
        if i == dSelectedChapter then
            SetNodeBorder(node, C_GOLD[1], C_GOLD[2], C_GOLD[3], 1.0)
            node.activeGlow:Show()
            node.downArrow:Show()
        else
            node.activeGlow:Hide()
            node.downArrow:Hide()
            -- Restore completion-state border color so it doesn't stay gold.
            local thCh = chapters[i]
            if thCh then
                if thCh.loreOnly then
                    local loreViewed = IsLoreChapterViewed(data.title, thCh.chapter)
                    if loreViewed then
                        SetNodeBorder(node, RING_GREEN_R, RING_GREEN_G, RING_GREEN_B, 0.8)
                        node.checkmark:Show()
                    else
                        SetNodeBorder(node, 0.55, 0.48, 0.38, 0.55)
                        node.checkmark:Hide()
                    end
                else
                    local cd, ct = GetChapterProgress(thCh, chapters[i + 1])
                    local isComp = cd == ct and ct > 0
                    local isAct  = cd > 0 and not isComp
                    if isComp then
                        SetNodeBorder(node, RING_GREEN_R, RING_GREEN_G, RING_GREEN_B, 0.8)
                    elseif isAct then
                        SetNodeBorder(node, RING_GOLD_R, RING_GOLD_G, RING_GOLD_B, 0.9)
                    else
                        SetNodeBorder(node, 0.4, 0.35, 0.30, 0.5)
                    end
                end
            end
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

    local playerLevel = UnitLevel("player") or 0
    local cdNote, ctNote = GetChapterProgress(ch, chapters[dSelectedChapter + 1])
    local chIsComplete = cdNote == ctNote and ctNote > 0

    if ch.loreOnly then
        dChapterNote:SetText(ch.note or "This content is no longer available in-game.")
        dChapterNote:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        dChapterNote:Show()
    elseif data.requiredLevel and playerLevel < data.requiredLevel then
        dChapterNote:SetText("Reach level " .. data.requiredLevel .. " to begin this story.")
        dChapterNote:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        dChapterNote:Show()
    elseif ch.note and not chIsComplete then
        dChapterNote:SetText(ch.note)
        dChapterNote:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        dChapterNote:Show()
    elseif ch.prerequisites and not chIsComplete then
        local req = GetFirstUnmetChapterPrerequisite(ch)
        if req then
            local reqQuest = req.name or ("Quest ID " .. tostring(req.id))
            if req.npc then
                dChapterNote:SetText("Speak with " .. req.npc .. " and pick up \"" .. reqQuest .. "\" to begin this chapter.")
            else
                dChapterNote:SetText("Complete \"" .. reqQuest .. "\" to unlock this chapter.")
            end
            dChapterNote:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
            dChapterNote:Show()
        else
            dChapterNote:Hide()
        end
    else
        dChapterNote:Hide()
    end

    -- Mark as Viewed / Mark as Played button
    if ch.loreOnly or ch.replayable then
        local btnAnchor = dChapterNote:IsShown() and dChapterNote
                       or dChapterSummary:IsShown() and dChapterSummary
                       or dChapterTitle
        dMarkViewedBtn:ClearAllPoints()
        dMarkViewedBtn:SetPoint("TOP", btnAnchor, "BOTTOM", 0, -14)
        if chIsComplete then
            dMarkViewedBtn:SetText(ch.loreOnly and "Watched" or "Played")
            dMarkViewedBtn:SetScript("OnClick", nil)
            dMarkViewedBtn:Disable()
            dMarkViewedBtn:SetAlpha(0.5)
        elseif ch.loreOnly then
            dMarkViewedBtn:SetText("Mark as Viewed")
            dMarkViewedBtn:SetScript("OnClick", function()
                SetLoreChapterViewed(data.title, ch.chapter)
                LayoutSelectedChapter()
            end)
            dMarkViewedBtn:Enable()
            dMarkViewedBtn:SetAlpha(1.0)
        else
            dMarkViewedBtn:SetText("Mark as Played")
            dMarkViewedBtn:SetScript("OnClick", function()
                SetChapterPlayed(data.title, ch.chapter)
                LayoutSelectedChapter()
            end)
            dMarkViewedBtn:Enable()
            dMarkViewedBtn:SetAlpha(1.0)
        end
        dMarkViewedBtn:Show()
    else
        dMarkViewedBtn:Hide()
    end

    -- Achievement reward line — only shown for chapters that also have quest cards.
    -- Quest-less chapters (achievementID, no quests) use the full card below instead.
    -- Replayable chapters suppress this row; the button is the sole interaction.
    local achID = ch.achievementID
    if achID and #ch.quests > 0 and not ch.replayable then
        local _, achName, _, achDone, _,_,_,_, _, achIcon = GetAchievementInfo(achID)
        if achName then
            dChapterAchievement.achID = achID
            dChapterAchievement.achieved = achDone
            if achIcon then
                dChapterAchievement.icon:SetTexture(achIcon)
                dChapterAchievement.icon:Show()
            else
                dChapterAchievement.icon:Hide()
            end
            dChapterAchievement.label:SetText(achName)
            if achDone then
                dChapterAchievement.label:SetTextColor(0.45, 0.90, 0.35)
            else
                dChapterAchievement.label:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
            end
            local achHeaderAnchor = dChapterNote:IsShown() and dChapterNote
                                 or dChapterSummary:IsShown() and dChapterSummary
                                 or dChapterTitle
            dChapterAchievement:ClearAllPoints()
            dChapterAchievement:SetPoint("TOPLEFT", achHeaderAnchor, "BOTTOMLEFT", 0, -8)
            dChapterAchievement:SetPoint("TOPRIGHT", detailChild, "RIGHT", -CP, 0)
            dChapterAchievement:Show()
        else
            dChapterAchievement:Hide()
        end
    else
        dChapterAchievement:Hide()
    end

    -- Quest cards — skipped for replayable chapters (button is the sole interaction point)
    local nextQuest = FindNextQuest(data)
    local nextQuestID = nextQuest and nextQuest.id
    local campaignFinished = (nextQuestID == nil)

    for i, q in ipairs(ch.quests) do
        if not dQuestCards[i] then
            dQuestCards[i] = CreateQuestCard(detailChild)
        end
        local card = dQuestCards[i]
        if ch.replayable or not IsQuestForPlayer(q) or ShouldHideQuest(q) then
            card:Hide()
        else
            local nextCh = chapters[dSelectedChapter + 1]
            local qOptional = q.optional == true
            local qDone = IsQuestEffectivelyComplete(i, ch.quests, nextCh and nextCh.quests)
            local qInLog = not qDone and IsQuestInLog(q.id)
            -- Display fallback: if the story has no next quest ("Story Finished"),
            -- treat remaining cards as complete for UI purposes.
            local qDoneDisplay = qDone or (campaignFinished and not qInLog and not qOptional)
            local qIsNextRecommended = (q.id == nextQuestID)
            local lockReason = (not qDoneDisplay and not qInLog and not qOptional) and GetQuestLockReason(data, ch, i, nextCh and nextCh.quests) or nil

            card.title:SetText(q.name)
            card.npcLabel:SetText(q.npc or "")
            card.questID = q.id
            card.tooltipTitle = q.name
            card.tooltipNPC = q.npc
            card.tooltipStatus = qDoneDisplay and "|cff59c746Completed|r"
                or qInLog and "|cffffd223In Progress|r"
                or qOptional and "|cff808080Optional|r"
                or "|cff808080Not yet available|r"
            card.tooltipRequirement = lockReason

            card.icon:SetSize(14, 14)
            card.icon:SetDesaturation(0)
            if qDoneDisplay then
                card.icon:SetAtlas("common-icon-checkmark", false)
                card.icon:SetVertexColor(0.45, 0.90, 0.35)
                card.icon:Show()
                card.title:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3], 0.8)
                card.npcLabel:SetTextColor(C_BODY[1] * 0.8, C_BODY[2] * 0.8, C_BODY[3] * 0.8, 0.6)
                card:SetAlpha(1.0)
            elseif qInLog or qIsNextRecommended then
                card.icon:SetAtlas("common-icon-forwardarrow", false)
                card.icon:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
                card.icon:Show()
                card.title:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
                card.npcLabel:SetTextColor(C_BODY[1] * 0.8, C_BODY[2] * 0.8, C_BODY[3] * 0.8, 0.7)
                card:SetAlpha(1.0)
            elseif qOptional then
                card.icon:Hide()
                card.title:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3], 0.4)
                card.npcLabel:SetTextColor(C_BODY[1] * 0.8, C_BODY[2] * 0.8, C_BODY[3] * 0.8, 0.3)
                card:SetAlpha(0.55)
            else
                card.icon:Hide()
                card.title:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3], 0.6)
                card.npcLabel:SetTextColor(C_BODY[1] * 0.8, C_BODY[2] * 0.8, C_BODY[3] * 0.8, 0.4)
                card:SetAlpha(0.8)
            end
            card:Show()
        end
    end
    for i = #ch.quests + 1, #dQuestCards do dQuestCards[i]:Hide() end

    -- For chapters with no quests, show a full achievement card instead.
    local CARD_W = 280
    if #ch.quests == 0 and ch.achievementID then
        local _, achName, _, achDone, _,_,_,_,_, achIcon = GetAchievementInfo(ch.achievementID)
        if achName then
            dChapterAchievementCard.achievementID = ch.achievementID
            dChapterAchievementCard.icon:SetTexture(achIcon)
            dChapterAchievementCard.icon:SetDesaturated(not achDone)
            dChapterAchievementCard.title:SetText(achName)
            dChapterAchievementCard.title:SetTextColor(
                achDone and C_BODY[1] or C_DIM[1],
                achDone and C_BODY[2] or C_DIM[2],
                achDone and C_BODY[3] or C_DIM[3])
            local anchor = dChapterNote:IsShown() and dChapterNote
                        or dChapterSummary:IsShown() and dChapterSummary
                        or dChapterTitle
            dChapterAchievementCard:ClearAllPoints()
            dChapterAchievementCard:SetWidth(CARD_W)
            dChapterAchievementCard:SetPoint("TOP",  anchor,      "BOTTOM", 0,         -20)
            dChapterAchievementCard:SetPoint("LEFT", detailChild, "CENTER", -CARD_W/2,   0)
            dChapterAchievementCard:Show()
        else
            dChapterAchievementCard:Hide()
        end
    else
        dChapterAchievementCard:Hide()
    end

    -- Position visible quest cards below the header area
    local prevCard = nil
    for i = 1, #ch.quests do
        local card = dQuestCards[i]
        if card and card:IsShown() then
            card:ClearAllPoints()
            card:SetWidth(CARD_W)
            if not prevCard then
                local anchor = dChapterAchievement:IsShown() and dChapterAchievement
                            or dChapterNote:IsShown() and dChapterNote
                            or dChapterSummary:IsShown() and dChapterSummary
                            or dChapterTitle
                card:SetPoint("TOP", anchor, "BOTTOM", 0, -20)
            else
                card:SetPoint("TOP", prevCard, "BOTTOM", 0, -QCARD_GAP)
            end
            -- Center horizontally: anchor LEFT relative to detailChild center
            card:SetPoint("LEFT", detailChild, "CENTER", -CARD_W / 2, 0)
            prevCard = card
        end
    end

    -- Update scroll height.
    -- For achievement-card-only chapters (no quest cards), the card sits below a
    -- word-wrapped FontString whose height may not be resolved on the zero-delay tick.
    -- A second pass at 0.1 s gives fonts time to finish layout so GetBottom() is accurate
    -- and the card lands within the scroll child's interactive region.
    -- NOTE: no SetHeight pre-sizing here — quest cards anchor their LEFT edge to
    -- detailChild CENTER, so changing detailChild's height shifts their Y position.
    local scrollAnchor = prevCard
                      or (dChapterAchievementCard:IsShown() and dChapterAchievementCard)
                      or (dMarkViewedBtn:IsShown() and dMarkViewedBtn)

    local function UpdateScrollHeight()
        if not scrollAnchor then return end
        local bot = scrollAnchor:GetBottom()
        local top = detailChild:GetTop()
        if bot and top then
            detailChild:SetHeight(math.max(top - bot + 30, 400))
        end
    end

    C_Timer.After(0, UpdateScrollHeight)

    -- Second pass only needed for achievement-card-only chapters.
    if not prevCard and dChapterAchievementCard:IsShown() then
        C_Timer.After(0.1, function()
            if dChapterAchievementCard:IsShown() then
                UpdateScrollHeight()
            end
        end)
    end
end

local progressElements = { dProgSummary, dTrackContainer, dChapterTitle, dChapterSummary, dChapterNote, dChapterAchievement, dChapterAchievementCard, dMarkViewedBtn }

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
    for _, el in ipairs(achievementElements) do el:Hide() end
    sTrackBtn:Hide(); sCompleteText:Hide()
    dCompleteText:Hide()

    if tab == "story" then
        for _, el in ipairs(storyElements) do el:Show() end
    elseif tab == "achievements" then
        -- LayoutAchievementsTab shows only the cards it needs; nothing to pre-show here
    else
        for _, el in ipairs(progressElements) do el:Show() end
    end
end

local function SetActiveTab(tab)
    activeTab = tab
    if tab == "story" then
        tabStoryLabel:SetTextColor(1, 1, 1)
        tabProgressLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        tabAchievementsLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
    elseif tab == "achievements" then
        tabStoryLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        tabProgressLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        tabAchievementsLabel:SetTextColor(1, 1, 1)
    else
        tabStoryLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        tabProgressLabel:SetTextColor(1, 1, 1)
        tabAchievementsLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
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
        local gateReason = GetQuestlineGateReason(data)
        sJournalHeader:SetText(quest and "Your Story So Far" or "Your Story")
        sTrackBtn:ClearAllPoints()
        sTrackBtn:SetPoint("TOP", lastAnchor, "BOTTOM", 0, -24)
        sCompleteText:Hide()
        if quest then
            if gateReason then
                sTrackBtn:SetText("Story Locked")
                sTrackBtn:SetScript("OnClick", nil)
                sTrackBtnSecure:SetScript("PreClick", nil)
                sTrackBtn:Disable()
                sTrackBtn:SetAlpha(0.5)
                sTrackBtn.lockReason = gateReason
            else
                sTrackBtn:SetText(done > 0 and "Continue Story" or "Begin This Story")
                -- PreClick on the secure overlay queues the action BEFORE the
                -- macro fires. The macro then performs the waypoint +
                -- supertrack calls in a secure execution context.
                sTrackBtnSecure:SetScript("PreClick", function()
                    pendingSecureTrack = { data = data, quest = quest }
                end)
                sTrackBtn:SetScript("OnClick", nil)
                sTrackBtn:Enable()
                sTrackBtn:SetAlpha(1.0)
                sTrackBtn.lockReason = nil
            end
        else
            sTrackBtn:SetText("Story Finished")
            sTrackBtn:SetScript("OnClick", nil)
            sTrackBtnSecure:SetScript("PreClick", nil)
            sTrackBtn:Disable()
            sTrackBtn:SetAlpha(0.5)
            sTrackBtn.lockReason = nil
        end
        sTrackBtn:Show()
        SyncSecureOverlay()
        lastAnchor = sTrackBtn

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

    elseif activeTab == "progress" then
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

        -- ── Horizontal chapter track + quest cards ────────────────────
        local GREEN_R, GREEN_G, GREEN_B = RING_GREEN_R, RING_GREEN_G, RING_GREEN_B
        local GOLD_R,  GOLD_G,  GOLD_B  = RING_GOLD_R,  RING_GOLD_G,  RING_GOLD_B
        local DIM_R, DIM_G, DIM_B = C_DIM[1], C_DIM[2], C_DIM[3]

        -- Hide old pools
        for _, node in ipairs(dTrackNodes) do node:Hide() end
        for _, arrow in ipairs(dTrackArrows) do arrow:Hide() end
        for _, card in ipairs(dQuestCards) do card:Hide() end

        -- Find the first incomplete chapter (current chapter)
        local currentChapter = #chapters
        for i, ch in ipairs(chapters) do
            local cd, ct = GetChapterProgress(ch, chapters[i + 1])
            if cd < ct or ct == 0 then currentChapter = i; break end
        end
        dSelectedChapter = currentChapter
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
            local displayID, chapterIcon = GetChapterPortraitSource(data, ch)
            SetChapterPortrait(node.portrait, displayID, chapterIcon)

            -- Tooltip
            node.tooltipTitle = ch.chapter
            node.tooltipBody = ch.summary or nil
            node.tooltipProgress = cDone .. " / " .. cTotal .. " quests"
            node.tooltipAchievementID = ch.achievementID or nil

            -- Status styling
            if ch.loreOnly and not isComplete then
                node.portrait:SetVertexColor(0.80, 0.80, 0.80)
                node.portrait:SetDesaturation(0.4)
                node.ring:SetVertexColor(0.55, 0.48, 0.38)
                node.ring:SetAlpha(0.55)
                node.checkmark:Hide()
            elseif isComplete then
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

            -- Shape: gated chapters render as squares.
            -- ch.prerequisites = explicit quest gate; ch.gated = manual flag for
            -- chapters locked behind progress that can't be expressed as a quest ID.
            local CIRC = "Interface/CHARACTERFRAME/TempPortraitAlphaMask"
            local isGated = ch.prerequisites ~= nil or ch.gated == true
            node.isGated = isGated
            if isGated then
                node.portraitMask:SetTexture("Interface/Buttons/WHITE8x8")
                node.hlMask:SetTexture("Interface/Buttons/WHITE8x8")
                node.glowMask:SetTexture("Interface/Buttons/WHITE8x8")
                local r, g, b = node.ring:GetVertexColor()
                local a = node.ring:GetAlpha()
                node.ring:Hide()
                node.squareBorder:SetVertexColor(r, g, b)
                node.squareBorder:SetAlpha(a)
                node.squareBorder:Show()
            else
                node.portraitMask:SetTexture(CIRC, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                node.hlMask:SetTexture(CIRC, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                node.glowMask:SetTexture(CIRC, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                node.squareBorder:Hide()
                node.ring:Show()
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
                StoryModeDB.selectedChapter = idx
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

        dChapterNote:ClearAllPoints()
        dChapterNote:SetPoint("TOPLEFT", dChapterSummary, "BOTTOMLEFT", 0, -8)
        dChapterNote:SetPoint("TOPRIGHT", dChapterSummary, "BOTTOMRIGHT", 0, -8)

        -- Render quest cards for selected chapter
        LayoutSelectedChapter()
    elseif activeTab == "achievements" then
        -- ── ACHIEVEMENTS TAB layout ──────────────────────────────────────
        LayoutAchievementsTab(data)
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

tabAchievementsHit:SetScript("OnEnter", function()
    if activeTab ~= "achievements" then tabAchievementsLabel:SetTextColor(1, 1, 1) end
end)
tabAchievementsHit:SetScript("OnLeave", function()
    if activeTab ~= "achievements" then tabAchievementsLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3]) end
end)
tabAchievementsHit:SetScript("OnClick", function()
    if activeTab ~= "achievements" and currentStoryData then
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        SetActiveTab("achievements")
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
        for _, el in ipairs(achievementElements) do el:Hide() end
        sTrackBtn:Hide(); sCompleteText:Hide()
        dCompleteText:Hide()
        introIcon2:Show(); introTitle:Show(); introText:Show()
        heroIcon:SetTexture(nil)
        smHeaderSub:SetText("")
        SetActiveTab("story")
        -- Hide tabs on intro page
        tabStoryLabel:Hide(); tabProgressLabel:Hide(); tabAchievementsLabel:Hide()
        tabStoryHit:Hide(); tabProgressHit:Hide(); tabAchievementsHit:Hide()
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
    -- Show tabs; hide achievements tab if this story has none
    tabStoryLabel:Show(); tabProgressLabel:Show()
    tabStoryHit:Show(); tabProgressHit:Show()
    local hasAchievements = #GetStoryAchievements(data) > 0
    tabAchievementsLabel:SetShown(hasAchievements)
    tabAchievementsHit:SetShown(hasAchievements)
    -- If currently on achievements tab but new story has none, fall back to story tab
    if activeTab == "achievements" and not hasAchievements then
        activeTab = "story"
    end

    -- Portrait icon (creature portrait or texture)
    heroIcon:SetTexture(nil)
    if data.portraitDisplayID then
        heroIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        SetPortraitTextureFromCreatureDisplayID(heroIcon, data.portraitDisplayID)
        if not heroIcon:GetTexture() then
            local fallback = data.race and HERITAGE_ICON_BY_RACE[data.race]
            heroIcon:SetTexCoord(0.16, 0.84, 0.12, 0.88)
            if not (fallback and SafeSetTexture(heroIcon, fallback)) then
                SafeSetTexture(heroIcon, HERITAGE_ICON_FALLBACK)
            end
        end
    else
        local iconID
        if data.achievementID then
            local _,_,_,_,_,_,_,_,_,achIcon = GetAchievementInfo(data.achievementID)
            if achIcon and achIcon ~= 0 then iconID = achIcon end
        end
        iconID = data.icon or iconID
        if iconID and iconID ~= 0 then
            heroIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            if not SafeSetTexture(heroIcon, iconID) then
                local fallback = data.race and HERITAGE_ICON_BY_RACE[data.race]
                heroIcon:SetTexCoord(0.16, 0.84, 0.12, 0.88)
                if not (fallback and SafeSetTexture(heroIcon, fallback)) then
                    SafeSetTexture(heroIcon, HERITAGE_ICON_FALLBACK)
                end
            end
        else
            local fallback = data.race and HERITAGE_ICON_BY_RACE[data.race]
            heroIcon:SetTexCoord(0.16, 0.84, 0.12, 0.88)
            if not (fallback and SafeSetTexture(heroIcon, fallback)) then
                SafeSetTexture(heroIcon, HERITAGE_ICON_FALLBACK)
            end
        end
    end

    local displayTitle = data.title
    if (not displayTitle or displayTitle == "") and data.achievementID then
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
local storyIndexToData = {}

-- Portrait circle sizes (Delve companion style)
local PORT = 46
local ICON = 34

local function SelectStory(index)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    storySelectedIdx = index
    StoryModeDB.selectedQuestline = index
    StoryModeDB.selectedChapter = 1  -- reset to first chapter when switching stories
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
    if index == 0 or not storyIndexToData[index] then
        UpdateStoryDetail(nil)
    else
        UpdateStoryDetail(storyIndexToData[index])
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
    wipe(storyIndexToData)

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
                storyIndexToData[idx] = data
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
                    if not iconTex:GetTexture() then
                        if data.achievementID then
                            local _,_,_,_,_,_,_,_,_,achIcon = GetAchievementInfo(data.achievementID)
                            if achIcon and achIcon ~= 0 then
                                iconTex:SetTexture(achIcon)
                            end
                        end
                        if not iconTex:GetTexture() and data.icon then
                            SafeSetTexture(iconTex, data.icon)
                        end
                        if not iconTex:GetTexture() and data.race and not data.class then
                            local heritageIcon = HERITAGE_ICON_BY_RACE[data.race]
                            if not (heritageIcon and SafeSetTexture(iconTex, heritageIcon)) then
                                if data.race == "Pandaren" then
                                    SafeSetTexture(iconTex, PANDAREN_TABARD_ICON)
                                else
                                    SafeSetTexture(iconTex, HERITAGE_ICON_FALLBACK)
                                end
                            end
                        end
                    end
                elseif data.race and not data.class and data.icon then
                    -- Heritage cards should reflect the configured questline card icon.
                    if not SafeSetTexture(iconTex, data.icon) then
                        local heritageIcon = HERITAGE_ICON_BY_RACE[data.race]
                        if not (heritageIcon and SafeSetTexture(iconTex, heritageIcon)) then
                            if data.race == "Pandaren" then
                                SafeSetTexture(iconTex, PANDAREN_TABARD_ICON)
                            else
                                SafeSetTexture(iconTex, HERITAGE_ICON_FALLBACK)
                            end
                        end
                    end
                elseif data.achievementID and not data.icon then
                    local _,_,_,_,_,_,_,_,_,achIcon = GetAchievementInfo(data.achievementID)
                    if achIcon and achIcon ~= 0 then iconTex:SetTexture(achIcon) end
                elseif data.icon then
                    if not SafeSetTexture(iconTex, data.icon) then
                        if data.race == "Pandaren" then
                            SafeSetTexture(iconTex, PANDAREN_TABARD_ICON)
                        else
                            SafeSetTexture(iconTex, HERITAGE_ICON_FALLBACK)
                        end
                    end
                elseif data.race and not data.class then
                    -- Heritage cards: fallback to cloak/tabard style imagery.
                    local heritageIcon = HERITAGE_ICON_BY_RACE[data.race]
                    if not (heritageIcon and SafeSetTexture(iconTex, heritageIcon)) then
                        if data.race == "Pandaren" then
                            SafeSetTexture(iconTex, PANDAREN_TABARD_ICON)
                        else
                            SafeSetTexture(iconTex, HERITAGE_ICON_FALLBACK)
                        end
                    end
                end
                if not iconTex:GetTexture() and data.race and not data.class then
                    local heritageIcon = HERITAGE_ICON_BY_RACE[data.race]
                    if not (heritageIcon and SafeSetTexture(iconTex, heritageIcon)) then
                        if data.race == "Pandaren" then
                            SafeSetTexture(iconTex, PANDAREN_TABARD_ICON)
                        else
                            SafeSetTexture(iconTex, HERITAGE_ICON_FALLBACK)
                        end
                    end
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
                local zoneText = data.zone or ""
                local parts = {}
                for part in zoneText:gmatch("[^/]+") do
                    parts[#parts + 1] = part:match("^%s*(.-)%s*$")
                end
                if #parts > 2 then
                    zoneText = parts[1] .. " / " .. parts[2] .. "…"
                end
                zoneLabel:SetText(zoneText)
                zoneLabel:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])

                -- ── Completion checkmark (bottom-right of portrait, same as track nodes) ──
                local cardCheckmark = portFrame:CreateTexture(nil, "OVERLAY", nil, 2)
                cardCheckmark:SetAtlas("common-icon-checkmark", false)
                cardCheckmark:SetSize(14, 14)
                cardCheckmark:SetPoint("BOTTOMRIGHT", iconTex, "BOTTOMRIGHT", 4, -4)
                local cdone, ctotal = GetCampaignProgress(data)
                if cdone == ctotal and ctotal > 0 then
                    cardCheckmark:Show()
                else
                    cardCheckmark:Hide()
                end

                -- ── Click ──────────────────────────────────────────────────────
                card:SetScript("OnClick", function() SelectStory(idx) end)

                storyLeftRows[idx] = {
                    btn       = card,
                    bg        = bg,
                    portBorder= portBorder,
                    nameLabel = nameLabel,
                    zoneLabel = zoneLabel,
                    checkmark = cardCheckmark,
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
            -- Restore last selected questline, or default to intro
            local savedIdx = StoryModeDB.selectedQuestline or 0
            -- Validate saved index exists
            if savedIdx > 0 and storyIndexToData[savedIdx] then
                SelectStory(savedIdx)
            else
                SelectStory(0)  -- default to Introduction card
            end
        end)
    end)
end)

storyFrame:SetScript("OnHide", function()
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
end)


local ShowStoryBanner   -- forward declaration (defined in Banner section below)
local ShowStoryComplete -- forward declaration (defined in Banner section below)

SLASH_STORYMODE1 = "/sm"
SLASH_STORYMODE2 = "/storymode"
SlashCmdList["STORYMODE"] = function(msg)
    msg = msg and msg:trim():lower() or ""
    if msg == "banner" then
        local data = allQuestlines[1]
        if data then
            ShowStoryBanner(data.title, "Test Quest Name", data, nil, true)
        else
            print("|cff64b5f6StoryMode:|r No questline data to test.")
        end
        return
    elseif msg == "chapter" then
        local data = allQuestlines[1]
        if data then
            local ch = GetAllChapters(data)[1]
            ShowStoryBanner("CHAPTER COMPLETE", ch and ch.chapter or data.title, data, nil, true)
        else
            print("|cff64b5f6StoryMode:|r No questline data to test.")
        end
        return
    elseif msg == "complete" then
        local data = allQuestlines[1]
        if data then
            ShowStoryComplete(data.title)
        else
            print("|cff64b5f6StoryMode:|r No questline data to test.")
        end
        return
    elseif msg == "track" or msg == "next" then
        -- Slash commands always execute in an insecure Lua context, so the
        -- waypoint calls below will taint the quest-reward path. Prefer the
        -- in-UI "Continue Story" button, which routes through the secure
        -- macro dispatch and avoids taint.
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
    elseif msg:match("^debug") then
        local filter = msg:match("^debug%s+(.+)$")
        local found = false
        for _, data in ipairs(allQuestlines) do
            if not filter or data.title:lower():find(filter, 1, true) then
                found = true
                print("|cff64b5f6StoryMode Debug:|r " .. data.title)
                local chapters = GetAllChapters(data)
                for _, ch in ipairs(chapters) do
                    if ch.quests then
                        local chDone, chTotal = GetChapterProgress(ch)
                        print(string.format("  |cffaaaaaa[%s]|r %d/%d", ch.chapter or "?", chDone, chTotal))
                        for j, q in ipairs(ch.quests) do
                            local inLog = IsQuestInLog(q.id)
                            local flagged = C_QuestLog.IsQuestFlaggedCompleted(q.id)
                            local effective = IsQuestEffectivelyComplete(j, ch.quests)
                            local tag = inLog and "|cff00ff00[IN LOG]|r"
                                or (flagged and "|cffaaaaaa[done]|r")
                                or (effective and "|cffff8800[eff-done]|r")
                                or "|cffff4444[incomplete]|r"
                            print(string.format("    %s %d %s", tag, q.id, q.name or "?"))
                        end
                    end
                end
            end
        end
        if not found then
            print("|cff64b5f6StoryMode:|r No questline matching '" .. (filter or "") .. "'")
        end
    else
        if InCombatLockdown() then
            UIErrorsFrame:AddMessage("You cannot toggle this UI while in combat.", 1, 0.1, 0.1)
            return
        end
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

-- Forward-declared so the event handler at the bottom of the file can call it
-- after ADDON_LOADED. Everything else in this section is block-scoped.
local MinimapButton_Init
do
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
    if InCombatLockdown() then
        UIErrorsFrame:AddMessage("You cannot toggle this UI while in combat.", 1, 0.1, 0.1)
        return
    end
    -- Defer the toggle by one frame to avoid taint from protected contexts
    -- (e.g. TalkingHeadFrame animations) bleeding into the Show/Hide call.
    C_Timer.After(0, function()
        if storyFrame:IsShown() then
            storyFrame:Hide()
        else
            storyFrame:Show()
        end
    end)
end)

minimapBtn:SetScript("OnEnter", function(self)
    SMTooltip:SetOwner(self, "ANCHOR_LEFT")
    SMTooltip:ClearLines()
    SMTooltip:AddLine("Story Mode", 1, 1, 1)
    SMTooltip:AddLine("Click to open", C_BODY[1], C_BODY[2], C_BODY[3])
    SMTooltip._minW = 0
    SMTooltip:Show()
end)
minimapBtn:SetScript("OnLeave", function() SMTooltip:Hide() end)

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
MinimapButton_Init = function()
    local angle = StoryModeDB and StoryModeDB.minimapAngle or 4.4  -- default: bottom
    MinimapButton_UpdatePosition(angle)
end
end  -- do: minimap section

-- ============================================================================
-- Chapter / Quest Completion Alert  (minimal top-center text fade)
-- ============================================================================

-- ShowStoryBanner is forward-declared at the top of this section; all
-- alert-frame locals are block-scoped to free their slots before the
-- ShowStoryComplete block below.
do
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
end  -- do: alert section

ShowStoryComplete = function(storyTitle)
    ShowStoryBanner("STORY COMPLETE", storyTitle or "", nil, nil, true)
end

-- ============================================================================
-- Quest Completion Tracking — detect chapter and storyline completion
-- ============================================================================

local chapterCompletionCache  = {}  -- [questlineTitle|chapterName] = true
local storylineCompletionCache = {}  -- [questlineTitle] = true

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
                -- Refresh the open detail panel immediately so checkmarks appear
                C_Timer.After(0.1, function()
                    if storyFrame:IsShown() and currentStoryData == data then
                        UpdateStoryDetail(data)
                    end
                end)

                -- Check if entire chapter is now complete
                local done, total = GetChapterProgress(ch)
                local isChapterDone = done >= total and total > 0
                local key = (data.title or "") .. "|" .. (ch.chapter or "")

                if isChapterDone and not chapterCompletionCache[key] then
                    chapterCompletionCache[key] = true

                    -- Check if the entire storyline just finished
                    local storyKey = data.title or ""
                    local allDone = true
                    for _, c in ipairs(GetAllChapters(data)) do
                        local d, t = GetChapterProgress(c)
                        if d < t or t == 0 then allDone = false; break end
                    end

                    local chName = ch.chapter
                    local npc   = questNpc
                    C_Timer.After(1.5, function()
                        ShowStoryBanner("CHAPTER COMPLETE", chName, data, npc, true)
                    end)

                    if allDone and not storylineCompletionCache[storyKey] then
                        storylineCompletionCache[storyKey] = true
                        C_Timer.After(6.5, function()
                            ShowStoryComplete(data.title)
                        end)
                    end
                else
                    -- Individual quest — show chapter-style banner
                    local qName = questName
                    local npc   = questNpc
                    C_Timer.After(1.0, function()
                        ShowStoryBanner(data.title, qName, data, npc, true)
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
        -- Pre-populate caches so already-completed chapters/storylines don't re-fire
        for _, data in ipairs(allQuestlines) do
            local allDone = true
            for _, ch in ipairs(GetAllChapters(data)) do
                local d, t = GetChapterProgress(ch)
                if d >= t and t > 0 then
                    chapterCompletionCache[(data.title or "") .. "|" .. (ch.chapter or "")] = true
                else
                    allDone = false
                end
            end
            if allDone then
                storylineCompletionCache[data.title or ""] = true
            end
        end
    elseif event == "QUEST_TURNED_IN" then
        CheckQuestCompletion(arg1)
    end
end)
