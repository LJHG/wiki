---
title: 美丽塔---LeetCode2866(单调栈)
date: 2023-09-26 17:08:28
tags: [单调栈]
---
# 美丽塔---LeetCode2866(单调栈)
> 日期: 2023-09-26

## 题目描述

给你一个长度为 `n` 下标从 **0** 开始的整数数组 `maxHeights` 。

你的任务是在坐标轴上建 `n` 座塔。第 `i` 座塔的下标为 `i` ，高度为 `heights[i]` 。

如果以下条件满足，我们称这些塔是 **美丽** 的：

1. `1 <= heights[i] <= maxHeights[i]`
2. `heights` 是一个 **山状** 数组。

如果存在下标 `i` 满足以下条件，那么我们称数组 `heights` 是一个 **山状** 数组：

- 对于所有 `0 < j <= i` ，都有 `heights[j - 1] <= heights[j]`
- 对于所有 `i <= k < n - 1` ，都有 `heights[k + 1] <= heights[k]`

请你返回满足 **美丽塔** 要求的方案中，**高度和的最大值** 。

## 示例

```
输入：maxHeights = [5,3,4,1,1]
输出：13
解释：和最大的美丽塔方案为 heights = [5,3,3,1,1] ，这是一个美丽塔方案，因为：
- 1 <= heights[i] <= maxHeights[i]  
- heights 是个山状数组，峰值在 i = 0 处。
13 是所有美丽塔方案中的最大高度和。
```

```cpp
输入：maxHeights = [6,5,3,9,2,7]
输出：22
解释： 和最大的美丽塔方案为 heights = [3,3,3,9,2,2] ，这是一个美丽塔方案，因为：
- 1 <= heights[i] <= maxHeights[i]
- heights 是个山状数组，峰值在 i = 3 处。
22 是所有美丽塔方案中的最大高度和。
```

```
输入：maxHeights = [3,2,5,5,2,3]
输出：18
解释：和最大的美丽塔方案为 heights = [2,2,5,5,2,2] ，这是一个美丽塔方案，因为：
- 1 <= heights[i] <= maxHeights[i]
- heights 是个山状数组，最大值在 i = 2 处。
注意，在这个方案中，i = 3 也是一个峰值。
18 是所有美丽塔方案中的最大高度和。
```

## 解题思路

### 暴力枚举

当数据范围比较小的时候，例如1e3的时候，可以通过枚举顶点，然后往两边走，一直模拟就可以了。

n^2的复杂度

```cpp
class Solution {
public:
    long long maximumSumOfHeights(vector<int>& maxHeights) {
        long long ans = 0;
        int n = maxHeights.size();
        for(int i=0;i<n;i++){
            int top = maxHeights[i];
            long long sum = top;
            int cur = top;
            for(int j=i-1;j>=0;j--){
                if(maxHeights[j] >= cur){
                    sum += cur;
                }else{
                    sum += maxHeights[j];
                    cur = maxHeights[j];
                }
            }
            cur = top;
            for(int j=i+1;j<n;j++){
                if(maxHeights[j] >= cur){
                    sum += cur;
                }else{
                    sum += maxHeights[j];
                    cur = maxHeights[j];
                }
            }
            ans = max(ans, sum);
        }
        return ans;
    }
};
```



### 单调栈

可以看到，其实枚举顶点的方式其实上算的就是前缀的上升序列以及一个后缀的下降序列，上面的做法其实有很多的重复计算，所以我们可以考虑把这个前缀的上升序列以及这个后缀的下降序列预计算出来，然后存下来。

计算的方式可以通过单调栈的方式来计算。

举个例子，假如我们计算的是一个上升的前缀

假设前面的数字是 13333332，那么当2进来时，前面的3都要被替换为2。

比如说这个就可以使用一个单调栈去记录最左边的idx，当处理每一个位置时，一直pop直到栈顶元素比当前元素小，比如当2进来时，curSum的更新应该为 -6✖️3 + 7 ✖️2

> 可以通过往栈里面push -1 来在构造pre时候来标识起点，往栈里面push len 来在构造pre时候来标识尾巴。
>
> 使用st.size() > 1来标识栈空

```cpp
class Solution {
public:
    long long maximumSumOfHeights(vector<int>& maxHeights) {
        int len = maxHeights.size();
        stack<long long> st;
        vector<long long> suf(len,0);
        vector<long long> pre(len,0);
        st.push(len);
        long long curSum = 0;
        for(int i=len-1; i>=0; i--){
            while(st.size() > 1 && maxHeights[i] <= maxHeights[st.top()]){
                int left = st.top();
                st.pop();
                int right = st.top();
                curSum -= 1ll * (right-left) * maxHeights[left];
            }
            curSum += 1ll * (st.top() - i ) * maxHeights[i];
            suf[i] = curSum;
            st.push(i);
        }
        curSum = 0;
        while(!st.empty()) st.pop();
        st.push(-1);
        for(int i=0; i<len; i++){
            while(st.size() > 1 && maxHeights[i] <= maxHeights[st.top()]){
                int right = st.top();
                st.pop();
                int left = st.top();
                curSum -= 1ll * (right-left) * maxHeights[right];
            }
            curSum += 1ll * (i - st.top()) * maxHeights[i];
            pre[i] = curSum;
            st.push(i);
        }
        long long ans = 0;
        for(int i=0;i<len;i++){
            long long val = pre[i];
            if(i+1 < len) val += suf[i+1];
            ans = max(ans ,val);
        }

        return ans;
    }
};
```









## 题目链接

[2866. 美丽塔 II - 力扣（LeetCode）](https://leetcode.cn/problems/beautiful-towers-ii/description/)