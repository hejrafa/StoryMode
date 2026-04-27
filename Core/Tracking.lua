local addonName, SM = ...

local function EnsureTrivialQuestsVisible()
    for i = 1, C_Minimap.GetNumTrackingTypes() do
        local info = C_Minimap.GetTrackingInfo(i)
        if info and not info.active then
            local isTrivial = (MINIMAP_TRACKING_TRIVIAL_QUESTS and info.name == MINIMAP_TRACKING_TRIVIAL_QUESTS)
                or info.name == "Trivial Quests"
                or info.name == "Low Level Quests"
            if isTrivial then
                local idx, name = i, info.name
                C_Timer.After(0, function()
                    C_Minimap.SetTracking(idx, true)
                    print("|cff64b5f6Story Mode:|r Enabled |cffffd200" .. name .. "|r tracking so you can see quest markers for this storyline.")
                end)
                return
            end
        end
    end
end

local pingFrame
local function GetPingFrame()
    if pingFrame then return pingFrame end

    local f = CreateFrame("Frame")
    f:SetSize(32, 32)
    f:SetFrameStrata("HIGH")
    f:Hide()

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
    tex:SetVertexColor(1, 0.78, 0.1)
    f.tex = tex

    local ag = f:CreateAnimationGroup()
    ag:SetLooping("NONE")

    local s = ag:CreateAnimation("Scale")
    s:SetScaleFrom(0.6, 0.6)
    s:SetScaleTo(3.0, 3.0)
    s:SetDuration(0.75)
    s:SetSmoothing("OUT")

    local a = ag:CreateAnimation("Alpha")
    a:SetFromAlpha(0.9)
    a:SetToAlpha(0)
    a:SetDuration(0.75)
    a:SetSmoothing("OUT")

    ag:SetScript("OnFinished", function() f:Hide(); f:SetParent(UIParent) end)
    f.anim = ag

    pingFrame = f
    return f
end

local function PingOnWorldMap(mapID, x, y)
    if not WorldMapFrame then return end
    OpenWorldMap(mapID)
    PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_SUPER_TRACK_ON or 167425)

    C_Timer.After(0.15, function()
        if not WorldMapFrame:IsShown() then return end
        local canvas = WorldMapFrame.ScrollContainer.Child
        if not canvas then return end

        local f = GetPingFrame()
        f:SetParent(canvas)
        f:ClearAllPoints()
        f:SetPoint("CENTER", canvas, "TOPLEFT",
            canvas:GetWidth() * x, -canvas:GetHeight() * y)
        f:SetAlpha(1)
        f:SetScale(1)
        f:Show()
        f.anim:Stop()
        f.anim:Play()
    end)
end

function SM.SetWaypointForQuest(data, quest)
    if not quest then return "no_location", nil, nil end

    EnsureTrivialQuestsVisible()

    if SM.IsQuestInLog(quest.id) then
        local qid = quest.id
        C_QuestLog.AddQuestWatch(qid)
        C_SuperTrack.SetSuperTrackedQuestID(qid)
        local loc = data.npcLocations and data.npcLocations[quest.npc]
        if loc then
            PingOnWorldMap(loc.mapID, loc.x, loc.y)
        end
        return "supertracked", loc and loc.mapID, loc
    end

    local loc = data.npcLocations and data.npcLocations[quest.npc]
    local qid = quest.id

    if Enum.SuperTrackingMapPinType and Enum.SuperTrackingMapPinType.QuestOffer then
        C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.QuestOffer, qid)
    end

    if loc and C_Map.CanSetUserWaypointOnMap(loc.mapID) then
        local point = UiMapPoint.CreateFromCoordinates(loc.mapID, loc.x, loc.y)
        C_Map.SetUserWaypoint(point)
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        PingOnWorldMap(loc.mapID, loc.x, loc.y)
        return "waypoint", loc.mapID, loc
    end

    if loc then
        PingOnWorldMap(loc.mapID, loc.x, loc.y)
        return "waypoint_approx", loc.mapID, loc
    end

    if data.startMapID then
        OpenWorldMap(data.startMapID)
    end
    return "no_location", nil, nil
end

local function GetZoneName(mapID)
    local info = mapID and C_Map.GetMapInfo(mapID)
    return info and info.name or nil
end

function SM.PrintTrackResult(result, quest, data)
    local P = "|cff64b5f6Story Mode:|r "
    local loc = data.npcLocations and data.npcLocations[quest.npc]
    local zone = loc and GetZoneName(loc.mapID) or nil

    if result == "supertracked" then
        if zone then
            print(P .. "Tracking: |cffffd200" .. quest.name .. "|r — check your map.")
        else
            print(P .. "Tracking: |cffffd200" .. quest.name .. "|r")
        end
    elseif result == "waypoint" or result == "waypoint_approx" then
        if quest._isPrerequisiteForChapter then
            if zone then
                print(P .. "Chapter lock: complete |cffffd200" .. quest.name .. "|r in |cff64b5f6" .. zone .. "|r first, then continue |cffffd200" .. quest._isPrerequisiteForChapter .. "|r.")
            else
                print(P .. "Chapter lock: complete |cffffd200" .. quest.name .. "|r first, then continue |cffffd200" .. quest._isPrerequisiteForChapter .. "|r.")
            end
            return
        end
        if zone then
            print(P .. "Find |cffffd200" .. quest.npc .. "|r in |cff64b5f6" .. zone .. "|r to accept: " .. quest.name)
        else
            print(P .. "Find |cffffd200" .. quest.npc .. "|r to accept: " .. quest.name)
        end
    else
        if quest._isPrerequisiteForChapter then
            if zone then
                print(P .. "Chapter lock: complete |cffffd200" .. quest.name .. "|r from " .. quest.npc .. " in |cff64b5f6" .. zone .. "|r first.")
            else
                print(P .. "Chapter lock: complete |cffffd200" .. quest.name .. "|r first.")
            end
            return
        end
        if zone then
            print(P .. "Next: |cffffd200" .. quest.name .. "|r from " .. quest.npc .. " in |cff64b5f6" .. zone .. "|r")
        else
            print(P .. "Next: |cffffd200" .. quest.name .. "|r from |cffffd200" .. quest.npc .. "|r")
        end
    end
end
