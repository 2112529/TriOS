
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fe250513          	addi	a0,a0,-30 # ffffffffc0206018 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	52a60613          	addi	a2,a2,1322 # ffffffffc0206568 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2bd010ef          	jal	ra,ffffffffc0201b0a <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	aca50513          	addi	a0,a0,-1334 # ffffffffc0201b20 <etext+0x4>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	35c010ef          	jal	ra,ffffffffc02013c6 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	536010ef          	jal	ra,ffffffffc02015e0 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	502010ef          	jal	ra,ffffffffc02015e0 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00002517          	auipc	a0,0x2
ffffffffc0200144:	a3050513          	addi	a0,a0,-1488 # ffffffffc0201b70 <etext+0x54>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0201b90 <etext+0x74>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00002597          	auipc	a1,0x2
ffffffffc0200166:	9ba58593          	addi	a1,a1,-1606 # ffffffffc0201b1c <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	a4650513          	addi	a0,a0,-1466 # ffffffffc0201bb0 <etext+0x94>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	ea258593          	addi	a1,a1,-350 # ffffffffc0206018 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	a5250513          	addi	a0,a0,-1454 # ffffffffc0201bd0 <etext+0xb4>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	3de58593          	addi	a1,a1,990 # ffffffffc0206568 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0201bf0 <etext+0xd4>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	7c958593          	addi	a1,a1,1993 # ffffffffc0206967 <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00002517          	auipc	a0,0x2
ffffffffc02001c4:	a5050513          	addi	a0,a0,-1456 # ffffffffc0201c10 <etext+0xf4>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00002617          	auipc	a2,0x2
ffffffffc02001d4:	97060613          	addi	a2,a2,-1680 # ffffffffc0201b40 <etext+0x24>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	97c50513          	addi	a0,a0,-1668 # ffffffffc0201b58 <etext+0x3c>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	b3460613          	addi	a2,a2,-1228 # ffffffffc0201d20 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	b4c58593          	addi	a1,a1,-1204 # ffffffffc0201d40 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0201d48 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0201d58 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	b6e58593          	addi	a1,a1,-1170 # ffffffffc0201d80 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0201d48 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0201d90 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	b8258593          	addi	a1,a1,-1150 # ffffffffc0201db0 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	b1250513          	addi	a0,a0,-1262 # ffffffffc0201d48 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	a1850513          	addi	a0,a0,-1512 # ffffffffc0201c88 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00002517          	auipc	a0,0x2
ffffffffc0200296:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0201cb0 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00002c97          	auipc	s9,0x2
ffffffffc02002ac:	998c8c93          	addi	s9,s9,-1640 # ffffffffc0201c40 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	a2898993          	addi	s3,s3,-1496 # ffffffffc0201cd8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	a2890913          	addi	s2,s2,-1496 # ffffffffc0201ce0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	a26b0b13          	addi	s6,s6,-1498 # ffffffffc0201ce8 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	a76a8a93          	addi	s5,s5,-1418 # ffffffffc0201d40 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	696010ef          	jal	ra,ffffffffc020196c <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	005010ef          	jal	ra,ffffffffc0201aec <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00002d17          	auipc	s10,0x2
ffffffffc0200302:	942d0d13          	addi	s10,s10,-1726 # ffffffffc0201c40 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	7b6010ef          	jal	ra,ffffffffc0201ac2 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	7a2010ef          	jal	ra,ffffffffc0201ac2 <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	766010ef          	jal	ra,ffffffffc0201aec <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	96a50513          	addi	a0,a0,-1686 # ffffffffc0201d08 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06c30313          	addi	t1,t1,108 # ffffffffc0206418 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72423          	sw	a5,72(a4) # ffffffffc0206418 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	9e250513          	addi	a0,a0,-1566 # ffffffffc0201dc0 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00002517          	auipc	a0,0x2
ffffffffc02003f8:	84450513          	addi	a0,a0,-1980 # ffffffffc0201c38 <etext+0x11c>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	622010ef          	jal	ra,ffffffffc0201a46 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b723          	sd	zero,14(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0201de0 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	5fa0106f          	j	ffffffffc0201a46 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	5d40106f          	j	ffffffffc0201a2a <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	6080106f          	j	ffffffffc0201a62 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	33a78793          	addi	a5,a5,826 # ffffffffc02007a8 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	a7450513          	addi	a0,a0,-1420 # ffffffffc0201ef8 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0201f10 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	a8650513          	addi	a0,a0,-1402 # ffffffffc0201f28 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	a9050513          	addi	a0,a0,-1392 # ffffffffc0201f40 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0201f58 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	aa450513          	addi	a0,a0,-1372 # ffffffffc0201f70 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	aae50513          	addi	a0,a0,-1362 # ffffffffc0201f88 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	ab850513          	addi	a0,a0,-1352 # ffffffffc0201fa0 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	ac250513          	addi	a0,a0,-1342 # ffffffffc0201fb8 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	acc50513          	addi	a0,a0,-1332 # ffffffffc0201fd0 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	ad650513          	addi	a0,a0,-1322 # ffffffffc0201fe8 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	ae050513          	addi	a0,a0,-1312 # ffffffffc0202000 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	aea50513          	addi	a0,a0,-1302 # ffffffffc0202018 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	af450513          	addi	a0,a0,-1292 # ffffffffc0202030 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	afe50513          	addi	a0,a0,-1282 # ffffffffc0202048 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0202060 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	b1250513          	addi	a0,a0,-1262 # ffffffffc0202078 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0202090 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	b2650513          	addi	a0,a0,-1242 # ffffffffc02020a8 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	b3050513          	addi	a0,a0,-1232 # ffffffffc02020c0 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	b3a50513          	addi	a0,a0,-1222 # ffffffffc02020d8 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	b4450513          	addi	a0,a0,-1212 # ffffffffc02020f0 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0202108 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	b5850513          	addi	a0,a0,-1192 # ffffffffc0202120 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	b6250513          	addi	a0,a0,-1182 # ffffffffc0202138 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0202150 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	b7650513          	addi	a0,a0,-1162 # ffffffffc0202168 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	b8050513          	addi	a0,a0,-1152 # ffffffffc0202180 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0202198 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	b9450513          	addi	a0,a0,-1132 # ffffffffc02021b0 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	b9e50513          	addi	a0,a0,-1122 # ffffffffc02021c8 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	ba450513          	addi	a0,a0,-1116 # ffffffffc02021e0 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	ba650513          	addi	a0,a0,-1114 # ffffffffc02021f8 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	ba650513          	addi	a0,a0,-1114 # ffffffffc0202210 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	bae50513          	addi	a0,a0,-1106 # ffffffffc0202228 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	bb650513          	addi	a0,a0,-1098 # ffffffffc0202240 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0202258 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	0af76263          	bltu	a4,a5,ffffffffc020075c <interrupt_handler+0xb0>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	74070713          	addi	a4,a4,1856 # ffffffffc0201dfc <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	7c250513          	addi	a0,a0,1986 # ffffffffc0201e90 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	79650513          	addi	a0,a0,1942 # ffffffffc0201e70 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	74a50513          	addi	a0,a0,1866 # ffffffffc0201e30 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	7be50513          	addi	a0,a0,1982 # ffffffffc0201eb0 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1101                	addi	sp,sp,-32
ffffffffc0200700:	e822                	sd	s0,16(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            ticks++;
ffffffffc0200702:	00006417          	auipc	s0,0x6
ffffffffc0200706:	d3640413          	addi	s0,s0,-714 # ffffffffc0206438 <ticks>
ffffffffc020070a:	601c                	ld	a5,0(s0)
void interrupt_handler(struct trapframe *tf) {
ffffffffc020070c:	e426                	sd	s1,8(sp)
ffffffffc020070e:	ec06                	sd	ra,24(sp)
            ticks++;
ffffffffc0200710:	0785                	addi	a5,a5,1
ffffffffc0200712:	00006717          	auipc	a4,0x6
ffffffffc0200716:	d2f73323          	sd	a5,-730(a4) # ffffffffc0206438 <ticks>
            clock_set_next_event();
ffffffffc020071a:	d27ff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if(ticks == 100 ){
ffffffffc020071e:	6018                	ld	a4,0(s0)
ffffffffc0200720:	06400793          	li	a5,100
ffffffffc0200724:	00006497          	auipc	s1,0x6
ffffffffc0200728:	cf848493          	addi	s1,s1,-776 # ffffffffc020641c <num>
ffffffffc020072c:	02f70a63          	beq	a4,a5,ffffffffc0200760 <interrupt_handler+0xb4>
		cprintf("100 ticks\n");
		ticks = 0;
		num++;
		}
	    if(num == 10){
ffffffffc0200730:	409c                	lw	a5,0(s1)
ffffffffc0200732:	4729                	li	a4,10
ffffffffc0200734:	2781                	sext.w	a5,a5
ffffffffc0200736:	04e78663          	beq	a5,a4,ffffffffc0200782 <interrupt_handler+0xd6>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020073a:	60e2                	ld	ra,24(sp)
ffffffffc020073c:	6442                	ld	s0,16(sp)
ffffffffc020073e:	64a2                	ld	s1,8(sp)
ffffffffc0200740:	6105                	addi	sp,sp,32
ffffffffc0200742:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200744:	00001517          	auipc	a0,0x1
ffffffffc0200748:	79450513          	addi	a0,a0,1940 # ffffffffc0201ed8 <commands+0x298>
ffffffffc020074c:	96bff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200750:	00001517          	auipc	a0,0x1
ffffffffc0200754:	70050513          	addi	a0,a0,1792 # ffffffffc0201e50 <commands+0x210>
ffffffffc0200758:	95fff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc020075c:	eefff06f          	j	ffffffffc020064a <print_trapframe>
		cprintf("100 ticks\n");
ffffffffc0200760:	00001517          	auipc	a0,0x1
ffffffffc0200764:	76850513          	addi	a0,a0,1896 # ffffffffc0201ec8 <commands+0x288>
ffffffffc0200768:	94fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
		ticks = 0;
ffffffffc020076c:	00006797          	auipc	a5,0x6
ffffffffc0200770:	cc07b623          	sd	zero,-820(a5) # ffffffffc0206438 <ticks>
		num++;
ffffffffc0200774:	409c                	lw	a5,0(s1)
ffffffffc0200776:	2785                	addiw	a5,a5,1
ffffffffc0200778:	00006717          	auipc	a4,0x6
ffffffffc020077c:	caf72223          	sw	a5,-860(a4) # ffffffffc020641c <num>
ffffffffc0200780:	bf45                	j	ffffffffc0200730 <interrupt_handler+0x84>
}
ffffffffc0200782:	6442                	ld	s0,16(sp)
ffffffffc0200784:	60e2                	ld	ra,24(sp)
ffffffffc0200786:	64a2                	ld	s1,8(sp)
ffffffffc0200788:	6105                	addi	sp,sp,32
	    	sbi_shutdown();
ffffffffc020078a:	2f60106f          	j	ffffffffc0201a80 <sbi_shutdown>

ffffffffc020078e <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020078e:	11853783          	ld	a5,280(a0)
ffffffffc0200792:	0007c863          	bltz	a5,ffffffffc02007a2 <trap+0x14>
    switch (tf->cause) {
ffffffffc0200796:	472d                	li	a4,11
ffffffffc0200798:	00f76363          	bltu	a4,a5,ffffffffc020079e <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc020079c:	8082                	ret
            print_trapframe(tf);
ffffffffc020079e:	eadff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc02007a2:	f0bff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc02007a8 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc02007a8:	14011073          	csrw	sscratch,sp
ffffffffc02007ac:	712d                	addi	sp,sp,-288
ffffffffc02007ae:	e002                	sd	zero,0(sp)
ffffffffc02007b0:	e406                	sd	ra,8(sp)
ffffffffc02007b2:	ec0e                	sd	gp,24(sp)
ffffffffc02007b4:	f012                	sd	tp,32(sp)
ffffffffc02007b6:	f416                	sd	t0,40(sp)
ffffffffc02007b8:	f81a                	sd	t1,48(sp)
ffffffffc02007ba:	fc1e                	sd	t2,56(sp)
ffffffffc02007bc:	e0a2                	sd	s0,64(sp)
ffffffffc02007be:	e4a6                	sd	s1,72(sp)
ffffffffc02007c0:	e8aa                	sd	a0,80(sp)
ffffffffc02007c2:	ecae                	sd	a1,88(sp)
ffffffffc02007c4:	f0b2                	sd	a2,96(sp)
ffffffffc02007c6:	f4b6                	sd	a3,104(sp)
ffffffffc02007c8:	f8ba                	sd	a4,112(sp)
ffffffffc02007ca:	fcbe                	sd	a5,120(sp)
ffffffffc02007cc:	e142                	sd	a6,128(sp)
ffffffffc02007ce:	e546                	sd	a7,136(sp)
ffffffffc02007d0:	e94a                	sd	s2,144(sp)
ffffffffc02007d2:	ed4e                	sd	s3,152(sp)
ffffffffc02007d4:	f152                	sd	s4,160(sp)
ffffffffc02007d6:	f556                	sd	s5,168(sp)
ffffffffc02007d8:	f95a                	sd	s6,176(sp)
ffffffffc02007da:	fd5e                	sd	s7,184(sp)
ffffffffc02007dc:	e1e2                	sd	s8,192(sp)
ffffffffc02007de:	e5e6                	sd	s9,200(sp)
ffffffffc02007e0:	e9ea                	sd	s10,208(sp)
ffffffffc02007e2:	edee                	sd	s11,216(sp)
ffffffffc02007e4:	f1f2                	sd	t3,224(sp)
ffffffffc02007e6:	f5f6                	sd	t4,232(sp)
ffffffffc02007e8:	f9fa                	sd	t5,240(sp)
ffffffffc02007ea:	fdfe                	sd	t6,248(sp)
ffffffffc02007ec:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007f0:	100024f3          	csrr	s1,sstatus
ffffffffc02007f4:	14102973          	csrr	s2,sepc
ffffffffc02007f8:	143029f3          	csrr	s3,stval
ffffffffc02007fc:	14202a73          	csrr	s4,scause
ffffffffc0200800:	e822                	sd	s0,16(sp)
ffffffffc0200802:	e226                	sd	s1,256(sp)
ffffffffc0200804:	e64a                	sd	s2,264(sp)
ffffffffc0200806:	ea4e                	sd	s3,272(sp)
ffffffffc0200808:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc020080a:	850a                	mv	a0,sp
    jal trap
ffffffffc020080c:	f83ff0ef          	jal	ra,ffffffffc020078e <trap>

ffffffffc0200810 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200810:	6492                	ld	s1,256(sp)
ffffffffc0200812:	6932                	ld	s2,264(sp)
ffffffffc0200814:	10049073          	csrw	sstatus,s1
ffffffffc0200818:	14191073          	csrw	sepc,s2
ffffffffc020081c:	60a2                	ld	ra,8(sp)
ffffffffc020081e:	61e2                	ld	gp,24(sp)
ffffffffc0200820:	7202                	ld	tp,32(sp)
ffffffffc0200822:	72a2                	ld	t0,40(sp)
ffffffffc0200824:	7342                	ld	t1,48(sp)
ffffffffc0200826:	73e2                	ld	t2,56(sp)
ffffffffc0200828:	6406                	ld	s0,64(sp)
ffffffffc020082a:	64a6                	ld	s1,72(sp)
ffffffffc020082c:	6546                	ld	a0,80(sp)
ffffffffc020082e:	65e6                	ld	a1,88(sp)
ffffffffc0200830:	7606                	ld	a2,96(sp)
ffffffffc0200832:	76a6                	ld	a3,104(sp)
ffffffffc0200834:	7746                	ld	a4,112(sp)
ffffffffc0200836:	77e6                	ld	a5,120(sp)
ffffffffc0200838:	680a                	ld	a6,128(sp)
ffffffffc020083a:	68aa                	ld	a7,136(sp)
ffffffffc020083c:	694a                	ld	s2,144(sp)
ffffffffc020083e:	69ea                	ld	s3,152(sp)
ffffffffc0200840:	7a0a                	ld	s4,160(sp)
ffffffffc0200842:	7aaa                	ld	s5,168(sp)
ffffffffc0200844:	7b4a                	ld	s6,176(sp)
ffffffffc0200846:	7bea                	ld	s7,184(sp)
ffffffffc0200848:	6c0e                	ld	s8,192(sp)
ffffffffc020084a:	6cae                	ld	s9,200(sp)
ffffffffc020084c:	6d4e                	ld	s10,208(sp)
ffffffffc020084e:	6dee                	ld	s11,216(sp)
ffffffffc0200850:	7e0e                	ld	t3,224(sp)
ffffffffc0200852:	7eae                	ld	t4,232(sp)
ffffffffc0200854:	7f4e                	ld	t5,240(sp)
ffffffffc0200856:	7fee                	ld	t6,248(sp)
ffffffffc0200858:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020085a:	10200073          	sret

ffffffffc020085e <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020085e:	00006797          	auipc	a5,0x6
ffffffffc0200862:	be278793          	addi	a5,a5,-1054 # ffffffffc0206440 <free_area>
ffffffffc0200866:	e79c                	sd	a5,8(a5)
ffffffffc0200868:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020086a:	0007a823          	sw	zero,16(a5)
}
ffffffffc020086e:	8082                	ret

ffffffffc0200870 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200870:	00006517          	auipc	a0,0x6
ffffffffc0200874:	be056503          	lwu	a0,-1056(a0) # ffffffffc0206450 <free_area+0x10>
ffffffffc0200878:	8082                	ret

ffffffffc020087a <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc020087a:	715d                	addi	sp,sp,-80
ffffffffc020087c:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020087e:	00006917          	auipc	s2,0x6
ffffffffc0200882:	bc290913          	addi	s2,s2,-1086 # ffffffffc0206440 <free_area>
ffffffffc0200886:	00893783          	ld	a5,8(s2)
ffffffffc020088a:	e486                	sd	ra,72(sp)
ffffffffc020088c:	e0a2                	sd	s0,64(sp)
ffffffffc020088e:	fc26                	sd	s1,56(sp)
ffffffffc0200890:	f44e                	sd	s3,40(sp)
ffffffffc0200892:	f052                	sd	s4,32(sp)
ffffffffc0200894:	ec56                	sd	s5,24(sp)
ffffffffc0200896:	e85a                	sd	s6,16(sp)
ffffffffc0200898:	e45e                	sd	s7,8(sp)
ffffffffc020089a:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020089c:	2d278363          	beq	a5,s2,ffffffffc0200b62 <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02008a0:	ff07b703          	ld	a4,-16(a5)
ffffffffc02008a4:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02008a6:	8b05                	andi	a4,a4,1
ffffffffc02008a8:	2c070163          	beqz	a4,ffffffffc0200b6a <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc02008ac:	4401                	li	s0,0
ffffffffc02008ae:	4481                	li	s1,0
ffffffffc02008b0:	a031                	j	ffffffffc02008bc <best_fit_check+0x42>
ffffffffc02008b2:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc02008b6:	8b09                	andi	a4,a4,2
ffffffffc02008b8:	2a070963          	beqz	a4,ffffffffc0200b6a <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc02008bc:	ff87a703          	lw	a4,-8(a5)
ffffffffc02008c0:	679c                	ld	a5,8(a5)
ffffffffc02008c2:	2485                	addiw	s1,s1,1
ffffffffc02008c4:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02008c6:	ff2796e3          	bne	a5,s2,ffffffffc02008b2 <best_fit_check+0x38>
ffffffffc02008ca:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc02008cc:	2bb000ef          	jal	ra,ffffffffc0201386 <nr_free_pages>
ffffffffc02008d0:	37351d63          	bne	a0,s3,ffffffffc0200c4a <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02008d4:	4505                	li	a0,1
ffffffffc02008d6:	227000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc02008da:	8a2a                	mv	s4,a0
ffffffffc02008dc:	3a050763          	beqz	a0,ffffffffc0200c8a <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02008e0:	4505                	li	a0,1
ffffffffc02008e2:	21b000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc02008e6:	89aa                	mv	s3,a0
ffffffffc02008e8:	38050163          	beqz	a0,ffffffffc0200c6a <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02008ec:	4505                	li	a0,1
ffffffffc02008ee:	20f000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc02008f2:	8aaa                	mv	s5,a0
ffffffffc02008f4:	30050b63          	beqz	a0,ffffffffc0200c0a <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02008f8:	293a0963          	beq	s4,s3,ffffffffc0200b8a <best_fit_check+0x310>
ffffffffc02008fc:	28aa0763          	beq	s4,a0,ffffffffc0200b8a <best_fit_check+0x310>
ffffffffc0200900:	28a98563          	beq	s3,a0,ffffffffc0200b8a <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200904:	000a2783          	lw	a5,0(s4)
ffffffffc0200908:	2a079163          	bnez	a5,ffffffffc0200baa <best_fit_check+0x330>
ffffffffc020090c:	0009a783          	lw	a5,0(s3)
ffffffffc0200910:	28079d63          	bnez	a5,ffffffffc0200baa <best_fit_check+0x330>
ffffffffc0200914:	411c                	lw	a5,0(a0)
ffffffffc0200916:	28079a63          	bnez	a5,ffffffffc0200baa <best_fit_check+0x330>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020091a:	00006797          	auipc	a5,0x6
ffffffffc020091e:	c4678793          	addi	a5,a5,-954 # ffffffffc0206560 <pages>
ffffffffc0200922:	639c                	ld	a5,0(a5)
ffffffffc0200924:	00002717          	auipc	a4,0x2
ffffffffc0200928:	94c70713          	addi	a4,a4,-1716 # ffffffffc0202270 <commands+0x630>
ffffffffc020092c:	630c                	ld	a1,0(a4)
ffffffffc020092e:	40fa0733          	sub	a4,s4,a5
ffffffffc0200932:	8711                	srai	a4,a4,0x4
ffffffffc0200934:	02b70733          	mul	a4,a4,a1
ffffffffc0200938:	00002697          	auipc	a3,0x2
ffffffffc020093c:	03068693          	addi	a3,a3,48 # ffffffffc0202968 <nbase>
ffffffffc0200940:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200942:	00006697          	auipc	a3,0x6
ffffffffc0200946:	ade68693          	addi	a3,a3,-1314 # ffffffffc0206420 <npage>
ffffffffc020094a:	6294                	ld	a3,0(a3)
ffffffffc020094c:	06b2                	slli	a3,a3,0xc
ffffffffc020094e:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200950:	0732                	slli	a4,a4,0xc
ffffffffc0200952:	26d77c63          	bleu	a3,a4,ffffffffc0200bca <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200956:	40f98733          	sub	a4,s3,a5
ffffffffc020095a:	8711                	srai	a4,a4,0x4
ffffffffc020095c:	02b70733          	mul	a4,a4,a1
ffffffffc0200960:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200962:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200964:	42d77363          	bleu	a3,a4,ffffffffc0200d8a <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200968:	40f507b3          	sub	a5,a0,a5
ffffffffc020096c:	8791                	srai	a5,a5,0x4
ffffffffc020096e:	02b787b3          	mul	a5,a5,a1
ffffffffc0200972:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200974:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200976:	3ed7fa63          	bleu	a3,a5,ffffffffc0200d6a <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc020097a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020097c:	00093c03          	ld	s8,0(s2)
ffffffffc0200980:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200984:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200988:	00006797          	auipc	a5,0x6
ffffffffc020098c:	ad27b023          	sd	s2,-1344(a5) # ffffffffc0206448 <free_area+0x8>
ffffffffc0200990:	00006797          	auipc	a5,0x6
ffffffffc0200994:	ab27b823          	sd	s2,-1360(a5) # ffffffffc0206440 <free_area>
    nr_free = 0;
ffffffffc0200998:	00006797          	auipc	a5,0x6
ffffffffc020099c:	aa07ac23          	sw	zero,-1352(a5) # ffffffffc0206450 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02009a0:	15d000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc02009a4:	3a051363          	bnez	a0,ffffffffc0200d4a <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc02009a8:	4585                	li	a1,1
ffffffffc02009aa:	8552                	mv	a0,s4
ffffffffc02009ac:	195000ef          	jal	ra,ffffffffc0201340 <free_pages>
    free_page(p1);
ffffffffc02009b0:	4585                	li	a1,1
ffffffffc02009b2:	854e                	mv	a0,s3
ffffffffc02009b4:	18d000ef          	jal	ra,ffffffffc0201340 <free_pages>
    free_page(p2);
ffffffffc02009b8:	4585                	li	a1,1
ffffffffc02009ba:	8556                	mv	a0,s5
ffffffffc02009bc:	185000ef          	jal	ra,ffffffffc0201340 <free_pages>
    assert(nr_free == 3);
ffffffffc02009c0:	01092703          	lw	a4,16(s2)
ffffffffc02009c4:	478d                	li	a5,3
ffffffffc02009c6:	36f71263          	bne	a4,a5,ffffffffc0200d2a <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02009ca:	4505                	li	a0,1
ffffffffc02009cc:	131000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc02009d0:	89aa                	mv	s3,a0
ffffffffc02009d2:	32050c63          	beqz	a0,ffffffffc0200d0a <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02009d6:	4505                	li	a0,1
ffffffffc02009d8:	125000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc02009dc:	8aaa                	mv	s5,a0
ffffffffc02009de:	30050663          	beqz	a0,ffffffffc0200cea <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02009e2:	4505                	li	a0,1
ffffffffc02009e4:	119000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc02009e8:	8a2a                	mv	s4,a0
ffffffffc02009ea:	2e050063          	beqz	a0,ffffffffc0200cca <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc02009ee:	4505                	li	a0,1
ffffffffc02009f0:	10d000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc02009f4:	2a051b63          	bnez	a0,ffffffffc0200caa <best_fit_check+0x430>
    free_page(p0);
ffffffffc02009f8:	4585                	li	a1,1
ffffffffc02009fa:	854e                	mv	a0,s3
ffffffffc02009fc:	145000ef          	jal	ra,ffffffffc0201340 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a00:	00893783          	ld	a5,8(s2)
ffffffffc0200a04:	1f278363          	beq	a5,s2,ffffffffc0200bea <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200a08:	4505                	li	a0,1
ffffffffc0200a0a:	0f3000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc0200a0e:	54a99e63          	bne	s3,a0,ffffffffc0200f6a <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200a12:	4505                	li	a0,1
ffffffffc0200a14:	0e9000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc0200a18:	52051963          	bnez	a0,ffffffffc0200f4a <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200a1c:	01092783          	lw	a5,16(s2)
ffffffffc0200a20:	50079563          	bnez	a5,ffffffffc0200f2a <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200a24:	854e                	mv	a0,s3
ffffffffc0200a26:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200a28:	00006797          	auipc	a5,0x6
ffffffffc0200a2c:	a187bc23          	sd	s8,-1512(a5) # ffffffffc0206440 <free_area>
ffffffffc0200a30:	00006797          	auipc	a5,0x6
ffffffffc0200a34:	a177bc23          	sd	s7,-1512(a5) # ffffffffc0206448 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200a38:	00006797          	auipc	a5,0x6
ffffffffc0200a3c:	a167ac23          	sw	s6,-1512(a5) # ffffffffc0206450 <free_area+0x10>
    free_page(p);
ffffffffc0200a40:	101000ef          	jal	ra,ffffffffc0201340 <free_pages>
    free_page(p1);
ffffffffc0200a44:	4585                	li	a1,1
ffffffffc0200a46:	8556                	mv	a0,s5
ffffffffc0200a48:	0f9000ef          	jal	ra,ffffffffc0201340 <free_pages>
    free_page(p2);
ffffffffc0200a4c:	4585                	li	a1,1
ffffffffc0200a4e:	8552                	mv	a0,s4
ffffffffc0200a50:	0f1000ef          	jal	ra,ffffffffc0201340 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200a54:	4515                	li	a0,5
ffffffffc0200a56:	0a7000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc0200a5a:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200a5c:	4a050763          	beqz	a0,ffffffffc0200f0a <best_fit_check+0x690>
ffffffffc0200a60:	651c                	ld	a5,8(a0)
ffffffffc0200a62:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200a64:	8b85                	andi	a5,a5,1
ffffffffc0200a66:	48079263          	bnez	a5,ffffffffc0200eea <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200a6a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a6c:	00093b03          	ld	s6,0(s2)
ffffffffc0200a70:	00893a83          	ld	s5,8(s2)
ffffffffc0200a74:	00006797          	auipc	a5,0x6
ffffffffc0200a78:	9d27b623          	sd	s2,-1588(a5) # ffffffffc0206440 <free_area>
ffffffffc0200a7c:	00006797          	auipc	a5,0x6
ffffffffc0200a80:	9d27b623          	sd	s2,-1588(a5) # ffffffffc0206448 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200a84:	079000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc0200a88:	44051163          	bnez	a0,ffffffffc0200eca <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200a8c:	4589                	li	a1,2
ffffffffc0200a8e:	03098513          	addi	a0,s3,48
    unsigned int nr_free_store = nr_free;
ffffffffc0200a92:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200a96:	0c098c13          	addi	s8,s3,192
    nr_free = 0;
ffffffffc0200a9a:	00006797          	auipc	a5,0x6
ffffffffc0200a9e:	9a07ab23          	sw	zero,-1610(a5) # ffffffffc0206450 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200aa2:	09f000ef          	jal	ra,ffffffffc0201340 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200aa6:	8562                	mv	a0,s8
ffffffffc0200aa8:	4585                	li	a1,1
ffffffffc0200aaa:	097000ef          	jal	ra,ffffffffc0201340 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200aae:	4511                	li	a0,4
ffffffffc0200ab0:	04d000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc0200ab4:	3e051b63          	bnez	a0,ffffffffc0200eaa <best_fit_check+0x630>
ffffffffc0200ab8:	0389b783          	ld	a5,56(s3)
ffffffffc0200abc:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200abe:	8b85                	andi	a5,a5,1
ffffffffc0200ac0:	3c078563          	beqz	a5,ffffffffc0200e8a <best_fit_check+0x610>
ffffffffc0200ac4:	0409a703          	lw	a4,64(s3)
ffffffffc0200ac8:	4789                	li	a5,2
ffffffffc0200aca:	3cf71063          	bne	a4,a5,ffffffffc0200e8a <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200ace:	4505                	li	a0,1
ffffffffc0200ad0:	02d000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc0200ad4:	8a2a                	mv	s4,a0
ffffffffc0200ad6:	38050a63          	beqz	a0,ffffffffc0200e6a <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200ada:	4509                	li	a0,2
ffffffffc0200adc:	021000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc0200ae0:	36050563          	beqz	a0,ffffffffc0200e4a <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200ae4:	354c1363          	bne	s8,s4,ffffffffc0200e2a <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200ae8:	854e                	mv	a0,s3
ffffffffc0200aea:	4595                	li	a1,5
ffffffffc0200aec:	055000ef          	jal	ra,ffffffffc0201340 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200af0:	4515                	li	a0,5
ffffffffc0200af2:	00b000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc0200af6:	89aa                	mv	s3,a0
ffffffffc0200af8:	30050963          	beqz	a0,ffffffffc0200e0a <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200afc:	4505                	li	a0,1
ffffffffc0200afe:	7fe000ef          	jal	ra,ffffffffc02012fc <alloc_pages>
ffffffffc0200b02:	2e051463          	bnez	a0,ffffffffc0200dea <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200b06:	01092783          	lw	a5,16(s2)
ffffffffc0200b0a:	2c079063          	bnez	a5,ffffffffc0200dca <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200b0e:	4595                	li	a1,5
ffffffffc0200b10:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200b12:	00006797          	auipc	a5,0x6
ffffffffc0200b16:	9377af23          	sw	s7,-1730(a5) # ffffffffc0206450 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200b1a:	00006797          	auipc	a5,0x6
ffffffffc0200b1e:	9367b323          	sd	s6,-1754(a5) # ffffffffc0206440 <free_area>
ffffffffc0200b22:	00006797          	auipc	a5,0x6
ffffffffc0200b26:	9357b323          	sd	s5,-1754(a5) # ffffffffc0206448 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200b2a:	017000ef          	jal	ra,ffffffffc0201340 <free_pages>
    return listelm->next;
ffffffffc0200b2e:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b32:	01278963          	beq	a5,s2,ffffffffc0200b44 <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200b36:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b3a:	679c                	ld	a5,8(a5)
ffffffffc0200b3c:	34fd                	addiw	s1,s1,-1
ffffffffc0200b3e:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b40:	ff279be3          	bne	a5,s2,ffffffffc0200b36 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200b44:	26049363          	bnez	s1,ffffffffc0200daa <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200b48:	e06d                	bnez	s0,ffffffffc0200c2a <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200b4a:	60a6                	ld	ra,72(sp)
ffffffffc0200b4c:	6406                	ld	s0,64(sp)
ffffffffc0200b4e:	74e2                	ld	s1,56(sp)
ffffffffc0200b50:	7942                	ld	s2,48(sp)
ffffffffc0200b52:	79a2                	ld	s3,40(sp)
ffffffffc0200b54:	7a02                	ld	s4,32(sp)
ffffffffc0200b56:	6ae2                	ld	s5,24(sp)
ffffffffc0200b58:	6b42                	ld	s6,16(sp)
ffffffffc0200b5a:	6ba2                	ld	s7,8(sp)
ffffffffc0200b5c:	6c02                	ld	s8,0(sp)
ffffffffc0200b5e:	6161                	addi	sp,sp,80
ffffffffc0200b60:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b62:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b64:	4401                	li	s0,0
ffffffffc0200b66:	4481                	li	s1,0
ffffffffc0200b68:	b395                	j	ffffffffc02008cc <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200b6a:	00001697          	auipc	a3,0x1
ffffffffc0200b6e:	70e68693          	addi	a3,a3,1806 # ffffffffc0202278 <commands+0x638>
ffffffffc0200b72:	00001617          	auipc	a2,0x1
ffffffffc0200b76:	71660613          	addi	a2,a2,1814 # ffffffffc0202288 <commands+0x648>
ffffffffc0200b7a:	10b00593          	li	a1,267
ffffffffc0200b7e:	00001517          	auipc	a0,0x1
ffffffffc0200b82:	72250513          	addi	a0,a0,1826 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200b86:	827ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b8a:	00001697          	auipc	a3,0x1
ffffffffc0200b8e:	7ae68693          	addi	a3,a3,1966 # ffffffffc0202338 <commands+0x6f8>
ffffffffc0200b92:	00001617          	auipc	a2,0x1
ffffffffc0200b96:	6f660613          	addi	a2,a2,1782 # ffffffffc0202288 <commands+0x648>
ffffffffc0200b9a:	0d700593          	li	a1,215
ffffffffc0200b9e:	00001517          	auipc	a0,0x1
ffffffffc0200ba2:	70250513          	addi	a0,a0,1794 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200ba6:	807ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200baa:	00001697          	auipc	a3,0x1
ffffffffc0200bae:	7b668693          	addi	a3,a3,1974 # ffffffffc0202360 <commands+0x720>
ffffffffc0200bb2:	00001617          	auipc	a2,0x1
ffffffffc0200bb6:	6d660613          	addi	a2,a2,1750 # ffffffffc0202288 <commands+0x648>
ffffffffc0200bba:	0d800593          	li	a1,216
ffffffffc0200bbe:	00001517          	auipc	a0,0x1
ffffffffc0200bc2:	6e250513          	addi	a0,a0,1762 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200bc6:	fe6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bca:	00001697          	auipc	a3,0x1
ffffffffc0200bce:	7d668693          	addi	a3,a3,2006 # ffffffffc02023a0 <commands+0x760>
ffffffffc0200bd2:	00001617          	auipc	a2,0x1
ffffffffc0200bd6:	6b660613          	addi	a2,a2,1718 # ffffffffc0202288 <commands+0x648>
ffffffffc0200bda:	0da00593          	li	a1,218
ffffffffc0200bde:	00001517          	auipc	a0,0x1
ffffffffc0200be2:	6c250513          	addi	a0,a0,1730 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200be6:	fc6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200bea:	00002697          	auipc	a3,0x2
ffffffffc0200bee:	83e68693          	addi	a3,a3,-1986 # ffffffffc0202428 <commands+0x7e8>
ffffffffc0200bf2:	00001617          	auipc	a2,0x1
ffffffffc0200bf6:	69660613          	addi	a2,a2,1686 # ffffffffc0202288 <commands+0x648>
ffffffffc0200bfa:	0f300593          	li	a1,243
ffffffffc0200bfe:	00001517          	auipc	a0,0x1
ffffffffc0200c02:	6a250513          	addi	a0,a0,1698 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200c06:	fa6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c0a:	00001697          	auipc	a3,0x1
ffffffffc0200c0e:	70e68693          	addi	a3,a3,1806 # ffffffffc0202318 <commands+0x6d8>
ffffffffc0200c12:	00001617          	auipc	a2,0x1
ffffffffc0200c16:	67660613          	addi	a2,a2,1654 # ffffffffc0202288 <commands+0x648>
ffffffffc0200c1a:	0d500593          	li	a1,213
ffffffffc0200c1e:	00001517          	auipc	a0,0x1
ffffffffc0200c22:	68250513          	addi	a0,a0,1666 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200c26:	f86ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200c2a:	00002697          	auipc	a3,0x2
ffffffffc0200c2e:	92e68693          	addi	a3,a3,-1746 # ffffffffc0202558 <commands+0x918>
ffffffffc0200c32:	00001617          	auipc	a2,0x1
ffffffffc0200c36:	65660613          	addi	a2,a2,1622 # ffffffffc0202288 <commands+0x648>
ffffffffc0200c3a:	14d00593          	li	a1,333
ffffffffc0200c3e:	00001517          	auipc	a0,0x1
ffffffffc0200c42:	66250513          	addi	a0,a0,1634 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200c46:	f66ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200c4a:	00001697          	auipc	a3,0x1
ffffffffc0200c4e:	66e68693          	addi	a3,a3,1646 # ffffffffc02022b8 <commands+0x678>
ffffffffc0200c52:	00001617          	auipc	a2,0x1
ffffffffc0200c56:	63660613          	addi	a2,a2,1590 # ffffffffc0202288 <commands+0x648>
ffffffffc0200c5a:	10e00593          	li	a1,270
ffffffffc0200c5e:	00001517          	auipc	a0,0x1
ffffffffc0200c62:	64250513          	addi	a0,a0,1602 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200c66:	f46ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c6a:	00001697          	auipc	a3,0x1
ffffffffc0200c6e:	68e68693          	addi	a3,a3,1678 # ffffffffc02022f8 <commands+0x6b8>
ffffffffc0200c72:	00001617          	auipc	a2,0x1
ffffffffc0200c76:	61660613          	addi	a2,a2,1558 # ffffffffc0202288 <commands+0x648>
ffffffffc0200c7a:	0d400593          	li	a1,212
ffffffffc0200c7e:	00001517          	auipc	a0,0x1
ffffffffc0200c82:	62250513          	addi	a0,a0,1570 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200c86:	f26ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c8a:	00001697          	auipc	a3,0x1
ffffffffc0200c8e:	64e68693          	addi	a3,a3,1614 # ffffffffc02022d8 <commands+0x698>
ffffffffc0200c92:	00001617          	auipc	a2,0x1
ffffffffc0200c96:	5f660613          	addi	a2,a2,1526 # ffffffffc0202288 <commands+0x648>
ffffffffc0200c9a:	0d300593          	li	a1,211
ffffffffc0200c9e:	00001517          	auipc	a0,0x1
ffffffffc0200ca2:	60250513          	addi	a0,a0,1538 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200ca6:	f06ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200caa:	00001697          	auipc	a3,0x1
ffffffffc0200cae:	75668693          	addi	a3,a3,1878 # ffffffffc0202400 <commands+0x7c0>
ffffffffc0200cb2:	00001617          	auipc	a2,0x1
ffffffffc0200cb6:	5d660613          	addi	a2,a2,1494 # ffffffffc0202288 <commands+0x648>
ffffffffc0200cba:	0f000593          	li	a1,240
ffffffffc0200cbe:	00001517          	auipc	a0,0x1
ffffffffc0200cc2:	5e250513          	addi	a0,a0,1506 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200cc6:	ee6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cca:	00001697          	auipc	a3,0x1
ffffffffc0200cce:	64e68693          	addi	a3,a3,1614 # ffffffffc0202318 <commands+0x6d8>
ffffffffc0200cd2:	00001617          	auipc	a2,0x1
ffffffffc0200cd6:	5b660613          	addi	a2,a2,1462 # ffffffffc0202288 <commands+0x648>
ffffffffc0200cda:	0ee00593          	li	a1,238
ffffffffc0200cde:	00001517          	auipc	a0,0x1
ffffffffc0200ce2:	5c250513          	addi	a0,a0,1474 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200ce6:	ec6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cea:	00001697          	auipc	a3,0x1
ffffffffc0200cee:	60e68693          	addi	a3,a3,1550 # ffffffffc02022f8 <commands+0x6b8>
ffffffffc0200cf2:	00001617          	auipc	a2,0x1
ffffffffc0200cf6:	59660613          	addi	a2,a2,1430 # ffffffffc0202288 <commands+0x648>
ffffffffc0200cfa:	0ed00593          	li	a1,237
ffffffffc0200cfe:	00001517          	auipc	a0,0x1
ffffffffc0200d02:	5a250513          	addi	a0,a0,1442 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200d06:	ea6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d0a:	00001697          	auipc	a3,0x1
ffffffffc0200d0e:	5ce68693          	addi	a3,a3,1486 # ffffffffc02022d8 <commands+0x698>
ffffffffc0200d12:	00001617          	auipc	a2,0x1
ffffffffc0200d16:	57660613          	addi	a2,a2,1398 # ffffffffc0202288 <commands+0x648>
ffffffffc0200d1a:	0ec00593          	li	a1,236
ffffffffc0200d1e:	00001517          	auipc	a0,0x1
ffffffffc0200d22:	58250513          	addi	a0,a0,1410 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200d26:	e86ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200d2a:	00001697          	auipc	a3,0x1
ffffffffc0200d2e:	6ee68693          	addi	a3,a3,1774 # ffffffffc0202418 <commands+0x7d8>
ffffffffc0200d32:	00001617          	auipc	a2,0x1
ffffffffc0200d36:	55660613          	addi	a2,a2,1366 # ffffffffc0202288 <commands+0x648>
ffffffffc0200d3a:	0ea00593          	li	a1,234
ffffffffc0200d3e:	00001517          	auipc	a0,0x1
ffffffffc0200d42:	56250513          	addi	a0,a0,1378 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200d46:	e66ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d4a:	00001697          	auipc	a3,0x1
ffffffffc0200d4e:	6b668693          	addi	a3,a3,1718 # ffffffffc0202400 <commands+0x7c0>
ffffffffc0200d52:	00001617          	auipc	a2,0x1
ffffffffc0200d56:	53660613          	addi	a2,a2,1334 # ffffffffc0202288 <commands+0x648>
ffffffffc0200d5a:	0e500593          	li	a1,229
ffffffffc0200d5e:	00001517          	auipc	a0,0x1
ffffffffc0200d62:	54250513          	addi	a0,a0,1346 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200d66:	e46ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d6a:	00001697          	auipc	a3,0x1
ffffffffc0200d6e:	67668693          	addi	a3,a3,1654 # ffffffffc02023e0 <commands+0x7a0>
ffffffffc0200d72:	00001617          	auipc	a2,0x1
ffffffffc0200d76:	51660613          	addi	a2,a2,1302 # ffffffffc0202288 <commands+0x648>
ffffffffc0200d7a:	0dc00593          	li	a1,220
ffffffffc0200d7e:	00001517          	auipc	a0,0x1
ffffffffc0200d82:	52250513          	addi	a0,a0,1314 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200d86:	e26ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200d8a:	00001697          	auipc	a3,0x1
ffffffffc0200d8e:	63668693          	addi	a3,a3,1590 # ffffffffc02023c0 <commands+0x780>
ffffffffc0200d92:	00001617          	auipc	a2,0x1
ffffffffc0200d96:	4f660613          	addi	a2,a2,1270 # ffffffffc0202288 <commands+0x648>
ffffffffc0200d9a:	0db00593          	li	a1,219
ffffffffc0200d9e:	00001517          	auipc	a0,0x1
ffffffffc0200da2:	50250513          	addi	a0,a0,1282 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200da6:	e06ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200daa:	00001697          	auipc	a3,0x1
ffffffffc0200dae:	79e68693          	addi	a3,a3,1950 # ffffffffc0202548 <commands+0x908>
ffffffffc0200db2:	00001617          	auipc	a2,0x1
ffffffffc0200db6:	4d660613          	addi	a2,a2,1238 # ffffffffc0202288 <commands+0x648>
ffffffffc0200dba:	14c00593          	li	a1,332
ffffffffc0200dbe:	00001517          	auipc	a0,0x1
ffffffffc0200dc2:	4e250513          	addi	a0,a0,1250 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200dc6:	de6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200dca:	00001697          	auipc	a3,0x1
ffffffffc0200dce:	69668693          	addi	a3,a3,1686 # ffffffffc0202460 <commands+0x820>
ffffffffc0200dd2:	00001617          	auipc	a2,0x1
ffffffffc0200dd6:	4b660613          	addi	a2,a2,1206 # ffffffffc0202288 <commands+0x648>
ffffffffc0200dda:	14100593          	li	a1,321
ffffffffc0200dde:	00001517          	auipc	a0,0x1
ffffffffc0200de2:	4c250513          	addi	a0,a0,1218 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200de6:	dc6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200dea:	00001697          	auipc	a3,0x1
ffffffffc0200dee:	61668693          	addi	a3,a3,1558 # ffffffffc0202400 <commands+0x7c0>
ffffffffc0200df2:	00001617          	auipc	a2,0x1
ffffffffc0200df6:	49660613          	addi	a2,a2,1174 # ffffffffc0202288 <commands+0x648>
ffffffffc0200dfa:	13b00593          	li	a1,315
ffffffffc0200dfe:	00001517          	auipc	a0,0x1
ffffffffc0200e02:	4a250513          	addi	a0,a0,1186 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200e06:	da6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e0a:	00001697          	auipc	a3,0x1
ffffffffc0200e0e:	71e68693          	addi	a3,a3,1822 # ffffffffc0202528 <commands+0x8e8>
ffffffffc0200e12:	00001617          	auipc	a2,0x1
ffffffffc0200e16:	47660613          	addi	a2,a2,1142 # ffffffffc0202288 <commands+0x648>
ffffffffc0200e1a:	13a00593          	li	a1,314
ffffffffc0200e1e:	00001517          	auipc	a0,0x1
ffffffffc0200e22:	48250513          	addi	a0,a0,1154 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200e26:	d86ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200e2a:	00001697          	auipc	a3,0x1
ffffffffc0200e2e:	6ee68693          	addi	a3,a3,1774 # ffffffffc0202518 <commands+0x8d8>
ffffffffc0200e32:	00001617          	auipc	a2,0x1
ffffffffc0200e36:	45660613          	addi	a2,a2,1110 # ffffffffc0202288 <commands+0x648>
ffffffffc0200e3a:	13200593          	li	a1,306
ffffffffc0200e3e:	00001517          	auipc	a0,0x1
ffffffffc0200e42:	46250513          	addi	a0,a0,1122 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200e46:	d66ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200e4a:	00001697          	auipc	a3,0x1
ffffffffc0200e4e:	6b668693          	addi	a3,a3,1718 # ffffffffc0202500 <commands+0x8c0>
ffffffffc0200e52:	00001617          	auipc	a2,0x1
ffffffffc0200e56:	43660613          	addi	a2,a2,1078 # ffffffffc0202288 <commands+0x648>
ffffffffc0200e5a:	13100593          	li	a1,305
ffffffffc0200e5e:	00001517          	auipc	a0,0x1
ffffffffc0200e62:	44250513          	addi	a0,a0,1090 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200e66:	d46ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200e6a:	00001697          	auipc	a3,0x1
ffffffffc0200e6e:	67668693          	addi	a3,a3,1654 # ffffffffc02024e0 <commands+0x8a0>
ffffffffc0200e72:	00001617          	auipc	a2,0x1
ffffffffc0200e76:	41660613          	addi	a2,a2,1046 # ffffffffc0202288 <commands+0x648>
ffffffffc0200e7a:	13000593          	li	a1,304
ffffffffc0200e7e:	00001517          	auipc	a0,0x1
ffffffffc0200e82:	42250513          	addi	a0,a0,1058 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200e86:	d26ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200e8a:	00001697          	auipc	a3,0x1
ffffffffc0200e8e:	62668693          	addi	a3,a3,1574 # ffffffffc02024b0 <commands+0x870>
ffffffffc0200e92:	00001617          	auipc	a2,0x1
ffffffffc0200e96:	3f660613          	addi	a2,a2,1014 # ffffffffc0202288 <commands+0x648>
ffffffffc0200e9a:	12e00593          	li	a1,302
ffffffffc0200e9e:	00001517          	auipc	a0,0x1
ffffffffc0200ea2:	40250513          	addi	a0,a0,1026 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200ea6:	d06ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200eaa:	00001697          	auipc	a3,0x1
ffffffffc0200eae:	5ee68693          	addi	a3,a3,1518 # ffffffffc0202498 <commands+0x858>
ffffffffc0200eb2:	00001617          	auipc	a2,0x1
ffffffffc0200eb6:	3d660613          	addi	a2,a2,982 # ffffffffc0202288 <commands+0x648>
ffffffffc0200eba:	12d00593          	li	a1,301
ffffffffc0200ebe:	00001517          	auipc	a0,0x1
ffffffffc0200ec2:	3e250513          	addi	a0,a0,994 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200ec6:	ce6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200eca:	00001697          	auipc	a3,0x1
ffffffffc0200ece:	53668693          	addi	a3,a3,1334 # ffffffffc0202400 <commands+0x7c0>
ffffffffc0200ed2:	00001617          	auipc	a2,0x1
ffffffffc0200ed6:	3b660613          	addi	a2,a2,950 # ffffffffc0202288 <commands+0x648>
ffffffffc0200eda:	12100593          	li	a1,289
ffffffffc0200ede:	00001517          	auipc	a0,0x1
ffffffffc0200ee2:	3c250513          	addi	a0,a0,962 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200ee6:	cc6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200eea:	00001697          	auipc	a3,0x1
ffffffffc0200eee:	59668693          	addi	a3,a3,1430 # ffffffffc0202480 <commands+0x840>
ffffffffc0200ef2:	00001617          	auipc	a2,0x1
ffffffffc0200ef6:	39660613          	addi	a2,a2,918 # ffffffffc0202288 <commands+0x648>
ffffffffc0200efa:	11800593          	li	a1,280
ffffffffc0200efe:	00001517          	auipc	a0,0x1
ffffffffc0200f02:	3a250513          	addi	a0,a0,930 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200f06:	ca6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200f0a:	00001697          	auipc	a3,0x1
ffffffffc0200f0e:	56668693          	addi	a3,a3,1382 # ffffffffc0202470 <commands+0x830>
ffffffffc0200f12:	00001617          	auipc	a2,0x1
ffffffffc0200f16:	37660613          	addi	a2,a2,886 # ffffffffc0202288 <commands+0x648>
ffffffffc0200f1a:	11700593          	li	a1,279
ffffffffc0200f1e:	00001517          	auipc	a0,0x1
ffffffffc0200f22:	38250513          	addi	a0,a0,898 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200f26:	c86ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200f2a:	00001697          	auipc	a3,0x1
ffffffffc0200f2e:	53668693          	addi	a3,a3,1334 # ffffffffc0202460 <commands+0x820>
ffffffffc0200f32:	00001617          	auipc	a2,0x1
ffffffffc0200f36:	35660613          	addi	a2,a2,854 # ffffffffc0202288 <commands+0x648>
ffffffffc0200f3a:	0f900593          	li	a1,249
ffffffffc0200f3e:	00001517          	auipc	a0,0x1
ffffffffc0200f42:	36250513          	addi	a0,a0,866 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200f46:	c66ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f4a:	00001697          	auipc	a3,0x1
ffffffffc0200f4e:	4b668693          	addi	a3,a3,1206 # ffffffffc0202400 <commands+0x7c0>
ffffffffc0200f52:	00001617          	auipc	a2,0x1
ffffffffc0200f56:	33660613          	addi	a2,a2,822 # ffffffffc0202288 <commands+0x648>
ffffffffc0200f5a:	0f700593          	li	a1,247
ffffffffc0200f5e:	00001517          	auipc	a0,0x1
ffffffffc0200f62:	34250513          	addi	a0,a0,834 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200f66:	c46ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f6a:	00001697          	auipc	a3,0x1
ffffffffc0200f6e:	4d668693          	addi	a3,a3,1238 # ffffffffc0202440 <commands+0x800>
ffffffffc0200f72:	00001617          	auipc	a2,0x1
ffffffffc0200f76:	31660613          	addi	a2,a2,790 # ffffffffc0202288 <commands+0x648>
ffffffffc0200f7a:	0f600593          	li	a1,246
ffffffffc0200f7e:	00001517          	auipc	a0,0x1
ffffffffc0200f82:	32250513          	addi	a0,a0,802 # ffffffffc02022a0 <commands+0x660>
ffffffffc0200f86:	c26ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f8a <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200f8a:	1141                	addi	sp,sp,-16
ffffffffc0200f8c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200f8e:	18058063          	beqz	a1,ffffffffc020110e <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0200f92:	00159693          	slli	a3,a1,0x1
ffffffffc0200f96:	96ae                	add	a3,a3,a1
ffffffffc0200f98:	0692                	slli	a3,a3,0x4
ffffffffc0200f9a:	96aa                	add	a3,a3,a0
ffffffffc0200f9c:	02d50d63          	beq	a0,a3,ffffffffc0200fd6 <best_fit_free_pages+0x4c>
ffffffffc0200fa0:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200fa2:	8b85                	andi	a5,a5,1
ffffffffc0200fa4:	14079563          	bnez	a5,ffffffffc02010ee <best_fit_free_pages+0x164>
ffffffffc0200fa8:	651c                	ld	a5,8(a0)
ffffffffc0200faa:	8385                	srli	a5,a5,0x1
ffffffffc0200fac:	8b85                	andi	a5,a5,1
ffffffffc0200fae:	14079063          	bnez	a5,ffffffffc02010ee <best_fit_free_pages+0x164>
ffffffffc0200fb2:	87aa                	mv	a5,a0
ffffffffc0200fb4:	a809                	j	ffffffffc0200fc6 <best_fit_free_pages+0x3c>
ffffffffc0200fb6:	6798                	ld	a4,8(a5)
ffffffffc0200fb8:	8b05                	andi	a4,a4,1
ffffffffc0200fba:	12071a63          	bnez	a4,ffffffffc02010ee <best_fit_free_pages+0x164>
ffffffffc0200fbe:	6798                	ld	a4,8(a5)
ffffffffc0200fc0:	8b09                	andi	a4,a4,2
ffffffffc0200fc2:	12071663          	bnez	a4,ffffffffc02010ee <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc0200fc6:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200fca:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200fce:	03078793          	addi	a5,a5,48
ffffffffc0200fd2:	fed792e3          	bne	a5,a3,ffffffffc0200fb6 <best_fit_free_pages+0x2c>
        base->property = n;
ffffffffc0200fd6:	2581                	sext.w	a1,a1
ffffffffc0200fd8:	c90c                	sw	a1,16(a0)
	SetPageProperty(base);
ffffffffc0200fda:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200fde:	4789                	li	a5,2
ffffffffc0200fe0:	40f8b02f          	amoor.d	zero,a5,(a7)
	nr_free += n;
ffffffffc0200fe4:	00005697          	auipc	a3,0x5
ffffffffc0200fe8:	45c68693          	addi	a3,a3,1116 # ffffffffc0206440 <free_area>
ffffffffc0200fec:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200fee:	669c                	ld	a5,8(a3)
ffffffffc0200ff0:	9db9                	addw	a1,a1,a4
ffffffffc0200ff2:	00005717          	auipc	a4,0x5
ffffffffc0200ff6:	44b72f23          	sw	a1,1118(a4) # ffffffffc0206450 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0200ffa:	08d78f63          	beq	a5,a3,ffffffffc0201098 <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0200ffe:	fe878713          	addi	a4,a5,-24
ffffffffc0201002:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201004:	4801                	li	a6,0
ffffffffc0201006:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020100a:	00e56a63          	bltu	a0,a4,ffffffffc020101e <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc020100e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201010:	02d70563          	beq	a4,a3,ffffffffc020103a <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201014:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201016:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020101a:	fee57ae3          	bleu	a4,a0,ffffffffc020100e <best_fit_free_pages+0x84>
ffffffffc020101e:	00080663          	beqz	a6,ffffffffc020102a <best_fit_free_pages+0xa0>
ffffffffc0201022:	00005817          	auipc	a6,0x5
ffffffffc0201026:	40b83f23          	sd	a1,1054(a6) # ffffffffc0206440 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020102a:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020102c:	e390                	sd	a2,0(a5)
ffffffffc020102e:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0201030:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201032:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0201034:	02d59163          	bne	a1,a3,ffffffffc0201056 <best_fit_free_pages+0xcc>
ffffffffc0201038:	a091                	j	ffffffffc020107c <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc020103a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020103c:	f114                	sd	a3,32(a0)
ffffffffc020103e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201040:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201042:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201044:	00d70563          	beq	a4,a3,ffffffffc020104e <best_fit_free_pages+0xc4>
ffffffffc0201048:	4805                	li	a6,1
ffffffffc020104a:	87ba                	mv	a5,a4
ffffffffc020104c:	b7e9                	j	ffffffffc0201016 <best_fit_free_pages+0x8c>
ffffffffc020104e:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201050:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201052:	02d78163          	beq	a5,a3,ffffffffc0201074 <best_fit_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0201056:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc020105a:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base) {
ffffffffc020105e:	02081713          	slli	a4,a6,0x20
ffffffffc0201062:	9301                	srli	a4,a4,0x20
ffffffffc0201064:	00171793          	slli	a5,a4,0x1
ffffffffc0201068:	97ba                	add	a5,a5,a4
ffffffffc020106a:	0792                	slli	a5,a5,0x4
ffffffffc020106c:	97b2                	add	a5,a5,a2
ffffffffc020106e:	02f50e63          	beq	a0,a5,ffffffffc02010aa <best_fit_free_pages+0x120>
ffffffffc0201072:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201074:	fe878713          	addi	a4,a5,-24
ffffffffc0201078:	00d78d63          	beq	a5,a3,ffffffffc0201092 <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc020107c:	490c                	lw	a1,16(a0)
ffffffffc020107e:	02059613          	slli	a2,a1,0x20
ffffffffc0201082:	9201                	srli	a2,a2,0x20
ffffffffc0201084:	00161693          	slli	a3,a2,0x1
ffffffffc0201088:	96b2                	add	a3,a3,a2
ffffffffc020108a:	0692                	slli	a3,a3,0x4
ffffffffc020108c:	96aa                	add	a3,a3,a0
ffffffffc020108e:	04d70063          	beq	a4,a3,ffffffffc02010ce <best_fit_free_pages+0x144>
}
ffffffffc0201092:	60a2                	ld	ra,8(sp)
ffffffffc0201094:	0141                	addi	sp,sp,16
ffffffffc0201096:	8082                	ret
ffffffffc0201098:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020109a:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020109e:	e398                	sd	a4,0(a5)
ffffffffc02010a0:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02010a2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010a4:	ed1c                	sd	a5,24(a0)
}
ffffffffc02010a6:	0141                	addi	sp,sp,16
ffffffffc02010a8:	8082                	ret
		p->property += base->property;
