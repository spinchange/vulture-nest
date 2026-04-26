const fsProm = await import("node:fs/promises");
const pathMod = await import("node:path");

globalThis.hex = async s => {
  const data = new TextEncoder().encode(String(s));
  const hash = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(hash))
    .map(b => b.toString(16).padStart(2, "0"))
    .join("");
};

globalThis.read = async path => {
  return fsProm.readFile(path, "utf8");
};

globalThis.append = async (path, text) => {
  await fsProm.appendFile(path, String(text), "utf8");
  return path;
};

globalThis.mkdir = async path => {
  await fsProm.mkdir(path, { recursive: true });
  return path;
};

globalThis.copy = async (from, to) => {
  await fsProm.copyFile(from, to);
  return to;
};

globalThis.write = async (path, text) => {
  await fsProm.writeFile(path, String(text), "utf8");
  return path;
};

globalThis.rm = async path => {
  await fsProm.rm(path, { recursive: true, force: true });
  return path;
};

globalThis.json = async path => {
  return JSON.parse(await fsProm.readFile(path, "utf8"));
};

globalThis.writeJson = async (path, value, space = 2) => {
  await fsProm.writeFile(path, `${JSON.stringify(value, null, space)}\n`, "utf8");
  return path;
};

globalThis.ls = async (path = codex.cwd) => {
  const entries = await fsProm.readdir(path, { withFileTypes: true });
  return entries
    .map(entry => ({
      name: entry.name,
      type: entry.isDirectory() ? "dir" : entry.isFile() ? "file" : "other",
    }))
    .sort((a, b) => a.name.localeCompare(b.name));
};

globalThis.exists = async path => {
  try {
    await fsProm.access(path);
    return true;
  } catch {
    return false;
  }
};

globalThis.head = async (path, lines = 20) => {
  const text = await fsProm.readFile(path, "utf8");
  return text.split(/\r?\n/).slice(0, lines).join("\n");
};

globalThis.tail = async (path, lines = 20) => {
  const text = await fsProm.readFile(path, "utf8");
  return text.split(/\r?\n/).slice(-lines).join("\n");
};

globalThis.test = async (name, fn) => {
  const startedAt = new Date().toISOString();
  try {
    const value = await fn();
    return {
      name,
      ok: true,
      value,
      startedAt,
      finishedAt: new Date().toISOString(),
    };
  } catch (error) {
    return {
      name,
      ok: false,
      error: error?.message ?? String(error),
      startedAt,
      finishedAt: new Date().toISOString(),
    };
  }
};

globalThis.assert = (condition, message = "assertion failed") => {
  if (!condition) throw new Error(message);
  return true;
};

globalThis.run = async (command, workdir = codex.cwd, timeout_ms = 20000) => {
  const res = await codex.tool("shell_command", { command, workdir, timeout_ms });
  return res?.output ?? res;
};

