local addonName, SM = ...

-- =============================================================================
-- Classic: Raene's Cleansing
-- Astranaar, Dartol's Rod, and the corrupted furbolg of Ashenvale.
-- =============================================================================

SM.RaenesCleansingData = {
    title = "Raene's Cleansing",
    description = "In Astranaar, Raene Wolfrunner sends you west after Teronis, a missing friend who was searching for a way to slow the furbolg attacks. His death leaves behind a journal, a gem, and the unfinished work of Dartol's Rod.\n\nRebuild the rod, speak to one of the last uncorrupted furbolg, and bring down Ran Bloodtooth before Ashenvale's corruption swallows more than the forest.",
    zone = "Ashenvale",
    expansion = "Classic",
    recommendedLevel = { min = 18, max = 30 },
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.42, 0.58, 0.36 },
    icon = 135139,
    portraitDisplayID = 1980,
    adventureCoverTexture = 131878, -- Blackfathom Deeps loading screen; closest Ashenvale/Night Elf ruin art
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 991, name = "Finding Teronis", npc = "Raene Wolfrunner", location = "Astranaar, Ashenvale" },
    startMapID = 63,
    startX = 0.3620,
    startY = 0.4980,

    npcLocations = {
        ["Raene Wolfrunner"] = { mapID = 63, x = 0.3620, y = 0.4980, location = "Astranaar, Ashenvale" },
        ["Teronis' Corpse"] = { mapID = 63, x = 0.2020, y = 0.4250, location = "Lake Falathim, Ashenvale" },
        ["Shael'dryn"] = { mapID = 63, x = 0.5900, y = 0.5960, location = "the moonwell east of Iris Lake, Ashenvale" },
        ["Hidden Shrine"] = { mapID = 63, x = 0.5600, y = 0.4900, location = "the hidden shrine southeast of Shael'dryn" },
        ["Krolg"] = { mapID = 63, x = 0.5000, y = 0.3900, location = "southeast of Mystral Lake, Ashenvale" },
        ["Ran Bloodtooth"] = { mapID = 63, x = 0.5200, y = 0.3800, location = "the furbolg camp near Mystral Lake, Ashenvale" },
    },

    npcDisplayIDs = {
        ["Raene Wolfrunner"] = 1980,
        ["Shael'dryn"] = 2721,
        ["Krolg"] = 1010,
        ["Ran Bloodtooth"] = 1012,
    },

    chapterDisplayIDs = {
        ["Teronis' Journal"] = 1980,
        ["Dartol's Rod"] = 2721,
        ["The Uncorrupted Furbolg"] = 1010,
    },

    chapterIcons = {
        ["Teronis' Journal"] = 133741,
        ["Dartol's Rod"] = 135139,
        ["The Uncorrupted Furbolg"] = 132183,
    },

    chapters = {
        {
            chapter = "Teronis' Journal",
            summary = "Raene sends you to find Teronis near Lake Falathim. His body and journal turn a missing-person search into a mission to finish his work.",
            recap = "Raene Wolfrunner feared for Teronis, and Ashenvale answered with a corpse. The murlocs near Lake Falathim had killed him, but his journal survived, along with the trail to a glowing gem. Returning both to Astranaar changed the task. Teronis had died looking for a way to slow the furbolg attacks, and Raene asked you to carry that hope forward.",
            quests = {
                { id = 991, name = "Finding Teronis", displayName = "Find Teronis", npc = "Raene Wolfrunner" },
                { id = 1023, name = "The Lost Gem", displayName = "Teronis' Journal", npc = "Teronis' Corpse" },
                { id = 1024, name = "Dryad Delivery", displayName = "Find Shael'dryn", npc = "Raene Wolfrunner" },
            },
        },
        {
            chapter = "Dartol's Rod",
            summary = "Shael'dryn guides you through treants, Dor'danil, and a hidden shrine to rebuild and empower Dartol's Rod of Transformation.",
            recap = "Shael'dryn knew what Teronis had been chasing: Dartol's Rod, broken into pieces and hidden across Ashenvale's corrupted places. The iron shaft lay behind a key carried by twisted treants near Felwood. The iron pommel had passed through Dor'danil's dead and into the slime. When the rod was remade, a hidden shrine gave it power again. By then, Teronis' errand had become something stranger: not a weapon, but a way to speak across the line between the uncorrupted and the lost.",
            quests = {
                { id = 1026, name = "Search the Bole", displayName = "Iron Shaft", npc = "Shael'dryn" },
                { id = 1027, name = "Playing Possum", displayName = "Iron Pommel", npc = "Shael'dryn" },
                { id = 1028, name = "Raene's Cleansing", displayName = "Hidden Shrine", npc = "Shael'dryn" },
                { id = 1029, name = "Return to Raene", displayName = "Return to Raene", npc = "Shael'dryn" },
            },
        },
        {
            chapter = "The Uncorrupted Furbolg",
            summary = "Dartol's Rod lets you approach Krolg, who sends you against Ran Bloodtooth and the corrupted furbolg threatening Ashenvale.",
            recap = "The rod transformed more than your shape. It let you approach Krolg, an uncorrupted furbolg who still carried grief and anger for what had happened to his people. Krolg blamed the night elves, but he also knew Ran Bloodtooth had become a threat no one could ignore. Killing Ran and his guards did not cleanse Ashenvale, but it proved Teronis had not died for nothing. Raene kept the skull and the rod as proof that the forest could still be defended.",
            quests = {
                { id = 1030, name = "Dartol's Rod", displayName = "Find Krolg", npc = "Raene Wolfrunner" },
                { id = 1045, name = "A New Adornment", displayName = "Ran Bloodtooth", npc = "Krolg" },
                { id = 1046, name = "True Power of the Rod", displayName = "Return to Raene", npc = "Krolg" },
            },
        },
    },
}
