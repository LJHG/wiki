---
title: 找出强数对的最大异或值---LeetCode2395(字典树)
date: 2023-11-14 16:51:01
tags: [字典树]
---
# 找出强数对的最大异或值---LeetCode2395(字典树)
> 日期: 2023-11-14

## 题目描述

给你一个下标从 **0** 开始的整数数组 `nums` 。如果一对整数 `x` 和 `y` 满足以下条件，则称其为 **强数对** ：

- `|x - y| <= min(x, y)`

你需要从 `nums` 中选出两个整数，且满足：这两个整数可以形成一个强数对，并且它们的按位异或（`XOR`）值是在该数组所有强数对中的 **最大值** 。

返回数组 `nums` 所有可能的强数对中的 **最大** 异或值。

**注意**，你可以选择同一个整数两次来形成一个强数对。

## 示例

**示例 1：**

```
输入：nums = [1,2,3,4,5]
输出：7
解释：数组 nums 中有 11 个强数对：(1, 1), (1, 2), (2, 2), (2, 3), (2, 4), (3, 3), (3, 4), (3, 5), (4, 4), (4, 5) 和 (5, 5) 。
这些强数对中的最大异或值是 3 XOR 4 = 7 。
```

**示例 2：**

```
输入：nums = [10,100]
输出：0
解释：数组 nums 中有 2 个强数对：(10, 10) 和 (100, 100) 。
这些强数对中的最大异或值是 10 XOR 10 = 0 ，数对 (100, 100) 的异或值也是 100 XOR 100 = 0 。
```

**示例 3：**

```
输入：nums = [500,520,2500,3000]
输出：1020
解释：数组 nums 中有 6 个强数对：(500, 500), (500, 520), (520, 520), (2500, 2500), (2500, 3000) 和 (3000, 3000) 。
这些强数对中的最大异或值是 500 XOR 520 = 1020 ；另一个异或值非零的数对是 (5, 6) ，其异或值是 2500 XOR 3000 = 636 。
```

## 解题思路

其实这道题有两个解法，一个是哈希表(类似两数之和)，一个是字典树。

###  哈希表

其实也是非常巧妙的一个做法，但是这里不多赘述了。

```cpp
class Solution {
public:
    int maximumStrongPairXor(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        // 2x >= y
        int ans = 0;
        int mask = 0;
        for(int i=31; i>=0; i--){
            mask |= (1 << i);
            int newAns = ans | (1 << i);
            // 判断newAns是否可行
            unordered_map<int,int> m;
            for(int y:nums){
                int mask_y = y & mask;
                if(m.count(mask_y ^ newAns) && m[mask_y ^ newAns] * 2 >= y){
                    ans = newAns;
                    break;
                }
                m[mask_y] = y;
            }
        }
        return ans;
    }
};
```

### 字典树

第一次接触用字典树来解题，发现用字典树来做这种位运算的题真的很适合。因为树的高度最多就为32，而且字典树的增加和删除也非常好写，完美适配滑动窗口。

```cpp
class Solution {
public:
    struct Node{
        int cnt;
        vector<Node*> sons;
        Node(){
            cnt = 1;
            sons = vector<Node*>(2);
        }
    };
    class Trie{
        public:
        Node* root;
        Trie(){
            root = new Node();
        }
        void add(int val){
            Node* cur = root;
            for(int i=31; i>=0; i--){
                if(val & (1 << i)){
                   if(cur->sons[1] == nullptr){
                       cur->sons[1] = new Node();
                   }else{
                       cur->sons[1]->cnt++;
                   }
                   cur = cur->sons[1];
                }else{
                    if(cur->sons[0] == nullptr){
                       cur->sons[0] = new Node();
                   }else{
                       cur->sons[0]->cnt++;
                   }
                   cur = cur->sons[0];
                }
            }
        }

        void remove(int val){
            Node* cur = root;
            for(int i=31; i>=0; i--){
                if(val & (1 << i)){
                   cur->sons[1]->cnt--;
                   cur = cur->sons[1];
                }else{
                    cur->sons[0]->cnt -- ;
                    cur = cur->sons[0];
                }
            }
        }
        // 当前字典树与val的最大异或值
        int maxXor(int val){
            int ans = 0;
            Node* cur = root;
            for(int i=31; i>=0; i--){
                int curBit = (val >> i) & 1;
                if(curBit == 1){
                    // 寻找0的
                    if(cur->sons[0] == nullptr || cur->sons[0]->cnt == 0){
                        cur = cur->sons[1];
                    }else{
                        cur = cur->sons[0];
                        ans |=  (1 << i);
                        continue;
                    }
                    
                }else{
                    // 寻找1的
                    if(cur->sons[1] == nullptr || cur->sons[1]->cnt == 0){
                        cur = cur->sons[0];
                    }else{
                        cur = cur->sons[1];
                        ans |=  (1 << i);
                        continue;
                    }
                }
            }
            return ans;
        }
    };

    int maximumStrongPairXor(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        Trie* tree = new Trie();
        int ans = 0;
        int left = 0;
        for(int right = 0; right < nums.size(); right++){
            tree->add(nums[right]);
            while(nums[left] * 2 < nums[right]){
                tree->remove(nums[left]);
                left++;
            }
            ans = max(ans, tree->maxXor(nums[right]));
        }
        return ans;
    }
};
```



## 题目链接

[2935. 找出强数对的最大异或值 II - 力扣（LeetCode）](https://leetcode.cn/problems/maximum-strong-pair-xor-ii/)

[最大异或和的两种思路：0-1字典树/哈希表【力扣周赛 371】_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1MG411X7zR/?spm_id_from=333.337.search-card.all.click&vd_source=c0c1ccbf42eada4efb166a6acf39141b)