---
title: 排序链表---LeetCode148
date: 2023-09-17 21:25:25
tags: [mergeSort, 归并, 链表]
---
# 排序链表---LeetCode148
> 日期: 2023-09-17

## 题目描述

给你链表的头结点 `head` ，请将其按 **升序** 排列并返回 **排序后的链表** 。

## 示例

```
输入：head = [4,2,1,3]
输出：[1,2,3,4]
```

## 解题思路

这道题要求O(1)空间复杂度，所以还不能用递归的方式来写递归(其实也不好写)，要用迭代的方式来写，其中的细节太多啦，所以这里记录一下。

> 顺便一提用递归的方式来写的思路，重点是要对链表一分为二，那么其实就是用快慢指针的方式来找到中点(坑蛮多)，然后一分为二。排好序后再merge。这里埋个坑，以后可能会写。

这里记录几个重点：

1. 首先是枚举每一个小段的长度，当然是从1开始，然后每次乘2。
2. 需要计算一个合并次数，然后按照合并次数写一个loop来执行每一次的合并。在计算合并次数时要注意，如果没除尽的话，那么其实也是需要算是一次合并的(比如对于3个节点，按照段长为1，其实也是要两次合并(1,2 和3，null))。这里可以通过模的方式来判断，也可以直接向上取整。
3. 每一次合并时，要计算两个链表分别的开头。同时要记录下一次合并的开头，并在最后更新到head。
4. 在所有的合并计算完后，要记得把cur->next设置为空，来避免链表成环。同时要记得把head还原换取，因为每一次我们是通过更新head来实现更新下一个链表的开头的。

真的很难呢。。。

直接贴代码

```cpp
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    ListNode* sortList(ListNode* head) {
        int len = 0;
        ListNode* cur = head;
        while(cur != nullptr){
            len += 1;
            cur = cur->next;
        }
        for(int i=1; i<=len; i*=2){ //枚举长度
            //枚举合并次数
            int cnt = 0;
            if( (len%(i*2)) != 0){
                cnt = len/(i*2) + 1;
            }else{
                cnt = len/(i*2);
            }
            // int cnt = ceil(1.0 * len / (2*i)); //这么写也行
            ListNode* dummy = new ListNode(-1);
            cur = dummy;
            while(cnt--){
                ListNode* l1 = head;
                ListNode* l2 = head;
                //计算l2的开始位置
                for(int j=0;j<i && l2;j++) l2 = l2->next;
                ListNode* nxt = l2;
                //计算下一次开始的位置
                for(int j=0;j<i && nxt;j++) nxt = nxt->next;
                //每一次合并l1和l2
                int l1Cnt = 0;
                int l2Cnt = 0;
                while(l1Cnt < i && l2Cnt < i && l1 && l2){
                    if(l1->val < l2->val){
                        l1Cnt += 1;
                        cur->next = l1;
                        l1 = l1->next;
                    }else{
                        l2Cnt += 1;
                        cur->next = l2;
                        l2 = l2->next;
                    }
                    cur = cur->next;
                }
                while(l1Cnt < i && l1){
                    l1Cnt += 1;
                    cur->next = l1;
                    l1 = l1->next;
                    cur = cur->next;
                }
                while(l2Cnt < i && l2){
                    l2Cnt += 1;
                    cur->next = l2;
                    l2 = l2->next;
                    cur = cur->next;
                }
                //计算下一个head
                head = nxt;
            }
            cur->next = nullptr; //尾部设置为空，防止成环
            head = dummy->next;
        }
        return head;
    }
};
```



## 题目链接

[148. 排序链表 - 力扣（LeetCode）](https://leetcode.cn/problems/sort-list/)