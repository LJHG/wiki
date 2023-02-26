---
title: 买卖股票的最佳时机---LeetCode121(dp)
date: 2023-02-26 20:10:50
tags: [dp]
---
# 买卖股票的最佳时机---LeetCode121(dp)
> 日期: 2023-02-26

## 一次买卖

给定一个数组 prices ，它的第 i 个元素 prices[i] 表示一支给定股票第 i 天的价格。

你只能选择 某一天 买入这只股票，并选择在 未来的某一个不同的日子 卖出该股票。设计一个算法来计算你所能获取的最大利润。

返回你可以从这笔交易中获取的最大利润。如果你不能获取任何利润，返回 0 。

### 示例

```
输入：[7,1,5,3,6,4]
输出：5
解释：在第 2 天（股票价格 = 1）的时候买入，在第 5 天（股票价格 = 6）的时候卖出，最大利润 = 6-1 = 5 。
     注意利润不能是 7-1 = 6, 因为卖出价格需要大于买入价格；同时，你不能在买入前卖出股票。

来源：力扣（LeetCode）
链接：https://leetcode.cn/problems/best-time-to-buy-and-sell-stock
著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
```



### 解题思路

用dp做，买卖股票这类题最重要的就是状态的选择，包括后面的差别其实就在状态数量上，以及状态之间是如何转移的。这道题的关键就是只有一次买卖，所以 `dp[i][1]` 如果是当天买的话那么其实就是 `-prices[i]`。

```c++
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        int len = prices.size();
        int dp[100005][2]; // dp[i][0] 表示第i天不持有股票时的最大利润, dp[i][i] 表示第i天不持有股票时的最大利润
        memset(dp,0,sizeof(dp));
        dp[0][0] = 0;
        dp[0][1] = -prices[0];
        for(int i=1;i<len;i++){
            dp[i][0] = max(dp[i-1][0], dp[i-1][1] + prices[i]);  //第i天不持有，可能是之前就卖掉了，或者是现在卖掉了
            dp[i][1] = max(dp[i-1][1], - prices[i]);  //第i天持有，可能是之前就有，也有可能是现在才买入
        }
        return dp[len-1][0];
    }
};
```

### 题目链接

[121. 买卖股票的最佳时机 - 力扣（LeetCode）](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock/)



## 多次买卖

给你一个整数数组 prices ，其中 prices[i] 表示某支股票第 i 天的价格。

在每一天，你可以决定是否购买和/或出售股票。你在任何时候 最多 只能持有 一股 股票。你也可以先购买，然后在 同一天 出售。

返回 你能获得的 最大 利润 。

### 示例

```
输入：prices = [7,1,5,3,6,4]
输出：7
解释：在第 2 天（股票价格 = 1）的时候买入，在第 3 天（股票价格 = 5）的时候卖出, 这笔交易所能获得利润 = 5 - 1 = 4 。
     随后，在第 4 天（股票价格 = 3）的时候买入，在第 5 天（股票价格 = 6）的时候卖出, 这笔交易所能获得利润 = 6 - 3 = 3 。
     总利润为 4 + 3 = 7 。

```

### 解题思路

多次买卖和一次买卖的唯一区别就是`dp[i][1]` 如果是当天买的话那么其实是 `dp[i-1][0]-prices[i]`。

```c++
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        int len = prices.size();
        int dp[30005][2]; //dp[i][0]表示第i天不持有股票的最大利润, //dp[i][1]表示第i天持有股票的最大利润
        memset(dp,0,sizeof(dp));
        dp[0][0] = 0;
        dp[0][1] = -prices[0];
        for(int i=1;i<len;i++){
            dp[i][0] = max(dp[i-1][1] + prices[i], dp[i-1][0]);
            dp[i][1] = max(dp[i-1][0] - prices[i], dp[i-1][1]);
        }

        return dp[len-1][0];
    }
};
```

### 题目链接

[122. 买卖股票的最佳时机 II - 力扣（LeetCode）](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-ii/)



## 最多两次买卖

给定一个数组，它的第 i 个元素是一支给定的股票在第 i 天的价格。

设计一个算法来计算你所能获取的最大利润。你最多可以完成 两笔 交易。

注意：你不能同时参与多笔交易（你必须在再次购买前出售掉之前的股票）。

### 示例

```
输入：prices = [3,3,5,0,0,3,1,4]
输出：6
解释：在第 4 天（股票价格 = 0）的时候买入，在第 6 天（股票价格 = 3）的时候卖出，这笔交易所能获得利润 = 3-0 = 3 。
     随后，在第 7 天（股票价格 = 1）的时候买入，在第 8 天 （股票价格 = 4）的时候卖出，这笔交易所能获得利润 = 4-1 = 3 。

```

### 解题思路

之前的情况都是只有两种状态，持有和不持有。

但是这里有最多两笔交易，所以需要设立5种状态，具体看代码

```c++
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        int len = prices.size();
        int dp[100005][5]; 
        /**
            dp[i][0]表示第i天时还没有进行任何操作
            dp[i][1]表示第i天持有第一个股票的状态
            dp[i][2]表示第i天不持有第一个股票的状态
            dp[i][3]表示第i天持有第二个股票的状态
            dp[i][4]表示第i天不持有第二个股票的状态
        */
        memset(dp,0,sizeof(dp));
        dp[0][1] = -prices[0];
        dp[0][3] = -prices[0]; //这里的初始化很细
        for(int i=1;i<len;i++){
            dp[i][0] = dp[i-1][0];
            dp[i][1] = max(dp[i-1][1], dp[i-1][0] - prices[i]);
            dp[i][2] = max(dp[i-1][2], dp[i-1][1] + prices[i]);
            dp[i][3] = max(dp[i-1][3], dp[i-1][2] - prices[i]);
            dp[i][4] = max(dp[i-1][4], dp[i-1][3] + prices[i]);
        }
        return dp[len-1][4];
    }
};
```

### 题目链接

[123. 买卖股票的最佳时机 III - 力扣（LeetCode）](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-iii/)



## 最多k笔交易

给定一个整数数组 prices ，它的第 i 个元素 prices[i] 是一支给定的股票在第 i 天的价格。

设计一个算法来计算你所能获取的最大利润。你最多可以完成 k 笔交易。

注意：你不能同时参与多笔交易（你必须在再次购买前出售掉之前的股票）。



### 示例

```
输入：k = 2, prices = [2,4,1]
输出：2
解释：在第 1 天 (股票价格 = 2) 的时候买入，在第 2 天 (股票价格 = 4) 的时候卖出，这笔交易所能获得利润 = 4-2 = 2 。
```

### 解题思路

之前最多交易两次是5种状态，那么最多交易k次就是2*k+1种状态。

```c++
class Solution {
public:
    int maxProfit(int k, vector<int>& prices) {
        int len = prices.size();
        int dp[1010][202]; //每一次交易会增加两种状态
        memset(dp,0,sizeof(dp));
        for(int j=0;j<k;j++){
            dp[0][j*2 + 1] = -prices[0];
        } 
        for(int i=1;i<len;i++){
            for(int j=0;j<2*k+1;j++){
                if(j == 0){
                    dp[i][j] = dp[i-1][j];
                    continue;
                }
                if(j % 2  == 1){
                    dp[i][j] = max(dp[i-1][j], dp[i-1][j-1] - prices[i]);
                }else{
                    dp[i][j] = max(dp[i-1][j], dp[i-1][j-1] + prices[i]);
                }
            }
        }
        return dp[len-1][2*k];
    }
};
```

### 题目链接

[188. 买卖股票的最佳时机 IV - 力扣（LeetCode）](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-iv/)







