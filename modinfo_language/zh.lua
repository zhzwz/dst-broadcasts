return {
    description = [[
纯服务端全服播报工具，客户端无需安装。

- 猎犬、蠕虫、巨鹿与熊獾袭击预警
- 洞穴事件预警与状态播报
- 青蛙雨结束时播报本次青蛙总数
- 物品低耐久、低燃料与损毁播报
- 玩家饱食度或理智降至 10 / 0 时播报
- 玩家生命值降至 20% / 10% 时播报
- 玩家开始过冷或过热时播报
- 每日季节、天气、事件与存活巨兽早报
- 巨兽现身、击败与伤害排行播报
- 聊天发送 pearl / 珍珠查询寄居蟹隐士好感与待办（含洞穴跨分片）
]],
    language_label = "播报语言",
    language_hover = "选择服务器播报使用的语言。",
    item_label = "物品状态播报",
    item_hover = "播报玩家持有物品的低耐久、低燃料与损毁状态。",
    vitals_label = "玩家状态播报",
    vitals_hover = "播报饱食度/理智/生命过低，以及开始过冷或过热。",
    hounded_label = "猎犬与蠕虫预警",
    hounded_hover = "在来袭前的多个时间节点播报。",
    cave_events_label = "洞穴事件播报",
    cave_events_hover = "播报噩梦循环、地震、酸雨与远古遗迹重置。",
    frog_rain_label = "青蛙雨统计",
    frog_rain_hover = "统计每次青蛙雨生成的青蛙，并在结束时播报总数。",
    hassler_label = "巨鹿与熊獾预警",
    hassler_hover = "在来袭前分阶段播报，并在巨兽现身时立即播报。",
    morning_label = "永恒早报",
    morning_hover = "每天开始时播报季节、天气趋势、近期事件与存活巨兽。",
    defeat_label = "巨兽击败播报",
    defeat_hover = "巨兽被击败时播报最终一击，并按实际伤害量播报伤害排行。",
    pearl_label = "寄居蟹隐士查询",
    pearl_hover = "公频聊天发送 pearl 或 珍珠，播报好感与未完成任务；洞穴也可查询。好感提升时每个游戏日最多自动播报一次。",
    debug_label = "调试模式",
    debug_hover = "开启后，Broadcasts 报错会同时出现在游戏播报中。",
    enabled = "启用",
    disabled = "禁用",
}
