---
title: 记录cuda和cpu的计算误差带来的坑
date: 2022-10-28 17:07:05
tags: [cuda]
---
# 记录cuda和cpu的计算误差带来的坑
> 日期: 2022-10-28

最近在用torchac糊demo，之前光速写完了然后一直发现编码和解码的点云对应不上，然后这个bug我de了好多天。

最开始以为是库的精度问题带来的误差，然后我把神经网络的输入输出都打出来看了，发现编码端和解码端的神经网络的输入输出都是一样的，这让我非常迷惑。

由于实在不知道啥情况了，我打算把输出输出用pickle存入文件，然后单独写一个py文件来debug。结果发现编码解码端的神经网络输出是一样的，而且在单独的文件里做算术编解码时，输出的结果居然都是对的。

这让我开始怀疑是不是编码的bytestream出了问题，于是我将实际编码以及单独文件里编码的bytestream打出来看了一下，发现居然不一样。

这让我非常的震惊，明明两个函数的输入都是一样的，唯一的区别在于一个是直接跑的，另外一个是被我存进了文件，然后再读出来再跑的。

最后发现坑在于.cuda()和.cpu()。原本我有一个变量是存在gpu上的，但是在保存为文件后，就默认保存为.cpu()格式了，然后再读取时也没有将其转为.cuda()。

具体的问题呢应该是出在这里，我试了一下，输入的pdf分别是.cuda()和.cpu()时，结果是不一样的。

行吧。。。
```python
def pdf2cdf(pdf):
    # if symbols nums is N, need cdf of length of N+1
    #     pdf       ->     cdf
    #  B * N * 256      B * N * 257
    # https://blog.csdn.net/OrdinaryMatthew/article/details/125757080
    # pdf = pdf/torch.sum(pdf,-1,keepdim=True) # normalize, 如果本身输入的pdf之和为1，则不需要这行
    pdf = F.softmax(pdf,dim=-1)
    # print(pdf)
    cdf = torch.cumsum(pdf, -1)
    cdf = torch.cat([torch.zeros_like(cdf[:,:,:1]),cdf], -1) #  add zero in the front
    cdf = torch.cat([cdf[:,:,:-1],torch.ones_like(cdf[:,:,:1])], -1) # add one in the back (其实最后是有0的，但是一般来说会超过1一点点，所以这里直接把最后的1.000几几直接替换为1)
    return cdf

```