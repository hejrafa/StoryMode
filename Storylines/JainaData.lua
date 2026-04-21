local addonName, SM = ...

-- =============================================================================
-- Jaina Proudmoore: Daughter of the Sea
-- A saga set in Battle for Azeroth.
-- From the shores of a homeland that called her traitor to the admiral's seat
-- she was always meant to hold — the story of a woman finding her way home.
-- =============================================================================

SM.JainaData = {
    -- Questline metadata
    title = "Daughter of the Sea",
    description = "Jaina Proudmoore was once Theramore's defender and the Alliance's most celebrated mage. When the Horde dropped a mana bomb on her city, she emerged from the wreckage transformed — her hair turned white, her grief hardened into fury. She purged the Sunreavers from Dalaran. She watched old friendships fall away. When Battle for Azeroth began, she stood at the prow of the fleet that sailed on Lordaeron — not for diplomacy, but for war.\n\nThen came the summons home. Kul Tiras, her birthplace, wanted nothing to do with her. She had let her father die in Kalimdor — condemned to death by Night Elves and Horde alike, standing on the wrong side of a war she refused to fight. In the eyes of Katherine Proudmoore and the Admiralty, Jaina was a traitor. She arrived home in chains.\n\nWhat follows is an estrangement, a conspiracy, and an impossible reconciliation — and at the end of it, a song.",
    zone = "Kul Tiras",
    expansion = "Battle for Azeroth",
    achievements = {
        -- Kul Tiras zone story (chapters 1–3)
        12473,  -- A Sound Plan (Tiragarde Sound)
        12496,  -- Stormsong and Dance (Stormsong Valley)
        12497,  -- Drust Do It. (Drustvar)
        12593,  -- Loremaster of Kul Tiras
        -- The Pride of Kul Tiras — four dungeons
        12840,  -- Tol Dagor (Normal)
        12841,  -- Heroic: Tol Dagor
        12842,  -- Mythic: Tol Dagor
        12835,  -- Shrine of the Storm (Normal)
        12837,  -- Heroic: Shrine of the Storm
        12838,  -- Mythic: Shrine of the Storm
        12483,  -- Waycrest Manor (Normal)
        12484,  -- Heroic: Waycrest Manor
        12488,  -- Mythic: Waycrest Manor
        12847,  -- Siege of Boralus (Mythic)
        12812,  -- Glory of the Wartorn Hero (all four dungeons meta)
        -- The Fog of War — Battle of Dazar'alor (Alliance wings)
        13286,  -- Siege of Dazar'alor (Wing 1: Champion of the Light, Jadefire Masters, Grong)
        13287,  -- Empire's Fall (Wing 2: Opulence, Conclave of the Chosen, King Rastakhan)
        13288,  -- Might of the Alliance (Wing 3: Mekkatorque, Stormwall Blockade, Lady Jaina)
        13314,  -- Mythic: Lady Jaina Proudmoore (grants title: Hero of Dazar'alor)
        13322,  -- Ahead of the Curve: Lady Jaina Proudmoore
        13323,  -- Cutting Edge: Lady Jaina Proudmoore
        13315,  -- Glory of the Dazar'alor Raider
    },
    faction = "Alliance",
    color = { 0.20, 0.55, 0.85 },  -- Kul Tiran sea-blue
    portraitDisplayID = 87892,  -- Lady Jaina Proudmoore

    -- Start location: Captain Garrick in Stormwind Keep
    startQuest = { id = 57766, name = "War with the Horde", npc = "Captain Garrick", location = "Stormwind Keep, Stormwind" },
    startMapID = 84,   -- Stormwind City
    startX = 0.5220,
    startY = 0.3360,

    -- Key NPC locations for waypoint guidance (mapID, x, y)
    npcLocations = {
        -- Stormwind (intro)
        ["Captain Garrick"]          = { mapID = 84,   x = 0.5220, y = 0.3360 },
        -- Boralus
        ["Jaina Proudmoore"]         = { mapID = 1161, x = 0.5760, y = 0.3120 },
        ["Taelia"]                   = { mapID = 1161, x = 0.5600, y = 0.3460 },
        ["Cyrus Crestfall"]          = { mapID = 1161, x = 0.5800, y = 0.3050 },
        ["Flynn Fairwind"]           = { mapID = 1161, x = 0.4840, y = 0.5720 },
        ["Katherine Proudmoore"]     = { mapID = 1161, x = 0.4200, y = 0.2640 },
        ["Genn Greymane"]            = { mapID = 1161, x = 0.5200, y = 0.3800 },
        -- Tiragarde Sound (Enemies Within)
        ["Priscilla Ashvane"]        = { mapID = 895,  x = 0.4980, y = 0.5420 },
        -- Proudmoore Keep (Tides of Vengeance)
        ["Mathias Shaw"]             = { mapID = 1161, x = 0.4100, y = 0.2400 },
        ["Halford Wyrmbane"]         = { mapID = 1161, x = 0.5800, y = 0.3200 },
    },

    -- NPC creature display IDs for chapter portraits
    -- Verify unknowns: /run print(UnitCreatureDisplayID("target"))
    npcDisplayIDs = {
        ["Jaina Proudmoore"]         = 87892,
        ["Captain Garrick"]          = 92690,
        ["Taelia"]                   = 81291,
        ["Cyrus Crestfall"]          = 76907,
        ["Flynn Fairwind"]           = 83102,   -- (verify)
        ["Katherine Proudmoore"]     = 84654,   -- (verify)
        ["Genn Greymane"]            = 18202,   -- (verify)
        ["Priscilla Ashvane"]        = 84655,   -- (verify)
        ["Mathias Shaw"]             = 72253,
        ["Halford Wyrmbane"]         = 69317,   -- (verify)
    },
    chapterDisplayIDs = {
        ["A Nation Divided"]         = 92690,   -- Garrick (intro)
        ["Enemies Within"]           = 76907,   -- Crestfall
        ["The Pride of Kul Tiras"]   = 87892,   -- Jaina
        ["The Fog of War"]           = 72253,   -- Shaw
    },
    chapterIcons = {
        ["A Nation Divided"]         = 92690,
        ["Enemies Within"]           = 76907,
        ["The Pride of Kul Tiras"]   = 87892,
        ["The Fog of War"]           = 72253,
    },

    -- =========================================================================
    -- ACT I — A NATION DIVIDED (Battle for Azeroth 8.0.1 — Kul Tiras Intro)
    -- The Lord Admiral's daughter returns home as a political exile.
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: The exile arrives
        {
            chapter = "A Nation Divided",
            summary = "Jaina Proudmoore brings the Alliance to Kul Tiras — and is immediately arrested by her own mother's guards the moment she sets foot on the docks. Katherine Proudmoore, Lord Admiral in her daughter's absence, has not forgiven Jaina for the death of her father Daelin. Jaina is imprisoned in Tol Dagor. You break out with the help of a disgraced sailor named Flynn Fairwind, surface in a Kul Tiras rebuilding itself from the inside out, and learn that three zones of unrest must be addressed before Kul Tiras will trust the Alliance — or her.",
            recap = "Jaina brought you to Kul Tiras aboard the Alliance fleet, and the moment she stepped off the ship she was surrounded by Proudmoore Guard acting on Katherine's orders. Her own mother had her arrested for treason. You were thrown in Tol Dagor prison alongside her — until Flynn Fairwind, a sailor with nothing to lose and excellent lock-picking instincts, got you both out. Cyrus Crestfall and the 7th Legion met you on the outside. The road to earning Kul Tiras back for the Alliance runs through three zones — and through a rift between mother and daughter that has been open for years.",
            quests = {
                { id = 57766, name = "War with the Horde",                    npc = "Captain Garrick" },
                { id = 46727, name = "Battle for Azeroth: Tides of War",      npc = "Captain Garrick" },
                { id = 46728, name = "The Nation of Kul Tiras",               npc = "Captain Garrick" },
                { id = 51341, name = "Daughter of the Sea",                   npc = "Jaina Proudmoore" },
                { id = 47098, name = "Out Like Flynn",                        npc = "Flynn Fairwind" },
                { id = 47099, name = "Get Your Bearings",                     npc = "Taelia" },
                { id = 46729, name = "The Old Knight",                        npc = "Cyrus Crestfall" },
                { id = 47186, name = "Sanctum of the Sages",                  npc = "Cyrus Crestfall" },
                { id = 47189, name = "A Nation Divided",                      npc = "Taelia" },
            },
        },

        -- =====================================================================
        -- ACT II — ENEMIES WITHIN (Tiragarde Sound)
        -- Priscilla Ashvane's conspiracy to destroy the Proudmoore name.
        -- =====================================================================

        -- CHAPTER 2: The conspiracy
        {
            chapter = "Enemies Within",
            note = "Requires completing the Tiragarde Sound main storyline (\"Trouble in Tiragarde Sound\"). Begin with the Ashvane Trading Company investigation in Boralus.",
            summary = "Priscilla Ashvane has been quietly dismantling the Proudmoore Admiralty from within — bribing officials, sabotaging trade, and positioning herself to absorb the family's political legacy while Katherine grieves her son Derek and her estrangement from Jaina. Unraveling the conspiracy takes you across Tiragarde Sound, from Boralus's counting houses to Ashvane prison cells, until the truth lands at Genn Greymane's feet in Boralus Harbor.",
            recap = "Tiragarde Sound was rotting at its foundations. Priscilla Ashvane and the Ashvane Trading Company had corrupted the Admiralty's supply lines, bribed its officers, and turned institutional loyalty into a private racket — all while Katherine Proudmoore remained in the dark, managing the public appearances of a nation that was quietly being hollowed out beneath her. You dismantled the operation piece by piece, surfacing the evidence until the case against Ashvane was undeniable. Katherine met with Genn Greymane in Boralus Harbor. She still had not spoken to Jaina.",
            quests = {
                { id = 50795, name = "Prepare for Trouble",    npc = "Taelia" },
                { id = 50787, name = "Make Our Case",          npc = "Taelia" },
                { id = 50788, name = "Enemies Within",         npc = "Taelia" },
                { id = 50789, name = "Clear the Air",          npc = "Taelia" },
                { id = 50790, name = "Hot Pursuit",            npc = "Taelia" },
                { id = 50972, name = "Proudmoore's Parley",    npc = "Katherine Proudmoore" },
            },
        },

        -- =====================================================================
        -- ACT III — THE PRIDE OF KUL TIRAS (Battle for Azeroth 8.0.1)
        -- To earn the fleet, four keys must be recovered from across the nation.
        -- Then a mother and daughter must face each other.
        -- =====================================================================

        -- CHAPTER 3: The lost fleet
        {
            chapter = "The Pride of Kul Tiras",
            note = "Requires completing all three Kul Tiras zone storylines (Tiragarde Sound, Drustvar, and Stormsong Valley). Speak to Cyrus Crestfall in Boralus to begin. This chapter includes four dungeon quests: Tol Dagor, Shrine of the Storm, Waycrest Manor, and Siege of Boralus.",
            summary = "The Kul Tiran fleet — decades of Proudmoore naval heritage — is scattered and locked behind four keys held by enemies who have taken root across the nation: pirates in Freehold, corrupt wardens in Tol Dagor, drowned tidesages in the Shrine of the Storm, and Drust witches in Waycrest Manor. The keys must be taken by force. At the end, Priscilla Ashvane makes one final move — and Jaina faces her mother in a square in Boralus, in front of the entire fleet, for the first time since Theramore fell.",
            recap = "Four dungeons. Four keys. Sweete the pirate queen, the tidesage Zul'gurub, the witch Gorak Tul — all of them fell. The Kul Tiran fleet, locked away by enemies and time and a nation that had stopped believing in itself, was free again. Then came the Siege of Boralus: Priscilla Ashvane, revealed as the architect of Kul Tiras's rot, made her last stand in the harbor. She fell too.\n\nIn Unity Square, Katherine Proudmoore stood before her daughter for the first time in years. She spoke the words no one had expected her to say: she stepped aside. She named Jaina Lord Admiral. She called her back — not as a Kul Tiran returning home, but as the heir to a seat her mother had been keeping warm. The fleet sailed. The song that Jaina's father had sung to her as a child played across the harbor.",
            quests = {
                { id = 52194, name = "What You May Regret",                          npc = "Cyrus Crestfall" },
                { id = 52246, name = "Lost Shipment",                                npc = "Taelia" },
                { id = 52762, name = "A Local Guide",                                npc = "Taelia" },
                { id = 52252, name = "An Explosive Entrance",                        npc = "Flynn Fairwind" },
                { id = 52253, name = "The Keys to Success in Freehold",              npc = "Flynn Fairwind" },
                { id = 52311, name = "Sweete's Strongbox",                           npc = "Flynn Fairwind" },
                { id = 52445, name = "Tol Dagor: The Fourth Key",                    npc = "Taelia", optional = true },
                { id = 52449, name = "The Mysterious Island",                        npc = "Taelia" },
                { id = 52453, name = "A Forlorn Hope",                               npc = "Taelia" },
                { id = 52508, name = "Ritual Effects",                               npc = "Cyrus Crestfall" },
                { id = 52509, name = "The Strength of the Storm",                    npc = "Cyrus Crestfall" },
                { id = 52510, name = "Shrine of the Storm: The Missing Ritual",      npc = "Cyrus Crestfall", optional = true },
                { id = 52511, name = "Opening the Way",                              npc = "Cyrus Crestfall" },
                { id = 52512, name = "Fate's End",                                   npc = "Cyrus Crestfall" },
                { id = 52513, name = "Lost in Darkness",                             npc = "Cyrus Crestfall" },
                { id = 52481, name = "Of Myth and Fable",                            npc = "Taelia" },
                { id = 52482, name = "The Old Bear",                                 npc = "Taelia" },
                { id = 52483, name = "Nightmare Catcher",                            npc = "Taelia" },
                { id = 52484, name = "Buried Power",                                 npc = "Taelia" },
                { id = 52485, name = "Hatred's Focus",                               npc = "Taelia" },
                { id = 52486, name = "Waycrest Manor: Draining the Heartsbane",      npc = "Taelia", optional = true },
                { id = 52487, name = "Into Darkness",                                npc = "Taelia" },
                { id = 52488, name = "Runic Resistance",                             npc = "Taelia" },
                { id = 51445, name = "Thros, the Blighted Lands",                    npc = "Taelia" },
                -- Siege of Boralus: Lady Ashvane's Return (dungeon — ID needs in-game verification)
                { id = 52151, name = "A Nation United",                              npc = "Jaina Proudmoore" },
            },
        },

        -- =====================================================================
        -- ACT IV — THE FOG OF WAR (Battle for Azeroth 8.1 — Tides of Vengeance)
        -- The Lord Admiral of Kul Tiras goes to war.
        -- =====================================================================

        -- CHAPTER 4: The Zuldazar assault
        {
            chapter = "The Fog of War",
            note = "Complete the Kul Tiras intro and War Campaign chapters to unlock, then speak with Mathias Shaw in Proudmoore Keep.",
            summary = "Jaina Proudmoore, now Lord Admiral, turns the Kul Tiran fleet against the Zandalari Empire. The plan: draw the Horde's forces deep into Nazmir with the Abyssal Scepter while the Alliance fleet strikes Zuldazar harbor from the south. Jaina personally freezes the harbor, and the Battle of Dazar'alor begins.",
            recap = "Mathias Shaw laid out the strategy in Proudmoore Keep: use the Abyssal Scepter to create a false assault on Nazmir and lure the Horde fleet away from Zuldazar. While Zandalari forces rushed south to repel the distraction, the Alliance fleet would hit the harbor directly. You spent two weeks fighting through Nazmir swamps, disabling Zandalari machinery, and holding the line at the Blood Gate — long enough for the fleet to round the coast.\n\nThen Jaina froze the harbor. The water turned to ice beneath Zandalari hulls. The Alliance sailed straight through. The Battle of Dazar'alor — the most audacious naval assault in a generation — had begun. Lord Admiral Jaina Proudmoore, fighting in her own waters, had brought the war home.",
            quests = {
                { id = 54302, name = "The Fall of Zuldazar",      npc = "Mathias Shaw" },
                { id = 54303, name = "The March to Nazmir",       npc = "Halford Wyrmbane" },
                { id = 54310, name = "Repurposing Their Village", npc = "Halford Wyrmbane" },
                { id = 54404, name = "Dark Iron Machinations",    npc = "Halford Wyrmbane" },
                { id = 54312, name = "Fog of War",                npc = "Halford Wyrmbane" },
                { id = 54407, name = "Lurking in the Swamp",      npc = "Halford Wyrmbane" },
                { id = 54412, name = "Zul'jan Deluge",            npc = "Halford Wyrmbane" },
                { id = 54418, name = "The Mech of Death",         npc = "Halford Wyrmbane" },
                { id = 54417, name = "Showing Our Might",         npc = "Halford Wyrmbane" },
                { id = 54421, name = "Taming their Beasts",       npc = "Halford Wyrmbane" },
                { id = 54441, name = "Taking the Blood Gate",     npc = "Halford Wyrmbane" },
                { id = 54459, name = "He Who Walks in the Light", npc = "Halford Wyrmbane" },
            },
        },
    },
}
