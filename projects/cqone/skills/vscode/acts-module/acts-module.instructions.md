---
applyTo: '**'
name: acts-module
description: >-
  Guides cqone activity (acts) modules: choose ActWin/CommonAct*X vs CommonAct*
  vs ModuleData before coding, enforce activity-specific checklist, and wire
  scaffold/conf. Use when creating or changing src/script/acts/*, ActWin,
  CommonActData(X), CommonActGroupMo(X), activity FnId/Protos/RedDots, or when
  the user mentions 活动模块, 新活动, CommonAct, ActWin, acts 脚手架.
---

# cqone 活动模块（acts）

活动玩法写在 `src/script/acts/<module>/`；公共壳在 `src/script/biz/act/`。  
**新建或大改活动前必须先完成本 skill 选型**；再跑 [laya-module-scaffold](../laya-module-scaffold/SKILL.md)；写代码遵守 [code-standards](../code-standards/SKILL.md)；有 FGUI 包时先 [fgui-ui-elements](../fgui-ui-elements/SKILL.md)；交付后 [my-features](../my-features/SKILL.md)。

**文件头 `@author`**：固定 `zhangyongkang`。

---

## 何时使用

| 场景 | 做法 |
|------|------|
| 新建 acts 模块 | 先选型（下方差异表）→ scaffold `--acts` → 改 Data 基类 → conf → 本 skill 检查 |
| 改现有活动 / 加 GroupMo / Win | 对照心智模型与交付检查；勿盲目套 X |
| 只理解注册流程 | [ARCHITECTURE.md](../laya-module-scaffold/ARCHITECTURE.md) + 本 skill「分层心智」 |

---

## Agent 必做顺序

1. **读本 skill**（选型 + 检查清单）。
2. **向用户确认差异**（未确认不得写业务骨架）：
   - 玩法族：达标领奖 / 抽奖转盘 / 礼包商店 / 排行 / 其它
   - Data 模板：`CommonAct*X`（默认）/ `CommonAct*`（用户明确抄老）/ `ModuleData`（形态不符）
   - 是否双组（玩法组 + Goal 组）
   - 参考模块路径（见下表）
3. 再跑脚手架（若需要）：`--acts`；生成后 **把 Data/Mo/GroupMo 改成选定基类**（脚手架默认 Data 仍是普通骨架，不自动生成 CommonAct*X）。
4. 补 `FnId`、`Protos`、`RedDots`、`Wins`（见 MyFeatures/checklists 脚手架清单，勿写入工程）。
5. 交付前：code-standards 全局清单 + **本 skill 活动专属检查** + MyFeatures。

---

## 新建前差异表（必确认）

| 层 | 新活动默认 | 例外 |
|----|------------|------|
| 壳 | **必须** `ActWin` + 挂 `ActFn` / 走 `ActData` 开闭与倒计时 | 非活动入口窗另议 |
| Data 模板 | **优先** `CommonActDataX` + `CommonActGroupMoX` + `CommonActMoX`（Goal 用 `CommonActGoalMoX`） | 排行/公告等 → `ModuleData`；用户明确抄老 → 可 `CommonActData` |
| 主键 | X：`activityId`；旧 Common：`actFnId` | 与选定模板一致，勿混用 |
| 双组 | 玩法有「抽/买」+「累计达标」时拆两个 GroupMo | 单列表达标可一组 |

### 玩法族 → 参考模块

| 玩法族 | Data 建议 | 参考路径 |
|--------|-----------|----------|
| 抽奖 / 转盘 + 累计 | `CommonAct*X` | `src/script/acts/treasureVault/` |
| 进度 / 达标列表（新） | `CommonAct*X` | `src/script/acts/progress/` |
| 登录 / 日充等老达标 | 抄老时可用 `CommonAct*` | `src/script/acts/login/`、`dailyRecharge/` |
| 礼包 / 商店 | 视配置行形态；能套则 X/Common，否则自管 | `shop/`、`secKillGift/` |
| 排行 | `ModuleData` + 排行基类 | `src/script/acts/dailyRank/` |
| 公告 / 特殊 | `ModuleData` | `src/script/acts/notice/` |

**不强制**存量活动迁到 X。

---

## 分层心智（短）

```
biz/act/     活动壳：开闭、展示期、倒计时、通用领奖/奖励展示、ActWin
acts/xxx/    玩法：协议、配置组、红点细则、界面编排
```

| 概念 | 含义 |
|------|------|
| `ActFn` / `actFnId` | 入口功能，与 FnId 对应；展示中的活动挂在 `actFn.actMo` |
| `ActMo` / `activityId` | 一期活动实例 |
| `CommonAct*` | 旧模板：按 `actFnId` 管配置行；一个 Fn 同时一个活动 |
| `CommonAct*X` | 新模板：按 `activityId`；组合代替厚泛型 |
| `ActWin` | 绑 `ActFn`，听 DATA_CHANGE / 倒计时 / 奖励展示；子类覆写内容请求与刷新 |

抽基类抽的是 **壳 + 配置行范式**，不是玩法都一样。玩法差异写在各自 `*Data` / `*GroupMo` / `reqXxx`。

---

## 脚手架衔接

```bash
# 先完成本 skill 选型，再：
node <laya-module-scaffold>/scripts/scaffold-module.js <moduleName> --acts --standard|--full --project C:/myPro/cqone
```

- Win：脚手架已 `extends ActWin`。
- Data：脚手架生成后改为 `CommonActDataX`（或确认的其它基类），`init` 里 `addGroupMo(...)`。
- GroupMo / Mo / GoalMo：按参考模块补；`coClass` + `moClass` 必配。
- 类名：`Act` 前缀（scaffold 对 acts 会处理）。

---

## 活动专属交付检查（必做）

在 code-standards 全局清单之外，acts 还须勾选：

```
- [ ] 已与用户确认玩法族 / Data 模板 / 是否双组 / 参考模块
- [ ] 主界面 Win 继承 ActWin；内容走 reqActContentData / refreshActContentData（及需要的 refreshActRewardShow）
- [ ] 奖励展示：reqRewardShowInfo / getRewardShowMo；多类奖励有 ParamId（或等价常量），勿混 param
- [ ] 通用领奖走 ActData.I.reqGainReward（或文档化的自有 CS 协议）；Goal 全量/增量用 ActDataUtil.resetGoalsX / updateGoalsX（旧模板则 resetGoals / updateGoals）
- [ ] 恭喜获得弹窗：通用 `GainRewardView`（`WinId.GAIN_REWARD_POP`）。后端推 `SCPopupsGainItemReward` 会自动弹；若需客户端在动效/点亮后再弹，用 `GainRewardData.I.createFakePopupWithMo(items, fnId)`（参考 `FaxiangTreasureWin`）。两端勿叠弹
- [ ] 恭喜获得 `vPrizeType`：在 `ShowRule.updateRewardItem` 里用 `gainRewardMo.configIdArr.get(mo.srcIdx)` 取奖池配置 id，再读表字段（如 `ifSpecialReward`）设 `item.vPrizeType.selectedIndex`（大奖角标一般为 `1`）。`reward` 为掉落包时**禁止**用包 id / 道具 id 本地缓存判断。参考 `SummerTreasureShowRule` / `DragonTreasureShowRule` / `TurnTableShowRule`。需要 `GainRareRewardView` 时才注册 `SortRule.filterRare`（同样走 configId）；不需要则勿注册
- [ ] GroupMo 已设 coClass、moClass；按 activityGroup 取配置；登出 clear 路径正确
- [ ] 红点挂 Fn / GroupMo.updateRedDot；init 不抢跑依赖后端数据的红点；刷红点走 RedDotTask；兄弟页签独立 Fn 禁止互相 `addChild`（见 code-standards「红点挂载」）
- [ ] conf：Modules + Fns（FnId）+ Protos + 需要的 Wins/RedDots
- [ ] setCustomClass 只注册本包组件；公共组件不靠 Win 再注册
- [ ] MyFeatures 已更新（FGUI 包 / FnId）
```

---

## 规范联动

- 写/改任何 `.ts`：先 [code-standards](../code-standards/SKILL.md)。
- 触及 Laya / FGUI 引擎行为：[laya-fgui-engine-source](../laya-fgui-engine-source/SKILL.md)。
- 注册架构细节：[ARCHITECTURE.md](../laya-module-scaffold/ARCHITECTURE.md)。

---

## 反例（避免）

- 未选型就按旧 `CommonActData` 或硬套 X。
- Win 继承普通 `Win` 却当活动入口（丢倒计时 / ActFn 监听）。
- 在 Win 里直接刷协议状态，不经过 Data / GroupMo。
- Goal 与抽奖奖励共用同一 `getRewardShowMo` param。
- 把排行/公告硬塞进 CommonAct* 模板。
