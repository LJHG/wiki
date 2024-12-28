---
title: 软光栅器MicroRenderer(三) 着色器(完结)
date: 2022-06-01 12:06:00
tags: [MicroRenderer]
---
# 软光栅器MicroRenderer(三) 着色器
代码见：https://github.com/LJHG/MicroRenderer

本节会对软渲染器剩下的内容进行说明，主要包括：
1. 模型加载
2. 贴图uv颜色采样
3. 更加复杂的shader的设计，本项目中主要实现了 Gouraud shader以及Phong shader。



## 1. 模型加载

首先来看一下Mesh这个类都包含哪些成员变量：

```cpp
class Mesh{
public:
    Mesh();

    /** getter and setter for vertices and indices **/
    std::vector<VertexData>& getVertices();
    std::vector<unsigned int>& getIndices();
    Material getMaterial();
    std::string getTextureUrl();
    void setVertices(const std::vector<VertexData>& _vertices);
    void setIndices(const std::vector<unsigned int>& _indices);
    void setMaterial(Material _material);
    void addVertex(VertexData v);
    void addIndex(unsigned int idx);
    void setTextureUrl(std::string _textureUrl);

    /** set model matrix **/
    void setModelMatrix(const glm::mat4& m);
    glm::mat4 getModelMatrix();


    /** quick create mesh functions **/
    void asTriangle(VertexData v1, VertexData v2, VertexData v3); // read 3 vertices and as a triangle
    void asCube(glm::vec3 center, float size, Material _material); // use fot generate point light


private:
    std::vector<VertexData> vertices;
    std::vector<unsigned int> indices;
    Material material;
    std::string textureUrl;
    glm::mat4 modelMatrix;
};
```

可以看到，首先是最重要的顶点和下标，也就是vertices 和 indices，这存储了顶点的信息以及顶点之间的连接关系。同时mesh还包含了材质mateiral，包含了ka, kd 以及ks，一般来说我们认为一个mesh的材质是固定的。mesh还包含了textureUrl用来保存贴图的路径，以及一个modelMatrix，来处理有的mesh需要移动的情况。

同时，VertexData的成员主要如下所示：

```cpp
struct VertexData{
    glm::vec3 position;
    glm::vec3 normal;
    glm::vec4 color; //如果是Phong shader, 那么就不使用color这个属性，而是去查询纹理或者直接用材质
    glm::vec2 textureCoord; // 纹理坐标
};
```

对于color这个属性，这里要加以说明一下。之前我们在使用 THREE_D_SHADER 绘制三角形时，直接给顶点赋了颜色，同时vertex shader 和 fragment shader 也是直接传递颜色，那个时候就是直接使用color这个属性来进行绘制。

在使用 Gouraud shader 或者 Phong shader时，顶点的颜色就不会被指定了。所以VertexData这个结构体的color属性就不会被用到了。这两个Shader具体怎么着色会在后续进行说明。



上面对于一个Mesh的成员变量已经阐述完毕了，所以接下来我们就要在加载obj模型时把这些成员变量给填满就行了。

