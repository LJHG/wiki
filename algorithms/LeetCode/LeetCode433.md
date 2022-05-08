---
title: 最小基因变化---LeetCode433(bfs)
date: 2022-05-07 22:21:29
tags: [bfs]
---
# 最小基因变化---LeetCode433(bfs)
## 题目描述
基因序列可以表示为一条由 8 个字符组成的字符串，其中每个字符都是 'A'、'C'、'G' 和 'T' 之一。

假设我们需要调查从基因序列 start 变为 end 所发生的基因变化。一次基因变化就意味着这个基因序列中的一个字符发生了变化。

例如，"AACCGGTT" --> "AACCGGTA" 就是一次基因变化。
另有一个基因库 bank 记录了所有有效的基因变化，只有基因库中的基因才是有效的基因序列。

给你两个基因序列 start 和 end ，以及一个基因库 bank ，请你找出并返回能够使 start 变化为 end 所需的最少变化次数。如果无法完成此基因变化，返回 -1 。

注意：起始基因序列 start 默认是有效的，但是它并不一定会出现在基因库中。

    
## 示例
示例 1：
```
输入：start = "AACCGGTT", end = "AACCGGTA", bank = ["AACCGGTA"]
输出：1
示例 2：

输入：start = "AACCGGTT", end = "AAACGGTA", bank = ["AACCGGTA","AACCGCTA","AAACGGTA"]
输出：2
示例 3：

输入：start = "AAAAACCC", end = "AACCCCCC", bank = ["AAAACCCC","AAACCCCC","AACCCCCC"]
输出：3
```
    
## 解题思路
切水题，但还是记录一下，因为这道题一个很重要的点是你需要先把问题转化为一个图，然后直接套bfs找一条路径就ok了。然后直接一发A就很爽🤓。
```cpp
class Solution {
public:
    bool convertable(string a,string b){
        int aLen = a.size();
        int bLen = b.size();
        if(aLen != bLen) return false;
        int diffNum = 0;
        for(int i=0;i<aLen;i++){
            if(a[i] != b[i]){
                diffNum +=1;
            }
        }
        return diffNum == 1;
    }

    struct node{
        int idx;
        int num;
    };

    int minMutation(string start, string end, vector<string>& bank) {
        int graph[20][20];
        memset(graph,0,sizeof(graph));
        //构建一个图,图的节点数为 1+bank.size(),如果两个基因的字符只相差1，那么就有一条无向边
        vector<string> nodes;
        nodes.push_back(start);
        for(auto x:bank){
            nodes.push_back(x);
        }
        int len = nodes.size();
        for(int i=0;i<len;i++){
            for(int j=0;j<len;j++){
                if(i == j) continue;
                if(convertable(nodes[i],nodes[j])){
                    graph[i][j] = 1;
                    graph[j][i] = 1;
                }
            }
        }
        queue<node> q;
        int vis[20];memset(vis,0,sizeof(vis));
        vis[0] = 1;
        node startNode;startNode.idx= 0; startNode.num = 0;
        q.push(startNode);
        while(!q.empty()){
            node top = q.front();
            q.pop();
            if(nodes[top.idx] == end){
                return top.num;
            }
            for(int i=0;i<len;i++){
                if(graph[top.idx][i] == 1 && vis[i] == 0){
                    node tmp;tmp.idx=i;tmp.num = top.num+1;
                    vis[i] = 1;
                    q.push(tmp);
                }
            }
        }
        return -1;
    }
};
```
    
## 题目链接
    