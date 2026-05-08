import { loadDatasets } from "./story-data-utils.mjs";

const positionalArgs = process.argv.slice(2).filter((arg) => !arg.startsWith("--"));
const root = positionalArgs[0] || process.cwd();
const scope = positionalArgs[1] || "";

const MAP_ZONES = new Map([
  [1, ["Durotar", "Bladefist Bay"]],
  [7, ["Mulgore"]],
  [10, ["Barrens", "Northern Barrens"]],
  [18, ["Tirisfal", "Deathknell", "Ruins of Lordaeron"]],
  [21, ["Silverpine"]],
  [23, ["Eastern Plaguelands"]],
  [25, ["Hillsbrad", "Alterac"]],
  [27, ["Dun Morogh"]],
  [36, ["Burning Steppes"]],
  [37, ["Elwynn", "Goldshire", "Eastvale"]],
  [47, ["Duskwood", "Darkshire", "Raven Hill", "Sven"]],
  [48, ["Loch Modan"]],
  [50, ["Stranglethorn", "Booty Bay"]],
  [52, ["Westfall", "Moonbrook"]],
  [56, ["Wetlands", "Menethil"]],
  [57, ["Teldrassil"]],
  [62, ["Darkshore", "Auberdine"]],
  [70, ["Dustwallow"]],
  [71, ["Tanaris", "Gadgetzan", "Caverns of Time", "Steamwheedle"]],
  [76, ["Azshara"]],
  [77, ["Felwood", "Emerald Sanctuary"]],
  [78, ["Un'Goro", "Marshal's Refuge"]],
  [80, ["Moonglade", "Nighthaven"]],
  [81, ["Silithus", "Cenarion Hold", "Scarab Wall"]],
  [83, ["Winterspring"]],
  [84, ["Stormwind"]],
  [85, ["Orgrimmar"]],
  [87, ["Ironforge"]],
  [88, ["Thunder Bluff"]],
  [89, ["Darnassus"]],
  [90, ["Undercity"]],
  [103, ["Exodar"]],
  [111, ["Shattrath"]],
  [115, ["Dragonblight", "Wyrmrest", "Fordragon", "Agmar"]],
  [118, ["Icecrown", "Skybreaker", "Orgrim", "Argent Vanguard", "Ymirheim"]],
  [125, ["Icecrown Citadel", "Forge of Souls", "Pit of Saron"]],
  [220, ["Atal'Hakkar"]],
  [234, ["Dire Maul"]],
  [287, ["Blackwing Lair"]],
  [371, ["Jade Forest", "Dawn's Blossom", "Tian Monastery", "Honeydew", "Paw'don"]],
  [680, ["Suramar"]],
  [862, ["Zuldazar", "Dazar'alor"]],
  [1161, ["Boralus"]],
  [1670, ["Oribos", "Ring of Fates"]],
  [2070, ["Lordaeron"]],
]);

const RACE_FACTION = new Map([
  ["Human", "Alliance"],
  ["Dwarf", "Alliance"],
  ["NightElf", "Alliance"],
  ["Gnome", "Alliance"],
  ["Draenei", "Alliance"],
  ["Worgen", "Alliance"],
  ["DarkIronDwarf", "Alliance"],
  ["Orc", "Horde"],
  ["Scourge", "Horde"],
  ["Tauren", "Horde"],
  ["Troll", "Horde"],
  ["BloodElf", "Horde"],
  ["Goblin", "Horde"],
]);

function values(value) {
  if (!value) return [];
  return Array.isArray(value) ? value : [value];
}

function intersects(a, b) {
  const av = values(a);
  const bv = values(b);
  if (!av.length || !bv.length) return true;
  return av.some((value) => bv.includes(value));
}

function describe(value) {
  return values(value).join(", ");
}

function impliedFaction(race) {
  const factions = new Set(values(race).map((item) => RACE_FACTION.get(item)).filter(Boolean));
  return factions.size === 1 ? [...factions][0] : null;
}

function hasZoneMismatch(mapID, location) {
  if (!mapID || !location) return false;
  if (location.includes("/")) return false;
  const aliases = MAP_ZONES.get(mapID);
  if (!aliases) return false;
  const lower = location.toLowerCase();
  return !aliases.some((alias) => lower.includes(alias.toLowerCase()));
}

const datasets = await loadDatasets(root, scope);
const findings = [];

function addFinding(severity, finding) {
  findings.push({ severity, ...finding });
}

for (const data of datasets) {
  const storyRaceFaction = impliedFaction(data.race);
  if (data.faction && storyRaceFaction && data.faction !== storyRaceFaction) {
    addFinding("error", { type: "story-race-faction-conflict", file: data.rel, story: data.title, faction: data.faction, race: describe(data.race) });
  }

  for (const quest of data.quests) {
    if (quest.storyFaction && quest.faction && quest.storyFaction !== quest.faction) {
      addFinding("error", { type: "story-quest-faction-conflict", file: data.rel, story: data.title, quest: quest.id, storyFaction: quest.storyFaction, questFaction: quest.faction });
    }
    if (quest.chapterFaction && quest.faction && quest.chapterFaction !== quest.faction) {
      addFinding("error", { type: "chapter-quest-faction-conflict", file: data.rel, story: data.title, chapter: quest.chapter, quest: quest.id, chapterFaction: quest.chapterFaction, questFaction: quest.faction });
    }
    if (!intersects(quest.storyClass, quest.class)) {
      addFinding("error", { type: "story-quest-class-conflict", file: data.rel, story: data.title, quest: quest.id, storyClass: describe(quest.storyClass), questClass: describe(quest.class) });
    }
    if (!intersects(quest.storyRace, quest.race)) {
      addFinding("error", { type: "story-quest-race-conflict", file: data.rel, story: data.title, quest: quest.id, storyRace: describe(quest.storyRace), questRace: describe(quest.race) });
    }
    const questRaceFaction = impliedFaction(quest.race);
    if (quest.faction && questRaceFaction && quest.faction !== questRaceFaction) {
      addFinding("error", { type: "quest-race-faction-conflict", file: data.rel, story: data.title, quest: quest.id, faction: quest.faction, race: describe(quest.race) });
    }
    const effectiveFaction = quest.faction || quest.chapterFaction || quest.storyFaction;
    if (effectiveFaction && questRaceFaction && effectiveFaction !== questRaceFaction) {
      addFinding("error", { type: "effective-race-faction-conflict", file: data.rel, story: data.title, quest: quest.id, faction: effectiveFaction, race: describe(quest.race) });
    }
    if (hasZoneMismatch(quest.mapID, quest.location)) {
      addFinding("warn", { type: "quest-map-location-mismatch", file: data.rel, story: data.title, quest: quest.id, mapID: quest.mapID, location: quest.location });
    }
  }

  for (const [npc, loc] of data.npcLocations) {
    if (hasZoneMismatch(loc.mapID, loc.location)) {
      addFinding("warn", { type: "npc-map-location-mismatch", file: data.rel, story: data.title, npc, mapID: loc.mapID, location: loc.location });
    }
  }
}

const severityCounts = findings.reduce((counts, finding) => {
  counts[finding.severity] = (counts[finding.severity] || 0) + 1;
  return counts;
}, {});

console.log(JSON.stringify({
  files: datasets.length,
  severityCounts,
  findings,
}, null, 2));

process.exit((severityCounts.error || 0) ? 1 : 0);
