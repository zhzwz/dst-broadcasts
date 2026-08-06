# features/item_status（物品状态）

播报玩家持有物品的低耐久、低燃料与损毁。**永久开启**，无配置项。

## 文件

| 文件                     | 职责                                        |
| ------------------------ | ------------------------------------------- |
| `constants.lua`          | 耐久 / 燃料阈值                             |
| `fueled.lua`             | `fueled` 组件百分比档位                     |
| `last_use_whitelist.lua` | 剩余 1 次提醒的 prefab 白名单               |
| `break.lua`              | `finiteuses` 耗尽、最后 1 次与 `armorbroke` |

## 行为要点

- 仅主机；读档首帧只对齐 flag，不播报
- 各档位下降越过时播一次，回升后可再次触发
- 白名单物品剩余 1 次时播报 `item_last_use`
- 无主时不钉死「已提醒」flag；进入玩家背包（`onputininventory`）时补检一次

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
