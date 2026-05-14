#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const [version, outFile = ".release/changelog.md"] = process.argv.slice(2);
const root = process.cwd();

if (!version) {
  console.error("Usage: node _Dev/tools/extract-release-changelog.mjs <version> [outFile]");
  process.exit(1);
}

const changelogPath = path.join(root, "CHANGELOG.md");
const changelog = fs.readFileSync(changelogPath, "utf8");
const header = `## ${version}`;
const headerIndex = changelog.indexOf(`${header}\n`);

if (headerIndex < 0) {
  console.error(`Could not find changelog section for ${version}.`);
  process.exit(1);
}

const nextHeaderIndex = changelog.indexOf("\n## ", headerIndex + header.length);
const sectionEnd = nextHeaderIndex >= 0 ? nextHeaderIndex : changelog.length;
const section = changelog.slice(headerIndex, sectionEnd).trimEnd() + "\n";
const outPath = path.join(root, outFile);

fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, section);

console.log(JSON.stringify({
  version,
  outFile,
  lines: section.split("\n").length,
}, null, 2));
