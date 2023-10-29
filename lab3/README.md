




## challenge 要求： LRU 页面替换算法在C中的实现

# 算法思路：

1. **数据结构**：使用一个双向链表表示缓存。链表的头部存放最新使用的页面，而尾部存放最近最少使用的页面。

2. **查找操作**：
   - 当需要检查一个页面是否在缓存中时，遍历链表以查找该页面。
   - 如果该页面已经在缓存中（即在链表中），则将其从当前位置删除并移动到链表的头部，表示它现在是最新使用的页面。

3. **插入操作**：
   - 当缓存未满时，直接在链表头部添加新页面。
   - 如果缓存已满（即链表的大小达到了上限），则先从链表尾部删除一个页面（即最近最少使用的页面），然后再在链表头部添加新的页面。

4. **替换操作**：当需要将一个新的页面放入缓存，但缓存已满时，删除链表尾部的页面（即最近最少使用的页面），然后在链表头部添加新的页面。

5. **优化**：为了提高查找效率，可以使用哈希表与双向链表结合的方式实现LRU。哈希表用于存放页面与其在链表中的位置的映射，这样可以在O(1)的时间复杂度内判断一个页面是否在缓存中，并迅速找到其在链表中的位置。


- 当页面被访问或添加到缓存时，始终将其移动到链表的头部。
- 当需要替换页面时，总是从链表的尾部删除页面，因为它是最近最少使用的。
- 双向链表是实现这一策略的关键，因为它允许我们在O(1)的时间内从链表中删除一个节点，并在链表的头部或尾部添加一个节点。


### 数据结构和变量

- `list_entry_t pra_list_head;`：这是一个链表入口，表示LRU算法的主要数据结构，即页面列表。

### 主要函数

1. **_lru_init_mm**：此函数初始化`pra_list_head`链表并将`mm->sm_priv`设置为`pra_list_head`的地址。这样，通过内存控制结构`mm_struct`，我们可以访问LRU页面替换算法。

2. **_lru_map_swappable**：根据LRU算法，每当访问一个页面时，它都应该移动到`pra_list_head`队列的尾部，表示它是最近使用的。 

3. **_lru_swap_out_victim**：根据LRU算法，我们应该在`pra_list_head`队列前断开最近最少使用的页面的链接，然后将此页面的地址设置为`ptr_page`。

### 其他函数

- **_lru_init**、**_lru_set_unswappable** 和 **_lru_tick_event** 都是为特定需求（例如初始化、设置页面为不可交换或处理定时事件）而定义的函数，但在所提供的代码段中，这些函数的实现为空。

### 结构体

- `swap_manager swap_manager_lru`：这个结构体定义了与LRU算法相关的函数指针，以及该算法的名称。其中`.check_swap`使用了`_fifo_check_swap`，这意味着LRU和FIFO都共享某种检查交换的逻辑。

### 在vmm结构体中添加成员变量跟踪页面的访问过程

了在`vmm`结构体中跟踪页面访问以供LRU算法使用:

1. **增加跟踪成员**:
   
   首先，在`mm_struct`或`vma_struct`中增加一个跟踪页面访问的链表或数组。考虑到LRU需要知道哪个页面最久未使用，使用一个链表结构是最合适的。

   ```c
   struct mm_struct {
       ...
       struct list_head lru_page_list;
       ...
   };
   ```

   这里使用Linux内核提供的双向链表`list_head`结构。每次页面被访问，都会将其移至链表的前部。这样，链表尾部的页面就是最久未使用的页面。

2. **页面跟踪结构体**:
   
   为了存储页面的信息，可以创建一个新的结构体。

   ```c
   struct lru_page {
       struct list_head list; // 用于插入到mm_struct的lru_page_list中
       struct page *pg;      // 指向内核中的页面结构体
       unsigned long last_access_time; // 最后访问时间，可以使用jiffies
   };
   ```

3. **修改页面访问函数**:
   
   当页面被访问时，需要更新LRU链表。找到相关的页面访问函数（比如`handle_mm_fault()`）并修改它，每次访问页面时，都将对应的`lru_page`移至链表的前部。这可以使用Linux提供的`list_move_tail`函数。

   ```c
   struct lru_page *lpage = ...; // 找到被访问的页面的lru_page
   lpage->last_access_time = jiffies;
   list_move_tail(&lpage->list, &mm->lru_page_list);
   ```

4. **LRU接口**:
   
   为LRU算法提供一个接口，例如`get_lru_page()`，该函数返回最久未使用的页面。

   ```c
   struct page *get_lru_page(struct mm_struct *mm) {
       if (list_empty(&mm->lru_page_list))
           return NULL;

       struct lru_page *lpage = list_entry(mm->lru_page_list.prev, struct lru_page, list);
       return lpage->pg;
   }
   ```

5. **页面释放**:

   当页面被释放或替换时，确保也从LRU链表中移除对应的`lru_page`结构体。

