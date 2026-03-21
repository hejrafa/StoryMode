local addonName, SM = ...

-- ============================================================================
-- Saved Variables
-- ============================================================================

local defaults = {
    version = "0.1.0",
    selectedQuestline = 1,
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

    -- First: check if any quest is actively in the log
    for _, ch in ipairs(chapters) do
        for _, q in ipairs(ch.quests) do
            if IsQuestInLog(q.id) then
                return q, ch.chapter
            end
        end
    end

    -- Second: find the latest chapter with progress
    local activeChapterIdx = nil
    for i, ch in ipairs(chapters) do
        local done, total = GetChapterProgress(ch)
        if done > 0 and done < total then
            activeChapterIdx = i
        elseif done == total and total > 0 then
            activeChapterIdx = i + 1
        end
    end

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

local SOLID = "Interface\\Buttons\\WHITE8x8"
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
-- Settings Panel
-- ============================================================================

local settingsPanel = CreateFrame("Frame", "StoryModeSettingsPanel")
settingsPanel.name = "StoryMode"

-- ============================================================================
-- Left Panel — Story List
-- ============================================================================

local leftPanel = CreateFrame("Frame", nil, settingsPanel)
leftPanel:SetPoint("TOPLEFT", 0, 0)
leftPanel:SetPoint("BOTTOMLEFT", 0, 0)
leftPanel:SetWidth(LEFT_WIDTH)

-- Vertical divider between panels (subtle)
local divider = settingsPanel:CreateTexture(nil, "ARTWORK", nil, 1)
divider:SetTexture(SOLID)
divider:SetVertexColor(0.25, 0.25, 0.25, 0.4)
divider:SetWidth(1)
divider:SetPoint("TOPLEFT", leftPanel, "TOPRIGHT", 0, -10)
divider:SetPoint("BOTTOMLEFT", leftPanel, "BOTTOMRIGHT", 0, 10)

-- Header: centered title + subtitle
local leftTitle = leftPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
leftTitle:SetPoint("TOP", leftPanel, "TOP", 0, -PAD)
leftTitle:SetJustifyH("CENTER")
leftTitle:SetText("Story Mode")

local leftSubtitle = leftPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
leftSubtitle:SetPoint("TOP", leftTitle, "BOTTOM", 0, -3)
leftSubtitle:SetJustifyH("CENTER")
leftSubtitle:SetTextColor(0.72, 0.72, 0.72)
leftSubtitle:SetText("Experience an adventure")

-- Footer: version number at the very bottom
local footerText = leftPanel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
footerText:SetPoint("BOTTOM", leftPanel, "BOTTOM", 0, 10)
footerText:SetJustifyH("CENTER")
footerText:SetText("v" .. defaults.version)
footerText:SetTextColor(0.30, 0.30, 0.30)

-- ============================================================================
-- Right Panel — Detail View
-- ============================================================================

local rightPanel = CreateFrame("ScrollFrame", nil, settingsPanel, "ScrollFrameTemplate")
rightPanel:SetPoint("TOPLEFT", leftPanel, "TOPRIGHT", 1, 0)
rightPanel:SetPoint("BOTTOMRIGHT", 0, 0)
if rightPanel.ScrollBar then rightPanel.ScrollBar:Hide() end

local rightChild = CreateFrame("Frame", nil, rightPanel)
rightChild:SetWidth(400)
rightPanel:SetScrollChild(rightChild)

settingsPanel:SetScript("OnSizeChanged", function(_, w)
    rightChild:SetWidth(w - LEFT_WIDTH - 1)
end)

local DETAIL_PAD = 20
local ICON_SIZE = 40

-- ── Icon: same spellbook pattern as the left panel, just bigger ──
local detailIconBtn = CreateFrame("Button", nil, rightChild)
detailIconBtn:SetSize(ICON_SIZE, ICON_SIZE)
detailIconBtn:SetPoint("TOPLEFT", DETAIL_PAD, -DETAIL_PAD)

-- Spell slot background (dark square behind the icon)
local detailIconBg = detailIconBtn:CreateTexture(nil, "BACKGROUND")
detailIconBg:SetAllPoints()
detailIconBg:SetTexture("Interface\\Buttons\\UI-Quickslot")
detailIconBg:SetTexCoord(0.15, 0.85, 0.15, 0.85)

-- Icon image
local detailIcon = detailIconBtn:CreateTexture(nil, "BORDER")
detailIcon:SetAllPoints()
detailIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

-- Spellbook border on top (oversized, centered over the button)
detailIconBtn:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
local detailBorderTex = detailIconBtn:GetNormalTexture()
detailBorderTex:ClearAllPoints()
detailBorderTex:SetPoint("CENTER")
detailBorderTex:SetSize(ICON_SIZE * 1.75, ICON_SIZE * 1.75)

-- ── Title (yellow) ──
local detailTitle = rightChild:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
detailTitle:SetPoint("LEFT", detailIconBtn, "RIGHT", 8, 0)
detailTitle:SetPoint("TOP", rightChild, "TOP", 0, -DETAIL_PAD)
detailTitle:SetPoint("RIGHT", rightChild, "RIGHT", -DETAIL_PAD, 0)
detailTitle:SetJustifyH("LEFT")
detailTitle:SetJustifyV("TOP")
detailTitle:SetWordWrap(false)
detailTitle:SetTextColor(1, 0.82, 0)

-- ── Subtitle: expansion · zone (light white) ──
local detailSub = rightChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
detailSub:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -3)
detailSub:SetTextColor(0.72, 0.72, 0.72)
detailSub:SetJustifyH("LEFT")

