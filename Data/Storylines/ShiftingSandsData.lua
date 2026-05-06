local addonName, SM = ...

-- =============================================================================
-- Classic: The Scepter of the Shifting Sands
-- The Scarab Lord chain and the opening of Ahn'Qiraj.
-- =============================================================================

SM.ShiftingSandsData = {
    title = "The Scepter of the Shifting Sands",
    description = "Before the gates of Ahn'Qiraj could open, one champion had to earn the trust of the Brood of Nozdormu, gather the scattered shards of the ancient scepter, and carry the war effort of an entire realm to the Scarab Gong.\n\nFollow Classic's most legendary questline: Blackwing Lair, Silithus, the Nightmare, Azuregos, Narain's absurd errands, and the moment Azeroth rang the gong.",
    zone = "Silithus / Tanaris / Moonglade / Azshara / Blackwing Lair",
    expansion = "Classic",
    recommendedLevel = 60,
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    factions = {
        { id = 910, name = "Brood of Nozdormu", description = "Earn the trust of the bronze dragonflight's ancient brood." },
    },
    color = { 0.78, 0.58, 0.20 },
    icon = 134962,
    portraitDisplayID = 2719,
    adventureGuideInstanceName = "Ahn'Qiraj",
    adventureCoverTexture = 131819,
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 8286, name = "What Tomorrow Brings", npc = "Baristolth of the Shifting Sands", location = "Cenarion Hold, Silithus" },
    startMapID = 81,
    startX = 0.4900,
    startY = 0.3600,

    npcLocations = {
        ["Baristolth of the Shifting Sands"] = { mapID = 81, x = 0.4900, y = 0.3600, location = "Cenarion Hold, Silithus" },
        ["Anachronos"] = { mapID = 71, x = 0.6400, y = 0.5000, location = "outside the Caverns of Time, Tanaris" },
        ["Malfurion Stormrage"] = { mapID = 220, x = 0.6000, y = 0.5000, location = "the Temple of Atal'Hakkar" },
        ["Keeper Remulos"] = { mapID = 80, x = 0.3600, y = 0.4100, location = "Nighthaven, Moonglade" },
        ["Vaelastrasz the Corrupt"] = { mapID = 287, x = 0.4600, y = 0.2700, location = "Blackwing Lair" },
        ["Azuregos"] = { mapID = 76, x = 0.5600, y = 0.8000, location = "southeastern Azshara" },
        ["Narain Soothfancy"] = { mapID = 71, x = 0.6500, y = 0.1800, location = "north of Steamwheedle Port, Tanaris" },
        ["Dirge Quikcleave"] = { mapID = 71, x = 0.5200, y = 0.2800, location = "Gadgetzan, Tanaris" },
    },

    npcDisplayIDs = {
        ["Baristolth of the Shifting Sands"] = 15311,
        ["Anachronos"] = 2719,
        ["Malfurion Stormrage"] = 15399,
        ["Keeper Remulos"] = 11906,
        ["Vaelastrasz the Corrupt"] = 13992,
        ["Azuregos"] = 11460,
        ["Narain Soothfancy"] = 11757,
        ["Dirge Quikcleave"] = 7338,
    },

    chapterDisplayIDs = {
        ["The Brood of Nozdormu"] = 15311,
        ["The Charge of the Dragonflights"] = 2719,
        ["Green Scepter Shard"] = 11906,
        ["Red Scepter Shard"] = 13992,
        ["Blue Scepter Shard"] = 11757,
        ["Bang a Gong"] = 2719,
    },

    chapterIcons = {
        ["The Brood of Nozdormu"] = 134962,
        ["The Charge of the Dragonflights"] = 134156,
        ["Green Scepter Shard"] = 134134,
        ["Red Scepter Shard"] = 134129,
        ["Blue Scepter Shard"] = 134155,
        ["Bang a Gong"] = 134962,
    },

    chapters = {
        {
            chapter = "The Brood of Nozdormu",
            summary = "Baristolth sends you to Anachronos and then to Blackwing Lair. Broodlord Lashlayer's head begins the long work of earning Nozdormu's trust.",
            recap = "The bronze dragonflight did not greet mortals as allies. Baristolth's trial led to Anachronos, then back through Blackwing Lair and into the Silithus hives. The Head of Broodlord Lashlayer proved strength; the carapace fragments proved endurance. Before the scepter could be repaired, a champion first had to become someone the Brood of Nozdormu would even address.",
            quests = {
                { id = 8286, name = "What Tomorrow Brings", npc = "Baristolth of the Shifting Sands" },
                { id = 8288, name = "Only One May Rise", npc = "Baristolth of the Shifting Sands" },
                { id = 8301, name = "The Path of the Righteous", npc = "Baristolth of the Shifting Sands" },
                { id = 8302, name = "The Hand of the Righteous", npc = "Baristolth of the Shifting Sands", optional = true },
                { id = 8303, name = "Anachronos", npc = "Baristolth of the Shifting Sands" },
            },
        },
        {
            chapter = "The Charge of the Dragonflights",
            summary = "At the Scarab Wall, Anachronos shows the War of the Shifting Sands and names the lost shards held by Eranikus, Vaelastrasz, and Azuregos.",
            recap = "The red tear outside Ahn'Qiraj was memory made visible. Anachronos let the past speak: the night elves, dragons, and qiraji locked in a war old enough to feel mythic even in Classic. The scepter had broken across dragonflights and tragedies. To open the gates, the champion would have to follow those wounds into the Emerald Dream, Blackwing Lair, and Azshara's blue-dragon riddles.",
            quests = {
                { id = 8305, name = "Long Forgotten Memories", npc = "Anachronos" },
                { id = 8519, name = "A Pawn on the Eternal Board", npc = "Anachronos" },
                { id = 8555, name = "The Charge of the Dragonflights", npc = "Anachronos" },
            },
        },
        {
            chapter = "Green Scepter Shard",
            summary = "Malfurion and Remulos guide the path to Eranikus. The Nightmare's corruption must be confronted in Moonglade.",
            recap = "The green shard was not won by simple killing. Eranikus had fallen into nightmare, and Remulos needed the corruption named before it could be answered. The defense of Moonglade became one of Classic's rare public rituals: shades pouring from the Dream, Remulos holding the line, and Tyrande's grace turning a dragon's rage toward redemption.",
            quests = {
                { id = 8733, name = "Eranikus, Tyrant of the Dream", npc = "Malfurion Stormrage" },
                { id = 8734, name = "Tyrande and Remulos", npc = "Forest Wisp" },
                { id = 8735, name = "The Nightmare's Corruption", npc = "Keeper Remulos" },
                { id = 8736, name = "The Nightmare Manifests", npc = "Keeper Remulos" },
                { id = 8741, name = "The Champion Returns", npc = "Keeper Remulos" },
            },
        },
        {
            chapter = "Red Scepter Shard",
            summary = "Vaelastrasz's corruption leaves no time for ceremony. Nefarian holds the red shard, and Blackwing Lair must answer quickly.",
            recap = "The red shard was the bluntest path and perhaps the cruelest. Vaelastrasz, already broken by Nefarian, could only point toward the master of Blackwing Lair and set a clock running. The shard came from defeating Nefarian under pressure, a raid victory pressed into the shape of a single person's impossible errand.",
            quests = {
                { id = 8730, name = "Nefarius's Corruption", npc = "Vaelastrasz the Corrupt" },
            },
        },
        {
            chapter = "Blue Scepter Shard",
            summary = "Azuregos sends you to Narain Soothfancy, whose ledger explodes into goggles, chimaerok chops, ransom notes, Draconic pages, and the Wrath of Neptulon.",
            recap = "The blue shard was Classic maximalism at full sprint. Azuregos hid cosmic importance behind jokes about minnows. Narain turned the task into errands involving Molten Core goggles, a five-hundred-pound chicken, a stolen book, a fake ransom drop, Onyxia, Ragnaros, and finally a shark off Azshara's coast. It was absurd, exhausting, and somehow exactly what a legendary scepter needed.",
            quests = {
                { id = 8575, name = "Azuregos's Magical Ledger", npc = "Azuregos" },
                { id = 8576, name = "Translating the Ledger", npc = "Narain Soothfancy" },
                { id = 8577, name = "Stewvul, Ex-B.F.F.", npc = "Narain Soothfancy" },
                { id = 8578, name = "Scrying Goggles? No Problem!", npc = "Stewvul" },
                { id = 8584, name = "Never Ask Me About My Business", npc = "Narain Soothfancy" },
                { id = 8585, name = "The Isle of Dread!", npc = "Dirge Quikcleave" },
                { id = 8586, name = "Dirge's Kickin' Chimaerok Chops", npc = "Dirge Quikcleave" },
                { id = 8587, name = "Return to Narain", npc = "Dirge Quikcleave" },
                { id = 8597, name = "Draconic for Dummies", npc = "Narain Soothfancy" },
                { id = 8599, name = "Love Song for Narain", npc = "Meridith the Mermaiden", optional = true },
                { id = 8598, name = "rAnS0m", npc = "Freshly Dug Dirt" },
                { id = 8606, name = "Decoy!", npc = "Narain Soothfancy" },
                { id = 8620, name = "The Only Prescription", npc = "Narain Soothfancy" },
                { id = 8728, name = "The Good News and The Bad News", npc = "Narain Soothfancy" },
                { id = 8729, name = "The Wrath of Neptulon", npc = "Narain Soothfancy" },
            },
        },
        {
            chapter = "Bang a Gong",
            summary = "With the three shards restored, Anachronos grants the Scepter of the Shifting Sands. The Scarab Gong turns one player's chain into a realm event.",
            recap = "When the shards were whole, the story stopped belonging to one adventurer. The Might of Kalimdor waited on the war effort, on the armies at the wall, and on a server holding its breath. Bang a Gong was not only a quest handoff. It was the moment Classic let a player touch the history of a realm, open Ahn'Qiraj, and become part of the memory everyone else would tell later.",
            quests = {
                { id = 8742, name = "The Might of Kalimdor", npc = "Anachronos" },
                { id = 8743, name = "Bang a Gong!", npc = "Scarab Gong" },
                { id = 8744, name = "Treasure of the Timeless One", npc = "Jonathan the Revelator" },
            },
        },
    },
}
