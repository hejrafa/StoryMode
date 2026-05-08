import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import path from "node:path";

const positionalArgs = process.argv.slice(2).filter((arg) => !arg.startsWith("--"));
const root = positionalArgs[0] || process.cwd();
const scope = positionalArgs[1] || "";
const includeQaReport = process.argv.includes("--qa-report");
const cacheDir = path.join(root, ".quest-audit-cache");
const dataRoot = path.join(root, "Data");
const exceptionsPath = path.join(root, "_Dev", "quest-audit-exceptions.json");

const CLASSIC_ZONE_TO_UI_MAP = new Map([
  [1, 27],      // Dun Morogh
  [8, 51],      // Swamp of Sorrows
  [12, 37],     // Elwynn Forest
  [14, 1],      // Durotar
  [15, 70],     // Dustwallow Marsh
  [16, 76],     // Azshara
  [17, 10],     // The Barrens
  [28, 23],     // Western Plaguelands
  [33, 50],     // Stranglethorn Vale
  [36, 25],     // Alterac Mountains / Hillsbrad area
  [38, 48],     // Loch Modan
  [40, 52],     // Westfall
  [46, 36],     // Burning Steppes
  [85, 18],     // Tirisfal Glades
  [130, 21],    // Silverpine Forest
  [141, 57],    // Teldrassil
  [148, 62],    // Darkshore
  [215, 7],     // Mulgore
  [267, 25],    // Hillsbrad Foothills
  [361, 77],    // Felwood
  [400, 64],    // Thousand Needles
  [490, 78],    // Un'Goro Crater
  [493, 80],    // Moonglade
  [1497, 90],   // Undercity
  [1519, 84],   // Stormwind
  [1537, 87],   // Ironforge
  [1637, 85],   // Orgrimmar
  [1638, 88],   // Thunder Bluff
  [1657, 89],   // Darnassus
  [2557, 234],  // Dire Maul
]);

async function mapLimit(items, limit, worker) {
  const results = new Array(items.length);
  let next = 0;
  const runners = Array.from({ length: Math.min(limit, items.length) }, async () => {
    while (next < items.length) {
      const index = next++;
      results[index] = await worker(items[index], index);
    }
  });
  await Promise.all(runners);
  return results;
}

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

async function readExceptions() {
  try {
    const parsed = JSON.parse(await readFile(exceptionsPath, "utf8"));
    return Array.isArray(parsed.exceptions) ? parsed.exceptions : [];
  } catch {
    return [];
  }
}

