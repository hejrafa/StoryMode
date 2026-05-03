local addonName, SM = ...

-- =============================================================================
-- Classic: Darrowshire
-- Pamela Redpath, Chromie, and the battle that never stopped echoing.
-- =============================================================================

SM.DarrowshireData = {
    title = "The Battle of Darrowshire",
    description = "In the Plaguelands, a little girl waits in the ruins of Darrowshire with no memory of what really happened to her family. Pamela Redpath wants her doll back. Her surviving kin want answers. Chromie wants history's broken pieces gathered carefully enough to be touched again.\n\nFollow the Redpath family through one of Classic's most remembered tragedies, from Pamela's burned home to the battle where Joseph Redpath can finally be saved from what the Scourge made of him.",
    zone = "Western Plaguelands / Eastern Plaguelands",
    expansion = "Classic",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.68, 0.62, 0.48 },
    icon = 134331,
    portraitDisplayID = 7069,
    adventureCoverTexture = 131869,
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 5142, altIds = { 5601 }, name = "Little Pamela", npc = "Marlene Redpath", location = "Sorrow Hill, Western Plaguelands" },
    startMapID = 22,
    startX = 0.4900,
    startY = 0.7800,

    npcLocations = {
        ["Marlene Redpath"] = { mapID = 22, x = 0.4900, y = 0.7800, location = "Sorrow Hill, Western Plaguelands" },
        ["Jessica Redpath"] = { mapID = 83, x = 0.6100, y = 0.3900, location = "Everlook, Winterspring" },
        ["Pamela Redpath"] = { mapID = 23, x = 0.3600, y = 0.9000, location = "Darrowshire, Eastern Plaguelands" },
        ["Chromie"] = { mapID = 22, x = 0.3900, y = 0.6600, location = "the ruined inn of Andorhal, Western Plaguelands" },
        ["Carlin Redpath"] = { mapID = 23, x = 0.8100, y = 0.5900, location = "Light's Hope Chapel, Eastern Plaguelands" },
    },

    npcDisplayIDs = {
        ["Marlene Redpath"] = 7069,
        ["Jessica Redpath"] = 7069,
        ["Pamela Redpath"] = 7069,
        ["Chromie"] = 2489,
        ["Carlin Redpath"] = 9479,
    },

    chapterDisplayIDs = {
        ["Pamela's Doll"] = 7069,
        ["The Annals of Darrowshire"] = 2489,
        ["The Redpath Relics"] = 9479,
        ["Darrowshire Rewritten"] = 7069,
    },

    chapterIcons = {
        ["Pamela's Doll"] = 134506,
        ["The Annals of Darrowshire"] = 133739,
        ["The Redpath Relics"] = 134331,
        ["Darrowshire Rewritten"] = 135994,
    },

    chapters = {
        {
            chapter = "Pamela's Doll",
            summary = "Marlene or Jessica Redpath sends you to Darrowshire, where Pamela's ghost waits among burned houses and asks for the scattered pieces of her doll.",
            recap = "Darrowshire did not introduce itself with soldiers or strategy. It introduced itself with Pamela Redpath, alone in a ruined village and still thinking like the child she had been when the battle came. Finding the pieces of her doll made the truth harder to avoid: Pamela had not merely been lost. She had died here, and the people who loved her had been broken across the Plaguelands.",
            quests = {
                { id = 5142, altIds = { 5601 }, name = "Little Pamela", npc = "Marlene Redpath" },
                { id = 5149, name = "Pamela's Doll", npc = "Pamela Redpath" },
            },
        },
        {
            chapter = "The Annals of Darrowshire",
            summary = "Pamela sends you to her aunt and uncle. Marlene points toward Chromie and the Annals of Darrowshire, while Carlin carries the grief east to Light's Hope Chapel.",
            recap = "Pamela's family survived only in fragments: Marlene's guilt near Andorhal, Jessica's exile in Winterspring, and Carlin's grief at Light's Hope. Chromie gave those fragments a shape. The Annals of Darrowshire were not only a history book. In her hands, they became a way to read beyond the last page and ask whether one doomed night could be answered.",
            quests = {
                { id = 5152, name = "Auntie Marlene", npc = "Pamela Redpath" },
                { id = 5153, name = "A Strange Historian", npc = "Marlene Redpath" },
                { id = 5154, name = "The Annals of Darrowshire", npc = "Chromie" },
                { id = 5241, name = "Uncle Carlin", npc = "Pamela Redpath", optional = true },
                { id = 5211, name = "Defenders of Darrowshire", npc = "Carlin Redpath", optional = true },
                { id = 5210, name = "Brother Carlin", npc = "Chromie" },
            },
        },
        {
            chapter = "The Redpath Relics",
            summary = "Carlin and Chromie send you after the villains, heroes, and marauders of Darrowshire: relics from Horgus, Marduk, Davil, Redpath, and the Scourge champions who joined the battle.",
            recap = "The battle could not be touched until its names were recovered. Horgus and Marduk left relics of cruelty. Davil Lightfire and Joseph Redpath left relics of defense. The marauders left skulls that still resonated with the night Darrowshire fell. Each object made the past less abstract and more dangerous, as if history itself were being assembled into a spell.",
            quests = {
                { id = 5181, name = "Villains of Darrowshire", npc = "Carlin Redpath" },
                { id = 5168, name = "Heroes of Darrowshire", npc = "Carlin Redpath" },
                { id = 5206, name = "Marauders of Darrowshire", npc = "Carlin Redpath" },
                { id = 5941, name = "Return to Chromie", npc = "Carlin Redpath" },
            },
        },
        {
            chapter = "Darrowshire Rewritten",
            summary = "Chromie sends you back into Darrowshire's last battle. If the defenders hold, Joseph Redpath's spirit can be freed and Pamela can finally stop waiting.",
            recap = "The dead of Darrowshire rose to fight their last battle again. Davil had to stand long enough for Horgus to fall. Joseph Redpath had to live long enough to become the corrupted thing history remembered, and then be defeated before that corruption owned the end of his story. When Pamela heard the fighting stop, her father came home at last. Darrowshire was not saved in the ordinary sense, but one wound in it finally closed.",
            quests = {
                { id = 5721, name = "The Battle of Darrowshire", npc = "Chromie" },
                { id = 5942, name = "Hidden Treasures", npc = "Pamela Redpath" },
            },
        },
    },
}
