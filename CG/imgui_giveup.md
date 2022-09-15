---
title: 我不想用imgui了
date: 2022-09-15 20:34:29
tags: [imgui]
---
# 我不想用imgui了
弄这个imgui弄了好多天，从最开始跑通它官网上的demo，到琢磨应该怎么把它整合到我的软渲染器里，最后 -> 放弃。

弄了加起来可能还是有好几个小时，为了不让这段时间白费，写点东西记录一下。

原因主要有三点吧，当然技术上的原因比较多。

首先是我觉得自己的这个软渲染器不需要那么多的按钮啥的来交互，我能想到的就是imgui能够有一个很好的显示fps的窗口，然后就是我能够在ui里选择渲染的后端(光栅器/光追)，当然现在我连光追一点都没写，感觉ui也不是特别有必要了。

其次就是感觉这个项目没有必要导入太多的其他库，不然就太庞大了，也失去了软光栅器那种徒手造轮子的感觉了。现在我已经导入了sdl, assimp这些庞大的库了，已经很难受了。再来一个glew和imgui，库就太多了。

最后，当然也是最重要的原因就是我菜，opengl太麻烦了，看得我头皮发麻。

在这里稍微整理一下目前遇到的坑吧，如果以后我会了，可能会来填。

目前观察到的现象就是，我的软渲染器是通过`SDL_UpdateWindowSurface(window)` 这个函数来实现窗口的像素更新的，我还在stackoverflow上[问了一波](https://stackoverflow.com/questions/73726756/sdl-updatewindowsurface-cover-the-result-of-sdl-gl-swapwindow)，别人的说法是：

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202209152047309.png" alt="image-20220915204747082" style="zoom:50%;" />

意思就是你用windowSurface时就不能再去调其它的3D图形的API了

但是Imgui调用的`SDL_GL_SwapWindow(window)`刚好就是

```cpp
/**
 * Update a window with OpenGL rendering.
 *
 * This is used with double-buffered OpenGL contexts, which are the default.
 *
 * On macOS, make sure you bind 0 to the draw framebuffer before swapping the
 * window, otherwise nothing will happen. If you aren't using
 * glBindFramebuffer(), this is the default and you won't have to do anything
 * extra.
 *
 * \param window the window to change
 *
 * \since This function is available since SDL 2.0.0.
 */
extern DECLSPEC void SDLCALL SDL_GL_SwapWindow(SDL_Window * window);
```

所以这两个函数应该是不能同时调的，我的实验结果就是`SDL_UpdateWindowSurface(window)`会覆盖掉`SDL_GL_SwapWindow(window)`，不论先后。

中途我还尝试了一下用opengl的`glDrawPixels`搞了半天，但是没搞定，我也不知道咋回事，opengl真不熟。

但是解决方案其实也是有的，比如说把要展示的图片弄成一个opengl的2D贴图，然后传给`Imgui::Image()`，但是，又是opengl... 我顶不住了orz。

有人也给出了相关的实现[【Dear imgui】有关Image的实现_Gary的面包屑小道的博客-CSDN博客](https://blog.csdn.net/DY_1024/article/details/105690739)，但是最后好像他也没能够把图片弄在背景里，而是搞到一个小窗口里了。

总之先这样吧，反正我个人感觉软渲染器加上Imgui会有点臃肿而且**麻烦**，如果有一天我熟练掌握了opengl，或者vulkan...? 到时候这可能也不是啥问题了。🤔