---
title: 恢复二叉搜索树---LeetCode99(DFS+中序遍历)
date: 2022-09-22 17:18:34
tags: [DFS, 中序遍历]
---
# 恢复二叉搜索树---LeetCode99(DFS+中序遍历)
> 日期: 2022-09-22

## 题目描述

给你二叉搜索树的根节点 `root` ，该树中的 **恰好** 两个节点的值被错误地交换。*请在不改变其结构的情况下，恢复这棵树* 。

## 示例


输入：root = [1,3,null,null,2]
输出：[3,1,null,null,2]
解释：3 不能是 1 的左孩子，因为 3 > 1 。交换 1 和 3 使二叉搜索树有效。

输入：root = [3,1,4,null,null,2]
输出：[2,1,4,null,null,3]
解释：2 不能在 3 的右子树中，因为 2 < 3 。交换 2 和 3 使二叉搜索树有效。


提示：

树上节点的数目在范围 [2, 1000] 内
-231 <= Node.val <= 231 - 1

来源：力扣（LeetCode）

## 解题思路

### 复习中序遍历

对于一个正确的二叉搜索树，如果对其进行中序遍历，那么输出应该是升序的，然后只需要找到序列里不合理的两个位置即可。

首先得实现中序遍历，中序遍历的模板是这样的：

```cpp
void inOrder(TreeNode* root, vector<int>& nums){
        if(root == nullptr) return;
        inOrder(root->left, nums);
        nums.push_back(root->val);
        inOrder(root->right,nums);
}
```

### 如何找到一个序列里不合理的两个位置

这里最开始我想到的是为开头添加一个特别小的数字，为最后添加一个特别大的数字，然后去找一个波峰和一个波谷，从而找到这两个不合理的位置，但是这种方法是有问题的。

举个例子，比如说原来的数字是:

`[1,2,3,4,5]`

现在我们将其调换为:

`[5,2,3,4,1]`，

经过预处理后变为:

`[-10001, 5, 2 ,3, 4, 1, 10001]`

这个情况下，5是波峰，2是波谷，4是波峰，1是波谷，这显然是不合理的，所以这种方法不能用。

官方给出的题解是这样的：

去寻找下降趋势的数字，如果第一个数字还没找到，那么两个都赋值(相邻两个数字互相交换的情况)，然后继续往后看，找另外一个数字。

其实这里我有一点没看懂。。。

```cpp
vector<int> findSwap(vector<int>& nums) {
        int n = nums.size();
        int index1 = -1, index2 = -1;
        for (int i = 0; i < n - 1; ++i) {
            if (nums[i + 1] < nums[i]) {
                index2 = i + 1;
                if (index1 == -1) {
                    index1 = i;
                } else {
                    break;
                }
            }
        }
        int x = nums[index1], y = nums[index2];
        vector<int> ans;
        ans.push_back(x);
        ans.push_back(y);
        return ans;
    }
```



### 其它解法

其实这道题还有一些其它的解法，比如说不需要将中序遍历的nums存下来，而是在中序遍历的过程中进行交换，以及复杂度是O(1)的Morris中序遍历，这里就先不管了。。。



## 题目链接

[99. 恢复二叉搜索树 - 力扣（LeetCode）](https://leetcode.cn/problems/recover-binary-search-tree/)