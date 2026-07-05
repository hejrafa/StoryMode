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

local SCARLET_REVEAL_THRESHOLD = 100
local SCARLET_VOSS_THRESHOLD = 1000
local SCARLET_WHISPERS = { [25] = true, [50] = true, [75] = true }
SM.ScarletCapstoneThreshold = 5000

-- CLEU destName arrives localized, so the tally gate needs per-locale name
-- fragments (plain find, case-sensitive). ruRU lists the adjective declensions
-- of "Алый орден"; the Romance locales use lowercase-safe substrings.
local SCARLET_NAME_FRAGMENTS = {
    deDE = { "Scharlach" },
    esES = { "scarlata" },
    esMX = { "scarlata" },
    ptBR = { "scarlate" },
    frFR = { "carlate" },
    ruRU = { "Алый", "Алая", "Алое", "Алого", "Алой", "Алому", "Алым", "Алых", "Алые" },
    koKR = { "진홍" },
    zhCN = { "血色" },
    zhTW = { "血色" },
}
local scarletNameFragments = SCARLET_NAME_FRAGMENTS[GetLocale and GetLocale() or ""] or { "Scarlet" }

function SM.IsScarletMobName(name)
    if not name or name == "" then return false end
    for _, fragment in ipairs(scarletNameFragments) do
        if name:find(fragment, 1, true) then return true end
    end
    return false
end

local function RefreshScarletStoryViews()
    InvalidateProgress()
    RefreshVisibleStoryList()
    if SM.RefreshCurrentStoryDetail then
        local currentData = SM.GetCurrentStoryData and SM.GetCurrentStoryData() or nil
        if currentData then SM.RefreshCurrentStoryDetail(currentData) end
    end
end

local function PrintScarletRevealChatLink()
    if not SM.GetScarletTabChatLink then return end
    print(L["Addon Prefix"] .. string.format(L["Scarlet Reveal Chat Format"], SM.GetScarletTabChatLink()))
end

local function HandleScarletCombatEvent()
    if not CombatLogGetCurrentEventInfo then return end
    local _, subevent, _, sourceGUID, _, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
    if subevent ~= "PARTY_KILL" then return end
    if not destName or destName == "" then return end

    local playerGUID = UnitGUID("player")
    local petGUID = UnitGUID("pet")
    if sourceGUID ~= playerGUID and (not petGUID or sourceGUID ~= petGUID) then return end

    -- Only NPCs feed the ledger: without this, battleground kills on players
    -- named "Scarlett" (or renamed enemy pets) would count toward the secret.
    local guidType = destGUID and destGUID:match("^(%a+)")
    if guidType ~= "Creature" and guidType ~= "Vehicle" then return end

    -- Named Crusade figures (Herod, Whitemane, ...) don't all carry "Scarlet"
    -- in their name, so the ledger check runs before the tally gate.
    if SM.GetScarletNamedTargetKey and SM.RecordScarletNamedKill then
        local npcID = tonumber(select(6, strsplit("-", destGUID)) or nil)
        local key = SM.GetScarletNamedTargetKey(npcID, destName)
        if key and SM.RecordScarletNamedKill(key) and SM.IsScarletCrusaderRevealed() then
            print("|cffff8040" .. L["Scarlet Ledger " .. key] .. "|r")
            local fallenName = destName
            C_Timer.After(1.5, function()
                if SM.ShowStoryBanner then
                    SM.ShowStoryBanner(L["Scarlet Named Banner Header"], fallenName, nil, nil, true)
                end
            end)
        end
    end

    if not SM.IsScarletMobName(destName) then return end
    if not SM.IncrementScarletKillCount then return end
    local count = SM.IncrementScarletKillCount()

    if SCARLET_WHISPERS[count] and not SM.IsScarletCrusaderRevealed() then
        print("|cffff8040" .. L["Scarlet Whisper " .. count] .. "|r")
    end

    if count >= SCARLET_REVEAL_THRESHOLD and not SM.IsScarletCrusaderRevealed() then
        SM.SetScarletCrusaderRevealed()
        if SM.ShowStoryBanner then
            SM.ShowStoryBanner(L["Scarlet Crusader Reveal Header"], L["Scarlet Crusader Reveal Title"], nil, nil, true)
        end
        PrintScarletRevealChatLink()
        RefreshScarletStoryViews()
    end

    if count >= SCARLET_VOSS_THRESHOLD and SM.IsScarletCrusaderRevealed()
        and SM.IsScarletVossBannerShown and not SM.IsScarletVossBannerShown() then
        SM.SetScarletVossBannerShown()
        if SM.ShowStoryBanner then
            SM.ShowStoryBanner(L["Scarlet Voss Banner Header"], L["Scarlet Voss Banner Title"], nil, nil, true)
        end
    end

    if count >= SM.ScarletCapstoneThreshold and SM.IsScarletCrusaderRevealed()
        and SM.IsScarletCapstoneBannerShown and not SM.IsScarletCapstoneBannerShown() then
        SM.SetScarletCapstoneBannerShown()
        if SM.ShowStoryBanner then
            SM.ShowStoryBanner(L["Scarlet Capstone Banner Header"], L["Scarlet Capstone Banner Title"], nil, nil, true)
        end
    end
end

function SM.GetQuestAcceptedMessageQuestID(message)
    local questID = message and message:match("|Hquest:(%d+)")
    return questID and tonumber(questID) or nil
