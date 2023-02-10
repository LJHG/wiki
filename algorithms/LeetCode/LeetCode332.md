---
title: 重新安排行程---LeetCode332(STL)
date: 2023-02-10 16:53:33
tags: [STL, 回溯]
---
# 重新安排行程---LeetCode332(STL)
> 日期: 2023-02-10

## 题目描述

给你一份航线列表 tickets ，其中 tickets[i] = [fromi, toi] 表示飞机出发和降落的机场地点。请你对该行程进行重新规划排序。

所有这些机票都属于一个从 JFK（肯尼迪国际机场）出发的先生，所以该行程必须从 JFK 开始。如果存在多种有效的行程，请你按字典排序返回最小的行程组合。

例如，行程 ["JFK", "LGA"] 与 ["JFK", "LGB"] 相比就更小，排序更靠前。
假定所有机票至少存在一种合理的行程。且所有的机票 必须都用一次 且 只能用一次。

## 示例

```
输入：tickets = [["MUC","LHR"],["JFK","MUC"],["SFO","SJC"],["LHR","SFO"]]
输出：["JFK","MUC","LHR","SFO","SJC"]

输入：tickets = [["JFK","SFO"],["JFK","ATL"],["SFO","ATL"],["ATL","JFK"],["ATL","SFO"]]
输出：["JFK","ATL","JFK","SFO","ATL","SFO"]
解释：另一种有效的行程是 ["JFK","SFO","ATL","JFK","ATL","SFO"] ，但是它字典排序更大更靠后。

```



## 解题思路

### 1. 直接回溯

最开始是直接当作回溯来做的，没有使用邻接表(费时)，就是每进入一个dfs就对所有的边进行一次遍历，能用就加。

最后再对所有的结果进行一个sort(费时+1)，最前面的那个字符串数组就是字典序最小的结果。

这种方法会超时，但是还是贴一下。

```cpp
class Solution {
public:
    vector<vector<string>> totalAns;
    vector<string> tmp;
    int vis[310];

    void dfs(vector<vector<string>>& tickets)
    {
        if(tmp.size() == tickets.size()+1){
            totalAns.push_back(tmp);
            return;
        }

        if(tmp.size() == 0){
            for(int i=0;i<tickets.size();i++){
                if(tickets[i][0] == "JFK"){
                    vis[i] = 1;
                    tmp.push_back("JFK");
                    tmp.push_back(tickets[i][1]);
                    dfs(tickets);
                    tmp.pop_back();
                    tmp.pop_back();
                    vis[i] = 0;
                }
            }
        }else{
            for(int i=0;i<tickets.size();i++){
                if(vis[i] == 1) continue;
                if(tickets[i][0] == tmp.back()){
                    vis[i] = 1;
                    tmp.push_back(tickets[i][1]);
                    dfs(tickets);
                    tmp.pop_back();
                    vis[i] = 0;
                }
            }
        }
    }

    

    vector<string> findItinerary(vector<vector<string>>& tickets) {
        memset(vis,0,sizeof(vis));
        dfs(tickets);
        sort(totalAns.begin(),totalAns.end());
        // cout<<totalAns.size()<<endl;
        return totalAns[0];      
    }
};
```



### 2. 用邻接表

可以先对图进行一个预处理将其转换为一个邻接表，这会在遍历时节省很多时间。

至于这个邻接表该使用什么样的数据结构来存，这里使用了 `unordered_map<string, map<string,int>>`，第二个使用map的话就会自动将其用字典序排好了。于是就可以一直递归，看到能用的就加，第一个得到的最终答案就是最后的答案。

最后再提一下一个坑，因为题目里面的ticket是有重复的，所以不能单单使用0和1来表示票是否访问过了，于是这里就需要将票的数量保存下来。

```cpp
class Solution {
public:
    vector<string> tmp;
    unordered_map<string, map<string,int> > vis; 

    void initialize(vector<vector<string>>& tickets){
        for(auto ticket:tickets){
            vis[ticket[0]][ticket[1]] += 1;
        }
    }

    bool dfs(string curString, vector<vector<string>>& tickets){
        if(tmp.size() == tickets.size() + 1){
            return true;
        }
       for(auto target:vis[curString]){
            if(target.second > 0){
                vis[curString][target.first]--;
                tmp.push_back(target.first);
                bool valid = dfs(target.first,tickets);
                if(valid == true){
                    return true;
                }
                tmp.pop_back();
                vis[curString][target.first]++;
            }
       }
       return false;
    }

    vector<string> findItinerary(vector<vector<string>>& tickets) {
        initialize(tickets);
        tmp.push_back("JFK");
        dfs("JFK",tickets);
        return tmp;      
    }
};
```



## 题目链接

[332. 重新安排行程 - 力扣（LeetCode）](https://leetcode.cn/problems/reconstruct-itinerary/)