在这里模型加载我使用了[assimp](https://github.com/assimp/assimp)这个来进行实现。只要给定obj的文件路径，就可以从**obj里面解析出若干个mesh**。这里要稍微注意一下，一个obj文件里是可以包括多个mesh的，所以不能把加载模型的这个函数作为Mesh类的一个成员函数。因此，我单独在外边写了一个加载模型的函数，并且返回的是一个Mesh的vector。

```cpp
static std::vector<Mesh> loadObjModel(std::string filepath)
{
    std::vector<Mesh> meshes;
    Assimp::Importer import;
    const aiScene* scene = import.ReadFile(filepath, aiProcess_Triangulate | aiProcess_FlipUVs);
    // 异常处理
    if (!scene || scene->mFlags == AI_SCENE_FLAGS_INCOMPLETE || !scene->mRootNode)
    {
        std::cout << "读取模型出现错误: " << import.GetErrorString() << std::endl;
        exit(-1);
    }
    // 模型文件相对路径
    std::string rootPath = filepath.substr(0, filepath.find_last_of('/'));

    // 循环生成 mesh
    for (int i = 0; i < scene->mNumMeshes; i++)
    {
        // 创建mesh
        Mesh mesh;

        // 获取 assimp 的读取到的 aiMesh 对象
        aiMesh* aiMesh = scene->mMeshes[i];

        VertexData vertexData;
        // 我们将数据传递给我们自定义的mesh
        for (int j = 0; j < aiMesh->mNumVertices; j++)
        {
            // 顶点
            glm::vec3 vvv;
            vvv.x = aiMesh->mVertices[j].x;
            vvv.y = aiMesh->mVertices[j].y;
            vvv.z = aiMesh->mVertices[j].z;
            vertexData.position = vvv;

            // 法线
            vvv.x = aiMesh->mNormals[j].x;
            vvv.y = aiMesh->mNormals[j].y;
            vvv.z = aiMesh->mNormals[j].z;
            vertexData.normal = glm::normalize(vvv); // 法线记得要归一化

            // 纹理坐标: 如果存在则加入。assimp 默认可以有多个纹理坐标 我们取第一个（0）即可
            glm::vec2 vv(0, 0);
            if (aiMesh->mTextureCoords[0])
            {
                vv.x = aiMesh->mTextureCoords[0][j].x;
                vv.y = aiMesh->mTextureCoords[0][j].y;
            }
            vertexData.textureCoord = vv;
            vertexData.color = glm::vec4(128,128,128,0); //设置一个默认颜色。。
            mesh.addVertex(vertexData);
        }

        // 传递面片索引
        for (int j = 0; j < aiMesh->mNumFaces; j++)
        {
            aiFace face = aiMesh->mFaces[j];
            for (int k = 0; k < face.mNumIndices; k++)
            {
                mesh.addIndex(face.mIndices[k]);
            }
        }

        // 读取材质和贴图
        if(aiMesh->mMaterialIndex >= 0){
            aiMaterial *material = scene->mMaterials[aiMesh->mMaterialIndex];
            // 这里只考虑漫反射贴图了，暂时先不去管镜面反射贴图
            if(material->GetTextureCount(aiTextureType_DIFFUSE) == 0){
                //没有漫反射贴图，直接读取 ka kd ks
                std::cout<<"do not has texture, read material"<<std::endl;
                aiColor3D color;
                material->Get(AI_MATKEY_COLOR_AMBIENT, color);
                glm::vec3 ka = glm::vec3(color.r,color.g, color.b);
                material->Get(AI_MATKEY_COLOR_DIFFUSE, color);
                glm::vec3 kd = glm::vec3(color.r,color.g, color.b);
                material->Get(AI_MATKEY_COLOR_SPECULAR, color);
                glm::vec3 ks = glm::vec3(color.r,color.g, color.b);
                mesh.setMaterial(Material(ka,kd,ks,16.0f)); // set shininess at 16.0f...
            }
            else{
                //有漫反射贴图，记录 ka ,ks，并且把贴图路径记录下来
                std::cout<<"has texture"<<std::endl;
                aiColor3D color;
                material->Get(AI_MATKEY_COLOR_AMBIENT, color);
                glm::vec3 ka = glm::vec3(color.r,color.g, color.b);
                glm::vec3 kd = glm::vec3(0.0f,0.0f, 0.0f);
                material->Get(AI_MATKEY_COLOR_SPECULAR, color);
                glm::vec3 ks = glm::vec3(color.r,color.g, color.b);
                mesh.setMaterial(Material(ka,kd,ks,16.0f)); // set shininess at 16.0f...
                // 贴图路径
                aiString _textureUrl;
                material->GetTexture(aiTextureType_DIFFUSE,0,&_textureUrl);
                mesh.setTextureUrl(rootPath + "/" + _textureUrl.C_Str());
            }
        }


        // add mesh
        meshes.push_back(mesh);
    }

    return meshes;
}
```

这里要稍微说一下关于材质和贴图的处理。有的obj文件是没有贴图的，对于这种情况就直接读取模型的材质ka kd ks即可，模型的材质路径不需要去单独设置了，不去设置会默认设置为none。如果obj文件有贴图，那么就把kd这一项给设置为全0，并且为mesh设置材质的路径，后续读取到贴图的颜色后再把颜色赋值给kd。

> 这里之所以这样做是因为我们这里只考虑了漫反射贴图，其实有的时候还会有镜面反射贴图的，不过这里先不管这些了。在只考虑漫反射贴图时，我们可以使用在贴图上颜色去替代材质的kd这一项。

至此，模型的加载已经结束。

## 2. 贴图uv颜色采样

刚刚在读取模型时我们已经在Mesh里面拿到了贴图的文件路径。根据顶点的纹理坐标，我们可以在贴图上去拿到颜色值，然后赋给kd，进行着色。

在这里我们使用 [stb_image.h](https://github.com/nothings/stb/blob/master/stb_image.h) 这个头文件来进行图片的读取。

```cpp
Image CommonUtils::loadImage(std::string url) {
    int width,height,channel;
    uint8_t* rgb_image = stbi_load(url.c_str(), &width, &height, &channel, 3);
    Image image(rgb_image,width,height,channel);
    return image;
}
```

这里读取来的图片会被保存在一个 char* 的数组里。图片的保存格式是RGBRGBRGB...左上角对应index 0，右下角对应 index 最大，同时颜色按行存储。比如说第一行的index对应 0，1，2，3，4，第二行对应 5，6，7，8，9。这非常的重要，这影响到后面颜色采样是否对的问题。

后续在着色时，我们会再次把mesh的贴图路径传递给shader，并且在shader里把贴图读取到，然后就可以开始进行颜色的采样了。

我这里时直接把颜色采样写在了shader里，没有单独再去封装函数了，大概长这样：

```cpp
if(textureUrl != "none"){
    int xIdx = v.textureCoord[0] * texture.width;
    int yIdx = (1-v.textureCoord[1]) * texture.height;
    int idx = (yIdx * texture.width + xIdx)*3;
    kd = glm::vec3(texture.pixels[idx+0]/255.0f,
                   texture.pixels[idx+1]/255.0f,
                   texture.pixels[idx+2]/255.0f);
}
```

因为纹理坐标是在(0,1)的，所以需要分别乘上一个宽度和高度，再经过把float -> int，直接向下取整得到纹理坐标。

> 关于这里为什么是 (1-v.textureCoord[1])，是因为uv坐标，也就是纹理坐标的开始位置(0,0)在左下角，而我们读取的图片的开始位置(0,0)在左上角，所以在y分量的处理上要这样做。

同时，在计算对应像素的index的时候记得要乘上一个3，也就是通道数。

>tips：要实现更精细的采样纹理坐标，还可以做双线性插值或者三线性插值，这里先不弄了。



## 3. shader编写

根据不同的着色频率，我们可以编写不同的shader。

在Blinn-Phong着色模型中，根据不同的着色频率，可以分为三个shader：

1. Flat shader，计算三角形的法线，为三角形进行着色。
2. Gouraud shader, 为每个顶点计算法线，计算出每个顶点的颜色然后插值出每个像素的颜色。
3. Phong shader，为每个像素插值出法线，直接为每个像素计算着色。

这里我们仅仅实现下面两个，也就是Gouraud shader以及Phong shader。

### 写在之前

关于各种类的设计是非常多的，我这里对与shader这个类的设计可能不是非常优雅，但是基本可以实现功能。不过在这里还是稍微阐述一下shader的设计思路。

首先渲染是交给渲染管线来做的：

```cpp
class ShadingPipeline {
public:
    ShadingPipeline(int _width,int _height,Shader* _shader);
    void shade(const std::vector<VertexData>& _vertices,
               const std::vector<unsigned int>& _indices,
               int rasterizingMode);
    void clearBuffer();
    uint8_t* getResult();
    Shader* shader; 
private:
    int width;
    int height;
    uint8_t* image;
    float* zBuffer;
    glm::mat4 viewPortMatrix;
    void bresenhamLineRasterization(VertexOutData& from, VertexOutData& to);
    void fillRasterization(VertexOutData& v1, VertexOutData& v2, VertexOutData& v3);
};
```

每一个渲染管线有一个Shader变量，Shader变量负责提供vertexShader以及fragmentShader在渲染管线里进行调用。

这里其实设计得不是很好，因为我这里给渲染管线的Shader变量的类型是Shader的基类，也就是说，如果后续我写的一个Shader类继承了这个基类，并且定义了一些变量以及函数，那么在渲染管线里也还是拿不到的。

所以没有办法，我就只好在Shader的基类里把所有可能用到的变量以及函数先定义好，然后在Shader基类的继承子类里只需要去实现 vertexShader 以及 fragmentShader这两个基函数即可。

```cpp
class Shader {
public:
    Shader() = default;
    virtual VertexOutData vertexShader(VertexData& v)  {VertexOutData _v; return _v;}; //meaningless implementation
    virtual glm::vec4 fragmentShader(VertexOutData& v) {glm::vec4 r; return r;}; //meaningless implementation
    void setModelMatrix(glm::mat4 matrix);
    void setViewMatrix(glm::mat4 matrix);
    void setProjectionMatrix(glm::mat4 matrix);

    //Gouraud and phong shader needed
    void setMaterial(Material _material);
    void setEyePos(glm::vec3 _eyePos);
    void addDirectionLight(DirectionLight* light);
    void addPointLight(PointLight* light);
    void setTexture(std::string _textureUrl);

protected:
    glm::mat4 modelMatrix;
    glm::mat4 viewMatrix;
    glm::mat4 projectionMatrix;

    //Gouraud and phong shader needed
    std::string textureUrl;
    Image texture;
    std::vector<DirectionLight*> directionLights; // multiple lights
    std::vector<PointLight*> pointLights;
    Material material;
    glm::vec3 eyePos;
};
```

比如这里定义的很多变量，例如 material, eyepos什么的，在 THREE_D_SHADER 里是完全用不到的。



### 3.1 Gouraud shader

首先要为shader添加光源，从上面可以看到，shader里有两个vector，一个用来存放平行光，一个用来存放点光源。通过调用 `addDirectionLight` 以及 `addPointLight`函数，我们就可以为shader添加光源。

>  在使用Blinn-Phong着色模型时，必须要添加光源，因为颜色其实就是光与材质作用的结果。

简单展示一下光源的代码：

```cpp
class Light{
public:
    glm::vec3 ambient;
    glm::vec3 diffuse;
    glm::vec3 specular;

};

class DirectionLight : public Light{
public:
    DirectionLight(glm::vec3 _ambient, glm::vec3 _diffuse, glm::vec3 _specular, glm::vec3 _direction);
    glm::vec3 direction;
};

class PointLight : public Light{
public:
    PointLight(glm::vec3 _ambient, glm::vec3 _diffuse, glm::vec3 _specular, glm::vec3 _position);
    void setLightPos(glm::vec3 _position);
    glm::vec3 position;
};
```

然后就是 Gouraud shader 对于自己的vertex shader以及fragment shader的具体实现了，具体如下所示：

```cpp
VertexOutData GouraudShader::vertexShader(VertexData &v) {
    VertexOutData vod;
    vod.position = glm::vec4(v.position,1.0f);
    vod.position = projectionMatrix * viewMatrix * modelMatrix * vod.position; //mvp transformation
    vod.normal = v.normal;

    // 计算着色
    glm::vec3 ka = material.ka;
    glm::vec3 kd = material.kd;
    if(textureUrl != "none"){
        int xIdx = v.textureCoord[0] * texture.width;
        int yIdx = (1-v.textureCoord[1]) * texture.height;
        int idx = (yIdx * texture.width + xIdx)*3;
        kd = glm::vec3(texture.pixels[idx+0]/255.0f,
                       texture.pixels[idx+1]/255.0f,
                       texture.pixels[idx+2]/255.0f);
    }
    glm::vec3 ks = material.ks;

    glm::vec3 color(0.0f,0.0f,0.0f);

    //directional lights
    for(const auto& light:directionLights){
        glm::vec3 lightDir = glm::normalize(-light->direction); // pos -> light
        glm::vec3 viewDir = glm::normalize(eyePos - v.position); // pos -> view
        glm::vec3 half = glm::normalize(lightDir + viewDir); // 半程向量
        glm::vec3 L_a = light->ambient * kd;
        glm::vec3 L_d = light->diffuse * kd * std::max(0.0f,glm::dot(v.normal,lightDir));
        glm::vec3 L_s = light->specular * ks * pow(std::max(0.0f,glm::dot(v.normal,half)),material.shininess);


        color += (L_a + L_d + L_s)*255.0f;
    }

    //point lights
    for(const auto& light:pointLights){
        glm::vec3 lightDir = glm::normalize(light->position - v.position); // pos -> light
        glm::vec3 viewDir = glm::normalize(eyePos - v.position); // pos -> view
        glm::vec3 half = glm::normalize(lightDir + viewDir); // 半程向量

        float distance = MathUtils::calPoint2PointSquareDistance(v.position,light->position);

        glm::vec3 L_d = light->diffuse * kd * std::max(0.0f,glm::dot(v.normal,lightDir));
        glm::vec3 L_s = light->specular * ks * pow(std::max(0.0f,glm::dot(v.normal,half)),material.shininess);


        color += (L_d/distance + L_s/distance)*255.0f;
    }


    color = glm::vec3(std::min(color[0],255.0f), std::min(color[1],255.0f),std::min(color[2],255.0f));

    vod.color = glm::vec4(color,1.0f);

    return vod;
}

glm::vec4 GouraudShader::fragmentShader(VertexOutData &v) {
    return v.color;
}
```

具体没什么好说的，关于Blinn-Phong着色模型的原理可以看一下[这里](https://www.ljhblog.top/CG/GAMES101/assignment3.html)。需要注意的是 Gouraud shader 的主要代码部分是在 vertexShader，而fragmentShader就直接传递颜色即可。

最后实现出来的结果如下所示：

![1](https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202206011450942.gif)

可以看到，地面没有被照亮，因为点光源里地板的四个顶点太远了，点光源对于四个顶点的颜色贡献不大。

![2](https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202206011452620.gif)

加载纹理的情况下，Gouraud shader的效果也不是很好，因为等于说纹理坐标都没有进行插值，而是直接拿纹理坐标去查询，效果肯定不会特别好。



### 3.2 Phong shader

对于Phong shader，其实基本上就是把 Gouraud shader 的vertex shader搬到了fragment shader中去。

> 稍微提一下，在把世界坐标，纹理坐标等传递给fragment shader之前是需要进行插值的，这里我还是选择了使用了二维的中心坐标插值，可能会有一点问题。

shader的代码主要如下所示：

```cpp
VertexOutData PhongShader::vertexShader(VertexData &v) {
    VertexOutData vod;
    vod.position = glm::vec4(v.position,1.0f);
    vod.position = projectionMatrix * viewMatrix * modelMatrix * vod.position; //mvp transformation
    vod.worldPos = modelMatrix * glm::vec4(v.position,1.0f);  // vec3 = vec4...
    vod.normal = v.normal;
    vod.textureCoord = v.textureCoord;

    return vod;
}

glm::vec4 PhongShader::fragmentShader(VertexOutData &v) {
    // 计算着色
    glm::vec3 ka = material.ka;
    glm::vec3 kd = material.kd;
    if(textureUrl != "none"){
        int xIdx = v.textureCoord[0] * texture.width;
        int yIdx = (1-v.textureCoord[1]) * texture.height;
        int idx = (yIdx * texture.width + xIdx)*3;
        kd = glm::vec3(texture.pixels[idx+0]/255.0f,
                       texture.pixels[idx+1]/255.0f,
                       texture.pixels[idx+2]/255.0f);
    }
    glm::vec3 ks = material.ks;

    glm::vec3 color(0.0f,0.0f,0.0f);

    //directional lights
    for(const auto& light:directionLights){
        glm::vec3 lightDir = glm::normalize(-light->direction); // pos -> light
        glm::vec3 viewDir = glm::normalize(eyePos - v.worldPos); // pos -> view
        glm::vec3 half = glm::normalize(lightDir + viewDir); // 半程向量
        glm::vec3 L_a = light->ambient * kd;
        glm::vec3 L_d = light->diffuse * kd * std::max(0.0f,glm::dot(v.normal,lightDir));
        glm::vec3 L_s = light->specular * ks * pow(std::max(0.0f,glm::dot(v.normal,half)),material.shininess);


        color += (L_a + L_d + L_s)*255.0f;
    }

    //point lights
    for(const auto& light:pointLights){
        glm::vec3 lightDir = glm::normalize(light->position - v.worldPos); // pos -> light
        glm::vec3 viewDir = glm::normalize(eyePos - v.worldPos); // pos -> view
        glm::vec3 half = glm::normalize(lightDir + viewDir); // 半程向量

        float distance = MathUtils::calPoint2PointSquareDistance(v.worldPos,light->position);

        glm::vec3 L_d = light->diffuse * kd * std::max(0.0f,glm::dot(v.normal,lightDir));
        glm::vec3 L_s = light->specular * ks * pow(std::max(0.0f,glm::dot(v.normal,half)),material.shininess);


        color += (L_d/distance + L_s/distance)*255.0f;
    }


    color = glm::vec3(std::min(color[0],255.0f), std::min(color[1],255.0f),std::min(color[2],255.0f));



    return glm::vec4(color,1.0f);
}
```

最后实现出来的结果如下所示：

![phong_shading](https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202206011457405.gif)

可以看到，地面有明显的光照反射了，因为现在是逐像素着色了。

![rock](https://raw.githubusercontent.com/ljhgpp/whatisthis/main/static/202206011459984.gif)

同时，石头的纹理也更加清楚了，因为现在是把纹理坐标插值后再去查询颜色。



## 4. 最后

目前这个软渲染器差不多就实现这么多了，不会再添加例如PCF，PCSS这些新功能了，基本上触及到我的知识盲区了。同时现在跑一个Phong shader已经非常卡了，感觉一秒只有5帧吧，当然这和我写的不好也有问题，期间基本上没考虑性能的问题，越写到后面越放飞自我，然后结构也开始比较混乱了。。。

不过一路把一个软渲染器从头到尾实现收获还是非常大，让我更加清楚地理解了渲染管线的运作流程，比如说什么地方该做mvp变换，什么地方应该做插值等等。。。虽然有的地方我的代码架构和实际的硬件实现区别会很大，不过我感觉基本上应该也差不大是这么一个流程吧。。。

总之暂时先这样吧。。。🤓



