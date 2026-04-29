#!/usr/bin/env lua
-- Sanity-check the npcLocations tables across all data files.
--
-- Run from the addon root:
--     lua _Dev/tools/validate_npc_locations.lua
--
-- What it flags:
--   * coords outside [0, 1]
--   * coords at exact zone center (likely placeholders)
--   * multiple NPCs sharing the same map+coords (potential alias placeholders)
--   * quest npc names that aren't in npcLocations and aren't a known
--     non-NPC quest source ("Automatic", item names, etc.)
--
-- Note: since we now use C_QuestLog.GetNextWaypointForMap at runtime,
-- a missing npcLocations entry only matters for the "first ping for an
-- un-accepted quest not currently visible on the open map" path.

local NON_NPC_QUEST_SOURCES = {
    ["Automatic"] = true,
    ["Varies"] = true,
}

-- Names containing any of these substrings are treated as non-NPC quest
-- sources (mailed parcels, click-on-object quests, faction-specific
-- automatic handoffs, etc.).
local NON_NPC_PATTERNS = {
    "^Automatic", "Sealed", "Parcel", "Tablet", "Armor Stand",
    "Bag of", "Cactus Apples", "Designs",
}

local function isNonNpc(name)
    if NON_NPC_QUEST_SOURCES[name] then return true end
    for _, pat in ipairs(NON_NPC_PATTERNS) do
        if name:find(pat) then return true end
    end
    return false
end

-- Parenthetical faction tags ("Aysa Cloudsinger (Alliance)") strip down
-- to a base name before we look them up in npcLocations.
local function stripFactionTag(name)
    return (name:gsub("%s*%([^)]+%)%s*$", ""))
end

local files = {}
local function scan(dir)
    local p = io.popen('ls "'..dir..'" 2>/dev/null')
    if not p then return end
    for f in p:lines() do
        if f:match("%.lua$") then files[#files+1] = dir.."/"..f end
    end
    p:close()
end
scan("Data/Storylines"); scan("Data/Heritage"); scan("Data/Campaigns")

local issues = {}
local function add(file, msg) issues[#issues+1] = file..": "..msg end

for _, file in ipairs(files) do
    local src = io.open(file, "r"):read("*a")

    for block in src:gmatch("npcLocations%s*=%s*{(.-)\n%s*},") do
        local entries = {}
        for name, body in block:gmatch('%["?([^"%]]+)"?%]%s*=%s*{([^}]+)}') do
            local mapID = tonumber(body:match("mapID%s*=%s*(%d+)"))
            local x = tonumber(body:match("x%s*=%s*([%-%d%.]+)"))
            local y = tonumber(body:match("y%s*=%s*([%-%d%.]+)"))
            if not mapID or not x or not y then
                add(file, ("entry %q missing fields"):format(name))
            else
                if x < 0 or x > 1 then add(file, ("%q x=%.4f out of [0,1]"):format(name, x)) end
                if y < 0 or y > 1 then add(file, ("%q y=%.4f out of [0,1]"):format(name, y)) end
                if math.abs(x-0.5) < 0.005 and math.abs(y-0.5) < 0.005 then
                    add(file, ("%q at exact zone center — placeholder?"):format(name))
                end
                entries[name] = {mapID=mapID, x=x, y=y}
            end
        end

        local seen = {}
        for name, loc in pairs(entries) do
            local key = loc.mapID..":"..("%.4f"):format(loc.x)..":"..("%.4f"):format(loc.y)
            if seen[key] then
                add(file, ("%q shares coords with %q (%d:%.4f,%.4f) — fallback alias?"):format(name, seen[key], loc.mapID, loc.x, loc.y))
            else
                seen[key] = name
            end
        end

        local listed = {}
        for n in pairs(entries) do listed[n] = true end
        for npc in src:gmatch('npc%s*=%s*"([^"]+)"') do
            if not isNonNpc(npc) then
                local base = stripFactionTag(npc)
                if not listed[npc] and not listed[base] then
                    add(file, ("quest npc %q not in npcLocations"):format(npc))
                end
            end
        end
    end
end

table.sort(issues)
local last
for _, i in ipairs(issues) do
    if i ~= last then print(i); last = i end
end
print(("--- %d issue lines"):format(#issues))
