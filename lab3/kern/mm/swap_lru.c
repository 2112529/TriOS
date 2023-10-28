#include <swap.h>
#include <list.h>
#include <swap_fifo.h>
// kern/mm/swap_lru.c
list_entry_t pra_list_head;

/*
* (1) _lru_init_mm: init pra_list_head and let mm->sm_priv point to the addr of pra_list_head.
* Now, From the memory control struct mm_struct, we can access LRU PRA
*/
static int
_lru_init_mm(struct mm_struct *mm)
{
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
    return 0;
}

/*
* (2)_lru_map_swappable: According LRU PRA, whenever a page is accessed, it should be moved
* to the back of pra_list_head queue, indicating it's the most recently used.
*/
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
    list_entry_t *entry = &(page->pra_page_link);
    assert(entry != NULL && head != NULL);

    // Move the accessed page to the back of the queue
    list_del(entry);
    list_add(head, entry);

    return 0;
}

/*
* (3)_lru_swap_out_victim: According LRU PRA, we should unlink the least recently used page 
* in front of pra_list_head queue, then set the addr of addr of this page to ptr_page.
*/
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick == 0);

    // Select the victim, which is the least recently used page (the one in front of the queue)
    list_entry_t* entry = list_prev(head);
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        *ptr_page = NULL;
    }
    return 0;
}

static int _lru_init(void)
{
    return 0;
}

static int _lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int _lru_tick_event(struct mm_struct *mm)
{
    return 0;
}

struct swap_manager swap_manager_lru =
{
    .name = "lru swap manager",
    .init = &_lru_init,
    .init_mm = &_lru_init_mm,
    .tick_event = &_lru_tick_event,
    .map_swappable = &_lru_map_swappable,
    .set_unswappable = &_lru_set_unswappable,
    .swap_out_victim = &_lru_swap_out_victim,
    .check_swap = &_fifo_check_swap,  // Assuming the check_swap is common for both FIFO and LRU
};