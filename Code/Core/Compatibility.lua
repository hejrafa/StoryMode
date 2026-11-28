local addonName, SM = ...

_G.StoryMode = SM

local WOW_PROJECT_MAINLINE = _G.WOW_PROJECT_MAINLINE or 1
local WOW_PROJECT_CLASSIC = _G.WOW_PROJECT_CLASSIC or 2
local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5

local projectID = _G.WOW_PROJECT_ID or WOW_PROJECT_MAINLINE
local interfaceVersion = select(4, GetBuildInfo()) or 0

-- WoW Forever (project "Camelot", interface 16xxx) runs the Retail engine and
-- API with Classic-era content. isMainline covers Retail and Forever for API
-- and design paths; content checks use isRetail, isClassicEra, isTBC and
-- isForever directly.
local isForever = (_G.WOW_PROJECT_CAMELOT ~= nil and projectID == _G.WOW_PROJECT_CAMELOT)
    or (interfaceVersion >= 16000 and interfaceVersion < 17000)
local isClassicEra = not isForever and projectID == WOW_PROJECT_CLASSIC
local isTBC = not isForever and projectID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local isRetail = not isForever and projectID == WOW_PROJECT_MAINLINE
local isMainline = isRetail or isForever

local expansionLevels = {
    Classic = 0,
    ["The Burning Crusade"] = 1,
    ["Wrath of the Lich King"] = 2,
    Cataclysm = 3,
    ["Mists of Pandaria"] = 4,
    ["Warlords of Draenor"] = 5,
    Legion = 6,
    ["Battle for Azeroth"] = 7,
    Shadowlands = 8,
    Dragonflight = 9,
    ["The War Within"] = 10,
    Midnight = 11,
}

local maxExpansionLevel
if isClassicEra or isForever then
    maxExpansionLevel = expansionLevels.Classic
elseif isTBC then
    maxExpansionLevel = expansionLevels["The Burning Crusade"]
elseif GetExpansionLevel then
    maxExpansionLevel = GetExpansionLevel()
else
    maxExpansionLevel = expansionLevels["The War Within"]
end

SM.Client = {
    projectID = projectID,
    interfaceVersion = interfaceVersion,
    isRetail = isRetail,
    isForever = isForever,
    isMainline = isMainline,
    isClassicEra = isClassicEra,
    isTBC = isTBC,
    maxExpansionLevel = maxExpansionLevel,
}

-- Retail-style API and design: Retail and WoW Forever.
function SM.IsMainlineClient()
    return SM.Client and SM.Client.isMainline
end

function SM.IsClassicClient()
    return not SM.IsMainlineClient()
end

-- Fills the game's $Gmale:female; tokens for the player's character. Quest
-- text uses them, and so do the journal's translations in languages where
-- the narrator's gender changes the words (Russian "я пошёл" / "я пошла").
function SM.ApplyGenderTokens(text)
    if type(text) ~= "string" then return text end
    local female = UnitSex and UnitSex("player") == 3
    return (text:gsub("%$[Gg]([^:;]*):([^;]*);", function(maleForm, femaleForm)
        return female and femaleForm or maleForm
    end))
end

-- The text with its first letter capitalized. Story data writes places in
-- lower case ("the Altar of Zul, The Hinterlands") so chat lines can use them
-- mid-sentence; a line that starts with one capitalizes it. string.upper only
-- knows A to Z, so accented Latin and Cyrillic first letters are mapped here.
function SM.CapitalizeFirst(text)
    if type(text) ~= "string" or text == "" then return text end
    local a, b = text:byte(1, 2)
    if a >= 97 and a <= 122 then
        return string.char(a - 32) .. text:sub(2)
    end
    if not b then return text end
    if a == 0xC3 and b >= 0xA0 and b <= 0xBE and b ~= 0xB7 then
        b = b - 0x20                -- à to þ: À to Þ
    elseif a == 0xD0 and b >= 0xB0 and b <= 0xBF then
        b = b - 0x20                -- а to п: А to П
    elseif a == 0xD1 and b >= 0x80 and b <= 0x8F then
        a, b = 0xD0, b + 0x20       -- р to я: Р to Я
    elseif a == 0xD1 and b == 0x91 then
        a, b = 0xD0, 0x81           -- ё: Ё
    else
        return text
    end
    return string.char(a, b) .. text:sub(3)
end

