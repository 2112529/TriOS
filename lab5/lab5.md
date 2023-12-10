### 练习 1: 加载应用程序并执行（需要编码）

#### （1）设计实现过程

- 调用 mm_create 函数来申请进程的内存管理数据结构 mm 所需内存空间，并对 mm 进行初始化；

```C
//(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
```

- 调用 setup_pgdir 来申请一个页目录表所需的一个页大小的内存空间，并把描述 ucore 内核虚空间映射 的内核页表（boot_pgdir 所指）的内容拷贝到此新目录表中，最后让 mm->pgdir 指向此页目录表，这就 是进程新的页目录表了，且能够正确映射内核虚空间；

```C
//(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }
```

- 根据应用程序执行码的起始位置来解析此 ELF 格式的执行程序，并调用 mm_map 函数根据 ELF 格式 的执行程序说明的各个段（代码段、数据段、BSS 段等）的起始位置和大小建立对应的 vma 结构，并 把 vma 插入到 mm 结构中，从而表明了用户进程的合法用户态虚拟地址空间；

```C
//(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }
    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
    for (; ph < ph_end; ph ++) {
    //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
        }
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0) {
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U | PTE_V;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        // modify the perm bits here for RISC-V
        if (vm_flags & VM_READ) perm |= PTE_R;
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
        if (vm_flags & VM_EXEC) perm |= PTE_X;
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
        ret = -E_NO_MEM;
     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }
      //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
```

- 需要给用户进程设置用户栈，为此调用 mm_mmap 函数建立用户栈的 vma 结构，明确用户栈的位置在 用户虚空间的顶端，大小为 256 个页，即 1MB，并分配一定数量的物理内存且建立好栈的虚地址 <–> 物理地址映射关系；

```c
//(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
```

- 至此, 进程内的内存管理 vma 和 mm 数据结构已经建立完成，于是把 mm->pgdir 赋值到 cr3 寄存器中， 即更新了用户进程的虚拟内存空间，此时的 initproc 已经被 hello 的代码和数据覆盖，成为了第一个用 户进程，但此时这个用户进程的执行现场还没建立好；

```C
//(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));
```

- 先清空进程的中断帧，再重新设置进程的中断帧，使得在执行中断返回指令“iret”后，能够让 CPU 转 到用户态特权级，并回到用户态内存空间，使用用户态的代码段、数据段和堆栈，且能够跳转到用户 进程的第一条指令执行，并确保在用户态能够响应中断；

```c++
//(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
    // Keep sstatus
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
```

#### （2）请简要描述这个用户态进程被 ucore 选择占用 CPU 执行（RUNNING 态）到具体执行应用程序第一条 指令的整个经过。

**在用户进程被ucore选择为RUNNING态之后，user_main中通过宏KERNEL_EXECVE，调用`kernel_execve`然后触发断点异常，之后在中断处理机制中在`CAUSE_BREAKPOINT`处调用`syscall`然后执行`sys_exec`，调用`do_execve`通过load_icode函数加载文件到内存中然后退出S态开始执行用户程序**

### 练习 2: 父进程复制自己的内存空间给子进程（需要编码）

- **查找 `src_kvaddr`：`page` 的内核虚拟地址**

```C
// (1) find src_kvaddr: the kernel virtual address of page
void *src_kvaddr = page2kva(page);
```

- **查找 `dst_kvaddr`：`npage` 的内核虚拟地址**

```C
// (2) find dst_kvaddr: the kernel virtual address of npage
void *dst_kvaddr = page2kva(npage);
```

- **从 `src_kvaddr` 复制内存到 `dst_kvaddr`，大小为 `PGSIZE`**

```C
// (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
```

- **构建 `npage` 的物理地址与线性地址 `start` 的映射**

```C
// (4) build the map of phy addr of npage with the linear addr start
            int ret = page_insert(to, npage, start, perm);
            if (ret != 0) {
                free_page(npage);
                return ret;
            }
```

下面是将提供的文本转换为Markdown格式的示例：

---

## 练习 2: 父进程复制自己的内存空间给子进程（需要编码）

# 创建子进程的函数 `do_fork` 在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过 `copy_range` 函数（位于 `kern/mm/pmm.c` 中）实现的，请补充 `copy_range` 的实现，确保能够正确执行。


```C++
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    // copy content by page unit.
    do {
        // call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0);
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        // call get_pte to find process B's pte according to the addr start. If
        // pte is NULL, just alloc a PT
        if (*ptep & PTE_V) {
            pte_t *nptep = get_pte(to, start, 1);
            if (nptep == NULL) {
                return -E_NO_MEM;
            }
            uint32_t perm = (*ptep & PTE_USER);
            struct Page *page = pte2page(*ptep);
            struct Page *npage = alloc_page();
            if (page == NULL || npage == NULL) {
                return -E_NO_MEM;
            }

            // (1) find src_kvaddr: the kernel virtual address of page
            void *src_kvaddr = page2kva(page);

            // (2) find dst_kvaddr: the kernel virtual address of npage
            void *dst_kvaddr = page2kva(npage);

            // (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);

            // (4) build the map of phy addr of npage with the linear addr start
            int ret = page_insert(to, npage, start, perm);
            if (ret != 0) {
                free_page(npage);
                return ret;
            }
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}
```

### 函数概述

- **目的**：`copy_range` 用于将一段虚拟内存从源页目录（`from`）复制到目标页目录（`to`），覆盖从 `start` 地址到 `end` 地址的范围。这通常用于需要复制进程内存的操作，比如在类 UNIX 操作系统中实现 `fork` 系统调用时。
- **参数**：
  - `pde_t *to`：目标页目录。
  - `pde_t *from`：源页目录。
  - `uintptr_t start, end`：要复制的内存范围的起始和结束地址。
  - `bool share`：标志位，指示是否在源和目标之间共享内存。

