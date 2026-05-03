local addonName, SM = ...

-- =============================================================================
-- Classic: The Agamand Family
-- A short Forsaken story at the Agamand Mills outside Brill.
-- =============================================================================

SM.AgamandFamilyData = {
    title = "The Agamand Family",
    description = "North of Brill, the Agamand Mills still carry the family name, but the family itself has become part of Tirisfal's dead. Coleman Farthing wants proof, Deathguard Dillinger wants the mills cleared, and Magistrate Sevren knows the family crypt has not been quiet either.\n\nRecover the remains of Devlin, Nissa, Thurman, and Gregor Agamand, then descend into the crypt where the old dead of the estate still wail under the earth.",
    zone = "Tirisfal Glades",
    expansion = "Classic",
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.46, 0.56, 0.44 },
    icon = 136123,
    portraitDisplayID = 3516,
    adventureCoverTexture = 131867, -- Ruins of Lordaeron battleground loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 404, name = "A Putrid Task", npc = "Deathguard Dillinger", location = "Brill, Tirisfal Glades" },
    startMapID = 18,
    startX = 0.5820,
    startY = 0.5145,

    npcLocations = {
        ["Deathguard Dillinger"] = { mapID = 18, x = 0.5820, y = 0.5145, location = "Brill, Tirisfal Glades" },
        ["Coleman Farthing"] = { mapID = 18, x = 0.6172, y = 0.5229, location = "Gallows' End Tavern, Brill" },
        ["Magistrate Sevren"] = { mapID = 18, x = 0.6126, y = 0.5084, location = "Brill, Tirisfal Glades" },
        ["Yvette Farthing"] = { mapID = 18, x = 0.6130, y = 0.5270, location = "Gallows' End Tavern, Brill" },
        ["Devlin Agamand"] = { mapID = 18, x = 0.4734, y = 0.4078, location = "Agamand Mills, Tirisfal Glades" },
        ["Gregor Agamand"] = { mapID = 18, x = 0.4674, y = 0.2931, location = "Agamand Mills, Tirisfal Glades" },
        ["Nissa Agamand"] = { mapID = 18, x = 0.4974, y = 0.3634, location = "Agamand Mills, Tirisfal Glades" },
        ["Thurman Agamand"] = { mapID = 18, x = 0.4400, y = 0.3364, location = "Agamand Mills, Tirisfal Glades" },
        ["Captain Dargol"] = { mapID = 18, x = 0.5281, y = 0.2635, location = "the Agamand Family Crypt, Tirisfal Glades" },
    },

    npcDisplayIDs = {
        ["Deathguard Dillinger"] = 2855,
        ["Coleman Farthing"] = 3516,
        ["Magistrate Sevren"] = 3514,
        ["Yvette Farthing"] = 3517,
        ["Devlin Agamand"] = 11399,
        ["Gregor Agamand"] = 646,
        ["Nissa Agamand"] = 10702,
        ["Thurman Agamand"] = 1196,
        ["Captain Dargol"] = 733,
    },

    chapterDisplayIDs = {
        ["The Haunted Mills"] = 3516,
        ["The Family Crypt"] = 3514,
    },

    chapterIcons = {
        ["The Haunted Mills"] = 136123,
        ["The Family Crypt"] = 136129,
    },

    chapters = {
        {
            chapter = "The Haunted Mills",
            summary = "Brill sends you north to the Agamand Mills, where the dead are stripping bones clean and the Agamand children still wander their ruined home.",
            recap = "The Agamand Mills were not abandoned so much as inherited by the dead. Deathguard Dillinger wanted the bones and skulls cleared from the grounds, while Coleman Farthing wanted the remains of the family itself: Devlin first, then Gregor, Nissa, and Thurman. Each return made the story smaller and sadder. These were not nameless undead at the edge of town. They were a household, still trapped under their own sign.",
            quests = {
                { id = 404, name = "A Putrid Task", npc = "Deathguard Dillinger" },
                { id = 426, name = "The Mills Overrun", npc = "Deathguard Dillinger" },
                { id = 362, name = "The Haunted Mills", npc = "Coleman Farthing" },
                { id = 354, name = "Deaths in the Family", npc = "Coleman Farthing" },
                { id = 361, name = "A Letter Undelivered", npc = "Yvette Farthing", optional = true },
            },
        },
        {
            chapter = "The Family Crypt",
            summary = "Coleman sends you to Magistrate Sevren, who points below the mills to the family crypt and Captain Dargol's skull.",
            recap = "Coleman could name the family tragedy, but Sevren knew it had deeper roots. Beneath the mills, the Agamand crypt held older dead: wailing ancestors, rotting ancestors, and Captain Dargol guarding the last piece Sevren needed. The work began as cleanup around Brill and ended as an exorcism of a whole estate, one skull and one set of remains at a time.",
            quests = {
                { id = 355, name = "Speak with Sevren", npc = "Coleman Farthing" },
                { id = 408, name = "The Family Crypt", npc = "Magistrate Sevren" },
            },
        },
    },
}
