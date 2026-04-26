local addonName, SM = ...

SM.DarkIronHeritageData = {
    title = "Heritage o' the Dark Iron",
    description = "Stand with Moira Thaurissan as the Dark Iron clan steps out of Blackrock's shadow and finally claims its place at the council of Ironforge. Walk through forges that once smelted weapons for the Firelord, return to halls where Sorcerer-Thanes still whisper, and prove that the old craft-pride was never lost — only buried under ash. Reclaim the Hammer of the High Thane and remember that Dark Iron loyalty is earned in fire, not granted in court. By the end, you carry both the title and the burden of a clan re-forged.",
    zone = "Stormwind Embassy / Blackrock Depths",
    expansion = "Shadowlands",
    faction = "Alliance",
    race = "DarkIronDwarf",
    requiredLevel = 50,
    achievementID = 13076,
    achievementName = "Heritage o' the Dark Iron",
    achievements = { 13076 },
    color = { 0.45, 0.28, 0.22 },
    adventureGuideInstanceName = "Blackrock Depths",
    startQuest = { id = 51483, name = "Heritage o' the Dark Iron", npc = "Automatic", location = "Alliance city call-up" },
    npcLocations = {
        ["Moira Thaurissan"] = { mapID = 87, x = 0.2460, y = 0.5350 }, -- Hall of Explorers / Ironforge area (approx)
        ["Anvil-Thane Thurgaden"] = { mapID = 242, x = 0.3500, y = 0.3800 }, -- Blackrock Depths (approx)
        ["Kasea Angerforge"] = { mapID = 242, x = 0.3600, y = 0.4000 }, -- Blackrock Depths (approx)
    },
    chapterIcons = {
        ["Heritage o' the Dark Iron"] = "Interface\\Icons\\inv_helm_plate_raidwarrior_p_01",
    },
    chapterDisplayIDs = {
        ["Heritage o' the Dark Iron"] = 85249,
    },
    chapters = {
        {
            chapter = "Heritage o' the Dark Iron",
            summary = "Win back the Anvil-Thane's designs and reforge Dark Iron pride through craft and grit.",
            recap = "The Dark Iron legacy is forged, not inherited. By proving your worth in brawls, smithing, and service, you helped secure the clan's heritage for a new era.",
            quests = {
                { id = 51483, name = "Heritage o' the Dark Iron", npc = "Automatic" },
                { id = 63494, name = "The Anvil-Thane's Designs", npc = "Anvil-Thane Thurgaden" },
                { id = 63498, name = "Brawl or Brew", npc = "Strongarm Jarden" },
                { id = 63501, name = "It's Called Borrowing", npc = "Thurgaden's Designs" },
                { id = 63502, name = "Weapons o' the Dark Iron", npc = "Anvil-Thane Thurgaden" },
                { id = 65563, name = "Delivery for Kasea", npc = "Anvil-Thane Thurgaden" },
                { id = 65564, name = "Good Fiery Boy", npc = "Kasea Angerforge" },
            },
        },
    },
}

return SM
