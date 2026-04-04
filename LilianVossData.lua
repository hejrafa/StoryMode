local addonName, SM = ...

-- =============================================================================
-- Lilian Voss: The Forsaken Daughter
-- A saga spanning Cataclysm, Mists of Pandaria, and Battle for Azeroth.
-- From Deathknell to the dungeons of the Scarlet Crusade to the shores
-- of Kul Tiras — the story of a daughter who became a weapon.
-- =============================================================================

SM.LilianVossData = {
    -- Questline metadata
    title = "The Forsaken Daughter",
    description = "Lilian Voss was trained from birth to serve the Scarlet Crusade and destroy the undead. When the Val'kyr raise her as Forsaken in Deathknell, she refuses to accept what she has become. Desperate for acceptance, she seeks out her father — High Priest Benedictus Voss — only to be condemned to death by the man who raised her.\n\nWhat follows is a saga of vengeance and identity that stretches across years: a trail of fire and shadow through the Scarlet Halls and Monastery, a descent into the cursed halls of Scholomance, and ultimately a new war on the shores of Kul Tiras — where Lilian must decide whether she is still a weapon, or something more.",
    zone = "Tirisfal Glades / Kul Tiras",
    expansion = "Cataclysm — Battle for Azeroth",
    color = { 0.75, 0.12, 0.18 },  -- Scarlet Crusade crimson
    portraitDisplayID = 85799,  -- Lilian Voss (BfA model) as card portrait

    -- Start location: Caretaker Caice in Deathknell
    startQuest = { id = 24960, name = "The Wakening", npc = "Caretaker Caice", location = "Deathknell, Tirisfal Glades" },
    startMapID = 18,    -- Tirisfal Glades
    startX = 0.3060,
    startY = 0.7140,

    -- Key NPC locations for waypoint guidance (mapID, x, y)
    npcLocations = {
        -- Tirisfal Glades
        ["Caretaker Caice"]           = { mapID = 18, x = 0.3060, y = 0.7140 },
        ["Novice Elreth"]             = { mapID = 18, x = 0.2780, y = 0.6760 },
        ["Deathguard Simmer"]         = { mapID = 18, x = 0.4470, y = 0.5350 },
        ["Executor Zygand"]           = { mapID = 18, x = 0.4510, y = 0.5460 },
        ["High Executor Derrington"]  = { mapID = 18, x = 0.5820, y = 0.5200 },
        ["Lieutenant Sanders"]        = { mapID = 18, x = 0.5300, y = 0.5300 },
        -- Dungeons (interior — coordinates not meaningful)
        ["Hooded Crusader"]           = { mapID = 18, x = 0.8540, y = 0.3100 },
        ["Talking Skull"]             = { mapID = 18, x = 0.7000, y = 0.7300 },
        -- BfA — Zuldazar / Kul Tiras
        ["Nathanos Blightcaller"]     = { mapID = 862, x = 0.5840, y = 0.6260 },
        ["Lilian Voss"]               = { mapID = 862, x = 0.5840, y = 0.6260 },
        ["Rexxar"]                    = { mapID = 942, x = 0.5200, y = 0.3360 },
        ["Thomas Zelling"]            = { mapID = 942, x = 0.5956, y = 0.3070 },
    },

    -- NPC creature display IDs for chapter portraits
    -- Used with SetPortraitTextureFromCreatureDisplayID()
    -- Look up on wowhead.com model viewer or /run print(UnitCreatureDisplayID("target"))
    npcDisplayIDs = {
        -- Tirisfal Glades NPCs
        ["Caretaker Caice"]           = 4473,
        ["Novice Elreth"]             = 1593,
        ["Deathguard Simmer"]         = 1648,
        ["Executor Zygand"]           = 1649,
        ["High Executor Derrington"]  = 10150,
        ["Lieutenant Sanders"]        = 13090,
        -- Dungeon NPCs
        ["Hooded Crusader"]           = 43650,  -- Lilian in disguise
        ["Talking Skull"]             = 31252,   -- Uses Lilian's display as she speaks through it
        -- BfA NPCs
        ["Lilian Voss"]               = 85799,
        ["Nathanos Blightcaller"]     = 86219,
        ["Rexxar"]                    = 60766,
        ["Thomas Zelling"]            = 86536,
    },

    -- =========================================================================
    -- ACT I — TIRISFAL GLADES (Cataclysm)
    -- A daughter of the Scarlet Crusade is raised as the thing she was
    -- trained to destroy.
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: Raised against her will
        {
            chapter = "The Wakening",
            summary = "The Val'kyr raise new Forsaken in the crypt of Deathknell. Among them is a young woman who refuses to accept what she has become — Lilian Voss, daughter of High Priest Benedictus Voss of the Scarlet Crusade.",
            recap = "You opened your eyes in the crypt of Deathknell, raised by the Val'kyr as one of the Forsaken. Among the newly risen was a young woman trembling with rage — Lilian Voss, daughter of the Scarlet Crusade's High Priest. While you accepted your new existence, she could not. She fled into the darkness, refusing to believe what she had become.",
            quests = {
                { id = 24960, name = "The Wakening",            npc = "Caretaker Caice" },
                { id = 24961, name = "The Truth of the Grave",   npc = "Novice Elreth" },
            },
        },

        -- CHAPTER 2: First contact with the Scarlet Crusade
        {
            chapter = "A Scarlet Letter",
            summary = "The Forsaken push into the farmlands surrounding Deathknell, where the Scarlet Crusade maintains a fortified palisade. Inside, a familiar prisoner awaits — Lilian Voss, captured by the very order she once served.",
            recap = "Pushing through the farmlands around Deathknell, you clashed with the Scarlet Crusade at their palisade. Inside the fortifications you found Lilian — captured by the zealots she once served. Her captors didn't care that she had been one of them. To the Crusade, she was just another undead abomination to be purged.",
            quests = {
                { id = 24978, name = "Reaping the Reapers",     npc = "Deathguard Simmer" },
                { id = 24979, name = "A Scarlet Letter",         npc = "Deathguard Simmer" },
                { id = 24980, name = "The Scarlet Palisade",     npc = "Deathguard Simmer" },
                { id = 24981, name = "A Thorn in Our Side",      npc = "Executor Zygand" },
            },
        },

        -- CHAPTER 3: Father and daughter, one last time
        {
            chapter = "A Daughter's Embrace",
            summary = "Lilian tears through the crusaders with terrifying shadow magic, then marches to the tower at Crusader's Run to face the father who condemned her to death. She kills him — and vanishes.",
            recap = "Something broke inside Lilian Voss. Shadow magic erupted from her hands as she tore through the crusaders with a fury that terrified even the Forsaken. She marched to the tower where her father, High Priest Benedictus Voss, waited — and when he condemned her as a monster, she killed him. Then she vanished, leaving nothing but silence and the smell of burning.",
            quests = {
                { id = 25009, name = "At War With The Scarlet Crusade", npc = "High Executor Derrington" },
                { id = 25010, name = "A Deadly New Ally",               npc = "High Executor Derrington" },
                { id = 25046, name = "A Daughter's Embrace",            npc = "Lieutenant Sanders" },
            },
        },

        -- =====================================================================
        -- ACT II — SCARLET HALLS, MONASTERY & SCHOLOMANCE (Mists of Pandaria)
        -- Lilian returns as a hooded infiltrator, hunting the Crusade's
        -- remnants through their own strongholds.
        -- =====================================================================

        -- CHAPTER 4: Infiltrating the Scarlet Halls
        {
            chapter = "The Scarlet Halls",
            summary = "A hooded figure lurks inside the Scarlet Halls, offering coin for carnage. She wants the Crusade's membership records — a checklist of every name, just so none go unaccounted for. The Hooded Crusader does not like loose ends.",
            recap = "Years passed before Lilian surfaced again — this time as a hooded figure lurking inside the Scarlet Halls. She hired you to slaughter your way through the Crusade's ranks and steal their membership records. Every name on that list was a target. Lilian Voss was no longer running from the Crusade — she was hunting them down, one by one.",
            quests = {
                { id = 31490, name = "Rank and File",                   npc = "Hooded Crusader" },
                { id = 31493, name = "Just for Safekeeping, Of Course", npc = "Hooded Crusader" },
            },
        },

        -- CHAPTER 5: Destroying the Scarlet Monastery
        {
            chapter = "The Scarlet Monastery",
            summary = "The Hooded Crusader slips inside the Scarlet Monastery itself. Two blessed blades rest within these halls — weapons anointed to destroy the undead. She wants them found, and she wants them buried in High Inquisitor Whitemane's corpse.",
            recap = "The Hooded Crusader's campaign reached the Scarlet Monastery itself. You retrieved the blessed blades of the Anointed — weapons consecrated to destroy the undead — and drove them into High Inquisitor Whitemane. The irony was not lost on Lilian: the Crusade's holiest weapons, wielded by the dead, against the Crusade's own champion.",
            quests = {
                { id = 31513, name = "Blades of the Anointed",          npc = "Hooded Crusader" },
                { id = 31514, name = "Unto Dust Thou Shalt Return",     npc = "Hooded Crusader" },
            },
        },

        -- CHAPTER 6: Scholomance — consumed by vengeance
        {
            chapter = "Scholomance",
            summary = "Lilian's hunt for dark knowledge leads her into the cursed academy of Scholomance. Within its halls she confronts Darkmaster Gandling — but the darkness she wields threatens to consume her entirely. She must destroy the forbidden tomes and end the suffering, or become the very evil she hunts.",
            recap = "Lilian's pursuit of power led her into Scholomance, the cursed academy of necromancy. Through a talking skull she guided you to destroy the Four Tomes of forbidden knowledge and end the suffering within those walls. But when she faced Darkmaster Gandling, the darkness she wielded nearly consumed her. She survived — but the line between hunter and monster grew thinner.",
            quests = {
                { id = 31440, name = "The Four Tomes",                  npc = "Talking Skull" },
                { id = 31447, name = "An End to the Suffering",         npc = "Talking Skull" },
            },
        },

        -- =====================================================================
        -- ACT III — HORDE WAR CAMPAIGN (Battle for Azeroth)
        -- Years later. Lilian serves the Horde on the shores of Kul Tiras,
        -- but the war forces her to confront what it means to be Forsaken.
        -- =====================================================================

        -- CHAPTER 7: Tiragarde Sound — The First Assault
        {
            chapter = "The First Assault",
            summary = "Nathanos Blightcaller and Lilian Voss lead a covert strike into the heart of Tiragarde Sound. While Nathanos secures the mountain outpost, Lilian takes command of the Bridgeport operation — sabotaging Ashvane foundries, planting explosives, and riding through the chaos she created.",
            recap = "Years later, Lilian served the Horde on the shores of Kul Tiras. While Nathanos Blightcaller secured a mountain outpost, Lilian led you through Bridgeport — sabotaging foundries, planting explosives, and riding through the flames of your own making. She was efficient, ruthless, and completely in her element. The girl who once trembled in Deathknell was gone.",
            quests = {
                { id = 51589, name = "Breaking Kul Tiran Will",         npc = "Nathanos Blightcaller" },
                { id = 51590, name = "Into the Heart of Tiragarde",     npc = "Nathanos Blightcaller" },
                { id = 51591, name = "Our Mountain Now",                npc = "Nathanos Blightcaller" },
                { id = 51592, name = "Making Ourselves at Home",        npc = "Nathanos Blightcaller" },
                { id = 51593, name = "Bridgeport Investigation",        npc = "Lilian Voss" },
                { id = 51594, name = "Explosives in the Foundry",       npc = "Lilian Voss" },
                { id = 51595, name = "Explosivity",                     npc = "Lilian Voss" },
                { id = 51596, name = "Ammunition Acquisition",          npc = "Lilian Voss" },
                { id = 51597, name = "Gunpowder Research",              npc = "Lilian Voss" },
                { id = 51598, name = "A Bit of Chaos",                  npc = "Lilian Voss" },
                { id = 51599, name = "Death Trap",                      npc = "Lilian Voss" },
                { id = 51601, name = "The Bridgeport Ride",             npc = "Lilian Voss" },
            },
        },

        -- CHAPTER 8: Drustvar — The Marshal's Grave
        {
            chapter = "The Marshal's Grave",
            summary = "The graveyards of Drustvar hold fallen Kul Tiran war heroes — soldiers too valuable to leave buried. Nathanos leads the expedition to unearth Marshal M. Valentine, while Lilian questions what separates the Horde's methods from the horrors she once suffered at the hands of the Scarlet Crusade.",
            recap = "Nathanos led an expedition to dig up a fallen Kul Tiran war hero for resurrection. As you searched the graveyards of Drustvar, Lilian grew quiet. Unearthing the dead, raising them against their will — it was exactly what had been done to her. She carried out her orders, but the questions in her eyes said everything her lips would not.",
            quests = {
                { id = 53065, name = "Operation: Grave Digger",         npc = "Nathanos Blightcaller" },
                { id = 51784, name = "A Stroll Through a Cemetery",     npc = "Nathanos Blightcaller" },
                { id = 51785, name = "Examining the Epitaphs",          npc = "Nathanos Blightcaller" },
                { id = 51786, name = "State of Unrest",                 npc = "Nathanos Blightcaller" },
                { id = 51787, name = "Our Lot in Life",                 npc = "Lilian Voss" },
                { id = 51788, name = "The Crypt Keeper",                npc = "Nathanos Blightcaller" },
                { id = 51789, name = "What Remains of Marshal M. Valentine", npc = "Nathanos Blightcaller" },
            },
        },

        -- CHAPTER 9: Stormsong Valley — Death of a Tidesage
        {
            chapter = "Death of a Tidesage",
            summary = "The Horde needs a tidesage's power over the sea. Lilian and Rexxar track one down in Stormsong Valley — Thomas Zelling, a dying man willing to trade his humanity for a few more years with his family. When the ritual is done, Lilian must watch Zelling's wife recoil from the husband she no longer recognizes. The scene is painfully familiar.",
            recap = "Thomas Zelling was a dying tidesage who traded his humanity for undeath, desperate for a few more years with his family. You and Lilian performed the ritual that raised him — and then watched his wife recoil in horror from the husband she no longer recognized. Lilian stood in silence as the scene played out, seeing her own story reflected in Zelling's shattered face. To be Forsaken, she finally understood, was not just a curse of the body.",
            quests = {
                { id = 53066, name = "Operation: Water Wise",           npc = "Nathanos Blightcaller" },
                { id = 51797, name = "Tracking Tidesages",              npc = "Nathanos Blightcaller" },
                { id = 51798, name = "No Price Too High",               npc = "Rexxar" },
                { id = 51805, name = "They Will Know Fear",             npc = "Lilian Voss" },
                { id = 51818, name = "Commander and Captain",           npc = "Thomas Zelling" },
                { id = 51819, name = "Scattering Our Enemies",          npc = "Rexxar" },
                { id = 51830, name = "Zelling's Potential",             npc = "Thomas Zelling" },
                { id = 51837, name = "Whatever Will Be",                npc = "Lilian Voss" },
                { id = 52122, name = "To Be Forsaken",                  npc = "Lilian Voss" },
            },
        },
    },
}
