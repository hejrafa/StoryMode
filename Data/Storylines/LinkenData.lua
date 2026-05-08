local addonName, SM = ...

-- =============================================================================
-- Classic: Linken's Adventure
-- A lost gnome, a broken sword, and Azeroth's longest wink at Hyrule.
-- =============================================================================

SM.LinkenData = {
    title = "Linken's Adventure",
    description = "A wrecked raft in Un'Goro holds a compass, a map, a key, and a faded photograph. Their owner is alive at Marshal's Refuge, but Linken remembers almost nothing about himself or the strange sword he carried into the crater.\n\nFollow one of Classic's strangest and most beloved treasure-hunt stories from Un'Goro to Tanaris, Felwood, Winterspring, and back to Fire Plume Ridge.",
    zone = "Un'Goro Crater / Tanaris / Felwood / Winterspring",
    expansion = "Classic",
    recommendedLevel = { min = 47, max = 56 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.30, 0.66, 0.34 },
    icon = 135346,
    portraitDisplayID = 8012,
    adventureCoverTexture = 131886,
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 3844, name = "It's a Secret to Everybody", npc = "A Wrecked Raft", location = "the Marshlands, Un'Goro Crater" },
    startMapID = 78,
    startX = 0.6300,
    startY = 0.6800,

    npcLocations = {
        ["A Wrecked Raft"] = { mapID = 78, x = 0.6300, y = 0.6800, location = "the Marshlands, Un'Goro Crater" },
        ["A Small Pack"] = { mapID = 78, x = 0.6300, y = 0.6900, location = "beside the wrecked raft, Un'Goro Crater" },
        ["Linken"] = { mapID = 78, x = 0.4450, y = 0.0810, location = "Marshal's Refuge, Un'Goro Crater" },
        ["Donova Snowden"] = { mapID = 83, x = 0.3100, y = 0.4500, location = "Frostfire Hot Springs, Winterspring" },
        ["Gaeriyan"] = { mapID = 71, x = 0.5300, y = 0.2900, location = "Gadgetzan, Tanaris" },
        ["Eridan Bluewind"] = { mapID = 77, x = 0.5100, y = 0.8200, location = "Emerald Sanctuary, Felwood" },
        ["Aquementas"] = { mapID = 78, x = 0.7100, y = 0.7600, location = "the lakes east of Fire Plume Ridge, Un'Goro Crater" },
        ["Blazerunner"] = { mapID = 78, x = 0.4900, y = 0.5100, location = "Fire Plume Ridge, Un'Goro Crater" },
    },

    npcDisplayIDs = {
        ["Linken"] = 8012,
        ["Donova Snowden"] = 8949,
        ["Gaeriyan"] = 8717,
        ["Eridan Bluewind"] = 9136,
        ["Aquementas"] = 5564,
        ["Blazerunner"] = 1204,
    },

    chapterDisplayIDs = {
        ["A Secret to Everybody"] = 8012,
        ["Linken's Memory"] = 9136,
        ["Aquementas"] = 5564,
        ["It's Dangerous to Go Alone"] = 1204,
    },

    chapterIcons = {
        ["A Secret to Everybody"] = 134269,
        ["Linken's Memory"] = 133738,
        ["Aquementas"] = 135861,
        ["It's Dangerous to Go Alone"] = 135346,
    },

    chapters = {
        {
            chapter = "A Secret to Everybody",
            summary = "A wrecked raft and a small pack lead to Linken at Marshal's Refuge. He has the look of a hero, but not the memory to explain why.",
            recap = "The raft in Un'Goro was absurdly specific: a compass, a curled map, a lion-headed key, and a photograph pointing toward a gnome in green. Linken recognized the belongings and almost recognized himself. The crater had swallowed the context, leaving only the shape of an adventure and the sense that someone had once handed him a sword for a reason.",
            quests = {
                { id = 3844, name = "It's a Secret to Everybody", npc = "A Wrecked Raft" },
                { id = 3845, name = "It's a Secret to Everybody", npc = "A Small Pack" },
                { id = 3908, name = "It's a Secret to Everybody", npc = "Linken" },
            },
        },
        {
            chapter = "Linken's Memory",
            summary = "The Videre Elixir sends you through Tanaris and Winterspring, then back by way of a grave. Linken's sword begins to remember before Linken does.",
            recap = "Linken's memory did not return like a clean answer. It came through strange errands, ghostly meetings, and a sword that changed in flashes of light. Donova, Gaeriyan, and the grave outside Gadgetzan turned the lost gnome's story into a ritual of recovery. By the time the sword was reforged, Linken still did not fully understand himself, but the adventure had momentum again.",
            quests = {
                { id = 3909, name = "The Videre Elixir", npc = "Donova Snowden" },
                { id = 3912, name = "Meet at the Grave", npc = "Gaeriyan" },
                { id = 3913, name = "A Grave Situation", npc = "A Conspicuous Gravestone", mapID = 71, x = 0.5300, y = 0.2900, location = "Linken's Memory, Un'Goro Crater / Tanaris / Felwood / Winterspring" },
                { id = 3914, name = "Linken's Sword", npc = "A Conspicuous Gravestone", mapID = 71, x = 0.5300, y = 0.2900, location = "Linken's Memory, Un'Goro Crater / Tanaris / Felwood / Winterspring" },
                { id = 3941, name = "A Gnome's Assistance", npc = "Linken" },
                { id = 3942, name = "Linken's Memory", npc = "Linken" },
            },
        },
        {
            chapter = "Aquementas",
            summary = "Eridan Bluewind sends you after a silver heart and the elemental Aquementas. Linken's broken adventure gains a totem and a purpose.",
            recap = "Felwood gave the quest its older magic. Eridan Bluewind understood the silver heart Linken had been trying to make and sent you into Winterspring's old forests before Aquementas rose in Un'Goro. The elemental's power became a silver totem, the key to stripping away the final guardian's protection. The joke was still playful, but the ritual had become real.",
            quests = {
                { id = 4084, name = "Silver Heart", npc = "Eridan Bluewind" },
                { id = 4005, name = "Aquementas", npc = "Eridan Bluewind" },
                { id = 3961, name = "Linken's Adventure", npc = "Aquementas" },
            },
        },
        {
            chapter = "It's Dangerous to Go Alone",
            summary = "Linken sends you to Fire Plume Ridge with the Silver Totem of Aquementas. Blazerunner waits with the Golden Flame.",
            recap = "At the end, Linken's adventure became exactly what it had been hinting at all along: a hero, a sword, a strange tool, a mountain, and a dangerous guardian. Blazerunner's flame was protected until the totem broke its shield. When the Golden Flame came back to Marshal's Refuge, Linken's memory was still imperfect, but the story knew what it was. It was dangerous to go alone. So he sent you.",
            quests = {
                { id = 3962, name = "It's Dangerous to Go Alone", npc = "Linken" },
            },
        },
    },
}
