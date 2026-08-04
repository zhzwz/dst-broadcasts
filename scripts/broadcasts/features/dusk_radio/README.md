# features/dusk_radio（黄昏电台）

**白天 → 黄昏**时开播。**始终开启**，无配置项。

## 触发

- 森林：`phase` day → dusk
- 洞穴：`cavephase` day → dusk
- 读档停在黄昏、或相位尚未就绪时不播

## 节目

`OnAir()` 目前为空，待填黄昏电台内容。

收获播报仍为独立功能（同相位触发）；本目录只负责黄昏电台时段槽。

## 依赖

- `BROADCASTS_SAFE` / `BROADCASTS_DAY_SLOT`

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
