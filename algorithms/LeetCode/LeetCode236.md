---
title: 二叉树的最近公共祖先---LeetCode236(后序遍历实现自底向上查找)
date: 2023-01-11 16:46:58
tags: [后序遍历, 二叉树]
---
# 二叉树的最近公共祖先---LeetCode236(后序遍历实现自底向上查找)
> 日期: 2023-01-11

## 题目描述

给定一个二叉树, 找到该树中两个指定节点的最近公共祖先。

百度百科中最近公共祖先的定义为：“对于有根树 T 的两个节点 p、q，最近公共祖先表示为一个节点 x，满足 x 是 p、q 的祖先且 x 的深度尽可能大（一个节点也可以是它自己的祖先）。”

## 示例

```
输入：root = [3,5,1,6,2,0,8,null,null,7,4], p = 5, q = 1
输出：3
解释：节点 5 和节点 1 的最近公共祖先是节点 3 。
```

```
输入：root = [1,2], p = 1, q = 2
输出：1
```

## 解题思路

这道题以前我写过一个最暴力的思路，就是自顶向下遍历，然后对于每个节点都去判断该节点是否为p 和 q的祖先节点，因为太过暴力这里就不多说了。

这里主要说一下后序遍历的方法。因为后序遍历是**左右中**，所以就可以实现一种对整棵树自底向上遍历的效果。

```cpp
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
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        if(root == nullptr) return nullptr;
        if(root == q || root == p) return root;
        TreeNode* left =  lowestCommonAncestor(root->left,p,q);
        TreeNode* right = lowestCommonAncestor(root->right,p,q);
        if(left != nullptr && right != nullptr) return root;
        if(left != nullptr) return left;
        return right;
    }
};
```

还是要稍微注意一下写法，不然容易把自己绕进去。最开始几行就是递归的返回条件，下面是左遍历，右遍历和中间的遍历。

## 题目链接

[236. 二叉树的最近公共祖先 - 力扣（LeetCode）](https://leetcode.cn/problems/lowest-common-ancestor-of-a-binary-tree/)