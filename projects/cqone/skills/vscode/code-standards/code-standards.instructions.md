---
applyTo: '**/*.{ts,tsx}'
name: code-standards
description: >-
  Enforces cqone/Laya TypeScript coding standards (skill-owned upstream snapshot
  of 代码规范; naming, file headers, @author zhangyongkang, concise method comments
  on new files AND subsequently added methods/fields, encapsulation/own-responsibility,
  new-module Data/View layout, UI lifecycle, Data/Event/Mo suffixes, protocol
  handlers). Use proactively on every write, edit, review, or scaffold of
  TypeScript in cqone; when creating Win, Pop, Data, Mo, Item, Li classes;
  registering FnId, Fns, Protos, RedDots; or when the user mentions 代码规范, 不规范,
  注释, 排版, 封装, 自己的事, 红点, RedDotTask, RedDots, createChildOfFn, addChild,
  页签红点, or naming conventions. For acts/ activity modules also follow acts-module
  skill (选型 + 活动专属检查). After delivering a new/changed cqone feature with FGUI/FnId,
  also follow my-features skill (C:/Users/lu/Desktop/MyFeatures). Before wiring Win/Pop
  to an existing FGUI package, follow fgui-ui-elements (read v* from
  fgui/assets XML / list-fgui-fields.js; ask when 策划与元素对不上).
---

# cqone 代码规范（全局）

**权威正文（skill 自持，勿读 SVN doc）**：[upstream/代码规范.md](upstream/代码规范.md)  
IDEA 格式化说明：[upstream/代码规范-idea设置.md](upstream/代码规范-idea设置.md)（同目录含 `idea-code-style.xml` / `idea-inspections.xml`）  
Agent 常用摘要与增量约定：[reference.md](reference.md)  
上游说明：[upstream/README.md](upstream/README.md)

**硬性要求**：在 cqone 中**新增或修改任何 `.ts` 文件**前读取本 skill；交付前对照下方清单自检。**禁止**再打开 `C:/myPro/doc/代码规范*.md` 作为规范来源（SVN 可能被覆盖）。

**触及底层必读源码**：分析/排障落到引擎或 FGUI API（`bin/libs`、遮罩、控制器、显示对象、渲染等）时，遵循 skill `laya-fgui-engine-source`：用 codegraph 读 `C:/myPro/LayaAir-LayaAir_2.13.1` 与 `C:/myPro/FairyGUI-layabox-master`，勿只猜业务封装或压缩 JS。

---

## 交付前自检（必做）

