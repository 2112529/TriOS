
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02082b7          	lui	t0,0xc0208
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
ffffffffc0200028:	c0208137          	lui	sp,0xc0208

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
ffffffffc0200036:	00009517          	auipc	a0,0x9
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc0209040 <edata>
ffffffffc020003e:	00010617          	auipc	a2,0x10
ffffffffc0200042:	55a60613          	addi	a2,a2,1370 # ffffffffc0210598 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	060040ef          	jal	ra,ffffffffc02040ae <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	08658593          	addi	a1,a1,134 # ffffffffc02040d8 <etext>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	09e50513          	addi	a0,a0,158 # ffffffffc02040f8 <etext+0x20>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	0a0000ef          	jal	ra,ffffffffc0200106 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	28d010ef          	jal	ra,ffffffffc0201af6 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	4e0000ef          	jal	ra,ffffffffc020054e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	41c030ef          	jal	ra,ffffffffc020348e <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	426000ef          	jal	ra,ffffffffc020049c <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	772020ef          	jal	ra,ffffffffc02027ec <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	356000ef          	jal	ra,ffffffffc02003d4 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
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
ffffffffc02000b2:	315030ef          	jal	ra,ffffffffc0203bc6 <vprintfmt>
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
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0208028 <boot_page_table_sv39+0x28>
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
ffffffffc02000e6:	2e1030ef          	jal	ra,ffffffffc0203bc6 <vprintfmt>
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
ffffffffc020010c:	02850513          	addi	a0,a0,40 # ffffffffc0204130 <etext+0x58>
void print_kerninfo(void) {
ffffffffc0200110:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200112:	fadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200116:	00000597          	auipc	a1,0x0
ffffffffc020011a:	f2058593          	addi	a1,a1,-224 # ffffffffc0200036 <kern_init>
ffffffffc020011e:	00004517          	auipc	a0,0x4
ffffffffc0200122:	03250513          	addi	a0,a0,50 # ffffffffc0204150 <etext+0x78>
ffffffffc0200126:	f99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020012a:	00004597          	auipc	a1,0x4
ffffffffc020012e:	fae58593          	addi	a1,a1,-82 # ffffffffc02040d8 <etext>
ffffffffc0200132:	00004517          	auipc	a0,0x4
ffffffffc0200136:	03e50513          	addi	a0,a0,62 # ffffffffc0204170 <etext+0x98>
ffffffffc020013a:	f85ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013e:	00009597          	auipc	a1,0x9
ffffffffc0200142:	f0258593          	addi	a1,a1,-254 # ffffffffc0209040 <edata>
ffffffffc0200146:	00004517          	auipc	a0,0x4
ffffffffc020014a:	04a50513          	addi	a0,a0,74 # ffffffffc0204190 <etext+0xb8>
ffffffffc020014e:	f71ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200152:	00010597          	auipc	a1,0x10
ffffffffc0200156:	44658593          	addi	a1,a1,1094 # ffffffffc0210598 <end>
ffffffffc020015a:	00004517          	auipc	a0,0x4
ffffffffc020015e:	05650513          	addi	a0,a0,86 # ffffffffc02041b0 <etext+0xd8>
ffffffffc0200162:	f5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200166:	00011597          	auipc	a1,0x11
ffffffffc020016a:	83158593          	addi	a1,a1,-1999 # ffffffffc0210997 <end+0x3ff>
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
ffffffffc020018c:	04850513          	addi	a0,a0,72 # ffffffffc02041d0 <etext+0xf8>
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
ffffffffc020019c:	f6860613          	addi	a2,a2,-152 # ffffffffc0204100 <etext+0x28>
ffffffffc02001a0:	04e00593          	li	a1,78
ffffffffc02001a4:	00004517          	auipc	a0,0x4
ffffffffc02001a8:	f7450513          	addi	a0,a0,-140 # ffffffffc0204118 <etext+0x40>
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
ffffffffc02001b8:	12460613          	addi	a2,a2,292 # ffffffffc02042d8 <commands+0xd8>
ffffffffc02001bc:	00004597          	auipc	a1,0x4
ffffffffc02001c0:	13c58593          	addi	a1,a1,316 # ffffffffc02042f8 <commands+0xf8>
ffffffffc02001c4:	00004517          	auipc	a0,0x4
ffffffffc02001c8:	13c50513          	addi	a0,a0,316 # ffffffffc0204300 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ce:	ef1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001d2:	00004617          	auipc	a2,0x4
ffffffffc02001d6:	13e60613          	addi	a2,a2,318 # ffffffffc0204310 <commands+0x110>
ffffffffc02001da:	00004597          	auipc	a1,0x4
ffffffffc02001de:	15e58593          	addi	a1,a1,350 # ffffffffc0204338 <commands+0x138>
ffffffffc02001e2:	00004517          	auipc	a0,0x4
ffffffffc02001e6:	11e50513          	addi	a0,a0,286 # ffffffffc0204300 <commands+0x100>
ffffffffc02001ea:	ed5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	15a60613          	addi	a2,a2,346 # ffffffffc0204348 <commands+0x148>
ffffffffc02001f6:	00004597          	auipc	a1,0x4
ffffffffc02001fa:	17258593          	addi	a1,a1,370 # ffffffffc0204368 <commands+0x168>
ffffffffc02001fe:	00004517          	auipc	a0,0x4
ffffffffc0200202:	10250513          	addi	a0,a0,258 # ffffffffc0204300 <commands+0x100>
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
ffffffffc020023c:	01050513          	addi	a0,a0,16 # ffffffffc0204248 <commands+0x48>
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
ffffffffc020025e:	01650513          	addi	a0,a0,22 # ffffffffc0204270 <commands+0x70>
ffffffffc0200262:	e5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc0200266:	000c0563          	beqz	s8,ffffffffc0200270 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020026a:	8562                	mv	a0,s8
ffffffffc020026c:	4ce000ef          	jal	ra,ffffffffc020073a <print_trapframe>
ffffffffc0200270:	00004c97          	auipc	s9,0x4
ffffffffc0200274:	f90c8c93          	addi	s9,s9,-112 # ffffffffc0204200 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200278:	00005997          	auipc	s3,0x5
ffffffffc020027c:	4d098993          	addi	s3,s3,1232 # ffffffffc0205748 <default_pmm_manager+0x940>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200280:	00004917          	auipc	s2,0x4
ffffffffc0200284:	01890913          	addi	s2,s2,24 # ffffffffc0204298 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200288:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020028a:	00004b17          	auipc	s6,0x4
ffffffffc020028e:	016b0b13          	addi	s6,s6,22 # ffffffffc02042a0 <commands+0xa0>
    if (argc == 0) {
ffffffffc0200292:	00004a97          	auipc	s5,0x4
ffffffffc0200296:	066a8a93          	addi	s5,s5,102 # ffffffffc02042f8 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020029a:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc020029c:	854e                	mv	a0,s3
ffffffffc020029e:	4b5030ef          	jal	ra,ffffffffc0203f52 <readline>
ffffffffc02002a2:	842a                	mv	s0,a0
ffffffffc02002a4:	dd65                	beqz	a0,ffffffffc020029c <kmonitor+0x6a>
ffffffffc02002a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002aa:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ac:	c999                	beqz	a1,ffffffffc02002c2 <kmonitor+0x90>
ffffffffc02002ae:	854a                	mv	a0,s2
ffffffffc02002b0:	5e1030ef          	jal	ra,ffffffffc0204090 <strchr>
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
ffffffffc02002ca:	f3ad0d13          	addi	s10,s10,-198 # ffffffffc0204200 <commands>
    if (argc == 0) {
ffffffffc02002ce:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d2:	0d61                	addi	s10,s10,24
ffffffffc02002d4:	593030ef          	jal	ra,ffffffffc0204066 <strcmp>
ffffffffc02002d8:	c919                	beqz	a0,ffffffffc02002ee <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002da:	2405                	addiw	s0,s0,1
ffffffffc02002dc:	09740463          	beq	s0,s7,ffffffffc0200364 <kmonitor+0x132>
ffffffffc02002e0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	0d61                	addi	s10,s10,24
ffffffffc02002e8:	57f030ef          	jal	ra,ffffffffc0204066 <strcmp>
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
ffffffffc020034e:	543030ef          	jal	ra,ffffffffc0204090 <strchr>
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
ffffffffc020036a:	f5a50513          	addi	a0,a0,-166 # ffffffffc02042c0 <commands+0xc0>
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
ffffffffc0200374:	00010317          	auipc	t1,0x10
ffffffffc0200378:	0cc30313          	addi	t1,t1,204 # ffffffffc0210440 <is_panic>
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
ffffffffc0200398:	00010717          	auipc	a4,0x10
ffffffffc020039c:	0af72423          	sw	a5,168(a4) # ffffffffc0210440 <is_panic>

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
ffffffffc02003aa:	fd250513          	addi	a0,a0,-46 # ffffffffc0204378 <commands+0x178>
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
ffffffffc02003c0:	f3450513          	addi	a0,a0,-204 # ffffffffc02052f0 <default_pmm_manager+0x4e8>
ffffffffc02003c4:	cfbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c8:	10e000ef          	jal	ra,ffffffffc02004d6 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003cc:	4501                	li	a0,0
ffffffffc02003ce:	e65ff0ef          	jal	ra,ffffffffc0200232 <kmonitor>
ffffffffc02003d2:	bfed                	j	ffffffffc02003cc <__panic+0x58>

ffffffffc02003d4 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d4:	67e1                	lui	a5,0x18
ffffffffc02003d6:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02003da:	00010717          	auipc	a4,0x10
ffffffffc02003de:	06f73723          	sd	a5,110(a4) # ffffffffc0210448 <timebase>
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
ffffffffc02003fe:	f9e50513          	addi	a0,a0,-98 # ffffffffc0204398 <commands+0x198>
    ticks = 0;
ffffffffc0200402:	00010797          	auipc	a5,0x10
ffffffffc0200406:	0607b723          	sd	zero,110(a5) # ffffffffc0210470 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020040a:	cb5ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020040e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020040e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200412:	00010797          	auipc	a5,0x10
ffffffffc0200416:	03678793          	addi	a5,a5,54 # ffffffffc0210448 <timebase>
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
ffffffffc0200448:	08e000ef          	jal	ra,ffffffffc02004d6 <intr_disable>
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
ffffffffc020045c:	0740006f          	j	ffffffffc02004d0 <intr_enable>

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
ffffffffc020047c:	05a000ef          	jal	ra,ffffffffc02004d6 <intr_disable>
ffffffffc0200480:	4501                	li	a0,0
ffffffffc0200482:	4581                	li	a1,0
ffffffffc0200484:	4601                	li	a2,0
ffffffffc0200486:	4889                	li	a7,2
ffffffffc0200488:	00000073          	ecall
ffffffffc020048c:	2501                	sext.w	a0,a0
ffffffffc020048e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200490:	040000ef          	jal	ra,ffffffffc02004d0 <intr_enable>
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

ffffffffc02004aa <ide_write_secs>:
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004aa:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ac:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004b0:	00009517          	auipc	a0,0x9
ffffffffc02004b4:	b9050513          	addi	a0,a0,-1136 # ffffffffc0209040 <edata>
                   size_t nsecs) {
ffffffffc02004b8:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ba:	00969613          	slli	a2,a3,0x9
ffffffffc02004be:	85ba                	mv	a1,a4
ffffffffc02004c0:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004c2:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c4:	3fd030ef          	jal	ra,ffffffffc02040c0 <memcpy>
    return 0;
}
ffffffffc02004c8:	60a2                	ld	ra,8(sp)
ffffffffc02004ca:	4501                	li	a0,0
ffffffffc02004cc:	0141                	addi	sp,sp,16
ffffffffc02004ce:	8082                	ret

ffffffffc02004d0 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004d0:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004d4:	8082                	ret

ffffffffc02004d6 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004d6:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004da:	8082                	ret

ffffffffc02004dc <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004dc:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004e0:	1141                	addi	sp,sp,-16
ffffffffc02004e2:	e022                	sd	s0,0(sp)
ffffffffc02004e4:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004e6:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004ea:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004ec:	11053583          	ld	a1,272(a0)
ffffffffc02004f0:	05500613          	li	a2,85
ffffffffc02004f4:	c399                	beqz	a5,ffffffffc02004fa <pgfault_handler+0x1e>
ffffffffc02004f6:	04b00613          	li	a2,75
ffffffffc02004fa:	11843703          	ld	a4,280(s0)
ffffffffc02004fe:	47bd                	li	a5,15
ffffffffc0200500:	05700693          	li	a3,87
ffffffffc0200504:	00f70463          	beq	a4,a5,ffffffffc020050c <pgfault_handler+0x30>
ffffffffc0200508:	05200693          	li	a3,82
ffffffffc020050c:	00004517          	auipc	a0,0x4
ffffffffc0200510:	18450513          	addi	a0,a0,388 # ffffffffc0204690 <commands+0x490>
ffffffffc0200514:	babff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200518:	00010797          	auipc	a5,0x10
ffffffffc020051c:	07878793          	addi	a5,a5,120 # ffffffffc0210590 <check_mm_struct>
ffffffffc0200520:	6388                	ld	a0,0(a5)
ffffffffc0200522:	c911                	beqz	a0,ffffffffc0200536 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200524:	11043603          	ld	a2,272(s0)
ffffffffc0200528:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc020052c:	6402                	ld	s0,0(sp)
ffffffffc020052e:	60a2                	ld	ra,8(sp)
ffffffffc0200530:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200532:	49a0306f          	j	ffffffffc02039cc <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200536:	00004617          	auipc	a2,0x4
ffffffffc020053a:	17a60613          	addi	a2,a2,378 # ffffffffc02046b0 <commands+0x4b0>
ffffffffc020053e:	07800593          	li	a1,120
ffffffffc0200542:	00004517          	auipc	a0,0x4
ffffffffc0200546:	18650513          	addi	a0,a0,390 # ffffffffc02046c8 <commands+0x4c8>
ffffffffc020054a:	e2bff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020054e <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020054e:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200552:	00000797          	auipc	a5,0x0
ffffffffc0200556:	49e78793          	addi	a5,a5,1182 # ffffffffc02009f0 <__alltraps>
ffffffffc020055a:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc020055e:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200562:	000407b7          	lui	a5,0x40
ffffffffc0200566:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020056a:	8082                	ret

ffffffffc020056c <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020056c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020056e:	1141                	addi	sp,sp,-16
ffffffffc0200570:	e022                	sd	s0,0(sp)
ffffffffc0200572:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200574:	00004517          	auipc	a0,0x4
ffffffffc0200578:	16c50513          	addi	a0,a0,364 # ffffffffc02046e0 <commands+0x4e0>
void print_regs(struct pushregs *gpr) {
ffffffffc020057c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020057e:	b41ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200582:	640c                	ld	a1,8(s0)
ffffffffc0200584:	00004517          	auipc	a0,0x4
ffffffffc0200588:	17450513          	addi	a0,a0,372 # ffffffffc02046f8 <commands+0x4f8>
ffffffffc020058c:	b33ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200590:	680c                	ld	a1,16(s0)
ffffffffc0200592:	00004517          	auipc	a0,0x4
ffffffffc0200596:	17e50513          	addi	a0,a0,382 # ffffffffc0204710 <commands+0x510>
ffffffffc020059a:	b25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020059e:	6c0c                	ld	a1,24(s0)
ffffffffc02005a0:	00004517          	auipc	a0,0x4
ffffffffc02005a4:	18850513          	addi	a0,a0,392 # ffffffffc0204728 <commands+0x528>
ffffffffc02005a8:	b17ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005ac:	700c                	ld	a1,32(s0)
ffffffffc02005ae:	00004517          	auipc	a0,0x4
ffffffffc02005b2:	19250513          	addi	a0,a0,402 # ffffffffc0204740 <commands+0x540>
ffffffffc02005b6:	b09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005ba:	740c                	ld	a1,40(s0)
ffffffffc02005bc:	00004517          	auipc	a0,0x4
ffffffffc02005c0:	19c50513          	addi	a0,a0,412 # ffffffffc0204758 <commands+0x558>
ffffffffc02005c4:	afbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005c8:	780c                	ld	a1,48(s0)
ffffffffc02005ca:	00004517          	auipc	a0,0x4
ffffffffc02005ce:	1a650513          	addi	a0,a0,422 # ffffffffc0204770 <commands+0x570>
ffffffffc02005d2:	aedff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005d6:	7c0c                	ld	a1,56(s0)
ffffffffc02005d8:	00004517          	auipc	a0,0x4
ffffffffc02005dc:	1b050513          	addi	a0,a0,432 # ffffffffc0204788 <commands+0x588>
ffffffffc02005e0:	adfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005e4:	602c                	ld	a1,64(s0)
ffffffffc02005e6:	00004517          	auipc	a0,0x4
ffffffffc02005ea:	1ba50513          	addi	a0,a0,442 # ffffffffc02047a0 <commands+0x5a0>
ffffffffc02005ee:	ad1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02005f2:	642c                	ld	a1,72(s0)
ffffffffc02005f4:	00004517          	auipc	a0,0x4
ffffffffc02005f8:	1c450513          	addi	a0,a0,452 # ffffffffc02047b8 <commands+0x5b8>
ffffffffc02005fc:	ac3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200600:	682c                	ld	a1,80(s0)
ffffffffc0200602:	00004517          	auipc	a0,0x4
ffffffffc0200606:	1ce50513          	addi	a0,a0,462 # ffffffffc02047d0 <commands+0x5d0>
ffffffffc020060a:	ab5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020060e:	6c2c                	ld	a1,88(s0)
ffffffffc0200610:	00004517          	auipc	a0,0x4
ffffffffc0200614:	1d850513          	addi	a0,a0,472 # ffffffffc02047e8 <commands+0x5e8>
ffffffffc0200618:	aa7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020061c:	702c                	ld	a1,96(s0)
ffffffffc020061e:	00004517          	auipc	a0,0x4
ffffffffc0200622:	1e250513          	addi	a0,a0,482 # ffffffffc0204800 <commands+0x600>
ffffffffc0200626:	a99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020062a:	742c                	ld	a1,104(s0)
ffffffffc020062c:	00004517          	auipc	a0,0x4
ffffffffc0200630:	1ec50513          	addi	a0,a0,492 # ffffffffc0204818 <commands+0x618>
ffffffffc0200634:	a8bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200638:	782c                	ld	a1,112(s0)
ffffffffc020063a:	00004517          	auipc	a0,0x4
ffffffffc020063e:	1f650513          	addi	a0,a0,502 # ffffffffc0204830 <commands+0x630>
ffffffffc0200642:	a7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200646:	7c2c                	ld	a1,120(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	20050513          	addi	a0,a0,512 # ffffffffc0204848 <commands+0x648>
ffffffffc0200650:	a6fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200654:	604c                	ld	a1,128(s0)
ffffffffc0200656:	00004517          	auipc	a0,0x4
ffffffffc020065a:	20a50513          	addi	a0,a0,522 # ffffffffc0204860 <commands+0x660>
ffffffffc020065e:	a61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200662:	644c                	ld	a1,136(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	21450513          	addi	a0,a0,532 # ffffffffc0204878 <commands+0x678>
ffffffffc020066c:	a53ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200670:	684c                	ld	a1,144(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	21e50513          	addi	a0,a0,542 # ffffffffc0204890 <commands+0x690>
ffffffffc020067a:	a45ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020067e:	6c4c                	ld	a1,152(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	22850513          	addi	a0,a0,552 # ffffffffc02048a8 <commands+0x6a8>
ffffffffc0200688:	a37ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020068c:	704c                	ld	a1,160(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	23250513          	addi	a0,a0,562 # ffffffffc02048c0 <commands+0x6c0>
ffffffffc0200696:	a29ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020069a:	744c                	ld	a1,168(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	23c50513          	addi	a0,a0,572 # ffffffffc02048d8 <commands+0x6d8>
ffffffffc02006a4:	a1bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006a8:	784c                	ld	a1,176(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	24650513          	addi	a0,a0,582 # ffffffffc02048f0 <commands+0x6f0>
ffffffffc02006b2:	a0dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006b6:	7c4c                	ld	a1,184(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	25050513          	addi	a0,a0,592 # ffffffffc0204908 <commands+0x708>
ffffffffc02006c0:	9ffff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006c4:	606c                	ld	a1,192(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	25a50513          	addi	a0,a0,602 # ffffffffc0204920 <commands+0x720>
ffffffffc02006ce:	9f1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006d2:	646c                	ld	a1,200(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	26450513          	addi	a0,a0,612 # ffffffffc0204938 <commands+0x738>
ffffffffc02006dc:	9e3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006e0:	686c                	ld	a1,208(s0)
ffffffffc02006e2:	00004517          	auipc	a0,0x4
ffffffffc02006e6:	26e50513          	addi	a0,a0,622 # ffffffffc0204950 <commands+0x750>
ffffffffc02006ea:	9d5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02006ee:	6c6c                	ld	a1,216(s0)
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	27850513          	addi	a0,a0,632 # ffffffffc0204968 <commands+0x768>
ffffffffc02006f8:	9c7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02006fc:	706c                	ld	a1,224(s0)
ffffffffc02006fe:	00004517          	auipc	a0,0x4
ffffffffc0200702:	28250513          	addi	a0,a0,642 # ffffffffc0204980 <commands+0x780>
ffffffffc0200706:	9b9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020070a:	746c                	ld	a1,232(s0)
ffffffffc020070c:	00004517          	auipc	a0,0x4
ffffffffc0200710:	28c50513          	addi	a0,a0,652 # ffffffffc0204998 <commands+0x798>
ffffffffc0200714:	9abff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200718:	786c                	ld	a1,240(s0)
ffffffffc020071a:	00004517          	auipc	a0,0x4
ffffffffc020071e:	29650513          	addi	a0,a0,662 # ffffffffc02049b0 <commands+0x7b0>
ffffffffc0200722:	99dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200726:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200728:	6402                	ld	s0,0(sp)
ffffffffc020072a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020072c:	00004517          	auipc	a0,0x4
ffffffffc0200730:	29c50513          	addi	a0,a0,668 # ffffffffc02049c8 <commands+0x7c8>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200736:	989ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020073a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020073a:	1141                	addi	sp,sp,-16
ffffffffc020073c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020073e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200740:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	29e50513          	addi	a0,a0,670 # ffffffffc02049e0 <commands+0x7e0>
void print_trapframe(struct trapframe *tf) {
ffffffffc020074a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020074c:	973ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200750:	8522                	mv	a0,s0
ffffffffc0200752:	e1bff0ef          	jal	ra,ffffffffc020056c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200756:	10043583          	ld	a1,256(s0)
ffffffffc020075a:	00004517          	auipc	a0,0x4
ffffffffc020075e:	29e50513          	addi	a0,a0,670 # ffffffffc02049f8 <commands+0x7f8>
ffffffffc0200762:	95dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200766:	10843583          	ld	a1,264(s0)
ffffffffc020076a:	00004517          	auipc	a0,0x4
ffffffffc020076e:	2a650513          	addi	a0,a0,678 # ffffffffc0204a10 <commands+0x810>
ffffffffc0200772:	94dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200776:	11043583          	ld	a1,272(s0)
ffffffffc020077a:	00004517          	auipc	a0,0x4
ffffffffc020077e:	2ae50513          	addi	a0,a0,686 # ffffffffc0204a28 <commands+0x828>
ffffffffc0200782:	93dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200786:	11843583          	ld	a1,280(s0)
}
ffffffffc020078a:	6402                	ld	s0,0(sp)
ffffffffc020078c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	2b250513          	addi	a0,a0,690 # ffffffffc0204a40 <commands+0x840>
}
ffffffffc0200796:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200798:	927ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020079c <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020079c:	11853783          	ld	a5,280(a0)
ffffffffc02007a0:	577d                	li	a4,-1
ffffffffc02007a2:	8305                	srli	a4,a4,0x1
ffffffffc02007a4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007a6:	472d                	li	a4,11
ffffffffc02007a8:	06f76f63          	bltu	a4,a5,ffffffffc0200826 <interrupt_handler+0x8a>
ffffffffc02007ac:	00004717          	auipc	a4,0x4
ffffffffc02007b0:	c0870713          	addi	a4,a4,-1016 # ffffffffc02043b4 <commands+0x1b4>
ffffffffc02007b4:	078a                	slli	a5,a5,0x2
ffffffffc02007b6:	97ba                	add	a5,a5,a4
ffffffffc02007b8:	439c                	lw	a5,0(a5)
ffffffffc02007ba:	97ba                	add	a5,a5,a4
ffffffffc02007bc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007be:	00004517          	auipc	a0,0x4
ffffffffc02007c2:	e8250513          	addi	a0,a0,-382 # ffffffffc0204640 <commands+0x440>
ffffffffc02007c6:	8f9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ca:	00004517          	auipc	a0,0x4
ffffffffc02007ce:	e5650513          	addi	a0,a0,-426 # ffffffffc0204620 <commands+0x420>
ffffffffc02007d2:	8edff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007d6:	00004517          	auipc	a0,0x4
ffffffffc02007da:	e0a50513          	addi	a0,a0,-502 # ffffffffc02045e0 <commands+0x3e0>
ffffffffc02007de:	8e1ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	e1e50513          	addi	a0,a0,-482 # ffffffffc0204600 <commands+0x400>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	e8250513          	addi	a0,a0,-382 # ffffffffc0204670 <commands+0x470>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02007fa:	1141                	addi	sp,sp,-16
ffffffffc02007fc:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02007fe:	c11ff0ef          	jal	ra,ffffffffc020040e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200802:	00010797          	auipc	a5,0x10
ffffffffc0200806:	c6e78793          	addi	a5,a5,-914 # ffffffffc0210470 <ticks>
ffffffffc020080a:	639c                	ld	a5,0(a5)
ffffffffc020080c:	06400713          	li	a4,100
ffffffffc0200810:	0785                	addi	a5,a5,1
ffffffffc0200812:	02e7f733          	remu	a4,a5,a4
ffffffffc0200816:	00010697          	auipc	a3,0x10
ffffffffc020081a:	c4f6bd23          	sd	a5,-934(a3) # ffffffffc0210470 <ticks>
ffffffffc020081e:	c711                	beqz	a4,ffffffffc020082a <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200820:	60a2                	ld	ra,8(sp)
ffffffffc0200822:	0141                	addi	sp,sp,16
ffffffffc0200824:	8082                	ret
            print_trapframe(tf);
ffffffffc0200826:	f15ff06f          	j	ffffffffc020073a <print_trapframe>
}
ffffffffc020082a:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020082c:	06400593          	li	a1,100
ffffffffc0200830:	00004517          	auipc	a0,0x4
ffffffffc0200834:	e3050513          	addi	a0,a0,-464 # ffffffffc0204660 <commands+0x460>
}
ffffffffc0200838:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020083a:	885ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020083e <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020083e:	11853783          	ld	a5,280(a0)
ffffffffc0200842:	473d                	li	a4,15
ffffffffc0200844:	16f76563          	bltu	a4,a5,ffffffffc02009ae <exception_handler+0x170>
ffffffffc0200848:	00004717          	auipc	a4,0x4
ffffffffc020084c:	b9c70713          	addi	a4,a4,-1124 # ffffffffc02043e4 <commands+0x1e4>
ffffffffc0200850:	078a                	slli	a5,a5,0x2
ffffffffc0200852:	97ba                	add	a5,a5,a4
ffffffffc0200854:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200856:	1101                	addi	sp,sp,-32
ffffffffc0200858:	e822                	sd	s0,16(sp)
ffffffffc020085a:	ec06                	sd	ra,24(sp)
ffffffffc020085c:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc020085e:	97ba                	add	a5,a5,a4
ffffffffc0200860:	842a                	mv	s0,a0
ffffffffc0200862:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200864:	00004517          	auipc	a0,0x4
ffffffffc0200868:	d6450513          	addi	a0,a0,-668 # ffffffffc02045c8 <commands+0x3c8>
ffffffffc020086c:	853ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200870:	8522                	mv	a0,s0
ffffffffc0200872:	c6bff0ef          	jal	ra,ffffffffc02004dc <pgfault_handler>
ffffffffc0200876:	84aa                	mv	s1,a0
ffffffffc0200878:	12051d63          	bnez	a0,ffffffffc02009b2 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020087c:	60e2                	ld	ra,24(sp)
ffffffffc020087e:	6442                	ld	s0,16(sp)
ffffffffc0200880:	64a2                	ld	s1,8(sp)
ffffffffc0200882:	6105                	addi	sp,sp,32
ffffffffc0200884:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200886:	00004517          	auipc	a0,0x4
ffffffffc020088a:	ba250513          	addi	a0,a0,-1118 # ffffffffc0204428 <commands+0x228>
}
ffffffffc020088e:	6442                	ld	s0,16(sp)
ffffffffc0200890:	60e2                	ld	ra,24(sp)
ffffffffc0200892:	64a2                	ld	s1,8(sp)
ffffffffc0200894:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200896:	829ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc020089a:	00004517          	auipc	a0,0x4
ffffffffc020089e:	bae50513          	addi	a0,a0,-1106 # ffffffffc0204448 <commands+0x248>
ffffffffc02008a2:	b7f5                	j	ffffffffc020088e <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	bc450513          	addi	a0,a0,-1084 # ffffffffc0204468 <commands+0x268>
ffffffffc02008ac:	b7cd                	j	ffffffffc020088e <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	bd250513          	addi	a0,a0,-1070 # ffffffffc0204480 <commands+0x280>
ffffffffc02008b6:	bfe1                	j	ffffffffc020088e <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	bd850513          	addi	a0,a0,-1064 # ffffffffc0204490 <commands+0x290>
ffffffffc02008c0:	b7f9                	j	ffffffffc020088e <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	bee50513          	addi	a0,a0,-1042 # ffffffffc02044b0 <commands+0x2b0>
ffffffffc02008ca:	ff4ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008ce:	8522                	mv	a0,s0
ffffffffc02008d0:	c0dff0ef          	jal	ra,ffffffffc02004dc <pgfault_handler>
ffffffffc02008d4:	84aa                	mv	s1,a0
ffffffffc02008d6:	d15d                	beqz	a0,ffffffffc020087c <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008d8:	8522                	mv	a0,s0
ffffffffc02008da:	e61ff0ef          	jal	ra,ffffffffc020073a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008de:	86a6                	mv	a3,s1
ffffffffc02008e0:	00004617          	auipc	a2,0x4
ffffffffc02008e4:	be860613          	addi	a2,a2,-1048 # ffffffffc02044c8 <commands+0x2c8>
ffffffffc02008e8:	0ca00593          	li	a1,202
ffffffffc02008ec:	00004517          	auipc	a0,0x4
ffffffffc02008f0:	ddc50513          	addi	a0,a0,-548 # ffffffffc02046c8 <commands+0x4c8>
ffffffffc02008f4:	a81ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02008f8:	00004517          	auipc	a0,0x4
ffffffffc02008fc:	bf050513          	addi	a0,a0,-1040 # ffffffffc02044e8 <commands+0x2e8>
ffffffffc0200900:	b779                	j	ffffffffc020088e <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0204500 <commands+0x300>
ffffffffc020090a:	fb4ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020090e:	8522                	mv	a0,s0
ffffffffc0200910:	bcdff0ef          	jal	ra,ffffffffc02004dc <pgfault_handler>
ffffffffc0200914:	84aa                	mv	s1,a0
ffffffffc0200916:	d13d                	beqz	a0,ffffffffc020087c <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	e21ff0ef          	jal	ra,ffffffffc020073a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020091e:	86a6                	mv	a3,s1
ffffffffc0200920:	00004617          	auipc	a2,0x4
ffffffffc0200924:	ba860613          	addi	a2,a2,-1112 # ffffffffc02044c8 <commands+0x2c8>
ffffffffc0200928:	0d400593          	li	a1,212
ffffffffc020092c:	00004517          	auipc	a0,0x4
ffffffffc0200930:	d9c50513          	addi	a0,a0,-612 # ffffffffc02046c8 <commands+0x4c8>
ffffffffc0200934:	a41ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200938:	00004517          	auipc	a0,0x4
ffffffffc020093c:	be050513          	addi	a0,a0,-1056 # ffffffffc0204518 <commands+0x318>
ffffffffc0200940:	b7b9                	j	ffffffffc020088e <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	bf650513          	addi	a0,a0,-1034 # ffffffffc0204538 <commands+0x338>
ffffffffc020094a:	b791                	j	ffffffffc020088e <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0204558 <commands+0x358>
ffffffffc0200954:	bf2d                	j	ffffffffc020088e <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	c2250513          	addi	a0,a0,-990 # ffffffffc0204578 <commands+0x378>
ffffffffc020095e:	bf05                	j	ffffffffc020088e <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	c3850513          	addi	a0,a0,-968 # ffffffffc0204598 <commands+0x398>
ffffffffc0200968:	b71d                	j	ffffffffc020088e <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	c4650513          	addi	a0,a0,-954 # ffffffffc02045b0 <commands+0x3b0>
ffffffffc0200972:	f4cff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200976:	8522                	mv	a0,s0
ffffffffc0200978:	b65ff0ef          	jal	ra,ffffffffc02004dc <pgfault_handler>
ffffffffc020097c:	84aa                	mv	s1,a0
ffffffffc020097e:	ee050fe3          	beqz	a0,ffffffffc020087c <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200982:	8522                	mv	a0,s0
ffffffffc0200984:	db7ff0ef          	jal	ra,ffffffffc020073a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200988:	86a6                	mv	a3,s1
ffffffffc020098a:	00004617          	auipc	a2,0x4
ffffffffc020098e:	b3e60613          	addi	a2,a2,-1218 # ffffffffc02044c8 <commands+0x2c8>
ffffffffc0200992:	0ea00593          	li	a1,234
ffffffffc0200996:	00004517          	auipc	a0,0x4
ffffffffc020099a:	d3250513          	addi	a0,a0,-718 # ffffffffc02046c8 <commands+0x4c8>
ffffffffc020099e:	9d7ff0ef          	jal	ra,ffffffffc0200374 <__panic>
}
ffffffffc02009a2:	6442                	ld	s0,16(sp)
ffffffffc02009a4:	60e2                	ld	ra,24(sp)
ffffffffc02009a6:	64a2                	ld	s1,8(sp)
ffffffffc02009a8:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009aa:	d91ff06f          	j	ffffffffc020073a <print_trapframe>
ffffffffc02009ae:	d8dff06f          	j	ffffffffc020073a <print_trapframe>
                print_trapframe(tf);
ffffffffc02009b2:	8522                	mv	a0,s0
ffffffffc02009b4:	d87ff0ef          	jal	ra,ffffffffc020073a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009b8:	86a6                	mv	a3,s1
ffffffffc02009ba:	00004617          	auipc	a2,0x4
ffffffffc02009be:	b0e60613          	addi	a2,a2,-1266 # ffffffffc02044c8 <commands+0x2c8>
ffffffffc02009c2:	0f100593          	li	a1,241
ffffffffc02009c6:	00004517          	auipc	a0,0x4
ffffffffc02009ca:	d0250513          	addi	a0,a0,-766 # ffffffffc02046c8 <commands+0x4c8>
ffffffffc02009ce:	9a7ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02009d2 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009d2:	11853783          	ld	a5,280(a0)
ffffffffc02009d6:	0007c463          	bltz	a5,ffffffffc02009de <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009da:	e65ff06f          	j	ffffffffc020083e <exception_handler>
        interrupt_handler(tf);
ffffffffc02009de:	dbfff06f          	j	ffffffffc020079c <interrupt_handler>
	...

ffffffffc02009f0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009f0:	14011073          	csrw	sscratch,sp
ffffffffc02009f4:	712d                	addi	sp,sp,-288
ffffffffc02009f6:	e406                	sd	ra,8(sp)
ffffffffc02009f8:	ec0e                	sd	gp,24(sp)
ffffffffc02009fa:	f012                	sd	tp,32(sp)
ffffffffc02009fc:	f416                	sd	t0,40(sp)
ffffffffc02009fe:	f81a                	sd	t1,48(sp)
ffffffffc0200a00:	fc1e                	sd	t2,56(sp)
ffffffffc0200a02:	e0a2                	sd	s0,64(sp)
ffffffffc0200a04:	e4a6                	sd	s1,72(sp)
ffffffffc0200a06:	e8aa                	sd	a0,80(sp)
ffffffffc0200a08:	ecae                	sd	a1,88(sp)
ffffffffc0200a0a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a0c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a0e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a10:	fcbe                	sd	a5,120(sp)
ffffffffc0200a12:	e142                	sd	a6,128(sp)
ffffffffc0200a14:	e546                	sd	a7,136(sp)
ffffffffc0200a16:	e94a                	sd	s2,144(sp)
ffffffffc0200a18:	ed4e                	sd	s3,152(sp)
ffffffffc0200a1a:	f152                	sd	s4,160(sp)
ffffffffc0200a1c:	f556                	sd	s5,168(sp)
ffffffffc0200a1e:	f95a                	sd	s6,176(sp)
ffffffffc0200a20:	fd5e                	sd	s7,184(sp)
ffffffffc0200a22:	e1e2                	sd	s8,192(sp)
ffffffffc0200a24:	e5e6                	sd	s9,200(sp)
ffffffffc0200a26:	e9ea                	sd	s10,208(sp)
ffffffffc0200a28:	edee                	sd	s11,216(sp)
ffffffffc0200a2a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a2c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a2e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a30:	fdfe                	sd	t6,248(sp)
ffffffffc0200a32:	14002473          	csrr	s0,sscratch
ffffffffc0200a36:	100024f3          	csrr	s1,sstatus
ffffffffc0200a3a:	14102973          	csrr	s2,sepc
ffffffffc0200a3e:	143029f3          	csrr	s3,stval
ffffffffc0200a42:	14202a73          	csrr	s4,scause
ffffffffc0200a46:	e822                	sd	s0,16(sp)
ffffffffc0200a48:	e226                	sd	s1,256(sp)
ffffffffc0200a4a:	e64a                	sd	s2,264(sp)
ffffffffc0200a4c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a4e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a50:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a52:	f81ff0ef          	jal	ra,ffffffffc02009d2 <trap>

ffffffffc0200a56 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a56:	6492                	ld	s1,256(sp)
ffffffffc0200a58:	6932                	ld	s2,264(sp)
ffffffffc0200a5a:	10049073          	csrw	sstatus,s1
ffffffffc0200a5e:	14191073          	csrw	sepc,s2
ffffffffc0200a62:	60a2                	ld	ra,8(sp)
ffffffffc0200a64:	61e2                	ld	gp,24(sp)
ffffffffc0200a66:	7202                	ld	tp,32(sp)
ffffffffc0200a68:	72a2                	ld	t0,40(sp)
ffffffffc0200a6a:	7342                	ld	t1,48(sp)
ffffffffc0200a6c:	73e2                	ld	t2,56(sp)
ffffffffc0200a6e:	6406                	ld	s0,64(sp)
ffffffffc0200a70:	64a6                	ld	s1,72(sp)
ffffffffc0200a72:	6546                	ld	a0,80(sp)
ffffffffc0200a74:	65e6                	ld	a1,88(sp)
ffffffffc0200a76:	7606                	ld	a2,96(sp)
ffffffffc0200a78:	76a6                	ld	a3,104(sp)
ffffffffc0200a7a:	7746                	ld	a4,112(sp)
ffffffffc0200a7c:	77e6                	ld	a5,120(sp)
ffffffffc0200a7e:	680a                	ld	a6,128(sp)
ffffffffc0200a80:	68aa                	ld	a7,136(sp)
ffffffffc0200a82:	694a                	ld	s2,144(sp)
ffffffffc0200a84:	69ea                	ld	s3,152(sp)
ffffffffc0200a86:	7a0a                	ld	s4,160(sp)
ffffffffc0200a88:	7aaa                	ld	s5,168(sp)
ffffffffc0200a8a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a8c:	7bea                	ld	s7,184(sp)
ffffffffc0200a8e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a90:	6cae                	ld	s9,200(sp)
ffffffffc0200a92:	6d4e                	ld	s10,208(sp)
ffffffffc0200a94:	6dee                	ld	s11,216(sp)
ffffffffc0200a96:	7e0e                	ld	t3,224(sp)
ffffffffc0200a98:	7eae                	ld	t4,232(sp)
ffffffffc0200a9a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a9c:	7fee                	ld	t6,248(sp)
ffffffffc0200a9e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200aa0:	10200073          	sret
	...

ffffffffc0200ab0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ab0:	00010797          	auipc	a5,0x10
ffffffffc0200ab4:	9c878793          	addi	a5,a5,-1592 # ffffffffc0210478 <free_area>
ffffffffc0200ab8:	e79c                	sd	a5,8(a5)
ffffffffc0200aba:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200abc:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ac0:	8082                	ret

ffffffffc0200ac2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ac2:	00010517          	auipc	a0,0x10
ffffffffc0200ac6:	9c656503          	lwu	a0,-1594(a0) # ffffffffc0210488 <free_area+0x10>
ffffffffc0200aca:	8082                	ret

ffffffffc0200acc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200acc:	715d                	addi	sp,sp,-80
ffffffffc0200ace:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ad0:	00010917          	auipc	s2,0x10
ffffffffc0200ad4:	9a890913          	addi	s2,s2,-1624 # ffffffffc0210478 <free_area>
ffffffffc0200ad8:	00893783          	ld	a5,8(s2)
ffffffffc0200adc:	e486                	sd	ra,72(sp)
ffffffffc0200ade:	e0a2                	sd	s0,64(sp)
ffffffffc0200ae0:	fc26                	sd	s1,56(sp)
ffffffffc0200ae2:	f44e                	sd	s3,40(sp)
ffffffffc0200ae4:	f052                	sd	s4,32(sp)
ffffffffc0200ae6:	ec56                	sd	s5,24(sp)
ffffffffc0200ae8:	e85a                	sd	s6,16(sp)
ffffffffc0200aea:	e45e                	sd	s7,8(sp)
ffffffffc0200aec:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200aee:	31278f63          	beq	a5,s2,ffffffffc0200e0c <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200af2:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200af6:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200af8:	8b05                	andi	a4,a4,1
ffffffffc0200afa:	30070d63          	beqz	a4,ffffffffc0200e14 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200afe:	4401                	li	s0,0
ffffffffc0200b00:	4481                	li	s1,0
ffffffffc0200b02:	a031                	j	ffffffffc0200b0e <default_check+0x42>
ffffffffc0200b04:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200b08:	8b09                	andi	a4,a4,2
ffffffffc0200b0a:	30070563          	beqz	a4,ffffffffc0200e14 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200b0e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b12:	679c                	ld	a5,8(a5)
ffffffffc0200b14:	2485                	addiw	s1,s1,1
ffffffffc0200b16:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b18:	ff2796e3          	bne	a5,s2,ffffffffc0200b04 <default_check+0x38>
ffffffffc0200b1c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200b1e:	3ef000ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc0200b22:	75351963          	bne	a0,s3,ffffffffc0201274 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b26:	4505                	li	a0,1
ffffffffc0200b28:	317000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200b2c:	8a2a                	mv	s4,a0
ffffffffc0200b2e:	48050363          	beqz	a0,ffffffffc0200fb4 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b32:	4505                	li	a0,1
ffffffffc0200b34:	30b000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200b38:	89aa                	mv	s3,a0
ffffffffc0200b3a:	74050d63          	beqz	a0,ffffffffc0201294 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b3e:	4505                	li	a0,1
ffffffffc0200b40:	2ff000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200b44:	8aaa                	mv	s5,a0
ffffffffc0200b46:	4e050763          	beqz	a0,ffffffffc0201034 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b4a:	2f3a0563          	beq	s4,s3,ffffffffc0200e34 <default_check+0x368>
ffffffffc0200b4e:	2eaa0363          	beq	s4,a0,ffffffffc0200e34 <default_check+0x368>
ffffffffc0200b52:	2ea98163          	beq	s3,a0,ffffffffc0200e34 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b56:	000a2783          	lw	a5,0(s4)
ffffffffc0200b5a:	2e079d63          	bnez	a5,ffffffffc0200e54 <default_check+0x388>
ffffffffc0200b5e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b62:	2e079963          	bnez	a5,ffffffffc0200e54 <default_check+0x388>
ffffffffc0200b66:	411c                	lw	a5,0(a0)
ffffffffc0200b68:	2e079663          	bnez	a5,ffffffffc0200e54 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b6c:	00010797          	auipc	a5,0x10
ffffffffc0200b70:	93c78793          	addi	a5,a5,-1732 # ffffffffc02104a8 <pages>
ffffffffc0200b74:	639c                	ld	a5,0(a5)
ffffffffc0200b76:	00004717          	auipc	a4,0x4
ffffffffc0200b7a:	ee270713          	addi	a4,a4,-286 # ffffffffc0204a58 <commands+0x858>
ffffffffc0200b7e:	630c                	ld	a1,0(a4)
ffffffffc0200b80:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b84:	870d                	srai	a4,a4,0x3
ffffffffc0200b86:	02b70733          	mul	a4,a4,a1
ffffffffc0200b8a:	00005697          	auipc	a3,0x5
ffffffffc0200b8e:	2de68693          	addi	a3,a3,734 # ffffffffc0205e68 <nbase>
ffffffffc0200b92:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b94:	00010697          	auipc	a3,0x10
ffffffffc0200b98:	8c468693          	addi	a3,a3,-1852 # ffffffffc0210458 <npage>
ffffffffc0200b9c:	6294                	ld	a3,0(a3)
ffffffffc0200b9e:	06b2                	slli	a3,a3,0xc
ffffffffc0200ba0:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ba2:	0732                	slli	a4,a4,0xc
ffffffffc0200ba4:	2cd77863          	bleu	a3,a4,ffffffffc0200e74 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ba8:	40f98733          	sub	a4,s3,a5
ffffffffc0200bac:	870d                	srai	a4,a4,0x3
ffffffffc0200bae:	02b70733          	mul	a4,a4,a1
ffffffffc0200bb2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bb4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200bb6:	4ed77f63          	bleu	a3,a4,ffffffffc02010b4 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bba:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bbe:	878d                	srai	a5,a5,0x3
ffffffffc0200bc0:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bc4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bc6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bc8:	34d7f663          	bleu	a3,a5,ffffffffc0200f14 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200bcc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bce:	00093c03          	ld	s8,0(s2)
ffffffffc0200bd2:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bd6:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200bda:	00010797          	auipc	a5,0x10
ffffffffc0200bde:	8b27b323          	sd	s2,-1882(a5) # ffffffffc0210480 <free_area+0x8>
ffffffffc0200be2:	00010797          	auipc	a5,0x10
ffffffffc0200be6:	8927bb23          	sd	s2,-1898(a5) # ffffffffc0210478 <free_area>
    nr_free = 0;
ffffffffc0200bea:	00010797          	auipc	a5,0x10
ffffffffc0200bee:	8807af23          	sw	zero,-1890(a5) # ffffffffc0210488 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bf2:	24d000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200bf6:	2e051f63          	bnez	a0,ffffffffc0200ef4 <default_check+0x428>
    free_page(p0);
ffffffffc0200bfa:	4585                	li	a1,1
ffffffffc0200bfc:	8552                	mv	a0,s4
ffffffffc0200bfe:	2c9000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    free_page(p1);
ffffffffc0200c02:	4585                	li	a1,1
ffffffffc0200c04:	854e                	mv	a0,s3
ffffffffc0200c06:	2c1000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    free_page(p2);
ffffffffc0200c0a:	4585                	li	a1,1
ffffffffc0200c0c:	8556                	mv	a0,s5
ffffffffc0200c0e:	2b9000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c12:	01092703          	lw	a4,16(s2)
ffffffffc0200c16:	478d                	li	a5,3
ffffffffc0200c18:	2af71e63          	bne	a4,a5,ffffffffc0200ed4 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c1c:	4505                	li	a0,1
ffffffffc0200c1e:	221000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200c22:	89aa                	mv	s3,a0
ffffffffc0200c24:	28050863          	beqz	a0,ffffffffc0200eb4 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c28:	4505                	li	a0,1
ffffffffc0200c2a:	215000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200c2e:	8aaa                	mv	s5,a0
ffffffffc0200c30:	3e050263          	beqz	a0,ffffffffc0201014 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c34:	4505                	li	a0,1
ffffffffc0200c36:	209000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200c3a:	8a2a                	mv	s4,a0
ffffffffc0200c3c:	3a050c63          	beqz	a0,ffffffffc0200ff4 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200c40:	4505                	li	a0,1
ffffffffc0200c42:	1fd000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200c46:	38051763          	bnez	a0,ffffffffc0200fd4 <default_check+0x508>
    free_page(p0);
ffffffffc0200c4a:	4585                	li	a1,1
ffffffffc0200c4c:	854e                	mv	a0,s3
ffffffffc0200c4e:	279000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c52:	00893783          	ld	a5,8(s2)
ffffffffc0200c56:	23278f63          	beq	a5,s2,ffffffffc0200e94 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200c5a:	4505                	li	a0,1
ffffffffc0200c5c:	1e3000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200c60:	32a99a63          	bne	s3,a0,ffffffffc0200f94 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200c64:	4505                	li	a0,1
ffffffffc0200c66:	1d9000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200c6a:	30051563          	bnez	a0,ffffffffc0200f74 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200c6e:	01092783          	lw	a5,16(s2)
ffffffffc0200c72:	2e079163          	bnez	a5,ffffffffc0200f54 <default_check+0x488>
    free_page(p);
ffffffffc0200c76:	854e                	mv	a0,s3
ffffffffc0200c78:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c7a:	0000f797          	auipc	a5,0xf
ffffffffc0200c7e:	7f87bf23          	sd	s8,2046(a5) # ffffffffc0210478 <free_area>
ffffffffc0200c82:	0000f797          	auipc	a5,0xf
ffffffffc0200c86:	7f77bf23          	sd	s7,2046(a5) # ffffffffc0210480 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200c8a:	0000f797          	auipc	a5,0xf
ffffffffc0200c8e:	7f67af23          	sw	s6,2046(a5) # ffffffffc0210488 <free_area+0x10>
    free_page(p);
ffffffffc0200c92:	235000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    free_page(p1);
ffffffffc0200c96:	4585                	li	a1,1
ffffffffc0200c98:	8556                	mv	a0,s5
ffffffffc0200c9a:	22d000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    free_page(p2);
ffffffffc0200c9e:	4585                	li	a1,1
ffffffffc0200ca0:	8552                	mv	a0,s4
ffffffffc0200ca2:	225000ef          	jal	ra,ffffffffc02016c6 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200ca6:	4515                	li	a0,5
ffffffffc0200ca8:	197000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200cac:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200cae:	28050363          	beqz	a0,ffffffffc0200f34 <default_check+0x468>
ffffffffc0200cb2:	651c                	ld	a5,8(a0)
ffffffffc0200cb4:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200cb6:	8b85                	andi	a5,a5,1
ffffffffc0200cb8:	54079e63          	bnez	a5,ffffffffc0201214 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200cbc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cbe:	00093b03          	ld	s6,0(s2)
ffffffffc0200cc2:	00893a83          	ld	s5,8(s2)
ffffffffc0200cc6:	0000f797          	auipc	a5,0xf
ffffffffc0200cca:	7b27b923          	sd	s2,1970(a5) # ffffffffc0210478 <free_area>
ffffffffc0200cce:	0000f797          	auipc	a5,0xf
ffffffffc0200cd2:	7b27b923          	sd	s2,1970(a5) # ffffffffc0210480 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200cd6:	169000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200cda:	50051d63          	bnez	a0,ffffffffc02011f4 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200cde:	09098a13          	addi	s4,s3,144
ffffffffc0200ce2:	8552                	mv	a0,s4
ffffffffc0200ce4:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200ce6:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200cea:	0000f797          	auipc	a5,0xf
ffffffffc0200cee:	7807af23          	sw	zero,1950(a5) # ffffffffc0210488 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200cf2:	1d5000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cf6:	4511                	li	a0,4
ffffffffc0200cf8:	147000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200cfc:	4c051c63          	bnez	a0,ffffffffc02011d4 <default_check+0x708>
ffffffffc0200d00:	0989b783          	ld	a5,152(s3)
ffffffffc0200d04:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d06:	8b85                	andi	a5,a5,1
ffffffffc0200d08:	4a078663          	beqz	a5,ffffffffc02011b4 <default_check+0x6e8>
ffffffffc0200d0c:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d10:	478d                	li	a5,3
ffffffffc0200d12:	4af71163          	bne	a4,a5,ffffffffc02011b4 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d16:	450d                	li	a0,3
ffffffffc0200d18:	127000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200d1c:	8c2a                	mv	s8,a0
ffffffffc0200d1e:	46050b63          	beqz	a0,ffffffffc0201194 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200d22:	4505                	li	a0,1
ffffffffc0200d24:	11b000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200d28:	44051663          	bnez	a0,ffffffffc0201174 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200d2c:	438a1463          	bne	s4,s8,ffffffffc0201154 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d30:	4585                	li	a1,1
ffffffffc0200d32:	854e                	mv	a0,s3
ffffffffc0200d34:	193000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d38:	458d                	li	a1,3
ffffffffc0200d3a:	8552                	mv	a0,s4
ffffffffc0200d3c:	18b000ef          	jal	ra,ffffffffc02016c6 <free_pages>
ffffffffc0200d40:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d44:	04898c13          	addi	s8,s3,72
ffffffffc0200d48:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d4a:	8b85                	andi	a5,a5,1
ffffffffc0200d4c:	3e078463          	beqz	a5,ffffffffc0201134 <default_check+0x668>
ffffffffc0200d50:	0189a703          	lw	a4,24(s3)
ffffffffc0200d54:	4785                	li	a5,1
ffffffffc0200d56:	3cf71f63          	bne	a4,a5,ffffffffc0201134 <default_check+0x668>
ffffffffc0200d5a:	008a3783          	ld	a5,8(s4)
ffffffffc0200d5e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d60:	8b85                	andi	a5,a5,1
ffffffffc0200d62:	3a078963          	beqz	a5,ffffffffc0201114 <default_check+0x648>
ffffffffc0200d66:	018a2703          	lw	a4,24(s4)
ffffffffc0200d6a:	478d                	li	a5,3
ffffffffc0200d6c:	3af71463          	bne	a4,a5,ffffffffc0201114 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d70:	4505                	li	a0,1
ffffffffc0200d72:	0cd000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200d76:	36a99f63          	bne	s3,a0,ffffffffc02010f4 <default_check+0x628>
    free_page(p0);
ffffffffc0200d7a:	4585                	li	a1,1
ffffffffc0200d7c:	14b000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d80:	4509                	li	a0,2
ffffffffc0200d82:	0bd000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200d86:	34aa1763          	bne	s4,a0,ffffffffc02010d4 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200d8a:	4589                	li	a1,2
ffffffffc0200d8c:	13b000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    free_page(p2);
ffffffffc0200d90:	4585                	li	a1,1
ffffffffc0200d92:	8562                	mv	a0,s8
ffffffffc0200d94:	133000ef          	jal	ra,ffffffffc02016c6 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d98:	4515                	li	a0,5
ffffffffc0200d9a:	0a5000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200d9e:	89aa                	mv	s3,a0
ffffffffc0200da0:	48050a63          	beqz	a0,ffffffffc0201234 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200da4:	4505                	li	a0,1
ffffffffc0200da6:	099000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200daa:	2e051563          	bnez	a0,ffffffffc0201094 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200dae:	01092783          	lw	a5,16(s2)
ffffffffc0200db2:	2c079163          	bnez	a5,ffffffffc0201074 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200db6:	4595                	li	a1,5
ffffffffc0200db8:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200dba:	0000f797          	auipc	a5,0xf
ffffffffc0200dbe:	6d77a723          	sw	s7,1742(a5) # ffffffffc0210488 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200dc2:	0000f797          	auipc	a5,0xf
ffffffffc0200dc6:	6b67bb23          	sd	s6,1718(a5) # ffffffffc0210478 <free_area>
ffffffffc0200dca:	0000f797          	auipc	a5,0xf
ffffffffc0200dce:	6b57bb23          	sd	s5,1718(a5) # ffffffffc0210480 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200dd2:	0f5000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    return listelm->next;
ffffffffc0200dd6:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dda:	01278963          	beq	a5,s2,ffffffffc0200dec <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200dde:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200de2:	679c                	ld	a5,8(a5)
ffffffffc0200de4:	34fd                	addiw	s1,s1,-1
ffffffffc0200de6:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200de8:	ff279be3          	bne	a5,s2,ffffffffc0200dde <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200dec:	26049463          	bnez	s1,ffffffffc0201054 <default_check+0x588>
    assert(total == 0);
ffffffffc0200df0:	46041263          	bnez	s0,ffffffffc0201254 <default_check+0x788>
}
ffffffffc0200df4:	60a6                	ld	ra,72(sp)
ffffffffc0200df6:	6406                	ld	s0,64(sp)
ffffffffc0200df8:	74e2                	ld	s1,56(sp)
ffffffffc0200dfa:	7942                	ld	s2,48(sp)
ffffffffc0200dfc:	79a2                	ld	s3,40(sp)
ffffffffc0200dfe:	7a02                	ld	s4,32(sp)
ffffffffc0200e00:	6ae2                	ld	s5,24(sp)
ffffffffc0200e02:	6b42                	ld	s6,16(sp)
ffffffffc0200e04:	6ba2                	ld	s7,8(sp)
ffffffffc0200e06:	6c02                	ld	s8,0(sp)
ffffffffc0200e08:	6161                	addi	sp,sp,80
ffffffffc0200e0a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e0c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e0e:	4401                	li	s0,0
ffffffffc0200e10:	4481                	li	s1,0
ffffffffc0200e12:	b331                	j	ffffffffc0200b1e <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200e14:	00004697          	auipc	a3,0x4
ffffffffc0200e18:	c4c68693          	addi	a3,a3,-948 # ffffffffc0204a60 <commands+0x860>
ffffffffc0200e1c:	00004617          	auipc	a2,0x4
ffffffffc0200e20:	c5460613          	addi	a2,a2,-940 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200e24:	0f000593          	li	a1,240
ffffffffc0200e28:	00004517          	auipc	a0,0x4
ffffffffc0200e2c:	c6050513          	addi	a0,a0,-928 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200e30:	d44ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e34:	00004697          	auipc	a3,0x4
ffffffffc0200e38:	cec68693          	addi	a3,a3,-788 # ffffffffc0204b20 <commands+0x920>
ffffffffc0200e3c:	00004617          	auipc	a2,0x4
ffffffffc0200e40:	c3460613          	addi	a2,a2,-972 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200e44:	0bd00593          	li	a1,189
ffffffffc0200e48:	00004517          	auipc	a0,0x4
ffffffffc0200e4c:	c4050513          	addi	a0,a0,-960 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200e50:	d24ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e54:	00004697          	auipc	a3,0x4
ffffffffc0200e58:	cf468693          	addi	a3,a3,-780 # ffffffffc0204b48 <commands+0x948>
ffffffffc0200e5c:	00004617          	auipc	a2,0x4
ffffffffc0200e60:	c1460613          	addi	a2,a2,-1004 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200e64:	0be00593          	li	a1,190
ffffffffc0200e68:	00004517          	auipc	a0,0x4
ffffffffc0200e6c:	c2050513          	addi	a0,a0,-992 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200e70:	d04ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e74:	00004697          	auipc	a3,0x4
ffffffffc0200e78:	d1468693          	addi	a3,a3,-748 # ffffffffc0204b88 <commands+0x988>
ffffffffc0200e7c:	00004617          	auipc	a2,0x4
ffffffffc0200e80:	bf460613          	addi	a2,a2,-1036 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200e84:	0c000593          	li	a1,192
ffffffffc0200e88:	00004517          	auipc	a0,0x4
ffffffffc0200e8c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200e90:	ce4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e94:	00004697          	auipc	a3,0x4
ffffffffc0200e98:	d7c68693          	addi	a3,a3,-644 # ffffffffc0204c10 <commands+0xa10>
ffffffffc0200e9c:	00004617          	auipc	a2,0x4
ffffffffc0200ea0:	bd460613          	addi	a2,a2,-1068 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200ea4:	0d900593          	li	a1,217
ffffffffc0200ea8:	00004517          	auipc	a0,0x4
ffffffffc0200eac:	be050513          	addi	a0,a0,-1056 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200eb0:	cc4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200eb4:	00004697          	auipc	a3,0x4
ffffffffc0200eb8:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0204ac0 <commands+0x8c0>
ffffffffc0200ebc:	00004617          	auipc	a2,0x4
ffffffffc0200ec0:	bb460613          	addi	a2,a2,-1100 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200ec4:	0d200593          	li	a1,210
ffffffffc0200ec8:	00004517          	auipc	a0,0x4
ffffffffc0200ecc:	bc050513          	addi	a0,a0,-1088 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200ed0:	ca4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200ed4:	00004697          	auipc	a3,0x4
ffffffffc0200ed8:	d2c68693          	addi	a3,a3,-724 # ffffffffc0204c00 <commands+0xa00>
ffffffffc0200edc:	00004617          	auipc	a2,0x4
ffffffffc0200ee0:	b9460613          	addi	a2,a2,-1132 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200ee4:	0d000593          	li	a1,208
ffffffffc0200ee8:	00004517          	auipc	a0,0x4
ffffffffc0200eec:	ba050513          	addi	a0,a0,-1120 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200ef0:	c84ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ef4:	00004697          	auipc	a3,0x4
ffffffffc0200ef8:	cf468693          	addi	a3,a3,-780 # ffffffffc0204be8 <commands+0x9e8>
ffffffffc0200efc:	00004617          	auipc	a2,0x4
ffffffffc0200f00:	b7460613          	addi	a2,a2,-1164 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200f04:	0cb00593          	li	a1,203
ffffffffc0200f08:	00004517          	auipc	a0,0x4
ffffffffc0200f0c:	b8050513          	addi	a0,a0,-1152 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200f10:	c64ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f14:	00004697          	auipc	a3,0x4
ffffffffc0200f18:	cb468693          	addi	a3,a3,-844 # ffffffffc0204bc8 <commands+0x9c8>
ffffffffc0200f1c:	00004617          	auipc	a2,0x4
ffffffffc0200f20:	b5460613          	addi	a2,a2,-1196 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200f24:	0c200593          	li	a1,194
ffffffffc0200f28:	00004517          	auipc	a0,0x4
ffffffffc0200f2c:	b6050513          	addi	a0,a0,-1184 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200f30:	c44ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200f34:	00004697          	auipc	a3,0x4
ffffffffc0200f38:	d2468693          	addi	a3,a3,-732 # ffffffffc0204c58 <commands+0xa58>
ffffffffc0200f3c:	00004617          	auipc	a2,0x4
ffffffffc0200f40:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200f44:	0f800593          	li	a1,248
ffffffffc0200f48:	00004517          	auipc	a0,0x4
ffffffffc0200f4c:	b4050513          	addi	a0,a0,-1216 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200f50:	c24ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200f54:	00004697          	auipc	a3,0x4
ffffffffc0200f58:	cf468693          	addi	a3,a3,-780 # ffffffffc0204c48 <commands+0xa48>
ffffffffc0200f5c:	00004617          	auipc	a2,0x4
ffffffffc0200f60:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200f64:	0df00593          	li	a1,223
ffffffffc0200f68:	00004517          	auipc	a0,0x4
ffffffffc0200f6c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200f70:	c04ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f74:	00004697          	auipc	a3,0x4
ffffffffc0200f78:	c7468693          	addi	a3,a3,-908 # ffffffffc0204be8 <commands+0x9e8>
ffffffffc0200f7c:	00004617          	auipc	a2,0x4
ffffffffc0200f80:	af460613          	addi	a2,a2,-1292 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200f84:	0dd00593          	li	a1,221
ffffffffc0200f88:	00004517          	auipc	a0,0x4
ffffffffc0200f8c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200f90:	be4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f94:	00004697          	auipc	a3,0x4
ffffffffc0200f98:	c9468693          	addi	a3,a3,-876 # ffffffffc0204c28 <commands+0xa28>
ffffffffc0200f9c:	00004617          	auipc	a2,0x4
ffffffffc0200fa0:	ad460613          	addi	a2,a2,-1324 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200fa4:	0dc00593          	li	a1,220
ffffffffc0200fa8:	00004517          	auipc	a0,0x4
ffffffffc0200fac:	ae050513          	addi	a0,a0,-1312 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200fb0:	bc4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fb4:	00004697          	auipc	a3,0x4
ffffffffc0200fb8:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0204ac0 <commands+0x8c0>
ffffffffc0200fbc:	00004617          	auipc	a2,0x4
ffffffffc0200fc0:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200fc4:	0b900593          	li	a1,185
ffffffffc0200fc8:	00004517          	auipc	a0,0x4
ffffffffc0200fcc:	ac050513          	addi	a0,a0,-1344 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200fd0:	ba4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fd4:	00004697          	auipc	a3,0x4
ffffffffc0200fd8:	c1468693          	addi	a3,a3,-1004 # ffffffffc0204be8 <commands+0x9e8>
ffffffffc0200fdc:	00004617          	auipc	a2,0x4
ffffffffc0200fe0:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204a70 <commands+0x870>
ffffffffc0200fe4:	0d600593          	li	a1,214
ffffffffc0200fe8:	00004517          	auipc	a0,0x4
ffffffffc0200fec:	aa050513          	addi	a0,a0,-1376 # ffffffffc0204a88 <commands+0x888>
ffffffffc0200ff0:	b84ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ff4:	00004697          	auipc	a3,0x4
ffffffffc0200ff8:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0204b00 <commands+0x900>
ffffffffc0200ffc:	00004617          	auipc	a2,0x4
ffffffffc0201000:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201004:	0d400593          	li	a1,212
ffffffffc0201008:	00004517          	auipc	a0,0x4
ffffffffc020100c:	a8050513          	addi	a0,a0,-1408 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201010:	b64ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201014:	00004697          	auipc	a3,0x4
ffffffffc0201018:	acc68693          	addi	a3,a3,-1332 # ffffffffc0204ae0 <commands+0x8e0>
ffffffffc020101c:	00004617          	auipc	a2,0x4
ffffffffc0201020:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201024:	0d300593          	li	a1,211
ffffffffc0201028:	00004517          	auipc	a0,0x4
ffffffffc020102c:	a6050513          	addi	a0,a0,-1440 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201030:	b44ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201034:	00004697          	auipc	a3,0x4
ffffffffc0201038:	acc68693          	addi	a3,a3,-1332 # ffffffffc0204b00 <commands+0x900>
ffffffffc020103c:	00004617          	auipc	a2,0x4
ffffffffc0201040:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201044:	0bb00593          	li	a1,187
ffffffffc0201048:	00004517          	auipc	a0,0x4
ffffffffc020104c:	a4050513          	addi	a0,a0,-1472 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201050:	b24ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0201054:	00004697          	auipc	a3,0x4
ffffffffc0201058:	d5468693          	addi	a3,a3,-684 # ffffffffc0204da8 <commands+0xba8>
ffffffffc020105c:	00004617          	auipc	a2,0x4
ffffffffc0201060:	a1460613          	addi	a2,a2,-1516 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201064:	12500593          	li	a1,293
ffffffffc0201068:	00004517          	auipc	a0,0x4
ffffffffc020106c:	a2050513          	addi	a0,a0,-1504 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201070:	b04ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0201074:	00004697          	auipc	a3,0x4
ffffffffc0201078:	bd468693          	addi	a3,a3,-1068 # ffffffffc0204c48 <commands+0xa48>
ffffffffc020107c:	00004617          	auipc	a2,0x4
ffffffffc0201080:	9f460613          	addi	a2,a2,-1548 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201084:	11a00593          	li	a1,282
ffffffffc0201088:	00004517          	auipc	a0,0x4
ffffffffc020108c:	a0050513          	addi	a0,a0,-1536 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201090:	ae4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201094:	00004697          	auipc	a3,0x4
ffffffffc0201098:	b5468693          	addi	a3,a3,-1196 # ffffffffc0204be8 <commands+0x9e8>
ffffffffc020109c:	00004617          	auipc	a2,0x4
ffffffffc02010a0:	9d460613          	addi	a2,a2,-1580 # ffffffffc0204a70 <commands+0x870>
ffffffffc02010a4:	11800593          	li	a1,280
ffffffffc02010a8:	00004517          	auipc	a0,0x4
ffffffffc02010ac:	9e050513          	addi	a0,a0,-1568 # ffffffffc0204a88 <commands+0x888>
ffffffffc02010b0:	ac4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010b4:	00004697          	auipc	a3,0x4
ffffffffc02010b8:	af468693          	addi	a3,a3,-1292 # ffffffffc0204ba8 <commands+0x9a8>
ffffffffc02010bc:	00004617          	auipc	a2,0x4
ffffffffc02010c0:	9b460613          	addi	a2,a2,-1612 # ffffffffc0204a70 <commands+0x870>
ffffffffc02010c4:	0c100593          	li	a1,193
ffffffffc02010c8:	00004517          	auipc	a0,0x4
ffffffffc02010cc:	9c050513          	addi	a0,a0,-1600 # ffffffffc0204a88 <commands+0x888>
ffffffffc02010d0:	aa4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010d4:	00004697          	auipc	a3,0x4
ffffffffc02010d8:	c9468693          	addi	a3,a3,-876 # ffffffffc0204d68 <commands+0xb68>
ffffffffc02010dc:	00004617          	auipc	a2,0x4
ffffffffc02010e0:	99460613          	addi	a2,a2,-1644 # ffffffffc0204a70 <commands+0x870>
ffffffffc02010e4:	11200593          	li	a1,274
ffffffffc02010e8:	00004517          	auipc	a0,0x4
ffffffffc02010ec:	9a050513          	addi	a0,a0,-1632 # ffffffffc0204a88 <commands+0x888>
ffffffffc02010f0:	a84ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010f4:	00004697          	auipc	a3,0x4
ffffffffc02010f8:	c5468693          	addi	a3,a3,-940 # ffffffffc0204d48 <commands+0xb48>
ffffffffc02010fc:	00004617          	auipc	a2,0x4
ffffffffc0201100:	97460613          	addi	a2,a2,-1676 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201104:	11000593          	li	a1,272
ffffffffc0201108:	00004517          	auipc	a0,0x4
ffffffffc020110c:	98050513          	addi	a0,a0,-1664 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201110:	a64ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201114:	00004697          	auipc	a3,0x4
ffffffffc0201118:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0204d20 <commands+0xb20>
ffffffffc020111c:	00004617          	auipc	a2,0x4
ffffffffc0201120:	95460613          	addi	a2,a2,-1708 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201124:	10e00593          	li	a1,270
ffffffffc0201128:	00004517          	auipc	a0,0x4
ffffffffc020112c:	96050513          	addi	a0,a0,-1696 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201130:	a44ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201134:	00004697          	auipc	a3,0x4
ffffffffc0201138:	bc468693          	addi	a3,a3,-1084 # ffffffffc0204cf8 <commands+0xaf8>
ffffffffc020113c:	00004617          	auipc	a2,0x4
ffffffffc0201140:	93460613          	addi	a2,a2,-1740 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201144:	10d00593          	li	a1,269
ffffffffc0201148:	00004517          	auipc	a0,0x4
ffffffffc020114c:	94050513          	addi	a0,a0,-1728 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201150:	a24ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201154:	00004697          	auipc	a3,0x4
ffffffffc0201158:	b9468693          	addi	a3,a3,-1132 # ffffffffc0204ce8 <commands+0xae8>
ffffffffc020115c:	00004617          	auipc	a2,0x4
ffffffffc0201160:	91460613          	addi	a2,a2,-1772 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201164:	10800593          	li	a1,264
ffffffffc0201168:	00004517          	auipc	a0,0x4
ffffffffc020116c:	92050513          	addi	a0,a0,-1760 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201170:	a04ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201174:	00004697          	auipc	a3,0x4
ffffffffc0201178:	a7468693          	addi	a3,a3,-1420 # ffffffffc0204be8 <commands+0x9e8>
ffffffffc020117c:	00004617          	auipc	a2,0x4
ffffffffc0201180:	8f460613          	addi	a2,a2,-1804 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201184:	10700593          	li	a1,263
ffffffffc0201188:	00004517          	auipc	a0,0x4
ffffffffc020118c:	90050513          	addi	a0,a0,-1792 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201190:	9e4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201194:	00004697          	auipc	a3,0x4
ffffffffc0201198:	b3468693          	addi	a3,a3,-1228 # ffffffffc0204cc8 <commands+0xac8>
ffffffffc020119c:	00004617          	auipc	a2,0x4
ffffffffc02011a0:	8d460613          	addi	a2,a2,-1836 # ffffffffc0204a70 <commands+0x870>
ffffffffc02011a4:	10600593          	li	a1,262
ffffffffc02011a8:	00004517          	auipc	a0,0x4
ffffffffc02011ac:	8e050513          	addi	a0,a0,-1824 # ffffffffc0204a88 <commands+0x888>
ffffffffc02011b0:	9c4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011b4:	00004697          	auipc	a3,0x4
ffffffffc02011b8:	ae468693          	addi	a3,a3,-1308 # ffffffffc0204c98 <commands+0xa98>
ffffffffc02011bc:	00004617          	auipc	a2,0x4
ffffffffc02011c0:	8b460613          	addi	a2,a2,-1868 # ffffffffc0204a70 <commands+0x870>
ffffffffc02011c4:	10500593          	li	a1,261
ffffffffc02011c8:	00004517          	auipc	a0,0x4
ffffffffc02011cc:	8c050513          	addi	a0,a0,-1856 # ffffffffc0204a88 <commands+0x888>
ffffffffc02011d0:	9a4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011d4:	00004697          	auipc	a3,0x4
ffffffffc02011d8:	aac68693          	addi	a3,a3,-1364 # ffffffffc0204c80 <commands+0xa80>
ffffffffc02011dc:	00004617          	auipc	a2,0x4
ffffffffc02011e0:	89460613          	addi	a2,a2,-1900 # ffffffffc0204a70 <commands+0x870>
ffffffffc02011e4:	10400593          	li	a1,260
ffffffffc02011e8:	00004517          	auipc	a0,0x4
ffffffffc02011ec:	8a050513          	addi	a0,a0,-1888 # ffffffffc0204a88 <commands+0x888>
ffffffffc02011f0:	984ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011f4:	00004697          	auipc	a3,0x4
ffffffffc02011f8:	9f468693          	addi	a3,a3,-1548 # ffffffffc0204be8 <commands+0x9e8>
ffffffffc02011fc:	00004617          	auipc	a2,0x4
ffffffffc0201200:	87460613          	addi	a2,a2,-1932 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201204:	0fe00593          	li	a1,254
ffffffffc0201208:	00004517          	auipc	a0,0x4
ffffffffc020120c:	88050513          	addi	a0,a0,-1920 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201210:	964ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201214:	00004697          	auipc	a3,0x4
ffffffffc0201218:	a5468693          	addi	a3,a3,-1452 # ffffffffc0204c68 <commands+0xa68>
ffffffffc020121c:	00004617          	auipc	a2,0x4
ffffffffc0201220:	85460613          	addi	a2,a2,-1964 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201224:	0f900593          	li	a1,249
ffffffffc0201228:	00004517          	auipc	a0,0x4
ffffffffc020122c:	86050513          	addi	a0,a0,-1952 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201230:	944ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201234:	00004697          	auipc	a3,0x4
ffffffffc0201238:	b5468693          	addi	a3,a3,-1196 # ffffffffc0204d88 <commands+0xb88>
ffffffffc020123c:	00004617          	auipc	a2,0x4
ffffffffc0201240:	83460613          	addi	a2,a2,-1996 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201244:	11700593          	li	a1,279
ffffffffc0201248:	00004517          	auipc	a0,0x4
ffffffffc020124c:	84050513          	addi	a0,a0,-1984 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201250:	924ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc0201254:	00004697          	auipc	a3,0x4
ffffffffc0201258:	b6468693          	addi	a3,a3,-1180 # ffffffffc0204db8 <commands+0xbb8>
ffffffffc020125c:	00004617          	auipc	a2,0x4
ffffffffc0201260:	81460613          	addi	a2,a2,-2028 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201264:	12600593          	li	a1,294
ffffffffc0201268:	00004517          	auipc	a0,0x4
ffffffffc020126c:	82050513          	addi	a0,a0,-2016 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201270:	904ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201274:	00004697          	auipc	a3,0x4
ffffffffc0201278:	82c68693          	addi	a3,a3,-2004 # ffffffffc0204aa0 <commands+0x8a0>
ffffffffc020127c:	00003617          	auipc	a2,0x3
ffffffffc0201280:	7f460613          	addi	a2,a2,2036 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201284:	0f300593          	li	a1,243
ffffffffc0201288:	00004517          	auipc	a0,0x4
ffffffffc020128c:	80050513          	addi	a0,a0,-2048 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201290:	8e4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201294:	00004697          	auipc	a3,0x4
ffffffffc0201298:	84c68693          	addi	a3,a3,-1972 # ffffffffc0204ae0 <commands+0x8e0>
ffffffffc020129c:	00003617          	auipc	a2,0x3
ffffffffc02012a0:	7d460613          	addi	a2,a2,2004 # ffffffffc0204a70 <commands+0x870>
ffffffffc02012a4:	0ba00593          	li	a1,186
ffffffffc02012a8:	00003517          	auipc	a0,0x3
ffffffffc02012ac:	7e050513          	addi	a0,a0,2016 # ffffffffc0204a88 <commands+0x888>
ffffffffc02012b0:	8c4ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02012b4 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02012b4:	1141                	addi	sp,sp,-16
ffffffffc02012b6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012b8:	18058063          	beqz	a1,ffffffffc0201438 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02012bc:	00359693          	slli	a3,a1,0x3
ffffffffc02012c0:	96ae                	add	a3,a3,a1
ffffffffc02012c2:	068e                	slli	a3,a3,0x3
ffffffffc02012c4:	96aa                	add	a3,a3,a0
ffffffffc02012c6:	02d50d63          	beq	a0,a3,ffffffffc0201300 <default_free_pages+0x4c>
ffffffffc02012ca:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012cc:	8b85                	andi	a5,a5,1
ffffffffc02012ce:	14079563          	bnez	a5,ffffffffc0201418 <default_free_pages+0x164>
ffffffffc02012d2:	651c                	ld	a5,8(a0)
ffffffffc02012d4:	8385                	srli	a5,a5,0x1
ffffffffc02012d6:	8b85                	andi	a5,a5,1
ffffffffc02012d8:	14079063          	bnez	a5,ffffffffc0201418 <default_free_pages+0x164>
ffffffffc02012dc:	87aa                	mv	a5,a0
ffffffffc02012de:	a809                	j	ffffffffc02012f0 <default_free_pages+0x3c>
ffffffffc02012e0:	6798                	ld	a4,8(a5)
ffffffffc02012e2:	8b05                	andi	a4,a4,1
ffffffffc02012e4:	12071a63          	bnez	a4,ffffffffc0201418 <default_free_pages+0x164>
ffffffffc02012e8:	6798                	ld	a4,8(a5)
ffffffffc02012ea:	8b09                	andi	a4,a4,2
ffffffffc02012ec:	12071663          	bnez	a4,ffffffffc0201418 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc02012f0:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012f4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012f8:	04878793          	addi	a5,a5,72
ffffffffc02012fc:	fed792e3          	bne	a5,a3,ffffffffc02012e0 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201300:	2581                	sext.w	a1,a1
ffffffffc0201302:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201304:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201308:	4789                	li	a5,2
ffffffffc020130a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020130e:	0000f697          	auipc	a3,0xf
ffffffffc0201312:	16a68693          	addi	a3,a3,362 # ffffffffc0210478 <free_area>
ffffffffc0201316:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201318:	669c                	ld	a5,8(a3)
ffffffffc020131a:	9db9                	addw	a1,a1,a4
ffffffffc020131c:	0000f717          	auipc	a4,0xf
ffffffffc0201320:	16b72623          	sw	a1,364(a4) # ffffffffc0210488 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201324:	08d78f63          	beq	a5,a3,ffffffffc02013c2 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201328:	fe078713          	addi	a4,a5,-32
ffffffffc020132c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020132e:	4801                	li	a6,0
ffffffffc0201330:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201334:	00e56a63          	bltu	a0,a4,ffffffffc0201348 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0201338:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020133a:	02d70563          	beq	a4,a3,ffffffffc0201364 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020133e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201340:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201344:	fee57ae3          	bleu	a4,a0,ffffffffc0201338 <default_free_pages+0x84>
ffffffffc0201348:	00080663          	beqz	a6,ffffffffc0201354 <default_free_pages+0xa0>
ffffffffc020134c:	0000f817          	auipc	a6,0xf
ffffffffc0201350:	12b83623          	sd	a1,300(a6) # ffffffffc0210478 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201354:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201356:	e390                	sd	a2,0(a5)
ffffffffc0201358:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020135a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020135c:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc020135e:	02d59163          	bne	a1,a3,ffffffffc0201380 <default_free_pages+0xcc>
ffffffffc0201362:	a091                	j	ffffffffc02013a6 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0201364:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201366:	f514                	sd	a3,40(a0)
ffffffffc0201368:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020136a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020136c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020136e:	00d70563          	beq	a4,a3,ffffffffc0201378 <default_free_pages+0xc4>
ffffffffc0201372:	4805                	li	a6,1
ffffffffc0201374:	87ba                	mv	a5,a4
ffffffffc0201376:	b7e9                	j	ffffffffc0201340 <default_free_pages+0x8c>
ffffffffc0201378:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020137a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020137c:	02d78163          	beq	a5,a3,ffffffffc020139e <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0201380:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201384:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc0201388:	02081713          	slli	a4,a6,0x20
ffffffffc020138c:	9301                	srli	a4,a4,0x20
ffffffffc020138e:	00371793          	slli	a5,a4,0x3
ffffffffc0201392:	97ba                	add	a5,a5,a4
ffffffffc0201394:	078e                	slli	a5,a5,0x3
ffffffffc0201396:	97b2                	add	a5,a5,a2
ffffffffc0201398:	02f50e63          	beq	a0,a5,ffffffffc02013d4 <default_free_pages+0x120>
ffffffffc020139c:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc020139e:	fe078713          	addi	a4,a5,-32
ffffffffc02013a2:	00d78d63          	beq	a5,a3,ffffffffc02013bc <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02013a6:	4d0c                	lw	a1,24(a0)
ffffffffc02013a8:	02059613          	slli	a2,a1,0x20
ffffffffc02013ac:	9201                	srli	a2,a2,0x20
ffffffffc02013ae:	00361693          	slli	a3,a2,0x3
ffffffffc02013b2:	96b2                	add	a3,a3,a2
ffffffffc02013b4:	068e                	slli	a3,a3,0x3
ffffffffc02013b6:	96aa                	add	a3,a3,a0
ffffffffc02013b8:	04d70063          	beq	a4,a3,ffffffffc02013f8 <default_free_pages+0x144>
}
ffffffffc02013bc:	60a2                	ld	ra,8(sp)
ffffffffc02013be:	0141                	addi	sp,sp,16
ffffffffc02013c0:	8082                	ret
ffffffffc02013c2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02013c4:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02013c8:	e398                	sd	a4,0(a5)
ffffffffc02013ca:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02013cc:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013ce:	f11c                	sd	a5,32(a0)
}
ffffffffc02013d0:	0141                	addi	sp,sp,16
ffffffffc02013d2:	8082                	ret
            p->property += base->property;
ffffffffc02013d4:	4d1c                	lw	a5,24(a0)
ffffffffc02013d6:	0107883b          	addw	a6,a5,a6
ffffffffc02013da:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02013de:	57f5                	li	a5,-3
ffffffffc02013e0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013e4:	02053803          	ld	a6,32(a0)
ffffffffc02013e8:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc02013ea:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02013ec:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc02013f0:	659c                	ld	a5,8(a1)
ffffffffc02013f2:	01073023          	sd	a6,0(a4)
ffffffffc02013f6:	b765                	j	ffffffffc020139e <default_free_pages+0xea>
            base->property += p->property;
ffffffffc02013f8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013fc:	fe878693          	addi	a3,a5,-24
ffffffffc0201400:	9db9                	addw	a1,a1,a4
ffffffffc0201402:	cd0c                	sw	a1,24(a0)
ffffffffc0201404:	5775                	li	a4,-3
ffffffffc0201406:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020140a:	6398                	ld	a4,0(a5)
ffffffffc020140c:	679c                	ld	a5,8(a5)
}
ffffffffc020140e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201410:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201412:	e398                	sd	a4,0(a5)
ffffffffc0201414:	0141                	addi	sp,sp,16
ffffffffc0201416:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201418:	00004697          	auipc	a3,0x4
ffffffffc020141c:	9b068693          	addi	a3,a3,-1616 # ffffffffc0204dc8 <commands+0xbc8>
ffffffffc0201420:	00003617          	auipc	a2,0x3
ffffffffc0201424:	65060613          	addi	a2,a2,1616 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201428:	08300593          	li	a1,131
ffffffffc020142c:	00003517          	auipc	a0,0x3
ffffffffc0201430:	65c50513          	addi	a0,a0,1628 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201434:	f41fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201438:	00004697          	auipc	a3,0x4
ffffffffc020143c:	9b868693          	addi	a3,a3,-1608 # ffffffffc0204df0 <commands+0xbf0>
ffffffffc0201440:	00003617          	auipc	a2,0x3
ffffffffc0201444:	63060613          	addi	a2,a2,1584 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201448:	08000593          	li	a1,128
ffffffffc020144c:	00003517          	auipc	a0,0x3
ffffffffc0201450:	63c50513          	addi	a0,a0,1596 # ffffffffc0204a88 <commands+0x888>
ffffffffc0201454:	f21fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201458 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201458:	cd51                	beqz	a0,ffffffffc02014f4 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc020145a:	0000f597          	auipc	a1,0xf
ffffffffc020145e:	01e58593          	addi	a1,a1,30 # ffffffffc0210478 <free_area>
ffffffffc0201462:	0105a803          	lw	a6,16(a1)
ffffffffc0201466:	862a                	mv	a2,a0
ffffffffc0201468:	02081793          	slli	a5,a6,0x20
ffffffffc020146c:	9381                	srli	a5,a5,0x20
ffffffffc020146e:	00a7ee63          	bltu	a5,a0,ffffffffc020148a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201472:	87ae                	mv	a5,a1
ffffffffc0201474:	a801                	j	ffffffffc0201484 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201476:	ff87a703          	lw	a4,-8(a5)
ffffffffc020147a:	02071693          	slli	a3,a4,0x20
ffffffffc020147e:	9281                	srli	a3,a3,0x20
ffffffffc0201480:	00c6f763          	bleu	a2,a3,ffffffffc020148e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201484:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201486:	feb798e3          	bne	a5,a1,ffffffffc0201476 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020148a:	4501                	li	a0,0
}
ffffffffc020148c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020148e:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc0201492:	dd6d                	beqz	a0,ffffffffc020148c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201494:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201498:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020149c:	00060e1b          	sext.w	t3,a2
ffffffffc02014a0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02014a4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02014a8:	02d67b63          	bleu	a3,a2,ffffffffc02014de <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02014ac:	00361693          	slli	a3,a2,0x3
ffffffffc02014b0:	96b2                	add	a3,a3,a2
ffffffffc02014b2:	068e                	slli	a3,a3,0x3
ffffffffc02014b4:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02014b6:	41c7073b          	subw	a4,a4,t3
ffffffffc02014ba:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014bc:	00868613          	addi	a2,a3,8
ffffffffc02014c0:	4709                	li	a4,2
ffffffffc02014c2:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02014c6:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02014ca:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc02014ce:	0105a803          	lw	a6,16(a1)
ffffffffc02014d2:	e310                	sd	a2,0(a4)
ffffffffc02014d4:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02014d8:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc02014da:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc02014de:	41c8083b          	subw	a6,a6,t3
ffffffffc02014e2:	0000f717          	auipc	a4,0xf
ffffffffc02014e6:	fb072323          	sw	a6,-90(a4) # ffffffffc0210488 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02014ea:	5775                	li	a4,-3
ffffffffc02014ec:	17a1                	addi	a5,a5,-24
ffffffffc02014ee:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02014f2:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02014f4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02014f6:	00004697          	auipc	a3,0x4
ffffffffc02014fa:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0204df0 <commands+0xbf0>
ffffffffc02014fe:	00003617          	auipc	a2,0x3
ffffffffc0201502:	57260613          	addi	a2,a2,1394 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201506:	06200593          	li	a1,98
ffffffffc020150a:	00003517          	auipc	a0,0x3
ffffffffc020150e:	57e50513          	addi	a0,a0,1406 # ffffffffc0204a88 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201512:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201514:	e61fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201518 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201518:	1141                	addi	sp,sp,-16
ffffffffc020151a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020151c:	c1fd                	beqz	a1,ffffffffc0201602 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020151e:	00359693          	slli	a3,a1,0x3
ffffffffc0201522:	96ae                	add	a3,a3,a1
ffffffffc0201524:	068e                	slli	a3,a3,0x3
ffffffffc0201526:	96aa                	add	a3,a3,a0
ffffffffc0201528:	02d50463          	beq	a0,a3,ffffffffc0201550 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020152c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020152e:	87aa                	mv	a5,a0
ffffffffc0201530:	8b05                	andi	a4,a4,1
ffffffffc0201532:	e709                	bnez	a4,ffffffffc020153c <default_init_memmap+0x24>
ffffffffc0201534:	a07d                	j	ffffffffc02015e2 <default_init_memmap+0xca>
ffffffffc0201536:	6798                	ld	a4,8(a5)
ffffffffc0201538:	8b05                	andi	a4,a4,1
ffffffffc020153a:	c745                	beqz	a4,ffffffffc02015e2 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc020153c:	0007ac23          	sw	zero,24(a5)
ffffffffc0201540:	0007b423          	sd	zero,8(a5)
ffffffffc0201544:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201548:	04878793          	addi	a5,a5,72
ffffffffc020154c:	fed795e3          	bne	a5,a3,ffffffffc0201536 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc0201550:	2581                	sext.w	a1,a1
ffffffffc0201552:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201554:	4789                	li	a5,2
ffffffffc0201556:	00850713          	addi	a4,a0,8
ffffffffc020155a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020155e:	0000f697          	auipc	a3,0xf
ffffffffc0201562:	f1a68693          	addi	a3,a3,-230 # ffffffffc0210478 <free_area>
ffffffffc0201566:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201568:	669c                	ld	a5,8(a3)
ffffffffc020156a:	9db9                	addw	a1,a1,a4
ffffffffc020156c:	0000f717          	auipc	a4,0xf
ffffffffc0201570:	f0b72e23          	sw	a1,-228(a4) # ffffffffc0210488 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201574:	04d78a63          	beq	a5,a3,ffffffffc02015c8 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0201578:	fe078713          	addi	a4,a5,-32
ffffffffc020157c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020157e:	4801                	li	a6,0
ffffffffc0201580:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201584:	00e56a63          	bltu	a0,a4,ffffffffc0201598 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0201588:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020158a:	02d70563          	beq	a4,a3,ffffffffc02015b4 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020158e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201590:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201594:	fee57ae3          	bleu	a4,a0,ffffffffc0201588 <default_init_memmap+0x70>
ffffffffc0201598:	00080663          	beqz	a6,ffffffffc02015a4 <default_init_memmap+0x8c>
ffffffffc020159c:	0000f717          	auipc	a4,0xf
ffffffffc02015a0:	ecb73e23          	sd	a1,-292(a4) # ffffffffc0210478 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02015a4:	6398                	ld	a4,0(a5)
}
ffffffffc02015a6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02015a8:	e390                	sd	a2,0(a5)
ffffffffc02015aa:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02015ac:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015ae:	f118                	sd	a4,32(a0)
ffffffffc02015b0:	0141                	addi	sp,sp,16
ffffffffc02015b2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02015b4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015b6:	f514                	sd	a3,40(a0)
ffffffffc02015b8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02015ba:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02015bc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015be:	00d70e63          	beq	a4,a3,ffffffffc02015da <default_init_memmap+0xc2>
ffffffffc02015c2:	4805                	li	a6,1
ffffffffc02015c4:	87ba                	mv	a5,a4
ffffffffc02015c6:	b7e9                	j	ffffffffc0201590 <default_init_memmap+0x78>
}
ffffffffc02015c8:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02015ca:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02015ce:	e398                	sd	a4,0(a5)
ffffffffc02015d0:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02015d2:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015d4:	f11c                	sd	a5,32(a0)
}
ffffffffc02015d6:	0141                	addi	sp,sp,16
ffffffffc02015d8:	8082                	ret
ffffffffc02015da:	60a2                	ld	ra,8(sp)
ffffffffc02015dc:	e290                	sd	a2,0(a3)
ffffffffc02015de:	0141                	addi	sp,sp,16
ffffffffc02015e0:	8082                	ret
        assert(PageReserved(p));
