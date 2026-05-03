local addonName, SM = ...

-- =============================================================================
-- Classic class quests
-- Curated identity chains: iconic abilities, tools, weapons, and mounts.
-- =============================================================================

SM.ClassicDruidQuestData = {
    title = "The Cenarion Path",
    description = "A druid's training is not learned from a trainer alone. It is answered in Moonglade, tested by spirits, carried through poison and water, and bound to the quiet duties of the Cenarion Circle.",
    zone = "Moonglade / Darkshore / Westfall / The Barrens",
    expansion = "Classic",
    class = "DRUID",
    gameVersions = { classicEra = true, tbc = true },
    color = { 1.00, 0.49, 0.04 },
    icon = 136041,
    adventureCoverTexture = 131882, -- Wailing Caverns: Cenarion/Naralex nature imagery closest to Classic druid class fantasy
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 5923, name = "Heeding the Call", npc = "Druid Trainer", faction = "Alliance" },
    startMapID = 80,
    startX = 0.5600,
    startY = 0.3000,

    chapterIcons = {
        ["Bear Form"] = 132276,
        ["Cure Poison"] = 136067,
        ["Aquatic Form"] = 132112,
    },

    chapters = {
        {
            chapter = "Bear Form",
            requiredLevel = 10,
            summary = "Answer the call to Moonglade, speak with the Great Bear Spirit, and earn the form that lets a young druid stand their ground.",
            recap = "Your first true lesson came from the wild itself. The path led through Moonglade to the Great Bear Spirit, whose strength was not rage but endurance. When you returned to your people, you carried that lesson in your bones.",
            quests = {
                { id = 5923, name = "Heeding the Call", npc = "Druid Trainer", faction = "Alliance" },
                { id = 5921, name = "Moonglade", npc = "Druid Trainer", faction = "Alliance" },
                { id = 5929, name = "Great Bear Spirit", npc = "Dendrite Starblaze", faction = "Alliance" },
                { id = 5931, name = "Back to Darnassus", npc = "Dendrite Starblaze", faction = "Alliance" },
                { id = 6001, name = "Body and Heart", npc = "Mathrengyl Bearwalker", faction = "Alliance" },
                { id = 5926, name = "Heeding the Call", npc = "Druid Trainer", faction = "Horde" },
                { id = 5922, name = "Moonglade", npc = "Druid Trainer", faction = "Horde" },
                { id = 5930, name = "Great Bear Spirit", npc = "Dendrite Starblaze", faction = "Horde" },
                { id = 5932, name = "Back to Thunder Bluff", npc = "Dendrite Starblaze", faction = "Horde" },
                { id = 6002, name = "Body and Heart", npc = "Turak Runetotem", faction = "Horde" },
            },
        },
        {
            chapter = "Cure Poison",
            requiredLevel = 14,
            summary = "Track a corruption spreading through beasts and waters, gather the cure, and learn to cleanse poison from the living.",
            recap = "The Circle's work was not always grand. Sometimes it meant kneeling beside sick creatures, following rot to its source, and learning that restoration is as much a weapon as claw or fang.",
            quests = {
                { id = 6121, name = "Lessons Anew", npc = "Druid Trainer", faction = "Alliance" },
                { id = 6122, name = "The Principal Source", npc = "Mathrengyl Bearwalker", faction = "Alliance" },
                { id = 6123, name = "Gathering the Cure", npc = "Alanndarian Nightsong", faction = "Alliance" },
                { id = 6124, name = "Curing the Sick", npc = "Alanndarian Nightsong", faction = "Alliance" },
                { id = 6125, name = "Power over Poison", npc = "Alanndarian Nightsong", faction = "Alliance" },
                { id = 6126, name = "Lessons Anew", npc = "Druid Trainer", faction = "Horde" },
                { id = 6127, name = "The Principal Source", npc = "Turak Runetotem", faction = "Horde" },
                { id = 6128, name = "Gathering the Cure", npc = "Torwa Pathfinder", faction = "Horde" },
                { id = 6129, name = "Curing the Sick", npc = "Torwa Pathfinder", faction = "Horde" },
                { id = 6130, name = "Power over Poison", npc = "Torwa Pathfinder", faction = "Horde" },
            },
        },
        {
            chapter = "Aquatic Form",
            requiredLevel = 16,
            summary = "Cross lake and sea for the pendant pieces that unlock the shape of the seal.",
            recap = "The water trial sent you farther than any trainer's lesson had before. Lake, coast, and current became the classroom, and when the pendant was whole, the depths opened.",
            quests = {
                { id = 26, name = "A Lesson to Learn", npc = "Druid Trainer", faction = "Alliance" },
                { id = 28, name = "Trial of the Lake", npc = "Tajarri", faction = "Alliance" },
                { id = 30, name = "Trial of the Sea Lion", npc = "Tajarri", faction = "Alliance" },
                { id = 31, name = "Aquatic Form", npc = "Dendrite Starblaze", faction = "Alliance" },
                { id = 27, name = "A Lesson to Learn", npc = "Druid Trainer", faction = "Horde" },
                { id = 29, name = "Trial of the Lake", npc = "Tajarri", faction = "Horde" },
                { id = 272, name = "Trial of the Sea Lion", npc = "Tajarri", faction = "Horde" },
                { id = 31, name = "Aquatic Form", npc = "Dendrite Starblaze", faction = "Horde" },
            },
        },
    },
}

