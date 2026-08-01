#!/usr/bin/env bun
/**
 * 打包并上传 Steam Workshop。
 *
 *   bun run release
 *   bun run release -- --pack-only
 *   bun run release -- --dry-run
 */

import { $ } from "bun";

type WorkshopConfig = {
  appid: string;
  publishedfileid: string;
  steamUser: string;
};

const ROOT = decodeURIComponent(new URL("..", import.meta.url).pathname).replace(/\/$/, "");
const DST_APPID = "322330";

function usage(): never {
  console.error(`用法:
  bun run release
  bun run release -- --pack-only
  bun run release -- --dry-run`);
  process.exit(1);
}

function parseArgs(argv: string[]) {
  let packOnly = false;
  let dryRun = false;

  for (const arg of argv) {
    if (arg === "--pack-only") {
      packOnly = true;
    } else if (arg === "--dry-run") {
      dryRun = true;
    } else if (arg === "--help" || arg === "-h") {
      usage();
    } else {
      console.error(`未知参数: ${arg}`);
      usage();
    }
  }

  return { packOnly, dryRun };
}

async function readVersion(modinfoPath: string): Promise<string> {
  const text = await Bun.file(modinfoPath).text();
  const match = text.match(/^\s*version\s*=\s*"([^"]+)"/m);
  if (!match?.[1]) {
    throw new Error(`无法从 ${modinfoPath} 解析 version`);
  }
  return match[1];
}

function requireEnv(name: string): string {
  const value = Bun.env[name]?.trim();
  if (!value) {
    throw new Error(`缺少环境变量 ${name}，请在 .env 中填写`);
  }
  return value;
}

function readWorkshopConfig(): WorkshopConfig {
  // Bun 会自动加载项目根目录 .env
  const workshop = {
    steamUser: requireEnv("STEAM_USER"),
    appid: Bun.env.WORKSHOP_APPID?.trim() || DST_APPID,
    publishedfileid: requireEnv("WORKSHOP_PUBLISHED_FILE_ID"),
  };
  if (workshop.appid !== DST_APPID) {
    console.warn(`警告: WORKSHOP_APPID=${workshop.appid}，DST 创意工坊通常为 ${DST_APPID}`);
  }
  return workshop;
}

async function writeVdf(filePath: string, values: {
  appid: string;
  publishedfileid: string;
  contentfolder: string;
  previewfile: string;
}) {
  const escape = (value: string) => value.replaceAll("\\", "\\\\").replaceAll('"', '\\"');
  const body = `"workshopitem"
{
    "appid"           "${escape(values.appid)}"
    "publishedfileid" "${escape(values.publishedfileid)}"
    "contentfolder"   "${escape(values.contentfolder)}"
    "previewfile"     "${escape(values.previewfile)}"
    "changenote"      ""
}
`;
  await Bun.write(filePath, body);
}

function ensureSteamcmd(): string {
  const which = Bun.which("steamcmd");
  if (!which) {
    throw new Error("找不到 steamcmd，请先安装（如 brew install steamcmd）");
  }
  return which;
}

async function main() {
  const args = parseArgs(Bun.argv.slice(2));
  const version = await readVersion(`${ROOT}/modinfo.lua`);
  const workshop = readWorkshopConfig();
  const outDir = `${ROOT}/broadcasts-${version}`;
  const preview = `${ROOT}/preview.png`;
  const vdfPath = `${ROOT}/workshop.vdf`;

  if (!(await Bun.file(preview).exists())) {
    throw new Error("缺少 preview.png");
  }

  console.log(`版本: ${version}`);
  console.log(`打包目录: ${outDir}`);

  if (args.dryRun) {
    console.log("[dry-run] 跳过 preview.sh / steamcmd");
    console.log(`将使用 publishedfileid=${workshop.publishedfileid}`);
    return;
  }

  const pack = Bun.spawn(["./preview.sh", outDir], {
    cwd: ROOT,
    stdin: "inherit",
    stdout: "inherit",
    stderr: "inherit",
  });
  if ((await pack.exited) !== 0) {
    throw new Error(`打包失败，退出码 ${pack.exitCode}`);
  }

  await writeVdf(vdfPath, {
    appid: workshop.appid,
    publishedfileid: workshop.publishedfileid,
    contentfolder: outDir,
    previewfile: preview,
  });
  console.log(`已写入 ${vdfPath}`);

  if (args.packOnly) {
    console.log("已按 --pack-only 结束（未上传）");
    return;
  }

  const steamcmd = ensureSteamcmd();
  console.log(`上传中（Steam 用户: ${workshop.steamUser}）...`);
  console.log("若未缓存登录态，请按提示输入密码 / Steam Guard。");

  // steamcmd 需要可写的 home；部分环境 HOME 异常时用本地目录兜底
  const steamHome = `${ROOT}/.steamcmd-home`;
  await $`mkdir -p ${steamHome}`.quiet();
  await $`chmod 700 ${steamHome}`.quiet();

  const upload = Bun.spawn([
    steamcmd,
    "+login",
    workshop.steamUser,
    "+workshop_build_item",
    vdfPath,
    "+quit",
  ], {
    cwd: ROOT,
    stdin: "inherit",
    stdout: "inherit",
    stderr: "inherit",
    env: {
      ...Bun.env,
      HOME: Bun.env.HOME || steamHome,
    },
  });
  if ((await upload.exited) !== 0) {
    throw new Error(`steamcmd 上传失败，退出码 ${upload.exitCode}`);
  }

  console.log("上传完成");
  console.log(`工坊: https://steamcommunity.com/sharedfiles/filedetails/?id=${workshop.publishedfileid}`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
