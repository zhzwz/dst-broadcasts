# features/pearl（寄居蟹隐士）

查询并播报 Pearl 好感与未完成任务。**永久开启**，无配置开关。

## 触发

- 公频聊天精确发送 `pearl`（洞穴可跨分片查地表）
- 好感等级提升时自动播报（每个游戏日最多一次）

## 文件

| 文件            | 职责                                      |
| --------------- | ----------------------------------------- |
| `constants.lua` | 冷却与跨片超时 → `BROADCASTS_PEARL`       |
| `tasks.lua`     | 任务 id/文案键 → `BROADCASTS_PEARL_TASKS` |
| `pearl.lua`     | 聊天钩子、好感监听、跨片 RPC              |

## 文案

| 键                    | 说明              |
| --------------------- | ----------------- |
| `pearl_name`          | 显示名            |
| `pearl_status`        | 好感 `%s` `%d/%d` |
| `pearl_tasks_pending` | 待办列表前缀      |
| `pearl_tasks_done`    | 无待办            |
| `pearl_not_found`     | 未找到            |
| `pearl_tasks.*`       | 各任务名          |

`README.md` 仅供仓库阅读；打包时会排除，不进工坊包。