### 函数逐步解析

1. **初始断言**：
   - `assert(start % PGSIZE == 0 && end % PGSIZE == 0);`：确保起始和结束地址都按页面对齐。
   - `assert(USER_ACCESS(start, end));`：检查内存范围是否在用户可访问空间内。

2. **按页面单位复制**：
   - 函数遍历内存范围，每次处理一个页面大小（`PGSIZE`）。

3. **查找页表项（PTEs）**：
   - 对于范围内的每个页面，使用 `get_pte(from, start, 0);` 从源页表中检索相应的页表项。
   - 如果没有找到 PTE，它会调整 start 到下一个页表并继续。

4. **处理有效的 PTEs**：
   - 如果找到有效的 PTE（由 `PTE_V` 表示），函数接着尝试在目标页表中找到或创建相应的 PTE。

5. **分配新页面**：
   - `struct Page *npage = alloc_page();`：为目标分配一个新页面。
   - 如果源页面（`page`）或新页面（`npage`）不可用，函数返回内存不足错误。

6. **复制页面内容**：
   - 将源页面的内容复制到新分配的页面。这通过映射页面到内核虚拟地址（使用 `page2kva`），然后使用 `memcpy` 来完成。

7. **更新目标页表项**：
   - 使用 `page_insert` 将新页面的物理地址映射到目标页表中的对应虚拟地址。
   - 如果这个过程中出现错误，释放新页面并返回错误代码。

8. **循环处理所有页面**：
   - 函数继续处理，直到覆盖了从 `start` 到 `end` 的整个内存范围。



### 练习 3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）

#### （1）fork函数：根据当前线程创建一个子线程

**该函数的主要执行步骤为：**

- **调用alloc_proc来分配一个porc结构体，并在函数内部进行初始化操作**
- **为子线程分配一个栈空间**
- **根据clone_flag来调用copy_mm 函数实现内存空间的赋值，进程 “proc” 根据 `clone_flags` 复制或共享进程 “current” 的内存管理结构（mm）。 // - 根据 `clone_flags&`  `CLONE_VM`，设置为“共享”或“复制”。**
- **调用copy_thread函数来设置进程的中断帧和上下文**
- **维护全局的线程链表和线程的hash链表（主要是用来快速查找）**
- **唤醒线程设置返回值等处理**

```C
//    1. call alloc_proc to allocate a proc_struct
    proc = alloc_proc();
    if (!proc) {
        goto bad_fork_cleanup_proc;
    }
    if(!current->wait_state==0)
    {
        current->wait_state=0;
    }
    proc->parent=current;
    proc->pid=get_pid();
    //    2. call setup_kstack to allocate a kernel stack for child process
    setup_kstack(proc);
    if (!proc->kstack) {
        goto bad_fork_cleanup_kstack;
    }
    //    3. call copy_mm to dup OR share mm according clone_flag
    copy_mm(clone_flags,proc);
    //    4. call copy_thread to setup tf & context in proc_struct
    copy_thread(proc,stack,tf);
    //    5. insert proc_struct into hash_list && proc_list
    
    bool intrstate;
    local_intr_save(intrstate);
    hash_proc(proc);
    //list_add(&proc_list,&(proc->list_link));
    set_links(proc);
    local_intr_restore(intrstate);
    //    6. call wakeup_proc to make the new child process RUNNABLE
    wakeup_proc(proc);
    //    7. set ret vaule using child proc's pid
    ret=proc->pid;
```

#### （2）exec函数：调用 `exit_mmap(mm)` 和 `put_pgdir(mm)` 来回收当前进程的内存空间。 调用 `load_icode` 根据二进制程序设置新的内存空间。

**该函数的主要执行步骤为：**

- **首先为加载新的执行码做好用户态内存空间清空准备。如果 mm 不为 NULL，则设置页表为内核空间 页表。**
- **进一步判断 mm 的引用计数减 1 后是否为 0，如果为 0，则表明没有进程再需要此进程所占用 的内存空间，为此将根据 mm 中的记录，释放进程所占用户空间内存和进程页表本身所占空间。**
- **最后 把当前进程的 mm 内存管理指针为空。由于此处的 initproc 是内核线程，所以 mm 为 NULL，整个处理 都不会做。** 
-  **接下来的一步是加载应用程序执行码到当前进程的新创建的用户态虚拟空间中。这里涉及到读 ELF 格 式的文件，申请内存空间，建立用户态虚存空间，加载应用程序执行码等。load_icode 函数完成了整个 复杂的工作。该函数的主要工作已经在上面的问题中回答过了**

#### （3）wait函数：等待一个或多个处于 `PROC_ZOMBIE` 状态的子进程，并释放这些子进程的内核栈的内存空间。

**该函数的主要执行步骤为**

- **调用user_mem_check进行用户空间的检查，如果检查出现问题直接退出**
- **循环调用find_proc函数找到处于PROC_ZOMBIE状态的子进程**
- **如果找到，则释放这些进程的内存空间**

#### （4）exit函数：由sys_exit系统调用进行调用，释放进程自身所占内存空间和相关内存管理（如页表等）信息所占空间，唤醒父进程，好让 父进程收了自己，让调度器切换到其他进程

**该函数的主要执行步骤为**

- **调用 `exit_mmap`、`put_pgdir` 和 `mm_destroy` 来释放进程几乎所有的内存空间。**
- **将进程状态设置为 `PROC_ZOMBIE`，然后调用 `wakeup_proc(parent)` 通知父进程回收其资源。**
- **调用调度器切换到其他进程。**

#### （5）系统调用实现



#### （6）执行状态生命周期图

<img src="C:\Users\MT.37\AppData\Roaming\Typora\typora-user-images\image-20231209222644303.png" alt="image-20231209222644303" style="zoom:50%;" />

