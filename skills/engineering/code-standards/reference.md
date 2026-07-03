# cqone 代码规范 — 详细参考

来源：`C:/myPro/doc/代码规范.md`（格式化见 `代码规范-idea设置.md`）

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

## 方法注释

公有方法原则上都加；参数/返回值仅在规则复杂时说明。

```typescript
/**
 * 方法说明
 * @param id 参数说明
 * @return 返回值说明
 */
```

## 成员变量

```typescript
/** 变量说明 */
private goods: ShopGoodsMo[];
```

## 语句块

```typescript
// 非显而易见的原因说明
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

## 常见违规示例

| 违规 | 正确 |
|------|------|
| `isNotifyRedDot()` 当属性用漏写 `()` | 改为 `get isNotifyRedDot()` |
| `protected refreshGoods()` 丢父类参数 | `refreshGoods(updateShop?: ShopMo)` |
| 新类无 `@author` / `@since` | 补全文件头 |
| `ShopDifferentWordWin` 与 FGUI `ShopAlienLandWin` 不一致 | 类名、xml、setCustomClass 对齐 |
| 重复 `import ShopConst` | 合并 import |
| 活动商店配 `Shop.csv` | 活动用 `ActivityShop.csv`，功能商店用 `Shop.csv` |
