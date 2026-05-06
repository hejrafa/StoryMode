local addonName, SM = ...
local L = SM.L

local categories = {
    { name = "Epic Storylines", displayName = L["Category Epic Storylines"], questlines = {} },
    { name = "Character Stories", displayName = L["Category Character Stories"], questlines = {} },
    { name = "Short Stories", displayName = L["Category Short Stories"], questlines = {} },
    { name = "Identity", displayName = string.format(L["Category Identity Format"], UnitRace("player"), UnitClass("player")), questlines = {} },
    { name = "More Coming Soon", displayName = L["Category More Coming Soon"], disabled = true, questlines = {} },
}

local allQuestlines = {}
local questlinesByID = {}
local questLookupByID = {}
local questLookupByName = {}
local questlineSortOrder = 0

local _, playerClass = UnitClass("player")
local playerFaction = UnitFactionGroup("player")
local playerRace = select(2, UnitRace("player"))

local function SlugifyQuestlineID(text)
    text = tostring(text or ""):lower()
    text = text:gsub("[^a-z0-9]+", "-")
    text = text:gsub("^-+", ""):gsub("-+$", "")
    return text ~= "" and text or "story"
end

local function EnsureUniqueQuestlineID(data)
    local baseID = data.id or data.storyID or SlugifyQuestlineID(data.title or data.achievementName)
    local id = baseID
    local suffix = 2
    while questlinesByID[id] and questlinesByID[id] ~= data do
        id = baseID .. "-" .. suffix
        suffix = suffix + 1
    end
    data.id = id
    questlinesByID[id] = data
end

local function AssignStableQuestlineID(data)
    if data and not data.id and not data.storyID then
        data.id = SlugifyQuestlineID(data.title or data.achievementName)
    end
end

local function NormalizeQuestlineData(data)
    if not data or data._storyModeNormalized then return end
    EnsureUniqueQuestlineID(data)
    local chapters = SM.GetAllChapters(data)
    for chapterIndex, ch in ipairs(chapters) do
        ch._story = data
        ch._storyID = data.id
        ch._chapterIndex = chapterIndex
        ch._chapterKey = ch.chapter or tostring(chapterIndex)
        if ch.quests then
            for questIndex, q in ipairs(ch.quests) do
                q._story = data
                q._storyID = data.id
                q._chapter = ch
                q._chapterIndex = chapterIndex
                q._questIndex = questIndex
                q._questIDs = SM.GetQuestIDs(q)
                for _, questID in ipairs(q._questIDs) do
                    questLookupByID[questID] = { story = data, quest = q, chapter = ch }
                end
                if q.name and q.name ~= "" then
                    questLookupByName[q.name] = { story = data, quest = q, chapter = ch }
                end
            end
        end
    end
    data._storyModeNormalized = true
end

local function CanShowQuestline(data)
    if not data then return false end
    if not SM.IsContentAvailableForClient(data) then return false end
    if data.class and data.class ~= playerClass then return false end
    if data.faction and data.faction ~= playerFaction then return false end
    if data.race and data.race ~= playerRace then return false end
    return true
end

