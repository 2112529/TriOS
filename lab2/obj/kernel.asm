
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
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	43260613          	addi	a2,a2,1074 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	341010ef          	jal	ra,ffffffffc0201b8e <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0201ba0 <etext>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	3fc010ef          	jal	ra,ffffffffc0201466 <pmm_init>

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
ffffffffc02000aa:	5d6010ef          	jal	ra,ffffffffc0201680 <vprintfmt>
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
ffffffffc02000de:	5a2010ef          	jal	ra,ffffffffc0201680 <vprintfmt>
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
ffffffffc0200144:	ab050513          	addi	a0,a0,-1360 # ffffffffc0201bf0 <etext+0x50>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	aba50513          	addi	a0,a0,-1350 # ffffffffc0201c10 <etext+0x70>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00002597          	auipc	a1,0x2
ffffffffc0200166:	a3e58593          	addi	a1,a1,-1474 # ffffffffc0201ba0 <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	ac650513          	addi	a0,a0,-1338 # ffffffffc0201c30 <etext+0x90>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	ad250513          	addi	a0,a0,-1326 # ffffffffc0201c50 <etext+0xb0>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2e658593          	addi	a1,a1,742 # ffffffffc0206470 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	ade50513          	addi	a0,a0,-1314 # ffffffffc0201c70 <etext+0xd0>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	6d158593          	addi	a1,a1,1745 # ffffffffc020686f <end+0x3ff>
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
ffffffffc02001c4:	ad050513          	addi	a0,a0,-1328 # ffffffffc0201c90 <etext+0xf0>
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
ffffffffc02001d4:	9f060613          	addi	a2,a2,-1552 # ffffffffc0201bc0 <etext+0x20>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0201bd8 <etext+0x38>
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
ffffffffc02001f0:	bb460613          	addi	a2,a2,-1100 # ffffffffc0201da0 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	bcc58593          	addi	a1,a1,-1076 # ffffffffc0201dc0 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0201dc8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	bce60613          	addi	a2,a2,-1074 # ffffffffc0201dd8 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	bee58593          	addi	a1,a1,-1042 # ffffffffc0201e00 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	bae50513          	addi	a0,a0,-1106 # ffffffffc0201dc8 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	bea60613          	addi	a2,a2,-1046 # ffffffffc0201e10 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	c0258593          	addi	a1,a1,-1022 # ffffffffc0201e30 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	b9250513          	addi	a0,a0,-1134 # ffffffffc0201dc8 <commands+0x108>
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
ffffffffc0200274:	a9850513          	addi	a0,a0,-1384 # ffffffffc0201d08 <commands+0x48>
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
ffffffffc0200296:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0201d30 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00002c97          	auipc	s9,0x2
ffffffffc02002ac:	a18c8c93          	addi	s9,s9,-1512 # ffffffffc0201cc0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	aa898993          	addi	s3,s3,-1368 # ffffffffc0201d58 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	aa890913          	addi	s2,s2,-1368 # ffffffffc0201d60 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	aa6b0b13          	addi	s6,s6,-1370 # ffffffffc0201d68 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	af6a8a93          	addi	s5,s5,-1290 # ffffffffc0201dc0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	736010ef          	jal	ra,ffffffffc0201a0c <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	089010ef          	jal	ra,ffffffffc0201b70 <strchr>
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
ffffffffc0200302:	9c2d0d13          	addi	s10,s10,-1598 # ffffffffc0201cc0 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	03b010ef          	jal	ra,ffffffffc0201b46 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	027010ef          	jal	ra,ffffffffc0201b46 <strcmp>
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
ffffffffc0200386:	7ea010ef          	jal	ra,ffffffffc0201b70 <strchr>
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
ffffffffc02003a2:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0201d88 <commands+0xc8>
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
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
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
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0206410 <is_panic>

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
ffffffffc02003e2:	a6250513          	addi	a0,a0,-1438 # ffffffffc0201e40 <commands+0x180>
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
ffffffffc02003f8:	8c450513          	addi	a0,a0,-1852 # ffffffffc0201cb8 <etext+0x118>
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
ffffffffc0200424:	6c2010ef          	jal	ra,ffffffffc0201ae6 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0201e60 <commands+0x1a0>
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
ffffffffc020044c:	69a0106f          	j	ffffffffc0201ae6 <sbi_set_timer>

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
ffffffffc0200456:	6740106f          	j	ffffffffc0201aca <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	6a80106f          	j	ffffffffc0201b02 <sbi_console_getchar>

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
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
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
ffffffffc0200488:	af450513          	addi	a0,a0,-1292 # ffffffffc0201f78 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	afc50513          	addi	a0,a0,-1284 # ffffffffc0201f90 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	b0650513          	addi	a0,a0,-1274 # ffffffffc0201fa8 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	b1050513          	addi	a0,a0,-1264 # ffffffffc0201fc0 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0201fd8 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	b2450513          	addi	a0,a0,-1244 # ffffffffc0201ff0 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0202008 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	b3850513          	addi	a0,a0,-1224 # ffffffffc0202020 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	b4250513          	addi	a0,a0,-1214 # ffffffffc0202038 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0202050 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	b5650513          	addi	a0,a0,-1194 # ffffffffc0202068 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	b6050513          	addi	a0,a0,-1184 # ffffffffc0202080 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0202098 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	b7450513          	addi	a0,a0,-1164 # ffffffffc02020b0 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	b7e50513          	addi	a0,a0,-1154 # ffffffffc02020c8 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	b8850513          	addi	a0,a0,-1144 # ffffffffc02020e0 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	b9250513          	addi	a0,a0,-1134 # ffffffffc02020f8 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0202110 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	ba650513          	addi	a0,a0,-1114 # ffffffffc0202128 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	bb050513          	addi	a0,a0,-1104 # ffffffffc0202140 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0202158 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	bc450513          	addi	a0,a0,-1084 # ffffffffc0202170 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	bce50513          	addi	a0,a0,-1074 # ffffffffc0202188 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	bd850513          	addi	a0,a0,-1064 # ffffffffc02021a0 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	be250513          	addi	a0,a0,-1054 # ffffffffc02021b8 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	bec50513          	addi	a0,a0,-1044 # ffffffffc02021d0 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	bf650513          	addi	a0,a0,-1034 # ffffffffc02021e8 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	c0050513          	addi	a0,a0,-1024 # ffffffffc0202200 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0202218 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	c1450513          	addi	a0,a0,-1004 # ffffffffc0202230 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	c1e50513          	addi	a0,a0,-994 # ffffffffc0202248 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	c2450513          	addi	a0,a0,-988 # ffffffffc0202260 <commands+0x5a0>
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
ffffffffc0200656:	c2650513          	addi	a0,a0,-986 # ffffffffc0202278 <commands+0x5b8>
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
ffffffffc020066e:	c2650513          	addi	a0,a0,-986 # ffffffffc0202290 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	c2e50513          	addi	a0,a0,-978 # ffffffffc02022a8 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	c3650513          	addi	a0,a0,-970 # ffffffffc02022c0 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	c3a50513          	addi	a0,a0,-966 # ffffffffc02022d8 <commands+0x618>
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
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	7c070713          	addi	a4,a4,1984 # ffffffffc0201e7c <commands+0x1bc>
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
ffffffffc02006ce:	00002517          	auipc	a0,0x2
ffffffffc02006d2:	84250513          	addi	a0,a0,-1982 # ffffffffc0201f10 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00002517          	auipc	a0,0x2
ffffffffc02006de:	81650513          	addi	a0,a0,-2026 # ffffffffc0201ef0 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	7ca50513          	addi	a0,a0,1994 # ffffffffc0201eb0 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00002517          	auipc	a0,0x2
ffffffffc02006f6:	83e50513          	addi	a0,a0,-1986 # ffffffffc0201f30 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00002517          	auipc	a0,0x2
ffffffffc020072e:	82e50513          	addi	a0,a0,-2002 # ffffffffc0201f58 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	79a50513          	addi	a0,a0,1946 # ffffffffc0201ed0 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	7fc50513          	addi	a0,a0,2044 # ffffffffc0201f48 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020082a:	00006797          	auipc	a5,0x6
ffffffffc020082e:	c0e78793          	addi	a5,a5,-1010 # ffffffffc0206438 <free_area>
ffffffffc0200832:	e79c                	sd	a5,8(a5)
ffffffffc0200834:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200836:	0007a823          	sw	zero,16(a5)
}
ffffffffc020083a:	8082                	ret