SM.ClassicHunterQuestData = {
    title = "The Hunter's Path",
    description = "A hunter is measured by patience, bond, and precision. Tame your first companion, then follow the ancient leaf into one of Classic's sharpest class trials.",
    zone = "Teldrassil / Dun Morogh / Mulgore / Durotar / Felwood / Molten Core",
    expansion = "Classic",
    class = "HUNTER",
    gameVersions = { classicEra = true, tbc = true },
    color = { 0.67, 0.83, 0.45 },
    icon = 132164,
    adventureCoverTexture = 131851, -- Molten Core: source of the Ancient Petrified Leaf for Rhok'delar
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 6065, name = "The Hunter's Path", npc = "Hunter Trainer", faction = "Alliance" },
    startMapID = 1,
    startX = 0.4600,
    startY = 0.5300,

    chapterIcons = {
        ["Taming the Beast"] = 132164,
        ["Rhok'delar"] = 135489,
    },

    chapters = {
        {
            chapter = "Taming the Beast",
            requiredLevel = 10,
            summary = "Learn the hunter's defining bond by taming wild beasts and earning the right to train a companion.",
            recap = "The first lesson was humility: approach the wild, survive it, and earn trust without breaking it. When the final beast answered your call, you stopped traveling alone.",
            quests = {
                { id = 6062, name = "Taming the Beast", npc = "Dazalar", race = "NightElf" },
                { id = 6083, name = "Taming the Beast", npc = "Dazalar", race = "NightElf" },
                { id = 6082, name = "Taming the Beast", npc = "Dazalar", race = "NightElf" },
                { id = 6081, name = "Training the Beast", npc = "Dazalar", race = "NightElf" },
                { id = 6065, name = "The Hunter's Path", npc = "Hunter Trainer", race = "Dwarf" },
                { id = 6061, name = "Taming the Beast", npc = "Grif Wildheart", race = "Dwarf" },
                { id = 6087, name = "Taming the Beast", npc = "Grif Wildheart", race = "Dwarf" },
                { id = 6088, name = "Taming the Beast", npc = "Grif Wildheart", race = "Dwarf" },
                { id = 6089, name = "Training the Beast", npc = "Grif Wildheart", race = "Dwarf" },
                { id = 6071, name = "The Hunter's Path", npc = "Hunter Trainer", race = "Tauren" },
                { id = 6063, name = "Taming the Beast", npc = "Yaw Sharpmane", race = "Tauren" },
                { id = 6101, name = "Taming the Beast", npc = "Yaw Sharpmane", race = "Tauren" },
                { id = 6102, name = "Taming the Beast", npc = "Yaw Sharpmane", race = "Tauren" },
                { id = 6103, name = "Training the Beast", npc = "Yaw Sharpmane", race = "Tauren" },
                { id = 6074, name = "The Hunter's Path", npc = "Hunter Trainer", race = { "Orc", "Troll" } },
                { id = 6064, name = "Taming the Beast", npc = "Thotar", race = { "Orc", "Troll" } },
                { id = 6084, name = "Taming the Beast", npc = "Thotar", race = { "Orc", "Troll" } },
                { id = 6085, name = "Taming the Beast", npc = "Thotar", race = { "Orc", "Troll" } },
                { id = 6086, name = "Training the Beast", npc = "Thotar", race = { "Orc", "Troll" } },
            },
        },
        {
            chapter = "Rhok'delar",
            requiredLevel = 60,
            summary = "Bring the Ancient Petrified Leaf to Felwood, hunt the demons named by the ancients, and claim the living bow.",
            recap = "The Ancient Petrified Leaf was not a trophy. It was a summons. The ancients named four demons loose in the world, and the trial demanded the thing every hunter claims to have: control. Alone, precise, and patient, you earned Rhok'delar.",
            quests = {
                { id = 7632, name = "The Ancient Leaf", npc = "Vartrus the Ancient" },
                { id = 7636, name = "Stave of the Ancients", npc = "Vartrus the Ancient" },
                { id = 7635, name = "A Proper String", npc = "Stoma the Ancient" },
                { id = 7634, name = "Ancient Sinew Wrapped Lamina", npc = "Hastat the Ancient" },
            },
        },
    },
}