ffffffffc02010aa:	491c                	lw	a5,16(a0)
ffffffffc02010ac:	0107883b          	addw	a6,a5,a6
ffffffffc02010b0:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010b4:	57f5                	li	a5,-3
ffffffffc02010b6:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010ba:	01853803          	ld	a6,24(a0)
ffffffffc02010be:	7118                	ld	a4,32(a0)
		base = p;
ffffffffc02010c0:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02010c2:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc02010c6:	659c                	ld	a5,8(a1)
ffffffffc02010c8:	01073023          	sd	a6,0(a4)
ffffffffc02010cc:	b765                	j	ffffffffc0201074 <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc02010ce:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010d2:	ff078693          	addi	a3,a5,-16
ffffffffc02010d6:	9db9                	addw	a1,a1,a4
ffffffffc02010d8:	c90c                	sw	a1,16(a0)
ffffffffc02010da:	5775                	li	a4,-3
ffffffffc02010dc:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010e0:	6398                	ld	a4,0(a5)
ffffffffc02010e2:	679c                	ld	a5,8(a5)
}
ffffffffc02010e4:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02010e6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02010e8:	e398                	sd	a4,0(a5)
ffffffffc02010ea:	0141                	addi	sp,sp,16
ffffffffc02010ec:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02010ee:	00001697          	auipc	a3,0x1
ffffffffc02010f2:	47a68693          	addi	a3,a3,1146 # ffffffffc0202568 <commands+0x928>
ffffffffc02010f6:	00001617          	auipc	a2,0x1
ffffffffc02010fa:	19260613          	addi	a2,a2,402 # ffffffffc0202288 <commands+0x648>
ffffffffc02010fe:	09300593          	li	a1,147
ffffffffc0201102:	00001517          	auipc	a0,0x1
ffffffffc0201106:	19e50513          	addi	a0,a0,414 # ffffffffc02022a0 <commands+0x660>
ffffffffc020110a:	aa2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020110e:	00001697          	auipc	a3,0x1
ffffffffc0201112:	48268693          	addi	a3,a3,1154 # ffffffffc0202590 <commands+0x950>
ffffffffc0201116:	00001617          	auipc	a2,0x1
ffffffffc020111a:	17260613          	addi	a2,a2,370 # ffffffffc0202288 <commands+0x648>
ffffffffc020111e:	09000593          	li	a1,144
ffffffffc0201122:	00001517          	auipc	a0,0x1
ffffffffc0201126:	17e50513          	addi	a0,a0,382 # ffffffffc02022a0 <commands+0x660>
ffffffffc020112a:	a82ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020112e <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020112e:	c145                	beqz	a0,ffffffffc02011ce <best_fit_alloc_pages+0xa0>
    if (n > nr_free) {
ffffffffc0201130:	00005617          	auipc	a2,0x5
ffffffffc0201134:	31060613          	addi	a2,a2,784 # ffffffffc0206440 <free_area>
ffffffffc0201138:	01062803          	lw	a6,16(a2)
ffffffffc020113c:	86aa                	mv	a3,a0
ffffffffc020113e:	02081793          	slli	a5,a6,0x20
ffffffffc0201142:	9381                	srli	a5,a5,0x20
ffffffffc0201144:	08a7e363          	bltu	a5,a0,ffffffffc02011ca <best_fit_alloc_pages+0x9c>
    size_t best_size = ~(size_t)0;
ffffffffc0201148:	55fd                	li	a1,-1
    list_entry_t *le = &free_list;
ffffffffc020114a:	87b2                	mv	a5,a2
    struct Page *page = NULL;
ffffffffc020114c:	4501                	li	a0,0
    return listelm->next;
ffffffffc020114e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201150:	00c78e63          	beq	a5,a2,ffffffffc020116c <best_fit_alloc_pages+0x3e>
        if (p->property >= n && p->property < best_size) {
ffffffffc0201154:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0201158:	fed76be3          	bltu	a4,a3,ffffffffc020114e <best_fit_alloc_pages+0x20>
ffffffffc020115c:	feb779e3          	bleu	a1,a4,ffffffffc020114e <best_fit_alloc_pages+0x20>
        struct Page *p = le2page(le, page_link);
ffffffffc0201160:	fe878513          	addi	a0,a5,-24
ffffffffc0201164:	679c                	ld	a5,8(a5)
ffffffffc0201166:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201168:	fec796e3          	bne	a5,a2,ffffffffc0201154 <best_fit_alloc_pages+0x26>
    if (page != NULL) {
ffffffffc020116c:	c125                	beqz	a0,ffffffffc02011cc <best_fit_alloc_pages+0x9e>
    __list_del(listelm->prev, listelm->next);
ffffffffc020116e:	7118                	ld	a4,32(a0)
    return listelm->prev;
ffffffffc0201170:	6d10                	ld	a2,24(a0)
        if (page->property > n) {
ffffffffc0201172:	490c                	lw	a1,16(a0)
ffffffffc0201174:	0006889b          	sext.w	a7,a3
    prev->next = next;
ffffffffc0201178:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc020117a:	e310                	sd	a2,0(a4)
ffffffffc020117c:	02059713          	slli	a4,a1,0x20
ffffffffc0201180:	9301                	srli	a4,a4,0x20
ffffffffc0201182:	02e6f863          	bleu	a4,a3,ffffffffc02011b2 <best_fit_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc0201186:	00169713          	slli	a4,a3,0x1
ffffffffc020118a:	9736                	add	a4,a4,a3
ffffffffc020118c:	0712                	slli	a4,a4,0x4
ffffffffc020118e:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201190:	411585bb          	subw	a1,a1,a7
ffffffffc0201194:	cb0c                	sw	a1,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201196:	4689                	li	a3,2
ffffffffc0201198:	00870593          	addi	a1,a4,8
ffffffffc020119c:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02011a0:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc02011a2:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc02011a6:	0107a803          	lw	a6,16(a5)
ffffffffc02011aa:	e28c                	sd	a1,0(a3)
ffffffffc02011ac:	e60c                	sd	a1,8(a2)
    elm->next = next;
ffffffffc02011ae:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02011b0:	ef10                	sd	a2,24(a4)
        nr_free -= n;
ffffffffc02011b2:	4118083b          	subw	a6,a6,a7
ffffffffc02011b6:	00005797          	auipc	a5,0x5
ffffffffc02011ba:	2907ad23          	sw	a6,666(a5) # ffffffffc0206450 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02011be:	57f5                	li	a5,-3
ffffffffc02011c0:	00850713          	addi	a4,a0,8
ffffffffc02011c4:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc02011c8:	8082                	ret
        return NULL;
ffffffffc02011ca:	4501                	li	a0,0
}
ffffffffc02011cc:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02011ce:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02011d0:	00001697          	auipc	a3,0x1
ffffffffc02011d4:	3c068693          	addi	a3,a3,960 # ffffffffc0202590 <commands+0x950>
ffffffffc02011d8:	00001617          	auipc	a2,0x1
ffffffffc02011dc:	0b060613          	addi	a2,a2,176 # ffffffffc0202288 <commands+0x648>
ffffffffc02011e0:	06b00593          	li	a1,107
ffffffffc02011e4:	00001517          	auipc	a0,0x1
ffffffffc02011e8:	0bc50513          	addi	a0,a0,188 # ffffffffc02022a0 <commands+0x660>
best_fit_alloc_pages(size_t n) {
ffffffffc02011ec:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011ee:	9beff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011f2 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02011f2:	1141                	addi	sp,sp,-16
ffffffffc02011f4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011f6:	c1fd                	beqz	a1,ffffffffc02012dc <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02011f8:	00159693          	slli	a3,a1,0x1
ffffffffc02011fc:	96ae                	add	a3,a3,a1
ffffffffc02011fe:	0692                	slli	a3,a3,0x4
ffffffffc0201200:	96aa                	add	a3,a3,a0
ffffffffc0201202:	02d50463          	beq	a0,a3,ffffffffc020122a <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201206:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0201208:	87aa                	mv	a5,a0
ffffffffc020120a:	8b05                	andi	a4,a4,1
ffffffffc020120c:	e709                	bnez	a4,ffffffffc0201216 <best_fit_init_memmap+0x24>
ffffffffc020120e:	a07d                	j	ffffffffc02012bc <best_fit_init_memmap+0xca>
ffffffffc0201210:	6798                	ld	a4,8(a5)
ffffffffc0201212:	8b05                	andi	a4,a4,1
ffffffffc0201214:	c745                	beqz	a4,ffffffffc02012bc <best_fit_init_memmap+0xca>
	p->flags = p->property = 0;
ffffffffc0201216:	0007a823          	sw	zero,16(a5)
ffffffffc020121a:	0007b423          	sd	zero,8(a5)
ffffffffc020121e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201222:	03078793          	addi	a5,a5,48
ffffffffc0201226:	fed795e3          	bne	a5,a3,ffffffffc0201210 <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc020122a:	2581                	sext.w	a1,a1
ffffffffc020122c:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020122e:	4789                	li	a5,2
ffffffffc0201230:	00850713          	addi	a4,a0,8
ffffffffc0201234:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201238:	00005697          	auipc	a3,0x5
ffffffffc020123c:	20868693          	addi	a3,a3,520 # ffffffffc0206440 <free_area>
ffffffffc0201240:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201242:	669c                	ld	a5,8(a3)
ffffffffc0201244:	9db9                	addw	a1,a1,a4
ffffffffc0201246:	00005717          	auipc	a4,0x5
ffffffffc020124a:	20b72523          	sw	a1,522(a4) # ffffffffc0206450 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020124e:	04d78a63          	beq	a5,a3,ffffffffc02012a2 <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0201252:	fe878713          	addi	a4,a5,-24
ffffffffc0201256:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201258:	4801                	li	a6,0
ffffffffc020125a:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020125e:	00e56a63          	bltu	a0,a4,ffffffffc0201272 <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc0201262:	6798                	ld	a4,8(a5)
	    else if (list_next(le) == &free_list) {
ffffffffc0201264:	02d70563          	beq	a4,a3,ffffffffc020128e <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201268:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020126a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020126e:	fee57ae3          	bleu	a4,a0,ffffffffc0201262 <best_fit_init_memmap+0x70>
ffffffffc0201272:	00080663          	beqz	a6,ffffffffc020127e <best_fit_init_memmap+0x8c>
ffffffffc0201276:	00005717          	auipc	a4,0x5
ffffffffc020127a:	1cb73523          	sd	a1,458(a4) # ffffffffc0206440 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020127e:	6398                	ld	a4,0(a5)
}
ffffffffc0201280:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201282:	e390                	sd	a2,0(a5)
ffffffffc0201284:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201286:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201288:	ed18                	sd	a4,24(a0)
ffffffffc020128a:	0141                	addi	sp,sp,16
ffffffffc020128c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020128e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201290:	f114                	sd	a3,32(a0)
ffffffffc0201292:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201294:	ed1c                	sd	a5,24(a0)
			list_add(le, &(base->page_link));
ffffffffc0201296:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201298:	00d70e63          	beq	a4,a3,ffffffffc02012b4 <best_fit_init_memmap+0xc2>
ffffffffc020129c:	4805                	li	a6,1
ffffffffc020129e:	87ba                	mv	a5,a4
ffffffffc02012a0:	b7e9                	j	ffffffffc020126a <best_fit_init_memmap+0x78>
}
ffffffffc02012a2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02012a4:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02012a8:	e398                	sd	a4,0(a5)
ffffffffc02012aa:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02012ac:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02012ae:	ed1c                	sd	a5,24(a0)
}
ffffffffc02012b0:	0141                	addi	sp,sp,16
ffffffffc02012b2:	8082                	ret
ffffffffc02012b4:	60a2                	ld	ra,8(sp)
ffffffffc02012b6:	e290                	sd	a2,0(a3)
ffffffffc02012b8:	0141                	addi	sp,sp,16
ffffffffc02012ba:	8082                	ret
        assert(PageReserved(p));
ffffffffc02012bc:	00001697          	auipc	a3,0x1
ffffffffc02012c0:	2dc68693          	addi	a3,a3,732 # ffffffffc0202598 <commands+0x958>
ffffffffc02012c4:	00001617          	auipc	a2,0x1
ffffffffc02012c8:	fc460613          	addi	a2,a2,-60 # ffffffffc0202288 <commands+0x648>
ffffffffc02012cc:	04a00593          	li	a1,74
ffffffffc02012d0:	00001517          	auipc	a0,0x1
ffffffffc02012d4:	fd050513          	addi	a0,a0,-48 # ffffffffc02022a0 <commands+0x660>
ffffffffc02012d8:	8d4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02012dc:	00001697          	auipc	a3,0x1
ffffffffc02012e0:	2b468693          	addi	a3,a3,692 # ffffffffc0202590 <commands+0x950>
ffffffffc02012e4:	00001617          	auipc	a2,0x1
ffffffffc02012e8:	fa460613          	addi	a2,a2,-92 # ffffffffc0202288 <commands+0x648>
ffffffffc02012ec:	04700593          	li	a1,71
ffffffffc02012f0:	00001517          	auipc	a0,0x1
ffffffffc02012f4:	fb050513          	addi	a0,a0,-80 # ffffffffc02022a0 <commands+0x660>
ffffffffc02012f8:	8b4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012fc <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012fc:	100027f3          	csrr	a5,sstatus
ffffffffc0201300:	8b89                	andi	a5,a5,2
ffffffffc0201302:	eb89                	bnez	a5,ffffffffc0201314 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201304:	00005797          	auipc	a5,0x5
ffffffffc0201308:	24c78793          	addi	a5,a5,588 # ffffffffc0206550 <pmm_manager>
ffffffffc020130c:	639c                	ld	a5,0(a5)
ffffffffc020130e:	0187b303          	ld	t1,24(a5)
ffffffffc0201312:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0201314:	1141                	addi	sp,sp,-16
ffffffffc0201316:	e406                	sd	ra,8(sp)
ffffffffc0201318:	e022                	sd	s0,0(sp)
ffffffffc020131a:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020131c:	948ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201320:	00005797          	auipc	a5,0x5
ffffffffc0201324:	23078793          	addi	a5,a5,560 # ffffffffc0206550 <pmm_manager>
ffffffffc0201328:	639c                	ld	a5,0(a5)
ffffffffc020132a:	8522                	mv	a0,s0
ffffffffc020132c:	6f9c                	ld	a5,24(a5)
ffffffffc020132e:	9782                	jalr	a5
ffffffffc0201330:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201332:	92cff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201336:	8522                	mv	a0,s0
ffffffffc0201338:	60a2                	ld	ra,8(sp)
ffffffffc020133a:	6402                	ld	s0,0(sp)
ffffffffc020133c:	0141                	addi	sp,sp,16
ffffffffc020133e:	8082                	ret

ffffffffc0201340 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201340:	100027f3          	csrr	a5,sstatus
ffffffffc0201344:	8b89                	andi	a5,a5,2
ffffffffc0201346:	eb89                	bnez	a5,ffffffffc0201358 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201348:	00005797          	auipc	a5,0x5
ffffffffc020134c:	20878793          	addi	a5,a5,520 # ffffffffc0206550 <pmm_manager>
ffffffffc0201350:	639c                	ld	a5,0(a5)
ffffffffc0201352:	0207b303          	ld	t1,32(a5)
ffffffffc0201356:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201358:	1101                	addi	sp,sp,-32
ffffffffc020135a:	ec06                	sd	ra,24(sp)
ffffffffc020135c:	e822                	sd	s0,16(sp)
ffffffffc020135e:	e426                	sd	s1,8(sp)
ffffffffc0201360:	842a                	mv	s0,a0
ffffffffc0201362:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201364:	900ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201368:	00005797          	auipc	a5,0x5
ffffffffc020136c:	1e878793          	addi	a5,a5,488 # ffffffffc0206550 <pmm_manager>
ffffffffc0201370:	639c                	ld	a5,0(a5)
ffffffffc0201372:	85a6                	mv	a1,s1
ffffffffc0201374:	8522                	mv	a0,s0
ffffffffc0201376:	739c                	ld	a5,32(a5)
ffffffffc0201378:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020137a:	6442                	ld	s0,16(sp)
ffffffffc020137c:	60e2                	ld	ra,24(sp)
ffffffffc020137e:	64a2                	ld	s1,8(sp)
ffffffffc0201380:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201382:	8dcff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201386 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201386:	100027f3          	csrr	a5,sstatus
ffffffffc020138a:	8b89                	andi	a5,a5,2
ffffffffc020138c:	eb89                	bnez	a5,ffffffffc020139e <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020138e:	00005797          	auipc	a5,0x5
ffffffffc0201392:	1c278793          	addi	a5,a5,450 # ffffffffc0206550 <pmm_manager>
ffffffffc0201396:	639c                	ld	a5,0(a5)
ffffffffc0201398:	0287b303          	ld	t1,40(a5)
ffffffffc020139c:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc020139e:	1141                	addi	sp,sp,-16
ffffffffc02013a0:	e406                	sd	ra,8(sp)
ffffffffc02013a2:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02013a4:	8c0ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02013a8:	00005797          	auipc	a5,0x5
ffffffffc02013ac:	1a878793          	addi	a5,a5,424 # ffffffffc0206550 <pmm_manager>
ffffffffc02013b0:	639c                	ld	a5,0(a5)
ffffffffc02013b2:	779c                	ld	a5,40(a5)
ffffffffc02013b4:	9782                	jalr	a5
ffffffffc02013b6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02013b8:	8a6ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02013bc:	8522                	mv	a0,s0
ffffffffc02013be:	60a2                	ld	ra,8(sp)
ffffffffc02013c0:	6402                	ld	s0,0(sp)
ffffffffc02013c2:	0141                	addi	sp,sp,16
ffffffffc02013c4:	8082                	ret

ffffffffc02013c6 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013c6:	00001797          	auipc	a5,0x1
ffffffffc02013ca:	1e278793          	addi	a5,a5,482 # ffffffffc02025a8 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013ce:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02013d0:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013d2:	00001517          	auipc	a0,0x1
ffffffffc02013d6:	22650513          	addi	a0,a0,550 # ffffffffc02025f8 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc02013da:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013dc:	00005717          	auipc	a4,0x5
ffffffffc02013e0:	16f73a23          	sd	a5,372(a4) # ffffffffc0206550 <pmm_manager>
void pmm_init(void) {
ffffffffc02013e4:	e822                	sd	s0,16(sp)
ffffffffc02013e6:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013e8:	00005417          	auipc	s0,0x5
ffffffffc02013ec:	16840413          	addi	s0,s0,360 # ffffffffc0206550 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013f0:	cc7fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02013f4:	601c                	ld	a5,0(s0)
ffffffffc02013f6:	679c                	ld	a5,8(a5)
ffffffffc02013f8:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013fa:	57f5                	li	a5,-3
ffffffffc02013fc:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02013fe:	00001517          	auipc	a0,0x1
ffffffffc0201402:	21250513          	addi	a0,a0,530 # ffffffffc0202610 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201406:	00005717          	auipc	a4,0x5
ffffffffc020140a:	14f73923          	sd	a5,338(a4) # ffffffffc0206558 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020140e:	ca9fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201412:	46c5                	li	a3,17
ffffffffc0201414:	06ee                	slli	a3,a3,0x1b
ffffffffc0201416:	40100613          	li	a2,1025
ffffffffc020141a:	16fd                	addi	a3,a3,-1
ffffffffc020141c:	0656                	slli	a2,a2,0x15
ffffffffc020141e:	07e005b7          	lui	a1,0x7e00
ffffffffc0201422:	00001517          	auipc	a0,0x1
ffffffffc0201426:	20650513          	addi	a0,a0,518 # ffffffffc0202628 <best_fit_pmm_manager+0x80>
ffffffffc020142a:	c8dfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020142e:	777d                	lui	a4,0xfffff
ffffffffc0201430:	00006797          	auipc	a5,0x6
ffffffffc0201434:	13778793          	addi	a5,a5,311 # ffffffffc0207567 <end+0xfff>
ffffffffc0201438:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020143a:	00088737          	lui	a4,0x88
ffffffffc020143e:	00005697          	auipc	a3,0x5
ffffffffc0201442:	fee6b123          	sd	a4,-30(a3) # ffffffffc0206420 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201446:	4601                	li	a2,0
ffffffffc0201448:	00005717          	auipc	a4,0x5
ffffffffc020144c:	10f73c23          	sd	a5,280(a4) # ffffffffc0206560 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201450:	4681                	li	a3,0
ffffffffc0201452:	00005897          	auipc	a7,0x5
ffffffffc0201456:	fce88893          	addi	a7,a7,-50 # ffffffffc0206420 <npage>
ffffffffc020145a:	00005597          	auipc	a1,0x5
ffffffffc020145e:	10658593          	addi	a1,a1,262 # ffffffffc0206560 <pages>
ffffffffc0201462:	4805                	li	a6,1
ffffffffc0201464:	fff80537          	lui	a0,0xfff80
ffffffffc0201468:	a011                	j	ffffffffc020146c <pmm_init+0xa6>
ffffffffc020146a:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020146c:	97b2                	add	a5,a5,a2
ffffffffc020146e:	07a1                	addi	a5,a5,8
ffffffffc0201470:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201474:	0008b703          	ld	a4,0(a7)
ffffffffc0201478:	0685                	addi	a3,a3,1
ffffffffc020147a:	03060613          	addi	a2,a2,48
ffffffffc020147e:	00a707b3          	add	a5,a4,a0
ffffffffc0201482:	fef6e4e3          	bltu	a3,a5,ffffffffc020146a <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201486:	6190                	ld	a2,0(a1)
ffffffffc0201488:	00171793          	slli	a5,a4,0x1
ffffffffc020148c:	97ba                	add	a5,a5,a4
ffffffffc020148e:	fe8006b7          	lui	a3,0xfe800
ffffffffc0201492:	0792                	slli	a5,a5,0x4
ffffffffc0201494:	96b2                	add	a3,a3,a2
ffffffffc0201496:	96be                	add	a3,a3,a5
ffffffffc0201498:	c02007b7          	lui	a5,0xc0200
ffffffffc020149c:	08f6e863          	bltu	a3,a5,ffffffffc020152c <pmm_init+0x166>
ffffffffc02014a0:	00005497          	auipc	s1,0x5
ffffffffc02014a4:	0b848493          	addi	s1,s1,184 # ffffffffc0206558 <va_pa_offset>
ffffffffc02014a8:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc02014aa:	45c5                	li	a1,17
ffffffffc02014ac:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014ae:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc02014b0:	04b6e963          	bltu	a3,a1,ffffffffc0201502 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02014b4:	601c                	ld	a5,0(s0)
ffffffffc02014b6:	7b9c                	ld	a5,48(a5)
ffffffffc02014b8:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02014ba:	00001517          	auipc	a0,0x1
ffffffffc02014be:	20650513          	addi	a0,a0,518 # ffffffffc02026c0 <best_fit_pmm_manager+0x118>
ffffffffc02014c2:	bf5fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02014c6:	00004697          	auipc	a3,0x4
ffffffffc02014ca:	b3a68693          	addi	a3,a3,-1222 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02014ce:	00005797          	auipc	a5,0x5
ffffffffc02014d2:	f4d7bd23          	sd	a3,-166(a5) # ffffffffc0206428 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02014d6:	c02007b7          	lui	a5,0xc0200
ffffffffc02014da:	06f6e563          	bltu	a3,a5,ffffffffc0201544 <pmm_init+0x17e>
ffffffffc02014de:	609c                	ld	a5,0(s1)
}
ffffffffc02014e0:	6442                	ld	s0,16(sp)
ffffffffc02014e2:	60e2                	ld	ra,24(sp)
ffffffffc02014e4:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014e6:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02014e8:	8e9d                	sub	a3,a3,a5
ffffffffc02014ea:	00005797          	auipc	a5,0x5
ffffffffc02014ee:	04d7bf23          	sd	a3,94(a5) # ffffffffc0206548 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014f2:	00001517          	auipc	a0,0x1
ffffffffc02014f6:	1ee50513          	addi	a0,a0,494 # ffffffffc02026e0 <best_fit_pmm_manager+0x138>
ffffffffc02014fa:	8636                	mv	a2,a3
}
ffffffffc02014fc:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014fe:	bb9fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201502:	6785                	lui	a5,0x1
ffffffffc0201504:	17fd                	addi	a5,a5,-1
ffffffffc0201506:	96be                	add	a3,a3,a5
ffffffffc0201508:	77fd                	lui	a5,0xfffff
ffffffffc020150a:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020150c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201510:	04e7f663          	bleu	a4,a5,ffffffffc020155c <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0201514:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201516:	97aa                	add	a5,a5,a0
ffffffffc0201518:	00179513          	slli	a0,a5,0x1
ffffffffc020151c:	953e                	add	a0,a0,a5
ffffffffc020151e:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201520:	8d95                	sub	a1,a1,a3
ffffffffc0201522:	0512                	slli	a0,a0,0x4
    pmm_manager->init_memmap(base, n);
ffffffffc0201524:	81b1                	srli	a1,a1,0xc
ffffffffc0201526:	9532                	add	a0,a0,a2
ffffffffc0201528:	9782                	jalr	a5
ffffffffc020152a:	b769                	j	ffffffffc02014b4 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020152c:	00001617          	auipc	a2,0x1
ffffffffc0201530:	12c60613          	addi	a2,a2,300 # ffffffffc0202658 <best_fit_pmm_manager+0xb0>
ffffffffc0201534:	06e00593          	li	a1,110
ffffffffc0201538:	00001517          	auipc	a0,0x1
ffffffffc020153c:	14850513          	addi	a0,a0,328 # ffffffffc0202680 <best_fit_pmm_manager+0xd8>
ffffffffc0201540:	e6dfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201544:	00001617          	auipc	a2,0x1
ffffffffc0201548:	11460613          	addi	a2,a2,276 # ffffffffc0202658 <best_fit_pmm_manager+0xb0>
ffffffffc020154c:	08900593          	li	a1,137
ffffffffc0201550:	00001517          	auipc	a0,0x1
ffffffffc0201554:	13050513          	addi	a0,a0,304 # ffffffffc0202680 <best_fit_pmm_manager+0xd8>
ffffffffc0201558:	e55fe0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020155c:	00001617          	auipc	a2,0x1
ffffffffc0201560:	13460613          	addi	a2,a2,308 # ffffffffc0202690 <best_fit_pmm_manager+0xe8>
ffffffffc0201564:	06b00593          	li	a1,107
ffffffffc0201568:	00001517          	auipc	a0,0x1
ffffffffc020156c:	14850513          	addi	a0,a0,328 # ffffffffc02026b0 <best_fit_pmm_manager+0x108>
ffffffffc0201570:	e3dfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201574 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201574:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201578:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020157a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020157e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201580:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201584:	f022                	sd	s0,32(sp)
ffffffffc0201586:	ec26                	sd	s1,24(sp)
ffffffffc0201588:	e84a                	sd	s2,16(sp)
ffffffffc020158a:	f406                	sd	ra,40(sp)
ffffffffc020158c:	e44e                	sd	s3,8(sp)
ffffffffc020158e:	84aa                	mv	s1,a0
ffffffffc0201590:	892e                	mv	s2,a1
ffffffffc0201592:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201596:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201598:	03067e63          	bleu	a6,a2,ffffffffc02015d4 <printnum+0x60>
ffffffffc020159c:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020159e:	00805763          	blez	s0,ffffffffc02015ac <printnum+0x38>
ffffffffc02015a2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02015a4:	85ca                	mv	a1,s2
ffffffffc02015a6:	854e                	mv	a0,s3
ffffffffc02015a8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02015aa:	fc65                	bnez	s0,ffffffffc02015a2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015ac:	1a02                	slli	s4,s4,0x20
ffffffffc02015ae:	020a5a13          	srli	s4,s4,0x20
ffffffffc02015b2:	00001797          	auipc	a5,0x1
ffffffffc02015b6:	2fe78793          	addi	a5,a5,766 # ffffffffc02028b0 <error_string+0x38>
ffffffffc02015ba:	9a3e                	add	s4,s4,a5
}
ffffffffc02015bc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015be:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02015c2:	70a2                	ld	ra,40(sp)
ffffffffc02015c4:	69a2                	ld	s3,8(sp)
ffffffffc02015c6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015c8:	85ca                	mv	a1,s2
ffffffffc02015ca:	8326                	mv	t1,s1
}
ffffffffc02015cc:	6942                	ld	s2,16(sp)
ffffffffc02015ce:	64e2                	ld	s1,24(sp)
ffffffffc02015d0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015d2:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02015d4:	03065633          	divu	a2,a2,a6
ffffffffc02015d8:	8722                	mv	a4,s0
ffffffffc02015da:	f9bff0ef          	jal	ra,ffffffffc0201574 <printnum>
ffffffffc02015de:	b7f9                	j	ffffffffc02015ac <printnum+0x38>

