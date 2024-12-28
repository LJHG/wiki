---
title: 二叉树里的最大路径和---LeetCode124(别再错了)
date: 2023-08-05 17:13:22
tags: [二叉树, 树形dp]
---
# 二叉树里的最大路径和
> 日期: 2023-08-05

## 题目描述
二叉树中的 路径 被定义为一条节点序列，序列中每对相邻节点之间都存在一条边。同一个节点在一条路径序列中 至多出现一次 。该路径 至少包含一个 节点，且不一定经过根节点。
路径和 是路径中各节点值的总和。
给你一个二叉树的根节点 root ，返回其 最大路径和 。

## 示例
输入：root = [1,2,3]
输出：6
解释：最优路径是 2 -> 1 -> 3 ，路径和为 2 + 1 + 3 = 6

## 解题思路
xhs面试碰到了，一道不算hard的hard吧。。但是我写成从root出发到叶子的最大路径和了QAQ，反应过来时已经来不及了，哭。
尤其是事后发现这道题我做过，而且是LeetCode hot100，太悲伤了，引以为戒。

虽然这道题算不上hard，但是还是有一些需要注意的，比如说全局答案的更新和dfs的返回值其实是不同的，原因是这里的dfs的返回值表示的是从一个节点往下走，不走回头路的最大值，所以其实只能选择走左边或者走右边。但是在更新ans的时候就要同时加上左边和右边啦。
```cpp
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    int ans = INT_MIN;
    int dfs(TreeNode* root){
        if(root == nullptr) return 0;
        int leftMax = max(dfs(root->left), 0);
        int rightMax = max(dfs(root->right), 0);
        ans = max(ans, leftMax + rightMax + root->val);
        return root->val + max(leftMax, rightMax);
    }
    int maxPathSum(TreeNode* root) {
        dfs(root);
        return ans;
    }
};
```


    
## 题目链接
https://leetcode.cn/problems/binary-tree-maximum-path-sum/
