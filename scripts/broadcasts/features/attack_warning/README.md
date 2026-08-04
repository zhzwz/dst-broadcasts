# features/attack_warning（袭击预警）

玩法功能模块：猎犬、洞穴蠕虫、巨鹿、熊獾的倒计时预警与相关播报。
同类功能放在 `scripts/broadcasts/features/<name>/`，与 `lib/`、`shared/` 区分。

## 配置（默认均开启）

| 键                             | 作用                        |
| ------------------------------ | --------------------------- |
| `hounds_warning_enabled`       | 地表猎犬：倒计时 + 袭击开始 |
| `depths_worms_warning_enabled` | 洞穴蠕虫：倒计时 + 袭击开始 |
| `deerclops_warning_enabled`    | 巨鹿：倒计时预警            |
| `bearger_warning_enabled`      | 熊獾：倒计时预警            |

`modmain` 始终 `modimport` 本目录 `init.lua`；全部关闭时 `init` 直接返回，不加载子模块。

## 文件

| 文件            | 职责                                                     |
| --------------- | -------------------------------------------------------- |
| `init.lua`      | 入口；按配置加载子模块与 `lib/cross_real_thresholds`     |
| `constants.lua` | 阈值、轮询间隔、计时器名 → `BROADCASTS_ATTACK_WARNING`   |
| `watch.lua`     | 共用倒计时轮询与播报 → `BROADCASTS_WATCH_ATTACK_WARNING` |
| `hounded.lua`   | 猎犬 / 蠕虫（`hounded` 组件）                            |
| `hassler.lua`   | 巨鹿 / 熊獾倒计时（`worldsettingstimer`）                |

## 倒计时档位

现实时间：8 / 4 / 2 / 1 分钟，以及 30 / 10 / 5 秒。
文案键：`attack_time`、`durations[秒]`；袭击开始：`attack_started`。

现身播报见 `features/appear`。与早报无关；不写持久化状态，重载后阈值标记重置。

## 依赖

- `../../lib/cross_real_thresholds.lua`：阈值跨越纯函数
- `BROADCASTS_SAFE` / `BROADCASTS_STRINGS` / 全局常量

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
