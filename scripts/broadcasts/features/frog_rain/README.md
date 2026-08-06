# features/frog_rain（青蛙雨播报）

玩法功能模块：第一只雨蛙落地时电台开播；结束时分别统计青蛙与明眼青蛙。**永久开启**，无配置项。

## 文件

| 文件            | 职责                                                |
| --------------- | --------------------------------------------------- |
| `init.lua`      | 入口；加载常量与主逻辑                              |
| `constants.lua` | 持久化键、prefab、去重标记 → `BROADCASTS_FROG_RAIN` |
| `frog_rain.lua` | `StartTracking` 计数、条件结算、开始/结束播报       |

## 文案

`scripts/broadcasts/i18n/<语种>.lua`：

| 键                      | 占位符     | 说明                             |
| ----------------------- | ---------- | -------------------------------- |
| `frog_rain_started`     | —          | 开始；字符串或数组（多条随机）   |
| `frog_rain_ended`       | `%d`       | 结束且无明眼蛙；青蛙数           |
| `frog_rain_ended_lunar` | `%d`, `%d` | 结束且有明眼蛙；青蛙、明眼青蛙数 |

## 行为要点

- 仅地表主机；洞穴直接跳过
- **开始**：`frograin:StartTracking` 首次计入 `frog` / `lunarfrog` 时开场并播报（非天气条件）
- **结束**：生成条件不再满足，且 `青蛙 + 明眼青蛙 > 0` 时播报
- **去重**：实体标记 `COUNTED_FLAG`；读档时对 `frograin._frogs` 已在场个体打标
- **读档门闩**：`POPULATING` 或首帧前只打标不计增；`DoTaskInTime(0)` 后再响应结算与计增（同 `features/cave_events`）
- 生成条件与原版 `ToggleUpdate` 一致，仅用于判断何时结算

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