SM.ClassicMageQuestData = {
    title = "Mage's Wand",
    description = "Tabetha's marsh hut becomes the center of a mage's practical education: old texts, charged materials, and a wand shaped to your chosen school.",
    zone = "Dustwallow Marsh / Scarlet Monastery / Azshara / Dire Maul",
    expansion = "Classic",
    class = "MAGE",
    gameVersions = { classicEra = true, tbc = true },
    color = { 0.25, 0.78, 0.92 },
    icon = 135932,
    adventureCoverTexture = 131835, -- Dire Maul: arcane library setting for Arcane Refreshment
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 1947, name = "Journey to the Marsh", npc = "Mage Trainer" },
    startMapID = 70,
    startX = 0.4600,
    startY = 0.5700,

    chapterIcons = {
        ["Mage's Wand"] = 135463,
        ["Polymorph: Pig"] = 135997,
        ["Arcane Refreshment"] = 132805,
    },

    chapters = {
        {
            chapter = "Mage's Wand",
            requiredLevel = 30,
            summary = "Travel to Tabetha, recover lost magical knowledge, and choose the wand that fits your path.",
            recap = "Tabetha's lesson was part scholarship, part field work, and part old-fashioned danger. The final ritual gave your magic a focus of its own: fire, frost, or arcane power bound into a wand.",
            quests = {
                { id = 1947, name = "Journey to the Marsh", npc = "Mage Trainer" },
                { id = 1949, name = "Hidden Secrets", npc = "Tabetha" },
                { id = 1950, name = "Get the Scoop", npc = "Tabetha" },
                { id = 1951, name = "Rituals of Power", npc = "Tabetha" },
                { id = 1948, name = "Items of Power", npc = "Tabetha" },
                { id = 1952, name = "Mage's Wand", npc = "Tabetha" },
            },
        },
        {
            chapter = "Polymorph: Pig",
            requiredLevel = 60,
            summary = "Azshara's magic is volatile enough to teach a ridiculous but useful spell.",
            recap = "A mage's dignity rarely survives contact with field research. Warlord Krellian's magic fractured into something stranger, and the result was practical, pink, and humiliating.",
            quests = {
                { id = 9362, name = "Warlord Krellian", npc = "Sanath Lim-yo" },
                { id = 9364, name = "Fragmented Magic", npc = "Sanath Lim-yo" },
            },
        },
        {
            chapter = "Arcane Refreshment",
            requiredLevel = 60,
            summary = "Enter Dire Maul and recover the spell that lets a mage conjure proper water for allies.",
            recap = "Every veteran mage eventually learns that power is not always a fireball. Sometimes it is arriving prepared, feeding the group, and making a dungeon run smoother before the first pull.",
            quests = {
                { id = 7463, name = "Arcane Refreshment", npc = "Lorekeeper Lydros" },
            },
        },
    },
}