ffffffffc020083c <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	c0c56503          	lwu	a0,-1012(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200844:	8082                	ret

ffffffffc0200846 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200846:	715d                	addi	sp,sp,-80
ffffffffc0200848:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020084a:	00006917          	auipc	s2,0x6
ffffffffc020084e:	bee90913          	addi	s2,s2,-1042 # ffffffffc0206438 <free_area>
ffffffffc0200852:	00893783          	ld	a5,8(s2)
ffffffffc0200856:	e486                	sd	ra,72(sp)
ffffffffc0200858:	e0a2                	sd	s0,64(sp)
ffffffffc020085a:	fc26                	sd	s1,56(sp)
ffffffffc020085c:	f44e                	sd	s3,40(sp)
ffffffffc020085e:	f052                	sd	s4,32(sp)
ffffffffc0200860:	ec56                	sd	s5,24(sp)
ffffffffc0200862:	e85a                	sd	s6,16(sp)
ffffffffc0200864:	e45e                	sd	s7,8(sp)
ffffffffc0200866:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200868:	31278f63          	beq	a5,s2,ffffffffc0200b86 <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020086c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200870:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200872:	8b05                	andi	a4,a4,1
ffffffffc0200874:	30070d63          	beqz	a4,ffffffffc0200b8e <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200878:	4401                	li	s0,0
ffffffffc020087a:	4481                	li	s1,0
ffffffffc020087c:	a031                	j	ffffffffc0200888 <default_check+0x42>
ffffffffc020087e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200882:	8b09                	andi	a4,a4,2
ffffffffc0200884:	30070563          	beqz	a4,ffffffffc0200b8e <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200888:	ff87a703          	lw	a4,-8(a5)
ffffffffc020088c:	679c                	ld	a5,8(a5)
ffffffffc020088e:	2485                	addiw	s1,s1,1
ffffffffc0200890:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200892:	ff2796e3          	bne	a5,s2,ffffffffc020087e <default_check+0x38>
ffffffffc0200896:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200898:	38f000ef          	jal	ra,ffffffffc0201426 <nr_free_pages>
ffffffffc020089c:	75351963          	bne	a0,s3,ffffffffc0200fee <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02008a0:	4505                	li	a0,1
ffffffffc02008a2:	2fb000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc02008a6:	8a2a                	mv	s4,a0
ffffffffc02008a8:	48050363          	beqz	a0,ffffffffc0200d2e <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02008ac:	4505                	li	a0,1
ffffffffc02008ae:	2ef000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc02008b2:	89aa                	mv	s3,a0
ffffffffc02008b4:	74050d63          	beqz	a0,ffffffffc020100e <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02008b8:	4505                	li	a0,1
ffffffffc02008ba:	2e3000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc02008be:	8aaa                	mv	s5,a0
ffffffffc02008c0:	4e050763          	beqz	a0,ffffffffc0200dae <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02008c4:	2f3a0563          	beq	s4,s3,ffffffffc0200bae <default_check+0x368>
ffffffffc02008c8:	2eaa0363          	beq	s4,a0,ffffffffc0200bae <default_check+0x368>
ffffffffc02008cc:	2ea98163          	beq	s3,a0,ffffffffc0200bae <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02008d0:	000a2783          	lw	a5,0(s4)
ffffffffc02008d4:	2e079d63          	bnez	a5,ffffffffc0200bce <default_check+0x388>
ffffffffc02008d8:	0009a783          	lw	a5,0(s3)
ffffffffc02008dc:	2e079963          	bnez	a5,ffffffffc0200bce <default_check+0x388>
ffffffffc02008e0:	411c                	lw	a5,0(a0)
ffffffffc02008e2:	2e079663          	bnez	a5,ffffffffc0200bce <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008e6:	00006797          	auipc	a5,0x6
ffffffffc02008ea:	b8278793          	addi	a5,a5,-1150 # ffffffffc0206468 <pages>
ffffffffc02008ee:	639c                	ld	a5,0(a5)
ffffffffc02008f0:	00002717          	auipc	a4,0x2
ffffffffc02008f4:	a0070713          	addi	a4,a4,-1536 # ffffffffc02022f0 <commands+0x630>
ffffffffc02008f8:	630c                	ld	a1,0(a4)
ffffffffc02008fa:	40fa0733          	sub	a4,s4,a5
ffffffffc02008fe:	870d                	srai	a4,a4,0x3
ffffffffc0200900:	02b70733          	mul	a4,a4,a1
ffffffffc0200904:	00002697          	auipc	a3,0x2
ffffffffc0200908:	15c68693          	addi	a3,a3,348 # ffffffffc0202a60 <nbase>
ffffffffc020090c:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020090e:	00006697          	auipc	a3,0x6
ffffffffc0200912:	b0a68693          	addi	a3,a3,-1270 # ffffffffc0206418 <npage>
ffffffffc0200916:	6294                	ld	a3,0(a3)
ffffffffc0200918:	06b2                	slli	a3,a3,0xc
ffffffffc020091a:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc020091c:	0732                	slli	a4,a4,0xc
ffffffffc020091e:	2cd77863          	bleu	a3,a4,ffffffffc0200bee <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200922:	40f98733          	sub	a4,s3,a5
ffffffffc0200926:	870d                	srai	a4,a4,0x3
ffffffffc0200928:	02b70733          	mul	a4,a4,a1
ffffffffc020092c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020092e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200930:	4ed77f63          	bleu	a3,a4,ffffffffc0200e2e <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200934:	40f507b3          	sub	a5,a0,a5
ffffffffc0200938:	878d                	srai	a5,a5,0x3
ffffffffc020093a:	02b787b3          	mul	a5,a5,a1
ffffffffc020093e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200940:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200942:	34d7f663          	bleu	a3,a5,ffffffffc0200c8e <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200946:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200948:	00093c03          	ld	s8,0(s2)
ffffffffc020094c:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200950:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200954:	00006797          	auipc	a5,0x6
ffffffffc0200958:	af27b623          	sd	s2,-1300(a5) # ffffffffc0206440 <free_area+0x8>
ffffffffc020095c:	00006797          	auipc	a5,0x6
ffffffffc0200960:	ad27be23          	sd	s2,-1316(a5) # ffffffffc0206438 <free_area>
    nr_free = 0;
ffffffffc0200964:	00006797          	auipc	a5,0x6
ffffffffc0200968:	ae07a223          	sw	zero,-1308(a5) # ffffffffc0206448 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020096c:	231000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc0200970:	2e051f63          	bnez	a0,ffffffffc0200c6e <default_check+0x428>
    free_page(p0);
ffffffffc0200974:	4585                	li	a1,1
ffffffffc0200976:	8552                	mv	a0,s4
ffffffffc0200978:	269000ef          	jal	ra,ffffffffc02013e0 <free_pages>
    free_page(p1);
ffffffffc020097c:	4585                	li	a1,1
ffffffffc020097e:	854e                	mv	a0,s3
ffffffffc0200980:	261000ef          	jal	ra,ffffffffc02013e0 <free_pages>
    free_page(p2);
ffffffffc0200984:	4585                	li	a1,1
ffffffffc0200986:	8556                	mv	a0,s5
ffffffffc0200988:	259000ef          	jal	ra,ffffffffc02013e0 <free_pages>
    assert(nr_free == 3);
ffffffffc020098c:	01092703          	lw	a4,16(s2)
ffffffffc0200990:	478d                	li	a5,3
ffffffffc0200992:	2af71e63          	bne	a4,a5,ffffffffc0200c4e <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200996:	4505                	li	a0,1
ffffffffc0200998:	205000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc020099c:	89aa                	mv	s3,a0
ffffffffc020099e:	28050863          	beqz	a0,ffffffffc0200c2e <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02009a2:	4505                	li	a0,1
ffffffffc02009a4:	1f9000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc02009a8:	8aaa                	mv	s5,a0
ffffffffc02009aa:	3e050263          	beqz	a0,ffffffffc0200d8e <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02009ae:	4505                	li	a0,1
ffffffffc02009b0:	1ed000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc02009b4:	8a2a                	mv	s4,a0
ffffffffc02009b6:	3a050c63          	beqz	a0,ffffffffc0200d6e <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc02009ba:	4505                	li	a0,1
ffffffffc02009bc:	1e1000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc02009c0:	38051763          	bnez	a0,ffffffffc0200d4e <default_check+0x508>
    free_page(p0);
ffffffffc02009c4:	4585                	li	a1,1
ffffffffc02009c6:	854e                	mv	a0,s3
ffffffffc02009c8:	219000ef          	jal	ra,ffffffffc02013e0 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02009cc:	00893783          	ld	a5,8(s2)
ffffffffc02009d0:	23278f63          	beq	a5,s2,ffffffffc0200c0e <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc02009d4:	4505                	li	a0,1
ffffffffc02009d6:	1c7000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc02009da:	32a99a63          	bne	s3,a0,ffffffffc0200d0e <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc02009de:	4505                	li	a0,1
ffffffffc02009e0:	1bd000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc02009e4:	30051563          	bnez	a0,ffffffffc0200cee <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc02009e8:	01092783          	lw	a5,16(s2)
ffffffffc02009ec:	2e079163          	bnez	a5,ffffffffc0200cce <default_check+0x488>
    free_page(p);
ffffffffc02009f0:	854e                	mv	a0,s3
ffffffffc02009f2:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02009f4:	00006797          	auipc	a5,0x6
ffffffffc02009f8:	a587b223          	sd	s8,-1468(a5) # ffffffffc0206438 <free_area>
ffffffffc02009fc:	00006797          	auipc	a5,0x6
ffffffffc0200a00:	a577b223          	sd	s7,-1468(a5) # ffffffffc0206440 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200a04:	00006797          	auipc	a5,0x6
ffffffffc0200a08:	a567a223          	sw	s6,-1468(a5) # ffffffffc0206448 <free_area+0x10>
    free_page(p);
ffffffffc0200a0c:	1d5000ef          	jal	ra,ffffffffc02013e0 <free_pages>
    free_page(p1);
ffffffffc0200a10:	4585                	li	a1,1
ffffffffc0200a12:	8556                	mv	a0,s5
ffffffffc0200a14:	1cd000ef          	jal	ra,ffffffffc02013e0 <free_pages>
    free_page(p2);
ffffffffc0200a18:	4585                	li	a1,1
ffffffffc0200a1a:	8552                	mv	a0,s4
ffffffffc0200a1c:	1c5000ef          	jal	ra,ffffffffc02013e0 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200a20:	4515                	li	a0,5
ffffffffc0200a22:	17b000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc0200a26:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200a28:	28050363          	beqz	a0,ffffffffc0200cae <default_check+0x468>
ffffffffc0200a2c:	651c                	ld	a5,8(a0)
ffffffffc0200a2e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200a30:	8b85                	andi	a5,a5,1
ffffffffc0200a32:	54079e63          	bnez	a5,ffffffffc0200f8e <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200a36:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a38:	00093b03          	ld	s6,0(s2)
ffffffffc0200a3c:	00893a83          	ld	s5,8(s2)
ffffffffc0200a40:	00006797          	auipc	a5,0x6
ffffffffc0200a44:	9f27bc23          	sd	s2,-1544(a5) # ffffffffc0206438 <free_area>
ffffffffc0200a48:	00006797          	auipc	a5,0x6
ffffffffc0200a4c:	9f27bc23          	sd	s2,-1544(a5) # ffffffffc0206440 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200a50:	14d000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc0200a54:	50051d63          	bnez	a0,ffffffffc0200f6e <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200a58:	05098a13          	addi	s4,s3,80
ffffffffc0200a5c:	8552                	mv	a0,s4
ffffffffc0200a5e:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200a60:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200a64:	00006797          	auipc	a5,0x6
ffffffffc0200a68:	9e07a223          	sw	zero,-1564(a5) # ffffffffc0206448 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200a6c:	175000ef          	jal	ra,ffffffffc02013e0 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200a70:	4511                	li	a0,4
ffffffffc0200a72:	12b000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc0200a76:	4c051c63          	bnez	a0,ffffffffc0200f4e <default_check+0x708>
ffffffffc0200a7a:	0589b783          	ld	a5,88(s3)
ffffffffc0200a7e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200a80:	8b85                	andi	a5,a5,1
ffffffffc0200a82:	4a078663          	beqz	a5,ffffffffc0200f2e <default_check+0x6e8>
ffffffffc0200a86:	0609a703          	lw	a4,96(s3)
ffffffffc0200a8a:	478d                	li	a5,3
ffffffffc0200a8c:	4af71163          	bne	a4,a5,ffffffffc0200f2e <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200a90:	450d                	li	a0,3
ffffffffc0200a92:	10b000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc0200a96:	8c2a                	mv	s8,a0
ffffffffc0200a98:	46050b63          	beqz	a0,ffffffffc0200f0e <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200a9c:	4505                	li	a0,1
ffffffffc0200a9e:	0ff000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc0200aa2:	44051663          	bnez	a0,ffffffffc0200eee <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200aa6:	438a1463          	bne	s4,s8,ffffffffc0200ece <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200aaa:	4585                	li	a1,1
ffffffffc0200aac:	854e                	mv	a0,s3
ffffffffc0200aae:	133000ef          	jal	ra,ffffffffc02013e0 <free_pages>
    free_pages(p1, 3);
ffffffffc0200ab2:	458d                	li	a1,3
ffffffffc0200ab4:	8552                	mv	a0,s4
ffffffffc0200ab6:	12b000ef          	jal	ra,ffffffffc02013e0 <free_pages>
ffffffffc0200aba:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200abe:	02898c13          	addi	s8,s3,40
ffffffffc0200ac2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200ac4:	8b85                	andi	a5,a5,1
ffffffffc0200ac6:	3e078463          	beqz	a5,ffffffffc0200eae <default_check+0x668>
ffffffffc0200aca:	0109a703          	lw	a4,16(s3)
ffffffffc0200ace:	4785                	li	a5,1
ffffffffc0200ad0:	3cf71f63          	bne	a4,a5,ffffffffc0200eae <default_check+0x668>
ffffffffc0200ad4:	008a3783          	ld	a5,8(s4)
ffffffffc0200ad8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200ada:	8b85                	andi	a5,a5,1
ffffffffc0200adc:	3a078963          	beqz	a5,ffffffffc0200e8e <default_check+0x648>
ffffffffc0200ae0:	010a2703          	lw	a4,16(s4)
ffffffffc0200ae4:	478d                	li	a5,3
ffffffffc0200ae6:	3af71463          	bne	a4,a5,ffffffffc0200e8e <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200aea:	4505                	li	a0,1
ffffffffc0200aec:	0b1000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc0200af0:	36a99f63          	bne	s3,a0,ffffffffc0200e6e <default_check+0x628>
    free_page(p0);
ffffffffc0200af4:	4585                	li	a1,1
ffffffffc0200af6:	0eb000ef          	jal	ra,ffffffffc02013e0 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200afa:	4509                	li	a0,2
ffffffffc0200afc:	0a1000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc0200b00:	34aa1763          	bne	s4,a0,ffffffffc0200e4e <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200b04:	4589                	li	a1,2
ffffffffc0200b06:	0db000ef          	jal	ra,ffffffffc02013e0 <free_pages>
    free_page(p2);
ffffffffc0200b0a:	4585                	li	a1,1
ffffffffc0200b0c:	8562                	mv	a0,s8
ffffffffc0200b0e:	0d3000ef          	jal	ra,ffffffffc02013e0 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b12:	4515                	li	a0,5
ffffffffc0200b14:	089000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc0200b18:	89aa                	mv	s3,a0
ffffffffc0200b1a:	48050a63          	beqz	a0,ffffffffc0200fae <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200b1e:	4505                	li	a0,1
ffffffffc0200b20:	07d000ef          	jal	ra,ffffffffc020139c <alloc_pages>
ffffffffc0200b24:	2e051563          	bnez	a0,ffffffffc0200e0e <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200b28:	01092783          	lw	a5,16(s2)
ffffffffc0200b2c:	2c079163          	bnez	a5,ffffffffc0200dee <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200b30:	4595                	li	a1,5
ffffffffc0200b32:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200b34:	00006797          	auipc	a5,0x6
ffffffffc0200b38:	9177aa23          	sw	s7,-1772(a5) # ffffffffc0206448 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200b3c:	00006797          	auipc	a5,0x6
ffffffffc0200b40:	8f67be23          	sd	s6,-1796(a5) # ffffffffc0206438 <free_area>
ffffffffc0200b44:	00006797          	auipc	a5,0x6
ffffffffc0200b48:	8f57be23          	sd	s5,-1796(a5) # ffffffffc0206440 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200b4c:	095000ef          	jal	ra,ffffffffc02013e0 <free_pages>
    return listelm->next;
ffffffffc0200b50:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b54:	01278963          	beq	a5,s2,ffffffffc0200b66 <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200b58:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b5c:	679c                	ld	a5,8(a5)
ffffffffc0200b5e:	34fd                	addiw	s1,s1,-1
ffffffffc0200b60:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b62:	ff279be3          	bne	a5,s2,ffffffffc0200b58 <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200b66:	26049463          	bnez	s1,ffffffffc0200dce <default_check+0x588>
    assert(total == 0);
ffffffffc0200b6a:	46041263          	bnez	s0,ffffffffc0200fce <default_check+0x788>
}
ffffffffc0200b6e:	60a6                	ld	ra,72(sp)
ffffffffc0200b70:	6406                	ld	s0,64(sp)
ffffffffc0200b72:	74e2                	ld	s1,56(sp)
ffffffffc0200b74:	7942                	ld	s2,48(sp)
ffffffffc0200b76:	79a2                	ld	s3,40(sp)
ffffffffc0200b78:	7a02                	ld	s4,32(sp)
ffffffffc0200b7a:	6ae2                	ld	s5,24(sp)
ffffffffc0200b7c:	6b42                	ld	s6,16(sp)
ffffffffc0200b7e:	6ba2                	ld	s7,8(sp)
ffffffffc0200b80:	6c02                	ld	s8,0(sp)
ffffffffc0200b82:	6161                	addi	sp,sp,80
ffffffffc0200b84:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b86:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200b88:	4401                	li	s0,0
ffffffffc0200b8a:	4481                	li	s1,0
ffffffffc0200b8c:	b331                	j	ffffffffc0200898 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200b8e:	00001697          	auipc	a3,0x1
ffffffffc0200b92:	76a68693          	addi	a3,a3,1898 # ffffffffc02022f8 <commands+0x638>
ffffffffc0200b96:	00001617          	auipc	a2,0x1
ffffffffc0200b9a:	77260613          	addi	a2,a2,1906 # ffffffffc0202308 <commands+0x648>
ffffffffc0200b9e:	0ef00593          	li	a1,239
ffffffffc0200ba2:	00001517          	auipc	a0,0x1
ffffffffc0200ba6:	77e50513          	addi	a0,a0,1918 # ffffffffc0202320 <commands+0x660>
ffffffffc0200baa:	803ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bae:	00002697          	auipc	a3,0x2
ffffffffc0200bb2:	80a68693          	addi	a3,a3,-2038 # ffffffffc02023b8 <commands+0x6f8>
ffffffffc0200bb6:	00001617          	auipc	a2,0x1
ffffffffc0200bba:	75260613          	addi	a2,a2,1874 # ffffffffc0202308 <commands+0x648>
ffffffffc0200bbe:	0bc00593          	li	a1,188
ffffffffc0200bc2:	00001517          	auipc	a0,0x1
ffffffffc0200bc6:	75e50513          	addi	a0,a0,1886 # ffffffffc0202320 <commands+0x660>
ffffffffc0200bca:	fe2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bce:	00002697          	auipc	a3,0x2
ffffffffc0200bd2:	81268693          	addi	a3,a3,-2030 # ffffffffc02023e0 <commands+0x720>
ffffffffc0200bd6:	00001617          	auipc	a2,0x1
ffffffffc0200bda:	73260613          	addi	a2,a2,1842 # ffffffffc0202308 <commands+0x648>
ffffffffc0200bde:	0bd00593          	li	a1,189
ffffffffc0200be2:	00001517          	auipc	a0,0x1
ffffffffc0200be6:	73e50513          	addi	a0,a0,1854 # ffffffffc0202320 <commands+0x660>
ffffffffc0200bea:	fc2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bee:	00002697          	auipc	a3,0x2
ffffffffc0200bf2:	83268693          	addi	a3,a3,-1998 # ffffffffc0202420 <commands+0x760>
ffffffffc0200bf6:	00001617          	auipc	a2,0x1
ffffffffc0200bfa:	71260613          	addi	a2,a2,1810 # ffffffffc0202308 <commands+0x648>
ffffffffc0200bfe:	0bf00593          	li	a1,191
ffffffffc0200c02:	00001517          	auipc	a0,0x1
ffffffffc0200c06:	71e50513          	addi	a0,a0,1822 # ffffffffc0202320 <commands+0x660>
ffffffffc0200c0a:	fa2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c0e:	00002697          	auipc	a3,0x2
ffffffffc0200c12:	89a68693          	addi	a3,a3,-1894 # ffffffffc02024a8 <commands+0x7e8>
ffffffffc0200c16:	00001617          	auipc	a2,0x1
ffffffffc0200c1a:	6f260613          	addi	a2,a2,1778 # ffffffffc0202308 <commands+0x648>
ffffffffc0200c1e:	0d800593          	li	a1,216
ffffffffc0200c22:	00001517          	auipc	a0,0x1
ffffffffc0200c26:	6fe50513          	addi	a0,a0,1790 # ffffffffc0202320 <commands+0x660>
ffffffffc0200c2a:	f82ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c2e:	00001697          	auipc	a3,0x1
ffffffffc0200c32:	72a68693          	addi	a3,a3,1834 # ffffffffc0202358 <commands+0x698>
ffffffffc0200c36:	00001617          	auipc	a2,0x1
ffffffffc0200c3a:	6d260613          	addi	a2,a2,1746 # ffffffffc0202308 <commands+0x648>
ffffffffc0200c3e:	0d100593          	li	a1,209
ffffffffc0200c42:	00001517          	auipc	a0,0x1
ffffffffc0200c46:	6de50513          	addi	a0,a0,1758 # ffffffffc0202320 <commands+0x660>
ffffffffc0200c4a:	f62ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200c4e:	00002697          	auipc	a3,0x2
ffffffffc0200c52:	84a68693          	addi	a3,a3,-1974 # ffffffffc0202498 <commands+0x7d8>
ffffffffc0200c56:	00001617          	auipc	a2,0x1
ffffffffc0200c5a:	6b260613          	addi	a2,a2,1714 # ffffffffc0202308 <commands+0x648>
ffffffffc0200c5e:	0cf00593          	li	a1,207
ffffffffc0200c62:	00001517          	auipc	a0,0x1
ffffffffc0200c66:	6be50513          	addi	a0,a0,1726 # ffffffffc0202320 <commands+0x660>
ffffffffc0200c6a:	f42ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c6e:	00002697          	auipc	a3,0x2
ffffffffc0200c72:	81268693          	addi	a3,a3,-2030 # ffffffffc0202480 <commands+0x7c0>
ffffffffc0200c76:	00001617          	auipc	a2,0x1
ffffffffc0200c7a:	69260613          	addi	a2,a2,1682 # ffffffffc0202308 <commands+0x648>
ffffffffc0200c7e:	0ca00593          	li	a1,202
ffffffffc0200c82:	00001517          	auipc	a0,0x1
ffffffffc0200c86:	69e50513          	addi	a0,a0,1694 # ffffffffc0202320 <commands+0x660>
ffffffffc0200c8a:	f22ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c8e:	00001697          	auipc	a3,0x1
ffffffffc0200c92:	7d268693          	addi	a3,a3,2002 # ffffffffc0202460 <commands+0x7a0>
ffffffffc0200c96:	00001617          	auipc	a2,0x1
ffffffffc0200c9a:	67260613          	addi	a2,a2,1650 # ffffffffc0202308 <commands+0x648>
ffffffffc0200c9e:	0c100593          	li	a1,193
ffffffffc0200ca2:	00001517          	auipc	a0,0x1
ffffffffc0200ca6:	67e50513          	addi	a0,a0,1662 # ffffffffc0202320 <commands+0x660>
ffffffffc0200caa:	f02ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200cae:	00002697          	auipc	a3,0x2
ffffffffc0200cb2:	84268693          	addi	a3,a3,-1982 # ffffffffc02024f0 <commands+0x830>
ffffffffc0200cb6:	00001617          	auipc	a2,0x1
ffffffffc0200cba:	65260613          	addi	a2,a2,1618 # ffffffffc0202308 <commands+0x648>
ffffffffc0200cbe:	0f700593          	li	a1,247
ffffffffc0200cc2:	00001517          	auipc	a0,0x1
ffffffffc0200cc6:	65e50513          	addi	a0,a0,1630 # ffffffffc0202320 <commands+0x660>
ffffffffc0200cca:	ee2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200cce:	00002697          	auipc	a3,0x2
ffffffffc0200cd2:	81268693          	addi	a3,a3,-2030 # ffffffffc02024e0 <commands+0x820>
ffffffffc0200cd6:	00001617          	auipc	a2,0x1
ffffffffc0200cda:	63260613          	addi	a2,a2,1586 # ffffffffc0202308 <commands+0x648>
ffffffffc0200cde:	0de00593          	li	a1,222
ffffffffc0200ce2:	00001517          	auipc	a0,0x1
ffffffffc0200ce6:	63e50513          	addi	a0,a0,1598 # ffffffffc0202320 <commands+0x660>
ffffffffc0200cea:	ec2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200cee:	00001697          	auipc	a3,0x1
ffffffffc0200cf2:	79268693          	addi	a3,a3,1938 # ffffffffc0202480 <commands+0x7c0>
ffffffffc0200cf6:	00001617          	auipc	a2,0x1
ffffffffc0200cfa:	61260613          	addi	a2,a2,1554 # ffffffffc0202308 <commands+0x648>
ffffffffc0200cfe:	0dc00593          	li	a1,220
ffffffffc0200d02:	00001517          	auipc	a0,0x1
ffffffffc0200d06:	61e50513          	addi	a0,a0,1566 # ffffffffc0202320 <commands+0x660>
ffffffffc0200d0a:	ea2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200d0e:	00001697          	auipc	a3,0x1
ffffffffc0200d12:	7b268693          	addi	a3,a3,1970 # ffffffffc02024c0 <commands+0x800>
ffffffffc0200d16:	00001617          	auipc	a2,0x1
ffffffffc0200d1a:	5f260613          	addi	a2,a2,1522 # ffffffffc0202308 <commands+0x648>
ffffffffc0200d1e:	0db00593          	li	a1,219
ffffffffc0200d22:	00001517          	auipc	a0,0x1
ffffffffc0200d26:	5fe50513          	addi	a0,a0,1534 # ffffffffc0202320 <commands+0x660>
ffffffffc0200d2a:	e82ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d2e:	00001697          	auipc	a3,0x1
ffffffffc0200d32:	62a68693          	addi	a3,a3,1578 # ffffffffc0202358 <commands+0x698>
ffffffffc0200d36:	00001617          	auipc	a2,0x1
ffffffffc0200d3a:	5d260613          	addi	a2,a2,1490 # ffffffffc0202308 <commands+0x648>
ffffffffc0200d3e:	0b800593          	li	a1,184
ffffffffc0200d42:	00001517          	auipc	a0,0x1
ffffffffc0200d46:	5de50513          	addi	a0,a0,1502 # ffffffffc0202320 <commands+0x660>
ffffffffc0200d4a:	e62ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d4e:	00001697          	auipc	a3,0x1
ffffffffc0200d52:	73268693          	addi	a3,a3,1842 # ffffffffc0202480 <commands+0x7c0>
ffffffffc0200d56:	00001617          	auipc	a2,0x1
ffffffffc0200d5a:	5b260613          	addi	a2,a2,1458 # ffffffffc0202308 <commands+0x648>
ffffffffc0200d5e:	0d500593          	li	a1,213
ffffffffc0200d62:	00001517          	auipc	a0,0x1
ffffffffc0200d66:	5be50513          	addi	a0,a0,1470 # ffffffffc0202320 <commands+0x660>
ffffffffc0200d6a:	e42ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d6e:	00001697          	auipc	a3,0x1
ffffffffc0200d72:	62a68693          	addi	a3,a3,1578 # ffffffffc0202398 <commands+0x6d8>
ffffffffc0200d76:	00001617          	auipc	a2,0x1
ffffffffc0200d7a:	59260613          	addi	a2,a2,1426 # ffffffffc0202308 <commands+0x648>
ffffffffc0200d7e:	0d300593          	li	a1,211
ffffffffc0200d82:	00001517          	auipc	a0,0x1
ffffffffc0200d86:	59e50513          	addi	a0,a0,1438 # ffffffffc0202320 <commands+0x660>
ffffffffc0200d8a:	e22ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d8e:	00001697          	auipc	a3,0x1
ffffffffc0200d92:	5ea68693          	addi	a3,a3,1514 # ffffffffc0202378 <commands+0x6b8>
ffffffffc0200d96:	00001617          	auipc	a2,0x1
ffffffffc0200d9a:	57260613          	addi	a2,a2,1394 # ffffffffc0202308 <commands+0x648>
ffffffffc0200d9e:	0d200593          	li	a1,210
ffffffffc0200da2:	00001517          	auipc	a0,0x1
ffffffffc0200da6:	57e50513          	addi	a0,a0,1406 # ffffffffc0202320 <commands+0x660>
ffffffffc0200daa:	e02ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200dae:	00001697          	auipc	a3,0x1
ffffffffc0200db2:	5ea68693          	addi	a3,a3,1514 # ffffffffc0202398 <commands+0x6d8>
ffffffffc0200db6:	00001617          	auipc	a2,0x1
ffffffffc0200dba:	55260613          	addi	a2,a2,1362 # ffffffffc0202308 <commands+0x648>
ffffffffc0200dbe:	0ba00593          	li	a1,186
ffffffffc0200dc2:	00001517          	auipc	a0,0x1
ffffffffc0200dc6:	55e50513          	addi	a0,a0,1374 # ffffffffc0202320 <commands+0x660>
ffffffffc0200dca:	de2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200dce:	00002697          	auipc	a3,0x2
ffffffffc0200dd2:	87268693          	addi	a3,a3,-1934 # ffffffffc0202640 <commands+0x980>
ffffffffc0200dd6:	00001617          	auipc	a2,0x1
ffffffffc0200dda:	53260613          	addi	a2,a2,1330 # ffffffffc0202308 <commands+0x648>
ffffffffc0200dde:	12400593          	li	a1,292
ffffffffc0200de2:	00001517          	auipc	a0,0x1
ffffffffc0200de6:	53e50513          	addi	a0,a0,1342 # ffffffffc0202320 <commands+0x660>
ffffffffc0200dea:	dc2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200dee:	00001697          	auipc	a3,0x1
ffffffffc0200df2:	6f268693          	addi	a3,a3,1778 # ffffffffc02024e0 <commands+0x820>
ffffffffc0200df6:	00001617          	auipc	a2,0x1
ffffffffc0200dfa:	51260613          	addi	a2,a2,1298 # ffffffffc0202308 <commands+0x648>
ffffffffc0200dfe:	11900593          	li	a1,281
ffffffffc0200e02:	00001517          	auipc	a0,0x1
ffffffffc0200e06:	51e50513          	addi	a0,a0,1310 # ffffffffc0202320 <commands+0x660>
ffffffffc0200e0a:	da2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e0e:	00001697          	auipc	a3,0x1
ffffffffc0200e12:	67268693          	addi	a3,a3,1650 # ffffffffc0202480 <commands+0x7c0>
ffffffffc0200e16:	00001617          	auipc	a2,0x1
ffffffffc0200e1a:	4f260613          	addi	a2,a2,1266 # ffffffffc0202308 <commands+0x648>
ffffffffc0200e1e:	11700593          	li	a1,279
ffffffffc0200e22:	00001517          	auipc	a0,0x1
ffffffffc0200e26:	4fe50513          	addi	a0,a0,1278 # ffffffffc0202320 <commands+0x660>
ffffffffc0200e2a:	d82ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e2e:	00001697          	auipc	a3,0x1
ffffffffc0200e32:	61268693          	addi	a3,a3,1554 # ffffffffc0202440 <commands+0x780>
ffffffffc0200e36:	00001617          	auipc	a2,0x1
ffffffffc0200e3a:	4d260613          	addi	a2,a2,1234 # ffffffffc0202308 <commands+0x648>
ffffffffc0200e3e:	0c000593          	li	a1,192
ffffffffc0200e42:	00001517          	auipc	a0,0x1
ffffffffc0200e46:	4de50513          	addi	a0,a0,1246 # ffffffffc0202320 <commands+0x660>
ffffffffc0200e4a:	d62ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e4e:	00001697          	auipc	a3,0x1
ffffffffc0200e52:	7b268693          	addi	a3,a3,1970 # ffffffffc0202600 <commands+0x940>
ffffffffc0200e56:	00001617          	auipc	a2,0x1
ffffffffc0200e5a:	4b260613          	addi	a2,a2,1202 # ffffffffc0202308 <commands+0x648>
ffffffffc0200e5e:	11100593          	li	a1,273
ffffffffc0200e62:	00001517          	auipc	a0,0x1
ffffffffc0200e66:	4be50513          	addi	a0,a0,1214 # ffffffffc0202320 <commands+0x660>
ffffffffc0200e6a:	d42ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200e6e:	00001697          	auipc	a3,0x1
ffffffffc0200e72:	77268693          	addi	a3,a3,1906 # ffffffffc02025e0 <commands+0x920>
ffffffffc0200e76:	00001617          	auipc	a2,0x1
ffffffffc0200e7a:	49260613          	addi	a2,a2,1170 # ffffffffc0202308 <commands+0x648>
ffffffffc0200e7e:	10f00593          	li	a1,271
ffffffffc0200e82:	00001517          	auipc	a0,0x1
ffffffffc0200e86:	49e50513          	addi	a0,a0,1182 # ffffffffc0202320 <commands+0x660>
ffffffffc0200e8a:	d22ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200e8e:	00001697          	auipc	a3,0x1
ffffffffc0200e92:	72a68693          	addi	a3,a3,1834 # ffffffffc02025b8 <commands+0x8f8>
ffffffffc0200e96:	00001617          	auipc	a2,0x1
ffffffffc0200e9a:	47260613          	addi	a2,a2,1138 # ffffffffc0202308 <commands+0x648>
ffffffffc0200e9e:	10d00593          	li	a1,269
ffffffffc0200ea2:	00001517          	auipc	a0,0x1
ffffffffc0200ea6:	47e50513          	addi	a0,a0,1150 # ffffffffc0202320 <commands+0x660>
ffffffffc0200eaa:	d02ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200eae:	00001697          	auipc	a3,0x1
ffffffffc0200eb2:	6e268693          	addi	a3,a3,1762 # ffffffffc0202590 <commands+0x8d0>
ffffffffc0200eb6:	00001617          	auipc	a2,0x1
ffffffffc0200eba:	45260613          	addi	a2,a2,1106 # ffffffffc0202308 <commands+0x648>
ffffffffc0200ebe:	10c00593          	li	a1,268
ffffffffc0200ec2:	00001517          	auipc	a0,0x1
ffffffffc0200ec6:	45e50513          	addi	a0,a0,1118 # ffffffffc0202320 <commands+0x660>
ffffffffc0200eca:	ce2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 2 == p1);
ffffffffc0200ece:	00001697          	auipc	a3,0x1
ffffffffc0200ed2:	6b268693          	addi	a3,a3,1714 # ffffffffc0202580 <commands+0x8c0>
ffffffffc0200ed6:	00001617          	auipc	a2,0x1
ffffffffc0200eda:	43260613          	addi	a2,a2,1074 # ffffffffc0202308 <commands+0x648>
ffffffffc0200ede:	10700593          	li	a1,263
ffffffffc0200ee2:	00001517          	auipc	a0,0x1
ffffffffc0200ee6:	43e50513          	addi	a0,a0,1086 # ffffffffc0202320 <commands+0x660>
ffffffffc0200eea:	cc2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200eee:	00001697          	auipc	a3,0x1
ffffffffc0200ef2:	59268693          	addi	a3,a3,1426 # ffffffffc0202480 <commands+0x7c0>
ffffffffc0200ef6:	00001617          	auipc	a2,0x1
ffffffffc0200efa:	41260613          	addi	a2,a2,1042 # ffffffffc0202308 <commands+0x648>
ffffffffc0200efe:	10600593          	li	a1,262
ffffffffc0200f02:	00001517          	auipc	a0,0x1
ffffffffc0200f06:	41e50513          	addi	a0,a0,1054 # ffffffffc0202320 <commands+0x660>
ffffffffc0200f0a:	ca2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200f0e:	00001697          	auipc	a3,0x1
ffffffffc0200f12:	65268693          	addi	a3,a3,1618 # ffffffffc0202560 <commands+0x8a0>
ffffffffc0200f16:	00001617          	auipc	a2,0x1
ffffffffc0200f1a:	3f260613          	addi	a2,a2,1010 # ffffffffc0202308 <commands+0x648>
ffffffffc0200f1e:	10500593          	li	a1,261
ffffffffc0200f22:	00001517          	auipc	a0,0x1
ffffffffc0200f26:	3fe50513          	addi	a0,a0,1022 # ffffffffc0202320 <commands+0x660>
ffffffffc0200f2a:	c82ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200f2e:	00001697          	auipc	a3,0x1
ffffffffc0200f32:	60268693          	addi	a3,a3,1538 # ffffffffc0202530 <commands+0x870>
ffffffffc0200f36:	00001617          	auipc	a2,0x1
ffffffffc0200f3a:	3d260613          	addi	a2,a2,978 # ffffffffc0202308 <commands+0x648>
ffffffffc0200f3e:	10400593          	li	a1,260
ffffffffc0200f42:	00001517          	auipc	a0,0x1
ffffffffc0200f46:	3de50513          	addi	a0,a0,990 # ffffffffc0202320 <commands+0x660>
ffffffffc0200f4a:	c62ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f4e:	00001697          	auipc	a3,0x1
ffffffffc0200f52:	5ca68693          	addi	a3,a3,1482 # ffffffffc0202518 <commands+0x858>
ffffffffc0200f56:	00001617          	auipc	a2,0x1
ffffffffc0200f5a:	3b260613          	addi	a2,a2,946 # ffffffffc0202308 <commands+0x648>
ffffffffc0200f5e:	10300593          	li	a1,259
ffffffffc0200f62:	00001517          	auipc	a0,0x1
ffffffffc0200f66:	3be50513          	addi	a0,a0,958 # ffffffffc0202320 <commands+0x660>
ffffffffc0200f6a:	c42ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f6e:	00001697          	auipc	a3,0x1
ffffffffc0200f72:	51268693          	addi	a3,a3,1298 # ffffffffc0202480 <commands+0x7c0>
ffffffffc0200f76:	00001617          	auipc	a2,0x1
ffffffffc0200f7a:	39260613          	addi	a2,a2,914 # ffffffffc0202308 <commands+0x648>
ffffffffc0200f7e:	0fd00593          	li	a1,253
ffffffffc0200f82:	00001517          	auipc	a0,0x1
ffffffffc0200f86:	39e50513          	addi	a0,a0,926 # ffffffffc0202320 <commands+0x660>
ffffffffc0200f8a:	c22ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f8e:	00001697          	auipc	a3,0x1
ffffffffc0200f92:	57268693          	addi	a3,a3,1394 # ffffffffc0202500 <commands+0x840>
ffffffffc0200f96:	00001617          	auipc	a2,0x1
ffffffffc0200f9a:	37260613          	addi	a2,a2,882 # ffffffffc0202308 <commands+0x648>
ffffffffc0200f9e:	0f800593          	li	a1,248
ffffffffc0200fa2:	00001517          	auipc	a0,0x1
ffffffffc0200fa6:	37e50513          	addi	a0,a0,894 # ffffffffc0202320 <commands+0x660>
ffffffffc0200faa:	c02ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200fae:	00001697          	auipc	a3,0x1
ffffffffc0200fb2:	67268693          	addi	a3,a3,1650 # ffffffffc0202620 <commands+0x960>
ffffffffc0200fb6:	00001617          	auipc	a2,0x1
ffffffffc0200fba:	35260613          	addi	a2,a2,850 # ffffffffc0202308 <commands+0x648>
ffffffffc0200fbe:	11600593          	li	a1,278
ffffffffc0200fc2:	00001517          	auipc	a0,0x1
ffffffffc0200fc6:	35e50513          	addi	a0,a0,862 # ffffffffc0202320 <commands+0x660>
ffffffffc0200fca:	be2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200fce:	00001697          	auipc	a3,0x1
ffffffffc0200fd2:	68268693          	addi	a3,a3,1666 # ffffffffc0202650 <commands+0x990>
ffffffffc0200fd6:	00001617          	auipc	a2,0x1
ffffffffc0200fda:	33260613          	addi	a2,a2,818 # ffffffffc0202308 <commands+0x648>
ffffffffc0200fde:	12500593          	li	a1,293
ffffffffc0200fe2:	00001517          	auipc	a0,0x1
ffffffffc0200fe6:	33e50513          	addi	a0,a0,830 # ffffffffc0202320 <commands+0x660>
ffffffffc0200fea:	bc2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200fee:	00001697          	auipc	a3,0x1
ffffffffc0200ff2:	34a68693          	addi	a3,a3,842 # ffffffffc0202338 <commands+0x678>
ffffffffc0200ff6:	00001617          	auipc	a2,0x1
ffffffffc0200ffa:	31260613          	addi	a2,a2,786 # ffffffffc0202308 <commands+0x648>
ffffffffc0200ffe:	0f200593          	li	a1,242
ffffffffc0201002:	00001517          	auipc	a0,0x1
ffffffffc0201006:	31e50513          	addi	a0,a0,798 # ffffffffc0202320 <commands+0x660>
ffffffffc020100a:	ba2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020100e:	00001697          	auipc	a3,0x1
ffffffffc0201012:	36a68693          	addi	a3,a3,874 # ffffffffc0202378 <commands+0x6b8>
ffffffffc0201016:	00001617          	auipc	a2,0x1
ffffffffc020101a:	2f260613          	addi	a2,a2,754 # ffffffffc0202308 <commands+0x648>
ffffffffc020101e:	0b900593          	li	a1,185
ffffffffc0201022:	00001517          	auipc	a0,0x1
ffffffffc0201026:	2fe50513          	addi	a0,a0,766 # ffffffffc0202320 <commands+0x660>
ffffffffc020102a:	b82ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020102e <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020102e:	1141                	addi	sp,sp,-16
ffffffffc0201030:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201032:	18058063          	beqz	a1,ffffffffc02011b2 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0201036:	00259693          	slli	a3,a1,0x2
ffffffffc020103a:	96ae                	add	a3,a3,a1
ffffffffc020103c:	068e                	slli	a3,a3,0x3
ffffffffc020103e:	96aa                	add	a3,a3,a0
ffffffffc0201040:	02d50d63          	beq	a0,a3,ffffffffc020107a <default_free_pages+0x4c>
ffffffffc0201044:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201046:	8b85                	andi	a5,a5,1
ffffffffc0201048:	14079563          	bnez	a5,ffffffffc0201192 <default_free_pages+0x164>
ffffffffc020104c:	651c                	ld	a5,8(a0)
ffffffffc020104e:	8385                	srli	a5,a5,0x1
ffffffffc0201050:	8b85                	andi	a5,a5,1
ffffffffc0201052:	14079063          	bnez	a5,ffffffffc0201192 <default_free_pages+0x164>
ffffffffc0201056:	87aa                	mv	a5,a0
ffffffffc0201058:	a809                	j	ffffffffc020106a <default_free_pages+0x3c>
ffffffffc020105a:	6798                	ld	a4,8(a5)
ffffffffc020105c:	8b05                	andi	a4,a4,1
ffffffffc020105e:	12071a63          	bnez	a4,ffffffffc0201192 <default_free_pages+0x164>
ffffffffc0201062:	6798                	ld	a4,8(a5)
ffffffffc0201064:	8b09                	andi	a4,a4,2
ffffffffc0201066:	12071663          	bnez	a4,ffffffffc0201192 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc020106a:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020106e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201072:	02878793          	addi	a5,a5,40
ffffffffc0201076:	fed792e3          	bne	a5,a3,ffffffffc020105a <default_free_pages+0x2c>
    base->property = n;
