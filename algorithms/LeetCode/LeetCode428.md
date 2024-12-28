---
title: 找到字符串中所有字符异位词---LeetCode428(双指针哈希表)
date: 2023-10-04 17:34:30
tags: [双指针,哈希]
---
# 找到字符串中所有字符异位词---LeetCode428(双指针哈希表)
> 日期: 2023-10-04

## 题目描述

给定两个字符串 `s` 和 `p`，找到 `s` 中所有 `p` 的 **异位词** 的子串，返回这些子串的起始索引。不考虑答案输出的顺序。

**异位词** 指由相同字母重排列形成的字符串（包括相同的字符串）。

## 示例

**示例 1:**

```
输入: s = "cbaebabacd", p = "abc"
输出: [0,6]
解释:
起始索引等于 0 的子串是 "cba", 它是 "abc" 的异位词。
起始索引等于 6 的子串是 "bac", 它是 "abc" 的异位词。
```

 **示例 2:**

```
输入: s = "abab", p = "ab"
输出: [0,1,2]
解释:
起始索引等于 0 的子串是 "ab", 它是 "ab" 的异位词。
起始索引等于 1 的子串是 "ba", 它是 "ab" 的异位词。
起始索引等于 2 的子串是 "ab", 它是 "ab" 的异位词。
```

## 解题思路

### 滑动窗口 + 哈希表

这道题一看到就想用双指针+哈希表，但是因为是固定长度的，所以就使用的一个滑动窗口。

考虑到一共只有26个字母，所以对于每一个滑动窗口，都去判断是否是合法的也不会超时。时间复杂度是O(26 * n)。

```cpp
class Solution {
public:
    unordered_map<char,int> ms;
    unordered_map<char,int> mp;
    
    bool equal(){
        for(auto& x:mp){
            if(ms[x.first] != x.second) return false;
        }
        return true;
    }

    vector<int> findAnagrams(string s, string p) {
        for(char c:p) mp[c]++;
        int len = p.size();
        for(int i=0;i<len;i++){
            ms[s[i]]++;
        }
        vector<int> ans;
        if(equal()) ans.push_back(0);
        for(int i=len; i<s.size();i++){
            ms[s[i-len]]--;
            ms[s[i]]++;
            if(equal()) ans.push_back(i-len+1);
        }
        return ans;
    }
    
};
```

### 双指针 + 哈希表

但是总感觉对于每一个窗口去做一个遍历判断还是比较不优雅，这道题只有26个字母还有，再多就不好做了。

所以这里可以使用双指针+哈希表的方法来做，因为知道了答案的长度一定是固定的，所以可以通过判断答案长度是否等于目标长度来看是否满足条件。

```cpp
class Solution {
public:
    vector<int> findAnagrams(string s, string p) {
        vector<int> ans;
        unordered_map<char,int> mp;
        unordered_map<char,int> ms;
        for(char c:p){
            mp[c]++;
        }
        int left = 0;
        for(int right=0; right<s.size();right++){
            ms[s[right]]++;
            while(ms[s[right]] > mp[s[right]]){
                ms[s[left]]--;
                left++;
            }
            // 根据长度来判断是否满足条件
            if(right - left + 1 == p.size()){
                ans.push_back(left);
            }
        }
        return ans;
    }
};
```



## 题目链接

[438. 找到字符串中所有字母异位词 - 力扣（LeetCode）](https://leetcode.cn/problems/find-all-anagrams-in-a-string/description/)