-- ── Description ──
local detailDesc = rightChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
detailDesc:SetPoint("TOPLEFT", rightChild, "TOPLEFT", DETAIL_PAD, -(DETAIL_PAD + ICON_SIZE + 12))
detailDesc:SetPoint("RIGHT", rightChild, "RIGHT", -DETAIL_PAD, 0)
detailDesc:SetJustifyH("LEFT")
detailDesc:SetSpacing(3)
detailDesc:SetWordWrap(true)
detailDesc:SetTextColor(0.72, 0.72, 0.72)

-- ── Progress: category divider with bar ──
local progDivLabel = rightChild:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
progDivLabel:SetJustifyH("CENTER")
progDivLabel:SetText("Progress")
progDivLabel:SetTextColor(0.85, 0.85, 0.85)

local progDivLineL = rightChild:CreateTexture(nil, "ARTWORK")
progDivLineL:SetTexture(SOLID)
progDivLineL:SetHeight(1)

local progDivLineR = rightChild:CreateTexture(nil, "ARTWORK")
progDivLineR:SetTexture(SOLID)
progDivLineR:SetHeight(1)

-- Chapter list container (two-column grid)
local chapterContainer = CreateFrame("Frame", nil, rightChild)
local chapterLabels = {}  -- pool of FontStrings
local CH_ROW_H = 16
local CH_GAP = 4

-- ── Next Step: category divider ──
local nextDivLabel = rightChild:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
nextDivLabel:SetJustifyH("CENTER")
nextDivLabel:SetText("Next Step")
nextDivLabel:SetTextColor(0.85, 0.85, 0.85)

local nextDivLineL = rightChild:CreateTexture(nil, "ARTWORK")
nextDivLineL:SetTexture(SOLID)
nextDivLineL:SetHeight(1)

local nextDivLineR = rightChild:CreateTexture(nil, "ARTWORK")
nextDivLineR:SetTexture(SOLID)
nextDivLineR:SetHeight(1)

-- Quest info — left-aligned narrative text
local nextBody = rightChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
nextBody:SetJustifyH("LEFT")
nextBody:SetSpacing(3)
nextBody:SetWordWrap(true)
nextBody:SetTextColor(0.72, 0.72, 0.72)

-- ── Track button: anchored to the very bottom-right of the right panel ──
local trackBtn = CreateFrame("Button", nil, rightChild, "UIPanelButtonTemplate")
trackBtn:SetSize(130, 22)
trackBtn:SetText("Track Story")
trackBtn:SetNormalFontObject("GameFontNormal")
trackBtn:SetHighlightFontObject("GameFontNormal")

-- Complete state
local completeText = rightChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
completeText:SetTextColor(0.25, 0.75, 0.25)
completeText:SetText("Campaign Complete")
completeText:Hide()

-- Empty state
local emptyText = rightChild:CreateFontString(nil, "ARTWORK", "GameFontDisable")
emptyText:SetPoint("CENTER")
emptyText:SetText("Select a story from the left.")

