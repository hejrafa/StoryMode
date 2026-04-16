local addonName, SM = ...

SM.PandarenHeritageData = {
    title = "Pandaren Heritage",
    description = "Follow old friends across Pandaria and rediscover the stories, values, and spirit that shaped the Wandering Isle.",
    zone = "Pandaria / Wandering Isle",
    expansion = "The War Within",
    race = "Pandaren",
    requiredLevel = 50,
    achievementName = "Heritage of the Wandering Isle",
    achievements = {},
    color = { 0.71, 0.31, 0.28 },
    icon = 630617,
    -- Faction-specific openers exist; this serves as a consistent StoryMode entry anchor.
    startQuest = { id = 84442, name = "Invitation to the Spirit Festival", npc = "Automatic / Ji Firepaw", location = "Stormwind or Orgrimmar Embassy" },
    npcLocations = {
        ["Ji Firepaw"] = { mapID = 85, x = 0.3920, y = 0.8110 }, -- Orgrimmar Embassy (approx)
        ["Aysa Cloudsinger"] = { mapID = 84, x = 0.5180, y = 0.1360 }, -- Stormwind Embassy (approx)
        ["Li Li Stormstout"] = { mapID = 376, x = 0.5580, y = 0.5830 }, -- Valley of the Four Winds (approx)
        ["Chen Stormstout"] = { mapID = 376, x = 0.5570, y = 0.5820 }, -- Valley of the Four Winds (approx)
        ["Lorewalker Cho"] = { mapID = 376, x = 0.8380, y = 0.3240 }, -- Seat of Knowledge (approx)
    },
    chapterDisplayIDs = {
        ["Heritage of the Wandering Isle"] = 40962,
    },
    chapterIcons = {
        ["Heritage of the Wandering Isle"] = 40962,
    },
    chapters = {
        {
            chapter = "Heritage of the Wandering Isle",
            summary = "Take part in the Spirit Festival and walk both Tushui and Huojin threads of pandaren heritage.",
            recap = "Pandaren heritage lives in stories carried by many voices. Through festival rites, old memories, and shared traditions, you helped weave those voices into a new legacy.",
            quests = {
                -- Faction-specific openers (both included)
                { id = 84442, name = "Invitation to the Spirit Festival", npc = "Automatic (Alliance)" },
                { id = 84444, name = "Invitation to the Spirit Festival", npc = "Ji Firepaw (Horde)" },
                { id = 84451, name = "The Wanderers", npc = "Li Li Stormstout (Alliance)" },
                { id = 84452, name = "The Wanderers", npc = "Li Li Stormstout (Horde)" },

                -- Shared and branch steps
                { id = 84453, name = "To Dai-Lo Farmstead", npc = "Chen Stormstout" },
                { id = 84456, name = "To Morning Breeze", npc = "Aysa Cloudsinger (Alliance)" },
                { id = 84457, name = "To Morning Breeze", npc = "Ji Firepaw (Horde)" },
                { id = 84454, name = "Tide of Virmen", npc = "Chen Stormstout" },
                { id = 84455, name = "Big Bertha", npc = "Chon Po Stormstout" },
                { id = 84468, name = "Brew You One Better", npc = "Chen Stormstout" },
                { id = 84459, name = "Scamps Ain't It!", npc = "Ji Firepaw" },
                { id = 84458, name = "Devil's in the Details", npc = "Aysa Cloudsinger" },
                { id = 84460, name = "Red Hand or Herring?", npc = "Aysa Cloudsinger" },
                { id = 84461, name = "It's Not a Spirit Festival Without Spirits", npc = "Mr. Crane" },
                { id = 84462, name = "Patterns in Static", npc = "Li Li Stormstout" },
                { id = 84463, name = "Codependency", npc = "Jojo Ironbrow" },
                { id = 84464, name = "Lost My Spark", npc = "Li Li Stormstout" },
                { id = 84465, name = "Of Water and Blood", npc = "Li Li Stormstout" },
                { id = 84466, name = "Thousands of Years Ago...", npc = "Li Li Stormstout" },
                { id = 84467, name = "This Was Home", npc = "Lorewalker Cho" },
                { id = 92030, name = "A New Tradition", npc = "Lorewalker Cho" },
            },
        },
    },
}

return SM
