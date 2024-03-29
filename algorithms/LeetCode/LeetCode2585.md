---
title: 获得分数的方法数---LeetCode2585(分组背包模板)
date: 2023-03-07 10:52:41
tags: [dp, 背包]
---
# 获得分数的方法数---LeetCode2585(分组背包模板)
> 日期: 2023-03-07

## 题目描述

考试中有 n 种类型的题目。给你一个整数 target 和一个下标从 0 开始的二维整数数组 types ，其中 types[i] = [counti, marksi] 表示第 i 种类型的题目有 counti 道，每道题目对应 marksi 分。

返回你在考试中恰好得到 target 分的方法数。由于答案可能很大，结果需要对 109 +7 取余。

注意，同类型题目无法区分。

比如说，如果有 3 道同类型题目，那么解答第 1 和第 2 道题目与解答第 1 和第 3 道题目或者第 2 和第 3 道题目是相同的。

## 示例

```
输入：target = 6, types = [[6,1],[3,2],[2,3]]
输出：7
解释：要获得 6 分，你可以选择以下七种方法之一：
- 解决 6 道第 0 种类型的题目：1 + 1 + 1 + 1 + 1 + 1 = 6
- 解决 4 道第 0 种类型的题目和 1 道第 1 种类型的题目：1 + 1 + 1 + 1 + 2 = 6
- 解决 2 道第 0 种类型的题目和 2 道第 1 种类型的题目：1 + 1 + 2 + 2 = 6
- 解决 3 道第 0 种类型的题目和 1 道第 2 种类型的题目：1 + 1 + 1 + 3 = 6
- 解决 1 道第 0 种类型的题目、1 道第 1 种类型的题目和 1 道第 2 种类型的题目：1 + 2 + 3 = 6
- 解决 3 道第 1 种类型的题目：2 + 2 + 2 = 6
- 解决 2 道第 2 种类型的题目：3 + 3 = 6
```

```
输入：target = 5, types = [[50,1],[50,2],[50,5]]
输出：4
解释：要获得 5 分，你可以选择以下四种方法之一：
- 解决 5 道第 0 种类型的题目：1 + 1 + 1 + 1 + 1 = 5
- 解决 3 道第 0 种类型的题目和 1 道第 1 种类型的题目：1 + 1 + 1 + 2 = 5
- 解决 1 道第 0 种类型的题目和 2 道第 1 种类型的题目：1 + 2 + 2 = 5
- 解决 1 道第 2 种类型的题目：5
```

```
输入：target = 18, types = [[6,1],[3,2],[2,3]]
输出：1
解释：只有回答所有题目才能获得 18 分。
```



## 解题思路

像这种其实是分组背包，不是多重背包。这里把二维写法和一维写法都总结一下。

### 二维写法

dp数组的意义和01背包是一样的，前面两层循环顺序和普通的01背包是一样的，遍历的顺序也都是从少到多。

和01背包的唯一区别在于多了第三层循环，对于某一种物品，可以取 0～count种可能。

总体来说二维写法还是比较好写的，没有什么需要注意的。如果空间没有限制的话，尽量写二维写法，不容易错。

```c++
int MOD = 1e9 + 7;
class Solution {
public:
    int waysToReachTarget(int target, vector<vector<int>>& types) {
        int dp[60][1010]; //前i个物品组成j价值的最大组合数
        memset(dp,0,sizeof(dp));
        dp[0][0] = 1;
        
        int len = types.size();
        for(int i=1;i<=len;i++){
            for(int j=0;j<=target;j++){
                for(int k=0;k<=types[i-1][0];k++){
                    if( j - k*types[i-1][1] >= 0){
                        dp[i][j] = (dp[i][j] +  dp[i-1][j - k * types[i-1][1]]) % MOD;
                    }
                }
            }
        }
        return dp[len][target];
    }
};
```

### 一维写法

同样，dp的意义和01背包是一样的。但是有一些细节需要注意：

1. 第二层遍历要逆序。同时最后的判定条件可以写` j >= 0`，也可以写` j >= types[i][1]`，都是可以的。因为这里我在下一个循环里面写了if判断
2. **第三层的k要从1开始遍历**，因为如果k为0就变成了 `dp[j] = dp[j] + dp[j]`，而这是没有意义的，`dp[j]`直接从上一层继承过来就好，没有必要再算一遍。

```c++
int MOD = 1e9 + 7;
class Solution {
public:
    int waysToReachTarget(int target, vector<vector<int>>& types) {
        int dp[1010]; //组成j价值的最大组合数
        memset(dp,0,sizeof(dp));
        dp[0] = 1;
        
        int len = types.size();
        for(int i=1;i<=len;i++){
            for(int j=target;j>=0;j--){
                for(int k=1;k<=types[i-1][0];k++){
                    if( j - k*types[i-1][1] >= 0){
                        dp[j] = (dp[j] +  dp[j - k * types[i-1][1]]) % MOD;
                    }
                }
            }
        }
        return dp[target];
    }
};
```



## 题目链接

[2585. 获得分数的方法数 - 力扣（LeetCode）](https://leetcode.cn/problems/number-of-ways-to-earn-points/)