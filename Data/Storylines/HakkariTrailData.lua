local addonName, SM = ...

-- =============================================================================
-- Classic: The Hakkari Trail
-- Yeh'kinya, the Mosh'aru Tablets, Hakkar, and the road to Zul'Gurub.
-- =============================================================================

SM.HakkariTrailData = {
    title = "The Hakkari Trail",
    description = "At Steamwheedle Port, Yeh'kinya asks for help with old troll spirits and older tablets. It sounds like simple archaeology, and Yeh'kinya is very polite about it.\n\nFollow the tablets from Feralas and Zul'Farrak into older and darker places, and see where an old troll's errand leads.",
    zone = "Tanaris / Feralas / Zul'Farrak / The Hinterlands / Sunken Temple / Blackrock Spire / Stranglethorn Vale",
    expansion = "Classic",
    recommendedLevel = { min = 40, max = 60 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.82, 0.54, 0.18 },
    icon = 136127,
    adventureGuideInstanceName = "Zul'Farrak",
    adventureCoverTexture = 131886, -- Zul'Gurub loading screen: Hakkari and Zandalar payoff
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 3520, name = "Screecher Spirits", npc = "Yeh'kinya", location = "Steamwheedle Port, Tanaris" },
    startMapID = 71,
    startX = 0.6680,
    startY = 0.2290,

    npcLocations = {
        ["Yeh'kinya"] = { mapID = 71, x = 0.6680, y = 0.2290, location = "Steamwheedle Port, Tanaris" },
        ["Prospector Ironboot"] = { mapID = 71, x = 0.6680, y = 0.2450, location = "Steamwheedle Port, Tanaris" },
        ["Theka the Martyr"] = { mapID = 219, x = 0.4500, y = 0.4400, location = "Zul'Farrak" },
        ["Hydromancer Velratha"] = { mapID = 219, x = 0.6200, y = 0.2800, location = "Zul'Farrak, near Gahz'rilla's pool" },
        ["Ancient Egg"] = { mapID = 26, x = 0.6600, y = 0.6600, location = "the summit cave at Jintha'Alor, The Hinterlands" },
        ["Avatar of Hakkar"] = { mapID = 220, x = 0.3400, y = 0.7800, location = "the Sanctum of the Fallen God, Temple of Atal'Hakkar" },
        ["Mosh'aru Tablets"] = { mapID = 23, x = 0.7200, y = 0.1500, location = "Zul'Mashar, Eastern Plaguelands" },
        ["Smolderthorn Tablets"] = { mapID = 250, x = 0.4200, y = 0.6800, location = "Lower Blackrock Spire" },
        ["Molthor"] = { mapID = 50, x = 0.1500, y = 0.1500, location = "Yojamba Isle, Stranglethorn Vale" },
        ["Tabetha"] = { mapID = 70, x = 0.4600, y = 0.5700, location = "Tabetha's Farm, Dustwallow Marsh" },
        ["Ursyn Ghull"] = { mapID = 88, x = 0.2540, y = 0.1440, location = "Thunder Bluff" },
        ["Krazek"] = { mapID = 50, x = 0.2700, y = 0.7720, location = "Booty Bay, Stranglethorn Vale" },
        ["Tran'rek"] = { mapID = 71, x = 0.5140, y = 0.2680, location = "Gadgetzan, Tanaris" },
        ["Chief Engineer Bilgewhizzle"] = { mapID = 71, x = 0.5240, y = 0.2840, location = "Gadgetzan, Tanaris" },
        ["Trenton Lighthammer"] = { mapID = 71, x = 0.5140, y = 0.2860, location = "Gadgetzan, Tanaris" },
        ["Wizzle Brassbolts"] = { mapID = 64, x = 0.7800, y = 0.7700, location = "Mirage Raceway, Thousand Needles" },
        ["Master Gadrin"] = { mapID = 1, x = 0.5580, y = 0.7440, location = "Sen'jin Village, Durotar" },
        ["Mazu'kon"] = { mapID = 7, x = 0.3240, y = 0.2060, location = "Mulgore" },
        ["Thadius Grimshade"] = { mapID = 17, x = 0.6700, y = 0.1940, location = "Nethergarde Keep, Blasted Lands" },
        ["Archmage Lan'dalock"] = { mapID = 1416, x = 0.1540, y = 0.7380, location = "Dalaran, Alterac Mountains" },
        ["Witch Doctor Uzer'i"] = { mapID = 69, x = 0.7440, y = 0.4340, location = "Camp Mojache, Feralas" },
        ["Marvon Rivetseeker"] = { mapID = 71, x = 0.5260, y = 0.4580, location = "Tanaris" },
        ["Brohann Caskbelly"] = { mapID = 84, x = 0.6940, y = 0.4040, location = "the Dwarven District, Stormwind" },
        ["Fel'zerul"] = { mapID = 51, x = 0.4800, y = 0.5500, location = "Stonard, Swamp of Sorrows" },
        ["Atal'ai Exile"] = { mapID = 26, x = 0.3360, y = 0.7520, location = "The Hinterlands" },
        ["Apothecary Lydon"] = { mapID = 25, x = 0.6140, y = 0.1920, location = "Tarren Mill, Hillsbrad Foothills" },
        ["Gryphon Master Talonaxe"] = { mapID = 26, x = 0.0975, y = 0.4447, location = "Aerie Peak, The Hinterlands" },
        ["Itharius"] = { mapID = 51, x = 0.1367, y = 0.7172, location = "Swamp of Sorrows" },
        ["Angelas Moonbreeze"] = { mapID = 69, x = 0.3183, y = 0.4561, location = "Feathermoon Stronghold, Feralas" },
    },

    chapterDisplayIDs = {
        ["Screecher Spirits"] = 3733,
        ["The Prophecy of Mosh'aru"] = 11279,
        ["The God Hakkar"] = 7842,
        ["The Final Tablets"] = 9291,
        ["The Hand of Rastakhan"] = 15295,
    },

    chapterIcons = {
        ["Screecher Spirits"] = 136122,
        ["The Prophecy of Mosh'aru"] = 133741,
        ["The God Hakkar"] = 136127,
        ["The Final Tablets"] = 134459,
        ["The Hand of Rastakhan"] = 132117,
    },

    npcDisplayIDs = {
        -- Lead-up quest givers: AzerothCore creature_template_model (same models as Classic).
        ["Falstad Wildhammer"] = 7005,
        ["Rhapsody Shindigger"] = 3874,
        -- Quest givers' models from the cmangos Classic database.
        ["Yeh'kinya"] = 7902,
        ["Prospector Ironboot"] = 10195,
        ["Ursyn Ghull"] = 6058,
        ["Tabetha"] = 5375,
        ["Krazek"] = 7164,
        ["Tran'rek"] = 11379,
        ["Chief Engineer Bilgewhizzle"] = 7169,
        ["Trenton Lighthammer"] = 6868,
        ["Wizzle Brassbolts"] = 5428,
        ["Master Gadrin"] = 4072,
        ["Thadius Grimshade"] = 7273,
        ["Witch Doctor Uzer'i"] = 7328,
        ["Marvon Rivetseeker"] = 7188,
        ["Brohann Caskbelly"] = 5079,
        ["Fel'zerul"] = 4554,
        ["Atal'ai Exile"] = 6590,
        ["Apothecary Lydon"] = 1660,
        ["Gryphon Master Talonaxe"] = 7007,
        ["Itharius"] = 4494,
        ["Angelas Moonbreeze"] = 6987,
        -- Quest givers' models from Wowhead's WoW Forever data.
        ["Archmage Lan'dalock"] = 19744,
        ["Mazu'kon"] = 143984,
    },

    chapters = {
        {
            chapter = "Screecher Spirits",
            summary = "Yeh'kinya, a troll at Steamwheedle Port in Tanaris, has the oddest little job on the coast: go to Feralas and catch the spirits of three dead screechers. Yeh'kinya supplies the bramble. You supply the legs.",
            recap = "It started as the oddest little job. A troll in Steamwheedle Port named Yeh'kinya handed me a bramble and sent me to Feralas to catch ghosts. Not big ghosts. Screecher ghosts. Find a dead screecher, use the bramble, and its spirit comes along with you.\n\nThree of them, that's all he wanted. I brought them back, and whatever those spirits told him, he liked it. It had to do with an old troll prophecy.\n\nI remember thinking, what does a dead screecher know about prophecy? More than I did, as it turned out. That was the first thread. I had no idea how much was tied to the other end of it.",
            quests = {
                { id = 3520, name = "Screecher Spirits", npc = "Yeh'kinya" },
            },
        },
        {
            chapter = "The Prophecy of Mosh'aru",
            summary = "Whatever the screecher spirits told Yeh'kinya, it had to do with an old troll prophecy written on tablets. The first two Mosh'aru tablets are in Zul'Farrak, among the sand trolls, and Yeh'kinya would very much like to read them.",
            recap = "The prophecy, it turned out, was written on tablets, and the tablets were in Zul'Farrak. Where else. Sand, heat, sand trolls, more sand. I brought two of them back and Yeh'kinya read them like a letter from home.\n\nThe tablets spoke of an ancient egg from the days of the old troll empires, and that egg sat in a cave at the top of Jintha'Alor, with every Vilebranch in the Hinterlands between me and it. I went up. I came down with the egg. The Vilebranch had a lot to say about that, most of it at the tops of their voices.\n\nYeh'kinya held it like a newborn. I've seen parents with less care.",
            quests = {
                { id = 3527, name = "The Prophecy of Mosh'aru", npc = "Yeh'kinya" },
                { id = 4787, name = "The Ancient Egg", npc = "Yeh'kinya" },
                { id = 2861, name = "Tabetha's Task", npc = "Ursyn Ghull", optional = true, breadcrumbFor = 2846 },
                { id = 2846, name = "Tiara of the Deep", npc = "Tabetha", optional = true, recap = "Tabetha keeps a farm out in the Dustwallow muck, and while she was away somebody raided it and made off with her Tiara of the Deep. It turned up on Hydromancer Velratha, a sand troll in Zul'Farrak. I brought it home, and Tabetha apologized for having been so sharp with me, which almost never happens." },
                { id = 2864, name = "Tran'rek", npc = "Krazek", optional = true, breadcrumbFor = 2865 },
                { id = 2865, name = "Scarab Shells", npc = "Tran'rek", optional = true, recap = "Tran'rek in Gadgetzan had promised a cousin in Booty Bay a load of scarab shells weeks ago and was still telling stories instead of delivering. The last scarabs in Tanaris live in Zul'Farrak, so I went and got five. Uncracked, as ordered, though the scarabs had their own ideas about that." },
                { id = 2768, name = "Divino-matic Rod", npc = "Chief Engineer Bilgewhizzle", optional = true, recap = "Chief Engineer Bilgewhizzle in Gadgetzan had lent a Divino-matic Rod, a gadget for finding water, to a Sergeant Bly, who took it into Zul'Farrak with a band of adventurers and kept it. I found Bly and asked nicely. Then I asked the other way, which the engineer liked a lot better." },
                { id = 3042, name = "Troll Temper", npc = "Trenton Lighthammer", optional = true, recap = "Trenton Lighthammer in Gadgetzan wanted twenty vials of troll temper, which the Sandfury brew out of sandstone. They carry it on them, so gathering it was mostly a matter of gathering trolls. Trenton called it very nice temper indeed, and I've never thought about temper since." },
                -- The Mallet of Zul'Farrak rings the gong that calls Gahz'rilla, and no quest
                -- gives it: Qiaga the Keeper drops the Sacred Mallet at the Altar of Zul, and
                -- using it at the altar atop Jintha'Alor makes the Mallet. It isn't used up,
                -- so the step is done once the character has held it.
                { item = 9240, name = "Mallet of Zul'Farrak", optional = true, mapID = 26, x = 0.4840, y = 0.6800, location = "the Altar of Zul, The Hinterlands", objective = "Take the Sacred Mallet from Qiaga the Keeper at the top of the Altar of Zul. Then use it at the altar at the top of Jintha'Alor to make the Mallet of Zul'Farrak, which rings the gong at Gahz'rilla's pool.", recap = "The gong at Gahz'rilla's pool in Zul'Farrak answers to one mallet, and nobody sells it. Qiaga the Keeper had the Sacred Mallet at the top of the Altar of Zul and no plans to give it up. I took it anyway. It still had to go to the altar at the top of Jintha'Alor, and one use there made it the Mallet of Zul'Farrak.\n\nIt doesn't break and it doesn't get used up, so I can ring for that hydra whenever I like. Whether I'd like to is another matter." },
                { id = 2770, name = "Gahz'rilla", npc = "Wizzle Brassbolts", optional = true, recap = "Wizzle Brassbolts at the Mirage Raceway wanted an electrified scale off Gahz'rilla to power a racing car. Gahz'rilla is a hydra the Zul'Farrak trolls keep in a sacred pool, and they don't lend it out. Wizzle's only question when I got back was how big it really was, and the honest answer is bigger than whatever you're picturing." },
                -- The Spider God comes after Apothecary Lydon's venom quests, which start at a
                -- Venom Bottle in a Witherbark village.
                { id = 2933, name = "Venom Bottles", npc = "Venom Bottle", faction = "Horde", optional = true, mapID = 26, x = 0.2320, y = 0.5850, location = "The Hinterlands" },
                { id = 2934, name = "Undamaged Venom Sac", npc = "Apothecary Lydon", faction = "Horde", optional = true, afterQuest = 2933 },
                { id = 2935, name = "Consult Master Gadrin", npc = "Apothecary Lydon", faction = "Horde", optional = true, afterQuest = 2934, recap = "In a Witherbark village in the Hinterlands there were more bottles of vile green venom than any troll needs, so I took one to Apothecary Lydon in Tarren Mill. Lydon wanted better than a bottle: an undamaged venom sac, and undamaged was the hard part. Once Lydon had it, the question was what kind of spider the trolls had been milking, and Lydon sent me to ask Master Gadrin in Sen'jin Village, who knows trolls." },
                { id = 2936, name = "The Spider God", npc = "Master Gadrin", faction = "Horde", optional = true, afterQuest = 2935, recap = "Master Gadrin in Sen'jin Village needed the true name of the spider god the Witherbark worship, and it was written on a tablet in Zul'Farrak that Theka the Martyr was guarding. Theka stopped guarding it. The name is Elortha no Shadra, and I'm told to say it only in whispers, so lean in." },
                { id = 2937, name = "Summoning Shadra", npc = "Master Gadrin", faction = "Horde", optional = true, afterQuest = 2936 },
                { id = 2938, name = "Venom to the Undercity", npc = "Apothecary Lydon", faction = "Horde", optional = true, afterQuest = 2937, recap = "Master Gadrin turned the spider god's true name into a spell of summoning and sent me to read it at the altar of Shadra'Alor, deep in Witherbark country. I read it, and Shadra came. The Witherbark get their strongest venom from her. Now so did I.\n\nApothecary Lydon in Tarren Mill was delighted. One drop had killed nearly two dozen rabbits, he told me, though he admitted some of them had been very small. He wanted a sample sent to his superior in the Undercity, so I carried it there, and the Royal Apothecary Society called my service undeniable. Nobody asked the rabbits." },
                { id = 96775, name = "Zum'rah's Head", npc = "Mazu'kon", faction = "Horde", optional = true, gameVersions = { forever = true }, recap = "Mazu'kon, out in Mulgore, wanted the head of Witch Doctor Zum'rah, who keeps the graveyard in Zul'Farrak and doesn't welcome visitors. Zum'rah raised the dead at us by the handful. The head came back with me anyway, which was the only part Mazu'kon cared about." },
                -- Nekrum's Medallion comes after Gryphon Master Talonaxe's search for Sharpbeak.
                { id = 2988, name = "Witherbark Cages", npc = "Gryphon Master Talonaxe", faction = "Alliance", optional = true },
                { id = 2989, name = "The Altar of Zul", npc = "Gryphon Master Talonaxe", faction = "Alliance", optional = true, afterQuest = 2988 },
                { id = 2990, name = "Thadius Grimshade", npc = "Gryphon Master Talonaxe", faction = "Alliance", optional = true, afterQuest = 2989, recap = "Gryphon Master Talonaxe at Aerie Peak had lost a young gryphon called Sharpbeak and suspected the Witherbark trolls. I searched the cages in both of their villages and found no gryphon. At the top of the Altar of Zul I found one of Sharpbeak's feathers, and no Sharpbeak. Talonaxe sent me off with the feather to Thadius Grimshade at Nethergarde Keep, who finds things by other means." },
                { id = 2991, name = "Nekrum's Medallion", npc = "Thadius Grimshade", faction = "Alliance", optional = true, afterQuest = 2990, recap = "Thadius Grimshade at Nethergarde Keep offered to find a lost gryphon named Sharpbeak by magic, in exchange for Nekrum Gutchewer's medallion out of Zul'Farrak. Rumor said it gave its wearer an unnaturally long life at a price, and Grimshade was confident the price could be avoided. They always are." },
                { id = 2992, name = "The Divination", npc = "Thadius Grimshade", faction = "Alliance", optional = true, afterQuest = 2991 },
                { id = 2993, name = "Return to the Hinterlands", npc = "Thadius Grimshade", faction = "Alliance", optional = true, afterQuest = 2992 },
                { id = 2994, name = "Saving Sharpbeak", npc = "Gryphon Master Talonaxe", faction = "Alliance", optional = true, afterQuest = 2993, recap = "Grimshade kept his end of the bargain. He asked for room to work and warned me that if the ritual went wrong, I'd better close my eyes. It didn't. Sharpbeak was in a cage at the top of Jintha'Alor, and the high priestess of the Vilebranch trolls had the key.\n\nGryphon Master Talonaxe took the news about as calmly as a dwarf can, which is to say not at all. So up I went, all the way to the top of Jintha'Alor, took the key off the priestess, and opened the cage.\n\nSharpbeak's parents flew home with him and fussed over him like new parents, and Talonaxe admitted to a little mist in the eyes. The gryphons of Aerie Peak will sing my name, he says, for a long, long time." },
                { id = 96770, name = "The Witch Doctor's Head", npc = "Archmage Lan'dalock", faction = "Alliance", optional = true, gameVersions = { forever = true }, recap = "Archmage Lan'dalock of Dalaran wanted the head of Witch Doctor Zum'rah, who keeps the graveyard in Zul'Farrak. Zum'rah's reply was to wake the graveyard up. The archmage got the head all the same, and I learned that the dead there stay down only once their witch doctor does." },
            },
        },
        {
            chapter = "The God Hakkar",
            summary = "Yeh'kinya has the ancient egg from Jintha'Alor and now wants it filled with the essence of Hakkar. That means the very bottom of the sunken Temple of Atal'Hakkar, in the Swamp of Sorrows. Don't go alone.",
            recap = "Then Yeh'kinya told me what the egg was for. It was a vessel, and he wanted it filled. With Hakkar.\n\nSo down into the Temple of Atal'Hakkar I went, the sunken one in the Swamp of Sorrows, and not alone, because that place doesn't take visitors one at a time. At the very bottom, in the Sanctum of the Fallen God, the Avatar of Hakkar rose up to meet us. Big. Winged. Furious. We put it down, I used the egg, and the egg drank in the essence of a god like dry ground takes rain.\n\nI carried it back to Tanaris in my pack, between my bedroll and my supper, and felt it the whole way.\n\nLooking back, that was the moment to start asking questions. I didn't. It was a very nice egg.",
            quests = {
                { id = 3528, name = "The God Hakkar", npc = "Yeh'kinya" },
                { id = 3380, name = "The Sunken Temple", npc = "Witch Doctor Uzer'i", faction = "Horde", optional = true },
                { id = 3445, name = "The Sunken Temple", npc = "Angelas Moonbreeze", faction = "Alliance", optional = true },
                { id = 3444, name = "The Stone Circle", npc = "Marvon Rivetseeker", optional = true, recap = "Marvon Rivetseeker had left something called the Stone Circle in a workshop in Ratchet and wanted it fetched. I fetched it, and Marvon had plans for it." },
                { id = 3446, name = "Into the Depths", npc = "Marvon Rivetseeker", optional = true, afterQuest = 3444, recap = "Marvon Rivetseeker, a goblin who studies troll ruins, had been inside the Sunken Temple once and nearly died poking a serpent statue. Marvon's theory was that the altar at the bottom of the round room held the secret, so down I went with a stone circle to test it. It fit exactly and locked in place, which in that temple is never the end of it." },
                { id = 3447, name = "Secret of the Circle", npc = "Marvon Rivetseeker", optional = true, afterQuest = 3444, recap = "Marvon Rivetseeker had a hazy memory of lights over the ring of serpent statues in the Sunken Temple, and a hunch they guarded treasure. Light them in the right order and something does happen: a very large guardian turns up to object. Behind the idol's glass eye sat the Atal'ai treasure, worth every bit of the argument." },
                -- Brohann Caskbelly's temple quest comes after the search that leads to Rhapsody Shindigger.
                { id = 1448, name = "In Search of The Temple", npc = "Brohann Caskbelly", faction = "Alliance", optional = true },
                { id = 1449, name = "To The Hinterlands", npc = "Brohann Caskbelly", faction = "Alliance", optional = true, afterQuest = 1448 },
                { id = 1450, name = "Gryphon Master Talonaxe", npc = "Falstad Wildhammer", faction = "Alliance", optional = true, afterQuest = 1449, mapID = 26, x = 0.1180, y = 0.4680 },
                { id = 1451, name = "Rhapsody Shindigger", npc = "Gryphon Master Talonaxe", faction = "Alliance", optional = true, afterQuest = 1450 },
                { id = 1452, name = "Rhapsody's Kalimdor Kocktail", npc = "Rhapsody Shindigger", faction = "Alliance", optional = true, afterQuest = 1451, mapID = 26, x = 0.2680, y = 0.4840 },
                { id = 1469, name = "Rhapsody's Tale", npc = "Rhapsody Shindigger", faction = "Alliance", optional = true, afterQuest = 1452, mapID = 26, x = 0.2680, y = 0.4840, recap = "Brohann Caskbelly of the Explorers' League in Stormwind wanted the Temple of Atal'Hakkar found, and the trail started in the Hinterlands. High Thane Falstad Wildhammer at Aerie Peak sent me to Gryphon Master Talonaxe, who sent me to Rhapsody Shindigger, who knew a tale about the temple and would tell it for a cocktail of roc gizzards, groddoc livers and ironfur livers. I brought the ingredients, heard the tale, and carried a fragment of an Atal'ai tablet back to Brohann." },
                { id = 1475, name = "Into The Temple of Atal'Hakkar", npc = "Brohann Caskbelly", faction = "Alliance", optional = true, afterQuest = 1469, recap = "Brohann Caskbelly in Stormwind had one last assignment for the Explorers' League before retiring: ten Atal'ai tablets out of the Sunken Temple. Pride kept him from asking for help, right up until he asked me. I brought the tablets, and Brohann said both our names would go into the League's history, though I've never gone to check." },
                { id = 1424, name = "Pool of Tears", npc = "Fel'zerul", faction = "Horde", optional = true },
                { id = 1429, name = "The Atal'ai Exile", npc = "Fel'zerul", faction = "Horde", optional = true, afterQuest = 1424 },
                { id = 1444, name = "Return to Fel'Zerul", npc = "Atal'ai Exile", faction = "Horde", optional = true, afterQuest = 1429, recap = "Fel'zerul in Stonard wanted to know more about the trolls at the Pool of Tears, and sent me to collect ten of their Atal'ai artifacts. Fel'zerul couldn't make sense of them and sent me with the bundle to an Atal'ai exile hiding in the Hinterlands, who could. Then I took what the exile had to say back to Stonard." },
                { id = 1445, name = "The Temple of Atal'Hakkar", npc = "Fel'zerul", faction = "Horde", optional = true, afterQuest = 1444, recap = "Fel'zerul in Stonard didn't trust the Atal'ai or their talk of Hakkar making them immortal, and wanted twenty of their Fetishes of Hakkar to learn what they were for. Twenty is a lot of fetishes. Every one of them came off an Atal'ai who believed very sincerely." },
                { id = 1446, name = "Jammal'an the Prophet", npc = "Atal'ai Exile", optional = true, recap = "An Atal'ai exile out in the Hinterlands, cast out by the tribe, wanted the head of Jammal'an the Prophet, who had convinced them all that Hakkar would make them immortal. I brought the head. The exile had hoped it might free the tribe, and mourned them anyway." },
                { id = 3373, name = "The Essence of Eranikus", npc = "Essence of Eranikus", optional = true, recap = "When the shade of Eranikus fell, it left a gem holding part of the dragon's essence, and a voice asking me to set it in the font in its lair so it could finally rest. I did, and the font turned out to be tainted as well, and the last I heard was Eranikus begging me to find the green dragonflight. I've done favors that went better." },
                { id = 3374, name = "The Essence of Eranikus", npc = "Oathstone of Ysera's Dragonflight", optional = true, afterQuest = 3373 },
                { id = 3512, name = "In Eranikus' Own Words", npc = "Itharius", optional = true, afterQuest = 3374, recap = "Through an oathstone of the green dragonflight, a dragon named Itharius spoke straight into my mind. If I gave him the gem that had chained what was left of Eranikus, we would work together to redeem him. I gave it up. Itharius said my choices so far had been the right ones, and that my deeds from here on would decide whether that continued. No pressure.\n\nFirst we needed to speak with Eranikus through the gem, so Itharius sent me to the far east of Winterspring, to a medium named Umbranse who speaks for the dead. Umbranse was willing. But his best augury device had been taken from him, and without it there was nothing to be done.\n\nI'm still waiting to hear who took it." },
            },
        },
        {
            chapter = "The Final Tablets",
            summary = "Prospector Ironboot at Steamwheedle Port has a question about the Mosh'aru tablets: how many do you think there are? Two more lie in Zul'Mashar, in the Eastern Plaguelands, and the prospector would like them brought back.",
            recap = "Back in Steamwheedle Port, Prospector Ironboot stopped me with a question. Did I know there were six Mosh'aru tablets? Not two. Six. Yeh'kinya had somehow forgotten to mention the other four.\n\nTwo of them were in Zul'Mashar, out in the Eastern Plaguelands, which is a fine place to visit if you enjoy being chewed on. The last two were in Lower Blackrock Spire, which is worse. I fetched all four, and Ironboot read the whole set.\n\nRead whole, the prophecy said something else entirely. Two tablets sounded like a way to keep Hakkar out of the world. Six sounded like a way to let him back in.\n\nI thought about that egg, and every mile I'd carried it. I'd been a great help to somebody. I just hadn't asked who.",
            quests = {
                { id = 5065, name = "The Lost Tablets of Mosh'aru", npc = "Prospector Ironboot" },
                { id = 4788, name = "The Final Tablets", npc = "Prospector Ironboot" },
            },
        },
        {
            chapter = "The Hand of Rastakhan",
            summary = "Prospector Ironboot has read all six Mosh'aru tablets and thinks it's time you and Yeh'kinya had a talk. Yeh'kinya is still at Steamwheedle Port, just down the way. The walk is the easy part.",
            recap = "The prospector reckoned I ought to go and have a word with Yeh'kinya. The prospector was right.\n\nI won't give you the whole conversation. The short of it was that Hakkar the Soulflayer was coming back into the world through Zul'Gurub, and the trolls who meant to meet him there were the Zandalar. Somebody had to carry word to their man Molthor, out on Yojamba Isle off the coast of Stranglethorn. That was me.\n\nSo a job that started with a bramble and three dead screechers ended with me on a beach full of Zandalar, with Zul'Gurub the obvious next stop.\n\nThat one's a story for another night. Buy the next round and I might tell it.",
            quests = {
                { id = 8181, name = "Confront Yeh'kinya", npc = "Prospector Ironboot" },
                { id = 8182, name = "The Hand of Rastakhan", npc = "Prospector Ironboot" },
            },
        },
    },
}
