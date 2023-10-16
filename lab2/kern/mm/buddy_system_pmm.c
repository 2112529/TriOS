
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

#define MAX_ORDER (10)  // 定义最大的块大小为2^10
#define BUDDY_END (~0x0UL)

// 定义伙伴页结构体
struct buddy_page {
    int order; // 记录块大小
    list_entry_t page_link; // 用于链接的链表结点
};

free_area_t free_area[MAX_ORDER + 1]; // 定义一个数组，用于存放各个块大小的空闲块链表

static struct Page *buddy_start = NULL; // 伙伴系统起始页的指针
static unsigned long buddy_pages = 0;  // 记录伙伴系统的总页数

// 以下为伙伴系统的私有助手函数

// 将页转换为索引
static inline unsigned long page_to_idx(struct Page *page) {
    return page - buddy_start;
}

// 将索引转换为页
static struct Page *idx_to_page(unsigned long idx) {
    return buddy_start + idx;
}

// 获取伙伴的索引
static unsigned long get_buddy_idx(unsigned long idx, unsigned long order) {
    return idx ^ (1 << order);
}

// 释放页面的函数
static void __free_pages(struct Page *page, int order) {
    unsigned long idx = page_to_idx(page);
    for (; order < MAX_ORDER - 1; ++order) {
        unsigned long buddy_idx = get_buddy_idx(idx, order);
        struct buddy_page *buddy = (struct buddy_page *)idx_to_page(buddy_idx);
        if (buddy->order != order) {
            break;
        }
        list_del(&(buddy->page_link)); // 从链表中删除
        idx &= buddy_idx;
    }
    struct buddy_page *buddy_page = (struct buddy_page *)idx_to_page(idx);
    buddy_page->order = order;
    list_add(&(free_area[order].free_list), &(buddy_page->page_link)); // 添加到空闲链表中
}

// 分配页面的函数
static struct Page *__alloc_pages(int order) {
    for (int o = order; o <= MAX_ORDER; ++o) {
        if (!list_empty(&(free_area[o].free_list))) {
            list_entry_t *le = list_next(&(free_area[o].free_list));
            struct buddy_page *page = (struct buddy_page *)le2page(le, page_link);
            list_del(le); // 从空闲链表中删除
            if (o != order) {
                unsigned long idx = page_to_idx((struct Page *)page);
                for (int i = o - 1; i >= order; --i) {
                    idx += 1 << i;
                    struct buddy_page *new_page = (struct buddy_page *)idx_to_page(idx);
                    new_page->order = i;
                    list_add(&(free_area[i].free_list), &(new_page->page_link)); // 添加到对应大小的空闲链表中
                }
            }
            return (struct Page *)page;
        }
    }
    return NULL;
}

// 以下为基于伙伴系统的公共物理内存管理函数

// 初始化函数
static void buddy_init(void) {
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_init(&(free_area[i].free_list)); // 初始化空闲链表
        free_area[i].nr_free = 0;
    }
}

// 初始化内存映射函数
static void buddy_init_memmap(struct Page *base, size_t n) {
    buddy_start = base;
    buddy_pages = n;
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    __free_pages(base, MAX_ORDER);
}

// 分配n个页面的函数
struct Page *buddy_alloc_pages(size_t n) {
    assert(n > 0 && (1 << MAX_ORDER) >= n);
    int order = 0;
    while ((1 << order) < n) {
        ++order;
    }
    struct Page *page = __alloc_pages(order);
    if (page) {
        struct buddy_page *buddy_page = (struct buddy_page *)page;
        buddy_page->order = order;
        free_area[order].nr_free--;
    }
    return page;
}

// 释放n个页面的函数
void buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0 && (1 << MAX_ORDER) >= n);
    int order = 0;
    while ((1 << order) < n) {
        ++order;
    }
    __free_pages(base, order);
}

// 获取当前空闲页面数量的函数
static size_t buddy_nr_free_pages(void) {
    size_t ret = 0;
    for (int i = 0; i <= MAX_ORDER; i++) {
        ret += free_area[i].nr_free * (1 << i);
    }
    return ret;
}

// 检查伙伴系统的函数
static void buddy_check(void) {
    // 实现伙伴系统的基础检查
}

const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};




