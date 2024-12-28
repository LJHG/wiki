---
title: 二叉树灯饰---LeetCode-LCP64(树形dp 记忆化搜索)
date: 2023-03-07 19:59:45
tags: [dp, 记忆化搜索]
---
# 二叉树灯饰---LeetCode-LCP64(树形dp 记忆化搜索)
> 日期: 2023-03-07

## 题目描述

「力扣嘉年华」的中心广场放置了一个巨型的二叉树形状的装饰树。每个节点上均有一盏灯和三个开关。节点值为 0 表示灯处于「关闭」状态，节点值为 1 表示灯处于「开启」状态。每个节点上的三个开关各自功能如下：

开关 1：切换当前节点的灯的状态；
开关 2：切换 以当前节点为根 的子树中，所有节点上的灯的状态，；
开关 3：切换 当前节点及其左右子节点（若存在的话） 上的灯的状态；
给定该装饰的初始状态 root，请返回最少需要操作多少次开关，可以关闭所有节点的灯。



## 示例

```
输入：root = [1,1,0,null,null,null,1]
输出：2
```

```
输入：root = [1,1,1,1,null,null,1]
输出：1
```



## 解题思路

状态为: 节点， 该节点往前用的开关2是否为偶数， 该节点的父节点是否用了开关3

这道题是树形dp，可以选择把dfs的返回值弄成一个长度为4的向量来标识4种状态的答案，但是这样弄递推公式写出来太容易出错了。

所以我用了记忆化搜索的方式来写，但是使用记忆化搜索有一个问题，就是这里的状态中的一个维度是二叉树节点，也就是说会用到地址来作为第一维，所以一般的dp数据开得很难受，所以这里是用了一个unordered_map，这种方式还是第一次开。(PS：可以考虑遍历二叉树来为每一个节点赋予一个编号，那么就可以用一般的dp来开了)。

这种unordered_map的方式太过于奇葩，所以不知道以后写树形dp是不是还要用这种方式。。。

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */

class Solution {
public:
    //记忆化搜索  
    unordered_map<TreeNode*,int[2][2]> dp;
    int dfs(TreeNode* root, int switch2_odd, int switch3){
        if(root == nullptr) return 0;
        if(dp.count(root) > 0 && dp[root][switch2_odd][switch3] != -1){
            return dp[root][switch2_odd][switch3];
        }
        
        if(!dp.count(root))
        {
            memset(dp[root],-1,sizeof(dp[root]));
        }
        //灯为开，且 2 和 3 抵消，那么最后灯是开，要把灯关掉
        //选择奇数开关
        if( (root->val == 1) == (switch2_odd == switch3)){
            int res1 = dfs(root->left, switch2_odd, 0) + dfs(root->right, switch2_odd, 0) + 1;
            int res2 = dfs(root->left, !switch2_odd, 0) + dfs(root->right, !switch2_odd, 0) + 1;
            int res3 = dfs(root->left, switch2_odd, 1) + dfs(root->right, switch2_odd, 1) + 1;
            int res123 = dfs(root->left, !switch2_odd, 1) + dfs(root->right, !switch2_odd, 1) + 3;
            dp[root][switch2_odd][switch3] = min(min(min(res1,res2),res3),res123);
        }
        // 最后灯为关，要把灯关掉
        // 选择偶数开关或者不做操作
        else{
            int res = dfs(root->left, switch2_odd, 0) + dfs(root->right, switch2_odd, 0);
            int res12 = dfs(root->left, !switch2_odd, 0) + dfs(root->right, !switch2_odd, 0) + 2;
            int res13 = dfs(root->left, switch2_odd, 1) + dfs(root->right, switch2_odd, 1) + 2;
            int res23 = dfs(root->left, !switch2_odd, 1) + dfs(root->right, !switch2_odd, 1) + 2;
            dp[root][switch2_odd][switch3] = min(min(min(res,res12),res13),res23);
        }
        
        return dp[root][switch2_odd][switch3];
    }

    int closeLampInTree(TreeNode* root) {
        return dfs(root,0,0);
    }
};
```



## 题目链接

[LCP 64. 二叉树灯饰 - 力扣（LeetCode）](https://leetcode.cn/problems/U7WvvU/)