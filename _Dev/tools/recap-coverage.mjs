#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const args = process.argv.slice(2);
const root = args.find((arg) => !arg.startsWith("--")) || ".";
const strict = args.includes("--strict");
const dirs = ["Data/Storylines", "Data/Heritage", "Data/ClassQuests", "Data/Campaigns"];
const locales = ["deDE", "esES", "frFR", "ptBR", "ruRU"];

function read(file) {
  return fs.readFileSync(path.join(root, file), "utf8");
}

function luaEntries(text) {
  const keys = new Set();
  const re = /L\["((?:\\.|[^"\\])*)"\]\s*=/g;
  for (const match of text.matchAll(re)) {
    keys.add(match[1]);
  }
  return keys;
}

function recaps(file) {
  const text = read(file);
  const out = [];
  const re = /recap = "((?:\\.|[^"\\])*)"/g;
  for (const match of text.matchAll(re)) {
    out.push(match[1]);
  }
  return out;
}

const localeKeys = Object.fromEntries(
  locales.map((locale) => [locale, luaEntries(read(`Locales/${locale}.lua`))]),
);

let total = 0;
let missingByLocale = Object.fromEntries(locales.map((locale) => [locale, 0]));
let totalMissing = 0;
const missingFiles = [];

for (const dir of dirs) {
  const files = fs
    .readdirSync(path.join(root, dir))
    .filter((file) => file.endsWith(".lua"))
    .sort();

  for (const file of files) {
    const rel = `${dir}/${file}`;
    const values = recaps(rel);
    if (!values.length) continue;

    total += values.length;
    const missing = {};

    for (const locale of locales) {
      missing[locale] = values.filter((value) => !localeKeys[locale].has(value)).length;
      missingByLocale[locale] += missing[locale];
    }

    if (Object.values(missing).some(Boolean)) {
      missingFiles.push({ file: rel, recaps: values.length, missing });
      console.log(`${rel}: ${values.length} recaps missing ${JSON.stringify(missing)}`);
    }
  }
}

totalMissing = Object.values(missingByLocale).reduce((sum, count) => sum + count, 0);

console.log(JSON.stringify({
  totalRecaps: total,
  missingByLocale,
  missingFiles,
  strict,
}, null, 2));

if (strict && totalMissing > 0) {
  process.exit(1);
}
