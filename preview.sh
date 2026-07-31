#!/bin/sh
# 打包模组到指定目录。
# ModUploader 会上传目录内全部文件，因此单独打出一份干净包，避免把无关内容传上工坊。
# 用法: ./preview.sh [目标目录]
# 默认目标目录: broadcasts-<version>

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
MODINFO="$ROOT/modinfo.lua"

if [ ! -f "$MODINFO" ]; then
  echo "找不到 $MODINFO" >&2
  exit 1
fi

version="$(
  sed -n 's/^[[:space:]]*version[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$MODINFO" | head -n 1
)"

if [ -z "$version" ]; then
  echo "无法从 $MODINFO 解析 version" >&2
  exit 1
fi

if [ "$#" -ge 1 ]; then
  out_dir="$1"
  case "$out_dir" in
    /*) ;;
    *) out_dir="$ROOT/$out_dir" ;;
  esac
else
  out_dir="$ROOT/broadcasts-$version"
fi

if [ -e "$out_dir" ]; then
  rm -rf "$out_dir"
fi

mkdir -p "$out_dir"

cp "$ROOT/modinfo.lua" "$out_dir/"
cp "$ROOT/modmain.lua" "$out_dir/"
cp -R "$ROOT/scripts" "$out_dir/"

if ! command -v npx >/dev/null 2>&1; then
  echo "找不到 npx，无法压缩 Lua 文件" >&2
  exit 1
fi

for file in "$out_dir/modinfo.lua" "$out_dir/modmain.lua" "$out_dir"/scripts/broadcasts/*.lua; do
  minified="$file.min"
  code="$(sed -n 'p' "$file")"
  if ! npx --yes luamin@1.0.4 --code "$code" > "$minified"; then
    rm -f "$minified"
    echo "压缩失败：${file#"$out_dir"/}" >&2
    exit 1
  fi
  code="$(sed '1{/^$/d;}' "$minified")"
  printf '%s' "$code" > "$file"
  rm "$minified"
done

find "$out_dir" -name '.DS_Store' -delete
find "$out_dir" -name '*.zip' -delete

echo "Lua 文件已压缩"
echo "已生成 ${out_dir#"$ROOT"/}/"
find "$out_dir" -type f | sed "s|^$out_dir/|  |" | sort

if [ -f "$ROOT/preview.png" ]; then
  echo "创意工坊封面：preview.png"
else
  echo "未找到创意工坊封面 preview.png" >&2
fi
