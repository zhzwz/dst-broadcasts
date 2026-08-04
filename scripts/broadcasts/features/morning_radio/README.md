# features/morning_radio（早间电台）

每个游戏日**开始**时开播（`cycles` 恰 +1；读档跳变不播）。**始终开启**，无配置项。

## 触发

与日历相同：`WatchWorldState("cycles")`，且 `cycles == previous + 1` 且 `cycles > 0`。

## 节目

`OnAir()` 目前为空，待填早间电台内容。

日历、收获等仍为独立功能；本目录只负责早间电台时段槽。

## 依赖

- `BROADCASTS_SAFE` / `BROADCASTS_DAY_SLOT`

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
