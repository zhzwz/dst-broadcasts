#!/usr/bin/env bun
/**
 * 打包并上传 Steam Workshop。
 * 版本以 package.json 为准，发布前询问递增方式并同步到 modinfo.lua。
 *
 *   bun run release
 *   bun run release -- --pack-only
 */

import { ensureCleanWorktree, finalizeRelease } from "./finalize";
import { cleanBuildDirs, packMod } from "./pack";
import { uploadWorkshopItem } from "./steam";

type WorkshopConfig = {
  appId: number;
  publishedFileId: bigint;
};

type PackageJson = {
  version?: string;
  [key: string]: unknown;
};

const ROOT = decodeURIComponent(new URL("..", import.meta.url).pathname).replace(/\/$/, "");
const PACKAGE_JSON = `${ROOT}/package.json`;
const MODINFO = `${ROOT}/modinfo.lua`;
const WORKSHOP_DESCRIPTION = `${ROOT}/workshop-description.txt`;
const WORKSHOP: WorkshopConfig = {
  appId: 322330,
  publishedFileId: 3774915634n,
};

function usage(): never {
  console.error(`用法:
  bun run release
  bun run release -- --pack-only`);
  process.exit(1);
}

function parseArgs(argv: string[]) {
  let packOnly = false;

  for (const arg of argv) {
    if (arg === "--pack-only") {
      packOnly = true;
    } else if (arg === "--help" || arg === "-h") {
      usage();
    } else {
      console.error(`未知参数: ${arg}`);
      usage();
    }
  }

  return { packOnly };
}

function parseSemver(version: string): [number, number, number] {
  const match = version.trim().match(/^(\d+)\.(\d+)\.(\d+)$/);
  if (!match) {
    throw new Error(`package.json version 不是 x.y.z 格式: ${version}`);
  }
  return [Number(match[1]), Number(match[2]), Number(match[3])];
}

function bumpVersion(current: string, kind: "patch" | "minor" | "major"): string {
  const [major, minor, patch] = parseSemver(current);
  if (kind === "major") return `${major + 1}.0.0`;
  if (kind === "minor") return `${major}.${minor + 1}.0`;
  return `${major}.${minor}.${patch + 1}`;
}

async function readLine(prompt: string): Promise<string> {
  process.stdout.write(prompt);
  const reader = Bun.stdin.stream().getReader();
  const decoder = new TextDecoder();
  let buffer = "";
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      buffer += decoder.decode(value, { stream: true });
      const newline = buffer.indexOf("\n");
      if (newline >= 0) {
        return buffer.slice(0, newline).replace(/\r$/, "").trim();
      }
    }
  } finally {
    reader.releaseLock();
  }
  return buffer.replace(/\r$/, "").trim();
}

async function askVersionBump(current: string, allowKeep: boolean): Promise<string> {
  const patch = bumpVersion(current, "patch");
  const minor = bumpVersion(current, "minor");
  const major = bumpVersion(current, "major");

  console.log(`当前版本: ${current}`);
  console.log("请选择版本递增方式:");
  console.log(`  1) patch  -> ${patch}`);
  console.log(`  2) minor  -> ${minor}`);
  console.log(`  3) major  -> ${major}`);
  if (allowKeep) {
    console.log(`  4) 保持   -> ${current}`);
  }

  while (true) {
    const answer = await readLine(`输入 1-${allowKeep ? 4 : 3}: `);
    if (answer === "1" || answer === "patch") return patch;
    if (answer === "2" || answer === "minor") return minor;
    if (answer === "3" || answer === "major") return major;
    if (allowKeep && (answer === "4" || answer === "keep" || answer === "")) return current;
    console.log("无效输入，请重新选择。");
  }
}

async function writePackageVersion(pkg: PackageJson, version: string) {
  pkg.version = version;
  await Bun.write(PACKAGE_JSON, `${JSON.stringify(pkg, null, 2)}\n`);
}

async function restoreVersionFiles(packageJson: string, modinfo: string) {
  await Promise.all([
    Bun.write(PACKAGE_JSON, packageJson),
    Bun.write(MODINFO, modinfo),
  ]);
}

async function main() {
  const args = parseArgs(Bun.argv.slice(2));
  if (!args.packOnly) {
    await ensureCleanWorktree();
  }

  const originalPackageJson = await Bun.file(PACKAGE_JSON).text();
  const originalModinfo = await Bun.file(MODINFO).text();
  const pkg = JSON.parse(originalPackageJson) as PackageJson;
  const currentVersion = pkg.version;
  if (!currentVersion) {
    throw new Error("package.json 缺少 version");
  }

  const workshop = WORKSHOP;
  const preview = `${ROOT}/preview.png`;

  if (!(await Bun.file(preview).exists())) {
    throw new Error("缺少 preview.png");
  }
  if (!args.packOnly && !(await Bun.file(WORKSHOP_DESCRIPTION).exists())) {
    throw new Error("缺少 workshop-description.txt");
  }

  const version = await askVersionBump(currentVersion, args.packOnly);
  let uploaded = false;
  try {
    if (version !== currentVersion) {
      await writePackageVersion(pkg, version);
      console.log(`已更新 package.json version: ${currentVersion} -> ${version}`);
    } else {
      console.log(`保持版本: ${version}`);
    }

    const outDir = `${ROOT}/broadcasts-${version}`;
    console.log(`打包目录: ${outDir}`);
    if (!args.packOnly) {
      await cleanBuildDirs();
    }
    await packMod(outDir);
    console.log(`已同步 modinfo.lua version = "${version}"`);

    if (args.packOnly) {
      if (version !== currentVersion) {
        await restoreVersionFiles(originalPackageJson, originalModinfo);
        console.log("已回滚工作区版本文件（打包目录仍为新版本）");
      }
      console.log("已按 --pack-only 结束（未上传）");
      return;
    }

    if (version === currentVersion) {
      console.warn("警告: 版本未变化，Steam 工坊可能拒绝更新（需 version 更新）。");
    }

    console.log("正在通过已登录的 Steam 客户端上传...");
    await uploadWorkshopItem({
      appId: workshop.appId,
      publishedFileId: workshop.publishedFileId,
      contentPath: outDir,
      descriptionPath: WORKSHOP_DESCRIPTION,
      modinfoPath: MODINFO,
      previewPath: preview,
      version,
    });

    uploaded = true;
    console.log("上传完成");
    console.log(`工坊: https://steamcommunity.com/sharedfiles/filedetails/?id=${workshop.publishedFileId}`);
    await finalizeRelease(version);
  } catch (error) {
    if (uploaded) {
      console.error("工坊上传已完成，但 Git 收尾失败；版本修改已保留，请手动处理提交和标签");
      throw error;
    }
    try {
      await restoreVersionFiles(originalPackageJson, originalModinfo);
      console.error("发布失败，已回滚 package.json 和 modinfo.lua 的版本");
    } catch (rollbackError) {
      throw new AggregateError([error, rollbackError], "发布失败，且版本回滚失败");
    }
    throw error;
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error instanceof Error ? error.message : error);
    process.exit(1);
  });
