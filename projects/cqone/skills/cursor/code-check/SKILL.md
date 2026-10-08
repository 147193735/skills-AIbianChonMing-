---
name: code-check
description: >-
  Checks cqone TypeScript for runtime/algorithm performance and whether
  existing common utilities are reused instead of reinvented; removes
  dialogue-tip comments (坑/注意/需手动…); reports unused imports / dead code
  under 建议删除 for user review before any delete; flags over-encapsulation
  (isXxx/canXxx that only alias enum/stage fields). Use when the user says
  检查代码, 性能检查, 代码性能, 算法性能, 有没有用通用方法, 复用检查,
  or asks to audit hot paths / Dic vs LinkedDic / ArrayUtil reuse on a module
  or diff. Complements code-standards (naming/comments) and does not replace
  Bugbot/security review.
---

# cqone 代码检查（性能 + 通用方法 + 清注释/无用代码 + 过度封装）

**范围**：运行时性能、算法复杂度、是否复用项目已有通用能力；清理「对话提示型」注释；扫无用 import / 无用代码（**只报建议删除，审核后才删**）；扫「无意义枚举/阶段透传封装」。  
**不做**：命名/常规注释补全/排版（→ [code-standards](../code-standards/SKILL.md)）；安全专项（→ review-security）；通用缺陷扫雷可另用 Bugbot/OCR。

**默认检查对象**：用户指定的模块/文件；未指定则查当前打开文件或本次会话改动的 diff。

---

## Agent 必做顺序

1. 读本 skill；细则见 [reference.md](reference.md)。
2. 确定范围（路径或 diff）；**优先 `codegraph_explore`** 拉模块实现与调用关系（等同已 Read）；codegraph 不可用再 Read。
3. 按下方清单逐项检查；对「重复调用 / 缺防护 / 未复用」类结论，**必须跟到 callee 实现**再定论（见「跟链防误报」）。
4. 只报**可行动**问题（有位置 + 原因 + 建议）。
5. **落地清理仅限清单 F**：对话提示型注释 → **直接删除**，写进「已清理」。
6. **清单 H（无用 import / 无用代码）禁止自动删除**：全文搜确认**定义外零命中**后写入报告 **「建议删除」**（含零引用的 `open*Win` / MvRes / TITLES / `get*Cos` 等预留 API，条目可标「预留/资源，审核慎删」）；**须等用户审核同意**后再删。仅协议注册目标、父类空钩子不进建议删除。
7. 输出固定报告格式；其余项（含过度封装）**默认只报告，不改代码**。用户明确要求「一并改」再动手（仍不含未审核的 H 删除）。

---

## 跟链防误报（硬性）

业务侧看似每次都重做的调用，底层常已做幂等。**未看 callee 源码不得报「重复/浪费」**。

| 场景 | 动作 |
|------|------|
| `playLoop` / `setUrl` / `play` / loader | codegraph 跟到 `MvArea`→`UiMv.setUrl` 等；同 url 已 early-return 则**不报** |
| `setData` / `refresh` / `numItems` | 跟到列表/组件是否同数据跳过或虚拟复用 |
| `eventLater` / `runLater` / `RedDotTask` | 确认是否队列去重，再谈「重复刷」 |
| 「手写了 X，该用 Y」 | codegraph/搜确认 Y 的 API 与语义匹配后再报复用 |
| 「过度封装」 | 打开 getter/方法体：仅 `return this.field === CONST` / `!this.field` / 透传另一 getter → 报；组合多条件/查表/算时间 → **不报** |
| 「无用代码」 | 全文搜零引用 → **写入「建议删除」**，**禁止当场删**；用户审核同意后再删。协议 `onSC*`/`req*`、Fns·Wins·Protos·`setCustomClass`、父类空钩子 → **不进建议删除**。零引用的预留/资源 API（`open*Win`、MvRes、TITLES、`get*Cos` 等）**仍进建议删除**，标「预留/资源，审核慎删」 |

