#!/usr/bin/env bun
/**
 * 从 modinfo.base.lua + modinfo_language/*.lua 生成自包含的 modinfo.lua。
 *
 * 文案唯一来源是 modinfo_language/；modinfo.lua 是生成物（已 gitignore），
 * 因 DST modinfo 沙箱没有 require / kleiloadlua，只能内联后才能被游戏加载。
 *
 *   bun run tools/embed_modinfo_languages.ts [输出路径]
 *   默认输出: <repo>/modinfo.lua
 */

const ROOT = decodeURIComponent(new URL("..", import.meta.url).pathname).replace(/\/$/, "");
const MODINFO_BASE = `${ROOT}/modinfo.base.lua`;
const MODINFO_OUT = `${ROOT}/modinfo.lua`;
const LANG_DIR = `${ROOT}/modinfo_language`;

const BEGIN = "-- BEGIN_MODINFO_LANGUAGES";
const END = "-- END_MODINFO_LANGUAGES";

const LANG_CODES = [
  "en",
  "zh",
  "zht",
  "fr",
  "de",
  "it",
  "es",
  "pt",
  "pl",
  "ru",
  "ko",
  "ja",
] as const;

async function readLanguageTable(code: string): Promise<string> {
  const text = (await Bun.file(`${LANG_DIR}/${code}.lua`).text()).replace(/^\uFEFF/, "");
  const match = text.match(/^return\s*(\{[\s\S]*\})\s*$/);
  if (!match) {
    throw new Error(`无法解析 modinfo_language/${code}.lua：需要整文件为 return { ... }`);
  }
  return match[1];
}

function formatLangEntry(code: string, table: string): string {
  // 不改动表体缩进，避免 [[...]] 长字符串内容被注入空格
  return `${code} = ${table},`;
}

async function buildLanguageBlock(): Promise<string> {
  const entries: string[] = [];
  for (const code of LANG_CODES) {
    entries.push(formatLangEntry(code, await readLanguageTable(code)));
  }

  return `${BEGIN}
local MODINFO_LANG = {
${entries.join("\n")}
}

local L = ChooseTranslationTable({
    MODINFO_LANG.en,
    zh = MODINFO_LANG.zh,
    zhr = MODINFO_LANG.zh,
    zht = MODINFO_LANG.zht,
    fr = MODINFO_LANG.fr,
    de = MODINFO_LANG.de,
    it = MODINFO_LANG.it,
    es = MODINFO_LANG.es,
    pt = MODINFO_LANG.pt,
    pl = MODINFO_LANG.pl,
    ru = MODINFO_LANG.ru,
    ko = MODINFO_LANG.ko,
    ja = MODINFO_LANG.ja,
})
${END}`;
}

function replaceLanguageBlock(base: string, block: string): string {
  if (!base.includes(BEGIN) || !base.includes(END)) {
    throw new Error("modinfo.base.lua 缺少 BEGIN_MODINFO_LANGUAGES / END_MODINFO_LANGUAGES 标记");
  }
  const pattern = new RegExp(
    `${BEGIN.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}[\\s\\S]*?${END.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}`,
  );
  const next = base.replace(pattern, block);
  if (next === base) {
    throw new Error("未能替换 modinfo.base.lua 中的语言段");
  }
  return next;
}

export async function embedModinfoLanguages(targetPath = MODINFO_OUT): Promise<void> {
  const base = await Bun.file(MODINFO_BASE).text();
  const block = await buildLanguageBlock();
  await Bun.write(targetPath, replaceLanguageBlock(base, block));
}

if (import.meta.main) {
  const out = Bun.argv[2] || MODINFO_OUT;
  embedModinfoLanguages(out)
    .then(() => {
      const rel = out.startsWith(`${ROOT}/`) ? out.slice(ROOT.length + 1) : out;
      console.log(`已从 modinfo_language/ 生成 ${rel}`);
    })
    .catch((error) => {
      console.error(error instanceof Error ? error.message : error);
      process.exit(1);
    });
}