SM.ClassicPaladinQuestData = {
    title = "The Tome of Valor",
    description = "The paladin's road is written in vows: resurrection, sacrifice, righteous arms, and the charger earned through judgment and redemption.",
    zone = "Stormwind / Ironforge / Western Plaguelands / Scholomance",
    expansion = "Classic",
    class = "PALADIN",
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    color = { 0.96, 0.55, 0.73 },
    icon = 135920,
    adventureCoverTexture = 131868, -- Scholomance: final charger judgment and redemption trial
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 1793, name = "The Tome of Valor", npc = "Duthorian Rall", faction = "Alliance" },
    startMapID = 84,
    startX = 0.3900,
    startY = 0.3200,

    chapterIcons = {
        ["The Tome of Valor"] = 133739,
        ["The Test of Righteousness"] = 132401,
        ["The Charger"] = 136103,
    },

    chapters = {
        {
            chapter = "The Tome of Valor",
            requiredLevel = 20,
            summary = "Carry the lesson of sacrifice from Stormwind to Westfall and learn what it means to protect the helpless.",
            recap = "Valor was not a speech in a cathedral. It was a wounded woman, a dangerous road, and the choice to spend your strength for someone who could not repay it.",
            quests = {
                { id = 1793, name = "The Tome of Valor", npc = "Duthorian Rall", faction = "Alliance" },
                { id = 1649, name = "The Tome of Valor", npc = "Daphne Stilwell", faction = "Alliance" },
                { id = 1650, name = "The Tome of Valor", npc = "Daphne Stilwell", faction = "Alliance" },
                { id = 1651, name = "The Tome of Valor", npc = "Daphne Stilwell", faction = "Alliance" },
                { id = 1652, name = "The Tome of Valor", npc = "Duthorian Rall", faction = "Alliance" },
            },
        },
        {
            chapter = "The Test of Righteousness",
            requiredLevel = 20,
            summary = "Gather rare materials from distant dangers and forge Verigan's Fist.",
            recap = "The weapon was not handed down. It had to be assembled from effort, travel, and stubborn faith. When Verigan's Fist was complete, it felt earned.",
            quests = {
                { id = 1653, name = "The Test of Righteousness", npc = "Duthorian Rall", faction = "Alliance" },
                { id = 1654, name = "The Test of Righteousness", npc = "Jordan Stilwell", faction = "Alliance" },
                { id = 1655, name = "Bailor's Ore Shipment", npc = "Jordan Stilwell", faction = "Alliance" },
                { id = 1442, name = "Seeking the Kor Gem", npc = "Jordan Stilwell", faction = "Alliance" },
                { id = 1806, name = "The Test of Righteousness", npc = "Jordan Stilwell", faction = "Alliance" },
            },
        },
        {
            chapter = "The Charger",
            requiredLevel = 60,
            summary = "Redeem a charger spirit through sacrifice, craft, Stratholme, and Scholomance.",
            recap = "A paladin's charger was not bought. It was rescued from darkness. The trial moved through plague, craft, divination, and judgment until the mount answered the Light again.",
            quests = {
                { id = 7638, name = "Lord Grayson Shadowbreaker", npc = "Duthorian Rall", faction = "Alliance" },
                { id = 7639, name = "To Show Due Judgment", npc = "Lord Grayson Shadowbreaker", faction = "Alliance" },
                { id = 7637, name = "Emphasis on Sacrifice", npc = "Lord Grayson Shadowbreaker", faction = "Alliance" },
                { id = 7640, name = "Exorcising Terrordale", npc = "Lord Grayson Shadowbreaker", faction = "Alliance" },
                { id = 7641, name = "The Work of Grimand Elmore", npc = "Lord Grayson Shadowbreaker", faction = "Alliance" },
                { id = 7642, name = "Collection of Goods", npc = "Grimand Elmore", faction = "Alliance" },
                { id = 7648, name = "Grimand's Finest Work", npc = "Grimand Elmore", faction = "Alliance" },
                { id = 7643, name = "Ancient Equine Spirit", npc = "Lord Grayson Shadowbreaker", faction = "Alliance" },
                { id = 7645, name = "Manna-Enriched Horse Feed", npc = "Merideth Carlson", faction = "Alliance" },
                { id = 7644, name = "Blessed Arcanite Barding", npc = "Lord Grayson Shadowbreaker", faction = "Alliance" },
                { id = 7646, name = "The Divination Scryer", npc = "Lord Grayson Shadowbreaker", faction = "Alliance" },
                { id = 7647, name = "Judgment and Redemption", npc = "Lord Grayson Shadowbreaker", faction = "Alliance" },
            },
        },
    },
}

SM.ClassicPriestQuestData = {
    title = "Benediction",
    description = "A priest's greatest Classic trial begins with the Eye of Divinity and ends in the balance between saving the living and resisting shadow.",
    zone = "Molten Core / Eastern Plaguelands",
    expansion = "Classic",
    class = "PRIEST",
    gameVersions = { classicEra = true, tbc = true },
    color = { 1.00, 1.00, 1.00 },
    icon = 135940,
    adventureCoverTexture = 131851, -- Molten Core: source of the Eye of Divinity before the Benediction trial
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 7622, name = "The Balance of Light and Shadow", npc = "Eris Havenfire" },
    startMapID = 23,
    startX = 0.1700,
    startY = 0.1400,

    chapterIcons = {
        ["The Balance of Light and Shadow"] = 135939,
    },

    chapters = {
        {
            chapter = "The Balance of Light and Shadow",
            requiredLevel = 60,
            summary = "With the Eye of Divinity in hand, protect the spirits of the fallen and earn Benediction.",
            recap = "The trial was not a duel. It was triage under pressure, compassion sharpened into discipline, and shadow waiting for every mistake. When the last spirit survived, the staff answered.",
            quests = {
                { id = 7622, name = "The Balance of Light and Shadow", npc = "Eris Havenfire" },
            },
        },
    },
}