globalThis.findText = async (pattern, target = codex.cwd, timeout_ms = 20000) => {
  const escaped = String(pattern).replace(/'/g, "''");
  return run(
    `rg -n --hidden --glob '!**/node_modules/**' --glob '!**/.git/**' '${escaped}' "${target}"`,
    codex.cwd,
    timeout_ms
  );
};

globalThis.setRepo = async repoPath => {
  globalThis.repo = repoPath;
  return {
    repo: repoPath,
    packageJson: await exists(pathMod.join(repoPath, "package.json")),
    gitDir: await exists(pathMod.join(repoPath, ".git")),
  };
};

globalThis.git = async (args, repoPath = globalThis.repo ?? codex.cwd, timeout_ms = 30000) => {
  return run(`git ${args}`, repoPath, timeout_ms);
};

globalThis.gitStatus = async (repoPath = globalThis.repo ?? codex.cwd) => {
  return git("status --short", repoPath);
};

globalThis.npmScript = async (name, repoPath = globalThis.repo ?? codex.cwd, timeout_ms = 120000) => {
  return run(`npm run ${name}`, repoPath, timeout_ms);
};

globalThis.npmTest = async (repoPath = globalThis.repo ?? codex.cwd, timeout_ms = 120000) => {
  return run("npm test", repoPath, timeout_ms);
};

globalThis.preflight = async (repoPath = globalThis.repo ?? codex.cwd) => {
  const status = await gitStatus(repoPath);
  const packageJsonPath = pathMod.join(repoPath, "package.json");
  const hasPkg = await exists(packageJsonPath);
  const pkgInfo = hasPkg ? await json(packageJsonPath) : {};
  const scripts = Object.keys(pkgInfo.scripts || {});
  const hasTestScript = scripts.includes("test");
  const tests = hasTestScript ? await npmTest(repoPath) : "no test script";

  return {
    branchClean: status.trim() === "",
    scripts,
    hasPackageJson: hasPkg,
    hasTestScript,
    testsPassed: tests.includes("Exit code: 0"),
  };
};

globalThis.summarizeStatus = async (repoPath = globalThis.repo ?? codex.cwd) => {
  const status = await gitStatus(repoPath);
  const lines = status
    .split(/\r?\n/)
    .map(line => line.trim())
    .filter(Boolean);

  return {
    repo: repoPath,
    clean: lines.length === 0,
    changedCount: lines.length,
    changed: lines,
  };
};

globalThis.repoAudit = async (repoPath = globalThis.repo ?? codex.cwd) => {
  const packageJsonPath = pathMod.join(repoPath, "package.json");
  const readmePath = pathMod.join(repoPath, "README.md");
  const preflightResult = await preflight(repoPath);
  const statusResult = await summarizeStatus(repoPath);

  return {
    repo: repoPath,
    gitDir: await exists(pathMod.join(repoPath, ".git")),
    hasReadme: await exists(readmePath),
    hasPackageJson: await exists(packageJsonPath),
    preflight: preflightResult,
    status: statusResult,
  };
};

globalThis.testOrExplain = async (repoPath = globalThis.repo ?? codex.cwd) => {
  const packageJsonPath = pathMod.join(repoPath, "package.json");
  const hasPkg = await exists(packageJsonPath);
  if (!hasPkg) {
    return {
      repo: repoPath,
      ok: false,
      reason: "no package.json",
      nextStep: "Use run(...) directly or switch to a repo with a package.json.",
    };
  }

  const pkgInfo = await json(packageJsonPath);
  const scripts = Object.keys(pkgInfo.scripts || {});
  if (!scripts.includes("test")) {
    return {
      repo: repoPath,
      ok: false,
      reason: "no test script",
      scripts,
      nextStep: "Run a different script with npmScript(name) or use run(...) for a custom command.",
    };
  }

  const output = await npmTest(repoPath);
  return {
    repo: repoPath,
    ok: output.includes("Exit code: 0"),
    reason: output.includes("Exit code: 0") ? "tests passed" : "tests failed",
    output,
  };
};

globalThis.getTitle = async url => {
  const html = await fetch(url).then(r => r.text());
  return html.match(/<title>(.*?)<\/title>/i)?.[1] ?? "no title";
};

globalThis.proofSummaries = async (
  proofsDir = pathMod.join(codex.homeDir || codex.cwd, ".workbench", "proof-rounds")
) => {
  const entries = await ls(proofsDir);
  const proofFiles = entries
    .filter(entry => entry.type === "file" && entry.name.endsWith(".json"))
    .map(entry => pathMod.join(proofsDir, entry.name));

  const summaries = [];
  for (const proofFile of proofFiles) {
    const artifact = await json(proofFile);
    const audit = artifact.steps?.find?.(step => step.id === "repo_audit")?.data ?? {};
    const testStep = artifact.steps?.find?.(step => step.id === "test_or_explain") ?? {};
    summaries.push({
      file: proofFile,
      repo: artifact.inputs?.repoPath ?? null,
      status: artifact.overallStatus ?? null,
      branchClean: audit?.preflight?.branchClean ?? null,
      hasTestScript: audit?.preflight?.hasTestScript ?? null,
      testsPassed: audit?.preflight?.testsPassed ?? null,
      changedCount: audit?.status?.changedCount ?? null,
      testStepStatus: testStep?.status ?? null,
      testReason: testStep?.data?.reason ?? null,
      recommendedNextAction: artifact.recommendedNextAction ?? null,
    });
  }

  const rank = { fail: 0, warn: 1, pass: 2 };
  summaries.sort((a, b) => {
    const left = rank[a.status] ?? 99;
    const right = rank[b.status] ?? 99;
    if (left !== right) return left - right;
    return String(a.repo).localeCompare(String(b.repo));
  });

  return {
    proofsDir,
    count: summaries.length,
    summaries,
  };
};

globalThis.latestProofFor = async (
  repoPattern,
  proofsDir = pathMod.join(codex.homeDir || codex.cwd, ".workbench", "proof-rounds")
) => {
  const pattern = String(repoPattern || "").toLowerCase();
  const { summaries } = await proofSummaries(proofsDir);
  const matches = summaries.filter(summary =>
    !pattern ||
    String(summary.repo || "").toLowerCase().includes(pattern) ||
    String(summary.file || "").toLowerCase().includes(pattern)
  );

  if (matches.length === 0) {
    return null;
  }

  return matches
    .slice()
    .sort((a, b) => String(b.file).localeCompare(String(a.file)))[0];
};

globalThis.proofStatusCounts = async (
  proofsDir = pathMod.join(codex.homeDir || codex.cwd, ".workbench", "proof-rounds")
) => {
  const { summaries } = await proofSummaries(proofsDir);
  return summaries.reduce((counts, summary) => {
    const key = String(summary.status || "unknown");
    counts[key] = (counts[key] || 0) + 1;
    return counts;
  }, {});
};

globalThis.proofWarnReasons = async (
  proofsDir = pathMod.join(codex.homeDir || codex.cwd, ".workbench", "proof-rounds")
) => {
  const { summaries } = await proofSummaries(proofsDir);
  return summaries.reduce((counts, summary) => {
    if (summary.status !== "warn") return counts;
    const key = String(summary.testReason || "unknown");
    counts[key] = (counts[key] || 0) + 1;
    return counts;
  }, {});
};

globalThis.replHelp = () => ({
  load: 'await import(`${codex.cwd}/02_System/js-repl-helpers.mjs`)',
  helpers: [
    "hex",
    "read",
    "append",
    "mkdir",
    "copy",
    "write",
    "rm",
    "json",
    "writeJson",
    "ls",
    "exists",
    "head",
    "tail",
    "findText",
    "test",
    "assert",
    "run",
    "setRepo",
    "git",
    "gitStatus",
    "npmScript",
    "npmTest",
    "preflight",
    "summarizeStatus",
    "repoAudit",
    "testOrExplain",
    "getTitle",
    "proofSummaries",
    "latestProofFor",
    "proofStatusCounts",
    "proofWarnReasons",
    "replHelp",
  ],
  repo: globalThis.repo ?? null,
  cwd: codex.cwd,
});

console.log("codex-repl-helpers loaded: hex, read, append, mkdir, copy, write, rm, json, writeJson, ls, exists, head, tail, findText, test, assert, run, setRepo, git, gitStatus, npmScript, npmTest, preflight, summarizeStatus, repoAudit, testOrExplain, getTitle, proofSummaries, latestProofFor, proofStatusCounts, proofWarnReasons, replHelp");
