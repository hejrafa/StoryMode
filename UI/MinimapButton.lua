local addonName, SM = ...

function SM.CreateMinimapButton(storyFrame, tooltip, bodyColor)
    local minimapBtn = CreateFrame("Button", nil, Minimap)
    minimapBtn:SetSize(42, 42)
    minimapBtn:SetFrameStrata("MEDIUM")
    minimapBtn:SetFrameLevel(9)

    -- Soft shadow (multiple offset copies for fake blur)
    for _, s in ipairs({{0.5, -0.5, 0.25}, {-0.5, -0.5, 0.15}, {0, -1, 0.3}, {1, 0, 0.15}}) do
        local sh = minimapBtn:CreateTexture(nil, "ARTWORK", nil, 1)
        sh:SetSize(38, 38)
        sh:SetPoint("CENTER", s[1], s[2])
        sh:SetAtlas("majorfactions_icons_flame512", false)
        sh:SetVertexColor(0, 0, 0)
        sh:SetAlpha(s[3])
    end

    local minimapIcon = minimapBtn:CreateTexture(nil, "ARTWORK", nil, 2)
    minimapIcon:SetSize(36, 36)
    minimapIcon:SetPoint("CENTER", 0, 2)
    minimapIcon:SetAtlas("majorfactions_icons_flame512", false)

    local minimapMask = minimapBtn:CreateMaskTexture()
    minimapMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    minimapMask:SetAllPoints(minimapIcon)
    minimapIcon:AddMaskTexture(minimapMask)

    local function UpdatePosition(angle)
        local r = (Minimap:GetWidth() / 2) + 8  -- sit on the edge
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

    minimapBtn:SetScript("OnClick", function()
        if InCombatLockdown() then
            UIErrorsFrame:AddMessage("You cannot toggle this UI while in combat.", 1, 0.1, 0.1)
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
        tooltip:SetOwner(self, "ANCHOR_LEFT")
        tooltip:ClearLines()
        tooltip:AddLine("Story Mode", 1, 1, 1)
        tooltip:AddLine("Click to open", bodyColor[1], bodyColor[2], bodyColor[3])
        tooltip._minW = 0
        tooltip:Show()
    end)
    minimapBtn:SetScript("OnLeave", function() tooltip:Hide() end)

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
        local angle = StoryModeDB and StoryModeDB.minimapAngle or 4.4  -- default: bottom
        UpdatePosition(angle)
    end
end
