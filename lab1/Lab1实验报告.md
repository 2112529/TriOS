# Lab1实验报告----中断

[TOC]

### 1.练习一：内核启动的程序入口操作

**1.la sp, bootstacktop**

这条指令la sp, bootstacktop在汇编语言中是用于加载地址的操作，其中la代表"load address"。

在计算机系统中，特别是在操作系统的内核中，堆栈是一个关键的数据结构。它用于存储临时数据，如函数调用时的返回地址、局部变量等。堆栈是一个后进先出(LIFO)的结构，意味着最后放入堆栈的数据项将首先被取出。

核心解释: 当操作系统的内核启动或执行某些任务时，它需要为这些任务分配一块内存作为它们的堆栈。在这里，bootstacktop是一个标识符，它指向这块分配给内核的堆栈的顶部。通过执行la sp, bootstacktop这条指令，我们实际上是在设置堆栈指针sp，使其指向这块内存的顶部。后续的函数调用、局部变量的存储等操作都会使用到这块内存。

目的: 为什么要设置堆栈的起始位置呢？在多任务操作系统中，每个任务或线程通常都有自己的堆栈。为内核设置明确的堆栈起始位置是确保内核可以正确地存储临时数据并执行功能的关键。此外，由于堆栈是后进先出的，所以设置正确的起始位置也有助于确保数据的有效管理和内存的最优使用。

**2.tail kern_init**

tail kern_init是一个跳转指令，用于将程序的执行流程从当前位置转移到kern_init函数。

在操作系统的启动过程中，一系列的初始化操作需要被执行以确保系统的正常运行。这些操作可能包括设备驱动的初始化、内存管理子系统的设置、文件系统的加载等。

核心解释: kern_init函数，如其名所示，是操作系统内核的主要初始化函数。它可能会调用其他的子函数或模块来完成特定的初始化任务。通过执行tail kern_init指令，我们确保了内核的这一初始化过程从kern_init函数开始执行。一旦这个函数被调用，它将按预定的顺序执行一系列的初始化操作。	

目的: 初始化是任何系统、应用或程序的关键部分。没有适当的初始化，系统可能会遇到各种问题，如错误、崩溃或意外的行为。通过确保从kern_init开始执行初始化，我们为操作系统提供了一个明确、有组织的起点，从而确保了系统的稳定和可预测的启动。

### 2.练习二：完善中断处理

**编程实现代码：**

```C
case IRQ_S_TIMER:
            clock_set_next_event();
            if(ticks==100){
                print_ticks();
                ticks=0;
                num++;
            }
            else ticks++;
            if(num==10)sbi_shutdown();
            break;
```

**代码说明：**

1. 设置下次时钟中断- clock_set_next_event()
2. 计数器（ticks）加一
3. 当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
4. 判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机

**实验验证结果：**

```cmd
Special kernel symbols:
  entry  0x000000008020000c (virtual)
  etext  0x00000000802009ee (virtual)
  edata  0x0000000080204010 (virtual)
  end    0x0000000080204028 (virtual)
Kernel executable memory footprint: 17KB
++ setup timer interrupts
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
nick@nick-virtual-machine:~/riscv64-ucore-labcodes/lab1$ 
```

### 3.拓展练习一：描述和理解中断流程

在计算机系统中，中断是外部事件对处理器的一种通知，通常来自I/O设备；而异常则是程序在运行中由于某种原因产生的突发事件。为了快速和正确地响应这些事件，一个操作系统必须有一个完备的异常和中断处理机制。在ucore中，中断和异常处理的流程是严格定义的，与MIPS指令集紧密相关。

**mov a0, sp的目的**

向函数传递参数。

在MIPS指令集中，a0至a3是用于存储函数参数的寄存器。在异常处理例程中，特别是__alltraps部分，mov a0, sp的指令将当前堆栈指针（sp）的值复制到a0寄存器中。这么做的目的是为后续的操作提供一个指向当前堆栈位置的引用，特别是当我们需要访问之前保存的寄存器值或传递给其他异常处理函数时。

**SAVE_ALL中寄存器保存在栈中的位置是如何确定的**

