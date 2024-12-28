---
title: 通配符匹配---LeetCode44(dp)
date: 2022-09-27 16:49:08
tags: [dp]
---
# 通配符匹配---LeetCode44(dp)
> 日期: 2022-09-27

## 题目描述

给定一个字符串 (s) 和一个字符模式 (p) ，实现一个支持 '?' 和 '*' 的通配符匹配。

'?' 可以匹配任何单个字符。
'*' 可以匹配任意字符串（包括空字符串）。
两个字符串完全匹配才算匹配成功。

说明:

s 可能为空，且只包含从 a-z 的小写字母。
p 可能为空，且只包含从 a-z 的小写字母，以及字符 ? 和 *。

## 示例

```
示例 1:

输入:
s = "aa"
p = "a"
输出: false
解释: "a" 无法匹配 "aa" 整个字符串。
示例 2:

输入:
s = "aa"
p = "*"
输出: true
解释: '*' 可以匹配任意字符串。
示例 3:

输入:
s = "cb"
p = "?a"
输出: false
解释: '?' 可以匹配 'c', 但第二个 'a' 无法匹配 'b'。
示例 4:

输入:
s = "adceb"
p = "*a*b"
输出: true
解释: 第一个 '*' 可以匹配空字符串, 第二个 '*' 可以匹配字符串 "dce".
示例 5:

输入:
s = "acdcb"
p = "a*c?b"
输出: false
```



## 解题思路

这道题没有给数据范围，很怪，不过还是手动把dp推出来了，yes！

因为没有给数据范围，所以一开始的时候把数组开得很大，然后就超时了。这里我表示很费解，难道开数组很耗费时间吗？

不是很懂，最后把数组改到了 1080 * 1080后勉强过了。

这道题用dp来做，dp[i] [j] 表示s字符串的i之前和p字符串的之前能否匹配。

转移方程是这样的：

1. 如果 s[i] == s[j]
   $$
   dp[i][j] = dp[i-1][j-1]
   $$

2. 如果 s[j] == ?
   $$
   dp[i][j] = dp[i-1][j-1]
   $$

3. 如果 s[j] == *
   $$
   if \quad dp[k][j-1] = 1, \quad then \quad dp[i-1][j-1] = 1, \quad where \quad 0<=k<=i
   $$

此外，为了避免空字符串以及一系列问题，为两个字符串前面都添加了一个a

代码如下:

```cpp
class Solution {
public:
    bool isMatch(string s, string p) {
        //避免空字符串
        s = "a" + s;
        p = "a" + p;
        
        int len1 = s.size();
        int len2 = p.size();
        int dp[1080][1080]; //dp[i][j] = 表示 对于s的index i之前，p的index j之前，能够匹配
        memset(dp,0,sizeof(dp));
        dp[0][0] = (s[0] == p[0]) || (p[0] == '?') || (p[0] == '*');
        for(int i=0;i<len1;i++){
            for(int j=0;j<len2;j++){
                if(i == 0 && j == 0) continue;
                if(p[j] == '?'){
                    if(i>=1 && j>=1)
                        dp[i][j] = dp[i-1][j-1];
                }
                else if(p[j] == '*'){
                    for(int k=i;k>=0;k--){
                        if( j>=1 && dp[k][j-1] == 1){
                            dp[i][j] = 1;
                            break;
                        }
                    }
                }
                else{
                    if(s[i] == p[j]){
                        if(i>=1 && j>=1)
                            dp[i][j] = dp[i-1][j-1];
                    }
                }
            }
        }
        return dp[len1-1][len2-1];
    }
};
```



## 题目链接

[44. 通配符匹配 - 力扣（LeetCode）](https://leetcode.cn/problems/wildcard-matching/)