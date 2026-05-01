local addonName, SM = ...
local L = SM.L

-- Exposed for Code/Core/Progress.lua so lore/replayable chapter progress can read
-- the selected story without coupling that module to the UI implementation.
local currentStoryData = nil  -- assigned by UpdateStoryDetail
function SM.GetCurrentStoryData()
    return currentStoryData
end

-- ============================================================================
-- Achievement Resolver — find achievement ID by name at runtime
-- ============================================================================

local function ResolveAchievementID(data)
    local faction = UnitFactionGroup("player")
    if data.achievementIDByFaction then
        data.achievementID = data.achievementIDByFaction[faction] or data.achievementID
    end
    if data.achievementsByFaction then
        data.achievements = data.achievementsByFaction[faction] or data.achievements
    end

    if data.achievementID then
        local _, name = GetAchievementInfo(data.achievementID)
        if name then return end  -- ID is valid
    end
    -- Search by name across achievement ID ranges
    if data.achievementName then
        for id = 1, 50000 do
            local _, name = GetAchievementInfo(id)
            if name == data.achievementName then
                data.achievementID = id
                return
            end
        end
    end
end

-- ============================================================================
-- Core helper aliases
-- ============================================================================

local IsQuestForPlayer = SM.IsQuestForPlayer
local ShouldHideQuest = SM.ShouldHideQuest
local IsQuestEffectivelyComplete = SM.IsQuestEffectivelyComplete
local IsQuestInLog = SM.IsQuestInLog
local GetAllChapters = SM.GetAllChapters
local GetStoryAchievements = SM.GetStoryAchievements
local GetStoryFactions = SM.GetStoryFactions
local GetCampaignProgress = SM.GetCampaignProgress
local GetChapterProgress = SM.GetChapterProgress
local GetFirstUnmetChapterPrerequisite = SM.GetFirstUnmetChapterPrerequisite
local GetQuestLockReason = SM.GetQuestLockReason
local GetQuestlineGateReason = SM.GetQuestlineGateReason
local FindNextQuest = SM.FindNextQuest
local SetWaypointForQuest = SM.SetWaypointForQuest
local PrintTrackResult = SM.PrintTrackResult

-- ============================================================================
-- UI Constants & Helpers
-- ============================================================================

local function HexColor(r, g, b)
    return string.format("%02x%02x%02x",
        math.min(255, math.floor(r * 255)),
        math.min(255, math.floor(g * 255)),
        math.min(255, math.floor(b * 255)))
end

-- ============================================================================
-- Category & Questline Registry
-- ============================================================================

local categories = {
    { name = "Epic Storylines", displayName = L["Category Epic Storylines"], questlines = {} },
    { name = "Character Stories", displayName = L["Category Character Stories"], questlines = {} },
    { name = "Short Stories", displayName = L["Category Short Stories"], questlines = {} },
    { name = "Identity", displayName = string.format(L["Category Identity Format"], UnitRace("player"), UnitClass("player")), questlines = {} },
    { name = "More Coming Soon", displayName = L["Category More Coming Soon"], disabled = true, questlines = {} },
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
-- Player filtering helpers
-- ============================================================================

local _, playerClass = UnitClass("player")   -- English token: "ROGUE", "WARRIOR", etc.
local playerFaction = UnitFactionGroup("player")  -- "Horde" or "Alliance"
local playerRace = select(2, UnitRace("player"))  -- English token: "Human", "Orc", etc.

local function CanShowQuestline(data)
    if not data then return false end
    if not SM.IsContentAvailableForClient(data) then return false end
    if data.class and data.class ~= playerClass then return false end
    if data.faction and data.faction ~= playerFaction then return false end
    if data.race and data.race ~= playerRace then return false end
    return true
end

-- ============================================================================
-- Localize Questline Content
-- ============================================================================

local contentData = {}
local function AddContentData(data)
    if data then contentData[#contentData + 1] = data end
end

AddContentData(SM.FrozenThroneData)
AddContentData(SM.DefiasBrotherhoodData)
AddContentData(SM.DuskwoodData)
AddContentData(SM.FallenHeroData)
AddContentData(SM.MissingDiplomatData)
AddContentData(SM.OnyxiaData)
AddContentData(SM.ScarletCrusadeData)
AddContentData(SM.JadeForestData)
AddContentData(SM.SuramarData)
AddContentData(SM.NazmirData)
AddContentData(SM.RevendrethData)
AddContentData(SM.DrustvarData)
AddContentData(SM.SylvanasData)
AddContentData(SM.JainaData)
AddContentData(SM.LilianVossData)
AddContentData(SM.TeddiesAndTeaData)
AddContentData(SM.MankriksWifeData)
AddContentData(SM.ClassicDruidQuestData)
AddContentData(SM.ClassicHunterQuestData)
AddContentData(SM.ClassicMageQuestData)
AddContentData(SM.ClassicPaladinQuestData)
AddContentData(SM.ClassicPriestQuestData)
AddContentData(SM.ClassicRogueQuestData)
AddContentData(SM.ClassicShamanQuestData)
AddContentData(SM.ClassicWarlockQuestData)
AddContentData(SM.ClassicWarriorQuestData)
AddContentData(SM.DeathKnightCampaignData)
AddContentData(SM.DemonHunterCampaignData)
AddContentData(SM.DruidCampaignData)
AddContentData(SM.HunterCampaignData)
AddContentData(SM.MageCampaignData)
AddContentData(SM.MonkCampaignData)
AddContentData(SM.PaladinCampaignData)
AddContentData(SM.PriestCampaignData)
AddContentData(SM.RogueCampaignData)
AddContentData(SM.ShamanCampaignData)
AddContentData(SM.WarlockCampaignData)
AddContentData(SM.WarriorCampaignData)
AddContentData(SM.ForsakenHeritageData)
AddContentData(SM.BloodElfHeritageData)
AddContentData(SM.GoblinHeritageData)
AddContentData(SM.TrollHeritageData)
AddContentData(SM.OrcHeritageData)
AddContentData(SM.TaurenHeritageData)
AddContentData(SM.HumanHeritageData)
AddContentData(SM.DwarfHeritageData)
AddContentData(SM.GnomeHeritageData)
AddContentData(SM.NightElfHeritageData)
AddContentData(SM.WorgenHeritageData)
AddContentData(SM.DraeneiHeritageData)
AddContentData(SM.PandarenHeritageData)
AddContentData(SM.DarkIronHeritageData)

for _, data in ipairs(contentData) do
    SM.LocalizeContentData(data)
end

-- ============================================================================
-- Register Questlines
-- ============================================================================

if CanShowQuestline(SM.DefiasBrotherhoodData) then
    RegisterQuestline(SM.DefiasBrotherhoodData, "Epic Storylines")
end
if CanShowQuestline(SM.DuskwoodData) then
    RegisterQuestline(SM.DuskwoodData, "Epic Storylines")
end
if CanShowQuestline(SM.MissingDiplomatData) then
    RegisterQuestline(SM.MissingDiplomatData, "Epic Storylines")
end
if CanShowQuestline(SM.ScarletCrusadeData) then
    RegisterQuestline(SM.ScarletCrusadeData, "Epic Storylines")
end
if CanShowQuestline(SM.FallenHeroData) then
    RegisterQuestline(SM.FallenHeroData, "Epic Storylines")
end
if CanShowQuestline(SM.OnyxiaData) then
    RegisterQuestline(SM.OnyxiaData, "Epic Storylines")
end
if CanShowQuestline(SM.FrozenThroneData) then
    RegisterQuestline(SM.FrozenThroneData, "Epic Storylines")
end
if CanShowQuestline(SM.JadeForestData) then
    RegisterQuestline(SM.JadeForestData, "Epic Storylines")
end
if CanShowQuestline(SM.SuramarData) then
    RegisterQuestline(SM.SuramarData, "Epic Storylines")
end
if CanShowQuestline(SM.NazmirData) then
    RegisterQuestline(SM.NazmirData, "Epic Storylines")
end
if CanShowQuestline(SM.RevendrethData) then
    RegisterQuestline(SM.RevendrethData, "Epic Storylines")
end
if CanShowQuestline(SM.DrustvarData) then
    RegisterQuestline(SM.DrustvarData, "Epic Storylines")
end
if CanShowQuestline(SM.SylvanasData) then
    RegisterQuestline(SM.SylvanasData, "Character Stories")
end
if CanShowQuestline(SM.JainaData) then
    RegisterQuestline(SM.JainaData, "Character Stories")
end
if CanShowQuestline(SM.LilianVossData) then
    RegisterQuestline(SM.LilianVossData, "Character Stories")
end
if CanShowQuestline(SM.TeddiesAndTeaData) then
    RegisterQuestline(SM.TeddiesAndTeaData, "Short Stories")
end
if CanShowQuestline(SM.MankriksWifeData) then
    RegisterQuestline(SM.MankriksWifeData, "Short Stories")
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
    if CanShowQuestline(data) then
        RegisterQuestline(data, "Identity")
    end
end

if SM.ForsakenHeritageData then
    if CanShowQuestline(SM.ForsakenHeritageData) then
        RegisterQuestline(SM.ForsakenHeritageData, "Identity")
    end
end

local heritageQuestlines = {
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
    if data and CanShowQuestline(data) then
        RegisterQuestline(data, "Identity")
    end
end


-- ============================================================================
-- Story Mode Window  —  Trading-Post-style clean dark panels
-- ============================================================================

local SMTooltip = SM.Tooltip

-- Node ring colors — module-scoped so both the track builder and
-- LayoutSelectedChapter can restore per-state colors after selection changes.
local RING_GREEN_R, RING_GREEN_G, RING_GREEN_B = 0.35, 0.78, 0.28
local RING_GOLD_R,  RING_GOLD_G,  RING_GOLD_B  = 1.0,  0.82, 0.35

local FRAME_W  = 1012
local FRAME_H  = 550
local LEFT_W   = 274
local GAP      = 6
local RIGHT_W  = 732   -- FRAME_W - LEFT_W - GAP
local HEADER_H = 68
local SOLID    = "Interface\\Buttons\\WHITE8x8"
local STORYMODE_ICON_TEXTURE = "Interface\\AddOns\\StoryMode\\Art\\Icons\\storymode_icon"
local STORYMODE_HERO_TEXTURE = "Interface\\AddOns\\StoryMode\\Art\\Hero\\storymode_hero"
SM.ClassicCardTexture = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight"
SM.ClassicCardBorder = "Interface\\Tooltips\\UI-Tooltip-Border"
SM.ClassicPortraitRing = "Interface\\Common\\portrait-ring-withbg"
SM.ClassicPortraitRingFallback = "Interface\\Buttons\\GoldRing64"
SM.PanelScrollBottomInset = 4

-- Color palette
local C_BODY = {0.922, 0.871, 0.761}
local C_GOLD = {1,     0.82,  0}
local C_DIM  = {0.50,  0.50,  0.50}
local C_DIVIDER = {1.0, 0.80, 0.45}

local function NoShadow(fs) fs:SetShadowOffset(0,0); return fs end

function SM.SafeSetTexture(tex, path)
    if not tex or not path then return false end
    local ok = pcall(tex.SetTexture, tex, path)
    return ok and tex:GetTexture() ~= nil
end

function SM.SafeSetAtlas(tex, atlas, useAtlasSize)
    if not tex or not tex.SetAtlas or not atlas then return false end
    if not (SM.Client and SM.Client.isRetail) then return false end
    if C_Texture and C_Texture.GetAtlasInfo and not C_Texture.GetAtlasInfo(atlas) then
        return false
    end

    local ok = pcall(tex.SetAtlas, tex, atlas, useAtlasSize)
    return ok and (not tex.GetAtlas or tex:GetAtlas() == atlas)
end

function SM.SetSolidTexture(tex, r, g, b, a)
    tex:SetTexture(SOLID)
    tex:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
end

function SM.SafeSetButtonHighlight(button, atlas, alpha)
    if button.SetHighlightAtlas and SM.SafeSetAtlas(button, atlas, false) then
        local highlight = button:GetHighlightTexture()
        if highlight then
            highlight:SetAllPoints()
            if alpha then highlight:SetAlpha(alpha) end
        end
        return true
    end

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    SM.SetSolidTexture(highlight, 1, 0.82, 0.35, alpha or 0.18)
    highlight:SetAllPoints(button)
    button:SetHighlightTexture(highlight)
    return false
end

function SM.SetStoryArrowTexture(tex, direction, large)
    if not tex then return end
    tex:SetRotation(0)

    if large == "money" then
        if direction == "left" then
            SM.SafeSetTexture(tex, "Interface\\MoneyFrame\\Arrow-Left-Up")
        else
            SM.SafeSetTexture(tex, "Interface\\MoneyFrame\\Arrow-Right-Up")
        end
        return
    end

    if large or (SM.Client and SM.Client.isRetail) then
        if not SM.SafeSetAtlas(tex, "common-icon-forwardarrow", false) then
            SM.SafeSetTexture(tex, "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        end
        if direction == "left" then
            tex:SetRotation(math.pi)
        elseif direction == "down" then
            tex:SetRotation(-math.pi / 2)
        end
        return
    end

    SM.SafeSetTexture(tex, "Interface\\RAIDFRAME\\UI-RAIDFRAME-ARROW")
    if direction == "down" then
        tex:SetRotation(-math.pi / 2)
    elseif direction == "left" then
        tex:SetRotation(math.pi)
    end
end

function SM.CreateSimpleBorder(parent, thickness, level)
    local border = {}
    thickness = thickness or 1
    level = level or "OVERLAY"

    border.top = parent:CreateTexture(nil, level)
    border.top:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    border.top:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    border.top:SetHeight(thickness)

    border.bottom = parent:CreateTexture(nil, level)
    border.bottom:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    border.bottom:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    border.bottom:SetHeight(thickness)

    border.left = parent:CreateTexture(nil, level)
    border.left:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    border.left:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    border.left:SetWidth(thickness)

    border.right = parent:CreateTexture(nil, level)
    border.right:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    border.right:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    border.right:SetWidth(thickness)

    return border
end

function SM.SetSimpleBorder(border, r, g, b, a)
    if not border then return end
    for _, tex in pairs(border) do
        SM.SetSolidTexture(tex, r, g, b, a)
    end
end

function SM.ApplyClassicCardBackdrop(frame, bgAlpha, borderAlpha)
    if not frame or not frame.SetBackdrop then return end
    frame:SetBackdrop({
        bgFile = SOLID,
        edgeFile = SM.ClassicCardBorder,
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0.035, 0.030, 0.026, bgAlpha or 0.46)
    frame:SetBackdropBorderColor(0.72, 0.56, 0.30, borderAlpha or 0.62)
end

function SM.ClearCardFillTexture(tex)
    if not tex then return end
    tex:SetTexture(SOLID)
    tex:SetVertexColor(0, 0, 0, 0)
end

function SM.SetSubtleCardHover(button, mask)
    if not button then return end
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    if not SM.SafeSetTexture(highlight, "Interface\\QuestFrame\\UI-QuestLogTitleHighlight") then
        SM.SetSolidTexture(highlight, 0.92, 0.82, 0.58, 0.08)
    end
    highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
    highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
    highlight:SetVertexColor(0.92, 0.82, 0.58, 0.10)
    if mask then highlight:AddMaskTexture(mask) end
    button:SetHighlightTexture(highlight)
end

function SM.CreateInsetCardShade(parent, alpha, subLevel)
    if not parent then return nil end
    local shade = parent:CreateTexture(nil, "BACKGROUND", nil, subLevel or 1)
    SM.SetSolidTexture(shade, 0, 0, 0, alpha or 0.16)
    shade:SetPoint("TOPLEFT", parent, "TOPLEFT", 3, -3)
    shade:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -3, 3)
    shade:SetVertexColor(0, 0, 0, alpha or 0.16)
    return shade
end

-- ─── Panel frame (Trading Post NineSlice — actual Blizzard atlas textures) ───
local PERKS_LAYOUT = {
    TopLeftCorner     = { atlas = "Perks-List-NineSlice-CornerTopLeft", x = -31, y = 31 },
    TopRightCorner    = { atlas = "Perks-List-NineSlice-CornerTopLeft", mirrorLayout = true, x = 31, y = 31 },
    BottomLeftCorner  = { atlas = "Perks-List-NineSlice-CornerTopLeft", mirrorLayout = true, x = -31, y = -31 },
    BottomRightCorner = { atlas = "Perks-List-NineSlice-CornerTopLeft", mirrorLayout = true, x = 31, y = -31 },
    TopEdge           = { atlas = "_Perks-List-NineSlice-EdgeTop" },
    BottomEdge        = { atlas = "_Perks-List-NineSlice-EdgeTop", mirrorLayout = true },
    LeftEdge          = { atlas = "!Perks-List-NineSlice-EdgeLeft" },
    RightEdge         = { atlas = "!Perks-List-NineSlice-EdgeLeft", mirrorLayout = true },
    Center            = { atlas = "Perks-List-NineSlice-Center" },
}

local function CreateStoryPanel(section)
    local useRetailArt = SM.Client and SM.Client.isRetail
    local template = (useRetailArt and NineSliceUtil) and "NineSlicePanelTemplate" or "BackdropTemplate"
    local f = CreateFrame("Frame", nil, section, template)
    f:SetAllPoints(section)
    f:SetFrameLevel(section:GetFrameLevel())
    if useRetailArt and NineSliceUtil then
        local ok = pcall(NineSliceUtil.ApplyLayout, f, PERKS_LAYOUT)
        if ok then
            -- Tint border pieces gold-bronze
            local br, bg, bb = 1.0, 0.80, 0.45
            for _, key in ipairs({"TopLeftCorner","TopRightCorner","BottomLeftCorner","BottomRightCorner",
                                  "TopEdge","BottomEdge","LeftEdge","RightEdge"}) do
                if f[key] then f[key]:SetVertexColor(br, bg, bb) end
            end
            return f
        end
    end

    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile = SOLID,
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        f:SetBackdropColor(0.040, 0.035, 0.030, 0.76)
        f:SetBackdropBorderColor(1.0, 1.0, 1.0, 0.68)
    else
        local bg = f:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        SM.SetSolidTexture(bg, 0.040, 0.035, 0.030, 0.76)
    end
    return f
end

-- Blizzard scrollbar: ScrollFrameTemplate already provides one; just add
-- mouse-wheel support (the default template doesn't always wire it up).
local SCROLL_STEP = 40

local function EnableMouseWheelScroll(scrollFrame)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local range = self:GetVerticalScrollRange() or 0
        if range <= 0 then return end
        local cur = self:GetVerticalScroll() or 0
        local new = math.max(0, math.min(range, cur - delta * SCROLL_STEP))
        self:SetVerticalScroll(new)
    end)
end

function SM.GetScrollBar(scrollFrame)
    if not scrollFrame then return nil end
    return scrollFrame.ScrollBar
        or scrollFrame.Scrollbar
        or (scrollFrame.GetName and scrollFrame:GetName() and _G[scrollFrame:GetName() .. "ScrollBar"])
end

local function UpdateScrollbarVisibility(scrollFrame)
    local scrollbar = SM.GetScrollBar(scrollFrame)
    if not scrollbar then return end

    local range = scrollFrame:GetVerticalScrollRange() or 0
    if SM.Client and SM.Client.isRetail then
        if range > 1 then
            scrollbar:Show()
        else
            scrollFrame:SetVerticalScroll(0)
            scrollbar:Hide()
        end
    else
        if range <= 1 then scrollFrame:SetVerticalScroll(0) end
        scrollbar:Hide()
    end
end

function SM.StyleStoryScrollbar(scrollFrame)
    if not (SM.Client and SM.Client.isRetail) then return end
    local scrollbar = SM.GetScrollBar(scrollFrame)
    if not scrollbar then return end

    scrollbar:SetWidth(8)
    if not scrollbar.storyModeTrack then
        scrollbar.storyModeTrack = scrollbar:CreateTexture(nil, "BACKGROUND")
        scrollbar.storyModeTrack:SetPoint("TOP", scrollbar, "TOP", 0, -2)
        scrollbar.storyModeTrack:SetPoint("BOTTOM", scrollbar, "BOTTOM", 0, 2)
        scrollbar.storyModeTrack:SetWidth(4)
        SM.SetSolidTexture(scrollbar.storyModeTrack, 0.0, 0.0, 0.0, 0.48)
    end

    local thumb = (scrollbar.GetThumbTexture and scrollbar:GetThumbTexture()) or scrollbar.ThumbTexture
    if thumb then
        SM.SetSolidTexture(thumb, 0.72, 0.58, 0.32, 0.88)
        thumb:SetWidth(8)
    end

    for _, region in ipairs({ scrollbar:GetRegions() }) do
        if region ~= thumb and region.SetAlpha then region:SetAlpha(0.12) end
    end

    for _, child in ipairs({ scrollbar:GetChildren() }) do
        if child.SetAlpha then child:SetAlpha(0.45) end
        if child.SetSize then child:SetSize(12, 12) end
    end
end

-- ─── Major divider (Journeys renown divider atlas) ─────────────────────────
local function CreateMajorDivider(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight((SM.Client and SM.Client.isRetail) and 16 or 8)
    local tex = f:CreateTexture(nil, "ARTWORK")
    if SM.SafeSetAtlas(tex, "ui-journeys-renown-divider", false) then
        tex:SetPoint("LEFT",  f, "LEFT",  0, 0)
        tex:SetPoint("RIGHT", f, "RIGHT", 0, 0)
        tex:SetHeight(16)
        return f
    end

    tex:SetTexture(SOLID)
    tex:SetPoint("LEFT",  f, "LEFT",  0, 0)
    tex:SetPoint("RIGHT", f, "CENTER", 0, 0)
    tex:SetHeight(1)
    tex:SetGradient("HORIZONTAL",
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0),
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0.34))

    local texR = f:CreateTexture(nil, "ARTWORK")
    texR:SetTexture(SOLID)
    texR:SetPoint("LEFT",  f, "CENTER", 0, 0)
    texR:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    texR:SetHeight(1)
    texR:SetGradient("HORIZONTAL",
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0.34),
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0))
    return f
end

-- ════════════════════════════════════════════════════════════════════════════
-- Outer container  (invisible, handles dragging + ESC close)
-- ════════════════════════════════════════════════════════════════════════════

local storyFrame = CreateFrame("Frame", "StoryModeFrame", UIParent)
storyFrame:SetSize(FRAME_W, FRAME_H)
storyFrame:SetPoint("CENTER")
storyFrame:SetMovable(true); storyFrame:EnableMouse(true)
storyFrame:RegisterForDrag("LeftButton")
storyFrame:SetScript("OnDragStart", storyFrame.StartMoving)
storyFrame:SetScript("OnDragStop",  storyFrame.StopMovingOrSizing)
storyFrame:SetFrameStrata("HIGH")
storyFrame:Hide()
tinsert(UISpecialFrames, "StoryModeFrame")

-- ════════════════════════════════════════════════════════════════════════════
-- Left section  (274 × 550, card list)
-- ════════════════════════════════════════════════════════════════════════════

local leftSection = CreateFrame("Frame", nil, storyFrame)
leftSection:SetSize(LEFT_W, FRAME_H)
leftSection:SetPoint("TOPLEFT", storyFrame, "TOPLEFT", 0, 0)
CreateStoryPanel(leftSection)

-- Scrollable card list (no scrollbar — mousewheel only)
local leftScroll = CreateFrame("ScrollFrame", nil, leftSection, "ScrollFrameTemplate")
leftScroll:SetPoint("TOPLEFT",     leftSection, "TOPLEFT",     12, -2)
leftScroll:SetPoint("BOTTOMRIGHT", leftSection, "BOTTOMRIGHT", -12, SM.PanelScrollBottomInset)
if leftScroll.ScrollBar then leftScroll.ScrollBar:Hide() end
local leftChild = CreateFrame("Frame", nil, leftScroll)
leftChild:SetWidth(LEFT_W - 24)
leftScroll:SetScrollChild(leftChild)
EnableMouseWheelScroll(leftScroll)
SM.LeftContextChild = CreateFrame("Frame", nil, leftScroll)
SM.LeftContextChild:SetWidth(LEFT_W - 24)
SM.LeftContextChild:Hide()

-- ════════════════════════════════════════════════════════════════════════════
-- Right section  (732 × 550, header + detail)
-- ════════════════════════════════════════════════════════════════════════════

local rightSection = CreateFrame("Frame", nil, storyFrame)
rightSection:SetSize(RIGHT_W, FRAME_H)
rightSection:SetPoint("TOPLEFT", leftSection, "TOPRIGHT", GAP, 0)
CreateStoryPanel(rightSection)

-- ── Close button (standard Blizzard X) ──────────────────────────────────────
local closeBtn = CreateFrame("Button", nil, rightSection, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", rightSection, "TOPRIGHT", -4, -4)
closeBtn:SetScript("OnClick", function() storyFrame:Hide() end)

-- ── Right header  (68px, title + selected story name) ────────────────────────
local rightHeader = CreateFrame("Frame", nil, rightSection)
rightHeader:SetPoint("TOPLEFT",  rightSection, "TOPLEFT",  0, 0)
rightHeader:SetPoint("TOPRIGHT", rightSection, "TOPRIGHT", 0, 0)
rightHeader:SetHeight(HEADER_H)

-- Tab labels
local tabStoryLabel = NoShadow(rightHeader:CreateFontString(nil, "OVERLAY", "QuestFont_Large"))
tabStoryLabel:SetPoint("LEFT", rightHeader, "LEFT", 56, 0)
tabStoryLabel:SetPoint("BOTTOM", rightHeader, "BOTTOM", 0, 18)
tabStoryLabel:SetText(L["Tab Adventure"])
tabStoryLabel:SetTextColor(1, 1, 1)

local tabProgressLabel = NoShadow(rightHeader:CreateFontString(nil, "OVERLAY", "QuestFont_Large"))
tabProgressLabel:SetPoint("LEFT", tabStoryLabel, "RIGHT", 24, 0)
tabProgressLabel:SetPoint("BOTTOM", rightHeader, "BOTTOM", 0, 18)
tabProgressLabel:SetText(L["Tab Progress"])
tabProgressLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])

