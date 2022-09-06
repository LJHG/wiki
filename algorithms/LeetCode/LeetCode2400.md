---
title: 恰好移动 k 步到达某一位置的方法数目---LeetCode2400(dp与预处理)
date: 2022-09-06 15:41:49
tags: [dp]
---
# 恰好移动 k 步到达某一位置的方法数目---LeetCode2400(dp与预处理)
## 题目描述
给你两个 正 整数 startPos 和 endPos 。最初，你站在 无限 数轴上位置 startPos 处。在一步移动中，你可以向左或者向右移动一个位置。

给你一个正整数 k ，返回从 startPos 出发、恰好 移动 k 步并到达 endPos 的 不同 方法数目。由于答案可能会很大，返回对 109 + 7 取余 的结果。

如果所执行移动的顺序不完全相同，则认为两种方法不同。

注意：数轴包含负整数。

## 示例
示例 1：

输入：startPos = 1, endPos = 2, k = 3
输出：3
解释：存在 3 种从 1 到 2 且恰好移动 3 步的方法：
- 1 -> 2 -> 3 -> 2.
- 1 -> 2 -> 1 -> 2.
- 1 -> 0 -> 1 -> 2.
可以证明不存在其他方法，所以返回 3 。
示例 2：

输入：startPos = 2, endPos = 5, k = 10
输出：0
解释：不存在从 2 到 5 且恰好移动 10 步的方法。

## 解题思路

最开始看到这道题我是直接打算开三维dp，开成dp[i] [j] [k], 表示从i走到j，走k步能够到达的总次数，但是写了半天写不出来。。。于是我就去看题解了。

果不其然，题解只用了二维dp就做出来了，可能大部分情况下如果想到了用三维dp那么基本上是走远了。

二维dp是开成dp[i] [j]，表示走i步到达j的总次数。其实仔细一想确实应该这么开，因为这道题目的要求就是从StartPos走到EndPos，那么其实最开始的那个维度是可以被省掉的。

此外，这道题还聪明地使用了预处理来解决数组越界的问题，因为走的步数以及位置下标都在[0,1000]，那么只要对所有的坐标都+1000，开始结束坐标位置就会在[1000,2000]，整体坐标范围就会到[0,3000]，就无须再考虑负号。

具体代码如下：

```cpp
class Solution {
#define MOD 1000000007
public:
    int numberOfWays(int startPos, int endPos, int k) {
        int dp[1010][3010]; // dp[i][j]表示第i步走到j的方法
        memset(dp,0,sizeof(dp));
        //对数据进行预处理
        startPos += 1000;
        endPos += 1000;
        dp[0][startPos] = 1;
        for(int i=1;i<=k;i++){
            for(int j=1;j<3009;j++){
                dp[i][j] = (dp[i-1][j+1] + dp[i-1][j-1])%MOD;
            }
            
        }      

        return dp[k][endPos];
    }
};
```


## 题目链接

[2400. 恰好移动 k 步到达某一位置的方法数目 - 力扣（LeetCode）](https://leetcode.cn/problems/number-of-ways-to-reach-a-position-after-exactly-k-steps/)