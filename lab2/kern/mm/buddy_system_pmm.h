// kern/mm/default_pmm.h
#ifndef __KERN_MM_BUDDY_SYSTEM_PMM_H__
#define __KERN_MM_BUDDY_SYSTEM_PMM_H__
#include <pmm.h>
extern const struct pmm_manager buddy_system_pmm_manager;
struct Page *buddy_alloc_pages(size_t n);
void buddy_free_pages(struct Page *base, size_t n);

#endif /* ! __KERN_MM_BUDDY_SYSTEM_PMM_H__ */