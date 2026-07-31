#!/bin/sh
# 打包模组到指定目录，并生成 preview/preview.png
# 用法: ./preview.sh [目标目录]
# 默认目标目录: broadcasts-<version>

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
MODINFO="$ROOT/modinfo.lua"
SVG="$ROOT/wilson.svg"
PREVIEW_DIR="$ROOT/preview"
PREVIEW_PNG="$PREVIEW_DIR/preview.png"

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

find "$out_dir" -name '.DS_Store' -delete
find "$out_dir" -name '*.zip' -delete

echo "packed ${out_dir#"$ROOT"/}/"
find "$out_dir" -type f | sed "s|^$out_dir/|  |" | sort

if [ ! -f "$SVG" ]; then
  echo "找不到 $SVG，跳过 preview.png" >&2
  exit 1
fi

python3 "$ROOT/tools/generate_preview.py" --svg "$SVG" -o "$PREVIEW_PNG"
echo "hint: Preview Image 请选 preview/preview.png"
