local addonName, SM = ...

-- =============================================================================
-- Sylvanas Windrunner: The Banshee Queen
-- A saga spanning Battle for Azeroth and Shadowlands.
-- From the burning of Teldrassil to the judgment halls of Oribos —
-- the story of a queen who broke the world, and why.
-- =============================================================================

SM.SylvanasData = {
    -- Questline metadata
    title = "The Banshee Queen",
    description = "Before she became Warchief, Sylvanas Windrunner was a high elf ranger-general who died defending Quel'Thalas from Arthas Menethil. Raised as a banshee and bound to the Lich King's will, she waited — and when Arthas fell, she seized her freedom. She united the Forsaken, carved a place for them in the Horde, and rose through betrayal and blood to claim the highest seat of power.\n\nBut her true goals remained hidden — even from herself. In Battle for Azeroth she leads the Horde on a march that will burn a world tree, blight a beloved city, and shatter the soul of an honourable old soldier. Then, in Shadowlands, she tears a hole in the sky and descends into Death itself — not for conquest, but to unmake the very engine of suffering that created her.\n\nWhat follows is a reckoning across two worlds.",
    zone = "Darkshore / Lordaeron",
    expansion = "Battle for Azeroth — Shadowlands",
    achievements = {},
    faction = "Horde",
    color = { 0.20, 0.40, 0.70 },  -- Forsaken void-blue
    portraitDisplayID = 28213,  -- Lady Sylvanas Windrunner

    -- Start location: Lady Sylvanas Windrunner in Grommash Hold, Orgrimmar
    startQuest = { id = 50476, name = "The Warchief Awaits", npc = "Lady Sylvanas Windrunner", location = "Grommash Hold, Orgrimmar" },
    startMapID = 85,   -- Orgrimmar
    startX = 0.5180,
    startY = 0.3680,

    -- Key NPC locations for waypoint guidance (mapID, x, y)
    npcLocations = {
        -- Orgrimmar
        ["Lady Sylvanas Windrunner"] = { mapID = 85,   x = 0.5180, y = 0.3680 },
        ["High Overlord Saurfang"]   = { mapID = 85,   x = 0.5180, y = 0.3680 },
        -- Ashenvale / Darkshore (War of Thorns)
        ["Lorash"]                   = { mapID = 16,   x = 0.3880, y = 0.5520 },
        ["Zarvik Blastwix"]          = { mapID = 16,   x = 0.3580, y = 0.5800 },
        ["Jux Burstkix"]             = { mapID = 62,   x = 0.3580, y = 0.8480 },
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
        ["High Overlord Saurfang"]   = 14732,
        ["Lorash"]                   = 86220,   -- (verify)
        ["Zarvik Blastwix"]          = 35000,   -- (verify)
        ["Jux Burstkix"]             = 35001,   -- (verify)
        ["Dark Ranger Alina"]        = 32644,
        ["Nathanos Blightcaller"]    = 86219,
        ["Valeera Sanguinar"]        = 36940,   -- (verify)
        ["Bolvar Fordragon"]         = 95194,
        ["Uther the Lightbringer"]   = 87100,   -- (verify)
        ["Tyrande Whisperwind"]      = 20748,   -- (verify)
        ["Pelagos"]                  = 90000,   -- (verify)
    },
    chapterDisplayIDs = {
        ["The March on Darkshore"]           = 28213,  -- Sylvanas
        ["The Burning of Teldrassil"]        = 28213,  -- Sylvanas
        ["The Battle for Lordaeron"]         = 28213,  -- Sylvanas
        ["The Fate of Saurfang"]             = 32644,  -- Dark Ranger Alina
        ["Before the Gates of Orgrimmar"]    = 14732,  -- Saurfang
        ["Death Rising"]                     = 86219,  -- Nathanos
        ["Judgment"]                         = 95194,  -- Bolvar
    },
    chapterIcons = {
        ["The March on Darkshore"]           = 28213,
        ["The Burning of Teldrassil"]        = 28213,
        ["The Battle for Lordaeron"]         = 28213,
        ["The Fate of Saurfang"]             = 32644,
        ["Before the Gates of Orgrimmar"]    = 14732,
        ["Death Rising"]                     = 86219,
        ["Judgment"]                         = 95194,
    },

    -- =========================================================================
    -- ACT I — THE WAR OF THORNS (Battle for Azeroth Pre-Launch)
    -- The Horde's march on Kalimdor, led by a Warchief with hidden purpose.
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: The march begins
        {
            chapter = "The March on Darkshore",
            note = "Requires: Battle for Azeroth pre-patch (8.0.1). These quests were part of a limited-time world event and may be available via the Adventure Journal or phased world content.",
            summary = "Sylvanas calls the Horde to arms. The target: the Night Elf heartland of Kalimdor. With Saurfang at her side, the Horde tears through Ashenvale — burning, clearing, advancing — toward the great tree of Teldrassil. For the Alliance, the wisp wall of Malfurion Stormrage stands in the way. Sylvanas orders it dismantled.",
            recap = "Sylvanas Windrunner, Warchief of the Horde, summoned you to Orgrimmar with a command: march on the Night Elves and seize Kalimdor before the Alliance can mobilize. Saurfang led the vanguard through Ashenvale — past the ruins of Astranaar, through the wisp barrier Malfurion had woven across the road — while Sylvanas watched and waited. The world tree loomed ahead. The Horde had never moved so fast, or with such terrible purpose.",
            quests = {
                { id = 50476, name = "The Warchief Awaits",           npc = "Lady Sylvanas Windrunner" },
                { id = 50642, name = "The Warchief Commands",         npc = "Lady Sylvanas Windrunner" },
                { id = 50646, name = "A Quick Diversion",             npc = "High Overlord Saurfang" },
                { id = 50647, name = "Everybody Has a Price",         npc = "Lorash" },
                { id = 50738, name = "A Timely Arrival",              npc = "Lorash" },
                { id = 50740, name = "Zoram'gar Outpost",             npc = "Lady Sylvanas Windrunner" },
                { id = 50772, name = "On The Prowl",                  npc = "High Overlord Saurfang" },
                { id = 50800, name = "Into the Woods",                npc = "Lady Sylvanas Windrunner" },
                { id = 50823, name = "Ripe for the Picking",          npc = "Lady Sylvanas Windrunner" },
                { id = 50837, name = "A Quick Flyover",               npc = "Lady Sylvanas Windrunner" },
                { id = 50878, name = "Blurred Vision",                npc = "Lady Sylvanas Windrunner" },
                { id = 50879, name = "The Trees Have Ears",           npc = "Lady Sylvanas Windrunner" },
                { id = 50880, name = "An Unstoppable Force",          npc = "Lady Sylvanas Windrunner" },
                { id = 53550, name = "A Change in Leadership",        npc = "High Overlord Saurfang" },
                { id = 52436, name = "The Blackwood Den",             npc = "Lady Sylvanas Windrunner" },
                { id = 53606, name = "Aggressive Inspiration",        npc = "Lady Sylvanas Windrunner" },
                { id = 53608, name = "Fueling the Horde War Machine", npc = "Jux Burstkix" },
                { id = 53609, name = "A Very Clear Message",          npc = "Jux Burstkix" },
                { id = 52437, name = "The Start of Something Good",   npc = "Lady Sylvanas Windrunner" },
                { id = 52438, name = "A Wild Ride",                   npc = "Zarvik Blastwix" },
                { id = 52806, name = "A Looming Threat",              npc = "Lady Sylvanas Windrunner" },
            },
        },

        -- CHAPTER 2: The burning
        {
            chapter = "The Burning of Teldrassil",
            note = "Requires: Battle for Azeroth pre-patch (8.0.1), Week 2 of the War of Thorns event.",
            summary = "Lor'danel falls. Saurfang's forces push to the very shore beneath Teldrassil — but before the Horde can advance, Sylvanas issues an order Saurfang cannot obey: burn the tree. She does it herself. The world tree ignites. What Sylvanas truly wanted from that act remains unclear — until much later.",
            recap = "The second week of war brought the Horde to Lor'danel, the last Night Elf town before Teldrassil itself. The defenders were routed. The path to the world tree was open. Then Sylvanas gave the order to burn it — to deny the Night Elves their sanctuary, their anchor to the living world. Saurfang refused. Sylvanas burned Teldrassil herself. Thousands died. An entire people lost their home. And somewhere in the ash, the seeds of the Horde's fracture were planted.",
            quests = {
                { id = 52967, name = "Saurfang Returns",      npc = "Lady Sylvanas Windrunner" },
                { id = 52970, name = "No Small Mercy",        npc = "High Overlord Saurfang" },
                { id = 52971, name = "Seaside Rendezvous",    npc = "High Overlord Saurfang" },
                { id = 53610, name = "Driving Them Out",      npc = "High Overlord Saurfang" },
                { id = 52981, name = "Killer Queen",          npc = "High Overlord Saurfang" },
            },
        },

        -- =====================================================================
        -- ACT II — BATTLE FOR LORDAERON (Battle for Azeroth Launch)
        -- The Alliance's retribution comes for Undercity.
        -- =====================================================================

        -- CHAPTER 3: The fall of Undercity
        {
            chapter = "The Battle for Lordaeron",
            note = "Requires: Battle for Azeroth (8.0.1). This scenario may be replayed via Archivist Sylvia in Orgrimmar.",
            summary = "The Alliance counterstrikes. Led by King Anduin and Jaina Proudmoore, they march on the Undercity — the Forsaken capital and Sylvanas's seat of power. When the city cannot be held, Sylvanas makes one final, devastating choice: she releases the Blight. The gas that could raise the dead turns on friend and foe alike. The Undercity is lost, poisoned from within. Sylvanas escapes on horseback, leaving nothing but ruin.",
            recap = "Jaina and Anduin brought the Alliance's hammer down on Lordaeron. The Horde fought from the walls of Undercity, but the siege was overwhelming. When the gates could no longer hold, Sylvanas triggered the plague systems beneath the city — releasing the Blight on her own capital rather than let the Alliance take it. Soldiers on both sides choked and died. The Undercity became a tomb of green gas. Sylvanas rode for the Dark Portal as the horns of the Alliance echoed behind her. The Forsaken had no home left.",
            quests = {
                { id = 53372, name = "Battle for Azeroth: Hour of Reckoning", npc = "High Overlord Saurfang" },
                { id = 51796, name = "The Battle for Lordaeron",              npc = "High Overlord Saurfang" },
                { id = 53028, name = "A Dying World",                         npc = "Nathanos Blightcaller" },
            },
        },

        -- =====================================================================
        -- ACT III — THE FATE OF SAURFANG (Patch 8.1)
        -- Sylvanas orders the retrieval of a prisoner. Saurfang won't cooperate.
        -- =====================================================================

        -- CHAPTER 4: The hunt for the High Overlord
        {
            chapter = "The Fate of Saurfang",
            note = "Requires: Battle for Azeroth (8.1). Begin by talking to Dark Ranger Alina in Zuldazar.",
            summary = "Varok Saurfang, captured after the fall of Lordaeron, sits in an Alliance prison in Stormwind. Sylvanas wants him back — or silenced. Nathanos Blightcaller leads the mission to extract the old orc before he becomes a rallying point for those questioning the Warchief's leadership.",
            recap = "After the fall of Lordaeron, Saurfang had surrendered to the Alliance rather than flee with Sylvanas. Now Nathanos Blightcaller was dispatched to retrieve him — or ensure he stayed quiet. You tracked the old orc through layers of Alliance intelligence, piecing together where he was held and what he knew. Saurfang cooperated with the extraction — but on his own terms. He walked out of Stormwind not as a prisoner, but as a man with a plan.",
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

        -- =====================================================================
        -- ACT IV — BEFORE THE GATES (Patch 8.2.5)
        -- An old soldier's challenge. A Warchief who steps aside.
        -- =====================================================================

        -- CHAPTER 5: Mak'gora
        {
            chapter = "Before the Gates of Orgrimmar",
            note = "Requires: Battle for Azeroth (8.2.5). Complete the War Campaign to unlock.",
            summary = "Saurfang rallies the Horde's dissidents outside Orgrimmar. Sylvanas commands her forces to hold the gate. Then Saurfang does what no one expected — he invokes the ancient rite of Mak'gora, a challenge of single combat. Sylvanas accepts. The duel ends in his death — but not before his last words strip away what little she had left to rule with. The Horde watches their Warchief abandon them. She walks away, and does not look back.",
            recap = "Saurfang stood at the gates of Orgrimmar and challenged Sylvanas to Mak'gora — combat to the death, for the soul of the Horde. She accepted. She killed him. But as Saurfang fell, he turned to the watching Horde soldiers and named Sylvanas for what she was: someone who had stopped caring about Horde, honor, or anything they had built together. He died smiling. She stood alone at the gate, victorious, with nothing left to rule over. Then she left. The Horde had no Warchief.",
            quests = {
                { id = 56496, name = "The Eve of Battle",              npc = "High Overlord Saurfang" },
                { id = 57088, name = "This Ain't Mine",                npc = "High Overlord Saurfang" },
                { id = 57090, name = "Saving the Siege",               npc = "High Overlord Saurfang" },
                { id = 57091, name = "Already Among Us",               npc = "High Overlord Saurfang" },
                { id = 57092, name = "Strategic Deployment",           npc = "High Overlord Saurfang" },
                { id = 57093, name = "Before the Gates of Orgrimmar", npc = "High Overlord Saurfang" },
                { id = 57094, name = "The Price of Victory",           npc = "High Overlord Saurfang" },
                { id = 57095, name = "Old Soldier",                    npc = "High Overlord Saurfang" },
                { id = 57198, name = "Sense of Obligation",            npc = "High Overlord Saurfang" },
                { id = 58672, name = "A Gathering of Champions",       npc = "Valeera Sanguinar" },
                { id = 58673, name = "Warchief of the Horde",          npc = "Valeera Sanguinar" },
            },
        },

        -- =====================================================================
        -- ACT V — DEATH RISING (Shadowlands Pre-Patch, 9.0.1)
        -- The Scourge pours out of Icecrown. A barrier between worlds shatters.
        -- =====================================================================

        -- CHAPTER 6: The veil torn open
        {
            chapter = "Death Rising",
            note = "Requires: Shadowlands pre-patch (9.0.1). These quests were a limited-time world event. The Helm-shattering cinematic plays automatically during the pre-patch.",
            summary = "Sylvanas has disappeared into Icecrown Citadel. The Scourge, no longer bound by the Lich King's will, erupts across Azeroth. Bolvar Fordragon — the current Lich King — sends a warning. Nathanos Blightcaller hunts survivors on Sylvanas's behalf. And at the summit of the citadel, before a shocked Bolvar, Sylvanas shatters the Helm of Domination — tearing open the barrier between life and death. The sky above Icecrown splits apart, and something vast and hungry stirs on the other side.",
            recap = "The Scourge was everywhere — in Icecrown, in the streets of the capital cities. Bolvar Fordragon, bearing the Lich King's crown to keep the undead in check, sent out the call for champions to push back the tide. Then Sylvanas struck at the crown itself. She tore it from Bolvar's head and shattered it with her bare hands. The sky cracked open. The Shadowlands — the realm of all death — yawned open above Icecrown like a wound that would never close.",
            quests = {
                { id = 60115, name = "An Urgent Request",               npc = "Nathanos Blightcaller" },
                { id = 60669, name = "Cause for Distraction",           npc = "Nathanos Blightcaller" },
                { id = 60670, name = "Return of the Crusade",           npc = "Nathanos Blightcaller" },
                { id = 60725, name = "Field Reports",                   npc = "Nathanos Blightcaller" },
                { id = 60759, name = "Damned Intruders",                npc = "Nathanos Blightcaller" },
                { id = 60761, name = "Return of the Scourge",           npc = "Nathanos Blightcaller" },
                { id = 60727, name = "A Message from Icecrown",         npc = "Nathanos Blightcaller" },
                { id = 60169, name = "Securing the Area",               npc = "Bolvar Fordragon" },
                { id = 60003, name = "A Valiant Effort",                npc = "Bolvar Fordragon" },
                { id = 62157, name = "Scouting from a Safe Distance",   npc = "Bolvar Fordragon" },
                { id = 60827, name = "Advancing the Effort",            npc = "Bolvar Fordragon" },
            },
        },

        -- =====================================================================
        -- ACT VI — JUDGMENT (Shadowlands 9.2, Zereth Mortis)
        -- After the Jailer's fall, Sylvanas regains her soul — and faces
        -- the reckoning she has earned.
        -- =====================================================================

        -- CHAPTER 7: The long walk
        {
            chapter = "Judgment",
            note = "Requires: Shadowlands (9.2). Complete the Zereth Mortis campaign and defeat the Jailer in the Sepulcher of the First Ones raid to unlock.",
            summary = "With the Jailer defeated in the Sepulcher of the First Ones, the soul fragments Sylvanas surrendered when she made her dark bargain are returned to her. She remembers everything — every death, every atrocity, every choice made in the name of a plan she barely understood herself. Then she walks willingly into Oribos, to face the judgment of Tyrande Whisperwind and the souls of the dead.",
            recap = "The Jailer was dead. Sylvanas was whole again — every fragment of her soul restored from where she had given it away. She stood in silence with the full weight of what she had done pressing down on her at last. Then she walked. Down the long road through Oribos, past the faces of the people she had condemned, she came before Tyrande Whisperwind — who had more right to judge her than anyone alive or dead. Tyrande spoke her sentence. Sylvanas accepted it without a word of protest. She would spend eternity freeing the souls she had imprisoned in the Maw, sending them through the veil one by one. Not as punishment. As penance, freely chosen.",
            quests = {
                { id = 65249, name = "The Jailer's Defeat",   npc = "Bolvar Fordragon" },
                { id = 65250, name = "Prisoner of Interest",  npc = "Uther the Lightbringer" },
                { id = 65260, name = "A Long Walk",           npc = "Uther the Lightbringer" },
                { id = 65263, name = "The Fate of Sylvanas",  npc = "Pelagos" },
                { id = 65297, name = "Penance and Renewal",   npc = "Tyrande Whisperwind" },
            },
        },
    },
}
