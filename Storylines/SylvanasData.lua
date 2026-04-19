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
    description = "From the dungeon halls of Icecrown to the judgment courts of Oribos, this is the complete story of Sylvanas Windrunner.\n\nShe entered Icecrown to hunt the man who murdered her and learned something about her own fate from a dead man's ghost. She defied a Warchief to keep the Forsaken alive. She accepted a crown she never asked for and wielded it in ways no one could have predicted. In Battle for Azeroth she burned a world tree, blighted her own capital, and shattered an honourable soldier's last hope — all in service of a plan she barely understood herself.\n\nIn the end, she tore a hole in the sky, descended into Death, and faced what it meant to have brought so much suffering into the world.\n\nThis storyline spans five expansions and is fully playable today.",
    zone = "Icecrown / Silverpine / Orgrimmar / Oribos",
    expansion = "Wrath of the Lich King — Shadowlands",
    achievements = {},
    faction = "Horde",
    color = { 0.20, 0.40, 0.70 },  -- Forsaken void-blue
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
        ["Dark Ranger Vorel"]        = 32644,   -- (verify — dark ranger model)
        ["Grand Executor Mortuus"]   = 31000,   -- (verify)
        ["Deathstalker Belmont"]     = 31001,   -- (verify)
        ["High Executor Darthalia"]  = 31002,   -- (verify)
        ["Captain Russo"]            = 35000,   -- (verify)
        ["High Overlord Saurfang"]   = 14732,
        ["Dark Ranger Alina"]        = 32644,
        ["Nathanos Blightcaller"]    = 86219,
        ["Valeera Sanguinar"]        = 36940,   -- (verify)
        ["Bolvar Fordragon"]         = 95194,
        ["Uther the Lightbringer"]   = 87100,   -- (verify)
        ["Tyrande Whisperwind"]      = 20748,   -- (verify)
        ["Pelagos"]                  = 90000,   -- (verify)
    },
    chapterDisplayIDs = {
        ["The Frozen Halls"]              = 28213,  -- Sylvanas
        ["The War for Silverpine"]        = 28213,  -- Sylvanas
        ["Cities in Dust"]               = 28213,  -- Sylvanas
        ["The Broken Shore"]             = 28213,  -- Sylvanas
        ["The Battle for Lordaeron"]     = 28213,  -- Sylvanas
        ["The Fate of Saurfang"]         = 32644,  -- Dark Ranger Alina
        ["Before the Gates of Orgrimmar"] = 14732,  -- Saurfang
        ["Judgment"]                     = 95194,  -- Bolvar
    },
    chapterIcons = {
        ["The Frozen Halls"]              = 28213,
        ["The War for Silverpine"]        = 28213,
        ["Cities in Dust"]               = 28213,
        ["The Broken Shore"]             = 28213,
        ["The Battle for Lordaeron"]     = 28213,
        ["The Fate of Saurfang"]         = 32644,
        ["Before the Gates of Orgrimmar"] = 14732,
        ["Judgment"]                     = 95194,
    },

    -- =========================================================================
    -- ACT I — THE FROZEN HALLS (Wrath of the Lich King)
    -- Sylvanas enters Icecrown. She learns what waits for Arthas — and herself.
    -- =========================================================================
    chapters = {

        -- CHAPTER 1: The dungeon chain
        {
            chapter = "The Frozen Halls",
            note = "Talk to Dark Ranger Vorel in Dalaran to begin. Runs through three dungeons: Forge of Souls, Pit of Saron, and Halls of Reflection. Horde only — requires Wrath of the Lich King Chromie Time.",
            summary = "Sylvanas leads a covert strike into Icecrown Citadel through a side passage while the Argent Crusade holds the main gate. The route runs through the Forge of Souls, the Pit of Saron, and finally the Halls of Reflection. There, she faces the echo of Arthas and speaks with the ghost of Uther the Lightbringer, who tells her exactly what awaits the Lich King in death — and implies her own fate will not be kind. It is one of her defining moments: grief, hatred, and the first shadow of an obsession with death that will drive everything that follows.",
            recap = "Sylvanas found a crack in Icecrown's defenses and sent you in alongside her. The Forge of Souls. The Pit of Saron. And finally the Halls of Reflection, where she came face to face with the memory of the man who murdered her and enslaved her people. She asked Uther the Lightbringer what would become of Arthas when he died. He told her the only way to truly end the Lich King was at the Frozen Throne where he was made. Then he warned her, in the same breath, that her own fate in death would not be kind. She said nothing. She called for the gunship and got everyone out.",
            quests = {
                { id = 24506, name = "Inside the Frozen Citadel", npc = "Dark Ranger Vorel" },
                { id = 24511, name = "Echoes of Tortured Souls",  npc = "Lady Sylvanas Windrunner" },
                { id = 24682, name = "The Pit of Saron",          npc = "Lady Sylvanas Windrunner" },
                { id = 24498, name = "The Path to the Citadel",   npc = "Lady Sylvanas Windrunner" },
                { id = 24710, name = "Deliverance from the Pit",  npc = "Lady Sylvanas Windrunner" },
                { id = 24713, name = "Frostmourne",               npc = "Lady Sylvanas Windrunner" },
                { id = 24480, name = "Wrath of the Lich King",    npc = "Lady Sylvanas Windrunner" },
            },
        },

        -- =========================================================================
        -- ACT II — THE FORSAKEN MARCH (Cataclysm)
        -- She builds a nation with the dead. Garrosh doesn't approve.
        -- =========================================================================

        -- CHAPTER 2: The march into Silverpine and the Garrosh confrontation
        {
            chapter = "The War for Silverpine",
            note = "Begin at Forsaken High Command in Silverpine Forest. Horde only.",
            summary = "Sylvanas leads the Forsaken into Silverpine Forest and the outskirts of Gilneas, raising the fallen dead as new Forsaken to swell her ranks. When Garrosh Hellscream arrives in person and orders her to stop — pointing out that her Val'kyr tactics make her no different from the Lich King — she does not flinch. The Forsaken have no home. They have only each other, and a Dark Lady willing to do what it takes to keep them alive.",
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

        -- CHAPTER 3: Gilneas, Godfrey, and the final ultimatum
        {
            chapter = "Cities in Dust",
            note = "Continues directly from The War for Silverpine. One quest — \"What Tomorrow Brings\" (#27401) — has a known issue since the Gilneas Reclamation update: the telescope objective may be unreachable on foot. A flying mount can reach it.",
            summary = "The Forsaken push into the Ruins of Gilneas, hunting Worgen insurgents and the treacherous Lord Godfrey. Sylvanas raises Godfrey on the spot as a Forsaken servant. The campaign ends with Lorna Crowley — daughter of the Gilneas Liberation Front's leader — captured and brought before the Dark Lady. Sylvanas delivers her terms: stand down, or watch what little remains of Gilneas burn.",
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

        -- CHAPTER 4: The Broken Shore
        {
            chapter = "The Broken Shore",
            note = "Begin at the Horde dock in Durotar with Captain Russo. Requires Legion Chromie Time.",
            summary = "The Burning Legion attacks the Broken Shore and the Horde charges in. The battle goes badly. Vol'jin is struck by a fel-poisoned blade and will not survive. In his final moments, he tells Sylvanas that the loa spoke to him — and they named her as his successor. She looks at him like he has lost his mind. Then she accepts. The age of the Banshee Queen as Warchief of the Horde has begun.",
            recap = "The Broken Shore was a rout. The Horde threw everything at the Legion's landing force and bled for it. Vol'jin took a wound that no healer could close. By the time the retreat was called, he was dying. He summoned Sylvanas, told her the loa had whispered her name, and asked her to lead. She stood there for a moment — the Dark Lady of the Forsaken, who had never wanted anything to do with the Horde's politics — and said yes. She walked out of that room as Warchief. Nobody, including her, fully understood what that meant yet.",
            quests = {
                { id = 40518, name = "The Battle for Broken Shore", npc = "Captain Russo" },
                { id = 40522, name = "Fate of the Horde",           npc = "High Overlord Saurfang" },
            },
        },

        -- =========================================================================
        -- ACT IV — THE WARCHIEF'S WAR (Battle for Azeroth)
        -- A Warchief who burns everything — including the Horde itself.
        -- =========================================================================

        -- CHAPTER 5: The fall of Undercity
        {
            chapter = "The Battle for Lordaeron",
            note = "This scenario can be replayed at any time via Archivist Sylvia in Orgrimmar.",
            summary = "The Alliance counterstrikes. Led by King Anduin and Jaina Proudmoore, they march on Lordaeron — the Forsaken capital and Sylvanas's seat of power. When the city cannot be held, Sylvanas makes one final, devastating choice: she releases the Blight. The gas that could raise the dead turns on friend and foe alike. The Undercity becomes a tomb of green poison. Sylvanas rides away and does not look back.",
            recap = "Jaina and Anduin brought the Alliance's hammer down on Lordaeron. The Horde fought from the walls, but the siege was overwhelming. When the gates could no longer hold, Sylvanas triggered the plague systems beneath the city — releasing the Blight on her own capital rather than let the Alliance take it. Soldiers on both sides choked and died. The Undercity was lost. Sylvanas rode for the Dark Portal as the Alliance horns echoed behind her. The Forsaken had no home left. Again.",
            quests = {
                { id = 53372, name = "Battle for Azeroth: Hour of Reckoning", npc = "High Overlord Saurfang" },
                { id = 51796, name = "The Battle for Lordaeron",              npc = "High Overlord Saurfang" },
                { id = 53028, name = "A Dying World",                         npc = "Nathanos Blightcaller" },
            },
        },

        -- CHAPTER 6: The hunt for the High Overlord
        {
            chapter = "The Fate of Saurfang",
            note = "Talk to Dark Ranger Alina in Zuldazar to begin.",
            summary = "Varok Saurfang surrendered to the Alliance after the fall of Lordaeron rather than flee with Sylvanas. Now he sits in a Stormwind prison. Sylvanas dispatches Nathanos Blightcaller to retrieve him — or silence him. Saurfang cooperates with the extraction, but entirely on his own terms. He walks out of Stormwind not as a prisoner, but as a man with a plan.",
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

        -- CHAPTER 7: Mak'gora
        {
            chapter = "Before the Gates of Orgrimmar",
            note = "Complete the Horde War Campaign to unlock, then find High Overlord Saurfang outside the gates of Orgrimmar.",
            summary = "Saurfang rallies the Horde's dissidents outside Orgrimmar and invokes Mak'gora — the ancient right of single combat. Sylvanas accepts. She wins. But as Saurfang falls, his last words strip away the last thing she had to rule with: the fear of the Horde's soldiers. She stands at the gate, victorious, surrounded by an army that no longer follows her. Then she leaves.",
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

        -- CHAPTER 8: The long walk
        {
            chapter = "Judgment",
            note = "Complete the Zereth Mortis campaign and defeat the Jailer in the Sepulcher of the First Ones raid to unlock.",
            summary = "With the Jailer defeated, the soul fragments Sylvanas surrendered in her dark bargain are returned to her. She remembers everything — every death, every atrocity, every choice made in the name of a plan she barely understood herself. Then she walks willingly into Oribos to face the judgment of Tyrande Whisperwind and the souls of the dead.",
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