跟链后若底层已防护：写进「已通过」一句即可，勿塞进建议改。
---

## 检查清单

### A. 数据结构与遍历

- [ ] 频繁遍历用 `LinkedDic`（`.values` / `.keys`），避免热路径上对大 `Dic` 做 `for-in`
- [ ] 勿对 `Dic` 假装有 `.keys`（只有 `LinkedDic` 有）
- [ ] 聚合判断用 `dict.values.some` / 直接字段，**禁止** `getXxxArr()`（含排序）再 `some` 做红点/可见性
- [ ] 能 O(1) 字典查的不要线性扫全表；能增量更新的不要每次全量重建

### B. 算法与重复计算

- [ ] 嵌套循环是否可改为字典 / 一次遍历
- [ ] 同一次刷新内是否重复 `getRewardMos` / `filter` / `sort` 同一批数据（应缓存局部变量）
- [ ] `refresh*` / `itemRenderer` / `enterFrame` 路径是否做了不必要的分配（临时大数组、反复 `new`）
- [ ] 协议回包是否触发多余全量 UI 刷新（能局部刷则局部刷）

### C. 定时器 / 事件 / 红点

- [ ] Data 层红点必须 `RedDotTask` / `runLater`，禁止 `Timer.frameOnce`/`Timer.once` 刷红点
- [ ] `eventChangeLater` 与红点 `runLater` 分离；勿用刷新界面代替刷红点
- [ ] 监听用 `listenMgr`；离台/登出路径能清掉自己加的 Timer/Tween

### D. 是否复用通用方法（优先用现成的）

发现手写逻辑时，先对照 [reference.md](reference.md)「常用工具」与同模块先例，确认是否已有：

| 场景 | 优先 |
|------|------|
| 数组遍历/过滤/求和/池化长度 | `ArrayUtil` |
| 分组、arr↔set、建字典 | `DicUtil` |
| 字典存取、有序遍历 | `Dic` / `LinkedDic` |
| 延迟回调、去重 later | `Callback`、`EventDispatcher.eventLater` |
| UI 子节点 `v*` 挂载 | `UiUtil.setVFields` |
| 列表渲染回调 | `Callback.get` |
| 活动配置按 `activityGroup` | `ActDataUtil` / `CommonAct*X` |
| 倒计时文案等 | `CountdownUtil` 等 base 工具 |

手写等价实现 → 报「未复用」，并指出应对工具/先例路径。

### E. View / 列表特有

- [ ] 虚拟列表：数据量大时是否 `setVirtual`（业务允许时）
- [ ] `itemRenderer` 内勿做重逻辑（查全表、反复 `CfgMgr` 全扫）
- [ ] 超设计尺寸列表是否外包 Com + `setVFields`（见 code-standards），避免错误撑布局导致额外刷新

### F. 对话提示型注释（发现即删）

判定与禁写规则见 [code-standards](../code-standards/SKILL.md)「禁止对话提示型注释」。本 skill 负责**检查时落地删除**。

- [ ] 扫范围内 `//` / `/** */`：若主要在提醒「注意 / 需手动 / 记得 / FGUI 坑 / 协作备忘」，而非说明职责或业务原因 → **删除该注释**
- [ ] 删后若提示仍有协作价值 → 写进报告「已清理」并在对话复述一句
- [ ] **勿**借机补全其它注释或改排版；只删提示型注释

反例（应删）：`/** FGUI 为 image，需手动 touchable */`、`// 注意：基类也会绑 vClose，此处保证 touchable`  
正例（保留）：`/** 抽奖动画会话号 */`、`// 同 url 已播则跳过`

### G. 过度封装（无意义间接层）

细则见 [code-standards](../code-standards/SKILL.md) / [reference.md](../code-standards/reference.md)「过度封装」。本 skill **只报告、默认不改**。

