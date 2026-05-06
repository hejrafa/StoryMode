local _, SM = ...
local L = SM.L
local SMTooltip = SM.Tooltip

local categories = SM.GetQuestlineCategories()
local allQuestlines = SM.GetAllQuestlines()

local storyLeftRows    = {}
local storyContentBuilt = false
local storyIndexToData = {}

function SM.GetIntroStoryRow()
    return storyLeftRows[0]
end

function SM.GetStoryRowForData(data)
    if not data then return nil end
    for _, row in pairs(storyLeftRows) do
        if row.data == data then return row end
    end
    return nil
end

function SM.GetStoryDataByIndex(index)
    return storyIndexToData[index]
end

SM.StoryCardBorderNormal   = {0.48, 0.36, 0.18, 0.56}
SM.StoryCardBorderHover    = {1.00, 0.82, 0.18, 0.95}
SM.StoryCardBorderSelected = {1.00, 0.70, 0.12, 0.90}

function SM.ApplyStoryCardBorderState(row, isHover)
    if not row or not row.btn or not row.btn.SetBackdropBorderColor then return end
    local color = SM.StoryCardBorderNormal
    if isHover then
        color = SM.StoryCardBorderHover
    elseif row.isSelected then
        color = SM.StoryCardBorderSelected
    end
    row.btn:SetBackdropBorderColor(color[1], color[2], color[3], color[4])
end

function SM.ApplyIntroCompletionState(row)
    if not row or not row.btn or not row.nameLabel then return end
    local allComplete = SM.AreAllStoriesFinished()

    if row.checkmark then
        row.checkmark:SetShown(allComplete)
    end

    row.nameLabel:ClearAllPoints()
    row.nameLabel:SetPoint("LEFT", row.icon or row.btn, row.icon and "RIGHT" or "LEFT", row.icon and 8 or 24, 0)
    row.nameLabel:SetPoint("RIGHT", row.btn, "RIGHT", -8, 0)
    row.nameLabel:SetPoint("CENTER", row.btn, "CENTER", 0, 0)
    row.nameLabel:SetJustifyV("MIDDLE")
end

-- Portrait circle sizes (Delve companion style)
local PORT = 46
local ICON = 34

function SM.ClampLeftScrollOffset(offset)
    local range = SM.LeftScroll:GetVerticalScrollRange() or 0
    offset = offset or 0
    if offset < 0 then return 0 end
    if offset > range then return range end
    return offset
end

function SM.SaveLeftStoryScroll()
    if SM.LeftPanelMode == "story" then
        SM.LeftStoryScrollOffset = SM.LeftScroll:GetVerticalScroll() or SM.LeftStoryScrollOffset or 0
    end
end

function SM.RestoreLeftStoryScroll()
    local function apply()
        if SM.LeftPanelMode ~= "story" then return end
        SM.LeftScroll:SetVerticalScroll(SM.ClampLeftScrollOffset(SM.LeftStoryScrollOffset or 0))
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(0, apply)
    else
        apply()
    end
end

function SM.SelectStory(index)
    SM.SaveLeftStoryScroll()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    StoryModeDB.selectedQuestline = index
    local selectedData = storyIndexToData[index]
    StoryModeDB.selectedQuestlineID = selectedData and selectedData.id or nil
    StoryModeDB.selectedChapter = 1  -- reset to first chapter when switching stories
    for i, row in pairs(storyLeftRows) do
        local sel = (i == index)
        if row.btn then row.btn:UnlockHighlight() end
        if row.coverTex then
            if SM.IsRetailClient() then
                local hasCover = SM.SetAdventureCoverTexture(row.coverTex, row.data)
                row.coverTex:SetShown(hasCover)
                row.coverTex:SetAlpha(1)
            else
                local hasCover = SM.SetAdventureCoverTexture(row.coverTex, row.data)
                row.coverTex:SetShown(hasCover)
                row.coverTex:SetAlpha(0.72)
            end
        end
        row.isSelected = sel
        if SM.IsClassicClient() then
            SM.ApplyStoryCardBorderState(row, false)
        end
        row.bg:SetAlpha(1.0)
        if row.portBorder then row.portBorder:SetAlpha(sel and 1.0 or 0.5) end
        if i == 0 then SM.ApplyIntroCompletionState(row) end
        row.nameLabel:SetTextColor(1.0, 1.0, 1.0)
        if row.zoneLabel then row.zoneLabel:SetTextColor(1.0, 0.82, 0.36) end
        local state = row.data and SM.GetStoryState(row.data) or nil
        local gateReason = state and state.gateReason or nil
        if row.btn then row.btn.lockReason = gateReason end
        if row.checkmark and row.data then
            row.checkmark:SetShown(state and state.isFinished)
        elseif row.checkmark and row.isIntro then
            row.checkmark:SetShown(SM.AreAllStoriesFinished())
        end
    end
    if index == 0 or not selectedData then
        SM.UpdateStoryDetail(nil)
    else
        SM.UpdateStoryDetail(selectedData)
    end
