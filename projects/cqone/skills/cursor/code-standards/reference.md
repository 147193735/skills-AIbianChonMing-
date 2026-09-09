# cqone 代码规范 — 详细参考

来源快照：[upstream/代码规范.md](upstream/代码规范.md)（格式化见 [upstream/代码规范-idea设置.md](upstream/代码规范-idea设置.md)）。  
本文件为 Agent 增量约定与常用摘要；与 upstream 冲突时以 **upstream + 本 skill 明确增量** 为准，**不以** `C:/myPro/doc` 为准。

---

## 命名原则

- 全项目对同一事物用词统一（dungeon 不用 copy/fuben；rahi 不用 pet）
- 含义清楚前提下尽量短；不发明缩写
- 避免与语言/引擎关键字重名

### 约定简写

| 简写 | 全称 |
|------|------|
| i | index |
| cur / prev / next | current / previous / next |
| w / h | width / height |
| img / btn / txt / win | image / button / text / window |
| len / num / arr / str | length / number / array / string |
| fn | function |
| src / dst | source / destination |

---

## 类注释

```typescript
/**
 * 类说明
 * @author zhangyongkang
 * @since yyyy-MM-dd
 */
```

**`@author` 硬性规则**：固定写 `zhangyongkang`。不要参考同目录/同模块已有文件的 `@author`，也不要用类名、文件名或 git 用户名替代。

## 注释（方法 / 成员）

**精简优先**：默认单行 `/** 说明 */`；本类方法（含 private）都加；**父类覆盖方法不加**；**`v*` FGUI 元素默认不加**（仅人手写时保留，勿自动补）。

**时机**：不限于「刚建模块」。脚手架首版要写；之后在同一模块里**新加**的方法 / 字段 / getter 也要写。改旧文件时只给本次新增或改到的签名补注释，勿全文件补旧债。

### 禁止对话提示型注释

实现注意点、FGUI 坑、协作提醒 → **只写在对话**，不写进源码。已有则等「检查代码」删除（见 code-check）。

```typescript
// ❌ 禁止
/** FGUI 为 image，需手动 touchable */
vRuleBtn: GObject;
// 注意：基类也会绑 vClose，此处保证 touchable
this.vClose.touchable = true;

// ✅ 允许：职责语义 / 非显而易见业务原因
/** 抽奖动画会话号 */
private drawAnimToken: number = 0;
// 同 url 已播则跳过
```

```typescript
/** 变量说明 */
private goods: ShopGoodsMo[];

vRule: GButton;           // FGUI 元素 — 不加注释
vDrawOne: XiangongTreasureCom;

/** 今日剩余次数 */
get remainDrawTimes(): number { ... }

/** 领取达标奖励；cfgId=0 为一键领取 */
reqGainGoalReward(cfgId: number): void { ... }

/** 更新抽奖红点 */
private updateDrawRedDot(): void { ... }
```

`@param` / `@return` 仅规则复杂时使用；简单入参写进说明句（如上 `cfgId=0`），勿堆多行 JSDoc。

**不加注释的父类覆盖示例**：`ModuleData.init` / `onLogout`；`Win`/`UiComp` 的 `initUi` / `onAddedToStage` / `onRemovedFromStage` / `initData` / `onClose`；`ShowRuleBase.updateView` / `onPlayCompleted` 等。

## 语句块

```typescript
// 非显而易见的业务原因（禁止「注意/记得/需手动」类对话提示）
```

---

## 类成员书写顺序

1. 静态成员变量
2. 静态 get/初始化方法
3. 分区行 `//* ************************************************************************`
4. 实例成员变量
5. 分区行
6. 构造方法
7. 普通成员方法

**改已有文件时**：以该文件原有方法顺序为准，不要按上表或个人习惯重排既有成员。例如原文件是 `initUi` → `onAddedToStage` → `setWinMo`，扩展时继续保持该顺序，只改/加需要的内容，勿把 `setWinMo` 挪到 `initUi` 前面。

---

## 新建模块 Data/View 排版

