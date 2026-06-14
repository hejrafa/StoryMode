import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

const root = process.argv[2] || process.cwd();
const localeTargets = {
  deDE: "de",
  esES: "es",
  frFR: "fr",
  ptBR: "pt",
  ruRU: "ru",
};
const separator = "\n⟦STORY_MODE_LOCALE_SEPARATOR⟧\n";
const maxChunkChars = 3200;
const cacheDir = path.join(root, ".localization-cache");
const cachePath = path.join(cacheDir, "google-translate-cache.json");
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
      key: unescapeLuaString(match[1]),
      value: unescapeLuaString(match[2]),
    });
  }
  return records;
}

function extractLocaleEntries(text) {
  return new Map(extractLocaleEntryRecords(text).map((record) => [record.key, record.value]));
}

function protectFormats(value) {
  const tokens = [];
  const text = value.replace(/%(?:\d+\$)?[sdqfg]/g, (match) => {
    const token = `@@FMT${tokens.length}@@`;
    tokens.push({ token, value: match });
    return token;
  });
  return { text, tokens };
}

function restoreFormats(value, tokens) {
  let out = value;
  for (const { token, value: original } of tokens) {
    out = out.split(token).join(original);
  }
  return out;
}

function chunkKeys(keys) {
  const chunks = [];
  let current = [];
  let currentChars = 0;
  for (const key of keys) {
    const protectedKey = protectFormats(key).text;
    const nextChars = currentChars + protectedKey.length + separator.length;
    if (current.length > 0 && nextChars > maxChunkChars) {
      chunks.push(current);
      current = [];
      currentChars = 0;
    }
    current.push(key);
    currentChars += protectedKey.length + separator.length;
  }
  if (current.length > 0) chunks.push(current);
  return chunks;
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

async function translateText(text, targetLanguage, attempt = 1) {
  const params = new URLSearchParams({
    client: "gtx",
    sl: "en",
    tl: targetLanguage,
    dt: "t",
    q: text,
  });
  const response = await fetch(`https://translate.googleapis.com/translate_a/single?${params}`);
  if (!response.ok) {
    if (attempt < 4) {
      await new Promise((resolve) => setTimeout(resolve, attempt * 1500));
      return translateText(text, targetLanguage, attempt + 1);
    }
    throw new Error(`translation request failed with HTTP ${response.status}`);
  }
  const data = await response.json();
  return data[0].map((part) => part[0]).join("");
}

async function translateChunk(keys, targetLanguage, cache) {
  const prepared = keys.map((key) => protectFormats(key));
  const source = prepared.map((entry) => entry.text).join(separator);
  const translated = await translateText(source, targetLanguage);
  const parts = translated.split(separator.trim()).map((part) => part.trim());
  if (parts.length !== keys.length) {
    const out = [];
    for (const key of keys) {
      const preparedSingle = protectFormats(key);
      const translatedSingle = await translateText(preparedSingle.text, targetLanguage);
      out.push(restoreFormats(translatedSingle.trim(), preparedSingle.tokens));
    }
    return out;
  }
  return parts.map((part, index) => restoreFormats(part, prepared[index].tokens));
}

function entryLine(key, value) {
  return `L["${escapeLuaString(key)}"] = "${escapeLuaString(value)}"`;
}

const enText = await readFile(path.join(root, "Locales", "enUS.lua"), "utf8");
const contentStart = enText.indexOf("-- BEGIN CONTENT STRINGS");
if (contentStart < 0) {
  throw new Error("Locales/enUS.lua is missing -- BEGIN CONTENT STRINGS");
}
const contentEntries = extractLocaleEntries(enText.slice(contentStart));
const contentKeys = [...contentEntries.keys()];
const cache = await loadCache();

for (const [locale, targetLanguage] of Object.entries(localeTargets)) {
  const localePath = path.join(root, "Locales", `${locale}.lua`);
  const localeText = await readFile(localePath, "utf8");
  const localeEntries = extractLocaleEntries(localeText);
  const missingKeys = contentKeys.filter((key) => !localeEntries.has(key));
  console.log(`${locale}: ${missingKeys.length} missing content keys`);
  if (missingKeys.length === 0) continue;

  const generated = [];
  const chunks = chunkKeys(missingKeys);
  let translatedCount = 0;
  for (const chunk of chunks) {
    const uncached = chunk.filter((key) => cache[`${locale}\u0000${key}`] === undefined);
    if (uncached.length > 0) {
      const translations = await translateChunk(uncached, targetLanguage, cache);
      translations.forEach((translation, index) => {
        cache[`${locale}\u0000${uncached[index]}`] = translation;
      });
      await saveCache(cache);
    }
    for (const key of chunk) {
      generated.push(entryLine(key, cache[`${locale}\u0000${key}`]));
    }
    translatedCount += chunk.length;
    if (translatedCount % 250 < chunk.length) {
      console.log(`${locale}: ${translatedCount}/${missingKeys.length}`);
    }
  }

  const block = [
    "",
    "-- Generated full content localization for remaining English fallbacks.",
    ...generated,
    "",
  ].join("\n");
  await writeFile(localePath, localeText.replace(/\s*$/, "") + block, "utf8");
  console.log(`${locale}: appended ${generated.length} entries`);
}
