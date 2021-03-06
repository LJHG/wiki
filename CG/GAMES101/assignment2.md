---
title: GAMES101-assignment2-ZBuffuer
date: 2021-11-11
tags: [GAMES101]
---
# Assignment2

## 运行结果

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/image-20220101175340666.png" alt="image-20220101175340666" style="zoom:50%;" />





## 实现细节

[详细代码](https://github.com/LJHG/GAMES101-assignments)
我认为这次的assignment的重点有三个：

1. 三角形内的判断
2. 三角形边界的确定
3. 深度buffer



### 1. 三角形内的判断

判断一个点是否在三角形内是通过叉乘来判断的，假设一个点为**P**，我们与三角形的三个顶点相连，并分别令为**PA**，**PB**，**PC**，那么需要计算**PAPB**, **PBPC**, **PCPA**的叉乘，只要三个结果同号，那么该点就在三角形内。这里需要注意一下叉乘的顺序，倘若把**PCPA**写为**PAPC**，结果就会大不相同。

```cpp
static bool insideTriangle(int x, int y, const Vector3f* _v)
{   
    //TODO : Implement this function to check if the point (x, y) is inside the triangle

    //suppose the coordinate of p is (x,y)

    x = x + 0.5f;
    y = y + 0.5f;
    std::pair<float,float> pa = std::make_pair(_v[0][0]-x, _v[0][1]-y);
    std::pair<float,float> pb = std::make_pair(_v[1][0]-x, _v[1][1]-y);
    std::pair<float,float> pc = std::make_pair(_v[2][0]-x, _v[2][1]-y);

    float papb = cross_product(pa,pb);
    float pbpc = cross_product(pb,pc);
    float pcpa = cross_product(pc,pa);

    if( (papb > 0 && pbpc > 0 && pcpa >0)  || (papb < 0 && pbpc < 0 && pcpa < 0) )
        return true;
    return false;    
}
```



### 2. 三角形边界的确定

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/image-20211025231838941.png" alt="image-20211025231838941" style="zoom: 67%;" />

通过对三角形的边界进行确认，可以加速光栅化的过程，具体代码如下：

```cpp
//确定bounding box的坐标
int left = std::min(v[0][0],std::min(v[1][0],v[2][0]));
int bottom = std::min(v[0][1],std::min(v[1][1],v[2][1]));
int right = std::max(v[0][0],std::max(v[1][0],v[2][0])) + 1 ; //向上取整
int top = std::max(v[0][1],std::max(v[1][1],v[2][1])) + 1;
```



### 3. 深度buffer

代码中维护了一个**depth_buf**，如果当前要绘制的像素离摄像机近，那么才绘制，否则不绘制。具体的相关代码也很简单：

```cpp
int index = get_index(x,y);
if(z_interpolated < depth_buf[index] ){  // if near
    Eigen::Vector3f point;
    point << x,y,z_interpolated;
    Eigen::Vector3f color;
    set_pixel(point,t.getColor());
    depth_buf[index] = z_interpolated;
}
```

