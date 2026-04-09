local addonName, SM = ...

SM.GoblinHeritageData = {
    title = "Heritage of Kezan",
    description = "Reunite old allies, outplay Gallywix, and help Hobart finish his masterpiece in a bombastic goblin adventure through Crapopolis.",
    zone = "Stranglethorn / Crapopolis",
    expansion = "Battle for Azeroth",
    faction = "Horde",
    race = "Goblin",
    requiredLevel = 50,
    achievementName = "Heritage of Kezan",
    color = { 0.25, 0.72, 0.20 },
    icon = "Interface\\Icons\\inv_misc_tabard_goblin",
    startQuest = { id = 57043, name = "Old Friends, New Opportunities", npc = "Izzy", location = "Orgrimmar Embassy" },
    startMapID = 85,
    startX = 0.3790,
    startY = 0.8130,
    npcDisplayIDs = {
        ["Sassy Hardwrench"] = 40444,
        ["Hobart Grapplehammer"] = 19893,
        ["Izzy"] = 0,
    },
    chapters = {
        {
            chapter = "Heritage of Kezan",
            summary = "Build, test, and defend the X-52 while goblin politics and greed explode all around you.",
            recap = "Business, betrayal, and big explosions: a proper goblin story. You helped Hobart finish the X-52, survived every reckless test, crushed Gallywix's takeover, and earned the right to wear the pride of Kezan.",
            quests = {
                { id = 57043, name = "Old Friends, New Opportunities", npc = "Izzy" },
                { id = 57045, name = "A Special Delivery", npc = "Sassy Hardwrench" },
                { id = 57047, name = "A Simple Experiment", npc = "Hobart Grapplehammer" },
                { id = 57048, name = "Shopping For Parts", npc = "Hobart Grapplehammer" },
                { id = 57051, name = "Debt Collection!", npc = "Crank Greasefuse" },
                { id = 57052, name = "I've Got What You Need", npc = "Crank Greasefuse" },
                { id = 57053, name = "Blunt Force Testing", npc = "Hobart Grapplehammer" },
                { id = 57058, name = "Fun With Landmines", npc = "Hobart Grapplehammer" },
                { id = 57059, name = "Let's Rumble!", npc = "Hobart Grapplehammer" },
                { id = 57077, name = "Buyers Wanted!", npc = "Hobart Grapplehammer" },
                { id = 57078, name = "The VIP List", npc = "Sassy Hardwrench" },
                { id = 57079, name = "Beat The Crapopolis Outta Him!", npc = "Sassy Hardwrench" },
                { id = 57080, name = "A Fitting Reward", npc = "Hobart Grapplehammer" },
            },
        },
    },
}

return SM