SM.ClassicRogueQuestData = {
    title = "Poisons",
    description = "A rogue's craft lives in preparation: hidden towers, lockboxes, antidotes, and the first deadly edge on a blade.",
    zone = "Westfall / The Barrens / Hillsbrad Foothills / Ravenholdt",
    expansion = "Classic",
    class = "ROGUE",
    gameVersions = { classicEra = true, tbc = true },
    color = { 1.00, 0.96, 0.41 },
    icon = 132320,
    adventureCoverTexture = 131870, -- Stockade: closest Classic loading screen for rogue infiltration and lockwork
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 2360, name = "Mathias and the Defias", npc = "Rogue Trainer", faction = "Alliance" },
    startMapID = 84,
    startX = 0.7400,
    startY = 0.5900,

    chapterIcons = {
        ["Poisons"] = 132273,
        ["Ravenholdt"] = 132331,
    },

    chapters = {
        {
            chapter = "Poisons",
            requiredLevel = 20,
            summary = "Infiltrate hostile ground, prove you can work quietly, and unlock the rogue's most infamous tool.",
            recap = "The lesson was simple: a rogue who cannot enter unseen, open what is locked, and survive their own antidote has no business handling poison.",
            quests = {
                { id = 2360, name = "Mathias and the Defias", npc = "Rogue Trainer", faction = "Alliance" },
                { id = 2359, name = "Klaven's Tower", npc = "Agent Kearnen", faction = "Alliance" },
                { id = 2607, name = "The Touch of Zanzil", npc = "Doc Mixilpixil", faction = "Alliance" },
                { id = 2609, name = "The Touch of Zanzil", npc = "Doc Mixilpixil", faction = "Alliance" },
                { id = 2460, name = "The Shattered Salute", npc = "Rogue Trainer", faction = "Horde" },
                { id = 2458, name = "Deep Cover", npc = "Shenthul", faction = "Horde" },
                { id = 2478, name = "Mission: Possible But Not Probable", npc = "Shenthul", faction = "Horde" },
                { id = 2479, name = "Hinott's Assistance", npc = "Shenthul", faction = "Horde" },
                { id = 2480, name = "Hinott's Assistance", npc = "Serge Hinott", faction = "Horde" },
            },
        },
        {
            chapter = "Ravenholdt",
            requiredLevel = 24,
            summary = "Find the manor hidden in the hills and step into the wider rogue world.",
            recap = "Ravenholdt was not a city trainer's lesson. It was a door into the profession behind the profession: signals, reputation, and thieves who understood exactly what you were becoming.",
            quests = {
                { id = 6681, name = "The Manor, Ravenholdt", npc = "Rogue Trainer" },
            },
        },
    },
}

