---
name: code-standards
description: Enforce project-specific coding standards — naming conventions (folder, class, variable, method), comment format, code ordering, UI class lifecycle, and TypeScript best practices. Use when the user asks to "check code style", "follow the coding standards", is writing or reviewing TypeScript/JavaScript code in this project, or when another skill (e.g. review) needs standards enforcement.
---

# Coding Standards

按照本项目[代码规范](../../../CODING_STANDARDS.md)（如无此文件，则按以下内建规则）检查与生成代码。

当生成、修改或审查代码时，必须对照以下规则逐条检查。**每一条都是必须遵守的硬性约束。**

---

## 1. 命名规范

### 1.1 原则

- **统一性**：对同一事物的命名必须在所有地方保持一致。例如：副本模块将副本命名为 `dungeon`，其他模块就不能命名为 `copy`、`fuben` 等。
- **简短优先**：在含义清楚的前提下尽量用短词。能用单个词表达就不用两个词。
- **约定简写**：使用以下约定简写，不自创：

    | 简写            | 原词                 | 含义            |
    | --------------- | -------------------- | --------------- |
    | `i`             | index                | 索引（循环中）  |
    | `cur`           | current              | 当前            |
    | `prev` / `next` | previous / next      | 前一个 / 后一个 |
    | `w` / `h`       | width / height       | 宽 / 高         |
    | `img`           | image                | 图片            |
    | `btn`           | button               | 按钮            |
    | `txt`           | text                 | 文本            |
    | `win`           | window               | 窗口视图        |
    | `len`           | length               | 长度            |
    | `num`           | number               | 数字或数量      |
    | `arr`           | array                | 数组            |
    | `str`           | string               | 字符串          |
    | `fn`            | function             | 方法            |
    | `src` / `dst`   | source / destination | 源 / 目标       |

- **避免关键字重名**：不与语言和引擎的关键字重名。
- **全大写缩写驼峰化**：全大写缩写在驼峰命名中转为首字母大写、后续小写。如 `RMB` → `Rmb`，`GBK` → `Gbk`，`UTF` → `Utf`。

### 1.2 模块文件夹名

- 格式：**小写字母开头驼峰**（如 `bag`、`player`、`myPlayer`）
- 要求：含义清楚前提下尽量简短，尽量用单个词，不与 JS 内置关键字/工具类同名。

### 1.3 类名

- 格式：**大写字母开头驼峰**
- 要求：含义清楚前提下尽量简短。
- 前缀要求：除 `core`、`base`、`common` 等底层/公共模块外，`ctrl` 和 `data` 文件夹下的类**必须以模块名开头**，`view` 文件夹下的类也尽量以模块名开头。
- 后缀约定：

    | 后缀    | 全称            | 用途                     | 示例                                                                                                           |
    | ------- | --------------- | ------------------------ | -------------------------------------------------------------------------------------------------------------- |
    | `Ctrl`  | Controller      | 模块控制器               | `XxxCtrl`                                                                                                      |
    | `Data`  | Data            | 模块数据                 | `XxxData`                                                                                                      |
    | `Event` | Event           | 模块事件                 | `XxxEvent`                                                                                                     |
    | `Const` | Constant        | 模块常量（零散常量）     | `XxxConst`                                                                                                     |
    | `Co`    | Config Object   | 配表数据封装（工具生成） | `ItemCo`、`EquipAttrCo`                                                                                        |
    | `Po`    | Protocol Object | 协议数据封装（工具生成） | `EquipPageVoPo`                                                                                                |
    | `Fo`    | Function Object | 功能数据封装             | `EquipPageFo`、`EquipSlotFo`                                                                                   |
    | `Mo`    | Message Object  | 服务端信息封装           | `EquipPageMo`、`EquipSlotMo`                                                                                   |
    | 枚举类  | —               | 枚举常量（无固定后缀）   | `EquipSysId`、`EquipEnhanceSysId`                                                                              |
    | 视图类  | —               | 按视图类型定后缀         | `Win`（界面）、`Pop`（弹窗）、`Cell`（格子）、`Li`（列表项）、`Btn`（按钮）、`Com`（组件）、`View`（一般视图） |

### 1.4 变量名

- **常量**：`UPPER_SNAKE_CASE`（全大写、下划线分词），如 `CITY_SCENE_ID`、`MONSTER_TEAM_ID`。
- **可变量**（成员变量、形参、局部变量）：**小写字母开头驼峰**。
    - 类成员变量：含义清楚前提下尽量简短，如 `bagData`、`sceneId`、`scene`。
    - 视图类中的子视图：
        - 一般视图：`v` 开头 + 用途，如 `vBagList`
        - 按钮：`v` 开头 + 点击后执行的动作，如穿戴按钮 `vWear`
    - 方法形参/局部变量：作用域窄，可更简短，如 `i`、`id`、`num`、`len`。

### 1.5 方法名

