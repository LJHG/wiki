---
title: 零钱兑换---LeetCode322(完全背包)
date: 2023-04-01 16:28:15
tags: [dp]
---
# 零钱兑换---LeetCode322(完全背包)
> 日期: 2023-04-01

## 题目描述

给你一个整数数组 coins ，表示不同面额的硬币；以及一个整数 amount ，表示总金额。

计算并返回可以凑成总金额所需的 最少的硬币个数 。如果没有任何一种硬币组合能组成总金额，返回 -1 。

你可以认为每种硬币的数量是无限的。

## 示例

```
示例 1：

输入：coins = [1, 2, 5], amount = 11
输出：3 
解释：11 = 5 + 5 + 1
示例 2：

输入：coins = [2], amount = 3
输出：-1
示例 3：

输入：coins = [1], amount = 0
输出：0
```



## 解题思路

### 错误示范

不知道为什么，看到这道题，虽然dp数组定义对了，但是一来就写了一个三重循环。

中间我多搞了一个循环，来表示当前要选几个这种硬币，没毛病，但没必要，主要是多了重复计算。

```cpp
class Solution {
public:
    int coinChange(vector<int>& coins, int amount) {
        vector<int> dp(10001, 1e9 + 7); //dp[i]表示i的钱所需要硬币的最小数量
        int len = coins.size();
        dp[0] = 0;
        for(int i=1; i<=amount; i++){
            for(int j=0;j<len;j++){
                int n = 1;
                int curVal = coins[j];
                while(i - curVal*n >= 0){
                    dp[i] = min(dp[i], dp[i-curVal*n] + n);
                    n += 1;
                }
            }
        }
        if(dp[amount] == 1e9 + 7) return -1;
        return dp[amount];
        
    }
};
```



### 正确dp

其实里面那个while循环是完全没必要的，对于每一个值，我只需要考虑取某一种硬币一次即可，因为减了后的那个值会再去考虑相同的问题，就解决了一个硬币取多次的问题。

```cpp
class Solution {
public:
    int coinChange(vector<int>& coins, int amount) {
        vector<int> dp(10001, 1e9 + 7); //dp[i]表示i的钱所需要硬币的最小数量
        int len = coins.size();
        dp[0] = 0;
        for(int i=1; i<=amount; i++){
            for(int j=0;j<coins.size();j++){
                if(i >= coins[j]){
                    dp[i] = min(dp[i], dp[i-coins[j]] + 1);
                }
            }
        }
        if(dp[amount] == 1e9 + 7) return -1;
        return dp[amount];
        
    }
};
```



## 题目链接

[322. 零钱兑换 - 力扣（LeetCode）](https://leetcode.cn/problems/coin-change/)