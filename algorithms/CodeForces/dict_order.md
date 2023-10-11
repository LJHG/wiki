---
title: 删除一个元素让字典序最小
date: 2023-10-11 19:16:20
tags: [单调栈]
---
# 删除一个元素让字典序最小
> 日期: 2023-10-11

## 题目描述

遇到了一个场景，差不多就是对于一个字符串，每一次删除其中一个元素，要使得删除后的字符串的字典序最小。

然后把这些字符串拼在一起，给定一个pos，输出pos位置对应的字符。

## 解题思路

最开始想错了，以为是删除字符串里面最大的元素，其实不是，应该是删除字符串里面最靠前的一个元素，并且这个元素满足当前元素值比下一个元素大。

比如说 cdea，那么顺序应该是先删除e，再删除d，再删除c，最后删除a。

这满足一个单调栈的结构，所以这里使用了一个单调栈来做。

大致就是这样的一个思路

```c++
int n = s.size();
vector<int> order(n, 0);
stack <int> st;
int idx = 0;
for(int i=0;i<n;i++){
    while(!st.empty() && s[st.top()] > s[i]){
        order[st.top()] = idx;
        idx += 1;
        st.pop();
    }
    st.push(i);
}
while(!st.empty()){
    order[st.top()] = idx;
    idx += 1;
    st.pop();
}
```



确定了删除顺序后，后面要找第pos个位置的字符就很简单了，先找到属于第几次删除后的结果，然后把这个结果算出来，最后找到就行了。

```cpp
#include<bits/stdc++.h>
using namespace std;
int main(){
    int t;
    cin >> t;
    while(t--){
        string s;
        cin >> s;
        long long pos;
        cin >> pos;
        // 确定一个删除顺序
        int n = s.size();
        vector<int> order(n, 0);
        stack <int> st;
        int idx = 0;
        for(int i=0;i<n;i++){
            while(!st.empty() && s[st.top()] > s[i]){
                order[st.top()] = idx;
                idx += 1;
                st.pop();
            }
            st.push(i);
        }
        while(!st.empty()){
            order[st.top()] = idx;
            idx += 1;
            st.pop();
        }
        // 查找pos来自于第几个序列
        long long sequenceIdx = 0;
        long long curLen = n;
        while(1){
            if(pos - curLen <= 0){
                break;
            }else{
                sequenceIdx += 1;
                pos -= curLen;
                curLen -= 1;
            }
        }
        // 构建出答案
        string tmp = "";
        for(int i=0;i<n;i++){
            if(order[i] >= sequenceIdx){
                tmp += s[i];
            }
        }

        cout<<tmp[pos-1];
    }
    return 0;
}
```



## 题目链接

[Problem - C - Codeforces](https://codeforces.com/contest/1886/problem/C)