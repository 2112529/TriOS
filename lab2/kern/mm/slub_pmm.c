#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <buddy_system_pmm.h>

// 定义一个遍历链表的宏
#define list_for_each(pos, head) \
    for (pos = (head)->next; pos != (head); pos = pos->next)

// 宏定义
#define le2slab(le, member) to_struct((le), struct slab_page, member)


// SLUB中的结构体，描述内存缓存节点
struct kmem_cache_node {
    struct list_entry partial; // 保存部分使用的slab的链表
    struct list_entry full;    // 保存完全使用的slab的链表
    unsigned int free_objects; // 该节点中的空闲对象数量
};

// SLUB中的主要结构体，描述内存缓存
struct kmem_cache {
    size_t object_size;        // 单个对象的大小
    size_t num;                // 每个slab(一页内存)可以容纳的对象数量
    struct list_entry partial; // 保存部分使用的slab的链表
    struct list_entry full;    // 保存完全使用的slab的链表
    struct kmem_cache_node node; // 关联的内存缓存节点
};

// 描述一个slab的结构体
struct slab_page {
    struct kmem_cache *cache;   // 关联的内存缓存
    unsigned int free_objects;  // slab中的空闲对象数量 
    struct list_entry list;     // 用于将slab连接到部分使用或完全使用的链表
    void *free_pointer;         // 指向slab中第一个可用对象的指针
};

struct kmem_cache global_page_cache;  // 全局的内存缓存对象
struct kmem_cache default_cache;      // 默认的内存缓存对象，用于普通页面分配

// 将物理页面转换为内核虚拟地址
static void *page2kva(struct Page *page) {
    uintptr_t pa = (page - pages) * PGSIZE;
    return (void *)(pa + PHYSICAL_MEMORY_OFFSET);
}

// 将内核虚拟地址转换为其对应的物理页面
static struct Page *kva2page(void *kva) {
    uintptr_t pa = (uintptr_t)kva - PHYSICAL_MEMORY_OFFSET;
    return &pages[pa / PGSIZE];
}

// 从物理页面获取其对应的slab
static struct slab_page *get_slab_from_page(struct Page *page) {
    return (struct slab_page *)(page->data);
}

// 对给定的内存缓存增加一个新的slab
static void *kmem_cache_grow(struct kmem_cache *cache) {
    struct Page *new_page = buddy_alloc_pages(1); // 从伙伴系统中分配一页
    if (!new_page) {
        return NULL;
    }
    struct slab_page *new_slab = get_slab_from_page(new_page);
    new_slab->cache = cache;
    new_slab->free_objects = cache->num;
    new_slab->free_pointer = page2kva(new_page);
    list_add(&(cache->partial), &(new_slab->list)); // 将新的slab加入到部分使用的链表中
    return new_slab->free_pointer;
}

// 初始化给定大小的内存缓存
void kmem_cache_init(struct kmem_cache *cache, size_t size) {
    cache->object_size = size;
    cache->num = (PGSIZE - sizeof(struct slab_page)) / size;
    list_init(&cache->partial);
    list_init(&cache->full);
}

// 从给定的内存缓存中分配一个对象
void *kmem_cache_alloc(struct kmem_cache *cache) {
    if (list_empty(&cache->partial)) {
        // 如果部分使用的slab列表为空，增长缓存
        return kmem_cache_grow(cache);
    }

    struct list_entry *le = list_next(&cache->partial);
    struct slab_page *slab = le2slab(le, list);
    void *obj = slab->free_pointer;
    slab->free_pointer += cache->object_size;
    if (--slab->free_objects == 0) {
        // 如果slab没有空闲对象了，将其移至完全使用的链表
        list_del(le);
        list_add(&(cache->full), le);
    }
    return obj;
}

// 释放一个对象回到其内存缓存中
void kmem_cache_free(struct kmem_cache *cache, void *obj) {
    struct Page *page = kva2page(obj);
    struct slab_page *slab = get_slab_from_page(page);
    if (slab->free_objects == 0) {
        // 如果slab之前是完全使用的，将其移至部分使用的链表
        list_del(&slab->list);
        list_add(&cache->partial, &slab->list);
    }
    slab->free_pointer -= cache->object_size;
    slab->free_objects++;
}

// SLUB的初始化函数
static void slub_init(void) {
    kmem_cache_init(&global_page_cache, PGSIZE); // 初始化全局内存缓存
    kmem_cache_init(&default_cache, PGSIZE);    // 初始化默认内存缓存
}

// 释放给定的页面
static void slub_free_pages(struct Page *base, size_t n) {
    if (n != 1) {
        // 对于多页请求，直接使用伙伴系统释放
        return buddy_free_pages(base, n);
    }
    struct slab_page *slab = get_slab_from_page(base);
    kmem_cache_free(slab->cache, page2kva(base));
}

// 从SLUB中分配n个页面
static struct Page *slub_alloc_pages(size_t n) {
    // 对于大于1页的请求，直接使用伙伴系统
    if (n != 1) {
        return buddy_alloc_pages(n);
    }
    // 否则，使用默认的内存缓存来分配一个页面
    void *obj = kmem_cache_alloc(&default_cache);
    return kva2page(obj);
}

// 初始化物理内存映射
static void slub_init_memmap(struct Page *base, size_t n) {
    // 初始化给定范围内的每个物理页
    struct Page *p = base;
    for (; p != base + n; p++) {
        struct slab_page *slab = get_slab_from_page(p);
        slab->cache = NULL;
        slab->free_objects = 0;
        slab->free_pointer = NULL;
        list_init(&(slab->list)); // 初始化slab的链表节点
    }
}

// 获取当前空闲的页面数量
static size_t slub_nr_free_pages(void) {
    size_t free_pages = 0;

    struct kmem_cache_node *node = &global_page_cache.node;
    struct list_entry *le = NULL;
    struct slab_page *slab = NULL;

    // 遍历部分使用的slabs并累加空闲对象数量
    list_for_each(le, &node->partial) {
        slab = le2slab(le, list);
        free_pages += slab->free_objects;
    }
    // 遍历完全使用的slabs（实际上不会增加空闲页面计数，但出于完整性而遍历）
    list_for_each(le, &node->full) {}

    return free_pages;
}