-- Clickable hit areas over tab labels
local tabStoryHit = CreateFrame("Button", nil, rightHeader)
tabStoryHit:SetPoint("TOPLEFT", tabStoryLabel, "TOPLEFT", -4, 4)
tabStoryHit:SetPoint("BOTTOMRIGHT", tabStoryLabel, "BOTTOMRIGHT", 4, -4)

local tabProgressHit = CreateFrame("Button", nil, rightHeader)
tabProgressHit:SetPoint("TOPLEFT", tabProgressLabel, "TOPLEFT", -4, 4)
tabProgressHit:SetPoint("BOTTOMRIGHT", tabProgressLabel, "BOTTOMRIGHT", 4, -4)

local tabJournalLabel = NoShadow(rightHeader:CreateFontString(nil, "OVERLAY", "QuestFont_Large"))
tabJournalLabel:SetPoint("LEFT", tabProgressLabel, "RIGHT", 24, 0)
tabJournalLabel:SetPoint("BOTTOM", rightHeader, "BOTTOM", 0, 18)
tabJournalLabel:SetText(L["Tab Journal"])
tabJournalLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])

local tabJournalHit = CreateFrame("Button", nil, rightHeader)
tabJournalHit:SetPoint("TOPLEFT", tabJournalLabel, "TOPLEFT", -4, 4)
tabJournalHit:SetPoint("BOTTOMRIGHT", tabJournalLabel, "BOTTOMRIGHT", 4, -4)

local activeTab = "story"

-- Kept for backward compat in UpdateStoryDetail
local smHeaderSub = NoShadow(rightHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
smHeaderSub:SetPoint("RIGHT", rightHeader, "RIGHT", -56, 0)
smHeaderSub:SetPoint("BOTTOM", rightHeader, "BOTTOM", 0, 18)
smHeaderSub:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])
smHeaderSub:SetJustifyH("RIGHT")

-- Divider at bottom of header
local headerDiv = CreateMajorDivider(rightSection)
headerDiv:SetPoint("LEFT",  rightHeader, "BOTTOMLEFT",  28, 0)
headerDiv:SetPoint("RIGHT", rightHeader, "BOTTOMRIGHT", -36, 0)

-- ── Tab container  (fills right section below header) ────────────────────────
local tabContainer = CreateFrame("Frame", nil, rightSection)
tabContainer:SetPoint("TOPLEFT",     rightHeader,  "BOTTOMLEFT",  0,  0)
tabContainer:SetPoint("BOTTOMRIGHT", rightSection, "BOTTOMRIGHT", 0,  0)

-- ════════════════════════════════════════════════════════════════════════════
-- Detail pane  (scrollable, lives inside tabContainer)
-- ════════════════════════════════════════════════════════════════════════════

local detailScrollTemplate = (SM.Client and SM.Client.isRetail) and "ScrollFrameTemplate" or "UIPanelScrollFrameTemplate"
local detailScrollName = (SM.Client and SM.Client.isRetail) and nil or "StoryModeDetailScrollFrame"
local detailScroll = CreateFrame("ScrollFrame", detailScrollName, tabContainer, detailScrollTemplate)
detailScroll:SetPoint("TOPLEFT",     tabContainer, "TOPLEFT",      2,  -2)
detailScroll:SetPoint("BOTTOMRIGHT", tabContainer, "BOTTOMRIGHT", -2, SM.PanelScrollBottomInset)
local detailChild = CreateFrame("Frame", nil, detailScroll)
detailChild:SetWidth(RIGHT_W)
detailScroll:SetScrollChild(detailChild)
EnableMouseWheelScroll(detailScroll)

-- Move scrollbar inside the panel. Classic uses the options/settings scroll art.
local detailScrollbar = SM.GetScrollBar(detailScroll)
if detailScrollbar then
    if SM.Client and SM.Client.isRetail then
        detailScrollbar:ClearAllPoints()
        detailScrollbar:SetPoint("TOPRIGHT",    detailScroll, "TOPRIGHT",    -10, -16)
        detailScrollbar:SetPoint("BOTTOMRIGHT", detailScroll, "BOTTOMRIGHT", -10,  16)
    else
        detailScrollbar:Hide()
    end
    detailScroll:HookScript("OnScrollRangeChanged", function(self)
        C_Timer.After(0, function() UpdateScrollbarVisibility(self) end)
    end)
    UpdateScrollbarVisibility(detailScroll)
end

local DP  = 32   -- divider padding (left/right)
local CP  = 80   -- content padding (left/right) — narrower than dividers

-- ── Intro (visible when no story is selected) ──────────────────────────────
local INTRO_HERO_W = 256
local INTRO_HERO_H = 128

local introHero = detailChild:CreateTexture(nil, "ARTWORK")
introHero:SetSize(INTRO_HERO_W, INTRO_HERO_H)
introHero:SetPoint("TOP", detailChild, "TOP", 0, -34)
introHero:SetTexture(STORYMODE_HERO_TEXTURE)
introHero:SetTexCoord(0, 1, 0, 1)

local introText = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
introText:SetPoint("TOPLEFT",  detailChild, "TOPLEFT",  CP, -(INTRO_HERO_H + 48))
introText:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", -CP, -(INTRO_HERO_H + 48))
introText:SetJustifyH("LEFT"); introText:SetSpacing(5)
introText:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
introText:SetText(L["Intro Text"])

-- ══════════════════════════════════════════════════════════════════════════════
-- Detail view — centered portrait hero + clean sections
-- ══════════════════════════════════════════════════════════════════════════════

local HERO_ICON = 96

-- ── Hero: centered circular portrait + title below (shared across tabs) ─────
local heroFrame = CreateFrame("Frame", nil, detailChild)
heroFrame:SetPoint("TOPLEFT",  detailChild, "TOPLEFT",  0, 0)
heroFrame:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", 0, 0)
heroFrame:SetHeight(HERO_ICON + 60)  -- icon + gap + title

local heroPort = CreateFrame("Frame", nil, heroFrame)
heroPort:SetSize(HERO_ICON, HERO_ICON)
heroPort:SetPoint("TOP", heroFrame, "TOP", 0, -30)

local heroIcon = heroPort:CreateTexture(nil, "ARTWORK")
heroIcon:SetSize(HERO_ICON - 8, HERO_ICON - 8)
heroIcon:SetPoint("CENTER")
heroIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
heroIcon:SetTexelSnappingBias(0)
heroIcon:SetSnapToPixelGrid(false)

local heroMask = heroPort:CreateMaskTexture()
heroMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask",
    "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
heroMask:SetAllPoints(heroIcon)
heroIcon:AddMaskTexture(heroMask)

local heroRing = heroPort:CreateTexture(nil, "OVERLAY")
if not SM.SafeSetAtlas(heroRing, "ui-frame-genericplayerchoice-portrait-border", false) then
    heroRing:Hide()
end
heroRing:SetPoint("TOPLEFT",     heroIcon, "TOPLEFT",     -3,  3)
heroRing:SetPoint("BOTTOMRIGHT", heroIcon, "BOTTOMRIGHT",  3, -3)
heroRing:SetVertexColor(1.0, 0.82, 0.5)
heroRing:SetAlpha(0.85)

local dTitle = NoShadow(heroFrame:CreateFontString(nil, "OVERLAY", "QuestFont_Huge"))
dTitle:SetPoint("TOP", heroPort, "BOTTOM", 0, -12)
dTitle:SetJustifyH("CENTER"); dTitle:SetWordWrap(false)
dTitle:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])

local ADVENTURE_COVER_W = 1200
local ADVENTURE_COVER_TEX_LEFT = 0.07
local ADVENTURE_COVER_TEX_RIGHT = 0.74
local ADVENTURE_COVER_TEX_TOP = 0.29
local ADVENTURE_COVER_TEX_BOTTOM = 0.46
local ADVENTURE_COVER_H = ADVENTURE_COVER_W
    * ((ADVENTURE_COVER_TEX_BOTTOM - ADVENTURE_COVER_TEX_TOP)
    / (ADVENTURE_COVER_TEX_RIGHT - ADVENTURE_COVER_TEX_LEFT))
SM.AdventureLoadingScreenTexHeight = (16 / 9) / (ADVENTURE_COVER_W / ADVENTURE_COVER_H)
SM.AdventureLoadingScreenTexTop = (1 - SM.AdventureLoadingScreenTexHeight) / 2
SM.AdventureLoadingScreenTexBottom = SM.AdventureLoadingScreenTexTop + SM.AdventureLoadingScreenTexHeight

local aCoverFrame = CreateFrame("Frame", nil, detailChild)
aCoverFrame:SetSize(ADVENTURE_COVER_W, ADVENTURE_COVER_H)
aCoverFrame:Hide()

local aCoverTexture = aCoverFrame:CreateTexture(nil, "ARTWORK")
aCoverTexture:SetPoint("CENTER")
aCoverTexture:SetSize(ADVENTURE_COVER_W, ADVENTURE_COVER_H)
aCoverTexture:SetTexCoord(
    ADVENTURE_COVER_TEX_LEFT,
    ADVENTURE_COVER_TEX_RIGHT,
    ADVENTURE_COVER_TEX_TOP,
    ADVENTURE_COVER_TEX_BOTTOM
)

-- Soft-edge fade mask: alpha-channel rounded rect that fades to transparent on
-- all four sides. Authored in Figma, exported as 32-bit TGA. The mask stretches
-- to fit the cover, so changing fade thickness is a matter of re-exporting.
local aCoverFadeMask = aCoverFrame:CreateMaskTexture()
aCoverFadeMask:SetTexture("Interface\\AddOns\\StoryMode\\Art\\Masks\\CoverFadeMask",
    "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
aCoverFadeMask:SetAllPoints(aCoverTexture)
aCoverTexture:AddMaskTexture(aCoverFadeMask)

local aCoverTitle = aCoverFrame:CreateFontString(nil, "OVERLAY", "QuestFont_Huge")
aCoverTitle:SetPoint("CENTER", aCoverFrame, "CENTER", 0, 0)
aCoverTitle:SetWidth(ADVENTURE_COVER_W - 56)
aCoverTitle:SetJustifyH("CENTER")
aCoverTitle:SetWordWrap(false)
aCoverTitle:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
do
    local font, _, flags = aCoverTitle:GetFont()
    aCoverTitle:SetFont(font, 30, flags)
end
-- Soft shadow so the title stays readable on bright/busy parts of the cover.
aCoverTitle:SetShadowColor(0, 0, 0, 0.55)
aCoverTitle:SetShadowOffset(2, -2)

-- Gold gradient divider under the title (matches achievements page style).
local aCoverDivider = CreateFrame("Frame", nil, aCoverFrame)
aCoverDivider:SetHeight(1)
local aCoverDividerL = aCoverDivider:CreateTexture(nil, "OVERLAY")
aCoverDividerL:SetTexture(SOLID)
aCoverDividerL:SetHeight(1)
aCoverDividerL:SetPoint("LEFT",  aCoverDivider, "LEFT",   0, 0)
aCoverDividerL:SetPoint("RIGHT", aCoverDivider, "CENTER", 0, 0)
aCoverDividerL:SetGradient("HORIZONTAL",
    CreateColor(C_GOLD[1], C_GOLD[2], C_GOLD[3], 0),
    CreateColor(C_GOLD[1], C_GOLD[2], C_GOLD[3], 0.7))
local aCoverDividerR = aCoverDivider:CreateTexture(nil, "OVERLAY")
aCoverDividerR:SetTexture(SOLID)
aCoverDividerR:SetHeight(1)
aCoverDividerR:SetPoint("LEFT",  aCoverDivider, "CENTER", 0, 0)
aCoverDividerR:SetPoint("RIGHT", aCoverDivider, "RIGHT",  0, 0)
aCoverDividerR:SetGradient("HORIZONTAL",
    CreateColor(C_GOLD[1], C_GOLD[2], C_GOLD[3], 0.7),
    CreateColor(C_GOLD[1], C_GOLD[2], C_GOLD[3], 0))

-- ════════════════════════════════════════════════════════════════════════════
-- STORY TAB elements
-- ════════════════════════════════════════════════════════════════════════════

-- Story intro paragraph
local sIntro = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
sIntro:SetJustifyH("LEFT"); sIntro:SetSpacing(4); sIntro:SetWordWrap(true)
sIntro:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])

-- CTA button on story tab (big red Trading Post style)
-- The visible button is a standard (non-secure) Button so it can anchor
-- freely to FontStrings during layout. A separate invisible secure overlay
-- (sTrackBtnSecure, created further below) is anchored on top of it with
-- SetAllPoints — that overlay is what actually receives clicks and fires
-- the macro in a secure execution context, keeping the tainting calls
-- (OpenWorldMap / AddQuestWatch / SetSuperTracked* / SetUserWaypoint)
-- out of Blizzard's quest-reward money-frame path.
local sTrackBtnTemplate = C_XMLUtil and C_XMLUtil.GetTemplateInfo
    and C_XMLUtil.GetTemplateInfo("SharedButtonLargeTemplate")
    and "SharedButtonLargeTemplate" or "UIPanelButtonTemplate"
local sTrackBtn = CreateFrame("Button", nil, detailChild, sTrackBtnTemplate)
sTrackBtn:SetSize(240, 40)
sTrackBtn:SetText(L["Button Begin Story"])
sTrackBtn:RegisterForClicks("AnyUp")
sTrackBtn.lockReason = nil

-- Pending action queued by PreClick; consumed by the secure macro.
local pendingSecureTrack = nil

-- Called from the macro via /run — runs in secure context, so its calls to
-- OpenWorldMap / AddQuestWatch / SetSuperTrackedQuestID / SetUserWaypoint
-- don't taint the execution path. Upvalues SetWaypointForQuest,
-- PrintTrackResult and storyFrame resolve at call time.
function StoryMode_ExecuteSecureTrack()
    local pending = pendingSecureTrack
    pendingSecureTrack = nil
    if not pending then return end
    local result = SetWaypointForQuest(pending.data, pending.quest)
    PrintTrackResult(result, pending.quest, pending.data)
    if storyFrame then storyFrame:Hide() end
end

-- Invisible SecureActionButtonTemplate overlay. Parented to detailChild, and
-- its anchor points are computed manually from sTrackBtn's rect so there is
-- NO anchor dependency in either direction. (If the overlay anchored to
-- sTrackBtn, sTrackBtn would inherit the protected-frame anchor rules and
-- could no longer be anchored to FontStrings during layout — raising
-- "Cannot anchor protected frames to regions". If sTrackBtn anchored to
-- the overlay, the same thing would happen.) SyncSecureOverlay() keeps it
-- positioned on top of sTrackBtn; it's called after every layout pass and
-- is a no-op during combat (SetPoint on protected frames is combat-
-- restricted — minor cosmetic drift is acceptable).
local sTrackBtnSecure = CreateFrame("Button", "StoryModeTrackButton", detailChild, "SecureActionButtonTemplate")
sTrackBtnSecure:SetSize(240, 40)
sTrackBtnSecure:SetPoint("TOPLEFT", detailChild, "TOPLEFT", 0, 0)
sTrackBtnSecure:RegisterForClicks("AnyUp")
sTrackBtnSecure:SetAttribute("type", "macro")
sTrackBtnSecure:SetAttribute("macrotext", "/run StoryMode_ExecuteSecureTrack()")
sTrackBtnSecure:SetFrameLevel((sTrackBtn:GetFrameLevel() or 0) + 5)

local function SyncSecureOverlay()
    if InCombatLockdown() then return end
    local btnLeft, btnTop = sTrackBtn:GetLeft(), sTrackBtn:GetTop()
    local parLeft, parTop = detailChild:GetLeft(), detailChild:GetTop()
    if not (btnLeft and btnTop and parLeft and parTop) then return end
    sTrackBtnSecure:ClearAllPoints()
    sTrackBtnSecure:SetPoint("TOPLEFT", detailChild, "TOPLEFT",
        btnLeft - parLeft, btnTop - parTop)
    sTrackBtnSecure:SetSize(sTrackBtn:GetWidth(), sTrackBtn:GetHeight())
end

-- Re-sync when sTrackBtn resizes (content fonts reflowing, etc.).
-- Layout code calls SyncSecureOverlay() explicitly after re-anchoring.
sTrackBtn:HookScript("OnSizeChanged", SyncSecureOverlay)
sTrackBtn:HookScript("OnShow", SyncSecureOverlay)
-- Always visible; enable/disable is effectively controlled by whether PreClick
-- queues a pending action. No pending action → the macro is a no-op.

-- Forward hover events to the visible button so its template highlight and
-- lock-reason tooltip keep working while the overlay sits on top.
sTrackBtnSecure:SetScript("OnEnter", function()
    sTrackBtn:LockHighlight()
    local fn = sTrackBtn:GetScript("OnEnter")
    if fn then fn(sTrackBtn) end
end)
sTrackBtnSecure:SetScript("OnLeave", function()
    sTrackBtn:UnlockHighlight()
    local fn = sTrackBtn:GetScript("OnLeave")
    if fn then fn(sTrackBtn) end
end)
sTrackBtn:SetScript("OnEnter", function(self)
    if self.lockReason then
        SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
        SMTooltip:ClearLines()
        SMTooltip:AddLine(L["Tooltip Story Locked"], 1, 1, 1)
        SMTooltip:AddLine(self.lockReason, 1.0, 0.82, 0.35, true)
        SMTooltip:Show()
    end
end)
sTrackBtn:SetScript("OnLeave", function() SMTooltip:Hide() end)

local sCompleteText = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
sCompleteText:SetTextColor(0.40, 0.82, 0.35)
sCompleteText:SetText(L["Campaign Complete"])

-- Progressive story journal entries (chapter recaps, revealed as quests are completed)
local sJournalHeader = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
sJournalHeader:SetJustifyH("CENTER")
sJournalHeader:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
sJournalHeader:SetText(L["Journal Header"])

local sJournalSubline = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
sJournalSubline:SetJustifyH("CENTER"); sJournalSubline:SetWordWrap(true)
sJournalSubline:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
sJournalSubline:SetText(L["Journal Subline"])

local sJournalEmptyTitle = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
sJournalEmptyTitle:SetJustifyH("CENTER")
sJournalEmptyTitle:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
sJournalEmptyTitle:SetText(L["Journal Empty Title"])
sJournalEmptyTitle:Hide()

local sJournalEmptyText = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
sJournalEmptyText:SetJustifyH("CENTER"); sJournalEmptyText:SetSpacing(4); sJournalEmptyText:SetWordWrap(true)
sJournalEmptyText:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
sJournalEmptyText:SetText(L["Journal Empty Text"])

local sFactionHeader = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Large"))
sFactionHeader:SetJustifyH("CENTER")
sFactionHeader:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
sFactionHeader:SetText(L["Section Factions"])
sFactionHeader:Hide()

local sJournalEntries = {}  -- pool of { title = FontString, body = FontString }

local function GetJournalEntry(idx)
    if sJournalEntries[idx] then return sJournalEntries[idx] end
    local title = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Large"))
    title:SetJustifyH("CENTER")
    title:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
    local body = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
    body:SetJustifyH("LEFT"); body:SetSpacing(4); body:SetWordWrap(true)
    body:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
    sJournalEntries[idx] = { title = title, body = body }
    return sJournalEntries[idx]
end

local storyElements = { sIntro, sTrackBtn, sCompleteText }
local journalElements = { sJournalHeader, sJournalSubline, sJournalEmptyTitle, sJournalEmptyText, sFactionHeader }

-- ── Faction reputation cards (journal tab) ─────────────────────────────────
-- Uses the Housing Dashboard house-level reward card surface with Blizzard's
-- Journeys radial art:
--   house-upgrade-reward-large-tile-bg / -highlight
--   RenownCardButtonTemplate radial: ui-journeys-renown-radial-bar/fill
local FactionUI = {
    CARD_W = 304,
    CARD_H = 88,
    TILE_SIZE = 112,
    CARD_ATLAS = "house-upgrade-reward-large-tile-bg",
    CARD_HOVER_ATLAS = "house-upgrade-reward-large-tile-bg-highlight",
    TILE_ATLASES = {
        "house-chest-list-item-default",
        "house-chest-list-Item-default",
    },
    cards = {},
    spacer = nil,
    iconOverrides = {
        [68] = 255143,     -- Exalted Champion of the Undercity
        [1098] = 236694,   -- Knights of the Ebon Blade
        [1106] = 236690,   -- Argent Crusader
        [1156] = 133441,   -- The Ashen Verdict
        [1228] = 877482,   -- Forest Hozen
        [1271] = 646324,   -- Order of the Cloud Serpent
        [1859] = 1394956,  -- Nightfallen faction icon
        [2103] = 2065579,  -- Zandalari Empire faction icon
        [2156] = 2065575,  -- Talanji's Expedition faction icon
        [2157] = 2486869,  -- Honorbound paragon cache
        [2159] = 2486868,  -- 7th Legion paragon cache
        [2160] = 2065573,  -- Proudmoore Admiralty faction icon
        [2161] = 2065572,  -- Order of Embers faction icon
        [2162] = 2065574,  -- Storm's Wake faction icon
        [2413] = 3540525,  -- Court of Harvesters
        [2439] = 3386971,  -- Sinstone, for The Avowed
    },
    achievementIconNames = {
        [68] = "Undercity",
        [1098] = "Knights of the Ebon Blade",
        [1106] = "Argent Crusade",
        [1156] = "The Ashen Verdict",
        [1228] = "Forest Hozen",
        [1271] = "Order of the Cloud Serpent",
        [1859] = "The Nightfallen",
        [2103] = "Zandalari Empire",
        [2156] = "Talanji's Expedition",
        [2157] = "The Honorbound",
        [2159] = "The 7th Legion",
        [2160] = "Proudmoore Admiralty",
        [2161] = "Order of Embers",
        [2162] = "Storm's Wake",
        [2413] = "Court of Harvesters",
        [2439] = "The Avowed",
    },
    achievementIconCache = {},
    colorOverrides = {
        [68] = {0.45, 0.78, 0.50},    -- Undercity
        [1098] = {0.42, 0.72, 0.62},  -- Knights of the Ebon Blade
        [1106] = {0.95, 0.72, 0.26},  -- Argent Crusade
        [1156] = {0.78, 0.85, 0.60},  -- The Ashen Verdict
        [1228] = {0.58, 0.76, 0.26},  -- Forest Hozen
        [1271] = {0.12, 0.72, 0.78},  -- Order of the Cloud Serpent
        [1859] = {0.62, 0.38, 0.95},  -- The Nightfallen
        [2103] = {0.91, 0.62, 0.12},  -- Zandalari Empire
        [2156] = {0.16, 0.72, 0.68},  -- Talanji's Expedition
        [2157] = {0.82, 0.22, 0.16},  -- The Honorbound
        [2159] = {0.32, 0.55, 0.95},  -- 7th Legion
        [2160] = {0.36, 0.62, 0.94},  -- Proudmoore Admiralty
        [2161] = {0.95, 0.48, 0.18},  -- Order of Embers
        [2162] = {0.28, 0.78, 0.68},  -- Storm's Wake
        [2413] = {0.74, 0.18, 0.28},  -- Court of Harvesters
        [2439] = {0.72, 0.62, 0.48},  -- The Avowed
    },
    descriptions = {
        [1859] = "These exiled Nightborne elves suffer withdrawals after being cut off from the Nightwell. They oppose their people's alliance with the Legion and fight for some kind of redemption.",
    },
}