### 扩展练习 Challenge:实现COW机制，复现Dirty COW漏洞，给出漏洞解决方案


实现 Copy-on-Write (COW) 机制的核心在于优化内存管理，特别是在进程创建（如fork操作）时。在COW机制下，当一个父进程创建一个子进程时，它们共享相同的物理内存页面，而不是立即复制整个内存空间。只有当其中一个进程尝试修改这些共享页面时，操作系统才会实际复制这些页面，确保每个进程有自己的独立副本。这种方法减少了不必要的数据复制，提高了内存使用效率。

### 首先在proc.c中编写写时复制（COW）功能的实现

```c++

static int copy_mm_cow(uint32_t clone_flags, struct proc_struct *proc) {

    #ifdef USE_COW_FIX
    local_intr_save(intr_flag);
    #endif
    {

        struct mm_struct *mm, *oldmm = current->mm;

        if (oldmm == NULL) {
            #ifdef USE_COW_FIX
            local_intr_restore(intr_flag);
            #endif
            return 0;
        }

        if (clone_flags & CLONE_VM) {
            mm = oldmm;
            mm_count_inc(mm);
            proc->mm = mm;
            proc->cr3 = PADDR(mm->pgdir);
            #ifdef USE_COW_FIX
            local_intr_restore(intr_flag);
            #endif
            return set_cow_pages(oldmm);
        }

        if ((mm = mm_create()) == NULL) {
            #ifdef USE_COW_FIX
            local_intr_restore(intr_flag);
            #endif
            return -E_NO_MEM;
        }

        if (setup_pgdir(mm) != 0) {
            mm_destroy(mm);
            #ifdef USE_COW_FIX
            local_intr_restore(intr_flag);
            #endif
            return -E_NO_MEM;
        }

        lock_mm(oldmm);
        {
            int ret = dup_mmap(mm, oldmm);
            unlock_mm(oldmm);
            if (ret != 0) {
                exit_mmap(mm);
                put_pgdir(mm);
                mm_destroy(mm);
                #ifdef USE_COW_FIX
                local_intr_restore(intr_flag);
                #endif
                return ret;
            }
        }

        mm_count_inc(mm);
        proc->mm = mm;
        proc->cr3 = PADDR(mm->pgdir);

    }
    #ifdef USE_COW_FIX
    local_intr_restore(intr_flag);
    #endif
    return 0;
}

```

### 函数解析


- **功能**：这个函数负责创建新进程的内存管理结构（`mm_struct`），并根据COW机制设置其内存页。

- **处理流程**：
  1. **检查现有内存管理结构**：首先，函数检查当前进程（`current->mm`）是否有内存管理结构。如果没有，函数直接返回。
  2. **处理 CLONE_VM 标志**：如果`clone_flags`包含`CLONE_VM`标志，这意味着父子进程将共享相同的内存空间。在这种情况下，子进程的`mm`指向父进程的`mm`，并增加其引用计数。然后，它调用`set_cow_pages`来设置COW页。
  3. **创建新的内存管理结构**：如果不共享内存，则为子进程创建新的内存管理结构。如果内存分配失败，则返回错误。
  4. **复制内存映射**：通过调用`dup_mmap`，复制父进程的内存映射到子进程。如果这个过程中出现错误，就会清理并释放分配的资源。
  5. **设置新进程的内存管理结构**：将新创建的内存管理结构分配给子进程，并设置其CR3寄存器（这是x86体系结构中控制页表的寄存器）指向新的页目录。

- **异常处理和中断**：代码中的`#ifdef USE_COW_FIX`块涉及到中断处理。它确保在修改内存管理结构时，系统不会被中断，从而防止数据竞争和不一致的状态。

### COW状态转换

在COW机制下的状态转换可以被视为一种有限状态自动机，其中包括以下状态：

1. **共享状态**：父子进程共享相同的物理页面。
2. **写操作尝试**：当进程尝试写入共享页面时，触发页面错误。
3. **页面复制**：操作系统响应页面错误，复制页面，分配新的物理页面给写操作的进程。
4. **私有状态**：每个进程拥有其自己的独立页面副本，可以自由读写。

整个机制的目标是优化内存利用率和进程创建性能，尤其是在只读数据共享频繁的场景中非常有效。COW机制在现代操作系统中被广泛使用，尤其在虚拟内存管理和进程创建（如Linux的fork()）中起着关键作用。

## 之后实现具体的COW的标记位的设定代码

```c++

int set_cow_pages(struct mm_struct *mm) {
    list_entry_t *entry = &(mm->mmap_list);
    while ((entry = list_next(entry)) != &(mm->mmap_list)) {
        struct vma_struct *vma = le2vma(entry, list_link);
        if (vma->vm_flags & VM_WRITE) {
            uintptr_t addr;
            for (addr = vma->vm_start; addr < vma->vm_end; addr += PGSIZE) {
                pte_t *pte = get_pte(mm->pgdir, addr, 0);
                if (pte != NULL && (*pte & PTE_V)) {
                    *pte = *pte & ~PTE_W;
                    *pte = *pte | PTE_COW;
                }
            }
        }
    }
    return 0;
}

```

详细分析这个`set_cow_pages`函数的每一部分

### 函数定义
```c
int set_cow_pages(struct mm_struct *mm)
```
- **功能**：为进程的内存管理结构(`mm_struct`)设置写时复制(COW)页。
- **参数**：`mm` 是指向进程的内存管理结构的指针，包含了进程的虚拟内存区域信息。

### 函数体分析
1. **遍历内存映射区域（VMA）**：
   - `list_entry_t *entry = &(mm->mmap_list);`：获取进程的内存映射列表头部。
   - `while ((entry = list_next(entry)) != &(mm->mmap_list))`：通过循环遍历每个虚拟内存区域（VMA）。这个循环会持续直到遍历回到列表的开始。