-- A chapter's intro (summary) or journal entry (recap) for the player. Where
-- the Alliance and the Horde live a chapter differently, it keeps one for
-- each (summaryAlliance, recapHorde...) beside the shared one.
function SM.GetChapterText(chapter, field)
    if type(chapter) ~= "table" then return nil end
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    local text = (faction == "Alliance" or faction == "Horde") and chapter[field .. faction] or nil
    return SM.ApplyGenderTokens(text or chapter[field])
end

-- The gameVersions key that decides which stories this client shows. Forever
-- shows the Classic Era set unless a story sets gameVersions.forever itself.
function SM.IsForClientGameVersion(versions)
    if type(versions) ~= "table" then return nil end
    if isRetail then return versions.retail == true end
    if isTBC then return versions.tbc == true end
    if isClassicEra then return versions.classicEra == true end
    if isForever then
        if versions.forever ~= nil then return versions.forever == true end
        return versions.classicEra == true
    end
    return false
end

if not CopyTable then
    function CopyTable(source)
        if type(source) ~= "table" then return source end
        local copy = {}
        for key, value in pairs(source) do
            copy[key] = type(value) == "table" and CopyTable(value) or value
        end
        return copy
    end
end

if not CreateColor then
    function CreateColor(r, g, b, a)
        return {
            r = r,
            g = g,
            b = b,
            a = a == nil and 1 or a,
            GetRGBA = function(self)
                return self.r, self.g, self.b, self.a
            end,
        }
    end
end

if not GetAchievementInfo then
    function GetAchievementInfo(id)
        return nil
    end
end

if not GetAchievementNumCriteria then
    function GetAchievementNumCriteria(id)
        return 0
    end
end

if not GetAchievementCriteriaInfo then
    function GetAchievementCriteriaInfo(id, index)
        return nil
    end
end

function SM.LoadAddOn(addon)
    if C_AddOns and C_AddOns.LoadAddOn then
        return pcall(C_AddOns.LoadAddOn, addon)
    end
    if LoadAddOn then
        return pcall(LoadAddOn, addon)
    end
    return false
end

function SM.GetAchievementInfo(id)
    if GetAchievementInfo then
        return GetAchievementInfo(id)
    end
    return nil
end

function SM.GetAchievementNumCriteria(id)
    if GetAchievementNumCriteria then
        return GetAchievementNumCriteria(id)
    end
    return 0
end

function SM.GetAchievementCriteriaInfo(id, index)
    if GetAchievementCriteriaInfo then
        return GetAchievementCriteriaInfo(id, index)
    end
    return nil
end

function SM.IsQuestFlaggedCompleted(questID)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        return C_QuestLog.IsQuestFlaggedCompleted(questID)
    end
    if IsQuestFlaggedCompleted then
        return IsQuestFlaggedCompleted(questID)
    end
    return false
end

-- Where a quest the player is on sits in the quest log. Retail-engine
-- clients (Retail and WoW Forever) also keep hidden entries there, such as
-- tracking and system quests, and area tasks the player never accepted;
-- those aren't quests the player is on, so they don't count.
local function HiddenLogEntry(logIndex)
    if not (logIndex and C_QuestLog and C_QuestLog.GetInfo) then return false end
    local info = C_QuestLog.GetInfo(logIndex)
    return info ~= nil and (info.isHidden or info.isTask) and true or false
end

function SM.GetLogIndexForQuestID(questID)
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
        if HiddenLogEntry(logIndex) then return nil end
        return logIndex
    end
    if GetQuestLogIndexByID then
        local index = GetQuestLogIndexByID(questID)
        if index and index > 0 then return index end
    end
    return nil
end

-- Whether the quest log holds this quest only as a hidden entry or an area
-- task (see above): for /sm debug.
function SM.IsQuestHiddenInLog(questID)
    if not (C_QuestLog and C_QuestLog.GetLogIndexForQuestID) then return false end
    return HiddenLogEntry(C_QuestLog.GetLogIndexForQuestID(questID))
end

function SM.AddQuestWatch(questID)
    if C_QuestLog and C_QuestLog.AddQuestWatch then
        return C_QuestLog.AddQuestWatch(questID)
    end
    if AddQuestWatch then
        return AddQuestWatch(SM.GetLogIndexForQuestID(questID) or questID)
    end
end

