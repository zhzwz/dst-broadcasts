return {
    description = [[
Server-side broadcast utility. No client installation required.

- Hound, worm, Deerclops, and Bearger warnings
- Cave event warnings and status announcements
- Frog rain totals when each shower ends
- Low durability, low fuel, and item break alerts
- Hunger and sanity alerts at 10 and 0
- Health alerts at 20% and 10%
- Freezing and overheating alerts
- Daily report: season, weather, events, bosses, plus marble shrubs / honey / crops / drying racks
- Boss appearance, defeat, and damage ranking announcements
- Chat pearl / 珍珠 for Pearl friendship and unfinished tasks (cross-shard)
- Announce WX-78 delivery drone name and cargo on landing
]],
    language_label = "Broadcast language",
    language_hover = "Select the language used for server announcements.",
    item_label = "Item status alerts",
    item_hover = "Announce low durability, low fuel, and broken items held by players.",
    vitals_label = "Player status alerts",
    vitals_hover = "Announce low hunger/sanity/health, and when a player starts freezing or overheating.",
    hounded_label = "Hound and worm warnings",
    hounded_hover = "Warn at multiple intervals before an attack.",
    cave_events_label = "Cave event alerts",
    cave_events_hover = "Announce nightmare cycles, earthquakes, acid rain, and Ruins resets.",
    frog_rain_label = "Frog rain reports",
    frog_rain_hover = "Count frogs spawned by each frog rain and report the total when it ends.",
    hassler_label = "Deerclops and Bearger warnings",
    hassler_hover = "Warn before an attack and announce when the boss appears.",
    morning_label = "The Constant Daily",
    morning_hover = "Each morning: season, weather, events, living bosses, plus mature marble shrubs, harvestable honey, mature crops, and finished drying-rack goods.",
    defeat_label = "Boss defeat announcements",
    defeat_hover = "Announce boss defeats, the finishing blow, and a damage ranking by actual HP dealt.",
    pearl_label = "Pearl status",
    pearl_hover = "Say pearl or 珍珠 in chat to announce friendship and unfinished tasks (works from caves). Auto-announces at most once per game day on friendship gain.",
    drone_label = "Delivery drone alerts",
    drone_hover = "Announce the player, drone name, and cargo when a WX-78 delivery drone lands.",
    debug_label = "Debug logging",
    debug_hover = "When enabled, Broadcasts errors are also announced in-game.",
    enabled = "Enabled",
    disabled = "Disabled",
}
