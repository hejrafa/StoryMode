import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { loadDatasets } from "./story-data-utils.mjs";

const root = process.argv[2] || process.cwd();
const applyChanges = process.argv.includes("--apply");
const cacheOnly = process.argv.includes("--cache-only");
const localeTargets = {
  deDE: { path: "de", key: "name_dede" },
  esES: { path: "es", key: "name_eses" },
  frFR: { path: "fr", key: "name_frfr" },
  ptBR: { path: "pt", key: "name_ptbr" },
  ruRU: { path: "ru", key: "name_ruru" },
};
const cacheDir = path.join(root, ".localization-cache");
const cachePath = path.join(cacheDir, "official-wowhead-quest-names.json");
const requestConcurrency = 2;
const luaByteDecoder = new TextDecoder("utf-8");

function unescapeLuaString(value) {
  let output = "";
  let byteRun = [];
  const flushBytes = () => {
    if (byteRun.length === 0) return;
    output += luaByteDecoder.decode(Uint8Array.from(byteRun));
    byteRun = [];
  };
  for (let index = 0; index < value.length; index += 1) {
    const char = value[index];
    if (char !== "\\") {
      flushBytes();
      output += char;
      continue;
    }
    const next = value[index + 1];
    if (next === undefined) {
      flushBytes();
      output += "\\";
      continue;
    }
    if (/\d/.test(next)) {
      let digits = next;
      index += 1;
      while (digits.length < 3 && /\d/.test(value[index + 1] || "")) {
        digits += value[index + 1];
        index += 1;
      }
      byteRun.push(Number(digits));
      continue;
    }
    flushBytes();
    index += 1;
    if (next === "n") output += "\n";
    else if (next === "r") output += "\r";
    else if (next === "t") output += "\t";
    else if (next === '"') output += '"';
    else if (next === "\\") output += "\\";
    else output += next;
  }
  flushBytes();
  return output;
}

