---
title: 字符串解码---LeetCode394(栈)
date: 2023-09-28 15:57:39
tags: [栈]
---
# 字符串解码---LeetCode394(栈)
> 日期: 2023-09-28

## 题目描述

给定一个经过编码的字符串，返回它解码后的字符串。

编码规则为: `k[encoded_string]`，表示其中方括号内部的 `encoded_string` 正好重复 `k` 次。注意 `k` 保证为正整数。

你可以认为输入字符串总是有效的；输入字符串中没有额外的空格，且输入的方括号总是符合格式要求的。

此外，你可以认为原始数据不包含数字，所有的数字只表示重复的次数 `k` ，例如不会出现像 `3a` 或 `2[4]` 的输入。

## 示例

```
示例 1：

输入：s = "3[a]2[bc]"
输出："aaabcbc"
示例 2：

输入：s = "3[a2[c]]"
输出："accaccacc"
示例 3：

输入：s = "2[abc]3[cd]ef"
输出："abcabccdcdcdef"
示例 4：

输入：s = "abc3[cd]xyz"
输出："abccdcdcdxyz"
```



## 解题思路

看起来简单的一道题做起来其实细节还蛮多的

最开始写了个dfs写了半天没写明白，然后还是用栈写吧，感觉和括号相关的题用栈写都会简单一些。

这里写一些注意的细节点吧：

1. 对于字母，首先去判断当前栈顶是否是字母，如果是的话，更新栈顶。数字同理。
2. 当遇到右括号时，一直将栈顶元素进行合并操作，也就是说，如果连续两个是都是字符串，那么直接将字符串合并，如果一个字符串一个数字，那么就repeat。这里还需要注意的一点是，当处理到左括号完了后，将左括号pop出去，有必要继续执行合并到下一个左括号之前。这样做的好处是处理完后栈里面的栈顶就是最终答案，不然还需要对栈再进行一次处理，来得到最终答案。

```cpp
class Solution {
public:
    string decodeString(string s) {
        stack<string> st;
        for(char c:s){
            if(c >= '0' && c <= '9'){
                string tmp = "";
                if(!st.empty() && st.top()[0] >= '0' && st.top()[0] <= '9' ){
                    tmp = st.top();
                    st.pop();
                }
                tmp += c;
                st.push(tmp);
            }else if(c >= 'a' && c <= 'z'){
                string tmp = "";
                if(!st.empty() && st.top()[0] >= 'a' && st.top()[0] <= 'z' ){
                    tmp = st.top();
                    st.pop();
                }
                tmp += c;
                st.push(tmp);
            }else if(c == '['){
                st.push("[");
            }else{
                // 右括号
                string tmp = "";
                while(!st.empty() && st.top() != "["){
                    if(st.top()[0] >= 'a' && st.top()[0] <= 'z'){
                        tmp = st.top() + tmp;
                    }else if(st.top()[0] >= '0' && st.top()[0] <= '9'){
                        string newTmp = "";
                        int cnt = stoi(st.top());
                        while(cnt--){
                            newTmp += tmp;
                        }
                        tmp = newTmp;
                    }
                    st.pop();
                }
                // 最顶上是左括号，pop掉
                st.pop();
                // 合并到下一个左括号
                while(!st.empty() && st.top() != "["){
                    if(st.top()[0] >= 'a' && st.top()[0] <= 'z'){
                        tmp = st.top() + tmp;
                    }else if(st.top()[0] >= '0' && st.top()[0] <= '9'){
                        string newTmp = "";
                        int cnt = stoi(st.top());
                        while(cnt--){
                            newTmp += tmp;
                        }
                        tmp = newTmp;
                    }
                    st.pop();
                }
                st.push(tmp);
            }
        }
        return st.top();
    }
};
```

## 题目链接

[394. 字符串解码 - 力扣（LeetCode）](https://leetcode.cn/problems/decode-string/)