```
- [ ] 新文件有类头注释（说明 + `@author zhangyongkang` + `@since yyyy-MM-dd`）
- [ ] **注释**：本类方法（含 private）均有精简 `/** */`；**父类覆盖 / `v*` FGUI 元素不加**（`v*` 仅人手写时保留）；优先单行，少用 `@param`/`@return`；**禁对话提示型注释**（坑/注意/需手动…改对话说，见「注释规范」）
- [ ] **后续新增同样要注释**：在已有模块/类里**新加**的方法、字段、getter，与新建时同一套注释规则；勿只给脚手架首版加注释、后续增量漏掉。改旧文件时**不必**给未改动的旧方法补注释
- [ ] **新建 Data/View 排版**：按「新建模块 Data/View 排版」分区；Data 字段必注释；getter 进自定义对外接口；勿为排版重排旧文件
- [ ] **职责边界**：自己的事自己做（缓动/特效/资源由持有者在生命周期内自清）；Win 只编排，不代子组件清内部状态
- [ ] 命名与模块域词统一（dungeon/rahi/alienLand 等，不另造同义词）
- [ ] 类后缀正确（Data/Event/Const/Mo/Co/Po/Win/Pop/Cell/Li/Com）
- [ ] 布尔状态用 is/has/can/need/allow 前缀；优先 getter 而非无参方法
- [ ] Data 收协议：on + 协议名去 Po；发协议：req 开头
- [ ] 视图刷新方法：refresh 开头
- [ ] FGUI 子节点：`v` + 语义 + 类型后缀（`vXxxTxt`/`vXxxBtn`/`vXxxMv`…）；抬 Win 禁泛名 `vRedDot`（见 [fgui-ui-naming](../fgui-ui-naming/SKILL.md)）
- [ ] 界面生命周期顺序与监听清理符合规范（listenMgr 自动 off）
- [ ] 覆盖父类方法时签名与父类一致（含可选参数）
- [ ] 无重复 import、无 Po 当 Mo 用、非必要不用 any
- [ ] 改动范围最小，风格与相邻文件一致
- [ ] **不改无关排版**：不挪动既有方法/成员上下位置、不重排无关 import、不做“顺手整理”；diff 只应含业务相关行
- [ ] Data 变更默认 `eventChangeLater()` + 视图听 `EventType.change`；简单功能不新建 `XxxEvent`
- [ ] 勾选/选中提醒对齐 `ActShopData`，勿自造 `NOTIFY_*` 带参事件
- [ ] **红点必须走 `RedDotTask`**：Data 层禁止用 `Timer.frameOnce`/`Timer.once` 刷红点；**`init` 勿立刻刷依赖后端数据的红点**（等 `onSC…`/背包等就绪）；`eventChangeLater` 与 `redDotTask.runLater` 分离；避免 getter 热路径全量 `some(isBuyRedDot)`
- [ ] **红点挂载（`RedDots.ts`）**：先分清「同 Fn 子红点」vs「独立页签 Fn」；**禁止**把兄弟页签的 `getByFn(GOAL)` `addChild` 到另一页签 Fn（会串红点）；入口汇总靠 Function 父子/`ENTRY`；改 Fn 分层后必须重审 `createChildOfFn`/`addChild`（反例：至尊秘宝曾把 GOAL 挂到主玩法）
- [ ] `setCustomClass`：公共组件（`Btn_a_r`/`Btn_a_y`/`CostCom`/`RelateFnBtn`/`ItemCell` 等）已在 `BasicViews.ts` 全局注册，Win/Pop **禁止再注册**；只注册本包业务组件
- [ ] 超设计宽高的列表/区域：FGUI 外包 Com（如 `RewardCom`），`UiUtil.setVFields(com, this)` 挂到 Win，**不新建** Com 类（见 reference「外包 Com + setVFields」）
- [ ] IDEA 格式化 scheme：tuoqi（Ctrl+Alt+L）
- [ ] **acts 模块**：另过 [acts-module](../acts-module/SKILL.md) 选型与活动专属检查（`ActWin` / Data 模板 / 奖励 param / conf）
- [ ] **功能归档**：新功能/换主包或 FnId 后更新 `C:/Users/lu/Desktop/MyFeatures`（见 [my-features](../my-features/SKILL.md)）；脚手架清单只放 `MyFeatures/checklists/`，禁止工程内 `*.scaffold-checklist.txt`
```


---

## 新建 TypeScript 文件

优先用 IDEA **CQ Module …** 模板（`CQ File Header`）：

```typescript
/**
 * 类说明
 * @author zhangyongkang
 * @since ${YEAR}-${MONTH}-${DAY}
 */
```

- **`@author` 固定为 `zhangyongkang`**（与 IDEA `CQ File Header` 模板一致）
- **禁止**从相邻文件、git 提交者、类名/文件名推断或复制 `@author`（常见误写：`caijinhui`、`yangzhenjie` 等原文件作者）
- 用户未另行指定时，新建/脚手架生成的 `.ts` 一律写 `@author zhangyongkang`
- `import` 写在类注释**上方**
- 成员与方法注释见下方「注释规范」

---

## 注释规范

**原则**：精简、有用；不写废话；优先单行 `/** 说明 */`。

**适用范围（硬性）**：
- **新建**模块/文件：本类方法、字段按表执行
- **后续增量**：在已有类中**新加**的方法 / 字段 / getter，**同样必须**加注释（含 private），与是否「刚建模块」无关
- **改旧代码**：只要求本次新增/你改到的签名带注释；**不要**为通过自检而去给整文件未改动的旧方法补注释

### 禁止「对话提示型」注释（硬性）

写代码时发现的**实现注意点 / 坑 / FGUI 特殊处理 / 给协作者的提醒**，必须写在**对话回复**里告知用户，**禁止**落成 `//` 或 `/** */` 留在源码。

