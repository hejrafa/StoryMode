local addonName, SM = ...

-- =============================================================================
-- Sylvanas Windrunner: The Banshee Queen
-- A saga spanning Wrath of the Lich King through Dragonflight.
-- From the ice halls of Icecrown to the judgment courts of Oribos —
-- the full story of a queen who broke the world, and why.
-- =============================================================================

SM.SylvanasData = {
    -- Questline metadata
    title = "The Banshee Queen",
    description = "Sylvanas Windrunner was a Ranger-General, then a corpse, then something the Horde was never fully prepared for. Follow her story from the frozen passages of Icecrown through the wars she started — and the reckoning that followed.",
    zone = "Icecrown / Silverpine / Orgrimmar / Oribos",
    expansion = "Wrath of the Lich King — Dragonflight",
    achievements = {
        -- The Frozen Halls — dungeon completions
        4516,   -- The Forge of Souls (Normal)
        4519,   -- Heroic: The Forge of Souls
        4517,   -- The Pit of Saron (Normal)
        4520,   -- Heroic: The Pit of Saron
        4518,   -- The Halls of Reflection (Normal)
        4521,   -- Heroic: The Halls of Reflection
        -- The Frozen Halls — bonus achievements
        4522,   -- Soul Power (Bronjahm: keep 4+ soul fragments alive)
        4523,   -- Three Faced (Devourer of Souls: no Phantom Blast lands)
        4524,   -- Doesn't Go to Eleven (Garfrost: under 11 stacks of Permafrost)
        4525,   -- Don't Look Up (Pit of Saron hallway: avoid all icicles)
        4526,   -- We're Not Retreating; We're Advancing in a Different Direction. (HoR: escape in under 6 min)
        -- Icecrown Citadel
        4608,   -- Fall of the Lich King (defeat the Lich King)
        4583,   -- Bane of the Fallen King (defeat the Lich King on Heroic 25)
        -- Battle for Azeroth — war campaign arc
        12509,  -- Ready for War (complete the BfA 8.0 war campaign)
        13466,  -- Tides of Vengeance (complete the 8.1 war campaign, includes Fate of Saurfang)
        13924,  -- The Fourth War (complete the full BfA war story through the Mak'gora)
        -- Shadowlands — Zereth Mortis / Judgment
        15259,  -- Secrets of the First Ones (Zereth Mortis campaign; Judgment is the final chapter)
    },
    faction = "Horde",
    color = { 0.20, 0.40, 0.70 },  -- Forsaken void-blue
    icon = 341221,
    portraitDisplayID = 28213,  -- Lady Sylvanas Windrunner

    -- Start location: Dark Ranger Vorel in Dalaran (Northrend)
    startQuest = { id = 24506, name = "Inside the Frozen Citadel", npc = "Dark Ranger Vorel", location = "Dalaran" },
    startMapID = 125,   -- Northrend Dalaran
    startX = 0.4400,
    startY = 0.4800,

    -- Key NPC locations for waypoint guidance (mapID, x, y)
    npcLocations = {
        -- Northrend Dalaran (Frozen Halls entry)
        ["Dark Ranger Vorel"]        = { mapID = 125,  x = 0.4400, y = 0.4800 },  -- (verify)
        -- Icecrown / Forge of Souls entrance (Frozen Halls)
        ["Lady Sylvanas Windrunner"] = { mapID = 118,  x = 0.5700, y = 0.7200 },  -- (verify)
        -- Silverpine Forest (Forsaken High Command)
        ["Grand Executor Mortuus"]   = { mapID = 18,   x = 0.4200, y = 0.7300 },  -- (verify)
        ["Deathstalker Belmont"]     = { mapID = 18,   x = 0.4200, y = 0.7300 },  -- (verify)
        ["High Executor Darthalia"]  = { mapID = 18,   x = 0.4300, y = 0.7100 },  -- (verify — Sepulcher)
        -- Durotar (Broken Shore entry)
        ["Captain Russo"]            = { mapID = 1,    x = 0.5560, y = 0.1100 },  -- Horde dock (verify)
        -- Orgrimmar
        ["High Overlord Saurfang"]   = { mapID = 85,   x = 0.5180, y = 0.3680 },
        -- Zuldazar (Fate of Saurfang)
        ["Dark Ranger Alina"]        = { mapID = 862,  x = 0.5000, y = 0.6500 },
        ["Nathanos Blightcaller"]    = { mapID = 862,  x = 0.5840, y = 0.6260 },
        -- Zuldazar / Orgrimmar (Stay of Execution)
        ["Lor'themar Theron"]        = { mapID = 862,  x = 0.5000, y = 0.6500 },
        -- Orgrimmar (War Campaign Finale)
        ["Lilian Voss"]              = { mapID = 85,   x = 0.5050, y = 0.5700 },  -- (verify)
        ["Valeera Sanguinar"]        = { mapID = 85,   x = 0.5050, y = 0.5700 },
        -- Ruins of Lordaeron (Dragonflight phased — The Long Hunt epilogue)
        ["Dori'thur"]                = { mapID = 2070, x = 0.6400, y = 0.6800 },
        -- Oribos (Judgment)
        ["Bolvar Fordragon"]         = { mapID = 1670, x = 0.5000, y = 0.5000 },
        ["Uther the Lightbringer"]   = { mapID = 1670, x = 0.5100, y = 0.4900 },
        ["Tyrande Whisperwind"]      = { mapID = 1670, x = 0.5050, y = 0.5100 },
        ["Pelagos"]                  = { mapID = 1670, x = 0.5000, y = 0.5200 },
    },

    -- NPC creature display IDs for chapter portraits
    -- Verify unknowns: /run print(UnitCreatureDisplayID("target"))
    npcDisplayIDs = {
        ["Lady Sylvanas Windrunner"] = 28213,
        ["Dark Ranger Vorel"]        = 30686,
        ["Grand Executor Mortuus"]   = 33999,
        ["Deathstalker Belmont"]     = 31001,
        ["High Executor Darthalia"]  = 31002,
        ["Captain Russo"]            = 35000,
        ["Holgar Stormaxe"]         = 4515,
        ["High Overlord Saurfang"]   = 14732,
        ["Dark Ranger Alina"]        = 32644,
        ["Nathanos Blightcaller"]    = 86219,
        ["Lilian Voss"]              = 85799,
        ["Valeera Sanguinar"]        = 36940,
        ["Bolvar Fordragon"]         = 95194,
        ["Uther the Lightbringer"]   = 87100,
        ["Tyrande Whisperwind"]      = 20748,
        ["Pelagos"]                  = 90000,
        ["Dori'thur"]                = 38801,
    },
    chapterDisplayIDs = {
        ["The Frozen Halls"]              = 30686,  -- Dark Ranger Vorel
        ["Icecrown's End"]               = 0,  -- Falls through to chapterIcons
        ["The War for Silverpine"]        = 33999,  -- Grand Executor Mortuus
        ["Cities in Dust"]               = 33999,  -- Grand Executor Mortuus
        ["The Broken Shore"]             = 4515,  -- Holgar Stormaxe
        ["The War of Thorns"]            = 28213,  -- Sylvanas
        ["The Battle for Lordaeron"]     = 14732,  -- High Overlord Saurfang
        ["The Fate of Saurfang"]         = 32644,  -- Dark Ranger Alina
        ["Stay of Execution"]            = 17122,  -- Lor'themar Theron
        ["Breaking the Cycle"]           = 28213,  -- Sylvanas Windrunner
        ["What Comes After"]             = 85799,  -- Lilian Voss
        ["A Chilling Summons"]           = 95194,  -- Bolvar Fordragon
        ["Judgment"]                     = 95194,  -- Bolvar Fordragon
        ["The Long Hunt"]                = 38801,  -- Dori'thur
    },
    chapterIcons = {
        ["The Frozen Halls"]              = 0,
        ["Icecrown's End"]               = 341221,
        ["The War for Silverpine"]        = 0,
        ["Cities in Dust"]               = 0,
        ["The Broken Shore"]             = 0,
        ["The War of Thorns"]            = 0,
        ["The Battle for Lordaeron"]     = 0,
        ["The Fate of Saurfang"]         = 0,
        ["Stay of Execution"]            = 0,
        ["Breaking the Cycle"]           = 0,
        ["What Comes After"]             = 0,
        ["A Chilling Summons"]           = 0,
        ["Judgment"]                     = 0,
        ["The Long Hunt"]                = 0,
    },

    -- =========================================================================
    -- ACT I — THE FROZEN HALLS (Wrath of the Lich King)
    -- Sylvanas enters Icecrown. She learns what waits for Arthas — and herself.
    -- =========================================================================
    chapters = {

        -- CHAPTER 1: The dungeon chain
        {
            chapter = "The Frozen Halls",
            note = "Talk to Dark Ranger Vorel in Wrath Dalaran. Use Chromie to set your timeline if needed. Runs through Forge of Souls, Pit of Saron, and Halls of Reflection.",
            summary = "Sylvanas has found a crack in Icecrown's defenses. She leads a covert strike through three dungeons — the Forge of Souls, the Pit of Saron, and the Halls of Reflection — to reach something she has been waiting years to confront.",
            recap = "Sylvanas found a crack in Icecrown's defenses and sent you in alongside her. The Forge of Souls. The Pit of Saron. And finally the Halls of Reflection, where she came face to face with the memory of the man who murdered her and enslaved her people. She asked Uther the Lightbringer what would become of Arthas when he died. He told her the only way to truly end the Lich King was at the Frozen Throne where he was made. Then he warned her, in the same breath, that her own fate in death would not be kind. She said nothing. She called for the gunship and got everyone out.",
            quests = {
                { id = 24506, name = "Inside the Frozen Citadel", npc = "Dark Ranger Vorel" },
                { id = 24511, name = "Echoes of Tortured Souls",  npc = "Lady Sylvanas Windrunner" },
                { id = 24682, name = "The Pit of Saron",          npc = "Lady Sylvanas Windrunner" },
                { id = 24498, name = "The Path to the Citadel",   npc = "Lady Sylvanas Windrunner" },
                { id = 24710, name = "Deliverance from the Pit",  npc = "Lady Sylvanas Windrunner" },
                { id = 24713, name = "Frostmourne",               npc = "Lady Sylvanas Windrunner" },
            },
        },

        -- CHAPTER 2: The fall of Arthas — and what Sylvanas saw in death
        {
            chapter = "Icecrown's End",
            achievementID = 4608,  -- "Fall of the Lich King"
            note = "Defeat the Lich King in Icecrown Citadel. Fully soloable. The Sylvanas moment plays in the aftermath.",
            summary = "The Lich King's reign ends at the Frozen Throne. For Sylvanas, the aftermath is more personal than anyone outside Icecrown will ever know.",
            recap = "Arthas died at the Frozen Throne. The moment he fell, the power of the Lich King's realm rippled outward — and Sylvanas, like every Forsaken sustained by that dark energy, briefly stopped. She died on her feet, alone at the pinnacle of Icecrown. A Val'kyr named Annhylde gave her life to pull her back. Sylvanas opened her eyes to wind and ice and herself, inexplicably, still breathing. She looked out at nothing for a long time. Then she went back to work. She never explained what she had seen. But the Val'kyr — the ones who would spend their own lives to keep her alive — suddenly became very important to her. Now she knew why.",
            quests = {},
        },

        -- =========================================================================
        -- ACT II — THE FORSAKEN MARCH (Cataclysm)
        -- She builds a nation with the dead. Garrosh doesn't approve.
        -- =========================================================================

        -- CHAPTER 3: The march into Silverpine and the Garrosh confrontation
        {
            chapter = "The War for Silverpine",
            note = "Begin at Forsaken High Command in Silverpine Forest.",
            summary = "The Forsaken are marching on Silverpine Forest. Warchief Garrosh Hellscream has heard what Sylvanas is doing to grow their numbers — and he is not pleased.",
            recap = "The Forsaken High Command was busy when Garrosh Hellscream showed up with a grievance. He'd heard what Sylvanas was doing — using the Val'kyr to raise human dead as new Forsaken, growing her forces beyond what the Horde had sanctioned. He told her to stop. She asked him, face to face, what the difference was between her and the Lich King. He didn't have a good answer. The campaign continued.",
            quests = {
                { id = 26965, name = "The Warchief Cometh",         npc = "Grand Executor Mortuus" },
                { id = 26989, name = "The Gilneas Liberation Front", npc = "Grand Executor Mortuus" },
                { id = 26992, name = "Agony Abounds",               npc = "Grand Executor Mortuus" },
                { id = 26995, name = "Guts and Gore",               npc = "Grand Executor Mortuus" },
                { id = 26998, name = "Iterating Upon Success",      npc = "Grand Executor Mortuus" },
                { id = 27045, name = "Waiting to Exsanguinate",     npc = "Grand Executor Mortuus" },
                { id = 27056, name = "Belmont's Report",            npc = "Deathstalker Belmont" },
                { id = 27065, name = "The Warchief's Fleet",        npc = "Grand Executor Mortuus" },
                { id = 27096, name = "Orcs are in Order",           npc = "Grand Executor Mortuus" },
                { id = 27097, name = "Rise, Forsaken",              npc = "Lady Sylvanas Windrunner" },
                { id = 27099, name = "No Escape",                   npc = "Lady Sylvanas Windrunner" },
                { id = 27098, name = "Lordaeron",                   npc = "Lady Sylvanas Windrunner" },
                { id = 27180, name = "Honor the Dead",              npc = "Lady Sylvanas Windrunner" },
            },
        },

        -- CHAPTER 4: Gilneas, Godfrey, and the final ultimatum
        {
            chapter = "Cities in Dust",
            note = "Continues from The War for Silverpine. For \"What Tomorrow Brings\", use a flying mount to reach the telescope if it's blocked on foot.",
            summary = "The campaign pushes into the ruins of Gilneas. A traitor needs to be dealt with, and the Gilneas Liberation Front is running out of room to maneuver.",
            recap = "You fought through the Ruins of Gilneas — sabotage, ambushes, a cat-and-mouse hunt through a shattered city — and cornered Godfrey, the man who had betrayed everyone at least once. Sylvanas raised him without ceremony. Then the final push: Lorna Crowley was captured and brought before her. Sylvanas offered terms. The Gilneas Liberation Front could keep fighting and watch everything turn to dust, or stand aside. It was not a bluff. Cities in Dust is one of the best Sylvanas scenes in the game — cold, precise, and entirely in character.",
            quests = {
                { id = 27364, name = "On Whose Orders?",               npc = "Grand Executor Mortuus" },
                { id = 27401, name = "What Tomorrow Brings",           npc = "Grand Executor Mortuus" },
                { id = 27405, name = "Fall Back!",                     npc = "Grand Executor Mortuus" },
                { id = 27438, name = "The Great Escape",               npc = "Grand Executor Mortuus" },
                { id = 27472, name = "Rise, Godfrey",                  npc = "Lady Sylvanas Windrunner" },
                { id = 27474, name = "Breaking the Barrier",           npc = "Lady Sylvanas Windrunner" },
                { id = 27580, name = "Sowing Discord",                 npc = "Grand Executor Mortuus" },
                { id = 27594, name = "On Her Majesty's Secret Service", npc = "Grand Executor Mortuus" },
                { id = 27601, name = "Cities in Dust",                 npc = "Lady Sylvanas Windrunner" },
                { id = 27746, name = "Empire of Dirt",                 npc = "High Executor Darthalia" },
            },
        },

        -- =========================================================================
        -- ACT III — THE CROWN (Legion)
        -- Vol'jin dies. Sylvanas becomes Warchief. Neither of them expected it.
        -- =========================================================================

        -- CHAPTER 5: The Broken Shore
        {
            chapter = "The Broken Shore",
            note = "Begin with Captain Russo in Durotar. If the quest isn't available, use Chromie in Orgrimmar to set your timeline to Legion.",
            summary = "The Legion has landed on the Broken Shore. The Horde answers the call — but this battle will cost far more than anyone expected.",
            recap = "The Broken Shore was a rout. The Horde threw everything at the Legion's landing force and bled for it. Vol'jin took a wound that no healer could close. By the time the retreat was called, he was dying. He summoned Sylvanas, told her the loa had whispered her name, and asked her to lead. She stood there for a moment — the Dark Lady of the Forsaken, who had never wanted anything to do with the Horde's politics — and said yes. She walked out of that room as Warchief. Nobody, including her, fully understood what that meant yet.",
            quests = {
                { id = 43926, name = "The Legion Returns",          npc = "Holgar Stormaxe" },
                { id = 40518, name = "The Battle for Broken Shore", npc = "Captain Russo" },
                { id = 40522, name = "Fate of the Horde",           npc = "Eitrigg" },
                { id = 40760, name = "Emissary",                    npc = "Allari the Souleater", optional = true },
                { id = 40607, name = "Demons Among Us",             npc = "Allari the Souleater", optional = true },
                { id = 40605, name = "Keep Your Friends Close",     npc = "Elthyn Da'rai",        optional = true },
            },
        },

        -- =========================================================================
        -- ACT IV — THE WARCHIEF'S WAR (Battle for Azeroth)
        -- A Warchief who burns everything — including the Horde itself.
        -- =========================================================================

        -- CHAPTER 6: The burning of Teldrassil
        {
            chapter = "The War of Thorns",
            loreOnly = true,
            note = "Find Zidormi near the Darkshore/Felwood border — she takes you back to the War of Thorns. Mark as viewed when done.",
            summary = "The Warchief sets her sights on Darkshore. What unfolds there will make the Fourth War impossible to contain.",
            recap = "The Horde marched into Ashenvale with speed and purpose. You pushed through Night Elf defenses, secured the roads, and drove toward the coast beneath Teldrassil. The Night Elves fought well but the Horde had the numbers and Sylvanas had a plan. The World Tree loomed at the end of it — massive, ancient, and full of civilians who had not escaped in time. Sylvanas stood at its base with the battle won and the tree in reach. A Night Elf prisoner asked what the people inside had done to deserve this. Sylvanas spoke about hope being the enemy. Then she gave the order. Teldrassil burned. The smoke was visible from Stormwind. Whatever Sylvanas had been building toward, this was no longer a war anyone could call limited.",
            quests = {},
        },

        -- CHAPTER 7: The fall of Undercity
        {
            chapter = "The Battle for Lordaeron",
            achievementID = 12584,
            replayable = true,
            note = "Replay via Archivist Sylvia in Orgrimmar. Use Mark as Played if completion isn't detected.",
            summary = "The Alliance has come for Lordaeron. Sylvanas holds the walls of the Forsaken capital as Jaina and Anduin lead the siege.",
            recap = "Jaina and Anduin brought the Alliance's hammer down on Lordaeron. The Horde fought from the walls, but the siege was overwhelming. When the gates could no longer hold, Sylvanas triggered the plague systems beneath the city — releasing the Blight on her own capital rather than let the Alliance take it. Soldiers on both sides choked and died. The Undercity was lost. Sylvanas rode for the Dark Portal as the Alliance horns echoed behind her. The Forsaken had no home left. Again.",
            quests = {
                { id = 53372, name = "Battle for Azeroth: Hour of Reckoning", npc = "High Overlord Saurfang" },
                { id = 51796, name = "The Battle for Lordaeron",              npc = "High Overlord Saurfang" },
            },
        },

        -- CHAPTER 8: The hunt for the High Overlord
        {
            chapter = "The Fate of Saurfang",
            note = "Talk to Dark Ranger Alina in Zuldazar to begin.",
            summary = "Saurfang is gone. Nathanos Blightcaller has been dispatched to find him — and bring him back before he becomes a problem.",
            recap = "After the fall of Lordaeron, Saurfang had surrendered to the Alliance rather than flee with Sylvanas. Now Nathanos was dispatched to retrieve him — or ensure he stayed quiet. You tracked the old orc through layers of Alliance intelligence, pieced together where he was held, and extracted him. Saurfang walked out of Stormwind on his own two feet, not as anyone's prisoner. He thanked Nathanos without warmth. Whatever he was planning, it wasn't a return to Sylvanas's service.",
            quests = {
                { id = 54097, name = "The Dark Lady Calls",      npc = "Dark Ranger Alina" },
                { id = 54099, name = "The High Overlord",        npc = "Nathanos Blightcaller" },
                { id = 54100, name = "A Way Out",                npc = "Nathanos Blightcaller" },
                { id = 54102, name = "Eastern Escape",           npc = "Nathanos Blightcaller" },
                { id = 54103, name = "Corner Crossing",          npc = "Nathanos Blightcaller" },
                { id = 54104, name = "Signs of Saurfang",        npc = "Nathanos Blightcaller" },
                { id = 54105, name = "Ever Eastward",            npc = "Nathanos Blightcaller" },
                { id = 54106, name = "Tracking Tipoff",          npc = "Nathanos Blightcaller" },
                { id = 54107, name = "Grim Tidings",             npc = "Nathanos Blightcaller" },
                { id = 54108, name = "A Warrior's Death",        npc = "Nathanos Blightcaller" },
                { id = 54109, name = "Queen's Favor",            npc = "Nathanos Blightcaller" },
                { id = 50769, name = "The Stormwind Extraction", npc = "Nathanos Blightcaller" },
            },
        },

        -- CHAPTER 8.5: The rescue of Baine Bloodhoof
        {
            chapter = "Stay of Execution",
            note = "Travel to Nazjatar and speak with Lor'themar Theron to begin.",
            summary = "Baine Bloodhoof is to be executed. Lor'themar has gathered allies to defy the Warchief and save the Tauren chieftain.",
            recap = "When Spiritwalker Ussoh's vision revealed Baine's imminent execution, Lor'themar gathered a small band of rebels — Thrall, Saurfang, and others. You infiltrated Orgrimmar's depths, fought through Sylvanas's forces, and rescued Baine from his cell. Jaina Proudmoore, of all people, helped you escape. The Horde was fracturing, and this was just the beginning.",
            quests = {
                { id = 55778, name = "Visions of Danger",    npc = "Lor'themar Theron" },
                { id = 55780, name = "Old Allies",           npc = "Lor'themar Theron", showIf = 55780 },
                { id = 55781, name = "Old Allies",           npc = "Lor'themar Theron", showIf = 55781 },
                { id = 55779, name = "Stay of Execution",    npc = "Lor'themar Theron", showIf = 55780 },
                { id = 55782, name = "Stay of Execution",    npc = "Thrall",             showIf = 55781 },
            },
        },

        -- CHAPTER 9: The Horde fractures
        {
            chapter = "Breaking the Cycle",
            summary = "The Horde has split in two. Saurfang rallies those who oppose Sylvanas, while loyalists prepare to crush the rebellion.",
            recap = "After Baine's rescue, the Horde fractured completely. Some followed Saurfang to Razor Hill, others remained loyal to Sylvanas in Orgrimmar. The stage was set for the final confrontation — not between Alliance and Horde, but within the Horde itself.",
            quests = {
                -- Sylvanas loyalist path (chose 55780)
                { id = 56495, name = "They Move Against Us",     npc = "Sylvanas Windrunner", showIf = 55780 },
                { id = 56833, name = "Leaders of the Horde",  npc = "Sylvanas Windrunner", showIf = 55780 },
                { id = 57130, name = "Traitors In Our Midst", npc = "Nathanos Blightcaller", showIf = 55780 },
                { id = 57148, name = "Siegebreakers",      npc = "Nathanos Blightcaller", showIf = 55780 },
                { id = 57149, name = "Propaganda Takedown", npc = "Nathanos Blightcaller", showIf = 55780 },
                { id = 57150, name = "Militia",          npc = "Nathanos Blightcaller", showIf = 55780 },
                { id = 57151, name = "A Line in the Sand", npc = "Nathanos Blightcaller", showIf = 55780 },
                { id = 57152, name = "Most Loyal",        npc = "Nathanos Blightcaller", showIf = 55780 },
                -- Saurfang rebel path (chose 55781)
                { id = 56496, name = "The Eve of Battle", npc = "High Overlord Saurfang", showIf = 55781 },
                { id = 57088, name = "This Ain't Mine",  npc = "High Overlord Saurfang", showIf = 55781 },
                { id = 57090, name = "Saving the Siege", npc = "High Overlord Saurfang", showIf = 55781 },
                { id = 57091, name = "Already Among Us",  npc = "High Overlord Saurfang", showIf = 55781 },
                { id = 57092, name = "Strategic Deployment", npc = "High Overlord Saurfang", showIf = 55781 },
                { id = 57093, name = "Before the Gates of Orgrimmar", npc = "High Overlord Saurfang", showIf = 55781 },
                { id = 57094, name = "The Price of Victory", npc = "High Overlord Saurfang", showIf = 55781 },
                { id = 57095, name = "Old Soldier",     npc = "High Overlord Saurfang", showIf = 55781 },
            },
        },

        -- CHAPTER 10: What Comes After
        {
            chapter = "What Comes After",
            note = "If \"A Gathering of Champions\" isn't available, finish the war campaign through \"The Hidden Need\" first.",
            summary = "Sylvanas is gone. What remains of the Horde gathers to decide what it becomes without her.",
            recap = "Saurfang's last act before the gate was a summons sent to every Horde leader still standing. By the time the crowd outside Orgrimmar thinned and the silence settled in, they were already gathering: Baine, Lor'themar, Ji Firepaw, and Lilian Voss, who now spoke for a Forsaken people their former Warchief had used as weapons and discarded. In the middle of it, Lilian stepped away from the main hall to broker a quieter conversation — one that had to happen before anything else could move: Forsaken leadership, face to face with Calia Menethil and Derek Proudmoore. Hidden, necessary, and hers to arrange. Then the full council assembled. The Warchief's throne was empty. Lilian made the case for leaving it that way. No single voice, no single will — a council, the way the Horde had always needed to work but never quite managed. The others listened. Then they agreed.",
            quests = {
                { id = 57198, name = "Sense of Obligation",      npc = "High Overlord Saurfang" },
                { id = 57376, name = "The Hidden Need",          npc = "Lilian Voss" },
                { id = 58672, name = "A Gathering of Champions", npc = "Valeera Sanguinar" },
                { id = 58673, name = "Warchief of the Horde",    npc = "Lilian Voss" },
            },
        },

        -- =========================================================================
        -- ACT V — THE VEIL TEARS OPEN (Shadowlands 9.0 intro)
        -- Sylvanas shatters the Helm of Domination. The door opens.
        -- =========================================================================

        -- CHAPTER 11: The veil tears open / descent into the Maw
        {
            chapter = "A Chilling Summons",
            note = "Talk to Highlord Darion Mograine at your capital to begin. Runs through a scenario inside the Maw.",
            summary = "Sylvanas shatters the Helm of Domination and tears open the sky above Icecrown. The leaders of Azeroth follow her into death itself — and find that she left someone behind.",
            recap = "Sylvanas went to Icecrown and took the Helm of Domination from Bolvar Fordragon's head. Then she broke it. The veil between the living world and the realm of death split apart where she stood, and she stepped through and left. Bolvar used the shards to open a second rift — he and Jaina, Thrall, Baine, and Anduin went in after her. They landed in the Maw, the prison at the bottom of the Shadowlands, a place no soul had ever escaped from. Sylvanas was already gone deeper in. She had left Anduin behind, locked in a cage in the Tremaculum, to be broken slowly by the Jailer's forces — a message, maybe, or an experiment. Jaina found him. The Jailer's magic had already started working on Baine, poisoning his spirit through a cursed dagger. There was no clean escape: the river of souls, Gorgoa, cut across the only path out, and the Jailer's armies were moving to seal it. The group fought their way through, kept each other standing, and crossed. They came out the other side with Anduin freed and the full shape of the threat finally visible. Sylvanas had not just started a war. She had chosen a side in one that had been running since before Azeroth existed.",
            quests = {
                { id = 62504, name = "Shadowlands: A Chilling Summons", npc = "Highlord Darion Mograine", faction = "Alliance" },
                { id = 61874, name = "Shadowlands: A Chilling Summons", npc = "Highlord Darion Mograine", faction = "Horde" },
                { id = 59751, name = "Through the Shattered Sky",       npc = "Highlord Bolvar Fordragon" },
                { id = 59759, name = "The Lion's Cage",                  npc = "Lady Jaina Proudmoore" },
                { id = 59760, name = "The Afflictor's Key",              npc = "Lady Jaina Proudmoore" },
                { id = 59765, name = "Wounds Beyond Flesh",              npc = "Lady Jaina Proudmoore" },
                { id = 59767, name = "The Path to Salvation",            npc = "Lady Jaina Proudmoore" },
                { id = 59770, name = "Stand as One",                     npc = "Lady Jaina Proudmoore" },
            },
        },

        -- =========================================================================
        -- ACT VI — JUDGMENT (Shadowlands 9.2, Zereth Mortis)
        -- After the Jailer's fall, Sylvanas regains her soul — and faces
        -- the reckoning she has earned.
        -- =========================================================================

        -- CHAPTER 12: The long walk
        {
            chapter = "Judgment",
            note = "Complete the Zereth Mortis campaign and defeat the Jailer in the Sepulcher of the First Ones raid.",
            summary = "The war in the Shadowlands is over. Sylvanas stands before those she has wronged — and must face what comes next.",
            recap = "The Jailer was dead. Sylvanas was whole again — every fragment of her soul restored from where she had given it away. She stood in silence with the full weight of what she had done pressing down on her at last. Then she walked. Down the long road through Oribos, past the faces of the people she had condemned, she came before Tyrande Whisperwind — who had more right to judge her than anyone alive or dead. Tyrande spoke her sentence. Sylvanas accepted it without a word of protest. She would spend eternity freeing the souls she had imprisoned in the Maw, sending them through the veil one by one. Not as punishment. As penance, freely chosen.",
            quests = {
                { id = 65249, name = "The Jailer's Defeat",  npc = "Bolvar Fordragon" },
                { id = 65250, name = "Prisoner of Interest", npc = "Uther the Lightbringer" },
                { id = 65260, name = "A Long Walk",          npc = "Uther the Lightbringer" },
                { id = 65263, name = "The Fate of Sylvanas", npc = "Pelagos" },
                { id = 65297, name = "Penance and Renewal",  npc = "Tyrande Whisperwind" },
            },
        },

        -- =========================================================================
        -- ACT VII — THE LONG HUNT (Dragonflight 10.1.7)
        -- The penance continues. The hunt has no end.
        -- =========================================================================

        -- CHAPTER 13: The Long Hunt
        {
            chapter = "The Long Hunt",
            note = "Complete the Forsaken Heritage questline as an Undead character. Requires having sided with Sylvanas during the war campaign.",
            summary = "Lordaeron has been reclaimed, the penance accepted. But for those who once swore loyalty to the Banshee Queen, a message finds its way back through the dark — one last task, carried by a familiar messenger.",
            recap = "The Forsaken moved on. Lordaeron was theirs again, and the long war had its accounting. But some loyalties don't dissolve with a verdict. Dori'thur arrived in the ruins of Lordaeron bearing a message — not from a queen, not a command, just acknowledgment. The hunt Sylvanas began in death has no end date. The souls in the Maw number in the countless. She is still there, freeing them one by one. The message asked nothing. It only said: she remembers who stood with her.",
            quests = {
                { id = 75519, name = "The Long Hunt", npc = "Dori'thur" },
            },
        },

    },
}
