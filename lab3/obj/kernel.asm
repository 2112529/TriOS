
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	65260613          	addi	a2,a2,1618 # ffffffffc0211690 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2e2040ef          	jal	ra,ffffffffc0204330 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	30e58593          	addi	a1,a1,782 # ffffffffc0204360 <etext+0x6>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	32650513          	addi	a0,a0,806 # ffffffffc0204380 <etext+0x26>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	0a0000ef          	jal	ra,ffffffffc0200106 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	31d010ef          	jal	ra,ffffffffc0201b86 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	5cc030ef          	jal	ra,ffffffffc020363e <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	426000ef          	jal	ra,ffffffffc020049c <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	003020ef          	jal	ra,ffffffffc020287c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	356000ef          	jal	ra,ffffffffc02003d4 <clock_init>
    //intr_enable();              // enable irq interrupt

    while (1)
        ;
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	39e000ef          	jal	ra,ffffffffc020042a <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	597030ef          	jal	ra,ffffffffc0203e48 <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	563030ef          	jal	ra,ffffffffc0203e48 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3380006f          	j	ffffffffc020042a <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	366000ef          	jal	ra,ffffffffc0200460 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200106:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200108:	00004517          	auipc	a0,0x4
ffffffffc020010c:	2b050513          	addi	a0,a0,688 # ffffffffc02043b8 <etext+0x5e>
void print_kerninfo(void) {
ffffffffc0200110:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200112:	fadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200116:	00000597          	auipc	a1,0x0
ffffffffc020011a:	f2058593          	addi	a1,a1,-224 # ffffffffc0200036 <kern_init>
ffffffffc020011e:	00004517          	auipc	a0,0x4
ffffffffc0200122:	2ba50513          	addi	a0,a0,698 # ffffffffc02043d8 <etext+0x7e>
ffffffffc0200126:	f99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020012a:	00004597          	auipc	a1,0x4
ffffffffc020012e:	23058593          	addi	a1,a1,560 # ffffffffc020435a <etext>
ffffffffc0200132:	00004517          	auipc	a0,0x4
ffffffffc0200136:	2c650513          	addi	a0,a0,710 # ffffffffc02043f8 <etext+0x9e>
ffffffffc020013a:	f85ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013e:	0000a597          	auipc	a1,0xa
ffffffffc0200142:	f0258593          	addi	a1,a1,-254 # ffffffffc020a040 <edata>
ffffffffc0200146:	00004517          	auipc	a0,0x4
ffffffffc020014a:	2d250513          	addi	a0,a0,722 # ffffffffc0204418 <etext+0xbe>
ffffffffc020014e:	f71ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200152:	00011597          	auipc	a1,0x11
ffffffffc0200156:	53e58593          	addi	a1,a1,1342 # ffffffffc0211690 <end>
ffffffffc020015a:	00004517          	auipc	a0,0x4
ffffffffc020015e:	2de50513          	addi	a0,a0,734 # ffffffffc0204438 <etext+0xde>
ffffffffc0200162:	f5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200166:	00012597          	auipc	a1,0x12
ffffffffc020016a:	92958593          	addi	a1,a1,-1751 # ffffffffc0211a8f <end+0x3ff>
ffffffffc020016e:	00000797          	auipc	a5,0x0
ffffffffc0200172:	ec878793          	addi	a5,a5,-312 # ffffffffc0200036 <kern_init>
ffffffffc0200176:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200180:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200184:	95be                	add	a1,a1,a5
ffffffffc0200186:	85a9                	srai	a1,a1,0xa
ffffffffc0200188:	00004517          	auipc	a0,0x4
ffffffffc020018c:	2d050513          	addi	a0,a0,720 # ffffffffc0204458 <etext+0xfe>
}
ffffffffc0200190:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200192:	f2dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200196 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200196:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200198:	00004617          	auipc	a2,0x4
ffffffffc020019c:	1f060613          	addi	a2,a2,496 # ffffffffc0204388 <etext+0x2e>
ffffffffc02001a0:	04e00593          	li	a1,78
ffffffffc02001a4:	00004517          	auipc	a0,0x4
ffffffffc02001a8:	1fc50513          	addi	a0,a0,508 # ffffffffc02043a0 <etext+0x46>
void print_stackframe(void) {
ffffffffc02001ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001ae:	1c6000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001b4:	00004617          	auipc	a2,0x4
ffffffffc02001b8:	3ac60613          	addi	a2,a2,940 # ffffffffc0204560 <commands+0xd8>
ffffffffc02001bc:	00004597          	auipc	a1,0x4
ffffffffc02001c0:	3c458593          	addi	a1,a1,964 # ffffffffc0204580 <commands+0xf8>
ffffffffc02001c4:	00004517          	auipc	a0,0x4
ffffffffc02001c8:	3c450513          	addi	a0,a0,964 # ffffffffc0204588 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ce:	ef1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001d2:	00004617          	auipc	a2,0x4
ffffffffc02001d6:	3c660613          	addi	a2,a2,966 # ffffffffc0204598 <commands+0x110>
ffffffffc02001da:	00004597          	auipc	a1,0x4
ffffffffc02001de:	3e658593          	addi	a1,a1,998 # ffffffffc02045c0 <commands+0x138>
ffffffffc02001e2:	00004517          	auipc	a0,0x4
ffffffffc02001e6:	3a650513          	addi	a0,a0,934 # ffffffffc0204588 <commands+0x100>
ffffffffc02001ea:	ed5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	3e260613          	addi	a2,a2,994 # ffffffffc02045d0 <commands+0x148>
ffffffffc02001f6:	00004597          	auipc	a1,0x4
ffffffffc02001fa:	3fa58593          	addi	a1,a1,1018 # ffffffffc02045f0 <commands+0x168>
ffffffffc02001fe:	00004517          	auipc	a0,0x4
ffffffffc0200202:	38a50513          	addi	a0,a0,906 # ffffffffc0204588 <commands+0x100>
ffffffffc0200206:	eb9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020020a:	60a2                	ld	ra,8(sp)
ffffffffc020020c:	4501                	li	a0,0
ffffffffc020020e:	0141                	addi	sp,sp,16
ffffffffc0200210:	8082                	ret

ffffffffc0200212 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
ffffffffc0200214:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200216:	ef1ff0ef          	jal	ra,ffffffffc0200106 <print_kerninfo>
    return 0;
}
ffffffffc020021a:	60a2                	ld	ra,8(sp)
ffffffffc020021c:	4501                	li	a0,0
ffffffffc020021e:	0141                	addi	sp,sp,16
ffffffffc0200220:	8082                	ret

ffffffffc0200222 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	1141                	addi	sp,sp,-16
ffffffffc0200224:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200226:	f71ff0ef          	jal	ra,ffffffffc0200196 <print_stackframe>
    return 0;
}
ffffffffc020022a:	60a2                	ld	ra,8(sp)
ffffffffc020022c:	4501                	li	a0,0
ffffffffc020022e:	0141                	addi	sp,sp,16
ffffffffc0200230:	8082                	ret

ffffffffc0200232 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200232:	7115                	addi	sp,sp,-224
ffffffffc0200234:	e962                	sd	s8,144(sp)
ffffffffc0200236:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	29850513          	addi	a0,a0,664 # ffffffffc02044d0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200240:	ed86                	sd	ra,216(sp)
ffffffffc0200242:	e9a2                	sd	s0,208(sp)
ffffffffc0200244:	e5a6                	sd	s1,200(sp)
ffffffffc0200246:	e1ca                	sd	s2,192(sp)
ffffffffc0200248:	fd4e                	sd	s3,184(sp)
ffffffffc020024a:	f952                	sd	s4,176(sp)
ffffffffc020024c:	f556                	sd	s5,168(sp)
ffffffffc020024e:	f15a                	sd	s6,160(sp)
ffffffffc0200250:	ed5e                	sd	s7,152(sp)
ffffffffc0200252:	e566                	sd	s9,136(sp)
ffffffffc0200254:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200256:	e69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020025a:	00004517          	auipc	a0,0x4
ffffffffc020025e:	29e50513          	addi	a0,a0,670 # ffffffffc02044f8 <commands+0x70>
ffffffffc0200262:	e5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc0200266:	000c0563          	beqz	s8,ffffffffc0200270 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020026a:	8562                	mv	a0,s8
ffffffffc020026c:	4f2000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc0200270:	00004c97          	auipc	s9,0x4
ffffffffc0200274:	218c8c93          	addi	s9,s9,536 # ffffffffc0204488 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200278:	00006997          	auipc	s3,0x6
ffffffffc020027c:	81098993          	addi	s3,s3,-2032 # ffffffffc0205a88 <default_pmm_manager+0x990>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200280:	00004917          	auipc	s2,0x4
ffffffffc0200284:	2a090913          	addi	s2,s2,672 # ffffffffc0204520 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200288:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020028a:	00004b17          	auipc	s6,0x4
ffffffffc020028e:	29eb0b13          	addi	s6,s6,670 # ffffffffc0204528 <commands+0xa0>
    if (argc == 0) {
ffffffffc0200292:	00004a97          	auipc	s5,0x4
ffffffffc0200296:	2eea8a93          	addi	s5,s5,750 # ffffffffc0204580 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020029a:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc020029c:	854e                	mv	a0,s3
ffffffffc020029e:	737030ef          	jal	ra,ffffffffc02041d4 <readline>
ffffffffc02002a2:	842a                	mv	s0,a0
ffffffffc02002a4:	dd65                	beqz	a0,ffffffffc020029c <kmonitor+0x6a>
ffffffffc02002a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002aa:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ac:	c999                	beqz	a1,ffffffffc02002c2 <kmonitor+0x90>
ffffffffc02002ae:	854a                	mv	a0,s2
ffffffffc02002b0:	062040ef          	jal	ra,ffffffffc0204312 <strchr>
ffffffffc02002b4:	c925                	beqz	a0,ffffffffc0200324 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002b6:	00144583          	lbu	a1,1(s0)
ffffffffc02002ba:	00040023          	sb	zero,0(s0)
ffffffffc02002be:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002c0:	f5fd                	bnez	a1,ffffffffc02002ae <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002c2:	dce9                	beqz	s1,ffffffffc020029c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c4:	6582                	ld	a1,0(sp)
ffffffffc02002c6:	00004d17          	auipc	s10,0x4
ffffffffc02002ca:	1c2d0d13          	addi	s10,s10,450 # ffffffffc0204488 <commands>
    if (argc == 0) {
ffffffffc02002ce:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d2:	0d61                	addi	s10,s10,24
ffffffffc02002d4:	014040ef          	jal	ra,ffffffffc02042e8 <strcmp>
ffffffffc02002d8:	c919                	beqz	a0,ffffffffc02002ee <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002da:	2405                	addiw	s0,s0,1
ffffffffc02002dc:	09740463          	beq	s0,s7,ffffffffc0200364 <kmonitor+0x132>
ffffffffc02002e0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	0d61                	addi	s10,s10,24
ffffffffc02002e8:	000040ef          	jal	ra,ffffffffc02042e8 <strcmp>
ffffffffc02002ec:	f57d                	bnez	a0,ffffffffc02002da <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002ee:	00141793          	slli	a5,s0,0x1
ffffffffc02002f2:	97a2                	add	a5,a5,s0
ffffffffc02002f4:	078e                	slli	a5,a5,0x3
ffffffffc02002f6:	97e6                	add	a5,a5,s9
ffffffffc02002f8:	6b9c                	ld	a5,16(a5)
ffffffffc02002fa:	8662                	mv	a2,s8
ffffffffc02002fc:	002c                	addi	a1,sp,8
ffffffffc02002fe:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200302:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200304:	f8055ce3          	bgez	a0,ffffffffc020029c <kmonitor+0x6a>
}
ffffffffc0200308:	60ee                	ld	ra,216(sp)
ffffffffc020030a:	644e                	ld	s0,208(sp)
ffffffffc020030c:	64ae                	ld	s1,200(sp)
ffffffffc020030e:	690e                	ld	s2,192(sp)
ffffffffc0200310:	79ea                	ld	s3,184(sp)
ffffffffc0200312:	7a4a                	ld	s4,176(sp)
ffffffffc0200314:	7aaa                	ld	s5,168(sp)
ffffffffc0200316:	7b0a                	ld	s6,160(sp)
ffffffffc0200318:	6bea                	ld	s7,152(sp)
ffffffffc020031a:	6c4a                	ld	s8,144(sp)
ffffffffc020031c:	6caa                	ld	s9,136(sp)
ffffffffc020031e:	6d0a                	ld	s10,128(sp)
ffffffffc0200320:	612d                	addi	sp,sp,224
ffffffffc0200322:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200324:	00044783          	lbu	a5,0(s0)
ffffffffc0200328:	dfc9                	beqz	a5,ffffffffc02002c2 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020032a:	03448863          	beq	s1,s4,ffffffffc020035a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020032e:	00349793          	slli	a5,s1,0x3
ffffffffc0200332:	0118                	addi	a4,sp,128
ffffffffc0200334:	97ba                	add	a5,a5,a4
ffffffffc0200336:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200340:	e591                	bnez	a1,ffffffffc020034c <kmonitor+0x11a>
ffffffffc0200342:	b749                	j	ffffffffc02002c4 <kmonitor+0x92>
            buf ++;
ffffffffc0200344:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200346:	00044583          	lbu	a1,0(s0)
ffffffffc020034a:	ddad                	beqz	a1,ffffffffc02002c4 <kmonitor+0x92>
ffffffffc020034c:	854a                	mv	a0,s2
ffffffffc020034e:	7c5030ef          	jal	ra,ffffffffc0204312 <strchr>
ffffffffc0200352:	d96d                	beqz	a0,ffffffffc0200344 <kmonitor+0x112>
ffffffffc0200354:	00044583          	lbu	a1,0(s0)
ffffffffc0200358:	bf91                	j	ffffffffc02002ac <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200362:	b7f1                	j	ffffffffc020032e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	1e250513          	addi	a0,a0,482 # ffffffffc0204548 <commands+0xc0>
ffffffffc020036e:	d51ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc0200372:	b72d                	j	ffffffffc020029c <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00011317          	auipc	t1,0x11
ffffffffc0200378:	0cc30313          	addi	t1,t1,204 # ffffffffc0211440 <is_panic>
ffffffffc020037c:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	02031c63          	bnez	t1,ffffffffc02003c8 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	8432                	mv	s0,a2
ffffffffc0200398:	00011717          	auipc	a4,0x11
ffffffffc020039c:	0af72423          	sw	a5,168(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a4:	85aa                	mv	a1,a0
ffffffffc02003a6:	00004517          	auipc	a0,0x4
ffffffffc02003aa:	25a50513          	addi	a0,a0,602 # ffffffffc0204600 <commands+0x178>
    va_start(ap, fmt);
ffffffffc02003ae:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003b0:	d0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b4:	65a2                	ld	a1,8(sp)
ffffffffc02003b6:	8522                	mv	a0,s0
ffffffffc02003b8:	ce7ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc02003bc:	00005517          	auipc	a0,0x5
ffffffffc02003c0:	22450513          	addi	a0,a0,548 # ffffffffc02055e0 <default_pmm_manager+0x4e8>
ffffffffc02003c4:	cfbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c8:	132000ef          	jal	ra,ffffffffc02004fa <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003cc:	4501                	li	a0,0
ffffffffc02003ce:	e65ff0ef          	jal	ra,ffffffffc0200232 <kmonitor>
ffffffffc02003d2:	bfed                	j	ffffffffc02003cc <__panic+0x58>

ffffffffc02003d4 <clock_init>:
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // enable timer interrupt in sie
    timebase = 1e7 / 100;
ffffffffc02003d4:	67e1                	lui	a5,0x18
ffffffffc02003d6:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02003da:	00011717          	auipc	a4,0x11
ffffffffc02003de:	06f73723          	sd	a5,110(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003e2:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e6:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e8:	953e                	add	a0,a0,a5
ffffffffc02003ea:	4601                	li	a2,0
ffffffffc02003ec:	4881                	li	a7,0
ffffffffc02003ee:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003f2:	02000793          	li	a5,32
ffffffffc02003f6:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003fa:	00004517          	auipc	a0,0x4
ffffffffc02003fe:	22650513          	addi	a0,a0,550 # ffffffffc0204620 <commands+0x198>
    ticks = 0;
ffffffffc0200402:	00011797          	auipc	a5,0x11
ffffffffc0200406:	0607bb23          	sd	zero,118(a5) # ffffffffc0211478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020040a:	cb5ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020040e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020040e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200412:	00011797          	auipc	a5,0x11
ffffffffc0200416:	03678793          	addi	a5,a5,54 # ffffffffc0211448 <timebase>
ffffffffc020041a:	639c                	ld	a5,0(a5)
ffffffffc020041c:	4581                	li	a1,0
ffffffffc020041e:	4601                	li	a2,0
ffffffffc0200420:	953e                	add	a0,a0,a5
ffffffffc0200422:	4881                	li	a7,0
ffffffffc0200424:	00000073          	ecall
ffffffffc0200428:	8082                	ret

ffffffffc020042a <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020042a:	100027f3          	csrr	a5,sstatus
ffffffffc020042e:	8b89                	andi	a5,a5,2
ffffffffc0200430:	0ff57513          	andi	a0,a0,255
ffffffffc0200434:	e799                	bnez	a5,ffffffffc0200442 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200436:	4581                	li	a1,0
ffffffffc0200438:	4601                	li	a2,0
ffffffffc020043a:	4885                	li	a7,1
ffffffffc020043c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200440:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200442:	1101                	addi	sp,sp,-32
ffffffffc0200444:	ec06                	sd	ra,24(sp)
ffffffffc0200446:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200448:	0b2000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc020044c:	6522                	ld	a0,8(sp)
ffffffffc020044e:	4581                	li	a1,0
ffffffffc0200450:	4601                	li	a2,0
ffffffffc0200452:	4885                	li	a7,1
ffffffffc0200454:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200458:	60e2                	ld	ra,24(sp)
ffffffffc020045a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020045c:	0980006f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc0200460 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200460:	100027f3          	csrr	a5,sstatus
ffffffffc0200464:	8b89                	andi	a5,a5,2
ffffffffc0200466:	eb89                	bnez	a5,ffffffffc0200478 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200468:	4501                	li	a0,0
ffffffffc020046a:	4581                	li	a1,0
ffffffffc020046c:	4601                	li	a2,0
ffffffffc020046e:	4889                	li	a7,2
ffffffffc0200470:	00000073          	ecall
ffffffffc0200474:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200476:	8082                	ret
int cons_getc(void) {
ffffffffc0200478:	1101                	addi	sp,sp,-32
ffffffffc020047a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020047c:	07e000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0200480:	4501                	li	a0,0
ffffffffc0200482:	4581                	li	a1,0
ffffffffc0200484:	4601                	li	a2,0
ffffffffc0200486:	4889                	li	a7,2
ffffffffc0200488:	00000073          	ecall
ffffffffc020048c:	2501                	sext.w	a0,a0
ffffffffc020048e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200490:	064000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
}
ffffffffc0200494:	60e2                	ld	ra,24(sp)
ffffffffc0200496:	6522                	ld	a0,8(sp)
ffffffffc0200498:	6105                	addi	sp,sp,32
ffffffffc020049a:	8082                	ret

ffffffffc020049c <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020049c:	8082                	ret

ffffffffc020049e <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020049e:	00253513          	sltiu	a0,a0,2
ffffffffc02004a2:	8082                	ret

ffffffffc02004a4 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004a4:	03800513          	li	a0,56
ffffffffc02004a8:	8082                	ret

ffffffffc02004aa <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004aa:	0000a797          	auipc	a5,0xa
ffffffffc02004ae:	b9678793          	addi	a5,a5,-1130 # ffffffffc020a040 <edata>
ffffffffc02004b2:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004b6:	1141                	addi	sp,sp,-16
ffffffffc02004b8:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ba:	95be                	add	a1,a1,a5
ffffffffc02004bc:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004c0:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c2:	681030ef          	jal	ra,ffffffffc0204342 <memcpy>
    return 0;
}
ffffffffc02004c6:	60a2                	ld	ra,8(sp)
ffffffffc02004c8:	4501                	li	a0,0
ffffffffc02004ca:	0141                	addi	sp,sp,16
ffffffffc02004cc:	8082                	ret

ffffffffc02004ce <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004ce:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d0:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004d4:	0000a517          	auipc	a0,0xa
ffffffffc02004d8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc02004dc:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004de:	00969613          	slli	a2,a3,0x9
ffffffffc02004e2:	85ba                	mv	a1,a4
ffffffffc02004e4:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004e6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e8:	65b030ef          	jal	ra,ffffffffc0204342 <memcpy>
    return 0;
}
ffffffffc02004ec:	60a2                	ld	ra,8(sp)
ffffffffc02004ee:	4501                	li	a0,0
ffffffffc02004f0:	0141                	addi	sp,sp,16
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004fa:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200504:	1141                	addi	sp,sp,-16
ffffffffc0200506:	e022                	sd	s0,0(sp)
ffffffffc0200508:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020050a:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050e:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200510:	11053583          	ld	a1,272(a0)
ffffffffc0200514:	05500613          	li	a2,85
ffffffffc0200518:	c399                	beqz	a5,ffffffffc020051e <pgfault_handler+0x1e>
ffffffffc020051a:	04b00613          	li	a2,75
ffffffffc020051e:	11843703          	ld	a4,280(s0)
ffffffffc0200522:	47bd                	li	a5,15
ffffffffc0200524:	05700693          	li	a3,87
ffffffffc0200528:	00f70463          	beq	a4,a5,ffffffffc0200530 <pgfault_handler+0x30>
ffffffffc020052c:	05200693          	li	a3,82
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	45050513          	addi	a0,a0,1104 # ffffffffc0204980 <commands+0x4f8>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	14c78793          	addi	a5,a5,332 # ffffffffc0211688 <check_mm_struct>
ffffffffc0200544:	6388                	ld	a0,0(a5)
ffffffffc0200546:	c911                	beqz	a0,ffffffffc020055a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	11043603          	ld	a2,272(s0)
ffffffffc020054c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200550:	6402                	ld	s0,0(sp)
ffffffffc0200552:	60a2                	ld	ra,8(sp)
ffffffffc0200554:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200556:	6260306f          	j	ffffffffc0203b7c <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	44660613          	addi	a2,a2,1094 # ffffffffc02049a0 <commands+0x518>
ffffffffc0200562:	07800593          	li	a1,120
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	45250513          	addi	a0,a0,1106 # ffffffffc02049b8 <commands+0x530>
ffffffffc020056e:	e07ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	50a78793          	addi	a5,a5,1290 # ffffffffc0200a80 <__alltraps>
ffffffffc020057e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200582:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200586:	000407b7          	lui	a5,0x40
ffffffffc020058a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	1141                	addi	sp,sp,-16
ffffffffc0200594:	e022                	sd	s0,0(sp)
ffffffffc0200596:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	43850513          	addi	a0,a0,1080 # ffffffffc02049d0 <commands+0x548>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	44050513          	addi	a0,a0,1088 # ffffffffc02049e8 <commands+0x560>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	44a50513          	addi	a0,a0,1098 # ffffffffc0204a00 <commands+0x578>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	45450513          	addi	a0,a0,1108 # ffffffffc0204a18 <commands+0x590>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	45e50513          	addi	a0,a0,1118 # ffffffffc0204a30 <commands+0x5a8>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	46850513          	addi	a0,a0,1128 # ffffffffc0204a48 <commands+0x5c0>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	47250513          	addi	a0,a0,1138 # ffffffffc0204a60 <commands+0x5d8>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	47c50513          	addi	a0,a0,1148 # ffffffffc0204a78 <commands+0x5f0>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	48650513          	addi	a0,a0,1158 # ffffffffc0204a90 <commands+0x608>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	49050513          	addi	a0,a0,1168 # ffffffffc0204aa8 <commands+0x620>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	49a50513          	addi	a0,a0,1178 # ffffffffc0204ac0 <commands+0x638>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	4a450513          	addi	a0,a0,1188 # ffffffffc0204ad8 <commands+0x650>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	4ae50513          	addi	a0,a0,1198 # ffffffffc0204af0 <commands+0x668>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	4b850513          	addi	a0,a0,1208 # ffffffffc0204b08 <commands+0x680>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	4c250513          	addi	a0,a0,1218 # ffffffffc0204b20 <commands+0x698>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	4cc50513          	addi	a0,a0,1228 # ffffffffc0204b38 <commands+0x6b0>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	4d650513          	addi	a0,a0,1238 # ffffffffc0204b50 <commands+0x6c8>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	4e050513          	addi	a0,a0,1248 # ffffffffc0204b68 <commands+0x6e0>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	4ea50513          	addi	a0,a0,1258 # ffffffffc0204b80 <commands+0x6f8>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	4f450513          	addi	a0,a0,1268 # ffffffffc0204b98 <commands+0x710>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	4fe50513          	addi	a0,a0,1278 # ffffffffc0204bb0 <commands+0x728>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	50850513          	addi	a0,a0,1288 # ffffffffc0204bc8 <commands+0x740>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	51250513          	addi	a0,a0,1298 # ffffffffc0204be0 <commands+0x758>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	51c50513          	addi	a0,a0,1308 # ffffffffc0204bf8 <commands+0x770>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	52650513          	addi	a0,a0,1318 # ffffffffc0204c10 <commands+0x788>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	53050513          	addi	a0,a0,1328 # ffffffffc0204c28 <commands+0x7a0>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	53a50513          	addi	a0,a0,1338 # ffffffffc0204c40 <commands+0x7b8>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	54450513          	addi	a0,a0,1348 # ffffffffc0204c58 <commands+0x7d0>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	54e50513          	addi	a0,a0,1358 # ffffffffc0204c70 <commands+0x7e8>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	55850513          	addi	a0,a0,1368 # ffffffffc0204c88 <commands+0x800>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	56250513          	addi	a0,a0,1378 # ffffffffc0204ca0 <commands+0x818>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	56850513          	addi	a0,a0,1384 # ffffffffc0204cb8 <commands+0x830>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020075a:	965ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020075e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	1141                	addi	sp,sp,-16
ffffffffc0200760:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200762:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	00004517          	auipc	a0,0x4
ffffffffc020076a:	56a50513          	addi	a0,a0,1386 # ffffffffc0204cd0 <commands+0x848>
void print_trapframe(struct trapframe *tf) {
ffffffffc020076e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200770:	94fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200774:	8522                	mv	a0,s0
ffffffffc0200776:	e1bff0ef          	jal	ra,ffffffffc0200590 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020077a:	10043583          	ld	a1,256(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	56a50513          	addi	a0,a0,1386 # ffffffffc0204ce8 <commands+0x860>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	57250513          	addi	a0,a0,1394 # ffffffffc0204d00 <commands+0x878>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00004517          	auipc	a0,0x4
ffffffffc02007a2:	57a50513          	addi	a0,a0,1402 # ffffffffc0204d18 <commands+0x890>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	57e50513          	addi	a0,a0,1406 # ffffffffc0204d30 <commands+0x8a8>
}
ffffffffc02007ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007bc:	903ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007c0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	577d                	li	a4,-1
ffffffffc02007c6:	8305                	srli	a4,a4,0x1
ffffffffc02007c8:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007ca:	472d                	li	a4,11
ffffffffc02007cc:	08f76d63          	bltu	a4,a5,ffffffffc0200866 <interrupt_handler+0xa6>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	e6c70713          	addi	a4,a4,-404 # ffffffffc020463c <commands+0x1b4>
ffffffffc02007d8:	078a                	slli	a5,a5,0x2
ffffffffc02007da:	97ba                	add	a5,a5,a4
ffffffffc02007dc:	439c                	lw	a5,0(a5)
ffffffffc02007de:	97ba                	add	a5,a5,a4
ffffffffc02007e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	14e50513          	addi	a0,a0,334 # ffffffffc0204930 <commands+0x4a8>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	12250513          	addi	a0,a0,290 # ffffffffc0204910 <commands+0x488>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	0d650513          	addi	a0,a0,214 # ffffffffc02048d0 <commands+0x448>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	0ea50513          	addi	a0,a0,234 # ffffffffc02048f0 <commands+0x468>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	14e50513          	addi	a0,a0,334 # ffffffffc0204960 <commands+0x4d8>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200822:	bedff0ef          	jal	ra,ffffffffc020040e <clock_set_next_event>
            if(ticks==100){
ffffffffc0200826:	00011797          	auipc	a5,0x11
ffffffffc020082a:	c5278793          	addi	a5,a5,-942 # ffffffffc0211478 <ticks>
ffffffffc020082e:	6394                	ld	a3,0(a5)
ffffffffc0200830:	06400713          	li	a4,100
ffffffffc0200834:	02e68b63          	beq	a3,a4,ffffffffc020086a <interrupt_handler+0xaa>
            else ticks++;
ffffffffc0200838:	639c                	ld	a5,0(a5)
ffffffffc020083a:	00011717          	auipc	a4,0x11
ffffffffc020083e:	c1670713          	addi	a4,a4,-1002 # ffffffffc0211450 <num>
ffffffffc0200842:	0785                	addi	a5,a5,1
ffffffffc0200844:	00011697          	auipc	a3,0x11
ffffffffc0200848:	c2f6ba23          	sd	a5,-972(a3) # ffffffffc0211478 <ticks>
            if(num==10)sbi_shutdown();
ffffffffc020084c:	6318                	ld	a4,0(a4)
ffffffffc020084e:	47a9                	li	a5,10
ffffffffc0200850:	00f71863          	bne	a4,a5,ffffffffc0200860 <interrupt_handler+0xa0>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200854:	4501                	li	a0,0
ffffffffc0200856:	4581                	li	a1,0
ffffffffc0200858:	4601                	li	a2,0
ffffffffc020085a:	48a1                	li	a7,8
ffffffffc020085c:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200860:	60a2                	ld	ra,8(sp)
ffffffffc0200862:	0141                	addi	sp,sp,16
ffffffffc0200864:	8082                	ret
            print_trapframe(tf);
ffffffffc0200866:	ef9ff06f          	j	ffffffffc020075e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020086a:	06400593          	li	a1,100
ffffffffc020086e:	00004517          	auipc	a0,0x4
ffffffffc0200872:	0e250513          	addi	a0,a0,226 # ffffffffc0204950 <commands+0x4c8>
ffffffffc0200876:	849ff0ef          	jal	ra,ffffffffc02000be <cprintf>
                num++;
ffffffffc020087a:	00011717          	auipc	a4,0x11
ffffffffc020087e:	bd670713          	addi	a4,a4,-1066 # ffffffffc0211450 <num>
                ticks=0;
ffffffffc0200882:	00011797          	auipc	a5,0x11
ffffffffc0200886:	be07bb23          	sd	zero,-1034(a5) # ffffffffc0211478 <ticks>
                num++;
ffffffffc020088a:	631c                	ld	a5,0(a4)
ffffffffc020088c:	0785                	addi	a5,a5,1
ffffffffc020088e:	00011697          	auipc	a3,0x11
ffffffffc0200892:	bcf6b123          	sd	a5,-1086(a3) # ffffffffc0211450 <num>
ffffffffc0200896:	bf5d                	j	ffffffffc020084c <interrupt_handler+0x8c>

ffffffffc0200898 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200898:	11853783          	ld	a5,280(a0)
ffffffffc020089c:	473d                	li	a4,15
ffffffffc020089e:	1af76463          	bltu	a4,a5,ffffffffc0200a46 <exception_handler+0x1ae>
ffffffffc02008a2:	00004717          	auipc	a4,0x4
ffffffffc02008a6:	dca70713          	addi	a4,a4,-566 # ffffffffc020466c <commands+0x1e4>
ffffffffc02008aa:	078a                	slli	a5,a5,0x2
ffffffffc02008ac:	97ba                	add	a5,a5,a4
ffffffffc02008ae:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc02008b0:	1101                	addi	sp,sp,-32
ffffffffc02008b2:	e822                	sd	s0,16(sp)
ffffffffc02008b4:	ec06                	sd	ra,24(sp)
ffffffffc02008b6:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc02008b8:	97ba                	add	a5,a5,a4
ffffffffc02008ba:	842a                	mv	s0,a0
ffffffffc02008bc:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc02008be:	00004517          	auipc	a0,0x4
ffffffffc02008c2:	ffa50513          	addi	a0,a0,-6 # ffffffffc02048b8 <commands+0x430>
ffffffffc02008c6:	ff8ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008ca:	8522                	mv	a0,s0
ffffffffc02008cc:	c35ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02008d0:	84aa                	mv	s1,a0
ffffffffc02008d2:	16051c63          	bnez	a0,ffffffffc0200a4a <exception_handler+0x1b2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008d6:	60e2                	ld	ra,24(sp)
ffffffffc02008d8:	6442                	ld	s0,16(sp)
ffffffffc02008da:	64a2                	ld	s1,8(sp)
ffffffffc02008dc:	6105                	addi	sp,sp,32
ffffffffc02008de:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008e0:	00004517          	auipc	a0,0x4
ffffffffc02008e4:	dd050513          	addi	a0,a0,-560 # ffffffffc02046b0 <commands+0x228>
}
ffffffffc02008e8:	6442                	ld	s0,16(sp)
ffffffffc02008ea:	60e2                	ld	ra,24(sp)
ffffffffc02008ec:	64a2                	ld	s1,8(sp)
ffffffffc02008ee:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008f0:	fceff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008f4:	00004517          	auipc	a0,0x4
ffffffffc02008f8:	ddc50513          	addi	a0,a0,-548 # ffffffffc02046d0 <commands+0x248>
ffffffffc02008fc:	b7f5                	j	ffffffffc02008e8 <exception_handler+0x50>
            cprintf("Exception type:Illegal instruction\n");
ffffffffc02008fe:	00004517          	auipc	a0,0x4
ffffffffc0200902:	df250513          	addi	a0,a0,-526 # ffffffffc02046f0 <commands+0x268>
ffffffffc0200906:	fb8ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc020090a:	10843583          	ld	a1,264(s0)
ffffffffc020090e:	00004517          	auipc	a0,0x4
ffffffffc0200912:	e0a50513          	addi	a0,a0,-502 # ffffffffc0204718 <commands+0x290>
ffffffffc0200916:	fa8ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            tf->epc += 4;
ffffffffc020091a:	10843783          	ld	a5,264(s0)
ffffffffc020091e:	0791                	addi	a5,a5,4
ffffffffc0200920:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200924:	bf4d                	j	ffffffffc02008d6 <exception_handler+0x3e>
            cprintf("Exception type: breakpoint\n");
ffffffffc0200926:	00004517          	auipc	a0,0x4
ffffffffc020092a:	e1a50513          	addi	a0,a0,-486 # ffffffffc0204740 <commands+0x2b8>
ffffffffc020092e:	f90ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc0200932:	10843583          	ld	a1,264(s0)
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	e2a50513          	addi	a0,a0,-470 # ffffffffc0204760 <commands+0x2d8>
ffffffffc020093e:	f80ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            tf->epc += 4;
ffffffffc0200942:	10843783          	ld	a5,264(s0)
ffffffffc0200946:	0791                	addi	a5,a5,4
ffffffffc0200948:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc020094c:	b769                	j	ffffffffc02008d6 <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc020094e:	00004517          	auipc	a0,0x4
ffffffffc0200952:	e3250513          	addi	a0,a0,-462 # ffffffffc0204780 <commands+0x2f8>
ffffffffc0200956:	bf49                	j	ffffffffc02008e8 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200958:	00004517          	auipc	a0,0x4
ffffffffc020095c:	e4850513          	addi	a0,a0,-440 # ffffffffc02047a0 <commands+0x318>
ffffffffc0200960:	f5eff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200964:	8522                	mv	a0,s0
ffffffffc0200966:	b9bff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc020096a:	84aa                	mv	s1,a0
ffffffffc020096c:	d52d                	beqz	a0,ffffffffc02008d6 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020096e:	8522                	mv	a0,s0
ffffffffc0200970:	defff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200974:	86a6                	mv	a3,s1
ffffffffc0200976:	00004617          	auipc	a2,0x4
ffffffffc020097a:	e4260613          	addi	a2,a2,-446 # ffffffffc02047b8 <commands+0x330>
ffffffffc020097e:	0e800593          	li	a1,232
ffffffffc0200982:	00004517          	auipc	a0,0x4
ffffffffc0200986:	03650513          	addi	a0,a0,54 # ffffffffc02049b8 <commands+0x530>
ffffffffc020098a:	9ebff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	e4a50513          	addi	a0,a0,-438 # ffffffffc02047d8 <commands+0x350>
ffffffffc0200996:	bf89                	j	ffffffffc02008e8 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200998:	00004517          	auipc	a0,0x4
ffffffffc020099c:	e5850513          	addi	a0,a0,-424 # ffffffffc02047f0 <commands+0x368>
ffffffffc02009a0:	f1eff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009a4:	8522                	mv	a0,s0
ffffffffc02009a6:	b5bff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02009aa:	84aa                	mv	s1,a0
ffffffffc02009ac:	f20505e3          	beqz	a0,ffffffffc02008d6 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b0:	8522                	mv	a0,s0
ffffffffc02009b2:	dadff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009b6:	86a6                	mv	a3,s1
ffffffffc02009b8:	00004617          	auipc	a2,0x4
ffffffffc02009bc:	e0060613          	addi	a2,a2,-512 # ffffffffc02047b8 <commands+0x330>
ffffffffc02009c0:	0f200593          	li	a1,242
ffffffffc02009c4:	00004517          	auipc	a0,0x4
ffffffffc02009c8:	ff450513          	addi	a0,a0,-12 # ffffffffc02049b8 <commands+0x530>
ffffffffc02009cc:	9a9ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc02009d0:	00004517          	auipc	a0,0x4
ffffffffc02009d4:	e3850513          	addi	a0,a0,-456 # ffffffffc0204808 <commands+0x380>
ffffffffc02009d8:	bf01                	j	ffffffffc02008e8 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc02009da:	00004517          	auipc	a0,0x4
ffffffffc02009de:	e4e50513          	addi	a0,a0,-434 # ffffffffc0204828 <commands+0x3a0>
ffffffffc02009e2:	b719                	j	ffffffffc02008e8 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc02009e4:	00004517          	auipc	a0,0x4
ffffffffc02009e8:	e6450513          	addi	a0,a0,-412 # ffffffffc0204848 <commands+0x3c0>
ffffffffc02009ec:	bdf5                	j	ffffffffc02008e8 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc02009ee:	00004517          	auipc	a0,0x4
ffffffffc02009f2:	e7a50513          	addi	a0,a0,-390 # ffffffffc0204868 <commands+0x3e0>
ffffffffc02009f6:	bdcd                	j	ffffffffc02008e8 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc02009f8:	00004517          	auipc	a0,0x4
ffffffffc02009fc:	e9050513          	addi	a0,a0,-368 # ffffffffc0204888 <commands+0x400>
ffffffffc0200a00:	b5e5                	j	ffffffffc02008e8 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a02:	00004517          	auipc	a0,0x4
ffffffffc0200a06:	e9e50513          	addi	a0,a0,-354 # ffffffffc02048a0 <commands+0x418>
ffffffffc0200a0a:	eb4ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a0e:	8522                	mv	a0,s0
ffffffffc0200a10:	af1ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200a14:	84aa                	mv	s1,a0
ffffffffc0200a16:	ec0500e3          	beqz	a0,ffffffffc02008d6 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a1a:	8522                	mv	a0,s0
ffffffffc0200a1c:	d43ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a20:	86a6                	mv	a3,s1
ffffffffc0200a22:	00004617          	auipc	a2,0x4
ffffffffc0200a26:	d9660613          	addi	a2,a2,-618 # ffffffffc02047b8 <commands+0x330>
ffffffffc0200a2a:	10800593          	li	a1,264
ffffffffc0200a2e:	00004517          	auipc	a0,0x4
ffffffffc0200a32:	f8a50513          	addi	a0,a0,-118 # ffffffffc02049b8 <commands+0x530>
ffffffffc0200a36:	93fff0ef          	jal	ra,ffffffffc0200374 <__panic>
}
ffffffffc0200a3a:	6442                	ld	s0,16(sp)
ffffffffc0200a3c:	60e2                	ld	ra,24(sp)
ffffffffc0200a3e:	64a2                	ld	s1,8(sp)
ffffffffc0200a40:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a42:	d1dff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc0200a46:	d19ff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a4a:	8522                	mv	a0,s0
ffffffffc0200a4c:	d13ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a50:	86a6                	mv	a3,s1
ffffffffc0200a52:	00004617          	auipc	a2,0x4
ffffffffc0200a56:	d6660613          	addi	a2,a2,-666 # ffffffffc02047b8 <commands+0x330>
ffffffffc0200a5a:	10f00593          	li	a1,271
ffffffffc0200a5e:	00004517          	auipc	a0,0x4
ffffffffc0200a62:	f5a50513          	addi	a0,a0,-166 # ffffffffc02049b8 <commands+0x530>
ffffffffc0200a66:	90fff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200a6a <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a6a:	11853783          	ld	a5,280(a0)
ffffffffc0200a6e:	0007c463          	bltz	a5,ffffffffc0200a76 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a72:	e27ff06f          	j	ffffffffc0200898 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a76:	d4bff06f          	j	ffffffffc02007c0 <interrupt_handler>
ffffffffc0200a7a:	0000                	unimp
ffffffffc0200a7c:	0000                	unimp
	...

ffffffffc0200a80 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a80:	14011073          	csrw	sscratch,sp
ffffffffc0200a84:	712d                	addi	sp,sp,-288
ffffffffc0200a86:	e406                	sd	ra,8(sp)
ffffffffc0200a88:	ec0e                	sd	gp,24(sp)
ffffffffc0200a8a:	f012                	sd	tp,32(sp)
ffffffffc0200a8c:	f416                	sd	t0,40(sp)
ffffffffc0200a8e:	f81a                	sd	t1,48(sp)
ffffffffc0200a90:	fc1e                	sd	t2,56(sp)
ffffffffc0200a92:	e0a2                	sd	s0,64(sp)
ffffffffc0200a94:	e4a6                	sd	s1,72(sp)
ffffffffc0200a96:	e8aa                	sd	a0,80(sp)
ffffffffc0200a98:	ecae                	sd	a1,88(sp)
ffffffffc0200a9a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a9c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a9e:	f8ba                	sd	a4,112(sp)
ffffffffc0200aa0:	fcbe                	sd	a5,120(sp)
ffffffffc0200aa2:	e142                	sd	a6,128(sp)
ffffffffc0200aa4:	e546                	sd	a7,136(sp)
ffffffffc0200aa6:	e94a                	sd	s2,144(sp)
ffffffffc0200aa8:	ed4e                	sd	s3,152(sp)
ffffffffc0200aaa:	f152                	sd	s4,160(sp)
ffffffffc0200aac:	f556                	sd	s5,168(sp)
ffffffffc0200aae:	f95a                	sd	s6,176(sp)
ffffffffc0200ab0:	fd5e                	sd	s7,184(sp)
ffffffffc0200ab2:	e1e2                	sd	s8,192(sp)
ffffffffc0200ab4:	e5e6                	sd	s9,200(sp)
ffffffffc0200ab6:	e9ea                	sd	s10,208(sp)
ffffffffc0200ab8:	edee                	sd	s11,216(sp)
ffffffffc0200aba:	f1f2                	sd	t3,224(sp)
ffffffffc0200abc:	f5f6                	sd	t4,232(sp)
ffffffffc0200abe:	f9fa                	sd	t5,240(sp)
ffffffffc0200ac0:	fdfe                	sd	t6,248(sp)
ffffffffc0200ac2:	14002473          	csrr	s0,sscratch
ffffffffc0200ac6:	100024f3          	csrr	s1,sstatus
ffffffffc0200aca:	14102973          	csrr	s2,sepc
ffffffffc0200ace:	143029f3          	csrr	s3,stval
ffffffffc0200ad2:	14202a73          	csrr	s4,scause
ffffffffc0200ad6:	e822                	sd	s0,16(sp)
ffffffffc0200ad8:	e226                	sd	s1,256(sp)
ffffffffc0200ada:	e64a                	sd	s2,264(sp)
ffffffffc0200adc:	ea4e                	sd	s3,272(sp)
ffffffffc0200ade:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ae0:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ae2:	f89ff0ef          	jal	ra,ffffffffc0200a6a <trap>

ffffffffc0200ae6 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ae6:	6492                	ld	s1,256(sp)
ffffffffc0200ae8:	6932                	ld	s2,264(sp)
ffffffffc0200aea:	10049073          	csrw	sstatus,s1
ffffffffc0200aee:	14191073          	csrw	sepc,s2
ffffffffc0200af2:	60a2                	ld	ra,8(sp)
ffffffffc0200af4:	61e2                	ld	gp,24(sp)
ffffffffc0200af6:	7202                	ld	tp,32(sp)
ffffffffc0200af8:	72a2                	ld	t0,40(sp)
ffffffffc0200afa:	7342                	ld	t1,48(sp)
ffffffffc0200afc:	73e2                	ld	t2,56(sp)
ffffffffc0200afe:	6406                	ld	s0,64(sp)
ffffffffc0200b00:	64a6                	ld	s1,72(sp)
ffffffffc0200b02:	6546                	ld	a0,80(sp)
ffffffffc0200b04:	65e6                	ld	a1,88(sp)
ffffffffc0200b06:	7606                	ld	a2,96(sp)
ffffffffc0200b08:	76a6                	ld	a3,104(sp)
ffffffffc0200b0a:	7746                	ld	a4,112(sp)
ffffffffc0200b0c:	77e6                	ld	a5,120(sp)
ffffffffc0200b0e:	680a                	ld	a6,128(sp)
ffffffffc0200b10:	68aa                	ld	a7,136(sp)
ffffffffc0200b12:	694a                	ld	s2,144(sp)
ffffffffc0200b14:	69ea                	ld	s3,152(sp)
ffffffffc0200b16:	7a0a                	ld	s4,160(sp)
ffffffffc0200b18:	7aaa                	ld	s5,168(sp)
ffffffffc0200b1a:	7b4a                	ld	s6,176(sp)
ffffffffc0200b1c:	7bea                	ld	s7,184(sp)
ffffffffc0200b1e:	6c0e                	ld	s8,192(sp)
ffffffffc0200b20:	6cae                	ld	s9,200(sp)
ffffffffc0200b22:	6d4e                	ld	s10,208(sp)
ffffffffc0200b24:	6dee                	ld	s11,216(sp)
ffffffffc0200b26:	7e0e                	ld	t3,224(sp)
ffffffffc0200b28:	7eae                	ld	t4,232(sp)
ffffffffc0200b2a:	7f4e                	ld	t5,240(sp)
ffffffffc0200b2c:	7fee                	ld	t6,248(sp)
ffffffffc0200b2e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200b30:	10200073          	sret
	...

ffffffffc0200b40 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b40:	00011797          	auipc	a5,0x11
ffffffffc0200b44:	94078793          	addi	a5,a5,-1728 # ffffffffc0211480 <free_area>
ffffffffc0200b48:	e79c                	sd	a5,8(a5)
ffffffffc0200b4a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b4c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b50:	8082                	ret

ffffffffc0200b52 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b52:	00011517          	auipc	a0,0x11
ffffffffc0200b56:	93e56503          	lwu	a0,-1730(a0) # ffffffffc0211490 <free_area+0x10>
ffffffffc0200b5a:	8082                	ret

ffffffffc0200b5c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b5c:	715d                	addi	sp,sp,-80
ffffffffc0200b5e:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b60:	00011917          	auipc	s2,0x11
ffffffffc0200b64:	92090913          	addi	s2,s2,-1760 # ffffffffc0211480 <free_area>
ffffffffc0200b68:	00893783          	ld	a5,8(s2)
ffffffffc0200b6c:	e486                	sd	ra,72(sp)
ffffffffc0200b6e:	e0a2                	sd	s0,64(sp)
ffffffffc0200b70:	fc26                	sd	s1,56(sp)
ffffffffc0200b72:	f44e                	sd	s3,40(sp)
ffffffffc0200b74:	f052                	sd	s4,32(sp)
ffffffffc0200b76:	ec56                	sd	s5,24(sp)
ffffffffc0200b78:	e85a                	sd	s6,16(sp)
ffffffffc0200b7a:	e45e                	sd	s7,8(sp)
ffffffffc0200b7c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b7e:	31278f63          	beq	a5,s2,ffffffffc0200e9c <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b82:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b86:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b88:	8b05                	andi	a4,a4,1
ffffffffc0200b8a:	30070d63          	beqz	a4,ffffffffc0200ea4 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200b8e:	4401                	li	s0,0
ffffffffc0200b90:	4481                	li	s1,0
ffffffffc0200b92:	a031                	j	ffffffffc0200b9e <default_check+0x42>
ffffffffc0200b94:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200b98:	8b09                	andi	a4,a4,2
ffffffffc0200b9a:	30070563          	beqz	a4,ffffffffc0200ea4 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200b9e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ba2:	679c                	ld	a5,8(a5)
ffffffffc0200ba4:	2485                	addiw	s1,s1,1
ffffffffc0200ba6:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ba8:	ff2796e3          	bne	a5,s2,ffffffffc0200b94 <default_check+0x38>
ffffffffc0200bac:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200bae:	3ef000ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc0200bb2:	75351963          	bne	a0,s3,ffffffffc0201304 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bb6:	4505                	li	a0,1
ffffffffc0200bb8:	317000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200bbc:	8a2a                	mv	s4,a0
ffffffffc0200bbe:	48050363          	beqz	a0,ffffffffc0201044 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bc2:	4505                	li	a0,1
ffffffffc0200bc4:	30b000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200bc8:	89aa                	mv	s3,a0
ffffffffc0200bca:	74050d63          	beqz	a0,ffffffffc0201324 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bce:	4505                	li	a0,1
ffffffffc0200bd0:	2ff000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200bd4:	8aaa                	mv	s5,a0
ffffffffc0200bd6:	4e050763          	beqz	a0,ffffffffc02010c4 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bda:	2f3a0563          	beq	s4,s3,ffffffffc0200ec4 <default_check+0x368>
ffffffffc0200bde:	2eaa0363          	beq	s4,a0,ffffffffc0200ec4 <default_check+0x368>
ffffffffc0200be2:	2ea98163          	beq	s3,a0,ffffffffc0200ec4 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200be6:	000a2783          	lw	a5,0(s4)
ffffffffc0200bea:	2e079d63          	bnez	a5,ffffffffc0200ee4 <default_check+0x388>
ffffffffc0200bee:	0009a783          	lw	a5,0(s3)
ffffffffc0200bf2:	2e079963          	bnez	a5,ffffffffc0200ee4 <default_check+0x388>
ffffffffc0200bf6:	411c                	lw	a5,0(a0)
ffffffffc0200bf8:	2e079663          	bnez	a5,ffffffffc0200ee4 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bfc:	00011797          	auipc	a5,0x11
ffffffffc0200c00:	9a478793          	addi	a5,a5,-1628 # ffffffffc02115a0 <pages>
ffffffffc0200c04:	639c                	ld	a5,0(a5)
ffffffffc0200c06:	00004717          	auipc	a4,0x4
ffffffffc0200c0a:	14270713          	addi	a4,a4,322 # ffffffffc0204d48 <commands+0x8c0>
ffffffffc0200c0e:	630c                	ld	a1,0(a4)
ffffffffc0200c10:	40fa0733          	sub	a4,s4,a5
ffffffffc0200c14:	870d                	srai	a4,a4,0x3
ffffffffc0200c16:	02b70733          	mul	a4,a4,a1
ffffffffc0200c1a:	00005697          	auipc	a3,0x5
ffffffffc0200c1e:	5c668693          	addi	a3,a3,1478 # ffffffffc02061e0 <nbase>
ffffffffc0200c22:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c24:	00011697          	auipc	a3,0x11
ffffffffc0200c28:	83c68693          	addi	a3,a3,-1988 # ffffffffc0211460 <npage>
ffffffffc0200c2c:	6294                	ld	a3,0(a3)
ffffffffc0200c2e:	06b2                	slli	a3,a3,0xc
ffffffffc0200c30:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c32:	0732                	slli	a4,a4,0xc
ffffffffc0200c34:	2cd77863          	bleu	a3,a4,ffffffffc0200f04 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c38:	40f98733          	sub	a4,s3,a5
ffffffffc0200c3c:	870d                	srai	a4,a4,0x3
ffffffffc0200c3e:	02b70733          	mul	a4,a4,a1
ffffffffc0200c42:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c44:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c46:	4ed77f63          	bleu	a3,a4,ffffffffc0201144 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c4a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c4e:	878d                	srai	a5,a5,0x3
ffffffffc0200c50:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c54:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c56:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c58:	34d7f663          	bleu	a3,a5,ffffffffc0200fa4 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200c5c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c5e:	00093c03          	ld	s8,0(s2)
ffffffffc0200c62:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c66:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c6a:	00011797          	auipc	a5,0x11
ffffffffc0200c6e:	8127bf23          	sd	s2,-2018(a5) # ffffffffc0211488 <free_area+0x8>
ffffffffc0200c72:	00011797          	auipc	a5,0x11
ffffffffc0200c76:	8127b723          	sd	s2,-2034(a5) # ffffffffc0211480 <free_area>
    nr_free = 0;
ffffffffc0200c7a:	00011797          	auipc	a5,0x11
ffffffffc0200c7e:	8007ab23          	sw	zero,-2026(a5) # ffffffffc0211490 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c82:	24d000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200c86:	2e051f63          	bnez	a0,ffffffffc0200f84 <default_check+0x428>
    free_page(p0);
ffffffffc0200c8a:	4585                	li	a1,1
ffffffffc0200c8c:	8552                	mv	a0,s4
ffffffffc0200c8e:	2c9000ef          	jal	ra,ffffffffc0201756 <free_pages>
    free_page(p1);
ffffffffc0200c92:	4585                	li	a1,1
ffffffffc0200c94:	854e                	mv	a0,s3
ffffffffc0200c96:	2c1000ef          	jal	ra,ffffffffc0201756 <free_pages>
    free_page(p2);
ffffffffc0200c9a:	4585                	li	a1,1
ffffffffc0200c9c:	8556                	mv	a0,s5
ffffffffc0200c9e:	2b9000ef          	jal	ra,ffffffffc0201756 <free_pages>
    assert(nr_free == 3);
ffffffffc0200ca2:	01092703          	lw	a4,16(s2)
ffffffffc0200ca6:	478d                	li	a5,3
ffffffffc0200ca8:	2af71e63          	bne	a4,a5,ffffffffc0200f64 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cac:	4505                	li	a0,1
ffffffffc0200cae:	221000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200cb2:	89aa                	mv	s3,a0
ffffffffc0200cb4:	28050863          	beqz	a0,ffffffffc0200f44 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cb8:	4505                	li	a0,1
ffffffffc0200cba:	215000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200cbe:	8aaa                	mv	s5,a0
ffffffffc0200cc0:	3e050263          	beqz	a0,ffffffffc02010a4 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cc4:	4505                	li	a0,1
ffffffffc0200cc6:	209000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200cca:	8a2a                	mv	s4,a0
ffffffffc0200ccc:	3a050c63          	beqz	a0,ffffffffc0201084 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200cd0:	4505                	li	a0,1
ffffffffc0200cd2:	1fd000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200cd6:	38051763          	bnez	a0,ffffffffc0201064 <default_check+0x508>
    free_page(p0);
ffffffffc0200cda:	4585                	li	a1,1
ffffffffc0200cdc:	854e                	mv	a0,s3
ffffffffc0200cde:	279000ef          	jal	ra,ffffffffc0201756 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200ce2:	00893783          	ld	a5,8(s2)
ffffffffc0200ce6:	23278f63          	beq	a5,s2,ffffffffc0200f24 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200cea:	4505                	li	a0,1
ffffffffc0200cec:	1e3000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200cf0:	32a99a63          	bne	s3,a0,ffffffffc0201024 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200cf4:	4505                	li	a0,1
ffffffffc0200cf6:	1d9000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200cfa:	30051563          	bnez	a0,ffffffffc0201004 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200cfe:	01092783          	lw	a5,16(s2)
ffffffffc0200d02:	2e079163          	bnez	a5,ffffffffc0200fe4 <default_check+0x488>
    free_page(p);
ffffffffc0200d06:	854e                	mv	a0,s3
ffffffffc0200d08:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d0a:	00010797          	auipc	a5,0x10
ffffffffc0200d0e:	7787bb23          	sd	s8,1910(a5) # ffffffffc0211480 <free_area>
ffffffffc0200d12:	00010797          	auipc	a5,0x10
ffffffffc0200d16:	7777bb23          	sd	s7,1910(a5) # ffffffffc0211488 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200d1a:	00010797          	auipc	a5,0x10
ffffffffc0200d1e:	7767ab23          	sw	s6,1910(a5) # ffffffffc0211490 <free_area+0x10>
    free_page(p);
ffffffffc0200d22:	235000ef          	jal	ra,ffffffffc0201756 <free_pages>
    free_page(p1);
ffffffffc0200d26:	4585                	li	a1,1
ffffffffc0200d28:	8556                	mv	a0,s5
ffffffffc0200d2a:	22d000ef          	jal	ra,ffffffffc0201756 <free_pages>
    free_page(p2);
ffffffffc0200d2e:	4585                	li	a1,1
ffffffffc0200d30:	8552                	mv	a0,s4
ffffffffc0200d32:	225000ef          	jal	ra,ffffffffc0201756 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d36:	4515                	li	a0,5
ffffffffc0200d38:	197000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200d3c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d3e:	28050363          	beqz	a0,ffffffffc0200fc4 <default_check+0x468>
ffffffffc0200d42:	651c                	ld	a5,8(a0)
ffffffffc0200d44:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d46:	8b85                	andi	a5,a5,1
ffffffffc0200d48:	54079e63          	bnez	a5,ffffffffc02012a4 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d4c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d4e:	00093b03          	ld	s6,0(s2)
ffffffffc0200d52:	00893a83          	ld	s5,8(s2)
ffffffffc0200d56:	00010797          	auipc	a5,0x10
ffffffffc0200d5a:	7327b523          	sd	s2,1834(a5) # ffffffffc0211480 <free_area>
ffffffffc0200d5e:	00010797          	auipc	a5,0x10
ffffffffc0200d62:	7327b523          	sd	s2,1834(a5) # ffffffffc0211488 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d66:	169000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200d6a:	50051d63          	bnez	a0,ffffffffc0201284 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d6e:	09098a13          	addi	s4,s3,144
ffffffffc0200d72:	8552                	mv	a0,s4
ffffffffc0200d74:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d76:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200d7a:	00010797          	auipc	a5,0x10
ffffffffc0200d7e:	7007ab23          	sw	zero,1814(a5) # ffffffffc0211490 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d82:	1d5000ef          	jal	ra,ffffffffc0201756 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d86:	4511                	li	a0,4
ffffffffc0200d88:	147000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200d8c:	4c051c63          	bnez	a0,ffffffffc0201264 <default_check+0x708>
ffffffffc0200d90:	0989b783          	ld	a5,152(s3)
ffffffffc0200d94:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d96:	8b85                	andi	a5,a5,1
ffffffffc0200d98:	4a078663          	beqz	a5,ffffffffc0201244 <default_check+0x6e8>
ffffffffc0200d9c:	0a89a703          	lw	a4,168(s3)
ffffffffc0200da0:	478d                	li	a5,3
ffffffffc0200da2:	4af71163          	bne	a4,a5,ffffffffc0201244 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200da6:	450d                	li	a0,3
ffffffffc0200da8:	127000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200dac:	8c2a                	mv	s8,a0
ffffffffc0200dae:	46050b63          	beqz	a0,ffffffffc0201224 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200db2:	4505                	li	a0,1
ffffffffc0200db4:	11b000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200db8:	44051663          	bnez	a0,ffffffffc0201204 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200dbc:	438a1463          	bne	s4,s8,ffffffffc02011e4 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200dc0:	4585                	li	a1,1
ffffffffc0200dc2:	854e                	mv	a0,s3
ffffffffc0200dc4:	193000ef          	jal	ra,ffffffffc0201756 <free_pages>
    free_pages(p1, 3);
ffffffffc0200dc8:	458d                	li	a1,3
ffffffffc0200dca:	8552                	mv	a0,s4
ffffffffc0200dcc:	18b000ef          	jal	ra,ffffffffc0201756 <free_pages>
ffffffffc0200dd0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200dd4:	04898c13          	addi	s8,s3,72
ffffffffc0200dd8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200dda:	8b85                	andi	a5,a5,1
ffffffffc0200ddc:	3e078463          	beqz	a5,ffffffffc02011c4 <default_check+0x668>
ffffffffc0200de0:	0189a703          	lw	a4,24(s3)
ffffffffc0200de4:	4785                	li	a5,1
ffffffffc0200de6:	3cf71f63          	bne	a4,a5,ffffffffc02011c4 <default_check+0x668>
ffffffffc0200dea:	008a3783          	ld	a5,8(s4)
ffffffffc0200dee:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200df0:	8b85                	andi	a5,a5,1
ffffffffc0200df2:	3a078963          	beqz	a5,ffffffffc02011a4 <default_check+0x648>
ffffffffc0200df6:	018a2703          	lw	a4,24(s4)
ffffffffc0200dfa:	478d                	li	a5,3
ffffffffc0200dfc:	3af71463          	bne	a4,a5,ffffffffc02011a4 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200e00:	4505                	li	a0,1
ffffffffc0200e02:	0cd000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200e06:	36a99f63          	bne	s3,a0,ffffffffc0201184 <default_check+0x628>
    free_page(p0);
ffffffffc0200e0a:	4585                	li	a1,1
ffffffffc0200e0c:	14b000ef          	jal	ra,ffffffffc0201756 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e10:	4509                	li	a0,2
ffffffffc0200e12:	0bd000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200e16:	34aa1763          	bne	s4,a0,ffffffffc0201164 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200e1a:	4589                	li	a1,2
ffffffffc0200e1c:	13b000ef          	jal	ra,ffffffffc0201756 <free_pages>
    free_page(p2);
ffffffffc0200e20:	4585                	li	a1,1
ffffffffc0200e22:	8562                	mv	a0,s8
ffffffffc0200e24:	133000ef          	jal	ra,ffffffffc0201756 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e28:	4515                	li	a0,5
ffffffffc0200e2a:	0a5000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200e2e:	89aa                	mv	s3,a0
ffffffffc0200e30:	48050a63          	beqz	a0,ffffffffc02012c4 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200e34:	4505                	li	a0,1
ffffffffc0200e36:	099000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200e3a:	2e051563          	bnez	a0,ffffffffc0201124 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200e3e:	01092783          	lw	a5,16(s2)
ffffffffc0200e42:	2c079163          	bnez	a5,ffffffffc0201104 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e46:	4595                	li	a1,5
ffffffffc0200e48:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e4a:	00010797          	auipc	a5,0x10
ffffffffc0200e4e:	6577a323          	sw	s7,1606(a5) # ffffffffc0211490 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200e52:	00010797          	auipc	a5,0x10
ffffffffc0200e56:	6367b723          	sd	s6,1582(a5) # ffffffffc0211480 <free_area>
ffffffffc0200e5a:	00010797          	auipc	a5,0x10
ffffffffc0200e5e:	6357b723          	sd	s5,1582(a5) # ffffffffc0211488 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e62:	0f5000ef          	jal	ra,ffffffffc0201756 <free_pages>
    return listelm->next;
ffffffffc0200e66:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e6a:	01278963          	beq	a5,s2,ffffffffc0200e7c <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e6e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e72:	679c                	ld	a5,8(a5)
ffffffffc0200e74:	34fd                	addiw	s1,s1,-1
ffffffffc0200e76:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e78:	ff279be3          	bne	a5,s2,ffffffffc0200e6e <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200e7c:	26049463          	bnez	s1,ffffffffc02010e4 <default_check+0x588>
    assert(total == 0);
ffffffffc0200e80:	46041263          	bnez	s0,ffffffffc02012e4 <default_check+0x788>
}
ffffffffc0200e84:	60a6                	ld	ra,72(sp)
ffffffffc0200e86:	6406                	ld	s0,64(sp)
ffffffffc0200e88:	74e2                	ld	s1,56(sp)
ffffffffc0200e8a:	7942                	ld	s2,48(sp)
ffffffffc0200e8c:	79a2                	ld	s3,40(sp)
ffffffffc0200e8e:	7a02                	ld	s4,32(sp)
ffffffffc0200e90:	6ae2                	ld	s5,24(sp)
ffffffffc0200e92:	6b42                	ld	s6,16(sp)
ffffffffc0200e94:	6ba2                	ld	s7,8(sp)
ffffffffc0200e96:	6c02                	ld	s8,0(sp)
ffffffffc0200e98:	6161                	addi	sp,sp,80
ffffffffc0200e9a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e9c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e9e:	4401                	li	s0,0
ffffffffc0200ea0:	4481                	li	s1,0
ffffffffc0200ea2:	b331                	j	ffffffffc0200bae <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200ea4:	00004697          	auipc	a3,0x4
ffffffffc0200ea8:	eac68693          	addi	a3,a3,-340 # ffffffffc0204d50 <commands+0x8c8>
ffffffffc0200eac:	00004617          	auipc	a2,0x4
ffffffffc0200eb0:	eb460613          	addi	a2,a2,-332 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0200eb4:	0f000593          	li	a1,240
ffffffffc0200eb8:	00004517          	auipc	a0,0x4
ffffffffc0200ebc:	ec050513          	addi	a0,a0,-320 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200ec0:	cb4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ec4:	00004697          	auipc	a3,0x4
ffffffffc0200ec8:	f4c68693          	addi	a3,a3,-180 # ffffffffc0204e10 <commands+0x988>
ffffffffc0200ecc:	00004617          	auipc	a2,0x4
ffffffffc0200ed0:	e9460613          	addi	a2,a2,-364 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0200ed4:	0bd00593          	li	a1,189
ffffffffc0200ed8:	00004517          	auipc	a0,0x4
ffffffffc0200edc:	ea050513          	addi	a0,a0,-352 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200ee0:	c94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ee4:	00004697          	auipc	a3,0x4
ffffffffc0200ee8:	f5468693          	addi	a3,a3,-172 # ffffffffc0204e38 <commands+0x9b0>
ffffffffc0200eec:	00004617          	auipc	a2,0x4
ffffffffc0200ef0:	e7460613          	addi	a2,a2,-396 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0200ef4:	0be00593          	li	a1,190
ffffffffc0200ef8:	00004517          	auipc	a0,0x4
ffffffffc0200efc:	e8050513          	addi	a0,a0,-384 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200f00:	c74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f04:	00004697          	auipc	a3,0x4
ffffffffc0200f08:	f7468693          	addi	a3,a3,-140 # ffffffffc0204e78 <commands+0x9f0>
ffffffffc0200f0c:	00004617          	auipc	a2,0x4
ffffffffc0200f10:	e5460613          	addi	a2,a2,-428 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0200f14:	0c000593          	li	a1,192
ffffffffc0200f18:	00004517          	auipc	a0,0x4
ffffffffc0200f1c:	e6050513          	addi	a0,a0,-416 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200f20:	c54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f24:	00004697          	auipc	a3,0x4
ffffffffc0200f28:	fdc68693          	addi	a3,a3,-36 # ffffffffc0204f00 <commands+0xa78>
ffffffffc0200f2c:	00004617          	auipc	a2,0x4
ffffffffc0200f30:	e3460613          	addi	a2,a2,-460 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0200f34:	0d900593          	li	a1,217
ffffffffc0200f38:	00004517          	auipc	a0,0x4
ffffffffc0200f3c:	e4050513          	addi	a0,a0,-448 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200f40:	c34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f44:	00004697          	auipc	a3,0x4
ffffffffc0200f48:	e6c68693          	addi	a3,a3,-404 # ffffffffc0204db0 <commands+0x928>
ffffffffc0200f4c:	00004617          	auipc	a2,0x4
ffffffffc0200f50:	e1460613          	addi	a2,a2,-492 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0200f54:	0d200593          	li	a1,210
ffffffffc0200f58:	00004517          	auipc	a0,0x4
ffffffffc0200f5c:	e2050513          	addi	a0,a0,-480 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200f60:	c14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200f64:	00004697          	auipc	a3,0x4
ffffffffc0200f68:	f8c68693          	addi	a3,a3,-116 # ffffffffc0204ef0 <commands+0xa68>
ffffffffc0200f6c:	00004617          	auipc	a2,0x4
ffffffffc0200f70:	df460613          	addi	a2,a2,-524 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0200f74:	0d000593          	li	a1,208
ffffffffc0200f78:	00004517          	auipc	a0,0x4
ffffffffc0200f7c:	e0050513          	addi	a0,a0,-512 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200f80:	bf4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f84:	00004697          	auipc	a3,0x4
ffffffffc0200f88:	f5468693          	addi	a3,a3,-172 # ffffffffc0204ed8 <commands+0xa50>
ffffffffc0200f8c:	00004617          	auipc	a2,0x4
ffffffffc0200f90:	dd460613          	addi	a2,a2,-556 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0200f94:	0cb00593          	li	a1,203
ffffffffc0200f98:	00004517          	auipc	a0,0x4
ffffffffc0200f9c:	de050513          	addi	a0,a0,-544 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200fa0:	bd4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200fa4:	00004697          	auipc	a3,0x4
ffffffffc0200fa8:	f1468693          	addi	a3,a3,-236 # ffffffffc0204eb8 <commands+0xa30>
ffffffffc0200fac:	00004617          	auipc	a2,0x4
ffffffffc0200fb0:	db460613          	addi	a2,a2,-588 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0200fb4:	0c200593          	li	a1,194
ffffffffc0200fb8:	00004517          	auipc	a0,0x4
ffffffffc0200fbc:	dc050513          	addi	a0,a0,-576 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200fc0:	bb4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200fc4:	00004697          	auipc	a3,0x4
ffffffffc0200fc8:	f8468693          	addi	a3,a3,-124 # ffffffffc0204f48 <commands+0xac0>
ffffffffc0200fcc:	00004617          	auipc	a2,0x4
ffffffffc0200fd0:	d9460613          	addi	a2,a2,-620 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0200fd4:	0f800593          	li	a1,248
ffffffffc0200fd8:	00004517          	auipc	a0,0x4
ffffffffc0200fdc:	da050513          	addi	a0,a0,-608 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200fe0:	b94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200fe4:	00004697          	auipc	a3,0x4
ffffffffc0200fe8:	f5468693          	addi	a3,a3,-172 # ffffffffc0204f38 <commands+0xab0>
ffffffffc0200fec:	00004617          	auipc	a2,0x4
ffffffffc0200ff0:	d7460613          	addi	a2,a2,-652 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0200ff4:	0df00593          	li	a1,223
ffffffffc0200ff8:	00004517          	auipc	a0,0x4
ffffffffc0200ffc:	d8050513          	addi	a0,a0,-640 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201000:	b74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201004:	00004697          	auipc	a3,0x4
ffffffffc0201008:	ed468693          	addi	a3,a3,-300 # ffffffffc0204ed8 <commands+0xa50>
ffffffffc020100c:	00004617          	auipc	a2,0x4
ffffffffc0201010:	d5460613          	addi	a2,a2,-684 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201014:	0dd00593          	li	a1,221
ffffffffc0201018:	00004517          	auipc	a0,0x4
ffffffffc020101c:	d6050513          	addi	a0,a0,-672 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201020:	b54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201024:	00004697          	auipc	a3,0x4
ffffffffc0201028:	ef468693          	addi	a3,a3,-268 # ffffffffc0204f18 <commands+0xa90>
ffffffffc020102c:	00004617          	auipc	a2,0x4
ffffffffc0201030:	d3460613          	addi	a2,a2,-716 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201034:	0dc00593          	li	a1,220
ffffffffc0201038:	00004517          	auipc	a0,0x4
ffffffffc020103c:	d4050513          	addi	a0,a0,-704 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201040:	b34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201044:	00004697          	auipc	a3,0x4
ffffffffc0201048:	d6c68693          	addi	a3,a3,-660 # ffffffffc0204db0 <commands+0x928>
ffffffffc020104c:	00004617          	auipc	a2,0x4
ffffffffc0201050:	d1460613          	addi	a2,a2,-748 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201054:	0b900593          	li	a1,185
ffffffffc0201058:	00004517          	auipc	a0,0x4
ffffffffc020105c:	d2050513          	addi	a0,a0,-736 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201060:	b14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201064:	00004697          	auipc	a3,0x4
ffffffffc0201068:	e7468693          	addi	a3,a3,-396 # ffffffffc0204ed8 <commands+0xa50>
ffffffffc020106c:	00004617          	auipc	a2,0x4
ffffffffc0201070:	cf460613          	addi	a2,a2,-780 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201074:	0d600593          	li	a1,214
ffffffffc0201078:	00004517          	auipc	a0,0x4
ffffffffc020107c:	d0050513          	addi	a0,a0,-768 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201080:	af4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201084:	00004697          	auipc	a3,0x4
ffffffffc0201088:	d6c68693          	addi	a3,a3,-660 # ffffffffc0204df0 <commands+0x968>
ffffffffc020108c:	00004617          	auipc	a2,0x4
ffffffffc0201090:	cd460613          	addi	a2,a2,-812 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201094:	0d400593          	li	a1,212
ffffffffc0201098:	00004517          	auipc	a0,0x4
ffffffffc020109c:	ce050513          	addi	a0,a0,-800 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc02010a0:	ad4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010a4:	00004697          	auipc	a3,0x4
ffffffffc02010a8:	d2c68693          	addi	a3,a3,-724 # ffffffffc0204dd0 <commands+0x948>
ffffffffc02010ac:	00004617          	auipc	a2,0x4
ffffffffc02010b0:	cb460613          	addi	a2,a2,-844 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02010b4:	0d300593          	li	a1,211
ffffffffc02010b8:	00004517          	auipc	a0,0x4
ffffffffc02010bc:	cc050513          	addi	a0,a0,-832 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc02010c0:	ab4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010c4:	00004697          	auipc	a3,0x4
ffffffffc02010c8:	d2c68693          	addi	a3,a3,-724 # ffffffffc0204df0 <commands+0x968>
ffffffffc02010cc:	00004617          	auipc	a2,0x4
ffffffffc02010d0:	c9460613          	addi	a2,a2,-876 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02010d4:	0bb00593          	li	a1,187
ffffffffc02010d8:	00004517          	auipc	a0,0x4
ffffffffc02010dc:	ca050513          	addi	a0,a0,-864 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc02010e0:	a94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc02010e4:	00004697          	auipc	a3,0x4
ffffffffc02010e8:	fb468693          	addi	a3,a3,-76 # ffffffffc0205098 <commands+0xc10>
ffffffffc02010ec:	00004617          	auipc	a2,0x4
ffffffffc02010f0:	c7460613          	addi	a2,a2,-908 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02010f4:	12500593          	li	a1,293
ffffffffc02010f8:	00004517          	auipc	a0,0x4
ffffffffc02010fc:	c8050513          	addi	a0,a0,-896 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201100:	a74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0201104:	00004697          	auipc	a3,0x4
ffffffffc0201108:	e3468693          	addi	a3,a3,-460 # ffffffffc0204f38 <commands+0xab0>
ffffffffc020110c:	00004617          	auipc	a2,0x4
ffffffffc0201110:	c5460613          	addi	a2,a2,-940 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201114:	11a00593          	li	a1,282
ffffffffc0201118:	00004517          	auipc	a0,0x4
ffffffffc020111c:	c6050513          	addi	a0,a0,-928 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201120:	a54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201124:	00004697          	auipc	a3,0x4
ffffffffc0201128:	db468693          	addi	a3,a3,-588 # ffffffffc0204ed8 <commands+0xa50>
ffffffffc020112c:	00004617          	auipc	a2,0x4
ffffffffc0201130:	c3460613          	addi	a2,a2,-972 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201134:	11800593          	li	a1,280
ffffffffc0201138:	00004517          	auipc	a0,0x4
ffffffffc020113c:	c4050513          	addi	a0,a0,-960 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201140:	a34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201144:	00004697          	auipc	a3,0x4
ffffffffc0201148:	d5468693          	addi	a3,a3,-684 # ffffffffc0204e98 <commands+0xa10>
ffffffffc020114c:	00004617          	auipc	a2,0x4
ffffffffc0201150:	c1460613          	addi	a2,a2,-1004 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201154:	0c100593          	li	a1,193
ffffffffc0201158:	00004517          	auipc	a0,0x4
ffffffffc020115c:	c2050513          	addi	a0,a0,-992 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201160:	a14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201164:	00004697          	auipc	a3,0x4
ffffffffc0201168:	ef468693          	addi	a3,a3,-268 # ffffffffc0205058 <commands+0xbd0>
ffffffffc020116c:	00004617          	auipc	a2,0x4
ffffffffc0201170:	bf460613          	addi	a2,a2,-1036 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201174:	11200593          	li	a1,274
ffffffffc0201178:	00004517          	auipc	a0,0x4
ffffffffc020117c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201180:	9f4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201184:	00004697          	auipc	a3,0x4
ffffffffc0201188:	eb468693          	addi	a3,a3,-332 # ffffffffc0205038 <commands+0xbb0>
ffffffffc020118c:	00004617          	auipc	a2,0x4
ffffffffc0201190:	bd460613          	addi	a2,a2,-1068 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201194:	11000593          	li	a1,272
ffffffffc0201198:	00004517          	auipc	a0,0x4
ffffffffc020119c:	be050513          	addi	a0,a0,-1056 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc02011a0:	9d4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02011a4:	00004697          	auipc	a3,0x4
ffffffffc02011a8:	e6c68693          	addi	a3,a3,-404 # ffffffffc0205010 <commands+0xb88>
ffffffffc02011ac:	00004617          	auipc	a2,0x4
ffffffffc02011b0:	bb460613          	addi	a2,a2,-1100 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02011b4:	10e00593          	li	a1,270
ffffffffc02011b8:	00004517          	auipc	a0,0x4
ffffffffc02011bc:	bc050513          	addi	a0,a0,-1088 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc02011c0:	9b4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02011c4:	00004697          	auipc	a3,0x4
ffffffffc02011c8:	e2468693          	addi	a3,a3,-476 # ffffffffc0204fe8 <commands+0xb60>
ffffffffc02011cc:	00004617          	auipc	a2,0x4
ffffffffc02011d0:	b9460613          	addi	a2,a2,-1132 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02011d4:	10d00593          	li	a1,269
ffffffffc02011d8:	00004517          	auipc	a0,0x4
ffffffffc02011dc:	ba050513          	addi	a0,a0,-1120 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc02011e0:	994ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02011e4:	00004697          	auipc	a3,0x4
ffffffffc02011e8:	df468693          	addi	a3,a3,-524 # ffffffffc0204fd8 <commands+0xb50>
ffffffffc02011ec:	00004617          	auipc	a2,0x4
ffffffffc02011f0:	b7460613          	addi	a2,a2,-1164 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02011f4:	10800593          	li	a1,264
ffffffffc02011f8:	00004517          	auipc	a0,0x4
ffffffffc02011fc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201200:	974ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201204:	00004697          	auipc	a3,0x4
ffffffffc0201208:	cd468693          	addi	a3,a3,-812 # ffffffffc0204ed8 <commands+0xa50>
ffffffffc020120c:	00004617          	auipc	a2,0x4
ffffffffc0201210:	b5460613          	addi	a2,a2,-1196 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201214:	10700593          	li	a1,263
ffffffffc0201218:	00004517          	auipc	a0,0x4
ffffffffc020121c:	b6050513          	addi	a0,a0,-1184 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201220:	954ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201224:	00004697          	auipc	a3,0x4
ffffffffc0201228:	d9468693          	addi	a3,a3,-620 # ffffffffc0204fb8 <commands+0xb30>
ffffffffc020122c:	00004617          	auipc	a2,0x4
ffffffffc0201230:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201234:	10600593          	li	a1,262
ffffffffc0201238:	00004517          	auipc	a0,0x4
ffffffffc020123c:	b4050513          	addi	a0,a0,-1216 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201240:	934ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201244:	00004697          	auipc	a3,0x4
ffffffffc0201248:	d4468693          	addi	a3,a3,-700 # ffffffffc0204f88 <commands+0xb00>
ffffffffc020124c:	00004617          	auipc	a2,0x4
ffffffffc0201250:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201254:	10500593          	li	a1,261
ffffffffc0201258:	00004517          	auipc	a0,0x4
ffffffffc020125c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201260:	914ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201264:	00004697          	auipc	a3,0x4
ffffffffc0201268:	d0c68693          	addi	a3,a3,-756 # ffffffffc0204f70 <commands+0xae8>
ffffffffc020126c:	00004617          	auipc	a2,0x4
ffffffffc0201270:	af460613          	addi	a2,a2,-1292 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201274:	10400593          	li	a1,260
ffffffffc0201278:	00004517          	auipc	a0,0x4
ffffffffc020127c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201280:	8f4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201284:	00004697          	auipc	a3,0x4
ffffffffc0201288:	c5468693          	addi	a3,a3,-940 # ffffffffc0204ed8 <commands+0xa50>
ffffffffc020128c:	00004617          	auipc	a2,0x4
ffffffffc0201290:	ad460613          	addi	a2,a2,-1324 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201294:	0fe00593          	li	a1,254
ffffffffc0201298:	00004517          	auipc	a0,0x4
ffffffffc020129c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc02012a0:	8d4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc02012a4:	00004697          	auipc	a3,0x4
ffffffffc02012a8:	cb468693          	addi	a3,a3,-844 # ffffffffc0204f58 <commands+0xad0>
ffffffffc02012ac:	00004617          	auipc	a2,0x4
ffffffffc02012b0:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02012b4:	0f900593          	li	a1,249
ffffffffc02012b8:	00004517          	auipc	a0,0x4
ffffffffc02012bc:	ac050513          	addi	a0,a0,-1344 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc02012c0:	8b4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012c4:	00004697          	auipc	a3,0x4
ffffffffc02012c8:	db468693          	addi	a3,a3,-588 # ffffffffc0205078 <commands+0xbf0>
ffffffffc02012cc:	00004617          	auipc	a2,0x4
ffffffffc02012d0:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02012d4:	11700593          	li	a1,279
ffffffffc02012d8:	00004517          	auipc	a0,0x4
ffffffffc02012dc:	aa050513          	addi	a0,a0,-1376 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc02012e0:	894ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc02012e4:	00004697          	auipc	a3,0x4
ffffffffc02012e8:	dc468693          	addi	a3,a3,-572 # ffffffffc02050a8 <commands+0xc20>
ffffffffc02012ec:	00004617          	auipc	a2,0x4
ffffffffc02012f0:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02012f4:	12600593          	li	a1,294
ffffffffc02012f8:	00004517          	auipc	a0,0x4
ffffffffc02012fc:	a8050513          	addi	a0,a0,-1408 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201300:	874ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201304:	00004697          	auipc	a3,0x4
ffffffffc0201308:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0204d90 <commands+0x908>
ffffffffc020130c:	00004617          	auipc	a2,0x4
ffffffffc0201310:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201314:	0f300593          	li	a1,243
ffffffffc0201318:	00004517          	auipc	a0,0x4
ffffffffc020131c:	a6050513          	addi	a0,a0,-1440 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201320:	854ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201324:	00004697          	auipc	a3,0x4
ffffffffc0201328:	aac68693          	addi	a3,a3,-1364 # ffffffffc0204dd0 <commands+0x948>
ffffffffc020132c:	00004617          	auipc	a2,0x4
ffffffffc0201330:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201334:	0ba00593          	li	a1,186
ffffffffc0201338:	00004517          	auipc	a0,0x4
ffffffffc020133c:	a4050513          	addi	a0,a0,-1472 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0201340:	834ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201344 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201344:	1141                	addi	sp,sp,-16
ffffffffc0201346:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201348:	18058063          	beqz	a1,ffffffffc02014c8 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc020134c:	00359693          	slli	a3,a1,0x3
ffffffffc0201350:	96ae                	add	a3,a3,a1
ffffffffc0201352:	068e                	slli	a3,a3,0x3
ffffffffc0201354:	96aa                	add	a3,a3,a0
ffffffffc0201356:	02d50d63          	beq	a0,a3,ffffffffc0201390 <default_free_pages+0x4c>
ffffffffc020135a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020135c:	8b85                	andi	a5,a5,1
ffffffffc020135e:	14079563          	bnez	a5,ffffffffc02014a8 <default_free_pages+0x164>
ffffffffc0201362:	651c                	ld	a5,8(a0)
ffffffffc0201364:	8385                	srli	a5,a5,0x1
ffffffffc0201366:	8b85                	andi	a5,a5,1
ffffffffc0201368:	14079063          	bnez	a5,ffffffffc02014a8 <default_free_pages+0x164>
ffffffffc020136c:	87aa                	mv	a5,a0
ffffffffc020136e:	a809                	j	ffffffffc0201380 <default_free_pages+0x3c>
ffffffffc0201370:	6798                	ld	a4,8(a5)
ffffffffc0201372:	8b05                	andi	a4,a4,1
ffffffffc0201374:	12071a63          	bnez	a4,ffffffffc02014a8 <default_free_pages+0x164>
ffffffffc0201378:	6798                	ld	a4,8(a5)
ffffffffc020137a:	8b09                	andi	a4,a4,2
ffffffffc020137c:	12071663          	bnez	a4,ffffffffc02014a8 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0201380:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201384:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201388:	04878793          	addi	a5,a5,72
ffffffffc020138c:	fed792e3          	bne	a5,a3,ffffffffc0201370 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201390:	2581                	sext.w	a1,a1
ffffffffc0201392:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201394:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201398:	4789                	li	a5,2
ffffffffc020139a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020139e:	00010697          	auipc	a3,0x10
ffffffffc02013a2:	0e268693          	addi	a3,a3,226 # ffffffffc0211480 <free_area>
ffffffffc02013a6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02013a8:	669c                	ld	a5,8(a3)
ffffffffc02013aa:	9db9                	addw	a1,a1,a4
ffffffffc02013ac:	00010717          	auipc	a4,0x10
ffffffffc02013b0:	0eb72223          	sw	a1,228(a4) # ffffffffc0211490 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02013b4:	08d78f63          	beq	a5,a3,ffffffffc0201452 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc02013b8:	fe078713          	addi	a4,a5,-32
ffffffffc02013bc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02013be:	4801                	li	a6,0
ffffffffc02013c0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02013c4:	00e56a63          	bltu	a0,a4,ffffffffc02013d8 <default_free_pages+0x94>
    return listelm->next;
ffffffffc02013c8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02013ca:	02d70563          	beq	a4,a3,ffffffffc02013f4 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013ce:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013d0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02013d4:	fee57ae3          	bleu	a4,a0,ffffffffc02013c8 <default_free_pages+0x84>
ffffffffc02013d8:	00080663          	beqz	a6,ffffffffc02013e4 <default_free_pages+0xa0>
ffffffffc02013dc:	00010817          	auipc	a6,0x10
ffffffffc02013e0:	0ab83223          	sd	a1,164(a6) # ffffffffc0211480 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013e4:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02013e6:	e390                	sd	a2,0(a5)
ffffffffc02013e8:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02013ea:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013ec:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc02013ee:	02d59163          	bne	a1,a3,ffffffffc0201410 <default_free_pages+0xcc>
ffffffffc02013f2:	a091                	j	ffffffffc0201436 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02013f4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013f6:	f514                	sd	a3,40(a0)
ffffffffc02013f8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013fa:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02013fc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013fe:	00d70563          	beq	a4,a3,ffffffffc0201408 <default_free_pages+0xc4>
ffffffffc0201402:	4805                	li	a6,1
ffffffffc0201404:	87ba                	mv	a5,a4
ffffffffc0201406:	b7e9                	j	ffffffffc02013d0 <default_free_pages+0x8c>
ffffffffc0201408:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020140a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020140c:	02d78163          	beq	a5,a3,ffffffffc020142e <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0201410:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201414:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc0201418:	02081713          	slli	a4,a6,0x20
ffffffffc020141c:	9301                	srli	a4,a4,0x20
ffffffffc020141e:	00371793          	slli	a5,a4,0x3
ffffffffc0201422:	97ba                	add	a5,a5,a4
ffffffffc0201424:	078e                	slli	a5,a5,0x3
ffffffffc0201426:	97b2                	add	a5,a5,a2
ffffffffc0201428:	02f50e63          	beq	a0,a5,ffffffffc0201464 <default_free_pages+0x120>
ffffffffc020142c:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc020142e:	fe078713          	addi	a4,a5,-32
ffffffffc0201432:	00d78d63          	beq	a5,a3,ffffffffc020144c <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0201436:	4d0c                	lw	a1,24(a0)
ffffffffc0201438:	02059613          	slli	a2,a1,0x20
ffffffffc020143c:	9201                	srli	a2,a2,0x20
ffffffffc020143e:	00361693          	slli	a3,a2,0x3
ffffffffc0201442:	96b2                	add	a3,a3,a2
ffffffffc0201444:	068e                	slli	a3,a3,0x3
ffffffffc0201446:	96aa                	add	a3,a3,a0
ffffffffc0201448:	04d70063          	beq	a4,a3,ffffffffc0201488 <default_free_pages+0x144>
}
ffffffffc020144c:	60a2                	ld	ra,8(sp)
ffffffffc020144e:	0141                	addi	sp,sp,16
ffffffffc0201450:	8082                	ret
ffffffffc0201452:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201454:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0201458:	e398                	sd	a4,0(a5)
ffffffffc020145a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020145c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020145e:	f11c                	sd	a5,32(a0)
}
ffffffffc0201460:	0141                	addi	sp,sp,16
ffffffffc0201462:	8082                	ret
            p->property += base->property;
ffffffffc0201464:	4d1c                	lw	a5,24(a0)
ffffffffc0201466:	0107883b          	addw	a6,a5,a6
ffffffffc020146a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020146e:	57f5                	li	a5,-3
ffffffffc0201470:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201474:	02053803          	ld	a6,32(a0)
ffffffffc0201478:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc020147a:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020147c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201480:	659c                	ld	a5,8(a1)
ffffffffc0201482:	01073023          	sd	a6,0(a4)
ffffffffc0201486:	b765                	j	ffffffffc020142e <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0201488:	ff87a703          	lw	a4,-8(a5)
ffffffffc020148c:	fe878693          	addi	a3,a5,-24
ffffffffc0201490:	9db9                	addw	a1,a1,a4
ffffffffc0201492:	cd0c                	sw	a1,24(a0)
ffffffffc0201494:	5775                	li	a4,-3
ffffffffc0201496:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020149a:	6398                	ld	a4,0(a5)
ffffffffc020149c:	679c                	ld	a5,8(a5)
}
ffffffffc020149e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02014a0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02014a2:	e398                	sd	a4,0(a5)
ffffffffc02014a4:	0141                	addi	sp,sp,16
ffffffffc02014a6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02014a8:	00004697          	auipc	a3,0x4
ffffffffc02014ac:	c1068693          	addi	a3,a3,-1008 # ffffffffc02050b8 <commands+0xc30>
ffffffffc02014b0:	00004617          	auipc	a2,0x4
ffffffffc02014b4:	8b060613          	addi	a2,a2,-1872 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02014b8:	08300593          	li	a1,131
ffffffffc02014bc:	00004517          	auipc	a0,0x4
ffffffffc02014c0:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc02014c4:	eb1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc02014c8:	00004697          	auipc	a3,0x4
ffffffffc02014cc:	c1868693          	addi	a3,a3,-1000 # ffffffffc02050e0 <commands+0xc58>
ffffffffc02014d0:	00004617          	auipc	a2,0x4
ffffffffc02014d4:	89060613          	addi	a2,a2,-1904 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02014d8:	08000593          	li	a1,128
ffffffffc02014dc:	00004517          	auipc	a0,0x4
ffffffffc02014e0:	89c50513          	addi	a0,a0,-1892 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc02014e4:	e91fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02014e8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02014e8:	cd51                	beqz	a0,ffffffffc0201584 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc02014ea:	00010597          	auipc	a1,0x10
ffffffffc02014ee:	f9658593          	addi	a1,a1,-106 # ffffffffc0211480 <free_area>
ffffffffc02014f2:	0105a803          	lw	a6,16(a1)
ffffffffc02014f6:	862a                	mv	a2,a0
ffffffffc02014f8:	02081793          	slli	a5,a6,0x20
ffffffffc02014fc:	9381                	srli	a5,a5,0x20
ffffffffc02014fe:	00a7ee63          	bltu	a5,a0,ffffffffc020151a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201502:	87ae                	mv	a5,a1
ffffffffc0201504:	a801                	j	ffffffffc0201514 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201506:	ff87a703          	lw	a4,-8(a5)
ffffffffc020150a:	02071693          	slli	a3,a4,0x20
ffffffffc020150e:	9281                	srli	a3,a3,0x20
ffffffffc0201510:	00c6f763          	bleu	a2,a3,ffffffffc020151e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201514:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201516:	feb798e3          	bne	a5,a1,ffffffffc0201506 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020151a:	4501                	li	a0,0
}
ffffffffc020151c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020151e:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc0201522:	dd6d                	beqz	a0,ffffffffc020151c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201524:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201528:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020152c:	00060e1b          	sext.w	t3,a2
ffffffffc0201530:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201534:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201538:	02d67b63          	bleu	a3,a2,ffffffffc020156e <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc020153c:	00361693          	slli	a3,a2,0x3
ffffffffc0201540:	96b2                	add	a3,a3,a2
ffffffffc0201542:	068e                	slli	a3,a3,0x3
ffffffffc0201544:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201546:	41c7073b          	subw	a4,a4,t3
ffffffffc020154a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020154c:	00868613          	addi	a2,a3,8
ffffffffc0201550:	4709                	li	a4,2
ffffffffc0201552:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201556:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020155a:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020155e:	0105a803          	lw	a6,16(a1)
ffffffffc0201562:	e310                	sd	a2,0(a4)
ffffffffc0201564:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201568:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020156a:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020156e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201572:	00010717          	auipc	a4,0x10
ffffffffc0201576:	f1072f23          	sw	a6,-226(a4) # ffffffffc0211490 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020157a:	5775                	li	a4,-3
ffffffffc020157c:	17a1                	addi	a5,a5,-24
ffffffffc020157e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201582:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201584:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201586:	00004697          	auipc	a3,0x4
ffffffffc020158a:	b5a68693          	addi	a3,a3,-1190 # ffffffffc02050e0 <commands+0xc58>
ffffffffc020158e:	00003617          	auipc	a2,0x3
ffffffffc0201592:	7d260613          	addi	a2,a2,2002 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201596:	06200593          	li	a1,98
ffffffffc020159a:	00003517          	auipc	a0,0x3
ffffffffc020159e:	7de50513          	addi	a0,a0,2014 # ffffffffc0204d78 <commands+0x8f0>
default_alloc_pages(size_t n) {
ffffffffc02015a2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015a4:	dd1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015a8 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02015a8:	1141                	addi	sp,sp,-16
ffffffffc02015aa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015ac:	c1fd                	beqz	a1,ffffffffc0201692 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02015ae:	00359693          	slli	a3,a1,0x3
ffffffffc02015b2:	96ae                	add	a3,a3,a1
ffffffffc02015b4:	068e                	slli	a3,a3,0x3
ffffffffc02015b6:	96aa                	add	a3,a3,a0
ffffffffc02015b8:	02d50463          	beq	a0,a3,ffffffffc02015e0 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02015bc:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02015be:	87aa                	mv	a5,a0
ffffffffc02015c0:	8b05                	andi	a4,a4,1
ffffffffc02015c2:	e709                	bnez	a4,ffffffffc02015cc <default_init_memmap+0x24>
ffffffffc02015c4:	a07d                	j	ffffffffc0201672 <default_init_memmap+0xca>
ffffffffc02015c6:	6798                	ld	a4,8(a5)
ffffffffc02015c8:	8b05                	andi	a4,a4,1
ffffffffc02015ca:	c745                	beqz	a4,ffffffffc0201672 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02015cc:	0007ac23          	sw	zero,24(a5)
ffffffffc02015d0:	0007b423          	sd	zero,8(a5)
ffffffffc02015d4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015d8:	04878793          	addi	a5,a5,72
ffffffffc02015dc:	fed795e3          	bne	a5,a3,ffffffffc02015c6 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc02015e0:	2581                	sext.w	a1,a1
ffffffffc02015e2:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015e4:	4789                	li	a5,2
ffffffffc02015e6:	00850713          	addi	a4,a0,8
ffffffffc02015ea:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02015ee:	00010697          	auipc	a3,0x10
ffffffffc02015f2:	e9268693          	addi	a3,a3,-366 # ffffffffc0211480 <free_area>
ffffffffc02015f6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015f8:	669c                	ld	a5,8(a3)
ffffffffc02015fa:	9db9                	addw	a1,a1,a4
ffffffffc02015fc:	00010717          	auipc	a4,0x10
ffffffffc0201600:	e8b72a23          	sw	a1,-364(a4) # ffffffffc0211490 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201604:	04d78a63          	beq	a5,a3,ffffffffc0201658 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0201608:	fe078713          	addi	a4,a5,-32
ffffffffc020160c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020160e:	4801                	li	a6,0
ffffffffc0201610:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201614:	00e56a63          	bltu	a0,a4,ffffffffc0201628 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0201618:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020161a:	02d70563          	beq	a4,a3,ffffffffc0201644 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020161e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201620:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201624:	fee57ae3          	bleu	a4,a0,ffffffffc0201618 <default_init_memmap+0x70>
ffffffffc0201628:	00080663          	beqz	a6,ffffffffc0201634 <default_init_memmap+0x8c>
ffffffffc020162c:	00010717          	auipc	a4,0x10
ffffffffc0201630:	e4b73a23          	sd	a1,-428(a4) # ffffffffc0211480 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201634:	6398                	ld	a4,0(a5)
}
ffffffffc0201636:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201638:	e390                	sd	a2,0(a5)
ffffffffc020163a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020163c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020163e:	f118                	sd	a4,32(a0)
ffffffffc0201640:	0141                	addi	sp,sp,16
ffffffffc0201642:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201644:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201646:	f514                	sd	a3,40(a0)
ffffffffc0201648:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020164a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020164c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020164e:	00d70e63          	beq	a4,a3,ffffffffc020166a <default_init_memmap+0xc2>
ffffffffc0201652:	4805                	li	a6,1
ffffffffc0201654:	87ba                	mv	a5,a4
ffffffffc0201656:	b7e9                	j	ffffffffc0201620 <default_init_memmap+0x78>
}
ffffffffc0201658:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020165a:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020165e:	e398                	sd	a4,0(a5)
ffffffffc0201660:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201662:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201664:	f11c                	sd	a5,32(a0)
}
ffffffffc0201666:	0141                	addi	sp,sp,16
ffffffffc0201668:	8082                	ret
ffffffffc020166a:	60a2                	ld	ra,8(sp)
ffffffffc020166c:	e290                	sd	a2,0(a3)
ffffffffc020166e:	0141                	addi	sp,sp,16
ffffffffc0201670:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201672:	00004697          	auipc	a3,0x4
ffffffffc0201676:	a7668693          	addi	a3,a3,-1418 # ffffffffc02050e8 <commands+0xc60>
ffffffffc020167a:	00003617          	auipc	a2,0x3
ffffffffc020167e:	6e660613          	addi	a2,a2,1766 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0201682:	04900593          	li	a1,73
ffffffffc0201686:	00003517          	auipc	a0,0x3
ffffffffc020168a:	6f250513          	addi	a0,a0,1778 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc020168e:	ce7fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201692:	00004697          	auipc	a3,0x4
ffffffffc0201696:	a4e68693          	addi	a3,a3,-1458 # ffffffffc02050e0 <commands+0xc58>
ffffffffc020169a:	00003617          	auipc	a2,0x3
ffffffffc020169e:	6c660613          	addi	a2,a2,1734 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02016a2:	04600593          	li	a1,70
ffffffffc02016a6:	00003517          	auipc	a0,0x3
ffffffffc02016aa:	6d250513          	addi	a0,a0,1746 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc02016ae:	cc7fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02016b2 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02016b2:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02016b4:	00004617          	auipc	a2,0x4
ffffffffc02016b8:	b0c60613          	addi	a2,a2,-1268 # ffffffffc02051c0 <default_pmm_manager+0xc8>
ffffffffc02016bc:	06500593          	li	a1,101
ffffffffc02016c0:	00004517          	auipc	a0,0x4
ffffffffc02016c4:	b2050513          	addi	a0,a0,-1248 # ffffffffc02051e0 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02016c8:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02016ca:	cabfe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02016ce <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02016ce:	715d                	addi	sp,sp,-80
ffffffffc02016d0:	e0a2                	sd	s0,64(sp)
ffffffffc02016d2:	fc26                	sd	s1,56(sp)
ffffffffc02016d4:	f84a                	sd	s2,48(sp)
ffffffffc02016d6:	f44e                	sd	s3,40(sp)
ffffffffc02016d8:	f052                	sd	s4,32(sp)
ffffffffc02016da:	ec56                	sd	s5,24(sp)
ffffffffc02016dc:	e486                	sd	ra,72(sp)
ffffffffc02016de:	842a                	mv	s0,a0
ffffffffc02016e0:	00010497          	auipc	s1,0x10
ffffffffc02016e4:	ea848493          	addi	s1,s1,-344 # ffffffffc0211588 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016e8:	4985                	li	s3,1
ffffffffc02016ea:	00010a17          	auipc	s4,0x10
ffffffffc02016ee:	d86a0a13          	addi	s4,s4,-634 # ffffffffc0211470 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02016f2:	0005091b          	sext.w	s2,a0
ffffffffc02016f6:	00010a97          	auipc	s5,0x10
ffffffffc02016fa:	f92a8a93          	addi	s5,s5,-110 # ffffffffc0211688 <check_mm_struct>
ffffffffc02016fe:	a00d                	j	ffffffffc0201720 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201700:	609c                	ld	a5,0(s1)
ffffffffc0201702:	6f9c                	ld	a5,24(a5)
ffffffffc0201704:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201706:	4601                	li	a2,0
ffffffffc0201708:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020170a:	ed0d                	bnez	a0,ffffffffc0201744 <alloc_pages+0x76>
ffffffffc020170c:	0289ec63          	bltu	s3,s0,ffffffffc0201744 <alloc_pages+0x76>
ffffffffc0201710:	000a2783          	lw	a5,0(s4)
ffffffffc0201714:	2781                	sext.w	a5,a5
ffffffffc0201716:	c79d                	beqz	a5,ffffffffc0201744 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201718:	000ab503          	ld	a0,0(s5)
ffffffffc020171c:	021010ef          	jal	ra,ffffffffc0202f3c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201720:	100027f3          	csrr	a5,sstatus
ffffffffc0201724:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201726:	8522                	mv	a0,s0
ffffffffc0201728:	dfe1                	beqz	a5,ffffffffc0201700 <alloc_pages+0x32>
        intr_disable();
ffffffffc020172a:	dd1fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc020172e:	609c                	ld	a5,0(s1)
ffffffffc0201730:	8522                	mv	a0,s0
ffffffffc0201732:	6f9c                	ld	a5,24(a5)
ffffffffc0201734:	9782                	jalr	a5
ffffffffc0201736:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201738:	dbdfe0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc020173c:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc020173e:	4601                	li	a2,0
ffffffffc0201740:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201742:	d569                	beqz	a0,ffffffffc020170c <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201744:	60a6                	ld	ra,72(sp)
ffffffffc0201746:	6406                	ld	s0,64(sp)
ffffffffc0201748:	74e2                	ld	s1,56(sp)
ffffffffc020174a:	7942                	ld	s2,48(sp)
ffffffffc020174c:	79a2                	ld	s3,40(sp)
ffffffffc020174e:	7a02                	ld	s4,32(sp)
ffffffffc0201750:	6ae2                	ld	s5,24(sp)
ffffffffc0201752:	6161                	addi	sp,sp,80
ffffffffc0201754:	8082                	ret

ffffffffc0201756 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201756:	100027f3          	csrr	a5,sstatus
ffffffffc020175a:	8b89                	andi	a5,a5,2
ffffffffc020175c:	eb89                	bnez	a5,ffffffffc020176e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020175e:	00010797          	auipc	a5,0x10
ffffffffc0201762:	e2a78793          	addi	a5,a5,-470 # ffffffffc0211588 <pmm_manager>
ffffffffc0201766:	639c                	ld	a5,0(a5)
ffffffffc0201768:	0207b303          	ld	t1,32(a5)
ffffffffc020176c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020176e:	1101                	addi	sp,sp,-32
ffffffffc0201770:	ec06                	sd	ra,24(sp)
ffffffffc0201772:	e822                	sd	s0,16(sp)
ffffffffc0201774:	e426                	sd	s1,8(sp)
ffffffffc0201776:	842a                	mv	s0,a0
ffffffffc0201778:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020177a:	d81fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020177e:	00010797          	auipc	a5,0x10
ffffffffc0201782:	e0a78793          	addi	a5,a5,-502 # ffffffffc0211588 <pmm_manager>
ffffffffc0201786:	639c                	ld	a5,0(a5)
ffffffffc0201788:	85a6                	mv	a1,s1
ffffffffc020178a:	8522                	mv	a0,s0
ffffffffc020178c:	739c                	ld	a5,32(a5)
ffffffffc020178e:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201790:	6442                	ld	s0,16(sp)
ffffffffc0201792:	60e2                	ld	ra,24(sp)
ffffffffc0201794:	64a2                	ld	s1,8(sp)
ffffffffc0201796:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201798:	d5dfe06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc020179c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020179c:	100027f3          	csrr	a5,sstatus
ffffffffc02017a0:	8b89                	andi	a5,a5,2
ffffffffc02017a2:	eb89                	bnez	a5,ffffffffc02017b4 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02017a4:	00010797          	auipc	a5,0x10
ffffffffc02017a8:	de478793          	addi	a5,a5,-540 # ffffffffc0211588 <pmm_manager>
ffffffffc02017ac:	639c                	ld	a5,0(a5)
ffffffffc02017ae:	0287b303          	ld	t1,40(a5)
ffffffffc02017b2:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02017b4:	1141                	addi	sp,sp,-16
ffffffffc02017b6:	e406                	sd	ra,8(sp)
ffffffffc02017b8:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02017ba:	d41fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02017be:	00010797          	auipc	a5,0x10
ffffffffc02017c2:	dca78793          	addi	a5,a5,-566 # ffffffffc0211588 <pmm_manager>
ffffffffc02017c6:	639c                	ld	a5,0(a5)
ffffffffc02017c8:	779c                	ld	a5,40(a5)
ffffffffc02017ca:	9782                	jalr	a5
ffffffffc02017cc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02017ce:	d27fe0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02017d2:	8522                	mv	a0,s0
ffffffffc02017d4:	60a2                	ld	ra,8(sp)
ffffffffc02017d6:	6402                	ld	s0,0(sp)
ffffffffc02017d8:	0141                	addi	sp,sp,16
ffffffffc02017da:	8082                	ret

ffffffffc02017dc <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017dc:	715d                	addi	sp,sp,-80
ffffffffc02017de:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02017e0:	01e5d493          	srli	s1,a1,0x1e
ffffffffc02017e4:	1ff4f493          	andi	s1,s1,511
ffffffffc02017e8:	048e                	slli	s1,s1,0x3
ffffffffc02017ea:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017ec:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017ee:	f84a                	sd	s2,48(sp)
ffffffffc02017f0:	f44e                	sd	s3,40(sp)
ffffffffc02017f2:	f052                	sd	s4,32(sp)
ffffffffc02017f4:	e486                	sd	ra,72(sp)
ffffffffc02017f6:	e0a2                	sd	s0,64(sp)
ffffffffc02017f8:	ec56                	sd	s5,24(sp)
ffffffffc02017fa:	e85a                	sd	s6,16(sp)
ffffffffc02017fc:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017fe:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201802:	892e                	mv	s2,a1
ffffffffc0201804:	8a32                	mv	s4,a2
ffffffffc0201806:	00010997          	auipc	s3,0x10
ffffffffc020180a:	c5a98993          	addi	s3,s3,-934 # ffffffffc0211460 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc020180e:	e3c9                	bnez	a5,ffffffffc0201890 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201810:	16060163          	beqz	a2,ffffffffc0201972 <get_pte+0x196>
ffffffffc0201814:	4505                	li	a0,1
ffffffffc0201816:	eb9ff0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc020181a:	842a                	mv	s0,a0
ffffffffc020181c:	14050b63          	beqz	a0,ffffffffc0201972 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201820:	00010b97          	auipc	s7,0x10
ffffffffc0201824:	d80b8b93          	addi	s7,s7,-640 # ffffffffc02115a0 <pages>
ffffffffc0201828:	000bb503          	ld	a0,0(s7)
ffffffffc020182c:	00003797          	auipc	a5,0x3
ffffffffc0201830:	51c78793          	addi	a5,a5,1308 # ffffffffc0204d48 <commands+0x8c0>
ffffffffc0201834:	0007bb03          	ld	s6,0(a5)
ffffffffc0201838:	40a40533          	sub	a0,s0,a0
ffffffffc020183c:	850d                	srai	a0,a0,0x3
ffffffffc020183e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201842:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201844:	00010997          	auipc	s3,0x10
ffffffffc0201848:	c1c98993          	addi	s3,s3,-996 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020184c:	00080ab7          	lui	s5,0x80
ffffffffc0201850:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201854:	c01c                	sw	a5,0(s0)
ffffffffc0201856:	57fd                	li	a5,-1
ffffffffc0201858:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020185a:	9556                	add	a0,a0,s5
ffffffffc020185c:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020185e:	0532                	slli	a0,a0,0xc
ffffffffc0201860:	16e7f063          	bleu	a4,a5,ffffffffc02019c0 <get_pte+0x1e4>
ffffffffc0201864:	00010797          	auipc	a5,0x10
ffffffffc0201868:	d2c78793          	addi	a5,a5,-724 # ffffffffc0211590 <va_pa_offset>
ffffffffc020186c:	639c                	ld	a5,0(a5)
ffffffffc020186e:	6605                	lui	a2,0x1
ffffffffc0201870:	4581                	li	a1,0
ffffffffc0201872:	953e                	add	a0,a0,a5
ffffffffc0201874:	2bd020ef          	jal	ra,ffffffffc0204330 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201878:	000bb683          	ld	a3,0(s7)
ffffffffc020187c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201880:	868d                	srai	a3,a3,0x3
ffffffffc0201882:	036686b3          	mul	a3,a3,s6
ffffffffc0201886:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201888:	06aa                	slli	a3,a3,0xa
ffffffffc020188a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020188e:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201890:	77fd                	lui	a5,0xfffff
ffffffffc0201892:	068a                	slli	a3,a3,0x2
ffffffffc0201894:	0009b703          	ld	a4,0(s3)
ffffffffc0201898:	8efd                	and	a3,a3,a5
ffffffffc020189a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020189e:	0ce7fc63          	bleu	a4,a5,ffffffffc0201976 <get_pte+0x19a>
ffffffffc02018a2:	00010a97          	auipc	s5,0x10
ffffffffc02018a6:	ceea8a93          	addi	s5,s5,-786 # ffffffffc0211590 <va_pa_offset>
ffffffffc02018aa:	000ab403          	ld	s0,0(s5)
ffffffffc02018ae:	01595793          	srli	a5,s2,0x15
ffffffffc02018b2:	1ff7f793          	andi	a5,a5,511
ffffffffc02018b6:	96a2                	add	a3,a3,s0
ffffffffc02018b8:	00379413          	slli	s0,a5,0x3
ffffffffc02018bc:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc02018be:	6014                	ld	a3,0(s0)
ffffffffc02018c0:	0016f793          	andi	a5,a3,1
ffffffffc02018c4:	ebbd                	bnez	a5,ffffffffc020193a <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02018c6:	0a0a0663          	beqz	s4,ffffffffc0201972 <get_pte+0x196>
ffffffffc02018ca:	4505                	li	a0,1
ffffffffc02018cc:	e03ff0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc02018d0:	84aa                	mv	s1,a0
ffffffffc02018d2:	c145                	beqz	a0,ffffffffc0201972 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018d4:	00010b97          	auipc	s7,0x10
ffffffffc02018d8:	cccb8b93          	addi	s7,s7,-820 # ffffffffc02115a0 <pages>
ffffffffc02018dc:	000bb503          	ld	a0,0(s7)
ffffffffc02018e0:	00003797          	auipc	a5,0x3
ffffffffc02018e4:	46878793          	addi	a5,a5,1128 # ffffffffc0204d48 <commands+0x8c0>
ffffffffc02018e8:	0007bb03          	ld	s6,0(a5)
ffffffffc02018ec:	40a48533          	sub	a0,s1,a0
ffffffffc02018f0:	850d                	srai	a0,a0,0x3
ffffffffc02018f2:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018f6:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018f8:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018fc:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201900:	c09c                	sw	a5,0(s1)
ffffffffc0201902:	57fd                	li	a5,-1
ffffffffc0201904:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201906:	9552                	add	a0,a0,s4
ffffffffc0201908:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020190a:	0532                	slli	a0,a0,0xc
ffffffffc020190c:	08e7fd63          	bleu	a4,a5,ffffffffc02019a6 <get_pte+0x1ca>
ffffffffc0201910:	000ab783          	ld	a5,0(s5)
ffffffffc0201914:	6605                	lui	a2,0x1
ffffffffc0201916:	4581                	li	a1,0
ffffffffc0201918:	953e                	add	a0,a0,a5
ffffffffc020191a:	217020ef          	jal	ra,ffffffffc0204330 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020191e:	000bb683          	ld	a3,0(s7)
ffffffffc0201922:	40d486b3          	sub	a3,s1,a3
ffffffffc0201926:	868d                	srai	a3,a3,0x3
ffffffffc0201928:	036686b3          	mul	a3,a3,s6
ffffffffc020192c:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020192e:	06aa                	slli	a3,a3,0xa
ffffffffc0201930:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201934:	e014                	sd	a3,0(s0)
ffffffffc0201936:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020193a:	068a                	slli	a3,a3,0x2
ffffffffc020193c:	757d                	lui	a0,0xfffff
ffffffffc020193e:	8ee9                	and	a3,a3,a0
ffffffffc0201940:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201944:	04e7f563          	bleu	a4,a5,ffffffffc020198e <get_pte+0x1b2>
ffffffffc0201948:	000ab503          	ld	a0,0(s5)
ffffffffc020194c:	00c95793          	srli	a5,s2,0xc
ffffffffc0201950:	1ff7f793          	andi	a5,a5,511
ffffffffc0201954:	96aa                	add	a3,a3,a0
ffffffffc0201956:	00379513          	slli	a0,a5,0x3
ffffffffc020195a:	9536                	add	a0,a0,a3
}
ffffffffc020195c:	60a6                	ld	ra,72(sp)
ffffffffc020195e:	6406                	ld	s0,64(sp)
ffffffffc0201960:	74e2                	ld	s1,56(sp)
ffffffffc0201962:	7942                	ld	s2,48(sp)
ffffffffc0201964:	79a2                	ld	s3,40(sp)
ffffffffc0201966:	7a02                	ld	s4,32(sp)
ffffffffc0201968:	6ae2                	ld	s5,24(sp)
ffffffffc020196a:	6b42                	ld	s6,16(sp)
ffffffffc020196c:	6ba2                	ld	s7,8(sp)
ffffffffc020196e:	6161                	addi	sp,sp,80
ffffffffc0201970:	8082                	ret
            return NULL;
ffffffffc0201972:	4501                	li	a0,0
ffffffffc0201974:	b7e5                	j	ffffffffc020195c <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201976:	00003617          	auipc	a2,0x3
ffffffffc020197a:	7d260613          	addi	a2,a2,2002 # ffffffffc0205148 <default_pmm_manager+0x50>
ffffffffc020197e:	10200593          	li	a1,258
ffffffffc0201982:	00003517          	auipc	a0,0x3
ffffffffc0201986:	7ee50513          	addi	a0,a0,2030 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc020198a:	9ebfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020198e:	00003617          	auipc	a2,0x3
ffffffffc0201992:	7ba60613          	addi	a2,a2,1978 # ffffffffc0205148 <default_pmm_manager+0x50>
ffffffffc0201996:	10f00593          	li	a1,271
ffffffffc020199a:	00003517          	auipc	a0,0x3
ffffffffc020199e:	7d650513          	addi	a0,a0,2006 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02019a2:	9d3fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02019a6:	86aa                	mv	a3,a0
ffffffffc02019a8:	00003617          	auipc	a2,0x3
ffffffffc02019ac:	7a060613          	addi	a2,a2,1952 # ffffffffc0205148 <default_pmm_manager+0x50>
ffffffffc02019b0:	10b00593          	li	a1,267
ffffffffc02019b4:	00003517          	auipc	a0,0x3
ffffffffc02019b8:	7bc50513          	addi	a0,a0,1980 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02019bc:	9b9fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02019c0:	86aa                	mv	a3,a0
ffffffffc02019c2:	00003617          	auipc	a2,0x3
ffffffffc02019c6:	78660613          	addi	a2,a2,1926 # ffffffffc0205148 <default_pmm_manager+0x50>
ffffffffc02019ca:	0ff00593          	li	a1,255
ffffffffc02019ce:	00003517          	auipc	a0,0x3
ffffffffc02019d2:	7a250513          	addi	a0,a0,1954 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02019d6:	99ffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02019da <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019da:	1141                	addi	sp,sp,-16
ffffffffc02019dc:	e022                	sd	s0,0(sp)
ffffffffc02019de:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019e0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019e2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019e4:	df9ff0ef          	jal	ra,ffffffffc02017dc <get_pte>
    if (ptep_store != NULL) {
ffffffffc02019e8:	c011                	beqz	s0,ffffffffc02019ec <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02019ea:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019ec:	c521                	beqz	a0,ffffffffc0201a34 <get_page+0x5a>
ffffffffc02019ee:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02019f0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019f2:	0017f713          	andi	a4,a5,1
ffffffffc02019f6:	e709                	bnez	a4,ffffffffc0201a00 <get_page+0x26>
}
ffffffffc02019f8:	60a2                	ld	ra,8(sp)
ffffffffc02019fa:	6402                	ld	s0,0(sp)
ffffffffc02019fc:	0141                	addi	sp,sp,16
ffffffffc02019fe:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a00:	00010717          	auipc	a4,0x10
ffffffffc0201a04:	a6070713          	addi	a4,a4,-1440 # ffffffffc0211460 <npage>
ffffffffc0201a08:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a0a:	078a                	slli	a5,a5,0x2
ffffffffc0201a0c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a0e:	02e7f863          	bleu	a4,a5,ffffffffc0201a3e <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a12:	fff80537          	lui	a0,0xfff80
ffffffffc0201a16:	97aa                	add	a5,a5,a0
ffffffffc0201a18:	00010697          	auipc	a3,0x10
ffffffffc0201a1c:	b8868693          	addi	a3,a3,-1144 # ffffffffc02115a0 <pages>
ffffffffc0201a20:	6288                	ld	a0,0(a3)
ffffffffc0201a22:	60a2                	ld	ra,8(sp)
ffffffffc0201a24:	6402                	ld	s0,0(sp)
ffffffffc0201a26:	00379713          	slli	a4,a5,0x3
ffffffffc0201a2a:	97ba                	add	a5,a5,a4
ffffffffc0201a2c:	078e                	slli	a5,a5,0x3
ffffffffc0201a2e:	953e                	add	a0,a0,a5
ffffffffc0201a30:	0141                	addi	sp,sp,16
ffffffffc0201a32:	8082                	ret
ffffffffc0201a34:	60a2                	ld	ra,8(sp)
ffffffffc0201a36:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201a38:	4501                	li	a0,0
}
ffffffffc0201a3a:	0141                	addi	sp,sp,16
ffffffffc0201a3c:	8082                	ret
ffffffffc0201a3e:	c75ff0ef          	jal	ra,ffffffffc02016b2 <pa2page.part.4>

ffffffffc0201a42 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a42:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a44:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a46:	e406                	sd	ra,8(sp)
ffffffffc0201a48:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a4a:	d93ff0ef          	jal	ra,ffffffffc02017dc <get_pte>
    if (ptep != NULL) {
ffffffffc0201a4e:	c511                	beqz	a0,ffffffffc0201a5a <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201a50:	611c                	ld	a5,0(a0)
ffffffffc0201a52:	842a                	mv	s0,a0
ffffffffc0201a54:	0017f713          	andi	a4,a5,1
ffffffffc0201a58:	e709                	bnez	a4,ffffffffc0201a62 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201a5a:	60a2                	ld	ra,8(sp)
ffffffffc0201a5c:	6402                	ld	s0,0(sp)
ffffffffc0201a5e:	0141                	addi	sp,sp,16
ffffffffc0201a60:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a62:	00010717          	auipc	a4,0x10
ffffffffc0201a66:	9fe70713          	addi	a4,a4,-1538 # ffffffffc0211460 <npage>
ffffffffc0201a6a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a6c:	078a                	slli	a5,a5,0x2
ffffffffc0201a6e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a70:	04e7f063          	bleu	a4,a5,ffffffffc0201ab0 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a74:	fff80737          	lui	a4,0xfff80
ffffffffc0201a78:	97ba                	add	a5,a5,a4
ffffffffc0201a7a:	00010717          	auipc	a4,0x10
ffffffffc0201a7e:	b2670713          	addi	a4,a4,-1242 # ffffffffc02115a0 <pages>
ffffffffc0201a82:	6308                	ld	a0,0(a4)
ffffffffc0201a84:	00379713          	slli	a4,a5,0x3
ffffffffc0201a88:	97ba                	add	a5,a5,a4
ffffffffc0201a8a:	078e                	slli	a5,a5,0x3
ffffffffc0201a8c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201a8e:	411c                	lw	a5,0(a0)
ffffffffc0201a90:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a94:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201a96:	cb09                	beqz	a4,ffffffffc0201aa8 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a98:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a9c:	12000073          	sfence.vma
}
ffffffffc0201aa0:	60a2                	ld	ra,8(sp)
ffffffffc0201aa2:	6402                	ld	s0,0(sp)
ffffffffc0201aa4:	0141                	addi	sp,sp,16
ffffffffc0201aa6:	8082                	ret
            free_page(page);
ffffffffc0201aa8:	4585                	li	a1,1
ffffffffc0201aaa:	cadff0ef          	jal	ra,ffffffffc0201756 <free_pages>
ffffffffc0201aae:	b7ed                	j	ffffffffc0201a98 <page_remove+0x56>
ffffffffc0201ab0:	c03ff0ef          	jal	ra,ffffffffc02016b2 <pa2page.part.4>

ffffffffc0201ab4 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201ab4:	7179                	addi	sp,sp,-48
ffffffffc0201ab6:	87b2                	mv	a5,a2
ffffffffc0201ab8:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201aba:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201abc:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201abe:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201ac0:	ec26                	sd	s1,24(sp)
ffffffffc0201ac2:	f406                	sd	ra,40(sp)
ffffffffc0201ac4:	e84a                	sd	s2,16(sp)
ffffffffc0201ac6:	e44e                	sd	s3,8(sp)
ffffffffc0201ac8:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201aca:	d13ff0ef          	jal	ra,ffffffffc02017dc <get_pte>
    if (ptep == NULL) {
ffffffffc0201ace:	c945                	beqz	a0,ffffffffc0201b7e <page_insert+0xca>
    page->ref += 1;
ffffffffc0201ad0:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201ad2:	611c                	ld	a5,0(a0)
ffffffffc0201ad4:	892a                	mv	s2,a0
ffffffffc0201ad6:	0016871b          	addiw	a4,a3,1
ffffffffc0201ada:	c018                	sw	a4,0(s0)
ffffffffc0201adc:	0017f713          	andi	a4,a5,1
ffffffffc0201ae0:	e339                	bnez	a4,ffffffffc0201b26 <page_insert+0x72>
ffffffffc0201ae2:	00010797          	auipc	a5,0x10
ffffffffc0201ae6:	abe78793          	addi	a5,a5,-1346 # ffffffffc02115a0 <pages>
ffffffffc0201aea:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201aec:	00003717          	auipc	a4,0x3
ffffffffc0201af0:	25c70713          	addi	a4,a4,604 # ffffffffc0204d48 <commands+0x8c0>
ffffffffc0201af4:	40f407b3          	sub	a5,s0,a5
ffffffffc0201af8:	6300                	ld	s0,0(a4)
ffffffffc0201afa:	878d                	srai	a5,a5,0x3
ffffffffc0201afc:	000806b7          	lui	a3,0x80
ffffffffc0201b00:	028787b3          	mul	a5,a5,s0
ffffffffc0201b04:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201b06:	07aa                	slli	a5,a5,0xa
ffffffffc0201b08:	8fc5                	or	a5,a5,s1
ffffffffc0201b0a:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201b0e:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b12:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201b16:	4501                	li	a0,0
}
ffffffffc0201b18:	70a2                	ld	ra,40(sp)
ffffffffc0201b1a:	7402                	ld	s0,32(sp)
ffffffffc0201b1c:	64e2                	ld	s1,24(sp)
ffffffffc0201b1e:	6942                	ld	s2,16(sp)
ffffffffc0201b20:	69a2                	ld	s3,8(sp)
ffffffffc0201b22:	6145                	addi	sp,sp,48
ffffffffc0201b24:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201b26:	00010717          	auipc	a4,0x10
ffffffffc0201b2a:	93a70713          	addi	a4,a4,-1734 # ffffffffc0211460 <npage>
ffffffffc0201b2e:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201b30:	00279513          	slli	a0,a5,0x2
ffffffffc0201b34:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b36:	04e57663          	bleu	a4,a0,ffffffffc0201b82 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b3a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201b3e:	953e                	add	a0,a0,a5
ffffffffc0201b40:	00010997          	auipc	s3,0x10
ffffffffc0201b44:	a6098993          	addi	s3,s3,-1440 # ffffffffc02115a0 <pages>
ffffffffc0201b48:	0009b783          	ld	a5,0(s3)
ffffffffc0201b4c:	00351713          	slli	a4,a0,0x3
ffffffffc0201b50:	953a                	add	a0,a0,a4
ffffffffc0201b52:	050e                	slli	a0,a0,0x3
ffffffffc0201b54:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201b56:	00a40e63          	beq	s0,a0,ffffffffc0201b72 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201b5a:	411c                	lw	a5,0(a0)
ffffffffc0201b5c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201b60:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201b62:	cb11                	beqz	a4,ffffffffc0201b76 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201b64:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b68:	12000073          	sfence.vma
ffffffffc0201b6c:	0009b783          	ld	a5,0(s3)
ffffffffc0201b70:	bfb5                	j	ffffffffc0201aec <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201b72:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201b74:	bfa5                	j	ffffffffc0201aec <page_insert+0x38>
            free_page(page);
ffffffffc0201b76:	4585                	li	a1,1
ffffffffc0201b78:	bdfff0ef          	jal	ra,ffffffffc0201756 <free_pages>
ffffffffc0201b7c:	b7e5                	j	ffffffffc0201b64 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201b7e:	5571                	li	a0,-4
ffffffffc0201b80:	bf61                	j	ffffffffc0201b18 <page_insert+0x64>
ffffffffc0201b82:	b31ff0ef          	jal	ra,ffffffffc02016b2 <pa2page.part.4>

ffffffffc0201b86 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b86:	00003797          	auipc	a5,0x3
ffffffffc0201b8a:	57278793          	addi	a5,a5,1394 # ffffffffc02050f8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b8e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b90:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b92:	00003517          	auipc	a0,0x3
ffffffffc0201b96:	67650513          	addi	a0,a0,1654 # ffffffffc0205208 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201b9a:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b9c:	00010717          	auipc	a4,0x10
ffffffffc0201ba0:	9ef73623          	sd	a5,-1556(a4) # ffffffffc0211588 <pmm_manager>
void pmm_init(void) {
ffffffffc0201ba4:	e8a2                	sd	s0,80(sp)
ffffffffc0201ba6:	e4a6                	sd	s1,72(sp)
ffffffffc0201ba8:	e0ca                	sd	s2,64(sp)
ffffffffc0201baa:	fc4e                	sd	s3,56(sp)
ffffffffc0201bac:	f852                	sd	s4,48(sp)
ffffffffc0201bae:	f456                	sd	s5,40(sp)
ffffffffc0201bb0:	f05a                	sd	s6,32(sp)
ffffffffc0201bb2:	ec5e                	sd	s7,24(sp)
ffffffffc0201bb4:	e862                	sd	s8,16(sp)
ffffffffc0201bb6:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201bb8:	00010417          	auipc	s0,0x10
ffffffffc0201bbc:	9d040413          	addi	s0,s0,-1584 # ffffffffc0211588 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201bc0:	cfefe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201bc4:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201bc6:	49c5                	li	s3,17
ffffffffc0201bc8:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201bcc:	679c                	ld	a5,8(a5)
ffffffffc0201bce:	00010497          	auipc	s1,0x10
ffffffffc0201bd2:	89248493          	addi	s1,s1,-1902 # ffffffffc0211460 <npage>
ffffffffc0201bd6:	00010917          	auipc	s2,0x10
ffffffffc0201bda:	9ca90913          	addi	s2,s2,-1590 # ffffffffc02115a0 <pages>
ffffffffc0201bde:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201be0:	57f5                	li	a5,-3
ffffffffc0201be2:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201be4:	07e006b7          	lui	a3,0x7e00
ffffffffc0201be8:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201bec:	015a1593          	slli	a1,s4,0x15
ffffffffc0201bf0:	00003517          	auipc	a0,0x3
ffffffffc0201bf4:	63050513          	addi	a0,a0,1584 # ffffffffc0205220 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201bf8:	00010717          	auipc	a4,0x10
ffffffffc0201bfc:	98f73c23          	sd	a5,-1640(a4) # ffffffffc0211590 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201c00:	cbefe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201c04:	00003517          	auipc	a0,0x3
ffffffffc0201c08:	64c50513          	addi	a0,a0,1612 # ffffffffc0205250 <default_pmm_manager+0x158>
ffffffffc0201c0c:	cb2fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201c10:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201c14:	16fd                	addi	a3,a3,-1
ffffffffc0201c16:	015a1613          	slli	a2,s4,0x15
ffffffffc0201c1a:	07e005b7          	lui	a1,0x7e00
ffffffffc0201c1e:	00003517          	auipc	a0,0x3
ffffffffc0201c22:	64a50513          	addi	a0,a0,1610 # ffffffffc0205268 <default_pmm_manager+0x170>
ffffffffc0201c26:	c98fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201c2a:	777d                	lui	a4,0xfffff
ffffffffc0201c2c:	00011797          	auipc	a5,0x11
ffffffffc0201c30:	a6378793          	addi	a5,a5,-1437 # ffffffffc021268f <end+0xfff>
ffffffffc0201c34:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201c36:	00088737          	lui	a4,0x88
ffffffffc0201c3a:	00010697          	auipc	a3,0x10
ffffffffc0201c3e:	82e6b323          	sd	a4,-2010(a3) # ffffffffc0211460 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201c42:	00010717          	auipc	a4,0x10
ffffffffc0201c46:	94f73f23          	sd	a5,-1698(a4) # ffffffffc02115a0 <pages>
ffffffffc0201c4a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c4c:	4701                	li	a4,0
ffffffffc0201c4e:	4585                	li	a1,1
ffffffffc0201c50:	fff80637          	lui	a2,0xfff80
ffffffffc0201c54:	a019                	j	ffffffffc0201c5a <pmm_init+0xd4>
ffffffffc0201c56:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201c5a:	97b6                	add	a5,a5,a3
ffffffffc0201c5c:	07a1                	addi	a5,a5,8
ffffffffc0201c5e:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c62:	609c                	ld	a5,0(s1)
ffffffffc0201c64:	0705                	addi	a4,a4,1
ffffffffc0201c66:	04868693          	addi	a3,a3,72
ffffffffc0201c6a:	00c78533          	add	a0,a5,a2
ffffffffc0201c6e:	fea764e3          	bltu	a4,a0,ffffffffc0201c56 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c72:	00093503          	ld	a0,0(s2)
ffffffffc0201c76:	00379693          	slli	a3,a5,0x3
ffffffffc0201c7a:	96be                	add	a3,a3,a5
ffffffffc0201c7c:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c80:	972a                	add	a4,a4,a0
ffffffffc0201c82:	068e                	slli	a3,a3,0x3
ffffffffc0201c84:	96ba                	add	a3,a3,a4
ffffffffc0201c86:	c0200737          	lui	a4,0xc0200
ffffffffc0201c8a:	58e6ea63          	bltu	a3,a4,ffffffffc020221e <pmm_init+0x698>
ffffffffc0201c8e:	00010997          	auipc	s3,0x10
ffffffffc0201c92:	90298993          	addi	s3,s3,-1790 # ffffffffc0211590 <va_pa_offset>
ffffffffc0201c96:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c9a:	45c5                	li	a1,17
ffffffffc0201c9c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c9e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201ca0:	44b6ef63          	bltu	a3,a1,ffffffffc02020fe <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201ca4:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201ca6:	0000f417          	auipc	s0,0xf
ffffffffc0201caa:	7b240413          	addi	s0,s0,1970 # ffffffffc0211458 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201cae:	7b9c                	ld	a5,48(a5)
ffffffffc0201cb0:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201cb2:	00003517          	auipc	a0,0x3
ffffffffc0201cb6:	60650513          	addi	a0,a0,1542 # ffffffffc02052b8 <default_pmm_manager+0x1c0>
ffffffffc0201cba:	c04fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201cbe:	00007697          	auipc	a3,0x7
ffffffffc0201cc2:	34268693          	addi	a3,a3,834 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201cc6:	0000f797          	auipc	a5,0xf
ffffffffc0201cca:	78d7b923          	sd	a3,1938(a5) # ffffffffc0211458 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201cce:	c02007b7          	lui	a5,0xc0200
ffffffffc0201cd2:	0ef6ece3          	bltu	a3,a5,ffffffffc02025ca <pmm_init+0xa44>
ffffffffc0201cd6:	0009b783          	ld	a5,0(s3)
ffffffffc0201cda:	8e9d                	sub	a3,a3,a5
ffffffffc0201cdc:	00010797          	auipc	a5,0x10
ffffffffc0201ce0:	8ad7be23          	sd	a3,-1860(a5) # ffffffffc0211598 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201ce4:	ab9ff0ef          	jal	ra,ffffffffc020179c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201ce8:	6098                	ld	a4,0(s1)
ffffffffc0201cea:	c80007b7          	lui	a5,0xc8000
ffffffffc0201cee:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201cf0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201cf2:	0ae7ece3          	bltu	a5,a4,ffffffffc02025aa <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201cf6:	6008                	ld	a0,0(s0)
ffffffffc0201cf8:	4c050363          	beqz	a0,ffffffffc02021be <pmm_init+0x638>
ffffffffc0201cfc:	6785                	lui	a5,0x1
ffffffffc0201cfe:	17fd                	addi	a5,a5,-1
ffffffffc0201d00:	8fe9                	and	a5,a5,a0
ffffffffc0201d02:	2781                	sext.w	a5,a5
ffffffffc0201d04:	4a079d63          	bnez	a5,ffffffffc02021be <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201d08:	4601                	li	a2,0
ffffffffc0201d0a:	4581                	li	a1,0
ffffffffc0201d0c:	ccfff0ef          	jal	ra,ffffffffc02019da <get_page>
ffffffffc0201d10:	4c051763          	bnez	a0,ffffffffc02021de <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201d14:	4505                	li	a0,1
ffffffffc0201d16:	9b9ff0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0201d1a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201d1c:	6008                	ld	a0,0(s0)
ffffffffc0201d1e:	4681                	li	a3,0
ffffffffc0201d20:	4601                	li	a2,0
ffffffffc0201d22:	85d6                	mv	a1,s5
ffffffffc0201d24:	d91ff0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
ffffffffc0201d28:	52051763          	bnez	a0,ffffffffc0202256 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201d2c:	6008                	ld	a0,0(s0)
ffffffffc0201d2e:	4601                	li	a2,0
ffffffffc0201d30:	4581                	li	a1,0
ffffffffc0201d32:	aabff0ef          	jal	ra,ffffffffc02017dc <get_pte>
ffffffffc0201d36:	50050063          	beqz	a0,ffffffffc0202236 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d3a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d3c:	0017f713          	andi	a4,a5,1
ffffffffc0201d40:	46070363          	beqz	a4,ffffffffc02021a6 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201d44:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d46:	078a                	slli	a5,a5,0x2
ffffffffc0201d48:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d4a:	44c7f063          	bleu	a2,a5,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d4e:	fff80737          	lui	a4,0xfff80
ffffffffc0201d52:	97ba                	add	a5,a5,a4
ffffffffc0201d54:	00379713          	slli	a4,a5,0x3
ffffffffc0201d58:	00093683          	ld	a3,0(s2)
ffffffffc0201d5c:	97ba                	add	a5,a5,a4
ffffffffc0201d5e:	078e                	slli	a5,a5,0x3
ffffffffc0201d60:	97b6                	add	a5,a5,a3
ffffffffc0201d62:	5efa9463          	bne	s5,a5,ffffffffc020234a <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0201d66:	000aab83          	lw	s7,0(s5)
ffffffffc0201d6a:	4785                	li	a5,1
ffffffffc0201d6c:	5afb9f63          	bne	s7,a5,ffffffffc020232a <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d70:	6008                	ld	a0,0(s0)
ffffffffc0201d72:	76fd                	lui	a3,0xfffff
ffffffffc0201d74:	611c                	ld	a5,0(a0)
ffffffffc0201d76:	078a                	slli	a5,a5,0x2
ffffffffc0201d78:	8ff5                	and	a5,a5,a3
ffffffffc0201d7a:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201d7e:	58c77963          	bleu	a2,a4,ffffffffc0202310 <pmm_init+0x78a>
ffffffffc0201d82:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d86:	97e2                	add	a5,a5,s8
ffffffffc0201d88:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201d8c:	0b0a                	slli	s6,s6,0x2
ffffffffc0201d8e:	00db7b33          	and	s6,s6,a3
ffffffffc0201d92:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201d96:	56c7f063          	bleu	a2,a5,ffffffffc02022f6 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d9a:	4601                	li	a2,0
ffffffffc0201d9c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d9e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201da0:	a3dff0ef          	jal	ra,ffffffffc02017dc <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201da4:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201da6:	53651863          	bne	a0,s6,ffffffffc02022d6 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc0201daa:	4505                	li	a0,1
ffffffffc0201dac:	923ff0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0201db0:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201db2:	6008                	ld	a0,0(s0)
ffffffffc0201db4:	46d1                	li	a3,20
ffffffffc0201db6:	6605                	lui	a2,0x1
ffffffffc0201db8:	85da                	mv	a1,s6
ffffffffc0201dba:	cfbff0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
ffffffffc0201dbe:	4e051c63          	bnez	a0,ffffffffc02022b6 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201dc2:	6008                	ld	a0,0(s0)
ffffffffc0201dc4:	4601                	li	a2,0
ffffffffc0201dc6:	6585                	lui	a1,0x1
ffffffffc0201dc8:	a15ff0ef          	jal	ra,ffffffffc02017dc <get_pte>
ffffffffc0201dcc:	4c050563          	beqz	a0,ffffffffc0202296 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc0201dd0:	611c                	ld	a5,0(a0)
ffffffffc0201dd2:	0107f713          	andi	a4,a5,16
ffffffffc0201dd6:	4a070063          	beqz	a4,ffffffffc0202276 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0201dda:	8b91                	andi	a5,a5,4
ffffffffc0201ddc:	66078763          	beqz	a5,ffffffffc020244a <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201de0:	6008                	ld	a0,0(s0)
ffffffffc0201de2:	611c                	ld	a5,0(a0)
ffffffffc0201de4:	8bc1                	andi	a5,a5,16
ffffffffc0201de6:	64078263          	beqz	a5,ffffffffc020242a <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201dea:	000b2783          	lw	a5,0(s6)
ffffffffc0201dee:	61779e63          	bne	a5,s7,ffffffffc020240a <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201df2:	4681                	li	a3,0
ffffffffc0201df4:	6605                	lui	a2,0x1
ffffffffc0201df6:	85d6                	mv	a1,s5
ffffffffc0201df8:	cbdff0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
ffffffffc0201dfc:	5e051763          	bnez	a0,ffffffffc02023ea <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc0201e00:	000aa703          	lw	a4,0(s5)
ffffffffc0201e04:	4789                	li	a5,2
ffffffffc0201e06:	5cf71263          	bne	a4,a5,ffffffffc02023ca <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201e0a:	000b2783          	lw	a5,0(s6)
ffffffffc0201e0e:	58079e63          	bnez	a5,ffffffffc02023aa <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201e12:	6008                	ld	a0,0(s0)
ffffffffc0201e14:	4601                	li	a2,0
ffffffffc0201e16:	6585                	lui	a1,0x1
ffffffffc0201e18:	9c5ff0ef          	jal	ra,ffffffffc02017dc <get_pte>
ffffffffc0201e1c:	56050763          	beqz	a0,ffffffffc020238a <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc0201e20:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201e22:	0016f793          	andi	a5,a3,1
ffffffffc0201e26:	38078063          	beqz	a5,ffffffffc02021a6 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201e2a:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201e2c:	00269793          	slli	a5,a3,0x2
ffffffffc0201e30:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e32:	34e7fc63          	bleu	a4,a5,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e36:	fff80737          	lui	a4,0xfff80
ffffffffc0201e3a:	97ba                	add	a5,a5,a4
ffffffffc0201e3c:	00379713          	slli	a4,a5,0x3
ffffffffc0201e40:	00093603          	ld	a2,0(s2)
ffffffffc0201e44:	97ba                	add	a5,a5,a4
ffffffffc0201e46:	078e                	slli	a5,a5,0x3
ffffffffc0201e48:	97b2                	add	a5,a5,a2
ffffffffc0201e4a:	52fa9063          	bne	s5,a5,ffffffffc020236a <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201e4e:	8ac1                	andi	a3,a3,16
ffffffffc0201e50:	6e069d63          	bnez	a3,ffffffffc020254a <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201e54:	6008                	ld	a0,0(s0)
ffffffffc0201e56:	4581                	li	a1,0
ffffffffc0201e58:	bebff0ef          	jal	ra,ffffffffc0201a42 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201e5c:	000aa703          	lw	a4,0(s5)
ffffffffc0201e60:	4785                	li	a5,1
ffffffffc0201e62:	6cf71463          	bne	a4,a5,ffffffffc020252a <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0201e66:	000b2783          	lw	a5,0(s6)
ffffffffc0201e6a:	6a079063          	bnez	a5,ffffffffc020250a <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e6e:	6008                	ld	a0,0(s0)
ffffffffc0201e70:	6585                	lui	a1,0x1
ffffffffc0201e72:	bd1ff0ef          	jal	ra,ffffffffc0201a42 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e76:	000aa783          	lw	a5,0(s5)
ffffffffc0201e7a:	66079863          	bnez	a5,ffffffffc02024ea <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc0201e7e:	000b2783          	lw	a5,0(s6)
ffffffffc0201e82:	70079463          	bnez	a5,ffffffffc020258a <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e86:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201e8a:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e8c:	000b3783          	ld	a5,0(s6)
ffffffffc0201e90:	078a                	slli	a5,a5,0x2
ffffffffc0201e92:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e94:	2eb7fb63          	bleu	a1,a5,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e98:	fff80737          	lui	a4,0xfff80
ffffffffc0201e9c:	973e                	add	a4,a4,a5
ffffffffc0201e9e:	00371793          	slli	a5,a4,0x3
ffffffffc0201ea2:	00093603          	ld	a2,0(s2)
ffffffffc0201ea6:	97ba                	add	a5,a5,a4
ffffffffc0201ea8:	078e                	slli	a5,a5,0x3
ffffffffc0201eaa:	00f60733          	add	a4,a2,a5
ffffffffc0201eae:	4314                	lw	a3,0(a4)
ffffffffc0201eb0:	4705                	li	a4,1
ffffffffc0201eb2:	6ae69c63          	bne	a3,a4,ffffffffc020256a <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201eb6:	00003a97          	auipc	s5,0x3
ffffffffc0201eba:	e92a8a93          	addi	s5,s5,-366 # ffffffffc0204d48 <commands+0x8c0>
ffffffffc0201ebe:	000ab703          	ld	a4,0(s5)
ffffffffc0201ec2:	4037d693          	srai	a3,a5,0x3
ffffffffc0201ec6:	00080bb7          	lui	s7,0x80
ffffffffc0201eca:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ece:	577d                	li	a4,-1
ffffffffc0201ed0:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ed2:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ed4:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ed6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ed8:	2ab77b63          	bleu	a1,a4,ffffffffc020218e <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201edc:	0009b783          	ld	a5,0(s3)
ffffffffc0201ee0:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ee2:	629c                	ld	a5,0(a3)
ffffffffc0201ee4:	078a                	slli	a5,a5,0x2
ffffffffc0201ee6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ee8:	2ab7f163          	bleu	a1,a5,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eec:	417787b3          	sub	a5,a5,s7
ffffffffc0201ef0:	00379513          	slli	a0,a5,0x3
ffffffffc0201ef4:	97aa                	add	a5,a5,a0
ffffffffc0201ef6:	00379513          	slli	a0,a5,0x3
ffffffffc0201efa:	9532                	add	a0,a0,a2
ffffffffc0201efc:	4585                	li	a1,1
ffffffffc0201efe:	859ff0ef          	jal	ra,ffffffffc0201756 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f02:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201f06:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f08:	050a                	slli	a0,a0,0x2
ffffffffc0201f0a:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f0c:	26f57f63          	bleu	a5,a0,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f10:	417507b3          	sub	a5,a0,s7
ffffffffc0201f14:	00379513          	slli	a0,a5,0x3
ffffffffc0201f18:	00093703          	ld	a4,0(s2)
ffffffffc0201f1c:	953e                	add	a0,a0,a5
ffffffffc0201f1e:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201f20:	4585                	li	a1,1
ffffffffc0201f22:	953a                	add	a0,a0,a4
ffffffffc0201f24:	833ff0ef          	jal	ra,ffffffffc0201756 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201f28:	601c                	ld	a5,0(s0)
ffffffffc0201f2a:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201f2e:	86fff0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc0201f32:	2caa1663          	bne	s4,a0,ffffffffc02021fe <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201f36:	00003517          	auipc	a0,0x3
ffffffffc0201f3a:	69250513          	addi	a0,a0,1682 # ffffffffc02055c8 <default_pmm_manager+0x4d0>
ffffffffc0201f3e:	980fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201f42:	85bff0ef          	jal	ra,ffffffffc020179c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f46:	6098                	ld	a4,0(s1)
ffffffffc0201f48:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201f4c:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f4e:	00c71693          	slli	a3,a4,0xc
ffffffffc0201f52:	1cd7fd63          	bleu	a3,a5,ffffffffc020212c <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f56:	83b1                	srli	a5,a5,0xc
ffffffffc0201f58:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f5a:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f5e:	1ce7f963          	bleu	a4,a5,ffffffffc0202130 <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f62:	7c7d                	lui	s8,0xfffff
ffffffffc0201f64:	6b85                	lui	s7,0x1
ffffffffc0201f66:	a029                	j	ffffffffc0201f70 <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f68:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201f6c:	1cf77263          	bleu	a5,a4,ffffffffc0202130 <pmm_init+0x5aa>
ffffffffc0201f70:	0009b583          	ld	a1,0(s3)
ffffffffc0201f74:	4601                	li	a2,0
ffffffffc0201f76:	95d2                	add	a1,a1,s4
ffffffffc0201f78:	865ff0ef          	jal	ra,ffffffffc02017dc <get_pte>
ffffffffc0201f7c:	1c050763          	beqz	a0,ffffffffc020214a <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f80:	611c                	ld	a5,0(a0)
ffffffffc0201f82:	078a                	slli	a5,a5,0x2
ffffffffc0201f84:	0187f7b3          	and	a5,a5,s8
ffffffffc0201f88:	1f479163          	bne	a5,s4,ffffffffc020216a <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f8c:	609c                	ld	a5,0(s1)
ffffffffc0201f8e:	9a5e                	add	s4,s4,s7
ffffffffc0201f90:	6008                	ld	a0,0(s0)
ffffffffc0201f92:	00c79713          	slli	a4,a5,0xc
ffffffffc0201f96:	fcea69e3          	bltu	s4,a4,ffffffffc0201f68 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f9a:	611c                	ld	a5,0(a0)
ffffffffc0201f9c:	6a079363          	bnez	a5,ffffffffc0202642 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc0201fa0:	4505                	li	a0,1
ffffffffc0201fa2:	f2cff0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0201fa6:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201fa8:	6008                	ld	a0,0(s0)
ffffffffc0201faa:	4699                	li	a3,6
ffffffffc0201fac:	10000613          	li	a2,256
ffffffffc0201fb0:	85d2                	mv	a1,s4
ffffffffc0201fb2:	b03ff0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
ffffffffc0201fb6:	66051663          	bnez	a0,ffffffffc0202622 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0201fba:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201fbe:	4785                	li	a5,1
ffffffffc0201fc0:	64f71163          	bne	a4,a5,ffffffffc0202602 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201fc4:	6008                	ld	a0,0(s0)
ffffffffc0201fc6:	6b85                	lui	s7,0x1
ffffffffc0201fc8:	4699                	li	a3,6
ffffffffc0201fca:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201fce:	85d2                	mv	a1,s4
ffffffffc0201fd0:	ae5ff0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
ffffffffc0201fd4:	60051763          	bnez	a0,ffffffffc02025e2 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0201fd8:	000a2703          	lw	a4,0(s4)
ffffffffc0201fdc:	4789                	li	a5,2
ffffffffc0201fde:	4ef71663          	bne	a4,a5,ffffffffc02024ca <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201fe2:	00003597          	auipc	a1,0x3
ffffffffc0201fe6:	71e58593          	addi	a1,a1,1822 # ffffffffc0205700 <default_pmm_manager+0x608>
ffffffffc0201fea:	10000513          	li	a0,256
ffffffffc0201fee:	2e8020ef          	jal	ra,ffffffffc02042d6 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201ff2:	100b8593          	addi	a1,s7,256
ffffffffc0201ff6:	10000513          	li	a0,256
ffffffffc0201ffa:	2ee020ef          	jal	ra,ffffffffc02042e8 <strcmp>
ffffffffc0201ffe:	4a051663          	bnez	a0,ffffffffc02024aa <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202002:	00093683          	ld	a3,0(s2)
ffffffffc0202006:	000abc83          	ld	s9,0(s5)
ffffffffc020200a:	00080c37          	lui	s8,0x80
ffffffffc020200e:	40da06b3          	sub	a3,s4,a3
ffffffffc0202012:	868d                	srai	a3,a3,0x3
ffffffffc0202014:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202018:	5afd                	li	s5,-1
ffffffffc020201a:	609c                	ld	a5,0(s1)
ffffffffc020201c:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202020:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202022:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202026:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202028:	16f77363          	bleu	a5,a4,ffffffffc020218e <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020202c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202030:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202034:	96be                	add	a3,a3,a5
ffffffffc0202036:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdeda70>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020203a:	258020ef          	jal	ra,ffffffffc0204292 <strlen>
ffffffffc020203e:	44051663          	bnez	a0,ffffffffc020248a <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202042:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202046:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202048:	000bb783          	ld	a5,0(s7)
ffffffffc020204c:	078a                	slli	a5,a5,0x2
ffffffffc020204e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202050:	12e7fd63          	bleu	a4,a5,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202054:	418787b3          	sub	a5,a5,s8
ffffffffc0202058:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020205c:	96be                	add	a3,a3,a5
ffffffffc020205e:	039686b3          	mul	a3,a3,s9
ffffffffc0202062:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202064:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202068:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020206a:	12eaf263          	bleu	a4,s5,ffffffffc020218e <pmm_init+0x608>
ffffffffc020206e:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202072:	4585                	li	a1,1
ffffffffc0202074:	8552                	mv	a0,s4
ffffffffc0202076:	99b6                	add	s3,s3,a3
ffffffffc0202078:	edeff0ef          	jal	ra,ffffffffc0201756 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020207c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202080:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202082:	078a                	slli	a5,a5,0x2
ffffffffc0202084:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202086:	10e7f263          	bleu	a4,a5,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020208a:	fff809b7          	lui	s3,0xfff80
ffffffffc020208e:	97ce                	add	a5,a5,s3
ffffffffc0202090:	00379513          	slli	a0,a5,0x3
ffffffffc0202094:	00093703          	ld	a4,0(s2)
ffffffffc0202098:	97aa                	add	a5,a5,a0
ffffffffc020209a:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020209e:	953a                	add	a0,a0,a4
ffffffffc02020a0:	4585                	li	a1,1
ffffffffc02020a2:	eb4ff0ef          	jal	ra,ffffffffc0201756 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02020a6:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02020aa:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02020ac:	050a                	slli	a0,a0,0x2
ffffffffc02020ae:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020b0:	0cf57d63          	bleu	a5,a0,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02020b4:	013507b3          	add	a5,a0,s3
ffffffffc02020b8:	00379513          	slli	a0,a5,0x3
ffffffffc02020bc:	00093703          	ld	a4,0(s2)
ffffffffc02020c0:	953e                	add	a0,a0,a5
ffffffffc02020c2:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc02020c4:	4585                	li	a1,1
ffffffffc02020c6:	953a                	add	a0,a0,a4
ffffffffc02020c8:	e8eff0ef          	jal	ra,ffffffffc0201756 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02020cc:	601c                	ld	a5,0(s0)
ffffffffc02020ce:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc02020d2:	ecaff0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc02020d6:	38ab1a63          	bne	s6,a0,ffffffffc020246a <pmm_init+0x8e4>
}
ffffffffc02020da:	6446                	ld	s0,80(sp)
ffffffffc02020dc:	60e6                	ld	ra,88(sp)
ffffffffc02020de:	64a6                	ld	s1,72(sp)
ffffffffc02020e0:	6906                	ld	s2,64(sp)
ffffffffc02020e2:	79e2                	ld	s3,56(sp)
ffffffffc02020e4:	7a42                	ld	s4,48(sp)
ffffffffc02020e6:	7aa2                	ld	s5,40(sp)
ffffffffc02020e8:	7b02                	ld	s6,32(sp)
ffffffffc02020ea:	6be2                	ld	s7,24(sp)
ffffffffc02020ec:	6c42                	ld	s8,16(sp)
ffffffffc02020ee:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020f0:	00003517          	auipc	a0,0x3
ffffffffc02020f4:	68850513          	addi	a0,a0,1672 # ffffffffc0205778 <default_pmm_manager+0x680>
}
ffffffffc02020f8:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020fa:	fc5fd06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020fe:	6705                	lui	a4,0x1
ffffffffc0202100:	177d                	addi	a4,a4,-1
ffffffffc0202102:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0202104:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202108:	08f77163          	bleu	a5,a4,ffffffffc020218a <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc020210c:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0202110:	9732                	add	a4,a4,a2
ffffffffc0202112:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202116:	767d                	lui	a2,0xfffff
ffffffffc0202118:	8ef1                	and	a3,a3,a2
ffffffffc020211a:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc020211c:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202120:	8d95                	sub	a1,a1,a3
ffffffffc0202122:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0202124:	81b1                	srli	a1,a1,0xc
ffffffffc0202126:	953e                	add	a0,a0,a5
ffffffffc0202128:	9702                	jalr	a4
ffffffffc020212a:	bead                	j	ffffffffc0201ca4 <pmm_init+0x11e>
ffffffffc020212c:	6008                	ld	a0,0(s0)
ffffffffc020212e:	b5b5                	j	ffffffffc0201f9a <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202130:	86d2                	mv	a3,s4
ffffffffc0202132:	00003617          	auipc	a2,0x3
ffffffffc0202136:	01660613          	addi	a2,a2,22 # ffffffffc0205148 <default_pmm_manager+0x50>
ffffffffc020213a:	1cd00593          	li	a1,461
ffffffffc020213e:	00003517          	auipc	a0,0x3
ffffffffc0202142:	03250513          	addi	a0,a0,50 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202146:	a2efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020214a:	00003697          	auipc	a3,0x3
ffffffffc020214e:	49e68693          	addi	a3,a3,1182 # ffffffffc02055e8 <default_pmm_manager+0x4f0>
ffffffffc0202152:	00003617          	auipc	a2,0x3
ffffffffc0202156:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020215a:	1cd00593          	li	a1,461
ffffffffc020215e:	00003517          	auipc	a0,0x3
ffffffffc0202162:	01250513          	addi	a0,a0,18 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202166:	a0efe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020216a:	00003697          	auipc	a3,0x3
ffffffffc020216e:	4be68693          	addi	a3,a3,1214 # ffffffffc0205628 <default_pmm_manager+0x530>
ffffffffc0202172:	00003617          	auipc	a2,0x3
ffffffffc0202176:	bee60613          	addi	a2,a2,-1042 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020217a:	1ce00593          	li	a1,462
ffffffffc020217e:	00003517          	auipc	a0,0x3
ffffffffc0202182:	ff250513          	addi	a0,a0,-14 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202186:	9eefe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020218a:	d28ff0ef          	jal	ra,ffffffffc02016b2 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020218e:	00003617          	auipc	a2,0x3
ffffffffc0202192:	fba60613          	addi	a2,a2,-70 # ffffffffc0205148 <default_pmm_manager+0x50>
ffffffffc0202196:	06a00593          	li	a1,106
ffffffffc020219a:	00003517          	auipc	a0,0x3
ffffffffc020219e:	04650513          	addi	a0,a0,70 # ffffffffc02051e0 <default_pmm_manager+0xe8>
ffffffffc02021a2:	9d2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02021a6:	00003617          	auipc	a2,0x3
ffffffffc02021aa:	21260613          	addi	a2,a2,530 # ffffffffc02053b8 <default_pmm_manager+0x2c0>
ffffffffc02021ae:	07000593          	li	a1,112
ffffffffc02021b2:	00003517          	auipc	a0,0x3
ffffffffc02021b6:	02e50513          	addi	a0,a0,46 # ffffffffc02051e0 <default_pmm_manager+0xe8>
ffffffffc02021ba:	9bafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02021be:	00003697          	auipc	a3,0x3
ffffffffc02021c2:	13a68693          	addi	a3,a3,314 # ffffffffc02052f8 <default_pmm_manager+0x200>
ffffffffc02021c6:	00003617          	auipc	a2,0x3
ffffffffc02021ca:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02021ce:	19300593          	li	a1,403
ffffffffc02021d2:	00003517          	auipc	a0,0x3
ffffffffc02021d6:	f9e50513          	addi	a0,a0,-98 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02021da:	99afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02021de:	00003697          	auipc	a3,0x3
ffffffffc02021e2:	15268693          	addi	a3,a3,338 # ffffffffc0205330 <default_pmm_manager+0x238>
ffffffffc02021e6:	00003617          	auipc	a2,0x3
ffffffffc02021ea:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02021ee:	19400593          	li	a1,404
ffffffffc02021f2:	00003517          	auipc	a0,0x3
ffffffffc02021f6:	f7e50513          	addi	a0,a0,-130 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02021fa:	97afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02021fe:	00003697          	auipc	a3,0x3
ffffffffc0202202:	3aa68693          	addi	a3,a3,938 # ffffffffc02055a8 <default_pmm_manager+0x4b0>
ffffffffc0202206:	00003617          	auipc	a2,0x3
ffffffffc020220a:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020220e:	1c000593          	li	a1,448
ffffffffc0202212:	00003517          	auipc	a0,0x3
ffffffffc0202216:	f5e50513          	addi	a0,a0,-162 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc020221a:	95afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020221e:	00003617          	auipc	a2,0x3
ffffffffc0202222:	07260613          	addi	a2,a2,114 # ffffffffc0205290 <default_pmm_manager+0x198>
ffffffffc0202226:	07700593          	li	a1,119
ffffffffc020222a:	00003517          	auipc	a0,0x3
ffffffffc020222e:	f4650513          	addi	a0,a0,-186 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202232:	942fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202236:	00003697          	auipc	a3,0x3
ffffffffc020223a:	15268693          	addi	a3,a3,338 # ffffffffc0205388 <default_pmm_manager+0x290>
ffffffffc020223e:	00003617          	auipc	a2,0x3
ffffffffc0202242:	b2260613          	addi	a2,a2,-1246 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202246:	19a00593          	li	a1,410
ffffffffc020224a:	00003517          	auipc	a0,0x3
ffffffffc020224e:	f2650513          	addi	a0,a0,-218 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202252:	922fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202256:	00003697          	auipc	a3,0x3
ffffffffc020225a:	10268693          	addi	a3,a3,258 # ffffffffc0205358 <default_pmm_manager+0x260>
ffffffffc020225e:	00003617          	auipc	a2,0x3
ffffffffc0202262:	b0260613          	addi	a2,a2,-1278 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202266:	19800593          	li	a1,408
ffffffffc020226a:	00003517          	auipc	a0,0x3
ffffffffc020226e:	f0650513          	addi	a0,a0,-250 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202272:	902fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202276:	00003697          	auipc	a3,0x3
ffffffffc020227a:	22a68693          	addi	a3,a3,554 # ffffffffc02054a0 <default_pmm_manager+0x3a8>
ffffffffc020227e:	00003617          	auipc	a2,0x3
ffffffffc0202282:	ae260613          	addi	a2,a2,-1310 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202286:	1a500593          	li	a1,421
ffffffffc020228a:	00003517          	auipc	a0,0x3
ffffffffc020228e:	ee650513          	addi	a0,a0,-282 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202292:	8e2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202296:	00003697          	auipc	a3,0x3
ffffffffc020229a:	1da68693          	addi	a3,a3,474 # ffffffffc0205470 <default_pmm_manager+0x378>
ffffffffc020229e:	00003617          	auipc	a2,0x3
ffffffffc02022a2:	ac260613          	addi	a2,a2,-1342 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02022a6:	1a400593          	li	a1,420
ffffffffc02022aa:	00003517          	auipc	a0,0x3
ffffffffc02022ae:	ec650513          	addi	a0,a0,-314 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02022b2:	8c2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02022b6:	00003697          	auipc	a3,0x3
ffffffffc02022ba:	18268693          	addi	a3,a3,386 # ffffffffc0205438 <default_pmm_manager+0x340>
ffffffffc02022be:	00003617          	auipc	a2,0x3
ffffffffc02022c2:	aa260613          	addi	a2,a2,-1374 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02022c6:	1a300593          	li	a1,419
ffffffffc02022ca:	00003517          	auipc	a0,0x3
ffffffffc02022ce:	ea650513          	addi	a0,a0,-346 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02022d2:	8a2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02022d6:	00003697          	auipc	a3,0x3
ffffffffc02022da:	13a68693          	addi	a3,a3,314 # ffffffffc0205410 <default_pmm_manager+0x318>
ffffffffc02022de:	00003617          	auipc	a2,0x3
ffffffffc02022e2:	a8260613          	addi	a2,a2,-1406 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02022e6:	1a000593          	li	a1,416
ffffffffc02022ea:	00003517          	auipc	a0,0x3
ffffffffc02022ee:	e8650513          	addi	a0,a0,-378 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02022f2:	882fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022f6:	86da                	mv	a3,s6
ffffffffc02022f8:	00003617          	auipc	a2,0x3
ffffffffc02022fc:	e5060613          	addi	a2,a2,-432 # ffffffffc0205148 <default_pmm_manager+0x50>
ffffffffc0202300:	19f00593          	li	a1,415
ffffffffc0202304:	00003517          	auipc	a0,0x3
ffffffffc0202308:	e6c50513          	addi	a0,a0,-404 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc020230c:	868fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202310:	86be                	mv	a3,a5
ffffffffc0202312:	00003617          	auipc	a2,0x3
ffffffffc0202316:	e3660613          	addi	a2,a2,-458 # ffffffffc0205148 <default_pmm_manager+0x50>
ffffffffc020231a:	19e00593          	li	a1,414
ffffffffc020231e:	00003517          	auipc	a0,0x3
ffffffffc0202322:	e5250513          	addi	a0,a0,-430 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202326:	84efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020232a:	00003697          	auipc	a3,0x3
ffffffffc020232e:	0ce68693          	addi	a3,a3,206 # ffffffffc02053f8 <default_pmm_manager+0x300>
ffffffffc0202332:	00003617          	auipc	a2,0x3
ffffffffc0202336:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020233a:	19c00593          	li	a1,412
ffffffffc020233e:	00003517          	auipc	a0,0x3
ffffffffc0202342:	e3250513          	addi	a0,a0,-462 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202346:	82efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020234a:	00003697          	auipc	a3,0x3
ffffffffc020234e:	09668693          	addi	a3,a3,150 # ffffffffc02053e0 <default_pmm_manager+0x2e8>
ffffffffc0202352:	00003617          	auipc	a2,0x3
ffffffffc0202356:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020235a:	19b00593          	li	a1,411
ffffffffc020235e:	00003517          	auipc	a0,0x3
ffffffffc0202362:	e1250513          	addi	a0,a0,-494 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202366:	80efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020236a:	00003697          	auipc	a3,0x3
ffffffffc020236e:	07668693          	addi	a3,a3,118 # ffffffffc02053e0 <default_pmm_manager+0x2e8>
ffffffffc0202372:	00003617          	auipc	a2,0x3
ffffffffc0202376:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020237a:	1ae00593          	li	a1,430
ffffffffc020237e:	00003517          	auipc	a0,0x3
ffffffffc0202382:	df250513          	addi	a0,a0,-526 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202386:	feffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020238a:	00003697          	auipc	a3,0x3
ffffffffc020238e:	0e668693          	addi	a3,a3,230 # ffffffffc0205470 <default_pmm_manager+0x378>
ffffffffc0202392:	00003617          	auipc	a2,0x3
ffffffffc0202396:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020239a:	1ad00593          	li	a1,429
ffffffffc020239e:	00003517          	auipc	a0,0x3
ffffffffc02023a2:	dd250513          	addi	a0,a0,-558 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02023a6:	fcffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02023aa:	00003697          	auipc	a3,0x3
ffffffffc02023ae:	18e68693          	addi	a3,a3,398 # ffffffffc0205538 <default_pmm_manager+0x440>
ffffffffc02023b2:	00003617          	auipc	a2,0x3
ffffffffc02023b6:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02023ba:	1ac00593          	li	a1,428
ffffffffc02023be:	00003517          	auipc	a0,0x3
ffffffffc02023c2:	db250513          	addi	a0,a0,-590 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02023c6:	faffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02023ca:	00003697          	auipc	a3,0x3
ffffffffc02023ce:	15668693          	addi	a3,a3,342 # ffffffffc0205520 <default_pmm_manager+0x428>
ffffffffc02023d2:	00003617          	auipc	a2,0x3
ffffffffc02023d6:	98e60613          	addi	a2,a2,-1650 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02023da:	1ab00593          	li	a1,427
ffffffffc02023de:	00003517          	auipc	a0,0x3
ffffffffc02023e2:	d9250513          	addi	a0,a0,-622 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02023e6:	f8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02023ea:	00003697          	auipc	a3,0x3
ffffffffc02023ee:	10668693          	addi	a3,a3,262 # ffffffffc02054f0 <default_pmm_manager+0x3f8>
ffffffffc02023f2:	00003617          	auipc	a2,0x3
ffffffffc02023f6:	96e60613          	addi	a2,a2,-1682 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02023fa:	1aa00593          	li	a1,426
ffffffffc02023fe:	00003517          	auipc	a0,0x3
ffffffffc0202402:	d7250513          	addi	a0,a0,-654 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202406:	f6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020240a:	00003697          	auipc	a3,0x3
ffffffffc020240e:	0ce68693          	addi	a3,a3,206 # ffffffffc02054d8 <default_pmm_manager+0x3e0>
ffffffffc0202412:	00003617          	auipc	a2,0x3
ffffffffc0202416:	94e60613          	addi	a2,a2,-1714 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020241a:	1a800593          	li	a1,424
ffffffffc020241e:	00003517          	auipc	a0,0x3
ffffffffc0202422:	d5250513          	addi	a0,a0,-686 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202426:	f4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020242a:	00003697          	auipc	a3,0x3
ffffffffc020242e:	09668693          	addi	a3,a3,150 # ffffffffc02054c0 <default_pmm_manager+0x3c8>
ffffffffc0202432:	00003617          	auipc	a2,0x3
ffffffffc0202436:	92e60613          	addi	a2,a2,-1746 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020243a:	1a700593          	li	a1,423
ffffffffc020243e:	00003517          	auipc	a0,0x3
ffffffffc0202442:	d3250513          	addi	a0,a0,-718 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202446:	f2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020244a:	00003697          	auipc	a3,0x3
ffffffffc020244e:	06668693          	addi	a3,a3,102 # ffffffffc02054b0 <default_pmm_manager+0x3b8>
ffffffffc0202452:	00003617          	auipc	a2,0x3
ffffffffc0202456:	90e60613          	addi	a2,a2,-1778 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020245a:	1a600593          	li	a1,422
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	d1250513          	addi	a0,a0,-750 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202466:	f0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020246a:	00003697          	auipc	a3,0x3
ffffffffc020246e:	13e68693          	addi	a3,a3,318 # ffffffffc02055a8 <default_pmm_manager+0x4b0>
ffffffffc0202472:	00003617          	auipc	a2,0x3
ffffffffc0202476:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020247a:	1e800593          	li	a1,488
ffffffffc020247e:	00003517          	auipc	a0,0x3
ffffffffc0202482:	cf250513          	addi	a0,a0,-782 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202486:	eeffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020248a:	00003697          	auipc	a3,0x3
ffffffffc020248e:	2c668693          	addi	a3,a3,710 # ffffffffc0205750 <default_pmm_manager+0x658>
ffffffffc0202492:	00003617          	auipc	a2,0x3
ffffffffc0202496:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020249a:	1e000593          	li	a1,480
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	cd250513          	addi	a0,a0,-814 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02024a6:	ecffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02024aa:	00003697          	auipc	a3,0x3
ffffffffc02024ae:	26e68693          	addi	a3,a3,622 # ffffffffc0205718 <default_pmm_manager+0x620>
ffffffffc02024b2:	00003617          	auipc	a2,0x3
ffffffffc02024b6:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02024ba:	1dd00593          	li	a1,477
ffffffffc02024be:	00003517          	auipc	a0,0x3
ffffffffc02024c2:	cb250513          	addi	a0,a0,-846 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02024c6:	eaffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02024ca:	00003697          	auipc	a3,0x3
ffffffffc02024ce:	21e68693          	addi	a3,a3,542 # ffffffffc02056e8 <default_pmm_manager+0x5f0>
ffffffffc02024d2:	00003617          	auipc	a2,0x3
ffffffffc02024d6:	88e60613          	addi	a2,a2,-1906 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02024da:	1d900593          	li	a1,473
ffffffffc02024de:	00003517          	auipc	a0,0x3
ffffffffc02024e2:	c9250513          	addi	a0,a0,-878 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02024e6:	e8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02024ea:	00003697          	auipc	a3,0x3
ffffffffc02024ee:	07e68693          	addi	a3,a3,126 # ffffffffc0205568 <default_pmm_manager+0x470>
ffffffffc02024f2:	00003617          	auipc	a2,0x3
ffffffffc02024f6:	86e60613          	addi	a2,a2,-1938 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02024fa:	1b600593          	li	a1,438
ffffffffc02024fe:	00003517          	auipc	a0,0x3
ffffffffc0202502:	c7250513          	addi	a0,a0,-910 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202506:	e6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020250a:	00003697          	auipc	a3,0x3
ffffffffc020250e:	02e68693          	addi	a3,a3,46 # ffffffffc0205538 <default_pmm_manager+0x440>
ffffffffc0202512:	00003617          	auipc	a2,0x3
ffffffffc0202516:	84e60613          	addi	a2,a2,-1970 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020251a:	1b300593          	li	a1,435
ffffffffc020251e:	00003517          	auipc	a0,0x3
ffffffffc0202522:	c5250513          	addi	a0,a0,-942 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202526:	e4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020252a:	00003697          	auipc	a3,0x3
ffffffffc020252e:	ece68693          	addi	a3,a3,-306 # ffffffffc02053f8 <default_pmm_manager+0x300>
ffffffffc0202532:	00003617          	auipc	a2,0x3
ffffffffc0202536:	82e60613          	addi	a2,a2,-2002 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020253a:	1b200593          	li	a1,434
ffffffffc020253e:	00003517          	auipc	a0,0x3
ffffffffc0202542:	c3250513          	addi	a0,a0,-974 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202546:	e2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020254a:	00003697          	auipc	a3,0x3
ffffffffc020254e:	00668693          	addi	a3,a3,6 # ffffffffc0205550 <default_pmm_manager+0x458>
ffffffffc0202552:	00003617          	auipc	a2,0x3
ffffffffc0202556:	80e60613          	addi	a2,a2,-2034 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020255a:	1af00593          	li	a1,431
ffffffffc020255e:	00003517          	auipc	a0,0x3
ffffffffc0202562:	c1250513          	addi	a0,a0,-1006 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202566:	e0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020256a:	00003697          	auipc	a3,0x3
ffffffffc020256e:	01668693          	addi	a3,a3,22 # ffffffffc0205580 <default_pmm_manager+0x488>
ffffffffc0202572:	00002617          	auipc	a2,0x2
ffffffffc0202576:	7ee60613          	addi	a2,a2,2030 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020257a:	1b900593          	li	a1,441
ffffffffc020257e:	00003517          	auipc	a0,0x3
ffffffffc0202582:	bf250513          	addi	a0,a0,-1038 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202586:	deffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020258a:	00003697          	auipc	a3,0x3
ffffffffc020258e:	fae68693          	addi	a3,a3,-82 # ffffffffc0205538 <default_pmm_manager+0x440>
ffffffffc0202592:	00002617          	auipc	a2,0x2
ffffffffc0202596:	7ce60613          	addi	a2,a2,1998 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020259a:	1b700593          	li	a1,439
ffffffffc020259e:	00003517          	auipc	a0,0x3
ffffffffc02025a2:	bd250513          	addi	a0,a0,-1070 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02025a6:	dcffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02025aa:	00003697          	auipc	a3,0x3
ffffffffc02025ae:	d2e68693          	addi	a3,a3,-722 # ffffffffc02052d8 <default_pmm_manager+0x1e0>
ffffffffc02025b2:	00002617          	auipc	a2,0x2
ffffffffc02025b6:	7ae60613          	addi	a2,a2,1966 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02025ba:	19200593          	li	a1,402
ffffffffc02025be:	00003517          	auipc	a0,0x3
ffffffffc02025c2:	bb250513          	addi	a0,a0,-1102 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02025c6:	daffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02025ca:	00003617          	auipc	a2,0x3
ffffffffc02025ce:	cc660613          	addi	a2,a2,-826 # ffffffffc0205290 <default_pmm_manager+0x198>
ffffffffc02025d2:	0bd00593          	li	a1,189
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02025de:	d97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	0c668693          	addi	a3,a3,198 # ffffffffc02056a8 <default_pmm_manager+0x5b0>
ffffffffc02025ea:	00002617          	auipc	a2,0x2
ffffffffc02025ee:	77660613          	addi	a2,a2,1910 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02025f2:	1d800593          	li	a1,472
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02025fe:	d77fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202602:	00003697          	auipc	a3,0x3
ffffffffc0202606:	08e68693          	addi	a3,a3,142 # ffffffffc0205690 <default_pmm_manager+0x598>
ffffffffc020260a:	00002617          	auipc	a2,0x2
ffffffffc020260e:	75660613          	addi	a2,a2,1878 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202612:	1d700593          	li	a1,471
ffffffffc0202616:	00003517          	auipc	a0,0x3
ffffffffc020261a:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc020261e:	d57fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202622:	00003697          	auipc	a3,0x3
ffffffffc0202626:	03668693          	addi	a3,a3,54 # ffffffffc0205658 <default_pmm_manager+0x560>
ffffffffc020262a:	00002617          	auipc	a2,0x2
ffffffffc020262e:	73660613          	addi	a2,a2,1846 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202632:	1d600593          	li	a1,470
ffffffffc0202636:	00003517          	auipc	a0,0x3
ffffffffc020263a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc020263e:	d37fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202642:	00003697          	auipc	a3,0x3
ffffffffc0202646:	ffe68693          	addi	a3,a3,-2 # ffffffffc0205640 <default_pmm_manager+0x548>
ffffffffc020264a:	00002617          	auipc	a2,0x2
ffffffffc020264e:	71660613          	addi	a2,a2,1814 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202652:	1d200593          	li	a1,466
ffffffffc0202656:	00003517          	auipc	a0,0x3
ffffffffc020265a:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc020265e:	d17fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202662 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202662:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0202666:	8082                	ret

ffffffffc0202668 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202668:	7179                	addi	sp,sp,-48
ffffffffc020266a:	e84a                	sd	s2,16(sp)
ffffffffc020266c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020266e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202670:	f022                	sd	s0,32(sp)
ffffffffc0202672:	ec26                	sd	s1,24(sp)
ffffffffc0202674:	e44e                	sd	s3,8(sp)
ffffffffc0202676:	f406                	sd	ra,40(sp)
ffffffffc0202678:	84ae                	mv	s1,a1
ffffffffc020267a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020267c:	852ff0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0202680:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202682:	cd19                	beqz	a0,ffffffffc02026a0 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202684:	85aa                	mv	a1,a0
ffffffffc0202686:	86ce                	mv	a3,s3
ffffffffc0202688:	8626                	mv	a2,s1
ffffffffc020268a:	854a                	mv	a0,s2
ffffffffc020268c:	c28ff0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
ffffffffc0202690:	ed39                	bnez	a0,ffffffffc02026ee <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202692:	0000f797          	auipc	a5,0xf
ffffffffc0202696:	dde78793          	addi	a5,a5,-546 # ffffffffc0211470 <swap_init_ok>
ffffffffc020269a:	439c                	lw	a5,0(a5)
ffffffffc020269c:	2781                	sext.w	a5,a5
ffffffffc020269e:	eb89                	bnez	a5,ffffffffc02026b0 <pgdir_alloc_page+0x48>
}
ffffffffc02026a0:	8522                	mv	a0,s0
ffffffffc02026a2:	70a2                	ld	ra,40(sp)
ffffffffc02026a4:	7402                	ld	s0,32(sp)
ffffffffc02026a6:	64e2                	ld	s1,24(sp)
ffffffffc02026a8:	6942                	ld	s2,16(sp)
ffffffffc02026aa:	69a2                	ld	s3,8(sp)
ffffffffc02026ac:	6145                	addi	sp,sp,48
ffffffffc02026ae:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02026b0:	0000f797          	auipc	a5,0xf
ffffffffc02026b4:	fd878793          	addi	a5,a5,-40 # ffffffffc0211688 <check_mm_struct>
ffffffffc02026b8:	6388                	ld	a0,0(a5)
ffffffffc02026ba:	4681                	li	a3,0
ffffffffc02026bc:	8622                	mv	a2,s0
ffffffffc02026be:	85a6                	mv	a1,s1
ffffffffc02026c0:	06d000ef          	jal	ra,ffffffffc0202f2c <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc02026c4:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc02026c6:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc02026c8:	4785                	li	a5,1
ffffffffc02026ca:	fcf70be3          	beq	a4,a5,ffffffffc02026a0 <pgdir_alloc_page+0x38>
ffffffffc02026ce:	00003697          	auipc	a3,0x3
ffffffffc02026d2:	b2268693          	addi	a3,a3,-1246 # ffffffffc02051f0 <default_pmm_manager+0xf8>
ffffffffc02026d6:	00002617          	auipc	a2,0x2
ffffffffc02026da:	68a60613          	addi	a2,a2,1674 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02026de:	17a00593          	li	a1,378
ffffffffc02026e2:	00003517          	auipc	a0,0x3
ffffffffc02026e6:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02026ea:	c8bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
            free_page(page);
ffffffffc02026ee:	8522                	mv	a0,s0
ffffffffc02026f0:	4585                	li	a1,1
ffffffffc02026f2:	864ff0ef          	jal	ra,ffffffffc0201756 <free_pages>
            return NULL;
ffffffffc02026f6:	4401                	li	s0,0
ffffffffc02026f8:	b765                	j	ffffffffc02026a0 <pgdir_alloc_page+0x38>

ffffffffc02026fa <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02026fa:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026fc:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02026fe:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202700:	fff50713          	addi	a4,a0,-1
ffffffffc0202704:	17f9                	addi	a5,a5,-2
ffffffffc0202706:	04e7ee63          	bltu	a5,a4,ffffffffc0202762 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020270a:	6785                	lui	a5,0x1
ffffffffc020270c:	17fd                	addi	a5,a5,-1
ffffffffc020270e:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0202710:	8131                	srli	a0,a0,0xc
ffffffffc0202712:	fbdfe0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
    assert(base != NULL);
ffffffffc0202716:	c159                	beqz	a0,ffffffffc020279c <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202718:	0000f797          	auipc	a5,0xf
ffffffffc020271c:	e8878793          	addi	a5,a5,-376 # ffffffffc02115a0 <pages>
ffffffffc0202720:	639c                	ld	a5,0(a5)
ffffffffc0202722:	8d1d                	sub	a0,a0,a5
ffffffffc0202724:	00002797          	auipc	a5,0x2
ffffffffc0202728:	62478793          	addi	a5,a5,1572 # ffffffffc0204d48 <commands+0x8c0>
ffffffffc020272c:	6394                	ld	a3,0(a5)
ffffffffc020272e:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202730:	0000f797          	auipc	a5,0xf
ffffffffc0202734:	d3078793          	addi	a5,a5,-720 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202738:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020273c:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020273e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202742:	57fd                	li	a5,-1
ffffffffc0202744:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202746:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202748:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020274a:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020274c:	02e7fb63          	bleu	a4,a5,ffffffffc0202782 <kmalloc+0x88>
ffffffffc0202750:	0000f797          	auipc	a5,0xf
ffffffffc0202754:	e4078793          	addi	a5,a5,-448 # ffffffffc0211590 <va_pa_offset>
ffffffffc0202758:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc020275a:	60a2                	ld	ra,8(sp)
ffffffffc020275c:	953e                	add	a0,a0,a5
ffffffffc020275e:	0141                	addi	sp,sp,16
ffffffffc0202760:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202762:	00003697          	auipc	a3,0x3
ffffffffc0202766:	a2e68693          	addi	a3,a3,-1490 # ffffffffc0205190 <default_pmm_manager+0x98>
ffffffffc020276a:	00002617          	auipc	a2,0x2
ffffffffc020276e:	5f660613          	addi	a2,a2,1526 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202772:	1f000593          	li	a1,496
ffffffffc0202776:	00003517          	auipc	a0,0x3
ffffffffc020277a:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc020277e:	bf7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202782:	86aa                	mv	a3,a0
ffffffffc0202784:	00003617          	auipc	a2,0x3
ffffffffc0202788:	9c460613          	addi	a2,a2,-1596 # ffffffffc0205148 <default_pmm_manager+0x50>
ffffffffc020278c:	06a00593          	li	a1,106
ffffffffc0202790:	00003517          	auipc	a0,0x3
ffffffffc0202794:	a5050513          	addi	a0,a0,-1456 # ffffffffc02051e0 <default_pmm_manager+0xe8>
ffffffffc0202798:	bddfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc020279c:	00003697          	auipc	a3,0x3
ffffffffc02027a0:	a1468693          	addi	a3,a3,-1516 # ffffffffc02051b0 <default_pmm_manager+0xb8>
ffffffffc02027a4:	00002617          	auipc	a2,0x2
ffffffffc02027a8:	5bc60613          	addi	a2,a2,1468 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02027ac:	1f300593          	li	a1,499
ffffffffc02027b0:	00003517          	auipc	a0,0x3
ffffffffc02027b4:	9c050513          	addi	a0,a0,-1600 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc02027b8:	bbdfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02027bc <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc02027bc:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027be:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc02027c0:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027c2:	fff58713          	addi	a4,a1,-1
ffffffffc02027c6:	17f9                	addi	a5,a5,-2
ffffffffc02027c8:	04e7eb63          	bltu	a5,a4,ffffffffc020281e <kfree+0x62>
    assert(ptr != NULL);
ffffffffc02027cc:	c941                	beqz	a0,ffffffffc020285c <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02027ce:	6785                	lui	a5,0x1
ffffffffc02027d0:	17fd                	addi	a5,a5,-1
ffffffffc02027d2:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027d4:	c02007b7          	lui	a5,0xc0200
ffffffffc02027d8:	81b1                	srli	a1,a1,0xc
ffffffffc02027da:	06f56463          	bltu	a0,a5,ffffffffc0202842 <kfree+0x86>
ffffffffc02027de:	0000f797          	auipc	a5,0xf
ffffffffc02027e2:	db278793          	addi	a5,a5,-590 # ffffffffc0211590 <va_pa_offset>
ffffffffc02027e6:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02027e8:	0000f717          	auipc	a4,0xf
ffffffffc02027ec:	c7870713          	addi	a4,a4,-904 # ffffffffc0211460 <npage>
ffffffffc02027f0:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027f2:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc02027f6:	83b1                	srli	a5,a5,0xc
ffffffffc02027f8:	04e7f363          	bleu	a4,a5,ffffffffc020283e <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc02027fc:	fff80537          	lui	a0,0xfff80
ffffffffc0202800:	97aa                	add	a5,a5,a0
ffffffffc0202802:	0000f697          	auipc	a3,0xf
ffffffffc0202806:	d9e68693          	addi	a3,a3,-610 # ffffffffc02115a0 <pages>
ffffffffc020280a:	6288                	ld	a0,0(a3)
ffffffffc020280c:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0202810:	60a2                	ld	ra,8(sp)
ffffffffc0202812:	97ba                	add	a5,a5,a4
ffffffffc0202814:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0202816:	953e                	add	a0,a0,a5
}
ffffffffc0202818:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc020281a:	f3dfe06f          	j	ffffffffc0201756 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020281e:	00003697          	auipc	a3,0x3
ffffffffc0202822:	97268693          	addi	a3,a3,-1678 # ffffffffc0205190 <default_pmm_manager+0x98>
ffffffffc0202826:	00002617          	auipc	a2,0x2
ffffffffc020282a:	53a60613          	addi	a2,a2,1338 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020282e:	1f900593          	li	a1,505
ffffffffc0202832:	00003517          	auipc	a0,0x3
ffffffffc0202836:	93e50513          	addi	a0,a0,-1730 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc020283a:	b3bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020283e:	e75fe0ef          	jal	ra,ffffffffc02016b2 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202842:	86aa                	mv	a3,a0
ffffffffc0202844:	00003617          	auipc	a2,0x3
ffffffffc0202848:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0205290 <default_pmm_manager+0x198>
ffffffffc020284c:	06c00593          	li	a1,108
ffffffffc0202850:	00003517          	auipc	a0,0x3
ffffffffc0202854:	99050513          	addi	a0,a0,-1648 # ffffffffc02051e0 <default_pmm_manager+0xe8>
ffffffffc0202858:	b1dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc020285c:	00003697          	auipc	a3,0x3
ffffffffc0202860:	92468693          	addi	a3,a3,-1756 # ffffffffc0205180 <default_pmm_manager+0x88>
ffffffffc0202864:	00002617          	auipc	a2,0x2
ffffffffc0202868:	4fc60613          	addi	a2,a2,1276 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020286c:	1fa00593          	li	a1,506
ffffffffc0202870:	00003517          	auipc	a0,0x3
ffffffffc0202874:	90050513          	addi	a0,a0,-1792 # ffffffffc0205170 <default_pmm_manager+0x78>
ffffffffc0202878:	afdfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020287c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020287c:	7135                	addi	sp,sp,-160
ffffffffc020287e:	ed06                	sd	ra,152(sp)
ffffffffc0202880:	e922                	sd	s0,144(sp)
ffffffffc0202882:	e526                	sd	s1,136(sp)
ffffffffc0202884:	e14a                	sd	s2,128(sp)
ffffffffc0202886:	fcce                	sd	s3,120(sp)
ffffffffc0202888:	f8d2                	sd	s4,112(sp)
ffffffffc020288a:	f4d6                	sd	s5,104(sp)
ffffffffc020288c:	f0da                	sd	s6,96(sp)
ffffffffc020288e:	ecde                	sd	s7,88(sp)
ffffffffc0202890:	e8e2                	sd	s8,80(sp)
ffffffffc0202892:	e4e6                	sd	s9,72(sp)
ffffffffc0202894:	e0ea                	sd	s10,64(sp)
ffffffffc0202896:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202898:	3c0010ef          	jal	ra,ffffffffc0203c58 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020289c:	0000f797          	auipc	a5,0xf
ffffffffc02028a0:	d9478793          	addi	a5,a5,-620 # ffffffffc0211630 <max_swap_offset>
ffffffffc02028a4:	6394                	ld	a3,0(a5)
ffffffffc02028a6:	010007b7          	lui	a5,0x1000
ffffffffc02028aa:	17e1                	addi	a5,a5,-8
ffffffffc02028ac:	ff968713          	addi	a4,a3,-7
ffffffffc02028b0:	42e7ea63          	bltu	a5,a4,ffffffffc0202ce4 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;
ffffffffc02028b4:	00007797          	auipc	a5,0x7
ffffffffc02028b8:	74c78793          	addi	a5,a5,1868 # ffffffffc020a000 <swap_manager_clock>
    // sm = &swap_manager_fifo;
    // sm = &swap_manager_lru;     
     int r = sm->init();
ffffffffc02028bc:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;
ffffffffc02028be:	0000f697          	auipc	a3,0xf
ffffffffc02028c2:	baf6b523          	sd	a5,-1110(a3) # ffffffffc0211468 <sm>
     int r = sm->init();
ffffffffc02028c6:	9702                	jalr	a4
ffffffffc02028c8:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc02028ca:	c10d                	beqz	a0,ffffffffc02028ec <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02028cc:	60ea                	ld	ra,152(sp)
ffffffffc02028ce:	644a                	ld	s0,144(sp)
ffffffffc02028d0:	855a                	mv	a0,s6
ffffffffc02028d2:	64aa                	ld	s1,136(sp)
ffffffffc02028d4:	690a                	ld	s2,128(sp)
ffffffffc02028d6:	79e6                	ld	s3,120(sp)
ffffffffc02028d8:	7a46                	ld	s4,112(sp)
ffffffffc02028da:	7aa6                	ld	s5,104(sp)
ffffffffc02028dc:	7b06                	ld	s6,96(sp)
ffffffffc02028de:	6be6                	ld	s7,88(sp)
ffffffffc02028e0:	6c46                	ld	s8,80(sp)
ffffffffc02028e2:	6ca6                	ld	s9,72(sp)
ffffffffc02028e4:	6d06                	ld	s10,64(sp)
ffffffffc02028e6:	7de2                	ld	s11,56(sp)
ffffffffc02028e8:	610d                	addi	sp,sp,160
ffffffffc02028ea:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028ec:	0000f797          	auipc	a5,0xf
ffffffffc02028f0:	b7c78793          	addi	a5,a5,-1156 # ffffffffc0211468 <sm>
ffffffffc02028f4:	639c                	ld	a5,0(a5)
ffffffffc02028f6:	00003517          	auipc	a0,0x3
ffffffffc02028fa:	f2250513          	addi	a0,a0,-222 # ffffffffc0205818 <default_pmm_manager+0x720>
    return listelm->next;
ffffffffc02028fe:	0000f417          	auipc	s0,0xf
ffffffffc0202902:	b8240413          	addi	s0,s0,-1150 # ffffffffc0211480 <free_area>
ffffffffc0202906:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202908:	4785                	li	a5,1
ffffffffc020290a:	0000f717          	auipc	a4,0xf
ffffffffc020290e:	b6f72323          	sw	a5,-1178(a4) # ffffffffc0211470 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202912:	facfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202916:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202918:	2e878a63          	beq	a5,s0,ffffffffc0202c0c <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020291c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202920:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202922:	8b05                	andi	a4,a4,1
ffffffffc0202924:	2e070863          	beqz	a4,ffffffffc0202c14 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc0202928:	4481                	li	s1,0
ffffffffc020292a:	4901                	li	s2,0
ffffffffc020292c:	a031                	j	ffffffffc0202938 <swap_init+0xbc>
ffffffffc020292e:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202932:	8b09                	andi	a4,a4,2
ffffffffc0202934:	2e070063          	beqz	a4,ffffffffc0202c14 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc0202938:	ff87a703          	lw	a4,-8(a5)
ffffffffc020293c:	679c                	ld	a5,8(a5)
ffffffffc020293e:	2905                	addiw	s2,s2,1
ffffffffc0202940:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202942:	fe8796e3          	bne	a5,s0,ffffffffc020292e <swap_init+0xb2>
ffffffffc0202946:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202948:	e55fe0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc020294c:	5b351863          	bne	a0,s3,ffffffffc0202efc <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202950:	8626                	mv	a2,s1
ffffffffc0202952:	85ca                	mv	a1,s2
ffffffffc0202954:	00003517          	auipc	a0,0x3
ffffffffc0202958:	edc50513          	addi	a0,a0,-292 # ffffffffc0205830 <default_pmm_manager+0x738>
ffffffffc020295c:	f62fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202960:	323000ef          	jal	ra,ffffffffc0203482 <mm_create>
ffffffffc0202964:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202966:	50050b63          	beqz	a0,ffffffffc0202e7c <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020296a:	0000f797          	auipc	a5,0xf
ffffffffc020296e:	d1e78793          	addi	a5,a5,-738 # ffffffffc0211688 <check_mm_struct>
ffffffffc0202972:	639c                	ld	a5,0(a5)
ffffffffc0202974:	52079463          	bnez	a5,ffffffffc0202e9c <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202978:	0000f797          	auipc	a5,0xf
ffffffffc020297c:	ae078793          	addi	a5,a5,-1312 # ffffffffc0211458 <boot_pgdir>
ffffffffc0202980:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0202982:	0000f797          	auipc	a5,0xf
ffffffffc0202986:	d0a7b323          	sd	a0,-762(a5) # ffffffffc0211688 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020298a:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020298c:	ec3a                	sd	a4,24(sp)
ffffffffc020298e:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202990:	52079663          	bnez	a5,ffffffffc0202ebc <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202994:	6599                	lui	a1,0x6
ffffffffc0202996:	460d                	li	a2,3
ffffffffc0202998:	6505                	lui	a0,0x1
ffffffffc020299a:	335000ef          	jal	ra,ffffffffc02034ce <vma_create>
ffffffffc020299e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02029a0:	52050e63          	beqz	a0,ffffffffc0202edc <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc02029a4:	855e                	mv	a0,s7
ffffffffc02029a6:	395000ef          	jal	ra,ffffffffc020353a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02029aa:	00003517          	auipc	a0,0x3
ffffffffc02029ae:	ef650513          	addi	a0,a0,-266 # ffffffffc02058a0 <default_pmm_manager+0x7a8>
ffffffffc02029b2:	f0cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02029b6:	018bb503          	ld	a0,24(s7)
ffffffffc02029ba:	4605                	li	a2,1
ffffffffc02029bc:	6585                	lui	a1,0x1
ffffffffc02029be:	e1ffe0ef          	jal	ra,ffffffffc02017dc <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02029c2:	40050d63          	beqz	a0,ffffffffc0202ddc <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02029c6:	00003517          	auipc	a0,0x3
ffffffffc02029ca:	f2a50513          	addi	a0,a0,-214 # ffffffffc02058f0 <default_pmm_manager+0x7f8>
ffffffffc02029ce:	0000fa17          	auipc	s4,0xf
ffffffffc02029d2:	bdaa0a13          	addi	s4,s4,-1062 # ffffffffc02115a8 <check_rp>
ffffffffc02029d6:	ee8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029da:	0000fa97          	auipc	s5,0xf
ffffffffc02029de:	beea8a93          	addi	s5,s5,-1042 # ffffffffc02115c8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02029e2:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc02029e4:	4505                	li	a0,1
ffffffffc02029e6:	ce9fe0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc02029ea:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6e970>
          assert(check_rp[i] != NULL );
ffffffffc02029ee:	2a050b63          	beqz	a0,ffffffffc0202ca4 <swap_init+0x428>
ffffffffc02029f2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02029f4:	8b89                	andi	a5,a5,2
ffffffffc02029f6:	28079763          	bnez	a5,ffffffffc0202c84 <swap_init+0x408>
ffffffffc02029fa:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029fc:	ff5994e3          	bne	s3,s5,ffffffffc02029e4 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202a00:	601c                	ld	a5,0(s0)
ffffffffc0202a02:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202a06:	0000fd17          	auipc	s10,0xf
ffffffffc0202a0a:	ba2d0d13          	addi	s10,s10,-1118 # ffffffffc02115a8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202a0e:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202a10:	481c                	lw	a5,16(s0)
ffffffffc0202a12:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202a14:	0000f797          	auipc	a5,0xf
ffffffffc0202a18:	a687ba23          	sd	s0,-1420(a5) # ffffffffc0211488 <free_area+0x8>
ffffffffc0202a1c:	0000f797          	auipc	a5,0xf
ffffffffc0202a20:	a687b223          	sd	s0,-1436(a5) # ffffffffc0211480 <free_area>
     nr_free = 0;
ffffffffc0202a24:	0000f797          	auipc	a5,0xf
ffffffffc0202a28:	a607a623          	sw	zero,-1428(a5) # ffffffffc0211490 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202a2c:	000d3503          	ld	a0,0(s10)
ffffffffc0202a30:	4585                	li	a1,1
ffffffffc0202a32:	0d21                	addi	s10,s10,8
ffffffffc0202a34:	d23fe0ef          	jal	ra,ffffffffc0201756 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a38:	ff5d1ae3          	bne	s10,s5,ffffffffc0202a2c <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202a3c:	01042d03          	lw	s10,16(s0)
ffffffffc0202a40:	4791                	li	a5,4
ffffffffc0202a42:	36fd1d63          	bne	s10,a5,ffffffffc0202dbc <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202a46:	00003517          	auipc	a0,0x3
ffffffffc0202a4a:	f3250513          	addi	a0,a0,-206 # ffffffffc0205978 <default_pmm_manager+0x880>
ffffffffc0202a4e:	e70fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a52:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202a54:	0000f797          	auipc	a5,0xf
ffffffffc0202a58:	a207a023          	sw	zero,-1504(a5) # ffffffffc0211474 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a5c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202a5e:	0000f797          	auipc	a5,0xf
ffffffffc0202a62:	a1678793          	addi	a5,a5,-1514 # ffffffffc0211474 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a66:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202a6a:	4398                	lw	a4,0(a5)
ffffffffc0202a6c:	4585                	li	a1,1
ffffffffc0202a6e:	2701                	sext.w	a4,a4
ffffffffc0202a70:	30b71663          	bne	a4,a1,ffffffffc0202d7c <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202a74:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202a78:	4394                	lw	a3,0(a5)
ffffffffc0202a7a:	2681                	sext.w	a3,a3
ffffffffc0202a7c:	32e69063          	bne	a3,a4,ffffffffc0202d9c <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202a80:	6689                	lui	a3,0x2
ffffffffc0202a82:	462d                	li	a2,11
ffffffffc0202a84:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202a88:	4398                	lw	a4,0(a5)
ffffffffc0202a8a:	4589                	li	a1,2
ffffffffc0202a8c:	2701                	sext.w	a4,a4
ffffffffc0202a8e:	26b71763          	bne	a4,a1,ffffffffc0202cfc <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202a92:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202a96:	4394                	lw	a3,0(a5)
ffffffffc0202a98:	2681                	sext.w	a3,a3
ffffffffc0202a9a:	28e69163          	bne	a3,a4,ffffffffc0202d1c <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202a9e:	668d                	lui	a3,0x3
ffffffffc0202aa0:	4631                	li	a2,12
ffffffffc0202aa2:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202aa6:	4398                	lw	a4,0(a5)
ffffffffc0202aa8:	458d                	li	a1,3
ffffffffc0202aaa:	2701                	sext.w	a4,a4
ffffffffc0202aac:	28b71863          	bne	a4,a1,ffffffffc0202d3c <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202ab0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202ab4:	4394                	lw	a3,0(a5)
ffffffffc0202ab6:	2681                	sext.w	a3,a3
ffffffffc0202ab8:	2ae69263          	bne	a3,a4,ffffffffc0202d5c <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202abc:	6691                	lui	a3,0x4
ffffffffc0202abe:	4635                	li	a2,13
ffffffffc0202ac0:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202ac4:	4398                	lw	a4,0(a5)
ffffffffc0202ac6:	2701                	sext.w	a4,a4
ffffffffc0202ac8:	33a71a63          	bne	a4,s10,ffffffffc0202dfc <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202acc:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202ad0:	439c                	lw	a5,0(a5)
ffffffffc0202ad2:	2781                	sext.w	a5,a5
ffffffffc0202ad4:	34e79463          	bne	a5,a4,ffffffffc0202e1c <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202ad8:	481c                	lw	a5,16(s0)
ffffffffc0202ada:	36079163          	bnez	a5,ffffffffc0202e3c <swap_init+0x5c0>
ffffffffc0202ade:	0000f797          	auipc	a5,0xf
ffffffffc0202ae2:	aea78793          	addi	a5,a5,-1302 # ffffffffc02115c8 <swap_in_seq_no>
ffffffffc0202ae6:	0000f717          	auipc	a4,0xf
ffffffffc0202aea:	b0a70713          	addi	a4,a4,-1270 # ffffffffc02115f0 <swap_out_seq_no>
ffffffffc0202aee:	0000f617          	auipc	a2,0xf
ffffffffc0202af2:	b0260613          	addi	a2,a2,-1278 # ffffffffc02115f0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202af6:	56fd                	li	a3,-1
ffffffffc0202af8:	c394                	sw	a3,0(a5)
ffffffffc0202afa:	c314                	sw	a3,0(a4)
ffffffffc0202afc:	0791                	addi	a5,a5,4
ffffffffc0202afe:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202b00:	fec79ce3          	bne	a5,a2,ffffffffc0202af8 <swap_init+0x27c>
ffffffffc0202b04:	0000f697          	auipc	a3,0xf
ffffffffc0202b08:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0211650 <check_ptep>
ffffffffc0202b0c:	0000f817          	auipc	a6,0xf
ffffffffc0202b10:	a9c80813          	addi	a6,a6,-1380 # ffffffffc02115a8 <check_rp>
ffffffffc0202b14:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202b16:	0000fc97          	auipc	s9,0xf
ffffffffc0202b1a:	94ac8c93          	addi	s9,s9,-1718 # ffffffffc0211460 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b1e:	0000fd97          	auipc	s11,0xf
ffffffffc0202b22:	a82d8d93          	addi	s11,s11,-1406 # ffffffffc02115a0 <pages>
ffffffffc0202b26:	00003d17          	auipc	s10,0x3
ffffffffc0202b2a:	6bad0d13          	addi	s10,s10,1722 # ffffffffc02061e0 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b2e:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202b30:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b34:	4601                	li	a2,0
ffffffffc0202b36:	85e2                	mv	a1,s8
ffffffffc0202b38:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202b3a:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b3c:	ca1fe0ef          	jal	ra,ffffffffc02017dc <get_pte>
ffffffffc0202b40:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202b42:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b44:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202b46:	16050f63          	beqz	a0,ffffffffc0202cc4 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202b4a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202b4c:	0017f613          	andi	a2,a5,1
ffffffffc0202b50:	10060263          	beqz	a2,ffffffffc0202c54 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202b54:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b58:	078a                	slli	a5,a5,0x2
ffffffffc0202b5a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b5c:	10c7f863          	bleu	a2,a5,ffffffffc0202c6c <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b60:	000d3603          	ld	a2,0(s10)
ffffffffc0202b64:	000db583          	ld	a1,0(s11)
ffffffffc0202b68:	00083503          	ld	a0,0(a6)
ffffffffc0202b6c:	8f91                	sub	a5,a5,a2
ffffffffc0202b6e:	00379613          	slli	a2,a5,0x3
ffffffffc0202b72:	97b2                	add	a5,a5,a2
ffffffffc0202b74:	078e                	slli	a5,a5,0x3
ffffffffc0202b76:	97ae                	add	a5,a5,a1
ffffffffc0202b78:	0af51e63          	bne	a0,a5,ffffffffc0202c34 <swap_init+0x3b8>
ffffffffc0202b7c:	6785                	lui	a5,0x1
ffffffffc0202b7e:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b80:	6795                	lui	a5,0x5
ffffffffc0202b82:	06a1                	addi	a3,a3,8
ffffffffc0202b84:	0821                	addi	a6,a6,8
ffffffffc0202b86:	fafc14e3          	bne	s8,a5,ffffffffc0202b2e <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202b8a:	00003517          	auipc	a0,0x3
ffffffffc0202b8e:	e9650513          	addi	a0,a0,-362 # ffffffffc0205a20 <default_pmm_manager+0x928>
ffffffffc0202b92:	d2cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202b96:	0000f797          	auipc	a5,0xf
ffffffffc0202b9a:	8d278793          	addi	a5,a5,-1838 # ffffffffc0211468 <sm>
ffffffffc0202b9e:	639c                	ld	a5,0(a5)
ffffffffc0202ba0:	7f9c                	ld	a5,56(a5)
ffffffffc0202ba2:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202ba4:	2a051c63          	bnez	a0,ffffffffc0202e5c <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202ba8:	000a3503          	ld	a0,0(s4)
ffffffffc0202bac:	4585                	li	a1,1
ffffffffc0202bae:	0a21                	addi	s4,s4,8
ffffffffc0202bb0:	ba7fe0ef          	jal	ra,ffffffffc0201756 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202bb4:	ff5a1ae3          	bne	s4,s5,ffffffffc0202ba8 <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202bb8:	855e                	mv	a0,s7
ffffffffc0202bba:	24f000ef          	jal	ra,ffffffffc0203608 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202bbe:	77a2                	ld	a5,40(sp)
ffffffffc0202bc0:	0000f717          	auipc	a4,0xf
ffffffffc0202bc4:	8cf72823          	sw	a5,-1840(a4) # ffffffffc0211490 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202bc8:	7782                	ld	a5,32(sp)
ffffffffc0202bca:	0000f717          	auipc	a4,0xf
ffffffffc0202bce:	8af73b23          	sd	a5,-1866(a4) # ffffffffc0211480 <free_area>
ffffffffc0202bd2:	0000f797          	auipc	a5,0xf
ffffffffc0202bd6:	8b37bb23          	sd	s3,-1866(a5) # ffffffffc0211488 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bda:	00898a63          	beq	s3,s0,ffffffffc0202bee <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202bde:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202be2:	0089b983          	ld	s3,8(s3)
ffffffffc0202be6:	397d                	addiw	s2,s2,-1
ffffffffc0202be8:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bea:	fe899ae3          	bne	s3,s0,ffffffffc0202bde <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202bee:	8626                	mv	a2,s1
ffffffffc0202bf0:	85ca                	mv	a1,s2
ffffffffc0202bf2:	00003517          	auipc	a0,0x3
ffffffffc0202bf6:	e5e50513          	addi	a0,a0,-418 # ffffffffc0205a50 <default_pmm_manager+0x958>
ffffffffc0202bfa:	cc4fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202bfe:	00003517          	auipc	a0,0x3
ffffffffc0202c02:	e7250513          	addi	a0,a0,-398 # ffffffffc0205a70 <default_pmm_manager+0x978>
ffffffffc0202c06:	cb8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202c0a:	b1c9                	j	ffffffffc02028cc <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202c0c:	4481                	li	s1,0
ffffffffc0202c0e:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c10:	4981                	li	s3,0
ffffffffc0202c12:	bb1d                	j	ffffffffc0202948 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202c14:	00002697          	auipc	a3,0x2
ffffffffc0202c18:	13c68693          	addi	a3,a3,316 # ffffffffc0204d50 <commands+0x8c8>
ffffffffc0202c1c:	00002617          	auipc	a2,0x2
ffffffffc0202c20:	14460613          	addi	a2,a2,324 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202c24:	0bc00593          	li	a1,188
ffffffffc0202c28:	00003517          	auipc	a0,0x3
ffffffffc0202c2c:	be050513          	addi	a0,a0,-1056 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202c30:	f44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c34:	00003697          	auipc	a3,0x3
ffffffffc0202c38:	dc468693          	addi	a3,a3,-572 # ffffffffc02059f8 <default_pmm_manager+0x900>
ffffffffc0202c3c:	00002617          	auipc	a2,0x2
ffffffffc0202c40:	12460613          	addi	a2,a2,292 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202c44:	0fc00593          	li	a1,252
ffffffffc0202c48:	00003517          	auipc	a0,0x3
ffffffffc0202c4c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202c50:	f24fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202c54:	00002617          	auipc	a2,0x2
ffffffffc0202c58:	76460613          	addi	a2,a2,1892 # ffffffffc02053b8 <default_pmm_manager+0x2c0>
ffffffffc0202c5c:	07000593          	li	a1,112
ffffffffc0202c60:	00002517          	auipc	a0,0x2
ffffffffc0202c64:	58050513          	addi	a0,a0,1408 # ffffffffc02051e0 <default_pmm_manager+0xe8>
ffffffffc0202c68:	f0cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202c6c:	00002617          	auipc	a2,0x2
ffffffffc0202c70:	55460613          	addi	a2,a2,1364 # ffffffffc02051c0 <default_pmm_manager+0xc8>
ffffffffc0202c74:	06500593          	li	a1,101
ffffffffc0202c78:	00002517          	auipc	a0,0x2
ffffffffc0202c7c:	56850513          	addi	a0,a0,1384 # ffffffffc02051e0 <default_pmm_manager+0xe8>
ffffffffc0202c80:	ef4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c84:	00003697          	auipc	a3,0x3
ffffffffc0202c88:	cac68693          	addi	a3,a3,-852 # ffffffffc0205930 <default_pmm_manager+0x838>
ffffffffc0202c8c:	00002617          	auipc	a2,0x2
ffffffffc0202c90:	0d460613          	addi	a2,a2,212 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202c94:	0dd00593          	li	a1,221
ffffffffc0202c98:	00003517          	auipc	a0,0x3
ffffffffc0202c9c:	b7050513          	addi	a0,a0,-1168 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202ca0:	ed4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202ca4:	00003697          	auipc	a3,0x3
ffffffffc0202ca8:	c7468693          	addi	a3,a3,-908 # ffffffffc0205918 <default_pmm_manager+0x820>
ffffffffc0202cac:	00002617          	auipc	a2,0x2
ffffffffc0202cb0:	0b460613          	addi	a2,a2,180 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202cb4:	0dc00593          	li	a1,220
ffffffffc0202cb8:	00003517          	auipc	a0,0x3
ffffffffc0202cbc:	b5050513          	addi	a0,a0,-1200 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202cc0:	eb4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202cc4:	00003697          	auipc	a3,0x3
ffffffffc0202cc8:	d1c68693          	addi	a3,a3,-740 # ffffffffc02059e0 <default_pmm_manager+0x8e8>
ffffffffc0202ccc:	00002617          	auipc	a2,0x2
ffffffffc0202cd0:	09460613          	addi	a2,a2,148 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202cd4:	0fb00593          	li	a1,251
ffffffffc0202cd8:	00003517          	auipc	a0,0x3
ffffffffc0202cdc:	b3050513          	addi	a0,a0,-1232 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202ce0:	e94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202ce4:	00003617          	auipc	a2,0x3
ffffffffc0202ce8:	b0460613          	addi	a2,a2,-1276 # ffffffffc02057e8 <default_pmm_manager+0x6f0>
ffffffffc0202cec:	02700593          	li	a1,39
ffffffffc0202cf0:	00003517          	auipc	a0,0x3
ffffffffc0202cf4:	b1850513          	addi	a0,a0,-1256 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202cf8:	e7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202cfc:	00003697          	auipc	a3,0x3
ffffffffc0202d00:	cb468693          	addi	a3,a3,-844 # ffffffffc02059b0 <default_pmm_manager+0x8b8>
ffffffffc0202d04:	00002617          	auipc	a2,0x2
ffffffffc0202d08:	05c60613          	addi	a2,a2,92 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202d0c:	09700593          	li	a1,151
ffffffffc0202d10:	00003517          	auipc	a0,0x3
ffffffffc0202d14:	af850513          	addi	a0,a0,-1288 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202d18:	e5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202d1c:	00003697          	auipc	a3,0x3
ffffffffc0202d20:	c9468693          	addi	a3,a3,-876 # ffffffffc02059b0 <default_pmm_manager+0x8b8>
ffffffffc0202d24:	00002617          	auipc	a2,0x2
ffffffffc0202d28:	03c60613          	addi	a2,a2,60 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202d2c:	09900593          	li	a1,153
ffffffffc0202d30:	00003517          	auipc	a0,0x3
ffffffffc0202d34:	ad850513          	addi	a0,a0,-1320 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202d38:	e3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202d3c:	00003697          	auipc	a3,0x3
ffffffffc0202d40:	c8468693          	addi	a3,a3,-892 # ffffffffc02059c0 <default_pmm_manager+0x8c8>
ffffffffc0202d44:	00002617          	auipc	a2,0x2
ffffffffc0202d48:	01c60613          	addi	a2,a2,28 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202d4c:	09b00593          	li	a1,155
ffffffffc0202d50:	00003517          	auipc	a0,0x3
ffffffffc0202d54:	ab850513          	addi	a0,a0,-1352 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202d58:	e1cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202d5c:	00003697          	auipc	a3,0x3
ffffffffc0202d60:	c6468693          	addi	a3,a3,-924 # ffffffffc02059c0 <default_pmm_manager+0x8c8>
ffffffffc0202d64:	00002617          	auipc	a2,0x2
ffffffffc0202d68:	ffc60613          	addi	a2,a2,-4 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202d6c:	09d00593          	li	a1,157
ffffffffc0202d70:	00003517          	auipc	a0,0x3
ffffffffc0202d74:	a9850513          	addi	a0,a0,-1384 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202d78:	dfcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d7c:	00003697          	auipc	a3,0x3
ffffffffc0202d80:	c2468693          	addi	a3,a3,-988 # ffffffffc02059a0 <default_pmm_manager+0x8a8>
ffffffffc0202d84:	00002617          	auipc	a2,0x2
ffffffffc0202d88:	fdc60613          	addi	a2,a2,-36 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202d8c:	09300593          	li	a1,147
ffffffffc0202d90:	00003517          	auipc	a0,0x3
ffffffffc0202d94:	a7850513          	addi	a0,a0,-1416 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202d98:	ddcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d9c:	00003697          	auipc	a3,0x3
ffffffffc0202da0:	c0468693          	addi	a3,a3,-1020 # ffffffffc02059a0 <default_pmm_manager+0x8a8>
ffffffffc0202da4:	00002617          	auipc	a2,0x2
ffffffffc0202da8:	fbc60613          	addi	a2,a2,-68 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202dac:	09500593          	li	a1,149
ffffffffc0202db0:	00003517          	auipc	a0,0x3
ffffffffc0202db4:	a5850513          	addi	a0,a0,-1448 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202db8:	dbcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202dbc:	00003697          	auipc	a3,0x3
ffffffffc0202dc0:	b9468693          	addi	a3,a3,-1132 # ffffffffc0205950 <default_pmm_manager+0x858>
ffffffffc0202dc4:	00002617          	auipc	a2,0x2
ffffffffc0202dc8:	f9c60613          	addi	a2,a2,-100 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202dcc:	0ea00593          	li	a1,234
ffffffffc0202dd0:	00003517          	auipc	a0,0x3
ffffffffc0202dd4:	a3850513          	addi	a0,a0,-1480 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202dd8:	d9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202ddc:	00003697          	auipc	a3,0x3
ffffffffc0202de0:	afc68693          	addi	a3,a3,-1284 # ffffffffc02058d8 <default_pmm_manager+0x7e0>
ffffffffc0202de4:	00002617          	auipc	a2,0x2
ffffffffc0202de8:	f7c60613          	addi	a2,a2,-132 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202dec:	0d700593          	li	a1,215
ffffffffc0202df0:	00003517          	auipc	a0,0x3
ffffffffc0202df4:	a1850513          	addi	a0,a0,-1512 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202df8:	d7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202dfc:	00003697          	auipc	a3,0x3
ffffffffc0202e00:	bd468693          	addi	a3,a3,-1068 # ffffffffc02059d0 <default_pmm_manager+0x8d8>
ffffffffc0202e04:	00002617          	auipc	a2,0x2
ffffffffc0202e08:	f5c60613          	addi	a2,a2,-164 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202e0c:	09f00593          	li	a1,159
ffffffffc0202e10:	00003517          	auipc	a0,0x3
ffffffffc0202e14:	9f850513          	addi	a0,a0,-1544 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202e18:	d5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202e1c:	00003697          	auipc	a3,0x3
ffffffffc0202e20:	bb468693          	addi	a3,a3,-1100 # ffffffffc02059d0 <default_pmm_manager+0x8d8>
ffffffffc0202e24:	00002617          	auipc	a2,0x2
ffffffffc0202e28:	f3c60613          	addi	a2,a2,-196 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202e2c:	0a100593          	li	a1,161
ffffffffc0202e30:	00003517          	auipc	a0,0x3
ffffffffc0202e34:	9d850513          	addi	a0,a0,-1576 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202e38:	d3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202e3c:	00002697          	auipc	a3,0x2
ffffffffc0202e40:	0fc68693          	addi	a3,a3,252 # ffffffffc0204f38 <commands+0xab0>
ffffffffc0202e44:	00002617          	auipc	a2,0x2
ffffffffc0202e48:	f1c60613          	addi	a2,a2,-228 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202e4c:	0f300593          	li	a1,243
ffffffffc0202e50:	00003517          	auipc	a0,0x3
ffffffffc0202e54:	9b850513          	addi	a0,a0,-1608 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202e58:	d1cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202e5c:	00003697          	auipc	a3,0x3
ffffffffc0202e60:	bec68693          	addi	a3,a3,-1044 # ffffffffc0205a48 <default_pmm_manager+0x950>
ffffffffc0202e64:	00002617          	auipc	a2,0x2
ffffffffc0202e68:	efc60613          	addi	a2,a2,-260 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202e6c:	10200593          	li	a1,258
ffffffffc0202e70:	00003517          	auipc	a0,0x3
ffffffffc0202e74:	99850513          	addi	a0,a0,-1640 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202e78:	cfcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202e7c:	00003697          	auipc	a3,0x3
ffffffffc0202e80:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0205858 <default_pmm_manager+0x760>
ffffffffc0202e84:	00002617          	auipc	a2,0x2
ffffffffc0202e88:	edc60613          	addi	a2,a2,-292 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202e8c:	0c400593          	li	a1,196
ffffffffc0202e90:	00003517          	auipc	a0,0x3
ffffffffc0202e94:	97850513          	addi	a0,a0,-1672 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202e98:	cdcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202e9c:	00003697          	auipc	a3,0x3
ffffffffc0202ea0:	9cc68693          	addi	a3,a3,-1588 # ffffffffc0205868 <default_pmm_manager+0x770>
ffffffffc0202ea4:	00002617          	auipc	a2,0x2
ffffffffc0202ea8:	ebc60613          	addi	a2,a2,-324 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202eac:	0c700593          	li	a1,199
ffffffffc0202eb0:	00003517          	auipc	a0,0x3
ffffffffc0202eb4:	95850513          	addi	a0,a0,-1704 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202eb8:	cbcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202ebc:	00003697          	auipc	a3,0x3
ffffffffc0202ec0:	9c468693          	addi	a3,a3,-1596 # ffffffffc0205880 <default_pmm_manager+0x788>
ffffffffc0202ec4:	00002617          	auipc	a2,0x2
ffffffffc0202ec8:	e9c60613          	addi	a2,a2,-356 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202ecc:	0cc00593          	li	a1,204
ffffffffc0202ed0:	00003517          	auipc	a0,0x3
ffffffffc0202ed4:	93850513          	addi	a0,a0,-1736 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202ed8:	c9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202edc:	00003697          	auipc	a3,0x3
ffffffffc0202ee0:	9b468693          	addi	a3,a3,-1612 # ffffffffc0205890 <default_pmm_manager+0x798>
ffffffffc0202ee4:	00002617          	auipc	a2,0x2
ffffffffc0202ee8:	e7c60613          	addi	a2,a2,-388 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202eec:	0cf00593          	li	a1,207
ffffffffc0202ef0:	00003517          	auipc	a0,0x3
ffffffffc0202ef4:	91850513          	addi	a0,a0,-1768 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202ef8:	c7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202efc:	00002697          	auipc	a3,0x2
ffffffffc0202f00:	e9468693          	addi	a3,a3,-364 # ffffffffc0204d90 <commands+0x908>
ffffffffc0202f04:	00002617          	auipc	a2,0x2
ffffffffc0202f08:	e5c60613          	addi	a2,a2,-420 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0202f0c:	0bf00593          	li	a1,191
ffffffffc0202f10:	00003517          	auipc	a0,0x3
ffffffffc0202f14:	8f850513          	addi	a0,a0,-1800 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc0202f18:	c5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202f1c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202f1c:	0000e797          	auipc	a5,0xe
ffffffffc0202f20:	54c78793          	addi	a5,a5,1356 # ffffffffc0211468 <sm>
ffffffffc0202f24:	639c                	ld	a5,0(a5)
ffffffffc0202f26:	0107b303          	ld	t1,16(a5)
ffffffffc0202f2a:	8302                	jr	t1

ffffffffc0202f2c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202f2c:	0000e797          	auipc	a5,0xe
ffffffffc0202f30:	53c78793          	addi	a5,a5,1340 # ffffffffc0211468 <sm>
ffffffffc0202f34:	639c                	ld	a5,0(a5)
ffffffffc0202f36:	0207b303          	ld	t1,32(a5)
ffffffffc0202f3a:	8302                	jr	t1

ffffffffc0202f3c <swap_out>:
{
ffffffffc0202f3c:	711d                	addi	sp,sp,-96
ffffffffc0202f3e:	ec86                	sd	ra,88(sp)
ffffffffc0202f40:	e8a2                	sd	s0,80(sp)
ffffffffc0202f42:	e4a6                	sd	s1,72(sp)
ffffffffc0202f44:	e0ca                	sd	s2,64(sp)
ffffffffc0202f46:	fc4e                	sd	s3,56(sp)
ffffffffc0202f48:	f852                	sd	s4,48(sp)
ffffffffc0202f4a:	f456                	sd	s5,40(sp)
ffffffffc0202f4c:	f05a                	sd	s6,32(sp)
ffffffffc0202f4e:	ec5e                	sd	s7,24(sp)
ffffffffc0202f50:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202f52:	cde9                	beqz	a1,ffffffffc020302c <swap_out+0xf0>
ffffffffc0202f54:	8ab2                	mv	s5,a2
ffffffffc0202f56:	892a                	mv	s2,a0
ffffffffc0202f58:	8a2e                	mv	s4,a1
ffffffffc0202f5a:	4401                	li	s0,0
ffffffffc0202f5c:	0000e997          	auipc	s3,0xe
ffffffffc0202f60:	50c98993          	addi	s3,s3,1292 # ffffffffc0211468 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f64:	00003b17          	auipc	s6,0x3
ffffffffc0202f68:	b8cb0b13          	addi	s6,s6,-1140 # ffffffffc0205af0 <default_pmm_manager+0x9f8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f6c:	00003b97          	auipc	s7,0x3
ffffffffc0202f70:	b6cb8b93          	addi	s7,s7,-1172 # ffffffffc0205ad8 <default_pmm_manager+0x9e0>
ffffffffc0202f74:	a825                	j	ffffffffc0202fac <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f76:	67a2                	ld	a5,8(sp)
ffffffffc0202f78:	8626                	mv	a2,s1
ffffffffc0202f7a:	85a2                	mv	a1,s0
ffffffffc0202f7c:	63b4                	ld	a3,64(a5)
ffffffffc0202f7e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202f80:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f82:	82b1                	srli	a3,a3,0xc
ffffffffc0202f84:	0685                	addi	a3,a3,1
ffffffffc0202f86:	938fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f8a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202f8c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f8e:	613c                	ld	a5,64(a0)
ffffffffc0202f90:	83b1                	srli	a5,a5,0xc
ffffffffc0202f92:	0785                	addi	a5,a5,1
ffffffffc0202f94:	07a2                	slli	a5,a5,0x8
ffffffffc0202f96:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202f9a:	fbcfe0ef          	jal	ra,ffffffffc0201756 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202f9e:	01893503          	ld	a0,24(s2)
ffffffffc0202fa2:	85a6                	mv	a1,s1
ffffffffc0202fa4:	ebeff0ef          	jal	ra,ffffffffc0202662 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202fa8:	048a0d63          	beq	s4,s0,ffffffffc0203002 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202fac:	0009b783          	ld	a5,0(s3)
ffffffffc0202fb0:	8656                	mv	a2,s5
ffffffffc0202fb2:	002c                	addi	a1,sp,8
ffffffffc0202fb4:	7b9c                	ld	a5,48(a5)
ffffffffc0202fb6:	854a                	mv	a0,s2
ffffffffc0202fb8:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202fba:	e12d                	bnez	a0,ffffffffc020301c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202fbc:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fbe:	01893503          	ld	a0,24(s2)
ffffffffc0202fc2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202fc4:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fc6:	85a6                	mv	a1,s1
ffffffffc0202fc8:	815fe0ef          	jal	ra,ffffffffc02017dc <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fcc:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fce:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fd0:	8b85                	andi	a5,a5,1
ffffffffc0202fd2:	cfb9                	beqz	a5,ffffffffc0203030 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202fd4:	65a2                	ld	a1,8(sp)
ffffffffc0202fd6:	61bc                	ld	a5,64(a1)
ffffffffc0202fd8:	83b1                	srli	a5,a5,0xc
ffffffffc0202fda:	00178513          	addi	a0,a5,1
ffffffffc0202fde:	0522                	slli	a0,a0,0x8
ffffffffc0202fe0:	557000ef          	jal	ra,ffffffffc0203d36 <swapfs_write>
ffffffffc0202fe4:	d949                	beqz	a0,ffffffffc0202f76 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202fe6:	855e                	mv	a0,s7
ffffffffc0202fe8:	8d6fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fec:	0009b783          	ld	a5,0(s3)
ffffffffc0202ff0:	6622                	ld	a2,8(sp)
ffffffffc0202ff2:	4681                	li	a3,0
ffffffffc0202ff4:	739c                	ld	a5,32(a5)
ffffffffc0202ff6:	85a6                	mv	a1,s1
ffffffffc0202ff8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202ffa:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202ffc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202ffe:	fa8a17e3          	bne	s4,s0,ffffffffc0202fac <swap_out+0x70>
}
ffffffffc0203002:	8522                	mv	a0,s0
ffffffffc0203004:	60e6                	ld	ra,88(sp)
ffffffffc0203006:	6446                	ld	s0,80(sp)
ffffffffc0203008:	64a6                	ld	s1,72(sp)
ffffffffc020300a:	6906                	ld	s2,64(sp)
ffffffffc020300c:	79e2                	ld	s3,56(sp)
ffffffffc020300e:	7a42                	ld	s4,48(sp)
ffffffffc0203010:	7aa2                	ld	s5,40(sp)
ffffffffc0203012:	7b02                	ld	s6,32(sp)
ffffffffc0203014:	6be2                	ld	s7,24(sp)
ffffffffc0203016:	6c42                	ld	s8,16(sp)
ffffffffc0203018:	6125                	addi	sp,sp,96
ffffffffc020301a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020301c:	85a2                	mv	a1,s0
ffffffffc020301e:	00003517          	auipc	a0,0x3
ffffffffc0203022:	a7250513          	addi	a0,a0,-1422 # ffffffffc0205a90 <default_pmm_manager+0x998>
ffffffffc0203026:	898fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc020302a:	bfe1                	j	ffffffffc0203002 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020302c:	4401                	li	s0,0
ffffffffc020302e:	bfd1                	j	ffffffffc0203002 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203030:	00003697          	auipc	a3,0x3
ffffffffc0203034:	a9068693          	addi	a3,a3,-1392 # ffffffffc0205ac0 <default_pmm_manager+0x9c8>
ffffffffc0203038:	00002617          	auipc	a2,0x2
ffffffffc020303c:	d2860613          	addi	a2,a2,-728 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203040:	06800593          	li	a1,104
ffffffffc0203044:	00002517          	auipc	a0,0x2
ffffffffc0203048:	7c450513          	addi	a0,a0,1988 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc020304c:	b28fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203050 <swap_in>:
{
ffffffffc0203050:	7179                	addi	sp,sp,-48
ffffffffc0203052:	e84a                	sd	s2,16(sp)
ffffffffc0203054:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203056:	4505                	li	a0,1
{
ffffffffc0203058:	ec26                	sd	s1,24(sp)
ffffffffc020305a:	e44e                	sd	s3,8(sp)
ffffffffc020305c:	f406                	sd	ra,40(sp)
ffffffffc020305e:	f022                	sd	s0,32(sp)
ffffffffc0203060:	84ae                	mv	s1,a1
ffffffffc0203062:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203064:	e6afe0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
     assert(result!=NULL);
ffffffffc0203068:	c129                	beqz	a0,ffffffffc02030aa <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020306a:	842a                	mv	s0,a0
ffffffffc020306c:	01893503          	ld	a0,24(s2)
ffffffffc0203070:	4601                	li	a2,0
ffffffffc0203072:	85a6                	mv	a1,s1
ffffffffc0203074:	f68fe0ef          	jal	ra,ffffffffc02017dc <get_pte>
ffffffffc0203078:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020307a:	6108                	ld	a0,0(a0)
ffffffffc020307c:	85a2                	mv	a1,s0
ffffffffc020307e:	413000ef          	jal	ra,ffffffffc0203c90 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203082:	00093583          	ld	a1,0(s2)
ffffffffc0203086:	8626                	mv	a2,s1
ffffffffc0203088:	00002517          	auipc	a0,0x2
ffffffffc020308c:	72050513          	addi	a0,a0,1824 # ffffffffc02057a8 <default_pmm_manager+0x6b0>
ffffffffc0203090:	81a1                	srli	a1,a1,0x8
ffffffffc0203092:	82cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203096:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203098:	0089b023          	sd	s0,0(s3)
}
ffffffffc020309c:	7402                	ld	s0,32(sp)
ffffffffc020309e:	64e2                	ld	s1,24(sp)
ffffffffc02030a0:	6942                	ld	s2,16(sp)
ffffffffc02030a2:	69a2                	ld	s3,8(sp)
ffffffffc02030a4:	4501                	li	a0,0
ffffffffc02030a6:	6145                	addi	sp,sp,48
ffffffffc02030a8:	8082                	ret
     assert(result!=NULL);
ffffffffc02030aa:	00002697          	auipc	a3,0x2
ffffffffc02030ae:	6ee68693          	addi	a3,a3,1774 # ffffffffc0205798 <default_pmm_manager+0x6a0>
ffffffffc02030b2:	00002617          	auipc	a2,0x2
ffffffffc02030b6:	cae60613          	addi	a2,a2,-850 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02030ba:	07e00593          	li	a1,126
ffffffffc02030be:	00002517          	auipc	a0,0x2
ffffffffc02030c2:	74a50513          	addi	a0,a0,1866 # ffffffffc0205808 <default_pmm_manager+0x710>
ffffffffc02030c6:	aaefd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02030ca <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc02030ca:	4501                	li	a0,0
ffffffffc02030cc:	8082                	ret

ffffffffc02030ce <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02030ce:	4501                	li	a0,0
ffffffffc02030d0:	8082                	ret

ffffffffc02030d2 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02030d2:	4501                	li	a0,0
ffffffffc02030d4:	8082                	ret

ffffffffc02030d6 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc02030d6:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02030d8:	678d                	lui	a5,0x3
ffffffffc02030da:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc02030dc:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02030de:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02030e2:	0000e797          	auipc	a5,0xe
ffffffffc02030e6:	39278793          	addi	a5,a5,914 # ffffffffc0211474 <pgfault_num>
ffffffffc02030ea:	4398                	lw	a4,0(a5)
ffffffffc02030ec:	4691                	li	a3,4
ffffffffc02030ee:	2701                	sext.w	a4,a4
ffffffffc02030f0:	08d71f63          	bne	a4,a3,ffffffffc020318e <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02030f4:	6685                	lui	a3,0x1
ffffffffc02030f6:	4629                	li	a2,10
ffffffffc02030f8:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02030fc:	4394                	lw	a3,0(a5)
ffffffffc02030fe:	2681                	sext.w	a3,a3
ffffffffc0203100:	20e69763          	bne	a3,a4,ffffffffc020330e <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203104:	6711                	lui	a4,0x4
ffffffffc0203106:	4635                	li	a2,13
ffffffffc0203108:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc020310c:	4398                	lw	a4,0(a5)
ffffffffc020310e:	2701                	sext.w	a4,a4
ffffffffc0203110:	1cd71f63          	bne	a4,a3,ffffffffc02032ee <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203114:	6689                	lui	a3,0x2
ffffffffc0203116:	462d                	li	a2,11
ffffffffc0203118:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020311c:	4394                	lw	a3,0(a5)
ffffffffc020311e:	2681                	sext.w	a3,a3
ffffffffc0203120:	1ae69763          	bne	a3,a4,ffffffffc02032ce <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203124:	6715                	lui	a4,0x5
ffffffffc0203126:	46b9                	li	a3,14
ffffffffc0203128:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020312c:	4398                	lw	a4,0(a5)
ffffffffc020312e:	4695                	li	a3,5
ffffffffc0203130:	2701                	sext.w	a4,a4
ffffffffc0203132:	16d71e63          	bne	a4,a3,ffffffffc02032ae <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc0203136:	4394                	lw	a3,0(a5)
ffffffffc0203138:	2681                	sext.w	a3,a3
ffffffffc020313a:	14e69a63          	bne	a3,a4,ffffffffc020328e <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc020313e:	4398                	lw	a4,0(a5)
ffffffffc0203140:	2701                	sext.w	a4,a4
ffffffffc0203142:	12d71663          	bne	a4,a3,ffffffffc020326e <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc0203146:	4394                	lw	a3,0(a5)
ffffffffc0203148:	2681                	sext.w	a3,a3
ffffffffc020314a:	10e69263          	bne	a3,a4,ffffffffc020324e <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc020314e:	4398                	lw	a4,0(a5)
ffffffffc0203150:	2701                	sext.w	a4,a4
ffffffffc0203152:	0cd71e63          	bne	a4,a3,ffffffffc020322e <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc0203156:	4394                	lw	a3,0(a5)
ffffffffc0203158:	2681                	sext.w	a3,a3
ffffffffc020315a:	0ae69a63          	bne	a3,a4,ffffffffc020320e <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020315e:	6715                	lui	a4,0x5
ffffffffc0203160:	46b9                	li	a3,14
ffffffffc0203162:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203166:	4398                	lw	a4,0(a5)
ffffffffc0203168:	4695                	li	a3,5
ffffffffc020316a:	2701                	sext.w	a4,a4
ffffffffc020316c:	08d71163          	bne	a4,a3,ffffffffc02031ee <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203170:	6705                	lui	a4,0x1
ffffffffc0203172:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203176:	4729                	li	a4,10
ffffffffc0203178:	04e69b63          	bne	a3,a4,ffffffffc02031ce <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc020317c:	439c                	lw	a5,0(a5)
ffffffffc020317e:	4719                	li	a4,6
ffffffffc0203180:	2781                	sext.w	a5,a5
ffffffffc0203182:	02e79663          	bne	a5,a4,ffffffffc02031ae <_clock_check_swap+0xd8>
}
ffffffffc0203186:	60a2                	ld	ra,8(sp)
ffffffffc0203188:	4501                	li	a0,0
ffffffffc020318a:	0141                	addi	sp,sp,16
ffffffffc020318c:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020318e:	00003697          	auipc	a3,0x3
ffffffffc0203192:	84268693          	addi	a3,a3,-1982 # ffffffffc02059d0 <default_pmm_manager+0x8d8>
ffffffffc0203196:	00002617          	auipc	a2,0x2
ffffffffc020319a:	bca60613          	addi	a2,a2,-1078 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020319e:	09400593          	li	a1,148
ffffffffc02031a2:	00003517          	auipc	a0,0x3
ffffffffc02031a6:	98e50513          	addi	a0,a0,-1650 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc02031aa:	9cafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==6);
ffffffffc02031ae:	00003697          	auipc	a3,0x3
ffffffffc02031b2:	9d268693          	addi	a3,a3,-1582 # ffffffffc0205b80 <default_pmm_manager+0xa88>
ffffffffc02031b6:	00002617          	auipc	a2,0x2
ffffffffc02031ba:	baa60613          	addi	a2,a2,-1110 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02031be:	0ab00593          	li	a1,171
ffffffffc02031c2:	00003517          	auipc	a0,0x3
ffffffffc02031c6:	96e50513          	addi	a0,a0,-1682 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc02031ca:	9aafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02031ce:	00003697          	auipc	a3,0x3
ffffffffc02031d2:	98a68693          	addi	a3,a3,-1654 # ffffffffc0205b58 <default_pmm_manager+0xa60>
ffffffffc02031d6:	00002617          	auipc	a2,0x2
ffffffffc02031da:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02031de:	0a900593          	li	a1,169
ffffffffc02031e2:	00003517          	auipc	a0,0x3
ffffffffc02031e6:	94e50513          	addi	a0,a0,-1714 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc02031ea:	98afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031ee:	00003697          	auipc	a3,0x3
ffffffffc02031f2:	95a68693          	addi	a3,a3,-1702 # ffffffffc0205b48 <default_pmm_manager+0xa50>
ffffffffc02031f6:	00002617          	auipc	a2,0x2
ffffffffc02031fa:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02031fe:	0a800593          	li	a1,168
ffffffffc0203202:	00003517          	auipc	a0,0x3
ffffffffc0203206:	92e50513          	addi	a0,a0,-1746 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc020320a:	96afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020320e:	00003697          	auipc	a3,0x3
ffffffffc0203212:	93a68693          	addi	a3,a3,-1734 # ffffffffc0205b48 <default_pmm_manager+0xa50>
ffffffffc0203216:	00002617          	auipc	a2,0x2
ffffffffc020321a:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020321e:	0a600593          	li	a1,166
ffffffffc0203222:	00003517          	auipc	a0,0x3
ffffffffc0203226:	90e50513          	addi	a0,a0,-1778 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc020322a:	94afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020322e:	00003697          	auipc	a3,0x3
ffffffffc0203232:	91a68693          	addi	a3,a3,-1766 # ffffffffc0205b48 <default_pmm_manager+0xa50>
ffffffffc0203236:	00002617          	auipc	a2,0x2
ffffffffc020323a:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020323e:	0a400593          	li	a1,164
ffffffffc0203242:	00003517          	auipc	a0,0x3
ffffffffc0203246:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc020324a:	92afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020324e:	00003697          	auipc	a3,0x3
ffffffffc0203252:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0205b48 <default_pmm_manager+0xa50>
ffffffffc0203256:	00002617          	auipc	a2,0x2
ffffffffc020325a:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020325e:	0a200593          	li	a1,162
ffffffffc0203262:	00003517          	auipc	a0,0x3
ffffffffc0203266:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc020326a:	90afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020326e:	00003697          	auipc	a3,0x3
ffffffffc0203272:	8da68693          	addi	a3,a3,-1830 # ffffffffc0205b48 <default_pmm_manager+0xa50>
ffffffffc0203276:	00002617          	auipc	a2,0x2
ffffffffc020327a:	aea60613          	addi	a2,a2,-1302 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020327e:	0a000593          	li	a1,160
ffffffffc0203282:	00003517          	auipc	a0,0x3
ffffffffc0203286:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc020328a:	8eafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020328e:	00003697          	auipc	a3,0x3
ffffffffc0203292:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0205b48 <default_pmm_manager+0xa50>
ffffffffc0203296:	00002617          	auipc	a2,0x2
ffffffffc020329a:	aca60613          	addi	a2,a2,-1334 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020329e:	09e00593          	li	a1,158
ffffffffc02032a2:	00003517          	auipc	a0,0x3
ffffffffc02032a6:	88e50513          	addi	a0,a0,-1906 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc02032aa:	8cafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02032ae:	00003697          	auipc	a3,0x3
ffffffffc02032b2:	89a68693          	addi	a3,a3,-1894 # ffffffffc0205b48 <default_pmm_manager+0xa50>
ffffffffc02032b6:	00002617          	auipc	a2,0x2
ffffffffc02032ba:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02032be:	09c00593          	li	a1,156
ffffffffc02032c2:	00003517          	auipc	a0,0x3
ffffffffc02032c6:	86e50513          	addi	a0,a0,-1938 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc02032ca:	8aafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02032ce:	00002697          	auipc	a3,0x2
ffffffffc02032d2:	70268693          	addi	a3,a3,1794 # ffffffffc02059d0 <default_pmm_manager+0x8d8>
ffffffffc02032d6:	00002617          	auipc	a2,0x2
ffffffffc02032da:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02032de:	09a00593          	li	a1,154
ffffffffc02032e2:	00003517          	auipc	a0,0x3
ffffffffc02032e6:	84e50513          	addi	a0,a0,-1970 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc02032ea:	88afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02032ee:	00002697          	auipc	a3,0x2
ffffffffc02032f2:	6e268693          	addi	a3,a3,1762 # ffffffffc02059d0 <default_pmm_manager+0x8d8>
ffffffffc02032f6:	00002617          	auipc	a2,0x2
ffffffffc02032fa:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02032fe:	09800593          	li	a1,152
ffffffffc0203302:	00003517          	auipc	a0,0x3
ffffffffc0203306:	82e50513          	addi	a0,a0,-2002 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc020330a:	86afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc020330e:	00002697          	auipc	a3,0x2
ffffffffc0203312:	6c268693          	addi	a3,a3,1730 # ffffffffc02059d0 <default_pmm_manager+0x8d8>
ffffffffc0203316:	00002617          	auipc	a2,0x2
ffffffffc020331a:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020331e:	09600593          	li	a1,150
ffffffffc0203322:	00003517          	auipc	a0,0x3
ffffffffc0203326:	80e50513          	addi	a0,a0,-2034 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc020332a:	84afd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020332e <_clock_init_mm>:
{     
ffffffffc020332e:	1141                	addi	sp,sp,-16
ffffffffc0203330:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0203332:	0000e797          	auipc	a5,0xe
ffffffffc0203336:	33e78793          	addi	a5,a5,830 # ffffffffc0211670 <pra_list_head>
     mm->sm_priv = &pra_list_head;
ffffffffc020333a:	f51c                	sd	a5,40(a0)
     cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
ffffffffc020333c:	85be                	mv	a1,a5
ffffffffc020333e:	00003517          	auipc	a0,0x3
ffffffffc0203342:	85250513          	addi	a0,a0,-1966 # ffffffffc0205b90 <default_pmm_manager+0xa98>
ffffffffc0203346:	e79c                	sd	a5,8(a5)
ffffffffc0203348:	e39c                	sd	a5,0(a5)
     curr_ptr=&pra_list_head;
ffffffffc020334a:	0000e717          	auipc	a4,0xe
ffffffffc020334e:	32f73b23          	sd	a5,822(a4) # ffffffffc0211680 <curr_ptr>
     cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
ffffffffc0203352:	d6dfc0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203356:	60a2                	ld	ra,8(sp)
ffffffffc0203358:	4501                	li	a0,0
ffffffffc020335a:	0141                	addi	sp,sp,16
ffffffffc020335c:	8082                	ret

ffffffffc020335e <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020335e:	03060793          	addi	a5,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203362:	c38d                	beqz	a5,ffffffffc0203384 <_clock_map_swappable+0x26>
ffffffffc0203364:	0000e717          	auipc	a4,0xe
ffffffffc0203368:	31c70713          	addi	a4,a4,796 # ffffffffc0211680 <curr_ptr>
ffffffffc020336c:	6318                	ld	a4,0(a4)
ffffffffc020336e:	cb19                	beqz	a4,ffffffffc0203384 <_clock_map_swappable+0x26>
    list_add_before((list_entry_t*) mm->sm_priv,entry);
ffffffffc0203370:	7518                	ld	a4,40(a0)
}
ffffffffc0203372:	4501                	li	a0,0
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203374:	6314                	ld	a3,0(a4)
    prev->next = next->prev = elm;
ffffffffc0203376:	e31c                	sd	a5,0(a4)
ffffffffc0203378:	e69c                	sd	a5,8(a3)
    page->visited = 1;
ffffffffc020337a:	4785                	li	a5,1
    elm->next = next;
ffffffffc020337c:	fe18                	sd	a4,56(a2)
    elm->prev = prev;
ffffffffc020337e:	fa14                	sd	a3,48(a2)
ffffffffc0203380:	ea1c                	sd	a5,16(a2)
}
ffffffffc0203382:	8082                	ret
{
ffffffffc0203384:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203386:	00003697          	auipc	a3,0x3
ffffffffc020338a:	83268693          	addi	a3,a3,-1998 # ffffffffc0205bb8 <default_pmm_manager+0xac0>
ffffffffc020338e:	00002617          	auipc	a2,0x2
ffffffffc0203392:	9d260613          	addi	a2,a2,-1582 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203396:	03700593          	li	a1,55
ffffffffc020339a:	00002517          	auipc	a0,0x2
ffffffffc020339e:	79650513          	addi	a0,a0,1942 # ffffffffc0205b30 <default_pmm_manager+0xa38>
{
ffffffffc02033a2:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02033a4:	fd1fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02033a8 <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02033a8:	7508                	ld	a0,40(a0)
{
ffffffffc02033aa:	1141                	addi	sp,sp,-16
ffffffffc02033ac:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02033ae:	c941                	beqz	a0,ffffffffc020343e <_clock_swap_out_victim+0x96>
     assert(in_tick==0);
ffffffffc02033b0:	e63d                	bnez	a2,ffffffffc020341e <_clock_swap_out_victim+0x76>
ffffffffc02033b2:	0000e797          	auipc	a5,0xe
ffffffffc02033b6:	2ce78793          	addi	a5,a5,718 # ffffffffc0211680 <curr_ptr>
ffffffffc02033ba:	639c                	ld	a5,0(a5)
ffffffffc02033bc:	679c                	ld	a5,8(a5)
ffffffffc02033be:	a039                	j	ffffffffc02033cc <_clock_swap_out_victim+0x24>
        if (page->visited==0) {
ffffffffc02033c0:	fe07b683          	ld	a3,-32(a5)
ffffffffc02033c4:	ce91                	beqz	a3,ffffffffc02033e0 <_clock_swap_out_victim+0x38>
            page->visited = 0;
ffffffffc02033c6:	fe07b023          	sd	zero,-32(a5)
    while (1) {
ffffffffc02033ca:	87ba                	mv	a5,a4
        if(curr_ptr == head) {
ffffffffc02033cc:	6798                	ld	a4,8(a5)
ffffffffc02033ce:	fef519e3          	bne	a0,a5,ffffffffc02033c0 <_clock_swap_out_victim+0x18>
            if(curr_ptr == head) {
ffffffffc02033d2:	02a70c63          	beq	a4,a0,ffffffffc020340a <_clock_swap_out_victim+0x62>
ffffffffc02033d6:	87ba                	mv	a5,a4
        if (page->visited==0) {
ffffffffc02033d8:	fe07b683          	ld	a3,-32(a5)
            if(curr_ptr == head) {
ffffffffc02033dc:	6718                	ld	a4,8(a4)
        if (page->visited==0) {
ffffffffc02033de:	f6e5                	bnez	a3,ffffffffc02033c6 <_clock_swap_out_victim+0x1e>
    __list_del(listelm->prev, listelm->next);
ffffffffc02033e0:	6394                	ld	a3,0(a5)
ffffffffc02033e2:	0000e617          	auipc	a2,0xe
ffffffffc02033e6:	28f63f23          	sd	a5,670(a2) # ffffffffc0211680 <curr_ptr>
        struct Page *page = le2page(curr_ptr, pra_page_link);
ffffffffc02033ea:	fd078613          	addi	a2,a5,-48
            *ptr_page=page;
ffffffffc02033ee:	e190                	sd	a2,0(a1)
    prev->next = next;
ffffffffc02033f0:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02033f2:	e314                	sd	a3,0(a4)
            cprintf("curr_ptr %p\n",curr_ptr);
ffffffffc02033f4:	85be                	mv	a1,a5
ffffffffc02033f6:	00003517          	auipc	a0,0x3
ffffffffc02033fa:	80a50513          	addi	a0,a0,-2038 # ffffffffc0205c00 <default_pmm_manager+0xb08>
ffffffffc02033fe:	cc1fc0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203402:	60a2                	ld	ra,8(sp)
ffffffffc0203404:	4501                	li	a0,0
ffffffffc0203406:	0141                	addi	sp,sp,16
ffffffffc0203408:	8082                	ret
ffffffffc020340a:	60a2                	ld	ra,8(sp)
ffffffffc020340c:	0000e797          	auipc	a5,0xe
ffffffffc0203410:	26a7ba23          	sd	a0,628(a5) # ffffffffc0211680 <curr_ptr>
                *ptr_page = NULL;
ffffffffc0203414:	0005b023          	sd	zero,0(a1) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
}
ffffffffc0203418:	4501                	li	a0,0
ffffffffc020341a:	0141                	addi	sp,sp,16
ffffffffc020341c:	8082                	ret
     assert(in_tick==0);
ffffffffc020341e:	00002697          	auipc	a3,0x2
ffffffffc0203422:	7d268693          	addi	a3,a3,2002 # ffffffffc0205bf0 <default_pmm_manager+0xaf8>
ffffffffc0203426:	00002617          	auipc	a2,0x2
ffffffffc020342a:	93a60613          	addi	a2,a2,-1734 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020342e:	04b00593          	li	a1,75
ffffffffc0203432:	00002517          	auipc	a0,0x2
ffffffffc0203436:	6fe50513          	addi	a0,a0,1790 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc020343a:	f3bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(head != NULL);
ffffffffc020343e:	00002697          	auipc	a3,0x2
ffffffffc0203442:	7a268693          	addi	a3,a3,1954 # ffffffffc0205be0 <default_pmm_manager+0xae8>
ffffffffc0203446:	00002617          	auipc	a2,0x2
ffffffffc020344a:	91a60613          	addi	a2,a2,-1766 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020344e:	04a00593          	li	a1,74
ffffffffc0203452:	00002517          	auipc	a0,0x2
ffffffffc0203456:	6de50513          	addi	a0,a0,1758 # ffffffffc0205b30 <default_pmm_manager+0xa38>
ffffffffc020345a:	f1bfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020345e <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020345e:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203460:	00002697          	auipc	a3,0x2
ffffffffc0203464:	7c868693          	addi	a3,a3,1992 # ffffffffc0205c28 <default_pmm_manager+0xb30>
ffffffffc0203468:	00002617          	auipc	a2,0x2
ffffffffc020346c:	8f860613          	addi	a2,a2,-1800 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203470:	07d00593          	li	a1,125
ffffffffc0203474:	00002517          	auipc	a0,0x2
ffffffffc0203478:	7d450513          	addi	a0,a0,2004 # ffffffffc0205c48 <default_pmm_manager+0xb50>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020347c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020347e:	ef7fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203482 <mm_create>:
mm_create(void) {
ffffffffc0203482:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203484:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203488:	e022                	sd	s0,0(sp)
ffffffffc020348a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020348c:	a6eff0ef          	jal	ra,ffffffffc02026fa <kmalloc>
ffffffffc0203490:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203492:	c115                	beqz	a0,ffffffffc02034b6 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203494:	0000e797          	auipc	a5,0xe
ffffffffc0203498:	fdc78793          	addi	a5,a5,-36 # ffffffffc0211470 <swap_init_ok>
ffffffffc020349c:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc020349e:	e408                	sd	a0,8(s0)
ffffffffc02034a0:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02034a2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02034a6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02034aa:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02034ae:	2781                	sext.w	a5,a5
ffffffffc02034b0:	eb81                	bnez	a5,ffffffffc02034c0 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc02034b2:	02053423          	sd	zero,40(a0)
}
ffffffffc02034b6:	8522                	mv	a0,s0
ffffffffc02034b8:	60a2                	ld	ra,8(sp)
ffffffffc02034ba:	6402                	ld	s0,0(sp)
ffffffffc02034bc:	0141                	addi	sp,sp,16
ffffffffc02034be:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02034c0:	a5dff0ef          	jal	ra,ffffffffc0202f1c <swap_init_mm>
}
ffffffffc02034c4:	8522                	mv	a0,s0
ffffffffc02034c6:	60a2                	ld	ra,8(sp)
ffffffffc02034c8:	6402                	ld	s0,0(sp)
ffffffffc02034ca:	0141                	addi	sp,sp,16
ffffffffc02034cc:	8082                	ret

ffffffffc02034ce <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02034ce:	1101                	addi	sp,sp,-32
ffffffffc02034d0:	e04a                	sd	s2,0(sp)
ffffffffc02034d2:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034d4:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02034d8:	e822                	sd	s0,16(sp)
ffffffffc02034da:	e426                	sd	s1,8(sp)
ffffffffc02034dc:	ec06                	sd	ra,24(sp)
ffffffffc02034de:	84ae                	mv	s1,a1
ffffffffc02034e0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034e2:	a18ff0ef          	jal	ra,ffffffffc02026fa <kmalloc>
    if (vma != NULL) {
ffffffffc02034e6:	c509                	beqz	a0,ffffffffc02034f0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02034e8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02034ec:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02034ee:	ed00                	sd	s0,24(a0)
}
ffffffffc02034f0:	60e2                	ld	ra,24(sp)
ffffffffc02034f2:	6442                	ld	s0,16(sp)
ffffffffc02034f4:	64a2                	ld	s1,8(sp)
ffffffffc02034f6:	6902                	ld	s2,0(sp)
ffffffffc02034f8:	6105                	addi	sp,sp,32
ffffffffc02034fa:	8082                	ret

ffffffffc02034fc <find_vma>:
    if (mm != NULL) {
ffffffffc02034fc:	c51d                	beqz	a0,ffffffffc020352a <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02034fe:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203500:	c781                	beqz	a5,ffffffffc0203508 <find_vma+0xc>
ffffffffc0203502:	6798                	ld	a4,8(a5)
ffffffffc0203504:	02e5f663          	bleu	a4,a1,ffffffffc0203530 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0203508:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020350a:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020350c:	00f50f63          	beq	a0,a5,ffffffffc020352a <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0203510:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203514:	fee5ebe3          	bltu	a1,a4,ffffffffc020350a <find_vma+0xe>
ffffffffc0203518:	ff07b703          	ld	a4,-16(a5)
ffffffffc020351c:	fee5f7e3          	bleu	a4,a1,ffffffffc020350a <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0203520:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0203522:	c781                	beqz	a5,ffffffffc020352a <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0203524:	e91c                	sd	a5,16(a0)
}
ffffffffc0203526:	853e                	mv	a0,a5
ffffffffc0203528:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020352a:	4781                	li	a5,0
}
ffffffffc020352c:	853e                	mv	a0,a5
ffffffffc020352e:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203530:	6b98                	ld	a4,16(a5)
ffffffffc0203532:	fce5fbe3          	bleu	a4,a1,ffffffffc0203508 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0203536:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0203538:	b7fd                	j	ffffffffc0203526 <find_vma+0x2a>

ffffffffc020353a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020353a:	6590                	ld	a2,8(a1)
ffffffffc020353c:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203540:	1141                	addi	sp,sp,-16
ffffffffc0203542:	e406                	sd	ra,8(sp)
ffffffffc0203544:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203546:	01066863          	bltu	a2,a6,ffffffffc0203556 <insert_vma_struct+0x1c>
ffffffffc020354a:	a8b9                	j	ffffffffc02035a8 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020354c:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203550:	04d66763          	bltu	a2,a3,ffffffffc020359e <insert_vma_struct+0x64>
ffffffffc0203554:	873e                	mv	a4,a5
ffffffffc0203556:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0203558:	fef51ae3          	bne	a0,a5,ffffffffc020354c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020355c:	02a70463          	beq	a4,a0,ffffffffc0203584 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203560:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203564:	fe873883          	ld	a7,-24(a4)
ffffffffc0203568:	08d8f063          	bleu	a3,a7,ffffffffc02035e8 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020356c:	04d66e63          	bltu	a2,a3,ffffffffc02035c8 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0203570:	00f50a63          	beq	a0,a5,ffffffffc0203584 <insert_vma_struct+0x4a>
ffffffffc0203574:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203578:	0506e863          	bltu	a3,a6,ffffffffc02035c8 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc020357c:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203580:	02c6f263          	bleu	a2,a3,ffffffffc02035a4 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203584:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0203586:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203588:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020358c:	e390                	sd	a2,0(a5)
ffffffffc020358e:	e710                	sd	a2,8(a4)
}
ffffffffc0203590:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203592:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203594:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0203596:	2685                	addiw	a3,a3,1
ffffffffc0203598:	d114                	sw	a3,32(a0)
}
ffffffffc020359a:	0141                	addi	sp,sp,16
ffffffffc020359c:	8082                	ret
    if (le_prev != list) {
ffffffffc020359e:	fca711e3          	bne	a4,a0,ffffffffc0203560 <insert_vma_struct+0x26>
ffffffffc02035a2:	bfd9                	j	ffffffffc0203578 <insert_vma_struct+0x3e>
ffffffffc02035a4:	ebbff0ef          	jal	ra,ffffffffc020345e <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02035a8:	00002697          	auipc	a3,0x2
ffffffffc02035ac:	73068693          	addi	a3,a3,1840 # ffffffffc0205cd8 <default_pmm_manager+0xbe0>
ffffffffc02035b0:	00001617          	auipc	a2,0x1
ffffffffc02035b4:	7b060613          	addi	a2,a2,1968 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02035b8:	08400593          	li	a1,132
ffffffffc02035bc:	00002517          	auipc	a0,0x2
ffffffffc02035c0:	68c50513          	addi	a0,a0,1676 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc02035c4:	db1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02035c8:	00002697          	auipc	a3,0x2
ffffffffc02035cc:	75068693          	addi	a3,a3,1872 # ffffffffc0205d18 <default_pmm_manager+0xc20>
ffffffffc02035d0:	00001617          	auipc	a2,0x1
ffffffffc02035d4:	79060613          	addi	a2,a2,1936 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02035d8:	07c00593          	li	a1,124
ffffffffc02035dc:	00002517          	auipc	a0,0x2
ffffffffc02035e0:	66c50513          	addi	a0,a0,1644 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc02035e4:	d91fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02035e8:	00002697          	auipc	a3,0x2
ffffffffc02035ec:	71068693          	addi	a3,a3,1808 # ffffffffc0205cf8 <default_pmm_manager+0xc00>
ffffffffc02035f0:	00001617          	auipc	a2,0x1
ffffffffc02035f4:	77060613          	addi	a2,a2,1904 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02035f8:	07b00593          	li	a1,123
ffffffffc02035fc:	00002517          	auipc	a0,0x2
ffffffffc0203600:	64c50513          	addi	a0,a0,1612 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203604:	d71fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203608 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203608:	1141                	addi	sp,sp,-16
ffffffffc020360a:	e022                	sd	s0,0(sp)
ffffffffc020360c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020360e:	6508                	ld	a0,8(a0)
ffffffffc0203610:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203612:	00a40e63          	beq	s0,a0,ffffffffc020362e <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203616:	6118                	ld	a4,0(a0)
ffffffffc0203618:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020361a:	03000593          	li	a1,48
ffffffffc020361e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203620:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203622:	e398                	sd	a4,0(a5)
ffffffffc0203624:	998ff0ef          	jal	ra,ffffffffc02027bc <kfree>
    return listelm->next;
ffffffffc0203628:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020362a:	fea416e3          	bne	s0,a0,ffffffffc0203616 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020362e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203630:	6402                	ld	s0,0(sp)
ffffffffc0203632:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203634:	03000593          	li	a1,48
}
ffffffffc0203638:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020363a:	982ff06f          	j	ffffffffc02027bc <kfree>

ffffffffc020363e <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020363e:	715d                	addi	sp,sp,-80
ffffffffc0203640:	e486                	sd	ra,72(sp)
ffffffffc0203642:	e0a2                	sd	s0,64(sp)
ffffffffc0203644:	fc26                	sd	s1,56(sp)
ffffffffc0203646:	f84a                	sd	s2,48(sp)
ffffffffc0203648:	f052                	sd	s4,32(sp)
ffffffffc020364a:	f44e                	sd	s3,40(sp)
ffffffffc020364c:	ec56                	sd	s5,24(sp)
ffffffffc020364e:	e85a                	sd	s6,16(sp)
ffffffffc0203650:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203652:	94afe0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc0203656:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203658:	944fe0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc020365c:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc020365e:	e25ff0ef          	jal	ra,ffffffffc0203482 <mm_create>
    assert(mm != NULL);
ffffffffc0203662:	842a                	mv	s0,a0
ffffffffc0203664:	03200493          	li	s1,50
ffffffffc0203668:	e919                	bnez	a0,ffffffffc020367e <vmm_init+0x40>
ffffffffc020366a:	aeed                	j	ffffffffc0203a64 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc020366c:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020366e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203670:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203674:	14ed                	addi	s1,s1,-5
ffffffffc0203676:	8522                	mv	a0,s0
ffffffffc0203678:	ec3ff0ef          	jal	ra,ffffffffc020353a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020367c:	c88d                	beqz	s1,ffffffffc02036ae <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020367e:	03000513          	li	a0,48
ffffffffc0203682:	878ff0ef          	jal	ra,ffffffffc02026fa <kmalloc>
ffffffffc0203686:	85aa                	mv	a1,a0
ffffffffc0203688:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020368c:	f165                	bnez	a0,ffffffffc020366c <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc020368e:	00002697          	auipc	a3,0x2
ffffffffc0203692:	20268693          	addi	a3,a3,514 # ffffffffc0205890 <default_pmm_manager+0x798>
ffffffffc0203696:	00001617          	auipc	a2,0x1
ffffffffc020369a:	6ca60613          	addi	a2,a2,1738 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc020369e:	0ce00593          	li	a1,206
ffffffffc02036a2:	00002517          	auipc	a0,0x2
ffffffffc02036a6:	5a650513          	addi	a0,a0,1446 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc02036aa:	ccbfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02036ae:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02036b2:	1f900993          	li	s3,505
ffffffffc02036b6:	a819                	j	ffffffffc02036cc <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc02036b8:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02036ba:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02036bc:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02036c0:	0495                	addi	s1,s1,5
ffffffffc02036c2:	8522                	mv	a0,s0
ffffffffc02036c4:	e77ff0ef          	jal	ra,ffffffffc020353a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02036c8:	03348a63          	beq	s1,s3,ffffffffc02036fc <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02036cc:	03000513          	li	a0,48
ffffffffc02036d0:	82aff0ef          	jal	ra,ffffffffc02026fa <kmalloc>
ffffffffc02036d4:	85aa                	mv	a1,a0
ffffffffc02036d6:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02036da:	fd79                	bnez	a0,ffffffffc02036b8 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc02036dc:	00002697          	auipc	a3,0x2
ffffffffc02036e0:	1b468693          	addi	a3,a3,436 # ffffffffc0205890 <default_pmm_manager+0x798>
ffffffffc02036e4:	00001617          	auipc	a2,0x1
ffffffffc02036e8:	67c60613          	addi	a2,a2,1660 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02036ec:	0d400593          	li	a1,212
ffffffffc02036f0:	00002517          	auipc	a0,0x2
ffffffffc02036f4:	55850513          	addi	a0,a0,1368 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc02036f8:	c7dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02036fc:	6418                	ld	a4,8(s0)
ffffffffc02036fe:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203700:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203704:	2ae40063          	beq	s0,a4,ffffffffc02039a4 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203708:	fe873603          	ld	a2,-24(a4)
ffffffffc020370c:	ffe78693          	addi	a3,a5,-2
ffffffffc0203710:	20d61a63          	bne	a2,a3,ffffffffc0203924 <vmm_init+0x2e6>
ffffffffc0203714:	ff073683          	ld	a3,-16(a4)
ffffffffc0203718:	20d79663          	bne	a5,a3,ffffffffc0203924 <vmm_init+0x2e6>
ffffffffc020371c:	0795                	addi	a5,a5,5
ffffffffc020371e:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203720:	feb792e3          	bne	a5,a1,ffffffffc0203704 <vmm_init+0xc6>
ffffffffc0203724:	499d                	li	s3,7
ffffffffc0203726:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203728:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020372c:	85a6                	mv	a1,s1
ffffffffc020372e:	8522                	mv	a0,s0
ffffffffc0203730:	dcdff0ef          	jal	ra,ffffffffc02034fc <find_vma>
ffffffffc0203734:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc0203736:	2e050763          	beqz	a0,ffffffffc0203a24 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020373a:	00148593          	addi	a1,s1,1
ffffffffc020373e:	8522                	mv	a0,s0
ffffffffc0203740:	dbdff0ef          	jal	ra,ffffffffc02034fc <find_vma>
ffffffffc0203744:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0203746:	2a050f63          	beqz	a0,ffffffffc0203a04 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020374a:	85ce                	mv	a1,s3
ffffffffc020374c:	8522                	mv	a0,s0
ffffffffc020374e:	dafff0ef          	jal	ra,ffffffffc02034fc <find_vma>
        assert(vma3 == NULL);
ffffffffc0203752:	28051963          	bnez	a0,ffffffffc02039e4 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203756:	00348593          	addi	a1,s1,3
ffffffffc020375a:	8522                	mv	a0,s0
ffffffffc020375c:	da1ff0ef          	jal	ra,ffffffffc02034fc <find_vma>
        assert(vma4 == NULL);
ffffffffc0203760:	26051263          	bnez	a0,ffffffffc02039c4 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203764:	00448593          	addi	a1,s1,4
ffffffffc0203768:	8522                	mv	a0,s0
ffffffffc020376a:	d93ff0ef          	jal	ra,ffffffffc02034fc <find_vma>
        assert(vma5 == NULL);
ffffffffc020376e:	2c051b63          	bnez	a0,ffffffffc0203a44 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203772:	008b3783          	ld	a5,8(s6)
ffffffffc0203776:	1c979763          	bne	a5,s1,ffffffffc0203944 <vmm_init+0x306>
ffffffffc020377a:	010b3783          	ld	a5,16(s6)
ffffffffc020377e:	1d379363          	bne	a5,s3,ffffffffc0203944 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203782:	008ab783          	ld	a5,8(s5)
ffffffffc0203786:	1c979f63          	bne	a5,s1,ffffffffc0203964 <vmm_init+0x326>
ffffffffc020378a:	010ab783          	ld	a5,16(s5)
ffffffffc020378e:	1d379b63          	bne	a5,s3,ffffffffc0203964 <vmm_init+0x326>
ffffffffc0203792:	0495                	addi	s1,s1,5
ffffffffc0203794:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203796:	f9749be3          	bne	s1,s7,ffffffffc020372c <vmm_init+0xee>
ffffffffc020379a:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020379c:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020379e:	85a6                	mv	a1,s1
ffffffffc02037a0:	8522                	mv	a0,s0
ffffffffc02037a2:	d5bff0ef          	jal	ra,ffffffffc02034fc <find_vma>
ffffffffc02037a6:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02037aa:	c90d                	beqz	a0,ffffffffc02037dc <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02037ac:	6914                	ld	a3,16(a0)
ffffffffc02037ae:	6510                	ld	a2,8(a0)
ffffffffc02037b0:	00002517          	auipc	a0,0x2
ffffffffc02037b4:	68850513          	addi	a0,a0,1672 # ffffffffc0205e38 <default_pmm_manager+0xd40>
ffffffffc02037b8:	907fc0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02037bc:	00002697          	auipc	a3,0x2
ffffffffc02037c0:	6a468693          	addi	a3,a3,1700 # ffffffffc0205e60 <default_pmm_manager+0xd68>
ffffffffc02037c4:	00001617          	auipc	a2,0x1
ffffffffc02037c8:	59c60613          	addi	a2,a2,1436 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02037cc:	0f600593          	li	a1,246
ffffffffc02037d0:	00002517          	auipc	a0,0x2
ffffffffc02037d4:	47850513          	addi	a0,a0,1144 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc02037d8:	b9dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02037dc:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02037de:	fd3490e3          	bne	s1,s3,ffffffffc020379e <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc02037e2:	8522                	mv	a0,s0
ffffffffc02037e4:	e25ff0ef          	jal	ra,ffffffffc0203608 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02037e8:	fb5fd0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc02037ec:	28aa1c63          	bne	s4,a0,ffffffffc0203a84 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02037f0:	00002517          	auipc	a0,0x2
ffffffffc02037f4:	6b050513          	addi	a0,a0,1712 # ffffffffc0205ea0 <default_pmm_manager+0xda8>
ffffffffc02037f8:	8c7fc0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02037fc:	fa1fd0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc0203800:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0203802:	c81ff0ef          	jal	ra,ffffffffc0203482 <mm_create>
ffffffffc0203806:	0000e797          	auipc	a5,0xe
ffffffffc020380a:	e8a7b123          	sd	a0,-382(a5) # ffffffffc0211688 <check_mm_struct>
ffffffffc020380e:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc0203810:	2a050a63          	beqz	a0,ffffffffc0203ac4 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203814:	0000e797          	auipc	a5,0xe
ffffffffc0203818:	c4478793          	addi	a5,a5,-956 # ffffffffc0211458 <boot_pgdir>
ffffffffc020381c:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020381e:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203820:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203822:	32079d63          	bnez	a5,ffffffffc0203b5c <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203826:	03000513          	li	a0,48
ffffffffc020382a:	ed1fe0ef          	jal	ra,ffffffffc02026fa <kmalloc>
ffffffffc020382e:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0203830:	14050a63          	beqz	a0,ffffffffc0203984 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc0203834:	002007b7          	lui	a5,0x200
ffffffffc0203838:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc020383c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020383e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203840:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203844:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203846:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc020384a:	cf1ff0ef          	jal	ra,ffffffffc020353a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020384e:	10000593          	li	a1,256
ffffffffc0203852:	8522                	mv	a0,s0
ffffffffc0203854:	ca9ff0ef          	jal	ra,ffffffffc02034fc <find_vma>
ffffffffc0203858:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc020385c:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203860:	2aaa1263          	bne	s4,a0,ffffffffc0203b04 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc0203864:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203868:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020386a:	fee79de3          	bne	a5,a4,ffffffffc0203864 <vmm_init+0x226>
        sum += i;
ffffffffc020386e:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203870:	10000793          	li	a5,256
        sum += i;
ffffffffc0203874:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203878:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020387c:	0007c683          	lbu	a3,0(a5)
ffffffffc0203880:	0785                	addi	a5,a5,1
ffffffffc0203882:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203884:	fec79ce3          	bne	a5,a2,ffffffffc020387c <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0203888:	2a071a63          	bnez	a4,ffffffffc0203b3c <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020388c:	4581                	li	a1,0
ffffffffc020388e:	8526                	mv	a0,s1
ffffffffc0203890:	9b2fe0ef          	jal	ra,ffffffffc0201a42 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203894:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0203896:	0000e717          	auipc	a4,0xe
ffffffffc020389a:	bca70713          	addi	a4,a4,-1078 # ffffffffc0211460 <npage>
ffffffffc020389e:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc02038a0:	078a                	slli	a5,a5,0x2
ffffffffc02038a2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02038a4:	28e7f063          	bleu	a4,a5,ffffffffc0203b24 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc02038a8:	00003717          	auipc	a4,0x3
ffffffffc02038ac:	93870713          	addi	a4,a4,-1736 # ffffffffc02061e0 <nbase>
ffffffffc02038b0:	6318                	ld	a4,0(a4)
ffffffffc02038b2:	0000e697          	auipc	a3,0xe
ffffffffc02038b6:	cee68693          	addi	a3,a3,-786 # ffffffffc02115a0 <pages>
ffffffffc02038ba:	6288                	ld	a0,0(a3)
ffffffffc02038bc:	8f99                	sub	a5,a5,a4
ffffffffc02038be:	00379713          	slli	a4,a5,0x3
ffffffffc02038c2:	97ba                	add	a5,a5,a4
ffffffffc02038c4:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc02038c6:	953e                	add	a0,a0,a5
ffffffffc02038c8:	4585                	li	a1,1
ffffffffc02038ca:	e8dfd0ef          	jal	ra,ffffffffc0201756 <free_pages>

    pgdir[0] = 0;
ffffffffc02038ce:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02038d2:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02038d4:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02038d8:	d31ff0ef          	jal	ra,ffffffffc0203608 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc02038dc:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc02038de:	0000e797          	auipc	a5,0xe
ffffffffc02038e2:	da07b523          	sd	zero,-598(a5) # ffffffffc0211688 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038e6:	eb7fd0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc02038ea:	1aa99d63          	bne	s3,a0,ffffffffc0203aa4 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02038ee:	00002517          	auipc	a0,0x2
ffffffffc02038f2:	61a50513          	addi	a0,a0,1562 # ffffffffc0205f08 <default_pmm_manager+0xe10>
ffffffffc02038f6:	fc8fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038fa:	ea3fd0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc02038fe:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203900:	1ea91263          	bne	s2,a0,ffffffffc0203ae4 <vmm_init+0x4a6>
}
ffffffffc0203904:	6406                	ld	s0,64(sp)
ffffffffc0203906:	60a6                	ld	ra,72(sp)
ffffffffc0203908:	74e2                	ld	s1,56(sp)
ffffffffc020390a:	7942                	ld	s2,48(sp)
ffffffffc020390c:	79a2                	ld	s3,40(sp)
ffffffffc020390e:	7a02                	ld	s4,32(sp)
ffffffffc0203910:	6ae2                	ld	s5,24(sp)
ffffffffc0203912:	6b42                	ld	s6,16(sp)
ffffffffc0203914:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203916:	00002517          	auipc	a0,0x2
ffffffffc020391a:	61250513          	addi	a0,a0,1554 # ffffffffc0205f28 <default_pmm_manager+0xe30>
}
ffffffffc020391e:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203920:	f9efc06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203924:	00002697          	auipc	a3,0x2
ffffffffc0203928:	42c68693          	addi	a3,a3,1068 # ffffffffc0205d50 <default_pmm_manager+0xc58>
ffffffffc020392c:	00001617          	auipc	a2,0x1
ffffffffc0203930:	43460613          	addi	a2,a2,1076 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203934:	0dd00593          	li	a1,221
ffffffffc0203938:	00002517          	auipc	a0,0x2
ffffffffc020393c:	31050513          	addi	a0,a0,784 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203940:	a35fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203944:	00002697          	auipc	a3,0x2
ffffffffc0203948:	49468693          	addi	a3,a3,1172 # ffffffffc0205dd8 <default_pmm_manager+0xce0>
ffffffffc020394c:	00001617          	auipc	a2,0x1
ffffffffc0203950:	41460613          	addi	a2,a2,1044 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203954:	0ed00593          	li	a1,237
ffffffffc0203958:	00002517          	auipc	a0,0x2
ffffffffc020395c:	2f050513          	addi	a0,a0,752 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203960:	a15fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203964:	00002697          	auipc	a3,0x2
ffffffffc0203968:	4a468693          	addi	a3,a3,1188 # ffffffffc0205e08 <default_pmm_manager+0xd10>
ffffffffc020396c:	00001617          	auipc	a2,0x1
ffffffffc0203970:	3f460613          	addi	a2,a2,1012 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203974:	0ee00593          	li	a1,238
ffffffffc0203978:	00002517          	auipc	a0,0x2
ffffffffc020397c:	2d050513          	addi	a0,a0,720 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203980:	9f5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc0203984:	00002697          	auipc	a3,0x2
ffffffffc0203988:	f0c68693          	addi	a3,a3,-244 # ffffffffc0205890 <default_pmm_manager+0x798>
ffffffffc020398c:	00001617          	auipc	a2,0x1
ffffffffc0203990:	3d460613          	addi	a2,a2,980 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203994:	11100593          	li	a1,273
ffffffffc0203998:	00002517          	auipc	a0,0x2
ffffffffc020399c:	2b050513          	addi	a0,a0,688 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc02039a0:	9d5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02039a4:	00002697          	auipc	a3,0x2
ffffffffc02039a8:	39468693          	addi	a3,a3,916 # ffffffffc0205d38 <default_pmm_manager+0xc40>
ffffffffc02039ac:	00001617          	auipc	a2,0x1
ffffffffc02039b0:	3b460613          	addi	a2,a2,948 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02039b4:	0db00593          	li	a1,219
ffffffffc02039b8:	00002517          	auipc	a0,0x2
ffffffffc02039bc:	29050513          	addi	a0,a0,656 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc02039c0:	9b5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc02039c4:	00002697          	auipc	a3,0x2
ffffffffc02039c8:	3f468693          	addi	a3,a3,1012 # ffffffffc0205db8 <default_pmm_manager+0xcc0>
ffffffffc02039cc:	00001617          	auipc	a2,0x1
ffffffffc02039d0:	39460613          	addi	a2,a2,916 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02039d4:	0e900593          	li	a1,233
ffffffffc02039d8:	00002517          	auipc	a0,0x2
ffffffffc02039dc:	27050513          	addi	a0,a0,624 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc02039e0:	995fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc02039e4:	00002697          	auipc	a3,0x2
ffffffffc02039e8:	3c468693          	addi	a3,a3,964 # ffffffffc0205da8 <default_pmm_manager+0xcb0>
ffffffffc02039ec:	00001617          	auipc	a2,0x1
ffffffffc02039f0:	37460613          	addi	a2,a2,884 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc02039f4:	0e700593          	li	a1,231
ffffffffc02039f8:	00002517          	auipc	a0,0x2
ffffffffc02039fc:	25050513          	addi	a0,a0,592 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203a00:	975fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc0203a04:	00002697          	auipc	a3,0x2
ffffffffc0203a08:	39468693          	addi	a3,a3,916 # ffffffffc0205d98 <default_pmm_manager+0xca0>
ffffffffc0203a0c:	00001617          	auipc	a2,0x1
ffffffffc0203a10:	35460613          	addi	a2,a2,852 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203a14:	0e500593          	li	a1,229
ffffffffc0203a18:	00002517          	auipc	a0,0x2
ffffffffc0203a1c:	23050513          	addi	a0,a0,560 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203a20:	955fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc0203a24:	00002697          	auipc	a3,0x2
ffffffffc0203a28:	36468693          	addi	a3,a3,868 # ffffffffc0205d88 <default_pmm_manager+0xc90>
ffffffffc0203a2c:	00001617          	auipc	a2,0x1
ffffffffc0203a30:	33460613          	addi	a2,a2,820 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203a34:	0e300593          	li	a1,227
ffffffffc0203a38:	00002517          	auipc	a0,0x2
ffffffffc0203a3c:	21050513          	addi	a0,a0,528 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203a40:	935fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203a44:	00002697          	auipc	a3,0x2
ffffffffc0203a48:	38468693          	addi	a3,a3,900 # ffffffffc0205dc8 <default_pmm_manager+0xcd0>
ffffffffc0203a4c:	00001617          	auipc	a2,0x1
ffffffffc0203a50:	31460613          	addi	a2,a2,788 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203a54:	0eb00593          	li	a1,235
ffffffffc0203a58:	00002517          	auipc	a0,0x2
ffffffffc0203a5c:	1f050513          	addi	a0,a0,496 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203a60:	915fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203a64:	00002697          	auipc	a3,0x2
ffffffffc0203a68:	df468693          	addi	a3,a3,-524 # ffffffffc0205858 <default_pmm_manager+0x760>
ffffffffc0203a6c:	00001617          	auipc	a2,0x1
ffffffffc0203a70:	2f460613          	addi	a2,a2,756 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203a74:	0c700593          	li	a1,199
ffffffffc0203a78:	00002517          	auipc	a0,0x2
ffffffffc0203a7c:	1d050513          	addi	a0,a0,464 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203a80:	8f5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a84:	00002697          	auipc	a3,0x2
ffffffffc0203a88:	3f468693          	addi	a3,a3,1012 # ffffffffc0205e78 <default_pmm_manager+0xd80>
ffffffffc0203a8c:	00001617          	auipc	a2,0x1
ffffffffc0203a90:	2d460613          	addi	a2,a2,724 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203a94:	0fb00593          	li	a1,251
ffffffffc0203a98:	00002517          	auipc	a0,0x2
ffffffffc0203a9c:	1b050513          	addi	a0,a0,432 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203aa0:	8d5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203aa4:	00002697          	auipc	a3,0x2
ffffffffc0203aa8:	3d468693          	addi	a3,a3,980 # ffffffffc0205e78 <default_pmm_manager+0xd80>
ffffffffc0203aac:	00001617          	auipc	a2,0x1
ffffffffc0203ab0:	2b460613          	addi	a2,a2,692 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203ab4:	12e00593          	li	a1,302
ffffffffc0203ab8:	00002517          	auipc	a0,0x2
ffffffffc0203abc:	19050513          	addi	a0,a0,400 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203ac0:	8b5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203ac4:	00002697          	auipc	a3,0x2
ffffffffc0203ac8:	3fc68693          	addi	a3,a3,1020 # ffffffffc0205ec0 <default_pmm_manager+0xdc8>
ffffffffc0203acc:	00001617          	auipc	a2,0x1
ffffffffc0203ad0:	29460613          	addi	a2,a2,660 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203ad4:	10a00593          	li	a1,266
ffffffffc0203ad8:	00002517          	auipc	a0,0x2
ffffffffc0203adc:	17050513          	addi	a0,a0,368 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203ae0:	895fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ae4:	00002697          	auipc	a3,0x2
ffffffffc0203ae8:	39468693          	addi	a3,a3,916 # ffffffffc0205e78 <default_pmm_manager+0xd80>
ffffffffc0203aec:	00001617          	auipc	a2,0x1
ffffffffc0203af0:	27460613          	addi	a2,a2,628 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203af4:	0bd00593          	li	a1,189
ffffffffc0203af8:	00002517          	auipc	a0,0x2
ffffffffc0203afc:	15050513          	addi	a0,a0,336 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203b00:	875fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203b04:	00002697          	auipc	a3,0x2
ffffffffc0203b08:	3d468693          	addi	a3,a3,980 # ffffffffc0205ed8 <default_pmm_manager+0xde0>
ffffffffc0203b0c:	00001617          	auipc	a2,0x1
ffffffffc0203b10:	25460613          	addi	a2,a2,596 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203b14:	11600593          	li	a1,278
ffffffffc0203b18:	00002517          	auipc	a0,0x2
ffffffffc0203b1c:	13050513          	addi	a0,a0,304 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203b20:	855fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203b24:	00001617          	auipc	a2,0x1
ffffffffc0203b28:	69c60613          	addi	a2,a2,1692 # ffffffffc02051c0 <default_pmm_manager+0xc8>
ffffffffc0203b2c:	06500593          	li	a1,101
ffffffffc0203b30:	00001517          	auipc	a0,0x1
ffffffffc0203b34:	6b050513          	addi	a0,a0,1712 # ffffffffc02051e0 <default_pmm_manager+0xe8>
ffffffffc0203b38:	83dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203b3c:	00002697          	auipc	a3,0x2
ffffffffc0203b40:	3bc68693          	addi	a3,a3,956 # ffffffffc0205ef8 <default_pmm_manager+0xe00>
ffffffffc0203b44:	00001617          	auipc	a2,0x1
ffffffffc0203b48:	21c60613          	addi	a2,a2,540 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203b4c:	12000593          	li	a1,288
ffffffffc0203b50:	00002517          	auipc	a0,0x2
ffffffffc0203b54:	0f850513          	addi	a0,a0,248 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203b58:	81dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203b5c:	00002697          	auipc	a3,0x2
ffffffffc0203b60:	d2468693          	addi	a3,a3,-732 # ffffffffc0205880 <default_pmm_manager+0x788>
ffffffffc0203b64:	00001617          	auipc	a2,0x1
ffffffffc0203b68:	1fc60613          	addi	a2,a2,508 # ffffffffc0204d60 <commands+0x8d8>
ffffffffc0203b6c:	10d00593          	li	a1,269
ffffffffc0203b70:	00002517          	auipc	a0,0x2
ffffffffc0203b74:	0d850513          	addi	a0,a0,216 # ffffffffc0205c48 <default_pmm_manager+0xb50>
ffffffffc0203b78:	ffcfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203b7c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b7c:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b7e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b80:	f022                	sd	s0,32(sp)
ffffffffc0203b82:	ec26                	sd	s1,24(sp)
ffffffffc0203b84:	f406                	sd	ra,40(sp)
ffffffffc0203b86:	e84a                	sd	s2,16(sp)
ffffffffc0203b88:	8432                	mv	s0,a2
ffffffffc0203b8a:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b8c:	971ff0ef          	jal	ra,ffffffffc02034fc <find_vma>

    pgfault_num++;
ffffffffc0203b90:	0000e797          	auipc	a5,0xe
ffffffffc0203b94:	8e478793          	addi	a5,a5,-1820 # ffffffffc0211474 <pgfault_num>
ffffffffc0203b98:	439c                	lw	a5,0(a5)
ffffffffc0203b9a:	2785                	addiw	a5,a5,1
ffffffffc0203b9c:	0000e717          	auipc	a4,0xe
ffffffffc0203ba0:	8cf72c23          	sw	a5,-1832(a4) # ffffffffc0211474 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203ba4:	c949                	beqz	a0,ffffffffc0203c36 <do_pgfault+0xba>
ffffffffc0203ba6:	651c                	ld	a5,8(a0)
ffffffffc0203ba8:	08f46763          	bltu	s0,a5,ffffffffc0203c36 <do_pgfault+0xba>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203bac:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203bae:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203bb0:	8b89                	andi	a5,a5,2
ffffffffc0203bb2:	e3ad                	bnez	a5,ffffffffc0203c14 <do_pgfault+0x98>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203bb4:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203bb6:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203bb8:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203bba:	85a2                	mv	a1,s0
ffffffffc0203bbc:	4605                	li	a2,1
ffffffffc0203bbe:	c1ffd0ef          	jal	ra,ffffffffc02017dc <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203bc2:	610c                	ld	a1,0(a0)
ffffffffc0203bc4:	c9b1                	beqz	a1,ffffffffc0203c18 <do_pgfault+0x9c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203bc6:	0000e797          	auipc	a5,0xe
ffffffffc0203bca:	8aa78793          	addi	a5,a5,-1878 # ffffffffc0211470 <swap_init_ok>
ffffffffc0203bce:	439c                	lw	a5,0(a5)
ffffffffc0203bd0:	2781                	sext.w	a5,a5
ffffffffc0203bd2:	cbbd                	beqz	a5,ffffffffc0203c48 <do_pgfault+0xcc>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm, addr, &page);
ffffffffc0203bd4:	85a2                	mv	a1,s0
ffffffffc0203bd6:	0030                	addi	a2,sp,8
ffffffffc0203bd8:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203bda:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0203bdc:	c74ff0ef          	jal	ra,ffffffffc0203050 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0203be0:	65a2                	ld	a1,8(sp)
ffffffffc0203be2:	6c88                	ld	a0,24(s1)
ffffffffc0203be4:	86ca                	mv	a3,s2
ffffffffc0203be6:	8622                	mv	a2,s0
ffffffffc0203be8:	ecdfd0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm,addr,page,swap_in);
ffffffffc0203bec:	6622                	ld	a2,8(sp)
ffffffffc0203bee:	fffff697          	auipc	a3,0xfffff
ffffffffc0203bf2:	46268693          	addi	a3,a3,1122 # ffffffffc0203050 <swap_in>
ffffffffc0203bf6:	2681                	sext.w	a3,a3
ffffffffc0203bf8:	85a2                	mv	a1,s0
ffffffffc0203bfa:	8526                	mv	a0,s1
ffffffffc0203bfc:	b30ff0ef          	jal	ra,ffffffffc0202f2c <swap_map_swappable>

            
            page->pra_vaddr = addr;
ffffffffc0203c00:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203c02:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0203c04:	e320                	sd	s0,64(a4)
failed:
    return ret;
}
ffffffffc0203c06:	70a2                	ld	ra,40(sp)
ffffffffc0203c08:	7402                	ld	s0,32(sp)
ffffffffc0203c0a:	64e2                	ld	s1,24(sp)
ffffffffc0203c0c:	6942                	ld	s2,16(sp)
ffffffffc0203c0e:	853e                	mv	a0,a5
ffffffffc0203c10:	6145                	addi	sp,sp,48
ffffffffc0203c12:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203c14:	4959                	li	s2,22
ffffffffc0203c16:	bf79                	j	ffffffffc0203bb4 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203c18:	6c88                	ld	a0,24(s1)
ffffffffc0203c1a:	864a                	mv	a2,s2
ffffffffc0203c1c:	85a2                	mv	a1,s0
ffffffffc0203c1e:	a4bfe0ef          	jal	ra,ffffffffc0202668 <pgdir_alloc_page>
   ret = 0;
ffffffffc0203c22:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203c24:	f16d                	bnez	a0,ffffffffc0203c06 <do_pgfault+0x8a>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203c26:	00002517          	auipc	a0,0x2
ffffffffc0203c2a:	06250513          	addi	a0,a0,98 # ffffffffc0205c88 <default_pmm_manager+0xb90>
ffffffffc0203c2e:	c90fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c32:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203c34:	bfc9                	j	ffffffffc0203c06 <do_pgfault+0x8a>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203c36:	85a2                	mv	a1,s0
ffffffffc0203c38:	00002517          	auipc	a0,0x2
ffffffffc0203c3c:	02050513          	addi	a0,a0,32 # ffffffffc0205c58 <default_pmm_manager+0xb60>
ffffffffc0203c40:	c7efc0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0203c44:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203c46:	b7c1                	j	ffffffffc0203c06 <do_pgfault+0x8a>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203c48:	00002517          	auipc	a0,0x2
ffffffffc0203c4c:	06850513          	addi	a0,a0,104 # ffffffffc0205cb0 <default_pmm_manager+0xbb8>
ffffffffc0203c50:	c6efc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c54:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203c56:	bf45                	j	ffffffffc0203c06 <do_pgfault+0x8a>

ffffffffc0203c58 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203c58:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c5a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203c5c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c5e:	841fc0ef          	jal	ra,ffffffffc020049e <ide_device_valid>
ffffffffc0203c62:	cd01                	beqz	a0,ffffffffc0203c7a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c64:	4505                	li	a0,1
ffffffffc0203c66:	83ffc0ef          	jal	ra,ffffffffc02004a4 <ide_device_size>
}
ffffffffc0203c6a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c6c:	810d                	srli	a0,a0,0x3
ffffffffc0203c6e:	0000e797          	auipc	a5,0xe
ffffffffc0203c72:	9ca7b123          	sd	a0,-1598(a5) # ffffffffc0211630 <max_swap_offset>
}
ffffffffc0203c76:	0141                	addi	sp,sp,16
ffffffffc0203c78:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203c7a:	00002617          	auipc	a2,0x2
ffffffffc0203c7e:	2c660613          	addi	a2,a2,710 # ffffffffc0205f40 <default_pmm_manager+0xe48>
ffffffffc0203c82:	45b5                	li	a1,13
ffffffffc0203c84:	00002517          	auipc	a0,0x2
ffffffffc0203c88:	2dc50513          	addi	a0,a0,732 # ffffffffc0205f60 <default_pmm_manager+0xe68>
ffffffffc0203c8c:	ee8fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203c90 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203c90:	1141                	addi	sp,sp,-16
ffffffffc0203c92:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c94:	00855793          	srli	a5,a0,0x8
ffffffffc0203c98:	c7b5                	beqz	a5,ffffffffc0203d04 <swapfs_read+0x74>
ffffffffc0203c9a:	0000e717          	auipc	a4,0xe
ffffffffc0203c9e:	99670713          	addi	a4,a4,-1642 # ffffffffc0211630 <max_swap_offset>
ffffffffc0203ca2:	6318                	ld	a4,0(a4)
ffffffffc0203ca4:	06e7f063          	bleu	a4,a5,ffffffffc0203d04 <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ca8:	0000e717          	auipc	a4,0xe
ffffffffc0203cac:	8f870713          	addi	a4,a4,-1800 # ffffffffc02115a0 <pages>
ffffffffc0203cb0:	6310                	ld	a2,0(a4)
ffffffffc0203cb2:	00001717          	auipc	a4,0x1
ffffffffc0203cb6:	09670713          	addi	a4,a4,150 # ffffffffc0204d48 <commands+0x8c0>
ffffffffc0203cba:	00002697          	auipc	a3,0x2
ffffffffc0203cbe:	52668693          	addi	a3,a3,1318 # ffffffffc02061e0 <nbase>
ffffffffc0203cc2:	40c58633          	sub	a2,a1,a2
ffffffffc0203cc6:	630c                	ld	a1,0(a4)
ffffffffc0203cc8:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cca:	0000d717          	auipc	a4,0xd
ffffffffc0203cce:	79670713          	addi	a4,a4,1942 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cd2:	02b60633          	mul	a2,a2,a1
ffffffffc0203cd6:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203cda:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cdc:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cde:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ce0:	57fd                	li	a5,-1
ffffffffc0203ce2:	83b1                	srli	a5,a5,0xc
ffffffffc0203ce4:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ce6:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ce8:	02e7fa63          	bleu	a4,a5,ffffffffc0203d1c <swapfs_read+0x8c>
ffffffffc0203cec:	0000e797          	auipc	a5,0xe
ffffffffc0203cf0:	8a478793          	addi	a5,a5,-1884 # ffffffffc0211590 <va_pa_offset>
ffffffffc0203cf4:	639c                	ld	a5,0(a5)
}
ffffffffc0203cf6:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cf8:	46a1                	li	a3,8
ffffffffc0203cfa:	963e                	add	a2,a2,a5
ffffffffc0203cfc:	4505                	li	a0,1
}
ffffffffc0203cfe:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d00:	faafc06f          	j	ffffffffc02004aa <ide_read_secs>
ffffffffc0203d04:	86aa                	mv	a3,a0
ffffffffc0203d06:	00002617          	auipc	a2,0x2
ffffffffc0203d0a:	27260613          	addi	a2,a2,626 # ffffffffc0205f78 <default_pmm_manager+0xe80>
ffffffffc0203d0e:	45d1                	li	a1,20
ffffffffc0203d10:	00002517          	auipc	a0,0x2
ffffffffc0203d14:	25050513          	addi	a0,a0,592 # ffffffffc0205f60 <default_pmm_manager+0xe68>
ffffffffc0203d18:	e5cfc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203d1c:	86b2                	mv	a3,a2
ffffffffc0203d1e:	06a00593          	li	a1,106
ffffffffc0203d22:	00001617          	auipc	a2,0x1
ffffffffc0203d26:	42660613          	addi	a2,a2,1062 # ffffffffc0205148 <default_pmm_manager+0x50>
ffffffffc0203d2a:	00001517          	auipc	a0,0x1
ffffffffc0203d2e:	4b650513          	addi	a0,a0,1206 # ffffffffc02051e0 <default_pmm_manager+0xe8>
ffffffffc0203d32:	e42fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203d36 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203d36:	1141                	addi	sp,sp,-16
ffffffffc0203d38:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d3a:	00855793          	srli	a5,a0,0x8
ffffffffc0203d3e:	c7b5                	beqz	a5,ffffffffc0203daa <swapfs_write+0x74>
ffffffffc0203d40:	0000e717          	auipc	a4,0xe
ffffffffc0203d44:	8f070713          	addi	a4,a4,-1808 # ffffffffc0211630 <max_swap_offset>
ffffffffc0203d48:	6318                	ld	a4,0(a4)
ffffffffc0203d4a:	06e7f063          	bleu	a4,a5,ffffffffc0203daa <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d4e:	0000e717          	auipc	a4,0xe
ffffffffc0203d52:	85270713          	addi	a4,a4,-1966 # ffffffffc02115a0 <pages>
ffffffffc0203d56:	6310                	ld	a2,0(a4)
ffffffffc0203d58:	00001717          	auipc	a4,0x1
ffffffffc0203d5c:	ff070713          	addi	a4,a4,-16 # ffffffffc0204d48 <commands+0x8c0>
ffffffffc0203d60:	00002697          	auipc	a3,0x2
ffffffffc0203d64:	48068693          	addi	a3,a3,1152 # ffffffffc02061e0 <nbase>
ffffffffc0203d68:	40c58633          	sub	a2,a1,a2
ffffffffc0203d6c:	630c                	ld	a1,0(a4)
ffffffffc0203d6e:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d70:	0000d717          	auipc	a4,0xd
ffffffffc0203d74:	6f070713          	addi	a4,a4,1776 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d78:	02b60633          	mul	a2,a2,a1
ffffffffc0203d7c:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d80:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d82:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d84:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d86:	57fd                	li	a5,-1
ffffffffc0203d88:	83b1                	srli	a5,a5,0xc
ffffffffc0203d8a:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d8c:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d8e:	02e7fa63          	bleu	a4,a5,ffffffffc0203dc2 <swapfs_write+0x8c>
ffffffffc0203d92:	0000d797          	auipc	a5,0xd
ffffffffc0203d96:	7fe78793          	addi	a5,a5,2046 # ffffffffc0211590 <va_pa_offset>
ffffffffc0203d9a:	639c                	ld	a5,0(a5)
}
ffffffffc0203d9c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d9e:	46a1                	li	a3,8
ffffffffc0203da0:	963e                	add	a2,a2,a5
ffffffffc0203da2:	4505                	li	a0,1
}
ffffffffc0203da4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203da6:	f28fc06f          	j	ffffffffc02004ce <ide_write_secs>
ffffffffc0203daa:	86aa                	mv	a3,a0
ffffffffc0203dac:	00002617          	auipc	a2,0x2
ffffffffc0203db0:	1cc60613          	addi	a2,a2,460 # ffffffffc0205f78 <default_pmm_manager+0xe80>
ffffffffc0203db4:	45e5                	li	a1,25
ffffffffc0203db6:	00002517          	auipc	a0,0x2
ffffffffc0203dba:	1aa50513          	addi	a0,a0,426 # ffffffffc0205f60 <default_pmm_manager+0xe68>
ffffffffc0203dbe:	db6fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203dc2:	86b2                	mv	a3,a2
ffffffffc0203dc4:	06a00593          	li	a1,106
ffffffffc0203dc8:	00001617          	auipc	a2,0x1
ffffffffc0203dcc:	38060613          	addi	a2,a2,896 # ffffffffc0205148 <default_pmm_manager+0x50>
ffffffffc0203dd0:	00001517          	auipc	a0,0x1
ffffffffc0203dd4:	41050513          	addi	a0,a0,1040 # ffffffffc02051e0 <default_pmm_manager+0xe8>
ffffffffc0203dd8:	d9cfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203ddc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203ddc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203de0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203de2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203de6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203de8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dec:	f022                	sd	s0,32(sp)
ffffffffc0203dee:	ec26                	sd	s1,24(sp)
ffffffffc0203df0:	e84a                	sd	s2,16(sp)
ffffffffc0203df2:	f406                	sd	ra,40(sp)
ffffffffc0203df4:	e44e                	sd	s3,8(sp)
ffffffffc0203df6:	84aa                	mv	s1,a0
ffffffffc0203df8:	892e                	mv	s2,a1
ffffffffc0203dfa:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203dfe:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203e00:	03067e63          	bleu	a6,a2,ffffffffc0203e3c <printnum+0x60>
ffffffffc0203e04:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203e06:	00805763          	blez	s0,ffffffffc0203e14 <printnum+0x38>
ffffffffc0203e0a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203e0c:	85ca                	mv	a1,s2
ffffffffc0203e0e:	854e                	mv	a0,s3
ffffffffc0203e10:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203e12:	fc65                	bnez	s0,ffffffffc0203e0a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e14:	1a02                	slli	s4,s4,0x20
ffffffffc0203e16:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203e1a:	00002797          	auipc	a5,0x2
ffffffffc0203e1e:	30e78793          	addi	a5,a5,782 # ffffffffc0206128 <error_string+0x38>
ffffffffc0203e22:	9a3e                	add	s4,s4,a5
}
ffffffffc0203e24:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e26:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203e2a:	70a2                	ld	ra,40(sp)
ffffffffc0203e2c:	69a2                	ld	s3,8(sp)
ffffffffc0203e2e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e30:	85ca                	mv	a1,s2
ffffffffc0203e32:	8326                	mv	t1,s1
}
ffffffffc0203e34:	6942                	ld	s2,16(sp)
ffffffffc0203e36:	64e2                	ld	s1,24(sp)
ffffffffc0203e38:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e3a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203e3c:	03065633          	divu	a2,a2,a6
ffffffffc0203e40:	8722                	mv	a4,s0
ffffffffc0203e42:	f9bff0ef          	jal	ra,ffffffffc0203ddc <printnum>
ffffffffc0203e46:	b7f9                	j	ffffffffc0203e14 <printnum+0x38>

ffffffffc0203e48 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203e48:	7119                	addi	sp,sp,-128
ffffffffc0203e4a:	f4a6                	sd	s1,104(sp)
ffffffffc0203e4c:	f0ca                	sd	s2,96(sp)
ffffffffc0203e4e:	e8d2                	sd	s4,80(sp)
ffffffffc0203e50:	e4d6                	sd	s5,72(sp)
ffffffffc0203e52:	e0da                	sd	s6,64(sp)
ffffffffc0203e54:	fc5e                	sd	s7,56(sp)
ffffffffc0203e56:	f862                	sd	s8,48(sp)
ffffffffc0203e58:	f06a                	sd	s10,32(sp)
ffffffffc0203e5a:	fc86                	sd	ra,120(sp)
ffffffffc0203e5c:	f8a2                	sd	s0,112(sp)
ffffffffc0203e5e:	ecce                	sd	s3,88(sp)
ffffffffc0203e60:	f466                	sd	s9,40(sp)
ffffffffc0203e62:	ec6e                	sd	s11,24(sp)
ffffffffc0203e64:	892a                	mv	s2,a0
ffffffffc0203e66:	84ae                	mv	s1,a1
ffffffffc0203e68:	8d32                	mv	s10,a2
ffffffffc0203e6a:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203e6c:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e6e:	00002a17          	auipc	s4,0x2
ffffffffc0203e72:	12aa0a13          	addi	s4,s4,298 # ffffffffc0205f98 <default_pmm_manager+0xea0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e76:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203e7a:	00002c17          	auipc	s8,0x2
ffffffffc0203e7e:	276c0c13          	addi	s8,s8,630 # ffffffffc02060f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e82:	000d4503          	lbu	a0,0(s10)
ffffffffc0203e86:	02500793          	li	a5,37
ffffffffc0203e8a:	001d0413          	addi	s0,s10,1
ffffffffc0203e8e:	00f50e63          	beq	a0,a5,ffffffffc0203eaa <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203e92:	c521                	beqz	a0,ffffffffc0203eda <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e94:	02500993          	li	s3,37
ffffffffc0203e98:	a011                	j	ffffffffc0203e9c <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203e9a:	c121                	beqz	a0,ffffffffc0203eda <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203e9c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e9e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203ea0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ea2:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203ea6:	ff351ae3          	bne	a0,s3,ffffffffc0203e9a <vprintfmt+0x52>
ffffffffc0203eaa:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203eae:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203eb2:	4981                	li	s3,0
ffffffffc0203eb4:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203eb6:	5cfd                	li	s9,-1
ffffffffc0203eb8:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203eba:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203ebe:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ec0:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203ec4:	0ff6f693          	andi	a3,a3,255
ffffffffc0203ec8:	00140d13          	addi	s10,s0,1
ffffffffc0203ecc:	20d5e563          	bltu	a1,a3,ffffffffc02040d6 <vprintfmt+0x28e>
ffffffffc0203ed0:	068a                	slli	a3,a3,0x2
ffffffffc0203ed2:	96d2                	add	a3,a3,s4
ffffffffc0203ed4:	4294                	lw	a3,0(a3)
ffffffffc0203ed6:	96d2                	add	a3,a3,s4
ffffffffc0203ed8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203eda:	70e6                	ld	ra,120(sp)
ffffffffc0203edc:	7446                	ld	s0,112(sp)
ffffffffc0203ede:	74a6                	ld	s1,104(sp)
ffffffffc0203ee0:	7906                	ld	s2,96(sp)
ffffffffc0203ee2:	69e6                	ld	s3,88(sp)
ffffffffc0203ee4:	6a46                	ld	s4,80(sp)
ffffffffc0203ee6:	6aa6                	ld	s5,72(sp)
ffffffffc0203ee8:	6b06                	ld	s6,64(sp)
ffffffffc0203eea:	7be2                	ld	s7,56(sp)
ffffffffc0203eec:	7c42                	ld	s8,48(sp)
ffffffffc0203eee:	7ca2                	ld	s9,40(sp)
ffffffffc0203ef0:	7d02                	ld	s10,32(sp)
ffffffffc0203ef2:	6de2                	ld	s11,24(sp)
ffffffffc0203ef4:	6109                	addi	sp,sp,128
ffffffffc0203ef6:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203ef8:	4705                	li	a4,1
ffffffffc0203efa:	008a8593          	addi	a1,s5,8
ffffffffc0203efe:	01074463          	blt	a4,a6,ffffffffc0203f06 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203f02:	26080363          	beqz	a6,ffffffffc0204168 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203f06:	000ab603          	ld	a2,0(s5)
ffffffffc0203f0a:	46c1                	li	a3,16
ffffffffc0203f0c:	8aae                	mv	s5,a1
ffffffffc0203f0e:	a06d                	j	ffffffffc0203fb8 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203f10:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203f14:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f16:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203f18:	b765                	j	ffffffffc0203ec0 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203f1a:	000aa503          	lw	a0,0(s5)
ffffffffc0203f1e:	85a6                	mv	a1,s1
ffffffffc0203f20:	0aa1                	addi	s5,s5,8
ffffffffc0203f22:	9902                	jalr	s2
            break;
ffffffffc0203f24:	bfb9                	j	ffffffffc0203e82 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203f26:	4705                	li	a4,1
ffffffffc0203f28:	008a8993          	addi	s3,s5,8
ffffffffc0203f2c:	01074463          	blt	a4,a6,ffffffffc0203f34 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203f30:	22080463          	beqz	a6,ffffffffc0204158 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203f34:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203f38:	24044463          	bltz	s0,ffffffffc0204180 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203f3c:	8622                	mv	a2,s0
ffffffffc0203f3e:	8ace                	mv	s5,s3
ffffffffc0203f40:	46a9                	li	a3,10
ffffffffc0203f42:	a89d                	j	ffffffffc0203fb8 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203f44:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f48:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203f4a:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203f4c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203f50:	8fb5                	xor	a5,a5,a3
ffffffffc0203f52:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f56:	1ad74363          	blt	a4,a3,ffffffffc02040fc <vprintfmt+0x2b4>
ffffffffc0203f5a:	00369793          	slli	a5,a3,0x3
ffffffffc0203f5e:	97e2                	add	a5,a5,s8
ffffffffc0203f60:	639c                	ld	a5,0(a5)
ffffffffc0203f62:	18078d63          	beqz	a5,ffffffffc02040fc <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203f66:	86be                	mv	a3,a5
ffffffffc0203f68:	00002617          	auipc	a2,0x2
ffffffffc0203f6c:	27060613          	addi	a2,a2,624 # ffffffffc02061d8 <error_string+0xe8>
ffffffffc0203f70:	85a6                	mv	a1,s1
ffffffffc0203f72:	854a                	mv	a0,s2
ffffffffc0203f74:	240000ef          	jal	ra,ffffffffc02041b4 <printfmt>
ffffffffc0203f78:	b729                	j	ffffffffc0203e82 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203f7a:	00144603          	lbu	a2,1(s0)
ffffffffc0203f7e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f80:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203f82:	bf3d                	j	ffffffffc0203ec0 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203f84:	4705                	li	a4,1
ffffffffc0203f86:	008a8593          	addi	a1,s5,8
ffffffffc0203f8a:	01074463          	blt	a4,a6,ffffffffc0203f92 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203f8e:	1e080263          	beqz	a6,ffffffffc0204172 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203f92:	000ab603          	ld	a2,0(s5)
ffffffffc0203f96:	46a1                	li	a3,8
ffffffffc0203f98:	8aae                	mv	s5,a1
ffffffffc0203f9a:	a839                	j	ffffffffc0203fb8 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0203f9c:	03000513          	li	a0,48
ffffffffc0203fa0:	85a6                	mv	a1,s1
ffffffffc0203fa2:	e03e                	sd	a5,0(sp)
ffffffffc0203fa4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203fa6:	85a6                	mv	a1,s1
ffffffffc0203fa8:	07800513          	li	a0,120
ffffffffc0203fac:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203fae:	0aa1                	addi	s5,s5,8
ffffffffc0203fb0:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203fb4:	6782                	ld	a5,0(sp)
ffffffffc0203fb6:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203fb8:	876e                	mv	a4,s11
ffffffffc0203fba:	85a6                	mv	a1,s1
ffffffffc0203fbc:	854a                	mv	a0,s2
ffffffffc0203fbe:	e1fff0ef          	jal	ra,ffffffffc0203ddc <printnum>
            break;
ffffffffc0203fc2:	b5c1                	j	ffffffffc0203e82 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203fc4:	000ab603          	ld	a2,0(s5)
ffffffffc0203fc8:	0aa1                	addi	s5,s5,8
ffffffffc0203fca:	1c060663          	beqz	a2,ffffffffc0204196 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0203fce:	00160413          	addi	s0,a2,1
ffffffffc0203fd2:	17b05c63          	blez	s11,ffffffffc020414a <vprintfmt+0x302>
ffffffffc0203fd6:	02d00593          	li	a1,45
ffffffffc0203fda:	14b79263          	bne	a5,a1,ffffffffc020411e <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fde:	00064783          	lbu	a5,0(a2)
ffffffffc0203fe2:	0007851b          	sext.w	a0,a5
ffffffffc0203fe6:	c905                	beqz	a0,ffffffffc0204016 <vprintfmt+0x1ce>
ffffffffc0203fe8:	000cc563          	bltz	s9,ffffffffc0203ff2 <vprintfmt+0x1aa>
ffffffffc0203fec:	3cfd                	addiw	s9,s9,-1
ffffffffc0203fee:	036c8263          	beq	s9,s6,ffffffffc0204012 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0203ff2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203ff4:	18098463          	beqz	s3,ffffffffc020417c <vprintfmt+0x334>
ffffffffc0203ff8:	3781                	addiw	a5,a5,-32
ffffffffc0203ffa:	18fbf163          	bleu	a5,s7,ffffffffc020417c <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0203ffe:	03f00513          	li	a0,63
ffffffffc0204002:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204004:	0405                	addi	s0,s0,1
ffffffffc0204006:	fff44783          	lbu	a5,-1(s0)
ffffffffc020400a:	3dfd                	addiw	s11,s11,-1
ffffffffc020400c:	0007851b          	sext.w	a0,a5
ffffffffc0204010:	fd61                	bnez	a0,ffffffffc0203fe8 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0204012:	e7b058e3          	blez	s11,ffffffffc0203e82 <vprintfmt+0x3a>
ffffffffc0204016:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204018:	85a6                	mv	a1,s1
ffffffffc020401a:	02000513          	li	a0,32
ffffffffc020401e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204020:	e60d81e3          	beqz	s11,ffffffffc0203e82 <vprintfmt+0x3a>
ffffffffc0204024:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204026:	85a6                	mv	a1,s1
ffffffffc0204028:	02000513          	li	a0,32
ffffffffc020402c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020402e:	fe0d94e3          	bnez	s11,ffffffffc0204016 <vprintfmt+0x1ce>
ffffffffc0204032:	bd81                	j	ffffffffc0203e82 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204034:	4705                	li	a4,1
ffffffffc0204036:	008a8593          	addi	a1,s5,8
ffffffffc020403a:	01074463          	blt	a4,a6,ffffffffc0204042 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020403e:	12080063          	beqz	a6,ffffffffc020415e <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204042:	000ab603          	ld	a2,0(s5)
ffffffffc0204046:	46a9                	li	a3,10
ffffffffc0204048:	8aae                	mv	s5,a1
ffffffffc020404a:	b7bd                	j	ffffffffc0203fb8 <vprintfmt+0x170>
ffffffffc020404c:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204050:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204054:	846a                	mv	s0,s10
ffffffffc0204056:	b5ad                	j	ffffffffc0203ec0 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204058:	85a6                	mv	a1,s1
ffffffffc020405a:	02500513          	li	a0,37
ffffffffc020405e:	9902                	jalr	s2
            break;
ffffffffc0204060:	b50d                	j	ffffffffc0203e82 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204062:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204066:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020406a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020406c:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020406e:	e40dd9e3          	bgez	s11,ffffffffc0203ec0 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204072:	8de6                	mv	s11,s9
ffffffffc0204074:	5cfd                	li	s9,-1
ffffffffc0204076:	b5a9                	j	ffffffffc0203ec0 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204078:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020407c:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204080:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204082:	bd3d                	j	ffffffffc0203ec0 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204084:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204088:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020408c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020408e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204092:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204096:	fcd56ce3          	bltu	a0,a3,ffffffffc020406e <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020409a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020409c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02040a0:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02040a4:	0196873b          	addw	a4,a3,s9
ffffffffc02040a8:	0017171b          	slliw	a4,a4,0x1
ffffffffc02040ac:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02040b0:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02040b4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02040b8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040bc:	fcd57fe3          	bleu	a3,a0,ffffffffc020409a <vprintfmt+0x252>
ffffffffc02040c0:	b77d                	j	ffffffffc020406e <vprintfmt+0x226>
            if (width < 0)
ffffffffc02040c2:	fffdc693          	not	a3,s11
ffffffffc02040c6:	96fd                	srai	a3,a3,0x3f
ffffffffc02040c8:	00ddfdb3          	and	s11,s11,a3
ffffffffc02040cc:	00144603          	lbu	a2,1(s0)
ffffffffc02040d0:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040d2:	846a                	mv	s0,s10
ffffffffc02040d4:	b3f5                	j	ffffffffc0203ec0 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02040d6:	85a6                	mv	a1,s1
ffffffffc02040d8:	02500513          	li	a0,37
ffffffffc02040dc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040de:	fff44703          	lbu	a4,-1(s0)
ffffffffc02040e2:	02500793          	li	a5,37
ffffffffc02040e6:	8d22                	mv	s10,s0
ffffffffc02040e8:	d8f70de3          	beq	a4,a5,ffffffffc0203e82 <vprintfmt+0x3a>
ffffffffc02040ec:	02500713          	li	a4,37
ffffffffc02040f0:	1d7d                	addi	s10,s10,-1
ffffffffc02040f2:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02040f6:	fee79de3          	bne	a5,a4,ffffffffc02040f0 <vprintfmt+0x2a8>
ffffffffc02040fa:	b361                	j	ffffffffc0203e82 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02040fc:	00002617          	auipc	a2,0x2
ffffffffc0204100:	0cc60613          	addi	a2,a2,204 # ffffffffc02061c8 <error_string+0xd8>
ffffffffc0204104:	85a6                	mv	a1,s1
ffffffffc0204106:	854a                	mv	a0,s2
ffffffffc0204108:	0ac000ef          	jal	ra,ffffffffc02041b4 <printfmt>
ffffffffc020410c:	bb9d                	j	ffffffffc0203e82 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020410e:	00002617          	auipc	a2,0x2
ffffffffc0204112:	0b260613          	addi	a2,a2,178 # ffffffffc02061c0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204116:	00002417          	auipc	s0,0x2
ffffffffc020411a:	0ab40413          	addi	s0,s0,171 # ffffffffc02061c1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020411e:	8532                	mv	a0,a2
ffffffffc0204120:	85e6                	mv	a1,s9
ffffffffc0204122:	e032                	sd	a2,0(sp)
ffffffffc0204124:	e43e                	sd	a5,8(sp)
ffffffffc0204126:	18a000ef          	jal	ra,ffffffffc02042b0 <strnlen>
ffffffffc020412a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020412e:	6602                	ld	a2,0(sp)
ffffffffc0204130:	01b05d63          	blez	s11,ffffffffc020414a <vprintfmt+0x302>
ffffffffc0204134:	67a2                	ld	a5,8(sp)
ffffffffc0204136:	2781                	sext.w	a5,a5
ffffffffc0204138:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020413a:	6522                	ld	a0,8(sp)
ffffffffc020413c:	85a6                	mv	a1,s1
ffffffffc020413e:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204140:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204142:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204144:	6602                	ld	a2,0(sp)
ffffffffc0204146:	fe0d9ae3          	bnez	s11,ffffffffc020413a <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020414a:	00064783          	lbu	a5,0(a2)
ffffffffc020414e:	0007851b          	sext.w	a0,a5
ffffffffc0204152:	e8051be3          	bnez	a0,ffffffffc0203fe8 <vprintfmt+0x1a0>
ffffffffc0204156:	b335                	j	ffffffffc0203e82 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0204158:	000aa403          	lw	s0,0(s5)
ffffffffc020415c:	bbf1                	j	ffffffffc0203f38 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020415e:	000ae603          	lwu	a2,0(s5)
ffffffffc0204162:	46a9                	li	a3,10
ffffffffc0204164:	8aae                	mv	s5,a1
ffffffffc0204166:	bd89                	j	ffffffffc0203fb8 <vprintfmt+0x170>
ffffffffc0204168:	000ae603          	lwu	a2,0(s5)
ffffffffc020416c:	46c1                	li	a3,16
ffffffffc020416e:	8aae                	mv	s5,a1
ffffffffc0204170:	b5a1                	j	ffffffffc0203fb8 <vprintfmt+0x170>
ffffffffc0204172:	000ae603          	lwu	a2,0(s5)
ffffffffc0204176:	46a1                	li	a3,8
ffffffffc0204178:	8aae                	mv	s5,a1
ffffffffc020417a:	bd3d                	j	ffffffffc0203fb8 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020417c:	9902                	jalr	s2
ffffffffc020417e:	b559                	j	ffffffffc0204004 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204180:	85a6                	mv	a1,s1
ffffffffc0204182:	02d00513          	li	a0,45
ffffffffc0204186:	e03e                	sd	a5,0(sp)
ffffffffc0204188:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020418a:	8ace                	mv	s5,s3
ffffffffc020418c:	40800633          	neg	a2,s0
ffffffffc0204190:	46a9                	li	a3,10
ffffffffc0204192:	6782                	ld	a5,0(sp)
ffffffffc0204194:	b515                	j	ffffffffc0203fb8 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0204196:	01b05663          	blez	s11,ffffffffc02041a2 <vprintfmt+0x35a>
ffffffffc020419a:	02d00693          	li	a3,45
ffffffffc020419e:	f6d798e3          	bne	a5,a3,ffffffffc020410e <vprintfmt+0x2c6>
ffffffffc02041a2:	00002417          	auipc	s0,0x2
ffffffffc02041a6:	01f40413          	addi	s0,s0,31 # ffffffffc02061c1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041aa:	02800513          	li	a0,40
ffffffffc02041ae:	02800793          	li	a5,40
ffffffffc02041b2:	bd1d                	j	ffffffffc0203fe8 <vprintfmt+0x1a0>

ffffffffc02041b4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041b4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02041b6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041ba:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041bc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041be:	ec06                	sd	ra,24(sp)
ffffffffc02041c0:	f83a                	sd	a4,48(sp)
ffffffffc02041c2:	fc3e                	sd	a5,56(sp)
ffffffffc02041c4:	e0c2                	sd	a6,64(sp)
ffffffffc02041c6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02041c8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041ca:	c7fff0ef          	jal	ra,ffffffffc0203e48 <vprintfmt>
}
ffffffffc02041ce:	60e2                	ld	ra,24(sp)
ffffffffc02041d0:	6161                	addi	sp,sp,80
ffffffffc02041d2:	8082                	ret

ffffffffc02041d4 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02041d4:	715d                	addi	sp,sp,-80
ffffffffc02041d6:	e486                	sd	ra,72(sp)
ffffffffc02041d8:	e0a2                	sd	s0,64(sp)
ffffffffc02041da:	fc26                	sd	s1,56(sp)
ffffffffc02041dc:	f84a                	sd	s2,48(sp)
ffffffffc02041de:	f44e                	sd	s3,40(sp)
ffffffffc02041e0:	f052                	sd	s4,32(sp)
ffffffffc02041e2:	ec56                	sd	s5,24(sp)
ffffffffc02041e4:	e85a                	sd	s6,16(sp)
ffffffffc02041e6:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02041e8:	c901                	beqz	a0,ffffffffc02041f8 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02041ea:	85aa                	mv	a1,a0
ffffffffc02041ec:	00002517          	auipc	a0,0x2
ffffffffc02041f0:	fec50513          	addi	a0,a0,-20 # ffffffffc02061d8 <error_string+0xe8>
ffffffffc02041f4:	ecbfb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc02041f8:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041fa:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02041fc:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02041fe:	4aa9                	li	s5,10
ffffffffc0204200:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204202:	0000db97          	auipc	s7,0xd
ffffffffc0204206:	e3eb8b93          	addi	s7,s7,-450 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020420a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020420e:	ee9fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204212:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204214:	00054b63          	bltz	a0,ffffffffc020422a <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204218:	00a95b63          	ble	a0,s2,ffffffffc020422e <readline+0x5a>
ffffffffc020421c:	029a5463          	ble	s1,s4,ffffffffc0204244 <readline+0x70>
        c = getchar();
ffffffffc0204220:	ed7fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204224:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204226:	fe0559e3          	bgez	a0,ffffffffc0204218 <readline+0x44>
            return NULL;
ffffffffc020422a:	4501                	li	a0,0
ffffffffc020422c:	a099                	j	ffffffffc0204272 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc020422e:	03341463          	bne	s0,s3,ffffffffc0204256 <readline+0x82>
ffffffffc0204232:	e8b9                	bnez	s1,ffffffffc0204288 <readline+0xb4>
        c = getchar();
ffffffffc0204234:	ec3fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204238:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020423a:	fe0548e3          	bltz	a0,ffffffffc020422a <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020423e:	fea958e3          	ble	a0,s2,ffffffffc020422e <readline+0x5a>
ffffffffc0204242:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204244:	8522                	mv	a0,s0
ffffffffc0204246:	eadfb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc020424a:	009b87b3          	add	a5,s7,s1
ffffffffc020424e:	00878023          	sb	s0,0(a5)
ffffffffc0204252:	2485                	addiw	s1,s1,1
ffffffffc0204254:	bf6d                	j	ffffffffc020420e <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0204256:	01540463          	beq	s0,s5,ffffffffc020425e <readline+0x8a>
ffffffffc020425a:	fb641ae3          	bne	s0,s6,ffffffffc020420e <readline+0x3a>
            cputchar(c);
ffffffffc020425e:	8522                	mv	a0,s0
ffffffffc0204260:	e93fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0204264:	0000d517          	auipc	a0,0xd
ffffffffc0204268:	ddc50513          	addi	a0,a0,-548 # ffffffffc0211040 <buf>
ffffffffc020426c:	94aa                	add	s1,s1,a0
ffffffffc020426e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204272:	60a6                	ld	ra,72(sp)
ffffffffc0204274:	6406                	ld	s0,64(sp)
ffffffffc0204276:	74e2                	ld	s1,56(sp)
ffffffffc0204278:	7942                	ld	s2,48(sp)
ffffffffc020427a:	79a2                	ld	s3,40(sp)
ffffffffc020427c:	7a02                	ld	s4,32(sp)
ffffffffc020427e:	6ae2                	ld	s5,24(sp)
ffffffffc0204280:	6b42                	ld	s6,16(sp)
ffffffffc0204282:	6ba2                	ld	s7,8(sp)
ffffffffc0204284:	6161                	addi	sp,sp,80
ffffffffc0204286:	8082                	ret
            cputchar(c);
ffffffffc0204288:	4521                	li	a0,8
ffffffffc020428a:	e69fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc020428e:	34fd                	addiw	s1,s1,-1
ffffffffc0204290:	bfbd                	j	ffffffffc020420e <readline+0x3a>

ffffffffc0204292 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204292:	00054783          	lbu	a5,0(a0)
ffffffffc0204296:	cb91                	beqz	a5,ffffffffc02042aa <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204298:	4781                	li	a5,0
        cnt ++;
ffffffffc020429a:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020429c:	00f50733          	add	a4,a0,a5
ffffffffc02042a0:	00074703          	lbu	a4,0(a4)
ffffffffc02042a4:	fb7d                	bnez	a4,ffffffffc020429a <strlen+0x8>
    }
    return cnt;
}
ffffffffc02042a6:	853e                	mv	a0,a5
ffffffffc02042a8:	8082                	ret
    size_t cnt = 0;
ffffffffc02042aa:	4781                	li	a5,0
}
ffffffffc02042ac:	853e                	mv	a0,a5
ffffffffc02042ae:	8082                	ret

ffffffffc02042b0 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02042b0:	c185                	beqz	a1,ffffffffc02042d0 <strnlen+0x20>
ffffffffc02042b2:	00054783          	lbu	a5,0(a0)
ffffffffc02042b6:	cf89                	beqz	a5,ffffffffc02042d0 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02042b8:	4781                	li	a5,0
ffffffffc02042ba:	a021                	j	ffffffffc02042c2 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02042bc:	00074703          	lbu	a4,0(a4)
ffffffffc02042c0:	c711                	beqz	a4,ffffffffc02042cc <strnlen+0x1c>
        cnt ++;
ffffffffc02042c2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02042c4:	00f50733          	add	a4,a0,a5
ffffffffc02042c8:	fef59ae3          	bne	a1,a5,ffffffffc02042bc <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02042cc:	853e                	mv	a0,a5
ffffffffc02042ce:	8082                	ret
    size_t cnt = 0;
ffffffffc02042d0:	4781                	li	a5,0
}
ffffffffc02042d2:	853e                	mv	a0,a5
ffffffffc02042d4:	8082                	ret

ffffffffc02042d6 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02042d6:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02042d8:	0585                	addi	a1,a1,1
ffffffffc02042da:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02042de:	0785                	addi	a5,a5,1
ffffffffc02042e0:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02042e4:	fb75                	bnez	a4,ffffffffc02042d8 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02042e6:	8082                	ret

ffffffffc02042e8 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042e8:	00054783          	lbu	a5,0(a0)
ffffffffc02042ec:	0005c703          	lbu	a4,0(a1)
ffffffffc02042f0:	cb91                	beqz	a5,ffffffffc0204304 <strcmp+0x1c>
ffffffffc02042f2:	00e79c63          	bne	a5,a4,ffffffffc020430a <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02042f6:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042f8:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02042fc:	0585                	addi	a1,a1,1
ffffffffc02042fe:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204302:	fbe5                	bnez	a5,ffffffffc02042f2 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204304:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204306:	9d19                	subw	a0,a0,a4
ffffffffc0204308:	8082                	ret
ffffffffc020430a:	0007851b          	sext.w	a0,a5
ffffffffc020430e:	9d19                	subw	a0,a0,a4
ffffffffc0204310:	8082                	ret

ffffffffc0204312 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204312:	00054783          	lbu	a5,0(a0)
ffffffffc0204316:	cb91                	beqz	a5,ffffffffc020432a <strchr+0x18>
        if (*s == c) {
ffffffffc0204318:	00b79563          	bne	a5,a1,ffffffffc0204322 <strchr+0x10>
ffffffffc020431c:	a809                	j	ffffffffc020432e <strchr+0x1c>
ffffffffc020431e:	00b78763          	beq	a5,a1,ffffffffc020432c <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204322:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204324:	00054783          	lbu	a5,0(a0)
ffffffffc0204328:	fbfd                	bnez	a5,ffffffffc020431e <strchr+0xc>
    }
    return NULL;
ffffffffc020432a:	4501                	li	a0,0
}
ffffffffc020432c:	8082                	ret
ffffffffc020432e:	8082                	ret

ffffffffc0204330 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204330:	ca01                	beqz	a2,ffffffffc0204340 <memset+0x10>
ffffffffc0204332:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204334:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204336:	0785                	addi	a5,a5,1
ffffffffc0204338:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020433c:	fec79de3          	bne	a5,a2,ffffffffc0204336 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204340:	8082                	ret

ffffffffc0204342 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204342:	ca19                	beqz	a2,ffffffffc0204358 <memcpy+0x16>
ffffffffc0204344:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204346:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204348:	0585                	addi	a1,a1,1
ffffffffc020434a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020434e:	0785                	addi	a5,a5,1
ffffffffc0204350:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204354:	fec59ae3          	bne	a1,a2,ffffffffc0204348 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204358:	8082                	ret
