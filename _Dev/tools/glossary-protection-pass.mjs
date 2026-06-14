import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { loadDatasets } from "./story-data-utils.mjs";

const root = process.argv[2] || process.cwd();
const applyChanges = process.argv.includes("--apply");
const locales = ["deDE", "esES", "frFR", "ptBR", "ruRU"];
const nonLatinApplyLocales = new Set(["ruRU"]);
const reportPath = path.join(root, ".localization-cache", "glossary-protection-candidates.json");
const dictionaryPath = "/usr/share/dict/words";
const luaByteDecoder = new TextDecoder("utf-8");

const genericNameWords = new Set([
  "a", "an", "and", "at", "by", "for", "from", "in", "into", "of", "on", "or", "the", "to", "with",
  "admiral", "advisor", "apothecary", "archdruid", "archmage", "artist", "baron", "baroness", "brother",
  "captain", "chief", "clerk", "commander", "crusader", "deathguard", "deathstalker", "doctor", "duke",
  "executor", "fleet", "general", "high", "highlord", "highlord's", "innkeeper", "keeper", "king", "lady",
  "librarian", "lord", "marshal", "master", "mistress", "mother", "prince", "princess", "queen", "sage",
  "sentinel", "shadow", "sister", "sir", "spirit", "the", "watcher",
  "altar", "book", "chest", "crate", "dirt", "disc", "discs", "door", "footlocker", "fragment", "fragments",
  "gem", "hand", "journal", "mound", "orb", "page", "relic", "remains", "scroll", "shard", "tablet", "tablets",
  "tome", "totem",
]);

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

async function loadEnglishWords() {
  try {
    const words = await readFile(dictionaryPath, "utf8");
    return new Set(words.split(/\r?\n/).map((word) => word.trim().toLowerCase()).filter(Boolean));
  } catch {
    return new Set();
  }
}

function normalizedDictionaryForms(word) {
  const lower = word.toLowerCase().replace(/[^a-z]/g, "");
  const forms = new Set([lower]);
  if (lower.endsWith("ies") && lower.length > 4) forms.add(`${lower.slice(0, -3)}y`);
  if (lower.endsWith("s") && lower.length > 4) forms.add(lower.slice(0, -1));
  if (lower.endsWith("ed") && lower.length > 5) {
    forms.add(lower.slice(0, -2));
    forms.add(`${lower.slice(0, -1)}`);
  }
  if (lower.endsWith("ing") && lower.length > 6) {
    forms.add(lower.slice(0, -3));
    forms.add(`${lower.slice(0, -3)}e`);
  }
  return [...forms].filter(Boolean);
}

function hasDictionaryForm(word, englishWords) {
  return normalizedDictionaryForms(word).some((form) => englishWords.has(form));
}

function isDictionaryCompound(word, englishWords) {
  const lower = word.toLowerCase().replace(/[^a-z]/g, "");
  if (lower.length < 8) return false;
  for (let index = 3; index <= lower.length - 3; index += 1) {
    const left = lower.slice(0, index);
    const right = lower.slice(index);
    if (hasDictionaryForm(left, englishWords) && hasDictionaryForm(right, englishWords)) return true;
  }
  return false;
}

function anchorsForTerm(term, englishWords) {
  const words = term.match(/[A-Za-z][A-Za-z'’.-]*/g) || [];
  const anchors = [];
  for (const word of words) {
    const normalized = word.replace(/^[^A-Za-z]+|[^A-Za-z]+$/g, "").replace(/['’]s$/i, "");
    if (normalized.length < 4) continue;
    if (genericNameWords.has(normalized.toLowerCase())) continue;
    if (hasDictionaryForm(normalized, englishWords) && !/['’.-]/.test(normalized)) continue;
    if (isDictionaryCompound(normalized, englishWords)) continue;
    anchors.push(normalized);
  }
  return [...new Set(anchors)];
}

function normalizeForAnchorMatch(value) {
  return value.normalize("NFD").replace(/\p{M}/gu, "");
}

function containsAnyAnchor(value, anchors) {
  const normalizedValue = normalizeForAnchorMatch(value);
  return anchors.some((anchor) => {
    const normalizedAnchor = normalizeForAnchorMatch(anchor);
    return new RegExp(`(^|[^\\p{L}])${escapeRegex(normalizedAnchor)}(?:['’]s|s)?([^\\p{L}]|$)`, "iu").test(normalizedValue);
  });
}

function rewriteLocaleText(text, directUpdates) {
  const records = extractLocaleEntryRecords(text);
  let out = "";
  let cursor = 0;
  let changedEntries = 0;
  for (const record of records) {
    out += text.slice(cursor, record.start);
    const direct = directUpdates.get(record.key);
    if (!direct) {
      out += record.raw;
      cursor = record.end;
      continue;
    }
    const value = direct;
    const rewritten = `L["${escapeLuaString(record.key)}"] = "${escapeLuaString(value)}"`;
    if (rewritten !== record.raw) changedEntries += 1;
    out += rewritten;
    cursor = record.end;
  }
  out += text.slice(cursor);
  return { text: out, changedEntries };
}

const datasets = await loadDatasets(root);
const englishWords = await loadEnglishWords();
const protectedTerms = new Map();
for (const data of datasets) {
  for (const quest of [data.startQuest, ...data.quests].filter(Boolean)) {
    for (const value of [quest.npc, quest.trackingHintNPC]) {
      if (!value) continue;
      const anchors = anchorsForTerm(value, englishWords);
      if (anchors.length > 0) protectedTerms.set(value, anchors);
    }
  }
}

console.log(`Protected glossary terms with anchors: ${protectedTerms.size}`);

const report = {};
for (const locale of locales) {
  const localePath = path.join(root, "Locales", `${locale}.lua`);
  const localeText = await readFile(localePath, "utf8");
  const localeEntries = extractLocaleEntries(localeText);
  const directUpdates = new Map();
  const candidates = [];
  for (const [term, anchors] of protectedTerms) {
    const current = localeEntries.get(term);
    if (!current || containsAnyAnchor(current, anchors)) continue;
    candidates.push({ term, current, anchors });
    directUpdates.set(term, term);
  }
  report[locale] = candidates;
  if (!applyChanges) {
    console.log(`${locale}: ${candidates.length} candidate glossary keys`);
    continue;
  }
  if (nonLatinApplyLocales.has(locale)) {
    console.log(`${locale}: ${candidates.length} candidates skipped; use official localized names or native review for non-Latin scripts`);
    continue;
  }
  const result = rewriteLocaleText(localeText, directUpdates);
  await writeFile(localePath, result.text, "utf8");
  console.log(`${locale}: ${directUpdates.size} glossary keys locked, ${result.changedEntries} entries changed`);
}

await mkdir(path.dirname(reportPath), { recursive: true });
await writeFile(reportPath, JSON.stringify(report, null, 2) + "\n", "utf8");
console.log(`Report written to ${path.relative(root, reportPath)}`);
