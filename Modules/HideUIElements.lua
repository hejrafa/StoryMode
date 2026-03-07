--[[ ClassicPlus - HideUIElements ]]
local f = CreateFrame("Frame")

-- Register events to catch the bars during login, spec changes, or stance swaps
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

local STANCE_BAR_FRAMES = { "StanceBar", "StanceBarFrame", "ShapeshiftBarFrame" }

local function ApplyStanceBarHide()
    if not ClassicPlusDB or not ClassicPlusDB.hideStanceBarEnabled then return end
    if InCombatLockdown() then return end

    if not CP_HiddenParent then
        CP_HiddenParent = CreateFrame("Frame")
        CP_HiddenParent:Hide()
    end

    for _, name in ipairs(STANCE_BAR_FRAMES) do
        local frame = _G[name]
        if frame then
            frame:UnregisterAllEvents()
            frame:Hide()
            frame:SetParent(CP_HiddenParent)

            if not frame.IsCPHooked then
                hooksecurefunc(frame, "SetShown", function(self, shown)
                    if shown and ClassicPlusDB and ClassicPlusDB.hideStanceBarEnabled and not InCombatLockdown() then
                        self:Hide()
                    end
                end)
                hooksecurefunc(frame, "Show", function(self)
                    if ClassicPlusDB and ClassicPlusDB.hideStanceBarEnabled and not InCombatLockdown() then
                        self:Hide()
                    end
                end)
                frame.IsCPHooked = true
            end
        end
    end
end

local function RestoreStanceBar()
    if ClassicPlusDB and ClassicPlusDB.hideStanceBarEnabled then return end
    if InCombatLockdown() then return end

    for _, name in ipairs(STANCE_BAR_FRAMES) do
        local frame = _G[name]
        if frame then
            frame:SetParent(UIParent)
            frame:Show()
        end
    end
end

local function UpdateActionBars()
    -- Ensure database is initialized
    if not ClassicPlusDB then return end

    -- 1. STANCE BAR LOGIC (combat-safe: no protected frame changes during combat)
    if ClassicPlusDB.hideStanceBarEnabled then
        ApplyStanceBarHide()
    else
        RestoreStanceBar()
    end

    -- 2. MACRO NAMES & KEYBIND TEXT LOGIC
    for i = 1, 12 do
        local buttons = {
            _G["ActionButton" .. i],
            _G["MultiBarBottomLeftButton" .. i],
            _G["MultiBarBottomRightButton" .. i],
            _G["MultiBarLeftButton" .. i],
            _G["MultiBarRightButton" .. i],
            _G["MultiBar5Button" .. i],
            _G["MultiBar6Button" .. i],
            _G["MultiBar7Button" .. i],
        }

        for _, btn in ipairs(buttons) do
            if btn then
                local hotkey = _G[btn:GetName() .. "HotKey"]
                local name = _G[btn:GetName() .. "Name"]

                -- Handle Keybinds (HotKey)
                if hotkey then
                    if ClassicPlusDB.hideKeybindsEnabled then
                        hotkey:SetAlpha(0)
                        if not hotkey.IsCPHooked then
                            hooksecurefunc(hotkey, "Show", function(self)
                                if ClassicPlusDB.hideKeybindsEnabled then self:SetAlpha(0) end
                            end)
                            hotkey.IsCPHooked = true
                        end
                    else
                        hotkey:SetAlpha(1)
                    end
                end

                -- Handle Macro Names (Name)
                if name then
                    if ClassicPlusDB.hideMacroNamesEnabled then
                        name:SetAlpha(0)
                        if not name.IsCPHooked then
                            hooksecurefunc(name, "Show", function(self)
                                if ClassicPlusDB.hideMacroNamesEnabled then self:SetAlpha(0) end
                            end)
                            name.IsCPHooked = true
                        end
                    else
                        name:SetAlpha(1)
                    end
                end
            end
        end
    end
end

f:SetScript("OnEvent", function()
    UpdateActionBars()
end)

-- Initial execution to set the state on login
UpdateActionBars()
