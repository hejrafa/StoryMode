local addonName, SM = ...

-- =============================================================================
-- Classic: A New Plague
-- The Royal Apothecary Society's early plague research, from Brill to Hillsbrad.
-- =============================================================================

SM.ANewPlagueData = {
    title = "A New Plague",
    description = "Apothecary Johaan has work in Brill, and it is not the sort of work the living would approve of. The Forsaken need samples, records, and willing hands if they are to learn what can still kill the dead.\n\nBegin with the Royal Apothecary Society's errands in Tirisfal and follow the plague work into Silverpine and Hillsbrad. Each vial answers one question and raises another.",
    zone = "Tirisfal Glades / Silverpine Forest / Hillsbrad Foothills",
    expansion = "Classic",
    recommendedLevel = { min = 6, max = 32 },
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.45, 0.72, 0.36 },
    icon = 136066,
    portraitDisplayID = 1565,
    adventureCoverTexture = 6514589, -- Karazhan Crypts loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 367, name = "A New Plague", npc = "Apothecary Johaan", location = "Gallows' End Tavern, Brill" },
    startMapID = 18,
    startX = 0.5945,
    startY = 0.5240,

    npcLocations = {
        ["Apothecary Johaan"] = { mapID = 18, x = 0.5945, y = 0.5240, location = "Gallows' End Tavern, Brill" },
        ["Captured Mountaineer"] = { mapID = 18, x = 0.5900, y = 0.5200, location = "cellar of Gallows' End Tavern, Brill" },
        ["Apothecary Renferrel"] = { mapID = 21, x = 0.4290, y = 0.4090, location = "the Sepulcher, Silverpine Forest" },
        ["Master Apothecary Faranell"] = { mapID = 90, x = 0.4800, y = 0.6900, location = "the Apothecarium, Undercity" },
        ["Apothecary Lydon"] = { mapID = 25, x = 0.6160, y = 0.1900, location = "Tarren Mill, Hillsbrad Foothills" },
        ["Umpi"] = { mapID = 25, x = 0.6160, y = 0.1900, location = "Apothecary Lydon's room, Tarren Mill" },
        ["Stanley"] = { mapID = 25, x = 0.3200, y = 0.3500, location = "the northern farm in Hillsbrad Fields" },
        ["Berard's Journal"] = { mapID = 21, x = 0.4300, y = 0.7300, location = "Pyrewood Village Inn, Silverpine Forest" },
        ["Nethander Stead"] = { mapID = 25, x = 0.6400, y = 0.6200, location = "Nethander Stead, Hillsbrad Foothills" },
        ["Dun Garok"] = { mapID = 25, x = 0.7100, y = 0.8000, location = "Dun Garok, southeastern Hillsbrad Foothills" },
        ["Dusty Rug"] = { mapID = 25, x = 0.6200, y = 0.1800, location = "upstairs in the Tarren Mill inn" },
    },

    npcDisplayIDs = {
        ["Apothecary Johaan"] = 1565,
        ["Apothecary Renferrel"] = 1661,
        ["Master Apothecary Faranell"] = 1680,
        ["Apothecary Lydon"] = 1660,
        ["Umpi"] = 901,
        ["Stanley"] = 855,
        ["Captured Mountaineer"] = 11426,
    },

    chapterDisplayIDs = {
        ["Johaan's Formula"] = 1565,
        ["A Recipe for Death"] = 1661,
        ["Tarren Mill Trials"] = 1660,
        ["Plagued Brew"] = 1660,
    },

    chapterIcons = {
        ["Johaan's Formula"] = 136066,
        ["A Recipe for Death"] = 134941,
        ["Tarren Mill Trials"] = 136067,
        ["Plagued Brew"] = 132792,
    },

    chapters = {
        {
            chapter = "Johaan's Formula",
            summary = "Apothecary Johaan gathers blood, scales, and venom around Brill, then tests his first drink on a captive mountaineer.",
            recap = "The Royal Apothecary Society's work began in Brill with a simple promise from Sylvanas: make a plague deadly enough to ruin Arthas. Johaan started like a scientist with no patience for ethics, moving from darkhound blood to murloc scales and spider venom. Once the mixture was ready, theory became practice in the Gallows' End cellar. A captured mountaineer drank the first dose, and the Forsaken plague stopped being an idea.",
            quests = {
                { id = 367, name = "A New Plague", displayName = "Darkhound Blood", npc = "Apothecary Johaan" },
                { id = 368, name = "A New Plague", displayName = "Vile Fin Scales", npc = "Apothecary Johaan" },
                { id = 369, name = "A New Plague", displayName = "Night Web Venom", npc = "Apothecary Johaan" },
                { id = 492, name = "A New Plague", displayName = "Johaan's Special Drink", npc = "Apothecary Johaan" },
                { id = 445, name = "Delivery to Silverpine Forest", npc = "Apothecary Johaan" },
            },
        },
        {
            chapter = "A Recipe for Death",
            summary = "Renferrel carries Johaan's work into Silverpine, where Berard's lost research and Faranell's Undercity lab push the recipe forward.",
            recap = "Silverpine turned Johaan's notes into something larger. Apothecary Renferrel gathered spider blood and bear hearts for Faranell, then sent you into cursed Pyrewood Village to recover Berard's journal before Arugal's magic swallowed the research for good. The journal pointed back to Lake Lordamere, where dead murloc tumors and lake-creature moss preserved clues from an older plague. By the time Faranell had the samples, the Society was no longer improvising. It had a recipe.",
            quests = {
                { id = 447, name = "A Recipe For Death", npc = "Apothecary Renferrel" },
                { id = 450, name = "A Recipe For Death", displayName = "Berard's Journal", npc = "Master Apothecary Faranell" },
                { id = 451, name = "A Recipe For Death", displayName = "Lake Lordamere Samples", npc = "Apothecary Renferrel" },
            },
        },
        {
            chapter = "Tarren Mill Trials",
            summary = "In Hillsbrad, Apothecary Lydon turns plague research into local experiments on Umpi and Stanley.",
            recap = "Tarren Mill made the plague feel intimate and ugly. Lydon hated the living world with theatrical cheer, but his work was practical: collect tongues, ichor, and mountain lion blood, brew the agents, and see what happens. Umpi received the Elixir of Suffering. Stanley, Farmer Ray's dog, received the Elixir of Pain and changed violently enough to prove the mixture worked. The tests were small, but the intent was enormous.",
            quests = {
                { id = 496, name = "Elixir of Suffering", npc = "Apothecary Lydon" },
                { id = 499, name = "Elixir of Suffering", displayName = "Umpi", npc = "Apothecary Lydon" },
                { id = 501, name = "Elixir of Pain", npc = "Apothecary Lydon" },
                { id = 502, name = "Elixir of Pain", displayName = "Stanley", npc = "Apothecary Lydon" },
            },
        },
        {
            chapter = "Plagued Brew",
            summary = "Lydon's final elixir moves through Faranell's lab, Dun Garok's stolen stout, and a room of captured farmers.",
            recap = "The Elixir of Agony chain was Lydon at his most gleeful. Mudsnout blossoms became a composite; Faranell added decay; Lydon activated the mixture with troll blood, murloc eyes, and naga scales. Then came the delivery system: stolen dwarven stout from Dun Garok. The finished keg went upstairs in the Tarren Mill inn, where captured farmers became the last proof that the Forsaken could turn ordinary hospitality into a weapon.",
            quests = {
                { id = 509, name = "Elixir of Agony", displayName = "Mudsnout Blossoms", npc = "Apothecary Lydon" },
                { id = 513, name = "Elixir of Agony", displayName = "Mudsnout Composite", npc = "Apothecary Lydon" },
                { id = 515, name = "Elixir of Agony", displayName = "Faranell's Mixture", npc = "Master Apothecary Faranell" },
                { id = 517, name = "Elixir of Agony", displayName = "Shindigger Stout", npc = "Apothecary Lydon" },
                { id = 524, name = "Elixir of Agony", displayName = "Tainted Keg", npc = "Apothecary Lydon" },
            },
        },
    },
}
