# features/appear（巨兽现身）

巨兽实体**新生成**时播报（读档 / 世界填充不播）。**始终开启**，无配置项。

## 文案

`boss_appeared`：`%s已现身！`（`%s` 为 `bosses.*` 名称）

## 行为要点

- 仅主机
- `POPULATING`（世界生成 / 填充）期间出生：直接跳过，避免新档刷屏
- `OnLoad` 标记后跳过，避免读档误报
- **天体英雄**：仅 `alterguardian_phase1` 播报，避免换阶段重复
- **双子魔眼 / 远古守卫塔**：同组先 claim 播一次；全灭后 `onremove` 释放（存活计数对齐 defeat）。若 claim 残留且场上只剩自己，现身时自愈再占位。
- **克劳斯**：包装 `Unchain`，解链后播；**启迪战争瓦器人**：包装 `ConfigureHostile`，进入敌对后播
- 巨鹿 / 熊獾现身由本功能负责；`attack_warning` 的 hassler 仅保留倒计时预警

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