-- Newer clients (WoW Forever, and retail since Midnight) leave the world map
-- to the player. Addon code may not open it (C_Map.OpenWorldMap is
-- restricted), and every pin the map places calls SetPassThroughButtons,
-- which is restricted too. When Story Mode opened the map and quest log
-- itself, the pins kept its taint, and a later click on one (a shift-click
-- to untrack, say) was blocked with "StoryMode has been blocked from an
-- action only available to the Blizzard UI". There Story Mode never opens
-- or draws on the map.
function SM.MapIsRestricted()
    return issecretvalue ~= nil
end

function SM.OpenQuestLogToQuest(questID)
    if SM.MapIsRestricted() then return false end
    local logIndex = SM.GetLogIndexForQuestID(questID)
    if not logIndex then return false end

    if QuestLog_OpenToQuest and pcall(QuestLog_OpenToQuest, questID) then
        return true
    end

    if C_QuestLog and C_QuestLog.SetSelectedQuest then
        pcall(C_QuestLog.SetSelectedQuest, questID)
    end
    if QuestMapFrame_OpenToQuestDetails and pcall(QuestMapFrame_OpenToQuestDetails, questID) then
        return true
    end

    if OpenQuestLog then
        pcall(OpenQuestLog)
    elseif QuestLogFrame and ShowUIPanel then
        ShowUIPanel(QuestLogFrame)
    elseif ToggleQuestLog then
        ToggleQuestLog()
    end

    if SelectQuestLogEntry then
        pcall(SelectQuestLogEntry, logIndex)
    end
    if QuestLog_SetSelection then
        pcall(QuestLog_SetSelection, logIndex)
    end
    if QuestLog_Update then
        pcall(QuestLog_Update)
    end
    return true
end

function SM.GetQuestObjectives(questID)
    if C_QuestLog and C_QuestLog.GetQuestObjectives then
        return C_QuestLog.GetQuestObjectives(questID)
    end
    local logIndex = SM.GetLogIndexForQuestID(questID)
    if not logIndex or not GetNumQuestLeaderBoards or not GetQuestLogLeaderBoard then
        return nil
    end

    local objectives = {}
    for index = 1, GetNumQuestLeaderBoards(logIndex) do
        local text, objectiveType, finished = GetQuestLogLeaderBoard(index, logIndex)
        objectives[#objectives + 1] = {
            text = text,
            type = objectiveType,
            finished = finished,
        }
    end
    return objectives
end

function SM.GetNumTrackingTypes()
    if C_Minimap and C_Minimap.GetNumTrackingTypes then
        return C_Minimap.GetNumTrackingTypes()
    end
    if GetNumTrackingTypes then
        return GetNumTrackingTypes()
    end
    return 0
end

function SM.GetTrackingInfo(index)
    if C_Minimap and C_Minimap.GetTrackingInfo then
        return C_Minimap.GetTrackingInfo(index)
    end
    if GetTrackingInfo then
        local name, texture, active, category, nested, spellID = GetTrackingInfo(index)
        return {
            name = name,
            texture = texture,
            active = active,
            category = category,
            nested = nested,
            spellID = spellID,
        }
    end
    return nil
end

function SM.SetTracking(index, enabled)
    if C_Minimap and C_Minimap.SetTracking then
        return C_Minimap.SetTracking(index, enabled)
    end
    if SetTracking then
        return SetTracking(index, enabled)
    end
end

function SM.GetFactionDataByID(factionID)
    if C_Reputation and C_Reputation.GetFactionDataByID then
        return C_Reputation.GetFactionDataByID(factionID)
    end
    if GetFactionInfoByID then
        local name, description, standingID, bottomValue, topValue, earnedValue, atWarWith,
            canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild,
            factionIDOut, hasBonusRepGain, canSetInactive = GetFactionInfoByID(factionID)
        if name then
            return {
                name = name,
                description = description,
                reaction = standingID,
                currentReactionThreshold = bottomValue,
                nextReactionThreshold = topValue,
                currentStanding = earnedValue,
                atWarWith = atWarWith,
                canToggleAtWar = canToggleAtWar,
                isHeader = isHeader,
                isCollapsed = isCollapsed,
                hasRep = hasRep,
                isWatched = isWatched,
                isChild = isChild,
                factionID = factionIDOut or factionID,
                hasBonusRepGain = hasBonusRepGain,
                canSetInactive = canSetInactive,
            }
        end
    end
    return nil
end

function SM.GetContentExpansionLevel(data)
    local expansion = data and data.expansion
    if type(expansion) ~= "string" then return nil end

    local best
    for name, level in pairs(expansionLevels) do
        if expansion:find(name, 1, true) and (not best or level < best) then
            best = level
        end
    end
    return best
