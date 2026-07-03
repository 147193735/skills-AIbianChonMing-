---
name: code-standards
description: >-
  Enforces cqone/Laya TypeScript coding standards from C:/myPro/doc/代码规范.md
  (naming, file headers, UI lifecycle, Data/Event/Mo suffixes, protocol handlers).
  Use proactively on every write, edit, review, or scaffold of TypeScript in cqone;
  when creating Win, Pop, Data, Mo, Item, Li classes; registering FnId, Fns, Protos;
  or when the user mentions 代码规范, 不规范, or naming conventions.
---

# cqone 代码规范（全局）

完整文档：`C:/myPro/doc/代码规范.md`  
IDEA 模板与格式化：`C:/myPro/doc/代码规范-idea设置.md`  
细则展开：[reference.md](reference.md)

**硬性要求**：在 cqone 中**新增或修改任何 `.ts` 文件**前读取本 skill；交付前对照下方清单自检。

---

## 交付前自检（必做）

```
- [ ] 新文件有类头注释（说明 + @author + @since yyyy-MM-dd）
- [ ] 命名与模块域词统一（dungeon/rahi/alienLand 等，不另造同义词）
- [ ] 类后缀正确（Data/Event/Const/Mo/Co/Po/Win/Pop/Cell/Li/Com）
- [ ] 布尔状态用 is/has/can/need/allow 前缀；优先 getter 而非无参方法
- [ ] Data 收协议：on + 协议名去 Po；发协议：req 开头
- [ ] 视图刷新方法：refresh 开头
- [ ] FGUI 子节点：v 前缀（vGoods、vSelect、vSelectAll）
- [ ] 界面生命周期顺序与监听清理符合规范（listenMgr 自动 off）
- [ ] 覆盖父类方法时签名与父类一致（含可选参数）
- [ ] 无重复 import、无 Po 当 Mo 用、非必要不用 any
- [ ] 改动范围最小，风格与相邻文件一致
- [ ] IDEA 格式化 scheme：tuoqi（Ctrl+Alt+L）
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

- `@author` 用姓名拼音全拼（与团队 IDEA 模板一致）
- `import` 写在类注释**上方**
- 单行成员注释：`/** 说明 */`

---

## 命名（摘要）

| 类别 | 规则 | 示例 |
|------|------|------|
| 模块文件夹 | 小驼峰，尽量单词 | `bag`, `shop`, `alienLand` |
| 类名 | 大驼峰；ctrl/data 以模块名开头 | `ShopData`, `ShopAlienLandWin` |
| 常量 | 全大写下划线 | `ALIEN_LAND_SHOP` |
| 成员/参数 | 小驼峰 | `shopType`, `good` |
| 视图子节点 | `v` + 用途 | `vFrame`, `vDesc`, `vSelect` |
| 缩写 | 用约定简写，不自造 | win/btn/txt/num/fn/cur |

全大写缩写进驼峰时首字母大写其余小写：`UTF` → `Utf`。

**同一概念全项目一词**：例如异界商店用 `AlienLand`，勿混用 `DifferentWord` / `yjsc` 等于义异名类名。

---

## 类后缀（cqone 约定）

| 后缀 | 含义 |
|------|------|
| `Data` | 模块数据，单例 `static readonly I` |
| `Event` | 模块事件常量 |
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
| `onRemovedFromStage` | 清理；`listenMgr` 已自动 off |
| `refreshXxx` | 按数据粒度刷新 |

FGUI：`super(pkg, resName)` + `setCustomClass("GoodsXxxItem", XxxItem)` 与 xml 组件名一致。

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

## 编码禁忌

- 不要将 `Po` 直接当信息对象用
- 不写无意义的 get/set 透传
- `Long` 仅在协议域；业务用 `string`（id）或 `number`（数值）
- 非必要不用继承堆叠；优先组合
- 非必要不点 `any` 属性
- 不写废话注释；只解释非显而易见的业务/技术原因

---

## 与脚手架协作

新建模块时配合 [laya-module-scaffold](../laya-module-scaffold/SKILL.md)；本 skill 约束**所有**手写与生成后的修改。

---

## 不确定时

1. 读同模块最近 1～2 个同类文件（如 `ShopChivalryWin`、`ShopData`）
2. 读 [reference.md](reference.md) 对应章节
3. 仍不确定则问用户，勿自造命名或结构
