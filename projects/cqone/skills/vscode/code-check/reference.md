# code-check 细则

## 用 codegraph 检查（优先）

对目标模块一次 `codegraph_explore`（类名 + 热路径方法：`refresh*` / `getXxx` / `itemRenderer` / `update*RedDot`），拿齐源码与调用关系。

怀疑「重复/浪费」时，**再 explore callee**（如 `playLoop setUrl UiMv`、`eventLater`、`RedDotTask.runLater`），看是否已有同值跳过、队列去重、缓存。

| 勿仅凭调用点推断 | 应跟到的常见底层 |
|------------------|------------------|
| `MvArea.playLoop` 每次刷新都重播 | `UiMv.setUrl`：同 `url`/`firstFrameTime`/loop 则不清动画 |
| 多次 `redDotTask.runLater` | `RedDotTask`/`TaskQueue` 是否合并同任务 |
| `eventChangeLater` | `EventDispatcher` later 是否同事件去重 |
| `GList.numItems = n` | 是否整表重建；结合 `setVirtual` 与 item 复用判断代价 |

codegraph 不可用（无索引/error）时再 Read；报告里对跟过链的项可在「已通过」注明「底层已幂等」。

反例（误报）：`ActSummerRebateItem.setData` → `playLoop` → `UiMv.setUrl` 已同 url 跳过，**不应**建议「同 URL 再判断」。

---

## 热路径定义（本项目）

优先盯这些调用栈上的实现：

- `itemRenderer` / `refresh*` / `onSC*` → 立刻全量刷 UI
- `RedDotTask` 回调 / `update*RedDot`
- `enterFrame` / 每秒倒计时 tick
- 列表滚动中触发的数据 getter

冷路径（打开一次、配置解析）可放宽，但仍优先复用工具，避免复制粘贴。

---

## 常见坏味道 → 建议

| 坏味道 | 建议 |
|--------|------|
| `getXxxArr().some(...)` 仅做有无判断 | `dict.values.some(...)` 或维护计数/标志 |
| 每次 refresh 重建全部 slot/mo | 按 id 增量更新；或确保只在结构变化时 `ensure*` |
| `for (let k in dic)` 扫大表 | `LinkedDic` + `.values`；或业务侧维护有序列表 |
| 嵌套 `for` 配表 × 背包 | 先建 `Dic`/`Set` 再查 |
| 同一 refresh 内多次 `getRewardMos(id)` | 局部变量缓存 |
| Data 里 `Timer.frameOnce` 刷红点 | `RedDotTask.runLater()` |
| 手写 `arr.filter(...).length` 计数 | 看 `ArrayUtil` 是否已有等价 |
| 手写深拷贝/合并对象 | `ObjectUtil` / `DicUtil` |
| 手写 `setTimeout` 业务延迟 | `Timer` / `Callback`（与项目一致） |
| Win 里 `Tween.clearAll(子节点)` | 子组件自己清（封装，兼性能/正确性） |
| 业务重复调 `playLoop(同url)` | **先跟** `UiMv.setUrl`；已幂等则不报 |

---

## 常用工具（检查复用时对照）

路径根：`src/script/core/util/`（及 `biz`/`base` 下同类）。

| 工具 | 典型用途 |
|------|----------|
| `ArrayUtil` | 遍历、过滤、求和、池化扩缩、乱序等 |
| `Dic` / `LinkedDic` | 字典；有序遍历用 LinkedDic |
| `DicUtil` | 分组、数组↔字典/集合 |
| `ObjectUtil` | 对象拷贝/合并/判空类操作 |
| `StringUtil` / `Ubb` / `TemplateStr` | 字符串与模板 |
| `MathUtil` / `RandomSequence` | 数值与随机序列 |
| `DateUtil` | 时间格式与计算 |
| `Callback` | 列表回调、可回收 Handler |
| `Timer` | 延迟/帧定时（非红点） |
| `Listen` / `ListenMgr` | 事件监听生命周期 |
| `ObjectPool` / `UniqueList` | 池与去重列表 |
| `UiUtil` | `setVFields`、UI 辅助 |
| `JsonUtil` / `FileUtil` / `HttpUtil` | IO |
| `ClassUtil` / `ReflectUtil` / `TypeUtil` | 类型与反射 |

业务侧常见：

| 工具 | 典型用途 |
|------|----------|
| `ActDataUtil` | 活动 Co 按 `activityGroup` 等 |
| `CountdownUtil` | 倒计时展示 |
| `RedDotTask` / `RedDotTaskList` | Data 红点 |
| `CfgMgr` | 读表（热路径避免反复全表扫） |

**查法**：手写逻辑出现时，对核心动词（filter/group/sum/delay/listen）在 `core/util` 与同目录先例里搜；找到公开静态方法则报复用机会。

---

## 严重度

| 级 | 含义 | 进报告栏 |
|----|------|----------|
| 必须改 | 热路径明显浪费、错误 API（如 Dic.keys）、红点 Timer 违规 | 必须改 |
| 建议改 | 冷路径冗余、可局部刷新、轻度重复计算 | 建议改 |
| 复用机会 | 正确但可换成通用 API，收益主要是一致性/维护 | 复用机会 |

不确定是否热路径时标「建议改」，并说明触发频率假设。

---

## 与 code-standards 重叠时

- 红点 `RedDotTask`、少算 `dict.values.some`：两边都管 → **本 skill 从性能角度报**，改法仍按 code-standards。
- 纯命名/常规注释补全：**不报**，交给 code-standards。
- **对话提示型注释**：code-standards 禁写；本 skill 在「检查代码」时**直接删除**并在报告「已清理」复述（见 SKILL 清单 F）。

---

## 对话提示型注释（删除示例）

| 应删 | 原因 |
|------|------|
| `/** FGUI 为 image，需手动 touchable */` | 提醒操作，非字段职责 |
| `// 注意：基类也会绑 vClose，此处保证 touchable` | 协作备忘，应对话说 |
| `// 记得调 setFontStyle` / `// 坑：pageCount` | 流程/踩坑提醒 |

| 保留 | 原因 |
|------|------|
| `/** 抽奖动画会话号 */` | 字段职责 |
| `// 同 url 已播则跳过` | 方法体内非显而易见业务原因 |
