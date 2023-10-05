#ifndef _SLUB_PMM_H_
#define _SLUB_PMM_H_

#include <pmm.h>
#include <list.h>

// 前向声明SLUB数据结构
struct kmem_cache;
struct slab_page;

// 全局kmem_cache对象声明
extern struct kmem_cache global_page_cache;
extern struct kmem_cache default_cache;

// SLUB 助手函数声明
static struct slab_page *get_slab_from_page(struct Page *page);
static void *kmem_cache_grow(struct kmem_cache *cache);

// SLUB 公共函数声明
void kmem_cache_init(struct kmem_cache *cache, size_t size);
void *kmem_cache_alloc(struct kmem_cache *cache);
void kmem_cache_free(struct kmem_cache *cache, void *obj);

// SLUB 内存管理器声明
extern const struct pmm_manager slub_pmm_manager;

#endif /* _SLUB_PMM_H_ */
