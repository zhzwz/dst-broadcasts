# features/player_vitals（玩家状态）

玩家饱食、理智、生命、温度、湿度播报。

## 配置（默认均开启）

| 键                           | 作用                             |
| ---------------------------- | -------------------------------- |
| `player_hunger_enabled`      | 饱食度过低（≤10 / ≤0）           |
| `player_sanity_enabled`      | 理智过低（百分比 50% / 10%）     |
| `player_health_enabled`      | 生命过低（≤10% 时播报当前/上限） |
| `player_temperature_enabled` | 真正过冷 / 过热时播报            |
| `player_moisture_enabled`    | 湿度 10/20/40/60/80 分档         |

`modmain` 始终 `modimport` 本目录 `init.lua`；全部关闭时直接返回。

## 饱食档位

| 当前值 | 文案                | 角色内置台词      |
| ------ | ------------------- | ----------------- |
| ≤ 10   | `player_hunger[10]` | `ANNOUNCE_HUNGRY` |
| ≤ 0    | `player_hunger[0]`  | `ANNOUNCE_HUNGRY` |

每档各播一次；回升越过该档后可再次触发。每档为字符串数组，随机一条（`%s` = 玩家名）后拼接角色台词。

## 理智档位

| 百分比 | 文案键                 | 游戏含义（约）        |
| ------ | ---------------------- | --------------------- |
| ≤ 50%  | `player_low_sanity_50` | 可能出现 1 只暗影生物 |
| ≤ 10%  | `player_low_sanity_10` | 可能出现 2 只暗影生物 |

每档各播一次；回升越过该档后可再次触发。每键为字符串数组，播报时随机取一条（`%s` = 玩家名）。

## 生命

| 百分比 | 文案                | 说明                                               |
| ------ | ------------------- | -------------------------------------------------- |
| ≤ 10%  | `player_low_health` | 固定一句；播报玩家名、当前生命、上限（不含百分比） |

仅在生命**下降**时播报；回升越过 10% 后可再次触发。进服只对齐 flag。

## 湿度档位

| 湿度 | 文案                  | 角色内置台词      |
| ---- | --------------------- | ----------------- |
| ≥ 10 | `player_moisture[10]` | `ANNOUNCE_DAMP`   |
| ≥ 20 | `player_moisture[20]` | `ANNOUNCE_DAMP`   |
| ≥ 40 | `player_moisture[40]` | `ANNOUNCE_WET`    |
| ≥ 60 | `player_moisture[60]` | `ANNOUNCE_WETTER` |
| ≥ 80 | `player_moisture[80]` | `ANNOUNCE_SOAKED` |

每档各播一次；变干低于该档后可再次触发。播报 = 模组短句 + 角色台词。

## 温度

与游戏伤害判定一致：过冷 `current < 0`、过热 `current > overheattemp`（默认 70°；优先读角色 `overheattemp` / `TUNING.OVERHEAT_TEMP`）。
进入过冷 / 过热时各播一次；离开后可再次触发。
若 `mintemp` / `maxtemp` 已使角色无法真正受伤（如 WX-78 加热 / 制冷电路），则跳过对应播报。
文案在 `player_temperature.cold` / `player_temperature.hot`（字符串或字符串数组，多条时随机；`%s` = 玩家名），
播报后拼接角色内置 `ANNOUNCE_COLD` / `ANNOUNCE_HOT`。

## 文件

| 文件                                       | 职责                              |
| ------------------------------------------ | --------------------------------- |
| `init.lua`                                 | 入口与按配置加载                  |
| `constants.lua`                            | 阈值 → `BROADCASTS_PLAYER_VITALS` |
| `hunger.lua` / `sanity.lua` / `health.lua` | 各分项监听                        |
| `temperature.lua`                          | 过冷 / 过热播报                   |
| `moisture.lua`                             | 湿度分档                          |

## 依赖

- `../../lib/pick_message.lua`
- `../../shared/get_player_display_name.lua`
- `../../shared/get_character_announce_line.lua`
- `BROADCASTS_SAFE` / `BROADCASTS_STRINGS`

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
