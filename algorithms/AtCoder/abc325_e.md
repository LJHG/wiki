---
title: Dijkstra最短路，以及2N节点
date: 2023-10-23 21:01:45
tags: [最短路, dijkstra]
---
# Dijkstra最短路，以及2N节点
> 日期: 2023-10-23

## 题目描述

[E - Our clients, please wait a moment (atcoder.jp)](https://atcoder.jp/contests/abc325/tasks/abc325_e)

## 示例

```
4 8 5 13
0 6 2 15
6 0 3 5
2 3 0 13
15 5 13 0

78
```



## 解题思路

第一次做atcoder，感觉还是有点难的，因为对最短路不熟悉，所以这道题完全没有意识到是最短路，因此在这里复习一下。

总的来说，单源Djikstra最短路就是不停地寻找一个最近的一个没有vis过的节点(第一个while循环)，去更新剩下的节点的dis(第二个while循环)。因为要挑选n个节点，所以最外层还有一个循环，所以复杂度是O(n^2)。

这里给出一般的Dijkstra的写法:

```cpp
for(int t =0; t<n; t++){
        // 未选取的dis最小的点
        int x = -1;
        for(int i=0;i<n;i++){
            if(!vis[i] && dis[i] != -1 && (x == -1 || dis[i] < dis[x])){
                x = i;
            }
        }
        // 更新距离
        vis[x] = 1;
        for(int j=0; j<n; j++){
            if(dis[j] == -1 || dis[j] > dis[x] + grid[j][x]){
                dis[j] = dis[x] + grid[j][x];
            }
        }
    }
```

回到这道题，这道题虽然只有n个城市，但是在求最短路的时候，需要把它构造为有2n个点，来分别表示car的点和train的点，同时car的点可以走向train的点，但是trian的点不能走向car的点。

这道题还有一点很妙的是，虽然我们构造出了一个2n的图，但是没有必要显示地把这个2n的图用邻接矩阵表示出来，只需要稍微处理一下，就用原来那个n*n的领结矩阵也是可以的(妙蛙)

代码如下(参考了jiangly的代码，tql)：

```cpp
#include<bits/stdc++.h>
using namespace std;

using ll = long long;

int main(){
    int n,a,b,c;;
    cin>>n>>a>>b>>c;
    vector<vector<ll>> grid(n ,vector<ll>(n));
    for(int i=0;i<n;i++){
        for(int j=0;j<n;j++){
            cin >> grid[i][j];
        }
    }
    vector<ll> dis(2*n, -1);
    vector<int> vis(2*n, 0);
    dis[0] = 0;
    for(int t =0; t<2*n; t++){
        // 未选取的dis最小的点
        int x = -1;
        for(int i=0;i<2*n;i++){
            if(!vis[i] && dis[i] != -1 && (x == -1 || dis[i] < dis[x])){
                x = i;
            }
        }
        // 更新距离
        vis[x] = 1;
        if(x % 2 == 0){ // car
            // car到train的转移单独处理
            if(dis[x+1] == -1 || dis[x+1] > dis[x]){
                dis[x+1] = dis[x];
            }
        }
        for(int j=0; j<n; j++){
            int k = j*2 + x % 2; // 更新 car->car train -> train
            ll v = dis[x];
            if(x % 2 == 0){
                v += grid[x/2][j] * a; // car
            }else{
                v += grid[x/2][j] * b + c; // train
            }
            if(dis[k] == -1 || dis[k] > v){
                dis[k] = v;
            }
        }
    }

    cout<<dis[2*n-1]<<endl;


    return 0;

}
```

## 题目链接

[E - Our clients, please wait a moment (atcoder.jp)](https://atcoder.jp/contests/abc325/tasks/abc325_e)

[KEYENCE Programming Contest 2023 Autumn（AtCoder Beginner Contest 325）_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1rN411x7hi/?spm_id_from=333.337.search-card.all.click&vd_source=c0c1ccbf42eada4efb166a6acf39141b)