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
    icon = "Interface\\Icons\\inv_misc_tabard_gilneas",
    startQuest = { id = 54976, name = "The Shadow of Gilneas", npc = "Courier Claridge", location = "Stormwind Embassy" },
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
