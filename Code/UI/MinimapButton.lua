local addonName, SM = ...
local L = SM.L

local STORYMODE_ICON_TEXTURE = "Interface\\AddOns\\StoryMode\\Art\\Icons\\storymode_icon"
local STORYMODE_ICON_GLOW_TEXTURE = "Interface\\AddOns\\StoryMode\\Art\\Icons\\storymode_icon_glow"
local STORYMODE_AVATAR_TEXTURE = "Interface\\AddOns\\StoryMode\\Art\\Icons\\storymode_avatar"
local MINIMAP_STYLE_BORDERLESS = "borderless"
local MINIMAP_STYLE_DEFAULT_BORDER = "defaultBorder"

local function GetMinimapIconStyle()
    if not StoryModeDB or StoryModeDB.minimapIconStyle ~= MINIMAP_STYLE_DEFAULT_BORDER then
        return MINIMAP_STYLE_BORDERLESS
    end
    return MINIMAP_STYLE_DEFAULT_BORDER
end

function SM.CreateMinimapButton(storyFrame, tooltip, bodyColor)
    local minimapBtn = CreateFrame("Button", nil, Minimap)
    local borderlessButtonSize = (SM.IsRetailClient()) and 42 or 38
    local borderlessIconSize = (SM.IsRetailClient()) and 36 or 32
    local defaultButtonSize = (SM.IsRetailClient()) and 32 or 30
    local defaultIconSize = (SM.IsRetailClient()) and 25 or 22
    local defaultBorderSize = (SM.IsRetailClient()) and 50 or 53
    local defaultIconOffsetX = (SM.IsRetailClient()) and 0 or 1
    local edgeOffset = (SM.IsRetailClient()) and 8 or 5
    minimapBtn:SetSize(borderlessButtonSize, borderlessButtonSize)
    minimapBtn:SetFrameStrata("MEDIUM")
    minimapBtn:SetFrameLevel(9)
    minimapBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local minimapIcon = minimapBtn:CreateTexture(nil, "ARTWORK", nil, 2)
    minimapIcon:SetSize(borderlessIconSize, borderlessIconSize)
    minimapIcon:SetPoint("CENTER", 0, (SM.IsRetailClient()) and 2 or 1)
    minimapIcon:SetTexture(STORYMODE_ICON_TEXTURE)

    local minimapMask = minimapBtn:CreateMaskTexture()
    minimapMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    minimapMask:SetAllPoints(minimapIcon)
    minimapIcon:AddMaskTexture(minimapMask)

    local minimapIconGlow = minimapBtn:CreateTexture(nil, "OVERLAY", nil, 4)
    minimapIconGlow:SetTexture(STORYMODE_ICON_GLOW_TEXTURE)
    minimapIconGlow:SetTexCoord(0, 1, 0, 1)
    minimapIconGlow:Hide()

    local defaultBorder = minimapBtn:CreateTexture(nil, "OVERLAY", nil, 3)
    defaultBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    local isHoveringMinimapButton = false
    local function UpdateIconGlow()
        minimapIconGlow:SetShown(isHoveringMinimapButton and GetMinimapIconStyle() == MINIMAP_STYLE_BORDERLESS)
    end

    local function ApplyIconStyle()
        minimapIcon:ClearAllPoints()
        minimapIconGlow:ClearAllPoints()
        defaultBorder:ClearAllPoints()

        if GetMinimapIconStyle() == MINIMAP_STYLE_DEFAULT_BORDER then
            minimapBtn:SetSize(defaultButtonSize, defaultButtonSize)
            minimapIcon:SetSize(defaultIconSize, defaultIconSize)
            minimapIcon:SetPoint("CENTER", minimapBtn, "CENTER", defaultIconOffsetX, 0)
            minimapIcon:SetTexture(STORYMODE_AVATAR_TEXTURE)
            minimapIconGlow:Hide()
            defaultBorder:SetSize(defaultBorderSize, defaultBorderSize)
            defaultBorder:SetPoint("TOPLEFT", minimapBtn, "TOPLEFT", 0, 0)
            defaultBorder:Show()
        else
            minimapBtn:SetSize(borderlessButtonSize, borderlessButtonSize)
            minimapIcon:SetSize(borderlessIconSize, borderlessIconSize)
            minimapIcon:SetPoint("CENTER", minimapBtn, "CENTER", 0, (SM.IsRetailClient()) and 2 or 1)
            minimapIcon:SetTexture(STORYMODE_ICON_TEXTURE)
            minimapIconGlow:SetSize(borderlessButtonSize, borderlessButtonSize)
            minimapIconGlow:SetPoint("CENTER", minimapBtn, "CENTER", 0, (SM.IsRetailClient()) and 2 or 1)
            defaultBorder:Hide()
        end
        UpdateIconGlow()
    end

    local minimapMenuFrame
    local function SetIconStyle(style)
        if StoryModeDB then StoryModeDB.minimapIconStyle = style end
        ApplyIconStyle()
    end

    local function ShowIconStyleMenu(owner)
        tooltip:Hide()

        if MenuUtil and MenuUtil.CreateContextMenu then
            MenuUtil.CreateContextMenu(owner, function(_, rootDescription)
                rootDescription:CreateTitle(L["Minimap Icon Style"])
                rootDescription:CreateRadio(
                    L["Minimap Icon Style Borderless"],
                    function() return GetMinimapIconStyle() == MINIMAP_STYLE_BORDERLESS end,
                    function() SetIconStyle(MINIMAP_STYLE_BORDERLESS) end
                )
                rootDescription:CreateRadio(
                    L["Minimap Icon Style Default"],
                    function() return GetMinimapIconStyle() == MINIMAP_STYLE_DEFAULT_BORDER end,
                    function() SetIconStyle(MINIMAP_STYLE_DEFAULT_BORDER) end
                )
            end)
            return
        end

        if EasyMenu then
            if not minimapMenuFrame then
                minimapMenuFrame = CreateFrame("Frame", "StoryModeMinimapIconStyleMenu", UIParent, "UIDropDownMenuTemplate")
            end
            EasyMenu({
                {
                    text = L["Minimap Icon Style"],
                    isTitle = true,
                    notCheckable = true,
                },
                {
                    text = L["Minimap Icon Style Borderless"],
                    checked = function() return GetMinimapIconStyle() == MINIMAP_STYLE_BORDERLESS end,
                    func = function() SetIconStyle(MINIMAP_STYLE_BORDERLESS) end,
                },
                {
                    text = L["Minimap Icon Style Default"],
                    checked = function() return GetMinimapIconStyle() == MINIMAP_STYLE_DEFAULT_BORDER end,
                    func = function() SetIconStyle(MINIMAP_STYLE_DEFAULT_BORDER) end,
                },
            }, minimapMenuFrame, "cursor", 0, 0, "MENU")
        end
    end

    local function UpdatePosition(angle)
        local r = (Minimap:GetWidth() / 2) + edgeOffset  -- sit on the edge
        local x = math.cos(angle) * r
        local y = math.sin(angle) * r
        minimapBtn:ClearAllPoints()
        minimapBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end

    minimapBtn:RegisterForDrag("LeftButton")
    minimapBtn:SetScript("OnDragStart", function(self)
        self.dragging = true
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            cx, cy = cx / scale, cy / scale
            local angle = math.atan2(cy - my, cx - mx)
            UpdatePosition(angle)
            StoryModeDB.minimapAngle = angle
        end)
    end)
    minimapBtn:SetScript("OnDragStop", function(self)
        self.dragging = false
        self:SetScript("OnUpdate", nil)
    end)

    minimapBtn:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            ShowIconStyleMenu(self)
            return
        end

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
    end)

    minimapBtn:SetScript("OnEnter", function(self)
        isHoveringMinimapButton = true
        UpdateIconGlow()
        tooltip:SetOwner(self, "ANCHOR_LEFT")
        tooltip:ClearLines()
        tooltip:AddLine(L["Minimap Tooltip Title"])
        tooltip:AddLine(L["Minimap Tooltip Open"])
        tooltip:AddLine(L["Minimap Tooltip Settings"])
        tooltip._minW = 0
        tooltip:Show()
    end)
    minimapBtn:SetScript("OnLeave", function()
        isHoveringMinimapButton = false
        UpdateIconGlow()
        tooltip:Hide()
    end)

    -- Idle hide: invisible until cursor is near the minimap.
    minimapBtn:SetAlpha(0)
    local mmFadeIn = minimapBtn:CreateAnimationGroup()
    local mmFiAlpha = mmFadeIn:CreateAnimation("Alpha")
    mmFiAlpha:SetFromAlpha(0); mmFiAlpha:SetToAlpha(1); mmFiAlpha:SetDuration(0.25); mmFiAlpha:SetSmoothing("OUT")
    mmFadeIn:SetScript("OnFinished", function() minimapBtn:SetAlpha(1) end)

    local mmFadeOut = minimapBtn:CreateAnimationGroup()
    local mmFoAlpha = mmFadeOut:CreateAnimation("Alpha")
    mmFoAlpha:SetFromAlpha(1); mmFoAlpha:SetToAlpha(0); mmFoAlpha:SetDuration(0.4); mmFoAlpha:SetSmoothing("IN")
    mmFadeOut:SetScript("OnFinished", function() minimapBtn:SetAlpha(0) end)

    local mmProximity = CreateFrame("Frame", nil, Minimap)
    mmProximity:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -30, 30)
    mmProximity:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 30, -30)
    mmProximity.isNear = false
    mmProximity:SetScript("OnUpdate", function(self)
        local cx, cy = GetCursorPosition()
        local scale = self:GetEffectiveScale()
        cx, cy = cx / scale, cy / scale
        local l, b, w, h = self:GetRect()
        local inside = cx >= l and cx <= l + w and cy >= b and cy <= b + h
        if inside and not self.isNear then
            self.isNear = true
            if self.fadeTimer then self.fadeTimer:Cancel(); self.fadeTimer = nil end
            mmFadeOut:Stop()
            mmFadeIn:Play()
        elseif not inside and self.isNear then
            self.isNear = false
            mmFadeIn:Stop()
            if not self.fadeTimer then
                self.fadeTimer = C_Timer.NewTimer(1.0, function()
                    mmProximity.fadeTimer = nil
                    if not mmProximity.isNear then mmFadeOut:Play() end
                end)
            end
        end
    end)

    return function()
        ApplyIconStyle()
        local angle = StoryModeDB and StoryModeDB.minimapAngle or 4.4  -- default: bottom
        UpdatePosition(angle)
    end
end