**仅约束「成员书写顺序 / 分区」用于新建或脚手架生成**；改旧文件勿为排版整文件挪方法（除非用户明确要求重排）。  
**注释不在此限**：排版「仅新建」≠ 注释「仅新建」——后续往模块里加方法 / 字段仍须按上文「注释」写 `/** */`。

**分区行**：默认区与区之间空行即可；方法多或跨职责时再加：

```typescript
//* ************************************************************************
//* 分区说明
//* ************************************************************************
```

### Data（`XxxData`）

| 顺序 | 分区 | 内容 |
|------|------|------|
| 1 | 静态 | `static readonly I` |
| 2 | 字段 | 全部 `/** */`；private 缓存 → public 状态；**不放** getter |
| 3 | 父类/生命周期 | `init` → `onLogout`（…）；覆盖方法不加注释 |
| 4 | 协议收包 | `onSC…` |
| 5 | 协议发包 | `req…` |
| 6 | 自定义对外接口 | `get*` / `is*` / **getter** / `open*` / `set*` / `cancel*` 等 |
| 7 | 私有实现 | `do*` / `send*` / `refresh*` 等内部逻辑 |
| 8 | 红点 | `update*RedDot`、触发红点的监听回调等 |

```typescript
export default class XxxData extends ModuleData {
    static readonly I = new XxxData();

    /** 奖池缓存 */
    private rewardCos: XxxCo[] = [];
    /** 今日已抽次数 */
    useTimes: number = 0;

    init(): void { ... }
    onLogout(isReconnect: boolean): void { ... }

    /** 同步面板 */
    onSCXxxInfo(po: SCXxxInfoPo): void { ... }

    /** 请求抽奖 */
    reqDraw(idx: number): void { ... }

    /** 今日剩余次数 */
    get remainDrawTimes(): number { ... }
    /** 大奖预览 */
    getBigShowCos(): XxxCo[] { ... }

    /** 抽奖内部实现 */
    private doDraw(cnt: number): void { ... }

    /** 更新抽奖红点 */
    private updateDrawRedDot(): void { ... }
}
```

### View（`Win` / `Pop` / `UiComp`）

| 顺序 | 分区 | 内容 |
|------|------|------|
| 1 | 字段 | `v*`（不加注释）→ 其它业务成员（加注释） |
| 2 | 构造 | `constructor`；有 `setWinMo` 则紧随其后 |
| 3 | 父类生命周期 | `initUi` → `onAddedToStage` → `onRemovedFromStage` → [`onClose`] → `initData` |
| 4 | 刷新 | `refresh*` |
| 5 | 自定义交互/业务 | `on*` / `play*` / `render*` 等 |
| 6 | 其它 | 私有辅助 |

```typescript
export default class XxxWin extends Win {
    vRule: GButton;
    vCount: GTextField;
    /** 列表数据 */
    moArr: XxxMo[];

    constructor() {
        super("Xxx", "XxxWin");
    }

    initUi(): void { ... }
    onAddedToStage(): void { ... }
    onRemovedFromStage(): void { ... }
    initData(): void { ... }

    /** 全量刷新 */
    private refreshAll(): void { ... }
    /** 刷新次数 */
    private refreshCount(): void { ... }

    /** 打开玩法说明 */
    private onRule(): void { ... }
}
```

---

## 职责边界（自己的事自己做）

封装实践：对象自己的状态与副作用由自己管理；父级只编排、只调公开接口。

| 角色 | 该做 | 不该做 |
|------|------|--------|
| `Item` / `Com` / 子组件 | 本对象 Tween（`clearAll` / `coverBefore`）、Mv `clear`；`onRemovedFromStage` 还原自身 | 指望 Win 代清本对象缓动 |
| `Win` / `Pop` | 流程（何时 fly / 播特效 / 发协议）；token 丢弃过期回调 | `Tween.clearAll(子节点)`、替子组件记 origin |
| `Data` | 协议与数据；动画结束由 View 回调再发包 | 用固定 Timer 代替真动画时长 |

