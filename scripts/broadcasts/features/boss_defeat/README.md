# features/boss_defeat（巨兽击败）

巨兽被击败时播报最终一击与伤害排行。**始终开启**，无配置项。

## 文案

`scripts/broadcasts/language/<语种>.lua`：

| 键                         | 说明                         |
| -------------------------- | ---------------------------- |
| `boss_defeated`            | 无击杀者                     |
| `boss_defeated_by`         | 有击杀者                     |
| `boss_defeated_by_weapon`  | 有击杀者与武器               |
| `boss_damage_ranking` 等   | 伤害排行相关                 |
| `bosses.*`                 | 巨兽显示名                   |

## 行为要点

- 仅主机
- 普通死亡 / 非致死贴底（如蚁狮、鲨鱼人等）均可能结算
- **双子魔眼 / 远古守卫塔**：整组清场后播一次
- 伤害按实际扣血累计，排行上限见 `mod.CONSTANTS.BOSS_DAMAGE_RANKING_MAX`

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
