# AGENTS

> 注：
> 若有关此项目的信息有必要让以后运行的 Agent 知晓，请随时修改此文件。
> 此文件的内容务必简洁精炼。

## 开发规范

- 游戏官方脚本位于：`~/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/data/databundles/scripts.zip`，在编写模组代码时，可以读取官方的脚本信息。

- `dst.d.lua` 仅为对照官方 API 的 LuaLS 类型桩：内容以官方脚本为准，禁止为迁就本模组而改动。

- 写函数注释时，函数顶部的说明有且仅有一行，参数说明一行一个，其他更细的说明可以写在函数内部执行的各处。

- `core.Wrap` 已内置 `core.Call`，若非必要，不要 `core.Call` 再包一层。

- 如果需要记录某个变量，稍后用于与更新的值对比，应该使用 `_previous` 后缀，并且在相应的逻辑执行完之后，执行记录。示例：

```lua
local value_previous = nil
if (value ~= value_previous) then
  --- ...
end
value_previous = value
```

- 尽量不用单词缩写。

## 默认翻译

- moonstorm 月亮风暴
- sandstorm 沙尘暴
