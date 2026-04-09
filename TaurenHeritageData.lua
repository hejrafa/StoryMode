local addonName, SM = ...

SM.TaurenHeritageData = {
    title = "Heritage of the Shu'halo",
    description = "Answer Baine's call, walk with the spiritwalkers, and restore balance between the living and the spirit realm to honor tauren heritage.",
    zone = "Thunder Bluff / Mulgore / Stonetalon",
    expansion = "Battle for Azeroth",
    faction = "Horde",
    race = "Tauren",
    requiredLevel = 50,
    achievementName = "Heritage of the Shu'halo",
    color = { 0.62, 0.42, 0.24 },
    icon = "Interface\\Icons\\inv_misc_tabard_thunderbluff",
    startQuest = { id = 54759, name = "When Spirits Whisper", npc = "Spiritwalker Isahi", location = "Orgrimmar Embassy" },
    chapters = {
        {
            chapter = "Heritage of the Shu'halo",
            summary = "Cross into the spirit realm, face unrest among the ancestors, and protect Thunder Bluff.",
            recap = "The spirits called, and you answered. By walking between worlds and standing with Baine and the spiritwalkers, you helped the Shu'halo restore harmony and honor their ancestors.",
            quests = {
                { id = 54759, name = "When Spirits Whisper", npc = "Spiritwalker Isahi" },
                { id = 54760, name = "The Spiritwalkers", npc = "Baine Bloodhoof" },
                { id = 54761, name = "Spirit Guide", npc = "Spiritwalker Ussoh" },
                { id = 54762, name = "A Small Retreat", npc = "Spiritwalker Ussoh" },
                { id = 54763, name = "Crossing Over", npc = "Spiritwalker Ussoh" },
                { id = 54764, name = "Storm in Bloodhoof", npc = "Spiritwalker Ussoh" },
                { id = 54766, name = "Answer the Call", npc = "Baine Bloodhoof" },
                { id = 54765, name = "Thank Your Guide", npc = "Baine Bloodhoof" },
            },
        },
    },
}

return SM
