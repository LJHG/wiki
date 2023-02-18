---
title: 组合总和 Ⅳ---LeetCode377(完全背包变体)
date: 2023-02-18 13:28:07
tags: [dp]
---
# 组合总和 Ⅳ---LeetCode377(完全背包变体)
> 日期: 2023-02-18

## 题目描述
给你一个由 不同 整数组成的数组 nums ，和一个目标整数 target 。请你从 nums 中找出并返回总和为 target 的元素组合的个数。

题目数据保证答案符合 32 位整数范围。
    
## 示例

```
输入：nums = [1,2,3], target = 4
输出：7
解释：
所有可能的组合为：
(1, 1, 1, 1)
(1, 1, 2)
(1, 2, 1)
(1, 3)
(2, 1, 1)
(2, 2)
(3, 1)
请注意，顺序不同的序列被视作不同的组合。
```

```
输入：nums = [9], target = 3
输出：0
```



## 解题思路

这道题是完全背包的变种。

题目中提到，不同的序列被视作不同的组合，但是传统的完全背包是没有考虑这个问题的。等于说一般的完全背包不考虑顺序，解决的是组合问题。这里解决的是排列问题。

修改的方法也很简单，只需要将两层循环的顺序调换一下即可：

```cpp
class Solution {
public:
    int combinationSum4(vector<int>& nums, int target) {
        //多重背包
        int dp[1010]; //dp[i]表示容量为i的背包的组合数
        memset(dp,0,sizeof(dp));
        dp[0] = 1;
        for(int j=0;j<=target;j++){
            for(int i=0;i<nums.size();i++){
                if(j >= nums[i] && dp[j] < INT_MAX - dp[j-nums[i]]){
                    dp[j] += dp[j-nums[i]];
                }
            }
        }
        
        return dp[target];
        
    }
};
```

之前我在[LeetCode518 · GitBook (ljhblog.top)](https://www.ljhblog.top/algorithms/LeetCode/LeetCode518.html)里面说完全背包的循环顺序是无所谓的，其实好像并不太对。对于这种 `dp[i] += dp[i-nums[j]]`形式的递推公式好像还是有影响的，只不过对于那种 `dp[i] = max(dp[i], dp[i-nums[j]]+ value[j])`形式的应该是没有影响的。

## 题目链接

[377. 组合总和 Ⅳ - 力扣（LeetCode）](https://leetcode.cn/problems/combination-sum-iv/)