

if not ClassicPlusDB then ClassicPlusDB = {} end

local defaults = {
    -- Action Bars
    hideMacroNamesEnabled = false,
    hideKeybindsEnabled = false,
    actionBarFaderEnabled = false,
    actionBarRangeEnabled = false,
    hideStanceBarEnabled = false,
    -- Interface
    menuTransparencyEnabled = false,
    smallerExpBarEnabled = false,
    hideStanceBarEnabled = false,
    minimapClutterEnabled = false,
    enhanceTooltipEnabled = false,
    -- Unit Frames
    classHealthColorsEnabled = false,
    threatIndicatorEnabled = false,
    unitFrameDebuffsEnabled = false,
    unitFrameClassIconEnabled = false,
    hideUnitFrameCombatTextEnabled = false,
    -- Nameplates
    debuffTrackerEnabled = false,
    nameplateComboEnabled = false,
    nameplateCastNamesEnabled = false,
    nameplateClassHealthEnabled = false,
    raidTargetIconAlignedEnabled = false,
    -- Chat
    chatFilterEnabled = false,
    filterGuildRecruitEnabled = false,
    filterTradeBotsEnabled = false,
    filterGamblingEnabled = false,
    filterDuplicatesEnabled = false,
    filterRestedXPEnabled = false,
    chatCleanerEnabled = false,
    hideChatButtonsEnabled = false,
    -- Automations
    autoCarrotEnabled = false,
    autoCarrotSlot = 14,
    smartMacrosEnabled = false,
    autoSellGreys = false,
    autoRepair = false,
    -- Text
    enchantWarningEnabled = false,
    hideErrorMessagesEnabled = false,
    -- Immersion
    actionCamEnabled = false,
}

function ClassicPlus_InitializeSettings()
    for key, value in pairs(defaults) do
        if ClassicPlusDB[key] == nil then
            ClassicPlusDB[key] = value
        end
    end
end

-- Slash Command Handler
SLASH_CLASSICPLUS1 = "/cp"
SlashCmdList["CLASSICPLUS"] = function(msg)
    if ClassicPlus_OpenConfig then
        ClassicPlus_OpenConfig()
    else
        local success = pcall(ClassicPlus_OpenConfig)
        if not success then
            print("|cffff0000ClassicPlus:|r Config UI not loaded.")
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, addon)
    if addon == "ClassicPlus" then
        ClassicPlus_InitializeSettings()
    end
    
end)