是根据当前sp指针的位置来进行确定的，即进行压栈处理

在MIPS中，当发生中断或异常时，为了保护当前执行上下文的状态，必须将许多寄存器的值保存到堆栈上。SAVE_ALL是一个宏，它定义了一个固定的保存顺序，这样，当我们需要恢复这些寄存器的值时，我们知道在哪里找到它们。

这些保存的顺序通常是根据MIPS的约定和硬件结构来确定的。例如，通常先保存常用的寄存器（如a0-a3, t0-t9），然后保存特殊用途的寄存器。具体的顺序可能还取决于操作系统设计者的选择，但通常要确保与MIPS的调用约定保持一致。

**对于任何中断，__alltraps中都需要保存所有寄存器吗？**

理论上，并不是每次中断或异常都需要保存所有的寄存器。但从实际实现的角度来看，__alltraps通常保存所有寄存器主要有以下原因：

简单性：保存所有寄存器简化了异常处理的逻辑，因为你总是知道所有寄存器的状态都被保存了。

可预测性：在复杂的系统中，不同的中断和异常可能需要不同的寄存器集。为了避免错误，保存所有寄存器提供了一个统一和可预测的行为。

安全性：不保存某些寄存器可能会导致未定义的行为，特别是在嵌套的中断或异常情境下。

然而，从性能的角度来看，保存和恢复所有的寄存器确实增加了中断响应的延迟。因此，高度优化的系统可能会选择只保存真正需要的寄存器。

---

**完整流程**

 **异常和中断产生**

当MIPS处理器运行的当前指令遇到异常（例如，一个无效的内存访问）或外部中断（例如，时钟中断）时，它会立即停止当前指令的执行，并跳转到一个预定的异常处理例程地址。这个地址通常是在启动时由操作系统设置的。

 **异常入口和寄存器保存**

当处理器跳转到异常处理例程时，它首先会执行一个称为__alltraps的代码段。这段代码的主要目的是保存处理器的状态，这样异常处理例程可以在稍后恢复它。

2.1. mov a0, sp

此指令的目的是将当前的堆栈指针（sp）的值移动到a0寄存器。这样做的原因是在后续的异常处理中，我们可能需要访问堆栈的内容，而a0寄存器可以作为一个指向这些内容的指针。

 

2.2. SAVE_ALL

MIPS架构定义了一组寄存器，这些寄存器保存了处理器的当前状态。SAVE_ALL宏的任务是将这些寄存器的值保存到堆栈中，这样在异常处理结束后，原始的处理器状态可以被恢复。通常，这些寄存器的保存顺序是预定义的，并与MIPS的硬件结构相关。

 

对于任何中断或异常，是否需要保存所有寄存器？答案是“不一定”。保存所有寄存器会增加中断响应的延迟，但这确保了系统可以在处理完中断后完全恢复原始状态。在一些场景中，为了提高性能，系统可能只保存和恢复一部分寄存器。但在ucore中，为了简单和可靠，__alltraps通常会保存所有寄存器。

 

\3. 中断和异常处理

一旦处理器的状态被保存，ucore会根据中断或异常的类型调用适当的处理程序。这可能涉及到修复一个错误，响应一个I/O设备的请求，或者重新调度一个新的进程运行。

 

\4. 退出异常处理

处理完中断或异常后，ucore会执行RESTORE_ALL宏，该宏会从堆栈中恢复之前保存的处理器状态。随后，它会使用eret指令返回到中断或异常发生前的指令。

 

\5. MIPS指令集的角色

MIPS指令集定义了一组与异常和中断处理相关的指令。例如，mtc0 和 mfc0 允许访问COP0协处理器中的特殊寄存器，这些寄存器用于配置和管理中断和异常。此外，eret指令是从异常处理返回正常执行的关键。

 

因此，ucore在中断和异常处理方面的设计充分展示了MIPS指令集的特性和能力。保存和恢复处理器状态是确保系统稳定性和可靠性的关键，而__alltraps代码段提供了这一功能。

 

### 4.拓展练习二：理解上下文切换机制

\1. csrw sscratch, sp和csrrw s0, sscratch, x0实现了什么操作，目的是什么？