end

function SM.IsContentAvailableForClient(data)
    if type(data) == "table" and type(data.gameVersions) == "table" then
        return SM.IsForClientGameVersion(data.gameVersions)
    end

    if isRetail then
        return true
    end

    local contentLevel = SM.GetContentExpansionLevel(data)
    return not contentLevel or contentLevel <= maxExpansionLevel
end

-- Primary professions by skill line, with the spells that teach each rank
-- (Apprentice to Master). Clients with GetProfessions (Retail and WoW
-- Forever) report the skill line itself; Classic and TBC know the spells,
-- and the skill list is the last resort, matched by the profession's name.
local professionRankSpells = {
    [164] = { 2018, 3100, 3538, 9785, 29844 },   -- Blacksmithing
    [165] = { 2108, 3104, 3811, 10662, 32549 },  -- Leatherworking
    [202] = { 4036, 4037, 4038, 12656, 30350 },  -- Engineering
}

local function GetSpellNameForClient(spellID)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(spellID) end
    if GetSpellInfo then return (GetSpellInfo(spellID)) end
    return nil
end

function SM.PlayerHasProfession(skillLine)
    if not skillLine then return false end
    if GetProfessions and GetProfessionInfo then
        local prof1, prof2 = GetProfessions()
        for _, index in pairs({ prof1, prof2 }) do
            if select(7, GetProfessionInfo(index)) == skillLine then return true end
        end
    end
    local spells = professionRankSpells[skillLine]
    if not spells then return false end
    if IsPlayerSpell then
        for _, spellID in ipairs(spells) do
            if IsPlayerSpell(spellID) then return true end
        end
    end
    local name = GetSpellNameForClient(spells[1])
    if name and GetNumSkillLines and GetSkillLineInfo then
        for i = 1, GetNumSkillLines() do
            local skillName, isHeader = GetSkillLineInfo(i)
            if not isHeader and skillName == name then return true end
        end
    end
    return false
end

-- Whether the player holds an item: in the bags, the bank (as far as the
-- client knows it) or worn.
function SM.PlayerHasItem(itemID)
    if not itemID then return false end
    local getCount = (C_Item and C_Item.GetItemCount) or GetItemCount
    local count = getCount and getCount(itemID, true)
    if count and count > 0 then return true end
    local isEquipped = (C_Item and C_Item.IsEquippedItem) or IsEquippedItem
    return isEquipped ~= nil and isEquipped(itemID) == true
end

-- Story data stores Retail uiMapIDs. WoW Forever keeps the Classic zone maps
-- (Elwynn Forest is 1429, not 37) and has no dungeon maps, so dungeon
-- locations have no Forever map and return nil.
local foreverMapIDs = {
    [1] = 1411,   -- Durotar
    [7] = 1412,   -- Mulgore
    [10] = 1413,  -- Northern Barrens -> The Barrens
    [14] = 1417,  -- Arathi Highlands
    [15] = 1418,  -- Badlands
    [17] = 1419,  -- Blasted Lands
    [18] = 1420,  -- Tirisfal Glades
    [21] = 1421,  -- Silverpine Forest
    [22] = 1422,  -- Western Plaguelands
    [23] = 1423,  -- Eastern Plaguelands
    [25] = 1424,  -- Hillsbrad Foothills
    [26] = 1425,  -- The Hinterlands
    [27] = 1426,  -- Dun Morogh
    [32] = 1427,  -- Searing Gorge
    [36] = 1428,  -- Burning Steppes
    [37] = 1429,  -- Elwynn Forest
    [42] = 1430,  -- Deadwind Pass
    [47] = 1431,  -- Duskwood
    [48] = 1432,  -- Loch Modan
    [49] = 1433,  -- Redridge Mountains
    [50] = 1434,  -- Northern Stranglethorn -> Stranglethorn Vale
    [224] = 1434, -- Stranglethorn Vale
    [210] = 1434, -- The Cape of Stranglethorn -> Stranglethorn Vale
    [51] = 1435,  -- Swamp of Sorrows
    [52] = 1436,  -- Westfall
    [56] = 1437,  -- Wetlands
    [57] = 1438,  -- Teldrassil
    [62] = 1439,  -- Darkshore
    [63] = 1440,  -- Ashenvale
    [64] = 1441,  -- Thousand Needles
    [65] = 1442,  -- Stonetalon Mountains
    [66] = 1443,  -- Desolace
    [69] = 1444,  -- Feralas
    [70] = 1445,  -- Dustwallow Marsh
    [71] = 1446,  -- Tanaris
    [76] = 1447,  -- Azshara
    [77] = 1448,  -- Felwood
    [78] = 1449,  -- Un'Goro Crater
    [80] = 1450,  -- Moonglade
    [81] = 1451,  -- Silithus
    [83] = 1452,  -- Winterspring
    [84] = 1453,  -- Stormwind City
    [85] = 1454,  -- Orgrimmar
    [87] = 1455,  -- Ironforge
    [88] = 1456,  -- Thunder Bluff
    [89] = 1457,  -- Darnassus
    [90] = 1458,  -- Undercity
    [199] = 1413, -- Southern Barrens -> The Barrens
}

