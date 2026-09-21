#!/usr/bin/env node
// go-test-mcp — a minimal, dependency-free MCP stdio server exposing Go's
// build/test as first-class verification tools.
//
// Why this exists: the modernise VERIFICATION protocol needs (a) compile-proof
// (`go test -c -o /dev/null`, VERIFICATION.md §5.3) and (b) real red/green
// execution (Check 3). Go 1.27 on this machine runs tests fine (the old dyld
// LC_UUID defect on Go 1.21 is gone), so both checks are available locally.
// Exposing them as tools lets a PostTaskExec gate REQUIRE them per category.
//
// Protocol: MCP over JSON-RPC 2.0 on stdio, Node stdlib only.

import { spawn } from "node:child_process";

const GO_BIN = process.env.GO_BIN || "go";
const DEFAULT_TIMEOUT_MS = Number(process.env.GO_TEST_TIMEOUT_MS || 600000);

let buffer = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => {
  buffer += chunk;
  let idx;
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
function rpcError(id, code, message) {
  send({ jsonrpc: "2.0", id, error: { code, message } });
}

async function handleLine(line) {
  let msg;
  try {
    msg = JSON.parse(line);
  } catch {
    return;
  }
  const { id, method, params } = msg;
  try {
    if (method === "initialize") {
      result(id, {
        protocolVersion: "2024-11-05",
        capabilities: { tools: {} },
        serverInfo: { name: "go-test-mcp", version: "1.0.0" },
      });
    } else if (method === "notifications/initialized") {
      // no-op
    } else if (method === "tools/list") {
      result(id, { tools: TOOLS });
    } else if (method === "tools/call") {
      const out = await callTool(params?.name, params?.arguments || {});
      result(id, out);
    } else if (id !== undefined) {
      rpcError(id, -32601, `method not found: ${method}`);
    }
  } catch (e) {
    if (id !== undefined) rpcError(id, -32603, String(e?.message || e));
  }
}

const TOOLS = [
  {
    name: "go_compile_proof",
    description:
      "Compile-and-link the real TEST binary without running it (`go test -c -o /dev/null <pkg>`). Proves the test file itself compiles against the real dependency graph, including every mock/fake/assertion helper — strictly stronger than `go build`. Use as the minimum ceiling for a modernise category's citation-integrity proof (VERIFICATION.md §5.3).",
    inputSchema: {
      type: "object",
      properties: {
        directory: { type: "string", description: "Absolute path of the Go module/checkout to run in." },
        packages: { type: "string", description: "Package pattern (default './...')." },
        timeout_ms: { type: "number", description: `Kill after this many ms (default ${DEFAULT_TIMEOUT_MS}).` },
      },
      required: ["directory"],
    },
  },
  {
    name: "go_test",
    description:
      "Run real `go test` (Check 3 red/green execution). Returns exit code, stdout, stderr. A non-zero exit is the RED; a zero exit after applying a fix is the GREEN. Run against an isolated worktree, never a shared checkout.",
    inputSchema: {
      type: "object",
      properties: {
        directory: { type: "string", description: "Absolute path of the Go module/checkout to run in." },
        packages: { type: "string", description: "Package pattern (default './...')." },
        run: { type: "string", description: "Optional -run regex to scope to specific test(s)." },
        verbose: { type: "boolean", description: "Pass -v (default true)." },
        timeout_ms: { type: "number", description: `Kill after this many ms (default ${DEFAULT_TIMEOUT_MS}).` },
      },
      required: ["directory"],
    },
  },
  {
    name: "go_vet",
    description: "Run `go vet` over the package pattern. A cheap correctness gate to pair with compile-proof.",
    inputSchema: {
      type: "object",
      properties: {
        directory: { type: "string", description: "Absolute path of the Go module/checkout to run in." },
        packages: { type: "string", description: "Package pattern (default './...')." },
        timeout_ms: { type: "number", description: `Kill after this many ms (default ${DEFAULT_TIMEOUT_MS}).` },
      },
      required: ["directory"],
    },
  },
];

function run(dir, goArgs, timeout) {
  return new Promise((resolve) => {
    let stdout = "";
    let stderr = "";
    let done = false;
    const child = spawn(GO_BIN, goArgs, { cwd: dir });
    const timer = setTimeout(() => {
      if (!done) {
        child.kill("SIGKILL");
        done = true;
        resolve({ code: 124, stdout, stderr: stderr + `\n[killed: timeout ${timeout}ms]` });
      }
    }, timeout);
    child.stdout.on("data", (d) => (stdout += d));
    child.stderr.on("data", (d) => (stderr += d));
    child.on("error", (e) => {
      if (done) return;
      done = true;
      clearTimeout(timer);
      resolve({ code: 127, stdout, stderr: `failed to launch ${GO_BIN}: ${e.message}` });
    });
    child.on("close", (code) => {
      if (done) return;
      done = true;
      clearTimeout(timer);
      resolve({ code, stdout, stderr });
    });
  });
}

async function callTool(name, args) {
  const dir = args.directory;
  if (!dir) {
    return { isError: true, content: [{ type: "text", text: "directory is required" }] };
  }
  const pkgs = args.packages || "./...";
  const timeout = Number(args.timeout_ms || DEFAULT_TIMEOUT_MS);

  let goArgs;
  if (name === "go_compile_proof") {
    goArgs = ["test", "-c", "-o", "/dev/null", pkgs];
  } else if (name === "go_test") {
    goArgs = ["test"];
    if (args.verbose !== false) goArgs.push("-v");
    if (args.run) goArgs.push("-run", args.run);
    goArgs.push(pkgs);
  } else if (name === "go_vet") {
    goArgs = ["vet", pkgs];
  } else {
    return { isError: true, content: [{ type: "text", text: `unknown tool: ${name}` }] };
  }

  const { code, stdout, stderr } = await run(dir, goArgs, timeout);
  const text = `$ go ${goArgs.join(" ")}   (cwd: ${dir})\nexit code: ${code}\n\n--- stdout ---\n${stdout || "(empty)"}\n--- stderr ---\n${stderr || "(empty)"}`;
  return { isError: code !== 0, content: [{ type: "text", text }] };
}
