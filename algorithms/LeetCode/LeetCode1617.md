---
title: 统计子树中城市最大距离---LeetCode1617(子集+树形dp)
date: 2023-10-20 18:06:39
tags: [回溯, 树形dp]
---
# 统计子树中城市最大距离---LeetCode1617(子集+树形dp)
> 日期: 2023-10-20

## 题目描述

给你 `n` 个城市，编号为从 `1` 到 `n` 。同时给你一个大小为 `n-1` 的数组 `edges` ，其中 `edges[i] = [ui, vi]` 表示城市 `ui` 和 `vi` 之间有一条双向边。题目保证任意城市之间只有唯一的一条路径。换句话说，所有城市形成了一棵 **树** 。

一棵 **子树** 是城市的一个子集，且子集中任意城市之间可以通过子集中的其他城市和边到达。两个子树被认为不一样的条件是至少有一个城市在其中一棵子树中存在，但在另一棵子树中不存在。

对于 `d` 从 `1` 到 `n-1` ，请你找到城市间 **最大距离** 恰好为 `d` 的所有子树数目。

请你返回一个大小为 `n-1` 的数组，其中第 `d` 个元素（**下标从 1 开始**）是城市间 **最大距离** 恰好等于 `d` 的子树数目。

**请注意**，两个城市间距离定义为它们之间需要经过的边的数目。

## 示例

```
输入：n = 4, edges = [[1,2],[2,3],[2,4]]
输出：[3,4,0]
解释：
子树 {1,2}, {2,3} 和 {2,4} 最大距离都是 1 。
子树 {1,2,3}, {1,2,4}, {2,3,4} 和 {1,2,3,4} 最大距离都为 2 。
不存在城市间最大距离为 3 的子树。
```

## 解题思路

### 比较low的求树的直径的写法

我胆子大了敢做hard了，但是这道题其实就是一个树的直径和子集的结合。

因为题目说的最大距离其实就是树的直径，把这个翻译出来其实就好做很多了。

但是细节上的东西还是蛮多的，比如，首先构建出来的子树需要是一个连通的，这里的做法是搞了一个inset和一个vis数组，vis数组在树形dp遍历的时候去更新，最后通过判断vis和inset是否相等来看当前这个子集是不是合法的，只有合法才会去更新答案。

因为树的直径有时候不太能写明白，有时候我会选择把子树的结果全部存进一个vector里面然后挑选最大的两个元素来做(比如这里)

```cpp
class Solution {
public:
    // 枚举子集求树的直径
    // 需要更优雅的写法
    vector<vector<int>> g;
    vector<bool> vis; 
    vector<bool> inSet;
    vector<int> ans;
    int N;
    int diameter;
    int dfs(int idx, int fa){
        vis[idx] = true;
        vector<int> tmp;
        for(int son:g[idx]){
            if(son == fa || !inSet[son]) continue;
            int curCnt = dfs(son, idx);
            tmp.push_back(curCnt);
        }
        if(tmp.size() == 0){
            return 1;
        }else if(tmp.size() == 1){
            diameter = max(diameter, tmp[0]);
            return tmp[0] + 1;
        }else{
            sort(tmp.begin(),tmp.end());
            diameter = max(diameter, tmp[tmp.size()-1] + tmp[tmp.size()-2]);
            return tmp[tmp.size()-1] + 1;
        }
    }
    
    void dfs2(int idx){
        if(idx == N){
            // 找一个在子图中的点开始dfs
            for(int i=0;i<inSet.size();i++){
                if(inSet[i]){
                    vis = vector<bool>(N, false);
                    diameter = 0;
                    dfs(i,-1);
                    break;
                }
            }
            if(diameter > 0 && vis == inSet){
                ans[diameter-1]++;
            }
            return;
        }
        inSet[idx] = true;
        dfs2(idx+1);
        inSet[idx] = false;
        dfs2(idx+1);
    }
    
    vector<int> countSubgraphsForEachDiameter(int n, vector<vector<int>>& edges) {
        g = vector<vector<int>>(n);
        inSet = vector<bool>(n, false);
        vis = vector<bool>(n, false);
        N = n;
        for(auto x : edges){
            g[x[0]-1].push_back(x[1]-1);
            g[x[1]-1].push_back(x[0]-1);
        }
        ans = vector<int>(n-1,0);
        diameter = 0;
        dfs2(0);
        return ans;
        
    }
};
```



### 优雅的求树的直径的写法

不过把所有子树的点数push进vector然后排序的方法比较丑陋，所以还有一种比较绕但是优雅的写法。

这里我们假设dfs的返回值是包含当前节点的最大路径长度，这种写法叫做maxLen。

假设dfs的返回值是包含当前节点的最大节点数量，这种写法叫做maxCnt。

大致就是记录的是maxLen而不是maxCnt了，这种比较好写。因为假设在处理前一颗子树的情况时，如果前面是空，因为我们会把maxCnt初始化为1，但是maxCnt如果最小是1就比较奇怪，但是maxLen是0就很合理。

反正在用maxCnt写法写的时候我不太能想清楚，但是用maxLen写法倒是比较好写。

```cpp
class Solution {
public:
    // 枚举子集求树的直径
    vector<vector<int>> g;
    vector<bool> vis; 
    vector<bool> inSet;
    vector<int> ans;
    int N;
    int diameter;

    int dfs(int idx, int fa){
        vis[idx] = true;
        int maxLen = 0;
        for(int son:g[idx]){
            if(son == fa || !inSet[son]) continue;
            int curLen = dfs(son, idx) + 1;
            diameter = max(diameter, maxLen + curLen);
            maxLen = max(maxLen, curLen);
        }
        return maxLen;
    }
    
    void dfs2(int idx){
        if(idx == N){
            // 找一个在子图中的点开始dfs
            for(int i=0;i<inSet.size();i++){
                if(inSet[i]){
                    vis = vector<bool>(N, false);
                    diameter = 0;
                    dfs(i,-1);
                    break;
                }
            }
            if(diameter > 0 && vis == inSet){
                ans[diameter-1]++;
            }
            return;
        }
        inSet[idx] = true;
        dfs2(idx+1);
        inSet[idx] = false;
        dfs2(idx+1);
    }
    
    vector<int> countSubgraphsForEachDiameter(int n, vector<vector<int>>& edges) {
        g = vector<vector<int>>(n);
        inSet = vector<bool>(n, false);
        vis = vector<bool>(n, false);
        N = n;
        for(auto x : edges){
            g[x[0]-1].push_back(x[1]-1);
            g[x[1]-1].push_back(x[0]-1);
        }
        ans = vector<int>(n-1,0);
        diameter = 0;
        dfs2(0);
        return ans;
        
    }
};
```







## 题目链接

[1617. 统计子树中城市之间最大距离 - 力扣（LeetCode）](https://leetcode.cn/problems/count-subtrees-with-max-distance-between-cities/)