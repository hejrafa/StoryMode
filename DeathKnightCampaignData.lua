local addonName, SM = ...

-- =============================================================================
-- Legion Death Knight Campaign: Knights of the Ebon Blade
-- Class Order Hall + Artifact Weapons + Class Mount
-- =============================================================================

SM.DeathKnightCampaignData = {
    title = "Deathlord's Campaign",
    achievementName = "The Deathlord's Campaign",
    description = "From Acherus: The Ebon Hold, the Knights of the Ebon Blade wage their own war against the Legion. As Deathlord, you must raise the Four Horsemen — champions torn from death itself — and lead an army of the damned against demons who threaten to unmake the world.",
    zone = "Acherus / Broken Isles",
    expansion = "Legion",
    class = "DEATHKNIGHT",
    color = { 0.77, 0.12, 0.23 },  -- Death Knight red

    startQuest = { id = 40714, name = "The Call to War", npc = "Duke Lankral", location = "Dalaran" },
    startMapID = 627,
    startX = 0.7300,
    startY = 0.5100,

    npcLocations = {
        ["Duke Lankral"]                = { mapID = 627, x = 0.7300, y = 0.5100 },
        ["Highlord Darion Mograine"]    = { mapID = 648, x = 0.5100, y = 0.5100 },
        ["Thassarian"]                  = { mapID = 648, x = 0.5200, y = 0.5000 },
        ["Nazgrim"]                     = { mapID = 648, x = 0.5000, y = 0.5200 },
        ["Koltira Deathweaver"]         = { mapID = 648, x = 0.5300, y = 0.5100 },
        ["Siouxsie the Banshee"]        = { mapID = 648, x = 0.5100, y = 0.4800 },
        ["Salanar the Horseman"]        = { mapID = 648, x = 0.4900, y = 0.5300 },
        ["Amal'thazad"]                 = { mapID = 648, x = 0.5000, y = 0.4900 },
        ["Lord Thorval"]                = { mapID = 648, x = 0.5200, y = 0.5300 },
        ["Prince Galen Trollbane"]      = { mapID = 14, x = 0.3200, y = 0.3500 },
        ["Quartermaster Ozorg"]         = { mapID = 648, x = 0.4800, y = 0.5000 },
        ["Minerva Ravensorrow"]         = { mapID = 646, x = 0.4500, y = 0.6300 },
        ["Dread Commander Thalanor"]    = { mapID = 646, x = 0.4400, y = 0.6200 },
    },

    npcDisplayIDs = {
        ["Duke Lankral"]                = 26688,
        ["Highlord Darion Mograine"]    = 27153,
        ["Thassarian"]                  = 26608,
        ["Nazgrim"]                     = 49521,
        ["Koltira Deathweaver"]         = 25048,
        ["Siouxsie the Banshee"]        = 65573,
        ["Salanar the Horseman"]        = 25235,
        ["Amal'thazad"]                 = 65572,
        ["Lord Thorval"]                = 65571,
        ["Prince Galen Trollbane"]      = 66102,
        ["Quartermaster Ozorg"]         = 15958,
        ["Minerva Ravensorrow"]         = 69441,
        ["Dread Commander Thalanor"]    = 65574,
    },

    -- =========================================================================
    -- Main campaign chapters (in story order)
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: Introduction
        {
            chapter = "The Call to War",
            summary = "Duke Lankral summons you to Acherus, where the Ebon Blade prepares for a war that only the dead can fight.",
            recap = "Duke Lankral appeared in Dalaran with an urgent summons — the Knights of the Ebon Blade needed you at Acherus. The Ebon Hold floated above the Broken Isles like a fortress of iron and frost, and Highlord Darion Mograine spoke of a pact of necessity: the living would fight the Legion their way, and the dead would fight it theirs. You claimed an artifact weapon forged for death itself.",
            quests = {
                { id = 40714, name = "The Call to War",             npc = "Duke Lankral" },
                { id = 40715, name = "A Pact of Necessity",         npc = "Duke Lankral" },
            },
        },

        -- CHAPTER 2: Return of the Four Horsemen
        {
            chapter = "Return of the Four Horsemen",
            summary = "The Lich King commands you to raise the Four Horsemen anew. The first to rise is Nazgrim, the fallen Horde general.",
            recap = "Darion Mograine revealed the Lich King's plan — to raise the Four Horsemen, death knights of legendary power, to serve as the Ebon Blade's vanguard. The first was Nazgrim, the Horde general who fell defending the gates of Orgrimmar. You tore his spirit from the grave and bound it in service. Thassarian and Nazgrim pledged as your champions, and the order's forces began to take shape — troops recruited, missions dispatched, and a war machine built from bone and shadow.",
            quests = {
                { id = 39832, name = "Plans and Preparations",     npc = "Highlord Darion Mograine" },
                { id = 39799, name = "Our Next Move",               npc = "Highlord Darion Mograine" },
                { id = 42449, name = "Return of the Four Horsemen", npc = "Highlord Darion Mograine" },
                { id = 42484, name = "The Firstborn Rises",         npc = "Thassarian" },
                { id = 43264, name = "Rise, Champions",             npc = "Highlord Darion Mograine" },
                { id = 39816, name = "Champion: Thassarian",        npc = "Thassarian" },
                { id = 39818, name = "Champion: Nazgrim",           npc = "Nazgrim" },
                { id = 43265, name = "Spread the Word",             npc = "Highlord Darion Mograine" },
                { id = 43266, name = "Recruiting the Troops",       npc = "Highlord Darion Mograine" },
                { id = 43267, name = "Troops in the Field",         npc = "Siouxsie the Banshee" },
                { id = 42696, name = "Tech It Up A Notch",          npc = "Siouxsie the Banshee" },
            },
        },

        -- CHAPTER 3: The Ruined Kingdom
        {
            chapter = "The Ruined Kingdom",
            summary = "Journey to the ruins of Stromgarde to raise King Thoras Trollbane, the second Horseman, from his defiled grave.",
            recap = "The second Horseman would be Thoras Trollbane, the warrior-king of Stromgarde who had been murdered by his own son. You traveled to the ruined kingdom where Trollbane's restless spirit lingered, betrayed even in death. Prince Galen, the traitor-son, stood in your way — but regicide was a small price for the Ebon Blade. You cut Galen down and raised his father, and Thoras Trollbane rode once more, his fury undimmed by centuries in the grave.",
            quests = {
                { id = 42533, name = "The Ruined Kingdom",         npc = "Highlord Darion Mograine" },
                { id = 42534, name = "Our Oldest Enemies",          npc = "Prince Galen Trollbane" },
                { id = 42535, name = "Death... and Decay",          npc = "Prince Galen Trollbane" },
                { id = 42536, name = "Regicide",                    npc = "Thassarian" },
                { id = 42537, name = "The King Rises",              npc = "Thassarian" },
                { id = 44243, name = "Champion: Thoras Trollbane",  npc = "Thassarian" },
            },
        },

        -- CHAPTER 4: Steeds of the Damned
        {
            chapter = "Steeds of the Damned",
            summary = "Rescue Koltira Deathweaver from imprisonment and forge deathchargers worthy of the Four Horsemen.",
            recap = "Thassarian came with a personal request — Koltira Deathweaver, his old friend and fellow death knight, had been imprisoned beneath the Undercity by Sylvanas Windrunner. You freed Koltira from his chains, and he pledged himself to your cause. Then came the steeds — Salanar the Horseman forged deathchargers in Neltharion's Lair and the Darkheart Thicket, crafting mounts worthy of the Horsemen from nightmares and shadow.",
            quests = {
                { id = 42708, name = "A Personal Request",          npc = "Thassarian" },
                { id = 44244, name = "Champion: Koltira Deathweaver", npc = "Koltira Deathweaver" },
                { id = 43899, name = "Steeds of the Damned",        npc = "Siouxsie the Banshee" },
                { id = 43539, name = "Salanar the Horseman",        npc = "Siouxsie the Banshee" },
                { id = 44082, name = "Knights of the Ebon Blade",   npc = "Highlord Darion Mograine" },
                { id = 43571, name = "Neltharion's Lair: Braid of the Underking", npc = "Salanar the Horseman" },
                { id = 43572, name = "Darkheart Thicket: The Nightmare Lash", npc = "Salanar the Horseman" },
            },
        },

        -- CHAPTER 5: The Scarlet Assault
        {
            chapter = "The Scarlet Assault",
            summary = "Assault the Scarlet Monastery to raise the third Horseman — High Inquisitor Whitemane, your oldest enemy turned servant.",
            recap = "The third Horseman would be the most controversial — High Inquisitor Whitemane of the Scarlet Crusade, a zealot who had burned the undead with holy fire for years. You led the assault on the Scarlet Monastery, cutting through fanatical defenders in a massacre that painted the halls red. When Whitemane fell, you raised her — and the woman who had sworn to destroy every death knight opened her eyes as one. The irony was not lost on anyone.",
            quests = {
                { id = 44217, name = "Armor Fit For A Deathlord",   npc = "Quartermaster Ozorg" },
                { id = 42818, name = "The Scarlet Assault",         npc = "Highlord Darion Mograine" },
                { id = 42882, name = "The Scarlet Massacre",        npc = "Thassarian" },
                { id = 42821, name = "Raising an Army",             npc = "Thassarian" },
                { id = 42823, name = "The Scarlet Commander",       npc = "Thassarian" },
                { id = 42824, name = "The Zealot Rises",            npc = "Thassarian" },
                { id = 44245, name = "Champion: High Inquisitor Whitemane", npc = "Thassarian" },
            },
        },

        -- CHAPTER 6: The Fourth Horseman
        {
            chapter = "The Fourth Horseman",
            summary = "The final Horseman must be raised from the most sacred ground in Azeroth. Darion Mograine makes the ultimate sacrifice.",
            recap = "Three Horsemen rode, but the fourth seat remained empty. The Lich King demanded a champion of unmatched power — and the only candidate lay buried beneath Light's Hope Chapel itself. You stormed the most sacred ground on Azeroth, battling paladins and holy guardians, only for the assault to fail against the Chapel's consecrated power. In the end, it was Darion Mograine who knelt and gave himself — dying so he could rise as the Fourth Horseman. With your weapon forged anew and all four riders assembled, you were named Deathlord of the Ebon Blade.",
            quests = {
                { id = 43573, name = "Advancing the War Effort",    npc = "Siouxsie the Banshee" },
                { id = 44282, name = "Eye of Azshara: The Frozen Soul", npc = "Amal'thazad" },
                { id = 44247, name = "Champion: Amal'thazad",       npc = "Amal'thazad" },
                { id = 44286, name = "Vault of the Wardens: A Masterpiece of Flesh", npc = "Lord Thorval" },
                { id = 44246, name = "Champion: Rottgut",           npc = "Lord Thorval" },
                { id = 44690, name = "A Thirst For Blood",          npc = "Lord Thorval" },
                { id = 43574, name = "Maw of Souls: Maul of the Dead", npc = "Salanar the Horseman" },
                { id = 43686, name = "The Fourth Horseman",         npc = "Highlord Darion Mograine" },
                { id = 44248, name = "Champion: Darion Mograine",   npc = "Highlord Darion Mograine" },
                { id = 43407, name = "A Hero's Weapon",             npc = "Highlord Darion Mograine" },
            },
        },

        -- CHAPTER 7: Broken Shore & Class Mount
        {
            chapter = "Deathlord's Vilebrood Vanquisher",
            summary = "Lead the Ebon Blade to the Broken Shore, tame a frost wyrm, and claim the Vilebrood Vanquisher as your mount.",
            recap = "The Broken Shore called, and the Ebon Blade answered. Minerva Ravensorrow joined as your newest champion, harnessing power from the very demons you slew. You led an expedition to the Peak of Bones where an army of undead rose at your command, fought alongside Thorim's flame, and defeated the Bonemother. On Daumyr's wings you soared above the battlefield, and when the final ride came, you claimed the Vilebrood Vanquisher — a frost wyrm that knelt before the Deathlord.",
            quests = {
                { id = 47137, name = "Champions of Legionfall",     npc = "Highlord Darion Mograine" },
                { id = 45240, name = "Making Preparations",         npc = "Highlord Darion Mograine" },
                { id = 45398, name = "Harnessing Power",            npc = "Minerva Ravensorrow" },
                { id = 45399, name = "Severing the Sveldrek",       npc = "Minerva Ravensorrow" },
                { id = 45331, name = "Return to Acherus",           npc = "Minerva Ravensorrow" },
                { id = 46050, name = "Champion: Minerva Ravensorrow", npc = "Minerva Ravensorrow" },
                { id = 44775, name = "The Peak of Bones",           npc = "Highlord Darion Mograine" },
                { id = 45243, name = "On Daumyr's Wings",           npc = "Highlord Darion Mograine" },
                { id = 45103, name = "We Ride!",                    npc = "Highlord Darion Mograine" },
                { id = 46719, name = "Amal'thazad's Message",       npc = "Dread Commander Thalanor" },
                { id = 46720, name = "Frozen Memories",             npc = "Amal'thazad" },
                { id = 46812, name = "Draconic Secrets",            npc = "Amal'thazad" },
                { id = 46813, name = "The Lost Glacier",            npc = "Amal'thazad" },
            },
        },

        -- CHAPTER 8-10: Artifact Weapons
        {
            chapter = "Apocalypse",
            summary = "The Lich King reveals the location of Apocalypse, a runesword that brings death to everything it touches.",
            recap = "The Lich King's voice echoed through Acherus, pointing you toward Apocalypse — a blade of pure death forged in an age of darkness. You followed the trail through Duskwood alongside Revil Kost, hunting the Dark Riders who had stolen the sword. In the depths of Deadwind Pass, you wrested Apocalypse from their skeletal grip. The blade hummed with necrotic power, eager to fulfill the promise of its name.",
            quests = {
                { id = 40930, name = "Apocalypse",                  npc = "Highlord Darion Mograine" },
            },
        },
        {
            chapter = "Blades of the Fallen Prince",
            summary = "Journey to Icecrown Citadel to reforge the shattered remnants of Frostmourne into twin runeblades.",
            recap = "Darion Mograine spoke of Frostmourne — the Lich King's blade, shattered atop Icecrown Citadel. Its shards still radiated power, and the call of Icecrown pulled you north. In the frozen throne room, you gathered the remnants and reforged them into the Blades of the Fallen Prince — twin runeblades that carried echoes of Arthas, Ner'zhul, and every soul the original sword had devoured.",
            quests = {
                { id = 38990, name = "The Call of Icecrown",        npc = "Highlord Darion Mograine" },
            },
        },
        {
            chapter = "Maw of the Damned",
            summary = "Recover the Maw of the Damned, a vampiric axe that drains the life from its victims to sustain its wielder.",
            recap = "Duke Lankral told of the Maw of the Damned — a vampiric greataxe that drank the blood of its enemies and fed it to its wielder. The weapon had been lost in a Legion stronghold, guarded by demons who had learned to fear it. You stormed their fortress and tore the Maw from the hands of its demonic captor. The axe drank deep on the way out.",
            quests = {
                { id = 40740, name = "The Dead and the Damned",     npc = "Duke Lankral" },
            },
        },
    },
}
