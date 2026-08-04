# features/portable_storage（便携储存单元）

WX-78 便携储存单元配送落地时播报发货玩家、单元名称与内容物。

## 配置（默认开启）

| 键                         | 界面名（zh） | 作用         |
| -------------------------- | ------------ | ------------ |
| `portable_storage_enabled` | 便携储存单元 | 落地成功播报 |

`modmain` 始终 `modimport` 本目录 `init.lua`；关闭时直接返回。

## 文案

| 键                        | 说明                                    |
| ------------------------- | --------------------------------------- |
| `portable_storage_landed` | `%s` = 玩家名+单元名，`%s` = 内容物汇总 |

## 行为要点

- 仅主机；监听 prefab `wx78_drone_delivery` / `wx78_drone_delivery_small`（游戏内名 Portable Storage Unit）
- 配送进度完成后再等 `on_landed`，避免未送达误报
- 内容物为空时不播报
- 内容物汇总复用 `lib/harvest_announce` 的 `名称×数量` 格式

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
