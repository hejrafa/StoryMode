local addonName, SM = ...

-- =============================================================================
-- Classic: Timbermaw Hold
-- The uncorrupted furbolg tribe between Felwood, Winterspring, and Moonglade.
-- =============================================================================

SM.TimbermawData = {
    title = "Timbermaw Hold",
    description = "Felwood's corruption did not take every furbolg. The Timbermaw still guard their hold between Felwood, Winterspring, and Moonglade, wary of strangers and grieving what the Deadwood and Winterfall tribes have become.\n\nEarn their trust by fighting corrupted kin on both sides of the mountain and carrying word through the tunnels of one of Classic's most memorable reputation stories.",
    zone = "Felwood / Winterspring / Timbermaw Hold",
    expansion = "Classic",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    factions = {
        { id = 576, name = "Timbermaw Hold", description = "Earn reputation with the last uncorrupted furbolg tribe." },
    },
    color = { 0.48, 0.58, 0.36 },
    icon = 132183,
    portraitDisplayID = 5851,
    adventureCoverTexture = 131850,
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 8460, name = "Timbermaw Ally", npc = "Grazle", location = "south Felwood near Emerald Sanctuary" },
    startMapID = 77,
    startX = 0.5100,
    startY = 0.8500,

    npcLocations = {
        ["Grazle"] = { mapID = 77, x = 0.5100, y = 0.8500, location = "south Felwood near Emerald Sanctuary" },
        ["Nafien"] = { mapID = 77, x = 0.6450, y = 0.0810, location = "the Felwood entrance to Timbermaw Hold" },
        ["Salfa"] = { mapID = 83, x = 0.2700, y = 0.3400, location = "the Winterspring entrance to Timbermaw Hold" },
        ["Kernda"] = { mapID = 77, x = 0.5100, y = 0.8500, location = "south Felwood near Emerald Sanctuary" },
    },

    npcDisplayIDs = {
        ["Grazle"] = 5851,
        ["Nafien"] = 5851,
        ["Salfa"] = 6829,
        ["Kernda"] = 21528,
    },

    chapterDisplayIDs = {
        ["Timbermaw Ally"] = 5851,
        ["Through the Hold"] = 5851,
        ["Ritual Totems"] = 6829,
    },

    chapterIcons = {
        ["Timbermaw Ally"] = 132183,
        ["Through the Hold"] = 134331,
        ["Ritual Totems"] = 136232,
    },

    chapters = {
        {
            chapter = "Timbermaw Ally",
            summary = "Grazle asks you to prove yourself against the corrupted Deadwood furbolgs in southern Felwood.",
            recap = "The Timbermaw did not begin with friendship. They began with suspicion, and with Grazle asking whether an outsider could tell the difference between a furbolg tribe and the corruption consuming it. Fighting the Deadwood was ugly work because the Timbermaw knew exactly what those enemies had once been. Trust began in grief, not triumph.",
            quests = {
                { id = 8460, name = "Timbermaw Ally", npc = "Grazle" },
                { id = 8462, name = "Speak to Nafien", npc = "Grazle" },
            },
        },
        {
            chapter = "Through the Hold",
            summary = "Nafien guards the Felwood entrance and sends you against the northern Deadwood before asking you to carry word through Timbermaw Hold to Salfa.",
            recap = "At the northern mouth of Felwood, Nafien made the Timbermaw's position clear: the hold was sanctuary, not a shortcut. The Deadwood camp nearby proved the corruption was still pressing against their doors. When you had done enough to be trusted with passage, the tunnel became more than geography. It became an invitation to see the tribe from the inside.",
            quests = {
                { id = 8461, name = "Deadwood of the North", npc = "Nafien" },
                { id = 8465, name = "Speak to Salfa", npc = "Nafien" },
                { id = 8467, name = "Feathers for Nafien", npc = "Nafien", optional = true },
            },
        },
        {
            chapter = "Ritual Totems",
            summary = "Salfa turns the story east to Winterspring, where the Winterfall tribe has fallen into the same fear and fury. Rare ritual totems reveal how deep the corruption runs.",
            recap = "Winterspring showed that Felwood's sickness was not contained by snow or stone. The Winterfall tribe had become hostile, frightened, and violent, another mirror the Timbermaw could hardly bear to look into. Ritual totems from Deadwood and Winterfall camps made the corruption feel organized, almost ceremonial. The Timbermaw survived by remembering who they were while ending what their kin had become.",
            quests = {
                { id = 8464, name = "Winterfall Activity", npc = "Salfa" },
                { id = 8466, name = "Feathers for Grazle", npc = "Grazle", optional = true },
                { id = 8469, name = "Beads for Salfa", npc = "Salfa", optional = true },
                { id = 8470, name = "Deadwood Ritual Totem", npc = "Deadwood Ritual Totem", optional = true },
                { id = 8471, name = "Winterfall Ritual Totem", npc = "Winterfall Ritual Totem", optional = true },
                { id = 8481, name = "The Root of All Evil", npc = "Kernda", optional = true },
            },
        },
    },
}
