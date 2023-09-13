---
title: 单词拆分---LeetCode139(背包和字符串)
date: 2023-02-20 11:22:04
tags: [dp]
---
# 单词拆分---LeetCode139(背包和字符串)
> 日期: 2023-02-20

## 题目描述

给你一个字符串 s 和一个字符串列表 wordDict 作为字典。请你判断是否可以利用字典中出现的单词拼接出 s 。

注意：不要求字典中出现的单词全部都使用，并且字典中的单词可以重复使用。

## 示例

```
输入: s = "leetcode", wordDict = ["leet", "code"]
输出: true
解释: 返回 true 因为 "leetcode" 可以由 "leet" 和 "code" 拼接成。

```

```
输入: s = "applepenapple", wordDict = ["apple", "pen"]
输出: true
解释: 返回 true 因为 "applepenapple" 可以由 "apple" "pen" "apple" 拼接成。
     注意，你可以重复使用字典中的单词。
```

```
输入: s = "catsandog", wordDict = ["cats", "dog", "sand", "and", "cat"]
输出: false
```



## 解题思路

### 备忘录思路

个人感觉使用dfs + 备忘录的方式会更加清晰，所以把这个题解放在前面。

```cpp
class Solution {
public:
    // dfs + 备忘录写法
    map<pair<string,int>, bool> m;
    bool dfs(string& s, int idx, vector<string>& wordDict){
        if(idx == s.size()) return true;
        if(m.count(make_pair(s,idx))) return m[make_pair(s,idx)];
        bool ans = false;
        for(string& word:wordDict){
            if(s.size() - idx < word.size()) continue;
            bool valid = true;
            for(int i=0;i<word.size();i++){
                if(s[idx+i] != word[i]){
                    valid = false;
                    break;
                }
            }
            if(valid){
                ans |= dfs(s, idx+word.size(), wordDict);
            }
        }
        m[make_pair(s,idx)] = ans;
        return ans;
    }
    bool wordBreak(string s, vector<string>& wordDict) {
        return dfs(s, 0, wordDict);
    }
};
```



### 背包思路

首先，可以重复使用，所以判断为完全背包。

因为顺序是很重要的，比如说 leetcode 是 由 leet 和 code 组成的，而不是由 code 和 leet 组成的，所以完全背包应该先遍历容量，再遍历物品。

然后就可以dp了

```cpp
class Solution {
public:
    bool wordBreak(string s, vector<string>& wordDict) {
        unordered_set<string> wordSet(wordDict.begin(), wordDict.end());
        //完全背包
        vector<bool> dp(s.size() + 1, false);
        dp[0] = true;
        for(int i=1;i<=s.size();i++){
            for(int j=0; j<i; j++){
                string word = s.substr(j, i-j);
                if(wordSet.find(word) != wordSet.end() && dp[j]){
                    dp[i] = true;
                }
            }
        }
        return dp[s.size()];
    }
};
```

> 其实像这种和传统的背包问题已经不是特别像的题，感觉也不是特别有必要把思路往背包上面靠了，直接想dp说不定还更容易一些(可能吧)



## 题目链接

[139. 单词拆分 - 力扣（LeetCode）](https://leetcode.cn/problems/word-break/)