function unescapeLuaString(value) {
  return value.replace(/\\"/g, '"').replace(/\\\\/g, "\\");
}

function extractString(line, key) {
  const match = line.match(new RegExp(`${key}\\s*=\\s*"((?:[^"\\\\]|\\\\.)*)"`));
  return match ? unescapeLuaString(match[1]) : null;
}

function extractNumber(line, key) {
  const match = line.match(new RegExp(`${key}\\s*=\\s*([0-9.]+)`));
  return match ? Number(match[1]) : null;
}

function parseDataFile(file, text) {
  const rel = path.relative(root, file);
  const story = extractString(text, "title") || rel;
  const classicCompatible = /gameVersions\s*=\s*\{[^}]*classicEra\s*=\s*true/.test(text)
    || rel.includes(`${path.sep}ClassQuests${path.sep}Classic`);
  const source = classicCompatible ? "classic" : "retail";
  const quests = [];
  const npcLocations = new Map();
  const npcDisplayIDs = new Map();
  const chapterDisplayIDs = new Map();
  let chapter = "";
  let table = "";

  for (const line of text.split(/\r?\n/)) {
    const chapterName = extractString(line, "chapter");
    if (chapterName) chapter = chapterName;

    if (/npcLocations\s*=\s*\{/.test(line)) table = "locations";
    if (/npcDisplayIDs\s*=\s*\{/.test(line)) table = "npcDisplayIDs";
    if (/chapterDisplayIDs\s*=\s*\{/.test(line)) table = "chapterDisplayIDs";
    if (table && /^\s*\},?\s*$/.test(line)) table = "";

    if (table === "locations") {
      const match = line.match(/\["((?:[^"\\]|\\.)+)"\]\s*=\s*\{\s*mapID\s*=\s*(\d+),\s*x\s*=\s*([0-9.]+),\s*y\s*=\s*([0-9.]+)/);
      if (match) npcLocations.set(unescapeLuaString(match[1]), {
        mapID: Number(match[2]),
        x: Number(match[3]),
        y: Number(match[4]),
      });
    }

    if (table === "npcDisplayIDs" || table === "chapterDisplayIDs") {
      const match = line.match(/\["((?:[^"\\]|\\.)+)"\]\s*=\s*(\d+)/);
      if (match) {
        const target = table === "npcDisplayIDs" ? npcDisplayIDs : chapterDisplayIDs;
        target.set(unescapeLuaString(match[1]), Number(match[2]));
      }
    }

    if (!/\bid\s*=\s*\d+/.test(line)) continue;
    const idMatch = line.match(/\bid\s*=\s*(\d+)/);
    const name = extractString(line, "name");
    const npc = extractString(line, "npc");
    const location = extractString(line, "location");
    const faction = extractString(line, "faction");
    const race = extractString(line, "race") || (line.match(/race\s*=\s*\{\s*([^}]+)\s*\}/)?.[1] || null);
    const mapID = extractNumber(line, "mapID");
    const x = extractNumber(line, "x");
    const y = extractNumber(line, "y");
    if (idMatch && name) {
      quests.push({
        id: Number(idMatch[1]),
        name,
        npc,
        location,
        faction,
        race,
        mapID,
        x,
        y,
        source,
        story,
        chapter,
        file: rel,
        line: line.trim(),
      });
    }
  }

  return { rel, story, source, quests, npcLocations, npcDisplayIDs, chapterDisplayIDs };
}