function FactionUI:Create()
    local card = CreateFrame("Frame", nil, detailChild)
    card:SetSize(self.CARD_W, self.CARD_H)

    card.button = CreateFrame("Button", nil, card)
    card.button:SetPoint("TOPLEFT", card, "TOPLEFT", 0, 0)
    card.button:SetSize(self.CARD_W, self.CARD_H)

    card.button.Background = card.button:CreateTexture(nil, "BACKGROUND")
    card.button.Background:SetAllPoints(card.button)
    if not SM.SafeSetAtlas(card.button.Background, self.CARD_ATLAS, false) then
        SM.SetSolidTexture(card.button.Background, 0.075, 0.065, 0.055, 0.92)
    end

    card.button:SetScript("OnEnter", function(button)
        if card.tileMode then
            FactionUI:ApplyTileVisual(card, true)
        else
            FactionUI:SetCardAtlas(card, FactionUI:GetCardAtlas(card, true))
        end
        if card.tooltipTitle then
            SMTooltip:SetOwner(button, "ANCHOR_RIGHT")
            SMTooltip:ClearLines()
            SMTooltip:AddLine(card.tooltipTitle, 1, 1, 1)
            if card.tooltipStatus and card.tooltipStatus ~= "" then
                SMTooltip:AddLine(card.tooltipStatus, C_GOLD[1], C_GOLD[2], C_GOLD[3])
            end
            if card.tooltipDescription and card.tooltipDescription ~= "" then
                SMTooltip:AddLine(" ")
                SMTooltip:AddLine(card.tooltipDescription, C_BODY[1], C_BODY[2], C_BODY[3], true)
            end
            SMTooltip:Show()
        end
    end)
    card.button:SetScript("OnLeave", function()
        if card.tileMode then
            FactionUI:ApplyTileVisual(card, false)
        else
            FactionUI:SetCardAtlas(card, FactionUI:GetCardAtlas(card, false))
        end
        SMTooltip:Hide()
    end)
    card.button:SetScript("OnClick", nil)
    card.button:EnableMouse(true)

    if not card.button.IconFrame then
        card.button.IconFrame = CreateFrame("Frame", nil, card.button)
        card.button.IconFrame.Border = card.button.IconFrame:CreateTexture(nil, "BORDER")
        card.button.IconFrame.Border:SetAllPoints(card.button.IconFrame)
        card.button.IconFrame.Icon = card.button.IconFrame:CreateTexture(nil, "OVERLAY")
        card.button.IconFrame.Icon:SetPoint("CENTER", card.button.IconFrame, "CENTER", 0, 0)
        card.button.IconFrame.IconMask = card.button.IconFrame:CreateMaskTexture()
        card.button.IconFrame.IconMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
            "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        card.button.IconFrame.IconMask:SetAllPoints(card.button.IconFrame.Icon)
        card.button.IconFrame.Icon:AddMaskTexture(card.button.IconFrame.IconMask)
    end

    if not card.button.RenownCardFactionName then
        card.button.RenownCardFactionName = NoShadow(card.button:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
        card.button.RenownCardFactionName:SetPoint("LEFT", card.button.IconFrame, "RIGHT", 5, 5)
        card.button.RenownCardFactionName:SetSize(225, 20)
        card.button.RenownCardFactionName:SetJustifyH("LEFT")
    end

    if not card.button.RenownCardFactionLevel then
        card.button.RenownCardFactionLevel = NoShadow(card.button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
        card.button.RenownCardFactionLevel:SetPoint("LEFT", card.button.IconFrame, "RIGHT", 5, -15)
        card.button.RenownCardFactionLevel:SetSize(220, 15)
        card.button.RenownCardFactionLevel:SetJustifyH("LEFT")
    end

    if card.button.IconFrame then
        card.button.IconFrame:SetSize(60, 60)
        card.button.IconFrame:SetPoint("LEFT", card.button, "LEFT", 18, 0)
        card.progress = CreateFrame("Cooldown", nil, card.button.IconFrame, "CooldownFrameTemplate")
        card.progress:SetAllPoints(card.button.IconFrame)
        card.progress:SetDrawEdge(false)
        card.progress:SetDrawSwipe(true)
        card.progress:SetHideCountdownNumbers(true)
        card.progress:SetReverse(true)
        card.progress.noCooldownCount = true
        if card.progress.SetRotation then
            card.progress:SetRotation(math.pi)
        end
        card.fullRing = card.button.IconFrame:CreateTexture(nil, "ARTWORK", nil, 2)
        card.fullRing:SetAllPoints(card.button.IconFrame)
        card.fullRing:Hide()
        if card.button.IconFrame.Border then
            if not SM.SafeSetAtlas(card.button.IconFrame.Border, "ui-journeys-renown-radial-bar", false) then
                card.button.IconFrame.Border:Hide()
            end
            card.button.IconFrame.Border:SetSize(60, 60)
        end
        card.icon = card.button.IconFrame.Icon
        card.icon:SetSize(40, 40)
    end

    card.nameLabel = card.button.RenownCardFactionName
    card.statusLabel = card.button.RenownCardFactionLevel
    card.nameLabel:ClearAllPoints()
    card.nameLabel:SetPoint("LEFT", card.button.IconFrame, "RIGHT", 10, 0)
    card.nameLabel:SetPoint("RIGHT", card.button, "RIGHT", -14, 0)
    card.nameLabel:SetPoint("BOTTOM", card.button, "CENTER", 0, 0)
    card.nameLabel:SetJustifyH("LEFT")
    card.nameLabel:SetJustifyV("BOTTOM")
    card.nameLabel:SetScale(1.08)
    card.nameLabel:SetMaxLines(1)
    card.nameLabel:SetWordWrap(false)
    card.statusLabel:ClearAllPoints()
    card.statusLabel:SetPoint("TOPLEFT", card.nameLabel, "BOTTOMLEFT", 0, 0)
    card.statusLabel:SetPoint("RIGHT", card.nameLabel, "RIGHT", 0, 0)
    card.statusLabel:SetJustifyH("LEFT")
    card.statusLabel:SetScale(1.08)
    card.statusLabel:SetMaxLines(1)
    card.statusLabel:SetWordWrap(false)
    card.nameLabel:SetTextColor(1, 1, 1)
    card.statusLabel:SetTextColor(1.0, 0.82, 0.36)
    return card
end

function FactionUI:Get(idx)
    if self.cards[idx] then return self.cards[idx] end
    self.cards[idx] = self:Create()
    return self.cards[idx]
end

function FactionUI:Resize(card, width)
    local scale = math.min(1, width / self.CARD_W)
    card:SetSize(width, self.CARD_H * scale)
    card.button:SetScale(scale)
    return self.CARD_H * scale
end

function FactionUI:SetAtlas(tex, atlas, useAtlasSize)
    if not tex or not atlas then return false end
    if C_Texture and C_Texture.GetAtlasInfo and not C_Texture.GetAtlasInfo(atlas) then
        return false
    end
    local ok = pcall(tex.SetAtlas, tex, atlas, useAtlasSize)
    return ok and (not tex.GetAtlas or tex:GetAtlas() == atlas)
end

function FactionUI:ApplyTileVisual(card, isHover)
    if not card or not card.button or not card.tileMode then return false end
    local button = card.button
    local function SetCatalogTileAtlas(tex)
        for _, atlas in ipairs(self.TILE_ATLASES) do
            if self:SetAtlas(tex, atlas, false) then
                return true
            end
        end
        return false
    end

    if button.TileBg then button.TileBg:Hide() end
    if button.TileBorder then
        for _, tex in ipairs(button.TileBorder) do
            tex:Hide()
        end
    end

    if button.Background then
        button.Background:ClearAllPoints()
        button.Background:SetAllPoints(button)
        if SetCatalogTileAtlas(button.Background) then
            button.Background:SetVertexColor(1, 1, 1, 1)
        else
            button.Background:SetTexture(SOLID)
            button.Background:SetVertexColor(0.015, 0.012, 0.010, 0.96)
        end
        button.Background:SetAlpha(1)
        button.Background:SetDesaturated(false)
        button.Background:Show()

        if not button.HoverBackground then
            button.HoverBackground = button:CreateTexture(nil, "BACKGROUND", nil, 1)
            button.HoverBackground:SetBlendMode("ADD")
        end
        button.HoverBackground:ClearAllPoints()
        button.HoverBackground:SetAllPoints(button)
        if SetCatalogTileAtlas(button.HoverBackground) then
            button.HoverBackground:SetAlpha(isHover and 0.45 or 0)
            button.HoverBackground:SetVertexColor(1, 1, 1, 1)
            button.HoverBackground:SetShown(isHover)
        else
            button.HoverBackground:Hide()
        end
        return true
    end

    return false
end

function FactionUI:SetCardAtlas(card, atlas)
    if not card or not atlas then return end
    if card.tileMode and self:ApplyTileVisual(card, false) then
        return true
    end
    if type(atlas) == "table" then
        for _, candidate in ipairs(atlas) do
            if self:SetCardAtlas(card, candidate) then
                return true
            end
        end
        return false
    end
    if card.button and card.button.Background then
        return self:SetAtlas(card.button.Background, atlas, false)
    elseif card.button and card.button.bg then
        return self:SetAtlas(card.button.bg, atlas, false)
    end
    return false
end

function FactionUI:GetCardAtlas(card, isHover)
    return isHover and self.CARD_HOVER_ATLAS or self.CARD_ATLAS
end

function FactionUI:GetAchievementIcon(factionID)
    if self.achievementIconCache[factionID] ~= nil then
        return self.achievementIconCache[factionID] or nil
    end

    local targetName = self.achievementIconNames[factionID]
    if not targetName then
        self.achievementIconCache[factionID] = false
        return nil
    end

    for id = 1, 50000 do
        local _, name, _, _, _, _, _, _, _, icon = GetAchievementInfo(id)
        if name == targetName and icon then
            self.achievementIconCache[factionID] = icon
            return icon
        end
    end

    self.achievementIconCache[factionID] = false
    return nil
end

function FactionUI:GetFactionIcon(factionID, entry)
    return (entry and entry.icon) or self.iconOverrides[factionID] or self:GetAchievementIcon(factionID)
end

function FactionUI:SetIcon(tex, atlas, texture)
    if not tex then return end
    tex:Hide()
    tex:SetTexture(nil)
    if atlas and self:SetAtlas(tex, atlas, false) then
        tex:SetTexCoord(0, 1, 0, 1)
        tex:SetVertexColor(1, 1, 1)
        tex:Show()
        return
    end
    tex:SetTexture(texture)
    if texture and tex:GetTexture() then
        tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        tex:SetVertexColor(1, 1, 1)
    end
    if not tex:GetTexture() then
        tex:SetTexture(236681) -- Achievement_Reputation_01
        if tex:GetTexture() then
            tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            tex:SetVertexColor(1, 1, 1)
        end
    end
    if tex:GetTexture() then
        tex:Show()
    end
end

function FactionUI:GetAccentColor(factionID, entry, majorFactionData, reputationInfo)
    if entry and entry.color then
        return entry.color[1], entry.color[2], entry.color[3]
    end
    local override = self.colorOverrides[factionID]
    if override then
        return override[1], override[2], override[3]
    end
    if majorFactionData and majorFactionData.factionFontColor and majorFactionData.factionFontColor.color then
        return majorFactionData.factionFontColor.color:GetRGB()
    end
    if reputationInfo and FACTION_BAR_COLORS then
        local standingColor = FACTION_BAR_COLORS[reputationInfo.reaction or 4]
        if standingColor then
            return standingColor.r, standingColor.g, standingColor.b
        end
    end
    return C_GOLD[1], C_GOLD[2], C_GOLD[3]
end

function FactionUI:ApplyAccentColor(card, r, g, b)
    if card.progress then card.progress:SetSwipeColor(r, g, b, 1) end
    if card.fullRing then card.fullRing:SetVertexColor(r, g, b, 1) end
    if card.button and card.button.IconFrame and card.button.IconFrame.Border then
        card.button.IconFrame.Border:SetVertexColor(r, g, b)
    end
end

function FactionUI:ApplyArt(card, expansionID, textureKit)
    self:SetCardAtlas(card, self:GetCardAtlas(card, false))

    if card.button and card.button.IconFrame and card.button.IconFrame.Border then
        if not self:SetAtlas(card.button.IconFrame.Border, "ui-journeys-renown-radial-bar", false) then
            card.button.IconFrame.Border:Hide()
        end
        card.button.IconFrame.Border:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
    end

    local fillAtlas = "ui-journeys-renown-radial-fill"
    local fillInfo = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(fillAtlas)
    if fillInfo then
        if card.progress then
            card.progress:SetSwipeTexture(fillInfo.file or fillInfo.filename)
            if card.progress.SetTexCoordRange then
                card.progress:SetTexCoordRange(
                    { x = fillInfo.leftTexCoord, y = fillInfo.topTexCoord },
                    { x = fillInfo.rightTexCoord, y = fillInfo.bottomTexCoord }
                )
            end
            card.progress:SetSwipeColor(1, 0.82, 0.1, 1)
        end
        if card.fullRing then
            card.fullRing:SetTexture(fillInfo.file or fillInfo.filename)
            card.fullRing:SetTexCoord(
                fillInfo.leftTexCoord, fillInfo.rightTexCoord,
                fillInfo.topTexCoord, fillInfo.bottomTexCoord
            )
        end
        if card.fullRing then card.fullRing:SetVertexColor(1, 0.82, 0.1, 1) end
    else
        if card.progress then
            card.progress:SetSwipeColor(C_GOLD[1], C_GOLD[2], C_GOLD[3], 0.95)
        end
        if card.fullRing then card.fullRing:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3], 0.95) end
    end
end

function FactionUI:SetProgress(card, pct)
    pct = math.max(0, math.min(1, pct or 0))
    local isFull = pct >= 0.999
    if card.fullRing then
        card.fullRing:SetShown(isFull)
    end
    if card.progress then
        card.progress:SetShown(pct > 0 and not isFull)
        if pct > 0 and not isFull then
            if CooldownFrame_SetDisplayAsPercentage then
                CooldownFrame_SetDisplayAsPercentage(card.progress, pct)
            else
                local DURATION = 1000
                card.progress:SetCooldown(GetTime() - pct * DURATION, DURATION)
                if card.progress.Pause then card.progress:Pause() end
            end
        end
    end
end

function FactionUI:LayoutLeftCardText(card)
    if not card or not card.leftContext or not card.nameLabel or not card.statusLabel then return end
    if card.tileMode then
        local textW = math.max(70, (card:GetWidth() or self.TILE_SIZE) - 16)
        card.nameLabel:SetWidth(textW)
        card.statusLabel:SetWidth(textW)
        local nameH = math.ceil(math.max(14, card.nameLabel:GetStringHeight() or 14))
        local statusH = math.ceil(math.max(12, card.statusLabel:GetStringHeight() or 12))

        card.nameLabel:ClearAllPoints()
        card.nameLabel:SetPoint("TOP", card.button.IconFrame, "BOTTOM", 0, -6)
        card.nameLabel:SetPoint("LEFT", card, "LEFT", 8, 0)
        card.nameLabel:SetPoint("RIGHT", card, "RIGHT", -8, 0)
        card.nameLabel:SetHeight(nameH)
        card.nameLabel:SetJustifyH("CENTER")
        card.nameLabel:SetJustifyV("TOP")
        card.statusLabel:ClearAllPoints()
        card.statusLabel:SetPoint("TOPLEFT", card.nameLabel, "BOTTOMLEFT", 0, 0)
        card.statusLabel:SetPoint("RIGHT", card.nameLabel, "RIGHT", 0, 0)
        card.statusLabel:SetHeight(statusH)
        card.statusLabel:SetJustifyH("CENTER")
        return
    end
    if not card.textGroup then
        card.textGroup = CreateFrame("Frame", nil, card.button)
    end

    local textGap = 1
    local textW = math.max(80, (card.button:GetWidth() or (LEFT_W - 32)) - 84)
    card.nameLabel:SetWidth(textW)
    card.statusLabel:SetWidth(textW)
    local nameH = math.ceil(math.max(14, card.nameLabel:GetStringHeight() or 14))
    local statusH = math.ceil(math.max(12, card.statusLabel:GetStringHeight() or 12))
    local blockH = nameH + textGap + statusH

    card.textGroup:ClearAllPoints()
    card.textGroup:SetPoint("LEFT", card.button.IconFrame, "RIGHT", 10, 0)
    card.textGroup:SetPoint("RIGHT", card.button, "RIGHT", -12, 0)
    card.textGroup:SetPoint("TOP", card.button, "CENTER", 0, blockH / 2)
    card.textGroup:SetHeight(blockH)

    card.nameLabel:ClearAllPoints()
    card.nameLabel:SetPoint("TOPLEFT", card.textGroup, "TOPLEFT", 0, 0)
    card.nameLabel:SetPoint("RIGHT", card.textGroup, "RIGHT", 0, 0)
    card.nameLabel:SetHeight(nameH)
    card.nameLabel:SetJustifyV("TOP")
    card.statusLabel:ClearAllPoints()
    card.statusLabel:SetPoint("TOPLEFT", card.nameLabel, "BOTTOMLEFT", 0, -textGap)
    card.statusLabel:SetPoint("RIGHT", card.textGroup, "RIGHT", 0, 0)
    card.statusLabel:SetHeight(statusH)
end

function FactionUI:NormalizeEntry(entry)
    if type(entry) == "table" then
        return entry
    end
    return { id = entry }
end

function FactionUI:Update(card, entry, storyData)
    entry = self:NormalizeEntry(entry)
    local factionID = entry.id or entry.factionID
    if not factionID then card:Hide(); return false end

    local pct, name, status, description = 0, nil, "", entry.description

    local mf = C_MajorFactions and C_MajorFactions.GetMajorFactionData
        and C_MajorFactions.GetMajorFactionData(factionID)
    if mf and mf.name then
        name = mf.name
        description = description or mf.description or self.descriptions[factionID]
        local cur = mf.renownReputationEarned or 0
        local need = mf.renownLevelThreshold or 0
        if need > 0 then pct = math.max(0, math.min(1, cur / need)) end
        local maxLevel = 0
        if C_MajorFactions.GetRenownLevels then
            local levels = C_MajorFactions.GetRenownLevels(factionID)
            if levels then maxLevel = #levels end
        end
        if maxLevel > 0 and (mf.renownLevel or 0) >= maxLevel then
            pct = 1
        end
        status = maxLevel > 0
            and string.format("Renown %d/%d", mf.renownLevel or 0, maxLevel)
            or string.format("Renown %d", mf.renownLevel or 0)
        self:ApplyArt(card, mf.expansionID, mf.textureKit)
        self:SetIcon(card.icon, entry.iconAtlas or (mf.textureKit and ("majorfactions_icons_" .. mf.textureKit .. "512")), self:GetFactionIcon(factionID, entry))
        self:ApplyAccentColor(card, self:GetAccentColor(factionID, entry, mf, nil))
    else
        local info = SM.GetFactionDataByID(factionID)
        if not info or not info.name then card:Hide(); return false end
        name = info.name
        description = description or info.description or self.descriptions[factionID]
        local reaction = info.reaction or 4
        local minRep   = info.currentReactionThreshold or 0
        local maxRep   = info.nextReactionThreshold or (minRep + 1)
        local cur      = info.currentStanding or 0
        if reaction >= 8 or (info.nextReactionThreshold == nil and cur >= minRep) then
            pct = 1
        elseif maxRep > minRep then
            pct = math.max(0, math.min(1, (cur - minRep) / (maxRep - minRep)))
        end
        status = _G["FACTION_STANDING_LABEL" .. reaction] or ""
        self:ApplyArt(card, entry.expansionID, entry.textureKit)
        self:SetIcon(card.icon, entry.iconAtlas, self:GetFactionIcon(factionID, entry))
        self:ApplyAccentColor(card, self:GetAccentColor(factionID, entry, nil, info))
    end

    card.factionID = factionID
    card.isMajorFaction = (mf and mf.name) and true or false
    if card.nameLabel then card.nameLabel:SetText(name) end
    if card.statusLabel then card.statusLabel:SetText(status) end
    self:LayoutLeftCardText(card)
    if card.leftContext and C_Timer then
        C_Timer.After(0, function()
            FactionUI:LayoutLeftCardText(card)
        end)
    end
    card.tooltipTitle = name
    card.tooltipStatus = status
    card.tooltipDescription = description
    self:SetProgress(card, pct)
    card:Show()
    return true
end

function FactionUI:HideAll()
    for _, c in ipairs(self.cards) do c:Hide() end
    if self.spacer then self.spacer:Hide() end
end

-- ════════════════════════════════════════════════════════════════════════════
-- PROGRESS TAB elements
-- ════════════════════════════════════════════════════════════════════════════

local dCompleteText = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
dCompleteText:SetTextColor(0.40, 0.82, 0.35)
dCompleteText:SetText(L["Campaign Complete"])

-- Progress summary (shown at top of progress tab, under hero)
local dProgSummary = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
dProgSummary:SetJustifyH("CENTER")
dProgSummary:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])

-- Set a 2D NPC portrait from a pre-stored creature display ID
local HERITAGE_ICON_BY_RACE = {
    BloodElf = 2459464,
    Goblin = "Interface\\Icons\\inv_misc_tabard_goblin",
    Troll = "Interface\\Icons\\inv_misc_tabard_darkspear",
    Orc = "Interface\\Icons\\inv_misc_tabard_orgrimmar",
    Tauren = "Interface\\Icons\\inv_misc_tabard_thunderbluff",
    Human = "Interface\\Icons\\inv_misc_tabard_stormwind",
    Dwarf = "Interface\\Icons\\inv_misc_tabard_ironforge",
    Gnome = "Interface\\Icons\\inv_misc_tabard_gnomeregan",
    NightElf = "Interface\\Icons\\inv_misc_tabard_darnassus",
    Worgen = "Interface\\Icons\\inv_misc_tabard_gilneas",
    Draenei = "Interface\\Icons\\inv_misc_tabard_exodar",
    Pandaren = "Interface\\Icons\\inv_misc_tabard_tushui",
    DarkIronDwarf = "Interface\\Icons\\inv_misc_tabard_darkiron",
    Scourge = "Interface\\Icons\\inv_misc_tabard_forsaken",
}
local HERITAGE_ICON_FALLBACK = "Interface\\Icons\\inv_misc_cape_18"
local PANDAREN_TABARD_ICON = "Interface\\Icons\\inv_misc_tabard_tushui"

local function CreateCompletionRibbon(parent)
    local ribbon = CreateFrame("Frame", nil, parent)
    ribbon:SetSize(34, 42)

    local flag = ribbon:CreateTexture(nil, "OVERLAY", nil, 1)
    flag:SetAllPoints()
    flag:SetVertexColor(1, 1, 1)
    local hasFlag = SM.SafeSetAtlas(flag, "housing-dashboard-tasks-listitem-flag", false)
    if not hasFlag then
        flag:Hide()
    end

    local check = ribbon:CreateTexture(nil, "OVERLAY", nil, 2)
    if not SM.SafeSetAtlas(check, "common-icon-checkmark", false) then
        SM.SafeSetTexture(check, "Interface\\Buttons\\UI-CheckBox-Check")
    end
    if hasFlag then
        check:SetSize(14, 14)
        check:SetPoint("CENTER", ribbon, "CENTER", 0, 3)
    else
        check:SetSize(24, 24)
        check:SetPoint("CENTER", ribbon, "CENTER", 0, 0)
    end
    check:SetVertexColor(0.45, 0.90, 0.35)

    return ribbon
end

