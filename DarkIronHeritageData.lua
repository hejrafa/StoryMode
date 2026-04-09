local addonName, SM = ...

SM.DarkIronHeritageData = {
    title = "Heritage o' the Dark Iron",
    description = "Stand with Moira and the Dark Iron to reclaim old craft-pride through steel, fire, and hard-won loyalty.",
    zone = "Stormwind Embassy / Blackrock Depths",
    expansion = "Shadowlands",
    faction = "Alliance",
    race = "DarkIronDwarf",
    requiredLevel = 50,
    achievementName = "Heritage o' the Dark Iron",
    color = { 0.45, 0.28, 0.22 },
    icon = "Interface\\Icons\\inv_misc_tabard_darkiron",
    startQuest = { id = 51483, name = "Heritage o' the Dark Iron", npc = "Automatic", location = "Alliance city call-up" },
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
