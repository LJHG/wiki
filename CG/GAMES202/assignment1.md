---
title: GAMES202-Assinment1-实时阴影
date: 2022-04-09
tags: [GAMES202]
---
> 日期：2022.4.11

# Assignment1-实时阴影

开始看games202了，第一次的作业是实时阴影，参考了一些GitHub的代码然后自己实现了一下，虽然感觉还有不少的问题...

## 运行结果

这里贴一个pcss的运行结果，感觉看起来不太对。。。

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202204112008496.png" alt="image-20220411200837460" style="zoom: 67%;" />

## 实现细节

### 0. 坐标转换

首先，在写shader之前，需要缕清楚坐标的变换，比如说这里，在真正开始进行深度测试之前，你需要得到shadowmap上真正对应的坐标，也就是**从光源的角度看过去的一个转化为了ndc的坐标**。

那么就需要做两步：

1. 坐标变换，把世界坐标系下(?)转换到从光源角度看过去的坐标。
2. ndc变化

具体的实现就是：

```glsl
// 坐标变换，在vertex shader里
vPositionFromLight = uLightMVP * vec4(aVertexPosition, 1.0);

// ndc变换，在fragment shader里
vec3 shadowCoord = (vPositionFromLight.xyz / vPositionFromLight.w) * 0.5 + 0.5; //为啥是 *0.5 + 0.5 ? ...
```

这里的`*0.5 + 0.5` 我比较迷惑(我抄的github)，根据我的理解，前面的`(vPositionFromLight.xyz / vPositionFromLight.w)`是做一个归一化，那么后面的`*0.5 + 0.5`应该就是一个平移的操作，但是我觉得具体乘多少加多少要根据数据的范围来定。

> 我猜测进行了`(vPositionFromLight.xyz / vPositionFromLight.w)`的数据范围在 [-1,1]，这样的话[-1\*0.5 + 0.5, 1\*0.5+0.5] 刚好就被shift到了[0,1]。。。



### 1. 硬阴影

既然得到了以光源为原点的坐标系的坐标，那么做硬阴影就很简单了，代码如下：

```glsl
// 直接使用shadowMap产生硬阴影
float useShadowMap(sampler2D shadowMap, vec4 shadowCoord){
  // 使用shadowCoord在shadowMap采样获得深度值，然后与实际的z进行比较
  vec4 depthPack = texture2D(shadowMap, shadowCoord.xy); //因为从深度图中查询到的实际上是一个颜色
  float depth = unpack(depthPack); //所以在这里需要把深度图查询到的颜色转换为一个浮点数
  if(depth < shadowCoord.z){
    return 0.0;
  }
  return 1.0;
}
```

思路就是在shadowMap里去查那个点的深度，然后与实际的深度比，如果实际的深度更大，那么就没挡住，否则就挡住了。

需要稍微注意的是`unpack`操作，因为深度图实际上是一张图片，所以需要将那个点的rgba像素转换为浮点数后才能进行比较。

使用硬阴影的效果图如下：

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202204112007511.png" alt="image-20220411200710483" style="zoom: 50%;" />

### 2. PCF

PCF思想也很简单，就是在自己周围做一个采样，然后看有多少物体被挡住(1)，有多少没被挡住(0)，然后做一个平均来表示自身的visibility。

作业给出的框架是使用了均匀采样和泊松采样，比如说像这样：

```glsl
void poissonDiskSamples( const in vec2 randomSeed ) {

  float ANGLE_STEP = PI2 * float( NUM_RINGS ) / float( NUM_SAMPLES );
  float INV_NUM_SAMPLES = 1.0 / float( NUM_SAMPLES );

  float angle = rand_2to1( randomSeed ) * PI2;
  float radius = INV_NUM_SAMPLES;
  float radiusStep = radius;

  for( int i = 0; i < NUM_SAMPLES; i ++ ) {
    poissonDisk[i] = vec2( cos( angle ), sin( angle ) ) * pow( radius, 0.75 );
    radius += radiusStep;
    angle += ANGLE_STEP;
  }
}
```

我们只需要给它穿入一个seed，然后就可以通过访问`poissonDisk[i]`去得到一个采样后的值，不过我有点没太搞懂这个得到的采样后的值的一个大致范围，我只知道它是均匀的，所以后面我就开始瞎搞了。

