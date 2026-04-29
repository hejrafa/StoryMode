local addonName, SM = ...

-- =============================================================================
-- Classic: The Scarlet Crusade
-- Forsaken warfront, Alliance investigation, Scarlet Monastery, and Hearthglen.
-- =============================================================================

SM.ScarletCrusadeData = {
    title = "The Scarlet Crusade",
    description = "The Scarlet Crusade calls itself the last pure flame of Lordaeron, but its crusade burns everyone it touches: Forsaken farmers, human dissenters, prisoners in the Monastery, and even its own sons.\n\nFollow the Scarlet trail from Deathknell and Southshore into Scarlet Monastery, through Stratholme's Scarlet Bastion, and north to Hearthglen, where Tirion Fordring tries to save Taelan from the order's fanatic heart.",
    zone = "Tirisfal / Monastery / Stratholme / Plaguelands",
    expansion = "Classic",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.82, 0.10, 0.12 },
    icon = 135926,
    adventureGuideInstanceName = "Scarlet Monastery",
    adventureCoverTexture = 645156,
    adventureCoverIsLoadingScreen = true,

    startMapID = 18,
    startX = 0.3100,
    startY = 0.6600,

    npcLocations = {
        ["Deathguard Simmer"] = { mapID = 18, x = 0.3060, y = 0.6600, location = "Deathknell, Tirisfal Glades" },
        ["Executor Arren"] = { mapID = 18, x = 0.3260, y = 0.6500, location = "Deathknell, Tirisfal Glades" },
        ["Executor Zygand"] = { mapID = 18, x = 0.6020, y = 0.5200, location = "Brill, Tirisfal Glades" },
        ["Varimathras"] = { mapID = 90, x = 0.5600, y = 0.9200, location = "the Royal Quarter, Undercity" },
        ["Master Apothecary Faranell"] = { mapID = 90, x = 0.4800, y = 0.6900, location = "the Apothecarium, Undercity" },
        ["Sage Truthseeker"] = { mapID = 88, x = 0.3400, y = 0.4700, location = "Thunder Bluff" },
        ["Brother Crowley"] = { mapID = 84, x = 0.4300, y = 0.2400, location = "Cathedral Square, Stormwind" },
        ["Brother Anton"] = { mapID = 66, x = 0.6600, y = 0.0700, location = "Nijel's Point, Desolace" },
        ["Raleigh the Devout"] = { mapID = 25, x = 0.5150, y = 0.5850, location = "Southshore, Hillsbrad Foothills" },
        ["Librarian Mae Paledust"] = { mapID = 87, x = 0.7450, y = 0.1200, location = "the Hall of Explorers, Ironforge" },
        ["Vorrel Sengutz"] = { mapID = 435, x = 0.4500, y = 0.5600, location = "the Scarlet Monastery Graveyard" },
        ["Monika Sengutz"] = { mapID = 25, x = 0.6200, y = 0.1900, location = "Tarren Mill, Hillsbrad Foothills" },
        ["Interrogator Vishas"] = { mapID = 435, x = 0.4500, y = 0.5600, location = "the Scarlet Monastery Graveyard" },
        ["Arcanist Doan"] = { mapID = 435, x = 0.6500, y = 0.2600, location = "the Scarlet Monastery Library" },
        ["Houndmaster Loksey"] = { mapID = 435, x = 0.7000, y = 0.3200, location = "the Scarlet Monastery Library" },
        ["Herod"] = { mapID = 435, x = 0.3300, y = 0.4100, location = "the Scarlet Monastery Armory" },
        ["Scarlet Commander Mograine"] = { mapID = 435, x = 0.4900, y = 0.1300, location = "the Scarlet Monastery Cathedral" },
        ["High Inquisitor Whitemane"] = { mapID = 435, x = 0.4900, y = 0.1300, location = "the Scarlet Monastery Cathedral" },
        ["High Executor Derrington"] = { mapID = 22, x = 0.8300, y = 0.6900, location = "the Bulwark, Tirisfal Glades" },
        ["Commander Ashlam Valorfist"] = { mapID = 22, x = 0.4300, y = 0.8400, location = "Chillwind Camp, Western Plaguelands" },
        ["Tirion Fordring"] = { mapID = 23, x = 0.0700, y = 0.4300, location = "Tirion's cottage, Eastern Plaguelands" },
        ["Artist Renfray"] = { mapID = 22, x = 0.6500, y = 0.7500, location = "Caer Darrow, Western Plaguelands" },
        ["Myranda the Hag"] = { mapID = 22, x = 0.5100, y = 0.7800, location = "Sorrow Hill, Western Plaguelands" },
        ["Taelan Fordring"] = { mapID = 22, x = 0.4600, y = 0.1900, location = "Hearthglen, Western Plaguelands" },
    },

    npcDisplayIDs = {
        ["Executor Zygand"] = 1649,
        ["Varimathras"] = 11658,
        ["Brother Anton"] = 2070,
        ["Raleigh the Devout"] = 4518,
        ["Librarian Mae Paledust"] = 2049,
        ["Vorrel Sengutz"] = 1491,
        ["Interrogator Vishas"] = 2044,
        ["Arcanist Doan"] = 2046,
        ["Houndmaster Loksey"] = 2040,
        ["Herod"] = 2041,
        ["Scarlet Commander Mograine"] = 2042,
        ["High Inquisitor Whitemane"] = 2043,
        ["Tirion Fordring"] = 9477,
        ["Taelan Fordring"] = 10341,
    },

    chapterDisplayIDs = {
        ["Deathknell's Red Messenger"] = 1649,
        ["The Brill Campaign"] = 1649,
        ["The Scarlet Path"] = 2070,
        ["Graveyard and Library"] = 2046,
        ["Armory and Cathedral"] = 2043,
        ["The Fordring Name"] = 9477,
    },

    chapterIcons = {
        ["Deathknell's Red Messenger"] = 135926,
        ["The Brill Campaign"] = 135926,
        ["The Scarlet Path"] = 135923,
        ["Graveyard and Library"] = 134939,
        ["Armory and Cathedral"] = 132331,
        ["The Fordring Name"] = 135984,
    },

    chapters = {
        {
            chapter = "Deathknell's Red Messenger",
            faction = "Horde",
            summary = "The newly risen Forsaken meet the Scarlet Crusade almost immediately. A red messenger rides out of Deathknell carrying word that the undead have awakened.",
            recap = "Deathknell taught the Forsaken their first lesson about Lordaeron's living survivors: the Scarlet Crusade did not see people, only infection. Deathguard Simmer sent you against Scarlet converts and their courier. Executor Arren read the stolen intelligence and understood the warning. The Crusade was watching Deathknell, counting the dead, and preparing for war.",
            quests = {
                { id = 381, name = "The Scarlet Crusade", npc = "Deathguard Simmer" },
                { id = 382, name = "The Red Messenger", npc = "Deathguard Simmer" },
                { id = 383, name = "Vital Intelligence", npc = "Executor Arren" },
            },
        },
        {
            chapter = "The Brill Campaign",
            faction = "Horde",
            summary = "Brill turns the Deathknell warning into an open campaign. Executor Zygand sends you into the Scarlet camps west of town until Captain Vachon falls.",
            recap = "By the time you reached Brill, the Scarlet Crusade was no rumor. Their camps pressed close to Forsaken roads, their officers pushed deeper into Tirisfal, and their captain meant to make the dead kneel or burn. Executor Zygand answered with a simple order repeated until the threat broke: strike the camps, kill the officers, and leave the Crusade no safe foothold near Brill.",
            quests = {
                { id = 427, name = "At War With The Scarlet Crusade", displayName = "Scarlet Encampment", npc = "Executor Zygand" },
                { id = 370, name = "At War With The Scarlet Crusade", displayName = "Scarlet Officers", npc = "Executor Zygand" },
                { id = 371, name = "At War With The Scarlet Crusade", displayName = "Scarlet Watch Post", npc = "Executor Zygand" },
                { id = 372, name = "At War With The Scarlet Crusade", displayName = "Captain Vachon", npc = "Executor Zygand" },
            },
        },
        {
            chapter = "The Scarlet Path",
            faction = "Alliance",
            summary = "Alliance priests follow reports of Scarlet activity from Stormwind to Desolace and Southshore. Raleigh the Devout turns the investigation toward the Monastery.",
            recap = "For the Alliance, the Scarlet Crusade first looked like a distant Lordaeron problem: troubling enough for Brother Crowley to send word to Brother Anton, and troubling enough for Anton to send you onward. Raleigh the Devout understood what the red tabards meant. The Monastery was not merely a garrison. It was the heart of a militant faith losing its way.",
            quests = {
                { id = 6141, name = "Brother Anton", npc = "Brother Crowley" },
                { id = 261, name = "Down the Scarlet Path", displayName = "Find Brother Anton", npc = "Brother Anton" },
                { id = 1052, name = "Down the Scarlet Path", displayName = "Report to Raleigh", npc = "Brother Anton" },
            },
        },
        {
            chapter = "Graveyard and Library",
            summary = "The Monastery's outer wings reveal prisoners, stolen histories, and a crusade that polices memory as fiercely as it hunts the undead.",
            recap = "The Graveyard and Library showed the Crusade's machinery from the inside. Vorrel Sengutz lay tortured by Interrogator Vishas. Scholars wanted books the Crusade had locked away. Horde agents wanted the Compendium of the Fallen; Alliance scholars wanted the Mythology of the Titans. Every shelf and cell told the same story: the Scarlet Crusade did not only kill enemies. It controlled what its followers were allowed to know.",
            quests = {
                { id = 1051, name = "Vorrel's Revenge", npc = "Vorrel Sengutz" },
                { id = 1049, name = "Compendium of the Fallen", npc = "Sage Truthseeker", faction = "Horde" },
                { id = 1050, name = "Mythology of the Titans", npc = "Librarian Mae Paledust", faction = "Alliance" },
                { id = 1113, name = "Hearts of Zeal", npc = "Master Apothecary Faranell", faction = "Horde", optional = true },
            },
        },
        {
            chapter = "Armory and Cathedral",
            summary = "The Crusade's champions wait deeper within: Houndmaster Loksey, Herod, Mograine, and Whitemane. The Monastery becomes a judgment hall.",
            recap = "The Armory and Cathedral were the Crusade's sermon made flesh. Houndmaster Loksey guarded the Library with trained violence. Herod turned recruits into fanatics through spectacle and blood. In the Cathedral, Scarlet Commander Mograine and High Inquisitor Whitemane embodied the order's beautiful lie: holy words wrapped around endless war. Whether sent by Varimathras or Raleigh, you cut through the Monastery's saints and executioners alike.",
            quests = {
                { id = 1048, name = "Into The Scarlet Monastery", npc = "Varimathras", faction = "Horde" },
                { id = 1053, name = "In the Name of the Light", npc = "Raleigh the Devout", faction = "Alliance" },
            },
        },
        {
            chapter = "The Fordring Name",
            summary = "In the Plaguelands, the Scarlet Crusade's tragedy narrows to one family. Tirion Fordring sends you through Stratholme's Scarlet Bastion and risks everything to reach Taelan inside Hearthglen.",
            recap = "The Plaguelands proved the Crusade had become more than a monastery. Scarlet banners flew over towers and towns, Stratholme's living quarter hid the Fordring family painting, and Hearthglen stood as a fortress of certainty. Tirion Fordring, exiled and alone, still believed his son could be saved from it. Forgotten memories, lost honor, and the painting became weapons against indoctrination. Disguised as Scarlet, you reached Taelan and watched him remember who he was before the Crusade taught him whom to hate.",
            quests = {
                { id = 5096, name = "Scarlet Diversions", npc = "High Executor Derrington", faction = "Horde" },
                { id = 5097, name = "All Along the Watchtowers", npc = "Commander Ashlam Valorfist", faction = "Alliance", optional = true },
                { id = 5098, name = "All Along the Watchtowers", npc = "High Executor Derrington", faction = "Horde", optional = true },
                { id = 5742, name = "Redemption", npc = "Tirion Fordring" },
                { id = 5781, name = "Of Forgotten Memories", npc = "Tirion Fordring" },
                { id = 5845, name = "Of Lost Honor", npc = "Tirion Fordring" },
                { id = 5846, name = "Of Love and Family", displayName = "The Painting", npc = "Tirion Fordring" },
                { id = 5848, name = "Of Love and Family", displayName = "A Father's Hope", npc = "Artist Renfray" },
                { id = 5861, name = "Find Myranda", npc = "Tirion Fordring" },
                { id = 5862, name = "Scarlet Subterfuge", npc = "Myranda the Hag" },
                { id = 5944, name = "In Dreams", npc = "Taelan Fordring" },
            },
        },
    },
}