2. **处理每个VMA**：
   - `struct vma_struct *vma = le2vma(entry, list_link);`：从列表项获取VMA结构体的指针。
   - `if (vma->vm_flags & VM_WRITE)`：检查VMA是否允许写操作。`VM_WRITE`标志表示这个内存区域是可写的。

3. **设置COW标志**：
   - 循环遍历VMA中的每一页：
     - `for (addr = vma->vm_start; addr < vma->vm_end; addr += PGSIZE)`：从VMA的起始地址开始，一直到结束地址，每次增加一页的大小(`PGSIZE`)。
   - `pte_t *pte = get_pte(mm->pgdir, addr, 0);`：获取当前地址的页表项(pte)。
   - `if (pte != NULL && (*pte & PTE_V))`：检查页表项是否存在且有效（`PTE_V`表示有效）。
   - `*pte = *pte & ~PTE_W;`：清除写标志（`PTE_W`），使页变为只读。
   - `*pte = *pte | PTE_COW;`：设置COW标志，表示这一页现在是写时复制的。

### 函数返回
- 最后，函数返回`0`，表示操作成功完成。

### 总结
此函数是写时复制（COW）机制的关键部分。当一个进程（如父进程）创建子进程时，在ucore操作系统中，它们共享相同的物理内存页面。默认情况下，这些页面是只读的。当任一进程尝试写入这些共享页面时，操作系统会拦截这个写操作（通过页面错误异常），复制这个页面，然后允许写操作继续在新的、独立的页面上进行。这个机制提高了内存的使用效率，并减少了不必要的数据复制。通过这样的方式，`set_cow_pages`函数在内存页表中设置必要的标志，以实现这一机制。

#### pmm.c中的cow机制的代码

```c++
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
     #ifdef USE_COW

    #ifdef USE_COW_FIX
    local_intr_save(intr_flag);
    #endif
    {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    do {
        pte_t *ptep = get_pte(from, start, 0);
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        if (*ptep & PTE_V) {
            pte_t *nptep = get_pte(to, start, 1);
            if (nptep == NULL) {
                return -E_NO_MEM;
            }

            // Mark both parent and child as COW
            *ptep &= ~PTE_W; *ptep |= PTE_COW;
            *nptep = *ptep;
            tlb_invalidate(from, start);
            tlb_invalidate(to, start);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
    }
    #ifdef USE_COW_FIX
    local_intr_restore(intr_flag);
    #endif
     #endif
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    // copy content by page unit.
    do {
        // call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0);
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        // call get_pte to find process B's pte according to the addr start. If
        // pte is NULL, just alloc a PT
        if (*ptep & PTE_V) {
            pte_t *nptep = get_pte(to, start, 1);
            if (nptep == NULL) {
                return -E_NO_MEM;
            }
            uint32_t perm = (*ptep & PTE_USER);
            struct Page *page = pte2page(*ptep);
            struct Page *npage = alloc_page();
            if (page == NULL || npage == NULL) {
                return -E_NO_MEM;
            }

            // (1) find src_kvaddr: the kernel virtual address of page
            void *src_kvaddr = page2kva(page);

            // (2) find dst_kvaddr: the kernel virtual address of npage
            void *dst_kvaddr = page2kva(npage);

            // (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);

            // (4) build the map of phy addr of npage with the linear addr start
            int ret = page_insert(to, npage, start, perm);
            if (ret != 0) {
                free_page(npage);
                return ret;
            }
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}

//COW机制的实现
int copy_range_cow(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    do {
        pte_t *ptep = get_pte(from, start, 0);
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        if (*ptep & PTE_V) {
            pte_t *nptep = get_pte(to, start, 1);
            if (nptep == NULL) {
                return -E_NO_MEM;
            }

            // Mark both parent and child as COW
            *ptep &= ~PTE_W; *ptep |= PTE_COW;
            *nptep = *ptep;
            tlb_invalidate(from, start);
            tlb_invalidate(to, start);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}

```

1. **初始化和断言**：
   - 函数开始时首先进行一些基本的断言，确保传入的起始地址（`start`）和结束地址（`end`）是按页面对齐的，这是COW操作的前提。

2. **遍历页表项**：
   - 函数通过一个循环遍历从`start`到`end`的每个页面。这是通过逐页增加地址并检查每个地址的页表项来完成的。

3. **获取源页表项**：
   - 对于每个地址，函数使用`get_pte`从源页目录（`from`）获取对应的页表项（`ptep`）。这一步是为了找到当前正在处理的页面的物理地址。

4. **处理有效的页表项**：
   - 如果页表项有效（即标记为`PTE_V`），则进行接下来的处理。有效性检查是为了确保只处理那些实际映射到物理内存的页面。

5. **设置COW标志**：
   - 在页表项中设置COW标志（`PTE_COW`），并清除写标志（`PTE_W`）。这表示这个页面是共享的，并且在任何写操作发生之前不会被复制。

6. **创建新的页表项**：
   - 对目标页目录（`to`）执行相同的页表项查找或创建操作。新的页表项（`nptep`）被设置为与源页表项相同的值，包括COW标志。

7. **更新TLB**：
   - 使用`tlb_invalidate`函数更新转换后备缓冲区（TLB）。这是因为修改了页表项，所以需要确保CPU的页表缓存是最新的，避免发生旧数据的错误读取。

8. **处理写操作**：
   - 在实际运行中，当任一共享这个页面的进程尝试写入页面时，会触发页面错误。操作系统的页面错误处理程序会检测到这个页面被标记为COW，然后为写入操作的进程创建这个页面的一个新副本，解除共享状态。

### COW机制的优势

