---
title: 二分红蓝染色法---LeetCode153等
date: 2023-07-22 15:40:00
tags: [二分]
---
# 二分红蓝染色法系列---LeetCode153等
> 日期: 2023-07-22

二分的红蓝染色法主要用来解决寻找旋转数组里面的一些数的问题，旋转数组是一个前后有序但是总体不有序的数组，因此不能直接套二分来做，需要用来一些巧妙的方法（比如这里的红蓝染色法）来解决。

# 寻找峰值

## 题目描述

峰值元素是指其值严格大于左右相邻值的元素。

给你一个整数数组 nums，找到峰值元素并返回其索引。数组可能包含多个峰值，在这种情况下，返回 任何一个峰值 所在位置即可。

你可以假设 nums[-1] = nums[n] = -∞ 。

你必须实现时间复杂度为 O(log n) 的算法来解决此问题。

## 示例

```cpp
输出：2
解释：3 是峰值元素，你的函数应该返回其索引 2。
示例 2：

输入：nums = [1,2,1,3,5,6,4]
输出：1 或 5 
解释：你的函数可以返回索引 1，其峰值元素为 2；
     或者返回索引 5， 其峰值元素为 6。
```

## 解题思路

一般来说，红蓝染色法常用的做法是先去定义红色和蓝色的定义。

比如这道题红色的定义是峰值左边的点，蓝色的定义是**峰值以及峰值右边的点**。

一般来说，这样的定义可以保证最右边一定为蓝色，所以可以把二分的区间缩小到[0,n-2]。

这里是通过比较mid和mid+1位置的点来判断颜色，如果mid的值 > mid+1的值，那么右边肯定全部为蓝色，因为mid就有可能是峰值。否则左边全为红色。

```cpp
class Solution {
public:
    int findPeakElement(vector<int>& nums) {
        //红蓝染色法，对于可以确定颜色的区间就不再处理，一直去处理需要决定颜色的区间
        // 定义红色为峰值左边的点，蓝色为峰值右边或者峰值右边的点
        // 那么最右边一定为蓝色，不需要处理
        // 在 [0,n-2]二分
        int left = -1;
        int right = nums.size()-1;
        while(left + 1 < right){
            int mid = (left + right) /2 ;
            if(nums[mid] > nums[mid+1]){
                // 右边全为蓝色
                right = mid;
            }else{
                // 左边全为红色
                left = mid;
            }
        }
        return right;
    }
};
```



# 寻找旋转排序数组中的最小值(无重复数字)

## 题目描述

已知一个长度为 n 的数组，预先按照升序排列，经由 1 到 n 次 旋转 后，得到输入数组。例如，原数组 nums = [0,1,2,4,5,6,7] 在变化后可能得到：
若旋转 4 次，则可以得到 [4,5,6,7,0,1,2]
若旋转 7 次，则可以得到 [0,1,2,4,5,6,7]
注意，数组 [a[0], a[1], a[2], ..., a[n-1]] 旋转一次 的结果为数组 [a[n-1], a[0], a[1], a[2], ..., a[n-2]] 。

给你一个元素值 互不相同 的数组 nums ，它原来是一个升序排列的数组，并按上述情形进行了多次旋转。请你找出并返回数组中的 最小元素 。

你必须设计一个时间复杂度为 O(log n) 的算法解决此问题。

## 示例

```
示例 1：

输入：nums = [3,4,5,1,2]
输出：1
解释：原数组为 [1,2,3,4,5] ，旋转 3 次得到输入数组。
示例 2：

输入：nums = [4,5,6,7,0,1,2]
输出：0
解释：原数组为 [0,1,2,4,5,6,7] ，旋转 4 次得到输入数组。
示例 3：

输入：nums = [11,13,15,17]
输出：11
解释：原数组为 [11,13,15,17] ，旋转 4 次得到输入数组。

```



## 解题思路

一样的红蓝染色法解题。

首先可以确定的是最小值就是旋转点。

把红色定义为在旋转点左侧。

把蓝色定义为**旋转点或者在旋转点右侧**。

同样，最右边一定为蓝色，所以无需纳入考虑范围，在[0,n-2]进行二分。

将mid为最右边的值进行比较，如果mid的值比最右边的值大，那么最小值不可能在左边，所以左边全是红色。

否则右边全是蓝色。

```cpp
class Solution {
public:
    int findMin(vector<int>& nums) {
        //红色为旋转点左边
        //蓝色为旋转点或者旋转点右边
        // 因为最右边一定为蓝色，所以在[0,n-2]二分
        int left = -1;
        int right = nums.size()-1;
        while(left + 1 < right){
            int mid = (left + right) / 2;
            if(nums[mid] > nums[nums.size()-1]){
                left = mid;
            }else{
                right = mid;
            }
        }
        return nums[right];
    }
};
```



# 旋转数组的最小数字(有重复)

## 题目描述

把一个数组最开始的若干个元素搬到数组的末尾，我们称之为数组的旋转。

给你一个可能存在 重复 元素值的数组 numbers ，它原来是一个升序排列的数组，并按上述情形进行了一次旋转。请返回旋转数组的最小元素。例如，数组 [3,4,5,1,2] 为 [1,2,3,4,5] 的一次旋转，该数组的最小值为 1。  

注意，数组 [a[0], a[1], a[2], ..., a[n-1]] 旋转一次 的结果为数组 [a[n-1], a[0], a[1], a[2], ..., a[n-2]] 。

## 示例

```
示例 1：

输入：numbers = [3,4,5,1,2]
输出：1
示例 2：

输入：numbers = [2,2,2,0,1]
输出：0

```



## 解题思路

这道题和上一题唯一的区别在于有重复数字。

那么如果出现了枚举的mid的值和最右边的数字一样，就不知道该如何判断了。

这里我们的做法是如果一样，那么就right--，不去比较了，这样做也是合理的。

因为如果数字这个值就是最小值，那么--后区间内还存在这个值，不影响。

如果这个值不是最小值，那更无所谓了。

```cpp
class Solution {
public:
    int minArray(vector<int>& numbers) {
        //二分
        // 蓝色表示是最小数字或者在最小数字右侧
        // 红色表示在最小数字左侧
        // 因为最右边一定是蓝色，所以在[0,n-2]二分
        int left = -1;
        int right = numbers.size()-1;
        while(left + 1 < right){
            int mid = (left + right) / 2;
            if(numbers[mid] > numbers[right]){
                left = mid;
            }else if(numbers[mid] < numbers[right]){
                right = mid;
            }else{
                right -= 1; //去除末尾元素
            }
        }
        return numbers[right];
    }
};

```

要注意这里是和`numbers[right]`来比较了而不是之前的`numbers[numbers.size()-1]`

## 题目链接

[162. 寻找峰值 - 力扣（LeetCode）](https://leetcode.cn/problems/find-peak-element/)

[153. 寻找旋转排序数组中的最小值 - 力扣（LeetCode）](https://leetcode.cn/problems/find-minimum-in-rotated-sorted-array/)

[剑指 Offer 11. 旋转数组的最小数字 - 力扣（LeetCode）](https://leetcode.cn/problems/xuan-zhuan-shu-zu-de-zui-xiao-shu-zi-lcof/)

[二分查找，一个视频讲透！（Python/Java/C++/Go） - 旋转数组的最小数字 - 力扣（LeetCode）](https://leetcode.cn/problems/xuan-zhuan-shu-zu-de-zui-xiao-shu-zi-lcof/solution/er-fen-cha-zhao-yi-ge-shi-pin-jiang-tou-1kbvh/)