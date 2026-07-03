# cqone 模块注册架构

## 启动顺序（Main.ts）

**登录前**：`Protos.init()` → `Wins.init()` → `BasicViews.init()` → `RedDots.init()`

**登录后**（`initModules`）：`Modules.datas().init()` → `Modules.ctrls().init()` → `Fns.init()`

## conf 注册文件

| 文件 | 职责 |
|------|------|
| `conf/view/Modules.ts` | `XxxData.I` 注册到 `datas()` |
| `conf/view/Fns.ts` | `FnMo.reg(FnId.XXX, XxxWin)` |
| `conf/data/Protos.ts` | `NetMsgHandler.reg(SC..., Data.I, handler)` |
| `conf/view/Wins.ts` | 非 Fn 弹窗 `WinMo.reg(WinId, Pop)` |
| `conf/data/RedDots.ts` | `RedDotMo.createChildOfFn(FnId.xxx)` |
| `conf/view/BasicViews.ts` | 全局 FGUI `setCustomClass` |

## 目录约定

```
src/script/
  biz/<module>/data/   # XxxData, XxxEvent, XxxConst, XxxMo
  biz/<module>/view/   # XxxWin, XxxPop, XxxLi
  acts/<module>/       # 活动模块，类名通常 Act 前缀
```

## UI 类层次

- 功能窗：`Win`（biz）或 `ActWin`（acts）
- 弹窗：`Win` + `WinShowStrategy.POP`
- 列表项：`UiComp` 子类，后缀 `Li`
- 场景 HUD：`DockView` + `WinShowStrategy.DOCK`

## Win 生命周期（须遵守 code-standards）

```
constructor → setWinMo → [加载资源] → initUi
  → show → onAddedToStage → initData
  → hide → onRemovedFromStage
```

## scaffold 标记位置

脚本在以下标记处插入新模块注册：

```typescript
// @scaffold:modules-import   // Modules.ts import 区
// @scaffold:modules-data     // datas() 数组，RelateFnData.I 之前
// @scaffold:fns-import       // Fns.ts import 区
// @scaffold:fns-reg          // Fns.init() 末尾
```
