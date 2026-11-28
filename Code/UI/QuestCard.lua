local _, SM = ...
local L = SM.L
local SMTooltip = SM.Tooltip
local C_BODY = SM.UIColors.body
local C_GOLD = SM.UIColors.gold
local C_DIM = SM.UIColors.dim

local QCARD_H = 44 + 8

function SM.ExecuteTrackButton(data, quest)
    if not data or not quest then return end
    local result = SM.SetWaypointForQuest(data, quest)
    SM.PrintTrackResult(result, quest, data)
    local storyFrame = SM.GetStoryModeFrame and SM.GetStoryModeFrame()
    if storyFrame then storyFrame:Hide() end
end

-- WoW Forever hides Lua errors unless scriptErrors is on, so a button that
-- fails there just seems to do nothing. There its errors go to chat too.
function SM.RunTrackButton(data, quest)
    if not SM.Client.isForever then
        SM.ExecuteTrackButton(data, quest)
        return
    end
    local ok, err = pcall(SM.ExecuteTrackButton, data, quest)
    if not ok then
        print(L["Addon Prefix"] .. tostring(err))
        geterrorhandler()(err)
    end
end

local activeQuestTooltipCard = nil
local questTooltipRefreshToken = 0

local function IsQuestTooltipDataCached(questID)
    if questID and C_QuestLog and C_QuestLog.IsQuestDataCached then
        local ok, cached = pcall(C_QuestLog.IsQuestDataCached, questID)
        if ok then return cached and true or false end
    end
    return nil
end

local function QuestCardHasQuestID(card, questID)
    if not (card and questID) then return false end
    if card.questID == questID then return true end
    if card.questEntry and SM.GetQuestIDs then
        for _, id in ipairs(SM.GetQuestIDs(card.questEntry)) do
            if id == questID then return true end
        end
    end
    return false
end

local function IsQuestTooltipCardActive(card)
    return card
        and activeQuestTooltipCard == card
        and card:IsShown()
        and card:IsMouseOver()
end

local function QueueQuestTooltipRefresh(card, delay)
    if not (C_Timer and C_Timer.After) then return end
    questTooltipRefreshToken = questTooltipRefreshToken + 1
    local token = questTooltipRefreshToken
    C_Timer.After(delay or 0, function()
        if token ~= questTooltipRefreshToken then return end
        if SM.RefreshQuestCardTooltip and IsQuestTooltipCardActive(card) then
            SM.RefreshQuestCardTooltip(card, false)
        end
    end)
end

local function EnsureQuestTooltipEvents()
    if SM.questTooltipEventFrame then return end

    SM.questTooltipEventFrame = CreateFrame("Frame")
    SM.questTooltipEventFrame:RegisterEvent("QUEST_LOG_UPDATE")
    if C_QuestLog and C_QuestLog.RequestLoadQuestByID then
        pcall(SM.questTooltipEventFrame.RegisterEvent, SM.questTooltipEventFrame, "QUEST_DATA_LOAD_RESULT")
    end

    SM.questTooltipEventFrame:SetScript("OnEvent", function(_, event, questID, success)
        local card = activeQuestTooltipCard
        if not IsQuestTooltipCardActive(card) then return end

        if event == "QUEST_DATA_LOAD_RESULT" then
            if not success or not QuestCardHasQuestID(card, questID) then return end
            QueueQuestTooltipRefresh(card, 0)
        elseif event == "QUEST_LOG_UPDATE" then
            QueueQuestTooltipRefresh(card, 0.05)
        end
    end)
end

local function RequestQuestTooltipData(card)
    local questID = card and card.questID
    if not (questID and C_QuestLog and C_QuestLog.RequestLoadQuestByID) then
        return false
    end

    EnsureQuestTooltipEvents()
    local ok = pcall(C_QuestLog.RequestLoadQuestByID, questID)
    if ok then
        QueueQuestTooltipRefresh(card, 0.35)
    end
    return ok
end

function SM.RefreshQuestCardTooltip(card, requestQuestData)
    if not (card and card.questID) then return end

    local questDataCached = IsQuestTooltipDataCached(card.questID)
    local requestedQuestData = requestQuestData and RequestQuestTooltipData(card) or false

    SMTooltip:SetOwner(card, "ANCHOR_RIGHT")
    SMTooltip:ClearLines()

    local qName = (QuestUtils_GetQuestName and QuestUtils_GetQuestName(card.questID)) or card.tooltipTitle or ""
    SMTooltip:AddLine(qName, 1, 1, 1)

    if card.tooltipNPC then
        SMTooltip:AddLine(card.tooltipNPC, C_BODY[1], C_BODY[2], C_BODY[3])
    end
    -- A dungeon or raid quest names its instance, with the quest log's icon:
    -- the card's corner shows the date instead once the quest is done.
    if card.tooltipInstance then
        SMTooltip:AddLine(card.tooltipInstance, C_BODY[1], C_BODY[2], C_BODY[3])
    end

    -- Objectives are only useful for active, incomplete quests. Completed
    -- quests no longer keep live counters, which makes old objective lines stale.
    local qComplete = SM.IsQuestFlaggedCompleted(card.questID)
    local hasObjectives = false
    -- In Explorer mode the next quest names its giver, not what they'll ask.
    if not qComplete and not card.offerOnly then
        local objectives = SM.GetQuestObjectives(card.questID)
        if objectives and #objectives > 0 then
            SMTooltip:AddLine(" ")
            for _, obj in ipairs(objectives) do
                if obj.text and obj.text ~= "" then
                    hasObjectives = true
                    if obj.finished then
                        SMTooltip:AddLine(obj.text, 0.45, 0.90, 0.35, true)
                    else
                        SMTooltip:AddLine(obj.text, 0.9, 0.9, 0.9, true)
                    end
                end
            end
        end

        if requestedQuestData and questDataCached ~= true and not hasObjectives then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine(L["Quest Tooltip Loading"], C_DIM[1], C_DIM[2], C_DIM[3], true)
        end
    end

    if card.tooltipStatus then
        SMTooltip:AddLine(" ")
        SMTooltip:AddLine(card.tooltipStatus)
    end
    if card.tooltipRequirement then
        SMTooltip:AddLine(card.tooltipRequirement, 1.0, 0.82, 0.35, true)
    end

    SMTooltip:Show()
end

