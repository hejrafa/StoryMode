import { readFile } from "node:fs/promises";
import path from "node:path";

const positionalArgs = process.argv.slice(2).filter((arg) => !arg.startsWith("--"));
const root = positionalArgs[0] || process.cwd();
const reportPath = positionalArgs[1] || "";
const exceptionsPath = path.join(root, "_Dev", "quest-audit-exceptions.json");

const config = JSON.parse(await readFile(exceptionsPath, "utf8"));
const exceptions = Array.isArray(config.exceptions) ? config.exceptions : [];
const findings = [];

const keys = new Map();
exceptions.forEach((exception, index) => {
  if (!exception.type) findings.push({ type: "exception-missing-type", severity: "error", index });
  if (!exception.file) findings.push({ type: "exception-missing-file", severity: "error", index });
  if (!exception.reason) findings.push({ type: "exception-missing-reason", severity: "error", index });
  const key = JSON.stringify({
    type: exception.type,
    file: exception.file,
    quest: exception.quest || "",
    source: exception.source || "",
    npc: exception.npc || "",
    chapter: exception.chapter || "",
    name: exception.name || "",
    remoteContains: exception.remoteContains || "",
  });
  if (keys.has(key)) {
    findings.push({ type: "duplicate-exception", severity: "error", index, duplicateOf: keys.get(key) });
  } else {
    keys.set(key, index);
  }
});

let report = null;
if (reportPath) {
  report = JSON.parse(await readFile(path.resolve(root, reportPath), "utf8"));
  for (const exception of report.unmatchedExceptions || []) {
    findings.push({
      type: "unmatched-exception",
      severity: "warn",
      index: exception.index,
      file: exception.file,
      quest: exception.quest,
      npc: exception.npc,
      reason: exception.reason,
    });
  }
}

const suppressedByType = report?.suppressedFindingsByType || (report?.suppressedFindings || []).reduce((counts, finding) => {
  counts[finding.type] = (counts[finding.type] || 0) + 1;
  return counts;
}, {});
const findingsBySeverity = findings.reduce((counts, finding) => {
  counts[finding.severity] = (counts[finding.severity] || 0) + 1;
  return counts;
}, {});

console.log(JSON.stringify({
  exceptions: exceptions.length,
  suppressedByType,
  unmatchedExceptions: report?.unmatchedExceptions?.length,
  findingsBySeverity,
  findings,
}, null, 2));

process.exit((findingsBySeverity.error || 0) ? 1 : 0);
