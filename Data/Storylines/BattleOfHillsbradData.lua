local addonName, SM = ...

-- =============================================================================
-- Classic: Battle of Hillsbrad
-- The Forsaken campaign against Hillsbrad, Azureload Mine, and Dun Garok.
-- =============================================================================

SM.BattleOfHillsbradData = {
    title = "Battle of Hillsbrad",
    description = "From Tarren Mill, High Executor Darthalia turns Hillsbrad Foothills into a proving ground for the Forsaken war machine. Farmers, peasants, town leaders, miners, and Dun Garok's dwarves all become targets in a campaign meant to break human control of the region.\n\nCarry out Darthalia's orders, then bring her sealed commendation to Varimathras in the Undercity.",
    zone = "Hillsbrad Foothills",
    expansion = "Classic",
    recommendedLevel = { min = 19, max = 32 },
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.54, 0.44, 0.36 },
    icon = 132349,
    portraitDisplayID = 1645,
    adventureCoverTexture = 131867, -- Ruins of Lordaeron battleground loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 527, name = "Battle of Hillsbrad", npc = "High Executor Darthalia", location = "Tarren Mill, Hillsbrad Foothills" },
    startMapID = 25,
    startX = 0.6200,
    startY = 0.1950,

    npcLocations = {
        ["High Executor Darthalia"] = { mapID = 25, x = 0.6200, y = 0.1950, location = "Tarren Mill, Hillsbrad Foothills" },
        ["Deathguard Samsa"] = { mapID = 25, x = 0.6200, y = 0.2000, location = "Tarren Mill, Hillsbrad Foothills" },
        ["WANTED"] = { mapID = 25, x = 0.6250, y = 0.1970, location = "the wanted poster outside the inn in Tarren Mill" },
        ["Varimathras"] = { mapID = 90, x = 0.5600, y = 0.9200, location = "the Royal Quarter, Undercity" },
        ["Hillsbrad Fields"] = { mapID = 25, x = 0.3200, y = 0.4500, location = "Hillsbrad Fields, Hillsbrad Foothills" },
        ["Hillsbrad Town"] = { mapID = 25, x = 0.3100, y = 0.4200, location = "Hillsbrad, Hillsbrad Foothills" },
        ["Azureload Mine"] = { mapID = 25, x = 0.3000, y = 0.5800, location = "Azureload Mine, Hillsbrad Foothills" },
        ["Dun Garok"] = { mapID = 25, x = 0.6900, y = 0.7600, location = "Dun Garok, Hillsbrad Foothills" },
    },

    npcDisplayIDs = {
        ["High Executor Darthalia"] = 1645,
        ["Varimathras"] = 11658,
    },

    chapterDisplayIDs = {
        ["Hillsbrad Fields"] = 1645,
        ["Town and Mine"] = 1645,
        ["Dun Garok"] = 11658,
    },

    chapterIcons = {
        ["Hillsbrad Fields"] = 132349,
        ["Town and Mine"] = 134708,
        ["Dun Garok"] = 132355,
    },

    chapters = {
        {
            chapter = "Hillsbrad Fields",
            summary = "High Executor Darthalia opens the campaign by sending you against Hillsbrad's farms and fleeing peasants.",
            recap = "Darthalia did not dress the campaign in noble language. Varimathras wanted the humans of Hillsbrad removed, and Tarren Mill needed soldiers willing to do the removing. The first raids struck the farms: farmers, farmhands, and landowners first, then peasants fleeing into the fields. The Forsaken were not defending a border here. They were testing how quickly a human town could be made afraid.",
            quests = {
                { id = 527, name = "Battle of Hillsbrad", displayName = "The Northern Farms", npc = "High Executor Darthalia" },
                { id = 528, name = "Battle of Hillsbrad", displayName = "The Peasants", npc = "High Executor Darthalia" },
                { id = 546, name = "Souvenirs of Death", npc = "Deathguard Samsa", optional = true, showIf = 527 },
            },
        },
        {
            chapter = "Town and Mine",
            summary = "The campaign turns from fields to infrastructure: the blacksmith, town hall, registry, and Azureload Mine.",
            recap = "The town did not collapse as quickly as Darthalia expected. Its blacksmith armed the people, its leaders rallied them, and its mine supplied Alliance ore. So the orders became more precise. Verringtan and his apprentices had to die. Magistrate Burnside, the council, the town registry, and the proclamation had to be erased or stolen. Then Azureload Mine had to be taken by killing Foreman Bonds and the miners who still worked there. Hillsbrad was being dismantled piece by piece.",
            quests = {
                { id = 529, name = "Battle of Hillsbrad", displayName = "The Blacksmith", npc = "High Executor Darthalia" },
                { id = 532, name = "Battle of Hillsbrad", displayName = "The Town Hall", npc = "High Executor Darthalia" },
                { id = 567, name = "Dangerous!", npc = "WANTED", optional = true },
                { id = 539, name = "Battle of Hillsbrad", displayName = "Azureload Mine", npc = "High Executor Darthalia" },
            },
        },
        {
            chapter = "Dun Garok",
            summary = "Darthalia's final field order sends you against Dun Garok before she writes a commendation for Varimathras himself.",
            recap = "The last obstacle was not Hillsbrad's farmers or leaders, but the dwarves of Dun Garok. Darthalia sent you into their stronghold to kill mountaineers, riflemen, priests, and Captain Ironhill. When Dun Garok fell, she wrote a sealed commendation and sent it to the Undercity. Varimathras received it as proof that the human problem in Hillsbrad could be solved by force, and that you had become useful to the Dark Lady's war.",
            quests = {
                { id = 541, name = "Battle of Hillsbrad", displayName = "Dun Garok", npc = "High Executor Darthalia" },
                { id = 550, name = "Battle of Hillsbrad", displayName = "Darthalia's Commendation", npc = "High Executor Darthalia" },
            },
        },
    },
}
