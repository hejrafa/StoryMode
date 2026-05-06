local addonName, SM = ...

-- =============================================================================
-- Classic: Arugal and Shadowfang Keep
-- Silverpine's worgen curse, Ambermill's Dalaran mages, and Arugal's fall.
-- =============================================================================

SM.ArugalData = {
    title = "Arugal and Shadowfang Keep",
    description = "Silverpine Forest belongs to the Forsaken only on paper. The roads are stalked by worgen, the mages of Dalaran fortify Ambermill, and Arugal's mistake still howls from Shadowfang Keep.\n\nServe the Sepulcher, uncover the magic loose in Silverpine, break the Dalaran weaving at Ambermill, and carry Arugal's head back as proof that the forest can be claimed.",
    zone = "Silverpine Forest / Shadowfang Keep",
    expansion = "Classic",
    recommendedLevel = { min = 9, max = 27 },
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.42, 0.48, 0.58 },
    icon = 136150,
    portraitDisplayID = 2353,
    adventureCoverTexture = 131869, -- Shadowfang Keep loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 421, name = "Prove Your Worth", npc = "Dalar Dawnweaver", location = "the Sepulcher, Silverpine Forest" },
    startMapID = 21,
    startX = 0.4430,
    startY = 0.3950,

    npcLocations = {
        ["Dalar Dawnweaver"] = { mapID = 21, x = 0.4430, y = 0.3950, location = "the Sepulcher, Silverpine Forest" },
        ["Shadow Priest Allister"] = { mapID = 21, x = 0.4340, y = 0.4100, location = "the Sepulcher, Silverpine Forest" },
        ["Keeper Bel'dugur"] = { mapID = 90, x = 0.5300, y = 0.5400, location = "the Apothecarium, Undercity" },
        ["Dalaran Crate"] = { mapID = 21, x = 0.4650, y = 0.7200, location = "the Dalaran camp north of Pyrewood Village" },
        ["Pyrewood Village"] = { mapID = 21, x = 0.4600, y = 0.7350, location = "Pyrewood Village, Silverpine Forest" },
        ["Ambermill"] = { mapID = 21, x = 0.6100, y = 0.6400, location = "Ambermill, Silverpine Forest" },
        ["Shadowfang Keep"] = { mapID = 21, x = 0.4400, y = 0.6750, location = "Shadowfang Keep, Silverpine Forest" },
        ["Archmage Ataeric"] = { mapID = 21, x = 0.6120, y = 0.6400, location = "Ambermill, Silverpine Forest" },
        ["Archmage Arugal"] = { mapID = 310, x = 0.5000, y = 0.5000, location = "Shadowfang Keep" },
    },

    npcDisplayIDs = {
        ["Dalar Dawnweaver"] = 1278,
        ["Shadow Priest Allister"] = 1948,
        ["Keeper Bel'dugur"] = 5751,
        ["Archmage Ataeric"] = 3601,
        ["Archmage Arugal"] = 2353,
    },

    chapterDisplayIDs = {
        ["Arugal's Folly"] = 1278,
        ["Ambermill"] = 3601,
        ["Shadowfang Keep"] = 2353,
    },

    chapterIcons = {
        ["Arugal's Folly"] = 136150,
        ["Ambermill"] = 136096,
        ["Shadowfang Keep"] = 136163,
    },

    chapters = {
        {
            chapter = "Arugal's Folly",
            summary = "Dalar Dawnweaver sends you against the Moonrage worgen and the magic Arugal left behind in Silverpine.",
            recap = "Dalar Dawnweaver spoke of Arugal like an insult that had learned to cast spells. The Forsaken wanted Silverpine secured for the Dark Lady, but Arugal's worgen still prowled the fields and mines. You proved yourself against the Moonrage packs, stole the Remedy of Arugal from the old farm, gathered shackles from cursed beasts, and struck down Grimson the Pale and other tainted servants. Each task made the same point clearer: Silverpine's danger was not random. Arugal's magic had soaked into the place.",
            quests = {
                { id = 421, name = "Prove Your Worth", npc = "Dalar Dawnweaver" },
                { id = 422, name = "Arugal's Folly", displayName = "The Remedy of Arugal", npc = "Dalar Dawnweaver" },
                { id = 423, name = "Arugal's Folly", displayName = "Moonrage Shackles", npc = "Dalar Dawnweaver" },
                { id = 424, name = "Arugal's Folly", displayName = "Grimson the Pale", npc = "Dalar Dawnweaver" },
                { id = 99, name = "Arugal's Folly", displayName = "Pyrewood Shackles", npc = "Dalar Dawnweaver" },
            },
        },
        {
            chapter = "Ambermill",
            summary = "The Sepulcher turns from worgen to Dalaran. Crates, runes, pendants, and a hidden ley project lead you to Ambermill's archmage.",
            recap = "The Dalaran wizards were not only holding Ambermill. They were moving supplies, studying runes, and trying to wake a ley node under Silverpine. Shadow Priest Allister and Dalar Dawnweaver picked apart the trail: crates near Pyrewood, a rune-inscribed pendant, and enough Dalaran pendants to show the scale of the work. At the end stood Archmage Ataeric, the weaver guiding the project. Killing him did not make Silverpine safe, but it stopped one more force from deciding the forest's future without the Forsaken.",
            quests = {
                { id = 477, name = "Border Crossings", npc = "Shadow Priest Allister" },
                { id = 478, name = "Maps and Runes", npc = "Dalaran Crate" },
                { id = 481, name = "Dalar's Analysis", npc = "Shadow Priest Allister" },
                { id = 482, name = "Dalaran's Intentions", npc = "Dalar Dawnweaver" },
                { id = 479, name = "Ambermill Investigations", npc = "Shadow Priest Allister" },
                { id = 480, name = "The Weaver", npc = "Shadow Priest Allister" },
            },
        },
        {
            chapter = "Shadowfang Keep",
            summary = "The trail ends inside Shadowfang Keep, where the Forsaken want Arugal dead and the Book of Ur recovered from his haunted castle.",
            recap = "Shadowfang Keep was the answer waiting above Silverpine's roads. Keeper Bel'dugur wanted the Book of Ur from its halls, old magic worth studying even in a cursed keep. Dalar Dawnweaver wanted something simpler and bloodier: Arugal's head. In the end, the worgen, the ruined village below the keep, and the tower above it all pointed back to one mage whose mistake had become a whole region's wound. Arugal fell, and the Sepulcher had its proof.",
            quests = {
                { id = 1013, name = "The Book of Ur", npc = "Keeper Bel'dugur" },
                { id = 1014, name = "Arugal Must Die", npc = "Dalar Dawnweaver" },
            },
        },
    },
}
