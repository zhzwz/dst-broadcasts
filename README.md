# Broadcasts

《饥荒联机版》纯服务端事件播报模组。

- 永恒早报：季节天气、近期事件、存活巨兽，以及大理石灌木 / 蜂蜜 / 农作物 / 晾晒待收获
- 袭击预警、洞穴事件、青蛙雨统计
- 物品与玩家状态、巨兽现身与击败排行
- 聊天 `pearl` 查询寄居蟹隐士
- WX-78 快递无人机配送落地播报

订阅与详细说明：[Steam 创意工坊](https://steamcommunity.com/sharedfiles/filedetails/?id=3774915634)

## 模组信息

源文件在 `modinfo/`，打包或本地测试会生成根目录 `modinfo.lua`（gitignore）：

- `modinfo/base.lua`：元数据与配置项
- `modinfo/language/*.lua`：配置页 / 描述多语言
- `bun run build-modinfo`：生成；`pack` / `release` 会自动跑
