local addonName, SM = ...
local L = SM.L

local function GetPlayerFaction()
    return UnitFactionGroup("player")
end

local function GetPlayerRace()
    return select(2, UnitRace("player"))
end

local function GetPlayerClass()
    return select(2, UnitClass("player"))
end

function SM.GetQuestIDs(q)
    if type(q) ~= "table" then return { q } end
    local ids = {}
    if q.id then ids[#ids + 1] = q.id end
    if q.altIds then
        for _, id in ipairs(q.altIds) do
            ids[#ids + 1] = id
        end
    end
    return ids
end

function SM.IsQuestComplete(questID)
    return SM.IsQuestFlaggedCompleted(questID)
end

function SM.IsQuestEntryComplete(q)
    for _, questID in ipairs(SM.GetQuestIDs(q)) do
        if SM.IsQuestComplete(questID) then return true end
    end
    return false
end

function SM.IsQuestForPlayer(q)
    if q.faction and q.faction ~= GetPlayerFaction() then return false end
    if q.class then
        local playerClass = GetPlayerClass()
        if type(q.class) == "table" then
            local classMatch = false
            for _, class in ipairs(q.class) do
                if class == playerClass then classMatch = true; break end
            end
            if not classMatch then return false end
        elseif q.class ~= playerClass then
            return false
        end
    end
    if q.race then
        local playerRace = GetPlayerRace()
        if type(q.race) == "table" then
            for _, race in ipairs(q.race) do
                if race == playerRace then return true end
            end
            return false
        end
        return q.race == playerRace
    end
    return true
end

function SM.ShouldHideQuest(q)
    if q.showIf then
        if not SM.IsQuestComplete(q.showIf) then return true end
    elseif q.hideIf then
        local ids = type(q.hideIf) == "table" and q.hideIf or { q.hideIf }
        for _, hid in ipairs(ids) do
            if SM.IsQuestComplete(hid) then return true end
        end
    end
    return false
end

function SM.IsQuestEffectivelyComplete(questIndex, chapterQuests)
    local q = chapterQuests[questIndex]
    -- Quests for the opposing faction are irrelevant.
    if not SM.IsQuestForPlayer(q) then return true end

    if SM.IsQuestEntryInLog(q) then return false end
    if SM.IsQuestEntryComplete(q) then return true end

    for i = 1, questIndex - 1 do
        if SM.IsQuestForPlayer(chapterQuests[i]) and SM.IsQuestEntryInLog(chapterQuests[i]) then
            return false
        end
    end

    for i = questIndex + 1, #chapterQuests do
        if SM.IsQuestForPlayer(chapterQuests[i]) and SM.IsQuestEntryComplete(chapterQuests[i]) then
            return true
        end
    end

    return false
end

function SM.IsQuestInLog(questID)
    return SM.GetLogIndexForQuestID(questID) ~= nil
end

function SM.IsQuestEntryInLog(q)
    for _, questID in ipairs(SM.GetQuestIDs(q)) do
        if SM.IsQuestInLog(questID) then return true, questID end
    end
    return false, nil
end

function SM.GetAllChapters(data)
    local all = {}
    local playerFaction = GetPlayerFaction()

    local function ShouldShowChapter(ch)
        return not ch.faction or ch.faction == playerFaction
    end

    if data.prereqs then
        for _, ch in ipairs(data.prereqs) do
            if ShouldShowChapter(ch) then
                ch._section = 1
                all[#all + 1] = ch
            end
        end
    end
    if data.chapters then
        for _, ch in ipairs(data.chapters) do
            if ShouldShowChapter(ch) then
                ch._section = 2
                all[#all + 1] = ch
            end
        end
    end
    if data.insurrection then
        for _, ch in ipairs(data.insurrection) do
            if ShouldShowChapter(ch) then
                ch._section = 3
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

function SM.GetStoryAchievements(data)
    local ids, seen = {}, {}
    local function add(id)
        if type(id) == "string" then
            local target = id:lower()
            for scan = 1, 50000 do
                local _, scanName = GetAchievementInfo(scan)
                if scanName and scanName:lower() == target then id = scan; break end
            end
            if type(id) ~= "number" then return end
        end
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
    for _, ch in ipairs(SM.GetAllChapters(data)) do
        add(ch.achievementID)
    end
    return ids
end

function SM.GetStoryFactions(data)
    if not data then return nil end
    local faction = GetPlayerFaction()
    return (data.factionsByFaction and data.factionsByFaction[faction]) or data.factions
end

function SM.GetChapterProgress(ch)
    local currentStoryData = SM.GetCurrentStoryData and SM.GetCurrentStoryData()

    if ch.loreOnly then
        if currentStoryData and SM.IsLoreChapterViewed(currentStoryData.title, ch.chapter) then
            return 1, 1
        end
        return 0, 0
    end
    if ch.replayable and currentStoryData and SM.IsChapterPlayed(currentStoryData.title, ch.chapter) then
        return 1, 1
    end
    if ch.achievementID then
        local _, _, _, completed = GetAchievementInfo(ch.achievementID)
        if completed then return 1, 1 end
    end
    if ch.completionAchievementID then
        local _, _, _, completed = GetAchievementInfo(ch.completionAchievementID)
        if completed then return 1, 1 end
    end

    local total, done = 0, 0
    local optionalTotal, optionalDone = 0, 0
    for i, q in ipairs(ch.quests) do
        if SM.IsQuestForPlayer(q) and not SM.ShouldHideQuest(q) then
            if q.optional then
                optionalTotal = optionalTotal + 1
                if SM.IsQuestEffectivelyComplete(i, ch.quests) then optionalDone = optionalDone + 1 end
            else
                total = total + 1
                if SM.IsQuestEffectivelyComplete(i, ch.quests) then done = done + 1 end
            end
        end
    end
    if total == 0 and optionalTotal > 0 then
        return optionalDone, optionalTotal
    end
    return done, total
end

function SM.GetCampaignProgress(data)
    local total, done = 0, 0
    for _, ch in ipairs(SM.GetAllChapters(data)) do
        for _, q in ipairs(ch.quests) do
            if not q.optional and SM.IsQuestForPlayer(q) and not SM.ShouldHideQuest(q) then
                total = total + 1
                if SM.IsQuestEntryComplete(q) then done = done + 1 end
            end
        end
    end

    local nextQuest = SM.FindNextQuest(data)
    if not nextQuest and total > 0 then
        done = total
    end
    return done, total
end

function SM.GetFirstUnmetChapterPrerequisite(ch)
    if not ch or not ch.prerequisites then return nil end
    for _, req in ipairs(ch.prerequisites) do
        if req.id and not SM.IsQuestComplete(req.id) and not SM.IsQuestInLog(req.id) then
            return req
        end
    end
    return nil
end

function SM.GetQuestLockReason(data, ch, questIndex)
    if not data or not ch then return nil end

    local playerLevel = UnitLevel("player") or 0
    if data.requiredLevel and playerLevel < data.requiredLevel then
        return string.format(L["Lock Required Level Format"], data.requiredLevel)
    end
    if ch.requiredLevel and playerLevel < ch.requiredLevel then
        return string.format(L["Lock Required Level Format"], ch.requiredLevel)
    end

    local unmetPrereq = SM.GetFirstUnmetChapterPrerequisite(ch)
    if unmetPrereq then
        local questName = unmetPrereq.name or string.format(L["Quest ID Format"], tostring(unmetPrereq.id))
        if unmetPrereq.npc and unmetPrereq.npc ~= "" then
            return string.format(L["Lock Pick Up Quest Format"], questName, unmetPrereq.npc)
        end
        return string.format(L["Lock Complete Quest Format"], questName)
    end

    if questIndex and questIndex > 1 then
        local prevQuest = ch.quests and ch.quests[questIndex - 1]
        if prevQuest and not SM.IsQuestEffectivelyComplete(questIndex - 1, ch.quests) then
            return string.format(L["Lock Complete Previous Quest Format"], prevQuest.name or string.format(L["Quest ID Format"], tostring(prevQuest.id)))
        end
    end

    return nil
end

function SM.GetQuestlineGateReason(data, ch)
    if not data then return nil end

    local playerLevel = UnitLevel("player") or 0
    if data.requiredLevel and playerLevel < data.requiredLevel then
        return string.format(L["Lock Required Level Format"], data.requiredLevel)
    end
    if ch and ch.requiredLevel and playerLevel < ch.requiredLevel then
        return string.format(L["Lock Required Level Format"], ch.requiredLevel)
    end

    return nil
end

function SM.FindNextQuest(data)
    local chapters = SM.GetAllChapters(data)
    local hasPrereqProgress = not data.prereqs

    if data.prereqs then
        for _, ch in ipairs(data.prereqs) do
            local d = SM.GetChapterProgress(ch)
            if d > 0 then hasPrereqProgress = true; break end
        end
    end

    local logCandidates = {}
    local readyCandidates = {}

    for chIdx, ch in ipairs(chapters) do
        -- Optional chapters remain visible in the track, but they do not keep
        -- the main story CTA from reaching "Story Finished".
        if not ch.optional then
            local unmetPrereq = SM.GetFirstUnmetChapterPrerequisite(ch)
            if unmetPrereq then
                readyCandidates[#readyCandidates + 1] = {
                    quest = {
                        id = unmetPrereq.id,
                        name = unmetPrereq.name,
                        npc = unmetPrereq.npc,
                        _isPrerequisiteForChapter = ch.chapter,
                    },
                    chapter = ch.chapter,
                    chapterData = ch,
                    section = ch._section or 1,
                    depth = 0,
                    order = chIdx,
                }
            else
                local chDone, chTotal = SM.GetChapterProgress(ch)
                if chDone < chTotal then
                    local section = ch._section or 1

                    for j, q in ipairs(ch.quests) do
                        if not SM.IsQuestForPlayer(q) then
                            -- skip opposing-faction variant
                        elseif SM.IsQuestEntryInLog(q) then
                            logCandidates[#logCandidates + 1] = {
                                quest = q, chapter = ch.chapter,
                                chapterData = ch,
                                section = section, depth = j, order = chIdx,
                            }
                            break
                        elseif not SM.IsQuestEffectivelyComplete(j, ch.quests) then
                            if j == 1 then
                                if section >= 2 and hasPrereqProgress then
                                    readyCandidates[#readyCandidates + 1] = {
                                        quest = q, chapter = ch.chapter,
                                        chapterData = ch,
                                        section = section, depth = j, order = chIdx,
                                    }
                                elseif section == 1 and chDone == 0 and not hasPrereqProgress then
                                    readyCandidates[#readyCandidates + 1] = {
                                        quest = q, chapter = ch.chapter,
                                        chapterData = ch,
                                        section = section, depth = j, order = chIdx,
                                    }
                                end
                                break
                            elseif SM.IsQuestEffectivelyComplete(j - 1, ch.quests) then
                                readyCandidates[#readyCandidates + 1] = {
                                    quest = q, chapter = ch.chapter,
                                    chapterData = ch,
                                    section = section, depth = j, order = chIdx,
                                }
                                break
                            else
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    local sectionHasProgress = {}
    for _, ch in ipairs(chapters) do
        local s = ch._section or 1
        if not sectionHasProgress[s] then
            local d = SM.GetChapterProgress(ch)
            if d > 0 then sectionHasProgress[s] = true end
        end
    end

    local lastCompleteOrder = {}
    for chIdx, ch in ipairs(chapters) do
        local d, t = SM.GetChapterProgress(ch)
        local s = ch._section or 1
        if d >= t and t > 0 then
            if not lastCompleteOrder[s] or chIdx > lastCompleteOrder[s] then
                lastCompleteOrder[s] = chIdx
            end
        end
    end

    table.sort(logCandidates, function(a, b)
        if a.section ~= b.section then return a.section > b.section end
        if a.depth ~= b.depth then return a.depth > b.depth end
        return a.order < b.order
    end)

    table.sort(readyCandidates, function(a, b)
        local aP = sectionHasProgress[a.section] and true or false
        local bP = sectionHasProgress[b.section] and true or false
        if aP ~= bP then return aP end
        if aP then
            if a.section ~= b.section then return a.section > b.section end
        else
            if a.section ~= b.section then return a.section < b.section end
        end
        if a.depth ~= b.depth then return a.depth > b.depth end

        local aLast = lastCompleteOrder[a.section] or 0
        local bLast = lastCompleteOrder[b.section] or 0
        local aAfter = a.order > aLast
        local bAfter = b.order > bLast
        if aAfter ~= bAfter then return aAfter end
        return a.order < b.order
    end)

    if #logCandidates > 0 then
        return logCandidates[1].quest, logCandidates[1].chapter, logCandidates[1].chapterData
    end
    if #readyCandidates > 0 then
        return readyCandidates[1].quest, readyCandidates[1].chapter, readyCandidates[1].chapterData
    end

    return nil, nil
end