反例：关界面后格子位置错乱——父级 `setXY` 但子组件缓动未停，或完成回调在中断后仍跑。  
正例：`XiangongTreasureRewardItem.resetFly` / `onRemovedFromStage` 自清；Win 只调 `flyTo`/`hideAfterFly`/`resetFly`。

---

## 界面类生命周期（详）

```
创建 → constructor → setWinMo → 加载资源 → initUi
show（首次）→ onAddedToStage → initData
show（再次，未关闭）→ initData only
hide → onRemovedFromStage
```

- `constructor` / `initUi` 只执行一次
- `initData` 每次 show 都执行
- `onAddedToStage` 仅在首次加到舞台时执行

### refresh 粒度

- 数据少或同时变化：一个 `refreshData`
- 数据多、变化频率不同：多个 `refreshXxx`

---

## Data 层协议

| 方向 | 命名 |
|------|------|
| 收包 | `onSCSynPosition`（on + 协议类名去 Po） |
| 发包 | `reqEnterScene`（req 开头，语义清晰即可） |

注册：`Protos.ts` 中 `NetMsgHandler.reg(...)`。

---

## Data 变更事件（EventDispatcher）

`ModuleData`、`*Fo`（如 `GrowSysFo`）继承 `EventDispatcher`。

### 默认原则（优先遵守）

简单功能（数据变了 → 界面整页/整块刷新）**不要新建 `XxxEvent`**：

| 做法 | 说明 |
|------|------|
| ✅ `this.eventChangeLater()` | Data 侧派发，延迟 + 去重 → `EventType.change` |
| ✅ 视图 `listenMgr.on(XxxData.I, EventType.change, …)` | 跨模块同样听 `EventType.change` |
| ❌ 仅为全量刷新新建 `XxxEvent.DATA_CHANGE` 等 | 无额外语义，多余一层转发 |
| ❌ 自造带参 `NOTIFY_*` | 对齐商店规范，见下 |

仅在以下情况才加自定义事件：需要区分刷新粒度、必须带参、或与红点等通道分离（性能优化）等。

### 派发

```typescript
// 状态变更后（延迟 + 去重）
this.eventChangeLater();  // → EventType.change
```

参考：`GrowSysFo.onDataChange`、`ActShopData.reqSetCheck`、`DailyCalendarData`。

### 监听

```typescript
// 模块单例 — 养成、活动商店、活动周历等
GrowData.I.on(EventType.change, this, this.updateAllShop);
this.listenMgr.on(ActShopData.I, EventType.change, this, this.refreshActContentData);
this.listenMgr.on(DailyCalendarData.I, EventType.change, this, this.refresh);
```

视图刷新时**从 Mo 读状态**，不依赖事件参数。

### 养成等级（buyLimit 类型 6、`EnableConditionTypeId.GROW_PAGE_LV`）

| 做法 | 说明 |
|------|------|
| ✅ `GrowData.I` + `EventType.change` | 覆盖登录、推送、升级等所有 `onDataChange` 路径 |
| ❌ `for (fo of GrowSysFo.instances) fo.on(GrowSysEvent.upOk)` | UI 事件；仅升级成功；时序在 `updateMyData` 前 |

先例：`HangUpData`、`BagData`、`DungeonData`、`AlienBossFirstKillData`。

### 商店勾选提醒

对齐 `ActShopData` + `ActTreasureTroveShopWin`：`eventChangeLater` + `EventType.change`。  
勿用 `ShopEvent.NOTIFY_SINGLE_CHANGE` / `NOTIFY_ALL_CHANGE` 等带参自定义事件。

---

## 红点（硬性：一律 RedDotTask）

**以后所有 Data 层红点刷新必须走 `RedDotTask` / `RedDotTaskList`**，禁止用 `Timer.frameOnce` / `Timer.once` 做 Data 红点延迟。

`eventChangeLater` + 背包/养成等监听会让刷新变频繁；**红点重算成本高于 `RedDotMo.setVisible` 短路**（值未变仍会先算一遍）。`RedDotTask` 靠队列去重，同一帧多次触发只算一次。

