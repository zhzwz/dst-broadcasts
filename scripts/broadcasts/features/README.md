# broadcasts/features

玩法功能模块。每个子目录是一个独立的功能（入口一般为 `init.lua`）。

## 约定

- 路径：`scripts/broadcasts/features/<feature_name>/`
- 由 `modmain` `modimport(".../features/<name>/init.lua")`
- 功能私有逻辑留在本目录
