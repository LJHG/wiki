---
title: 打家劫舍 IV---LeetCode2560(二分+dp)
date: 2023-02-28 15:32:41
tags: [二分,dp]
---
# 打家劫舍 IV---LeetCode2560(二分+dp)
> 日期: 2023-02-28

## 题目描述

沿街有一排连续的房屋。每间房屋内都藏有一定的现金。现在有一位小偷计划从这些房屋中窃取现金。

由于相邻的房屋装有相互连通的防盗系统，所以小偷 不会窃取相邻的房屋 。

小偷的 窃取能力 定义为他在窃取过程中能从单间房屋中窃取的 最大金额 。

给你一个整数数组 nums 表示每间房屋存放的现金金额。形式上，从左起第 i 间房屋中放有 nums[i] 美元。

另给你一个整数 k ，表示窃贼将会窃取的 最少 房屋数。小偷总能窃取至少 k 间房屋。

返回小偷的 最小 窃取能力。

## 示例

```
输入：nums = [2,3,5,9], k = 2
输出：5
解释：
小偷窃取至少 2 间房屋，共有 3 种方式：
- 窃取下标 0 和 2 处的房屋，窃取能力为 max(nums[0], nums[2]) = 5 。
- 窃取下标 0 和 3 处的房屋，窃取能力为 max(nums[0], nums[3]) = 9 。
- 窃取下标 1 和 3 处的房屋，窃取能力为 max(nums[1], nums[3]) = 9 。
因此，返回 min(5, 9, 9) = 5 。
```



## 解题思路

将题目转换为先寻找一个最小窃取能力，然后用dp去验证这个最小窃取能力是否是可行的。

找最小窃取能力的过程是二分。

一般这种最小最大或者最大最小问题都会涉及到二分。

```c++
class Solution {
public:

    int dp[100005]; //dp[i]表示前i个房子里面最多可以偷多少个房子
    
    // check这个最大值是否是可行的
    int check(vector<int> nums, int mx){
        int len = nums.size();
        memset(dp,0,sizeof(dp));
        dp[0] = (nums[0] <= mx);
        dp[1] = (nums[0] <= mx || nums[1] <= mx);
        for(int i=2;i<nums.size();i++){
            dp[i] = dp[i-1];
            if(nums[i] <= mx){
                dp[i] = max(dp[i], dp[i-2] + 1);
            }
        }
        return dp[len-1];
    }
    int minCapability(vector<int>& nums, int k) {
        if(nums.size() == 1) return nums[0];
        int mxLeft = 0;
        int mxRight = 0;
        for(int x:nums) mxRight = max(mxRight, x);
        mxRight += 1;
        while(mxLeft + 1 < mxRight){
            int mid = (mxLeft + mxRight) /2;
            int val = check(nums,mid);
            if(val < k){
                mxLeft = mid;
            }else{
                mxRight = mid;
            }
        }
        return mxLeft +1;
    }
};
```





## 题目链接

[2560. 打家劫舍 IV - 力扣（LeetCode）](https://leetcode.cn/problems/house-robber-iv/)