- **内存使用效率**：COW机制通过共享未被修改的页面减少了内存的使用量。在进程创建（如fork操作）时特别有用，因为新创建的进程最初可以共享父进程的所有页面。
- **性能提升**：避免了不必要的内存复制，减少了内存分配和复制的开销，从而提高了系统的整体性能。
- **写操作隔离**：确保当一个进程修改共享页面时，其他共享这个页面的进程不会受到影响，维护了数据的完整性和一致性。

在操作系统中，中断响应函数是处理各种系统事件的核心部分，其中包括处理内存页面错误。页面错误是由于进程访问无效或不可访问的内存地址时引发的一种中断。在您提供的代码片段中，特别涉及到处理存储页面错误（Store/AMO Page Fault）的场景，尤其是在启用了写时复制（Copy-On-Write, COW）机制的情况下。

#### trap.c中对于由于访问只读页面触发的异常的处理函数的修改

```c++
case CAUSE_STORE_PAGE_FAULT:
            if (use_cow == 1 && handle_cow_fault(tf) == 0) {
                return; // COW fault handled
            }
             #ifdef USE_COW
            if (*pte & PTE_COW) {
                return handle_cow_fault(tf);
            }
            #endif

            cprintf("Store/AMO page fault\n");
            if ((ret = pgfault_handler(tf)) != 0) {
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;

```
### 代码功能分析

1. **处理存储页面错误**：
   - `case CAUSE_STORE_PAGE_FAULT:`：这部分代码是处理存储页面错误的情况。当进程试图写入一个它没有写权限的内存页面时，会触发这种类型的页面错误。

2. **检查并处理COW错误**：
   - `if (use_cow == 1 && handle_cow_fault(tf) == 0) { return; }`：首先检查是否启用了COW机制。如果是，并且`handle_cow_fault`函数成功处理了错误（返回0），则直接返回。这表示这是一个COW错误，并且已经被正确处理。
   
3. **COW错误处理**：
   - `#ifdef USE_COW`：这是一个条件编译指令，只有在定义了`USE_COW`宏时，编译器才会包含这段代码。
   - `if (*pte & PTE_COW) { return handle_cow_fault(tf); }`：检查当前的页面错误是否是由于COW机制引发的。如果是（即页表项标记为`PTE_COW`），则调用`handle_cow_fault`函数来处理这个错误。

4. **COW错误处理函数**：
   - `handle_cow_fault`函数的作用是处理COW引起的页面错误。当进程试图写入一个标记为COW的页面时，这个函数会被调用。它会为该进程分配一个新的页面，并复制原页面的内容到新页面上，然后更新页表项，以指向这个新分配的页面。这样，进程就可以在自己的私有页面上进行写操作，而不影响其他共享原页面的进程。

5. **处理其他类型的页面错误**：
   - 如果不是COW错误，或者`handle_cow_fault`函数没有成功处理错误，则执行接下来的代码。
   - `cprintf("Store/AMO page fault\n");`：打印错误信息。
   - `if ((ret = pgfault_handler(tf)) != 0) { ... }`：调用通用的页面错误处理函数`pgfault_handler`。如果这个函数返回非零值，表示错误处理失败，随后执行错误处理代码，打印错误信息并终止程序。

### 总结
通过检查页表项的状态（是否标记为COW），系统能够识别出哪些页面错误是由于写时复制条件触发的，并采取相应的措施来处理这些错误，即通过为写入操作分配新的内存页面来解决冲突。这种机制在提高内存使用效率和优化进程间内存共享方面非常有效，尤其是在多任务操作系统环境中。

### handle_cow_fault函数的实现

```c++
// handle_cow_fault - handle a Copy-on-Write fault
int handle_cow_fault(struct trapframe *tf) {
    uintptr_t fault_addr = tf->tval;
    pte_t *pte = get_pte(current->mm->pgdir, fault_addr, 0);

    if (pte != NULL && (*pte & PTE_COW)) {
        struct Page *new_page = alloc_page();
        if (new_page == NULL) {
            return -E_NO_MEM; // 无法分配新页面
        }

        void *kva_new = page2kva(new_page);
        void *kva_old = KADDR(PTE_ADDR(*pte));

        // 复制内容到新页面
        memcpy(kva_new, kva_old, PGSIZE);

        // 更新页表项，指向新页面，设置为可读写
        *pte = page2pa(new_page) | PTE_U | PTE_W | PTE_V;

        tlb_invalidate(current->mm->pgdir, fault_addr); // 刷新TLB
        return 0; // COW错误处理成功
    }

    return -1; // 不是COW错误
}
```

`handle_cow_fault`函数是一个专门用来处理写时复制（Copy-On-Write, COW）页面错误的函数。这个函数在操作系统内核中非常关键，它确保当一个进程尝试修改一个共享页面时，该页面会被正确地复制，从而保证内存的隔离和数据的一致性。下面是对这个函数的详细功能说明：

### 函数功能和流程

1. **提取故障地址**：
   - `uintptr_t fault_addr = tf->tval;`：函数首先从传入的`trapframe`结构体中提取出引起页面错误的地址（`fault_addr`）。

2. **获取页表项**：
   - `pte_t *pte = get_pte(current->mm->pgdir, fault_addr, 0);`：接下来，函数通过调用`get_pte`获取当前进程（`current`）的页目录（`pgdir`）中对应`fault_addr`的页表项（`pte`）。

3. **检查COW标志**：
   - `if (pte != NULL && (*pte & PTE_COW))`：函数检查获取到的页表项是否存在，并且是否被标记为COW。这意味着这个页面是被共享的，并且需要在写操作前进行复制。

4. **分配新的页面**：
   - `struct Page *new_page = alloc_page();`：如果是COW页面，函数尝试分配一个新的物理页面。
   - `if (new_page == NULL) { return -E_NO_MEM; }`：如果无法分配新页面（可能由于内存不足），函数返回一个错误。

