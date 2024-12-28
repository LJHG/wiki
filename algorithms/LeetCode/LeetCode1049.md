---
title: 最后一块石头的重量 II---(还是背包)
date: 2023-02-15 21:55:48
tags: [dp]
---
# 最后一块石头的重量 II---(还是背包)
> 日期: 2023-02-15

## 题目描述

有一堆石头，用整数数组 stones 表示。其中 stones[i] 表示第 i 块石头的重量。

每一回合，从中选出任意两块石头，然后将它们一起粉碎。假设石头的重量分别为 x 和 y，且 x <= y。那么粉碎的可能结果如下：

如果 x == y，那么两块石头都会被完全粉碎；
如果 x != y，那么重量为 x 的石头将会完全粉碎，而重量为 y 的石头新重量为 y-x。
最后，最多只会剩下一块 石头。返回此石头 最小的可能重量 。如果没有石头剩下，就返回 0。

## 示例

```
输入：stones = [2,7,4,1,8,1]
输出：1
解释：
组合 2 和 4，得到 2，所以数组转化为 [2,7,1,8,1]，
组合 7 和 8，得到 1，所以数组转化为 [2,1,1,1]，
组合 2 和 1，得到 1，所以数组转化为 [1,1,1]，
组合 1 和 1，得到 0，所以数组转化为 [1]，这就是最优值。

```

```
输入：stones = [31,26,33,21,40]
输出：5
```



## 解题思路

这道题和[416. 分割等和子集 - 力扣（LeetCode）](https://leetcode.cn/problems/partition-equal-subset-sum/)差不多，稍微分析一下就会发现，这道题也是尽量把这堆石头分为相等的两份。

```cpp
class Solution {
public:
    int lastStoneWeightII(vector<int>& stones) {
        //感觉像是将石头分为尽可能均等的两份
        //[2,7,4,1,8,1] -> [2,8,1] [4,7,1]
        //[31,26,33,21,40] -> [21,26,31] [33,40]
        // 感觉和 https://leetcode.cn/problems/partition-equal-subset-sum/ 差不多
        int sum = 0;
        for(int x:stones){
            sum += x;
        }
        int target = sum/2;
        int dp[3090];
        for(int i=0;i<3090;i++) dp[i] = 0;
        for(int i=0;i<stones.size();i++){
            for(int j=target;j>=stones[i];j--){
                dp[j] = max(dp[j], dp[j-stones[i]] + stones[i]);
            }
        }

        return sum-dp[target]-dp[target];
        
    }
};
```

这里再明确一下dp[i]的意义，它的意思是背包容量为i时的最大价值，因为这里价值就是重量，那么意思就是背包容量为i时的最大重量，也就是说dp[i]的值是不会比i大的。

因为我们的目标是尽量对半分，所以最好的情况就是 dp[target] == target，如果不是的话，那么少的那一半的重量dp[target], 所以多的那一半就是 sum - dp[target]，所以最后返回的结果是 (sum - dp[target]) - dp[target]。



## 题目链接

[1049. 最后一块石头的重量 II - 力扣（LeetCode）](https://leetcode.cn/problems/last-stone-weight-ii/)