SM.ClassicShamanQuestData = {
    title = "Call of the Elements",
    description = "The shaman earns power by answering the elements one by one: earth, fire, water, air, and the deeper mastery waiting in the temple.",
    zone = "Durotar / Mulgore / The Barrens / Sunken Temple",
    expansion = "Classic",
    class = "SHAMAN",
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    color = { 0.00, 0.44, 0.87 },
    icon = 136048,
    adventureCoverTexture = 131872, -- Sunken Temple: final Elemental Mastery class trial
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 1516, name = "Call of Earth", npc = "Shaman Trainer", faction = "Horde" },
    startMapID = 10,
    startX = 0.5300,
    startY = 0.4300,

    chapterIcons = {
        ["Call of Earth"] = 136025,
        ["Call of Fire"] = 135824,
        ["Call of Water"] = 135861,
        ["Call of Air"] = 136022,
        ["Elemental Mastery"] = 136075,
    },

    chapters = {
        {
            chapter = "Call of Earth",
            requiredLevel = 4,
            summary = "Seek the earth's trial and earn your first totem.",
            recap = "The earth did not answer because you asked. It answered because you listened, carried its sapta, and proved you could stand steady.",
            quests = {
                { id = 1516, name = "Call of Earth", npc = "Shaman Trainer", race = { "Orc", "Troll" }, faction = "Horde" },
                { id = 1517, name = "Call of Earth", npc = "Canaga Earthcaller", race = { "Orc", "Troll" }, faction = "Horde" },
                { id = 1518, name = "Call of Earth", npc = "Minor Manifestation of Earth", race = { "Orc", "Troll" }, faction = "Horde" },
                { id = 1520, name = "Call of Earth", npc = "Shaman Trainer", race = "Tauren", faction = "Horde" },
                { id = 1521, name = "Call of Earth", npc = "Seer Ravenfeather", race = "Tauren", faction = "Horde" },
            },
        },
        {
            chapter = "Call of Fire",
            requiredLevel = 10,
            summary = "Carry the fire sapta through danger and earn the flame's service.",
            recap = "Fire demanded motion, risk, and offering. By the end, the flame was no longer just destruction. It was a companion at your feet.",
            quests = {
                { id = 1522, name = "Call of Fire", npc = "Shaman Trainer", faction = "Horde" },
                { id = 1524, name = "Call of Fire", npc = "Kranal Fiss", faction = "Horde" },
                { id = 1525, name = "Call of Fire", npc = "Telf Joolam", faction = "Horde" },
                { id = 1526, name = "Call of Fire", npc = "Telf Joolam", faction = "Horde" },
                { id = 1527, name = "Call of Fire", npc = "Minor Manifestation of Fire", faction = "Horde" },
            },
        },
        {
            chapter = "Call of Water",
            requiredLevel = 20,
            summary = "Travel farther than any earlier totem trial, carrying waters between distant lands.",
            recap = "Water was the long lesson. It sent you through Barrens dust, Ashenvale green, and Hillsbrad roads until patience became part of the ritual.",
            quests = {
                { id = 1528, name = "Call of Water", npc = "Shaman Trainer", faction = "Horde" },
                { id = 1530, name = "Call of Water", npc = "Islen Waterseer", faction = "Horde" },
                { id = 1535, name = "Call of Water", npc = "Brine", faction = "Horde" },
                { id = 1536, name = "Call of Water", npc = "Brine", faction = "Horde" },
                { id = 1534, name = "Call of Water", npc = "Brine", faction = "Horde" },
                { id = 220, name = "Call of Water", npc = "Tiev Mordune", faction = "Horde" },
                { id = 63, name = "Call of Water", npc = "Islen Waterseer", faction = "Horde" },
                { id = 100, name = "Call of Water", npc = "Islen Waterseer", faction = "Horde" },
            },
        },
        {
            chapter = "Call of Air",
            requiredLevel = 30,
            summary = "The final leveling totem comes quickly, but it completes the shaman's elemental kit.",
            recap = "Air was brief but essential. With the last totem earned, the circle of elements finally closed around you.",
            quests = {
                { id = 1531, name = "Call of Air", npc = "Shaman Trainer", faction = "Horde" },
            },
        },
        {
            chapter = "Elemental Mastery",
            requiredLevel = 50,
            summary = "Gather proofs of air, fire, earth, and water for the Sunken Temple class trial.",
            recap = "The temple trial asked for more than a single element. It asked whether you could carry all four at once and still know your own voice among them.",
            quests = {
                { id = 8410, name = "Elemental Mastery", npc = "Bath'rah the Windwatcher", faction = "Horde" },
            },
        },
    },
}