- [ ] 扫 `*Mo.ts` / `*Data.ts` 的 `get is/can/has…` 与无参 `is/can/has…()`：体若仅 `return this.xxx === CONST` / `!==` / `!this.xxx` / 透传另一同义 getter → 报「过度封装」，建议调用方直接比字段常量
- [ ] **不报**：组合多条件（如 `hasFruit &&` 时间到）、查表/遍历结果、需计算的展示值（剩余秒等）
- [ ] **不报**：公共基类契约（如 `CommonActMo.isCanGainState`）——除非本模块又包了一层同义别名
- [ ] 报告进「建议改」；纯透传且调用多处可进「必须改」

反例（应报）：`get canGainPrivilege() { return this.rechargeState === CAN_GAIN; }`、`get isEffectCdEnd() { return this.canGainEffect; }`  
正例（保留）：`get canHarvest() { return this.hasFruit && this.isHarvestCdEnd; }`、`get coolDownLeftSec()`

### H. 无用 import / 无用代码（只报「建议删除」，审核后才删）

细则见 [reference.md](reference.md)「无用 import / 无用代码」。

**硬性**：检查阶段对 H **一律不改文件**；条目写入报告 **「建议删除」**。用户审核同意后再执行删除（可整批或逐条）。

**建议删除（候选）** — 定义外全文零命中即报，**含预留/资源类**

- [ ] 未在本文件使用的 `import` / `import =`（含类型-only 未引用；side-effect-only 除外）
- [ ] 本文件未引用的 `private` 方法/字段/局部变量
- [ ] 全文零引用的模块 API / 明确不可达死分支（含 `open*Win`、`*MvRes*`、`*_TITLES`、`get*MvResId`、`get*Cos`、效果·果实预表访问器等）—— 预留类加注 **「预留/资源，审核慎删」**
- [ ] **有引用则不报**（已接线的预留不算无用）

**不进建议删除**

- [ ] `onSC*` / `req*`、Fns·Wins·Protos·RedDots·`setCustomClass` 注册目标
- [ ] 覆盖父类的空钩子（`onRule` 等）

- [ ] 候选须 codegraph/全文搜确认定义外零命中
- [ ] 报告每条写清：`path` + 符号名 + 为何判无用（预留类写上标签）
- [ ] 用户说「删建议删除」「同意删」或点名某条后，才删对应项，并记入「已清理」；预留类用户未点名时不要因「整批删」误删，应确认

---

## 报告格式

```markdown
## 代码检查：<范围>

### 结论
<一句话：有/无必须改项；性能/复用/过度封装各几条；建议删除几条待审核；是否清了提示注释>

### 必须改
- `path:行号附近` — 问题 — 建议

### 建议改
- `path:行号附近` — 问题 — 建议
- （过度封装）`path:行号` — `isXxx` 仅透传 `field === CONST` — 调用方直接比常量

### 建议删除（待审核，默认不删）
- `path:行号` — `符号` — 全文零引用 / 未使用 import — 建议删
- （预留/资源，审核慎删）`path:行号` — `openTreeWin` — 全文零引用
- （无则写「无」）

### 复用机会
- `path` — 手写了 X — 应用 `Y.zzz`（参考 `path/to/example`）

### 已清理
- （提示注释）`path` — 原注释大意
- （审核后删除）`path` — `符号`（仅当用户已确认）

### 已通过（可选，极短）
- …
```

无问题写「未发现必须改项」，可列 1～2 条观察，勿凑数。

---

## 与其它技能

| 技能 | 分工 |
|------|------|
| [code-standards](../code-standards/SKILL.md) | 规范、注释（含禁写对话提示）、排版、过度封装**禁写** |
| [acts-module](../acts-module/SKILL.md) | 活动选型 |
| 本 skill | 性能 + 通用复用 + **检查时删除**提示注释 + **建议删除待审核**无用 import/死代码 + **检查时报告**过度封装 |

先完成本检查再改代码时：改完仍遵守 code-standards（含新增方法注释；仍禁写对话提示型注释与无意义枚举透传）。