ffffffffc020107a:	2581                	sext.w	a1,a1
ffffffffc020107c:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020107e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201082:	4789                	li	a5,2
ffffffffc0201084:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201088:	00005697          	auipc	a3,0x5
ffffffffc020108c:	3b068693          	addi	a3,a3,944 # ffffffffc0206438 <free_area>
ffffffffc0201090:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201092:	669c                	ld	a5,8(a3)
ffffffffc0201094:	9db9                	addw	a1,a1,a4
ffffffffc0201096:	00005717          	auipc	a4,0x5
ffffffffc020109a:	3ab72923          	sw	a1,946(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020109e:	08d78f63          	beq	a5,a3,ffffffffc020113c <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc02010a2:	fe878713          	addi	a4,a5,-24
ffffffffc02010a6:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02010a8:	4801                	li	a6,0
ffffffffc02010aa:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02010ae:	00e56a63          	bltu	a0,a4,ffffffffc02010c2 <default_free_pages+0x94>
    return listelm->next;
ffffffffc02010b2:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02010b4:	02d70563          	beq	a4,a3,ffffffffc02010de <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010b8:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02010ba:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02010be:	fee57ae3          	bleu	a4,a0,ffffffffc02010b2 <default_free_pages+0x84>
ffffffffc02010c2:	00080663          	beqz	a6,ffffffffc02010ce <default_free_pages+0xa0>
ffffffffc02010c6:	00005817          	auipc	a6,0x5
ffffffffc02010ca:	36b83923          	sd	a1,882(a6) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010ce:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02010d0:	e390                	sd	a2,0(a5)
ffffffffc02010d2:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02010d4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010d6:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02010d8:	02d59163          	bne	a1,a3,ffffffffc02010fa <default_free_pages+0xcc>
ffffffffc02010dc:	a091                	j	ffffffffc0201120 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02010de:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010e0:	f114                	sd	a3,32(a0)
ffffffffc02010e2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02010e4:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02010e6:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010e8:	00d70563          	beq	a4,a3,ffffffffc02010f2 <default_free_pages+0xc4>
ffffffffc02010ec:	4805                	li	a6,1
ffffffffc02010ee:	87ba                	mv	a5,a4
ffffffffc02010f0:	b7e9                	j	ffffffffc02010ba <default_free_pages+0x8c>
ffffffffc02010f2:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02010f4:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02010f6:	02d78163          	beq	a5,a3,ffffffffc0201118 <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02010fa:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02010fe:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base) {
ffffffffc0201102:	02081713          	slli	a4,a6,0x20
ffffffffc0201106:	9301                	srli	a4,a4,0x20
ffffffffc0201108:	00271793          	slli	a5,a4,0x2
ffffffffc020110c:	97ba                	add	a5,a5,a4
ffffffffc020110e:	078e                	slli	a5,a5,0x3
ffffffffc0201110:	97b2                	add	a5,a5,a2
ffffffffc0201112:	02f50e63          	beq	a0,a5,ffffffffc020114e <default_free_pages+0x120>
ffffffffc0201116:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201118:	fe878713          	addi	a4,a5,-24
ffffffffc020111c:	00d78d63          	beq	a5,a3,ffffffffc0201136 <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0201120:	490c                	lw	a1,16(a0)
ffffffffc0201122:	02059613          	slli	a2,a1,0x20
ffffffffc0201126:	9201                	srli	a2,a2,0x20
ffffffffc0201128:	00261693          	slli	a3,a2,0x2
ffffffffc020112c:	96b2                	add	a3,a3,a2
ffffffffc020112e:	068e                	slli	a3,a3,0x3
ffffffffc0201130:	96aa                	add	a3,a3,a0
ffffffffc0201132:	04d70063          	beq	a4,a3,ffffffffc0201172 <default_free_pages+0x144>
}
ffffffffc0201136:	60a2                	ld	ra,8(sp)
ffffffffc0201138:	0141                	addi	sp,sp,16
ffffffffc020113a:	8082                	ret
ffffffffc020113c:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020113e:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201142:	e398                	sd	a4,0(a5)
ffffffffc0201144:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201146:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201148:	ed1c                	sd	a5,24(a0)
}
ffffffffc020114a:	0141                	addi	sp,sp,16
ffffffffc020114c:	8082                	ret
            p->property += base->property;
