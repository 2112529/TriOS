
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
ffffffffc0200042:	64a60613          	addi	a2,a2,1610 # ffffffffc0211688 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2b6040ef          	jal	ra,ffffffffc0204304 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	2de58593          	addi	a1,a1,734 # ffffffffc0204330 <etext+0x2>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	2f650513          	addi	a0,a0,758 # ffffffffc0204350 <etext+0x22>
ffffffffc0200062:	066000ef          	jal	ra,ffffffffc02000c8 <cprintf>

    print_kerninfo();
ffffffffc0200066:	0aa000ef          	jal	ra,ffffffffc0200110 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	30d010ef          	jal	ra,ffffffffc0201b76 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	4f2000ef          	jal	ra,ffffffffc0200560 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	5a8030ef          	jal	ra,ffffffffc020361a <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	414000ef          	jal	ra,ffffffffc020048a <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	7f2020ef          	jal	ra,ffffffffc020286c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	360000ef          	jal	ra,ffffffffc02003de <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc0200082:	460000ef          	jal	ra,ffffffffc02004e2 <intr_enable>


    asm("mret");
ffffffffc0200086:	30200073          	mret
    asm("ebreak");
ffffffffc020008a:	9002                	ebreak
    while (1)
        ;
ffffffffc020008c:	a001                	j	ffffffffc020008c <kern_init+0x56>

ffffffffc020008e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020008e:	1141                	addi	sp,sp,-16
ffffffffc0200090:	e022                	sd	s0,0(sp)
ffffffffc0200092:	e406                	sd	ra,8(sp)
ffffffffc0200094:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200096:	382000ef          	jal	ra,ffffffffc0200418 <cons_putc>
    (*cnt) ++;
ffffffffc020009a:	401c                	lw	a5,0(s0)
}
ffffffffc020009c:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020009e:	2785                	addiw	a5,a5,1
ffffffffc02000a0:	c01c                	sw	a5,0(s0)
}
ffffffffc02000a2:	6402                	ld	s0,0(sp)
ffffffffc02000a4:	0141                	addi	sp,sp,16
ffffffffc02000a6:	8082                	ret

ffffffffc02000a8 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a8:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	86ae                	mv	a3,a1
ffffffffc02000ac:	862a                	mv	a2,a0
ffffffffc02000ae:	006c                	addi	a1,sp,12
ffffffffc02000b0:	00000517          	auipc	a0,0x0
ffffffffc02000b4:	fde50513          	addi	a0,a0,-34 # ffffffffc020008e <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b8:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ba:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000bc:	561030ef          	jal	ra,ffffffffc0203e1c <vprintfmt>
    return cnt;
}
ffffffffc02000c0:	60e2                	ld	ra,24(sp)
ffffffffc02000c2:	4532                	lw	a0,12(sp)
ffffffffc02000c4:	6105                	addi	sp,sp,32
ffffffffc02000c6:	8082                	ret

ffffffffc02000c8 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000c8:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000ca:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	f42e                	sd	a1,40(sp)
ffffffffc02000d0:	f832                	sd	a2,48(sp)
ffffffffc02000d2:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000d4:	862a                	mv	a2,a0
ffffffffc02000d6:	004c                	addi	a1,sp,4
ffffffffc02000d8:	00000517          	auipc	a0,0x0
ffffffffc02000dc:	fb650513          	addi	a0,a0,-74 # ffffffffc020008e <cputch>
ffffffffc02000e0:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000e2:	ec06                	sd	ra,24(sp)
ffffffffc02000e4:	e0ba                	sd	a4,64(sp)
ffffffffc02000e6:	e4be                	sd	a5,72(sp)
ffffffffc02000e8:	e8c2                	sd	a6,80(sp)
ffffffffc02000ea:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000ec:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000ee:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f0:	52d030ef          	jal	ra,ffffffffc0203e1c <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000f4:	60e2                	ld	ra,24(sp)
ffffffffc02000f6:	4512                	lw	a0,4(sp)
ffffffffc02000f8:	6125                	addi	sp,sp,96
ffffffffc02000fa:	8082                	ret

ffffffffc02000fc <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000fc:	31c0006f          	j	ffffffffc0200418 <cons_putc>

ffffffffc0200100 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200100:	1141                	addi	sp,sp,-16
ffffffffc0200102:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200104:	34a000ef          	jal	ra,ffffffffc020044e <cons_getc>
ffffffffc0200108:	dd75                	beqz	a0,ffffffffc0200104 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020010a:	60a2                	ld	ra,8(sp)
ffffffffc020010c:	0141                	addi	sp,sp,16
ffffffffc020010e:	8082                	ret

ffffffffc0200110 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200110:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200112:	00004517          	auipc	a0,0x4
ffffffffc0200116:	27650513          	addi	a0,a0,630 # ffffffffc0204388 <etext+0x5a>
void print_kerninfo(void) {
ffffffffc020011a:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020011c:	fadff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200120:	00000597          	auipc	a1,0x0
ffffffffc0200124:	f1658593          	addi	a1,a1,-234 # ffffffffc0200036 <kern_init>
ffffffffc0200128:	00004517          	auipc	a0,0x4
ffffffffc020012c:	28050513          	addi	a0,a0,640 # ffffffffc02043a8 <etext+0x7a>
ffffffffc0200130:	f99ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200134:	00004597          	auipc	a1,0x4
ffffffffc0200138:	1fa58593          	addi	a1,a1,506 # ffffffffc020432e <etext>
ffffffffc020013c:	00004517          	auipc	a0,0x4
ffffffffc0200140:	28c50513          	addi	a0,a0,652 # ffffffffc02043c8 <etext+0x9a>
ffffffffc0200144:	f85ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200148:	0000a597          	auipc	a1,0xa
ffffffffc020014c:	ef858593          	addi	a1,a1,-264 # ffffffffc020a040 <edata>
ffffffffc0200150:	00004517          	auipc	a0,0x4
ffffffffc0200154:	29850513          	addi	a0,a0,664 # ffffffffc02043e8 <etext+0xba>
ffffffffc0200158:	f71ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020015c:	00011597          	auipc	a1,0x11
ffffffffc0200160:	52c58593          	addi	a1,a1,1324 # ffffffffc0211688 <end>
ffffffffc0200164:	00004517          	auipc	a0,0x4
ffffffffc0200168:	2a450513          	addi	a0,a0,676 # ffffffffc0204408 <etext+0xda>
ffffffffc020016c:	f5dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200170:	00012597          	auipc	a1,0x12
ffffffffc0200174:	91758593          	addi	a1,a1,-1769 # ffffffffc0211a87 <end+0x3ff>
ffffffffc0200178:	00000797          	auipc	a5,0x0
ffffffffc020017c:	ebe78793          	addi	a5,a5,-322 # ffffffffc0200036 <kern_init>
ffffffffc0200180:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200184:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200188:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020018a:	3ff5f593          	andi	a1,a1,1023
ffffffffc020018e:	95be                	add	a1,a1,a5
ffffffffc0200190:	85a9                	srai	a1,a1,0xa
ffffffffc0200192:	00004517          	auipc	a0,0x4
ffffffffc0200196:	29650513          	addi	a0,a0,662 # ffffffffc0204428 <etext+0xfa>
}
ffffffffc020019a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020019c:	f2dff06f          	j	ffffffffc02000c8 <cprintf>

ffffffffc02001a0 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001a0:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001a2:	00004617          	auipc	a2,0x4
ffffffffc02001a6:	1b660613          	addi	a2,a2,438 # ffffffffc0204358 <etext+0x2a>
ffffffffc02001aa:	04e00593          	li	a1,78
ffffffffc02001ae:	00004517          	auipc	a0,0x4
ffffffffc02001b2:	1c250513          	addi	a0,a0,450 # ffffffffc0204370 <etext+0x42>
void print_stackframe(void) {
ffffffffc02001b6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001b8:	1c6000ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02001bc <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001bc:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001be:	00004617          	auipc	a2,0x4
ffffffffc02001c2:	37260613          	addi	a2,a2,882 # ffffffffc0204530 <commands+0xd8>
ffffffffc02001c6:	00004597          	auipc	a1,0x4
ffffffffc02001ca:	38a58593          	addi	a1,a1,906 # ffffffffc0204550 <commands+0xf8>
ffffffffc02001ce:	00004517          	auipc	a0,0x4
ffffffffc02001d2:	38a50513          	addi	a0,a0,906 # ffffffffc0204558 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001d6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001d8:	ef1ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
ffffffffc02001dc:	00004617          	auipc	a2,0x4
ffffffffc02001e0:	38c60613          	addi	a2,a2,908 # ffffffffc0204568 <commands+0x110>
ffffffffc02001e4:	00004597          	auipc	a1,0x4
ffffffffc02001e8:	3ac58593          	addi	a1,a1,940 # ffffffffc0204590 <commands+0x138>
ffffffffc02001ec:	00004517          	auipc	a0,0x4
ffffffffc02001f0:	36c50513          	addi	a0,a0,876 # ffffffffc0204558 <commands+0x100>
ffffffffc02001f4:	ed5ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
ffffffffc02001f8:	00004617          	auipc	a2,0x4
ffffffffc02001fc:	3a860613          	addi	a2,a2,936 # ffffffffc02045a0 <commands+0x148>
ffffffffc0200200:	00004597          	auipc	a1,0x4
ffffffffc0200204:	3c058593          	addi	a1,a1,960 # ffffffffc02045c0 <commands+0x168>
ffffffffc0200208:	00004517          	auipc	a0,0x4
ffffffffc020020c:	35050513          	addi	a0,a0,848 # ffffffffc0204558 <commands+0x100>
ffffffffc0200210:	eb9ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    }
    return 0;
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
ffffffffc0200216:	4501                	li	a0,0
ffffffffc0200218:	0141                	addi	sp,sp,16
ffffffffc020021a:	8082                	ret

ffffffffc020021c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020021c:	1141                	addi	sp,sp,-16
ffffffffc020021e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200220:	ef1ff0ef          	jal	ra,ffffffffc0200110 <print_kerninfo>
    return 0;
}
ffffffffc0200224:	60a2                	ld	ra,8(sp)
ffffffffc0200226:	4501                	li	a0,0
ffffffffc0200228:	0141                	addi	sp,sp,16
ffffffffc020022a:	8082                	ret

ffffffffc020022c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020022c:	1141                	addi	sp,sp,-16
ffffffffc020022e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200230:	f71ff0ef          	jal	ra,ffffffffc02001a0 <print_stackframe>
    return 0;
}
ffffffffc0200234:	60a2                	ld	ra,8(sp)
ffffffffc0200236:	4501                	li	a0,0
ffffffffc0200238:	0141                	addi	sp,sp,16
ffffffffc020023a:	8082                	ret

ffffffffc020023c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020023c:	7115                	addi	sp,sp,-224
ffffffffc020023e:	e962                	sd	s8,144(sp)
ffffffffc0200240:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200242:	00004517          	auipc	a0,0x4
ffffffffc0200246:	25e50513          	addi	a0,a0,606 # ffffffffc02044a0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc020024a:	ed86                	sd	ra,216(sp)
ffffffffc020024c:	e9a2                	sd	s0,208(sp)
ffffffffc020024e:	e5a6                	sd	s1,200(sp)
ffffffffc0200250:	e1ca                	sd	s2,192(sp)
ffffffffc0200252:	fd4e                	sd	s3,184(sp)
ffffffffc0200254:	f952                	sd	s4,176(sp)
ffffffffc0200256:	f556                	sd	s5,168(sp)
ffffffffc0200258:	f15a                	sd	s6,160(sp)
ffffffffc020025a:	ed5e                	sd	s7,152(sp)
ffffffffc020025c:	e566                	sd	s9,136(sp)
ffffffffc020025e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200260:	e69ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200264:	00004517          	auipc	a0,0x4
ffffffffc0200268:	26450513          	addi	a0,a0,612 # ffffffffc02044c8 <commands+0x70>
ffffffffc020026c:	e5dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    if (tf != NULL) {
ffffffffc0200270:	000c0563          	beqz	s8,ffffffffc020027a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200274:	8562                	mv	a0,s8
ffffffffc0200276:	4d6000ef          	jal	ra,ffffffffc020074c <print_trapframe>
ffffffffc020027a:	00004c97          	auipc	s9,0x4
ffffffffc020027e:	1dec8c93          	addi	s9,s9,478 # ffffffffc0204458 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200282:	00005997          	auipc	s3,0x5
ffffffffc0200286:	7d698993          	addi	s3,s3,2006 # ffffffffc0205a58 <default_pmm_manager+0x990>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020028a:	00004917          	auipc	s2,0x4
ffffffffc020028e:	26690913          	addi	s2,s2,614 # ffffffffc02044f0 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200292:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200294:	00004b17          	auipc	s6,0x4
ffffffffc0200298:	264b0b13          	addi	s6,s6,612 # ffffffffc02044f8 <commands+0xa0>
    if (argc == 0) {
ffffffffc020029c:	00004a97          	auipc	s5,0x4
ffffffffc02002a0:	2b4a8a93          	addi	s5,s5,692 # ffffffffc0204550 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002a4:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002a6:	854e                	mv	a0,s3
ffffffffc02002a8:	701030ef          	jal	ra,ffffffffc02041a8 <readline>
ffffffffc02002ac:	842a                	mv	s0,a0
ffffffffc02002ae:	dd65                	beqz	a0,ffffffffc02002a6 <kmonitor+0x6a>
ffffffffc02002b0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002b4:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b6:	c999                	beqz	a1,ffffffffc02002cc <kmonitor+0x90>
ffffffffc02002b8:	854a                	mv	a0,s2
ffffffffc02002ba:	02c040ef          	jal	ra,ffffffffc02042e6 <strchr>
ffffffffc02002be:	c925                	beqz	a0,ffffffffc020032e <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002c0:	00144583          	lbu	a1,1(s0)
ffffffffc02002c4:	00040023          	sb	zero,0(s0)
ffffffffc02002c8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ca:	f5fd                	bnez	a1,ffffffffc02002b8 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002cc:	dce9                	beqz	s1,ffffffffc02002a6 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ce:	6582                	ld	a1,0(sp)
ffffffffc02002d0:	00004d17          	auipc	s10,0x4
ffffffffc02002d4:	188d0d13          	addi	s10,s10,392 # ffffffffc0204458 <commands>
    if (argc == 0) {
ffffffffc02002d8:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002da:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002dc:	0d61                	addi	s10,s10,24
ffffffffc02002de:	7df030ef          	jal	ra,ffffffffc02042bc <strcmp>
ffffffffc02002e2:	c919                	beqz	a0,ffffffffc02002f8 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002e4:	2405                	addiw	s0,s0,1
ffffffffc02002e6:	09740463          	beq	s0,s7,ffffffffc020036e <kmonitor+0x132>
ffffffffc02002ea:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ee:	6582                	ld	a1,0(sp)
ffffffffc02002f0:	0d61                	addi	s10,s10,24
ffffffffc02002f2:	7cb030ef          	jal	ra,ffffffffc02042bc <strcmp>
ffffffffc02002f6:	f57d                	bnez	a0,ffffffffc02002e4 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002f8:	00141793          	slli	a5,s0,0x1
ffffffffc02002fc:	97a2                	add	a5,a5,s0
ffffffffc02002fe:	078e                	slli	a5,a5,0x3
ffffffffc0200300:	97e6                	add	a5,a5,s9
ffffffffc0200302:	6b9c                	ld	a5,16(a5)
ffffffffc0200304:	8662                	mv	a2,s8
ffffffffc0200306:	002c                	addi	a1,sp,8
ffffffffc0200308:	fff4851b          	addiw	a0,s1,-1
ffffffffc020030c:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020030e:	f8055ce3          	bgez	a0,ffffffffc02002a6 <kmonitor+0x6a>
}
ffffffffc0200312:	60ee                	ld	ra,216(sp)
ffffffffc0200314:	644e                	ld	s0,208(sp)
ffffffffc0200316:	64ae                	ld	s1,200(sp)
ffffffffc0200318:	690e                	ld	s2,192(sp)
ffffffffc020031a:	79ea                	ld	s3,184(sp)
ffffffffc020031c:	7a4a                	ld	s4,176(sp)
ffffffffc020031e:	7aaa                	ld	s5,168(sp)
ffffffffc0200320:	7b0a                	ld	s6,160(sp)
ffffffffc0200322:	6bea                	ld	s7,152(sp)
ffffffffc0200324:	6c4a                	ld	s8,144(sp)
ffffffffc0200326:	6caa                	ld	s9,136(sp)
ffffffffc0200328:	6d0a                	ld	s10,128(sp)
ffffffffc020032a:	612d                	addi	sp,sp,224
ffffffffc020032c:	8082                	ret
        if (*buf == '\0') {
ffffffffc020032e:	00044783          	lbu	a5,0(s0)
ffffffffc0200332:	dfc9                	beqz	a5,ffffffffc02002cc <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200334:	03448863          	beq	s1,s4,ffffffffc0200364 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200338:	00349793          	slli	a5,s1,0x3
ffffffffc020033c:	0118                	addi	a4,sp,128
ffffffffc020033e:	97ba                	add	a5,a5,a4
ffffffffc0200340:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200344:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200348:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020034a:	e591                	bnez	a1,ffffffffc0200356 <kmonitor+0x11a>
ffffffffc020034c:	b749                	j	ffffffffc02002ce <kmonitor+0x92>
            buf ++;
ffffffffc020034e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200350:	00044583          	lbu	a1,0(s0)
ffffffffc0200354:	ddad                	beqz	a1,ffffffffc02002ce <kmonitor+0x92>
ffffffffc0200356:	854a                	mv	a0,s2
ffffffffc0200358:	78f030ef          	jal	ra,ffffffffc02042e6 <strchr>
ffffffffc020035c:	d96d                	beqz	a0,ffffffffc020034e <kmonitor+0x112>
ffffffffc020035e:	00044583          	lbu	a1,0(s0)
ffffffffc0200362:	bf91                	j	ffffffffc02002b6 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200364:	45c1                	li	a1,16
ffffffffc0200366:	855a                	mv	a0,s6
ffffffffc0200368:	d61ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
ffffffffc020036c:	b7f1                	j	ffffffffc0200338 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020036e:	6582                	ld	a1,0(sp)
ffffffffc0200370:	00004517          	auipc	a0,0x4
ffffffffc0200374:	1a850513          	addi	a0,a0,424 # ffffffffc0204518 <commands+0xc0>
ffffffffc0200378:	d51ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    return 0;
ffffffffc020037c:	b72d                	j	ffffffffc02002a6 <kmonitor+0x6a>

ffffffffc020037e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020037e:	00011317          	auipc	t1,0x11
ffffffffc0200382:	0c230313          	addi	t1,t1,194 # ffffffffc0211440 <is_panic>
ffffffffc0200386:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020038a:	715d                	addi	sp,sp,-80
ffffffffc020038c:	ec06                	sd	ra,24(sp)
ffffffffc020038e:	e822                	sd	s0,16(sp)
ffffffffc0200390:	f436                	sd	a3,40(sp)
ffffffffc0200392:	f83a                	sd	a4,48(sp)
ffffffffc0200394:	fc3e                	sd	a5,56(sp)
ffffffffc0200396:	e0c2                	sd	a6,64(sp)
ffffffffc0200398:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020039a:	02031c63          	bnez	t1,ffffffffc02003d2 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020039e:	4785                	li	a5,1
ffffffffc02003a0:	8432                	mv	s0,a2
ffffffffc02003a2:	00011717          	auipc	a4,0x11
ffffffffc02003a6:	08f72f23          	sw	a5,158(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003aa:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003ac:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ae:	85aa                	mv	a1,a0
ffffffffc02003b0:	00004517          	auipc	a0,0x4
ffffffffc02003b4:	22050513          	addi	a0,a0,544 # ffffffffc02045d0 <commands+0x178>
    va_start(ap, fmt);
ffffffffc02003b8:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ba:	d0fff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003be:	65a2                	ld	a1,8(sp)
ffffffffc02003c0:	8522                	mv	a0,s0
ffffffffc02003c2:	ce7ff0ef          	jal	ra,ffffffffc02000a8 <vcprintf>
    cprintf("\n");
ffffffffc02003c6:	00005517          	auipc	a0,0x5
ffffffffc02003ca:	1ea50513          	addi	a0,a0,490 # ffffffffc02055b0 <default_pmm_manager+0x4e8>
ffffffffc02003ce:	cfbff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003d2:	116000ef          	jal	ra,ffffffffc02004e8 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003d6:	4501                	li	a0,0
ffffffffc02003d8:	e65ff0ef          	jal	ra,ffffffffc020023c <kmonitor>
ffffffffc02003dc:	bfed                	j	ffffffffc02003d6 <__panic+0x58>

ffffffffc02003de <clock_init>:
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc02003de:	02000793          	li	a5,32
ffffffffc02003e2:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003e6:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003ea:	4581                	li	a1,0
ffffffffc02003ec:	4601                	li	a2,0
ffffffffc02003ee:	4881                	li	a7,0
ffffffffc02003f0:	00000073          	ecall
    clock_set_next_event();

    // initialize time counter 'ticks' to zero
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
ffffffffc02003f4:	00004517          	auipc	a0,0x4
ffffffffc02003f8:	1fc50513          	addi	a0,a0,508 # ffffffffc02045f0 <commands+0x198>
    ticks = 0;
ffffffffc02003fc:	00011797          	auipc	a5,0x11
ffffffffc0200400:	0607ba23          	sd	zero,116(a5) # ffffffffc0211470 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200404:	cc5ff06f          	j	ffffffffc02000c8 <cprintf>

ffffffffc0200408 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200408:	c0102573          	rdtime	a0
ffffffffc020040c:	4581                	li	a1,0
ffffffffc020040e:	4601                	li	a2,0
ffffffffc0200410:	4881                	li	a7,0
ffffffffc0200412:	00000073          	ecall
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200416:	8082                	ret

ffffffffc0200418 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200418:	100027f3          	csrr	a5,sstatus
ffffffffc020041c:	8b89                	andi	a5,a5,2
ffffffffc020041e:	0ff57513          	andi	a0,a0,255
ffffffffc0200422:	e799                	bnez	a5,ffffffffc0200430 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200424:	4581                	li	a1,0
ffffffffc0200426:	4601                	li	a2,0
ffffffffc0200428:	4885                	li	a7,1
ffffffffc020042a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020042e:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200430:	1101                	addi	sp,sp,-32
ffffffffc0200432:	ec06                	sd	ra,24(sp)
ffffffffc0200434:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200436:	0b2000ef          	jal	ra,ffffffffc02004e8 <intr_disable>
ffffffffc020043a:	6522                	ld	a0,8(sp)
ffffffffc020043c:	4581                	li	a1,0
ffffffffc020043e:	4601                	li	a2,0
ffffffffc0200440:	4885                	li	a7,1
ffffffffc0200442:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200446:	60e2                	ld	ra,24(sp)
ffffffffc0200448:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020044a:	0980006f          	j	ffffffffc02004e2 <intr_enable>

ffffffffc020044e <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020044e:	100027f3          	csrr	a5,sstatus
ffffffffc0200452:	8b89                	andi	a5,a5,2
ffffffffc0200454:	eb89                	bnez	a5,ffffffffc0200466 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200456:	4501                	li	a0,0
ffffffffc0200458:	4581                	li	a1,0
ffffffffc020045a:	4601                	li	a2,0
ffffffffc020045c:	4889                	li	a7,2
ffffffffc020045e:	00000073          	ecall
ffffffffc0200462:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200464:	8082                	ret
int cons_getc(void) {
ffffffffc0200466:	1101                	addi	sp,sp,-32
ffffffffc0200468:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020046a:	07e000ef          	jal	ra,ffffffffc02004e8 <intr_disable>
ffffffffc020046e:	4501                	li	a0,0
ffffffffc0200470:	4581                	li	a1,0
ffffffffc0200472:	4601                	li	a2,0
ffffffffc0200474:	4889                	li	a7,2
ffffffffc0200476:	00000073          	ecall
ffffffffc020047a:	2501                	sext.w	a0,a0
ffffffffc020047c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020047e:	064000ef          	jal	ra,ffffffffc02004e2 <intr_enable>
}
ffffffffc0200482:	60e2                	ld	ra,24(sp)
ffffffffc0200484:	6522                	ld	a0,8(sp)
ffffffffc0200486:	6105                	addi	sp,sp,32
ffffffffc0200488:	8082                	ret

ffffffffc020048a <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020048a:	8082                	ret

ffffffffc020048c <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020048c:	00253513          	sltiu	a0,a0,2
ffffffffc0200490:	8082                	ret

ffffffffc0200492 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200492:	03800513          	li	a0,56
ffffffffc0200496:	8082                	ret

ffffffffc0200498 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200498:	0000a797          	auipc	a5,0xa
ffffffffc020049c:	ba878793          	addi	a5,a5,-1112 # ffffffffc020a040 <edata>
ffffffffc02004a0:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004a4:	1141                	addi	sp,sp,-16
ffffffffc02004a6:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004a8:	95be                	add	a1,a1,a5
ffffffffc02004aa:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004ae:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b0:	667030ef          	jal	ra,ffffffffc0204316 <memcpy>
    return 0;
}
ffffffffc02004b4:	60a2                	ld	ra,8(sp)
ffffffffc02004b6:	4501                	li	a0,0
ffffffffc02004b8:	0141                	addi	sp,sp,16
ffffffffc02004ba:	8082                	ret

ffffffffc02004bc <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004bc:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004be:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004c2:	0000a517          	auipc	a0,0xa
ffffffffc02004c6:	b7e50513          	addi	a0,a0,-1154 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc02004ca:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004cc:	00969613          	slli	a2,a3,0x9
ffffffffc02004d0:	85ba                	mv	a1,a4
ffffffffc02004d2:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004d4:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d6:	641030ef          	jal	ra,ffffffffc0204316 <memcpy>
    return 0;
}
ffffffffc02004da:	60a2                	ld	ra,8(sp)
ffffffffc02004dc:	4501                	li	a0,0
ffffffffc02004de:	0141                	addi	sp,sp,16
ffffffffc02004e0:	8082                	ret

ffffffffc02004e2 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e2:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004ee:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f2:	1141                	addi	sp,sp,-16
ffffffffc02004f4:	e022                	sd	s0,0(sp)
ffffffffc02004f6:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f8:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004fc:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004fe:	11053583          	ld	a1,272(a0)
ffffffffc0200502:	05500613          	li	a2,85
ffffffffc0200506:	c399                	beqz	a5,ffffffffc020050c <pgfault_handler+0x1e>
ffffffffc0200508:	04b00613          	li	a2,75
ffffffffc020050c:	11843703          	ld	a4,280(s0)
ffffffffc0200510:	47bd                	li	a5,15
ffffffffc0200512:	05700693          	li	a3,87
ffffffffc0200516:	00f70463          	beq	a4,a5,ffffffffc020051e <pgfault_handler+0x30>
ffffffffc020051a:	05200693          	li	a3,82
ffffffffc020051e:	00004517          	auipc	a0,0x4
ffffffffc0200522:	43250513          	addi	a0,a0,1074 # ffffffffc0204950 <commands+0x4f8>
ffffffffc0200526:	ba3ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020052a:	00011797          	auipc	a5,0x11
ffffffffc020052e:	15678793          	addi	a5,a5,342 # ffffffffc0211680 <check_mm_struct>
ffffffffc0200532:	6388                	ld	a0,0(a5)
ffffffffc0200534:	c911                	beqz	a0,ffffffffc0200548 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200536:	11043603          	ld	a2,272(s0)
ffffffffc020053a:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc020053e:	6402                	ld	s0,0(sp)
ffffffffc0200540:	60a2                	ld	ra,8(sp)
ffffffffc0200542:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200544:	6140306f          	j	ffffffffc0203b58 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200548:	00004617          	auipc	a2,0x4
ffffffffc020054c:	42860613          	addi	a2,a2,1064 # ffffffffc0204970 <commands+0x518>
ffffffffc0200550:	07800593          	li	a1,120
ffffffffc0200554:	00004517          	auipc	a0,0x4
ffffffffc0200558:	43450513          	addi	a0,a0,1076 # ffffffffc0204988 <commands+0x530>
ffffffffc020055c:	e23ff0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0200560 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200560:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200564:	00000797          	auipc	a5,0x0
ffffffffc0200568:	50c78793          	addi	a5,a5,1292 # ffffffffc0200a70 <__alltraps>
ffffffffc020056c:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200570:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200574:	000407b7          	lui	a5,0x40
ffffffffc0200578:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020057c:	8082                	ret

ffffffffc020057e <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020057e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200580:	1141                	addi	sp,sp,-16
ffffffffc0200582:	e022                	sd	s0,0(sp)
ffffffffc0200584:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200586:	00004517          	auipc	a0,0x4
ffffffffc020058a:	41a50513          	addi	a0,a0,1050 # ffffffffc02049a0 <commands+0x548>
void print_regs(struct pushregs *gpr) {
ffffffffc020058e:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	b39ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200594:	640c                	ld	a1,8(s0)
ffffffffc0200596:	00004517          	auipc	a0,0x4
ffffffffc020059a:	42250513          	addi	a0,a0,1058 # ffffffffc02049b8 <commands+0x560>
ffffffffc020059e:	b2bff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a2:	680c                	ld	a1,16(s0)
ffffffffc02005a4:	00004517          	auipc	a0,0x4
ffffffffc02005a8:	42c50513          	addi	a0,a0,1068 # ffffffffc02049d0 <commands+0x578>
ffffffffc02005ac:	b1dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b0:	6c0c                	ld	a1,24(s0)
ffffffffc02005b2:	00004517          	auipc	a0,0x4
ffffffffc02005b6:	43650513          	addi	a0,a0,1078 # ffffffffc02049e8 <commands+0x590>
ffffffffc02005ba:	b0fff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005be:	700c                	ld	a1,32(s0)
ffffffffc02005c0:	00004517          	auipc	a0,0x4
ffffffffc02005c4:	44050513          	addi	a0,a0,1088 # ffffffffc0204a00 <commands+0x5a8>
ffffffffc02005c8:	b01ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005cc:	740c                	ld	a1,40(s0)
ffffffffc02005ce:	00004517          	auipc	a0,0x4
ffffffffc02005d2:	44a50513          	addi	a0,a0,1098 # ffffffffc0204a18 <commands+0x5c0>
ffffffffc02005d6:	af3ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005da:	780c                	ld	a1,48(s0)
ffffffffc02005dc:	00004517          	auipc	a0,0x4
ffffffffc02005e0:	45450513          	addi	a0,a0,1108 # ffffffffc0204a30 <commands+0x5d8>
ffffffffc02005e4:	ae5ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005e8:	7c0c                	ld	a1,56(s0)
ffffffffc02005ea:	00004517          	auipc	a0,0x4
ffffffffc02005ee:	45e50513          	addi	a0,a0,1118 # ffffffffc0204a48 <commands+0x5f0>
ffffffffc02005f2:	ad7ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005f6:	602c                	ld	a1,64(s0)
ffffffffc02005f8:	00004517          	auipc	a0,0x4
ffffffffc02005fc:	46850513          	addi	a0,a0,1128 # ffffffffc0204a60 <commands+0x608>
ffffffffc0200600:	ac9ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200604:	642c                	ld	a1,72(s0)
ffffffffc0200606:	00004517          	auipc	a0,0x4
ffffffffc020060a:	47250513          	addi	a0,a0,1138 # ffffffffc0204a78 <commands+0x620>
ffffffffc020060e:	abbff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200612:	682c                	ld	a1,80(s0)
ffffffffc0200614:	00004517          	auipc	a0,0x4
ffffffffc0200618:	47c50513          	addi	a0,a0,1148 # ffffffffc0204a90 <commands+0x638>
ffffffffc020061c:	aadff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200620:	6c2c                	ld	a1,88(s0)
ffffffffc0200622:	00004517          	auipc	a0,0x4
ffffffffc0200626:	48650513          	addi	a0,a0,1158 # ffffffffc0204aa8 <commands+0x650>
ffffffffc020062a:	a9fff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020062e:	702c                	ld	a1,96(s0)
ffffffffc0200630:	00004517          	auipc	a0,0x4
ffffffffc0200634:	49050513          	addi	a0,a0,1168 # ffffffffc0204ac0 <commands+0x668>
ffffffffc0200638:	a91ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020063c:	742c                	ld	a1,104(s0)
ffffffffc020063e:	00004517          	auipc	a0,0x4
ffffffffc0200642:	49a50513          	addi	a0,a0,1178 # ffffffffc0204ad8 <commands+0x680>
ffffffffc0200646:	a83ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064a:	782c                	ld	a1,112(s0)
ffffffffc020064c:	00004517          	auipc	a0,0x4
ffffffffc0200650:	4a450513          	addi	a0,a0,1188 # ffffffffc0204af0 <commands+0x698>
ffffffffc0200654:	a75ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200658:	7c2c                	ld	a1,120(s0)
ffffffffc020065a:	00004517          	auipc	a0,0x4
ffffffffc020065e:	4ae50513          	addi	a0,a0,1198 # ffffffffc0204b08 <commands+0x6b0>
ffffffffc0200662:	a67ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200666:	604c                	ld	a1,128(s0)
ffffffffc0200668:	00004517          	auipc	a0,0x4
ffffffffc020066c:	4b850513          	addi	a0,a0,1208 # ffffffffc0204b20 <commands+0x6c8>
ffffffffc0200670:	a59ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200674:	644c                	ld	a1,136(s0)
ffffffffc0200676:	00004517          	auipc	a0,0x4
ffffffffc020067a:	4c250513          	addi	a0,a0,1218 # ffffffffc0204b38 <commands+0x6e0>
ffffffffc020067e:	a4bff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200682:	684c                	ld	a1,144(s0)
ffffffffc0200684:	00004517          	auipc	a0,0x4
ffffffffc0200688:	4cc50513          	addi	a0,a0,1228 # ffffffffc0204b50 <commands+0x6f8>
ffffffffc020068c:	a3dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200690:	6c4c                	ld	a1,152(s0)
ffffffffc0200692:	00004517          	auipc	a0,0x4
ffffffffc0200696:	4d650513          	addi	a0,a0,1238 # ffffffffc0204b68 <commands+0x710>
ffffffffc020069a:	a2fff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020069e:	704c                	ld	a1,160(s0)
ffffffffc02006a0:	00004517          	auipc	a0,0x4
ffffffffc02006a4:	4e050513          	addi	a0,a0,1248 # ffffffffc0204b80 <commands+0x728>
ffffffffc02006a8:	a21ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006ac:	744c                	ld	a1,168(s0)
ffffffffc02006ae:	00004517          	auipc	a0,0x4
ffffffffc02006b2:	4ea50513          	addi	a0,a0,1258 # ffffffffc0204b98 <commands+0x740>
ffffffffc02006b6:	a13ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006ba:	784c                	ld	a1,176(s0)
ffffffffc02006bc:	00004517          	auipc	a0,0x4
ffffffffc02006c0:	4f450513          	addi	a0,a0,1268 # ffffffffc0204bb0 <commands+0x758>
ffffffffc02006c4:	a05ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006c8:	7c4c                	ld	a1,184(s0)
ffffffffc02006ca:	00004517          	auipc	a0,0x4
ffffffffc02006ce:	4fe50513          	addi	a0,a0,1278 # ffffffffc0204bc8 <commands+0x770>
ffffffffc02006d2:	9f7ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006d6:	606c                	ld	a1,192(s0)
ffffffffc02006d8:	00004517          	auipc	a0,0x4
ffffffffc02006dc:	50850513          	addi	a0,a0,1288 # ffffffffc0204be0 <commands+0x788>
ffffffffc02006e0:	9e9ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e4:	646c                	ld	a1,200(s0)
ffffffffc02006e6:	00004517          	auipc	a0,0x4
ffffffffc02006ea:	51250513          	addi	a0,a0,1298 # ffffffffc0204bf8 <commands+0x7a0>
ffffffffc02006ee:	9dbff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f2:	686c                	ld	a1,208(s0)
ffffffffc02006f4:	00004517          	auipc	a0,0x4
ffffffffc02006f8:	51c50513          	addi	a0,a0,1308 # ffffffffc0204c10 <commands+0x7b8>
ffffffffc02006fc:	9cdff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200700:	6c6c                	ld	a1,216(s0)
ffffffffc0200702:	00004517          	auipc	a0,0x4
ffffffffc0200706:	52650513          	addi	a0,a0,1318 # ffffffffc0204c28 <commands+0x7d0>
ffffffffc020070a:	9bfff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020070e:	706c                	ld	a1,224(s0)
ffffffffc0200710:	00004517          	auipc	a0,0x4
ffffffffc0200714:	53050513          	addi	a0,a0,1328 # ffffffffc0204c40 <commands+0x7e8>
ffffffffc0200718:	9b1ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020071c:	746c                	ld	a1,232(s0)
ffffffffc020071e:	00004517          	auipc	a0,0x4
ffffffffc0200722:	53a50513          	addi	a0,a0,1338 # ffffffffc0204c58 <commands+0x800>
ffffffffc0200726:	9a3ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072a:	786c                	ld	a1,240(s0)
ffffffffc020072c:	00004517          	auipc	a0,0x4
ffffffffc0200730:	54450513          	addi	a0,a0,1348 # ffffffffc0204c70 <commands+0x818>
ffffffffc0200734:	995ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200738:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073a:	6402                	ld	s0,0(sp)
ffffffffc020073c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	54a50513          	addi	a0,a0,1354 # ffffffffc0204c88 <commands+0x830>
}
ffffffffc0200746:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200748:	981ff06f          	j	ffffffffc02000c8 <cprintf>

ffffffffc020074c <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074c:	1141                	addi	sp,sp,-16
ffffffffc020074e:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200750:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200752:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200754:	00004517          	auipc	a0,0x4
ffffffffc0200758:	54c50513          	addi	a0,a0,1356 # ffffffffc0204ca0 <commands+0x848>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075c:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020075e:	96bff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200762:	8522                	mv	a0,s0
ffffffffc0200764:	e1bff0ef          	jal	ra,ffffffffc020057e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200768:	10043583          	ld	a1,256(s0)
ffffffffc020076c:	00004517          	auipc	a0,0x4
ffffffffc0200770:	54c50513          	addi	a0,a0,1356 # ffffffffc0204cb8 <commands+0x860>
ffffffffc0200774:	955ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200778:	10843583          	ld	a1,264(s0)
ffffffffc020077c:	00004517          	auipc	a0,0x4
ffffffffc0200780:	55450513          	addi	a0,a0,1364 # ffffffffc0204cd0 <commands+0x878>
ffffffffc0200784:	945ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200788:	11043583          	ld	a1,272(s0)
ffffffffc020078c:	00004517          	auipc	a0,0x4
ffffffffc0200790:	55c50513          	addi	a0,a0,1372 # ffffffffc0204ce8 <commands+0x890>
ffffffffc0200794:	935ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200798:	11843583          	ld	a1,280(s0)
}
ffffffffc020079c:	6402                	ld	s0,0(sp)
ffffffffc020079e:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a0:	00004517          	auipc	a0,0x4
ffffffffc02007a4:	56050513          	addi	a0,a0,1376 # ffffffffc0204d00 <commands+0x8a8>
}
ffffffffc02007a8:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	91fff06f          	j	ffffffffc02000c8 <cprintf>

ffffffffc02007ae <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007ae:	11853783          	ld	a5,280(a0)
ffffffffc02007b2:	577d                	li	a4,-1
ffffffffc02007b4:	8305                	srli	a4,a4,0x1
ffffffffc02007b6:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007b8:	472d                	li	a4,11
ffffffffc02007ba:	08f76d63          	bltu	a4,a5,ffffffffc0200854 <interrupt_handler+0xa6>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	e4e70713          	addi	a4,a4,-434 # ffffffffc020460c <commands+0x1b4>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	13050513          	addi	a0,a0,304 # ffffffffc0204900 <commands+0x4a8>
ffffffffc02007d8:	8f1ff06f          	j	ffffffffc02000c8 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	10450513          	addi	a0,a0,260 # ffffffffc02048e0 <commands+0x488>
ffffffffc02007e4:	8e5ff06f          	j	ffffffffc02000c8 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	0b850513          	addi	a0,a0,184 # ffffffffc02048a0 <commands+0x448>
ffffffffc02007f0:	8d9ff06f          	j	ffffffffc02000c8 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	0cc50513          	addi	a0,a0,204 # ffffffffc02048c0 <commands+0x468>
ffffffffc02007fc:	8cdff06f          	j	ffffffffc02000c8 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200800:	00004517          	auipc	a0,0x4
ffffffffc0200804:	13050513          	addi	a0,a0,304 # ffffffffc0204930 <commands+0x4d8>
ffffffffc0200808:	8c1ff06f          	j	ffffffffc02000c8 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020080c:	1141                	addi	sp,sp,-16
ffffffffc020080e:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200810:	bf9ff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            if(ticks==100){
ffffffffc0200814:	00011797          	auipc	a5,0x11
ffffffffc0200818:	c5c78793          	addi	a5,a5,-932 # ffffffffc0211470 <ticks>
ffffffffc020081c:	6394                	ld	a3,0(a5)
ffffffffc020081e:	06400713          	li	a4,100
ffffffffc0200822:	02e68b63          	beq	a3,a4,ffffffffc0200858 <interrupt_handler+0xaa>
            else ticks++;
ffffffffc0200826:	639c                	ld	a5,0(a5)
ffffffffc0200828:	00011717          	auipc	a4,0x11
ffffffffc020082c:	c2070713          	addi	a4,a4,-992 # ffffffffc0211448 <num>
ffffffffc0200830:	0785                	addi	a5,a5,1
ffffffffc0200832:	00011697          	auipc	a3,0x11
ffffffffc0200836:	c2f6bf23          	sd	a5,-962(a3) # ffffffffc0211470 <ticks>
            if(num==10)sbi_shutdown();
ffffffffc020083a:	6318                	ld	a4,0(a4)
ffffffffc020083c:	47a9                	li	a5,10
ffffffffc020083e:	00f71863          	bne	a4,a5,ffffffffc020084e <interrupt_handler+0xa0>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200842:	4501                	li	a0,0
ffffffffc0200844:	4581                	li	a1,0
ffffffffc0200846:	4601                	li	a2,0
ffffffffc0200848:	48a1                	li	a7,8
ffffffffc020084a:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020084e:	60a2                	ld	ra,8(sp)
ffffffffc0200850:	0141                	addi	sp,sp,16
ffffffffc0200852:	8082                	ret
            print_trapframe(tf);
ffffffffc0200854:	ef9ff06f          	j	ffffffffc020074c <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200858:	06400593          	li	a1,100
ffffffffc020085c:	00004517          	auipc	a0,0x4
ffffffffc0200860:	0c450513          	addi	a0,a0,196 # ffffffffc0204920 <commands+0x4c8>
ffffffffc0200864:	865ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
                num++;
ffffffffc0200868:	00011717          	auipc	a4,0x11
ffffffffc020086c:	be070713          	addi	a4,a4,-1056 # ffffffffc0211448 <num>
                ticks=0;
ffffffffc0200870:	00011797          	auipc	a5,0x11
ffffffffc0200874:	c007b023          	sd	zero,-1024(a5) # ffffffffc0211470 <ticks>
                num++;
ffffffffc0200878:	631c                	ld	a5,0(a4)
ffffffffc020087a:	0785                	addi	a5,a5,1
ffffffffc020087c:	00011697          	auipc	a3,0x11
ffffffffc0200880:	bcf6b623          	sd	a5,-1076(a3) # ffffffffc0211448 <num>
ffffffffc0200884:	bf5d                	j	ffffffffc020083a <interrupt_handler+0x8c>

ffffffffc0200886 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200886:	11853783          	ld	a5,280(a0)
ffffffffc020088a:	473d                	li	a4,15
ffffffffc020088c:	1af76463          	bltu	a4,a5,ffffffffc0200a34 <exception_handler+0x1ae>
ffffffffc0200890:	00004717          	auipc	a4,0x4
ffffffffc0200894:	dac70713          	addi	a4,a4,-596 # ffffffffc020463c <commands+0x1e4>
ffffffffc0200898:	078a                	slli	a5,a5,0x2
ffffffffc020089a:	97ba                	add	a5,a5,a4
ffffffffc020089c:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020089e:	1101                	addi	sp,sp,-32
ffffffffc02008a0:	e822                	sd	s0,16(sp)
ffffffffc02008a2:	ec06                	sd	ra,24(sp)
ffffffffc02008a4:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc02008a6:	97ba                	add	a5,a5,a4
ffffffffc02008a8:	842a                	mv	s0,a0
ffffffffc02008aa:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc02008ac:	00004517          	auipc	a0,0x4
ffffffffc02008b0:	fdc50513          	addi	a0,a0,-36 # ffffffffc0204888 <commands+0x430>
ffffffffc02008b4:	815ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008b8:	8522                	mv	a0,s0
ffffffffc02008ba:	c35ff0ef          	jal	ra,ffffffffc02004ee <pgfault_handler>
ffffffffc02008be:	84aa                	mv	s1,a0
ffffffffc02008c0:	16051c63          	bnez	a0,ffffffffc0200a38 <exception_handler+0x1b2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008c4:	60e2                	ld	ra,24(sp)
ffffffffc02008c6:	6442                	ld	s0,16(sp)
ffffffffc02008c8:	64a2                	ld	s1,8(sp)
ffffffffc02008ca:	6105                	addi	sp,sp,32
ffffffffc02008cc:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008ce:	00004517          	auipc	a0,0x4
ffffffffc02008d2:	db250513          	addi	a0,a0,-590 # ffffffffc0204680 <commands+0x228>
}
ffffffffc02008d6:	6442                	ld	s0,16(sp)
ffffffffc02008d8:	60e2                	ld	ra,24(sp)
ffffffffc02008da:	64a2                	ld	s1,8(sp)
ffffffffc02008dc:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008de:	feaff06f          	j	ffffffffc02000c8 <cprintf>
ffffffffc02008e2:	00004517          	auipc	a0,0x4
ffffffffc02008e6:	dbe50513          	addi	a0,a0,-578 # ffffffffc02046a0 <commands+0x248>
ffffffffc02008ea:	b7f5                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Exception type:Illegal instruction\n");
ffffffffc02008ec:	00004517          	auipc	a0,0x4
ffffffffc02008f0:	dd450513          	addi	a0,a0,-556 # ffffffffc02046c0 <commands+0x268>
ffffffffc02008f4:	fd4ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc02008f8:	10843583          	ld	a1,264(s0)
ffffffffc02008fc:	00004517          	auipc	a0,0x4
ffffffffc0200900:	dec50513          	addi	a0,a0,-532 # ffffffffc02046e8 <commands+0x290>
ffffffffc0200904:	fc4ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            tf->epc += 4;
ffffffffc0200908:	10843783          	ld	a5,264(s0)
ffffffffc020090c:	0791                	addi	a5,a5,4
ffffffffc020090e:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200912:	bf4d                	j	ffffffffc02008c4 <exception_handler+0x3e>
            cprintf("Exception type: breakpoint\n");
ffffffffc0200914:	00004517          	auipc	a0,0x4
ffffffffc0200918:	dfc50513          	addi	a0,a0,-516 # ffffffffc0204710 <commands+0x2b8>
ffffffffc020091c:	facff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc0200920:	10843583          	ld	a1,264(s0)
ffffffffc0200924:	00004517          	auipc	a0,0x4
ffffffffc0200928:	e0c50513          	addi	a0,a0,-500 # ffffffffc0204730 <commands+0x2d8>
ffffffffc020092c:	f9cff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            tf->epc += 4;
ffffffffc0200930:	10843783          	ld	a5,264(s0)
ffffffffc0200934:	0791                	addi	a5,a5,4
ffffffffc0200936:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc020093a:	b769                	j	ffffffffc02008c4 <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc020093c:	00004517          	auipc	a0,0x4
ffffffffc0200940:	e1450513          	addi	a0,a0,-492 # ffffffffc0204750 <commands+0x2f8>
ffffffffc0200944:	bf49                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200946:	00004517          	auipc	a0,0x4
ffffffffc020094a:	e2a50513          	addi	a0,a0,-470 # ffffffffc0204770 <commands+0x318>
ffffffffc020094e:	f7aff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200952:	8522                	mv	a0,s0
ffffffffc0200954:	b9bff0ef          	jal	ra,ffffffffc02004ee <pgfault_handler>
ffffffffc0200958:	84aa                	mv	s1,a0
ffffffffc020095a:	d52d                	beqz	a0,ffffffffc02008c4 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020095c:	8522                	mv	a0,s0
ffffffffc020095e:	defff0ef          	jal	ra,ffffffffc020074c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200962:	86a6                	mv	a3,s1
ffffffffc0200964:	00004617          	auipc	a2,0x4
ffffffffc0200968:	e2460613          	addi	a2,a2,-476 # ffffffffc0204788 <commands+0x330>
ffffffffc020096c:	0e800593          	li	a1,232
ffffffffc0200970:	00004517          	auipc	a0,0x4
ffffffffc0200974:	01850513          	addi	a0,a0,24 # ffffffffc0204988 <commands+0x530>
ffffffffc0200978:	a07ff0ef          	jal	ra,ffffffffc020037e <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020097c:	00004517          	auipc	a0,0x4
ffffffffc0200980:	e2c50513          	addi	a0,a0,-468 # ffffffffc02047a8 <commands+0x350>
ffffffffc0200984:	bf89                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200986:	00004517          	auipc	a0,0x4
ffffffffc020098a:	e3a50513          	addi	a0,a0,-454 # ffffffffc02047c0 <commands+0x368>
ffffffffc020098e:	f3aff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200992:	8522                	mv	a0,s0
ffffffffc0200994:	b5bff0ef          	jal	ra,ffffffffc02004ee <pgfault_handler>
ffffffffc0200998:	84aa                	mv	s1,a0
ffffffffc020099a:	f20505e3          	beqz	a0,ffffffffc02008c4 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020099e:	8522                	mv	a0,s0
ffffffffc02009a0:	dadff0ef          	jal	ra,ffffffffc020074c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009a4:	86a6                	mv	a3,s1
ffffffffc02009a6:	00004617          	auipc	a2,0x4
ffffffffc02009aa:	de260613          	addi	a2,a2,-542 # ffffffffc0204788 <commands+0x330>
ffffffffc02009ae:	0f200593          	li	a1,242
ffffffffc02009b2:	00004517          	auipc	a0,0x4
ffffffffc02009b6:	fd650513          	addi	a0,a0,-42 # ffffffffc0204988 <commands+0x530>
ffffffffc02009ba:	9c5ff0ef          	jal	ra,ffffffffc020037e <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc02009be:	00004517          	auipc	a0,0x4
ffffffffc02009c2:	e1a50513          	addi	a0,a0,-486 # ffffffffc02047d8 <commands+0x380>
ffffffffc02009c6:	bf01                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc02009c8:	00004517          	auipc	a0,0x4
ffffffffc02009cc:	e3050513          	addi	a0,a0,-464 # ffffffffc02047f8 <commands+0x3a0>
ffffffffc02009d0:	b719                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc02009d2:	00004517          	auipc	a0,0x4
ffffffffc02009d6:	e4650513          	addi	a0,a0,-442 # ffffffffc0204818 <commands+0x3c0>
ffffffffc02009da:	bdf5                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc02009dc:	00004517          	auipc	a0,0x4
ffffffffc02009e0:	e5c50513          	addi	a0,a0,-420 # ffffffffc0204838 <commands+0x3e0>
ffffffffc02009e4:	bdcd                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc02009e6:	00004517          	auipc	a0,0x4
ffffffffc02009ea:	e7250513          	addi	a0,a0,-398 # ffffffffc0204858 <commands+0x400>
ffffffffc02009ee:	b5e5                	j	ffffffffc02008d6 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc02009f0:	00004517          	auipc	a0,0x4
ffffffffc02009f4:	e8050513          	addi	a0,a0,-384 # ffffffffc0204870 <commands+0x418>
ffffffffc02009f8:	ed0ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009fc:	8522                	mv	a0,s0
ffffffffc02009fe:	af1ff0ef          	jal	ra,ffffffffc02004ee <pgfault_handler>
ffffffffc0200a02:	84aa                	mv	s1,a0
ffffffffc0200a04:	ec0500e3          	beqz	a0,ffffffffc02008c4 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a08:	8522                	mv	a0,s0
ffffffffc0200a0a:	d43ff0ef          	jal	ra,ffffffffc020074c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a0e:	86a6                	mv	a3,s1
ffffffffc0200a10:	00004617          	auipc	a2,0x4
ffffffffc0200a14:	d7860613          	addi	a2,a2,-648 # ffffffffc0204788 <commands+0x330>
ffffffffc0200a18:	10800593          	li	a1,264
ffffffffc0200a1c:	00004517          	auipc	a0,0x4
ffffffffc0200a20:	f6c50513          	addi	a0,a0,-148 # ffffffffc0204988 <commands+0x530>
ffffffffc0200a24:	95bff0ef          	jal	ra,ffffffffc020037e <__panic>
}
ffffffffc0200a28:	6442                	ld	s0,16(sp)
ffffffffc0200a2a:	60e2                	ld	ra,24(sp)
ffffffffc0200a2c:	64a2                	ld	s1,8(sp)
ffffffffc0200a2e:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a30:	d1dff06f          	j	ffffffffc020074c <print_trapframe>
ffffffffc0200a34:	d19ff06f          	j	ffffffffc020074c <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a38:	8522                	mv	a0,s0
ffffffffc0200a3a:	d13ff0ef          	jal	ra,ffffffffc020074c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a3e:	86a6                	mv	a3,s1
ffffffffc0200a40:	00004617          	auipc	a2,0x4
ffffffffc0200a44:	d4860613          	addi	a2,a2,-696 # ffffffffc0204788 <commands+0x330>
ffffffffc0200a48:	10f00593          	li	a1,271
ffffffffc0200a4c:	00004517          	auipc	a0,0x4
ffffffffc0200a50:	f3c50513          	addi	a0,a0,-196 # ffffffffc0204988 <commands+0x530>
ffffffffc0200a54:	92bff0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0200a58 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a58:	11853783          	ld	a5,280(a0)
ffffffffc0200a5c:	0007c463          	bltz	a5,ffffffffc0200a64 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a60:	e27ff06f          	j	ffffffffc0200886 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a64:	d4bff06f          	j	ffffffffc02007ae <interrupt_handler>
	...

ffffffffc0200a70 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a70:	14011073          	csrw	sscratch,sp
ffffffffc0200a74:	712d                	addi	sp,sp,-288
ffffffffc0200a76:	e406                	sd	ra,8(sp)
ffffffffc0200a78:	ec0e                	sd	gp,24(sp)
ffffffffc0200a7a:	f012                	sd	tp,32(sp)
ffffffffc0200a7c:	f416                	sd	t0,40(sp)
ffffffffc0200a7e:	f81a                	sd	t1,48(sp)
ffffffffc0200a80:	fc1e                	sd	t2,56(sp)
ffffffffc0200a82:	e0a2                	sd	s0,64(sp)
ffffffffc0200a84:	e4a6                	sd	s1,72(sp)
ffffffffc0200a86:	e8aa                	sd	a0,80(sp)
ffffffffc0200a88:	ecae                	sd	a1,88(sp)
ffffffffc0200a8a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a8c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a8e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a90:	fcbe                	sd	a5,120(sp)
ffffffffc0200a92:	e142                	sd	a6,128(sp)
ffffffffc0200a94:	e546                	sd	a7,136(sp)
ffffffffc0200a96:	e94a                	sd	s2,144(sp)
ffffffffc0200a98:	ed4e                	sd	s3,152(sp)
ffffffffc0200a9a:	f152                	sd	s4,160(sp)
ffffffffc0200a9c:	f556                	sd	s5,168(sp)
ffffffffc0200a9e:	f95a                	sd	s6,176(sp)
ffffffffc0200aa0:	fd5e                	sd	s7,184(sp)
ffffffffc0200aa2:	e1e2                	sd	s8,192(sp)
ffffffffc0200aa4:	e5e6                	sd	s9,200(sp)
ffffffffc0200aa6:	e9ea                	sd	s10,208(sp)
ffffffffc0200aa8:	edee                	sd	s11,216(sp)
ffffffffc0200aaa:	f1f2                	sd	t3,224(sp)
ffffffffc0200aac:	f5f6                	sd	t4,232(sp)
ffffffffc0200aae:	f9fa                	sd	t5,240(sp)
ffffffffc0200ab0:	fdfe                	sd	t6,248(sp)
ffffffffc0200ab2:	14002473          	csrr	s0,sscratch
ffffffffc0200ab6:	100024f3          	csrr	s1,sstatus
ffffffffc0200aba:	14102973          	csrr	s2,sepc
ffffffffc0200abe:	143029f3          	csrr	s3,stval
ffffffffc0200ac2:	14202a73          	csrr	s4,scause
ffffffffc0200ac6:	e822                	sd	s0,16(sp)
ffffffffc0200ac8:	e226                	sd	s1,256(sp)
ffffffffc0200aca:	e64a                	sd	s2,264(sp)
ffffffffc0200acc:	ea4e                	sd	s3,272(sp)
ffffffffc0200ace:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ad0:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ad2:	f87ff0ef          	jal	ra,ffffffffc0200a58 <trap>

ffffffffc0200ad6 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ad6:	6492                	ld	s1,256(sp)
ffffffffc0200ad8:	6932                	ld	s2,264(sp)
ffffffffc0200ada:	10049073          	csrw	sstatus,s1
ffffffffc0200ade:	14191073          	csrw	sepc,s2
ffffffffc0200ae2:	60a2                	ld	ra,8(sp)
ffffffffc0200ae4:	61e2                	ld	gp,24(sp)
ffffffffc0200ae6:	7202                	ld	tp,32(sp)
ffffffffc0200ae8:	72a2                	ld	t0,40(sp)
ffffffffc0200aea:	7342                	ld	t1,48(sp)
ffffffffc0200aec:	73e2                	ld	t2,56(sp)
ffffffffc0200aee:	6406                	ld	s0,64(sp)
ffffffffc0200af0:	64a6                	ld	s1,72(sp)
ffffffffc0200af2:	6546                	ld	a0,80(sp)
ffffffffc0200af4:	65e6                	ld	a1,88(sp)
ffffffffc0200af6:	7606                	ld	a2,96(sp)
ffffffffc0200af8:	76a6                	ld	a3,104(sp)
ffffffffc0200afa:	7746                	ld	a4,112(sp)
ffffffffc0200afc:	77e6                	ld	a5,120(sp)
ffffffffc0200afe:	680a                	ld	a6,128(sp)
ffffffffc0200b00:	68aa                	ld	a7,136(sp)
ffffffffc0200b02:	694a                	ld	s2,144(sp)
ffffffffc0200b04:	69ea                	ld	s3,152(sp)
ffffffffc0200b06:	7a0a                	ld	s4,160(sp)
ffffffffc0200b08:	7aaa                	ld	s5,168(sp)
ffffffffc0200b0a:	7b4a                	ld	s6,176(sp)
ffffffffc0200b0c:	7bea                	ld	s7,184(sp)
ffffffffc0200b0e:	6c0e                	ld	s8,192(sp)
ffffffffc0200b10:	6cae                	ld	s9,200(sp)
ffffffffc0200b12:	6d4e                	ld	s10,208(sp)
ffffffffc0200b14:	6dee                	ld	s11,216(sp)
ffffffffc0200b16:	7e0e                	ld	t3,224(sp)
ffffffffc0200b18:	7eae                	ld	t4,232(sp)
ffffffffc0200b1a:	7f4e                	ld	t5,240(sp)
ffffffffc0200b1c:	7fee                	ld	t6,248(sp)
ffffffffc0200b1e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200b20:	10200073          	sret
	...

ffffffffc0200b30 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b30:	00011797          	auipc	a5,0x11
ffffffffc0200b34:	94878793          	addi	a5,a5,-1720 # ffffffffc0211478 <free_area>
ffffffffc0200b38:	e79c                	sd	a5,8(a5)
ffffffffc0200b3a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b3c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b40:	8082                	ret

ffffffffc0200b42 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b42:	00011517          	auipc	a0,0x11
ffffffffc0200b46:	94656503          	lwu	a0,-1722(a0) # ffffffffc0211488 <free_area+0x10>
ffffffffc0200b4a:	8082                	ret

ffffffffc0200b4c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b4c:	715d                	addi	sp,sp,-80
ffffffffc0200b4e:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b50:	00011917          	auipc	s2,0x11
ffffffffc0200b54:	92890913          	addi	s2,s2,-1752 # ffffffffc0211478 <free_area>
ffffffffc0200b58:	00893783          	ld	a5,8(s2)
ffffffffc0200b5c:	e486                	sd	ra,72(sp)
ffffffffc0200b5e:	e0a2                	sd	s0,64(sp)
ffffffffc0200b60:	fc26                	sd	s1,56(sp)
ffffffffc0200b62:	f44e                	sd	s3,40(sp)
ffffffffc0200b64:	f052                	sd	s4,32(sp)
ffffffffc0200b66:	ec56                	sd	s5,24(sp)
ffffffffc0200b68:	e85a                	sd	s6,16(sp)
ffffffffc0200b6a:	e45e                	sd	s7,8(sp)
ffffffffc0200b6c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b6e:	31278f63          	beq	a5,s2,ffffffffc0200e8c <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b72:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b76:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b78:	8b05                	andi	a4,a4,1
ffffffffc0200b7a:	30070d63          	beqz	a4,ffffffffc0200e94 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200b7e:	4401                	li	s0,0
ffffffffc0200b80:	4481                	li	s1,0
ffffffffc0200b82:	a031                	j	ffffffffc0200b8e <default_check+0x42>
ffffffffc0200b84:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200b88:	8b09                	andi	a4,a4,2
ffffffffc0200b8a:	30070563          	beqz	a4,ffffffffc0200e94 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200b8e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b92:	679c                	ld	a5,8(a5)
ffffffffc0200b94:	2485                	addiw	s1,s1,1
ffffffffc0200b96:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b98:	ff2796e3          	bne	a5,s2,ffffffffc0200b84 <default_check+0x38>
ffffffffc0200b9c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200b9e:	3ef000ef          	jal	ra,ffffffffc020178c <nr_free_pages>
ffffffffc0200ba2:	75351963          	bne	a0,s3,ffffffffc02012f4 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ba6:	4505                	li	a0,1
ffffffffc0200ba8:	317000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200bac:	8a2a                	mv	s4,a0
ffffffffc0200bae:	48050363          	beqz	a0,ffffffffc0201034 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bb2:	4505                	li	a0,1
ffffffffc0200bb4:	30b000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200bb8:	89aa                	mv	s3,a0
ffffffffc0200bba:	74050d63          	beqz	a0,ffffffffc0201314 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bbe:	4505                	li	a0,1
ffffffffc0200bc0:	2ff000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200bc4:	8aaa                	mv	s5,a0
ffffffffc0200bc6:	4e050763          	beqz	a0,ffffffffc02010b4 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bca:	2f3a0563          	beq	s4,s3,ffffffffc0200eb4 <default_check+0x368>
ffffffffc0200bce:	2eaa0363          	beq	s4,a0,ffffffffc0200eb4 <default_check+0x368>
ffffffffc0200bd2:	2ea98163          	beq	s3,a0,ffffffffc0200eb4 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bd6:	000a2783          	lw	a5,0(s4)
ffffffffc0200bda:	2e079d63          	bnez	a5,ffffffffc0200ed4 <default_check+0x388>
ffffffffc0200bde:	0009a783          	lw	a5,0(s3)
ffffffffc0200be2:	2e079963          	bnez	a5,ffffffffc0200ed4 <default_check+0x388>
ffffffffc0200be6:	411c                	lw	a5,0(a0)
ffffffffc0200be8:	2e079663          	bnez	a5,ffffffffc0200ed4 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bec:	00011797          	auipc	a5,0x11
ffffffffc0200bf0:	9ac78793          	addi	a5,a5,-1620 # ffffffffc0211598 <pages>
ffffffffc0200bf4:	639c                	ld	a5,0(a5)
ffffffffc0200bf6:	00004717          	auipc	a4,0x4
ffffffffc0200bfa:	12270713          	addi	a4,a4,290 # ffffffffc0204d18 <commands+0x8c0>
ffffffffc0200bfe:	630c                	ld	a1,0(a4)
ffffffffc0200c00:	40fa0733          	sub	a4,s4,a5
ffffffffc0200c04:	870d                	srai	a4,a4,0x3
ffffffffc0200c06:	02b70733          	mul	a4,a4,a1
ffffffffc0200c0a:	00005697          	auipc	a3,0x5
ffffffffc0200c0e:	5be68693          	addi	a3,a3,1470 # ffffffffc02061c8 <nbase>
ffffffffc0200c12:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c14:	00011697          	auipc	a3,0x11
ffffffffc0200c18:	84468693          	addi	a3,a3,-1980 # ffffffffc0211458 <npage>
ffffffffc0200c1c:	6294                	ld	a3,0(a3)
ffffffffc0200c1e:	06b2                	slli	a3,a3,0xc
ffffffffc0200c20:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c22:	0732                	slli	a4,a4,0xc
ffffffffc0200c24:	2cd77863          	bleu	a3,a4,ffffffffc0200ef4 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c28:	40f98733          	sub	a4,s3,a5
ffffffffc0200c2c:	870d                	srai	a4,a4,0x3
ffffffffc0200c2e:	02b70733          	mul	a4,a4,a1
ffffffffc0200c32:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c34:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c36:	4ed77f63          	bleu	a3,a4,ffffffffc0201134 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c3a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c3e:	878d                	srai	a5,a5,0x3
ffffffffc0200c40:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c44:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c46:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c48:	34d7f663          	bleu	a3,a5,ffffffffc0200f94 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200c4c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c4e:	00093c03          	ld	s8,0(s2)
ffffffffc0200c52:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c56:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c5a:	00011797          	auipc	a5,0x11
ffffffffc0200c5e:	8327b323          	sd	s2,-2010(a5) # ffffffffc0211480 <free_area+0x8>
ffffffffc0200c62:	00011797          	auipc	a5,0x11
ffffffffc0200c66:	8127bb23          	sd	s2,-2026(a5) # ffffffffc0211478 <free_area>
    nr_free = 0;
ffffffffc0200c6a:	00011797          	auipc	a5,0x11
ffffffffc0200c6e:	8007af23          	sw	zero,-2018(a5) # ffffffffc0211488 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c72:	24d000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200c76:	2e051f63          	bnez	a0,ffffffffc0200f74 <default_check+0x428>
    free_page(p0);
ffffffffc0200c7a:	4585                	li	a1,1
ffffffffc0200c7c:	8552                	mv	a0,s4
ffffffffc0200c7e:	2c9000ef          	jal	ra,ffffffffc0201746 <free_pages>
    free_page(p1);
ffffffffc0200c82:	4585                	li	a1,1
ffffffffc0200c84:	854e                	mv	a0,s3
ffffffffc0200c86:	2c1000ef          	jal	ra,ffffffffc0201746 <free_pages>
    free_page(p2);
ffffffffc0200c8a:	4585                	li	a1,1
ffffffffc0200c8c:	8556                	mv	a0,s5
ffffffffc0200c8e:	2b9000ef          	jal	ra,ffffffffc0201746 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c92:	01092703          	lw	a4,16(s2)
ffffffffc0200c96:	478d                	li	a5,3
ffffffffc0200c98:	2af71e63          	bne	a4,a5,ffffffffc0200f54 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c9c:	4505                	li	a0,1
ffffffffc0200c9e:	221000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200ca2:	89aa                	mv	s3,a0
ffffffffc0200ca4:	28050863          	beqz	a0,ffffffffc0200f34 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ca8:	4505                	li	a0,1
ffffffffc0200caa:	215000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200cae:	8aaa                	mv	s5,a0
ffffffffc0200cb0:	3e050263          	beqz	a0,ffffffffc0201094 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cb4:	4505                	li	a0,1
ffffffffc0200cb6:	209000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200cba:	8a2a                	mv	s4,a0
ffffffffc0200cbc:	3a050c63          	beqz	a0,ffffffffc0201074 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200cc0:	4505                	li	a0,1
ffffffffc0200cc2:	1fd000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200cc6:	38051763          	bnez	a0,ffffffffc0201054 <default_check+0x508>
    free_page(p0);
ffffffffc0200cca:	4585                	li	a1,1
ffffffffc0200ccc:	854e                	mv	a0,s3
ffffffffc0200cce:	279000ef          	jal	ra,ffffffffc0201746 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200cd2:	00893783          	ld	a5,8(s2)
ffffffffc0200cd6:	23278f63          	beq	a5,s2,ffffffffc0200f14 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200cda:	4505                	li	a0,1
ffffffffc0200cdc:	1e3000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200ce0:	32a99a63          	bne	s3,a0,ffffffffc0201014 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200ce4:	4505                	li	a0,1
ffffffffc0200ce6:	1d9000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200cea:	30051563          	bnez	a0,ffffffffc0200ff4 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200cee:	01092783          	lw	a5,16(s2)
ffffffffc0200cf2:	2e079163          	bnez	a5,ffffffffc0200fd4 <default_check+0x488>
    free_page(p);
ffffffffc0200cf6:	854e                	mv	a0,s3
ffffffffc0200cf8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200cfa:	00010797          	auipc	a5,0x10
ffffffffc0200cfe:	7787bf23          	sd	s8,1918(a5) # ffffffffc0211478 <free_area>
ffffffffc0200d02:	00010797          	auipc	a5,0x10
ffffffffc0200d06:	7777bf23          	sd	s7,1918(a5) # ffffffffc0211480 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200d0a:	00010797          	auipc	a5,0x10
ffffffffc0200d0e:	7767af23          	sw	s6,1918(a5) # ffffffffc0211488 <free_area+0x10>
    free_page(p);
ffffffffc0200d12:	235000ef          	jal	ra,ffffffffc0201746 <free_pages>
    free_page(p1);
ffffffffc0200d16:	4585                	li	a1,1
ffffffffc0200d18:	8556                	mv	a0,s5
ffffffffc0200d1a:	22d000ef          	jal	ra,ffffffffc0201746 <free_pages>
    free_page(p2);
ffffffffc0200d1e:	4585                	li	a1,1
ffffffffc0200d20:	8552                	mv	a0,s4
ffffffffc0200d22:	225000ef          	jal	ra,ffffffffc0201746 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d26:	4515                	li	a0,5
ffffffffc0200d28:	197000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200d2c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d2e:	28050363          	beqz	a0,ffffffffc0200fb4 <default_check+0x468>
ffffffffc0200d32:	651c                	ld	a5,8(a0)
ffffffffc0200d34:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d36:	8b85                	andi	a5,a5,1
ffffffffc0200d38:	54079e63          	bnez	a5,ffffffffc0201294 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d3c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d3e:	00093b03          	ld	s6,0(s2)
ffffffffc0200d42:	00893a83          	ld	s5,8(s2)
ffffffffc0200d46:	00010797          	auipc	a5,0x10
ffffffffc0200d4a:	7327b923          	sd	s2,1842(a5) # ffffffffc0211478 <free_area>
ffffffffc0200d4e:	00010797          	auipc	a5,0x10
ffffffffc0200d52:	7327b923          	sd	s2,1842(a5) # ffffffffc0211480 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d56:	169000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200d5a:	50051d63          	bnez	a0,ffffffffc0201274 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d5e:	09098a13          	addi	s4,s3,144
ffffffffc0200d62:	8552                	mv	a0,s4
ffffffffc0200d64:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d66:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200d6a:	00010797          	auipc	a5,0x10
ffffffffc0200d6e:	7007af23          	sw	zero,1822(a5) # ffffffffc0211488 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d72:	1d5000ef          	jal	ra,ffffffffc0201746 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d76:	4511                	li	a0,4
ffffffffc0200d78:	147000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200d7c:	4c051c63          	bnez	a0,ffffffffc0201254 <default_check+0x708>
ffffffffc0200d80:	0989b783          	ld	a5,152(s3)
ffffffffc0200d84:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d86:	8b85                	andi	a5,a5,1
ffffffffc0200d88:	4a078663          	beqz	a5,ffffffffc0201234 <default_check+0x6e8>
ffffffffc0200d8c:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d90:	478d                	li	a5,3
ffffffffc0200d92:	4af71163          	bne	a4,a5,ffffffffc0201234 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d96:	450d                	li	a0,3
ffffffffc0200d98:	127000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200d9c:	8c2a                	mv	s8,a0
ffffffffc0200d9e:	46050b63          	beqz	a0,ffffffffc0201214 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200da2:	4505                	li	a0,1
ffffffffc0200da4:	11b000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200da8:	44051663          	bnez	a0,ffffffffc02011f4 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200dac:	438a1463          	bne	s4,s8,ffffffffc02011d4 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200db0:	4585                	li	a1,1
ffffffffc0200db2:	854e                	mv	a0,s3
ffffffffc0200db4:	193000ef          	jal	ra,ffffffffc0201746 <free_pages>
    free_pages(p1, 3);
ffffffffc0200db8:	458d                	li	a1,3
ffffffffc0200dba:	8552                	mv	a0,s4
ffffffffc0200dbc:	18b000ef          	jal	ra,ffffffffc0201746 <free_pages>
ffffffffc0200dc0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200dc4:	04898c13          	addi	s8,s3,72
ffffffffc0200dc8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200dca:	8b85                	andi	a5,a5,1
ffffffffc0200dcc:	3e078463          	beqz	a5,ffffffffc02011b4 <default_check+0x668>
ffffffffc0200dd0:	0189a703          	lw	a4,24(s3)
ffffffffc0200dd4:	4785                	li	a5,1
ffffffffc0200dd6:	3cf71f63          	bne	a4,a5,ffffffffc02011b4 <default_check+0x668>
ffffffffc0200dda:	008a3783          	ld	a5,8(s4)
ffffffffc0200dde:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200de0:	8b85                	andi	a5,a5,1
ffffffffc0200de2:	3a078963          	beqz	a5,ffffffffc0201194 <default_check+0x648>
ffffffffc0200de6:	018a2703          	lw	a4,24(s4)
ffffffffc0200dea:	478d                	li	a5,3
ffffffffc0200dec:	3af71463          	bne	a4,a5,ffffffffc0201194 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200df0:	4505                	li	a0,1
ffffffffc0200df2:	0cd000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200df6:	36a99f63          	bne	s3,a0,ffffffffc0201174 <default_check+0x628>
    free_page(p0);
ffffffffc0200dfa:	4585                	li	a1,1
ffffffffc0200dfc:	14b000ef          	jal	ra,ffffffffc0201746 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e00:	4509                	li	a0,2
ffffffffc0200e02:	0bd000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200e06:	34aa1763          	bne	s4,a0,ffffffffc0201154 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200e0a:	4589                	li	a1,2
ffffffffc0200e0c:	13b000ef          	jal	ra,ffffffffc0201746 <free_pages>
    free_page(p2);
ffffffffc0200e10:	4585                	li	a1,1
ffffffffc0200e12:	8562                	mv	a0,s8
ffffffffc0200e14:	133000ef          	jal	ra,ffffffffc0201746 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e18:	4515                	li	a0,5
ffffffffc0200e1a:	0a5000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200e1e:	89aa                	mv	s3,a0
ffffffffc0200e20:	48050a63          	beqz	a0,ffffffffc02012b4 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200e24:	4505                	li	a0,1
ffffffffc0200e26:	099000ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0200e2a:	2e051563          	bnez	a0,ffffffffc0201114 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200e2e:	01092783          	lw	a5,16(s2)
ffffffffc0200e32:	2c079163          	bnez	a5,ffffffffc02010f4 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e36:	4595                	li	a1,5
ffffffffc0200e38:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e3a:	00010797          	auipc	a5,0x10
ffffffffc0200e3e:	6577a723          	sw	s7,1614(a5) # ffffffffc0211488 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200e42:	00010797          	auipc	a5,0x10
ffffffffc0200e46:	6367bb23          	sd	s6,1590(a5) # ffffffffc0211478 <free_area>
ffffffffc0200e4a:	00010797          	auipc	a5,0x10
ffffffffc0200e4e:	6357bb23          	sd	s5,1590(a5) # ffffffffc0211480 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e52:	0f5000ef          	jal	ra,ffffffffc0201746 <free_pages>
    return listelm->next;
ffffffffc0200e56:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e5a:	01278963          	beq	a5,s2,ffffffffc0200e6c <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e5e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e62:	679c                	ld	a5,8(a5)
ffffffffc0200e64:	34fd                	addiw	s1,s1,-1
ffffffffc0200e66:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e68:	ff279be3          	bne	a5,s2,ffffffffc0200e5e <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200e6c:	26049463          	bnez	s1,ffffffffc02010d4 <default_check+0x588>
    assert(total == 0);
ffffffffc0200e70:	46041263          	bnez	s0,ffffffffc02012d4 <default_check+0x788>
}
ffffffffc0200e74:	60a6                	ld	ra,72(sp)
ffffffffc0200e76:	6406                	ld	s0,64(sp)
ffffffffc0200e78:	74e2                	ld	s1,56(sp)
ffffffffc0200e7a:	7942                	ld	s2,48(sp)
ffffffffc0200e7c:	79a2                	ld	s3,40(sp)
ffffffffc0200e7e:	7a02                	ld	s4,32(sp)
ffffffffc0200e80:	6ae2                	ld	s5,24(sp)
ffffffffc0200e82:	6b42                	ld	s6,16(sp)
ffffffffc0200e84:	6ba2                	ld	s7,8(sp)
ffffffffc0200e86:	6c02                	ld	s8,0(sp)
ffffffffc0200e88:	6161                	addi	sp,sp,80
ffffffffc0200e8a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e8c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e8e:	4401                	li	s0,0
ffffffffc0200e90:	4481                	li	s1,0
ffffffffc0200e92:	b331                	j	ffffffffc0200b9e <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200e94:	00004697          	auipc	a3,0x4
ffffffffc0200e98:	e8c68693          	addi	a3,a3,-372 # ffffffffc0204d20 <commands+0x8c8>
ffffffffc0200e9c:	00004617          	auipc	a2,0x4
ffffffffc0200ea0:	e9460613          	addi	a2,a2,-364 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0200ea4:	0f000593          	li	a1,240
ffffffffc0200ea8:	00004517          	auipc	a0,0x4
ffffffffc0200eac:	ea050513          	addi	a0,a0,-352 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0200eb0:	cceff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200eb4:	00004697          	auipc	a3,0x4
ffffffffc0200eb8:	f2c68693          	addi	a3,a3,-212 # ffffffffc0204de0 <commands+0x988>
ffffffffc0200ebc:	00004617          	auipc	a2,0x4
ffffffffc0200ec0:	e7460613          	addi	a2,a2,-396 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0200ec4:	0bd00593          	li	a1,189
ffffffffc0200ec8:	00004517          	auipc	a0,0x4
ffffffffc0200ecc:	e8050513          	addi	a0,a0,-384 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0200ed0:	caeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ed4:	00004697          	auipc	a3,0x4
ffffffffc0200ed8:	f3468693          	addi	a3,a3,-204 # ffffffffc0204e08 <commands+0x9b0>
ffffffffc0200edc:	00004617          	auipc	a2,0x4
ffffffffc0200ee0:	e5460613          	addi	a2,a2,-428 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0200ee4:	0be00593          	li	a1,190
ffffffffc0200ee8:	00004517          	auipc	a0,0x4
ffffffffc0200eec:	e6050513          	addi	a0,a0,-416 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0200ef0:	c8eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ef4:	00004697          	auipc	a3,0x4
ffffffffc0200ef8:	f5468693          	addi	a3,a3,-172 # ffffffffc0204e48 <commands+0x9f0>
ffffffffc0200efc:	00004617          	auipc	a2,0x4
ffffffffc0200f00:	e3460613          	addi	a2,a2,-460 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0200f04:	0c000593          	li	a1,192
ffffffffc0200f08:	00004517          	auipc	a0,0x4
ffffffffc0200f0c:	e4050513          	addi	a0,a0,-448 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0200f10:	c6eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f14:	00004697          	auipc	a3,0x4
ffffffffc0200f18:	fbc68693          	addi	a3,a3,-68 # ffffffffc0204ed0 <commands+0xa78>
ffffffffc0200f1c:	00004617          	auipc	a2,0x4
ffffffffc0200f20:	e1460613          	addi	a2,a2,-492 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0200f24:	0d900593          	li	a1,217
ffffffffc0200f28:	00004517          	auipc	a0,0x4
ffffffffc0200f2c:	e2050513          	addi	a0,a0,-480 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0200f30:	c4eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f34:	00004697          	auipc	a3,0x4
ffffffffc0200f38:	e4c68693          	addi	a3,a3,-436 # ffffffffc0204d80 <commands+0x928>
ffffffffc0200f3c:	00004617          	auipc	a2,0x4
ffffffffc0200f40:	df460613          	addi	a2,a2,-524 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0200f44:	0d200593          	li	a1,210
ffffffffc0200f48:	00004517          	auipc	a0,0x4
ffffffffc0200f4c:	e0050513          	addi	a0,a0,-512 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0200f50:	c2eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free == 3);
ffffffffc0200f54:	00004697          	auipc	a3,0x4
ffffffffc0200f58:	f6c68693          	addi	a3,a3,-148 # ffffffffc0204ec0 <commands+0xa68>
ffffffffc0200f5c:	00004617          	auipc	a2,0x4
ffffffffc0200f60:	dd460613          	addi	a2,a2,-556 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0200f64:	0d000593          	li	a1,208
ffffffffc0200f68:	00004517          	auipc	a0,0x4
ffffffffc0200f6c:	de050513          	addi	a0,a0,-544 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0200f70:	c0eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f74:	00004697          	auipc	a3,0x4
ffffffffc0200f78:	f3468693          	addi	a3,a3,-204 # ffffffffc0204ea8 <commands+0xa50>
ffffffffc0200f7c:	00004617          	auipc	a2,0x4
ffffffffc0200f80:	db460613          	addi	a2,a2,-588 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0200f84:	0cb00593          	li	a1,203
ffffffffc0200f88:	00004517          	auipc	a0,0x4
ffffffffc0200f8c:	dc050513          	addi	a0,a0,-576 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0200f90:	beeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f94:	00004697          	auipc	a3,0x4
ffffffffc0200f98:	ef468693          	addi	a3,a3,-268 # ffffffffc0204e88 <commands+0xa30>
ffffffffc0200f9c:	00004617          	auipc	a2,0x4
ffffffffc0200fa0:	d9460613          	addi	a2,a2,-620 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0200fa4:	0c200593          	li	a1,194
ffffffffc0200fa8:	00004517          	auipc	a0,0x4
ffffffffc0200fac:	da050513          	addi	a0,a0,-608 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0200fb0:	bceff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(p0 != NULL);
ffffffffc0200fb4:	00004697          	auipc	a3,0x4
ffffffffc0200fb8:	f6468693          	addi	a3,a3,-156 # ffffffffc0204f18 <commands+0xac0>
ffffffffc0200fbc:	00004617          	auipc	a2,0x4
ffffffffc0200fc0:	d7460613          	addi	a2,a2,-652 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0200fc4:	0f800593          	li	a1,248
ffffffffc0200fc8:	00004517          	auipc	a0,0x4
ffffffffc0200fcc:	d8050513          	addi	a0,a0,-640 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0200fd0:	baeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free == 0);
ffffffffc0200fd4:	00004697          	auipc	a3,0x4
ffffffffc0200fd8:	f3468693          	addi	a3,a3,-204 # ffffffffc0204f08 <commands+0xab0>
ffffffffc0200fdc:	00004617          	auipc	a2,0x4
ffffffffc0200fe0:	d5460613          	addi	a2,a2,-684 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0200fe4:	0df00593          	li	a1,223
ffffffffc0200fe8:	00004517          	auipc	a0,0x4
ffffffffc0200fec:	d6050513          	addi	a0,a0,-672 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0200ff0:	b8eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ff4:	00004697          	auipc	a3,0x4
ffffffffc0200ff8:	eb468693          	addi	a3,a3,-332 # ffffffffc0204ea8 <commands+0xa50>
ffffffffc0200ffc:	00004617          	auipc	a2,0x4
ffffffffc0201000:	d3460613          	addi	a2,a2,-716 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201004:	0dd00593          	li	a1,221
ffffffffc0201008:	00004517          	auipc	a0,0x4
ffffffffc020100c:	d4050513          	addi	a0,a0,-704 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201010:	b6eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201014:	00004697          	auipc	a3,0x4
ffffffffc0201018:	ed468693          	addi	a3,a3,-300 # ffffffffc0204ee8 <commands+0xa90>
ffffffffc020101c:	00004617          	auipc	a2,0x4
ffffffffc0201020:	d1460613          	addi	a2,a2,-748 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201024:	0dc00593          	li	a1,220
ffffffffc0201028:	00004517          	auipc	a0,0x4
ffffffffc020102c:	d2050513          	addi	a0,a0,-736 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201030:	b4eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201034:	00004697          	auipc	a3,0x4
ffffffffc0201038:	d4c68693          	addi	a3,a3,-692 # ffffffffc0204d80 <commands+0x928>
ffffffffc020103c:	00004617          	auipc	a2,0x4
ffffffffc0201040:	cf460613          	addi	a2,a2,-780 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201044:	0b900593          	li	a1,185
ffffffffc0201048:	00004517          	auipc	a0,0x4
ffffffffc020104c:	d0050513          	addi	a0,a0,-768 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201050:	b2eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201054:	00004697          	auipc	a3,0x4
ffffffffc0201058:	e5468693          	addi	a3,a3,-428 # ffffffffc0204ea8 <commands+0xa50>
ffffffffc020105c:	00004617          	auipc	a2,0x4
ffffffffc0201060:	cd460613          	addi	a2,a2,-812 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201064:	0d600593          	li	a1,214
ffffffffc0201068:	00004517          	auipc	a0,0x4
ffffffffc020106c:	ce050513          	addi	a0,a0,-800 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201070:	b0eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201074:	00004697          	auipc	a3,0x4
ffffffffc0201078:	d4c68693          	addi	a3,a3,-692 # ffffffffc0204dc0 <commands+0x968>
ffffffffc020107c:	00004617          	auipc	a2,0x4
ffffffffc0201080:	cb460613          	addi	a2,a2,-844 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201084:	0d400593          	li	a1,212
ffffffffc0201088:	00004517          	auipc	a0,0x4
ffffffffc020108c:	cc050513          	addi	a0,a0,-832 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201090:	aeeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201094:	00004697          	auipc	a3,0x4
ffffffffc0201098:	d0c68693          	addi	a3,a3,-756 # ffffffffc0204da0 <commands+0x948>
ffffffffc020109c:	00004617          	auipc	a2,0x4
ffffffffc02010a0:	c9460613          	addi	a2,a2,-876 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02010a4:	0d300593          	li	a1,211
ffffffffc02010a8:	00004517          	auipc	a0,0x4
ffffffffc02010ac:	ca050513          	addi	a0,a0,-864 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc02010b0:	aceff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010b4:	00004697          	auipc	a3,0x4
ffffffffc02010b8:	d0c68693          	addi	a3,a3,-756 # ffffffffc0204dc0 <commands+0x968>
ffffffffc02010bc:	00004617          	auipc	a2,0x4
ffffffffc02010c0:	c7460613          	addi	a2,a2,-908 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02010c4:	0bb00593          	li	a1,187
ffffffffc02010c8:	00004517          	auipc	a0,0x4
ffffffffc02010cc:	c8050513          	addi	a0,a0,-896 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc02010d0:	aaeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(count == 0);
ffffffffc02010d4:	00004697          	auipc	a3,0x4
ffffffffc02010d8:	f9468693          	addi	a3,a3,-108 # ffffffffc0205068 <commands+0xc10>
ffffffffc02010dc:	00004617          	auipc	a2,0x4
ffffffffc02010e0:	c5460613          	addi	a2,a2,-940 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02010e4:	12500593          	li	a1,293
ffffffffc02010e8:	00004517          	auipc	a0,0x4
ffffffffc02010ec:	c6050513          	addi	a0,a0,-928 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc02010f0:	a8eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free == 0);
ffffffffc02010f4:	00004697          	auipc	a3,0x4
ffffffffc02010f8:	e1468693          	addi	a3,a3,-492 # ffffffffc0204f08 <commands+0xab0>
ffffffffc02010fc:	00004617          	auipc	a2,0x4
ffffffffc0201100:	c3460613          	addi	a2,a2,-972 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201104:	11a00593          	li	a1,282
ffffffffc0201108:	00004517          	auipc	a0,0x4
ffffffffc020110c:	c4050513          	addi	a0,a0,-960 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201110:	a6eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201114:	00004697          	auipc	a3,0x4
ffffffffc0201118:	d9468693          	addi	a3,a3,-620 # ffffffffc0204ea8 <commands+0xa50>
ffffffffc020111c:	00004617          	auipc	a2,0x4
ffffffffc0201120:	c1460613          	addi	a2,a2,-1004 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201124:	11800593          	li	a1,280
ffffffffc0201128:	00004517          	auipc	a0,0x4
ffffffffc020112c:	c2050513          	addi	a0,a0,-992 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201130:	a4eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201134:	00004697          	auipc	a3,0x4
ffffffffc0201138:	d3468693          	addi	a3,a3,-716 # ffffffffc0204e68 <commands+0xa10>
ffffffffc020113c:	00004617          	auipc	a2,0x4
ffffffffc0201140:	bf460613          	addi	a2,a2,-1036 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201144:	0c100593          	li	a1,193
ffffffffc0201148:	00004517          	auipc	a0,0x4
ffffffffc020114c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201150:	a2eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201154:	00004697          	auipc	a3,0x4
ffffffffc0201158:	ed468693          	addi	a3,a3,-300 # ffffffffc0205028 <commands+0xbd0>
ffffffffc020115c:	00004617          	auipc	a2,0x4
ffffffffc0201160:	bd460613          	addi	a2,a2,-1068 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201164:	11200593          	li	a1,274
ffffffffc0201168:	00004517          	auipc	a0,0x4
ffffffffc020116c:	be050513          	addi	a0,a0,-1056 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201170:	a0eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201174:	00004697          	auipc	a3,0x4
ffffffffc0201178:	e9468693          	addi	a3,a3,-364 # ffffffffc0205008 <commands+0xbb0>
ffffffffc020117c:	00004617          	auipc	a2,0x4
ffffffffc0201180:	bb460613          	addi	a2,a2,-1100 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201184:	11000593          	li	a1,272
ffffffffc0201188:	00004517          	auipc	a0,0x4
ffffffffc020118c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201190:	9eeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201194:	00004697          	auipc	a3,0x4
ffffffffc0201198:	e4c68693          	addi	a3,a3,-436 # ffffffffc0204fe0 <commands+0xb88>
ffffffffc020119c:	00004617          	auipc	a2,0x4
ffffffffc02011a0:	b9460613          	addi	a2,a2,-1132 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02011a4:	10e00593          	li	a1,270
ffffffffc02011a8:	00004517          	auipc	a0,0x4
ffffffffc02011ac:	ba050513          	addi	a0,a0,-1120 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc02011b0:	9ceff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02011b4:	00004697          	auipc	a3,0x4
ffffffffc02011b8:	e0468693          	addi	a3,a3,-508 # ffffffffc0204fb8 <commands+0xb60>
ffffffffc02011bc:	00004617          	auipc	a2,0x4
ffffffffc02011c0:	b7460613          	addi	a2,a2,-1164 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02011c4:	10d00593          	li	a1,269
ffffffffc02011c8:	00004517          	auipc	a0,0x4
ffffffffc02011cc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc02011d0:	9aeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(p0 + 2 == p1);
ffffffffc02011d4:	00004697          	auipc	a3,0x4
ffffffffc02011d8:	dd468693          	addi	a3,a3,-556 # ffffffffc0204fa8 <commands+0xb50>
ffffffffc02011dc:	00004617          	auipc	a2,0x4
ffffffffc02011e0:	b5460613          	addi	a2,a2,-1196 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02011e4:	10800593          	li	a1,264
ffffffffc02011e8:	00004517          	auipc	a0,0x4
ffffffffc02011ec:	b6050513          	addi	a0,a0,-1184 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc02011f0:	98eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011f4:	00004697          	auipc	a3,0x4
ffffffffc02011f8:	cb468693          	addi	a3,a3,-844 # ffffffffc0204ea8 <commands+0xa50>
ffffffffc02011fc:	00004617          	auipc	a2,0x4
ffffffffc0201200:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201204:	10700593          	li	a1,263
ffffffffc0201208:	00004517          	auipc	a0,0x4
ffffffffc020120c:	b4050513          	addi	a0,a0,-1216 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201210:	96eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201214:	00004697          	auipc	a3,0x4
ffffffffc0201218:	d7468693          	addi	a3,a3,-652 # ffffffffc0204f88 <commands+0xb30>
ffffffffc020121c:	00004617          	auipc	a2,0x4
ffffffffc0201220:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201224:	10600593          	li	a1,262
ffffffffc0201228:	00004517          	auipc	a0,0x4
ffffffffc020122c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201230:	94eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201234:	00004697          	auipc	a3,0x4
ffffffffc0201238:	d2468693          	addi	a3,a3,-732 # ffffffffc0204f58 <commands+0xb00>
ffffffffc020123c:	00004617          	auipc	a2,0x4
ffffffffc0201240:	af460613          	addi	a2,a2,-1292 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201244:	10500593          	li	a1,261
ffffffffc0201248:	00004517          	auipc	a0,0x4
ffffffffc020124c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201250:	92eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201254:	00004697          	auipc	a3,0x4
ffffffffc0201258:	cec68693          	addi	a3,a3,-788 # ffffffffc0204f40 <commands+0xae8>
ffffffffc020125c:	00004617          	auipc	a2,0x4
ffffffffc0201260:	ad460613          	addi	a2,a2,-1324 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201264:	10400593          	li	a1,260
ffffffffc0201268:	00004517          	auipc	a0,0x4
ffffffffc020126c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201270:	90eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201274:	00004697          	auipc	a3,0x4
ffffffffc0201278:	c3468693          	addi	a3,a3,-972 # ffffffffc0204ea8 <commands+0xa50>
ffffffffc020127c:	00004617          	auipc	a2,0x4
ffffffffc0201280:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201284:	0fe00593          	li	a1,254
ffffffffc0201288:	00004517          	auipc	a0,0x4
ffffffffc020128c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201290:	8eeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(!PageProperty(p0));
ffffffffc0201294:	00004697          	auipc	a3,0x4
ffffffffc0201298:	c9468693          	addi	a3,a3,-876 # ffffffffc0204f28 <commands+0xad0>
ffffffffc020129c:	00004617          	auipc	a2,0x4
ffffffffc02012a0:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02012a4:	0f900593          	li	a1,249
ffffffffc02012a8:	00004517          	auipc	a0,0x4
ffffffffc02012ac:	aa050513          	addi	a0,a0,-1376 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc02012b0:	8ceff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012b4:	00004697          	auipc	a3,0x4
ffffffffc02012b8:	d9468693          	addi	a3,a3,-620 # ffffffffc0205048 <commands+0xbf0>
ffffffffc02012bc:	00004617          	auipc	a2,0x4
ffffffffc02012c0:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02012c4:	11700593          	li	a1,279
ffffffffc02012c8:	00004517          	auipc	a0,0x4
ffffffffc02012cc:	a8050513          	addi	a0,a0,-1408 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc02012d0:	8aeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(total == 0);
ffffffffc02012d4:	00004697          	auipc	a3,0x4
ffffffffc02012d8:	da468693          	addi	a3,a3,-604 # ffffffffc0205078 <commands+0xc20>
ffffffffc02012dc:	00004617          	auipc	a2,0x4
ffffffffc02012e0:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02012e4:	12600593          	li	a1,294
ffffffffc02012e8:	00004517          	auipc	a0,0x4
ffffffffc02012ec:	a6050513          	addi	a0,a0,-1440 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc02012f0:	88eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(total == nr_free_pages());
ffffffffc02012f4:	00004697          	auipc	a3,0x4
ffffffffc02012f8:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0204d60 <commands+0x908>
ffffffffc02012fc:	00004617          	auipc	a2,0x4
ffffffffc0201300:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201304:	0f300593          	li	a1,243
ffffffffc0201308:	00004517          	auipc	a0,0x4
ffffffffc020130c:	a4050513          	addi	a0,a0,-1472 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201310:	86eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201314:	00004697          	auipc	a3,0x4
ffffffffc0201318:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0204da0 <commands+0x948>
ffffffffc020131c:	00004617          	auipc	a2,0x4
ffffffffc0201320:	a1460613          	addi	a2,a2,-1516 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201324:	0ba00593          	li	a1,186
ffffffffc0201328:	00004517          	auipc	a0,0x4
ffffffffc020132c:	a2050513          	addi	a0,a0,-1504 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc0201330:	84eff0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0201334 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201334:	1141                	addi	sp,sp,-16
ffffffffc0201336:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201338:	18058063          	beqz	a1,ffffffffc02014b8 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc020133c:	00359693          	slli	a3,a1,0x3
ffffffffc0201340:	96ae                	add	a3,a3,a1
ffffffffc0201342:	068e                	slli	a3,a3,0x3
ffffffffc0201344:	96aa                	add	a3,a3,a0
ffffffffc0201346:	02d50d63          	beq	a0,a3,ffffffffc0201380 <default_free_pages+0x4c>
ffffffffc020134a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020134c:	8b85                	andi	a5,a5,1
ffffffffc020134e:	14079563          	bnez	a5,ffffffffc0201498 <default_free_pages+0x164>
ffffffffc0201352:	651c                	ld	a5,8(a0)
ffffffffc0201354:	8385                	srli	a5,a5,0x1
ffffffffc0201356:	8b85                	andi	a5,a5,1
ffffffffc0201358:	14079063          	bnez	a5,ffffffffc0201498 <default_free_pages+0x164>
ffffffffc020135c:	87aa                	mv	a5,a0
ffffffffc020135e:	a809                	j	ffffffffc0201370 <default_free_pages+0x3c>
ffffffffc0201360:	6798                	ld	a4,8(a5)
ffffffffc0201362:	8b05                	andi	a4,a4,1
ffffffffc0201364:	12071a63          	bnez	a4,ffffffffc0201498 <default_free_pages+0x164>
ffffffffc0201368:	6798                	ld	a4,8(a5)
ffffffffc020136a:	8b09                	andi	a4,a4,2
ffffffffc020136c:	12071663          	bnez	a4,ffffffffc0201498 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0201370:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201374:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201378:	04878793          	addi	a5,a5,72
ffffffffc020137c:	fed792e3          	bne	a5,a3,ffffffffc0201360 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201380:	2581                	sext.w	a1,a1
ffffffffc0201382:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201384:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201388:	4789                	li	a5,2
ffffffffc020138a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020138e:	00010697          	auipc	a3,0x10
ffffffffc0201392:	0ea68693          	addi	a3,a3,234 # ffffffffc0211478 <free_area>
ffffffffc0201396:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201398:	669c                	ld	a5,8(a3)
ffffffffc020139a:	9db9                	addw	a1,a1,a4
ffffffffc020139c:	00010717          	auipc	a4,0x10
ffffffffc02013a0:	0eb72623          	sw	a1,236(a4) # ffffffffc0211488 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02013a4:	08d78f63          	beq	a5,a3,ffffffffc0201442 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc02013a8:	fe078713          	addi	a4,a5,-32
ffffffffc02013ac:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02013ae:	4801                	li	a6,0
ffffffffc02013b0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02013b4:	00e56a63          	bltu	a0,a4,ffffffffc02013c8 <default_free_pages+0x94>
    return listelm->next;
ffffffffc02013b8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02013ba:	02d70563          	beq	a4,a3,ffffffffc02013e4 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013be:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013c0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02013c4:	fee57ae3          	bleu	a4,a0,ffffffffc02013b8 <default_free_pages+0x84>
ffffffffc02013c8:	00080663          	beqz	a6,ffffffffc02013d4 <default_free_pages+0xa0>
ffffffffc02013cc:	00010817          	auipc	a6,0x10
ffffffffc02013d0:	0ab83623          	sd	a1,172(a6) # ffffffffc0211478 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013d4:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02013d6:	e390                	sd	a2,0(a5)
ffffffffc02013d8:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02013da:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013dc:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc02013de:	02d59163          	bne	a1,a3,ffffffffc0201400 <default_free_pages+0xcc>
ffffffffc02013e2:	a091                	j	ffffffffc0201426 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02013e4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013e6:	f514                	sd	a3,40(a0)
ffffffffc02013e8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013ea:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02013ec:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013ee:	00d70563          	beq	a4,a3,ffffffffc02013f8 <default_free_pages+0xc4>
ffffffffc02013f2:	4805                	li	a6,1
ffffffffc02013f4:	87ba                	mv	a5,a4
ffffffffc02013f6:	b7e9                	j	ffffffffc02013c0 <default_free_pages+0x8c>
ffffffffc02013f8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02013fa:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02013fc:	02d78163          	beq	a5,a3,ffffffffc020141e <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0201400:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201404:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc0201408:	02081713          	slli	a4,a6,0x20
ffffffffc020140c:	9301                	srli	a4,a4,0x20
ffffffffc020140e:	00371793          	slli	a5,a4,0x3
ffffffffc0201412:	97ba                	add	a5,a5,a4
ffffffffc0201414:	078e                	slli	a5,a5,0x3
ffffffffc0201416:	97b2                	add	a5,a5,a2
ffffffffc0201418:	02f50e63          	beq	a0,a5,ffffffffc0201454 <default_free_pages+0x120>
ffffffffc020141c:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc020141e:	fe078713          	addi	a4,a5,-32
ffffffffc0201422:	00d78d63          	beq	a5,a3,ffffffffc020143c <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0201426:	4d0c                	lw	a1,24(a0)
ffffffffc0201428:	02059613          	slli	a2,a1,0x20
ffffffffc020142c:	9201                	srli	a2,a2,0x20
ffffffffc020142e:	00361693          	slli	a3,a2,0x3
ffffffffc0201432:	96b2                	add	a3,a3,a2
ffffffffc0201434:	068e                	slli	a3,a3,0x3
ffffffffc0201436:	96aa                	add	a3,a3,a0
ffffffffc0201438:	04d70063          	beq	a4,a3,ffffffffc0201478 <default_free_pages+0x144>
}
ffffffffc020143c:	60a2                	ld	ra,8(sp)
ffffffffc020143e:	0141                	addi	sp,sp,16
ffffffffc0201440:	8082                	ret
ffffffffc0201442:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201444:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0201448:	e398                	sd	a4,0(a5)
ffffffffc020144a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020144c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020144e:	f11c                	sd	a5,32(a0)
}
ffffffffc0201450:	0141                	addi	sp,sp,16
ffffffffc0201452:	8082                	ret
            p->property += base->property;
ffffffffc0201454:	4d1c                	lw	a5,24(a0)
ffffffffc0201456:	0107883b          	addw	a6,a5,a6
ffffffffc020145a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020145e:	57f5                	li	a5,-3
ffffffffc0201460:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201464:	02053803          	ld	a6,32(a0)
ffffffffc0201468:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc020146a:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020146c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201470:	659c                	ld	a5,8(a1)
ffffffffc0201472:	01073023          	sd	a6,0(a4)
ffffffffc0201476:	b765                	j	ffffffffc020141e <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0201478:	ff87a703          	lw	a4,-8(a5)
ffffffffc020147c:	fe878693          	addi	a3,a5,-24
ffffffffc0201480:	9db9                	addw	a1,a1,a4
ffffffffc0201482:	cd0c                	sw	a1,24(a0)
ffffffffc0201484:	5775                	li	a4,-3
ffffffffc0201486:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020148a:	6398                	ld	a4,0(a5)
ffffffffc020148c:	679c                	ld	a5,8(a5)
}
ffffffffc020148e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201490:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201492:	e398                	sd	a4,0(a5)
ffffffffc0201494:	0141                	addi	sp,sp,16
ffffffffc0201496:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201498:	00004697          	auipc	a3,0x4
ffffffffc020149c:	bf068693          	addi	a3,a3,-1040 # ffffffffc0205088 <commands+0xc30>
ffffffffc02014a0:	00004617          	auipc	a2,0x4
ffffffffc02014a4:	89060613          	addi	a2,a2,-1904 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02014a8:	08300593          	li	a1,131
ffffffffc02014ac:	00004517          	auipc	a0,0x4
ffffffffc02014b0:	89c50513          	addi	a0,a0,-1892 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc02014b4:	ecbfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(n > 0);
ffffffffc02014b8:	00004697          	auipc	a3,0x4
ffffffffc02014bc:	bf868693          	addi	a3,a3,-1032 # ffffffffc02050b0 <commands+0xc58>
ffffffffc02014c0:	00004617          	auipc	a2,0x4
ffffffffc02014c4:	87060613          	addi	a2,a2,-1936 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02014c8:	08000593          	li	a1,128
ffffffffc02014cc:	00004517          	auipc	a0,0x4
ffffffffc02014d0:	87c50513          	addi	a0,a0,-1924 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc02014d4:	eabfe0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02014d8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02014d8:	cd51                	beqz	a0,ffffffffc0201574 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc02014da:	00010597          	auipc	a1,0x10
ffffffffc02014de:	f9e58593          	addi	a1,a1,-98 # ffffffffc0211478 <free_area>
ffffffffc02014e2:	0105a803          	lw	a6,16(a1)
ffffffffc02014e6:	862a                	mv	a2,a0
ffffffffc02014e8:	02081793          	slli	a5,a6,0x20
ffffffffc02014ec:	9381                	srli	a5,a5,0x20
ffffffffc02014ee:	00a7ee63          	bltu	a5,a0,ffffffffc020150a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02014f2:	87ae                	mv	a5,a1
ffffffffc02014f4:	a801                	j	ffffffffc0201504 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02014f6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014fa:	02071693          	slli	a3,a4,0x20
ffffffffc02014fe:	9281                	srli	a3,a3,0x20
ffffffffc0201500:	00c6f763          	bleu	a2,a3,ffffffffc020150e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201504:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201506:	feb798e3          	bne	a5,a1,ffffffffc02014f6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020150a:	4501                	li	a0,0
}
ffffffffc020150c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020150e:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc0201512:	dd6d                	beqz	a0,ffffffffc020150c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201514:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201518:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020151c:	00060e1b          	sext.w	t3,a2
ffffffffc0201520:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201524:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201528:	02d67b63          	bleu	a3,a2,ffffffffc020155e <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc020152c:	00361693          	slli	a3,a2,0x3
ffffffffc0201530:	96b2                	add	a3,a3,a2
ffffffffc0201532:	068e                	slli	a3,a3,0x3
ffffffffc0201534:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201536:	41c7073b          	subw	a4,a4,t3
ffffffffc020153a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020153c:	00868613          	addi	a2,a3,8
ffffffffc0201540:	4709                	li	a4,2
ffffffffc0201542:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201546:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020154a:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020154e:	0105a803          	lw	a6,16(a1)
ffffffffc0201552:	e310                	sd	a2,0(a4)
ffffffffc0201554:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201558:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020155a:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020155e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201562:	00010717          	auipc	a4,0x10
ffffffffc0201566:	f3072323          	sw	a6,-218(a4) # ffffffffc0211488 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020156a:	5775                	li	a4,-3
ffffffffc020156c:	17a1                	addi	a5,a5,-24
ffffffffc020156e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201572:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201574:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201576:	00004697          	auipc	a3,0x4
ffffffffc020157a:	b3a68693          	addi	a3,a3,-1222 # ffffffffc02050b0 <commands+0xc58>
ffffffffc020157e:	00003617          	auipc	a2,0x3
ffffffffc0201582:	7b260613          	addi	a2,a2,1970 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201586:	06200593          	li	a1,98
ffffffffc020158a:	00003517          	auipc	a0,0x3
ffffffffc020158e:	7be50513          	addi	a0,a0,1982 # ffffffffc0204d48 <commands+0x8f0>
default_alloc_pages(size_t n) {
ffffffffc0201592:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201594:	debfe0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0201598 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201598:	1141                	addi	sp,sp,-16
ffffffffc020159a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020159c:	c1fd                	beqz	a1,ffffffffc0201682 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020159e:	00359693          	slli	a3,a1,0x3
ffffffffc02015a2:	96ae                	add	a3,a3,a1
ffffffffc02015a4:	068e                	slli	a3,a3,0x3
ffffffffc02015a6:	96aa                	add	a3,a3,a0
ffffffffc02015a8:	02d50463          	beq	a0,a3,ffffffffc02015d0 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02015ac:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02015ae:	87aa                	mv	a5,a0
ffffffffc02015b0:	8b05                	andi	a4,a4,1
ffffffffc02015b2:	e709                	bnez	a4,ffffffffc02015bc <default_init_memmap+0x24>
ffffffffc02015b4:	a07d                	j	ffffffffc0201662 <default_init_memmap+0xca>
ffffffffc02015b6:	6798                	ld	a4,8(a5)
ffffffffc02015b8:	8b05                	andi	a4,a4,1
ffffffffc02015ba:	c745                	beqz	a4,ffffffffc0201662 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02015bc:	0007ac23          	sw	zero,24(a5)
ffffffffc02015c0:	0007b423          	sd	zero,8(a5)
ffffffffc02015c4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015c8:	04878793          	addi	a5,a5,72
ffffffffc02015cc:	fed795e3          	bne	a5,a3,ffffffffc02015b6 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc02015d0:	2581                	sext.w	a1,a1
ffffffffc02015d2:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015d4:	4789                	li	a5,2
ffffffffc02015d6:	00850713          	addi	a4,a0,8
ffffffffc02015da:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02015de:	00010697          	auipc	a3,0x10
ffffffffc02015e2:	e9a68693          	addi	a3,a3,-358 # ffffffffc0211478 <free_area>
ffffffffc02015e6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015e8:	669c                	ld	a5,8(a3)
ffffffffc02015ea:	9db9                	addw	a1,a1,a4
ffffffffc02015ec:	00010717          	auipc	a4,0x10
ffffffffc02015f0:	e8b72e23          	sw	a1,-356(a4) # ffffffffc0211488 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02015f4:	04d78a63          	beq	a5,a3,ffffffffc0201648 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02015f8:	fe078713          	addi	a4,a5,-32
ffffffffc02015fc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015fe:	4801                	li	a6,0
ffffffffc0201600:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201604:	00e56a63          	bltu	a0,a4,ffffffffc0201618 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0201608:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020160a:	02d70563          	beq	a4,a3,ffffffffc0201634 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020160e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201610:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201614:	fee57ae3          	bleu	a4,a0,ffffffffc0201608 <default_init_memmap+0x70>
ffffffffc0201618:	00080663          	beqz	a6,ffffffffc0201624 <default_init_memmap+0x8c>
ffffffffc020161c:	00010717          	auipc	a4,0x10
ffffffffc0201620:	e4b73e23          	sd	a1,-420(a4) # ffffffffc0211478 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201624:	6398                	ld	a4,0(a5)
}
ffffffffc0201626:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201628:	e390                	sd	a2,0(a5)
ffffffffc020162a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020162c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020162e:	f118                	sd	a4,32(a0)
ffffffffc0201630:	0141                	addi	sp,sp,16
ffffffffc0201632:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201634:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201636:	f514                	sd	a3,40(a0)
ffffffffc0201638:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020163a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020163c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020163e:	00d70e63          	beq	a4,a3,ffffffffc020165a <default_init_memmap+0xc2>
ffffffffc0201642:	4805                	li	a6,1
ffffffffc0201644:	87ba                	mv	a5,a4
ffffffffc0201646:	b7e9                	j	ffffffffc0201610 <default_init_memmap+0x78>
}
ffffffffc0201648:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020164a:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020164e:	e398                	sd	a4,0(a5)
ffffffffc0201650:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201652:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201654:	f11c                	sd	a5,32(a0)
}
ffffffffc0201656:	0141                	addi	sp,sp,16
ffffffffc0201658:	8082                	ret
ffffffffc020165a:	60a2                	ld	ra,8(sp)
ffffffffc020165c:	e290                	sd	a2,0(a3)
ffffffffc020165e:	0141                	addi	sp,sp,16
ffffffffc0201660:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201662:	00004697          	auipc	a3,0x4
ffffffffc0201666:	a5668693          	addi	a3,a3,-1450 # ffffffffc02050b8 <commands+0xc60>
ffffffffc020166a:	00003617          	auipc	a2,0x3
ffffffffc020166e:	6c660613          	addi	a2,a2,1734 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201672:	04900593          	li	a1,73
ffffffffc0201676:	00003517          	auipc	a0,0x3
ffffffffc020167a:	6d250513          	addi	a0,a0,1746 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc020167e:	d01fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(n > 0);
ffffffffc0201682:	00004697          	auipc	a3,0x4
ffffffffc0201686:	a2e68693          	addi	a3,a3,-1490 # ffffffffc02050b0 <commands+0xc58>
ffffffffc020168a:	00003617          	auipc	a2,0x3
ffffffffc020168e:	6a660613          	addi	a2,a2,1702 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0201692:	04600593          	li	a1,70
ffffffffc0201696:	00003517          	auipc	a0,0x3
ffffffffc020169a:	6b250513          	addi	a0,a0,1714 # ffffffffc0204d48 <commands+0x8f0>
ffffffffc020169e:	ce1fe0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02016a2 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02016a2:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02016a4:	00004617          	auipc	a2,0x4
ffffffffc02016a8:	aec60613          	addi	a2,a2,-1300 # ffffffffc0205190 <default_pmm_manager+0xc8>
ffffffffc02016ac:	06500593          	li	a1,101
ffffffffc02016b0:	00004517          	auipc	a0,0x4
ffffffffc02016b4:	b0050513          	addi	a0,a0,-1280 # ffffffffc02051b0 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02016b8:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02016ba:	cc5fe0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02016be <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02016be:	715d                	addi	sp,sp,-80
ffffffffc02016c0:	e0a2                	sd	s0,64(sp)
ffffffffc02016c2:	fc26                	sd	s1,56(sp)
ffffffffc02016c4:	f84a                	sd	s2,48(sp)
ffffffffc02016c6:	f44e                	sd	s3,40(sp)
ffffffffc02016c8:	f052                	sd	s4,32(sp)
ffffffffc02016ca:	ec56                	sd	s5,24(sp)
ffffffffc02016cc:	e486                	sd	ra,72(sp)
ffffffffc02016ce:	842a                	mv	s0,a0
ffffffffc02016d0:	00010497          	auipc	s1,0x10
ffffffffc02016d4:	eb048493          	addi	s1,s1,-336 # ffffffffc0211580 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016d8:	4985                	li	s3,1
ffffffffc02016da:	00010a17          	auipc	s4,0x10
ffffffffc02016de:	d8ea0a13          	addi	s4,s4,-626 # ffffffffc0211468 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02016e2:	0005091b          	sext.w	s2,a0
ffffffffc02016e6:	00010a97          	auipc	s5,0x10
ffffffffc02016ea:	f9aa8a93          	addi	s5,s5,-102 # ffffffffc0211680 <check_mm_struct>
ffffffffc02016ee:	a00d                	j	ffffffffc0201710 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016f0:	609c                	ld	a5,0(s1)
ffffffffc02016f2:	6f9c                	ld	a5,24(a5)
ffffffffc02016f4:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc02016f6:	4601                	li	a2,0
ffffffffc02016f8:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016fa:	ed0d                	bnez	a0,ffffffffc0201734 <alloc_pages+0x76>
ffffffffc02016fc:	0289ec63          	bltu	s3,s0,ffffffffc0201734 <alloc_pages+0x76>
ffffffffc0201700:	000a2783          	lw	a5,0(s4)
ffffffffc0201704:	2781                	sext.w	a5,a5
ffffffffc0201706:	c79d                	beqz	a5,ffffffffc0201734 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201708:	000ab503          	ld	a0,0(s5)
ffffffffc020170c:	021010ef          	jal	ra,ffffffffc0202f2c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201710:	100027f3          	csrr	a5,sstatus
ffffffffc0201714:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201716:	8522                	mv	a0,s0
ffffffffc0201718:	dfe1                	beqz	a5,ffffffffc02016f0 <alloc_pages+0x32>
        intr_disable();
ffffffffc020171a:	dcffe0ef          	jal	ra,ffffffffc02004e8 <intr_disable>
ffffffffc020171e:	609c                	ld	a5,0(s1)
ffffffffc0201720:	8522                	mv	a0,s0
ffffffffc0201722:	6f9c                	ld	a5,24(a5)
ffffffffc0201724:	9782                	jalr	a5
ffffffffc0201726:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201728:	dbbfe0ef          	jal	ra,ffffffffc02004e2 <intr_enable>
ffffffffc020172c:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc020172e:	4601                	li	a2,0
ffffffffc0201730:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201732:	d569                	beqz	a0,ffffffffc02016fc <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201734:	60a6                	ld	ra,72(sp)
ffffffffc0201736:	6406                	ld	s0,64(sp)
ffffffffc0201738:	74e2                	ld	s1,56(sp)
ffffffffc020173a:	7942                	ld	s2,48(sp)
ffffffffc020173c:	79a2                	ld	s3,40(sp)
ffffffffc020173e:	7a02                	ld	s4,32(sp)
ffffffffc0201740:	6ae2                	ld	s5,24(sp)
ffffffffc0201742:	6161                	addi	sp,sp,80
ffffffffc0201744:	8082                	ret

ffffffffc0201746 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201746:	100027f3          	csrr	a5,sstatus
ffffffffc020174a:	8b89                	andi	a5,a5,2
ffffffffc020174c:	eb89                	bnez	a5,ffffffffc020175e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020174e:	00010797          	auipc	a5,0x10
ffffffffc0201752:	e3278793          	addi	a5,a5,-462 # ffffffffc0211580 <pmm_manager>
ffffffffc0201756:	639c                	ld	a5,0(a5)
ffffffffc0201758:	0207b303          	ld	t1,32(a5)
ffffffffc020175c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020175e:	1101                	addi	sp,sp,-32
ffffffffc0201760:	ec06                	sd	ra,24(sp)
ffffffffc0201762:	e822                	sd	s0,16(sp)
ffffffffc0201764:	e426                	sd	s1,8(sp)
ffffffffc0201766:	842a                	mv	s0,a0
ffffffffc0201768:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020176a:	d7ffe0ef          	jal	ra,ffffffffc02004e8 <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020176e:	00010797          	auipc	a5,0x10
ffffffffc0201772:	e1278793          	addi	a5,a5,-494 # ffffffffc0211580 <pmm_manager>
ffffffffc0201776:	639c                	ld	a5,0(a5)
ffffffffc0201778:	85a6                	mv	a1,s1
ffffffffc020177a:	8522                	mv	a0,s0
ffffffffc020177c:	739c                	ld	a5,32(a5)
ffffffffc020177e:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201780:	6442                	ld	s0,16(sp)
ffffffffc0201782:	60e2                	ld	ra,24(sp)
ffffffffc0201784:	64a2                	ld	s1,8(sp)
ffffffffc0201786:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201788:	d5bfe06f          	j	ffffffffc02004e2 <intr_enable>

ffffffffc020178c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020178c:	100027f3          	csrr	a5,sstatus
ffffffffc0201790:	8b89                	andi	a5,a5,2
ffffffffc0201792:	eb89                	bnez	a5,ffffffffc02017a4 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201794:	00010797          	auipc	a5,0x10
ffffffffc0201798:	dec78793          	addi	a5,a5,-532 # ffffffffc0211580 <pmm_manager>
ffffffffc020179c:	639c                	ld	a5,0(a5)
ffffffffc020179e:	0287b303          	ld	t1,40(a5)
ffffffffc02017a2:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02017a4:	1141                	addi	sp,sp,-16
ffffffffc02017a6:	e406                	sd	ra,8(sp)
ffffffffc02017a8:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02017aa:	d3ffe0ef          	jal	ra,ffffffffc02004e8 <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02017ae:	00010797          	auipc	a5,0x10
ffffffffc02017b2:	dd278793          	addi	a5,a5,-558 # ffffffffc0211580 <pmm_manager>
ffffffffc02017b6:	639c                	ld	a5,0(a5)
ffffffffc02017b8:	779c                	ld	a5,40(a5)
ffffffffc02017ba:	9782                	jalr	a5
ffffffffc02017bc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02017be:	d25fe0ef          	jal	ra,ffffffffc02004e2 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02017c2:	8522                	mv	a0,s0
ffffffffc02017c4:	60a2                	ld	ra,8(sp)
ffffffffc02017c6:	6402                	ld	s0,0(sp)
ffffffffc02017c8:	0141                	addi	sp,sp,16
ffffffffc02017ca:	8082                	ret

ffffffffc02017cc <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017cc:	715d                	addi	sp,sp,-80
ffffffffc02017ce:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02017d0:	01e5d493          	srli	s1,a1,0x1e
ffffffffc02017d4:	1ff4f493          	andi	s1,s1,511
ffffffffc02017d8:	048e                	slli	s1,s1,0x3
ffffffffc02017da:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017dc:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017de:	f84a                	sd	s2,48(sp)
ffffffffc02017e0:	f44e                	sd	s3,40(sp)
ffffffffc02017e2:	f052                	sd	s4,32(sp)
ffffffffc02017e4:	e486                	sd	ra,72(sp)
ffffffffc02017e6:	e0a2                	sd	s0,64(sp)
ffffffffc02017e8:	ec56                	sd	s5,24(sp)
ffffffffc02017ea:	e85a                	sd	s6,16(sp)
ffffffffc02017ec:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017ee:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017f2:	892e                	mv	s2,a1
ffffffffc02017f4:	8a32                	mv	s4,a2
ffffffffc02017f6:	00010997          	auipc	s3,0x10
ffffffffc02017fa:	c6298993          	addi	s3,s3,-926 # ffffffffc0211458 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017fe:	e3c9                	bnez	a5,ffffffffc0201880 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201800:	16060163          	beqz	a2,ffffffffc0201962 <get_pte+0x196>
ffffffffc0201804:	4505                	li	a0,1
ffffffffc0201806:	eb9ff0ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc020180a:	842a                	mv	s0,a0
ffffffffc020180c:	14050b63          	beqz	a0,ffffffffc0201962 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201810:	00010b97          	auipc	s7,0x10
ffffffffc0201814:	d88b8b93          	addi	s7,s7,-632 # ffffffffc0211598 <pages>
ffffffffc0201818:	000bb503          	ld	a0,0(s7)
ffffffffc020181c:	00003797          	auipc	a5,0x3
ffffffffc0201820:	4fc78793          	addi	a5,a5,1276 # ffffffffc0204d18 <commands+0x8c0>
ffffffffc0201824:	0007bb03          	ld	s6,0(a5)
ffffffffc0201828:	40a40533          	sub	a0,s0,a0
ffffffffc020182c:	850d                	srai	a0,a0,0x3
ffffffffc020182e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201832:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201834:	00010997          	auipc	s3,0x10
ffffffffc0201838:	c2498993          	addi	s3,s3,-988 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020183c:	00080ab7          	lui	s5,0x80
ffffffffc0201840:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201844:	c01c                	sw	a5,0(s0)
ffffffffc0201846:	57fd                	li	a5,-1
ffffffffc0201848:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020184a:	9556                	add	a0,a0,s5
ffffffffc020184c:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020184e:	0532                	slli	a0,a0,0xc
ffffffffc0201850:	16e7f063          	bleu	a4,a5,ffffffffc02019b0 <get_pte+0x1e4>
ffffffffc0201854:	00010797          	auipc	a5,0x10
ffffffffc0201858:	d3478793          	addi	a5,a5,-716 # ffffffffc0211588 <va_pa_offset>
ffffffffc020185c:	639c                	ld	a5,0(a5)
ffffffffc020185e:	6605                	lui	a2,0x1
ffffffffc0201860:	4581                	li	a1,0
ffffffffc0201862:	953e                	add	a0,a0,a5
ffffffffc0201864:	2a1020ef          	jal	ra,ffffffffc0204304 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201868:	000bb683          	ld	a3,0(s7)
ffffffffc020186c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201870:	868d                	srai	a3,a3,0x3
ffffffffc0201872:	036686b3          	mul	a3,a3,s6
ffffffffc0201876:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201878:	06aa                	slli	a3,a3,0xa
ffffffffc020187a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020187e:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201880:	77fd                	lui	a5,0xfffff
ffffffffc0201882:	068a                	slli	a3,a3,0x2
ffffffffc0201884:	0009b703          	ld	a4,0(s3)
ffffffffc0201888:	8efd                	and	a3,a3,a5
ffffffffc020188a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020188e:	0ce7fc63          	bleu	a4,a5,ffffffffc0201966 <get_pte+0x19a>
ffffffffc0201892:	00010a97          	auipc	s5,0x10
ffffffffc0201896:	cf6a8a93          	addi	s5,s5,-778 # ffffffffc0211588 <va_pa_offset>
ffffffffc020189a:	000ab403          	ld	s0,0(s5)
ffffffffc020189e:	01595793          	srli	a5,s2,0x15
ffffffffc02018a2:	1ff7f793          	andi	a5,a5,511
ffffffffc02018a6:	96a2                	add	a3,a3,s0
ffffffffc02018a8:	00379413          	slli	s0,a5,0x3
ffffffffc02018ac:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc02018ae:	6014                	ld	a3,0(s0)
ffffffffc02018b0:	0016f793          	andi	a5,a3,1
ffffffffc02018b4:	ebbd                	bnez	a5,ffffffffc020192a <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02018b6:	0a0a0663          	beqz	s4,ffffffffc0201962 <get_pte+0x196>
ffffffffc02018ba:	4505                	li	a0,1
ffffffffc02018bc:	e03ff0ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc02018c0:	84aa                	mv	s1,a0
ffffffffc02018c2:	c145                	beqz	a0,ffffffffc0201962 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018c4:	00010b97          	auipc	s7,0x10
ffffffffc02018c8:	cd4b8b93          	addi	s7,s7,-812 # ffffffffc0211598 <pages>
ffffffffc02018cc:	000bb503          	ld	a0,0(s7)
ffffffffc02018d0:	00003797          	auipc	a5,0x3
ffffffffc02018d4:	44878793          	addi	a5,a5,1096 # ffffffffc0204d18 <commands+0x8c0>
ffffffffc02018d8:	0007bb03          	ld	s6,0(a5)
ffffffffc02018dc:	40a48533          	sub	a0,s1,a0
ffffffffc02018e0:	850d                	srai	a0,a0,0x3
ffffffffc02018e2:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018e6:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018e8:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018ec:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018f0:	c09c                	sw	a5,0(s1)
ffffffffc02018f2:	57fd                	li	a5,-1
ffffffffc02018f4:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018f6:	9552                	add	a0,a0,s4
ffffffffc02018f8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02018fa:	0532                	slli	a0,a0,0xc
ffffffffc02018fc:	08e7fd63          	bleu	a4,a5,ffffffffc0201996 <get_pte+0x1ca>
ffffffffc0201900:	000ab783          	ld	a5,0(s5)
ffffffffc0201904:	6605                	lui	a2,0x1
ffffffffc0201906:	4581                	li	a1,0
ffffffffc0201908:	953e                	add	a0,a0,a5
ffffffffc020190a:	1fb020ef          	jal	ra,ffffffffc0204304 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020190e:	000bb683          	ld	a3,0(s7)
ffffffffc0201912:	40d486b3          	sub	a3,s1,a3
ffffffffc0201916:	868d                	srai	a3,a3,0x3
ffffffffc0201918:	036686b3          	mul	a3,a3,s6
ffffffffc020191c:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020191e:	06aa                	slli	a3,a3,0xa
ffffffffc0201920:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201924:	e014                	sd	a3,0(s0)
ffffffffc0201926:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020192a:	068a                	slli	a3,a3,0x2
ffffffffc020192c:	757d                	lui	a0,0xfffff
ffffffffc020192e:	8ee9                	and	a3,a3,a0
ffffffffc0201930:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201934:	04e7f563          	bleu	a4,a5,ffffffffc020197e <get_pte+0x1b2>
ffffffffc0201938:	000ab503          	ld	a0,0(s5)
ffffffffc020193c:	00c95793          	srli	a5,s2,0xc
ffffffffc0201940:	1ff7f793          	andi	a5,a5,511
ffffffffc0201944:	96aa                	add	a3,a3,a0
ffffffffc0201946:	00379513          	slli	a0,a5,0x3
ffffffffc020194a:	9536                	add	a0,a0,a3
}
ffffffffc020194c:	60a6                	ld	ra,72(sp)
ffffffffc020194e:	6406                	ld	s0,64(sp)
ffffffffc0201950:	74e2                	ld	s1,56(sp)
ffffffffc0201952:	7942                	ld	s2,48(sp)
ffffffffc0201954:	79a2                	ld	s3,40(sp)
ffffffffc0201956:	7a02                	ld	s4,32(sp)
ffffffffc0201958:	6ae2                	ld	s5,24(sp)
ffffffffc020195a:	6b42                	ld	s6,16(sp)
ffffffffc020195c:	6ba2                	ld	s7,8(sp)
ffffffffc020195e:	6161                	addi	sp,sp,80
ffffffffc0201960:	8082                	ret
            return NULL;
ffffffffc0201962:	4501                	li	a0,0
ffffffffc0201964:	b7e5                	j	ffffffffc020194c <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201966:	00003617          	auipc	a2,0x3
ffffffffc020196a:	7b260613          	addi	a2,a2,1970 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc020196e:	10200593          	li	a1,258
ffffffffc0201972:	00003517          	auipc	a0,0x3
ffffffffc0201976:	7ce50513          	addi	a0,a0,1998 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020197a:	a05fe0ef          	jal	ra,ffffffffc020037e <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020197e:	00003617          	auipc	a2,0x3
ffffffffc0201982:	79a60613          	addi	a2,a2,1946 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc0201986:	10f00593          	li	a1,271
ffffffffc020198a:	00003517          	auipc	a0,0x3
ffffffffc020198e:	7b650513          	addi	a0,a0,1974 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0201992:	9edfe0ef          	jal	ra,ffffffffc020037e <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201996:	86aa                	mv	a3,a0
ffffffffc0201998:	00003617          	auipc	a2,0x3
ffffffffc020199c:	78060613          	addi	a2,a2,1920 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc02019a0:	10b00593          	li	a1,267
ffffffffc02019a4:	00003517          	auipc	a0,0x3
ffffffffc02019a8:	79c50513          	addi	a0,a0,1948 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02019ac:	9d3fe0ef          	jal	ra,ffffffffc020037e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02019b0:	86aa                	mv	a3,a0
ffffffffc02019b2:	00003617          	auipc	a2,0x3
ffffffffc02019b6:	76660613          	addi	a2,a2,1894 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc02019ba:	0ff00593          	li	a1,255
ffffffffc02019be:	00003517          	auipc	a0,0x3
ffffffffc02019c2:	78250513          	addi	a0,a0,1922 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02019c6:	9b9fe0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02019ca <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019ca:	1141                	addi	sp,sp,-16
ffffffffc02019cc:	e022                	sd	s0,0(sp)
ffffffffc02019ce:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019d0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019d2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019d4:	df9ff0ef          	jal	ra,ffffffffc02017cc <get_pte>
    if (ptep_store != NULL) {
ffffffffc02019d8:	c011                	beqz	s0,ffffffffc02019dc <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02019da:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019dc:	c521                	beqz	a0,ffffffffc0201a24 <get_page+0x5a>
ffffffffc02019de:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02019e0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019e2:	0017f713          	andi	a4,a5,1
ffffffffc02019e6:	e709                	bnez	a4,ffffffffc02019f0 <get_page+0x26>
}
ffffffffc02019e8:	60a2                	ld	ra,8(sp)
ffffffffc02019ea:	6402                	ld	s0,0(sp)
ffffffffc02019ec:	0141                	addi	sp,sp,16
ffffffffc02019ee:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02019f0:	00010717          	auipc	a4,0x10
ffffffffc02019f4:	a6870713          	addi	a4,a4,-1432 # ffffffffc0211458 <npage>
ffffffffc02019f8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019fa:	078a                	slli	a5,a5,0x2
ffffffffc02019fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019fe:	02e7f863          	bleu	a4,a5,ffffffffc0201a2e <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a02:	fff80537          	lui	a0,0xfff80
ffffffffc0201a06:	97aa                	add	a5,a5,a0
ffffffffc0201a08:	00010697          	auipc	a3,0x10
ffffffffc0201a0c:	b9068693          	addi	a3,a3,-1136 # ffffffffc0211598 <pages>
ffffffffc0201a10:	6288                	ld	a0,0(a3)
ffffffffc0201a12:	60a2                	ld	ra,8(sp)
ffffffffc0201a14:	6402                	ld	s0,0(sp)
ffffffffc0201a16:	00379713          	slli	a4,a5,0x3
ffffffffc0201a1a:	97ba                	add	a5,a5,a4
ffffffffc0201a1c:	078e                	slli	a5,a5,0x3
ffffffffc0201a1e:	953e                	add	a0,a0,a5
ffffffffc0201a20:	0141                	addi	sp,sp,16
ffffffffc0201a22:	8082                	ret
ffffffffc0201a24:	60a2                	ld	ra,8(sp)
ffffffffc0201a26:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201a28:	4501                	li	a0,0
}
ffffffffc0201a2a:	0141                	addi	sp,sp,16
ffffffffc0201a2c:	8082                	ret
ffffffffc0201a2e:	c75ff0ef          	jal	ra,ffffffffc02016a2 <pa2page.part.4>

ffffffffc0201a32 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a32:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a34:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a36:	e406                	sd	ra,8(sp)
ffffffffc0201a38:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a3a:	d93ff0ef          	jal	ra,ffffffffc02017cc <get_pte>
    if (ptep != NULL) {
ffffffffc0201a3e:	c511                	beqz	a0,ffffffffc0201a4a <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201a40:	611c                	ld	a5,0(a0)
ffffffffc0201a42:	842a                	mv	s0,a0
ffffffffc0201a44:	0017f713          	andi	a4,a5,1
ffffffffc0201a48:	e709                	bnez	a4,ffffffffc0201a52 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201a4a:	60a2                	ld	ra,8(sp)
ffffffffc0201a4c:	6402                	ld	s0,0(sp)
ffffffffc0201a4e:	0141                	addi	sp,sp,16
ffffffffc0201a50:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a52:	00010717          	auipc	a4,0x10
ffffffffc0201a56:	a0670713          	addi	a4,a4,-1530 # ffffffffc0211458 <npage>
ffffffffc0201a5a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a5c:	078a                	slli	a5,a5,0x2
ffffffffc0201a5e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a60:	04e7f063          	bleu	a4,a5,ffffffffc0201aa0 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a64:	fff80737          	lui	a4,0xfff80
ffffffffc0201a68:	97ba                	add	a5,a5,a4
ffffffffc0201a6a:	00010717          	auipc	a4,0x10
ffffffffc0201a6e:	b2e70713          	addi	a4,a4,-1234 # ffffffffc0211598 <pages>
ffffffffc0201a72:	6308                	ld	a0,0(a4)
ffffffffc0201a74:	00379713          	slli	a4,a5,0x3
ffffffffc0201a78:	97ba                	add	a5,a5,a4
ffffffffc0201a7a:	078e                	slli	a5,a5,0x3
ffffffffc0201a7c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201a7e:	411c                	lw	a5,0(a0)
ffffffffc0201a80:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a84:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201a86:	cb09                	beqz	a4,ffffffffc0201a98 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a88:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a8c:	12000073          	sfence.vma
}
ffffffffc0201a90:	60a2                	ld	ra,8(sp)
ffffffffc0201a92:	6402                	ld	s0,0(sp)
ffffffffc0201a94:	0141                	addi	sp,sp,16
ffffffffc0201a96:	8082                	ret
            free_page(page);
ffffffffc0201a98:	4585                	li	a1,1
ffffffffc0201a9a:	cadff0ef          	jal	ra,ffffffffc0201746 <free_pages>
ffffffffc0201a9e:	b7ed                	j	ffffffffc0201a88 <page_remove+0x56>
ffffffffc0201aa0:	c03ff0ef          	jal	ra,ffffffffc02016a2 <pa2page.part.4>

ffffffffc0201aa4 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201aa4:	7179                	addi	sp,sp,-48
ffffffffc0201aa6:	87b2                	mv	a5,a2
ffffffffc0201aa8:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201aaa:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201aac:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201aae:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201ab0:	ec26                	sd	s1,24(sp)
ffffffffc0201ab2:	f406                	sd	ra,40(sp)
ffffffffc0201ab4:	e84a                	sd	s2,16(sp)
ffffffffc0201ab6:	e44e                	sd	s3,8(sp)
ffffffffc0201ab8:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201aba:	d13ff0ef          	jal	ra,ffffffffc02017cc <get_pte>
    if (ptep == NULL) {
ffffffffc0201abe:	c945                	beqz	a0,ffffffffc0201b6e <page_insert+0xca>
    page->ref += 1;
ffffffffc0201ac0:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201ac2:	611c                	ld	a5,0(a0)
ffffffffc0201ac4:	892a                	mv	s2,a0
ffffffffc0201ac6:	0016871b          	addiw	a4,a3,1
ffffffffc0201aca:	c018                	sw	a4,0(s0)
ffffffffc0201acc:	0017f713          	andi	a4,a5,1
ffffffffc0201ad0:	e339                	bnez	a4,ffffffffc0201b16 <page_insert+0x72>
ffffffffc0201ad2:	00010797          	auipc	a5,0x10
ffffffffc0201ad6:	ac678793          	addi	a5,a5,-1338 # ffffffffc0211598 <pages>
ffffffffc0201ada:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201adc:	00003717          	auipc	a4,0x3
ffffffffc0201ae0:	23c70713          	addi	a4,a4,572 # ffffffffc0204d18 <commands+0x8c0>
ffffffffc0201ae4:	40f407b3          	sub	a5,s0,a5
ffffffffc0201ae8:	6300                	ld	s0,0(a4)
ffffffffc0201aea:	878d                	srai	a5,a5,0x3
ffffffffc0201aec:	000806b7          	lui	a3,0x80
ffffffffc0201af0:	028787b3          	mul	a5,a5,s0
ffffffffc0201af4:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201af6:	07aa                	slli	a5,a5,0xa
ffffffffc0201af8:	8fc5                	or	a5,a5,s1
ffffffffc0201afa:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201afe:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b02:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201b06:	4501                	li	a0,0
}
ffffffffc0201b08:	70a2                	ld	ra,40(sp)
ffffffffc0201b0a:	7402                	ld	s0,32(sp)
ffffffffc0201b0c:	64e2                	ld	s1,24(sp)
ffffffffc0201b0e:	6942                	ld	s2,16(sp)
ffffffffc0201b10:	69a2                	ld	s3,8(sp)
ffffffffc0201b12:	6145                	addi	sp,sp,48
ffffffffc0201b14:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201b16:	00010717          	auipc	a4,0x10
ffffffffc0201b1a:	94270713          	addi	a4,a4,-1726 # ffffffffc0211458 <npage>
ffffffffc0201b1e:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201b20:	00279513          	slli	a0,a5,0x2
ffffffffc0201b24:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b26:	04e57663          	bleu	a4,a0,ffffffffc0201b72 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b2a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201b2e:	953e                	add	a0,a0,a5
ffffffffc0201b30:	00010997          	auipc	s3,0x10
ffffffffc0201b34:	a6898993          	addi	s3,s3,-1432 # ffffffffc0211598 <pages>
ffffffffc0201b38:	0009b783          	ld	a5,0(s3)
ffffffffc0201b3c:	00351713          	slli	a4,a0,0x3
ffffffffc0201b40:	953a                	add	a0,a0,a4
ffffffffc0201b42:	050e                	slli	a0,a0,0x3
ffffffffc0201b44:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201b46:	00a40e63          	beq	s0,a0,ffffffffc0201b62 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201b4a:	411c                	lw	a5,0(a0)
ffffffffc0201b4c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201b50:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201b52:	cb11                	beqz	a4,ffffffffc0201b66 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201b54:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b58:	12000073          	sfence.vma
ffffffffc0201b5c:	0009b783          	ld	a5,0(s3)
ffffffffc0201b60:	bfb5                	j	ffffffffc0201adc <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201b62:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201b64:	bfa5                	j	ffffffffc0201adc <page_insert+0x38>
            free_page(page);
ffffffffc0201b66:	4585                	li	a1,1
ffffffffc0201b68:	bdfff0ef          	jal	ra,ffffffffc0201746 <free_pages>
ffffffffc0201b6c:	b7e5                	j	ffffffffc0201b54 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201b6e:	5571                	li	a0,-4
ffffffffc0201b70:	bf61                	j	ffffffffc0201b08 <page_insert+0x64>
ffffffffc0201b72:	b31ff0ef          	jal	ra,ffffffffc02016a2 <pa2page.part.4>

ffffffffc0201b76 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b76:	00003797          	auipc	a5,0x3
ffffffffc0201b7a:	55278793          	addi	a5,a5,1362 # ffffffffc02050c8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b7e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b80:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b82:	00003517          	auipc	a0,0x3
ffffffffc0201b86:	65650513          	addi	a0,a0,1622 # ffffffffc02051d8 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201b8a:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b8c:	00010717          	auipc	a4,0x10
ffffffffc0201b90:	9ef73a23          	sd	a5,-1548(a4) # ffffffffc0211580 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b94:	e8a2                	sd	s0,80(sp)
ffffffffc0201b96:	e4a6                	sd	s1,72(sp)
ffffffffc0201b98:	e0ca                	sd	s2,64(sp)
ffffffffc0201b9a:	fc4e                	sd	s3,56(sp)
ffffffffc0201b9c:	f852                	sd	s4,48(sp)
ffffffffc0201b9e:	f456                	sd	s5,40(sp)
ffffffffc0201ba0:	f05a                	sd	s6,32(sp)
ffffffffc0201ba2:	ec5e                	sd	s7,24(sp)
ffffffffc0201ba4:	e862                	sd	s8,16(sp)
ffffffffc0201ba6:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201ba8:	00010417          	auipc	s0,0x10
ffffffffc0201bac:	9d840413          	addi	s0,s0,-1576 # ffffffffc0211580 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201bb0:	d18fe0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    pmm_manager->init();
ffffffffc0201bb4:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201bb6:	49c5                	li	s3,17
ffffffffc0201bb8:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201bbc:	679c                	ld	a5,8(a5)
ffffffffc0201bbe:	00010497          	auipc	s1,0x10
ffffffffc0201bc2:	89a48493          	addi	s1,s1,-1894 # ffffffffc0211458 <npage>
ffffffffc0201bc6:	00010917          	auipc	s2,0x10
ffffffffc0201bca:	9d290913          	addi	s2,s2,-1582 # ffffffffc0211598 <pages>
ffffffffc0201bce:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201bd0:	57f5                	li	a5,-3
ffffffffc0201bd2:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201bd4:	07e006b7          	lui	a3,0x7e00
ffffffffc0201bd8:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201bdc:	015a1593          	slli	a1,s4,0x15
ffffffffc0201be0:	00003517          	auipc	a0,0x3
ffffffffc0201be4:	61050513          	addi	a0,a0,1552 # ffffffffc02051f0 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201be8:	00010717          	auipc	a4,0x10
ffffffffc0201bec:	9af73023          	sd	a5,-1632(a4) # ffffffffc0211588 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201bf0:	cd8fe0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201bf4:	00003517          	auipc	a0,0x3
ffffffffc0201bf8:	62c50513          	addi	a0,a0,1580 # ffffffffc0205220 <default_pmm_manager+0x158>
ffffffffc0201bfc:	cccfe0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201c00:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201c04:	16fd                	addi	a3,a3,-1
ffffffffc0201c06:	015a1613          	slli	a2,s4,0x15
ffffffffc0201c0a:	07e005b7          	lui	a1,0x7e00
ffffffffc0201c0e:	00003517          	auipc	a0,0x3
ffffffffc0201c12:	62a50513          	addi	a0,a0,1578 # ffffffffc0205238 <default_pmm_manager+0x170>
ffffffffc0201c16:	cb2fe0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201c1a:	777d                	lui	a4,0xfffff
ffffffffc0201c1c:	00011797          	auipc	a5,0x11
ffffffffc0201c20:	a6b78793          	addi	a5,a5,-1429 # ffffffffc0212687 <end+0xfff>
ffffffffc0201c24:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201c26:	00088737          	lui	a4,0x88
ffffffffc0201c2a:	00010697          	auipc	a3,0x10
ffffffffc0201c2e:	82e6b723          	sd	a4,-2002(a3) # ffffffffc0211458 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201c32:	00010717          	auipc	a4,0x10
ffffffffc0201c36:	96f73323          	sd	a5,-1690(a4) # ffffffffc0211598 <pages>
ffffffffc0201c3a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c3c:	4701                	li	a4,0
ffffffffc0201c3e:	4585                	li	a1,1
ffffffffc0201c40:	fff80637          	lui	a2,0xfff80
ffffffffc0201c44:	a019                	j	ffffffffc0201c4a <pmm_init+0xd4>
ffffffffc0201c46:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201c4a:	97b6                	add	a5,a5,a3
ffffffffc0201c4c:	07a1                	addi	a5,a5,8
ffffffffc0201c4e:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c52:	609c                	ld	a5,0(s1)
ffffffffc0201c54:	0705                	addi	a4,a4,1
ffffffffc0201c56:	04868693          	addi	a3,a3,72
ffffffffc0201c5a:	00c78533          	add	a0,a5,a2
ffffffffc0201c5e:	fea764e3          	bltu	a4,a0,ffffffffc0201c46 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c62:	00093503          	ld	a0,0(s2)
ffffffffc0201c66:	00379693          	slli	a3,a5,0x3
ffffffffc0201c6a:	96be                	add	a3,a3,a5
ffffffffc0201c6c:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c70:	972a                	add	a4,a4,a0
ffffffffc0201c72:	068e                	slli	a3,a3,0x3
ffffffffc0201c74:	96ba                	add	a3,a3,a4
ffffffffc0201c76:	c0200737          	lui	a4,0xc0200
ffffffffc0201c7a:	58e6ea63          	bltu	a3,a4,ffffffffc020220e <pmm_init+0x698>
ffffffffc0201c7e:	00010997          	auipc	s3,0x10
ffffffffc0201c82:	90a98993          	addi	s3,s3,-1782 # ffffffffc0211588 <va_pa_offset>
ffffffffc0201c86:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c8a:	45c5                	li	a1,17
ffffffffc0201c8c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c8e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c90:	44b6ef63          	bltu	a3,a1,ffffffffc02020ee <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c94:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c96:	0000f417          	auipc	s0,0xf
ffffffffc0201c9a:	7ba40413          	addi	s0,s0,1978 # ffffffffc0211450 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c9e:	7b9c                	ld	a5,48(a5)
ffffffffc0201ca0:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201ca2:	00003517          	auipc	a0,0x3
ffffffffc0201ca6:	5e650513          	addi	a0,a0,1510 # ffffffffc0205288 <default_pmm_manager+0x1c0>
ffffffffc0201caa:	c1efe0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201cae:	00007697          	auipc	a3,0x7
ffffffffc0201cb2:	35268693          	addi	a3,a3,850 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201cb6:	0000f797          	auipc	a5,0xf
ffffffffc0201cba:	78d7bd23          	sd	a3,1946(a5) # ffffffffc0211450 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201cbe:	c02007b7          	lui	a5,0xc0200
ffffffffc0201cc2:	0ef6ece3          	bltu	a3,a5,ffffffffc02025ba <pmm_init+0xa44>
ffffffffc0201cc6:	0009b783          	ld	a5,0(s3)
ffffffffc0201cca:	8e9d                	sub	a3,a3,a5
ffffffffc0201ccc:	00010797          	auipc	a5,0x10
ffffffffc0201cd0:	8cd7b223          	sd	a3,-1852(a5) # ffffffffc0211590 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201cd4:	ab9ff0ef          	jal	ra,ffffffffc020178c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201cd8:	6098                	ld	a4,0(s1)
ffffffffc0201cda:	c80007b7          	lui	a5,0xc8000
ffffffffc0201cde:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201ce0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201ce2:	0ae7ece3          	bltu	a5,a4,ffffffffc020259a <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201ce6:	6008                	ld	a0,0(s0)
ffffffffc0201ce8:	4c050363          	beqz	a0,ffffffffc02021ae <pmm_init+0x638>
ffffffffc0201cec:	6785                	lui	a5,0x1
ffffffffc0201cee:	17fd                	addi	a5,a5,-1
ffffffffc0201cf0:	8fe9                	and	a5,a5,a0
ffffffffc0201cf2:	2781                	sext.w	a5,a5
ffffffffc0201cf4:	4a079d63          	bnez	a5,ffffffffc02021ae <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201cf8:	4601                	li	a2,0
ffffffffc0201cfa:	4581                	li	a1,0
ffffffffc0201cfc:	ccfff0ef          	jal	ra,ffffffffc02019ca <get_page>
ffffffffc0201d00:	4c051763          	bnez	a0,ffffffffc02021ce <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201d04:	4505                	li	a0,1
ffffffffc0201d06:	9b9ff0ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0201d0a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201d0c:	6008                	ld	a0,0(s0)
ffffffffc0201d0e:	4681                	li	a3,0
ffffffffc0201d10:	4601                	li	a2,0
ffffffffc0201d12:	85d6                	mv	a1,s5
ffffffffc0201d14:	d91ff0ef          	jal	ra,ffffffffc0201aa4 <page_insert>
ffffffffc0201d18:	52051763          	bnez	a0,ffffffffc0202246 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201d1c:	6008                	ld	a0,0(s0)
ffffffffc0201d1e:	4601                	li	a2,0
ffffffffc0201d20:	4581                	li	a1,0
ffffffffc0201d22:	aabff0ef          	jal	ra,ffffffffc02017cc <get_pte>
ffffffffc0201d26:	50050063          	beqz	a0,ffffffffc0202226 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d2a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d2c:	0017f713          	andi	a4,a5,1
ffffffffc0201d30:	46070363          	beqz	a4,ffffffffc0202196 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201d34:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d36:	078a                	slli	a5,a5,0x2
ffffffffc0201d38:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d3a:	44c7f063          	bleu	a2,a5,ffffffffc020217a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d3e:	fff80737          	lui	a4,0xfff80
ffffffffc0201d42:	97ba                	add	a5,a5,a4
ffffffffc0201d44:	00379713          	slli	a4,a5,0x3
ffffffffc0201d48:	00093683          	ld	a3,0(s2)
ffffffffc0201d4c:	97ba                	add	a5,a5,a4
ffffffffc0201d4e:	078e                	slli	a5,a5,0x3
ffffffffc0201d50:	97b6                	add	a5,a5,a3
ffffffffc0201d52:	5efa9463          	bne	s5,a5,ffffffffc020233a <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0201d56:	000aab83          	lw	s7,0(s5)
ffffffffc0201d5a:	4785                	li	a5,1
ffffffffc0201d5c:	5afb9f63          	bne	s7,a5,ffffffffc020231a <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d60:	6008                	ld	a0,0(s0)
ffffffffc0201d62:	76fd                	lui	a3,0xfffff
ffffffffc0201d64:	611c                	ld	a5,0(a0)
ffffffffc0201d66:	078a                	slli	a5,a5,0x2
ffffffffc0201d68:	8ff5                	and	a5,a5,a3
ffffffffc0201d6a:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201d6e:	58c77963          	bleu	a2,a4,ffffffffc0202300 <pmm_init+0x78a>
ffffffffc0201d72:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d76:	97e2                	add	a5,a5,s8
ffffffffc0201d78:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201d7c:	0b0a                	slli	s6,s6,0x2
ffffffffc0201d7e:	00db7b33          	and	s6,s6,a3
ffffffffc0201d82:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201d86:	56c7f063          	bleu	a2,a5,ffffffffc02022e6 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d8a:	4601                	li	a2,0
ffffffffc0201d8c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d8e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d90:	a3dff0ef          	jal	ra,ffffffffc02017cc <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d94:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d96:	53651863          	bne	a0,s6,ffffffffc02022c6 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc0201d9a:	4505                	li	a0,1
ffffffffc0201d9c:	923ff0ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0201da0:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201da2:	6008                	ld	a0,0(s0)
ffffffffc0201da4:	46d1                	li	a3,20
ffffffffc0201da6:	6605                	lui	a2,0x1
ffffffffc0201da8:	85da                	mv	a1,s6
ffffffffc0201daa:	cfbff0ef          	jal	ra,ffffffffc0201aa4 <page_insert>
ffffffffc0201dae:	4e051c63          	bnez	a0,ffffffffc02022a6 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201db2:	6008                	ld	a0,0(s0)
ffffffffc0201db4:	4601                	li	a2,0
ffffffffc0201db6:	6585                	lui	a1,0x1
ffffffffc0201db8:	a15ff0ef          	jal	ra,ffffffffc02017cc <get_pte>
ffffffffc0201dbc:	4c050563          	beqz	a0,ffffffffc0202286 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc0201dc0:	611c                	ld	a5,0(a0)
ffffffffc0201dc2:	0107f713          	andi	a4,a5,16
ffffffffc0201dc6:	4a070063          	beqz	a4,ffffffffc0202266 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0201dca:	8b91                	andi	a5,a5,4
ffffffffc0201dcc:	66078763          	beqz	a5,ffffffffc020243a <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201dd0:	6008                	ld	a0,0(s0)
ffffffffc0201dd2:	611c                	ld	a5,0(a0)
ffffffffc0201dd4:	8bc1                	andi	a5,a5,16
ffffffffc0201dd6:	64078263          	beqz	a5,ffffffffc020241a <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201dda:	000b2783          	lw	a5,0(s6)
ffffffffc0201dde:	61779e63          	bne	a5,s7,ffffffffc02023fa <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201de2:	4681                	li	a3,0
ffffffffc0201de4:	6605                	lui	a2,0x1
ffffffffc0201de6:	85d6                	mv	a1,s5
ffffffffc0201de8:	cbdff0ef          	jal	ra,ffffffffc0201aa4 <page_insert>
ffffffffc0201dec:	5e051763          	bnez	a0,ffffffffc02023da <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc0201df0:	000aa703          	lw	a4,0(s5)
ffffffffc0201df4:	4789                	li	a5,2
ffffffffc0201df6:	5cf71263          	bne	a4,a5,ffffffffc02023ba <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201dfa:	000b2783          	lw	a5,0(s6)
ffffffffc0201dfe:	58079e63          	bnez	a5,ffffffffc020239a <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201e02:	6008                	ld	a0,0(s0)
ffffffffc0201e04:	4601                	li	a2,0
ffffffffc0201e06:	6585                	lui	a1,0x1
ffffffffc0201e08:	9c5ff0ef          	jal	ra,ffffffffc02017cc <get_pte>
ffffffffc0201e0c:	56050763          	beqz	a0,ffffffffc020237a <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc0201e10:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201e12:	0016f793          	andi	a5,a3,1
ffffffffc0201e16:	38078063          	beqz	a5,ffffffffc0202196 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201e1a:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201e1c:	00269793          	slli	a5,a3,0x2
ffffffffc0201e20:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e22:	34e7fc63          	bleu	a4,a5,ffffffffc020217a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e26:	fff80737          	lui	a4,0xfff80
ffffffffc0201e2a:	97ba                	add	a5,a5,a4
ffffffffc0201e2c:	00379713          	slli	a4,a5,0x3
ffffffffc0201e30:	00093603          	ld	a2,0(s2)
ffffffffc0201e34:	97ba                	add	a5,a5,a4
ffffffffc0201e36:	078e                	slli	a5,a5,0x3
ffffffffc0201e38:	97b2                	add	a5,a5,a2
ffffffffc0201e3a:	52fa9063          	bne	s5,a5,ffffffffc020235a <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201e3e:	8ac1                	andi	a3,a3,16
ffffffffc0201e40:	6e069d63          	bnez	a3,ffffffffc020253a <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201e44:	6008                	ld	a0,0(s0)
ffffffffc0201e46:	4581                	li	a1,0
ffffffffc0201e48:	bebff0ef          	jal	ra,ffffffffc0201a32 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201e4c:	000aa703          	lw	a4,0(s5)
ffffffffc0201e50:	4785                	li	a5,1
ffffffffc0201e52:	6cf71463          	bne	a4,a5,ffffffffc020251a <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0201e56:	000b2783          	lw	a5,0(s6)
ffffffffc0201e5a:	6a079063          	bnez	a5,ffffffffc02024fa <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e5e:	6008                	ld	a0,0(s0)
ffffffffc0201e60:	6585                	lui	a1,0x1
ffffffffc0201e62:	bd1ff0ef          	jal	ra,ffffffffc0201a32 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e66:	000aa783          	lw	a5,0(s5)
ffffffffc0201e6a:	66079863          	bnez	a5,ffffffffc02024da <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc0201e6e:	000b2783          	lw	a5,0(s6)
ffffffffc0201e72:	70079463          	bnez	a5,ffffffffc020257a <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e76:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201e7a:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e7c:	000b3783          	ld	a5,0(s6)
ffffffffc0201e80:	078a                	slli	a5,a5,0x2
ffffffffc0201e82:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e84:	2eb7fb63          	bleu	a1,a5,ffffffffc020217a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e88:	fff80737          	lui	a4,0xfff80
ffffffffc0201e8c:	973e                	add	a4,a4,a5
ffffffffc0201e8e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e92:	00093603          	ld	a2,0(s2)
ffffffffc0201e96:	97ba                	add	a5,a5,a4
ffffffffc0201e98:	078e                	slli	a5,a5,0x3
ffffffffc0201e9a:	00f60733          	add	a4,a2,a5
ffffffffc0201e9e:	4314                	lw	a3,0(a4)
ffffffffc0201ea0:	4705                	li	a4,1
ffffffffc0201ea2:	6ae69c63          	bne	a3,a4,ffffffffc020255a <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ea6:	00003a97          	auipc	s5,0x3
ffffffffc0201eaa:	e72a8a93          	addi	s5,s5,-398 # ffffffffc0204d18 <commands+0x8c0>
ffffffffc0201eae:	000ab703          	ld	a4,0(s5)
ffffffffc0201eb2:	4037d693          	srai	a3,a5,0x3
ffffffffc0201eb6:	00080bb7          	lui	s7,0x80
ffffffffc0201eba:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ebe:	577d                	li	a4,-1
ffffffffc0201ec0:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ec2:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ec4:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ec6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ec8:	2ab77b63          	bleu	a1,a4,ffffffffc020217e <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201ecc:	0009b783          	ld	a5,0(s3)
ffffffffc0201ed0:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ed2:	629c                	ld	a5,0(a3)
ffffffffc0201ed4:	078a                	slli	a5,a5,0x2
ffffffffc0201ed6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ed8:	2ab7f163          	bleu	a1,a5,ffffffffc020217a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201edc:	417787b3          	sub	a5,a5,s7
ffffffffc0201ee0:	00379513          	slli	a0,a5,0x3
ffffffffc0201ee4:	97aa                	add	a5,a5,a0
ffffffffc0201ee6:	00379513          	slli	a0,a5,0x3
ffffffffc0201eea:	9532                	add	a0,a0,a2
ffffffffc0201eec:	4585                	li	a1,1
ffffffffc0201eee:	859ff0ef          	jal	ra,ffffffffc0201746 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ef2:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201ef6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ef8:	050a                	slli	a0,a0,0x2
ffffffffc0201efa:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201efc:	26f57f63          	bleu	a5,a0,ffffffffc020217a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f00:	417507b3          	sub	a5,a0,s7
ffffffffc0201f04:	00379513          	slli	a0,a5,0x3
ffffffffc0201f08:	00093703          	ld	a4,0(s2)
ffffffffc0201f0c:	953e                	add	a0,a0,a5
ffffffffc0201f0e:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201f10:	4585                	li	a1,1
ffffffffc0201f12:	953a                	add	a0,a0,a4
ffffffffc0201f14:	833ff0ef          	jal	ra,ffffffffc0201746 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201f18:	601c                	ld	a5,0(s0)
ffffffffc0201f1a:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201f1e:	86fff0ef          	jal	ra,ffffffffc020178c <nr_free_pages>
ffffffffc0201f22:	2caa1663          	bne	s4,a0,ffffffffc02021ee <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201f26:	00003517          	auipc	a0,0x3
ffffffffc0201f2a:	67250513          	addi	a0,a0,1650 # ffffffffc0205598 <default_pmm_manager+0x4d0>
ffffffffc0201f2e:	99afe0ef          	jal	ra,ffffffffc02000c8 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201f32:	85bff0ef          	jal	ra,ffffffffc020178c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f36:	6098                	ld	a4,0(s1)
ffffffffc0201f38:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201f3c:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f3e:	00c71693          	slli	a3,a4,0xc
ffffffffc0201f42:	1cd7fd63          	bleu	a3,a5,ffffffffc020211c <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f46:	83b1                	srli	a5,a5,0xc
ffffffffc0201f48:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f4a:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f4e:	1ce7f963          	bleu	a4,a5,ffffffffc0202120 <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f52:	7c7d                	lui	s8,0xfffff
ffffffffc0201f54:	6b85                	lui	s7,0x1
ffffffffc0201f56:	a029                	j	ffffffffc0201f60 <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f58:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201f5c:	1cf77263          	bleu	a5,a4,ffffffffc0202120 <pmm_init+0x5aa>
ffffffffc0201f60:	0009b583          	ld	a1,0(s3)
ffffffffc0201f64:	4601                	li	a2,0
ffffffffc0201f66:	95d2                	add	a1,a1,s4
ffffffffc0201f68:	865ff0ef          	jal	ra,ffffffffc02017cc <get_pte>
ffffffffc0201f6c:	1c050763          	beqz	a0,ffffffffc020213a <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f70:	611c                	ld	a5,0(a0)
ffffffffc0201f72:	078a                	slli	a5,a5,0x2
ffffffffc0201f74:	0187f7b3          	and	a5,a5,s8
ffffffffc0201f78:	1f479163          	bne	a5,s4,ffffffffc020215a <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f7c:	609c                	ld	a5,0(s1)
ffffffffc0201f7e:	9a5e                	add	s4,s4,s7
ffffffffc0201f80:	6008                	ld	a0,0(s0)
ffffffffc0201f82:	00c79713          	slli	a4,a5,0xc
ffffffffc0201f86:	fcea69e3          	bltu	s4,a4,ffffffffc0201f58 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f8a:	611c                	ld	a5,0(a0)
ffffffffc0201f8c:	6a079363          	bnez	a5,ffffffffc0202632 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f90:	4505                	li	a0,1
ffffffffc0201f92:	f2cff0ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0201f96:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f98:	6008                	ld	a0,0(s0)
ffffffffc0201f9a:	4699                	li	a3,6
ffffffffc0201f9c:	10000613          	li	a2,256
ffffffffc0201fa0:	85d2                	mv	a1,s4
ffffffffc0201fa2:	b03ff0ef          	jal	ra,ffffffffc0201aa4 <page_insert>
ffffffffc0201fa6:	66051663          	bnez	a0,ffffffffc0202612 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0201faa:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201fae:	4785                	li	a5,1
ffffffffc0201fb0:	64f71163          	bne	a4,a5,ffffffffc02025f2 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201fb4:	6008                	ld	a0,0(s0)
ffffffffc0201fb6:	6b85                	lui	s7,0x1
ffffffffc0201fb8:	4699                	li	a3,6
ffffffffc0201fba:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201fbe:	85d2                	mv	a1,s4
ffffffffc0201fc0:	ae5ff0ef          	jal	ra,ffffffffc0201aa4 <page_insert>
ffffffffc0201fc4:	60051763          	bnez	a0,ffffffffc02025d2 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0201fc8:	000a2703          	lw	a4,0(s4)
ffffffffc0201fcc:	4789                	li	a5,2
ffffffffc0201fce:	4ef71663          	bne	a4,a5,ffffffffc02024ba <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201fd2:	00003597          	auipc	a1,0x3
ffffffffc0201fd6:	6fe58593          	addi	a1,a1,1790 # ffffffffc02056d0 <default_pmm_manager+0x608>
ffffffffc0201fda:	10000513          	li	a0,256
ffffffffc0201fde:	2cc020ef          	jal	ra,ffffffffc02042aa <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201fe2:	100b8593          	addi	a1,s7,256
ffffffffc0201fe6:	10000513          	li	a0,256
ffffffffc0201fea:	2d2020ef          	jal	ra,ffffffffc02042bc <strcmp>
ffffffffc0201fee:	4a051663          	bnez	a0,ffffffffc020249a <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ff2:	00093683          	ld	a3,0(s2)
ffffffffc0201ff6:	000abc83          	ld	s9,0(s5)
ffffffffc0201ffa:	00080c37          	lui	s8,0x80
ffffffffc0201ffe:	40da06b3          	sub	a3,s4,a3
ffffffffc0202002:	868d                	srai	a3,a3,0x3
ffffffffc0202004:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202008:	5afd                	li	s5,-1
ffffffffc020200a:	609c                	ld	a5,0(s1)
ffffffffc020200c:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202010:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202012:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202016:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202018:	16f77363          	bleu	a5,a4,ffffffffc020217e <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020201c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202020:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202024:	96be                	add	a3,a3,a5
ffffffffc0202026:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdeda78>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020202a:	23c020ef          	jal	ra,ffffffffc0204266 <strlen>
ffffffffc020202e:	44051663          	bnez	a0,ffffffffc020247a <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202032:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202036:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202038:	000bb783          	ld	a5,0(s7)
ffffffffc020203c:	078a                	slli	a5,a5,0x2
ffffffffc020203e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202040:	12e7fd63          	bleu	a4,a5,ffffffffc020217a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202044:	418787b3          	sub	a5,a5,s8
ffffffffc0202048:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020204c:	96be                	add	a3,a3,a5
ffffffffc020204e:	039686b3          	mul	a3,a3,s9
ffffffffc0202052:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202054:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202058:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020205a:	12eaf263          	bleu	a4,s5,ffffffffc020217e <pmm_init+0x608>
ffffffffc020205e:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202062:	4585                	li	a1,1
ffffffffc0202064:	8552                	mv	a0,s4
ffffffffc0202066:	99b6                	add	s3,s3,a3
ffffffffc0202068:	edeff0ef          	jal	ra,ffffffffc0201746 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020206c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202070:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202072:	078a                	slli	a5,a5,0x2
ffffffffc0202074:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202076:	10e7f263          	bleu	a4,a5,ffffffffc020217a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020207a:	fff809b7          	lui	s3,0xfff80
ffffffffc020207e:	97ce                	add	a5,a5,s3
ffffffffc0202080:	00379513          	slli	a0,a5,0x3
ffffffffc0202084:	00093703          	ld	a4,0(s2)
ffffffffc0202088:	97aa                	add	a5,a5,a0
ffffffffc020208a:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020208e:	953a                	add	a0,a0,a4
ffffffffc0202090:	4585                	li	a1,1
ffffffffc0202092:	eb4ff0ef          	jal	ra,ffffffffc0201746 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202096:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020209a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020209c:	050a                	slli	a0,a0,0x2
ffffffffc020209e:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020a0:	0cf57d63          	bleu	a5,a0,ffffffffc020217a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02020a4:	013507b3          	add	a5,a0,s3
ffffffffc02020a8:	00379513          	slli	a0,a5,0x3
ffffffffc02020ac:	00093703          	ld	a4,0(s2)
ffffffffc02020b0:	953e                	add	a0,a0,a5
ffffffffc02020b2:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc02020b4:	4585                	li	a1,1
ffffffffc02020b6:	953a                	add	a0,a0,a4
ffffffffc02020b8:	e8eff0ef          	jal	ra,ffffffffc0201746 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02020bc:	601c                	ld	a5,0(s0)
ffffffffc02020be:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc02020c2:	ecaff0ef          	jal	ra,ffffffffc020178c <nr_free_pages>
ffffffffc02020c6:	38ab1a63          	bne	s6,a0,ffffffffc020245a <pmm_init+0x8e4>
}
ffffffffc02020ca:	6446                	ld	s0,80(sp)
ffffffffc02020cc:	60e6                	ld	ra,88(sp)
ffffffffc02020ce:	64a6                	ld	s1,72(sp)
ffffffffc02020d0:	6906                	ld	s2,64(sp)
ffffffffc02020d2:	79e2                	ld	s3,56(sp)
ffffffffc02020d4:	7a42                	ld	s4,48(sp)
ffffffffc02020d6:	7aa2                	ld	s5,40(sp)
ffffffffc02020d8:	7b02                	ld	s6,32(sp)
ffffffffc02020da:	6be2                	ld	s7,24(sp)
ffffffffc02020dc:	6c42                	ld	s8,16(sp)
ffffffffc02020de:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020e0:	00003517          	auipc	a0,0x3
ffffffffc02020e4:	66850513          	addi	a0,a0,1640 # ffffffffc0205748 <default_pmm_manager+0x680>
}
ffffffffc02020e8:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020ea:	fdffd06f          	j	ffffffffc02000c8 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020ee:	6705                	lui	a4,0x1
ffffffffc02020f0:	177d                	addi	a4,a4,-1
ffffffffc02020f2:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02020f4:	00c6d713          	srli	a4,a3,0xc
ffffffffc02020f8:	08f77163          	bleu	a5,a4,ffffffffc020217a <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc02020fc:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0202100:	9732                	add	a4,a4,a2
ffffffffc0202102:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202106:	767d                	lui	a2,0xfffff
ffffffffc0202108:	8ef1                	and	a3,a3,a2
ffffffffc020210a:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc020210c:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202110:	8d95                	sub	a1,a1,a3
ffffffffc0202112:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0202114:	81b1                	srli	a1,a1,0xc
ffffffffc0202116:	953e                	add	a0,a0,a5
ffffffffc0202118:	9702                	jalr	a4
ffffffffc020211a:	bead                	j	ffffffffc0201c94 <pmm_init+0x11e>
ffffffffc020211c:	6008                	ld	a0,0(s0)
ffffffffc020211e:	b5b5                	j	ffffffffc0201f8a <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202120:	86d2                	mv	a3,s4
ffffffffc0202122:	00003617          	auipc	a2,0x3
ffffffffc0202126:	ff660613          	addi	a2,a2,-10 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc020212a:	1cd00593          	li	a1,461
ffffffffc020212e:	00003517          	auipc	a0,0x3
ffffffffc0202132:	01250513          	addi	a0,a0,18 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202136:	a48fe0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc020213a:	00003697          	auipc	a3,0x3
ffffffffc020213e:	47e68693          	addi	a3,a3,1150 # ffffffffc02055b8 <default_pmm_manager+0x4f0>
ffffffffc0202142:	00003617          	auipc	a2,0x3
ffffffffc0202146:	bee60613          	addi	a2,a2,-1042 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020214a:	1cd00593          	li	a1,461
ffffffffc020214e:	00003517          	auipc	a0,0x3
ffffffffc0202152:	ff250513          	addi	a0,a0,-14 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202156:	a28fe0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020215a:	00003697          	auipc	a3,0x3
ffffffffc020215e:	49e68693          	addi	a3,a3,1182 # ffffffffc02055f8 <default_pmm_manager+0x530>
ffffffffc0202162:	00003617          	auipc	a2,0x3
ffffffffc0202166:	bce60613          	addi	a2,a2,-1074 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020216a:	1ce00593          	li	a1,462
ffffffffc020216e:	00003517          	auipc	a0,0x3
ffffffffc0202172:	fd250513          	addi	a0,a0,-46 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202176:	a08fe0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc020217a:	d28ff0ef          	jal	ra,ffffffffc02016a2 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020217e:	00003617          	auipc	a2,0x3
ffffffffc0202182:	f9a60613          	addi	a2,a2,-102 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc0202186:	06a00593          	li	a1,106
ffffffffc020218a:	00003517          	auipc	a0,0x3
ffffffffc020218e:	02650513          	addi	a0,a0,38 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0202192:	9ecfe0ef          	jal	ra,ffffffffc020037e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202196:	00003617          	auipc	a2,0x3
ffffffffc020219a:	1f260613          	addi	a2,a2,498 # ffffffffc0205388 <default_pmm_manager+0x2c0>
ffffffffc020219e:	07000593          	li	a1,112
ffffffffc02021a2:	00003517          	auipc	a0,0x3
ffffffffc02021a6:	00e50513          	addi	a0,a0,14 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc02021aa:	9d4fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02021ae:	00003697          	auipc	a3,0x3
ffffffffc02021b2:	11a68693          	addi	a3,a3,282 # ffffffffc02052c8 <default_pmm_manager+0x200>
ffffffffc02021b6:	00003617          	auipc	a2,0x3
ffffffffc02021ba:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02021be:	19300593          	li	a1,403
ffffffffc02021c2:	00003517          	auipc	a0,0x3
ffffffffc02021c6:	f7e50513          	addi	a0,a0,-130 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02021ca:	9b4fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02021ce:	00003697          	auipc	a3,0x3
ffffffffc02021d2:	13268693          	addi	a3,a3,306 # ffffffffc0205300 <default_pmm_manager+0x238>
ffffffffc02021d6:	00003617          	auipc	a2,0x3
ffffffffc02021da:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02021de:	19400593          	li	a1,404
ffffffffc02021e2:	00003517          	auipc	a0,0x3
ffffffffc02021e6:	f5e50513          	addi	a0,a0,-162 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02021ea:	994fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02021ee:	00003697          	auipc	a3,0x3
ffffffffc02021f2:	38a68693          	addi	a3,a3,906 # ffffffffc0205578 <default_pmm_manager+0x4b0>
ffffffffc02021f6:	00003617          	auipc	a2,0x3
ffffffffc02021fa:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02021fe:	1c000593          	li	a1,448
ffffffffc0202202:	00003517          	auipc	a0,0x3
ffffffffc0202206:	f3e50513          	addi	a0,a0,-194 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020220a:	974fe0ef          	jal	ra,ffffffffc020037e <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020220e:	00003617          	auipc	a2,0x3
ffffffffc0202212:	05260613          	addi	a2,a2,82 # ffffffffc0205260 <default_pmm_manager+0x198>
ffffffffc0202216:	07700593          	li	a1,119
ffffffffc020221a:	00003517          	auipc	a0,0x3
ffffffffc020221e:	f2650513          	addi	a0,a0,-218 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202222:	95cfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202226:	00003697          	auipc	a3,0x3
ffffffffc020222a:	13268693          	addi	a3,a3,306 # ffffffffc0205358 <default_pmm_manager+0x290>
ffffffffc020222e:	00003617          	auipc	a2,0x3
ffffffffc0202232:	b0260613          	addi	a2,a2,-1278 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202236:	19a00593          	li	a1,410
ffffffffc020223a:	00003517          	auipc	a0,0x3
ffffffffc020223e:	f0650513          	addi	a0,a0,-250 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202242:	93cfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202246:	00003697          	auipc	a3,0x3
ffffffffc020224a:	0e268693          	addi	a3,a3,226 # ffffffffc0205328 <default_pmm_manager+0x260>
ffffffffc020224e:	00003617          	auipc	a2,0x3
ffffffffc0202252:	ae260613          	addi	a2,a2,-1310 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202256:	19800593          	li	a1,408
ffffffffc020225a:	00003517          	auipc	a0,0x3
ffffffffc020225e:	ee650513          	addi	a0,a0,-282 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202262:	91cfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202266:	00003697          	auipc	a3,0x3
ffffffffc020226a:	20a68693          	addi	a3,a3,522 # ffffffffc0205470 <default_pmm_manager+0x3a8>
ffffffffc020226e:	00003617          	auipc	a2,0x3
ffffffffc0202272:	ac260613          	addi	a2,a2,-1342 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202276:	1a500593          	li	a1,421
ffffffffc020227a:	00003517          	auipc	a0,0x3
ffffffffc020227e:	ec650513          	addi	a0,a0,-314 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202282:	8fcfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202286:	00003697          	auipc	a3,0x3
ffffffffc020228a:	1ba68693          	addi	a3,a3,442 # ffffffffc0205440 <default_pmm_manager+0x378>
ffffffffc020228e:	00003617          	auipc	a2,0x3
ffffffffc0202292:	aa260613          	addi	a2,a2,-1374 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202296:	1a400593          	li	a1,420
ffffffffc020229a:	00003517          	auipc	a0,0x3
ffffffffc020229e:	ea650513          	addi	a0,a0,-346 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02022a2:	8dcfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02022a6:	00003697          	auipc	a3,0x3
ffffffffc02022aa:	16268693          	addi	a3,a3,354 # ffffffffc0205408 <default_pmm_manager+0x340>
ffffffffc02022ae:	00003617          	auipc	a2,0x3
ffffffffc02022b2:	a8260613          	addi	a2,a2,-1406 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02022b6:	1a300593          	li	a1,419
ffffffffc02022ba:	00003517          	auipc	a0,0x3
ffffffffc02022be:	e8650513          	addi	a0,a0,-378 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02022c2:	8bcfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02022c6:	00003697          	auipc	a3,0x3
ffffffffc02022ca:	11a68693          	addi	a3,a3,282 # ffffffffc02053e0 <default_pmm_manager+0x318>
ffffffffc02022ce:	00003617          	auipc	a2,0x3
ffffffffc02022d2:	a6260613          	addi	a2,a2,-1438 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02022d6:	1a000593          	li	a1,416
ffffffffc02022da:	00003517          	auipc	a0,0x3
ffffffffc02022de:	e6650513          	addi	a0,a0,-410 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02022e2:	89cfe0ef          	jal	ra,ffffffffc020037e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022e6:	86da                	mv	a3,s6
ffffffffc02022e8:	00003617          	auipc	a2,0x3
ffffffffc02022ec:	e3060613          	addi	a2,a2,-464 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc02022f0:	19f00593          	li	a1,415
ffffffffc02022f4:	00003517          	auipc	a0,0x3
ffffffffc02022f8:	e4c50513          	addi	a0,a0,-436 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02022fc:	882fe0ef          	jal	ra,ffffffffc020037e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202300:	86be                	mv	a3,a5
ffffffffc0202302:	00003617          	auipc	a2,0x3
ffffffffc0202306:	e1660613          	addi	a2,a2,-490 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc020230a:	19e00593          	li	a1,414
ffffffffc020230e:	00003517          	auipc	a0,0x3
ffffffffc0202312:	e3250513          	addi	a0,a0,-462 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202316:	868fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020231a:	00003697          	auipc	a3,0x3
ffffffffc020231e:	0ae68693          	addi	a3,a3,174 # ffffffffc02053c8 <default_pmm_manager+0x300>
ffffffffc0202322:	00003617          	auipc	a2,0x3
ffffffffc0202326:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020232a:	19c00593          	li	a1,412
ffffffffc020232e:	00003517          	auipc	a0,0x3
ffffffffc0202332:	e1250513          	addi	a0,a0,-494 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202336:	848fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020233a:	00003697          	auipc	a3,0x3
ffffffffc020233e:	07668693          	addi	a3,a3,118 # ffffffffc02053b0 <default_pmm_manager+0x2e8>
ffffffffc0202342:	00003617          	auipc	a2,0x3
ffffffffc0202346:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020234a:	19b00593          	li	a1,411
ffffffffc020234e:	00003517          	auipc	a0,0x3
ffffffffc0202352:	df250513          	addi	a0,a0,-526 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202356:	828fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020235a:	00003697          	auipc	a3,0x3
ffffffffc020235e:	05668693          	addi	a3,a3,86 # ffffffffc02053b0 <default_pmm_manager+0x2e8>
ffffffffc0202362:	00003617          	auipc	a2,0x3
ffffffffc0202366:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020236a:	1ae00593          	li	a1,430
ffffffffc020236e:	00003517          	auipc	a0,0x3
ffffffffc0202372:	dd250513          	addi	a0,a0,-558 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202376:	808fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020237a:	00003697          	auipc	a3,0x3
ffffffffc020237e:	0c668693          	addi	a3,a3,198 # ffffffffc0205440 <default_pmm_manager+0x378>
ffffffffc0202382:	00003617          	auipc	a2,0x3
ffffffffc0202386:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020238a:	1ad00593          	li	a1,429
ffffffffc020238e:	00003517          	auipc	a0,0x3
ffffffffc0202392:	db250513          	addi	a0,a0,-590 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202396:	fe9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020239a:	00003697          	auipc	a3,0x3
ffffffffc020239e:	16e68693          	addi	a3,a3,366 # ffffffffc0205508 <default_pmm_manager+0x440>
ffffffffc02023a2:	00003617          	auipc	a2,0x3
ffffffffc02023a6:	98e60613          	addi	a2,a2,-1650 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02023aa:	1ac00593          	li	a1,428
ffffffffc02023ae:	00003517          	auipc	a0,0x3
ffffffffc02023b2:	d9250513          	addi	a0,a0,-622 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02023b6:	fc9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02023ba:	00003697          	auipc	a3,0x3
ffffffffc02023be:	13668693          	addi	a3,a3,310 # ffffffffc02054f0 <default_pmm_manager+0x428>
ffffffffc02023c2:	00003617          	auipc	a2,0x3
ffffffffc02023c6:	96e60613          	addi	a2,a2,-1682 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02023ca:	1ab00593          	li	a1,427
ffffffffc02023ce:	00003517          	auipc	a0,0x3
ffffffffc02023d2:	d7250513          	addi	a0,a0,-654 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02023d6:	fa9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02023da:	00003697          	auipc	a3,0x3
ffffffffc02023de:	0e668693          	addi	a3,a3,230 # ffffffffc02054c0 <default_pmm_manager+0x3f8>
ffffffffc02023e2:	00003617          	auipc	a2,0x3
ffffffffc02023e6:	94e60613          	addi	a2,a2,-1714 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02023ea:	1aa00593          	li	a1,426
ffffffffc02023ee:	00003517          	auipc	a0,0x3
ffffffffc02023f2:	d5250513          	addi	a0,a0,-686 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02023f6:	f89fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02023fa:	00003697          	auipc	a3,0x3
ffffffffc02023fe:	0ae68693          	addi	a3,a3,174 # ffffffffc02054a8 <default_pmm_manager+0x3e0>
ffffffffc0202402:	00003617          	auipc	a2,0x3
ffffffffc0202406:	92e60613          	addi	a2,a2,-1746 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020240a:	1a800593          	li	a1,424
ffffffffc020240e:	00003517          	auipc	a0,0x3
ffffffffc0202412:	d3250513          	addi	a0,a0,-718 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202416:	f69fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020241a:	00003697          	auipc	a3,0x3
ffffffffc020241e:	07668693          	addi	a3,a3,118 # ffffffffc0205490 <default_pmm_manager+0x3c8>
ffffffffc0202422:	00003617          	auipc	a2,0x3
ffffffffc0202426:	90e60613          	addi	a2,a2,-1778 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020242a:	1a700593          	li	a1,423
ffffffffc020242e:	00003517          	auipc	a0,0x3
ffffffffc0202432:	d1250513          	addi	a0,a0,-750 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202436:	f49fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(*ptep & PTE_W);
ffffffffc020243a:	00003697          	auipc	a3,0x3
ffffffffc020243e:	04668693          	addi	a3,a3,70 # ffffffffc0205480 <default_pmm_manager+0x3b8>
ffffffffc0202442:	00003617          	auipc	a2,0x3
ffffffffc0202446:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020244a:	1a600593          	li	a1,422
ffffffffc020244e:	00003517          	auipc	a0,0x3
ffffffffc0202452:	cf250513          	addi	a0,a0,-782 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202456:	f29fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020245a:	00003697          	auipc	a3,0x3
ffffffffc020245e:	11e68693          	addi	a3,a3,286 # ffffffffc0205578 <default_pmm_manager+0x4b0>
ffffffffc0202462:	00003617          	auipc	a2,0x3
ffffffffc0202466:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020246a:	1e800593          	li	a1,488
ffffffffc020246e:	00003517          	auipc	a0,0x3
ffffffffc0202472:	cd250513          	addi	a0,a0,-814 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202476:	f09fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020247a:	00003697          	auipc	a3,0x3
ffffffffc020247e:	2a668693          	addi	a3,a3,678 # ffffffffc0205720 <default_pmm_manager+0x658>
ffffffffc0202482:	00003617          	auipc	a2,0x3
ffffffffc0202486:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020248a:	1e000593          	li	a1,480
ffffffffc020248e:	00003517          	auipc	a0,0x3
ffffffffc0202492:	cb250513          	addi	a0,a0,-846 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202496:	ee9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020249a:	00003697          	auipc	a3,0x3
ffffffffc020249e:	24e68693          	addi	a3,a3,590 # ffffffffc02056e8 <default_pmm_manager+0x620>
ffffffffc02024a2:	00003617          	auipc	a2,0x3
ffffffffc02024a6:	88e60613          	addi	a2,a2,-1906 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02024aa:	1dd00593          	li	a1,477
ffffffffc02024ae:	00003517          	auipc	a0,0x3
ffffffffc02024b2:	c9250513          	addi	a0,a0,-878 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02024b6:	ec9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p) == 2);
ffffffffc02024ba:	00003697          	auipc	a3,0x3
ffffffffc02024be:	1fe68693          	addi	a3,a3,510 # ffffffffc02056b8 <default_pmm_manager+0x5f0>
ffffffffc02024c2:	00003617          	auipc	a2,0x3
ffffffffc02024c6:	86e60613          	addi	a2,a2,-1938 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02024ca:	1d900593          	li	a1,473
ffffffffc02024ce:	00003517          	auipc	a0,0x3
ffffffffc02024d2:	c7250513          	addi	a0,a0,-910 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02024d6:	ea9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02024da:	00003697          	auipc	a3,0x3
ffffffffc02024de:	05e68693          	addi	a3,a3,94 # ffffffffc0205538 <default_pmm_manager+0x470>
ffffffffc02024e2:	00003617          	auipc	a2,0x3
ffffffffc02024e6:	84e60613          	addi	a2,a2,-1970 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02024ea:	1b600593          	li	a1,438
ffffffffc02024ee:	00003517          	auipc	a0,0x3
ffffffffc02024f2:	c5250513          	addi	a0,a0,-942 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02024f6:	e89fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024fa:	00003697          	auipc	a3,0x3
ffffffffc02024fe:	00e68693          	addi	a3,a3,14 # ffffffffc0205508 <default_pmm_manager+0x440>
ffffffffc0202502:	00003617          	auipc	a2,0x3
ffffffffc0202506:	82e60613          	addi	a2,a2,-2002 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020250a:	1b300593          	li	a1,435
ffffffffc020250e:	00003517          	auipc	a0,0x3
ffffffffc0202512:	c3250513          	addi	a0,a0,-974 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202516:	e69fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020251a:	00003697          	auipc	a3,0x3
ffffffffc020251e:	eae68693          	addi	a3,a3,-338 # ffffffffc02053c8 <default_pmm_manager+0x300>
ffffffffc0202522:	00003617          	auipc	a2,0x3
ffffffffc0202526:	80e60613          	addi	a2,a2,-2034 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020252a:	1b200593          	li	a1,434
ffffffffc020252e:	00003517          	auipc	a0,0x3
ffffffffc0202532:	c1250513          	addi	a0,a0,-1006 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202536:	e49fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020253a:	00003697          	auipc	a3,0x3
ffffffffc020253e:	fe668693          	addi	a3,a3,-26 # ffffffffc0205520 <default_pmm_manager+0x458>
ffffffffc0202542:	00002617          	auipc	a2,0x2
ffffffffc0202546:	7ee60613          	addi	a2,a2,2030 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020254a:	1af00593          	li	a1,431
ffffffffc020254e:	00003517          	auipc	a0,0x3
ffffffffc0202552:	bf250513          	addi	a0,a0,-1038 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202556:	e29fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020255a:	00003697          	auipc	a3,0x3
ffffffffc020255e:	ff668693          	addi	a3,a3,-10 # ffffffffc0205550 <default_pmm_manager+0x488>
ffffffffc0202562:	00002617          	auipc	a2,0x2
ffffffffc0202566:	7ce60613          	addi	a2,a2,1998 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020256a:	1b900593          	li	a1,441
ffffffffc020256e:	00003517          	auipc	a0,0x3
ffffffffc0202572:	bd250513          	addi	a0,a0,-1070 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202576:	e09fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020257a:	00003697          	auipc	a3,0x3
ffffffffc020257e:	f8e68693          	addi	a3,a3,-114 # ffffffffc0205508 <default_pmm_manager+0x440>
ffffffffc0202582:	00002617          	auipc	a2,0x2
ffffffffc0202586:	7ae60613          	addi	a2,a2,1966 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020258a:	1b700593          	li	a1,439
ffffffffc020258e:	00003517          	auipc	a0,0x3
ffffffffc0202592:	bb250513          	addi	a0,a0,-1102 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202596:	de9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020259a:	00003697          	auipc	a3,0x3
ffffffffc020259e:	d0e68693          	addi	a3,a3,-754 # ffffffffc02052a8 <default_pmm_manager+0x1e0>
ffffffffc02025a2:	00002617          	auipc	a2,0x2
ffffffffc02025a6:	78e60613          	addi	a2,a2,1934 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02025aa:	19200593          	li	a1,402
ffffffffc02025ae:	00003517          	auipc	a0,0x3
ffffffffc02025b2:	b9250513          	addi	a0,a0,-1134 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02025b6:	dc9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02025ba:	00003617          	auipc	a2,0x3
ffffffffc02025be:	ca660613          	addi	a2,a2,-858 # ffffffffc0205260 <default_pmm_manager+0x198>
ffffffffc02025c2:	0bd00593          	li	a1,189
ffffffffc02025c6:	00003517          	auipc	a0,0x3
ffffffffc02025ca:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02025ce:	db1fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02025d2:	00003697          	auipc	a3,0x3
ffffffffc02025d6:	0a668693          	addi	a3,a3,166 # ffffffffc0205678 <default_pmm_manager+0x5b0>
ffffffffc02025da:	00002617          	auipc	a2,0x2
ffffffffc02025de:	75660613          	addi	a2,a2,1878 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02025e2:	1d800593          	li	a1,472
ffffffffc02025e6:	00003517          	auipc	a0,0x3
ffffffffc02025ea:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02025ee:	d91fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p) == 1);
ffffffffc02025f2:	00003697          	auipc	a3,0x3
ffffffffc02025f6:	06e68693          	addi	a3,a3,110 # ffffffffc0205660 <default_pmm_manager+0x598>
ffffffffc02025fa:	00002617          	auipc	a2,0x2
ffffffffc02025fe:	73660613          	addi	a2,a2,1846 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202602:	1d700593          	li	a1,471
ffffffffc0202606:	00003517          	auipc	a0,0x3
ffffffffc020260a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020260e:	d71fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202612:	00003697          	auipc	a3,0x3
ffffffffc0202616:	01668693          	addi	a3,a3,22 # ffffffffc0205628 <default_pmm_manager+0x560>
ffffffffc020261a:	00002617          	auipc	a2,0x2
ffffffffc020261e:	71660613          	addi	a2,a2,1814 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202622:	1d600593          	li	a1,470
ffffffffc0202626:	00003517          	auipc	a0,0x3
ffffffffc020262a:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020262e:	d51fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202632:	00003697          	auipc	a3,0x3
ffffffffc0202636:	fde68693          	addi	a3,a3,-34 # ffffffffc0205610 <default_pmm_manager+0x548>
ffffffffc020263a:	00002617          	auipc	a2,0x2
ffffffffc020263e:	6f660613          	addi	a2,a2,1782 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202642:	1d200593          	li	a1,466
ffffffffc0202646:	00003517          	auipc	a0,0x3
ffffffffc020264a:	afa50513          	addi	a0,a0,-1286 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020264e:	d31fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0202652 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202652:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0202656:	8082                	ret

ffffffffc0202658 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202658:	7179                	addi	sp,sp,-48
ffffffffc020265a:	e84a                	sd	s2,16(sp)
ffffffffc020265c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020265e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202660:	f022                	sd	s0,32(sp)
ffffffffc0202662:	ec26                	sd	s1,24(sp)
ffffffffc0202664:	e44e                	sd	s3,8(sp)
ffffffffc0202666:	f406                	sd	ra,40(sp)
ffffffffc0202668:	84ae                	mv	s1,a1
ffffffffc020266a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020266c:	852ff0ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc0202670:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202672:	cd19                	beqz	a0,ffffffffc0202690 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202674:	85aa                	mv	a1,a0
ffffffffc0202676:	86ce                	mv	a3,s3
ffffffffc0202678:	8626                	mv	a2,s1
ffffffffc020267a:	854a                	mv	a0,s2
ffffffffc020267c:	c28ff0ef          	jal	ra,ffffffffc0201aa4 <page_insert>
ffffffffc0202680:	ed39                	bnez	a0,ffffffffc02026de <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202682:	0000f797          	auipc	a5,0xf
ffffffffc0202686:	de678793          	addi	a5,a5,-538 # ffffffffc0211468 <swap_init_ok>
ffffffffc020268a:	439c                	lw	a5,0(a5)
ffffffffc020268c:	2781                	sext.w	a5,a5
ffffffffc020268e:	eb89                	bnez	a5,ffffffffc02026a0 <pgdir_alloc_page+0x48>
}
ffffffffc0202690:	8522                	mv	a0,s0
ffffffffc0202692:	70a2                	ld	ra,40(sp)
ffffffffc0202694:	7402                	ld	s0,32(sp)
ffffffffc0202696:	64e2                	ld	s1,24(sp)
ffffffffc0202698:	6942                	ld	s2,16(sp)
ffffffffc020269a:	69a2                	ld	s3,8(sp)
ffffffffc020269c:	6145                	addi	sp,sp,48
ffffffffc020269e:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02026a0:	0000f797          	auipc	a5,0xf
ffffffffc02026a4:	fe078793          	addi	a5,a5,-32 # ffffffffc0211680 <check_mm_struct>
ffffffffc02026a8:	6388                	ld	a0,0(a5)
ffffffffc02026aa:	4681                	li	a3,0
ffffffffc02026ac:	8622                	mv	a2,s0
ffffffffc02026ae:	85a6                	mv	a1,s1
ffffffffc02026b0:	06d000ef          	jal	ra,ffffffffc0202f1c <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc02026b4:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc02026b6:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc02026b8:	4785                	li	a5,1
ffffffffc02026ba:	fcf70be3          	beq	a4,a5,ffffffffc0202690 <pgdir_alloc_page+0x38>
ffffffffc02026be:	00003697          	auipc	a3,0x3
ffffffffc02026c2:	b0268693          	addi	a3,a3,-1278 # ffffffffc02051c0 <default_pmm_manager+0xf8>
ffffffffc02026c6:	00002617          	auipc	a2,0x2
ffffffffc02026ca:	66a60613          	addi	a2,a2,1642 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02026ce:	17a00593          	li	a1,378
ffffffffc02026d2:	00003517          	auipc	a0,0x3
ffffffffc02026d6:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02026da:	ca5fd0ef          	jal	ra,ffffffffc020037e <__panic>
            free_page(page);
ffffffffc02026de:	8522                	mv	a0,s0
ffffffffc02026e0:	4585                	li	a1,1
ffffffffc02026e2:	864ff0ef          	jal	ra,ffffffffc0201746 <free_pages>
            return NULL;
ffffffffc02026e6:	4401                	li	s0,0
ffffffffc02026e8:	b765                	j	ffffffffc0202690 <pgdir_alloc_page+0x38>

ffffffffc02026ea <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02026ea:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026ec:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02026ee:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026f0:	fff50713          	addi	a4,a0,-1
ffffffffc02026f4:	17f9                	addi	a5,a5,-2
ffffffffc02026f6:	04e7ee63          	bltu	a5,a4,ffffffffc0202752 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02026fa:	6785                	lui	a5,0x1
ffffffffc02026fc:	17fd                	addi	a5,a5,-1
ffffffffc02026fe:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0202700:	8131                	srli	a0,a0,0xc
ffffffffc0202702:	fbdfe0ef          	jal	ra,ffffffffc02016be <alloc_pages>
    assert(base != NULL);
ffffffffc0202706:	c159                	beqz	a0,ffffffffc020278c <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202708:	0000f797          	auipc	a5,0xf
ffffffffc020270c:	e9078793          	addi	a5,a5,-368 # ffffffffc0211598 <pages>
ffffffffc0202710:	639c                	ld	a5,0(a5)
ffffffffc0202712:	8d1d                	sub	a0,a0,a5
ffffffffc0202714:	00002797          	auipc	a5,0x2
ffffffffc0202718:	60478793          	addi	a5,a5,1540 # ffffffffc0204d18 <commands+0x8c0>
ffffffffc020271c:	6394                	ld	a3,0(a5)
ffffffffc020271e:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202720:	0000f797          	auipc	a5,0xf
ffffffffc0202724:	d3878793          	addi	a5,a5,-712 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202728:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020272c:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020272e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202732:	57fd                	li	a5,-1
ffffffffc0202734:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202736:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202738:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020273a:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020273c:	02e7fb63          	bleu	a4,a5,ffffffffc0202772 <kmalloc+0x88>
ffffffffc0202740:	0000f797          	auipc	a5,0xf
ffffffffc0202744:	e4878793          	addi	a5,a5,-440 # ffffffffc0211588 <va_pa_offset>
ffffffffc0202748:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc020274a:	60a2                	ld	ra,8(sp)
ffffffffc020274c:	953e                	add	a0,a0,a5
ffffffffc020274e:	0141                	addi	sp,sp,16
ffffffffc0202750:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202752:	00003697          	auipc	a3,0x3
ffffffffc0202756:	a0e68693          	addi	a3,a3,-1522 # ffffffffc0205160 <default_pmm_manager+0x98>
ffffffffc020275a:	00002617          	auipc	a2,0x2
ffffffffc020275e:	5d660613          	addi	a2,a2,1494 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202762:	1f000593          	li	a1,496
ffffffffc0202766:	00003517          	auipc	a0,0x3
ffffffffc020276a:	9da50513          	addi	a0,a0,-1574 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020276e:	c11fd0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc0202772:	86aa                	mv	a3,a0
ffffffffc0202774:	00003617          	auipc	a2,0x3
ffffffffc0202778:	9a460613          	addi	a2,a2,-1628 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc020277c:	06a00593          	li	a1,106
ffffffffc0202780:	00003517          	auipc	a0,0x3
ffffffffc0202784:	a3050513          	addi	a0,a0,-1488 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0202788:	bf7fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(base != NULL);
ffffffffc020278c:	00003697          	auipc	a3,0x3
ffffffffc0202790:	9f468693          	addi	a3,a3,-1548 # ffffffffc0205180 <default_pmm_manager+0xb8>
ffffffffc0202794:	00002617          	auipc	a2,0x2
ffffffffc0202798:	59c60613          	addi	a2,a2,1436 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020279c:	1f300593          	li	a1,499
ffffffffc02027a0:	00003517          	auipc	a0,0x3
ffffffffc02027a4:	9a050513          	addi	a0,a0,-1632 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02027a8:	bd7fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02027ac <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc02027ac:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027ae:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc02027b0:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027b2:	fff58713          	addi	a4,a1,-1
ffffffffc02027b6:	17f9                	addi	a5,a5,-2
ffffffffc02027b8:	04e7eb63          	bltu	a5,a4,ffffffffc020280e <kfree+0x62>
    assert(ptr != NULL);
ffffffffc02027bc:	c941                	beqz	a0,ffffffffc020284c <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02027be:	6785                	lui	a5,0x1
ffffffffc02027c0:	17fd                	addi	a5,a5,-1
ffffffffc02027c2:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027c4:	c02007b7          	lui	a5,0xc0200
ffffffffc02027c8:	81b1                	srli	a1,a1,0xc
ffffffffc02027ca:	06f56463          	bltu	a0,a5,ffffffffc0202832 <kfree+0x86>
ffffffffc02027ce:	0000f797          	auipc	a5,0xf
ffffffffc02027d2:	dba78793          	addi	a5,a5,-582 # ffffffffc0211588 <va_pa_offset>
ffffffffc02027d6:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02027d8:	0000f717          	auipc	a4,0xf
ffffffffc02027dc:	c8070713          	addi	a4,a4,-896 # ffffffffc0211458 <npage>
ffffffffc02027e0:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027e2:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc02027e6:	83b1                	srli	a5,a5,0xc
ffffffffc02027e8:	04e7f363          	bleu	a4,a5,ffffffffc020282e <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc02027ec:	fff80537          	lui	a0,0xfff80
ffffffffc02027f0:	97aa                	add	a5,a5,a0
ffffffffc02027f2:	0000f697          	auipc	a3,0xf
ffffffffc02027f6:	da668693          	addi	a3,a3,-602 # ffffffffc0211598 <pages>
ffffffffc02027fa:	6288                	ld	a0,0(a3)
ffffffffc02027fc:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0202800:	60a2                	ld	ra,8(sp)
ffffffffc0202802:	97ba                	add	a5,a5,a4
ffffffffc0202804:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0202806:	953e                	add	a0,a0,a5
}
ffffffffc0202808:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc020280a:	f3dfe06f          	j	ffffffffc0201746 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020280e:	00003697          	auipc	a3,0x3
ffffffffc0202812:	95268693          	addi	a3,a3,-1710 # ffffffffc0205160 <default_pmm_manager+0x98>
ffffffffc0202816:	00002617          	auipc	a2,0x2
ffffffffc020281a:	51a60613          	addi	a2,a2,1306 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020281e:	1f900593          	li	a1,505
ffffffffc0202822:	00003517          	auipc	a0,0x3
ffffffffc0202826:	91e50513          	addi	a0,a0,-1762 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020282a:	b55fd0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc020282e:	e75fe0ef          	jal	ra,ffffffffc02016a2 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202832:	86aa                	mv	a3,a0
ffffffffc0202834:	00003617          	auipc	a2,0x3
ffffffffc0202838:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0205260 <default_pmm_manager+0x198>
ffffffffc020283c:	06c00593          	li	a1,108
ffffffffc0202840:	00003517          	auipc	a0,0x3
ffffffffc0202844:	97050513          	addi	a0,a0,-1680 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0202848:	b37fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(ptr != NULL);
ffffffffc020284c:	00003697          	auipc	a3,0x3
ffffffffc0202850:	90468693          	addi	a3,a3,-1788 # ffffffffc0205150 <default_pmm_manager+0x88>
ffffffffc0202854:	00002617          	auipc	a2,0x2
ffffffffc0202858:	4dc60613          	addi	a2,a2,1244 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020285c:	1fa00593          	li	a1,506
ffffffffc0202860:	00003517          	auipc	a0,0x3
ffffffffc0202864:	8e050513          	addi	a0,a0,-1824 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202868:	b17fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc020286c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020286c:	7135                	addi	sp,sp,-160
ffffffffc020286e:	ed06                	sd	ra,152(sp)
ffffffffc0202870:	e922                	sd	s0,144(sp)
ffffffffc0202872:	e526                	sd	s1,136(sp)
ffffffffc0202874:	e14a                	sd	s2,128(sp)
ffffffffc0202876:	fcce                	sd	s3,120(sp)
ffffffffc0202878:	f8d2                	sd	s4,112(sp)
ffffffffc020287a:	f4d6                	sd	s5,104(sp)
ffffffffc020287c:	f0da                	sd	s6,96(sp)
ffffffffc020287e:	ecde                	sd	s7,88(sp)
ffffffffc0202880:	e8e2                	sd	s8,80(sp)
ffffffffc0202882:	e4e6                	sd	s9,72(sp)
ffffffffc0202884:	e0ea                	sd	s10,64(sp)
ffffffffc0202886:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202888:	3a4010ef          	jal	ra,ffffffffc0203c2c <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020288c:	0000f797          	auipc	a5,0xf
ffffffffc0202890:	d9c78793          	addi	a5,a5,-612 # ffffffffc0211628 <max_swap_offset>
ffffffffc0202894:	6394                	ld	a3,0(a5)
ffffffffc0202896:	010007b7          	lui	a5,0x1000
ffffffffc020289a:	17e1                	addi	a5,a5,-8
ffffffffc020289c:	ff968713          	addi	a4,a3,-7
ffffffffc02028a0:	42e7ea63          	bltu	a5,a4,ffffffffc0202cd4 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02028a4:	00007797          	auipc	a5,0x7
ffffffffc02028a8:	75c78793          	addi	a5,a5,1884 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc02028ac:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02028ae:	0000f697          	auipc	a3,0xf
ffffffffc02028b2:	baf6b923          	sd	a5,-1102(a3) # ffffffffc0211460 <sm>
     int r = sm->init();
ffffffffc02028b6:	9702                	jalr	a4
ffffffffc02028b8:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc02028ba:	c10d                	beqz	a0,ffffffffc02028dc <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02028bc:	60ea                	ld	ra,152(sp)
ffffffffc02028be:	644a                	ld	s0,144(sp)
ffffffffc02028c0:	855a                	mv	a0,s6
ffffffffc02028c2:	64aa                	ld	s1,136(sp)
ffffffffc02028c4:	690a                	ld	s2,128(sp)
ffffffffc02028c6:	79e6                	ld	s3,120(sp)
ffffffffc02028c8:	7a46                	ld	s4,112(sp)
ffffffffc02028ca:	7aa6                	ld	s5,104(sp)
ffffffffc02028cc:	7b06                	ld	s6,96(sp)
ffffffffc02028ce:	6be6                	ld	s7,88(sp)
ffffffffc02028d0:	6c46                	ld	s8,80(sp)
ffffffffc02028d2:	6ca6                	ld	s9,72(sp)
ffffffffc02028d4:	6d06                	ld	s10,64(sp)
ffffffffc02028d6:	7de2                	ld	s11,56(sp)
ffffffffc02028d8:	610d                	addi	sp,sp,160
ffffffffc02028da:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028dc:	0000f797          	auipc	a5,0xf
ffffffffc02028e0:	b8478793          	addi	a5,a5,-1148 # ffffffffc0211460 <sm>
ffffffffc02028e4:	639c                	ld	a5,0(a5)
ffffffffc02028e6:	00003517          	auipc	a0,0x3
ffffffffc02028ea:	f0250513          	addi	a0,a0,-254 # ffffffffc02057e8 <default_pmm_manager+0x720>
    return listelm->next;
ffffffffc02028ee:	0000f417          	auipc	s0,0xf
ffffffffc02028f2:	b8a40413          	addi	s0,s0,-1142 # ffffffffc0211478 <free_area>
ffffffffc02028f6:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02028f8:	4785                	li	a5,1
ffffffffc02028fa:	0000f717          	auipc	a4,0xf
ffffffffc02028fe:	b6f72723          	sw	a5,-1170(a4) # ffffffffc0211468 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202902:	fc6fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
ffffffffc0202906:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202908:	2e878a63          	beq	a5,s0,ffffffffc0202bfc <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020290c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202910:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202912:	8b05                	andi	a4,a4,1
ffffffffc0202914:	2e070863          	beqz	a4,ffffffffc0202c04 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc0202918:	4481                	li	s1,0
ffffffffc020291a:	4901                	li	s2,0
ffffffffc020291c:	a031                	j	ffffffffc0202928 <swap_init+0xbc>
ffffffffc020291e:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202922:	8b09                	andi	a4,a4,2
ffffffffc0202924:	2e070063          	beqz	a4,ffffffffc0202c04 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc0202928:	ff87a703          	lw	a4,-8(a5)
ffffffffc020292c:	679c                	ld	a5,8(a5)
ffffffffc020292e:	2905                	addiw	s2,s2,1
ffffffffc0202930:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202932:	fe8796e3          	bne	a5,s0,ffffffffc020291e <swap_init+0xb2>
ffffffffc0202936:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202938:	e55fe0ef          	jal	ra,ffffffffc020178c <nr_free_pages>
ffffffffc020293c:	5b351863          	bne	a0,s3,ffffffffc0202eec <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202940:	8626                	mv	a2,s1
ffffffffc0202942:	85ca                	mv	a1,s2
ffffffffc0202944:	00003517          	auipc	a0,0x3
ffffffffc0202948:	ebc50513          	addi	a0,a0,-324 # ffffffffc0205800 <default_pmm_manager+0x738>
ffffffffc020294c:	f7cfd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202950:	30f000ef          	jal	ra,ffffffffc020345e <mm_create>
ffffffffc0202954:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202956:	50050b63          	beqz	a0,ffffffffc0202e6c <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020295a:	0000f797          	auipc	a5,0xf
ffffffffc020295e:	d2678793          	addi	a5,a5,-730 # ffffffffc0211680 <check_mm_struct>
ffffffffc0202962:	639c                	ld	a5,0(a5)
ffffffffc0202964:	52079463          	bnez	a5,ffffffffc0202e8c <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202968:	0000f797          	auipc	a5,0xf
ffffffffc020296c:	ae878793          	addi	a5,a5,-1304 # ffffffffc0211450 <boot_pgdir>
ffffffffc0202970:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0202972:	0000f797          	auipc	a5,0xf
ffffffffc0202976:	d0a7b723          	sd	a0,-754(a5) # ffffffffc0211680 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020297a:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020297c:	ec3a                	sd	a4,24(sp)
ffffffffc020297e:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202980:	52079663          	bnez	a5,ffffffffc0202eac <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202984:	6599                	lui	a1,0x6
ffffffffc0202986:	460d                	li	a2,3
ffffffffc0202988:	6505                	lui	a0,0x1
ffffffffc020298a:	321000ef          	jal	ra,ffffffffc02034aa <vma_create>
ffffffffc020298e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202990:	52050e63          	beqz	a0,ffffffffc0202ecc <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0202994:	855e                	mv	a0,s7
ffffffffc0202996:	381000ef          	jal	ra,ffffffffc0203516 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020299a:	00003517          	auipc	a0,0x3
ffffffffc020299e:	ed650513          	addi	a0,a0,-298 # ffffffffc0205870 <default_pmm_manager+0x7a8>
ffffffffc02029a2:	f26fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02029a6:	018bb503          	ld	a0,24(s7)
ffffffffc02029aa:	4605                	li	a2,1
ffffffffc02029ac:	6585                	lui	a1,0x1
ffffffffc02029ae:	e1ffe0ef          	jal	ra,ffffffffc02017cc <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02029b2:	40050d63          	beqz	a0,ffffffffc0202dcc <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02029b6:	00003517          	auipc	a0,0x3
ffffffffc02029ba:	f0a50513          	addi	a0,a0,-246 # ffffffffc02058c0 <default_pmm_manager+0x7f8>
ffffffffc02029be:	0000fa17          	auipc	s4,0xf
ffffffffc02029c2:	be2a0a13          	addi	s4,s4,-1054 # ffffffffc02115a0 <check_rp>
ffffffffc02029c6:	f02fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029ca:	0000fa97          	auipc	s5,0xf
ffffffffc02029ce:	bf6a8a93          	addi	s5,s5,-1034 # ffffffffc02115c0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02029d2:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc02029d4:	4505                	li	a0,1
ffffffffc02029d6:	ce9fe0ef          	jal	ra,ffffffffc02016be <alloc_pages>
ffffffffc02029da:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6e978>
          assert(check_rp[i] != NULL );
ffffffffc02029de:	2a050b63          	beqz	a0,ffffffffc0202c94 <swap_init+0x428>
ffffffffc02029e2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02029e4:	8b89                	andi	a5,a5,2
ffffffffc02029e6:	28079763          	bnez	a5,ffffffffc0202c74 <swap_init+0x408>
ffffffffc02029ea:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029ec:	ff5994e3          	bne	s3,s5,ffffffffc02029d4 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02029f0:	601c                	ld	a5,0(s0)
ffffffffc02029f2:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02029f6:	0000fd17          	auipc	s10,0xf
ffffffffc02029fa:	baad0d13          	addi	s10,s10,-1110 # ffffffffc02115a0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02029fe:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202a00:	481c                	lw	a5,16(s0)
ffffffffc0202a02:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202a04:	0000f797          	auipc	a5,0xf
ffffffffc0202a08:	a687be23          	sd	s0,-1412(a5) # ffffffffc0211480 <free_area+0x8>
ffffffffc0202a0c:	0000f797          	auipc	a5,0xf
ffffffffc0202a10:	a687b623          	sd	s0,-1428(a5) # ffffffffc0211478 <free_area>
     nr_free = 0;
ffffffffc0202a14:	0000f797          	auipc	a5,0xf
ffffffffc0202a18:	a607aa23          	sw	zero,-1420(a5) # ffffffffc0211488 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202a1c:	000d3503          	ld	a0,0(s10)
ffffffffc0202a20:	4585                	li	a1,1
ffffffffc0202a22:	0d21                	addi	s10,s10,8
ffffffffc0202a24:	d23fe0ef          	jal	ra,ffffffffc0201746 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a28:	ff5d1ae3          	bne	s10,s5,ffffffffc0202a1c <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202a2c:	01042d03          	lw	s10,16(s0)
ffffffffc0202a30:	4791                	li	a5,4
ffffffffc0202a32:	36fd1d63          	bne	s10,a5,ffffffffc0202dac <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202a36:	00003517          	auipc	a0,0x3
ffffffffc0202a3a:	f1250513          	addi	a0,a0,-238 # ffffffffc0205948 <default_pmm_manager+0x880>
ffffffffc0202a3e:	e8afd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a42:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202a44:	0000f797          	auipc	a5,0xf
ffffffffc0202a48:	a207a423          	sw	zero,-1496(a5) # ffffffffc021146c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a4c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202a4e:	0000f797          	auipc	a5,0xf
ffffffffc0202a52:	a1e78793          	addi	a5,a5,-1506 # ffffffffc021146c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a56:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202a5a:	4398                	lw	a4,0(a5)
ffffffffc0202a5c:	4585                	li	a1,1
ffffffffc0202a5e:	2701                	sext.w	a4,a4
ffffffffc0202a60:	30b71663          	bne	a4,a1,ffffffffc0202d6c <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202a64:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202a68:	4394                	lw	a3,0(a5)
ffffffffc0202a6a:	2681                	sext.w	a3,a3
ffffffffc0202a6c:	32e69063          	bne	a3,a4,ffffffffc0202d8c <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202a70:	6689                	lui	a3,0x2
ffffffffc0202a72:	462d                	li	a2,11
ffffffffc0202a74:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202a78:	4398                	lw	a4,0(a5)
ffffffffc0202a7a:	4589                	li	a1,2
ffffffffc0202a7c:	2701                	sext.w	a4,a4
ffffffffc0202a7e:	26b71763          	bne	a4,a1,ffffffffc0202cec <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202a82:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202a86:	4394                	lw	a3,0(a5)
ffffffffc0202a88:	2681                	sext.w	a3,a3
ffffffffc0202a8a:	28e69163          	bne	a3,a4,ffffffffc0202d0c <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202a8e:	668d                	lui	a3,0x3
ffffffffc0202a90:	4631                	li	a2,12
ffffffffc0202a92:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202a96:	4398                	lw	a4,0(a5)
ffffffffc0202a98:	458d                	li	a1,3
ffffffffc0202a9a:	2701                	sext.w	a4,a4
ffffffffc0202a9c:	28b71863          	bne	a4,a1,ffffffffc0202d2c <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202aa0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202aa4:	4394                	lw	a3,0(a5)
ffffffffc0202aa6:	2681                	sext.w	a3,a3
ffffffffc0202aa8:	2ae69263          	bne	a3,a4,ffffffffc0202d4c <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202aac:	6691                	lui	a3,0x4
ffffffffc0202aae:	4635                	li	a2,13
ffffffffc0202ab0:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202ab4:	4398                	lw	a4,0(a5)
ffffffffc0202ab6:	2701                	sext.w	a4,a4
ffffffffc0202ab8:	33a71a63          	bne	a4,s10,ffffffffc0202dec <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202abc:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202ac0:	439c                	lw	a5,0(a5)
ffffffffc0202ac2:	2781                	sext.w	a5,a5
ffffffffc0202ac4:	34e79463          	bne	a5,a4,ffffffffc0202e0c <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202ac8:	481c                	lw	a5,16(s0)
ffffffffc0202aca:	36079163          	bnez	a5,ffffffffc0202e2c <swap_init+0x5c0>
ffffffffc0202ace:	0000f797          	auipc	a5,0xf
ffffffffc0202ad2:	af278793          	addi	a5,a5,-1294 # ffffffffc02115c0 <swap_in_seq_no>
ffffffffc0202ad6:	0000f717          	auipc	a4,0xf
ffffffffc0202ada:	b1270713          	addi	a4,a4,-1262 # ffffffffc02115e8 <swap_out_seq_no>
ffffffffc0202ade:	0000f617          	auipc	a2,0xf
ffffffffc0202ae2:	b0a60613          	addi	a2,a2,-1270 # ffffffffc02115e8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202ae6:	56fd                	li	a3,-1
ffffffffc0202ae8:	c394                	sw	a3,0(a5)
ffffffffc0202aea:	c314                	sw	a3,0(a4)
ffffffffc0202aec:	0791                	addi	a5,a5,4
ffffffffc0202aee:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202af0:	fec79ce3          	bne	a5,a2,ffffffffc0202ae8 <swap_init+0x27c>
ffffffffc0202af4:	0000f697          	auipc	a3,0xf
ffffffffc0202af8:	b5468693          	addi	a3,a3,-1196 # ffffffffc0211648 <check_ptep>
ffffffffc0202afc:	0000f817          	auipc	a6,0xf
ffffffffc0202b00:	aa480813          	addi	a6,a6,-1372 # ffffffffc02115a0 <check_rp>
ffffffffc0202b04:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202b06:	0000fc97          	auipc	s9,0xf
ffffffffc0202b0a:	952c8c93          	addi	s9,s9,-1710 # ffffffffc0211458 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b0e:	0000fd97          	auipc	s11,0xf
ffffffffc0202b12:	a8ad8d93          	addi	s11,s11,-1398 # ffffffffc0211598 <pages>
ffffffffc0202b16:	00003d17          	auipc	s10,0x3
ffffffffc0202b1a:	6b2d0d13          	addi	s10,s10,1714 # ffffffffc02061c8 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b1e:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202b20:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b24:	4601                	li	a2,0
ffffffffc0202b26:	85e2                	mv	a1,s8
ffffffffc0202b28:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202b2a:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b2c:	ca1fe0ef          	jal	ra,ffffffffc02017cc <get_pte>
ffffffffc0202b30:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202b32:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b34:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202b36:	16050f63          	beqz	a0,ffffffffc0202cb4 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202b3a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202b3c:	0017f613          	andi	a2,a5,1
ffffffffc0202b40:	10060263          	beqz	a2,ffffffffc0202c44 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202b44:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b48:	078a                	slli	a5,a5,0x2
ffffffffc0202b4a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b4c:	10c7f863          	bleu	a2,a5,ffffffffc0202c5c <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b50:	000d3603          	ld	a2,0(s10)
ffffffffc0202b54:	000db583          	ld	a1,0(s11)
ffffffffc0202b58:	00083503          	ld	a0,0(a6)
ffffffffc0202b5c:	8f91                	sub	a5,a5,a2
ffffffffc0202b5e:	00379613          	slli	a2,a5,0x3
ffffffffc0202b62:	97b2                	add	a5,a5,a2
ffffffffc0202b64:	078e                	slli	a5,a5,0x3
ffffffffc0202b66:	97ae                	add	a5,a5,a1
ffffffffc0202b68:	0af51e63          	bne	a0,a5,ffffffffc0202c24 <swap_init+0x3b8>
ffffffffc0202b6c:	6785                	lui	a5,0x1
ffffffffc0202b6e:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b70:	6795                	lui	a5,0x5
ffffffffc0202b72:	06a1                	addi	a3,a3,8
ffffffffc0202b74:	0821                	addi	a6,a6,8
ffffffffc0202b76:	fafc14e3          	bne	s8,a5,ffffffffc0202b1e <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202b7a:	00003517          	auipc	a0,0x3
ffffffffc0202b7e:	e7650513          	addi	a0,a0,-394 # ffffffffc02059f0 <default_pmm_manager+0x928>
ffffffffc0202b82:	d46fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    int ret = sm->check_swap();
ffffffffc0202b86:	0000f797          	auipc	a5,0xf
ffffffffc0202b8a:	8da78793          	addi	a5,a5,-1830 # ffffffffc0211460 <sm>
ffffffffc0202b8e:	639c                	ld	a5,0(a5)
ffffffffc0202b90:	7f9c                	ld	a5,56(a5)
ffffffffc0202b92:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202b94:	2a051c63          	bnez	a0,ffffffffc0202e4c <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202b98:	000a3503          	ld	a0,0(s4)
ffffffffc0202b9c:	4585                	li	a1,1
ffffffffc0202b9e:	0a21                	addi	s4,s4,8
ffffffffc0202ba0:	ba7fe0ef          	jal	ra,ffffffffc0201746 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ba4:	ff5a1ae3          	bne	s4,s5,ffffffffc0202b98 <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202ba8:	855e                	mv	a0,s7
ffffffffc0202baa:	23b000ef          	jal	ra,ffffffffc02035e4 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202bae:	77a2                	ld	a5,40(sp)
ffffffffc0202bb0:	0000f717          	auipc	a4,0xf
ffffffffc0202bb4:	8cf72c23          	sw	a5,-1832(a4) # ffffffffc0211488 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202bb8:	7782                	ld	a5,32(sp)
ffffffffc0202bba:	0000f717          	auipc	a4,0xf
ffffffffc0202bbe:	8af73f23          	sd	a5,-1858(a4) # ffffffffc0211478 <free_area>
ffffffffc0202bc2:	0000f797          	auipc	a5,0xf
ffffffffc0202bc6:	8b37bf23          	sd	s3,-1858(a5) # ffffffffc0211480 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bca:	00898a63          	beq	s3,s0,ffffffffc0202bde <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202bce:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202bd2:	0089b983          	ld	s3,8(s3)
ffffffffc0202bd6:	397d                	addiw	s2,s2,-1
ffffffffc0202bd8:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bda:	fe899ae3          	bne	s3,s0,ffffffffc0202bce <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202bde:	8626                	mv	a2,s1
ffffffffc0202be0:	85ca                	mv	a1,s2
ffffffffc0202be2:	00003517          	auipc	a0,0x3
ffffffffc0202be6:	e3e50513          	addi	a0,a0,-450 # ffffffffc0205a20 <default_pmm_manager+0x958>
ffffffffc0202bea:	cdefd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202bee:	00003517          	auipc	a0,0x3
ffffffffc0202bf2:	e5250513          	addi	a0,a0,-430 # ffffffffc0205a40 <default_pmm_manager+0x978>
ffffffffc0202bf6:	cd2fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
ffffffffc0202bfa:	b1c9                	j	ffffffffc02028bc <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202bfc:	4481                	li	s1,0
ffffffffc0202bfe:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c00:	4981                	li	s3,0
ffffffffc0202c02:	bb1d                	j	ffffffffc0202938 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202c04:	00002697          	auipc	a3,0x2
ffffffffc0202c08:	11c68693          	addi	a3,a3,284 # ffffffffc0204d20 <commands+0x8c8>
ffffffffc0202c0c:	00002617          	auipc	a2,0x2
ffffffffc0202c10:	12460613          	addi	a2,a2,292 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202c14:	0ba00593          	li	a1,186
ffffffffc0202c18:	00003517          	auipc	a0,0x3
ffffffffc0202c1c:	bc050513          	addi	a0,a0,-1088 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202c20:	f5efd0ef          	jal	ra,ffffffffc020037e <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c24:	00003697          	auipc	a3,0x3
ffffffffc0202c28:	da468693          	addi	a3,a3,-604 # ffffffffc02059c8 <default_pmm_manager+0x900>
ffffffffc0202c2c:	00002617          	auipc	a2,0x2
ffffffffc0202c30:	10460613          	addi	a2,a2,260 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202c34:	0fa00593          	li	a1,250
ffffffffc0202c38:	00003517          	auipc	a0,0x3
ffffffffc0202c3c:	ba050513          	addi	a0,a0,-1120 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202c40:	f3efd0ef          	jal	ra,ffffffffc020037e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202c44:	00002617          	auipc	a2,0x2
ffffffffc0202c48:	74460613          	addi	a2,a2,1860 # ffffffffc0205388 <default_pmm_manager+0x2c0>
ffffffffc0202c4c:	07000593          	li	a1,112
ffffffffc0202c50:	00002517          	auipc	a0,0x2
ffffffffc0202c54:	56050513          	addi	a0,a0,1376 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0202c58:	f26fd0ef          	jal	ra,ffffffffc020037e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202c5c:	00002617          	auipc	a2,0x2
ffffffffc0202c60:	53460613          	addi	a2,a2,1332 # ffffffffc0205190 <default_pmm_manager+0xc8>
ffffffffc0202c64:	06500593          	li	a1,101
ffffffffc0202c68:	00002517          	auipc	a0,0x2
ffffffffc0202c6c:	54850513          	addi	a0,a0,1352 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0202c70:	f0efd0ef          	jal	ra,ffffffffc020037e <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c74:	00003697          	auipc	a3,0x3
ffffffffc0202c78:	c8c68693          	addi	a3,a3,-884 # ffffffffc0205900 <default_pmm_manager+0x838>
ffffffffc0202c7c:	00002617          	auipc	a2,0x2
ffffffffc0202c80:	0b460613          	addi	a2,a2,180 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202c84:	0db00593          	li	a1,219
ffffffffc0202c88:	00003517          	auipc	a0,0x3
ffffffffc0202c8c:	b5050513          	addi	a0,a0,-1200 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202c90:	eeefd0ef          	jal	ra,ffffffffc020037e <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202c94:	00003697          	auipc	a3,0x3
ffffffffc0202c98:	c5468693          	addi	a3,a3,-940 # ffffffffc02058e8 <default_pmm_manager+0x820>
ffffffffc0202c9c:	00002617          	auipc	a2,0x2
ffffffffc0202ca0:	09460613          	addi	a2,a2,148 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202ca4:	0da00593          	li	a1,218
ffffffffc0202ca8:	00003517          	auipc	a0,0x3
ffffffffc0202cac:	b3050513          	addi	a0,a0,-1232 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202cb0:	ecefd0ef          	jal	ra,ffffffffc020037e <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202cb4:	00003697          	auipc	a3,0x3
ffffffffc0202cb8:	cfc68693          	addi	a3,a3,-772 # ffffffffc02059b0 <default_pmm_manager+0x8e8>
ffffffffc0202cbc:	00002617          	auipc	a2,0x2
ffffffffc0202cc0:	07460613          	addi	a2,a2,116 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202cc4:	0f900593          	li	a1,249
ffffffffc0202cc8:	00003517          	auipc	a0,0x3
ffffffffc0202ccc:	b1050513          	addi	a0,a0,-1264 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202cd0:	eaefd0ef          	jal	ra,ffffffffc020037e <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202cd4:	00003617          	auipc	a2,0x3
ffffffffc0202cd8:	ae460613          	addi	a2,a2,-1308 # ffffffffc02057b8 <default_pmm_manager+0x6f0>
ffffffffc0202cdc:	02700593          	li	a1,39
ffffffffc0202ce0:	00003517          	auipc	a0,0x3
ffffffffc0202ce4:	af850513          	addi	a0,a0,-1288 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202ce8:	e96fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==2);
ffffffffc0202cec:	00003697          	auipc	a3,0x3
ffffffffc0202cf0:	c9468693          	addi	a3,a3,-876 # ffffffffc0205980 <default_pmm_manager+0x8b8>
ffffffffc0202cf4:	00002617          	auipc	a2,0x2
ffffffffc0202cf8:	03c60613          	addi	a2,a2,60 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202cfc:	09500593          	li	a1,149
ffffffffc0202d00:	00003517          	auipc	a0,0x3
ffffffffc0202d04:	ad850513          	addi	a0,a0,-1320 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202d08:	e76fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==2);
ffffffffc0202d0c:	00003697          	auipc	a3,0x3
ffffffffc0202d10:	c7468693          	addi	a3,a3,-908 # ffffffffc0205980 <default_pmm_manager+0x8b8>
ffffffffc0202d14:	00002617          	auipc	a2,0x2
ffffffffc0202d18:	01c60613          	addi	a2,a2,28 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202d1c:	09700593          	li	a1,151
ffffffffc0202d20:	00003517          	auipc	a0,0x3
ffffffffc0202d24:	ab850513          	addi	a0,a0,-1352 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202d28:	e56fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==3);
ffffffffc0202d2c:	00003697          	auipc	a3,0x3
ffffffffc0202d30:	c6468693          	addi	a3,a3,-924 # ffffffffc0205990 <default_pmm_manager+0x8c8>
ffffffffc0202d34:	00002617          	auipc	a2,0x2
ffffffffc0202d38:	ffc60613          	addi	a2,a2,-4 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202d3c:	09900593          	li	a1,153
ffffffffc0202d40:	00003517          	auipc	a0,0x3
ffffffffc0202d44:	a9850513          	addi	a0,a0,-1384 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202d48:	e36fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==3);
ffffffffc0202d4c:	00003697          	auipc	a3,0x3
ffffffffc0202d50:	c4468693          	addi	a3,a3,-956 # ffffffffc0205990 <default_pmm_manager+0x8c8>
ffffffffc0202d54:	00002617          	auipc	a2,0x2
ffffffffc0202d58:	fdc60613          	addi	a2,a2,-36 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202d5c:	09b00593          	li	a1,155
ffffffffc0202d60:	00003517          	auipc	a0,0x3
ffffffffc0202d64:	a7850513          	addi	a0,a0,-1416 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202d68:	e16fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==1);
ffffffffc0202d6c:	00003697          	auipc	a3,0x3
ffffffffc0202d70:	c0468693          	addi	a3,a3,-1020 # ffffffffc0205970 <default_pmm_manager+0x8a8>
ffffffffc0202d74:	00002617          	auipc	a2,0x2
ffffffffc0202d78:	fbc60613          	addi	a2,a2,-68 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202d7c:	09100593          	li	a1,145
ffffffffc0202d80:	00003517          	auipc	a0,0x3
ffffffffc0202d84:	a5850513          	addi	a0,a0,-1448 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202d88:	df6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==1);
ffffffffc0202d8c:	00003697          	auipc	a3,0x3
ffffffffc0202d90:	be468693          	addi	a3,a3,-1052 # ffffffffc0205970 <default_pmm_manager+0x8a8>
ffffffffc0202d94:	00002617          	auipc	a2,0x2
ffffffffc0202d98:	f9c60613          	addi	a2,a2,-100 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202d9c:	09300593          	li	a1,147
ffffffffc0202da0:	00003517          	auipc	a0,0x3
ffffffffc0202da4:	a3850513          	addi	a0,a0,-1480 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202da8:	dd6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202dac:	00003697          	auipc	a3,0x3
ffffffffc0202db0:	b7468693          	addi	a3,a3,-1164 # ffffffffc0205920 <default_pmm_manager+0x858>
ffffffffc0202db4:	00002617          	auipc	a2,0x2
ffffffffc0202db8:	f7c60613          	addi	a2,a2,-132 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202dbc:	0e800593          	li	a1,232
ffffffffc0202dc0:	00003517          	auipc	a0,0x3
ffffffffc0202dc4:	a1850513          	addi	a0,a0,-1512 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202dc8:	db6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202dcc:	00003697          	auipc	a3,0x3
ffffffffc0202dd0:	adc68693          	addi	a3,a3,-1316 # ffffffffc02058a8 <default_pmm_manager+0x7e0>
ffffffffc0202dd4:	00002617          	auipc	a2,0x2
ffffffffc0202dd8:	f5c60613          	addi	a2,a2,-164 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202ddc:	0d500593          	li	a1,213
ffffffffc0202de0:	00003517          	auipc	a0,0x3
ffffffffc0202de4:	9f850513          	addi	a0,a0,-1544 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202de8:	d96fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==4);
ffffffffc0202dec:	00003697          	auipc	a3,0x3
ffffffffc0202df0:	bb468693          	addi	a3,a3,-1100 # ffffffffc02059a0 <default_pmm_manager+0x8d8>
ffffffffc0202df4:	00002617          	auipc	a2,0x2
ffffffffc0202df8:	f3c60613          	addi	a2,a2,-196 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202dfc:	09d00593          	li	a1,157
ffffffffc0202e00:	00003517          	auipc	a0,0x3
ffffffffc0202e04:	9d850513          	addi	a0,a0,-1576 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202e08:	d76fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==4);
ffffffffc0202e0c:	00003697          	auipc	a3,0x3
ffffffffc0202e10:	b9468693          	addi	a3,a3,-1132 # ffffffffc02059a0 <default_pmm_manager+0x8d8>
ffffffffc0202e14:	00002617          	auipc	a2,0x2
ffffffffc0202e18:	f1c60613          	addi	a2,a2,-228 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202e1c:	09f00593          	li	a1,159
ffffffffc0202e20:	00003517          	auipc	a0,0x3
ffffffffc0202e24:	9b850513          	addi	a0,a0,-1608 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202e28:	d56fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert( nr_free == 0);         
ffffffffc0202e2c:	00002697          	auipc	a3,0x2
ffffffffc0202e30:	0dc68693          	addi	a3,a3,220 # ffffffffc0204f08 <commands+0xab0>
ffffffffc0202e34:	00002617          	auipc	a2,0x2
ffffffffc0202e38:	efc60613          	addi	a2,a2,-260 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202e3c:	0f100593          	li	a1,241
ffffffffc0202e40:	00003517          	auipc	a0,0x3
ffffffffc0202e44:	99850513          	addi	a0,a0,-1640 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202e48:	d36fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(ret==0);
ffffffffc0202e4c:	00003697          	auipc	a3,0x3
ffffffffc0202e50:	bcc68693          	addi	a3,a3,-1076 # ffffffffc0205a18 <default_pmm_manager+0x950>
ffffffffc0202e54:	00002617          	auipc	a2,0x2
ffffffffc0202e58:	edc60613          	addi	a2,a2,-292 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202e5c:	10000593          	li	a1,256
ffffffffc0202e60:	00003517          	auipc	a0,0x3
ffffffffc0202e64:	97850513          	addi	a0,a0,-1672 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202e68:	d16fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(mm != NULL);
ffffffffc0202e6c:	00003697          	auipc	a3,0x3
ffffffffc0202e70:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0205828 <default_pmm_manager+0x760>
ffffffffc0202e74:	00002617          	auipc	a2,0x2
ffffffffc0202e78:	ebc60613          	addi	a2,a2,-324 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202e7c:	0c200593          	li	a1,194
ffffffffc0202e80:	00003517          	auipc	a0,0x3
ffffffffc0202e84:	95850513          	addi	a0,a0,-1704 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202e88:	cf6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202e8c:	00003697          	auipc	a3,0x3
ffffffffc0202e90:	9ac68693          	addi	a3,a3,-1620 # ffffffffc0205838 <default_pmm_manager+0x770>
ffffffffc0202e94:	00002617          	auipc	a2,0x2
ffffffffc0202e98:	e9c60613          	addi	a2,a2,-356 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202e9c:	0c500593          	li	a1,197
ffffffffc0202ea0:	00003517          	auipc	a0,0x3
ffffffffc0202ea4:	93850513          	addi	a0,a0,-1736 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202ea8:	cd6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202eac:	00003697          	auipc	a3,0x3
ffffffffc0202eb0:	9a468693          	addi	a3,a3,-1628 # ffffffffc0205850 <default_pmm_manager+0x788>
ffffffffc0202eb4:	00002617          	auipc	a2,0x2
ffffffffc0202eb8:	e7c60613          	addi	a2,a2,-388 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202ebc:	0ca00593          	li	a1,202
ffffffffc0202ec0:	00003517          	auipc	a0,0x3
ffffffffc0202ec4:	91850513          	addi	a0,a0,-1768 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202ec8:	cb6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(vma != NULL);
ffffffffc0202ecc:	00003697          	auipc	a3,0x3
ffffffffc0202ed0:	99468693          	addi	a3,a3,-1644 # ffffffffc0205860 <default_pmm_manager+0x798>
ffffffffc0202ed4:	00002617          	auipc	a2,0x2
ffffffffc0202ed8:	e5c60613          	addi	a2,a2,-420 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202edc:	0cd00593          	li	a1,205
ffffffffc0202ee0:	00003517          	auipc	a0,0x3
ffffffffc0202ee4:	8f850513          	addi	a0,a0,-1800 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202ee8:	c96fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(total == nr_free_pages());
ffffffffc0202eec:	00002697          	auipc	a3,0x2
ffffffffc0202ef0:	e7468693          	addi	a3,a3,-396 # ffffffffc0204d60 <commands+0x908>
ffffffffc0202ef4:	00002617          	auipc	a2,0x2
ffffffffc0202ef8:	e3c60613          	addi	a2,a2,-452 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0202efc:	0bd00593          	li	a1,189
ffffffffc0202f00:	00003517          	auipc	a0,0x3
ffffffffc0202f04:	8d850513          	addi	a0,a0,-1832 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202f08:	c76fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0202f0c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202f0c:	0000e797          	auipc	a5,0xe
ffffffffc0202f10:	55478793          	addi	a5,a5,1364 # ffffffffc0211460 <sm>
ffffffffc0202f14:	639c                	ld	a5,0(a5)
ffffffffc0202f16:	0107b303          	ld	t1,16(a5)
ffffffffc0202f1a:	8302                	jr	t1

ffffffffc0202f1c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202f1c:	0000e797          	auipc	a5,0xe
ffffffffc0202f20:	54478793          	addi	a5,a5,1348 # ffffffffc0211460 <sm>
ffffffffc0202f24:	639c                	ld	a5,0(a5)
ffffffffc0202f26:	0207b303          	ld	t1,32(a5)
ffffffffc0202f2a:	8302                	jr	t1

ffffffffc0202f2c <swap_out>:
{
ffffffffc0202f2c:	711d                	addi	sp,sp,-96
ffffffffc0202f2e:	ec86                	sd	ra,88(sp)
ffffffffc0202f30:	e8a2                	sd	s0,80(sp)
ffffffffc0202f32:	e4a6                	sd	s1,72(sp)
ffffffffc0202f34:	e0ca                	sd	s2,64(sp)
ffffffffc0202f36:	fc4e                	sd	s3,56(sp)
ffffffffc0202f38:	f852                	sd	s4,48(sp)
ffffffffc0202f3a:	f456                	sd	s5,40(sp)
ffffffffc0202f3c:	f05a                	sd	s6,32(sp)
ffffffffc0202f3e:	ec5e                	sd	s7,24(sp)
ffffffffc0202f40:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202f42:	cde9                	beqz	a1,ffffffffc020301c <swap_out+0xf0>
ffffffffc0202f44:	8ab2                	mv	s5,a2
ffffffffc0202f46:	892a                	mv	s2,a0
ffffffffc0202f48:	8a2e                	mv	s4,a1
ffffffffc0202f4a:	4401                	li	s0,0
ffffffffc0202f4c:	0000e997          	auipc	s3,0xe
ffffffffc0202f50:	51498993          	addi	s3,s3,1300 # ffffffffc0211460 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f54:	00003b17          	auipc	s6,0x3
ffffffffc0202f58:	b6cb0b13          	addi	s6,s6,-1172 # ffffffffc0205ac0 <default_pmm_manager+0x9f8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f5c:	00003b97          	auipc	s7,0x3
ffffffffc0202f60:	b4cb8b93          	addi	s7,s7,-1204 # ffffffffc0205aa8 <default_pmm_manager+0x9e0>
ffffffffc0202f64:	a825                	j	ffffffffc0202f9c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f66:	67a2                	ld	a5,8(sp)
ffffffffc0202f68:	8626                	mv	a2,s1
ffffffffc0202f6a:	85a2                	mv	a1,s0
ffffffffc0202f6c:	63b4                	ld	a3,64(a5)
ffffffffc0202f6e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202f70:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f72:	82b1                	srli	a3,a3,0xc
ffffffffc0202f74:	0685                	addi	a3,a3,1
ffffffffc0202f76:	952fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f7a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202f7c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f7e:	613c                	ld	a5,64(a0)
ffffffffc0202f80:	83b1                	srli	a5,a5,0xc
ffffffffc0202f82:	0785                	addi	a5,a5,1
ffffffffc0202f84:	07a2                	slli	a5,a5,0x8
ffffffffc0202f86:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202f8a:	fbcfe0ef          	jal	ra,ffffffffc0201746 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202f8e:	01893503          	ld	a0,24(s2)
ffffffffc0202f92:	85a6                	mv	a1,s1
ffffffffc0202f94:	ebeff0ef          	jal	ra,ffffffffc0202652 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202f98:	048a0d63          	beq	s4,s0,ffffffffc0202ff2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202f9c:	0009b783          	ld	a5,0(s3)
ffffffffc0202fa0:	8656                	mv	a2,s5
ffffffffc0202fa2:	002c                	addi	a1,sp,8
ffffffffc0202fa4:	7b9c                	ld	a5,48(a5)
ffffffffc0202fa6:	854a                	mv	a0,s2
ffffffffc0202fa8:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202faa:	e12d                	bnez	a0,ffffffffc020300c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202fac:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fae:	01893503          	ld	a0,24(s2)
ffffffffc0202fb2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202fb4:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fb6:	85a6                	mv	a1,s1
ffffffffc0202fb8:	815fe0ef          	jal	ra,ffffffffc02017cc <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fbc:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fbe:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fc0:	8b85                	andi	a5,a5,1
ffffffffc0202fc2:	cfb9                	beqz	a5,ffffffffc0203020 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202fc4:	65a2                	ld	a1,8(sp)
ffffffffc0202fc6:	61bc                	ld	a5,64(a1)
ffffffffc0202fc8:	83b1                	srli	a5,a5,0xc
ffffffffc0202fca:	00178513          	addi	a0,a5,1
ffffffffc0202fce:	0522                	slli	a0,a0,0x8
ffffffffc0202fd0:	53b000ef          	jal	ra,ffffffffc0203d0a <swapfs_write>
ffffffffc0202fd4:	d949                	beqz	a0,ffffffffc0202f66 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202fd6:	855e                	mv	a0,s7
ffffffffc0202fd8:	8f0fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fdc:	0009b783          	ld	a5,0(s3)
ffffffffc0202fe0:	6622                	ld	a2,8(sp)
ffffffffc0202fe2:	4681                	li	a3,0
ffffffffc0202fe4:	739c                	ld	a5,32(a5)
ffffffffc0202fe6:	85a6                	mv	a1,s1
ffffffffc0202fe8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202fea:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fec:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202fee:	fa8a17e3          	bne	s4,s0,ffffffffc0202f9c <swap_out+0x70>
}
ffffffffc0202ff2:	8522                	mv	a0,s0
ffffffffc0202ff4:	60e6                	ld	ra,88(sp)
ffffffffc0202ff6:	6446                	ld	s0,80(sp)
ffffffffc0202ff8:	64a6                	ld	s1,72(sp)
ffffffffc0202ffa:	6906                	ld	s2,64(sp)
ffffffffc0202ffc:	79e2                	ld	s3,56(sp)
ffffffffc0202ffe:	7a42                	ld	s4,48(sp)
ffffffffc0203000:	7aa2                	ld	s5,40(sp)
ffffffffc0203002:	7b02                	ld	s6,32(sp)
ffffffffc0203004:	6be2                	ld	s7,24(sp)
ffffffffc0203006:	6c42                	ld	s8,16(sp)
ffffffffc0203008:	6125                	addi	sp,sp,96
ffffffffc020300a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020300c:	85a2                	mv	a1,s0
ffffffffc020300e:	00003517          	auipc	a0,0x3
ffffffffc0203012:	a5250513          	addi	a0,a0,-1454 # ffffffffc0205a60 <default_pmm_manager+0x998>
ffffffffc0203016:	8b2fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
                  break;
ffffffffc020301a:	bfe1                	j	ffffffffc0202ff2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020301c:	4401                	li	s0,0
ffffffffc020301e:	bfd1                	j	ffffffffc0202ff2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203020:	00003697          	auipc	a3,0x3
ffffffffc0203024:	a7068693          	addi	a3,a3,-1424 # ffffffffc0205a90 <default_pmm_manager+0x9c8>
ffffffffc0203028:	00002617          	auipc	a2,0x2
ffffffffc020302c:	d0860613          	addi	a2,a2,-760 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203030:	06600593          	li	a1,102
ffffffffc0203034:	00002517          	auipc	a0,0x2
ffffffffc0203038:	7a450513          	addi	a0,a0,1956 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc020303c:	b42fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0203040 <swap_in>:
{
ffffffffc0203040:	7179                	addi	sp,sp,-48
ffffffffc0203042:	e84a                	sd	s2,16(sp)
ffffffffc0203044:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203046:	4505                	li	a0,1
{
ffffffffc0203048:	ec26                	sd	s1,24(sp)
ffffffffc020304a:	e44e                	sd	s3,8(sp)
ffffffffc020304c:	f406                	sd	ra,40(sp)
ffffffffc020304e:	f022                	sd	s0,32(sp)
ffffffffc0203050:	84ae                	mv	s1,a1
ffffffffc0203052:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203054:	e6afe0ef          	jal	ra,ffffffffc02016be <alloc_pages>
     assert(result!=NULL);
ffffffffc0203058:	c129                	beqz	a0,ffffffffc020309a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020305a:	842a                	mv	s0,a0
ffffffffc020305c:	01893503          	ld	a0,24(s2)
ffffffffc0203060:	4601                	li	a2,0
ffffffffc0203062:	85a6                	mv	a1,s1
ffffffffc0203064:	f68fe0ef          	jal	ra,ffffffffc02017cc <get_pte>
ffffffffc0203068:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020306a:	6108                	ld	a0,0(a0)
ffffffffc020306c:	85a2                	mv	a1,s0
ffffffffc020306e:	3f7000ef          	jal	ra,ffffffffc0203c64 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203072:	00093583          	ld	a1,0(s2)
ffffffffc0203076:	8626                	mv	a2,s1
ffffffffc0203078:	00002517          	auipc	a0,0x2
ffffffffc020307c:	70050513          	addi	a0,a0,1792 # ffffffffc0205778 <default_pmm_manager+0x6b0>
ffffffffc0203080:	81a1                	srli	a1,a1,0x8
ffffffffc0203082:	846fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
}
ffffffffc0203086:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203088:	0089b023          	sd	s0,0(s3)
}
ffffffffc020308c:	7402                	ld	s0,32(sp)
ffffffffc020308e:	64e2                	ld	s1,24(sp)
ffffffffc0203090:	6942                	ld	s2,16(sp)
ffffffffc0203092:	69a2                	ld	s3,8(sp)
ffffffffc0203094:	4501                	li	a0,0
ffffffffc0203096:	6145                	addi	sp,sp,48
ffffffffc0203098:	8082                	ret
     assert(result!=NULL);
ffffffffc020309a:	00002697          	auipc	a3,0x2
ffffffffc020309e:	6ce68693          	addi	a3,a3,1742 # ffffffffc0205768 <default_pmm_manager+0x6a0>
ffffffffc02030a2:	00002617          	auipc	a2,0x2
ffffffffc02030a6:	c8e60613          	addi	a2,a2,-882 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02030aa:	07c00593          	li	a1,124
ffffffffc02030ae:	00002517          	auipc	a0,0x2
ffffffffc02030b2:	72a50513          	addi	a0,a0,1834 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc02030b6:	ac8fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02030ba <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc02030ba:	4501                	li	a0,0
ffffffffc02030bc:	8082                	ret

ffffffffc02030be <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02030be:	4501                	li	a0,0
ffffffffc02030c0:	8082                	ret

ffffffffc02030c2 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02030c2:	4501                	li	a0,0
ffffffffc02030c4:	8082                	ret

ffffffffc02030c6 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc02030c6:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02030c8:	678d                	lui	a5,0x3
ffffffffc02030ca:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc02030cc:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02030ce:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02030d2:	0000e797          	auipc	a5,0xe
ffffffffc02030d6:	39a78793          	addi	a5,a5,922 # ffffffffc021146c <pgfault_num>
ffffffffc02030da:	4398                	lw	a4,0(a5)
ffffffffc02030dc:	4691                	li	a3,4
ffffffffc02030de:	2701                	sext.w	a4,a4
ffffffffc02030e0:	08d71f63          	bne	a4,a3,ffffffffc020317e <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02030e4:	6685                	lui	a3,0x1
ffffffffc02030e6:	4629                	li	a2,10
ffffffffc02030e8:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02030ec:	4394                	lw	a3,0(a5)
ffffffffc02030ee:	2681                	sext.w	a3,a3
ffffffffc02030f0:	20e69763          	bne	a3,a4,ffffffffc02032fe <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02030f4:	6711                	lui	a4,0x4
ffffffffc02030f6:	4635                	li	a2,13
ffffffffc02030f8:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02030fc:	4398                	lw	a4,0(a5)
ffffffffc02030fe:	2701                	sext.w	a4,a4
ffffffffc0203100:	1cd71f63          	bne	a4,a3,ffffffffc02032de <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203104:	6689                	lui	a3,0x2
ffffffffc0203106:	462d                	li	a2,11
ffffffffc0203108:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020310c:	4394                	lw	a3,0(a5)
ffffffffc020310e:	2681                	sext.w	a3,a3
ffffffffc0203110:	1ae69763          	bne	a3,a4,ffffffffc02032be <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203114:	6715                	lui	a4,0x5
ffffffffc0203116:	46b9                	li	a3,14
ffffffffc0203118:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020311c:	4398                	lw	a4,0(a5)
ffffffffc020311e:	4695                	li	a3,5
ffffffffc0203120:	2701                	sext.w	a4,a4
ffffffffc0203122:	16d71e63          	bne	a4,a3,ffffffffc020329e <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc0203126:	4394                	lw	a3,0(a5)
ffffffffc0203128:	2681                	sext.w	a3,a3
ffffffffc020312a:	14e69a63          	bne	a3,a4,ffffffffc020327e <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc020312e:	4398                	lw	a4,0(a5)
ffffffffc0203130:	2701                	sext.w	a4,a4
ffffffffc0203132:	12d71663          	bne	a4,a3,ffffffffc020325e <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc0203136:	4394                	lw	a3,0(a5)
ffffffffc0203138:	2681                	sext.w	a3,a3
ffffffffc020313a:	10e69263          	bne	a3,a4,ffffffffc020323e <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc020313e:	4398                	lw	a4,0(a5)
ffffffffc0203140:	2701                	sext.w	a4,a4
ffffffffc0203142:	0cd71e63          	bne	a4,a3,ffffffffc020321e <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc0203146:	4394                	lw	a3,0(a5)
ffffffffc0203148:	2681                	sext.w	a3,a3
ffffffffc020314a:	0ae69a63          	bne	a3,a4,ffffffffc02031fe <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020314e:	6715                	lui	a4,0x5
ffffffffc0203150:	46b9                	li	a3,14
ffffffffc0203152:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203156:	4398                	lw	a4,0(a5)
ffffffffc0203158:	4695                	li	a3,5
ffffffffc020315a:	2701                	sext.w	a4,a4
ffffffffc020315c:	08d71163          	bne	a4,a3,ffffffffc02031de <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203160:	6705                	lui	a4,0x1
ffffffffc0203162:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203166:	4729                	li	a4,10
ffffffffc0203168:	04e69b63          	bne	a3,a4,ffffffffc02031be <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc020316c:	439c                	lw	a5,0(a5)
ffffffffc020316e:	4719                	li	a4,6
ffffffffc0203170:	2781                	sext.w	a5,a5
ffffffffc0203172:	02e79663          	bne	a5,a4,ffffffffc020319e <_clock_check_swap+0xd8>
}
ffffffffc0203176:	60a2                	ld	ra,8(sp)
ffffffffc0203178:	4501                	li	a0,0
ffffffffc020317a:	0141                	addi	sp,sp,16
ffffffffc020317c:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020317e:	00003697          	auipc	a3,0x3
ffffffffc0203182:	82268693          	addi	a3,a3,-2014 # ffffffffc02059a0 <default_pmm_manager+0x8d8>
ffffffffc0203186:	00002617          	auipc	a2,0x2
ffffffffc020318a:	baa60613          	addi	a2,a2,-1110 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020318e:	09300593          	li	a1,147
ffffffffc0203192:	00003517          	auipc	a0,0x3
ffffffffc0203196:	96e50513          	addi	a0,a0,-1682 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020319a:	9e4fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==6);
ffffffffc020319e:	00003697          	auipc	a3,0x3
ffffffffc02031a2:	9b268693          	addi	a3,a3,-1614 # ffffffffc0205b50 <default_pmm_manager+0xa88>
ffffffffc02031a6:	00002617          	auipc	a2,0x2
ffffffffc02031aa:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02031ae:	0aa00593          	li	a1,170
ffffffffc02031b2:	00003517          	auipc	a0,0x3
ffffffffc02031b6:	94e50513          	addi	a0,a0,-1714 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc02031ba:	9c4fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02031be:	00003697          	auipc	a3,0x3
ffffffffc02031c2:	96a68693          	addi	a3,a3,-1686 # ffffffffc0205b28 <default_pmm_manager+0xa60>
ffffffffc02031c6:	00002617          	auipc	a2,0x2
ffffffffc02031ca:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02031ce:	0a800593          	li	a1,168
ffffffffc02031d2:	00003517          	auipc	a0,0x3
ffffffffc02031d6:	92e50513          	addi	a0,a0,-1746 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc02031da:	9a4fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc02031de:	00003697          	auipc	a3,0x3
ffffffffc02031e2:	93a68693          	addi	a3,a3,-1734 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc02031e6:	00002617          	auipc	a2,0x2
ffffffffc02031ea:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02031ee:	0a700593          	li	a1,167
ffffffffc02031f2:	00003517          	auipc	a0,0x3
ffffffffc02031f6:	90e50513          	addi	a0,a0,-1778 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc02031fa:	984fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc02031fe:	00003697          	auipc	a3,0x3
ffffffffc0203202:	91a68693          	addi	a3,a3,-1766 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc0203206:	00002617          	auipc	a2,0x2
ffffffffc020320a:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020320e:	0a500593          	li	a1,165
ffffffffc0203212:	00003517          	auipc	a0,0x3
ffffffffc0203216:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020321a:	964fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc020321e:	00003697          	auipc	a3,0x3
ffffffffc0203222:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc0203226:	00002617          	auipc	a2,0x2
ffffffffc020322a:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020322e:	0a300593          	li	a1,163
ffffffffc0203232:	00003517          	auipc	a0,0x3
ffffffffc0203236:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020323a:	944fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc020323e:	00003697          	auipc	a3,0x3
ffffffffc0203242:	8da68693          	addi	a3,a3,-1830 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc0203246:	00002617          	auipc	a2,0x2
ffffffffc020324a:	aea60613          	addi	a2,a2,-1302 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020324e:	0a100593          	li	a1,161
ffffffffc0203252:	00003517          	auipc	a0,0x3
ffffffffc0203256:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020325a:	924fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc020325e:	00003697          	auipc	a3,0x3
ffffffffc0203262:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc0203266:	00002617          	auipc	a2,0x2
ffffffffc020326a:	aca60613          	addi	a2,a2,-1334 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020326e:	09f00593          	li	a1,159
ffffffffc0203272:	00003517          	auipc	a0,0x3
ffffffffc0203276:	88e50513          	addi	a0,a0,-1906 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020327a:	904fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc020327e:	00003697          	auipc	a3,0x3
ffffffffc0203282:	89a68693          	addi	a3,a3,-1894 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc0203286:	00002617          	auipc	a2,0x2
ffffffffc020328a:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020328e:	09d00593          	li	a1,157
ffffffffc0203292:	00003517          	auipc	a0,0x3
ffffffffc0203296:	86e50513          	addi	a0,a0,-1938 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020329a:	8e4fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc020329e:	00003697          	auipc	a3,0x3
ffffffffc02032a2:	87a68693          	addi	a3,a3,-1926 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc02032a6:	00002617          	auipc	a2,0x2
ffffffffc02032aa:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02032ae:	09b00593          	li	a1,155
ffffffffc02032b2:	00003517          	auipc	a0,0x3
ffffffffc02032b6:	84e50513          	addi	a0,a0,-1970 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc02032ba:	8c4fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==4);
ffffffffc02032be:	00002697          	auipc	a3,0x2
ffffffffc02032c2:	6e268693          	addi	a3,a3,1762 # ffffffffc02059a0 <default_pmm_manager+0x8d8>
ffffffffc02032c6:	00002617          	auipc	a2,0x2
ffffffffc02032ca:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02032ce:	09900593          	li	a1,153
ffffffffc02032d2:	00003517          	auipc	a0,0x3
ffffffffc02032d6:	82e50513          	addi	a0,a0,-2002 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc02032da:	8a4fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==4);
ffffffffc02032de:	00002697          	auipc	a3,0x2
ffffffffc02032e2:	6c268693          	addi	a3,a3,1730 # ffffffffc02059a0 <default_pmm_manager+0x8d8>
ffffffffc02032e6:	00002617          	auipc	a2,0x2
ffffffffc02032ea:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02032ee:	09700593          	li	a1,151
ffffffffc02032f2:	00003517          	auipc	a0,0x3
ffffffffc02032f6:	80e50513          	addi	a0,a0,-2034 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc02032fa:	884fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==4);
ffffffffc02032fe:	00002697          	auipc	a3,0x2
ffffffffc0203302:	6a268693          	addi	a3,a3,1698 # ffffffffc02059a0 <default_pmm_manager+0x8d8>
ffffffffc0203306:	00002617          	auipc	a2,0x2
ffffffffc020330a:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020330e:	09500593          	li	a1,149
ffffffffc0203312:	00002517          	auipc	a0,0x2
ffffffffc0203316:	7ee50513          	addi	a0,a0,2030 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020331a:	864fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc020331e <_clock_init_mm>:
{     
ffffffffc020331e:	1141                	addi	sp,sp,-16
ffffffffc0203320:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0203322:	0000e797          	auipc	a5,0xe
ffffffffc0203326:	34678793          	addi	a5,a5,838 # ffffffffc0211668 <pra_list_head>
     mm->sm_priv = &pra_list_head;
ffffffffc020332a:	f51c                	sd	a5,40(a0)
     cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
ffffffffc020332c:	85be                	mv	a1,a5
ffffffffc020332e:	00003517          	auipc	a0,0x3
ffffffffc0203332:	83250513          	addi	a0,a0,-1998 # ffffffffc0205b60 <default_pmm_manager+0xa98>
ffffffffc0203336:	e79c                	sd	a5,8(a5)
ffffffffc0203338:	e39c                	sd	a5,0(a5)
     curr_ptr=pra_list_head.prev;
ffffffffc020333a:	0000e717          	auipc	a4,0xe
ffffffffc020333e:	32f73f23          	sd	a5,830(a4) # ffffffffc0211678 <curr_ptr>
     cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
ffffffffc0203342:	d87fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
}
ffffffffc0203346:	60a2                	ld	ra,8(sp)
ffffffffc0203348:	4501                	li	a0,0
ffffffffc020334a:	0141                	addi	sp,sp,16
ffffffffc020334c:	8082                	ret

ffffffffc020334e <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020334e:	03060793          	addi	a5,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203352:	c38d                	beqz	a5,ffffffffc0203374 <_clock_map_swappable+0x26>
ffffffffc0203354:	0000e717          	auipc	a4,0xe
ffffffffc0203358:	32470713          	addi	a4,a4,804 # ffffffffc0211678 <curr_ptr>
ffffffffc020335c:	6318                	ld	a4,0(a4)
ffffffffc020335e:	cb19                	beqz	a4,ffffffffc0203374 <_clock_map_swappable+0x26>
    list_add_before((list_entry_t*) mm->sm_priv,entry);
ffffffffc0203360:	7518                	ld	a4,40(a0)
}
ffffffffc0203362:	4501                	li	a0,0
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203364:	6314                	ld	a3,0(a4)
    prev->next = next->prev = elm;
ffffffffc0203366:	e31c                	sd	a5,0(a4)
ffffffffc0203368:	e69c                	sd	a5,8(a3)
    page->visited = 1;
ffffffffc020336a:	4785                	li	a5,1
    elm->next = next;
ffffffffc020336c:	fe18                	sd	a4,56(a2)
    elm->prev = prev;
ffffffffc020336e:	fa14                	sd	a3,48(a2)
ffffffffc0203370:	ea1c                	sd	a5,16(a2)
}
ffffffffc0203372:	8082                	ret
{
ffffffffc0203374:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203376:	00003697          	auipc	a3,0x3
ffffffffc020337a:	81268693          	addi	a3,a3,-2030 # ffffffffc0205b88 <default_pmm_manager+0xac0>
ffffffffc020337e:	00002617          	auipc	a2,0x2
ffffffffc0203382:	9b260613          	addi	a2,a2,-1614 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203386:	03700593          	li	a1,55
ffffffffc020338a:	00002517          	auipc	a0,0x2
ffffffffc020338e:	77650513          	addi	a0,a0,1910 # ffffffffc0205b00 <default_pmm_manager+0xa38>
{
ffffffffc0203392:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203394:	febfc0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0203398 <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203398:	751c                	ld	a5,40(a0)
{
ffffffffc020339a:	1141                	addi	sp,sp,-16
ffffffffc020339c:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020339e:	cfb5                	beqz	a5,ffffffffc020341a <_clock_swap_out_victim+0x82>
     assert(in_tick==0);
ffffffffc02033a0:	ee29                	bnez	a2,ffffffffc02033fa <_clock_swap_out_victim+0x62>
        if (list_empty(head)) {
ffffffffc02033a2:	6798                	ld	a4,8(a5)
ffffffffc02033a4:	04e78163          	beq	a5,a4,ffffffffc02033e6 <_clock_swap_out_victim+0x4e>
    return listelm->next;
ffffffffc02033a8:	0000e797          	auipc	a5,0xe
ffffffffc02033ac:	2d078793          	addi	a5,a5,720 # ffffffffc0211678 <curr_ptr>
ffffffffc02033b0:	639c                	ld	a5,0(a5)
ffffffffc02033b2:	679c                	ld	a5,8(a5)
            if (page->visited == 0) {
ffffffffc02033b4:	fe07b703          	ld	a4,-32(a5)
            curr_ptr=list_next(curr_ptr);
ffffffffc02033b8:	0000e697          	auipc	a3,0xe
ffffffffc02033bc:	2cf6b023          	sd	a5,704(a3) # ffffffffc0211678 <curr_ptr>
            if (page->visited == 0) {
ffffffffc02033c0:	cb19                	beqz	a4,ffffffffc02033d6 <_clock_swap_out_victim+0x3e>
                page->visited = 0;
ffffffffc02033c2:	fe07b023          	sd	zero,-32(a5)
ffffffffc02033c6:	679c                	ld	a5,8(a5)
            if (page->visited == 0) {
ffffffffc02033c8:	fe07b703          	ld	a4,-32(a5)
ffffffffc02033cc:	fb7d                	bnez	a4,ffffffffc02033c2 <_clock_swap_out_victim+0x2a>
ffffffffc02033ce:	0000e717          	auipc	a4,0xe
ffffffffc02033d2:	2af73523          	sd	a5,682(a4) # ffffffffc0211678 <curr_ptr>
    __list_del(listelm->prev, listelm->next);
ffffffffc02033d6:	6398                	ld	a4,0(a5)
ffffffffc02033d8:	679c                	ld	a5,8(a5)
}
ffffffffc02033da:	60a2                	ld	ra,8(sp)
    return 0;
ffffffffc02033dc:	4501                	li	a0,0
    prev->next = next;
ffffffffc02033de:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02033e0:	e398                	sd	a4,0(a5)
}
ffffffffc02033e2:	0141                	addi	sp,sp,16
ffffffffc02033e4:	8082                	ret
            cprintf("list_empty in clock_swap_out_victim\n");
ffffffffc02033e6:	00002517          	auipc	a0,0x2
ffffffffc02033ea:	7ea50513          	addi	a0,a0,2026 # ffffffffc0205bd0 <default_pmm_manager+0xb08>
ffffffffc02033ee:	cdbfc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
}
ffffffffc02033f2:	60a2                	ld	ra,8(sp)
            return -1;
ffffffffc02033f4:	557d                	li	a0,-1
}
ffffffffc02033f6:	0141                	addi	sp,sp,16
ffffffffc02033f8:	8082                	ret
     assert(in_tick==0);
ffffffffc02033fa:	00002697          	auipc	a3,0x2
ffffffffc02033fe:	7c668693          	addi	a3,a3,1990 # ffffffffc0205bc0 <default_pmm_manager+0xaf8>
ffffffffc0203402:	00002617          	auipc	a2,0x2
ffffffffc0203406:	92e60613          	addi	a2,a2,-1746 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020340a:	04b00593          	li	a1,75
ffffffffc020340e:	00002517          	auipc	a0,0x2
ffffffffc0203412:	6f250513          	addi	a0,a0,1778 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc0203416:	f69fc0ef          	jal	ra,ffffffffc020037e <__panic>
         assert(head != NULL);
ffffffffc020341a:	00002697          	auipc	a3,0x2
ffffffffc020341e:	79668693          	addi	a3,a3,1942 # ffffffffc0205bb0 <default_pmm_manager+0xae8>
ffffffffc0203422:	00002617          	auipc	a2,0x2
ffffffffc0203426:	90e60613          	addi	a2,a2,-1778 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020342a:	04a00593          	li	a1,74
ffffffffc020342e:	00002517          	auipc	a0,0x2
ffffffffc0203432:	6d250513          	addi	a0,a0,1746 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc0203436:	f49fc0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc020343a <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020343a:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020343c:	00002697          	auipc	a3,0x2
ffffffffc0203440:	7d468693          	addi	a3,a3,2004 # ffffffffc0205c10 <default_pmm_manager+0xb48>
ffffffffc0203444:	00002617          	auipc	a2,0x2
ffffffffc0203448:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020344c:	07d00593          	li	a1,125
ffffffffc0203450:	00002517          	auipc	a0,0x2
ffffffffc0203454:	7e050513          	addi	a0,a0,2016 # ffffffffc0205c30 <default_pmm_manager+0xb68>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203458:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020345a:	f25fc0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc020345e <mm_create>:
mm_create(void) {
ffffffffc020345e:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203460:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203464:	e022                	sd	s0,0(sp)
ffffffffc0203466:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203468:	a82ff0ef          	jal	ra,ffffffffc02026ea <kmalloc>
ffffffffc020346c:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020346e:	c115                	beqz	a0,ffffffffc0203492 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203470:	0000e797          	auipc	a5,0xe
ffffffffc0203474:	ff878793          	addi	a5,a5,-8 # ffffffffc0211468 <swap_init_ok>
ffffffffc0203478:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc020347a:	e408                	sd	a0,8(s0)
ffffffffc020347c:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020347e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203482:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203486:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020348a:	2781                	sext.w	a5,a5
ffffffffc020348c:	eb81                	bnez	a5,ffffffffc020349c <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc020348e:	02053423          	sd	zero,40(a0)
}
ffffffffc0203492:	8522                	mv	a0,s0
ffffffffc0203494:	60a2                	ld	ra,8(sp)
ffffffffc0203496:	6402                	ld	s0,0(sp)
ffffffffc0203498:	0141                	addi	sp,sp,16
ffffffffc020349a:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020349c:	a71ff0ef          	jal	ra,ffffffffc0202f0c <swap_init_mm>
}
ffffffffc02034a0:	8522                	mv	a0,s0
ffffffffc02034a2:	60a2                	ld	ra,8(sp)
ffffffffc02034a4:	6402                	ld	s0,0(sp)
ffffffffc02034a6:	0141                	addi	sp,sp,16
ffffffffc02034a8:	8082                	ret

ffffffffc02034aa <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02034aa:	1101                	addi	sp,sp,-32
ffffffffc02034ac:	e04a                	sd	s2,0(sp)
ffffffffc02034ae:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034b0:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02034b4:	e822                	sd	s0,16(sp)
ffffffffc02034b6:	e426                	sd	s1,8(sp)
ffffffffc02034b8:	ec06                	sd	ra,24(sp)
ffffffffc02034ba:	84ae                	mv	s1,a1
ffffffffc02034bc:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034be:	a2cff0ef          	jal	ra,ffffffffc02026ea <kmalloc>
    if (vma != NULL) {
ffffffffc02034c2:	c509                	beqz	a0,ffffffffc02034cc <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02034c4:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02034c8:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02034ca:	ed00                	sd	s0,24(a0)
}
ffffffffc02034cc:	60e2                	ld	ra,24(sp)
ffffffffc02034ce:	6442                	ld	s0,16(sp)
ffffffffc02034d0:	64a2                	ld	s1,8(sp)
ffffffffc02034d2:	6902                	ld	s2,0(sp)
ffffffffc02034d4:	6105                	addi	sp,sp,32
ffffffffc02034d6:	8082                	ret

ffffffffc02034d8 <find_vma>:
    if (mm != NULL) {
ffffffffc02034d8:	c51d                	beqz	a0,ffffffffc0203506 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02034da:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02034dc:	c781                	beqz	a5,ffffffffc02034e4 <find_vma+0xc>
ffffffffc02034de:	6798                	ld	a4,8(a5)
ffffffffc02034e0:	02e5f663          	bleu	a4,a1,ffffffffc020350c <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02034e4:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc02034e6:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02034e8:	00f50f63          	beq	a0,a5,ffffffffc0203506 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02034ec:	fe87b703          	ld	a4,-24(a5)
ffffffffc02034f0:	fee5ebe3          	bltu	a1,a4,ffffffffc02034e6 <find_vma+0xe>
ffffffffc02034f4:	ff07b703          	ld	a4,-16(a5)
ffffffffc02034f8:	fee5f7e3          	bleu	a4,a1,ffffffffc02034e6 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02034fc:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02034fe:	c781                	beqz	a5,ffffffffc0203506 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0203500:	e91c                	sd	a5,16(a0)
}
ffffffffc0203502:	853e                	mv	a0,a5
ffffffffc0203504:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0203506:	4781                	li	a5,0
}
ffffffffc0203508:	853e                	mv	a0,a5
ffffffffc020350a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020350c:	6b98                	ld	a4,16(a5)
ffffffffc020350e:	fce5fbe3          	bleu	a4,a1,ffffffffc02034e4 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0203512:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0203514:	b7fd                	j	ffffffffc0203502 <find_vma+0x2a>

ffffffffc0203516 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203516:	6590                	ld	a2,8(a1)
ffffffffc0203518:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020351c:	1141                	addi	sp,sp,-16
ffffffffc020351e:	e406                	sd	ra,8(sp)
ffffffffc0203520:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203522:	01066863          	bltu	a2,a6,ffffffffc0203532 <insert_vma_struct+0x1c>
ffffffffc0203526:	a8b9                	j	ffffffffc0203584 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203528:	fe87b683          	ld	a3,-24(a5)
ffffffffc020352c:	04d66763          	bltu	a2,a3,ffffffffc020357a <insert_vma_struct+0x64>
ffffffffc0203530:	873e                	mv	a4,a5
ffffffffc0203532:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0203534:	fef51ae3          	bne	a0,a5,ffffffffc0203528 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203538:	02a70463          	beq	a4,a0,ffffffffc0203560 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020353c:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203540:	fe873883          	ld	a7,-24(a4)
ffffffffc0203544:	08d8f063          	bleu	a3,a7,ffffffffc02035c4 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203548:	04d66e63          	bltu	a2,a3,ffffffffc02035a4 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc020354c:	00f50a63          	beq	a0,a5,ffffffffc0203560 <insert_vma_struct+0x4a>
ffffffffc0203550:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203554:	0506e863          	bltu	a3,a6,ffffffffc02035a4 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0203558:	ff07b603          	ld	a2,-16(a5)
ffffffffc020355c:	02c6f263          	bleu	a2,a3,ffffffffc0203580 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203560:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0203562:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203564:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203568:	e390                	sd	a2,0(a5)
ffffffffc020356a:	e710                	sd	a2,8(a4)
}
ffffffffc020356c:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020356e:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203570:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0203572:	2685                	addiw	a3,a3,1
ffffffffc0203574:	d114                	sw	a3,32(a0)
}
ffffffffc0203576:	0141                	addi	sp,sp,16
ffffffffc0203578:	8082                	ret
    if (le_prev != list) {
ffffffffc020357a:	fca711e3          	bne	a4,a0,ffffffffc020353c <insert_vma_struct+0x26>
ffffffffc020357e:	bfd9                	j	ffffffffc0203554 <insert_vma_struct+0x3e>
ffffffffc0203580:	ebbff0ef          	jal	ra,ffffffffc020343a <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203584:	00002697          	auipc	a3,0x2
ffffffffc0203588:	73c68693          	addi	a3,a3,1852 # ffffffffc0205cc0 <default_pmm_manager+0xbf8>
ffffffffc020358c:	00001617          	auipc	a2,0x1
ffffffffc0203590:	7a460613          	addi	a2,a2,1956 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203594:	08400593          	li	a1,132
ffffffffc0203598:	00002517          	auipc	a0,0x2
ffffffffc020359c:	69850513          	addi	a0,a0,1688 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc02035a0:	ddffc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02035a4:	00002697          	auipc	a3,0x2
ffffffffc02035a8:	75c68693          	addi	a3,a3,1884 # ffffffffc0205d00 <default_pmm_manager+0xc38>
ffffffffc02035ac:	00001617          	auipc	a2,0x1
ffffffffc02035b0:	78460613          	addi	a2,a2,1924 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02035b4:	07c00593          	li	a1,124
ffffffffc02035b8:	00002517          	auipc	a0,0x2
ffffffffc02035bc:	67850513          	addi	a0,a0,1656 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc02035c0:	dbffc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02035c4:	00002697          	auipc	a3,0x2
ffffffffc02035c8:	71c68693          	addi	a3,a3,1820 # ffffffffc0205ce0 <default_pmm_manager+0xc18>
ffffffffc02035cc:	00001617          	auipc	a2,0x1
ffffffffc02035d0:	76460613          	addi	a2,a2,1892 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02035d4:	07b00593          	li	a1,123
ffffffffc02035d8:	00002517          	auipc	a0,0x2
ffffffffc02035dc:	65850513          	addi	a0,a0,1624 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc02035e0:	d9ffc0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02035e4 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc02035e4:	1141                	addi	sp,sp,-16
ffffffffc02035e6:	e022                	sd	s0,0(sp)
ffffffffc02035e8:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02035ea:	6508                	ld	a0,8(a0)
ffffffffc02035ec:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02035ee:	00a40e63          	beq	s0,a0,ffffffffc020360a <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02035f2:	6118                	ld	a4,0(a0)
ffffffffc02035f4:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02035f6:	03000593          	li	a1,48
ffffffffc02035fa:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02035fc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02035fe:	e398                	sd	a4,0(a5)
ffffffffc0203600:	9acff0ef          	jal	ra,ffffffffc02027ac <kfree>
    return listelm->next;
ffffffffc0203604:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203606:	fea416e3          	bne	s0,a0,ffffffffc02035f2 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020360a:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020360c:	6402                	ld	s0,0(sp)
ffffffffc020360e:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203610:	03000593          	li	a1,48
}
ffffffffc0203614:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203616:	996ff06f          	j	ffffffffc02027ac <kfree>

ffffffffc020361a <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020361a:	715d                	addi	sp,sp,-80
ffffffffc020361c:	e486                	sd	ra,72(sp)
ffffffffc020361e:	e0a2                	sd	s0,64(sp)
ffffffffc0203620:	fc26                	sd	s1,56(sp)
ffffffffc0203622:	f84a                	sd	s2,48(sp)
ffffffffc0203624:	f052                	sd	s4,32(sp)
ffffffffc0203626:	f44e                	sd	s3,40(sp)
ffffffffc0203628:	ec56                	sd	s5,24(sp)
ffffffffc020362a:	e85a                	sd	s6,16(sp)
ffffffffc020362c:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020362e:	95efe0ef          	jal	ra,ffffffffc020178c <nr_free_pages>
ffffffffc0203632:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203634:	958fe0ef          	jal	ra,ffffffffc020178c <nr_free_pages>
ffffffffc0203638:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc020363a:	e25ff0ef          	jal	ra,ffffffffc020345e <mm_create>
    assert(mm != NULL);
ffffffffc020363e:	842a                	mv	s0,a0
ffffffffc0203640:	03200493          	li	s1,50
ffffffffc0203644:	e919                	bnez	a0,ffffffffc020365a <vmm_init+0x40>
ffffffffc0203646:	aeed                	j	ffffffffc0203a40 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc0203648:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020364a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020364c:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203650:	14ed                	addi	s1,s1,-5
ffffffffc0203652:	8522                	mv	a0,s0
ffffffffc0203654:	ec3ff0ef          	jal	ra,ffffffffc0203516 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203658:	c88d                	beqz	s1,ffffffffc020368a <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020365a:	03000513          	li	a0,48
ffffffffc020365e:	88cff0ef          	jal	ra,ffffffffc02026ea <kmalloc>
ffffffffc0203662:	85aa                	mv	a1,a0
ffffffffc0203664:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203668:	f165                	bnez	a0,ffffffffc0203648 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc020366a:	00002697          	auipc	a3,0x2
ffffffffc020366e:	1f668693          	addi	a3,a3,502 # ffffffffc0205860 <default_pmm_manager+0x798>
ffffffffc0203672:	00001617          	auipc	a2,0x1
ffffffffc0203676:	6be60613          	addi	a2,a2,1726 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc020367a:	0ce00593          	li	a1,206
ffffffffc020367e:	00002517          	auipc	a0,0x2
ffffffffc0203682:	5b250513          	addi	a0,a0,1458 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc0203686:	cf9fc0ef          	jal	ra,ffffffffc020037e <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc020368a:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020368e:	1f900993          	li	s3,505
ffffffffc0203692:	a819                	j	ffffffffc02036a8 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0203694:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203696:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203698:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020369c:	0495                	addi	s1,s1,5
ffffffffc020369e:	8522                	mv	a0,s0
ffffffffc02036a0:	e77ff0ef          	jal	ra,ffffffffc0203516 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02036a4:	03348a63          	beq	s1,s3,ffffffffc02036d8 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02036a8:	03000513          	li	a0,48
ffffffffc02036ac:	83eff0ef          	jal	ra,ffffffffc02026ea <kmalloc>
ffffffffc02036b0:	85aa                	mv	a1,a0
ffffffffc02036b2:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02036b6:	fd79                	bnez	a0,ffffffffc0203694 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc02036b8:	00002697          	auipc	a3,0x2
ffffffffc02036bc:	1a868693          	addi	a3,a3,424 # ffffffffc0205860 <default_pmm_manager+0x798>
ffffffffc02036c0:	00001617          	auipc	a2,0x1
ffffffffc02036c4:	67060613          	addi	a2,a2,1648 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02036c8:	0d400593          	li	a1,212
ffffffffc02036cc:	00002517          	auipc	a0,0x2
ffffffffc02036d0:	56450513          	addi	a0,a0,1380 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc02036d4:	cabfc0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc02036d8:	6418                	ld	a4,8(s0)
ffffffffc02036da:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02036dc:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02036e0:	2ae40063          	beq	s0,a4,ffffffffc0203980 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02036e4:	fe873603          	ld	a2,-24(a4)
ffffffffc02036e8:	ffe78693          	addi	a3,a5,-2
ffffffffc02036ec:	20d61a63          	bne	a2,a3,ffffffffc0203900 <vmm_init+0x2e6>
ffffffffc02036f0:	ff073683          	ld	a3,-16(a4)
ffffffffc02036f4:	20d79663          	bne	a5,a3,ffffffffc0203900 <vmm_init+0x2e6>
ffffffffc02036f8:	0795                	addi	a5,a5,5
ffffffffc02036fa:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02036fc:	feb792e3          	bne	a5,a1,ffffffffc02036e0 <vmm_init+0xc6>
ffffffffc0203700:	499d                	li	s3,7
ffffffffc0203702:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203704:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203708:	85a6                	mv	a1,s1
ffffffffc020370a:	8522                	mv	a0,s0
ffffffffc020370c:	dcdff0ef          	jal	ra,ffffffffc02034d8 <find_vma>
ffffffffc0203710:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc0203712:	2e050763          	beqz	a0,ffffffffc0203a00 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203716:	00148593          	addi	a1,s1,1
ffffffffc020371a:	8522                	mv	a0,s0
ffffffffc020371c:	dbdff0ef          	jal	ra,ffffffffc02034d8 <find_vma>
ffffffffc0203720:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0203722:	2a050f63          	beqz	a0,ffffffffc02039e0 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203726:	85ce                	mv	a1,s3
ffffffffc0203728:	8522                	mv	a0,s0
ffffffffc020372a:	dafff0ef          	jal	ra,ffffffffc02034d8 <find_vma>
        assert(vma3 == NULL);
ffffffffc020372e:	28051963          	bnez	a0,ffffffffc02039c0 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203732:	00348593          	addi	a1,s1,3
ffffffffc0203736:	8522                	mv	a0,s0
ffffffffc0203738:	da1ff0ef          	jal	ra,ffffffffc02034d8 <find_vma>
        assert(vma4 == NULL);
ffffffffc020373c:	26051263          	bnez	a0,ffffffffc02039a0 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203740:	00448593          	addi	a1,s1,4
ffffffffc0203744:	8522                	mv	a0,s0
ffffffffc0203746:	d93ff0ef          	jal	ra,ffffffffc02034d8 <find_vma>
        assert(vma5 == NULL);
ffffffffc020374a:	2c051b63          	bnez	a0,ffffffffc0203a20 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020374e:	008b3783          	ld	a5,8(s6)
ffffffffc0203752:	1c979763          	bne	a5,s1,ffffffffc0203920 <vmm_init+0x306>
ffffffffc0203756:	010b3783          	ld	a5,16(s6)
ffffffffc020375a:	1d379363          	bne	a5,s3,ffffffffc0203920 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020375e:	008ab783          	ld	a5,8(s5)
ffffffffc0203762:	1c979f63          	bne	a5,s1,ffffffffc0203940 <vmm_init+0x326>
ffffffffc0203766:	010ab783          	ld	a5,16(s5)
ffffffffc020376a:	1d379b63          	bne	a5,s3,ffffffffc0203940 <vmm_init+0x326>
ffffffffc020376e:	0495                	addi	s1,s1,5
ffffffffc0203770:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203772:	f9749be3          	bne	s1,s7,ffffffffc0203708 <vmm_init+0xee>
ffffffffc0203776:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203778:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020377a:	85a6                	mv	a1,s1
ffffffffc020377c:	8522                	mv	a0,s0
ffffffffc020377e:	d5bff0ef          	jal	ra,ffffffffc02034d8 <find_vma>
ffffffffc0203782:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203786:	c90d                	beqz	a0,ffffffffc02037b8 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203788:	6914                	ld	a3,16(a0)
ffffffffc020378a:	6510                	ld	a2,8(a0)
ffffffffc020378c:	00002517          	auipc	a0,0x2
ffffffffc0203790:	69450513          	addi	a0,a0,1684 # ffffffffc0205e20 <default_pmm_manager+0xd58>
ffffffffc0203794:	935fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203798:	00002697          	auipc	a3,0x2
ffffffffc020379c:	6b068693          	addi	a3,a3,1712 # ffffffffc0205e48 <default_pmm_manager+0xd80>
ffffffffc02037a0:	00001617          	auipc	a2,0x1
ffffffffc02037a4:	59060613          	addi	a2,a2,1424 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02037a8:	0f600593          	li	a1,246
ffffffffc02037ac:	00002517          	auipc	a0,0x2
ffffffffc02037b0:	48450513          	addi	a0,a0,1156 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc02037b4:	bcbfc0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc02037b8:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02037ba:	fd3490e3          	bne	s1,s3,ffffffffc020377a <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc02037be:	8522                	mv	a0,s0
ffffffffc02037c0:	e25ff0ef          	jal	ra,ffffffffc02035e4 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02037c4:	fc9fd0ef          	jal	ra,ffffffffc020178c <nr_free_pages>
ffffffffc02037c8:	28aa1c63          	bne	s4,a0,ffffffffc0203a60 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02037cc:	00002517          	auipc	a0,0x2
ffffffffc02037d0:	6bc50513          	addi	a0,a0,1724 # ffffffffc0205e88 <default_pmm_manager+0xdc0>
ffffffffc02037d4:	8f5fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02037d8:	fb5fd0ef          	jal	ra,ffffffffc020178c <nr_free_pages>
ffffffffc02037dc:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02037de:	c81ff0ef          	jal	ra,ffffffffc020345e <mm_create>
ffffffffc02037e2:	0000e797          	auipc	a5,0xe
ffffffffc02037e6:	e8a7bf23          	sd	a0,-354(a5) # ffffffffc0211680 <check_mm_struct>
ffffffffc02037ea:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc02037ec:	2a050a63          	beqz	a0,ffffffffc0203aa0 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02037f0:	0000e797          	auipc	a5,0xe
ffffffffc02037f4:	c6078793          	addi	a5,a5,-928 # ffffffffc0211450 <boot_pgdir>
ffffffffc02037f8:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02037fa:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02037fc:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02037fe:	32079d63          	bnez	a5,ffffffffc0203b38 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203802:	03000513          	li	a0,48
ffffffffc0203806:	ee5fe0ef          	jal	ra,ffffffffc02026ea <kmalloc>
ffffffffc020380a:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc020380c:	14050a63          	beqz	a0,ffffffffc0203960 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc0203810:	002007b7          	lui	a5,0x200
ffffffffc0203814:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0203818:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020381a:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020381c:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203820:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203822:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203826:	cf1ff0ef          	jal	ra,ffffffffc0203516 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020382a:	10000593          	li	a1,256
ffffffffc020382e:	8522                	mv	a0,s0
ffffffffc0203830:	ca9ff0ef          	jal	ra,ffffffffc02034d8 <find_vma>
ffffffffc0203834:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203838:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020383c:	2aaa1263          	bne	s4,a0,ffffffffc0203ae0 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc0203840:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203844:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203846:	fee79de3          	bne	a5,a4,ffffffffc0203840 <vmm_init+0x226>
        sum += i;
ffffffffc020384a:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc020384c:	10000793          	li	a5,256
        sum += i;
ffffffffc0203850:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203854:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203858:	0007c683          	lbu	a3,0(a5)
ffffffffc020385c:	0785                	addi	a5,a5,1
ffffffffc020385e:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203860:	fec79ce3          	bne	a5,a2,ffffffffc0203858 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0203864:	2a071a63          	bnez	a4,ffffffffc0203b18 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203868:	4581                	li	a1,0
ffffffffc020386a:	8526                	mv	a0,s1
ffffffffc020386c:	9c6fe0ef          	jal	ra,ffffffffc0201a32 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203870:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0203872:	0000e717          	auipc	a4,0xe
ffffffffc0203876:	be670713          	addi	a4,a4,-1050 # ffffffffc0211458 <npage>
ffffffffc020387a:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc020387c:	078a                	slli	a5,a5,0x2
ffffffffc020387e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203880:	28e7f063          	bleu	a4,a5,ffffffffc0203b00 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0203884:	00003717          	auipc	a4,0x3
ffffffffc0203888:	94470713          	addi	a4,a4,-1724 # ffffffffc02061c8 <nbase>
ffffffffc020388c:	6318                	ld	a4,0(a4)
ffffffffc020388e:	0000e697          	auipc	a3,0xe
ffffffffc0203892:	d0a68693          	addi	a3,a3,-758 # ffffffffc0211598 <pages>
ffffffffc0203896:	6288                	ld	a0,0(a3)
ffffffffc0203898:	8f99                	sub	a5,a5,a4
ffffffffc020389a:	00379713          	slli	a4,a5,0x3
ffffffffc020389e:	97ba                	add	a5,a5,a4
ffffffffc02038a0:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc02038a2:	953e                	add	a0,a0,a5
ffffffffc02038a4:	4585                	li	a1,1
ffffffffc02038a6:	ea1fd0ef          	jal	ra,ffffffffc0201746 <free_pages>

    pgdir[0] = 0;
ffffffffc02038aa:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02038ae:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02038b0:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02038b4:	d31ff0ef          	jal	ra,ffffffffc02035e4 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc02038b8:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc02038ba:	0000e797          	auipc	a5,0xe
ffffffffc02038be:	dc07b323          	sd	zero,-570(a5) # ffffffffc0211680 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038c2:	ecbfd0ef          	jal	ra,ffffffffc020178c <nr_free_pages>
ffffffffc02038c6:	1aa99d63          	bne	s3,a0,ffffffffc0203a80 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02038ca:	00002517          	auipc	a0,0x2
ffffffffc02038ce:	62650513          	addi	a0,a0,1574 # ffffffffc0205ef0 <default_pmm_manager+0xe28>
ffffffffc02038d2:	ff6fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038d6:	eb7fd0ef          	jal	ra,ffffffffc020178c <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc02038da:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038dc:	1ea91263          	bne	s2,a0,ffffffffc0203ac0 <vmm_init+0x4a6>
}
ffffffffc02038e0:	6406                	ld	s0,64(sp)
ffffffffc02038e2:	60a6                	ld	ra,72(sp)
ffffffffc02038e4:	74e2                	ld	s1,56(sp)
ffffffffc02038e6:	7942                	ld	s2,48(sp)
ffffffffc02038e8:	79a2                	ld	s3,40(sp)
ffffffffc02038ea:	7a02                	ld	s4,32(sp)
ffffffffc02038ec:	6ae2                	ld	s5,24(sp)
ffffffffc02038ee:	6b42                	ld	s6,16(sp)
ffffffffc02038f0:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02038f2:	00002517          	auipc	a0,0x2
ffffffffc02038f6:	61e50513          	addi	a0,a0,1566 # ffffffffc0205f10 <default_pmm_manager+0xe48>
}
ffffffffc02038fa:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc02038fc:	fccfc06f          	j	ffffffffc02000c8 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203900:	00002697          	auipc	a3,0x2
ffffffffc0203904:	43868693          	addi	a3,a3,1080 # ffffffffc0205d38 <default_pmm_manager+0xc70>
ffffffffc0203908:	00001617          	auipc	a2,0x1
ffffffffc020390c:	42860613          	addi	a2,a2,1064 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203910:	0dd00593          	li	a1,221
ffffffffc0203914:	00002517          	auipc	a0,0x2
ffffffffc0203918:	31c50513          	addi	a0,a0,796 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc020391c:	a63fc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203920:	00002697          	auipc	a3,0x2
ffffffffc0203924:	4a068693          	addi	a3,a3,1184 # ffffffffc0205dc0 <default_pmm_manager+0xcf8>
ffffffffc0203928:	00001617          	auipc	a2,0x1
ffffffffc020392c:	40860613          	addi	a2,a2,1032 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203930:	0ed00593          	li	a1,237
ffffffffc0203934:	00002517          	auipc	a0,0x2
ffffffffc0203938:	2fc50513          	addi	a0,a0,764 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc020393c:	a43fc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203940:	00002697          	auipc	a3,0x2
ffffffffc0203944:	4b068693          	addi	a3,a3,1200 # ffffffffc0205df0 <default_pmm_manager+0xd28>
ffffffffc0203948:	00001617          	auipc	a2,0x1
ffffffffc020394c:	3e860613          	addi	a2,a2,1000 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203950:	0ee00593          	li	a1,238
ffffffffc0203954:	00002517          	auipc	a0,0x2
ffffffffc0203958:	2dc50513          	addi	a0,a0,732 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc020395c:	a23fc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(vma != NULL);
ffffffffc0203960:	00002697          	auipc	a3,0x2
ffffffffc0203964:	f0068693          	addi	a3,a3,-256 # ffffffffc0205860 <default_pmm_manager+0x798>
ffffffffc0203968:	00001617          	auipc	a2,0x1
ffffffffc020396c:	3c860613          	addi	a2,a2,968 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203970:	11100593          	li	a1,273
ffffffffc0203974:	00002517          	auipc	a0,0x2
ffffffffc0203978:	2bc50513          	addi	a0,a0,700 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc020397c:	a03fc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203980:	00002697          	auipc	a3,0x2
ffffffffc0203984:	3a068693          	addi	a3,a3,928 # ffffffffc0205d20 <default_pmm_manager+0xc58>
ffffffffc0203988:	00001617          	auipc	a2,0x1
ffffffffc020398c:	3a860613          	addi	a2,a2,936 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203990:	0db00593          	li	a1,219
ffffffffc0203994:	00002517          	auipc	a0,0x2
ffffffffc0203998:	29c50513          	addi	a0,a0,668 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc020399c:	9e3fc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma4 == NULL);
ffffffffc02039a0:	00002697          	auipc	a3,0x2
ffffffffc02039a4:	40068693          	addi	a3,a3,1024 # ffffffffc0205da0 <default_pmm_manager+0xcd8>
ffffffffc02039a8:	00001617          	auipc	a2,0x1
ffffffffc02039ac:	38860613          	addi	a2,a2,904 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02039b0:	0e900593          	li	a1,233
ffffffffc02039b4:	00002517          	auipc	a0,0x2
ffffffffc02039b8:	27c50513          	addi	a0,a0,636 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc02039bc:	9c3fc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma3 == NULL);
ffffffffc02039c0:	00002697          	auipc	a3,0x2
ffffffffc02039c4:	3d068693          	addi	a3,a3,976 # ffffffffc0205d90 <default_pmm_manager+0xcc8>
ffffffffc02039c8:	00001617          	auipc	a2,0x1
ffffffffc02039cc:	36860613          	addi	a2,a2,872 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02039d0:	0e700593          	li	a1,231
ffffffffc02039d4:	00002517          	auipc	a0,0x2
ffffffffc02039d8:	25c50513          	addi	a0,a0,604 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc02039dc:	9a3fc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma2 != NULL);
ffffffffc02039e0:	00002697          	auipc	a3,0x2
ffffffffc02039e4:	3a068693          	addi	a3,a3,928 # ffffffffc0205d80 <default_pmm_manager+0xcb8>
ffffffffc02039e8:	00001617          	auipc	a2,0x1
ffffffffc02039ec:	34860613          	addi	a2,a2,840 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc02039f0:	0e500593          	li	a1,229
ffffffffc02039f4:	00002517          	auipc	a0,0x2
ffffffffc02039f8:	23c50513          	addi	a0,a0,572 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc02039fc:	983fc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma1 != NULL);
ffffffffc0203a00:	00002697          	auipc	a3,0x2
ffffffffc0203a04:	37068693          	addi	a3,a3,880 # ffffffffc0205d70 <default_pmm_manager+0xca8>
ffffffffc0203a08:	00001617          	auipc	a2,0x1
ffffffffc0203a0c:	32860613          	addi	a2,a2,808 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203a10:	0e300593          	li	a1,227
ffffffffc0203a14:	00002517          	auipc	a0,0x2
ffffffffc0203a18:	21c50513          	addi	a0,a0,540 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc0203a1c:	963fc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma5 == NULL);
ffffffffc0203a20:	00002697          	auipc	a3,0x2
ffffffffc0203a24:	39068693          	addi	a3,a3,912 # ffffffffc0205db0 <default_pmm_manager+0xce8>
ffffffffc0203a28:	00001617          	auipc	a2,0x1
ffffffffc0203a2c:	30860613          	addi	a2,a2,776 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203a30:	0eb00593          	li	a1,235
ffffffffc0203a34:	00002517          	auipc	a0,0x2
ffffffffc0203a38:	1fc50513          	addi	a0,a0,508 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc0203a3c:	943fc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(mm != NULL);
ffffffffc0203a40:	00002697          	auipc	a3,0x2
ffffffffc0203a44:	de868693          	addi	a3,a3,-536 # ffffffffc0205828 <default_pmm_manager+0x760>
ffffffffc0203a48:	00001617          	auipc	a2,0x1
ffffffffc0203a4c:	2e860613          	addi	a2,a2,744 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203a50:	0c700593          	li	a1,199
ffffffffc0203a54:	00002517          	auipc	a0,0x2
ffffffffc0203a58:	1dc50513          	addi	a0,a0,476 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc0203a5c:	923fc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a60:	00002697          	auipc	a3,0x2
ffffffffc0203a64:	40068693          	addi	a3,a3,1024 # ffffffffc0205e60 <default_pmm_manager+0xd98>
ffffffffc0203a68:	00001617          	auipc	a2,0x1
ffffffffc0203a6c:	2c860613          	addi	a2,a2,712 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203a70:	0fb00593          	li	a1,251
ffffffffc0203a74:	00002517          	auipc	a0,0x2
ffffffffc0203a78:	1bc50513          	addi	a0,a0,444 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc0203a7c:	903fc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a80:	00002697          	auipc	a3,0x2
ffffffffc0203a84:	3e068693          	addi	a3,a3,992 # ffffffffc0205e60 <default_pmm_manager+0xd98>
ffffffffc0203a88:	00001617          	auipc	a2,0x1
ffffffffc0203a8c:	2a860613          	addi	a2,a2,680 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203a90:	12e00593          	li	a1,302
ffffffffc0203a94:	00002517          	auipc	a0,0x2
ffffffffc0203a98:	19c50513          	addi	a0,a0,412 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc0203a9c:	8e3fc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203aa0:	00002697          	auipc	a3,0x2
ffffffffc0203aa4:	40868693          	addi	a3,a3,1032 # ffffffffc0205ea8 <default_pmm_manager+0xde0>
ffffffffc0203aa8:	00001617          	auipc	a2,0x1
ffffffffc0203aac:	28860613          	addi	a2,a2,648 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203ab0:	10a00593          	li	a1,266
ffffffffc0203ab4:	00002517          	auipc	a0,0x2
ffffffffc0203ab8:	17c50513          	addi	a0,a0,380 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc0203abc:	8c3fc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ac0:	00002697          	auipc	a3,0x2
ffffffffc0203ac4:	3a068693          	addi	a3,a3,928 # ffffffffc0205e60 <default_pmm_manager+0xd98>
ffffffffc0203ac8:	00001617          	auipc	a2,0x1
ffffffffc0203acc:	26860613          	addi	a2,a2,616 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203ad0:	0bd00593          	li	a1,189
ffffffffc0203ad4:	00002517          	auipc	a0,0x2
ffffffffc0203ad8:	15c50513          	addi	a0,a0,348 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc0203adc:	8a3fc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203ae0:	00002697          	auipc	a3,0x2
ffffffffc0203ae4:	3e068693          	addi	a3,a3,992 # ffffffffc0205ec0 <default_pmm_manager+0xdf8>
ffffffffc0203ae8:	00001617          	auipc	a2,0x1
ffffffffc0203aec:	24860613          	addi	a2,a2,584 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203af0:	11600593          	li	a1,278
ffffffffc0203af4:	00002517          	auipc	a0,0x2
ffffffffc0203af8:	13c50513          	addi	a0,a0,316 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc0203afc:	883fc0ef          	jal	ra,ffffffffc020037e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203b00:	00001617          	auipc	a2,0x1
ffffffffc0203b04:	69060613          	addi	a2,a2,1680 # ffffffffc0205190 <default_pmm_manager+0xc8>
ffffffffc0203b08:	06500593          	li	a1,101
ffffffffc0203b0c:	00001517          	auipc	a0,0x1
ffffffffc0203b10:	6a450513          	addi	a0,a0,1700 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0203b14:	86bfc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(sum == 0);
ffffffffc0203b18:	00002697          	auipc	a3,0x2
ffffffffc0203b1c:	3c868693          	addi	a3,a3,968 # ffffffffc0205ee0 <default_pmm_manager+0xe18>
ffffffffc0203b20:	00001617          	auipc	a2,0x1
ffffffffc0203b24:	21060613          	addi	a2,a2,528 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203b28:	12000593          	li	a1,288
ffffffffc0203b2c:	00002517          	auipc	a0,0x2
ffffffffc0203b30:	10450513          	addi	a0,a0,260 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc0203b34:	84bfc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203b38:	00002697          	auipc	a3,0x2
ffffffffc0203b3c:	d1868693          	addi	a3,a3,-744 # ffffffffc0205850 <default_pmm_manager+0x788>
ffffffffc0203b40:	00001617          	auipc	a2,0x1
ffffffffc0203b44:	1f060613          	addi	a2,a2,496 # ffffffffc0204d30 <commands+0x8d8>
ffffffffc0203b48:	10d00593          	li	a1,269
ffffffffc0203b4c:	00002517          	auipc	a0,0x2
ffffffffc0203b50:	0e450513          	addi	a0,a0,228 # ffffffffc0205c30 <default_pmm_manager+0xb68>
ffffffffc0203b54:	82bfc0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0203b58 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b58:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b5a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b5c:	f022                	sd	s0,32(sp)
ffffffffc0203b5e:	ec26                	sd	s1,24(sp)
ffffffffc0203b60:	f406                	sd	ra,40(sp)
ffffffffc0203b62:	e84a                	sd	s2,16(sp)
ffffffffc0203b64:	8432                	mv	s0,a2
ffffffffc0203b66:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b68:	971ff0ef          	jal	ra,ffffffffc02034d8 <find_vma>

    pgfault_num++;
ffffffffc0203b6c:	0000e797          	auipc	a5,0xe
ffffffffc0203b70:	90078793          	addi	a5,a5,-1792 # ffffffffc021146c <pgfault_num>
ffffffffc0203b74:	439c                	lw	a5,0(a5)
ffffffffc0203b76:	2785                	addiw	a5,a5,1
ffffffffc0203b78:	0000e717          	auipc	a4,0xe
ffffffffc0203b7c:	8ef72a23          	sw	a5,-1804(a4) # ffffffffc021146c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203b80:	c549                	beqz	a0,ffffffffc0203c0a <do_pgfault+0xb2>
ffffffffc0203b82:	651c                	ld	a5,8(a0)
ffffffffc0203b84:	08f46363          	bltu	s0,a5,ffffffffc0203c0a <do_pgfault+0xb2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b88:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203b8a:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b8c:	8b89                	andi	a5,a5,2
ffffffffc0203b8e:	efa9                	bnez	a5,ffffffffc0203be8 <do_pgfault+0x90>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b90:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b92:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b94:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b96:	85a2                	mv	a1,s0
ffffffffc0203b98:	4605                	li	a2,1
ffffffffc0203b9a:	c33fd0ef          	jal	ra,ffffffffc02017cc <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203b9e:	610c                	ld	a1,0(a0)
ffffffffc0203ba0:	c5b1                	beqz	a1,ffffffffc0203bec <do_pgfault+0x94>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203ba2:	0000e797          	auipc	a5,0xe
ffffffffc0203ba6:	8c678793          	addi	a5,a5,-1850 # ffffffffc0211468 <swap_init_ok>
ffffffffc0203baa:	439c                	lw	a5,0(a5)
ffffffffc0203bac:	2781                	sext.w	a5,a5
ffffffffc0203bae:	c7bd                	beqz	a5,ffffffffc0203c1c <do_pgfault+0xc4>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm, addr, &page);
ffffffffc0203bb0:	85a2                	mv	a1,s0
ffffffffc0203bb2:	0030                	addi	a2,sp,8
ffffffffc0203bb4:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203bb6:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0203bb8:	c88ff0ef          	jal	ra,ffffffffc0203040 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0203bbc:	65a2                	ld	a1,8(sp)
ffffffffc0203bbe:	6c88                	ld	a0,24(s1)
ffffffffc0203bc0:	86ca                	mv	a3,s2
ffffffffc0203bc2:	8622                	mv	a2,s0
ffffffffc0203bc4:	ee1fd0ef          	jal	ra,ffffffffc0201aa4 <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm,addr,page,1);
ffffffffc0203bc8:	6622                	ld	a2,8(sp)
ffffffffc0203bca:	4685                	li	a3,1
ffffffffc0203bcc:	85a2                	mv	a1,s0
ffffffffc0203bce:	8526                	mv	a0,s1
ffffffffc0203bd0:	b4cff0ef          	jal	ra,ffffffffc0202f1c <swap_map_swappable>

            
            page->pra_vaddr = addr;
ffffffffc0203bd4:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203bd6:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0203bd8:	e320                	sd	s0,64(a4)
failed:
    return ret;
}
ffffffffc0203bda:	70a2                	ld	ra,40(sp)
ffffffffc0203bdc:	7402                	ld	s0,32(sp)
ffffffffc0203bde:	64e2                	ld	s1,24(sp)
ffffffffc0203be0:	6942                	ld	s2,16(sp)
ffffffffc0203be2:	853e                	mv	a0,a5
ffffffffc0203be4:	6145                	addi	sp,sp,48
ffffffffc0203be6:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203be8:	4959                	li	s2,22
ffffffffc0203bea:	b75d                	j	ffffffffc0203b90 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203bec:	6c88                	ld	a0,24(s1)
ffffffffc0203bee:	864a                	mv	a2,s2
ffffffffc0203bf0:	85a2                	mv	a1,s0
ffffffffc0203bf2:	a67fe0ef          	jal	ra,ffffffffc0202658 <pgdir_alloc_page>
   ret = 0;
ffffffffc0203bf6:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203bf8:	f16d                	bnez	a0,ffffffffc0203bda <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203bfa:	00002517          	auipc	a0,0x2
ffffffffc0203bfe:	07650513          	addi	a0,a0,118 # ffffffffc0205c70 <default_pmm_manager+0xba8>
ffffffffc0203c02:	cc6fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c06:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203c08:	bfc9                	j	ffffffffc0203bda <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203c0a:	85a2                	mv	a1,s0
ffffffffc0203c0c:	00002517          	auipc	a0,0x2
ffffffffc0203c10:	03450513          	addi	a0,a0,52 # ffffffffc0205c40 <default_pmm_manager+0xb78>
ffffffffc0203c14:	cb4fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203c18:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203c1a:	b7c1                	j	ffffffffc0203bda <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203c1c:	00002517          	auipc	a0,0x2
ffffffffc0203c20:	07c50513          	addi	a0,a0,124 # ffffffffc0205c98 <default_pmm_manager+0xbd0>
ffffffffc0203c24:	ca4fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c28:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203c2a:	bf45                	j	ffffffffc0203bda <do_pgfault+0x82>

ffffffffc0203c2c <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203c2c:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c2e:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203c30:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c32:	85bfc0ef          	jal	ra,ffffffffc020048c <ide_device_valid>
ffffffffc0203c36:	cd01                	beqz	a0,ffffffffc0203c4e <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c38:	4505                	li	a0,1
ffffffffc0203c3a:	859fc0ef          	jal	ra,ffffffffc0200492 <ide_device_size>
}
ffffffffc0203c3e:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c40:	810d                	srli	a0,a0,0x3
ffffffffc0203c42:	0000e797          	auipc	a5,0xe
ffffffffc0203c46:	9ea7b323          	sd	a0,-1562(a5) # ffffffffc0211628 <max_swap_offset>
}
ffffffffc0203c4a:	0141                	addi	sp,sp,16
ffffffffc0203c4c:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203c4e:	00002617          	auipc	a2,0x2
ffffffffc0203c52:	2da60613          	addi	a2,a2,730 # ffffffffc0205f28 <default_pmm_manager+0xe60>
ffffffffc0203c56:	45b5                	li	a1,13
ffffffffc0203c58:	00002517          	auipc	a0,0x2
ffffffffc0203c5c:	2f050513          	addi	a0,a0,752 # ffffffffc0205f48 <default_pmm_manager+0xe80>
ffffffffc0203c60:	f1efc0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0203c64 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203c64:	1141                	addi	sp,sp,-16
ffffffffc0203c66:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c68:	00855793          	srli	a5,a0,0x8
ffffffffc0203c6c:	c7b5                	beqz	a5,ffffffffc0203cd8 <swapfs_read+0x74>
ffffffffc0203c6e:	0000e717          	auipc	a4,0xe
ffffffffc0203c72:	9ba70713          	addi	a4,a4,-1606 # ffffffffc0211628 <max_swap_offset>
ffffffffc0203c76:	6318                	ld	a4,0(a4)
ffffffffc0203c78:	06e7f063          	bleu	a4,a5,ffffffffc0203cd8 <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c7c:	0000e717          	auipc	a4,0xe
ffffffffc0203c80:	91c70713          	addi	a4,a4,-1764 # ffffffffc0211598 <pages>
ffffffffc0203c84:	6310                	ld	a2,0(a4)
ffffffffc0203c86:	00001717          	auipc	a4,0x1
ffffffffc0203c8a:	09270713          	addi	a4,a4,146 # ffffffffc0204d18 <commands+0x8c0>
ffffffffc0203c8e:	00002697          	auipc	a3,0x2
ffffffffc0203c92:	53a68693          	addi	a3,a3,1338 # ffffffffc02061c8 <nbase>
ffffffffc0203c96:	40c58633          	sub	a2,a1,a2
ffffffffc0203c9a:	630c                	ld	a1,0(a4)
ffffffffc0203c9c:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c9e:	0000d717          	auipc	a4,0xd
ffffffffc0203ca2:	7ba70713          	addi	a4,a4,1978 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ca6:	02b60633          	mul	a2,a2,a1
ffffffffc0203caa:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203cae:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cb0:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cb2:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cb4:	57fd                	li	a5,-1
ffffffffc0203cb6:	83b1                	srli	a5,a5,0xc
ffffffffc0203cb8:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cba:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cbc:	02e7fa63          	bleu	a4,a5,ffffffffc0203cf0 <swapfs_read+0x8c>
ffffffffc0203cc0:	0000e797          	auipc	a5,0xe
ffffffffc0203cc4:	8c878793          	addi	a5,a5,-1848 # ffffffffc0211588 <va_pa_offset>
ffffffffc0203cc8:	639c                	ld	a5,0(a5)
}
ffffffffc0203cca:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ccc:	46a1                	li	a3,8
ffffffffc0203cce:	963e                	add	a2,a2,a5
ffffffffc0203cd0:	4505                	li	a0,1
}
ffffffffc0203cd2:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cd4:	fc4fc06f          	j	ffffffffc0200498 <ide_read_secs>
ffffffffc0203cd8:	86aa                	mv	a3,a0
ffffffffc0203cda:	00002617          	auipc	a2,0x2
ffffffffc0203cde:	28660613          	addi	a2,a2,646 # ffffffffc0205f60 <default_pmm_manager+0xe98>
ffffffffc0203ce2:	45d1                	li	a1,20
ffffffffc0203ce4:	00002517          	auipc	a0,0x2
ffffffffc0203ce8:	26450513          	addi	a0,a0,612 # ffffffffc0205f48 <default_pmm_manager+0xe80>
ffffffffc0203cec:	e92fc0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc0203cf0:	86b2                	mv	a3,a2
ffffffffc0203cf2:	06a00593          	li	a1,106
ffffffffc0203cf6:	00001617          	auipc	a2,0x1
ffffffffc0203cfa:	42260613          	addi	a2,a2,1058 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc0203cfe:	00001517          	auipc	a0,0x1
ffffffffc0203d02:	4b250513          	addi	a0,a0,1202 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0203d06:	e78fc0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0203d0a <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203d0a:	1141                	addi	sp,sp,-16
ffffffffc0203d0c:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d0e:	00855793          	srli	a5,a0,0x8
ffffffffc0203d12:	c7b5                	beqz	a5,ffffffffc0203d7e <swapfs_write+0x74>
ffffffffc0203d14:	0000e717          	auipc	a4,0xe
ffffffffc0203d18:	91470713          	addi	a4,a4,-1772 # ffffffffc0211628 <max_swap_offset>
ffffffffc0203d1c:	6318                	ld	a4,0(a4)
ffffffffc0203d1e:	06e7f063          	bleu	a4,a5,ffffffffc0203d7e <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d22:	0000e717          	auipc	a4,0xe
ffffffffc0203d26:	87670713          	addi	a4,a4,-1930 # ffffffffc0211598 <pages>
ffffffffc0203d2a:	6310                	ld	a2,0(a4)
ffffffffc0203d2c:	00001717          	auipc	a4,0x1
ffffffffc0203d30:	fec70713          	addi	a4,a4,-20 # ffffffffc0204d18 <commands+0x8c0>
ffffffffc0203d34:	00002697          	auipc	a3,0x2
ffffffffc0203d38:	49468693          	addi	a3,a3,1172 # ffffffffc02061c8 <nbase>
ffffffffc0203d3c:	40c58633          	sub	a2,a1,a2
ffffffffc0203d40:	630c                	ld	a1,0(a4)
ffffffffc0203d42:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d44:	0000d717          	auipc	a4,0xd
ffffffffc0203d48:	71470713          	addi	a4,a4,1812 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d4c:	02b60633          	mul	a2,a2,a1
ffffffffc0203d50:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d54:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d56:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d58:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d5a:	57fd                	li	a5,-1
ffffffffc0203d5c:	83b1                	srli	a5,a5,0xc
ffffffffc0203d5e:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d60:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d62:	02e7fa63          	bleu	a4,a5,ffffffffc0203d96 <swapfs_write+0x8c>
ffffffffc0203d66:	0000e797          	auipc	a5,0xe
ffffffffc0203d6a:	82278793          	addi	a5,a5,-2014 # ffffffffc0211588 <va_pa_offset>
ffffffffc0203d6e:	639c                	ld	a5,0(a5)
}
ffffffffc0203d70:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d72:	46a1                	li	a3,8
ffffffffc0203d74:	963e                	add	a2,a2,a5
ffffffffc0203d76:	4505                	li	a0,1
}
ffffffffc0203d78:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d7a:	f42fc06f          	j	ffffffffc02004bc <ide_write_secs>
ffffffffc0203d7e:	86aa                	mv	a3,a0
ffffffffc0203d80:	00002617          	auipc	a2,0x2
ffffffffc0203d84:	1e060613          	addi	a2,a2,480 # ffffffffc0205f60 <default_pmm_manager+0xe98>
ffffffffc0203d88:	45e5                	li	a1,25
ffffffffc0203d8a:	00002517          	auipc	a0,0x2
ffffffffc0203d8e:	1be50513          	addi	a0,a0,446 # ffffffffc0205f48 <default_pmm_manager+0xe80>
ffffffffc0203d92:	decfc0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc0203d96:	86b2                	mv	a3,a2
ffffffffc0203d98:	06a00593          	li	a1,106
ffffffffc0203d9c:	00001617          	auipc	a2,0x1
ffffffffc0203da0:	37c60613          	addi	a2,a2,892 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc0203da4:	00001517          	auipc	a0,0x1
ffffffffc0203da8:	40c50513          	addi	a0,a0,1036 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0203dac:	dd2fc0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0203db0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203db0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203db4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203db6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dba:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203dbc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dc0:	f022                	sd	s0,32(sp)
ffffffffc0203dc2:	ec26                	sd	s1,24(sp)
ffffffffc0203dc4:	e84a                	sd	s2,16(sp)
ffffffffc0203dc6:	f406                	sd	ra,40(sp)
ffffffffc0203dc8:	e44e                	sd	s3,8(sp)
ffffffffc0203dca:	84aa                	mv	s1,a0
ffffffffc0203dcc:	892e                	mv	s2,a1
ffffffffc0203dce:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203dd2:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203dd4:	03067e63          	bleu	a6,a2,ffffffffc0203e10 <printnum+0x60>
ffffffffc0203dd8:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203dda:	00805763          	blez	s0,ffffffffc0203de8 <printnum+0x38>
ffffffffc0203dde:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203de0:	85ca                	mv	a1,s2
ffffffffc0203de2:	854e                	mv	a0,s3
ffffffffc0203de4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203de6:	fc65                	bnez	s0,ffffffffc0203dde <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203de8:	1a02                	slli	s4,s4,0x20
ffffffffc0203dea:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203dee:	00002797          	auipc	a5,0x2
ffffffffc0203df2:	32278793          	addi	a5,a5,802 # ffffffffc0206110 <error_string+0x38>
ffffffffc0203df6:	9a3e                	add	s4,s4,a5
}
ffffffffc0203df8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203dfa:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203dfe:	70a2                	ld	ra,40(sp)
ffffffffc0203e00:	69a2                	ld	s3,8(sp)
ffffffffc0203e02:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e04:	85ca                	mv	a1,s2
ffffffffc0203e06:	8326                	mv	t1,s1
}
ffffffffc0203e08:	6942                	ld	s2,16(sp)
ffffffffc0203e0a:	64e2                	ld	s1,24(sp)
ffffffffc0203e0c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e0e:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203e10:	03065633          	divu	a2,a2,a6
ffffffffc0203e14:	8722                	mv	a4,s0
ffffffffc0203e16:	f9bff0ef          	jal	ra,ffffffffc0203db0 <printnum>
ffffffffc0203e1a:	b7f9                	j	ffffffffc0203de8 <printnum+0x38>

ffffffffc0203e1c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203e1c:	7119                	addi	sp,sp,-128
ffffffffc0203e1e:	f4a6                	sd	s1,104(sp)
ffffffffc0203e20:	f0ca                	sd	s2,96(sp)
ffffffffc0203e22:	e8d2                	sd	s4,80(sp)
ffffffffc0203e24:	e4d6                	sd	s5,72(sp)
ffffffffc0203e26:	e0da                	sd	s6,64(sp)
ffffffffc0203e28:	fc5e                	sd	s7,56(sp)
ffffffffc0203e2a:	f862                	sd	s8,48(sp)
ffffffffc0203e2c:	f06a                	sd	s10,32(sp)
ffffffffc0203e2e:	fc86                	sd	ra,120(sp)
ffffffffc0203e30:	f8a2                	sd	s0,112(sp)
ffffffffc0203e32:	ecce                	sd	s3,88(sp)
ffffffffc0203e34:	f466                	sd	s9,40(sp)
ffffffffc0203e36:	ec6e                	sd	s11,24(sp)
ffffffffc0203e38:	892a                	mv	s2,a0
ffffffffc0203e3a:	84ae                	mv	s1,a1
ffffffffc0203e3c:	8d32                	mv	s10,a2
ffffffffc0203e3e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203e40:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e42:	00002a17          	auipc	s4,0x2
ffffffffc0203e46:	13ea0a13          	addi	s4,s4,318 # ffffffffc0205f80 <default_pmm_manager+0xeb8>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e4a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203e4e:	00002c17          	auipc	s8,0x2
ffffffffc0203e52:	28ac0c13          	addi	s8,s8,650 # ffffffffc02060d8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e56:	000d4503          	lbu	a0,0(s10)
ffffffffc0203e5a:	02500793          	li	a5,37
ffffffffc0203e5e:	001d0413          	addi	s0,s10,1
ffffffffc0203e62:	00f50e63          	beq	a0,a5,ffffffffc0203e7e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203e66:	c521                	beqz	a0,ffffffffc0203eae <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e68:	02500993          	li	s3,37
ffffffffc0203e6c:	a011                	j	ffffffffc0203e70 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203e6e:	c121                	beqz	a0,ffffffffc0203eae <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203e70:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e72:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203e74:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e76:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203e7a:	ff351ae3          	bne	a0,s3,ffffffffc0203e6e <vprintfmt+0x52>
ffffffffc0203e7e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203e82:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203e86:	4981                	li	s3,0
ffffffffc0203e88:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203e8a:	5cfd                	li	s9,-1
ffffffffc0203e8c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e8e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203e92:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e94:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203e98:	0ff6f693          	andi	a3,a3,255
ffffffffc0203e9c:	00140d13          	addi	s10,s0,1
ffffffffc0203ea0:	20d5e563          	bltu	a1,a3,ffffffffc02040aa <vprintfmt+0x28e>
ffffffffc0203ea4:	068a                	slli	a3,a3,0x2
ffffffffc0203ea6:	96d2                	add	a3,a3,s4
ffffffffc0203ea8:	4294                	lw	a3,0(a3)
ffffffffc0203eaa:	96d2                	add	a3,a3,s4
ffffffffc0203eac:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203eae:	70e6                	ld	ra,120(sp)
ffffffffc0203eb0:	7446                	ld	s0,112(sp)
ffffffffc0203eb2:	74a6                	ld	s1,104(sp)
ffffffffc0203eb4:	7906                	ld	s2,96(sp)
ffffffffc0203eb6:	69e6                	ld	s3,88(sp)
ffffffffc0203eb8:	6a46                	ld	s4,80(sp)
ffffffffc0203eba:	6aa6                	ld	s5,72(sp)
ffffffffc0203ebc:	6b06                	ld	s6,64(sp)
ffffffffc0203ebe:	7be2                	ld	s7,56(sp)
ffffffffc0203ec0:	7c42                	ld	s8,48(sp)
ffffffffc0203ec2:	7ca2                	ld	s9,40(sp)
ffffffffc0203ec4:	7d02                	ld	s10,32(sp)
ffffffffc0203ec6:	6de2                	ld	s11,24(sp)
ffffffffc0203ec8:	6109                	addi	sp,sp,128
ffffffffc0203eca:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203ecc:	4705                	li	a4,1
ffffffffc0203ece:	008a8593          	addi	a1,s5,8
ffffffffc0203ed2:	01074463          	blt	a4,a6,ffffffffc0203eda <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203ed6:	26080363          	beqz	a6,ffffffffc020413c <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203eda:	000ab603          	ld	a2,0(s5)
ffffffffc0203ede:	46c1                	li	a3,16
ffffffffc0203ee0:	8aae                	mv	s5,a1
ffffffffc0203ee2:	a06d                	j	ffffffffc0203f8c <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203ee4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203ee8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203eea:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203eec:	b765                	j	ffffffffc0203e94 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203eee:	000aa503          	lw	a0,0(s5)
ffffffffc0203ef2:	85a6                	mv	a1,s1
ffffffffc0203ef4:	0aa1                	addi	s5,s5,8
ffffffffc0203ef6:	9902                	jalr	s2
            break;
ffffffffc0203ef8:	bfb9                	j	ffffffffc0203e56 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203efa:	4705                	li	a4,1
ffffffffc0203efc:	008a8993          	addi	s3,s5,8
ffffffffc0203f00:	01074463          	blt	a4,a6,ffffffffc0203f08 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203f04:	22080463          	beqz	a6,ffffffffc020412c <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203f08:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203f0c:	24044463          	bltz	s0,ffffffffc0204154 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203f10:	8622                	mv	a2,s0
ffffffffc0203f12:	8ace                	mv	s5,s3
ffffffffc0203f14:	46a9                	li	a3,10
ffffffffc0203f16:	a89d                	j	ffffffffc0203f8c <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203f18:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f1c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203f1e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203f20:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203f24:	8fb5                	xor	a5,a5,a3
ffffffffc0203f26:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f2a:	1ad74363          	blt	a4,a3,ffffffffc02040d0 <vprintfmt+0x2b4>
ffffffffc0203f2e:	00369793          	slli	a5,a3,0x3
ffffffffc0203f32:	97e2                	add	a5,a5,s8
ffffffffc0203f34:	639c                	ld	a5,0(a5)
ffffffffc0203f36:	18078d63          	beqz	a5,ffffffffc02040d0 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203f3a:	86be                	mv	a3,a5
ffffffffc0203f3c:	00002617          	auipc	a2,0x2
ffffffffc0203f40:	28460613          	addi	a2,a2,644 # ffffffffc02061c0 <error_string+0xe8>
ffffffffc0203f44:	85a6                	mv	a1,s1
ffffffffc0203f46:	854a                	mv	a0,s2
ffffffffc0203f48:	240000ef          	jal	ra,ffffffffc0204188 <printfmt>
ffffffffc0203f4c:	b729                	j	ffffffffc0203e56 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203f4e:	00144603          	lbu	a2,1(s0)
ffffffffc0203f52:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f54:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203f56:	bf3d                	j	ffffffffc0203e94 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203f58:	4705                	li	a4,1
ffffffffc0203f5a:	008a8593          	addi	a1,s5,8
ffffffffc0203f5e:	01074463          	blt	a4,a6,ffffffffc0203f66 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203f62:	1e080263          	beqz	a6,ffffffffc0204146 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203f66:	000ab603          	ld	a2,0(s5)
ffffffffc0203f6a:	46a1                	li	a3,8
ffffffffc0203f6c:	8aae                	mv	s5,a1
ffffffffc0203f6e:	a839                	j	ffffffffc0203f8c <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0203f70:	03000513          	li	a0,48
ffffffffc0203f74:	85a6                	mv	a1,s1
ffffffffc0203f76:	e03e                	sd	a5,0(sp)
ffffffffc0203f78:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203f7a:	85a6                	mv	a1,s1
ffffffffc0203f7c:	07800513          	li	a0,120
ffffffffc0203f80:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203f82:	0aa1                	addi	s5,s5,8
ffffffffc0203f84:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203f88:	6782                	ld	a5,0(sp)
ffffffffc0203f8a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203f8c:	876e                	mv	a4,s11
ffffffffc0203f8e:	85a6                	mv	a1,s1
ffffffffc0203f90:	854a                	mv	a0,s2
ffffffffc0203f92:	e1fff0ef          	jal	ra,ffffffffc0203db0 <printnum>
            break;
ffffffffc0203f96:	b5c1                	j	ffffffffc0203e56 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203f98:	000ab603          	ld	a2,0(s5)
ffffffffc0203f9c:	0aa1                	addi	s5,s5,8
ffffffffc0203f9e:	1c060663          	beqz	a2,ffffffffc020416a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0203fa2:	00160413          	addi	s0,a2,1
ffffffffc0203fa6:	17b05c63          	blez	s11,ffffffffc020411e <vprintfmt+0x302>
ffffffffc0203faa:	02d00593          	li	a1,45
ffffffffc0203fae:	14b79263          	bne	a5,a1,ffffffffc02040f2 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fb2:	00064783          	lbu	a5,0(a2)
ffffffffc0203fb6:	0007851b          	sext.w	a0,a5
ffffffffc0203fba:	c905                	beqz	a0,ffffffffc0203fea <vprintfmt+0x1ce>
ffffffffc0203fbc:	000cc563          	bltz	s9,ffffffffc0203fc6 <vprintfmt+0x1aa>
ffffffffc0203fc0:	3cfd                	addiw	s9,s9,-1
ffffffffc0203fc2:	036c8263          	beq	s9,s6,ffffffffc0203fe6 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0203fc6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203fc8:	18098463          	beqz	s3,ffffffffc0204150 <vprintfmt+0x334>
ffffffffc0203fcc:	3781                	addiw	a5,a5,-32
ffffffffc0203fce:	18fbf163          	bleu	a5,s7,ffffffffc0204150 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0203fd2:	03f00513          	li	a0,63
ffffffffc0203fd6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fd8:	0405                	addi	s0,s0,1
ffffffffc0203fda:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203fde:	3dfd                	addiw	s11,s11,-1
ffffffffc0203fe0:	0007851b          	sext.w	a0,a5
ffffffffc0203fe4:	fd61                	bnez	a0,ffffffffc0203fbc <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0203fe6:	e7b058e3          	blez	s11,ffffffffc0203e56 <vprintfmt+0x3a>
ffffffffc0203fea:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203fec:	85a6                	mv	a1,s1
ffffffffc0203fee:	02000513          	li	a0,32
ffffffffc0203ff2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203ff4:	e60d81e3          	beqz	s11,ffffffffc0203e56 <vprintfmt+0x3a>
ffffffffc0203ff8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203ffa:	85a6                	mv	a1,s1
ffffffffc0203ffc:	02000513          	li	a0,32
ffffffffc0204000:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204002:	fe0d94e3          	bnez	s11,ffffffffc0203fea <vprintfmt+0x1ce>
ffffffffc0204006:	bd81                	j	ffffffffc0203e56 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204008:	4705                	li	a4,1
ffffffffc020400a:	008a8593          	addi	a1,s5,8
ffffffffc020400e:	01074463          	blt	a4,a6,ffffffffc0204016 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204012:	12080063          	beqz	a6,ffffffffc0204132 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204016:	000ab603          	ld	a2,0(s5)
ffffffffc020401a:	46a9                	li	a3,10
ffffffffc020401c:	8aae                	mv	s5,a1
ffffffffc020401e:	b7bd                	j	ffffffffc0203f8c <vprintfmt+0x170>
ffffffffc0204020:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204024:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204028:	846a                	mv	s0,s10
ffffffffc020402a:	b5ad                	j	ffffffffc0203e94 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020402c:	85a6                	mv	a1,s1
ffffffffc020402e:	02500513          	li	a0,37
ffffffffc0204032:	9902                	jalr	s2
            break;
ffffffffc0204034:	b50d                	j	ffffffffc0203e56 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204036:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020403a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020403e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204040:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204042:	e40dd9e3          	bgez	s11,ffffffffc0203e94 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204046:	8de6                	mv	s11,s9
ffffffffc0204048:	5cfd                	li	s9,-1
ffffffffc020404a:	b5a9                	j	ffffffffc0203e94 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020404c:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204050:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204054:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204056:	bd3d                	j	ffffffffc0203e94 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204058:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020405c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204060:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204062:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204066:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020406a:	fcd56ce3          	bltu	a0,a3,ffffffffc0204042 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020406e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204070:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204074:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204078:	0196873b          	addw	a4,a3,s9
ffffffffc020407c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204080:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204084:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204088:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020408c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204090:	fcd57fe3          	bleu	a3,a0,ffffffffc020406e <vprintfmt+0x252>
ffffffffc0204094:	b77d                	j	ffffffffc0204042 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204096:	fffdc693          	not	a3,s11
ffffffffc020409a:	96fd                	srai	a3,a3,0x3f
ffffffffc020409c:	00ddfdb3          	and	s11,s11,a3
ffffffffc02040a0:	00144603          	lbu	a2,1(s0)
ffffffffc02040a4:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040a6:	846a                	mv	s0,s10
ffffffffc02040a8:	b3f5                	j	ffffffffc0203e94 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02040aa:	85a6                	mv	a1,s1
ffffffffc02040ac:	02500513          	li	a0,37
ffffffffc02040b0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040b2:	fff44703          	lbu	a4,-1(s0)
ffffffffc02040b6:	02500793          	li	a5,37
ffffffffc02040ba:	8d22                	mv	s10,s0
ffffffffc02040bc:	d8f70de3          	beq	a4,a5,ffffffffc0203e56 <vprintfmt+0x3a>
ffffffffc02040c0:	02500713          	li	a4,37
ffffffffc02040c4:	1d7d                	addi	s10,s10,-1
ffffffffc02040c6:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02040ca:	fee79de3          	bne	a5,a4,ffffffffc02040c4 <vprintfmt+0x2a8>
ffffffffc02040ce:	b361                	j	ffffffffc0203e56 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02040d0:	00002617          	auipc	a2,0x2
ffffffffc02040d4:	0e060613          	addi	a2,a2,224 # ffffffffc02061b0 <error_string+0xd8>
ffffffffc02040d8:	85a6                	mv	a1,s1
ffffffffc02040da:	854a                	mv	a0,s2
ffffffffc02040dc:	0ac000ef          	jal	ra,ffffffffc0204188 <printfmt>
ffffffffc02040e0:	bb9d                	j	ffffffffc0203e56 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02040e2:	00002617          	auipc	a2,0x2
ffffffffc02040e6:	0c660613          	addi	a2,a2,198 # ffffffffc02061a8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02040ea:	00002417          	auipc	s0,0x2
ffffffffc02040ee:	0bf40413          	addi	s0,s0,191 # ffffffffc02061a9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02040f2:	8532                	mv	a0,a2
ffffffffc02040f4:	85e6                	mv	a1,s9
ffffffffc02040f6:	e032                	sd	a2,0(sp)
ffffffffc02040f8:	e43e                	sd	a5,8(sp)
ffffffffc02040fa:	18a000ef          	jal	ra,ffffffffc0204284 <strnlen>
ffffffffc02040fe:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204102:	6602                	ld	a2,0(sp)
ffffffffc0204104:	01b05d63          	blez	s11,ffffffffc020411e <vprintfmt+0x302>
ffffffffc0204108:	67a2                	ld	a5,8(sp)
ffffffffc020410a:	2781                	sext.w	a5,a5
ffffffffc020410c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020410e:	6522                	ld	a0,8(sp)
ffffffffc0204110:	85a6                	mv	a1,s1
ffffffffc0204112:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204114:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204116:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204118:	6602                	ld	a2,0(sp)
ffffffffc020411a:	fe0d9ae3          	bnez	s11,ffffffffc020410e <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020411e:	00064783          	lbu	a5,0(a2)
ffffffffc0204122:	0007851b          	sext.w	a0,a5
ffffffffc0204126:	e8051be3          	bnez	a0,ffffffffc0203fbc <vprintfmt+0x1a0>
ffffffffc020412a:	b335                	j	ffffffffc0203e56 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020412c:	000aa403          	lw	s0,0(s5)
ffffffffc0204130:	bbf1                	j	ffffffffc0203f0c <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204132:	000ae603          	lwu	a2,0(s5)
ffffffffc0204136:	46a9                	li	a3,10
ffffffffc0204138:	8aae                	mv	s5,a1
ffffffffc020413a:	bd89                	j	ffffffffc0203f8c <vprintfmt+0x170>
ffffffffc020413c:	000ae603          	lwu	a2,0(s5)
ffffffffc0204140:	46c1                	li	a3,16
ffffffffc0204142:	8aae                	mv	s5,a1
ffffffffc0204144:	b5a1                	j	ffffffffc0203f8c <vprintfmt+0x170>
ffffffffc0204146:	000ae603          	lwu	a2,0(s5)
ffffffffc020414a:	46a1                	li	a3,8
ffffffffc020414c:	8aae                	mv	s5,a1
ffffffffc020414e:	bd3d                	j	ffffffffc0203f8c <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204150:	9902                	jalr	s2
ffffffffc0204152:	b559                	j	ffffffffc0203fd8 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204154:	85a6                	mv	a1,s1
ffffffffc0204156:	02d00513          	li	a0,45
ffffffffc020415a:	e03e                	sd	a5,0(sp)
ffffffffc020415c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020415e:	8ace                	mv	s5,s3
ffffffffc0204160:	40800633          	neg	a2,s0
ffffffffc0204164:	46a9                	li	a3,10
ffffffffc0204166:	6782                	ld	a5,0(sp)
ffffffffc0204168:	b515                	j	ffffffffc0203f8c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020416a:	01b05663          	blez	s11,ffffffffc0204176 <vprintfmt+0x35a>
ffffffffc020416e:	02d00693          	li	a3,45
ffffffffc0204172:	f6d798e3          	bne	a5,a3,ffffffffc02040e2 <vprintfmt+0x2c6>
ffffffffc0204176:	00002417          	auipc	s0,0x2
ffffffffc020417a:	03340413          	addi	s0,s0,51 # ffffffffc02061a9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020417e:	02800513          	li	a0,40
ffffffffc0204182:	02800793          	li	a5,40
ffffffffc0204186:	bd1d                	j	ffffffffc0203fbc <vprintfmt+0x1a0>

ffffffffc0204188 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204188:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020418a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020418e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204190:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204192:	ec06                	sd	ra,24(sp)
ffffffffc0204194:	f83a                	sd	a4,48(sp)
ffffffffc0204196:	fc3e                	sd	a5,56(sp)
ffffffffc0204198:	e0c2                	sd	a6,64(sp)
ffffffffc020419a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020419c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020419e:	c7fff0ef          	jal	ra,ffffffffc0203e1c <vprintfmt>
}
ffffffffc02041a2:	60e2                	ld	ra,24(sp)
ffffffffc02041a4:	6161                	addi	sp,sp,80
ffffffffc02041a6:	8082                	ret

ffffffffc02041a8 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02041a8:	715d                	addi	sp,sp,-80
ffffffffc02041aa:	e486                	sd	ra,72(sp)
ffffffffc02041ac:	e0a2                	sd	s0,64(sp)
ffffffffc02041ae:	fc26                	sd	s1,56(sp)
ffffffffc02041b0:	f84a                	sd	s2,48(sp)
ffffffffc02041b2:	f44e                	sd	s3,40(sp)
ffffffffc02041b4:	f052                	sd	s4,32(sp)
ffffffffc02041b6:	ec56                	sd	s5,24(sp)
ffffffffc02041b8:	e85a                	sd	s6,16(sp)
ffffffffc02041ba:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02041bc:	c901                	beqz	a0,ffffffffc02041cc <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02041be:	85aa                	mv	a1,a0
ffffffffc02041c0:	00002517          	auipc	a0,0x2
ffffffffc02041c4:	00050513          	mv	a0,a0
ffffffffc02041c8:	f01fb0ef          	jal	ra,ffffffffc02000c8 <cprintf>
readline(const char *prompt) {
ffffffffc02041cc:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041ce:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02041d0:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02041d2:	4aa9                	li	s5,10
ffffffffc02041d4:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02041d6:	0000db97          	auipc	s7,0xd
ffffffffc02041da:	e6ab8b93          	addi	s7,s7,-406 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041de:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02041e2:	f1ffb0ef          	jal	ra,ffffffffc0200100 <getchar>
ffffffffc02041e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02041e8:	00054b63          	bltz	a0,ffffffffc02041fe <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041ec:	00a95b63          	ble	a0,s2,ffffffffc0204202 <readline+0x5a>
ffffffffc02041f0:	029a5463          	ble	s1,s4,ffffffffc0204218 <readline+0x70>
        c = getchar();
ffffffffc02041f4:	f0dfb0ef          	jal	ra,ffffffffc0200100 <getchar>
ffffffffc02041f8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02041fa:	fe0559e3          	bgez	a0,ffffffffc02041ec <readline+0x44>
            return NULL;
ffffffffc02041fe:	4501                	li	a0,0
ffffffffc0204200:	a099                	j	ffffffffc0204246 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0204202:	03341463          	bne	s0,s3,ffffffffc020422a <readline+0x82>
ffffffffc0204206:	e8b9                	bnez	s1,ffffffffc020425c <readline+0xb4>
        c = getchar();
ffffffffc0204208:	ef9fb0ef          	jal	ra,ffffffffc0200100 <getchar>
ffffffffc020420c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020420e:	fe0548e3          	bltz	a0,ffffffffc02041fe <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204212:	fea958e3          	ble	a0,s2,ffffffffc0204202 <readline+0x5a>
ffffffffc0204216:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204218:	8522                	mv	a0,s0
ffffffffc020421a:	ee3fb0ef          	jal	ra,ffffffffc02000fc <cputchar>
            buf[i ++] = c;
ffffffffc020421e:	009b87b3          	add	a5,s7,s1
ffffffffc0204222:	00878023          	sb	s0,0(a5)
ffffffffc0204226:	2485                	addiw	s1,s1,1
ffffffffc0204228:	bf6d                	j	ffffffffc02041e2 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020422a:	01540463          	beq	s0,s5,ffffffffc0204232 <readline+0x8a>
ffffffffc020422e:	fb641ae3          	bne	s0,s6,ffffffffc02041e2 <readline+0x3a>
            cputchar(c);
ffffffffc0204232:	8522                	mv	a0,s0
ffffffffc0204234:	ec9fb0ef          	jal	ra,ffffffffc02000fc <cputchar>
            buf[i] = '\0';
ffffffffc0204238:	0000d517          	auipc	a0,0xd
ffffffffc020423c:	e0850513          	addi	a0,a0,-504 # ffffffffc0211040 <buf>
ffffffffc0204240:	94aa                	add	s1,s1,a0
ffffffffc0204242:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204246:	60a6                	ld	ra,72(sp)
ffffffffc0204248:	6406                	ld	s0,64(sp)
ffffffffc020424a:	74e2                	ld	s1,56(sp)
ffffffffc020424c:	7942                	ld	s2,48(sp)
ffffffffc020424e:	79a2                	ld	s3,40(sp)
ffffffffc0204250:	7a02                	ld	s4,32(sp)
ffffffffc0204252:	6ae2                	ld	s5,24(sp)
ffffffffc0204254:	6b42                	ld	s6,16(sp)
ffffffffc0204256:	6ba2                	ld	s7,8(sp)
ffffffffc0204258:	6161                	addi	sp,sp,80
ffffffffc020425a:	8082                	ret
            cputchar(c);
ffffffffc020425c:	4521                	li	a0,8
ffffffffc020425e:	e9ffb0ef          	jal	ra,ffffffffc02000fc <cputchar>
            i --;
ffffffffc0204262:	34fd                	addiw	s1,s1,-1
ffffffffc0204264:	bfbd                	j	ffffffffc02041e2 <readline+0x3a>

ffffffffc0204266 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204266:	00054783          	lbu	a5,0(a0)
ffffffffc020426a:	cb91                	beqz	a5,ffffffffc020427e <strlen+0x18>
    size_t cnt = 0;
ffffffffc020426c:	4781                	li	a5,0
        cnt ++;
ffffffffc020426e:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204270:	00f50733          	add	a4,a0,a5
ffffffffc0204274:	00074703          	lbu	a4,0(a4)
ffffffffc0204278:	fb7d                	bnez	a4,ffffffffc020426e <strlen+0x8>
    }
    return cnt;
}
ffffffffc020427a:	853e                	mv	a0,a5
ffffffffc020427c:	8082                	ret
    size_t cnt = 0;
ffffffffc020427e:	4781                	li	a5,0
}
ffffffffc0204280:	853e                	mv	a0,a5
ffffffffc0204282:	8082                	ret

ffffffffc0204284 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204284:	c185                	beqz	a1,ffffffffc02042a4 <strnlen+0x20>
ffffffffc0204286:	00054783          	lbu	a5,0(a0)
ffffffffc020428a:	cf89                	beqz	a5,ffffffffc02042a4 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020428c:	4781                	li	a5,0
ffffffffc020428e:	a021                	j	ffffffffc0204296 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204290:	00074703          	lbu	a4,0(a4)
ffffffffc0204294:	c711                	beqz	a4,ffffffffc02042a0 <strnlen+0x1c>
        cnt ++;
ffffffffc0204296:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204298:	00f50733          	add	a4,a0,a5
ffffffffc020429c:	fef59ae3          	bne	a1,a5,ffffffffc0204290 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02042a0:	853e                	mv	a0,a5
ffffffffc02042a2:	8082                	ret
    size_t cnt = 0;
ffffffffc02042a4:	4781                	li	a5,0
}
ffffffffc02042a6:	853e                	mv	a0,a5
ffffffffc02042a8:	8082                	ret

ffffffffc02042aa <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02042aa:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02042ac:	0585                	addi	a1,a1,1
ffffffffc02042ae:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02042b2:	0785                	addi	a5,a5,1
ffffffffc02042b4:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02042b8:	fb75                	bnez	a4,ffffffffc02042ac <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02042ba:	8082                	ret

ffffffffc02042bc <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042bc:	00054783          	lbu	a5,0(a0)
ffffffffc02042c0:	0005c703          	lbu	a4,0(a1)
ffffffffc02042c4:	cb91                	beqz	a5,ffffffffc02042d8 <strcmp+0x1c>
ffffffffc02042c6:	00e79c63          	bne	a5,a4,ffffffffc02042de <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02042ca:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042cc:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02042d0:	0585                	addi	a1,a1,1
ffffffffc02042d2:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042d6:	fbe5                	bnez	a5,ffffffffc02042c6 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02042d8:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02042da:	9d19                	subw	a0,a0,a4
ffffffffc02042dc:	8082                	ret
ffffffffc02042de:	0007851b          	sext.w	a0,a5
ffffffffc02042e2:	9d19                	subw	a0,a0,a4
ffffffffc02042e4:	8082                	ret

ffffffffc02042e6 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02042e6:	00054783          	lbu	a5,0(a0)
ffffffffc02042ea:	cb91                	beqz	a5,ffffffffc02042fe <strchr+0x18>
        if (*s == c) {
ffffffffc02042ec:	00b79563          	bne	a5,a1,ffffffffc02042f6 <strchr+0x10>
ffffffffc02042f0:	a809                	j	ffffffffc0204302 <strchr+0x1c>
ffffffffc02042f2:	00b78763          	beq	a5,a1,ffffffffc0204300 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02042f6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02042f8:	00054783          	lbu	a5,0(a0)
ffffffffc02042fc:	fbfd                	bnez	a5,ffffffffc02042f2 <strchr+0xc>
    }
    return NULL;
ffffffffc02042fe:	4501                	li	a0,0
}
ffffffffc0204300:	8082                	ret
ffffffffc0204302:	8082                	ret

ffffffffc0204304 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204304:	ca01                	beqz	a2,ffffffffc0204314 <memset+0x10>
ffffffffc0204306:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204308:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020430a:	0785                	addi	a5,a5,1
ffffffffc020430c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204310:	fec79de3          	bne	a5,a2,ffffffffc020430a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204314:	8082                	ret

ffffffffc0204316 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204316:	ca19                	beqz	a2,ffffffffc020432c <memcpy+0x16>
ffffffffc0204318:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020431a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020431c:	0585                	addi	a1,a1,1
ffffffffc020431e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204322:	0785                	addi	a5,a5,1
ffffffffc0204324:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204328:	fec59ae3          	bne	a1,a2,ffffffffc020431c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020432c:	8082                	ret
