---
title: 删除无效的括号---LeetCode301(BFS)
date: 2022-09-23 19:36:07
tags: [BFS]
---
# 删除无效的括号---LeetCode301(BFS)
> 日期: 2022-09-23

## 题目描述

给你一个由若干括号和字母组成的字符串 `s` ，删除最小数量的无效括号，使得输入的字符串有效。

返回所有可能的结果。答案可以按 **任意顺序** 返回。

## 示例

```
示例 1：

输入：s = "()())()"
输出：["(())()","()()()"]
示例 2：

输入：s = "(a)())()"
输出：["(a())()","(a)()()"]
示例 3：

输入：s = ")("
输出：[""]

```

## 解题思路

### 回溯 + 剪枝

> update on 2023.9.25

个人感觉回溯加剪枝的方式比较好想也比较好写，唯一不太好写的地方在于剪枝。

本来一般来说，是走到s的末尾再去判断tmp是否valid，如果是的话，那么就加入答案。

但是这道题不剪枝过不了，应该算是被卡常数了，虽然2^25只有3000万，但是每一次判断一下，差不多是一个长度为30的遍历就到1e9了，所以是有可能过不了的。

```
>>> 2 ** 25
33554432
>>> 33554432 * 30
1006632960
```

所以这里要剪枝，提供了一个`isPossibleValid`函数来看当前的答案是否还有可能合法，因为存在一些情况使得它肯定会不合法的，比如：

1. 当前的右括号数量比左括号多: ), )()
2. 当前的左括号数量已经大于后续还没有处理的字符数量，无法有足够多的右括号与之匹配(这个剪枝很重要，不加这个就过不了)，例如 ((((((((((((((((((((((aaaaaa

```cpp
class Solution {
public:
    int totalSize;

    bool isValid(string& s){
        int curLeft = 0;
        for(char c:s){
            if(c == '(') curLeft += 1;
            else if(c == ')'){
                if(curLeft == 0) return false;
                else curLeft -= 1;
            }
        }
        return curLeft == 0;
    }

    bool isPossibleValid(string &s, int idx){
        int curLeft = 0;
        int curRight = 0;
        for(char c:s){
            if(c == '('){
                curLeft += 1;
            }else if(c == ')'){
                curRight += 1;
            }
        }
        if(curLeft < curRight) return false;
        // 这个剪枝很有用
        if(curLeft - curRight > totalSize - idx ) return false;
        return curLeft >= curRight;
    }

    vector<string> ans;
    unordered_set<string> st;
    string tmp;
    void dfs(string& s, int idx){
        // 剪枝
        if(!isPossibleValid(tmp, idx)) return;
        if(idx == s.size()){
            if(isValid(tmp) && st.count(tmp) == 0){
                ans.push_back(tmp);
                st.insert(tmp);
            }
            return;
        }
        tmp += s[idx];
        dfs(s, idx+1);
        tmp.pop_back();
        dfs(s, idx+1);
    }

    static bool cmp(string& a, string& b){
        return a.size() > b.size();
    }
    
    vector<string> removeInvalidParentheses(string s) {
        totalSize = s.size();
        dfs(s, 0);
        sort(ans.begin(), ans.end(), cmp);
        int len = ans[0].size();
        vector<string> _ans;
        for(string& x:ans){
            if(x.size() == len){
                _ans.push_back(x);
            }else{
                break;
            }
        }
        return _ans;
    }
};
```





### bfs

感觉逐渐掌握BFS，这道题要求的是删除**最小数量**的括号，那么可以通过BFS的方式一点一点地把结果构造出来。

这道题最后做出来时间勉强飘过，感觉时间卡的不是很死，因为我频繁的int转string应该会让性能损失很多，不过应该是有方法直接在int上做valid的判断，或者说不用int全用string？

因为这道题我的判重是在string上做的，一方面是因为我不知道为什么开一个30000000大的一维数组会崩，另外就是因为两个不一样的int(选择方案)可能会导致相同的结果，虽然这个可以在ans进行一个判重就是了，但是我还是不知道为什么开一个30000000大的数组会崩。

最后代码是这样的：

```cpp
class Solution {
public:
    bool isValid(string s){
        int res = 0;
        //从左往右扫，遇到左括号+1，遇到右括号-1，如果一直>=0就是valid
        for(auto x:s){
            if(x == '(') res += 1;
            if(x == ')') res -= 1;
            if(res < 0) return false;
        }
        if(res == 0)
            return true;
        return false;
    }

    string int2string(int curInt,string& s){
        string curString = "";
        int increment = 1;
        int len = s.size();
        for (int j = 0; j < len; j++)
        {
            if (curInt & increment)
            {
                curString += s[j];
            }
            increment *= 2;
        }
        return curString;
    }

    vector<string> removeInvalidParentheses(string s)
    {
        unordered_set<string> vis;
        int len = s.size();
        queue<int> q;
        q.push(0);
        vis.insert("");
        vector<string> ans;
        while (!q.empty())
        {
            int qlen = q.size();
            vector<string> tmpAns;
            for (int i = 0; i < qlen; i++)
            {
                int curInt = q.front();
                q.pop();
                //根据二进制转字符串
                string curString = int2string(curInt,s);
                if (isValid(curString))
                {
                    tmpAns.push_back(curString);
                }
                // 变换一次
                int increment = 1;
                for (int j = 0; j < len; j++)
                {
                    if ( (curInt & increment) == 0)
                    {
                        int newInt = curInt | increment;
                        string newString = int2string(newInt,s);
                        if(vis.count(newString) == 0){
                            vis.insert(newString);
                            q.push(newInt);
                        }
                    }
                    increment *= 2;
                }
            }
            if (tmpAns.size() > 0)
            {
                ans = tmpAns;
            }
        }
        return ans;
    }
};
```



## 题目链接

[301. 删除无效的括号 - 力扣（LeetCode）](https://leetcode.cn/problems/remove-invalid-parentheses/)