-- Stories made for WoW Forever store its own uiMapIDs, all 1400 and up (its
-- Classic zones are 1411-1458, its new zones such as Zephras Isle later), so
-- those pass through. Retail uiMapIDs for Classic zones are all below 1400.
local FIRST_FOREVER_MAP_ID = 1400

local function ForeverMapID(mapID)
    return foreverMapIDs[mapID] or (mapID >= FIRST_FOREVER_MAP_ID and mapID or nil)
end

function SM.GetClientMapID(mapID)
    if not mapID or not isForever then return mapID end
    return ForeverMapID(mapID)
end

-- A copy of a data location with its map translated for this client, or nil
-- when this client has no map for it.
function SM.GetClientLocation(loc)
    if type(loc) ~= "table" or not loc.mapID or not isForever then return loc end
    local mapID = ForeverMapID(loc.mapID)
    if not mapID then return nil end
    local copy = {}
    for key, value in pairs(loc) do copy[key] = value end
    copy.mapID = mapID
    return copy
end

-- A quest line can name the ID WoW Forever uses for it (foreverId), where
-- Forever reworked a quest under a new ID. On Forever the line takes that ID
-- and keeps the Classic one in classicId. foreverOptional makes a quest
-- optional on Forever only: one Forever's server won't describe (/sm scan)
-- and no one has reported doing there, so its chapter can't stall on it.
local function ApplyForeverQuestID(quest)
    if type(quest) ~= "table" then return end
    if quest.foreverId and not quest.classicId then
        quest.classicId = quest.id
        quest.id = quest.foreverId
    end
    if quest.foreverOptional then quest.optional = true end
    ApplyForeverQuestID(quest.guidanceQuest)
    for _, guidanceQuest in ipairs(quest.guidanceQuests or {}) do
        ApplyForeverQuestID(guidanceQuest)
    end
end

-- A chapter with more to it on WoW Forever (Forever-only quests) keeps its
-- intro (summary) and journal entry (recap) for there in foreverText. They
-- replace the usual ones before the story is translated. Either one there
-- replaces all of the chapter's, faction versions included, so the usual
-- Alliance or Horde text can't outrank it.
local FOREVER_TEXT_FIELDS = { "summary", "recap" }
local function ApplyForeverChapterText(chapter)
    local text = chapter.foreverText
    if type(text) ~= "table" then return end
    for _, field in ipairs(FOREVER_TEXT_FIELDS) do
        local alliance, horde = field .. "Alliance", field .. "Horde"
        if text[field] or text[alliance] or text[horde] then
            chapter[field], chapter[alliance], chapter[horde] = text[field], text[alliance], text[horde]
        end
    end
end

function SM.ApplyClientQuestIDs(data)
    if not isForever or type(data) ~= "table" then return end
    ApplyForeverQuestID(data.startQuest)
    for _, section in ipairs({ data.prereqs or {}, data.chapters or {}, data.insurrection or {} }) do
        for _, chapter in ipairs(section) do
            ApplyForeverChapterText(chapter)
            for _, quest in ipairs(chapter.quests or {}) do
                ApplyForeverQuestID(quest)
            end
        end
    end
end

-- Quests that only exist on WoW Forever have no translations in Locales:
-- Blizzard publishes no localized names for them. On other locales they take
-- the game's own title once the client has it.
local pendingTitleQuests
local titleFrame

local function IsForeverOnly(quest)
    local versions = type(quest) == "table" and quest.gameVersions
    return type(versions) == "table" and versions.forever == true
        and not versions.classicEra and not versions.tbc and not versions.retail
end

