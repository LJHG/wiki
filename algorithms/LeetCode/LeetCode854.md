---
title: 用BFS解决交换问题---LeetCode854(BFS)
date: 2022-09-21 20:11:11
tags: [BFS]
---
# 用BFS解决交换问题---LeetCode854(BFS)
> 日期: 2022-09-21

## 题目描述
对于某些非负整数 k ，如果交换 s1 中两个字母的位置恰好 k 次，能够使结果字符串等于 s2 ，则认为字符串 s1 和 s2 的 相似度为 k 。

给你两个字母异位词 s1 和 s2 ，返回 s1 和 s2 的相似度 k 的最小值。
## 示例
示例 1：

输入：s1 = "ab", s2 = "ba"
输出：1
示例 2：

输入：s1 = "abc", s2 = "bca"
输出：2
    
## 解题思路

好久没有做过这么难的题了。。。是我太菜。

这道题就是直接用bfs来做暴力搜索，然后使用一个unordered_set来记录已经处理过的序列，如果处理过了就直接剪枝，看起来很简单但是其实写起来还挺麻烦的。。。而且对于一道bfs的题来说，这道题有一些非主流。

首先完整的代码在这里：

```cpp
class Solution {
public:
    vector<string> next(string& s1, string& s2){
        vector<string> nexts;
        int len = s1.size();
        int i = 0;
        for(i=0;i<len;i++){
            if(s1[i] != s2[i]){
                break;
            }
        }
        for(int j=i+1;j<len;j++){
            if(s1[i] == s2[j]){
                swap(s1[i],s1[j]);
                nexts.push_back(s1);
                swap(s1[i],s1[j]);
            }
        }
        return nexts;
    }

    int kSimilarity(string s1, string s2) {
        queue<string> q;
        unordered_set<string> vis;
        q.push(s1);
        vis.insert(s1);
        int ans = 0;
        while(1){
            int len = q.size();
            for(int i =0; i<len;i++){
                string curString = q.front();
                q.pop();
                if(curString == s2){
                    return ans;
                }
                for(auto& x:next(curString,s2)){
                    if(!vis.count(x)){ //还没找过
                        vis.insert(x);
                        q.push(x);
                    }
                }
            }
            ans += 1;
        }
    }
};
```

### 我不小心写成双重循环了

这里使用了一个next函数来判断，对于一个前面有一定长度已经匹配好的字符串`s1`，它后续允许进行哪些变换来使得它能够更为接近`s2`。

上面的这种写法是没有问题的，但是之前我写的是另外一种写法，这种写法会直接tle，也比较傻逼。

```cpp
vector<string> next(string& s1, string& s2){
        vector<string> nexts;
        int len = s1.size();
        for(int i=0;i<len;i++){
            if(s1[i] == s2[i]){
                continue;
            }
            for(int j=i+1;j<len;j++){
                if(s1[i] == s2[j]){
                    swap(s1[i],s1[j]);
                    nexts.push_back(s1);
                    swap(s1[i],s1[j]);
                }
            }
        }
        return nexts;
    }
```

这种写法是直接套了两层循环(🙅‍♂️)，这相当于是把i这个位置后的字符串也拿进来处理了，但是这是不对的，因为你首先得保证i这个位置匹配好了。

### for循环的坑点

这个完全是我的问题了，当然也是因为这道题的BFS比较非主流。

一般来说，BFS都是

```cpp
while(!q.empty()){
	// some code
}
```

但是这道题不行，因为我没有带着ans去dfs。如果用一个结构体去存ans的话，其实也可以写成上面的那种写法。

不过这里我就是直接ans++了，因此写法就变成了:

```cpp
while(1){
	for(xxxxx){
		xxx
	}
}
```

这里正确的写法是:

```cpp
int len = q.size();
for(int i =0; i<len;i++){
```

但是如果直接写成了

```cpp
for(int i =0; i<q.size();i++){
```

就寄了，因为q的size一直在变。一般很少碰到这个问题所以也没引起我的注意，仔细一想这么写就是有问题的，因为每次判断时都会去读取q.size()，当然如果你写成

```cpp
for(int i =q.size(); i>0;i--){
```

就没问题了，因为初始化这里只有一次。

感觉这种坑写在这里有点侮辱智商，不过。。。至少也是坑过我的。。。是我太菜。




## 题目链接

[854. 相似度为 K 的字符串 - 力扣（LeetCode）](https://leetcode.cn/problems/k-similar-strings/)

[[Python3/Java/C++/Go\] 一题双解：朴素 BFS + 启发式 A* 搜索 - 相似度为 K 的字符串 - 力扣（LeetCode）](https://leetcode.cn/problems/k-similar-strings/solution/-by-lcbin-snnw/)


