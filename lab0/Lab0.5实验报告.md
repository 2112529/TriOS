# Lab0.5实验报告

[TOC]

### 1.实验过程及分析

#### (1)计算机复位操作

当我们使用**make test指令**开始调试程序的时候，模拟的计算机开始上电，此时**pc指向0x1000**

我们使用si逐个运行指令的时候，我们可以发现最初运行的指令一共有五条：

```assembly
(gdb) x/5i 0x00001000
   0x1000:      auipc   t0,0x0
   0x1004:      addi    a1,t0,32
   0x1008:      csrr    a0,mhartid
   0x100c:      ld      t0,24(t0)
   0x1010:      jr      t0
```

在最后一条指令结束的时候我们就会**跳转到0x80000000位置**处**执行bootloader**相关的指令

分析这一段指令，我们发现这一段指令 的主要作用

- 相关寄存器的设置（清零）
- 为跳转到bootloader做准备
- 计算机状态的复位

#### (2)bootloader运行

首先我们回答为什么会跳转到0x80000000，我们查看qemu的源码发现，存在一个内存到地址的映射，映射如下：

```
} virt_memmap[] = {
    [VIRT_DEBUG] =       {        0x0,         0x100 },
    [VIRT_MROM] =        {     0x1000,       0x11000 },
    [VIRT_TEST] =        {   0x100000,        0x1000 },
    [VIRT_CLINT] =       {  0x2000000,       0x10000 },
    [VIRT_PLIC] =        {  0xc000000,     0x4000000 },
    [VIRT_UART0] =       { 0x10000000,         0x100 },
    [VIRT_VIRTIO] =      { 0x10001000,        0x1000 },
    [VIRT_DRAM] =        { 0x80000000,           0x0 },
    [VIRT_PCIE_MMIO] =   { 0x40000000,    0x40000000 },
    [VIRT_PCIE_PIO] =    { 0x03000000,    0x00010000 },
    [VIRT_PCIE_ECAM] =   { 0x30000000,    0x10000000 },
};
```

我们可以看见，0x80000000映射到了0x0，也就是初始位置，这样一个映射就规定了我们的qemu模拟之后的最初一段代码bootloader会出现在0x80000000处。

---

我们使用**x/10i 0x80000000**指令查看0x80000000附近的指令，如下所示

```assembly
(gdb) x/10i 0x80000000
=> 0x80000000:  csrr    a6,mhartid
   0x80000004:  bgtz    a6,0x80000108
   0x80000008:  auipc   t0,0x0
   0x8000000c:  addi    t0,t0,1032
   0x80000010:  auipc   t1,0x0
   0x80000014:  addi    t1,t1,-16
   0x80000018:  sd      t1,0(t0)
   0x8000001c:  auipc   t0,0x0
   0x80000020:  addi    t0,t0,1020
   0x80000024:  ld      t0,0(t0)
```

随后我们使用**si单步调试**，我们发现会一直运行到0x80200000，也就是**操作系统的入口**处。

那么这一段的指令主要的作用是什么呢？bootloader主要的作用是什么呢？或者更具体一点，我们运行的函数主要有什么呢？为了解决这一问题，我们查阅qemu的具体源码，发现主要的工作如下：

在virt.c函数中，确定定位到0x80200000，因为我们使用的是**RISCV64**

```c
#if defined(TARGET_RISCV32)
# define KERNEL_BOOT_ADDRESS 0x80400000
#else
# define KERNEL_BOOT_ADDRESS 0x80200000
#endif
```

然后就是主要的**riscv_virt_board_init函数**：

