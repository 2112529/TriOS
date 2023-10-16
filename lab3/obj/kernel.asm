
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
ffffffffc0200042:	65260613          	addi	a2,a2,1618 # ffffffffc0210690 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	0d0040ef          	jal	ra,ffffffffc020411e <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	0f658593          	addi	a1,a1,246 # ffffffffc0204148 <etext>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	10e50513          	addi	a0,a0,270 # ffffffffc0204168 <etext+0x20>
ffffffffc0200062:	066000ef          	jal	ra,ffffffffc02000c8 <cprintf>

    print_kerninfo();
ffffffffc0200066:	0aa000ef          	jal	ra,ffffffffc0200110 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	2fd010ef          	jal	ra,ffffffffc0201b66 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	4ea000ef          	jal	ra,ffffffffc0200558 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	48c030ef          	jal	ra,ffffffffc02034fe <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	430000ef          	jal	ra,ffffffffc02004a6 <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	7e2020ef          	jal	ra,ffffffffc020285c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	360000ef          	jal	ra,ffffffffc02003de <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc0200082:	458000ef          	jal	ra,ffffffffc02004da <intr_enable>


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
ffffffffc0200096:	39e000ef          	jal	ra,ffffffffc0200434 <cons_putc>
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
ffffffffc02000bc:	37b030ef          	jal	ra,ffffffffc0203c36 <vprintfmt>
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
ffffffffc02000ca:	02810313          	addi	t1,sp,40 # ffffffffc0208028 <boot_page_table_sv39+0x28>
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
ffffffffc02000f0:	347030ef          	jal	ra,ffffffffc0203c36 <vprintfmt>
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
ffffffffc02000fc:	3380006f          	j	ffffffffc0200434 <cons_putc>

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
ffffffffc0200104:	366000ef          	jal	ra,ffffffffc020046a <cons_getc>
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
ffffffffc0200116:	08e50513          	addi	a0,a0,142 # ffffffffc02041a0 <etext+0x58>
void print_kerninfo(void) {
ffffffffc020011a:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020011c:	fadff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200120:	00000597          	auipc	a1,0x0
ffffffffc0200124:	f1658593          	addi	a1,a1,-234 # ffffffffc0200036 <kern_init>
ffffffffc0200128:	00004517          	auipc	a0,0x4
ffffffffc020012c:	09850513          	addi	a0,a0,152 # ffffffffc02041c0 <etext+0x78>
ffffffffc0200130:	f99ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200134:	00004597          	auipc	a1,0x4
ffffffffc0200138:	01458593          	addi	a1,a1,20 # ffffffffc0204148 <etext>
ffffffffc020013c:	00004517          	auipc	a0,0x4
ffffffffc0200140:	0a450513          	addi	a0,a0,164 # ffffffffc02041e0 <etext+0x98>
ffffffffc0200144:	f85ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200148:	00009597          	auipc	a1,0x9
ffffffffc020014c:	ef858593          	addi	a1,a1,-264 # ffffffffc0209040 <edata>
ffffffffc0200150:	00004517          	auipc	a0,0x4
ffffffffc0200154:	0b050513          	addi	a0,a0,176 # ffffffffc0204200 <etext+0xb8>
ffffffffc0200158:	f71ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020015c:	00010597          	auipc	a1,0x10
ffffffffc0200160:	53458593          	addi	a1,a1,1332 # ffffffffc0210690 <end>
ffffffffc0200164:	00004517          	auipc	a0,0x4
ffffffffc0200168:	0bc50513          	addi	a0,a0,188 # ffffffffc0204220 <etext+0xd8>
ffffffffc020016c:	f5dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200170:	00011597          	auipc	a1,0x11
ffffffffc0200174:	91f58593          	addi	a1,a1,-1761 # ffffffffc0210a8f <end+0x3ff>
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
ffffffffc0200196:	0ae50513          	addi	a0,a0,174 # ffffffffc0204240 <etext+0xf8>
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
ffffffffc02001a6:	fce60613          	addi	a2,a2,-50 # ffffffffc0204170 <etext+0x28>
ffffffffc02001aa:	04e00593          	li	a1,78
ffffffffc02001ae:	00004517          	auipc	a0,0x4
ffffffffc02001b2:	fda50513          	addi	a0,a0,-38 # ffffffffc0204188 <etext+0x40>
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
ffffffffc02001c2:	18a60613          	addi	a2,a2,394 # ffffffffc0204348 <commands+0xd8>
ffffffffc02001c6:	00004597          	auipc	a1,0x4
ffffffffc02001ca:	1a258593          	addi	a1,a1,418 # ffffffffc0204368 <commands+0xf8>
ffffffffc02001ce:	00004517          	auipc	a0,0x4
ffffffffc02001d2:	1a250513          	addi	a0,a0,418 # ffffffffc0204370 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001d6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001d8:	ef1ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
ffffffffc02001dc:	00004617          	auipc	a2,0x4
ffffffffc02001e0:	1a460613          	addi	a2,a2,420 # ffffffffc0204380 <commands+0x110>
ffffffffc02001e4:	00004597          	auipc	a1,0x4
ffffffffc02001e8:	1c458593          	addi	a1,a1,452 # ffffffffc02043a8 <commands+0x138>
ffffffffc02001ec:	00004517          	auipc	a0,0x4
ffffffffc02001f0:	18450513          	addi	a0,a0,388 # ffffffffc0204370 <commands+0x100>
ffffffffc02001f4:	ed5ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
ffffffffc02001f8:	00004617          	auipc	a2,0x4
ffffffffc02001fc:	1c060613          	addi	a2,a2,448 # ffffffffc02043b8 <commands+0x148>
ffffffffc0200200:	00004597          	auipc	a1,0x4
ffffffffc0200204:	1d858593          	addi	a1,a1,472 # ffffffffc02043d8 <commands+0x168>
ffffffffc0200208:	00004517          	auipc	a0,0x4
ffffffffc020020c:	16850513          	addi	a0,a0,360 # ffffffffc0204370 <commands+0x100>
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
ffffffffc0200246:	07650513          	addi	a0,a0,118 # ffffffffc02042b8 <commands+0x48>
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
ffffffffc0200268:	07c50513          	addi	a0,a0,124 # ffffffffc02042e0 <commands+0x70>
ffffffffc020026c:	e5dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    if (tf != NULL) {
ffffffffc0200270:	000c0563          	beqz	s8,ffffffffc020027a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200274:	8562                	mv	a0,s8
ffffffffc0200276:	4ce000ef          	jal	ra,ffffffffc0200744 <print_trapframe>
ffffffffc020027a:	00004c97          	auipc	s9,0x4
ffffffffc020027e:	ff6c8c93          	addi	s9,s9,-10 # ffffffffc0204270 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200282:	00005997          	auipc	s3,0x5
ffffffffc0200286:	59e98993          	addi	s3,s3,1438 # ffffffffc0205820 <default_pmm_manager+0x940>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020028a:	00004917          	auipc	s2,0x4
ffffffffc020028e:	07e90913          	addi	s2,s2,126 # ffffffffc0204308 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200292:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200294:	00004b17          	auipc	s6,0x4
ffffffffc0200298:	07cb0b13          	addi	s6,s6,124 # ffffffffc0204310 <commands+0xa0>
    if (argc == 0) {
ffffffffc020029c:	00004a97          	auipc	s5,0x4
ffffffffc02002a0:	0cca8a93          	addi	s5,s5,204 # ffffffffc0204368 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002a4:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002a6:	854e                	mv	a0,s3
ffffffffc02002a8:	51b030ef          	jal	ra,ffffffffc0203fc2 <readline>
ffffffffc02002ac:	842a                	mv	s0,a0
ffffffffc02002ae:	dd65                	beqz	a0,ffffffffc02002a6 <kmonitor+0x6a>
ffffffffc02002b0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002b4:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b6:	c999                	beqz	a1,ffffffffc02002cc <kmonitor+0x90>
ffffffffc02002b8:	854a                	mv	a0,s2
ffffffffc02002ba:	647030ef          	jal	ra,ffffffffc0204100 <strchr>
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
ffffffffc02002d4:	fa0d0d13          	addi	s10,s10,-96 # ffffffffc0204270 <commands>
    if (argc == 0) {
ffffffffc02002d8:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002da:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002dc:	0d61                	addi	s10,s10,24
ffffffffc02002de:	5f9030ef          	jal	ra,ffffffffc02040d6 <strcmp>
ffffffffc02002e2:	c919                	beqz	a0,ffffffffc02002f8 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002e4:	2405                	addiw	s0,s0,1
ffffffffc02002e6:	09740463          	beq	s0,s7,ffffffffc020036e <kmonitor+0x132>
ffffffffc02002ea:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ee:	6582                	ld	a1,0(sp)
ffffffffc02002f0:	0d61                	addi	s10,s10,24
ffffffffc02002f2:	5e5030ef          	jal	ra,ffffffffc02040d6 <strcmp>
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
ffffffffc0200358:	5a9030ef          	jal	ra,ffffffffc0204100 <strchr>
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
ffffffffc0200374:	fc050513          	addi	a0,a0,-64 # ffffffffc0204330 <commands+0xc0>
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
ffffffffc020037e:	00010317          	auipc	t1,0x10
ffffffffc0200382:	0c230313          	addi	t1,t1,194 # ffffffffc0210440 <is_panic>
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
ffffffffc02003a2:	00010717          	auipc	a4,0x10
ffffffffc02003a6:	08f72f23          	sw	a5,158(a4) # ffffffffc0210440 <is_panic>

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
ffffffffc02003b4:	03850513          	addi	a0,a0,56 # ffffffffc02043e8 <commands+0x178>
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
ffffffffc02003ca:	00250513          	addi	a0,a0,2 # ffffffffc02053c8 <default_pmm_manager+0x4e8>
ffffffffc02003ce:	cfbff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003d2:	10e000ef          	jal	ra,ffffffffc02004e0 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003d6:	4501                	li	a0,0
ffffffffc02003d8:	e65ff0ef          	jal	ra,ffffffffc020023c <kmonitor>
ffffffffc02003dc:	bfed                	j	ffffffffc02003d6 <__panic+0x58>

ffffffffc02003de <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003de:	67e1                	lui	a5,0x18
ffffffffc02003e0:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02003e4:	00010717          	auipc	a4,0x10
ffffffffc02003e8:	06f73223          	sd	a5,100(a4) # ffffffffc0210448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003ec:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003f0:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003f2:	953e                	add	a0,a0,a5
ffffffffc02003f4:	4601                	li	a2,0
ffffffffc02003f6:	4881                	li	a7,0
ffffffffc02003f8:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003fc:	02000793          	li	a5,32
ffffffffc0200400:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200404:	00004517          	auipc	a0,0x4
ffffffffc0200408:	00450513          	addi	a0,a0,4 # ffffffffc0204408 <commands+0x198>
    ticks = 0;
ffffffffc020040c:	00010797          	auipc	a5,0x10
ffffffffc0200410:	0607b623          	sd	zero,108(a5) # ffffffffc0210478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200414:	cb5ff06f          	j	ffffffffc02000c8 <cprintf>

ffffffffc0200418 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	00010797          	auipc	a5,0x10
ffffffffc0200420:	02c78793          	addi	a5,a5,44 # ffffffffc0210448 <timebase>
ffffffffc0200424:	639c                	ld	a5,0(a5)
ffffffffc0200426:	4581                	li	a1,0
ffffffffc0200428:	4601                	li	a2,0
ffffffffc020042a:	953e                	add	a0,a0,a5
ffffffffc020042c:	4881                	li	a7,0
ffffffffc020042e:	00000073          	ecall
ffffffffc0200432:	8082                	ret

ffffffffc0200434 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200434:	100027f3          	csrr	a5,sstatus
ffffffffc0200438:	8b89                	andi	a5,a5,2
ffffffffc020043a:	0ff57513          	andi	a0,a0,255
ffffffffc020043e:	e799                	bnez	a5,ffffffffc020044c <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200440:	4581                	li	a1,0
ffffffffc0200442:	4601                	li	a2,0
ffffffffc0200444:	4885                	li	a7,1
ffffffffc0200446:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020044a:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020044c:	1101                	addi	sp,sp,-32
ffffffffc020044e:	ec06                	sd	ra,24(sp)
ffffffffc0200450:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200452:	08e000ef          	jal	ra,ffffffffc02004e0 <intr_disable>
ffffffffc0200456:	6522                	ld	a0,8(sp)
ffffffffc0200458:	4581                	li	a1,0
ffffffffc020045a:	4601                	li	a2,0
ffffffffc020045c:	4885                	li	a7,1
ffffffffc020045e:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200462:	60e2                	ld	ra,24(sp)
ffffffffc0200464:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200466:	0740006f          	j	ffffffffc02004da <intr_enable>

ffffffffc020046a <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020046a:	100027f3          	csrr	a5,sstatus
ffffffffc020046e:	8b89                	andi	a5,a5,2
ffffffffc0200470:	eb89                	bnez	a5,ffffffffc0200482 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200472:	4501                	li	a0,0
ffffffffc0200474:	4581                	li	a1,0
ffffffffc0200476:	4601                	li	a2,0
ffffffffc0200478:	4889                	li	a7,2
ffffffffc020047a:	00000073          	ecall
ffffffffc020047e:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200480:	8082                	ret
int cons_getc(void) {
ffffffffc0200482:	1101                	addi	sp,sp,-32
ffffffffc0200484:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200486:	05a000ef          	jal	ra,ffffffffc02004e0 <intr_disable>
ffffffffc020048a:	4501                	li	a0,0
ffffffffc020048c:	4581                	li	a1,0
ffffffffc020048e:	4601                	li	a2,0
ffffffffc0200490:	4889                	li	a7,2
ffffffffc0200492:	00000073          	ecall
ffffffffc0200496:	2501                	sext.w	a0,a0
ffffffffc0200498:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020049a:	040000ef          	jal	ra,ffffffffc02004da <intr_enable>
}
ffffffffc020049e:	60e2                	ld	ra,24(sp)
ffffffffc02004a0:	6522                	ld	a0,8(sp)
ffffffffc02004a2:	6105                	addi	sp,sp,32
ffffffffc02004a4:	8082                	ret

ffffffffc02004a6 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02004a6:	8082                	ret

ffffffffc02004a8 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02004a8:	00253513          	sltiu	a0,a0,2
ffffffffc02004ac:	8082                	ret

ffffffffc02004ae <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004ae:	03800513          	li	a0,56
ffffffffc02004b2:	8082                	ret

ffffffffc02004b4 <ide_write_secs>:
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004b4:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004b6:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004ba:	00009517          	auipc	a0,0x9
ffffffffc02004be:	b8650513          	addi	a0,a0,-1146 # ffffffffc0209040 <edata>
                   size_t nsecs) {
ffffffffc02004c2:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c4:	00969613          	slli	a2,a3,0x9
ffffffffc02004c8:	85ba                	mv	a1,a4
ffffffffc02004ca:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004cc:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ce:	463030ef          	jal	ra,ffffffffc0204130 <memcpy>
    return 0;
}
ffffffffc02004d2:	60a2                	ld	ra,8(sp)
ffffffffc02004d4:	4501                	li	a0,0
ffffffffc02004d6:	0141                	addi	sp,sp,16
ffffffffc02004d8:	8082                	ret

ffffffffc02004da <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004da:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004de:	8082                	ret

ffffffffc02004e0 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e0:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004e4:	8082                	ret

ffffffffc02004e6 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004e6:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004ea:	1141                	addi	sp,sp,-16
ffffffffc02004ec:	e022                	sd	s0,0(sp)
ffffffffc02004ee:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f0:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f4:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004f6:	11053583          	ld	a1,272(a0)
ffffffffc02004fa:	05500613          	li	a2,85
ffffffffc02004fe:	c399                	beqz	a5,ffffffffc0200504 <pgfault_handler+0x1e>
ffffffffc0200500:	04b00613          	li	a2,75
ffffffffc0200504:	11843703          	ld	a4,280(s0)
ffffffffc0200508:	47bd                	li	a5,15
ffffffffc020050a:	05700693          	li	a3,87
ffffffffc020050e:	00f70463          	beq	a4,a5,ffffffffc0200516 <pgfault_handler+0x30>
ffffffffc0200512:	05200693          	li	a3,82
ffffffffc0200516:	00004517          	auipc	a0,0x4
ffffffffc020051a:	25250513          	addi	a0,a0,594 # ffffffffc0204768 <commands+0x4f8>
ffffffffc020051e:	babff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200522:	00010797          	auipc	a5,0x10
ffffffffc0200526:	16678793          	addi	a5,a5,358 # ffffffffc0210688 <check_mm_struct>
ffffffffc020052a:	6388                	ld	a0,0(a5)
ffffffffc020052c:	c911                	beqz	a0,ffffffffc0200540 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020052e:	11043603          	ld	a2,272(s0)
ffffffffc0200532:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200536:	6402                	ld	s0,0(sp)
ffffffffc0200538:	60a2                	ld	ra,8(sp)
ffffffffc020053a:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053c:	5000306f          	j	ffffffffc0203a3c <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200540:	00004617          	auipc	a2,0x4
ffffffffc0200544:	24860613          	addi	a2,a2,584 # ffffffffc0204788 <commands+0x518>
ffffffffc0200548:	07800593          	li	a1,120
ffffffffc020054c:	00004517          	auipc	a0,0x4
ffffffffc0200550:	25450513          	addi	a0,a0,596 # ffffffffc02047a0 <commands+0x530>
ffffffffc0200554:	e2bff0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0200558 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200558:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020055c:	00000797          	auipc	a5,0x0
ffffffffc0200560:	50478793          	addi	a5,a5,1284 # ffffffffc0200a60 <__alltraps>
ffffffffc0200564:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200568:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020056c:	000407b7          	lui	a5,0x40
ffffffffc0200570:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200574:	8082                	ret

ffffffffc0200576 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200576:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200578:	1141                	addi	sp,sp,-16
ffffffffc020057a:	e022                	sd	s0,0(sp)
ffffffffc020057c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020057e:	00004517          	auipc	a0,0x4
ffffffffc0200582:	23a50513          	addi	a0,a0,570 # ffffffffc02047b8 <commands+0x548>
void print_regs(struct pushregs *gpr) {
ffffffffc0200586:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200588:	b41ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020058c:	640c                	ld	a1,8(s0)
ffffffffc020058e:	00004517          	auipc	a0,0x4
ffffffffc0200592:	24250513          	addi	a0,a0,578 # ffffffffc02047d0 <commands+0x560>
ffffffffc0200596:	b33ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020059a:	680c                	ld	a1,16(s0)
ffffffffc020059c:	00004517          	auipc	a0,0x4
ffffffffc02005a0:	24c50513          	addi	a0,a0,588 # ffffffffc02047e8 <commands+0x578>
ffffffffc02005a4:	b25ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005a8:	6c0c                	ld	a1,24(s0)
ffffffffc02005aa:	00004517          	auipc	a0,0x4
ffffffffc02005ae:	25650513          	addi	a0,a0,598 # ffffffffc0204800 <commands+0x590>
ffffffffc02005b2:	b17ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005b6:	700c                	ld	a1,32(s0)
ffffffffc02005b8:	00004517          	auipc	a0,0x4
ffffffffc02005bc:	26050513          	addi	a0,a0,608 # ffffffffc0204818 <commands+0x5a8>
ffffffffc02005c0:	b09ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005c4:	740c                	ld	a1,40(s0)
ffffffffc02005c6:	00004517          	auipc	a0,0x4
ffffffffc02005ca:	26a50513          	addi	a0,a0,618 # ffffffffc0204830 <commands+0x5c0>
ffffffffc02005ce:	afbff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005d2:	780c                	ld	a1,48(s0)
ffffffffc02005d4:	00004517          	auipc	a0,0x4
ffffffffc02005d8:	27450513          	addi	a0,a0,628 # ffffffffc0204848 <commands+0x5d8>
ffffffffc02005dc:	aedff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005e0:	7c0c                	ld	a1,56(s0)
ffffffffc02005e2:	00004517          	auipc	a0,0x4
ffffffffc02005e6:	27e50513          	addi	a0,a0,638 # ffffffffc0204860 <commands+0x5f0>
ffffffffc02005ea:	adfff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005ee:	602c                	ld	a1,64(s0)
ffffffffc02005f0:	00004517          	auipc	a0,0x4
ffffffffc02005f4:	28850513          	addi	a0,a0,648 # ffffffffc0204878 <commands+0x608>
ffffffffc02005f8:	ad1ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02005fc:	642c                	ld	a1,72(s0)
ffffffffc02005fe:	00004517          	auipc	a0,0x4
ffffffffc0200602:	29250513          	addi	a0,a0,658 # ffffffffc0204890 <commands+0x620>
ffffffffc0200606:	ac3ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020060a:	682c                	ld	a1,80(s0)
ffffffffc020060c:	00004517          	auipc	a0,0x4
ffffffffc0200610:	29c50513          	addi	a0,a0,668 # ffffffffc02048a8 <commands+0x638>
ffffffffc0200614:	ab5ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200618:	6c2c                	ld	a1,88(s0)
ffffffffc020061a:	00004517          	auipc	a0,0x4
ffffffffc020061e:	2a650513          	addi	a0,a0,678 # ffffffffc02048c0 <commands+0x650>
ffffffffc0200622:	aa7ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200626:	702c                	ld	a1,96(s0)
ffffffffc0200628:	00004517          	auipc	a0,0x4
ffffffffc020062c:	2b050513          	addi	a0,a0,688 # ffffffffc02048d8 <commands+0x668>
ffffffffc0200630:	a99ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200634:	742c                	ld	a1,104(s0)
ffffffffc0200636:	00004517          	auipc	a0,0x4
ffffffffc020063a:	2ba50513          	addi	a0,a0,698 # ffffffffc02048f0 <commands+0x680>
ffffffffc020063e:	a8bff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200642:	782c                	ld	a1,112(s0)
ffffffffc0200644:	00004517          	auipc	a0,0x4
ffffffffc0200648:	2c450513          	addi	a0,a0,708 # ffffffffc0204908 <commands+0x698>
ffffffffc020064c:	a7dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200650:	7c2c                	ld	a1,120(s0)
ffffffffc0200652:	00004517          	auipc	a0,0x4
ffffffffc0200656:	2ce50513          	addi	a0,a0,718 # ffffffffc0204920 <commands+0x6b0>
ffffffffc020065a:	a6fff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020065e:	604c                	ld	a1,128(s0)
ffffffffc0200660:	00004517          	auipc	a0,0x4
ffffffffc0200664:	2d850513          	addi	a0,a0,728 # ffffffffc0204938 <commands+0x6c8>
ffffffffc0200668:	a61ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020066c:	644c                	ld	a1,136(s0)
ffffffffc020066e:	00004517          	auipc	a0,0x4
ffffffffc0200672:	2e250513          	addi	a0,a0,738 # ffffffffc0204950 <commands+0x6e0>
ffffffffc0200676:	a53ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020067a:	684c                	ld	a1,144(s0)
ffffffffc020067c:	00004517          	auipc	a0,0x4
ffffffffc0200680:	2ec50513          	addi	a0,a0,748 # ffffffffc0204968 <commands+0x6f8>
ffffffffc0200684:	a45ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200688:	6c4c                	ld	a1,152(s0)
ffffffffc020068a:	00004517          	auipc	a0,0x4
ffffffffc020068e:	2f650513          	addi	a0,a0,758 # ffffffffc0204980 <commands+0x710>
ffffffffc0200692:	a37ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200696:	704c                	ld	a1,160(s0)
ffffffffc0200698:	00004517          	auipc	a0,0x4
ffffffffc020069c:	30050513          	addi	a0,a0,768 # ffffffffc0204998 <commands+0x728>
ffffffffc02006a0:	a29ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006a4:	744c                	ld	a1,168(s0)
ffffffffc02006a6:	00004517          	auipc	a0,0x4
ffffffffc02006aa:	30a50513          	addi	a0,a0,778 # ffffffffc02049b0 <commands+0x740>
ffffffffc02006ae:	a1bff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006b2:	784c                	ld	a1,176(s0)
ffffffffc02006b4:	00004517          	auipc	a0,0x4
ffffffffc02006b8:	31450513          	addi	a0,a0,788 # ffffffffc02049c8 <commands+0x758>
ffffffffc02006bc:	a0dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006c0:	7c4c                	ld	a1,184(s0)
ffffffffc02006c2:	00004517          	auipc	a0,0x4
ffffffffc02006c6:	31e50513          	addi	a0,a0,798 # ffffffffc02049e0 <commands+0x770>
ffffffffc02006ca:	9ffff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006ce:	606c                	ld	a1,192(s0)
ffffffffc02006d0:	00004517          	auipc	a0,0x4
ffffffffc02006d4:	32850513          	addi	a0,a0,808 # ffffffffc02049f8 <commands+0x788>
ffffffffc02006d8:	9f1ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006dc:	646c                	ld	a1,200(s0)
ffffffffc02006de:	00004517          	auipc	a0,0x4
ffffffffc02006e2:	33250513          	addi	a0,a0,818 # ffffffffc0204a10 <commands+0x7a0>
ffffffffc02006e6:	9e3ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006ea:	686c                	ld	a1,208(s0)
ffffffffc02006ec:	00004517          	auipc	a0,0x4
ffffffffc02006f0:	33c50513          	addi	a0,a0,828 # ffffffffc0204a28 <commands+0x7b8>
ffffffffc02006f4:	9d5ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02006f8:	6c6c                	ld	a1,216(s0)
ffffffffc02006fa:	00004517          	auipc	a0,0x4
ffffffffc02006fe:	34650513          	addi	a0,a0,838 # ffffffffc0204a40 <commands+0x7d0>
ffffffffc0200702:	9c7ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200706:	706c                	ld	a1,224(s0)
ffffffffc0200708:	00004517          	auipc	a0,0x4
ffffffffc020070c:	35050513          	addi	a0,a0,848 # ffffffffc0204a58 <commands+0x7e8>
ffffffffc0200710:	9b9ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200714:	746c                	ld	a1,232(s0)
ffffffffc0200716:	00004517          	auipc	a0,0x4
ffffffffc020071a:	35a50513          	addi	a0,a0,858 # ffffffffc0204a70 <commands+0x800>
ffffffffc020071e:	9abff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200722:	786c                	ld	a1,240(s0)
ffffffffc0200724:	00004517          	auipc	a0,0x4
ffffffffc0200728:	36450513          	addi	a0,a0,868 # ffffffffc0204a88 <commands+0x818>
ffffffffc020072c:	99dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200730:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200732:	6402                	ld	s0,0(sp)
ffffffffc0200734:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200736:	00004517          	auipc	a0,0x4
ffffffffc020073a:	36a50513          	addi	a0,a0,874 # ffffffffc0204aa0 <commands+0x830>
}
ffffffffc020073e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200740:	989ff06f          	j	ffffffffc02000c8 <cprintf>

ffffffffc0200744 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200744:	1141                	addi	sp,sp,-16
ffffffffc0200746:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200748:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc020074a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020074c:	00004517          	auipc	a0,0x4
ffffffffc0200750:	36c50513          	addi	a0,a0,876 # ffffffffc0204ab8 <commands+0x848>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	973ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    print_regs(&tf->gpr);
ffffffffc020075a:	8522                	mv	a0,s0
ffffffffc020075c:	e1bff0ef          	jal	ra,ffffffffc0200576 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200760:	10043583          	ld	a1,256(s0)
ffffffffc0200764:	00004517          	auipc	a0,0x4
ffffffffc0200768:	36c50513          	addi	a0,a0,876 # ffffffffc0204ad0 <commands+0x860>
ffffffffc020076c:	95dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200770:	10843583          	ld	a1,264(s0)
ffffffffc0200774:	00004517          	auipc	a0,0x4
ffffffffc0200778:	37450513          	addi	a0,a0,884 # ffffffffc0204ae8 <commands+0x878>
ffffffffc020077c:	94dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200780:	11043583          	ld	a1,272(s0)
ffffffffc0200784:	00004517          	auipc	a0,0x4
ffffffffc0200788:	37c50513          	addi	a0,a0,892 # ffffffffc0204b00 <commands+0x890>
ffffffffc020078c:	93dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200790:	11843583          	ld	a1,280(s0)
}
ffffffffc0200794:	6402                	ld	s0,0(sp)
ffffffffc0200796:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200798:	00004517          	auipc	a0,0x4
ffffffffc020079c:	38050513          	addi	a0,a0,896 # ffffffffc0204b18 <commands+0x8a8>
}
ffffffffc02007a0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	927ff06f          	j	ffffffffc02000c8 <cprintf>

ffffffffc02007a6 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007a6:	11853783          	ld	a5,280(a0)
ffffffffc02007aa:	577d                	li	a4,-1
ffffffffc02007ac:	8305                	srli	a4,a4,0x1
ffffffffc02007ae:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007b0:	472d                	li	a4,11
ffffffffc02007b2:	08f76d63          	bltu	a4,a5,ffffffffc020084c <interrupt_handler+0xa6>
ffffffffc02007b6:	00004717          	auipc	a4,0x4
ffffffffc02007ba:	c6e70713          	addi	a4,a4,-914 # ffffffffc0204424 <commands+0x1b4>
ffffffffc02007be:	078a                	slli	a5,a5,0x2
ffffffffc02007c0:	97ba                	add	a5,a5,a4
ffffffffc02007c2:	439c                	lw	a5,0(a5)
ffffffffc02007c4:	97ba                	add	a5,a5,a4
ffffffffc02007c6:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007c8:	00004517          	auipc	a0,0x4
ffffffffc02007cc:	f5050513          	addi	a0,a0,-176 # ffffffffc0204718 <commands+0x4a8>
ffffffffc02007d0:	8f9ff06f          	j	ffffffffc02000c8 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007d4:	00004517          	auipc	a0,0x4
ffffffffc02007d8:	f2450513          	addi	a0,a0,-220 # ffffffffc02046f8 <commands+0x488>
ffffffffc02007dc:	8edff06f          	j	ffffffffc02000c8 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e0:	00004517          	auipc	a0,0x4
ffffffffc02007e4:	ed850513          	addi	a0,a0,-296 # ffffffffc02046b8 <commands+0x448>
ffffffffc02007e8:	8e1ff06f          	j	ffffffffc02000c8 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007ec:	00004517          	auipc	a0,0x4
ffffffffc02007f0:	eec50513          	addi	a0,a0,-276 # ffffffffc02046d8 <commands+0x468>
ffffffffc02007f4:	8d5ff06f          	j	ffffffffc02000c8 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02007f8:	00004517          	auipc	a0,0x4
ffffffffc02007fc:	f5050513          	addi	a0,a0,-176 # ffffffffc0204748 <commands+0x4d8>
ffffffffc0200800:	8c9ff06f          	j	ffffffffc02000c8 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200804:	1141                	addi	sp,sp,-16
ffffffffc0200806:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200808:	c11ff0ef          	jal	ra,ffffffffc0200418 <clock_set_next_event>
            if(ticks==100){
ffffffffc020080c:	00010797          	auipc	a5,0x10
ffffffffc0200810:	c6c78793          	addi	a5,a5,-916 # ffffffffc0210478 <ticks>
ffffffffc0200814:	6394                	ld	a3,0(a5)
ffffffffc0200816:	06400713          	li	a4,100
ffffffffc020081a:	02e68b63          	beq	a3,a4,ffffffffc0200850 <interrupt_handler+0xaa>
            else ticks++;
ffffffffc020081e:	639c                	ld	a5,0(a5)
ffffffffc0200820:	00010717          	auipc	a4,0x10
ffffffffc0200824:	c3070713          	addi	a4,a4,-976 # ffffffffc0210450 <num>
ffffffffc0200828:	0785                	addi	a5,a5,1
ffffffffc020082a:	00010697          	auipc	a3,0x10
ffffffffc020082e:	c4f6b723          	sd	a5,-946(a3) # ffffffffc0210478 <ticks>
            if(num==10)sbi_shutdown();
ffffffffc0200832:	6318                	ld	a4,0(a4)
ffffffffc0200834:	47a9                	li	a5,10
ffffffffc0200836:	00f71863          	bne	a4,a5,ffffffffc0200846 <interrupt_handler+0xa0>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020083a:	4501                	li	a0,0
ffffffffc020083c:	4581                	li	a1,0
ffffffffc020083e:	4601                	li	a2,0
ffffffffc0200840:	48a1                	li	a7,8
ffffffffc0200842:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200846:	60a2                	ld	ra,8(sp)
ffffffffc0200848:	0141                	addi	sp,sp,16
ffffffffc020084a:	8082                	ret
            print_trapframe(tf);
ffffffffc020084c:	ef9ff06f          	j	ffffffffc0200744 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200850:	06400593          	li	a1,100
ffffffffc0200854:	00004517          	auipc	a0,0x4
ffffffffc0200858:	ee450513          	addi	a0,a0,-284 # ffffffffc0204738 <commands+0x4c8>
ffffffffc020085c:	86dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
                num++;
ffffffffc0200860:	00010717          	auipc	a4,0x10
ffffffffc0200864:	bf070713          	addi	a4,a4,-1040 # ffffffffc0210450 <num>
                ticks=0;
ffffffffc0200868:	00010797          	auipc	a5,0x10
ffffffffc020086c:	c007b823          	sd	zero,-1008(a5) # ffffffffc0210478 <ticks>
                num++;
ffffffffc0200870:	631c                	ld	a5,0(a4)
ffffffffc0200872:	0785                	addi	a5,a5,1
ffffffffc0200874:	00010697          	auipc	a3,0x10
ffffffffc0200878:	bcf6be23          	sd	a5,-1060(a3) # ffffffffc0210450 <num>
ffffffffc020087c:	bf5d                	j	ffffffffc0200832 <interrupt_handler+0x8c>

ffffffffc020087e <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020087e:	11853783          	ld	a5,280(a0)
ffffffffc0200882:	473d                	li	a4,15
ffffffffc0200884:	1af76463          	bltu	a4,a5,ffffffffc0200a2c <exception_handler+0x1ae>
ffffffffc0200888:	00004717          	auipc	a4,0x4
ffffffffc020088c:	bcc70713          	addi	a4,a4,-1076 # ffffffffc0204454 <commands+0x1e4>
ffffffffc0200890:	078a                	slli	a5,a5,0x2
ffffffffc0200892:	97ba                	add	a5,a5,a4
ffffffffc0200894:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200896:	1101                	addi	sp,sp,-32
ffffffffc0200898:	e822                	sd	s0,16(sp)
ffffffffc020089a:	ec06                	sd	ra,24(sp)
ffffffffc020089c:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc020089e:	97ba                	add	a5,a5,a4
ffffffffc02008a0:	842a                	mv	s0,a0
ffffffffc02008a2:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	dfc50513          	addi	a0,a0,-516 # ffffffffc02046a0 <commands+0x430>
ffffffffc02008ac:	81dff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008b0:	8522                	mv	a0,s0
ffffffffc02008b2:	c35ff0ef          	jal	ra,ffffffffc02004e6 <pgfault_handler>
ffffffffc02008b6:	84aa                	mv	s1,a0
ffffffffc02008b8:	16051c63          	bnez	a0,ffffffffc0200a30 <exception_handler+0x1b2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008bc:	60e2                	ld	ra,24(sp)
ffffffffc02008be:	6442                	ld	s0,16(sp)
ffffffffc02008c0:	64a2                	ld	s1,8(sp)
ffffffffc02008c2:	6105                	addi	sp,sp,32
ffffffffc02008c4:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008c6:	00004517          	auipc	a0,0x4
ffffffffc02008ca:	bd250513          	addi	a0,a0,-1070 # ffffffffc0204498 <commands+0x228>
}
ffffffffc02008ce:	6442                	ld	s0,16(sp)
ffffffffc02008d0:	60e2                	ld	ra,24(sp)
ffffffffc02008d2:	64a2                	ld	s1,8(sp)
ffffffffc02008d4:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008d6:	ff2ff06f          	j	ffffffffc02000c8 <cprintf>
ffffffffc02008da:	00004517          	auipc	a0,0x4
ffffffffc02008de:	bde50513          	addi	a0,a0,-1058 # ffffffffc02044b8 <commands+0x248>
ffffffffc02008e2:	b7f5                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Exception type:Illegal instruction\n");
ffffffffc02008e4:	00004517          	auipc	a0,0x4
ffffffffc02008e8:	bf450513          	addi	a0,a0,-1036 # ffffffffc02044d8 <commands+0x268>
ffffffffc02008ec:	fdcff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc02008f0:	10843583          	ld	a1,264(s0)
ffffffffc02008f4:	00004517          	auipc	a0,0x4
ffffffffc02008f8:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0204500 <commands+0x290>
ffffffffc02008fc:	fccff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            tf->epc += 4;
ffffffffc0200900:	10843783          	ld	a5,264(s0)
ffffffffc0200904:	0791                	addi	a5,a5,4
ffffffffc0200906:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc020090a:	bf4d                	j	ffffffffc02008bc <exception_handler+0x3e>
            cprintf("Exception type: breakpoint\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	c1c50513          	addi	a0,a0,-996 # ffffffffc0204528 <commands+0x2b8>
ffffffffc0200914:	fb4ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc0200918:	10843583          	ld	a1,264(s0)
ffffffffc020091c:	00004517          	auipc	a0,0x4
ffffffffc0200920:	c2c50513          	addi	a0,a0,-980 # ffffffffc0204548 <commands+0x2d8>
ffffffffc0200924:	fa4ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            tf->epc += 4;
ffffffffc0200928:	10843783          	ld	a5,264(s0)
ffffffffc020092c:	0791                	addi	a5,a5,4
ffffffffc020092e:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200932:	b769                	j	ffffffffc02008bc <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc0200934:	00004517          	auipc	a0,0x4
ffffffffc0200938:	c3450513          	addi	a0,a0,-972 # ffffffffc0204568 <commands+0x2f8>
ffffffffc020093c:	bf49                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc020093e:	00004517          	auipc	a0,0x4
ffffffffc0200942:	c4a50513          	addi	a0,a0,-950 # ffffffffc0204588 <commands+0x318>
ffffffffc0200946:	f82ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020094a:	8522                	mv	a0,s0
ffffffffc020094c:	b9bff0ef          	jal	ra,ffffffffc02004e6 <pgfault_handler>
ffffffffc0200950:	84aa                	mv	s1,a0
ffffffffc0200952:	d52d                	beqz	a0,ffffffffc02008bc <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200954:	8522                	mv	a0,s0
ffffffffc0200956:	defff0ef          	jal	ra,ffffffffc0200744 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020095a:	86a6                	mv	a3,s1
ffffffffc020095c:	00004617          	auipc	a2,0x4
ffffffffc0200960:	c4460613          	addi	a2,a2,-956 # ffffffffc02045a0 <commands+0x330>
ffffffffc0200964:	0e800593          	li	a1,232
ffffffffc0200968:	00004517          	auipc	a0,0x4
ffffffffc020096c:	e3850513          	addi	a0,a0,-456 # ffffffffc02047a0 <commands+0x530>
ffffffffc0200970:	a0fff0ef          	jal	ra,ffffffffc020037e <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	c4c50513          	addi	a0,a0,-948 # ffffffffc02045c0 <commands+0x350>
ffffffffc020097c:	bf89                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020097e:	00004517          	auipc	a0,0x4
ffffffffc0200982:	c5a50513          	addi	a0,a0,-934 # ffffffffc02045d8 <commands+0x368>
ffffffffc0200986:	f42ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020098a:	8522                	mv	a0,s0
ffffffffc020098c:	b5bff0ef          	jal	ra,ffffffffc02004e6 <pgfault_handler>
ffffffffc0200990:	84aa                	mv	s1,a0
ffffffffc0200992:	f20505e3          	beqz	a0,ffffffffc02008bc <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200996:	8522                	mv	a0,s0
ffffffffc0200998:	dadff0ef          	jal	ra,ffffffffc0200744 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020099c:	86a6                	mv	a3,s1
ffffffffc020099e:	00004617          	auipc	a2,0x4
ffffffffc02009a2:	c0260613          	addi	a2,a2,-1022 # ffffffffc02045a0 <commands+0x330>
ffffffffc02009a6:	0f200593          	li	a1,242
ffffffffc02009aa:	00004517          	auipc	a0,0x4
ffffffffc02009ae:	df650513          	addi	a0,a0,-522 # ffffffffc02047a0 <commands+0x530>
ffffffffc02009b2:	9cdff0ef          	jal	ra,ffffffffc020037e <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc02009b6:	00004517          	auipc	a0,0x4
ffffffffc02009ba:	c3a50513          	addi	a0,a0,-966 # ffffffffc02045f0 <commands+0x380>
ffffffffc02009be:	bf01                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc02009c0:	00004517          	auipc	a0,0x4
ffffffffc02009c4:	c5050513          	addi	a0,a0,-944 # ffffffffc0204610 <commands+0x3a0>
ffffffffc02009c8:	b719                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc02009ca:	00004517          	auipc	a0,0x4
ffffffffc02009ce:	c6650513          	addi	a0,a0,-922 # ffffffffc0204630 <commands+0x3c0>
ffffffffc02009d2:	bdf5                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc02009d4:	00004517          	auipc	a0,0x4
ffffffffc02009d8:	c7c50513          	addi	a0,a0,-900 # ffffffffc0204650 <commands+0x3e0>
ffffffffc02009dc:	bdcd                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc02009de:	00004517          	auipc	a0,0x4
ffffffffc02009e2:	c9250513          	addi	a0,a0,-878 # ffffffffc0204670 <commands+0x400>
ffffffffc02009e6:	b5e5                	j	ffffffffc02008ce <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc02009e8:	00004517          	auipc	a0,0x4
ffffffffc02009ec:	ca050513          	addi	a0,a0,-864 # ffffffffc0204688 <commands+0x418>
ffffffffc02009f0:	ed8ff0ef          	jal	ra,ffffffffc02000c8 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009f4:	8522                	mv	a0,s0
ffffffffc02009f6:	af1ff0ef          	jal	ra,ffffffffc02004e6 <pgfault_handler>
ffffffffc02009fa:	84aa                	mv	s1,a0
ffffffffc02009fc:	ec0500e3          	beqz	a0,ffffffffc02008bc <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a00:	8522                	mv	a0,s0
ffffffffc0200a02:	d43ff0ef          	jal	ra,ffffffffc0200744 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a06:	86a6                	mv	a3,s1
ffffffffc0200a08:	00004617          	auipc	a2,0x4
ffffffffc0200a0c:	b9860613          	addi	a2,a2,-1128 # ffffffffc02045a0 <commands+0x330>
ffffffffc0200a10:	10800593          	li	a1,264
ffffffffc0200a14:	00004517          	auipc	a0,0x4
ffffffffc0200a18:	d8c50513          	addi	a0,a0,-628 # ffffffffc02047a0 <commands+0x530>
ffffffffc0200a1c:	963ff0ef          	jal	ra,ffffffffc020037e <__panic>
}
ffffffffc0200a20:	6442                	ld	s0,16(sp)
ffffffffc0200a22:	60e2                	ld	ra,24(sp)
ffffffffc0200a24:	64a2                	ld	s1,8(sp)
ffffffffc0200a26:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a28:	d1dff06f          	j	ffffffffc0200744 <print_trapframe>
ffffffffc0200a2c:	d19ff06f          	j	ffffffffc0200744 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a30:	8522                	mv	a0,s0
ffffffffc0200a32:	d13ff0ef          	jal	ra,ffffffffc0200744 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a36:	86a6                	mv	a3,s1
ffffffffc0200a38:	00004617          	auipc	a2,0x4
ffffffffc0200a3c:	b6860613          	addi	a2,a2,-1176 # ffffffffc02045a0 <commands+0x330>
ffffffffc0200a40:	10f00593          	li	a1,271
ffffffffc0200a44:	00004517          	auipc	a0,0x4
ffffffffc0200a48:	d5c50513          	addi	a0,a0,-676 # ffffffffc02047a0 <commands+0x530>
ffffffffc0200a4c:	933ff0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0200a50 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a50:	11853783          	ld	a5,280(a0)
ffffffffc0200a54:	0007c463          	bltz	a5,ffffffffc0200a5c <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a58:	e27ff06f          	j	ffffffffc020087e <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a5c:	d4bff06f          	j	ffffffffc02007a6 <interrupt_handler>

ffffffffc0200a60 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a60:	14011073          	csrw	sscratch,sp
ffffffffc0200a64:	712d                	addi	sp,sp,-288
ffffffffc0200a66:	e406                	sd	ra,8(sp)
ffffffffc0200a68:	ec0e                	sd	gp,24(sp)
ffffffffc0200a6a:	f012                	sd	tp,32(sp)
ffffffffc0200a6c:	f416                	sd	t0,40(sp)
ffffffffc0200a6e:	f81a                	sd	t1,48(sp)
ffffffffc0200a70:	fc1e                	sd	t2,56(sp)
ffffffffc0200a72:	e0a2                	sd	s0,64(sp)
ffffffffc0200a74:	e4a6                	sd	s1,72(sp)
ffffffffc0200a76:	e8aa                	sd	a0,80(sp)
ffffffffc0200a78:	ecae                	sd	a1,88(sp)
ffffffffc0200a7a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a7c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a7e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a80:	fcbe                	sd	a5,120(sp)
ffffffffc0200a82:	e142                	sd	a6,128(sp)
ffffffffc0200a84:	e546                	sd	a7,136(sp)
ffffffffc0200a86:	e94a                	sd	s2,144(sp)
ffffffffc0200a88:	ed4e                	sd	s3,152(sp)
ffffffffc0200a8a:	f152                	sd	s4,160(sp)
ffffffffc0200a8c:	f556                	sd	s5,168(sp)
ffffffffc0200a8e:	f95a                	sd	s6,176(sp)
ffffffffc0200a90:	fd5e                	sd	s7,184(sp)
ffffffffc0200a92:	e1e2                	sd	s8,192(sp)
ffffffffc0200a94:	e5e6                	sd	s9,200(sp)
ffffffffc0200a96:	e9ea                	sd	s10,208(sp)
ffffffffc0200a98:	edee                	sd	s11,216(sp)
ffffffffc0200a9a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a9c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a9e:	f9fa                	sd	t5,240(sp)
ffffffffc0200aa0:	fdfe                	sd	t6,248(sp)
ffffffffc0200aa2:	14002473          	csrr	s0,sscratch
ffffffffc0200aa6:	100024f3          	csrr	s1,sstatus
ffffffffc0200aaa:	14102973          	csrr	s2,sepc
ffffffffc0200aae:	143029f3          	csrr	s3,stval
ffffffffc0200ab2:	14202a73          	csrr	s4,scause
ffffffffc0200ab6:	e822                	sd	s0,16(sp)
ffffffffc0200ab8:	e226                	sd	s1,256(sp)
ffffffffc0200aba:	e64a                	sd	s2,264(sp)
ffffffffc0200abc:	ea4e                	sd	s3,272(sp)
ffffffffc0200abe:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ac0:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ac2:	f8fff0ef          	jal	ra,ffffffffc0200a50 <trap>

ffffffffc0200ac6 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ac6:	6492                	ld	s1,256(sp)
ffffffffc0200ac8:	6932                	ld	s2,264(sp)
ffffffffc0200aca:	10049073          	csrw	sstatus,s1
ffffffffc0200ace:	14191073          	csrw	sepc,s2
ffffffffc0200ad2:	60a2                	ld	ra,8(sp)
ffffffffc0200ad4:	61e2                	ld	gp,24(sp)
ffffffffc0200ad6:	7202                	ld	tp,32(sp)
ffffffffc0200ad8:	72a2                	ld	t0,40(sp)
ffffffffc0200ada:	7342                	ld	t1,48(sp)
ffffffffc0200adc:	73e2                	ld	t2,56(sp)
ffffffffc0200ade:	6406                	ld	s0,64(sp)
ffffffffc0200ae0:	64a6                	ld	s1,72(sp)
ffffffffc0200ae2:	6546                	ld	a0,80(sp)
ffffffffc0200ae4:	65e6                	ld	a1,88(sp)
ffffffffc0200ae6:	7606                	ld	a2,96(sp)
ffffffffc0200ae8:	76a6                	ld	a3,104(sp)
ffffffffc0200aea:	7746                	ld	a4,112(sp)
ffffffffc0200aec:	77e6                	ld	a5,120(sp)
ffffffffc0200aee:	680a                	ld	a6,128(sp)
ffffffffc0200af0:	68aa                	ld	a7,136(sp)
ffffffffc0200af2:	694a                	ld	s2,144(sp)
ffffffffc0200af4:	69ea                	ld	s3,152(sp)
ffffffffc0200af6:	7a0a                	ld	s4,160(sp)
ffffffffc0200af8:	7aaa                	ld	s5,168(sp)
ffffffffc0200afa:	7b4a                	ld	s6,176(sp)
ffffffffc0200afc:	7bea                	ld	s7,184(sp)
ffffffffc0200afe:	6c0e                	ld	s8,192(sp)
ffffffffc0200b00:	6cae                	ld	s9,200(sp)
ffffffffc0200b02:	6d4e                	ld	s10,208(sp)
ffffffffc0200b04:	6dee                	ld	s11,216(sp)
ffffffffc0200b06:	7e0e                	ld	t3,224(sp)
ffffffffc0200b08:	7eae                	ld	t4,232(sp)
ffffffffc0200b0a:	7f4e                	ld	t5,240(sp)
ffffffffc0200b0c:	7fee                	ld	t6,248(sp)
ffffffffc0200b0e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200b10:	10200073          	sret
	...

ffffffffc0200b20 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b20:	00010797          	auipc	a5,0x10
ffffffffc0200b24:	96078793          	addi	a5,a5,-1696 # ffffffffc0210480 <free_area>
ffffffffc0200b28:	e79c                	sd	a5,8(a5)
ffffffffc0200b2a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b2c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b30:	8082                	ret

ffffffffc0200b32 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b32:	00010517          	auipc	a0,0x10
ffffffffc0200b36:	95e56503          	lwu	a0,-1698(a0) # ffffffffc0210490 <free_area+0x10>
ffffffffc0200b3a:	8082                	ret

ffffffffc0200b3c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b3c:	715d                	addi	sp,sp,-80
ffffffffc0200b3e:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b40:	00010917          	auipc	s2,0x10
ffffffffc0200b44:	94090913          	addi	s2,s2,-1728 # ffffffffc0210480 <free_area>
ffffffffc0200b48:	00893783          	ld	a5,8(s2)
ffffffffc0200b4c:	e486                	sd	ra,72(sp)
ffffffffc0200b4e:	e0a2                	sd	s0,64(sp)
ffffffffc0200b50:	fc26                	sd	s1,56(sp)
ffffffffc0200b52:	f44e                	sd	s3,40(sp)
ffffffffc0200b54:	f052                	sd	s4,32(sp)
ffffffffc0200b56:	ec56                	sd	s5,24(sp)
ffffffffc0200b58:	e85a                	sd	s6,16(sp)
ffffffffc0200b5a:	e45e                	sd	s7,8(sp)
ffffffffc0200b5c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b5e:	31278f63          	beq	a5,s2,ffffffffc0200e7c <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b62:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b66:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b68:	8b05                	andi	a4,a4,1
ffffffffc0200b6a:	30070d63          	beqz	a4,ffffffffc0200e84 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200b6e:	4401                	li	s0,0
ffffffffc0200b70:	4481                	li	s1,0
ffffffffc0200b72:	a031                	j	ffffffffc0200b7e <default_check+0x42>
ffffffffc0200b74:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200b78:	8b09                	andi	a4,a4,2
ffffffffc0200b7a:	30070563          	beqz	a4,ffffffffc0200e84 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200b7e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b82:	679c                	ld	a5,8(a5)
ffffffffc0200b84:	2485                	addiw	s1,s1,1
ffffffffc0200b86:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b88:	ff2796e3          	bne	a5,s2,ffffffffc0200b74 <default_check+0x38>
ffffffffc0200b8c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200b8e:	3ef000ef          	jal	ra,ffffffffc020177c <nr_free_pages>
ffffffffc0200b92:	75351963          	bne	a0,s3,ffffffffc02012e4 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b96:	4505                	li	a0,1
ffffffffc0200b98:	317000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200b9c:	8a2a                	mv	s4,a0
ffffffffc0200b9e:	48050363          	beqz	a0,ffffffffc0201024 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ba2:	4505                	li	a0,1
ffffffffc0200ba4:	30b000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200ba8:	89aa                	mv	s3,a0
ffffffffc0200baa:	74050d63          	beqz	a0,ffffffffc0201304 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bae:	4505                	li	a0,1
ffffffffc0200bb0:	2ff000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200bb4:	8aaa                	mv	s5,a0
ffffffffc0200bb6:	4e050763          	beqz	a0,ffffffffc02010a4 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bba:	2f3a0563          	beq	s4,s3,ffffffffc0200ea4 <default_check+0x368>
ffffffffc0200bbe:	2eaa0363          	beq	s4,a0,ffffffffc0200ea4 <default_check+0x368>
ffffffffc0200bc2:	2ea98163          	beq	s3,a0,ffffffffc0200ea4 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bc6:	000a2783          	lw	a5,0(s4)
ffffffffc0200bca:	2e079d63          	bnez	a5,ffffffffc0200ec4 <default_check+0x388>
ffffffffc0200bce:	0009a783          	lw	a5,0(s3)
ffffffffc0200bd2:	2e079963          	bnez	a5,ffffffffc0200ec4 <default_check+0x388>
ffffffffc0200bd6:	411c                	lw	a5,0(a0)
ffffffffc0200bd8:	2e079663          	bnez	a5,ffffffffc0200ec4 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bdc:	00010797          	auipc	a5,0x10
ffffffffc0200be0:	9c478793          	addi	a5,a5,-1596 # ffffffffc02105a0 <pages>
ffffffffc0200be4:	639c                	ld	a5,0(a5)
ffffffffc0200be6:	00004717          	auipc	a4,0x4
ffffffffc0200bea:	f4a70713          	addi	a4,a4,-182 # ffffffffc0204b30 <commands+0x8c0>
ffffffffc0200bee:	630c                	ld	a1,0(a4)
ffffffffc0200bf0:	40fa0733          	sub	a4,s4,a5
ffffffffc0200bf4:	870d                	srai	a4,a4,0x3
ffffffffc0200bf6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bfa:	00005697          	auipc	a3,0x5
ffffffffc0200bfe:	34668693          	addi	a3,a3,838 # ffffffffc0205f40 <nbase>
ffffffffc0200c02:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c04:	00010697          	auipc	a3,0x10
ffffffffc0200c08:	85c68693          	addi	a3,a3,-1956 # ffffffffc0210460 <npage>
ffffffffc0200c0c:	6294                	ld	a3,0(a3)
ffffffffc0200c0e:	06b2                	slli	a3,a3,0xc
ffffffffc0200c10:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c12:	0732                	slli	a4,a4,0xc
ffffffffc0200c14:	2cd77863          	bleu	a3,a4,ffffffffc0200ee4 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c18:	40f98733          	sub	a4,s3,a5
ffffffffc0200c1c:	870d                	srai	a4,a4,0x3
ffffffffc0200c1e:	02b70733          	mul	a4,a4,a1
ffffffffc0200c22:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c24:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c26:	4ed77f63          	bleu	a3,a4,ffffffffc0201124 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c2a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c2e:	878d                	srai	a5,a5,0x3
ffffffffc0200c30:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c34:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c36:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c38:	34d7f663          	bleu	a3,a5,ffffffffc0200f84 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200c3c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c3e:	00093c03          	ld	s8,0(s2)
ffffffffc0200c42:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c46:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c4a:	00010797          	auipc	a5,0x10
ffffffffc0200c4e:	8327bf23          	sd	s2,-1986(a5) # ffffffffc0210488 <free_area+0x8>
ffffffffc0200c52:	00010797          	auipc	a5,0x10
ffffffffc0200c56:	8327b723          	sd	s2,-2002(a5) # ffffffffc0210480 <free_area>
    nr_free = 0;
ffffffffc0200c5a:	00010797          	auipc	a5,0x10
ffffffffc0200c5e:	8207ab23          	sw	zero,-1994(a5) # ffffffffc0210490 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c62:	24d000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200c66:	2e051f63          	bnez	a0,ffffffffc0200f64 <default_check+0x428>
    free_page(p0);
ffffffffc0200c6a:	4585                	li	a1,1
ffffffffc0200c6c:	8552                	mv	a0,s4
ffffffffc0200c6e:	2c9000ef          	jal	ra,ffffffffc0201736 <free_pages>
    free_page(p1);
ffffffffc0200c72:	4585                	li	a1,1
ffffffffc0200c74:	854e                	mv	a0,s3
ffffffffc0200c76:	2c1000ef          	jal	ra,ffffffffc0201736 <free_pages>
    free_page(p2);
ffffffffc0200c7a:	4585                	li	a1,1
ffffffffc0200c7c:	8556                	mv	a0,s5
ffffffffc0200c7e:	2b9000ef          	jal	ra,ffffffffc0201736 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c82:	01092703          	lw	a4,16(s2)
ffffffffc0200c86:	478d                	li	a5,3
ffffffffc0200c88:	2af71e63          	bne	a4,a5,ffffffffc0200f44 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c8c:	4505                	li	a0,1
ffffffffc0200c8e:	221000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200c92:	89aa                	mv	s3,a0
ffffffffc0200c94:	28050863          	beqz	a0,ffffffffc0200f24 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c98:	4505                	li	a0,1
ffffffffc0200c9a:	215000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200c9e:	8aaa                	mv	s5,a0
ffffffffc0200ca0:	3e050263          	beqz	a0,ffffffffc0201084 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ca4:	4505                	li	a0,1
ffffffffc0200ca6:	209000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200caa:	8a2a                	mv	s4,a0
ffffffffc0200cac:	3a050c63          	beqz	a0,ffffffffc0201064 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200cb0:	4505                	li	a0,1
ffffffffc0200cb2:	1fd000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200cb6:	38051763          	bnez	a0,ffffffffc0201044 <default_check+0x508>
    free_page(p0);
ffffffffc0200cba:	4585                	li	a1,1
ffffffffc0200cbc:	854e                	mv	a0,s3
ffffffffc0200cbe:	279000ef          	jal	ra,ffffffffc0201736 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200cc2:	00893783          	ld	a5,8(s2)
ffffffffc0200cc6:	23278f63          	beq	a5,s2,ffffffffc0200f04 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200cca:	4505                	li	a0,1
ffffffffc0200ccc:	1e3000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200cd0:	32a99a63          	bne	s3,a0,ffffffffc0201004 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200cd4:	4505                	li	a0,1
ffffffffc0200cd6:	1d9000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200cda:	30051563          	bnez	a0,ffffffffc0200fe4 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200cde:	01092783          	lw	a5,16(s2)
ffffffffc0200ce2:	2e079163          	bnez	a5,ffffffffc0200fc4 <default_check+0x488>
    free_page(p);
ffffffffc0200ce6:	854e                	mv	a0,s3
ffffffffc0200ce8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200cea:	0000f797          	auipc	a5,0xf
ffffffffc0200cee:	7987bb23          	sd	s8,1942(a5) # ffffffffc0210480 <free_area>
ffffffffc0200cf2:	0000f797          	auipc	a5,0xf
ffffffffc0200cf6:	7977bb23          	sd	s7,1942(a5) # ffffffffc0210488 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200cfa:	0000f797          	auipc	a5,0xf
ffffffffc0200cfe:	7967ab23          	sw	s6,1942(a5) # ffffffffc0210490 <free_area+0x10>
    free_page(p);
ffffffffc0200d02:	235000ef          	jal	ra,ffffffffc0201736 <free_pages>
    free_page(p1);
ffffffffc0200d06:	4585                	li	a1,1
ffffffffc0200d08:	8556                	mv	a0,s5
ffffffffc0200d0a:	22d000ef          	jal	ra,ffffffffc0201736 <free_pages>
    free_page(p2);
ffffffffc0200d0e:	4585                	li	a1,1
ffffffffc0200d10:	8552                	mv	a0,s4
ffffffffc0200d12:	225000ef          	jal	ra,ffffffffc0201736 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d16:	4515                	li	a0,5
ffffffffc0200d18:	197000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200d1c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d1e:	28050363          	beqz	a0,ffffffffc0200fa4 <default_check+0x468>
ffffffffc0200d22:	651c                	ld	a5,8(a0)
ffffffffc0200d24:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d26:	8b85                	andi	a5,a5,1
ffffffffc0200d28:	54079e63          	bnez	a5,ffffffffc0201284 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d2c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d2e:	00093b03          	ld	s6,0(s2)
ffffffffc0200d32:	00893a83          	ld	s5,8(s2)
ffffffffc0200d36:	0000f797          	auipc	a5,0xf
ffffffffc0200d3a:	7527b523          	sd	s2,1866(a5) # ffffffffc0210480 <free_area>
ffffffffc0200d3e:	0000f797          	auipc	a5,0xf
ffffffffc0200d42:	7527b523          	sd	s2,1866(a5) # ffffffffc0210488 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d46:	169000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200d4a:	50051d63          	bnez	a0,ffffffffc0201264 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d4e:	09098a13          	addi	s4,s3,144
ffffffffc0200d52:	8552                	mv	a0,s4
ffffffffc0200d54:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d56:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200d5a:	0000f797          	auipc	a5,0xf
ffffffffc0200d5e:	7207ab23          	sw	zero,1846(a5) # ffffffffc0210490 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d62:	1d5000ef          	jal	ra,ffffffffc0201736 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d66:	4511                	li	a0,4
ffffffffc0200d68:	147000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200d6c:	4c051c63          	bnez	a0,ffffffffc0201244 <default_check+0x708>
ffffffffc0200d70:	0989b783          	ld	a5,152(s3)
ffffffffc0200d74:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d76:	8b85                	andi	a5,a5,1
ffffffffc0200d78:	4a078663          	beqz	a5,ffffffffc0201224 <default_check+0x6e8>
ffffffffc0200d7c:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d80:	478d                	li	a5,3
ffffffffc0200d82:	4af71163          	bne	a4,a5,ffffffffc0201224 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d86:	450d                	li	a0,3
ffffffffc0200d88:	127000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200d8c:	8c2a                	mv	s8,a0
ffffffffc0200d8e:	46050b63          	beqz	a0,ffffffffc0201204 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200d92:	4505                	li	a0,1
ffffffffc0200d94:	11b000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200d98:	44051663          	bnez	a0,ffffffffc02011e4 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200d9c:	438a1463          	bne	s4,s8,ffffffffc02011c4 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200da0:	4585                	li	a1,1
ffffffffc0200da2:	854e                	mv	a0,s3
ffffffffc0200da4:	193000ef          	jal	ra,ffffffffc0201736 <free_pages>
    free_pages(p1, 3);
ffffffffc0200da8:	458d                	li	a1,3
ffffffffc0200daa:	8552                	mv	a0,s4
ffffffffc0200dac:	18b000ef          	jal	ra,ffffffffc0201736 <free_pages>
ffffffffc0200db0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200db4:	04898c13          	addi	s8,s3,72
ffffffffc0200db8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200dba:	8b85                	andi	a5,a5,1
ffffffffc0200dbc:	3e078463          	beqz	a5,ffffffffc02011a4 <default_check+0x668>
ffffffffc0200dc0:	0189a703          	lw	a4,24(s3)
ffffffffc0200dc4:	4785                	li	a5,1
ffffffffc0200dc6:	3cf71f63          	bne	a4,a5,ffffffffc02011a4 <default_check+0x668>
ffffffffc0200dca:	008a3783          	ld	a5,8(s4)
ffffffffc0200dce:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200dd0:	8b85                	andi	a5,a5,1
ffffffffc0200dd2:	3a078963          	beqz	a5,ffffffffc0201184 <default_check+0x648>
ffffffffc0200dd6:	018a2703          	lw	a4,24(s4)
ffffffffc0200dda:	478d                	li	a5,3
ffffffffc0200ddc:	3af71463          	bne	a4,a5,ffffffffc0201184 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200de0:	4505                	li	a0,1
ffffffffc0200de2:	0cd000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200de6:	36a99f63          	bne	s3,a0,ffffffffc0201164 <default_check+0x628>
    free_page(p0);
ffffffffc0200dea:	4585                	li	a1,1
ffffffffc0200dec:	14b000ef          	jal	ra,ffffffffc0201736 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200df0:	4509                	li	a0,2
ffffffffc0200df2:	0bd000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200df6:	34aa1763          	bne	s4,a0,ffffffffc0201144 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200dfa:	4589                	li	a1,2
ffffffffc0200dfc:	13b000ef          	jal	ra,ffffffffc0201736 <free_pages>
    free_page(p2);
ffffffffc0200e00:	4585                	li	a1,1
ffffffffc0200e02:	8562                	mv	a0,s8
ffffffffc0200e04:	133000ef          	jal	ra,ffffffffc0201736 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e08:	4515                	li	a0,5
ffffffffc0200e0a:	0a5000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200e0e:	89aa                	mv	s3,a0
ffffffffc0200e10:	48050a63          	beqz	a0,ffffffffc02012a4 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200e14:	4505                	li	a0,1
ffffffffc0200e16:	099000ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0200e1a:	2e051563          	bnez	a0,ffffffffc0201104 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200e1e:	01092783          	lw	a5,16(s2)
ffffffffc0200e22:	2c079163          	bnez	a5,ffffffffc02010e4 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e26:	4595                	li	a1,5
ffffffffc0200e28:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e2a:	0000f797          	auipc	a5,0xf
ffffffffc0200e2e:	6777a323          	sw	s7,1638(a5) # ffffffffc0210490 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200e32:	0000f797          	auipc	a5,0xf
ffffffffc0200e36:	6567b723          	sd	s6,1614(a5) # ffffffffc0210480 <free_area>
ffffffffc0200e3a:	0000f797          	auipc	a5,0xf
ffffffffc0200e3e:	6557b723          	sd	s5,1614(a5) # ffffffffc0210488 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e42:	0f5000ef          	jal	ra,ffffffffc0201736 <free_pages>
    return listelm->next;
ffffffffc0200e46:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e4a:	01278963          	beq	a5,s2,ffffffffc0200e5c <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e4e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e52:	679c                	ld	a5,8(a5)
ffffffffc0200e54:	34fd                	addiw	s1,s1,-1
ffffffffc0200e56:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e58:	ff279be3          	bne	a5,s2,ffffffffc0200e4e <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200e5c:	26049463          	bnez	s1,ffffffffc02010c4 <default_check+0x588>
    assert(total == 0);
ffffffffc0200e60:	46041263          	bnez	s0,ffffffffc02012c4 <default_check+0x788>
}
ffffffffc0200e64:	60a6                	ld	ra,72(sp)
ffffffffc0200e66:	6406                	ld	s0,64(sp)
ffffffffc0200e68:	74e2                	ld	s1,56(sp)
ffffffffc0200e6a:	7942                	ld	s2,48(sp)
ffffffffc0200e6c:	79a2                	ld	s3,40(sp)
ffffffffc0200e6e:	7a02                	ld	s4,32(sp)
ffffffffc0200e70:	6ae2                	ld	s5,24(sp)
ffffffffc0200e72:	6b42                	ld	s6,16(sp)
ffffffffc0200e74:	6ba2                	ld	s7,8(sp)
ffffffffc0200e76:	6c02                	ld	s8,0(sp)
ffffffffc0200e78:	6161                	addi	sp,sp,80
ffffffffc0200e7a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e7c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e7e:	4401                	li	s0,0
ffffffffc0200e80:	4481                	li	s1,0
ffffffffc0200e82:	b331                	j	ffffffffc0200b8e <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200e84:	00004697          	auipc	a3,0x4
ffffffffc0200e88:	cb468693          	addi	a3,a3,-844 # ffffffffc0204b38 <commands+0x8c8>
ffffffffc0200e8c:	00004617          	auipc	a2,0x4
ffffffffc0200e90:	cbc60613          	addi	a2,a2,-836 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0200e94:	0f000593          	li	a1,240
ffffffffc0200e98:	00004517          	auipc	a0,0x4
ffffffffc0200e9c:	cc850513          	addi	a0,a0,-824 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0200ea0:	cdeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ea4:	00004697          	auipc	a3,0x4
ffffffffc0200ea8:	d5468693          	addi	a3,a3,-684 # ffffffffc0204bf8 <commands+0x988>
ffffffffc0200eac:	00004617          	auipc	a2,0x4
ffffffffc0200eb0:	c9c60613          	addi	a2,a2,-868 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0200eb4:	0bd00593          	li	a1,189
ffffffffc0200eb8:	00004517          	auipc	a0,0x4
ffffffffc0200ebc:	ca850513          	addi	a0,a0,-856 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0200ec0:	cbeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ec4:	00004697          	auipc	a3,0x4
ffffffffc0200ec8:	d5c68693          	addi	a3,a3,-676 # ffffffffc0204c20 <commands+0x9b0>
ffffffffc0200ecc:	00004617          	auipc	a2,0x4
ffffffffc0200ed0:	c7c60613          	addi	a2,a2,-900 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0200ed4:	0be00593          	li	a1,190
ffffffffc0200ed8:	00004517          	auipc	a0,0x4
ffffffffc0200edc:	c8850513          	addi	a0,a0,-888 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0200ee0:	c9eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ee4:	00004697          	auipc	a3,0x4
ffffffffc0200ee8:	d7c68693          	addi	a3,a3,-644 # ffffffffc0204c60 <commands+0x9f0>
ffffffffc0200eec:	00004617          	auipc	a2,0x4
ffffffffc0200ef0:	c5c60613          	addi	a2,a2,-932 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0200ef4:	0c000593          	li	a1,192
ffffffffc0200ef8:	00004517          	auipc	a0,0x4
ffffffffc0200efc:	c6850513          	addi	a0,a0,-920 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0200f00:	c7eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f04:	00004697          	auipc	a3,0x4
ffffffffc0200f08:	de468693          	addi	a3,a3,-540 # ffffffffc0204ce8 <commands+0xa78>
ffffffffc0200f0c:	00004617          	auipc	a2,0x4
ffffffffc0200f10:	c3c60613          	addi	a2,a2,-964 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0200f14:	0d900593          	li	a1,217
ffffffffc0200f18:	00004517          	auipc	a0,0x4
ffffffffc0200f1c:	c4850513          	addi	a0,a0,-952 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0200f20:	c5eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f24:	00004697          	auipc	a3,0x4
ffffffffc0200f28:	c7468693          	addi	a3,a3,-908 # ffffffffc0204b98 <commands+0x928>
ffffffffc0200f2c:	00004617          	auipc	a2,0x4
ffffffffc0200f30:	c1c60613          	addi	a2,a2,-996 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0200f34:	0d200593          	li	a1,210
ffffffffc0200f38:	00004517          	auipc	a0,0x4
ffffffffc0200f3c:	c2850513          	addi	a0,a0,-984 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0200f40:	c3eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free == 3);
ffffffffc0200f44:	00004697          	auipc	a3,0x4
ffffffffc0200f48:	d9468693          	addi	a3,a3,-620 # ffffffffc0204cd8 <commands+0xa68>
ffffffffc0200f4c:	00004617          	auipc	a2,0x4
ffffffffc0200f50:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0200f54:	0d000593          	li	a1,208
ffffffffc0200f58:	00004517          	auipc	a0,0x4
ffffffffc0200f5c:	c0850513          	addi	a0,a0,-1016 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0200f60:	c1eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f64:	00004697          	auipc	a3,0x4
ffffffffc0200f68:	d5c68693          	addi	a3,a3,-676 # ffffffffc0204cc0 <commands+0xa50>
ffffffffc0200f6c:	00004617          	auipc	a2,0x4
ffffffffc0200f70:	bdc60613          	addi	a2,a2,-1060 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0200f74:	0cb00593          	li	a1,203
ffffffffc0200f78:	00004517          	auipc	a0,0x4
ffffffffc0200f7c:	be850513          	addi	a0,a0,-1048 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0200f80:	bfeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f84:	00004697          	auipc	a3,0x4
ffffffffc0200f88:	d1c68693          	addi	a3,a3,-740 # ffffffffc0204ca0 <commands+0xa30>
ffffffffc0200f8c:	00004617          	auipc	a2,0x4
ffffffffc0200f90:	bbc60613          	addi	a2,a2,-1092 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0200f94:	0c200593          	li	a1,194
ffffffffc0200f98:	00004517          	auipc	a0,0x4
ffffffffc0200f9c:	bc850513          	addi	a0,a0,-1080 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0200fa0:	bdeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(p0 != NULL);
ffffffffc0200fa4:	00004697          	auipc	a3,0x4
ffffffffc0200fa8:	d8c68693          	addi	a3,a3,-628 # ffffffffc0204d30 <commands+0xac0>
ffffffffc0200fac:	00004617          	auipc	a2,0x4
ffffffffc0200fb0:	b9c60613          	addi	a2,a2,-1124 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0200fb4:	0f800593          	li	a1,248
ffffffffc0200fb8:	00004517          	auipc	a0,0x4
ffffffffc0200fbc:	ba850513          	addi	a0,a0,-1112 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0200fc0:	bbeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free == 0);
ffffffffc0200fc4:	00004697          	auipc	a3,0x4
ffffffffc0200fc8:	d5c68693          	addi	a3,a3,-676 # ffffffffc0204d20 <commands+0xab0>
ffffffffc0200fcc:	00004617          	auipc	a2,0x4
ffffffffc0200fd0:	b7c60613          	addi	a2,a2,-1156 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0200fd4:	0df00593          	li	a1,223
ffffffffc0200fd8:	00004517          	auipc	a0,0x4
ffffffffc0200fdc:	b8850513          	addi	a0,a0,-1144 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0200fe0:	b9eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fe4:	00004697          	auipc	a3,0x4
ffffffffc0200fe8:	cdc68693          	addi	a3,a3,-804 # ffffffffc0204cc0 <commands+0xa50>
ffffffffc0200fec:	00004617          	auipc	a2,0x4
ffffffffc0200ff0:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0200ff4:	0dd00593          	li	a1,221
ffffffffc0200ff8:	00004517          	auipc	a0,0x4
ffffffffc0200ffc:	b6850513          	addi	a0,a0,-1176 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201000:	b7eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201004:	00004697          	auipc	a3,0x4
ffffffffc0201008:	cfc68693          	addi	a3,a3,-772 # ffffffffc0204d00 <commands+0xa90>
ffffffffc020100c:	00004617          	auipc	a2,0x4
ffffffffc0201010:	b3c60613          	addi	a2,a2,-1220 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201014:	0dc00593          	li	a1,220
ffffffffc0201018:	00004517          	auipc	a0,0x4
ffffffffc020101c:	b4850513          	addi	a0,a0,-1208 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201020:	b5eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201024:	00004697          	auipc	a3,0x4
ffffffffc0201028:	b7468693          	addi	a3,a3,-1164 # ffffffffc0204b98 <commands+0x928>
ffffffffc020102c:	00004617          	auipc	a2,0x4
ffffffffc0201030:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201034:	0b900593          	li	a1,185
ffffffffc0201038:	00004517          	auipc	a0,0x4
ffffffffc020103c:	b2850513          	addi	a0,a0,-1240 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201040:	b3eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201044:	00004697          	auipc	a3,0x4
ffffffffc0201048:	c7c68693          	addi	a3,a3,-900 # ffffffffc0204cc0 <commands+0xa50>
ffffffffc020104c:	00004617          	auipc	a2,0x4
ffffffffc0201050:	afc60613          	addi	a2,a2,-1284 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201054:	0d600593          	li	a1,214
ffffffffc0201058:	00004517          	auipc	a0,0x4
ffffffffc020105c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201060:	b1eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201064:	00004697          	auipc	a3,0x4
ffffffffc0201068:	b7468693          	addi	a3,a3,-1164 # ffffffffc0204bd8 <commands+0x968>
ffffffffc020106c:	00004617          	auipc	a2,0x4
ffffffffc0201070:	adc60613          	addi	a2,a2,-1316 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201074:	0d400593          	li	a1,212
ffffffffc0201078:	00004517          	auipc	a0,0x4
ffffffffc020107c:	ae850513          	addi	a0,a0,-1304 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201080:	afeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201084:	00004697          	auipc	a3,0x4
ffffffffc0201088:	b3468693          	addi	a3,a3,-1228 # ffffffffc0204bb8 <commands+0x948>
ffffffffc020108c:	00004617          	auipc	a2,0x4
ffffffffc0201090:	abc60613          	addi	a2,a2,-1348 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201094:	0d300593          	li	a1,211
ffffffffc0201098:	00004517          	auipc	a0,0x4
ffffffffc020109c:	ac850513          	addi	a0,a0,-1336 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc02010a0:	adeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010a4:	00004697          	auipc	a3,0x4
ffffffffc02010a8:	b3468693          	addi	a3,a3,-1228 # ffffffffc0204bd8 <commands+0x968>
ffffffffc02010ac:	00004617          	auipc	a2,0x4
ffffffffc02010b0:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02010b4:	0bb00593          	li	a1,187
ffffffffc02010b8:	00004517          	auipc	a0,0x4
ffffffffc02010bc:	aa850513          	addi	a0,a0,-1368 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc02010c0:	abeff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(count == 0);
ffffffffc02010c4:	00004697          	auipc	a3,0x4
ffffffffc02010c8:	dbc68693          	addi	a3,a3,-580 # ffffffffc0204e80 <commands+0xc10>
ffffffffc02010cc:	00004617          	auipc	a2,0x4
ffffffffc02010d0:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02010d4:	12500593          	li	a1,293
ffffffffc02010d8:	00004517          	auipc	a0,0x4
ffffffffc02010dc:	a8850513          	addi	a0,a0,-1400 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc02010e0:	a9eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free == 0);
ffffffffc02010e4:	00004697          	auipc	a3,0x4
ffffffffc02010e8:	c3c68693          	addi	a3,a3,-964 # ffffffffc0204d20 <commands+0xab0>
ffffffffc02010ec:	00004617          	auipc	a2,0x4
ffffffffc02010f0:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02010f4:	11a00593          	li	a1,282
ffffffffc02010f8:	00004517          	auipc	a0,0x4
ffffffffc02010fc:	a6850513          	addi	a0,a0,-1432 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201100:	a7eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201104:	00004697          	auipc	a3,0x4
ffffffffc0201108:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0204cc0 <commands+0xa50>
ffffffffc020110c:	00004617          	auipc	a2,0x4
ffffffffc0201110:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201114:	11800593          	li	a1,280
ffffffffc0201118:	00004517          	auipc	a0,0x4
ffffffffc020111c:	a4850513          	addi	a0,a0,-1464 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201120:	a5eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201124:	00004697          	auipc	a3,0x4
ffffffffc0201128:	b5c68693          	addi	a3,a3,-1188 # ffffffffc0204c80 <commands+0xa10>
ffffffffc020112c:	00004617          	auipc	a2,0x4
ffffffffc0201130:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201134:	0c100593          	li	a1,193
ffffffffc0201138:	00004517          	auipc	a0,0x4
ffffffffc020113c:	a2850513          	addi	a0,a0,-1496 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201140:	a3eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201144:	00004697          	auipc	a3,0x4
ffffffffc0201148:	cfc68693          	addi	a3,a3,-772 # ffffffffc0204e40 <commands+0xbd0>
ffffffffc020114c:	00004617          	auipc	a2,0x4
ffffffffc0201150:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201154:	11200593          	li	a1,274
ffffffffc0201158:	00004517          	auipc	a0,0x4
ffffffffc020115c:	a0850513          	addi	a0,a0,-1528 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201160:	a1eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201164:	00004697          	auipc	a3,0x4
ffffffffc0201168:	cbc68693          	addi	a3,a3,-836 # ffffffffc0204e20 <commands+0xbb0>
ffffffffc020116c:	00004617          	auipc	a2,0x4
ffffffffc0201170:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201174:	11000593          	li	a1,272
ffffffffc0201178:	00004517          	auipc	a0,0x4
ffffffffc020117c:	9e850513          	addi	a0,a0,-1560 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201180:	9feff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201184:	00004697          	auipc	a3,0x4
ffffffffc0201188:	c7468693          	addi	a3,a3,-908 # ffffffffc0204df8 <commands+0xb88>
ffffffffc020118c:	00004617          	auipc	a2,0x4
ffffffffc0201190:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201194:	10e00593          	li	a1,270
ffffffffc0201198:	00004517          	auipc	a0,0x4
ffffffffc020119c:	9c850513          	addi	a0,a0,-1592 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc02011a0:	9deff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02011a4:	00004697          	auipc	a3,0x4
ffffffffc02011a8:	c2c68693          	addi	a3,a3,-980 # ffffffffc0204dd0 <commands+0xb60>
ffffffffc02011ac:	00004617          	auipc	a2,0x4
ffffffffc02011b0:	99c60613          	addi	a2,a2,-1636 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02011b4:	10d00593          	li	a1,269
ffffffffc02011b8:	00004517          	auipc	a0,0x4
ffffffffc02011bc:	9a850513          	addi	a0,a0,-1624 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc02011c0:	9beff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(p0 + 2 == p1);
ffffffffc02011c4:	00004697          	auipc	a3,0x4
ffffffffc02011c8:	bfc68693          	addi	a3,a3,-1028 # ffffffffc0204dc0 <commands+0xb50>
ffffffffc02011cc:	00004617          	auipc	a2,0x4
ffffffffc02011d0:	97c60613          	addi	a2,a2,-1668 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02011d4:	10800593          	li	a1,264
ffffffffc02011d8:	00004517          	auipc	a0,0x4
ffffffffc02011dc:	98850513          	addi	a0,a0,-1656 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc02011e0:	99eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011e4:	00004697          	auipc	a3,0x4
ffffffffc02011e8:	adc68693          	addi	a3,a3,-1316 # ffffffffc0204cc0 <commands+0xa50>
ffffffffc02011ec:	00004617          	auipc	a2,0x4
ffffffffc02011f0:	95c60613          	addi	a2,a2,-1700 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02011f4:	10700593          	li	a1,263
ffffffffc02011f8:	00004517          	auipc	a0,0x4
ffffffffc02011fc:	96850513          	addi	a0,a0,-1688 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201200:	97eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201204:	00004697          	auipc	a3,0x4
ffffffffc0201208:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0204da0 <commands+0xb30>
ffffffffc020120c:	00004617          	auipc	a2,0x4
ffffffffc0201210:	93c60613          	addi	a2,a2,-1732 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201214:	10600593          	li	a1,262
ffffffffc0201218:	00004517          	auipc	a0,0x4
ffffffffc020121c:	94850513          	addi	a0,a0,-1720 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201220:	95eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201224:	00004697          	auipc	a3,0x4
ffffffffc0201228:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0204d70 <commands+0xb00>
ffffffffc020122c:	00004617          	auipc	a2,0x4
ffffffffc0201230:	91c60613          	addi	a2,a2,-1764 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201234:	10500593          	li	a1,261
ffffffffc0201238:	00004517          	auipc	a0,0x4
ffffffffc020123c:	92850513          	addi	a0,a0,-1752 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201240:	93eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201244:	00004697          	auipc	a3,0x4
ffffffffc0201248:	b1468693          	addi	a3,a3,-1260 # ffffffffc0204d58 <commands+0xae8>
ffffffffc020124c:	00004617          	auipc	a2,0x4
ffffffffc0201250:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201254:	10400593          	li	a1,260
ffffffffc0201258:	00004517          	auipc	a0,0x4
ffffffffc020125c:	90850513          	addi	a0,a0,-1784 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201260:	91eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201264:	00004697          	auipc	a3,0x4
ffffffffc0201268:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0204cc0 <commands+0xa50>
ffffffffc020126c:	00004617          	auipc	a2,0x4
ffffffffc0201270:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201274:	0fe00593          	li	a1,254
ffffffffc0201278:	00004517          	auipc	a0,0x4
ffffffffc020127c:	8e850513          	addi	a0,a0,-1816 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201280:	8feff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(!PageProperty(p0));
ffffffffc0201284:	00004697          	auipc	a3,0x4
ffffffffc0201288:	abc68693          	addi	a3,a3,-1348 # ffffffffc0204d40 <commands+0xad0>
ffffffffc020128c:	00004617          	auipc	a2,0x4
ffffffffc0201290:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201294:	0f900593          	li	a1,249
ffffffffc0201298:	00004517          	auipc	a0,0x4
ffffffffc020129c:	8c850513          	addi	a0,a0,-1848 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc02012a0:	8deff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012a4:	00004697          	auipc	a3,0x4
ffffffffc02012a8:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0204e60 <commands+0xbf0>
ffffffffc02012ac:	00004617          	auipc	a2,0x4
ffffffffc02012b0:	89c60613          	addi	a2,a2,-1892 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02012b4:	11700593          	li	a1,279
ffffffffc02012b8:	00004517          	auipc	a0,0x4
ffffffffc02012bc:	8a850513          	addi	a0,a0,-1880 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc02012c0:	8beff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(total == 0);
ffffffffc02012c4:	00004697          	auipc	a3,0x4
ffffffffc02012c8:	bcc68693          	addi	a3,a3,-1076 # ffffffffc0204e90 <commands+0xc20>
ffffffffc02012cc:	00004617          	auipc	a2,0x4
ffffffffc02012d0:	87c60613          	addi	a2,a2,-1924 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02012d4:	12600593          	li	a1,294
ffffffffc02012d8:	00004517          	auipc	a0,0x4
ffffffffc02012dc:	88850513          	addi	a0,a0,-1912 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc02012e0:	89eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(total == nr_free_pages());
ffffffffc02012e4:	00004697          	auipc	a3,0x4
ffffffffc02012e8:	89468693          	addi	a3,a3,-1900 # ffffffffc0204b78 <commands+0x908>
ffffffffc02012ec:	00004617          	auipc	a2,0x4
ffffffffc02012f0:	85c60613          	addi	a2,a2,-1956 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02012f4:	0f300593          	li	a1,243
ffffffffc02012f8:	00004517          	auipc	a0,0x4
ffffffffc02012fc:	86850513          	addi	a0,a0,-1944 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201300:	87eff0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201304:	00004697          	auipc	a3,0x4
ffffffffc0201308:	8b468693          	addi	a3,a3,-1868 # ffffffffc0204bb8 <commands+0x948>
ffffffffc020130c:	00004617          	auipc	a2,0x4
ffffffffc0201310:	83c60613          	addi	a2,a2,-1988 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201314:	0ba00593          	li	a1,186
ffffffffc0201318:	00004517          	auipc	a0,0x4
ffffffffc020131c:	84850513          	addi	a0,a0,-1976 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc0201320:	85eff0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0201324 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201324:	1141                	addi	sp,sp,-16
ffffffffc0201326:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201328:	18058063          	beqz	a1,ffffffffc02014a8 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc020132c:	00359693          	slli	a3,a1,0x3
ffffffffc0201330:	96ae                	add	a3,a3,a1
ffffffffc0201332:	068e                	slli	a3,a3,0x3
ffffffffc0201334:	96aa                	add	a3,a3,a0
ffffffffc0201336:	02d50d63          	beq	a0,a3,ffffffffc0201370 <default_free_pages+0x4c>
ffffffffc020133a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020133c:	8b85                	andi	a5,a5,1
ffffffffc020133e:	14079563          	bnez	a5,ffffffffc0201488 <default_free_pages+0x164>
ffffffffc0201342:	651c                	ld	a5,8(a0)
ffffffffc0201344:	8385                	srli	a5,a5,0x1
ffffffffc0201346:	8b85                	andi	a5,a5,1
ffffffffc0201348:	14079063          	bnez	a5,ffffffffc0201488 <default_free_pages+0x164>
ffffffffc020134c:	87aa                	mv	a5,a0
ffffffffc020134e:	a809                	j	ffffffffc0201360 <default_free_pages+0x3c>
ffffffffc0201350:	6798                	ld	a4,8(a5)
ffffffffc0201352:	8b05                	andi	a4,a4,1
ffffffffc0201354:	12071a63          	bnez	a4,ffffffffc0201488 <default_free_pages+0x164>
ffffffffc0201358:	6798                	ld	a4,8(a5)
ffffffffc020135a:	8b09                	andi	a4,a4,2
ffffffffc020135c:	12071663          	bnez	a4,ffffffffc0201488 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0201360:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201364:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201368:	04878793          	addi	a5,a5,72
ffffffffc020136c:	fed792e3          	bne	a5,a3,ffffffffc0201350 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201370:	2581                	sext.w	a1,a1
ffffffffc0201372:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201374:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201378:	4789                	li	a5,2
ffffffffc020137a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020137e:	0000f697          	auipc	a3,0xf
ffffffffc0201382:	10268693          	addi	a3,a3,258 # ffffffffc0210480 <free_area>
ffffffffc0201386:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201388:	669c                	ld	a5,8(a3)
ffffffffc020138a:	9db9                	addw	a1,a1,a4
ffffffffc020138c:	0000f717          	auipc	a4,0xf
ffffffffc0201390:	10b72223          	sw	a1,260(a4) # ffffffffc0210490 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201394:	08d78f63          	beq	a5,a3,ffffffffc0201432 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201398:	fe078713          	addi	a4,a5,-32
ffffffffc020139c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020139e:	4801                	li	a6,0
ffffffffc02013a0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02013a4:	00e56a63          	bltu	a0,a4,ffffffffc02013b8 <default_free_pages+0x94>
    return listelm->next;
ffffffffc02013a8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02013aa:	02d70563          	beq	a4,a3,ffffffffc02013d4 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013ae:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013b0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02013b4:	fee57ae3          	bleu	a4,a0,ffffffffc02013a8 <default_free_pages+0x84>
ffffffffc02013b8:	00080663          	beqz	a6,ffffffffc02013c4 <default_free_pages+0xa0>
ffffffffc02013bc:	0000f817          	auipc	a6,0xf
ffffffffc02013c0:	0cb83223          	sd	a1,196(a6) # ffffffffc0210480 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013c4:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02013c6:	e390                	sd	a2,0(a5)
ffffffffc02013c8:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02013ca:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013cc:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc02013ce:	02d59163          	bne	a1,a3,ffffffffc02013f0 <default_free_pages+0xcc>
ffffffffc02013d2:	a091                	j	ffffffffc0201416 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02013d4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013d6:	f514                	sd	a3,40(a0)
ffffffffc02013d8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013da:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02013dc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013de:	00d70563          	beq	a4,a3,ffffffffc02013e8 <default_free_pages+0xc4>
ffffffffc02013e2:	4805                	li	a6,1
ffffffffc02013e4:	87ba                	mv	a5,a4
ffffffffc02013e6:	b7e9                	j	ffffffffc02013b0 <default_free_pages+0x8c>
ffffffffc02013e8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02013ea:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02013ec:	02d78163          	beq	a5,a3,ffffffffc020140e <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02013f0:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02013f4:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc02013f8:	02081713          	slli	a4,a6,0x20
ffffffffc02013fc:	9301                	srli	a4,a4,0x20
ffffffffc02013fe:	00371793          	slli	a5,a4,0x3
ffffffffc0201402:	97ba                	add	a5,a5,a4
ffffffffc0201404:	078e                	slli	a5,a5,0x3
ffffffffc0201406:	97b2                	add	a5,a5,a2
ffffffffc0201408:	02f50e63          	beq	a0,a5,ffffffffc0201444 <default_free_pages+0x120>
ffffffffc020140c:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc020140e:	fe078713          	addi	a4,a5,-32
ffffffffc0201412:	00d78d63          	beq	a5,a3,ffffffffc020142c <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0201416:	4d0c                	lw	a1,24(a0)
ffffffffc0201418:	02059613          	slli	a2,a1,0x20
ffffffffc020141c:	9201                	srli	a2,a2,0x20
ffffffffc020141e:	00361693          	slli	a3,a2,0x3
ffffffffc0201422:	96b2                	add	a3,a3,a2
ffffffffc0201424:	068e                	slli	a3,a3,0x3
ffffffffc0201426:	96aa                	add	a3,a3,a0
ffffffffc0201428:	04d70063          	beq	a4,a3,ffffffffc0201468 <default_free_pages+0x144>
}
ffffffffc020142c:	60a2                	ld	ra,8(sp)
ffffffffc020142e:	0141                	addi	sp,sp,16
ffffffffc0201430:	8082                	ret
ffffffffc0201432:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201434:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0201438:	e398                	sd	a4,0(a5)
ffffffffc020143a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020143c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020143e:	f11c                	sd	a5,32(a0)
}
ffffffffc0201440:	0141                	addi	sp,sp,16
ffffffffc0201442:	8082                	ret
            p->property += base->property;
ffffffffc0201444:	4d1c                	lw	a5,24(a0)
ffffffffc0201446:	0107883b          	addw	a6,a5,a6
ffffffffc020144a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020144e:	57f5                	li	a5,-3
ffffffffc0201450:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201454:	02053803          	ld	a6,32(a0)
ffffffffc0201458:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc020145a:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020145c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201460:	659c                	ld	a5,8(a1)
ffffffffc0201462:	01073023          	sd	a6,0(a4)
ffffffffc0201466:	b765                	j	ffffffffc020140e <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0201468:	ff87a703          	lw	a4,-8(a5)
ffffffffc020146c:	fe878693          	addi	a3,a5,-24
ffffffffc0201470:	9db9                	addw	a1,a1,a4
ffffffffc0201472:	cd0c                	sw	a1,24(a0)
ffffffffc0201474:	5775                	li	a4,-3
ffffffffc0201476:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020147a:	6398                	ld	a4,0(a5)
ffffffffc020147c:	679c                	ld	a5,8(a5)
}
ffffffffc020147e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201480:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201482:	e398                	sd	a4,0(a5)
ffffffffc0201484:	0141                	addi	sp,sp,16
ffffffffc0201486:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201488:	00004697          	auipc	a3,0x4
ffffffffc020148c:	a1868693          	addi	a3,a3,-1512 # ffffffffc0204ea0 <commands+0xc30>
ffffffffc0201490:	00003617          	auipc	a2,0x3
ffffffffc0201494:	6b860613          	addi	a2,a2,1720 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201498:	08300593          	li	a1,131
ffffffffc020149c:	00003517          	auipc	a0,0x3
ffffffffc02014a0:	6c450513          	addi	a0,a0,1732 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc02014a4:	edbfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(n > 0);
ffffffffc02014a8:	00004697          	auipc	a3,0x4
ffffffffc02014ac:	a2068693          	addi	a3,a3,-1504 # ffffffffc0204ec8 <commands+0xc58>
ffffffffc02014b0:	00003617          	auipc	a2,0x3
ffffffffc02014b4:	69860613          	addi	a2,a2,1688 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02014b8:	08000593          	li	a1,128
ffffffffc02014bc:	00003517          	auipc	a0,0x3
ffffffffc02014c0:	6a450513          	addi	a0,a0,1700 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc02014c4:	ebbfe0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02014c8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02014c8:	cd51                	beqz	a0,ffffffffc0201564 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc02014ca:	0000f597          	auipc	a1,0xf
ffffffffc02014ce:	fb658593          	addi	a1,a1,-74 # ffffffffc0210480 <free_area>
ffffffffc02014d2:	0105a803          	lw	a6,16(a1)
ffffffffc02014d6:	862a                	mv	a2,a0
ffffffffc02014d8:	02081793          	slli	a5,a6,0x20
ffffffffc02014dc:	9381                	srli	a5,a5,0x20
ffffffffc02014de:	00a7ee63          	bltu	a5,a0,ffffffffc02014fa <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02014e2:	87ae                	mv	a5,a1
ffffffffc02014e4:	a801                	j	ffffffffc02014f4 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02014e6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014ea:	02071693          	slli	a3,a4,0x20
ffffffffc02014ee:	9281                	srli	a3,a3,0x20
ffffffffc02014f0:	00c6f763          	bleu	a2,a3,ffffffffc02014fe <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02014f4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02014f6:	feb798e3          	bne	a5,a1,ffffffffc02014e6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02014fa:	4501                	li	a0,0
}
ffffffffc02014fc:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02014fe:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc0201502:	dd6d                	beqz	a0,ffffffffc02014fc <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201504:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201508:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020150c:	00060e1b          	sext.w	t3,a2
ffffffffc0201510:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201514:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201518:	02d67b63          	bleu	a3,a2,ffffffffc020154e <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc020151c:	00361693          	slli	a3,a2,0x3
ffffffffc0201520:	96b2                	add	a3,a3,a2
ffffffffc0201522:	068e                	slli	a3,a3,0x3
ffffffffc0201524:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201526:	41c7073b          	subw	a4,a4,t3
ffffffffc020152a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020152c:	00868613          	addi	a2,a3,8
ffffffffc0201530:	4709                	li	a4,2
ffffffffc0201532:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201536:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020153a:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020153e:	0105a803          	lw	a6,16(a1)
ffffffffc0201542:	e310                	sd	a2,0(a4)
ffffffffc0201544:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201548:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020154a:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020154e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201552:	0000f717          	auipc	a4,0xf
ffffffffc0201556:	f3072f23          	sw	a6,-194(a4) # ffffffffc0210490 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020155a:	5775                	li	a4,-3
ffffffffc020155c:	17a1                	addi	a5,a5,-24
ffffffffc020155e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201562:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201564:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201566:	00004697          	auipc	a3,0x4
ffffffffc020156a:	96268693          	addi	a3,a3,-1694 # ffffffffc0204ec8 <commands+0xc58>
ffffffffc020156e:	00003617          	auipc	a2,0x3
ffffffffc0201572:	5da60613          	addi	a2,a2,1498 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201576:	06200593          	li	a1,98
ffffffffc020157a:	00003517          	auipc	a0,0x3
ffffffffc020157e:	5e650513          	addi	a0,a0,1510 # ffffffffc0204b60 <commands+0x8f0>
default_alloc_pages(size_t n) {
ffffffffc0201582:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201584:	dfbfe0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0201588 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201588:	1141                	addi	sp,sp,-16
ffffffffc020158a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020158c:	c1fd                	beqz	a1,ffffffffc0201672 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020158e:	00359693          	slli	a3,a1,0x3
ffffffffc0201592:	96ae                	add	a3,a3,a1
ffffffffc0201594:	068e                	slli	a3,a3,0x3
ffffffffc0201596:	96aa                	add	a3,a3,a0
ffffffffc0201598:	02d50463          	beq	a0,a3,ffffffffc02015c0 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020159c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020159e:	87aa                	mv	a5,a0
ffffffffc02015a0:	8b05                	andi	a4,a4,1
ffffffffc02015a2:	e709                	bnez	a4,ffffffffc02015ac <default_init_memmap+0x24>
ffffffffc02015a4:	a07d                	j	ffffffffc0201652 <default_init_memmap+0xca>
ffffffffc02015a6:	6798                	ld	a4,8(a5)
ffffffffc02015a8:	8b05                	andi	a4,a4,1
ffffffffc02015aa:	c745                	beqz	a4,ffffffffc0201652 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02015ac:	0007ac23          	sw	zero,24(a5)
ffffffffc02015b0:	0007b423          	sd	zero,8(a5)
ffffffffc02015b4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015b8:	04878793          	addi	a5,a5,72
ffffffffc02015bc:	fed795e3          	bne	a5,a3,ffffffffc02015a6 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc02015c0:	2581                	sext.w	a1,a1
ffffffffc02015c2:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015c4:	4789                	li	a5,2
ffffffffc02015c6:	00850713          	addi	a4,a0,8
ffffffffc02015ca:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02015ce:	0000f697          	auipc	a3,0xf
ffffffffc02015d2:	eb268693          	addi	a3,a3,-334 # ffffffffc0210480 <free_area>
ffffffffc02015d6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015d8:	669c                	ld	a5,8(a3)
ffffffffc02015da:	9db9                	addw	a1,a1,a4
ffffffffc02015dc:	0000f717          	auipc	a4,0xf
ffffffffc02015e0:	eab72a23          	sw	a1,-332(a4) # ffffffffc0210490 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02015e4:	04d78a63          	beq	a5,a3,ffffffffc0201638 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02015e8:	fe078713          	addi	a4,a5,-32
ffffffffc02015ec:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015ee:	4801                	li	a6,0
ffffffffc02015f0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02015f4:	00e56a63          	bltu	a0,a4,ffffffffc0201608 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc02015f8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02015fa:	02d70563          	beq	a4,a3,ffffffffc0201624 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015fe:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201600:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201604:	fee57ae3          	bleu	a4,a0,ffffffffc02015f8 <default_init_memmap+0x70>
ffffffffc0201608:	00080663          	beqz	a6,ffffffffc0201614 <default_init_memmap+0x8c>
ffffffffc020160c:	0000f717          	auipc	a4,0xf
ffffffffc0201610:	e6b73a23          	sd	a1,-396(a4) # ffffffffc0210480 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201614:	6398                	ld	a4,0(a5)
}
ffffffffc0201616:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201618:	e390                	sd	a2,0(a5)
ffffffffc020161a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020161c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020161e:	f118                	sd	a4,32(a0)
ffffffffc0201620:	0141                	addi	sp,sp,16
ffffffffc0201622:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201624:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201626:	f514                	sd	a3,40(a0)
ffffffffc0201628:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020162a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020162c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020162e:	00d70e63          	beq	a4,a3,ffffffffc020164a <default_init_memmap+0xc2>
ffffffffc0201632:	4805                	li	a6,1
ffffffffc0201634:	87ba                	mv	a5,a4
ffffffffc0201636:	b7e9                	j	ffffffffc0201600 <default_init_memmap+0x78>
}
ffffffffc0201638:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020163a:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020163e:	e398                	sd	a4,0(a5)
ffffffffc0201640:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201642:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201644:	f11c                	sd	a5,32(a0)
}
ffffffffc0201646:	0141                	addi	sp,sp,16
ffffffffc0201648:	8082                	ret
ffffffffc020164a:	60a2                	ld	ra,8(sp)
ffffffffc020164c:	e290                	sd	a2,0(a3)
ffffffffc020164e:	0141                	addi	sp,sp,16
ffffffffc0201650:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201652:	00004697          	auipc	a3,0x4
ffffffffc0201656:	87e68693          	addi	a3,a3,-1922 # ffffffffc0204ed0 <commands+0xc60>
ffffffffc020165a:	00003617          	auipc	a2,0x3
ffffffffc020165e:	4ee60613          	addi	a2,a2,1262 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201662:	04900593          	li	a1,73
ffffffffc0201666:	00003517          	auipc	a0,0x3
ffffffffc020166a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc020166e:	d11fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(n > 0);
ffffffffc0201672:	00004697          	auipc	a3,0x4
ffffffffc0201676:	85668693          	addi	a3,a3,-1962 # ffffffffc0204ec8 <commands+0xc58>
ffffffffc020167a:	00003617          	auipc	a2,0x3
ffffffffc020167e:	4ce60613          	addi	a2,a2,1230 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0201682:	04600593          	li	a1,70
ffffffffc0201686:	00003517          	auipc	a0,0x3
ffffffffc020168a:	4da50513          	addi	a0,a0,1242 # ffffffffc0204b60 <commands+0x8f0>
ffffffffc020168e:	cf1fe0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0201692 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201692:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201694:	00004617          	auipc	a2,0x4
ffffffffc0201698:	91460613          	addi	a2,a2,-1772 # ffffffffc0204fa8 <default_pmm_manager+0xc8>
ffffffffc020169c:	06500593          	li	a1,101
ffffffffc02016a0:	00004517          	auipc	a0,0x4
ffffffffc02016a4:	92850513          	addi	a0,a0,-1752 # ffffffffc0204fc8 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02016a8:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02016aa:	cd5fe0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02016ae <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02016ae:	715d                	addi	sp,sp,-80
ffffffffc02016b0:	e0a2                	sd	s0,64(sp)
ffffffffc02016b2:	fc26                	sd	s1,56(sp)
ffffffffc02016b4:	f84a                	sd	s2,48(sp)
ffffffffc02016b6:	f44e                	sd	s3,40(sp)
ffffffffc02016b8:	f052                	sd	s4,32(sp)
ffffffffc02016ba:	ec56                	sd	s5,24(sp)
ffffffffc02016bc:	e486                	sd	ra,72(sp)
ffffffffc02016be:	842a                	mv	s0,a0
ffffffffc02016c0:	0000f497          	auipc	s1,0xf
ffffffffc02016c4:	ec848493          	addi	s1,s1,-312 # ffffffffc0210588 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016c8:	4985                	li	s3,1
ffffffffc02016ca:	0000fa17          	auipc	s4,0xf
ffffffffc02016ce:	da6a0a13          	addi	s4,s4,-602 # ffffffffc0210470 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02016d2:	0005091b          	sext.w	s2,a0
ffffffffc02016d6:	0000fa97          	auipc	s5,0xf
ffffffffc02016da:	fb2a8a93          	addi	s5,s5,-78 # ffffffffc0210688 <check_mm_struct>
ffffffffc02016de:	a00d                	j	ffffffffc0201700 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016e0:	609c                	ld	a5,0(s1)
ffffffffc02016e2:	6f9c                	ld	a5,24(a5)
ffffffffc02016e4:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc02016e6:	4601                	li	a2,0
ffffffffc02016e8:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016ea:	ed0d                	bnez	a0,ffffffffc0201724 <alloc_pages+0x76>
ffffffffc02016ec:	0289ec63          	bltu	s3,s0,ffffffffc0201724 <alloc_pages+0x76>
ffffffffc02016f0:	000a2783          	lw	a5,0(s4)
ffffffffc02016f4:	2781                	sext.w	a5,a5
ffffffffc02016f6:	c79d                	beqz	a5,ffffffffc0201724 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc02016f8:	000ab503          	ld	a0,0(s5)
ffffffffc02016fc:	021010ef          	jal	ra,ffffffffc0202f1c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201700:	100027f3          	csrr	a5,sstatus
ffffffffc0201704:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201706:	8522                	mv	a0,s0
ffffffffc0201708:	dfe1                	beqz	a5,ffffffffc02016e0 <alloc_pages+0x32>
        intr_disable();
ffffffffc020170a:	dd7fe0ef          	jal	ra,ffffffffc02004e0 <intr_disable>
ffffffffc020170e:	609c                	ld	a5,0(s1)
ffffffffc0201710:	8522                	mv	a0,s0
ffffffffc0201712:	6f9c                	ld	a5,24(a5)
ffffffffc0201714:	9782                	jalr	a5
ffffffffc0201716:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201718:	dc3fe0ef          	jal	ra,ffffffffc02004da <intr_enable>
ffffffffc020171c:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc020171e:	4601                	li	a2,0
ffffffffc0201720:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201722:	d569                	beqz	a0,ffffffffc02016ec <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201724:	60a6                	ld	ra,72(sp)
ffffffffc0201726:	6406                	ld	s0,64(sp)
ffffffffc0201728:	74e2                	ld	s1,56(sp)
ffffffffc020172a:	7942                	ld	s2,48(sp)
ffffffffc020172c:	79a2                	ld	s3,40(sp)
ffffffffc020172e:	7a02                	ld	s4,32(sp)
ffffffffc0201730:	6ae2                	ld	s5,24(sp)
ffffffffc0201732:	6161                	addi	sp,sp,80
ffffffffc0201734:	8082                	ret

ffffffffc0201736 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201736:	100027f3          	csrr	a5,sstatus
ffffffffc020173a:	8b89                	andi	a5,a5,2
ffffffffc020173c:	eb89                	bnez	a5,ffffffffc020174e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020173e:	0000f797          	auipc	a5,0xf
ffffffffc0201742:	e4a78793          	addi	a5,a5,-438 # ffffffffc0210588 <pmm_manager>
ffffffffc0201746:	639c                	ld	a5,0(a5)
ffffffffc0201748:	0207b303          	ld	t1,32(a5)
ffffffffc020174c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020174e:	1101                	addi	sp,sp,-32
ffffffffc0201750:	ec06                	sd	ra,24(sp)
ffffffffc0201752:	e822                	sd	s0,16(sp)
ffffffffc0201754:	e426                	sd	s1,8(sp)
ffffffffc0201756:	842a                	mv	s0,a0
ffffffffc0201758:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020175a:	d87fe0ef          	jal	ra,ffffffffc02004e0 <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020175e:	0000f797          	auipc	a5,0xf
ffffffffc0201762:	e2a78793          	addi	a5,a5,-470 # ffffffffc0210588 <pmm_manager>
ffffffffc0201766:	639c                	ld	a5,0(a5)
ffffffffc0201768:	85a6                	mv	a1,s1
ffffffffc020176a:	8522                	mv	a0,s0
ffffffffc020176c:	739c                	ld	a5,32(a5)
ffffffffc020176e:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201770:	6442                	ld	s0,16(sp)
ffffffffc0201772:	60e2                	ld	ra,24(sp)
ffffffffc0201774:	64a2                	ld	s1,8(sp)
ffffffffc0201776:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201778:	d63fe06f          	j	ffffffffc02004da <intr_enable>

ffffffffc020177c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020177c:	100027f3          	csrr	a5,sstatus
ffffffffc0201780:	8b89                	andi	a5,a5,2
ffffffffc0201782:	eb89                	bnez	a5,ffffffffc0201794 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201784:	0000f797          	auipc	a5,0xf
ffffffffc0201788:	e0478793          	addi	a5,a5,-508 # ffffffffc0210588 <pmm_manager>
ffffffffc020178c:	639c                	ld	a5,0(a5)
ffffffffc020178e:	0287b303          	ld	t1,40(a5)
ffffffffc0201792:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201794:	1141                	addi	sp,sp,-16
ffffffffc0201796:	e406                	sd	ra,8(sp)
ffffffffc0201798:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020179a:	d47fe0ef          	jal	ra,ffffffffc02004e0 <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020179e:	0000f797          	auipc	a5,0xf
ffffffffc02017a2:	dea78793          	addi	a5,a5,-534 # ffffffffc0210588 <pmm_manager>
ffffffffc02017a6:	639c                	ld	a5,0(a5)
ffffffffc02017a8:	779c                	ld	a5,40(a5)
ffffffffc02017aa:	9782                	jalr	a5
ffffffffc02017ac:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02017ae:	d2dfe0ef          	jal	ra,ffffffffc02004da <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02017b2:	8522                	mv	a0,s0
ffffffffc02017b4:	60a2                	ld	ra,8(sp)
ffffffffc02017b6:	6402                	ld	s0,0(sp)
ffffffffc02017b8:	0141                	addi	sp,sp,16
ffffffffc02017ba:	8082                	ret

ffffffffc02017bc <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017bc:	715d                	addi	sp,sp,-80
ffffffffc02017be:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02017c0:	01e5d493          	srli	s1,a1,0x1e
ffffffffc02017c4:	1ff4f493          	andi	s1,s1,511
ffffffffc02017c8:	048e                	slli	s1,s1,0x3
ffffffffc02017ca:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017cc:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017ce:	f84a                	sd	s2,48(sp)
ffffffffc02017d0:	f44e                	sd	s3,40(sp)
ffffffffc02017d2:	f052                	sd	s4,32(sp)
ffffffffc02017d4:	e486                	sd	ra,72(sp)
ffffffffc02017d6:	e0a2                	sd	s0,64(sp)
ffffffffc02017d8:	ec56                	sd	s5,24(sp)
ffffffffc02017da:	e85a                	sd	s6,16(sp)
ffffffffc02017dc:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017de:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017e2:	892e                	mv	s2,a1
ffffffffc02017e4:	8a32                	mv	s4,a2
ffffffffc02017e6:	0000f997          	auipc	s3,0xf
ffffffffc02017ea:	c7a98993          	addi	s3,s3,-902 # ffffffffc0210460 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017ee:	e3c9                	bnez	a5,ffffffffc0201870 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017f0:	16060163          	beqz	a2,ffffffffc0201952 <get_pte+0x196>
ffffffffc02017f4:	4505                	li	a0,1
ffffffffc02017f6:	eb9ff0ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc02017fa:	842a                	mv	s0,a0
ffffffffc02017fc:	14050b63          	beqz	a0,ffffffffc0201952 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201800:	0000fb97          	auipc	s7,0xf
ffffffffc0201804:	da0b8b93          	addi	s7,s7,-608 # ffffffffc02105a0 <pages>
ffffffffc0201808:	000bb503          	ld	a0,0(s7)
ffffffffc020180c:	00003797          	auipc	a5,0x3
ffffffffc0201810:	32478793          	addi	a5,a5,804 # ffffffffc0204b30 <commands+0x8c0>
ffffffffc0201814:	0007bb03          	ld	s6,0(a5)
ffffffffc0201818:	40a40533          	sub	a0,s0,a0
ffffffffc020181c:	850d                	srai	a0,a0,0x3
ffffffffc020181e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201822:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201824:	0000f997          	auipc	s3,0xf
ffffffffc0201828:	c3c98993          	addi	s3,s3,-964 # ffffffffc0210460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020182c:	00080ab7          	lui	s5,0x80
ffffffffc0201830:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201834:	c01c                	sw	a5,0(s0)
ffffffffc0201836:	57fd                	li	a5,-1
ffffffffc0201838:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020183a:	9556                	add	a0,a0,s5
ffffffffc020183c:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020183e:	0532                	slli	a0,a0,0xc
ffffffffc0201840:	16e7f063          	bleu	a4,a5,ffffffffc02019a0 <get_pte+0x1e4>
ffffffffc0201844:	0000f797          	auipc	a5,0xf
ffffffffc0201848:	d4c78793          	addi	a5,a5,-692 # ffffffffc0210590 <va_pa_offset>
ffffffffc020184c:	639c                	ld	a5,0(a5)
ffffffffc020184e:	6605                	lui	a2,0x1
ffffffffc0201850:	4581                	li	a1,0
ffffffffc0201852:	953e                	add	a0,a0,a5
ffffffffc0201854:	0cb020ef          	jal	ra,ffffffffc020411e <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201858:	000bb683          	ld	a3,0(s7)
ffffffffc020185c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201860:	868d                	srai	a3,a3,0x3
ffffffffc0201862:	036686b3          	mul	a3,a3,s6
ffffffffc0201866:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201868:	06aa                	slli	a3,a3,0xa
ffffffffc020186a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020186e:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201870:	77fd                	lui	a5,0xfffff
ffffffffc0201872:	068a                	slli	a3,a3,0x2
ffffffffc0201874:	0009b703          	ld	a4,0(s3)
ffffffffc0201878:	8efd                	and	a3,a3,a5
ffffffffc020187a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020187e:	0ce7fc63          	bleu	a4,a5,ffffffffc0201956 <get_pte+0x19a>
ffffffffc0201882:	0000fa97          	auipc	s5,0xf
ffffffffc0201886:	d0ea8a93          	addi	s5,s5,-754 # ffffffffc0210590 <va_pa_offset>
ffffffffc020188a:	000ab403          	ld	s0,0(s5)
ffffffffc020188e:	01595793          	srli	a5,s2,0x15
ffffffffc0201892:	1ff7f793          	andi	a5,a5,511
ffffffffc0201896:	96a2                	add	a3,a3,s0
ffffffffc0201898:	00379413          	slli	s0,a5,0x3
ffffffffc020189c:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020189e:	6014                	ld	a3,0(s0)
ffffffffc02018a0:	0016f793          	andi	a5,a3,1
ffffffffc02018a4:	ebbd                	bnez	a5,ffffffffc020191a <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02018a6:	0a0a0663          	beqz	s4,ffffffffc0201952 <get_pte+0x196>
ffffffffc02018aa:	4505                	li	a0,1
ffffffffc02018ac:	e03ff0ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc02018b0:	84aa                	mv	s1,a0
ffffffffc02018b2:	c145                	beqz	a0,ffffffffc0201952 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018b4:	0000fb97          	auipc	s7,0xf
ffffffffc02018b8:	cecb8b93          	addi	s7,s7,-788 # ffffffffc02105a0 <pages>
ffffffffc02018bc:	000bb503          	ld	a0,0(s7)
ffffffffc02018c0:	00003797          	auipc	a5,0x3
ffffffffc02018c4:	27078793          	addi	a5,a5,624 # ffffffffc0204b30 <commands+0x8c0>
ffffffffc02018c8:	0007bb03          	ld	s6,0(a5)
ffffffffc02018cc:	40a48533          	sub	a0,s1,a0
ffffffffc02018d0:	850d                	srai	a0,a0,0x3
ffffffffc02018d2:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018d6:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018d8:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018dc:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018e0:	c09c                	sw	a5,0(s1)
ffffffffc02018e2:	57fd                	li	a5,-1
ffffffffc02018e4:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018e6:	9552                	add	a0,a0,s4
ffffffffc02018e8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02018ea:	0532                	slli	a0,a0,0xc
ffffffffc02018ec:	08e7fd63          	bleu	a4,a5,ffffffffc0201986 <get_pte+0x1ca>
ffffffffc02018f0:	000ab783          	ld	a5,0(s5)
ffffffffc02018f4:	6605                	lui	a2,0x1
ffffffffc02018f6:	4581                	li	a1,0
ffffffffc02018f8:	953e                	add	a0,a0,a5
ffffffffc02018fa:	025020ef          	jal	ra,ffffffffc020411e <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018fe:	000bb683          	ld	a3,0(s7)
ffffffffc0201902:	40d486b3          	sub	a3,s1,a3
ffffffffc0201906:	868d                	srai	a3,a3,0x3
ffffffffc0201908:	036686b3          	mul	a3,a3,s6
ffffffffc020190c:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020190e:	06aa                	slli	a3,a3,0xa
ffffffffc0201910:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201914:	e014                	sd	a3,0(s0)
ffffffffc0201916:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020191a:	068a                	slli	a3,a3,0x2
ffffffffc020191c:	757d                	lui	a0,0xfffff
ffffffffc020191e:	8ee9                	and	a3,a3,a0
ffffffffc0201920:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201924:	04e7f563          	bleu	a4,a5,ffffffffc020196e <get_pte+0x1b2>
ffffffffc0201928:	000ab503          	ld	a0,0(s5)
ffffffffc020192c:	00c95793          	srli	a5,s2,0xc
ffffffffc0201930:	1ff7f793          	andi	a5,a5,511
ffffffffc0201934:	96aa                	add	a3,a3,a0
ffffffffc0201936:	00379513          	slli	a0,a5,0x3
ffffffffc020193a:	9536                	add	a0,a0,a3
}
ffffffffc020193c:	60a6                	ld	ra,72(sp)
ffffffffc020193e:	6406                	ld	s0,64(sp)
ffffffffc0201940:	74e2                	ld	s1,56(sp)
ffffffffc0201942:	7942                	ld	s2,48(sp)
ffffffffc0201944:	79a2                	ld	s3,40(sp)
ffffffffc0201946:	7a02                	ld	s4,32(sp)
ffffffffc0201948:	6ae2                	ld	s5,24(sp)
ffffffffc020194a:	6b42                	ld	s6,16(sp)
ffffffffc020194c:	6ba2                	ld	s7,8(sp)
ffffffffc020194e:	6161                	addi	sp,sp,80
ffffffffc0201950:	8082                	ret
            return NULL;
ffffffffc0201952:	4501                	li	a0,0
ffffffffc0201954:	b7e5                	j	ffffffffc020193c <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201956:	00003617          	auipc	a2,0x3
ffffffffc020195a:	5da60613          	addi	a2,a2,1498 # ffffffffc0204f30 <default_pmm_manager+0x50>
ffffffffc020195e:	10200593          	li	a1,258
ffffffffc0201962:	00003517          	auipc	a0,0x3
ffffffffc0201966:	5f650513          	addi	a0,a0,1526 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc020196a:	a15fe0ef          	jal	ra,ffffffffc020037e <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020196e:	00003617          	auipc	a2,0x3
ffffffffc0201972:	5c260613          	addi	a2,a2,1474 # ffffffffc0204f30 <default_pmm_manager+0x50>
ffffffffc0201976:	10f00593          	li	a1,271
ffffffffc020197a:	00003517          	auipc	a0,0x3
ffffffffc020197e:	5de50513          	addi	a0,a0,1502 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0201982:	9fdfe0ef          	jal	ra,ffffffffc020037e <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201986:	86aa                	mv	a3,a0
ffffffffc0201988:	00003617          	auipc	a2,0x3
ffffffffc020198c:	5a860613          	addi	a2,a2,1448 # ffffffffc0204f30 <default_pmm_manager+0x50>
ffffffffc0201990:	10b00593          	li	a1,267
ffffffffc0201994:	00003517          	auipc	a0,0x3
ffffffffc0201998:	5c450513          	addi	a0,a0,1476 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc020199c:	9e3fe0ef          	jal	ra,ffffffffc020037e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02019a0:	86aa                	mv	a3,a0
ffffffffc02019a2:	00003617          	auipc	a2,0x3
ffffffffc02019a6:	58e60613          	addi	a2,a2,1422 # ffffffffc0204f30 <default_pmm_manager+0x50>
ffffffffc02019aa:	0ff00593          	li	a1,255
ffffffffc02019ae:	00003517          	auipc	a0,0x3
ffffffffc02019b2:	5aa50513          	addi	a0,a0,1450 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02019b6:	9c9fe0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02019ba <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019ba:	1141                	addi	sp,sp,-16
ffffffffc02019bc:	e022                	sd	s0,0(sp)
ffffffffc02019be:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019c0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019c2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019c4:	df9ff0ef          	jal	ra,ffffffffc02017bc <get_pte>
    if (ptep_store != NULL) {
ffffffffc02019c8:	c011                	beqz	s0,ffffffffc02019cc <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02019ca:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019cc:	c521                	beqz	a0,ffffffffc0201a14 <get_page+0x5a>
ffffffffc02019ce:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02019d0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019d2:	0017f713          	andi	a4,a5,1
ffffffffc02019d6:	e709                	bnez	a4,ffffffffc02019e0 <get_page+0x26>
}
ffffffffc02019d8:	60a2                	ld	ra,8(sp)
ffffffffc02019da:	6402                	ld	s0,0(sp)
ffffffffc02019dc:	0141                	addi	sp,sp,16
ffffffffc02019de:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02019e0:	0000f717          	auipc	a4,0xf
ffffffffc02019e4:	a8070713          	addi	a4,a4,-1408 # ffffffffc0210460 <npage>
ffffffffc02019e8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019ea:	078a                	slli	a5,a5,0x2
ffffffffc02019ec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019ee:	02e7f863          	bleu	a4,a5,ffffffffc0201a1e <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc02019f2:	fff80537          	lui	a0,0xfff80
ffffffffc02019f6:	97aa                	add	a5,a5,a0
ffffffffc02019f8:	0000f697          	auipc	a3,0xf
ffffffffc02019fc:	ba868693          	addi	a3,a3,-1112 # ffffffffc02105a0 <pages>
ffffffffc0201a00:	6288                	ld	a0,0(a3)
ffffffffc0201a02:	60a2                	ld	ra,8(sp)
ffffffffc0201a04:	6402                	ld	s0,0(sp)
ffffffffc0201a06:	00379713          	slli	a4,a5,0x3
ffffffffc0201a0a:	97ba                	add	a5,a5,a4
ffffffffc0201a0c:	078e                	slli	a5,a5,0x3
ffffffffc0201a0e:	953e                	add	a0,a0,a5
ffffffffc0201a10:	0141                	addi	sp,sp,16
ffffffffc0201a12:	8082                	ret
ffffffffc0201a14:	60a2                	ld	ra,8(sp)
ffffffffc0201a16:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201a18:	4501                	li	a0,0
}
ffffffffc0201a1a:	0141                	addi	sp,sp,16
ffffffffc0201a1c:	8082                	ret
ffffffffc0201a1e:	c75ff0ef          	jal	ra,ffffffffc0201692 <pa2page.part.4>

ffffffffc0201a22 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a22:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a24:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a26:	e406                	sd	ra,8(sp)
ffffffffc0201a28:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a2a:	d93ff0ef          	jal	ra,ffffffffc02017bc <get_pte>
    if (ptep != NULL) {
ffffffffc0201a2e:	c511                	beqz	a0,ffffffffc0201a3a <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201a30:	611c                	ld	a5,0(a0)
ffffffffc0201a32:	842a                	mv	s0,a0
ffffffffc0201a34:	0017f713          	andi	a4,a5,1
ffffffffc0201a38:	e709                	bnez	a4,ffffffffc0201a42 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201a3a:	60a2                	ld	ra,8(sp)
ffffffffc0201a3c:	6402                	ld	s0,0(sp)
ffffffffc0201a3e:	0141                	addi	sp,sp,16
ffffffffc0201a40:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a42:	0000f717          	auipc	a4,0xf
ffffffffc0201a46:	a1e70713          	addi	a4,a4,-1506 # ffffffffc0210460 <npage>
ffffffffc0201a4a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a4c:	078a                	slli	a5,a5,0x2
ffffffffc0201a4e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a50:	04e7f063          	bleu	a4,a5,ffffffffc0201a90 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a54:	fff80737          	lui	a4,0xfff80
ffffffffc0201a58:	97ba                	add	a5,a5,a4
ffffffffc0201a5a:	0000f717          	auipc	a4,0xf
ffffffffc0201a5e:	b4670713          	addi	a4,a4,-1210 # ffffffffc02105a0 <pages>
ffffffffc0201a62:	6308                	ld	a0,0(a4)
ffffffffc0201a64:	00379713          	slli	a4,a5,0x3
ffffffffc0201a68:	97ba                	add	a5,a5,a4
ffffffffc0201a6a:	078e                	slli	a5,a5,0x3
ffffffffc0201a6c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201a6e:	411c                	lw	a5,0(a0)
ffffffffc0201a70:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a74:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201a76:	cb09                	beqz	a4,ffffffffc0201a88 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a78:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a7c:	12000073          	sfence.vma
}
ffffffffc0201a80:	60a2                	ld	ra,8(sp)
ffffffffc0201a82:	6402                	ld	s0,0(sp)
ffffffffc0201a84:	0141                	addi	sp,sp,16
ffffffffc0201a86:	8082                	ret
            free_page(page);
ffffffffc0201a88:	4585                	li	a1,1
ffffffffc0201a8a:	cadff0ef          	jal	ra,ffffffffc0201736 <free_pages>
ffffffffc0201a8e:	b7ed                	j	ffffffffc0201a78 <page_remove+0x56>
ffffffffc0201a90:	c03ff0ef          	jal	ra,ffffffffc0201692 <pa2page.part.4>

ffffffffc0201a94 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a94:	7179                	addi	sp,sp,-48
ffffffffc0201a96:	87b2                	mv	a5,a2
ffffffffc0201a98:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a9a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a9c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a9e:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201aa0:	ec26                	sd	s1,24(sp)
ffffffffc0201aa2:	f406                	sd	ra,40(sp)
ffffffffc0201aa4:	e84a                	sd	s2,16(sp)
ffffffffc0201aa6:	e44e                	sd	s3,8(sp)
ffffffffc0201aa8:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201aaa:	d13ff0ef          	jal	ra,ffffffffc02017bc <get_pte>
    if (ptep == NULL) {
ffffffffc0201aae:	c945                	beqz	a0,ffffffffc0201b5e <page_insert+0xca>
    page->ref += 1;
ffffffffc0201ab0:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201ab2:	611c                	ld	a5,0(a0)
ffffffffc0201ab4:	892a                	mv	s2,a0
ffffffffc0201ab6:	0016871b          	addiw	a4,a3,1
ffffffffc0201aba:	c018                	sw	a4,0(s0)
ffffffffc0201abc:	0017f713          	andi	a4,a5,1
ffffffffc0201ac0:	e339                	bnez	a4,ffffffffc0201b06 <page_insert+0x72>
ffffffffc0201ac2:	0000f797          	auipc	a5,0xf
ffffffffc0201ac6:	ade78793          	addi	a5,a5,-1314 # ffffffffc02105a0 <pages>
ffffffffc0201aca:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201acc:	00003717          	auipc	a4,0x3
ffffffffc0201ad0:	06470713          	addi	a4,a4,100 # ffffffffc0204b30 <commands+0x8c0>
ffffffffc0201ad4:	40f407b3          	sub	a5,s0,a5
ffffffffc0201ad8:	6300                	ld	s0,0(a4)
ffffffffc0201ada:	878d                	srai	a5,a5,0x3
ffffffffc0201adc:	000806b7          	lui	a3,0x80
ffffffffc0201ae0:	028787b3          	mul	a5,a5,s0
ffffffffc0201ae4:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ae6:	07aa                	slli	a5,a5,0xa
ffffffffc0201ae8:	8fc5                	or	a5,a5,s1
ffffffffc0201aea:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201aee:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201af2:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201af6:	4501                	li	a0,0
}
ffffffffc0201af8:	70a2                	ld	ra,40(sp)
ffffffffc0201afa:	7402                	ld	s0,32(sp)
ffffffffc0201afc:	64e2                	ld	s1,24(sp)
ffffffffc0201afe:	6942                	ld	s2,16(sp)
ffffffffc0201b00:	69a2                	ld	s3,8(sp)
ffffffffc0201b02:	6145                	addi	sp,sp,48
ffffffffc0201b04:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201b06:	0000f717          	auipc	a4,0xf
ffffffffc0201b0a:	95a70713          	addi	a4,a4,-1702 # ffffffffc0210460 <npage>
ffffffffc0201b0e:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201b10:	00279513          	slli	a0,a5,0x2
ffffffffc0201b14:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b16:	04e57663          	bleu	a4,a0,ffffffffc0201b62 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b1a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201b1e:	953e                	add	a0,a0,a5
ffffffffc0201b20:	0000f997          	auipc	s3,0xf
ffffffffc0201b24:	a8098993          	addi	s3,s3,-1408 # ffffffffc02105a0 <pages>
ffffffffc0201b28:	0009b783          	ld	a5,0(s3)
ffffffffc0201b2c:	00351713          	slli	a4,a0,0x3
ffffffffc0201b30:	953a                	add	a0,a0,a4
ffffffffc0201b32:	050e                	slli	a0,a0,0x3
ffffffffc0201b34:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201b36:	00a40e63          	beq	s0,a0,ffffffffc0201b52 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201b3a:	411c                	lw	a5,0(a0)
ffffffffc0201b3c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201b40:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201b42:	cb11                	beqz	a4,ffffffffc0201b56 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201b44:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b48:	12000073          	sfence.vma
ffffffffc0201b4c:	0009b783          	ld	a5,0(s3)
ffffffffc0201b50:	bfb5                	j	ffffffffc0201acc <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201b52:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201b54:	bfa5                	j	ffffffffc0201acc <page_insert+0x38>
            free_page(page);
ffffffffc0201b56:	4585                	li	a1,1
ffffffffc0201b58:	bdfff0ef          	jal	ra,ffffffffc0201736 <free_pages>
ffffffffc0201b5c:	b7e5                	j	ffffffffc0201b44 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201b5e:	5571                	li	a0,-4
ffffffffc0201b60:	bf61                	j	ffffffffc0201af8 <page_insert+0x64>
ffffffffc0201b62:	b31ff0ef          	jal	ra,ffffffffc0201692 <pa2page.part.4>

ffffffffc0201b66 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b66:	00003797          	auipc	a5,0x3
ffffffffc0201b6a:	37a78793          	addi	a5,a5,890 # ffffffffc0204ee0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b6e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b70:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b72:	00003517          	auipc	a0,0x3
ffffffffc0201b76:	47e50513          	addi	a0,a0,1150 # ffffffffc0204ff0 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201b7a:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b7c:	0000f717          	auipc	a4,0xf
ffffffffc0201b80:	a0f73623          	sd	a5,-1524(a4) # ffffffffc0210588 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b84:	e8a2                	sd	s0,80(sp)
ffffffffc0201b86:	e4a6                	sd	s1,72(sp)
ffffffffc0201b88:	e0ca                	sd	s2,64(sp)
ffffffffc0201b8a:	fc4e                	sd	s3,56(sp)
ffffffffc0201b8c:	f852                	sd	s4,48(sp)
ffffffffc0201b8e:	f456                	sd	s5,40(sp)
ffffffffc0201b90:	f05a                	sd	s6,32(sp)
ffffffffc0201b92:	ec5e                	sd	s7,24(sp)
ffffffffc0201b94:	e862                	sd	s8,16(sp)
ffffffffc0201b96:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b98:	0000f417          	auipc	s0,0xf
ffffffffc0201b9c:	9f040413          	addi	s0,s0,-1552 # ffffffffc0210588 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ba0:	d28fe0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    pmm_manager->init();
ffffffffc0201ba4:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201ba6:	49c5                	li	s3,17
ffffffffc0201ba8:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201bac:	679c                	ld	a5,8(a5)
ffffffffc0201bae:	0000f497          	auipc	s1,0xf
ffffffffc0201bb2:	8b248493          	addi	s1,s1,-1870 # ffffffffc0210460 <npage>
ffffffffc0201bb6:	0000f917          	auipc	s2,0xf
ffffffffc0201bba:	9ea90913          	addi	s2,s2,-1558 # ffffffffc02105a0 <pages>
ffffffffc0201bbe:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201bc0:	57f5                	li	a5,-3
ffffffffc0201bc2:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201bc4:	07e006b7          	lui	a3,0x7e00
ffffffffc0201bc8:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201bcc:	015a1593          	slli	a1,s4,0x15
ffffffffc0201bd0:	00003517          	auipc	a0,0x3
ffffffffc0201bd4:	43850513          	addi	a0,a0,1080 # ffffffffc0205008 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201bd8:	0000f717          	auipc	a4,0xf
ffffffffc0201bdc:	9af73c23          	sd	a5,-1608(a4) # ffffffffc0210590 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201be0:	ce8fe0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201be4:	00003517          	auipc	a0,0x3
ffffffffc0201be8:	45450513          	addi	a0,a0,1108 # ffffffffc0205038 <default_pmm_manager+0x158>
ffffffffc0201bec:	cdcfe0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201bf0:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201bf4:	16fd                	addi	a3,a3,-1
ffffffffc0201bf6:	015a1613          	slli	a2,s4,0x15
ffffffffc0201bfa:	07e005b7          	lui	a1,0x7e00
ffffffffc0201bfe:	00003517          	auipc	a0,0x3
ffffffffc0201c02:	45250513          	addi	a0,a0,1106 # ffffffffc0205050 <default_pmm_manager+0x170>
ffffffffc0201c06:	cc2fe0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201c0a:	777d                	lui	a4,0xfffff
ffffffffc0201c0c:	00010797          	auipc	a5,0x10
ffffffffc0201c10:	a8378793          	addi	a5,a5,-1405 # ffffffffc021168f <end+0xfff>
ffffffffc0201c14:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201c16:	00088737          	lui	a4,0x88
ffffffffc0201c1a:	0000f697          	auipc	a3,0xf
ffffffffc0201c1e:	84e6b323          	sd	a4,-1978(a3) # ffffffffc0210460 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201c22:	0000f717          	auipc	a4,0xf
ffffffffc0201c26:	96f73f23          	sd	a5,-1666(a4) # ffffffffc02105a0 <pages>
ffffffffc0201c2a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c2c:	4701                	li	a4,0
ffffffffc0201c2e:	4585                	li	a1,1
ffffffffc0201c30:	fff80637          	lui	a2,0xfff80
ffffffffc0201c34:	a019                	j	ffffffffc0201c3a <pmm_init+0xd4>
ffffffffc0201c36:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201c3a:	97b6                	add	a5,a5,a3
ffffffffc0201c3c:	07a1                	addi	a5,a5,8
ffffffffc0201c3e:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c42:	609c                	ld	a5,0(s1)
ffffffffc0201c44:	0705                	addi	a4,a4,1
ffffffffc0201c46:	04868693          	addi	a3,a3,72
ffffffffc0201c4a:	00c78533          	add	a0,a5,a2
ffffffffc0201c4e:	fea764e3          	bltu	a4,a0,ffffffffc0201c36 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c52:	00093503          	ld	a0,0(s2)
ffffffffc0201c56:	00379693          	slli	a3,a5,0x3
ffffffffc0201c5a:	96be                	add	a3,a3,a5
ffffffffc0201c5c:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c60:	972a                	add	a4,a4,a0
ffffffffc0201c62:	068e                	slli	a3,a3,0x3
ffffffffc0201c64:	96ba                	add	a3,a3,a4
ffffffffc0201c66:	c0200737          	lui	a4,0xc0200
ffffffffc0201c6a:	58e6ea63          	bltu	a3,a4,ffffffffc02021fe <pmm_init+0x698>
ffffffffc0201c6e:	0000f997          	auipc	s3,0xf
ffffffffc0201c72:	92298993          	addi	s3,s3,-1758 # ffffffffc0210590 <va_pa_offset>
ffffffffc0201c76:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c7a:	45c5                	li	a1,17
ffffffffc0201c7c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c7e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c80:	44b6ef63          	bltu	a3,a1,ffffffffc02020de <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c84:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c86:	0000e417          	auipc	s0,0xe
ffffffffc0201c8a:	7d240413          	addi	s0,s0,2002 # ffffffffc0210458 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c8e:	7b9c                	ld	a5,48(a5)
ffffffffc0201c90:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c92:	00003517          	auipc	a0,0x3
ffffffffc0201c96:	40e50513          	addi	a0,a0,1038 # ffffffffc02050a0 <default_pmm_manager+0x1c0>
ffffffffc0201c9a:	c2efe0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c9e:	00006697          	auipc	a3,0x6
ffffffffc0201ca2:	36268693          	addi	a3,a3,866 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc0201ca6:	0000e797          	auipc	a5,0xe
ffffffffc0201caa:	7ad7b923          	sd	a3,1970(a5) # ffffffffc0210458 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201cae:	c02007b7          	lui	a5,0xc0200
ffffffffc0201cb2:	0ef6ece3          	bltu	a3,a5,ffffffffc02025aa <pmm_init+0xa44>
ffffffffc0201cb6:	0009b783          	ld	a5,0(s3)
ffffffffc0201cba:	8e9d                	sub	a3,a3,a5
ffffffffc0201cbc:	0000f797          	auipc	a5,0xf
ffffffffc0201cc0:	8cd7be23          	sd	a3,-1828(a5) # ffffffffc0210598 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201cc4:	ab9ff0ef          	jal	ra,ffffffffc020177c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201cc8:	6098                	ld	a4,0(s1)
ffffffffc0201cca:	c80007b7          	lui	a5,0xc8000
ffffffffc0201cce:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201cd0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201cd2:	0ae7ece3          	bltu	a5,a4,ffffffffc020258a <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201cd6:	6008                	ld	a0,0(s0)
ffffffffc0201cd8:	4c050363          	beqz	a0,ffffffffc020219e <pmm_init+0x638>
ffffffffc0201cdc:	6785                	lui	a5,0x1
ffffffffc0201cde:	17fd                	addi	a5,a5,-1
ffffffffc0201ce0:	8fe9                	and	a5,a5,a0
ffffffffc0201ce2:	2781                	sext.w	a5,a5
ffffffffc0201ce4:	4a079d63          	bnez	a5,ffffffffc020219e <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201ce8:	4601                	li	a2,0
ffffffffc0201cea:	4581                	li	a1,0
ffffffffc0201cec:	ccfff0ef          	jal	ra,ffffffffc02019ba <get_page>
ffffffffc0201cf0:	4c051763          	bnez	a0,ffffffffc02021be <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201cf4:	4505                	li	a0,1
ffffffffc0201cf6:	9b9ff0ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0201cfa:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201cfc:	6008                	ld	a0,0(s0)
ffffffffc0201cfe:	4681                	li	a3,0
ffffffffc0201d00:	4601                	li	a2,0
ffffffffc0201d02:	85d6                	mv	a1,s5
ffffffffc0201d04:	d91ff0ef          	jal	ra,ffffffffc0201a94 <page_insert>
ffffffffc0201d08:	52051763          	bnez	a0,ffffffffc0202236 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201d0c:	6008                	ld	a0,0(s0)
ffffffffc0201d0e:	4601                	li	a2,0
ffffffffc0201d10:	4581                	li	a1,0
ffffffffc0201d12:	aabff0ef          	jal	ra,ffffffffc02017bc <get_pte>
ffffffffc0201d16:	50050063          	beqz	a0,ffffffffc0202216 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d1a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d1c:	0017f713          	andi	a4,a5,1
ffffffffc0201d20:	46070363          	beqz	a4,ffffffffc0202186 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201d24:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d26:	078a                	slli	a5,a5,0x2
ffffffffc0201d28:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d2a:	44c7f063          	bleu	a2,a5,ffffffffc020216a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d2e:	fff80737          	lui	a4,0xfff80
ffffffffc0201d32:	97ba                	add	a5,a5,a4
ffffffffc0201d34:	00379713          	slli	a4,a5,0x3
ffffffffc0201d38:	00093683          	ld	a3,0(s2)
ffffffffc0201d3c:	97ba                	add	a5,a5,a4
ffffffffc0201d3e:	078e                	slli	a5,a5,0x3
ffffffffc0201d40:	97b6                	add	a5,a5,a3
ffffffffc0201d42:	5efa9463          	bne	s5,a5,ffffffffc020232a <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0201d46:	000aab83          	lw	s7,0(s5)
ffffffffc0201d4a:	4785                	li	a5,1
ffffffffc0201d4c:	5afb9f63          	bne	s7,a5,ffffffffc020230a <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d50:	6008                	ld	a0,0(s0)
ffffffffc0201d52:	76fd                	lui	a3,0xfffff
ffffffffc0201d54:	611c                	ld	a5,0(a0)
ffffffffc0201d56:	078a                	slli	a5,a5,0x2
ffffffffc0201d58:	8ff5                	and	a5,a5,a3
ffffffffc0201d5a:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201d5e:	58c77963          	bleu	a2,a4,ffffffffc02022f0 <pmm_init+0x78a>
ffffffffc0201d62:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d66:	97e2                	add	a5,a5,s8
ffffffffc0201d68:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201d6c:	0b0a                	slli	s6,s6,0x2
ffffffffc0201d6e:	00db7b33          	and	s6,s6,a3
ffffffffc0201d72:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201d76:	56c7f063          	bleu	a2,a5,ffffffffc02022d6 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d7a:	4601                	li	a2,0
ffffffffc0201d7c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d7e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d80:	a3dff0ef          	jal	ra,ffffffffc02017bc <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d84:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d86:	53651863          	bne	a0,s6,ffffffffc02022b6 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc0201d8a:	4505                	li	a0,1
ffffffffc0201d8c:	923ff0ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0201d90:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d92:	6008                	ld	a0,0(s0)
ffffffffc0201d94:	46d1                	li	a3,20
ffffffffc0201d96:	6605                	lui	a2,0x1
ffffffffc0201d98:	85da                	mv	a1,s6
ffffffffc0201d9a:	cfbff0ef          	jal	ra,ffffffffc0201a94 <page_insert>
ffffffffc0201d9e:	4e051c63          	bnez	a0,ffffffffc0202296 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201da2:	6008                	ld	a0,0(s0)
ffffffffc0201da4:	4601                	li	a2,0
ffffffffc0201da6:	6585                	lui	a1,0x1
ffffffffc0201da8:	a15ff0ef          	jal	ra,ffffffffc02017bc <get_pte>
ffffffffc0201dac:	4c050563          	beqz	a0,ffffffffc0202276 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc0201db0:	611c                	ld	a5,0(a0)
ffffffffc0201db2:	0107f713          	andi	a4,a5,16
ffffffffc0201db6:	4a070063          	beqz	a4,ffffffffc0202256 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0201dba:	8b91                	andi	a5,a5,4
ffffffffc0201dbc:	66078763          	beqz	a5,ffffffffc020242a <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201dc0:	6008                	ld	a0,0(s0)
ffffffffc0201dc2:	611c                	ld	a5,0(a0)
ffffffffc0201dc4:	8bc1                	andi	a5,a5,16
ffffffffc0201dc6:	64078263          	beqz	a5,ffffffffc020240a <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201dca:	000b2783          	lw	a5,0(s6)
ffffffffc0201dce:	61779e63          	bne	a5,s7,ffffffffc02023ea <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201dd2:	4681                	li	a3,0
ffffffffc0201dd4:	6605                	lui	a2,0x1
ffffffffc0201dd6:	85d6                	mv	a1,s5
ffffffffc0201dd8:	cbdff0ef          	jal	ra,ffffffffc0201a94 <page_insert>
ffffffffc0201ddc:	5e051763          	bnez	a0,ffffffffc02023ca <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc0201de0:	000aa703          	lw	a4,0(s5)
ffffffffc0201de4:	4789                	li	a5,2
ffffffffc0201de6:	5cf71263          	bne	a4,a5,ffffffffc02023aa <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201dea:	000b2783          	lw	a5,0(s6)
ffffffffc0201dee:	58079e63          	bnez	a5,ffffffffc020238a <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201df2:	6008                	ld	a0,0(s0)
ffffffffc0201df4:	4601                	li	a2,0
ffffffffc0201df6:	6585                	lui	a1,0x1
ffffffffc0201df8:	9c5ff0ef          	jal	ra,ffffffffc02017bc <get_pte>
ffffffffc0201dfc:	56050763          	beqz	a0,ffffffffc020236a <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc0201e00:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201e02:	0016f793          	andi	a5,a3,1
ffffffffc0201e06:	38078063          	beqz	a5,ffffffffc0202186 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201e0a:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201e0c:	00269793          	slli	a5,a3,0x2
ffffffffc0201e10:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e12:	34e7fc63          	bleu	a4,a5,ffffffffc020216a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e16:	fff80737          	lui	a4,0xfff80
ffffffffc0201e1a:	97ba                	add	a5,a5,a4
ffffffffc0201e1c:	00379713          	slli	a4,a5,0x3
ffffffffc0201e20:	00093603          	ld	a2,0(s2)
ffffffffc0201e24:	97ba                	add	a5,a5,a4
ffffffffc0201e26:	078e                	slli	a5,a5,0x3
ffffffffc0201e28:	97b2                	add	a5,a5,a2
ffffffffc0201e2a:	52fa9063          	bne	s5,a5,ffffffffc020234a <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201e2e:	8ac1                	andi	a3,a3,16
ffffffffc0201e30:	6e069d63          	bnez	a3,ffffffffc020252a <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201e34:	6008                	ld	a0,0(s0)
ffffffffc0201e36:	4581                	li	a1,0
ffffffffc0201e38:	bebff0ef          	jal	ra,ffffffffc0201a22 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201e3c:	000aa703          	lw	a4,0(s5)
ffffffffc0201e40:	4785                	li	a5,1
ffffffffc0201e42:	6cf71463          	bne	a4,a5,ffffffffc020250a <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0201e46:	000b2783          	lw	a5,0(s6)
ffffffffc0201e4a:	6a079063          	bnez	a5,ffffffffc02024ea <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e4e:	6008                	ld	a0,0(s0)
ffffffffc0201e50:	6585                	lui	a1,0x1
ffffffffc0201e52:	bd1ff0ef          	jal	ra,ffffffffc0201a22 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e56:	000aa783          	lw	a5,0(s5)
ffffffffc0201e5a:	66079863          	bnez	a5,ffffffffc02024ca <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc0201e5e:	000b2783          	lw	a5,0(s6)
ffffffffc0201e62:	70079463          	bnez	a5,ffffffffc020256a <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e66:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201e6a:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e6c:	000b3783          	ld	a5,0(s6)
ffffffffc0201e70:	078a                	slli	a5,a5,0x2
ffffffffc0201e72:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e74:	2eb7fb63          	bleu	a1,a5,ffffffffc020216a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e78:	fff80737          	lui	a4,0xfff80
ffffffffc0201e7c:	973e                	add	a4,a4,a5
ffffffffc0201e7e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e82:	00093603          	ld	a2,0(s2)
ffffffffc0201e86:	97ba                	add	a5,a5,a4
ffffffffc0201e88:	078e                	slli	a5,a5,0x3
ffffffffc0201e8a:	00f60733          	add	a4,a2,a5
ffffffffc0201e8e:	4314                	lw	a3,0(a4)
ffffffffc0201e90:	4705                	li	a4,1
ffffffffc0201e92:	6ae69c63          	bne	a3,a4,ffffffffc020254a <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e96:	00003a97          	auipc	s5,0x3
ffffffffc0201e9a:	c9aa8a93          	addi	s5,s5,-870 # ffffffffc0204b30 <commands+0x8c0>
ffffffffc0201e9e:	000ab703          	ld	a4,0(s5)
ffffffffc0201ea2:	4037d693          	srai	a3,a5,0x3
ffffffffc0201ea6:	00080bb7          	lui	s7,0x80
ffffffffc0201eaa:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201eae:	577d                	li	a4,-1
ffffffffc0201eb0:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201eb2:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201eb4:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201eb6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201eb8:	2ab77b63          	bleu	a1,a4,ffffffffc020216e <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201ebc:	0009b783          	ld	a5,0(s3)
ffffffffc0201ec0:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ec2:	629c                	ld	a5,0(a3)
ffffffffc0201ec4:	078a                	slli	a5,a5,0x2
ffffffffc0201ec6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ec8:	2ab7f163          	bleu	a1,a5,ffffffffc020216a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ecc:	417787b3          	sub	a5,a5,s7
ffffffffc0201ed0:	00379513          	slli	a0,a5,0x3
ffffffffc0201ed4:	97aa                	add	a5,a5,a0
ffffffffc0201ed6:	00379513          	slli	a0,a5,0x3
ffffffffc0201eda:	9532                	add	a0,a0,a2
ffffffffc0201edc:	4585                	li	a1,1
ffffffffc0201ede:	859ff0ef          	jal	ra,ffffffffc0201736 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ee2:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201ee6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ee8:	050a                	slli	a0,a0,0x2
ffffffffc0201eea:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201eec:	26f57f63          	bleu	a5,a0,ffffffffc020216a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ef0:	417507b3          	sub	a5,a0,s7
ffffffffc0201ef4:	00379513          	slli	a0,a5,0x3
ffffffffc0201ef8:	00093703          	ld	a4,0(s2)
ffffffffc0201efc:	953e                	add	a0,a0,a5
ffffffffc0201efe:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201f00:	4585                	li	a1,1
ffffffffc0201f02:	953a                	add	a0,a0,a4
ffffffffc0201f04:	833ff0ef          	jal	ra,ffffffffc0201736 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201f08:	601c                	ld	a5,0(s0)
ffffffffc0201f0a:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201f0e:	86fff0ef          	jal	ra,ffffffffc020177c <nr_free_pages>
ffffffffc0201f12:	2caa1663          	bne	s4,a0,ffffffffc02021de <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201f16:	00003517          	auipc	a0,0x3
ffffffffc0201f1a:	49a50513          	addi	a0,a0,1178 # ffffffffc02053b0 <default_pmm_manager+0x4d0>
ffffffffc0201f1e:	9aafe0ef          	jal	ra,ffffffffc02000c8 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201f22:	85bff0ef          	jal	ra,ffffffffc020177c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f26:	6098                	ld	a4,0(s1)
ffffffffc0201f28:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201f2c:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f2e:	00c71693          	slli	a3,a4,0xc
ffffffffc0201f32:	1cd7fd63          	bleu	a3,a5,ffffffffc020210c <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f36:	83b1                	srli	a5,a5,0xc
ffffffffc0201f38:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f3a:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f3e:	1ce7f963          	bleu	a4,a5,ffffffffc0202110 <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f42:	7c7d                	lui	s8,0xfffff
ffffffffc0201f44:	6b85                	lui	s7,0x1
ffffffffc0201f46:	a029                	j	ffffffffc0201f50 <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f48:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201f4c:	1cf77263          	bleu	a5,a4,ffffffffc0202110 <pmm_init+0x5aa>
ffffffffc0201f50:	0009b583          	ld	a1,0(s3)
ffffffffc0201f54:	4601                	li	a2,0
ffffffffc0201f56:	95d2                	add	a1,a1,s4
ffffffffc0201f58:	865ff0ef          	jal	ra,ffffffffc02017bc <get_pte>
ffffffffc0201f5c:	1c050763          	beqz	a0,ffffffffc020212a <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f60:	611c                	ld	a5,0(a0)
ffffffffc0201f62:	078a                	slli	a5,a5,0x2
ffffffffc0201f64:	0187f7b3          	and	a5,a5,s8
ffffffffc0201f68:	1f479163          	bne	a5,s4,ffffffffc020214a <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f6c:	609c                	ld	a5,0(s1)
ffffffffc0201f6e:	9a5e                	add	s4,s4,s7
ffffffffc0201f70:	6008                	ld	a0,0(s0)
ffffffffc0201f72:	00c79713          	slli	a4,a5,0xc
ffffffffc0201f76:	fcea69e3          	bltu	s4,a4,ffffffffc0201f48 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f7a:	611c                	ld	a5,0(a0)
ffffffffc0201f7c:	6a079363          	bnez	a5,ffffffffc0202622 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f80:	4505                	li	a0,1
ffffffffc0201f82:	f2cff0ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0201f86:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f88:	6008                	ld	a0,0(s0)
ffffffffc0201f8a:	4699                	li	a3,6
ffffffffc0201f8c:	10000613          	li	a2,256
ffffffffc0201f90:	85d2                	mv	a1,s4
ffffffffc0201f92:	b03ff0ef          	jal	ra,ffffffffc0201a94 <page_insert>
ffffffffc0201f96:	66051663          	bnez	a0,ffffffffc0202602 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0201f9a:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201f9e:	4785                	li	a5,1
ffffffffc0201fa0:	64f71163          	bne	a4,a5,ffffffffc02025e2 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201fa4:	6008                	ld	a0,0(s0)
ffffffffc0201fa6:	6b85                	lui	s7,0x1
ffffffffc0201fa8:	4699                	li	a3,6
ffffffffc0201faa:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201fae:	85d2                	mv	a1,s4
ffffffffc0201fb0:	ae5ff0ef          	jal	ra,ffffffffc0201a94 <page_insert>
ffffffffc0201fb4:	60051763          	bnez	a0,ffffffffc02025c2 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0201fb8:	000a2703          	lw	a4,0(s4)
ffffffffc0201fbc:	4789                	li	a5,2
ffffffffc0201fbe:	4ef71663          	bne	a4,a5,ffffffffc02024aa <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201fc2:	00003597          	auipc	a1,0x3
ffffffffc0201fc6:	52658593          	addi	a1,a1,1318 # ffffffffc02054e8 <default_pmm_manager+0x608>
ffffffffc0201fca:	10000513          	li	a0,256
ffffffffc0201fce:	0f6020ef          	jal	ra,ffffffffc02040c4 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201fd2:	100b8593          	addi	a1,s7,256
ffffffffc0201fd6:	10000513          	li	a0,256
ffffffffc0201fda:	0fc020ef          	jal	ra,ffffffffc02040d6 <strcmp>
ffffffffc0201fde:	4a051663          	bnez	a0,ffffffffc020248a <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fe2:	00093683          	ld	a3,0(s2)
ffffffffc0201fe6:	000abc83          	ld	s9,0(s5)
ffffffffc0201fea:	00080c37          	lui	s8,0x80
ffffffffc0201fee:	40da06b3          	sub	a3,s4,a3
ffffffffc0201ff2:	868d                	srai	a3,a3,0x3
ffffffffc0201ff4:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ff8:	5afd                	li	s5,-1
ffffffffc0201ffa:	609c                	ld	a5,0(s1)
ffffffffc0201ffc:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202000:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202002:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202006:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202008:	16f77363          	bleu	a5,a4,ffffffffc020216e <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020200c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202010:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202014:	96be                	add	a3,a3,a5
ffffffffc0202016:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdeea70>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020201a:	066020ef          	jal	ra,ffffffffc0204080 <strlen>
ffffffffc020201e:	44051663          	bnez	a0,ffffffffc020246a <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202022:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202026:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202028:	000bb783          	ld	a5,0(s7)
ffffffffc020202c:	078a                	slli	a5,a5,0x2
ffffffffc020202e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202030:	12e7fd63          	bleu	a4,a5,ffffffffc020216a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202034:	418787b3          	sub	a5,a5,s8
ffffffffc0202038:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020203c:	96be                	add	a3,a3,a5
ffffffffc020203e:	039686b3          	mul	a3,a3,s9
ffffffffc0202042:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202044:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202048:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020204a:	12eaf263          	bleu	a4,s5,ffffffffc020216e <pmm_init+0x608>
ffffffffc020204e:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202052:	4585                	li	a1,1
ffffffffc0202054:	8552                	mv	a0,s4
ffffffffc0202056:	99b6                	add	s3,s3,a3
ffffffffc0202058:	edeff0ef          	jal	ra,ffffffffc0201736 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020205c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202060:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202062:	078a                	slli	a5,a5,0x2
ffffffffc0202064:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202066:	10e7f263          	bleu	a4,a5,ffffffffc020216a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020206a:	fff809b7          	lui	s3,0xfff80
ffffffffc020206e:	97ce                	add	a5,a5,s3
ffffffffc0202070:	00379513          	slli	a0,a5,0x3
ffffffffc0202074:	00093703          	ld	a4,0(s2)
ffffffffc0202078:	97aa                	add	a5,a5,a0
ffffffffc020207a:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020207e:	953a                	add	a0,a0,a4
ffffffffc0202080:	4585                	li	a1,1
ffffffffc0202082:	eb4ff0ef          	jal	ra,ffffffffc0201736 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202086:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020208a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020208c:	050a                	slli	a0,a0,0x2
ffffffffc020208e:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202090:	0cf57d63          	bleu	a5,a0,ffffffffc020216a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202094:	013507b3          	add	a5,a0,s3
ffffffffc0202098:	00379513          	slli	a0,a5,0x3
ffffffffc020209c:	00093703          	ld	a4,0(s2)
ffffffffc02020a0:	953e                	add	a0,a0,a5
ffffffffc02020a2:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc02020a4:	4585                	li	a1,1
ffffffffc02020a6:	953a                	add	a0,a0,a4
ffffffffc02020a8:	e8eff0ef          	jal	ra,ffffffffc0201736 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02020ac:	601c                	ld	a5,0(s0)
ffffffffc02020ae:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc02020b2:	ecaff0ef          	jal	ra,ffffffffc020177c <nr_free_pages>
ffffffffc02020b6:	38ab1a63          	bne	s6,a0,ffffffffc020244a <pmm_init+0x8e4>
}
ffffffffc02020ba:	6446                	ld	s0,80(sp)
ffffffffc02020bc:	60e6                	ld	ra,88(sp)
ffffffffc02020be:	64a6                	ld	s1,72(sp)
ffffffffc02020c0:	6906                	ld	s2,64(sp)
ffffffffc02020c2:	79e2                	ld	s3,56(sp)
ffffffffc02020c4:	7a42                	ld	s4,48(sp)
ffffffffc02020c6:	7aa2                	ld	s5,40(sp)
ffffffffc02020c8:	7b02                	ld	s6,32(sp)
ffffffffc02020ca:	6be2                	ld	s7,24(sp)
ffffffffc02020cc:	6c42                	ld	s8,16(sp)
ffffffffc02020ce:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020d0:	00003517          	auipc	a0,0x3
ffffffffc02020d4:	49050513          	addi	a0,a0,1168 # ffffffffc0205560 <default_pmm_manager+0x680>
}
ffffffffc02020d8:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020da:	feffd06f          	j	ffffffffc02000c8 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020de:	6705                	lui	a4,0x1
ffffffffc02020e0:	177d                	addi	a4,a4,-1
ffffffffc02020e2:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02020e4:	00c6d713          	srli	a4,a3,0xc
ffffffffc02020e8:	08f77163          	bleu	a5,a4,ffffffffc020216a <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc02020ec:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc02020f0:	9732                	add	a4,a4,a2
ffffffffc02020f2:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020f6:	767d                	lui	a2,0xfffff
ffffffffc02020f8:	8ef1                	and	a3,a3,a2
ffffffffc02020fa:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc02020fc:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202100:	8d95                	sub	a1,a1,a3
ffffffffc0202102:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0202104:	81b1                	srli	a1,a1,0xc
ffffffffc0202106:	953e                	add	a0,a0,a5
ffffffffc0202108:	9702                	jalr	a4
ffffffffc020210a:	bead                	j	ffffffffc0201c84 <pmm_init+0x11e>
ffffffffc020210c:	6008                	ld	a0,0(s0)
ffffffffc020210e:	b5b5                	j	ffffffffc0201f7a <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202110:	86d2                	mv	a3,s4
ffffffffc0202112:	00003617          	auipc	a2,0x3
ffffffffc0202116:	e1e60613          	addi	a2,a2,-482 # ffffffffc0204f30 <default_pmm_manager+0x50>
ffffffffc020211a:	1cd00593          	li	a1,461
ffffffffc020211e:	00003517          	auipc	a0,0x3
ffffffffc0202122:	e3a50513          	addi	a0,a0,-454 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202126:	a58fe0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc020212a:	00003697          	auipc	a3,0x3
ffffffffc020212e:	2a668693          	addi	a3,a3,678 # ffffffffc02053d0 <default_pmm_manager+0x4f0>
ffffffffc0202132:	00003617          	auipc	a2,0x3
ffffffffc0202136:	a1660613          	addi	a2,a2,-1514 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020213a:	1cd00593          	li	a1,461
ffffffffc020213e:	00003517          	auipc	a0,0x3
ffffffffc0202142:	e1a50513          	addi	a0,a0,-486 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202146:	a38fe0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020214a:	00003697          	auipc	a3,0x3
ffffffffc020214e:	2c668693          	addi	a3,a3,710 # ffffffffc0205410 <default_pmm_manager+0x530>
ffffffffc0202152:	00003617          	auipc	a2,0x3
ffffffffc0202156:	9f660613          	addi	a2,a2,-1546 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020215a:	1ce00593          	li	a1,462
ffffffffc020215e:	00003517          	auipc	a0,0x3
ffffffffc0202162:	dfa50513          	addi	a0,a0,-518 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202166:	a18fe0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc020216a:	d28ff0ef          	jal	ra,ffffffffc0201692 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020216e:	00003617          	auipc	a2,0x3
ffffffffc0202172:	dc260613          	addi	a2,a2,-574 # ffffffffc0204f30 <default_pmm_manager+0x50>
ffffffffc0202176:	06a00593          	li	a1,106
ffffffffc020217a:	00003517          	auipc	a0,0x3
ffffffffc020217e:	e4e50513          	addi	a0,a0,-434 # ffffffffc0204fc8 <default_pmm_manager+0xe8>
ffffffffc0202182:	9fcfe0ef          	jal	ra,ffffffffc020037e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202186:	00003617          	auipc	a2,0x3
ffffffffc020218a:	01a60613          	addi	a2,a2,26 # ffffffffc02051a0 <default_pmm_manager+0x2c0>
ffffffffc020218e:	07000593          	li	a1,112
ffffffffc0202192:	00003517          	auipc	a0,0x3
ffffffffc0202196:	e3650513          	addi	a0,a0,-458 # ffffffffc0204fc8 <default_pmm_manager+0xe8>
ffffffffc020219a:	9e4fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020219e:	00003697          	auipc	a3,0x3
ffffffffc02021a2:	f4268693          	addi	a3,a3,-190 # ffffffffc02050e0 <default_pmm_manager+0x200>
ffffffffc02021a6:	00003617          	auipc	a2,0x3
ffffffffc02021aa:	9a260613          	addi	a2,a2,-1630 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02021ae:	19300593          	li	a1,403
ffffffffc02021b2:	00003517          	auipc	a0,0x3
ffffffffc02021b6:	da650513          	addi	a0,a0,-602 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02021ba:	9c4fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02021be:	00003697          	auipc	a3,0x3
ffffffffc02021c2:	f5a68693          	addi	a3,a3,-166 # ffffffffc0205118 <default_pmm_manager+0x238>
ffffffffc02021c6:	00003617          	auipc	a2,0x3
ffffffffc02021ca:	98260613          	addi	a2,a2,-1662 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02021ce:	19400593          	li	a1,404
ffffffffc02021d2:	00003517          	auipc	a0,0x3
ffffffffc02021d6:	d8650513          	addi	a0,a0,-634 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02021da:	9a4fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02021de:	00003697          	auipc	a3,0x3
ffffffffc02021e2:	1b268693          	addi	a3,a3,434 # ffffffffc0205390 <default_pmm_manager+0x4b0>
ffffffffc02021e6:	00003617          	auipc	a2,0x3
ffffffffc02021ea:	96260613          	addi	a2,a2,-1694 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02021ee:	1c000593          	li	a1,448
ffffffffc02021f2:	00003517          	auipc	a0,0x3
ffffffffc02021f6:	d6650513          	addi	a0,a0,-666 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02021fa:	984fe0ef          	jal	ra,ffffffffc020037e <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02021fe:	00003617          	auipc	a2,0x3
ffffffffc0202202:	e7a60613          	addi	a2,a2,-390 # ffffffffc0205078 <default_pmm_manager+0x198>
ffffffffc0202206:	07700593          	li	a1,119
ffffffffc020220a:	00003517          	auipc	a0,0x3
ffffffffc020220e:	d4e50513          	addi	a0,a0,-690 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202212:	96cfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202216:	00003697          	auipc	a3,0x3
ffffffffc020221a:	f5a68693          	addi	a3,a3,-166 # ffffffffc0205170 <default_pmm_manager+0x290>
ffffffffc020221e:	00003617          	auipc	a2,0x3
ffffffffc0202222:	92a60613          	addi	a2,a2,-1750 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202226:	19a00593          	li	a1,410
ffffffffc020222a:	00003517          	auipc	a0,0x3
ffffffffc020222e:	d2e50513          	addi	a0,a0,-722 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202232:	94cfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202236:	00003697          	auipc	a3,0x3
ffffffffc020223a:	f0a68693          	addi	a3,a3,-246 # ffffffffc0205140 <default_pmm_manager+0x260>
ffffffffc020223e:	00003617          	auipc	a2,0x3
ffffffffc0202242:	90a60613          	addi	a2,a2,-1782 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202246:	19800593          	li	a1,408
ffffffffc020224a:	00003517          	auipc	a0,0x3
ffffffffc020224e:	d0e50513          	addi	a0,a0,-754 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202252:	92cfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202256:	00003697          	auipc	a3,0x3
ffffffffc020225a:	03268693          	addi	a3,a3,50 # ffffffffc0205288 <default_pmm_manager+0x3a8>
ffffffffc020225e:	00003617          	auipc	a2,0x3
ffffffffc0202262:	8ea60613          	addi	a2,a2,-1814 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202266:	1a500593          	li	a1,421
ffffffffc020226a:	00003517          	auipc	a0,0x3
ffffffffc020226e:	cee50513          	addi	a0,a0,-786 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202272:	90cfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202276:	00003697          	auipc	a3,0x3
ffffffffc020227a:	fe268693          	addi	a3,a3,-30 # ffffffffc0205258 <default_pmm_manager+0x378>
ffffffffc020227e:	00003617          	auipc	a2,0x3
ffffffffc0202282:	8ca60613          	addi	a2,a2,-1846 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202286:	1a400593          	li	a1,420
ffffffffc020228a:	00003517          	auipc	a0,0x3
ffffffffc020228e:	cce50513          	addi	a0,a0,-818 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202292:	8ecfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202296:	00003697          	auipc	a3,0x3
ffffffffc020229a:	f8a68693          	addi	a3,a3,-118 # ffffffffc0205220 <default_pmm_manager+0x340>
ffffffffc020229e:	00003617          	auipc	a2,0x3
ffffffffc02022a2:	8aa60613          	addi	a2,a2,-1878 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02022a6:	1a300593          	li	a1,419
ffffffffc02022aa:	00003517          	auipc	a0,0x3
ffffffffc02022ae:	cae50513          	addi	a0,a0,-850 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02022b2:	8ccfe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02022b6:	00003697          	auipc	a3,0x3
ffffffffc02022ba:	f4268693          	addi	a3,a3,-190 # ffffffffc02051f8 <default_pmm_manager+0x318>
ffffffffc02022be:	00003617          	auipc	a2,0x3
ffffffffc02022c2:	88a60613          	addi	a2,a2,-1910 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02022c6:	1a000593          	li	a1,416
ffffffffc02022ca:	00003517          	auipc	a0,0x3
ffffffffc02022ce:	c8e50513          	addi	a0,a0,-882 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02022d2:	8acfe0ef          	jal	ra,ffffffffc020037e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022d6:	86da                	mv	a3,s6
ffffffffc02022d8:	00003617          	auipc	a2,0x3
ffffffffc02022dc:	c5860613          	addi	a2,a2,-936 # ffffffffc0204f30 <default_pmm_manager+0x50>
ffffffffc02022e0:	19f00593          	li	a1,415
ffffffffc02022e4:	00003517          	auipc	a0,0x3
ffffffffc02022e8:	c7450513          	addi	a0,a0,-908 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02022ec:	892fe0ef          	jal	ra,ffffffffc020037e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02022f0:	86be                	mv	a3,a5
ffffffffc02022f2:	00003617          	auipc	a2,0x3
ffffffffc02022f6:	c3e60613          	addi	a2,a2,-962 # ffffffffc0204f30 <default_pmm_manager+0x50>
ffffffffc02022fa:	19e00593          	li	a1,414
ffffffffc02022fe:	00003517          	auipc	a0,0x3
ffffffffc0202302:	c5a50513          	addi	a0,a0,-934 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202306:	878fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020230a:	00003697          	auipc	a3,0x3
ffffffffc020230e:	ed668693          	addi	a3,a3,-298 # ffffffffc02051e0 <default_pmm_manager+0x300>
ffffffffc0202312:	00003617          	auipc	a2,0x3
ffffffffc0202316:	83660613          	addi	a2,a2,-1994 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020231a:	19c00593          	li	a1,412
ffffffffc020231e:	00003517          	auipc	a0,0x3
ffffffffc0202322:	c3a50513          	addi	a0,a0,-966 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202326:	858fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020232a:	00003697          	auipc	a3,0x3
ffffffffc020232e:	e9e68693          	addi	a3,a3,-354 # ffffffffc02051c8 <default_pmm_manager+0x2e8>
ffffffffc0202332:	00003617          	auipc	a2,0x3
ffffffffc0202336:	81660613          	addi	a2,a2,-2026 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020233a:	19b00593          	li	a1,411
ffffffffc020233e:	00003517          	auipc	a0,0x3
ffffffffc0202342:	c1a50513          	addi	a0,a0,-998 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202346:	838fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020234a:	00003697          	auipc	a3,0x3
ffffffffc020234e:	e7e68693          	addi	a3,a3,-386 # ffffffffc02051c8 <default_pmm_manager+0x2e8>
ffffffffc0202352:	00002617          	auipc	a2,0x2
ffffffffc0202356:	7f660613          	addi	a2,a2,2038 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020235a:	1ae00593          	li	a1,430
ffffffffc020235e:	00003517          	auipc	a0,0x3
ffffffffc0202362:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202366:	818fe0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020236a:	00003697          	auipc	a3,0x3
ffffffffc020236e:	eee68693          	addi	a3,a3,-274 # ffffffffc0205258 <default_pmm_manager+0x378>
ffffffffc0202372:	00002617          	auipc	a2,0x2
ffffffffc0202376:	7d660613          	addi	a2,a2,2006 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020237a:	1ad00593          	li	a1,429
ffffffffc020237e:	00003517          	auipc	a0,0x3
ffffffffc0202382:	bda50513          	addi	a0,a0,-1062 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202386:	ff9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020238a:	00003697          	auipc	a3,0x3
ffffffffc020238e:	f9668693          	addi	a3,a3,-106 # ffffffffc0205320 <default_pmm_manager+0x440>
ffffffffc0202392:	00002617          	auipc	a2,0x2
ffffffffc0202396:	7b660613          	addi	a2,a2,1974 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020239a:	1ac00593          	li	a1,428
ffffffffc020239e:	00003517          	auipc	a0,0x3
ffffffffc02023a2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02023a6:	fd9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02023aa:	00003697          	auipc	a3,0x3
ffffffffc02023ae:	f5e68693          	addi	a3,a3,-162 # ffffffffc0205308 <default_pmm_manager+0x428>
ffffffffc02023b2:	00002617          	auipc	a2,0x2
ffffffffc02023b6:	79660613          	addi	a2,a2,1942 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02023ba:	1ab00593          	li	a1,427
ffffffffc02023be:	00003517          	auipc	a0,0x3
ffffffffc02023c2:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02023c6:	fb9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02023ca:	00003697          	auipc	a3,0x3
ffffffffc02023ce:	f0e68693          	addi	a3,a3,-242 # ffffffffc02052d8 <default_pmm_manager+0x3f8>
ffffffffc02023d2:	00002617          	auipc	a2,0x2
ffffffffc02023d6:	77660613          	addi	a2,a2,1910 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02023da:	1aa00593          	li	a1,426
ffffffffc02023de:	00003517          	auipc	a0,0x3
ffffffffc02023e2:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02023e6:	f99fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02023ea:	00003697          	auipc	a3,0x3
ffffffffc02023ee:	ed668693          	addi	a3,a3,-298 # ffffffffc02052c0 <default_pmm_manager+0x3e0>
ffffffffc02023f2:	00002617          	auipc	a2,0x2
ffffffffc02023f6:	75660613          	addi	a2,a2,1878 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02023fa:	1a800593          	li	a1,424
ffffffffc02023fe:	00003517          	auipc	a0,0x3
ffffffffc0202402:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202406:	f79fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020240a:	00003697          	auipc	a3,0x3
ffffffffc020240e:	e9e68693          	addi	a3,a3,-354 # ffffffffc02052a8 <default_pmm_manager+0x3c8>
ffffffffc0202412:	00002617          	auipc	a2,0x2
ffffffffc0202416:	73660613          	addi	a2,a2,1846 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020241a:	1a700593          	li	a1,423
ffffffffc020241e:	00003517          	auipc	a0,0x3
ffffffffc0202422:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202426:	f59fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(*ptep & PTE_W);
ffffffffc020242a:	00003697          	auipc	a3,0x3
ffffffffc020242e:	e6e68693          	addi	a3,a3,-402 # ffffffffc0205298 <default_pmm_manager+0x3b8>
ffffffffc0202432:	00002617          	auipc	a2,0x2
ffffffffc0202436:	71660613          	addi	a2,a2,1814 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020243a:	1a600593          	li	a1,422
ffffffffc020243e:	00003517          	auipc	a0,0x3
ffffffffc0202442:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202446:	f39fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020244a:	00003697          	auipc	a3,0x3
ffffffffc020244e:	f4668693          	addi	a3,a3,-186 # ffffffffc0205390 <default_pmm_manager+0x4b0>
ffffffffc0202452:	00002617          	auipc	a2,0x2
ffffffffc0202456:	6f660613          	addi	a2,a2,1782 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020245a:	1e800593          	li	a1,488
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	afa50513          	addi	a0,a0,-1286 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202466:	f19fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020246a:	00003697          	auipc	a3,0x3
ffffffffc020246e:	0ce68693          	addi	a3,a3,206 # ffffffffc0205538 <default_pmm_manager+0x658>
ffffffffc0202472:	00002617          	auipc	a2,0x2
ffffffffc0202476:	6d660613          	addi	a2,a2,1750 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020247a:	1e000593          	li	a1,480
ffffffffc020247e:	00003517          	auipc	a0,0x3
ffffffffc0202482:	ada50513          	addi	a0,a0,-1318 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202486:	ef9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020248a:	00003697          	auipc	a3,0x3
ffffffffc020248e:	07668693          	addi	a3,a3,118 # ffffffffc0205500 <default_pmm_manager+0x620>
ffffffffc0202492:	00002617          	auipc	a2,0x2
ffffffffc0202496:	6b660613          	addi	a2,a2,1718 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020249a:	1dd00593          	li	a1,477
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	aba50513          	addi	a0,a0,-1350 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02024a6:	ed9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p) == 2);
ffffffffc02024aa:	00003697          	auipc	a3,0x3
ffffffffc02024ae:	02668693          	addi	a3,a3,38 # ffffffffc02054d0 <default_pmm_manager+0x5f0>
ffffffffc02024b2:	00002617          	auipc	a2,0x2
ffffffffc02024b6:	69660613          	addi	a2,a2,1686 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02024ba:	1d900593          	li	a1,473
ffffffffc02024be:	00003517          	auipc	a0,0x3
ffffffffc02024c2:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02024c6:	eb9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02024ca:	00003697          	auipc	a3,0x3
ffffffffc02024ce:	e8668693          	addi	a3,a3,-378 # ffffffffc0205350 <default_pmm_manager+0x470>
ffffffffc02024d2:	00002617          	auipc	a2,0x2
ffffffffc02024d6:	67660613          	addi	a2,a2,1654 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02024da:	1b600593          	li	a1,438
ffffffffc02024de:	00003517          	auipc	a0,0x3
ffffffffc02024e2:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02024e6:	e99fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024ea:	00003697          	auipc	a3,0x3
ffffffffc02024ee:	e3668693          	addi	a3,a3,-458 # ffffffffc0205320 <default_pmm_manager+0x440>
ffffffffc02024f2:	00002617          	auipc	a2,0x2
ffffffffc02024f6:	65660613          	addi	a2,a2,1622 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02024fa:	1b300593          	li	a1,435
ffffffffc02024fe:	00003517          	auipc	a0,0x3
ffffffffc0202502:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202506:	e79fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020250a:	00003697          	auipc	a3,0x3
ffffffffc020250e:	cd668693          	addi	a3,a3,-810 # ffffffffc02051e0 <default_pmm_manager+0x300>
ffffffffc0202512:	00002617          	auipc	a2,0x2
ffffffffc0202516:	63660613          	addi	a2,a2,1590 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020251a:	1b200593          	li	a1,434
ffffffffc020251e:	00003517          	auipc	a0,0x3
ffffffffc0202522:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202526:	e59fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020252a:	00003697          	auipc	a3,0x3
ffffffffc020252e:	e0e68693          	addi	a3,a3,-498 # ffffffffc0205338 <default_pmm_manager+0x458>
ffffffffc0202532:	00002617          	auipc	a2,0x2
ffffffffc0202536:	61660613          	addi	a2,a2,1558 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020253a:	1af00593          	li	a1,431
ffffffffc020253e:	00003517          	auipc	a0,0x3
ffffffffc0202542:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202546:	e39fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020254a:	00003697          	auipc	a3,0x3
ffffffffc020254e:	e1e68693          	addi	a3,a3,-482 # ffffffffc0205368 <default_pmm_manager+0x488>
ffffffffc0202552:	00002617          	auipc	a2,0x2
ffffffffc0202556:	5f660613          	addi	a2,a2,1526 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020255a:	1b900593          	li	a1,441
ffffffffc020255e:	00003517          	auipc	a0,0x3
ffffffffc0202562:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202566:	e19fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020256a:	00003697          	auipc	a3,0x3
ffffffffc020256e:	db668693          	addi	a3,a3,-586 # ffffffffc0205320 <default_pmm_manager+0x440>
ffffffffc0202572:	00002617          	auipc	a2,0x2
ffffffffc0202576:	5d660613          	addi	a2,a2,1494 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020257a:	1b700593          	li	a1,439
ffffffffc020257e:	00003517          	auipc	a0,0x3
ffffffffc0202582:	9da50513          	addi	a0,a0,-1574 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202586:	df9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020258a:	00003697          	auipc	a3,0x3
ffffffffc020258e:	b3668693          	addi	a3,a3,-1226 # ffffffffc02050c0 <default_pmm_manager+0x1e0>
ffffffffc0202592:	00002617          	auipc	a2,0x2
ffffffffc0202596:	5b660613          	addi	a2,a2,1462 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020259a:	19200593          	li	a1,402
ffffffffc020259e:	00003517          	auipc	a0,0x3
ffffffffc02025a2:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02025a6:	dd9fd0ef          	jal	ra,ffffffffc020037e <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02025aa:	00003617          	auipc	a2,0x3
ffffffffc02025ae:	ace60613          	addi	a2,a2,-1330 # ffffffffc0205078 <default_pmm_manager+0x198>
ffffffffc02025b2:	0bd00593          	li	a1,189
ffffffffc02025b6:	00003517          	auipc	a0,0x3
ffffffffc02025ba:	9a250513          	addi	a0,a0,-1630 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02025be:	dc1fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02025c2:	00003697          	auipc	a3,0x3
ffffffffc02025c6:	ece68693          	addi	a3,a3,-306 # ffffffffc0205490 <default_pmm_manager+0x5b0>
ffffffffc02025ca:	00002617          	auipc	a2,0x2
ffffffffc02025ce:	57e60613          	addi	a2,a2,1406 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02025d2:	1d800593          	li	a1,472
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	98250513          	addi	a0,a0,-1662 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02025de:	da1fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_ref(p) == 1);
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	e9668693          	addi	a3,a3,-362 # ffffffffc0205478 <default_pmm_manager+0x598>
ffffffffc02025ea:	00002617          	auipc	a2,0x2
ffffffffc02025ee:	55e60613          	addi	a2,a2,1374 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02025f2:	1d700593          	li	a1,471
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	96250513          	addi	a0,a0,-1694 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02025fe:	d81fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202602:	00003697          	auipc	a3,0x3
ffffffffc0202606:	e3e68693          	addi	a3,a3,-450 # ffffffffc0205440 <default_pmm_manager+0x560>
ffffffffc020260a:	00002617          	auipc	a2,0x2
ffffffffc020260e:	53e60613          	addi	a2,a2,1342 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202612:	1d600593          	li	a1,470
ffffffffc0202616:	00003517          	auipc	a0,0x3
ffffffffc020261a:	94250513          	addi	a0,a0,-1726 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc020261e:	d61fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202622:	00003697          	auipc	a3,0x3
ffffffffc0202626:	e0668693          	addi	a3,a3,-506 # ffffffffc0205428 <default_pmm_manager+0x548>
ffffffffc020262a:	00002617          	auipc	a2,0x2
ffffffffc020262e:	51e60613          	addi	a2,a2,1310 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202632:	1d200593          	li	a1,466
ffffffffc0202636:	00003517          	auipc	a0,0x3
ffffffffc020263a:	92250513          	addi	a0,a0,-1758 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc020263e:	d41fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0202642 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202642:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0202646:	8082                	ret

ffffffffc0202648 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202648:	7179                	addi	sp,sp,-48
ffffffffc020264a:	e84a                	sd	s2,16(sp)
ffffffffc020264c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020264e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202650:	f022                	sd	s0,32(sp)
ffffffffc0202652:	ec26                	sd	s1,24(sp)
ffffffffc0202654:	e44e                	sd	s3,8(sp)
ffffffffc0202656:	f406                	sd	ra,40(sp)
ffffffffc0202658:	84ae                	mv	s1,a1
ffffffffc020265a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020265c:	852ff0ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc0202660:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202662:	cd19                	beqz	a0,ffffffffc0202680 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202664:	85aa                	mv	a1,a0
ffffffffc0202666:	86ce                	mv	a3,s3
ffffffffc0202668:	8626                	mv	a2,s1
ffffffffc020266a:	854a                	mv	a0,s2
ffffffffc020266c:	c28ff0ef          	jal	ra,ffffffffc0201a94 <page_insert>
ffffffffc0202670:	ed39                	bnez	a0,ffffffffc02026ce <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202672:	0000e797          	auipc	a5,0xe
ffffffffc0202676:	dfe78793          	addi	a5,a5,-514 # ffffffffc0210470 <swap_init_ok>
ffffffffc020267a:	439c                	lw	a5,0(a5)
ffffffffc020267c:	2781                	sext.w	a5,a5
ffffffffc020267e:	eb89                	bnez	a5,ffffffffc0202690 <pgdir_alloc_page+0x48>
}
ffffffffc0202680:	8522                	mv	a0,s0
ffffffffc0202682:	70a2                	ld	ra,40(sp)
ffffffffc0202684:	7402                	ld	s0,32(sp)
ffffffffc0202686:	64e2                	ld	s1,24(sp)
ffffffffc0202688:	6942                	ld	s2,16(sp)
ffffffffc020268a:	69a2                	ld	s3,8(sp)
ffffffffc020268c:	6145                	addi	sp,sp,48
ffffffffc020268e:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202690:	0000e797          	auipc	a5,0xe
ffffffffc0202694:	ff878793          	addi	a5,a5,-8 # ffffffffc0210688 <check_mm_struct>
ffffffffc0202698:	6388                	ld	a0,0(a5)
ffffffffc020269a:	4681                	li	a3,0
ffffffffc020269c:	8622                	mv	a2,s0
ffffffffc020269e:	85a6                	mv	a1,s1
ffffffffc02026a0:	06d000ef          	jal	ra,ffffffffc0202f0c <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc02026a4:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc02026a6:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc02026a8:	4785                	li	a5,1
ffffffffc02026aa:	fcf70be3          	beq	a4,a5,ffffffffc0202680 <pgdir_alloc_page+0x38>
ffffffffc02026ae:	00003697          	auipc	a3,0x3
ffffffffc02026b2:	92a68693          	addi	a3,a3,-1750 # ffffffffc0204fd8 <default_pmm_manager+0xf8>
ffffffffc02026b6:	00002617          	auipc	a2,0x2
ffffffffc02026ba:	49260613          	addi	a2,a2,1170 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02026be:	17a00593          	li	a1,378
ffffffffc02026c2:	00003517          	auipc	a0,0x3
ffffffffc02026c6:	89650513          	addi	a0,a0,-1898 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc02026ca:	cb5fd0ef          	jal	ra,ffffffffc020037e <__panic>
            free_page(page);
ffffffffc02026ce:	8522                	mv	a0,s0
ffffffffc02026d0:	4585                	li	a1,1
ffffffffc02026d2:	864ff0ef          	jal	ra,ffffffffc0201736 <free_pages>
            return NULL;
ffffffffc02026d6:	4401                	li	s0,0
ffffffffc02026d8:	b765                	j	ffffffffc0202680 <pgdir_alloc_page+0x38>

ffffffffc02026da <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02026da:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026dc:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02026de:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026e0:	fff50713          	addi	a4,a0,-1
ffffffffc02026e4:	17f9                	addi	a5,a5,-2
ffffffffc02026e6:	04e7ee63          	bltu	a5,a4,ffffffffc0202742 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02026ea:	6785                	lui	a5,0x1
ffffffffc02026ec:	17fd                	addi	a5,a5,-1
ffffffffc02026ee:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02026f0:	8131                	srli	a0,a0,0xc
ffffffffc02026f2:	fbdfe0ef          	jal	ra,ffffffffc02016ae <alloc_pages>
    assert(base != NULL);
ffffffffc02026f6:	c159                	beqz	a0,ffffffffc020277c <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026f8:	0000e797          	auipc	a5,0xe
ffffffffc02026fc:	ea878793          	addi	a5,a5,-344 # ffffffffc02105a0 <pages>
ffffffffc0202700:	639c                	ld	a5,0(a5)
ffffffffc0202702:	8d1d                	sub	a0,a0,a5
ffffffffc0202704:	00002797          	auipc	a5,0x2
ffffffffc0202708:	42c78793          	addi	a5,a5,1068 # ffffffffc0204b30 <commands+0x8c0>
ffffffffc020270c:	6394                	ld	a3,0(a5)
ffffffffc020270e:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202710:	0000e797          	auipc	a5,0xe
ffffffffc0202714:	d5078793          	addi	a5,a5,-688 # ffffffffc0210460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202718:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020271c:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020271e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202722:	57fd                	li	a5,-1
ffffffffc0202724:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202726:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202728:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020272a:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020272c:	02e7fb63          	bleu	a4,a5,ffffffffc0202762 <kmalloc+0x88>
ffffffffc0202730:	0000e797          	auipc	a5,0xe
ffffffffc0202734:	e6078793          	addi	a5,a5,-416 # ffffffffc0210590 <va_pa_offset>
ffffffffc0202738:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc020273a:	60a2                	ld	ra,8(sp)
ffffffffc020273c:	953e                	add	a0,a0,a5
ffffffffc020273e:	0141                	addi	sp,sp,16
ffffffffc0202740:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202742:	00003697          	auipc	a3,0x3
ffffffffc0202746:	83668693          	addi	a3,a3,-1994 # ffffffffc0204f78 <default_pmm_manager+0x98>
ffffffffc020274a:	00002617          	auipc	a2,0x2
ffffffffc020274e:	3fe60613          	addi	a2,a2,1022 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202752:	1f000593          	li	a1,496
ffffffffc0202756:	00003517          	auipc	a0,0x3
ffffffffc020275a:	80250513          	addi	a0,a0,-2046 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc020275e:	c21fd0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc0202762:	86aa                	mv	a3,a0
ffffffffc0202764:	00002617          	auipc	a2,0x2
ffffffffc0202768:	7cc60613          	addi	a2,a2,1996 # ffffffffc0204f30 <default_pmm_manager+0x50>
ffffffffc020276c:	06a00593          	li	a1,106
ffffffffc0202770:	00003517          	auipc	a0,0x3
ffffffffc0202774:	85850513          	addi	a0,a0,-1960 # ffffffffc0204fc8 <default_pmm_manager+0xe8>
ffffffffc0202778:	c07fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(base != NULL);
ffffffffc020277c:	00003697          	auipc	a3,0x3
ffffffffc0202780:	81c68693          	addi	a3,a3,-2020 # ffffffffc0204f98 <default_pmm_manager+0xb8>
ffffffffc0202784:	00002617          	auipc	a2,0x2
ffffffffc0202788:	3c460613          	addi	a2,a2,964 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020278c:	1f300593          	li	a1,499
ffffffffc0202790:	00002517          	auipc	a0,0x2
ffffffffc0202794:	7c850513          	addi	a0,a0,1992 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202798:	be7fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc020279c <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc020279c:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020279e:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc02027a0:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027a2:	fff58713          	addi	a4,a1,-1
ffffffffc02027a6:	17f9                	addi	a5,a5,-2
ffffffffc02027a8:	04e7eb63          	bltu	a5,a4,ffffffffc02027fe <kfree+0x62>
    assert(ptr != NULL);
ffffffffc02027ac:	c941                	beqz	a0,ffffffffc020283c <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02027ae:	6785                	lui	a5,0x1
ffffffffc02027b0:	17fd                	addi	a5,a5,-1
ffffffffc02027b2:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027b4:	c02007b7          	lui	a5,0xc0200
ffffffffc02027b8:	81b1                	srli	a1,a1,0xc
ffffffffc02027ba:	06f56463          	bltu	a0,a5,ffffffffc0202822 <kfree+0x86>
ffffffffc02027be:	0000e797          	auipc	a5,0xe
ffffffffc02027c2:	dd278793          	addi	a5,a5,-558 # ffffffffc0210590 <va_pa_offset>
ffffffffc02027c6:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02027c8:	0000e717          	auipc	a4,0xe
ffffffffc02027cc:	c9870713          	addi	a4,a4,-872 # ffffffffc0210460 <npage>
ffffffffc02027d0:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027d2:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc02027d6:	83b1                	srli	a5,a5,0xc
ffffffffc02027d8:	04e7f363          	bleu	a4,a5,ffffffffc020281e <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc02027dc:	fff80537          	lui	a0,0xfff80
ffffffffc02027e0:	97aa                	add	a5,a5,a0
ffffffffc02027e2:	0000e697          	auipc	a3,0xe
ffffffffc02027e6:	dbe68693          	addi	a3,a3,-578 # ffffffffc02105a0 <pages>
ffffffffc02027ea:	6288                	ld	a0,0(a3)
ffffffffc02027ec:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02027f0:	60a2                	ld	ra,8(sp)
ffffffffc02027f2:	97ba                	add	a5,a5,a4
ffffffffc02027f4:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc02027f6:	953e                	add	a0,a0,a5
}
ffffffffc02027f8:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc02027fa:	f3dfe06f          	j	ffffffffc0201736 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027fe:	00002697          	auipc	a3,0x2
ffffffffc0202802:	77a68693          	addi	a3,a3,1914 # ffffffffc0204f78 <default_pmm_manager+0x98>
ffffffffc0202806:	00002617          	auipc	a2,0x2
ffffffffc020280a:	34260613          	addi	a2,a2,834 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020280e:	1f900593          	li	a1,505
ffffffffc0202812:	00002517          	auipc	a0,0x2
ffffffffc0202816:	74650513          	addi	a0,a0,1862 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc020281a:	b65fd0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc020281e:	e75fe0ef          	jal	ra,ffffffffc0201692 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202822:	86aa                	mv	a3,a0
ffffffffc0202824:	00003617          	auipc	a2,0x3
ffffffffc0202828:	85460613          	addi	a2,a2,-1964 # ffffffffc0205078 <default_pmm_manager+0x198>
ffffffffc020282c:	06c00593          	li	a1,108
ffffffffc0202830:	00002517          	auipc	a0,0x2
ffffffffc0202834:	79850513          	addi	a0,a0,1944 # ffffffffc0204fc8 <default_pmm_manager+0xe8>
ffffffffc0202838:	b47fd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(ptr != NULL);
ffffffffc020283c:	00002697          	auipc	a3,0x2
ffffffffc0202840:	72c68693          	addi	a3,a3,1836 # ffffffffc0204f68 <default_pmm_manager+0x88>
ffffffffc0202844:	00002617          	auipc	a2,0x2
ffffffffc0202848:	30460613          	addi	a2,a2,772 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020284c:	1fa00593          	li	a1,506
ffffffffc0202850:	00002517          	auipc	a0,0x2
ffffffffc0202854:	70850513          	addi	a0,a0,1800 # ffffffffc0204f58 <default_pmm_manager+0x78>
ffffffffc0202858:	b27fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc020285c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020285c:	7135                	addi	sp,sp,-160
ffffffffc020285e:	ed06                	sd	ra,152(sp)
ffffffffc0202860:	e922                	sd	s0,144(sp)
ffffffffc0202862:	e526                	sd	s1,136(sp)
ffffffffc0202864:	e14a                	sd	s2,128(sp)
ffffffffc0202866:	fcce                	sd	s3,120(sp)
ffffffffc0202868:	f8d2                	sd	s4,112(sp)
ffffffffc020286a:	f4d6                	sd	s5,104(sp)
ffffffffc020286c:	f0da                	sd	s6,96(sp)
ffffffffc020286e:	ecde                	sd	s7,88(sp)
ffffffffc0202870:	e8e2                	sd	s8,80(sp)
ffffffffc0202872:	e4e6                	sd	s9,72(sp)
ffffffffc0202874:	e0ea                	sd	s10,64(sp)
ffffffffc0202876:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202878:	274010ef          	jal	ra,ffffffffc0203aec <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020287c:	0000e797          	auipc	a5,0xe
ffffffffc0202880:	db478793          	addi	a5,a5,-588 # ffffffffc0210630 <max_swap_offset>
ffffffffc0202884:	6394                	ld	a3,0(a5)
ffffffffc0202886:	010007b7          	lui	a5,0x1000
ffffffffc020288a:	17e1                	addi	a5,a5,-8
ffffffffc020288c:	ff968713          	addi	a4,a3,-7
ffffffffc0202890:	42e7ea63          	bltu	a5,a4,ffffffffc0202cc4 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0202894:	00006797          	auipc	a5,0x6
ffffffffc0202898:	76c78793          	addi	a5,a5,1900 # ffffffffc0209000 <swap_manager_clock>
     int r = sm->init();
ffffffffc020289c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc020289e:	0000e697          	auipc	a3,0xe
ffffffffc02028a2:	bcf6b523          	sd	a5,-1078(a3) # ffffffffc0210468 <sm>
     int r = sm->init();
ffffffffc02028a6:	9702                	jalr	a4
ffffffffc02028a8:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc02028aa:	c10d                	beqz	a0,ffffffffc02028cc <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02028ac:	60ea                	ld	ra,152(sp)
ffffffffc02028ae:	644a                	ld	s0,144(sp)
ffffffffc02028b0:	855a                	mv	a0,s6
ffffffffc02028b2:	64aa                	ld	s1,136(sp)
ffffffffc02028b4:	690a                	ld	s2,128(sp)
ffffffffc02028b6:	79e6                	ld	s3,120(sp)
ffffffffc02028b8:	7a46                	ld	s4,112(sp)
ffffffffc02028ba:	7aa6                	ld	s5,104(sp)
ffffffffc02028bc:	7b06                	ld	s6,96(sp)
ffffffffc02028be:	6be6                	ld	s7,88(sp)
ffffffffc02028c0:	6c46                	ld	s8,80(sp)
ffffffffc02028c2:	6ca6                	ld	s9,72(sp)
ffffffffc02028c4:	6d06                	ld	s10,64(sp)
ffffffffc02028c6:	7de2                	ld	s11,56(sp)
ffffffffc02028c8:	610d                	addi	sp,sp,160
ffffffffc02028ca:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028cc:	0000e797          	auipc	a5,0xe
ffffffffc02028d0:	b9c78793          	addi	a5,a5,-1124 # ffffffffc0210468 <sm>
ffffffffc02028d4:	639c                	ld	a5,0(a5)
ffffffffc02028d6:	00003517          	auipc	a0,0x3
ffffffffc02028da:	cda50513          	addi	a0,a0,-806 # ffffffffc02055b0 <default_pmm_manager+0x6d0>
    return listelm->next;
ffffffffc02028de:	0000e417          	auipc	s0,0xe
ffffffffc02028e2:	ba240413          	addi	s0,s0,-1118 # ffffffffc0210480 <free_area>
ffffffffc02028e6:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02028e8:	4785                	li	a5,1
ffffffffc02028ea:	0000e717          	auipc	a4,0xe
ffffffffc02028ee:	b8f72323          	sw	a5,-1146(a4) # ffffffffc0210470 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028f2:	fd6fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
ffffffffc02028f6:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028f8:	2e878a63          	beq	a5,s0,ffffffffc0202bec <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02028fc:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202900:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202902:	8b05                	andi	a4,a4,1
ffffffffc0202904:	2e070863          	beqz	a4,ffffffffc0202bf4 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc0202908:	4481                	li	s1,0
ffffffffc020290a:	4901                	li	s2,0
ffffffffc020290c:	a031                	j	ffffffffc0202918 <swap_init+0xbc>
ffffffffc020290e:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202912:	8b09                	andi	a4,a4,2
ffffffffc0202914:	2e070063          	beqz	a4,ffffffffc0202bf4 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc0202918:	ff87a703          	lw	a4,-8(a5)
ffffffffc020291c:	679c                	ld	a5,8(a5)
ffffffffc020291e:	2905                	addiw	s2,s2,1
ffffffffc0202920:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202922:	fe8796e3          	bne	a5,s0,ffffffffc020290e <swap_init+0xb2>
ffffffffc0202926:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202928:	e55fe0ef          	jal	ra,ffffffffc020177c <nr_free_pages>
ffffffffc020292c:	5b351863          	bne	a0,s3,ffffffffc0202edc <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202930:	8626                	mv	a2,s1
ffffffffc0202932:	85ca                	mv	a1,s2
ffffffffc0202934:	00003517          	auipc	a0,0x3
ffffffffc0202938:	c9450513          	addi	a0,a0,-876 # ffffffffc02055c8 <default_pmm_manager+0x6e8>
ffffffffc020293c:	f8cfd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202940:	203000ef          	jal	ra,ffffffffc0203342 <mm_create>
ffffffffc0202944:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202946:	50050b63          	beqz	a0,ffffffffc0202e5c <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020294a:	0000e797          	auipc	a5,0xe
ffffffffc020294e:	d3e78793          	addi	a5,a5,-706 # ffffffffc0210688 <check_mm_struct>
ffffffffc0202952:	639c                	ld	a5,0(a5)
ffffffffc0202954:	52079463          	bnez	a5,ffffffffc0202e7c <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202958:	0000e797          	auipc	a5,0xe
ffffffffc020295c:	b0078793          	addi	a5,a5,-1280 # ffffffffc0210458 <boot_pgdir>
ffffffffc0202960:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0202962:	0000e797          	auipc	a5,0xe
ffffffffc0202966:	d2a7b323          	sd	a0,-730(a5) # ffffffffc0210688 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020296a:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020296c:	ec3a                	sd	a4,24(sp)
ffffffffc020296e:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202970:	52079663          	bnez	a5,ffffffffc0202e9c <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202974:	6599                	lui	a1,0x6
ffffffffc0202976:	460d                	li	a2,3
ffffffffc0202978:	6505                	lui	a0,0x1
ffffffffc020297a:	215000ef          	jal	ra,ffffffffc020338e <vma_create>
ffffffffc020297e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202980:	52050e63          	beqz	a0,ffffffffc0202ebc <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0202984:	855e                	mv	a0,s7
ffffffffc0202986:	275000ef          	jal	ra,ffffffffc02033fa <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020298a:	00003517          	auipc	a0,0x3
ffffffffc020298e:	cae50513          	addi	a0,a0,-850 # ffffffffc0205638 <default_pmm_manager+0x758>
ffffffffc0202992:	f36fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202996:	018bb503          	ld	a0,24(s7)
ffffffffc020299a:	4605                	li	a2,1
ffffffffc020299c:	6585                	lui	a1,0x1
ffffffffc020299e:	e1ffe0ef          	jal	ra,ffffffffc02017bc <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02029a2:	40050d63          	beqz	a0,ffffffffc0202dbc <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02029a6:	00003517          	auipc	a0,0x3
ffffffffc02029aa:	ce250513          	addi	a0,a0,-798 # ffffffffc0205688 <default_pmm_manager+0x7a8>
ffffffffc02029ae:	0000ea17          	auipc	s4,0xe
ffffffffc02029b2:	bfaa0a13          	addi	s4,s4,-1030 # ffffffffc02105a8 <check_rp>
ffffffffc02029b6:	f12fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029ba:	0000ea97          	auipc	s5,0xe
ffffffffc02029be:	c0ea8a93          	addi	s5,s5,-1010 # ffffffffc02105c8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02029c2:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc02029c4:	4505                	li	a0,1
ffffffffc02029c6:	ce9fe0ef          	jal	ra,ffffffffc02016ae <alloc_pages>
ffffffffc02029ca:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6f970>
          assert(check_rp[i] != NULL );
ffffffffc02029ce:	2a050b63          	beqz	a0,ffffffffc0202c84 <swap_init+0x428>
ffffffffc02029d2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02029d4:	8b89                	andi	a5,a5,2
ffffffffc02029d6:	28079763          	bnez	a5,ffffffffc0202c64 <swap_init+0x408>
ffffffffc02029da:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029dc:	ff5994e3          	bne	s3,s5,ffffffffc02029c4 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02029e0:	601c                	ld	a5,0(s0)
ffffffffc02029e2:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02029e6:	0000ed17          	auipc	s10,0xe
ffffffffc02029ea:	bc2d0d13          	addi	s10,s10,-1086 # ffffffffc02105a8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02029ee:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02029f0:	481c                	lw	a5,16(s0)
ffffffffc02029f2:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02029f4:	0000e797          	auipc	a5,0xe
ffffffffc02029f8:	a887ba23          	sd	s0,-1388(a5) # ffffffffc0210488 <free_area+0x8>
ffffffffc02029fc:	0000e797          	auipc	a5,0xe
ffffffffc0202a00:	a887b223          	sd	s0,-1404(a5) # ffffffffc0210480 <free_area>
     nr_free = 0;
ffffffffc0202a04:	0000e797          	auipc	a5,0xe
ffffffffc0202a08:	a807a623          	sw	zero,-1396(a5) # ffffffffc0210490 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202a0c:	000d3503          	ld	a0,0(s10)
ffffffffc0202a10:	4585                	li	a1,1
ffffffffc0202a12:	0d21                	addi	s10,s10,8
ffffffffc0202a14:	d23fe0ef          	jal	ra,ffffffffc0201736 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a18:	ff5d1ae3          	bne	s10,s5,ffffffffc0202a0c <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202a1c:	01042d03          	lw	s10,16(s0)
ffffffffc0202a20:	4791                	li	a5,4
ffffffffc0202a22:	36fd1d63          	bne	s10,a5,ffffffffc0202d9c <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202a26:	00003517          	auipc	a0,0x3
ffffffffc0202a2a:	cea50513          	addi	a0,a0,-790 # ffffffffc0205710 <default_pmm_manager+0x830>
ffffffffc0202a2e:	e9afd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a32:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202a34:	0000e797          	auipc	a5,0xe
ffffffffc0202a38:	a407a023          	sw	zero,-1472(a5) # ffffffffc0210474 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a3c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202a3e:	0000e797          	auipc	a5,0xe
ffffffffc0202a42:	a3678793          	addi	a5,a5,-1482 # ffffffffc0210474 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a46:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202a4a:	4398                	lw	a4,0(a5)
ffffffffc0202a4c:	4585                	li	a1,1
ffffffffc0202a4e:	2701                	sext.w	a4,a4
ffffffffc0202a50:	30b71663          	bne	a4,a1,ffffffffc0202d5c <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202a54:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202a58:	4394                	lw	a3,0(a5)
ffffffffc0202a5a:	2681                	sext.w	a3,a3
ffffffffc0202a5c:	32e69063          	bne	a3,a4,ffffffffc0202d7c <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202a60:	6689                	lui	a3,0x2
ffffffffc0202a62:	462d                	li	a2,11
ffffffffc0202a64:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202a68:	4398                	lw	a4,0(a5)
ffffffffc0202a6a:	4589                	li	a1,2
ffffffffc0202a6c:	2701                	sext.w	a4,a4
ffffffffc0202a6e:	26b71763          	bne	a4,a1,ffffffffc0202cdc <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202a72:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202a76:	4394                	lw	a3,0(a5)
ffffffffc0202a78:	2681                	sext.w	a3,a3
ffffffffc0202a7a:	28e69163          	bne	a3,a4,ffffffffc0202cfc <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202a7e:	668d                	lui	a3,0x3
ffffffffc0202a80:	4631                	li	a2,12
ffffffffc0202a82:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202a86:	4398                	lw	a4,0(a5)
ffffffffc0202a88:	458d                	li	a1,3
ffffffffc0202a8a:	2701                	sext.w	a4,a4
ffffffffc0202a8c:	28b71863          	bne	a4,a1,ffffffffc0202d1c <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202a90:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202a94:	4394                	lw	a3,0(a5)
ffffffffc0202a96:	2681                	sext.w	a3,a3
ffffffffc0202a98:	2ae69263          	bne	a3,a4,ffffffffc0202d3c <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202a9c:	6691                	lui	a3,0x4
ffffffffc0202a9e:	4635                	li	a2,13
ffffffffc0202aa0:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202aa4:	4398                	lw	a4,0(a5)
ffffffffc0202aa6:	2701                	sext.w	a4,a4
ffffffffc0202aa8:	33a71a63          	bne	a4,s10,ffffffffc0202ddc <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202aac:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202ab0:	439c                	lw	a5,0(a5)
ffffffffc0202ab2:	2781                	sext.w	a5,a5
ffffffffc0202ab4:	34e79463          	bne	a5,a4,ffffffffc0202dfc <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202ab8:	481c                	lw	a5,16(s0)
ffffffffc0202aba:	36079163          	bnez	a5,ffffffffc0202e1c <swap_init+0x5c0>
ffffffffc0202abe:	0000e797          	auipc	a5,0xe
ffffffffc0202ac2:	b0a78793          	addi	a5,a5,-1270 # ffffffffc02105c8 <swap_in_seq_no>
ffffffffc0202ac6:	0000e717          	auipc	a4,0xe
ffffffffc0202aca:	b2a70713          	addi	a4,a4,-1238 # ffffffffc02105f0 <swap_out_seq_no>
ffffffffc0202ace:	0000e617          	auipc	a2,0xe
ffffffffc0202ad2:	b2260613          	addi	a2,a2,-1246 # ffffffffc02105f0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202ad6:	56fd                	li	a3,-1
ffffffffc0202ad8:	c394                	sw	a3,0(a5)
ffffffffc0202ada:	c314                	sw	a3,0(a4)
ffffffffc0202adc:	0791                	addi	a5,a5,4
ffffffffc0202ade:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202ae0:	fec79ce3          	bne	a5,a2,ffffffffc0202ad8 <swap_init+0x27c>
ffffffffc0202ae4:	0000e697          	auipc	a3,0xe
ffffffffc0202ae8:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0210650 <check_ptep>
ffffffffc0202aec:	0000e817          	auipc	a6,0xe
ffffffffc0202af0:	abc80813          	addi	a6,a6,-1348 # ffffffffc02105a8 <check_rp>
ffffffffc0202af4:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202af6:	0000ec97          	auipc	s9,0xe
ffffffffc0202afa:	96ac8c93          	addi	s9,s9,-1686 # ffffffffc0210460 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202afe:	0000ed97          	auipc	s11,0xe
ffffffffc0202b02:	aa2d8d93          	addi	s11,s11,-1374 # ffffffffc02105a0 <pages>
ffffffffc0202b06:	00003d17          	auipc	s10,0x3
ffffffffc0202b0a:	43ad0d13          	addi	s10,s10,1082 # ffffffffc0205f40 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b0e:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202b10:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b14:	4601                	li	a2,0
ffffffffc0202b16:	85e2                	mv	a1,s8
ffffffffc0202b18:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202b1a:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b1c:	ca1fe0ef          	jal	ra,ffffffffc02017bc <get_pte>
ffffffffc0202b20:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202b22:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b24:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202b26:	16050f63          	beqz	a0,ffffffffc0202ca4 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202b2a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202b2c:	0017f613          	andi	a2,a5,1
ffffffffc0202b30:	10060263          	beqz	a2,ffffffffc0202c34 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202b34:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b38:	078a                	slli	a5,a5,0x2
ffffffffc0202b3a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b3c:	10c7f863          	bleu	a2,a5,ffffffffc0202c4c <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b40:	000d3603          	ld	a2,0(s10)
ffffffffc0202b44:	000db583          	ld	a1,0(s11)
ffffffffc0202b48:	00083503          	ld	a0,0(a6)
ffffffffc0202b4c:	8f91                	sub	a5,a5,a2
ffffffffc0202b4e:	00379613          	slli	a2,a5,0x3
ffffffffc0202b52:	97b2                	add	a5,a5,a2
ffffffffc0202b54:	078e                	slli	a5,a5,0x3
ffffffffc0202b56:	97ae                	add	a5,a5,a1
ffffffffc0202b58:	0af51e63          	bne	a0,a5,ffffffffc0202c14 <swap_init+0x3b8>
ffffffffc0202b5c:	6785                	lui	a5,0x1
ffffffffc0202b5e:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b60:	6795                	lui	a5,0x5
ffffffffc0202b62:	06a1                	addi	a3,a3,8
ffffffffc0202b64:	0821                	addi	a6,a6,8
ffffffffc0202b66:	fafc14e3          	bne	s8,a5,ffffffffc0202b0e <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202b6a:	00003517          	auipc	a0,0x3
ffffffffc0202b6e:	c4e50513          	addi	a0,a0,-946 # ffffffffc02057b8 <default_pmm_manager+0x8d8>
ffffffffc0202b72:	d56fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    int ret = sm->check_swap();
ffffffffc0202b76:	0000e797          	auipc	a5,0xe
ffffffffc0202b7a:	8f278793          	addi	a5,a5,-1806 # ffffffffc0210468 <sm>
ffffffffc0202b7e:	639c                	ld	a5,0(a5)
ffffffffc0202b80:	7f9c                	ld	a5,56(a5)
ffffffffc0202b82:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202b84:	2a051c63          	bnez	a0,ffffffffc0202e3c <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202b88:	000a3503          	ld	a0,0(s4)
ffffffffc0202b8c:	4585                	li	a1,1
ffffffffc0202b8e:	0a21                	addi	s4,s4,8
ffffffffc0202b90:	ba7fe0ef          	jal	ra,ffffffffc0201736 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b94:	ff5a1ae3          	bne	s4,s5,ffffffffc0202b88 <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202b98:	855e                	mv	a0,s7
ffffffffc0202b9a:	12f000ef          	jal	ra,ffffffffc02034c8 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202b9e:	77a2                	ld	a5,40(sp)
ffffffffc0202ba0:	0000e717          	auipc	a4,0xe
ffffffffc0202ba4:	8ef72823          	sw	a5,-1808(a4) # ffffffffc0210490 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202ba8:	7782                	ld	a5,32(sp)
ffffffffc0202baa:	0000e717          	auipc	a4,0xe
ffffffffc0202bae:	8cf73b23          	sd	a5,-1834(a4) # ffffffffc0210480 <free_area>
ffffffffc0202bb2:	0000e797          	auipc	a5,0xe
ffffffffc0202bb6:	8d37bb23          	sd	s3,-1834(a5) # ffffffffc0210488 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bba:	00898a63          	beq	s3,s0,ffffffffc0202bce <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202bbe:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202bc2:	0089b983          	ld	s3,8(s3)
ffffffffc0202bc6:	397d                	addiw	s2,s2,-1
ffffffffc0202bc8:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bca:	fe899ae3          	bne	s3,s0,ffffffffc0202bbe <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202bce:	8626                	mv	a2,s1
ffffffffc0202bd0:	85ca                	mv	a1,s2
ffffffffc0202bd2:	00003517          	auipc	a0,0x3
ffffffffc0202bd6:	c1650513          	addi	a0,a0,-1002 # ffffffffc02057e8 <default_pmm_manager+0x908>
ffffffffc0202bda:	ceefd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202bde:	00003517          	auipc	a0,0x3
ffffffffc0202be2:	c2a50513          	addi	a0,a0,-982 # ffffffffc0205808 <default_pmm_manager+0x928>
ffffffffc0202be6:	ce2fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
ffffffffc0202bea:	b1c9                	j	ffffffffc02028ac <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202bec:	4481                	li	s1,0
ffffffffc0202bee:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bf0:	4981                	li	s3,0
ffffffffc0202bf2:	bb1d                	j	ffffffffc0202928 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202bf4:	00002697          	auipc	a3,0x2
ffffffffc0202bf8:	f4468693          	addi	a3,a3,-188 # ffffffffc0204b38 <commands+0x8c8>
ffffffffc0202bfc:	00002617          	auipc	a2,0x2
ffffffffc0202c00:	f4c60613          	addi	a2,a2,-180 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202c04:	0ba00593          	li	a1,186
ffffffffc0202c08:	00003517          	auipc	a0,0x3
ffffffffc0202c0c:	99850513          	addi	a0,a0,-1640 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202c10:	f6efd0ef          	jal	ra,ffffffffc020037e <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c14:	00003697          	auipc	a3,0x3
ffffffffc0202c18:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0205790 <default_pmm_manager+0x8b0>
ffffffffc0202c1c:	00002617          	auipc	a2,0x2
ffffffffc0202c20:	f2c60613          	addi	a2,a2,-212 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202c24:	0fa00593          	li	a1,250
ffffffffc0202c28:	00003517          	auipc	a0,0x3
ffffffffc0202c2c:	97850513          	addi	a0,a0,-1672 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202c30:	f4efd0ef          	jal	ra,ffffffffc020037e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202c34:	00002617          	auipc	a2,0x2
ffffffffc0202c38:	56c60613          	addi	a2,a2,1388 # ffffffffc02051a0 <default_pmm_manager+0x2c0>
ffffffffc0202c3c:	07000593          	li	a1,112
ffffffffc0202c40:	00002517          	auipc	a0,0x2
ffffffffc0202c44:	38850513          	addi	a0,a0,904 # ffffffffc0204fc8 <default_pmm_manager+0xe8>
ffffffffc0202c48:	f36fd0ef          	jal	ra,ffffffffc020037e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202c4c:	00002617          	auipc	a2,0x2
ffffffffc0202c50:	35c60613          	addi	a2,a2,860 # ffffffffc0204fa8 <default_pmm_manager+0xc8>
ffffffffc0202c54:	06500593          	li	a1,101
ffffffffc0202c58:	00002517          	auipc	a0,0x2
ffffffffc0202c5c:	37050513          	addi	a0,a0,880 # ffffffffc0204fc8 <default_pmm_manager+0xe8>
ffffffffc0202c60:	f1efd0ef          	jal	ra,ffffffffc020037e <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c64:	00003697          	auipc	a3,0x3
ffffffffc0202c68:	a6468693          	addi	a3,a3,-1436 # ffffffffc02056c8 <default_pmm_manager+0x7e8>
ffffffffc0202c6c:	00002617          	auipc	a2,0x2
ffffffffc0202c70:	edc60613          	addi	a2,a2,-292 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202c74:	0db00593          	li	a1,219
ffffffffc0202c78:	00003517          	auipc	a0,0x3
ffffffffc0202c7c:	92850513          	addi	a0,a0,-1752 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202c80:	efefd0ef          	jal	ra,ffffffffc020037e <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202c84:	00003697          	auipc	a3,0x3
ffffffffc0202c88:	a2c68693          	addi	a3,a3,-1492 # ffffffffc02056b0 <default_pmm_manager+0x7d0>
ffffffffc0202c8c:	00002617          	auipc	a2,0x2
ffffffffc0202c90:	ebc60613          	addi	a2,a2,-324 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202c94:	0da00593          	li	a1,218
ffffffffc0202c98:	00003517          	auipc	a0,0x3
ffffffffc0202c9c:	90850513          	addi	a0,a0,-1784 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202ca0:	edefd0ef          	jal	ra,ffffffffc020037e <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202ca4:	00003697          	auipc	a3,0x3
ffffffffc0202ca8:	ad468693          	addi	a3,a3,-1324 # ffffffffc0205778 <default_pmm_manager+0x898>
ffffffffc0202cac:	00002617          	auipc	a2,0x2
ffffffffc0202cb0:	e9c60613          	addi	a2,a2,-356 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202cb4:	0f900593          	li	a1,249
ffffffffc0202cb8:	00003517          	auipc	a0,0x3
ffffffffc0202cbc:	8e850513          	addi	a0,a0,-1816 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202cc0:	ebefd0ef          	jal	ra,ffffffffc020037e <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202cc4:	00003617          	auipc	a2,0x3
ffffffffc0202cc8:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0205580 <default_pmm_manager+0x6a0>
ffffffffc0202ccc:	02700593          	li	a1,39
ffffffffc0202cd0:	00003517          	auipc	a0,0x3
ffffffffc0202cd4:	8d050513          	addi	a0,a0,-1840 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202cd8:	ea6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==2);
ffffffffc0202cdc:	00003697          	auipc	a3,0x3
ffffffffc0202ce0:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0205748 <default_pmm_manager+0x868>
ffffffffc0202ce4:	00002617          	auipc	a2,0x2
ffffffffc0202ce8:	e6460613          	addi	a2,a2,-412 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202cec:	09500593          	li	a1,149
ffffffffc0202cf0:	00003517          	auipc	a0,0x3
ffffffffc0202cf4:	8b050513          	addi	a0,a0,-1872 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202cf8:	e86fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==2);
ffffffffc0202cfc:	00003697          	auipc	a3,0x3
ffffffffc0202d00:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0205748 <default_pmm_manager+0x868>
ffffffffc0202d04:	00002617          	auipc	a2,0x2
ffffffffc0202d08:	e4460613          	addi	a2,a2,-444 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202d0c:	09700593          	li	a1,151
ffffffffc0202d10:	00003517          	auipc	a0,0x3
ffffffffc0202d14:	89050513          	addi	a0,a0,-1904 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202d18:	e66fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==3);
ffffffffc0202d1c:	00003697          	auipc	a3,0x3
ffffffffc0202d20:	a3c68693          	addi	a3,a3,-1476 # ffffffffc0205758 <default_pmm_manager+0x878>
ffffffffc0202d24:	00002617          	auipc	a2,0x2
ffffffffc0202d28:	e2460613          	addi	a2,a2,-476 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202d2c:	09900593          	li	a1,153
ffffffffc0202d30:	00003517          	auipc	a0,0x3
ffffffffc0202d34:	87050513          	addi	a0,a0,-1936 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202d38:	e46fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==3);
ffffffffc0202d3c:	00003697          	auipc	a3,0x3
ffffffffc0202d40:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0205758 <default_pmm_manager+0x878>
ffffffffc0202d44:	00002617          	auipc	a2,0x2
ffffffffc0202d48:	e0460613          	addi	a2,a2,-508 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202d4c:	09b00593          	li	a1,155
ffffffffc0202d50:	00003517          	auipc	a0,0x3
ffffffffc0202d54:	85050513          	addi	a0,a0,-1968 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202d58:	e26fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==1);
ffffffffc0202d5c:	00003697          	auipc	a3,0x3
ffffffffc0202d60:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0205738 <default_pmm_manager+0x858>
ffffffffc0202d64:	00002617          	auipc	a2,0x2
ffffffffc0202d68:	de460613          	addi	a2,a2,-540 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202d6c:	09100593          	li	a1,145
ffffffffc0202d70:	00003517          	auipc	a0,0x3
ffffffffc0202d74:	83050513          	addi	a0,a0,-2000 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202d78:	e06fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==1);
ffffffffc0202d7c:	00003697          	auipc	a3,0x3
ffffffffc0202d80:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0205738 <default_pmm_manager+0x858>
ffffffffc0202d84:	00002617          	auipc	a2,0x2
ffffffffc0202d88:	dc460613          	addi	a2,a2,-572 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202d8c:	09300593          	li	a1,147
ffffffffc0202d90:	00003517          	auipc	a0,0x3
ffffffffc0202d94:	81050513          	addi	a0,a0,-2032 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202d98:	de6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d9c:	00003697          	auipc	a3,0x3
ffffffffc0202da0:	94c68693          	addi	a3,a3,-1716 # ffffffffc02056e8 <default_pmm_manager+0x808>
ffffffffc0202da4:	00002617          	auipc	a2,0x2
ffffffffc0202da8:	da460613          	addi	a2,a2,-604 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202dac:	0e800593          	li	a1,232
ffffffffc0202db0:	00002517          	auipc	a0,0x2
ffffffffc0202db4:	7f050513          	addi	a0,a0,2032 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202db8:	dc6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202dbc:	00003697          	auipc	a3,0x3
ffffffffc0202dc0:	8b468693          	addi	a3,a3,-1868 # ffffffffc0205670 <default_pmm_manager+0x790>
ffffffffc0202dc4:	00002617          	auipc	a2,0x2
ffffffffc0202dc8:	d8460613          	addi	a2,a2,-636 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202dcc:	0d500593          	li	a1,213
ffffffffc0202dd0:	00002517          	auipc	a0,0x2
ffffffffc0202dd4:	7d050513          	addi	a0,a0,2000 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202dd8:	da6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==4);
ffffffffc0202ddc:	00003697          	auipc	a3,0x3
ffffffffc0202de0:	98c68693          	addi	a3,a3,-1652 # ffffffffc0205768 <default_pmm_manager+0x888>
ffffffffc0202de4:	00002617          	auipc	a2,0x2
ffffffffc0202de8:	d6460613          	addi	a2,a2,-668 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202dec:	09d00593          	li	a1,157
ffffffffc0202df0:	00002517          	auipc	a0,0x2
ffffffffc0202df4:	7b050513          	addi	a0,a0,1968 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202df8:	d86fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgfault_num==4);
ffffffffc0202dfc:	00003697          	auipc	a3,0x3
ffffffffc0202e00:	96c68693          	addi	a3,a3,-1684 # ffffffffc0205768 <default_pmm_manager+0x888>
ffffffffc0202e04:	00002617          	auipc	a2,0x2
ffffffffc0202e08:	d4460613          	addi	a2,a2,-700 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202e0c:	09f00593          	li	a1,159
ffffffffc0202e10:	00002517          	auipc	a0,0x2
ffffffffc0202e14:	79050513          	addi	a0,a0,1936 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202e18:	d66fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert( nr_free == 0);         
ffffffffc0202e1c:	00002697          	auipc	a3,0x2
ffffffffc0202e20:	f0468693          	addi	a3,a3,-252 # ffffffffc0204d20 <commands+0xab0>
ffffffffc0202e24:	00002617          	auipc	a2,0x2
ffffffffc0202e28:	d2460613          	addi	a2,a2,-732 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202e2c:	0f100593          	li	a1,241
ffffffffc0202e30:	00002517          	auipc	a0,0x2
ffffffffc0202e34:	77050513          	addi	a0,a0,1904 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202e38:	d46fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(ret==0);
ffffffffc0202e3c:	00003697          	auipc	a3,0x3
ffffffffc0202e40:	9a468693          	addi	a3,a3,-1628 # ffffffffc02057e0 <default_pmm_manager+0x900>
ffffffffc0202e44:	00002617          	auipc	a2,0x2
ffffffffc0202e48:	d0460613          	addi	a2,a2,-764 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202e4c:	10000593          	li	a1,256
ffffffffc0202e50:	00002517          	auipc	a0,0x2
ffffffffc0202e54:	75050513          	addi	a0,a0,1872 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202e58:	d26fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(mm != NULL);
ffffffffc0202e5c:	00002697          	auipc	a3,0x2
ffffffffc0202e60:	79468693          	addi	a3,a3,1940 # ffffffffc02055f0 <default_pmm_manager+0x710>
ffffffffc0202e64:	00002617          	auipc	a2,0x2
ffffffffc0202e68:	ce460613          	addi	a2,a2,-796 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202e6c:	0c200593          	li	a1,194
ffffffffc0202e70:	00002517          	auipc	a0,0x2
ffffffffc0202e74:	73050513          	addi	a0,a0,1840 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202e78:	d06fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202e7c:	00002697          	auipc	a3,0x2
ffffffffc0202e80:	78468693          	addi	a3,a3,1924 # ffffffffc0205600 <default_pmm_manager+0x720>
ffffffffc0202e84:	00002617          	auipc	a2,0x2
ffffffffc0202e88:	cc460613          	addi	a2,a2,-828 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202e8c:	0c500593          	li	a1,197
ffffffffc0202e90:	00002517          	auipc	a0,0x2
ffffffffc0202e94:	71050513          	addi	a0,a0,1808 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202e98:	ce6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e9c:	00002697          	auipc	a3,0x2
ffffffffc0202ea0:	77c68693          	addi	a3,a3,1916 # ffffffffc0205618 <default_pmm_manager+0x738>
ffffffffc0202ea4:	00002617          	auipc	a2,0x2
ffffffffc0202ea8:	ca460613          	addi	a2,a2,-860 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202eac:	0ca00593          	li	a1,202
ffffffffc0202eb0:	00002517          	auipc	a0,0x2
ffffffffc0202eb4:	6f050513          	addi	a0,a0,1776 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202eb8:	cc6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(vma != NULL);
ffffffffc0202ebc:	00002697          	auipc	a3,0x2
ffffffffc0202ec0:	76c68693          	addi	a3,a3,1900 # ffffffffc0205628 <default_pmm_manager+0x748>
ffffffffc0202ec4:	00002617          	auipc	a2,0x2
ffffffffc0202ec8:	c8460613          	addi	a2,a2,-892 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202ecc:	0cd00593          	li	a1,205
ffffffffc0202ed0:	00002517          	auipc	a0,0x2
ffffffffc0202ed4:	6d050513          	addi	a0,a0,1744 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202ed8:	ca6fd0ef          	jal	ra,ffffffffc020037e <__panic>
     assert(total == nr_free_pages());
ffffffffc0202edc:	00002697          	auipc	a3,0x2
ffffffffc0202ee0:	c9c68693          	addi	a3,a3,-868 # ffffffffc0204b78 <commands+0x908>
ffffffffc0202ee4:	00002617          	auipc	a2,0x2
ffffffffc0202ee8:	c6460613          	addi	a2,a2,-924 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0202eec:	0bd00593          	li	a1,189
ffffffffc0202ef0:	00002517          	auipc	a0,0x2
ffffffffc0202ef4:	6b050513          	addi	a0,a0,1712 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc0202ef8:	c86fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0202efc <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202efc:	0000d797          	auipc	a5,0xd
ffffffffc0202f00:	56c78793          	addi	a5,a5,1388 # ffffffffc0210468 <sm>
ffffffffc0202f04:	639c                	ld	a5,0(a5)
ffffffffc0202f06:	0107b303          	ld	t1,16(a5)
ffffffffc0202f0a:	8302                	jr	t1

ffffffffc0202f0c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202f0c:	0000d797          	auipc	a5,0xd
ffffffffc0202f10:	55c78793          	addi	a5,a5,1372 # ffffffffc0210468 <sm>
ffffffffc0202f14:	639c                	ld	a5,0(a5)
ffffffffc0202f16:	0207b303          	ld	t1,32(a5)
ffffffffc0202f1a:	8302                	jr	t1

ffffffffc0202f1c <swap_out>:
{
ffffffffc0202f1c:	711d                	addi	sp,sp,-96
ffffffffc0202f1e:	ec86                	sd	ra,88(sp)
ffffffffc0202f20:	e8a2                	sd	s0,80(sp)
ffffffffc0202f22:	e4a6                	sd	s1,72(sp)
ffffffffc0202f24:	e0ca                	sd	s2,64(sp)
ffffffffc0202f26:	fc4e                	sd	s3,56(sp)
ffffffffc0202f28:	f852                	sd	s4,48(sp)
ffffffffc0202f2a:	f456                	sd	s5,40(sp)
ffffffffc0202f2c:	f05a                	sd	s6,32(sp)
ffffffffc0202f2e:	ec5e                	sd	s7,24(sp)
ffffffffc0202f30:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202f32:	cde9                	beqz	a1,ffffffffc020300c <swap_out+0xf0>
ffffffffc0202f34:	8ab2                	mv	s5,a2
ffffffffc0202f36:	892a                	mv	s2,a0
ffffffffc0202f38:	8a2e                	mv	s4,a1
ffffffffc0202f3a:	4401                	li	s0,0
ffffffffc0202f3c:	0000d997          	auipc	s3,0xd
ffffffffc0202f40:	52c98993          	addi	s3,s3,1324 # ffffffffc0210468 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f44:	00003b17          	auipc	s6,0x3
ffffffffc0202f48:	944b0b13          	addi	s6,s6,-1724 # ffffffffc0205888 <default_pmm_manager+0x9a8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f4c:	00003b97          	auipc	s7,0x3
ffffffffc0202f50:	924b8b93          	addi	s7,s7,-1756 # ffffffffc0205870 <default_pmm_manager+0x990>
ffffffffc0202f54:	a825                	j	ffffffffc0202f8c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f56:	67a2                	ld	a5,8(sp)
ffffffffc0202f58:	8626                	mv	a2,s1
ffffffffc0202f5a:	85a2                	mv	a1,s0
ffffffffc0202f5c:	63b4                	ld	a3,64(a5)
ffffffffc0202f5e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202f60:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f62:	82b1                	srli	a3,a3,0xc
ffffffffc0202f64:	0685                	addi	a3,a3,1
ffffffffc0202f66:	962fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f6a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202f6c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f6e:	613c                	ld	a5,64(a0)
ffffffffc0202f70:	83b1                	srli	a5,a5,0xc
ffffffffc0202f72:	0785                	addi	a5,a5,1
ffffffffc0202f74:	07a2                	slli	a5,a5,0x8
ffffffffc0202f76:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202f7a:	fbcfe0ef          	jal	ra,ffffffffc0201736 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202f7e:	01893503          	ld	a0,24(s2)
ffffffffc0202f82:	85a6                	mv	a1,s1
ffffffffc0202f84:	ebeff0ef          	jal	ra,ffffffffc0202642 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202f88:	048a0d63          	beq	s4,s0,ffffffffc0202fe2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202f8c:	0009b783          	ld	a5,0(s3)
ffffffffc0202f90:	8656                	mv	a2,s5
ffffffffc0202f92:	002c                	addi	a1,sp,8
ffffffffc0202f94:	7b9c                	ld	a5,48(a5)
ffffffffc0202f96:	854a                	mv	a0,s2
ffffffffc0202f98:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202f9a:	e12d                	bnez	a0,ffffffffc0202ffc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202f9c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f9e:	01893503          	ld	a0,24(s2)
ffffffffc0202fa2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202fa4:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fa6:	85a6                	mv	a1,s1
ffffffffc0202fa8:	815fe0ef          	jal	ra,ffffffffc02017bc <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fac:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fae:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fb0:	8b85                	andi	a5,a5,1
ffffffffc0202fb2:	cfb9                	beqz	a5,ffffffffc0203010 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202fb4:	65a2                	ld	a1,8(sp)
ffffffffc0202fb6:	61bc                	ld	a5,64(a1)
ffffffffc0202fb8:	83b1                	srli	a5,a5,0xc
ffffffffc0202fba:	00178513          	addi	a0,a5,1
ffffffffc0202fbe:	0522                	slli	a0,a0,0x8
ffffffffc0202fc0:	365000ef          	jal	ra,ffffffffc0203b24 <swapfs_write>
ffffffffc0202fc4:	d949                	beqz	a0,ffffffffc0202f56 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202fc6:	855e                	mv	a0,s7
ffffffffc0202fc8:	900fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fcc:	0009b783          	ld	a5,0(s3)
ffffffffc0202fd0:	6622                	ld	a2,8(sp)
ffffffffc0202fd2:	4681                	li	a3,0
ffffffffc0202fd4:	739c                	ld	a5,32(a5)
ffffffffc0202fd6:	85a6                	mv	a1,s1
ffffffffc0202fd8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202fda:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fdc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202fde:	fa8a17e3          	bne	s4,s0,ffffffffc0202f8c <swap_out+0x70>
}
ffffffffc0202fe2:	8522                	mv	a0,s0
ffffffffc0202fe4:	60e6                	ld	ra,88(sp)
ffffffffc0202fe6:	6446                	ld	s0,80(sp)
ffffffffc0202fe8:	64a6                	ld	s1,72(sp)
ffffffffc0202fea:	6906                	ld	s2,64(sp)
ffffffffc0202fec:	79e2                	ld	s3,56(sp)
ffffffffc0202fee:	7a42                	ld	s4,48(sp)
ffffffffc0202ff0:	7aa2                	ld	s5,40(sp)
ffffffffc0202ff2:	7b02                	ld	s6,32(sp)
ffffffffc0202ff4:	6be2                	ld	s7,24(sp)
ffffffffc0202ff6:	6c42                	ld	s8,16(sp)
ffffffffc0202ff8:	6125                	addi	sp,sp,96
ffffffffc0202ffa:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202ffc:	85a2                	mv	a1,s0
ffffffffc0202ffe:	00003517          	auipc	a0,0x3
ffffffffc0203002:	82a50513          	addi	a0,a0,-2006 # ffffffffc0205828 <default_pmm_manager+0x948>
ffffffffc0203006:	8c2fd0ef          	jal	ra,ffffffffc02000c8 <cprintf>
                  break;
ffffffffc020300a:	bfe1                	j	ffffffffc0202fe2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020300c:	4401                	li	s0,0
ffffffffc020300e:	bfd1                	j	ffffffffc0202fe2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203010:	00003697          	auipc	a3,0x3
ffffffffc0203014:	84868693          	addi	a3,a3,-1976 # ffffffffc0205858 <default_pmm_manager+0x978>
ffffffffc0203018:	00002617          	auipc	a2,0x2
ffffffffc020301c:	b3060613          	addi	a2,a2,-1232 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203020:	06600593          	li	a1,102
ffffffffc0203024:	00002517          	auipc	a0,0x2
ffffffffc0203028:	57c50513          	addi	a0,a0,1404 # ffffffffc02055a0 <default_pmm_manager+0x6c0>
ffffffffc020302c:	b52fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0203030 <_clock_init_mm>:
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203030:	4501                	li	a0,0
ffffffffc0203032:	8082                	ret

ffffffffc0203034 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0203034:	4501                	li	a0,0
ffffffffc0203036:	8082                	ret

ffffffffc0203038 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203038:	4501                	li	a0,0
ffffffffc020303a:	8082                	ret

ffffffffc020303c <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc020303c:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020303e:	678d                	lui	a5,0x3
ffffffffc0203040:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0203042:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203044:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203048:	0000d797          	auipc	a5,0xd
ffffffffc020304c:	42c78793          	addi	a5,a5,1068 # ffffffffc0210474 <pgfault_num>
ffffffffc0203050:	4398                	lw	a4,0(a5)
ffffffffc0203052:	4691                	li	a3,4
ffffffffc0203054:	2701                	sext.w	a4,a4
ffffffffc0203056:	08d71f63          	bne	a4,a3,ffffffffc02030f4 <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020305a:	6685                	lui	a3,0x1
ffffffffc020305c:	4629                	li	a2,10
ffffffffc020305e:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203062:	4394                	lw	a3,0(a5)
ffffffffc0203064:	2681                	sext.w	a3,a3
ffffffffc0203066:	20e69763          	bne	a3,a4,ffffffffc0203274 <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020306a:	6711                	lui	a4,0x4
ffffffffc020306c:	4635                	li	a2,13
ffffffffc020306e:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203072:	4398                	lw	a4,0(a5)
ffffffffc0203074:	2701                	sext.w	a4,a4
ffffffffc0203076:	1cd71f63          	bne	a4,a3,ffffffffc0203254 <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020307a:	6689                	lui	a3,0x2
ffffffffc020307c:	462d                	li	a2,11
ffffffffc020307e:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203082:	4394                	lw	a3,0(a5)
ffffffffc0203084:	2681                	sext.w	a3,a3
ffffffffc0203086:	1ae69763          	bne	a3,a4,ffffffffc0203234 <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020308a:	6715                	lui	a4,0x5
ffffffffc020308c:	46b9                	li	a3,14
ffffffffc020308e:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203092:	4398                	lw	a4,0(a5)
ffffffffc0203094:	4695                	li	a3,5
ffffffffc0203096:	2701                	sext.w	a4,a4
ffffffffc0203098:	16d71e63          	bne	a4,a3,ffffffffc0203214 <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc020309c:	4394                	lw	a3,0(a5)
ffffffffc020309e:	2681                	sext.w	a3,a3
ffffffffc02030a0:	14e69a63          	bne	a3,a4,ffffffffc02031f4 <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc02030a4:	4398                	lw	a4,0(a5)
ffffffffc02030a6:	2701                	sext.w	a4,a4
ffffffffc02030a8:	12d71663          	bne	a4,a3,ffffffffc02031d4 <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc02030ac:	4394                	lw	a3,0(a5)
ffffffffc02030ae:	2681                	sext.w	a3,a3
ffffffffc02030b0:	10e69263          	bne	a3,a4,ffffffffc02031b4 <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc02030b4:	4398                	lw	a4,0(a5)
ffffffffc02030b6:	2701                	sext.w	a4,a4
ffffffffc02030b8:	0cd71e63          	bne	a4,a3,ffffffffc0203194 <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc02030bc:	4394                	lw	a3,0(a5)
ffffffffc02030be:	2681                	sext.w	a3,a3
ffffffffc02030c0:	0ae69a63          	bne	a3,a4,ffffffffc0203174 <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02030c4:	6715                	lui	a4,0x5
ffffffffc02030c6:	46b9                	li	a3,14
ffffffffc02030c8:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02030cc:	4398                	lw	a4,0(a5)
ffffffffc02030ce:	4695                	li	a3,5
ffffffffc02030d0:	2701                	sext.w	a4,a4
ffffffffc02030d2:	08d71163          	bne	a4,a3,ffffffffc0203154 <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02030d6:	6705                	lui	a4,0x1
ffffffffc02030d8:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02030dc:	4729                	li	a4,10
ffffffffc02030de:	04e69b63          	bne	a3,a4,ffffffffc0203134 <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc02030e2:	439c                	lw	a5,0(a5)
ffffffffc02030e4:	4719                	li	a4,6
ffffffffc02030e6:	2781                	sext.w	a5,a5
ffffffffc02030e8:	02e79663          	bne	a5,a4,ffffffffc0203114 <_clock_check_swap+0xd8>
}
ffffffffc02030ec:	60a2                	ld	ra,8(sp)
ffffffffc02030ee:	4501                	li	a0,0
ffffffffc02030f0:	0141                	addi	sp,sp,16
ffffffffc02030f2:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02030f4:	00002697          	auipc	a3,0x2
ffffffffc02030f8:	67468693          	addi	a3,a3,1652 # ffffffffc0205768 <default_pmm_manager+0x888>
ffffffffc02030fc:	00002617          	auipc	a2,0x2
ffffffffc0203100:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203104:	07700593          	li	a1,119
ffffffffc0203108:	00002517          	auipc	a0,0x2
ffffffffc020310c:	7c050513          	addi	a0,a0,1984 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc0203110:	a6efd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==6);
ffffffffc0203114:	00003697          	auipc	a3,0x3
ffffffffc0203118:	80468693          	addi	a3,a3,-2044 # ffffffffc0205918 <default_pmm_manager+0xa38>
ffffffffc020311c:	00002617          	auipc	a2,0x2
ffffffffc0203120:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203124:	08e00593          	li	a1,142
ffffffffc0203128:	00002517          	auipc	a0,0x2
ffffffffc020312c:	7a050513          	addi	a0,a0,1952 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc0203130:	a4efd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203134:	00002697          	auipc	a3,0x2
ffffffffc0203138:	7bc68693          	addi	a3,a3,1980 # ffffffffc02058f0 <default_pmm_manager+0xa10>
ffffffffc020313c:	00002617          	auipc	a2,0x2
ffffffffc0203140:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203144:	08c00593          	li	a1,140
ffffffffc0203148:	00002517          	auipc	a0,0x2
ffffffffc020314c:	78050513          	addi	a0,a0,1920 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc0203150:	a2efd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc0203154:	00002697          	auipc	a3,0x2
ffffffffc0203158:	78c68693          	addi	a3,a3,1932 # ffffffffc02058e0 <default_pmm_manager+0xa00>
ffffffffc020315c:	00002617          	auipc	a2,0x2
ffffffffc0203160:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203164:	08b00593          	li	a1,139
ffffffffc0203168:	00002517          	auipc	a0,0x2
ffffffffc020316c:	76050513          	addi	a0,a0,1888 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc0203170:	a0efd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc0203174:	00002697          	auipc	a3,0x2
ffffffffc0203178:	76c68693          	addi	a3,a3,1900 # ffffffffc02058e0 <default_pmm_manager+0xa00>
ffffffffc020317c:	00002617          	auipc	a2,0x2
ffffffffc0203180:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203184:	08900593          	li	a1,137
ffffffffc0203188:	00002517          	auipc	a0,0x2
ffffffffc020318c:	74050513          	addi	a0,a0,1856 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc0203190:	9eefd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc0203194:	00002697          	auipc	a3,0x2
ffffffffc0203198:	74c68693          	addi	a3,a3,1868 # ffffffffc02058e0 <default_pmm_manager+0xa00>
ffffffffc020319c:	00002617          	auipc	a2,0x2
ffffffffc02031a0:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02031a4:	08700593          	li	a1,135
ffffffffc02031a8:	00002517          	auipc	a0,0x2
ffffffffc02031ac:	72050513          	addi	a0,a0,1824 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc02031b0:	9cefd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc02031b4:	00002697          	auipc	a3,0x2
ffffffffc02031b8:	72c68693          	addi	a3,a3,1836 # ffffffffc02058e0 <default_pmm_manager+0xa00>
ffffffffc02031bc:	00002617          	auipc	a2,0x2
ffffffffc02031c0:	98c60613          	addi	a2,a2,-1652 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02031c4:	08500593          	li	a1,133
ffffffffc02031c8:	00002517          	auipc	a0,0x2
ffffffffc02031cc:	70050513          	addi	a0,a0,1792 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc02031d0:	9aefd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc02031d4:	00002697          	auipc	a3,0x2
ffffffffc02031d8:	70c68693          	addi	a3,a3,1804 # ffffffffc02058e0 <default_pmm_manager+0xa00>
ffffffffc02031dc:	00002617          	auipc	a2,0x2
ffffffffc02031e0:	96c60613          	addi	a2,a2,-1684 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02031e4:	08300593          	li	a1,131
ffffffffc02031e8:	00002517          	auipc	a0,0x2
ffffffffc02031ec:	6e050513          	addi	a0,a0,1760 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc02031f0:	98efd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc02031f4:	00002697          	auipc	a3,0x2
ffffffffc02031f8:	6ec68693          	addi	a3,a3,1772 # ffffffffc02058e0 <default_pmm_manager+0xa00>
ffffffffc02031fc:	00002617          	auipc	a2,0x2
ffffffffc0203200:	94c60613          	addi	a2,a2,-1716 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203204:	08100593          	li	a1,129
ffffffffc0203208:	00002517          	auipc	a0,0x2
ffffffffc020320c:	6c050513          	addi	a0,a0,1728 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc0203210:	96efd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==5);
ffffffffc0203214:	00002697          	auipc	a3,0x2
ffffffffc0203218:	6cc68693          	addi	a3,a3,1740 # ffffffffc02058e0 <default_pmm_manager+0xa00>
ffffffffc020321c:	00002617          	auipc	a2,0x2
ffffffffc0203220:	92c60613          	addi	a2,a2,-1748 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203224:	07f00593          	li	a1,127
ffffffffc0203228:	00002517          	auipc	a0,0x2
ffffffffc020322c:	6a050513          	addi	a0,a0,1696 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc0203230:	94efd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==4);
ffffffffc0203234:	00002697          	auipc	a3,0x2
ffffffffc0203238:	53468693          	addi	a3,a3,1332 # ffffffffc0205768 <default_pmm_manager+0x888>
ffffffffc020323c:	00002617          	auipc	a2,0x2
ffffffffc0203240:	90c60613          	addi	a2,a2,-1780 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203244:	07d00593          	li	a1,125
ffffffffc0203248:	00002517          	auipc	a0,0x2
ffffffffc020324c:	68050513          	addi	a0,a0,1664 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc0203250:	92efd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==4);
ffffffffc0203254:	00002697          	auipc	a3,0x2
ffffffffc0203258:	51468693          	addi	a3,a3,1300 # ffffffffc0205768 <default_pmm_manager+0x888>
ffffffffc020325c:	00002617          	auipc	a2,0x2
ffffffffc0203260:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203264:	07b00593          	li	a1,123
ffffffffc0203268:	00002517          	auipc	a0,0x2
ffffffffc020326c:	66050513          	addi	a0,a0,1632 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc0203270:	90efd0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgfault_num==4);
ffffffffc0203274:	00002697          	auipc	a3,0x2
ffffffffc0203278:	4f468693          	addi	a3,a3,1268 # ffffffffc0205768 <default_pmm_manager+0x888>
ffffffffc020327c:	00002617          	auipc	a2,0x2
ffffffffc0203280:	8cc60613          	addi	a2,a2,-1844 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203284:	07900593          	li	a1,121
ffffffffc0203288:	00002517          	auipc	a0,0x2
ffffffffc020328c:	64050513          	addi	a0,a0,1600 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc0203290:	8eefd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0203294 <_clock_swap_out_victim>:
         assert(head != NULL);
ffffffffc0203294:	751c                	ld	a5,40(a0)
{
ffffffffc0203296:	1141                	addi	sp,sp,-16
ffffffffc0203298:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020329a:	c39d                	beqz	a5,ffffffffc02032c0 <_clock_swap_out_victim+0x2c>
     assert(in_tick==0);
ffffffffc020329c:	e211                	bnez	a2,ffffffffc02032a0 <_clock_swap_out_victim+0xc>
    }
ffffffffc020329e:	a001                	j	ffffffffc020329e <_clock_swap_out_victim+0xa>
     assert(in_tick==0);
ffffffffc02032a0:	00002697          	auipc	a3,0x2
ffffffffc02032a4:	6c068693          	addi	a3,a3,1728 # ffffffffc0205960 <default_pmm_manager+0xa80>
ffffffffc02032a8:	00002617          	auipc	a2,0x2
ffffffffc02032ac:	8a060613          	addi	a2,a2,-1888 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02032b0:	04400593          	li	a1,68
ffffffffc02032b4:	00002517          	auipc	a0,0x2
ffffffffc02032b8:	61450513          	addi	a0,a0,1556 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc02032bc:	8c2fd0ef          	jal	ra,ffffffffc020037e <__panic>
         assert(head != NULL);
ffffffffc02032c0:	00002697          	auipc	a3,0x2
ffffffffc02032c4:	69068693          	addi	a3,a3,1680 # ffffffffc0205950 <default_pmm_manager+0xa70>
ffffffffc02032c8:	00002617          	auipc	a2,0x2
ffffffffc02032cc:	88060613          	addi	a2,a2,-1920 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02032d0:	04300593          	li	a1,67
ffffffffc02032d4:	00002517          	auipc	a0,0x2
ffffffffc02032d8:	5f450513          	addi	a0,a0,1524 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
ffffffffc02032dc:	8a2fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02032e0 <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc02032e0:	03060613          	addi	a2,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02032e4:	ca09                	beqz	a2,ffffffffc02032f6 <_clock_map_swappable+0x16>
ffffffffc02032e6:	0000d797          	auipc	a5,0xd
ffffffffc02032ea:	39a78793          	addi	a5,a5,922 # ffffffffc0210680 <curr_ptr>
ffffffffc02032ee:	639c                	ld	a5,0(a5)
ffffffffc02032f0:	c399                	beqz	a5,ffffffffc02032f6 <_clock_map_swappable+0x16>
}
ffffffffc02032f2:	4501                	li	a0,0
ffffffffc02032f4:	8082                	ret
{
ffffffffc02032f6:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02032f8:	00002697          	auipc	a3,0x2
ffffffffc02032fc:	63068693          	addi	a3,a3,1584 # ffffffffc0205928 <default_pmm_manager+0xa48>
ffffffffc0203300:	00002617          	auipc	a2,0x2
ffffffffc0203304:	84860613          	addi	a2,a2,-1976 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203308:	03300593          	li	a1,51
ffffffffc020330c:	00002517          	auipc	a0,0x2
ffffffffc0203310:	5bc50513          	addi	a0,a0,1468 # ffffffffc02058c8 <default_pmm_manager+0x9e8>
{
ffffffffc0203314:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203316:	868fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc020331a <_clock_tick_event>:
ffffffffc020331a:	4501                	li	a0,0
ffffffffc020331c:	8082                	ret

ffffffffc020331e <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020331e:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203320:	00002697          	auipc	a3,0x2
ffffffffc0203324:	66868693          	addi	a3,a3,1640 # ffffffffc0205988 <default_pmm_manager+0xaa8>
ffffffffc0203328:	00002617          	auipc	a2,0x2
ffffffffc020332c:	82060613          	addi	a2,a2,-2016 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203330:	07d00593          	li	a1,125
ffffffffc0203334:	00002517          	auipc	a0,0x2
ffffffffc0203338:	67450513          	addi	a0,a0,1652 # ffffffffc02059a8 <default_pmm_manager+0xac8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020333c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020333e:	840fd0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0203342 <mm_create>:
mm_create(void) {
ffffffffc0203342:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203344:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203348:	e022                	sd	s0,0(sp)
ffffffffc020334a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020334c:	b8eff0ef          	jal	ra,ffffffffc02026da <kmalloc>
ffffffffc0203350:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203352:	c115                	beqz	a0,ffffffffc0203376 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203354:	0000d797          	auipc	a5,0xd
ffffffffc0203358:	11c78793          	addi	a5,a5,284 # ffffffffc0210470 <swap_init_ok>
ffffffffc020335c:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc020335e:	e408                	sd	a0,8(s0)
ffffffffc0203360:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0203362:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203366:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020336a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020336e:	2781                	sext.w	a5,a5
ffffffffc0203370:	eb81                	bnez	a5,ffffffffc0203380 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0203372:	02053423          	sd	zero,40(a0)
}
ffffffffc0203376:	8522                	mv	a0,s0
ffffffffc0203378:	60a2                	ld	ra,8(sp)
ffffffffc020337a:	6402                	ld	s0,0(sp)
ffffffffc020337c:	0141                	addi	sp,sp,16
ffffffffc020337e:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203380:	b7dff0ef          	jal	ra,ffffffffc0202efc <swap_init_mm>
}
ffffffffc0203384:	8522                	mv	a0,s0
ffffffffc0203386:	60a2                	ld	ra,8(sp)
ffffffffc0203388:	6402                	ld	s0,0(sp)
ffffffffc020338a:	0141                	addi	sp,sp,16
ffffffffc020338c:	8082                	ret

ffffffffc020338e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc020338e:	1101                	addi	sp,sp,-32
ffffffffc0203390:	e04a                	sd	s2,0(sp)
ffffffffc0203392:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203394:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203398:	e822                	sd	s0,16(sp)
ffffffffc020339a:	e426                	sd	s1,8(sp)
ffffffffc020339c:	ec06                	sd	ra,24(sp)
ffffffffc020339e:	84ae                	mv	s1,a1
ffffffffc02033a0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02033a2:	b38ff0ef          	jal	ra,ffffffffc02026da <kmalloc>
    if (vma != NULL) {
ffffffffc02033a6:	c509                	beqz	a0,ffffffffc02033b0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02033a8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02033ac:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02033ae:	ed00                	sd	s0,24(a0)
}
ffffffffc02033b0:	60e2                	ld	ra,24(sp)
ffffffffc02033b2:	6442                	ld	s0,16(sp)
ffffffffc02033b4:	64a2                	ld	s1,8(sp)
ffffffffc02033b6:	6902                	ld	s2,0(sp)
ffffffffc02033b8:	6105                	addi	sp,sp,32
ffffffffc02033ba:	8082                	ret

ffffffffc02033bc <find_vma>:
    if (mm != NULL) {
ffffffffc02033bc:	c51d                	beqz	a0,ffffffffc02033ea <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02033be:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02033c0:	c781                	beqz	a5,ffffffffc02033c8 <find_vma+0xc>
ffffffffc02033c2:	6798                	ld	a4,8(a5)
ffffffffc02033c4:	02e5f663          	bleu	a4,a1,ffffffffc02033f0 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02033c8:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc02033ca:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02033cc:	00f50f63          	beq	a0,a5,ffffffffc02033ea <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02033d0:	fe87b703          	ld	a4,-24(a5)
ffffffffc02033d4:	fee5ebe3          	bltu	a1,a4,ffffffffc02033ca <find_vma+0xe>
ffffffffc02033d8:	ff07b703          	ld	a4,-16(a5)
ffffffffc02033dc:	fee5f7e3          	bleu	a4,a1,ffffffffc02033ca <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02033e0:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02033e2:	c781                	beqz	a5,ffffffffc02033ea <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02033e4:	e91c                	sd	a5,16(a0)
}
ffffffffc02033e6:	853e                	mv	a0,a5
ffffffffc02033e8:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02033ea:	4781                	li	a5,0
}
ffffffffc02033ec:	853e                	mv	a0,a5
ffffffffc02033ee:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02033f0:	6b98                	ld	a4,16(a5)
ffffffffc02033f2:	fce5fbe3          	bleu	a4,a1,ffffffffc02033c8 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02033f6:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02033f8:	b7fd                	j	ffffffffc02033e6 <find_vma+0x2a>

ffffffffc02033fa <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02033fa:	6590                	ld	a2,8(a1)
ffffffffc02033fc:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203400:	1141                	addi	sp,sp,-16
ffffffffc0203402:	e406                	sd	ra,8(sp)
ffffffffc0203404:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203406:	01066863          	bltu	a2,a6,ffffffffc0203416 <insert_vma_struct+0x1c>
ffffffffc020340a:	a8b9                	j	ffffffffc0203468 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020340c:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203410:	04d66763          	bltu	a2,a3,ffffffffc020345e <insert_vma_struct+0x64>
ffffffffc0203414:	873e                	mv	a4,a5
ffffffffc0203416:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0203418:	fef51ae3          	bne	a0,a5,ffffffffc020340c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020341c:	02a70463          	beq	a4,a0,ffffffffc0203444 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203420:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203424:	fe873883          	ld	a7,-24(a4)
ffffffffc0203428:	08d8f063          	bleu	a3,a7,ffffffffc02034a8 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020342c:	04d66e63          	bltu	a2,a3,ffffffffc0203488 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0203430:	00f50a63          	beq	a0,a5,ffffffffc0203444 <insert_vma_struct+0x4a>
ffffffffc0203434:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203438:	0506e863          	bltu	a3,a6,ffffffffc0203488 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc020343c:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203440:	02c6f263          	bleu	a2,a3,ffffffffc0203464 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203444:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0203446:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203448:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020344c:	e390                	sd	a2,0(a5)
ffffffffc020344e:	e710                	sd	a2,8(a4)
}
ffffffffc0203450:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203452:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203454:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0203456:	2685                	addiw	a3,a3,1
ffffffffc0203458:	d114                	sw	a3,32(a0)
}
ffffffffc020345a:	0141                	addi	sp,sp,16
ffffffffc020345c:	8082                	ret
    if (le_prev != list) {
ffffffffc020345e:	fca711e3          	bne	a4,a0,ffffffffc0203420 <insert_vma_struct+0x26>
ffffffffc0203462:	bfd9                	j	ffffffffc0203438 <insert_vma_struct+0x3e>
ffffffffc0203464:	ebbff0ef          	jal	ra,ffffffffc020331e <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203468:	00002697          	auipc	a3,0x2
ffffffffc020346c:	5d068693          	addi	a3,a3,1488 # ffffffffc0205a38 <default_pmm_manager+0xb58>
ffffffffc0203470:	00001617          	auipc	a2,0x1
ffffffffc0203474:	6d860613          	addi	a2,a2,1752 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203478:	08400593          	li	a1,132
ffffffffc020347c:	00002517          	auipc	a0,0x2
ffffffffc0203480:	52c50513          	addi	a0,a0,1324 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203484:	efbfc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203488:	00002697          	auipc	a3,0x2
ffffffffc020348c:	5f068693          	addi	a3,a3,1520 # ffffffffc0205a78 <default_pmm_manager+0xb98>
ffffffffc0203490:	00001617          	auipc	a2,0x1
ffffffffc0203494:	6b860613          	addi	a2,a2,1720 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203498:	07c00593          	li	a1,124
ffffffffc020349c:	00002517          	auipc	a0,0x2
ffffffffc02034a0:	50c50513          	addi	a0,a0,1292 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc02034a4:	edbfc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02034a8:	00002697          	auipc	a3,0x2
ffffffffc02034ac:	5b068693          	addi	a3,a3,1456 # ffffffffc0205a58 <default_pmm_manager+0xb78>
ffffffffc02034b0:	00001617          	auipc	a2,0x1
ffffffffc02034b4:	69860613          	addi	a2,a2,1688 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02034b8:	07b00593          	li	a1,123
ffffffffc02034bc:	00002517          	auipc	a0,0x2
ffffffffc02034c0:	4ec50513          	addi	a0,a0,1260 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc02034c4:	ebbfc0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc02034c8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc02034c8:	1141                	addi	sp,sp,-16
ffffffffc02034ca:	e022                	sd	s0,0(sp)
ffffffffc02034cc:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02034ce:	6508                	ld	a0,8(a0)
ffffffffc02034d0:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02034d2:	00a40e63          	beq	s0,a0,ffffffffc02034ee <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02034d6:	6118                	ld	a4,0(a0)
ffffffffc02034d8:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02034da:	03000593          	li	a1,48
ffffffffc02034de:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02034e0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02034e2:	e398                	sd	a4,0(a5)
ffffffffc02034e4:	ab8ff0ef          	jal	ra,ffffffffc020279c <kfree>
    return listelm->next;
ffffffffc02034e8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02034ea:	fea416e3          	bne	s0,a0,ffffffffc02034d6 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02034ee:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02034f0:	6402                	ld	s0,0(sp)
ffffffffc02034f2:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02034f4:	03000593          	li	a1,48
}
ffffffffc02034f8:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02034fa:	aa2ff06f          	j	ffffffffc020279c <kfree>

ffffffffc02034fe <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02034fe:	715d                	addi	sp,sp,-80
ffffffffc0203500:	e486                	sd	ra,72(sp)
ffffffffc0203502:	e0a2                	sd	s0,64(sp)
ffffffffc0203504:	fc26                	sd	s1,56(sp)
ffffffffc0203506:	f84a                	sd	s2,48(sp)
ffffffffc0203508:	f052                	sd	s4,32(sp)
ffffffffc020350a:	f44e                	sd	s3,40(sp)
ffffffffc020350c:	ec56                	sd	s5,24(sp)
ffffffffc020350e:	e85a                	sd	s6,16(sp)
ffffffffc0203510:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203512:	a6afe0ef          	jal	ra,ffffffffc020177c <nr_free_pages>
ffffffffc0203516:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203518:	a64fe0ef          	jal	ra,ffffffffc020177c <nr_free_pages>
ffffffffc020351c:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc020351e:	e25ff0ef          	jal	ra,ffffffffc0203342 <mm_create>
    assert(mm != NULL);
ffffffffc0203522:	842a                	mv	s0,a0
ffffffffc0203524:	03200493          	li	s1,50
ffffffffc0203528:	e919                	bnez	a0,ffffffffc020353e <vmm_init+0x40>
ffffffffc020352a:	aeed                	j	ffffffffc0203924 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc020352c:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020352e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203530:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203534:	14ed                	addi	s1,s1,-5
ffffffffc0203536:	8522                	mv	a0,s0
ffffffffc0203538:	ec3ff0ef          	jal	ra,ffffffffc02033fa <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc020353c:	c88d                	beqz	s1,ffffffffc020356e <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020353e:	03000513          	li	a0,48
ffffffffc0203542:	998ff0ef          	jal	ra,ffffffffc02026da <kmalloc>
ffffffffc0203546:	85aa                	mv	a1,a0
ffffffffc0203548:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020354c:	f165                	bnez	a0,ffffffffc020352c <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc020354e:	00002697          	auipc	a3,0x2
ffffffffc0203552:	0da68693          	addi	a3,a3,218 # ffffffffc0205628 <default_pmm_manager+0x748>
ffffffffc0203556:	00001617          	auipc	a2,0x1
ffffffffc020355a:	5f260613          	addi	a2,a2,1522 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020355e:	0ce00593          	li	a1,206
ffffffffc0203562:	00002517          	auipc	a0,0x2
ffffffffc0203566:	44650513          	addi	a0,a0,1094 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc020356a:	e15fc0ef          	jal	ra,ffffffffc020037e <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc020356e:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203572:	1f900993          	li	s3,505
ffffffffc0203576:	a819                	j	ffffffffc020358c <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0203578:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020357a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020357c:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203580:	0495                	addi	s1,s1,5
ffffffffc0203582:	8522                	mv	a0,s0
ffffffffc0203584:	e77ff0ef          	jal	ra,ffffffffc02033fa <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203588:	03348a63          	beq	s1,s3,ffffffffc02035bc <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020358c:	03000513          	li	a0,48
ffffffffc0203590:	94aff0ef          	jal	ra,ffffffffc02026da <kmalloc>
ffffffffc0203594:	85aa                	mv	a1,a0
ffffffffc0203596:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020359a:	fd79                	bnez	a0,ffffffffc0203578 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc020359c:	00002697          	auipc	a3,0x2
ffffffffc02035a0:	08c68693          	addi	a3,a3,140 # ffffffffc0205628 <default_pmm_manager+0x748>
ffffffffc02035a4:	00001617          	auipc	a2,0x1
ffffffffc02035a8:	5a460613          	addi	a2,a2,1444 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02035ac:	0d400593          	li	a1,212
ffffffffc02035b0:	00002517          	auipc	a0,0x2
ffffffffc02035b4:	3f850513          	addi	a0,a0,1016 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc02035b8:	dc7fc0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc02035bc:	6418                	ld	a4,8(s0)
ffffffffc02035be:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02035c0:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02035c4:	2ae40063          	beq	s0,a4,ffffffffc0203864 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02035c8:	fe873603          	ld	a2,-24(a4)
ffffffffc02035cc:	ffe78693          	addi	a3,a5,-2
ffffffffc02035d0:	20d61a63          	bne	a2,a3,ffffffffc02037e4 <vmm_init+0x2e6>
ffffffffc02035d4:	ff073683          	ld	a3,-16(a4)
ffffffffc02035d8:	20d79663          	bne	a5,a3,ffffffffc02037e4 <vmm_init+0x2e6>
ffffffffc02035dc:	0795                	addi	a5,a5,5
ffffffffc02035de:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02035e0:	feb792e3          	bne	a5,a1,ffffffffc02035c4 <vmm_init+0xc6>
ffffffffc02035e4:	499d                	li	s3,7
ffffffffc02035e6:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02035e8:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02035ec:	85a6                	mv	a1,s1
ffffffffc02035ee:	8522                	mv	a0,s0
ffffffffc02035f0:	dcdff0ef          	jal	ra,ffffffffc02033bc <find_vma>
ffffffffc02035f4:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc02035f6:	2e050763          	beqz	a0,ffffffffc02038e4 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02035fa:	00148593          	addi	a1,s1,1
ffffffffc02035fe:	8522                	mv	a0,s0
ffffffffc0203600:	dbdff0ef          	jal	ra,ffffffffc02033bc <find_vma>
ffffffffc0203604:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0203606:	2a050f63          	beqz	a0,ffffffffc02038c4 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020360a:	85ce                	mv	a1,s3
ffffffffc020360c:	8522                	mv	a0,s0
ffffffffc020360e:	dafff0ef          	jal	ra,ffffffffc02033bc <find_vma>
        assert(vma3 == NULL);
ffffffffc0203612:	28051963          	bnez	a0,ffffffffc02038a4 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203616:	00348593          	addi	a1,s1,3
ffffffffc020361a:	8522                	mv	a0,s0
ffffffffc020361c:	da1ff0ef          	jal	ra,ffffffffc02033bc <find_vma>
        assert(vma4 == NULL);
ffffffffc0203620:	26051263          	bnez	a0,ffffffffc0203884 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203624:	00448593          	addi	a1,s1,4
ffffffffc0203628:	8522                	mv	a0,s0
ffffffffc020362a:	d93ff0ef          	jal	ra,ffffffffc02033bc <find_vma>
        assert(vma5 == NULL);
ffffffffc020362e:	2c051b63          	bnez	a0,ffffffffc0203904 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203632:	008b3783          	ld	a5,8(s6)
ffffffffc0203636:	1c979763          	bne	a5,s1,ffffffffc0203804 <vmm_init+0x306>
ffffffffc020363a:	010b3783          	ld	a5,16(s6)
ffffffffc020363e:	1d379363          	bne	a5,s3,ffffffffc0203804 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203642:	008ab783          	ld	a5,8(s5)
ffffffffc0203646:	1c979f63          	bne	a5,s1,ffffffffc0203824 <vmm_init+0x326>
ffffffffc020364a:	010ab783          	ld	a5,16(s5)
ffffffffc020364e:	1d379b63          	bne	a5,s3,ffffffffc0203824 <vmm_init+0x326>
ffffffffc0203652:	0495                	addi	s1,s1,5
ffffffffc0203654:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203656:	f9749be3          	bne	s1,s7,ffffffffc02035ec <vmm_init+0xee>
ffffffffc020365a:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020365c:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020365e:	85a6                	mv	a1,s1
ffffffffc0203660:	8522                	mv	a0,s0
ffffffffc0203662:	d5bff0ef          	jal	ra,ffffffffc02033bc <find_vma>
ffffffffc0203666:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc020366a:	c90d                	beqz	a0,ffffffffc020369c <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc020366c:	6914                	ld	a3,16(a0)
ffffffffc020366e:	6510                	ld	a2,8(a0)
ffffffffc0203670:	00002517          	auipc	a0,0x2
ffffffffc0203674:	52850513          	addi	a0,a0,1320 # ffffffffc0205b98 <default_pmm_manager+0xcb8>
ffffffffc0203678:	a51fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020367c:	00002697          	auipc	a3,0x2
ffffffffc0203680:	54468693          	addi	a3,a3,1348 # ffffffffc0205bc0 <default_pmm_manager+0xce0>
ffffffffc0203684:	00001617          	auipc	a2,0x1
ffffffffc0203688:	4c460613          	addi	a2,a2,1220 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc020368c:	0f600593          	li	a1,246
ffffffffc0203690:	00002517          	auipc	a0,0x2
ffffffffc0203694:	31850513          	addi	a0,a0,792 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203698:	ce7fc0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc020369c:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc020369e:	fd3490e3          	bne	s1,s3,ffffffffc020365e <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc02036a2:	8522                	mv	a0,s0
ffffffffc02036a4:	e25ff0ef          	jal	ra,ffffffffc02034c8 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02036a8:	8d4fe0ef          	jal	ra,ffffffffc020177c <nr_free_pages>
ffffffffc02036ac:	28aa1c63          	bne	s4,a0,ffffffffc0203944 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02036b0:	00002517          	auipc	a0,0x2
ffffffffc02036b4:	55050513          	addi	a0,a0,1360 # ffffffffc0205c00 <default_pmm_manager+0xd20>
ffffffffc02036b8:	a11fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02036bc:	8c0fe0ef          	jal	ra,ffffffffc020177c <nr_free_pages>
ffffffffc02036c0:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02036c2:	c81ff0ef          	jal	ra,ffffffffc0203342 <mm_create>
ffffffffc02036c6:	0000d797          	auipc	a5,0xd
ffffffffc02036ca:	fca7b123          	sd	a0,-62(a5) # ffffffffc0210688 <check_mm_struct>
ffffffffc02036ce:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc02036d0:	2a050a63          	beqz	a0,ffffffffc0203984 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02036d4:	0000d797          	auipc	a5,0xd
ffffffffc02036d8:	d8478793          	addi	a5,a5,-636 # ffffffffc0210458 <boot_pgdir>
ffffffffc02036dc:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02036de:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02036e0:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02036e2:	32079d63          	bnez	a5,ffffffffc0203a1c <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02036e6:	03000513          	li	a0,48
ffffffffc02036ea:	ff1fe0ef          	jal	ra,ffffffffc02026da <kmalloc>
ffffffffc02036ee:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc02036f0:	14050a63          	beqz	a0,ffffffffc0203844 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc02036f4:	002007b7          	lui	a5,0x200
ffffffffc02036f8:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02036fc:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02036fe:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203700:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203704:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203706:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc020370a:	cf1ff0ef          	jal	ra,ffffffffc02033fa <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020370e:	10000593          	li	a1,256
ffffffffc0203712:	8522                	mv	a0,s0
ffffffffc0203714:	ca9ff0ef          	jal	ra,ffffffffc02033bc <find_vma>
ffffffffc0203718:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc020371c:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203720:	2aaa1263          	bne	s4,a0,ffffffffc02039c4 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc0203724:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203728:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020372a:	fee79de3          	bne	a5,a4,ffffffffc0203724 <vmm_init+0x226>
        sum += i;
ffffffffc020372e:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203730:	10000793          	li	a5,256
        sum += i;
ffffffffc0203734:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203738:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020373c:	0007c683          	lbu	a3,0(a5)
ffffffffc0203740:	0785                	addi	a5,a5,1
ffffffffc0203742:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203744:	fec79ce3          	bne	a5,a2,ffffffffc020373c <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0203748:	2a071a63          	bnez	a4,ffffffffc02039fc <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020374c:	4581                	li	a1,0
ffffffffc020374e:	8526                	mv	a0,s1
ffffffffc0203750:	ad2fe0ef          	jal	ra,ffffffffc0201a22 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203754:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0203756:	0000d717          	auipc	a4,0xd
ffffffffc020375a:	d0a70713          	addi	a4,a4,-758 # ffffffffc0210460 <npage>
ffffffffc020375e:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203760:	078a                	slli	a5,a5,0x2
ffffffffc0203762:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203764:	28e7f063          	bleu	a4,a5,ffffffffc02039e4 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0203768:	00002717          	auipc	a4,0x2
ffffffffc020376c:	7d870713          	addi	a4,a4,2008 # ffffffffc0205f40 <nbase>
ffffffffc0203770:	6318                	ld	a4,0(a4)
ffffffffc0203772:	0000d697          	auipc	a3,0xd
ffffffffc0203776:	e2e68693          	addi	a3,a3,-466 # ffffffffc02105a0 <pages>
ffffffffc020377a:	6288                	ld	a0,0(a3)
ffffffffc020377c:	8f99                	sub	a5,a5,a4
ffffffffc020377e:	00379713          	slli	a4,a5,0x3
ffffffffc0203782:	97ba                	add	a5,a5,a4
ffffffffc0203784:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203786:	953e                	add	a0,a0,a5
ffffffffc0203788:	4585                	li	a1,1
ffffffffc020378a:	fadfd0ef          	jal	ra,ffffffffc0201736 <free_pages>

    pgdir[0] = 0;
ffffffffc020378e:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0203792:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0203794:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0203798:	d31ff0ef          	jal	ra,ffffffffc02034c8 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc020379c:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc020379e:	0000d797          	auipc	a5,0xd
ffffffffc02037a2:	ee07b523          	sd	zero,-278(a5) # ffffffffc0210688 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02037a6:	fd7fd0ef          	jal	ra,ffffffffc020177c <nr_free_pages>
ffffffffc02037aa:	1aa99d63          	bne	s3,a0,ffffffffc0203964 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02037ae:	00002517          	auipc	a0,0x2
ffffffffc02037b2:	4ba50513          	addi	a0,a0,1210 # ffffffffc0205c68 <default_pmm_manager+0xd88>
ffffffffc02037b6:	913fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02037ba:	fc3fd0ef          	jal	ra,ffffffffc020177c <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc02037be:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02037c0:	1ea91263          	bne	s2,a0,ffffffffc02039a4 <vmm_init+0x4a6>
}
ffffffffc02037c4:	6406                	ld	s0,64(sp)
ffffffffc02037c6:	60a6                	ld	ra,72(sp)
ffffffffc02037c8:	74e2                	ld	s1,56(sp)
ffffffffc02037ca:	7942                	ld	s2,48(sp)
ffffffffc02037cc:	79a2                	ld	s3,40(sp)
ffffffffc02037ce:	7a02                	ld	s4,32(sp)
ffffffffc02037d0:	6ae2                	ld	s5,24(sp)
ffffffffc02037d2:	6b42                	ld	s6,16(sp)
ffffffffc02037d4:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02037d6:	00002517          	auipc	a0,0x2
ffffffffc02037da:	4b250513          	addi	a0,a0,1202 # ffffffffc0205c88 <default_pmm_manager+0xda8>
}
ffffffffc02037de:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc02037e0:	8e9fc06f          	j	ffffffffc02000c8 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02037e4:	00002697          	auipc	a3,0x2
ffffffffc02037e8:	2cc68693          	addi	a3,a3,716 # ffffffffc0205ab0 <default_pmm_manager+0xbd0>
ffffffffc02037ec:	00001617          	auipc	a2,0x1
ffffffffc02037f0:	35c60613          	addi	a2,a2,860 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02037f4:	0dd00593          	li	a1,221
ffffffffc02037f8:	00002517          	auipc	a0,0x2
ffffffffc02037fc:	1b050513          	addi	a0,a0,432 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203800:	b7ffc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203804:	00002697          	auipc	a3,0x2
ffffffffc0203808:	33468693          	addi	a3,a3,820 # ffffffffc0205b38 <default_pmm_manager+0xc58>
ffffffffc020380c:	00001617          	auipc	a2,0x1
ffffffffc0203810:	33c60613          	addi	a2,a2,828 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203814:	0ed00593          	li	a1,237
ffffffffc0203818:	00002517          	auipc	a0,0x2
ffffffffc020381c:	19050513          	addi	a0,a0,400 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203820:	b5ffc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203824:	00002697          	auipc	a3,0x2
ffffffffc0203828:	34468693          	addi	a3,a3,836 # ffffffffc0205b68 <default_pmm_manager+0xc88>
ffffffffc020382c:	00001617          	auipc	a2,0x1
ffffffffc0203830:	31c60613          	addi	a2,a2,796 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203834:	0ee00593          	li	a1,238
ffffffffc0203838:	00002517          	auipc	a0,0x2
ffffffffc020383c:	17050513          	addi	a0,a0,368 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203840:	b3ffc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(vma != NULL);
ffffffffc0203844:	00002697          	auipc	a3,0x2
ffffffffc0203848:	de468693          	addi	a3,a3,-540 # ffffffffc0205628 <default_pmm_manager+0x748>
ffffffffc020384c:	00001617          	auipc	a2,0x1
ffffffffc0203850:	2fc60613          	addi	a2,a2,764 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203854:	11100593          	li	a1,273
ffffffffc0203858:	00002517          	auipc	a0,0x2
ffffffffc020385c:	15050513          	addi	a0,a0,336 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203860:	b1ffc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203864:	00002697          	auipc	a3,0x2
ffffffffc0203868:	23468693          	addi	a3,a3,564 # ffffffffc0205a98 <default_pmm_manager+0xbb8>
ffffffffc020386c:	00001617          	auipc	a2,0x1
ffffffffc0203870:	2dc60613          	addi	a2,a2,732 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203874:	0db00593          	li	a1,219
ffffffffc0203878:	00002517          	auipc	a0,0x2
ffffffffc020387c:	13050513          	addi	a0,a0,304 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203880:	afffc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma4 == NULL);
ffffffffc0203884:	00002697          	auipc	a3,0x2
ffffffffc0203888:	29468693          	addi	a3,a3,660 # ffffffffc0205b18 <default_pmm_manager+0xc38>
ffffffffc020388c:	00001617          	auipc	a2,0x1
ffffffffc0203890:	2bc60613          	addi	a2,a2,700 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203894:	0e900593          	li	a1,233
ffffffffc0203898:	00002517          	auipc	a0,0x2
ffffffffc020389c:	11050513          	addi	a0,a0,272 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc02038a0:	adffc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma3 == NULL);
ffffffffc02038a4:	00002697          	auipc	a3,0x2
ffffffffc02038a8:	26468693          	addi	a3,a3,612 # ffffffffc0205b08 <default_pmm_manager+0xc28>
ffffffffc02038ac:	00001617          	auipc	a2,0x1
ffffffffc02038b0:	29c60613          	addi	a2,a2,668 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02038b4:	0e700593          	li	a1,231
ffffffffc02038b8:	00002517          	auipc	a0,0x2
ffffffffc02038bc:	0f050513          	addi	a0,a0,240 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc02038c0:	abffc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma2 != NULL);
ffffffffc02038c4:	00002697          	auipc	a3,0x2
ffffffffc02038c8:	23468693          	addi	a3,a3,564 # ffffffffc0205af8 <default_pmm_manager+0xc18>
ffffffffc02038cc:	00001617          	auipc	a2,0x1
ffffffffc02038d0:	27c60613          	addi	a2,a2,636 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02038d4:	0e500593          	li	a1,229
ffffffffc02038d8:	00002517          	auipc	a0,0x2
ffffffffc02038dc:	0d050513          	addi	a0,a0,208 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc02038e0:	a9ffc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma1 != NULL);
ffffffffc02038e4:	00002697          	auipc	a3,0x2
ffffffffc02038e8:	20468693          	addi	a3,a3,516 # ffffffffc0205ae8 <default_pmm_manager+0xc08>
ffffffffc02038ec:	00001617          	auipc	a2,0x1
ffffffffc02038f0:	25c60613          	addi	a2,a2,604 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02038f4:	0e300593          	li	a1,227
ffffffffc02038f8:	00002517          	auipc	a0,0x2
ffffffffc02038fc:	0b050513          	addi	a0,a0,176 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203900:	a7ffc0ef          	jal	ra,ffffffffc020037e <__panic>
        assert(vma5 == NULL);
ffffffffc0203904:	00002697          	auipc	a3,0x2
ffffffffc0203908:	22468693          	addi	a3,a3,548 # ffffffffc0205b28 <default_pmm_manager+0xc48>
ffffffffc020390c:	00001617          	auipc	a2,0x1
ffffffffc0203910:	23c60613          	addi	a2,a2,572 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203914:	0eb00593          	li	a1,235
ffffffffc0203918:	00002517          	auipc	a0,0x2
ffffffffc020391c:	09050513          	addi	a0,a0,144 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203920:	a5ffc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(mm != NULL);
ffffffffc0203924:	00002697          	auipc	a3,0x2
ffffffffc0203928:	ccc68693          	addi	a3,a3,-820 # ffffffffc02055f0 <default_pmm_manager+0x710>
ffffffffc020392c:	00001617          	auipc	a2,0x1
ffffffffc0203930:	21c60613          	addi	a2,a2,540 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203934:	0c700593          	li	a1,199
ffffffffc0203938:	00002517          	auipc	a0,0x2
ffffffffc020393c:	07050513          	addi	a0,a0,112 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203940:	a3ffc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203944:	00002697          	auipc	a3,0x2
ffffffffc0203948:	29468693          	addi	a3,a3,660 # ffffffffc0205bd8 <default_pmm_manager+0xcf8>
ffffffffc020394c:	00001617          	auipc	a2,0x1
ffffffffc0203950:	1fc60613          	addi	a2,a2,508 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203954:	0fb00593          	li	a1,251
ffffffffc0203958:	00002517          	auipc	a0,0x2
ffffffffc020395c:	05050513          	addi	a0,a0,80 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203960:	a1ffc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203964:	00002697          	auipc	a3,0x2
ffffffffc0203968:	27468693          	addi	a3,a3,628 # ffffffffc0205bd8 <default_pmm_manager+0xcf8>
ffffffffc020396c:	00001617          	auipc	a2,0x1
ffffffffc0203970:	1dc60613          	addi	a2,a2,476 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203974:	12e00593          	li	a1,302
ffffffffc0203978:	00002517          	auipc	a0,0x2
ffffffffc020397c:	03050513          	addi	a0,a0,48 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203980:	9fffc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203984:	00002697          	auipc	a3,0x2
ffffffffc0203988:	29c68693          	addi	a3,a3,668 # ffffffffc0205c20 <default_pmm_manager+0xd40>
ffffffffc020398c:	00001617          	auipc	a2,0x1
ffffffffc0203990:	1bc60613          	addi	a2,a2,444 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203994:	10a00593          	li	a1,266
ffffffffc0203998:	00002517          	auipc	a0,0x2
ffffffffc020399c:	01050513          	addi	a0,a0,16 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc02039a0:	9dffc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02039a4:	00002697          	auipc	a3,0x2
ffffffffc02039a8:	23468693          	addi	a3,a3,564 # ffffffffc0205bd8 <default_pmm_manager+0xcf8>
ffffffffc02039ac:	00001617          	auipc	a2,0x1
ffffffffc02039b0:	19c60613          	addi	a2,a2,412 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02039b4:	0bd00593          	li	a1,189
ffffffffc02039b8:	00002517          	auipc	a0,0x2
ffffffffc02039bc:	ff050513          	addi	a0,a0,-16 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc02039c0:	9bffc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02039c4:	00002697          	auipc	a3,0x2
ffffffffc02039c8:	27468693          	addi	a3,a3,628 # ffffffffc0205c38 <default_pmm_manager+0xd58>
ffffffffc02039cc:	00001617          	auipc	a2,0x1
ffffffffc02039d0:	17c60613          	addi	a2,a2,380 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc02039d4:	11600593          	li	a1,278
ffffffffc02039d8:	00002517          	auipc	a0,0x2
ffffffffc02039dc:	fd050513          	addi	a0,a0,-48 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc02039e0:	99ffc0ef          	jal	ra,ffffffffc020037e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02039e4:	00001617          	auipc	a2,0x1
ffffffffc02039e8:	5c460613          	addi	a2,a2,1476 # ffffffffc0204fa8 <default_pmm_manager+0xc8>
ffffffffc02039ec:	06500593          	li	a1,101
ffffffffc02039f0:	00001517          	auipc	a0,0x1
ffffffffc02039f4:	5d850513          	addi	a0,a0,1496 # ffffffffc0204fc8 <default_pmm_manager+0xe8>
ffffffffc02039f8:	987fc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(sum == 0);
ffffffffc02039fc:	00002697          	auipc	a3,0x2
ffffffffc0203a00:	25c68693          	addi	a3,a3,604 # ffffffffc0205c58 <default_pmm_manager+0xd78>
ffffffffc0203a04:	00001617          	auipc	a2,0x1
ffffffffc0203a08:	14460613          	addi	a2,a2,324 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203a0c:	12000593          	li	a1,288
ffffffffc0203a10:	00002517          	auipc	a0,0x2
ffffffffc0203a14:	f9850513          	addi	a0,a0,-104 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203a18:	967fc0ef          	jal	ra,ffffffffc020037e <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203a1c:	00002697          	auipc	a3,0x2
ffffffffc0203a20:	bfc68693          	addi	a3,a3,-1028 # ffffffffc0205618 <default_pmm_manager+0x738>
ffffffffc0203a24:	00001617          	auipc	a2,0x1
ffffffffc0203a28:	12460613          	addi	a2,a2,292 # ffffffffc0204b48 <commands+0x8d8>
ffffffffc0203a2c:	10d00593          	li	a1,269
ffffffffc0203a30:	00002517          	auipc	a0,0x2
ffffffffc0203a34:	f7850513          	addi	a0,a0,-136 # ffffffffc02059a8 <default_pmm_manager+0xac8>
ffffffffc0203a38:	947fc0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0203a3c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203a3c:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203a3e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203a40:	e822                	sd	s0,16(sp)
ffffffffc0203a42:	e426                	sd	s1,8(sp)
ffffffffc0203a44:	ec06                	sd	ra,24(sp)
ffffffffc0203a46:	e04a                	sd	s2,0(sp)
ffffffffc0203a48:	8432                	mv	s0,a2
ffffffffc0203a4a:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203a4c:	971ff0ef          	jal	ra,ffffffffc02033bc <find_vma>

    pgfault_num++;
ffffffffc0203a50:	0000d797          	auipc	a5,0xd
ffffffffc0203a54:	a2478793          	addi	a5,a5,-1500 # ffffffffc0210474 <pgfault_num>
ffffffffc0203a58:	439c                	lw	a5,0(a5)
ffffffffc0203a5a:	2785                	addiw	a5,a5,1
ffffffffc0203a5c:	0000d717          	auipc	a4,0xd
ffffffffc0203a60:	a0f72c23          	sw	a5,-1512(a4) # ffffffffc0210474 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203a64:	c939                	beqz	a0,ffffffffc0203aba <do_pgfault+0x7e>
ffffffffc0203a66:	651c                	ld	a5,8(a0)
ffffffffc0203a68:	04f46963          	bltu	s0,a5,ffffffffc0203aba <do_pgfault+0x7e>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203a6c:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203a6e:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203a70:	8b89                	andi	a5,a5,2
ffffffffc0203a72:	e785                	bnez	a5,ffffffffc0203a9a <do_pgfault+0x5e>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203a74:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203a76:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203a78:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203a7a:	85a2                	mv	a1,s0
ffffffffc0203a7c:	4605                	li	a2,1
ffffffffc0203a7e:	d3ffd0ef          	jal	ra,ffffffffc02017bc <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203a82:	610c                	ld	a1,0(a0)
ffffffffc0203a84:	cd89                	beqz	a1,ffffffffc0203a9e <do_pgfault+0x62>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203a86:	0000d797          	auipc	a5,0xd
ffffffffc0203a8a:	9ea78793          	addi	a5,a5,-1558 # ffffffffc0210470 <swap_init_ok>
ffffffffc0203a8e:	439c                	lw	a5,0(a5)
ffffffffc0203a90:	2781                	sext.w	a5,a5
ffffffffc0203a92:	cf8d                	beqz	a5,ffffffffc0203acc <do_pgfault+0x90>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc0203a94:	04003023          	sd	zero,64(zero) # 40 <BASE_ADDRESS-0xffffffffc01fffc0>
ffffffffc0203a98:	9002                	ebreak
        perm |= (PTE_R | PTE_W);
ffffffffc0203a9a:	4959                	li	s2,22
ffffffffc0203a9c:	bfe1                	j	ffffffffc0203a74 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203a9e:	6c88                	ld	a0,24(s1)
ffffffffc0203aa0:	864a                	mv	a2,s2
ffffffffc0203aa2:	85a2                	mv	a1,s0
ffffffffc0203aa4:	ba5fe0ef          	jal	ra,ffffffffc0202648 <pgdir_alloc_page>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203aa8:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203aaa:	c90d                	beqz	a0,ffffffffc0203adc <do_pgfault+0xa0>
failed:
    return ret;
}
ffffffffc0203aac:	60e2                	ld	ra,24(sp)
ffffffffc0203aae:	6442                	ld	s0,16(sp)
ffffffffc0203ab0:	64a2                	ld	s1,8(sp)
ffffffffc0203ab2:	6902                	ld	s2,0(sp)
ffffffffc0203ab4:	853e                	mv	a0,a5
ffffffffc0203ab6:	6105                	addi	sp,sp,32
ffffffffc0203ab8:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203aba:	85a2                	mv	a1,s0
ffffffffc0203abc:	00002517          	auipc	a0,0x2
ffffffffc0203ac0:	efc50513          	addi	a0,a0,-260 # ffffffffc02059b8 <default_pmm_manager+0xad8>
ffffffffc0203ac4:	e04fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203ac8:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203aca:	b7cd                	j	ffffffffc0203aac <do_pgfault+0x70>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203acc:	00002517          	auipc	a0,0x2
ffffffffc0203ad0:	f4450513          	addi	a0,a0,-188 # ffffffffc0205a10 <default_pmm_manager+0xb30>
ffffffffc0203ad4:	df4fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203ad8:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203ada:	bfc9                	j	ffffffffc0203aac <do_pgfault+0x70>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203adc:	00002517          	auipc	a0,0x2
ffffffffc0203ae0:	f0c50513          	addi	a0,a0,-244 # ffffffffc02059e8 <default_pmm_manager+0xb08>
ffffffffc0203ae4:	de4fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203ae8:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203aea:	b7c9                	j	ffffffffc0203aac <do_pgfault+0x70>

ffffffffc0203aec <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203aec:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203aee:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203af0:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203af2:	9b7fc0ef          	jal	ra,ffffffffc02004a8 <ide_device_valid>
ffffffffc0203af6:	cd01                	beqz	a0,ffffffffc0203b0e <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203af8:	4505                	li	a0,1
ffffffffc0203afa:	9b5fc0ef          	jal	ra,ffffffffc02004ae <ide_device_size>
}
ffffffffc0203afe:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203b00:	810d                	srli	a0,a0,0x3
ffffffffc0203b02:	0000d797          	auipc	a5,0xd
ffffffffc0203b06:	b2a7b723          	sd	a0,-1234(a5) # ffffffffc0210630 <max_swap_offset>
}
ffffffffc0203b0a:	0141                	addi	sp,sp,16
ffffffffc0203b0c:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203b0e:	00002617          	auipc	a2,0x2
ffffffffc0203b12:	19260613          	addi	a2,a2,402 # ffffffffc0205ca0 <default_pmm_manager+0xdc0>
ffffffffc0203b16:	45b5                	li	a1,13
ffffffffc0203b18:	00002517          	auipc	a0,0x2
ffffffffc0203b1c:	1a850513          	addi	a0,a0,424 # ffffffffc0205cc0 <default_pmm_manager+0xde0>
ffffffffc0203b20:	85ffc0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0203b24 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203b24:	1141                	addi	sp,sp,-16
ffffffffc0203b26:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b28:	00855793          	srli	a5,a0,0x8
ffffffffc0203b2c:	c7b5                	beqz	a5,ffffffffc0203b98 <swapfs_write+0x74>
ffffffffc0203b2e:	0000d717          	auipc	a4,0xd
ffffffffc0203b32:	b0270713          	addi	a4,a4,-1278 # ffffffffc0210630 <max_swap_offset>
ffffffffc0203b36:	6318                	ld	a4,0(a4)
ffffffffc0203b38:	06e7f063          	bleu	a4,a5,ffffffffc0203b98 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203b3c:	0000d717          	auipc	a4,0xd
ffffffffc0203b40:	a6470713          	addi	a4,a4,-1436 # ffffffffc02105a0 <pages>
ffffffffc0203b44:	6310                	ld	a2,0(a4)
ffffffffc0203b46:	00001717          	auipc	a4,0x1
ffffffffc0203b4a:	fea70713          	addi	a4,a4,-22 # ffffffffc0204b30 <commands+0x8c0>
ffffffffc0203b4e:	00002697          	auipc	a3,0x2
ffffffffc0203b52:	3f268693          	addi	a3,a3,1010 # ffffffffc0205f40 <nbase>
ffffffffc0203b56:	40c58633          	sub	a2,a1,a2
ffffffffc0203b5a:	630c                	ld	a1,0(a4)
ffffffffc0203b5c:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b5e:	0000d717          	auipc	a4,0xd
ffffffffc0203b62:	90270713          	addi	a4,a4,-1790 # ffffffffc0210460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203b66:	02b60633          	mul	a2,a2,a1
ffffffffc0203b6a:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203b6e:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b70:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203b72:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b74:	57fd                	li	a5,-1
ffffffffc0203b76:	83b1                	srli	a5,a5,0xc
ffffffffc0203b78:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b7a:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b7c:	02e7fa63          	bleu	a4,a5,ffffffffc0203bb0 <swapfs_write+0x8c>
ffffffffc0203b80:	0000d797          	auipc	a5,0xd
ffffffffc0203b84:	a1078793          	addi	a5,a5,-1520 # ffffffffc0210590 <va_pa_offset>
ffffffffc0203b88:	639c                	ld	a5,0(a5)
}
ffffffffc0203b8a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b8c:	46a1                	li	a3,8
ffffffffc0203b8e:	963e                	add	a2,a2,a5
ffffffffc0203b90:	4505                	li	a0,1
}
ffffffffc0203b92:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b94:	921fc06f          	j	ffffffffc02004b4 <ide_write_secs>
ffffffffc0203b98:	86aa                	mv	a3,a0
ffffffffc0203b9a:	00002617          	auipc	a2,0x2
ffffffffc0203b9e:	13e60613          	addi	a2,a2,318 # ffffffffc0205cd8 <default_pmm_manager+0xdf8>
ffffffffc0203ba2:	45e5                	li	a1,25
ffffffffc0203ba4:	00002517          	auipc	a0,0x2
ffffffffc0203ba8:	11c50513          	addi	a0,a0,284 # ffffffffc0205cc0 <default_pmm_manager+0xde0>
ffffffffc0203bac:	fd2fc0ef          	jal	ra,ffffffffc020037e <__panic>
ffffffffc0203bb0:	86b2                	mv	a3,a2
ffffffffc0203bb2:	06a00593          	li	a1,106
ffffffffc0203bb6:	00001617          	auipc	a2,0x1
ffffffffc0203bba:	37a60613          	addi	a2,a2,890 # ffffffffc0204f30 <default_pmm_manager+0x50>
ffffffffc0203bbe:	00001517          	auipc	a0,0x1
ffffffffc0203bc2:	40a50513          	addi	a0,a0,1034 # ffffffffc0204fc8 <default_pmm_manager+0xe8>
ffffffffc0203bc6:	fb8fc0ef          	jal	ra,ffffffffc020037e <__panic>

ffffffffc0203bca <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203bca:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203bce:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203bd0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203bd4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203bd6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203bda:	f022                	sd	s0,32(sp)
ffffffffc0203bdc:	ec26                	sd	s1,24(sp)
ffffffffc0203bde:	e84a                	sd	s2,16(sp)
ffffffffc0203be0:	f406                	sd	ra,40(sp)
ffffffffc0203be2:	e44e                	sd	s3,8(sp)
ffffffffc0203be4:	84aa                	mv	s1,a0
ffffffffc0203be6:	892e                	mv	s2,a1
ffffffffc0203be8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203bec:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203bee:	03067e63          	bleu	a6,a2,ffffffffc0203c2a <printnum+0x60>
ffffffffc0203bf2:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203bf4:	00805763          	blez	s0,ffffffffc0203c02 <printnum+0x38>
ffffffffc0203bf8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203bfa:	85ca                	mv	a1,s2
ffffffffc0203bfc:	854e                	mv	a0,s3
ffffffffc0203bfe:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203c00:	fc65                	bnez	s0,ffffffffc0203bf8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203c02:	1a02                	slli	s4,s4,0x20
ffffffffc0203c04:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203c08:	00002797          	auipc	a5,0x2
ffffffffc0203c0c:	28078793          	addi	a5,a5,640 # ffffffffc0205e88 <error_string+0x38>
ffffffffc0203c10:	9a3e                	add	s4,s4,a5
}
ffffffffc0203c12:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203c14:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203c18:	70a2                	ld	ra,40(sp)
ffffffffc0203c1a:	69a2                	ld	s3,8(sp)
ffffffffc0203c1c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203c1e:	85ca                	mv	a1,s2
ffffffffc0203c20:	8326                	mv	t1,s1
}
ffffffffc0203c22:	6942                	ld	s2,16(sp)
ffffffffc0203c24:	64e2                	ld	s1,24(sp)
ffffffffc0203c26:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203c28:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203c2a:	03065633          	divu	a2,a2,a6
ffffffffc0203c2e:	8722                	mv	a4,s0
ffffffffc0203c30:	f9bff0ef          	jal	ra,ffffffffc0203bca <printnum>
ffffffffc0203c34:	b7f9                	j	ffffffffc0203c02 <printnum+0x38>

ffffffffc0203c36 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203c36:	7119                	addi	sp,sp,-128
ffffffffc0203c38:	f4a6                	sd	s1,104(sp)
ffffffffc0203c3a:	f0ca                	sd	s2,96(sp)
ffffffffc0203c3c:	e8d2                	sd	s4,80(sp)
ffffffffc0203c3e:	e4d6                	sd	s5,72(sp)
ffffffffc0203c40:	e0da                	sd	s6,64(sp)
ffffffffc0203c42:	fc5e                	sd	s7,56(sp)
ffffffffc0203c44:	f862                	sd	s8,48(sp)
ffffffffc0203c46:	f06a                	sd	s10,32(sp)
ffffffffc0203c48:	fc86                	sd	ra,120(sp)
ffffffffc0203c4a:	f8a2                	sd	s0,112(sp)
ffffffffc0203c4c:	ecce                	sd	s3,88(sp)
ffffffffc0203c4e:	f466                	sd	s9,40(sp)
ffffffffc0203c50:	ec6e                	sd	s11,24(sp)
ffffffffc0203c52:	892a                	mv	s2,a0
ffffffffc0203c54:	84ae                	mv	s1,a1
ffffffffc0203c56:	8d32                	mv	s10,a2
ffffffffc0203c58:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203c5a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c5c:	00002a17          	auipc	s4,0x2
ffffffffc0203c60:	09ca0a13          	addi	s4,s4,156 # ffffffffc0205cf8 <default_pmm_manager+0xe18>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203c64:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203c68:	00002c17          	auipc	s8,0x2
ffffffffc0203c6c:	1e8c0c13          	addi	s8,s8,488 # ffffffffc0205e50 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203c70:	000d4503          	lbu	a0,0(s10)
ffffffffc0203c74:	02500793          	li	a5,37
ffffffffc0203c78:	001d0413          	addi	s0,s10,1
ffffffffc0203c7c:	00f50e63          	beq	a0,a5,ffffffffc0203c98 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203c80:	c521                	beqz	a0,ffffffffc0203cc8 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203c82:	02500993          	li	s3,37
ffffffffc0203c86:	a011                	j	ffffffffc0203c8a <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203c88:	c121                	beqz	a0,ffffffffc0203cc8 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203c8a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203c8c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203c8e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203c90:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203c94:	ff351ae3          	bne	a0,s3,ffffffffc0203c88 <vprintfmt+0x52>
ffffffffc0203c98:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203c9c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203ca0:	4981                	li	s3,0
ffffffffc0203ca2:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203ca4:	5cfd                	li	s9,-1
ffffffffc0203ca6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ca8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203cac:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cae:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203cb2:	0ff6f693          	andi	a3,a3,255
ffffffffc0203cb6:	00140d13          	addi	s10,s0,1
ffffffffc0203cba:	20d5e563          	bltu	a1,a3,ffffffffc0203ec4 <vprintfmt+0x28e>
ffffffffc0203cbe:	068a                	slli	a3,a3,0x2
ffffffffc0203cc0:	96d2                	add	a3,a3,s4
ffffffffc0203cc2:	4294                	lw	a3,0(a3)
ffffffffc0203cc4:	96d2                	add	a3,a3,s4
ffffffffc0203cc6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203cc8:	70e6                	ld	ra,120(sp)
ffffffffc0203cca:	7446                	ld	s0,112(sp)
ffffffffc0203ccc:	74a6                	ld	s1,104(sp)
ffffffffc0203cce:	7906                	ld	s2,96(sp)
ffffffffc0203cd0:	69e6                	ld	s3,88(sp)
ffffffffc0203cd2:	6a46                	ld	s4,80(sp)
ffffffffc0203cd4:	6aa6                	ld	s5,72(sp)
ffffffffc0203cd6:	6b06                	ld	s6,64(sp)
ffffffffc0203cd8:	7be2                	ld	s7,56(sp)
ffffffffc0203cda:	7c42                	ld	s8,48(sp)
ffffffffc0203cdc:	7ca2                	ld	s9,40(sp)
ffffffffc0203cde:	7d02                	ld	s10,32(sp)
ffffffffc0203ce0:	6de2                	ld	s11,24(sp)
ffffffffc0203ce2:	6109                	addi	sp,sp,128
ffffffffc0203ce4:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203ce6:	4705                	li	a4,1
ffffffffc0203ce8:	008a8593          	addi	a1,s5,8
ffffffffc0203cec:	01074463          	blt	a4,a6,ffffffffc0203cf4 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203cf0:	26080363          	beqz	a6,ffffffffc0203f56 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203cf4:	000ab603          	ld	a2,0(s5)
ffffffffc0203cf8:	46c1                	li	a3,16
ffffffffc0203cfa:	8aae                	mv	s5,a1
ffffffffc0203cfc:	a06d                	j	ffffffffc0203da6 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203cfe:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203d02:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d04:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203d06:	b765                	j	ffffffffc0203cae <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203d08:	000aa503          	lw	a0,0(s5)
ffffffffc0203d0c:	85a6                	mv	a1,s1
ffffffffc0203d0e:	0aa1                	addi	s5,s5,8
ffffffffc0203d10:	9902                	jalr	s2
            break;
ffffffffc0203d12:	bfb9                	j	ffffffffc0203c70 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203d14:	4705                	li	a4,1
ffffffffc0203d16:	008a8993          	addi	s3,s5,8
ffffffffc0203d1a:	01074463          	blt	a4,a6,ffffffffc0203d22 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203d1e:	22080463          	beqz	a6,ffffffffc0203f46 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203d22:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203d26:	24044463          	bltz	s0,ffffffffc0203f6e <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203d2a:	8622                	mv	a2,s0
ffffffffc0203d2c:	8ace                	mv	s5,s3
ffffffffc0203d2e:	46a9                	li	a3,10
ffffffffc0203d30:	a89d                	j	ffffffffc0203da6 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203d32:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203d36:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203d38:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203d3a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203d3e:	8fb5                	xor	a5,a5,a3
ffffffffc0203d40:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203d44:	1ad74363          	blt	a4,a3,ffffffffc0203eea <vprintfmt+0x2b4>
ffffffffc0203d48:	00369793          	slli	a5,a3,0x3
ffffffffc0203d4c:	97e2                	add	a5,a5,s8
ffffffffc0203d4e:	639c                	ld	a5,0(a5)
ffffffffc0203d50:	18078d63          	beqz	a5,ffffffffc0203eea <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203d54:	86be                	mv	a3,a5
ffffffffc0203d56:	00002617          	auipc	a2,0x2
ffffffffc0203d5a:	1e260613          	addi	a2,a2,482 # ffffffffc0205f38 <error_string+0xe8>
ffffffffc0203d5e:	85a6                	mv	a1,s1
ffffffffc0203d60:	854a                	mv	a0,s2
ffffffffc0203d62:	240000ef          	jal	ra,ffffffffc0203fa2 <printfmt>
ffffffffc0203d66:	b729                	j	ffffffffc0203c70 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203d68:	00144603          	lbu	a2,1(s0)
ffffffffc0203d6c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d6e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203d70:	bf3d                	j	ffffffffc0203cae <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203d72:	4705                	li	a4,1
ffffffffc0203d74:	008a8593          	addi	a1,s5,8
ffffffffc0203d78:	01074463          	blt	a4,a6,ffffffffc0203d80 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203d7c:	1e080263          	beqz	a6,ffffffffc0203f60 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203d80:	000ab603          	ld	a2,0(s5)
ffffffffc0203d84:	46a1                	li	a3,8
ffffffffc0203d86:	8aae                	mv	s5,a1
ffffffffc0203d88:	a839                	j	ffffffffc0203da6 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0203d8a:	03000513          	li	a0,48
ffffffffc0203d8e:	85a6                	mv	a1,s1
ffffffffc0203d90:	e03e                	sd	a5,0(sp)
ffffffffc0203d92:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203d94:	85a6                	mv	a1,s1
ffffffffc0203d96:	07800513          	li	a0,120
ffffffffc0203d9a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203d9c:	0aa1                	addi	s5,s5,8
ffffffffc0203d9e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203da2:	6782                	ld	a5,0(sp)
ffffffffc0203da4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203da6:	876e                	mv	a4,s11
ffffffffc0203da8:	85a6                	mv	a1,s1
ffffffffc0203daa:	854a                	mv	a0,s2
ffffffffc0203dac:	e1fff0ef          	jal	ra,ffffffffc0203bca <printnum>
            break;
ffffffffc0203db0:	b5c1                	j	ffffffffc0203c70 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203db2:	000ab603          	ld	a2,0(s5)
ffffffffc0203db6:	0aa1                	addi	s5,s5,8
ffffffffc0203db8:	1c060663          	beqz	a2,ffffffffc0203f84 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0203dbc:	00160413          	addi	s0,a2,1
ffffffffc0203dc0:	17b05c63          	blez	s11,ffffffffc0203f38 <vprintfmt+0x302>
ffffffffc0203dc4:	02d00593          	li	a1,45
ffffffffc0203dc8:	14b79263          	bne	a5,a1,ffffffffc0203f0c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203dcc:	00064783          	lbu	a5,0(a2)
ffffffffc0203dd0:	0007851b          	sext.w	a0,a5
ffffffffc0203dd4:	c905                	beqz	a0,ffffffffc0203e04 <vprintfmt+0x1ce>
ffffffffc0203dd6:	000cc563          	bltz	s9,ffffffffc0203de0 <vprintfmt+0x1aa>
ffffffffc0203dda:	3cfd                	addiw	s9,s9,-1
ffffffffc0203ddc:	036c8263          	beq	s9,s6,ffffffffc0203e00 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0203de0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203de2:	18098463          	beqz	s3,ffffffffc0203f6a <vprintfmt+0x334>
ffffffffc0203de6:	3781                	addiw	a5,a5,-32
ffffffffc0203de8:	18fbf163          	bleu	a5,s7,ffffffffc0203f6a <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0203dec:	03f00513          	li	a0,63
ffffffffc0203df0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203df2:	0405                	addi	s0,s0,1
ffffffffc0203df4:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203df8:	3dfd                	addiw	s11,s11,-1
ffffffffc0203dfa:	0007851b          	sext.w	a0,a5
ffffffffc0203dfe:	fd61                	bnez	a0,ffffffffc0203dd6 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0203e00:	e7b058e3          	blez	s11,ffffffffc0203c70 <vprintfmt+0x3a>
ffffffffc0203e04:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203e06:	85a6                	mv	a1,s1
ffffffffc0203e08:	02000513          	li	a0,32
ffffffffc0203e0c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203e0e:	e60d81e3          	beqz	s11,ffffffffc0203c70 <vprintfmt+0x3a>
ffffffffc0203e12:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203e14:	85a6                	mv	a1,s1
ffffffffc0203e16:	02000513          	li	a0,32
ffffffffc0203e1a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203e1c:	fe0d94e3          	bnez	s11,ffffffffc0203e04 <vprintfmt+0x1ce>
ffffffffc0203e20:	bd81                	j	ffffffffc0203c70 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203e22:	4705                	li	a4,1
ffffffffc0203e24:	008a8593          	addi	a1,s5,8
ffffffffc0203e28:	01074463          	blt	a4,a6,ffffffffc0203e30 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0203e2c:	12080063          	beqz	a6,ffffffffc0203f4c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0203e30:	000ab603          	ld	a2,0(s5)
ffffffffc0203e34:	46a9                	li	a3,10
ffffffffc0203e36:	8aae                	mv	s5,a1
ffffffffc0203e38:	b7bd                	j	ffffffffc0203da6 <vprintfmt+0x170>
ffffffffc0203e3a:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0203e3e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e42:	846a                	mv	s0,s10
ffffffffc0203e44:	b5ad                	j	ffffffffc0203cae <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0203e46:	85a6                	mv	a1,s1
ffffffffc0203e48:	02500513          	li	a0,37
ffffffffc0203e4c:	9902                	jalr	s2
            break;
ffffffffc0203e4e:	b50d                	j	ffffffffc0203c70 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0203e50:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0203e54:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203e58:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e5a:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0203e5c:	e40dd9e3          	bgez	s11,ffffffffc0203cae <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0203e60:	8de6                	mv	s11,s9
ffffffffc0203e62:	5cfd                	li	s9,-1
ffffffffc0203e64:	b5a9                	j	ffffffffc0203cae <vprintfmt+0x78>
            goto reswitch;
ffffffffc0203e66:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0203e6a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e6e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203e70:	bd3d                	j	ffffffffc0203cae <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0203e72:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0203e76:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e7a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203e7c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203e80:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203e84:	fcd56ce3          	bltu	a0,a3,ffffffffc0203e5c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0203e88:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203e8a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0203e8e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203e92:	0196873b          	addw	a4,a3,s9
ffffffffc0203e96:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203e9a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0203e9e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0203ea2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0203ea6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203eaa:	fcd57fe3          	bleu	a3,a0,ffffffffc0203e88 <vprintfmt+0x252>
ffffffffc0203eae:	b77d                	j	ffffffffc0203e5c <vprintfmt+0x226>
            if (width < 0)
ffffffffc0203eb0:	fffdc693          	not	a3,s11
ffffffffc0203eb4:	96fd                	srai	a3,a3,0x3f
ffffffffc0203eb6:	00ddfdb3          	and	s11,s11,a3
ffffffffc0203eba:	00144603          	lbu	a2,1(s0)
ffffffffc0203ebe:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ec0:	846a                	mv	s0,s10
ffffffffc0203ec2:	b3f5                	j	ffffffffc0203cae <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0203ec4:	85a6                	mv	a1,s1
ffffffffc0203ec6:	02500513          	li	a0,37
ffffffffc0203eca:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203ecc:	fff44703          	lbu	a4,-1(s0)
ffffffffc0203ed0:	02500793          	li	a5,37
ffffffffc0203ed4:	8d22                	mv	s10,s0
ffffffffc0203ed6:	d8f70de3          	beq	a4,a5,ffffffffc0203c70 <vprintfmt+0x3a>
ffffffffc0203eda:	02500713          	li	a4,37
ffffffffc0203ede:	1d7d                	addi	s10,s10,-1
ffffffffc0203ee0:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0203ee4:	fee79de3          	bne	a5,a4,ffffffffc0203ede <vprintfmt+0x2a8>
ffffffffc0203ee8:	b361                	j	ffffffffc0203c70 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203eea:	00002617          	auipc	a2,0x2
ffffffffc0203eee:	03e60613          	addi	a2,a2,62 # ffffffffc0205f28 <error_string+0xd8>
ffffffffc0203ef2:	85a6                	mv	a1,s1
ffffffffc0203ef4:	854a                	mv	a0,s2
ffffffffc0203ef6:	0ac000ef          	jal	ra,ffffffffc0203fa2 <printfmt>
ffffffffc0203efa:	bb9d                	j	ffffffffc0203c70 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0203efc:	00002617          	auipc	a2,0x2
ffffffffc0203f00:	02460613          	addi	a2,a2,36 # ffffffffc0205f20 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0203f04:	00002417          	auipc	s0,0x2
ffffffffc0203f08:	01d40413          	addi	s0,s0,29 # ffffffffc0205f21 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203f0c:	8532                	mv	a0,a2
ffffffffc0203f0e:	85e6                	mv	a1,s9
ffffffffc0203f10:	e032                	sd	a2,0(sp)
ffffffffc0203f12:	e43e                	sd	a5,8(sp)
ffffffffc0203f14:	18a000ef          	jal	ra,ffffffffc020409e <strnlen>
ffffffffc0203f18:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0203f1c:	6602                	ld	a2,0(sp)
ffffffffc0203f1e:	01b05d63          	blez	s11,ffffffffc0203f38 <vprintfmt+0x302>
ffffffffc0203f22:	67a2                	ld	a5,8(sp)
ffffffffc0203f24:	2781                	sext.w	a5,a5
ffffffffc0203f26:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0203f28:	6522                	ld	a0,8(sp)
ffffffffc0203f2a:	85a6                	mv	a1,s1
ffffffffc0203f2c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203f2e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0203f30:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203f32:	6602                	ld	a2,0(sp)
ffffffffc0203f34:	fe0d9ae3          	bnez	s11,ffffffffc0203f28 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203f38:	00064783          	lbu	a5,0(a2)
ffffffffc0203f3c:	0007851b          	sext.w	a0,a5
ffffffffc0203f40:	e8051be3          	bnez	a0,ffffffffc0203dd6 <vprintfmt+0x1a0>
ffffffffc0203f44:	b335                	j	ffffffffc0203c70 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0203f46:	000aa403          	lw	s0,0(s5)
ffffffffc0203f4a:	bbf1                	j	ffffffffc0203d26 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0203f4c:	000ae603          	lwu	a2,0(s5)
ffffffffc0203f50:	46a9                	li	a3,10
ffffffffc0203f52:	8aae                	mv	s5,a1
ffffffffc0203f54:	bd89                	j	ffffffffc0203da6 <vprintfmt+0x170>
ffffffffc0203f56:	000ae603          	lwu	a2,0(s5)
ffffffffc0203f5a:	46c1                	li	a3,16
ffffffffc0203f5c:	8aae                	mv	s5,a1
ffffffffc0203f5e:	b5a1                	j	ffffffffc0203da6 <vprintfmt+0x170>
ffffffffc0203f60:	000ae603          	lwu	a2,0(s5)
ffffffffc0203f64:	46a1                	li	a3,8
ffffffffc0203f66:	8aae                	mv	s5,a1
ffffffffc0203f68:	bd3d                	j	ffffffffc0203da6 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0203f6a:	9902                	jalr	s2
ffffffffc0203f6c:	b559                	j	ffffffffc0203df2 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0203f6e:	85a6                	mv	a1,s1
ffffffffc0203f70:	02d00513          	li	a0,45
ffffffffc0203f74:	e03e                	sd	a5,0(sp)
ffffffffc0203f76:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0203f78:	8ace                	mv	s5,s3
ffffffffc0203f7a:	40800633          	neg	a2,s0
ffffffffc0203f7e:	46a9                	li	a3,10
ffffffffc0203f80:	6782                	ld	a5,0(sp)
ffffffffc0203f82:	b515                	j	ffffffffc0203da6 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0203f84:	01b05663          	blez	s11,ffffffffc0203f90 <vprintfmt+0x35a>
ffffffffc0203f88:	02d00693          	li	a3,45
ffffffffc0203f8c:	f6d798e3          	bne	a5,a3,ffffffffc0203efc <vprintfmt+0x2c6>
ffffffffc0203f90:	00002417          	auipc	s0,0x2
ffffffffc0203f94:	f9140413          	addi	s0,s0,-111 # ffffffffc0205f21 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203f98:	02800513          	li	a0,40
ffffffffc0203f9c:	02800793          	li	a5,40
ffffffffc0203fa0:	bd1d                	j	ffffffffc0203dd6 <vprintfmt+0x1a0>

ffffffffc0203fa2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203fa2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0203fa4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203fa8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203faa:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203fac:	ec06                	sd	ra,24(sp)
ffffffffc0203fae:	f83a                	sd	a4,48(sp)
ffffffffc0203fb0:	fc3e                	sd	a5,56(sp)
ffffffffc0203fb2:	e0c2                	sd	a6,64(sp)
ffffffffc0203fb4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0203fb6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203fb8:	c7fff0ef          	jal	ra,ffffffffc0203c36 <vprintfmt>
}
ffffffffc0203fbc:	60e2                	ld	ra,24(sp)
ffffffffc0203fbe:	6161                	addi	sp,sp,80
ffffffffc0203fc0:	8082                	ret

ffffffffc0203fc2 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0203fc2:	715d                	addi	sp,sp,-80
ffffffffc0203fc4:	e486                	sd	ra,72(sp)
ffffffffc0203fc6:	e0a2                	sd	s0,64(sp)
ffffffffc0203fc8:	fc26                	sd	s1,56(sp)
ffffffffc0203fca:	f84a                	sd	s2,48(sp)
ffffffffc0203fcc:	f44e                	sd	s3,40(sp)
ffffffffc0203fce:	f052                	sd	s4,32(sp)
ffffffffc0203fd0:	ec56                	sd	s5,24(sp)
ffffffffc0203fd2:	e85a                	sd	s6,16(sp)
ffffffffc0203fd4:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0203fd6:	c901                	beqz	a0,ffffffffc0203fe6 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0203fd8:	85aa                	mv	a1,a0
ffffffffc0203fda:	00002517          	auipc	a0,0x2
ffffffffc0203fde:	f5e50513          	addi	a0,a0,-162 # ffffffffc0205f38 <error_string+0xe8>
ffffffffc0203fe2:	8e6fc0ef          	jal	ra,ffffffffc02000c8 <cprintf>
readline(const char *prompt) {
ffffffffc0203fe6:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203fe8:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0203fea:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0203fec:	4aa9                	li	s5,10
ffffffffc0203fee:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0203ff0:	0000cb97          	auipc	s7,0xc
ffffffffc0203ff4:	050b8b93          	addi	s7,s7,80 # ffffffffc0210040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0203ff8:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0203ffc:	904fc0ef          	jal	ra,ffffffffc0200100 <getchar>
ffffffffc0204000:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204002:	00054b63          	bltz	a0,ffffffffc0204018 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204006:	00a95b63          	ble	a0,s2,ffffffffc020401c <readline+0x5a>
ffffffffc020400a:	029a5463          	ble	s1,s4,ffffffffc0204032 <readline+0x70>
        c = getchar();
ffffffffc020400e:	8f2fc0ef          	jal	ra,ffffffffc0200100 <getchar>
ffffffffc0204012:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204014:	fe0559e3          	bgez	a0,ffffffffc0204006 <readline+0x44>
            return NULL;
ffffffffc0204018:	4501                	li	a0,0
ffffffffc020401a:	a099                	j	ffffffffc0204060 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc020401c:	03341463          	bne	s0,s3,ffffffffc0204044 <readline+0x82>
ffffffffc0204020:	e8b9                	bnez	s1,ffffffffc0204076 <readline+0xb4>
        c = getchar();
ffffffffc0204022:	8defc0ef          	jal	ra,ffffffffc0200100 <getchar>
ffffffffc0204026:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204028:	fe0548e3          	bltz	a0,ffffffffc0204018 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020402c:	fea958e3          	ble	a0,s2,ffffffffc020401c <readline+0x5a>
ffffffffc0204030:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204032:	8522                	mv	a0,s0
ffffffffc0204034:	8c8fc0ef          	jal	ra,ffffffffc02000fc <cputchar>
            buf[i ++] = c;
ffffffffc0204038:	009b87b3          	add	a5,s7,s1
ffffffffc020403c:	00878023          	sb	s0,0(a5)
ffffffffc0204040:	2485                	addiw	s1,s1,1
ffffffffc0204042:	bf6d                	j	ffffffffc0203ffc <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0204044:	01540463          	beq	s0,s5,ffffffffc020404c <readline+0x8a>
ffffffffc0204048:	fb641ae3          	bne	s0,s6,ffffffffc0203ffc <readline+0x3a>
            cputchar(c);
ffffffffc020404c:	8522                	mv	a0,s0
ffffffffc020404e:	8aefc0ef          	jal	ra,ffffffffc02000fc <cputchar>
            buf[i] = '\0';
ffffffffc0204052:	0000c517          	auipc	a0,0xc
ffffffffc0204056:	fee50513          	addi	a0,a0,-18 # ffffffffc0210040 <buf>
ffffffffc020405a:	94aa                	add	s1,s1,a0
ffffffffc020405c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204060:	60a6                	ld	ra,72(sp)
ffffffffc0204062:	6406                	ld	s0,64(sp)
ffffffffc0204064:	74e2                	ld	s1,56(sp)
ffffffffc0204066:	7942                	ld	s2,48(sp)
ffffffffc0204068:	79a2                	ld	s3,40(sp)
ffffffffc020406a:	7a02                	ld	s4,32(sp)
ffffffffc020406c:	6ae2                	ld	s5,24(sp)
ffffffffc020406e:	6b42                	ld	s6,16(sp)
ffffffffc0204070:	6ba2                	ld	s7,8(sp)
ffffffffc0204072:	6161                	addi	sp,sp,80
ffffffffc0204074:	8082                	ret
            cputchar(c);
ffffffffc0204076:	4521                	li	a0,8
ffffffffc0204078:	884fc0ef          	jal	ra,ffffffffc02000fc <cputchar>
            i --;
ffffffffc020407c:	34fd                	addiw	s1,s1,-1
ffffffffc020407e:	bfbd                	j	ffffffffc0203ffc <readline+0x3a>

ffffffffc0204080 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204080:	00054783          	lbu	a5,0(a0)
ffffffffc0204084:	cb91                	beqz	a5,ffffffffc0204098 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204086:	4781                	li	a5,0
        cnt ++;
ffffffffc0204088:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020408a:	00f50733          	add	a4,a0,a5
ffffffffc020408e:	00074703          	lbu	a4,0(a4)
ffffffffc0204092:	fb7d                	bnez	a4,ffffffffc0204088 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204094:	853e                	mv	a0,a5
ffffffffc0204096:	8082                	ret
    size_t cnt = 0;
ffffffffc0204098:	4781                	li	a5,0
}
ffffffffc020409a:	853e                	mv	a0,a5
ffffffffc020409c:	8082                	ret

ffffffffc020409e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020409e:	c185                	beqz	a1,ffffffffc02040be <strnlen+0x20>
ffffffffc02040a0:	00054783          	lbu	a5,0(a0)
ffffffffc02040a4:	cf89                	beqz	a5,ffffffffc02040be <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02040a6:	4781                	li	a5,0
ffffffffc02040a8:	a021                	j	ffffffffc02040b0 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02040aa:	00074703          	lbu	a4,0(a4)
ffffffffc02040ae:	c711                	beqz	a4,ffffffffc02040ba <strnlen+0x1c>
        cnt ++;
ffffffffc02040b0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02040b2:	00f50733          	add	a4,a0,a5
ffffffffc02040b6:	fef59ae3          	bne	a1,a5,ffffffffc02040aa <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02040ba:	853e                	mv	a0,a5
ffffffffc02040bc:	8082                	ret
    size_t cnt = 0;
ffffffffc02040be:	4781                	li	a5,0
}
ffffffffc02040c0:	853e                	mv	a0,a5
ffffffffc02040c2:	8082                	ret

ffffffffc02040c4 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02040c4:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02040c6:	0585                	addi	a1,a1,1
ffffffffc02040c8:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02040cc:	0785                	addi	a5,a5,1
ffffffffc02040ce:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02040d2:	fb75                	bnez	a4,ffffffffc02040c6 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02040d4:	8082                	ret

ffffffffc02040d6 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02040d6:	00054783          	lbu	a5,0(a0)
ffffffffc02040da:	0005c703          	lbu	a4,0(a1)
ffffffffc02040de:	cb91                	beqz	a5,ffffffffc02040f2 <strcmp+0x1c>
ffffffffc02040e0:	00e79c63          	bne	a5,a4,ffffffffc02040f8 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02040e4:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02040e6:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02040ea:	0585                	addi	a1,a1,1
ffffffffc02040ec:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02040f0:	fbe5                	bnez	a5,ffffffffc02040e0 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02040f2:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02040f4:	9d19                	subw	a0,a0,a4
ffffffffc02040f6:	8082                	ret
ffffffffc02040f8:	0007851b          	sext.w	a0,a5
ffffffffc02040fc:	9d19                	subw	a0,a0,a4
ffffffffc02040fe:	8082                	ret

ffffffffc0204100 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204100:	00054783          	lbu	a5,0(a0)
ffffffffc0204104:	cb91                	beqz	a5,ffffffffc0204118 <strchr+0x18>
        if (*s == c) {
ffffffffc0204106:	00b79563          	bne	a5,a1,ffffffffc0204110 <strchr+0x10>
ffffffffc020410a:	a809                	j	ffffffffc020411c <strchr+0x1c>
ffffffffc020410c:	00b78763          	beq	a5,a1,ffffffffc020411a <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204110:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204112:	00054783          	lbu	a5,0(a0)
ffffffffc0204116:	fbfd                	bnez	a5,ffffffffc020410c <strchr+0xc>
    }
    return NULL;
ffffffffc0204118:	4501                	li	a0,0
}
ffffffffc020411a:	8082                	ret
ffffffffc020411c:	8082                	ret

ffffffffc020411e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020411e:	ca01                	beqz	a2,ffffffffc020412e <memset+0x10>
ffffffffc0204120:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204122:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204124:	0785                	addi	a5,a5,1
ffffffffc0204126:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020412a:	fec79de3          	bne	a5,a2,ffffffffc0204124 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020412e:	8082                	ret

ffffffffc0204130 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204130:	ca19                	beqz	a2,ffffffffc0204146 <memcpy+0x16>
ffffffffc0204132:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204134:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204136:	0585                	addi	a1,a1,1
ffffffffc0204138:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020413c:	0785                	addi	a5,a5,1
ffffffffc020413e:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204142:	fec59ae3          	bne	a1,a2,ffffffffc0204136 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204146:	8082                	ret