local adventureGuideImageCache = {}
SM.AdventureGuideLoadingScreenByMapID = {
    [33] = 131869,    -- Shadowfang Keep
    [36] = 131833,    -- Deadmines
    [43] = 131882,    -- Wailing Caverns
    [70] = 131876,    -- Uldaman
    [90] = 131841,    -- Gnomeregan
    [230] = 131824,   -- Blackrock Depths
    [564] = 131826,   -- Black Temple
    [580] = 131873,   -- The Sunwell / Sunwell Plateau
    [608] = 236058,   -- Violet Hold
    [631] = 318964,   -- Icecrown Citadel
    [643] = 397151,   -- Throne of the Tides
    [960] = 633149,   -- Temple of the Jade Serpent
    [1004] = 645156,  -- Scarlet Monastery
    [1009] = 633148,  -- Heart of Fear
    [1136] = 903869,  -- Siege of Orgrimmar
    [1182] = 1034725, -- Auchindoun
    [1466] = 1389212, -- Darkheart Thicket
    [1477] = 1454826, -- Halls of Valor
    [1520] = 1394867, -- The Emerald Nightmare
    [1530] = 1448532, -- The Nighthold
    [1571] = 1477131, -- Court of Stars
    [1594] = 2016712, -- The MOTHERLODE!!
    [1676] = 1615560, -- Tomb of Sargeras
    [1677] = 1616802, -- Cathedral of Eternal Night
    [1753] = 1717768, -- Seat of the Triumvirate
    [1763] = 1968998, -- Atal'Dazar
    [1822] = 2068775, -- Siege of Boralus
    [1841] = 2175832, -- The Underrot
    [1862] = 1984118, -- Waycrest Manor
    [2296] = 3582016, -- Castle Nathria
}

local function NormalizeAdventureGuideName(name)
    if not name then return nil end
    name = string.lower(name)
    name = name:gsub("^the%s+", "")
    name = name:gsub("[^%w]", "")
    return name
end

local function EnsureEncounterJournalAPI()
    if EJ_GetInstanceInfo and EJ_GetInstanceByIndex then return true end
    SM.LoadAddOn("Blizzard_EncounterJournal")
    return EJ_GetInstanceInfo and EJ_GetInstanceByIndex
end

local function FindAdventureGuideInstanceID(instanceName)
    if not instanceName or instanceName == "" then return nil end
    if adventureGuideImageCache[instanceName] ~= nil then
        return adventureGuideImageCache[instanceName]
    end
    if not EnsureEncounterJournalAPI() then return nil end

    -- securecall keeps our addon's insecure taint off Blizzard_EncounterJournal's
    -- saved tier state. Without it, EJ_SelectTier from this insecure context
    -- taints EJ's secure data and surfaces later as a MoneyFrame_Update arithmetic
    -- error when the user hovers loot in the Adventure Guide.
    local previousTier = EJ_GetCurrentTier and EJ_GetCurrentTier()
    local numTiers = EJ_GetNumTiers and EJ_GetNumTiers() or 0
    if numTiers <= 0 then
        adventureGuideImageCache[instanceName] = false
        return nil
    end

    local function RestorePreviousTier()
        if previousTier and previousTier >= 1 and previousTier <= numTiers then
            pcall(securecall, EJ_SelectTier, previousTier)
        end
    end

    local normalizedTarget = NormalizeAdventureGuideName(instanceName)
    local normalizedMatches = {}
    for tier = 1, numTiers do
        pcall(securecall, EJ_SelectTier, tier)
        for _, isRaid in ipairs({ false, true }) do
            for i = 1, 200 do
                local instanceID, name = EJ_GetInstanceByIndex(i, isRaid)
                if not instanceID then break end
                if name == instanceName then
                    adventureGuideImageCache[instanceName] = instanceID
                    RestorePreviousTier()
                    return instanceID
                end
                if NormalizeAdventureGuideName(name) == normalizedTarget then
                    normalizedMatches[#normalizedMatches + 1] = instanceID
                end
            end
        end
    end

    RestorePreviousTier()
    if normalizedMatches[1] then
        adventureGuideImageCache[instanceName] = normalizedMatches[1]
        return normalizedMatches[1]
    end
    adventureGuideImageCache[instanceName] = false
    return nil
end

local function GetAdventureCoverTexture(data)
    if not data then return nil end
    if data.adventureCoverTexture then
        return data.adventureCoverTexture, data.adventureCoverIsLoadingScreen
    end

    local instanceID = data.adventureGuideInstanceID
        or FindAdventureGuideInstanceID(data.adventureGuideInstanceName)
    if instanceID and EnsureEncounterJournalAPI() then
        local _, _, bgImage, buttonImage1, loreImage, buttonImage2, _, _, _, mapID = EJ_GetInstanceInfo(instanceID)
        if not data.adventureGuideImage then
            local loadingScreen = SM.AdventureGuideLoadingScreenByMapID[mapID]
            if loadingScreen then
                return loadingScreen, true
            end
        end
        if data.adventureGuideImage == "background" then
            return bgImage or loreImage or buttonImage1 or buttonImage2
        elseif data.adventureGuideImage == "button" then
            return buttonImage1 or buttonImage2 or loreImage or bgImage
        elseif data.adventureGuideImage == "button2" then
            return buttonImage2 or buttonImage1 or loreImage or bgImage
        elseif data.adventureGuideImage == "lore" then
            return loreImage or bgImage or buttonImage1 or buttonImage2
        end
        return loreImage or bgImage or buttonImage1 or buttonImage2
    end

    return data.adventureFallbackTexture or data.icon
end

local function SetAdventureCover(data, displayTitle)
    aCoverTitle:SetText(displayTitle or (data and data.title) or "")
    local texture, useFullTexCoords = GetAdventureCoverTexture(data)
    local texCoords = data and data.adventureCoverTexCoords
    if texture then
        if texCoords then
            aCoverTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4])
        elseif useFullTexCoords then
            aCoverTexture:SetTexCoord(0, 1, SM.AdventureLoadingScreenTexTop, SM.AdventureLoadingScreenTexBottom)
        else
            aCoverTexture:SetTexCoord(
                ADVENTURE_COVER_TEX_LEFT,
                ADVENTURE_COVER_TEX_RIGHT,
                ADVENTURE_COVER_TEX_TOP,
                ADVENTURE_COVER_TEX_BOTTOM
            )
        end
        if not SM.SafeSetTexture(aCoverTexture, texture) then
            aCoverTexture:SetColorTexture(0.08, 0.07, 0.06, 1)
        end
    else
        aCoverTexture:SetColorTexture(0.08, 0.07, 0.06, 1)
    end
end

local function SetAdventureCoverTexture(tex, data)
    if not tex then return false end
    local texture, useFullTexCoords = GetAdventureCoverTexture(data)
    if not texture then
        tex:SetTexture(nil)
        return false
    end

    local texCoords = data and data.adventureCoverTexCoords
    if texCoords then
        tex:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4])
    elseif useFullTexCoords then
        tex:SetTexCoord(0, 1, SM.AdventureLoadingScreenTexTop, SM.AdventureLoadingScreenTexBottom)
    else
        tex:SetTexCoord(
            ADVENTURE_COVER_TEX_LEFT,
            ADVENTURE_COVER_TEX_RIGHT,
            ADVENTURE_COVER_TEX_TOP,
            ADVENTURE_COVER_TEX_BOTTOM
        )
    end

    if SM.SafeSetTexture(tex, texture) then
        return true
    end

    tex:SetTexture(nil)
    return false
end

local function SetChapterPortrait(portraitTex, displayID, iconPath, questID)
    -- Prevent stale portrait reuse when a source fails to resolve.
    portraitTex:SetTexture(nil)

    if questID and C_QuestLog and C_QuestLog.GetQuestPortraitGiver then
        local portrait = C_QuestLog.GetQuestPortraitGiver(questID)
        if portrait then
            portraitTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            portraitTex:SetTexture(portrait)
            if portraitTex:GetTexture() then
                return
            end
        end
    end

    local fallbackID = currentStoryData and currentStoryData.portraitDisplayID
    local tryID = nil
    if displayID and displayID ~= 0 then
        tryID = displayID
    elseif (SM.Client and SM.Client.isRetail) and fallbackID then
        tryID = fallbackID
    end
    if tryID then
        -- Creature portraits look best with a slight center crop.
        portraitTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        SetPortraitTextureFromCreatureDisplayID(portraitTex, tryID)
        if not portraitTex:GetTexture() then
            portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
            if not (iconPath and SM.SafeSetTexture(portraitTex, iconPath)) then
                local storyIcon = currentStoryData and currentStoryData.icon
                SM.SafeSetTexture(portraitTex, storyIcon or "Interface\\Icons\\INV_Misc_Map_01")
            end
        end
    elseif currentStoryData and currentStoryData.race and not currentStoryData.class then
        -- Heritage tracks: prefer achievement art, then cloak/tabard fallback.
        portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
        local achIcon
        if currentStoryData.achievementID then
            local _,_,_,_,_,_,_,_,_,icon = GetAchievementInfo(currentStoryData.achievementID)
            if icon and icon ~= 0 then achIcon = icon end
        end
        if not (achIcon and SM.SafeSetTexture(portraitTex, achIcon)) then
            local heritageIcon = HERITAGE_ICON_BY_RACE[currentStoryData.race]
            if not (heritageIcon and SM.SafeSetTexture(portraitTex, heritageIcon)) then
                if currentStoryData.race == "Pandaren" then
                    SM.SafeSetTexture(portraitTex, PANDAREN_TABARD_ICON)
                elseif not SM.SafeSetTexture(portraitTex, HERITAGE_ICON_FALLBACK) then
                    SM.SafeSetTexture(portraitTex, "Interface\\Icons\\INV_Misc_Map_01")
                end
            end
        end
    elseif iconPath then
        -- Chapter icon override (non-NPC visual) when a campaign defines one.
        portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
        if not SM.SafeSetTexture(portraitTex, iconPath) then
            local storyIcon = currentStoryData and currentStoryData.icon
            SM.SafeSetTexture(portraitTex, storyIcon or "Interface\\Icons\\INV_Misc_Map_01")
        end
    elseif currentStoryData and currentStoryData.icon then
        -- Tabard/banner icons often have transparent outer margins; crop inward for chapter portraits.
        portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
        if not SM.SafeSetTexture(portraitTex, currentStoryData.icon) then
            local fallback = currentStoryData.race and HERITAGE_ICON_BY_RACE[currentStoryData.race]
            if not (fallback and SM.SafeSetTexture(portraitTex, fallback)) then
                SM.SafeSetTexture(portraitTex, "Interface\\Icons\\INV_Misc_Map_01")
            end
        end
    else
        portraitTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        local fallback = currentStoryData and currentStoryData.race and HERITAGE_ICON_BY_RACE[currentStoryData.race]
        if fallback then
            portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
            SM.SafeSetTexture(portraitTex, fallback)
        else
            portraitTex:SetTexture(nil)
        end
    end
end

-- Resolve chapter portrait source: explicit chapter override first, then first quest's NPC portrait.
local function GetChapterPortraitSource(data, chapter)
    if not data or not chapter then
        return nil, nil
    end

    -- Heritage chains: use explicit chapter override when provided, otherwise first-quest NPC.
    if data.race and not data.class then
        if data.chapterDisplayIDs then
            local chapterDisplayID = data.chapterDisplayIDs[chapter.chapter]
            if chapterDisplayID and chapterDisplayID ~= 0 then
                return chapterDisplayID, nil
            end
        end
        if data.chapterIcons then
            local chapterIcon = data.chapterIcons[chapter.chapter]
            if chapterIcon and chapterIcon ~= "" then
                return nil, chapterIcon
            end
        end
        if data.npcDisplayIDs and chapter.quests then
            for _, q in ipairs(chapter.quests) do
                if not q.faction or q.faction == playerFaction then
                    local id = q.npc and data.npcDisplayIDs[q.npc]
                    if id and id ~= 0 then
                        return id, nil
                    end
                end
            end
        end
        return nil, nil
    end

    if data.chapterDisplayIDs then
        local chapterDisplayID = data.chapterDisplayIDs[chapter.chapter]
        if chapterDisplayID and chapterDisplayID ~= 0 then
            return chapterDisplayID, nil
        end
    end

    if data.chapterIcons then
        local chapterIcon = data.chapterIcons[chapter.chapter]
        if chapterIcon and chapterIcon ~= "" then
            return nil, chapterIcon
        end
    end

    if (SM.Client and SM.Client.isRetail) and data.npcDisplayIDs and chapter.quests then
        -- Walk the quest list to find the first quest whose faction matches (or has no faction).
        for _, q in ipairs(chapter.quests) do
            if not q.faction or q.faction == playerFaction then
                local id = q.npc and data.npcDisplayIDs[q.npc]
                if id and id ~= 0 then
                    return id, nil
                end
            end
        end
    end

    return nil, nil
end

-- ══ Renown-Track Style Chapter Selector + Quest Cards ══════════════════
-- Horizontal chapter track with quest detail cards below

local TRACK_NODE_SIZE = 48      -- portrait circle diameter
local TRACK_ARROW_GAP = 24      -- space between nodes (contains arrow)
local TRACK_STEP = TRACK_NODE_SIZE + TRACK_ARROW_GAP  -- 72px per step
local TRACK_H = 72              -- track container height

local QCARD_H = 44 + 8         -- quest card height (44 + 4px top/bottom padding)
local QCARD_GAP = 3            -- gap between cards

-- (quest cards now use housefinder atlas, no backdrop needed)

-- State
local dSelectedChapter = 1
local dTrackChapterCount = 0

-- Forward-declare pools (used by CenterTrackOnSelected)
local dTrackNodes = {}
local dTrackArrows = {}

-- ── Track container (persistent, created once) ──────────────────────
local dTrackContainer = CreateFrame("Frame", nil, detailChild)
dTrackContainer:SetHeight(TRACK_H)
dTrackContainer:Hide()

-- Clip frame — full width, fades are done via node alpha instead of overlays
local dTrackClip = CreateFrame("Frame", nil, dTrackContainer)
dTrackClip:SetClipsChildren(true)
dTrackClip:SetPoint("TOPLEFT", dTrackContainer, "TOPLEFT", 0, 0)
dTrackClip:SetPoint("BOTTOMRIGHT", dTrackContainer, "BOTTOMRIGHT", 0, 0)

-- Inner frame that slides left/right
local dTrackInner = CreateFrame("Frame", nil, dTrackClip)
dTrackInner:SetPoint("LEFT", dTrackClip, "LEFT", 0, 0)
dTrackInner:SetHeight(TRACK_H)

-- Centers the track so selected chapter is in the middle of the clip
-- Also applies distance-based alpha fade to each node
local function CenterTrackOnSelected(clipW)
    if clipW <= 0 then clipW = 350 end
    local selCenterX = (dSelectedChapter - 1) * TRACK_STEP + TRACK_NODE_SIZE / 2
    local offset = selCenterX - clipW / 2
    dTrackInner:ClearAllPoints()
    dTrackInner:SetPoint("LEFT", dTrackClip, "LEFT", -offset, 0)
    -- Apply distance-based alpha fade to nodes
    local center = clipW / 2
    local fadeStart = center - TRACK_NODE_SIZE  -- start fading past this distance
    local fadeEnd = clipW / 2 + 10             -- fully faded at edge
    for i, node in ipairs(dTrackNodes) do
        if not node:IsShown() then break end
        local nodeCenter = (i - 1) * TRACK_STEP + TRACK_NODE_SIZE / 2 - offset
        local dist = math.abs(nodeCenter - center)
        if dist <= fadeStart then
            node:SetAlpha(1.0)
        elseif dist >= fadeEnd then
            node:SetAlpha(0.0)
        else
            node:SetAlpha(1.0 - (dist - fadeStart) / (fadeEnd - fadeStart))
        end
    end
    -- Same for between-node arrows
    for i, arrow in ipairs(dTrackArrows) do
        if not arrow:IsShown() then break end
        local arrowX = (i - 1) * TRACK_STEP + TRACK_NODE_SIZE + TRACK_ARROW_GAP / 2 - offset
        local dist = math.abs(arrowX - center)
        if dist <= fadeStart then
            arrow:SetAlpha(1.0)
        elseif dist >= fadeEnd then
            arrow:SetAlpha(0.0)
        else
            arrow:SetAlpha(1.0 - (dist - fadeStart) / (fadeEnd - fadeStart))
        end
    end
end

-- Navigation arrows — always visible, navigate between chapters
local LayoutSelectedChapter  -- forward declare for arrow callbacks

local NAV_ARROW_SIZE = 26
local NAV_ARROW_INSET = 12

-- Left arrow
local dTrackLeftBtn = CreateFrame("Button", nil, dTrackContainer)
dTrackLeftBtn:SetSize(NAV_ARROW_SIZE + 16, NAV_ARROW_SIZE + 16)
dTrackLeftBtn:SetPoint("LEFT", dTrackContainer, "LEFT", NAV_ARROW_INSET, 5)
dTrackLeftBtn:SetFrameLevel(dTrackClip:GetFrameLevel() + 20)
local dTrackLeftTex = dTrackLeftBtn:CreateTexture(nil, "ARTWORK")
SM.SetStoryArrowTexture(dTrackLeftTex, "left", true)
dTrackLeftTex:SetSize(NAV_ARROW_SIZE, NAV_ARROW_SIZE)
dTrackLeftTex:SetPoint("CENTER")
dTrackLeftTex:SetVertexColor(0.85, 0.75, 0.55)
dTrackLeftBtn:SetScript("OnEnter", function() dTrackLeftTex:SetVertexColor(1, 0.90, 0.65) end)
dTrackLeftBtn:SetScript("OnLeave", function() dTrackLeftTex:SetVertexColor(0.85, 0.75, 0.55) end)
dTrackLeftBtn:SetScript("OnClick", function()
    if dSelectedChapter > 1 then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        dSelectedChapter = dSelectedChapter - 1
        LayoutSelectedChapter()
        C_Timer.After(0, function() CenterTrackOnSelected(dTrackClip:GetWidth()) end)
    end
end)

-- Right arrow
local dTrackRightBtn = CreateFrame("Button", nil, dTrackContainer)
dTrackRightBtn:SetSize(NAV_ARROW_SIZE + 16, NAV_ARROW_SIZE + 16)
dTrackRightBtn:SetPoint("RIGHT", dTrackContainer, "RIGHT", -NAV_ARROW_INSET, 5)
dTrackRightBtn:SetFrameLevel(dTrackClip:GetFrameLevel() + 20)
local dTrackRightTex = dTrackRightBtn:CreateTexture(nil, "ARTWORK")
SM.SetStoryArrowTexture(dTrackRightTex, "right", true)
dTrackRightTex:SetSize(NAV_ARROW_SIZE, NAV_ARROW_SIZE)
dTrackRightTex:SetPoint("CENTER")
dTrackRightTex:SetVertexColor(0.85, 0.75, 0.55)
dTrackRightBtn:SetScript("OnEnter", function() dTrackRightTex:SetVertexColor(1, 0.90, 0.65) end)
dTrackRightBtn:SetScript("OnLeave", function() dTrackRightTex:SetVertexColor(0.85, 0.75, 0.55) end)
dTrackRightBtn:SetScript("OnClick", function()
    if dSelectedChapter < dTrackChapterCount then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        dSelectedChapter = dSelectedChapter + 1
        LayoutSelectedChapter()
        C_Timer.After(0, function() CenterTrackOnSelected(dTrackClip:GetWidth()) end)
    end
end)

-- Mousewheel on track changes selection
dTrackContainer:EnableMouseWheel(true)
dTrackContainer:SetScript("OnMouseWheel", function(_, delta)
    if delta > 0 and dSelectedChapter > 1 then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        dSelectedChapter = dSelectedChapter - 1
        LayoutSelectedChapter()
        C_Timer.After(0, function() CenterTrackOnSelected(dTrackClip:GetWidth()) end)
    elseif delta < 0 and dSelectedChapter < dTrackChapterCount then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        dSelectedChapter = dSelectedChapter + 1
        LayoutSelectedChapter()
        C_Timer.After(0, function() CenterTrackOnSelected(dTrackClip:GetWidth()) end)
    end
end)

-- Chapter title + summary below track
local dChapterTitle = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Huge"))
dChapterTitle:SetJustifyH("CENTER")
dChapterTitle:Hide()

local dChapterSummary = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont"))
dChapterSummary:SetJustifyH("LEFT"); dChapterSummary:SetSpacing(4); dChapterSummary:SetWordWrap(true)
dChapterSummary:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
dChapterSummary:Hide()

-- Prerequisite note — shown when a chapter has a .note field
local dChapterNote = NoShadow(detailChild:CreateFontString(nil, "ARTWORK", "QuestFont_Shadow_Small"))
dChapterNote:SetJustifyH("LEFT"); dChapterNote:SetSpacing(3); dChapterNote:SetWordWrap(true)
dChapterNote:SetTextColor(1.0, 0.82, 0.35)
dChapterNote:Hide()

-- Mark as Viewed button — shown for loreOnly chapters (same template as story CTA)
local dMarkViewedBtn = CreateFrame("Button", nil, detailChild, sTrackBtnTemplate)
dMarkViewedBtn:SetSize(240, 40)
dMarkViewedBtn:SetText(L["Button Mark Viewed"])
dMarkViewedBtn:Hide()

