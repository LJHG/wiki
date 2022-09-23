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