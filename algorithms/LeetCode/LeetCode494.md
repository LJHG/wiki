---
title: 目标和---LeetCode49(不太典型的背包)
date: 2023-02-16 14:32:09
tags: [dp]
---
# 目标和---LeetCode49(不太典型的背包)
> 日期: 2023-02-16

## 题目描述

给你一个整数数组 nums 和一个整数 target 。

向数组中的每个整数前添加 '+' 或 '-' ，然后串联起所有整数，可以构造一个 表达式 ：

例如，nums = [2, 1] ，可以在 2 之前添加 '+' ，在 1 之前添加 '-' ，然后串联起来得到表达式 "+2-1" 。
返回可以通过上述方法构造的、运算结果等于 target 的不同 表达式 的数目。

## 示例

```
输入：nums = [1,1,1,1,1], target = 3
输出：5
解释：一共有 5 种方法让最终目标和为 3 。
-1 + 1 + 1 + 1 + 1 = 3
+1 - 1 + 1 + 1 + 1 = 3
+1 + 1 - 1 + 1 + 1 = 3
+1 + 1 + 1 - 1 + 1 = 3
+1 + 1 + 1 + 1 - 1 = 3
```

```
输入：nums = [1], target = 1
输出：1
```



## 解题思路

首先还是要意识到这道题是一个背包问题。其实问题可以转换为 

```
sum(pos) - sum(neg) = target
```

同时

```
sum(pos) + sum(neg) = sum
```

于是可以把等式转换为

```
2 * sum(pos) = sum + target
```

> 这里可以看出 sum + target一定需要是一个正偶数

所以

```
sum(pos) = (sum + target)/2
```

然后我们就把sum(pos)作为背包问题的背包容量，这里记为 bagSize。



同时，要注意一下这里的递推公式，最开始我以为这么一转换就可以直接套背包问题的板子了，其实不是的，因为dp的意义不同。

传统的背包问题的dp[i]表示容量为i时候的最大价值，这里的dp[i]表示的是容量为i的装法。`其实感觉这么一描述应该不算是背包问题了`

于是递推同时就应该为:

```
dp[i] = dp[i-nums[j]]
```

代码：

```cpp
class Solution {
public:
    int findTargetSumWays(vector<int>& nums, int target) {
        int dp[1010]; //dp[i]表示和为i的数量
        memset(dp,0,sizeof(dp));
        int sum = 0;
        for(int x:nums){
            sum +=x;
        }

        int bagSize = (target + sum)/2; //正数的值，转换为背包问题
        if( (target + sum) %2 == 1) return 0; // target + sum 一定是一个正偶数
        if( abs(target) > sum ) return 0;

        dp[0] = 1;
        
        for(int i=0;i<nums.size();i++){
            for(int j=bagSize;j>=nums[i];j--){
                dp[j] += dp[j-nums[i]];
            }
        }

        return dp[bagSize];
    

    }
};
```

## 题目链接

[494. 目标和 - 力扣（LeetCode）](https://leetcode.cn/problems/target-sum/)