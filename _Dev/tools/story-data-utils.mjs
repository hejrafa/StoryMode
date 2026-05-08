import { readFile, readdir } from "node:fs/promises";
import path from "node:path";

export async function walkDataFiles(root, scope = "") {
  const dataRoot = path.join(root, "Data");
  async function walk(dir) {
    const entries = await readdir(dir, { withFileTypes: true });
    const out = [];
    for (const entry of entries) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) out.push(...await walk(full));
      else if (entry.name.endsWith("Data.lua")) out.push(full);
    }
    return out;
  }
  return (await walk(dataRoot)).filter((file) => !scope || path.relative(root, file).includes(scope));
}

export function unescapeLuaString(value) {
  return value.replace(/\\"/g, '"').replace(/\\\\/g, "\\");
}

export function extractString(text, key) {
  const match = text.match(new RegExp(`${key}\\s*=\\s*"((?:[^"\\\\]|\\\\.)*)"`));
  return match ? unescapeLuaString(match[1]) : null;
}

export function extractNumber(text, key) {
  const match = text.match(new RegExp(`${key}\\s*=\\s*([0-9.]+)`));
  return match ? Number(match[1]) : null;
}

export function extractStringOrList(text, key) {
  const single = extractString(text, key);
  if (single) return single;
  const list = text.match(new RegExp(`${key}\\s*=\\s*\\{([^}]+)\\}`));
  if (!list) return null;
  const values = [...list[1].matchAll(/"((?:[^"\\]|\\.)*)"/g)].map((match) => unescapeLuaString(match[1]));
  return values.length ? values : null;
}

function tableKey(line) {
  const match = line.match(/\["((?:[^"\\]|\\.)+)"\]\s*=/);
  return match ? unescapeLuaString(match[1]) : null;
}

function parseQuest(line, chapter, chapterMeta, dataMeta) {
  const idMatch = line.match(/\bid\s*=\s*(\d+)/);
  if (!idMatch) return null;
  const name = extractString(line, "name");
  if (!name) return null;
  const quest = {
    id: Number(idMatch[1]),
    name,
    displayName: extractString(line, "displayName"),
    npc: extractString(line, "npc"),
    location: extractString(line, "location"),
    faction: extractString(line, "faction"),
    class: extractStringOrList(line, "class"),
    race: extractStringOrList(line, "race"),
    mapID: extractNumber(line, "mapID"),
    x: extractNumber(line, "x"),
    y: extractNumber(line, "y"),
    optional: /\boptional\s*=\s*true/.test(line),
    chapter,
    chapterFaction: chapterMeta.faction,
    storyFaction: dataMeta.faction,
    storyClass: dataMeta.class,
    storyRace: dataMeta.race,
    line: line.trim(),
  };
  return quest;
}

export function parseDataFile(root, file, text) {
  const rel = path.relative(root, file).replace(/\\/g, "/");
  const title = extractString(text, "title") || rel;
  const dataHeader = text.split(/\n\s*(?:startQuest|startMapID|npcLocations|chapters|prereqs|insurrection)\s*=/)[0] || text;
  const dataMeta = {
    faction: extractString(dataHeader, "faction"),
    class: extractStringOrList(dataHeader, "class"),
    race: extractStringOrList(dataHeader, "race"),
  };
  const gameVersions = text.match(/gameVersions\s*=\s*\{([^}]+)\}/)?.[1] || "";
  const classicCompatible = /classicEra\s*=\s*true/.test(gameVersions) || rel.includes("/ClassQuests/Classic");
  const source = classicCompatible ? "classic" : "retail";
  const startQuestLine = text.match(/startQuest\s*=\s*(\{[^\n]+\})/)?.[1] || "";
  const startQuest = startQuestLine ? parseQuest(startQuestLine, "(startQuest)", {}, dataMeta) : null;
  const startMapID = extractNumber(text, "startMapID");
  const startX = extractNumber(text, "startX");
  const startY = extractNumber(text, "startY");
  const npcLocations = new Map();
  const quests = [];
  const chapters = [];
  let table = "";
  let chapter = "";
  let chapterMeta = {};

  for (const line of text.split(/\r?\n/)) {
    const chapterName = extractString(line, "chapter");
    if (chapterName) {
      chapter = chapterName;
      chapterMeta = { faction: extractString(line, "faction") };
      chapters.push({ chapter, faction: chapterMeta.faction });
    }

    if (/npcLocations\s*=\s*\{/.test(line)) table = "locations";
    else if (table && /^\s*\},?\s*$/.test(line)) table = "";

    if (table === "locations") {
      const name = tableKey(line);
      const body = line.match(/\{([^}]+)\}/)?.[1] || "";
      const mapID = extractNumber(body, "mapID");
      const x = extractNumber(body, "x");
      const y = extractNumber(body, "y");
      if (name && mapID && x !== null && y !== null) {
        npcLocations.set(name, {
          mapID,
          x,
          y,
          location: extractString(body, "location"),
        });
      }
    }

    const quest = parseQuest(line, chapter, chapterMeta, dataMeta);
    if (quest && chapter) quests.push(quest);
  }

  return {
    rel,
    title,
    source,
    classicCompatible,
    faction: dataMeta.faction,
    class: dataMeta.class,
    race: dataMeta.race,
    startQuest,
    startMapID,
    startX,
    startY,
    npcLocations,
    chapters,
    quests,
  };
}

export async function loadDatasets(root, scope = "") {
  const files = await walkDataFiles(root, scope);
  const datasets = [];
  for (const file of files) {
    datasets.push(parseDataFile(root, file, await readFile(file, "utf8")));
  }
  return datasets;
}
