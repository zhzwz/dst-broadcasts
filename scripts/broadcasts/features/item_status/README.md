# features/item_status（物品状态）

播报玩家持有物品的低耐久、低燃料与损毁。

## 配置（默认均开启）

| 键                           | 界面名（zh） | 作用                          |
| ---------------------------- | ------------ | ----------------------------- |
| `item_durability_enabled`    | 物品耐久     | 可缝补物品（USAGE）低耐久档位 |
| `item_fuel_enabled`          | 物品燃料     | 可补燃料物品低燃料档位        |
| `item_break_enabled`         | 物品损毁     | 武器 / 护甲损毁               |
| `item_break_warning_enabled` | 物品损毁预警 | 白名单物品剩余 1 次使用时提醒 |

`modmain` 始终 `modimport` 本目录 `init.lua`；全部关闭时直接返回。

## 文件

| 文件                     | 职责                                        |
| ------------------------ | ------------------------------------------- |
| `constants.lua`          | 耐久 / 燃料阈值                             |
| `fueled.lua`             | `fueled` 组件百分比档位（按开关分流）       |
| `last_use_whitelist.lua` | 剩余 1 次提醒的 prefab 白名单               |
| `break.lua`              | `finiteuses` 耗尽、最后 1 次与 `armorbroke` |

## 行为要点

- 仅主机；读档首帧只对齐 flag，不播报
- 各档位下降越过时播一次，回升后可再次触发
- `item_break_warning_enabled`：白名单物品剩余 1 次时播报 `item_last_use`（可与损毁分开关）
- 无主时不钉死「已提醒」flag；进入玩家背包（`onputininventory`）时补检一次

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
