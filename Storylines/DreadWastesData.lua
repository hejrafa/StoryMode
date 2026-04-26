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
        6545,   -- Klaxxi (Exalted with The Klaxxi)
    },
    description = "The mantid are ancient and alien: older than the mogu, older than written history, and bound to traditions outsiders barely understand. In the Dread Wastes, something has gone wrong inside the swarm, and even the Klaxxi have begun to move against their own Empress.\n\nThey name you a Wakener, an outsider trusted to free legendary paragons from amber and help steady a civilization that sees war, loyalty, and destiny very differently than the rest of Pandaria.",
    zone = "Dread Wastes",
    expansion = "Mists of Pandaria",
    color = { 0.72, 0.53, 0.15 },   -- amber/ochre

    icon = 624970,
    factions = { 1337 }, -- The Klaxxi
    adventureGuideInstanceName = "Heart of Fear",

    startQuest = { id = 31001, name = "Falling Down", npc = "Shado-Pan Scout", location = "Terrace of Gurthan" },
    startMapID = 422,
    startX = 0.3400,
    startY = 0.2200,

    npcLocations = {
        ["Ambersmith Zikk"]         = { mapID = 422, x = 0.5580, y = 0.5060 },  -- Klaxxi'vess
        ["Kil'ruk the Wind-Reaver"] = { mapID = 422, x = 0.5240, y = 0.4850 },
        ["Ka'roz the Locust"]       = { mapID = 422, x = 0.5460, y = 0.5200 },
        ["Kaz'tik the Manipulator"] = { mapID = 422, x = 0.4700, y = 0.5600 },
        ["Malik the Unscathed"]     = { mapID = 422, x = 0.6200, y = 0.5100 },  -- Heart of Fear entrance
    },

    npcDisplayIDs = {
        ["Shado-Pan Scout"]         = 42080,
        ["Ambersmith Zikk"]         = 43587,
        ["Master Angler Ju Lien"]   = 43494,
        ["Kil'ruk the Wind-Reaver"] = 0,  -- TODO: verify
        ["Ka'roz the Locust"]       = 0,  -- TODO: verify
        ["Kaz'tik the Manipulator"] = 0,  -- TODO: verify
    },

    portraitDisplayID = 43587,  -- Ambersmith Zikk (TODO: swap for Kil'ruk once ID is known)

    -- =========================================================================
    -- Main storyline chapters (matching the 4 achievement questlines + epilogue)
    -- =========================================================================
    chapters = {

        -- CHAPTER 1: The First Paragons
        {
            chapter = "The First Paragons",
            summary = "A wall stands between Pandaria and the mantid swarm. It just cracked open.",
            recap = "The Shado-Pan had held the Serpent's Spine against the mantid for centuries, but when you arrived, the swarm had already turned on itself. Grand Empress Shek'zeer had been touched by sha energy, and the corruption was spreading. You fell from the wall into the Dread Wastes and survived by luck and stubbornness. The Klaxxi, the mantid council of elders, had been watching. They named you a Wakener — a rare outsider trusted to free their greatest warriors from amber prisons.\n\nAt Klaxxi'vess, the heart of the Klaxxi, you stood before paragons who had been preserved in amber for decades. Kil'ruk the Wind-Reaver regarded you with the cool assessment of someone who had fought wars before your grandparents were born. You proved your worth. The first paragons were free, and the Klaxxi's war against the Empress had begun in earnest.",
            quests = {
                { id = 31001, name = "Falling Down",                npc = "Shado-Pan Scout" },
                { id = 31002, name = "Nope",                        npc = "Shado-Pan Scout" },
                { id = 31003, name = "Psycho Mantid",               npc = "Shado-Pan Scout" },
                { id = 31004, name = "Preserved in Amber",          npc = "Shado-Pan Scout" },
                { id = 31005, name = "Wakening Sickness",           npc = "Kil'ruk the Wind-Reaver" },
                { id = 31676, name = "Ancient Vengeance",           npc = "Kil'ruk the Wind-Reaver" },
                { id = 31006, name = "The Klaxxi Council",          npc = "Kil'ruk the Wind-Reaver" },
                { id = 31007, name = "The Dread Clutches",          npc = "Ambersmith Zikk" },
                { id = 31660, name = "Not Fit to Swarm",            npc = "Ambersmith Zikk" },
                { id = 31009, name = "Dead Zone",                   npc = "Ambersmith Zikk" },
                { id = 31008, name = "Amber Arms",                  npc = "Ambersmith Zikk" },
                { id = 31661, name = "A Source of Terrifying Power", npc = "Ambersmith Zikk" },
                { id = 31010, name = "In Her Clutch",               npc = "Ambersmith Zikk" },
                { id = 31689, name = "The Dreadsworn",              npc = "Ambersmith Zikk" },
                { id = 31108, name = "Concentrated Fear",           npc = "Ambersmith Zikk" },
                { id = 31107, name = "Citizens of a New Empire",    npc = "Ambersmith Zikk" },
                { id = 31066, name = "The First Paragons",          npc = "Ambersmith Zikk" },
            },
        },

        -- CHAPTER 2: Taste of Amber
        {
            chapter = "Taste of Amber",
            summary = "The Klaxxi forge weapons from amber of sacred trees — and the wastes hold older fires still.",
            recap = "The paragons needed weapons worthy of war. The amber of Kypari Zar — a sacred tree deep in the wastes — carried the power to fortify blades beyond ordinary craft. You harvested it, fed the groves that kept living amber healthy, and traced the roots to find what corruption had touched them. In the ruins nearby, older rituals waited: the binding of shade and wood, incantations fae and primal, the crafting of daggers by ancient recipes. The Stormstout family, stranded and out of their depth in the wastes, crossed your path along the way.\n\nDeeper still, the fires of old spirits burned. You bound the glamour, faced what had been unleashed at the heart of the blaze, and came out the other side with the smell of amber and ash still in your armor. The sacred trees held. The weapons were ready.",
            quests = {
                { id = 31019, name = "Amber Is Life",               npc = "Ambersmith Zikk" },
                { id = 31020, name = "Feeding the Beast",           npc = "Ambersmith Zikk" },
                { id = 31021, name = "Living Amber",                npc = "Ambersmith Zikk" },
                { id = 31022, name = "Kypari Zar",                  npc = "Ambersmith Zikk" },
                { id = 31026, name = "The Root of the Problem",     npc = "Ambersmith Zikk" },
                { id = 31067, name = "The Heavens Hum With War",    npc = "Ambersmith Zikk" },
                { id = 31068, name = "Sacred Recipe",               npc = "Ambersmith Zikk" },
                { id = 31069, name = "Bound With Shade",            npc = "Ambersmith Zikk" },
                { id = 31070, name = "Daggers of the Great Ones",   npc = "Ambersmith Zikk" },
                { id = 31071, name = "I Bring Us Great Shame",      npc = "Ambersmith Zikk" },
                { id = 31072, name = "Rending Daggers",             npc = "Ambersmith Zikk" },
                { id = 31073, name = "Bound With Wood",             npc = "Ambersmith Zikk" },
                { id = 31074, name = "Wood and Shade",              npc = "Ambersmith Zikk" },
                { id = 31075, name = "Sunset Kings",                npc = "Ambersmith Zikk" },
                { id = 31076, name = "Fate of the Stormstouts",     npc = "Evie Stormstout",  optional = true },
                { id = 31129, name = "Fate of the Stormstouts",     npc = "Evie Stormstout",  optional = true },
                { id = 31077, name = "Evie Stormstout",             npc = "Evie Stormstout" },
                { id = 31078, name = "Han Stormstout",              npc = "Han Stormstout" },
                { id = 31079, name = "The Horror Comes A-Rising",   npc = "Ambersmith Zikk" },
                { id = 31080, name = "Fiery Wings",                 npc = "Ambersmith Zikk" },
                { id = 31081, name = "Incantations Fae and Primal", npc = "Ambersmith Zikk" },
                { id = 31082, name = "Great Vessel of Salvation",   npc = "Ambersmith Zikk" },
                { id = 31084, name = "Bind the Glamour",            npc = "Ambersmith Zikk" },
                { id = 31085, name = "Fires and Fears of Old",      npc = "Ambersmith Zikk" },
                { id = 31086, name = "Taste of Amber",              npc = "Ambersmith Zikk" },
            },
        },

        -- CHAPTER 3: The Might of the Klaxxi
        {
            chapter = "The Might of the Klaxxi",
            summary = "Skeer hunts by blood. Kaz'tik whispers to kunchong. Both have earned the right.",
            recap = "The Klaxxi's reach extended into the most hostile parts of the wastes. Skeer the Bloodseeker had specific requirements — not battle, exactly, but feeding. You followed his methods, if not his pleasure in them. A strange appetite, satisfied through increasingly particular means: fine dining, a bloody delight, the scent of blood on the wind. Skeer was thorough. Skeer was satisfied.\n\nKaz'tik the Manipulator was different: patient, focused, watching a kunchong that most paragons would see only as a weapon. He had been tending it for what might have been decades. You helped him finish what he had started. The kunchong responded only to Kaz'tik, and it was loyal in the way only something that has never learned fear can be. With Skeer and Kaz'tik standing among the paragons, the might of the Klaxxi was no longer theoretical.",
            quests = {
                { id = 31087, name = "Extending Our Coverage",      npc = "Ambersmith Zikk" },
                { id = 31088, name = "Crime and Punishment",        npc = "Ambersmith Zikk" },
                { id = 31089, name = "By the Sea, Nevermore",       npc = "Ambersmith Zikk" },
                { id = 31090, name = "Better With Age",             npc = "Ambersmith Zikk" },
                { id = 31091, name = "Reunited",                    npc = "Ambersmith Zikk" },
                { id = 31092, name = "Feed or Be Eaten",            npc = "Ambersmith Zikk" },
                { id = 31175, name = "Skeer the Bloodseeker",       npc = "Skeer the Bloodseeker" },
                { id = 31176, name = "A Strange Appetite",          npc = "Skeer the Bloodseeker" },
                { id = 31177, name = "Fine Dining",                 npc = "Skeer the Bloodseeker" },
                { id = 31178, name = "A Bloody Delight",            npc = "Skeer the Bloodseeker" },
                { id = 31179, name = "The Scent of Blood",          npc = "Skeer the Bloodseeker" },
                { id = 31359, name = "The Kunchong Whisperer",      npc = "Kaz'tik the Manipulator" },
                { id = 31398, name = "The Might of the Klaxxi",     npc = "Kaz'tik the Manipulator" },
            },
        },

        -- CHAPTER 4: Like a Deck Boss
        {
            chapter = "Like a Deck Boss",
            summary = "Soggy's Gamble is a shipwrecked camp at the edge of the world. The cap'n runs it on stubbornness alone.",
            recap = "Not every chapter of a war is fought on a battlefield. Soggy's Gamble — a ramshackle settlement of shipwrecked fishermen, one cantankerous captain, and a dog with strong opinions about its schedule — had been cut off from the rest of Pandaria. You helped where you could, and improvised where you couldn't. The sea creatures, the debt to Mazu the sea spirit, the shark problem, the crab problem, the cap'n's particular personality. All of it unfolded at the southern edge of the Dread Wastes with an air of absurdity the mantid would never have tolerated.\n\nYou earned Mazu's bounty. The deck, for the record, was absolutely yours.",
            quests = {
                { id = 31265, name = "Mazu's Breath",               npc = "Master Angler Ju Lien" },
                { id = 31181, name = "Fresh Pots",                  npc = "Master Angler Ju Lien" },
                { id = 31182, name = "You Otter Know",              npc = "Master Angler Ju Lien" },
                { id = 31183, name = "Meet the Cap'n",              npc = "Master Angler Ju Lien" },
                { id = 31184, name = "Old Age and Treachery",       npc = "Cap'n Aueron" },
                { id = 31185, name = "Walking Dog",                 npc = "Cap'n Aueron" },
                { id = 31186, name = "Dog Food",                    npc = "Cap'n Aueron" },
                { id = 31187, name = "On the Crab",                 npc = "Cap'n Aueron" },
                { id = 31188, name = "Shark Week",                  npc = "Cap'n Aueron" },
                { id = 31189, name = "Reeltime Strategy",           npc = "Cap'n Aueron" },
                { id = 31190, name = "The Mariner's Revenge",       npc = "Cap'n Aueron" },
                { id = 31354, name = "Like a Deck Boss",            npc = "Master Angler Ju Lien" },
            },
        },

        -- CHAPTER 5: Shadow of the Empire
        {
            chapter = "Shadow of the Empire",
            summary = "Grand Empress Shek'zeer has run out of patience. Eleven paragons stand at your side.",
            recap = "Malik the Unscathed brought word: Grand Empress Shek'zeer had marshalled her full army against the Klaxxi, and there would be no more waiting. You marched with all the paragons you had freed — eleven elders who had outlasted empires — toward the Heart of Fear. What waited inside was sha given form, an Empress possessed beyond recovery. You fought beside the Klaxxi and brought Shek'zeer down.\n\nAfterward, Kil'ruk brought you below Klaxxi'vess — into chambers that no outsider had ever seen. He said he was proud to have fought beside you. He did not say what you were being trusted with. But beneath the halls of the Klaxxi, beneath all of the Dread Wastes, something much older was waiting. The paragons had always known it was there.",
            quests = {
                { id = 31133, name = "Kor'thik Aggression",         npc = "Ambersmith Zikk" },
                { id = 31959, name = "The Empress' Gambit",         npc = "Malik the Unscathed" },
                { id = 31609, name = "The Wrath of Shek'zeer",      npc = "Malik the Unscathed" },
                { id = 31612, name = "Shadow of the Empire",        npc = "Kil'ruk the Wind-Reaver" },
            },
        },
    },
}

return SM
