---
title: 如何将imgui跑起来
date: 2022-09-05 15:58:31
tags: [imgui]
---

# 如何将imgui跑起来

不得不说imgui的新手指引真的太劝退了，居然没有一个傻瓜式的直接用cmake编译的例子，这对于cmake小白(我)来说太不友好了。加之imgui本身支持很多后端(opengl, vulkan, metal...)，第一眼看过去根本不知所措，我连要include哪些文件都不知道。

于是，在经过一天多的摸索后，我终于把imgui跑起来了。

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202209052028875.png" alt="image-20220905202805000" style="zoom: 30%;" />

首先，如果要将imgui导入你的项目，你需要将整个imgui项目导入你的项目中，比如这样：

<img src="https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202209052030522.png" alt="image-20220905203020499" style="zoom:30%;" />

然后你需要编写相关的CmakeLists...

```cmake
cmake_minimum_required(VERSION 3.21)
project(imgui_demo)

set(CMAKE_CXX_STANDARD 14)

find_package(glfw3 REQUIRED) # 添加glfw
find_package(GLEW REQUIRED) # 添加glew

include_directories(imgui)
include_directories(imgui/backends)

add_executable(imgui_demo
        main.cpp
        imgui/imgui.cpp
        imgui/imgui_draw.cpp
        imgui/imgui_tables.cpp
        imgui/imgui_demo.cpp
        imgui/imgui_widgets.cpp
        imgui/backends/imgui_impl_glfw.cpp
        imgui/backends/imgui_impl_opengl3.cpp
        )

target_link_libraries(imgui_demo glfw GLEW::GLEW)
```

你需要确定自己要用什么后端来跑，这里我们就选择最简单的opengl好了，那么你就需要导入 glfw+glew(这里我是这么选的，其实也可以glfw + glad ?)，总之你需要确定自己需要确定自己要导入什么库。

接着include相关的文件夹，再在add_executable里确定相关的文件就可以跑了。。。

这里的main.cpp我选择了imgui官方提供的example_glfw_opengl3里的main.cpp来跑。

