#!/usr/bin/env bun

import { spawnSync } from "child_process";
import { mkdirSync, writeFileSync, existsSync, readFileSync } from "fs";
import { join, basename } from "path";

const [filter, baseDir] = process.argv.slice(2);

if (!filter || !baseDir) {
  console.error("Usage: scripts/gmail-pull.ts <filter> <base_dir>");
  process.exit(1);
}

// Ensure directories exist
mkdirSync(join(baseDir, "messages"), { recursive: true });
mkdirSync(join(baseDir, "threads"), { recursive: true });
mkdirSync(join(baseDir, "attachments"), { recursive: true });

async function runGws(args: string[], retries = 3): Promise<string> {
  let lastError: any;
  for (let i = 0; i < retries; i++) {
    const proc = Bun.spawn(["gws", ...args], {
      stdout: "pipe",
      stderr: "pipe",
    });

    const stdout = await new Response(proc.stdout).text();
    const stderr = await new Response(proc.stderr).text();
    const exitCode = await proc.exited;

    if (exitCode === 0) {
      return stdout;
    }

    lastError = { exitCode, stderr };
    if (i < retries - 1) {
      const delay = Math.pow(2, i) * 1000;
      console.warn(
        `gws failed (attempt ${i + 1}/${retries}), retrying in ${delay}ms...`,
      );
      await Bun.sleep(delay);
    }
  }

  console.error(
    `gws failed after ${retries} attempts. Status: ${lastError.exitCode}, Stderr: ${lastError.stderr}`,
  );
  throw new Error(`gws failed with status ${lastError.exitCode}`);
}

async function runYq(input: string, args: string[]): Promise<string> {
  const proc = Bun.spawn(["yq", ...args], {
    stdin: Buffer.from(input),
    stdout: "pipe",
    stderr: "pipe",
  });

  const stdout = await new Response(proc.stdout).text();
  const stderr = await new Response(proc.stderr).text();
  const exitCode = await proc.exited;

  if (exitCode !== 0) {
    console.error(`yq failed: ${stderr}`);
    throw new Error(`yq failed with status ${exitCode}`);
  }
  return stdout.trim();
}

function extractBodies(payload: any) {
  const bodies = { text: "", html: "" };
  function walk(part: any) {
    if (part.mimeType === "text/plain" && part.body?.data) {
      bodies.text = Buffer.from(part.body.data, "base64url").toString("utf-8");
    } else if (part.mimeType === "text/html" && part.body?.data) {
      bodies.html = Buffer.from(part.body.data, "base64url").toString("utf-8");
    }
    if (part.parts) part.parts.forEach(walk);
  }
  if (payload) walk(payload);
  return bodies;
}

function findAttachments(payload: any) {
  const attachments: any[] = [];
  function walk(part: any) {
    if (part.body?.attachmentId) {
      attachments.push({
        attachmentId: part.body.attachmentId,
        filename: part.filename,
        partId: part.partId,
      });
    }
    if (part.parts) part.parts.forEach(walk);
  }
  if (payload) walk(payload);
  return attachments;
}

function sanitizeFilename(name: string) {
  return name.replace(/[/\\?%*:|"<>]/g, "_");
}

function htmlToMd(html: string) {
  let cleaned = html.replace(/<style[^>]*>[\s\S]*?<\/style>/gi, "");
  cleaned = cleaned.replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "");

  return cleaned
    .replace(/<h[1-6]>(.*?)<\/h[1-6]>/gi, (match, p1) => `\n# ${p1}\n`)
    .replace(/<b>(.*?)<\/b>/gi, "**$1**")
    .replace(/<strong>(.*?)<\/strong>/gi, "**$1**")
    .replace(/<i>(.*?)<\/i>/gi, "_$1_")
    .replace(/em>(.*?)<\/em>/gi, "_$1_")
    .replace(/<a.*?href="(.*?)".*?>(.*?)<\/a>/gi, "[$2]($1)")
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<p>(.*?)<\/p>/gi, "\n$1\n")
    .replace(/&nbsp;/g, " ")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&amp;/g, "&")
    .replace(/<[^>]+>/g, "")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

function getHeader(headers: any[], name: string): string {
  return (
    headers.find((h: any) => h.name.toLowerCase() === name.toLowerCase())
      ?.value || ""
  );
}