SM.ClassicWarlockQuestData = {
    title = "The Binding",
    description = "The warlock's path is a chain of bargains: demons named, bound, dismissed, and finally ridden out of Xoroth itself.",
    zone = "Capital Cities / The Barrens / Burning Steppes / Dire Maul",
    expansion = "Classic",
    class = "WARLOCK",
    gameVersions = { classicEra = true, tbc = true },
    color = { 0.53, 0.53, 0.93 },
    icon = 136145,
    adventureCoverTexture = 131835, -- Dire Maul: Dreadsteed of Xoroth ritual finale
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 1685, name = "Gakin's Summons", npc = "Warlock Trainer", faction = "Alliance" },
    startMapID = 84,
    startX = 0.2600,
    startY = 0.7800,

    chapterIcons = {
        ["Voidwalker"] = 136221,
        ["Succubus"] = 136220,
        ["Felhunter"] = 136217,
        ["Felsteed"] = 136103,
        ["Dreadsteed"] = 136103,
    },

    chapters = {
        {
            chapter = "Voidwalker",
            requiredLevel = 10,
            summary = "Learn the first serious rule of warlock power: summon, bind, command.",
            recap = "The voidwalker was your first true bargain with something that did not want to serve. Names, circles, and willpower turned a threat into a shield.",
            quests = {
                { id = 1685, name = "Gakin's Summons", npc = "Warlock Trainer", race = { "Human", "Gnome" }, faction = "Alliance" },
                { id = 1715, name = "The Slaughtered Lamb", npc = "Gakin the Darkbinder", race = { "Human", "Gnome" }, faction = "Alliance" },
                { id = 1688, name = "Surena Caledon", npc = "Gakin the Darkbinder", race = { "Human", "Gnome" }, faction = "Alliance" },
                { id = 1689, name = "The Binding", npc = "Gakin the Darkbinder", race = { "Human", "Gnome" }, faction = "Alliance" },
                { id = 1478, name = "Halgar's Summons", npc = "Warlock Trainer", race = "Scourge", faction = "Horde" },
                { id = 1473, name = "Creature of the Void", npc = "Carendin Halgar", race = "Scourge", faction = "Horde" },
                { id = 1471, name = "The Binding", npc = "Carendin Halgar", race = "Scourge", faction = "Horde" },
                { id = 1506, name = "Gan'rul's Summons", npc = "Warlock Trainer", race = "Orc", faction = "Horde" },
                { id = 1501, name = "Creature of the Void", npc = "Gan'rul Bloodeye", race = "Orc", faction = "Horde" },
                { id = 1504, name = "The Binding", npc = "Gan'rul Bloodeye", race = "Orc", faction = "Horde" },
            },
        },
        {
            chapter = "Succubus",
            requiredLevel = 20,
            summary = "Follow the Devourer of Souls chain and bind a subtler demon.",
            recap = "Not every demon breaks a door down. Some smile first. The succubus trial taught you that control had to survive temptation as well as terror.",
            quests = {
                { id = 1472, name = "Devourer of Souls", npc = "Carendin Halgar", faction = "Horde" },
                { id = 1476, name = "Hearts of the Pure", npc = "Godrick Farsan", faction = "Horde" },
                { id = 1474, name = "The Binding", npc = "Carendin Halgar", faction = "Horde" },
                { id = 1716, name = "Devourer of Souls", npc = "Gakin the Darkbinder", faction = "Alliance" },
                { id = 1738, name = "Heartswood", npc = "Gakin the Darkbinder", faction = "Alliance" },
                { id = 1739, name = "The Binding", npc = "Gakin the Darkbinder", faction = "Alliance" },
            },
        },
        {
            chapter = "Felhunter",
            requiredLevel = 30,
            summary = "Seek Strahad Farsan and assemble the Tome of the Cabal.",
            recap = "The felhunter was not muscle. It was hunger shaped into an answer to enemy magic. Binding one meant proving you could handle a demon made to hunt power itself.",
            quests = {
                { id = 3001, name = "Seeking Strahad", npc = "Warlock Trainer" },
                { id = 1801, name = "Tome of the Cabal", npc = "Strahad Farsan", faction = "Alliance" },
                { id = 1803, name = "Tome of the Cabal", npc = "Strahad Farsan", faction = "Alliance" },
                { id = 1805, name = "Tome of the Cabal", npc = "Strahad Farsan", faction = "Alliance" },
                { id = 1804, name = "Tome of the Cabal", npc = "Strahad Farsan" },
                { id = 1758, name = "Tome of the Cabal", npc = "Strahad Farsan", faction = "Horde" },
                { id = 1802, name = "Tome of the Cabal", npc = "Strahad Farsan", faction = "Horde" },
                { id = 1795, name = "The Binding", npc = "Strahad Farsan" },
            },
        },
        {
            chapter = "Felsteed",
            requiredLevel = 40,
            summary = "Bind your first demonic mount.",
            recap = "The felsteed was a promise that the road itself could be bent to your will. Other riders bought reins. You made a pact.",
            quests = {
                { id = 4489, name = "Summon Felsteed", npc = "Warlock Trainer", faction = "Alliance" },
                { id = 4490, name = "Summon Felsteed", npc = "Warlock Trainer", faction = "Horde" },
            },
        },
        {
            chapter = "Dreadsteed",
            requiredLevel = 60,
            summary = "Prepare the ritual, bargain in Jaedenar, and open the way to Xoroth in Dire Maul.",
            recap = "The dreadsteed chain was everything warlock training warned about and promised. Blood, stardust, crafted ritual tools, Scholomance errands, and a portal to Xoroth. When the smoke cleared, the nightmare served.",
            quests = {
                { id = 7562, name = "Mor'zul Bloodbringer", npc = "Warlock Trainer" },
                { id = 7563, name = "Rage of Blood", npc = "Mor'zul Bloodbringer" },
                { id = 7564, name = "Wildeyes", npc = "Mor'zul Bloodbringer" },
                { id = 7623, name = "Lord Banehollow", npc = "Gorzeeki Wildeyes" },
                { id = 7624, name = "Ulathek the Traitor", npc = "Lord Banehollow" },
                { id = 7625, name = "Xorothian Stardust", npc = "Lord Banehollow" },
                { id = 7626, name = "Bell of Dethmoora", npc = "Gorzeeki Wildeyes" },
                { id = 7627, name = "Wheel of the Black March", npc = "Gorzeeki Wildeyes" },
                { id = 7628, name = "Doomsday Candle", npc = "Gorzeeki Wildeyes" },
                { id = 7629, name = "Imp Delivery", npc = "Gorzeeki Wildeyes" },
                { id = 7630, name = "Arcanite", npc = "Gorzeeki Wildeyes" },
                { id = 7631, name = "Dreadsteed of Xoroth", npc = "Mor'zul Bloodbringer" },
            },
        },
    },
}