| 允许（注释「是什么 / 业务原因」） | 禁止（应改对话说） |
|------|------|
| `/** 抽奖动画会话号 */` | `/** FGUI 为 image，需手动 touchable */` |
| `/** 请求抽奖 */` | `// 注意：基类也会绑 vClose，此处保证 touchable` |
| `// 同 url 已播则跳过`（方法体内非显而易见原因） | `// 记得 / 勿忘 / 坑：…`、流程提醒、Agent 备忘 |

判定：注释主要在**提醒读者怎么操作/别踩坑**，而不是说明字段或方法**职责** → 对话说，代码删。  
已入库的此类注释：用户触发「检查代码」时由 [code-check](../code-check/SKILL.md) **直接删除**（有价值则在检查报告里复述）。

| 对象 | 要求 |
|------|------|
| 类 | 类头三件套：说明 + `@author` + `@since` |
| 成员变量 / 静态常量 | 单行 `/** 说明 */`（职责语义；禁对话提示型） |
| **`v*` FGUI 元素** | **默认不加**注释；仅人手主动写时保留，Agent **勿自动补**；**禁止**在 `v*` 上写 FGUI 操作提示 |
| **本类方法**（含 private、getter） | 均加精简方法注释（新建 + 后续新增皆然） |
| **父类覆盖方法** | **不加**注释（如 `init`/`onLogout`、`initUi`/`onAddedToStage`/`initData`/`onClose` 等） |
| `@param` / `@return` | 默认不用；仅规则复杂时再写；简单参数写进说明句即可 |
| 方法体内 | 仅非显而易见处用 `// 原因`；禁「注意/记得/需手动」类提示 |

```typescript
/** 今日剩余次数 */
get remainDrawTimes(): number { ... }

/** 请求抽奖；drawCb 为恭喜获得内再抽时关闭弹窗 */
reqDraw(idx: number, drawCb?: Callback): void { ... }

/** 道具不足：有商店入口则弹商店，否则提示不足 */
private openBuyWhenItemNotEnough(cost: number[]): void { ... }

// 父类覆盖 — 不加方法注释
init(): void { ... }
onLogout(isReconnect: boolean): void { ... }
```

细则与多行示例见 [reference.md](reference.md)「注释」。

---

## 新建模块 Data/View 排版

**仅约束「成员书写顺序 / 分区」用于新建或脚手架生成**；改旧文件时勿整文件挪方法（除非用户明确要求重排）。  
**注释不在此限**：排版「仅新建」≠ 注释「仅新建」——后续往模块里加方法仍须按「注释规范」写 `/** */`。

分区默认**空行**；方法多或跨职责再加 `//* ************************************************************************` + 分区说明。

### Data（`XxxData`）

1. 静态单例 `I`
2. **字段**（全部 `/** */`；private 缓存 → public 状态）— **不放** getter
3. **父类/生命周期**：`init` → `onLogout`（…）（覆盖方法不加注释）
4. **协议收包**：`onSC…`
5. **协议发包**：`req…`
6. **自定义对外接口**：`get*` / `is*` / **getter** / `open*` / `set*` / `cancel*` 等
7. **私有实现**：`do*` / `send*` / `refresh*` 等内部逻辑
8. **红点**：`RedDotTask` / `RedDotTaskList` 字段 → `update*RedDotsLater` → `update*RedDot`（见「红点」）

### View（`Win` / `Pop` / `UiComp`）

1. 字段：`v*`（不加注释）→ 其它业务成员（加注释）
2. `constructor`（有 `setWinMo` 则紧随其后）
3. **父类生命周期**（固定）：`initUi` → `onAddedToStage` → `onRemovedFromStage` → [`onClose`] → `initData`
4. **刷新**：`refresh*`
5. **自定义交互/业务**：`on*` / `play*` / `render*` 等
6. 其它私有辅助

完整示例见 [reference.md](reference.md)「新建模块 Data/View 排版」。

---

## 命名（摘要）


