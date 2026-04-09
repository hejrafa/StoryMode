local addonName, SM = ...

SM.DraeneiHeritageData = {
    title = "Heritage of the Draenei",
    description = "Travel from the Exodar to Outland and Bloodmyst to confront old eredar scars and help forge a future worthy of draenei endurance.",
    zone = "Exodar / Outland / Bloodmyst Isle",
    expansion = "Dragonflight",
    faction = "Alliance",
    race = "Draenei",
    requiredLevel = 50,
    achievementName = "Heritage of the Draenei",
    color = { 0.55, 0.45, 0.82 },
    icon = "Interface\\Icons\\inv_misc_tabard_exodar",
    startQuest = { id = 78068, name = "An Artificer's Appeal", npc = "Automatic / Magically-Sealed Parcel", location = "Stormwind Embassy / Exodar" },
    chapters = {
        {
            chapter = "Heritage of the Draenei",
            summary = "Recover lost tradition, confront painful history, and stand against lingering eredar corruption.",
            recap = "The draenei's strength comes from memory, faith, and resilience. By sharing burdens old and new, you helped your people move forward without forgetting what they endured.",
            quests = {
                { id = 78068, name = "An Artificer's Appeal", npc = "Automatic / Magically-Sealed Parcel" },
                { id = 78069, name = "Reviving Tradition", npc = "Grand Artificer Romuul" },
                { id = 78070, name = "Pressing Deadlines", npc = "Grand Artificer Romuul" },
                { id = 78071, name = "Rush Order", npc = "High Artificer Ataanya" },
                { id = 78072, name = "An Old Wound", npc = "Apprentice Beruun" },
                { id = 78073, name = "Lingering Scars", npc = "Exarch Maladaar" },
                { id = 78074, name = "To See Clearly", npc = "Exarch Maladaar" },
                { id = 78075, name = "Moving Past", npc = "High Artificer Ataanya" },
                { id = 78076, name = "Emergency Efforts", npc = "Chieftain Hatuun" },
                { id = 78078, name = "Assessing the Enemy", npc = "Arzaal" },
                { id = 78077, name = "Beneath the Skin", npc = "Chieftain Hatuun" },
                { id = 78079, name = "Excision", npc = "Prophet Velen" },
                { id = 78080, name = "At the Source", npc = "Arzaal" },
                { id = 78081, name = "Pain Recedes", npc = "Prophet Velen" },
                { id = 78082, name = "A Burden Shared", npc = "Prophet Velen" },
                { id = 78083, name = "Our Path Forward", npc = "Grand Anchorite Almonen" },
            },
        },
    },
}

return SM
