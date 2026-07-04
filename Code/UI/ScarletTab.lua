local _, SM = ...
local L = SM.L

local SCARLET_CAPSTONE_THRESHOLD = 5000
local LEDGER_PAGES = { 250, 500, 1000 }

-- Named Crusade figures whose deaths earn a ledger entry. Matched by NPC ID
-- (locale-safe) with an exact enUS name fallback in case an ID drifts between
-- client flavors. Display order is this table's order.
SM.ScarletNamedTargets = {
    { key = "Thalnos",   npcID = 4543,  name = "Bloodmage Thalnos" },
    { key = "Vishas",    npcID = 3983,  name = "Interrogator Vishas" },
    { key = "Loksey",    npcID = 3974,  name = "Houndmaster Loksey" },
    { key = "Doan",      npcID = 6487,  name = "Arcanist Doan" },
    { key = "Herod",     npcID = 3975,  name = "Herod" },
    { key = "Mograine",  npcID = 3976,  name = "Scarlet Commander Mograine" },
    { key = "Fairbanks", npcID = 4542,  name = "High Inquisitor Fairbanks" },
    { key = "Whitemane", npcID = 3977,  name = "High Inquisitor Whitemane" },
    { key = "Courier",   npcID = 12337, name = "Crimson Courier" },
    { key = "Demetria",  npcID = 12339, name = "Demetria" },
}

function SM.GetScarletNamedTargetKey(npcID, destName)
    for _, target in ipairs(SM.ScarletNamedTargets) do
        if (npcID and target.npcID == npcID) or (destName and target.name == destName) then
            return target.key
        end
    end
    return nil
end

local function ComposeScarletBody()
    local body = L["Scarlet Tab Body"]
    local count = SM.GetScarletKillCount and SM.GetScarletKillCount() or 0
    for _, threshold in ipairs(LEDGER_PAGES) do
        if count >= threshold then
            body = body .. "\n\n" .. L["Scarlet Tab Body " .. threshold]
        end
    end
    return body
end