ffffffffc02015e0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02015e0:	7119                	addi	sp,sp,-128
ffffffffc02015e2:	f4a6                	sd	s1,104(sp)
ffffffffc02015e4:	f0ca                	sd	s2,96(sp)
ffffffffc02015e6:	e8d2                	sd	s4,80(sp)
ffffffffc02015e8:	e4d6                	sd	s5,72(sp)
ffffffffc02015ea:	e0da                	sd	s6,64(sp)
ffffffffc02015ec:	fc5e                	sd	s7,56(sp)
ffffffffc02015ee:	f862                	sd	s8,48(sp)
ffffffffc02015f0:	f06a                	sd	s10,32(sp)
ffffffffc02015f2:	fc86                	sd	ra,120(sp)
ffffffffc02015f4:	f8a2                	sd	s0,112(sp)
ffffffffc02015f6:	ecce                	sd	s3,88(sp)
ffffffffc02015f8:	f466                	sd	s9,40(sp)
ffffffffc02015fa:	ec6e                	sd	s11,24(sp)
ffffffffc02015fc:	892a                	mv	s2,a0
ffffffffc02015fe:	84ae                	mv	s1,a1
ffffffffc0201600:	8d32                	mv	s10,a2
ffffffffc0201602:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201604:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201606:	00001a17          	auipc	s4,0x1
ffffffffc020160a:	11aa0a13          	addi	s4,s4,282 # ffffffffc0202720 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020160e:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201612:	00001c17          	auipc	s8,0x1
ffffffffc0201616:	266c0c13          	addi	s8,s8,614 # ffffffffc0202878 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020161a:	000d4503          	lbu	a0,0(s10)
ffffffffc020161e:	02500793          	li	a5,37
ffffffffc0201622:	001d0413          	addi	s0,s10,1
ffffffffc0201626:	00f50e63          	beq	a0,a5,ffffffffc0201642 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc020162a:	c521                	beqz	a0,ffffffffc0201672 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020162c:	02500993          	li	s3,37
ffffffffc0201630:	a011                	j	ffffffffc0201634 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201632:	c121                	beqz	a0,ffffffffc0201672 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201634:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201636:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201638:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020163a:	fff44503          	lbu	a0,-1(s0)
ffffffffc020163e:	ff351ae3          	bne	a0,s3,ffffffffc0201632 <vprintfmt+0x52>
ffffffffc0201642:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201646:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020164a:	4981                	li	s3,0
ffffffffc020164c:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020164e:	5cfd                	li	s9,-1
ffffffffc0201650:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201652:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201656:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201658:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020165c:	0ff6f693          	andi	a3,a3,255
ffffffffc0201660:	00140d13          	addi	s10,s0,1
ffffffffc0201664:	20d5e563          	bltu	a1,a3,ffffffffc020186e <vprintfmt+0x28e>
ffffffffc0201668:	068a                	slli	a3,a3,0x2
ffffffffc020166a:	96d2                	add	a3,a3,s4
ffffffffc020166c:	4294                	lw	a3,0(a3)
ffffffffc020166e:	96d2                	add	a3,a3,s4
ffffffffc0201670:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201672:	70e6                	ld	ra,120(sp)
ffffffffc0201674:	7446                	ld	s0,112(sp)
ffffffffc0201676:	74a6                	ld	s1,104(sp)
ffffffffc0201678:	7906                	ld	s2,96(sp)
ffffffffc020167a:	69e6                	ld	s3,88(sp)
ffffffffc020167c:	6a46                	ld	s4,80(sp)
ffffffffc020167e:	6aa6                	ld	s5,72(sp)
ffffffffc0201680:	6b06                	ld	s6,64(sp)
ffffffffc0201682:	7be2                	ld	s7,56(sp)
ffffffffc0201684:	7c42                	ld	s8,48(sp)
ffffffffc0201686:	7ca2                	ld	s9,40(sp)
ffffffffc0201688:	7d02                	ld	s10,32(sp)
ffffffffc020168a:	6de2                	ld	s11,24(sp)
ffffffffc020168c:	6109                	addi	sp,sp,128
ffffffffc020168e:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201690:	4705                	li	a4,1
ffffffffc0201692:	008a8593          	addi	a1,s5,8
ffffffffc0201696:	01074463          	blt	a4,a6,ffffffffc020169e <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc020169a:	26080363          	beqz	a6,ffffffffc0201900 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020169e:	000ab603          	ld	a2,0(s5)
ffffffffc02016a2:	46c1                	li	a3,16
ffffffffc02016a4:	8aae                	mv	s5,a1
ffffffffc02016a6:	a06d                	j	ffffffffc0201750 <vprintfmt+0x170>
            goto reswitch;
