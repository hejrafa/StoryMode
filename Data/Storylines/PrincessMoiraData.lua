local addonName, SM = ...

-- =============================================================================
-- Classic: Princess Moira
-- Ironforge, Thrall, and the succession crisis hidden in Blackrock Depths.
-- =============================================================================

SM.PrincessMoiraData = {
    title = "The Princess of Ironforge",
    description = "Princess Moira Bronzebeard vanished into Blackrock Depths, and both Ironforge and Orgrimmar read danger in the same name: Emperor Dagran Thaurissan. To Magni, she is a daughter to be rescued. To Thrall, she is a political crisis that could place a Dark Iron heir inside Ironforge itself.\n\nFollow the Blackrock Depths chains that turn a dungeon rescue into one of Classic's sharpest succession stories.",
    zone = "Blackrock Depths / Ironforge / Orgrimmar",
    expansion = "Classic",
    recommendedLevel = { min = 48, max = 60 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.76, 0.48, 0.28 },
    icon = 133416,
    portraitDisplayID = 8705,
    adventureGuideInstanceName = "Blackrock Depths",
    adventureCoverTexture = 131824,
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 3702, name = "The Smoldering Ruins of Thaurissan", npc = "Royal Historian Archesonus", location = "Ironforge", faction = "Alliance" },
    startMapID = 87,
    startX = 0.3900,
    startY = 0.5600,

    npcLocations = {
        ["King Magni Bronzebeard"] = { mapID = 87, x = 0.3900, y = 0.5600, location = "the High Seat, Ironforge" },
        ["Royal Historian Archesonus"] = { mapID = 87, x = 0.3800, y = 0.5500, location = "the High Seat, Ironforge" },
        ["Kharan Mighthammer"] = { mapID = 242, x = 0.4500, y = 0.6300, location = "the Detention Block, Blackrock Depths" },
        ["Princess Moira Bronzebeard"] = { mapID = 242, x = 0.5900, y = 0.2300, location = "the Imperial Seat, Blackrock Depths" },
        ["Galamav the Marksman"] = { mapID = 15, x = 0.0500, y = 0.4700, location = "Kargath, Badlands" },
        ["Commander Gor'shak"] = { mapID = 242, x = 0.4500, y = 0.6300, location = "the Detention Block, Blackrock Depths" },
        ["Thrall"] = { mapID = 85, x = 0.3200, y = 0.3800, location = "Grommash Hold, Orgrimmar" },
    },

    npcDisplayIDs = {
        ["King Magni Bronzebeard"] = 3597,
        ["Royal Historian Archesonus"] = 8171,
        ["Kharan Mighthammer"] = 8708,
        ["Princess Moira Bronzebeard"] = 8705,
        ["Galamav the Marksman"] = 8334,
        ["Commander Gor'shak"] = 8703,
        ["Thrall"] = 4527,
    },

    chapterDisplayIDs = {
        ["Kharan's Tale"] = 8708,
        ["The Royal Rescue"] = 8705,
        ["The Warchief's Rescue"] = 4527,
    },

    chapterIcons = {
        ["Kharan's Tale"] = 133739,
        ["The Royal Rescue"] = 133416,
        ["The Warchief's Rescue"] = 132349,
    },

    chapters = {
        {
            chapter = "Kharan's Tale",
            faction = "Alliance",
            summary = "Ironforge's historians point back to old Thaurissan, then Magni sends you into Blackrock Depths to find Kharan Mighthammer, the guard who knows what happened to Princess Moira.",
            recap = "The story began before Moira's disappearance, in the ruins left by the first Thaurissan and the War of the Three Hammers. Ironforge's old wound led straight into Blackrock Depths, where Kharan Mighthammer's prison cell held the news Magni did not want to hear. Moira was in the heart of the Dark Iron kingdom, and the rescue he wanted was already tangled in questions of love, control, succession, and inherited hatred.",
            quests = {
                { id = 3702, name = "The Smoldering Ruins of Thaurissan", npc = "Royal Historian Archesonus" },
                { id = 3701, name = "The Smoldering Ruins of Thaurissan", displayName = "Burning Steppes", npc = "Royal Historian Archesonus" },
                { id = 4341, name = "Kharan Mighthammer", npc = "King Magni Bronzebeard" },
                { id = 4342, name = "Kharan's Tale", npc = "Kharan Mighthammer" },
                { id = 4361, name = "The Bearer of Bad News", npc = "Kharan Mighthammer" },
            },
        },
        {
            chapter = "The Royal Rescue",
            faction = "Alliance",
            summary = "Magni orders a rescue. Emperor Thaurissan must die, but Moira must survive.",
            recap = "The order sounded simple because grief needed it to be simple: kill Thaurissan, spare Moira, bring the princess home. Blackrock Depths answered with something crueler. When the emperor fell, Moira did not thank her rescuers. She mourned her husband, named her unborn child heir to Ironforge, and sent Magni a future he could not command away.",
            quests = {
                { id = 4362, name = "The Fate of the Kingdom", npc = "King Magni Bronzebeard" },
                { id = 4363, name = "The Princess's Surprise", npc = "Princess Moira Bronzebeard" },
            },
        },
        {
            chapter = "The Warchief's Rescue",
            faction = "Horde",
            summary = "A message from Commander Gor'shak pulls the Horde into Blackrock Depths. Thrall sees Moira's captivity as a threat to the balance of the Eastern Kingdoms.",
            recap = "The Horde path entered the same crisis through a different door: a commander in chains, a prisoner with information, and Thrall reading the politics beneath the dungeon walls. Freeing Moira was not mercy alone. It was strategy. If a Dark Iron child could inherit Ironforge, then Blackrock Depths was not only a prison. It was a future capital waiting in the dark.",
            quests = {
                { id = 3981, name = "Commander Gor'shak", npc = "Galamav the Marksman" },
                { id = 3982, name = "What Is Going On?", npc = "Commander Gor'shak" },
                { id = 4001, name = "What Is Going On?", npc = "Commander Gor'shak" },
                { id = 4002, name = "The Eastern Kingdoms", npc = "Thrall" },
                { id = 4003, name = "The Royal Rescue", npc = "Thrall" },
                { id = 4004, name = "The Princess Saved?", npc = "Princess Moira Bronzebeard" },
            },
        },
    },
}
