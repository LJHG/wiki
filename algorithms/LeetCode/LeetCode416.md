---
title: 分割等和子集---LeetCode416(其实是背包问题)
date: 2023-02-15 21:00:08
tags: [dp]
---
# 分割等和子集---LeetCode416(其实是背包问题)
> 日期: 2023-02-15

## 题目描述
给你一个 只包含正整数 的 非空 数组 nums 。请你判断是否可以将这个数组分割成两个子集，使得两个子集的元素和相等。

## 示例

```
输入：nums = [1,5,11,5]
输出：true
解释：数组可以分割成 [1, 5, 5] 和 [11] 。
```

```
输入：nums = [1,2,3,5]
输出：false
解释：数组不能分割成两个元素和相等的子集。
```



## 解题思路

这道题我一来并没有意识到这是一道dp题，更没有意识到这是背包问题。

首先要把问题转换为，两个子集元素和相等 -> 有一个子集元素和为 sum/2。

然后就是要从这个数组里面挑选一些元素，使其和为sum/2，这就变成一个背包问题了，重量为nums[i]，价值也为nums[i]。

最后就判断一下 dp[sum/2] == sum/2就行了。

这里用一维背包来做

```cpp
class Solution {
public:
    bool canPartition(vector<int>& nums) {
        int sum = 0; 
        for(auto x:nums){
            sum += x;
        }
        if(sum % 2 == 1) return false;
        int target = sum/2;
        //一维背包
        int dp[10010]; //dp[j]表示容量为j的背包的最大价值, 重量是nums[i],价值也是nums[i]
        memset(dp,0,sizeof(dp));
        for(int i=0;i<nums.size();i++){
            for(int j=target;j>=nums[i];j--){
                dp[j] = max(dp[j], dp[j-nums[i]] + nums[i]);
            }
        }
        return dp[target] == target;
    }
};
```



## 题目链接

[416. 分割等和子集 - 力扣（LeetCode）](https://leetcode.cn/problems/partition-equal-subset-sum/)