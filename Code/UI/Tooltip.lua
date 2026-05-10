local addonName, SM = ...

-- Private tooltip: plain Frame, never touches the GameTooltip C layer so we
-- cannot taint MoneyFrame or EmbeddedItemTooltip arithmetic in Blizzard code.
do
    local TTPAD  = 10
    local TTLSP  = 3
    local TTWRAP = 380
    local TTMIN  = 220

    local tooltip = CreateFrame("Frame", "StoryModeTooltip", UIParent, "BackdropTemplate")
    tooltip:SetFrameStrata("TOOLTIP")
    tooltip:SetToplevel(true)
    tooltip:SetClampedToScreen(true)
    tooltip:Hide()
    tooltip:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    tooltip:SetBackdropColor(0.09, 0.09, 0.19, 1)
    tooltip:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)

    local ttLines = {}
    local ttLineN = 0
    local ttWraps = {}  -- parallel bool array: ttWraps[i] = true if line i wraps

    local function TTLine(i)
        if not ttLines[i] then
            local fs = tooltip:CreateFontString(nil, "OVERLAY", "GameTooltipText")
            if fs.SetFontObject and GameTooltipText then
                fs:SetFontObject(GameTooltipText)
            end
            fs:SetJustifyH("LEFT")
            ttLines[i] = fs
        end
        return ttLines[i]
    end

    local frameShow = tooltip.Show

    function tooltip:SetOwner(frame, anchor)
        self:ClearAllPoints()
        if anchor == "ANCHOR_LEFT" then
            self:SetPoint("TOPRIGHT", frame, "TOPLEFT", -5, 0)
        else
            self:SetPoint("TOPLEFT", frame, "TOPRIGHT", 5, 0)
        end
    end

    function tooltip:ClearLines()
        ttLineN = 0
        for _, fs in ipairs(ttLines) do fs:Hide() end
        ttWraps = {}
    end

    function tooltip:AddLine(text, r, g, b, wrap)
        ttLineN = ttLineN + 1
        local fs = TTLine(ttLineN)
        fs:SetTextColor(r or 1, g or 1, b or 1)
        fs:SetWordWrap(wrap and true or false)
        fs:SetWidth(wrap and TTWRAP or 0)
        fs:SetText(text or "")
        ttWraps[ttLineN] = wrap and true or false
        fs:Show()
    end

    function tooltip:Show()
        local maxW = self._minW ~= nil and self._minW or TTMIN
        self._minW = nil
        for i = 1, ttLineN do
            local fs = ttLines[i]
            if fs and fs:IsShown() and not ttWraps[i] then
                local w = fs:GetStringWidth()
                if w > maxW then maxW = w end
            end
        end
        local innerW = math.min(maxW, TTWRAP)

        local yOff = -TTPAD
        for i = 1, ttLineN do
            local fs = ttLines[i]
            if fs and fs:IsShown() then
                fs:ClearAllPoints()
                fs:SetPoint("TOPLEFT", self, "TOPLEFT", TTPAD, yOff)
                if ttWraps[i] then fs:SetWidth(innerW) end
                yOff = yOff - fs:GetStringHeight() - TTLSP
            end
        end

        self:SetWidth(innerW + TTPAD * 2)
        self:SetHeight(math.abs(yOff) - TTLSP + TTPAD)
        frameShow(self)
    end

    SM.Tooltip = tooltip
end
