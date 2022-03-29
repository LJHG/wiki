# Assignment7

光线追踪之路径追踪

## 1. 运行结果

当把spp设置为32时，结果如图所示：

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/image-20220313154640560.png" alt="image-20220313154640560" style="zoom:33%;" />



## 2. 实现细节

[详细代码](https://github.com/LJHG/GAMES101-assignments)

这次作业主要实现了路径追踪，其中涉及到的坑点比较多，主要是以下几个：

1. 相较于assignment6有几个地方需要修改一下，不然会出现**很错误的结果**。
2. 直接光照的实现
3. 间接光照的实现
4. 还可以拓展的地方



## 2.1 在assignment6的基础上修改(注意)

首先，需要对 `BVH.cpp` 的 `BVHAccel::getIntersection` 函数进行修改：

```cpp
std::array<int, 3> dirIsNeg = {int(ray.direction.x > 0), int(ray.direction.y > 0), int(ray.direction.z) > 0};
```

这里需要将 > 修改为 >= ，不然的话光线和物体求交全是空，结果就是全是黑的。。。

```cpp
std::array<int, 3> dirIsNeg = {int(ray.direction.x >= 0), int(ray.direction.y >= 0), int(ray.direction.z) >= 0};
```



然后，需要对 `Bounds3.hpp` 的 `Bounds3::IntersectP` 函数进行修改：

```cpp
if(t_enter < t_exit && t_exit >= 0){
        return true;
   }
```

这里在判断光线与包围盒相交时要把 < 改为 <= 才对(表示非常不理解)，不然的话场景的一大半都会是黑色的。。。

```cpp
if(t_enter <= t_exit && t_exit >= 0){
        return true;
   }
```



## 2.2 直接光照的实现

直接光照基本就是参照着课程来实现的，说几个需要注意的地方吧。

1. 第一个，由于直接光照是直接对光源来进行采样的，所以渲染方程是需要修改的，修改后的代码如下所示：

   ```cpp
   float distance = dotProduct(hit_obj_to_light, hit_obj_to_light);
   float cosine1 = dotProduct(hit_obj.normal, hit_obj_to_light_dir);
   float cosine2 = dotProduct(light_intersection.normal, -hit_obj_to_light_dir);
   if(light_pdf > pdf_epsilon)
   	Lo_direct = light_intersection.emit * f_r * cosine1*cosine2 / light_pdf / distance;
   ```

2. 作业中存在着大量的向量，并且很多时候不同的向量就是方向取了一个反(对应到代码里就是取了一个负号)，我这里的作业里面的一些向量的方向是我自己认为是对的，不保证正确(但是经过测试好像大多数的向量的方向正负并没有什么影响，很迷)。

3. 在直接光照的实现中，从物体向光源打出的线需要判断中间是否有物体遮挡，这里不能直接用 `Intersection.happened` 来判断是否有交点，因为要保证交点在物体和光线之间，所以代码应该这样写：

   ```cpp
   if(t.distance - hit_obj_to_light.norm() > -epsilon){
           //光线没有被遮挡
           xxxx
      }
   ```



## 2.3 间接光照的实现

同样，间接光照也指出几个需要注意的地方：

1. 刚刚直接光照是对光源进行了采样，这里间接光照也需要再进行一次采样，不过就是普通的采样。

   ```cpp
   Vector3f obj1_to_obj2_dir = hit_obj.m->sample(-wo, hit_obj.normal).normalized();
   float obj2_pdf = hit_obj.m->pdf(-wo,obj1_to_obj2_dir,hit_obj.normal);
   ```

2. 从物体向采样的方向射出一条光线，打中一个物体，这里还需要判断打中的物体是否会发光，不然会出现很多的白色噪点：

   ```cpp
   if(t_2.happened && !t_2.m->hasEmission()){ //这里需要确定交点处不会发光，来确保这是间接光照而不是直接射到了光源
         //光线和物体相交
         Vector3f f_r = hit_obj.m->eval(-obj1_to_obj2_dir, wo, hit_obj.normal);
         float cosine = dotProduct(hit_obj.normal, obj1_to_obj2_dir); 
         if(obj2_pdf > pdf_epsilon)
         Lo_indirect = shade(t_2, -obj1_to_obj2_dir) * f_r * cosine / obj2_pdf / RussianRoulette;
      }
   ```

3. 最后补充一下，需要单独判断物体是否会发光，如果会发光直接返回，不然的话结果里是没有灯的：

   ```cpp
   //如果物体会发光，直接返回光照
   if (hit_obj.m->hasEmission())
   {
   	return hit_obj.m->getEmission();
   }
   ```



## 2.4 拓展

这个作业还有一些可以补充的地方，比如说多线程加速，比如说看到论坛里有人说随机数的生成很大的影响了性能，不过这些都先留着好了。。。



# 3. 结果展示

最后展示一下将spp分别设置为1，16，32的结果：

* spp = 1

  <img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/image-20220313154827341.png" alt="image-20220313154827341" style="zoom:33%;" />

* spp = 16

  <img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/image-20220313155000558.png" alt="image-20220313155000558" style="zoom:33%;" />

* spp = 32

  <img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/image-20220313155028295.png" alt="image-20220313155028295" style="zoom:33%;" />



