function escapeLuaString(value) {
  return value
    .replace(/\\/g, "\\\\")
    .replace(/\r/g, "")
    .replace(/\n/g, "\\n")
    .replace(/"/g, '\\"');
}

function extractLocaleEntryRecords(text) {
  const records = [];
  const re = /L\["((?:[^"\\]|\\.)*)"\]\s*=\s*"((?:[^"\\]|\\.)*)"/g;
  let match;
  while ((match = re.exec(text))) {
    records.push({
      start: match.index,
      end: re.lastIndex,
      raw: match[0],
      key: unescapeLuaString(match[1]),
      value: unescapeLuaString(match[2]),
    });
  }
  return records;
}

function extractLocaleEntries(text) {
  return new Map(extractLocaleEntryRecords(text).map((record) => [record.key, record.value]));
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function titleFromHtml(html) {
  const h1 = html.match(/<h1[^>]*>(.*?)<\/h1>/s)?.[1];
  if (h1) return htmlDecode(h1.replace(/<[^>]+>/g, "").trim());
  const title = html.match(/<title>(.*?)<\/title>/s)?.[1];
  if (!title) return null;
  return htmlDecode(title.split(" - ")[0].trim());
}

function htmlDecode(value) {
  return (value || "")
    .replace(/&quot;/g, '"')
    .replace(/&#039;/g, "'")
    .replace(/&apos;/g, "'")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">");
}

function officialNameFromHtml(html, id, preferredKey) {
  const gatherer = html.match(new RegExp(`WH\\.Gatherer\\.addData\\(5,\\s*\\d+,\\s*(\\{[^\\n]*"${id}"[\\s\\S]*?\\})\\);`));
  if (gatherer) {
    try {
      const parsed = JSON.parse(gatherer[1]);
      const entry = parsed[String(id)];
      if (entry) {
        if (entry[preferredKey]) return entry[preferredKey];
        const localized = Object.entries(entry).find(([key]) => key.startsWith("name_"));
        if (localized) return localized[1];
        if (entry.name) return entry.name;
      }
    } catch {}
  }
  return titleFromHtml(html);
}

function questUrl(source, localePath, id) {
  if (source === "classic") {
    return `https://www.wowhead.com/classic/${localePath}/quest=${id}`;
  }
  return `https://www.wowhead.com/${localePath}/quest=${id}`;
}

async function loadCache() {
  try {
    return JSON.parse(await readFile(cachePath, "utf8"));
  } catch {
    return {};
  }
}

async function saveCache(cache) {
  await mkdir(cacheDir, { recursive: true });
  await writeFile(cachePath, JSON.stringify(cache, null, 2) + "\n");
}

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

async function fetchOfficialName(quest, locale, localeInfo, cache) {
  const cacheKey = `${locale}\u0000${quest.source}\u0000${quest.id}`;
  if (cache[cacheKey] !== undefined) return cache[cacheKey] || null;
  if (cacheOnly) return null;

  const url = questUrl(quest.source, localeInfo.path, quest.id);
  for (let attempt = 1; attempt <= 4; attempt++) {
    try {
      const response = await fetch(url, {
        headers: {
          "user-agent": "StoryMode official localization pass",
          "accept-language": `${localeInfo.path},en;q=0.8`,
        },
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const html = await response.text();
      const official = officialNameFromHtml(html, quest.id, localeInfo.key);
      cache[cacheKey] = official || "";
      return official || null;
    } catch (error) {
      if (attempt === 4) {
        console.warn(`${locale}: failed quest ${quest.id} (${quest.source}): ${error.message}`);
        return null;
      }
      await new Promise((resolve) => setTimeout(resolve, attempt * 1000));
    }
  }
  return null;
}

function rewriteLocaleText(text, directUpdates, phraseReplacements) {
  const records = extractLocaleEntryRecords(text);
  let out = "";
  let cursor = 0;
  let changedEntries = 0;
  for (const record of records) {
    out += text.slice(cursor, record.start);
    let value = record.value;
    let changed = false;
    const direct = directUpdates.get(record.key);
    if (direct) {
      changed = value !== direct;
      value = direct;
    } else {
      for (const [from, to] of phraseReplacements) {
        if (from && from !== to && value.includes(from)) {
          value = value.replace(new RegExp(escapeRegex(from), "g"), to);
          changed = true;
        }
      }
    }
    if (!changed) {
      out += record.raw;
      cursor = record.end;
      continue;
    }
    const rewritten = `L["${escapeLuaString(record.key)}"] = "${escapeLuaString(value)}"`;
    if (rewritten !== record.raw) changedEntries += 1;
    out += rewritten;
    cursor = record.end;
  }
  out += text.slice(cursor);
  return { text: out, changedEntries };
}

function safePhraseCandidate(value) {
  if (!value || value.length < 8) return false;
  if (/%(?:\d+\$)?[sdqfg]/.test(value)) return false;
  if (/^[a-z]+$/i.test(value)) return false;
  return true;
}

function normalizeQuestName(value) {
  return (value || "")
    .toLowerCase()
    .replace(/[“”"'’]/g, "")
    .replace(/[^a-z0-9]+/g, " ")
    .trim()
    .replace(/\s+/g, " ");
}

function isEnglishFallbackName(official, english) {
  return normalizeQuestName(official) === normalizeQuestName(english);
}

const datasets = await loadDatasets(root);
const questBySourceID = new Map();
for (const data of datasets) {
  for (const quest of [data.startQuest, ...data.quests].filter(Boolean)) {
    const source = quest.source || data.source;
    questBySourceID.set(`${source}\u0000${quest.id}`, {
      source,
      id: quest.id,
      name: quest.name,
    });
  }
}
const quests = [...questBySourceID.values()].sort((a, b) => a.source.localeCompare(b.source) || a.id - b.id);
const cache = await loadCache();

for (const [locale, localeInfo] of Object.entries(localeTargets)) {
  console.log(`${locale}: ${cacheOnly ? "checking cached official names" : "fetching official names"} for ${quests.length} quest IDs`);
  const officialByEnglish = new Map();
  let englishFallbacks = 0;
  let processed = 0;
  await mapLimit(quests, requestConcurrency, async (quest) => {
    const official = await fetchOfficialName(quest, locale, localeInfo, cache);
    processed += 1;
    if (processed % 250 === 0) {
      console.log(`${locale}: ${processed}/${quests.length}`);
      await saveCache(cache);
    }
    if (!official) return;
    if (isEnglishFallbackName(official, quest.name)) {
      englishFallbacks += 1;
      return;
    }
    const names = officialByEnglish.get(quest.name) || new Map();
    names.set(official, (names.get(official) || 0) + 1);
    officialByEnglish.set(quest.name, names);
  });
  await saveCache(cache);

  const localePath = path.join(root, "Locales", `${locale}.lua`);
  const localeText = await readFile(localePath, "utf8");
  const localeEntries = extractLocaleEntries(localeText);
  const directUpdates = new Map();
  const phraseReplacements = [];
  const conflicts = [];
  for (const [english, counts] of officialByEnglish) {
    const sorted = [...counts.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]));
    if (sorted.length > 1 && sorted[0][1] === sorted[1][1]) {
      conflicts.push({ english, candidates: sorted.map(([name]) => name) });
      continue;
    }
    const official = sorted[0][0];
    if (!official || !localeEntries.has(english)) continue;
    const oldValue = localeEntries.get(english);
    directUpdates.set(english, official);
    for (const candidate of [english, oldValue]) {
      if (safePhraseCandidate(candidate) && candidate !== official) {
        phraseReplacements.push([candidate, official]);
      }
    }
  }
  phraseReplacements.sort((a, b) => b[0].length - a[0].length);
  const result = rewriteLocaleText(localeText, directUpdates, phraseReplacements);
  if (applyChanges) {
    await writeFile(localePath, result.text, "utf8");
  }
  console.log(`${locale}: ${directUpdates.size} quest-title keys, ${result.changedEntries} locale entries ${applyChanges ? "changed" : "would change"}, ${conflicts.length} conflicts skipped, ${englishFallbacks} English-fallback names skipped`);
  if (conflicts.length > 0) {
    console.log(`${locale}: skipped conflicts: ${conflicts.slice(0, 10).map((c) => c.english).join(", ")}${conflicts.length > 10 ? "..." : ""}`);
  }
}