ffffffffc02015e2:	00004697          	auipc	a3,0x4
ffffffffc02015e6:	81668693          	addi	a3,a3,-2026 # ffffffffc0204df8 <commands+0xbf8>
ffffffffc02015ea:	00003617          	auipc	a2,0x3
ffffffffc02015ee:	48660613          	addi	a2,a2,1158 # ffffffffc0204a70 <commands+0x870>
ffffffffc02015f2:	04900593          	li	a1,73
ffffffffc02015f6:	00003517          	auipc	a0,0x3
ffffffffc02015fa:	49250513          	addi	a0,a0,1170 # ffffffffc0204a88 <commands+0x888>
ffffffffc02015fe:	d77fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201602:	00003697          	auipc	a3,0x3
ffffffffc0201606:	7ee68693          	addi	a3,a3,2030 # ffffffffc0204df0 <commands+0xbf0>
ffffffffc020160a:	00003617          	auipc	a2,0x3
ffffffffc020160e:	46660613          	addi	a2,a2,1126 # ffffffffc0204a70 <commands+0x870>
ffffffffc0201612:	04600593          	li	a1,70
ffffffffc0201616:	00003517          	auipc	a0,0x3
ffffffffc020161a:	47250513          	addi	a0,a0,1138 # ffffffffc0204a88 <commands+0x888>
ffffffffc020161e:	d57fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201622 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201622:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201624:	00004617          	auipc	a2,0x4
ffffffffc0201628:	8ac60613          	addi	a2,a2,-1876 # ffffffffc0204ed0 <default_pmm_manager+0xc8>
ffffffffc020162c:	06500593          	li	a1,101
ffffffffc0201630:	00004517          	auipc	a0,0x4
ffffffffc0201634:	8c050513          	addi	a0,a0,-1856 # ffffffffc0204ef0 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201638:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020163a:	d3bfe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020163e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc020163e:	715d                	addi	sp,sp,-80
ffffffffc0201640:	e0a2                	sd	s0,64(sp)
ffffffffc0201642:	fc26                	sd	s1,56(sp)
ffffffffc0201644:	f84a                	sd	s2,48(sp)
ffffffffc0201646:	f44e                	sd	s3,40(sp)
ffffffffc0201648:	f052                	sd	s4,32(sp)
ffffffffc020164a:	ec56                	sd	s5,24(sp)
ffffffffc020164c:	e486                	sd	ra,72(sp)
ffffffffc020164e:	842a                	mv	s0,a0
ffffffffc0201650:	0000f497          	auipc	s1,0xf
ffffffffc0201654:	e4048493          	addi	s1,s1,-448 # ffffffffc0210490 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201658:	4985                	li	s3,1
ffffffffc020165a:	0000fa17          	auipc	s4,0xf
ffffffffc020165e:	e0ea0a13          	addi	s4,s4,-498 # ffffffffc0210468 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201662:	0005091b          	sext.w	s2,a0
ffffffffc0201666:	0000fa97          	auipc	s5,0xf
ffffffffc020166a:	f2aa8a93          	addi	s5,s5,-214 # ffffffffc0210590 <check_mm_struct>
ffffffffc020166e:	a00d                	j	ffffffffc0201690 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201670:	609c                	ld	a5,0(s1)
ffffffffc0201672:	6f9c                	ld	a5,24(a5)
ffffffffc0201674:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201676:	4601                	li	a2,0
ffffffffc0201678:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020167a:	ed0d                	bnez	a0,ffffffffc02016b4 <alloc_pages+0x76>
ffffffffc020167c:	0289ec63          	bltu	s3,s0,ffffffffc02016b4 <alloc_pages+0x76>
ffffffffc0201680:	000a2783          	lw	a5,0(s4)
ffffffffc0201684:	2781                	sext.w	a5,a5
ffffffffc0201686:	c79d                	beqz	a5,ffffffffc02016b4 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201688:	000ab503          	ld	a0,0(s5)
ffffffffc020168c:	021010ef          	jal	ra,ffffffffc0202eac <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201690:	100027f3          	csrr	a5,sstatus
ffffffffc0201694:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201696:	8522                	mv	a0,s0
ffffffffc0201698:	dfe1                	beqz	a5,ffffffffc0201670 <alloc_pages+0x32>
        intr_disable();
