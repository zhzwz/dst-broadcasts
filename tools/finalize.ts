#!/usr/bin/env bun

const ROOT = decodeURIComponent(new URL("..", import.meta.url).pathname).replace(/\/$/, "");
const VERSION_FILES = ["package.json", "modinfo/base.lua"];

type PackageJson = {
  version?: string;
};

async function gitOutput(args: string[]): Promise<{ exitCode: number; stdout: string; stderr: string }> {
  const process = Bun.spawn(["git", ...args], {
    cwd: ROOT,
    stdout: "pipe",
    stderr: "pipe",
  });
  const [exitCode, stdout, stderr] = await Promise.all([
    process.exited,
    new Response(process.stdout).text(),
    new Response(process.stderr).text(),
  ]);
  return { exitCode, stdout, stderr };
}

async function runGit(args: string[]) {
  const process = Bun.spawn(["git", ...args], {
    cwd: ROOT,
    stdin: "inherit",
    stdout: "inherit",
    stderr: "inherit",
  });
  if ((await process.exited) !== 0) {
    throw new Error(`git ${args[0]} 执行失败，退出码 ${process.exitCode}`);
  }
}

export async function ensureCleanWorktree() {
  const result = await gitOutput(["status", "--porcelain=v1", "--untracked-files=normal"]);
  if (result.exitCode !== 0) {
    throw new Error(result.stderr.trim() || "无法检查 Git 工作区状态");
  }
  if (result.stdout.trim()) {
    throw new Error(`发布前必须提交或清理工作区修改：\n${result.stdout.trimEnd()}`);
  }
}

export async function finalizeRelease(version: string) {
  if (!/^\d+\.\d+\.\d+$/.test(version)) {
    throw new Error(`无效版本号: ${version}`);
  }

  const tag = `v${version}`;
  const tagCheck = await gitOutput(["rev-parse", "--verify", "--quiet", `refs/tags/${tag}`]);
  if (tagCheck.exitCode === 0) {
    throw new Error(`标签 ${tag} 已存在`);
  }
  if (tagCheck.exitCode !== 1) {
    throw new Error(tagCheck.stderr.trim() || `无法检查标签 ${tag}`);
  }

  const status = await gitOutput(["status", "--porcelain=v1", "--untracked-files=normal"]);
  if (status.exitCode !== 0) {
    throw new Error(status.stderr.trim() || "无法检查 Git 工作区状态");
  }
  const unexpected = status.stdout
    .trimEnd()
    .split("\n")
    .filter(Boolean)
    .filter((line) => !VERSION_FILES.includes(line.slice(3)));
  if (unexpected.length > 0) {
    throw new Error(`发布期间出现了非版本文件修改，已暂停 Git 收尾：\n${unexpected.join("\n")}`);
  }

  await runGit(["add", "--", ...VERSION_FILES]);
  const staged = await gitOutput(["diff", "--cached", "--quiet", "--", ...VERSION_FILES]);
  if (staged.exitCode === 0) {
    throw new Error("版本文件没有变化，无法创建发布提交");
  }
  if (staged.exitCode !== 1) {
    throw new Error(staged.stderr.trim() || "无法检查待提交的版本修改");
  }

  await runGit(["commit", "-m", `chore(release): ${tag}`]);
  await runGit(["tag", "-a", tag, "-m", `Release ${tag}`]);
  console.log(`已创建发布提交和标签 ${tag}`);
  console.log("未推送到远程；需要时请执行: git push && git push --tags");
}

async function readVersion(): Promise<string> {
  const pkg = JSON.parse(await Bun.file(`${ROOT}/package.json`).text()) as PackageJson;
  if (!pkg.version) {
    throw new Error("package.json 缺少 version");
  }
  return pkg.version;
}

if (import.meta.main) {
  const version = Bun.argv[2] || await readVersion();
  finalizeRelease(version).catch((error) => {
    console.error(error instanceof Error ? error.message : error);
    process.exit(1);
  });
}
