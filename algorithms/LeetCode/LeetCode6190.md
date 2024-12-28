---
title: 找到所有好下标---LeetCode6190(递推)
date: 2022-09-25 16:58:39
tags: [递推]
---
# 找到所有好下标---LeetCode6190(递推)
> 日期: 2022-09-25

## 题目描述
给你一个大小为 n 下标从 0 开始的整数数组 nums 和一个正整数 k 。

对于 k <= i < n - k 之间的一个下标 i ，如果它满足以下条件，我们就称它为一个 好 下标：

下标 i 之前 的 k 个元素是 非递增的 。
下标 i 之后 的 k 个元素是 非递减的 。
按 升序 返回所有好下标。

## 示例

```
示例 1：

输入：nums = [2,1,1,1,3,4,1], k = 2
输出：[2,3]
解释：数组中有两个好下标：
- 下标 2 。子数组 [2,1] 是非递增的，子数组 [1,3] 是非递减的。
- 下标 3 。子数组 [1,1] 是非递增的，子数组 [3,4] 是非递减的。
注意，下标 4 不是好下标，因为 [4,1] 不是非递减的。
示例 2：

输入：nums = [2,1,1,2], k = 2
输出：[]
解释：数组中没有好下标。

来源：力扣（LeetCode）
链接：https://leetcode.cn/problems/find-all-good-indices
著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
```



## 解题思路

### 错误示范

做这道题时最开始想到了递推，但是没有完全想到递推，最开始只是想了在判断的过程中去看前面一个位置是否满足要求，如果满足，那么只需要和最近的最后一个数比较即可，不然的话就重新算一遍。这种解法就是纯纯的超时，而且不好写。

```cpp
class Solution {
public:
    vector<int> goodIndices(vector<int>& nums, int k) {
        vector<int> ans;
        int n = nums.size();
        bool preLeftOK = false;
        bool preRightOK = false;
        int preLeftMin = 1000001;
        int preRightMax = -1;
        if(k == 1){
            for(int i=1;i<n-1;i++){
                ans.push_back(i);
            }
            return ans;
        }
        
        
        for(int i=k;i<n-k;i++){
            bool curLeftOK = true;
            bool curRightOK = true;
            int curLeftMin = 1000001;
            int curRightMax = -1;
            
            //debug
            // if(i == 5){
            //     cout<<preLeftOK<<endl;
            //     cout<<preRightOK<<endl;
            //     cout<<preLeftMin<<endl;
            //     cout<<preRightMax<<endl;
            // }
            
            if(!preLeftOK){
                //对当前的重新求
                for(int j=i-k;j<i;j++){
                    if(nums[j] <= curLeftMin){
                        curLeftMin = nums[j];
                    }else{
                        curLeftOK = false;
                    }
                }
            }else{
                if(nums[i-1] > preLeftMin ){
                    curLeftOK = false;  
                }
                curLeftMin = nums[i-1];
            }
            
            
            if(!preRightOK){
                //对当前的重新求
                for(int j=i+1;j<i+1+k;j++){
                    if(nums[j] >= curRightMax){
                        curRightMax = nums[j];
                    }else{
                        curRightOK = false;
                    }
                }
            }else{
                if(nums[i+k] < preRightMax){
                    curRightOK = false;
                }
                curRightMax = nums[i+k];
                
            }
            
            if(curLeftOK && curRightOK){
                ans.push_back(i);
            }
            
            preLeftOK = curLeftOK;
            preRightOK = curRightOK;
            preLeftMin = curLeftMin;
            preRightMax = curRightMax;
        }
        return ans;
    }
};
```

### 正确解法

正确的解法是先对数组递推地算每一个位置，算上当前位置非递增/非递减的长度，然后再线性扫一遍判断一下就行了。。。很简单的思路当时就是没想到捏。

```cpp
class Solution {
public:
    vector<int> goodIndices(vector<int>& nums, int k) {
        int len = nums.size();
        int before[100005]; //before[i]表示idx为i的位置前面非递增序列的数量
        int after[100005]; //after[i]表示idx为i的位置后面非递减的数量
        for(int i=0;i<len;i++){
            before[i] = 1;
            after[i] = 1;
        }
        //顺着求非递增
        for(int i=0;i<len-1;i++){
            if(nums[i+1] <= nums[i]){
                before[i+1]  = before[i] + 1;
            }
        }
        //倒着求非递减
        for(int i=len-2;i>=0;i--){
            if(nums[i] <= nums[i+1]){
                after[i] = after[i+1] + 1;
            }
        }
        vector<int> ans;
        for(int i=k;i<len-k;i++){
            if(after[i+1] >= k && before[i-1] >= k){
                ans.push_back(i);
            }
        }
        return ans;
    }
};
```



## 题目链接

[6190. 找到所有好下标 - 力扣（LeetCode）](https://leetcode.cn/problems/find-all-good-indices/)