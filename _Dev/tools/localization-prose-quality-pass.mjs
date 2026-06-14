import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

const root = process.argv[2] || process.cwd();
const reportOnly = process.argv.includes("--report-only");
const localeFiles = ["deDE", "esES", "frFR", "ptBR", "ruRU"];
const reportPath = path.join(root, ".localization-cache", "prose-quality-candidates.json");
const luaByteDecoder = new TextDecoder("utf-8");

const englishStopWords = new Set(
  "a an and are as at be been but by can could did do does for from had has have he her his if in into is it its not of on or she so that the their them then there they this through to was were what when where while who will with you your"
    .split(" ")
);

const localeStopPatterns = {
  deDE: /\b(?:der|die|das|und|ist|war|du|sie|mit|von|zu|den|dem|eine|ein|nicht|hat|haben|wurde|werden|durch|für)\b/i,
  esES: /\b(?:el|la|los|las|y|de|que|en|con|para|por|una|un|no|se|su|sus|del|al|como)\b/i,
  frFR: /\b(?:le|la|les|et|de|des|que|dans|avec|pour|par|une|un|pas|vous|ses|sur|du|au)\b/i,
  ptBR: /\b(?:o|a|os|as|e|de|que|em|com|para|por|uma|um|não|se|seu|sua|dos|das)\b/i,
  ruRU: /[А-Яа-я]/,
};

const allowedSourceTitlePhrases = new Set([
  "World of Warcraft",
  "The Barrens",
  "The Bloodmyst Isle",
  "The Exodar",
  "The Hinterlands",
  "The Stockade",
  "The Deadmines",
  "The Dreamgrove",
  "The Dreamway",
  "The Violet Hold",
  "The Fel Hammer",
  "The Wandering Isle",
  "The Broken Shore",
  "The Ebon Blade",
  "The Silver Hand",
  "The Underbelly",
  "The Maelstrom",
  "The Scarlet Monastery",
  "The Plaguelands",
  "The Blasted Lands",
  "The Burning Steppes",
  "The Black Temple",
  "The Black Morass",
  "The Dark Portal",
  "The Sunwell",
  "The Maw",
  "The Jailer",
  "The Primus",
  "The Winter Queen",
  "The Arbiter",
  "The Accuser",
  "The Fearstalker",
  "The Light",
  "The Void",
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

function extractLocaleEntryRecords(text) {
  const records = [];
  const re = /L\["((?:[^"\\]|\\.)*)"\]\s*=\s*"((?:[^"\\]|\\.)*)"/g;
  let match;
  while ((match = re.exec(text))) {
    records.push({
      line: text.slice(0, match.index).split("\n").length,
      key: unescapeLuaString(match[1]),
      value: unescapeLuaString(match[2]),
    });
  }
  return records;
}

function splitChunks(value) {
  return value
    .split(/(?<=[.!?])\s+|\n+/)
    .map((chunk) => chunk.trim())
    .filter(Boolean);
}

function englishWords(value) {
  return value.match(/[A-Za-z][A-Za-z']*/g) || [];
}

function englishWordCount(value) {
  return englishWords(value).length;
}

function normalizeEnglish(value) {
  return value
    .toLowerCase()
    .replace(/[“”"'’]/g, "")
    .replace(/[^a-z0-9]+/g, " ")
    .trim()
    .replace(/\s+/g, " ");
}

function englishStopScore(value) {
  const words = englishWords(value).map((word) => word.toLowerCase());
  const stopWords = words.filter((word) => englishStopWords.has(word)).length;
  return {
    words: words.length,
    stopWords,
    ratio: words.length > 0 ? stopWords / words.length : 0,
  };
}

function sourceChunks(key) {
  if (!/[.!?]|\n/.test(key)) return [];
  return splitChunks(key)
    .filter((chunk) => englishWordCount(chunk) >= 4)
    .map((chunk) => ({ raw: chunk, normalized: normalizeEnglish(chunk) }))
    .filter((chunk) => chunk.normalized);
}

function exactSourceResidue(key, valueChunk) {
  const normalizedValue = normalizeEnglish(valueChunk);
  if (!normalizedValue) return null;
  return sourceChunks(key).find((sourceChunk) => {
    return (
      normalizedValue === sourceChunk.normalized ||
      normalizedValue.includes(sourceChunk.normalized)
    );
  });
}

function englishSentenceResidue(locale, valueChunk) {
  const score = englishStopScore(valueChunk);
  if (score.words < 4 || score.stopWords < 3 || score.ratio < 0.35) return false;
  return !localeStopPatterns[locale].test(valueChunk);
}

function sourceTitlePhrases(key) {
  const phrases = new Set();
  const titlePhrase = /\b(?:The|A|An)\s+[A-Z][A-Za-z'’.-]+(?:\s+(?:of|and|the|[A-Z][A-Za-z'’.-]+)){0,4}/g;
  for (const match of key.matchAll(titlePhrase)) {
    const phrase = match[0].trim().replace(/[,.!?;:]+$/, "");
    if (allowedSourceTitlePhrases.has(phrase)) continue;
    if (englishWordCount(phrase) < 3) continue;
    phrases.add(phrase);
  }
  return [...phrases];
}

const findings = [];
const report = {};

for (const locale of localeFiles) {
  const localePath = path.join(root, "Locales", `${locale}.lua`);
  const localeText = await readFile(localePath, "utf8");
  const localeFindings = [];
  for (const record of extractLocaleEntryRecords(localeText)) {
    if (record.key.length < 50) continue;
    for (const phrase of sourceTitlePhrases(record.key)) {
      if (record.value.includes(phrase)) {
        localeFindings.push({
          line: record.line,
          type: "source title phrase residue",
          phrase,
          key: record.key,
        });
      }
    }
    for (const chunk of splitChunks(record.value)) {
      const exact = exactSourceResidue(record.key, chunk);
      if (exact) {
        localeFindings.push({
          line: record.line,
          type: "source sentence residue",
          chunk,
          sourceChunk: exact.raw,
          key: record.key,
        });
        continue;
      }
      if (englishSentenceResidue(locale, chunk)) {
        localeFindings.push({
          line: record.line,
          type: "english sentence residue",
          chunk,
          key: record.key,
        });
      }
    }
  }
  report[locale] = localeFindings;
  findings.push(...localeFindings.map((finding) => ({ locale, ...finding })));
}

await mkdir(path.dirname(reportPath), { recursive: true });
await writeFile(reportPath, JSON.stringify(report, null, 2) + "\n", "utf8");

if (findings.length > 0) {
  console.error(JSON.stringify({ findings, report: path.relative(root, reportPath) }, null, 2));
  if (!reportOnly) process.exit(1);
}

console.log(JSON.stringify({
  findings: findings.length,
  byLocale: Object.fromEntries(localeFiles.map((locale) => [locale, report[locale].length])),
  report: path.relative(root, reportPath),
}, null, 2));
