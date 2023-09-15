# Lab1实验报告----中断

[TOC]

### 1.练习一：内核启动的程序入口操作

### 2.练习二：完善中断处理

#### （1）编程实现代码：

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

### 4.拓展练习二：理解上下文切换机制

### 5.拓展练习三：完善异常中断

异常指令的地址一定是和寄存器中存储的值有关系的