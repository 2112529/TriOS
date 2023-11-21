### 练习 1: 加载应用程序并执行（需要编码）

设计实现过程

```c++
//tf->gpr.sp should be user stack top (the value of sp)
tf->gpr.sp = USTACKTOP - 3 * PGSIZE;
//tf->epc should be entry point of user program (the value of sepc)
tf->epc = elf_entry(elf);
//tf->status should be appropriate for user program (the value of sstatus)
tf->status = sstatus | SSTATUS_SPP | SSTATUS_SPIE;
```

问题：从选择占用CPU状态到具体执行程序的第一条指令的全部过程

1. 

### 练习 2: 父进程复制自己的内存空间给子进程（需要编码）

### 练习 3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不 需要编码）

### 扩展练习 Challenge