-- WoW Forever: quest cards are the Legacy window's challenge cards
-- (LegacyChallengeTemplate), at its size and with its state art. A finished
-- quest is a brown card with a brown ribbon; any other is dimmed, as an
-- unfinished challenge is: a dark card and ribbon, grey text, grey portrait.
--
-- A quest with two or more objectives gets Legacy's plus/minus, and clicking
-- its card opens it, as on the Legacy page. The open card is the selected
-- one: gold outline and full colour, the whole objective text, the quest's
-- objectives two to a row on Legacy's criteria bars, and who gives the
-- quest, with a button to track it. One card is open at a time. Any other
-- card stays plain and tracks its quest when clicked. Field names match the
-- usual card, so the tooltip and chat link code below works for both.
SM.LegacyQuestCardWidth, SM.LegacyQuestCardHeight = 516, 122
SM.LegacyQuestCardGap = 5

local LEGACY = {
    card = "Legacy-Challenge-Cards",
    cardDim = "Legacy-Challenge-Cards-Disable",
    top = "Legacy-Challenge-Cards-tiled-top",
    topDim = "Legacy-Challenge-Cards-tiled-top-Disable",
    middle = "Legacy-Challenge-Cards-tiled-vertical",
    middleDim = "Legacy-Challenge-Cards-tiled-vertical-Disable",
    bottom = "Legacy-Challenge-Cards-tiled-bottom",
    bottomDim = "Legacy-Challenge-Cards-tiled-bottom-disable",
    selected = "Legacy-Challenge-Cards-selected",
    ribbon = "Legacy-Challenge-Cards-Ribbon-Brown",
    ribbonDim = "Legacy-Challenge-Cards-Ribbon-Brown-disable",
    ribbonAccount = "Legacy-Challenge-Cards-Ribbon-Blue",          -- an account-wide challenge's
    ribbonAccountDim = "Legacy-Challenge-Cards-Ribbon-Blue-Disable",
    iconFrame = "Legacy-Tree-Frame-icon-frame",
    iconMask = "UI-Frame-IconMask",
    statusBackground = "Legacy-Challenge-Cards-Date-BG",
    check = "worldquest-tracker-checkmark",
    criteria = "Legacy-Challenge-Cards-Bar",
    plus = "128-redbutton-plus",
    minus = "128-redbutton-minus",
    shield = "Legacy-Tree-Frame-Points-icon",
}
local UNDISCOVERED_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
-- An item's icon from the game's item data, which needs no item cache.
local GetItemIconByID = (C_Item and C_Item.GetItemIconByID) or GetItemIcon