ffffffffc020169a:	e3dfe0ef          	jal	ra,ffffffffc02004d6 <intr_disable>
ffffffffc020169e:	609c                	ld	a5,0(s1)
ffffffffc02016a0:	8522                	mv	a0,s0
ffffffffc02016a2:	6f9c                	ld	a5,24(a5)
ffffffffc02016a4:	9782                	jalr	a5
ffffffffc02016a6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02016a8:	e29fe0ef          	jal	ra,ffffffffc02004d0 <intr_enable>
ffffffffc02016ac:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc02016ae:	4601                	li	a2,0
ffffffffc02016b0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016b2:	d569                	beqz	a0,ffffffffc020167c <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc02016b4:	60a6                	ld	ra,72(sp)
ffffffffc02016b6:	6406                	ld	s0,64(sp)
ffffffffc02016b8:	74e2                	ld	s1,56(sp)
ffffffffc02016ba:	7942                	ld	s2,48(sp)
ffffffffc02016bc:	79a2                	ld	s3,40(sp)
ffffffffc02016be:	7a02                	ld	s4,32(sp)
ffffffffc02016c0:	6ae2                	ld	s5,24(sp)
ffffffffc02016c2:	6161                	addi	sp,sp,80
ffffffffc02016c4:	8082                	ret

ffffffffc02016c6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016c6:	100027f3          	csrr	a5,sstatus
ffffffffc02016ca:	8b89                	andi	a5,a5,2
ffffffffc02016cc:	eb89                	bnez	a5,ffffffffc02016de <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc02016ce:	0000f797          	auipc	a5,0xf
ffffffffc02016d2:	dc278793          	addi	a5,a5,-574 # ffffffffc0210490 <pmm_manager>
ffffffffc02016d6:	639c                	ld	a5,0(a5)
ffffffffc02016d8:	0207b303          	ld	t1,32(a5)
ffffffffc02016dc:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc02016de:	1101                	addi	sp,sp,-32
ffffffffc02016e0:	ec06                	sd	ra,24(sp)
ffffffffc02016e2:	e822                	sd	s0,16(sp)
ffffffffc02016e4:	e426                	sd	s1,8(sp)
ffffffffc02016e6:	842a                	mv	s0,a0
ffffffffc02016e8:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02016ea:	dedfe0ef          	jal	ra,ffffffffc02004d6 <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02016ee:	0000f797          	auipc	a5,0xf
ffffffffc02016f2:	da278793          	addi	a5,a5,-606 # ffffffffc0210490 <pmm_manager>
ffffffffc02016f6:	639c                	ld	a5,0(a5)
ffffffffc02016f8:	85a6                	mv	a1,s1
ffffffffc02016fa:	8522                	mv	a0,s0
ffffffffc02016fc:	739c                	ld	a5,32(a5)
ffffffffc02016fe:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201700:	6442                	ld	s0,16(sp)
ffffffffc0201702:	60e2                	ld	ra,24(sp)
ffffffffc0201704:	64a2                	ld	s1,8(sp)
ffffffffc0201706:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201708:	dc9fe06f          	j	ffffffffc02004d0 <intr_enable>

ffffffffc020170c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020170c:	100027f3          	csrr	a5,sstatus
ffffffffc0201710:	8b89                	andi	a5,a5,2
ffffffffc0201712:	eb89                	bnez	a5,ffffffffc0201724 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201714:	0000f797          	auipc	a5,0xf
ffffffffc0201718:	d7c78793          	addi	a5,a5,-644 # ffffffffc0210490 <pmm_manager>
ffffffffc020171c:	639c                	ld	a5,0(a5)
ffffffffc020171e:	0287b303          	ld	t1,40(a5)
ffffffffc0201722:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201724:	1141                	addi	sp,sp,-16
ffffffffc0201726:	e406                	sd	ra,8(sp)
ffffffffc0201728:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020172a:	dadfe0ef          	jal	ra,ffffffffc02004d6 <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020172e:	0000f797          	auipc	a5,0xf
ffffffffc0201732:	d6278793          	addi	a5,a5,-670 # ffffffffc0210490 <pmm_manager>
ffffffffc0201736:	639c                	ld	a5,0(a5)
ffffffffc0201738:	779c                	ld	a5,40(a5)
ffffffffc020173a:	9782                	jalr	a5
ffffffffc020173c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020173e:	d93fe0ef          	jal	ra,ffffffffc02004d0 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201742:	8522                	mv	a0,s0
ffffffffc0201744:	60a2                	ld	ra,8(sp)
ffffffffc0201746:	6402                	ld	s0,0(sp)
ffffffffc0201748:	0141                	addi	sp,sp,16
ffffffffc020174a:	8082                	ret

ffffffffc020174c <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020174c:	715d                	addi	sp,sp,-80
ffffffffc020174e:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201750:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201754:	1ff4f493          	andi	s1,s1,511
ffffffffc0201758:	048e                	slli	s1,s1,0x3
ffffffffc020175a:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc020175c:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020175e:	f84a                	sd	s2,48(sp)
ffffffffc0201760:	f44e                	sd	s3,40(sp)
ffffffffc0201762:	f052                	sd	s4,32(sp)
ffffffffc0201764:	e486                	sd	ra,72(sp)
ffffffffc0201766:	e0a2                	sd	s0,64(sp)
ffffffffc0201768:	ec56                	sd	s5,24(sp)
ffffffffc020176a:	e85a                	sd	s6,16(sp)
ffffffffc020176c:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc020176e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201772:	892e                	mv	s2,a1
ffffffffc0201774:	8a32                	mv	s4,a2
ffffffffc0201776:	0000f997          	auipc	s3,0xf
ffffffffc020177a:	ce298993          	addi	s3,s3,-798 # ffffffffc0210458 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc020177e:	e3c9                	bnez	a5,ffffffffc0201800 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201780:	16060163          	beqz	a2,ffffffffc02018e2 <get_pte+0x196>
ffffffffc0201784:	4505                	li	a0,1
ffffffffc0201786:	eb9ff0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc020178a:	842a                	mv	s0,a0
ffffffffc020178c:	14050b63          	beqz	a0,ffffffffc02018e2 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201790:	0000fb97          	auipc	s7,0xf
ffffffffc0201794:	d18b8b93          	addi	s7,s7,-744 # ffffffffc02104a8 <pages>
ffffffffc0201798:	000bb503          	ld	a0,0(s7)
ffffffffc020179c:	00003797          	auipc	a5,0x3
ffffffffc02017a0:	2bc78793          	addi	a5,a5,700 # ffffffffc0204a58 <commands+0x858>
ffffffffc02017a4:	0007bb03          	ld	s6,0(a5)
ffffffffc02017a8:	40a40533          	sub	a0,s0,a0
ffffffffc02017ac:	850d                	srai	a0,a0,0x3
ffffffffc02017ae:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017b2:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02017b4:	0000f997          	auipc	s3,0xf
ffffffffc02017b8:	ca498993          	addi	s3,s3,-860 # ffffffffc0210458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017bc:	00080ab7          	lui	s5,0x80
ffffffffc02017c0:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017c4:	c01c                	sw	a5,0(s0)
ffffffffc02017c6:	57fd                	li	a5,-1
ffffffffc02017c8:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017ca:	9556                	add	a0,a0,s5
ffffffffc02017cc:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02017ce:	0532                	slli	a0,a0,0xc
ffffffffc02017d0:	16e7f063          	bleu	a4,a5,ffffffffc0201930 <get_pte+0x1e4>
ffffffffc02017d4:	0000f797          	auipc	a5,0xf
ffffffffc02017d8:	cc478793          	addi	a5,a5,-828 # ffffffffc0210498 <va_pa_offset>
ffffffffc02017dc:	639c                	ld	a5,0(a5)
ffffffffc02017de:	6605                	lui	a2,0x1
ffffffffc02017e0:	4581                	li	a1,0
ffffffffc02017e2:	953e                	add	a0,a0,a5
ffffffffc02017e4:	0cb020ef          	jal	ra,ffffffffc02040ae <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017e8:	000bb683          	ld	a3,0(s7)
ffffffffc02017ec:	40d406b3          	sub	a3,s0,a3
ffffffffc02017f0:	868d                	srai	a3,a3,0x3
ffffffffc02017f2:	036686b3          	mul	a3,a3,s6
ffffffffc02017f6:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02017f8:	06aa                	slli	a3,a3,0xa
ffffffffc02017fa:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02017fe:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201800:	77fd                	lui	a5,0xfffff
ffffffffc0201802:	068a                	slli	a3,a3,0x2
ffffffffc0201804:	0009b703          	ld	a4,0(s3)
ffffffffc0201808:	8efd                	and	a3,a3,a5
ffffffffc020180a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020180e:	0ce7fc63          	bleu	a4,a5,ffffffffc02018e6 <get_pte+0x19a>
ffffffffc0201812:	0000fa97          	auipc	s5,0xf
ffffffffc0201816:	c86a8a93          	addi	s5,s5,-890 # ffffffffc0210498 <va_pa_offset>
ffffffffc020181a:	000ab403          	ld	s0,0(s5)
ffffffffc020181e:	01595793          	srli	a5,s2,0x15
ffffffffc0201822:	1ff7f793          	andi	a5,a5,511
ffffffffc0201826:	96a2                	add	a3,a3,s0
ffffffffc0201828:	00379413          	slli	s0,a5,0x3
ffffffffc020182c:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020182e:	6014                	ld	a3,0(s0)
ffffffffc0201830:	0016f793          	andi	a5,a3,1
ffffffffc0201834:	ebbd                	bnez	a5,ffffffffc02018aa <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201836:	0a0a0663          	beqz	s4,ffffffffc02018e2 <get_pte+0x196>
ffffffffc020183a:	4505                	li	a0,1
ffffffffc020183c:	e03ff0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0201840:	84aa                	mv	s1,a0
ffffffffc0201842:	c145                	beqz	a0,ffffffffc02018e2 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201844:	0000fb97          	auipc	s7,0xf
ffffffffc0201848:	c64b8b93          	addi	s7,s7,-924 # ffffffffc02104a8 <pages>
ffffffffc020184c:	000bb503          	ld	a0,0(s7)
ffffffffc0201850:	00003797          	auipc	a5,0x3
ffffffffc0201854:	20878793          	addi	a5,a5,520 # ffffffffc0204a58 <commands+0x858>
ffffffffc0201858:	0007bb03          	ld	s6,0(a5)
ffffffffc020185c:	40a48533          	sub	a0,s1,a0
ffffffffc0201860:	850d                	srai	a0,a0,0x3
ffffffffc0201862:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201866:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201868:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc020186c:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201870:	c09c                	sw	a5,0(s1)
ffffffffc0201872:	57fd                	li	a5,-1
ffffffffc0201874:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201876:	9552                	add	a0,a0,s4
ffffffffc0201878:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020187a:	0532                	slli	a0,a0,0xc
ffffffffc020187c:	08e7fd63          	bleu	a4,a5,ffffffffc0201916 <get_pte+0x1ca>
ffffffffc0201880:	000ab783          	ld	a5,0(s5)
ffffffffc0201884:	6605                	lui	a2,0x1
ffffffffc0201886:	4581                	li	a1,0
ffffffffc0201888:	953e                	add	a0,a0,a5
ffffffffc020188a:	025020ef          	jal	ra,ffffffffc02040ae <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020188e:	000bb683          	ld	a3,0(s7)
ffffffffc0201892:	40d486b3          	sub	a3,s1,a3
ffffffffc0201896:	868d                	srai	a3,a3,0x3
ffffffffc0201898:	036686b3          	mul	a3,a3,s6
ffffffffc020189c:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020189e:	06aa                	slli	a3,a3,0xa
ffffffffc02018a0:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02018a4:	e014                	sd	a3,0(s0)
ffffffffc02018a6:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018aa:	068a                	slli	a3,a3,0x2
ffffffffc02018ac:	757d                	lui	a0,0xfffff
ffffffffc02018ae:	8ee9                	and	a3,a3,a0
ffffffffc02018b0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02018b4:	04e7f563          	bleu	a4,a5,ffffffffc02018fe <get_pte+0x1b2>
ffffffffc02018b8:	000ab503          	ld	a0,0(s5)
ffffffffc02018bc:	00c95793          	srli	a5,s2,0xc
ffffffffc02018c0:	1ff7f793          	andi	a5,a5,511
ffffffffc02018c4:	96aa                	add	a3,a3,a0
ffffffffc02018c6:	00379513          	slli	a0,a5,0x3
ffffffffc02018ca:	9536                	add	a0,a0,a3
}
ffffffffc02018cc:	60a6                	ld	ra,72(sp)
ffffffffc02018ce:	6406                	ld	s0,64(sp)
ffffffffc02018d0:	74e2                	ld	s1,56(sp)
ffffffffc02018d2:	7942                	ld	s2,48(sp)
ffffffffc02018d4:	79a2                	ld	s3,40(sp)
ffffffffc02018d6:	7a02                	ld	s4,32(sp)
ffffffffc02018d8:	6ae2                	ld	s5,24(sp)
ffffffffc02018da:	6b42                	ld	s6,16(sp)
ffffffffc02018dc:	6ba2                	ld	s7,8(sp)
ffffffffc02018de:	6161                	addi	sp,sp,80
ffffffffc02018e0:	8082                	ret
            return NULL;
ffffffffc02018e2:	4501                	li	a0,0
ffffffffc02018e4:	b7e5                	j	ffffffffc02018cc <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02018e6:	00003617          	auipc	a2,0x3
ffffffffc02018ea:	57260613          	addi	a2,a2,1394 # ffffffffc0204e58 <default_pmm_manager+0x50>
ffffffffc02018ee:	10200593          	li	a1,258
ffffffffc02018f2:	00003517          	auipc	a0,0x3
ffffffffc02018f6:	58e50513          	addi	a0,a0,1422 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02018fa:	a7bfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018fe:	00003617          	auipc	a2,0x3
ffffffffc0201902:	55a60613          	addi	a2,a2,1370 # ffffffffc0204e58 <default_pmm_manager+0x50>
ffffffffc0201906:	10f00593          	li	a1,271
ffffffffc020190a:	00003517          	auipc	a0,0x3
ffffffffc020190e:	57650513          	addi	a0,a0,1398 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0201912:	a63fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201916:	86aa                	mv	a3,a0
ffffffffc0201918:	00003617          	auipc	a2,0x3
ffffffffc020191c:	54060613          	addi	a2,a2,1344 # ffffffffc0204e58 <default_pmm_manager+0x50>
ffffffffc0201920:	10b00593          	li	a1,267
ffffffffc0201924:	00003517          	auipc	a0,0x3
ffffffffc0201928:	55c50513          	addi	a0,a0,1372 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc020192c:	a49fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201930:	86aa                	mv	a3,a0
ffffffffc0201932:	00003617          	auipc	a2,0x3
ffffffffc0201936:	52660613          	addi	a2,a2,1318 # ffffffffc0204e58 <default_pmm_manager+0x50>
ffffffffc020193a:	0ff00593          	li	a1,255
ffffffffc020193e:	00003517          	auipc	a0,0x3
ffffffffc0201942:	54250513          	addi	a0,a0,1346 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0201946:	a2ffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020194a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020194a:	1141                	addi	sp,sp,-16
ffffffffc020194c:	e022                	sd	s0,0(sp)
ffffffffc020194e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201950:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201952:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201954:	df9ff0ef          	jal	ra,ffffffffc020174c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201958:	c011                	beqz	s0,ffffffffc020195c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020195a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020195c:	c521                	beqz	a0,ffffffffc02019a4 <get_page+0x5a>
ffffffffc020195e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201960:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201962:	0017f713          	andi	a4,a5,1
ffffffffc0201966:	e709                	bnez	a4,ffffffffc0201970 <get_page+0x26>
}
ffffffffc0201968:	60a2                	ld	ra,8(sp)
ffffffffc020196a:	6402                	ld	s0,0(sp)
ffffffffc020196c:	0141                	addi	sp,sp,16
ffffffffc020196e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201970:	0000f717          	auipc	a4,0xf
ffffffffc0201974:	ae870713          	addi	a4,a4,-1304 # ffffffffc0210458 <npage>
ffffffffc0201978:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020197a:	078a                	slli	a5,a5,0x2
ffffffffc020197c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020197e:	02e7f863          	bleu	a4,a5,ffffffffc02019ae <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc0201982:	fff80537          	lui	a0,0xfff80
ffffffffc0201986:	97aa                	add	a5,a5,a0
ffffffffc0201988:	0000f697          	auipc	a3,0xf
ffffffffc020198c:	b2068693          	addi	a3,a3,-1248 # ffffffffc02104a8 <pages>
ffffffffc0201990:	6288                	ld	a0,0(a3)
ffffffffc0201992:	60a2                	ld	ra,8(sp)
ffffffffc0201994:	6402                	ld	s0,0(sp)
ffffffffc0201996:	00379713          	slli	a4,a5,0x3
ffffffffc020199a:	97ba                	add	a5,a5,a4
ffffffffc020199c:	078e                	slli	a5,a5,0x3
ffffffffc020199e:	953e                	add	a0,a0,a5
ffffffffc02019a0:	0141                	addi	sp,sp,16
ffffffffc02019a2:	8082                	ret
ffffffffc02019a4:	60a2                	ld	ra,8(sp)
ffffffffc02019a6:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02019a8:	4501                	li	a0,0
}
ffffffffc02019aa:	0141                	addi	sp,sp,16
ffffffffc02019ac:	8082                	ret
ffffffffc02019ae:	c75ff0ef          	jal	ra,ffffffffc0201622 <pa2page.part.4>

ffffffffc02019b2 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02019b2:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019b4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02019b6:	e406                	sd	ra,8(sp)
ffffffffc02019b8:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019ba:	d93ff0ef          	jal	ra,ffffffffc020174c <get_pte>
    if (ptep != NULL) {
ffffffffc02019be:	c511                	beqz	a0,ffffffffc02019ca <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02019c0:	611c                	ld	a5,0(a0)
ffffffffc02019c2:	842a                	mv	s0,a0
ffffffffc02019c4:	0017f713          	andi	a4,a5,1
ffffffffc02019c8:	e709                	bnez	a4,ffffffffc02019d2 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc02019ca:	60a2                	ld	ra,8(sp)
ffffffffc02019cc:	6402                	ld	s0,0(sp)
ffffffffc02019ce:	0141                	addi	sp,sp,16
ffffffffc02019d0:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02019d2:	0000f717          	auipc	a4,0xf
ffffffffc02019d6:	a8670713          	addi	a4,a4,-1402 # ffffffffc0210458 <npage>
ffffffffc02019da:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019dc:	078a                	slli	a5,a5,0x2
ffffffffc02019de:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019e0:	04e7f063          	bleu	a4,a5,ffffffffc0201a20 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc02019e4:	fff80737          	lui	a4,0xfff80
ffffffffc02019e8:	97ba                	add	a5,a5,a4
ffffffffc02019ea:	0000f717          	auipc	a4,0xf
ffffffffc02019ee:	abe70713          	addi	a4,a4,-1346 # ffffffffc02104a8 <pages>
ffffffffc02019f2:	6308                	ld	a0,0(a4)
ffffffffc02019f4:	00379713          	slli	a4,a5,0x3
ffffffffc02019f8:	97ba                	add	a5,a5,a4
ffffffffc02019fa:	078e                	slli	a5,a5,0x3
ffffffffc02019fc:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02019fe:	411c                	lw	a5,0(a0)
ffffffffc0201a00:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a04:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201a06:	cb09                	beqz	a4,ffffffffc0201a18 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a08:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a0c:	12000073          	sfence.vma
}
ffffffffc0201a10:	60a2                	ld	ra,8(sp)
ffffffffc0201a12:	6402                	ld	s0,0(sp)
ffffffffc0201a14:	0141                	addi	sp,sp,16
ffffffffc0201a16:	8082                	ret
            free_page(page);
ffffffffc0201a18:	4585                	li	a1,1
ffffffffc0201a1a:	cadff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
ffffffffc0201a1e:	b7ed                	j	ffffffffc0201a08 <page_remove+0x56>
ffffffffc0201a20:	c03ff0ef          	jal	ra,ffffffffc0201622 <pa2page.part.4>

