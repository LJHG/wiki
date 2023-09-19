---
title: 手写一个vector
date: 2023-09-19 22:23:00
tags: [vector, cpp]
---
# 手写一个vector
> 日期: 2023-09-19

前两天在b站刷到一个手写vector的视频，于是就照着写了一下，新的c++知识增加了。。。

[手写一个 std::vector 可以有多复杂？_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1iX4y1w7x4/?spm_id_from=333.999.0.0&vd_source=c0c1ccbf42eada4efb166a6acf39141b)

直接上代码：

```cpp
#include<bits/stdc++.h>
using namespace std;

template<class T>
class _vector{
public:
    using value_type = T;
    using reference_type = T&; 
    using const_reference_type = const T&;
    using iterator = T*; //其实还可以有 const_iterator，但是这里不多实现了
private:
    T* m_data;
    size_t m_size;
    size_t m_capacity;
public:
    // 默认构造函数
    constexpr _vector() noexcept : m_data(), m_size(), m_capacity() {}
    // 析构函数
    ~_vector(){ 
        // 先去调用每一个元素的析构函数，然后再删除这一段内存
        for(size_t i=0; i<m_size; i++){
            m_data[i].~T();
        }
        if(m_data){
            delete m_data;
        }
    }  
    // 拷贝构造
    _vector(_vector& rhs){
        // 非异常安全，后面调用拷贝构造函数时可能会抛异常，那么前面分配的空间就会泄漏，可以使用方式来避免
        //先分配相同capacity的一段空间
        m_data =  static_cast<T*>(operator new(rhs.m_capacity * sizeof(T)));
        // 对于每一个元素调用它的拷贝构造函数
        for(size_t i = 0; i<rhs.size(); i++){
            new(&m_data[i]) T(rhs.m_data[i]); // new定位运算符，可以在指定内存地址构造对象
        }
        m_capacity = rhs.m_capacity;
        m_size = rhs.m_size;
    }
    // 移动构造
    _vector(_vector&& rhs){
        m_data = rhs.m_data;
        m_size = rhs.m_size;
        m_capacity = rhs.m_capacity;
        rhs.m_data = nullptr;
        rhs.m_size = 0;
        rhs.m_capacity = 0;
    }
    
    // 重载operator []
    T& operator[](int idx){
        return m_data[idx];
    }
    
    //迭代器
    iterator begin(){
        return m_data;
    }
    iterator end(){
        return m_data + m_size;
    }
    
    // data
    T* data(){
        return m_data;
    }

    // size
    size_t size(){
        return m_size;
    }

    // capacity
    size_t capacity(){
        return m_capacity;
    }

    // empty
    bool empty(){
        return m_size == 0;
    }

    // clear 删除所有元素，但是capacity不会变
    void clear(){
        for(size_t i=0; i<m_size; i++){
            m_data[i].~T();
        }
        m_size = 0;
    }
    
    // pop_back
    void pop_back(){
        if(empty()) return;
        m_size -= 1;
        m_data[m_size].~T(); //调用最后一个元素的析构
    }
    

    // push_back
    void push_back(T& rhs){
        cout<<"push_back func1"<<endl;
        this->emplace_back(rhs);
    }
    void push_back(T&& rhs){
        cout<<"push_back func2"<<endl;
        // 虽然rhs是右值引用，但是这里还是要std::move一下，这样emplace_back里面才能拿到右值
        this->emplace_back(std::move(rhs));
    }

    template<typename... ArgsT>
    T& emplace_back(ArgsT&&... args){
        if(m_size < m_capacity){
            m_size += 1;
        }else{
            //扩容
            // 先申请一段新的内存
            m_capacity = ceil((m_capacity+1) * 1.0f * 1.5);
            T* m_data_new = static_cast<T*>(operator new(m_capacity * sizeof(T))); //记得static cast
            // 把原本内存的元素移动到新的地方
            for(int i=0;i<m_size;i++){
                new(&m_data_new[i]) T(std::move(m_data[i])); //移动构造
            }
            // 删除原来的内存
            for(int i=0;i<m_size;i++){
                m_data[i].~T(); // 调用析构
            }
            delete m_data;

            m_size += 1;
            m_data = m_data_new;
        }
        // 在末尾构造一个元素
        T* cur = new(&m_data[m_size-1]) T(std::forward<T>(args)...);
        return *cur;
    }
};

void test1(){
    _vector<int> _v;
    _v.push_back(1);
    _v.push_back(2);
    _v.push_back(3);
    _v.push_back(4);
    _v.push_back(5);
    _v.push_back(6);
    _v.push_back(7);
    cout<<_v.size()<<" "<<_v.capacity()<<endl;
    for(int i=0;i<_v.size();i++){
        cout<<_v[i]<<" ";
    }
    cout<<endl;
    
    _vector<int> _v2(_v);
    cout<<_v2.size()<<" "<<_v2.capacity()<<endl;
    for(int i=0;i<_v2.size();i++){
        cout<<_v2[i]<<" ";
    }
    cout<<endl;
}


int main(){
    test1();
    return 0;
}
```

大体描述一下，总是要实现一个vector，至少在这段代码里面，我觉得重点应该在于：

1. 拷贝构造应该怎么实现 -> 首先分配和传入对象大小相同的一段内存(**怎么分配一段内存**)，然后对于内存的每一个位置，对于每一个元素调用拷贝构造函数来新建对象(**怎么在一个指定地址新建对象**)。 
2. 析构函数怎么实现 -> 先调用每一个元素的析构(**怎么调用析构**)，然后delete这段内存。
3. 因为push_back就是去调emplace_back，所以重点在于emplace_back应该怎么实现。不过还需要注意的是，对于接受右值引用为参数的push_back在继续向下传递时，要使用std::move，不然的话传进去就变左值了。
4. emplace_back怎么实现 -> 其实就是扩容后，需要重新分配更大的内存，然后把原来的元素通过移动构造的方式在新的内存新建。分配完后在末尾原地构造新元素，因为emplace_back可以接收各种参数，所以这里如何构造取决于外部传入的参数(如果是一堆参数那么就是普通构造，如果是左值引用那么就是拷贝构造，如果是右值引用那么就是移动构造。。。)



一些新学习的语法：

* `using value_type = T;` 其实和typedef 差不多
* `m_data[i].~T();` 调用析构
* `m_data =  static_cast<T*>(operator new(rhs.m_capacity * sizeof(T)));` 使用operator new 分配一段内存
* `new(&m_data[i]) T(rhs.m_data[i]);` 在指定地址新建对象

