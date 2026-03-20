local addonName, SM = ...

-- ============================================================================
-- Saved Variables
-- ============================================================================

local defaults = {
    version = "0.1.0",
}

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
        for _, ch in ipairs(data.prereqs) do all[#all + 1] = ch end
    end
    if data.chapters then
        for _, ch in ipairs(data.chapters) do all[#all + 1] = ch end
    end
    if data.insurrection then
        for _, ch in ipairs(data.insurrection) do all[#all + 1] = ch end
    end
    return all
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

local function GetChapterProgress(ch)
    local total, done = 0, 0
    for _, q in ipairs(ch.quests) do
        total = total + 1
        if IsQuestComplete(q.id) then done = done + 1 end
    end
    return done, total
end

-- Smart next quest: find the latest chapter with progress, then the first
-- incomplete quest in it. If that chapter is done, move to the next one.
-- Also checks if any quest is currently in the quest log (actively being done).
local function FindNextQuest(data)
    local chapters = GetAllChapters(data)

    -- First pass: check if any quest is in the log right now — that's the active one
    for _, ch in ipairs(chapters) do
        for _, q in ipairs(ch.quests) do
            if IsQuestInLog(q.id) then
                return q, ch.chapter
            end
        end
    end

    -- Second pass: find the latest chapter that has at least one completed quest
    local activeChapterIdx = nil
    for i, ch in ipairs(chapters) do
        local done, total = GetChapterProgress(ch)
        if done > 0 and done < total then
            -- Chapter in progress — this is the active one
            activeChapterIdx = i
        elseif done == total and total > 0 then
            -- Chapter complete — the next one might be active
            activeChapterIdx = i + 1
        end
    end

    -- Start from the active chapter (or chapter 1 if nothing started)
    local startIdx = activeChapterIdx or 1
    for i = startIdx, #chapters do
        local ch = chapters[i]
        for _, q in ipairs(ch.quests) do
            if not IsQuestComplete(q.id) then
                return q, ch.chapter
            end
        end
    end

    return nil, nil
end

local TRACK_SUPERTRACKED = "supertracked"
local TRACK_MAP_PIN      = "map_pin"
local TRACK_WAYPOINT     = "waypoint"
local TRACK_NO_LOCATION  = "no_location"

local function SetWaypointForQuest(data, quest)
    if not quest then return TRACK_NO_LOCATION end

    if IsQuestInLog(quest.id) then
        C_QuestLog.AddQuestWatch(quest.id)
        C_SuperTrack.SetSuperTrackedQuestID(quest.id)
        return TRACK_SUPERTRACKED
    end

    if Enum.SuperTrackingMapPinType and Enum.SuperTrackingMapPinType.QuestOffer then
        C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.QuestOffer, quest.id)
        return TRACK_MAP_PIN
    end

    local loc = data.npcLocations and data.npcLocations[quest.npc]
    if loc and C_Map.CanSetUserWaypointOnMap(loc.mapID) then
        local point = UiMapPoint.CreateFromCoordinates(loc.mapID, loc.x, loc.y)
        C_Map.SetUserWaypoint(point)
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        return TRACK_WAYPOINT
    end

    return TRACK_NO_LOCATION
end

local function PrintTrackResult(result, quest, data)
    if result == TRACK_SUPERTRACKED then
        print("|cff64b5f6StoryMode:|r Tracking: " .. quest.name)
    elseif result == TRACK_MAP_PIN then
        print("|cff64b5f6StoryMode:|r Tracking quest: |cffffd200" .. quest.name .. "|r — follow the navigation arrow.")
    elseif result == TRACK_WAYPOINT then
        print("|cff64b5f6StoryMode:|r Waypoint set for |cffffd200" .. quest.npc .. "|r — open your map to see it.")
    else
        print("|cff64b5f6StoryMode:|r Next: " .. quest.name .. " from |cffffd200" .. quest.npc .. "|r")
    end
end

-- ============================================================================
-- UI Helpers
-- ============================================================================

local SOLID = "Interface\\Buttons\\WHITE8x8"

local function HexColor(r, g, b)
    return string.format("%02x%02x%02x",
        math.min(255, math.floor(r * 255)),
        math.min(255, math.floor(g * 255)),
        math.min(255, math.floor(b * 255)))
end

-- ============================================================================
-- Settings Panel
-- ============================================================================

local settingsPanel = CreateFrame("Frame", "StoryModeSettingsPanel")
settingsPanel.name = "StoryMode"

local scrollFrame = CreateFrame("ScrollFrame", nil, settingsPanel, "ScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 0, 0)
scrollFrame:SetPoint("BOTTOMRIGHT", -24, 0)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetWidth(600)
scrollFrame:SetScrollChild(scrollChild)

settingsPanel:SetScript("OnSizeChanged", function(_, w)
    scrollChild:SetWidth(w - 24)
end)

-- ============================================================================
-- Questline Cards
-- ============================================================================

local CARD_GAP   = 14
local PAD        = 14
local ICON_SZ    = 40
local BAR_H      = 5

local allCards   = {}
local questlines = {}

local function RegisterQuestline(data)
    questlines[#questlines + 1] = data
end

local function CreateQuestlineCard(parent, data)
    local cr, cg, cb = unpack(data.color or { 0.50, 0.40, 0.30 })
    local hexC = HexColor(cr, cg, cb)

    -- ================================================================
    -- Card: subtle dark backdrop with colored left accent
    -- ================================================================
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetBackdrop({
        bgFile   = SOLID,
        edgeFile = SOLID,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    card:SetBackdropColor(0.08, 0.08, 0.08, 0.80)
    card:SetBackdropBorderColor(0.22, 0.22, 0.22, 0.80)

    -- Left color accent strip
    local accent = card:CreateTexture(nil, "ARTWORK", nil, 7)
    accent:SetTexture(SOLID)
    accent:SetVertexColor(cr, cg, cb, 1.0)
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("BOTTOMLEFT", 1, 1)
    accent:SetWidth(3)

    -- ================================================================
    -- Row 1: Icon + Title + Expansion tag (right-aligned)
    -- ================================================================
    local iconTex = card:CreateTexture(nil, "ARTWORK")
    iconTex:SetSize(ICON_SZ, ICON_SZ)
    iconTex:SetPoint("TOPLEFT", PAD + 4, -PAD)
    iconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local iconBorder = card:CreateTexture(nil, "OVERLAY")
    iconBorder:SetPoint("TOPLEFT", iconTex, "TOPLEFT", -2, 2)
    iconBorder:SetPoint("BOTTOMRIGHT", iconTex, "BOTTOMRIGHT", 2, -2)
    iconBorder:SetAtlas("ChallengeMode-ItemBorder")

    local titleText = card:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    titleText:SetPoint("TOPLEFT", iconTex, "TOPRIGHT", 10, -2)
    titleText:SetPoint("RIGHT", card, "RIGHT", -80, 0)
    titleText:SetJustifyH("LEFT")

    local expTag = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    expTag:SetPoint("RIGHT", card, "RIGHT", -PAD, 0)
    expTag:SetPoint("TOP", titleText, "TOP", 0, 0)
    expTag:SetTextColor(0.55, 0.55, 0.55)

    local zoneLine = card:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    zoneLine:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -2)
    zoneLine:SetTextColor(0.55, 0.55, 0.55)

    -- ================================================================
    -- Description (full wrapping text)
    -- ================================================================
    local descText = card:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    descText:SetPoint("TOPLEFT", iconTex, "BOTTOMLEFT", 0, -10)
    descText:SetPoint("RIGHT", card, "RIGHT", -PAD, 0)
    descText:SetJustifyH("LEFT")
    descText:SetSpacing(2)
    descText:SetTextColor(0.70, 0.70, 0.70)

    -- ================================================================
    -- Progress bar (minimal)
    -- ================================================================
    local progressBar = CreateFrame("StatusBar", nil, card)
    progressBar:SetHeight(BAR_H)
    progressBar:SetMinMaxValues(0, 1)
    progressBar:SetStatusBarTexture(SOLID)
    progressBar:SetStatusBarColor(cr, cg, cb, 1.0)

    local barBg = progressBar:CreateTexture(nil, "BACKGROUND")
    barBg:SetAllPoints()
    barBg:SetTexture(SOLID)
    barBg:SetVertexColor(0.15, 0.15, 0.15, 1.0)

    local progressText = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    progressText:SetTextColor(0.55, 0.55, 0.55)

    -- ================================================================
    -- Next step row: chapter · quest [Show on Map]
    -- ================================================================
    local nextInfo = card:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    nextInfo:SetJustifyH("LEFT")
    nextInfo:SetWordWrap(false)

    local trackBtn = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
    trackBtn:SetSize(110, 22)
    trackBtn:SetText("Show on Map")
    trackBtn:SetNormalFontObject("GameFontHighlightSmall")
    trackBtn:SetHighlightFontObject("GameFontHighlightSmall")

    local completeText = card:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    completeText:SetText("|cff40c040Complete|r")
    completeText:Hide()

    -- ================================================================
    -- Update
    -- ================================================================
    local function Update()
        -- Icon from achievement
        local iconID
        if data.achievementID then
            local _, _, _, _, _, _, _, _, _, achIcon = GetAchievementInfo(data.achievementID)
            iconID = achIcon
        end
        if iconID then iconTex:SetTexture(iconID) end

        titleText:SetText("|cff" .. hexC .. data.title .. "|r")
        expTag:SetText(data.expansion)
        zoneLine:SetText(data.zone)
        descText:SetText(data.description)

        -- Progress
        local done, total = GetCampaignProgress(data)
        local pct = total > 0 and (done / total) or 0
        progressBar:SetValue(pct)
        progressText:SetText(done .. "/" .. total)

        -- Anchor progress bar below description
        progressBar:ClearAllPoints()
        progressBar:SetPoint("TOPLEFT", descText, "BOTTOMLEFT", 0, -10)
        progressBar:SetPoint("RIGHT", card, "RIGHT", -PAD, 0)

        progressText:ClearAllPoints()
        progressText:SetPoint("TOPRIGHT", progressBar, "TOPRIGHT", 0, 14)

        -- Next quest
        local quest, chapter = FindNextQuest(data)

        if quest then
            nextInfo:Show()
            trackBtn:Show()
            completeText:Hide()

            nextInfo:ClearAllPoints()
            nextInfo:SetPoint("TOPLEFT", progressBar, "BOTTOMLEFT", 0, -10)
            nextInfo:SetPoint("RIGHT", card, "RIGHT", -126, 0)
            nextInfo:SetText("|cff" .. hexC .. chapter .. "|r  ·  |cffffd200" .. quest.name .. "|r")

            trackBtn:ClearAllPoints()
            trackBtn:SetPoint("RIGHT", card, "RIGHT", -PAD, 0)
            trackBtn:SetPoint("TOP", nextInfo, "TOP", 0, 3)

            trackBtn:SetScript("OnClick", function()
                local result = SetWaypointForQuest(data, quest)
                PrintTrackResult(result, quest, data)
            end)

            C_Timer.After(0, function()
                local h = PAD + ICON_SZ + 10 + descText:GetHeight() + 10
                         + BAR_H + 10 + 22 + PAD
                card:SetHeight(h)
            end)
        else
            nextInfo:Hide()
            trackBtn:Hide()
            completeText:Show()

            completeText:ClearAllPoints()
            completeText:SetPoint("TOPLEFT", progressBar, "BOTTOMLEFT", 0, -8)

            C_Timer.After(0, function()
                local h = PAD + ICON_SZ + 10 + descText:GetHeight() + 10
                         + BAR_H + 8 + 14 + PAD
                card:SetHeight(h)
            end)
        end
    end

    return card, Update
end

-- ============================================================================
-- Build & Layout
-- ============================================================================

local cardsBuilt = false

local function BuildCards()
    if cardsBuilt then return end
    cardsBuilt = true
    for i, data in ipairs(questlines) do
        local frame, updateFn = CreateQuestlineCard(scrollChild, data)
        allCards[i] = { frame = frame, update = updateFn }
    end
end

local function LayoutCards()
    local yOffset = -16
    for _, entry in ipairs(allCards) do
        entry.frame:ClearAllPoints()
        entry.frame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 16, yOffset)
        entry.frame:SetPoint("RIGHT", scrollChild, "RIGHT", -16, 0)
        yOffset = yOffset - entry.frame:GetHeight() - CARD_GAP
    end
    scrollChild:SetHeight(math.abs(yOffset) + 16)
end

local function RefreshAll()
    BuildCards()
    LayoutCards()  -- first pass: establish card widths so text can wrap
    for _, entry in ipairs(allCards) do
        entry.update()
    end
    C_Timer.After(0.05, LayoutCards)  -- second pass: correct heights after text wraps
end

settingsPanel:SetScript("OnShow", function()
    C_Timer.After(0, RefreshAll)
end)

-- ============================================================================
-- Register Questlines
-- ============================================================================

RegisterQuestline(SM.SuramarData)
RegisterQuestline(SM.RogueCampaignData)

-- ============================================================================
-- Register Settings
-- ============================================================================

local category = Settings.RegisterCanvasLayoutCategory(settingsPanel, "StoryMode")
Settings.RegisterAddOnCategory(category)

-- ============================================================================
-- Slash Commands
-- ============================================================================

SLASH_STORYMODE1 = "/sm"
SLASH_STORYMODE2 = "/storymode"
SlashCmdList["STORYMODE"] = function(msg)
    msg = msg and msg:trim():lower() or ""
    if msg == "track" or msg == "next" then
        for _, data in ipairs(questlines) do
            local quest, chapter = FindNextQuest(data)
            if quest then
                local result = SetWaypointForQuest(data, quest)
                print("|cff64b5f6StoryMode:|r |cffb48ef9" .. data.title .. " — " .. chapter .. "|r")
                PrintTrackResult(result, quest, data)
                return
            end
        end
        print("|cff64b5f6StoryMode:|r All questlines complete!")
    else
        Settings.OpenToCategory(category:GetID())
    end
end

-- ============================================================================
-- Initialization
-- ============================================================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon ~= addonName then return end
    StoryModeDB = StoryModeDB or CopyTable(defaults)
    self:UnregisterEvent("ADDON_LOADED")
end)