end

function SM.GetStoryIndexByID(storyID)
    if not storyID then return nil end
    for idx, data in pairs(storyIndexToData) do
        if data and data.id == storyID then return idx end
    end
    return nil
end

local function RefreshStoryRow(row)
    if not row then return end
    if row.isIntro then
        SM.ApplyIntroCompletionState(row)
    elseif row.data then
        local state = SM.GetStoryState(row.data)
        local gateReason = state and state.gateReason or nil
        if row.btn then row.btn.lockReason = gateReason end
        if row.checkmark then
            row.checkmark:SetShown(state and state.isFinished)
        end
        if row.coverTex and SM.IsClassicClient() then
            row.coverTex:SetShown(SM.SetAdventureCoverTexture(row.coverTex, row.data))
        end
    end
    if SM.IsClassicClient() then
        SM.ApplyStoryCardBorderState(row, false)
    end
end

function SM.RefreshStoryListState(data)
    if data then
        RefreshStoryRow(SM.GetStoryRowForData(data))
        RefreshStoryRow(storyLeftRows[0])
        return
    end
    for _, row in pairs(storyLeftRows) do
        RefreshStoryRow(row)
    end
end


function SM.BuildStoryWindow()
    if storyContentBuilt then return end
    if SM.RegisterQuestlines then SM.RegisterQuestlines() end
    if SM.IsQuestlineRegistryReady and not SM.IsQuestlineRegistryReady() then return end
    storyContentBuilt = true
    for _, data in ipairs(allQuestlines) do SM.ResolveAchievementID(data) end
    wipe(storyIndexToData)

    local CARD_H   = (SM.IsRetailClient()) and 78 or 70
    local CARD_PAD = 4
    local yOffset  = -16
    local globalIdx = 0

    -- ── Introduction card (index 0 = show intro text on right) ───────────
    local playerName = UnitName("player")
    local introDivH = SM.CreateCatDivider(SM.LeftStoryChild, playerName and string.format(L["Greeting Format"], playerName) or L["Greeting Fallback"], yOffset)
    yOffset = yOffset - introDivH - 4

    local introCard = CreateFrame("Button", nil, SM.LeftStoryChild, (SM.IsRetailClient()) and nil or "BackdropTemplate")
    introCard:SetHeight(CARD_H)
    introCard:SetPoint("TOPLEFT",  SM.LeftStoryChild, "TOPLEFT",  CARD_PAD, yOffset)
    introCard:SetPoint("TOPRIGHT", SM.LeftStoryChild, "TOPRIGHT", -CARD_PAD, yOffset)
    introCard:RegisterForClicks("AnyUp")
    if SM.IsClassicClient() then
        SM.ApplyClassicCardBackdrop(introCard, 0, 0.50)
    end
    local introBg = introCard:CreateTexture(nil, "BACKGROUND")
    if SM.IsRetailClient() then
        introBg:SetAtlas("housefinder_neighborhood-list-item-default", false)
        introBg:SetAllPoints()
    else
        SM.ClearCardFillTexture(introBg)
    end
    if SM.IsClassicClient() then
        introCard.shade = SM.CreateInsetCardShade(introCard, 0.38)
    end
    if SM.IsRetailClient() then
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
    introIcon:SetTexture(SM.StoryModeIconTexture)

    local introIconMask = introPort:CreateMaskTexture()
    introIconMask:SetTexture(
        "Interface/CHARACTERFRAME/TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    introIconMask:SetAllPoints(introIcon)
    introIcon:AddMaskTexture(introIconMask)

    local introName = SM.NoShadow(introCard:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
    introName:SetPoint("LEFT",  introIcon, "RIGHT", 8, 0)
    introName:SetPoint("RIGHT", introCard, "RIGHT", -8, 0)
    introName:SetJustifyH("LEFT"); introName:SetJustifyV("MIDDLE")
    introName:SetMaxLines(1); introName:SetWordWrap(false)
    introName:SetText(L["Addon Name"])
    introName:SetTextColor(1.0, 1.0, 1.0)

    local introZone = nil  -- no subline

    introCard.checkmark = SM.CreateCompletionRibbon(introCard)
    if SM.IsRetailClient() then
        introCard.checkmark:SetPoint("TOPRIGHT", introCard, "TOPRIGHT", -15, -1)
    else
        introCard.checkmark:SetPoint("RIGHT", introCard, "RIGHT", -18, 0)
    end
    introCard.checkmark:SetShown(SM.AreAllStoriesFinished())

    -- Store intro card for select styling
    storyLeftRows[0] = {
        btn       = introCard,
        bg        = introBg,
        icon      = introIcon,
        nameLabel = introName,
        zoneLabel = introZone,
        checkmark = introCard.checkmark,
        isIntro   = true,
    }
    introCard:SetScript("OnClick", function() SM.SelectStory(0) end)
    introCard:SetScript("OnEnter", function()
        if SM.IsClassicClient() then
            SM.ApplyStoryCardBorderState(storyLeftRows[0], true)
        end
    end)
    introCard:SetScript("OnLeave", function()
        if SM.IsClassicClient() then
            SM.ApplyStoryCardBorderState(storyLeftRows[0], false)
        end
    end)
    SM.ApplyIntroCompletionState(storyLeftRows[0])

    yOffset = yOffset - CARD_H - 4

    -- ── Questline cards ──────────────────────────────────────────────────
    for _, cat in ipairs(categories) do
        if cat.disabled then
            local divH = SM.CreateCatDivider(SM.LeftStoryChild, cat.displayName or cat.name, yOffset)
            yOffset = yOffset - divH - 12
        elseif #cat.questlines > 0 then
            local divH = SM.CreateCatDivider(SM.LeftStoryChild, cat.displayName or cat.name, yOffset)
            yOffset = yOffset - divH - 4
            for _, data in ipairs(cat.questlines) do
                globalIdx = globalIdx + 1
                local idx = globalIdx
                storyIndexToData[idx] = data

                -- ── Card frame ────────────────────────────────────────────────
                local card = CreateFrame("Button", nil, SM.LeftStoryChild, (SM.IsRetailClient()) and nil or "BackdropTemplate")
                card:SetHeight(CARD_H)
                card:SetPoint("TOPLEFT",  SM.LeftStoryChild, "TOPLEFT",  CARD_PAD, yOffset)
                card:SetPoint("TOPRIGHT", SM.LeftStoryChild, "TOPRIGHT", -CARD_PAD, yOffset)
                card:RegisterForClicks("AnyUp")
                if SM.IsClassicClient() then
                    SM.ApplyClassicCardBackdrop(card, 0, 0.50)
                end
                -- House Finder card background
                local bg = card:CreateTexture(nil, "BACKGROUND", nil, 2)
                if SM.IsRetailClient() then
                    bg:SetAtlas("housefinder_neighborhood-list-item-default", false)
                    bg:SetAllPoints()
                else
                    SM.ClearCardFillTexture(bg)
                end
                if SM.IsClassicClient() then
                    card.shade = SM.CreateInsetCardShade(card, 0.38, 4)
                end

                local coverTex = card:CreateTexture(nil, "BACKGROUND", nil, (SM.IsRetailClient()) and 0 or 2)
                if SM.IsRetailClient() then
                    coverTex:SetPoint("TOPLEFT", card, "TOPLEFT", 7, -7)
                    coverTex:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -7, 7)
                    coverTex:SetAlpha(0.78)
                    coverTex:Hide()
                else
                    coverTex:SetPoint("TOPLEFT", card, "TOPLEFT", 3, -3)
                    coverTex:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -3, 3)
                    coverTex:SetAlpha(0.72)
                    coverTex:SetShown(SM.SetAdventureCoverTexture(coverTex, data))
                end
                if SM.IsRetailClient() then
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
                            local heritageIcon = SM.HeritageIconByRace[data.race]
                            if not (heritageIcon and SM.SafeSetTexture(iconTex, heritageIcon)) then
                                if data.race == "Pandaren" then
                                    SM.SafeSetTexture(iconTex, SM.PandarenTabardIcon)
                                else
                                    SM.SafeSetTexture(iconTex, SM.HeritageIconFallback)
                                end
                            end
                        end
                    end
                elseif data.race and not data.class and data.icon then
                    -- Heritage cards should reflect the configured questline card icon.
                    if not SM.SafeSetTexture(iconTex, data.icon) then
                        local heritageIcon = SM.HeritageIconByRace[data.race]
                        if not (heritageIcon and SM.SafeSetTexture(iconTex, heritageIcon)) then
                            if data.race == "Pandaren" then
                                SM.SafeSetTexture(iconTex, SM.PandarenTabardIcon)
                            else
                                SM.SafeSetTexture(iconTex, SM.HeritageIconFallback)
                            end
                        end
                    end
                elseif data.achievementID and not data.icon then
                    local _,_,_,_,_,_,_,_,_,achIcon = GetAchievementInfo(data.achievementID)
                    if achIcon and achIcon ~= 0 then iconTex:SetTexture(achIcon) end
                elseif data.icon then
                    if not SM.SafeSetTexture(iconTex, data.icon) then
                        if data.race == "Pandaren" then
                            SM.SafeSetTexture(iconTex, SM.PandarenTabardIcon)
                        else
                            SM.SafeSetTexture(iconTex, SM.HeritageIconFallback)
                        end
                    end
                elseif data.race and not data.class then
                    -- Heritage cards: fallback to cloak/tabard style imagery.
                    local heritageIcon = SM.HeritageIconByRace[data.race]
                    if not (heritageIcon and SM.SafeSetTexture(iconTex, heritageIcon)) then
                        if data.race == "Pandaren" then
                            SM.SafeSetTexture(iconTex, SM.PandarenTabardIcon)
                        else
                            SM.SafeSetTexture(iconTex, SM.HeritageIconFallback)
                        end
                    end
                end
                if not iconTex:GetTexture() and data.race and not data.class then
                    local heritageIcon = SM.HeritageIconByRace[data.race]
                    if not (heritageIcon and SM.SafeSetTexture(iconTex, heritageIcon)) then
                        if data.race == "Pandaren" then
                            SM.SafeSetTexture(iconTex, SM.PandarenTabardIcon)
                        else
                            SM.SafeSetTexture(iconTex, SM.HeritageIconFallback)
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
                local nameLabel = SM.NoShadow(card:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
                nameLabel:SetPoint("LEFT",   card,      "LEFT",  24,  0)
                nameLabel:SetPoint("RIGHT",  card,      "RIGHT", -42,  0)
                nameLabel:SetPoint("BOTTOM", card,      "CENTER", 0,  1)
                nameLabel:SetJustifyH("LEFT"); nameLabel:SetJustifyV("BOTTOM")
                nameLabel:SetMaxLines(1); nameLabel:SetWordWrap(false)
                nameLabel:SetText(data.title)
                nameLabel:SetTextColor(1.0, 1.0, 1.0)

                local zoneLabel = SM.NoShadow(card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
                zoneLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -2)
                zoneLabel:SetPoint("RIGHT",   card,      "RIGHT",     -42,  0)
                zoneLabel:SetJustifyH("LEFT")
                local zoneText = SM.GetQuestlineCardSubline(data)
                local parts = {}
                for part in zoneText:gmatch("[^/]+") do
                    parts[#parts + 1] = part:match("^%s*(.-)%s*$")
                end
                if SM.IsClassicClient() and #parts > 1 then
                    zoneText = parts[1]
                elseif #parts > 2 then
                    zoneText = parts[1] .. " / " .. parts[2]
                end
                zoneLabel:SetText(zoneText)
                zoneLabel:SetTextColor(1.0, 0.82, 0.36)

                -- ── Completion checkmark ──────────────────────────────────────
                local cardCheckmark = SM.CreateCompletionRibbon(card)
                if SM.IsRetailClient() then
                    cardCheckmark:SetPoint("TOPRIGHT", card, "TOPRIGHT", -15, -1)
                else
                    cardCheckmark:SetPoint("RIGHT", card, "RIGHT", -18, 0)
                end
                local state = SM.GetStoryState(data)
                local gateReason = state and state.gateReason or nil
                card.lockReason = gateReason
                if gateReason then
                    cardCheckmark:Hide()
                elseif state and state.isFinished then
                    cardCheckmark:Show()
                else
                    cardCheckmark:Hide()
                end

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

                -- ── Click ──────────────────────────────────────────────────────
                card:SetScript("OnClick", function() SM.SelectStory(idx) end)
                card:SetScript("OnEnter", function(self)
                    if SM.IsClassicClient() then
                        SM.ApplyStoryCardBorderState(storyLeftRows[idx], true)
                    end
                    if not self.lockReason then return end
                    SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    SMTooltip:ClearLines()
                    SMTooltip:AddLine(L["Tooltip Story Locked"], 1, 1, 1)
                    SMTooltip:AddLine(self.lockReason, 1.0, 0.82, 0.35, true)
                    SMTooltip:Show()
                end)
                card:SetScript("OnLeave", function()
                    if SM.IsClassicClient() then
                        SM.ApplyStoryCardBorderState(storyLeftRows[idx], false)
                    end
                    SMTooltip:Hide()
                end)
                yOffset = yOffset - CARD_H - 5
            end
            yOffset = yOffset - 8
        end
    end
    SM.LeftStoryChild:SetHeight(math.abs(yOffset) + 16)
end
