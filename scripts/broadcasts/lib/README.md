# broadcasts/lib

与游戏无关的 **Lua 纯函数** 存放处。

## 约定

- **单文件单函数**：文件名用 snake_case，与导出符号对应。
- **纯函数**：不访问 `TheWorld`、组件、`GetModConfigData`、网络等 DST / 模组环境。
- **不必多处复用**：只要是纯逻辑，即可放这里，便于单测与阅读。
- **随用随引**：功能模块在需要时 `modimport("scripts/broadcasts/lib/<name>.lua")`，不要在 `modmain` 里一次性全量加载。
- **导出命名**：`BROADCASTS_<NAME>`，全大写蛇形，与文件名一致（例如 `cross_real_thresholds.lua` → `BROADCASTS_CROSS_REAL_THRESHOLDS`）。
- **注释**：说明用途、参数、返回值，以及是否就地修改入参。
- **单测**：与源文件同目录，`xxx.lua` 对应 `xxx.test.lua`；`bun run test` 会跑 `scripts/**/*.test.lua`。

依赖 DST API 或模组环境的可复用代码，请放 `../shared/` 或 `../features/<name>/`，不要放进本目录。

`README.md` 与 `*.test.lua` 仅供仓库使用；打包时会统一排除，不进工坊包。