-- Achievement reward line — clickable, shown when a chapter has an achievementID
local dChapterAchievement = CreateFrame("Button", nil, detailChild)
dChapterAchievement:SetHeight(18)
dChapterAchievement:Hide()
do
    local icon = dChapterAchievement:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", dChapterAchievement, "LEFT", 0, -1)
    dChapterAchievement.icon = icon

    local label = NoShadow(dChapterAchievement:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
    label:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    label:SetJustifyH("LEFT")
    dChapterAchievement.label = label

    dChapterAchievement:SetScript("OnClick", function(self)
        if self.achID then
            if AchievementFrame_ShowAchievement then
                AchievementFrame_ShowAchievement(self.achID)
            elseif AchievementFrame then
                ShowUIPanel(AchievementFrame)
            else
                ToggleAchievementFrame()
            end
        end
    end)
    dChapterAchievement:SetScript("OnEnter", function(self)
        self.label:SetTextColor(1, 1, 0.6)
    end)
    dChapterAchievement:SetScript("OnLeave", function(self)
        if self.achieved then
            self.label:SetTextColor(0.45, 0.90, 0.35)
        else
            self.label:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        end
    end)
end

-- Full-size achievement card for chapters that have no quest list.
-- Reuses CreateAchievementRow (defined later) — forward-created after that function.
local dChapterAchievementCard  -- assigned after CreateAchievementRow is defined

-- ── Track node pool ─────────────────────────────────────────────────
local function CreateTrackNode(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(TRACK_NODE_SIZE, TRACK_NODE_SIZE)

    -- Portrait
    local portrait = btn:CreateTexture(nil, "ARTWORK")
    portrait:SetSize(TRACK_NODE_SIZE - 4, TRACK_NODE_SIZE - 4)
    portrait:SetPoint("TOP", btn, "TOP", 0, 0)
    portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    portrait:SetTexelSnappingBias(0)
    portrait:SetSnapToPixelGrid(false)

    local mask = btn:CreateMaskTexture()
    mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(portrait)
    portrait:AddMaskTexture(mask)
    btn.portrait = portrait
    btn.portraitMask = mask

    -- Ring (circle border, shown for normal chapters)
    local ring = btn:CreateTexture(nil, "OVERLAY")
    local hasRingAtlas = SM.SafeSetAtlas(ring, "ui-frame-genericplayerchoice-portrait-border", false)
    if not hasRingAtlas then
        hasRingAtlas = SM.SafeSetTexture(ring, SM.ClassicPortraitRing)
            or SM.SafeSetTexture(ring, SM.ClassicPortraitRingFallback)
            or SM.SafeSetTexture(ring, "Interface\\Buttons\\UI-ActionButton-Border")
    end
    if hasRingAtlas then
        if SM.Client and SM.Client.isRetail then
            ring:SetPoint("TOPLEFT", portrait, "TOPLEFT", -3, 3)
            ring:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 3, -3)
        else
            ring:SetPoint("CENTER", portrait, "CENTER", 0, 0)
            ring:SetSize(TRACK_NODE_SIZE + 64, TRACK_NODE_SIZE + 64)
            ring:SetBlendMode("ADD")
            ring:SetVertexColor(1, 1, 1)
        end
    else
        ring:Hide()
    end
    btn.ring = ring
    btn.hasRingAtlas = hasRingAtlas

    local portraitBorder = SM.CreateSimpleBorder(btn, 2, "OVERLAY")
    portraitBorder.top:ClearAllPoints()
    portraitBorder.top:SetPoint("TOPLEFT", portrait, "TOPLEFT", -2, 2)
    portraitBorder.top:SetPoint("TOPRIGHT", portrait, "TOPRIGHT", 2, 2)
    portraitBorder.bottom:ClearAllPoints()
    portraitBorder.bottom:SetPoint("BOTTOMLEFT", portrait, "BOTTOMLEFT", -2, -2)
    portraitBorder.bottom:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 2, -2)
    portraitBorder.left:ClearAllPoints()
    portraitBorder.left:SetPoint("TOPLEFT", portrait, "TOPLEFT", -2, 2)
    portraitBorder.left:SetPoint("BOTTOMLEFT", portrait, "BOTTOMLEFT", -2, -2)
    portraitBorder.right:ClearAllPoints()
    portraitBorder.right:SetPoint("TOPRIGHT", portrait, "TOPRIGHT", 2, 2)
    portraitBorder.right:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 2, -2)
    SM.SetSimpleBorder(portraitBorder, 0.55, 0.48, 0.38, hasRingAtlas and 0 or 0.65)
    btn.portraitBorder = portraitBorder

    -- Square border (shown instead of ring for gated/prerequisite chapters).
    -- OVERLAY sublevel 5 places it above hl (sublevel -1) and ring (sublevel 0)
    -- within the same frame, so sublevel ordering is always guaranteed.
    local squareBorder = btn:CreateTexture(nil, "OVERLAY", nil, 5)
    if not SM.SafeSetAtlas(squareBorder, "talents-node-square-gray", false) then
        squareBorder:Hide()
    end
    squareBorder:SetPoint("TOPLEFT", portrait, "TOPLEFT", -3, 3)
    squareBorder:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 3, -3)
    squareBorder:Hide()
    btn.squareBorder = squareBorder

    -- Checkmark badge (top-right), sublevel 6 so it sits above squareBorder
    local checkmark = btn:CreateTexture(nil, "OVERLAY", nil, 6)
    if not SM.SafeSetAtlas(checkmark, "common-icon-checkmark", false) then
        SM.SafeSetTexture(checkmark, "Interface\\Buttons\\UI-CheckBox-Check")
    end
    checkmark:SetSize(18, 18)
    checkmark:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 5, -5)
    checkmark:Hide()
    btn.checkmark = checkmark

    -- Active glow (same as hover but always-on for selected node)
    local activeGlow = btn:CreateTexture(nil, "ARTWORK", nil, 3)
    activeGlow:SetTexture("Interface/Buttons/WHITE8x8")
    activeGlow:SetAllPoints(portrait)
    activeGlow:SetVertexColor(1, 0.82, 0.50, 0.25)
    local glowMask = btn:CreateMaskTexture()
    glowMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    glowMask:SetAllPoints(portrait)
    activeGlow:AddMaskTexture(glowMask)
    activeGlow:Hide()
    btn.activeGlow = activeGlow
    btn.glowMask = glowMask

    -- Hover glow mirrors the selected-node treatment without altering selection.
    local hoverGlow = btn:CreateTexture(nil, "ARTWORK", nil, 4)
    hoverGlow:SetTexture("Interface/Buttons/WHITE8x8")
    hoverGlow:SetAllPoints(portrait)
    hoverGlow:SetVertexColor(1, 0.82, 0.50, 0.25)
    local hoverGlowMask = btn:CreateMaskTexture()
    hoverGlowMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    hoverGlowMask:SetAllPoints(portrait)
    hoverGlow:AddMaskTexture(hoverGlowMask)
    hoverGlow:Hide()
    btn.hoverGlow = hoverGlow
    btn.hoverGlowMask = hoverGlowMask

    -- Down-arrow indicator (below node, points to quest cards)
    local downArrow = btn:CreateTexture(nil, "OVERLAY", nil, 3)
    SM.SetStoryArrowTexture(downArrow, "down", false)
    downArrow:SetSize(22, 22)
    downArrow:SetPoint("TOP", portrait, "BOTTOM", 0, 6)
    downArrow:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
    downArrow:Hide()
    btn.downArrow = downArrow

    -- Tooltip
    btn:SetScript("OnEnter", function(self)
        self.hoverGlow:SetVertexColor(1, 0.82, 0.50, self.isDimmed and 0.36 or 0.25)
        self.hoverGlow:Show()
        if self.isGated then
            self.squareBorder:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
            self.squareBorder:SetAlpha(1.0)
            SM.SetSimpleBorder(self.portraitBorder, C_GOLD[1], C_GOLD[2], C_GOLD[3], self.hasRingAtlas and 0 or 1.0)
        else
            self.ring:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
            self.ring:SetAlpha(1.0)
            SM.SetSimpleBorder(self.portraitBorder, C_GOLD[1], C_GOLD[2], C_GOLD[3], self.hasRingAtlas and 0 or 1.0)
        end
        if self.tooltipTitle then
            SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
            SMTooltip:ClearLines()
            SMTooltip:AddLine(self.tooltipTitle, 1, 1, 1)
            if self.tooltipBody then
                SMTooltip:AddLine(self.tooltipBody, C_BODY[1], C_BODY[2], C_BODY[3], true)
            end
            if self.tooltipProgress then
                SMTooltip:AddLine(" ")
                SMTooltip:AddLine(self.tooltipProgress, C_DIM[1], C_DIM[2], C_DIM[3])
            end
            if self.tooltipAchievementID then
                local _, achName, _, achDone = GetAchievementInfo(self.tooltipAchievementID)
                if achName then
                    SMTooltip:AddLine(" ")
                    if achDone then
                        SMTooltip:AddLine(achName, 0.45, 0.90, 0.35)
                    else
                        SMTooltip:AddLine(achName, C_GOLD[1], C_GOLD[2], C_GOLD[3])
                    end
                end
            end
            SMTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function(self)
        self.hoverGlow:Hide()
        if self.borderA then
            if self.isGated then
                self.squareBorder:SetVertexColor(self.borderR, self.borderG, self.borderB)
                self.squareBorder:SetAlpha(self.borderA)
                SM.SetSimpleBorder(self.portraitBorder, self.borderR, self.borderG, self.borderB, self.hasRingAtlas and 0 or self.borderA)
            else
                self.ring:SetVertexColor(self.borderR, self.borderG, self.borderB)
                self.ring:SetAlpha(self.borderA)
                SM.SetSimpleBorder(self.portraitBorder, self.borderR, self.borderG, self.borderB, self.hasRingAtlas and 0 or self.borderA)
            end
        end
        SMTooltip:Hide()
    end)

    return btn
end

-- ── Quest card pool ─────────────────────────────────────────────────
local dQuestCards = {}

local function CreateQuestCard(parent)
    local card = CreateFrame("Button", nil, parent, (SM.Client and SM.Client.isRetail) and nil or "BackdropTemplate")
    card:EnableMouse(true)
    card:SetHeight(QCARD_H)
    if not (SM.Client and SM.Client.isRetail) then
        SM.ApplyClassicCardBackdrop(card, 0.18, 0.50)
    end

    -- Housing endeavor-style card background
    local bg = card:CreateTexture(nil, "BACKGROUND")
    if SM.Client and SM.Client.isRetail then
        bg:SetAtlas("housing-dashboard-initiatives-tasks-listitem-bg", false)
    else
        SM.ClearCardFillTexture(bg)
    end
    bg:SetAllPoints()
    card.bg = bg
    if not (SM.Client and SM.Client.isRetail) then
        card.shade = SM.CreateInsetCardShade(card, 0.38)
    end

    local cardMask = card:CreateMaskTexture()
    cardMask:SetTexture("Interface/Buttons/WHITE8x8")
    cardMask:SetPoint("TOPLEFT", card, "TOPLEFT", 2, -2)
    cardMask:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -2, 2)
    bg:AddMaskTexture(cardMask)
    card.bgMask = cardMask

    -- Hover highlight
    if SM.Client and SM.Client.isRetail then
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
    local title = NoShadow(card:CreateFontString(nil, "ARTWORK", "GameFontNormal"))
    title:SetPoint("LEFT", card, "LEFT", TEXT_LEFT, 0)
    title:SetPoint("RIGHT", card, "RIGHT", -10, 0)
    title:SetPoint("BOTTOM", card, "CENTER", 0, 1)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("BOTTOM")
    title:SetWordWrap(false)
    card.title = title

    -- NPC name (bottom line, same left edge as title)
    local npcLabel = NoShadow(card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
    npcLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    npcLabel:SetPoint("RIGHT", card, "RIGHT", -10, 0)
    npcLabel:SetJustifyH("LEFT")
    npcLabel:SetWordWrap(false)
    card.npcLabel = npcLabel

    -- Tooltip — native quest tooltip with requirements lines removed
    card:SetScript("OnEnter", function(self)
        if not self.questID then return end
        SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
        SMTooltip:ClearLines()
        -- Quest name
        local qName = QuestUtils_GetQuestName(self.questID) or self.tooltipTitle or ""
        SMTooltip:AddLine(qName, 1, 1, 1)
        -- Quest giver
        if self.tooltipNPC then
            SMTooltip:AddLine(self.tooltipNPC, C_BODY[1], C_BODY[2], C_BODY[3])
        end
        -- Objectives — skip for completed quests; the log no longer tracks
        -- their counters so they always show stale "0/1" text.
        local qComplete = SM.IsQuestFlaggedCompleted(self.questID)
        if not qComplete then
            local objectives = SM.GetQuestObjectives(self.questID)
            if objectives and #objectives > 0 then
                SMTooltip:AddLine(" ")
                for _, obj in ipairs(objectives) do
                    if obj.text and obj.text ~= "" then
                        if obj.finished then
                            SMTooltip:AddLine(obj.text, 0.45, 0.90, 0.35, true)
                        else
                            SMTooltip:AddLine(obj.text, 0.9, 0.9, 0.9, true)
                        end
                    end
                end
            end
        end
        -- Status
        if self.tooltipStatus then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine(self.tooltipStatus)
        end
        if self.tooltipRequirement then
            SMTooltip:AddLine(self.tooltipRequirement, 1.0, 0.82, 0.35, true)
        end

        SMTooltip:Show()
    end)
    card:SetScript("OnLeave", function() SMTooltip:Hide() end)

    return card
end

-- ── Achievement row ──────────────────────────────────────────────────
local AROW_H     = 44    -- row height
local AROW_MAX_W = 300   -- max row width, centered in the panel
local AICON_SZ   = 32    -- icon size
local AROW_PAD   = 16    -- inner left/right padding

local function CreateAchievementRow(parent)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(AROW_H)
    row:EnableMouse(true)

    -- Hover: fading gradient tint (transparent → tint → transparent), shown/hidden manually
    local hlL = row:CreateTexture(nil, "BACKGROUND")
    hlL:SetTexture(SOLID)
    hlL:SetPoint("LEFT",  row, "LEFT",   0, 0)
    hlL:SetPoint("RIGHT", row, "CENTER", 0, 0)
    hlL:SetHeight(AROW_H)
    hlL:SetGradient("HORIZONTAL",
        CreateColor(C_BODY[1], C_BODY[2], C_BODY[3], 0),
        CreateColor(C_BODY[1], C_BODY[2], C_BODY[3], 0.12))
    hlL:Hide()
    local hlR = row:CreateTexture(nil, "BACKGROUND")
    hlR:SetTexture(SOLID)
    hlR:SetPoint("LEFT",  row, "CENTER", 0, 0)
    hlR:SetPoint("RIGHT", row, "RIGHT",  0, 0)
    hlR:SetHeight(AROW_H)
    hlR:SetGradient("HORIZONTAL",
        CreateColor(C_BODY[1], C_BODY[2], C_BODY[3], 0.12),
        CreateColor(C_BODY[1], C_BODY[2], C_BODY[3], 0))
    hlR:Hide()
    row.hlL, row.hlR = hlL, hlR

    -- Icon
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(AICON_SZ, AICON_SZ)
    icon:SetPoint("LEFT", row, "LEFT", AROW_PAD, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    row.icon = icon

    -- Talent node square border, tinted gold
    local iconBorder = row:CreateTexture(nil, "OVERLAY", nil, 2)
    if not SM.SafeSetAtlas(iconBorder, "talents-node-square-gray", false) then
        iconBorder:Hide()
    end
    iconBorder:SetSize(AICON_SZ + 8, AICON_SZ + 8)
    iconBorder:SetPoint("CENTER", icon, "CENTER", 0, 0)
    iconBorder:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
    row.iconBorder = iconBorder

    -- Achievement name
    local title = NoShadow(row:CreateFontString(nil, "ARTWORK", "GameFontNormal"))
    title:SetPoint("LEFT",  icon, "RIGHT",  10,        0)
    title:SetPoint("RIGHT", row,  "RIGHT",  -AROW_PAD, 0)
    title:SetJustifyH("LEFT")
    title:SetWordWrap(false)
    row.title = title

    -- Tooltip + hover
    row:SetScript("OnEnter", function(self)
        hlL:Show(); hlR:Show()
        if not self.achievementID then return end
        local _, achName, _, completed, month, day, year, description, _, _, _, rewardText =
            GetAchievementInfo(self.achievementID)
        SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
        SMTooltip:ClearLines()
        SMTooltip:AddLine(achName or "", 1, 1, 1)
        -- Completion status
        if completed then
            local dateStr = (month and month > 0)
                and (" — " .. month .. "/" .. day .. "/" .. year) or ""
            SMTooltip:AddLine(L["Achievement Earned"] .. dateStr, 0.2, 0.83, 0.2)
        else
            SMTooltip:AddLine(L["Achievement Not Yet Earned"], C_DIM[1], C_DIM[2], C_DIM[3])
        end
        -- Description
        if description and description ~= "" then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine(description, C_BODY[1], C_BODY[2], C_BODY[3], true)
        end
        -- Criteria
        local numCriteria = GetAchievementNumCriteria(self.achievementID)
        if numCriteria and numCriteria > 0 then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine(L["Achievement Criteria"], C_GOLD[1], C_GOLD[2], C_GOLD[3])
            for i = 1, numCriteria do
                local criteriaName, _, critCompleted = GetAchievementCriteriaInfo(self.achievementID, i)
                if criteriaName and criteriaName ~= "" then
                    local check = critCompleted and "|TInterface\\RaidFrame\\ReadyCheck-Ready:12:12|t" or "|TInterface\\RaidFrame\\ReadyCheck-NotReady:12:12|t"
                    local r, g, b = critCompleted and 0.2 or C_BODY[1], critCompleted and 0.83 or C_BODY[2], critCompleted and 0.2 or C_BODY[3]
                    SMTooltip:AddLine(check .. " " .. criteriaName, r, g, b, true)
                end
            end
        end
        -- Reward
        if type(rewardText) == "string" and rewardText ~= "" then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine(string.format(L["Achievement Reward Format"], rewardText), C_GOLD[1], C_GOLD[2], C_GOLD[3], true)
        end
        SMTooltip:AddLine(" ")
        SMTooltip:AddLine(L["Achievement Open Log"], 0.5, 0.5, 0.5)
        SMTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
        hlL:Hide(); hlR:Hide()
        SMTooltip:Hide()
    end)
    row:SetScript("OnClick", function(self)
        if not self.achievementID then return end
        SMTooltip:Hide()
        storyFrame:Hide()
        if not AchievementFrame then SM.LoadAddOn("Blizzard_AchievementUI") end
        if AchievementFrame and ShowUIPanel and AchievementFrame_SelectAchievement then
            ShowUIPanel(AchievementFrame)
            AchievementFrame_SelectAchievement(self.achievementID)
        end
    end)

    return row
end

-- Assign the forward-declared chapter achievement card now that CreateAchievementRow exists.
dChapterAchievementCard = CreateAchievementRow(detailChild)
dChapterAchievementCard:Hide()

-- ── Render quest cards for selected chapter ─────────────────────────
LayoutSelectedChapter = function()
    local data = currentStoryData
    if not data then return end
    local chapters = GetAllChapters(data)
    local ch = chapters[dSelectedChapter]
    if not ch then return end

    -- Update nav arrow enabled state
    local canGoLeft = dSelectedChapter > 1
    local canGoRight = dSelectedChapter < dTrackChapterCount
    dTrackLeftBtn:SetEnabled(canGoLeft)
    dTrackLeftTex:SetVertexColor(canGoLeft and 0.85 or 0.3, canGoLeft and 0.75 or 0.25, canGoLeft and 0.55 or 0.2)
    dTrackLeftTex:SetAlpha(canGoLeft and 1.0 or 0.3)
    dTrackRightBtn:SetEnabled(canGoRight)
    dTrackRightTex:SetVertexColor(canGoRight and 0.85 or 0.3, canGoRight and 0.75 or 0.25, canGoRight and 0.55 or 0.2)
    dTrackRightTex:SetAlpha(canGoRight and 1.0 or 0.3)

    -- Update track selection visuals: selected node gets gold ring + glow.
    -- Deselected nodes get their completion-state ring color restored.
    -- Gated nodes (with prerequisites) use squareBorder instead of ring.
    local function SetNodeBorder(node, r, g, b, a)
        if SM.Client and SM.Client.isRetail then
            node.ring:SetVertexColor(r, g, b)
        else
            node.ring:SetVertexColor(1, 1, 1)
        end
        local ringAlpha = (SM.Client and SM.Client.isRetail) and a or 1.0
        node.ring:SetAlpha(ringAlpha)
        node.borderR, node.borderG, node.borderB, node.borderA = r, g, b, ringAlpha
        if node.isGated then
            node.squareBorder:SetVertexColor(r, g, b)
            node.squareBorder:SetAlpha(a)
        end
    end
    for i, node in ipairs(dTrackNodes) do
        if not node:IsShown() then break end
        if i == dSelectedChapter then
            SetNodeBorder(node, C_GOLD[1], C_GOLD[2], C_GOLD[3], 1.0)
            node.activeGlow:Show()
            node.downArrow:Show()
        else
            node.activeGlow:Hide()
            node.downArrow:Hide()
            -- Restore completion-state border color so it doesn't stay gold.
            local thCh = chapters[i]
            if thCh then
                if thCh.loreOnly then
                    local loreViewed = SM.IsLoreChapterViewed(data.title, thCh.chapter)
                    if loreViewed then
                        SetNodeBorder(node, RING_GREEN_R, RING_GREEN_G, RING_GREEN_B, 0.8)
                        node.checkmark:Show()
                    else
                        SetNodeBorder(node, 0.55, 0.48, 0.38, 0.55)
                        node.checkmark:Hide()
                    end
                else
                    local cd, ct = GetChapterProgress(thCh)
                    local isComp = cd == ct and ct > 0
                    local isAct  = cd > 0 and not isComp
                    if isComp then
                        SetNodeBorder(node, RING_GREEN_R, RING_GREEN_G, RING_GREEN_B, 0.8)
                    elseif isAct then
                        SetNodeBorder(node, RING_GOLD_R, RING_GOLD_G, RING_GOLD_B, 0.9)
                    else
                        SetNodeBorder(node, 0.4, 0.35, 0.30, 0.5)
                    end
                end
            end
        end
    end

    -- Chapter title + summary
    dChapterTitle:SetText(ch.chapter)
    dChapterTitle:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
    dChapterTitle:Show()

    if ch.summary then
        dChapterSummary:SetText(ch.summary)
        dChapterSummary:Show()
    else
        dChapterSummary:Hide()
    end

    local chapterRequiredLevel = ch.requiredLevel
    local playerLevel = UnitLevel("player") or 0
    if chapterRequiredLevel and playerLevel < chapterRequiredLevel then
        dChapterNote:SetText(string.format(L["Lock Required Level Format"], chapterRequiredLevel))
        dChapterNote:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        dChapterNote:Show()
    elseif ch.gated and ch.note then
        dChapterNote:SetText(ch.note)
        dChapterNote:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        dChapterNote:Show()
    elseif ch.prerequisites then
        local req = GetFirstUnmetChapterPrerequisite(ch)
        if req then
            local reqQuest = req.name or string.format(L["Quest ID Format"], tostring(req.id))
            if req.npc then
                dChapterNote:SetText(string.format(L["Lock Speak Pick Up Quest Format"], req.npc, reqQuest))
            else
                dChapterNote:SetText(string.format(L["Lock Complete Quest Format"], reqQuest))
            end
            dChapterNote:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
            dChapterNote:Show()
        else
            dChapterNote:Hide()
        end
    else
        dChapterNote:Hide()
    end

    local cdNote, ctNote = GetChapterProgress(ch)
    local chIsComplete = cdNote == ctNote and ctNote > 0

    -- Mark as Viewed / Mark as Played button
    if ch.loreOnly or ch.replayable then
        local btnAnchor = dChapterNote:IsShown() and dChapterNote
                       or dChapterSummary:IsShown() and dChapterSummary
                       or dChapterTitle
        dMarkViewedBtn:ClearAllPoints()
        dMarkViewedBtn:SetPoint("TOP", btnAnchor, "BOTTOM", 0, -14)
        if chIsComplete then
            dMarkViewedBtn:SetText(ch.loreOnly and L["Button Watched"] or L["Button Played"])
            dMarkViewedBtn:SetScript("OnClick", nil)
            dMarkViewedBtn:Disable()
            dMarkViewedBtn:SetAlpha(0.5)
        elseif ch.loreOnly then
            dMarkViewedBtn:SetText(L["Button Mark Viewed"])
            dMarkViewedBtn:SetScript("OnClick", function()
                SM.SetLoreChapterViewed(data.title, ch.chapter)
                LayoutSelectedChapter()
            end)
            dMarkViewedBtn:Enable()
            dMarkViewedBtn:SetAlpha(1.0)
        else
            dMarkViewedBtn:SetText(L["Button Mark Played"])
            dMarkViewedBtn:SetScript("OnClick", function()
                SM.SetChapterPlayed(data.title, ch.chapter)
                LayoutSelectedChapter()
            end)
            dMarkViewedBtn:Enable()
            dMarkViewedBtn:SetAlpha(1.0)
        end
        dMarkViewedBtn:Show()
    else
        dMarkViewedBtn:Hide()
    end

    -- Achievement reward line — only shown for chapters that also have quest cards.
    -- Quest-less chapters (achievementID, no quests) use the full card below instead.
    -- Replayable chapters suppress this row; the button is the sole interaction.
    local achID = ch.achievementID
    if achID and #ch.quests > 0 and not ch.replayable then
        local _, achName, _, achDone, _,_,_,_, _, achIcon = GetAchievementInfo(achID)
        if achName then
            dChapterAchievement.achID = achID
            dChapterAchievement.achieved = achDone
            if achIcon then
                dChapterAchievement.icon:SetTexture(achIcon)
                dChapterAchievement.icon:Show()
            else
                dChapterAchievement.icon:Hide()
            end
            dChapterAchievement.label:SetText(achName)
            if achDone then
                dChapterAchievement.label:SetTextColor(0.45, 0.90, 0.35)
            else
                dChapterAchievement.label:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
            end
            local achHeaderAnchor = dChapterNote:IsShown() and dChapterNote
                                 or dChapterSummary:IsShown() and dChapterSummary
                                 or dChapterTitle
            dChapterAchievement:ClearAllPoints()
            dChapterAchievement:SetPoint("TOPLEFT", achHeaderAnchor, "BOTTOMLEFT", 0, -8)
            dChapterAchievement:SetPoint("TOPRIGHT", detailChild, "RIGHT", -CP, 0)
            dChapterAchievement:Show()
        else
            dChapterAchievement:Hide()
        end
    else
        dChapterAchievement:Hide()
    end

    -- Quest cards — skipped for replayable chapters (button is the sole interaction point)
    local nextQuest = FindNextQuest(data)
    local nextQuestID = nextQuest and nextQuest.id
    local campaignFinished = (nextQuestID == nil)

    for i, q in ipairs(ch.quests) do
        if not dQuestCards[i] then
            dQuestCards[i] = CreateQuestCard(detailChild)
        end
        local card = dQuestCards[i]
        if ch.replayable or not IsQuestForPlayer(q) or ShouldHideQuest(q) then
            card:Hide()
        else
            local qOptional = q.optional == true
            local qDone = IsQuestEffectivelyComplete(i, ch.quests)
            local qInLog = not qDone and IsQuestInLog(q.id)
            -- Display fallback: if the story has no next quest ("Story Finished"),
            -- treat remaining cards as complete for UI purposes.
            local qDoneDisplay = qDone or (campaignFinished and not qInLog and not qOptional)
            local qIsNextRecommended = (q.id == nextQuestID)
            local lockReason = (not qDoneDisplay and not qInLog and not qOptional) and GetQuestLockReason(data, ch, i) or nil

            card.title:SetText(q.displayName or q.name)
            card.npcLabel:SetText(q.npc or "")
            card.questID = q.id
            card.tooltipTitle = q.name
            card.tooltipNPC = q.npc
            card.tooltipStatus = qDoneDisplay and ("|cff59c746" .. L["Quest Status Completed"] .. "|r")
                or qInLog and ("|cffffd223" .. L["Quest Status In Progress"] .. "|r")
                or qOptional and ("|cff808080" .. L["Quest Status Optional"] .. "|r")
                or ("|cff808080" .. L["Quest Status Not Available"] .. "|r")
            card.tooltipRequirement = lockReason

            card.icon:SetSize(14, 14)
            card.icon:SetDesaturation(0)
            if qDoneDisplay then
                if not SM.SafeSetAtlas(card.icon, "common-icon-checkmark", false) then
                    SM.SafeSetTexture(card.icon, "Interface\\Buttons\\UI-CheckBox-Check")
                end
                card.icon:SetVertexColor(0.45, 0.90, 0.35)
                card.icon:Show()
                card.title:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3], 0.8)
                card.npcLabel:SetTextColor(C_BODY[1] * 0.8, C_BODY[2] * 0.8, C_BODY[3] * 0.8, 0.6)
                card:SetAlpha(1.0)
            elseif qInLog or qIsNextRecommended then
                SM.SetStoryArrowTexture(card.icon, "right", "money")
                card.icon:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
                card.icon:Show()
                card.title:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
                card.npcLabel:SetTextColor(C_BODY[1] * 0.8, C_BODY[2] * 0.8, C_BODY[3] * 0.8, 0.7)
                card:SetAlpha(1.0)
            elseif qOptional then
                card.icon:Hide()
                card.title:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3], 0.4)
                card.npcLabel:SetTextColor(C_BODY[1] * 0.8, C_BODY[2] * 0.8, C_BODY[3] * 0.8, 0.3)
                card:SetAlpha(0.55)
            else
                card.icon:Hide()
                card.title:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3], 0.6)
                card.npcLabel:SetTextColor(C_BODY[1] * 0.8, C_BODY[2] * 0.8, C_BODY[3] * 0.8, 0.4)
                card:SetAlpha(0.8)
            end
            card:Show()
        end
    end
    for i = #ch.quests + 1, #dQuestCards do dQuestCards[i]:Hide() end

    -- For chapters with no quests, show a full achievement card instead.
    local CARD_W = 280
    if #ch.quests == 0 and ch.achievementID then
        local _, achName, _, achDone, _,_,_,_,_, achIcon = GetAchievementInfo(ch.achievementID)
        if achName then
            dChapterAchievementCard.achievementID = ch.achievementID
            dChapterAchievementCard.icon:SetTexture(achIcon)
            dChapterAchievementCard.icon:SetDesaturated(not achDone)
            dChapterAchievementCard.title:SetText(achName)
            dChapterAchievementCard.title:SetTextColor(
                achDone and C_BODY[1] or C_DIM[1],
                achDone and C_BODY[2] or C_DIM[2],
                achDone and C_BODY[3] or C_DIM[3])
            local anchor = dChapterNote:IsShown() and dChapterNote
                        or dChapterSummary:IsShown() and dChapterSummary
                        or dChapterTitle
            dChapterAchievementCard:ClearAllPoints()
            dChapterAchievementCard:SetWidth(CARD_W)
            dChapterAchievementCard:SetPoint("TOP",  anchor,      "BOTTOM", 0,         -20)
            dChapterAchievementCard:SetPoint("LEFT", detailChild, "CENTER", -CARD_W/2,   0)
            dChapterAchievementCard:Show()
        else
            dChapterAchievementCard:Hide()
        end
    else
        dChapterAchievementCard:Hide()
    end

    -- Position visible quest cards below the header area
    local prevCard = nil
    for i = 1, #ch.quests do
        local card = dQuestCards[i]
        if card and card:IsShown() then
            card:ClearAllPoints()
            card:SetWidth(CARD_W)
            if not prevCard then
                local anchor = dChapterAchievement:IsShown() and dChapterAchievement
                            or dChapterNote:IsShown() and dChapterNote
                            or dChapterSummary:IsShown() and dChapterSummary
                            or dChapterTitle
                card:SetPoint("TOP", anchor, "BOTTOM", 0, -20)
            else
                card:SetPoint("TOP", prevCard, "BOTTOM", 0, -QCARD_GAP)
            end
            -- Center horizontally: anchor LEFT relative to detailChild center
            card:SetPoint("LEFT", detailChild, "CENTER", -CARD_W / 2, 0)
            prevCard = card
        end
    end

    -- Update scroll height.
    -- For achievement-card-only chapters (no quest cards), the card sits below a
    -- word-wrapped FontString whose height may not be resolved on the zero-delay tick.
    -- A second pass at 0.1 s gives fonts time to finish layout so GetBottom() is accurate
    -- and the card lands within the scroll child's interactive region.
    -- NOTE: no SetHeight pre-sizing here — quest cards anchor their LEFT edge to
    -- detailChild CENTER, so changing detailChild's height shifts their Y position.
    local scrollAnchor = prevCard
                      or (dChapterAchievementCard:IsShown() and dChapterAchievementCard)
                      or (dMarkViewedBtn:IsShown() and dMarkViewedBtn)

    local function UpdateScrollHeight()
        if not scrollAnchor then return end
        local bot = scrollAnchor:GetBottom()
        local top = detailChild:GetTop()
        if bot and top then
            detailChild:SetHeight(math.max(top - bot + 30, 400))
        end
    end

    C_Timer.After(0, UpdateScrollHeight)

    -- Second pass only needed for achievement-card-only chapters.
    if not prevCard and dChapterAchievementCard:IsShown() then
        C_Timer.After(0.1, function()
            if dChapterAchievementCard:IsShown() then
                UpdateScrollHeight()
            end
        end)
    end
