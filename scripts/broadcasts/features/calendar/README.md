# features/calendar（日历）

每天跨天时播报：永恒日、当前季节第几天、距下一季节还有几天。

## 配置（默认开启）

| 键                 | 界面名 | 作用     |
| ------------------ | ------ | -------- |
| `calendar_enabled` | 日历   | 开启播报 |

`modmain` 始终 `modimport` 本目录 `init.lua`；开关在 `init` 内判断。

## 文案

`scripts/broadcasts/language/<语种>.lua`：

| 键                     | 占位符                               | 说明             |
| ---------------------- | ------------------------------------ | ---------------- |
| `calendar_report`      | 日 / 季节 / 季内天 / 下季 / 剩余天数 | `remaining > 0`  |
| `calendar_report_soon` | 日 / 季节 / 季内天 / 下季            | `remaining <= 0` |

示例（简体）：`永恒88日，秋季第8天，距离冬季还有8天。` / `……即将进入冬季。`

## 行为要点

- 仅主机；读档时 `cycles` 跳变不播，仅 `cycles == previous + 1` 时播
- 季节第几天 = `elapseddaysinseason + 1`
- 距下季 = `remainingdaysinseason`；≤0 时用不含天数的「即将进入」文案
- 与「永恒早报」独立：早报不再含日期段

## 依赖

- `BROADCASTS_SAFE` / `BROADCASTS_STRINGS` / `BROADCASTS_CONSTANTS.NEXT_SEASON`

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