### 标准写法（对齐 `XiangongTreasureData` / `PillData`）

```typescript
private readonly drawRedDotTask = new RedDotTask("XiangongTreasureDraw", () => this.updateDrawRedDot());
private readonly goalRedDotTask = new RedDotTask("XiangongTreasureGoal", () => this.updateGoalRedDot());

init(): void {
    // 读表、建 Mo、注册监听 —— 不要在此 updateRedDotsLater（init 早于功能协议推送）
    BagData.I.on(BagEvent.ALL_ITEM_UPDATE, this, this.updateDrawRedDotsLater);
}

onSCXxxInfo(po: ...): void {
    // ... 更新后端态
    this.eventChangeLater();   // 界面
    this.updateRedDotsLater(); // 红点（数据就绪后再算）
}

/** 背包变化：只刷抽奖红点 */
private updateDrawRedDotsLater(): void {
    this.drawRedDotTask.runLater();
}

/** 协议/全量：刷抽奖 + 达标 */
private updateRedDotsLater(): void {
    this.drawRedDotTask.runLater();
    this.goalRedDotTask.runLater();
}
```

### init 与协议时序（勿在 init 刷后端态红点）

```
onPreloadBaseOk → modulesInitFn → 各 ModuleData.init()   // 仅本地配置/监听
…登录角色…
tryStartGame → resumeReceive → 功能 SC 推送 / afterLoginReqs
onSC… → updateRedDotsLater()                             // 此处才算红点
```

`init` 时后端次数/已领状态/背包等多为默认值；立刻算红点无意义，且可能误亮（如免费次数默认 `useTimes===0`）。

### 典型性能陷阱（`ShopMo.updateRedDot`）

```typescript
// 每条商品 isBuyRedDot：canShow + passBuyLimit + isItemEnough
const hasBuyRedDot = this.goods.some(good => good.isBuyRedDot);
```

`BagEvent.ALL_ITEM_UPDATE` → `updateAllRedDot` → 多商店 × 全量 goods × 重 getter。

### 规范

1. **必须**：`RedDotTask` / `RedDotTaskList`（`src/script/biz/fn/data/RedDotTask.ts`）
2. **禁止**：Data 内 `Timer.frameOnce(5, this, this.updateXxxRedDot)` 等
3. **禁止**：`init()` 内立刻调用依赖后端态的 `updateRedDotsLater`（等 `onSC…` / 背包等就绪）
4. **双通道**：`eventChangeLater()` 给界面；`task.runLater()` 给红点
5. **分任务**：变更源只触发受影响的红点任务
6. **少算**：Mo 缓存红点状态；聚合用 `shownGoods` / `dict.values`；单条变更只刷新受影响商店/Fn
7. **getter 轻量化**：`isXxxRedDot` 避免条件链+背包查询，或仅读缓存

### RedDots.ts：`createChildOfFn` / `addChild`（防页签串红点）

`RedDotMo.addChild` 会让**子亮则父亮**。挂错层级 = 兄弟页签红点互相污染。

**注册前先判定：**

1. GOAL / 子页是**同一功能下的逻辑子红点**，还是**独立 Fn 的页签**？
2. 入口汇总是否已有 Function 父子（如 `ENTRY=…00`，子页 `…01/…02`）？有则**不要**再把兄弟页签互相 `addChild`。

| 场景 | 写法 |
|------|------|
| 同 Fn 多子红点（仙宫抽奖+达标） | `DRAW/GOAL = createChildOfFn(同一 TREASURE Fn)` |
| 兄弟页签独立 Fn（至尊主玩法+累抽） | `DRAW = createChildOfFn(主Fn)`；`GOAL = createChildOfFn(累抽Fn)`；**不要** `getByFn(主).addChild(getByFn(累抽))` |
| 入口要亮 | Function 表父子 / `ENTRY` 汇总即可 |

**错误类比（踩坑记录）**：照抄仙宫时未发现仙宫 GOAL **不是**独立页签 Fn；至尊累抽是独立 `…02` 页签，却 `ZHIZUN_TREASURE.addChild(ZHIZUN_TREASURE_GOAL)` → 累抽有红点时主玩法页签也亮。

