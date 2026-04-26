local addonName, SM = ...

-- =============================================================================
-- Mists of Pandaria: The Jade Forest
-- Zone Storyline: "Upjade Complete" (Achievement 6300)
-- Dungeon Finale: Temple of the Jade Serpent
-- =============================================================================

SM.JadeForestData = {
    title = "The Jade Forest",
    achievementID = 6300,
    achievements = {
        6300,   -- Upjade Complete
        7381,   -- Restore Balance
        6850,   -- Hozen in the Mist
        6858,   -- What Is Worth Fighting For
        7230,   -- Legend of the Brewfathers
        6846,   -- Fish Tales
        6754,   -- The Dark Heart of the Mogu
        6855,   -- The Seven Burdens of Shaohao
        6716,   -- Between a Saurok and a Hard Place
        6757,   -- Temple of the Jade Serpent
    },
    description = "The Alliance and Horde did not discover Pandaria gently. They arrived as wreckage, orders, pursuit, and fire, then tried to make allies before they understood what the land would remember.\n\nThe Jade Forest is the first lesson of Pandaria: every doubt, every grudge, and every easy answer has weight. Follow the campaign from the first landings into a land where war leaves marks deeper than banners in the mud.",
    zone = "The Jade Forest",
    expansion = "Mists of Pandaria",
    color = { 0.22, 0.62, 0.32 },

    icon = 617824,
    adventureGuideInstanceName = "Temple of the Jade Serpent",

    startQuest = { id = 29547, name = "The King's Command", npc = "King Varian Wrynn", location = "Stormwind", faction = "Alliance" },
    startMapID = 371,
    startX = 0.4800,
    startY = 0.8800,

    npcLocations = {
        ["King Varian Wrynn"]   = { mapID = 84,  x = 0.8500, y = 0.3200 },
        ["Garrosh Hellscream"]  = { mapID = 85,  x = 0.4900, y = 0.7100 },
        ["Rell Nightwind"]      = { mapID = 371, x = 0.4800, y = 0.8800 },
        ["Sky Admiral Rogers"]  = { mapID = 371, x = 0.4800, y = 0.8800 },
        ["Admiral Taylor"]      = { mapID = 371, x = 0.5800, y = 0.8100 },
        ["Bold Karasshi"]       = { mapID = 371, x = 0.5900, y = 0.8200 },
        ["Elder Lusshan"]       = { mapID = 371, x = 0.5800, y = 0.8100 },
        ["General Nazgrim"]     = { mapID = 371, x = 0.2800, y = 0.4700 },
        ["Sergeant Gorrok"]     = { mapID = 371, x = 0.2900, y = 0.1400 },
        ["Shademaster Kiryn"]   = { mapID = 371, x = 0.2800, y = 0.2500 },
        ["Rivett Clutchpop"]    = { mapID = 371, x = 0.2800, y = 0.4700 },
        ["Chief Kah Kah"]       = { mapID = 371, x = 0.2800, y = 0.4700 },
        ["Lorewalker Cho"]      = { mapID = 371, x = 0.4700, y = 0.4600 },
        ["Toya"]                = { mapID = 371, x = 0.4700, y = 0.4600 },
        ["Old Man Misteye"]     = { mapID = 371, x = 0.4820, y = 0.4600 },
        ["Lin Tenderpaw"]       = { mapID = 371, x = 0.4500, y = 0.2500 },
        ["Shao the Defiant"]    = { mapID = 371, x = 0.4300, y = 0.7600 },
        ["Foreman Mann"]        = { mapID = 371, x = 0.5100, y = 0.2700 },
        ["Outcast Sprite"]      = { mapID = 371, x = 0.4900, y = 0.2500 },
        ["Foreman Raike"]       = { mapID = 371, x = 0.4800, y = 0.6100 },
        ["Elder Sage Rain-Zhu"] = { mapID = 371, x = 0.5800, y = 0.5900 },
        ["Elder Sage Wind-Yi"]  = { mapID = 371, x = 0.5600, y = 0.5700 },
        ["Yu'lon"]              = { mapID = 371, x = 0.5600, y = 0.5700 },
    },

    npcDisplayIDs = {
        ["King Varian Wrynn"]   = 28127,
        ["Garrosh Hellscream"]  = 32904,
        ["Rell Nightwind"]      = 42186,
        ["Sky Admiral Rogers"]  = 42283,
        ["Admiral Taylor"]      = 39036,
        ["Bold Karasshi"]       = 42188,
        ["Elder Lusshan"]       = 42269,
        ["General Nazgrim"]     = 42562,
        ["Sergeant Gorrok"]     = 39047,
        ["Shademaster Kiryn"]   = 39039,
        ["Rivett Clutchpop"]    = 42264,
        ["Chief Kah Kah"]       = 42453,
        ["Lorewalker Cho"]      = 127838,
        ["Toya"]                = 42605,
        ["Old Man Misteye"]     = 40761,
        ["Lin Tenderpaw"]       = 42072,
        ["Shao the Defiant"]    = 41981,
        ["Foreman Mann"]        = 42272,
        ["Outcast Sprite"]      = 40751,
        ["Foreman Raike"]       = 40770,
        ["Elder Sage Rain-Zhu"] = 39725,
        ["Elder Sage Wind-Yi"]  = 39724,
        ["Yu'lon"]              = 40029,
    },

    chapterIcons = {
        ["Temple of the Jade Serpent"] = 603529, -- Temple of the Jade Serpent achievement art
    },

    chapters = {

        -- =================================================================
        -- ALLIANCE: Paw'don Village
        -- =================================================================
        {
            chapter = "Paw'don Village",
            faction = "Alliance",
            summary = "The Skyfire reaches Pandaria hunting for Admiral Taylor and Prince Anduin, but the Alliance lands in the middle of a Horde war zone.",
            recap = "King Varian's command sent you after the missing White Pawn: Prince Anduin Wrynn. The Skyfire found Pandaria and immediately found the Horde. Admiral Rogers turned the gunship into a weapon, Sully McLeary got you onto the ground, and Paw'don Village became the Alliance's first real foothold. Every step inland was paid for in smoke, wounded soldiers, stolen supplies, and the first glimpse of sha born from the armies' violence. By the time Ga'trul fell at Twinspire Keep, the Alliance had survived its landing - but Taylor and Anduin were still missing.",
            quests = {
                { id = 29547, name = "The King's Command", npc = "King Varian Wrynn" },
                { id = 29548, name = "The Mission", npc = "Rell Nightwind" },
                { id = 31732, name = "Unleash Hell", npc = "Sky Admiral Rogers" },
                { id = 31733, name = "Touching Ground", npc = "Sky Admiral Rogers" },
                { id = 30069, name = "No Plan Survives Contact with the Enemy", npc = "Sully \"The Pickle\" McLeary" },
                { id = 31734, name = "Welcome Wagons", npc = "Sully \"The Pickle\" McLeary" },
                { id = 31735, name = "The Right Tool For The Job", npc = "Rell Nightwind" },
                { id = 31736, name = "Envoy of the Alliance", npc = "Rell Nightwind" },
                { id = 31737, name = "The Cost of War", npc = "Rell Nightwind" },
                { id = 31738, name = "Pillaging Peons", npc = "Sunke Khang" },
                { id = 29552, name = "Critical Condition", npc = "Mishka" },
                { id = 31739, name = "Priorities!", npc = "Teng Applebloom" },
                { id = 31740, name = "Koukou's Rampage", npc = "Lin Applebloom" },
                { id = 31741, name = "Twinspire Keep", npc = "Sunke Khang" },
                { id = 31742, name = "Fractured Forces", npc = "Rell Nightwind" },
                { id = 31743, name = "Smoke Before Fire", npc = "Rell Nightwind" },
                { id = 31744, name = "Unfair Trade", npc = "Sunke Khang" },
                { id = 30070, name = "The Fall of Ga'trul", npc = "Sully \"The Pickle\" McLeary" },
                { id = 31745, name = "Onward and Inward", npc = "Rell Nightwind" },
            },
        },

        -- =================================================================
        -- HORDE: Honeydew Village
        -- =================================================================
        {
            chapter = "Honeydew Village",
            faction = "Horde",
            summary = "Hellscream's Fist crashes into Pandaria, leaving Nazgrim to turn wreckage, survivors, and frightened locals into a foothold.",
            recap = "Garrosh sent the Horde to seize whatever had been hidden in the mists. Instead, Hellscream's Fist fell burning into the Jade Forest. Nazgrim drove the survivors forward with fire and discipline, but the first victory curdled quickly. Taran Zhu named the consequence of the Horde's fury: sha. The Horde regrouped at Honeydew Village, pulled its scattered officers out of danger, and learned that Pandaria would answer violence with something far older than either faction expected.",
            quests = {
                { id = 29612, name = "The Art of War", npc = "Garrosh Hellscream" },
                { id = 31853, name = "All Aboard!", npc = "General Nazgrim" },
                { id = 29690, name = "Into the Mists", npc = "General Nazgrim" },
                { id = 31765, name = "Paint it Red!", npc = "General Nazgrim" },
                { id = 31766, name = "Touching Ground", npc = "Rivett Clutchpop" },
                { id = 31767, name = "Finish Them!", npc = "General Nazgrim" },
                { id = 31768, name = "Fire Is Always the Answer", npc = "General Nazgrim" },
                { id = 31769, name = "The Final Blow!", npc = "General Nazgrim" },
                { id = 31770, name = "You're Either With Us Or...", npc = "General Nazgrim" },
                { id = 31771, name = "Face to Face With Consequence", npc = "Taran Zhu" },
                { id = 29694, name = "Regroup!", npc = "General Nazgrim" },
                { id = 31978, name = "Priorities!", npc = "Gi-Oh", optional = true },
                { id = 31773, name = "Prowler Problems", npc = "Kai-Lin Honeydew" },
            },
        },

        -- =================================================================
        -- ALLIANCE: Pearlfin and the White Pawn
        -- =================================================================
        {
            chapter = "Pearlfin and the White Pawn",
            faction = "Alliance",
            summary = "The Alliance finds Taylor, courts the Pearlfin jinyu, and follows Cho's strange methods to Prince Anduin.",
            recap = "The Vanguard's wreckage proved Anduin had survived, but it also pulled the Alliance into the Pearlfin jinyu's crisis. Taylor and Bold Karasshi had been captured by the Slingtail hozen, and the only way forward was through the pits. You freed prisoners, recovered waterspeaker relics, broke Kung Din's hold, and helped the Pearlfin decide whether the Alliance deserved their trust. SI:7's reports then made the bargain real: the Horde had armed the hozen, so Taylor trained the jinyu to fight back. When the trail finally led to Cho, the search changed shape. Tea, stories, and a strange brew opened the way to Anduin, who was already choosing curiosity over command.",
            quests = {
                { id = 29555, name = "The White Pawn", npc = "Sky Admiral Rogers" },
                { id = 29556, name = "Hozen Aren't Your Friends, Hozen Are Your Enemies", npc = "Sky Admiral Rogers" },
                { id = 29553, name = "The Missing Admiral", npc = "Nodd Codejack" },
                { id = 29558, name = "The Path of War", npc = "Bold Karasshi" },
                { id = 29559, name = "Freeing Our Brothers", npc = "Bold Karasshi" },
                { id = 29560, name = "Ancient Power", npc = "Bold Karasshi" },
                { id = 29759, name = "Kung Din", npc = "Bold Karasshi" },
                { id = 29562, name = "Jailbreak", npc = "Bold Karasshi" },
                { id = 29883, name = "The Pearlfin Situation", npc = "Rell Nightwind" },
                { id = 29885, name = "Road Rations", npc = "Rell Nightwind" },
                { id = 29762, name = "Family Heirlooms", npc = "Bold Karasshi" },
                { id = 29887, name = "The Elder's Instruments", npc = "Pearlkeeper Fujin" },
                { id = 29894, name = "Spirits of the Water", npc = "Pearlkeeper Fujin" },
                { id = 29733, name = "SI:7 Report: Lost in the Woods", npc = "Rell Nightwind" },
                { id = 29725, name = "SI:7 Report: Fire From the Sky", npc = "Sully \"The Pickle\" McLeary" },
                { id = 29726, name = "SI:7 Report: Hostile Natives", npc = "Little Lu" },
                { id = 29727, name = "SI:7 Report: Take No Prisoners", npc = "Amber Kearnen" },
                { id = 29903, name = "A Perfect Match", npc = "Admiral Taylor" },
                { id = 29904, name = "Bigger Fish to Fry", npc = "Admiral Taylor" },
                { id = 29905, name = "Let Them Burn", npc = "Admiral Taylor" },
                { id = 29906, name = "Carp Diem", npc = "Admiral Taylor" },
                { id = 29888, name = "Seek Out the Lorewalker", npc = "Bold Karasshi" },
                { id = 29889, name = "Borrowed Brew", npc = "Mouthwatering Brew" },
                { id = 31130, name = "A Visit with Lorewalker Cho", npc = "Lorewalker Cho" },
                { id = 29891, name = "Potency", npc = "Lorewalker Cho" },
                { id = 29892, name = "Body", npc = "Lorewalker Cho" },
                { id = 29893, name = "Hue", npc = "Lorewalker Cho" },
                { id = 29890, name = "Finding Your Center", npc = "Lorewalker Cho" },
                { id = 29898, name = "Sacred Waters", npc = "Anduin Wrynn" },
                { id = 29899, name = "Rest in Peace", npc = "Ren Whitepaw" },
                { id = 29900, name = "An Ancient Legend", npc = "Lina Whitepaw" },
                { id = 29901, name = "Anduin's Decision", npc = "Anduin Wrynn" },
            },
        },

        -- =================================================================
        -- HORDE: The Strongarm Airstrip
        -- =================================================================
        {
            chapter = "The Strongarm Airstrip",
            faction = "Horde",
            summary = "Nazgrim rescues Zin'jun, breaks the Alliance airstrip, and follows the trail to the edge of Cho's lesson.",
            recap = "The search for Zin'jun began as a rescue and became a campaign. The hozen had stripped him of his gear, the Alliance had dug in at Strongarm Airstrip, and Nazgrim needed every advantage he could improvise. You recovered Zin'jun's belongings, assaulted the airstrip, broke key Alliance officers, and learned that Captain Doren had been consumed by the darkness Taran Zhu warned about. Kiryn and Rivett turned Alliance wreckage into intelligence and acid rain, and Nazgrim sent you to read the shape of the land itself. Lay of the Land was the hinge: the war had carried you this far, but Cho was waiting to show you what the Horde had actually stepped into.",
            quests = {
                { id = 31774, name = "Seeking Zin'jun", npc = "Sergeant Gorrok" },
                { id = 29765, name = "Cryin' My Eyes Out", npc = "Zin'jun" },
                { id = 29743, name = "Monstrosity", npc = "Ancient Statue", optional = true },
                { id = 29804, name = "Seein' Red", npc = "Zin'jun" },
                { id = 31775, name = "Assault on the Airstrip", npc = "General Nazgrim" },
                { id = 31776, name = "Strongarm Tactics", npc = "General Nazgrim" },
                { id = 31777, name = "Choppertunity", npc = "Rivett Clutchpop" },
                { id = 31778, name = "Unreliable Allies", npc = "Merchant Zin" },
                { id = 31779, name = "The Darkness Within", npc = "General Nazgrim" },
                { id = 31999, name = "Nazgrim's Command", npc = "General Nazgrim" },
                { id = 29815, name = "Forensic Science", npc = "Shademaster Kiryn" },
                { id = 29821, name = "Missed Me By... That Much!", npc = "Rivett Clutchpop" },
                { id = 31112, name = "They're So Thorny!", npc = "Empty Package" },
                { id = 29827, name = "Acid Rain", npc = "Shademaster Kiryn" },
                { id = 29822, name = "Lay of the Land", npc = "General Nazgrim" },
            },
        },

        -- =================================================================
        -- HORDE: Lorewalker Cho's Lesson
        -- =================================================================
        {
            chapter = "Lorewalker Cho's Lesson",
            faction = "Horde",
            summary = "Cho slows the Horde campaign long enough to teach the land's memory, then the hozen pull you back into motion.",
            recap = "Lorewalker Cho did not answer Nazgrim's campaign with orders. He answered with tea, old stones, and the patient insistence that Pandaria had a story before the Horde arrived. You walked a mile in another person's shoes, listened to the forest's dead, peered into the past, and traced the branches of Cho's own family. The lesson was not gentle, but it was necessary: this land remembers what people bring into it. Then the river swallowed you, the hozen found you, and Chief Kah Kah's orders dragged the lesson back into the campaign. You left Cho with more questions than victories, which was probably the point.",
            quests = {
                { id = 31121, name = "Stay a While, and Listen", npc = "Lorewalker Cho" },
                { id = 31132, name = "A Mile in My Shoes", npc = "Lorewalker Cho" },
                { id = 31134, name = "If These Stones Could Speak", npc = "Lorewalker Cho" },
                { id = 31152, name = "Peering Into the Past", npc = "Lorewalker Cho" },
                { id = 31167, name = "Family Tree", npc = "Lorewalker Cho" },
                { id = 29879, name = "Swallowed Whole", npc = "Lorewalker Cho" },
                { id = 29935, name = "Orders are Orders", npc = "Tooki Tooki" },
                { id = 29933, name = "The Bees' Knees", npc = "Bo Bo", optional = true },
                { id = 29924, name = "Kill Kher Shan", npc = "Nibi Nibi", optional = true },
                { id = 31241, name = "Wicked Wikkets", npc = "Jeek Jeek", optional = true },
                { id = 31261, name = "Captain Jack's Dead", npc = "Capt. Jack's Head", optional = true },
            },
        },

        -- =================================================================
        -- HORDE: Grookin Hill
        -- =================================================================
        {
            chapter = "Grookin Hill",
            faction = "Horde",
            summary = "The Horde's hozen alliance becomes a proper forward campaign from Grookin Hill.",
            recap = "Grookin Hill roared to life in exactly the way a hozen fortress would: loud, improvised, and enthusiastic about explosives. Chief Kah Kah had given the Horde a foothold, but Nazgrim still needed scouts, maps, and pressure against the Alliance. Rivett sent messages through ridiculous means, Shokia and the scouts reported enemy positions, and the Horde learned how the jinyu, SI:7, and Alliance soldiers fit together. By the end, Guerrillas in our Midst became Burning Down the House. The hozen pact held, and the road to Dawn's Blossom opened through smoke.",
            quests = {
                { id = 29936, name = "Instant Messaging", npc = "Chief Kah Kah" },
                { id = 29941, name = "Beyond the Horizon", npc = "General Nazgrim" },
                { id = 29937, name = "Furious Fowl", npc = "Rivett Clutchpop" },
                { id = 31239, name = "What's in a Name Name?", npc = "Chief Kah Kah", optional = true },
                { id = 29939, name = "Boom Bait", npc = "Rivett Clutchpop" },
                { id = 29942, name = "Silly Wikket, Slickies are for Hozen", npc = "Eekle Eekle", optional = true },
                { id = 29971, name = "The Scouts Return", npc = "Rivett Clutchpop" },
                { id = 29730, name = "Scouting Report: Hostile Natives", npc = "Riko" },
                { id = 29731, name = "Scouting Report: On the Right Track", npc = "Shademaster Kiryn" },
                { id = 29823, name = "Scouting Report: The Friend of My Enemy", npc = "Riko" },
                { id = 29824, name = "Scouting Report: Like Jinyu in a Barrel", npc = "Shokia" },
                { id = 29943, name = "Guerrillas in our Midst", npc = "General Nazgrim" },
                { id = 29968, name = "Green-ish Energy", npc = "Rivett Clutchpop", optional = true },
                { id = 29966, name = "Burning Down the House", npc = "General Nazgrim" },
                { id = 29967, name = "Boom Goes the Doonamite!", npc = "Rivett Clutchpop", optional = true },
            },
        },

        -- =================================================================
        -- SHARED: Dawn's Blossom
        -- =================================================================
        {
            chapter = "Dawn's Blossom",
            summary = "Both factions arrive at Dawn's Blossom and begin helping the pandaren whose lives are caught between war, family, and old magic.",
            recap = "Dawn's Blossom slowed the campaign down long enough for you to see the people under it. Cho, Toya, and the villagers asked for something different than victory. An Windfur's missing cubs led to the Jade Witch and a curse hiding behind a grandmother's smile. The Goldendraft and Wanderbrew families needed courage more than soldiers, and the Arboretum needed ink, color, and permission before a marriage could heal an old feud. It was not a detour. It was the point: Pandaria was full of lives that had nothing to do with the Alliance or Horde until the war made everything their problem.",
            quests = {
                { id = 29922, name = "In Search of Wisdom", npc = "Elder Lusshan", faction = "Alliance" },
                { id = 30015, name = "Dawn's Blossom", npc = "General Nazgrim", faction = "Horde" },
                { id = 31230, name = "Welcome to Dawn's Blossom", npc = "Toya" },
                { id = 29716, name = "The Double Hozen Dare", npc = "An Windfur" },
                { id = 29717, name = "Down Kitty!", npc = "An Windfur" },
                { id = 29723, name = "The Jade Witch", npc = "An Windfur" },
                { id = 29866, name = "The Threads that Stick", npc = "Lo Wanderbrew" },
                { id = 29865, name = "The Silkwood Road", npc = "Tzu the Ironbelly", optional = true },
                { id = 29993, name = "Find the Boy", npc = "Kai Wanderbrew" },
                { id = 29995, name = "Shrine of the Dawn", npc = "Inkmaster Wei" },
                { id = 29920, name = "Getting Permission", npc = "Syra Goldendraft" },
                { id = 29925, name = "All We Can Spare", npc = "Toya" },
            },
        },

        -- =================================================================
        -- SHARED: Tian Monastery
        -- =================================================================
        {
            chapter = "Tian Monastery",
            summary = "At Tian Monastery, training means discipline, hospitality, a proper weapon, and learning not to solve every problem as a soldier.",
            recap = "Tian Monastery offered a different kind of strength. You entered as a guest, sat at the banquet, then trained under masters who cared as much about patience as power. You made a weapon with Groundskeeper Wu, learned precision from Instructor Xann, faced sparring partners who turned humility into bruises, and endured the Rumpus without mistaking chaos for victory. Flying Colors was more than a graduation. It was Pandaria quietly asking whether you could be taught.",
            quests = {
                { id = 29617, name = "Tian Monastery", npc = "Lin Tenderpaw", optional = true },
                { id = 29618, name = "The High Elder", npc = "Lin Tenderpaw" },
                { id = 29619, name = "A Courteous Guest", npc = "Lin Tenderpaw" },
                { id = 29620, name = "The Great Banquet", npc = "Lin Tenderpaw" },
                { id = 29626, name = "Groundskeeper Wu", npc = "Xiao" },
                { id = 29627, name = "A Proper Weapon", npc = "Groundskeeper Wu" },
                { id = 29628, name = "A Strong Back", npc = "Groundskeeper Wu" },
                { id = 29629, name = "A Steady Hand", npc = "Groundskeeper Wu" },
                { id = 29630, name = "And a Heavy Fist", npc = "Groundskeeper Wu" },
                { id = 29622, name = "Your Training Starts Now", npc = "Xiao" },
                { id = 29623, name = "Perfection", npc = "Instructor Xann" },
                { id = 29624, name = "Attention", npc = "Instructor Xann" },
                { id = 29632, name = "Becoming Battle-Ready", npc = "Master Stone Fist" },
                { id = 29633, name = "Zhi-Zhi, the Dextrous", npc = "Master Stone Fist" },
                { id = 29634, name = "Husshun, the Wizened", npc = "Master Stone Fist" },
                { id = 29635, name = "Xiao, the Eater", npc = "Master Stone Fist" },
                { id = 29636, name = "A Test of Endurance", npc = "Master Stone Fist" },
                { id = 29637, name = "The Rumpus", npc = "Instructor Myang" },
                { id = 29647, name = "Flying Colors", npc = "High Elder Cloudfall" },
            },
        },

        -- =================================================================
        -- SHARED: Orchard and Quarry
        -- =================================================================
        {
            chapter = "Orchard and Quarry",
            summary = "Mogu raiders, exhausted farmers, trapped miners, and a starving jade project show what the forest needs before Yu'lon can return.",
            recap = "Nectarbreeze Orchard was not a battlefield until the mogu made it one. Shao the Defiant and Gentle Mother Hanae needed survivors rallied, hardware recovered, and slavers driven off before the orchard became another wound. From there the road bent toward Emperor's Omen and Greenstone Quarry, where the Serpent's Heart had stalled. Foreman Mann had no jade, Hao Mann was trapped, and the miners were running on fear. By freeing farmers, saving workers, and bringing jade back to the statue, you helped the forest rebuild something sacred while the armies outside kept finding reasons to break things.",
            quests = {
                { id = 29576, name = "An Air of Worry", npc = "Old Man Misteye", optional = true },
                { id = 29578, name = "Defiance", npc = "Shao the Defiant" },
                { id = 29579, name = "Rally the Survivors", npc = "Shao the Defiant" },
                { id = 29585, name = "Spitfire", npc = "Gentle Mother Hanae" },
                { id = 29580, name = "Orchard-Supplied Hardware", npc = "Gentle Mother Hanae" },
                { id = 29586, name = "The Splintered Path", npc = "Traumatized Nectarbreeze Farmer" },
                { id = 29587, name = "Unbound", npc = "Shao the Defiant" },
                { id = 29670, name = "Maul Gormal", npc = "Shao the Defiant" },
                { id = 29928, name = "I Have No Jade And I Must Scream", npc = "Foreman Mann" },
                { id = 29927, name = "Mann's Man", npc = "Foreman Mann" },
                { id = 29929, name = "Trapped!", npc = "Hao Mann" },
                { id = 29926, name = "Calamity Jade", npc = "Foreman Mann", optional = true },
                { id = 29930, name = "What's Mined Is Yours", npc = "Hao Mann" },
                { id = 29931, name = "The Serpent's Heart", npc = "Foreman Mann" },
                { id = 30495, name = "Love's Labor", npc = "Foreman Raike" },
            },
        },

        -- =================================================================
        -- SHARED: Terrace of Ten Thunders
        -- =================================================================
        {
            chapter = "Terrace of Ten Thunders",
            summary = "A dying sprite's plea reveals mogu rituals at the Terrace of Ten Thunders and the spirits trapped beneath them.",
            recap = "At the northern edge of the forest, a wounded sprite led you into an older, stranger grief. The mogu had bound spirits into vessels, rituals, and stone. Pei-Zhi needed those cycles broken before the dead were consumed by someone else's ambition. You shattered simulacrums, gathered ritual artifacts, released wayward spirits, returned beasts to nature, and offered the humility the terrace demanded. To bridge earth and sky, you had to answer the past without trying to own it.",
            quests = {
                { id = 29745, name = "The Sprites' Plight", npc = "Outcast Sprite" },
                { id = 29747, name = "Break the Cycle", npc = "Outcast Sprite" },
                { id = 29748, name = "Simulacrumble", npc = "Shattered Destroyer" },
                { id = 29749, name = "An Urgent Plea", npc = "Outcast Sprite" },
                { id = 29751, name = "Ritual Artifacts", npc = "Pei-Zhi" },
                { id = 29750, name = "Vessels of the Spirit", npc = "Pei-Zhi" },
                { id = 29752, name = "The Wayward Dead", npc = "Pei-Zhi" },
                { id = 29753, name = "Back to Nature", npc = "Pei-Zhi" },
                { id = 29756, name = "A Humble Offering", npc = "Pei-Zhi" },
                { id = 29754, name = "To Bridge Earth and Sky", npc = "Pei-Zhi" },
            },
        },

        -- =================================================================
        -- SHARED: The Temple of the Jade Serpent
        -- =================================================================
        {
            chapter = "The Temple of the Jade Serpent",
            summary = "With the Serpent's Heart restored, you travel to Yu'lon's temple and help the sages prepare for her rebirth.",
            recap = "The Serpent's Heart gave the temple the jade it needed, but Yu'lon could not simply appear on command. Elder Sage Rain-Zhu sent you through the temple's doubts and duties: Wise Mari's scrying, Lorewalker Stonestep's living library, Fei's cloud serpents, and the fireworks that would light the sky for a rebirth. At last Yu'lon emerged, ancient and luminous, and thanked you for helping the forest remember hope. For a moment, it felt like the war might be smaller than the wonder around it.",
            quests = {
                { id = 29932, name = "The Temple of the Jade Serpent", npc = "Foreman Raike" },
                { id = 29997, name = "The Scryer's Dilemma", npc = "Elder Sage Rain-Zhu" },
                { id = 30011, name = "A New Vision", npc = "Wise Mari" },
                { id = 29998, name = "The Librarian's Quandary", npc = "Elder Sage Rain-Zhu" },
                { id = 30001, name = "Moth-Ridden", npc = "Lorewalker Stonestep" },
                { id = 30002, name = "Pages of History", npc = "Lorewalker Stonestep" },
                { id = 30004, name = "Everything In Its Place", npc = "Lorewalker Stonestep" },
                { id = 29999, name = "The Rider's Bind", npc = "Fei" },
                { id = 30005, name = "Lighting Up the Sky", npc = "Fei" },
                { id = 30000, name = "The Jade Serpent", npc = "Fei" },
            },
        },

        -- =================================================================
        -- SHARED: Overcoming Doubt
        -- =================================================================
        {
            chapter = "Overcoming Doubt",
            summary = "The faction war reaches the Serpent's Heart, shatters the seal, and releases the Sha of Doubt.",
            recap = "Yu'lon's rebirth did not end the war. It only made the cost clearer. The Alliance returned to Pearlfin Village; the Horde returned to Grookin Hill. Both sides prepared their local allies for the next blow, and Cho called for help with the last piece of an ancient puzzle. Then the seal broke. The Serpent's Heart cracked under the weight of fear, anger, and suspicion. Jade became weapon and prison, friends were scattered in the fallout, and the Sha of Doubt rose from the ruin. The Jade Forest's lesson had become impossible to ignore: the enemy was not only across the battlefield.",
            quests = {
                { id = 30498, name = "Get Back Here!", npc = "Elder Sage Wind-Yi", faction = "Alliance" },
                { id = 30565, name = "An Unexpected Advantage", npc = "Sully \"The Pickle\" McLeary", faction = "Alliance" },
                { id = 30568, name = "Helping the Cause", npc = "Admiral Taylor", faction = "Alliance" },
                { id = 31362, name = "Last Piece of the Puzzle", npc = "Lorewalker Cho", faction = "Alliance" },
                { id = 30499, name = "Get Back Here!", npc = "Elder Sage Wind-Yi", faction = "Horde" },
                { id = 30466, name = "Sufficient Motivation", npc = "General Nazgrim", faction = "Horde" },
                { id = 30484, name = "Gauging Our Progress", npc = "General Nazgrim", faction = "Horde" },
                { id = 30485, name = "Last Piece of the Puzzle", npc = "Lorewalker Cho", faction = "Horde" },
                { id = 31303, name = "The Seal is Broken", npc = "Lorewalker Cho" },
                { id = 30500, name = "Residual Fallout", npc = "Lorewalker Cho" },
                { id = 30502, name = "Jaded Heart", npc = "Lorewalker Cho" },
                { id = 31319, name = "Emergency Response", npc = "Lorewalker Cho", faction = "Alliance" },
                { id = 30504, name = "Emergency Response", npc = "Lorewalker Cho", faction = "Horde" },
                { id = 30648, name = "Moving On", npc = "Fei" },
            },
        },

        -- =================================================================
        -- SHARED: Temple of the Jade Serpent
        -- Dungeon Finale
        -- =================================================================
        {
            chapter = "Temple of the Jade Serpent",
            dungeon = true,
            summary = "Enter the dungeon, cleanse Yu'lon's sacred temple, and destroy the Sha of Doubt where it has taken root.",
            recap = "The zone ends where its warning began: inside the Temple of the Jade Serpent. The sha has seeped into wisdom, memory, discipline, and flame. Wise Mari, Lorewalker Stonestep, Liu Flameheart, and the temple's defenders are all trapped in doubt's reflection. By cleansing the temple and defeating the Sha of Doubt, you do what the armies outside could not: stop feeding the darkness long enough to face it. The Jade Forest is not untouched anymore. It is wounded, changed, and still alive.",
            quests = {
                { id = 31355, name = "Restoring Jade's Purity", npc = "Yu'lon" },
            },
        },
    },
}

return SM