-- ============================================================================
-- Selection State
-- ============================================================================

local leftRows = {}
local selectedIndex = nil

-- ============================================================================
-- Update Detail View
-- ============================================================================

local function ShowDetail(show)
    local m = show and "Show" or "Hide"
    detailIconBtn[m](detailIconBtn)
    detailTitle[m](detailTitle)
    detailSub[m](detailSub)
    detailDesc[m](detailDesc)
    progDivLabel[m](progDivLabel)
    progDivLineL[m](progDivLineL)
    progDivLineR[m](progDivLineR)
    chapterContainer[m](chapterContainer)
end

local function UpdateDetailView(data)
    if not data then
        ShowDetail(false)
        nextDivLabel:Hide(); nextDivLineL:Hide(); nextDivLineR:Hide()
        nextBody:Hide(); trackBtn:Hide()
        completeText:Hide()
        emptyText:Show()
        return
    end

    emptyText:Hide()
    ShowDetail(true)

    -- Icon
    local iconID
    if data.achievementID then
        local _, _, _, _, _, _, _, _, _, achIcon = GetAchievementInfo(data.achievementID)
        iconID = achIcon
    end
    iconID = iconID or data.icon
    if iconID then detailIcon:SetTexture(iconID) end

    -- Title in yellow
    detailTitle:SetText(data.title)
    detailTitle:SetTextColor(1, 0.82, 0)

    -- Subtitle in light white
    detailSub:SetText(data.expansion .. "  ·  " .. data.zone)
    detailDesc:SetText(data.description)

    -- Progress
    local done, total = GetCampaignProgress(data)
    progDivLabel:SetText("Progress  ·  " .. done .. " / " .. total)

    -- Helper to layout a centered divider with fading lines
    local function LayoutDivider(label, lineL, lineR, anchorTo, yOff)
        local D = DETAIL_PAD
        label:ClearAllPoints()
        label:SetPoint("TOP", anchorTo, "BOTTOM", 0, yOff)

        lineL:ClearAllPoints()
        lineL:SetPoint("LEFT", rightChild, "LEFT", D, 0)
        lineL:SetPoint("RIGHT", label, "LEFT", -8, 0)
        lineL:SetPoint("TOP", label, "CENTER", 0, 0)
        lineL:SetHeight(1)
        lineL:SetGradient("HORIZONTAL",
            CreateColor(0.85, 0.85, 0.85, 0),
            CreateColor(0.85, 0.85, 0.85, 0.35))

        lineR:ClearAllPoints()
        lineR:SetPoint("LEFT", label, "RIGHT", 8, 0)
        lineR:SetPoint("RIGHT", rightChild, "RIGHT", -D, 0)
        lineR:SetPoint("TOP", label, "CENTER", 0, 0)
        lineR:SetHeight(1)
        lineR:SetGradient("HORIZONTAL",
            CreateColor(0.85, 0.85, 0.85, 0.35),
            CreateColor(0.85, 0.85, 0.85, 0))
    end

    -- Build chapter list (two columns)
    local chapters = GetAllChapters(data)

    -- Hide all pooled labels first
    for _, lbl in ipairs(chapterLabels) do lbl:Hide() end

    for i, ch in ipairs(chapters) do
        if not chapterLabels[i] then
            chapterLabels[i] = chapterContainer:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
            chapterLabels[i]:SetJustifyH("LEFT")
            chapterLabels[i]:SetWordWrap(false)
        end
        local lbl = chapterLabels[i]
        lbl:ClearAllPoints()

        local col = (i - 1) % 2   -- 0 = left, 1 = right
        local row = math.floor((i - 1) / 2)
        local yPos = -(row * (CH_ROW_H + CH_GAP))

        if col == 0 then
            lbl:SetPoint("TOPLEFT", 0, yPos)
            lbl:SetPoint("RIGHT", chapterContainer, "CENTER", -4, 0)
        else
            lbl:SetPoint("TOPLEFT", chapterContainer, "TOP", 4, yPos)
            lbl:SetPoint("RIGHT", chapterContainer, "RIGHT", 0, 0)
        end

        local chDone, chTotal = GetChapterProgress(ch)
        local prefix, color
        local check = "|A:common-icon-checkmark:0:0|a "
        if chDone == chTotal and chTotal > 0 then
            prefix = check
            color = { 0.40, 0.78, 0.30 }
        elseif chDone > 0 then
            prefix = ""
            color = { 1, 0.82, 0 }
        else
            prefix = ""
            color = { 0.45, 0.45, 0.45 }
        end
        lbl:SetText(prefix .. ch.chapter)
        lbl:SetTextColor(unpack(color))
        lbl:Show()
    end

    local numRows = math.ceil(#chapters / 2)
    chapterContainer:SetHeight(numRows * (CH_ROW_H + CH_GAP))

    -- Two-pass layout: first pass forces width so description wraps properly
    -- Second pass reads the correct heights
    C_Timer.After(0, function()
        -- Force description to recalculate with correct width
        detailDesc:SetWidth(rightChild:GetWidth() - DETAIL_PAD * 2)
        detailDesc:SetText(data.description)

        C_Timer.After(0, function()
            local D = DETAIL_PAD

            -- Progress divider below description
            LayoutDivider(progDivLabel, progDivLineL, progDivLineR, detailDesc, -18)

            -- Chapter grid below progress divider
            chapterContainer:ClearAllPoints()
            chapterContainer:SetPoint("TOP", progDivLabel, "BOTTOM", 0, -10)
            chapterContainer:SetPoint("LEFT", rightChild, "LEFT", D, 0)
            chapterContainer:SetPoint("RIGHT", rightChild, "RIGHT", -D, 0)

            local quest, chapter = FindNextQuest(data)

            if quest then
                nextDivLabel:Show(); nextDivLineL:Show(); nextDivLineR:Show()
                nextBody:Show(); trackBtn:Show()
                completeText:Hide()

                -- Next Step divider
                LayoutDivider(nextDivLabel, nextDivLineL, nextDivLineR, chapterContainer, -14)

                -- Quest narrative — left-aligned, no quotes
                nextBody:ClearAllPoints()
                nextBody:SetPoint("TOP", nextDivLabel, "BOTTOM", 0, -12)
                nextBody:SetPoint("LEFT", rightChild, "LEFT", D, 0)
                nextBody:SetPoint("RIGHT", rightChild, "RIGHT", -D, 0)
                nextBody:SetText("|cffffd200" .. quest.name .. "|r\nSeek out |cffffffff" .. quest.npc .. "|r in " .. (data.zone or "the world"))

                -- Track button — pinned to very bottom-right of the panel
                trackBtn:ClearAllPoints()
                trackBtn:SetPoint("BOTTOMRIGHT", settingsPanel, "BOTTOMRIGHT", -DETAIL_PAD, DETAIL_PAD)

                trackBtn:SetScript("OnClick", function()
                    local result = SetWaypointForQuest(data, quest)
                    PrintTrackResult(result, quest, data)
                end)

                C_Timer.After(0, function()
                    local chH = chapterContainer:GetHeight()
                    local totalH = DETAIL_PAD + ICON_SIZE + 12
                                 + detailDesc:GetHeight() + 18
                                 + progDivLabel:GetHeight() + 10
                                 + chH + 14
                                 + nextDivLabel:GetHeight() + 12
                                 + nextBody:GetHeight() + 16
                                 + 30 + DETAIL_PAD + 10
                    rightChild:SetHeight(math.max(totalH, 300))
                end)
            else
                nextDivLabel:Hide(); nextDivLineL:Hide(); nextDivLineR:Hide()
                nextBody:Hide(); trackBtn:Hide()
                completeText:Show()

                completeText:ClearAllPoints()
                completeText:SetPoint("TOP", chapterContainer, "BOTTOM", 0, -18)
                rightChild:SetHeight(400)
            end
        end)
    end)
end

-- ============================================================================
-- Select a Questline
-- ============================================================================

local function UpdateActiveStates()
    for _, row in pairs(leftRows) do
        local active = row.data and IsQuestlineActive(row.data)
        if active then
            row.activeLabel:Show()
        else
            row.activeLabel:Hide()
        end
    end
end

local function SelectQuestline(index)
    selectedIndex = index
    UpdateActiveStates()

    for i, row in pairs(leftRows) do
        if i == index then
            row.selBgL:Show(); row.selBgR:Show()
            row.selTopL:Show(); row.selTopR:Show()
            row.selBotL:Show(); row.selBotR:Show()
        else
            row.selBgL:Hide(); row.selBgR:Hide()
            row.selTopL:Hide(); row.selTopR:Hide()
            row.selBotL:Hide(); row.selBotR:Hide()
        end
    end

    UpdateDetailView(allQuestlines[index])

    if StoryModeDB then
        StoryModeDB.selectedQuestline = index
    end
end

-- ============================================================================
-- Build Left Panel
-- ============================================================================

local leftBuilt = false

-- Creates a centered category divider: ---- TEXT ----
-- with fading gold lines on each side of the text.
local function CreateCategoryDivider(parent, text, yOffset, disabled)
    local DIVIDER_COLOR_R, DIVIDER_COLOR_G, DIVIDER_COLOR_B = 0.85, 0.85, 0.85
    local DIVIDER_ALPHA = 0.35

    if disabled then
        DIVIDER_COLOR_R, DIVIDER_COLOR_G, DIVIDER_COLOR_B = 0.72, 0.72, 0.72
        DIVIDER_ALPHA = 0.2
    end

    -- Center text
    local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    label:SetPoint("TOP", parent, "TOP", 0, yOffset)
    label:SetJustifyH("CENTER")
    label:SetText(text)
    if disabled then
        label:SetTextColor(0.72, 0.72, 0.72)
    else
        label:SetTextColor(0.85, 0.85, 0.85)
    end

    -- Left line: fades from transparent (left edge) to visible (near text)
    local lineLeft = parent:CreateTexture(nil, "ARTWORK")
    lineLeft:SetTexture(SOLID)
    lineLeft:SetHeight(1)
    lineLeft:SetPoint("LEFT", parent, "LEFT", PAD, 0)
    lineLeft:SetPoint("RIGHT", label, "LEFT", -8, 0)
    lineLeft:SetPoint("TOP", label, "TOP", 0, 0)  -- clear vertical; recenter
    lineLeft:ClearAllPoints()
    lineLeft:SetPoint("RIGHT", label, "LEFT", -8, 0)
    lineLeft:SetPoint("LEFT", parent, "LEFT", PAD, 0)
    lineLeft:SetHeight(1)
    -- Vertically center with the text
    lineLeft:ClearAllPoints()
    lineLeft:SetPoint("LEFT", parent, "LEFT", PAD, 0)
    lineLeft:SetPoint("RIGHT", label, "LEFT", -8, 0)
    lineLeft:SetPoint("TOP", label, "CENTER", 0, 0)
    lineLeft:SetHeight(1)
    lineLeft:SetGradient("HORIZONTAL",
        CreateColor(DIVIDER_COLOR_R, DIVIDER_COLOR_G, DIVIDER_COLOR_B, 0),
        CreateColor(DIVIDER_COLOR_R, DIVIDER_COLOR_G, DIVIDER_COLOR_B, DIVIDER_ALPHA))

    -- Right line: fades from visible (near text) to transparent (right edge)
    local lineRight = parent:CreateTexture(nil, "ARTWORK")
    lineRight:SetTexture(SOLID)
    lineRight:SetHeight(1)
    lineRight:ClearAllPoints()
    lineRight:SetPoint("LEFT", label, "RIGHT", 8, 0)
    lineRight:SetPoint("RIGHT", parent, "RIGHT", -PAD, 0)
    lineRight:SetPoint("TOP", label, "CENTER", 0, 0)
    lineRight:SetHeight(1)
    lineRight:SetGradient("HORIZONTAL",
        CreateColor(DIVIDER_COLOR_R, DIVIDER_COLOR_G, DIVIDER_COLOR_B, DIVIDER_ALPHA),
        CreateColor(DIVIDER_COLOR_R, DIVIDER_COLOR_G, DIVIDER_COLOR_B, 0))

    return label:GetStringHeight() or 12
end

local function BuildLeftPanel()
    if leftBuilt then return end
    leftBuilt = true

    -- Start below header (title + subtitle + gap)
    local yOffset = -PAD - 18 - 3 - 12 - 20
    local globalIdx = 0

    for _, cat in ipairs(categories) do
        -- Category divider
        local divH = CreateCategoryDivider(leftPanel, cat.name, yOffset, cat.disabled)
        yOffset = yOffset - divH - 10

        -- Questline rows under this category
        for _, data in ipairs(cat.questlines) do
            globalIdx = globalIdx + 1
            local idx = globalIdx

            local row = CreateFrame("Frame", nil, leftPanel)
            row:EnableMouse(true)
            row:SetHeight(ROW_HEIGHT)
            row:SetPoint("TOPLEFT", 6, yOffset)
            row:SetPoint("RIGHT", leftPanel, "RIGHT", -6, 0)

            -- Selected background: warm fading
            local SR, SG, SB = 0.18, 0.16, 0.12
            local selBgL = row:CreateTexture(nil, "BACKGROUND")
            selBgL:SetTexture(SOLID)
            selBgL:SetPoint("TOPLEFT")
            selBgL:SetPoint("BOTTOMRIGHT", row, "BOTTOM")
            selBgL:SetGradient("HORIZONTAL", CreateColor(SR, SG, SB, 0), CreateColor(SR, SG, SB, 0.7))
            selBgL:Hide()

            local selBgR = row:CreateTexture(nil, "BACKGROUND")
            selBgR:SetTexture(SOLID)
            selBgR:SetPoint("TOPLEFT", row, "TOP")
            selBgR:SetPoint("BOTTOMRIGHT")
            selBgR:SetGradient("HORIZONTAL", CreateColor(SR, SG, SB, 0.7), CreateColor(SR, SG, SB, 0))
            selBgR:Hide()

            -- Selected fading lines (warm gold)
            local selTopL, selTopR = CreateFadingLine(row, 0.75, 0.65, 0.45, 0.35, 1, "ARTWORK", 2)
            selTopL:SetPoint("TOPLEFT", 4, 0)
            selTopL:SetPoint("RIGHT", row, "CENTER", 0, 0)
            selTopR:SetPoint("LEFT", row, "CENTER", 0, 0)
            selTopR:SetPoint("TOPRIGHT", -4, 0)
            selTopL:Hide(); selTopR:Hide()

            local selBotL, selBotR = CreateFadingLine(row, 0.75, 0.65, 0.45, 0.35, 1, "ARTWORK", 2)
            selBotL:SetPoint("BOTTOMLEFT", 4, 0)
            selBotL:SetPoint("RIGHT", row, "CENTER", 0, 0)
            selBotR:SetPoint("LEFT", row, "CENTER", 0, 0)
            selBotR:SetPoint("BOTTOMRIGHT", -4, 0)
            selBotL:Hide(); selBotR:Hide()

            -- Hover background: light white fading
            local HW = 0.25
            local hovBgL = row:CreateTexture(nil, "BACKGROUND", nil, 1)
            hovBgL:SetTexture(SOLID)
            hovBgL:SetPoint("TOPLEFT")
            hovBgL:SetPoint("BOTTOMRIGHT", row, "BOTTOM")
            hovBgL:SetGradient("HORIZONTAL", CreateColor(HW, HW, HW, 0), CreateColor(HW, HW, HW, 0.3))
            hovBgL:Hide()

            local hovBgR = row:CreateTexture(nil, "BACKGROUND", nil, 1)
            hovBgR:SetTexture(SOLID)
            hovBgR:SetPoint("TOPLEFT", row, "TOP")
            hovBgR:SetPoint("BOTTOMRIGHT")
            hovBgR:SetGradient("HORIZONTAL", CreateColor(HW, HW, HW, 0.3), CreateColor(HW, HW, HW, 0))
            hovBgR:Hide()

            -- Hover fading lines (light white)
            local hovTopL, hovTopR = CreateFadingLine(row, 0.8, 0.8, 0.8, 0.2, 1, "ARTWORK", 3)
            hovTopL:SetPoint("TOPLEFT", 4, 0)
            hovTopL:SetPoint("RIGHT", row, "CENTER", 0, 0)
            hovTopR:SetPoint("LEFT", row, "CENTER", 0, 0)
            hovTopR:SetPoint("TOPRIGHT", -4, 0)
            hovTopL:Hide(); hovTopR:Hide()

            local hovBotL, hovBotR = CreateFadingLine(row, 0.8, 0.8, 0.8, 0.2, 1, "ARTWORK", 3)
            hovBotL:SetPoint("BOTTOMLEFT", 4, 0)
            hovBotL:SetPoint("RIGHT", row, "CENTER", 0, 0)
            hovBotR:SetPoint("LEFT", row, "CENTER", 0, 0)
            hovBotR:SetPoint("BOTTOMRIGHT", -4, 0)
            hovBotL:Hide(); hovBotR:Hide()

            -- Spellbook-style icon with spell slot background
            local iconBtn = CreateFrame("Button", nil, row)
            iconBtn:SetSize(24, 24)
            iconBtn:SetPoint("LEFT", 10, 0)

            -- Spell slot background (dark square behind the icon)
            local iconBg = iconBtn:CreateTexture(nil, "BACKGROUND")
            iconBg:SetAllPoints()
            iconBg:SetTexture("Interface\\Buttons\\UI-Quickslot")
            iconBg:SetTexCoord(0.15, 0.85, 0.15, 0.85)

            -- Spell icon
            local icon = iconBtn:CreateTexture(nil, "BORDER")
            icon:SetAllPoints()
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

            -- Spellbook border on top
            iconBtn:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
            local normalTex = iconBtn:GetNormalTexture()
            normalTex:ClearAllPoints()
            normalTex:SetPoint("CENTER", iconBtn, "CENTER", 0, 0)
            normalTex:SetSize(42, 42)

            local iconBorder = iconBtn  -- alias for anchor references
            if data.achievementID then
                local _, _, _, _, _, _, _, _, _, achIcon = GetAchievementInfo(data.achievementID)
                if achIcon then icon:SetTexture(achIcon) end
            end

            -- Container to hold title + subline as a centered group
            local textGroup = CreateFrame("Frame", nil, row)
            textGroup:SetPoint("LEFT", iconBorder, "RIGHT", 4, 0)
            textGroup:SetPoint("RIGHT", row, "RIGHT", -8, 0)
            textGroup:SetPoint("TOP", row, "TOP")
            textGroup:SetPoint("BOTTOM", row, "BOTTOM")

            -- Title
            local label = textGroup:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            label:SetPoint("LEFT")
            label:SetPoint("RIGHT")
            label:SetPoint("BOTTOM", textGroup, "CENTER", 0, 0)
            label:SetJustifyH("LEFT")
            label:SetJustifyV("BOTTOM")
            label:SetWordWrap(false)
            label:SetText(data.title)

            -- "Active" subline
            local activeLabel = textGroup:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
            activeLabel:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -1)
            activeLabel:SetJustifyH("LEFT")
            activeLabel:SetText("|cff66bb44Active|r")
            activeLabel:Hide()

            row:SetScript("OnEnter", function()
                if idx ~= selectedIndex then
                    hovBgL:Show(); hovBgR:Show()
                    hovTopL:Show(); hovTopR:Show()
                    hovBotL:Show(); hovBotR:Show()
                end
            end)
            row:SetScript("OnLeave", function()
                hovBgL:Hide(); hovBgR:Hide()
                hovTopL:Hide(); hovTopR:Hide()
                hovBotL:Hide(); hovBotR:Hide()
            end)
            row:SetScript("OnMouseUp", function()
                SelectQuestline(idx)
            end)

            leftRows[idx] = {
                selBgL = selBgL, selBgR = selBgR,
                selTopL = selTopL, selTopR = selTopR,
                selBotL = selBotL, selBotR = selBotR,
                activeLabel = activeLabel, label = label,
                iconBorder = iconBorder,
                data = data,
            }
            yOffset = yOffset - ROW_HEIGHT - 4
        end

        yOffset = yOffset - 10  -- gap after category section
    end
end

-- ============================================================================
-- OnShow / Refresh
-- ============================================================================

settingsPanel:SetScript("OnShow", function()
    C_Timer.After(0, function()
        BuildLeftPanel()
        local startIdx = (StoryModeDB and StoryModeDB.selectedQuestline) or 1
        if startIdx > #allQuestlines then startIdx = 1 end
        SelectQuestline(startIdx)
    end)
end)

-- ============================================================================
-- Register Questlines
-- ============================================================================

RegisterQuestline(SM.SuramarData, "Epic Storylines")
RegisterQuestline(SM.RogueCampaignData, "Class Identity")

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