ffffffffc0201a24 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a24:	7179                	addi	sp,sp,-48
ffffffffc0201a26:	87b2                	mv	a5,a2
ffffffffc0201a28:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a2a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a2c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a2e:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a30:	ec26                	sd	s1,24(sp)
ffffffffc0201a32:	f406                	sd	ra,40(sp)
ffffffffc0201a34:	e84a                	sd	s2,16(sp)
ffffffffc0201a36:	e44e                	sd	s3,8(sp)
ffffffffc0201a38:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a3a:	d13ff0ef          	jal	ra,ffffffffc020174c <get_pte>
    if (ptep == NULL) {
ffffffffc0201a3e:	c945                	beqz	a0,ffffffffc0201aee <page_insert+0xca>
    page->ref += 1;
ffffffffc0201a40:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a42:	611c                	ld	a5,0(a0)
ffffffffc0201a44:	892a                	mv	s2,a0
ffffffffc0201a46:	0016871b          	addiw	a4,a3,1
ffffffffc0201a4a:	c018                	sw	a4,0(s0)
ffffffffc0201a4c:	0017f713          	andi	a4,a5,1
ffffffffc0201a50:	e339                	bnez	a4,ffffffffc0201a96 <page_insert+0x72>
ffffffffc0201a52:	0000f797          	auipc	a5,0xf
ffffffffc0201a56:	a5678793          	addi	a5,a5,-1450 # ffffffffc02104a8 <pages>
ffffffffc0201a5a:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a5c:	00003717          	auipc	a4,0x3
ffffffffc0201a60:	ffc70713          	addi	a4,a4,-4 # ffffffffc0204a58 <commands+0x858>
ffffffffc0201a64:	40f407b3          	sub	a5,s0,a5
ffffffffc0201a68:	6300                	ld	s0,0(a4)
ffffffffc0201a6a:	878d                	srai	a5,a5,0x3
ffffffffc0201a6c:	000806b7          	lui	a3,0x80
ffffffffc0201a70:	028787b3          	mul	a5,a5,s0
ffffffffc0201a74:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a76:	07aa                	slli	a5,a5,0xa
ffffffffc0201a78:	8fc5                	or	a5,a5,s1
ffffffffc0201a7a:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a7e:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a82:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a86:	4501                	li	a0,0
}
ffffffffc0201a88:	70a2                	ld	ra,40(sp)
ffffffffc0201a8a:	7402                	ld	s0,32(sp)
ffffffffc0201a8c:	64e2                	ld	s1,24(sp)
ffffffffc0201a8e:	6942                	ld	s2,16(sp)
ffffffffc0201a90:	69a2                	ld	s3,8(sp)
ffffffffc0201a92:	6145                	addi	sp,sp,48
ffffffffc0201a94:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a96:	0000f717          	auipc	a4,0xf
ffffffffc0201a9a:	9c270713          	addi	a4,a4,-1598 # ffffffffc0210458 <npage>
ffffffffc0201a9e:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201aa0:	00279513          	slli	a0,a5,0x2
ffffffffc0201aa4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201aa6:	04e57663          	bleu	a4,a0,ffffffffc0201af2 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201aaa:	fff807b7          	lui	a5,0xfff80
ffffffffc0201aae:	953e                	add	a0,a0,a5
ffffffffc0201ab0:	0000f997          	auipc	s3,0xf
ffffffffc0201ab4:	9f898993          	addi	s3,s3,-1544 # ffffffffc02104a8 <pages>
ffffffffc0201ab8:	0009b783          	ld	a5,0(s3)
ffffffffc0201abc:	00351713          	slli	a4,a0,0x3
ffffffffc0201ac0:	953a                	add	a0,a0,a4
ffffffffc0201ac2:	050e                	slli	a0,a0,0x3
ffffffffc0201ac4:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201ac6:	00a40e63          	beq	s0,a0,ffffffffc0201ae2 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201aca:	411c                	lw	a5,0(a0)
ffffffffc0201acc:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201ad0:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201ad2:	cb11                	beqz	a4,ffffffffc0201ae6 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201ad4:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201ad8:	12000073          	sfence.vma
ffffffffc0201adc:	0009b783          	ld	a5,0(s3)
ffffffffc0201ae0:	bfb5                	j	ffffffffc0201a5c <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201ae2:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201ae4:	bfa5                	j	ffffffffc0201a5c <page_insert+0x38>
            free_page(page);
ffffffffc0201ae6:	4585                	li	a1,1
ffffffffc0201ae8:	bdfff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
ffffffffc0201aec:	b7e5                	j	ffffffffc0201ad4 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201aee:	5571                	li	a0,-4
ffffffffc0201af0:	bf61                	j	ffffffffc0201a88 <page_insert+0x64>
ffffffffc0201af2:	b31ff0ef          	jal	ra,ffffffffc0201622 <pa2page.part.4>

ffffffffc0201af6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201af6:	00003797          	auipc	a5,0x3
ffffffffc0201afa:	31278793          	addi	a5,a5,786 # ffffffffc0204e08 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201afe:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b00:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b02:	00003517          	auipc	a0,0x3
ffffffffc0201b06:	41650513          	addi	a0,a0,1046 # ffffffffc0204f18 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201b0a:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b0c:	0000f717          	auipc	a4,0xf
ffffffffc0201b10:	98f73223          	sd	a5,-1660(a4) # ffffffffc0210490 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b14:	e8a2                	sd	s0,80(sp)
ffffffffc0201b16:	e4a6                	sd	s1,72(sp)
ffffffffc0201b18:	e0ca                	sd	s2,64(sp)
ffffffffc0201b1a:	fc4e                	sd	s3,56(sp)
ffffffffc0201b1c:	f852                	sd	s4,48(sp)
ffffffffc0201b1e:	f456                	sd	s5,40(sp)
ffffffffc0201b20:	f05a                	sd	s6,32(sp)
ffffffffc0201b22:	ec5e                	sd	s7,24(sp)
ffffffffc0201b24:	e862                	sd	s8,16(sp)
ffffffffc0201b26:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b28:	0000f417          	auipc	s0,0xf
ffffffffc0201b2c:	96840413          	addi	s0,s0,-1688 # ffffffffc0210490 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b30:	d8efe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201b34:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b36:	49c5                	li	s3,17
ffffffffc0201b38:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201b3c:	679c                	ld	a5,8(a5)
ffffffffc0201b3e:	0000f497          	auipc	s1,0xf
ffffffffc0201b42:	91a48493          	addi	s1,s1,-1766 # ffffffffc0210458 <npage>
ffffffffc0201b46:	0000f917          	auipc	s2,0xf
ffffffffc0201b4a:	96290913          	addi	s2,s2,-1694 # ffffffffc02104a8 <pages>
ffffffffc0201b4e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b50:	57f5                	li	a5,-3
ffffffffc0201b52:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b54:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b58:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201b5c:	015a1593          	slli	a1,s4,0x15
ffffffffc0201b60:	00003517          	auipc	a0,0x3
ffffffffc0201b64:	3d050513          	addi	a0,a0,976 # ffffffffc0204f30 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b68:	0000f717          	auipc	a4,0xf
ffffffffc0201b6c:	92f73823          	sd	a5,-1744(a4) # ffffffffc0210498 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b70:	d4efe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b74:	00003517          	auipc	a0,0x3
ffffffffc0201b78:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204f60 <default_pmm_manager+0x158>
ffffffffc0201b7c:	d42fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b80:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201b84:	16fd                	addi	a3,a3,-1
ffffffffc0201b86:	015a1613          	slli	a2,s4,0x15
ffffffffc0201b8a:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b8e:	00003517          	auipc	a0,0x3
ffffffffc0201b92:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204f78 <default_pmm_manager+0x170>
ffffffffc0201b96:	d28fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b9a:	777d                	lui	a4,0xfffff
ffffffffc0201b9c:	00010797          	auipc	a5,0x10
ffffffffc0201ba0:	9fb78793          	addi	a5,a5,-1541 # ffffffffc0211597 <end+0xfff>
ffffffffc0201ba4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201ba6:	00088737          	lui	a4,0x88
ffffffffc0201baa:	0000f697          	auipc	a3,0xf
ffffffffc0201bae:	8ae6b723          	sd	a4,-1874(a3) # ffffffffc0210458 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bb2:	0000f717          	auipc	a4,0xf
ffffffffc0201bb6:	8ef73b23          	sd	a5,-1802(a4) # ffffffffc02104a8 <pages>
ffffffffc0201bba:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bbc:	4701                	li	a4,0
ffffffffc0201bbe:	4585                	li	a1,1
ffffffffc0201bc0:	fff80637          	lui	a2,0xfff80
ffffffffc0201bc4:	a019                	j	ffffffffc0201bca <pmm_init+0xd4>
ffffffffc0201bc6:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201bca:	97b6                	add	a5,a5,a3
ffffffffc0201bcc:	07a1                	addi	a5,a5,8
ffffffffc0201bce:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bd2:	609c                	ld	a5,0(s1)
ffffffffc0201bd4:	0705                	addi	a4,a4,1
ffffffffc0201bd6:	04868693          	addi	a3,a3,72
ffffffffc0201bda:	00c78533          	add	a0,a5,a2
ffffffffc0201bde:	fea764e3          	bltu	a4,a0,ffffffffc0201bc6 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201be2:	00093503          	ld	a0,0(s2)
ffffffffc0201be6:	00379693          	slli	a3,a5,0x3
ffffffffc0201bea:	96be                	add	a3,a3,a5
ffffffffc0201bec:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201bf0:	972a                	add	a4,a4,a0
ffffffffc0201bf2:	068e                	slli	a3,a3,0x3
ffffffffc0201bf4:	96ba                	add	a3,a3,a4
ffffffffc0201bf6:	c0200737          	lui	a4,0xc0200
ffffffffc0201bfa:	58e6ea63          	bltu	a3,a4,ffffffffc020218e <pmm_init+0x698>
ffffffffc0201bfe:	0000f997          	auipc	s3,0xf
ffffffffc0201c02:	89a98993          	addi	s3,s3,-1894 # ffffffffc0210498 <va_pa_offset>
ffffffffc0201c06:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c0a:	45c5                	li	a1,17
ffffffffc0201c0c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c0e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c10:	44b6ef63          	bltu	a3,a1,ffffffffc020206e <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c14:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c16:	0000f417          	auipc	s0,0xf
ffffffffc0201c1a:	83a40413          	addi	s0,s0,-1990 # ffffffffc0210450 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c1e:	7b9c                	ld	a5,48(a5)
ffffffffc0201c20:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c22:	00003517          	auipc	a0,0x3
ffffffffc0201c26:	3a650513          	addi	a0,a0,934 # ffffffffc0204fc8 <default_pmm_manager+0x1c0>
ffffffffc0201c2a:	c94fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c2e:	00006697          	auipc	a3,0x6
ffffffffc0201c32:	3d268693          	addi	a3,a3,978 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc0201c36:	0000f797          	auipc	a5,0xf
ffffffffc0201c3a:	80d7bd23          	sd	a3,-2022(a5) # ffffffffc0210450 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c3e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c42:	0ef6ece3          	bltu	a3,a5,ffffffffc020253a <pmm_init+0xa44>
ffffffffc0201c46:	0009b783          	ld	a5,0(s3)
ffffffffc0201c4a:	8e9d                	sub	a3,a3,a5
ffffffffc0201c4c:	0000f797          	auipc	a5,0xf
ffffffffc0201c50:	84d7ba23          	sd	a3,-1964(a5) # ffffffffc02104a0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201c54:	ab9ff0ef          	jal	ra,ffffffffc020170c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c58:	6098                	ld	a4,0(s1)
ffffffffc0201c5a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c5e:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201c60:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c62:	0ae7ece3          	bltu	a5,a4,ffffffffc020251a <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c66:	6008                	ld	a0,0(s0)
ffffffffc0201c68:	4c050363          	beqz	a0,ffffffffc020212e <pmm_init+0x638>
ffffffffc0201c6c:	6785                	lui	a5,0x1
ffffffffc0201c6e:	17fd                	addi	a5,a5,-1
ffffffffc0201c70:	8fe9                	and	a5,a5,a0
ffffffffc0201c72:	2781                	sext.w	a5,a5
ffffffffc0201c74:	4a079d63          	bnez	a5,ffffffffc020212e <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c78:	4601                	li	a2,0
ffffffffc0201c7a:	4581                	li	a1,0
ffffffffc0201c7c:	ccfff0ef          	jal	ra,ffffffffc020194a <get_page>
ffffffffc0201c80:	4c051763          	bnez	a0,ffffffffc020214e <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201c84:	4505                	li	a0,1
ffffffffc0201c86:	9b9ff0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0201c8a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c8c:	6008                	ld	a0,0(s0)
ffffffffc0201c8e:	4681                	li	a3,0
ffffffffc0201c90:	4601                	li	a2,0
ffffffffc0201c92:	85d6                	mv	a1,s5
ffffffffc0201c94:	d91ff0ef          	jal	ra,ffffffffc0201a24 <page_insert>
ffffffffc0201c98:	52051763          	bnez	a0,ffffffffc02021c6 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201c9c:	6008                	ld	a0,0(s0)
ffffffffc0201c9e:	4601                	li	a2,0
ffffffffc0201ca0:	4581                	li	a1,0
ffffffffc0201ca2:	aabff0ef          	jal	ra,ffffffffc020174c <get_pte>
ffffffffc0201ca6:	50050063          	beqz	a0,ffffffffc02021a6 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201caa:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201cac:	0017f713          	andi	a4,a5,1
ffffffffc0201cb0:	46070363          	beqz	a4,ffffffffc0202116 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201cb4:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201cb6:	078a                	slli	a5,a5,0x2
ffffffffc0201cb8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201cba:	44c7f063          	bleu	a2,a5,ffffffffc02020fa <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cbe:	fff80737          	lui	a4,0xfff80
ffffffffc0201cc2:	97ba                	add	a5,a5,a4
ffffffffc0201cc4:	00379713          	slli	a4,a5,0x3
ffffffffc0201cc8:	00093683          	ld	a3,0(s2)
ffffffffc0201ccc:	97ba                	add	a5,a5,a4
ffffffffc0201cce:	078e                	slli	a5,a5,0x3
ffffffffc0201cd0:	97b6                	add	a5,a5,a3
ffffffffc0201cd2:	5efa9463          	bne	s5,a5,ffffffffc02022ba <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0201cd6:	000aab83          	lw	s7,0(s5)
ffffffffc0201cda:	4785                	li	a5,1
ffffffffc0201cdc:	5afb9f63          	bne	s7,a5,ffffffffc020229a <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201ce0:	6008                	ld	a0,0(s0)
ffffffffc0201ce2:	76fd                	lui	a3,0xfffff
ffffffffc0201ce4:	611c                	ld	a5,0(a0)
ffffffffc0201ce6:	078a                	slli	a5,a5,0x2
ffffffffc0201ce8:	8ff5                	and	a5,a5,a3
ffffffffc0201cea:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201cee:	58c77963          	bleu	a2,a4,ffffffffc0202280 <pmm_init+0x78a>
ffffffffc0201cf2:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cf6:	97e2                	add	a5,a5,s8
ffffffffc0201cf8:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201cfc:	0b0a                	slli	s6,s6,0x2
ffffffffc0201cfe:	00db7b33          	and	s6,s6,a3
ffffffffc0201d02:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201d06:	56c7f063          	bleu	a2,a5,ffffffffc0202266 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d0a:	4601                	li	a2,0
ffffffffc0201d0c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d0e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d10:	a3dff0ef          	jal	ra,ffffffffc020174c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d14:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d16:	53651863          	bne	a0,s6,ffffffffc0202246 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc0201d1a:	4505                	li	a0,1
ffffffffc0201d1c:	923ff0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0201d20:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d22:	6008                	ld	a0,0(s0)
ffffffffc0201d24:	46d1                	li	a3,20
ffffffffc0201d26:	6605                	lui	a2,0x1
ffffffffc0201d28:	85da                	mv	a1,s6
ffffffffc0201d2a:	cfbff0ef          	jal	ra,ffffffffc0201a24 <page_insert>
ffffffffc0201d2e:	4e051c63          	bnez	a0,ffffffffc0202226 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d32:	6008                	ld	a0,0(s0)
ffffffffc0201d34:	4601                	li	a2,0
ffffffffc0201d36:	6585                	lui	a1,0x1
ffffffffc0201d38:	a15ff0ef          	jal	ra,ffffffffc020174c <get_pte>
ffffffffc0201d3c:	4c050563          	beqz	a0,ffffffffc0202206 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc0201d40:	611c                	ld	a5,0(a0)
ffffffffc0201d42:	0107f713          	andi	a4,a5,16
ffffffffc0201d46:	4a070063          	beqz	a4,ffffffffc02021e6 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0201d4a:	8b91                	andi	a5,a5,4
ffffffffc0201d4c:	66078763          	beqz	a5,ffffffffc02023ba <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d50:	6008                	ld	a0,0(s0)
ffffffffc0201d52:	611c                	ld	a5,0(a0)
ffffffffc0201d54:	8bc1                	andi	a5,a5,16
ffffffffc0201d56:	64078263          	beqz	a5,ffffffffc020239a <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201d5a:	000b2783          	lw	a5,0(s6)
ffffffffc0201d5e:	61779e63          	bne	a5,s7,ffffffffc020237a <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d62:	4681                	li	a3,0
ffffffffc0201d64:	6605                	lui	a2,0x1
ffffffffc0201d66:	85d6                	mv	a1,s5
ffffffffc0201d68:	cbdff0ef          	jal	ra,ffffffffc0201a24 <page_insert>
ffffffffc0201d6c:	5e051763          	bnez	a0,ffffffffc020235a <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc0201d70:	000aa703          	lw	a4,0(s5)
ffffffffc0201d74:	4789                	li	a5,2
ffffffffc0201d76:	5cf71263          	bne	a4,a5,ffffffffc020233a <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201d7a:	000b2783          	lw	a5,0(s6)
ffffffffc0201d7e:	58079e63          	bnez	a5,ffffffffc020231a <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d82:	6008                	ld	a0,0(s0)
ffffffffc0201d84:	4601                	li	a2,0
ffffffffc0201d86:	6585                	lui	a1,0x1
ffffffffc0201d88:	9c5ff0ef          	jal	ra,ffffffffc020174c <get_pte>
ffffffffc0201d8c:	56050763          	beqz	a0,ffffffffc02022fa <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d90:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d92:	0016f793          	andi	a5,a3,1
ffffffffc0201d96:	38078063          	beqz	a5,ffffffffc0202116 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201d9a:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d9c:	00269793          	slli	a5,a3,0x2
ffffffffc0201da0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201da2:	34e7fc63          	bleu	a4,a5,ffffffffc02020fa <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201da6:	fff80737          	lui	a4,0xfff80
ffffffffc0201daa:	97ba                	add	a5,a5,a4
ffffffffc0201dac:	00379713          	slli	a4,a5,0x3
ffffffffc0201db0:	00093603          	ld	a2,0(s2)
ffffffffc0201db4:	97ba                	add	a5,a5,a4
ffffffffc0201db6:	078e                	slli	a5,a5,0x3
ffffffffc0201db8:	97b2                	add	a5,a5,a2
ffffffffc0201dba:	52fa9063          	bne	s5,a5,ffffffffc02022da <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201dbe:	8ac1                	andi	a3,a3,16
ffffffffc0201dc0:	6e069d63          	bnez	a3,ffffffffc02024ba <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201dc4:	6008                	ld	a0,0(s0)
ffffffffc0201dc6:	4581                	li	a1,0
ffffffffc0201dc8:	bebff0ef          	jal	ra,ffffffffc02019b2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201dcc:	000aa703          	lw	a4,0(s5)
ffffffffc0201dd0:	4785                	li	a5,1
ffffffffc0201dd2:	6cf71463          	bne	a4,a5,ffffffffc020249a <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0201dd6:	000b2783          	lw	a5,0(s6)
ffffffffc0201dda:	6a079063          	bnez	a5,ffffffffc020247a <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201dde:	6008                	ld	a0,0(s0)
ffffffffc0201de0:	6585                	lui	a1,0x1
ffffffffc0201de2:	bd1ff0ef          	jal	ra,ffffffffc02019b2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201de6:	000aa783          	lw	a5,0(s5)
ffffffffc0201dea:	66079863          	bnez	a5,ffffffffc020245a <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc0201dee:	000b2783          	lw	a5,0(s6)
ffffffffc0201df2:	70079463          	bnez	a5,ffffffffc02024fa <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201df6:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201dfa:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201dfc:	000b3783          	ld	a5,0(s6)
ffffffffc0201e00:	078a                	slli	a5,a5,0x2
ffffffffc0201e02:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e04:	2eb7fb63          	bleu	a1,a5,ffffffffc02020fa <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e08:	fff80737          	lui	a4,0xfff80
ffffffffc0201e0c:	973e                	add	a4,a4,a5
ffffffffc0201e0e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e12:	00093603          	ld	a2,0(s2)
ffffffffc0201e16:	97ba                	add	a5,a5,a4
ffffffffc0201e18:	078e                	slli	a5,a5,0x3
ffffffffc0201e1a:	00f60733          	add	a4,a2,a5
ffffffffc0201e1e:	4314                	lw	a3,0(a4)
ffffffffc0201e20:	4705                	li	a4,1
ffffffffc0201e22:	6ae69c63          	bne	a3,a4,ffffffffc02024da <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e26:	00003a97          	auipc	s5,0x3
ffffffffc0201e2a:	c32a8a93          	addi	s5,s5,-974 # ffffffffc0204a58 <commands+0x858>
ffffffffc0201e2e:	000ab703          	ld	a4,0(s5)
ffffffffc0201e32:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e36:	00080bb7          	lui	s7,0x80
ffffffffc0201e3a:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e3e:	577d                	li	a4,-1
ffffffffc0201e40:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e42:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e44:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e46:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e48:	2ab77b63          	bleu	a1,a4,ffffffffc02020fe <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e4c:	0009b783          	ld	a5,0(s3)
ffffffffc0201e50:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e52:	629c                	ld	a5,0(a3)
ffffffffc0201e54:	078a                	slli	a5,a5,0x2
ffffffffc0201e56:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e58:	2ab7f163          	bleu	a1,a5,ffffffffc02020fa <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e5c:	417787b3          	sub	a5,a5,s7
ffffffffc0201e60:	00379513          	slli	a0,a5,0x3
ffffffffc0201e64:	97aa                	add	a5,a5,a0
ffffffffc0201e66:	00379513          	slli	a0,a5,0x3
ffffffffc0201e6a:	9532                	add	a0,a0,a2
ffffffffc0201e6c:	4585                	li	a1,1
ffffffffc0201e6e:	859ff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e72:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201e76:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e78:	050a                	slli	a0,a0,0x2
ffffffffc0201e7a:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e7c:	26f57f63          	bleu	a5,a0,ffffffffc02020fa <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e80:	417507b3          	sub	a5,a0,s7
ffffffffc0201e84:	00379513          	slli	a0,a5,0x3
ffffffffc0201e88:	00093703          	ld	a4,0(s2)
ffffffffc0201e8c:	953e                	add	a0,a0,a5
ffffffffc0201e8e:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201e90:	4585                	li	a1,1
ffffffffc0201e92:	953a                	add	a0,a0,a4
ffffffffc0201e94:	833ff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201e98:	601c                	ld	a5,0(s0)
ffffffffc0201e9a:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201e9e:	86fff0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc0201ea2:	2caa1663          	bne	s4,a0,ffffffffc020216e <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ea6:	00003517          	auipc	a0,0x3
ffffffffc0201eaa:	43250513          	addi	a0,a0,1074 # ffffffffc02052d8 <default_pmm_manager+0x4d0>
ffffffffc0201eae:	a10fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201eb2:	85bff0ef          	jal	ra,ffffffffc020170c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201eb6:	6098                	ld	a4,0(s1)
ffffffffc0201eb8:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201ebc:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ebe:	00c71693          	slli	a3,a4,0xc
ffffffffc0201ec2:	1cd7fd63          	bleu	a3,a5,ffffffffc020209c <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ec6:	83b1                	srli	a5,a5,0xc
ffffffffc0201ec8:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201eca:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ece:	1ce7f963          	bleu	a4,a5,ffffffffc02020a0 <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ed2:	7c7d                	lui	s8,0xfffff
ffffffffc0201ed4:	6b85                	lui	s7,0x1
ffffffffc0201ed6:	a029                	j	ffffffffc0201ee0 <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ed8:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201edc:	1cf77263          	bleu	a5,a4,ffffffffc02020a0 <pmm_init+0x5aa>
ffffffffc0201ee0:	0009b583          	ld	a1,0(s3)
ffffffffc0201ee4:	4601                	li	a2,0
ffffffffc0201ee6:	95d2                	add	a1,a1,s4
ffffffffc0201ee8:	865ff0ef          	jal	ra,ffffffffc020174c <get_pte>
ffffffffc0201eec:	1c050763          	beqz	a0,ffffffffc02020ba <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ef0:	611c                	ld	a5,0(a0)
ffffffffc0201ef2:	078a                	slli	a5,a5,0x2
ffffffffc0201ef4:	0187f7b3          	and	a5,a5,s8
ffffffffc0201ef8:	1f479163          	bne	a5,s4,ffffffffc02020da <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201efc:	609c                	ld	a5,0(s1)
ffffffffc0201efe:	9a5e                	add	s4,s4,s7
ffffffffc0201f00:	6008                	ld	a0,0(s0)
ffffffffc0201f02:	00c79713          	slli	a4,a5,0xc
ffffffffc0201f06:	fcea69e3          	bltu	s4,a4,ffffffffc0201ed8 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f0a:	611c                	ld	a5,0(a0)
ffffffffc0201f0c:	6a079363          	bnez	a5,ffffffffc02025b2 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f10:	4505                	li	a0,1
ffffffffc0201f12:	f2cff0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0201f16:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f18:	6008                	ld	a0,0(s0)
ffffffffc0201f1a:	4699                	li	a3,6
ffffffffc0201f1c:	10000613          	li	a2,256
ffffffffc0201f20:	85d2                	mv	a1,s4
ffffffffc0201f22:	b03ff0ef          	jal	ra,ffffffffc0201a24 <page_insert>
ffffffffc0201f26:	66051663          	bnez	a0,ffffffffc0202592 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0201f2a:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201f2e:	4785                	li	a5,1
ffffffffc0201f30:	64f71163          	bne	a4,a5,ffffffffc0202572 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f34:	6008                	ld	a0,0(s0)
ffffffffc0201f36:	6b85                	lui	s7,0x1
ffffffffc0201f38:	4699                	li	a3,6
ffffffffc0201f3a:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201f3e:	85d2                	mv	a1,s4
ffffffffc0201f40:	ae5ff0ef          	jal	ra,ffffffffc0201a24 <page_insert>
ffffffffc0201f44:	60051763          	bnez	a0,ffffffffc0202552 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0201f48:	000a2703          	lw	a4,0(s4)
ffffffffc0201f4c:	4789                	li	a5,2
ffffffffc0201f4e:	4ef71663          	bne	a4,a5,ffffffffc020243a <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f52:	00003597          	auipc	a1,0x3
ffffffffc0201f56:	4be58593          	addi	a1,a1,1214 # ffffffffc0205410 <default_pmm_manager+0x608>
ffffffffc0201f5a:	10000513          	li	a0,256
ffffffffc0201f5e:	0f6020ef          	jal	ra,ffffffffc0204054 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f62:	100b8593          	addi	a1,s7,256
ffffffffc0201f66:	10000513          	li	a0,256
ffffffffc0201f6a:	0fc020ef          	jal	ra,ffffffffc0204066 <strcmp>
ffffffffc0201f6e:	4a051663          	bnez	a0,ffffffffc020241a <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f72:	00093683          	ld	a3,0(s2)
ffffffffc0201f76:	000abc83          	ld	s9,0(s5)
ffffffffc0201f7a:	00080c37          	lui	s8,0x80
ffffffffc0201f7e:	40da06b3          	sub	a3,s4,a3
ffffffffc0201f82:	868d                	srai	a3,a3,0x3
ffffffffc0201f84:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f88:	5afd                	li	s5,-1
ffffffffc0201f8a:	609c                	ld	a5,0(s1)
ffffffffc0201f8c:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f90:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f92:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f96:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f98:	16f77363          	bleu	a5,a4,ffffffffc02020fe <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201f9c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fa0:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fa4:	96be                	add	a3,a3,a5
ffffffffc0201fa6:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdeeb68>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201faa:	066020ef          	jal	ra,ffffffffc0204010 <strlen>
ffffffffc0201fae:	44051663          	bnez	a0,ffffffffc02023fa <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201fb2:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201fb6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fb8:	000bb783          	ld	a5,0(s7)
ffffffffc0201fbc:	078a                	slli	a5,a5,0x2
ffffffffc0201fbe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fc0:	12e7fd63          	bleu	a4,a5,ffffffffc02020fa <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fc4:	418787b3          	sub	a5,a5,s8
ffffffffc0201fc8:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fcc:	96be                	add	a3,a3,a5
ffffffffc0201fce:	039686b3          	mul	a3,a3,s9
ffffffffc0201fd2:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fd4:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fd8:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fda:	12eaf263          	bleu	a4,s5,ffffffffc02020fe <pmm_init+0x608>
ffffffffc0201fde:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201fe2:	4585                	li	a1,1
ffffffffc0201fe4:	8552                	mv	a0,s4
ffffffffc0201fe6:	99b6                	add	s3,s3,a3
ffffffffc0201fe8:	edeff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fec:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201ff0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ff2:	078a                	slli	a5,a5,0x2
ffffffffc0201ff4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ff6:	10e7f263          	bleu	a4,a5,ffffffffc02020fa <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ffa:	fff809b7          	lui	s3,0xfff80
ffffffffc0201ffe:	97ce                	add	a5,a5,s3
ffffffffc0202000:	00379513          	slli	a0,a5,0x3
ffffffffc0202004:	00093703          	ld	a4,0(s2)
ffffffffc0202008:	97aa                	add	a5,a5,a0
ffffffffc020200a:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020200e:	953a                	add	a0,a0,a4
ffffffffc0202010:	4585                	li	a1,1
ffffffffc0202012:	eb4ff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202016:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020201a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020201c:	050a                	slli	a0,a0,0x2
ffffffffc020201e:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202020:	0cf57d63          	bleu	a5,a0,ffffffffc02020fa <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202024:	013507b3          	add	a5,a0,s3
ffffffffc0202028:	00379513          	slli	a0,a5,0x3
ffffffffc020202c:	00093703          	ld	a4,0(s2)
ffffffffc0202030:	953e                	add	a0,a0,a5
ffffffffc0202032:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0202034:	4585                	li	a1,1
ffffffffc0202036:	953a                	add	a0,a0,a4
ffffffffc0202038:	e8eff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020203c:	601c                	ld	a5,0(s0)
ffffffffc020203e:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc0202042:	ecaff0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc0202046:	38ab1a63          	bne	s6,a0,ffffffffc02023da <pmm_init+0x8e4>
}
ffffffffc020204a:	6446                	ld	s0,80(sp)
ffffffffc020204c:	60e6                	ld	ra,88(sp)
ffffffffc020204e:	64a6                	ld	s1,72(sp)
ffffffffc0202050:	6906                	ld	s2,64(sp)
ffffffffc0202052:	79e2                	ld	s3,56(sp)
ffffffffc0202054:	7a42                	ld	s4,48(sp)
ffffffffc0202056:	7aa2                	ld	s5,40(sp)
ffffffffc0202058:	7b02                	ld	s6,32(sp)
ffffffffc020205a:	6be2                	ld	s7,24(sp)
ffffffffc020205c:	6c42                	ld	s8,16(sp)
ffffffffc020205e:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202060:	00003517          	auipc	a0,0x3
ffffffffc0202064:	42850513          	addi	a0,a0,1064 # ffffffffc0205488 <default_pmm_manager+0x680>
}
ffffffffc0202068:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020206a:	854fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020206e:	6705                	lui	a4,0x1
ffffffffc0202070:	177d                	addi	a4,a4,-1
ffffffffc0202072:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0202074:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202078:	08f77163          	bleu	a5,a4,ffffffffc02020fa <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc020207c:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0202080:	9732                	add	a4,a4,a2
ffffffffc0202082:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202086:	767d                	lui	a2,0xfffff
ffffffffc0202088:	8ef1                	and	a3,a3,a2
ffffffffc020208a:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc020208c:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202090:	8d95                	sub	a1,a1,a3
ffffffffc0202092:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0202094:	81b1                	srli	a1,a1,0xc
ffffffffc0202096:	953e                	add	a0,a0,a5
ffffffffc0202098:	9702                	jalr	a4
ffffffffc020209a:	bead                	j	ffffffffc0201c14 <pmm_init+0x11e>
ffffffffc020209c:	6008                	ld	a0,0(s0)
ffffffffc020209e:	b5b5                	j	ffffffffc0201f0a <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02020a0:	86d2                	mv	a3,s4
ffffffffc02020a2:	00003617          	auipc	a2,0x3
ffffffffc02020a6:	db660613          	addi	a2,a2,-586 # ffffffffc0204e58 <default_pmm_manager+0x50>
ffffffffc02020aa:	1cd00593          	li	a1,461
ffffffffc02020ae:	00003517          	auipc	a0,0x3
ffffffffc02020b2:	dd250513          	addi	a0,a0,-558 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02020b6:	abefe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02020ba:	00003697          	auipc	a3,0x3
ffffffffc02020be:	23e68693          	addi	a3,a3,574 # ffffffffc02052f8 <default_pmm_manager+0x4f0>
ffffffffc02020c2:	00003617          	auipc	a2,0x3
ffffffffc02020c6:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0204a70 <commands+0x870>
ffffffffc02020ca:	1cd00593          	li	a1,461
ffffffffc02020ce:	00003517          	auipc	a0,0x3
ffffffffc02020d2:	db250513          	addi	a0,a0,-590 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02020d6:	a9efe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02020da:	00003697          	auipc	a3,0x3
ffffffffc02020de:	25e68693          	addi	a3,a3,606 # ffffffffc0205338 <default_pmm_manager+0x530>
ffffffffc02020e2:	00003617          	auipc	a2,0x3
ffffffffc02020e6:	98e60613          	addi	a2,a2,-1650 # ffffffffc0204a70 <commands+0x870>
ffffffffc02020ea:	1ce00593          	li	a1,462
ffffffffc02020ee:	00003517          	auipc	a0,0x3
ffffffffc02020f2:	d9250513          	addi	a0,a0,-622 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02020f6:	a7efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02020fa:	d28ff0ef          	jal	ra,ffffffffc0201622 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02020fe:	00003617          	auipc	a2,0x3
ffffffffc0202102:	d5a60613          	addi	a2,a2,-678 # ffffffffc0204e58 <default_pmm_manager+0x50>
ffffffffc0202106:	06a00593          	li	a1,106
ffffffffc020210a:	00003517          	auipc	a0,0x3
ffffffffc020210e:	de650513          	addi	a0,a0,-538 # ffffffffc0204ef0 <default_pmm_manager+0xe8>
ffffffffc0202112:	a62fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202116:	00003617          	auipc	a2,0x3
ffffffffc020211a:	fb260613          	addi	a2,a2,-78 # ffffffffc02050c8 <default_pmm_manager+0x2c0>
ffffffffc020211e:	07000593          	li	a1,112
ffffffffc0202122:	00003517          	auipc	a0,0x3
ffffffffc0202126:	dce50513          	addi	a0,a0,-562 # ffffffffc0204ef0 <default_pmm_manager+0xe8>
ffffffffc020212a:	a4afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020212e:	00003697          	auipc	a3,0x3
ffffffffc0202132:	eda68693          	addi	a3,a3,-294 # ffffffffc0205008 <default_pmm_manager+0x200>
ffffffffc0202136:	00003617          	auipc	a2,0x3
ffffffffc020213a:	93a60613          	addi	a2,a2,-1734 # ffffffffc0204a70 <commands+0x870>
ffffffffc020213e:	19300593          	li	a1,403
ffffffffc0202142:	00003517          	auipc	a0,0x3
ffffffffc0202146:	d3e50513          	addi	a0,a0,-706 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc020214a:	a2afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020214e:	00003697          	auipc	a3,0x3
ffffffffc0202152:	ef268693          	addi	a3,a3,-270 # ffffffffc0205040 <default_pmm_manager+0x238>
ffffffffc0202156:	00003617          	auipc	a2,0x3
ffffffffc020215a:	91a60613          	addi	a2,a2,-1766 # ffffffffc0204a70 <commands+0x870>
ffffffffc020215e:	19400593          	li	a1,404
ffffffffc0202162:	00003517          	auipc	a0,0x3
ffffffffc0202166:	d1e50513          	addi	a0,a0,-738 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc020216a:	a0afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020216e:	00003697          	auipc	a3,0x3
ffffffffc0202172:	14a68693          	addi	a3,a3,330 # ffffffffc02052b8 <default_pmm_manager+0x4b0>
ffffffffc0202176:	00003617          	auipc	a2,0x3
ffffffffc020217a:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0204a70 <commands+0x870>
ffffffffc020217e:	1c000593          	li	a1,448
ffffffffc0202182:	00003517          	auipc	a0,0x3
ffffffffc0202186:	cfe50513          	addi	a0,a0,-770 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc020218a:	9eafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020218e:	00003617          	auipc	a2,0x3
ffffffffc0202192:	e1260613          	addi	a2,a2,-494 # ffffffffc0204fa0 <default_pmm_manager+0x198>
ffffffffc0202196:	07700593          	li	a1,119
ffffffffc020219a:	00003517          	auipc	a0,0x3
ffffffffc020219e:	ce650513          	addi	a0,a0,-794 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02021a2:	9d2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02021a6:	00003697          	auipc	a3,0x3
ffffffffc02021aa:	ef268693          	addi	a3,a3,-270 # ffffffffc0205098 <default_pmm_manager+0x290>
ffffffffc02021ae:	00003617          	auipc	a2,0x3
ffffffffc02021b2:	8c260613          	addi	a2,a2,-1854 # ffffffffc0204a70 <commands+0x870>
ffffffffc02021b6:	19a00593          	li	a1,410
ffffffffc02021ba:	00003517          	auipc	a0,0x3
ffffffffc02021be:	cc650513          	addi	a0,a0,-826 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02021c2:	9b2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02021c6:	00003697          	auipc	a3,0x3
ffffffffc02021ca:	ea268693          	addi	a3,a3,-350 # ffffffffc0205068 <default_pmm_manager+0x260>
ffffffffc02021ce:	00003617          	auipc	a2,0x3
ffffffffc02021d2:	8a260613          	addi	a2,a2,-1886 # ffffffffc0204a70 <commands+0x870>
ffffffffc02021d6:	19800593          	li	a1,408
ffffffffc02021da:	00003517          	auipc	a0,0x3
ffffffffc02021de:	ca650513          	addi	a0,a0,-858 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02021e2:	992fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02021e6:	00003697          	auipc	a3,0x3
ffffffffc02021ea:	fca68693          	addi	a3,a3,-54 # ffffffffc02051b0 <default_pmm_manager+0x3a8>
ffffffffc02021ee:	00003617          	auipc	a2,0x3
ffffffffc02021f2:	88260613          	addi	a2,a2,-1918 # ffffffffc0204a70 <commands+0x870>
ffffffffc02021f6:	1a500593          	li	a1,421
ffffffffc02021fa:	00003517          	auipc	a0,0x3
ffffffffc02021fe:	c8650513          	addi	a0,a0,-890 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202202:	972fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202206:	00003697          	auipc	a3,0x3
ffffffffc020220a:	f7a68693          	addi	a3,a3,-134 # ffffffffc0205180 <default_pmm_manager+0x378>
ffffffffc020220e:	00003617          	auipc	a2,0x3
ffffffffc0202212:	86260613          	addi	a2,a2,-1950 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202216:	1a400593          	li	a1,420
ffffffffc020221a:	00003517          	auipc	a0,0x3
ffffffffc020221e:	c6650513          	addi	a0,a0,-922 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202222:	952fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202226:	00003697          	auipc	a3,0x3
ffffffffc020222a:	f2268693          	addi	a3,a3,-222 # ffffffffc0205148 <default_pmm_manager+0x340>
ffffffffc020222e:	00003617          	auipc	a2,0x3
ffffffffc0202232:	84260613          	addi	a2,a2,-1982 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202236:	1a300593          	li	a1,419
ffffffffc020223a:	00003517          	auipc	a0,0x3
ffffffffc020223e:	c4650513          	addi	a0,a0,-954 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202242:	932fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202246:	00003697          	auipc	a3,0x3
ffffffffc020224a:	eda68693          	addi	a3,a3,-294 # ffffffffc0205120 <default_pmm_manager+0x318>
ffffffffc020224e:	00003617          	auipc	a2,0x3
ffffffffc0202252:	82260613          	addi	a2,a2,-2014 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202256:	1a000593          	li	a1,416
ffffffffc020225a:	00003517          	auipc	a0,0x3
ffffffffc020225e:	c2650513          	addi	a0,a0,-986 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202262:	912fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202266:	86da                	mv	a3,s6
ffffffffc0202268:	00003617          	auipc	a2,0x3
ffffffffc020226c:	bf060613          	addi	a2,a2,-1040 # ffffffffc0204e58 <default_pmm_manager+0x50>
ffffffffc0202270:	19f00593          	li	a1,415
ffffffffc0202274:	00003517          	auipc	a0,0x3
ffffffffc0202278:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc020227c:	8f8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202280:	86be                	mv	a3,a5
ffffffffc0202282:	00003617          	auipc	a2,0x3
ffffffffc0202286:	bd660613          	addi	a2,a2,-1066 # ffffffffc0204e58 <default_pmm_manager+0x50>
ffffffffc020228a:	19e00593          	li	a1,414
ffffffffc020228e:	00003517          	auipc	a0,0x3
ffffffffc0202292:	bf250513          	addi	a0,a0,-1038 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202296:	8defe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020229a:	00003697          	auipc	a3,0x3
ffffffffc020229e:	e6e68693          	addi	a3,a3,-402 # ffffffffc0205108 <default_pmm_manager+0x300>
ffffffffc02022a2:	00002617          	auipc	a2,0x2
ffffffffc02022a6:	7ce60613          	addi	a2,a2,1998 # ffffffffc0204a70 <commands+0x870>
ffffffffc02022aa:	19c00593          	li	a1,412
ffffffffc02022ae:	00003517          	auipc	a0,0x3
ffffffffc02022b2:	bd250513          	addi	a0,a0,-1070 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02022b6:	8befe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02022ba:	00003697          	auipc	a3,0x3
ffffffffc02022be:	e3668693          	addi	a3,a3,-458 # ffffffffc02050f0 <default_pmm_manager+0x2e8>
ffffffffc02022c2:	00002617          	auipc	a2,0x2
ffffffffc02022c6:	7ae60613          	addi	a2,a2,1966 # ffffffffc0204a70 <commands+0x870>
ffffffffc02022ca:	19b00593          	li	a1,411
ffffffffc02022ce:	00003517          	auipc	a0,0x3
ffffffffc02022d2:	bb250513          	addi	a0,a0,-1102 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02022d6:	89efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02022da:	00003697          	auipc	a3,0x3
ffffffffc02022de:	e1668693          	addi	a3,a3,-490 # ffffffffc02050f0 <default_pmm_manager+0x2e8>
ffffffffc02022e2:	00002617          	auipc	a2,0x2
ffffffffc02022e6:	78e60613          	addi	a2,a2,1934 # ffffffffc0204a70 <commands+0x870>
ffffffffc02022ea:	1ae00593          	li	a1,430
ffffffffc02022ee:	00003517          	auipc	a0,0x3
ffffffffc02022f2:	b9250513          	addi	a0,a0,-1134 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02022f6:	87efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02022fa:	00003697          	auipc	a3,0x3
ffffffffc02022fe:	e8668693          	addi	a3,a3,-378 # ffffffffc0205180 <default_pmm_manager+0x378>
ffffffffc0202302:	00002617          	auipc	a2,0x2
ffffffffc0202306:	76e60613          	addi	a2,a2,1902 # ffffffffc0204a70 <commands+0x870>
ffffffffc020230a:	1ad00593          	li	a1,429
ffffffffc020230e:	00003517          	auipc	a0,0x3
ffffffffc0202312:	b7250513          	addi	a0,a0,-1166 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202316:	85efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020231a:	00003697          	auipc	a3,0x3
ffffffffc020231e:	f2e68693          	addi	a3,a3,-210 # ffffffffc0205248 <default_pmm_manager+0x440>
ffffffffc0202322:	00002617          	auipc	a2,0x2
ffffffffc0202326:	74e60613          	addi	a2,a2,1870 # ffffffffc0204a70 <commands+0x870>
ffffffffc020232a:	1ac00593          	li	a1,428
ffffffffc020232e:	00003517          	auipc	a0,0x3
ffffffffc0202332:	b5250513          	addi	a0,a0,-1198 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202336:	83efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020233a:	00003697          	auipc	a3,0x3
ffffffffc020233e:	ef668693          	addi	a3,a3,-266 # ffffffffc0205230 <default_pmm_manager+0x428>
ffffffffc0202342:	00002617          	auipc	a2,0x2
ffffffffc0202346:	72e60613          	addi	a2,a2,1838 # ffffffffc0204a70 <commands+0x870>
ffffffffc020234a:	1ab00593          	li	a1,427
ffffffffc020234e:	00003517          	auipc	a0,0x3
ffffffffc0202352:	b3250513          	addi	a0,a0,-1230 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202356:	81efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020235a:	00003697          	auipc	a3,0x3
ffffffffc020235e:	ea668693          	addi	a3,a3,-346 # ffffffffc0205200 <default_pmm_manager+0x3f8>
ffffffffc0202362:	00002617          	auipc	a2,0x2
ffffffffc0202366:	70e60613          	addi	a2,a2,1806 # ffffffffc0204a70 <commands+0x870>
ffffffffc020236a:	1aa00593          	li	a1,426
ffffffffc020236e:	00003517          	auipc	a0,0x3
ffffffffc0202372:	b1250513          	addi	a0,a0,-1262 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202376:	ffffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020237a:	00003697          	auipc	a3,0x3
ffffffffc020237e:	e6e68693          	addi	a3,a3,-402 # ffffffffc02051e8 <default_pmm_manager+0x3e0>
ffffffffc0202382:	00002617          	auipc	a2,0x2
ffffffffc0202386:	6ee60613          	addi	a2,a2,1774 # ffffffffc0204a70 <commands+0x870>
ffffffffc020238a:	1a800593          	li	a1,424
ffffffffc020238e:	00003517          	auipc	a0,0x3
ffffffffc0202392:	af250513          	addi	a0,a0,-1294 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202396:	fdffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020239a:	00003697          	auipc	a3,0x3
ffffffffc020239e:	e3668693          	addi	a3,a3,-458 # ffffffffc02051d0 <default_pmm_manager+0x3c8>
ffffffffc02023a2:	00002617          	auipc	a2,0x2
ffffffffc02023a6:	6ce60613          	addi	a2,a2,1742 # ffffffffc0204a70 <commands+0x870>
ffffffffc02023aa:	1a700593          	li	a1,423
ffffffffc02023ae:	00003517          	auipc	a0,0x3
ffffffffc02023b2:	ad250513          	addi	a0,a0,-1326 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02023b6:	fbffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02023ba:	00003697          	auipc	a3,0x3
ffffffffc02023be:	e0668693          	addi	a3,a3,-506 # ffffffffc02051c0 <default_pmm_manager+0x3b8>
ffffffffc02023c2:	00002617          	auipc	a2,0x2
ffffffffc02023c6:	6ae60613          	addi	a2,a2,1710 # ffffffffc0204a70 <commands+0x870>
ffffffffc02023ca:	1a600593          	li	a1,422
ffffffffc02023ce:	00003517          	auipc	a0,0x3
ffffffffc02023d2:	ab250513          	addi	a0,a0,-1358 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02023d6:	f9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02023da:	00003697          	auipc	a3,0x3
ffffffffc02023de:	ede68693          	addi	a3,a3,-290 # ffffffffc02052b8 <default_pmm_manager+0x4b0>
ffffffffc02023e2:	00002617          	auipc	a2,0x2
ffffffffc02023e6:	68e60613          	addi	a2,a2,1678 # ffffffffc0204a70 <commands+0x870>
ffffffffc02023ea:	1e800593          	li	a1,488
ffffffffc02023ee:	00003517          	auipc	a0,0x3
ffffffffc02023f2:	a9250513          	addi	a0,a0,-1390 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02023f6:	f7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02023fa:	00003697          	auipc	a3,0x3
ffffffffc02023fe:	06668693          	addi	a3,a3,102 # ffffffffc0205460 <default_pmm_manager+0x658>
ffffffffc0202402:	00002617          	auipc	a2,0x2
ffffffffc0202406:	66e60613          	addi	a2,a2,1646 # ffffffffc0204a70 <commands+0x870>
ffffffffc020240a:	1e000593          	li	a1,480
ffffffffc020240e:	00003517          	auipc	a0,0x3
ffffffffc0202412:	a7250513          	addi	a0,a0,-1422 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202416:	f5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020241a:	00003697          	auipc	a3,0x3
ffffffffc020241e:	00e68693          	addi	a3,a3,14 # ffffffffc0205428 <default_pmm_manager+0x620>
ffffffffc0202422:	00002617          	auipc	a2,0x2
ffffffffc0202426:	64e60613          	addi	a2,a2,1614 # ffffffffc0204a70 <commands+0x870>
ffffffffc020242a:	1dd00593          	li	a1,477
ffffffffc020242e:	00003517          	auipc	a0,0x3
ffffffffc0202432:	a5250513          	addi	a0,a0,-1454 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202436:	f3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020243a:	00003697          	auipc	a3,0x3
ffffffffc020243e:	fbe68693          	addi	a3,a3,-66 # ffffffffc02053f8 <default_pmm_manager+0x5f0>
ffffffffc0202442:	00002617          	auipc	a2,0x2
ffffffffc0202446:	62e60613          	addi	a2,a2,1582 # ffffffffc0204a70 <commands+0x870>
ffffffffc020244a:	1d900593          	li	a1,473
ffffffffc020244e:	00003517          	auipc	a0,0x3
ffffffffc0202452:	a3250513          	addi	a0,a0,-1486 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202456:	f1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020245a:	00003697          	auipc	a3,0x3
ffffffffc020245e:	e1e68693          	addi	a3,a3,-482 # ffffffffc0205278 <default_pmm_manager+0x470>
ffffffffc0202462:	00002617          	auipc	a2,0x2
ffffffffc0202466:	60e60613          	addi	a2,a2,1550 # ffffffffc0204a70 <commands+0x870>
ffffffffc020246a:	1b600593          	li	a1,438
ffffffffc020246e:	00003517          	auipc	a0,0x3
ffffffffc0202472:	a1250513          	addi	a0,a0,-1518 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202476:	efffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020247a:	00003697          	auipc	a3,0x3
ffffffffc020247e:	dce68693          	addi	a3,a3,-562 # ffffffffc0205248 <default_pmm_manager+0x440>
ffffffffc0202482:	00002617          	auipc	a2,0x2
ffffffffc0202486:	5ee60613          	addi	a2,a2,1518 # ffffffffc0204a70 <commands+0x870>
ffffffffc020248a:	1b300593          	li	a1,435
ffffffffc020248e:	00003517          	auipc	a0,0x3
ffffffffc0202492:	9f250513          	addi	a0,a0,-1550 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202496:	edffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020249a:	00003697          	auipc	a3,0x3
ffffffffc020249e:	c6e68693          	addi	a3,a3,-914 # ffffffffc0205108 <default_pmm_manager+0x300>
ffffffffc02024a2:	00002617          	auipc	a2,0x2
ffffffffc02024a6:	5ce60613          	addi	a2,a2,1486 # ffffffffc0204a70 <commands+0x870>
ffffffffc02024aa:	1b200593          	li	a1,434
ffffffffc02024ae:	00003517          	auipc	a0,0x3
ffffffffc02024b2:	9d250513          	addi	a0,a0,-1582 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02024b6:	ebffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024ba:	00003697          	auipc	a3,0x3
ffffffffc02024be:	da668693          	addi	a3,a3,-602 # ffffffffc0205260 <default_pmm_manager+0x458>
ffffffffc02024c2:	00002617          	auipc	a2,0x2
ffffffffc02024c6:	5ae60613          	addi	a2,a2,1454 # ffffffffc0204a70 <commands+0x870>
ffffffffc02024ca:	1af00593          	li	a1,431
ffffffffc02024ce:	00003517          	auipc	a0,0x3
ffffffffc02024d2:	9b250513          	addi	a0,a0,-1614 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02024d6:	e9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02024da:	00003697          	auipc	a3,0x3
ffffffffc02024de:	db668693          	addi	a3,a3,-586 # ffffffffc0205290 <default_pmm_manager+0x488>
ffffffffc02024e2:	00002617          	auipc	a2,0x2
ffffffffc02024e6:	58e60613          	addi	a2,a2,1422 # ffffffffc0204a70 <commands+0x870>
ffffffffc02024ea:	1b900593          	li	a1,441
ffffffffc02024ee:	00003517          	auipc	a0,0x3
ffffffffc02024f2:	99250513          	addi	a0,a0,-1646 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02024f6:	e7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024fa:	00003697          	auipc	a3,0x3
ffffffffc02024fe:	d4e68693          	addi	a3,a3,-690 # ffffffffc0205248 <default_pmm_manager+0x440>
ffffffffc0202502:	00002617          	auipc	a2,0x2
ffffffffc0202506:	56e60613          	addi	a2,a2,1390 # ffffffffc0204a70 <commands+0x870>
ffffffffc020250a:	1b700593          	li	a1,439
ffffffffc020250e:	00003517          	auipc	a0,0x3
ffffffffc0202512:	97250513          	addi	a0,a0,-1678 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202516:	e5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020251a:	00003697          	auipc	a3,0x3
ffffffffc020251e:	ace68693          	addi	a3,a3,-1330 # ffffffffc0204fe8 <default_pmm_manager+0x1e0>
ffffffffc0202522:	00002617          	auipc	a2,0x2
ffffffffc0202526:	54e60613          	addi	a2,a2,1358 # ffffffffc0204a70 <commands+0x870>
ffffffffc020252a:	19200593          	li	a1,402
ffffffffc020252e:	00003517          	auipc	a0,0x3
ffffffffc0202532:	95250513          	addi	a0,a0,-1710 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202536:	e3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020253a:	00003617          	auipc	a2,0x3
ffffffffc020253e:	a6660613          	addi	a2,a2,-1434 # ffffffffc0204fa0 <default_pmm_manager+0x198>
ffffffffc0202542:	0bd00593          	li	a1,189
ffffffffc0202546:	00003517          	auipc	a0,0x3
ffffffffc020254a:	93a50513          	addi	a0,a0,-1734 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc020254e:	e27fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202552:	00003697          	auipc	a3,0x3
ffffffffc0202556:	e6668693          	addi	a3,a3,-410 # ffffffffc02053b8 <default_pmm_manager+0x5b0>
ffffffffc020255a:	00002617          	auipc	a2,0x2
ffffffffc020255e:	51660613          	addi	a2,a2,1302 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202562:	1d800593          	li	a1,472
ffffffffc0202566:	00003517          	auipc	a0,0x3
ffffffffc020256a:	91a50513          	addi	a0,a0,-1766 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc020256e:	e07fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202572:	00003697          	auipc	a3,0x3
ffffffffc0202576:	e2e68693          	addi	a3,a3,-466 # ffffffffc02053a0 <default_pmm_manager+0x598>
ffffffffc020257a:	00002617          	auipc	a2,0x2
ffffffffc020257e:	4f660613          	addi	a2,a2,1270 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202582:	1d700593          	li	a1,471
ffffffffc0202586:	00003517          	auipc	a0,0x3
ffffffffc020258a:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc020258e:	de7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202592:	00003697          	auipc	a3,0x3
ffffffffc0202596:	dd668693          	addi	a3,a3,-554 # ffffffffc0205368 <default_pmm_manager+0x560>
ffffffffc020259a:	00002617          	auipc	a2,0x2
ffffffffc020259e:	4d660613          	addi	a2,a2,1238 # ffffffffc0204a70 <commands+0x870>
ffffffffc02025a2:	1d600593          	li	a1,470
ffffffffc02025a6:	00003517          	auipc	a0,0x3
ffffffffc02025aa:	8da50513          	addi	a0,a0,-1830 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02025ae:	dc7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025b2:	00003697          	auipc	a3,0x3
ffffffffc02025b6:	d9e68693          	addi	a3,a3,-610 # ffffffffc0205350 <default_pmm_manager+0x548>
ffffffffc02025ba:	00002617          	auipc	a2,0x2
ffffffffc02025be:	4b660613          	addi	a2,a2,1206 # ffffffffc0204a70 <commands+0x870>
ffffffffc02025c2:	1d200593          	li	a1,466
ffffffffc02025c6:	00003517          	auipc	a0,0x3
ffffffffc02025ca:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02025ce:	da7fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02025d2 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02025d2:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02025d6:	8082                	ret

