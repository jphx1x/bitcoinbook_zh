# 《精通比特币》第三版 · 中文译稿

> **Mastering Bitcoin: Programming the Open Blockchain (3rd Edition)** by
> Andreas M. Antonopoulos & David A. Harding · O'Reilly Media, 2023
>
> 本仓库是该书的非官方中文翻译，逐章对照官方 AsciiDoc 源码翻译而成，
> 保留完整的 AsciiDoc 排版结构（锚点、交叉引用、索引条目、代码块、数学公式等），
> 渲染后可直接在浏览器中阅读，包含 83 张原书插图。

## 快速开始

```bash
# 直接双击或用浏览器打开
open index.html
```

无需联网即可阅读（仅数学公式需要在线加载 MathJax；如果离线，公式会显示为原始 LaTeX 源码，不影响其余内容）。

## 目录结构

```
bitcoinbook-zh/
├── index.html              ← 总目录
├── preface.html            ← 前言
├── ch01_intro.html         ← 第 1 章 · 引论
├── ch02_overview.html      ← 第 2 章 · Bitcoin 工作原理概览
├── ...                     ← 第 3–14 章
├── appa_whitepaper.html    ← 附录 A · Bitcoin 白皮书
├── appb_errata.html        ← 附录 B · 白皮书勘误
├── appc_bips.html          ← 附录 C · BIP 列表
│
├── images/                 ← 83 张原书插图（PNG）
├── code/                   ← 4 个 Python RPC 示例（被 ch03/ch12 引用）
├── meta/                   ← 版本变更说明、贡献者名单（被 preface 引用）
├── docinfo-footer.html     ← MathJax CDN 加载脚本
│
└── src/                    ← AsciiDoc 源文件
    ├── preface.adoc + 14 个章节 + 3 个附录 (.adoc)
    ├── render.sh           ← 一键重渲染脚本
    └── .parts/             ← 大章节分段翻译的 workflow 存档
```

## 阅读建议

建议按 `index.html` 列出的顺序阅读。前几章是概念入门，后几章逐层深入：

| 章 | 主题 | 体量 |
|---|---|---|
| 前言 + 第 1–2 章 | Bitcoin 是什么、典型流程 | 入门 |
| 第 3 章 | 运行你自己的 Bitcoin Core 节点 | 上手 |
| 第 4 章 | 密钥、地址、椭圆曲线密码学 | 核心 |
| 第 5 章 | 钱包（BIP-32/39 HD 钱包、PSBT） | 核心 |
| 第 6–8 章 | 交易结构、Script、签名（含 Taproot/Schnorr） | 进阶 |
| 第 9–12 章 | 手续费、网络、区块链、挖矿与共识 | 进阶 |
| 第 13–14 章 | 安全实践、Lightning/DLC 等应用 | 应用 |
| 附录 A | Satoshi 原始白皮书全文 | 经典 |
| 附录 B | 白皮书勘误 | 参考 |
| 附录 C | BIP 列表 | 参考 |

## 翻译规范

- **AsciiDoc 标记 100% 保留**：所有锚点 `[[id]]`、交叉引用 `<<id>>`、索引条目 `(((...)))`、`[NOTE]/[TIP]/[WARNING]` 提示框、侧栏、表格、代码块格式都按原样保留。
- **比特币专有名词保留英文**：UTXO、SegWit、Taproot、Schnorr、BIP（含编号）、所有 OP_* opcode、scriptSig/scriptPubKey、SIGHASH 系列、P2PKH/P2SH/P2WPKH/P2WSH/P2TR、HTLC、PSBT 等。
- **代码、十六进制、地址、URL、邮箱、人名不译**：所有代码块、Bitcoin 地址、私钥、十六进制数据、链接、Satoshi/Alice/Bob 等示例人物均保留英文原文。
- **大小写区分**：Bitcoin（系统）/bitcoin（货币单位）按原书严格区分。
- **bitcoin（货币单位）保留小写英文**，方便与中文 "比特币"（习惯叫法）区分使用场景。

## 自己重渲染（修改后用）

需要先装 asciidoctor（macOS / Linux 系统级 Ruby 即可）：

```bash
gem install --user-install asciidoctor
export PATH="$HOME/.gem/ruby/$(ruby -e 'puts RUBY_VERSION[/\d+\.\d+/]').0/bin:$PATH"
```

然后：

```bash
./src/render.sh              # 全量渲染并打开浏览器
./src/render.sh ch04_keys    # 仅渲染单章
./src/render.sh --no-open    # 不自动打开浏览器
OUT_DIR=/tmp/preview ./src/render.sh   # 指定输出目录
```

渲染脚本会：
1. 读取 `src/*.adoc`
2. 用 `docinfo-footer.html` 注入 MathJax
3. 输出到 `OUT_DIR`（默认覆盖当前根目录的 `*.html`）
4. 生成新的 `index.html`

## 版权与许可

- **原作**：_Mastering Bitcoin (3rd ed.)_ © 2024 Andreas M. Antonopoulos LLC & David A. Harding
- **原作许可**：[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)（自由分享与改编，需署名并以相同方式共享）
- **本翻译**：依据 CC BY-SA 4.0 的"改编"条款发布，沿用同一许可
- **AsciiDoc 源文件**：[bitcoinbook/bitcoinbook](https://github.com/bitcoinbook/bitcoinbook) 的 `develop` 分支（commit `275c4eb8`）

## 翻译方法

本翻译由大模型驱动的多 agent 工作流批量完成，过程中：

- 全 15 章 + 3 附录共约 17,000 行 AsciiDoc 源码自动翻译
- 大章节（ch04/ch07/ch12，1800–2200 行）按 `==` 边界切 8–11 段并行翻译
- 所有 AsciiDoc 标记、`\` 转义、`^上标^`、`[latexmath]` 块经脚本核对，结构完整性 100%
- 极少数处由人工调整：preface 跨文件 xref、ch04 中数学概率表达式、ch07 章节分隔空行

如果你在阅读中发现明显翻译问题，欢迎对 `src/*.adoc` 直接修改后 `./src/render.sh` 重渲染。