ffffffffc020114e:	491c                	lw	a5,16(a0)
ffffffffc0201150:	0107883b          	addw	a6,a5,a6
ffffffffc0201154:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201158:	57f5                	li	a5,-3
ffffffffc020115a:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020115e:	01853803          	ld	a6,24(a0)
ffffffffc0201162:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc0201164:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201166:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020116a:	659c                	ld	a5,8(a1)
ffffffffc020116c:	01073023          	sd	a6,0(a4)
ffffffffc0201170:	b765                	j	ffffffffc0201118 <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0201172:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201176:	ff078693          	addi	a3,a5,-16
ffffffffc020117a:	9db9                	addw	a1,a1,a4
ffffffffc020117c:	c90c                	sw	a1,16(a0)
ffffffffc020117e:	5775                	li	a4,-3
ffffffffc0201180:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201184:	6398                	ld	a4,0(a5)
ffffffffc0201186:	679c                	ld	a5,8(a5)
}
ffffffffc0201188:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020118a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020118c:	e398                	sd	a4,0(a5)
ffffffffc020118e:	0141                	addi	sp,sp,16
ffffffffc0201190:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201192:	00001697          	auipc	a3,0x1
ffffffffc0201196:	4ce68693          	addi	a3,a3,1230 # ffffffffc0202660 <commands+0x9a0>
ffffffffc020119a:	00001617          	auipc	a2,0x1
ffffffffc020119e:	16e60613          	addi	a2,a2,366 # ffffffffc0202308 <commands+0x648>
ffffffffc02011a2:	08200593          	li	a1,130
ffffffffc02011a6:	00001517          	auipc	a0,0x1
ffffffffc02011aa:	17a50513          	addi	a0,a0,378 # ffffffffc0202320 <commands+0x660>
ffffffffc02011ae:	9feff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02011b2:	00001697          	auipc	a3,0x1
ffffffffc02011b6:	4d668693          	addi	a3,a3,1238 # ffffffffc0202688 <commands+0x9c8>
ffffffffc02011ba:	00001617          	auipc	a2,0x1
ffffffffc02011be:	14e60613          	addi	a2,a2,334 # ffffffffc0202308 <commands+0x648>
ffffffffc02011c2:	07f00593          	li	a1,127
ffffffffc02011c6:	00001517          	auipc	a0,0x1
ffffffffc02011ca:	15a50513          	addi	a0,a0,346 # ffffffffc0202320 <commands+0x660>
ffffffffc02011ce:	9deff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011d2 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02011d2:	cd51                	beqz	a0,ffffffffc020126e <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc02011d4:	00005597          	auipc	a1,0x5
ffffffffc02011d8:	26458593          	addi	a1,a1,612 # ffffffffc0206438 <free_area>
ffffffffc02011dc:	0105a803          	lw	a6,16(a1)
ffffffffc02011e0:	862a                	mv	a2,a0
ffffffffc02011e2:	02081793          	slli	a5,a6,0x20
ffffffffc02011e6:	9381                	srli	a5,a5,0x20
ffffffffc02011e8:	00a7ee63          	bltu	a5,a0,ffffffffc0201204 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02011ec:	87ae                	mv	a5,a1
ffffffffc02011ee:	a801                	j	ffffffffc02011fe <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02011f0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02011f4:	02071693          	slli	a3,a4,0x20
ffffffffc02011f8:	9281                	srli	a3,a3,0x20
ffffffffc02011fa:	00c6f763          	bleu	a2,a3,ffffffffc0201208 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02011fe:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201200:	feb798e3          	bne	a5,a1,ffffffffc02011f0 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201204:	4501                	li	a0,0
}
ffffffffc0201206:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0201208:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc020120c:	dd6d                	beqz	a0,ffffffffc0201206 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc020120e:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201212:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201216:	00060e1b          	sext.w	t3,a2
ffffffffc020121a:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020121e:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201222:	02d67b63          	bleu	a3,a2,ffffffffc0201258 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc0201226:	00261693          	slli	a3,a2,0x2
ffffffffc020122a:	96b2                	add	a3,a3,a2
ffffffffc020122c:	068e                	slli	a3,a3,0x3
ffffffffc020122e:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201230:	41c7073b          	subw	a4,a4,t3
ffffffffc0201234:	ca98                	sw	a4,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201236:	00868613          	addi	a2,a3,8
ffffffffc020123a:	4709                	li	a4,2
ffffffffc020123c:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201240:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201244:	01868613          	addi	a2,a3,24
    prev->next = next->prev = elm;
