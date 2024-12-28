---
title: 盛最多水的容器---LeetCode11(贪心双指针)
date: 2022-09-28 15:03:48
tags: [贪心,双指针]
---
# 盛最多水的容器---LeetCode11(贪心双指针)
> 日期: 2022-09-28

## 题目描述

给定一个长度为 n 的整数数组 height 。有 n 条垂线，第 i 条线的两个端点是 (i, 0) 和 (i, height[i]) 。

找出其中的两条线，使得它们与 x 轴共同构成的容器可以容纳最多的水。

返回容器可以储存的最大水量。

说明：你不能倾斜容器。

## 示例

```
输入：[1,8,6,2,5,4,8,3,7]
输出：49 
解释：图中垂直线代表输入数组 [1,8,6,2,5,4,8,3,7]。在此情况下，容器能够容纳水（表示为蓝色部分）的最大值为 49。

```



<img src="https://aliyun-lc-upload.oss-cn-hangzhou.aliyuncs.com/aliyun-lc-upload/uploads/2018/07/25/question_11.jpg" alt="img" style="zoom:50%;" />



## 解题思路

这道题是贪心，用两个位置来表示区间，并且判断左右两边的大小，并且移动小的那一边。

这个方法很好想，好像可以通过反证法去证明它不是错的。。。

至于dp，这道题差点我又dp了，但是一看数据范围开不了二维dp，那也dp不了了。

```cpp
class Solution {
public:
    int maxArea(vector<int>& height) {
        //长度太大，不能dp
        int len = height.size();
        int left = 0;
        int right = len-1;
        int ans = 0;
        while(left < right){
            ans = max((right-left)*min(height[left],height[right]),ans);
            if(height[left] > height[right]){
                right -= 1;
            }else{
                left += 1;
            }
        }
        return ans;
    }
};
```

## 题目链接

[11. 盛最多水的容器 - 力扣（LeetCode）](https://leetcode.cn/problems/container-with-most-water/)