这两条指令与RISC-V的系统级寄存器（CSR）有关。

 

csrw sscratch, sp: 这条指令将当前的堆栈指针（sp）写入系统寄存器sscratch。在RISC-V中，sscratch寄存器通常用作中断或异常处理的临时存储，它为异常处理提供了一个保存环境的地方。

 

csrrw s0, sscratch, x0: 这条指令从sscratch读取值到s0寄存器，并将x0（永远为0）写入sscratch。目的是保存sscratch寄存器的原始值到s0寄存器，同时将sscratch设置为0。这样，如果发生递归异常，异常向量知道它是从内核中来的。

 

\2. SAVE_ALL中保存了stval, scause这些CSR，而在RESTORE_ALL里面不还原它们？

这是一个非常细致的观察。事实上，当处理异常或中断时，这些寄存器的值是非常重要的，因为它们提供了异常的原因和相关的信息（例如，如果发生了页错误，stval将包含引发页错误的地址）。

 

但为什么在恢复时不恢复它们呢？原因是这些CSR中的值只在异常处理过程中是有意义的。一旦异常处理完成，并决定返回到原来的代码，这些寄存器的值不再是有意义的。因为你已经处理了引起异常的原因，并且希望继续执行，而不是回到引起异常的状态。

 

例如，考虑一个页错误。一旦你已经处理了这个错误，你不再需要知道引发错误的地址是什么——你只是想继续执行代码。因此，没有必要恢复这些寄存器。

 

\3. 这样store的意义何在呢？

保存这些CSR的意义是为了异常处理过程。在异常处理过程中，你需要知道异常的原因、类型、相关的信息等，这就是为什么你需要stval, scause等寄存器的值。

 

例如，scause可以告诉你异常的原因（是一个中断还是一个异常？是哪种类型的中断或异常？），而stval可以为某些类型的异常提供额外的上下文（如触发页错误的地址）。

### 5.拓展练习三：完善异常中断

**代码实现**：

```C
case CAUSE_ILLEGAL_INSTRUCTION:
            cprintf("Exception type:Illegal instruction\n");
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
            tf->epc += 4;
            //print_regs(&tf->epc);
            break;
        case CAUSE_BREAKPOINT:
            cprintf("Exception type: breakpoint\n");
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
            tf->epc += 4;
            //print_regs(&tf->epc);
            break;
```

异常指令的地址一定是和寄存器中存储的值有关系的

**代码说明：**

```
            //断点异常处理
            /* LAB1 CHALLLENGE3   YOUR CODE :  */
            /*(1)输出指令异常类型（ breakpoint）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
```

**实验验证结果：**

```
sbi_emulate_csr_read: hartid0: invalid csr_num=0x302
Exception type:Illegal instruction
Illegal instruction caught at 0x80200050
Exception type: breakpoint
ebreak caught at 0x80200054
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
```

至此，时钟中断，interrupt中断以及break中断都已经实现

**实验评分展示**

![image-20230919233307287](C:\Users\MT.37\AppData\Roaming\Typora\typora-user-images\image-20230919233307287.png)

如图所示，，输出的结果为：

```
nick@nick-virtual-machine:~/riscv64-ucore-labcodes/lab1$ make grade
gmake[1]: Entering directory '/home/nick/riscv64-ucore-labcodes/lab1' + cc kern/init/entry.S + cc kern/init/init.c + cc kern/libs/stdio.c + cc kern/debug/kdebug.c + cc kern/debug/kmonitor.c + cc kern/debug/panic.c + cc kern/driver/clock.c + cc kern/driver/console.c + cc kern/driver/intr.c + cc kern/trap/trap.c + cc kern/trap/trapentry.S + cc kern/mm/pmm.c + cc libs/printfmt.c + cc libs/readline.c + cc libs/sbi.c + cc libs/string.c + ld bin/kernel riscv64-unknown-elf-objcopy bin/kernel --strip-all -O binary bin/ucore.img gmake[1]: Leaving directory '/home/nick/riscv64-ucore-labcodes/lab1'
try to run qemu
qemu pid=3923
  -100 ticks:                                OK
Total Score: 100/100
```

---