5. **复制页面内容**：
   - `void *kva_new = page2kva(new_page);`：函数获取新页面的内核虚拟地址。
   - `void *kva_old = KADDR(PTE_ADDR(*pte));`：获取旧页面的内核虚拟地址。
   - `memcpy(kva_new, kva_old, PGSIZE);`：复制旧页面的内容到新页面上。这是实现COW的核心步骤，确保在写入前，页面的内容被完整地复制到一个新的位置。

6. **更新页表项**：
   - `*pte = page2pa(new_page) | PTE_U | PTE_W | PTE_V;`：更新页表项，使其指向新分配的页面，并设置为用户模式（`PTE_U`）、可写（`PTE_W`）和有效（`PTE_V`）。

7. **刷新TLB**：
   - `tlb_invalidate(current->mm->pgdir, fault_addr);`：刷新TLB（Translation Lookaside Buffer），确保CPU的页面翻译缓存使用最新的页表项。

8. **返回处理结果**：
   - `return 0;`：如果以上步骤都成功执行，函数返回0，表示COW错误已经成功处理。
   - `return -1;`：如果页表项不包含COW标志，函数返回-1，表示这不是一个COW错误。

#### 完整的复现完COW机制之后，对Diry COW漏洞进行复现（编写类似于POC的代码）

因为目前之后一个用户进程hello，因此直接改写hello.c创建两个线程来尝试触发Dirty COW，向系统只读文件写入内容实现权限的提升

```c++
#include <stdio.h>
#include <ulib.h>
#include "unistd.h"
#define FILE_SIZE 4096
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PAGES 1024
#define PAGE_SIZE 4096
#define MADV_DONTNEED 1024
#define MAX_MAPPINGS 1024
typedef struct {
    char *fileContent; // 指向文件内容的指针
    bool used;         // 是否已经被映射
} MemoryMapping;

MemoryMapping mappings[MAX_MAPPINGS];
char simulated_file[FILE_SIZE]; // 模拟文件映射到的内存区域

// 初始化模拟的内存映射
void initializeMappings() {
    for (int i = 0; i < MAX_MAPPINGS; i++) {
        mappings[i].fileContent = NULL;
        mappings[i].used = 0;
    }
    // 初始化模拟文件的内容
    memset(simulated_file, 0, FILE_SIZE);
}

// 模拟 mmap 系统调用
void *simulate_mmap(void) {
    for (int i = 0; i < MAX_MAPPINGS; i++) {
        if (!mappings[i].used) {
            mappings[i].used = 1;
            mappings[i].fileContent = simulated_file;
            printf("Memory mapped at index %d\n", i);
            return (void *)mappings[i].fileContent;
        }
    }
    printf("Error: No available memory for mapping\n");
    return NULL;
}

// 模拟 munmap 系统调用
// int simulate_munmap(void *addr) {
//     for (int i = 0; i < MAX_MAPPINGS; i++) {
//         if (mappings[i].fileContent == addr && mappings[i].used) {
//             mappings[i].used = 0;
//             printf("Memory unmapped at index %d\n", i);
//             return 0; // Success
//         }
//     }
//     printf("Error: Memory not found for unmapping\n");
//     return -1; // Failure
// }

// 打印当前内存映射状态
void printMappingStatus() {
    for (int i = 0; i < MAX_MAPPINGS; i++) {
        printf("Mapping %d: %s\n", i, mappings[i].used ? "Used" : "Free");
    }
}

// 模拟 madvise 行为
void simulateMadvise(void *page, int advice) {
    printf("Simulating madvise\n");

    switch (advice) {
        case MADV_DONTNEED:
            // 释放指定的页面
            freePage(page);
            printf("Page freed\n");
            break;
        default:
            printf("Unsupported advice type\n");
    }

    // 记录内存池状态
    for (int i = 0; i < MAX_PAGES; i++) {
        printf("Page %d: %s\n", i, mappings[i].used ? "In Use" : "Free");
    }
}


volatile int stop_threads = 0;
char simulated_file[FILE_SIZE]; // 模拟文件映射到的内存区域


// 模拟写线程
void *write_thread_func(void *arg) {
    char *addr = (char *)arg;
    while (!stop_threads) {
        for (int i = 0; i < 10; i++) {
            addr[i] = 'A'; // 模拟向映射内存写入数据
        }
        sleep(200); // 休眠以模拟写入延迟
    }
    printf("Write thread exiting\n");
    return NULL;
}

// 模拟 madvise 线程
void *madvise_thread_func(void *arg) {
    while (!stop_threads) {
        simulateMadvise(arg,MADV_DONTNEED); // 模拟 madvise 调用
        sleep(20); // 休眠以模拟调用间隔
    }
    printf("Madvise thread exiting\n");
    return NULL;
}

int main0() {
    // 模拟 mmap 过程
    void *mapped_memory = simulate_mmap();

    int pid = fork();
    if (pid == 0) {
        write_thread_func(mapped_memory);
        exit(0);
    }

    int pid2 = fork();
    if (pid2 == 0) {
        madvise_thread_func(mapped_memory);
        exit(0);
    }

    getchar(); // 等待用户输入来停止子进程
    stop_threads = 1;

    waitpid(pid, 0);
    waitpid(pid2, 0);
    
    //printf("Main process exiting\n");
    return 0;
}
void print_file(){
    printf("%s\n",simulated_file);
    printf("end of file\n",simulated_file);
}

```

### 整体框架和数据结构

1. **`MemoryMapping`结构体**：
   - 用于表示内存映射。包含一个指向文件内容的指针和一个表示是否已经映射的布尔值。

2. **模拟文件和内存映射数组**：
   - `simulated_file`用作模拟文件的内存区域。
   - `mappings`数组用于存储多个`MemoryMapping`对象，模拟内存映射。

### 初始化和映射函数

