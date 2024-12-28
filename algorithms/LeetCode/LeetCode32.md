---
title: 最长有效括号---LeetCode32(dp)
date: 2022-09-26 17:30:43
tags: [dp]
---
# 最长有效括号---LeetCode32(dp)
> 日期: 2022-09-26

## 题目描述

给你一个只包含 `'('` 和 `')'` 的字符串，找出最长有效（格式正确且连续）括号子串的长度。

## 示例

```
示例 1：

输入：s = "(()"
输出：2
解释：最长有效括号子串是 "()"
示例 2：

输入：s = ")()())"
输出：4
解释：最长有效括号子串是 "()()"
示例 3：

输入：s = ""
输出：0
 

提示：

0 <= s.length <= 3 * 104
s[i] 为 '(' 或 ')'

```

## 解题思路

### 错误示范

最开始我想的是统计一个区间里面左括号和右括号的数量，而且最开始我还是开的二维dp...

后来发现不需要二维dp，直接一个前缀和就行了。但是统计了数量还是不够哇。诸如 ')('这种就是不行。

```cpp
class Solution {
public:
    struct info{
        int left;
        int right;
    };

    int longestValidParentheses(string s) {
        info dp[30001];
        int len = s.size();
        dp[0].left = (s[0] == '(');
        dp[0].right = (s[0] == ')');
        for(int i=1;i<len;i++){
            dp[i].left = dp[i-1].left + (s[i] == '(');
            dp[i].right = dp[i-1].right + (s[i] == ')');
        }
        // cout<<dp[0].left<<" "<<dp[0].right<<endl;
        // cout<<dp[1].left<<" "<<dp[1].right<<endl;
        // cout<<dp[2].left<<" "<<dp[2].right<<endl;
        int ans = 0;
        for(int k=2;k<=len;k++){
            if(k % 2 != 0) continue;
            for(int i=0;i+k-1<len;i++){
                int periodLeft = 1234567;
                int periodRight = 7654321;
                if(i-1 < 0){
                    periodLeft = dp[i+k-1].left;
                    periodRight = dp[i+k-1].right;
                }
                else{
                    periodLeft = dp[i+k-1].left - dp[i-1].left;
                    periodRight = dp[i+k-1].right - dp[i-1].right;
                }
                
                if(periodLeft == periodRight){
                    ans = max(ans,k);
                }
            }
        }
        return ans;
    }
};
```



### 正确dp

是我想不到的dp捏。

这道题的dp[i]表示的是i位置的最大长度，也就是直接是结果。

至于递推公式分两种情况：

1. 如果s[i] == ')' 且 s[i-1] == '('
   $$
   dp[i] = dp[i-2] + 2
   $$

2. 如果s[i] == ')' 且 s[i-1] == ')' 且 s[i-dp[i-1]-1] == '('
   $$
   dp[i] = dp[i-1] + 2 + dp[i-dp[i-1]-2]
   $$
   

其实挺难想的，第一种情况很合理，第二种情况比较难想清楚。硬要说的话就是，就是我们要去找到 s[i]的 ')' 对应的 '('， 那么就去判断 s[i-dp[i-1]-1] == '('，如果成立，那么就可以加2。此外，还需要加上s[i-1]那一组括号的结果 dp[i-1]，以及再之前的结果，也就是 dp[i-dp[i-1]-2]。

```cpp
class Solution {
public:

    int longestValidParentheses(string s) {
        int ans = 0;
        int dp[30005]; //dp[i]表示i位置的最长有效括号
        memset(dp,0,sizeof(dp));
        int len = s.size();
        for(int i=1;i<len;i++){
            if(s[i] == ')' && s[i-1] == '('){
                dp[i] = 2 + (i>=2 ? dp[i-2] : 0);
            }
            if(s[i] == ')' && s[i-1] == ')'){
                if(i-dp[i-1]-1 >= 0 && s[i-dp[i-1]-1] == '('){
                    dp[i] = dp[i-1] + 2 + ((i-dp[i-1]-2) >= 0 ? dp[i-dp[i-1]-2]:0);
                }
                
            }
        }
        for(int i=0;i<len;i++){
            ans = max(ans,dp[i]);
        }
        return ans;
    }
};
```



## 题目链接

[32. 最长有效括号 - 力扣（LeetCode）](https://leetcode.cn/problems/longest-valid-parentheses/submissions/)