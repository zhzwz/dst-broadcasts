# broadcasts/features

**玩法功能**模块目录。每个子目录是一个可独立开关的功能（入口一般为 `init.lua`）。

## 约定

- 路径：`scripts/broadcasts/features/<feature_name>/`
- 由 `modmain` `modimport(".../features/<name>/init.lua")`；细项开关尽量在各功能 `init` 内判断
- 功能私有逻辑留在本目录；纯函数用 `../lib/`，游戏侧复用用 `../shared/`
- 每个功能目录宜有 `README.md` 说明配置、文件职责与行为

与基础设施目录的关系：

| 目录        | 用途                                                 |
| ----------- | ---------------------------------------------------- |
| `features/` | 玩法功能（袭击预警、青蛙雨、日历、收获、便携储存单元、玩家状态等） |
| `lib/`      | 与游戏无关的纯函数                                   |
| `shared/`   | 依赖 DST 的可复用小函数                              |

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
