---
title: 找出游戏的获胜者---LeetCode1823(队列模拟链表，数学)
date: 2022-05-04 12:24:22
tags: [数学, 队列，链表]
---
# 找出游戏的获胜者---LeetCode1823(队列模拟链表，数学)
## 题目描述

共有 n 名小伙伴一起做游戏。小伙伴们围成一圈，按 顺时针顺序 从 1 到 n 编号。确切地说，从第 i 名小伙伴顺时针移动一位会到达第 (i+1) 名小伙伴的位置，其中 1 <= i < n ，从第 n 名小伙伴顺时针移动一位会回到第 1 名小伙伴的位置。

游戏遵循如下规则：

从第 1 名小伙伴所在位置 开始 。
沿着顺时针方向数 k 名小伙伴，计数时需要 包含 起始时的那位小伙伴。逐个绕圈进行计数，一些小伙伴可能会被数过不止一次。
你数到的最后一名小伙伴需要离开圈子，并视作输掉游戏。
如果圈子中仍然有不止一名小伙伴，从刚刚输掉的小伙伴的 顺时针下一位 小伙伴 开始，回到步骤 2 继续执行。
否则，圈子中最后一名小伙伴赢得游戏。
给你参与游戏的小伙伴总数 n ，和一个整数 k ，返回游戏的获胜者。

## 示例

<img src="https://assets.leetcode.com/uploads/2021/03/25/ic234-q2-ex11.png" alt="img" style="zoom: 50%;" />

```
输入：n = 5, k = 2
输出：3
解释：游戏运行步骤如下：
1) 从小伙伴 1 开始。
2) 顺时针数 2 名小伙伴，也就是小伙伴 1 和 2 。
3) 小伙伴 2 离开圈子。下一次从小伙伴 3 开始。
4) 顺时针数 2 名小伙伴，也就是小伙伴 3 和 4 。
5) 小伙伴 4 离开圈子。下一次从小伙伴 5 开始。
6) 顺时针数 2 名小伙伴，也就是小伙伴 5 和 1 。
7) 小伙伴 1 离开圈子。下一次从小伙伴 3 开始。
8) 顺时针数 2 名小伙伴，也就是小伙伴 3 和 5 。
9) 小伙伴 5 离开圈子。只剩下小伙伴 3 。所以小伙伴 3 是游戏的获胜者。

```



## 解题思路

### 1. 用队列模拟链表

是的，是可以直接用队列来模拟一个循环链表的。。。你只需要一直push再pop就行了。。

```cpp
class Solution {
public:
    int findTheWinner(int n, int k) {
        queue<int> q;
        for(int i=1;i<=n;i++){
            q.push(i);
        }
        while(q.size()>1){
            for(int i=0;i<k-1;i++){
                int top = q.front();
                q.pop();
                q.push(top);
            }
            q.pop();
        }
        return q.front();
    }
};
```

### 2. 约瑟夫环

这个问题其实就是一个约瑟夫环的问题，总的来说就是约瑟夫环服从一个递推公式：

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202205041230239.png" alt="image-20220504123004199" style="zoom:50%;" />

所以就可以直接开始推了：

```cpp
class Solution {
public:
    int findTheWinner(int n, int k) {
        int p = 0;      
        for(int i=2;i<=n;i++){
            p = (p + k)%i;
        }
        return p+1;
    }
};
```



## 题目链接

[1823. 找出游戏的获胜者 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/find-the-winner-of-the-circular-game/)

[约瑟夫环——公式法（递推公式）_陈浅墨的博客-CSDN博客_约瑟夫环数学公式](https://blog.csdn.net/u011500062/article/details/72855826)