end

function SM.NormalizeQuestAcceptedMessageQuestName(questName)
    if not questName or questName == "" then return nil end

    questName = questName:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    questName = questName:gsub("|H.-|h%[(.-)%]|h", "%1")
    questName = questName:gsub("|H.-|h(.-)|h", "%1")
    questName = questName:match("^%[(.+)%]$") or questName
    questName = questName:match("^%s*(.-)%s*$")

    if questName == "" then return nil end
    return questName
end

function SM.GetQuestAcceptedMessageQuestName(message)
    if not message or not ERR_QUEST_ACCEPTED_S then return nil end

    local pattern = ERR_QUEST_ACCEPTED_S:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    pattern = pattern:gsub("%%%%s", "(.+)")
    return SM.NormalizeQuestAcceptedMessageQuestName(message:match("^" .. pattern .. "$"))
end

function SM.ShouldSuppressQuestAcceptedSystemMessage(message)
    local questID = SM.GetQuestAcceptedMessageQuestID(message)
    if questID and SM.FindQuestStory(questID) then
        return true
    end

    local questName = SM.GetQuestAcceptedMessageQuestName(message)
    if questName and SM.FindQuestStoryByName(questName) then
        return true
    end
    return false
end

function SM.QuestAcceptedSystemMessageFilter(_, _, message, ...)
    if SM.ShouldSuppressQuestAcceptedSystemMessage(message) then
        return true
    end
    return false, message, ...
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
        print(L["Addon Prefix"] .. string.format(L["Quest Accepted Story Format"], SM.GetQuestChatLink(quest, quest.name), "|cffffd200" .. data.title .. "|r"))
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
        elseif msg:match("^scarlet") then
            local arg = msg:match("^scarlet%s+(.-)%s*$")
            local nameKey = arg and arg:match("^name%s+(%S+)$")
            if nameKey then
                if nameKey == "all" then
                    for _, target in ipairs(SM.ScarletNamedTargets or {}) do
                        SM.RecordScarletNamedKill(target.key)
                    end
                    RefreshScarletStoryViews()
                    print(L["Addon Debug Prefix"] .. "All named Scarlet kills recorded")
                    return
                end
                for _, target in ipairs(SM.ScarletNamedTargets or {}) do
                    if target.key:lower() == nameKey then
                        local isNew = SM.RecordScarletNamedKill(target.key)
                        RefreshScarletStoryViews()
                        if isNew and SM.IsScarletCrusaderRevealed() then
                            print("|cffff8040" .. L["Scarlet Ledger " .. target.key] .. "|r")
                            SM.ShowStoryBanner(L["Scarlet Named Banner Header"], L[target.name], nil, nil, true)
                        else
                            print(L["Addon Debug Prefix"] .. "Recorded named kill: " .. target.key)
                        end
                        return
                    end
                end
                local keys = {}
                for _, target in ipairs(SM.ScarletNamedTargets or {}) do
                    keys[#keys + 1] = target.key:lower()
                end
                print(L["Addon Debug Prefix"] .. "Unknown name. Keys: all, " .. table.concat(keys, ", "))
                return
            end
            if arg == "reset" then
                SM.ResetScarletState()
                RefreshScarletStoryViews()
                print(L["Addon Debug Prefix"] .. "Scarlet state reset (count, reveal, ledger)")
                return
            elseif arg == "hidden" then
                SM.SetScarletCrusaderHidden()
                RefreshScarletStoryViews()
                print(L["Addon Debug Prefix"] .. "Scarlet Crusader tab hidden (count and ledger kept)")
                return
            elseif arg == "reveal" then
                if not SM.IsScarletCrusaderRevealed() then
                    SM.SetScarletCrusaderRevealed()
                    SM.ShowStoryBanner(L["Scarlet Crusader Reveal Header"], L["Scarlet Crusader Reveal Title"], nil, nil, true)
                    PrintScarletRevealChatLink()
                    RefreshScarletStoryViews()
                    print(L["Addon Debug Prefix"] .. "Scarlet Crusader tab revealed")
                else
                    print(L["Addon Debug Prefix"] .. "Scarlet Crusader already revealed")
                end
                return
            elseif tonumber(arg) then
                SM.SetScarletKillCount(tonumber(arg))
                print(L["Addon Debug Prefix"] .. "Scarlet count set to " .. SM.GetScarletKillCount())
                return
            end
            -- The secret keeps its own counsel: no tally for the unrevealed.
            if SM.IsScarletCrusaderRevealed() then
                print(L["Addon Prefix"] .. string.format(L["Scarlet Crusader Note Format"], SM.GetScarletKillCount()))
            else
                print(L["Addon Prefix"] .. L["Scarlet Command Unrevealed"])
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
                                print(string.format("    %s %s", tag, SM.GetQuestChatLink(q, q.name) or "?"))
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
    -- The Scarlet secret lives where its host story lives: on clients where
    -- The Scarlet Crusade isn't registered (e.g. retail), never count kills —
    -- otherwise the reveal would announce a tab that cannot exist.
    if SM.ScarletCrusadeData and SM.IsContentAvailableForClient
        and SM.IsContentAvailableForClient(SM.ScarletCrusadeData) then
        eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
    eventFrame:SetScript("OnEvent", function(_, event, arg1, arg2)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            HandleScarletCombatEvent()
            return
        end
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
