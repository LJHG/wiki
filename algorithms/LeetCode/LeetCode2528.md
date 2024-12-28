---
title: 二分枚举答案判定系列---LeetCode2528等
date: 2023-03-08 21:22:31
tags: [二分]
---
# 二分枚举答案判定系列---LeetCode2528等
> 日期: 2023-03-08

## 题目1 最大化城市的最小供电站数目

### 题目描述

给你一个下标从 0 开始长度为 n 的整数数组 stations ，其中 stations[i] 表示第 i 座城市的供电站数目。

每个供电站可以在一定 范围 内给所有城市提供电力。换句话说，如果给定的范围是 r ，在城市 i 处的供电站可以给所有满足 |i - j| <= r 且 0 <= i, j <= n - 1 的城市 j 供电。

|x| 表示 x 的 绝对值 。比方说，|7 - 5| = 2 ，|3 - 10| = 7 。
一座城市的 电量 是所有能给它供电的供电站数目。

政府批准了可以额外建造 k 座供电站，你需要决定这些供电站分别应该建在哪里，这些供电站与已经存在的供电站有相同的供电范围。

给你两个整数 r 和 k ，如果以最优策略建造额外的发电站，返回所有城市中，最小供电站数目的最大值是多少。

这 k 座供电站可以建在多个城市。

### 示例

```
输入：stations = [1,2,4,5,0], r = 1, k = 2
输出：5
解释：
最优方案之一是把 2 座供电站都建在城市 1 。
每座城市的供电站数目分别为 [1,4,4,5,0] 。
- 城市 0 的供电站数目为 1 + 4 = 5 。
- 城市 1 的供电站数目为 1 + 4 + 4 = 9 。
- 城市 2 的供电站数目为 4 + 4 + 5 = 13 。
- 城市 3 的供电站数目为 5 + 4 = 9 。
- 城市 4 的供电站数目为 5 + 0 = 5 。
供电站数目最少是 5 。
无法得到更优解，所以我们返回 5 。
```

```
输入：stations = [4,4,4,4], r = 0, k = 3
输出：4
解释：
无论如何安排，总有一座城市的供电站数目是 4 ，所以最优解是 4 。
```

### 解题思路

看到最大最小或者最小最大，就想是二分枚举答案然后判断是否可行。

这道题还比较麻烦，因为每一个供电站会覆盖一定的范围，所以还需要用到前缀和和差分。

因为**这道题的答案要尽可能大**，所以**当check满足时是把left更新，同时最后返回的是left**。

```c++
class Solution {
public:
    vector<long long> diff;
    vector<long long> power;
    int K;
    int R;
    //判断 minPow这个答案是否可行
    bool check(long long minPow){
        diff = vector<long long>(power.size(),0);
        int curK = 0;
        long long sum_d = 0;
        //开始从左往右枚举
        for(int i=0;i<power.size();i++){
            sum_d += diff[i];
            long long m = minPow - power[i] - sum_d;
            if(m > 0){
                //选取位置放置发电站，在i处放置m个发电站，但是diff[i]不需要更新了，因为是用sum_d来维护的
                curK += m;
                if(curK > K) return false;
                sum_d += m;
                if(i + 2*R + 1 < diff.size())
                    diff[i + 2*R + 1] -= m; //更新差分
            }
        }
        return true;
    }

    long long maxPower(vector<int>& stations, int r, int k) {
        // 二分 + 贪心 + 前缀和 + 差分
        long long ans = 0;
        K = k;
        R = r;
        int len = stations.size();
        vector<long long> pre(len+1,0);
        //计算前缀和
        for(int i=0;i<len;i++){
            pre[i+1] = pre[i] + stations[i];
        }
        //根据前缀和快速计算每一个站点目前的电量
        power = vector<long long>(len,0);
        for(int i=0;i<len;i++){
            power[i] = pre[min(i + r + 1, len)] - pre[ max(0,i - r)];
        }

        //二分枚举答案
        //左开右开
        
        long long left = -1;
        long long right = pre[len] + k + 1;
        while(left + 1 < right){
            long long mid = left + (right - left) / 2;
            if(check(mid)) left = mid;
            else right = mid;
        }

        return left;        
        
    }
};

```



### 题目链接