local function ComposeScarletNames()
    local recorded = SM.GetScarletNamedKills and SM.GetScarletNamedKills() or nil
    if not recorded then return nil end
    local lines = {}
    for _, target in ipairs(SM.ScarletNamedTargets) do
        if recorded[target.key] then
            lines[#lines + 1] = L["Scarlet Ledger " .. target.key]
        end
    end
    if #lines == 0 then return nil end
    return table.concat(lines, "\n")
end

local function GetScarletWarDateLine()
    if not SM.GetScarletWarTimestamps then return nil end
    local firstKillAt, revealedAt = SM.GetScarletWarTimestamps()
    local startedAt = firstKillAt or revealedAt
    if not startedAt then return nil end
    return string.format(L["Scarlet War Began Format"], date(L["Scarlet War Date Pattern"], startedAt))
end

function SM.LayoutScarletTab(data, w, contentW, visibleContentW)
    local ui = SM.DetailUI
    local detailChild = ui.detailChild
    local CP = ui.CP
    local sScarletTitle = ui.sScarletTitle
    local sScarletCount = ui.sScarletCount
    local sScarletCountBtn = ui.sScarletCountBtn
    local sScarletDate = ui.sScarletDate
    local sScarletBody = ui.sScarletBody
    local sScarletNamesHeader = ui.sScarletNamesHeader
    local sScarletNames = ui.sScarletNames

    SM.FactionUI:HideAll()

    sScarletTitle:ClearAllPoints()
    sScarletTitle:SetPoint("TOP", detailChild, "TOP", 0, -18)
    sScarletTitle:Show()

    local count = SM.GetScarletKillCount and SM.GetScarletKillCount() or 0
    if count >= SCARLET_CAPSTONE_THRESHOLD then
        sScarletCount:SetText(L["Scarlet Stopped Counting"])
    else
        sScarletCount:SetText(string.format(L["Scarlet Crusader Note Format"], count))
    end
    sScarletCount:ClearAllPoints()
    sScarletCount:SetPoint("TOP", sScarletTitle, "BOTTOM", 0, -4)
    sScarletCount:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
    sScarletCount:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
    if contentW > 20 then sScarletCount:SetWidth(contentW) end
    sScarletCount:Show()

    sScarletCountBtn:ClearAllPoints()
    sScarletCountBtn:SetPoint("CENTER", sScarletCount, "CENTER", 0, 0)
    sScarletCountBtn:SetSize(math.max(sScarletCount:GetStringWidth(), 50), sScarletCount:GetStringHeight() + 6)
    sScarletCountBtn:Show()

    local dateLine = GetScarletWarDateLine()
    local bodyAnchor = sScarletCount
    if dateLine then
        sScarletDate:SetText(dateLine)
        sScarletDate:ClearAllPoints()
        sScarletDate:SetPoint("TOP", sScarletCount, "BOTTOM", 0, -4)
        sScarletDate:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
        sScarletDate:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
        sScarletDate:Show()
        bodyAnchor = sScarletDate
    else
        sScarletDate:Hide()
    end

    sScarletBody:SetText(ComposeScarletBody())
    sScarletBody:ClearAllPoints()
    sScarletBody:SetPoint("TOP", bodyAnchor, "BOTTOM", 0, -18)
    sScarletBody:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
    sScarletBody:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
    if contentW > 20 then sScarletBody:SetWidth(contentW) end
    sScarletBody:Show()

    local bottomEl = sScarletBody
    local namesText = ComposeScarletNames()
    if namesText then
        sScarletNamesHeader:ClearAllPoints()
        sScarletNamesHeader:SetPoint("TOP", sScarletBody, "BOTTOM", 0, -24)
        sScarletNamesHeader:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
        sScarletNamesHeader:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
        sScarletNamesHeader:Show()

        sScarletNames:SetText(namesText)
        sScarletNames:ClearAllPoints()
        sScarletNames:SetPoint("TOP", sScarletNamesHeader, "BOTTOM", 0, -8)
        sScarletNames:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
        sScarletNames:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
        if contentW > 20 then sScarletNames:SetWidth(contentW) end
        sScarletNames:Show()
        bottomEl = sScarletNames
    else
        sScarletNamesHeader:Hide()
        sScarletNames:Hide()
    end

    local scarletBottomEl = bottomEl
    -- Set scroll height
    C_Timer.After(0, function()
        local bot = scarletBottomEl:GetBottom()
        local top = detailChild:GetTop()
        if bot and top then
            detailChild:SetHeight(math.max(top - bot + 40, 400))
        else
            detailChild:SetHeight(500)
        end
    end)
end

-- ── World tooltip: living Scarlet mobs get one quiet ledger line ─────────────
-- Post-call line appends never touch secure tooltip internals, unlike owning
-- the GameTooltip (see Code/UI/Tooltip.lua for why SMTooltip is separate).

local function AddLedgerTooltipLine(tooltip, unit)
    if not unit then return end
    if not (SM.IsScarletCrusaderRevealed and SM.IsScarletCrusaderRevealed()) then return end
    if UnitIsPlayer(unit) or not UnitCanAttack("player", unit) then return end
    if UnitIsDead and UnitIsDead(unit) then return end
    local name = UnitName(unit)
    if not (SM.IsScarletMobName and SM.IsScarletMobName(name)) then return end
    tooltip:AddLine(L["Scarlet Tooltip Line"], 0.90, 0.16, 0.16)
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
    and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Unit then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
        if tooltip ~= GameTooltip then return end
        local _, unit = tooltip:GetUnit()
        AddLedgerTooltipLine(tooltip, unit)
    end)
elseif GameTooltip and GameTooltip.HookScript then
    GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
        local _, unit = tooltip:GetUnit()
        AddLedgerTooltipLine(tooltip, unit)
    end)
end
