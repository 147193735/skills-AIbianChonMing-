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
| `conf/view/BasicViews.ts` | 全局 FGUI `setCustomClass`（`Btn_a_r`/`CostCom`/`ItemCell`/`RelateFnBtn` 等） |

**注意**：Win/Pop 构造函数 **不要** 再对 BasicViews 已注册的公共组件 `setCustomClass`；只注册本包业务组件。详见 code-standards「setCustomClass 与 BasicViews」。

## 目录约定

```
src/script/
  biz/<module>/data/   # XxxData, XxxEvent, XxxConst, XxxMo
  biz/<module>/view/   # XxxWin, XxxPop, XxxLi
  biz/act/             # 活动公共壳：ActData / ActMo / ActFn / ActWin / CommonAct*
  acts/<module>/       # 活动玩法模块，类名通常 Act 前缀
```

**新建 acts**：先按 [acts-module](../acts-module/SKILL.md) 完成玩法与 Data 基类选型（默认优先 `CommonAct*X`），再 scaffold；壳层用 `ActWin`，玩法数据在 `acts/xxx`。

## UI 类层次

- 功能窗：`Win`（biz）或 `ActWin`（acts）
- 弹窗：`Win` + `WinShowStrategy.POP`
- 列表项：`UiComp` 子类，后缀 `Li`
- 场景 HUD：`DockView` + `WinShowStrategy.DOCK`

## 活动壳 vs 玩法（摘要）

| 层 | 位置 | 职责 |
|----|------|------|
| 壳 | `biz/act` | 开闭、展示期、倒计时、通用领奖/奖励展示、`ActWin` |
| 玩法 | `acts/<module>` | 协议、配置组、红点细则、界面编排 |

Data 模板选型与检查清单见 [acts-module](../acts-module/SKILL.md)（勿与「玩法都一样」混淆：共通的是壳与配置行范式）。

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
