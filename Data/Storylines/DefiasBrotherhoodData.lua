local addonName, SM = ...

-- =============================================================================
-- Classic: The Defias Brotherhood
-- Alliance Westfall investigation, Deadmines finale, and Stormwind aftermath.
-- =============================================================================

SM.DefiasBrotherhoodData = {
    title = "The Defias Brotherhood",
    description = "Westfall is collapsing under hunger, neglect, and red masks. Gryan Stoutmantle thinks the Defias are more than a bandit problem, and every errand pulls the thread tighter: Lakeshire, SI:7, the Stonemasons, Moonbrook, and finally the ship hidden beneath the Deadmines.\n\nFollow the Alliance's first great conspiracy story from Sentinel Hill to Edwin VanCleef, then into the letter he never sent and the noble rot still waiting inside Stormwind.",
    zone = "Westfall / Stormwind",
    expansion = "Classic",
    faction = "Alliance",
    requiredLevel = 14,
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.78, 0.16, 0.12 },
    icon = 132153,
    adventureGuideInstanceName = "Deadmines",

    startQuest = { id = 65, name = "The Defias Brotherhood", npc = "Gryan Stoutmantle", location = "Sentinel Hill, Westfall" },
    startMapID = 52,
    startX = 0.5650,
    startY = 0.4750,

    npcLocations = {
        ["Gryan Stoutmantle"] = { mapID = 52, x = 0.5650, y = 0.4750 },
        ["Wiley the Black"] = { mapID = 49, x = 0.2650, y = 0.4500 },
        ["Master Mathias Shaw"] = { mapID = 84, x = 0.7550, y = 0.5900 },
        ["Defias Messenger"] = { mapID = 52, x = 0.4400, y = 0.6900 },
        ["Defias Traitor"] = { mapID = 52, x = 0.5650, y = 0.4750 },
        ["Edwin VanCleef"] = { mapID = 36, x = 0.4500, y = 0.7200 },
        ["Baros Alexston"] = { mapID = 84, x = 0.4900, y = 0.3000 },
        ["Warden Thelwater"] = { mapID = 84, x = 0.4100, y = 0.5800 },
        ["Bazil Thredd"] = { mapID = 34, x = 0.5200, y = 0.5800 },
        ["Trias"] = { mapID = 84, x = 0.7000, y = 0.7350 },
        ["Elling Trias"] = { mapID = 84, x = 0.7000, y = 0.7350 },
        ["Tyrion"] = { mapID = 84, x = 0.6900, y = 0.1400 },
        ["Tyrion's Spybot"] = { mapID = 84, x = 0.6900, y = 0.1400 },
        ["Lord Gregor Lescovar"] = { mapID = 84, x = 0.7400, y = 0.0700 },
        ["Marzon the Silent Blade"] = { mapID = 84, x = 0.7400, y = 0.0700 },
        ["King Varian Wrynn"] = { mapID = 84, x = 0.8000, y = 0.3800 },
    },

    chapterIcons = {
        ["A Favor in Lakeshire"] = 134327,
        ["The Messenger and the Traitor"] = 132486,
        ["VanCleef"] = 132153,
        ["The Unsent Letter"] = 133471,
        ["The Stockade Riots"] = 133146,
        ["Lescovar's Fall"] = 132320,
    },

    chapters = {
        {
            chapter = "A Favor in Lakeshire",
            summary = "Gryan Stoutmantle sends you beyond Westfall to cash in an old favor. Wiley the Black's note turns bandits into a wider conspiracy: gnolls, kobolds, goblins, the Stonemasons, and a secret network reaching toward Stormwind itself.",
            recap = "Sentinel Hill did not have an army to spare, only the People's Militia and a suspicion that Westfall's troubles were connected. Gryan Stoutmantle sent you to Wiley the Black in Lakeshire, who confirmed the Defias were not acting alone. Wiley's note named allies, machinery, hidden routes, and one old word that changed the shape of the case: Stonemasons. Mathias Shaw made the link explicit. Edwin VanCleef, the man who helped rebuild Stormwind and was cheated for it, had become the mind behind the red masks.",
            quests = {
                { id = 65, name = "The Defias Brotherhood", npc = "Gryan Stoutmantle" },
                { id = 132, name = "The Defias Brotherhood", npc = "Wiley the Black" },
                { id = 135, name = "The Defias Brotherhood", npc = "Gryan Stoutmantle" },
                { id = 141, name = "The Defias Brotherhood", npc = "Master Mathias Shaw" },
            },
        },
        {
            chapter = "The Messenger and the Traitor",
            summary = "The investigation returns to Westfall. A Defias Messenger carries the proof Stoutmantle needs, and a captured traitor can lead you straight to the Brotherhood's hidden door in Moonbrook.",
            recap = "Shaw's report gave Gryan a name, but not enough proof. The trail moved back to Westfall's roads, where a Defias Messenger carried word between Moonbrook, the mines, and the quarry. The stolen message revealed the Brotherhood's movement clearly enough for Stoutmantle to use a prisoner of his own. The Defias Traitor walked you through Moonbrook and pointed out the entrance beneath the ruined town. VanCleef was not hiding in the hills. He was building something under Westfall's feet.",
            quests = {
                { id = 142, name = "The Defias Brotherhood", npc = "Gryan Stoutmantle" },
                { id = 155, name = "The Defias Brotherhood", npc = "Defias Traitor" },
            },
        },
        {
            chapter = "VanCleef",
            summary = "The Deadmines are not just a mine. They are a factory, a hideout, and a shipyard. Fight through goblin machines and Defias guards to reach Edwin VanCleef aboard his hidden warship.",
            recap = "The Deadmines revealed the scale of VanCleef's revenge. Behind Moonbrook's broken streets, the Brotherhood had built a fortress of laborers, mercenaries, goblin engineers, harvest watchers, and shipwrights. At its heart waited Edwin VanCleef, not as a roadside bandit, but as a revolutionary captain standing on the deck of a vessel meant for Stormwind. You killed him there and brought his head to Gryan Stoutmantle. Westfall had survived its first crisis, but VanCleef left one more piece behind: an unsent letter.",
            quests = {
                { id = 166, name = "The Defias Brotherhood", npc = "Gryan Stoutmantle" },
            },
        },
        {
            chapter = "The Unsent Letter",
            summary = "VanCleef's letter turns a local victory into a political wound. Baros Alexston remembers the Stonemasons, and Bazil Thredd's riot in the Stockade may expose what VanCleef's lieutenants still know.",
            recap = "The letter from VanCleef was addressed to Baros Alexston, Stormwind's city architect and one of the few people who truly understood the Stonemasons' betrayal. Baros did not defend VanCleef's crimes, but he did not pretend the kingdom's hands were clean. He sent you to Warden Thelwater, where Bazil Thredd had turned the Stockade into a riot. If Thredd knew what remained of VanCleef's plan, the only way to get answers was through the prison blocks.",
            quests = {
                { id = 373, name = "The Unsent Letter", npc = "Edwin VanCleef" },
                { id = 389, name = "Bazil Thredd", npc = "Baros Alexston" },
                { id = 391, name = "The Stockade Riots", npc = "Warden Thelwater" },
            },
        },
        {
            chapter = "The Noble Thread",
            summary = "Thredd's death sends the trail back into Stormwind. A hidden visitor, old friends, and SI:7 work reveal that VanCleef's revenge still has friends inside the city.",
            recap = "Bazil Thredd's head ended the riot, but the Defias trail did not end in the Stockade. Thelwater pointed you toward a strange visitor. Baros sent you to Mathias Shaw. Shaw sent you to Elling Trias, whose quiet cheese shop hid the old habits of an intelligence man. Trias knew someone who could get closer to the truth: Tyrion, an old friend with a spybot, a disguise, and a plan to expose Lord Gregor Lescovar's connection to the Brotherhood.",
            quests = {
                { id = 392, name = "The Curious Visitor", npc = "Warden Thelwater" },
                { id = 393, name = "Shadow of the Past", npc = "Baros Alexston" },
                { id = 350, name = "Look to an Old Friend", npc = "Master Mathias Shaw" },
                { id = 2745, name = "Infiltrating the Castle", npc = "Elling Trias" },
                { id = 2746, name = "Items of Some Consequence", npc = "Tyrion" },
            },
        },
        {
            chapter = "Lescovar's Fall",
            summary = "Tyrion's spybot draws Lescovar and Marzon into the open. Their deaths close the conspiracy, and the report finally reaches the king.",
            recap = "With silk, dye, and a rotten apple, Tyrion prepared the spybot's disguise and baited the meeting. In Stormwind Keep's garden, Lord Gregor Lescovar dismissed his guards and met Marzon the Silent Blade. Their conversation confirmed the Defias connection. You struck before the guards returned, killing both conspirators and carrying the truth back through Trias, Baros, and finally to King Varian Wrynn. The Brotherhood's first great plot was broken, but the story left a harder truth behind: VanCleef's rage had grown from a wound Stormwind chose not to heal.",
            quests = {
                { id = 434, name = "The Attack!", npc = "Tyrion's Spybot" },
                { id = 394, name = "The Head of the Beast", npc = "Elling Trias" },
                { id = 395, name = "Brotherhood's End", npc = "Master Mathias Shaw" },
                { id = 396, name = "An Audience with the King", npc = "Baros Alexston" },
            },
        },
    },
}
