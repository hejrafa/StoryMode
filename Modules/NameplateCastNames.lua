--[[ ClassicPlus - NameplateCastNames ]]
-- Adds spell name text to enemy nameplate cast bars with high-reliability event tracking.

-- Minimum cast duration (seconds) to show spell text; shorter/instant casts have no cast bar.
local MIN_CAST_DURATION = 0.5

local function UpdateSpellName(plate, unit)
    if not plate or not plate.CP_CastText then return end
    if not ClassicPlusDB or not ClassicPlusDB.nameplateCastNamesEnabled then
        plate.CP_CastText:SetText("")
        plate.CP_CastText:Hide()
        return
    end

    -- Prefer cast, then channel; only show when duration is long enough (real cast bar).
    local name, _, _, startTimeMS, endTimeMS = UnitCastingInfo(unit)
    local durationSec = (name and endTimeMS and startTimeMS) and (endTimeMS - startTimeMS) / 1000 or 0
    if not name or durationSec < MIN_CAST_DURATION then
        name, _, _, startTimeMS, endTimeMS = UnitChannelInfo(unit)
        durationSec = (name and endTimeMS and startTimeMS) and (endTimeMS - startTimeMS) / 1000 or 0
    end
    if not name or durationSec < MIN_CAST_DURATION then
        name = nil
    end

    -- Filter out false-positives like "Fishing" for non-player units
    if name == "Fishing" and not UnitIsPlayer(unit) then
        name = nil
    end

    if name then
        plate.CP_CastText:SetText(name)
        plate.CP_CastText:Show()
    else
        -- Don't clear "Interrupted" — let the interrupt timer clear it
        if plate.CP_CastText:GetText() == "Interrupted" then return end
        -- Explicitly clear and hide when not casting to prevent "stuck" text
        plate.CP_CastText:SetText("")
        plate.CP_CastText:Hide()
    end
end

local function SetupPlate(plate, unit)
    if not plate or plate.CP_CastText then return end

    local castBar = plate.UnitFrame and plate.UnitFrame.CastBar or plate.CastBar

    -- Always parent to plate (safe on every load state). Set our level just
    -- above the castbar instead of the old plate + 10, which was forcing WoW
    -- to re-sort sibling frame levels and scrambling the castbar/border order.
    local textContainer = CreateFrame("Frame", nil, plate)
    textContainer:SetAllPoints(plate)
    local targetLevel = 0
    if castBar and type(castBar.GetFrameLevel) == "function" then
        targetLevel = (castBar:GetFrameLevel() or 0) + 2
    else
        targetLevel = (plate:GetFrameLevel() or 0) + 2
    end
    textContainer:SetFrameLevel(targetLevel)

    -- Font size adjusted to 7
    local text = textContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetFont(text:GetFont(), 7)

    if castBar and type(castBar.GetFrameLevel) == "function" then
        text:SetPoint("CENTER", castBar, "CENTER", 8, -16)
    else
        text:SetPoint("CENTER", plate, "CENTER", 8, -26)
    end

    text:SetTextColor(1, 1, 1)
    text:SetShadowColor(0, 0, 0, 1)
    text:SetShadowOffset(1, -1)

    plate.CP_CastText = text

    UpdateSpellName(plate, unit)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("UNIT_SPELLCAST_START")
frame:RegisterEvent("UNIT_SPELLCAST_STOP")
frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_ENTERING_WORLD" then
        for _, plate in pairs(C_NamePlate.GetNamePlates()) do
            local plateUnit = plate.namePlateUnitToken or (plate.UnitFrame and plate.UnitFrame.unit)
            if plateUnit then
                SetupPlate(plate, plateUnit)
            end
        end
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate then
            SetupPlate(plate, unit)
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        -- unit can be "target", "focus", or nameplate token; ensure we get the nameplate
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if not plate and unit == "target" then
            -- Fallback: find nameplate whose unit is current target
            for _, p in pairs(C_NamePlate.GetNamePlates()) do
                local plateUnit = p.namePlateUnitToken or (p.UnitFrame and p.UnitFrame.unit)
                if plateUnit and UnitExists("target") and UnitIsUnit(plateUnit, "target") then
                    plate = p
                    unit = plateUnit
                    break
                end
            end
        end
        if plate and ClassicPlusDB and ClassicPlusDB.nameplateCastNamesEnabled then
            if not plate.CP_CastText then
                SetupPlate(plate, unit)
            end
            if plate.CP_CastText then
                plate.CP_CastText:SetText("Interrupted")
                plate.CP_CastText:Show()
                C_Timer.After(1.1, function()
                    if plate and plate.CP_CastText and plate.CP_CastText:GetText() == "Interrupted" then
                        plate.CP_CastText:SetText("")
                        plate.CP_CastText:Hide()
                    end
                end)
            end
        end
    elseif event:find("UNIT_SPELLCAST") then
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate then
            UpdateSpellName(plate, unit)
        end
    end
end)

-- Safety Ticker: Since nameplates can be finicky with data loading
C_Timer.NewTicker(0.5, function()
    if not ClassicPlusDB or not ClassicPlusDB.nameplateCastNamesEnabled then return end
    for _, plate in pairs(C_NamePlate.GetNamePlates()) do
        local unit = plate.namePlateUnitToken or (plate.UnitFrame and plate.UnitFrame.unit)
        if unit then
            -- Only run full update if actually needed (is casting/channeling or text is visible)
            if UnitCastingInfo(unit) or UnitChannelInfo(unit) or (plate.CP_CastText and plate.CP_CastText:IsShown()) then
                if not plate.CP_CastText then
                    SetupPlate(plate, unit)
                else
                    UpdateSpellName(plate, unit)
                end
            end
        end
    end
end)
