#!/usr/bin/env bash
# render.sh — 渲染 zh/*.adoc 为 HTML 并生成索引页
#
# 用法：
#   ./render.sh            渲染所有 .adoc，生成索引，打开浏览器
#   ./render.sh ch01_intro 只渲染指定章节（可省略 .adoc 后缀）
#   ./render.sh --no-open  不自动打开浏览器
#
set -euo pipefail

ZH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$ZH_DIR")"
OUT_DIR="${OUT_DIR:-$PROJECT_ROOT}"
ASCIIDOCTOR="${ASCIIDOCTOR:-$(command -v asciidoctor || echo /Users/admin/.gem/ruby/2.6.0/bin/asciidoctor)}"
OPEN_BROWSER=1
TARGET=""

# 解析参数
for arg in "$@"; do
  case "$arg" in
    --no-open) OPEN_BROWSER=0 ;;
    -h|--help)
      sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
      exit 0
      ;;
    *) TARGET="${arg%.adoc}" ;;
  esac
done

# 检查 asciidoctor
if [ ! -x "$ASCIIDOCTOR" ]; then
  echo "错误：asciidoctor 不在 $ASCIIDOCTOR" >&2
  echo "  尝试: gem install --user-install asciidoctor" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# 收集要渲染的文件列表
if [ -n "$TARGET" ]; then
  files=( "$ZH_DIR/${TARGET}.adoc" )
  if [ ! -f "${files[0]}" ]; then
    echo "错误：找不到 ${files[0]}" >&2
    exit 1
  fi
else
  files=( "$ZH_DIR"/*.adoc )
  # 处理 glob 不匹配的情况
  if [ ! -e "${files[0]}" ]; then
    echo "错误：$ZH_DIR 下没有 .adoc 文件" >&2
    exit 1
  fi
fi

# 渲染每个文件
echo "→ 渲染到 $OUT_DIR"
rendered=()
for src in "${files[@]}"; do
  name="$(basename "$src" .adoc)"
  out="$OUT_DIR/${name}.html"
  echo "  ✓ $name"
  "$ASCIIDOCTOR" \
    --base-dir "$PROJECT_ROOT" \
    -a icons=font \
    -a source-highlighter=highlight.js \
    -a stem=latexmath \
    -a docinfo=shared \
    -o "$out" \
    "$src" 2>&1 | sed 's/^/    /' || true
  rendered+=( "$name" )
done

# 生成索引页
INDEX="$OUT_DIR/index.html"
{
  cat <<'HTML_HEAD'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<title>Mastering Bitcoin 第三版 · 中文译稿</title>
<style>
  body { font-family: -apple-system, "PingFang SC", "Microsoft YaHei", sans-serif;
         max-width: 760px; margin: 60px auto; padding: 0 20px;
         color: #2a2a2a; line-height: 1.7; }
  h1 { font-size: 28px; border-bottom: 2px solid #f7931a; padding-bottom: 10px; }
  .meta { color: #888; font-size: 14px; margin-top: -10px; }
  ul { list-style: none; padding: 0; }
  li { padding: 10px 14px; border-radius: 6px; margin: 4px 0;
       transition: background .15s; }
  li:hover { background: #f7f7f7; }
  a { text-decoration: none; color: #1a73e8; font-size: 16px; }
  .ch { display: inline-block; min-width: 70px; color: #999; font-family: monospace; }
  .src { color: #b0b0b0; font-size: 12px; margin-left: 8px; }
  .updated { color: #999; font-size: 13px; }
</style>
</head>
<body>
<h1>《精通比特币》第三版 · 中文译稿</h1>
<ul>
HTML_HEAD

  # 章节顺序：preface → ch01-ch14 → 其他
  print_li() {
    local name="$1"
    local label
    case "$name" in
      preface)            label="前言" ;;
      ch01_intro)         label="第 1 章 · 引论" ;;
      ch02_overview)      label="第 2 章 · Bitcoin 工作原理概览" ;;
      ch03_bitcoin-core)  label="第 3 章 · Bitcoin Core" ;;
      ch04_keys)          label="第 4 章 · 密钥与地址" ;;
      ch05_wallets)       label="第 5 章 · 钱包" ;;
      ch06_transactions)  label="第 6 章 · 交易" ;;
      ch07_authorization-authentication) label="第 7 章 · 授权与认证" ;;
      ch08_signatures)    label="第 8 章 · 数字签名" ;;
      ch09_fees)          label="第 9 章 · 手续费" ;;
      ch10_network)       label="第 10 章 · Bitcoin 网络" ;;
      ch11_blockchain)    label="第 11 章 · 区块链" ;;
      ch12_mining)        label="第 12 章 · 挖矿与共识" ;;
      ch13_security)      label="第 13 章 · 安全" ;;
      ch14_applications)  label="第 14 章 · Bitcoin 应用" ;;
      appa_whitepaper)    label="附录 A · Bitcoin 白皮书" ;;
      appb_errata)        label="附录 B · 白皮书勘误" ;;
      appc_bips)          label="附录 C · BIP 列表" ;;
      *)                  label="$name" ;;
    esac
    local size
    size=$(wc -l < "$ZH_DIR/${name}.adoc" 2>/dev/null | tr -d ' ')
    echo "  <li><a href=\"${name}.html\">${label}</a><span class=\"src\">${size} 行</span></li>"
  }

  order=(preface ch01_intro ch02_overview ch03_bitcoin-core ch04_keys ch05_wallets \
         ch06_transactions ch07_authorization-authentication ch08_signatures \
         ch09_fees ch10_network ch11_blockchain ch12_mining ch13_security ch14_applications \
         appa_whitepaper appb_errata appc_bips)
  printed=()
  for name in "${order[@]}"; do
    if [ -f "$ZH_DIR/${name}.adoc" ]; then
      print_li "$name"
      printed+=( "$name" )
    fi
  done
  # 列出顺序表未涵盖的其他文件
  for src in "$ZH_DIR"/*.adoc; do
    name="$(basename "$src" .adoc)"
    skip=0
    for p in "${printed[@]:-}"; do
      [ "$p" = "$name" ] && { skip=1; break; }
    done
    [ "$skip" = 1 ] || print_li "$name"
  done

  cat <<HTML_FOOT
</ul>
<p class="updated">生成于 $(date '+%Y-%m-%d %H:%M:%S')</p>
</body>
</html>
HTML_FOOT
} > "$INDEX"

echo
echo "→ 索引页: $INDEX"
echo "→ 共渲染 ${#rendered[@]} 章"

if [ "$OPEN_BROWSER" = "1" ]; then
  open "$INDEX"
fi
