import { readFile } from "node:fs/promises";
import { spawnSync } from "node:child_process";

const root = process.argv[2] || process.cwd();
const tocFiles = ["StoryMode.toc", "StoryMode_Vanilla.toc", "StoryMode_TBC.toc"];
const requiredModules = [
  "Code\\Core\\Scheduler.lua",
  "Code\\Core\\StoryState.lua",
  "Code\\Core\\Events.lua",
  "Code\\UI\\Pools.lua",
  "Code\\UI\\LoadingScreenBrowser.lua",
  "Code\\UI\\StoryList.lua",
];
const maxStoryModeLocals = 160;

const findings = [];

function normalizeLine(line) {
  return line.trim().replace(/\//g, "\\");
}

for (const tocFile of tocFiles) {
  const content = await readFile(`${root}/${tocFile}`, "utf8");
  const lines = content.split(/\r?\n/).map(normalizeLine).filter(Boolean);
  for (const module of requiredModules) {
    if (!lines.includes(module)) {
      findings.push(`${tocFile} does not load ${module}`);
    }
  }

  const storyModeIndex = lines.indexOf("Code\\StoryMode.lua");
  for (const module of requiredModules) {
    const moduleIndex = lines.indexOf(module);
    if (moduleIndex >= 0 && storyModeIndex >= 0 && moduleIndex > storyModeIndex) {
      findings.push(`${tocFile} loads ${module} after Code\\StoryMode.lua`);
    }
  }
}

const luac = spawnSync("luac", ["-l", "-p", "Code/StoryMode.lua"], {
  cwd: root,
  encoding: "utf8",
});
if (luac.status !== 0) {
  findings.push(`luac failed for Code/StoryMode.lua: ${luac.stderr || luac.stdout}`);
} else {
  const header = luac.stdout.split(/\r?\n/).find((line) => line.includes(" locals,"));
  const match = header && header.match(/,\s+(\d+)\s+locals,/);
  const locals = match ? Number(match[1]) : null;
  if (locals == null) {
    findings.push("Could not read Code/StoryMode.lua local count from luac output");
  } else if (locals > maxStoryModeLocals) {
    findings.push(`Code/StoryMode.lua uses ${locals} locals; expected <= ${maxStoryModeLocals}`);
  }
}

if (findings.length > 0) {
  console.error(JSON.stringify({ findings }, null, 2));
  process.exit(1);
}

console.log(JSON.stringify({
  tocFiles: tocFiles.length,
  requiredModules: requiredModules.length,
  maxStoryModeLocals,
  findings: [],
}, null, 2));
