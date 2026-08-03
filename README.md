# Broadcasts

[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3774915634)

永恒电台，《饥荒联机版》纯服务端模组。

包括但不限于播报以下内容：

- 季节、天气、袭击预警
- 世界事件（青蛙雨、洞穴地震）
- 玩家的状态与物品
- 巨兽的状态与击杀
- 大理石灌木、蜂蜜、农作物、晾晒架等待收获信息
- WX-78 快递无人机落地
- 按 `Y` 聊天输入 `pearl` 可查询寄居蟹隐士好感度与任务

## 开发环境

```sh
bun install
# 会生成 modinfo.lua
bun run build-modinfo
# 打包发布
bun run release
```