| 类别 | 规则 | 示例 |
|------|------|------|
| 模块文件夹 | 小驼峰，尽量单词 | `bag`, `shop`, `alienLand` |
| 类名 | 大驼峰；ctrl/data 以模块名开头 | `ShopData`, `ShopAlienLandWin` |
| 常量 | 全大写下划线 | `ALIEN_LAND_SHOP` |
| 成员/参数 | 小驼峰 | `shopType`, `good` |
| 视图子节点 | `v` + 用途 + **类型简写后缀** | `vMonsterNameTxt`, `vPassRewardBtn`, `vDrawMv`（详见 [fgui-ui-naming](../fgui-ui-naming/SKILL.md)） |
| 缩写 | 用约定简写，不自造 | win/btn/txt/num/fn/cur/mv |

全大写缩写进驼峰时首字母大写其余小写：`UTF` → `Utf`。

**同一概念全项目一词**：例如异界商店用 `AlienLand`，勿混用 `DifferentWord` / `yjsc` 等于义异名类名。

---

## 类后缀（cqone 约定）

| 后缀 | 含义 |
|------|------|
| `Data` | 模块数据，单例 `static readonly I` |
| `Event` | 模块事件常量（**可选**；简单全量刷新勿建，见下方事件规范） |
| `Const` | 零散常量（枚举另建类，无 Const 后缀） |
| `Mo` | 业务信息对象 |
| `Co` / `Po` | 配置 / 协议（工具生成，勿手写） |
| `Win` / `Pop` | 功能页 / 弹窗 |
| `Cell` / `Li` / `Item` | 格子 / 列表项 |
| `Com` | 可复用组件 |

---

## 界面类（extends Win / UiComp）

**只执行一次**：`constructor` → `initUi`  
**每次 show**：`onAddedToStage`（首次）→ `initData`（每次 show）

| 方法 | 用途 |
|------|------|
| `initUi` | 绑事件、`itemRenderer`、`setCustomClass` |
| `onAddedToStage` | `listenMgr.on` 监听 Data 事件 |
| `initData` | 拉数据、全量刷新 |
| `onRemovedFromStage` | 清理；`listenMgr` 已自动 off；**本类持有的 Tween/Mv 等在此自清** |
| `refreshXxx` | 按数据粒度刷新 |

职责边界详见 [reference.md](reference.md)「职责边界（自己的事自己做）」。

FGUI：`super(pkg, resName)` + `setCustomClass("GoodsXxxItem", XxxItem)` 与 xml 组件名一致。  
**仅注册本包业务组件**；`Btn_a_r` / `Btn_a_y` / `CostCom` / `RelateFnBtn` 等已在 `BasicViews.init()` 全局注册，勿在 Win/Pop 构造函数重复 `setCustomClass`（详见 [reference.md](reference.md)「setCustomClass 与 BasicViews」）。

注册功能页：`FnMo.reg(FnId.XXX, XxxWin)` in `Fns.ts`；弹窗用 `Wins.ts`。

---

## 方法命名

| 场景 | 前缀/形式 |
|------|-----------|
| 布尔状态 | `is` / `has` / `can` / `need` / `allow` |
| 协议回调 | `onSC...` / `onCS...`（去 Po 后缀） |
| 请求协议 | `req...` |
| 刷新视图 | `refresh...` |
| 事件响应 | `on...`（如 `onAddedToStage`） |

布尔状态优先 **getter**（与 `isBuyRedDot` 一致），避免 `isXxx()` 方法却当属性用。

---

## 红点（硬性）

**以后 Data 层红点一律走 `RedDotTask`（或多任务用 `RedDotTaskList`）**，与界面刷新双通道分离。

| 要求 | 说明 |
|------|------|
| 必须用 | `new RedDotTask(name, () => this.updateXxxRedDot())` + `runLater()` |
| 禁止 | Data 里用 `Timer.frameOnce` / `Timer.once` 延迟刷红点 |
| **init 不刷依赖后端态的红点** | `ModuleData.init` 在功能协议推送之前（见下）；`init` 只注册监听/读表，红点在 `onSC…` / 背包等数据就绪后再 `runLater` |
| 双通道 | `eventChangeLater()` → 界面听 `EventType.change`；红点 → `update*RedDotsLater()` → `task.runLater()` |
| 分任务 | 背包等只影响抽奖时，只 `drawRedDotTask.runLater()`，勿连带重算无关达标红点 |
| 少算 | 聚合用 `dict.values.some`，勿 `getXxxArr()`（含排序）再 `some` |

### RedDots.ts 挂载（硬性，防页签串红点）

