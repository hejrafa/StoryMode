local addonName, SM = ...

-- =============================================================================
-- Sylvanas Windrunner: The Banshee Queen
-- A saga spanning Wrath of the Lich King through Shadowlands.
-- From the ice halls of Icecrown to the judgment courts of Oribos —
-- the full story of a queen who broke the world, and why.
-- =============================================================================

SM.SylvanasData = {
    -- Questline metadata
    title = "The Banshee Queen",
    description = "Sylvanas Windrunner was a Ranger-General, then a corpse, then something the Horde was never fully prepared for. Follow her story from the frozen passages of Icecrown through the wars she started — and the reckoning that followed.\n\nThis storyline spans Wrath of the Lich King, Cataclysm, Legion, and Battle for Azeroth.",
    zone = "Icecrown / Silverpine / Orgrimmar / Oribos",
    expansion = "Wrath of the Lich King — Shadowlands",
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
        -- Orgrimmar (War Campaign Finale)
        ["Valeera Sanguinar"]        = { mapID = 85,   x = 0.5050, y = 0.5700 },
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
        ["Valeera Sanguinar"]        = 36940,
        ["Bolvar Fordragon"]         = 95194,
        ["Uther the Lightbringer"]   = 87100,
        ["Tyrande Whisperwind"]      = 20748,
        ["Pelagos"]                  = 90000,
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
        ["Before the Gates of Orgrimmar"] = 14732,  -- High Overlord Saurfang
        ["Judgment"]                     = 95194,  -- Bolvar Fordragon
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
        ["Before the Gates of Orgrimmar"] = 0,
        ["Judgment"]                     = 0,
    },

    -- =========================================================================
    -- ACT I — THE FROZEN HALLS (Wrath of the Lich King)
    -- Sylvanas enters Icecrown. She learns what waits for Arthas — and herself.
    -- =========================================================================
    chapters = {

        -- CHAPTER 1: The dungeon chain
        {
            chapter = "The Frozen Halls",
            note = "Talk to Dark Ranger Vorel in Dalaran to begin. You need to be in the Wrath of the Lich King version of Dalaran — fly to Northrend and land there. Runs through three dungeons: Forge of Souls, Pit of Saron, and Halls of Reflection.",
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
            note = "Defeat the Lich King in Icecrown Citadel — fully soloable at max level. The key Sylvanas moment plays out in the aftermath of the kill.",
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
            note = "Continues directly from The War for Silverpine. One quest — \"What Tomorrow Brings\" (#27401) — has a known issue since the Gilneas Reclamation update: the telescope objective may be unreachable on foot. A flying mount can reach it.",
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
            note = "Begin at the Horde dock in Durotar with Captain Russo. You need to be in the Legion version of the Broken Shore — if the quest isn't available, use Chromie in Orgrimmar to set your timeline to Legion.",
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
            note = "Travel to Darkshore and find Zidormi near the border with Felwood — she can take you back to the War of Thorns and show you Teldrassil's last hours. Mark this chapter viewed when you are done.",
            summary = "The Warchief sets her sights on Darkshore. What unfolds there will make the Fourth War impossible to contain.",
            recap = "The Horde marched into Ashenvale with speed and purpose. You pushed through Night Elf defenses, secured the roads, and drove toward the coast beneath Teldrassil. The Night Elves fought well but the Horde had the numbers and Sylvanas had a plan. The World Tree loomed at the end of it — massive, ancient, and full of civilians who had not escaped in time. Sylvanas stood at its base with the battle won and the tree in reach. A Night Elf prisoner asked what the people inside had done to deserve this. Sylvanas spoke about hope being the enemy. Then she gave the order. Teldrassil burned. The smoke was visible from Stormwind. Whatever Sylvanas had been building toward, this was no longer a war anyone could call limited.",
            quests = {},
        },

        -- CHAPTER 7: The fall of Undercity
        {
            chapter = "The Battle for Lordaeron",
            -- Achievement for completing the Battle for Lordaeron scenario (Horde intro).
            -- Verify in-game: /run local _,n,_,c = GetAchievementInfo(12584); print(n, c)
            -- This fires when replaying via Archivist Sylvia, fixing detection for that path.
            achievementID = 12584,
            note = "This scenario can be played or replayed via Archivist Sylvia in Orgrimmar.",
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

        -- CHAPTER 9: Mak'gora
        {
            chapter = "Before the Gates of Orgrimmar",
            note = "Complete the Horde War Campaign to unlock, then find High Overlord Saurfang outside the gates of Orgrimmar.",
            summary = "Saurfang has gathered the Horde's dissenters outside Orgrimmar. He is invoking Mak'gora — the ancient right of single combat. Sylvanas must answer.",
            recap = "Saurfang stood at the gates of Orgrimmar with every Horde soldier who still had doubts, and he challenged Sylvanas to Mak'gora — combat to the death, for the soul of the Horde. She accepted. She killed him. But as he fell, he turned to the watching soldiers and named her for what she was: someone who had stopped caring about the Horde, honour, or any of the things they had built together. He died smiling. She stood alone at the gate, victorious, with nothing left to rule. Then she left. The Horde had no Warchief.",
            quests = {
                { id = 56496, name = "The Eve of Battle",              npc = "High Overlord Saurfang" },
                { id = 57088, name = "This Ain't Mine",                npc = "High Overlord Saurfang" },
                { id = 57090, name = "Saving the Siege",               npc = "High Overlord Saurfang" },
                { id = 57091, name = "Already Among Us",               npc = "High Overlord Saurfang" },
                { id = 57092, name = "Strategic Deployment",           npc = "High Overlord Saurfang" },
                { id = 57093, name = "Before the Gates of Orgrimmar",  npc = "High Overlord Saurfang" },
                { id = 57094, name = "The Price of Victory",           npc = "High Overlord Saurfang" },
                { id = 57095, name = "Old Soldier",                    npc = "High Overlord Saurfang" },
                { id = 57198, name = "Sense of Obligation",            npc = "High Overlord Saurfang" },
                { id = 58672, name = "A Gathering of Champions",       npc = "Valeera Sanguinar" },
                { id = 58673, name = "Warchief of the Horde",          npc = "Valeera Sanguinar" },
            },
        },

        -- =========================================================================
        -- ACT V — JUDGMENT (Shadowlands 9.2, Zereth Mortis)
        -- After the Jailer's fall, Sylvanas regains her soul — and faces
        -- the reckoning she has earned.
        -- =========================================================================

        -- CHAPTER 10: The long walk
        {
            chapter = "Judgment",
            note = "Complete the Zereth Mortis campaign and defeat the Jailer in the Sepulcher of the First Ones raid to unlock.",
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

    },
}
