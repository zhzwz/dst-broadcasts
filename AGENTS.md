# AGENTS

> 注：
> 若有关此项目的信息有必要让以后运行的 Agent 知晓，请随时修改此文件。
> 此文件的内容务必简洁精炼。

## 开发规范

- 游戏官方脚本位于：`~/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/data/databundles/scripts.zip`，在编写模组代码时，可以读取官方的脚本信息。

- 编写函数注释时，函数顶部的说明只一行，其他详细的说明可以写在函数内部执行的各处。

- `core.Wrap` 内部已经有一层 `Call`，不要使用 `core.Call` 重复再包一层。

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
