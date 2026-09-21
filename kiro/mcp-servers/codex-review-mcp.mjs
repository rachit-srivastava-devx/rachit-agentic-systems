#!/usr/bin/env node
// codex-review-mcp — a minimal, dependency-free MCP stdio server that exposes
// `codex exec` (read-only) as a first-class review tool.
//
// Why this exists: the modernise pipeline (AGENTS.md R6) makes codex cross-review
// MANDATORY. As a bare CLI, the model can forget to run it. As an MCP tool, the
// review step is a callable capability the pipeline can require and auto-approve.
//
// Protocol: MCP over JSON-RPC 2.0 on stdio. Implements initialize, tools/list,
// tools/call. No external packages — Node stdlib only.

import { spawn } from "node:child_process";
import { randomUUID } from "node:crypto";

const CODEX_BIN = process.env.CODEX_BIN || "codex";
const DEFAULT_TIMEOUT_MS = Number(process.env.CODEX_REVIEW_TIMEOUT_MS || 600000);

// ---- JSON-RPC stdio plumbing -------------------------------------------------

let buffer = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => {
  buffer += chunk;
  let idx;
  // Line-delimited JSON (one JSON object per line) — the transport Kiro uses.
  while ((idx = buffer.indexOf("\n")) >= 0) {
    const line = buffer.slice(0, idx).trim();
    buffer = buffer.slice(idx + 1);
    if (line) handleLine(line);
  }
});

function send(obj) {
  process.stdout.write(JSON.stringify(obj) + "\n");
}

function result(id, res) {
  send({ jsonrpc: "2.0", id, result: res });
}

function error(id, code, message, data) {
  send({ jsonrpc: "2.0", id, error: { code, message, data } });
}

async function handleLine(line) {
  let msg;
  try {
    msg = JSON.parse(line);
  } catch {
    return; // ignore unparseable lines
  }
  const { id, method, params } = msg;
  try {
    if (method === "initialize") {
      result(id, {
        protocolVersion: "2024-11-05",
        capabilities: { tools: {} },
        serverInfo: { name: "codex-review-mcp", version: "1.0.0" },
      });
    } else if (method === "notifications/initialized") {
      // notification, no response
    } else if (method === "tools/list") {
      result(id, { tools: TOOLS });
    } else if (method === "tools/call") {
      const out = await callTool(params?.name, params?.arguments || {});
      result(id, out);
    } else if (id !== undefined) {
      error(id, -32601, `method not found: ${method}`);
    }
  } catch (e) {
    if (id !== undefined) error(id, -32603, String(e?.message || e));
  }
}

// ---- Tool definitions --------------------------------------------------------

const TOOLS = [
  {
    name: "codex_review",
    description:
      "Run a read-only codex review over a directory. codex opens the real source, re-derives every file:line citation, and reports CONFIRMED/DRIFTED/REFUTED plus a no-stub PASS/FAIL. Use this as the mandatory cross-review step for a modernise category (AGENTS.md R6). codex NEVER edits anything (sandbox read-only).",
    inputSchema: {
      type: "object",
      properties: {
        directory: {
          type: "string",
          description: "Absolute path codex runs in (-C). Usually the category folder.",
        },
        prompt: {
          type: "string",
          description: "The review instruction. If omitted, a default modernise-category review prompt is used.",
        },
        source_root: {
          type: "string",
          description: "Absolute path to the real source tree to verify citations against (e.g. the btngo checkout). Injected into the default prompt.",
        },
        model: {
          type: "string",
          description: "Optional codex model override (-m).",
        },
        timeout_ms: {
          type: "number",
          description: `Kill codex after this many ms (default ${DEFAULT_TIMEOUT_MS}).`,
        },
      },
      required: ["directory"],
    },
  },
];

function defaultPrompt(sourceRoot) {
  const root = sourceRoot || "the real source tree for this app";
  return [
    `Review CONTRACT.md, BLUEPRINT.md, and TDD-SPEC.md in this directory against the real source at ${root} (read-only — do not edit anything).`,
    `For every file:line citation, open the real file and confirm or refute it explicitly.`,
    `For TDD-SPEC.md's test code, confirm it would compile and actually exercise the named code path (not a stub).`,
    `Report, per citation: CONFIRMED / DRIFTED / REFUTED, and an overall PASS/FAIL on the no-stub check.`,
  ].join(" ");
}

// ---- codex invocation --------------------------------------------------------

function callTool(name, args) {
  if (name !== "codex_review") {
    return Promise.resolve({
      isError: true,
      content: [{ type: "text", text: `unknown tool: ${name}` }],
    });
  }
  const dir = args.directory;
  if (!dir) {
    return Promise.resolve({
      isError: true,
      content: [{ type: "text", text: "directory is required" }],
    });
  }
  const prompt = args.prompt || defaultPrompt(args.source_root);
  const timeout = Number(args.timeout_ms || DEFAULT_TIMEOUT_MS);

  // codex exec -C <dir> [-m <model>] -s read-only --skip-git-repo-check "<prompt>"
  const cliArgs = ["exec", "-C", dir, "-s", "read-only", "--skip-git-repo-check"];
  if (args.model) cliArgs.push("-m", args.model);
  cliArgs.push(prompt);

  return new Promise((resolve) => {
    let stdout = "";
    let stderr = "";
    let done = false;
    const child = spawn(CODEX_BIN, cliArgs, { cwd: dir });
    const timer = setTimeout(() => {
      if (!done) {
        child.kill("SIGKILL");
        done = true;
        resolve({
          isError: true,
          content: [{ type: "text", text: `codex review timed out after ${timeout}ms\n\n--- stdout ---\n${stdout}\n--- stderr ---\n${stderr}` }],
        });
      }
    }, timeout);
    child.stdout.on("data", (d) => (stdout += d));
    child.stderr.on("data", (d) => (stderr += d));
    child.on("error", (e) => {
      if (done) return;
      done = true;
      clearTimeout(timer);
      resolve({
        isError: true,
        content: [{ type: "text", text: `failed to launch codex (${CODEX_BIN}): ${e.message}` }],
      });
    });
    child.on("close", (code) => {
      if (done) return;
      done = true;
      clearTimeout(timer);
      const text = `codex exit code: ${code}\nrun id: ${randomUUID()}\n\n--- codex output ---\n${stdout}${stderr ? `\n--- stderr ---\n${stderr}` : ""}`;
      resolve({
        isError: code !== 0,
        content: [{ type: "text", text }],
      });
    });
  });
}