ffffffffc02016a8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02016ac:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ae:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016b0:	b765                	j	ffffffffc0201658 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02016b2:	000aa503          	lw	a0,0(s5)
ffffffffc02016b6:	85a6                	mv	a1,s1
ffffffffc02016b8:	0aa1                	addi	s5,s5,8
ffffffffc02016ba:	9902                	jalr	s2
            break;
ffffffffc02016bc:	bfb9                	j	ffffffffc020161a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02016be:	4705                	li	a4,1
ffffffffc02016c0:	008a8993          	addi	s3,s5,8
ffffffffc02016c4:	01074463          	blt	a4,a6,ffffffffc02016cc <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02016c8:	22080463          	beqz	a6,ffffffffc02018f0 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02016cc:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02016d0:	24044463          	bltz	s0,ffffffffc0201918 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02016d4:	8622                	mv	a2,s0
ffffffffc02016d6:	8ace                	mv	s5,s3
ffffffffc02016d8:	46a9                	li	a3,10
ffffffffc02016da:	a89d                	j	ffffffffc0201750 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02016dc:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016e0:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02016e2:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02016e4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02016e8:	8fb5                	xor	a5,a5,a3
ffffffffc02016ea:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016ee:	1ad74363          	blt	a4,a3,ffffffffc0201894 <vprintfmt+0x2b4>
ffffffffc02016f2:	00369793          	slli	a5,a3,0x3
ffffffffc02016f6:	97e2                	add	a5,a5,s8
ffffffffc02016f8:	639c                	ld	a5,0(a5)
ffffffffc02016fa:	18078d63          	beqz	a5,ffffffffc0201894 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02016fe:	86be                	mv	a3,a5
ffffffffc0201700:	00001617          	auipc	a2,0x1
ffffffffc0201704:	26060613          	addi	a2,a2,608 # ffffffffc0202960 <error_string+0xe8>
ffffffffc0201708:	85a6                	mv	a1,s1
ffffffffc020170a:	854a                	mv	a0,s2
ffffffffc020170c:	240000ef          	jal	ra,ffffffffc020194c <printfmt>
ffffffffc0201710:	b729                	j	ffffffffc020161a <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201712:	00144603          	lbu	a2,1(s0)
ffffffffc0201716:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201718:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020171a:	bf3d                	j	ffffffffc0201658 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020171c:	4705                	li	a4,1
ffffffffc020171e:	008a8593          	addi	a1,s5,8
ffffffffc0201722:	01074463          	blt	a4,a6,ffffffffc020172a <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201726:	1e080263          	beqz	a6,ffffffffc020190a <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc020172a:	000ab603          	ld	a2,0(s5)
ffffffffc020172e:	46a1                	li	a3,8
ffffffffc0201730:	8aae                	mv	s5,a1
ffffffffc0201732:	a839                	j	ffffffffc0201750 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201734:	03000513          	li	a0,48
ffffffffc0201738:	85a6                	mv	a1,s1
ffffffffc020173a:	e03e                	sd	a5,0(sp)
ffffffffc020173c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020173e:	85a6                	mv	a1,s1
ffffffffc0201740:	07800513          	li	a0,120
ffffffffc0201744:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201746:	0aa1                	addi	s5,s5,8
ffffffffc0201748:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020174c:	6782                	ld	a5,0(sp)
ffffffffc020174e:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201750:	876e                	mv	a4,s11
ffffffffc0201752:	85a6                	mv	a1,s1
ffffffffc0201754:	854a                	mv	a0,s2
ffffffffc0201756:	e1fff0ef          	jal	ra,ffffffffc0201574 <printnum>
            break;
