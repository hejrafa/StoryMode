local addonName, SM = ...

SM.HumanHeritageData = {
    title = "Lion's Heritage",
    description = "Uncover a Defias plot with Mathias Shaw and Vanessa VanCleef, confront old Stormwind scars, and earn the legacy of humanity.",
    zone = "Stormwind / Westfall / Elwynn",
    expansion = "Dragonflight",
    faction = "Alliance",
    race = "Human",
    requiredLevel = 50,
    achievementName = "Lion's Heritage",
    color = { 0.22, 0.45, 0.86 },
    icon = "Interface\\Icons\\inv_misc_tournaments_banner_human",
    startQuest = { id = 72644, name = "An Urgent Matter", npc = "Agent Render", location = "Stormwind Embassy" },
    npcLocations = {
        ["Agent Render"] = { mapID = 84, x = 0.5220, y = 0.1350 }, -- Stormwind Embassy (approx)
        ["Master Mathias Shaw"] = { mapID = 84, x = 0.7620, y = 0.6010 }, -- SI:7 area (approx)
        ["Vanessa VanCleef"] = { mapID = 52, x = 0.4190, y = 0.6990 }, -- Moonbrook (approx)
        ["Ragged John"] = { mapID = 52, x = 0.4470, y = 0.2510 }, -- Sentinel Hill area (approx)
        ["Cecilia Clessington"] = { mapID = 52, x = 0.4190, y = 0.6990 }, -- Moonbrook (approx)
        ["Marshal McBride"] = { mapID = 37, x = 0.4840, y = 0.4200 }, -- Northshire (approx)
    },
    npcDisplayIDs = {
        ["Agent Render"] = 110648,
    },
    chapterIcons = {
        ["Lion's Heritage"] = "Interface\\Icons\\inv_misc_tournaments_banner_human",
    },
    chapterDisplayIDs = {
        ["Lion's Heritage"] = 110648,
    },
    chapters = {
        {
            chapter = "Lion's Heritage",
            summary = "Investigate conspiracy and betrayal tied to Stormwind's past and the Defias Brotherhood.",
            recap = "Stormwind's legacy was tested by old enemies and old mistakes. You followed the trail from the city to Westfall and Northshire, exposed the conspiracy, and helped preserve the honor of the kingdom.",
            quests = {
                { id = 72644, name = "An Urgent Matter", npc = "Agent Render" },
                { id = 72405, name = "An Unlikely Informant", npc = "Master Mathias Shaw" },
                { id = 72408, name = "A Window to the Past", npc = "Master Mathias Shaw" },
                { id = 72409, name = "Rotten Old Memories", npc = "Vanessa VanCleef" },
                { id = 72424, name = "Looking for Something Specific", npc = "Ragged John" },
                { id = 72426, name = "The New Clessington Estate", npc = "Master Mathias Shaw" },
                { id = 72430, name = "Misdeeds in Moonbrook", npc = "Vanessa VanCleef" },
                { id = 72431, name = "A Hungry Heritage", npc = "Vanessa VanCleef" },
                { id = 72432, name = "Supply Only the Finest Goons", npc = "Cecilia Clessington" },
                { id = 72453, name = "Betrayal of the Brotherhood", npc = "Vanessa VanCleef" },
                { id = 72445, name = "To Northshire", npc = "Master Mathias Shaw" },
                { id = 72449, name = "Knock It Off!", npc = "Master Mathias Shaw" },
                { id = 72446, name = "What's Their Problem?", npc = "Marshal McBride" },
                { id = 72450, name = "The Clessington Will", npc = "Cecilia Clessington" },
                { id = 72451, name = "Will to Survive", npc = "Master Mathias Shaw" },
                { id = 72452, name = "Go with Honor, Friend", npc = "Master Mathias Shaw" },
            },
        },
    },
}

return SM
