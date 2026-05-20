local addonName, SM = ...

-- =============================================================================
-- Classic: Cortello's Riddle
-- A pirate-ship scroll that turns into a three-zone treasure hunt.
-- =============================================================================

SM.CortellosRiddleData = {
    title = "Cortello's Riddle",
    description = "A small scroll waits aboard a Bloodsail ship south of Booty Bay. It gives no proper quest giver, only a riddle and enough direction to make you wonder what was hidden.\n\nTake Cortello's words seriously and follow the clues wherever they send you. The treasure is not marked for anyone who wants a straight road.",
    zone = "Stranglethorn Vale / Swamp of Sorrows / Dustwallow Marsh / The Hinterlands",
    expansion = "Classic",
    recommendedLevel = { min = 43, max = 51 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.29, 0.54, 0.63 },
    icon = 134331,
    adventureCoverTexture = 6213071, -- Tainted Scar loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 624, name = "Cortello's Riddle", npc = "Cortello's Riddle", location = "the Bloodsail ships off the Wild Shore, Stranglethorn Vale" },
    startMapID = 50,
    startX = 0.3000,
    startY = 0.8900,

    npcLocations = {
        ["Cortello's Riddle"] = { mapID = 50, x = 0.3000, y = 0.8900, location = "the Bloodsail ships off the Wild Shore, Stranglethorn Vale" },
        ["A Soggy Scroll"] = { mapID = 51, x = 0.2200, y = 0.4800, location = "under the first wooden bridge west of Stonard, Swamp of Sorrows" },
        ["Cortello's Treasure"] = { mapID = 26, x = 0.8100, y = 0.4700, location = "under the great eastern waterfall, The Hinterlands" },
    },

    chapterIcons = {
        ["The Soggy Scroll"] = 134331,
        ["Bloodfen Burrow"] = 134939,
        ["Under the Great Falls"] = 133634,
    },

    chapters = {
        {
            chapter = "The Soggy Scroll",
            summary = "Cortello's first riddle begins on a Bloodsail ship and points to an ornate bridge in the Swamp of Sorrows.",
            recap = "Cortello's Riddle began like a secret the world forgot to announce. The scroll was not handed to you by an NPC; it waited in the belly of a pirate ship, daring you to notice it between Bloodsail patrols. Its first clue sent you east of Deadwind and south of Redridge, under a bridge in the Swamp of Sorrows, where the next scrap of the trail was half-buried in the mud.",
            quests = {
                { id = 624, name = "Cortello's Riddle", npc = "Cortello's Riddle" },
            },
        },
        {
            chapter = "Bloodfen Burrow",
            summary = "The soggy clue sends you across the sea to Dustwallow Marsh, where the next scroll waits in a raptor cave.",
            recap = "The second clue widened the joke into a journey. Kalimdor was waiting, and the destination was not a city or a famous ruin but a cave in Dustwallow Marsh guarded by Bloodfen raptors. That was Cortello's charm: each answer was simple once solved, but the act of following it made old Azeroth feel enormous, connected by scraps of verse and stubborn curiosity.",
            quests = {
                { id = 625, name = "Cortello's Riddle", npc = "A Soggy Scroll" },
            },
        },
        {
            chapter = "Under the Great Falls",
            summary = "The musty scroll sends you back to Lordaeron, to the coast of the Hinterlands and a treasure chest beneath the waterfall.",
            recap = "The final riddle turned the road back across the world. The Hinterlands held the answer at the base of its great eastern falls, underwater and just awkward enough to feel earned. After pirates, mud, raptors, and a long ride through dangerous country, Cortello's treasure was not a weapon of legend. It was a backpack. Somehow, that made it more Classic: practical, odd, and completely worth the detour.",
            quests = {
                { id = 626, name = "Cortello's Riddle", npc = "Musty Scroll", mapID = 70, x = 0.3100, y = 0.6600, location = "Bloodfen Burrow, southwestern Dustwallow Marsh" },
            },
        },
    },
}
