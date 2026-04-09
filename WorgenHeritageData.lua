local addonName, SM = ...

SM.WorgenHeritageData = {
    title = "Heritage of Gilneas",
    description = "Answer Tess Greymane's call, hunt the Nightbane through Duskwood and the Emerald Dream's shadows, and uphold Gilnean tradition.",
    zone = "Stormwind / Duskwood / Emerald Dream (phased)",
    expansion = "Battle for Azeroth",
    faction = "Alliance",
    race = "Worgen",
    requiredLevel = 50,
    achievementName = "Heritage of Gilneas",
    color = { 0.37, 0.43, 0.56 },
    icon = "Interface\\Icons\\inv_helm_armor_worgen_c_01",
    startQuest = { id = 54976, name = "The Shadow of Gilneas", npc = "Courier Claridge", location = "Stormwind Embassy" },
    npcLocations = {
        ["Courier Claridge"] = { mapID = 84, x = 0.5220, y = 0.1350 }, -- Stormwind Embassy
        ["Mia Greymane"] = { mapID = 84, x = 0.7920, y = 0.3850 }, -- Stormwind Keep (approx)
        ["Vassandra Stormclaw"] = { mapID = 47, x = 0.7400, y = 0.4680 }, -- Duskwood (approx)
        ["Princess Tess Greymane"] = { mapID = 84, x = 0.7920, y = 0.3850 }, -- Stormwind Keep (approx)
    },
    chapterIcons = {
        ["Heritage of Gilneas"] = "Interface\\Icons\\inv_helm_armor_worgen_c_01",
    },
    chapterDisplayIDs = {
        ["Heritage of Gilneas"] = 90670,
    },
    chapters = {
        {
            chapter = "Heritage of Gilneas",
            summary = "Stand with Tess and the Gilneans to face the Nightbane and reaffirm your people's resolve.",
            recap = "Gilneas survived exile through loyalty, discipline, and the will to endure. By facing the darkness within and without, you helped carry that legacy forward.",
            quests = {
                { id = 54976, name = "The Shadow of Gilneas", npc = "Courier Claridge" },
                { id = 54977, name = "Into Duskwood", npc = "Mia Greymane" },
                { id = 54980, name = "Bane of the Nightbane", npc = "Vassandra Stormclaw" },
                { id = 54981, name = "Cry to the Moon", npc = "Vassandra Stormclaw" },
                { id = 54982, name = "The Spirit of the Hunter", npc = "Vassandra Stormclaw" },
                { id = 54983, name = "Waking a Dreamer", npc = "Vassandra Stormclaw" },
                { id = 54984, name = "Let Sleeping Wolves Lie", npc = "Goldrinn" },
                { id = 54990, name = "The New Guard", npc = "Princess Tess Greymane" },
            },
        },
    },
}

return SM
