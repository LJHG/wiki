---
title: 一些CPP简单的提速方法
date: 2022-06-18 18:00:00
tags: [CPP]
---
# 一些CPP简单的提速方法

最近看了小彭老师的c++课[第四讲](https://www.bilibili.com/video/BV12S4y1K721/?spm_id_from=333.788&vd_source=c0c1ccbf42eada4efb166a6acf39141b), 讲的是c++的编译器优化，打开了新世界的大门。

在这里简单记录一下作业里面我用到的优化方法。

>  在windows wsl2平台进行测试，CPU为i7-6700HQ, 从上至下迭代优化
>
> > 为什么不在macOS测试捏？macOS SOA居然比AOS慢，完全搞不懂为什么，放弃。

### 不做任何优化：1570ms

首先贴一下官方的源程序：

```cpp
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <chrono>
#include <cmath>

float frand() {
    return (float)rand() / RAND_MAX * 2 - 1;
}

struct Star {
    float px, py, pz;
    float vx, vy, vz;
    float mass;
};

std::vector<Star> stars;

void init() {
    for (int i = 0; i < 48; i++) {
        stars.push_back({
            frand(), frand(), frand(),
            frand(), frand(), frand(),
            frand() + 1,
        });
    }
}

float G = 0.001;
float eps = 0.001;
float dt = 0.01;

void step() {
    for (auto &star: stars) {
        for (auto &other: stars) {
            float dx = other.px - star.px;
            float dy = other.py - star.py;
            float dz = other.pz - star.pz;
            float d2 = dx * dx + dy * dy + dz * dz + eps * eps;
            d2 *= sqrt(d2);
            star.vx += dx * other.mass * G * dt / d2;
            star.vy += dy * other.mass * G * dt / d2;
            star.vz += dz * other.mass * G * dt / d2;
        }
    }
    for (auto &star: stars) {
        star.px += star.vx * dt;
        star.py += star.vy * dt;
        star.pz += star.vz * dt;
    }
}

float calc() {
    float energy = 0;
    for (auto &star: stars) {
        float v2 = star.vx * star.vx + star.vy * star.vy + star.vz * star.vz;
        energy += star.mass * v2 / 2;
        for (auto &other: stars) {
            float dx = other.px - star.px;
            float dy = other.py - star.py;
            float dz = other.pz - star.pz;
            float d2 = dx * dx + dy * dy + dz * dz + eps * eps;
            energy -= other.mass * star.mass * G / sqrt(d2) / 2;
        }
    }
    return energy;
}

template <class Func>
long benchmark(Func const &func) {
    auto t0 = std::chrono::steady_clock::now();
    func();
    auto t1 = std::chrono::steady_clock::now();
    auto dt = std::chrono::duration_cast<std::chrono::milliseconds>(t1 - t0);
    return dt.count();
}

int main() {
    init();
    printf("Initial energy: %f\n", calc());
    auto dt = benchmark([&] {
        for (int i = 0; i < 100000; i++)
            step();
    });
    printf("Final energy: %f\n", calc());
    printf("Time elapsed: %ld ms\n", dt);
    return 0;
}
```

### 加-O3:  没啥用

是的，加O3优化没起作用，我也不知道为啥。。。

```Cmake
set(CMAKE_CXX_FLAGS "-O3")
```

### 加-ffast-math:  1190ms

增加`-ffast-math`指令可以让GCC更大胆地尝试浮点运算的优化，如果能够保证程序中不会出现无穷大和NAN。

```cmake
set(CMAKE_CXX_FLAGS "-O3 -ffast-math")
```

### 加-march=native: 970ms

通过 `-march=native` 来让编译器检测电脑是否支持AVX，来实现更快的SIMD。

```cpp
set(CMAKE_CXX_FLAGS "-O3 -ffast-math -march=native")
```

### AOS改为SOA：240ms

AOS(Array of Struct): 传统的一般的面向对象的编程方式，例如上面代码中的：

```cpp
struct Star {
    float px, py, pz;
    float vx, vy, vz;
    float mass;
};

std::vector<Star> stars;
```

因为内存排布不友好，所以很难做SIMD。

SOA(Struct of Array): 高性能计算中常见的编程方式，可以将上面的写法更改为：

```cpp
template <size_t N>
struct Star {
    float px[N];
    float py[N];
    float pz[N];
    float vx[N];
    float vy[N];
    float vz[N];
    float mass[N];
};
```

这样的内存排布友好，所以方便做SIMD。

同样的，循环访问变量时的代码也要进行修改，例如：

```cpp
for(size_t i=0;i<48;i++){
        for(size_t j=0;j<48;j++){
            float dx = stars.px[j] - stars.px[i];
            float dy = stars.py[j] - stars.py[i];
            float dz = stars.pz[j] - stars.pz[i];
            float d2 = dx * dx + dy * dy + dz * dz + eps * eps;
            d2 *= std::sqrt(d2);
            stars.vx[i] += dx * stars.mass[j] * G * dt / d2;
            stars.vy[i] += dx * stars.mass[j] * G * dt / d2;
            stars.vz[i] += dx * stars.mass[j] * G * dt / d2;
        }
    }
```

可以看到优化效果是非常明显的(但是在mac上不是。。至少在M1的mac上不是，实测还变慢了，不知道是clang/LLVM的锅还是M1的锅。。。)

### sqrt改为std::sqrt: 170ms

传统的一些数学函数是C语言的遗产，不要用了，比如说sqrt函数只支持double类型，自然就会很慢。

所以这里修改为std::sqrt，这是C++的数学函数。

```cpp
d2 *= std::sqrt(d2);
```



### 将有些变量改为constexpr，有的函数改为static: 没啥用

```cpp
static float frand() {
    return (float)rand() / RAND_MAX * 2 - 1;
}

constexpr float G = 0.001;
constexpr float eps = 0.001;
constexpr float dt = 0.01;
```

constexpr是可以把一些变量直接进行编译器求值，static应该也差不多吧(我也不是很确定)。

但是不知道为什么加了没用。。。又或者说有一点用但是不明显吧。



## 总结

从1570ms最后优化到了170ms，接近10倍，牛逼疯了。

我感觉我以前写的代码可能全是垃圾代码。。。











