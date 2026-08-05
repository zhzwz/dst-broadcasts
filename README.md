# Broadcasts

[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3774915634)

永恒电台，《饥荒联机版》纯服务端模组。

包括但不限于播报以下内容：

- 日历、天气、袭击预警
- 早间 / 黄昏 / 午夜电台时段槽
- 世界事件（青蛙雨、洞穴地震）
- 玩家的状态与物品
- 巨兽现身与击败
- 黄昏收获（大理石灌木、蜂箱、农田、晾晒架；森林/洞穴各自播报）
- WX-78 便携储存单元落地
- 按 `Y` 聊天输入 `pearl` 可查询寄居蟹隐士好感度与任务

## 开发环境

```sh
bun install
# 生成 modinfo.lua
bun run build-modinfo
# 打包发布
bun run release
```

### 关于开发习惯

- 追加表项优先用 `table.insert(t, v)`，少写 `t[#t + 1] = v`
