# Broadcasts

[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3774915634)

永恒电台，《饥荒联机版》纯服务端模组。

包括但不限于播报以下内容：

- 日历、天气、袭击预警
- 早间 / 黄昏 / 午夜电台（`scripts/features/radio.lua`；节目文案待对接大模型）
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

- `.lua` 文件注释优先使用单行 `---` 加一个空格，然后写注释内容
- 追加表项优先用 `table.insert(t, v)`，少写 `t[#t + 1] = v`
- 不需要写很多防御代码，在函数外层有 `core.Wrap` 的情况下，出现错误时最多不执行，不会导致游戏崩溃
