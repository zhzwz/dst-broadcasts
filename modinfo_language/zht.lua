return {
    description = [[純伺服端全服播報工具，客戶端無需安裝。

- 獵犬、蠕蟲、獨眼巨鹿與熊獾襲擊預警
- 洞穴事件預警與狀態播報
- 青蛙雨結束時播報本次青蛙總數
- 物品低耐久、低燃料與損毀播報
- 玩家飽食度或理智降至 10 / 0 時播報
- 玩家生命值降至 20% / 10% 時播報
- 玩家開始過冷或過熱時播報
- 每日早報：季節天氣、事件、巨獸，及大理石灌木/蜂蜜/農作物/晾曬待收穫
- 巨獸現身、擊敗與傷害排行播報
- 聊天發送 pearl / 珍珠查詢寄居蟹隱士好感與待辦（含洞穴跨分片）
- WX-78 快遞無人機落地時播報名稱與內容物
]],
    language_label = "播報語言",
    language_hover = "選擇伺服器播報使用的語言。",
    item_label = "物品狀態播報",
    item_hover = "播報玩家持有物品的低耐久、低燃料與損毀狀態。",
    vitals_label = "玩家狀態播報",
    vitals_hover = "播報飽食度/理智/生命過低，以及開始過冷或過熱。",
    hounded_label = "獵犬與蠕蟲預警",
    hounded_hover = "在來襲前的多個時間節點播報。",
    cave_events_label = "洞穴事件播報",
    cave_events_hover = "播報噩夢循環、地震、酸雨與遠古遺跡重置。",
    frog_rain_label = "青蛙雨統計",
    frog_rain_hover = "統計每次青蛙雨生成的青蛙，並在結束時播報總數。",
    hassler_label = "獨眼巨鹿與熊獾預警",
    hassler_hover = "在來襲前分階段播報，並在巨獸現身時立即播報。",
    morning_label = "永恆早報",
    morning_hover = "每天開始時播報季節、天氣、事件、存活巨獸，以及成熟大理石灌木、待收蜂蜜、成熟農作物與晾曬待收穫。",
    defeat_label = "巨獸擊敗播報",
    defeat_hover = "巨獸被擊敗時播報最終一擊，並按實際傷害量播報傷害排行。",
    pearl_label = "寄居蟹隱士查詢",
    pearl_hover = "公頻聊天發送 pearl 或 珍珠，播報好感與未完成任務；洞穴也可查詢。好感提升時每個遊戲日最多自動播報一次。",
    drone_label = "快遞無人機播報",
    drone_hover = "WX-78 快遞無人機配送落地時，播報玩家名、無人機名稱與內容物。",
    debug_label = "除錯模式",
    debug_hover = "開啟後，Broadcasts 錯誤會同時出現在遊戲播報中。",
    enabled = "啟用",
    disabled = "停用",
}
