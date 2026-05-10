#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";

const args = process.argv.slice(2);
const version = args.find((arg) => !arg.startsWith("--"));
const skipChecks = args.includes("--no-check") || args.includes("--skip-checks");
const root = process.cwd();
const tocFiles = ["StoryMode.toc", "StoryMode_Vanilla.toc", "StoryMode_TBC.toc"];

if (!version || !/^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$/.test(version)) {
  console.error("Usage: node _Dev/tools/prepare-release.mjs <version> [--no-check]");
  process.exit(1);
}

function read(rel) {
  return fs.readFileSync(path.join(root, rel), "utf8");
}

function writeIfChanged(rel, next) {
  const full = path.join(root, rel);
  const current = fs.readFileSync(full, "utf8");
  if (current === next) return false;
  fs.writeFileSync(full, next);
  return true;
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function bumpTocVersions() {
  const changed = [];
  for (const toc of tocFiles) {
    const text = read(toc);
    const next = text.replace(/^## Version:\s*.+$/m, `## Version: ${version}`);
    if (writeIfChanged(toc, next)) changed.push(toc);
  }
  return changed;
}

function insertMaintenanceBullet(section, bullet) {
  if (section.includes(bullet)) return section;
  if (/### Maintenance\s*\n/.test(section)) {
    return section.replace(/### Maintenance\s*\n/, (match) => `${match}${bullet}\n`);
  }
  return `${section.trimEnd()}\n\n### Maintenance\n${bullet}\n`;
}

function ensureChangelogEntry() {
  const rel = "CHANGELOG.md";
  const text = read(rel);
  const header = `## ${version}`;
  const bullet = `- Bumped addon metadata to \`${version}\``;
  const bulletPattern = new RegExp(`Bumped addon (?:metadata|version).*${escapeRegex(version)}`);

  let next = text;
  const headerIndex = text.indexOf(`${header}\n`);
  if (headerIndex < 0) {
    next = text.replace(/^# Changelog\s*\n/, `# Changelog\n\n${header}\n\n### Maintenance\n${bullet}\n\n`);
    return writeIfChanged(rel, next);
  }

  const nextHeaderIndex = text.indexOf("\n## ", headerIndex + header.length);
  const sectionEnd = nextHeaderIndex >= 0 ? nextHeaderIndex : text.length;
  const before = text.slice(0, headerIndex);
  const section = text.slice(headerIndex, sectionEnd);
  const after = text.slice(sectionEnd);
  if (bulletPattern.test(section)) return false;

  next = `${before}${insertMaintenanceBullet(section, bullet)}${after}`;
  return writeIfChanged(rel, next);
}

function walkLuaFiles(relDir) {
  const dir = path.join(root, relDir);
  if (!fs.existsSync(dir)) return [];
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    const rel = path.relative(root, full);
    if (entry.isDirectory()) {
      out.push(...walkLuaFiles(rel));
    } else if (entry.name.endsWith(".lua")) {
      out.push(rel);
    }
  }
  return out;
}

function run(command, commandArgs) {
  console.log(`> ${command} ${commandArgs.join(" ")}`);
  const result = spawnSync(command, commandArgs, {
    cwd: root,
    stdio: "inherit",
  });
  if (result.error) {
    return `${command}: ${result.error.message}`;
  }
  if (result.status !== 0) {
    return `${command} exited with ${result.status}`;
  }
  return null;
}

function runChecks() {
  const luaFiles = [
    ...walkLuaFiles("Code"),
    ...walkLuaFiles("Data"),
    ...walkLuaFiles("Locales"),
  ].sort();

  const failures = [
    run("luac", ["-p", ...luaFiles]),
    run(process.execPath, ["_Dev/tools/check-core-behavior.mjs", root]),
    run(process.execPath, ["_Dev/tools/localization-audit.mjs", root]),
    run(process.execPath, ["_Dev/tools/recap-coverage.mjs", root, "--strict"]),
    run(process.execPath, ["_Dev/tools/validate-story-data.mjs", root]),
    run("git", ["diff", "--check"]),
  ].filter(Boolean);

  if (failures.length > 0) {
    console.error(JSON.stringify({ version, failures }, null, 2));
    process.exit(1);
  }
}

const changedTocs = bumpTocVersions();
const changedChangelog = ensureChangelogEntry();
if (!skipChecks) runChecks();

console.log(JSON.stringify({
  version,
  changedTocs,
  changedChangelog,
  checks: skipChecks ? "skipped" : "passed",
}, null, 2));
