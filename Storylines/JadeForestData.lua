local addonName, SM = ...

-- =============================================================================
-- Mists of Pandaria: The Jade Forest
-- Zone Storyline: "Upjade Complete" (Achievement 6300)
-- =============================================================================

SM.JadeForestData = {
    title = "The Jade Forest",
    achievementID = 6300,
    achievements = {
        6300,   -- Upjade Complete (zone story — 15 questlines)
        6351,   -- Explore Jade Forest
    },
    description = "Two armadas arrived in Pandaria within hours of each other — and started fighting before they learned the land's name. The Jade Forest had no context for war. It had monks, jade serpents, ancient frescoes, and a ten-thousand-year rebuilding project that both armies would take one afternoon to undo. The sha that emerged was called Doubt. It came from us.",
    zone = "The Jade Forest",
    expansion = "Mists of Pandaria",
    color = { 0.22, 0.62, 0.32 },   -- jade green

    icon = 617824,

    -- Alliance start (Stormwind breadcrumb); Horde equivalent: 29612 "The Art of War" (Orgrimmar)
    startQuest = { id = 29547, name = "The King's Command", npc = "King Varian Wrynn", location = "Stormwind" },
    startMapID = 371,   -- TODO: verify Jade Forest uiMapID in-game
    startX = 0.2800,
    startY = 0.8200,

    npcLocations = {
        ["Admiral Taylor"]      = { mapID = 371, x = 0.2750, y = 0.8000 },  -- Paw'don Village coast
        ["General Nazgrim"]     = { mapID = 371, x = 0.3200, y = 0.3200 },  -- Strongarm Airstrip
        ["Lorewalker Cho"]      = { mapID = 371, x = 0.5500, y = 0.5500 },  -- Serpent's Overlook / Dawn's Blossom
        ["Anduin Wrynn"]        = { mapID = 371, x = 0.6200, y = 0.4800 },  -- Pearlfin area / temple
        ["Fei"]                 = { mapID = 371, x = 0.7800, y = 0.3600 },  -- Temple of the Jade Serpent
    },

    npcDisplayIDs = {
        ["King Varian Wrynn"]   = 28127,
        ["General Nazgrim"]     = 42562,
        ["Admiral Taylor"]      = 39036,
        ["Shademaster Kiryn"]   = 39039,
        ["Lorewalker Cho"]      = 127838,
        ["Anduin Wrynn"]        = 0,  -- TODO: verify
        ["Fei"]                 = 42383,
    },

    -- portraitDisplayID intentionally omitted so data.icon (617824) is used on the card

    -- =========================================================================
    -- Main storyline chapters
    -- =========================================================================
    chapters = {

        -- CHAPTER 1: Into the Mists
        {
            chapter = "Into the Mists",
            summary = "Two armadas arrive in Pandaria. Neither knocks.",
            recap = "The Alliance fleet bombarded a Horde convoy in the seas east of Pandaria, and both went down in the mists together. You washed up on the shore of the Jade Forest — a land of impossible green, silk-heavy air, and a silence both armies immediately set about destroying. Twinspire Keep's Horde garrison fell to Alliance assault. Ships burned on the coast. A Horde gunship crewed by screaming hozen hit the treeline. The pandaren who watched from the hills had no context for what they were seeing. They would, soon enough.",
            quests = {
                -- Alliance
                { id = 29547, name = "The King's Command",              npc = "King Varian Wrynn",     faction = "Alliance" },
                { id = 29548, name = "The Mission",                     npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 31732, name = "Unleash Hell",                    npc = "Sky Admiral Rogers",    faction = "Alliance" },
                { id = 31733, name = "Touching Ground",                 npc = "Sky Admiral Rogers",    faction = "Alliance" },
                { id = 30069, name = "No Plan Survives Contact with the Enemy", npc = "Admiral Taylor", faction = "Alliance" },
                { id = 31734, name = "Welcome Wagons",                  npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 31735, name = "The Right Tool For The Job",      npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 31736, name = "Envoy of the Alliance",           npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 31737, name = "The Cost of War",                 npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 31738, name = "Pillaging Peons",                 npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 29552, name = "Critical Condition",              npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 31739, name = "Priorities!",                     npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 31740, name = "Koukou's Rampage",                npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 31741, name = "Twinspire Keep",                  npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 31742, name = "Fractured Forces",                npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 31743, name = "Smoke Before Fire",               npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 31744, name = "Unfair Trade",                    npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 30070, name = "The Fall of Ga'trul",             npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 31745, name = "Onward and Inward",               npc = "Admiral Taylor",        faction = "Alliance" },
                -- Horde
                { id = 29612, name = "The Art of War",                  npc = "General Nazgrim",       faction = "Horde" },
                { id = 31853, name = "All Aboard!",                     npc = "General Nazgrim",       faction = "Horde" },
                { id = 29690, name = "Into the Mists",                  npc = "General Nazgrim",       faction = "Horde" },
                { id = 31765, name = "Paint it Red!",                   npc = "General Nazgrim",       faction = "Horde" },
                { id = 31766, name = "Touching Ground",                 npc = "General Nazgrim",       faction = "Horde" },
                { id = 31767, name = "Finish Them!",                    npc = "General Nazgrim",       faction = "Horde" },
                { id = 31768, name = "Fire Is Always the Answer",       npc = "General Nazgrim",       faction = "Horde" },
                { id = 31769, name = "The Final Blow!",                 npc = "General Nazgrim",       faction = "Horde" },
                { id = 31770, name = "You're Either With Us Or...",     npc = "General Nazgrim",       faction = "Horde" },
                { id = 29694, name = "Regroup!",                        npc = "General Nazgrim",       faction = "Horde" },
                { id = 31771, name = "Face to Face With Consequence",   npc = "General Nazgrim",       faction = "Horde" },
                { id = 31773, name = "Prowler Problems",                npc = "Shademaster Kiryn",     faction = "Horde" },
            },
        },

        -- CHAPTER 2: Allies of the Forest
        {
            chapter = "Allies of the Forest",
            summary = "The Pearlfin listen to the water. The Hozen listen to no one.",
            recap = "The Alliance tracked Anduin's SI:7 escort through the forest and made contact with the Pearlfin Jinyu — river people, cool and watchful, who had their own reasons to want the Horde gone. They spoke through the water and through ceremony. It took time the Alliance barely had.\n\nThe Horde had less ceremony and more chaos. Nazgrim's forces were scattered across the wreckage of Hellscream's Fist. The Hozen — fur-covered, loud, and allergic to tactics — were recruited with the kind of optimism that comes from having no other options. Zin'jun the troll had been captured. The airstrip needed holding. Pandaria regarded all of this with the patient indifference of a very old land.",
            quests = {
                -- Alliance: SI:7 search and Pearlfin alliance
                { id = 29733, name = "SI:7 Report: Lost in the Woods",  npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 29725, name = "SI:7 Report: Fire From the Sky",  npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 29726, name = "SI:7 Report: Hostile Natives",    npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 29727, name = "SI:7 Report: Take No Prisoners",  npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 29894, name = "The Waterspeaking Ceremony",      npc = "Tojara",                faction = "Alliance" },
                { id = 29906, name = "Carp Diem",                       npc = "Tojara",                faction = "Alliance" },
                -- Horde: regrouping and Hozen
                { id = 31774, name = "Seeking Zin'jun",                 npc = "Shademaster Kiryn",     faction = "Horde" },
                { id = 29765, name = "Cryin' My Eyes Out",              npc = "Shademaster Kiryn",     faction = "Horde" },
                { id = 29804, name = "Seein' Red",                      npc = "Shademaster Kiryn",     faction = "Horde" },
                { id = 31775, name = "Assault on the Airstrip",         npc = "General Nazgrim",       faction = "Horde" },
                { id = 31776, name = "Strongarm Tactics",               npc = "General Nazgrim",       faction = "Horde" },
                { id = 31777, name = "Choppertunity",                   npc = "General Nazgrim",       faction = "Horde" },
                { id = 31778, name = "Unreliable Allies",               npc = "General Nazgrim",       faction = "Horde" },
                { id = 31779, name = "The Darkness Within",             npc = "General Nazgrim",       faction = "Horde" },
            },
        },

        -- CHAPTER 3: What Pandaria Teaches
        {
            chapter = "What Pandaria Teaches",
            summary = "Lorewalker Cho has a story for everything. He is not wrong.",
            recap = "Lorewalker Cho — archivist, historian, and perhaps the most patient man in Pandaria — had been watching both armies arrive with a composed expression that must have cost him something. The village of Dawn's Blossom, the Tian Monastery training grounds, the orchards at Nectarbreeze, the ancient quarries and the windswept Terrace of Ten Thunders: all of it was here before either faction existed, and all of it was still being tended by people who had no army and no interest in acquiring one.\n\nCho guided you through it. He told you about silk, about jade, about the disciplines practiced at the monastery by monks who chose the difficulty of inner peace over the easier difficulty of fighting. Whether either faction absorbed any of this is a separate question.",
            quests = {
                { id = 29922, name = "In Search of Wisdom",             npc = "Lorewalker Cho" },
                { id = 30015, name = "Dawn's Blossom",                  npc = "Lorewalker Cho" },
                { id = 31230, name = "Welcome to Dawn's Blossom",       npc = "Lorewalker Cho" },
                { id = 29881, name = "The Perfect Color",               npc = "Lorewalker Cho" },
                { id = 29882, name = "Quill of Stingers",               npc = "Lorewalker Cho" },
                { id = 29993, name = "Find the Boy",                    npc = "Lorewalker Cho" },
                { id = 29866, name = "The Threads that Stick",          npc = "Lorewalker Cho" },
                { id = 29865, name = "The Silkwood Road",               npc = "Lorewalker Cho" },
                { id = 29995, name = "Shrine of the Dawn",              npc = "Lorewalker Cho" },
                { id = 29920, name = "Getting Permission",              npc = "Lorewalker Cho" },
                { id = 29637, name = "The Rumpus",                      npc = "Master Bruised Paw" },
                { id = 29646, name = "Flying Colors",                   npc = "Master Bruised Paw" },
                { id = 29647, name = "Flying Colors",                   npc = "Master Bruised Paw" },
                { id = 29578, name = "Defiance",                        npc = "Master Bruised Paw" },
                { id = 29670, name = "Nectarbreeze Orchard",            npc = "Lorewalker Cho" },
                { id = 29755, name = "Terrace of Ten Thunders",         npc = "Lorewalker Cho" },
                { id = 29930, name = "Greenstone Quarry",               npc = "Lorewalker Cho" },
            },
        },

        -- CHAPTER 4: The White Pawn
        {
            chapter = "The White Pawn",
            summary = "Anduin chose to trust Pandaria. He wasn't wrong about that.",
            recap = "Prince Anduin Wrynn had not been captured — he had been learning. While SI:7 searched the forest and Admiral Taylor worried, Anduin had found Lorewalker Cho, the Pearlfin Jinyu elders, a view of the Jade Serpent's temple under reconstruction, and something he needed more than a rescue: a purpose. His decision was to approach Yu'lon's rebirth with reverence, not politics. To ask instead of take.\n\nAnduin's Decision was the chapter's name and its contents. He was a boy who had seen enough of war to know it was not the only answer, and young enough to still believe that. Admiral Taylor disapproved. Taran Zhu was watching. The Jade Serpent listened. You found Anduin safe, changed, and entirely unwilling to be treated as a problem that needed solving.",
            quests = {
                { id = 29888, name = "Seek Out the Lorewalker",         npc = "Admiral Taylor",        faction = "Alliance" },
                { id = 29903, name = "A Perfect Match",                 npc = "Lorewalker Cho",        faction = "Alliance" },
                { id = 29889, name = "Borrowed Brew",                   npc = "Lorewalker Cho",        faction = "Alliance" },
                { id = 31130, name = "A Visit with Lorewalker Cho",     npc = "Lorewalker Cho",        faction = "Alliance" },
                { id = 29891, name = "Potency",                         npc = "Lorewalker Cho",        faction = "Alliance" },
                { id = 29892, name = "Body",                            npc = "Lorewalker Cho",        faction = "Alliance" },
                { id = 29893, name = "Hue",                             npc = "Lorewalker Cho",        faction = "Alliance" },
                { id = 29890, name = "Finding Your Center",             npc = "Lorewalker Cho",        faction = "Alliance" },
                { id = 29898, name = "Sacred Waters",                   npc = "Anduin Wrynn",          faction = "Alliance" },
                { id = 29899, name = "Rest in Peace",                   npc = "Anduin Wrynn",          faction = "Alliance" },
                { id = 29900, name = "An Ancient Legend",               npc = "Anduin Wrynn",          faction = "Alliance" },
                { id = 29901, name = "Anduin's Decision",               npc = "Anduin Wrynn",          faction = "Alliance" },
                { id = 29904, name = "Bigger Fish to Fry",              npc = "Anduin Wrynn",          faction = "Alliance" },
                { id = 29905, name = "Let Them Burn",                   npc = "Anduin Wrynn",          faction = "Alliance" },
            },
        },

        -- CHAPTER 5: What We Have Wrought
        {
            chapter = "What We Have Wrought",
            summary = "The Jade Serpent statue had been rebuilt for ten thousand years. It took one afternoon to unmake.",
            recap = "The faction war came to the Jade Serpent statue — an enormous monument that pandaren artisans had spent ten thousand years restoring so that Yu'lon could be reborn. Both armies pushed forward. Doubt, hatred, pride: all the emotions carried here from another continent fed the Sha of Doubt, and it broke free at the worst possible moment. The statue shattered. Yu'lon's rebirth was undone in an instant. Lorewalker Cho stood in the rubble and said nothing. Both factions had done this.\n\nA small pandaren girl named Fei led you into the Temple of the Jade Serpent. Not to atone — atonement is a longer story — but to face what you'd caused and keep moving. You sealed the sha fissures feeding the great doubt, rescued your companions from the ruins, and watched Yu'lon be reborn smaller, frailer, a shadow of what she should have been. Fei told you to go to the Valley of the Four Winds. She seemed to think you were still worth something. It was unclear whether she was right.",
            quests = {
                { id = 30000, name = "The Jade Serpent",                npc = "Fei" },
                { id = 31362, name = "Last Piece of the Puzzle",        npc = "Lorewalker Cho" },
                { id = 31303, name = "The Seal is Broken",              npc = "Lorewalker Cho" },
                { id = 30500, name = "Residual Fallout",                npc = "Lorewalker Cho" },
                { id = 30502, name = "Jaded Heart",                     npc = "Lorewalker Cho" },
                { id = 31319, name = "Emergency Response",              npc = "Lorewalker Cho" },
                { id = 30648, name = "Moving On",                       npc = "Fei" },
            },
        },
    },
}

return SM
