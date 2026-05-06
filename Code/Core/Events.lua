local addonName, SM = ...
local L = SM.L

local eventFrame
local chapterCompletionCache = {}
local storylineCompletionCache = {}

local function ChapterFlagKey(data, chapter)
    return (data and data.id or data and data.title or "") .. "|" .. (chapter and chapter.chapter or "")
end

local function StoryFlagKey(data)
    return data and (data.id or data.title) or ""
end

local function InvalidateProgress()
    if SM.InvalidateProgressCache then SM.InvalidateProgressCache() end
end

local function RefreshVisibleStoryList(data)
    if SM.RefreshStoryListState then SM.RefreshStoryListState(data) end
end

function SM.GetQuestAcceptedMessageQuestName(message)
    if not message or not ERR_QUEST_ACCEPTED_S then return nil end

    local pattern = ERR_QUEST_ACCEPTED_S:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    pattern = pattern:gsub("%%%%s", "(.+)")
    return message:match("^" .. pattern .. "$")
end

function SM.QuestAcceptedSystemMessageFilter(_, _, message)
    local questName = SM.GetQuestAcceptedMessageQuestName(message)
    if questName and SM.FindQuestStoryByName(questName) then
        return true
    end
    return false
end

function SM.RegisterQuestAcceptedSystemMessageFilter()
    if SM.questAcceptedSystemMessageFilterRegistered then return end
    if ChatFrame_AddMessageEventFilter then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SM.QuestAcceptedSystemMessageFilter)
        SM.questAcceptedSystemMessageFilterRegistered = true
    end
end

function SM.PrintQuestAcceptedStory(questID)
    local data, quest = SM.FindQuestStory(questID)
    if data and data.title and data.title ~= "" and quest and quest.name then
        print(L["Addon Prefix"] .. string.format(L["Quest Accepted Story Format"], "|cffffd200" .. quest.name .. "|r", "|cffffd200" .. data.title .. "|r"))
    end
end

function SM.CheckQuestCompletion(completedQuestID)
    local data, quest, chapter = SM.FindQuestStory(completedQuestID)
    if not (data and quest and chapter) then return end

    local questName = quest.name
    local questNpc = quest.npc

    C_Timer.After(0.1, function()
        InvalidateProgress()
        if SM.RefreshCurrentStoryDetail then
            SM.RefreshCurrentStoryDetail(data)
        end

        local done, total = SM.GetChapterProgress(chapter)
        local isChapterDone = done >= total and total > 0
        local chapterKey = ChapterFlagKey(data, chapter)
        local storyKey = StoryFlagKey(data)
        local storyDone = SM.IsStoryFinished(data)

        if isChapterDone and not chapterCompletionCache[chapterKey] then
            chapterCompletionCache[chapterKey] = true

            if storyDone then
                RefreshVisibleStoryList(data)
            end

            C_Timer.After(1.5, function()
                if SM.ShowStoryBanner then
                    SM.ShowStoryBanner(L["Banner Chapter Complete"], chapter.chapter, data, questNpc, true)
                end
            end)

            if storyDone and not storylineCompletionCache[storyKey] then
                storylineCompletionCache[storyKey] = true
                C_Timer.After(6.5, function()
                    if SM.ShowStoryComplete then SM.ShowStoryComplete(data.title) end
                end)
            end
        else
            C_Timer.After(1.0, function()
                if SM.ShowStoryBanner then
                    SM.ShowStoryBanner(data.title, questName, data, questNpc, true)
                end
            end)
        end
    end)
end

function SM.PrimeCompletionCaches()
    wipe(chapterCompletionCache)
    wipe(storylineCompletionCache)
    for _, data in ipairs(SM.GetAllQuestlines()) do
        for _, chapter in ipairs(SM.GetAllChapters(data)) do
            local done, total = SM.GetChapterProgress(chapter)
            if done >= total and total > 0 then
                chapterCompletionCache[ChapterFlagKey(data, chapter)] = true
            end
        end
        if SM.IsStoryFinished(data) then
            storylineCompletionCache[StoryFlagKey(data)] = true
        end
    end
end

local function FirstQuestline()
    local questlines = SM.GetAllQuestlines()
    return questlines and questlines[1] or nil
end