PCF的代码大致如下：

```glsl
float PCF(sampler2D shadowMap, vec4 coords, float filterSize) {
  uniformDiskSamples(coords.xy);
  // poissonDiskSamples(coords.xy);
  float ans = 0.0;
  // 其实这个值应该是有一个具体含义，然后计算出来的，不过不太清楚poissonDisk里的值的一个具体范围，所以就随便设了。
  for(int i=0;i<NUM_SAMPLES;i++){
    vec2 sampleCoords = poissonDisk[i]*filterSize + coords.xy;
    float depth = unpack(texture2D(shadowMap, sampleCoords));
    ans +=  (depth > coords.z - 0.01) ? 1.0:0.0;  // 必须加一个 -0.01来做一个边界的过滤，不然整个屏幕都是糊的
  }
  return ans/float(NUM_SAMPLES);
}
```

可以看到，这里我乘上了一个`filterSize`，用来表示一个采样的范围，这个应该是可以通过一些推导得出来一个比较合理的值的，不过我直接就把它设成0.01了，效果还不错。。大概长这样：

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202204112007876.png" alt="image-20220411200749844" style="zoom: 67%;" />



### 3. PCSS

PCSS就是估计一个平均的blocker depth后去求一个半影长度，后面就和PCF一模一样了。

首先是求平均的blocker depth，大概长这样：

```glsl
float findBlocker( sampler2D shadowMap, vec2 uv, float zReceiver ) {
  uniformDiskSamples(uv); //采样
  float allDepth = 0.0;
  int blockerCnt = 0;
  for(int i=0;i<NUM_SAMPLES;i++){
    vec2 sampleCoords = poissonDisk[i] * BLOCKER_SIZE + uv;
    float depth = unpack(texture2D(shadowMap, sampleCoords));
    allDepth += depth;
    blockerCnt +=  (depth > zReceiver - 0.01) ? 1:0;
  }
	return float(allDepth) / float(blockerCnt);
}
```

在求平均的blocker depth时，采样范围时多少又是一个问题。。。我记得在课上好像讲了一下使用光源和blocker以及shading point的一个距离来取一个采样范围，大致就是blocker离光源近，采样范围就大，blocker离光源远，采样范围就小。

图好像是这样的：

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202204112001185.png" alt="image-20220411200135154" style="zoom: 33%;" />

不过我没有用这种方法(抱歉)，我又直接设了一个 `BLOCKER_SIZE = 0.01`，可能就是这个原因让后面的结果看起来很怪。

求出了 blocker depth 后，再算一个半影长度(把半影长度当成一个filter size)，最后就可以直接套PCF了，代码大致如下：

```glsl
float PCSS(sampler2D shadowMap, vec4 coords){

  // STEP 1: avgblocker depth
  float averageDepth = findBlocker(shadowMap, coords.xy, coords.z);

  // STEP 2: penumbra size
  // 使用相似三角形计算半影
  float dReceiver = coords.z;
  float dBlocker = averageDepth;
  float penumbraSize = float(L_WIDTH) * (dReceiver - dBlocker)/ dBlocker * 0.01;
  // STEP 3: filtering
  return PCF(shadowMap, coords, penumbraSize);
}
```

关于使用相似三角形计算半影的图长这样：

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202204111959492.png" alt="image-20220411195928455" style="zoom:50%;" />

至于为什么我在算半影时后面又乘了一个0.01，是因为不乘0.01范围又大了。。就把这个0.01当成filter_size吧。

最后PCSS的结果如下：

> 这肯定不对，可能还是算平均blocker depth那里有问题🤔，这里的图是 BLOCKER_DPETH 为0.01的结果，随着把BLOCKER_DPETH变大，实的影子的长度会越来越短，0.05～0.08时效果还行，但是都是野路子。。。

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202204112008496.png" alt="image-20220411200837460" style="zoom: 67%;" />



## 总结

感觉这次做的太糙了，但是也不想做了，暂时先这样，写shader太坐牢了，连print都不能打，调试地狱。所以我还是不知道到底采样后的数组里的数据范围是多少，这也是我在使用万能的0.01的原因。



