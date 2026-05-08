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

local function unescapeLuaString(value)
    return (value:gsub('\\"', '"'):gsub("\\\\", "\\"))
end

local function readQuotedString(line, quoteStart)
    local out = {}
    local i = quoteStart + 1
    while i <= #line do
        local ch = line:sub(i, i)
        if ch == "\\" then
            local nextCh = line:sub(i + 1, i + 1)
            if nextCh == "" then break end
            out[#out + 1] = "\\" .. nextCh
            i = i + 2
        elseif ch == '"' then
            return unescapeLuaString(table.concat(out)), i
        else
            out[#out + 1] = ch
            i = i + 1
        end
    end
    return nil, nil
end

local function stringField(line, key)
    local startAt = line:find(key.."%s*=%s*\"")
    if not startAt then return nil end
    local quoteStart = line:find('"', startAt)
    if not quoteStart then return nil end
    return readQuotedString(line, quoteStart)
end

local function tableKey(line)
    local startAt = line:find('%[%s*"')
    if not startAt then return nil end
    local quoteStart = line:find('"', startAt)
    if not quoteStart then return nil end
    return readQuotedString(line, quoteStart)
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
        for line in block:gmatch("[^\n]+") do
            local name = tableKey(line)
            local body = line:match("%{([^}]+)}")
            if name and body then
            local mapID = tonumber(body:match("mapID%s*=%s*(%d+)"))
            local x = tonumber(body:match("x%s*=%s*([%-%d%.]+)"))
            local y = tonumber(body:match("y%s*=%s*([%-%d%.]+)"))
            local location = stringField(body, "location")
            if not mapID or not x or not y then
                add(file, ("entry %q missing fields"):format(name))
            else
                if x < 0 or x > 1 then add(file, ("%q x=%.4f out of [0,1]"):format(name, x)) end
                if y < 0 or y > 1 then add(file, ("%q y=%.4f out of [0,1]"):format(name, y)) end
                if math.abs(x-0.5) < 0.005 and math.abs(y-0.5) < 0.005 then
                    add(file, ("%q at exact zone center — placeholder?"):format(name))
                end
                entries[name] = {mapID=mapID, x=x, y=y, location=location}
            end
            end
        end

        local seen = {}
        for name, loc in pairs(entries) do
            local key = loc.mapID..":"..("%.4f"):format(loc.x)..":"..("%.4f"):format(loc.y)
            if seen[key] then
                local other = entries[seen[key]]
                local hasNamedPlace = loc.location and other and other.location
                if not hasNamedPlace then
                    add(file, ("%q shares coords with %q (%d:%.4f,%.4f) — fallback alias?"):format(name, seen[key], loc.mapID, loc.x, loc.y))
                end
            else
                seen[key] = name
            end
        end

        local listed = {}
        for n in pairs(entries) do listed[n] = true end
        for entry in src:gmatch('{%s*id%s*=%s*%d+.-}') do
            local npc = stringField(entry, "npc")
            if npc and not isNonNpc(npc) then
                local base = stripFactionTag(npc)
                local hasQuestLocation = entry:match("mapID%s*=")
                    and entry:match("x%s*=")
                    and entry:match("y%s*=")
                if not hasQuestLocation and not listed[npc] and not listed[base] then
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