function SM.InitializeSlashCommands()
    SLASH_STORYMODE1 = "/sm"
    SLASH_STORYMODE2 = "/storymode"
    SlashCmdList["STORYMODE"] = function(msg)
        msg = msg and msg:trim():lower() or ""
        if msg == "loadingscreens" or msg == "loading" or msg == "covers" then
            SM.ShowLoadingScreenBrowser()
            return
        elseif msg == "banner" then
            local data = FirstQuestline()
            if data then
                SM.ShowStoryBanner(data.title, L["Slash Test Quest Name"], data, nil, true)
            else
                print(L["Addon Legacy Prefix"] .. L["Slash No Questline Data"])
            end
            return
        elseif msg == "chapter" then
            local data = FirstQuestline()
            if data then
                local ch = SM.GetAllChapters(data)[1]
                SM.ShowStoryBanner(L["Banner Chapter Complete"], ch and ch.chapter or data.title, data, nil, true)
            else
                print(L["Addon Legacy Prefix"] .. L["Slash No Questline Data"])
            end
            return
        elseif msg == "complete" then
            local data = FirstQuestline()
            if data then
                SM.ShowStoryComplete(data.title)
            else
                print(L["Addon Legacy Prefix"] .. L["Slash No Questline Data"])
            end
            return
        elseif msg == "track" or msg == "next" then
            -- Slash commands execute in an insecure Lua context; the in-UI
            -- Continue Story button remains the preferred waypoint path.
            for _, data in ipairs(SM.GetAllQuestlines()) do
                local quest, chapter = SM.FindNextQuest(data)
                if quest then
                    local result = SM.SetWaypointForQuest(data, quest)
                    local cr, cg, cb = unpack(data.color or { 1, 0.82, 0 })
                    local hex = SM.HexColor(cr, cg, cb)
                    print(L["Addon Legacy Prefix"] .. "|cff" .. hex .. data.title .. " - " .. chapter .. "|r")
                    SM.PrintTrackResult(result, quest, data)
                    return
                end
            end
            print(L["Addon Legacy Prefix"] .. L["Slash All Complete"])
        elseif msg:match("^debug") then
            local filter = msg:match("^debug%s+(.+)$")
            local found = false
            for _, data in ipairs(SM.GetAllQuestlines()) do
                if not filter or data.title:lower():find(filter, 1, true) then
                    found = true
                    print(L["Addon Debug Prefix"] .. data.title)
                    for _, ch in ipairs(SM.GetAllChapters(data)) do
                        if ch.quests then
                            local chDone, chTotal = SM.GetChapterProgress(ch)
                            print(string.format("  |cffaaaaaa[%s]|r %d/%d", ch.chapter or "?", chDone, chTotal))
                            for j, q in ipairs(ch.quests) do
                                local inLog = SM.IsQuestEntryInLog(q)
                                local flagged = SM.IsQuestEntryComplete(q)
                                local effective = SM.IsQuestEffectivelyComplete(j, ch.quests)
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
                print(L["Addon Legacy Prefix"] .. string.format(L["Slash No Match Format"], filter or ""))
            end
        else
            SM.ToggleStoryModeFrame()
        end
    end
end

function SM.InitializeCoreEvents(storyFrame)
    if eventFrame then return end
    eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("QUEST_ACCEPTED")
    eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
    eventFrame:RegisterEvent("QUEST_TURNED_IN")
    eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    eventFrame:RegisterEvent("PLAYER_LOGIN")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:SetScript("OnEvent", function(_, event, arg1, arg2)
        if event == "PLAYER_REGEN_DISABLED" then
            if storyFrame and storyFrame:IsShown() then storyFrame:Hide() end
            return
        end
        if event == "ADDON_LOADED" and arg1 == addonName then
            SM.ApplySavedVariableDefaults()
            InvalidateProgress()
            if SM.MinimapButton_Init then SM.MinimapButton_Init() end
            SM.RegisterQuestAcceptedSystemMessageFilter()
            SM.PrimeCompletionCaches()
        elseif event == "PLAYER_LOGIN" then
            if SM.RegisterQuestlines then SM.RegisterQuestlines() end
            InvalidateProgress()
            SM.PrimeCompletionCaches()
            RefreshVisibleStoryList()
        elseif event == "QUEST_TURNED_IN" then
            InvalidateProgress()
            SM.CheckQuestCompletion(arg1)
        elseif event == "QUEST_ACCEPTED" then
            InvalidateProgress()
            local data = SM.FindQuestStory(arg2 or arg1)
            SM.PrintQuestAcceptedStory(arg2 or arg1)
            RefreshVisibleStoryList(data)
        elseif event == "QUEST_LOG_UPDATE" then
            InvalidateProgress()
            if SM.DebounceTask then
                SM.DebounceTask("quest-log-update-refresh", 0.05, RefreshVisibleStoryList)
            else
                RefreshVisibleStoryList()
            end
        elseif event == "PLAYER_LEVEL_UP" then
            InvalidateProgress()
            RefreshVisibleStoryList()
        end
    end)
end
