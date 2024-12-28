---
title: 记录一次使用pybind内存泄漏的debug过程
date: 2022-03-30
tags: [pybind]
---
> 日期：2022.3.30

# 记录一次使用pybind内存泄漏的debug过程

最初发现bug是因为使用nohup命令炼丹时，炼着炼着任务就自己停了，没有任何的报错信息，当时十分迷惑，于是又跑了一次，发现任务又在差不多的位置停了。当时就断定应该是内存泄漏，操作系统把任务给我杀了，于是就开始查看为啥会内存泄漏。

最开始以为是pytorch的问题，比如说一些梯度的累加啥的，当时就在网上搜到说 loss 的记录与累加要写成:

```
totalLoss += loss.item()
```

的形式，然后因为我之前写的是：

```
totalLoss += loss.data
```

于是我就改了，事实发现没什么卵用。

于是开始在网上搜一些内存泄漏相关的debug工具，于是搜到了 `memory_profiler`。

这个真的是个神器，只需要在函数前面加上 `@profile` 修饰符，就可以在函数执行结束时查看这个函数执行过程中内存的变化。

最开始查看当然从 `train` 入手，于是操作一波发现每一次的内存增加都来自于 `dataLoader` ，当时我就在猜测应该是 `pybind` 的问题了，毕竟自己用 `pybind` 魔改了一波`dataLoader`，很难不保证不出什么幺蛾子。

> pybind是一个可以在python调用c++的一个库，比numba等直接在python里面写的库更加自由，因为pybind能够直接编写c++的代码(埋下伏笔)，但是相对来说也更难。

> 当初我的需求是使用c++来编写相关的代码来加速点云转换为八叉树，因为在python里直接转八叉树实在是太慢了，所以当初就想当然地在技术选型时使用了pybind，事实证明，这是一个还不错的决定，如果你的c++写得很好，而不是像我一样瞎用指针。

于是再次深入，去 `dataLoader` 里使用`@profile` 修饰符查看内存的变化情况，最后发现每一次的内存增加都来自于一个 我用pybing写的函数，这时候就基本确定了bug来自于何处。

仔细一看代码：

```cpp
process_info* bfs_process_octree(shared_ptr<Octant> root) {

	map<int, Node*> nodedict; nodedict.clear();
	map<int,int> layerIndexs; layerIndexs.clear();
	queue<shared_ptr<Octant>> octantQueue;
	....
}
```

好家伙，到处都是指针，当时我就在猜测应该是内存释放出了问题，所以我开始尝试一些例如 `del`, `gc.collecte()` 的一些操作，试图在python里把内存释放掉，然而没什么用。

当初我写指针也是想着既然C++和python数据通信，地址一定会更快一些，于是在面对一些数据量比较大的变量时都是用的指针，结果没想到因为内存释放出了大问题。

所以最后没办法，我就把所有的指针又改回了对象...(有点low)

```cpp
process_info bfs_process_octree(shared_ptr<Octant> root) {

	map<int, Node> nodedict; nodedict.clear();
	map<int,int> layerIndexs; layerIndexs.clear();
	queue<shared_ptr<Octant>> octantQueue;
	....
}
```

不过问题解决了，而且好像速度并没有变得更慢🤔?

总之以后要慎用指针了...