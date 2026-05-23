local addonName, SM = ...

-- =============================================================================
-- Classic: Poor Old Blanchy
-- A short Alliance Westfall story around the Furlbrows' tired horse.
-- =============================================================================

SM.PoorOldBlanchyData = {
    title = "Poor Old Blanchy",
    description = "Verna Furlbrow and her husband left their farm in a hurry, only for their wagon to break near the road into Westfall. Their old horse, Blanchy, has carried more than her share already.\n\nGather what oats you can from the nearby farms. It is a small kindness, but on a hard road even that can matter.",
    zone = "Westfall",
    expansion = "Classic",
    recommendedLevel = { min = 9, max = 14 },
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.74, 0.55, 0.32 },
    icon = "Interface\\Icons\\INV_Misc_Food_Wheat_02",
    adventureCoverTexture = 131833, -- Deadmines: closest Classic loading screen for Westfall.
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 151, name = "Poor Old Blanchy", npc = "Verna Furlbrow", location = "Jansen Stead, Westfall" },
    startMapID = 52,
    startX = 0.5990,
    startY = 0.1940,

    npcLocations = {
        ["Verna Furlbrow"] = { mapID = 52, x = 0.5990, y = 0.1940, location = "Jansen Stead, Westfall" },
        ["Old Blanchy"] = { mapID = 52, x = 0.5980, y = 0.1910, location = "Jansen Stead, Westfall" },
    },

    chapterIcons = {
        ["A Few Handfuls of Oats"] = "Interface\\Icons\\INV_Misc_Food_Wheat_02",
    },

    chapters = {
        {
            chapter = "A Few Handfuls of Oats",
            summary = "Gather oats from the farms of Westfall and bring them back to Verna Furlbrow for Old Blanchy.",
            recap = "The Furlbrows had fled their farm with little more than a broken wagon and a hungry old horse. Eight handfuls of oats were not much against the trouble in Westfall, but for Blanchy and the people still trying to leave, it was enough to make the road feel possible again.",
            quests = {
                { id = 151, name = "Poor Old Blanchy", npc = "Verna Furlbrow" },
            },
        },
    },
}