SM.ClassicWarriorQuestData = {
    title = "Whirlwind Weapon",
    description = "The warrior's Classic trials begin with stance discipline and end by calling Cyclonian down for the weapon every leveling warrior remembers.",
    zone = "The Barrens / Stranglethorn Vale / Arathi Highlands",
    expansion = "Classic",
    class = "WARRIOR",
    gameVersions = { classicEra = true, tbc = true },
    color = { 0.78, 0.61, 0.43 },
    icon = 132355,
    adventureCoverTexture = 131824, -- Blackrock Depths: martial arena imagery closest to the warrior weapon trial
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 1638, name = "A Warrior's Training", npc = "Warrior Trainer", faction = "Alliance" },
    startMapID = 10,
    startX = 0.6800,
    startY = 0.3600,

    chapterIcons = {
        ["Defensive Stance"] = 132341,
        ["Whirlwind Weapon"] = 132408,
    },

    chapters = {
        {
            chapter = "Defensive Stance",
            requiredLevel = 10,
            summary = "Complete your first warrior trial and learn the stance that keeps you alive.",
            recap = "The first warrior lesson was not about hitting harder. It was about taking the hit, holding your ground, and understanding that survival can be trained.",
            quests = {
                { id = 1638, name = "A Warrior's Training", npc = "Warrior Trainer", race = "Human", faction = "Alliance" },
                { id = 1639, name = "Bartleby the Drunk", npc = "Harry Burlguard", race = "Human", faction = "Alliance" },
                { id = 1640, name = "Beat Bartleby", npc = "Bartleby", race = "Human", faction = "Alliance" },
                { id = 1665, name = "Bartleby's Mug", npc = "Bartleby", race = "Human", faction = "Alliance" },
                { id = 1684, name = "Elanaria", npc = "Warrior Trainer", race = "NightElf", faction = "Alliance" },
                { id = 1683, name = "Vorlus Vilehoof", npc = "Elanaria", race = "NightElf", faction = "Alliance" },
                { id = 1679, name = "Muren Stormpike", npc = "Warrior Trainer", race = { "Dwarf", "Gnome" }, faction = "Alliance" },
                { id = 1678, name = "Vejrek", npc = "Muren Stormpike", race = { "Dwarf", "Gnome" }, faction = "Alliance" },
                { id = 1818, name = "Speak with Dillinger", npc = "Warrior Trainer", race = "Scourge", faction = "Horde" },
                { id = 1819, name = "Ulag the Cleaver", npc = "Dillinger", race = "Scourge", faction = "Horde" },
                { id = 1505, name = "Veteran Uzzek", npc = "Warrior Trainer", race = { "Orc", "Troll", "Tauren" }, faction = "Horde" },
                { id = 1498, name = "Path of Defense", npc = "Uzzek", race = { "Orc", "Troll", "Tauren" }, faction = "Horde" },
            },
        },
        {
            chapter = "Whirlwind Weapon",
            requiredLevel = 30,
            summary = "Survive the Islander, gather elemental charms, summon Cyclonian, and claim your weapon.",
            recap = "The Whirlwind trial was a warrior rite of passage: bruising, inconvenient, and absolutely worth it. When Cyclonian fell, your reward could carry you for levels.",
            quests = {
                { id = 1718, name = "The Islander", npc = "Warrior Trainer" },
                { id = 1719, name = "The Affray", npc = "Klannoc Macleod" },
                { id = 1791, name = "The Windwatcher", npc = "Klannoc Macleod" },
                { id = 1712, name = "Cyclonian", npc = "Bath'rah the Windwatcher" },
                { id = 1714, name = "Essence of the Exile", npc = "Bath'rah the Windwatcher" },
                { id = 1713, name = "The Summoning", npc = "Bath'rah the Windwatcher" },
                { id = 1792, name = "Whirlwind Weapon", npc = "Bath'rah the Windwatcher" },
            },
        },
    },
}