ffffffffc0201248:	0105a803          	lw	a6,16(a1)
ffffffffc020124c:	e310                	sd	a2,0(a4)
ffffffffc020124e:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201252:	f298                	sd	a4,32(a3)
    elm->prev = prev;
ffffffffc0201254:	0116bc23          	sd	a7,24(a3)
        nr_free -= n;
ffffffffc0201258:	41c8083b          	subw	a6,a6,t3
ffffffffc020125c:	00005717          	auipc	a4,0x5
ffffffffc0201260:	1f072623          	sw	a6,492(a4) # ffffffffc0206448 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201264:	5775                	li	a4,-3
ffffffffc0201266:	17c1                	addi	a5,a5,-16
ffffffffc0201268:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc020126c:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020126e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201270:	00001697          	auipc	a3,0x1
ffffffffc0201274:	41868693          	addi	a3,a3,1048 # ffffffffc0202688 <commands+0x9c8>
ffffffffc0201278:	00001617          	auipc	a2,0x1
ffffffffc020127c:	09060613          	addi	a2,a2,144 # ffffffffc0202308 <commands+0x648>
ffffffffc0201280:	06100593          	li	a1,97
ffffffffc0201284:	00001517          	auipc	a0,0x1
ffffffffc0201288:	09c50513          	addi	a0,a0,156 # ffffffffc0202320 <commands+0x660>
default_alloc_pages(size_t n) {
ffffffffc020128c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020128e:	91eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201292 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201292:	1141                	addi	sp,sp,-16
ffffffffc0201294:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201296:	c1fd                	beqz	a1,ffffffffc020137c <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc0201298:	00259693          	slli	a3,a1,0x2
ffffffffc020129c:	96ae                	add	a3,a3,a1
ffffffffc020129e:	068e                	slli	a3,a3,0x3
ffffffffc02012a0:	96aa                	add	a3,a3,a0
ffffffffc02012a2:	02d50463          	beq	a0,a3,ffffffffc02012ca <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02012a6:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02012a8:	87aa                	mv	a5,a0
ffffffffc02012aa:	8b05                	andi	a4,a4,1
ffffffffc02012ac:	e709                	bnez	a4,ffffffffc02012b6 <default_init_memmap+0x24>
ffffffffc02012ae:	a07d                	j	ffffffffc020135c <default_init_memmap+0xca>
ffffffffc02012b0:	6798                	ld	a4,8(a5)
ffffffffc02012b2:	8b05                	andi	a4,a4,1
ffffffffc02012b4:	c745                	beqz	a4,ffffffffc020135c <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02012b6:	0007a823          	sw	zero,16(a5)
ffffffffc02012ba:	0007b423          	sd	zero,8(a5)
ffffffffc02012be:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012c2:	02878793          	addi	a5,a5,40
ffffffffc02012c6:	fed795e3          	bne	a5,a3,ffffffffc02012b0 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc02012ca:	2581                	sext.w	a1,a1
ffffffffc02012cc:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012ce:	4789                	li	a5,2
ffffffffc02012d0:	00850713          	addi	a4,a0,8
ffffffffc02012d4:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02012d8:	00005697          	auipc	a3,0x5
ffffffffc02012dc:	16068693          	addi	a3,a3,352 # ffffffffc0206438 <free_area>
ffffffffc02012e0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012e2:	669c                	ld	a5,8(a3)
ffffffffc02012e4:	9db9                	addw	a1,a1,a4
ffffffffc02012e6:	00005717          	auipc	a4,0x5
ffffffffc02012ea:	16b72123          	sw	a1,354(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02012ee:	04d78a63          	beq	a5,a3,ffffffffc0201342 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02012f2:	fe878713          	addi	a4,a5,-24
ffffffffc02012f6:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012f8:	4801                	li	a6,0
ffffffffc02012fa:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02012fe:	00e56a63          	bltu	a0,a4,ffffffffc0201312 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0201302:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201304:	02d70563          	beq	a4,a3,ffffffffc020132e <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201308:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020130a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020130e:	fee57ae3          	bleu	a4,a0,ffffffffc0201302 <default_init_memmap+0x70>
ffffffffc0201312:	00080663          	beqz	a6,ffffffffc020131e <default_init_memmap+0x8c>
ffffffffc0201316:	00005717          	auipc	a4,0x5
ffffffffc020131a:	12b73123          	sd	a1,290(a4) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020131e:	6398                	ld	a4,0(a5)
}
ffffffffc0201320:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201322:	e390                	sd	a2,0(a5)
ffffffffc0201324:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201326:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201328:	ed18                	sd	a4,24(a0)
ffffffffc020132a:	0141                	addi	sp,sp,16
ffffffffc020132c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020132e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201330:	f114                	sd	a3,32(a0)
ffffffffc0201332:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201334:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201336:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201338:	00d70e63          	beq	a4,a3,ffffffffc0201354 <default_init_memmap+0xc2>
ffffffffc020133c:	4805                	li	a6,1
ffffffffc020133e:	87ba                	mv	a5,a4
ffffffffc0201340:	b7e9                	j	ffffffffc020130a <default_init_memmap+0x78>
}
ffffffffc0201342:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201344:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201348:	e398                	sd	a4,0(a5)
ffffffffc020134a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020134c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020134e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201350:	0141                	addi	sp,sp,16
ffffffffc0201352:	8082                	ret
ffffffffc0201354:	60a2                	ld	ra,8(sp)
ffffffffc0201356:	e290                	sd	a2,0(a3)
ffffffffc0201358:	0141                	addi	sp,sp,16
ffffffffc020135a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020135c:	00001697          	auipc	a3,0x1
ffffffffc0201360:	33468693          	addi	a3,a3,820 # ffffffffc0202690 <commands+0x9d0>
ffffffffc0201364:	00001617          	auipc	a2,0x1
ffffffffc0201368:	fa460613          	addi	a2,a2,-92 # ffffffffc0202308 <commands+0x648>
ffffffffc020136c:	04800593          	li	a1,72
ffffffffc0201370:	00001517          	auipc	a0,0x1
ffffffffc0201374:	fb050513          	addi	a0,a0,-80 # ffffffffc0202320 <commands+0x660>
ffffffffc0201378:	834ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020137c:	00001697          	auipc	a3,0x1
ffffffffc0201380:	30c68693          	addi	a3,a3,780 # ffffffffc0202688 <commands+0x9c8>
ffffffffc0201384:	00001617          	auipc	a2,0x1
ffffffffc0201388:	f8460613          	addi	a2,a2,-124 # ffffffffc0202308 <commands+0x648>
ffffffffc020138c:	04500593          	li	a1,69
ffffffffc0201390:	00001517          	auipc	a0,0x1
ffffffffc0201394:	f9050513          	addi	a0,a0,-112 # ffffffffc0202320 <commands+0x660>
ffffffffc0201398:	814ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020139c <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020139c:	100027f3          	csrr	a5,sstatus
ffffffffc02013a0:	8b89                	andi	a5,a5,2
ffffffffc02013a2:	eb89                	bnez	a5,ffffffffc02013b4 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02013a4:	00005797          	auipc	a5,0x5
ffffffffc02013a8:	0b478793          	addi	a5,a5,180 # ffffffffc0206458 <pmm_manager>
ffffffffc02013ac:	639c                	ld	a5,0(a5)
ffffffffc02013ae:	0187b303          	ld	t1,24(a5)
ffffffffc02013b2:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02013b4:	1141                	addi	sp,sp,-16
ffffffffc02013b6:	e406                	sd	ra,8(sp)
ffffffffc02013b8:	e022                	sd	s0,0(sp)
ffffffffc02013ba:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02013bc:	8a8ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02013c0:	00005797          	auipc	a5,0x5
ffffffffc02013c4:	09878793          	addi	a5,a5,152 # ffffffffc0206458 <pmm_manager>
ffffffffc02013c8:	639c                	ld	a5,0(a5)
ffffffffc02013ca:	8522                	mv	a0,s0
ffffffffc02013cc:	6f9c                	ld	a5,24(a5)
ffffffffc02013ce:	9782                	jalr	a5
ffffffffc02013d0:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02013d2:	88cff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02013d6:	8522                	mv	a0,s0
ffffffffc02013d8:	60a2                	ld	ra,8(sp)
ffffffffc02013da:	6402                	ld	s0,0(sp)
ffffffffc02013dc:	0141                	addi	sp,sp,16
ffffffffc02013de:	8082                	ret

