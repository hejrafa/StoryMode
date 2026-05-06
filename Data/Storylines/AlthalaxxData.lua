local addonName, SM = ...

-- =============================================================================
-- Classic: The Tower of Althalaxx
-- Darkshore and Ashenvale's Cult of the Dark Strand chain.
-- =============================================================================

SM.AlthalaxxData = {
    title = "The Tower of Althalaxx",
    description = "Auberdine sends a scout north to watch a lonely tower, and the report that comes back is worse than anyone hoped. Warlocks of the Cult of the Dark Strand are gathering around Althalaxx, with their trail reaching from Darkshore into Ashenvale.\n\nFollow Balthule Shadowstrike and Delgren the Purifier through parchments, soul gems, satyr ruins, and the final climb to Athrikus Narassin.",
    zone = "Darkshore / Ashenvale",
    expansion = "Classic",
    recommendedLevel = { min = 13, max = 31 },
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.38, 0.50, 0.64 },
    icon = 136145,
    adventureCoverTexture = 131878, -- Blackfathom Deeps loading screen; closest dark Night Elf ruin art
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 965, name = "The Tower of Althalaxx", npc = "Sentinel Elissa Starbreeze", location = "Auberdine, Darkshore" },
    startMapID = 62,
    startX = 0.3700,
    startY = 0.4400,

    npcLocations = {
        ["Sentinel Elissa Starbreeze"] = { mapID = 62, x = 0.3700, y = 0.4400, location = "Auberdine, Darkshore" },
        ["Balthule Shadowstrike"] = { mapID = 62, x = 0.5500, y = 0.2400, location = "near the Tower of Althalaxx, Darkshore" },
        ["Delgren the Purifier"] = { mapID = 63, x = 0.2660, y = 0.3830, location = "Maestra's Post, Ashenvale" },
        ["Ordil'Aran"] = { mapID = 63, x = 0.3100, y = 0.3100, location = "Ordil'Aran, Ashenvale" },
        ["Fire Scar Shrine"] = { mapID = 63, x = 0.2500, y = 0.6100, location = "Fire Scar Shrine, Ashenvale" },
        ["Night Run"] = { mapID = 63, x = 0.6600, y = 0.5600, location = "Night Run, Ashenvale" },
        ["Satyrnaar"] = { mapID = 63, x = 0.8100, y = 0.4900, location = "Satyrnaar, Ashenvale" },
        ["Athrikus Narassin"] = { mapID = 62, x = 0.5500, y = 0.2400, location = "the Tower of Althalaxx, Darkshore" },
    },

    npcDisplayIDs = {
        ["Sentinel Elissa Starbreeze"] = 2209,
        ["Balthule Shadowstrike"] = 2181,
        ["Delgren the Purifier"] = 2256,
        ["Athrikus Narassin"] = 2362,
    },

    chapterDisplayIDs = {
        ["The Dark Strand"] = 2181,
        ["Ashenvale Soul Gems"] = 2256,
        ["Athrikus Narassin"] = 2362,
    },

    chapterIcons = {
        ["The Dark Strand"] = 136145,
        ["Ashenvale Soul Gems"] = 136157,
        ["Athrikus Narassin"] = 136163,
    },

    chapters = {
        {
            chapter = "The Dark Strand",
            summary = "Auberdine asks you to find Balthule Shadowstrike near the Tower of Althalaxx, where warlocks have begun gathering in force.",
            recap = "At first, the tower was only a worry on the edge of Darkshore. Sentinel Elissa Starbreeze had sent Balthule Shadowstrike to watch it, and he had not returned. Balthule was alive, but his news was grim: warlocks had taken the tower, and their parchments named a cult he did not understand. The message had to reach Delgren the Purifier in Ashenvale before the Dark Strand's work ripened into something worse.",
            quests = {
                { id = 965, name = "The Tower of Althalaxx", displayName = "Find Balthule", npc = "Sentinel Elissa Starbreeze" },
                { id = 966, name = "The Tower of Althalaxx", displayName = "Worn Parchments", npc = "Balthule Shadowstrike" },
                { id = 967, name = "The Tower of Althalaxx", displayName = "Letter to Delgren", npc = "Balthule Shadowstrike" },
            },
        },
        {
            chapter = "Ashenvale Soul Gems",
            summary = "Delgren follows the cult into Ashenvale, from Ordil'Aran to Fire Scar Shrine, Night Run, and Satyrnaar.",
            recap = "Delgren understood the shape of the threat at once. The Dark Strand had allies and artifacts scattered through Ashenvale: a soul gem at Ordil'Aran, Ilkrud Magthrull's writings at Fire Scar Shrine, and Highborne souls trapped in satyr places that remembered older sins. Each shard of the trail weakened Athrikus Narassin's hold and made the return to the tower inevitable.",
            quests = {
                { id = 970, name = "The Tower of Althalaxx", displayName = "Glowing Soul Gem", npc = "Delgren the Purifier" },
                { id = 973, name = "The Tower of Althalaxx", displayName = "Ilkrud Magthrull's Tome", npc = "Delgren the Purifier" },
                { id = 1140, name = "The Tower of Althalaxx", displayName = "Highborne Souls", npc = "Delgren the Purifier" },
                { id = 1167, name = "The Tower of Althalaxx", displayName = "Return to Balthule", npc = "Delgren the Purifier" },
            },
        },
        {
            chapter = "Athrikus Narassin",
            summary = "With Athrikus weakened, Balthule sends you back into the tower to kill the warlock at its summit.",
            recap = "The screams and lightning from the tower left little mystery. Athrikus Narassin was exposed, weakened, and still dangerous. Balthule sent you into the tower itself, past the warlocks who had made Althalaxx their sanctuary. Athrikus died where the cult had gathered, and Delgren's final blessing turned a strange errand from Auberdine into one of the first great victories of the Night Elf lands.",
            quests = {
                { id = 1143, name = "The Tower of Althalaxx", displayName = "Athrikus Narassin", npc = "Balthule Shadowstrike" },
                { id = 981, name = "The Tower of Althalaxx", displayName = "Report to Delgren", npc = "Balthule Shadowstrike" },
            },
        },
    },
}
