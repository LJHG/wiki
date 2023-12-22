---
title: mac pytorch gpu加速尝鲜(
date: 2023-12-22 16:00:22
tags: [mac, pytorch]
---
# mac pytorch gpu加速尝鲜(
> 日期: 2023-12-22

前段时间就听说mac好像支持gpu加速了，当时似乎是pytorch官方发了一个博客[Introducing Accelerated PyTorch Training on Mac | PyTorch](https://pytorch.org/blog/introducing-accelerated-pytorch-training-on-mac/) (卧槽原来已经一年了)，我记得刚出的时候是只支持cpu来着，难道说一开始就支持mps了🤔？无所谓了，反正我一直没用过。

然后最近突然发现pytorch竟然已经更新到2.1了，pytorch给mac提供了一个叫做MPS (Metal Performance Shaders)的东西，来实现gpu加速（苹果真的得给这些社区磕头）。

于是就简单写了个脚本，测试一下(on 2021 mbp m1pro 16g)。。。

```python
import torch
import time

if __name__ == '__main__':
    if(torch.backends.mps.is_available()):
        print("## enabling mps ##")
        device = torch.device("mps")
    elif(torch.cuda.is_available()):
        print("## enabling cuda ##")
        device = torch.device("cuda")
    else:
        print("## enabling cpu ##")
        device = torch.device("cpu")
    
    layer = torch.nn.TransformerEncoderLayer(512, 8 ,2048)
    model = torch.nn.TransformerEncoder(layer, 6).to(device)
    start = time.time()
    for i in range(10):
        res = model(torch.zeros(1024,512).to(device))
    end = time.time()
    print("time cost: ", end-start)
    
        

```

简单写了个transoformer encoder，然后跑了一下

```
# torch 2.1 mps
time cost:  0.658048152923584

# torch 1.12 mps(没错，那个时候已经有mps了)
time cost:  1.2606778144836426

# torch 2.1 cpu
time cost:  4.325138092041016

# torch 1.12 cpu
time cost:  4.158311128616333

# torch 1.13 GTX1060
time cost:  1.8937978

# torch 1.13 i7-7700
time cost:  5.250705





```

可以看出来，gpu加速还是会有4～7倍的提升，随着版本更新，cpu推理没啥变化，但是gpu变快了好多。。。可能之前我看的那个blog post就是说的gpu加速变快了，但是我也找不到了。

还拿实验室的祖传1060来测了一下，还跑不过m1 pro。。。

虽然测得非常不严谨，不过mac上的表现真的还不错了，而且苹果的统一内存也挺香的，配个好点的机器，在果子上炼丹不是梦哇。。







