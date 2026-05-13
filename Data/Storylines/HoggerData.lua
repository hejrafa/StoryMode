local addonName, SM = ...

-- =============================================================================
-- Classic: Hogger
-- A short Alliance Elwynn story around Classic's earliest infamous elite.
-- =============================================================================

SM.HoggerData = {
    title = "Hogger",
    description = "The wanted poster outside Westbrook Garrison looks almost routine: a huge Riverpaw gnoll is prowling the woods, the Stormwind Army has posted a bounty, and Marshal Dughan wants proof.\n\nThen you follow the road southwest, step into Hogger's camp, and learn why one low-level elite became a Classic legend.",
    zone = "Elwynn Forest",
    expansion = "Classic",
    recommendedLevel = { min = 5, max = 11 },
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.78, 0.55, 0.28 },
    icon = "Interface\\Icons\\INV_Misc_MonsterClaw_04",
    portraitDisplayID = 384,
    adventureCoverTexture = 131833, -- Deadmines: closest Classic loading screen for Elwynn's Westfall border
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 176, name = "Wanted: \"Hogger\"", npc = "Wanted Poster", location = "Westbrook Garrison, Elwynn Forest" },
    startMapID = 37,
    startX = 0.2470,
    startY = 0.7900,

    npcLocations = {
        ["Wanted Poster"] = { mapID = 37, x = 0.2470, y = 0.7900, location = "Westbrook Garrison, Elwynn Forest" },
        ["Hogger"] = { mapID = 37, x = 0.2590, y = 0.8840, location = "Forest's Edge, Elwynn Forest" },
        ["Marshal Dughan"] = { mapID = 37, x = 0.4210, y = 0.6590, location = "Goldshire, Elwynn Forest" },
    },

    npcDisplayIDs = {
        ["Hogger"] = 384,
        ["Marshal Dughan"] = 1985,
    },

    chapterDisplayIDs = {
        ["The Scourge of Elwynn"] = 384,
    },

    chapterIcons = {
        ["The Scourge of Elwynn"] = "Interface\\Icons\\INV_Misc_MonsterClaw_04",
    },

    chapters = {
        {
            chapter = "The Scourge of Elwynn",
            summary = "A wanted poster outside Westbrook Garrison sends you after Hogger, the Riverpaw gnoll terrorizing southwestern Elwynn. Bring his huge claw back to Marshal Dughan in Goldshire.",
            recap = "Hogger's bounty was small on paper: read the poster at Westbrook Garrison, walk into the Riverpaw camps at Forest's Edge, bring back one huge claw. In practice, it became one of the Alliance's earliest rites of passage. Hogger was only a gnoll in southwestern Elwynn, but he hit hard, stood among friends, and taught new humans that some wanted posters were really invitations to find a party. When Marshal Dughan took the claw in Goldshire, the road to Westfall felt a little less safe and a little more like Classic.",
            quests = {
                { id = 176, name = "Wanted: \"Hogger\"", npc = "Wanted Poster" },
            },
        },
    },
}
