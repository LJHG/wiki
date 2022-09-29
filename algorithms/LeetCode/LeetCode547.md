---
title: 省份数量---LeetCode547(并查集)
date: 2022-09-29 14:17:50
tags: [并查集]
---
# 省份数量---LeetCode547(并查集)
> 日期: 2022-09-29

## 题目描述

有 n 个城市，其中一些彼此相连，另一些没有相连。如果城市 a 与城市 b 直接相连，且城市 b 与城市 c 直接相连，那么城市 a 与城市 c 间接相连。

省份 是一组直接或间接相连的城市，组内不含其他没有相连的城市。

给你一个 n x n 的矩阵 isConnected ，其中 isConnected[i][j] = 1 表示第 i 个城市和第 j 个城市直接相连，而 isConnected[i][j] = 0 表示二者不直接相连。

返回矩阵中 省份 的数量。

## 示例

**示例 1：**

![img](https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202209291422493.jpg)

```
输入：isConnected = [[1,1,0],[1,1,0],[0,0,1]]
输出：2
```

**示例 2：**

![img](https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202209291423603.jpg)

```
输入：isConnected = [[1,0,0],[0,1,0],[0,0,1]]
输出：3
```

## 解题思路

并查集板子题，复习了一下带路径压缩的并查集实现，非常简单。因为带秩合并的比较麻烦，所以暂时还没看。

具体来说就是根据题目给出的边来进行合并，然后依次判断自己是否为根结点即可，如果是根结点就代表是一个集合。

```cpp
class Solution {
public:
    int fa[220];
    void init(int n){
        for(int i=0;i<n;i++){
            fa[i] = i;
        }
    }

    int find(int x){
        if(fa[x] == x) return x;
        else{
            fa[x] = find(fa[x]);  //父节点设为根节点
            return fa[x];         //返回父节点
        }
    }

    void merge(int i, int j)
    {
        fa[find(i)] = find(j);
    }

    int findCircleNum(vector<vector<int>>& isConnected) {
        int len = isConnected.size();
        init(len);
        for(int i=0;i<len;i++){
            for(int j=0;j<len;j++){
                if(isConnected[i][j] == 1){
                    merge(i,j);     
                }
            }
        }
        int ans = 0;

        for(int i=0;i<len;i++){
            if(fa[i] == i) ans++; 
        }
        return ans;
    }
};
```



## 题目链接

[547. 省份数量 - 力扣（LeetCode）](https://leetcode.cn/problems/number-of-provinces/)

[算法学习笔记(1) : 并查集 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/93647900/)