-- Offsets from the Legacy card (Blizzard_LegacyChallengeButton.lua and
-- LegacyChallengeTemplate), from the card's top left.
local CARD = {
    descriptionX = 77,        -- the ribbon's left (5) + 72
    descriptionXOpenable = 100, -- 5 + 95, right of the plus/minus
    descriptionTop = 52,      -- below the ribbon: 4 + 46 + 2
    descriptionRight = 496,   -- rowInset short of the right edge, like the objective rows (Legacy's shield sits here)
    challengeDescriptionWidth = 400, -- a challenge's, as Legacy's (LEGACY_CHALLENGE_BASE_DESCRIPTION_WIDTH)
    collapsedLines = 3,
    objectivesGap = 23,       -- from the description to the first row
    rowHeight = 30,
    rowGapX = 10,
    rowGapY = 5,
    rowInset = 20,
    footerGap = 12,
    footerHeight = 26,  -- the red button's height (ForeverWindow.CreateRedButton)
    bottom = 16,
    outlineEdge = 12,         -- rows of the outline art that keep their size
}
local WHITE = { 1, 1, 1 }
local GRAY = { 0.5, 0.5, 0.5 }
local REQUIREMENT = { 1.0, 0.82, 0.35 }

-- The quest's objective line in the client's language, with the game's $
-- tokens filled in: Data/Forever/QuestText/<locale>.lua, which only the
-- matching client loads, or the English Data/Forever/ForeverQuestText.lua on
-- English clients.
local ENGLISH = { enUS = true, enGB = true }
local function GetQuestCardText(questID)
    if not questID then return nil end
    local text = SM.ForeverQuestTextLocalized and SM.ForeverQuestTextLocalized[questID]
    if not text and ENGLISH[GetLocale()] then
        text = SM.ForeverQuestText and SM.ForeverQuestText[questID]
    end
    if not text then return nil end
    text = SM.ApplyGenderTokens(text)
    text = text:gsub("%$%d+o[a-z]%s*", "")
    text = text:gsub("%$[Nn]", UnitName and UnitName("player") or "")
    text = text:gsub("%$[Cc]", UnitClass and (UnitClass("player")) or "")
    text = text:gsub("%$[Rr]", UnitRace and (UnitRace("player")) or "")
    text = text:gsub("%$[Bb]", " "):gsub("%s+", " ")
    return text
end

-- The game's own tag for a quest done in a dungeon or raid ("Dungeon",
-- "Raid", in the player's language) and the quest log's icon for it, or nil.
-- QuestInfo 81 is a dungeon; 62, 88 and 89 are raids.
local DUNGEON_ICON, RAID_ICON = "questlog-questtypeicon-dungeon", "questlog-questtypeicon-raid"
local INSTANCE_QUEST_TAGS = { [81] = DUNGEON_ICON, [62] = RAID_ICON, [88] = RAID_ICON, [89] = RAID_ICON }
-- A quest the game leaves untagged that still sends the player into a
-- dungeon or raid (the rogue's solo jobs for C) says so in the story data:
-- instance = "dungeon" or "raid". So does one the game tags wrong, and the
-- data wins: WoW Forever kept Season of Discovery's Raid tag on The Mad King,
-- though its Gnomeregan is a five-player dungeon. Its label is the client's
-- own word.
local DATA_INSTANCE_TAGS = {
    dungeon = { label = "LFG_TYPE_DUNGEON", fallback = "Dungeon", icon = DUNGEON_ICON },
    raid = { label = "LFG_TYPE_RAID", fallback = "Raid", icon = RAID_ICON },
}
-- Where the quest's dungeon or raid is known (Data/Forever/
-- ForeverQuestInstances.lua: quest ID -> its area), the card names it
-- ("Uldaman") in the client's language instead of saying "Dungeon".
local function GetInstanceName(quest)
    local areas = SM.ForeverQuestInstances
    if not (areas and C_Map and C_Map.GetAreaInfo) then return nil end
    local area
    for _, questID in ipairs(SM.GetQuestIDs(quest)) do
        area = area or areas[questID]
    end
    area = area or (quest.classicId and areas[quest.classicId])
    local name = area and C_Map.GetAreaInfo(area)
    return name ~= "" and name or nil
end

local function GetInstanceQuestTag(quest)
    if not quest then return nil end
    local label, icon
    local tag = quest.instance and DATA_INSTANCE_TAGS[quest.instance]
    if tag then
        label, icon = _G[tag.label] or tag.fallback, tag.icon
    elseif C_QuestLog and C_QuestLog.GetQuestTagInfo then
        for _, questID in ipairs(SM.GetQuestIDs(quest)) do
            local info = C_QuestLog.GetQuestTagInfo(questID)
            if info and INSTANCE_QUEST_TAGS[info.tagID] and info.tagName and info.tagName ~= "" then
                label, icon = info.tagName, INSTANCE_QUEST_TAGS[info.tagID]
                break
            end
        end
    end
    if not label then return nil end
    -- A quest that opens a raid without taking place in it (Onyxia's
    -- attunement, attunement = true) says so; its tooltip names the raid.
    if quest.attunement then return L["Quest Status Attunement"], icon end
    return GetInstanceName(quest) or label, icon
end

-- A turn-in day the way Legacy writes a challenge's date (13/11/26 or
-- 11/13/26, by the client's region).
local function FormatTurnInDate(stamp)
    local day = date("*t", stamp)
    if FormatShortDate then return FormatShortDate(day.day, day.month, day.year % 100) end
    return string.format("%d/%d/%02d", day.day, day.month, day.year % 100)
end

-- Who gives the quest and where, from the story data.
local function GetQuestGiverText(data, quest)
    local npc = quest and quest.npc or ""
    local location = quest and (quest.location
        or (data and data.npcLocations and data.npcLocations[quest.npc] and data.npcLocations[quest.npc].location))
    if location and location ~= "" then
        -- Class quest lines already name the giver in their location
        -- ("Myrokos Silentform, Ravenholdt Manor, Alterac Mountains").
        -- A place on its own starts the line, so it gets a capital.
        if npc == "" then return SM.CapitalizeFirst(location) end
        if location:sub(1, #npc) == npc then return location end
        return npc .. ", " .. location
    end
    return npc
end

-- The selected outline is a thin gold frame with round corners. An open card
-- is taller than the art, so the outline is drawn in three slices: the top
-- and bottom rows keep their size and only the straight sides stretch.
local function CreateOutline(card, layer, alpha)
    local info = C_Texture.GetAtlasInfo(LEGACY.selected)
    local file = info and (info.file or info.filename)
    local outline = {}
    if not (file and info.height and info.height > 0) then
        local whole = card:CreateTexture(nil, layer)
        whole:SetAllPoints()
        SM.ForeverWindow.SetAtlas(whole, LEGACY.selected)
        whole:SetAlpha(alpha)
        outline[1] = whole
        return outline
    end
    local left, right = info.leftTexCoord, info.rightTexCoord
    local top, bottom = info.topTexCoord, info.bottomTexCoord
    local edge = (bottom - top) * CARD.outlineEdge / info.height
    local slices = {
        { "TOPLEFT", "TOPRIGHT", top, top + edge },
        { "BOTTOMLEFT", "BOTTOMRIGHT", bottom - edge, bottom },
    }
    for i, slice in ipairs(slices) do
        local tex = card:CreateTexture(nil, layer)
        tex:SetTexture(file)
        tex:SetTexCoord(left, right, slice[3], slice[4])
        tex:SetHeight(CARD.outlineEdge)
        tex:SetPoint(slice[1])
        tex:SetPoint(slice[2])
        tex:SetAlpha(alpha)
        outline[i] = tex
    end
    local sides = card:CreateTexture(nil, layer)
    sides:SetTexture(file)
    sides:SetTexCoord(left, right, top + edge, bottom - edge)
    sides:SetPoint("TOPLEFT", outline[1], "BOTTOMLEFT")
    sides:SetPoint("BOTTOMRIGHT", outline[2], "TOPRIGHT")
    sides:SetAlpha(alpha)
    outline[3] = sides
    return outline
end

local function SetOutlineShown(outline, shown)
    for _, tex in ipairs(outline) do tex:SetShown(shown) end
end

-- One objective on Legacy's criteria bar (LegacyChallengeCriteriaTemplate).
local function CreateObjectiveRow(card)
    local SetAtlas = SM.ForeverWindow.SetAtlas
    local row = CreateFrame("Frame", nil, card)
    row:SetHeight(CARD.rowHeight)
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints()
    SetAtlas(row.background, LEGACY.criteria)
    row.check = row:CreateTexture(nil, "ARTWORK")
    SetAtlas(row.check, LEGACY.check, true)
    row.check:SetScale(0.4)
    row.check:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.text = row:CreateFontString(nil, "ARTWORK", "SystemFont_Small2")
    row.text:SetPoint("LEFT", row, "LEFT", 6, 0)
    row.text:SetJustifyH("LEFT")
    row.text:SetMaxLines(2)
    return row
end

-- Which card is open, by its quest, so it stays open while the chapter
-- lays itself out again.
local expandedQuest, expandedCard
local legacyCards = {}

local function RelayoutChapter()
    if SM.LayoutSelectedChapter then SM.LayoutSelectedChapter() end
end

local function AnyLegacyCardVisible()
    for _, card in ipairs(legacyCards) do
        if card:IsVisible() then return true end
    end
    return false
end

-- Quests the game had to load, and live counts on the open card, lay the
-- chapter out again. Several events in a row cause one layout.
local loadingObjectives = {}
local cardEvents
local function EnsureCardEvents()
    if cardEvents then return end
    cardEvents = CreateFrame("Frame")
    cardEvents:RegisterEvent("QUEST_LOG_UPDATE")
    pcall(cardEvents.RegisterEvent, cardEvents, "QUEST_DATA_LOAD_RESULT")
    local queued = false
    cardEvents:SetScript("OnEvent", function(_, event, questID)
        if event == "QUEST_DATA_LOAD_RESULT" then
            if not loadingObjectives[questID] then return end
            loadingObjectives[questID] = nil
        else
            local card = expandedCard
            if not (card and card.expanded and card.liveObjectives and card:IsVisible()) then return end
        end
        if queued or not AnyLegacyCardVisible() then return end
        queued = true
        C_Timer.After(0.2, function()
            queued = false
            if AnyLegacyCardVisible() then RelayoutChapter() end
        end)
    end)
end

-- The quest's objectives. A quest in the log has live counts; a turned-in
-- quest keeps none, so its counts show full. The game may need to load a
-- quest first: it's asked once, and the chapter lays itself out again when
-- the data arrives.
local requestedObjectives = {}
local function GetCardObjectives(card, done)
    local inLog, activeID = SM.IsQuestEntryInLog(card.questEntry)
    local questID = activeID or card.questID
    local list = {}
    local objectives = questID and SM.GetQuestObjectives(questID)
    for _, objective in ipairs(type(objectives) == "table" and objectives or {}) do
        local text = objective.text
        if text and text ~= "" then
            local finished = objective.finished and true or false
            if done then
                text = text:gsub("(%d+)%s*/%s*(%d+)", "%2/%2")
                finished = true
            end
            list[#list + 1] = { text = text, finished = finished }
        end
    end
    card.liveObjectives = inLog
    if #list == 0 and questID and not requestedObjectives[questID]
        and C_QuestLog and C_QuestLog.RequestLoadQuestByID then
        requestedObjectives[questID] = true
        if pcall(C_QuestLog.RequestLoadQuestByID, questID) then
            loadingObjectives[questID] = true
            EnsureCardEvents()
        end
    end
    return list
end

local function LayoutObjectives(card, list, top)
    local width = SM.LegacyQuestCardWidth - 2 * CARD.rowInset
    local cellWidth = (width - CARD.rowGapX) / 2
    local numRows = math.ceil(#list / 2)
    for i, objective in ipairs(list) do
        local row = card.rows[i] or CreateObjectiveRow(card)
        card.rows[i] = row
        local line = math.floor((i - 1) / 2)
        local y = -(top + line * (CARD.rowHeight + CARD.rowGapY))
        row:ClearAllPoints()
        if #list == 1 then
            -- A lone objective spans the card instead of half of it.
            row:SetWidth(width)
            row:SetPoint("TOPLEFT", card, "TOPLEFT", CARD.rowInset, y)
        elseif i % 2 == 1 then
            row:SetWidth(cellWidth)
            row:SetPoint("TOPLEFT", card, "TOPLEFT", CARD.rowInset, y)
        else
            row:SetWidth(cellWidth)
            row:SetPoint("TOPRIGHT", card, "TOPRIGHT", -CARD.rowInset, y)
        end
        row.text:SetWidth(row:GetWidth() - 30)
        row.text:SetText(objective.text)
        local color = objective.finished and WHITE or GRAY
        row.text:SetTextColor(color[1], color[2], color[3])
        row.check:SetShown(objective.finished)
        row:Show()
    end
    for i = #list + 1, #card.rows do card.rows[i]:Hide() end
    if numRows == 0 then return 0 end
    return numRows * CARD.rowHeight + (numRows - 1) * CARD.rowGapY
end

-- The quest a search found (SM.SelectStory): its card keeps the open card's
-- outline, and flashes and scrolls into view the first time it's laid out.
local highlightedQuest, highlightPending

function SM.HighlightQuestCard(quest)
    highlightedQuest, highlightPending = quest, quest ~= nil
end

local function ScrollCardIntoView(card)
    local ui = SM.DetailUI
    local scroll, child = ui and ui.detailScroll, ui and ui.detailChild
    if not (scroll and child) then return end
    -- After the chapter has placed its cards and sized the page.
    C_Timer.After(0.05, function()
        if not card:IsVisible() then return end
        local childTop, cardTop, cardBottom = child:GetTop(), card:GetTop(), card:GetBottom()
        if not (childTop and cardTop and cardBottom) then return end
        local top, bottom = childTop - cardTop, childTop - cardBottom
        local view, current = scroll:GetHeight(), scroll:GetVerticalScroll()
        if top >= current and bottom <= current + view then return end
        local target = top - math.max(0, (view - (bottom - top)) / 2)
        scroll:SetVerticalScroll(math.max(0, math.min(target, scroll:GetVerticalScrollRange())))
    end)
end

-- Only a card with two or more objectives opens; any other stays a plain
-- card that tracks its quest when clicked.
local function ToggleLegacyQuestCard(card)
    highlightedQuest = nil
    expandedQuest = (expandedQuest ~= card.questEntry) and card.questEntry or nil
    SMTooltip:Hide()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    RelayoutChapter()
end

-- The open card's middle runs from 10 below the top to 10 above the bottom,
-- as in Legacy, but as whole copies of the tile with the last one cut short
-- rather than the texture's wrap mode: the high-res tile sits in a file 4 rows
-- taller than it, and the wrap repeats those empty rows as a black line
-- across the card every tile.
local MIDDLE_INSET = 10
local function LayoutMiddle(card, atlas, height)
    local tiles = card.middleTiles
    local used = 0
    if atlas then
        local info = C_Texture.GetAtlasInfo(atlas)
        local tileH = (info and info.height and info.height > 0) and info.height or 62
        local y, bottom = MIDDLE_INSET, height - MIDDLE_INSET
        while bottom - y > 0.01 do
            used = used + 1
            local tile = tiles[used]
            if not tile then
                tile = card:CreateTexture(nil, "BACKGROUND", nil, -1)
                tiles[used] = tile
            end
            SM.ForeverWindow.SetAtlas(tile, atlas)
            local h = math.min(tileH, bottom - y)
            if h < tileH then
                -- Cut from the art the game picked (normal or high-res).
                local left, top, _, tileBottom, right = tile:GetTexCoord()
                if left and tileBottom then
                    tile:SetTexCoord(left, right, top, top + (tileBottom - top) * h / tileH)
                end
            end
            tile:ClearAllPoints()
            tile:SetPoint("TOPLEFT", card, "TOPLEFT", 0, -y)
            tile:SetPoint("TOPRIGHT", card, "TOPRIGHT", 0, -y)
            tile:SetHeight(h)
            tile:Show()
            y = y + tileH
        end
    end
    for i = used + 1, #tiles do tiles[i]:Hide() end
    card.middleAtlas = atlas
end

local function CreateLegacyQuestCard(parent)
    local SetAtlas = SM.ForeverWindow.SetAtlas
    local card = CreateFrame("Button", nil, parent)
    card:EnableMouse(true)
    card:SetSize(SM.LegacyQuestCardWidth, SM.LegacyQuestCardHeight)
    card.isLegacyCard = true
    card.rows = {}
    legacyCards[#legacyCards + 1] = card

    -- Closed: one card piece. Open: a top, a bottom and a middle that tiles
    -- down between them, so the card grows without stretching.
    card.bg = card:CreateTexture(nil, "BACKGROUND")
    card.bg:SetAllPoints()
    card.middleTiles = {}
    card.top = card:CreateTexture(nil, "BACKGROUND")
    card.top:SetPoint("TOPLEFT")
    card.top:SetPoint("TOPRIGHT")
    card.bottom = card:CreateTexture(nil, "BACKGROUND")
    card.bottom:SetPoint("BOTTOMLEFT")
    card.bottom:SetPoint("BOTTOMRIGHT")

    card.selected = CreateOutline(card, "BORDER", 1)
    SetOutlineShown(card.selected, false)
    -- A brighter copy of the outline that flashes on a card a search found.
    card.flash = CreateFrame("Frame", nil, card)
    card.flash:SetAllPoints()
    card.flash:SetFrameLevel(card:GetFrameLevel() + 2)
    CreateOutline(card.flash, "OVERLAY", 1)
    card.flash:Hide()
    local flash = card.flash:CreateAnimationGroup()
    for i = 1, 3 do
        local fadeIn = flash:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.25)
        fadeIn:SetOrder(i * 2 - 1)
        local fadeOut = flash:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.35)
        fadeOut:SetOrder(i * 2)
    end
    flash:SetScript("OnFinished", function() card.flash:Hide() end)
    card.flash.anim = flash
    CreateOutline(card, "HIGHLIGHT", 0.35)

    card.ribbon = card:CreateTexture(nil, "ARTWORK")
    card.ribbon:SetPoint("TOPLEFT", card, "TOPLEFT", 5, -4)
    card.ribbon:SetPoint("TOPRIGHT", card, "TOPRIGHT", -80, -4)
    card.ribbon:SetHeight(46)

    -- Quest giver portrait in the Legacy icon frame (LegacyChallengeIconFrameTemplate).
    local iconHolder = CreateFrame("Frame", nil, card)
    iconHolder:SetSize(60, 60)
    iconHolder:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -18)
    card.portrait = iconHolder:CreateTexture(nil, "ARTWORK")
    card.portrait:SetSize(50, 50)
    card.portrait:SetPoint("CENTER")
    local mask = iconHolder:CreateMaskTexture()
    mask:SetAllPoints(card.portrait)
    if SetAtlas(mask, LEGACY.iconMask) then card.portrait:AddMaskTexture(mask) end
    local iconFrame = iconHolder:CreateTexture(nil, "OVERLAY")
    SetAtlas(iconFrame, LEGACY.iconFrame, true)
    iconFrame:SetPoint("CENTER")

    card.title = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    card.title:SetPoint("TOPLEFT", card.ribbon, "TOPLEFT", 70, -18)
    card.title:SetPoint("RIGHT", card, "RIGHT", -80, 0)
    card.title:SetJustifyH("LEFT")
    card.title:SetWordWrap(false)

    -- Open or closed, as on the Legacy card.
    card.plusMinus = card:CreateTexture(nil, "OVERLAY")
    card.plusMinus:SetSize(20, 20)
    card.plusMinus:SetPoint("TOPLEFT", card, "TOPLEFT", 76, -49)

    -- The description: the quest's objective, or who gives it and where.
    card.npcLabel = card:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1")
    card.npcLabel:SetJustifyH("LEFT")
    card.npcLabel:SetJustifyV("TOP")

    -- Top-right corner, where Legacy shows the date a challenge was done.
    card.statusBackground = card:CreateTexture(nil, "OVERLAY")
    SetAtlas(card.statusBackground, LEGACY.statusBackground, true)
    card.statusBackground:SetPoint("TOPRIGHT", card, "TOPRIGHT", -6, -3)
    local artWidth = card.statusBackground:GetWidth()
    card.statusBackgroundWidth = (artWidth and artWidth > 0) and artWidth or 124   -- the art's own width
    -- When it widens for a long dungeon name, its rounded ends keep their shape.
    if card.statusBackground.SetTextureSliceMargins then
        pcall(card.statusBackground.SetTextureSliceMargins, card.statusBackground, 10, 4, 10, 4)
    end
    card.check = card:CreateTexture(nil, "OVERLAY", nil, 1)
    SetAtlas(card.check, LEGACY.check, true)
    card.check:SetScale(0.5)
    card.check:SetPoint("TOPRIGHT", card, "TOPRIGHT", -20, -8)  -- in the check's half scale
    card.status = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    card.status:SetJustifyH("RIGHT")
    -- The quest log's dungeon or raid icon, before an instance quest's tag
    -- or, once it's done, its date.
    card.instanceIcon = card:CreateTexture(nil, "OVERLAY", nil, 1)
    card.instanceIcon:SetSize(16, 16)
    card.instanceIcon:SetPoint("RIGHT", card.status, "LEFT", -3, 0)
    card.instanceIcon:Hide()

    -- The open card's last line: who gives the quest (or what it needs
    -- first), and a button to track it.
    card.footer = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    card.footer:SetJustifyH("LEFT")
    card.footer:SetWordWrap(false)
    -- The same red button as Add New Friend and the start page's choice.
    card.trackButton = SM.ForeverWindow.CreateRedButton and SM.ForeverWindow.CreateRedButton(card, 120)
        or CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
    card.trackButton:SetText(TRACK_QUEST or "Track Quest")
    local trackLabel = card.trackButton:GetFontString()
    card.trackButton:SetSize(math.max(120, (trackLabel and trackLabel:GetStringWidth() or 0) + 40), CARD.footerHeight)
    card.trackButton:SetScript("OnClick", function(self)
        local owner = self:GetParent()
        SM.RunTrackButton(owner.storyData, owner.questEntry)
    end)
    card.footer:Hide()
    card.trackButton:Hide()

    -- Kept so shared code that touches card.icon still works.
    card.icon = card:CreateTexture(nil, "OVERLAY")
    card.icon:Hide()

    -- state: "done", "active" (in the quest log), "next", "optional",
    -- "locked" (has a requirement) or "later".
    function card:SetLegacyState(state, data, chapter, quest)
        local done = state == "done"
        -- Explorer mode: a quest counts as discovered once it's done, in the
        -- log or passed, or it's the one the story sends the player to next.
        -- Passing an optional quest doesn't count: the player never saw it.
        -- Until then its card keeps its place, nothing else; the
        -- next quest names its giver but not what they'll ask.
        local explorer = SM.IsExplorerMode and SM.IsExplorerMode()
        local passed = state == "passed" and not (quest and quest.optional)
        local undiscovered = explorer and not (done or state == "active" or passed or state == "next")
        local offerOnly = explorer and state == "next"
        self.undiscovered, self.offerOnly = undiscovered, offerOnly
        local objectives = (undiscovered or offerOnly) and {} or GetCardObjectives(self, done)
        -- An item step (quest.item) has no quest text of its own: the story's
        -- data writes its objective.
        local objectiveText = not (undiscovered or offerOnly) and (GetQuestCardText(quest and quest.id)
            or (quest and quest.objective and SM.ApplyGenderTokens(quest.objective))) or nil
        local giverText = undiscovered and L["Quest Undiscovered Text"] or GetQuestGiverText(data, quest)
        -- A card opens when its closed face can't show everything: several
        -- objectives, or text cut short at the closed card's lines (measured
        -- at the open card's narrower width), which the open card shows whole.
        self.npcLabel:SetWidth(CARD.descriptionRight - CARD.descriptionXOpenable)
        self.npcLabel:SetMaxLines(CARD.collapsedLines)
        self.npcLabel:SetText(objectiveText or giverText)
        local cutShort = self.npcLabel.IsTruncated and self.npcLabel:IsTruncated() or false
        local expandable = #objectives > 1 or cutShort
        local expanded = expandable and quest ~= nil and quest == expandedQuest
        -- Legacy has two looks, finished and not. A quest in the log keeps
        -- the unfinished art but is in full colour, so it doesn't read as not
        -- started yet.
        local dimmed = not done and not expanded and state ~= "active"
        self.expandable = expandable
        self.expanded = expanded
        if expanded then
            expandedCard = self
            EnsureCardEvents()
        end

        SetAtlas(self.bg, done and LEGACY.card or LEGACY.cardDim)
        SetAtlas(self.top, done and LEGACY.top or LEGACY.topDim, true)
        SetAtlas(self.bottom, done and LEGACY.bottom or LEGACY.bottomDim, true)
        self.bg:SetShown(not expanded)
        self.top:SetShown(expanded)
        self.bottom:SetShown(expanded)
        SetAtlas(self.ribbon, done and LEGACY.ribbon or LEGACY.ribbonDim)
        local highlighted = quest ~= nil and quest == highlightedQuest
        SetOutlineShown(self.selected, expanded or highlighted)
        if highlighted and highlightPending then
            highlightPending = false
            self.flash:Show()
            self.flash.anim:Stop()
            self.flash.anim:Play()
            ScrollCardIntoView(self)
        elseif not highlighted and self.flash:IsShown() then
            self.flash.anim:Stop()
            self.flash:Hide()
        end
        SetAtlas(self.plusMinus, expanded and LEGACY.minus or LEGACY.plus)
        self.plusMinus:SetShown(expandable)

        local displayID = quest and SM.GetQuestGiverDisplayID(data, quest.npc)
        local iconPath = data and ((data.chapterIcons and chapter and data.chapterIcons[chapter.chapter]) or data.icon)
        -- An item step with no giver to picture (q.item, no npc) shows its item.
        local itemIcon = quest and quest.item and not displayID and GetItemIconByID
            and GetItemIconByID(quest.item)
        if undiscovered then
            self.portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            self.portrait:SetTexture(UNDISCOVERED_ICON)
            self.title:SetText(L["Quest Undiscovered Title"])
            self.tooltipTitle, self.tooltipNPC = L["Quest Undiscovered Title"], nil
            self.tooltipStatus, self.tooltipRequirement = nil, nil
        elseif itemIcon then
            self.portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            self.portrait:SetTexture(itemIcon)
        else
            SM.SetChapterPortrait(self.portrait, displayID, iconPath, quest and quest.id)
        end
        self.portrait:SetDesaturated(dimmed)

        local descriptionX = expandable and CARD.descriptionXOpenable or CARD.descriptionX
        self.npcLabel:ClearAllPoints()
        self.npcLabel:SetPoint("TOPLEFT", self, "TOPLEFT", descriptionX, -CARD.descriptionTop)
        self.npcLabel:SetWidth(CARD.descriptionRight - descriptionX)
        self.npcLabel:SetMaxLines(expanded and 0 or CARD.collapsedLines)
        self.npcLabel:SetText(objectiveText or giverText)

        -- Done: the day it was turned in and a check, as Legacy dates a
        -- finished challenge (just the check if the day isn't known).
        -- An unfinished dungeon or raid quest says so in the corner instead.
        -- Either way a dungeon or raid quest keeps the quest log's icon there.
        local turnedIn = done and SM.GetQuestTurnInDate and SM.GetQuestTurnInDate(quest)
        local instanceTag, instanceIcon
        if not undiscovered then instanceTag, instanceIcon = GetInstanceQuestTag(quest) end
        local instanceName = instanceTag and GetInstanceName(quest)
        self.tooltipInstance = instanceName
            and ((CreateAtlasMarkup and instanceIcon) and (CreateAtlasMarkup(instanceIcon, 14, 14) .. " ") or "") .. instanceName
            or nil
        -- WoW keeps no completion dates, so quests finished before Story
        -- Mode started saving them say Completed instead.
        local statusText = (turnedIn and FormatTurnInDate(turnedIn))
            or (done and L["Quest Status Completed"]) or instanceTag
            or (state == "active" and L["Quest Status In Progress"])
            or (state == "optional" and not undiscovered and L["Quest Status Optional"]) or nil
        self.status:SetText(statusText or "")
        self.status:ClearAllPoints()
        if done then
            self.status:SetPoint("RIGHT", self.check, "LEFT", 0, 0)
        else
            self.status:SetPoint("RIGHT", self.statusBackground, "RIGHT", -8, 0)
        end
        self.status:SetTextColor(1, 0.82, 0)
        self.statusBackground:SetShown(done or statusText ~= nil)
        self.check:SetShown(done)
        local showIcon = instanceIcon ~= nil and (done or statusText == instanceTag)
        if showIcon then self.instanceIcon:SetAtlas(instanceIcon) end
        self.instanceIcon:SetShown(showIcon)
        -- A dungeon's name can be longer than the corner's art: the art widens
        -- to hold it (the check or right edge, the text, the icon, a margin).
        local needed = (self.status:GetStringWidth() or 0) + (done and 30 or 8) + (showIcon and 19 or 0) + 14
        self.statusBackground:SetWidth(math.max(self.statusBackgroundWidth, needed))

        local color = dimmed and GRAY or WHITE
        self.title:SetTextColor(color[1], color[2], color[3])
        self.npcLabel:SetTextColor(color[1], color[2], color[3])

        local height = SM.LegacyQuestCardHeight
        local y = CARD.descriptionTop + math.ceil(self.npcLabel:GetStringHeight() or 0)
        local objectivesHeight = LayoutObjectives(self, expanded and objectives or {}, y + CARD.objectivesGap)
        if objectivesHeight > 0 then y = y + CARD.objectivesGap + objectivesHeight end

        local requirement = self.tooltipRequirement
        local footerText = requirement or (objectiveText and giverText ~= "" and giverText) or nil
        local canTrack = expanded and not done and not requirement
        self.footer:SetShown(expanded and footerText ~= nil)
        self.trackButton:SetShown(canTrack)
        if expanded then
            local footerY = -(y + CARD.footerGap)
            self.trackButton:ClearAllPoints()
            self.trackButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", -CARD.rowInset, footerY)
            self.footer:ClearAllPoints()
            self.footer:SetPoint("LEFT", self, "TOPLEFT", CARD.rowInset + 6, footerY - CARD.footerHeight / 2)
            self.footer:SetWidth(SM.LegacyQuestCardWidth - 2 * CARD.rowInset - 6
                - (canTrack and self.trackButton:GetWidth() + 12 or 0))
            self.footer:SetText(footerText or "")
            local footerColor = requirement and REQUIREMENT or C_GOLD
            self.footer:SetTextColor(footerColor[1], footerColor[2], footerColor[3])
            if footerText or canTrack then y = y + CARD.footerGap + CARD.footerHeight end
            height = math.max(height, y + CARD.bottom)
        end
        self:SetHeight(height)
        LayoutMiddle(self, expanded and (done and LEGACY.middle or LEGACY.middleDim) or nil, height)
    end

    return card
end

-- The Legacy points a challenge gives, as the Legacy window reads them
-- (AchievementFrame_GetOverridePoints), or nil.
local function GetLegacyPoints(achievementID)
    local consts = Constants and Constants.LegacyConsts
    local currencyID = consts and consts.LEGACY_POINTS_TRAIT_CURRENCY_ID
    if not (currencyID and C_Traits and C_Traits.GetTraitCurrencyForAchievement) then return nil end
    local ok, points = pcall(C_Traits.GetTraitCurrencyForAchievement, currencyID, achievementID)
    return ok and type(points) == "number" and points or nil
end

-- WoW Forever: a Legacy challenge a chapter's chain earns, on the card the
-- Legacy window shows it on: its icon, name and description, its points on
-- the shield, and once this character has earned it, the day and a check.
-- Clicking it opens the Legacy window at the challenge.
function SM.CreateLegacyChallengeCard(parent)
    local SetAtlas = SM.ForeverWindow.SetAtlas
    local card = CreateLegacyQuestCard(parent)
    card.shield = card:CreateTexture(nil, "ARTWORK")
    SetAtlas(card.shield, LEGACY.shield)
    card.shield:SetSize(35, 51)
    card.shield:SetPoint("TOPRIGHT", card, "TOPRIGHT", -14, -26)
    card.points = card:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3")
    card.points:SetPoint("CENTER", card.shield, "CENTER", -1, -4)
    -- Hovering the shield says what the challenge gives ("Earn 1 Legacy
    -- Point."), as on the Legacy card: the same 64 x 64 corner (the shield's
    -- Button in LegacyChallengeTemplate) and the game's own tooltip beside it
    -- (AchievementShield_OnEnter). A click on it still goes to the card.
    card.shieldHover = CreateFrame("Frame", nil, card)
    card.shieldHover:SetSize(64, 64)
    card.shieldHover:SetPoint("TOPRIGHT", card, "TOPRIGHT", -6, -2)
    card.shieldHover:SetFrameLevel(card:GetFrameLevel() + 3)
    if card.shieldHover.SetMouseClickEnabled then
        card.shieldHover:SetMouseMotionEnabled(true)
        card.shieldHover:SetMouseClickEnabled(false)
    else
        card.shieldHover:EnableMouse(true)
    end
    card.shieldHover:SetScript("OnEnter", function(self)
        local rewardText = card.challengeID and select(11, GetAchievementInfo(card.challengeID))
        if not GameTooltip or type(rewardText) ~= "string" or rewardText == "" then return end
        SMTooltip:Hide()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(rewardText)
        GameTooltip:Show()
    end)
    card.shieldHover:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)

    function card:SetLegacyChallenge(achievementID)
        local _, name, _, completed, month, day, year, description, flags, icon, _, _, wasEarnedByMe =
            GetAchievementInfo(achievementID)
        -- As in the Legacy window, one earned by another character still
        -- looks unfinished here.
        local earned = completed and wasEarnedByMe
        -- An account-wide challenge has Legacy's blue ribbon, any other the brown.
        local accountFlag = ACHIEVEMENT_FLAGS_ACCOUNT or 0x20000
        local accountWide = type(flags) == "number" and bit and bit.band(flags, accountFlag) == accountFlag
        self.challengeID, self.challengeName = achievementID, name

        SetAtlas(self.bg, earned and LEGACY.card or LEGACY.cardDim)
        self.bg:Show()
        self.top:Hide()
        self.bottom:Hide()
        LayoutMiddle(self, nil, SM.LegacyQuestCardHeight)
        if accountWide then
            SetAtlas(self.ribbon, earned and LEGACY.ribbonAccount or LEGACY.ribbonAccountDim)
        else
            SetAtlas(self.ribbon, earned and LEGACY.ribbon or LEGACY.ribbonDim)
        end
        SetOutlineShown(self.selected, false)
        self.plusMinus:Hide()
        self.footer:Hide()
        self.trackButton:Hide()
        self.instanceIcon:Hide()

        self.portrait:SetTexture(icon or UNDISCOVERED_ICON)
        self.portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        self.portrait:SetDesaturated(not earned)
        self.title:SetText(name or "")
        self.npcLabel:ClearAllPoints()
        self.npcLabel:SetPoint("TOPLEFT", self, "TOPLEFT", CARD.descriptionX, -CARD.descriptionTop)
        self.npcLabel:SetWidth(CARD.challengeDescriptionWidth)
        self.npcLabel:SetMaxLines(CARD.collapsedLines)
        self.npcLabel:SetText(description or "")
        local color = earned and WHITE or GRAY
        self.title:SetTextColor(color[1], color[2], color[3])
        self.npcLabel:SetTextColor(color[1], color[2], color[3])

        -- Legacy has no shield for a challenge worth no points.
        local points = GetLegacyPoints(achievementID)
        self.points:SetText(points and points > 0 and tostring(points) or "")
        local hasPoints = points ~= nil and points > 0
        self.shield:SetShown(hasPoints)
        self.points:SetShown(hasPoints)
        self.shieldHover:SetShown(hasPoints)

        local dateText = earned and month and month > 0 and FormatShortDate and FormatShortDate(day, month, year) or ""
        self.status:SetText(dateText)
        self.status:ClearAllPoints()
        self.status:SetPoint("RIGHT", self.check, "LEFT", 0, 0)
        self.status:SetTextColor(1, 0.82, 0)
        self.statusBackground:SetShown(earned)
        self.check:SetShown(earned)
        self:SetHeight(SM.LegacyQuestCardHeight)
    end

    card:SetScript("OnEnter", function(self)
        if not (self.challengeID and LEGACY_CHALLENGE_FRAME_TITLE) then return end
        SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
        SMTooltip:ClearLines()
        SMTooltip:AddLine(self.challengeName or "", 1, 1, 1)
        SMTooltip:AddLine(string.format(L["Legacy Challenge Open Format"], LEGACY_CHALLENGE_FRAME_TITLE), 0.5, 0.5, 0.5)
        SMTooltip:Show()
    end)
    card:SetScript("OnLeave", function() SMTooltip:Hide() end)
    card:SetScript("OnClick", function(self)
        if not self.challengeID then return end
        -- Shift-click links it in chat, as Legacy does.
        if IsShiftKeyDown() and GetAchievementLink and ChatEdit_InsertLink
            and ChatEdit_InsertLink(GetAchievementLink(self.challengeID)) then
            return
        end
        SMTooltip:Hide()
        -- The Legacy window opens where ours sits.
        local storyFrame = SM.GetStoryModeFrame and SM.GetStoryModeFrame()
        if storyFrame then storyFrame:Hide() end
        SM.OpenLegacyChallenge(self.challengeID)
    end)
    return card
end

function SM.CreateQuestCard(parent)
    if SM.ForeverWindow then
        local card = CreateLegacyQuestCard(parent)
        SM.AttachQuestCardScripts(card)
        return card
    end
    local card = CreateFrame("Button", nil, parent, (SM.IsMainlineClient()) and nil or "BackdropTemplate")
    card:EnableMouse(true)
    card:SetHeight(QCARD_H)
    if SM.IsClassicClient() then
        SM.ApplyClassicCardBackdrop(card, 0.18, 0.50)
    end

    -- Housing endeavor-style card background
    local bg = card:CreateTexture(nil, "BACKGROUND")
    if SM.IsMainlineClient() then
        bg:SetAtlas("housing-dashboard-initiatives-tasks-listitem-bg", false)
    else
        SM.ClearCardFillTexture(bg)
    end
    bg:SetAllPoints()
    card.bg = bg
    if SM.IsClassicClient() then
        card.shade = SM.CreateInsetCardShade(card, 0.38)
    end

    local cardMask = card:CreateMaskTexture()
    cardMask:SetTexture("Interface/Buttons/WHITE8x8")
    cardMask:SetPoint("TOPLEFT", card, "TOPLEFT", 2, -2)
    cardMask:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -2, 2)
    bg:AddMaskTexture(cardMask)
    card.bgMask = cardMask

    -- Hover highlight
    if SM.IsMainlineClient() then
        card:SetHighlightAtlas("housing-dashboard-initiatives-tasks-listitem-bg")
        card:GetHighlightTexture():SetAllPoints()
        card:GetHighlightTexture():SetAlpha(0.3)
    else
        SM.SetSubtleCardHover(card)
    end
    if card:GetHighlightTexture() then
        card:GetHighlightTexture():AddMaskTexture(cardMask)
    end

    -- Status icon (always 14x14 for consistent text alignment)
    local ICON_LEFT = 10
    local TEXT_LEFT = ICON_LEFT + 14 + 8  -- icon width + gap
    local icon = card:CreateTexture(nil, "ARTWORK")
    icon:SetSize(14, 14)
    icon:SetPoint("LEFT", card, "LEFT", ICON_LEFT, 0)
    card.icon = icon

    -- Quest name (top line)
    local title = SM.NoShadow(card:CreateFontString(nil, "ARTWORK", "GameFontNormal"))
    title:SetPoint("LEFT", card, "LEFT", TEXT_LEFT, 0)
    title:SetPoint("RIGHT", card, "RIGHT", -10, 0)
    title:SetPoint("BOTTOM", card, "CENTER", 0, 1)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("BOTTOM")
    title:SetWordWrap(false)
    card.title = title

    -- NPC name (bottom line, same left edge as title)
    local npcLabel = SM.NoShadow(card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
    npcLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    npcLabel:SetPoint("RIGHT", card, "RIGHT", -10, 0)
    npcLabel:SetJustifyH("LEFT")
    npcLabel:SetWordWrap(false)
    card.npcLabel = npcLabel

    SM.AttachQuestCardScripts(card)
    return card
end

-- Tooltip, chat link and tracking clicks, shared by both card styles. A
-- Legacy card opens on a click instead, and tracks from its own button.
function SM.AttachQuestCardScripts(card)
    -- Tooltip — refreshes in place when Blizzard finishes loading quest data.
    -- An open Legacy card already shows all of it.
    card:SetScript("OnEnter", function(self)
        if self.undiscovered then
            SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
            SMTooltip:ClearLines()
            SMTooltip:AddLine(L["Quest Undiscovered Title"], 1, 1, 1)
            SMTooltip:AddLine(L["Quest Undiscovered Text"], C_BODY[1], C_BODY[2], C_BODY[3], true)
            SMTooltip:Show()
            return
        end
        if not self.questID or self.expanded then return end
        activeQuestTooltipCard = self
        EnsureQuestTooltipEvents()
        SM.RefreshQuestCardTooltip(self, true)
    end)
    card:SetScript("OnLeave", function(self)
        if activeQuestTooltipCard == self then
            activeQuestTooltipCard = nil
            questTooltipRefreshToken = questTooltipRefreshToken + 1
        end
        SMTooltip:Hide()
    end)
    card:SetScript("OnClick", function(self, button)
        if not self.questEntry or self.undiscovered then return end

        local questName = self.tooltipTitle or self.questEntry.name or L["Quest"]
        if button == "LeftButton" and IsShiftKeyDown() and SM.InsertQuestChatLink(self.questEntry, self.questID, questName) then
            return
        end
        if self.isLegacyCard and self.expandable then
            ToggleLegacyQuestCard(self)
            return
        end

        local questText = SM.GetQuestChatLink(self.questEntry, questName)
        if self.questCompleteForClick or SM.IsQuestEntryComplete(self.questEntry) then
            local storyFrame = SM.GetStoryModeFrame and SM.GetStoryModeFrame()
            if storyFrame then storyFrame:Hide() end
            print(L["Addon Prefix"] .. string.format(L["Quest Click Complete Format"], questText))
            return
        end

        if self.tooltipRequirement then
            local storyFrame = SM.GetStoryModeFrame and SM.GetStoryModeFrame()
            if storyFrame then storyFrame:Hide() end
            print(L["Addon Prefix"] .. self.tooltipRequirement)
            return
        end

        SM.ExecuteTrackButton(self.storyData, self.questEntry)
    end)
end