ffffffffc02013e0 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02013e0:	100027f3          	csrr	a5,sstatus
ffffffffc02013e4:	8b89                	andi	a5,a5,2
ffffffffc02013e6:	eb89                	bnez	a5,ffffffffc02013f8 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02013e8:	00005797          	auipc	a5,0x5
ffffffffc02013ec:	07078793          	addi	a5,a5,112 # ffffffffc0206458 <pmm_manager>
ffffffffc02013f0:	639c                	ld	a5,0(a5)
ffffffffc02013f2:	0207b303          	ld	t1,32(a5)
ffffffffc02013f6:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc02013f8:	1101                	addi	sp,sp,-32
ffffffffc02013fa:	ec06                	sd	ra,24(sp)
ffffffffc02013fc:	e822                	sd	s0,16(sp)
ffffffffc02013fe:	e426                	sd	s1,8(sp)
ffffffffc0201400:	842a                	mv	s0,a0
ffffffffc0201402:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201404:	860ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201408:	00005797          	auipc	a5,0x5
ffffffffc020140c:	05078793          	addi	a5,a5,80 # ffffffffc0206458 <pmm_manager>
ffffffffc0201410:	639c                	ld	a5,0(a5)
ffffffffc0201412:	85a6                	mv	a1,s1
ffffffffc0201414:	8522                	mv	a0,s0
ffffffffc0201416:	739c                	ld	a5,32(a5)
ffffffffc0201418:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020141a:	6442                	ld	s0,16(sp)
ffffffffc020141c:	60e2                	ld	ra,24(sp)
ffffffffc020141e:	64a2                	ld	s1,8(sp)
ffffffffc0201420:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201422:	83cff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201426 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201426:	100027f3          	csrr	a5,sstatus
ffffffffc020142a:	8b89                	andi	a5,a5,2
ffffffffc020142c:	eb89                	bnez	a5,ffffffffc020143e <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020142e:	00005797          	auipc	a5,0x5
ffffffffc0201432:	02a78793          	addi	a5,a5,42 # ffffffffc0206458 <pmm_manager>
ffffffffc0201436:	639c                	ld	a5,0(a5)
ffffffffc0201438:	0287b303          	ld	t1,40(a5)
ffffffffc020143c:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc020143e:	1141                	addi	sp,sp,-16
ffffffffc0201440:	e406                	sd	ra,8(sp)
ffffffffc0201442:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201444:	820ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201448:	00005797          	auipc	a5,0x5
ffffffffc020144c:	01078793          	addi	a5,a5,16 # ffffffffc0206458 <pmm_manager>
ffffffffc0201450:	639c                	ld	a5,0(a5)
ffffffffc0201452:	779c                	ld	a5,40(a5)
ffffffffc0201454:	9782                	jalr	a5
ffffffffc0201456:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201458:	806ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc020145c:	8522                	mv	a0,s0
ffffffffc020145e:	60a2                	ld	ra,8(sp)
ffffffffc0201460:	6402                	ld	s0,0(sp)
ffffffffc0201462:	0141                	addi	sp,sp,16
ffffffffc0201464:	8082                	ret