ffffffffc02025d8 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02025d8:	7179                	addi	sp,sp,-48
ffffffffc02025da:	e84a                	sd	s2,16(sp)
ffffffffc02025dc:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02025de:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02025e0:	f022                	sd	s0,32(sp)
ffffffffc02025e2:	ec26                	sd	s1,24(sp)
ffffffffc02025e4:	e44e                	sd	s3,8(sp)
ffffffffc02025e6:	f406                	sd	ra,40(sp)
ffffffffc02025e8:	84ae                	mv	s1,a1
ffffffffc02025ea:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02025ec:	852ff0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc02025f0:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02025f2:	cd19                	beqz	a0,ffffffffc0202610 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02025f4:	85aa                	mv	a1,a0
ffffffffc02025f6:	86ce                	mv	a3,s3
ffffffffc02025f8:	8626                	mv	a2,s1
ffffffffc02025fa:	854a                	mv	a0,s2
ffffffffc02025fc:	c28ff0ef          	jal	ra,ffffffffc0201a24 <page_insert>
ffffffffc0202600:	ed39                	bnez	a0,ffffffffc020265e <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202602:	0000e797          	auipc	a5,0xe
ffffffffc0202606:	e6678793          	addi	a5,a5,-410 # ffffffffc0210468 <swap_init_ok>
ffffffffc020260a:	439c                	lw	a5,0(a5)
ffffffffc020260c:	2781                	sext.w	a5,a5
ffffffffc020260e:	eb89                	bnez	a5,ffffffffc0202620 <pgdir_alloc_page+0x48>
}
ffffffffc0202610:	8522                	mv	a0,s0
ffffffffc0202612:	70a2                	ld	ra,40(sp)
ffffffffc0202614:	7402                	ld	s0,32(sp)
ffffffffc0202616:	64e2                	ld	s1,24(sp)
ffffffffc0202618:	6942                	ld	s2,16(sp)
ffffffffc020261a:	69a2                	ld	s3,8(sp)
ffffffffc020261c:	6145                	addi	sp,sp,48
ffffffffc020261e:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202620:	0000e797          	auipc	a5,0xe
ffffffffc0202624:	f7078793          	addi	a5,a5,-144 # ffffffffc0210590 <check_mm_struct>
ffffffffc0202628:	6388                	ld	a0,0(a5)
ffffffffc020262a:	4681                	li	a3,0
ffffffffc020262c:	8622                	mv	a2,s0
ffffffffc020262e:	85a6                	mv	a1,s1
ffffffffc0202630:	06d000ef          	jal	ra,ffffffffc0202e9c <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202634:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202636:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0202638:	4785                	li	a5,1
ffffffffc020263a:	fcf70be3          	beq	a4,a5,ffffffffc0202610 <pgdir_alloc_page+0x38>
ffffffffc020263e:	00003697          	auipc	a3,0x3
ffffffffc0202642:	8c268693          	addi	a3,a3,-1854 # ffffffffc0204f00 <default_pmm_manager+0xf8>
ffffffffc0202646:	00002617          	auipc	a2,0x2
ffffffffc020264a:	42a60613          	addi	a2,a2,1066 # ffffffffc0204a70 <commands+0x870>
ffffffffc020264e:	17a00593          	li	a1,378
ffffffffc0202652:	00003517          	auipc	a0,0x3
ffffffffc0202656:	82e50513          	addi	a0,a0,-2002 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc020265a:	d1bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
            free_page(page);
ffffffffc020265e:	8522                	mv	a0,s0
ffffffffc0202660:	4585                	li	a1,1
ffffffffc0202662:	864ff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
            return NULL;
ffffffffc0202666:	4401                	li	s0,0
ffffffffc0202668:	b765                	j	ffffffffc0202610 <pgdir_alloc_page+0x38>

ffffffffc020266a <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc020266a:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020266c:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc020266e:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202670:	fff50713          	addi	a4,a0,-1
ffffffffc0202674:	17f9                	addi	a5,a5,-2
ffffffffc0202676:	04e7ee63          	bltu	a5,a4,ffffffffc02026d2 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020267a:	6785                	lui	a5,0x1
ffffffffc020267c:	17fd                	addi	a5,a5,-1
ffffffffc020267e:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0202680:	8131                	srli	a0,a0,0xc
ffffffffc0202682:	fbdfe0ef          	jal	ra,ffffffffc020163e <alloc_pages>
    assert(base != NULL);
ffffffffc0202686:	c159                	beqz	a0,ffffffffc020270c <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202688:	0000e797          	auipc	a5,0xe
ffffffffc020268c:	e2078793          	addi	a5,a5,-480 # ffffffffc02104a8 <pages>
ffffffffc0202690:	639c                	ld	a5,0(a5)
ffffffffc0202692:	8d1d                	sub	a0,a0,a5
ffffffffc0202694:	00002797          	auipc	a5,0x2
ffffffffc0202698:	3c478793          	addi	a5,a5,964 # ffffffffc0204a58 <commands+0x858>
ffffffffc020269c:	6394                	ld	a3,0(a5)
ffffffffc020269e:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026a0:	0000e797          	auipc	a5,0xe
ffffffffc02026a4:	db878793          	addi	a5,a5,-584 # ffffffffc0210458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026a8:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026ac:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026ae:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026b2:	57fd                	li	a5,-1
ffffffffc02026b4:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026b6:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026b8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02026ba:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026bc:	02e7fb63          	bleu	a4,a5,ffffffffc02026f2 <kmalloc+0x88>
ffffffffc02026c0:	0000e797          	auipc	a5,0xe
ffffffffc02026c4:	dd878793          	addi	a5,a5,-552 # ffffffffc0210498 <va_pa_offset>
ffffffffc02026c8:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc02026ca:	60a2                	ld	ra,8(sp)
ffffffffc02026cc:	953e                	add	a0,a0,a5
ffffffffc02026ce:	0141                	addi	sp,sp,16
ffffffffc02026d0:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026d2:	00002697          	auipc	a3,0x2
ffffffffc02026d6:	7ce68693          	addi	a3,a3,1998 # ffffffffc0204ea0 <default_pmm_manager+0x98>
ffffffffc02026da:	00002617          	auipc	a2,0x2
ffffffffc02026de:	39660613          	addi	a2,a2,918 # ffffffffc0204a70 <commands+0x870>
ffffffffc02026e2:	1f000593          	li	a1,496
ffffffffc02026e6:	00002517          	auipc	a0,0x2
ffffffffc02026ea:	79a50513          	addi	a0,a0,1946 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02026ee:	c87fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02026f2:	86aa                	mv	a3,a0
ffffffffc02026f4:	00002617          	auipc	a2,0x2
ffffffffc02026f8:	76460613          	addi	a2,a2,1892 # ffffffffc0204e58 <default_pmm_manager+0x50>
ffffffffc02026fc:	06a00593          	li	a1,106
ffffffffc0202700:	00002517          	auipc	a0,0x2
ffffffffc0202704:	7f050513          	addi	a0,a0,2032 # ffffffffc0204ef0 <default_pmm_manager+0xe8>
ffffffffc0202708:	c6dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc020270c:	00002697          	auipc	a3,0x2
ffffffffc0202710:	7b468693          	addi	a3,a3,1972 # ffffffffc0204ec0 <default_pmm_manager+0xb8>
ffffffffc0202714:	00002617          	auipc	a2,0x2
ffffffffc0202718:	35c60613          	addi	a2,a2,860 # ffffffffc0204a70 <commands+0x870>
ffffffffc020271c:	1f300593          	li	a1,499
ffffffffc0202720:	00002517          	auipc	a0,0x2
ffffffffc0202724:	76050513          	addi	a0,a0,1888 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc0202728:	c4dfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020272c <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc020272c:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020272e:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202730:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202732:	fff58713          	addi	a4,a1,-1
ffffffffc0202736:	17f9                	addi	a5,a5,-2
ffffffffc0202738:	04e7eb63          	bltu	a5,a4,ffffffffc020278e <kfree+0x62>
    assert(ptr != NULL);
ffffffffc020273c:	c941                	beqz	a0,ffffffffc02027cc <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020273e:	6785                	lui	a5,0x1
ffffffffc0202740:	17fd                	addi	a5,a5,-1
ffffffffc0202742:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202744:	c02007b7          	lui	a5,0xc0200
ffffffffc0202748:	81b1                	srli	a1,a1,0xc
ffffffffc020274a:	06f56463          	bltu	a0,a5,ffffffffc02027b2 <kfree+0x86>
ffffffffc020274e:	0000e797          	auipc	a5,0xe
ffffffffc0202752:	d4a78793          	addi	a5,a5,-694 # ffffffffc0210498 <va_pa_offset>
ffffffffc0202756:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202758:	0000e717          	auipc	a4,0xe
ffffffffc020275c:	d0070713          	addi	a4,a4,-768 # ffffffffc0210458 <npage>
ffffffffc0202760:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202762:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0202766:	83b1                	srli	a5,a5,0xc
ffffffffc0202768:	04e7f363          	bleu	a4,a5,ffffffffc02027ae <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc020276c:	fff80537          	lui	a0,0xfff80
ffffffffc0202770:	97aa                	add	a5,a5,a0
ffffffffc0202772:	0000e697          	auipc	a3,0xe
ffffffffc0202776:	d3668693          	addi	a3,a3,-714 # ffffffffc02104a8 <pages>
ffffffffc020277a:	6288                	ld	a0,0(a3)
ffffffffc020277c:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0202780:	60a2                	ld	ra,8(sp)
ffffffffc0202782:	97ba                	add	a5,a5,a4
ffffffffc0202784:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0202786:	953e                	add	a0,a0,a5
}
ffffffffc0202788:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc020278a:	f3dfe06f          	j	ffffffffc02016c6 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020278e:	00002697          	auipc	a3,0x2
ffffffffc0202792:	71268693          	addi	a3,a3,1810 # ffffffffc0204ea0 <default_pmm_manager+0x98>
ffffffffc0202796:	00002617          	auipc	a2,0x2
ffffffffc020279a:	2da60613          	addi	a2,a2,730 # ffffffffc0204a70 <commands+0x870>
ffffffffc020279e:	1f900593          	li	a1,505
ffffffffc02027a2:	00002517          	auipc	a0,0x2
ffffffffc02027a6:	6de50513          	addi	a0,a0,1758 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02027aa:	bcbfd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02027ae:	e75fe0ef          	jal	ra,ffffffffc0201622 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027b2:	86aa                	mv	a3,a0
ffffffffc02027b4:	00002617          	auipc	a2,0x2
ffffffffc02027b8:	7ec60613          	addi	a2,a2,2028 # ffffffffc0204fa0 <default_pmm_manager+0x198>
ffffffffc02027bc:	06c00593          	li	a1,108
ffffffffc02027c0:	00002517          	auipc	a0,0x2
ffffffffc02027c4:	73050513          	addi	a0,a0,1840 # ffffffffc0204ef0 <default_pmm_manager+0xe8>
ffffffffc02027c8:	badfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc02027cc:	00002697          	auipc	a3,0x2
ffffffffc02027d0:	6c468693          	addi	a3,a3,1732 # ffffffffc0204e90 <default_pmm_manager+0x88>
ffffffffc02027d4:	00002617          	auipc	a2,0x2
ffffffffc02027d8:	29c60613          	addi	a2,a2,668 # ffffffffc0204a70 <commands+0x870>
ffffffffc02027dc:	1fa00593          	li	a1,506
ffffffffc02027e0:	00002517          	auipc	a0,0x2
ffffffffc02027e4:	6a050513          	addi	a0,a0,1696 # ffffffffc0204e80 <default_pmm_manager+0x78>
ffffffffc02027e8:	b8dfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02027ec <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02027ec:	7135                	addi	sp,sp,-160
ffffffffc02027ee:	ed06                	sd	ra,152(sp)
ffffffffc02027f0:	e922                	sd	s0,144(sp)
ffffffffc02027f2:	e526                	sd	s1,136(sp)
ffffffffc02027f4:	e14a                	sd	s2,128(sp)
ffffffffc02027f6:	fcce                	sd	s3,120(sp)
ffffffffc02027f8:	f8d2                	sd	s4,112(sp)
ffffffffc02027fa:	f4d6                	sd	s5,104(sp)
ffffffffc02027fc:	f0da                	sd	s6,96(sp)
ffffffffc02027fe:	ecde                	sd	s7,88(sp)
ffffffffc0202800:	e8e2                	sd	s8,80(sp)
ffffffffc0202802:	e4e6                	sd	s9,72(sp)
ffffffffc0202804:	e0ea                	sd	s10,64(sp)
ffffffffc0202806:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202808:	274010ef          	jal	ra,ffffffffc0203a7c <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020280c:	0000e797          	auipc	a5,0xe
ffffffffc0202810:	d2c78793          	addi	a5,a5,-724 # ffffffffc0210538 <max_swap_offset>
ffffffffc0202814:	6394                	ld	a3,0(a5)
ffffffffc0202816:	010007b7          	lui	a5,0x1000
ffffffffc020281a:	17e1                	addi	a5,a5,-8
ffffffffc020281c:	ff968713          	addi	a4,a3,-7
ffffffffc0202820:	42e7ea63          	bltu	a5,a4,ffffffffc0202c54 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0202824:	00006797          	auipc	a5,0x6
ffffffffc0202828:	7dc78793          	addi	a5,a5,2012 # ffffffffc0209000 <swap_manager_clock>
     int r = sm->init();
ffffffffc020282c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc020282e:	0000e697          	auipc	a3,0xe
ffffffffc0202832:	c2f6b923          	sd	a5,-974(a3) # ffffffffc0210460 <sm>
     int r = sm->init();
ffffffffc0202836:	9702                	jalr	a4
ffffffffc0202838:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc020283a:	c10d                	beqz	a0,ffffffffc020285c <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020283c:	60ea                	ld	ra,152(sp)
ffffffffc020283e:	644a                	ld	s0,144(sp)
ffffffffc0202840:	855a                	mv	a0,s6
ffffffffc0202842:	64aa                	ld	s1,136(sp)
ffffffffc0202844:	690a                	ld	s2,128(sp)
ffffffffc0202846:	79e6                	ld	s3,120(sp)
ffffffffc0202848:	7a46                	ld	s4,112(sp)
ffffffffc020284a:	7aa6                	ld	s5,104(sp)
ffffffffc020284c:	7b06                	ld	s6,96(sp)
ffffffffc020284e:	6be6                	ld	s7,88(sp)
ffffffffc0202850:	6c46                	ld	s8,80(sp)
ffffffffc0202852:	6ca6                	ld	s9,72(sp)
ffffffffc0202854:	6d06                	ld	s10,64(sp)
ffffffffc0202856:	7de2                	ld	s11,56(sp)
ffffffffc0202858:	610d                	addi	sp,sp,160
ffffffffc020285a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020285c:	0000e797          	auipc	a5,0xe
ffffffffc0202860:	c0478793          	addi	a5,a5,-1020 # ffffffffc0210460 <sm>
ffffffffc0202864:	639c                	ld	a5,0(a5)
ffffffffc0202866:	00003517          	auipc	a0,0x3
ffffffffc020286a:	c7250513          	addi	a0,a0,-910 # ffffffffc02054d8 <default_pmm_manager+0x6d0>
    return listelm->next;
ffffffffc020286e:	0000e417          	auipc	s0,0xe
ffffffffc0202872:	c0a40413          	addi	s0,s0,-1014 # ffffffffc0210478 <free_area>
ffffffffc0202876:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202878:	4785                	li	a5,1
ffffffffc020287a:	0000e717          	auipc	a4,0xe
ffffffffc020287e:	bef72723          	sw	a5,-1042(a4) # ffffffffc0210468 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202882:	83dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202886:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202888:	2e878a63          	beq	a5,s0,ffffffffc0202b7c <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020288c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202890:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202892:	8b05                	andi	a4,a4,1
ffffffffc0202894:	2e070863          	beqz	a4,ffffffffc0202b84 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc0202898:	4481                	li	s1,0
ffffffffc020289a:	4901                	li	s2,0
ffffffffc020289c:	a031                	j	ffffffffc02028a8 <swap_init+0xbc>
ffffffffc020289e:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc02028a2:	8b09                	andi	a4,a4,2
ffffffffc02028a4:	2e070063          	beqz	a4,ffffffffc0202b84 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc02028a8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02028ac:	679c                	ld	a5,8(a5)
ffffffffc02028ae:	2905                	addiw	s2,s2,1
ffffffffc02028b0:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028b2:	fe8796e3          	bne	a5,s0,ffffffffc020289e <swap_init+0xb2>
ffffffffc02028b6:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02028b8:	e55fe0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc02028bc:	5b351863          	bne	a0,s3,ffffffffc0202e6c <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02028c0:	8626                	mv	a2,s1
ffffffffc02028c2:	85ca                	mv	a1,s2
ffffffffc02028c4:	00003517          	auipc	a0,0x3
ffffffffc02028c8:	c2c50513          	addi	a0,a0,-980 # ffffffffc02054f0 <default_pmm_manager+0x6e8>
ffffffffc02028cc:	ff2fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02028d0:	203000ef          	jal	ra,ffffffffc02032d2 <mm_create>
ffffffffc02028d4:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02028d6:	50050b63          	beqz	a0,ffffffffc0202dec <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02028da:	0000e797          	auipc	a5,0xe
ffffffffc02028de:	cb678793          	addi	a5,a5,-842 # ffffffffc0210590 <check_mm_struct>
ffffffffc02028e2:	639c                	ld	a5,0(a5)
ffffffffc02028e4:	52079463          	bnez	a5,ffffffffc0202e0c <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02028e8:	0000e797          	auipc	a5,0xe
ffffffffc02028ec:	b6878793          	addi	a5,a5,-1176 # ffffffffc0210450 <boot_pgdir>
ffffffffc02028f0:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc02028f2:	0000e797          	auipc	a5,0xe
ffffffffc02028f6:	c8a7bf23          	sd	a0,-866(a5) # ffffffffc0210590 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02028fa:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02028fc:	ec3a                	sd	a4,24(sp)
ffffffffc02028fe:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202900:	52079663          	bnez	a5,ffffffffc0202e2c <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202904:	6599                	lui	a1,0x6
ffffffffc0202906:	460d                	li	a2,3
ffffffffc0202908:	6505                	lui	a0,0x1
ffffffffc020290a:	215000ef          	jal	ra,ffffffffc020331e <vma_create>
ffffffffc020290e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202910:	52050e63          	beqz	a0,ffffffffc0202e4c <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0202914:	855e                	mv	a0,s7
ffffffffc0202916:	275000ef          	jal	ra,ffffffffc020338a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020291a:	00003517          	auipc	a0,0x3
ffffffffc020291e:	c4650513          	addi	a0,a0,-954 # ffffffffc0205560 <default_pmm_manager+0x758>
ffffffffc0202922:	f9cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202926:	018bb503          	ld	a0,24(s7)
ffffffffc020292a:	4605                	li	a2,1
ffffffffc020292c:	6585                	lui	a1,0x1
ffffffffc020292e:	e1ffe0ef          	jal	ra,ffffffffc020174c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202932:	40050d63          	beqz	a0,ffffffffc0202d4c <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202936:	00003517          	auipc	a0,0x3
ffffffffc020293a:	c7a50513          	addi	a0,a0,-902 # ffffffffc02055b0 <default_pmm_manager+0x7a8>
ffffffffc020293e:	0000ea17          	auipc	s4,0xe
ffffffffc0202942:	b72a0a13          	addi	s4,s4,-1166 # ffffffffc02104b0 <check_rp>
ffffffffc0202946:	f78fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020294a:	0000ea97          	auipc	s5,0xe
ffffffffc020294e:	b86a8a93          	addi	s5,s5,-1146 # ffffffffc02104d0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202952:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc0202954:	4505                	li	a0,1
ffffffffc0202956:	ce9fe0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc020295a:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6fa68>
          assert(check_rp[i] != NULL );
ffffffffc020295e:	2a050b63          	beqz	a0,ffffffffc0202c14 <swap_init+0x428>
ffffffffc0202962:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202964:	8b89                	andi	a5,a5,2
ffffffffc0202966:	28079763          	bnez	a5,ffffffffc0202bf4 <swap_init+0x408>
ffffffffc020296a:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020296c:	ff5994e3          	bne	s3,s5,ffffffffc0202954 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202970:	601c                	ld	a5,0(s0)
ffffffffc0202972:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202976:	0000ed17          	auipc	s10,0xe
ffffffffc020297a:	b3ad0d13          	addi	s10,s10,-1222 # ffffffffc02104b0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020297e:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202980:	481c                	lw	a5,16(s0)
ffffffffc0202982:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202984:	0000e797          	auipc	a5,0xe
ffffffffc0202988:	ae87be23          	sd	s0,-1284(a5) # ffffffffc0210480 <free_area+0x8>
ffffffffc020298c:	0000e797          	auipc	a5,0xe
ffffffffc0202990:	ae87b623          	sd	s0,-1300(a5) # ffffffffc0210478 <free_area>
     nr_free = 0;
