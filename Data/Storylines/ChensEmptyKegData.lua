local addonName, SM = ...

-- =============================================================================
-- Classic: Chen's Empty Keg
-- A stray Barrens keg, a Ratchet brewmaster, and an early Chen Stormstout wink.
-- =============================================================================

SM.ChensEmptyKegData = {
    title = "Chen's Empty Keg",
    description = "Somewhere in the Barrens, an abandoned keg carries a small placard with a name that will matter much more later: Chen Stormstout.\n\nBring the keg to Ratchet, help Brewmaster Drohn chase the memory of Stormstout, and turn a random roadside find into one of Classic's strangest little pieces of Pandaren foreshadowing.",
    zone = "The Barrens",
    expansion = "Classic",
    recommendedLevel = { min = 15, max = 24 },
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.78, 0.50, 0.23 },
    icon = 132792,
    adventureCoverTexture = 131864, -- Razorfen Downs: Barrens-adjacent quilboar loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 819, name = "Chen's Empty Keg", npc = "Chen's Empty Keg", location = "one of several keg spawns around The Barrens" },
    startMapID = 10,
    startX = 0.5600,
    startY = 0.2000,

    npcLocations = {
        ["Chen's Empty Keg"] = { mapID = 10, x = 0.5600, y = 0.2000, location = "one of several keg spawns around The Barrens, including near Grol'dom Farm" },
        ["Brewmaster Drohn"] = { mapID = 10, x = 0.6226, y = 0.3839, location = "Ratchet, The Barrens" },
    },

    npcDisplayIDs = {
        ["Brewmaster Drohn"] = 3851,
    },

    chapterDisplayIDs = {
        ["Stormstout Ingredients"] = 3851,
    },

    chapterIcons = {
        ["A Keg in the Barrens"] = 132623, -- Chen's Empty Keg item icon
        ["Stormstout Ingredients"] = 132799,
    },

    chapters = {
        {
            chapter = "A Keg in the Barrens",
            summary = "A lost keg in the Barrens points to Chen Stormstout. Brewmaster Drohn in Ratchet recognizes the name and the recipe it implies.",
            recap = "The keg looked like another bit of Barrens clutter until its placard named Chen Stormstout. Drohn understood what that meant: Chen had traveled with Rexxar, left a brewing legacy behind, and somehow one of his kegs had ended up in the dust. Before Pandaria was a continent players could visit, Classic let the name sit there like a rumor with a tap on it.",
            quests = {
                { id = 819, name = "Chen's Empty Keg", npc = "Chen's Empty Keg" },
            },
        },
        {
            chapter = "Stormstout Ingredients",
            summary = "Drohn tries to recreate Chen's work with Barrens ingredients: lion tusks, plainstrider kidneys, thunder lizard horns, and the stronger stuff behind trogg brew.",
            recap = "Drohn's nostalgia turned into a shopping list only Classic could love. Lions, plainstriders, thunder lizards, stormhides, thunderhawks, and kodos all became part of the attempt to make something worthy of Chen's old recipe. It was not a grand adventure, exactly. It was a messy little errand that made the Barrens feel older and stranger than it looked, as if even a keg by the roadside could have crossed half a legend before you found it.",
            quests = {
                { id = 821, name = "Chen's Empty Keg", npc = "Brewmaster Drohn" },
                { id = 822, name = "Chen's Empty Keg", npc = "Brewmaster Drohn", optional = true },
            },
        },
    },
}