ffffffffc020175a:	b5c1                	j	ffffffffc020161a <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020175c:	000ab603          	ld	a2,0(s5)
ffffffffc0201760:	0aa1                	addi	s5,s5,8
ffffffffc0201762:	1c060663          	beqz	a2,ffffffffc020192e <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201766:	00160413          	addi	s0,a2,1
ffffffffc020176a:	17b05c63          	blez	s11,ffffffffc02018e2 <vprintfmt+0x302>
ffffffffc020176e:	02d00593          	li	a1,45
ffffffffc0201772:	14b79263          	bne	a5,a1,ffffffffc02018b6 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201776:	00064783          	lbu	a5,0(a2)
ffffffffc020177a:	0007851b          	sext.w	a0,a5
ffffffffc020177e:	c905                	beqz	a0,ffffffffc02017ae <vprintfmt+0x1ce>
ffffffffc0201780:	000cc563          	bltz	s9,ffffffffc020178a <vprintfmt+0x1aa>
ffffffffc0201784:	3cfd                	addiw	s9,s9,-1
ffffffffc0201786:	036c8263          	beq	s9,s6,ffffffffc02017aa <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020178a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020178c:	18098463          	beqz	s3,ffffffffc0201914 <vprintfmt+0x334>
ffffffffc0201790:	3781                	addiw	a5,a5,-32
ffffffffc0201792:	18fbf163          	bleu	a5,s7,ffffffffc0201914 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201796:	03f00513          	li	a0,63
ffffffffc020179a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020179c:	0405                	addi	s0,s0,1
ffffffffc020179e:	fff44783          	lbu	a5,-1(s0)
ffffffffc02017a2:	3dfd                	addiw	s11,s11,-1
ffffffffc02017a4:	0007851b          	sext.w	a0,a5
ffffffffc02017a8:	fd61                	bnez	a0,ffffffffc0201780 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02017aa:	e7b058e3          	blez	s11,ffffffffc020161a <vprintfmt+0x3a>
ffffffffc02017ae:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02017b0:	85a6                	mv	a1,s1
ffffffffc02017b2:	02000513          	li	a0,32
ffffffffc02017b6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017b8:	e60d81e3          	beqz	s11,ffffffffc020161a <vprintfmt+0x3a>
ffffffffc02017bc:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02017be:	85a6                	mv	a1,s1
ffffffffc02017c0:	02000513          	li	a0,32
ffffffffc02017c4:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017c6:	fe0d94e3          	bnez	s11,ffffffffc02017ae <vprintfmt+0x1ce>
ffffffffc02017ca:	bd81                	j	ffffffffc020161a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017cc:	4705                	li	a4,1
ffffffffc02017ce:	008a8593          	addi	a1,s5,8
ffffffffc02017d2:	01074463          	blt	a4,a6,ffffffffc02017da <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02017d6:	12080063          	beqz	a6,ffffffffc02018f6 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02017da:	000ab603          	ld	a2,0(s5)
ffffffffc02017de:	46a9                	li	a3,10
ffffffffc02017e0:	8aae                	mv	s5,a1
ffffffffc02017e2:	b7bd                	j	ffffffffc0201750 <vprintfmt+0x170>
ffffffffc02017e4:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02017e8:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017ec:	846a                	mv	s0,s10
ffffffffc02017ee:	b5ad                	j	ffffffffc0201658 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02017f0:	85a6                	mv	a1,s1
ffffffffc02017f2:	02500513          	li	a0,37
ffffffffc02017f6:	9902                	jalr	s2
            break;
