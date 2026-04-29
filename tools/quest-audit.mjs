import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import path from "node:path";

const root = process.argv[2] || process.cwd();
const scope = process.argv[3] || "";
const cacheDir = path.join(root, ".quest-audit-cache");

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

function unescapeLuaString(value) {
  return value.replace(/\\"/g, '"').replace(/\\\\/g, "\\");
}

function extractString(line, key) {
  const match = line.match(new RegExp(`${key}\\s*=\\s*"((?:[^"\\\\]|\\\\.)*)"`));
  return match ? unescapeLuaString(match[1]) : null;
}

function parseDataFile(file, text) {
  const rel = path.relative(root, file);
  const story = extractString(text, "title") || rel;
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
    if (idMatch && name) {
      quests.push({
        id: Number(idMatch[1]),
        name,
        npc,
        story,
        chapter,
        file: rel,
        line: line.trim(),
      });
    }
  }

  return { rel, story, quests, npcLocations, npcDisplayIDs, chapterDisplayIDs };
}

function htmlDecode(value) {
  return value
    .replace(/&quot;/g, '"')
    .replace(/&#039;/g, "'")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">");
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

async function fetchQuestData(id) {
  try {
    const html = await fetchCached("quest", id, `https://www.wowhead.com/quest=${id}`);
    return parseQuestPage(id, html);
  } catch (pageError) {
    const tooltip = await fetchCached("quest-tooltip", id, `https://nether.wowhead.com/tooltip/quest/${id}`);
    const data = JSON.parse(tooltip);
    return {
      id,
      title: data.name || null,
      series: [],
      starts: [],
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

function distance(a, b) {
  if (!a || !b) return null;
  const ax = a.x <= 1 ? a.x * 100 : a.x;
  const ay = a.y <= 1 ? a.y * 100 : a.y;
  const bx = b.x <= 1 ? b.x * 100 : b.x;
  const by = b.y <= 1 ? b.y * 100 : b.y;
  return Math.hypot(ax - bx, ay - by);
}

const files = (await walk(root))
  .filter((file) => /(?:Campaigns|Heritage|Storylines)\//.test(path.relative(root, file)))
  .filter((file) => !scope || path.relative(root, file).includes(scope));

const datasets = [];
for (const file of files) datasets.push(parseDataFile(file, await readFile(file, "utf8")));

const quests = datasets.flatMap((data) => data.quests);
const uniqueQuestIds = [...new Set(quests.map((quest) => quest.id))].sort((a, b) => a - b);
const questData = new Map();
const findings = [];
await mapLimit(uniqueQuestIds, 6, async (id, index) => {
  if (index % 50 === 0) console.error(`quests ${index}/${uniqueQuestIds.length}`);
  try {
    questData.set(id, await fetchQuestData(id));
  } catch (error) {
    const examples = quests.filter((quest) => quest.id === id);
    for (const quest of examples) {
      findings.push({ type: "fetch", severity: "error", quest, remote: error.message });
    }
  }
});

const npcIds = new Set();
for (const quest of quests) {
  const remote = questData.get(quest.id);
  if (!remote) continue;
  if (remote.title && norm(remote.title) !== norm(quest.name)) {
    findings.push({ type: "title", severity: "error", quest, remote: remote.title });
  }
  if (quest.npc && remote.starts.length && !remote.starts.some((start) => norm(start.name) === norm(quest.npc))) {
    findings.push({ type: "npc", severity: "warn", quest, remote: remote.starts.map((start) => `${start.name} (${start.id})`).join(", ") });
  }
  for (const start of remote.starts) npcIds.add(start.id);
}

for (const data of datasets) {
  const byChapter = new Map();
  for (const quest of data.quests) {
    if (!quest.chapter) continue;
    if (!byChapter.has(quest.chapter)) byChapter.set(quest.chapter, []);
    byChapter.get(quest.chapter).push(quest);
  }

  for (const [chapter, chapterQuests] of byChapter) {
    const series = questData.get(chapterQuests[0]?.id)?.series || [];
    if (!series.length) continue;
    const seriesIndex = new Map(series.map((quest, index) => [quest.id, index]));
    let previous = -1;
    for (const quest of chapterQuests) {
      if (!seriesIndex.has(quest.id)) continue;
      const index = seriesIndex.get(quest.id);
      if (index < previous) findings.push({ type: "order", severity: "warn", quest, remote: `series index ${index + 1} after ${previous + 1}` });
      previous = Math.max(previous, index);
    }
  }

  for (const [npcName, localLocation] of data.npcLocations) {
    const starts = data.quests
      .filter((quest) => norm(quest.npc) === norm(npcName))
      .flatMap((quest) => questData.get(quest.id)?.starts || [])
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
  const starts = questData.get(quest.id)?.starts || [];
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

findings.sort((a, b) => a.quest.file.localeCompare(b.quest.file) || String(a.quest.id).localeCompare(String(b.quest.id)));

console.log(JSON.stringify({
  files: datasets.length,
  quests: quests.length,
  uniqueQuestIds: uniqueQuestIds.length,
  fullQuestPages: [...questData.values()].filter((quest) => !quest.pageError).length,
  tooltipQuestFallbacks: [...questData.values()].filter((quest) => quest.pageError).length,
  findings,
}, null, 2));