**改 Fn 分层后必做**：重审 `RedDots.ts` 全部相关 `createChildOfFn` / `addChild`，与当前 Fn 树对齐。

### 参考

| 模块 | 模式 |
|------|------|
| `XiangongTreasureData` | 双 `RedDotTask`；背包只刷 draw；协议刷 draw+goal；GOAL 与 DRAW **同 Fn** 子红点 |
| `ZhizunTreasureData` | 双 `RedDotTask`；GOAL 为**独立页签 Fn**，勿挂到主玩法 Fn |
| `PillData` / `GodOriginData` / `ItemCraftData` | 单 task：`onDataChange` → change + `updateRedDotsLater` |
| `GrowPageFo` | `RedDotTaskList` 按页 |
| `EquipPageFo` | 多子任务列表 |

---

## Long 类型

| 含义 | 业务类型 | 转换 |
|------|----------|------|
| id | string | `id?.toString()` / `Long.fromString(id)` |
| 可计算数值 | number | `Long.toNumberOrZero(value)` / `Long.fromNumber(value)` |

---

## IDEA 设置摘要

- Code Style：导入 `idea-code-style.xml`，scheme **tuoqi**
- Inspections：导入 `idea-inspections.xml`
- ESLint：Automatic ESLint Configuration，规则见项目 `.eslintrc.json`
- 新建 TS 文件头：File Templates → TypeScript File / CQ File Header

CQ 模板路径（用户本机）：

`%APPDATA%/JetBrains/IntelliJIdea2025.1/fileTemplates/`

含：`CQ Module Win.ts`、`CQ Module Data.ts`、`includes/CQ File Header.ts` 等。

---

## cqone 项目结构速查

```
src/script/
  biz/{module}/data/   → XxxData, XxxMo, XxxEvent, XxxConst
  biz/{module}/view/   → XxxWin, XxxPop, XxxItem
  conf/view/Fns.ts     → FnMo.reg 功能页
  conf/view/Wins.ts    → 弹窗注册
  conf/data/FnId.ts    → 功能 id
  cfg/cfg.ts           → Co（生成）
  proto/netProto.ts    → Po（生成）
fgui/assets/{Pkg}/     → FGUI 组件 xml
tool/csv/              → 策划表
tool/protofile/        → proto 源
```

---

## 超设计尺寸列表：外包 Com + `UiUtil.setVFields`（不新建类）

当列表/区域可能**超出设计宽高**，直接挂在 Win 根下会干扰父级适配时：在 FGUI 里拆成独立组件（如 `RewardCom`、`CardListCom`），**不要**为此新建 TS 类。

写法（参考 `DemonMountainWin`、`ActSummerRebateWin`、`ShopGoodAlienLandItem`）：

```typescript
// Win 上声明最终要用的 v*（列表等）；外包 Com 与内层可同名，setVFields 后同名字段会被覆盖为列表
UiUtil.setVFields(this.vRewards, this);
UiUtil.setVFields(this.vCardList, this);
```

要点：
- `UiUtil.setVFields(gComp, uiComp)`：把 `gComp` 里名字以 `v` 开头的子节点/控制器赋给 `uiComp`（默认 `gComp` 自身）
- 外包 Com 与内层列表可同名：`setVFields` 后同名字段会被列表覆盖，无需临时变量 / `as`
- 外包与内层不同名更清晰（如 `vRewardCom` + `vRewards`）
- **抬红点等到 Win**：子 Com 内勿泛用 `vRedDot`（多次 `setVFields` 同名覆盖）；用 `vPassRewardRedDot` 等业务名（见 fgui-ui-elements「抬字段到 Win」）
- **禁止**仅为这层壳去 `setCustomClass` / 新建 `XxxCom.ts`

---

## setCustomClass 与 BasicViews（防重复注册）

启动：`BasicViews.init()` 在登录前执行，对 **Common 包公共组件** 做全局 `fgui.UIObjectFactory.setExtension`。