- 格式：**小写字母开头驼峰**，一般以动词开头，某些情况用介词开头（`onXxx`、`afterXxx`、`beforeXxx`、`whenXxx`）。
- 分类约定：

    | 类别          | 规则                                                                                    | 示例                                             |
    | ------------- | --------------------------------------------------------------------------------------- | ------------------------------------------------ |
    | 获取布尔状态  | `is`（是否）、`has`（有没有）、`need`（是否需要）、`can`（是否能）、`allow`（是否允许） | `isMoving`、`hasSpace`、`canMove`                |
    | 事件监听      | `on` + 事件名                                                                           | `onAddedToStage`                                 |
    | Data 类收协议 | `on` + 协议类名（去 Po 后缀）                                                           | `onSCSynPosition`                                |
    | Data 类发协议 | `req` + 含义清楚的名字                                                                  | `reqEnterScene`、`reqUseSkill`                   |
    | 视图刷新数据  | `refresh` + 数据名                                                                      | `refreshLevel`、`refreshData`、`refreshHp`       |
    | 一般方法      | 动词开头                                                                                | `init`、`show`、`clear`、`addItem`、`removeItem` |

---

## 2. 注释规范

### 2.1 类注释

```ts
/**
 * 类说明
 * @author 中文名拼音全拼
 * @since yyyy-MM-dd
 */
```

### 2.2 方法注释

所有公有方法原则上都需要注释。参数和返回值只在规则复杂时说明。

```ts
/**
 * 方法说明
 * @param 参数名 参数说明
 * @return 返回值说明
 */
```

### 2.3 成员变量注释

使用单行注释：

```ts
/** 变量说明 */
```

### 2.4 方法内部语句块注释

只加在需要特别解释或容易引起误解的地方：

```ts
// 原因说明
```

---

## 3. 代码书写顺序与分区

### 3.1 类成员顺序

1. 静态成员变量
2. 初始化性质、get 性质的静态成员方法
3. 成员分区行（非必须）
4. 非静态成员变量
5. 成员分区行（非必须）
6. 构造方法
7. 普通成员方法（所有非静态方法 + 功能型静态方法）

### 3.2 分区分隔

当类中成员较多时，使用以下分隔行：

```ts
//* ************************************************************************
//* 分区说明
//* ************************************************************************
```

### 3.3 方法内语句

相关性大的语句写在一起，不同区之间用空行隔开。

---

## 4. 编码规范

### 4.1 界面类

界面类继承自 `Win`，成员按以下顺序定义：

1. **子视图成员变量**：`v` 开头，自动接收 FGUI 同名子元件
2. **`constructor`**：调用 `super`，设置 FGUI 资源、释放时机、所在图层
3. **`setWinMo`**：视图刚实例化、未加载资源时初始化实例
4. **`initUi`**：资源加载完毕、子视图赋值完毕后初始化界面，包括按钮事件监听
5. **`onAddedToStage`**：视图添加到舞台后，监听外部数据变更事件
6. **`onRemovedFromStage`**：视图从舞台移除时清理（注意：`listenMgr` 添加的事件监听已自动移除）
7. **`initData`**：界面刚显示出来时刷新全部数据
8. **`refreshXxx`**：按需定义细分刷新方法（数据多且变化时机不同时）

执行顺序：

```
constructor → setWinMo → [加载资源] → initUi
  → show
    → [未在舞台] onAddedToStage → initData
    → [已在舞台] initData
  → hide → onRemovedFromStage
```

> 注意：`constructor`、`setWinMo`、`initUi` 只执行一次；`onAddedToStage` 和 `initData` 每次 show 不一定都执行。

### 4.2 get/set 方法

不写没用的 get/set。如 `get id() {return this._id;} set id(v) {this._id = v;}` 应直接定义公有成员变量。

### 4.3 Long 类型

Long 类型变量仅用于协议域，业务域中按含义转换：

| 含义       | 业务域类型 | Long → 业务域                                        | 业务域 → Long            |
| ---------- | ---------- | ---------------------------------------------------- | ------------------------ |
| id         | `string`   | `id?.toString()`                                     | `Long.fromString(id)`    |
| 可计算数值 | `number`   | `Long.toNumberOrZero(value)`（安全，兼容 undefined） | `Long.fromNumber(value)` |

### 4.4 杂项

- **禁止**将 `Po` 直接用作信息对象。
- **避免**在 `any` 类型身上直接点属性/方法（不便于重构）。
- **优先**用组合而非类继承（继承易引发类加载乱序和启动报错）。

---

## VS Code 配置

在 `%APPDATA%\Code\User\prompts\`（Windows）或 `~/Library/Application Support/Code/User/prompts/`（macOS）下创建 `code-standards.instructions.md`：

```yaml
---
applyTo: '**/*.{ts,tsx}'
---
```

然后将此文件内容放入该文件。`applyTo` 确保仅在编辑 TypeScript 文件时触发。

## Cursor 配置

在项目 `.cursor/rules/` 下创建 `code-standards.mdc`：

```yaml
---
description: Enforce project-specific coding standards — naming, comments, ordering, UI class patterns. Auto-applies when editing TypeScript files.
globs: '**/*.{ts,tsx}'
alwaysApply: false
---
```

然后将此文件内容（不含 YAML 头部的 `name` 和 `license`）放入该文件。`globs` 确保仅在编辑 TypeScript 文件时触发。