ffffffffc02017f8:	b50d                	j	ffffffffc020161a <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02017fa:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02017fe:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201802:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201804:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201806:	e40dd9e3          	bgez	s11,ffffffffc0201658 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020180a:	8de6                	mv	s11,s9
ffffffffc020180c:	5cfd                	li	s9,-1
ffffffffc020180e:	b5a9                	j	ffffffffc0201658 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201810:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201814:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201818:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020181a:	bd3d                	j	ffffffffc0201658 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc020181c:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201820:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201824:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201826:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020182a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020182e:	fcd56ce3          	bltu	a0,a3,ffffffffc0201806 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201832:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201834:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201838:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020183c:	0196873b          	addw	a4,a3,s9
ffffffffc0201840:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201844:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201848:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020184c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201850:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201854:	fcd57fe3          	bleu	a3,a0,ffffffffc0201832 <vprintfmt+0x252>
ffffffffc0201858:	b77d                	j	ffffffffc0201806 <vprintfmt+0x226>
            if (width < 0)
ffffffffc020185a:	fffdc693          	not	a3,s11
ffffffffc020185e:	96fd                	srai	a3,a3,0x3f
ffffffffc0201860:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201864:	00144603          	lbu	a2,1(s0)
ffffffffc0201868:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020186a:	846a                	mv	s0,s10
ffffffffc020186c:	b3f5                	j	ffffffffc0201658 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020186e:	85a6                	mv	a1,s1
ffffffffc0201870:	02500513          	li	a0,37
ffffffffc0201874:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201876:	fff44703          	lbu	a4,-1(s0)
ffffffffc020187a:	02500793          	li	a5,37
ffffffffc020187e:	8d22                	mv	s10,s0
ffffffffc0201880:	d8f70de3          	beq	a4,a5,ffffffffc020161a <vprintfmt+0x3a>
ffffffffc0201884:	02500713          	li	a4,37
ffffffffc0201888:	1d7d                	addi	s10,s10,-1
ffffffffc020188a:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020188e:	fee79de3          	bne	a5,a4,ffffffffc0201888 <vprintfmt+0x2a8>
ffffffffc0201892:	b361                	j	ffffffffc020161a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201894:	00001617          	auipc	a2,0x1
ffffffffc0201898:	0bc60613          	addi	a2,a2,188 # ffffffffc0202950 <error_string+0xd8>
ffffffffc020189c:	85a6                	mv	a1,s1
ffffffffc020189e:	854a                	mv	a0,s2
ffffffffc02018a0:	0ac000ef          	jal	ra,ffffffffc020194c <printfmt>
ffffffffc02018a4:	bb9d                	j	ffffffffc020161a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02018a6:	00001617          	auipc	a2,0x1
ffffffffc02018aa:	0a260613          	addi	a2,a2,162 # ffffffffc0202948 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02018ae:	00001417          	auipc	s0,0x1
ffffffffc02018b2:	09b40413          	addi	s0,s0,155 # ffffffffc0202949 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018b6:	8532                	mv	a0,a2
ffffffffc02018b8:	85e6                	mv	a1,s9
ffffffffc02018ba:	e032                	sd	a2,0(sp)
ffffffffc02018bc:	e43e                	sd	a5,8(sp)
ffffffffc02018be:	1de000ef          	jal	ra,ffffffffc0201a9c <strnlen>
ffffffffc02018c2:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02018c6:	6602                	ld	a2,0(sp)
ffffffffc02018c8:	01b05d63          	blez	s11,ffffffffc02018e2 <vprintfmt+0x302>
ffffffffc02018cc:	67a2                	ld	a5,8(sp)
ffffffffc02018ce:	2781                	sext.w	a5,a5
ffffffffc02018d0:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02018d2:	6522                	ld	a0,8(sp)
ffffffffc02018d4:	85a6                	mv	a1,s1
ffffffffc02018d6:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018d8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02018da:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018dc:	6602                	ld	a2,0(sp)
ffffffffc02018de:	fe0d9ae3          	bnez	s11,ffffffffc02018d2 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018e2:	00064783          	lbu	a5,0(a2)
ffffffffc02018e6:	0007851b          	sext.w	a0,a5
ffffffffc02018ea:	e8051be3          	bnez	a0,ffffffffc0201780 <vprintfmt+0x1a0>
ffffffffc02018ee:	b335                	j	ffffffffc020161a <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02018f0:	000aa403          	lw	s0,0(s5)
ffffffffc02018f4:	bbf1                	j	ffffffffc02016d0 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02018f6:	000ae603          	lwu	a2,0(s5)
ffffffffc02018fa:	46a9                	li	a3,10
ffffffffc02018fc:	8aae                	mv	s5,a1
ffffffffc02018fe:	bd89                	j	ffffffffc0201750 <vprintfmt+0x170>
ffffffffc0201900:	000ae603          	lwu	a2,0(s5)
ffffffffc0201904:	46c1                	li	a3,16
ffffffffc0201906:	8aae                	mv	s5,a1
ffffffffc0201908:	b5a1                	j	ffffffffc0201750 <vprintfmt+0x170>
ffffffffc020190a:	000ae603          	lwu	a2,0(s5)
ffffffffc020190e:	46a1                	li	a3,8
ffffffffc0201910:	8aae                	mv	s5,a1
ffffffffc0201912:	bd3d                	j	ffffffffc0201750 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201914:	9902                	jalr	s2
ffffffffc0201916:	b559                	j	ffffffffc020179c <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201918:	85a6                	mv	a1,s1
ffffffffc020191a:	02d00513          	li	a0,45
ffffffffc020191e:	e03e                	sd	a5,0(sp)
ffffffffc0201920:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201922:	8ace                	mv	s5,s3
ffffffffc0201924:	40800633          	neg	a2,s0
ffffffffc0201928:	46a9                	li	a3,10
ffffffffc020192a:	6782                	ld	a5,0(sp)
ffffffffc020192c:	b515                	j	ffffffffc0201750 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020192e:	01b05663          	blez	s11,ffffffffc020193a <vprintfmt+0x35a>
ffffffffc0201932:	02d00693          	li	a3,45
ffffffffc0201936:	f6d798e3          	bne	a5,a3,ffffffffc02018a6 <vprintfmt+0x2c6>
ffffffffc020193a:	00001417          	auipc	s0,0x1
ffffffffc020193e:	00f40413          	addi	s0,s0,15 # ffffffffc0202949 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201942:	02800513          	li	a0,40
ffffffffc0201946:	02800793          	li	a5,40
ffffffffc020194a:	bd1d                	j	ffffffffc0201780 <vprintfmt+0x1a0>

