---
title: 到达终点---LeetCode780
date: 2022-04-09 13:25:43
tags: [智力题]
---
## 题目描述：
给定四个整数 sx , sy ，tx 和 ty，如果通过一系列的转换可以从起点 (sx, sy) 到达终点 (tx, ty)，则返回 true，否则返回 false。

从点 (x, y) 可以转换到 (x, x+y)  或者 (x+y, y)。

## 示例：
```
示例 1:

输入: sx = 1, sy = 1, tx = 3, ty = 5
输出: true
解释:
可以通过以下一系列转换从起点转换到终点：
(1, 1) -> (1, 2)
(1, 2) -> (3, 2)
(3, 2) -> (3, 5)
示例 2:

输入: sx = 1, sy = 1, tx = 2, ty = 2 
输出: false
示例 3:

输入: sx = 1, sy = 1, tx = 1, ty = 1 
输出: true
```

## 解题思路: 
首先这道题明显是用倒推来做，不可能正着解，不然情况太多了。
这道题最开始一来我做成了递归，就是每次直接`return reachingPoints(sx,sy,tx-ty,ty) || reachingPoints(sx,sy,tx,ty-tx)`, 乍一看很合理，但是其实忽略了一个非常重要的先决条件，那就是只有在 tx > ty时，才能调`reachingPoints(sx,sy,tx-ty,ty)`，只有在ty > tx时，才能调`reachingPoints(sx,sy,tx,ty-tx)`。

同时，我还考虑过使用dp来做，就是倒着推回去，但是一看数据范围1e9,那必然不能用dp来做了，除非做一些状态压缩啥的，但是那也走远了。

但是仔细一想，这道题好像和dp并没有啥关系，因为反正就是一路推回去就行了，又不用记录一下什么值，能够推回去就ok，推不回去就g。

所以思路还是和递归是一样的，只不过需要做一点改进，那就是不能每次就推一步，要推很多步，所以就要用到mod。
也就是说，当 tx 比 ty 大时，`tx = tx % ty`,当 ty 比 tx 大时，`ty = ty % tx`。就这样一直做，直到tx等于sx或者ty等于sy，如果还小于了，那直接就没了。

接下来就是一些简单的if else了，比如说当sx等于tx时，那么就看ty能不能变到sy去，也就是说判断一下 `(ty-sy)%tx == 0)` 是否成立，其他的一些情况同理。

最后代码如下：
```cpp
class Solution {
public:
    bool reachingPoints(int sx, int sy, int tx, int ty) {
        while(tx > sx && ty > sy){
            if(tx > ty){
                tx = tx % ty;
            }
            else if( ty > tx){
                ty = ty%tx;
            }
            else{
                break;
            }
        }
        cout<<tx<<" "<<ty<<endl;
        if(sx == tx && sy == ty) {return true;}
        if(sx == tx){
            if(ty > sy && (ty-sy)%tx == 0){
                return true;
            }
            return false;
        }
        else if(sy == ty){
            if(tx > sx && (tx-sx)%ty == 0){
                return true;
            }
            return false;
        }
        else{
            // sx不等于tx， sy不等于ty
            return false;
        }
    }
};
```


## 题目链接：  
https://leetcode-cn.com/problems/reaching-points/