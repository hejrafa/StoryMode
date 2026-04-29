local addonName, SM = ...

-- =============================================================================
-- Mists of Pandaria: Dread Wastes — The Klaxxi
-- Zone Storyline: "Dread Haste Makes Dread Waste" (Achievement 6540)
-- =============================================================================

SM.DreadWastesData = {
    title = "The Klaxxi",
    achievementID = 6540,
    achievements = {
        6540,   -- Dread Haste Makes Dread Waste (zone story — 4 questlines)
        "Explore Dread Wastes",
        6545,   -- Klaxxi (Exalted with The Klaxxi)
        "Stay Klaxxi",
        "Amber Is the Color of My Energy",
    },
    description = "The mantid are ancient and alien: older than the mogu, older than written history, and bound to traditions outsiders barely understand. In the Dread Wastes, something has gone wrong inside the swarm, and even the Klaxxi have begun to move against their own Empress.\n\nThey name you a Wakener, an outsider trusted to free legendary paragons from amber and help steady a civilization that sees war, loyalty, and destiny very differently than the rest of Pandaria.",
    zone = "Dread Wastes",
    expansion = "Mists of Pandaria",
    color = { 0.72, 0.53, 0.15 },   -- amber/ochre

    icon = 624970,
    factions = { 1337, 1302 }, -- The Klaxxi, The Anglers
    adventureGuideInstanceName = "Heart of Fear",

    startQuest = { id = 31001, name = "Falling Down", npc = "Bowmistress Li", location = "Serpent's Spine" },
    startMapID = 422,
    startX = 0.7500,
    startY = 0.2120,

    npcLocations = {
        ["Bowmistress Li"]          = { mapID = 422, x = 0.7500, y = 0.2120 },  -- Serpent's Spine
        ["Shado-Pan Scout"]         = { mapID = 422, x = 0.7500, y = 0.2120 },  -- fallback alias for the wall camp
        ["Marksman Lann"]           = { mapID = 422, x = 0.7260, y = 0.2860 },  -- Terrace of Gurthan
        ["Klaxxi'va Tik"]           = { mapID = 422, x = 0.7260, y = 0.2860 },  -- cave beside Marksman Lann
        ["Ambersmith Zikk"]         = { mapID = 422, x = 0.5500, y = 0.3540 },  -- Klaxxi'vess
        ["Kil'ruk the Wind-Reaver"] = { mapID = 422, x = 0.5500, y = 0.3580 },  -- Klaxxi'vess
        ["Kor'ik"]                  = { mapID = 422, x = 0.5480, y = 0.3400 },  -- Klaxxi'vess
        ["Malik the Unscathed"]     = { mapID = 422, x = 0.5500, y = 0.3540 },  -- Klaxxi'vess
        ["Sapmaster Vu"]            = { mapID = 422, x = 0.5120, y = 0.1140 },  -- Sunset Brewgarden
        ["Lya of Ten Songs"]        = { mapID = 422, x = 0.5060, y = 0.1180 },  -- Sunset Brewgarden
        ["Olon"]                    = { mapID = 422, x = 0.5100, y = 0.1120 },  -- Sunset Brewgarden
        ["Thirsty Missho"]          = { mapID = 422, x = 0.5100, y = 0.1120 },  -- Sunset Brewgarden
        ["Chen Stormstout"]         = { mapID = 422, x = 0.5040, y = 0.1200 },  -- Sunset Brewgarden
        ["Defender Azzo"]           = { mapID = 422, x = 0.5020, y = 0.1240 },  -- Sunset Brewgarden
        ["Chief Rikkitun"]          = { mapID = 422, x = 0.3860, y = 0.1720 },  -- Rikkitun Village
        ["Boggeo"]                  = { mapID = 422, x = 0.3820, y = 0.1720 },  -- Rikkitun Village
        ["Deck Boss Arie"]          = { mapID = 422, x = 0.5480, y = 0.7220 },  -- Soggy's Gamble
        ["Captain \"Soggy\" Su-Dao"] = { mapID = 422, x = 0.5480, y = 0.7220 },  -- Soggy's Gamble
        ["Ka'roz the Locust"]       = { mapID = 422, x = 0.5480, y = 0.7220 },  -- awakened after Mazu's Bounty
        ["Kaz'tik the Manipulator"] = { mapID = 422, x = 0.4340, y = 0.6340 },
    },

    npcDisplayIDs = {
        ["Bowmistress Li"]          = 42354,
        ["Shado-Pan Scout"]         = 42080,
        ["Ambersmith Zikk"]         = 43587,
        ["Kor'ik"]                  = 43630,
        ["Malik the Unscathed"]     = 43976,
        ["Sapmaster Vu"]            = 42613,
        ["Lya of Ten Songs"]        = 42614,
        ["Olon"]                    = 42615,
        ["Thirsty Missho"]          = 42748,
        ["Chen Stormstout"]         = 39698,
        ["Defender Azzo"]           = 42903,
        ["Chief Rikkitun"]          = 42522,
        ["Boggeo"]                  = 42778,
        ["Deck Boss Arie"]          = 42976,
        ["Captain \"Soggy\" Su-Dao"] = 42935,
        ["Kil'ruk the Wind-Reaver"] = 42539,
        ["Ka'roz the Locust"]       = 43466,
        ["Kaz'tik the Manipulator"] = 42801,
    },

    chapterDisplayIDs = {
        ["The First Paragons"]       = 42354, -- Bowmistress Li
        ["Taste of Amber"]           = 42613, -- Sapmaster Vu
        ["Like a Deck Boss"]         = 42976, -- Deck Boss Arie
    },

    portraitDisplayID = 43587,  -- Ambersmith Zikk (TODO: swap for Kil'ruk once ID is known)

    -- =========================================================================
    -- Main storyline chapters (4 achievement questlines + epilogue, with the
    -- amber harvest split off from Sapmaster Vu's brewgarden arc)
    -- =========================================================================
    chapters = {

        -- CHAPTER 1: The First Paragons
        {
            chapter = "The First Paragons",
            gated = true,
            summary = "A wall stands between Pandaria and the mantid swarm. It just cracked open.",
            note = "Begin with Bowmistress Li on top of the Serpent's Spine. If she is missing or phases out, speak with Zidormi near the Seat of Knowledge in the Vale of Eternal Blossoms and switch the Vale to the pre-N'Zoth assault timeline.",
            recap = "The Shado-Pan had held the Serpent's Spine against the mantid for centuries, but when you arrived, the swarm had already turned on itself. Grand Empress Shek'zeer had been touched by sha energy, and the corruption was spreading. You fell from the wall into the Dread Wastes and survived by luck and stubbornness. The Klaxxi, the mantid council of elders, had been watching. They named you a Wakener — a rare outsider trusted to free their greatest warriors from amber prisons.\n\nAt Klaxxi'vess, the heart of the Klaxxi, you stood before paragons who had been preserved in amber for decades. Kil'ruk the Wind-Reaver regarded you with the cool assessment of someone who had fought wars before your grandparents were born. You proved your worth. The first paragons were free, and the Klaxxi's war against the Empress had begun in earnest.",
            quests = {
                { id = 31001, name = "Falling Down",                npc = "Bowmistress Li" },
                { id = 31002, name = "Nope",                        npc = "Bowmistress Li" },
                { id = 31003, name = "Psycho Mantid",               npc = "Marksman Lann" },
                { id = 31004, name = "Preserved in Amber",          npc = "Klaxxi'va Tik" },
                { id = 31005, name = "Wakening Sickness",           npc = "Kil'ruk the Wind-Reaver" },
                { id = 31676, name = "Ancient Vengeance",           npc = "Kil'ruk the Wind-Reaver" },
                { id = 31006, name = "The Klaxxi Council",          npc = "Kil'ruk the Wind-Reaver" },
                { id = 31007, name = "The Dread Clutches",          npc = "Kil'ruk the Wind-Reaver" },
                { id = 31660, name = "Not Fit to Swarm",            npc = "Kil'ruk the Wind-Reaver" },
                { id = 31009, name = "Dead Zone",                   npc = "Kor'ik" },
                { id = 31008, name = "Amber Arms",                  npc = "Ambersmith Zikk" },
                { id = 31661, name = "A Source of Terrifying Power", npc = "Ambersmith Zikk" },
                { id = 31010, name = "In Her Clutch",               npc = "Ambersmith Zikk" },
                { id = 31689, name = "The Dreadsworn",              npc = "Malik the Unscathed" },
                { id = 31108, name = "Concentrated Fear",           npc = "Ambersmith Zikk" },
                { id = 31107, name = "Citizens of a New Empire",    npc = "Malik the Unscathed" },
                { id = 31066, name = "A Cry From Darkness",         npc = "Kor'ik" },
            },
        },

        -- CHAPTER 2: The Root of the Problem
        {
            chapter = "The Root of the Problem",
            summary = "Amber is the lifeblood of the Klaxxi. Kypari Zar is sick.",
            recap = "The paragons needed weapons worthy of war, and amber was their craft. Ambersmith Zikk sent you out into the groves of Klaxxi'vess — to harvest, to feed the beasts that kept the trees fertile, to coax living amber from the roots and bring it back unbroken.\n\nKypari Zar, the sacred tree at the heart of the harvest, had begun to fail. Korven the Prime walked the ruins by the lakeside with you and traced the corruption all the way down to the root. The rot was contained, the amber kept flowing, and the harvest held. Zikk turned your attention north — to a recipe, and to an old brewer who had been waiting longer than anyone realized.",
            quests = {
                { id = 31019, name = "Amber Is Life",               npc = "Kil'ruk the Wind-Reaver" },
                { id = 31020, name = "Feeding the Beast",           npc = "Ambersmith Zikk" },
                { id = 31021, name = "Living Amber",                npc = "Ambersmith Zikk" },
                { id = 31022, name = "Kypari Zar",                  npc = "Korven the Prime" },
                { id = 31026, name = "The Root of the Problem",     npc = "Korven the Prime" },
            },
        },

        -- CHAPTER 3: Taste of Amber
        {
            chapter = "Taste of Amber",
            summary = "Sapmaster Vu's brewgarden is hiding more than a recipe. The Stormstouts have come looking for their own.",
            recap = "North of the amber groves, Sapmaster Vu's Sunset Brewgarden sat at the edge of the wastes — pandaren brewers who had taken root here long before the mantid woke. The recipe Lya of Ten Songs deciphered split your work in two threads run in parallel: forge daggers of the great ones with Olon, and brew a salvation strong enough to drown an old fear. You gathered shade, wood, fang, and corewood for both at once.\n\nChen Stormstout crossed your path searching for his family. You stood beside him at one small grave, then another. First Evie. Then Han. There would be time to mourn later. You bound the glamour with Chief Rikkitun, faced Iyyokuk's old fires, and finished the recipe with a chunk of amber pried from the Heart of Fear itself. Lya tasted the brew. The work was done.",
            quests = {
                { id = 31067, name = "The Heavens Hum With War",    npc = "Sapmaster Vu" },
                { id = 31068, name = "Sacred Recipe",               npc = "Lya of Ten Songs" },
                { id = 31076, name = "Fate of the Stormstouts",     npc = "Chen Stormstout", optional = true },
                { id = 31077, name = "Evie Stormstout",             npc = "Chen Stormstout" },
                { id = 31078, name = "Han Stormstout",              npc = "Chen Stormstout" },
                { id = 31069, name = "Bound With Shade",            npc = "Sapmaster Vu" },
                { id = 31070, name = "Daggers of the Great Ones",   npc = "Olon" },
                { id = 31071, name = "I Bring Us Great Shame",      npc = "Thirsty Missho" },
                { id = 31072, name = "Rending Daggers",             npc = "Lya of Ten Songs" },
                { id = 31073, name = "Bound With Wood",             npc = "Sapmaster Vu" },
                { id = 31074, name = "Wood and Shade",              npc = "Lya of Ten Songs" },
                { id = 31075, name = "Sunset Kings",                npc = "Sapmaster Vu" },
                { id = 31079, name = "The Horror Comes A-Rising",   npc = "Boggeo" },
                { id = 31080, name = "Fiery Wings",                 npc = "Olon" },
                { id = 31081, name = "Incantations Fae and Primal", npc = "Lya of Ten Songs" },
                { id = 31082, name = "Great Vessel of Salvation",   npc = "Chief Rikkitun" },
                { id = 31084, name = "Bind the Glamour",            npc = "Chief Rikkitun" },
                { id = 31085, name = "Fires and Fears of Old",      npc = "Lya of Ten Songs" },
                { id = 31086, name = "Blood of Ancients",           npc = "Sapmaster Vu" },
            },
        },

        -- CHAPTER 3: The Might of the Klaxxi
        {
            chapter = "The Might of the Klaxxi",
            summary = "Skeer hunts by blood. Kaz'tik whispers to kunchong. Both have earned the right.",
            recap = "The Klaxxi's reach extended into the most hostile parts of the wastes. Skeer the Bloodseeker had specific requirements — not battle, exactly, but feeding. You followed his methods, if not his pleasure in them. A strange appetite, satisfied through increasingly particular means: fine dining, a bloody delight, the scent of blood on the wind. Skeer was thorough. Skeer was satisfied.\n\nKaz'tik the Manipulator was different: patient, focused, watching a kunchong that most paragons would see only as a weapon. He had been tending it for what might have been decades. You helped him finish what he had started. The kunchong responded only to Kaz'tik, and it was loyal in the way only something that has never learned fear can be. With Skeer and Kaz'tik standing among the paragons, the might of the Klaxxi was no longer theoretical.",
            quests = {
                { id = 31087, name = "Extending Our Coverage",      npc = "Kor'ik" },
                { id = 31088, name = "Crime and Punishment",        npc = "Kor'ik" },
                { id = 31090, name = "Better With Age",             npc = "Kor'ik" },
                { id = 31089, name = "By the Sea, Nevermore",       npc = "Kor'ik" },
                { id = 31091, name = "Reunited",                    npc = "Kaz'tik the Manipulator" },
                { id = 31092, name = "Feed or Be Eaten",            npc = "Kaz'tik the Manipulator" },
                { id = 31175, name = "Skeer the Bloodseeker",       npc = "Kil'ruk the Wind-Reaver" },
                { id = 31176, name = "A Strange Appetite",          npc = "Skeer the Bloodseeker" },
                { id = 31177, name = "Fine Dining",                 npc = "Skeer the Bloodseeker" },
                { id = 31178, name = "A Bloody Delight",            npc = "Skeer the Bloodseeker" },
                { id = 31179, name = "The Scent of Blood",          npc = "Skeer the Bloodseeker" },
                { id = 31359, name = "The Kunchong Whisperer",      npc = "Kaz'tik the Manipulator" },
                { id = 31398, name = "Falling to Pieces",           npc = "Kaz'tik the Manipulator" },
            },
        },

        -- CHAPTER 4: Like a Deck Boss
        {
            chapter = "Like a Deck Boss",
            summary = "Soggy's Gamble is a shipwrecked camp at the edge of the world. The cap'n runs it on stubbornness alone.",
            recap = "Not every chapter of a war is fought on a battlefield. Soggy's Gamble — a ramshackle settlement of shipwrecked fishermen, one cantankerous captain, and a dog with strong opinions about its schedule — had been cut off from the rest of Pandaria. You helped where you could, and improvised where you couldn't. The sea creatures, the debt to Mazu the sea spirit, the shark problem, the crab problem, the cap'n's particular personality. All of it unfolded at the southern edge of the Dread Wastes with an air of absurdity the mantid would never have tolerated.\n\nYou earned Mazu's bounty. The deck, for the record, was absolutely yours.",
            quests = {
                { id = 31265, name = "Mazu's Breath",               npc = "Deck Boss Arie" },
                { id = 31181, name = "Fresh Pots",                  npc = "Deck Boss Arie" },
                { id = 31182, name = "You Otter Know",              npc = "Deck Boss Arie" },
                { id = 31183, name = "Meet the Cap'n",              npc = "Deck Boss Arie" },
                { id = 31184, name = "Old Age and Treachery",       npc = "Captain \"Soggy\" Su-Dao" },
                { id = 31185, name = "Walking Dog",                 npc = "Captain \"Soggy\" Su-Dao" },
                { id = 31186, name = "Dog Food",                    npc = "Cap'n Aueron" },
                { id = 31187, name = "On the Crab",                 npc = "Deck Boss Arie" },
                { id = 31188, name = "Shark Week",                  npc = "Deck Boss Arie" },
                { id = 31189, name = "Reeltime Strategy",           npc = "Deck Boss Arie" },
                { id = 31190, name = "The Mariner's Revenge",       npc = "Captain \"Soggy\" Su-Dao" },
                { id = 31354, name = "Mazu's Bounty",               npc = "Deck Boss Arie" },
            },
        },

        -- CHAPTER 5: Shadow of the Empire
        {
            chapter = "Shadow of the Empire",
            summary = "Grand Empress Shek'zeer has run out of patience. Eleven paragons stand at your side.",
            recap = "Malik the Unscathed brought word: Grand Empress Shek'zeer had marshalled her full army against the Klaxxi, and there would be no more waiting. You marched with all the paragons you had freed — eleven elders who had outlasted empires — toward the Heart of Fear. What waited inside was sha given form, an Empress possessed beyond recovery. You fought beside the Klaxxi and brought Shek'zeer down.\n\nAfterward, Kil'ruk brought you below Klaxxi'vess — into chambers that no outsider had ever seen. He said he was proud to have fought beside you. He did not say what you were being trusted with. But beneath the halls of the Klaxxi, beneath all of the Dread Wastes, something much older was waiting. The paragons had always known it was there.",
            quests = {
                { id = 31133, name = "Kor'thik Aggression",         npc = "Defender Azzo" },
                { id = 31959, name = "The Empress' Gambit",         npc = "Malik the Unscathed" },
                { id = 31609, name = "The Wrath of Shek'zeer",      npc = "Ambersmith Zikk" },
                { id = 31612, name = "Shadow of the Empire",        npc = "Kil'ruk the Wind-Reaver" },
            },
        },
    },
}

return SM
