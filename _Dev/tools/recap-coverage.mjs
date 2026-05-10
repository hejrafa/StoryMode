#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const root = process.argv[2] || ".";
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
      console.log(`${rel}: ${values.length} recaps missing ${JSON.stringify(missing)}`);
    }
  }
}

console.log(JSON.stringify({ totalRecaps: total, missingByLocale }, null, 2));