ffffffffc0201466 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201466:	00001797          	auipc	a5,0x1
ffffffffc020146a:	23a78793          	addi	a5,a5,570 # ffffffffc02026a0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020146e:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201470:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201472:	00001517          	auipc	a0,0x1
ffffffffc0201476:	27e50513          	addi	a0,a0,638 # ffffffffc02026f0 <default_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc020147a:	ec06                	sd	ra,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020147c:	00005717          	auipc	a4,0x5
ffffffffc0201480:	fcf73e23          	sd	a5,-36(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc0201484:	e822                	sd	s0,16(sp)
ffffffffc0201486:	e426                	sd	s1,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201488:	00005417          	auipc	s0,0x5
ffffffffc020148c:	fd040413          	addi	s0,s0,-48 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201490:	c27fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0201494:	601c                	ld	a5,0(s0)
ffffffffc0201496:	679c                	ld	a5,8(a5)
ffffffffc0201498:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020149a:	57f5                	li	a5,-3
ffffffffc020149c:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020149e:	00001517          	auipc	a0,0x1
ffffffffc02014a2:	26a50513          	addi	a0,a0,618 # ffffffffc0202708 <default_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02014a6:	00005717          	auipc	a4,0x5
ffffffffc02014aa:	faf73d23          	sd	a5,-70(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02014ae:	c09fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02014b2:	46c5                	li	a3,17
ffffffffc02014b4:	06ee                	slli	a3,a3,0x1b
ffffffffc02014b6:	40100613          	li	a2,1025
ffffffffc02014ba:	16fd                	addi	a3,a3,-1
ffffffffc02014bc:	0656                	slli	a2,a2,0x15
ffffffffc02014be:	07e005b7          	lui	a1,0x7e00
ffffffffc02014c2:	00001517          	auipc	a0,0x1
ffffffffc02014c6:	25e50513          	addi	a0,a0,606 # ffffffffc0202720 <default_pmm_manager+0x80>
ffffffffc02014ca:	bedfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02014ce:	777d                	lui	a4,0xfffff
ffffffffc02014d0:	00006797          	auipc	a5,0x6
ffffffffc02014d4:	f9f78793          	addi	a5,a5,-97 # ffffffffc020746f <end+0xfff>
ffffffffc02014d8:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02014da:	00088737          	lui	a4,0x88
ffffffffc02014de:	00005697          	auipc	a3,0x5
ffffffffc02014e2:	f2e6bd23          	sd	a4,-198(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02014e6:	4601                	li	a2,0
ffffffffc02014e8:	00005717          	auipc	a4,0x5
ffffffffc02014ec:	f8f73023          	sd	a5,-128(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02014f0:	4681                	li	a3,0
ffffffffc02014f2:	00005897          	auipc	a7,0x5
ffffffffc02014f6:	f2688893          	addi	a7,a7,-218 # ffffffffc0206418 <npage>
ffffffffc02014fa:	00005597          	auipc	a1,0x5
ffffffffc02014fe:	f6e58593          	addi	a1,a1,-146 # ffffffffc0206468 <pages>
ffffffffc0201502:	4805                	li	a6,1
ffffffffc0201504:	fff80537          	lui	a0,0xfff80
ffffffffc0201508:	a011                	j	ffffffffc020150c <pmm_init+0xa6>
ffffffffc020150a:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020150c:	97b2                	add	a5,a5,a2
ffffffffc020150e:	07a1                	addi	a5,a5,8
ffffffffc0201510:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201514:	0008b703          	ld	a4,0(a7)
ffffffffc0201518:	0685                	addi	a3,a3,1
ffffffffc020151a:	02860613          	addi	a2,a2,40
ffffffffc020151e:	00a707b3          	add	a5,a4,a0
ffffffffc0201522:	fef6e4e3          	bltu	a3,a5,ffffffffc020150a <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201526:	6190                	ld	a2,0(a1)
ffffffffc0201528:	00271793          	slli	a5,a4,0x2
ffffffffc020152c:	97ba                	add	a5,a5,a4
ffffffffc020152e:	fec006b7          	lui	a3,0xfec00
ffffffffc0201532:	078e                	slli	a5,a5,0x3
ffffffffc0201534:	96b2                	add	a3,a3,a2
ffffffffc0201536:	96be                	add	a3,a3,a5
ffffffffc0201538:	c02007b7          	lui	a5,0xc0200
ffffffffc020153c:	08f6e863          	bltu	a3,a5,ffffffffc02015cc <pmm_init+0x166>
ffffffffc0201540:	00005497          	auipc	s1,0x5
ffffffffc0201544:	f2048493          	addi	s1,s1,-224 # ffffffffc0206460 <va_pa_offset>
ffffffffc0201548:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc020154a:	45c5                	li	a1,17
ffffffffc020154c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020154e:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0201550:	04b6e963          	bltu	a3,a1,ffffffffc02015a2 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201554:	601c                	ld	a5,0(s0)
ffffffffc0201556:	7b9c                	ld	a5,48(a5)
ffffffffc0201558:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020155a:	00001517          	auipc	a0,0x1
ffffffffc020155e:	25e50513          	addi	a0,a0,606 # ffffffffc02027b8 <default_pmm_manager+0x118>
ffffffffc0201562:	b55fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201566:	00004697          	auipc	a3,0x4
ffffffffc020156a:	a9a68693          	addi	a3,a3,-1382 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020156e:	00005797          	auipc	a5,0x5
ffffffffc0201572:	ead7b923          	sd	a3,-334(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201576:	c02007b7          	lui	a5,0xc0200
ffffffffc020157a:	06f6e563          	bltu	a3,a5,ffffffffc02015e4 <pmm_init+0x17e>
ffffffffc020157e:	609c                	ld	a5,0(s1)
}
ffffffffc0201580:	6442                	ld	s0,16(sp)
ffffffffc0201582:	60e2                	ld	ra,24(sp)
ffffffffc0201584:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201586:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0201588:	8e9d                	sub	a3,a3,a5
ffffffffc020158a:	00005797          	auipc	a5,0x5
ffffffffc020158e:	ecd7b323          	sd	a3,-314(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201592:	00001517          	auipc	a0,0x1
ffffffffc0201596:	24650513          	addi	a0,a0,582 # ffffffffc02027d8 <default_pmm_manager+0x138>
ffffffffc020159a:	8636                	mv	a2,a3
}
ffffffffc020159c:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020159e:	b19fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02015a2:	6785                	lui	a5,0x1
ffffffffc02015a4:	17fd                	addi	a5,a5,-1
ffffffffc02015a6:	96be                	add	a3,a3,a5
ffffffffc02015a8:	77fd                	lui	a5,0xfffff
ffffffffc02015aa:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02015ac:	00c6d793          	srli	a5,a3,0xc
ffffffffc02015b0:	04e7f663          	bleu	a4,a5,ffffffffc02015fc <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02015b4:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02015b6:	97aa                	add	a5,a5,a0
ffffffffc02015b8:	00279513          	slli	a0,a5,0x2
ffffffffc02015bc:	953e                	add	a0,a0,a5
ffffffffc02015be:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02015c0:	8d95                	sub	a1,a1,a3
ffffffffc02015c2:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02015c4:	81b1                	srli	a1,a1,0xc
ffffffffc02015c6:	9532                	add	a0,a0,a2
ffffffffc02015c8:	9782                	jalr	a5
ffffffffc02015ca:	b769                	j	ffffffffc0201554 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02015cc:	00001617          	auipc	a2,0x1
ffffffffc02015d0:	18460613          	addi	a2,a2,388 # ffffffffc0202750 <default_pmm_manager+0xb0>
ffffffffc02015d4:	06e00593          	li	a1,110
ffffffffc02015d8:	00001517          	auipc	a0,0x1
ffffffffc02015dc:	1a050513          	addi	a0,a0,416 # ffffffffc0202778 <default_pmm_manager+0xd8>
ffffffffc02015e0:	dcdfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02015e4:	00001617          	auipc	a2,0x1
ffffffffc02015e8:	16c60613          	addi	a2,a2,364 # ffffffffc0202750 <default_pmm_manager+0xb0>
ffffffffc02015ec:	08900593          	li	a1,137
ffffffffc02015f0:	00001517          	auipc	a0,0x1
ffffffffc02015f4:	18850513          	addi	a0,a0,392 # ffffffffc0202778 <default_pmm_manager+0xd8>
ffffffffc02015f8:	db5fe0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02015fc:	00001617          	auipc	a2,0x1
ffffffffc0201600:	18c60613          	addi	a2,a2,396 # ffffffffc0202788 <default_pmm_manager+0xe8>
ffffffffc0201604:	06b00593          	li	a1,107
ffffffffc0201608:	00001517          	auipc	a0,0x1
ffffffffc020160c:	1a050513          	addi	a0,a0,416 # ffffffffc02027a8 <default_pmm_manager+0x108>
ffffffffc0201610:	d9dfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201614 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201614:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201618:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020161a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020161e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201620:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201624:	f022                	sd	s0,32(sp)
ffffffffc0201626:	ec26                	sd	s1,24(sp)
ffffffffc0201628:	e84a                	sd	s2,16(sp)
ffffffffc020162a:	f406                	sd	ra,40(sp)
ffffffffc020162c:	e44e                	sd	s3,8(sp)
ffffffffc020162e:	84aa                	mv	s1,a0
ffffffffc0201630:	892e                	mv	s2,a1
ffffffffc0201632:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201636:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201638:	03067e63          	bleu	a6,a2,ffffffffc0201674 <printnum+0x60>
ffffffffc020163c:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020163e:	00805763          	blez	s0,ffffffffc020164c <printnum+0x38>
ffffffffc0201642:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201644:	85ca                	mv	a1,s2
ffffffffc0201646:	854e                	mv	a0,s3
ffffffffc0201648:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020164a:	fc65                	bnez	s0,ffffffffc0201642 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020164c:	1a02                	slli	s4,s4,0x20
ffffffffc020164e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201652:	00001797          	auipc	a5,0x1
ffffffffc0201656:	35678793          	addi	a5,a5,854 # ffffffffc02029a8 <error_string+0x38>
ffffffffc020165a:	9a3e                	add	s4,s4,a5
}
ffffffffc020165c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020165e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201662:	70a2                	ld	ra,40(sp)
ffffffffc0201664:	69a2                	ld	s3,8(sp)
ffffffffc0201666:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201668:	85ca                	mv	a1,s2
ffffffffc020166a:	8326                	mv	t1,s1
}
ffffffffc020166c:	6942                	ld	s2,16(sp)
ffffffffc020166e:	64e2                	ld	s1,24(sp)
ffffffffc0201670:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201672:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201674:	03065633          	divu	a2,a2,a6
ffffffffc0201678:	8722                	mv	a4,s0
ffffffffc020167a:	f9bff0ef          	jal	ra,ffffffffc0201614 <printnum>
ffffffffc020167e:	b7f9                	j	ffffffffc020164c <printnum+0x38>

ffffffffc0201680 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201680:	7119                	addi	sp,sp,-128
ffffffffc0201682:	f4a6                	sd	s1,104(sp)
ffffffffc0201684:	f0ca                	sd	s2,96(sp)
ffffffffc0201686:	e8d2                	sd	s4,80(sp)
ffffffffc0201688:	e4d6                	sd	s5,72(sp)
ffffffffc020168a:	e0da                	sd	s6,64(sp)
ffffffffc020168c:	fc5e                	sd	s7,56(sp)
ffffffffc020168e:	f862                	sd	s8,48(sp)
ffffffffc0201690:	f06a                	sd	s10,32(sp)
ffffffffc0201692:	fc86                	sd	ra,120(sp)
ffffffffc0201694:	f8a2                	sd	s0,112(sp)
ffffffffc0201696:	ecce                	sd	s3,88(sp)
ffffffffc0201698:	f466                	sd	s9,40(sp)
ffffffffc020169a:	ec6e                	sd	s11,24(sp)
ffffffffc020169c:	892a                	mv	s2,a0
ffffffffc020169e:	84ae                	mv	s1,a1
ffffffffc02016a0:	8d32                	mv	s10,a2
ffffffffc02016a2:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02016a4:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016a6:	00001a17          	auipc	s4,0x1
ffffffffc02016aa:	172a0a13          	addi	s4,s4,370 # ffffffffc0202818 <default_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016ae:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016b2:	00001c17          	auipc	s8,0x1
ffffffffc02016b6:	2bec0c13          	addi	s8,s8,702 # ffffffffc0202970 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016ba:	000d4503          	lbu	a0,0(s10)
ffffffffc02016be:	02500793          	li	a5,37
ffffffffc02016c2:	001d0413          	addi	s0,s10,1
ffffffffc02016c6:	00f50e63          	beq	a0,a5,ffffffffc02016e2 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02016ca:	c521                	beqz	a0,ffffffffc0201712 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016cc:	02500993          	li	s3,37
ffffffffc02016d0:	a011                	j	ffffffffc02016d4 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02016d2:	c121                	beqz	a0,ffffffffc0201712 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02016d4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016d6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02016d8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016da:	fff44503          	lbu	a0,-1(s0)
ffffffffc02016de:	ff351ae3          	bne	a0,s3,ffffffffc02016d2 <vprintfmt+0x52>
ffffffffc02016e2:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02016e6:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02016ea:	4981                	li	s3,0
ffffffffc02016ec:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02016ee:	5cfd                	li	s9,-1
ffffffffc02016f0:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f2:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02016f6:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f8:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02016fc:	0ff6f693          	andi	a3,a3,255
ffffffffc0201700:	00140d13          	addi	s10,s0,1
ffffffffc0201704:	20d5e563          	bltu	a1,a3,ffffffffc020190e <vprintfmt+0x28e>
ffffffffc0201708:	068a                	slli	a3,a3,0x2
ffffffffc020170a:	96d2                	add	a3,a3,s4
ffffffffc020170c:	4294                	lw	a3,0(a3)
ffffffffc020170e:	96d2                	add	a3,a3,s4
ffffffffc0201710:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201712:	70e6                	ld	ra,120(sp)
ffffffffc0201714:	7446                	ld	s0,112(sp)
ffffffffc0201716:	74a6                	ld	s1,104(sp)
ffffffffc0201718:	7906                	ld	s2,96(sp)
ffffffffc020171a:	69e6                	ld	s3,88(sp)
ffffffffc020171c:	6a46                	ld	s4,80(sp)
ffffffffc020171e:	6aa6                	ld	s5,72(sp)
ffffffffc0201720:	6b06                	ld	s6,64(sp)
ffffffffc0201722:	7be2                	ld	s7,56(sp)
ffffffffc0201724:	7c42                	ld	s8,48(sp)
ffffffffc0201726:	7ca2                	ld	s9,40(sp)
ffffffffc0201728:	7d02                	ld	s10,32(sp)
ffffffffc020172a:	6de2                	ld	s11,24(sp)
ffffffffc020172c:	6109                	addi	sp,sp,128
ffffffffc020172e:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201730:	4705                	li	a4,1
ffffffffc0201732:	008a8593          	addi	a1,s5,8
ffffffffc0201736:	01074463          	blt	a4,a6,ffffffffc020173e <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc020173a:	26080363          	beqz	a6,ffffffffc02019a0 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020173e:	000ab603          	ld	a2,0(s5)
ffffffffc0201742:	46c1                	li	a3,16
ffffffffc0201744:	8aae                	mv	s5,a1
ffffffffc0201746:	a06d                	j	ffffffffc02017f0 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201748:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020174c:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020174e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201750:	b765                	j	ffffffffc02016f8 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201752:	000aa503          	lw	a0,0(s5)
ffffffffc0201756:	85a6                	mv	a1,s1
ffffffffc0201758:	0aa1                	addi	s5,s5,8
ffffffffc020175a:	9902                	jalr	s2
            break;
ffffffffc020175c:	bfb9                	j	ffffffffc02016ba <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020175e:	4705                	li	a4,1
ffffffffc0201760:	008a8993          	addi	s3,s5,8
ffffffffc0201764:	01074463          	blt	a4,a6,ffffffffc020176c <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201768:	22080463          	beqz	a6,ffffffffc0201990 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020176c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201770:	24044463          	bltz	s0,ffffffffc02019b8 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0201774:	8622                	mv	a2,s0
ffffffffc0201776:	8ace                	mv	s5,s3
ffffffffc0201778:	46a9                	li	a3,10
ffffffffc020177a:	a89d                	j	ffffffffc02017f0 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc020177c:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201780:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201782:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0201784:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201788:	8fb5                	xor	a5,a5,a3
ffffffffc020178a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020178e:	1ad74363          	blt	a4,a3,ffffffffc0201934 <vprintfmt+0x2b4>
ffffffffc0201792:	00369793          	slli	a5,a3,0x3
ffffffffc0201796:	97e2                	add	a5,a5,s8
ffffffffc0201798:	639c                	ld	a5,0(a5)
ffffffffc020179a:	18078d63          	beqz	a5,ffffffffc0201934 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc020179e:	86be                	mv	a3,a5
ffffffffc02017a0:	00001617          	auipc	a2,0x1
ffffffffc02017a4:	2b860613          	addi	a2,a2,696 # ffffffffc0202a58 <error_string+0xe8>
ffffffffc02017a8:	85a6                	mv	a1,s1
ffffffffc02017aa:	854a                	mv	a0,s2
ffffffffc02017ac:	240000ef          	jal	ra,ffffffffc02019ec <printfmt>
ffffffffc02017b0:	b729                	j	ffffffffc02016ba <vprintfmt+0x3a>
            lflag ++;
ffffffffc02017b2:	00144603          	lbu	a2,1(s0)
ffffffffc02017b6:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017b8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017ba:	bf3d                	j	ffffffffc02016f8 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02017bc:	4705                	li	a4,1
ffffffffc02017be:	008a8593          	addi	a1,s5,8
ffffffffc02017c2:	01074463          	blt	a4,a6,ffffffffc02017ca <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02017c6:	1e080263          	beqz	a6,ffffffffc02019aa <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02017ca:	000ab603          	ld	a2,0(s5)
ffffffffc02017ce:	46a1                	li	a3,8
ffffffffc02017d0:	8aae                	mv	s5,a1
ffffffffc02017d2:	a839                	j	ffffffffc02017f0 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02017d4:	03000513          	li	a0,48
ffffffffc02017d8:	85a6                	mv	a1,s1
ffffffffc02017da:	e03e                	sd	a5,0(sp)
ffffffffc02017dc:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02017de:	85a6                	mv	a1,s1
ffffffffc02017e0:	07800513          	li	a0,120
ffffffffc02017e4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02017e6:	0aa1                	addi	s5,s5,8
ffffffffc02017e8:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02017ec:	6782                	ld	a5,0(sp)
ffffffffc02017ee:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02017f0:	876e                	mv	a4,s11
ffffffffc02017f2:	85a6                	mv	a1,s1
ffffffffc02017f4:	854a                	mv	a0,s2
ffffffffc02017f6:	e1fff0ef          	jal	ra,ffffffffc0201614 <printnum>
            break;
ffffffffc02017fa:	b5c1                	j	ffffffffc02016ba <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017fc:	000ab603          	ld	a2,0(s5)
ffffffffc0201800:	0aa1                	addi	s5,s5,8
ffffffffc0201802:	1c060663          	beqz	a2,ffffffffc02019ce <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201806:	00160413          	addi	s0,a2,1
ffffffffc020180a:	17b05c63          	blez	s11,ffffffffc0201982 <vprintfmt+0x302>
ffffffffc020180e:	02d00593          	li	a1,45
ffffffffc0201812:	14b79263          	bne	a5,a1,ffffffffc0201956 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201816:	00064783          	lbu	a5,0(a2)
ffffffffc020181a:	0007851b          	sext.w	a0,a5
ffffffffc020181e:	c905                	beqz	a0,ffffffffc020184e <vprintfmt+0x1ce>
ffffffffc0201820:	000cc563          	bltz	s9,ffffffffc020182a <vprintfmt+0x1aa>
ffffffffc0201824:	3cfd                	addiw	s9,s9,-1
ffffffffc0201826:	036c8263          	beq	s9,s6,ffffffffc020184a <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020182a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020182c:	18098463          	beqz	s3,ffffffffc02019b4 <vprintfmt+0x334>
ffffffffc0201830:	3781                	addiw	a5,a5,-32
ffffffffc0201832:	18fbf163          	bleu	a5,s7,ffffffffc02019b4 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201836:	03f00513          	li	a0,63
ffffffffc020183a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020183c:	0405                	addi	s0,s0,1
ffffffffc020183e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201842:	3dfd                	addiw	s11,s11,-1
ffffffffc0201844:	0007851b          	sext.w	a0,a5
ffffffffc0201848:	fd61                	bnez	a0,ffffffffc0201820 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc020184a:	e7b058e3          	blez	s11,ffffffffc02016ba <vprintfmt+0x3a>
ffffffffc020184e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201850:	85a6                	mv	a1,s1
ffffffffc0201852:	02000513          	li	a0,32
ffffffffc0201856:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201858:	e60d81e3          	beqz	s11,ffffffffc02016ba <vprintfmt+0x3a>
ffffffffc020185c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020185e:	85a6                	mv	a1,s1
ffffffffc0201860:	02000513          	li	a0,32
ffffffffc0201864:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201866:	fe0d94e3          	bnez	s11,ffffffffc020184e <vprintfmt+0x1ce>
ffffffffc020186a:	bd81                	j	ffffffffc02016ba <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020186c:	4705                	li	a4,1
ffffffffc020186e:	008a8593          	addi	a1,s5,8
ffffffffc0201872:	01074463          	blt	a4,a6,ffffffffc020187a <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0201876:	12080063          	beqz	a6,ffffffffc0201996 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc020187a:	000ab603          	ld	a2,0(s5)
ffffffffc020187e:	46a9                	li	a3,10
ffffffffc0201880:	8aae                	mv	s5,a1
ffffffffc0201882:	b7bd                	j	ffffffffc02017f0 <vprintfmt+0x170>
ffffffffc0201884:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201888:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020188c:	846a                	mv	s0,s10
ffffffffc020188e:	b5ad                	j	ffffffffc02016f8 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201890:	85a6                	mv	a1,s1
ffffffffc0201892:	02500513          	li	a0,37
ffffffffc0201896:	9902                	jalr	s2
            break;
ffffffffc0201898:	b50d                	j	ffffffffc02016ba <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc020189a:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020189e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02018a2:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018a4:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02018a6:	e40dd9e3          	bgez	s11,ffffffffc02016f8 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02018aa:	8de6                	mv	s11,s9
ffffffffc02018ac:	5cfd                	li	s9,-1
ffffffffc02018ae:	b5a9                	j	ffffffffc02016f8 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02018b0:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02018b4:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018b8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02018ba:	bd3d                	j	ffffffffc02016f8 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02018bc:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02018c0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018c4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02018c6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02018ca:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02018ce:	fcd56ce3          	bltu	a0,a3,ffffffffc02018a6 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02018d2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02018d4:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02018d8:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02018dc:	0196873b          	addw	a4,a3,s9
ffffffffc02018e0:	0017171b          	slliw	a4,a4,0x1
ffffffffc02018e4:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02018e8:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02018ec:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02018f0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02018f4:	fcd57fe3          	bleu	a3,a0,ffffffffc02018d2 <vprintfmt+0x252>
ffffffffc02018f8:	b77d                	j	ffffffffc02018a6 <vprintfmt+0x226>
            if (width < 0)
ffffffffc02018fa:	fffdc693          	not	a3,s11
ffffffffc02018fe:	96fd                	srai	a3,a3,0x3f
ffffffffc0201900:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201904:	00144603          	lbu	a2,1(s0)
ffffffffc0201908:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020190a:	846a                	mv	s0,s10
ffffffffc020190c:	b3f5                	j	ffffffffc02016f8 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020190e:	85a6                	mv	a1,s1
ffffffffc0201910:	02500513          	li	a0,37
ffffffffc0201914:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201916:	fff44703          	lbu	a4,-1(s0)
ffffffffc020191a:	02500793          	li	a5,37
ffffffffc020191e:	8d22                	mv	s10,s0
ffffffffc0201920:	d8f70de3          	beq	a4,a5,ffffffffc02016ba <vprintfmt+0x3a>
ffffffffc0201924:	02500713          	li	a4,37
ffffffffc0201928:	1d7d                	addi	s10,s10,-1
ffffffffc020192a:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020192e:	fee79de3          	bne	a5,a4,ffffffffc0201928 <vprintfmt+0x2a8>
ffffffffc0201932:	b361                	j	ffffffffc02016ba <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201934:	00001617          	auipc	a2,0x1
ffffffffc0201938:	11460613          	addi	a2,a2,276 # ffffffffc0202a48 <error_string+0xd8>
ffffffffc020193c:	85a6                	mv	a1,s1
ffffffffc020193e:	854a                	mv	a0,s2
ffffffffc0201940:	0ac000ef          	jal	ra,ffffffffc02019ec <printfmt>
ffffffffc0201944:	bb9d                	j	ffffffffc02016ba <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201946:	00001617          	auipc	a2,0x1
ffffffffc020194a:	0fa60613          	addi	a2,a2,250 # ffffffffc0202a40 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020194e:	00001417          	auipc	s0,0x1
ffffffffc0201952:	0f340413          	addi	s0,s0,243 # ffffffffc0202a41 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201956:	8532                	mv	a0,a2
ffffffffc0201958:	85e6                	mv	a1,s9
ffffffffc020195a:	e032                	sd	a2,0(sp)
ffffffffc020195c:	e43e                	sd	a5,8(sp)
ffffffffc020195e:	1c2000ef          	jal	ra,ffffffffc0201b20 <strnlen>
ffffffffc0201962:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201966:	6602                	ld	a2,0(sp)
ffffffffc0201968:	01b05d63          	blez	s11,ffffffffc0201982 <vprintfmt+0x302>
ffffffffc020196c:	67a2                	ld	a5,8(sp)
ffffffffc020196e:	2781                	sext.w	a5,a5
ffffffffc0201970:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201972:	6522                	ld	a0,8(sp)
ffffffffc0201974:	85a6                	mv	a1,s1
ffffffffc0201976:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201978:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020197a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020197c:	6602                	ld	a2,0(sp)
ffffffffc020197e:	fe0d9ae3          	bnez	s11,ffffffffc0201972 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201982:	00064783          	lbu	a5,0(a2)
ffffffffc0201986:	0007851b          	sext.w	a0,a5
ffffffffc020198a:	e8051be3          	bnez	a0,ffffffffc0201820 <vprintfmt+0x1a0>
ffffffffc020198e:	b335                	j	ffffffffc02016ba <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201990:	000aa403          	lw	s0,0(s5)
ffffffffc0201994:	bbf1                	j	ffffffffc0201770 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201996:	000ae603          	lwu	a2,0(s5)
ffffffffc020199a:	46a9                	li	a3,10
ffffffffc020199c:	8aae                	mv	s5,a1
ffffffffc020199e:	bd89                	j	ffffffffc02017f0 <vprintfmt+0x170>
ffffffffc02019a0:	000ae603          	lwu	a2,0(s5)
ffffffffc02019a4:	46c1                	li	a3,16
ffffffffc02019a6:	8aae                	mv	s5,a1
ffffffffc02019a8:	b5a1                	j	ffffffffc02017f0 <vprintfmt+0x170>
ffffffffc02019aa:	000ae603          	lwu	a2,0(s5)
ffffffffc02019ae:	46a1                	li	a3,8
ffffffffc02019b0:	8aae                	mv	s5,a1
ffffffffc02019b2:	bd3d                	j	ffffffffc02017f0 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02019b4:	9902                	jalr	s2
ffffffffc02019b6:	b559                	j	ffffffffc020183c <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02019b8:	85a6                	mv	a1,s1
ffffffffc02019ba:	02d00513          	li	a0,45
ffffffffc02019be:	e03e                	sd	a5,0(sp)
ffffffffc02019c0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02019c2:	8ace                	mv	s5,s3
ffffffffc02019c4:	40800633          	neg	a2,s0
ffffffffc02019c8:	46a9                	li	a3,10
ffffffffc02019ca:	6782                	ld	a5,0(sp)
ffffffffc02019cc:	b515                	j	ffffffffc02017f0 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02019ce:	01b05663          	blez	s11,ffffffffc02019da <vprintfmt+0x35a>
ffffffffc02019d2:	02d00693          	li	a3,45
ffffffffc02019d6:	f6d798e3          	bne	a5,a3,ffffffffc0201946 <vprintfmt+0x2c6>
ffffffffc02019da:	00001417          	auipc	s0,0x1
ffffffffc02019de:	06740413          	addi	s0,s0,103 # ffffffffc0202a41 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019e2:	02800513          	li	a0,40
ffffffffc02019e6:	02800793          	li	a5,40
ffffffffc02019ea:	bd1d                	j	ffffffffc0201820 <vprintfmt+0x1a0>

ffffffffc02019ec <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019ec:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02019ee:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019f2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02019f4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019f6:	ec06                	sd	ra,24(sp)
ffffffffc02019f8:	f83a                	sd	a4,48(sp)
ffffffffc02019fa:	fc3e                	sd	a5,56(sp)
ffffffffc02019fc:	e0c2                	sd	a6,64(sp)
ffffffffc02019fe:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201a00:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a02:	c7fff0ef          	jal	ra,ffffffffc0201680 <vprintfmt>
}
ffffffffc0201a06:	60e2                	ld	ra,24(sp)
ffffffffc0201a08:	6161                	addi	sp,sp,80
ffffffffc0201a0a:	8082                	ret

ffffffffc0201a0c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201a0c:	715d                	addi	sp,sp,-80
ffffffffc0201a0e:	e486                	sd	ra,72(sp)
ffffffffc0201a10:	e0a2                	sd	s0,64(sp)
ffffffffc0201a12:	fc26                	sd	s1,56(sp)
ffffffffc0201a14:	f84a                	sd	s2,48(sp)
ffffffffc0201a16:	f44e                	sd	s3,40(sp)
ffffffffc0201a18:	f052                	sd	s4,32(sp)
ffffffffc0201a1a:	ec56                	sd	s5,24(sp)
ffffffffc0201a1c:	e85a                	sd	s6,16(sp)
ffffffffc0201a1e:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201a20:	c901                	beqz	a0,ffffffffc0201a30 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201a22:	85aa                	mv	a1,a0
ffffffffc0201a24:	00001517          	auipc	a0,0x1
ffffffffc0201a28:	03450513          	addi	a0,a0,52 # ffffffffc0202a58 <error_string+0xe8>
ffffffffc0201a2c:	e8afe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201a30:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a32:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201a34:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201a36:	4aa9                	li	s5,10
ffffffffc0201a38:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201a3a:	00004b97          	auipc	s7,0x4
ffffffffc0201a3e:	5d6b8b93          	addi	s7,s7,1494 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a42:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201a46:	ee8fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201a4a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a4c:	00054b63          	bltz	a0,ffffffffc0201a62 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a50:	00a95b63          	ble	a0,s2,ffffffffc0201a66 <readline+0x5a>
ffffffffc0201a54:	029a5463          	ble	s1,s4,ffffffffc0201a7c <readline+0x70>
        c = getchar();
ffffffffc0201a58:	ed6fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201a5c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a5e:	fe0559e3          	bgez	a0,ffffffffc0201a50 <readline+0x44>
            return NULL;
ffffffffc0201a62:	4501                	li	a0,0
ffffffffc0201a64:	a099                	j	ffffffffc0201aaa <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201a66:	03341463          	bne	s0,s3,ffffffffc0201a8e <readline+0x82>
ffffffffc0201a6a:	e8b9                	bnez	s1,ffffffffc0201ac0 <readline+0xb4>
        c = getchar();
ffffffffc0201a6c:	ec2fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201a70:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a72:	fe0548e3          	bltz	a0,ffffffffc0201a62 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a76:	fea958e3          	ble	a0,s2,ffffffffc0201a66 <readline+0x5a>
ffffffffc0201a7a:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201a7c:	8522                	mv	a0,s0
ffffffffc0201a7e:	e6cfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201a82:	009b87b3          	add	a5,s7,s1
ffffffffc0201a86:	00878023          	sb	s0,0(a5)
ffffffffc0201a8a:	2485                	addiw	s1,s1,1
ffffffffc0201a8c:	bf6d                	j	ffffffffc0201a46 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201a8e:	01540463          	beq	s0,s5,ffffffffc0201a96 <readline+0x8a>
ffffffffc0201a92:	fb641ae3          	bne	s0,s6,ffffffffc0201a46 <readline+0x3a>
            cputchar(c);
ffffffffc0201a96:	8522                	mv	a0,s0
ffffffffc0201a98:	e52fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201a9c:	00004517          	auipc	a0,0x4
ffffffffc0201aa0:	57450513          	addi	a0,a0,1396 # ffffffffc0206010 <edata>
ffffffffc0201aa4:	94aa                	add	s1,s1,a0
ffffffffc0201aa6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201aaa:	60a6                	ld	ra,72(sp)
ffffffffc0201aac:	6406                	ld	s0,64(sp)
ffffffffc0201aae:	74e2                	ld	s1,56(sp)
ffffffffc0201ab0:	7942                	ld	s2,48(sp)
ffffffffc0201ab2:	79a2                	ld	s3,40(sp)
ffffffffc0201ab4:	7a02                	ld	s4,32(sp)
ffffffffc0201ab6:	6ae2                	ld	s5,24(sp)
ffffffffc0201ab8:	6b42                	ld	s6,16(sp)
ffffffffc0201aba:	6ba2                	ld	s7,8(sp)
ffffffffc0201abc:	6161                	addi	sp,sp,80
ffffffffc0201abe:	8082                	ret
            cputchar(c);
ffffffffc0201ac0:	4521                	li	a0,8
ffffffffc0201ac2:	e28fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201ac6:	34fd                	addiw	s1,s1,-1
ffffffffc0201ac8:	bfbd                	j	ffffffffc0201a46 <readline+0x3a>

ffffffffc0201aca <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201aca:	00004797          	auipc	a5,0x4
ffffffffc0201ace:	53e78793          	addi	a5,a5,1342 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201ad2:	6398                	ld	a4,0(a5)
ffffffffc0201ad4:	4781                	li	a5,0
ffffffffc0201ad6:	88ba                	mv	a7,a4
ffffffffc0201ad8:	852a                	mv	a0,a0
ffffffffc0201ada:	85be                	mv	a1,a5
ffffffffc0201adc:	863e                	mv	a2,a5
ffffffffc0201ade:	00000073          	ecall
ffffffffc0201ae2:	87aa                	mv	a5,a0
}
ffffffffc0201ae4:	8082                	ret

