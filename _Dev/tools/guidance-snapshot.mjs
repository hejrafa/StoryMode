import path from "node:path";
import { loadDatasets } from "./story-data-utils.mjs";

const positionalArgs = process.argv.slice(2).filter((arg) => !arg.startsWith("--"));
const root = positionalArgs[0] || process.cwd();
const scope = positionalArgs[1] || "";
const showExamples = process.argv.includes("--examples");

const PREFIX = "Story Mode > ";
const MAP_NAMES = new Map([
  [1, "Durotar"],
  [7, "Mulgore"],
  [10, "Northern Barrens"],
  [18, "Tirisfal Glades"],
  [21, "Silverpine Forest"],
  [23, "Eastern Plaguelands"],
  [25, "Hillsbrad Foothills"],
  [27, "Dun Morogh"],
  [36, "Burning Steppes"],
  [37, "Elwynn Forest"],
  [47, "Duskwood"],
  [48, "Loch Modan"],
  [50, "Northern Stranglethorn"],
  [52, "Westfall"],
  [56, "Wetlands"],
  [57, "Teldrassil"],
  [62, "Darkshore"],
  [70, "Dustwallow Marsh"],
  [71, "Tanaris"],
  [76, "Azshara"],
  [77, "Felwood"],
  [78, "Un'Goro Crater"],
  [80, "Moonglade"],
  [81, "Silithus"],
  [83, "Winterspring"],
  [84, "Stormwind"],
  [85, "Orgrimmar"],
  [88, "Thunder Bluff"],
  [89, "Darnassus"],
  [90, "Undercity"],
  [103, "The Exodar"],
  [111, "Shattrath City"],
  [115, "Dragonblight"],
  [118, "Icecrown"],
  [125, "Icecrown Citadel"],
  [371, "The Jade Forest"],
  [680, "Suramar"],
  [862, "Zuldazar"],
  [1161, "Boralus"],
  [1670, "Oribos"],
]);

function colorless(value) {
  return String(value || "").replace(/\|c[0-9a-fA-F]{8}/g, "").replace(/\|r/g, "");
}

function displayQuestName(quest) {
  return quest.displayName || quest.name;
}

function getQuestLocation(data, quest) {
  if (quest.mapID && quest.x !== null && quest.y !== null) {
    return { mapID: quest.mapID, x: quest.x, y: quest.y, location: quest.location };
  }
  const npcLoc = quest.npc && data.npcLocations.get(quest.npc);
  if (npcLoc) return npcLoc;
  if (data.startQuest && quest.id === data.startQuest.id && data.startMapID && data.startX !== null && data.startY !== null) {
    return { mapID: data.startMapID, x: data.startX, y: data.startY, location: data.startQuest.location };
  }
  if (quest.location) return { location: quest.location };
  return null;
}

function placeText(data, quest, loc) {
  if (quest.location) return quest.location;
  if (loc?.location) return loc.location;
  if (loc?.mapID && MAP_NAMES.has(loc.mapID)) return MAP_NAMES.get(loc.mapID);
  if (data.startQuest && quest.id === data.startQuest.id && data.startQuest.location) return data.startQuest.location;
  return null;
}

function guidanceLine(data, quest, kind = data.source === "classic" ? "classic_guidance" : "waypoint") {
  const q = displayQuestName(quest);
  const npc = quest.npc || "";
  const loc = getQuestLocation(data, quest);
  const place = placeText(data, quest, loc);
  if (quest._isPrerequisiteForChapter) {
    if (place) return `${PREFIX}${quest._isPrerequisiteForChapter} awaits, but first finish ${q}. Look for it around ${place}.`;
    return `${PREFIX}${quest._isPrerequisiteForChapter} awaits, but first finish ${q}.`;
  }
  if (kind === "supertracked") {
    if (npc && place) return `${PREFIX}Now following ${q}. Look for ${npc} at ${place}.`;
    return `${PREFIX}Now following ${q}. Look to your map.`;
  }
  if (npc && place) return `${PREFIX}Find ${npc} at ${place} to begin ${q}.`;
  if (npc) return `${PREFIX}Find ${npc} to begin ${q}.`;
  if (place) return `${PREFIX}Go to ${place} to begin ${q}.`;
  return `${PREFIX}Begin ${q}.`;
}

function firstActionableQuest(data, profile) {
  for (const quest of data.quests) {
    if (quest.faction && profile.faction && quest.faction !== profile.faction) continue;
    if (quest.chapterFaction && profile.faction && quest.chapterFaction !== profile.faction) continue;
    return quest;
  }
  return data.startQuest;
}

const profiles = [
  { name: "alliance", faction: "Alliance" },
  { name: "horde", faction: "Horde" },
];

const datasets = await loadDatasets(root, scope);
const snapshots = [];
const findings = [];

for (const data of datasets) {
  if (data.startQuest) {
    const message = colorless(guidanceLine(data, data.startQuest));
    snapshots.push({ story: data.title, file: data.rel, scenario: "start", quest: displayQuestName(data.startQuest), message });
    if (!data.startQuest.npc && !placeText(data, data.startQuest, getQuestLocation(data, data.startQuest))) {
      findings.push({ type: "start-guidance-missing-source", file: data.rel, story: data.title, quest: data.startQuest.id, message });
    }
    if (/^Story Mode > Begin /.test(message)) {
      findings.push({ type: "vague-start-guidance", file: data.rel, story: data.title, quest: data.startQuest.id, message });
    }
  }

  for (const profile of profiles) {
    const quest = firstActionableQuest(data, profile);
    if (!quest) continue;
    const message = colorless(guidanceLine(data, quest));
    snapshots.push({ story: data.title, file: data.rel, scenario: `continue:${profile.name}`, quest: displayQuestName(quest), message });
    if (/^Story Mode > Begin /.test(message) || /^Story Mode > Find (?!.* at ).+ to begin /.test(message)) {
      findings.push({ type: "vague-continue-guidance", file: data.rel, story: data.title, profile: profile.name, quest: quest.id, message });
    }
  }
}

const examples = [
  snapshots.find((item) => item.file.endsWith("FrozenThroneData.lua") && item.scenario === "continue:alliance"),
  snapshots.find((item) => item.file.endsWith("DuskwoodData.lua") && item.scenario === "start"),
  snapshots.find((item) => item.file.endsWith("ClassicClassQuestData.lua") && item.message.includes("Mathias")),
  snapshots.find((item) => item.file.endsWith("SylvanasData.lua") && item.scenario === "continue:horde"),
].filter(Boolean);

console.log(JSON.stringify({
  files: datasets.length,
  snapshots: snapshots.length,
  findings,
  examples: showExamples ? examples : undefined,
}, null, 2));

process.exit(findings.length ? 1 : 0);