end

local progressElements = { dProgSummary, dTrackContainer, dChapterTitle, dChapterSummary, dChapterNote, dChapterAchievement, dChapterAchievementCard, dMarkViewedBtn }

local function ShowDetail(show)
    -- Always hide both frames here. When opening a new story, the hero icon
    -- and adventure cover both still hold the previous story's content, and
    -- ShowTab (which runs from the deferred LayoutDetailTab) is what reveals
    -- the correct frame once the new texture/title have been assigned. Showing
    -- heroFrame eagerly here caused a 1–2 frame flicker of the old content.
    heroFrame:Hide()
    aCoverFrame:Hide()
end

local function ShowTab(tab)
    -- Hide all tab-specific elements
    for _, el in ipairs(storyElements) do el:Hide() end
    for _, el in ipairs(journalElements) do el:Hide() end
    for _, entry in ipairs(sJournalEntries) do entry.title:Hide(); entry.body:Hide() end
    for _, el in ipairs(progressElements) do el:Hide() end
    for _, node in ipairs(dTrackNodes) do node:Hide() end
    for _, arrow in ipairs(dTrackArrows) do arrow:Hide() end
    for _, card in ipairs(dQuestCards) do card:Hide() end
    sTrackBtn:Hide(); sCompleteText:Hide()
    dCompleteText:Hide()
    aCoverFrame:Hide()
    FactionUI:HideAll()
    heroFrame:Hide()
    heroPort:Show()
    heroFrame:SetHeight(HERO_ICON + 60)
    dTitle:ClearAllPoints()
    dTitle:SetPoint("TOP", heroPort, "BOTTOM", 0, -12)
    if tab ~= "story" then
        pendingSecureTrack = nil
        sTrackBtnSecure:SetScript("PreClick", nil)
    end

    if tab == "story" then
        heroFrame:Hide()
        aCoverFrame:Show()
        for _, el in ipairs(storyElements) do el:Show() end
    elseif tab == "journal" then
        for _, el in ipairs(journalElements) do el:Show() end
    elseif tab == "progress" then
        heroPort:Hide()
        heroFrame:SetHeight(50)
        dTitle:ClearAllPoints()
        dTitle:SetPoint("TOP", heroFrame, "TOP", 0, -18)
        heroFrame:Show()
        for _, el in ipairs(progressElements) do el:Show() end
    end
end

local function SetActiveTab(tab)
    activeTab = tab
    if tab == "story" then
        tabStoryLabel:SetTextColor(1, 1, 1)
        tabProgressLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        tabJournalLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
    elseif tab == "journal" then
        tabStoryLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        tabProgressLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        tabJournalLabel:SetTextColor(1, 1, 1)
    else
        tabStoryLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        tabProgressLabel:SetTextColor(1, 1, 1)
        tabJournalLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
    end
end

ShowDetail(false)
for _, el in ipairs(storyElements) do el:Hide() end
for _, el in ipairs(journalElements) do el:Hide() end
for _, el in ipairs(progressElements) do el:Hide() end

-- ════════════════════════════════════════════════════════════════════════════
-- UpdateStoryDetail  +  LayoutDetailTab
-- ════════════════════════════════════════════════════════════════════════════

local storySelectedIdx = nil

-- ── Layout the currently active tab ─────────────────────────────────────────
-- The per-tab branches each live in their own local function so that the
-- dispatcher does not exceed Lua's 60-upvalue limit.

local function LayoutStoryTab(data, w, contentW, visibleContentW)
        -- ── STORY TAB layout ────────────────────────────────────────────
        -- Clean top-down chain: cover → intro → CTA

        -- The fade mask has 40px transparent borders on a 512px-wide canvas, so
        -- the visually opaque portion of the cover is 432/512 = 0.84375 of the
        -- frame width. Bleed the frame outward on both sides so the *visible*
        -- area lines up with the text content bounds.
        local COVER_MASK_VISIBLE_X = 432 / 512
        local visibleTargetW = math.min(ADVENTURE_COVER_W, contentW)
        if visibleTargetW < 360 then visibleTargetW = 360 end
        local coverW = visibleTargetW / COVER_MASK_VISIBLE_X
        local coverH = coverW
            * ((ADVENTURE_COVER_TEX_BOTTOM - ADVENTURE_COVER_TEX_TOP)
            / (ADVENTURE_COVER_TEX_RIGHT - ADVENTURE_COVER_TEX_LEFT))
        local hBleed = (coverW - visibleTargetW) / 2
        aCoverFrame:ClearAllPoints()
        aCoverFrame:SetPoint("TOPLEFT", detailChild, "TOPLEFT", CP - hBleed, -18)
        aCoverFrame:SetSize(coverW, coverH)
        aCoverTexture:SetSize(coverW, coverH)
        aCoverTitle:SetWidth(visibleTargetW - 56)
        aCoverDivider:ClearAllPoints()
        aCoverDivider:SetPoint("TOP", aCoverTitle, "BOTTOM", 0, -6)
        local titleW = aCoverTitle:GetStringWidth()
        if titleW < 60 then titleW = 60 end
        aCoverDivider:SetWidth(titleW)
        aCoverFrame:Show()

        -- Story intro below hero
        sIntro:ClearAllPoints()
        sIntro:SetPoint("TOPLEFT",  detailChild, "TOPLEFT",  CP, -(coverH + 40))
        sIntro:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", -CP, -(coverH + 40))
        if contentW > 20 then sIntro:SetWidth(contentW) end

        local lastAnchor = sIntro

        FactionUI:HideAll()

        -- CTA button
        local quest, _, nextChapter = FindNextQuest(data)
        local done = select(1, GetCampaignProgress(data))
        local gateReason = GetQuestlineGateReason(data, nextChapter)
        sTrackBtn:ClearAllPoints()
        sTrackBtn:SetPoint("TOP", lastAnchor, "BOTTOM", 0, -24)
        sCompleteText:Hide()
        if quest then
            if gateReason then
                sTrackBtn:SetText(L["Button Story Locked"])
                sTrackBtn:SetScript("OnClick", nil)
                sTrackBtnSecure:SetScript("PreClick", nil)
                sTrackBtn:Disable()
                sTrackBtn:SetAlpha(0.5)
                sTrackBtn.lockReason = gateReason
            else
                sTrackBtn:SetText(done > 0 and L["Button Continue Story"] or L["Button Begin Story"])
                -- PreClick on the secure overlay queues the action BEFORE the
                -- macro fires. The macro then performs the waypoint +
                -- supertrack calls in a secure execution context.
                sTrackBtnSecure:SetScript("PreClick", function()
                    pendingSecureTrack = { data = data, quest = quest }
                end)
                sTrackBtn:SetScript("OnClick", nil)
                sTrackBtn:Enable()
                sTrackBtn:SetAlpha(1.0)
                sTrackBtn.lockReason = nil
            end
        else
            sTrackBtn:SetText(L["Button Story Finished"])
            sTrackBtn:SetScript("OnClick", nil)
            sTrackBtnSecure:SetScript("PreClick", nil)
            sTrackBtn:Disable()
            sTrackBtn:SetAlpha(0.5)
            sTrackBtn.lockReason = nil
        end
        sTrackBtn:Show()
        SyncSecureOverlay()
        lastAnchor = sTrackBtn

        local storyBottomEl = lastAnchor
        -- Set scroll height
        C_Timer.After(0, function()
            local bot = storyBottomEl:GetBottom()
            local top = detailChild:GetTop()
            if bot and top then
                detailChild:SetHeight(math.max(top - bot + 40, 400))
            else
                detailChild:SetHeight(500)
            end
        end)
end

local function LayoutJournalTab(data, w, contentW, visibleContentW)
        -- ── JOURNAL TAB layout ──────────────────────────────────────────
        -- Show recap for each completed chapter (no spoilers for future ones)
        local chapters = GetAllChapters(data)
        local journalIdx = 0
        local hasAnyRecap = false
        local quest = FindNextQuest(data)
        local done = GetCampaignProgress(data)
        local lastAnchor = sJournalHeader

        -- Factions live in the contextual left panel on the Journal tab.
        FactionUI:HideAll()
        sFactionHeader:Hide()

        sJournalHeader:SetText(quest and L["Journal Header"] or L["Journal Header Complete"])
        sJournalHeader:ClearAllPoints()
        sJournalHeader:SetPoint("TOP", detailChild, "TOP", 0, -18)
        sJournalHeader:Show()

        sJournalSubline:ClearAllPoints()
        sJournalSubline:SetPoint("TOP", sJournalHeader, "BOTTOM", 0, -4)
        sJournalSubline:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
        sJournalSubline:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
        if contentW > 20 then sJournalSubline:SetWidth(contentW) end
        sJournalSubline:Show()

        for ci, ch in ipairs(chapters) do
            local cd, ct = GetChapterProgress(ch)
            local chComplete = cd == ct and ct > 0
            if chComplete and ch.recap then
                journalIdx = journalIdx + 1
                hasAnyRecap = true
                local entry = GetJournalEntry(journalIdx)

                -- Chapter title
                entry.title:ClearAllPoints()
                if journalIdx == 1 then
                    entry.title:SetPoint("TOP", sJournalSubline, "BOTTOM", 0, -18)
                else
                    local prev = sJournalEntries[journalIdx - 1]
                    entry.title:SetPoint("TOP", prev.body, "BOTTOM", 0, -20)
                end
                entry.title:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
                entry.title:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
                entry.title:SetText(ch.chapter)
                entry.title:Show()

                -- Recap body
                entry.body:ClearAllPoints()
                entry.body:SetPoint("TOP", entry.title, "BOTTOM", 0, -6)
                entry.body:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
                entry.body:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
                entry.body:SetText(ch.recap)
                entry.body:Show()

                lastAnchor = entry.body
            end
        end

        if not hasAnyRecap then
            sJournalHeader:Hide()
            sJournalSubline:Hide()
            local emptyTop = -math.max(150, math.floor((detailScroll:GetHeight() or 420) * 0.42))
            sJournalEmptyTitle:ClearAllPoints()
            sJournalEmptyTitle:SetPoint("TOP", detailChild, "TOP", 0, emptyTop)
            sJournalEmptyTitle:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
            sJournalEmptyTitle:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
            if done > 0 then
                sJournalEmptyTitle:SetText(L["Journal No Recaps Title"])
                sJournalEmptyText:SetText(L["Journal No Recaps Text"])
            else
                sJournalEmptyTitle:SetText(L["Journal Empty Title"])
                sJournalEmptyText:SetText(L["Journal Empty Text"])
            end
            sJournalEmptyTitle:Show()
            sJournalEmptyText:ClearAllPoints()
            sJournalEmptyText:SetPoint("TOPLEFT", sJournalEmptyTitle, "BOTTOMLEFT", 0, -8)
            sJournalEmptyText:SetPoint("TOPRIGHT", sJournalEmptyTitle, "BOTTOMRIGHT", 0, -8)
            if contentW > 20 then sJournalEmptyText:SetWidth(contentW) end
            sJournalEmptyText:Show()
            lastAnchor = sJournalEmptyText
        else
            sJournalHeader:Show()
            sJournalSubline:Show()
            sJournalEmptyTitle:Hide()
            sJournalEmptyText:Hide()
        end

        -- Hide unused journal entries
        for i = journalIdx + 1, #sJournalEntries do
            sJournalEntries[i].title:Hide()
            sJournalEntries[i].body:Hide()
        end

        local journalBottomEl = lastAnchor
        -- Set scroll height
        C_Timer.After(0, function()
            local bot = journalBottomEl:GetBottom()
            local top = detailChild:GetTop()
            if bot and top then
                detailChild:SetHeight(math.max(top - bot + 40, 400))
            else
                detailChild:SetHeight(500)
            end
        end)
end

local function LayoutProgressTab(data, w, contentW, visibleContentW)
        -- ── PROGRESS TAB layout ─────────────────────────────────────────
        local chapters = GetAllChapters(data)

        -- CTA
        -- Progress summary line
        local done, total = GetCampaignProgress(data)
        local chapDone = 0
        for ci, ch in ipairs(chapters) do
            local cd, ct = GetChapterProgress(ch)
            if cd == ct and ct > 0 then chapDone = chapDone + 1 end
        end
        dProgSummary:SetText(string.format(L["Progress Summary Format"], chapDone, #chapters, done, total))
        dProgSummary:ClearAllPoints()
        dProgSummary:SetPoint("TOP", dTitle, "BOTTOM", 0, -4)
        dProgSummary:Show()

        -- ── Horizontal chapter track + quest cards ────────────────────
        local GREEN_R, GREEN_G, GREEN_B = RING_GREEN_R, RING_GREEN_G, RING_GREEN_B
        local GOLD_R,  GOLD_G,  GOLD_B  = RING_GOLD_R,  RING_GOLD_G,  RING_GOLD_B
        local DIM_R, DIM_G, DIM_B = C_DIM[1], C_DIM[2], C_DIM[3]

        -- Hide old pools
        for _, node in ipairs(dTrackNodes) do node:Hide() end
        for _, arrow in ipairs(dTrackArrows) do arrow:Hide() end
        for _, card in ipairs(dQuestCards) do card:Hide() end

        -- Find the first incomplete chapter (current chapter)
        local currentChapter = #chapters
        for i, ch in ipairs(chapters) do
            local cd, ct = GetChapterProgress(ch)
            if cd < ct or ct == 0 then currentChapter = i; break end
        end
        dSelectedChapter = currentChapter
        dTrackChapterCount = #chapters

        -- Build horizontal track nodes
        local totalTrackW = #chapters * TRACK_NODE_SIZE + math.max(0, #chapters - 1) * TRACK_ARROW_GAP
        dTrackInner:SetWidth(totalTrackW)
        local lineY = math.floor(TRACK_NODE_SIZE / 2)

        for i, ch in ipairs(chapters) do
            if not dTrackNodes[i] then
                dTrackNodes[i] = CreateTrackNode(dTrackInner)
            end
            local node = dTrackNodes[i]
            local cDone, cTotal = GetChapterProgress(ch)
            local isComplete = cDone == cTotal and cTotal > 0
            local isActive = cDone > 0 and not isComplete

            -- NPC portrait
            local displayID, chapterIcon = GetChapterPortraitSource(data, ch)
            SetChapterPortrait(node.portrait, displayID, chapterIcon, ch.quests and ch.quests[1] and ch.quests[1].id)

            -- Tooltip
            node.tooltipTitle = ch.chapter
            node.tooltipBody = ch.summary or nil
            node.tooltipProgress = cDone .. " / " .. cTotal .. " quests"
            node.tooltipAchievementID = ch.achievementID or nil

            -- Status styling
            if ch.loreOnly and not isComplete then
                node.isDimmed = true
                node.portrait:SetVertexColor(0.80, 0.80, 0.80)
                node.portrait:SetDesaturation(0.4)
                node.ring:SetVertexColor((SM.Client and SM.Client.isRetail) and 0.55 or 1, (SM.Client and SM.Client.isRetail) and 0.48 or 1, (SM.Client and SM.Client.isRetail) and 0.38 or 1)
                node.ring:SetAlpha((SM.Client and SM.Client.isRetail) and 0.55 or 1.0)
                SM.SetSimpleBorder(node.portraitBorder, 0.55, 0.48, 0.38, node.hasRingAtlas and 0 or 0.55)
                node.checkmark:Hide()
            elseif isComplete then
                node.isDimmed = false
                node.portrait:SetVertexColor(1, 1, 1)
                node.portrait:SetDesaturation(0)
                node.ring:SetVertexColor((SM.Client and SM.Client.isRetail) and GREEN_R or 1, (SM.Client and SM.Client.isRetail) and GREEN_G or 1, (SM.Client and SM.Client.isRetail) and GREEN_B or 1)
                node.ring:SetAlpha((SM.Client and SM.Client.isRetail) and 0.8 or 1.0)
                SM.SetSimpleBorder(node.portraitBorder, GREEN_R, GREEN_G, GREEN_B, node.hasRingAtlas and 0 or 0.8)
                node.checkmark:Show()
            elseif isActive then
                node.isDimmed = false
                node.portrait:SetVertexColor(1, 1, 1)
                node.portrait:SetDesaturation(0)
                node.ring:SetVertexColor((SM.Client and SM.Client.isRetail) and GOLD_R or 1, (SM.Client and SM.Client.isRetail) and GOLD_G or 1, (SM.Client and SM.Client.isRetail) and GOLD_B or 1)
                node.ring:SetAlpha((SM.Client and SM.Client.isRetail) and 0.9 or 1.0)
                SM.SetSimpleBorder(node.portraitBorder, GOLD_R, GOLD_G, GOLD_B, node.hasRingAtlas and 0 or 0.9)
                node.checkmark:Hide()
            else
                node.isDimmed = true
                node.portrait:SetVertexColor(0.6, 0.6, 0.6)
                node.portrait:SetDesaturation(0.7)
                node.ring:SetVertexColor((SM.Client and SM.Client.isRetail) and 0.4 or 1, (SM.Client and SM.Client.isRetail) and 0.35 or 1, (SM.Client and SM.Client.isRetail) and 0.30 or 1)
                node.ring:SetAlpha((SM.Client and SM.Client.isRetail) and 0.5 or 1.0)
                SM.SetSimpleBorder(node.portraitBorder, 0.4, 0.35, 0.30, node.hasRingAtlas and 0 or 0.5)
                node.checkmark:Hide()
            end
            node.borderR, node.borderG, node.borderB = node.ring:GetVertexColor()
            node.borderA = node.ring:GetAlpha()

            -- Shape: gated chapters render as squares.
            -- ch.prerequisites = explicit quest gate; ch.gated = manual flag for
            -- chapters locked behind progress that can't be expressed as a quest ID.
            local CIRC = "Interface/CHARACTERFRAME/TempPortraitAlphaMask"
            local isGated = ch.prerequisites ~= nil or ch.gated == true
            node.isGated = isGated
            if isGated then
                node.portraitMask:SetTexture("Interface/Buttons/WHITE8x8")
                node.glowMask:SetTexture("Interface/Buttons/WHITE8x8")
                node.hoverGlowMask:SetTexture("Interface/Buttons/WHITE8x8")
                local r, g, b = node.ring:GetVertexColor()
                local a = node.ring:GetAlpha()
                node.ring:Hide()
                node.squareBorder:SetVertexColor(r, g, b)
                node.squareBorder:SetAlpha(a)
                node.squareBorder:Show()
                SM.SetSimpleBorder(node.portraitBorder, r, g, b, node.hasRingAtlas and 0 or a)
                node.borderR, node.borderG, node.borderB, node.borderA = r, g, b, a
            else
                node.portraitMask:SetTexture(CIRC, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                node.glowMask:SetTexture(CIRC, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                node.hoverGlowMask:SetTexture(CIRC, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                node.squareBorder:Hide()
                if node.hasRingAtlas then
                    node.ring:Show()
                else
                    node.ring:Hide()
                end
                SM.SetSimpleBorder(node.portraitBorder, node.borderR, node.borderG, node.borderB, node.hasRingAtlas and 0 or node.borderA)
            end

            -- Position
            node:ClearAllPoints()
            local x = (i - 1) * TRACK_STEP
            node:SetPoint("TOP", dTrackInner, "TOPLEFT", x + TRACK_NODE_SIZE / 2, -8)

            -- Click handler
            local idx = i
            node:SetScript("OnClick", function()
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                dSelectedChapter = idx
                StoryModeDB.selectedChapter = idx
                LayoutSelectedChapter()
                C_Timer.After(0, function() CenterTrackOnSelected(dTrackClip:GetWidth()) end)
            end)

            node:Show()

            -- Arrow between nodes (except after last)
            if i < #chapters then
                if not dTrackArrows[i] then
                    dTrackArrows[i] = dTrackInner:CreateTexture(nil, "ARTWORK")
                    SM.SetStoryArrowTexture(dTrackArrows[i], "right", false)
                    dTrackArrows[i]:SetSize(18, 18)
                end
                local arrow = dTrackArrows[i]
                arrow:ClearAllPoints()
                arrow:SetPoint("LEFT", dTrackInner, "TOPLEFT",
                    x + TRACK_NODE_SIZE + (TRACK_ARROW_GAP - 18) / 2, -(lineY + 5))

                -- Arrow color
                if isComplete then
                    arrow:SetVertexColor(GREEN_R, GREEN_G, GREEN_B, 0.6)
                else
                    arrow:SetVertexColor(DIM_R, DIM_G, DIM_B, 0.3)
                end
                arrow:Show()
            end
        end
        for i = #chapters + 1, #dTrackNodes do dTrackNodes[i]:Hide() end
        for i = #chapters, #dTrackArrows do if dTrackArrows[i] then dTrackArrows[i]:Hide() end end

        -- Position track container
        dTrackContainer:ClearAllPoints()
        dTrackContainer:SetPoint("TOP", dProgSummary, "BOTTOM", 0, -18)
        dTrackContainer:SetPoint("LEFT", detailChild, "LEFT", 0, 0)
        dTrackContainer:SetPoint("RIGHT", detailChild, "RIGHT", 0, 0)
        dTrackContainer:Show()

        -- Center track on selected chapter + apply node fading
        C_Timer.After(0, function()
            local clipW = dTrackClip:GetWidth()
            CenterTrackOnSelected(clipW)
            dTrackLeftBtn:Show()
            dTrackRightBtn:Show()
        end)

        -- Chapter title + summary below track
        dChapterTitle:ClearAllPoints()
        dChapterTitle:SetPoint("TOPLEFT", dTrackContainer, "BOTTOMLEFT", CP, -10)
        dChapterTitle:SetPoint("TOPRIGHT", dTrackContainer, "BOTTOMRIGHT", -CP, -10)

        dChapterSummary:ClearAllPoints()
        dChapterSummary:SetPoint("TOPLEFT", dChapterTitle, "BOTTOMLEFT", 0, -4)
        dChapterSummary:SetPoint("TOPRIGHT", dChapterTitle, "BOTTOMRIGHT", 0, -4)

        dChapterNote:ClearAllPoints()
        dChapterNote:SetPoint("TOPLEFT", dChapterSummary, "BOTTOMLEFT", 0, -8)
        dChapterNote:SetPoint("TOPRIGHT", dChapterSummary, "BOTTOMRIGHT", 0, -8)

        -- Render quest cards for selected chapter
        LayoutSelectedChapter()
end

local function LayoutDetailTab()
    local data = currentStoryData
    if not data then return end

    local w = detailChild:GetWidth()
    local contentW = w - CP * 2
    local visibleContentW = w - 34

    ShowTab(activeTab)
    if SM.UpdateLeftPanelForTab then
        SM.UpdateLeftPanelForTab(activeTab, data)
    end

    local divW = w - DP * 2
    if divW < 20 then divW = 400 end

    if activeTab == "story" then
        LayoutStoryTab(data, w, contentW, visibleContentW)
    elseif activeTab == "journal" then
        LayoutJournalTab(data, w, contentW, visibleContentW)
    elseif activeTab == "progress" then
        LayoutProgressTab(data, w, contentW, visibleContentW)
    end
end

-- ── Tab hover + click handlers ──────────────────────────────────────────────
tabStoryHit:SetScript("OnEnter", function()
    if activeTab ~= "story" then tabStoryLabel:SetTextColor(1, 1, 1) end
end)
tabStoryHit:SetScript("OnLeave", function()
    if activeTab ~= "story" then tabStoryLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3]) end
end)
tabStoryHit:SetScript("OnClick", function()
    if activeTab ~= "story" and currentStoryData then
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        SetActiveTab("story")
        detailScroll:SetVerticalScroll(0)
        LayoutDetailTab()
    end
end)

tabProgressHit:SetScript("OnEnter", function()
    if activeTab ~= "progress" then tabProgressLabel:SetTextColor(1, 1, 1) end
end)
tabProgressHit:SetScript("OnLeave", function()
    if activeTab ~= "progress" then tabProgressLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3]) end
end)
tabProgressHit:SetScript("OnClick", function()
    if activeTab ~= "progress" and currentStoryData then
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        SetActiveTab("progress")
        detailScroll:SetVerticalScroll(0)
        LayoutDetailTab()
    end
end)

tabJournalHit:SetScript("OnEnter", function()
    if activeTab ~= "journal" then tabJournalLabel:SetTextColor(1, 1, 1) end
end)
tabJournalHit:SetScript("OnLeave", function()
    if activeTab ~= "journal" then tabJournalLabel:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3]) end