ffffffffc0201ae6 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201ae6:	00005797          	auipc	a5,0x5
ffffffffc0201aea:	94278793          	addi	a5,a5,-1726 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201aee:	6398                	ld	a4,0(a5)
ffffffffc0201af0:	4781                	li	a5,0
ffffffffc0201af2:	88ba                	mv	a7,a4
ffffffffc0201af4:	852a                	mv	a0,a0
ffffffffc0201af6:	85be                	mv	a1,a5
ffffffffc0201af8:	863e                	mv	a2,a5
ffffffffc0201afa:	00000073          	ecall
ffffffffc0201afe:	87aa                	mv	a5,a0
}
ffffffffc0201b00:	8082                	ret

ffffffffc0201b02 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201b02:	00004797          	auipc	a5,0x4
ffffffffc0201b06:	4fe78793          	addi	a5,a5,1278 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201b0a:	639c                	ld	a5,0(a5)
ffffffffc0201b0c:	4501                	li	a0,0
ffffffffc0201b0e:	88be                	mv	a7,a5
ffffffffc0201b10:	852a                	mv	a0,a0
ffffffffc0201b12:	85aa                	mv	a1,a0
ffffffffc0201b14:	862a                	mv	a2,a0
ffffffffc0201b16:	00000073          	ecall
ffffffffc0201b1a:	852a                	mv	a0,a0
ffffffffc0201b1c:	2501                	sext.w	a0,a0
ffffffffc0201b1e:	8082                	ret

ffffffffc0201b20 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b20:	c185                	beqz	a1,ffffffffc0201b40 <strnlen+0x20>
ffffffffc0201b22:	00054783          	lbu	a5,0(a0)
ffffffffc0201b26:	cf89                	beqz	a5,ffffffffc0201b40 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201b28:	4781                	li	a5,0
ffffffffc0201b2a:	a021                	j	ffffffffc0201b32 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b2c:	00074703          	lbu	a4,0(a4)
ffffffffc0201b30:	c711                	beqz	a4,ffffffffc0201b3c <strnlen+0x1c>
        cnt ++;
ffffffffc0201b32:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b34:	00f50733          	add	a4,a0,a5
ffffffffc0201b38:	fef59ae3          	bne	a1,a5,ffffffffc0201b2c <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201b3c:	853e                	mv	a0,a5
ffffffffc0201b3e:	8082                	ret
    size_t cnt = 0;
ffffffffc0201b40:	4781                	li	a5,0
}
ffffffffc0201b42:	853e                	mv	a0,a5
ffffffffc0201b44:	8082                	ret

ffffffffc0201b46 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b46:	00054783          	lbu	a5,0(a0)
ffffffffc0201b4a:	0005c703          	lbu	a4,0(a1)
ffffffffc0201b4e:	cb91                	beqz	a5,ffffffffc0201b62 <strcmp+0x1c>
ffffffffc0201b50:	00e79c63          	bne	a5,a4,ffffffffc0201b68 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201b54:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b56:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201b5a:	0585                	addi	a1,a1,1
ffffffffc0201b5c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b60:	fbe5                	bnez	a5,ffffffffc0201b50 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201b62:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201b64:	9d19                	subw	a0,a0,a4
ffffffffc0201b66:	8082                	ret
ffffffffc0201b68:	0007851b          	sext.w	a0,a5
ffffffffc0201b6c:	9d19                	subw	a0,a0,a4
ffffffffc0201b6e:	8082                	ret

ffffffffc0201b70 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201b70:	00054783          	lbu	a5,0(a0)
ffffffffc0201b74:	cb91                	beqz	a5,ffffffffc0201b88 <strchr+0x18>
        if (*s == c) {
ffffffffc0201b76:	00b79563          	bne	a5,a1,ffffffffc0201b80 <strchr+0x10>
ffffffffc0201b7a:	a809                	j	ffffffffc0201b8c <strchr+0x1c>
ffffffffc0201b7c:	00b78763          	beq	a5,a1,ffffffffc0201b8a <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201b80:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201b82:	00054783          	lbu	a5,0(a0)
ffffffffc0201b86:	fbfd                	bnez	a5,ffffffffc0201b7c <strchr+0xc>
    }
    return NULL;
ffffffffc0201b88:	4501                	li	a0,0
}
ffffffffc0201b8a:	8082                	ret
ffffffffc0201b8c:	8082                	ret

ffffffffc0201b8e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201b8e:	ca01                	beqz	a2,ffffffffc0201b9e <memset+0x10>
ffffffffc0201b90:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201b92:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201b94:	0785                	addi	a5,a5,1
ffffffffc0201b96:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201b9a:	fec79de3          	bne	a5,a2,ffffffffc0201b94 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201b9e:	8082                	ret
