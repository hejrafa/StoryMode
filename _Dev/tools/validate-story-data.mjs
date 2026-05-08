import { readFile, readdir } from "node:fs/promises";
import path from "node:path";

const root = process.argv.find((arg, index) => index > 1 && !arg.startsWith("--")) || process.cwd();
const showAllFindings = process.argv.includes("--all-findings");
const dataRoot = path.join(root, "Data");
const tocFiles = ["StoryMode.toc", "StoryMode_TBC.toc", "StoryMode_Vanilla.toc"];

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

function unescapeLua(value) {
  return value.replace(/\\"/g, '"').replace(/\\\\/g, "\\");
}

function stringField(text, key) {
  const match = text.match(new RegExp(`${key}\\s*=\\s*"((?:[^"\\\\]|\\\\.)*)"`));
  return match ? unescapeLua(match[1]) : null;
}

function slug(value) {
  return String(value || "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "") || "story";
}

function parseLuaData(rel, text) {
  const title = stringField(text, "title") || rel;
  const explicitID = stringField(text, "id") || stringField(text, "storyID");
  const id = explicitID || slug(title);
  const quests = [];
  const npcLocations = new Set();
  const npcDisplayIDs = new Set();
  const chapterDisplayIDs = new Set();
  let chapter = "";
  let table = "";

  for (const line of text.split(/\r?\n/)) {
    const chapterName = stringField(line, "chapter");
    if (chapterName) chapter = chapterName;

    if (/npcLocations\s*=\s*\{/.test(line)) table = "locations";
    else if (/npcDisplayIDs\s*=\s*\{/.test(line)) table = "npcDisplayIDs";
    else if (/chapterDisplayIDs\s*=\s*\{/.test(line)) table = "chapterDisplayIDs";
    else if (table && /^\s*\},?\s*$/.test(line)) table = "";

    const tableKey = line.match(/\["((?:[^"\\]|\\.)+)"\]\s*=/);
    if (tableKey) {
      const key = unescapeLua(tableKey[1]);
      if (table === "locations") npcLocations.add(key);
      else if (table === "npcDisplayIDs") npcDisplayIDs.add(key);
      else if (table === "chapterDisplayIDs") chapterDisplayIDs.add(key);
    }

    const questMatch = line.match(/\bid\s*=\s*(\d+)/);
    if (!questMatch) continue;
    const name = stringField(line, "name");
    const npc = stringField(line, "npc");
    quests.push({ id: Number(questMatch[1]), name, npc, chapter, line: line.trim() });
  }

  return { rel, title, id, explicitID, quests, npcLocations, npcDisplayIDs, chapterDisplayIDs };
}

function tocDataFiles(text) {
  return new Set(text
    .split(/\r?\n/)
    .map((line) => line.trim().replace(/\\/g, "/"))
    .filter((line) => line.startsWith("Data/") && line.endsWith("Data.lua")));
}

const files = await walk(dataRoot);
const datasets = [];
for (const file of files) {
  const rel = path.relative(root, file).replace(/\\/g, "/");
  datasets.push(parseLuaData(rel, await readFile(file, "utf8")));
}

const findings = [];
const ids = new Map();
for (const data of datasets) {
  if (ids.has(data.id)) {
    findings.push({ type: "duplicate-story-id", severity: "error", file: data.rel, detail: `${data.id} also used by ${ids.get(data.id)}` });
  } else {
    ids.set(data.id, data.rel);
  }

  if (!data.title || data.title === data.rel) {
    findings.push({ type: "missing-title", severity: "error", file: data.rel });
  }

  const questIDs = new Map();
  for (const quest of data.quests) {
    if (!quest.name) findings.push({ type: "missing-quest-name", severity: "error", file: data.rel, quest: quest.id });
    if (questIDs.has(quest.id) && questIDs.get(quest.id) !== "(root)") {
      findings.push({ type: "duplicate-quest-in-story", severity: "warn", file: data.rel, quest: quest.id, detail: `also in ${questIDs.get(quest.id)}` });
    } else {
      questIDs.set(quest.id, quest.chapter || "(root)");
    }
    const hasQuestLocation = quest.line.includes("location =")
      || (quest.line.includes("mapID =") && quest.line.includes("x =") && quest.line.includes("y ="));
    if (quest.npc && !data.npcLocations.has(quest.npc) && !hasQuestLocation) {
      findings.push({ type: "missing-npc-location", severity: "warn", file: data.rel, quest: quest.id, npc: quest.npc });
    }
  }

  for (const name of data.npcDisplayIDs) {
    if (!data.npcLocations.has(name)) {
      findings.push({ type: "display-without-location", severity: "info", file: data.rel, npc: name });
    }
  }

  for (const name of data.chapterDisplayIDs) {
    if (!data.rel.includes("/Heritage/") && !data.quests.some((quest) => quest.chapter === name)) {
      findings.push({ type: "chapter-display-without-chapter", severity: "warn", file: data.rel, chapter: name });
    }
  }
}

for (const toc of tocFiles) {
  const tocPath = path.join(root, toc);
  const tocSet = tocDataFiles(await readFile(tocPath, "utf8"));
  const classicOnly = toc !== "StoryMode.toc";
  for (const data of datasets) {
    const isClassicCompatible = /gameVersions\s*=\s*\{[^}]*classicEra\s*=\s*true/.test(await readFile(path.join(root, data.rel), "utf8"));
    if (classicOnly && isClassicCompatible && !tocSet.has(data.rel) && data.rel.startsWith("Data/Storylines/")) {
      findings.push({ type: "classic-story-missing-from-toc", severity: "error", file: data.rel, toc });
    }
  }
}

const severityCounts = findings.reduce((counts, finding) => {
  counts[finding.severity] = (counts[finding.severity] || 0) + 1;
  return counts;
}, {});
const visibleFindings = showAllFindings ? findings : findings.filter((finding) => finding.severity === "error");
const errorCount = severityCounts.error || 0;
console.log(JSON.stringify({
  files: datasets.length,
  storyIDs: ids.size,
  severityCounts,
  findings: visibleFindings,
  hint: showAllFindings ? undefined : "Run with --all-findings to print warnings and info findings.",
}, null, 2));

process.exit(errorCount > 0 ? 1 : 0);