ffffffffc0202994:	0000e797          	auipc	a5,0xe
ffffffffc0202998:	ae07aa23          	sw	zero,-1292(a5) # ffffffffc0210488 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020299c:	000d3503          	ld	a0,0(s10)
ffffffffc02029a0:	4585                	li	a1,1
ffffffffc02029a2:	0d21                	addi	s10,s10,8
ffffffffc02029a4:	d23fe0ef          	jal	ra,ffffffffc02016c6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029a8:	ff5d1ae3          	bne	s10,s5,ffffffffc020299c <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02029ac:	01042d03          	lw	s10,16(s0)
ffffffffc02029b0:	4791                	li	a5,4
ffffffffc02029b2:	36fd1d63          	bne	s10,a5,ffffffffc0202d2c <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02029b6:	00003517          	auipc	a0,0x3
ffffffffc02029ba:	c8250513          	addi	a0,a0,-894 # ffffffffc0205638 <default_pmm_manager+0x830>
ffffffffc02029be:	f00fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029c2:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02029c4:	0000e797          	auipc	a5,0xe
ffffffffc02029c8:	aa07a423          	sw	zero,-1368(a5) # ffffffffc021046c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029cc:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02029ce:	0000e797          	auipc	a5,0xe
ffffffffc02029d2:	a9e78793          	addi	a5,a5,-1378 # ffffffffc021046c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029d6:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02029da:	4398                	lw	a4,0(a5)
ffffffffc02029dc:	4585                	li	a1,1
ffffffffc02029de:	2701                	sext.w	a4,a4
ffffffffc02029e0:	30b71663          	bne	a4,a1,ffffffffc0202cec <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02029e4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02029e8:	4394                	lw	a3,0(a5)
ffffffffc02029ea:	2681                	sext.w	a3,a3
ffffffffc02029ec:	32e69063          	bne	a3,a4,ffffffffc0202d0c <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02029f0:	6689                	lui	a3,0x2
ffffffffc02029f2:	462d                	li	a2,11
ffffffffc02029f4:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc02029f8:	4398                	lw	a4,0(a5)
ffffffffc02029fa:	4589                	li	a1,2
ffffffffc02029fc:	2701                	sext.w	a4,a4
ffffffffc02029fe:	26b71763          	bne	a4,a1,ffffffffc0202c6c <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202a02:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202a06:	4394                	lw	a3,0(a5)
ffffffffc0202a08:	2681                	sext.w	a3,a3
ffffffffc0202a0a:	28e69163          	bne	a3,a4,ffffffffc0202c8c <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202a0e:	668d                	lui	a3,0x3
ffffffffc0202a10:	4631                	li	a2,12
ffffffffc0202a12:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202a16:	4398                	lw	a4,0(a5)
ffffffffc0202a18:	458d                	li	a1,3
ffffffffc0202a1a:	2701                	sext.w	a4,a4
ffffffffc0202a1c:	28b71863          	bne	a4,a1,ffffffffc0202cac <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202a20:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202a24:	4394                	lw	a3,0(a5)
ffffffffc0202a26:	2681                	sext.w	a3,a3
ffffffffc0202a28:	2ae69263          	bne	a3,a4,ffffffffc0202ccc <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202a2c:	6691                	lui	a3,0x4
ffffffffc0202a2e:	4635                	li	a2,13
ffffffffc0202a30:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202a34:	4398                	lw	a4,0(a5)
ffffffffc0202a36:	2701                	sext.w	a4,a4
ffffffffc0202a38:	33a71a63          	bne	a4,s10,ffffffffc0202d6c <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202a3c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202a40:	439c                	lw	a5,0(a5)
ffffffffc0202a42:	2781                	sext.w	a5,a5
ffffffffc0202a44:	34e79463          	bne	a5,a4,ffffffffc0202d8c <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202a48:	481c                	lw	a5,16(s0)
ffffffffc0202a4a:	36079163          	bnez	a5,ffffffffc0202dac <swap_init+0x5c0>
ffffffffc0202a4e:	0000e797          	auipc	a5,0xe
ffffffffc0202a52:	a8278793          	addi	a5,a5,-1406 # ffffffffc02104d0 <swap_in_seq_no>
ffffffffc0202a56:	0000e717          	auipc	a4,0xe
ffffffffc0202a5a:	aa270713          	addi	a4,a4,-1374 # ffffffffc02104f8 <swap_out_seq_no>
ffffffffc0202a5e:	0000e617          	auipc	a2,0xe
ffffffffc0202a62:	a9a60613          	addi	a2,a2,-1382 # ffffffffc02104f8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202a66:	56fd                	li	a3,-1
ffffffffc0202a68:	c394                	sw	a3,0(a5)
ffffffffc0202a6a:	c314                	sw	a3,0(a4)
ffffffffc0202a6c:	0791                	addi	a5,a5,4
ffffffffc0202a6e:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202a70:	fec79ce3          	bne	a5,a2,ffffffffc0202a68 <swap_init+0x27c>
ffffffffc0202a74:	0000e697          	auipc	a3,0xe
ffffffffc0202a78:	ae468693          	addi	a3,a3,-1308 # ffffffffc0210558 <check_ptep>
ffffffffc0202a7c:	0000e817          	auipc	a6,0xe
ffffffffc0202a80:	a3480813          	addi	a6,a6,-1484 # ffffffffc02104b0 <check_rp>
ffffffffc0202a84:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202a86:	0000ec97          	auipc	s9,0xe
ffffffffc0202a8a:	9d2c8c93          	addi	s9,s9,-1582 # ffffffffc0210458 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a8e:	0000ed97          	auipc	s11,0xe
ffffffffc0202a92:	a1ad8d93          	addi	s11,s11,-1510 # ffffffffc02104a8 <pages>
ffffffffc0202a96:	00003d17          	auipc	s10,0x3
ffffffffc0202a9a:	3d2d0d13          	addi	s10,s10,978 # ffffffffc0205e68 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202a9e:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202aa0:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202aa4:	4601                	li	a2,0
ffffffffc0202aa6:	85e2                	mv	a1,s8
ffffffffc0202aa8:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202aaa:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202aac:	ca1fe0ef          	jal	ra,ffffffffc020174c <get_pte>
ffffffffc0202ab0:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202ab2:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ab4:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202ab6:	16050f63          	beqz	a0,ffffffffc0202c34 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202aba:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202abc:	0017f613          	andi	a2,a5,1
ffffffffc0202ac0:	10060263          	beqz	a2,ffffffffc0202bc4 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202ac4:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ac8:	078a                	slli	a5,a5,0x2
ffffffffc0202aca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202acc:	10c7f863          	bleu	a2,a5,ffffffffc0202bdc <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ad0:	000d3603          	ld	a2,0(s10)
ffffffffc0202ad4:	000db583          	ld	a1,0(s11)
ffffffffc0202ad8:	00083503          	ld	a0,0(a6)
ffffffffc0202adc:	8f91                	sub	a5,a5,a2
ffffffffc0202ade:	00379613          	slli	a2,a5,0x3
ffffffffc0202ae2:	97b2                	add	a5,a5,a2
ffffffffc0202ae4:	078e                	slli	a5,a5,0x3
ffffffffc0202ae6:	97ae                	add	a5,a5,a1
ffffffffc0202ae8:	0af51e63          	bne	a0,a5,ffffffffc0202ba4 <swap_init+0x3b8>
ffffffffc0202aec:	6785                	lui	a5,0x1
ffffffffc0202aee:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202af0:	6795                	lui	a5,0x5
ffffffffc0202af2:	06a1                	addi	a3,a3,8
ffffffffc0202af4:	0821                	addi	a6,a6,8
ffffffffc0202af6:	fafc14e3          	bne	s8,a5,ffffffffc0202a9e <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202afa:	00003517          	auipc	a0,0x3
ffffffffc0202afe:	be650513          	addi	a0,a0,-1050 # ffffffffc02056e0 <default_pmm_manager+0x8d8>
ffffffffc0202b02:	dbcfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202b06:	0000e797          	auipc	a5,0xe
ffffffffc0202b0a:	95a78793          	addi	a5,a5,-1702 # ffffffffc0210460 <sm>
ffffffffc0202b0e:	639c                	ld	a5,0(a5)
ffffffffc0202b10:	7f9c                	ld	a5,56(a5)
ffffffffc0202b12:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202b14:	2a051c63          	bnez	a0,ffffffffc0202dcc <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202b18:	000a3503          	ld	a0,0(s4)
ffffffffc0202b1c:	4585                	li	a1,1
ffffffffc0202b1e:	0a21                	addi	s4,s4,8
ffffffffc0202b20:	ba7fe0ef          	jal	ra,ffffffffc02016c6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b24:	ff5a1ae3          	bne	s4,s5,ffffffffc0202b18 <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202b28:	855e                	mv	a0,s7
ffffffffc0202b2a:	12f000ef          	jal	ra,ffffffffc0203458 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202b2e:	77a2                	ld	a5,40(sp)
ffffffffc0202b30:	0000e717          	auipc	a4,0xe
ffffffffc0202b34:	94f72c23          	sw	a5,-1704(a4) # ffffffffc0210488 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202b38:	7782                	ld	a5,32(sp)
ffffffffc0202b3a:	0000e717          	auipc	a4,0xe
ffffffffc0202b3e:	92f73f23          	sd	a5,-1730(a4) # ffffffffc0210478 <free_area>
ffffffffc0202b42:	0000e797          	auipc	a5,0xe
ffffffffc0202b46:	9337bf23          	sd	s3,-1730(a5) # ffffffffc0210480 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b4a:	00898a63          	beq	s3,s0,ffffffffc0202b5e <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202b4e:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202b52:	0089b983          	ld	s3,8(s3)
ffffffffc0202b56:	397d                	addiw	s2,s2,-1
ffffffffc0202b58:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b5a:	fe899ae3          	bne	s3,s0,ffffffffc0202b4e <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202b5e:	8626                	mv	a2,s1
ffffffffc0202b60:	85ca                	mv	a1,s2
ffffffffc0202b62:	00003517          	auipc	a0,0x3
ffffffffc0202b66:	bae50513          	addi	a0,a0,-1106 # ffffffffc0205710 <default_pmm_manager+0x908>
ffffffffc0202b6a:	d54fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202b6e:	00003517          	auipc	a0,0x3
ffffffffc0202b72:	bc250513          	addi	a0,a0,-1086 # ffffffffc0205730 <default_pmm_manager+0x928>
ffffffffc0202b76:	d48fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202b7a:	b1c9                	j	ffffffffc020283c <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202b7c:	4481                	li	s1,0
ffffffffc0202b7e:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b80:	4981                	li	s3,0
ffffffffc0202b82:	bb1d                	j	ffffffffc02028b8 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202b84:	00002697          	auipc	a3,0x2
ffffffffc0202b88:	edc68693          	addi	a3,a3,-292 # ffffffffc0204a60 <commands+0x860>
ffffffffc0202b8c:	00002617          	auipc	a2,0x2
ffffffffc0202b90:	ee460613          	addi	a2,a2,-284 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202b94:	0ba00593          	li	a1,186
ffffffffc0202b98:	00003517          	auipc	a0,0x3
ffffffffc0202b9c:	93050513          	addi	a0,a0,-1744 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202ba0:	fd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202ba4:	00003697          	auipc	a3,0x3
ffffffffc0202ba8:	b1468693          	addi	a3,a3,-1260 # ffffffffc02056b8 <default_pmm_manager+0x8b0>
ffffffffc0202bac:	00002617          	auipc	a2,0x2
ffffffffc0202bb0:	ec460613          	addi	a2,a2,-316 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202bb4:	0fa00593          	li	a1,250
ffffffffc0202bb8:	00003517          	auipc	a0,0x3
ffffffffc0202bbc:	91050513          	addi	a0,a0,-1776 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202bc0:	fb4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bc4:	00002617          	auipc	a2,0x2
ffffffffc0202bc8:	50460613          	addi	a2,a2,1284 # ffffffffc02050c8 <default_pmm_manager+0x2c0>
ffffffffc0202bcc:	07000593          	li	a1,112
ffffffffc0202bd0:	00002517          	auipc	a0,0x2
ffffffffc0202bd4:	32050513          	addi	a0,a0,800 # ffffffffc0204ef0 <default_pmm_manager+0xe8>
ffffffffc0202bd8:	f9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202bdc:	00002617          	auipc	a2,0x2
ffffffffc0202be0:	2f460613          	addi	a2,a2,756 # ffffffffc0204ed0 <default_pmm_manager+0xc8>
ffffffffc0202be4:	06500593          	li	a1,101
ffffffffc0202be8:	00002517          	auipc	a0,0x2
ffffffffc0202bec:	30850513          	addi	a0,a0,776 # ffffffffc0204ef0 <default_pmm_manager+0xe8>
ffffffffc0202bf0:	f84fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202bf4:	00003697          	auipc	a3,0x3
ffffffffc0202bf8:	9fc68693          	addi	a3,a3,-1540 # ffffffffc02055f0 <default_pmm_manager+0x7e8>
ffffffffc0202bfc:	00002617          	auipc	a2,0x2
ffffffffc0202c00:	e7460613          	addi	a2,a2,-396 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202c04:	0db00593          	li	a1,219
ffffffffc0202c08:	00003517          	auipc	a0,0x3
ffffffffc0202c0c:	8c050513          	addi	a0,a0,-1856 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202c10:	f64fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202c14:	00003697          	auipc	a3,0x3
ffffffffc0202c18:	9c468693          	addi	a3,a3,-1596 # ffffffffc02055d8 <default_pmm_manager+0x7d0>
ffffffffc0202c1c:	00002617          	auipc	a2,0x2
ffffffffc0202c20:	e5460613          	addi	a2,a2,-428 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202c24:	0da00593          	li	a1,218
ffffffffc0202c28:	00003517          	auipc	a0,0x3
ffffffffc0202c2c:	8a050513          	addi	a0,a0,-1888 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202c30:	f44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202c34:	00003697          	auipc	a3,0x3
ffffffffc0202c38:	a6c68693          	addi	a3,a3,-1428 # ffffffffc02056a0 <default_pmm_manager+0x898>
ffffffffc0202c3c:	00002617          	auipc	a2,0x2
ffffffffc0202c40:	e3460613          	addi	a2,a2,-460 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202c44:	0f900593          	li	a1,249
ffffffffc0202c48:	00003517          	auipc	a0,0x3
ffffffffc0202c4c:	88050513          	addi	a0,a0,-1920 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202c50:	f24fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202c54:	00003617          	auipc	a2,0x3
ffffffffc0202c58:	85460613          	addi	a2,a2,-1964 # ffffffffc02054a8 <default_pmm_manager+0x6a0>
ffffffffc0202c5c:	02700593          	li	a1,39
ffffffffc0202c60:	00003517          	auipc	a0,0x3
ffffffffc0202c64:	86850513          	addi	a0,a0,-1944 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202c68:	f0cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202c6c:	00003697          	auipc	a3,0x3
ffffffffc0202c70:	a0468693          	addi	a3,a3,-1532 # ffffffffc0205670 <default_pmm_manager+0x868>
ffffffffc0202c74:	00002617          	auipc	a2,0x2
ffffffffc0202c78:	dfc60613          	addi	a2,a2,-516 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202c7c:	09500593          	li	a1,149
ffffffffc0202c80:	00003517          	auipc	a0,0x3
ffffffffc0202c84:	84850513          	addi	a0,a0,-1976 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202c88:	eecfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202c8c:	00003697          	auipc	a3,0x3
ffffffffc0202c90:	9e468693          	addi	a3,a3,-1564 # ffffffffc0205670 <default_pmm_manager+0x868>
ffffffffc0202c94:	00002617          	auipc	a2,0x2
ffffffffc0202c98:	ddc60613          	addi	a2,a2,-548 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202c9c:	09700593          	li	a1,151
ffffffffc0202ca0:	00003517          	auipc	a0,0x3
ffffffffc0202ca4:	82850513          	addi	a0,a0,-2008 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202ca8:	eccfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202cac:	00003697          	auipc	a3,0x3
ffffffffc0202cb0:	9d468693          	addi	a3,a3,-1580 # ffffffffc0205680 <default_pmm_manager+0x878>
ffffffffc0202cb4:	00002617          	auipc	a2,0x2
ffffffffc0202cb8:	dbc60613          	addi	a2,a2,-580 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202cbc:	09900593          	li	a1,153
ffffffffc0202cc0:	00003517          	auipc	a0,0x3
ffffffffc0202cc4:	80850513          	addi	a0,a0,-2040 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202cc8:	eacfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202ccc:	00003697          	auipc	a3,0x3
ffffffffc0202cd0:	9b468693          	addi	a3,a3,-1612 # ffffffffc0205680 <default_pmm_manager+0x878>
ffffffffc0202cd4:	00002617          	auipc	a2,0x2
ffffffffc0202cd8:	d9c60613          	addi	a2,a2,-612 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202cdc:	09b00593          	li	a1,155
ffffffffc0202ce0:	00002517          	auipc	a0,0x2
ffffffffc0202ce4:	7e850513          	addi	a0,a0,2024 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202ce8:	e8cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202cec:	00003697          	auipc	a3,0x3
ffffffffc0202cf0:	97468693          	addi	a3,a3,-1676 # ffffffffc0205660 <default_pmm_manager+0x858>
ffffffffc0202cf4:	00002617          	auipc	a2,0x2
ffffffffc0202cf8:	d7c60613          	addi	a2,a2,-644 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202cfc:	09100593          	li	a1,145
ffffffffc0202d00:	00002517          	auipc	a0,0x2
ffffffffc0202d04:	7c850513          	addi	a0,a0,1992 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202d08:	e6cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d0c:	00003697          	auipc	a3,0x3
ffffffffc0202d10:	95468693          	addi	a3,a3,-1708 # ffffffffc0205660 <default_pmm_manager+0x858>
ffffffffc0202d14:	00002617          	auipc	a2,0x2
ffffffffc0202d18:	d5c60613          	addi	a2,a2,-676 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202d1c:	09300593          	li	a1,147
ffffffffc0202d20:	00002517          	auipc	a0,0x2
ffffffffc0202d24:	7a850513          	addi	a0,a0,1960 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202d28:	e4cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d2c:	00003697          	auipc	a3,0x3
ffffffffc0202d30:	8e468693          	addi	a3,a3,-1820 # ffffffffc0205610 <default_pmm_manager+0x808>
ffffffffc0202d34:	00002617          	auipc	a2,0x2
ffffffffc0202d38:	d3c60613          	addi	a2,a2,-708 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202d3c:	0e800593          	li	a1,232
ffffffffc0202d40:	00002517          	auipc	a0,0x2
ffffffffc0202d44:	78850513          	addi	a0,a0,1928 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202d48:	e2cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202d4c:	00003697          	auipc	a3,0x3
ffffffffc0202d50:	84c68693          	addi	a3,a3,-1972 # ffffffffc0205598 <default_pmm_manager+0x790>
ffffffffc0202d54:	00002617          	auipc	a2,0x2
ffffffffc0202d58:	d1c60613          	addi	a2,a2,-740 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202d5c:	0d500593          	li	a1,213
ffffffffc0202d60:	00002517          	auipc	a0,0x2
ffffffffc0202d64:	76850513          	addi	a0,a0,1896 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202d68:	e0cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d6c:	00003697          	auipc	a3,0x3
ffffffffc0202d70:	92468693          	addi	a3,a3,-1756 # ffffffffc0205690 <default_pmm_manager+0x888>
ffffffffc0202d74:	00002617          	auipc	a2,0x2
ffffffffc0202d78:	cfc60613          	addi	a2,a2,-772 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202d7c:	09d00593          	li	a1,157
ffffffffc0202d80:	00002517          	auipc	a0,0x2
ffffffffc0202d84:	74850513          	addi	a0,a0,1864 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202d88:	decfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d8c:	00003697          	auipc	a3,0x3
ffffffffc0202d90:	90468693          	addi	a3,a3,-1788 # ffffffffc0205690 <default_pmm_manager+0x888>
ffffffffc0202d94:	00002617          	auipc	a2,0x2
ffffffffc0202d98:	cdc60613          	addi	a2,a2,-804 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202d9c:	09f00593          	li	a1,159
ffffffffc0202da0:	00002517          	auipc	a0,0x2
ffffffffc0202da4:	72850513          	addi	a0,a0,1832 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202da8:	dccfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202dac:	00002697          	auipc	a3,0x2
ffffffffc0202db0:	e9c68693          	addi	a3,a3,-356 # ffffffffc0204c48 <commands+0xa48>
ffffffffc0202db4:	00002617          	auipc	a2,0x2
ffffffffc0202db8:	cbc60613          	addi	a2,a2,-836 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202dbc:	0f100593          	li	a1,241
ffffffffc0202dc0:	00002517          	auipc	a0,0x2
ffffffffc0202dc4:	70850513          	addi	a0,a0,1800 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202dc8:	dacfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202dcc:	00003697          	auipc	a3,0x3
ffffffffc0202dd0:	93c68693          	addi	a3,a3,-1732 # ffffffffc0205708 <default_pmm_manager+0x900>
ffffffffc0202dd4:	00002617          	auipc	a2,0x2
ffffffffc0202dd8:	c9c60613          	addi	a2,a2,-868 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202ddc:	10000593          	li	a1,256
ffffffffc0202de0:	00002517          	auipc	a0,0x2
ffffffffc0202de4:	6e850513          	addi	a0,a0,1768 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202de8:	d8cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202dec:	00002697          	auipc	a3,0x2
ffffffffc0202df0:	72c68693          	addi	a3,a3,1836 # ffffffffc0205518 <default_pmm_manager+0x710>
ffffffffc0202df4:	00002617          	auipc	a2,0x2
ffffffffc0202df8:	c7c60613          	addi	a2,a2,-900 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202dfc:	0c200593          	li	a1,194
ffffffffc0202e00:	00002517          	auipc	a0,0x2
ffffffffc0202e04:	6c850513          	addi	a0,a0,1736 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202e08:	d6cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202e0c:	00002697          	auipc	a3,0x2
ffffffffc0202e10:	71c68693          	addi	a3,a3,1820 # ffffffffc0205528 <default_pmm_manager+0x720>
ffffffffc0202e14:	00002617          	auipc	a2,0x2
ffffffffc0202e18:	c5c60613          	addi	a2,a2,-932 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202e1c:	0c500593          	li	a1,197
ffffffffc0202e20:	00002517          	auipc	a0,0x2
ffffffffc0202e24:	6a850513          	addi	a0,a0,1704 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202e28:	d4cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e2c:	00002697          	auipc	a3,0x2
ffffffffc0202e30:	71468693          	addi	a3,a3,1812 # ffffffffc0205540 <default_pmm_manager+0x738>
ffffffffc0202e34:	00002617          	auipc	a2,0x2
ffffffffc0202e38:	c3c60613          	addi	a2,a2,-964 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202e3c:	0ca00593          	li	a1,202
ffffffffc0202e40:	00002517          	auipc	a0,0x2
ffffffffc0202e44:	68850513          	addi	a0,a0,1672 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202e48:	d2cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202e4c:	00002697          	auipc	a3,0x2
ffffffffc0202e50:	70468693          	addi	a3,a3,1796 # ffffffffc0205550 <default_pmm_manager+0x748>
ffffffffc0202e54:	00002617          	auipc	a2,0x2
ffffffffc0202e58:	c1c60613          	addi	a2,a2,-996 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202e5c:	0cd00593          	li	a1,205
ffffffffc0202e60:	00002517          	auipc	a0,0x2
ffffffffc0202e64:	66850513          	addi	a0,a0,1640 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202e68:	d0cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e6c:	00002697          	auipc	a3,0x2
ffffffffc0202e70:	c3468693          	addi	a3,a3,-972 # ffffffffc0204aa0 <commands+0x8a0>
ffffffffc0202e74:	00002617          	auipc	a2,0x2
ffffffffc0202e78:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202e7c:	0bd00593          	li	a1,189
ffffffffc0202e80:	00002517          	auipc	a0,0x2
ffffffffc0202e84:	64850513          	addi	a0,a0,1608 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202e88:	cecfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202e8c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202e8c:	0000d797          	auipc	a5,0xd
ffffffffc0202e90:	5d478793          	addi	a5,a5,1492 # ffffffffc0210460 <sm>
ffffffffc0202e94:	639c                	ld	a5,0(a5)
ffffffffc0202e96:	0107b303          	ld	t1,16(a5)
ffffffffc0202e9a:	8302                	jr	t1

ffffffffc0202e9c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202e9c:	0000d797          	auipc	a5,0xd
ffffffffc0202ea0:	5c478793          	addi	a5,a5,1476 # ffffffffc0210460 <sm>
ffffffffc0202ea4:	639c                	ld	a5,0(a5)
ffffffffc0202ea6:	0207b303          	ld	t1,32(a5)
ffffffffc0202eaa:	8302                	jr	t1

ffffffffc0202eac <swap_out>:
{
ffffffffc0202eac:	711d                	addi	sp,sp,-96
ffffffffc0202eae:	ec86                	sd	ra,88(sp)
ffffffffc0202eb0:	e8a2                	sd	s0,80(sp)
ffffffffc0202eb2:	e4a6                	sd	s1,72(sp)
ffffffffc0202eb4:	e0ca                	sd	s2,64(sp)
ffffffffc0202eb6:	fc4e                	sd	s3,56(sp)
ffffffffc0202eb8:	f852                	sd	s4,48(sp)
ffffffffc0202eba:	f456                	sd	s5,40(sp)
ffffffffc0202ebc:	f05a                	sd	s6,32(sp)
ffffffffc0202ebe:	ec5e                	sd	s7,24(sp)
ffffffffc0202ec0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202ec2:	cde9                	beqz	a1,ffffffffc0202f9c <swap_out+0xf0>
ffffffffc0202ec4:	8ab2                	mv	s5,a2
ffffffffc0202ec6:	892a                	mv	s2,a0
ffffffffc0202ec8:	8a2e                	mv	s4,a1
ffffffffc0202eca:	4401                	li	s0,0
ffffffffc0202ecc:	0000d997          	auipc	s3,0xd
ffffffffc0202ed0:	59498993          	addi	s3,s3,1428 # ffffffffc0210460 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ed4:	00003b17          	auipc	s6,0x3
ffffffffc0202ed8:	8dcb0b13          	addi	s6,s6,-1828 # ffffffffc02057b0 <default_pmm_manager+0x9a8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202edc:	00003b97          	auipc	s7,0x3
ffffffffc0202ee0:	8bcb8b93          	addi	s7,s7,-1860 # ffffffffc0205798 <default_pmm_manager+0x990>
ffffffffc0202ee4:	a825                	j	ffffffffc0202f1c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ee6:	67a2                	ld	a5,8(sp)
ffffffffc0202ee8:	8626                	mv	a2,s1
ffffffffc0202eea:	85a2                	mv	a1,s0
ffffffffc0202eec:	63b4                	ld	a3,64(a5)
ffffffffc0202eee:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202ef0:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ef2:	82b1                	srli	a3,a3,0xc
ffffffffc0202ef4:	0685                	addi	a3,a3,1
ffffffffc0202ef6:	9c8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202efa:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202efc:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202efe:	613c                	ld	a5,64(a0)
ffffffffc0202f00:	83b1                	srli	a5,a5,0xc
ffffffffc0202f02:	0785                	addi	a5,a5,1
ffffffffc0202f04:	07a2                	slli	a5,a5,0x8
ffffffffc0202f06:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202f0a:	fbcfe0ef          	jal	ra,ffffffffc02016c6 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202f0e:	01893503          	ld	a0,24(s2)
ffffffffc0202f12:	85a6                	mv	a1,s1
ffffffffc0202f14:	ebeff0ef          	jal	ra,ffffffffc02025d2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202f18:	048a0d63          	beq	s4,s0,ffffffffc0202f72 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202f1c:	0009b783          	ld	a5,0(s3)
ffffffffc0202f20:	8656                	mv	a2,s5
ffffffffc0202f22:	002c                	addi	a1,sp,8
ffffffffc0202f24:	7b9c                	ld	a5,48(a5)
ffffffffc0202f26:	854a                	mv	a0,s2
ffffffffc0202f28:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202f2a:	e12d                	bnez	a0,ffffffffc0202f8c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202f2c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f2e:	01893503          	ld	a0,24(s2)
ffffffffc0202f32:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202f34:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f36:	85a6                	mv	a1,s1
ffffffffc0202f38:	815fe0ef          	jal	ra,ffffffffc020174c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f3c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f3e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f40:	8b85                	andi	a5,a5,1
ffffffffc0202f42:	cfb9                	beqz	a5,ffffffffc0202fa0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202f44:	65a2                	ld	a1,8(sp)
ffffffffc0202f46:	61bc                	ld	a5,64(a1)
ffffffffc0202f48:	83b1                	srli	a5,a5,0xc
ffffffffc0202f4a:	00178513          	addi	a0,a5,1
ffffffffc0202f4e:	0522                	slli	a0,a0,0x8
ffffffffc0202f50:	365000ef          	jal	ra,ffffffffc0203ab4 <swapfs_write>
ffffffffc0202f54:	d949                	beqz	a0,ffffffffc0202ee6 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f56:	855e                	mv	a0,s7
ffffffffc0202f58:	966fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202f5c:	0009b783          	ld	a5,0(s3)
ffffffffc0202f60:	6622                	ld	a2,8(sp)
ffffffffc0202f62:	4681                	li	a3,0
ffffffffc0202f64:	739c                	ld	a5,32(a5)
ffffffffc0202f66:	85a6                	mv	a1,s1
ffffffffc0202f68:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202f6a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202f6c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202f6e:	fa8a17e3          	bne	s4,s0,ffffffffc0202f1c <swap_out+0x70>
}
ffffffffc0202f72:	8522                	mv	a0,s0
ffffffffc0202f74:	60e6                	ld	ra,88(sp)
ffffffffc0202f76:	6446                	ld	s0,80(sp)
ffffffffc0202f78:	64a6                	ld	s1,72(sp)
ffffffffc0202f7a:	6906                	ld	s2,64(sp)
ffffffffc0202f7c:	79e2                	ld	s3,56(sp)
ffffffffc0202f7e:	7a42                	ld	s4,48(sp)
ffffffffc0202f80:	7aa2                	ld	s5,40(sp)
ffffffffc0202f82:	7b02                	ld	s6,32(sp)
ffffffffc0202f84:	6be2                	ld	s7,24(sp)
ffffffffc0202f86:	6c42                	ld	s8,16(sp)
ffffffffc0202f88:	6125                	addi	sp,sp,96
ffffffffc0202f8a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202f8c:	85a2                	mv	a1,s0
ffffffffc0202f8e:	00002517          	auipc	a0,0x2
ffffffffc0202f92:	7c250513          	addi	a0,a0,1986 # ffffffffc0205750 <default_pmm_manager+0x948>
ffffffffc0202f96:	928fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202f9a:	bfe1                	j	ffffffffc0202f72 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202f9c:	4401                	li	s0,0
ffffffffc0202f9e:	bfd1                	j	ffffffffc0202f72 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fa0:	00002697          	auipc	a3,0x2
ffffffffc0202fa4:	7e068693          	addi	a3,a3,2016 # ffffffffc0205780 <default_pmm_manager+0x978>
ffffffffc0202fa8:	00002617          	auipc	a2,0x2
ffffffffc0202fac:	ac860613          	addi	a2,a2,-1336 # ffffffffc0204a70 <commands+0x870>
ffffffffc0202fb0:	06600593          	li	a1,102
ffffffffc0202fb4:	00002517          	auipc	a0,0x2
ffffffffc0202fb8:	51450513          	addi	a0,a0,1300 # ffffffffc02054c8 <default_pmm_manager+0x6c0>
ffffffffc0202fbc:	bb8fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202fc0 <_clock_init_mm>:
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0202fc0:	4501                	li	a0,0
ffffffffc0202fc2:	8082                	ret

ffffffffc0202fc4 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0202fc4:	4501                	li	a0,0
ffffffffc0202fc6:	8082                	ret

ffffffffc0202fc8 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0202fc8:	4501                	li	a0,0
ffffffffc0202fca:	8082                	ret

ffffffffc0202fcc <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc0202fcc:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202fce:	678d                	lui	a5,0x3
ffffffffc0202fd0:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0202fd2:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202fd4:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0202fd8:	0000d797          	auipc	a5,0xd
ffffffffc0202fdc:	49478793          	addi	a5,a5,1172 # ffffffffc021046c <pgfault_num>
ffffffffc0202fe0:	4398                	lw	a4,0(a5)
ffffffffc0202fe2:	4691                	li	a3,4
ffffffffc0202fe4:	2701                	sext.w	a4,a4
ffffffffc0202fe6:	08d71f63          	bne	a4,a3,ffffffffc0203084 <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202fea:	6685                	lui	a3,0x1
ffffffffc0202fec:	4629                	li	a2,10
ffffffffc0202fee:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0202ff2:	4394                	lw	a3,0(a5)
ffffffffc0202ff4:	2681                	sext.w	a3,a3
ffffffffc0202ff6:	20e69763          	bne	a3,a4,ffffffffc0203204 <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202ffa:	6711                	lui	a4,0x4
ffffffffc0202ffc:	4635                	li	a2,13
ffffffffc0202ffe:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203002:	4398                	lw	a4,0(a5)
ffffffffc0203004:	2701                	sext.w	a4,a4
ffffffffc0203006:	1cd71f63          	bne	a4,a3,ffffffffc02031e4 <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020300a:	6689                	lui	a3,0x2
ffffffffc020300c:	462d                	li	a2,11
ffffffffc020300e:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203012:	4394                	lw	a3,0(a5)
ffffffffc0203014:	2681                	sext.w	a3,a3
ffffffffc0203016:	1ae69763          	bne	a3,a4,ffffffffc02031c4 <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020301a:	6715                	lui	a4,0x5
ffffffffc020301c:	46b9                	li	a3,14
ffffffffc020301e:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203022:	4398                	lw	a4,0(a5)
ffffffffc0203024:	4695                	li	a3,5
ffffffffc0203026:	2701                	sext.w	a4,a4
ffffffffc0203028:	16d71e63          	bne	a4,a3,ffffffffc02031a4 <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc020302c:	4394                	lw	a3,0(a5)
ffffffffc020302e:	2681                	sext.w	a3,a3
ffffffffc0203030:	14e69a63          	bne	a3,a4,ffffffffc0203184 <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc0203034:	4398                	lw	a4,0(a5)
ffffffffc0203036:	2701                	sext.w	a4,a4
ffffffffc0203038:	12d71663          	bne	a4,a3,ffffffffc0203164 <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc020303c:	4394                	lw	a3,0(a5)
ffffffffc020303e:	2681                	sext.w	a3,a3
ffffffffc0203040:	10e69263          	bne	a3,a4,ffffffffc0203144 <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc0203044:	4398                	lw	a4,0(a5)
ffffffffc0203046:	2701                	sext.w	a4,a4
ffffffffc0203048:	0cd71e63          	bne	a4,a3,ffffffffc0203124 <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc020304c:	4394                	lw	a3,0(a5)
ffffffffc020304e:	2681                	sext.w	a3,a3
ffffffffc0203050:	0ae69a63          	bne	a3,a4,ffffffffc0203104 <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203054:	6715                	lui	a4,0x5
ffffffffc0203056:	46b9                	li	a3,14
ffffffffc0203058:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc020305c:	4398                	lw	a4,0(a5)
ffffffffc020305e:	4695                	li	a3,5
ffffffffc0203060:	2701                	sext.w	a4,a4
ffffffffc0203062:	08d71163          	bne	a4,a3,ffffffffc02030e4 <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203066:	6705                	lui	a4,0x1
ffffffffc0203068:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc020306c:	4729                	li	a4,10
ffffffffc020306e:	04e69b63          	bne	a3,a4,ffffffffc02030c4 <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc0203072:	439c                	lw	a5,0(a5)
ffffffffc0203074:	4719                	li	a4,6
ffffffffc0203076:	2781                	sext.w	a5,a5
ffffffffc0203078:	02e79663          	bne	a5,a4,ffffffffc02030a4 <_clock_check_swap+0xd8>
}
ffffffffc020307c:	60a2                	ld	ra,8(sp)
ffffffffc020307e:	4501                	li	a0,0
ffffffffc0203080:	0141                	addi	sp,sp,16
ffffffffc0203082:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203084:	00002697          	auipc	a3,0x2
ffffffffc0203088:	60c68693          	addi	a3,a3,1548 # ffffffffc0205690 <default_pmm_manager+0x888>
ffffffffc020308c:	00002617          	auipc	a2,0x2
ffffffffc0203090:	9e460613          	addi	a2,a2,-1564 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203094:	07700593          	li	a1,119
ffffffffc0203098:	00002517          	auipc	a0,0x2
ffffffffc020309c:	75850513          	addi	a0,a0,1880 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc02030a0:	ad4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==6);
ffffffffc02030a4:	00002697          	auipc	a3,0x2
ffffffffc02030a8:	79c68693          	addi	a3,a3,1948 # ffffffffc0205840 <default_pmm_manager+0xa38>
ffffffffc02030ac:	00002617          	auipc	a2,0x2
ffffffffc02030b0:	9c460613          	addi	a2,a2,-1596 # ffffffffc0204a70 <commands+0x870>
ffffffffc02030b4:	08e00593          	li	a1,142
ffffffffc02030b8:	00002517          	auipc	a0,0x2
ffffffffc02030bc:	73850513          	addi	a0,a0,1848 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc02030c0:	ab4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02030c4:	00002697          	auipc	a3,0x2
ffffffffc02030c8:	75468693          	addi	a3,a3,1876 # ffffffffc0205818 <default_pmm_manager+0xa10>
ffffffffc02030cc:	00002617          	auipc	a2,0x2
ffffffffc02030d0:	9a460613          	addi	a2,a2,-1628 # ffffffffc0204a70 <commands+0x870>
ffffffffc02030d4:	08c00593          	li	a1,140
ffffffffc02030d8:	00002517          	auipc	a0,0x2
ffffffffc02030dc:	71850513          	addi	a0,a0,1816 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc02030e0:	a94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02030e4:	00002697          	auipc	a3,0x2
ffffffffc02030e8:	72468693          	addi	a3,a3,1828 # ffffffffc0205808 <default_pmm_manager+0xa00>
ffffffffc02030ec:	00002617          	auipc	a2,0x2
ffffffffc02030f0:	98460613          	addi	a2,a2,-1660 # ffffffffc0204a70 <commands+0x870>
ffffffffc02030f4:	08b00593          	li	a1,139
ffffffffc02030f8:	00002517          	auipc	a0,0x2
ffffffffc02030fc:	6f850513          	addi	a0,a0,1784 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc0203100:	a74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203104:	00002697          	auipc	a3,0x2
ffffffffc0203108:	70468693          	addi	a3,a3,1796 # ffffffffc0205808 <default_pmm_manager+0xa00>
ffffffffc020310c:	00002617          	auipc	a2,0x2
ffffffffc0203110:	96460613          	addi	a2,a2,-1692 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203114:	08900593          	li	a1,137
ffffffffc0203118:	00002517          	auipc	a0,0x2
ffffffffc020311c:	6d850513          	addi	a0,a0,1752 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc0203120:	a54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203124:	00002697          	auipc	a3,0x2
ffffffffc0203128:	6e468693          	addi	a3,a3,1764 # ffffffffc0205808 <default_pmm_manager+0xa00>
ffffffffc020312c:	00002617          	auipc	a2,0x2
ffffffffc0203130:	94460613          	addi	a2,a2,-1724 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203134:	08700593          	li	a1,135
ffffffffc0203138:	00002517          	auipc	a0,0x2
ffffffffc020313c:	6b850513          	addi	a0,a0,1720 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc0203140:	a34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203144:	00002697          	auipc	a3,0x2
ffffffffc0203148:	6c468693          	addi	a3,a3,1732 # ffffffffc0205808 <default_pmm_manager+0xa00>
ffffffffc020314c:	00002617          	auipc	a2,0x2
ffffffffc0203150:	92460613          	addi	a2,a2,-1756 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203154:	08500593          	li	a1,133
ffffffffc0203158:	00002517          	auipc	a0,0x2
ffffffffc020315c:	69850513          	addi	a0,a0,1688 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc0203160:	a14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203164:	00002697          	auipc	a3,0x2
ffffffffc0203168:	6a468693          	addi	a3,a3,1700 # ffffffffc0205808 <default_pmm_manager+0xa00>
ffffffffc020316c:	00002617          	auipc	a2,0x2
ffffffffc0203170:	90460613          	addi	a2,a2,-1788 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203174:	08300593          	li	a1,131
ffffffffc0203178:	00002517          	auipc	a0,0x2
ffffffffc020317c:	67850513          	addi	a0,a0,1656 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc0203180:	9f4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203184:	00002697          	auipc	a3,0x2
ffffffffc0203188:	68468693          	addi	a3,a3,1668 # ffffffffc0205808 <default_pmm_manager+0xa00>
ffffffffc020318c:	00002617          	auipc	a2,0x2
ffffffffc0203190:	8e460613          	addi	a2,a2,-1820 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203194:	08100593          	li	a1,129
ffffffffc0203198:	00002517          	auipc	a0,0x2
ffffffffc020319c:	65850513          	addi	a0,a0,1624 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc02031a0:	9d4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031a4:	00002697          	auipc	a3,0x2
ffffffffc02031a8:	66468693          	addi	a3,a3,1636 # ffffffffc0205808 <default_pmm_manager+0xa00>
ffffffffc02031ac:	00002617          	auipc	a2,0x2
ffffffffc02031b0:	8c460613          	addi	a2,a2,-1852 # ffffffffc0204a70 <commands+0x870>
ffffffffc02031b4:	07f00593          	li	a1,127
ffffffffc02031b8:	00002517          	auipc	a0,0x2
ffffffffc02031bc:	63850513          	addi	a0,a0,1592 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc02031c0:	9b4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02031c4:	00002697          	auipc	a3,0x2
ffffffffc02031c8:	4cc68693          	addi	a3,a3,1228 # ffffffffc0205690 <default_pmm_manager+0x888>
ffffffffc02031cc:	00002617          	auipc	a2,0x2
ffffffffc02031d0:	8a460613          	addi	a2,a2,-1884 # ffffffffc0204a70 <commands+0x870>
ffffffffc02031d4:	07d00593          	li	a1,125
ffffffffc02031d8:	00002517          	auipc	a0,0x2
ffffffffc02031dc:	61850513          	addi	a0,a0,1560 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc02031e0:	994fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02031e4:	00002697          	auipc	a3,0x2
ffffffffc02031e8:	4ac68693          	addi	a3,a3,1196 # ffffffffc0205690 <default_pmm_manager+0x888>
ffffffffc02031ec:	00002617          	auipc	a2,0x2
ffffffffc02031f0:	88460613          	addi	a2,a2,-1916 # ffffffffc0204a70 <commands+0x870>
ffffffffc02031f4:	07b00593          	li	a1,123
ffffffffc02031f8:	00002517          	auipc	a0,0x2
ffffffffc02031fc:	5f850513          	addi	a0,a0,1528 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc0203200:	974fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc0203204:	00002697          	auipc	a3,0x2
ffffffffc0203208:	48c68693          	addi	a3,a3,1164 # ffffffffc0205690 <default_pmm_manager+0x888>
ffffffffc020320c:	00002617          	auipc	a2,0x2
ffffffffc0203210:	86460613          	addi	a2,a2,-1948 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203214:	07900593          	li	a1,121
ffffffffc0203218:	00002517          	auipc	a0,0x2
ffffffffc020321c:	5d850513          	addi	a0,a0,1496 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc0203220:	954fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203224 <_clock_swap_out_victim>:
         assert(head != NULL);
