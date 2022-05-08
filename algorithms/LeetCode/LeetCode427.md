---
title: 建立四叉树---LeetCode427(dfs)
date: 2022-04-29 13:12:53
tags: [dfs]
---
# 建立四叉树---LeetCode427(dfs)
## 题目描述
给你一个 n * n 矩阵 grid ，矩阵由若干 0 和 1 组成。请你用四叉树表示该矩阵 grid 。

你需要返回能表示矩阵的 四叉树 的根结点。

注意，当 isLeaf 为 False 时，你可以把 True 或者 False 赋值给节点，两种值都会被判题机制 接受 。

四叉树数据结构中，每个内部节点只有四个子节点。此外，每个节点都有两个属性：

val：储存叶子结点所代表的区域的值。1 对应 True，0 对应 False；
isLeaf: 当这个节点是一个叶子结点时为 True，如果它有 4 个子节点则为 False 。

```cpp
class Node {
    public boolean val;
    public boolean isLeaf;
    public Node topLeft;
    public Node topRight;
    public Node bottomLeft;
    public Node bottomRight;
}
```

我们可以按以下步骤为二维区域构建四叉树：

1. 如果当前网格的值相同（即，全为 0 或者全为 1），将 isLeaf 设为 True ，将 val 设为网格相应的值，并将四个子节点都设为 Null 然后停止。
2. 如果当前网格的值不同，将 isLeaf 设为 False， 将 val 设为任意值，然后如下图所示，将当前网格划分为四个子网格。
3. 使用适当的子网格递归每个子节点。

四叉树格式：

输出为使用层序遍历后四叉树的序列化形式，其中 null 表示路径终止符，其下面不存在节点。

它与二叉树的序列化非常相似。唯一的区别是节点以列表形式表示 [isLeaf, val] 。

如果 isLeaf 或者 val 的值为 True ，则表示它在列表 [isLeaf, val] 中的值为 1 ；如果 isLeaf 或者 val 的值为 False ，则表示值为 0 。
## 示例

```
输入：grid = [[0,1],[1,0]]
输出：[[0,1],[1,0],[1,1],[1,1],[1,0]]

输入：grid = [[1,1,1,1,0,0,0,0],[1,1,1,1,0,0,0,0],[1,1,1,1,1,1,1,1],[1,1,1,1,1,1,1,1],[1,1,1,1,0,0,0,0],[1,1,1,1,0,0,0,0],[1,1,1,1,0,0,0,0],[1,1,1,1,0,0,0,0]]
输出：[[0,1],[1,1],[0,1],[1,1],[1,0],null,null,null,null,[1,0],[1,0],[1,1],[1,1]]

```



## 解题思路

建立四叉树想法还是比较简单，就是一直dfs往下分就行了。。。分到最小无法再分了就往上返回，同时父亲节点要判断四个儿子是不是一样的，如果都是一样的叶子，那么就砍了把自己也变成叶子。

需要注意的地方：

1. 如果我们给定一个正方形的左上角和右下角来进行dfs，那么需要求出它的middle，这里的middle不能只求一个，或者说需要判断什么应该用middle，什么时候应该用middle+1。比如对于左上角的部分，在进行dfs时，就使用`(x1,y1,middleX,middleY)`, 而对于右下角部分需要使用`(middleX+1,middleY+1,x2,y2)`。
2. 在将儿子进行合并时，不仅要它们的val相同，还需要都是叶子结点，因为如果不是叶子结点的话，val其实是一个没有意义的值。

具体代码如下：

```cpp
/*
// Definition for a QuadTree node.
class Node {
public:
    bool val;
    bool isLeaf;
    Node* topLeft;
    Node* topRight;
    Node* bottomLeft;
    Node* bottomRight;
    
    Node() {
        val = false;
        isLeaf = false;
        topLeft = NULL;
        topRight = NULL;
        bottomLeft = NULL;
        bottomRight = NULL;
    }
    
    Node(bool _val, bool _isLeaf) {
        val = _val;
        isLeaf = _isLeaf;
        topLeft = NULL;
        topRight = NULL;
        bottomLeft = NULL;
        bottomRight = NULL;
    }
    
    Node(bool _val, bool _isLeaf, Node* _topLeft, Node* _topRight, Node* _bottomLeft, Node* _bottomRight) {
        val = _val;
        isLeaf = _isLeaf;
        topLeft = _topLeft;
        topRight = _topRight;
        bottomLeft = _bottomLeft;
        bottomRight = _bottomRight;
    }
};
*/

class Solution {
public:
    Node* _constrcut(vector<vector<int>>& grid, int x1,int y1,int x2,int y2){
        if( x1 == x2 && y1 == y2){
            return new Node(grid[x1][y1], true);
        }
        int middleX1 = (x1 + x2)/2;
        int middleY1 = (y1 + y2)/2;
        int middleX2 = (x1 + x2)/2 + 1;
        int middleY2 = (y1 + y2)/2 + 1;
        Node* node1 = _constrcut(grid,x1,y1,middleX1,middleY1);
        Node* node2 = _constrcut(grid,x1,middleY2,middleX1,y2);
        Node* node3 = _constrcut(grid,middleX2,y1,x2,middleY1);
        Node* node4 = _constrcut(grid,middleX2,middleY2,x2,y2);
        if(node1->val == node2->val && node2->val ==node3->val && node3->val == node4->val && node1->isLeaf == true && node2->isLeaf == true && node3->isLeaf == true && node4->isLeaf == true){
            return new Node(node1->val,true);
        }else{
            return new Node(-1,false,node1,node2,node3,node4);
        }

    }

    Node* construct(vector<vector<int>>& grid) {
        int row = grid.size();
        int col = grid[0].size();
        return _constrcut(grid,0,0,row-1,col-1);
    }
};
```



## 题目链接

[427. 建立四叉树 - 力扣（LeetCode） (leetcode-cn.com)](https://leetcode-cn.com/problems/construct-quad-tree/)