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

-- Map data provider for the "begin tracking" ping. We can't parent an insecure
-- frame to WorldMapFrame.ScrollContainer.Child directly — that taints the secure
-- canvas and propagates into AreaPOI tooltip widgets. Going through a proper
-- MapCanvasDataProvider with a pin template is the supported path.

StoryModePingPinMixin = CreateFromMixins(MapCanvasPinMixin)

function StoryModePingPinMixin:OnLoad()
    self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
    self:SetIgnoreGlobalPinScale(true)
    self.anim:SetScript("OnFinished", function()
        local map = self:GetMap()
        if map then map:RemovePin(self) end
    end)
end

function StoryModePingPinMixin:OnAcquired(x, y)
    self:SetPosition(x, y)
    self:SetAlpha(1)
    self.anim:Stop()
    self.anim:Play()
end

function StoryModePingPinMixin:OnReleased()
    self.anim:Stop()
end

local PingDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin)

function PingDataProviderMixin:GetPinTemplate()
    return "StoryModePingPinTemplate"
end

function PingDataProviderMixin:RemoveAllData()
    self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate())
end

function PingDataProviderMixin:RefreshAllData(fromOnShow)
    self:RemoveAllData()
    if self.pendingX and self.pendingY then
        self:GetMap():AcquirePin(self:GetPinTemplate(), self.pendingX, self.pendingY)
        self.pendingX, self.pendingY = nil, nil
    end
end

function PingDataProviderMixin:Ping(x, y)
    self.pendingX, self.pendingY = x, y
    self:RefreshAllData()
end

local pingProvider
local function GetPingProvider()
    if pingProvider then return pingProvider end
    if not WorldMapFrame then return nil end
    pingProvider = CreateFromMixins(PingDataProviderMixin)
    WorldMapFrame:AddDataProvider(pingProvider)
    return pingProvider
end

local function PingOnWorldMap(mapID, x, y)
    if not WorldMapFrame then return end
    OpenWorldMap(mapID)
    PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_SUPER_TRACK_ON or 167425)

    local provider = GetPingProvider()
    if not provider then return end

    -- Defer so the canvas has finished switching to mapID before we acquire a pin.
    C_Timer.After(0.15, function()
        if not WorldMapFrame:IsShown() then return end
        provider:Ping(x, y)
    end)
end

-- Ask Blizzard where the quest's icon actually sits on the map. Works for
-- accepted quests (next-waypoint API) and for offered quests visible on the
-- given map (GetQuestsOnMap). Returns nil if the engine doesn't know.
local function GetLiveQuestLocation(qid, mapHint)
    if not qid then return nil end

    if C_QuestLog.GetQuestUiMapID then
        local mapID = C_QuestLog.GetQuestUiMapID(qid)
        if mapID and mapID > 0 and C_QuestLog.GetNextWaypointForMap then
            local x, y = C_QuestLog.GetNextWaypointForMap(qid, mapID)
            if x and y then return { mapID = mapID, x = x, y = y } end
        end
    end

    if mapHint and C_QuestLog.GetQuestsOnMap then
        local quests = C_QuestLog.GetQuestsOnMap(mapHint)
        if quests then
            for _, q in ipairs(quests) do
                if q.questID == qid and q.x and q.y then
                    return { mapID = mapHint, x = q.x, y = q.y }
                end
            end
        end
    end

    return nil
end

local function GetQuestLocation(data, quest)
    local mapHint = (data.npcLocations and data.npcLocations[quest.npc] and data.npcLocations[quest.npc].mapID)
        or data.startMapID
    local live = GetLiveQuestLocation(quest.id, mapHint)
    if live then return live end

    local loc = data.npcLocations and data.npcLocations[quest.npc]
    if loc then return loc end

    if data.startQuest and quest.id == data.startQuest.id and data.startMapID and data.startX and data.startY then
        return { mapID = data.startMapID, x = data.startX, y = data.startY }
    end

    return nil
end

function SM.SetWaypointForQuest(data, quest)
    if not quest then return "no_location", nil, nil end

    EnsureTrivialQuestsVisible()

    if SM.IsQuestInLog(quest.id) then
        local qid = quest.id
        C_QuestLog.AddQuestWatch(qid)
        C_SuperTrack.SetSuperTrackedQuestID(qid)
        local loc = GetQuestLocation(data, quest)
        if loc then
            PingOnWorldMap(loc.mapID, loc.x, loc.y)
        end
        return "supertracked", loc and loc.mapID, loc
    end

    local loc = GetQuestLocation(data, quest)
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
    local loc = GetQuestLocation(data, quest)
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
