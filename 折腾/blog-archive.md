---
title: 我给博客加了个归档功能
date: 2022-04-25
tags: [折腾]
---

## 1. 起因

最近在用notion了，于是就打算把才用了半年多的gitbook给迁移了。原因就是我觉得gitbook和notion的重叠度太高了，如果我想把博客弄成一个知识管理的地方，emmm，我为什么不去用notion呢？所以后来我打算迁移博客，尽量把博客变成一个记录一些有意思的东西的地方，像是这样：

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202204252132562.png" alt="image-20220425213246727" style="zoom: 25%;" />

上面这个主题是hugo的paperMod主题，看起来非常的好看。但是它有一个问题，那就是它的有效现实页面实在是太小了，如果在台式的显示器上显示，显示内容差不多只占了中间的1/3，这是我无法接受的。

加之我有非常多的做算法题的存货。一方面我馋一般博客的tag功能，但是另一方面如果使用了这个tag功能就会导致我平时写的内容会夹杂在非常多的算法题里，也不美观。

后来我仔细想了一下，我目前使用的gitbook除了没有tag，没有归档，其它的一切都非常的让我满意。而且就是因为没有归档功能，才让我觉得它不像是一个博客，更像是一个笔记本，也就是notion。所以我就打算着手改造一下gitbook了。

## 2. 过程

具体加这个归档功能大概是这样的：

1. 用python写脚本解析所有的markdown的header，把标题、日期等内容解析出来，然后把它存成一个中间的json文件。
2. 使用gitbook生成html静态网页，此时json文件也会被生成过去。
3. 使用js(js是写在markdown里的)去读这个json文件，来进行对归档页面的填充。

> 这里要说一下，我之前是不知道可以直接在github page里读取同一个文件夹下的json文件的😅，所以之前我还想过用python一行一行地把html给写入markdown，这也是一种方法，但是太不优雅了。 -> 之前我的tag_table就是python直接生成了一个markdown表格塞到了markdown里，非常丑。

具体的代码细节也不贴了，中途我参考了 [这个网站](https://draveness.me/)的归档页面，于是我就直接把它嫖过来了 🤓



## 3. 成果

于是最后终于搞出来了一个归档页面 😇

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202204252145660.png" alt="image-20220425214503631" style="zoom: 33%;" />