```C
/* Initialize SOC */
    object_initialize_child(OBJECT(machine), "soc", &s->soc, sizeof(s->soc),
                            TYPE_RISCV_HART_ARRAY, &error_abort, NULL);
    object_property_set_str(OBJECT(&s->soc), machine->cpu_type, "cpu-type",
                            &error_abort);
    object_property_set_int(OBJECT(&s->soc), smp_cpus, "num-harts",
                            &error_abort);
    object_property_set_bool(OBJECT(&s->soc), true, "realized",
                            &error_abort);

    /* register system main memory (actual RAM) */
    memory_region_init_ram(main_mem, NULL, "riscv_virt_board.ram",
                           machine->ram_size, &error_fatal);
    memory_region_add_subregion(system_memory, memmap[VIRT_DRAM].base,
        main_mem);

    /* create device tree */
    fdt = create_fdt(s, memmap, machine->ram_size, machine->kernel_cmdline);

    /* boot rom */
    memory_region_init_rom(mask_rom, NULL, "riscv_virt_board.mrom",
                           memmap[VIRT_MROM].size, &error_fatal);
    memory_region_add_subregion(system_memory, memmap[VIRT_MROM].base,
                                mask_rom);

    riscv_find_and_load_firmware(machine, BIOS_FILENAME,
                                 memmap[VIRT_DRAM].base);

    if (machine->kernel_filename) {
        uint64_t kernel_entry = riscv_load_kernel(machine->kernel_filename);

        if (machine->initrd_filename) {
            hwaddr start;
            hwaddr end = riscv_load_initrd(machine->initrd_filename,
                                           machine->ram_size, kernel_entry,
                                           &start);
            qemu_fdt_setprop_cell(fdt, "/chosen",
                                  "linux,initrd-start", start);
            qemu_fdt_setprop_cell(fdt, "/chosen", "linux,initrd-end",
                                  end);
        }
    }
```

所以bootloader这一段代码主要的作用就是

- 加载操作系统到内存8020中
- cpu状态的清零
- 初始化SOC
- 初始化ram，然后装载ram
- 找到并且装在firmware也就是操作系统ucore

其中load_kernel函数以及cpu_reset函数如下：

```C
target_ulong riscv_load_kernel(const char *kernel_filename)
{
    uint64_t kernel_entry, kernel_high;

    if (load_elf(kernel_filename, NULL, NULL, NULL,
                 &kernel_entry, NULL, &kernel_high, 0, EM_RISCV, 1, 0) > 0) {
        return kernel_entry;
    }

    if (load_uimage_as(kernel_filename, &kernel_entry, NULL, NULL,
                       NULL, NULL, NULL) > 0) {
        return kernel_entry;
    }

    if (load_image_targphys_as(kernel_filename, KERNEL_BOOT_ADDRESS,
                               ram_size, NULL) > 0) {
        return KERNEL_BOOT_ADDRESS;
    }

    error_report("could not load kernel '%s'", kernel_filename);
    exit(1);
}
```

这一段代码中：**尝试加载ELF格式的内核**: 使用`load_elf`函数尝试加载一个ELF格式的内核文件。如果成功，它将返回内核的入口地址。`load_elf`函数的参数包括：

- 内核文件名
- 一些NULL参数，这些参数在此上下文中可能不重要或不需要
- 内核的入口地址（返回值）
- 内核的最高地址（返回值）
- ELF机器类型为`EM_RISCV`，这表示它应该是一个RISC-V格式的ELF文件

如果`load_elf`成功加载了内核（返回值大于0），函数将返回内核的入口地址。

```C
static void riscv_cpu_reset(CPUState *cs)
{
    RISCVCPU *cpu = RISCV_CPU(cs);
    RISCVCPUClass *mcc = RISCV_CPU_GET_CLASS(cpu);
    CPURISCVState *env = &cpu->env;

    mcc->parent_reset(cs);
#ifndef CONFIG_USER_ONLY
    env->priv = PRV_M;
    env->mstatus &= ~(MSTATUS_MIE | MSTATUS_MPRV);
    env->mcause = 0;
    env->pc = env->resetvec;
#endif
    cs->exception_index = EXCP_NONE;
    env->load_res = -1;
    set_default_nan_mode(1, &env->fp_status);
}
```

这一段代码的主要作用：