ffffffffc0203224:	751c                	ld	a5,40(a0)
{
ffffffffc0203226:	1141                	addi	sp,sp,-16
ffffffffc0203228:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020322a:	c39d                	beqz	a5,ffffffffc0203250 <_clock_swap_out_victim+0x2c>
     assert(in_tick==0);
ffffffffc020322c:	e211                	bnez	a2,ffffffffc0203230 <_clock_swap_out_victim+0xc>
    }
ffffffffc020322e:	a001                	j	ffffffffc020322e <_clock_swap_out_victim+0xa>
     assert(in_tick==0);
ffffffffc0203230:	00002697          	auipc	a3,0x2
ffffffffc0203234:	65868693          	addi	a3,a3,1624 # ffffffffc0205888 <default_pmm_manager+0xa80>
ffffffffc0203238:	00002617          	auipc	a2,0x2
ffffffffc020323c:	83860613          	addi	a2,a2,-1992 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203240:	04400593          	li	a1,68
ffffffffc0203244:	00002517          	auipc	a0,0x2
ffffffffc0203248:	5ac50513          	addi	a0,a0,1452 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc020324c:	928fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(head != NULL);
ffffffffc0203250:	00002697          	auipc	a3,0x2
ffffffffc0203254:	62868693          	addi	a3,a3,1576 # ffffffffc0205878 <default_pmm_manager+0xa70>
ffffffffc0203258:	00002617          	auipc	a2,0x2
ffffffffc020325c:	81860613          	addi	a2,a2,-2024 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203260:	04300593          	li	a1,67
ffffffffc0203264:	00002517          	auipc	a0,0x2
ffffffffc0203268:	58c50513          	addi	a0,a0,1420 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
ffffffffc020326c:	908fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203270 <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203270:	03060613          	addi	a2,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203274:	ca09                	beqz	a2,ffffffffc0203286 <_clock_map_swappable+0x16>
ffffffffc0203276:	0000d797          	auipc	a5,0xd
ffffffffc020327a:	31278793          	addi	a5,a5,786 # ffffffffc0210588 <curr_ptr>
ffffffffc020327e:	639c                	ld	a5,0(a5)
ffffffffc0203280:	c399                	beqz	a5,ffffffffc0203286 <_clock_map_swappable+0x16>
}
ffffffffc0203282:	4501                	li	a0,0
ffffffffc0203284:	8082                	ret
{
ffffffffc0203286:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203288:	00002697          	auipc	a3,0x2
ffffffffc020328c:	5c868693          	addi	a3,a3,1480 # ffffffffc0205850 <default_pmm_manager+0xa48>
ffffffffc0203290:	00001617          	auipc	a2,0x1
ffffffffc0203294:	7e060613          	addi	a2,a2,2016 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203298:	03300593          	li	a1,51
ffffffffc020329c:	00002517          	auipc	a0,0x2
ffffffffc02032a0:	55450513          	addi	a0,a0,1364 # ffffffffc02057f0 <default_pmm_manager+0x9e8>
{
ffffffffc02032a4:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02032a6:	8cefd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02032aa <_clock_tick_event>:
ffffffffc02032aa:	4501                	li	a0,0
ffffffffc02032ac:	8082                	ret

ffffffffc02032ae <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02032ae:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02032b0:	00002697          	auipc	a3,0x2
ffffffffc02032b4:	60068693          	addi	a3,a3,1536 # ffffffffc02058b0 <default_pmm_manager+0xaa8>
ffffffffc02032b8:	00001617          	auipc	a2,0x1
ffffffffc02032bc:	7b860613          	addi	a2,a2,1976 # ffffffffc0204a70 <commands+0x870>
ffffffffc02032c0:	07d00593          	li	a1,125
ffffffffc02032c4:	00002517          	auipc	a0,0x2
ffffffffc02032c8:	60c50513          	addi	a0,a0,1548 # ffffffffc02058d0 <default_pmm_manager+0xac8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02032cc:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02032ce:	8a6fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02032d2 <mm_create>:
mm_create(void) {
ffffffffc02032d2:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02032d4:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02032d8:	e022                	sd	s0,0(sp)
ffffffffc02032da:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02032dc:	b8eff0ef          	jal	ra,ffffffffc020266a <kmalloc>
ffffffffc02032e0:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02032e2:	c115                	beqz	a0,ffffffffc0203306 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02032e4:	0000d797          	auipc	a5,0xd
ffffffffc02032e8:	18478793          	addi	a5,a5,388 # ffffffffc0210468 <swap_init_ok>
ffffffffc02032ec:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02032ee:	e408                	sd	a0,8(s0)
ffffffffc02032f0:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02032f2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02032f6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02032fa:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02032fe:	2781                	sext.w	a5,a5
ffffffffc0203300:	eb81                	bnez	a5,ffffffffc0203310 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0203302:	02053423          	sd	zero,40(a0)
}
ffffffffc0203306:	8522                	mv	a0,s0
ffffffffc0203308:	60a2                	ld	ra,8(sp)
ffffffffc020330a:	6402                	ld	s0,0(sp)
ffffffffc020330c:	0141                	addi	sp,sp,16
ffffffffc020330e:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203310:	b7dff0ef          	jal	ra,ffffffffc0202e8c <swap_init_mm>
}
ffffffffc0203314:	8522                	mv	a0,s0
ffffffffc0203316:	60a2                	ld	ra,8(sp)
ffffffffc0203318:	6402                	ld	s0,0(sp)
ffffffffc020331a:	0141                	addi	sp,sp,16
ffffffffc020331c:	8082                	ret

ffffffffc020331e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc020331e:	1101                	addi	sp,sp,-32
ffffffffc0203320:	e04a                	sd	s2,0(sp)
ffffffffc0203322:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203324:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203328:	e822                	sd	s0,16(sp)
ffffffffc020332a:	e426                	sd	s1,8(sp)
ffffffffc020332c:	ec06                	sd	ra,24(sp)
ffffffffc020332e:	84ae                	mv	s1,a1
ffffffffc0203330:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203332:	b38ff0ef          	jal	ra,ffffffffc020266a <kmalloc>
    if (vma != NULL) {
ffffffffc0203336:	c509                	beqz	a0,ffffffffc0203340 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203338:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020333c:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020333e:	ed00                	sd	s0,24(a0)
}
ffffffffc0203340:	60e2                	ld	ra,24(sp)
ffffffffc0203342:	6442                	ld	s0,16(sp)
ffffffffc0203344:	64a2                	ld	s1,8(sp)
ffffffffc0203346:	6902                	ld	s2,0(sp)
ffffffffc0203348:	6105                	addi	sp,sp,32
ffffffffc020334a:	8082                	ret

ffffffffc020334c <find_vma>:
    if (mm != NULL) {
ffffffffc020334c:	c51d                	beqz	a0,ffffffffc020337a <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc020334e:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203350:	c781                	beqz	a5,ffffffffc0203358 <find_vma+0xc>
ffffffffc0203352:	6798                	ld	a4,8(a5)
ffffffffc0203354:	02e5f663          	bleu	a4,a1,ffffffffc0203380 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0203358:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020335a:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020335c:	00f50f63          	beq	a0,a5,ffffffffc020337a <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0203360:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203364:	fee5ebe3          	bltu	a1,a4,ffffffffc020335a <find_vma+0xe>
ffffffffc0203368:	ff07b703          	ld	a4,-16(a5)
ffffffffc020336c:	fee5f7e3          	bleu	a4,a1,ffffffffc020335a <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0203370:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0203372:	c781                	beqz	a5,ffffffffc020337a <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0203374:	e91c                	sd	a5,16(a0)
}
ffffffffc0203376:	853e                	mv	a0,a5
ffffffffc0203378:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020337a:	4781                	li	a5,0
}
ffffffffc020337c:	853e                	mv	a0,a5
ffffffffc020337e:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203380:	6b98                	ld	a4,16(a5)
ffffffffc0203382:	fce5fbe3          	bleu	a4,a1,ffffffffc0203358 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0203386:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0203388:	b7fd                	j	ffffffffc0203376 <find_vma+0x2a>

ffffffffc020338a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020338a:	6590                	ld	a2,8(a1)
ffffffffc020338c:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203390:	1141                	addi	sp,sp,-16
ffffffffc0203392:	e406                	sd	ra,8(sp)
ffffffffc0203394:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203396:	01066863          	bltu	a2,a6,ffffffffc02033a6 <insert_vma_struct+0x1c>
ffffffffc020339a:	a8b9                	j	ffffffffc02033f8 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020339c:	fe87b683          	ld	a3,-24(a5)
ffffffffc02033a0:	04d66763          	bltu	a2,a3,ffffffffc02033ee <insert_vma_struct+0x64>
ffffffffc02033a4:	873e                	mv	a4,a5
ffffffffc02033a6:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02033a8:	fef51ae3          	bne	a0,a5,ffffffffc020339c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02033ac:	02a70463          	beq	a4,a0,ffffffffc02033d4 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02033b0:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02033b4:	fe873883          	ld	a7,-24(a4)
ffffffffc02033b8:	08d8f063          	bleu	a3,a7,ffffffffc0203438 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02033bc:	04d66e63          	bltu	a2,a3,ffffffffc0203418 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02033c0:	00f50a63          	beq	a0,a5,ffffffffc02033d4 <insert_vma_struct+0x4a>
ffffffffc02033c4:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02033c8:	0506e863          	bltu	a3,a6,ffffffffc0203418 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02033cc:	ff07b603          	ld	a2,-16(a5)
ffffffffc02033d0:	02c6f263          	bleu	a2,a3,ffffffffc02033f4 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02033d4:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02033d6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02033d8:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02033dc:	e390                	sd	a2,0(a5)
ffffffffc02033de:	e710                	sd	a2,8(a4)
}
ffffffffc02033e0:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02033e2:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02033e4:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02033e6:	2685                	addiw	a3,a3,1
ffffffffc02033e8:	d114                	sw	a3,32(a0)
}
ffffffffc02033ea:	0141                	addi	sp,sp,16
ffffffffc02033ec:	8082                	ret
    if (le_prev != list) {
ffffffffc02033ee:	fca711e3          	bne	a4,a0,ffffffffc02033b0 <insert_vma_struct+0x26>
ffffffffc02033f2:	bfd9                	j	ffffffffc02033c8 <insert_vma_struct+0x3e>
ffffffffc02033f4:	ebbff0ef          	jal	ra,ffffffffc02032ae <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02033f8:	00002697          	auipc	a3,0x2
ffffffffc02033fc:	56868693          	addi	a3,a3,1384 # ffffffffc0205960 <default_pmm_manager+0xb58>
ffffffffc0203400:	00001617          	auipc	a2,0x1
ffffffffc0203404:	67060613          	addi	a2,a2,1648 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203408:	08400593          	li	a1,132
ffffffffc020340c:	00002517          	auipc	a0,0x2
ffffffffc0203410:	4c450513          	addi	a0,a0,1220 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203414:	f61fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203418:	00002697          	auipc	a3,0x2
ffffffffc020341c:	58868693          	addi	a3,a3,1416 # ffffffffc02059a0 <default_pmm_manager+0xb98>
ffffffffc0203420:	00001617          	auipc	a2,0x1
ffffffffc0203424:	65060613          	addi	a2,a2,1616 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203428:	07c00593          	li	a1,124
ffffffffc020342c:	00002517          	auipc	a0,0x2
ffffffffc0203430:	4a450513          	addi	a0,a0,1188 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203434:	f41fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203438:	00002697          	auipc	a3,0x2
ffffffffc020343c:	54868693          	addi	a3,a3,1352 # ffffffffc0205980 <default_pmm_manager+0xb78>
ffffffffc0203440:	00001617          	auipc	a2,0x1
ffffffffc0203444:	63060613          	addi	a2,a2,1584 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203448:	07b00593          	li	a1,123
ffffffffc020344c:	00002517          	auipc	a0,0x2
ffffffffc0203450:	48450513          	addi	a0,a0,1156 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203454:	f21fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203458 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203458:	1141                	addi	sp,sp,-16
ffffffffc020345a:	e022                	sd	s0,0(sp)
ffffffffc020345c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020345e:	6508                	ld	a0,8(a0)
ffffffffc0203460:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203462:	00a40e63          	beq	s0,a0,ffffffffc020347e <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203466:	6118                	ld	a4,0(a0)
ffffffffc0203468:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc020346a:	03000593          	li	a1,48
ffffffffc020346e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203470:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203472:	e398                	sd	a4,0(a5)
ffffffffc0203474:	ab8ff0ef          	jal	ra,ffffffffc020272c <kfree>
    return listelm->next;
ffffffffc0203478:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020347a:	fea416e3          	bne	s0,a0,ffffffffc0203466 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020347e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203480:	6402                	ld	s0,0(sp)
ffffffffc0203482:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203484:	03000593          	li	a1,48
}
ffffffffc0203488:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020348a:	aa2ff06f          	j	ffffffffc020272c <kfree>

ffffffffc020348e <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020348e:	715d                	addi	sp,sp,-80
ffffffffc0203490:	e486                	sd	ra,72(sp)
ffffffffc0203492:	e0a2                	sd	s0,64(sp)
ffffffffc0203494:	fc26                	sd	s1,56(sp)
ffffffffc0203496:	f84a                	sd	s2,48(sp)
ffffffffc0203498:	f052                	sd	s4,32(sp)
ffffffffc020349a:	f44e                	sd	s3,40(sp)
ffffffffc020349c:	ec56                	sd	s5,24(sp)
ffffffffc020349e:	e85a                	sd	s6,16(sp)
ffffffffc02034a0:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02034a2:	a6afe0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc02034a6:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02034a8:	a64fe0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc02034ac:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc02034ae:	e25ff0ef          	jal	ra,ffffffffc02032d2 <mm_create>
    assert(mm != NULL);
ffffffffc02034b2:	842a                	mv	s0,a0
ffffffffc02034b4:	03200493          	li	s1,50
ffffffffc02034b8:	e919                	bnez	a0,ffffffffc02034ce <vmm_init+0x40>
ffffffffc02034ba:	aeed                	j	ffffffffc02038b4 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc02034bc:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02034be:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02034c0:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02034c4:	14ed                	addi	s1,s1,-5
ffffffffc02034c6:	8522                	mv	a0,s0
ffffffffc02034c8:	ec3ff0ef          	jal	ra,ffffffffc020338a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02034cc:	c88d                	beqz	s1,ffffffffc02034fe <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034ce:	03000513          	li	a0,48
ffffffffc02034d2:	998ff0ef          	jal	ra,ffffffffc020266a <kmalloc>
ffffffffc02034d6:	85aa                	mv	a1,a0
ffffffffc02034d8:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02034dc:	f165                	bnez	a0,ffffffffc02034bc <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc02034de:	00002697          	auipc	a3,0x2
ffffffffc02034e2:	07268693          	addi	a3,a3,114 # ffffffffc0205550 <default_pmm_manager+0x748>
ffffffffc02034e6:	00001617          	auipc	a2,0x1
ffffffffc02034ea:	58a60613          	addi	a2,a2,1418 # ffffffffc0204a70 <commands+0x870>
ffffffffc02034ee:	0ce00593          	li	a1,206
ffffffffc02034f2:	00002517          	auipc	a0,0x2
ffffffffc02034f6:	3de50513          	addi	a0,a0,990 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc02034fa:	e7bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02034fe:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203502:	1f900993          	li	s3,505
ffffffffc0203506:	a819                	j	ffffffffc020351c <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0203508:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020350a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020350c:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203510:	0495                	addi	s1,s1,5
ffffffffc0203512:	8522                	mv	a0,s0
ffffffffc0203514:	e77ff0ef          	jal	ra,ffffffffc020338a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203518:	03348a63          	beq	s1,s3,ffffffffc020354c <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020351c:	03000513          	li	a0,48
ffffffffc0203520:	94aff0ef          	jal	ra,ffffffffc020266a <kmalloc>
ffffffffc0203524:	85aa                	mv	a1,a0
ffffffffc0203526:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020352a:	fd79                	bnez	a0,ffffffffc0203508 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc020352c:	00002697          	auipc	a3,0x2
ffffffffc0203530:	02468693          	addi	a3,a3,36 # ffffffffc0205550 <default_pmm_manager+0x748>
ffffffffc0203534:	00001617          	auipc	a2,0x1
ffffffffc0203538:	53c60613          	addi	a2,a2,1340 # ffffffffc0204a70 <commands+0x870>
ffffffffc020353c:	0d400593          	li	a1,212
ffffffffc0203540:	00002517          	auipc	a0,0x2
ffffffffc0203544:	39050513          	addi	a0,a0,912 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203548:	e2dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020354c:	6418                	ld	a4,8(s0)
ffffffffc020354e:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203550:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203554:	2ae40063          	beq	s0,a4,ffffffffc02037f4 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203558:	fe873603          	ld	a2,-24(a4)
ffffffffc020355c:	ffe78693          	addi	a3,a5,-2
ffffffffc0203560:	20d61a63          	bne	a2,a3,ffffffffc0203774 <vmm_init+0x2e6>
ffffffffc0203564:	ff073683          	ld	a3,-16(a4)
ffffffffc0203568:	20d79663          	bne	a5,a3,ffffffffc0203774 <vmm_init+0x2e6>
ffffffffc020356c:	0795                	addi	a5,a5,5
ffffffffc020356e:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203570:	feb792e3          	bne	a5,a1,ffffffffc0203554 <vmm_init+0xc6>
ffffffffc0203574:	499d                	li	s3,7
ffffffffc0203576:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203578:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020357c:	85a6                	mv	a1,s1
ffffffffc020357e:	8522                	mv	a0,s0
ffffffffc0203580:	dcdff0ef          	jal	ra,ffffffffc020334c <find_vma>
ffffffffc0203584:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc0203586:	2e050763          	beqz	a0,ffffffffc0203874 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020358a:	00148593          	addi	a1,s1,1
ffffffffc020358e:	8522                	mv	a0,s0
ffffffffc0203590:	dbdff0ef          	jal	ra,ffffffffc020334c <find_vma>
ffffffffc0203594:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0203596:	2a050f63          	beqz	a0,ffffffffc0203854 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020359a:	85ce                	mv	a1,s3
ffffffffc020359c:	8522                	mv	a0,s0
ffffffffc020359e:	dafff0ef          	jal	ra,ffffffffc020334c <find_vma>
        assert(vma3 == NULL);
ffffffffc02035a2:	28051963          	bnez	a0,ffffffffc0203834 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02035a6:	00348593          	addi	a1,s1,3
ffffffffc02035aa:	8522                	mv	a0,s0
ffffffffc02035ac:	da1ff0ef          	jal	ra,ffffffffc020334c <find_vma>
        assert(vma4 == NULL);
ffffffffc02035b0:	26051263          	bnez	a0,ffffffffc0203814 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02035b4:	00448593          	addi	a1,s1,4
ffffffffc02035b8:	8522                	mv	a0,s0
ffffffffc02035ba:	d93ff0ef          	jal	ra,ffffffffc020334c <find_vma>
        assert(vma5 == NULL);
ffffffffc02035be:	2c051b63          	bnez	a0,ffffffffc0203894 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02035c2:	008b3783          	ld	a5,8(s6)
ffffffffc02035c6:	1c979763          	bne	a5,s1,ffffffffc0203794 <vmm_init+0x306>
ffffffffc02035ca:	010b3783          	ld	a5,16(s6)
ffffffffc02035ce:	1d379363          	bne	a5,s3,ffffffffc0203794 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02035d2:	008ab783          	ld	a5,8(s5)
ffffffffc02035d6:	1c979f63          	bne	a5,s1,ffffffffc02037b4 <vmm_init+0x326>
ffffffffc02035da:	010ab783          	ld	a5,16(s5)
ffffffffc02035de:	1d379b63          	bne	a5,s3,ffffffffc02037b4 <vmm_init+0x326>
ffffffffc02035e2:	0495                	addi	s1,s1,5
ffffffffc02035e4:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02035e6:	f9749be3          	bne	s1,s7,ffffffffc020357c <vmm_init+0xee>
ffffffffc02035ea:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02035ec:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02035ee:	85a6                	mv	a1,s1
ffffffffc02035f0:	8522                	mv	a0,s0
ffffffffc02035f2:	d5bff0ef          	jal	ra,ffffffffc020334c <find_vma>
ffffffffc02035f6:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02035fa:	c90d                	beqz	a0,ffffffffc020362c <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02035fc:	6914                	ld	a3,16(a0)
ffffffffc02035fe:	6510                	ld	a2,8(a0)
ffffffffc0203600:	00002517          	auipc	a0,0x2
ffffffffc0203604:	4c050513          	addi	a0,a0,1216 # ffffffffc0205ac0 <default_pmm_manager+0xcb8>
ffffffffc0203608:	ab7fc0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020360c:	00002697          	auipc	a3,0x2
ffffffffc0203610:	4dc68693          	addi	a3,a3,1244 # ffffffffc0205ae8 <default_pmm_manager+0xce0>
ffffffffc0203614:	00001617          	auipc	a2,0x1
ffffffffc0203618:	45c60613          	addi	a2,a2,1116 # ffffffffc0204a70 <commands+0x870>
ffffffffc020361c:	0f600593          	li	a1,246
ffffffffc0203620:	00002517          	auipc	a0,0x2
ffffffffc0203624:	2b050513          	addi	a0,a0,688 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203628:	d4dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020362c:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc020362e:	fd3490e3          	bne	s1,s3,ffffffffc02035ee <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc0203632:	8522                	mv	a0,s0
ffffffffc0203634:	e25ff0ef          	jal	ra,ffffffffc0203458 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203638:	8d4fe0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc020363c:	28aa1c63          	bne	s4,a0,ffffffffc02038d4 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203640:	00002517          	auipc	a0,0x2
ffffffffc0203644:	4e850513          	addi	a0,a0,1256 # ffffffffc0205b28 <default_pmm_manager+0xd20>
ffffffffc0203648:	a77fc0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020364c:	8c0fe0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc0203650:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0203652:	c81ff0ef          	jal	ra,ffffffffc02032d2 <mm_create>
ffffffffc0203656:	0000d797          	auipc	a5,0xd
ffffffffc020365a:	f2a7bd23          	sd	a0,-198(a5) # ffffffffc0210590 <check_mm_struct>
ffffffffc020365e:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc0203660:	2a050a63          	beqz	a0,ffffffffc0203914 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203664:	0000d797          	auipc	a5,0xd
ffffffffc0203668:	dec78793          	addi	a5,a5,-532 # ffffffffc0210450 <boot_pgdir>
ffffffffc020366c:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020366e:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203670:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203672:	32079d63          	bnez	a5,ffffffffc02039ac <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203676:	03000513          	li	a0,48
ffffffffc020367a:	ff1fe0ef          	jal	ra,ffffffffc020266a <kmalloc>
ffffffffc020367e:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0203680:	14050a63          	beqz	a0,ffffffffc02037d4 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc0203684:	002007b7          	lui	a5,0x200
ffffffffc0203688:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc020368c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020368e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203690:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203694:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203696:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc020369a:	cf1ff0ef          	jal	ra,ffffffffc020338a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020369e:	10000593          	li	a1,256
ffffffffc02036a2:	8522                	mv	a0,s0
ffffffffc02036a4:	ca9ff0ef          	jal	ra,ffffffffc020334c <find_vma>
ffffffffc02036a8:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02036ac:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02036b0:	2aaa1263          	bne	s4,a0,ffffffffc0203954 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc02036b4:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc02036b8:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02036ba:	fee79de3          	bne	a5,a4,ffffffffc02036b4 <vmm_init+0x226>
        sum += i;
ffffffffc02036be:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02036c0:	10000793          	li	a5,256
        sum += i;
ffffffffc02036c4:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02036c8:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02036cc:	0007c683          	lbu	a3,0(a5)
ffffffffc02036d0:	0785                	addi	a5,a5,1
ffffffffc02036d2:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02036d4:	fec79ce3          	bne	a5,a2,ffffffffc02036cc <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc02036d8:	2a071a63          	bnez	a4,ffffffffc020398c <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02036dc:	4581                	li	a1,0
ffffffffc02036de:	8526                	mv	a0,s1
ffffffffc02036e0:	ad2fe0ef          	jal	ra,ffffffffc02019b2 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02036e4:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02036e6:	0000d717          	auipc	a4,0xd
ffffffffc02036ea:	d7270713          	addi	a4,a4,-654 # ffffffffc0210458 <npage>
ffffffffc02036ee:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036f0:	078a                	slli	a5,a5,0x2
ffffffffc02036f2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036f4:	28e7f063          	bleu	a4,a5,ffffffffc0203974 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc02036f8:	00002717          	auipc	a4,0x2
ffffffffc02036fc:	77070713          	addi	a4,a4,1904 # ffffffffc0205e68 <nbase>
ffffffffc0203700:	6318                	ld	a4,0(a4)
ffffffffc0203702:	0000d697          	auipc	a3,0xd
ffffffffc0203706:	da668693          	addi	a3,a3,-602 # ffffffffc02104a8 <pages>
ffffffffc020370a:	6288                	ld	a0,0(a3)
ffffffffc020370c:	8f99                	sub	a5,a5,a4
ffffffffc020370e:	00379713          	slli	a4,a5,0x3
ffffffffc0203712:	97ba                	add	a5,a5,a4
ffffffffc0203714:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203716:	953e                	add	a0,a0,a5
ffffffffc0203718:	4585                	li	a1,1
ffffffffc020371a:	fadfd0ef          	jal	ra,ffffffffc02016c6 <free_pages>

    pgdir[0] = 0;
ffffffffc020371e:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0203722:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0203724:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0203728:	d31ff0ef          	jal	ra,ffffffffc0203458 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc020372c:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc020372e:	0000d797          	auipc	a5,0xd
ffffffffc0203732:	e607b123          	sd	zero,-414(a5) # ffffffffc0210590 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203736:	fd7fd0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc020373a:	1aa99d63          	bne	s3,a0,ffffffffc02038f4 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020373e:	00002517          	auipc	a0,0x2
ffffffffc0203742:	45250513          	addi	a0,a0,1106 # ffffffffc0205b90 <default_pmm_manager+0xd88>
ffffffffc0203746:	979fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020374a:	fc3fd0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc020374e:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203750:	1ea91263          	bne	s2,a0,ffffffffc0203934 <vmm_init+0x4a6>
}
ffffffffc0203754:	6406                	ld	s0,64(sp)
ffffffffc0203756:	60a6                	ld	ra,72(sp)
ffffffffc0203758:	74e2                	ld	s1,56(sp)
ffffffffc020375a:	7942                	ld	s2,48(sp)
ffffffffc020375c:	79a2                	ld	s3,40(sp)
ffffffffc020375e:	7a02                	ld	s4,32(sp)
ffffffffc0203760:	6ae2                	ld	s5,24(sp)
ffffffffc0203762:	6b42                	ld	s6,16(sp)
ffffffffc0203764:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203766:	00002517          	auipc	a0,0x2
ffffffffc020376a:	44a50513          	addi	a0,a0,1098 # ffffffffc0205bb0 <default_pmm_manager+0xda8>
}
ffffffffc020376e:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203770:	94ffc06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203774:	00002697          	auipc	a3,0x2
ffffffffc0203778:	26468693          	addi	a3,a3,612 # ffffffffc02059d8 <default_pmm_manager+0xbd0>
ffffffffc020377c:	00001617          	auipc	a2,0x1
ffffffffc0203780:	2f460613          	addi	a2,a2,756 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203784:	0dd00593          	li	a1,221
ffffffffc0203788:	00002517          	auipc	a0,0x2
ffffffffc020378c:	14850513          	addi	a0,a0,328 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203790:	be5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203794:	00002697          	auipc	a3,0x2
ffffffffc0203798:	2cc68693          	addi	a3,a3,716 # ffffffffc0205a60 <default_pmm_manager+0xc58>
ffffffffc020379c:	00001617          	auipc	a2,0x1
ffffffffc02037a0:	2d460613          	addi	a2,a2,724 # ffffffffc0204a70 <commands+0x870>
ffffffffc02037a4:	0ed00593          	li	a1,237
ffffffffc02037a8:	00002517          	auipc	a0,0x2
ffffffffc02037ac:	12850513          	addi	a0,a0,296 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc02037b0:	bc5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02037b4:	00002697          	auipc	a3,0x2
ffffffffc02037b8:	2dc68693          	addi	a3,a3,732 # ffffffffc0205a90 <default_pmm_manager+0xc88>
ffffffffc02037bc:	00001617          	auipc	a2,0x1
ffffffffc02037c0:	2b460613          	addi	a2,a2,692 # ffffffffc0204a70 <commands+0x870>
ffffffffc02037c4:	0ee00593          	li	a1,238
ffffffffc02037c8:	00002517          	auipc	a0,0x2
ffffffffc02037cc:	10850513          	addi	a0,a0,264 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc02037d0:	ba5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc02037d4:	00002697          	auipc	a3,0x2
ffffffffc02037d8:	d7c68693          	addi	a3,a3,-644 # ffffffffc0205550 <default_pmm_manager+0x748>
ffffffffc02037dc:	00001617          	auipc	a2,0x1
ffffffffc02037e0:	29460613          	addi	a2,a2,660 # ffffffffc0204a70 <commands+0x870>
ffffffffc02037e4:	11100593          	li	a1,273
ffffffffc02037e8:	00002517          	auipc	a0,0x2
ffffffffc02037ec:	0e850513          	addi	a0,a0,232 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc02037f0:	b85fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02037f4:	00002697          	auipc	a3,0x2
ffffffffc02037f8:	1cc68693          	addi	a3,a3,460 # ffffffffc02059c0 <default_pmm_manager+0xbb8>
ffffffffc02037fc:	00001617          	auipc	a2,0x1
ffffffffc0203800:	27460613          	addi	a2,a2,628 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203804:	0db00593          	li	a1,219
ffffffffc0203808:	00002517          	auipc	a0,0x2
ffffffffc020380c:	0c850513          	addi	a0,a0,200 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203810:	b65fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc0203814:	00002697          	auipc	a3,0x2
ffffffffc0203818:	22c68693          	addi	a3,a3,556 # ffffffffc0205a40 <default_pmm_manager+0xc38>
ffffffffc020381c:	00001617          	auipc	a2,0x1
ffffffffc0203820:	25460613          	addi	a2,a2,596 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203824:	0e900593          	li	a1,233
ffffffffc0203828:	00002517          	auipc	a0,0x2
ffffffffc020382c:	0a850513          	addi	a0,a0,168 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203830:	b45fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc0203834:	00002697          	auipc	a3,0x2
ffffffffc0203838:	1fc68693          	addi	a3,a3,508 # ffffffffc0205a30 <default_pmm_manager+0xc28>
ffffffffc020383c:	00001617          	auipc	a2,0x1
ffffffffc0203840:	23460613          	addi	a2,a2,564 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203844:	0e700593          	li	a1,231
ffffffffc0203848:	00002517          	auipc	a0,0x2
ffffffffc020384c:	08850513          	addi	a0,a0,136 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203850:	b25fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc0203854:	00002697          	auipc	a3,0x2
ffffffffc0203858:	1cc68693          	addi	a3,a3,460 # ffffffffc0205a20 <default_pmm_manager+0xc18>
ffffffffc020385c:	00001617          	auipc	a2,0x1
ffffffffc0203860:	21460613          	addi	a2,a2,532 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203864:	0e500593          	li	a1,229
ffffffffc0203868:	00002517          	auipc	a0,0x2
ffffffffc020386c:	06850513          	addi	a0,a0,104 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203870:	b05fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc0203874:	00002697          	auipc	a3,0x2
ffffffffc0203878:	19c68693          	addi	a3,a3,412 # ffffffffc0205a10 <default_pmm_manager+0xc08>
ffffffffc020387c:	00001617          	auipc	a2,0x1
ffffffffc0203880:	1f460613          	addi	a2,a2,500 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203884:	0e300593          	li	a1,227
ffffffffc0203888:	00002517          	auipc	a0,0x2
ffffffffc020388c:	04850513          	addi	a0,a0,72 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203890:	ae5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203894:	00002697          	auipc	a3,0x2
ffffffffc0203898:	1bc68693          	addi	a3,a3,444 # ffffffffc0205a50 <default_pmm_manager+0xc48>
ffffffffc020389c:	00001617          	auipc	a2,0x1
ffffffffc02038a0:	1d460613          	addi	a2,a2,468 # ffffffffc0204a70 <commands+0x870>
ffffffffc02038a4:	0eb00593          	li	a1,235
ffffffffc02038a8:	00002517          	auipc	a0,0x2
ffffffffc02038ac:	02850513          	addi	a0,a0,40 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc02038b0:	ac5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc02038b4:	00002697          	auipc	a3,0x2
ffffffffc02038b8:	c6468693          	addi	a3,a3,-924 # ffffffffc0205518 <default_pmm_manager+0x710>
ffffffffc02038bc:	00001617          	auipc	a2,0x1
ffffffffc02038c0:	1b460613          	addi	a2,a2,436 # ffffffffc0204a70 <commands+0x870>
ffffffffc02038c4:	0c700593          	li	a1,199
ffffffffc02038c8:	00002517          	auipc	a0,0x2
ffffffffc02038cc:	00850513          	addi	a0,a0,8 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc02038d0:	aa5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038d4:	00002697          	auipc	a3,0x2
ffffffffc02038d8:	22c68693          	addi	a3,a3,556 # ffffffffc0205b00 <default_pmm_manager+0xcf8>
ffffffffc02038dc:	00001617          	auipc	a2,0x1
ffffffffc02038e0:	19460613          	addi	a2,a2,404 # ffffffffc0204a70 <commands+0x870>
ffffffffc02038e4:	0fb00593          	li	a1,251
ffffffffc02038e8:	00002517          	auipc	a0,0x2
ffffffffc02038ec:	fe850513          	addi	a0,a0,-24 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc02038f0:	a85fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038f4:	00002697          	auipc	a3,0x2
ffffffffc02038f8:	20c68693          	addi	a3,a3,524 # ffffffffc0205b00 <default_pmm_manager+0xcf8>
ffffffffc02038fc:	00001617          	auipc	a2,0x1
ffffffffc0203900:	17460613          	addi	a2,a2,372 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203904:	12e00593          	li	a1,302
ffffffffc0203908:	00002517          	auipc	a0,0x2
ffffffffc020390c:	fc850513          	addi	a0,a0,-56 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203910:	a65fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203914:	00002697          	auipc	a3,0x2
ffffffffc0203918:	23468693          	addi	a3,a3,564 # ffffffffc0205b48 <default_pmm_manager+0xd40>
ffffffffc020391c:	00001617          	auipc	a2,0x1
ffffffffc0203920:	15460613          	addi	a2,a2,340 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203924:	10a00593          	li	a1,266
ffffffffc0203928:	00002517          	auipc	a0,0x2
ffffffffc020392c:	fa850513          	addi	a0,a0,-88 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203930:	a45fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203934:	00002697          	auipc	a3,0x2
ffffffffc0203938:	1cc68693          	addi	a3,a3,460 # ffffffffc0205b00 <default_pmm_manager+0xcf8>
ffffffffc020393c:	00001617          	auipc	a2,0x1
ffffffffc0203940:	13460613          	addi	a2,a2,308 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203944:	0bd00593          	li	a1,189
ffffffffc0203948:	00002517          	auipc	a0,0x2
ffffffffc020394c:	f8850513          	addi	a0,a0,-120 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203950:	a25fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203954:	00002697          	auipc	a3,0x2
ffffffffc0203958:	20c68693          	addi	a3,a3,524 # ffffffffc0205b60 <default_pmm_manager+0xd58>
ffffffffc020395c:	00001617          	auipc	a2,0x1
ffffffffc0203960:	11460613          	addi	a2,a2,276 # ffffffffc0204a70 <commands+0x870>
ffffffffc0203964:	11600593          	li	a1,278
ffffffffc0203968:	00002517          	auipc	a0,0x2
ffffffffc020396c:	f6850513          	addi	a0,a0,-152 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc0203970:	a05fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203974:	00001617          	auipc	a2,0x1
ffffffffc0203978:	55c60613          	addi	a2,a2,1372 # ffffffffc0204ed0 <default_pmm_manager+0xc8>
ffffffffc020397c:	06500593          	li	a1,101
ffffffffc0203980:	00001517          	auipc	a0,0x1
ffffffffc0203984:	57050513          	addi	a0,a0,1392 # ffffffffc0204ef0 <default_pmm_manager+0xe8>
ffffffffc0203988:	9edfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc020398c:	00002697          	auipc	a3,0x2
ffffffffc0203990:	1f468693          	addi	a3,a3,500 # ffffffffc0205b80 <default_pmm_manager+0xd78>
ffffffffc0203994:	00001617          	auipc	a2,0x1
ffffffffc0203998:	0dc60613          	addi	a2,a2,220 # ffffffffc0204a70 <commands+0x870>
ffffffffc020399c:	12000593          	li	a1,288
ffffffffc02039a0:	00002517          	auipc	a0,0x2
ffffffffc02039a4:	f3050513          	addi	a0,a0,-208 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc02039a8:	9cdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02039ac:	00002697          	auipc	a3,0x2
ffffffffc02039b0:	b9468693          	addi	a3,a3,-1132 # ffffffffc0205540 <default_pmm_manager+0x738>
ffffffffc02039b4:	00001617          	auipc	a2,0x1
ffffffffc02039b8:	0bc60613          	addi	a2,a2,188 # ffffffffc0204a70 <commands+0x870>
ffffffffc02039bc:	10d00593          	li	a1,269
ffffffffc02039c0:	00002517          	auipc	a0,0x2
ffffffffc02039c4:	f1050513          	addi	a0,a0,-240 # ffffffffc02058d0 <default_pmm_manager+0xac8>
ffffffffc02039c8:	9adfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02039cc <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02039cc:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02039ce:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02039d0:	e822                	sd	s0,16(sp)
ffffffffc02039d2:	e426                	sd	s1,8(sp)
ffffffffc02039d4:	ec06                	sd	ra,24(sp)
ffffffffc02039d6:	e04a                	sd	s2,0(sp)
ffffffffc02039d8:	8432                	mv	s0,a2
ffffffffc02039da:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02039dc:	971ff0ef          	jal	ra,ffffffffc020334c <find_vma>

    pgfault_num++;