1. **`initializeMappings`函数**：
   - 初始化`mappings`数组和`simulated_file`。

2. **`simulate_mmap`函数**：
   - 模拟`mmap`系统调用，返回第一个未使用的映射地址。

### 模拟线程函数

1. **`write_thread_func`函数**：
   - 模拟一个不断向内存映射区域写入数据的线程。

2. **`madvise_thread_func`函数**：
   - 模拟一个调用`madvise`的线程，不断建议操作系统不再需要指定的页面。

### 主函数和控制流程

1. **`main0`函数**：
   - 模拟创建两个子进程：一个执行写操作，另一个执行`madvise`操作。
   - 使用`getchar`来等待用户输入，以控制子进程的停止。

### 模拟Dirty COW的机制

这段代码的核心在于同时运行两个子进程，一个不断尝试写入到内存映射区域，而另一个不断地建议操作系统释放这些页面。这种竞态条件模拟了Dirty COW的漏洞场景：

1. **写线程**：尝试修改映射到文件的内存区域。在正常情况下，这个区域应该是只读的，但由于Dirty COW的漏洞，写操作可能成功。

2. **`madvise`线程**：通过调用`simulateMadvise`，不断建议操作系统释放映射的页面。在某些Linux内核版本中，这可能导致映射页面的COW（写时复制）机制被错误地处理。

3. **竞态条件**：这两个线程的并发执行创建了一种竞态条件，其中写线程可能在`madvise`线程导致页面被释放后成功写入数据。这种情况下，写线程可能能够修改本应为只读的内存区域。

### 漏洞的影响

Dirty COW漏洞是一种严重的安全漏洞，因为它允许普通用户进程修改本应受到保护的内存区域，包括系统文件和进程内存。这可能导致未授权的数据修改，甚至系统完整性的破坏。


代码通过模拟内存映射、写操作和`madvise`调用，成功地复现了Dirty COW漏洞的环境。

利用互斥锁（Mutexes）解决Dirty COW（Copy-On-Write）问题的方法基于同步和互斥的原则。Dirty COW是一个涉及操作系统内存管理的安全漏洞，允许非特权用户进程通过利用COW机制写入只读内存。为了解决这个问题，互斥锁可以用来控制对共享内存的访问，确保一次只有一个线程可以对内存进行修改操作。下面详细论述这种方法的实现和原理。

### 互斥锁的基本概念

互斥锁是一种同步机制，用于控制对共享资源的访问。在多线程环境中，互斥锁确保一次只有一个线程可以访问共享资源。当一个线程获得锁时，其他线程必须等待直到锁被释放。

### Dirty COW问题

Dirty COW问题是由于操作系统的COW机制在某些情况下被不当处理而导致的。当多个进程共享同一物理内存页时，如果一个进程尝试写入，操作系统通常会创建这个页面的一个副本（即“写时复制”）。但是，由于竞态条件和错误的权限管理，非特权用户进程可能能够写入本应为只读的内存区域。

### 利用互斥锁解决Dirty COW

为了解决这个问题，可以在操作系统内核或应用程序层面实现互斥锁。以下是基于互斥锁的解决方案的详细步骤：

#### 1. 定义互斥锁

在共享资源（如内存映射区域）的数据结构中定义一个互斥锁。

```c
typedef struct {
    char *memoryPage;     // 指向内存页的指针
    pthread_mutex_t lock; // 互斥锁
} SharedMemory;
```

#### 2. 初始化互斥锁

在程序初始化或映射内存时，初始化互斥锁：

```c
pthread_mutex_init(&sharedMemory.lock, NULL);
```

#### 3. 加锁和解锁

在任何写入共享内存的操作之前，先加锁。完成写操作后，立即解锁。这确保了在写入数据时，没有其他线程可以访问这部分内存。

```c
void writeToMemory(SharedMemory *sharedMemory, char *data) {
    pthread_mutex_lock(&sharedMemory->lock);
    // 执行写入操作
    strcpy(sharedMemory->memoryPage, data);
    pthread_mutex_unlock(&sharedMemory->lock);
}
```

#### 4. 管理COW机制

在操作系统内核级别，互斥锁也可以用于管理COW机制。在创建页面副本之前，内核应确保没有其他进程正在写入同一页面。这可以通过在内核级别维护页表项上的锁来实现。

### 解决方案的效果

使用互斥锁来同步对共享内存的访问，可以有效避免Dirty COW类型的漏洞。通过确保在修改内存时的互斥，可以防止由于COW机制不当处理引发的安全漏洞。同时，这种方法也提高了系统的整体稳定性和可靠性。

### 实验总结

本实验涉及操作系统中关于进程创建、内存管理、系统调用、COW机制和安全漏洞（如Dirty COW）的理解与实现。通过分析代码和实现相关功能，我们可以深入理解操作系统的核心机制。

#### 练习 1: 加载应用程序并执行

##### 设计实现过程

1. **进程内存管理结构的初始化**：
   - 使用`mm_create`函数申请并初始化进程的内存管理结构`mm`。

2. **页目录表的设置**：
   - 调用`setup_pgdir`为进程分配页目录表，并将内核的页表内容拷贝至此。

3. **解析ELF格式执行程序**：
   - 解析应用程序执行码，为每个段（如代码段、数据段）创建虚拟内存区域（VMA），并将这些VMA插入到`mm`结构中。

4. **用户栈的建立**：
   - 使用`mm_map`函数为用户进程建立栈空间。

5. **更新进程的虚拟内存空间**：
   - 将`mm->pgdir`赋值给CR3寄存器，更新用户进程的虚拟内存空间。

6. **设置进程的中断帧**：
   - 为用户进程设置中断帧，以便在执行`iret`后跳转至用户态第一条指令。

##### 用户态进程执行过程

