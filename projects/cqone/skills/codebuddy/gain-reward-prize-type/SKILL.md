---
name: gain-reward-prize-type
description: >-
  Implements or reviews cqone GainRewardItem.vPrizeType and rare-reward logic
  in gainReward or activity ShowRule/SortRule TypeScript. Use when handling
  vPrizeType, configIdArr, ifSpecialReward, big-prize or rare-reward badges.
---

# 恭喜获得奖励角标

在 `ShowRuleBase.updateRewardItem` 设置 `GainRewardItem.vPrizeType` 时，使用协议的奖池配置 ID 决定角标，不从掉落包或最终道具 ID 推断。

1. 以 `mo.srcIdx` 取 `GainRewardMo.configIdArr`；无效时回退列表 `idx`。
2. 用该 `configId` 读取对应奖励配置表的业务字段，例如 `ifSpecialReward`、`rewardTitle` 或 `ifBigPrize`。
3. 将该字段映射到 `item.vPrizeType.selectedIndex`。`RewardItem` 的 index `1` 是大奖，`2` 是稀有，`3` 是幸运。
4. 需要 `GainRareRewardView` 时，`SortRule.filterRare` 同样按 `configIdArr` 与配置字段判断；不需要时不注册该过滤规则。

禁止按结算道具 ID 反查掉落包，也不要以 `reward` 字段的本地缓存判断奖励等级。

可参考 `SummerTreasureShowRule`、`DragonTreasureShowRule`、`TurnTableShowRule` 和 `LuckyTreasureShowRule`；稀有弹窗参考 `XiangongTreasureSortRule`、`AppraiseTreeSortRule`。
