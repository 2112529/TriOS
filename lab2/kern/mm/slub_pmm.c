#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <buddy_system_pmm.h>
// SLUB 数据结构
#define list_for_each(pos, head) \
    for (pos = (head)->next; pos != (head); pos = pos->next)

struct kmem_cache_node {
    struct list_entry partial; // 部分使用的 slab 列表
    struct list_entry full;    // 完全使用的 slab 列表
    unsigned int free_objects; // 空闲对象的计数
};
struct kmem_cache {
    size_t object_size;
    size_t num; // 对象数量 per slab (一页)
    struct list_entry partial; // 部分使用的 slab 列表
    struct list_entry full;    // 完全使用的 slab 列表
    struct kmem_cache_node node;
};

struct slab_page {

    struct kmem_cache *cache;
    unsigned int free_objects;
    struct list_entry list; // 连接到 partial 或 full 中
    void *free_pointer;     // 指向 slab 中的第一个可用对象
};

struct kmem_cache global_page_cache;  // 全局的kmem_cache对象
struct kmem_cache default_cache;  // 默认的kmem_cache对象，用于分配页面
static void slub_init(void) ;
static void slub_free_pages(struct Page *base, size_t n) ;
static struct Page *slub_alloc_pages(size_t n);
static void slub_init_memmap(struct Page *base, size_t n) ;
static size_t slub_nr_free_pages(void);
static void slub_check(void);
// Assume we have this global array as mentioned:
// extern struct Page* pages;

// Convert a Page to its kernel virtual address
static void *page2kva(struct Page *page) {
    uintptr_t pa = (page - pages) * PGSIZE;  // Get physical address
    return (void *)(pa + PHYSICAL_MEMORY_OFFSET);
}

// Convert a kernel virtual address to its corresponding Page
static struct Page *kva2page(void *kva) {
    uintptr_t pa = (uintptr_t)kva - PHYSICAL_MEMORY_OFFSET;
    return &pages[pa / PGSIZE];
}



// SLUB 助手函数
static struct slab_page *get_slab_from_page(struct Page *page) {
    return (struct slab_page *)(page->data);
}

static void *kmem_cache_grow(struct kmem_cache *cache) {
    struct Page *new_page = buddy_alloc_pages(1); // 从伙伴系统中分配一页
    if (!new_page) {
        return NULL;
    }
    struct slab_page *new_slab = get_slab_from_page(new_page);
    new_slab->cache = cache;
    new_slab->free_objects = cache->num;
    new_slab->free_pointer = page2kva(new_page);
    list_add(&(cache->partial), &(new_slab->list));
    return new_slab->free_pointer;
}

// Assuming a macro definition for le2slab
#define le2slab(le, member) to_struct((le), struct slab_page, member)

void kmem_cache_init(struct kmem_cache *cache, size_t size) {
    cache->object_size = size;
    cache->num = (PGSIZE - sizeof(struct slab_page)) / size;
    list_init(&cache->partial);
    list_init(&cache->full);
}

void *kmem_cache_alloc(struct kmem_cache *cache) {
    if (list_empty(&cache->partial)) {
        return kmem_cache_grow(cache);
    }

    struct list_entry *le = list_next(&cache->partial);
    struct slab_page *slab = le2slab(le, list);
    void *obj = slab->free_pointer;
    slab->free_pointer += cache->object_size;
    if (--slab->free_objects == 0) {
        list_del(le);
        list_add(&(cache->full), le);
    }
    return obj;
}

void kmem_cache_free(struct kmem_cache *cache, void *obj) {
    struct Page *page = kva2page(obj);
    struct slab_page *slab = get_slab_from_page(page);
    if (slab->free_objects == 0) {
        list_del(&slab->list);
        list_add(&cache->partial, &slab->list);
    }
    slab->free_objects++;
    slab->free_pointer = obj;
}

const struct pmm_manager slub_pmm_manager = {
    .name = "slub_pmm_manager",
    .init = slub_init,
    .init_memmap = slub_init_memmap,  // Placeholder, you may need to define these functions
    .alloc_pages = slub_alloc_pages,  // Placeholder
    .free_pages = slub_free_pages,    // Placeholder
    .nr_free_pages = slub_nr_free_pages,  // Placeholder
    .check = slub_check,
};

static void slub_init(void) {
    kmem_cache_init(&global_page_cache, PGSIZE);
    kmem_cache_init(&default_cache, PGSIZE);
}

static void slub_check(void) {
    assert(global_page_cache.object_size == PGSIZE);
}
static void slub_init_memmap(struct Page *base, size_t n) {
    // 初始化物理内存页的数据结构
    struct Page *p = base;
    for (; p != base + n; p++) {
        struct slab_page *slab = get_slab_from_page(p);
        slab->cache = NULL;
        slab->free_objects = 0;
        slab->free_pointer = NULL;
        list_init(&(slab->list));
    }
}

static struct Page *slub_alloc_pages(size_t n) {
    // 对于大的内存请求，我们仍然使用伙伴系统
    if (n != 1) {
        return buddy_alloc_pages(n);
    }
    // 否则，我们将使用默认的kmem_cache来分配一页
    // 假设已经存在名为default_cache的全局kmem_cache对象
    void *obj = kmem_cache_alloc(&default_cache);
    return kva2page(obj);
}

static void slub_free_pages(struct Page *base, size_t n) {
    if (n != 1) {
        return buddy_free_pages(base, n);
    }
    struct slab_page *slab = get_slab_from_page(base);
    kmem_cache_free(slab->cache, page2kva(base));
}

static size_t slub_nr_free_pages(void) {
    size_t free_pages = 0;

    struct kmem_cache_node *node = &global_page_cache.node;
    struct list_entry *le = NULL;
    struct slab_page *slab = NULL;

    // 遍历部分使用的slab，计算空闲对象数
    list_for_each(le, &node->partial) {
        slab = le2slab(le, list);
        free_pages += slab->free_objects;
    }

    // 虽然full slab列表里的slabs都被完全使用了，但出于完整性，我们还是遍历它
    list_for_each(le, &node->full) {
        // 实际上，这些slabs都被完全使用，所以没有增加free_pages计数器
    }

    return free_pages;
}