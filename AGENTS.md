# AGENTS

> 注：
> 若有关此项目的信息有必要让以后运行的 Agent 知晓，请随时修改此文件。
> 此文件的内容务必简洁精炼。

## 开发资源

- 游戏官方脚本位于：`~/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/data/databundles/scripts.zip`，在编写模组代码时，可读取官方的脚本内容作为参考项。

## 开发规范

- 在任何时候，游戏都不能因为模组代码崩溃。
- 写注释时，函数简要说明有且仅有一行，存在参数时每行一个参数说明，其他内容可在函数内部各处注释。
- 尽量不使用单词缩写。

- `dst.d.lua` 仅为对照官方 API 的 LuaLS 类型桩：内容以官方脚本为准，禁止为迁就模组而改动。

- `scripts/dst/` 只放对游戏 API 的通用封装，须与本模组业务无关，其他模组亦可直接复用。

- `core.Wrap` 已内置 `core.Call`，若非必要，不要 `core.Call` 再包一层。

- 若记录变量与新值做对比，优先使用 `_previous` 后缀，在对比逻辑执行后再记录新值。示例：

```lua
local value_previous = nil
if (value ~= value_previous) then
  --- ...
end
value_previous = value
```

## 默认翻译

- moonstorm 月亮风暴
- sandstorm 沙尘暴
