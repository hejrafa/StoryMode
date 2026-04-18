local addonName, SM = ...

-- =============================================================================
-- Lilian Voss: The Forsaken Daughter
-- A saga spanning Cataclysm, Mists of Pandaria, Battle for Azeroth,
-- and Shadowlands — from Deathknell to the dungeons of the Scarlet Crusade
-- to the shores of Kul Tiras, to the ruins of Undercity, and finally home.
-- =============================================================================

SM.LilianVossData = {
    -- Questline metadata
    title = "The Forsaken Daughter",
    description = "Lilian Voss was trained from birth to serve the Scarlet Crusade and destroy the undead. When the Val'kyr raise her as Forsaken in Deathknell, she refuses to accept what she has become. Desperate for acceptance, she seeks out her father — High Priest Benedictus Voss — only to be condemned to death by the man who raised her.\n\nWhat follows is a saga of vengeance and identity that stretches across years: a trail of fire and shadow through the Scarlet Halls and Monastery, a descent into the cursed halls of Scholomance, and a new war on the shores of Kul Tiras. The war delivers a prize — Derek Proudmoore, drowned at the bottom of the sea. Sylvanas puts him in Lilian's hands with one order: break him. Make him a weapon. Lilian has lived that story. Her answer costs her everything.\n\nBut the story does not end with defiance. It ends in Lordaeron — Lilian leading her people home, room by room, through the Blight.",
    zone = "Tirisfal Glades / Kul Tiras / Lordaeron",
    expansion = "Cataclysm — Shadowlands",
    achievements = { 15579 },  -- Return to Lordaeron
    faction = "Horde",
    color = { 0.75, 0.12, 0.18 },  -- Scarlet Crusade crimson
    portraitDisplayID = 85799,  -- Lilian Voss (BfA model) as card portrait

    -- Start location: Caretaker Caice in Deathknell
    startQuest = { id = 24960, name = "The Wakening", npc = "Caretaker Caice", location = "Deathknell, Tirisfal Glades" },
    startMapID = 18,    -- Tirisfal Glades
    startX = 0.3060,
    startY = 0.7140,

    -- Key NPC locations for waypoint guidance (mapID, x, y)
    npcLocations = {
        -- Tirisfal Glades
        ["Caretaker Caice"]           = { mapID = 18,  x = 0.3060, y = 0.7140 },
        ["Novice Elreth"]             = { mapID = 18,  x = 0.2780, y = 0.6760 },
        ["Deathguard Simmer"]         = { mapID = 18,  x = 0.4470, y = 0.5350 },
        ["Executor Zygand"]           = { mapID = 18,  x = 0.4510, y = 0.5460 },
        ["High Executor Derrington"]  = { mapID = 18,  x = 0.5820, y = 0.5200 },
        ["Lieutenant Sanders"]        = { mapID = 18,  x = 0.5300, y = 0.5300 },
        -- Dungeons (interior — coordinates not meaningful)
        ["Hooded Crusader"]           = { mapID = 18,  x = 0.8540, y = 0.3100 },
        ["Talking Skull"]             = { mapID = 18,  x = 0.7000, y = 0.7300 },
        -- BfA — Zuldazar / Kul Tiras
        ["Nathanos Blightcaller"]     = { mapID = 862, x = 0.5840, y = 0.6260 },
        ["Lilian Voss"]               = { mapID = 862, x = 0.5840, y = 0.6260 },
        ["Rexxar"]                    = { mapID = 942, x = 0.5200, y = 0.3360 },
        ["Thomas Zelling"]            = { mapID = 942, x = 0.5956, y = 0.3070 },
        -- BfA — At the Bottom of the Sea
        ["Dread-Admiral Tattersail"]  = { mapID = 862, x = 0.5620, y = 0.6480 },  -- Banshee's Wail, Port of Zandalar
        ["Hobart Grapplehammer"]      = { mapID = 862, x = 0.5620, y = 0.6480 },  -- aboard ship before dive
        -- BfA — Strike on Boralus / Testing Loyalties
        ["Captain Amalia Stone"]      = { mapID = 862, x = 0.5620, y = 0.6480 },  -- VERIFY: Banshee's Wail / Stormsong
        ["Baine Bloodhoof"]           = { mapID = 862, x = 0.5840, y = 0.6260 },  -- Banshee's Wail / Plunder Harbor
        ["Sylvanas Windrunner"]       = { mapID = 862, x = 0.5840, y = 0.6260 },
        ["Derek Proudmoore"]          = { mapID = 862, x = 0.5840, y = 0.6260 },
        -- 9.2.5 — Return to Lordaeron (Brill / Ruins of Lordaeron, Tirisfal)
        ["Calia Menethil"]            = { mapID = 18,  x = 0.5670, y = 0.5910 },  -- Brill
        ["Master Apothecary Faranell"]= { mapID = 18,  x = 0.5990, y = 0.6400 },  -- House of Plagues / Undercity ruins
        ["Dark Ranger Velonara"]      = { mapID = 18,  x = 0.5990, y = 0.6400 },
    },

    -- NPC creature display IDs for chapter portraits
    -- Used with SetPortraitTextureFromCreatureDisplayID()
    -- Look up on wowhead.com model viewer or /run print(UnitCreatureDisplayID("target"))
    npcDisplayIDs = {
        -- Tirisfal Glades NPCs
        ["Caretaker Caice"]             = 3522,
        ["Novice Elreth"]               = 1593,
        ["Deathguard Simmer"]           = 1648,
        ["Executor Zygand"]             = 1649,
        ["High Executor Derrington"]    = 10150,
        ["Lieutenant Sanders"]          = 13090,
        -- Dungeon NPCs
        ["Hooded Crusader"]             = 43650,   -- Lilian in disguise
        ["Talking Skull"]               = 40322,
        -- BfA NPCs
        ["Lilian Voss"]                 = 64531,
        ["Nathanos Blightcaller"]       = 86219,
        ["Rexxar"]                      = 22319,
        ["Thomas Zelling"]              = 86134,
        ["Dread-Admiral Tattersail"]    = 64374,   -- VERIFY
        ["Hobart Grapplehammer"]        = 23704,   -- VERIFY: goblin tinker model
        ["Captain Amalia Stone"]        = 86452,   -- VERIFY
        ["Baine Bloodhoof"]             = 86237,   -- VERIFY: BfA Baine model
        ["Sylvanas Windrunner"]         = 28213,
        ["Derek Proudmoore"]            = 86396,   -- VERIFY: undead Derek model
        -- 9.2.5 NPCs
        ["Calia Menethil"]              = 92900,
        ["Master Apothecary Faranell"]  = 25262,   -- VERIFY
        ["Dark Ranger Velonara"]        = 92615,   -- VERIFY
    },
    chapterDisplayIDs = {
        ["The Wakening"] = 67721, -- Lilian Voss
    },
    chapterIcons = {
        ["The Wakening"] = 67721,
    },

    -- =========================================================================
    -- ACT I — TIRISFAL GLADES (Cataclysm)
    -- A daughter of the Scarlet Crusade is raised as the thing she was
    -- trained to destroy.
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: Raised against her will
        {
            chapter = "The Wakening",
            summary = "The Val'kyr raise new Forsaken in the crypt of Deathknell. Among them is a young woman who refuses to accept what she has become — Lilian Voss, daughter of High Priest Benedictus Voss of the Scarlet Crusade.",
            recap = "You opened your eyes in the crypt of Deathknell, raised by the Val'kyr as one of the Forsaken. Among the newly risen was a young woman trembling with rage — Lilian Voss, daughter of the Scarlet Crusade's High Priest. While you accepted your new existence, she could not. She fled into the darkness, refusing to believe what she had become.",
            quests = {
                { id = 24960, name = "The Wakening",           npc = "Lilian Voss" },
                { id = 24961, name = "The Truth of the Grave",  npc = "Novice Elreth" },
            },
        },

        -- CHAPTER 2: First contact with the Scarlet Crusade
        {
            chapter = "A Scarlet Letter",
            summary = "The Forsaken push into the farmlands surrounding Deathknell, where the Scarlet Crusade maintains a fortified palisade. Inside, a familiar prisoner awaits — Lilian Voss, captured by the very order she once served.",
            recap = "Pushing through the farmlands around Deathknell, you clashed with the Scarlet Crusade at their palisade. Inside the fortifications you found Lilian — captured by the zealots she once served. Her captors didn't care that she had been one of them. To the Crusade, she was just another undead abomination to be purged.",
            quests = {
                { id = 24978, name = "Reaping the Reapers",    npc = "Deathguard Simmer" },
                { id = 24979, name = "A Scarlet Letter",        npc = "Deathguard Simmer" },
                { id = 24980, name = "The Scarlet Palisade",    npc = "Deathguard Simmer" },
                { id = 24981, name = "A Thorn in Our Side",     npc = "Executor Zygand" },
            },
        },

        -- CHAPTER 3: Father and daughter, one last time
        {
            chapter = "A Daughter's Embrace",
            summary = "Lilian tears through the crusaders with terrifying shadow magic, then marches to the tower at Crusader's Run to face the father who condemned her to death. She kills him — and vanishes.",
            recap = "Something broke inside Lilian Voss. Shadow magic erupted from her hands as she tore through the crusaders with a fury that terrified even the Forsaken. She marched to the tower where her father, High Priest Benedictus Voss, waited — and when he condemned her as a monster, she killed him. Then she vanished, leaving nothing but silence and the smell of burning.",
            quests = {
                { id = 25009, name = "At War With The Scarlet Crusade", npc = "High Executor Derrington" },
                { id = 25010, name = "A Deadly New Ally",               npc = "High Executor Derrington" },
                { id = 25046, name = "A Daughter's Embrace",            npc = "Lieutenant Sanders" },
            },
        },

        -- =====================================================================
        -- ACT II — SCARLET HALLS, MONASTERY & SCHOLOMANCE (Mists of Pandaria)
        -- Lilian returns as a hooded infiltrator, hunting the Crusade's
        -- remnants through their own strongholds.
        -- =====================================================================

        -- CHAPTER 4: Infiltrating the Scarlet Halls
        {
            chapter = "The Scarlet Halls",
            summary = "A hooded figure lurks inside the Scarlet Halls, offering coin for carnage. She wants the Crusade's membership records — a checklist of every name, just so none go unaccounted for. The Hooded Crusader does not like loose ends.",
            recap = "Years passed before Lilian surfaced again — this time as a hooded figure lurking inside the Scarlet Halls. She hired you to slaughter your way through the Crusade's ranks and steal their membership records. Every name on that list was a target. Lilian Voss was no longer running from the Crusade — she was hunting them down, one by one.",
            quests = {
                { id = 31490, name = "Rank and File",                    npc = "Hooded Crusader" },
                { id = 31493, name = "Just for Safekeeping, Of Course",  npc = "Hooded Crusader" },
            },
        },

        -- CHAPTER 5: Destroying the Scarlet Monastery
        {
            chapter = "The Scarlet Monastery",
            summary = "The Hooded Crusader slips inside the Scarlet Monastery itself. Two blessed blades rest within these halls — weapons anointed to destroy the undead. She wants them found, and she wants them buried in High Inquisitor Whitemane's corpse.",
            recap = "The Hooded Crusader's campaign reached the Scarlet Monastery itself. You retrieved the blessed blades of the Anointed — weapons consecrated to destroy the undead — and drove them into High Inquisitor Whitemane. The irony was not lost on Lilian: the Crusade's holiest weapons, wielded by the dead, against the Crusade's own champion.",
            quests = {
                { id = 31513, name = "Blades of the Anointed",           npc = "Hooded Crusader" },
                { id = 31514, name = "Unto Dust Thou Shalt Return",      npc = "Hooded Crusader" },
            },
        },

        -- CHAPTER 6: Scholomance — consumed by vengeance
        {
            chapter = "Scholomance",
            summary = "Lilian's hunt for dark knowledge leads her into the cursed academy of Scholomance. Within its halls she confronts Darkmaster Gandling — but the darkness she wields threatens to consume her entirely. She must destroy the forbidden tomes and end the suffering, or become the very evil she hunts.",
            recap = "Lilian's pursuit of power led her into Scholomance, the cursed academy of necromancy. Through a talking skull she guided you to destroy the Four Tomes of forbidden knowledge and end the suffering within those walls. But when she faced Darkmaster Gandling, the darkness she wielded nearly consumed her. She survived — but the line between hunter and monster grew thinner.",
            quests = {
                { id = 31440, name = "The Four Tomes",                   npc = "Talking Skull" },
                { id = 31447, name = "An End to the Suffering",          npc = "Talking Skull" },
            },
        },

        -- =====================================================================
        -- ACT III — HORDE WAR CAMPAIGN (Battle for Azeroth)
        -- Years later. Lilian serves the Horde on the shores of Kul Tiras,
        -- but the war forces her to confront what it means to be Forsaken.
        -- =====================================================================

        -- CHAPTER 7: Tiragarde Sound — The First Assault
        {
            chapter = "The First Assault",
            note = "Requires: Battle for Azeroth. Complete the Horde War Campaign introduction and travel to Zuldazar before this chapter becomes available.",
            summary = "Nathanos Blightcaller and Lilian Voss lead a covert strike into the heart of Tiragarde Sound. While Nathanos secures the mountain outpost, Lilian takes command of the Bridgeport operation — sabotaging Ashvane foundries, planting explosives, and riding through the chaos she created.",
            recap = "Years later, Lilian served the Horde on the shores of Kul Tiras. While Nathanos Blightcaller secured a mountain outpost, Lilian led you through Bridgeport — sabotaging foundries, planting explosives, and riding through the flames of your own making. She was efficient, ruthless, and completely in her element. The girl who once trembled in Deathknell was gone.",
            quests = {
                { id = 51589, name = "Breaking Kul Tiran Will",          npc = "Nathanos Blightcaller" },
                { id = 51590, name = "Into the Heart of Tiragarde",      npc = "Nathanos Blightcaller" },
                { id = 51591, name = "Our Mountain Now",                  npc = "Nathanos Blightcaller" },
                { id = 51592, name = "Making Ourselves at Home",          npc = "Nathanos Blightcaller" },
                { id = 51593, name = "Bridgeport Investigation",          npc = "Lilian Voss" },
                { id = 51594, name = "Explosives in the Foundry",         npc = "Lilian Voss" },
                { id = 51595, name = "Explosivity",                       npc = "Lilian Voss" },
                { id = 51596, name = "Ammunition Acquisition",            npc = "Lilian Voss" },
                { id = 51597, name = "Gunpowder Research",                npc = "Lilian Voss" },
                { id = 51598, name = "A Bit of Chaos",                    npc = "Lilian Voss" },
                { id = 51599, name = "Death Trap",                        npc = "Lilian Voss" },
                { id = 51601, name = "The Bridgeport Ride",               npc = "Lilian Voss" },
            },
        },

        -- CHAPTER 8: Drustvar — The Marshal's Grave
        {
            chapter = "The Marshal's Grave",
            summary = "The graveyards of Drustvar hold fallen Kul Tiran war heroes — soldiers too valuable to leave buried. Nathanos leads the expedition to unearth Marshal M. Valentine, while Lilian questions what separates the Horde's methods from the horrors she once suffered at the hands of the Scarlet Crusade.",
            recap = "Nathanos led an expedition to dig up a fallen Kul Tiran war hero for resurrection. As you searched the graveyards of Drustvar, Lilian grew quiet. Unearthing the dead, raising them against their will — it was exactly what had been done to her. She carried out her orders, but the questions in her eyes said everything her lips would not.",
            quests = {
                { id = 51784, name = "A Stroll Through a Cemetery",           npc = "Nathanos Blightcaller" },
                { id = 53065, name = "Operation: Grave Digger",               npc = "Nathanos Blightcaller", optional = true },
                { id = 51785, name = "Examining the Epitaphs",                npc = "Nathanos Blightcaller" },
                { id = 51786, name = "State of Unrest",                       npc = "Nathanos Blightcaller" },
                { id = 51787, name = "Our Lot in Life",                       npc = "Lilian Voss" },
                { id = 51788, name = "The Crypt Keeper",                      npc = "Nathanos Blightcaller" },
                { id = 51789, name = "What Remains of Marshal M. Valentine",  npc = "Nathanos Blightcaller" },
            },
        },

        -- CHAPTER 9: Stormsong Valley — Death of a Tidesage
        {
            chapter = "Death of a Tidesage",
            summary = "The Horde needs a tidesage's power over the sea. Lilian and Rexxar track one down in Stormsong Valley — Thomas Zelling, a dying man willing to trade his humanity for a few more years with his family. When the ritual is done, Lilian must watch Zelling's wife recoil from the husband she no longer recognizes. The scene is painfully familiar.",
            recap = "Thomas Zelling was a dying tidesage who traded his humanity for undeath, desperate for a few more years with his family. You and Lilian performed the ritual that raised him — and then watched his wife recoil in horror from the husband she no longer recognized. Lilian stood in silence as the scene played out, seeing her own story reflected in Zelling's shattered face. To be Forsaken, she finally understood, was not just a curse of the body.",
            quests = {
                { id = 51797, name = "Tracking Tidesages",               npc = "Nathanos Blightcaller" },
                { id = 53066, name = "Operation: Water Wise",            npc = "Nathanos Blightcaller", optional = true },
                { id = 51798, name = "No Price Too High",                npc = "Rexxar" },
                { id = 51805, name = "They Will Know Fear",              npc = "Lilian Voss" },
                { id = 51818, name = "Commander and Captain",            npc = "Thomas Zelling" },
                { id = 51819, name = "Scattering Our Enemies",           npc = "Rexxar" },
                { id = 51830, name = "Zelling's Potential",              npc = "Thomas Zelling" },
                { id = 51837, name = "Whatever Will Be",                 npc = "Lilian Voss" },
                { id = 52122, name = "To Be Forsaken",                   npc = "Lilian Voss" },
            },
        },

        -- =====================================================================
        -- ACT IV — THE PROUDMOORE AFFAIR (Battle for Azeroth 8.1)
        -- The war delivers a prize: a Proudmoore heir, drowned and waiting.
        -- Sylvanas sees a weapon. Lilian sees a mirror.
        -- =====================================================================

        -- CHAPTER 10: At the Bottom of the Sea
        {
            chapter = "At the Bottom of the Sea",
            note = "Requires: Battle for Azeroth patch 8.1 (Tides of Vengeance). Complete the Horde War Campaign through Stormsong Valley before this chapter becomes available.",
            summary = "The Horde's war at sea claims a significant prize: Derek Proudmoore, son of the Lord Admiral, goes down with his ship in the waters off Kul Tiras. Hobart Grapplehammer equips you with experimental diving gear as Dread-Admiral Tattersail leads the expedition into the deep. What Sylvanas intends to do with the body is not yet spoken aloud — but the silence on the ship ride home says enough.",
            recap = "The war at sea gave the Horde what blades on land could not: Derek Proudmoore, heir to Kul Tiras, dead at the bottom of the ocean. Hobart Grapplehammer put you in a diving suit and you went down. The ocean floor was littered with the wreckage of the battle — dog tags, sunken ships, the bones of sailors on both sides. You found Derek and hauled him up. No one said what Sylvanas would do with him. No one had to.",
            quests = {
                { id = 52764, name = "Journey to the Middle of Nowhere", npc = "Dread-Admiral Tattersail" },
                { id = 53067, name = "Operation: Bottom Feeder",         npc = "Nathanos Blightcaller", optional = true },
                { id = 52765, name = "Deep Dive",                        npc = "Hobart Grapplehammer" },
                { id = 52766, name = "Seafloor Shipwreck",               npc = "Hobart Grapplehammer" },
                { id = 52767, name = "Checking Dog Tags",                npc = "Hobart Grapplehammer" },
                { id = 52768, name = "The Sunken Graveyard",             npc = "Hobart Grapplehammer" },
                { id = 52769, name = "Captain By Captain",               npc = "Hobart Grapplehammer" },
                { id = 52770, name = "Biolumi-Nuisance",                 npc = "Hobart Grapplehammer" },
                { id = 52772, name = "The Undersea Ledge",               npc = "Hobart Grapplehammer" },
                { id = 52773, name = "Water-Breathing Dragon",           npc = "Hobart Grapplehammer" },
                { id = 52774, name = "Grab and Go",                      npc = "Nathanos Blightcaller" },
                { id = 53121, name = "Siege of Boralus",                 npc = "Nathanos Blightcaller", optional = true },
                { id = 52978, name = "With Prince in Tow",               npc = "Dread-Admiral Tattersail" },
            },
        },

        -- CHAPTER 11: The Strike on Boralus
        {
            chapter = "The Strike on Boralus",
            summary = "Derek Proudmoore's body is put to use before Lilian ever gets her orders: the Horde deploys him as bait to draw Kul Tiran warships away from Boralus, then drives a strike force into Stormsong Monastery to seize the Abyssal Scepter. Thomas Zelling — raised against his will just weeks ago — now fights for the Horde from inside the monastery walls. Lilian watches what the war makes of people.",
            recap = "Derek Proudmoore had barely been hauled out of the sea before Sylvanas found a use for him — not as a weapon yet, but as bait. The Kul Tiran fleet chased his ghost while you and Nathanos hit Stormsong Monastery. Thomas Zelling, the tidesage whose raising Lilian had stood witness to, guided you from inside. He was doing what he was told. So was she. The Horde got its scepter. Lilian got her champion tabard. No one asked if any of it was right.",
            quests = {
                { id = 52183, name = "When a Plan Comes Together",       npc = "Nathanos Blightcaller" },
                { id = 53068, name = "Operation: Hook and Line",         npc = "Nathanos Blightcaller", optional = true },
                { id = 52186, name = "The Bulk of the Guard",            npc = "Nathanos Blightcaller" },
                { id = 52187, name = "Old Colleagues",                   npc = "Captain Amalia Stone" },
                { id = 52185, name = "A Well Placed Portal",             npc = "Nathanos Blightcaller" },
                { id = 52184, name = "Relics of Ritual",                 npc = "Thomas Zelling" },
                { id = 52188, name = "Tidesage Teachings",               npc = "Thomas Zelling" },
                { id = 52189, name = "Forfeit Souls",                    npc = "Thomas Zelling" },
                { id = 52190, name = "Gaining the Upper Hand",           npc = "Thomas Zelling" },
                { id = 52990, name = "Return to the Harbor",             npc = "Thomas Zelling" },
                { id = 52191, name = "Life Held Hostage",                npc = "Nathanos Blightcaller" },
                { id = 52192, name = "The Aid of the Tides",             npc = "Nathanos Blightcaller" },
                { id = 52861, name = "Champion: Lilian Voss",            npc = "Lilian Voss", optional = true },
                { id = 53003, name = "A Cycle of Hatred",                npc = "Nathanos Blightcaller" },
            },
        },

        -- CHAPTER 12: Testing Loyalties
        {
            chapter = "Testing Loyalties",
            note = "Requires: Battle for Azeroth patch 8.1.5. Contains a player choice — the canonical lore outcome has you side with Baine.",
            summary = "Baine Bloodhoof has decided Derek Proudmoore cannot be used as a weapon against his own family and asks for your help freeing him. The plan runs through Plunder Harbor under false colors, with Thomas Zelling — the very tidesage Lilian helped raise — guiding the escape from the inside. When Baine and Zelling are punished for their defiance, Lilian says nothing to Sylvanas. She tells Zelling's family he died a hero.",
            recap = "Baine Bloodhoof looked at Derek Proudmoore — raised, hollowed out, aimed at his own kin — and decided he would not be part of it. He asked for your help. Thomas Zelling, the tidesage whose raising Lilian had stood witness to in Stormsong, helped guide Derek out from the inside. They freed him.\n\nSylvanas had Baine arrested and Zelling killed. Lilian said nothing aloud. Later, quietly, she went to Zelling's family and told them he had died a hero. It was not defiance. It was a choice. Small enough that no one noticed. Large enough that she did.",
            quests = {
                { id = 54961, name = "Righting Wrongs",                  npc = "Nathanos Blightcaller" },
                { id = 55124, name = "Righting Wrongs",                  npc = "Baine Bloodhoof" },
                { id = 54958, name = "Ships in the Night",               npc = "Baine Bloodhoof" },
                { id = 54959, name = "Under Lock and Keys",              npc = "Baine Bloodhoof" },
                { id = 54997, name = "Dead in the Water",                npc = "Baine Bloodhoof", optional = true },
                { id = 54960, name = "A Bitter Reunion",                 npc = "Baine Bloodhoof" },
                { id = 54999, name = "Under False Colors",               npc = "Thomas Zelling" },
                { id = 55034, name = "Under False Colors",               npc = "Nathanos Blightcaller", optional = true },
            },
        },

        -- =====================================================================
        -- ACT V — RETURN TO LORDAERON (Shadowlands 9.2.5)
        -- Sylvanas is defeated. The war is over. The Dark Lady is gone.
        -- What remains is the city below the Blight, and the people who
        -- never stopped calling it home.
        -- =====================================================================

        -- CHAPTER 13: Return to Lordaeron
        {
            chapter = "Return to Lordaeron",
            note = "Requires: Shadowlands patch 9.2.5. Available to Horde players after completing the Shadowlands campaign.",
            summary = "With Sylvanas defeated and the war over, Lilian Voss and Calia Menethil lead the Forsaken back to Lordaeron. The city is choked with Blight, the halls of Undercity dark and half-collapsed. Together they fight to reclaim it — cleansing what can be saved, burying what cannot — and at the end, form the Desolate Council: a governing body the Forsaken chose for themselves.",
            recap = "The war ended. Sylvanas was gone. And Lilian Voss led the Forsaken home.\n\nThey came back to ruins — streets flooded with Blight, Undercity dark and broken. Calia Menethil walked beside her, daughter of the last king of Lordaeron, and between the two of them they held the Forsaken together through all of it: the plague work, the dead to bury, the city to reclaim room by room. At the end they formed the Desolate Council — Lilian, Calia, Velonara, Belmont, Faranell — not a Dark Lady, not a warchief. A council. Their own.\n\nLilian Voss, who had spent her whole life as something to be used and discarded, had become the person her people followed home.",
            quests = {
                { id = 65656, name = "Call to Lordaeron",                npc = "Calia Menethil" },
                { id = 65657, name = "Assemble the Forsaken",            npc = "Calia Menethil" },
                { id = 65658, name = "This Land is Ours",                npc = "Calia Menethil" },
                { id = 65659, name = "The Blight Congress",              npc = "Calia Menethil" },
                { id = 65660, name = "Walk of Faith",                    npc = "Calia Menethil" },
                { id = 65661, name = "Consulting Our Allies",            npc = "Calia Menethil" },
                { id = 65662, name = "House of Plagues",                 npc = "Master Apothecary Faranell" },
                { id = 65663, name = "Feed the Eater",                   npc = "Master Apothecary Faranell" },
                { id = 65664, name = "Essence of Plague",                npc = "Master Apothecary Faranell" },
                { id = 65665, name = "Embodiment",                       npc = "Master Apothecary Faranell" },
                { id = 65666, name = "Return to Brill",                  npc = "Master Apothecary Faranell" },
                { id = 65667, name = "The Remedy of Lordaeron",          npc = "Calia Menethil" },
                { id = 65668, name = "The Desolate Council",             npc = "Lilian Voss" },
                { id = 66090, name = "Path of the Dark Rangers",         npc = "Dark Ranger Velonara" },
                { id = 65788, name = "A Walk with Ghosts",               npc = "Lilian Voss" },
            },
        },
    },
}
