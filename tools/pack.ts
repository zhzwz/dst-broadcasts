#!/usr/bin/env bun
/**
 * 打包模组到指定目录。
 * ModUploader 会上传目录内全部文件，因此单独打出一份干净包，避免把无关内容传上工坊。
 *
 *   bun run tools/pack.ts [目标目录]
 *   默认目标目录: broadcasts-<version>
 */

import { $, Glob } from "bun";
import luamin from "luamin";
import { isAbsolute, relative, resolve, sep } from "node:path";

const ROOT = decodeURIComponent(new URL("..", import.meta.url).pathname).replace(/\/$/, "");
const PACKAGE_JSON = `${ROOT}/package.json`;

type PackageJson = {
  version?: string;
};

async function readVersion(): Promise<string> {
  const pkg = JSON.parse(await Bun.file(PACKAGE_JSON).text()) as PackageJson;
  if (!pkg.version) {
    throw new Error("package.json 缺少 version");
  }
  return pkg.version;
}

function resolveOutDir(version: string, arg?: string): string {
  const outDir = resolve(ROOT, arg ?? `broadcasts-${version}`);
  const relativePath = relative(ROOT, outDir);
  const isDirectBuildDir =
    relativePath.startsWith("broadcasts-") &&
    !relativePath.includes(sep);
  if (
    !relativePath ||
    relativePath === ".." ||
    relativePath.startsWith(`..${sep}`) ||
    isAbsolute(relativePath) ||
    !isDirectBuildDir
  ) {
    throw new Error(`目标目录必须是项目根目录下的 broadcasts-* 目录: ${outDir}`);
  }
  return outDir;
}

async function pathExists(path: string): Promise<boolean> {
  return (await $`test -e ${path}`.quiet().nothrow()).exitCode === 0;
}

async function listPackedFiles(outDir: string): Promise<string[]> {
  const files: string[] = [];
  for await (const path of new Glob("**/*").scan({
    cwd: outDir,
    onlyFiles: true,
  })) {
    files.push(path);
  }
  return files.sort();
}

async function minifyLuaFile(filePath: string) {
  const code = await Bun.file(filePath).text();
  let minified = luamin.minify(code);
  if (minified.startsWith("\n")) {
    minified = minified.slice(1);
  }
  await Bun.write(filePath, minified);
}

async function syncModinfoVersion(version: string) {
  const modinfoPath = `${ROOT}/modinfo.lua`;
  const text = await Bun.file(modinfoPath).text();
  if (!/^\s*version\s*=\s*"[^"]*"/m.test(text)) {
    throw new Error("modinfo.lua 中找不到 version 字段");
  }
  const next = text.replace(/^\s*version\s*=\s*"[^"]*"/m, `version = "${version}"`);
  if (next !== text) {
    await Bun.write(modinfoPath, next);
  }
}

async function cleanupJunk(outDir: string) {
  for await (const path of new Glob("**/{.DS_Store,*.zip}").scan({
    cwd: outDir,
    absolute: true,
    dot: true,
    onlyFiles: true,
  })) {
    await $`rm -f ${path}`.quiet();
  }
}

export async function cleanBuildDirs() {
  const removed: string[] = [];
  for await (const path of new Glob("broadcasts-*").scan({
    cwd: ROOT,
    absolute: true,
    onlyFiles: false,
  })) {
    resolveOutDir("unused", path);
    if ((await $`test -d ${path}`.quiet().nothrow()).exitCode === 0) {
      await $`rm -rf ${path}`.quiet();
      removed.push(path.slice(ROOT.length + 1));
    }
  }
  if (removed.length > 0) {
    console.log(`已删除历史打包目录: ${removed.sort().join(", ")}`);
  }
}

export async function packMod(outDirArg?: string): Promise<string> {
  if (!(await pathExists(PACKAGE_JSON))) {
    throw new Error(`找不到 ${PACKAGE_JSON}`);
  }
  if (!(await pathExists(`${ROOT}/modinfo.lua`))) {
    throw new Error(`找不到 ${ROOT}/modinfo.lua`);
  }
  if (!(await pathExists(`${ROOT}/modmain.lua`))) {
    throw new Error(`找不到 ${ROOT}/modmain.lua`);
  }
  if (!(await pathExists(`${ROOT}/modinfo_language`))) {
    throw new Error(`找不到 ${ROOT}/modinfo_language`);
  }
  if (!(await pathExists(`${ROOT}/scripts`))) {
    throw new Error(`找不到 ${ROOT}/scripts`);
  }

  const version = await readVersion();
  const outDir = resolveOutDir(version, outDirArg);

  await syncModinfoVersion(version);
  await $`rm -rf ${outDir}`.quiet();
  await $`mkdir -p ${outDir}`.quiet();
  await $`cp ${ROOT}/modinfo.lua ${ROOT}/modmain.lua ${outDir}/`.quiet();
  await $`cp -R ${ROOT}/modinfo_language ${outDir}/`.quiet();
  await $`cp -R ${ROOT}/scripts ${outDir}/`.quiet();

  const luaFiles = [
    `${outDir}/modinfo.lua`,
    `${outDir}/modmain.lua`,
    ...(await Array.fromAsync(
      new Glob("modinfo_language/*.lua").scan({ cwd: outDir, absolute: true }),
    )),
    ...(await Array.fromAsync(
      new Glob("scripts/broadcasts/*.lua").scan({ cwd: outDir, absolute: true }),
    )),
  ];

  for (const file of luaFiles) {
    try {
      await minifyLuaFile(file);
    } catch (error) {
      const rel = file.startsWith(`${outDir}/`) ? file.slice(outDir.length + 1) : file;
      throw new Error(`压缩失败：${rel}${error instanceof Error ? ` (${error.message})` : ""}`);
    }
  }

  await cleanupJunk(outDir);

  console.log("Lua 文件已压缩");
  console.log(`已生成 ${outDir.startsWith(`${ROOT}/`) ? outDir.slice(ROOT.length + 1) : outDir}/`);
  for (const file of await listPackedFiles(outDir)) {
    console.log(`  ${file}`);
  }

  if (await Bun.file(`${ROOT}/preview.png`).exists()) {
    console.log("创意工坊封面：preview.png");
  } else {
    console.error("未找到创意工坊封面 preview.png");
  }

  return outDir;
}

if (import.meta.main) {
  packMod(Bun.argv[2]).catch((error) => {
    console.error(error instanceof Error ? error.message : error);
    process.exit(1);
  });
}