end)
tabJournalHit:SetScript("OnClick", function()
    if activeTab ~= "journal" and currentStoryData then
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        SetActiveTab("journal")
        detailScroll:SetVerticalScroll(0)
        LayoutDetailTab()
    end
end)

-- ── Main entry point ────────────────────────────────────────────────────────
local function UpdateStoryDetail(data)
    if not data then
        currentStoryData = nil
        ShowDetail(false)
        -- Hide all tab elements
        for _, el in ipairs(storyElements) do el:Hide() end
        for _, el in ipairs(journalElements) do el:Hide() end
        for _, entry in ipairs(sJournalEntries) do entry.title:Hide(); entry.body:Hide() end
        for _, el in ipairs(progressElements) do el:Hide() end
        for _, node in ipairs(dTrackNodes) do node:Hide() end
        for _, arrow in ipairs(dTrackArrows) do arrow:Hide() end
        for _, card in ipairs(dQuestCards) do card:Hide() end
        sTrackBtn:Hide(); sCompleteText:Hide()
        dCompleteText:Hide()
        introHero:Show(); introText:Show()
        heroIcon:SetTexture(nil)
        smHeaderSub:SetText("")
        SetActiveTab("story")
        -- Hide tabs on intro page
        tabStoryLabel:Hide(); tabProgressLabel:Hide(); tabJournalLabel:Hide()
        tabStoryHit:Hide(); tabProgressHit:Hide(); tabJournalHit:Hide()
        C_Timer.After(0, function()
            local w = detailScroll:GetWidth()
            if w > 20 then
                detailChild:SetWidth(w)
                introText:SetWidth(w - CP * 2)
            end
            C_Timer.After(0, function()
                local h = introText:GetStringHeight()
                detailChild:SetHeight(math.max((h or 0) + 80, 400))
            end)
        end)
        return
    end

    currentStoryData = data
    introHero:Hide(); introText:Hide(); ShowDetail(true)
    tabStoryLabel:Show(); tabProgressLabel:Show(); tabJournalLabel:Show()
    tabStoryHit:Show(); tabProgressHit:Show(); tabJournalHit:Show()

    -- Portrait icon (creature portrait or texture)
    heroIcon:SetTexture(nil)
    if data.portraitDisplayID then
        heroIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        SetPortraitTextureFromCreatureDisplayID(heroIcon, data.portraitDisplayID)
        if not heroIcon:GetTexture() then
            local fallback = data.race and HERITAGE_ICON_BY_RACE[data.race]
            heroIcon:SetTexCoord(0.16, 0.84, 0.12, 0.88)
            if not (fallback and SM.SafeSetTexture(heroIcon, fallback)) then
                SM.SafeSetTexture(heroIcon, HERITAGE_ICON_FALLBACK)
            end
        end
    else
        local iconID
        if data.achievementID then
            local _,_,_,_,_,_,_,_,_,achIcon = GetAchievementInfo(data.achievementID)
            if achIcon and achIcon ~= 0 then iconID = achIcon end
        end
        iconID = data.icon or iconID
        if iconID and iconID ~= 0 then
            heroIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            if not SM.SafeSetTexture(heroIcon, iconID) then
                local fallback = data.race and HERITAGE_ICON_BY_RACE[data.race]
                heroIcon:SetTexCoord(0.16, 0.84, 0.12, 0.88)
                if not (fallback and SM.SafeSetTexture(heroIcon, fallback)) then
                    SM.SafeSetTexture(heroIcon, HERITAGE_ICON_FALLBACK)
                end
            end
        else
            local fallback = data.race and HERITAGE_ICON_BY_RACE[data.race]
            heroIcon:SetTexCoord(0.16, 0.84, 0.12, 0.88)
            if not (fallback and SM.SafeSetTexture(heroIcon, fallback)) then
                SM.SafeSetTexture(heroIcon, HERITAGE_ICON_FALLBACK)
            end
        end
    end

    local displayTitle = data.title
    if (not displayTitle or displayTitle == "") and data.achievementID then
        local _, achName = GetAchievementInfo(data.achievementID)
        if achName then displayTitle = achName end
    end

    smHeaderSub:SetText("")
    dTitle:SetText(displayTitle)
    SetAdventureCover(data, displayTitle)
    sIntro:SetText(data.description or "")

    -- Layout the active tab
    C_Timer.After(0, function()
        local w = detailChild:GetWidth()
        if w > 20 then sIntro:SetWidth(w - CP * 2) end
        C_Timer.After(0, function()
            LayoutDetailTab()
        end)
    end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- Left panel: category dividers + card building
-- ════════════════════════════════════════════════════════════════════════════

local storyLeftRows    = {}
local storyContentBuilt = false
local storyIndexToData = {}

-- Portrait circle sizes (Delve companion style)
local PORT = 46
local ICON = 34

local function SelectStory(index)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    storySelectedIdx = index
    StoryModeDB.selectedQuestline = index
    StoryModeDB.selectedChapter = 1  -- reset to first chapter when switching stories
    for i, row in pairs(storyLeftRows) do
        local sel = (i == index)
        if row.btn then row.btn:UnlockHighlight() end
        if row.coverTex then
            if SM.Client and SM.Client.isRetail then
                local hasCover = SetAdventureCoverTexture(row.coverTex, row.data)
                row.coverTex:SetShown(hasCover)
                row.coverTex:SetAlpha(1)
            else
                local hasCover = SetAdventureCoverTexture(row.coverTex, row.data)
                row.coverTex:SetShown(hasCover)
                row.coverTex:SetAlpha(0.72)
            end
        end
        if row.btn and row.btn.SetBackdropBorderColor then
            row.btn:SetBackdropBorderColor(0.48, 0.36, 0.18, 0.56)
        end
        row.bg:SetAlpha(1.0)
        if row.portBorder then row.portBorder:SetAlpha(sel and 1.0 or 0.5) end
        row.nameLabel:SetTextColor(1.0, 1.0, 1.0)
        if row.zoneLabel then row.zoneLabel:SetTextColor(1.0, 0.82, 0.36) end
    end
    if index == 0 or not storyIndexToData[index] then
        UpdateStoryDetail(nil)
    else
        UpdateStoryDetail(storyIndexToData[index])
    end
end

-- Category header (Trading Post style: label with thin ruled lines)
local function CreateCatDivider(parent, text, yOff)
    local CAT_H = 26
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(CAT_H)
    f:SetPoint("TOPLEFT",  parent, "TOPLEFT",  4, yOff)
    f:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, yOff)

    local lbl = NoShadow(f:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
    lbl:SetPoint("CENTER", f, "CENTER", 0, 0)
    lbl:SetJustifyH("CENTER")
    lbl:SetText(text)
    lbl:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
    f.label = lbl

    -- Thin ruled lines flanking the label (fade out toward edges)
    local lineL = f:CreateTexture(nil, "BACKGROUND")
    lineL:SetTexture(SOLID)
    lineL:SetHeight(1)
    lineL:SetPoint("LEFT",  f,   "LEFT",  6, 0)
    lineL:SetPoint("RIGHT", lbl, "LEFT", -8, 0)
    lineL:SetGradient("HORIZONTAL",
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0),
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0.5))

    local lineR = f:CreateTexture(nil, "BACKGROUND")
    lineR:SetTexture(SOLID)
    lineR:SetHeight(1)
    lineR:SetPoint("LEFT",  lbl, "RIGHT", 8, 0)
    lineR:SetPoint("RIGHT", f,   "RIGHT", -6, 0)
    lineR:SetGradient("HORIZONTAL",
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0.5),
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0))

    return CAT_H, f
end

SM.LeftContextAchievementButtons = {}
SM.LeftContextFactionCards = {}
SM.LeftContextDividers = {}
SM.LeftContextEmptyText = NoShadow(SM.LeftContextChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
SM.LeftContextEmptyText:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])
SM.LeftContextEmptyText:SetJustifyH("CENTER")
SM.LeftContextEmptyText:Hide()

function SM.HideLeftContext()
    for _, btn in ipairs(SM.LeftContextAchievementButtons) do btn:Hide() end
    for _, card in ipairs(SM.LeftContextFactionCards) do card:Hide() end
    for _, div in ipairs(SM.LeftContextDividers) do div:Hide() end
    SM.LeftContextEmptyText:Hide()
end

function SM.UseStoryLeftPanel()
    SM.HideLeftContext()
    SM.LeftContextChild:Hide()
    leftChild:Show()
    leftScroll:SetScrollChild(leftChild)
end

function SM.UseContextLeftPanel()
    leftChild:Hide()
    SM.LeftContextChild:Show()
    leftScroll:SetScrollChild(SM.LeftContextChild)
    leftScroll:SetVerticalScroll(0)
    SM.HideLeftContext()
end

function SM.GetLeftContextDivider(index, text, yOff)
    local div = SM.LeftContextDividers[index]
    if not div then
        local _
        _, div = CreateCatDivider(SM.LeftContextChild, text, yOff)
        SM.LeftContextDividers[index] = div
    end
    div:ClearAllPoints()
    div:SetPoint("TOPLEFT",  SM.LeftContextChild, "TOPLEFT",  4, yOff)
    div:SetPoint("TOPRIGHT", SM.LeftContextChild, "TOPRIGHT", -4, yOff)
    div:Show()
    if div.label then div.label:SetText(text) end
    return 26
end

