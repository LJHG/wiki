---
title: 零钱兑换 II---LeetCode518(完全背包)
date: 2023-02-16 17:55:52
tags: []
---
# 零钱兑换 II---LeetCode518(完全背包)
> 日期: 2023-02-16

## 题目描述

给你一个整数数组 coins 表示不同面额的硬币，另给一个整数 amount 表示总金额。

请你计算并返回可以凑成总金额的硬币组合数。如果任何硬币组合都无法凑出总金额，返回 0 。

假设每一种面额的硬币有无限个。 

题目数据保证结果符合 32 位带符号整数。

## 示例

```
输入：amount = 5, coins = [1, 2, 5]
输出：4
解释：有四种方式可以凑成总金额：
5=5
5=2+2+1
5=2+1+1+1
5=1+1+1+1+1

```

```
输入：amount = 3, coins = [2]
输出：0
解释：只用面额 2 的硬币不能凑成总金额 3 。
```

```
输入：amount = 10, coins = [10] 
输出：1
```

## 解题思路

这道题是完全背包问题，完全背包问题和01背包问题的区别在于：

1. 完全背包问题的两层循环没有要求，都可。

   > 应该是对于 dp[i] = max(dp[i], dp[i-weight[j]] + value[j])形式没有要求
   >
   > 对于 dp[i] += dp[i-nums[j]] 这种循环的顺序还是有讲究的
2. 完全背包问题在遍历容量时，需要正向遍历。

所以可以把这道题的代码写为如下：

```cpp
class Solution {
public:
    int change(int amount, vector<int>& coins) {
        //完全背包
        int dp[5010];
        memset(dp,0,sizeof(dp));
        dp[0] = 1;
        for(int i=0;i<coins.size();i++){
            for(int j=coins[i];j<=amount;j++) //完全背包可以正向遍历
            {
                dp[j] += dp[j-coins[i]];
            }
        }
        return dp[amount];
    }
};
```

这里还是要稍微注意一下递推公式，这里又是+=形式的递推公式，就和[LeetCode491 · 目标和](https://www.ljhblog.top/algorithms/LeetCode/LeetCode494.html)一样。

这道题和[LeetCode491 · 目标和](https://www.ljhblog.top/algorithms/LeetCode/LeetCode494.html)一样，dp[i]的意义都是当容量为i时有几种装法，而不是容量为i的最大价值。这一点要注意一下，感觉比较容易混淆。

> 感觉如果题目出现了组合数这种字眼，那么一半就是 += 这种情况吧。



## 题目链接

[518. 零钱兑换 II - 力扣（LeetCode）](https://leetcode.cn/problems/coin-change-ii/)