ffffffffc020194c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020194c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020194e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201952:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201954:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201956:	ec06                	sd	ra,24(sp)
ffffffffc0201958:	f83a                	sd	a4,48(sp)
ffffffffc020195a:	fc3e                	sd	a5,56(sp)
ffffffffc020195c:	e0c2                	sd	a6,64(sp)
ffffffffc020195e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201960:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201962:	c7fff0ef          	jal	ra,ffffffffc02015e0 <vprintfmt>
}
ffffffffc0201966:	60e2                	ld	ra,24(sp)
ffffffffc0201968:	6161                	addi	sp,sp,80
ffffffffc020196a:	8082                	ret

ffffffffc020196c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020196c:	715d                	addi	sp,sp,-80
ffffffffc020196e:	e486                	sd	ra,72(sp)
ffffffffc0201970:	e0a2                	sd	s0,64(sp)
ffffffffc0201972:	fc26                	sd	s1,56(sp)
ffffffffc0201974:	f84a                	sd	s2,48(sp)
ffffffffc0201976:	f44e                	sd	s3,40(sp)
ffffffffc0201978:	f052                	sd	s4,32(sp)
ffffffffc020197a:	ec56                	sd	s5,24(sp)
ffffffffc020197c:	e85a                	sd	s6,16(sp)
ffffffffc020197e:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201980:	c901                	beqz	a0,ffffffffc0201990 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201982:	85aa                	mv	a1,a0
ffffffffc0201984:	00001517          	auipc	a0,0x1
ffffffffc0201988:	fdc50513          	addi	a0,a0,-36 # ffffffffc0202960 <error_string+0xe8>
ffffffffc020198c:	f2afe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201990:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201992:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201994:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201996:	4aa9                	li	s5,10
ffffffffc0201998:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020199a:	00004b97          	auipc	s7,0x4
ffffffffc020199e:	67eb8b93          	addi	s7,s7,1662 # ffffffffc0206018 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019a2:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02019a6:	f88fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019aa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019ac:	00054b63          	bltz	a0,ffffffffc02019c2 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019b0:	00a95b63          	ble	a0,s2,ffffffffc02019c6 <readline+0x5a>
ffffffffc02019b4:	029a5463          	ble	s1,s4,ffffffffc02019dc <readline+0x70>
        c = getchar();
