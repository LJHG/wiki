---
title: 使用scatter函数来计算onehot向量
date: 2022-04-06
tags: [pytorch]
---
> 日期：2022.4.6

## 循环太慢

最近在炼丹的过程中的测试阶段有一个需求，就是对于每一个输出的结果，需要对它做一个log，然后再把所有的结果加起来。因为本来的输入又是一个序列，加上batch_size，所以一共有三个维度，因此最开始我计算的时候是做了两重循环：

```python
for i in range(batch_size):
	for j in range(sequence_size):
		ans += -torch.log2(pred[i][j][int(gt[i][j])])
```

这里说明一下，pred，也就是预测输出的shape是`batch_size * sequence_size * classes`；gt，也就是实际label的shape是`batch_size * sequence_size`。

可以看到，这里的两重循环是非常辣眼睛的，经过测试，哪怕是将 `batch_size` 设置为512，`sequence_size` 设置128，一趟计算下来也要3秒钟，在数据量很大的时候，这是非常难以接受的。

## 矩阵运算替代

所以我就想到或许可以用矩阵运算的方式来代替掉这个循环，经过一阵推导，发现确实能够这样做，步骤大致如下：

1. 将 gt 矩阵变为 one-hot 形式，也就是说把 `batch_size * sequence_size` 变为 `batch_size * sequence_size * classes`的形式，也就是把最后一个维度变为one-hot。
2. 将pred矩阵与gt矩阵进行点乘。
3. 将点乘后的结果中所有的0替换为1。
4. 在整个矩阵上求 -log2
5. 矩阵求和

### one-hot矩阵生成

所以可以看到，一阵操作里面最复杂的应该就是如何把一个矩阵的最后一维变为one-hot形式，经过一番搜索，我发现pytorch里提供了一个叫做 `scatter_` 的函数，其大致的描述是这样的：

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202204062036222.png" alt="image-20220406203621393" style="zoom:50%;" />

用通俗易懂的话来说就是，给定一个source矩阵，和一个index矩阵，选定一个维度，根据index矩阵从source矩阵里**挑一些值**来作为结果(self)。

于是用下面两行代码就可以生产一个one-hot矩阵：

```python
one_hot_gt = torch.zeros(batch_size,sequence_size,256)
one_hot_gt = one_hot_gt.scatter_(dim=2,index=gt.reshape(batch_size,sequence_size,1).data.long().cpu(),value=1)
```

解释一下：

1. 首先，生成一个全零的`batch_size * sequence_size * classes`形式的矩阵。
2. 对于`scatter_`函数的参数说明一下。`dim=2`是因为要在最后一维做one-hot。由于输入的index(gt)和self(one_hot_gt)需要维度一致，所以我们将它reshape一下，变为 `batch_size * sequence_size * 1`。`value=1`是因为要把所有的值都替换为1，这也就是source。

如此操作就可以达成以下的效果：

```python
one_hot_gt[i][j][gt[i][j][0]] = 1 # gt[i][j][0]就是类别的编号
```

### 后续操作

一旦生成了one-hot矩阵，后续的操作就很简单了，完整的代码如下：

```python
# 首先将 gt 修改为one-hot形式  (batch_size, sequence_size, 256) 
one_hot_gt = torch.zeros(batch_size,sequence_size,256)
one_hot_gt = one_hot_gt.scatter_(dim=2,index=gt.reshape(batch_size,sequence_size,1).data.long().cpu(),value=1)
# 将one_hot_gt和pred点乘
ans = torch.mul(one_hot_gt.cuda(),pred.cuda())
# 将所有的0替换为1
ans[ans == 0] = 1
ans = -torch.log2(ans).sum()
```

最后测试得到，原本要3s的运算只需要0.1s了～