local function RegisterQuestline(data, categoryName)
    NormalizeQuestlineData(data)
    questlineSortOrder = questlineSortOrder + 1
    data._storyModeSortOrder = questlineSortOrder
    allQuestlines[#allQuestlines + 1] = data
    for _, cat in ipairs(categories) do
        if cat.name == categoryName then
            cat.questlines[#cat.questlines + 1] = data
            break
        end
    end
end

local function GetQuestlineSortLevel(data)
    return SM.GetRecommendedLevelMinimum(data) or math.huge
end

local function SortQuestlineCategories()
    for _, cat in ipairs(categories) do
        if cat.questlines and #cat.questlines > 1 then
            table.sort(cat.questlines, function(a, b)
                local aLevel = GetQuestlineSortLevel(a)
                local bLevel = GetQuestlineSortLevel(b)
                if aLevel ~= bLevel then
                    return aLevel < bLevel
                end
                return (a._storyModeSortOrder or 0) < (b._storyModeSortOrder or 0)
            end)
        end
    end
end

local function AddContentData(list, data)
    if data then list[#list + 1] = data end
end

function SM.GetQuestlineZoneText(data)
    if not data then return "" end
    if data.zoneByFaction then
        local factionZone = data.zoneByFaction[playerFaction]
        if factionZone and factionZone ~= "" then return factionZone end
    end
    return data.zone or ""
end

function SM.GetQuestlineByID(id)
    return id and questlinesByID[id] or nil
end

function SM.GetAllQuestlines()
    return allQuestlines
end

function SM.GetQuestlineCategories()
    return categories
end

local function IsLookupVisible(match)
    if not match then return false end
    return SM.IsQuestForPlayer(match.quest) and not SM.ShouldHideQuest(match.quest)
end

function SM.FindQuestStory(questID)
    if not questID then return nil end
    local match = questLookupByID[questID]
    if IsLookupVisible(match) then
        return match.story, match.quest, match.chapter
    end
    return nil
end

function SM.FindQuestStoryByName(questName)
    if not questName or questName == "" then return nil end
    local match = questLookupByName[questName]
    if IsLookupVisible(match) then
        return match.story, match.quest, match.chapter
    end
    return nil
end

function SM.LocalizeContentRegistry()
    local contentData = {}
    AddContentData(contentData, SM.FrozenThroneData)
    AddContentData(contentData, SM.DefiasBrotherhoodData)
    AddContentData(contentData, SM.ArugalData)
    AddContentData(contentData, SM.AlthalaxxData)
    AddContentData(contentData, SM.DuskwoodData)
    AddContentData(contentData, SM.RaenesCleansingData)
    AddContentData(contentData, SM.BattleOfHillsbradData)
    AddContentData(contentData, SM.FallenHeroData)
    AddContentData(contentData, SM.MissingDiplomatData)
    AddContentData(contentData, SM.OnyxiaData)
    AddContentData(contentData, SM.DungeonSetTwoData)
    AddContentData(contentData, SM.ScarletCrusadeData)
    AddContentData(contentData, SM.DarrowshireData)
    AddContentData(contentData, SM.ShiftingSandsData)
    AddContentData(contentData, SM.PrincessMoiraData)
    AddContentData(contentData, SM.TimbermawData)
    AddContentData(contentData, SM.JadeForestData)
    AddContentData(contentData, SM.SuramarData)
    AddContentData(contentData, SM.NazmirData)
    AddContentData(contentData, SM.RevendrethData)
    AddContentData(contentData, SM.DrustvarData)
    AddContentData(contentData, SM.SylvanasData)
    AddContentData(contentData, SM.JainaData)
    AddContentData(contentData, SM.LilianVossData)
    AddContentData(contentData, SM.TeddiesAndTeaData)
    AddContentData(contentData, SM.LinkenData)
    AddContentData(contentData, SM.AgamandFamilyData)
    AddContentData(contentData, SM.MankriksWifeData)
    AddContentData(contentData, SM.ClassicDruidQuestData)
    AddContentData(contentData, SM.ClassicHunterQuestData)
    AddContentData(contentData, SM.ClassicMageQuestData)
    AddContentData(contentData, SM.ClassicPaladinQuestData)
    AddContentData(contentData, SM.ClassicPriestQuestData)
    AddContentData(contentData, SM.ClassicRogueQuestData)
    AddContentData(contentData, SM.ClassicShamanQuestData)
    AddContentData(contentData, SM.ClassicWarlockQuestData)
    AddContentData(contentData, SM.ClassicWarriorQuestData)
    AddContentData(contentData, SM.DeathKnightCampaignData)
    AddContentData(contentData, SM.DemonHunterCampaignData)
    AddContentData(contentData, SM.DruidCampaignData)
    AddContentData(contentData, SM.HunterCampaignData)
    AddContentData(contentData, SM.MageCampaignData)
    AddContentData(contentData, SM.MonkCampaignData)
    AddContentData(contentData, SM.PaladinCampaignData)
    AddContentData(contentData, SM.PriestCampaignData)
    AddContentData(contentData, SM.RogueCampaignData)
    AddContentData(contentData, SM.ShamanCampaignData)
    AddContentData(contentData, SM.WarlockCampaignData)
    AddContentData(contentData, SM.WarriorCampaignData)
    AddContentData(contentData, SM.ForsakenHeritageData)
    AddContentData(contentData, SM.BloodElfHeritageData)
    AddContentData(contentData, SM.GoblinHeritageData)
    AddContentData(contentData, SM.TrollHeritageData)
    AddContentData(contentData, SM.OrcHeritageData)
    AddContentData(contentData, SM.TaurenHeritageData)
    AddContentData(contentData, SM.HumanHeritageData)
    AddContentData(contentData, SM.DwarfHeritageData)
    AddContentData(contentData, SM.GnomeHeritageData)
    AddContentData(contentData, SM.NightElfHeritageData)
    AddContentData(contentData, SM.WorgenHeritageData)
    AddContentData(contentData, SM.DraeneiHeritageData)
    AddContentData(contentData, SM.PandarenHeritageData)
    AddContentData(contentData, SM.DarkIronHeritageData)

    for _, data in ipairs(contentData) do
        AssignStableQuestlineID(data)
        SM.LocalizeContentData(data)
    end
end

function SM.RegisterQuestlines()
    local epicQuestlines = {
        SM.DefiasBrotherhoodData,
        SM.ArugalData,
        SM.AlthalaxxData,
        SM.DuskwoodData,
        SM.RaenesCleansingData,
        SM.BattleOfHillsbradData,
        SM.MissingDiplomatData,
        SM.ScarletCrusadeData,
        SM.DarrowshireData,
        SM.FallenHeroData,
        SM.OnyxiaData,
        SM.DungeonSetTwoData,
        SM.ShiftingSandsData,
        SM.PrincessMoiraData,
        SM.TimbermawData,
        SM.FrozenThroneData,
        SM.JadeForestData,
        SM.SuramarData,
        SM.NazmirData,
        SM.RevendrethData,
        SM.DrustvarData,
    }
    for _, data in ipairs(epicQuestlines) do
        if CanShowQuestline(data) then RegisterQuestline(data, "Epic Storylines") end
    end

    local characterQuestlines = { SM.SylvanasData, SM.JainaData, SM.LilianVossData }
    for _, data in ipairs(characterQuestlines) do
        if CanShowQuestline(data) then RegisterQuestline(data, "Character Stories") end
    end

    local shortQuestlines = { SM.TeddiesAndTeaData, SM.LinkenData, SM.AgamandFamilyData, SM.MankriksWifeData }
    for _, data in ipairs(shortQuestlines) do
        if CanShowQuestline(data) then RegisterQuestline(data, "Short Stories") end
    end

    local classCampaigns = {
        SM.ClassicDruidQuestData,
        SM.ClassicHunterQuestData,
        SM.ClassicMageQuestData,
        SM.ClassicPaladinQuestData,
        SM.ClassicPriestQuestData,
        SM.ClassicRogueQuestData,
        SM.ClassicShamanQuestData,
        SM.ClassicWarlockQuestData,
        SM.ClassicWarriorQuestData,
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
        if CanShowQuestline(data) then RegisterQuestline(data, "Identity") end
    end

    local heritageQuestlines = {
        SM.ForsakenHeritageData,
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
        if CanShowQuestline(data) then RegisterQuestline(data, "Identity") end
    end

    SortQuestlineCategories()
    if SM.InvalidateProgressCache then SM.InvalidateProgressCache() end
end

SM.LocalizeContentRegistry()
SM.RegisterQuestlines()
