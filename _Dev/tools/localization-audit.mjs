import { readFile, readdir } from "node:fs/promises";
import path from "node:path";

const root = process.argv[2] || process.cwd();
const localeFiles = ["deDE", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW"];

function extractLocaleEntries(text) {
  const entries = new Map();
  for (const record of extractLocaleEntryRecords(text)) {
    entries.set(record.key, record.value);
  }
  return entries;
}

function extractLocaleEntryRecords(text) {
  const records = [];
  const re = /L\["((?:[^"\\]|\\.)*)"\]\s*=\s*"((?:[^"\\]|\\.)*)"/g;
  let match;
  while ((match = re.exec(text))) {
    records.push({
      key: unescapeLuaString(match[1]),
      value: unescapeLuaString(match[2]),
      rawValue: match[2],
    });
  }
  return records;
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
  return value
    .replace(/\\n/g, "\n")
    .replace(/\\"/g, '"')
    .replace(/\\\\/g, "\\");
}

function extractDataStrings(text) {
  const strings = new Set();
  const re = /\b(?:title|description|zone|expansion|adventureGuideInstanceName|chapter|summary|recap|note|achievementName|name|displayName|npc|location|faction|level|trackingHint|trackingHintFormat|trackingHintQuestName|trackingHintPlace|trackingHintNPC|trackingHintDestination)\s*=\s*"((?:[^"\\]|\\.)*)"/g;
  let match;
  while ((match = re.exec(text))) {
    strings.add(unescapeLuaString(match[1]));
  }
  return strings;
}

// Positional arguments (%2$s) may reorder a sentence; compare the type expected at each argument index.
function specs(value) {
  return [...value.matchAll(/%(?:(\d+)\$)?([sdqfg])/g)]
    .map((match, index) => [match[1] ? Number(match[1]) : index + 1, match[2]])
    .sort((a, b) => a[0] - b[0])
    .map(([position, type]) => `${position}:${type}`)
    .join(",");
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

const protectedTerms = ["Story Mode", "Dialogue UI", "Warcraft", "WoW"];
const protectedTermPattern = protectedTerms.map(escapeRegex).join("|");
const gluedProtectedTerm = new RegExp(`\\p{L}(?:${protectedTermPattern})|(?:${protectedTermPattern})\\p{L}`, "u");
const gluedPlaceholder = /\p{L}%(?:\d+\$)?[sdqfg]|%(?:\d+\$)?[sdqfg]\p{L}/u;
const invisibleSpacing = /[\u00A0\u1680\u180E\u2000-\u200F\u2028\u2029\u202F\u205F\u2060\uFEFF]/u;

// Chinese writes without spaces and Korean attaches particles directly ("Story Mode를"), so
// adjacency to letters is normal there rather than a sign of a broken machine join.
const unspacedLocales = new Set(["koKR", "zhCN", "zhTW"]);

function localeValueFindings(value, rawValue, locale) {
  const findings = [];
  if (/SMTOK|SMESC|__SM/i.test(value) || /SMTOK|SMESC|__SM/i.test(rawValue)) {
    findings.push("machine token artifact");
  }
  if (/\\\\\d{2,3}/.test(rawValue)) {
    findings.push("double-escaped numeric byte sequence");
  }
  if (value.includes("�")) {
    findings.push("replacement character");
  }
  if (invisibleSpacing.test(value)) {
    findings.push("invisible or non-breaking spacing character");
  }
  if (unspacedLocales.has(locale)) {
    return findings;
  }
  if (gluedProtectedTerm.test(value)) {
    findings.push("protected term glued to surrounding text");
  }
  if (gluedPlaceholder.test(value)) {
    findings.push("format placeholder glued to surrounding text");
  }
  return findings;
}

const enText = await readFile(`${root}/Locales/enUS.lua`, "utf8");
const enEntries = extractLocaleEntries(enText);
const contentStart = enText.indexOf("-- BEGIN CONTENT STRINGS");
const contentEntries = extractLocaleEntries(contentStart >= 0 ? enText.slice(contentStart) : "");
const sourceKeys = new Set(enEntries.keys());
const dataFiles = await walk(`${root}/Data`);
const dataKeysMissingFromEnglish = new Set();
for (const dataFile of dataFiles) {
  for (const key of extractDataStrings(await readFile(dataFile, "utf8"))) {
    sourceKeys.add(key);
    if (!enEntries.has(key)) dataKeysMissingFromEnglish.add(key);
  }
}

const report = {};
const findings = [];

// A data string with no enUS entry never reaches the locale files, so every
// client shows it in English.
for (const key of dataKeysMissingFromEnglish) {
  findings.push(`${root}/Locales/enUS.lua: missing data string ${key}`);
}

for (const locale of localeFiles) {
  const localePath = `${root}/Locales/${locale}.lua`;
  const localeText = await readFile(localePath, "utf8");
  const localeRecords = extractLocaleEntryRecords(localeText);
  const localeEntries = extractLocaleEntries(localeText);
  let contentOverrides = 0;

  for (const { key, value, rawValue } of localeRecords) {
    if (!sourceKeys.has(key)) {
      findings.push(`${localePath}: unknown key ${key}`);
      continue;
    }
    if (enEntries.has(key) && specs(enEntries.get(key)) !== specs(value)) {
      findings.push(`${localePath}: placeholder mismatch for ${key}`);
    }
    for (const valueFinding of localeValueFindings(value, rawValue, locale)) {
      findings.push(`${localePath}: ${valueFinding} for ${key}`);
    }
    if (contentEntries.has(key)) {
      contentOverrides += 1;
    }
  }

  report[locale] = {
    overrides: localeEntries.size,
    contentOverrides,
    englishFallback: enEntries.size - localeEntries.size,
  };
  if (report[locale].englishFallback > 0) {
    findings.push(`${localePath}: ${report[locale].englishFallback} keys fall back to English`);
  }
}

if (findings.length > 0) {
  console.error(JSON.stringify({ findings }, null, 2));
  process.exit(1);
}

console.log(JSON.stringify({
  englishKeys: enEntries.size,
  englishContentKeys: contentEntries.size,
  sourceKeys: sourceKeys.size,
  locales: report,
  findings: [],
}, null, 2));
