---
title: 打家劫舍III---LeetCode337(树形dp)
date: 2023-02-24 12:15:39
tags: [dp]
---
# 打家劫舍III---LeetCode337(树形dp)
> 日期: 2023-02-24

## 题目描述

小偷又发现了一个新的可行窃的地区。这个地区只有一个入口，我们称之为 root 。

除了 root 之外，每栋房子有且只有一个“父“房子与之相连。一番侦察之后，聪明的小偷意识到“这个地方的所有房屋的排列类似于一棵二叉树”。 如果 两个直接相连的房子在同一天晚上被打劫 ，房屋将自动报警。

给定二叉树的 root 。返回 在不触动警报的情况下 ，小偷能够盗取的最高金额 。

## 示例

```
输入: root = [3,2,3,null,3,null,1]
输出: 7 
解释: 小偷一晚能够盗取的最高金额 3 + 3 + 1 = 7

输入: root = [3,4,5,1,3,null,1]
输出: 9
解释: 小偷一晚能够盗取的最高金额 4 + 5 = 9
```



## 解题思路

第一次做树形dp相关的题目，本来以为会是类似状压dp之类的解法，其实不是。

感觉树形dp就是在树的节点保存一些信息，然后通过递归的方式来用这些信息，而不需要把所有的信息存下来。所以dp数组不需要开很大，比如这道题就只开了2，0表示不取，1表示取。

```c++
class Solution {
public:
    int rob(TreeNode* root) {
        vector<int> result = robTree(root);
        return max(result[0], result[1]);
    }

    // 0表示不取, 1表示取
    vector<int> robTree(TreeNode* rob){
        if(rob == nullptr) return {0,0};
        //后序遍历
        vector<int> left = robTree(rob->left);
        vector<int> right = robTree(rob->right);
        vector<int> curVal = {0,0};
        //取中间节点, 左右不能取
        curVal[1] = rob->val + left[0] + right[0];
        //不取中间节点, 左右可以取,也可以不取
        curVal[0] = max(left[0],left[1]) + max(right[0],right[1]);
        return {curVal[0], curVal[1]};
    }
};
```



## 题目链接

[337. 打家劫舍 III - 力扣（LeetCode）](https://leetcode.cn/problems/house-robber-iii/)