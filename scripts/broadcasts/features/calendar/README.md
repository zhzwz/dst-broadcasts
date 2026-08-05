# features/calendar（日历）

每天跨天时播报：永恒日、当前天气一词、当前季节第几天、距下一季节还有几天。

## 配置（默认开启）

| 键                 | 界面名 | 作用     |
| ------------------ | ------ | -------- |
| `calendar_enabled` | 日历   | 开启播报 |

`modmain` 始终 `modimport` 本目录 `init.lua`；开关在 `init` 内判断。

## 文案

`scripts/broadcasts/i18n/<语种>.lua`：

| 键                     | 占位符                                     | 说明             |
| ---------------------- | ------------------------------------------ | ---------------- |
| `calendar_weather`     | 天气键 → 一词标签                          | 见下             |
| `calendar_report`      | 日 / 天气 / 季节 / 季内天 / 下季 / 剩余天数 | `remaining > 0`  |
| `calendar_report_soon` | 日 / 天气 / 季节 / 季内天 / 下季            | `remaining <= 0` |

示例（简体）：`永恒88日，晴，秋季第8天，距离冬季还有8天。`

天气一词由 `lib/current_weather` 分类，优先级大致为：酸雨 / 月雹 / 雪 / 大雨 / 雨 / 风暴（沙尘暴） / 月风暴 / 晴。大雨阈值对齐原版 `TUNING.FROG_RAIN_PRECIPITATION`。青蛙雨由独立功能播报，不计入日历天气。

## 行为要点

- 仅主机；读档时 `cycles` 跳变不播，仅 `cycles == previous + 1` 时播
- 季节第几天 = `elapseddaysinseason + 1`
- 距下季 = `remainingdaysinseason`；≤0 时用不含天数的「即将进入」文案
- 与「早间电台」独立：日历仍只报日期/天气/季节；电台节目见 `features/morning_radio`

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