1. **获取CPU的引用**:

   - `RISCVCPU *cpu = RISCV_CPU(cs);`: 从传入的`CPUState *cs`参数中获取一个指向`RISCVCPU`结构的指针。
   - `RISCVCPUClass *mcc = RISCV_CPU_GET_CLASS(cpu);`: 获取CPU的类，这通常用于OOP（面向对象编程）风格的结构中。
   - `CPURISCVState *env = &cpu->env;`: 获取指向CPU状态的指针。

2. **调用父类的重置方法**:

   - `mcc->parent_reset(cs);`: 调用父类的重置方法。这是面向对象编程中的一个常见模式，子类在执行自己的重置逻辑之前先调用父类的重置方法。

3. **设置CPU状态**: 在`#ifndef CONFIG_USER_ONLY`预处理器指令内：

   - `env->priv = PRV_M;`: 设置CPU的权限模式为Machine模式。
   - `env->mstatus &= ~(MSTATUS_MIE | MSTATUS_MPRV);`: 清除`mstatus`寄存器中的MIE和MPRV位。
   - `env->mcause = 0;`: 将`mcause`寄存器重置为0。
   - `env->pc = env->resetvec;`: 将程序计数器设置为重置向量的值。

   这些操作只在非用户模式下执行，即当`CONFIG_USER_ONLY`没有定义时。

4. **设置其他状态**:

   - `cs->exception_index = EXCP_NONE;`: 清除异常索引。
   - `env->load_res = -1;`: 设置`load_res`为-1，这可能是一个标志或计数器。
   - `set_default_nan_mode(1, &env->fp_status);`: 设置默认的NaN模式。这与浮点操作有关。

#### (3)运行ucore内核

我们先查看0x80200000处的指令

```
(gdb) x/10i 0x80200000
   0x80200000 <kern_entry>:     auipc   sp,0x3
   0x80200004 <kern_entry+4>:   mv      sp,sp
   0x80200008 <kern_entry+8>:   j       0x8020000c <kern_init>
   0x8020000c <kern_init>:      auipc   a0,0x3
   0x80200010 <kern_init+4>:    addi    a0,a0,-4
   0x80200014 <kern_init+8>:    auipc   a2,0x3
   0x80200018 <kern_init+12>:   addi    a2,a2,-12
   0x8020001c <kern_init+16>:   addi    sp,sp,-16
   0x8020001e <kern_init+18>:   li      a1,0
   0x80200020 <kern_init+20>:   sub     a2,a2,a0
```

随后我们执行continue操作，运行到下一个断点，出现了如下提示

```
Breakpoint 1, kern_entry () at kern/init/entry.S:7
7           la sp, bootstacktop
```

出现了第一个断点，这个时候openSBI已经完全运行起来了

运行结果如下：

```
OpenSBI v0.4 (Jul  2 2019 11:53:53)
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|____/_____|
        | |
        |_|

Platform Name          : QEMU Virt Machine
Platform HART Features : RV64ACDFIMSU
Platform Max HARTs     : 8
Current Hart           : 0
Firmware Base          : 0x80000000
Firmware Size          : 112 KB
Runtime SBI Version    : 0.1

PMP0: 0x0000000080000000-0x000000008001ffff (A)
PMP1: 0x0000000000000000-0xffffffffffffffff (A,R,W,X)
```

随后我们使用gdb在kern_init处增加断点，然后继续运行continue，出现如下结果

```
Breakpoint 2, kern_init () at kern/init/init.c:8
8           memset(edata, 0, end - edata);
```

出现了第二个断点，此时说明已经进入了init.c函数，即将运行打印的功能，我们继续continue

```
(gdb) continue
Continuing.
(THU.CST) os is loading ...
```

完成了打印

### 2.问题解答

加电之后的最初指令在0x1000，这几条指令的 作用是

- 准备完成跳转0x8000
- 相关寄存器状态的设置
- 计算机复位

随后跳转到0x80000000执行bootloader的功能，主要的作用是

- 加载ucore内核到0x80200000
- CPU状态清零
- 初始化ROM以及SOC等关键硬件

### 3.OS原理性拓展

#### (1)bootloader的实现

#### (2)cpu状态的重置

#### (3)计算机复位

#### (3)内存布局以及内存文件加载
