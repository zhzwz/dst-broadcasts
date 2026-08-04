# broadcasts/shared

可复用的小函数（实体、组件、`STRINGS`、世界状态等）。

## 约定

- **单文件单函数**：文件名用 snake_case，与导出符号对应。
- **文件开头注释**：说明用途、前置条件、参数与返回值；注明会触碰的游戏 API。
- **尽量复用即抽取**：即便当前只有一处调用，只要是稳定的游戏侧小能力，也可放这里。
- **随用随引**：功能模块需要时再 `modimport("scripts/broadcasts/shared/<name>.lua")`，不要在 `modmain` 全量加载。
- **导出命名**：`BROADCASTS_<NAME>`，全大写蛇形，与文件名一致（例如 `is_at_min_health.lua` → `BROADCASTS_IS_AT_MIN_HEALTH`）。
- **单测**：若可在无游戏环境下测（需 mock），同目录 `xxx.test.lua`；纯逻辑请放 `../lib/`。

## 与 lib / 功能目录的边界

| 位置                                                  | 放什么                               |
| ----------------------------------------------------- | ------------------------------------ |
| `../lib/`                                             | 与游戏无关的纯 Lua 函数              |
| `shared/`（本目录）                                   | 读实体/组件/`STRINGS` 等可复用小函数 |
| `../features/<name>/`                                 | 某一玩法的流程、注册与状态机         |
| `mod.lua` / `mod/` / `language/` | 全局基础设施，暂不拆进本目录         |

常用：`get_character_announce_line`（`ANNOUNCE_*`；`character_quote` 按语言加引号）、`is_at_min_health` 等。

显示名 / 归属玩家等请用 `mod.Entity` / `mod.Player` / `mod.Prefab`（见 `../mod/`）。

`README.md` 与 `*.test.lua` 仅供仓库使用；打包时会排除，不进工坊包。