function SM.UseClientQuestTitle(quest)
    if not isForever or not IsForeverOnly(quest) or not quest.id then return end
    if GetLocale() == "enUS" or not (C_QuestLog and C_QuestLog.GetTitleForQuestID) then return end
    local title = C_QuestLog.GetTitleForQuestID(quest.id)
    if title and title ~= "" then
        quest.name = title
        return
    end
    if not C_QuestLog.RequestLoadQuestByID then return end
    if not titleFrame then
        pendingTitleQuests = {}
        titleFrame = CreateFrame("Frame")
        titleFrame:RegisterEvent("QUEST_DATA_LOAD_RESULT")
        titleFrame:SetScript("OnEvent", function(_, _, questID, success)
            local waiting = pendingTitleQuests[questID]
            if not waiting then return end
            pendingTitleQuests[questID] = nil
            local loaded = success and C_QuestLog.GetTitleForQuestID(questID)
            if loaded and loaded ~= "" then
                for _, entry in ipairs(waiting) do entry.name = loaded end
            end
        end)
    end
    local waiting = pendingTitleQuests[quest.id]
    if not waiting then
        waiting = {}
        pendingTitleQuests[quest.id] = waiting
        C_QuestLog.RequestLoadQuestByID(quest.id)
    end
    waiting[#waiting + 1] = quest
end

-- Whether a secure button's macro can use /run. WoW Forever turns user
-- scripts off with a game rule (UserScriptsDisabled), and /run then does
-- nothing, so buttons that rely on it need a plain click there.
function SM.CanRunMacroScripts()
    if C_AddOns and C_AddOns.GetScriptsDisallowedForBeta and C_AddOns.GetScriptsDisallowedForBeta() then
        return false
    end
    local rules = Enum and Enum.GameRule
    if C_GameRules and C_GameRules.IsGameRuleActive and rules and rules.UserScriptsDisabled then
        local ok, active = pcall(C_GameRules.IsGameRuleActive, rules.UserScriptsDisabled)
        if ok and active then return false end
    end
    return true
end

-- WoW Forever's gamepad UI moves a cursor between the buttons of the windows
-- its frame controls manager knows about: A clicks, B clicks the window's
-- CloseButton, the right stick scrolls. Blizzard's windows join through
-- ShowUIPanel; ours opens with Show(), so it tells the manager itself, and
-- smart navigation then finds its buttons on its own. The manager refuses
-- addon calls in combat, so a close in combat is passed on once it ends.
local gamepadShownFrames = {}
local gamepadPendingHides = {}
local gamepadEvents

local function GamepadCallsBlocked()
    if InCombatLockdown() then return true end
    local restrictions = C_RestrictedActions
    if restrictions and restrictions.IsAddOnRestrictionActive and Enum.AddOnRestrictionType then
        return restrictions.IsAddOnRestrictionActive(Enum.AddOnRestrictionType.Combat) and true or false
    end
    return false
end

local function GamepadFrameManager()
    return GamepadMode and GamepadMode.FrameControlsManager
end

local function GamepadUIEnabled()
    return GamepadFrameManager() and InputUtil and InputUtil.IsGamepadUIEnabled
        and InputUtil.IsGamepadUIEnabled() and true or false
end

local function FlushGamepadHides()
    if GamepadCallsBlocked() then return end
    gamepadEvents:UnregisterEvent("PLAYER_REGEN_ENABLED")
    local manager = GamepadFrameManager()
    for frame in pairs(gamepadPendingHides) do
        gamepadPendingHides[frame] = nil
        if frame:IsShown() then
            gamepadShownFrames[frame] = true  -- reopened in combat: the manager still has it
        elseif manager then
            manager:FrameHidden(frame)
        end
    end
end

function SM.GamepadFrameShown(frame)
    if not GamepadUIEnabled() or GamepadCallsBlocked() then return end
    gamepadPendingHides[frame] = nil
    gamepadShownFrames[frame] = true
    GamepadFrameManager():FrameShown(frame)
end

function SM.GamepadFrameHidden(frame)
    if not gamepadShownFrames[frame] then return end
    gamepadShownFrames[frame] = nil
    local manager = GamepadFrameManager()
    if not manager then return end
    if GamepadCallsBlocked() then
        gamepadPendingHides[frame] = true
        if not gamepadEvents then
            gamepadEvents = CreateFrame("Frame")
            gamepadEvents:SetScript("OnEvent", FlushGamepadHides)
        end
        gamepadEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    manager:FrameHidden(frame)
end
