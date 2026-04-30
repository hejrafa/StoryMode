local addonName, SM = ...

-- =============================================================================
-- Classic: Mankrik's Wife
-- A short Barrens story with one of Classic's most remembered quest texts.
-- =============================================================================

SM.MankriksWifeData = {
    title = "Mankrik's Wife",
    description = "At the Crossroads, Mankrik asks every passing adventurer the same desperate question: have you seen his wife? Somewhere on the Gold Road, between quillboar camps and the wide heat of the Barrens, a small domestic story has already turned into grief.\n\nFind what happened to Olgra, and carry the truth back to the husband still waiting for her.",
    zone = "The Barrens",
    expansion = "Classic",
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.72, 0.52, 0.24 },
    icon = 133469,
    portraitDisplayID = 3773,

    startQuest = { id = 4921, name = "Lost in Battle", npc = "Mankrik", location = "the Crossroads, The Barrens" },
    startMapID = 10,
    startX = 0.5520,
    startY = 0.4100,

    npcLocations = {
        ["Mankrik"] = { mapID = 10, x = 0.5520, y = 0.4100, location = "the Crossroads, The Barrens" },
    },

    npcDisplayIDs = {
        ["Mankrik"] = 3855,
    },

    chapterDisplayIDs = {
        ["Lost in Battle"] = 3773,
    },

    chapterIcons = {
        ["Lost in Battle"] = 133469,
    },

    chapters = {
        {
            chapter = "Lost in Battle",
            summary = "Mankrik survived a quillboar attack on the Gold Road. His wife, Olgra, did not return with him. He asks you to search the road south of the Crossroads for any sign of her.",
            recap = "Mankrik's request was plain enough to become famous: find his wife. The Barrens was enormous, the directions were thin, and the road south of the Crossroads was full of danger. When you found Olgra's body, the search stopped being a joke about getting lost in a huge zone. It became one of Classic's smallest, sharpest losses: a husband waiting in the dust for news that could only hurt him.",
            quests = {
                { id = 4921, name = "Lost in Battle", npc = "Mankrik" },
            },
        },
    },
}