注册 / 改 `FnId`、`RedDots.ts` 时**先判断关系**，再写 `createChildOfFn` / `addChild`：

| 关系 | 正确挂法 | 禁止 |
|------|----------|------|
| **同 Fn 多子红点**（如仙宫抽奖+达标都在同一 Fn） | 多个 `createChildOfFn(同一FnId)` | — |
| **兄弟页签各自独立 Fn**（如主玩法 `…01` + 累抽 `…02`） | 各 `createChildOfFn(自己的FnId)`；页签红点互不影响 | `getByFn(主玩法).addChild(getByFn(累抽))` |
| **父入口汇总**（如 `…00` ENTRY） | 优先靠 Function 表父子；不要为「入口要亮」把兄弟页签互相挂 | 把 GOAL Fn 挂到主 Win Fn |

**反例（至尊秘宝）**：GOAL 已是独立页签 Fn，却 `ZHIZUN_TREASURE.addChild(ZHIZUN_TREASURE_GOAL)` → 累抽亮红点时主玩法页签也亮。  
**对照蓝本时**：先看对方 GOAL 是否**同一 Fn**，再抄挂载；改 Fn 分层（ENTRY/主/Goal）后必须重审 `RedDots`。

**时序（已确认）**：`Main.initModules` → 各 `ModuleData.init()`，发生在 `LoginData.onPreloadBaseOk`；进游戏后 `tryStartGame` 才 `resumeReceive`，随后才有功能 `SC…` 推送与 `SCProtocolPutSuc`/`afterLoginReqs`。故 `init` 时 `useTimes`/背包等常为默认值，立刻算红点无意义甚至会误亮。

参考实现：`XiangongTreasureData`、`PillData`、`GodOriginData`、`ItemCraftData`。细则见 [reference.md](reference.md)「红点」。

---

## 编码禁忌

- **自己的事自己做（封装）**：对象自己的状态与副作用由自己管理；父级/编排者只调公开接口，不代清内部细节（见下）
- 不要将 `Po` 直接当信息对象用
- 不写无意义的 get/set 透传
- `Long` 仅在协议域；业务用 `string`（id）或 `number`（数值）
- 非必要不用继承堆叠；优先组合
- 非必要不点 `any` 属性
- 不写废话注释；方法注释精简见「注释规范」；体内只解释非显而易见原因
- **禁止随意改他人代码排版**：修改已有文件时，保持原有方法/成员声明顺序与空白风格；不要为“更符合自己习惯”而上下挪动 `setWinMo`/`initUi` 等方法位置，也不要顺手重排无关 import。此类改动会污染 diff、阻碍 code review 与阅读对比。仅业务必需的增删改应出现在变更中

### 职责边界（自己的事自己做）

封装的实践口诀：类管好自己的状态与清理，外界只编排。

| 角色 | 该做 | 不该做 |
|------|------|--------|
| `Item` / `Com` / `MvArea` 等子组件 | 自己的缓动 `Tween.clearAll(this)`、特效 `clear`、离台 `onRemovedFromStage` 还原 | 指望 Win 代清本对象上的 Tween |
| `Win` / `Pop` | 流程编排（何时 `flyTo` / 播 mv / 发协议）、作废过期回调 | `Tween.clearAll(子节点)`、替子组件记 origin/清资源 |
| `Data` | 协议与状态；动画结束由 Win 回调再发包 | 用固定 Timer 硬编码子组件动画时长（真动画应由 View 驱动） |

典型反例：关界面后位置错乱——父级 `setXY` 还原但未停子组件缓动，或缓动完成回调在中断后仍执行。正确做法：子组件 `resetFly`/`onRemovedFromStage` 内自清；Win 用 token/`active` 丢弃过期回调。

---

## 与脚手架协作

新建模块时配合 [laya-module-scaffold](../laya-module-scaffold/SKILL.md)；本 skill 约束**所有**手写与生成后的修改。  
功能交付后配合 [my-features](../my-features/SKILL.md) 更新个人功能库。

---

## 不确定时

1. 读同模块最近 1～2 个同类文件（如 `ShopChivalryWin`、`ShopData`）
2. 读 [reference.md](reference.md) 对应章节
3. 仍不确定则问用户，勿自造命名或结构
