---
title: 太平洋大西洋水流问题---LeetCode417(dfs)
date: 2022-04-27 15:14:56
tags: [dfs]
---
# 太平洋大西洋水流问题---LeetCode417(dfs)

## 题目描述
有一个 m × n 的矩形岛屿，与 太平洋 和 大西洋 相邻。 “太平洋” 处于大陆的左边界和上边界，而 “大西洋” 处于大陆的右边界和下边界。

这个岛被分割成一个由若干方形单元格组成的网格。给定一个 m x n 的整数矩阵 heights ， heights[r][c] 表示坐标 (r, c) 上单元格 高于海平面的高度 。

岛上雨水较多，如果相邻单元格的高度 小于或等于 当前单元格的高度，雨水可以直接向北、南、东、西流向相邻单元格。水可以从海洋附近的任何单元格流入海洋。

返回 网格坐标 result 的 2D列表 ，其中 result[i] = [ri, ci] 表示雨水可以从单元格 (ri, ci) 流向 太平洋和大西洋 。

## 示例
<img src="https://assets.leetcode.com/uploads/2021/06/08/waterflow-grid.jpg" alt="img" style="zoom:50%;" />

```
输入: heights = [[1,2,2,3,5],[3,2,3,4,4],[2,4,5,3,1],[6,7,1,4,5],[5,1,1,2,4]]
输出: [[0,4],[1,3],[1,4],[2,2],[3,0],[3,1],[4,0]]

输入: heights = [[2,1],[1,2]]
输出: [[0,0],[0,1],[1,0],[1,1]]
```

## 解题思路

### 记忆化搜索->G了

最开始看到这道题第一反应使用dp来做，后来仔细一想，用dp来做的话那么就是从外圈一直往内圈里边推导(应该没想错吧🤔)。恰巧最近想要试一下记忆化搜索，就是备忘录，因为和dp的性质是一样的，想着就着这个机会练习一下，然后我人没了。

这里我的想法也很简单，就是对于每一个坐标，去判断它能否到大西洋或者太平洋，如何判断呢？就是去看它的邻居是否能到。乍一看没啥问题，但是可能也是真的没啥问题，但是我写出来就有问题。。。

首先你要考虑一下递归的终止条件，到达边界？(🙅‍♂️)，就算到了边界，也不能停，因为其实我在大西洋的边界，但是是有可能到太平洋的。所以最后我认为终止条件就是**走不动了**，也就是说设置一个vis，当我的邻居都访问过或者说周围都比我高了，那么就停。

但是其实这也有问题，因为你要考虑到一个**循环调用**的问题，比如说只有当一个坐标真正知道自己能否到太平洋以及大西洋后，才能把自己的vis设置为1，但是在这之前它已经进行了递归调用了，所以在执行递归的程序里是看不到vis为1的，所以它又会去调用这个坐标来执行dfs，于是就死循环了。

但是如果你把vis设置为1放在dfs的开头(如下面的代码)，那结果也不对了，因为你还没得到自己的结果呢。

反正最后我没搞定，错误示范如下：

```cpp
class Solution {
public:
    struct state{
        int pacific;
        int atlantic;
    };
    state ok[201][201];
    int togo[4][2] = {{0,1},{0,-1},{1,0},{-1,0}};
    int row = 0;
    int col = 0;
    int vis[201][201]; 
    
    state dfs(int m, int n,vector<vector<int>>& heights){
        if(vis[m][n]){
            return ok[m][n];
        }
        vis[m][n] = 1;
        state curOk;
        curOk.atlantic = 0;
        curOk.pacific = 0;
        if(m == 0 || n == 0){
            curOk.pacific = 1;
        }
        if(m == row-1 || n == col-1){
            curOk.atlantic = 1;
        }
        
        for(int i=0;i<4;i++){
            int x = m + togo[i][0];
            int y = n + togo[i][1];
            if(x >=0 && x<row && y>=0 && y<col && heights[x][y] <= heights[m][n]){
                state tmp = dfs(x,y,heights);
                curOk.atlantic |= tmp.atlantic;
                curOk.pacific |= tmp.pacific;
            }
            
        }
        
        ok[m][n] = curOk;
        return curOk;
    }


    vector<vector<int>> pacificAtlantic(vector<vector<int>>& heights) {
        memset(ok,0,sizeof(ok));
        memset(vis,0,sizeof(vis));
        row = heights.size();
        col = heights[0].size();
        vector<vector<int>> ans; ans.clear();
        for(int i=0;i<row;i++){
            for(int j=0;j<col;j++){
                state tmp = dfs(i,j,heights);
                if(tmp.atlantic && tmp.pacific){
                    vector<int> temp = {i,j};
                    ans.push_back(temp);
                }
            }
        }
        return ans;
    }
};
```

### 逆向dfs

正解其实是反着做dfs，也就是说从终点往回推，从4个海岸线往回做dfs，把所有可能的点都找出来，所以一共做m*n个dfs就行了。

代码如下：

```cpp
class Solution {
public:
    struct state{
        int pacific;
        int atlantic;
    };
    state ocean[201][201];
    int vis[201][201];
    int togo[4][2] = {{1,0},{-1,0},{0,1},{0,-1}};
    int row;
    int col;
    void dfs(int x ,int y, int type, vector<vector<int>>& heights ) // 1表示pacific, 2表示atlantic
    {
        vis[x][y] = 1;
        if(type == 1)
            ocean[x][y].pacific = 1;
        else 
            ocean[x][y].atlantic = 1;
        bool hasLeft = false;
        for(int i=0;i<4;i++){
            int m = x + togo[i][0];
            int n = y + togo[i][1];
            if(m>=0 && m<row && n>=0 && n<col && !vis[m][n] && heights[m][n] >= heights[x][y]){
                hasLeft = true;
                if(type == 1){
                    dfs(m,n,1,heights);
                }else{
                    dfs(m,n,2,heights);
                }
            }
        }
        return;
    }

    vector<vector<int>> pacificAtlantic(vector<vector<int>>& heights) {
        vector<vector<int>> ans;
        row = heights.size();
        col = heights[0].size();
        for(int i=0;i<row;i++){
            memset(vis,0,sizeof(vis));
            dfs(i,0,1,heights);
        }
        for(int i=0;i<row;i++){
            memset(vis,0,sizeof(vis));
            dfs(i,col-1,2,heights);
        }
        for(int j=0;j<col;j++){
            memset(vis,0,sizeof(vis));
            dfs(0,j,1,heights);
        }
        for(int j=0;j<col;j++){
            memset(vis,0,sizeof(vis));
            dfs(row-1,j,2,heights);
        }
        for(int i=0;i<row;i++){
            for(int j=0;j<col;j++){
                if(ocean[i][j].pacific && ocean[i][j].atlantic){
                    vector<int> temp = {i,j};
                    ans.push_back(temp);
                }
            }
        }

        return ans;
    }
};
```





## 题目链接

[417. 太平洋大西洋水流问题 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/pacific-atlantic-water-flow/)