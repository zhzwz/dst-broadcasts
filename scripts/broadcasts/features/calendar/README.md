# features/calendar（日历）

每天跨天时播报：永恒日、当前季节第几天、距下一季节还有几天。**永久开启**，无配置项。

`modmain` 始终 `modimport` 本目录 `init.lua`。

## 文案

`scripts/broadcasts/i18n/<语种>.lua`：

| 键                     | 占位符                              | 说明             |
| ---------------------- | ----------------------------------- | ---------------- |
| `calendar_report`      | 日 / 季节 / 季内天 / 下季 / 剩余天数 | `remaining > 0`  |
| `calendar_report_soon` | 日 / 季节 / 季内天 / 下季           | `remaining <= 0` |

示例（简体）：`永恒88日，秋季第8天，距离冬季还有8天。`

天气由独立功能 `features/weather.lua` 播报，不计入日历。

## 行为要点

- 仅主机；读档时 `cycles` 跳变不播（由 `mod.Watch.Cycles` 过滤，仅 `cycles == previous + 1`）
- 季节第几天 = `elapseddaysinseason + 1`
- 距下季 = `remainingdaysinseason`；≤0 时用不含天数的「即将进入」文案
- 与「早间电台」独立：日历只报日期/季节；电台节目见 `features/morning_radio`

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