ffffffffc02019b8:	f76fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019bc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019be:	fe0559e3          	bgez	a0,ffffffffc02019b0 <readline+0x44>
            return NULL;
ffffffffc02019c2:	4501                	li	a0,0
ffffffffc02019c4:	a099                	j	ffffffffc0201a0a <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02019c6:	03341463          	bne	s0,s3,ffffffffc02019ee <readline+0x82>
ffffffffc02019ca:	e8b9                	bnez	s1,ffffffffc0201a20 <readline+0xb4>
        c = getchar();
ffffffffc02019cc:	f62fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019d0:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019d2:	fe0548e3          	bltz	a0,ffffffffc02019c2 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019d6:	fea958e3          	ble	a0,s2,ffffffffc02019c6 <readline+0x5a>
ffffffffc02019da:	4481                	li	s1,0
            cputchar(c);
ffffffffc02019dc:	8522                	mv	a0,s0
ffffffffc02019de:	f0cfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02019e2:	009b87b3          	add	a5,s7,s1
ffffffffc02019e6:	00878023          	sb	s0,0(a5)
ffffffffc02019ea:	2485                	addiw	s1,s1,1
ffffffffc02019ec:	bf6d                	j	ffffffffc02019a6 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02019ee:	01540463          	beq	s0,s5,ffffffffc02019f6 <readline+0x8a>
ffffffffc02019f2:	fb641ae3          	bne	s0,s6,ffffffffc02019a6 <readline+0x3a>
            cputchar(c);
ffffffffc02019f6:	8522                	mv	a0,s0
ffffffffc02019f8:	ef2fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02019fc:	00004517          	auipc	a0,0x4
ffffffffc0201a00:	61c50513          	addi	a0,a0,1564 # ffffffffc0206018 <edata>
ffffffffc0201a04:	94aa                	add	s1,s1,a0
ffffffffc0201a06:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201a0a:	60a6                	ld	ra,72(sp)
ffffffffc0201a0c:	6406                	ld	s0,64(sp)
ffffffffc0201a0e:	74e2                	ld	s1,56(sp)
ffffffffc0201a10:	7942                	ld	s2,48(sp)
ffffffffc0201a12:	79a2                	ld	s3,40(sp)
ffffffffc0201a14:	7a02                	ld	s4,32(sp)
ffffffffc0201a16:	6ae2                	ld	s5,24(sp)
ffffffffc0201a18:	6b42                	ld	s6,16(sp)
ffffffffc0201a1a:	6ba2                	ld	s7,8(sp)
ffffffffc0201a1c:	6161                	addi	sp,sp,80
ffffffffc0201a1e:	8082                	ret
            cputchar(c);
ffffffffc0201a20:	4521                	li	a0,8
ffffffffc0201a22:	ec8fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201a26:	34fd                	addiw	s1,s1,-1
ffffffffc0201a28:	bfbd                	j	ffffffffc02019a6 <readline+0x3a>

ffffffffc0201a2a <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201a2a:	00004797          	auipc	a5,0x4
ffffffffc0201a2e:	5de78793          	addi	a5,a5,1502 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201a32:	6398                	ld	a4,0(a5)
ffffffffc0201a34:	4781                	li	a5,0
ffffffffc0201a36:	88ba                	mv	a7,a4
ffffffffc0201a38:	852a                	mv	a0,a0
ffffffffc0201a3a:	85be                	mv	a1,a5
ffffffffc0201a3c:	863e                	mv	a2,a5
ffffffffc0201a3e:	00000073          	ecall
ffffffffc0201a42:	87aa                	mv	a5,a0
}
ffffffffc0201a44:	8082                	ret

ffffffffc0201a46 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201a46:	00005797          	auipc	a5,0x5
ffffffffc0201a4a:	9ea78793          	addi	a5,a5,-1558 # ffffffffc0206430 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201a4e:	6398                	ld	a4,0(a5)
ffffffffc0201a50:	4781                	li	a5,0
ffffffffc0201a52:	88ba                	mv	a7,a4
ffffffffc0201a54:	852a                	mv	a0,a0
ffffffffc0201a56:	85be                	mv	a1,a5
ffffffffc0201a58:	863e                	mv	a2,a5
ffffffffc0201a5a:	00000073          	ecall
ffffffffc0201a5e:	87aa                	mv	a5,a0
}
ffffffffc0201a60:	8082                	ret

ffffffffc0201a62 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201a62:	00004797          	auipc	a5,0x4
ffffffffc0201a66:	59e78793          	addi	a5,a5,1438 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201a6a:	639c                	ld	a5,0(a5)
ffffffffc0201a6c:	4501                	li	a0,0
ffffffffc0201a6e:	88be                	mv	a7,a5
ffffffffc0201a70:	852a                	mv	a0,a0
ffffffffc0201a72:	85aa                	mv	a1,a0
ffffffffc0201a74:	862a                	mv	a2,a0
ffffffffc0201a76:	00000073          	ecall
ffffffffc0201a7a:	852a                	mv	a0,a0
}
ffffffffc0201a7c:	2501                	sext.w	a0,a0
ffffffffc0201a7e:	8082                	ret

ffffffffc0201a80 <sbi_shutdown>:
void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201a80:	00004797          	auipc	a5,0x4
ffffffffc0201a84:	59078793          	addi	a5,a5,1424 # ffffffffc0206010 <SBI_SHUTDOWN>
    __asm__ volatile (
ffffffffc0201a88:	6398                	ld	a4,0(a5)
ffffffffc0201a8a:	4781                	li	a5,0
ffffffffc0201a8c:	88ba                	mv	a7,a4
ffffffffc0201a8e:	853e                	mv	a0,a5
ffffffffc0201a90:	85be                	mv	a1,a5
ffffffffc0201a92:	863e                	mv	a2,a5
ffffffffc0201a94:	00000073          	ecall
ffffffffc0201a98:	87aa                	mv	a5,a0
}
ffffffffc0201a9a:	8082                	ret

ffffffffc0201a9c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a9c:	c185                	beqz	a1,ffffffffc0201abc <strnlen+0x20>
ffffffffc0201a9e:	00054783          	lbu	a5,0(a0)
ffffffffc0201aa2:	cf89                	beqz	a5,ffffffffc0201abc <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201aa4:	4781                	li	a5,0
ffffffffc0201aa6:	a021                	j	ffffffffc0201aae <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201aa8:	00074703          	lbu	a4,0(a4)
ffffffffc0201aac:	c711                	beqz	a4,ffffffffc0201ab8 <strnlen+0x1c>
        cnt ++;
ffffffffc0201aae:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201ab0:	00f50733          	add	a4,a0,a5
ffffffffc0201ab4:	fef59ae3          	bne	a1,a5,ffffffffc0201aa8 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201ab8:	853e                	mv	a0,a5
ffffffffc0201aba:	8082                	ret
    size_t cnt = 0;
ffffffffc0201abc:	4781                	li	a5,0
}
ffffffffc0201abe:	853e                	mv	a0,a5
ffffffffc0201ac0:	8082                	ret

ffffffffc0201ac2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ac2:	00054783          	lbu	a5,0(a0)
ffffffffc0201ac6:	0005c703          	lbu	a4,0(a1)
ffffffffc0201aca:	cb91                	beqz	a5,ffffffffc0201ade <strcmp+0x1c>
ffffffffc0201acc:	00e79c63          	bne	a5,a4,ffffffffc0201ae4 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201ad0:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ad2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201ad6:	0585                	addi	a1,a1,1
ffffffffc0201ad8:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201adc:	fbe5                	bnez	a5,ffffffffc0201acc <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201ade:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201ae0:	9d19                	subw	a0,a0,a4
ffffffffc0201ae2:	8082                	ret
ffffffffc0201ae4:	0007851b          	sext.w	a0,a5
ffffffffc0201ae8:	9d19                	subw	a0,a0,a4
ffffffffc0201aea:	8082                	ret

ffffffffc0201aec <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201aec:	00054783          	lbu	a5,0(a0)
ffffffffc0201af0:	cb91                	beqz	a5,ffffffffc0201b04 <strchr+0x18>
        if (*s == c) {
ffffffffc0201af2:	00b79563          	bne	a5,a1,ffffffffc0201afc <strchr+0x10>
ffffffffc0201af6:	a809                	j	ffffffffc0201b08 <strchr+0x1c>
ffffffffc0201af8:	00b78763          	beq	a5,a1,ffffffffc0201b06 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201afc:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201afe:	00054783          	lbu	a5,0(a0)
ffffffffc0201b02:	fbfd                	bnez	a5,ffffffffc0201af8 <strchr+0xc>
    }
    return NULL;
ffffffffc0201b04:	4501                	li	a0,0
}
ffffffffc0201b06:	8082                	ret
ffffffffc0201b08:	8082                	ret

ffffffffc0201b0a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201b0a:	ca01                	beqz	a2,ffffffffc0201b1a <memset+0x10>
ffffffffc0201b0c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201b0e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201b10:	0785                	addi	a5,a5,1
ffffffffc0201b12:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201b16:	fec79de3          	bne	a5,a2,ffffffffc0201b10 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201b1a:	8082                	ret