ffffffffc02039e0:	0000d797          	auipc	a5,0xd
ffffffffc02039e4:	a8c78793          	addi	a5,a5,-1396 # ffffffffc021046c <pgfault_num>
ffffffffc02039e8:	439c                	lw	a5,0(a5)
ffffffffc02039ea:	2785                	addiw	a5,a5,1
ffffffffc02039ec:	0000d717          	auipc	a4,0xd
ffffffffc02039f0:	a8f72023          	sw	a5,-1408(a4) # ffffffffc021046c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02039f4:	c939                	beqz	a0,ffffffffc0203a4a <do_pgfault+0x7e>
ffffffffc02039f6:	651c                	ld	a5,8(a0)
ffffffffc02039f8:	04f46963          	bltu	s0,a5,ffffffffc0203a4a <do_pgfault+0x7e>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02039fc:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02039fe:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203a00:	8b89                	andi	a5,a5,2
ffffffffc0203a02:	e785                	bnez	a5,ffffffffc0203a2a <do_pgfault+0x5e>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203a04:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203a06:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203a08:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203a0a:	85a2                	mv	a1,s0
ffffffffc0203a0c:	4605                	li	a2,1
ffffffffc0203a0e:	d3ffd0ef          	jal	ra,ffffffffc020174c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203a12:	610c                	ld	a1,0(a0)
ffffffffc0203a14:	cd89                	beqz	a1,ffffffffc0203a2e <do_pgfault+0x62>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203a16:	0000d797          	auipc	a5,0xd
ffffffffc0203a1a:	a5278793          	addi	a5,a5,-1454 # ffffffffc0210468 <swap_init_ok>
ffffffffc0203a1e:	439c                	lw	a5,0(a5)
ffffffffc0203a20:	2781                	sext.w	a5,a5
ffffffffc0203a22:	cf8d                	beqz	a5,ffffffffc0203a5c <do_pgfault+0x90>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc0203a24:	04003023          	sd	zero,64(zero) # 40 <BASE_ADDRESS-0xffffffffc01fffc0>
ffffffffc0203a28:	9002                	ebreak
        perm |= (PTE_R | PTE_W);
ffffffffc0203a2a:	4959                	li	s2,22
ffffffffc0203a2c:	bfe1                	j	ffffffffc0203a04 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203a2e:	6c88                	ld	a0,24(s1)
ffffffffc0203a30:	864a                	mv	a2,s2
ffffffffc0203a32:	85a2                	mv	a1,s0
ffffffffc0203a34:	ba5fe0ef          	jal	ra,ffffffffc02025d8 <pgdir_alloc_page>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203a38:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203a3a:	c90d                	beqz	a0,ffffffffc0203a6c <do_pgfault+0xa0>
failed:
    return ret;
}
ffffffffc0203a3c:	60e2                	ld	ra,24(sp)
ffffffffc0203a3e:	6442                	ld	s0,16(sp)
ffffffffc0203a40:	64a2                	ld	s1,8(sp)
ffffffffc0203a42:	6902                	ld	s2,0(sp)
ffffffffc0203a44:	853e                	mv	a0,a5
ffffffffc0203a46:	6105                	addi	sp,sp,32
ffffffffc0203a48:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203a4a:	85a2                	mv	a1,s0
ffffffffc0203a4c:	00002517          	auipc	a0,0x2
ffffffffc0203a50:	e9450513          	addi	a0,a0,-364 # ffffffffc02058e0 <default_pmm_manager+0xad8>
ffffffffc0203a54:	e6afc0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0203a58:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203a5a:	b7cd                	j	ffffffffc0203a3c <do_pgfault+0x70>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203a5c:	00002517          	auipc	a0,0x2
ffffffffc0203a60:	edc50513          	addi	a0,a0,-292 # ffffffffc0205938 <default_pmm_manager+0xb30>
ffffffffc0203a64:	e5afc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203a68:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203a6a:	bfc9                	j	ffffffffc0203a3c <do_pgfault+0x70>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203a6c:	00002517          	auipc	a0,0x2
ffffffffc0203a70:	ea450513          	addi	a0,a0,-348 # ffffffffc0205910 <default_pmm_manager+0xb08>
ffffffffc0203a74:	e4afc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203a78:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203a7a:	b7c9                	j	ffffffffc0203a3c <do_pgfault+0x70>

ffffffffc0203a7c <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203a7c:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203a7e:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203a80:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203a82:	a1dfc0ef          	jal	ra,ffffffffc020049e <ide_device_valid>
ffffffffc0203a86:	cd01                	beqz	a0,ffffffffc0203a9e <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203a88:	4505                	li	a0,1
ffffffffc0203a8a:	a1bfc0ef          	jal	ra,ffffffffc02004a4 <ide_device_size>
}
ffffffffc0203a8e:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203a90:	810d                	srli	a0,a0,0x3
ffffffffc0203a92:	0000d797          	auipc	a5,0xd
ffffffffc0203a96:	aaa7b323          	sd	a0,-1370(a5) # ffffffffc0210538 <max_swap_offset>
}
ffffffffc0203a9a:	0141                	addi	sp,sp,16
ffffffffc0203a9c:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203a9e:	00002617          	auipc	a2,0x2
ffffffffc0203aa2:	12a60613          	addi	a2,a2,298 # ffffffffc0205bc8 <default_pmm_manager+0xdc0>
ffffffffc0203aa6:	45b5                	li	a1,13
ffffffffc0203aa8:	00002517          	auipc	a0,0x2
ffffffffc0203aac:	14050513          	addi	a0,a0,320 # ffffffffc0205be8 <default_pmm_manager+0xde0>
ffffffffc0203ab0:	8c5fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203ab4 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203ab4:	1141                	addi	sp,sp,-16
ffffffffc0203ab6:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ab8:	00855793          	srli	a5,a0,0x8
ffffffffc0203abc:	c7b5                	beqz	a5,ffffffffc0203b28 <swapfs_write+0x74>
ffffffffc0203abe:	0000d717          	auipc	a4,0xd
ffffffffc0203ac2:	a7a70713          	addi	a4,a4,-1414 # ffffffffc0210538 <max_swap_offset>
ffffffffc0203ac6:	6318                	ld	a4,0(a4)
ffffffffc0203ac8:	06e7f063          	bleu	a4,a5,ffffffffc0203b28 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203acc:	0000d717          	auipc	a4,0xd
ffffffffc0203ad0:	9dc70713          	addi	a4,a4,-1572 # ffffffffc02104a8 <pages>
ffffffffc0203ad4:	6310                	ld	a2,0(a4)
ffffffffc0203ad6:	00001717          	auipc	a4,0x1
ffffffffc0203ada:	f8270713          	addi	a4,a4,-126 # ffffffffc0204a58 <commands+0x858>
ffffffffc0203ade:	00002697          	auipc	a3,0x2
ffffffffc0203ae2:	38a68693          	addi	a3,a3,906 # ffffffffc0205e68 <nbase>
ffffffffc0203ae6:	40c58633          	sub	a2,a1,a2
ffffffffc0203aea:	630c                	ld	a1,0(a4)
ffffffffc0203aec:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203aee:	0000d717          	auipc	a4,0xd
ffffffffc0203af2:	96a70713          	addi	a4,a4,-1686 # ffffffffc0210458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203af6:	02b60633          	mul	a2,a2,a1
ffffffffc0203afa:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203afe:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b00:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203b02:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b04:	57fd                	li	a5,-1
ffffffffc0203b06:	83b1                	srli	a5,a5,0xc
ffffffffc0203b08:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b0a:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b0c:	02e7fa63          	bleu	a4,a5,ffffffffc0203b40 <swapfs_write+0x8c>
ffffffffc0203b10:	0000d797          	auipc	a5,0xd
ffffffffc0203b14:	98878793          	addi	a5,a5,-1656 # ffffffffc0210498 <va_pa_offset>
ffffffffc0203b18:	639c                	ld	a5,0(a5)
}
ffffffffc0203b1a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b1c:	46a1                	li	a3,8
ffffffffc0203b1e:	963e                	add	a2,a2,a5
ffffffffc0203b20:	4505                	li	a0,1
}
ffffffffc0203b22:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b24:	987fc06f          	j	ffffffffc02004aa <ide_write_secs>
ffffffffc0203b28:	86aa                	mv	a3,a0
ffffffffc0203b2a:	00002617          	auipc	a2,0x2
ffffffffc0203b2e:	0d660613          	addi	a2,a2,214 # ffffffffc0205c00 <default_pmm_manager+0xdf8>
ffffffffc0203b32:	45e5                	li	a1,25
ffffffffc0203b34:	00002517          	auipc	a0,0x2
ffffffffc0203b38:	0b450513          	addi	a0,a0,180 # ffffffffc0205be8 <default_pmm_manager+0xde0>
ffffffffc0203b3c:	839fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203b40:	86b2                	mv	a3,a2
ffffffffc0203b42:	06a00593          	li	a1,106
ffffffffc0203b46:	00001617          	auipc	a2,0x1
ffffffffc0203b4a:	31260613          	addi	a2,a2,786 # ffffffffc0204e58 <default_pmm_manager+0x50>
ffffffffc0203b4e:	00001517          	auipc	a0,0x1
ffffffffc0203b52:	3a250513          	addi	a0,a0,930 # ffffffffc0204ef0 <default_pmm_manager+0xe8>
ffffffffc0203b56:	81ffc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203b5a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203b5a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b5e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203b60:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b64:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203b66:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b6a:	f022                	sd	s0,32(sp)
ffffffffc0203b6c:	ec26                	sd	s1,24(sp)
ffffffffc0203b6e:	e84a                	sd	s2,16(sp)
ffffffffc0203b70:	f406                	sd	ra,40(sp)
ffffffffc0203b72:	e44e                	sd	s3,8(sp)
ffffffffc0203b74:	84aa                	mv	s1,a0
ffffffffc0203b76:	892e                	mv	s2,a1
ffffffffc0203b78:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203b7c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203b7e:	03067e63          	bleu	a6,a2,ffffffffc0203bba <printnum+0x60>
ffffffffc0203b82:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203b84:	00805763          	blez	s0,ffffffffc0203b92 <printnum+0x38>
ffffffffc0203b88:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203b8a:	85ca                	mv	a1,s2
ffffffffc0203b8c:	854e                	mv	a0,s3
ffffffffc0203b8e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203b90:	fc65                	bnez	s0,ffffffffc0203b88 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b92:	1a02                	slli	s4,s4,0x20
ffffffffc0203b94:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203b98:	00002797          	auipc	a5,0x2
ffffffffc0203b9c:	21878793          	addi	a5,a5,536 # ffffffffc0205db0 <error_string+0x38>
ffffffffc0203ba0:	9a3e                	add	s4,s4,a5
}
ffffffffc0203ba2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203ba4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203ba8:	70a2                	ld	ra,40(sp)
ffffffffc0203baa:	69a2                	ld	s3,8(sp)
ffffffffc0203bac:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203bae:	85ca                	mv	a1,s2
ffffffffc0203bb0:	8326                	mv	t1,s1
}
ffffffffc0203bb2:	6942                	ld	s2,16(sp)
ffffffffc0203bb4:	64e2                	ld	s1,24(sp)
ffffffffc0203bb6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203bb8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203bba:	03065633          	divu	a2,a2,a6
ffffffffc0203bbe:	8722                	mv	a4,s0
ffffffffc0203bc0:	f9bff0ef          	jal	ra,ffffffffc0203b5a <printnum>
ffffffffc0203bc4:	b7f9                	j	ffffffffc0203b92 <printnum+0x38>

ffffffffc0203bc6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203bc6:	7119                	addi	sp,sp,-128
ffffffffc0203bc8:	f4a6                	sd	s1,104(sp)
ffffffffc0203bca:	f0ca                	sd	s2,96(sp)
ffffffffc0203bcc:	e8d2                	sd	s4,80(sp)
ffffffffc0203bce:	e4d6                	sd	s5,72(sp)
ffffffffc0203bd0:	e0da                	sd	s6,64(sp)
ffffffffc0203bd2:	fc5e                	sd	s7,56(sp)
ffffffffc0203bd4:	f862                	sd	s8,48(sp)
ffffffffc0203bd6:	f06a                	sd	s10,32(sp)
ffffffffc0203bd8:	fc86                	sd	ra,120(sp)
ffffffffc0203bda:	f8a2                	sd	s0,112(sp)
ffffffffc0203bdc:	ecce                	sd	s3,88(sp)
ffffffffc0203bde:	f466                	sd	s9,40(sp)
ffffffffc0203be0:	ec6e                	sd	s11,24(sp)
ffffffffc0203be2:	892a                	mv	s2,a0
ffffffffc0203be4:	84ae                	mv	s1,a1
ffffffffc0203be6:	8d32                	mv	s10,a2
ffffffffc0203be8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203bea:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203bec:	00002a17          	auipc	s4,0x2
ffffffffc0203bf0:	034a0a13          	addi	s4,s4,52 # ffffffffc0205c20 <default_pmm_manager+0xe18>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203bf4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203bf8:	00002c17          	auipc	s8,0x2
ffffffffc0203bfc:	180c0c13          	addi	s8,s8,384 # ffffffffc0205d78 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203c00:	000d4503          	lbu	a0,0(s10)
ffffffffc0203c04:	02500793          	li	a5,37
ffffffffc0203c08:	001d0413          	addi	s0,s10,1
ffffffffc0203c0c:	00f50e63          	beq	a0,a5,ffffffffc0203c28 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203c10:	c521                	beqz	a0,ffffffffc0203c58 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203c12:	02500993          	li	s3,37
ffffffffc0203c16:	a011                	j	ffffffffc0203c1a <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203c18:	c121                	beqz	a0,ffffffffc0203c58 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203c1a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203c1c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203c1e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203c20:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203c24:	ff351ae3          	bne	a0,s3,ffffffffc0203c18 <vprintfmt+0x52>
ffffffffc0203c28:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203c2c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203c30:	4981                	li	s3,0
ffffffffc0203c32:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203c34:	5cfd                	li	s9,-1
ffffffffc0203c36:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c38:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203c3c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c3e:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203c42:	0ff6f693          	andi	a3,a3,255
ffffffffc0203c46:	00140d13          	addi	s10,s0,1
ffffffffc0203c4a:	20d5e563          	bltu	a1,a3,ffffffffc0203e54 <vprintfmt+0x28e>
ffffffffc0203c4e:	068a                	slli	a3,a3,0x2
ffffffffc0203c50:	96d2                	add	a3,a3,s4
ffffffffc0203c52:	4294                	lw	a3,0(a3)
ffffffffc0203c54:	96d2                	add	a3,a3,s4
ffffffffc0203c56:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203c58:	70e6                	ld	ra,120(sp)
ffffffffc0203c5a:	7446                	ld	s0,112(sp)
ffffffffc0203c5c:	74a6                	ld	s1,104(sp)
ffffffffc0203c5e:	7906                	ld	s2,96(sp)
ffffffffc0203c60:	69e6                	ld	s3,88(sp)
ffffffffc0203c62:	6a46                	ld	s4,80(sp)
ffffffffc0203c64:	6aa6                	ld	s5,72(sp)
ffffffffc0203c66:	6b06                	ld	s6,64(sp)
ffffffffc0203c68:	7be2                	ld	s7,56(sp)
ffffffffc0203c6a:	7c42                	ld	s8,48(sp)
ffffffffc0203c6c:	7ca2                	ld	s9,40(sp)
ffffffffc0203c6e:	7d02                	ld	s10,32(sp)
ffffffffc0203c70:	6de2                	ld	s11,24(sp)
ffffffffc0203c72:	6109                	addi	sp,sp,128
ffffffffc0203c74:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203c76:	4705                	li	a4,1
ffffffffc0203c78:	008a8593          	addi	a1,s5,8
ffffffffc0203c7c:	01074463          	blt	a4,a6,ffffffffc0203c84 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203c80:	26080363          	beqz	a6,ffffffffc0203ee6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203c84:	000ab603          	ld	a2,0(s5)
ffffffffc0203c88:	46c1                	li	a3,16
ffffffffc0203c8a:	8aae                	mv	s5,a1
ffffffffc0203c8c:	a06d                	j	ffffffffc0203d36 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203c8e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203c92:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c94:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203c96:	b765                	j	ffffffffc0203c3e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203c98:	000aa503          	lw	a0,0(s5)
ffffffffc0203c9c:	85a6                	mv	a1,s1
ffffffffc0203c9e:	0aa1                	addi	s5,s5,8
ffffffffc0203ca0:	9902                	jalr	s2
            break;
ffffffffc0203ca2:	bfb9                	j	ffffffffc0203c00 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203ca4:	4705                	li	a4,1
ffffffffc0203ca6:	008a8993          	addi	s3,s5,8
ffffffffc0203caa:	01074463          	blt	a4,a6,ffffffffc0203cb2 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203cae:	22080463          	beqz	a6,ffffffffc0203ed6 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203cb2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203cb6:	24044463          	bltz	s0,ffffffffc0203efe <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203cba:	8622                	mv	a2,s0
ffffffffc0203cbc:	8ace                	mv	s5,s3
ffffffffc0203cbe:	46a9                	li	a3,10
ffffffffc0203cc0:	a89d                	j	ffffffffc0203d36 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203cc2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203cc6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203cc8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203cca:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203cce:	8fb5                	xor	a5,a5,a3
ffffffffc0203cd0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203cd4:	1ad74363          	blt	a4,a3,ffffffffc0203e7a <vprintfmt+0x2b4>
ffffffffc0203cd8:	00369793          	slli	a5,a3,0x3
ffffffffc0203cdc:	97e2                	add	a5,a5,s8
ffffffffc0203cde:	639c                	ld	a5,0(a5)
ffffffffc0203ce0:	18078d63          	beqz	a5,ffffffffc0203e7a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203ce4:	86be                	mv	a3,a5
ffffffffc0203ce6:	00002617          	auipc	a2,0x2
ffffffffc0203cea:	17a60613          	addi	a2,a2,378 # ffffffffc0205e60 <error_string+0xe8>
ffffffffc0203cee:	85a6                	mv	a1,s1
ffffffffc0203cf0:	854a                	mv	a0,s2
ffffffffc0203cf2:	240000ef          	jal	ra,ffffffffc0203f32 <printfmt>
ffffffffc0203cf6:	b729                	j	ffffffffc0203c00 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203cf8:	00144603          	lbu	a2,1(s0)
ffffffffc0203cfc:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cfe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203d00:	bf3d                	j	ffffffffc0203c3e <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203d02:	4705                	li	a4,1
ffffffffc0203d04:	008a8593          	addi	a1,s5,8
ffffffffc0203d08:	01074463          	blt	a4,a6,ffffffffc0203d10 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203d0c:	1e080263          	beqz	a6,ffffffffc0203ef0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203d10:	000ab603          	ld	a2,0(s5)
ffffffffc0203d14:	46a1                	li	a3,8
ffffffffc0203d16:	8aae                	mv	s5,a1
ffffffffc0203d18:	a839                	j	ffffffffc0203d36 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0203d1a:	03000513          	li	a0,48
ffffffffc0203d1e:	85a6                	mv	a1,s1
ffffffffc0203d20:	e03e                	sd	a5,0(sp)
ffffffffc0203d22:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203d24:	85a6                	mv	a1,s1
ffffffffc0203d26:	07800513          	li	a0,120
ffffffffc0203d2a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203d2c:	0aa1                	addi	s5,s5,8
ffffffffc0203d2e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203d32:	6782                	ld	a5,0(sp)
ffffffffc0203d34:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203d36:	876e                	mv	a4,s11
ffffffffc0203d38:	85a6                	mv	a1,s1
ffffffffc0203d3a:	854a                	mv	a0,s2
ffffffffc0203d3c:	e1fff0ef          	jal	ra,ffffffffc0203b5a <printnum>
            break;
ffffffffc0203d40:	b5c1                	j	ffffffffc0203c00 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203d42:	000ab603          	ld	a2,0(s5)
ffffffffc0203d46:	0aa1                	addi	s5,s5,8
ffffffffc0203d48:	1c060663          	beqz	a2,ffffffffc0203f14 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0203d4c:	00160413          	addi	s0,a2,1
ffffffffc0203d50:	17b05c63          	blez	s11,ffffffffc0203ec8 <vprintfmt+0x302>
ffffffffc0203d54:	02d00593          	li	a1,45
ffffffffc0203d58:	14b79263          	bne	a5,a1,ffffffffc0203e9c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d5c:	00064783          	lbu	a5,0(a2)
ffffffffc0203d60:	0007851b          	sext.w	a0,a5
ffffffffc0203d64:	c905                	beqz	a0,ffffffffc0203d94 <vprintfmt+0x1ce>
ffffffffc0203d66:	000cc563          	bltz	s9,ffffffffc0203d70 <vprintfmt+0x1aa>
ffffffffc0203d6a:	3cfd                	addiw	s9,s9,-1
ffffffffc0203d6c:	036c8263          	beq	s9,s6,ffffffffc0203d90 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0203d70:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203d72:	18098463          	beqz	s3,ffffffffc0203efa <vprintfmt+0x334>
ffffffffc0203d76:	3781                	addiw	a5,a5,-32
ffffffffc0203d78:	18fbf163          	bleu	a5,s7,ffffffffc0203efa <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0203d7c:	03f00513          	li	a0,63
ffffffffc0203d80:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d82:	0405                	addi	s0,s0,1
ffffffffc0203d84:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203d88:	3dfd                	addiw	s11,s11,-1
ffffffffc0203d8a:	0007851b          	sext.w	a0,a5
ffffffffc0203d8e:	fd61                	bnez	a0,ffffffffc0203d66 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0203d90:	e7b058e3          	blez	s11,ffffffffc0203c00 <vprintfmt+0x3a>
ffffffffc0203d94:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203d96:	85a6                	mv	a1,s1
ffffffffc0203d98:	02000513          	li	a0,32
ffffffffc0203d9c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203d9e:	e60d81e3          	beqz	s11,ffffffffc0203c00 <vprintfmt+0x3a>
ffffffffc0203da2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203da4:	85a6                	mv	a1,s1
ffffffffc0203da6:	02000513          	li	a0,32
ffffffffc0203daa:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203dac:	fe0d94e3          	bnez	s11,ffffffffc0203d94 <vprintfmt+0x1ce>
ffffffffc0203db0:	bd81                	j	ffffffffc0203c00 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203db2:	4705                	li	a4,1
ffffffffc0203db4:	008a8593          	addi	a1,s5,8
ffffffffc0203db8:	01074463          	blt	a4,a6,ffffffffc0203dc0 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0203dbc:	12080063          	beqz	a6,ffffffffc0203edc <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0203dc0:	000ab603          	ld	a2,0(s5)
ffffffffc0203dc4:	46a9                	li	a3,10
ffffffffc0203dc6:	8aae                	mv	s5,a1
ffffffffc0203dc8:	b7bd                	j	ffffffffc0203d36 <vprintfmt+0x170>
ffffffffc0203dca:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0203dce:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203dd2:	846a                	mv	s0,s10
ffffffffc0203dd4:	b5ad                	j	ffffffffc0203c3e <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0203dd6:	85a6                	mv	a1,s1
ffffffffc0203dd8:	02500513          	li	a0,37
ffffffffc0203ddc:	9902                	jalr	s2
            break;
ffffffffc0203dde:	b50d                	j	ffffffffc0203c00 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0203de0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0203de4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203de8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203dea:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0203dec:	e40dd9e3          	bgez	s11,ffffffffc0203c3e <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0203df0:	8de6                	mv	s11,s9
ffffffffc0203df2:	5cfd                	li	s9,-1
ffffffffc0203df4:	b5a9                	j	ffffffffc0203c3e <vprintfmt+0x78>
            goto reswitch;
ffffffffc0203df6:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0203dfa:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203dfe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203e00:	bd3d                	j	ffffffffc0203c3e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0203e02:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0203e06:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e0a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203e0c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203e10:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203e14:	fcd56ce3          	bltu	a0,a3,ffffffffc0203dec <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0203e18:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203e1a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0203e1e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203e22:	0196873b          	addw	a4,a3,s9
ffffffffc0203e26:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203e2a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0203e2e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0203e32:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0203e36:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203e3a:	fcd57fe3          	bleu	a3,a0,ffffffffc0203e18 <vprintfmt+0x252>
ffffffffc0203e3e:	b77d                	j	ffffffffc0203dec <vprintfmt+0x226>
            if (width < 0)
ffffffffc0203e40:	fffdc693          	not	a3,s11
ffffffffc0203e44:	96fd                	srai	a3,a3,0x3f
ffffffffc0203e46:	00ddfdb3          	and	s11,s11,a3
ffffffffc0203e4a:	00144603          	lbu	a2,1(s0)
ffffffffc0203e4e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e50:	846a                	mv	s0,s10
ffffffffc0203e52:	b3f5                	j	ffffffffc0203c3e <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0203e54:	85a6                	mv	a1,s1
ffffffffc0203e56:	02500513          	li	a0,37
ffffffffc0203e5a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203e5c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0203e60:	02500793          	li	a5,37
ffffffffc0203e64:	8d22                	mv	s10,s0
ffffffffc0203e66:	d8f70de3          	beq	a4,a5,ffffffffc0203c00 <vprintfmt+0x3a>
ffffffffc0203e6a:	02500713          	li	a4,37
ffffffffc0203e6e:	1d7d                	addi	s10,s10,-1
ffffffffc0203e70:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0203e74:	fee79de3          	bne	a5,a4,ffffffffc0203e6e <vprintfmt+0x2a8>
ffffffffc0203e78:	b361                	j	ffffffffc0203c00 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203e7a:	00002617          	auipc	a2,0x2
ffffffffc0203e7e:	fd660613          	addi	a2,a2,-42 # ffffffffc0205e50 <error_string+0xd8>
ffffffffc0203e82:	85a6                	mv	a1,s1
ffffffffc0203e84:	854a                	mv	a0,s2
ffffffffc0203e86:	0ac000ef          	jal	ra,ffffffffc0203f32 <printfmt>
ffffffffc0203e8a:	bb9d                	j	ffffffffc0203c00 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0203e8c:	00002617          	auipc	a2,0x2
ffffffffc0203e90:	fbc60613          	addi	a2,a2,-68 # ffffffffc0205e48 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0203e94:	00002417          	auipc	s0,0x2
ffffffffc0203e98:	fb540413          	addi	s0,s0,-75 # ffffffffc0205e49 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e9c:	8532                	mv	a0,a2
ffffffffc0203e9e:	85e6                	mv	a1,s9
ffffffffc0203ea0:	e032                	sd	a2,0(sp)
ffffffffc0203ea2:	e43e                	sd	a5,8(sp)
ffffffffc0203ea4:	18a000ef          	jal	ra,ffffffffc020402e <strnlen>
ffffffffc0203ea8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0203eac:	6602                	ld	a2,0(sp)
ffffffffc0203eae:	01b05d63          	blez	s11,ffffffffc0203ec8 <vprintfmt+0x302>
ffffffffc0203eb2:	67a2                	ld	a5,8(sp)
ffffffffc0203eb4:	2781                	sext.w	a5,a5
ffffffffc0203eb6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0203eb8:	6522                	ld	a0,8(sp)
ffffffffc0203eba:	85a6                	mv	a1,s1
ffffffffc0203ebc:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203ebe:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0203ec0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203ec2:	6602                	ld	a2,0(sp)
ffffffffc0203ec4:	fe0d9ae3          	bnez	s11,ffffffffc0203eb8 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203ec8:	00064783          	lbu	a5,0(a2)
ffffffffc0203ecc:	0007851b          	sext.w	a0,a5
ffffffffc0203ed0:	e8051be3          	bnez	a0,ffffffffc0203d66 <vprintfmt+0x1a0>
ffffffffc0203ed4:	b335                	j	ffffffffc0203c00 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0203ed6:	000aa403          	lw	s0,0(s5)
ffffffffc0203eda:	bbf1                	j	ffffffffc0203cb6 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0203edc:	000ae603          	lwu	a2,0(s5)
ffffffffc0203ee0:	46a9                	li	a3,10
ffffffffc0203ee2:	8aae                	mv	s5,a1
ffffffffc0203ee4:	bd89                	j	ffffffffc0203d36 <vprintfmt+0x170>
ffffffffc0203ee6:	000ae603          	lwu	a2,0(s5)
ffffffffc0203eea:	46c1                	li	a3,16
ffffffffc0203eec:	8aae                	mv	s5,a1
ffffffffc0203eee:	b5a1                	j	ffffffffc0203d36 <vprintfmt+0x170>
ffffffffc0203ef0:	000ae603          	lwu	a2,0(s5)
ffffffffc0203ef4:	46a1                	li	a3,8
ffffffffc0203ef6:	8aae                	mv	s5,a1
ffffffffc0203ef8:	bd3d                	j	ffffffffc0203d36 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0203efa:	9902                	jalr	s2
ffffffffc0203efc:	b559                	j	ffffffffc0203d82 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0203efe:	85a6                	mv	a1,s1
ffffffffc0203f00:	02d00513          	li	a0,45
ffffffffc0203f04:	e03e                	sd	a5,0(sp)
ffffffffc0203f06:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0203f08:	8ace                	mv	s5,s3
ffffffffc0203f0a:	40800633          	neg	a2,s0
ffffffffc0203f0e:	46a9                	li	a3,10
ffffffffc0203f10:	6782                	ld	a5,0(sp)
ffffffffc0203f12:	b515                	j	ffffffffc0203d36 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0203f14:	01b05663          	blez	s11,ffffffffc0203f20 <vprintfmt+0x35a>
ffffffffc0203f18:	02d00693          	li	a3,45
ffffffffc0203f1c:	f6d798e3          	bne	a5,a3,ffffffffc0203e8c <vprintfmt+0x2c6>
ffffffffc0203f20:	00002417          	auipc	s0,0x2
ffffffffc0203f24:	f2940413          	addi	s0,s0,-215 # ffffffffc0205e49 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203f28:	02800513          	li	a0,40
ffffffffc0203f2c:	02800793          	li	a5,40
ffffffffc0203f30:	bd1d                	j	ffffffffc0203d66 <vprintfmt+0x1a0>

ffffffffc0203f32 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203f32:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0203f34:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203f38:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203f3a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203f3c:	ec06                	sd	ra,24(sp)
ffffffffc0203f3e:	f83a                	sd	a4,48(sp)
ffffffffc0203f40:	fc3e                	sd	a5,56(sp)
ffffffffc0203f42:	e0c2                	sd	a6,64(sp)
ffffffffc0203f44:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0203f46:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203f48:	c7fff0ef          	jal	ra,ffffffffc0203bc6 <vprintfmt>
}
ffffffffc0203f4c:	60e2                	ld	ra,24(sp)
ffffffffc0203f4e:	6161                	addi	sp,sp,80
ffffffffc0203f50:	8082                	ret

ffffffffc0203f52 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0203f52:	715d                	addi	sp,sp,-80
ffffffffc0203f54:	e486                	sd	ra,72(sp)
ffffffffc0203f56:	e0a2                	sd	s0,64(sp)
ffffffffc0203f58:	fc26                	sd	s1,56(sp)
ffffffffc0203f5a:	f84a                	sd	s2,48(sp)
ffffffffc0203f5c:	f44e                	sd	s3,40(sp)
ffffffffc0203f5e:	f052                	sd	s4,32(sp)
ffffffffc0203f60:	ec56                	sd	s5,24(sp)
ffffffffc0203f62:	e85a                	sd	s6,16(sp)
ffffffffc0203f64:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0203f66:	c901                	beqz	a0,ffffffffc0203f76 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0203f68:	85aa                	mv	a1,a0
ffffffffc0203f6a:	00002517          	auipc	a0,0x2
ffffffffc0203f6e:	ef650513          	addi	a0,a0,-266 # ffffffffc0205e60 <error_string+0xe8>
ffffffffc0203f72:	94cfc0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc0203f76:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203f78:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0203f7a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0203f7c:	4aa9                	li	s5,10
ffffffffc0203f7e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0203f80:	0000cb97          	auipc	s7,0xc
ffffffffc0203f84:	0c0b8b93          	addi	s7,s7,192 # ffffffffc0210040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203f88:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0203f8c:	96afc0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0203f90:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0203f92:	00054b63          	bltz	a0,ffffffffc0203fa8 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203f96:	00a95b63          	ble	a0,s2,ffffffffc0203fac <readline+0x5a>
ffffffffc0203f9a:	029a5463          	ble	s1,s4,ffffffffc0203fc2 <readline+0x70>
        c = getchar();
ffffffffc0203f9e:	958fc0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0203fa2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0203fa4:	fe0559e3          	bgez	a0,ffffffffc0203f96 <readline+0x44>
            return NULL;
ffffffffc0203fa8:	4501                	li	a0,0
ffffffffc0203faa:	a099                	j	ffffffffc0203ff0 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0203fac:	03341463          	bne	s0,s3,ffffffffc0203fd4 <readline+0x82>
ffffffffc0203fb0:	e8b9                	bnez	s1,ffffffffc0204006 <readline+0xb4>
        c = getchar();
ffffffffc0203fb2:	944fc0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0203fb6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0203fb8:	fe0548e3          	bltz	a0,ffffffffc0203fa8 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203fbc:	fea958e3          	ble	a0,s2,ffffffffc0203fac <readline+0x5a>
ffffffffc0203fc0:	4481                	li	s1,0
            cputchar(c);
ffffffffc0203fc2:	8522                	mv	a0,s0
ffffffffc0203fc4:	92efc0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc0203fc8:	009b87b3          	add	a5,s7,s1
ffffffffc0203fcc:	00878023          	sb	s0,0(a5)
ffffffffc0203fd0:	2485                	addiw	s1,s1,1
ffffffffc0203fd2:	bf6d                	j	ffffffffc0203f8c <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0203fd4:	01540463          	beq	s0,s5,ffffffffc0203fdc <readline+0x8a>
ffffffffc0203fd8:	fb641ae3          	bne	s0,s6,ffffffffc0203f8c <readline+0x3a>
            cputchar(c);
ffffffffc0203fdc:	8522                	mv	a0,s0
ffffffffc0203fde:	914fc0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0203fe2:	0000c517          	auipc	a0,0xc
ffffffffc0203fe6:	05e50513          	addi	a0,a0,94 # ffffffffc0210040 <buf>
ffffffffc0203fea:	94aa                	add	s1,s1,a0
ffffffffc0203fec:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0203ff0:	60a6                	ld	ra,72(sp)
ffffffffc0203ff2:	6406                	ld	s0,64(sp)
ffffffffc0203ff4:	74e2                	ld	s1,56(sp)
ffffffffc0203ff6:	7942                	ld	s2,48(sp)
ffffffffc0203ff8:	79a2                	ld	s3,40(sp)
ffffffffc0203ffa:	7a02                	ld	s4,32(sp)
ffffffffc0203ffc:	6ae2                	ld	s5,24(sp)
ffffffffc0203ffe:	6b42                	ld	s6,16(sp)
ffffffffc0204000:	6ba2                	ld	s7,8(sp)
ffffffffc0204002:	6161                	addi	sp,sp,80
ffffffffc0204004:	8082                	ret
            cputchar(c);
ffffffffc0204006:	4521                	li	a0,8
ffffffffc0204008:	8eafc0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc020400c:	34fd                	addiw	s1,s1,-1
ffffffffc020400e:	bfbd                	j	ffffffffc0203f8c <readline+0x3a>

ffffffffc0204010 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204010:	00054783          	lbu	a5,0(a0)
ffffffffc0204014:	cb91                	beqz	a5,ffffffffc0204028 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204016:	4781                	li	a5,0
        cnt ++;
ffffffffc0204018:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020401a:	00f50733          	add	a4,a0,a5
ffffffffc020401e:	00074703          	lbu	a4,0(a4)
ffffffffc0204022:	fb7d                	bnez	a4,ffffffffc0204018 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204024:	853e                	mv	a0,a5
ffffffffc0204026:	8082                	ret
    size_t cnt = 0;
ffffffffc0204028:	4781                	li	a5,0
}
ffffffffc020402a:	853e                	mv	a0,a5
ffffffffc020402c:	8082                	ret

ffffffffc020402e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020402e:	c185                	beqz	a1,ffffffffc020404e <strnlen+0x20>
ffffffffc0204030:	00054783          	lbu	a5,0(a0)
ffffffffc0204034:	cf89                	beqz	a5,ffffffffc020404e <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204036:	4781                	li	a5,0
ffffffffc0204038:	a021                	j	ffffffffc0204040 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020403a:	00074703          	lbu	a4,0(a4)
ffffffffc020403e:	c711                	beqz	a4,ffffffffc020404a <strnlen+0x1c>
        cnt ++;
ffffffffc0204040:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204042:	00f50733          	add	a4,a0,a5
ffffffffc0204046:	fef59ae3          	bne	a1,a5,ffffffffc020403a <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020404a:	853e                	mv	a0,a5
ffffffffc020404c:	8082                	ret
    size_t cnt = 0;
ffffffffc020404e:	4781                	li	a5,0
}
ffffffffc0204050:	853e                	mv	a0,a5
ffffffffc0204052:	8082                	ret

ffffffffc0204054 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204054:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204056:	0585                	addi	a1,a1,1
ffffffffc0204058:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020405c:	0785                	addi	a5,a5,1
ffffffffc020405e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204062:	fb75                	bnez	a4,ffffffffc0204056 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204064:	8082                	ret

ffffffffc0204066 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204066:	00054783          	lbu	a5,0(a0)
ffffffffc020406a:	0005c703          	lbu	a4,0(a1)
ffffffffc020406e:	cb91                	beqz	a5,ffffffffc0204082 <strcmp+0x1c>
ffffffffc0204070:	00e79c63          	bne	a5,a4,ffffffffc0204088 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0204074:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204076:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020407a:	0585                	addi	a1,a1,1
ffffffffc020407c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204080:	fbe5                	bnez	a5,ffffffffc0204070 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204082:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204084:	9d19                	subw	a0,a0,a4
ffffffffc0204086:	8082                	ret
ffffffffc0204088:	0007851b          	sext.w	a0,a5
ffffffffc020408c:	9d19                	subw	a0,a0,a4
ffffffffc020408e:	8082                	ret

ffffffffc0204090 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204090:	00054783          	lbu	a5,0(a0)
ffffffffc0204094:	cb91                	beqz	a5,ffffffffc02040a8 <strchr+0x18>
        if (*s == c) {
ffffffffc0204096:	00b79563          	bne	a5,a1,ffffffffc02040a0 <strchr+0x10>
ffffffffc020409a:	a809                	j	ffffffffc02040ac <strchr+0x1c>
ffffffffc020409c:	00b78763          	beq	a5,a1,ffffffffc02040aa <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02040a0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02040a2:	00054783          	lbu	a5,0(a0)
ffffffffc02040a6:	fbfd                	bnez	a5,ffffffffc020409c <strchr+0xc>
    }
    return NULL;
ffffffffc02040a8:	4501                	li	a0,0
}
ffffffffc02040aa:	8082                	ret
ffffffffc02040ac:	8082                	ret

ffffffffc02040ae <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02040ae:	ca01                	beqz	a2,ffffffffc02040be <memset+0x10>
ffffffffc02040b0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02040b2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02040b4:	0785                	addi	a5,a5,1
ffffffffc02040b6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02040ba:	fec79de3          	bne	a5,a2,ffffffffc02040b4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02040be:	8082                	ret

ffffffffc02040c0 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02040c0:	ca19                	beqz	a2,ffffffffc02040d6 <memcpy+0x16>
ffffffffc02040c2:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02040c4:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02040c6:	0585                	addi	a1,a1,1
ffffffffc02040c8:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02040cc:	0785                	addi	a5,a5,1
ffffffffc02040ce:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02040d2:	fec59ae3          	bne	a1,a2,ffffffffc02040c6 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02040d6:	8082                	ret
