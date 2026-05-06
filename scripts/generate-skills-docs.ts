#!/usr/bin/env bun

import {
  readdirSync,
  readFileSync,
  writeFileSync,
  mkdirSync,
  existsSync,
  copyFileSync,
} from "node:fs";
import { join } from "node:path";

const SKILLS_DIR = "skills";
const DOCS_SKILLS_DIR = "docs/skills";

interface SkillInfo {
  id: string;
  name: string;
  description: string;
}

function main() {
  if (!existsSync(DOCS_SKILLS_DIR)) {
    mkdirSync(DOCS_SKILLS_DIR, { recursive: true });
  }

  const skillDirs = readdirSync(SKILLS_DIR, { withFileTypes: true })
    .filter((dirent) => dirent.isDirectory())
    .map((dirent) => dirent.name);

  console.log(`Found ${skillDirs.length} skills in ${SKILLS_DIR}/`);

  const skillInfos: SkillInfo[] = [];

  for (const skillId of skillDirs) {
    const skillPath = join(SKILLS_DIR, skillId);
    const skillMdPath = join(skillPath, "SKILL.md");
    if (!existsSync(skillMdPath)) continue;

    const rawContent = readFileSync(skillMdPath, "utf-8");
    const lines = rawContent.split("\n");

    let description = "";
    let name = skillId;
    let contentStart = 0;

    if (lines[0] === "---") {
      const endIdx = lines.indexOf("---", 1);
      if (endIdx !== -1) {
        const frontMatter = lines.slice(1, endIdx);
        for (const line of frontMatter) {
          if (line.startsWith("description:")) {
            description = line.replace("description:", "").trim();
          }
          if (line.startsWith("name:")) {
            name = line.replace("name:", "").trim();
          }
        }
        contentStart = endIdx + 1;
      }
    }

    // Try to get a nicer name from the first H1 if available
    let displayName = name;
    const contentLines = lines.slice(contentStart);
    for (const line of contentLines) {
      const h1Match = line.match(/^#\s+(.*)/);
      if (h1Match) {
        displayName = h1Match[1].trim();
        break;
      }
    }

    skillInfos.push({ id: skillId, name: displayName, description });

    let content = lines.slice(contentStart).join("\n").trim();

    // Inject description after the first # H1 if it exists, or at the top
    if (description) {
      const h1Match = content.match(/^(#\s+.*)/m);
      if (h1Match) {
        const h1 = h1Match[1];
        content = content.replace(h1, `${h1}\n\n> ${description}`);
      } else {
        content = `> ${description}\n\n${content}`;
      }
    }

    // Append README.md if it exists, merging it into the skill documentation
    const readmePath = join(skillPath, "README.md");
    if (existsSync(readmePath)) {
      let readmeContent = readFileSync(readmePath, "utf-8").trim();
      // Remove first H1 if it exists (usually a duplicate of the skill title)
      readmeContent = readmeContent.replace(/^#\s+.*\n?/, "").trim();
      if (readmeContent) {
        content += "\n\n---\n\n" + readmeContent;
      }
    }

    const targetPath = join(DOCS_SKILLS_DIR, `${skillId}.md`);
    writeFileSync(targetPath, content + "\n");

    // Copy other files from the skill directory to docs/skills/
    const otherFiles = readdirSync(skillPath, { withFileTypes: true }).filter(
      (dirent) =>
        dirent.isFile() &&
        dirent.name !== "SKILL.md" &&
        dirent.name !== "README.md",
    );

    for (const file of otherFiles) {
      copyFileSync(
        join(skillPath, file.name),
        join(DOCS_SKILLS_DIR, file.name),
      );
    }

    console.log(`  Generated ${targetPath}`);
  }

  // Generate index.md
  skillInfos.sort((a, b) => a.name.localeCompare(b.name));
  let indexContent = "# Agent Skills\n\n";
  indexContent +=
    "These are the skills available to AI agents in this project.\n\n";
  for (const info of skillInfos) {
    indexContent += `- [${info.name}](${info.id}.md): ${info.description}\n`;
  }

  const indexPath = join(DOCS_SKILLS_DIR, "index.md");
  writeFileSync(indexPath, indexContent);
  console.log(`  Generated ${indexPath}`);

  // Update zensical.toml navigation
  updateZensicalToml(skillInfos);

  console.log("Done!");
}

function updateZensicalToml(skillInfos: SkillInfo[]) {
  const tomlPath = "zensical.toml";
  if (!existsSync(tomlPath)) return;

  let tomlContent = readFileSync(tomlPath, "utf-8");
  const lines = tomlContent.split("\n");

  const skillEntries = skillInfos
    .map((info) => `{ "${info.name}" = "skills/${info.id}.md" }`)
    .join(",\n    ");
  const newSkillsNav = `{ "Skills" = [\n    { "Overview" = "skills/index.md" },\n    ${skillEntries}\n  ]}`;

  let startIdx = -1;
  let endIdx = -1;

  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('"Skills" =')) {
      startIdx = i;
      // Check if it's a single-line or multi-line entry
      if (lines[i].trim().endsWith("},") || lines[i].trim().endsWith("}")) {
        endIdx = i;
      } else {
        // It's a multi-line block (already a list)
        for (let j = i + 1; j < lines.length; j++) {
          if (
            lines[j].trim().startsWith("]},") ||
            lines[j].trim().startsWith("]}")
          ) {
            endIdx = j;
            break;
          }
        }
      }
      break;
    }
  }

  if (startIdx !== -1 && endIdx !== -1) {
    const indent = lines[startIdx].match(/^\s*/)?.[0] || "  ";
    const suffix = lines[endIdx].trim().endsWith(",") ? "," : "";

    const formattedNewNav =
      newSkillsNav
        .split("\n")
        .map((line, idx) => {
          if (idx === 0) return indent + line;
          return indent + "  " + line.trim();
        })
        .join("\n") + suffix;

    lines.splice(startIdx, endIdx - startIdx + 1, formattedNewNav);
    writeFileSync(tomlPath, lines.join("\n"));
    console.log(`  Updated ${tomlPath} navigation`);
  } else {
    console.warn(
      `  Could not find "Skills" entry in ${tomlPath} navigation to update.`,
    );
  }
}

main();