function SM.CreateLeftAchievementButton(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(42, 42)
    btn:EnableMouse(true)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(34, 34)
    icon:SetPoint("CENTER")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    btn.icon = icon

    local border = btn:CreateTexture(nil, "OVERLAY", nil, 2)
    if not SM.SafeSetAtlas(border, "talents-node-square-gray", false) then
        border:Hide()
    end
    border:SetSize(42, 42)
    border:SetPoint("CENTER", icon, "CENTER", 0, 0)
    btn.border = border

    btn:SetScript("OnEnter", function(self)
        if not self.achievementID then return end
        self.border:SetVertexColor(1, 0.90, 0.60)
        local _, achName, _, completed, month, day, year, description, _, _, _, rewardText =
            GetAchievementInfo(self.achievementID)
        SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
        SMTooltip:ClearLines()
        SMTooltip:AddLine(achName or "", 1, 1, 1)
        if completed then
            local dateStr = (month and month > 0) and (" — " .. month .. "/" .. day .. "/" .. year) or ""
            SMTooltip:AddLine(L["Achievement Earned"] .. dateStr, 0.2, 0.83, 0.2)
        else
            SMTooltip:AddLine(L["Achievement Not Yet Earned"], C_DIM[1], C_DIM[2], C_DIM[3])
        end
        if description and description ~= "" then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine(description, C_BODY[1], C_BODY[2], C_BODY[3], true)
        end
        if type(rewardText) == "string" and rewardText ~= "" then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine(string.format(L["Achievement Reward Format"], rewardText), C_GOLD[1], C_GOLD[2], C_GOLD[3], true)
        end
        SMTooltip:AddLine(" ")
        SMTooltip:AddLine(L["Achievement Open Log"], 0.5, 0.5, 0.5)
        SMTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        self.border:SetVertexColor(self.borderR or C_DIM[1], self.borderG or C_DIM[2], self.borderB or C_DIM[3])
        SMTooltip:Hide()
    end)
    btn:SetScript("OnClick", function(self)
        if not self.achievementID then return end
        SMTooltip:Hide()
        storyFrame:Hide()
        if not AchievementFrame then SM.LoadAddOn("Blizzard_AchievementUI") end
        if AchievementFrame and ShowUIPanel and AchievementFrame_SelectAchievement then
            ShowUIPanel(AchievementFrame)
            AchievementFrame_SelectAchievement(self.achievementID)
        end
    end)

    return btn
end

function SM.PrepareLeftFactionCard(card)
    card.leftContext = true
    card.tileMode = true
    card:SetParent(SM.LeftContextChild)
    card.button:SetScale(1)
    card.button:ClearAllPoints()
    card.button:SetAllPoints(card)
    if card.button.Background then
        card.button.Background:ClearAllPoints()
        card.button.Background:SetAllPoints(card.button)
    end
    FactionUI:SetCardAtlas(card, FactionUI:GetCardAtlas(card, false))
    card.button.IconFrame:SetSize(58, 58)
    card.button.IconFrame:ClearAllPoints()
    card.button.IconFrame:SetPoint("TOP", card.button, "TOP", 0, -10)
    if card.button.IconFrame.Border then
        card.button.IconFrame.Border:SetSize(58, 58)
    end
    if card.button.IconFrame.IconMask then
        card.button.IconFrame.IconMask:SetAllPoints(card.icon)
    end
    if card.progress then
        card.progress:SetAllPoints(card.button.IconFrame)
    end
    if card.fullRing then
        card.fullRing:SetAllPoints(card.button.IconFrame)
    end
    card.icon:SetSize(42, 42)
    card.nameLabel:ClearAllPoints()
    card.nameLabel:SetPoint("TOP", card.button.IconFrame, "BOTTOM", 0, -4)
    card.nameLabel:SetPoint("LEFT", card, "LEFT", 8, 0)
    card.nameLabel:SetPoint("RIGHT", card, "RIGHT", -8, 0)
    card.nameLabel:SetJustifyH("CENTER")
    card.nameLabel:SetJustifyV("TOP")
    card.nameLabel:SetScale(1)
    card.nameLabel:SetMaxLines(2)
    card.nameLabel:SetWordWrap(true)
    do
        local f, _, fl = card.nameLabel:GetFont()
        if f then card.nameLabel:SetFont(f, 10, fl) end
    end
    card.statusLabel:ClearAllPoints()
    card.statusLabel:SetPoint("TOPLEFT", card.nameLabel, "BOTTOMLEFT", 0, 0)
    card.statusLabel:SetPoint("RIGHT", card.nameLabel, "RIGHT", 0, 0)
    card.statusLabel:SetJustifyH("CENTER")
    card.statusLabel:SetScale(1)
    do
        local f, _, fl = card.statusLabel:GetFont()
        if f then card.statusLabel:SetFont(f, 9, fl) end
    end
    card.statusLabel:SetMaxLines(1)
    card.statusLabel:SetWordWrap(false)
    FactionUI:LayoutLeftCardText(card)
    card.button:RegisterForClicks("LeftButtonUp")
    card.button:SetScript("OnClick", function()
        local factionID = card.factionID
        if not factionID then return end
        local isMajor = card.isMajorFaction
        SMTooltip:Hide()
        storyFrame:Hide()
        C_Timer.After(0, function()
        if isMajor and EventRegistry then
            SM.LoadAddOn("Blizzard_MajorFactions")
            EventRegistry:TriggerEvent("MajorFactionRenownMixin.MajorFactionRenownRequest", factionID)
        else
            if not CharacterFrame or not CharacterFrame:IsShown() then
                ToggleCharacter("ReputationFrame")
            elseif ReputationFrame and not ReputationFrame:IsShown() then
                ToggleCharacter("ReputationFrame")
            end
            local function findIndex()
                if not C_Reputation or not C_Reputation.GetNumFactions or not C_Reputation.GetFactionDataByIndex then
                    return nil
                end
                local n = C_Reputation.GetNumFactions()
                for i = 1, n do
                    local d = C_Reputation.GetFactionDataByIndex(i)
                    if d and d.factionID == factionID then return i end
                end
            end
            local idx = findIndex()
            if not idx and C_Reputation and C_Reputation.GetNumFactions and C_Reputation.GetFactionDataByIndex then
                local n = C_Reputation.GetNumFactions()
                for i = n, 1, -1 do
                    local d = C_Reputation.GetFactionDataByIndex(i)
                    if d and d.isHeader and d.isCollapsed and C_Reputation.ExpandFactionHeader then
                        C_Reputation.ExpandFactionHeader(i)
                    end
                end
                idx = findIndex()
            end
            if idx and C_Reputation and C_Reputation.SetSelectedFaction then
                C_Reputation.SetSelectedFaction(idx)
                if ReputationFrame and ReputationFrame.Update then ReputationFrame:Update() end
                if ReputationFrame and ReputationFrame.ScrollBox and ReputationFrame.ScrollBox.ScrollToElementDataByPredicate then
                    ReputationFrame.ScrollBox:ScrollToElementDataByPredicate(function(node)
                        local d = node and node.GetData and node:GetData()
                        return d and d.factionID == factionID
                    end, ScrollBoxConstants and ScrollBoxConstants.AlignCenter or 0.5)
                end
            end
        end
        end)
    end)
end

function SM.LayoutLeftAchievements(data)
    local yOffset = SM.LeftContextYOffset or -16
    local ids = GetStoryAchievements(data)
    if #ids == 0 then
        for _, btn in ipairs(SM.LeftContextAchievementButtons) do btn:Hide() end
        return yOffset, false
    end

    yOffset = yOffset - SM.GetLeftContextDivider(SM.LeftContextDividerIndex or 1, L["Section Achievements"], yOffset) - 8
    SM.LeftContextDividerIndex = (SM.LeftContextDividerIndex or 1) + 1

    local iconSize, cols = 42, 5
    local contentW = LEFT_W - 24
    -- Match the faction grid's effective width (4px margin on each side).
    local rowW = contentW - 8
    local gap = (cols > 1) and math.max(4, math.floor((rowW - cols * iconSize) / (cols - 1))) or 8
    local total = #ids
    for i, achID in ipairs(ids) do
        local btn = SM.LeftContextAchievementButtons[i]
        if not btn then
            btn = SM.CreateLeftAchievementButton(SM.LeftContextChild)
            SM.LeftContextAchievementButtons[i] = btn
        end
        local _, _, _, completed, _, _, _, _, _, icon = GetAchievementInfo(achID)
        btn.achievementID = achID
        btn.icon:SetTexture(icon)
        btn.icon:SetDesaturated(not completed)
        btn.borderR = completed and C_GOLD[1] or C_DIM[1]
        btn.borderG = completed and C_GOLD[2] or C_DIM[2]
        btn.borderB = completed and C_GOLD[3] or C_DIM[3]
        btn.border:SetVertexColor(btn.borderR, btn.borderG, btn.borderB)
        btn:ClearAllPoints()
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local rowStart = row * cols + 1
        local rowCount = math.min(cols, total - rowStart + 1)
        local thisRowW = rowCount * iconSize + (rowCount - 1) * gap
        local startX = math.floor((contentW - thisRowW) / 2)
        btn:SetPoint("TOPLEFT", SM.LeftContextChild, "TOPLEFT", startX + col * (iconSize + gap), yOffset - row * (iconSize + gap))
        btn:Show()
    end
    for i = #ids + 1, #SM.LeftContextAchievementButtons do
        SM.LeftContextAchievementButtons[i]:Hide()
    end

    local rows = math.ceil(#ids / cols)
    SM.LeftContextYOffset = yOffset - rows * iconSize - math.max(0, rows - 1) * gap - 14
    return SM.LeftContextYOffset, true
end

function SM.LayoutLeftFactions(data)
    local yOffset = SM.LeftContextYOffset or -16
    local factions = GetStoryFactions(data)
    if not factions or #factions == 0 then
        for _, card in ipairs(SM.LeftContextFactionCards) do card:Hide() end
        return yOffset, false
    end

    yOffset = yOffset - SM.GetLeftContextDivider(SM.LeftContextDividerIndex or 1, L["Section Factions"], yOffset) - 8
    SM.LeftContextDividerIndex = (SM.LeftContextDividerIndex or 1) + 1

    local shown = 0
    local cols, gap = 2, 4
    local contentW = LEFT_W - 24
    local tileW = math.floor((contentW - 8 - gap) / cols)
    local tileH = tileW
    for _, entry in ipairs(factions) do
        local card = SM.LeftContextFactionCards[shown + 1]
        if not card then
            card = FactionUI:Create()
            SM.LeftContextFactionCards[shown + 1] = card
        end
        card:SetSize(tileW, tileH)
        SM.PrepareLeftFactionCard(card)
        if FactionUI:Update(card, entry, data) then
            local col = shown % cols
            local row = math.floor(shown / cols)
            shown = shown + 1
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", SM.LeftContextChild, "TOPLEFT", 4 + col * (tileW + gap), yOffset - row * (tileH + gap))
        end
    end
    for i = shown + 1, #SM.LeftContextFactionCards do
        SM.LeftContextFactionCards[i]:Hide()
    end

    if shown == 0 then
        local div = SM.LeftContextDividers[(SM.LeftContextDividerIndex or 2) - 1]
        if div then div:Hide() end
        SM.LeftContextDividerIndex = math.max(1, (SM.LeftContextDividerIndex or 2) - 1)
        return SM.LeftContextYOffset or yOffset, false
    end
    if shown > 0 then
        local rows = math.ceil(shown / cols)
        yOffset = yOffset - rows * tileH - math.max(0, rows - 1) * gap
    end
    SM.LeftContextYOffset = yOffset
    return SM.LeftContextYOffset, true
end

function SM.LayoutLeftProgressJournal(data)
    SM.UseContextLeftPanel()
    SM.LeftContextYOffset = -16
    SM.LeftContextDividerIndex = 1
    local _, hasAchievements = SM.LayoutLeftAchievements(data)
    local _, hasFactions = SM.LayoutLeftFactions(data)
    if not hasAchievements and not hasFactions then
        SM.UseStoryLeftPanel()
        return
    end
    SM.LeftContextChild:SetHeight(math.max(math.abs(SM.LeftContextYOffset or -16) + 16, 180))
end

SM.UpdateLeftPanelForTab = function(tab, data)
    if not data or tab == "story" then
        SM.UseStoryLeftPanel()
    elseif tab == "progress" or tab == "journal" then
        SM.LayoutLeftProgressJournal(data)
    else
        SM.UseStoryLeftPanel()
    end
end

local function BuildStoryWindow()
    if storyContentBuilt then return end
    storyContentBuilt = true
    for _, data in ipairs(allQuestlines) do ResolveAchievementID(data) end
    wipe(storyIndexToData)

    local CARD_H   = (SM.Client and SM.Client.isRetail) and 78 or 70
    local CARD_PAD = 4
    local yOffset  = -16
    local globalIdx = 0

    -- ── Introduction card (index 0 = show intro text on right) ───────────
    local playerName = UnitName("player")
    local introDivH = CreateCatDivider(leftChild, playerName and string.format(L["Greeting Format"], playerName) or L["Greeting Fallback"], yOffset)
    yOffset = yOffset - introDivH - 4

    local introCard = CreateFrame("Button", nil, leftChild, (SM.Client and SM.Client.isRetail) and nil or "BackdropTemplate")
    introCard:SetHeight(CARD_H)
    introCard:SetPoint("TOPLEFT",  leftChild, "TOPLEFT",  CARD_PAD, yOffset)
    introCard:SetPoint("TOPRIGHT", leftChild, "TOPRIGHT", -CARD_PAD, yOffset)
    introCard:RegisterForClicks("AnyUp")
    if not (SM.Client and SM.Client.isRetail) then
        SM.ApplyClassicCardBackdrop(introCard, 0, 0.50)
    end
    local introBg = introCard:CreateTexture(nil, "BACKGROUND")
    if SM.Client and SM.Client.isRetail then
        introBg:SetAtlas("housefinder_neighborhood-list-item-default", false)
        introBg:SetAllPoints()
    else
        SM.ClearCardFillTexture(introBg)
    end
    if not (SM.Client and SM.Client.isRetail) then
        introCard.shade = SM.CreateInsetCardShade(introCard, 0.38)
    end

    if SM.Client and SM.Client.isRetail then
        introCard:SetHighlightAtlas("housefinder_neighborhood-list-item-highlight")
        introCard:GetHighlightTexture():SetAllPoints()
    else
        SM.SetSubtleCardHover(introCard)
    end

    local introPort = CreateFrame("Frame", nil, introCard)
    introPort:SetSize(PORT, PORT)
    introPort:SetPoint("LEFT", introCard, "LEFT", 16, 0)

    local introIcon = introPort:CreateTexture(nil, "ARTWORK")
    introIcon:SetSize(ICON, ICON)
    introIcon:SetPoint("CENTER")
    introIcon:SetTexture(STORYMODE_ICON_TEXTURE)

    local introIconMask = introPort:CreateMaskTexture()
    introIconMask:SetTexture(
        "Interface/CHARACTERFRAME/TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    introIconMask:SetAllPoints(introIcon)
    introIcon:AddMaskTexture(introIconMask)

    local introName = NoShadow(introCard:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
    introName:SetPoint("LEFT",  introIcon, "RIGHT", 8, 0)
    introName:SetPoint("RIGHT", introCard, "RIGHT", -8, 0)
    introName:SetJustifyH("LEFT"); introName:SetJustifyV("MIDDLE")
    introName:SetMaxLines(1); introName:SetWordWrap(false)
    introName:SetText(L["Addon Name"])
    introName:SetTextColor(1.0, 1.0, 1.0)

    local introZone = nil  -- no subline

    introCard:SetScript("OnClick", function() SelectStory(0) end)

    -- Store intro card for select styling
    storyLeftRows[0] = {
        btn       = introCard,
        bg        = introBg,
        nameLabel = introName,
        zoneLabel = introZone,
    }

    yOffset = yOffset - CARD_H - 4

    -- ── Questline cards ──────────────────────────────────────────────────
    for _, cat in ipairs(categories) do
        if cat.disabled then
            local divH = CreateCatDivider(leftChild, cat.displayName or cat.name, yOffset)
            yOffset = yOffset - divH - 12
        elseif #cat.questlines > 0 then
            local divH = CreateCatDivider(leftChild, cat.displayName or cat.name, yOffset)
            yOffset = yOffset - divH - 4
            for _, data in ipairs(cat.questlines) do
                globalIdx = globalIdx + 1
                local idx = globalIdx
                storyIndexToData[idx] = data
                local cr, cg, cb = unpack(data.color or {0.5, 0.3, 0.9})

                -- ── Card frame ────────────────────────────────────────────────
                local card = CreateFrame("Button", nil, leftChild, (SM.Client and SM.Client.isRetail) and nil or "BackdropTemplate")
                card:SetHeight(CARD_H)
                card:SetPoint("TOPLEFT",  leftChild, "TOPLEFT",  CARD_PAD, yOffset)
                card:SetPoint("TOPRIGHT", leftChild, "TOPRIGHT", -CARD_PAD, yOffset)
                card:RegisterForClicks("AnyUp")
                if not (SM.Client and SM.Client.isRetail) then
                    SM.ApplyClassicCardBackdrop(card, 0, 0.50)
                end
                -- House Finder card background
                local bg = card:CreateTexture(nil, "BACKGROUND", nil, 2)
                if SM.Client and SM.Client.isRetail then
                    bg:SetAtlas("housefinder_neighborhood-list-item-default", false)
                    bg:SetAllPoints()
                else
                    SM.ClearCardFillTexture(bg)
                end
                if not (SM.Client and SM.Client.isRetail) then
                    card.shade = SM.CreateInsetCardShade(card, 0.38, 4)
                end

                local coverTex = card:CreateTexture(nil, "BACKGROUND", nil, (SM.Client and SM.Client.isRetail) and 0 or 2)
                if SM.Client and SM.Client.isRetail then
                    coverTex:SetPoint("TOPLEFT", card, "TOPLEFT", 7, -7)
                    coverTex:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -7, 7)
                    coverTex:SetAlpha(0.78)
                    coverTex:Hide()
                else
                    coverTex:SetPoint("TOPLEFT", card, "TOPLEFT", 3, -3)
                    coverTex:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -3, 3)
                    coverTex:SetAlpha(0.72)
                    coverTex:SetShown(SetAdventureCoverTexture(coverTex, data))
                end

                if SM.Client and SM.Client.isRetail then
                    card:SetHighlightAtlas("housefinder_neighborhood-list-item-highlight")
                    card:GetHighlightTexture():SetAllPoints()
                else
                    SM.SetSubtleCardHover(card)
                end

                -- ── Portrait circle ───────────────────────────────────────────
                local portFrame = CreateFrame("Frame", nil, card)
                portFrame:SetSize(PORT, PORT)
                portFrame:SetPoint("LEFT", card, "LEFT", 16, 0)

                local iconTex = portFrame:CreateTexture(nil, "ARTWORK")
                iconTex:SetSize(ICON, ICON)
                iconTex:SetPoint("CENTER", portFrame, "CENTER", 0, 0)
                iconTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                iconTex:SetTexelSnappingBias(0)
                iconTex:SetSnapToPixelGrid(false)

                local iconMask = portFrame:CreateMaskTexture()
                iconMask:SetTexture(
                    "Interface/CHARACTERFRAME/TempPortraitAlphaMask",
                    "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                iconMask:SetAllPoints(iconTex)
                iconTex:AddMaskTexture(iconMask)

                if data.portraitDisplayID then
                    SetPortraitTextureFromCreatureDisplayID(iconTex, data.portraitDisplayID)
                    if not iconTex:GetTexture() then
                        if data.achievementID then
                            local _,_,_,_,_,_,_,_,_,achIcon = GetAchievementInfo(data.achievementID)
                            if achIcon and achIcon ~= 0 then
                                iconTex:SetTexture(achIcon)
                            end
                        end
                        if not iconTex:GetTexture() and data.icon then
                            SM.SafeSetTexture(iconTex, data.icon)
                        end
                        if not iconTex:GetTexture() and data.race and not data.class then
                            local heritageIcon = HERITAGE_ICON_BY_RACE[data.race]
                            if not (heritageIcon and SM.SafeSetTexture(iconTex, heritageIcon)) then
                                if data.race == "Pandaren" then
                                    SM.SafeSetTexture(iconTex, PANDAREN_TABARD_ICON)
                                else
                                    SM.SafeSetTexture(iconTex, HERITAGE_ICON_FALLBACK)
                                end
                            end
                        end
                    end
                elseif data.race and not data.class and data.icon then
                    -- Heritage cards should reflect the configured questline card icon.
                    if not SM.SafeSetTexture(iconTex, data.icon) then
                        local heritageIcon = HERITAGE_ICON_BY_RACE[data.race]
                        if not (heritageIcon and SM.SafeSetTexture(iconTex, heritageIcon)) then
                            if data.race == "Pandaren" then
                                SM.SafeSetTexture(iconTex, PANDAREN_TABARD_ICON)
                            else
                                SM.SafeSetTexture(iconTex, HERITAGE_ICON_FALLBACK)
                            end
                        end
                    end
                elseif data.achievementID and not data.icon then
                    local _,_,_,_,_,_,_,_,_,achIcon = GetAchievementInfo(data.achievementID)
                    if achIcon and achIcon ~= 0 then iconTex:SetTexture(achIcon) end
                elseif data.icon then
                    if not SM.SafeSetTexture(iconTex, data.icon) then
                        if data.race == "Pandaren" then
                            SM.SafeSetTexture(iconTex, PANDAREN_TABARD_ICON)
                        else
                            SM.SafeSetTexture(iconTex, HERITAGE_ICON_FALLBACK)
                        end
                    end
                elseif data.race and not data.class then
                    -- Heritage cards: fallback to cloak/tabard style imagery.
                    local heritageIcon = HERITAGE_ICON_BY_RACE[data.race]
                    if not (heritageIcon and SM.SafeSetTexture(iconTex, heritageIcon)) then
                        if data.race == "Pandaren" then
                            SM.SafeSetTexture(iconTex, PANDAREN_TABARD_ICON)
                        else
                            SM.SafeSetTexture(iconTex, HERITAGE_ICON_FALLBACK)
                        end
                    end
                end
                if not iconTex:GetTexture() and data.race and not data.class then
                    local heritageIcon = HERITAGE_ICON_BY_RACE[data.race]
                    if not (heritageIcon and SM.SafeSetTexture(iconTex, heritageIcon)) then
                        if data.race == "Pandaren" then
                            SM.SafeSetTexture(iconTex, PANDAREN_TABARD_ICON)
                        else
                            SM.SafeSetTexture(iconTex, HERITAGE_ICON_FALLBACK)
                        end
                    end
                end

                -- Gold circle border around the portrait
                local portBorder = portFrame:CreateTexture(nil, "OVERLAY")
                if not SM.SafeSetAtlas(portBorder, "ui-frame-genericplayerchoice-portrait-border", false) then
                    portBorder:Hide()
                end
                portBorder:SetPoint("TOPLEFT",     iconTex, "TOPLEFT",     -3,  3)
                portBorder:SetPoint("BOTTOMRIGHT", iconTex, "BOTTOMRIGHT",  3, -3)
                portBorder:SetVertexColor(1.0, 0.82, 0.5)
                portBorder:SetAlpha(0.85)
                portFrame:Hide()

                -- ── Text labels (vertically centred on card) ──────────────────
                local nameLabel = NoShadow(card:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
                nameLabel:SetPoint("LEFT",   card,      "LEFT",  24,  0)
                nameLabel:SetPoint("RIGHT",  card,      "RIGHT", -42,  0)
                nameLabel:SetPoint("BOTTOM", card,      "CENTER", 0,  1)
                nameLabel:SetJustifyH("LEFT"); nameLabel:SetJustifyV("BOTTOM")
                nameLabel:SetMaxLines(1); nameLabel:SetWordWrap(false)
                nameLabel:SetText(data.title)
                nameLabel:SetTextColor(1.0, 1.0, 1.0)

                local zoneLabel = NoShadow(card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
                zoneLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -2)
                zoneLabel:SetPoint("RIGHT",   card,      "RIGHT",     -42,  0)
                zoneLabel:SetJustifyH("LEFT")
                local zoneText = data.zone or ""
                local parts = {}
                for part in zoneText:gmatch("[^/]+") do
                    parts[#parts + 1] = part:match("^%s*(.-)%s*$")
                end
                if not (SM.Client and SM.Client.isRetail) and #parts > 1 then
                    zoneText = parts[1]
                elseif #parts > 2 then
                    zoneText = parts[1] .. " / " .. parts[2] .. "…"
                end
                zoneLabel:SetText(zoneText)
                zoneLabel:SetTextColor(1.0, 0.82, 0.36)

                -- ── Completion checkmark ──────────────────────────────────────
                local cardCheckmark = CreateCompletionRibbon(card)
                if SM.Client and SM.Client.isRetail then
                    cardCheckmark:SetPoint("TOPRIGHT", card, "TOPRIGHT", -15, -1)
                else
                    cardCheckmark:SetPoint("RIGHT", card, "RIGHT", -18, 0)
                end
                local cdone, ctotal = GetCampaignProgress(data)
                if cdone == ctotal and ctotal > 0 then
                    cardCheckmark:Show()
                else
                    cardCheckmark:Hide()
                end

                -- ── Click ──────────────────────────────────────────────────────
                card:SetScript("OnClick", function() SelectStory(idx) end)

                storyLeftRows[idx] = {
                    btn       = card,
                    bg        = bg,
                    coverTex  = coverTex,
                    data      = data,
                    portBorder= portBorder,
                    nameLabel = nameLabel,
                    zoneLabel = zoneLabel,
                    checkmark = cardCheckmark,
                }
                yOffset = yOffset - CARD_H - 5
            end
            yOffset = yOffset - 8
        end
    end
    leftChild:SetHeight(math.abs(yOffset) + 16)
end

storyFrame:SetScript("OnShow", function()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    BuildStoryWindow()
    -- Frame 1: let layout settle so detailScroll has a real width
    C_Timer.After(0, function()
        local w = detailScroll:GetWidth()
        if w > 20 then detailChild:SetWidth(w) end
        -- Frame 2: now word-wrap can measure properly
        C_Timer.After(0, function()
            -- Restore last selected questline, or default to intro
            local savedIdx = StoryModeDB.selectedQuestline or 0
            -- Validate saved index exists
            if savedIdx > 0 and storyIndexToData[savedIdx] then
                SelectStory(savedIdx)
            else
                SelectStory(0)  -- default to Introduction card
            end
        end)
    end)
end)

storyFrame:SetScript("OnHide", function()
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
end)


local ShowStoryBanner   -- forward declaration (defined in Banner section below)
local ShowStoryComplete -- forward declaration (defined in Banner section below)

local function ToggleStoryModeFrame()
    if InCombatLockdown() then
        UIErrorsFrame:AddMessage(L["Error In Combat"], 1, 0.1, 0.1)
        return
    end

    C_Timer.After(0, function()
        if storyFrame:IsShown() then
            storyFrame:Hide()
        else
            storyFrame:Show()
        end
    end)
end

function StoryMode_AddonCompartment_OnClick(_, button)
    if button and button ~= "LeftButton" then return end
    ToggleStoryModeFrame()
end

function StoryMode_AddonCompartment_OnEnter(nameOrButton, maybeButton)
    local menuButton = maybeButton or nameOrButton
    if not menuButton or not menuButton.GetObjectType then return end

    SMTooltip:SetOwner(menuButton, "ANCHOR_LEFT")
    SMTooltip:ClearLines()
    SMTooltip:AddLine(L["Minimap Tooltip Title"], 1, 1, 1)
    SMTooltip:AddLine(L["Minimap Tooltip Open"], C_BODY[1], C_BODY[2], C_BODY[3])
    SMTooltip._minW = 0
    SMTooltip:Show()
end

function StoryMode_AddonCompartment_OnLeave()
    SMTooltip:Hide()
end

SLASH_STORYMODE1 = "/sm"
SLASH_STORYMODE2 = "/storymode"
SlashCmdList["STORYMODE"] = function(msg)
    msg = msg and msg:trim():lower() or ""
    if msg == "banner" then
        local data = allQuestlines[1]
        if data then
            ShowStoryBanner(data.title, L["Slash Test Quest Name"], data, nil, true)
        else
            print(L["Addon Legacy Prefix"] .. L["Slash No Questline Data"])
        end
        return
    elseif msg == "chapter" then
        local data = allQuestlines[1]
        if data then
            local ch = GetAllChapters(data)[1]
            ShowStoryBanner(L["Banner Chapter Complete"], ch and ch.chapter or data.title, data, nil, true)
        else
            print(L["Addon Legacy Prefix"] .. L["Slash No Questline Data"])
        end
        return
    elseif msg == "complete" then
        local data = allQuestlines[1]
        if data then
            ShowStoryComplete(data.title)
        else
            print(L["Addon Legacy Prefix"] .. L["Slash No Questline Data"])
        end
        return
    elseif msg == "track" or msg == "next" then
        -- Slash commands always execute in an insecure Lua context, so the
        -- waypoint calls below will taint the quest-reward path. Prefer the
        -- in-UI "Continue Story" button, which routes through the secure
        -- macro dispatch and avoids taint.
        for _, data in ipairs(allQuestlines) do
            local quest, chapter = FindNextQuest(data)
            if quest then
                local result = SetWaypointForQuest(data, quest)
                local cr, cg, cb = unpack(data.color or { 1, 0.82, 0 })
                local hex = HexColor(cr, cg, cb)
                print(L["Addon Legacy Prefix"] .. "|cff" .. hex .. data.title .. " — " .. chapter .. "|r")
                PrintTrackResult(result, quest, data)
                return
            end
        end
        print(L["Addon Legacy Prefix"] .. L["Slash All Complete"])
    elseif msg:match("^debug") then
        local filter = msg:match("^debug%s+(.+)$")
        local found = false
        for _, data in ipairs(allQuestlines) do
            if not filter or data.title:lower():find(filter, 1, true) then
                found = true
                print(L["Addon Debug Prefix"] .. data.title)
                local chapters = GetAllChapters(data)
                for _, ch in ipairs(chapters) do
                    if ch.quests then
                        local chDone, chTotal = GetChapterProgress(ch)
                        print(string.format("  |cffaaaaaa[%s]|r %d/%d", ch.chapter or "?", chDone, chTotal))
                        for j, q in ipairs(ch.quests) do
                            local inLog = IsQuestInLog(q.id)
                            local flagged = SM.IsQuestFlaggedCompleted(q.id)
                            local effective = IsQuestEffectivelyComplete(j, ch.quests)
                            local tag = inLog and "|cff00ff00[IN LOG]|r"
                                or (flagged and "|cffaaaaaa[done]|r")
                                or (effective and "|cffff8800[eff-done]|r")
                                or "|cffff4444[incomplete]|r"
                            print(string.format("    %s %d %s", tag, q.id, q.name or "?"))
                        end
                    end
                end
            end
        end
        if not found then
            print(L["Addon Legacy Prefix"] .. string.format(L["Slash No Match Format"], filter or ""))
        end
    else
        ToggleStoryModeFrame()
    end
end

SM.MinimapButton_Init = SM.CreateMinimapButton(storyFrame, SMTooltip, C_BODY)
ShowStoryBanner, ShowStoryComplete = SM.CreateBanners()

-- ============================================================================
-- Quest Completion Tracking — detect chapter and storyline completion
-- ============================================================================

local chapterCompletionCache  = {}  -- [questlineTitle|chapterName] = true
local storylineCompletionCache = {}  -- [questlineTitle] = true

local function CheckQuestCompletion(completedQuestID)
    for _, data in ipairs(allQuestlines) do
        for _, ch in ipairs(GetAllChapters(data)) do
            local questName, questNpc
            for _, q in ipairs(ch.quests) do
                if q.id == completedQuestID then
                    questName = q.name
                    questNpc = q.npc
                    break
                end
            end
            if questName then
                -- Delay so IsQuestFlaggedCompleted is reliable before we check progress
                C_Timer.After(0.1, function()
                    if storyFrame:IsShown() and currentStoryData == data then
                        UpdateStoryDetail(data)
                    end

                    local done, total = GetChapterProgress(ch)
                    local isChapterDone = done >= total and total > 0
                    local key = (data.title or "") .. "|" .. (ch.chapter or "")

                    if isChapterDone and not chapterCompletionCache[key] then
                        chapterCompletionCache[key] = true

                        local storyKey = data.title or ""
                        local allDone = true
                        for _, c in ipairs(GetAllChapters(data)) do
                            local d, t = GetChapterProgress(c)
                            -- t == 0 means loreOnly/achievement chapter with no quests — skip it
                            if t > 0 and d < t then allDone = false; break end
                        end

                        if allDone then
                            -- Update the story card checkmark on the left panel
                            for idx, row in pairs(storyLeftRows) do
                                if storyIndexToData[idx] == data then
                                    row.checkmark:Show()
                                    break
                                end
                            end
                        end

                        C_Timer.After(1.5, function()
                            ShowStoryBanner(L["Banner Chapter Complete"], ch.chapter, data, questNpc, true)
                        end)

                        if allDone and not storylineCompletionCache[storyKey] then
                            storylineCompletionCache[storyKey] = true
                            C_Timer.After(6.5, function()
                                ShowStoryComplete(data.title)
                            end)
                        end
                    else
                        C_Timer.After(1.0, function()
                            ShowStoryBanner(data.title, questName, data, questNpc, true)
                        end)
                    end
                end)
                break
            end
        end
    end
end

-- ============================================================================
-- Initialization
-- ============================================================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("QUEST_TURNED_IN")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_REGEN_DISABLED" then
        if storyFrame:IsShown() then storyFrame:Hide() end
        return
    end
    if event == "ADDON_LOADED" and arg1 == addonName then
        SM.ApplySavedVariableDefaults()
        SM.MinimapButton_Init()
        -- Pre-populate caches so already-completed chapters/storylines don't re-fire
        for _, data in ipairs(allQuestlines) do
            local allDone = true
            for _, ch in ipairs(GetAllChapters(data)) do
                local d, t = GetChapterProgress(ch)
                if d >= t and t > 0 then
                    chapterCompletionCache[(data.title or "") .. "|" .. (ch.chapter or "")] = true
                else
                    allDone = false
                end
            end
            if allDone then
                storylineCompletionCache[data.title or ""] = true
            end
        end
    elseif event == "QUEST_TURNED_IN" then
        CheckQuestCompletion(arg1)
    end
end)
