import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import path from "node:path";

const root = process.argv[2] || process.cwd();
const cacheDir = path.join(root, ".meta-audit-cache");
const dataRoot = path.join(root, "Data");

const namedAchievements = new Map([
  ["explore drustvar", 12557],
  ["explore nazmir", 12561],
  ["explore revendreth", 14306],
  ["explore suramar", 10669],
  ["explore jade forest", 6351],
]);

const factionNames = new Map([
  [68, "Undercity"],
  [1098, "Knights of the Ebon Blade"],
  [1106, "Argent Crusade"],
  [1156, "The Ashen Verdict"],
  [1228, "Forest Hozen"],
  [1242, "Pearlfin Jinyu"],
  [1271, "Order of the Cloud Serpent"],
  [1859, "The Nightfallen"],
  [2103, "Zandalari Empire"],
  [2156, "Talanji's Expedition"],
  [2157, "The Honorbound"],
  [2159, "7th Legion"],
  [2160, "Proudmoore Admiralty"],
  [2161, "Order of Embers"],
  [2162, "Storm's Wake"],
  [2413, "Court of Harvesters"],
  [2439, "The Avowed"],
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

function unescapeLuaString(value) {
  return value.replace(/\\"/g, '"').replace(/\\\\/g, "\\");
}

function extractString(text, key) {
  const match = text.match(new RegExp(`${key}\\s*=\\s*"((?:[^"\\\\]|\\\\.)*)"`));
  return match ? unescapeLuaString(match[1]) : null;
}

function stripLineComment(line) {
  return line.replace(/--.*$/, "");
}

function tableBodies(text, key) {
  const bodies = [];
  const re = new RegExp(`\\b${key}\\s*=\\s*\\{`, "g");
  let match;
  while ((match = re.exec(text))) {
    let index = match.index + match[0].length;
    let depth = 1;
    const start = index;
    for (; index < text.length; index++) {
      if (text[index] === "{") depth++;
      else if (text[index] === "}") {
        depth--;
        if (depth === 0) {
          bodies.push(text.slice(start, index));
          break;
        }
      }
    }
  }
  return bodies;
}

function addUse(map, id, use) {
  if (!map.has(id)) map.set(id, []);
  map.get(id).push(use);
}

function parseDataFile(file, text) {
  const rel = path.relative(root, file);
  const story = extractString(text, "title") || rel;
  const achievements = new Map();
  const named = new Map();
  const factions = new Map();
  const commentChecks = [];

  for (const match of text.matchAll(/\bachievementID\s*=\s*(\d+)/g)) {
    addUse(achievements, Number(match[1]), { file: rel, story, kind: "achievementID" });
  }

  for (const key of ["achievementIDByFaction", "achievements", "achievementsByFaction"]) {
    for (const body of tableBodies(text, key)) {
      for (const line of body.split(/\r?\n/)) {
        const clean = stripLineComment(line);
        for (const match of clean.matchAll(/\b(\d+)\b/g)) {
          const id = Number(match[1]);
          addUse(achievements, id, { file: rel, story, kind: key });
          const comment = line.split("--")[1]?.trim();
          if (comment) commentChecks.push({ id, comment, file: rel, story, kind: key });
        }
        for (const match of clean.matchAll(/"((?:[^"\\]|\\.)*)"/g)) {
          const name = unescapeLuaString(match[1]);
          addUse(named, name, { file: rel, story, kind: key });
        }
      }
    }
  }

  for (const key of ["factions", "factionsByFaction"]) {
    for (const body of tableBodies(text, key)) {
      for (const line of body.split(/\r?\n/)) {
        const clean = stripLineComment(line);
        for (const match of clean.matchAll(/\b(\d+)\b/g)) {
          addUse(factions, Number(match[1]), { file: rel, story, kind: key });
        }
      }
    }
  }

  return { achievements, named, factions, commentChecks };
}

async function fetchCached(kind, id, url) {
  await mkdir(path.join(cacheDir, kind), { recursive: true });
  const cachePath = path.join(cacheDir, kind, `${id}.json`);
  try {
    return JSON.parse(await readFile(cachePath, "utf8"));
  } catch {}
  const response = await fetch(url, {
    headers: {
      "user-agent": "StoryMode meta audit (local addon maintenance)",
      "accept-language": "en-US,en;q=0.9",
    },
  });
  if (!response.ok) throw new Error(`${response.status} ${response.statusText} for ${url}`);
  const data = await response.json();
  await writeFile(cachePath, JSON.stringify(data, null, 2));
  return data;
}

function norm(value) {
  return (value || "")
    .toLowerCase()
    .replace(/&amp;/g, "&")
    .replace(/&#039;/g, "'")
    .replace(/[^a-z0-9'&]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function commentExpectedName(comment) {
  return comment
    .replace(/\([^)]*\)/g, "")
    .replace(/[—-].*$/, "")
    .trim();
}

const files = await walk(dataRoot);

const allAchievementUses = new Map();
const allNamedAchievementUses = new Map();
const allFactionUses = new Map();
const commentChecks = [];

for (const file of files) {
  const parsed = parseDataFile(file, await readFile(file, "utf8"));
  for (const [id, uses] of parsed.achievements) for (const use of uses) addUse(allAchievementUses, id, use);
  for (const [name, uses] of parsed.named) for (const use of uses) addUse(allNamedAchievementUses, name, use);
  for (const [id, uses] of parsed.factions) for (const use of uses) addUse(allFactionUses, id, use);
  commentChecks.push(...parsed.commentChecks);
}

const findings = [];
const achievementData = new Map();
const achievementIds = [...allAchievementUses.keys()].sort((a, b) => a - b);
await mapLimit(achievementIds, 8, async (id) => {
  try {
    const data = await fetchCached("achievement", id, `https://nether.wowhead.com/tooltip/achievement/${id}`);
    achievementData.set(id, data);
    if (!data.name) {
      for (const use of allAchievementUses.get(id)) {
        findings.push({ type: "achievement", severity: "error", id, use, remote: data.error || "missing achievement name" });
      }
    }
  } catch (error) {
    for (const use of allAchievementUses.get(id)) {
      findings.push({ type: "achievement-fetch", severity: "error", id, use, remote: error.message });
    }
  }
});

for (const [name, uses] of allNamedAchievementUses) {
  const id = namedAchievements.get(norm(name));
  if (!id) {
    for (const use of uses) findings.push({ type: "achievement-name", severity: "warn", name, use, remote: "not in local resolver map" });
    continue;
  }
  const data = achievementData.get(id) || await fetchCached("achievement", id, `https://nether.wowhead.com/tooltip/achievement/${id}`);
  achievementData.set(id, data);
  if (norm(data.name) !== norm(name)) {
    for (const use of uses) findings.push({ type: "achievement-name", severity: "error", name, use, remote: `${id}: ${data.name}` });
  }
}

for (const check of commentChecks) {
  const data = achievementData.get(check.id);
  const expected = commentExpectedName(check.comment);
  if (!data?.name || !expected || expected.length < 4) continue;
  if (!norm(data.name).startsWith(norm(expected)) && !norm(expected).startsWith(norm(data.name))) {
    findings.push({ type: "achievement-comment", severity: "warn", id: check.id, use: check, remote: data.name });
  }
}

for (const [id, uses] of allFactionUses) {
  const name = factionNames.get(id);
  if (!name) {
    for (const use of uses) findings.push({ type: "faction", severity: "error", id, use, remote: "not in known faction map" });
  }
}

findings.sort((a, b) =>
  (a.use?.file || "").localeCompare(b.use?.file || "") ||
  String(a.id || a.name).localeCompare(String(b.id || b.name))
);

console.log(JSON.stringify({
  files: files.length,
  achievements: [...allAchievementUses.values()].reduce((sum, uses) => sum + uses.length, 0),
  uniqueAchievementIds: allAchievementUses.size,
  namedAchievements: [...allNamedAchievementUses.values()].reduce((sum, uses) => sum + uses.length, 0),
  factions: [...allFactionUses.values()].reduce((sum, uses) => sum + uses.length, 0),
  uniqueFactionIds: allFactionUses.size,
  factionNames: Object.fromEntries([...allFactionUses.keys()].sort((a, b) => a - b).map((id) => [id, factionNames.get(id)])),
  findings,
}, null, 2));
