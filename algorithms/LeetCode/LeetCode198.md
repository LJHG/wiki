---
title: 打家劫舍 I&II---LeetCode198&213
date: 2023-02-24 11:01:50
tags: []
---
# 打家劫舍 I&II---LeetCode198&213
> 日期: 2023-02-24

## 题目描述
你是一个专业的小偷，计划偷窃沿街的房屋。每间房内都藏有一定的现金，影响你偷窃的唯一制约因素就是相邻的房屋装有相互连通的防盗系统，如果两间相邻的房屋在同一晚上被小偷闯入，系统会自动报警。

给定一个代表每个房屋存放金额的非负整数数组，计算你 不触动警报装置的情况下 ，一夜之内能够偷窃到的最高金额。

## 示例

```
输入：[1,2,3,1]
输出：4
解释：偷窃 1 号房屋 (金额 = 1) ，然后偷窃 3 号房屋 (金额 = 3)。
     偷窃到的最高金额 = 1 + 3 = 4 。
```

```
输入：[2,7,9,3,1]
输出：12
解释：偷窃 1 号房屋 (金额 = 2), 偷窃 3 号房屋 (金额 = 9)，接着偷窃 5 号房屋 (金额 = 1)。
     偷窃到的最高金额 = 2 + 9 + 1 = 12 。
```



## 解题思路

### 打家劫舍I

对于最基础的打家劫舍，非常简单：

```cpp
class Solution {
public:
    int rob(vector<int>& nums) {
        if(nums.size() == 1) return nums[0];
        int dp[110];
        memset(dp,0,sizeof(dp));
        dp[0] = nums[0];
        dp[1] = max(nums[0],nums[1]);
        for(int i=2;i<nums.size();i++){
            dp[i] = max(nums[i] + dp[i-2], dp[i-1]);
        }
        return dp[nums.size()-1];
    }
};
```



### 打家劫舍II

打家劫舍II在I的基础上做了改动，将数据变成了一个首尾相接的环：

```
你是一个专业的小偷，计划偷窃沿街的房屋，每间房内都藏有一定的现金。这个地方所有的房屋都 围成一圈 ，这意味着第一个房屋和最后一个房屋是紧挨着的。同时，相邻的房屋装有相互连通的防盗系统，如果两间相邻的房屋在同一晚上被小偷闯入，系统会自动报警 。

给定一个代表每个房屋存放金额的非负整数数组，计算你 在不触动警报装置的情况下 ，今晚能够偷窃到的最高金额。

```

```
输入：nums = [2,3,2]
输出：3
解释：你不能先偷窃 1 号房屋（金额 = 2），然后偷窃 3 号房屋（金额 = 2）, 因为他们是相邻的。

输入：nums = [1,2,3,1]
输出：4
解释：你可以先偷窃 1 号房屋（金额 = 1），然后偷窃 3 号房屋（金额 = 3）。
     偷窃到的最高金额 = 1 + 3 = 4 。
```

对于这种情况其实比较难处理，最开始我还想过使用求模的方式来算，但是后来好像行不通。

正解是将原问题转为两个数组来做，因为第一个元素和最后一个元素是不可能同时取的，所以可以想列表划分为 [0, len-2], [1, len-1]两个来做，然后取最大值。

这里将原打家劫舍问题抽离为了`robRange`函数，然后在`rob`里调了两次

```cpp
class Solution {
public:
    int rob(vector<int>& nums) {
        int len = nums.size();
        if(len == 1) return nums[0];
        int a = robRange(nums,0,len-2);
        int b = robRange(nums,1,len-1);
        return max(a,b);      
    }

    int robRange(vector<int>& nums, int start, int end){
        if(start == end) return nums[start];
        int dp[110];
        memset(dp,0,sizeof(dp));
        dp[start] = nums[start];
        dp[start+1] = max(nums[start],nums[start+1]);
        for(int i=start+2;i<=end;i++){
            dp[i] = max(nums[i] + dp[i-2], dp[i-1]);
        }
        return dp[end];
    }
};
```



## 题目链接

[198. 打家劫舍 - 力扣（LeetCode）](https://leetcode.cn/problems/house-robber/)

[213. 打家劫舍 II - 力扣（LeetCode）](https://leetcode.cn/problems/house-robber-ii/)