### 原因（为何不该在 Win/Pop 再注册）

| 误区 | 实际 |
|------|------|
| 照抄旧模块构造函数里的 `setCustomClass("Btn_a_r", RedDotBtn)` | 多数是历史冗余；`BasicViews` 已注册 |
| 字段类型写了 `RedDotBtn` → 以为必须本窗 `setCustomClass` | **类型声明** 与 **FGUI 扩展注册** 是两回事：类型只影响 TS；运行时类由 `setCustomClass`/BasicViews 决定 |
| 参考 `ShadowTreasureWin` 的 `Btn_draw` | `Btn_draw` 是业务包内组件名，**不在** BasicViews；`Btn_a_r`/`Btn_a_y` **在** |

### 规则

1. **写 Win/Pop 构造函数前**：先查 `conf/view/BasicViews.ts` 是否已有同名组件。
2. **本窗只 `setCustomClass` 本包业务组件**（如 `XiangongTreasureCom`、`BtnReward`、`XxxGoalItem`）。
3. **已全局注册的不要再写**（常见）：`Btn_a_r` / `Btn_a_y` / `Btn_a_g` / `Btn_small` / `CostCom` / `ItemCell` / `RelateFnBtn` / 各类 `Btn_tab*` 等（以 BasicViews 源码为准）。
4. 字段仍可声明为 `vOk: RedDotBtn`，**只 import 类型用，不 setCustomClass**。

### 反例 → 正例

```typescript
// ❌ 重复：BasicViews 已注册 Btn_a_r / Btn_a_y
constructor() {
    super("Xxx", "XxxPop", WinShowStrategy.POP);
    this.setCustomClass("Btn_a_r", RedDotBtn);
    this.setCustomClass("Btn_a_y", RedDotBtn);
}

// ✅ 只注册本包组件；公共按钮依赖 BasicViews
constructor() {
    super("Xxx", "XxxPop", WinShowStrategy.POP);
    this.setCustomClass("XxxGoalItem", XxxGoalItem);
}
```

先例教训：`xiangongTreasure` 初版在 Win/GoalPop/BuyItemPop 重复注册 `Btn_a_r`/`Btn_a_y`（2026-07）。

---

## 常见违规示例

| 违规 | 正确 |
|------|------|
| `isNotifyRedDot()` 当属性用漏写 `()` | 改为 `get isNotifyRedDot()` |
| `protected refreshGoods()` 丢父类参数 | `refreshGoods(updateShop?: ShopMo)` |
| Win 构造函数再 `setCustomClass("Btn_a_r", RedDotBtn)` | 删掉；依赖 `BasicViews`；只注册本包组件 |
| 新类无 `@author` / `@since` | 补全文件头 |
| `ShopDifferentWordWin` 与 FGUI `ShopAlienLandWin` 不一致 | 类名、xml、setCustomClass 对齐 |
| 重复 `import ShopConst` | 合并 import |
| 活动商店配 `Shop.csv` | 活动用 `ActivityShop.csv`，功能商店用 `Shop.csv` |
| `GrowSysFo.instances` 循环听 `upOk` | 改 `GrowData.I.on(EventType.change, ...)` |
| 勾选变更 `event(ShopEvent.NOTIFY_*)` | 改 `eventChangeLater()` + 视图听 `EventType.change` |
| change 回调里同步 `updateAllRedDot` / `goods.some(isBuyRedDot)` | 改 `RedDotTask.runLater()`；缓存或缩小扫描范围 |
| Data 用 `Timer.frameOnce` 刷红点 | 改 `RedDotTask` / `update*RedDotsLater` |
| `init()` 里立刻 `updateRedDotsLater`（依赖 SC/背包） | 挪到 `onSC…` / 数据变更回调 |
| 兄弟页签 Fn 互相 `addChild`（如主玩法挂累抽 GOAL） | 各自 `createChildOfFn(自己的Fn)`；入口靠 Function/`ENTRY`；改 Fn 后重审 `RedDots` |
