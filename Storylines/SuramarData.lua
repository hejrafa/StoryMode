local addonName, SM = ...

-- =============================================================================
-- Suramar Campaign Quest Database
-- Zone: Suramar (Legion)
-- Achievement: Good Suramaritan (11124)
-- =============================================================================
-- Starting quest: Khadgar's Discovery (39985) from Archmage Khadgar in Dalaran
-- Zone entry coordinates: Suramar, The Broken Isles
-- =============================================================================

SM.SuramarData = {
    -- Questline metadata
    title = "Insurrection",
    description = "An ancient elven city under Legion occupation, sealed behind a magical barrier for ten thousand years. Aid First Arcanist Thalyssra and the nightfallen rebellion as they gather allies, infiltrate the noble houses, and prepare an assault to free Suramar from the grip of Grand Magistrix Elisande and her pact with the Burning Legion.",
    zone = "Suramar",
    expansion = "Legion",
    achievementID = 11340,
    achievementName = "Insurrection",
    achievements = {
        -- Suramar story
        10617,  -- Nightfallen But Not Forgotten (main gated chapter chain)
        11124,  -- Good Suramaritan (all side-chapter storylines)
        11340,  -- Insurrection (all 9 patch-7.1 chapters)
        10778,  -- The Nightfallen (Exalted with The Nightfallen)
        -- The Nighthold
        42030,  -- The Nighthold (full clear)
    },
    color = { 0.55, 0.35, 0.85 },  -- Suramar arcane purple
    icon = 1525722,

    -- Start location: Archmage Khadgar in the Violet Citadel, Dalaran (Legion)
    startQuest = { id = 39985, name = "Khadgar's Discovery", npc = "Archmage Khadgar", location = "The Violet Citadel, Dalaran" },
    startMapID = 626,   -- Dalaran (Legion)
    startX = 0.2858,    -- Violet Citadel
    startY = 0.4857,

    -- Key NPC locations for waypoint guidance (mapID, x, y)
    npcLocations = {
        ["Archmage Khadgar"]            = { mapID = 626, x = 0.2858, y = 0.4857 },  -- Dalaran, Violet Citadel
        ["First Arcanist Thalyssra"]    = { mapID = 680, x = 0.3674, y = 0.4680 },  -- Shal'Aran, Suramar
        ["Chief Telemancer Oculeth"]    = { mapID = 680, x = 0.3674, y = 0.4680 },  -- Shal'Aran
        ["Arcanist Valtrois"]           = { mapID = 680, x = 0.3674, y = 0.4680 },  -- Shal'Aran
        ["Arcanist Kel'danath"]         = { mapID = 680, x = 0.3674, y = 0.4680 },  -- Shal'Aran
        ["Valewalker Farodin"]          = { mapID = 680, x = 0.3674, y = 0.4680 },  -- Shal'Aran
        ["Ly'leth Lunastre"]            = { mapID = 680, x = 0.4258, y = 0.3131 },  -- Lunastre Estate, Suramar City
        ["Silgryn"]                     = { mapID = 680, x = 0.3430, y = 0.4880 },  -- Waning Crescent area
        ["Theryn"]                      = { mapID = 680, x = 0.4400, y = 0.3520 },  -- Tel'anor
        ["Mylune"]                      = { mapID = 680, x = 0.2250, y = 0.3950 },  -- Irongrove Retreat
        ["Keeper Remulos"]              = { mapID = 680, x = 0.2250, y = 0.3950 },  -- Irongrove Retreat
        ["Toryl"]                       = { mapID = 680, x = 0.6380, y = 0.5200 },  -- Jandvik
        ["Lyana Darksorrow"]            = { mapID = 680, x = 0.3100, y = 0.6200 },  -- Felsoul Hold area
        ["Ancient Keeper"]              = { mapID = 680, x = 0.3000, y = 0.1350 },  -- Moon Guard Stronghold
    },

    -- NPC creature display IDs for chapter portraits
    -- Used with SetPortraitTextureFromCreatureDisplayID()
    -- Look up on wowhead.com model viewer or /run print(UnitCreatureDisplayID("target"))
    npcDisplayIDs = {
        ["Archmage Khadgar"]            = 65834,
        ["First Arcanist Thalyssra"]    = 65100,
        ["Chief Telemancer Oculeth"]    = 73853,
        ["Arcanist Valtrois"]           = 67696,
        ["Arcanist Kel'danath"]         = 70943,
        ["Valewalker Farodin"]          = 69847,
        ["Ly'leth Lunastre"]            = 70210,
        ["Silgryn"]                     = 65081,
        ["Theryn"]                      = 68238,
        ["Mylune"]                      = 72120,
        ["Keeper Remulos"]              = 11906,
        ["Toryl"]                       = 67580,
        ["Lyana Darksorrow"]            = 72998,
        ["Ancient Keeper"]              = 70768,
        ["Thalrenus Rivertree"]         = 66972,
        ["Syrana Starweaver"]          = 66971,
        ["Lady Liadrin"]                = 61971,
        ["Tyrande Whisperwind"]         = 694523,
        ["Noressa"]                     = 70017,
        ["Stellagosa"]                  = 64545,
    },

    -- =========================================================================
    -- PRE-REQUISITE CHAINS (Nightfallen But Not Forgotten - Achievement 10617)
    -- These must be completed before the Good Suramaritan chapters unlock
    -- =========================================================================
    prereqs = {
        -- -----------------------------------------------------------------
        -- Chapter: Nightfall
        -- Unlocks Shal'Aran as the base of operations
        -- -----------------------------------------------------------------
        {
            chapter = "Nightfall",
            summary = "Discover the nightfallen exiles hiding in the ruins of Shal'Aran and learn the desperate truth behind Suramar's shimmering barrier.",
            recap = "You answered Khadgar's call and journeyed into the ancient city of Suramar, finding it sealed behind a shimmering barrier of arcane power. Beyond the wall, you discovered First Arcanist Thalyssra — once a leader of the Nightborne, now exiled and starving for mana. Together you claimed the ruins of Shal'Aran as a hidden refuge, a fragile spark of rebellion in the shadow of the Grand Magistrix.",
            achievement = nil, -- Part of Nightfallen But Not Forgotten (10617)
            quests = {
                { id = 39985, name = "Khadgar's Discovery",             npc = "Archmage Khadgar" },
                { id = 39986, name = "Magic Message",                   npc = "Archmage Khadgar" },
                { id = 39987, name = "Trail of Echoes",                 npc = "Archmage Khadgar" },
                { id = 40008, name = "The Only Way Out is Through",     npc = "Archmage Khadgar" },
                { id = 40123, name = "The Nightborne Pact",             npc = "First Arcanist Thalyssra" },
                { id = 40009, name = "Arcane Thirst",                   npc = "First Arcanist Thalyssra" },
                { id = 43994, name = "Feed Thalyssra",                  npc = "First Arcanist Thalyssra" },
                { id = 42229, name = "Shal'Aran",                       npc = "First Arcanist Thalyssra" },
                { id = 44672, name = "Ancient Mana",                    npc = "First Arcanist Thalyssra" },
            },
        },
        -- -----------------------------------------------------------------
        -- Chapter: Arcanist Kel'danath
        -- Branches from Shal'Aran (42229) in parallel with Oculeth's Workshop
        -- -----------------------------------------------------------------
        {
            chapter = "Arcanist Kel'danath",
            summary = "Rescue a brilliant arcanist trapped by withered nightfallen and secure his knowledge for the growing rebellion.",
            recap = "Deep in the tunnels beneath Suramar, you found Arcanist Kel'danath on the edge of withering, his brilliant mind nearly consumed by mana starvation. You fought through packs of feral withered to reach him, recovering his scattered research notes and the remnants of his arcane experiments. His knowledge of ancient Nightborne magic proved invaluable to the growing rebellion.",
            achievement = nil,
            quests = {
                { id = 40012, name = "An Old Ally",                     npc = "First Arcanist Thalyssra" },
                { id = 41149, name = "A Re-Warding Effort",             npc = "Arcanist Kel'danath" },
                { id = 40326, name = "Scattered Memories",              npc = "Arcanist Kel'danath" },
                { id = 40327, name = "Written in Stone",                npc = "Arcanist Kel'danath" },
                { id = 41704, name = "Subject 16",                      npc = "Arcanist Kel'danath" },
                { id = 41760, name = "Kel'danath's Legacy",             npc = "Arcanist Kel'danath" },
            },
        },
        -- -----------------------------------------------------------------
        -- Chapter: Chief Telemancer Oculeth
        -- Branches from Shal'Aran (42229) in parallel with An Old Ally
        -- -----------------------------------------------------------------
        {
            chapter = "Chief Telemancer Oculeth",
            summary = "Help Chief Telemancer Oculeth restore the teleportation network, opening new paths across Suramar.",
            recap = "You located Chief Telemancer Oculeth in his ruined workshop, surrounded by the wreckage of his life's work. Together you restored fragments of the ancient telemancy network, reactivating portals that would allow the rebels to move unseen across Suramar. The old telemancer's genius may have dulled with hunger, but his loyalty to Thalyssra never wavered.",
            achievement = nil,
            quests = {
                { id = 40011, name = "Oculeth's Workshop",              npc = "First Arcanist Thalyssra" },
                { id = 40747, name = "The Delicate Art of Telemancy",   npc = "Chief Telemancer Oculeth" },
                { id = 40748, name = "Network Security",                npc = "Chief Telemancer Oculeth" },
                { id = 40830, name = "Close Enough",                    npc = "Chief Telemancer Oculeth" },
                { id = 44691, name = "Hungry Work",                     npc = "Chief Telemancer Oculeth" },
                { id = 43106, name = "Feed Oculeth",                    npc = "Chief Telemancer Oculeth" },
                { id = 40956, name = "Survey Says...",                  npc = "Chief Telemancer Oculeth" },
            },
        },
        -- -----------------------------------------------------------------
        -- Chapter: Feeding Shal'Aran
        -- -----------------------------------------------------------------
        {
            chapter = "Feeding Shal'Aran",
            summary = "Establish a supply of ancient mana to sustain the nightfallen rebels and prevent them from withering.",
            recap = "You ventured into the ley line tunnels beneath Suramar, fighting corrupted creatures to restore the flow of ancient mana to Shal'Aran. The cavern hummed back to life as power surged through its crystalline conduits, giving the nightfallen refugees a lifeline against the withering that threatened to consume them all.",
            achievement = nil,
            quests = {
                { id = 40010, name = "Tapping the Leylines",            npc = "First Arcanist Thalyssra" },
                { id = 41028, name = "Power Grid",                      npc = "Arcanist Valtrois" },
                { id = 41168, name = "Turtle Powered",                  npc = "Arcanist Valtrois" },
                { id = 41169, name = "Something in the Water",          npc = "Arcanist Valtrois" },
                { id = 41170, name = "Purge the Unclean",               npc = "Arcanist Valtrois" },
                { id = 41138, name = "Feeding Shal'Aran",               npc = "Arcanist Valtrois" },
                { id = 43995, name = "Feed Valtrois",                   npc = "Arcanist Valtrois", optional = true },
            },
        },
        -- -----------------------------------------------------------------
        -- Chapter: Masquerade
        -- -----------------------------------------------------------------
        {
            chapter = "Masquerade",
            summary = "Disguise yourself as a Nightborne noble and infiltrate Suramar City to gather intelligence for the rebellion.",
            recap = "Through Ly'leth Lunastre's connections, you obtained a magical disguise and walked the gilded streets of Suramar City as one of the Nightborne elite. Behind the masks and pleasantries, you made first contact with sympathizers among the nobility — those who whispered against Elisande but dared not act alone.",
            achievement = nil,
            quests = {
                { id = 41762, name = "Sympathizers Among the Shal'dorei", npc = "First Arcanist Thalyssra" },
                { id = 41834, name = "The Masks We Wear",               npc = "Ly'leth Lunastre" },
                { id = 41989, name = "Blood of My Blood",               npc = "Ly'leth Lunastre" },
                { id = 42079, name = "Masquerade",                      npc = "Ly'leth Lunastre" },
                { id = 42147, name = "First Contact",                   npc = "First Arcanist Thalyssra" },
            },
        },
        -- -----------------------------------------------------------------
        -- Chapter: The Light Below
        -- -----------------------------------------------------------------
        {
            chapter = "The Light Below",
            summary = "Explore ancient ley line tunnels beneath Suramar, discovering forgotten power that could turn the tide.",
            recap = "Guided by Kel'danath's research, you descended into ancient caverns beneath Suramar, where moonlight filtered through crystal and the memories of the city's founding still lingered. You discovered the hidden legacy of Valewalker Farodin and the Arcan'dor — a tree of immense power that might hold the key to curing the nightfallen's addiction to the Nightwell.",
            achievement = nil,
            quests = {
                { id = 40324, name = "Arcane Communion",                npc = "Arcanist Kel'danath" },
                { id = 40325, name = "Scenes from a Memory",            npc = "Arcanist Kel'danath" },
                { id = 42224, name = "Cloaked in Moonshade",            npc = "Arcanist Kel'danath" },
                { id = 42225, name = "Breaking the Seal",               npc = "Arcanist Kel'danath" },
                { id = 42226, name = "Moonshade Holdout",               npc = "Arcanist Kel'danath" },
                { id = 42227, name = "Into the Crevasse",               npc = "Arcanist Kel'danath" },
                { id = 42228, name = "The Hidden City",                 npc = "Arcanist Kel'danath" },
                { id = 42230, name = "The Valewalker's Burden",         npc = "Valewalker Farodin" },
            },
        },
    },

    -- =========================================================================
    -- GOOD SURAMARITAN CHAPTERS (Achievement 11124)
    -- Each sub-section is a criteria of the meta-achievement
    -- =========================================================================
    -- Chapters ordered by Blizzard's intended progression (Nightfallen rep gates).
    -- Main storyline (rep-gated): Waning Crescent → Blood and Wine → Statecraft
    --   → A Growing Crisis → A Change of Seasons → Eminent Grow-main
    -- Side zones (no rep gate, slotted between gated chapters as rep-building):
    --   Moon Guard Stronghold, Tidying Tel'anor, Breaking The Lightbreaker, Jandvik's Jarl
    chapters = {
        -- -----------------------------------------------------------------
        -- 1. The Waning Crescent (Achievement 10759) — unlocks at Friendly
        -- -----------------------------------------------------------------
        {
            chapter = "The Waning Crescent",
            summary = "Make contact with nightfallen refugees hiding in the slums of Suramar City, right under Elisande's nose.",
            recap = "You slipped into the Waning Crescent, a forgotten slum where nightfallen refugees huddled in the shadows of Suramar City. Working alongside Silgryn, you established supply lines, freed imprisoned allies, and built a network of safe houses right beneath the Duskwatch's nose. What began as a handful of desperate exiles became the backbone of an underground resistance.",
            quests = {
                { id = 41877, name = "Lady Lunastre",                   npc = "Ly'leth Lunastre" },
                { id = 40746, name = "One of the People",               npc = "Ly'leth Lunastre" },
                { id = 41148, name = "Dispensing Compassion",           npc = "Silgryn" },
                { id = 42859, name = "A Draught of Hope",               npc = "Silgryn" },
                { id = 40947, name = "Special Delivery",                npc = "Silgryn" },
                { id = 44744, name = "Secret Correspondence",           npc = "Silgryn" },
                { id = 41878, name = "The Gondolier",                   npc = "Silgryn" },
                { id = 40727, name = "All Along the Waterways",         npc = "Silgryn" },
                { id = 42724, name = "Redistribution",                  npc = "Silgryn" },
                { id = 42725, name = "Sharing the Wealth",              npc = "Silgryn" },
                { id = 42726, name = "Lifelines",                       npc = "Silgryn" },
                { id = 40745, name = "Shift Change",                    npc = "Silgryn" },
                { id = 42969, name = "A Spy in Our Midst",              npc = "Silgryn" },
                { id = 42722, name = "Friends in Cages",                npc = "Silgryn" },
                { id = 42723, name = "Freeing the Taken",               npc = "Silgryn" },
                { id = 42486, name = "Little One Lost",                 npc = "Silgryn" },
                { id = 42487, name = "Friends On the Outside",          npc = "Silgryn" },
                { id = 44051, name = "Wasted Potential",                npc = "Silgryn" },
                { id = 42488, name = "Thalyssra's Abode",               npc = "Silgryn" },
                { id = 42489, name = "Thalyssra's Drawers",             npc = "First Arcanist Thalyssra" },
            },
        },
        -- -----------------------------------------------------------------
        -- 2. Blood and Wine (Achievement 10758) — unlocks at Friendly
        -- -----------------------------------------------------------------
        {
            chapter = "Blood and Wine",
            summary = "Infiltrate the Nightborne wine trade, disrupting the flow of arcwine that keeps the populace loyal to the Grand Magistrix.",
            recap = "You infiltrated the arcwine vineyards that kept Suramar's populace docile and dependent on Elisande's generosity. Working with Vintner Iltheux and the defiant Margaux, you sabotaged the production, poisoned the supply, and struck at the very system of control the Grand Magistrix had built. When Margaux fell to the Duskwatch's retribution, you ensured her sacrifice was not in vain — the rebellion now had its own supply of arcwine and the loyalty of those she inspired.",
            quests = {
                { id = 42828, name = "Moths to a Flame",                npc = "First Arcanist Thalyssra" },
                { id = 42829, name = "Make an Entrance",                npc = "First Arcanist Thalyssra" },
                { id = 42832, name = "The Fruit of Our Efforts",        npc = "Vintner Iltheux" },
                { id = 42833, name = "How It's Made: Arcwine",          npc = "Vintner Iltheux" },
                { id = 42834, name = "Intense Concentration",           npc = "Vintner Iltheux" },
                { id = 42835, name = "The Old Fashioned Way",           npc = "Vintner Iltheux" },
                { id = 42836, name = "Silkwing Sabotage",               npc = "Margaux" },
                { id = 42837, name = "Balance to Spare",                npc = "Margaux" },
                { id = 42838, name = "Reversal",                        npc = "Margaux" },
                { id = 44084, name = "Vengeance for Margaux",           npc = "First Arcanist Thalyssra" },
                { id = 42839, name = "Seek the Unsavory",               npc = "First Arcanist Thalyssra" },
                { id = 43969, name = "Hired Help",                      npc = "Meline" },
                { id = 42840, name = "If Words Don't Work...",          npc = "Meline" },
                { id = 42841, name = "A Big Score",                     npc = "Meline" },
                { id = 43352, name = "Asset Security",                  npc = "Meline" },
                { id = 42792, name = "Make Your Mark",                  npc = "Meline" },
                { id = 44052, name = "And They Will Tremble",           npc = "First Arcanist Thalyssra" },
            },
        },
        -- -----------------------------------------------------------------
        -- 3. Statecraft (Achievement 10760) — unlocks at Honored
        -- -----------------------------------------------------------------
        {
            chapter = "Statecraft",
            summary = "Navigate the treacherous politics of Suramar's noble houses alongside the cunning Ly'leth Lunastre.",
            recap = "Under Ly'leth Lunastre's guidance, you plunged into the viper pit of Nightborne politics — buying votes, silencing rivals, and navigating a web of alliances that shifted with every whispered rumor. Through cunning and carefully applied force, Ly'leth secured her position among the nobility and opened the path to the Arcway, an ancient tunnel network running beneath the city.",
            repRequirement = { faction = "The Nightfallen", level = "Honored" },
            quests = {
                { id = 43309, name = "The Perfect Opportunity",         npc = "Ly'leth Lunastre" },
                { id = 43310, name = "Either With Us",                  npc = "Ly'leth Lunastre" },
                { id = 43312, name = "Thinly Veiled Threats",           npc = "Ly'leth Lunastre" },
                { id = 44040, name = "Vote of Confidence",              npc = "Ly'leth Lunastre" },
                { id = 43311, name = "Or Against Us",                   npc = "Ly'leth Lunastre" },
                { id = 43315, name = "Death Becomes Him",               npc = "Ly'leth Lunastre" },
                { id = 43313, name = "Rumor Has It",                    npc = "Ly'leth Lunastre" },
                { id = 43314, name = "In the Bag",                      npc = "Ly'leth Lunastre" },
                { id = 43318, name = "Ly'leth's Champion",              npc = "Ly'leth Lunastre" },
                { id = 44053, name = "Friends With Benefits",           npc = "Ly'leth Lunastre" },
                { id = 43317, name = "The Arcway: Opening the Arcway",  npc = "First Arcanist Thalyssra" },
                { id = 43319, name = "Court of Stars: Beware the Fury of a Patient Elf", npc = "Ly'leth Lunastre",        optional = true },
                { id = 44054, name = "The Arcway: Long Buried Knowledge",                npc = "First Arcanist Thalyssra", optional = true },
            },
        },
        -- -----------------------------------------------------------------
        -- 4. Moon Guard Stronghold (Achievement 10763) — no rep gate
        -- -----------------------------------------------------------------
        -- 4. A Growing Crisis — unlocks at Honored
        -- -----------------------------------------------------------------
        {
            chapter = "A Growing Crisis",
            summary = "The Arcan'dor is struggling to survive. Race against time to find what it needs before the tree withers.",
            recap = "The Arcan'dor — the ancient tree nurtured in Shal'Aran — began to wither, its roots cracking and leaves curling despite all efforts. Valewalker Farodin led you on a desperate search for fragments of arcane power scattered across Suramar's ruins. In the end, you secured a branch of the Arcan'dor itself, stabilizing the tree and keeping alive the dream of a cure for the nightfallen.",
            repRequirement = { faction = "The Nightfallen", level = "Honored" },
            quests = {
                { id = 44152, name = "A Growing Crisis",                npc = "Valewalker Farodin" },
                { id = 43361, name = "Fragments of Disaster",           npc = "Valewalker Farodin" },
                { id = 43360, name = "The Shardmaidens",                npc = "Valewalker Farodin" },
                { id = 43364, name = "Another Arcan'dor Closes...",     npc = "Valewalker Farodin" },
                { id = 40125, name = "Branch of the Arcan'dor",         npc = "First Arcanist Thalyssra" },
                { id = 43362, name = "The Stuff of Dreams",             npc = "First Arcanist Thalyssra" },
            },
        },
        -- -----------------------------------------------------------------
        -- 5. A Change of Seasons — unlocks at Revered
        -- -----------------------------------------------------------------
        {
            chapter = "A Change of Seasons",
            summary = "Journey to the ancient groves of Val'sharah to find a seed that could save the Arcan'dor.",
            recap = "The Arcan'dor needed something that could not be found in Suramar — a seed blessed by the wild magic of Val'sharah. You journeyed with Thalyssra's allies to retrieve it, channeling ley energy through Oculeth's projectors and Valtrois's calculations. The seed took root, and the Arcan'dor bloomed with renewed strength, its fruit offering the first true cure for the nightfallen's dependence on the Nightwell.",
            repRequirement = { faction = "The Nightfallen", level = "Revered" },
            quests = {
                { id = 43502, name = "A Change of Seasons",             npc = "First Arcanist Thalyssra" },
                { id = 43562, name = "Giving It All We've Got",         npc = "First Arcanist Thalyssra" },
                { id = 43563, name = "Ephemeral Manastorm Projector",   npc = "Chief Telemancer Oculeth" },
                { id = 43564, name = "Flow Control",                    npc = "Arcanist Valtrois" },
                { id = 43565, name = "Bring Home the Beacon",           npc = "Arcanist Valtrois" },
                { id = 43567, name = "All In",                          npc = "First Arcanist Thalyssra" },
                { id = 43568, name = "Arcan'dor, Gift of the Ancient Magi", npc = "First Arcanist Thalyssra" },
                { id = 43569, name = "Arluin's Request",                npc = "Arluin" },
            },
        },
    },

    -- =========================================================================
    -- INSURRECTION (Patch 7.1) - Achievement 11340
    -- Final Suramar campaign, unlocks after completing Good Suramaritan
    -- =========================================================================
    insurrection = {
        achievementID = 11340,
        achievementName = "Insurrection",
        -- -----------------------------------------------------------------
        -- Sub-chapter 1: Lockdown
        -- -----------------------------------------------------------------
        {
            chapter = "Lockdown",
            summary = "Elisande seals Suramar's gates and tightens her grip. The resistance must find a way through the lockdown.",
            recap = "Grand Magistrix Elisande sealed the city, sending her Duskwatch to crush any hint of dissent. The crackdown was swift and merciless. You fought through patrols and barricades to evacuate nightfallen sympathizers before they could be captured, but not everyone made it out. As the gates slammed shut, the rebellion was forced deeper underground.",
            criteriaQuest = { id = 44955, name = "Visitor in Shal'Aran" },
            quests = {
                { id = 45260, name = "One Day at a Time",               npc = "First Arcanist Thalyssra" },
                { id = 38649, name = "Silence in the City",             npc = "First Arcanist Thalyssra" },
                { id = 38695, name = "Crackdown",                       npc = "Silgryn" },
                { id = 38692, name = "Answering Aggression",            npc = "Silgryn" },
                { id = 38720, name = "No Reason to Stay",               npc = "Silgryn" },
                { id = 38694, name = "Regroup",                         npc = "Silgryn" },
                { id = 42889, name = "The Way Back Home",               npc = "Silgryn" },
                { id = 44955, name = "Visitor in Shal'Aran",            npc = "First Arcanist Thalyssra" },
            },
        },
        -- -----------------------------------------------------------------
        -- Sub-chapter 2: Missing Persons
        -- -----------------------------------------------------------------
        {
            chapter = "Missing Persons",
            summary = "Key members of the resistance have vanished. Search the city to find them before it's too late.",
            recap = "Key members of the resistance vanished without a trace — taken in the night by Elisande's agents. You tracked them through Suramar's twisting streets, from soul cages to smuggler's routes, pulling allies from the jaws of captivity. The message was clear: the Grand Magistrix knew about the rebellion, and she was coming for them all.",
            criteriaQuest = { id = 44814, name = "Waning Refuge" },
            quests = {
                { id = 45261, name = "Continuing the Cure",             npc = "First Arcanist Thalyssra" },
                { id = 44722, name = "Disillusioned Defector",          npc = "First Arcanist Thalyssra" },
                { id = 44723, name = "More Like Me",                    npc = "Silgryn" },
                { id = 44724, name = "Missing Persons",                 npc = "First Arcanist Thalyssra" },
                { id = 44725, name = "Hostage Situation",               npc = "Silgryn" },
                { id = 44726, name = "In the Business of Souls",        npc = "Silgryn" },
                { id = 44727, name = "Smuggled!",                       npc = "Silgryn" },
                { id = 44814, name = "Waning Refuge",                   npc = "Silgryn" },
            },
        },
        -- -----------------------------------------------------------------
        -- Sub-chapter 3: Waxing Crescent
        -- -----------------------------------------------------------------
        {
            chapter = "Waxing Crescent",
            summary = "The rebellion grows bolder, establishing a foothold in the Waning Crescent district of Suramar City.",
            recap = "The rebellion emerged from hiding and seized the Waning Crescent district in an act of open defiance. You helped Oculeth triangulate and rescue an imprisoned ally put on public display as a warning, then established the first openly rebel-held territory in Suramar City. The Dusk Lily — the rebellion's symbol — flew for the first time where Elisande's banners once hung.",
            criteriaQuest = { id = 44756, name = "Sign of the Dusk Lily" },
            quests = {
                { id = 45262, name = "A Message From Ly'leth",          npc = "Ly'leth Lunastre" },
                { id = 44742, name = "Tavernkeeper's Fate",             npc = "Ly'leth Lunastre" },
                { id = 44752, name = "Essence Triangulation",           npc = "Chief Telemancer Oculeth" },
                { id = 44753, name = "On Public Display",               npc = "Chief Telemancer Oculeth" },
                { id = 44754, name = "Waxing Crescent",                 npc = "Silgryn" },
                { id = 44756, name = "Sign of the Dusk Lily",           npc = "Silgryn" },
            },
        },
        -- -----------------------------------------------------------------
        -- Sub-chapter 4: An Elven Problem
        -- -----------------------------------------------------------------
        {
            chapter = "An Elven Problem",
            summary = "Seek aid from the night elves and blood elves, bridging ten thousand years of division for a common cause.",
            recap = "Ten thousand years of division between the elven peoples had to be bridged if Suramar was to be freed. You stood between night elf and blood elf, forging an uneasy alliance from shared purpose. Lady Liadrin and Tyrande Whisperwind each brought their people's strength to the cause, while you cleared the Promenade of Elisande's defenses.",
            criteriaQuest = { id = 44845, name = "Break An Arm" },
            quests = {
                { id = 45316, name = "Stabilizing Suramar",             npc = "First Arcanist Thalyssra" },
                { id = 45263, name = "Eating Before the Meeting",       npc = "First Arcanist Thalyssra" },
                { id = 40391, name = "Take Me To Your Leader",          npc = "First Arcanist Thalyssra" },
                { id = 43810, name = "Down to Business",                npc = "Silgryn" },
                { id = 44831, name = "Taking a Promenade",              npc = "Silgryn" },
                { id = 41916, name = "A Better Future",                 npc = "Lady Liadrin / Tyrande Whisperwind" },
                { id = 44843, name = "Crystal Clearing",                npc = "Silgryn" },
                { id = 44844, name = "Powering Down the Portal",        npc = "Silgryn" },
                { id = 44834, name = "Nullified",                       npc = "Silgryn" },
                { id = 44845, name = "Break An Arm",                    npc = "Silgryn" },
            },
        },
        -- -----------------------------------------------------------------
        -- Sub-chapter 5: Crafting War
        -- -----------------------------------------------------------------
        {
            chapter = "Crafting War",
            summary = "Prepare the rebellion's weapons, armor, and siege equipment for the final assault on Suramar.",
            recap = "The time for subtlety had passed. You helped Oculeth build war machines, gathered supplies with Valtrois, trained civilian volunteers into a fighting force, and armed the rebellion with weapons taken from the Legion itself. When the trial by demonfire proved the rebels could hold their own, there was nothing left to do but march.",
            criteriaQuest = { id = 44790, name = "Trial by Demonfire" },
            quests = {
                { id = 45265, name = "Feeding the Rebellion",           npc = "First Arcanist Thalyssra" },
                { id = 44743, name = "Tyrande's Command",               npc = "Tyrande Whisperwind" },  -- Alliance
                { id = 44850, name = "Liadrin's Command",               npc = "Lady Liadrin" },          -- Horde
                { id = 44851, name = "Noressa",                         npc = "Noressa" },
                { id = 44852, name = "Mouths to Feed",                  npc = "Noressa" },
                { id = 44873, name = "Oculeth Ex Machina",              npc = "Chief Telemancer Oculeth" },
                { id = 44793, name = "Unbeleyvable",                    npc = "Arcanist Valtrois" },
                { id = 44794, name = "The Art of Flow",                 npc = "Arcanist Valtrois" },
                { id = 44795, name = "A Dance With Dragons",            npc = "Stellagosa" },
                { id = 44796, name = "Trolling Them",                   npc = "Stellagosa" },
                { id = 44797, name = "Something's Not Quite Right...",  npc = "First Arcanist Thalyssra" },
                { id = 44861, name = "Arming the Rebels",               npc = "Silgryn" },  -- Alliance
                { id = 44862, name = "Arming the Rebels",               npc = "Silgryn" },  -- Horde
                { id = 44801, name = "Citizens' Army",                  npc = "Silgryn" },
                { id = 44802, name = "Learning From the Dead",          npc = "Silgryn" },
                { id = 44803, name = "We Need Weapons",                 npc = "Silgryn" },
                { id = 44790, name = "Trial by Demonfire",              npc = "Silgryn" },
            },
        },
        -- -----------------------------------------------------------------
        -- Sub-chapter 6: March on Suramar
        -- -----------------------------------------------------------------
        {
            chapter = "March on Suramar",
            summary = "Lead the allied armies through the streets of Suramar in a desperate push toward the Nighthold.",
            recap = "The allied armies — nightfallen, blood elves, night elves, and vrykul — marched through the streets of Suramar in a united front. You fought alongside Thalyssra at the vanguard, pushing through Elisande's desperate defenses block by block. The fighting was brutal, but the staging point was secured — the Nighthold was within reach.",
            criteriaQuest = { id = 44740, name = "Staging Point" },
            quests = {
                { id = 45266, name = "A United Front",                  npc = "First Arcanist Thalyssra" },
                { id = 44739, name = "Ready for Battle",                npc = "First Arcanist Thalyssra" },
                { id = 44738, name = "Full Might of the Elves",         npc = "First Arcanist Thalyssra" },
                { id = 44740, name = "Staging Point",                   npc = "First Arcanist Thalyssra" },
            },
        },
        -- -----------------------------------------------------------------
        -- Sub-chapter 7: Elisande's Retort
        -- -----------------------------------------------------------------
        {
            chapter = "Elisande's Retort",
            summary = "Face Grand Magistrix Elisande herself as she unleashes the power of the Nightwell against the rebellion.",
            recap = "Elisande struck back with the full power of the Nightwell, warping time itself to halt the rebellion's advance. You worked with Valtrois to investigate the temporal distortions, scouted breaches in the Nighthold's defenses, and uncovered how the Grand Magistrix channeled the Nightwell's energy through ancient seals. Breaking those seals would be the key to reaching her.",
            criteriaQuest = { id = 44833, name = "The Seal's Power" },
            quests = {
                { id = 45267, name = "Before the Siege",                npc = "First Arcanist Thalyssra" },
                { id = 44736, name = "Gates of the Nighthold",          npc = "First Arcanist Thalyssra" },
                { id = 44822, name = "Temporal Investigations",         npc = "Arcanist Valtrois" },
                { id = 45209, name = "Those Scrying Eyes",              npc = "Arcanist Valtrois" },
                { id = 44832, name = "Scouting the Breach",             npc = "Arcanist Valtrois" },
                { id = 44833, name = "The Seal's Power",                npc = "First Arcanist Thalyssra" },
            },
        },
        -- -----------------------------------------------------------------
        -- Sub-chapter 8: As Strong As Our Will
        -- -----------------------------------------------------------------
        {
            chapter = "As Strong As Our Will",
            summary = "Lady Liadrin and the blood elves of Silvermoon answer the call, joining the fight for their distant kin.",
            recap = "Elisande's forces captured and experimented on nightfallen prisoners, transforming them into felborne abominations. You stormed the Felsoul experiments alongside Kel'danath and Oculeth, freeing those who could still be saved and putting down those who could not. The horrors you witnessed only strengthened the resolve of every rebel who fought beside you.",
            criteriaQuest = { id = 45064, name = "Felborne No More" },
            quests = {
                { id = 45268, name = "The Advisor and the Arcanist",    npc = "First Arcanist Thalyssra" },
                { id = 44918, name = "A Message From Our Enemies",      npc = "First Arcanist Thalyssra" },
                { id = 44919, name = "A Challenge From Our Enemies",    npc = "First Arcanist Thalyssra" },
                { id = 45067, name = "Telemantic Expanse",              npc = "Chief Telemancer Oculeth" },
                { id = 45063, name = "The Felsoul Experiments",         npc = "Arcanist Kel'danath" },
                { id = 45065, name = "Survey the City",                 npc = "Chief Telemancer Oculeth" },
                { id = 45062, name = "Resisting Arrest",                npc = "Arcanist Kel'danath" },
                { id = 45066, name = "Experimental Instability",        npc = "Arcanist Kel'danath" },
                { id = 45064, name = "Felborne No More",                npc = "First Arcanist Thalyssra" },
            },
        },
        -- -----------------------------------------------------------------
        -- Sub-chapter 9: Breaking the Nighthold
        -- -----------------------------------------------------------------
        {
            chapter = "Breaking the Nighthold",
            summary = "The allied forces breach the Nighthold itself, confronting the source of Elisande's power.",
            recap = "The final breach. You entered the Nighthold itself, fighting through the last of Elisande's loyalists to reach the seat of her power. When the Grand Magistrix fell and the Nightwell's corrupting influence was severed, Thalyssra stepped forward to lead her people into a new era. The nightfallen were nightborne once more — free to choose their own fate.",
            criteriaQuest = { id = 44719, name = "Breaching the Sanctum" },
            quests = {
                { id = 45269, name = "A Taste of Freedom",              npc = "First Arcanist Thalyssra" },
                { id = 44964, name = "I'll Just Leave This Here",       npc = "Silgryn" },
                { id = 44719, name = "Breaching the Sanctum",           npc = "First Arcanist Thalyssra" },
                { id = 45417, name = "The Nighthold: Lord of the Shadow Council", npc = "First Arcanist Thalyssra" },
                { id = 45420, name = "The Nighthold: The Eye of Aman'Thul", npc = "First Arcanist Thalyssra" },
                { id = 45372, name = "Fate of the Nightborne",          npc = "First Arcanist Thalyssra" },
            },
        },
    },

    -- =========================================================================
    -- ACHIEVEMENT STRUCTURE SUMMARY
    -- =========================================================================
    -- Good Suramaritan (11124) tracks quest completions, not sub-achievement IDs.
    -- Each criterion is the final quest of its chapter (no standalone achievement IDs exist).
    --
    -- Insurrection (11340) criteria:
    --   1. Lockdown                -> Visitor in Shal'Aran    (44955)
    --   2. Missing Persons         -> Waning Refuge           (44814)
    --   3. Waxing Crescent         -> Sign of the Dusk Lily   (44756)
    --   4. An Elven Problem        -> Break An Arm            (44845)
    --   5. Crafting War            -> Trial by Demonfire      (44790)
    --   6. March on Suramar        -> Staging Point           (44740)
    --   7. Elisande's Retort       -> The Seal's Power        (44833)
    --   8. As Strong As Our Will   -> Felborne No More        (45064)
    --   9. Breaking the Nighthold  -> Breaching the Sanctum   (44719)
    --
    -- Pre-requisite chain (Nightfallen But Not Forgotten, 10617):
    --   Nightfall, Arcanist Kel'danath, Chief Telemancer Oculeth,
    --   Feeding Shal'Aran, Masquerade, The Light Below
}
