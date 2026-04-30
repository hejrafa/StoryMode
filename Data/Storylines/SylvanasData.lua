local addonName, SM = ...

-- =============================================================================
-- Sylvanas Windrunner: The Banshee Queen
-- A saga spanning Wrath of the Lich King through The War Within.
-- From the ice halls of Icecrown to the judgment courts of Oribos —
-- the full story of a queen who broke the world, and what remains.
-- =============================================================================

SM.SylvanasData = {
    -- Questline metadata
    title = "The Banshee Queen",
    description = "Sylvanas Windrunner was a Ranger-General, then a corpse, then a queen the Horde was never fully prepared for. Slain by Arthas at the gates of Silvermoon and raised as the first of his banshees, she clawed her way back to herself and built an undead kingdom from the ruins of Lordaeron.\n\nFollow her from Icecrown and Silverpine into wars that test what leadership, vengeance, survival, and freedom mean to someone who has already lost almost everything.",
    zone = "Icecrown / Silverpine / Orgrimmar / Oribos / The Maw",
    expansion = "Wrath of the Lich King — The War Within",
    achievements = {
        -- The Frozen Halls — dungeon completions
        4516,   -- The Forge of Souls (Normal)
        4517,   -- The Pit of Saron (Normal)
        4518,   -- The Halls of Reflection (Normal)
        -- Icecrown Citadel
        4532,   -- Fall of the Lich King (10 player)
        4530,   -- The Frozen Throne (10 player)
        -- Battle for Azeroth — war campaign arc
        12509,  -- Ready for War (complete the BfA 8.0 war campaign)
        13466,  -- Tides of Vengeance (complete the 8.1 war campaign, includes Fate of Saurfang)
        13924,  -- The Fourth War (complete the full BfA war story through the Mak'gora)
        -- Shadowlands — Zereth Mortis / Judgment
        14961,  -- Chains of Domination
        15416,  -- Domination's Grasp
        15417,  -- Sepulcher of the First Ones
        15259,  -- Secrets of the First Ones (Zereth Mortis campaign; Judgment is the final chapter)
        -- The War Within — The Warning / Midnight prelude
        42299,  -- Visions of a Shadowed Sun
        61498,  -- Ready for Midnight
    },
    faction = "Horde",
    color = { 0.20, 0.40, 0.70 },  -- Forsaken void-blue
    icon = 341221,
    factions = { 68, 1098, 1156, 2157 }, -- Undercity, Knights of the Ebon Blade, The Ashen Verdict, The Honorbound
    portraitDisplayID = 28213,  -- Lady Sylvanas Windrunner
    adventureGuideInstanceName = "Icecrown Citadel",

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
        ["Anduin Wrynn"]             = 105386,
        ["Uther the Lightbringer"]   = 105509,
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
        ["Torghast Visions"]             = 28213,  -- Sylvanas Windrunner
        ["Chains of Domination"]         = 28213,  -- Sylvanas Windrunner
        ["Sanctum of Domination"]        = 28213,  -- Sylvanas Windrunner
        ["Shattered Legacies"]           = 105509, -- Uther the Lightbringer
        ["Domination's Grasp"]           = 105386, -- Anduin Wrynn
        ["Crown of Wills"]               = 95194,  -- Bolvar Fordragon
        ["Sepulcher of the First Ones"]  = 95194,  -- Bolvar Fordragon
        ["Judgment"]                     = 95194,  -- Bolvar Fordragon
        ["The Long Hunt"]                = 38801,  -- Dori'thur
        ["The Warning"]                  = 28213,  -- Sylvanas Windrunner
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
        ["Torghast Visions"]             = 0,
        ["Chains of Domination"]         = 0,
        ["Sanctum of Domination"]        = 0,
        ["Shattered Legacies"]           = 0,
        ["Domination's Grasp"]           = 0,
        ["Crown of Wills"]               = 0,
        ["Sepulcher of the First Ones"]  = 0,
        ["Judgment"]                     = 0,
        ["The Long Hunt"]                = 0,
        ["The Warning"]                  = 0,
    },

    -- =========================================================================
    -- ACT I — THE FROZEN HALLS (Wrath of the Lich King)
    -- Sylvanas enters Icecrown. She learns what waits for Arthas — and herself.
    -- =========================================================================
    chapters = {

        -- CHAPTER 1: The dungeon chain
        {
            chapter = "The Frozen Halls",
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
            summary = "The Legion has landed on the Broken Shore. The Horde answers the call — but this battle will cost far more than anyone expected.",
            recap = "The Broken Shore was a rout. The Horde threw everything at the Legion's landing force and bled for it. Vol'jin took a wound that no healer could close. By the time the retreat was called, he was dying. He summoned Sylvanas, told her the loa had whispered her name, and asked her to lead. She stood there for a moment — the Dark Lady of the Forsaken, who had never wanted anything to do with the Horde's politics — and said yes. She walked out of that room as Warchief. Nobody, including her, fully understood what that meant yet.",
            quests = {
                { id = 43926, name = "Legion: The Legion Returns",  npc = "Holgar Stormaxe" },
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
            summary = "The Warchief sets her sights on Darkshore. What unfolds there will make the Fourth War impossible to contain.",
            recap = "The Horde marched into Ashenvale with speed and purpose. You pushed through Night Elf defenses, secured the roads, and drove toward the coast beneath Teldrassil. The Night Elves fought well but the Horde had the numbers and Sylvanas had a plan. The World Tree loomed at the end of it — massive, ancient, and full of civilians who had not escaped in time. Sylvanas stood at its base with the battle won and the tree in reach. A Night Elf prisoner asked what the people inside had done to deserve this. Sylvanas spoke about hope being the enemy. Then she gave the order. Teldrassil burned. The smoke was visible from Stormwind. Whatever Sylvanas had been building toward, this was no longer a war anyone could call limited.",
            quests = {},
        },

        -- CHAPTER 7: The fall of Undercity
        {
            chapter = "The Battle for Lordaeron",
            replayable = true,
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
            gated = true,
            note = "Unlocks after defeating N'Zoth. Speak with Valeera Sanguinar in Zuldazar to begin.",
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
            summary = "Sylvanas shatters the Helm of Domination and tears open the sky above Icecrown. The leaders of Azeroth follow her into death itself — and find that she left someone behind.",
            recap = "Sylvanas went to Icecrown and took the Helm of Domination from Bolvar Fordragon's head. Then she broke it. The veil between the living world and the realm of death split apart where she stood, and she stepped through and left. Bolvar used the shards to open a second rift — he and Jaina, Thrall, Baine, and Anduin went in after her. They landed in the Maw, the prison at the bottom of the Shadowlands, a place no soul had ever escaped from. Sylvanas was already gone deeper in. She had left Anduin behind, locked in a cage in the Tremaculum, to be broken slowly by the Jailer's forces — a message, maybe, or an experiment. Jaina found him. The Jailer's magic had already started working on Baine, poisoning his spirit through a cursed dagger. There was no clean escape: the river of souls, Gorgoa, cut across the only path out, and the Jailer's armies were moving to seal it. The group fought their way through, kept each other standing, and crossed. They came out the other side with Anduin freed and the full shape of the threat finally visible. Sylvanas had not just started a war. She had chosen a side in one that had been running since before Azeroth existed.",
            quests = {
                { id = 60545, name = "Shadowlands: A Chilling Summons", npc = "Highlord Darion Mograine", faction = "Alliance" },
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
        -- ACT VI — TORGAST VISIONS (Shadowlands 9.0)
        -- Removed/skipped for many later characters, but important context:
        -- Sylvanas hesitates as Anduin is forged into the Jailer's weapon.
        -- =========================================================================

        -- CHAPTER 12: The mourneblade vision
        {
            chapter = "Torghast Visions",
            loreOnly = true,
            summary = "Bolvar's visions reveal the Jailer's next weapon: Anduin, bound to a mourneblade. Sylvanas still tries to call it a choice.",
            recap = "Before the assault on the Sanctum, Bolvar saw fragments of what was happening inside Torghast. The Jailer forged Kingsmourne, a mourneblade shaped around Anduin's own weapon and a soul crystal. Sylvanas brought the blade to Anduin and demanded he join their cause willingly or be made to serve. Anduin saw the wound she was trying to hide: she kept offering him the choice Arthas had stolen from her. Blizzard later removed or auto-completed much of this Torghast questline for catch-up characters, but the vision is the emotional bridge into Chains of Domination.",
            quests = {},
        },

        -- =========================================================================
        -- ACT VII — CHAINS OF DOMINATION (Shadowlands 9.1)
        -- Anduin strikes for the Jailer, Tyrande hunts Sylvanas, and the
        -- covenants open the way to Korthia and the Sanctum.
        -- =========================================================================

        -- CHAPTER 13: The Jailer's first move
        {
            chapter = "Chains of Domination",
            gated = true,
            note = "Begins after your covenant campaign reaches The Search for Baine. Later characters may be offered a skip to Korthia; skipping completes this chapter.",
            summary = "Anduin steals the Archon's sigil, and Sylvanas moves on Ardenweald. Tyrande finally catches her in the Heart of the Forest.",
            recap = "The Jailer's next move began in Bastion. Anduin, dominated through Kingsmourne, struck down the Archon and took her sigil while Sylvanas watched the plan unfold. Bolvar gathered the covenants in Oribos, and the war rushed to Ardenweald before the Winter Queen's sigil could be taken next. There, beneath the Heart of the Forest, Tyrande Whisperwind caught Sylvanas at last. Elune's wrath burned through her, but the Night Warrior's power faded before the killing blow. Sylvanas escaped, and the covenants turned toward Korthia and the Sanctum of Domination.",
            quests = {
                { id = 63576, name = "The First Move",            npc = "Highlord Bolvar Fordragon", location = "Oribos", mapID = 1670, x = 0.3990, y = 0.6860 },
                { id = 63856, name = "A Gathering of Covenants",  npc = "Highlord Bolvar Fordragon" },
                { id = 63857, name = "Voices of the Eternal",     npc = "Highlord Bolvar Fordragon" },
                { id = 63578, name = "The Battle of Ardenweald",  npc = "Highlord Bolvar Fordragon" },
                { id = 63638, name = "Can't Turn Our Backs",      npc = "Lady Moonberry" },
                { id = 63904, name = "The Heart of Ardenweald",   npc = "Lady Moonberry" },
                { id = 63639, name = "Report to Oribos",          npc = "Lady Moonberry" },
            },
        },

        -- =========================================================================
        -- ACT VIII — SANCTUM OF DOMINATION (Shadowlands 9.1)
        -- The pursuit reaches Torghast's summit, where Sylvanas finally turns
        -- on the master she chose to serve.
        -- =========================================================================

        -- CHAPTER 14: The raid finale
        {
            chapter = "Sanctum of Domination",
            gated = true,
            completionAchievementID = 15125, -- The Reckoning: Sylvanas Windrunner wing
            note = "Optional raid story from Chains of Domination. Pick up Storming the Sanctum from Bolvar in Korthia after The Primus Returns, or enter Sanctum of Domination directly.",
            summary = "The covenants assault the Jailer's fortress in Torghast. At the summit waits Sylvanas, and the battle ends with the choice that makes News from Oribos possible.",
            recap = "The assault on the Sanctum of Domination carried the covenants into the Jailer's seat of power. Sylvanas waited at the top of Torghast, fighting across shattered chains and the edge of the Maw while the Jailer dragged Oribos toward his prison. When Zovaal spoke of remaking reality so all would serve, Sylvanas finally heard Arthas in his words. She turned on him. The Jailer answered by returning the soul fragment Frostmourne had torn from her at Silvermoon, then left her unconscious at the mercy of those she had betrayed. She was defeated, but not judged. Not yet.",
            quests = {
                { id = 63903, name = "Storming the Sanctum", npc = "Highlord Bolvar Fordragon", optional = true, location = "Keeper's Respite, Korthia", mapID = 1961, x = 0.6280, y = 0.2500 },
            },
        },

        -- =========================================================================
        -- ACT IX — SHATTERED LEGACIES (Shadowlands 9.2, Zereth Mortis)
        -- Uther brings word from Oribos: Sylvanas has awakened, and her
        -- divided soul may be the key to saving Anduin.
        -- =========================================================================

        -- CHAPTER 15: The restoration of Sylvanas's soul
        {
            chapter = "Shattered Legacies",
            gated = true,
            note = "Complete Zereth Mortis campaign chapter 3, Forming an Understanding. This becomes available from Uther in Haven after The Way Forward.",
            summary = "Uther appears in Haven with news from Oribos. Sylvanas has awakened, but reaching the Sepulcher means earning the Enlightened's help first.",
            recap = "After the first foothold in Zereth Mortis was secured, Uther arrived in Haven with news from Oribos: Sylvanas had awakened. Her soul had been split since Frostmourne killed her, and the restored fragment forced her to face the Banshee Queen's atrocities as her own. In the vision Uther shared, the Ranger-General saw Teldrassil burn, rejected the comfort of pretending those crimes belonged to someone else, and chose to wake. The campaign then turned back to Zereth Mortis. Elder Ara led you through a pilgrimage to repair the ancient translocator to the Sepulcher. At the end, Sylvanas stood with Uther, Jaina, and Bolvar before the raid entrance. She knew Anduin was the key, and Uther convinced Jaina to let Sylvanas help free him.",
            quests = {
                { id = 65335, name = "News from Oribos", npc = "Uther the Lightbringer", location = "Haven, Zereth Mortis", mapID = 1970, x = 0.3496, y = 0.6470 },
                { id = 64830, name = "Enlisting the Enlightened",        npc = "Highlord Bolvar Fordragon" },
                { id = 64833, name = "Forging Unity from Diversity",     npc = "Elder Ara" },
                { id = 64831, name = "Remnants of the First Ones",       npc = "Elder Ara" },
                { id = 64832, name = "Reclaiming Provis Esper",          npc = "Elder Ara" },
                { id = 64837, name = "The Pilgrim's Journey",            npc = "Elder Ara" },
                { id = 64834, name = "Glow and Behold",                  npc = "Elder Ara" },
                { id = 64838, name = "Where There's a Pilgrim, There's a Way", npc = "Elder Ara" },
                { id = 64969, name = "In the Weeds",                     npc = "Elder Ara" },
                { id = 64835, name = "Pluck from the Vines",             npc = "Elder Ara" },
                { id = 64836, name = "Nip It in the Bud",                npc = "Elder Ara" },
                { id = 64839, name = "Root of the Problem",              npc = "Elder Ara" },
                { id = 64840, name = "Unchecked Growth",                 npc = "Elder Ara" },
                { id = 64841, name = "Take Charge",                      npc = "Elder Ara" },
                { id = 65331, name = "Herbal Remedies",                  npc = "Elder Ara" },
                { id = 64842, name = "Flora Frenzy",                     npc = "Elder Ara" },
                { id = 64843, name = "Key Crafting",                     npc = "Elder Ara" },
                { id = 64844, name = "The Pilgrimage Ends",              npc = "Elder Ara", location = "overlook behind Pilgrim's Grace", mapID = 1970, x = 0.6470, y = 0.5350 },
            },
        },

        -- =========================================================================
        -- ACT X — DOMINATION'S GRASP (Shadowlands 9.2, Sepulcher of the First Ones)
        -- Anduin is reached inside the Sepulcher before the Crown can be reforged.
        -- =========================================================================

        -- CHAPTER 16: The king in the Sepulcher
        {
            chapter = "Domination's Grasp",
            gated = true,
            achievementID = 15416, -- Domination's Grasp
            note = "Enter the Sepulcher of the First Ones and clear Domination's Grasp on any difficulty to see Anduin's liberation.",
            summary = "The path through the Sepulcher reaches Anduin at last. Freeing him from Kingsmourne sets the stage for the Crown of Wills.",
            recap = "Within the Sepulcher, the heroes found Anduin still bound to the Jailer's will. The fight was not only to defeat him, but to reach the part of him still resisting. In the end, Anduin found the strength to help shatter Kingsmourne from within. Sylvanas's warning had been true: saving Anduin was the key to opposing Zovaal's design.",
            quests = {},
        },

        -- =========================================================================
        -- ACT XI — CROWN OF WILLS (Shadowlands 9.2, Zereth Mortis)
        -- Anduin is freed, but the Jailer cannot be faced until Domination
        -- itself can be resisted.
        -- =========================================================================

        -- CHAPTER 17: The answer to Domination
        {
            chapter = "Crown of Wills",
            gated = true,
            note = "Continue from The Pilgrimage Ends. This chapter is story-set after Anduin is freed in Sepulcher, but no raid progress is required to play it.",
            summary = "Anduin has been rescued, but the Jailer still commands Domination. Bolvar and the Primus seek a way to turn the broken helm into a weapon of free will.",
            recap = "After Anduin was freed, the way forward was still blocked by the Jailer's Domination magic. Bolvar, Darion, Anduin, and Sylvanas all carried scars from the helm, the blade, or the will behind them. Their memories became part of the answer. In Bastion, Sylvanas faced the wound of what she had done and named the truth plainly: there was no absolution waiting inside a shard of memory, only the choice to keep resisting. The Primus reforged the Helm of Domination into the Crown of Wills, a symbol not of command, but of defiance. With it, Zovaal could finally be faced.",
            quests = {
                { id = 64799, name = "The Broken Crown",             npc = "Highlord Bolvar Fordragon" },
                { id = 64800, name = "Our Last Option",              npc = "Highlord Bolvar Fordragon" },
                { id = 64802, name = "Hello, Darkness",              npc = "The Primus" },
                { id = 64801, name = "Elder Eru",                    npc = "Elder Eru" },
                { id = 64803, name = "Testing One Two",              npc = "Elder Eru" },
                { id = 64804, name = "Cryptic Catalogue",            npc = "Elder Eru" },
                { id = 64805, name = "The Not-Scientific Method",    npc = "Elder Eru" },
                { id = 64853, name = "Two Paths to Tread",           npc = "Elder Eru" },
                { id = 64809, name = "One Half of the Equation",     npc = "The Primus" },
                { id = 64810, name = "Oppress and Destroy",          npc = "Highlord Bolvar Fordragon" },
                { id = 64811, name = "Aggressive Excavation",        npc = "Highlord Bolvar Fordragon" },
                { id = 64806, name = "Where the Memory Resides",     npc = "Highlord Bolvar Fordragon" },
                { id = 64807, name = "What We Wish to Forget",       npc = "Highlord Bolvar Fordragon" },
                { id = 64808, name = "What Makes Us Strong",         npc = "Sylvanas Windrunner" },
                { id = 64798, name = "What We Overcome",             npc = "Highlord Bolvar Fordragon" },
                { id = 64812, name = "Forge of Domination",          npc = "The Primus" },
                { id = 64813, name = "The Crown of Wills",           npc = "The Primus" },
            },
        },

        -- =========================================================================
        -- ACT XII — SEPULCHER OF THE FIRST ONES (Shadowlands 9.2)
        -- The final raid of Shadowlands frees Anduin and ends the Jailer's war.
        -- =========================================================================

        -- CHAPTER 18: The Jailer's fall
        {
            chapter = "Sepulcher of the First Ones",
            gated = true,
            achievementID = 15417, -- Sepulcher of the First Ones
            note = "Enter the Sepulcher of the First Ones in Zereth Mortis. Complete the raid on any difficulty to see Anduin's liberation and the Jailer's defeat.",
            summary = "The campaign reaches the Sepulcher itself. Anduin must be freed from Domination before Zovaal can be stopped at the heart of the First Ones' design.",
            recap = "The way into the Sepulcher opened, and the covenants carried the fight into the machinery of creation. At its heart stood Anduin, still bound to Kingsmourne and the Jailer's will. The heroes broke that domination, and Anduin found the strength to shatter the mourneblade from within. With the Crown of Wills reforged and the covenants united, the final battle moved deeper into the Sepulcher, where Zovaal tried to remake reality through the First Ones' design. He failed. The Jailer fell, and the Shadowlands war finally ended. Only then could Sylvanas be brought before those she had wronged.",
            quests = {},
        },

        -- =========================================================================
        -- ACT XIII — JUDGMENT (Shadowlands 9.2, Zereth Mortis)
        -- After the Jailer's fall, Sylvanas faces the reckoning she has earned.
        -- =========================================================================

        -- CHAPTER 19: The long walk
        {
            chapter = "Judgment",
            gated = true,
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
        -- ACT XIV — THE LONG HUNT (Dragonflight 10.1.7)
        -- The penance continues. The hunt has no end.
        -- =========================================================================

        -- CHAPTER 20: The Long Hunt
        {
            chapter = "The Long Hunt",
            gated = true,
            note = "Complete the Forsaken Heritage questline as an Undead character. Requires having sided with Sylvanas during the war campaign.",
            summary = "Lordaeron has been reclaimed, the penance accepted. But for those who once swore loyalty to the Banshee Queen, a message finds its way back through the dark — one last task, carried by a familiar messenger.",
            recap = "The Forsaken moved on. Lordaeron was theirs again, and the long war had its accounting. But some loyalties don't dissolve with a verdict. Dori'thur arrived in the ruins of Lordaeron bearing a message — not from a queen, not a command, just acknowledgment. The hunt Sylvanas began in death has no end date. The souls in the Maw number in the countless. She is still there, freeing them one by one. The message asked nothing. It only said: she remembers who stood with her.",
            quests = {
                { id = 75519, name = "The Long Hunt", npc = "Dori'thur" },
            },
        },

        -- =========================================================================
        -- ACT XV — THE WARNING (The War Within 11.2.7)
        -- Arator seeks the Windrunners as visions of Silvermoon's fall point
        -- toward Midnight. The road leads back into the Maw.
        -- =========================================================================

        -- CHAPTER 21: Arator in the Maw
        {
            chapter = "The Warning",
            gated = true,
            note = "Begin in Dornogal with Meet Arator, or open the Adventure Guide and start The Warning campaign.",
            summary = "A vision of Quel'Thalas in shadow sends Arator looking for the Windrunners. His search reaches the Maw, where Sylvanas is still freeing the souls she condemned.",
            recap = "Vereesa's visions showed Silvermoon under a shadowed sun, and Arator went looking for the family legacy that might answer it. Alleria was still hunting Xal'atath. Vereesa carried the warning. So Arator followed the trail no one else wanted to walk: through Ve'nari's gate and into the Maw, where Sylvanas continued her penance among the damned. The Devouring Host followed him there, and together he and Sylvanas cut them out of the Tremaculum. Arator asked her to come home. Sylvanas refused. Her duty was still among the dead, but she gave him the answer he needed: Silvermoon did need a Windrunner, and he could be one.",
            quests = {
                { id = 92405, name = "Meet Arator",                         npc = "Silver Hand Squire", location = "outside the Dornogal bank", mapID = 2339, x = 0.5100, y = 0.4500 },
                { id = 84996, name = "Vereesa's Tale",                      npc = "Arator" },
                { id = 84997, name = "What Might Come",                     npc = "Vereesa Windrunner" },
                { id = 84998, name = "Bringer of the Void",                 npc = "Vereesa Windrunner" },
                { id = 85001, name = "Blessings Be Upon You",               npc = "Vereesa Windrunner" },
                { id = 85002, name = "Off to Tazavesh",                     npc = "Arator" },
                { id = 85011, name = "Where in K'aresh is Alleria Windrunner?", npc = "Arator" },
                { id = 85804, name = "The Parent Trap",                     npc = "Arator" },
                { id = 85151, name = "In Her Shadow",                       npc = "Arator" },
                { id = 85155, name = "Do You Have a Spare?",                npc = "Arator" },
                { id = 85184, name = "Repossession is Nine-Tenths of the Law", npc = "Arator" },
                { id = 85185, name = "Those As Well",                       npc = "Arator" },
                { id = 85186, name = "A Cage for Alleria",                  npc = "Alleria Windrunner" },
                { id = 85196, name = "Tag, You're It",                      npc = "Alleria Windrunner" },
                { id = 85212, name = "A Void Test of Wills",                npc = "Alleria Windrunner" },
                { id = 85213, name = "Off to Tazavesh, Again",              npc = "Arator" },
                { id = 85214, name = "Here Goes Something",                 npc = "Ve'nari" },
                { id = 84935, name = "Excising the Incursion",              npc = "Sylvanas Windrunner" },
                { id = 84936, name = "To Cleanse Shadow's Stain",           npc = "Sylvanas Windrunner" },
                { id = 84937, name = "Distant Echoes",                      npc = "Sylvanas Windrunner" },
                { id = 84938, name = "Chaos Control",                       npc = "Arator" },
                { id = 84939, name = "Mad Space",                           npc = "Arator" },
                { id = 84942, name = "The Final Hazard",                    npc = "Arator" },
                { id = 84944, name = "Preludes and Preparations",           npc = "Sylvanas Windrunner" },
                { id = 84943, name = "The Long Vigil",                      npc = "Sylvanas Windrunner" },
                { id = 84945, name = "Repent of the Highborne",             npc = "Vereesa Windrunner" },
                { id = 84946, name = "Returning to Life",                   npc = "Vereesa Windrunner" },
                { id = 84947, name = "Determination",                       npc = "Arator" },
                { id = 84949, name = "The Eleventh Hour",                   npc = "Vereesa Windrunner" },
            },
        },

    },
}
