import { readFile, readdir } from "node:fs/promises";
import path from "node:path";

const root = process.argv[2] || process.cwd();
const localeFiles = ["deDE", "frFR", "ruRU"];

function extractLocaleEntries(text) {
  const entries = new Map();
  const re = /L\["((?:[^"\\]|\\.)*)"\]\s*=\s*"((?:[^"\\]|\\.)*)"/g;
  let match;
  while ((match = re.exec(text))) {
    entries.set(unescapeLuaString(match[1]), unescapeLuaString(match[2]));
  }
  return entries;
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
  const re = /\b(?:title|description|zone|expansion|adventureGuideInstanceName|chapter|summary|recap|note|achievementName|name|displayName|npc|location|faction|level)\s*=\s*"((?:[^"\\]|\\.)*)"/g;
  let match;
  while ((match = re.exec(text))) {
    strings.add(unescapeLuaString(match[1]));
  }
  return strings;
}

function specs(value) {
  return [...value.matchAll(/%(?:\d+\$)?[sdqfg]/g)].map((match) => match[0]).join(",");
}

const enText = await readFile(`${root}/Locales/enUS.lua`, "utf8");
const enEntries = extractLocaleEntries(enText);
const contentStart = enText.indexOf("-- BEGIN CONTENT STRINGS");
const contentEntries = extractLocaleEntries(enText.slice(contentStart));
const sourceKeys = new Set(enEntries.keys());
const dataFiles = await walk(`${root}/Data`);
for (const dataFile of dataFiles) {
  for (const key of extractDataStrings(await readFile(dataFile, "utf8"))) {
    sourceKeys.add(key);
  }
}

const report = {};
const findings = [];

for (const locale of localeFiles) {
  const localePath = `${root}/Locales/${locale}.lua`;
  const localeEntries = extractLocaleEntries(await readFile(localePath, "utf8"));
  let contentOverrides = 0;

  for (const [key, value] of localeEntries) {
    if (!sourceKeys.has(key)) {
      findings.push(`${localePath}: unknown key ${key}`);
      continue;
    }
    if (enEntries.has(key) && specs(enEntries.get(key)) !== specs(value)) {
      findings.push(`${localePath}: placeholder mismatch for ${key}`);
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