async function processMessage(message: any) {
  const id = message.id;
  const yamlPath = join(baseDir, "messages", `${id}.yaml`);

  // Even if skipping full processing, we return the data for thread concatenation
  const bodies = extractBodies(message.payload);
  const subject = getHeader(message.payload.headers, "subject");
  const from = getHeader(message.payload.headers, "from");
  const date = getHeader(message.payload.headers, "date");

  if (!existsSync(yamlPath)) {
    console.log(`  Processing message ${id}...`);
    const yamlContent = await runYq(JSON.stringify(message), [
      "eval",
      "-P",
      "-o",
      "yaml",
    ]);
    writeFileSync(yamlPath, yamlContent);

    if (bodies.text) {
      writeFileSync(join(baseDir, "messages", `${id}.txt`), bodies.text);
    }
    if (bodies.html) {
      writeFileSync(join(baseDir, "messages", `${id}.html`), bodies.html);
      writeFileSync(
        join(baseDir, "messages", `${id}.md`),
        htmlToMd(bodies.html),
      );
    }

    const attachments = findAttachments(message.payload);
    if (attachments.length > 0) {
      const attachDir = join(baseDir, "attachments", id);
      mkdirSync(attachDir, { recursive: true });
      for (const att of attachments) {
        console.log(
          `    Downloading attachment ${att.filename} (${att.partId})...`,
        );
        const attOutput = await runGws([
          "gmail",
          "users",
          "messages",
          "attachments",
          "get",
          "--params",
          JSON.stringify({ userId: "me", messageId: id, id: att.attachmentId }),
          "--format",
          "json",
        ]);
        const attData = JSON.parse(attOutput);
        const buffer = Buffer.from(attData.data, "base64url");
        const safeFilename = sanitizeFilename(att.filename);
        writeFileSync(join(attachDir, `${att.partId}-${safeFilename}`), buffer);
      }
    }
  }

  return { id, subject, from, date, bodies };
}

async function processThread(threadId: string) {
  const threadYamlPath = join(baseDir, "threads", `${threadId}.yaml`);
  const threadMdPath = join(baseDir, "threads", `${threadId}.md`);

  // We always fetch to ensure we have the latest messages in the thread
  // but we can skip if nothing changed (optional optimization, for now keep it simple)
  console.log(`Downloading thread ${threadId}...`);
  const threadOutput = await runGws([
    "gmail",
    "users",
    "threads",
    "get",
    "--params",
    JSON.stringify({ userId: "me", id: threadId }),
    "--format",
    "json",
  ]);

  const thread = JSON.parse(threadOutput);

  // Save Thread YAML
  const yamlContent = await runYq(threadOutput, ["eval", "-P", "-o", "yaml"]);
  writeFileSync(threadYamlPath, yamlContent);

  // Process all messages in thread
  const processedMessages = [];
  for (const msg of thread.messages) {
    processedMessages.push(await processMessage(msg));
  }

  // Generate Thread Markdown for LLM
  let threadMd = `# Thread: ${processedMessages[0]?.subject || threadId}\n\n`;
  for (const msg of processedMessages) {
    threadMd += `## Message ${msg.id}\n`;
    threadMd += `**From**: ${msg.from}\n`;
    threadMd += `**Date**: ${msg.date}\n\n`;
    threadMd += (
      msg.bodies.text ||
      htmlToMd(msg.bodies.html) ||
      "(No content)"
    ).trim();
    threadMd += "\n\n---\n\n";
  }
  writeFileSync(threadMdPath, threadMd.trim());
}

async function main() {
  // 1. List threads
  console.log(`Searching for threads with filter: ${filter}`);
  const listOutput = await runGws([
    "gmail",
    "users",
    "threads",
    "list",
    "--params",
    JSON.stringify({ userId: "me", q: filter }),
    "--format",
    "json",
  ]);

  const listData = JSON.parse(listOutput);
  const threadIds = (listData.threads || []).map((t: any) => t.id).sort();

  console.log(`Found ${threadIds.length} threads.`);

  // 2. Update index.yaml
  const indexPath = join(baseDir, "index.yaml");
  let indexContent = "{}";
  if (existsSync(indexPath)) {
    const content = readFileSync(indexPath, "utf-8").trim();
    if (content) indexContent = content;
  }

  const updatedIndex = await runYq(indexContent, [
    "eval",
    `.["${filter}"] = ${JSON.stringify(threadIds)}`,
    "-P",
    "-o",
    "yaml",
  ]);
  writeFileSync(indexPath, updatedIndex);
  console.log(`Updated ${indexPath}`);

  // 3. Parallel download
  const concurrency = 5; // Threads are heavier, reduce concurrency
  const queue = [...threadIds];
  const active: Promise<void>[] = [];

  while (queue.length > 0 || active.length > 0) {
    while (queue.length > 0 && active.length < concurrency) {
      const id = queue.shift()!;
      const promise = processThread(id).then(() => {
        active.splice(active.indexOf(promise), 1);
      });
      active.push(promise);
    }
    if (active.length > 0) {
      await Promise.race(active);
    }
  }

  console.log("Done!");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