[2528. 最大化城市的最小供电站数目 - 力扣（LeetCode）](https://leetcode.cn/problems/maximize-the-minimum-powered-city/)



## 题目2 最小化数组中的最大值

### 题目描述

给你一个下标从 0 开始的数组 nums ，它含有 n 个非负整数。

每一步操作中，你需要：

选择一个满足 1 <= i < n 的整数 i ，且 nums[i] > 0 。
将 nums[i] 减 1 。
将 nums[i - 1] 加 1 。
你可以对数组执行 任意 次上述操作，请你返回可以得到的 nums 数组中 最大值 最小 为多少。



### 示例

```
输入：nums = [3,7,1,6]
输出：5
解释：
一串最优操作是：
1. 选择 i = 1 ，nums 变为 [4,6,1,6] 。
2. 选择 i = 3 ，nums 变为 [4,6,2,5] 。
3. 选择 i = 1 ，nums 变为 [5,5,2,5] 。
nums 中最大值为 5 。无法得到比 5 更小的最大值。
所以我们返回 5 。
```



### 解题思路

因为**这道题的答案要尽可能小，所以check满足时是把right设置为mid**

```c++
class Solution {
public:
    int minimizeArrayValue(vector<int>& nums) {
        int len = nums.size();
        //判断答案是否可行
        auto check = [&](int num) -> bool{ 
            long long increment = 0;
            for(int i=nums.size()-1;i>=0;i--){
                long long m = nums[i] + increment - num;
                if( m > 0){
                    increment = m;
                }else{
                    increment = 0;
                }
            }
            return increment == 0;
        };
        int maxVal = 0;
        for(int x:nums){
            maxVal = max(maxVal,x);
        }
        int left = -1;
        int right = maxVal + 1;
        while(left +1 < right){
            int mid = (left + right) / 2;
            if(check(mid)) right = mid;
            else left = mid;
        }
        return right;
    }
};
```

### 题目链接

[2439. 最小化数组中的最大值 - 力扣（LeetCode）](https://leetcode.cn/problems/minimize-maximum-of-array/)



## 题目3 最小化两个数组中的最大值

### 题目描述

给你两个数组 arr1 和 arr2 ，它们一开始都是空的。你需要往它们中添加正整数，使它们满足以下条件：

arr1 包含 uniqueCnt1 个 互不相同 的正整数，每个整数都 不能 被 divisor1 整除 。
arr2 包含 uniqueCnt2 个 互不相同 的正整数，每个整数都 不能 被 divisor2 整除 。
arr1 和 arr2 中的元素 互不相同 。
给你 divisor1 ，divisor2 ，uniqueCnt1 和 uniqueCnt2 ，请你返回两个数组中 最大元素 的 最小值 。

### 示例

```c++
输入：divisor1 = 2, divisor2 = 7, uniqueCnt1 = 1, uniqueCnt2 = 3
输出：4
解释：
我们可以把前 4 个自然数划分到 arr1 和 arr2 中。
arr1 = [1] 和 arr2 = [2,3,4] 。
可以看出两个数组都满足条件。
最大值是 4 ，所以返回 4 。
```

### 解题思路

因为**这道题的答案要尽可能小，所以check满足时更新right，同时最后返回也是right**。

同时这道题涉及到求最大公约数(辗转相除法)和最小公倍数。

```c++
class Solution {
public:
    long long gcd(int a, int b){
        return b == 0 ? a : gcd(b, a % b);
    }
    long long lcm(int a, int b){
        return (long long) a / gcd(a,b) * b;
    }

    int minimizeSet(int divisor1, int divisor2, int uniqueCnt1, int uniqueCnt2) {
        long long _lcm = lcm(divisor1,divisor2);
        auto check = [&](int num) -> bool{    
            long long left1 = max((long long)0, (long long)uniqueCnt1 - (num/divisor2 - num/_lcm));
            long long left2 = max((long long)0, (long long)uniqueCnt2 - (num/divisor1 - num/_lcm));
            long long common = num - num/divisor1 - num/divisor2 + num/_lcm;
            return common >= (left1 + left2);
        };
        long long left = 0;
        long long right = (uniqueCnt1 + uniqueCnt2) * 2;
        while(left +1 < right){
            long long mid = (left + right)/2;
            if(check(mid)) right = mid;
            else left = mid;
        }
        return right;
    }
};
```

### 题目链接

[2513. 最小化两个数组中的最大值 - 力扣（LeetCode）](https://leetcode.cn/problems/minimize-the-maximum-of-two-arrays/)



## 总结

总的来说，在二分找答案时，根据题目条件来判断怎么更新和返回什么。

如果结果要尽可能小，那么就是

```c++
while(left +1 < right){
    long long mid = (left + right)/2;
    if(check(mid)) right = mid;
    else left = mid;
}
		return right;
```

如果结果要尽可能大，那么就是

```c++
while(left +1 < right){
    long long mid = (left + right)/2;
    if(check(mid)) left = mid;
    else right = mid;
}
		return left;
```

返回的就是check满足时更新的那个值。