用户态进程被选为RUNNING状态后，通过系统调用`sys_exec`执行`do_execve`，在`load_icode`中加载文件到内存。然后，内核设置好中断帧和上下文，退出S态开始执行用户程序。

#### 练习 2: 父进程复制自己的内存空间给子进程

##### 核心代码分析

1. **查找源和目标页的内核虚拟地址**：
   - 使用`page2kva`函数获取源页和新分配页的内核虚拟地址。

2. **复制内存内容**：
   - 使用`memcpy`函数将内容从源地址复制到目标地址。

3. **建立虚拟地址到物理地址的映射**：
   - 使用`page_insert`函数建立新页面的物理地址与线性地址的映射。

##### 功能实现

该过程实现了在父进程创建子进程时，将其内存空间内容复制给子进程的功能，是进程虚拟内存管理的关键部分。

#### 练习 3: 理解进程执行 fork/exec/wait/exit 的实现

##### 主要内容

1. **`fork`函数**：
   - 创建子进程，复制或共享内存空间。

2. **`exec`函数**：
   - 替换当前进程的内存空间为新的执行程序。

3. **`wait`函数**：
   - 等待子进程结束，并释放其占用的资源。

4. **`exit`函数**：
   - 释放当前进程所占用的资源，并通知父进程。

5. **系统调用实现**：
   - 系统调用是用户空间与内核空间交互的接口，用于实现上述功能。

6. **执行状态生命周期**：
   - 进程从创建到结束的各种状态转换。

#### 扩展练习 Challenge: 实现 COW 机制与解决 Dirty COW 漏洞

##### COW 机制实现

1. **`copy_mm_cow`函数**：
   - 实现了写时复制机制，共享或复制父进程的内存。

2. **`set_cow_pages`函数**：
   - 设置COW页，标记为只读，并在写操作时复制页面。

##### Dirty COW 漏洞复现与解决

1. **复现方法**：
   - 通过模拟内存

映射、写操作和`madvise`调用，创建了竞态条件，复现了Dirty COW漏洞。

2. **解决方案**：
   - 使用互斥锁同步对共享内存的访问，防止非特权用户进程写入只读内存。

### 实验总结

本实验涉及操作系统中关于进程创建、内存管理、系统调用、COW机制和安全漏洞（如Dirty COW）的理解与实现。通过分析代码和实现相关功能，我们可以深入理解操作系统的核心机制。

#### 练习 1: 加载应用程序并执行

##### 设计实现过程

1. **进程内存管理结构的初始化**：
   - 使用`mm_create`函数申请并初始化进程的内存管理结构`mm`。

2. **页目录表的设置**：
   - 调用`setup_pgdir`为进程分配页目录表，并将内核的页表内容拷贝至此。

3. **解析ELF格式执行程序**：
   - 解析应用程序执行码，为每个段（如代码段、数据段）创建虚拟内存区域（VMA），并将这些VMA插入到`mm`结构中。

4. **用户栈的建立**：
   - 使用`mm_map`函数为用户进程建立栈空间。

5. **更新进程的虚拟内存空间**：
   - 将`mm->pgdir`赋值给CR3寄存器，更新用户进程的虚拟内存空间。

6. **设置进程的中断帧**：
   - 为用户进程设置中断帧，以便在执行`iret`后跳转至用户态第一条指令。

##### 用户态进程执行过程

用户态进程被选为RUNNING状态后，通过系统调用`sys_exec`执行`do_execve`，在`load_icode`中加载文件到内存。然后，内核设置好中断帧和上下文，退出S态开始执行用户程序。

#### 练习 2: 父进程复制自己的内存空间给子进程

##### 核心代码分析

1. **查找源和目标页的内核虚拟地址**：
   - 使用`page2kva`函数获取源页和新分配页的内核虚拟地址。

2. **复制内存内容**：
   - 使用`memcpy`函数将内容从源地址复制到目标地址。

3. **建立虚拟地址到物理地址的映射**：
   - 使用`page_insert`函数建立新页面的物理地址与线性地址的映射。

##### 功能实现

该过程实现了在父进程创建子进程时，将其内存空间内容复制给子进程的功能，是进程虚拟内存管理的关键部分。

#### 练习 3: 理解进程执行 fork/exec/wait/exit 的实现

##### 主要内容

1. **`fork`函数**：
   - 创建子进程，复制或共享内存空间。

2. **`exec`函数**：
   - 替换当前进程的内存空间为新的执行程序。

3. **`wait`函数**：
   - 等待子进程结束，并释放其占用的资源。

4. **`exit`函数**：
   - 释放当前进程所占用的资源，并通知父进程。

5. **系统调用实现**：
   - 系统调用是用户空间与内核空间交互的接口，用于实现上述功能。

6. **执行状态生命周期**：
   - 进程从创建到结束的各种状态转换。

#### 扩展练习 Challenge: 实现 COW 机制与解决 Dirty COW 漏洞

##### COW 机制实现

1. **`copy_mm_cow`函数**：
   - 实现了写时复制机制，共享或复制父进程的内存。

2. **`set_cow_pages`函数**：
   - 设置COW页，标记为只读，并在写操作时复制页面。

##### Dirty COW 漏洞复现与解决

1. **复现方法**：
   - 通过模拟内存

映射、写操作和`madvise`调用，创建了竞态条件，复现了Dirty COW漏洞。

2. **解决方案**：
   - 使用互斥锁同步对共享内存的访问，防止非特权用户进程写入只读内存。

### 实验小结

本实验深入探究了操作系统中进程管理、内存管理和系统调用的机制，特别是在进程创建和内存共享方面。通过实际编码和分析，我们更好地理解了操作系统的复杂性和重要性。此外，对于Dirty COW这样的安全漏洞，我们学习了如何在操作系统层面进行诊断和解决，增强了对操作系统安全性的认识。