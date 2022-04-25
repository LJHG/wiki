---
title: MIT6.824-lab1-MapReduce
date: 2022-04-20
tags: [MIT6.824]
---
> 日期: 2022.4.20

# mit6.824 lab1

lab1是要求实现mapreduce，下面就简单记录一下做这个lab的一些注意点。

## 1. map function & reduce function

首先要搞明白map reduce 里的map function 以及reduce function都在干什么。

### map

拿这里的wordcount的为例，map函数要实现的就是对与每一个输入的filename，生成 形式为 <单词，1>的键值对，并且要将其保存为一个中间形式(intermediate)。在这里，我们将中间形式保存为文件，并且将其命名为 mr-X-Y，X是map task的id，Y是reduce task的id，也就是说，当一个中间文件形成时，就已经决定了它应该被哪个reduce task来处理了。

需要注意的是，在产生中间文件时，mr-X-Y的Y的选择很重要。在lab中提供了一个 `ihash` 函数，这个函数的作用是输入一个字符串，返回一个int的数，然后你用这个int的数去mod你的reduce task的数目就可以决定mr-X-Y的Y。最开始我是直接拿了要处理的txt文件名去做hash，也就是说一个map任务的所有处理结果全部写入一个文件，**但其实这是错误的**。

实际上在map reduce中是有一个shuffle阶段的，这个阶段就是说对于map产生的结果做一个shuffle，来使得在做reduce task的时候能够让一个reduce task能够在不同的中间结果中处理相同的部分内容。就比如说，reduce task 1只去处理对于字符 a，b，c的数量统计，reduce task 2只去处理对于字符 e，f，g的数量统计， 不过都是针对所有的中间结果的。

如果使用文件名来做hash，可以预想到的结果是，每一个Y里的中间结果都是差不多的，这是我们不想看到的，因为这样的话reduce task就没办法去挑自己想处理的文件来处理了。怎么办呢？其实这里应该是拿word去做hash，也就是说，一个map任务的处理结果会存到多个中间文件里去，这样一想就很清楚了。对于0号的map task，它的结果可能会存到 mr-0-1, mr-0-2。。。然后mr-X-1里全是存的 <单词1,1> <单词2, 1>, 然后mr-X-2里全是存的<单词3, 1> <单词4, 1>这种。

### reduce

reduce task 要实现的就是对于一堆输入 <单词，1>的键值对，将他们做一个求和，比如说把 <单词1，1><单词1，1><单词1，1>变成 <单词1，3>，就这么简单。



## 2. worker & master

这里我写的有点糙，感觉有一堆bug，尤其是crash test，就偶尔能过，不过摆了。

### worker

先来说worker的设计，相对来说简单一些。

worker主要就是通过rpc来向master要任务，如果说是map任务，那么就执行上面说的map task需要做的东西；如果是reduce任务，那么就执行上面说的reduce task需要做的东西；如果要等待，就啥也不干嗯等；不然就直接退出了。



### master

接下来就是master了，感觉这就是一个加锁地狱，尤其是当调crash test时。

首先你需要给master维护一堆变量，在创建时我们需要创建：

```go
type Master struct {
	// Your definitions here.
	mapFiles []string // txt文件名数组
	mapTasksTaken    map[int]bool     // map task 被taken了的记录
	mapOKTable       map[int]bool     // map task 做完了的记录
	mapTaskTimestamp map[int]int      // map任务开始时间
	nReduce          int              // reduce task的数目
	reduceTasks      map[int][]string // int -> reduce task的数目  []string -> reduce task 要处理的中间文件名
	reduceTasksTaken map[int]bool     // reduce task 被taken了的记录
	reduceOKTable       map[int]bool  // reduce task 做完了的记录
	reduceTaskTimestamp map[int]int   // 记录reduce任务开始时间
}
```

基本上需要维护上面这些变量。

此外，你还需要创建很多锁：

```go
var mapOkMutex = sync.Mutex{}
var reduceOkMutex = sync.Mutex{}
var reduceTakenMutex = sync.Mutex{}
var mapTakenMutex = sync.Mutex{}
var mapTimestampMutex = sync.Mutex{}
var reduceTimestampMutex = sync.Mutex{}
var reduceTasksMutex = sync.Mutex{}
var allLock = sync.Mutex{}
```

其实这一部分我还是不太清楚加这么多锁有没有用，因为最开始我是直接在`GetTask`函数的开头加了一个锁，在函数最后释放锁，就这么粗暴的操作可以通过除了最后一个crash test的test，然而当我加了这么多锁过后，crash test还是过不了，so...

简单说一下master都干了什么，master的主要任务就是实现 `GetTask`函数，使得在worker向master要任务时，要给它一个合理的安排。

首先要知道，在mapreduce里，需要在map任务都做完了过后再去做reduce任务，所以master自己要知道map任务是否做完了，reduce任务是否做完了，于是就这用到了我们上面列出的 `mapOKTable` 和 `reduceOKTable`, 当worker的map或者reduce任务做完后，会通过rpc调用一个master的函数来让master知道任务做完了。其余的部分好像也没啥好说的了，无非是map task没做完，给worker分一个map task，reduce task没做完，给worker分一个reduce task。

这里还要注意一下，考虑到crash的情况(虽然到最后我也没有完全解决这个问题)，我还维护了两个变量 `mapTasksTaken` 和 `reduceTasksTaken`，也就是说每一个任务会经历 `untaken -> taken -> done` 的过程，并不是说任务分配出去了就做完了。如何判断做完了？-> 调用了rpc来让master知道做完了就做完了。如何判断没做完？ -> 这里还记录了时间戳 `mapTaskTimestamp` 和 `reduceTaskTimestamp`，超过了一定的时间没有做完那么任务就会又变为 untaken，然后就会分配给别人。ps: 不过这里还有bug，直到最后我还发现会出现都开始执行reduce了，还有map task完成的情况，那么是不是就是因为 master以为任务挂了分配给了另一个worker，然后其实它没挂，然后就开始鬼畜了。。。所以我觉得加时间戳这个方法不是特别好。。。总之很迷，整个crash test都很迷而且难调，所以。。。摆了。



## 3. 总结

所以这就是整个lab的总结(摆烂实录)了 :)

![截屏2022-04-20 下午4.13.11](https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202204201710677.png)