function htmlDecode(value) {
  let decoded = value || "";
  for (let i = 0; i < 3; i++) {
    decoded = decoded
      .replace(/&quot;/g, '"')
      .replace(/&#039;/g, "'")
      .replace(/&amp;/g, "&")
      .replace(/&lt;/g, "<")
      .replace(/&gt;/g, ">");
  }
  return decoded;
}

function slug(value) {
  return value.toLowerCase()
    .replace(/['.]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

async function fetchCached(kind, id, url) {
  await mkdir(path.join(cacheDir, kind), { recursive: true });
  const cachePath = path.join(cacheDir, kind, `${id}.html`);
  try {
    return await readFile(cachePath, "utf8");
  } catch {}

  const response = await fetch(url, {
    headers: {
      "user-agent": "StoryMode quest audit (local addon maintenance)",
      "accept-language": "en-US,en;q=0.9",
    },
  });
  if (!response.ok) throw new Error(`${response.status} ${response.statusText} for ${url}`);
  const html = await response.text();
  await writeFile(cachePath, html);
  return html;
}

function parseQuestPage(id, html) {
  const titleMatch = html.match(/<title>(.*?) - Quest - World of Warcraft<\/title>/);
  const title = titleMatch ? htmlDecode(titleMatch[1]) : null;
  const gQuestMatch = html.match(new RegExp(`\\$\\.extend\\(g_quests\\[${id}\\],\\s*(\\{.*?\\})\\);`));
  let gQuest = null;
  if (gQuestMatch) {
    try { gQuest = JSON.parse(gQuestMatch[1]); } catch {}
  }

  const series = [];
  const olMatch = html.match(/<ol>([\s\S]*?)<\/ol>/);
  if (olMatch) {
    const itemRegex = /(?:quest=(\d+)\/[^"]*"[^>]*>(.*?)<\/a>)|(?:<li class="current"><span>(.*?)<\/span>)/g;
    let match;
    while ((match = itemRegex.exec(olMatch[1]))) {
      if (match[1]) series.push({ id: Number(match[1]), name: htmlDecode(match[2].replace(/<[^>]+>/g, "")) });
      else series.push({ id, name: htmlDecode(match[3].replace(/<[^>]+>/g, "")) });
    }
  }

  const starts = [];
  const mapperMatch = html.match(/var myMapper = new Mapper\((\{[\s\S]*?\})\);/);
  if (mapperMatch) {
    const mapperText = mapperMatch[1];
    const startRegex = /\{"type":1,"point":"start","name":"((?:[^"\\]|\\.)+)","coord":\[([0-9.]+),([0-9.]+)\],"coords":\[[\s\S]*?"id":(\d+)/g;
    let match;
    while ((match = startRegex.exec(mapperText))) {
      starts.push({
        name: JSON.parse(`"${match[1]}"`),
        x: Number(match[2]),
        y: Number(match[3]),
        id: Number(match[4]),
      });
    }
  }

  return {
    id,
    title: gQuest?.name || title,
    series,
    starts,
  };
}

function parseClassicQuestPage(id, html) {
  const titleMatch = html.match(/<title>(.*?) - Quest/);
  const title = titleMatch ? htmlDecode(titleMatch[1]) : null;
  const series = [];
  const seriesMatch = html.match(/<table class="series">([\s\S]*?)<\/table>/);
  if (seriesMatch) {
    const itemRegex = /(?:<a href="\?quest=(\d+)">([\s\S]*?)<\/a>)|(?:<b>([\s\S]*?)<\/b>)/g;
    let match;
    while ((match = itemRegex.exec(seriesMatch[1]))) {
      if (match[1]) series.push({ id: Number(match[1]), name: htmlDecode(match[2].replace(/<[^>]+>/g, "")) });
      else series.push({ id, name: htmlDecode(match[3].replace(/<[^>]+>/g, "")) });
    }
  }

  const starts = [];
  const startRegex = /zone:(\d+),coords:\[\[([0-9.]+),([0-9.]+),\{label:'[\s\S]*?<b class=q>(.*?)<\/b>[\s\S]*?Starts the quest/g;
  let match;
  while ((match = startRegex.exec(html))) {
    const classicZone = Number(match[1]);
    starts.push({
      name: htmlDecode(match[4].replace(/<[^>]+>/g, "")),
      x: Number(match[2]),
      y: Number(match[3]),
      classicZone,
      mapID: CLASSIC_ZONE_TO_UI_MAP.get(classicZone) || classicZone,
      id: null,
    });
  }

  const fallbackStart = html.match(/Start:\s*<a href="\?npc=(\d+)"[^>]*>(.*?)<\/a>/s);
  if (!starts.length && fallbackStart) {
    starts.push({
      name: htmlDecode(fallbackStart[2].replace(/<[^>]+>/g, "")),
      x: null,
      y: null,
      classicZone: null,
      mapID: null,
      id: Number(fallbackStart[1]),
    });
  }

  return { id, title, series, starts, source: "classic" };
}

async function fetchQuestData(id, source = "retail") {
  if (source === "classic") {
    const html = await fetchCached("classic-quest", id, `https://classicdb.ch/?quest=${id}`);
    return parseClassicQuestPage(id, html);
  }

  try {
    const html = await fetchCached("quest", id, `https://www.wowhead.com/quest=${id}`);
    return { ...parseQuestPage(id, html), source: "retail" };
  } catch (pageError) {
    const tooltip = await fetchCached("quest-tooltip", id, `https://nether.wowhead.com/tooltip/quest/${id}`);
    const data = JSON.parse(tooltip);
    return {
      id,
      title: data.name || null,
      series: [],
      starts: [],
      source: "retail",
      pageError: pageError.message,
    };
  }
}

function parseNpcPage(id, html) {
  const nameMatch = html.match(/<h1 class="heading-size-1">(.*?)<\/h1>/);
  const displayMatch = html.match(/data-mv-display-id="(\d+)"/);
  return {
    id,
    name: nameMatch ? htmlDecode(nameMatch[1]) : null,
    displayId: displayMatch ? Number(displayMatch[1]) : null,
  };
}

function norm(value) {
  return (value || "").toLowerCase().replace(/[\u2018\u2019]/g, "'").replace(/\s+/g, " ").trim();
}

function normQuestTitle(value) {
  return norm(value).replace(/\s+\(part\s+\d+\)$/i, "");
}

function distance(a, b) {
  if (!a || !b) return null;
  const ax = a.x <= 1 ? a.x * 100 : a.x;
  const ay = a.y <= 1 ? a.y * 100 : a.y;
  const bx = b.x <= 1 ? b.x * 100 : b.x;
  const by = b.y <= 1 ? b.y * 100 : b.y;
  return Math.hypot(ax - bx, ay - by);
}

const files = (await walk(dataRoot))
  .filter((file) => !scope || path.relative(root, file).includes(scope));
const exceptions = await readExceptions();

const datasets = [];
for (const file of files) datasets.push(parseDataFile(file, await readFile(file, "utf8")));

const quests = datasets.flatMap((data) => data.quests);
const questKeys = [...new Set(quests.map((quest) => `${quest.source}:${quest.id}`))]
  .map((key) => {
    const [source, id] = key.split(":");
    return { key, source, id: Number(id) };
  })
  .sort((a, b) => a.source.localeCompare(b.source) || a.id - b.id);
const questData = new Map();
const findings = [];
await mapLimit(questKeys, 6, async ({ key, source, id }, index) => {
  if (index % 50 === 0) console.error(`quests ${index}/${questKeys.length}`);
  try {
    questData.set(key, await fetchQuestData(id, source));
  } catch (error) {
    const examples = quests.filter((quest) => quest.id === id && quest.source === source);
    for (const quest of examples) {
      findings.push({ type: "fetch", severity: "error", quest, remote: error.message });
    }
  }
});

function questKey(quest) {
  return `${quest.source}:${quest.id}`;
}

const npcIds = new Set();
for (const quest of quests) {
  const remote = questData.get(questKey(quest));
  if (quest.npc && /\b[A-Z][A-Za-z]+ Trainer\b/.test(quest.npc)) {
    findings.push({ type: "generic-source", severity: "warn", quest, remote: "replace generic trainer with the specific quest starter when possible" });
  }
  if (quest.mapID && Math.abs((quest.x || 0) - 0.5) < 0.005 && Math.abs((quest.y || 0) - 0.5) < 0.005) {
    findings.push({ type: "placeholder-location", severity: "warn", quest, remote: "exact zone center coordinates" });
  }
  if (quest.location && (quest.location.match(/\//g) || []).length >= 2) {
    findings.push({ type: "broad-location", severity: "warn", quest, remote: quest.location });
  }
  if (!remote) continue;
  if (remote.title && normQuestTitle(remote.title) !== normQuestTitle(quest.name)) {
    findings.push({ type: "title", severity: "error", quest, remote: remote.title });
  }
  if (quest.npc && remote.starts.length && !remote.starts.some((start) => norm(start.name) === norm(quest.npc))) {
    findings.push({ type: "npc", severity: "warn", quest, remote: remote.starts.map((start) => `${start.name} (${start.id})`).join(", ") });
  }
  if (quest.source === "retail") {
    for (const start of remote.starts) {
      if (start.id) npcIds.add(start.id);
    }
  }
}

for (const data of datasets) {
  const byChapter = new Map();
  for (const quest of data.quests) {
    if (!quest.chapter) continue;
    if (!byChapter.has(quest.chapter)) byChapter.set(quest.chapter, []);
    byChapter.get(quest.chapter).push(quest);
  }

  for (const [chapter, chapterQuests] of byChapter) {
    const branchGroups = new Map();
    for (const quest of chapterQuests) {
      const branch = [quest.faction || "Any", quest.race || "Any"].join(":");
      if (!branchGroups.has(branch)) branchGroups.set(branch, []);
      branchGroups.get(branch).push(quest);
    }

    for (const branchQuests of branchGroups.values()) {
      const candidateSeries = branchQuests
        .map((quest) => questData.get(questKey(quest))?.series || [])
        .filter((series) => series.length);
      const series = candidateSeries
        .map((series) => ({
          series,
          matches: branchQuests.filter((quest) => series.some((remoteQuest) => remoteQuest.id === quest.id)).length,
        }))
        .sort((a, b) => b.matches - a.matches)[0]?.series || [];
      if (!series.length) continue;
      const seriesIndex = new Map(series.map((quest, index) => [quest.id, index]));
      const matchedIndexes = branchQuests
        .map((quest) => seriesIndex.get(quest.id))
        .filter((index) => index !== undefined);
      const span = matchedIndexes.length
        ? Math.max(...matchedIndexes) - Math.min(...matchedIndexes) + 1
        : 0;
      const toleratedGaps = Math.max(3, Math.ceil(matchedIndexes.length * 1.5));
      if (matchedIndexes.length < 2 || span > matchedIndexes.length + toleratedGaps) continue;
      let previous = -1;
      let previousQuest = null;
      const storyQuestIDs = new Set(data.quests.map((quest) => quest.id));
      for (const quest of branchQuests) {
        if (!seriesIndex.has(quest.id)) continue;
        const index = seriesIndex.get(quest.id);
        if (index < previous) findings.push({ type: "order", severity: "warn", quest, remote: `series index ${index + 1} after ${previous + 1}` });
        if (previousQuest && index > previous + 1) {
          const missing = series
            .slice(previous + 1, index)
            .filter((remoteQuest) => !storyQuestIDs.has(remoteQuest.id));
          if (missing.length) {
            findings.push({
              type: "chain-hole",
              severity: "warn",
              quest,
              remote: `between ${previousQuest.id} and ${quest.id}: ${missing.map((remoteQuest) => `${remoteQuest.id} ${remoteQuest.name}`).join(", ")}`,
            });
          }
        }
        previous = Math.max(previous, index);
        previousQuest = quest;
      }
    }
  }

  for (const [npcName, localLocation] of data.npcLocations) {
    const starts = data.quests
      .filter((quest) => norm(quest.npc) === norm(npcName))
      .flatMap((quest) => questData.get(questKey(quest))?.starts || [])
      .filter((start) => norm(start.name) === norm(npcName));
    if (!starts.length) continue;
    const nearest = starts.map((start) => ({ start, dist: distance(localLocation, start) })).sort((a, b) => a.dist - b.dist)[0];
    if (nearest && nearest.dist > 8) {
      findings.push({ type: "location", severity: "warn", quest: { story: data.story, file: data.rel, chapter: "npcLocations", id: "", name: npcName, npc: npcName }, remote: `${nearest.start.x}, ${nearest.start.y} (${nearest.start.id}), local ${localLocation.x * 100}, ${localLocation.y * 100}` });
    }
  }
}

const npcData = new Map();
await mapLimit([...npcIds], 8, async (id, index) => {
  if (index % 50 === 0) console.error(`npcs ${index}/${npcIds.size}`);
  try {
    const html = await fetchCached("npc", id, `https://www.wowhead.com/npc=${id}`);
    npcData.set(id, parseNpcPage(id, html));
  } catch {
    npcData.set(id, { id, name: null, displayId: null });
  }
});

const startsByName = new Map();
for (const quest of quests) {
  const starts = questData.get(questKey(quest))?.starts || [];
  for (const start of starts) {
    const key = norm(start.name);
    if (!startsByName.has(key)) startsByName.set(key, []);
    startsByName.get(key).push(start);
  }
}

for (const data of datasets) {
  for (const [npcName, localDisplay] of data.npcDisplayIDs) {
    if (!localDisplay) {
      findings.push({ type: "display-missing", severity: "warn", quest: { story: data.story, file: data.rel, chapter: "npcDisplayIDs", id: "", name: npcName, npc: npcName }, remote: "local display ID is 0" });
      continue;
    }
    const starts = startsByName.get(norm(npcName)) || [];
    const displayIds = [...new Set(starts.map((start) => npcData.get(start.id)?.displayId).filter(Boolean))];
    if (displayIds.length && !displayIds.includes(localDisplay)) {
      findings.push({ type: "display", severity: "info", quest: { story: data.story, file: data.rel, chapter: "npcDisplayIDs", id: "", name: npcName, npc: npcName }, remote: `Wowhead start NPC display IDs: ${displayIds.join(", ")}; local ${localDisplay}` });
    }
  }
}

function matchesException(finding, exception) {
  if (exception.type && exception.type !== finding.type) return false;
  if (exception.file && exception.file !== finding.quest.file) return false;
  if (exception.quest && Number(exception.quest) !== Number(finding.quest.id)) return false;
  if (exception.source && exception.source !== finding.quest.source) return false;
  if (exception.npc && exception.npc !== finding.quest.npc) return false;
  if (exception.chapter && exception.chapter !== finding.quest.chapter) return false;
  if (exception.name && exception.name !== finding.quest.name) return false;
  if (exception.remoteContains && !String(finding.remote || "").includes(exception.remoteContains)) return false;
  return true;
}

const suppressedFindings = [];
const visibleFindings = [];
const usedExceptionIndexes = new Set();
for (const finding of findings) {
  const exceptionIndex = exceptions.findIndex((candidate) => matchesException(finding, candidate));
  const exception = exceptionIndex >= 0 ? exceptions[exceptionIndex] : null;
  if (exception) {
    usedExceptionIndexes.add(exceptionIndex);
    suppressedFindings.push({ ...finding, exception: exception.reason || "audit exception", exceptionIndex });
  }
  else visibleFindings.push(finding);
}

const unmatchedExceptions = exceptions
  .map((exception, index) => ({ index, ...exception }))
  .filter((exception) => !usedExceptionIndexes.has(exception.index));

visibleFindings.sort((a, b) => a.quest.file.localeCompare(b.quest.file) || String(a.quest.id).localeCompare(String(b.quest.id)));
suppressedFindings.sort((a, b) => a.quest.file.localeCompare(b.quest.file) || String(a.quest.id).localeCompare(String(b.quest.id)));

const questsBySource = quests.reduce((counts, quest) => {
  counts[quest.source] = (counts[quest.source] || 0) + 1;
  return counts;
}, {});
const questKeysBySource = questKeys.reduce((counts, quest) => {
  counts[quest.source] = (counts[quest.source] || 0) + 1;
  return counts;
}, {});
const qaReport = includeQaReport ? datasets.map((data) => {
  const firstQuest = data.quests[0];
  const firstIncompletePath = firstQuest ? {
    quest: firstQuest.name,
    npc: firstQuest.npc || null,
    place: firstQuest.location || null,
    mapID: firstQuest.mapID || null,
  } : null;
  return {
    story: data.story,
    file: data.rel,
    source: data.source,
    quests: data.quests.length,
    firstIncompletePath,
  };
}) : undefined;

console.log(JSON.stringify({
  files: datasets.length,
  quests: quests.length,
  questsBySource,
  uniqueQuestKeys: questKeys.length,
  questKeysBySource,
  fullQuestPages: [...questData.values()].filter((quest) => !quest.pageError).length,
  tooltipQuestFallbacks: [...questData.values()].filter((quest) => quest.pageError).length,
  findings: visibleFindings,
  suppressedFindings,
  unmatchedExceptions,
  qaReport,
}, null, 2));
