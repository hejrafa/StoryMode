local addonName, SM = ...

-- Saved variables defaults
local defaults = {
    version = "0.1.0",
}

-- Settings panel
local settingsPanel = CreateFrame("Frame", "StoryModeSettingsPanel")
settingsPanel.name = "StoryMode"

local title = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Story|cff64b5f6Mode|r")

local subtitle = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetText("A quest story companion for World of Warcraft.")

local version = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
version:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -4)
version:SetText("Version " .. defaults.version)

-- Register with Settings API
local category = Settings.RegisterCanvasLayoutCategory(settingsPanel, "StoryMode")
Settings.RegisterAddOnCategory(category)

-- Slash command
SLASH_STORYMODE1 = "/sm"
SLASH_STORYMODE2 = "/storymode"
SlashCmdList["STORYMODE"] = function(msg)
    Settings.OpenToCategory(category:GetID())
end

-- Initialization
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon ~= addonName then return end

    StoryModeDB = StoryModeDB or CopyTable(defaults)

    self:UnregisterEvent("ADDON_LOADED")
end)
