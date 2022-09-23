---
title: 完全平方数---LeetCode279(DP/BFS)
date: 2022-09-23 11:12:40
tags: [DP,BFS]
---
# 完全平方数---LeetCode279(DP/BFS)
> 日期: 2022-09-23

## 题目描述

给你一个整数 n ，返回 和为 n 的完全平方数的最少数量 。

完全平方数 是一个整数，其值等于另一个整数的平方；换句话说，其值等于一个整数自乘的积。例如，1、4、9 和 16 都是完全平方数，而 3 和 11 不是。

## 示例

**示例 1：**

```
输入：n = 12
输出：3 
解释：12 = 4 + 4 + 4
```

**示例 2：**

```
输入：n = 13
输出：2
解释：13 = 4 + 9
```

## 解题思路

### DP

第一眼看到就觉得是dp，乍一看以为是完全背包，后来一想，这道题是没有价格的，也就是说只有重量和背包容量限制。具体来说应该更像找零钱，但是肯定是不能用贪心做的。

然后稀里糊涂就用dp做出来了，还是比较简单的：

```cpp
class Solution {
public:
    int numSquares(int n) {
        int dp[10010];
        for(int i=1;i<=n;i++){
            dp[i] = 0x7fffffff;
        }
        dp[0] = 0;
        for(int i=1;i<=n;i++){
            for(int j=1;j<=int(sqrt(i));j++){
                dp[i] = min(dp[i-j*j] + 1,dp[i]);
            }
        }
        return dp[n];
    }
};
```

### BFS

这道题还可以用BFS做，现在我感觉很多题都可以用BFS做，只要是要求什么最短路径，最少组合什么的，比如说：[LeetCode854 · GitBook (ljhblog.top)](https://www.ljhblog.top/algorithms/LeetCode/LeetCode854.html)。

这次我写的版本是带着结果BFS，就是要创建结构体的版本，这种写法可以不在队列的大循环里面包一个判断队列size的小循环，但是我不知道为什么这种写法会跑得很慢，甚至我必须要把 ==n 这个判断放进循环里面才能过，如果放在循环外面在pop出来时再去判断就会超时。

```cpp
class Solution {
public:
    struct Node{
        int curSum;
        int curDepth;
    };
    int numSquares(int n) {
        int maxNum = int(sqrt(n));
        Node* root = new Node(); root->curSum=0; root->curDepth=0;
        queue<Node*> q;
        q.push(root);
        int vis[20010]; memset(vis,0,sizeof(vis));
        while(!q.empty()){
            Node* curNode = q.front();
            q.pop();
            vis[curNode->curSum] = 1;
            for(int i=1;i<=maxNum;i++){
                Node* newNode = new Node();
                newNode->curSum = curNode->curSum + i*i;
                if(newNode->curSum > n) break;
                newNode->curDepth = curNode->curDepth + 1;
                if(newNode->curSum == n){
                    return newNode->curDepth;
                }
                if(!vis[newNode->curSum])
                    q.push(newNode);
            }
        }
        return -1;
    }
};

```

相反，如果不把结果带着BFS，而是采用在队列循环里一次一次把每一层的处理完，就会快非常多，甚至比DP还快，不是很理解，难道现在写BFS都流行不用结构体了，还是说这道题这么写就是会快很多🤔。

```cpp
class Solution {
public:
    int numSquares(int n) {
        unordered_set<int> visited;
        queue<int> q{{0}};
        int steps = 1;
        while (!q.empty()) {
            auto size = q.size();
            while (size--) {
                auto cur = q.front(); q.pop();
                for (int i = 1; i * i + cur <= n; i++) {
                    auto next = i * i + cur;
                    if (next == n) {
                        return steps;
                    }
                    if (!visited.count(next)) {
                        visited.insert(next);
                        q.push(next);
                    }
                }
            }
            steps++;
        }

        return -1; // should never reach here.
    }
};

```

## 题目链接

[279. 完全平方数 - 力扣（LeetCode）](https://leetcode.cn/problems/perfect-squares/)