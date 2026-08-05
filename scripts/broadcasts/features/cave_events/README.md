# features/cave_events（洞穴事件）

噩梦相位、酸雨起止、远古遗迹重置、地震预警。**始终开启**，无配置项。

## 文案

`scripts/broadcasts/i18n/<语种>.lua`：

| 键                  | 说明           |
| ------------------- | -------------- |
| `nightmare_phases`  | 按相位的文案表 |
| `acid_rain_started` | 酸雨开始       |
| `acid_rain_ended`   | 酸雨结束       |
| `ruins_reset`       | 遗迹重置       |
| `quake_warning`     | 地震预警       |

## 行为要点

- 仅洞穴主机
- 读档门闩：`DoTaskInTime(0)` 后再响应 `WatchWorldState`（避免还原状态误播）

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
