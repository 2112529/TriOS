
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
ffffffffc020004e:	3cd010ef          	jal	ra,ffffffffc0201c1a <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	bda50513          	addi	a0,a0,-1062 # ffffffffc0201c30 <etext+0x4>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	488010ef          	jal	ra,ffffffffc02014f2 <pmm_init>

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
ffffffffc02000aa:	662010ef          	jal	ra,ffffffffc020170c <vprintfmt>
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
ffffffffc02000de:	62e010ef          	jal	ra,ffffffffc020170c <vprintfmt>
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
ffffffffc0200144:	b4050513          	addi	a0,a0,-1216 # ffffffffc0201c80 <etext+0x54>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0201ca0 <etext+0x74>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00002597          	auipc	a1,0x2
ffffffffc0200166:	aca58593          	addi	a1,a1,-1334 # ffffffffc0201c2c <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	b5650513          	addi	a0,a0,-1194 # ffffffffc0201cc0 <etext+0x94>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	b6250513          	addi	a0,a0,-1182 # ffffffffc0201ce0 <etext+0xb4>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2e658593          	addi	a1,a1,742 # ffffffffc0206470 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0201d00 <etext+0xd4>
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
ffffffffc02001c4:	b6050513          	addi	a0,a0,-1184 # ffffffffc0201d20 <etext+0xf4>
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
ffffffffc02001d4:	a8060613          	addi	a2,a2,-1408 # ffffffffc0201c50 <etext+0x24>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0201c68 <etext+0x3c>
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
ffffffffc02001f0:	c4460613          	addi	a2,a2,-956 # ffffffffc0201e30 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	c5c58593          	addi	a1,a1,-932 # ffffffffc0201e50 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	c5c50513          	addi	a0,a0,-932 # ffffffffc0201e58 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	c5e60613          	addi	a2,a2,-930 # ffffffffc0201e68 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	c7e58593          	addi	a1,a1,-898 # ffffffffc0201e90 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	c3e50513          	addi	a0,a0,-962 # ffffffffc0201e58 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	c7a60613          	addi	a2,a2,-902 # ffffffffc0201ea0 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	c9258593          	addi	a1,a1,-878 # ffffffffc0201ec0 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	c2250513          	addi	a0,a0,-990 # ffffffffc0201e58 <commands+0x108>
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
ffffffffc0200274:	b2850513          	addi	a0,a0,-1240 # ffffffffc0201d98 <commands+0x48>
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
ffffffffc0200296:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0201dc0 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00002c97          	auipc	s9,0x2
ffffffffc02002ac:	aa8c8c93          	addi	s9,s9,-1368 # ffffffffc0201d50 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	b3898993          	addi	s3,s3,-1224 # ffffffffc0201de8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	b3890913          	addi	s2,s2,-1224 # ffffffffc0201df0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	b36b0b13          	addi	s6,s6,-1226 # ffffffffc0201df8 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	b86a8a93          	addi	s5,s5,-1146 # ffffffffc0201e50 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	7c2010ef          	jal	ra,ffffffffc0201a98 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	115010ef          	jal	ra,ffffffffc0201bfc <strchr>
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
ffffffffc0200302:	a52d0d13          	addi	s10,s10,-1454 # ffffffffc0201d50 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	0c7010ef          	jal	ra,ffffffffc0201bd2 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	0b3010ef          	jal	ra,ffffffffc0201bd2 <strcmp>
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
ffffffffc0200386:	077010ef          	jal	ra,ffffffffc0201bfc <strchr>
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
ffffffffc02003a2:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0201e18 <commands+0xc8>
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
ffffffffc02003e2:	af250513          	addi	a0,a0,-1294 # ffffffffc0201ed0 <commands+0x180>
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
ffffffffc02003f8:	95450513          	addi	a0,a0,-1708 # ffffffffc0201d48 <etext+0x11c>
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
ffffffffc0200424:	74e010ef          	jal	ra,ffffffffc0201b72 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	abe50513          	addi	a0,a0,-1346 # ffffffffc0201ef0 <commands+0x1a0>
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
ffffffffc020044c:	7260106f          	j	ffffffffc0201b72 <sbi_set_timer>

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
ffffffffc0200456:	7000106f          	j	ffffffffc0201b56 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	7340106f          	j	ffffffffc0201b8e <sbi_console_getchar>

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
ffffffffc0200472:	39278793          	addi	a5,a5,914 # ffffffffc0200800 <__alltraps>
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
ffffffffc0200488:	c1450513          	addi	a0,a0,-1004 # ffffffffc0202098 <commands+0x348>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	c1c50513          	addi	a0,a0,-996 # ffffffffc02020b0 <commands+0x360>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	c2650513          	addi	a0,a0,-986 # ffffffffc02020c8 <commands+0x378>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	c3050513          	addi	a0,a0,-976 # ffffffffc02020e0 <commands+0x390>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	c3a50513          	addi	a0,a0,-966 # ffffffffc02020f8 <commands+0x3a8>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	c4450513          	addi	a0,a0,-956 # ffffffffc0202110 <commands+0x3c0>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	c4e50513          	addi	a0,a0,-946 # ffffffffc0202128 <commands+0x3d8>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	c5850513          	addi	a0,a0,-936 # ffffffffc0202140 <commands+0x3f0>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	c6250513          	addi	a0,a0,-926 # ffffffffc0202158 <commands+0x408>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	c6c50513          	addi	a0,a0,-916 # ffffffffc0202170 <commands+0x420>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	c7650513          	addi	a0,a0,-906 # ffffffffc0202188 <commands+0x438>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	c8050513          	addi	a0,a0,-896 # ffffffffc02021a0 <commands+0x450>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	c8a50513          	addi	a0,a0,-886 # ffffffffc02021b8 <commands+0x468>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	c9450513          	addi	a0,a0,-876 # ffffffffc02021d0 <commands+0x480>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	c9e50513          	addi	a0,a0,-866 # ffffffffc02021e8 <commands+0x498>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	ca850513          	addi	a0,a0,-856 # ffffffffc0202200 <commands+0x4b0>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	cb250513          	addi	a0,a0,-846 # ffffffffc0202218 <commands+0x4c8>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	cbc50513          	addi	a0,a0,-836 # ffffffffc0202230 <commands+0x4e0>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	cc650513          	addi	a0,a0,-826 # ffffffffc0202248 <commands+0x4f8>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	cd050513          	addi	a0,a0,-816 # ffffffffc0202260 <commands+0x510>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	cda50513          	addi	a0,a0,-806 # ffffffffc0202278 <commands+0x528>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	ce450513          	addi	a0,a0,-796 # ffffffffc0202290 <commands+0x540>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	cee50513          	addi	a0,a0,-786 # ffffffffc02022a8 <commands+0x558>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	cf850513          	addi	a0,a0,-776 # ffffffffc02022c0 <commands+0x570>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	d0250513          	addi	a0,a0,-766 # ffffffffc02022d8 <commands+0x588>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	d0c50513          	addi	a0,a0,-756 # ffffffffc02022f0 <commands+0x5a0>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	d1650513          	addi	a0,a0,-746 # ffffffffc0202308 <commands+0x5b8>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	d2050513          	addi	a0,a0,-736 # ffffffffc0202320 <commands+0x5d0>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	d2a50513          	addi	a0,a0,-726 # ffffffffc0202338 <commands+0x5e8>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	d3450513          	addi	a0,a0,-716 # ffffffffc0202350 <commands+0x600>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	d3e50513          	addi	a0,a0,-706 # ffffffffc0202368 <commands+0x618>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	d4450513          	addi	a0,a0,-700 # ffffffffc0202380 <commands+0x630>
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
ffffffffc0200656:	d4650513          	addi	a0,a0,-698 # ffffffffc0202398 <commands+0x648>
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
ffffffffc020066e:	d4650513          	addi	a0,a0,-698 # ffffffffc02023b0 <commands+0x660>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	d4e50513          	addi	a0,a0,-690 # ffffffffc02023c8 <commands+0x678>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	d5650513          	addi	a0,a0,-682 # ffffffffc02023e0 <commands+0x690>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	d5a50513          	addi	a0,a0,-678 # ffffffffc02023f8 <commands+0x6a8>
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
ffffffffc02006bc:	00002717          	auipc	a4,0x2
ffffffffc02006c0:	85070713          	addi	a4,a4,-1968 # ffffffffc0201f0c <commands+0x1bc>
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
ffffffffc02006d2:	96250513          	addi	a0,a0,-1694 # ffffffffc0202030 <commands+0x2e0>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00002517          	auipc	a0,0x2
ffffffffc02006de:	93650513          	addi	a0,a0,-1738 # ffffffffc0202010 <commands+0x2c0>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00002517          	auipc	a0,0x2
ffffffffc02006ea:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0201fd0 <commands+0x280>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00002517          	auipc	a0,0x2
ffffffffc02006f6:	95e50513          	addi	a0,a0,-1698 # ffffffffc0202050 <commands+0x300>
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
ffffffffc020072e:	94e50513          	addi	a0,a0,-1714 # ffffffffc0202078 <commands+0x328>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00002517          	auipc	a0,0x2
ffffffffc020073a:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0201ff0 <commands+0x2a0>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00002517          	auipc	a0,0x2
ffffffffc0200750:	91c50513          	addi	a0,a0,-1764 # ffffffffc0202068 <commands+0x318>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	472d                	li	a4,11
ffffffffc0200760:	02f76863          	bltu	a4,a5,ffffffffc0200790 <exception_handler+0x36>
ffffffffc0200764:	4705                	li	a4,1
ffffffffc0200766:	00f71733          	sll	a4,a4,a5
ffffffffc020076a:	6785                	lui	a5,0x1
ffffffffc020076c:	17cd                	addi	a5,a5,-13
ffffffffc020076e:	8ff9                	and	a5,a5,a4
ffffffffc0200770:	ef99                	bnez	a5,ffffffffc020078e <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
ffffffffc0200772:	1141                	addi	sp,sp,-16
ffffffffc0200774:	e022                	sd	s0,0(sp)
ffffffffc0200776:	e406                	sd	ra,8(sp)
ffffffffc0200778:	00877793          	andi	a5,a4,8
ffffffffc020077c:	842a                	mv	s0,a0
ffffffffc020077e:	e3b1                	bnez	a5,ffffffffc02007c2 <exception_handler+0x68>
ffffffffc0200780:	8b11                	andi	a4,a4,4
ffffffffc0200782:	eb09                	bnez	a4,ffffffffc0200794 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200784:	6402                	ld	s0,0(sp)
ffffffffc0200786:	60a2                	ld	ra,8(sp)
ffffffffc0200788:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc020078a:	ec1ff06f          	j	ffffffffc020064a <print_trapframe>
ffffffffc020078e:	8082                	ret
ffffffffc0200790:	ebbff06f          	j	ffffffffc020064a <print_trapframe>
            cprintf("Exception type:Illegal instruction\n");
ffffffffc0200794:	00001517          	auipc	a0,0x1
ffffffffc0200798:	7ac50513          	addi	a0,a0,1964 # ffffffffc0201f40 <commands+0x1f0>
ffffffffc020079c:	91bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc02007a0:	10843583          	ld	a1,264(s0)
ffffffffc02007a4:	00001517          	auipc	a0,0x1
ffffffffc02007a8:	7c450513          	addi	a0,a0,1988 # ffffffffc0201f68 <commands+0x218>
ffffffffc02007ac:	90bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            tf->epc += 4;
ffffffffc02007b0:	10843783          	ld	a5,264(s0)
}
ffffffffc02007b4:	60a2                	ld	ra,8(sp)
            tf->epc += 4;
ffffffffc02007b6:	0791                	addi	a5,a5,4
ffffffffc02007b8:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007bc:	6402                	ld	s0,0(sp)
ffffffffc02007be:	0141                	addi	sp,sp,16
ffffffffc02007c0:	8082                	ret
            cprintf("Exception type: breakpoint\n");
ffffffffc02007c2:	00001517          	auipc	a0,0x1
ffffffffc02007c6:	7ce50513          	addi	a0,a0,1998 # ffffffffc0201f90 <commands+0x240>
ffffffffc02007ca:	8edff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc02007ce:	10843583          	ld	a1,264(s0)
ffffffffc02007d2:	00001517          	auipc	a0,0x1
ffffffffc02007d6:	7de50513          	addi	a0,a0,2014 # ffffffffc0201fb0 <commands+0x260>
ffffffffc02007da:	8ddff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            tf->epc += 4;
ffffffffc02007de:	10843783          	ld	a5,264(s0)
}
ffffffffc02007e2:	60a2                	ld	ra,8(sp)
            tf->epc += 4;
ffffffffc02007e4:	0791                	addi	a5,a5,4
ffffffffc02007e6:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007ea:	6402                	ld	s0,0(sp)
ffffffffc02007ec:	0141                	addi	sp,sp,16
ffffffffc02007ee:	8082                	ret

ffffffffc02007f0 <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc02007f0:	11853783          	ld	a5,280(a0)
ffffffffc02007f4:	0007c463          	bltz	a5,ffffffffc02007fc <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02007f8:	f63ff06f          	j	ffffffffc020075a <exception_handler>
        interrupt_handler(tf);
ffffffffc02007fc:	eb1ff06f          	j	ffffffffc02006ac <interrupt_handler>

ffffffffc0200800 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200800:	14011073          	csrw	sscratch,sp
ffffffffc0200804:	712d                	addi	sp,sp,-288
ffffffffc0200806:	e002                	sd	zero,0(sp)
ffffffffc0200808:	e406                	sd	ra,8(sp)
ffffffffc020080a:	ec0e                	sd	gp,24(sp)
ffffffffc020080c:	f012                	sd	tp,32(sp)
ffffffffc020080e:	f416                	sd	t0,40(sp)
ffffffffc0200810:	f81a                	sd	t1,48(sp)
ffffffffc0200812:	fc1e                	sd	t2,56(sp)
ffffffffc0200814:	e0a2                	sd	s0,64(sp)
ffffffffc0200816:	e4a6                	sd	s1,72(sp)
ffffffffc0200818:	e8aa                	sd	a0,80(sp)
ffffffffc020081a:	ecae                	sd	a1,88(sp)
ffffffffc020081c:	f0b2                	sd	a2,96(sp)
ffffffffc020081e:	f4b6                	sd	a3,104(sp)
ffffffffc0200820:	f8ba                	sd	a4,112(sp)
ffffffffc0200822:	fcbe                	sd	a5,120(sp)
ffffffffc0200824:	e142                	sd	a6,128(sp)
ffffffffc0200826:	e546                	sd	a7,136(sp)
ffffffffc0200828:	e94a                	sd	s2,144(sp)
ffffffffc020082a:	ed4e                	sd	s3,152(sp)
ffffffffc020082c:	f152                	sd	s4,160(sp)
ffffffffc020082e:	f556                	sd	s5,168(sp)
ffffffffc0200830:	f95a                	sd	s6,176(sp)
ffffffffc0200832:	fd5e                	sd	s7,184(sp)
ffffffffc0200834:	e1e2                	sd	s8,192(sp)
ffffffffc0200836:	e5e6                	sd	s9,200(sp)
ffffffffc0200838:	e9ea                	sd	s10,208(sp)
ffffffffc020083a:	edee                	sd	s11,216(sp)
ffffffffc020083c:	f1f2                	sd	t3,224(sp)
ffffffffc020083e:	f5f6                	sd	t4,232(sp)
ffffffffc0200840:	f9fa                	sd	t5,240(sp)
ffffffffc0200842:	fdfe                	sd	t6,248(sp)
ffffffffc0200844:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200848:	100024f3          	csrr	s1,sstatus
ffffffffc020084c:	14102973          	csrr	s2,sepc
ffffffffc0200850:	143029f3          	csrr	s3,stval
ffffffffc0200854:	14202a73          	csrr	s4,scause
ffffffffc0200858:	e822                	sd	s0,16(sp)
ffffffffc020085a:	e226                	sd	s1,256(sp)
ffffffffc020085c:	e64a                	sd	s2,264(sp)
ffffffffc020085e:	ea4e                	sd	s3,272(sp)
ffffffffc0200860:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200862:	850a                	mv	a0,sp
    jal trap
ffffffffc0200864:	f8dff0ef          	jal	ra,ffffffffc02007f0 <trap>

ffffffffc0200868 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200868:	6492                	ld	s1,256(sp)
ffffffffc020086a:	6932                	ld	s2,264(sp)
ffffffffc020086c:	10049073          	csrw	sstatus,s1
ffffffffc0200870:	14191073          	csrw	sepc,s2
ffffffffc0200874:	60a2                	ld	ra,8(sp)
ffffffffc0200876:	61e2                	ld	gp,24(sp)
ffffffffc0200878:	7202                	ld	tp,32(sp)
ffffffffc020087a:	72a2                	ld	t0,40(sp)
ffffffffc020087c:	7342                	ld	t1,48(sp)
ffffffffc020087e:	73e2                	ld	t2,56(sp)
ffffffffc0200880:	6406                	ld	s0,64(sp)
ffffffffc0200882:	64a6                	ld	s1,72(sp)
ffffffffc0200884:	6546                	ld	a0,80(sp)
ffffffffc0200886:	65e6                	ld	a1,88(sp)
ffffffffc0200888:	7606                	ld	a2,96(sp)
ffffffffc020088a:	76a6                	ld	a3,104(sp)
ffffffffc020088c:	7746                	ld	a4,112(sp)
ffffffffc020088e:	77e6                	ld	a5,120(sp)
ffffffffc0200890:	680a                	ld	a6,128(sp)
ffffffffc0200892:	68aa                	ld	a7,136(sp)
ffffffffc0200894:	694a                	ld	s2,144(sp)
ffffffffc0200896:	69ea                	ld	s3,152(sp)
ffffffffc0200898:	7a0a                	ld	s4,160(sp)
ffffffffc020089a:	7aaa                	ld	s5,168(sp)
ffffffffc020089c:	7b4a                	ld	s6,176(sp)
ffffffffc020089e:	7bea                	ld	s7,184(sp)
ffffffffc02008a0:	6c0e                	ld	s8,192(sp)
ffffffffc02008a2:	6cae                	ld	s9,200(sp)
ffffffffc02008a4:	6d4e                	ld	s10,208(sp)
ffffffffc02008a6:	6dee                	ld	s11,216(sp)
ffffffffc02008a8:	7e0e                	ld	t3,224(sp)
ffffffffc02008aa:	7eae                	ld	t4,232(sp)
ffffffffc02008ac:	7f4e                	ld	t5,240(sp)
ffffffffc02008ae:	7fee                	ld	t6,248(sp)
ffffffffc02008b0:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02008b2:	10200073          	sret

ffffffffc02008b6 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02008b6:	00006797          	auipc	a5,0x6
ffffffffc02008ba:	b8278793          	addi	a5,a5,-1150 # ffffffffc0206438 <free_area>
ffffffffc02008be:	e79c                	sd	a5,8(a5)
ffffffffc02008c0:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02008c2:	0007a823          	sw	zero,16(a5)
}
ffffffffc02008c6:	8082                	ret

ffffffffc02008c8 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02008c8:	00006517          	auipc	a0,0x6
ffffffffc02008cc:	b8056503          	lwu	a0,-1152(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc02008d0:	8082                	ret

ffffffffc02008d2 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc02008d2:	715d                	addi	sp,sp,-80
ffffffffc02008d4:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02008d6:	00006917          	auipc	s2,0x6
ffffffffc02008da:	b6290913          	addi	s2,s2,-1182 # ffffffffc0206438 <free_area>
ffffffffc02008de:	00893783          	ld	a5,8(s2)
ffffffffc02008e2:	e486                	sd	ra,72(sp)
ffffffffc02008e4:	e0a2                	sd	s0,64(sp)
ffffffffc02008e6:	fc26                	sd	s1,56(sp)
ffffffffc02008e8:	f44e                	sd	s3,40(sp)
ffffffffc02008ea:	f052                	sd	s4,32(sp)
ffffffffc02008ec:	ec56                	sd	s5,24(sp)
ffffffffc02008ee:	e85a                	sd	s6,16(sp)
ffffffffc02008f0:	e45e                	sd	s7,8(sp)
ffffffffc02008f2:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02008f4:	31278f63          	beq	a5,s2,ffffffffc0200c12 <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02008f8:	ff07b703          	ld	a4,-16(a5)
ffffffffc02008fc:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02008fe:	8b05                	andi	a4,a4,1
ffffffffc0200900:	30070d63          	beqz	a4,ffffffffc0200c1a <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200904:	4401                	li	s0,0
ffffffffc0200906:	4481                	li	s1,0
ffffffffc0200908:	a031                	j	ffffffffc0200914 <default_check+0x42>
ffffffffc020090a:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020090e:	8b09                	andi	a4,a4,2
ffffffffc0200910:	30070563          	beqz	a4,ffffffffc0200c1a <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200914:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200918:	679c                	ld	a5,8(a5)
ffffffffc020091a:	2485                	addiw	s1,s1,1
ffffffffc020091c:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020091e:	ff2796e3          	bne	a5,s2,ffffffffc020090a <default_check+0x38>
ffffffffc0200922:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200924:	38f000ef          	jal	ra,ffffffffc02014b2 <nr_free_pages>
ffffffffc0200928:	75351963          	bne	a0,s3,ffffffffc020107a <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020092c:	4505                	li	a0,1
ffffffffc020092e:	2fb000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200932:	8a2a                	mv	s4,a0
ffffffffc0200934:	48050363          	beqz	a0,ffffffffc0200dba <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200938:	4505                	li	a0,1
ffffffffc020093a:	2ef000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc020093e:	89aa                	mv	s3,a0
ffffffffc0200940:	74050d63          	beqz	a0,ffffffffc020109a <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200944:	4505                	li	a0,1
ffffffffc0200946:	2e3000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc020094a:	8aaa                	mv	s5,a0
ffffffffc020094c:	4e050763          	beqz	a0,ffffffffc0200e3a <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200950:	2f3a0563          	beq	s4,s3,ffffffffc0200c3a <default_check+0x368>
ffffffffc0200954:	2eaa0363          	beq	s4,a0,ffffffffc0200c3a <default_check+0x368>
ffffffffc0200958:	2ea98163          	beq	s3,a0,ffffffffc0200c3a <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020095c:	000a2783          	lw	a5,0(s4)
ffffffffc0200960:	2e079d63          	bnez	a5,ffffffffc0200c5a <default_check+0x388>
ffffffffc0200964:	0009a783          	lw	a5,0(s3)
ffffffffc0200968:	2e079963          	bnez	a5,ffffffffc0200c5a <default_check+0x388>
ffffffffc020096c:	411c                	lw	a5,0(a0)
ffffffffc020096e:	2e079663          	bnez	a5,ffffffffc0200c5a <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200972:	00006797          	auipc	a5,0x6
ffffffffc0200976:	af678793          	addi	a5,a5,-1290 # ffffffffc0206468 <pages>
ffffffffc020097a:	639c                	ld	a5,0(a5)
ffffffffc020097c:	00002717          	auipc	a4,0x2
ffffffffc0200980:	a9470713          	addi	a4,a4,-1388 # ffffffffc0202410 <commands+0x6c0>
ffffffffc0200984:	630c                	ld	a1,0(a4)
ffffffffc0200986:	40fa0733          	sub	a4,s4,a5
ffffffffc020098a:	870d                	srai	a4,a4,0x3
ffffffffc020098c:	02b70733          	mul	a4,a4,a1
ffffffffc0200990:	00002697          	auipc	a3,0x2
ffffffffc0200994:	1f068693          	addi	a3,a3,496 # ffffffffc0202b80 <nbase>
ffffffffc0200998:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020099a:	00006697          	auipc	a3,0x6
ffffffffc020099e:	a7e68693          	addi	a3,a3,-1410 # ffffffffc0206418 <npage>
ffffffffc02009a2:	6294                	ld	a3,0(a3)
ffffffffc02009a4:	06b2                	slli	a3,a3,0xc
ffffffffc02009a6:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009a8:	0732                	slli	a4,a4,0xc
ffffffffc02009aa:	2cd77863          	bleu	a3,a4,ffffffffc0200c7a <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009ae:	40f98733          	sub	a4,s3,a5
ffffffffc02009b2:	870d                	srai	a4,a4,0x3
ffffffffc02009b4:	02b70733          	mul	a4,a4,a1
ffffffffc02009b8:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009ba:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009bc:	4ed77f63          	bleu	a3,a4,ffffffffc0200eba <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009c0:	40f507b3          	sub	a5,a0,a5
ffffffffc02009c4:	878d                	srai	a5,a5,0x3
ffffffffc02009c6:	02b787b3          	mul	a5,a5,a1
ffffffffc02009ca:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009cc:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02009ce:	34d7f663          	bleu	a3,a5,ffffffffc0200d1a <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc02009d2:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009d4:	00093c03          	ld	s8,0(s2)
ffffffffc02009d8:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02009dc:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc02009e0:	00006797          	auipc	a5,0x6
ffffffffc02009e4:	a727b023          	sd	s2,-1440(a5) # ffffffffc0206440 <free_area+0x8>
ffffffffc02009e8:	00006797          	auipc	a5,0x6
ffffffffc02009ec:	a527b823          	sd	s2,-1456(a5) # ffffffffc0206438 <free_area>
    nr_free = 0;
ffffffffc02009f0:	00006797          	auipc	a5,0x6
ffffffffc02009f4:	a407ac23          	sw	zero,-1448(a5) # ffffffffc0206448 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02009f8:	231000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc02009fc:	2e051f63          	bnez	a0,ffffffffc0200cfa <default_check+0x428>
    free_page(p0);
ffffffffc0200a00:	4585                	li	a1,1
ffffffffc0200a02:	8552                	mv	a0,s4
ffffffffc0200a04:	269000ef          	jal	ra,ffffffffc020146c <free_pages>
    free_page(p1);
ffffffffc0200a08:	4585                	li	a1,1
ffffffffc0200a0a:	854e                	mv	a0,s3
ffffffffc0200a0c:	261000ef          	jal	ra,ffffffffc020146c <free_pages>
    free_page(p2);
ffffffffc0200a10:	4585                	li	a1,1
ffffffffc0200a12:	8556                	mv	a0,s5
ffffffffc0200a14:	259000ef          	jal	ra,ffffffffc020146c <free_pages>
    assert(nr_free == 3);
ffffffffc0200a18:	01092703          	lw	a4,16(s2)
ffffffffc0200a1c:	478d                	li	a5,3
ffffffffc0200a1e:	2af71e63          	bne	a4,a5,ffffffffc0200cda <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a22:	4505                	li	a0,1
ffffffffc0200a24:	205000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200a28:	89aa                	mv	s3,a0
ffffffffc0200a2a:	28050863          	beqz	a0,ffffffffc0200cba <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a2e:	4505                	li	a0,1
ffffffffc0200a30:	1f9000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200a34:	8aaa                	mv	s5,a0
ffffffffc0200a36:	3e050263          	beqz	a0,ffffffffc0200e1a <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a3a:	4505                	li	a0,1
ffffffffc0200a3c:	1ed000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200a40:	8a2a                	mv	s4,a0
ffffffffc0200a42:	3a050c63          	beqz	a0,ffffffffc0200dfa <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200a46:	4505                	li	a0,1
ffffffffc0200a48:	1e1000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200a4c:	38051763          	bnez	a0,ffffffffc0200dda <default_check+0x508>
    free_page(p0);
ffffffffc0200a50:	4585                	li	a1,1
ffffffffc0200a52:	854e                	mv	a0,s3
ffffffffc0200a54:	219000ef          	jal	ra,ffffffffc020146c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a58:	00893783          	ld	a5,8(s2)
ffffffffc0200a5c:	23278f63          	beq	a5,s2,ffffffffc0200c9a <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200a60:	4505                	li	a0,1
ffffffffc0200a62:	1c7000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200a66:	32a99a63          	bne	s3,a0,ffffffffc0200d9a <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200a6a:	4505                	li	a0,1
ffffffffc0200a6c:	1bd000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200a70:	30051563          	bnez	a0,ffffffffc0200d7a <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200a74:	01092783          	lw	a5,16(s2)
ffffffffc0200a78:	2e079163          	bnez	a5,ffffffffc0200d5a <default_check+0x488>
    free_page(p);
ffffffffc0200a7c:	854e                	mv	a0,s3
ffffffffc0200a7e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200a80:	00006797          	auipc	a5,0x6
ffffffffc0200a84:	9b87bc23          	sd	s8,-1608(a5) # ffffffffc0206438 <free_area>
ffffffffc0200a88:	00006797          	auipc	a5,0x6
ffffffffc0200a8c:	9b77bc23          	sd	s7,-1608(a5) # ffffffffc0206440 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200a90:	00006797          	auipc	a5,0x6
ffffffffc0200a94:	9b67ac23          	sw	s6,-1608(a5) # ffffffffc0206448 <free_area+0x10>
    free_page(p);
ffffffffc0200a98:	1d5000ef          	jal	ra,ffffffffc020146c <free_pages>
    free_page(p1);
ffffffffc0200a9c:	4585                	li	a1,1
ffffffffc0200a9e:	8556                	mv	a0,s5
ffffffffc0200aa0:	1cd000ef          	jal	ra,ffffffffc020146c <free_pages>
    free_page(p2);
ffffffffc0200aa4:	4585                	li	a1,1
ffffffffc0200aa6:	8552                	mv	a0,s4
ffffffffc0200aa8:	1c5000ef          	jal	ra,ffffffffc020146c <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200aac:	4515                	li	a0,5
ffffffffc0200aae:	17b000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200ab2:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200ab4:	28050363          	beqz	a0,ffffffffc0200d3a <default_check+0x468>
ffffffffc0200ab8:	651c                	ld	a5,8(a0)
ffffffffc0200aba:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200abc:	8b85                	andi	a5,a5,1
ffffffffc0200abe:	54079e63          	bnez	a5,ffffffffc020101a <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200ac2:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ac4:	00093b03          	ld	s6,0(s2)
ffffffffc0200ac8:	00893a83          	ld	s5,8(s2)
ffffffffc0200acc:	00006797          	auipc	a5,0x6
ffffffffc0200ad0:	9727b623          	sd	s2,-1684(a5) # ffffffffc0206438 <free_area>
ffffffffc0200ad4:	00006797          	auipc	a5,0x6
ffffffffc0200ad8:	9727b623          	sd	s2,-1684(a5) # ffffffffc0206440 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200adc:	14d000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200ae0:	50051d63          	bnez	a0,ffffffffc0200ffa <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200ae4:	05098a13          	addi	s4,s3,80
ffffffffc0200ae8:	8552                	mv	a0,s4
ffffffffc0200aea:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200aec:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200af0:	00006797          	auipc	a5,0x6
ffffffffc0200af4:	9407ac23          	sw	zero,-1704(a5) # ffffffffc0206448 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200af8:	175000ef          	jal	ra,ffffffffc020146c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200afc:	4511                	li	a0,4
ffffffffc0200afe:	12b000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200b02:	4c051c63          	bnez	a0,ffffffffc0200fda <default_check+0x708>
ffffffffc0200b06:	0589b783          	ld	a5,88(s3)
ffffffffc0200b0a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200b0c:	8b85                	andi	a5,a5,1
ffffffffc0200b0e:	4a078663          	beqz	a5,ffffffffc0200fba <default_check+0x6e8>
ffffffffc0200b12:	0609a703          	lw	a4,96(s3)
ffffffffc0200b16:	478d                	li	a5,3
ffffffffc0200b18:	4af71163          	bne	a4,a5,ffffffffc0200fba <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200b1c:	450d                	li	a0,3
ffffffffc0200b1e:	10b000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200b22:	8c2a                	mv	s8,a0
ffffffffc0200b24:	46050b63          	beqz	a0,ffffffffc0200f9a <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200b28:	4505                	li	a0,1
ffffffffc0200b2a:	0ff000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200b2e:	44051663          	bnez	a0,ffffffffc0200f7a <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200b32:	438a1463          	bne	s4,s8,ffffffffc0200f5a <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200b36:	4585                	li	a1,1
ffffffffc0200b38:	854e                	mv	a0,s3
ffffffffc0200b3a:	133000ef          	jal	ra,ffffffffc020146c <free_pages>
    free_pages(p1, 3);
ffffffffc0200b3e:	458d                	li	a1,3
ffffffffc0200b40:	8552                	mv	a0,s4
ffffffffc0200b42:	12b000ef          	jal	ra,ffffffffc020146c <free_pages>
ffffffffc0200b46:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200b4a:	02898c13          	addi	s8,s3,40
ffffffffc0200b4e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200b50:	8b85                	andi	a5,a5,1
ffffffffc0200b52:	3e078463          	beqz	a5,ffffffffc0200f3a <default_check+0x668>
ffffffffc0200b56:	0109a703          	lw	a4,16(s3)
ffffffffc0200b5a:	4785                	li	a5,1
ffffffffc0200b5c:	3cf71f63          	bne	a4,a5,ffffffffc0200f3a <default_check+0x668>
ffffffffc0200b60:	008a3783          	ld	a5,8(s4)
ffffffffc0200b64:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200b66:	8b85                	andi	a5,a5,1
ffffffffc0200b68:	3a078963          	beqz	a5,ffffffffc0200f1a <default_check+0x648>
ffffffffc0200b6c:	010a2703          	lw	a4,16(s4)
ffffffffc0200b70:	478d                	li	a5,3
ffffffffc0200b72:	3af71463          	bne	a4,a5,ffffffffc0200f1a <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200b76:	4505                	li	a0,1
ffffffffc0200b78:	0b1000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200b7c:	36a99f63          	bne	s3,a0,ffffffffc0200efa <default_check+0x628>
    free_page(p0);
ffffffffc0200b80:	4585                	li	a1,1
ffffffffc0200b82:	0eb000ef          	jal	ra,ffffffffc020146c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200b86:	4509                	li	a0,2
ffffffffc0200b88:	0a1000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200b8c:	34aa1763          	bne	s4,a0,ffffffffc0200eda <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200b90:	4589                	li	a1,2
ffffffffc0200b92:	0db000ef          	jal	ra,ffffffffc020146c <free_pages>
    free_page(p2);
ffffffffc0200b96:	4585                	li	a1,1
ffffffffc0200b98:	8562                	mv	a0,s8
ffffffffc0200b9a:	0d3000ef          	jal	ra,ffffffffc020146c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b9e:	4515                	li	a0,5
ffffffffc0200ba0:	089000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200ba4:	89aa                	mv	s3,a0
ffffffffc0200ba6:	48050a63          	beqz	a0,ffffffffc020103a <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200baa:	4505                	li	a0,1
ffffffffc0200bac:	07d000ef          	jal	ra,ffffffffc0201428 <alloc_pages>
ffffffffc0200bb0:	2e051563          	bnez	a0,ffffffffc0200e9a <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200bb4:	01092783          	lw	a5,16(s2)
ffffffffc0200bb8:	2c079163          	bnez	a5,ffffffffc0200e7a <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200bbc:	4595                	li	a1,5
ffffffffc0200bbe:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200bc0:	00006797          	auipc	a5,0x6
ffffffffc0200bc4:	8977a423          	sw	s7,-1912(a5) # ffffffffc0206448 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200bc8:	00006797          	auipc	a5,0x6
ffffffffc0200bcc:	8767b823          	sd	s6,-1936(a5) # ffffffffc0206438 <free_area>
ffffffffc0200bd0:	00006797          	auipc	a5,0x6
ffffffffc0200bd4:	8757b823          	sd	s5,-1936(a5) # ffffffffc0206440 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200bd8:	095000ef          	jal	ra,ffffffffc020146c <free_pages>
    return listelm->next;
ffffffffc0200bdc:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200be0:	01278963          	beq	a5,s2,ffffffffc0200bf2 <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200be4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200be8:	679c                	ld	a5,8(a5)
ffffffffc0200bea:	34fd                	addiw	s1,s1,-1
ffffffffc0200bec:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bee:	ff279be3          	bne	a5,s2,ffffffffc0200be4 <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200bf2:	26049463          	bnez	s1,ffffffffc0200e5a <default_check+0x588>
    assert(total == 0);
ffffffffc0200bf6:	46041263          	bnez	s0,ffffffffc020105a <default_check+0x788>
}
ffffffffc0200bfa:	60a6                	ld	ra,72(sp)
ffffffffc0200bfc:	6406                	ld	s0,64(sp)
ffffffffc0200bfe:	74e2                	ld	s1,56(sp)
ffffffffc0200c00:	7942                	ld	s2,48(sp)
ffffffffc0200c02:	79a2                	ld	s3,40(sp)
ffffffffc0200c04:	7a02                	ld	s4,32(sp)
ffffffffc0200c06:	6ae2                	ld	s5,24(sp)
ffffffffc0200c08:	6b42                	ld	s6,16(sp)
ffffffffc0200c0a:	6ba2                	ld	s7,8(sp)
ffffffffc0200c0c:	6c02                	ld	s8,0(sp)
ffffffffc0200c0e:	6161                	addi	sp,sp,80
ffffffffc0200c10:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c12:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200c14:	4401                	li	s0,0
ffffffffc0200c16:	4481                	li	s1,0
ffffffffc0200c18:	b331                	j	ffffffffc0200924 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200c1a:	00001697          	auipc	a3,0x1
ffffffffc0200c1e:	7fe68693          	addi	a3,a3,2046 # ffffffffc0202418 <commands+0x6c8>
ffffffffc0200c22:	00002617          	auipc	a2,0x2
ffffffffc0200c26:	80660613          	addi	a2,a2,-2042 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200c2a:	0ef00593          	li	a1,239
ffffffffc0200c2e:	00002517          	auipc	a0,0x2
ffffffffc0200c32:	81250513          	addi	a0,a0,-2030 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200c36:	f76ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c3a:	00002697          	auipc	a3,0x2
ffffffffc0200c3e:	89e68693          	addi	a3,a3,-1890 # ffffffffc02024d8 <commands+0x788>
ffffffffc0200c42:	00001617          	auipc	a2,0x1
ffffffffc0200c46:	7e660613          	addi	a2,a2,2022 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200c4a:	0bc00593          	li	a1,188
ffffffffc0200c4e:	00001517          	auipc	a0,0x1
ffffffffc0200c52:	7f250513          	addi	a0,a0,2034 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200c56:	f56ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c5a:	00002697          	auipc	a3,0x2
ffffffffc0200c5e:	8a668693          	addi	a3,a3,-1882 # ffffffffc0202500 <commands+0x7b0>
ffffffffc0200c62:	00001617          	auipc	a2,0x1
ffffffffc0200c66:	7c660613          	addi	a2,a2,1990 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200c6a:	0bd00593          	li	a1,189
ffffffffc0200c6e:	00001517          	auipc	a0,0x1
ffffffffc0200c72:	7d250513          	addi	a0,a0,2002 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200c76:	f36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c7a:	00002697          	auipc	a3,0x2
ffffffffc0200c7e:	8c668693          	addi	a3,a3,-1850 # ffffffffc0202540 <commands+0x7f0>
ffffffffc0200c82:	00001617          	auipc	a2,0x1
ffffffffc0200c86:	7a660613          	addi	a2,a2,1958 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200c8a:	0bf00593          	li	a1,191
ffffffffc0200c8e:	00001517          	auipc	a0,0x1
ffffffffc0200c92:	7b250513          	addi	a0,a0,1970 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200c96:	f16ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c9a:	00002697          	auipc	a3,0x2
ffffffffc0200c9e:	92e68693          	addi	a3,a3,-1746 # ffffffffc02025c8 <commands+0x878>
ffffffffc0200ca2:	00001617          	auipc	a2,0x1
ffffffffc0200ca6:	78660613          	addi	a2,a2,1926 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200caa:	0d800593          	li	a1,216
ffffffffc0200cae:	00001517          	auipc	a0,0x1
ffffffffc0200cb2:	79250513          	addi	a0,a0,1938 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200cb6:	ef6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cba:	00001697          	auipc	a3,0x1
ffffffffc0200cbe:	7be68693          	addi	a3,a3,1982 # ffffffffc0202478 <commands+0x728>
ffffffffc0200cc2:	00001617          	auipc	a2,0x1
ffffffffc0200cc6:	76660613          	addi	a2,a2,1894 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200cca:	0d100593          	li	a1,209
ffffffffc0200cce:	00001517          	auipc	a0,0x1
ffffffffc0200cd2:	77250513          	addi	a0,a0,1906 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200cd6:	ed6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200cda:	00002697          	auipc	a3,0x2
ffffffffc0200cde:	8de68693          	addi	a3,a3,-1826 # ffffffffc02025b8 <commands+0x868>
ffffffffc0200ce2:	00001617          	auipc	a2,0x1
ffffffffc0200ce6:	74660613          	addi	a2,a2,1862 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200cea:	0cf00593          	li	a1,207
ffffffffc0200cee:	00001517          	auipc	a0,0x1
ffffffffc0200cf2:	75250513          	addi	a0,a0,1874 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200cf6:	eb6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200cfa:	00002697          	auipc	a3,0x2
ffffffffc0200cfe:	8a668693          	addi	a3,a3,-1882 # ffffffffc02025a0 <commands+0x850>
ffffffffc0200d02:	00001617          	auipc	a2,0x1
ffffffffc0200d06:	72660613          	addi	a2,a2,1830 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200d0a:	0ca00593          	li	a1,202
ffffffffc0200d0e:	00001517          	auipc	a0,0x1
ffffffffc0200d12:	73250513          	addi	a0,a0,1842 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200d16:	e96ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d1a:	00002697          	auipc	a3,0x2
ffffffffc0200d1e:	86668693          	addi	a3,a3,-1946 # ffffffffc0202580 <commands+0x830>
ffffffffc0200d22:	00001617          	auipc	a2,0x1
ffffffffc0200d26:	70660613          	addi	a2,a2,1798 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200d2a:	0c100593          	li	a1,193
ffffffffc0200d2e:	00001517          	auipc	a0,0x1
ffffffffc0200d32:	71250513          	addi	a0,a0,1810 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200d36:	e76ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200d3a:	00002697          	auipc	a3,0x2
ffffffffc0200d3e:	8d668693          	addi	a3,a3,-1834 # ffffffffc0202610 <commands+0x8c0>
ffffffffc0200d42:	00001617          	auipc	a2,0x1
ffffffffc0200d46:	6e660613          	addi	a2,a2,1766 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200d4a:	0f700593          	li	a1,247
ffffffffc0200d4e:	00001517          	auipc	a0,0x1
ffffffffc0200d52:	6f250513          	addi	a0,a0,1778 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200d56:	e56ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200d5a:	00002697          	auipc	a3,0x2
ffffffffc0200d5e:	8a668693          	addi	a3,a3,-1882 # ffffffffc0202600 <commands+0x8b0>
ffffffffc0200d62:	00001617          	auipc	a2,0x1
ffffffffc0200d66:	6c660613          	addi	a2,a2,1734 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200d6a:	0de00593          	li	a1,222
ffffffffc0200d6e:	00001517          	auipc	a0,0x1
ffffffffc0200d72:	6d250513          	addi	a0,a0,1746 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200d76:	e36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d7a:	00002697          	auipc	a3,0x2
ffffffffc0200d7e:	82668693          	addi	a3,a3,-2010 # ffffffffc02025a0 <commands+0x850>
ffffffffc0200d82:	00001617          	auipc	a2,0x1
ffffffffc0200d86:	6a660613          	addi	a2,a2,1702 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200d8a:	0dc00593          	li	a1,220
ffffffffc0200d8e:	00001517          	auipc	a0,0x1
ffffffffc0200d92:	6b250513          	addi	a0,a0,1714 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200d96:	e16ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200d9a:	00002697          	auipc	a3,0x2
ffffffffc0200d9e:	84668693          	addi	a3,a3,-1978 # ffffffffc02025e0 <commands+0x890>
ffffffffc0200da2:	00001617          	auipc	a2,0x1
ffffffffc0200da6:	68660613          	addi	a2,a2,1670 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200daa:	0db00593          	li	a1,219
ffffffffc0200dae:	00001517          	auipc	a0,0x1
ffffffffc0200db2:	69250513          	addi	a0,a0,1682 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200db6:	df6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200dba:	00001697          	auipc	a3,0x1
ffffffffc0200dbe:	6be68693          	addi	a3,a3,1726 # ffffffffc0202478 <commands+0x728>
ffffffffc0200dc2:	00001617          	auipc	a2,0x1
ffffffffc0200dc6:	66660613          	addi	a2,a2,1638 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200dca:	0b800593          	li	a1,184
ffffffffc0200dce:	00001517          	auipc	a0,0x1
ffffffffc0200dd2:	67250513          	addi	a0,a0,1650 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200dd6:	dd6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200dda:	00001697          	auipc	a3,0x1
ffffffffc0200dde:	7c668693          	addi	a3,a3,1990 # ffffffffc02025a0 <commands+0x850>
ffffffffc0200de2:	00001617          	auipc	a2,0x1
ffffffffc0200de6:	64660613          	addi	a2,a2,1606 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200dea:	0d500593          	li	a1,213
ffffffffc0200dee:	00001517          	auipc	a0,0x1
ffffffffc0200df2:	65250513          	addi	a0,a0,1618 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200df6:	db6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200dfa:	00001697          	auipc	a3,0x1
ffffffffc0200dfe:	6be68693          	addi	a3,a3,1726 # ffffffffc02024b8 <commands+0x768>
ffffffffc0200e02:	00001617          	auipc	a2,0x1
ffffffffc0200e06:	62660613          	addi	a2,a2,1574 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200e0a:	0d300593          	li	a1,211
ffffffffc0200e0e:	00001517          	auipc	a0,0x1
ffffffffc0200e12:	63250513          	addi	a0,a0,1586 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200e16:	d96ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e1a:	00001697          	auipc	a3,0x1
ffffffffc0200e1e:	67e68693          	addi	a3,a3,1662 # ffffffffc0202498 <commands+0x748>
ffffffffc0200e22:	00001617          	auipc	a2,0x1
ffffffffc0200e26:	60660613          	addi	a2,a2,1542 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200e2a:	0d200593          	li	a1,210
ffffffffc0200e2e:	00001517          	auipc	a0,0x1
ffffffffc0200e32:	61250513          	addi	a0,a0,1554 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200e36:	d76ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e3a:	00001697          	auipc	a3,0x1
ffffffffc0200e3e:	67e68693          	addi	a3,a3,1662 # ffffffffc02024b8 <commands+0x768>
ffffffffc0200e42:	00001617          	auipc	a2,0x1
ffffffffc0200e46:	5e660613          	addi	a2,a2,1510 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200e4a:	0ba00593          	li	a1,186
ffffffffc0200e4e:	00001517          	auipc	a0,0x1
ffffffffc0200e52:	5f250513          	addi	a0,a0,1522 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200e56:	d56ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200e5a:	00002697          	auipc	a3,0x2
ffffffffc0200e5e:	90668693          	addi	a3,a3,-1786 # ffffffffc0202760 <commands+0xa10>
ffffffffc0200e62:	00001617          	auipc	a2,0x1
ffffffffc0200e66:	5c660613          	addi	a2,a2,1478 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200e6a:	12400593          	li	a1,292
ffffffffc0200e6e:	00001517          	auipc	a0,0x1
ffffffffc0200e72:	5d250513          	addi	a0,a0,1490 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200e76:	d36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e7a:	00001697          	auipc	a3,0x1
ffffffffc0200e7e:	78668693          	addi	a3,a3,1926 # ffffffffc0202600 <commands+0x8b0>
ffffffffc0200e82:	00001617          	auipc	a2,0x1
ffffffffc0200e86:	5a660613          	addi	a2,a2,1446 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200e8a:	11900593          	li	a1,281
ffffffffc0200e8e:	00001517          	auipc	a0,0x1
ffffffffc0200e92:	5b250513          	addi	a0,a0,1458 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200e96:	d16ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e9a:	00001697          	auipc	a3,0x1
ffffffffc0200e9e:	70668693          	addi	a3,a3,1798 # ffffffffc02025a0 <commands+0x850>
ffffffffc0200ea2:	00001617          	auipc	a2,0x1
ffffffffc0200ea6:	58660613          	addi	a2,a2,1414 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200eaa:	11700593          	li	a1,279
ffffffffc0200eae:	00001517          	auipc	a0,0x1
ffffffffc0200eb2:	59250513          	addi	a0,a0,1426 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200eb6:	cf6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200eba:	00001697          	auipc	a3,0x1
ffffffffc0200ebe:	6a668693          	addi	a3,a3,1702 # ffffffffc0202560 <commands+0x810>
ffffffffc0200ec2:	00001617          	auipc	a2,0x1
ffffffffc0200ec6:	56660613          	addi	a2,a2,1382 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200eca:	0c000593          	li	a1,192
ffffffffc0200ece:	00001517          	auipc	a0,0x1
ffffffffc0200ed2:	57250513          	addi	a0,a0,1394 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200ed6:	cd6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200eda:	00002697          	auipc	a3,0x2
ffffffffc0200ede:	84668693          	addi	a3,a3,-1978 # ffffffffc0202720 <commands+0x9d0>
ffffffffc0200ee2:	00001617          	auipc	a2,0x1
ffffffffc0200ee6:	54660613          	addi	a2,a2,1350 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200eea:	11100593          	li	a1,273
ffffffffc0200eee:	00001517          	auipc	a0,0x1
ffffffffc0200ef2:	55250513          	addi	a0,a0,1362 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200ef6:	cb6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200efa:	00002697          	auipc	a3,0x2
ffffffffc0200efe:	80668693          	addi	a3,a3,-2042 # ffffffffc0202700 <commands+0x9b0>
ffffffffc0200f02:	00001617          	auipc	a2,0x1
ffffffffc0200f06:	52660613          	addi	a2,a2,1318 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200f0a:	10f00593          	li	a1,271
ffffffffc0200f0e:	00001517          	auipc	a0,0x1
ffffffffc0200f12:	53250513          	addi	a0,a0,1330 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200f16:	c96ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200f1a:	00001697          	auipc	a3,0x1
ffffffffc0200f1e:	7be68693          	addi	a3,a3,1982 # ffffffffc02026d8 <commands+0x988>
ffffffffc0200f22:	00001617          	auipc	a2,0x1
ffffffffc0200f26:	50660613          	addi	a2,a2,1286 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200f2a:	10d00593          	li	a1,269
ffffffffc0200f2e:	00001517          	auipc	a0,0x1
ffffffffc0200f32:	51250513          	addi	a0,a0,1298 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200f36:	c76ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200f3a:	00001697          	auipc	a3,0x1
ffffffffc0200f3e:	77668693          	addi	a3,a3,1910 # ffffffffc02026b0 <commands+0x960>
ffffffffc0200f42:	00001617          	auipc	a2,0x1
ffffffffc0200f46:	4e660613          	addi	a2,a2,1254 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200f4a:	10c00593          	li	a1,268
ffffffffc0200f4e:	00001517          	auipc	a0,0x1
ffffffffc0200f52:	4f250513          	addi	a0,a0,1266 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200f56:	c56ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 2 == p1);
ffffffffc0200f5a:	00001697          	auipc	a3,0x1
ffffffffc0200f5e:	74668693          	addi	a3,a3,1862 # ffffffffc02026a0 <commands+0x950>
ffffffffc0200f62:	00001617          	auipc	a2,0x1
ffffffffc0200f66:	4c660613          	addi	a2,a2,1222 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200f6a:	10700593          	li	a1,263
ffffffffc0200f6e:	00001517          	auipc	a0,0x1
ffffffffc0200f72:	4d250513          	addi	a0,a0,1234 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200f76:	c36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f7a:	00001697          	auipc	a3,0x1
ffffffffc0200f7e:	62668693          	addi	a3,a3,1574 # ffffffffc02025a0 <commands+0x850>
ffffffffc0200f82:	00001617          	auipc	a2,0x1
ffffffffc0200f86:	4a660613          	addi	a2,a2,1190 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200f8a:	10600593          	li	a1,262
ffffffffc0200f8e:	00001517          	auipc	a0,0x1
ffffffffc0200f92:	4b250513          	addi	a0,a0,1202 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200f96:	c16ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200f9a:	00001697          	auipc	a3,0x1
ffffffffc0200f9e:	6e668693          	addi	a3,a3,1766 # ffffffffc0202680 <commands+0x930>
ffffffffc0200fa2:	00001617          	auipc	a2,0x1
ffffffffc0200fa6:	48660613          	addi	a2,a2,1158 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200faa:	10500593          	li	a1,261
ffffffffc0200fae:	00001517          	auipc	a0,0x1
ffffffffc0200fb2:	49250513          	addi	a0,a0,1170 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200fb6:	bf6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200fba:	00001697          	auipc	a3,0x1
ffffffffc0200fbe:	69668693          	addi	a3,a3,1686 # ffffffffc0202650 <commands+0x900>
ffffffffc0200fc2:	00001617          	auipc	a2,0x1
ffffffffc0200fc6:	46660613          	addi	a2,a2,1126 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200fca:	10400593          	li	a1,260
ffffffffc0200fce:	00001517          	auipc	a0,0x1
ffffffffc0200fd2:	47250513          	addi	a0,a0,1138 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200fd6:	bd6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200fda:	00001697          	auipc	a3,0x1
ffffffffc0200fde:	65e68693          	addi	a3,a3,1630 # ffffffffc0202638 <commands+0x8e8>
ffffffffc0200fe2:	00001617          	auipc	a2,0x1
ffffffffc0200fe6:	44660613          	addi	a2,a2,1094 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0200fea:	10300593          	li	a1,259
ffffffffc0200fee:	00001517          	auipc	a0,0x1
ffffffffc0200ff2:	45250513          	addi	a0,a0,1106 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0200ff6:	bb6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ffa:	00001697          	auipc	a3,0x1
ffffffffc0200ffe:	5a668693          	addi	a3,a3,1446 # ffffffffc02025a0 <commands+0x850>
ffffffffc0201002:	00001617          	auipc	a2,0x1
ffffffffc0201006:	42660613          	addi	a2,a2,1062 # ffffffffc0202428 <commands+0x6d8>
ffffffffc020100a:	0fd00593          	li	a1,253
ffffffffc020100e:	00001517          	auipc	a0,0x1
ffffffffc0201012:	43250513          	addi	a0,a0,1074 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0201016:	b96ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc020101a:	00001697          	auipc	a3,0x1
ffffffffc020101e:	60668693          	addi	a3,a3,1542 # ffffffffc0202620 <commands+0x8d0>
ffffffffc0201022:	00001617          	auipc	a2,0x1
ffffffffc0201026:	40660613          	addi	a2,a2,1030 # ffffffffc0202428 <commands+0x6d8>
ffffffffc020102a:	0f800593          	li	a1,248
ffffffffc020102e:	00001517          	auipc	a0,0x1
ffffffffc0201032:	41250513          	addi	a0,a0,1042 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0201036:	b76ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020103a:	00001697          	auipc	a3,0x1
ffffffffc020103e:	70668693          	addi	a3,a3,1798 # ffffffffc0202740 <commands+0x9f0>
ffffffffc0201042:	00001617          	auipc	a2,0x1
ffffffffc0201046:	3e660613          	addi	a2,a2,998 # ffffffffc0202428 <commands+0x6d8>
ffffffffc020104a:	11600593          	li	a1,278
ffffffffc020104e:	00001517          	auipc	a0,0x1
ffffffffc0201052:	3f250513          	addi	a0,a0,1010 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0201056:	b56ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc020105a:	00001697          	auipc	a3,0x1
ffffffffc020105e:	71668693          	addi	a3,a3,1814 # ffffffffc0202770 <commands+0xa20>
ffffffffc0201062:	00001617          	auipc	a2,0x1
ffffffffc0201066:	3c660613          	addi	a2,a2,966 # ffffffffc0202428 <commands+0x6d8>
ffffffffc020106a:	12500593          	li	a1,293
ffffffffc020106e:	00001517          	auipc	a0,0x1
ffffffffc0201072:	3d250513          	addi	a0,a0,978 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0201076:	b36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc020107a:	00001697          	auipc	a3,0x1
ffffffffc020107e:	3de68693          	addi	a3,a3,990 # ffffffffc0202458 <commands+0x708>
ffffffffc0201082:	00001617          	auipc	a2,0x1
ffffffffc0201086:	3a660613          	addi	a2,a2,934 # ffffffffc0202428 <commands+0x6d8>
ffffffffc020108a:	0f200593          	li	a1,242
ffffffffc020108e:	00001517          	auipc	a0,0x1
ffffffffc0201092:	3b250513          	addi	a0,a0,946 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0201096:	b16ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020109a:	00001697          	auipc	a3,0x1
ffffffffc020109e:	3fe68693          	addi	a3,a3,1022 # ffffffffc0202498 <commands+0x748>
ffffffffc02010a2:	00001617          	auipc	a2,0x1
ffffffffc02010a6:	38660613          	addi	a2,a2,902 # ffffffffc0202428 <commands+0x6d8>
ffffffffc02010aa:	0b900593          	li	a1,185
ffffffffc02010ae:	00001517          	auipc	a0,0x1
ffffffffc02010b2:	39250513          	addi	a0,a0,914 # ffffffffc0202440 <commands+0x6f0>
ffffffffc02010b6:	af6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02010ba <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02010ba:	1141                	addi	sp,sp,-16
ffffffffc02010bc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02010be:	18058063          	beqz	a1,ffffffffc020123e <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02010c2:	00259693          	slli	a3,a1,0x2
ffffffffc02010c6:	96ae                	add	a3,a3,a1
ffffffffc02010c8:	068e                	slli	a3,a3,0x3
ffffffffc02010ca:	96aa                	add	a3,a3,a0
ffffffffc02010cc:	02d50d63          	beq	a0,a3,ffffffffc0201106 <default_free_pages+0x4c>
ffffffffc02010d0:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02010d2:	8b85                	andi	a5,a5,1
ffffffffc02010d4:	14079563          	bnez	a5,ffffffffc020121e <default_free_pages+0x164>
ffffffffc02010d8:	651c                	ld	a5,8(a0)
ffffffffc02010da:	8385                	srli	a5,a5,0x1
ffffffffc02010dc:	8b85                	andi	a5,a5,1
ffffffffc02010de:	14079063          	bnez	a5,ffffffffc020121e <default_free_pages+0x164>
ffffffffc02010e2:	87aa                	mv	a5,a0
ffffffffc02010e4:	a809                	j	ffffffffc02010f6 <default_free_pages+0x3c>
ffffffffc02010e6:	6798                	ld	a4,8(a5)
ffffffffc02010e8:	8b05                	andi	a4,a4,1
ffffffffc02010ea:	12071a63          	bnez	a4,ffffffffc020121e <default_free_pages+0x164>
ffffffffc02010ee:	6798                	ld	a4,8(a5)
ffffffffc02010f0:	8b09                	andi	a4,a4,2
ffffffffc02010f2:	12071663          	bnez	a4,ffffffffc020121e <default_free_pages+0x164>
        p->flags = 0;
ffffffffc02010f6:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02010fa:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02010fe:	02878793          	addi	a5,a5,40
ffffffffc0201102:	fed792e3          	bne	a5,a3,ffffffffc02010e6 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201106:	2581                	sext.w	a1,a1
ffffffffc0201108:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020110a:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020110e:	4789                	li	a5,2
ffffffffc0201110:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201114:	00005697          	auipc	a3,0x5
ffffffffc0201118:	32468693          	addi	a3,a3,804 # ffffffffc0206438 <free_area>
ffffffffc020111c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020111e:	669c                	ld	a5,8(a3)
ffffffffc0201120:	9db9                	addw	a1,a1,a4
ffffffffc0201122:	00005717          	auipc	a4,0x5
ffffffffc0201126:	32b72323          	sw	a1,806(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020112a:	08d78f63          	beq	a5,a3,ffffffffc02011c8 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc020112e:	fe878713          	addi	a4,a5,-24
ffffffffc0201132:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201134:	4801                	li	a6,0
ffffffffc0201136:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020113a:	00e56a63          	bltu	a0,a4,ffffffffc020114e <default_free_pages+0x94>
    return listelm->next;
ffffffffc020113e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201140:	02d70563          	beq	a4,a3,ffffffffc020116a <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201144:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201146:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020114a:	fee57ae3          	bleu	a4,a0,ffffffffc020113e <default_free_pages+0x84>
ffffffffc020114e:	00080663          	beqz	a6,ffffffffc020115a <default_free_pages+0xa0>
ffffffffc0201152:	00005817          	auipc	a6,0x5
ffffffffc0201156:	2eb83323          	sd	a1,742(a6) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020115a:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020115c:	e390                	sd	a2,0(a5)
ffffffffc020115e:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0201160:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201162:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0201164:	02d59163          	bne	a1,a3,ffffffffc0201186 <default_free_pages+0xcc>
ffffffffc0201168:	a091                	j	ffffffffc02011ac <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc020116a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020116c:	f114                	sd	a3,32(a0)
ffffffffc020116e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201170:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201172:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201174:	00d70563          	beq	a4,a3,ffffffffc020117e <default_free_pages+0xc4>
ffffffffc0201178:	4805                	li	a6,1
ffffffffc020117a:	87ba                	mv	a5,a4
ffffffffc020117c:	b7e9                	j	ffffffffc0201146 <default_free_pages+0x8c>
ffffffffc020117e:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201180:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201182:	02d78163          	beq	a5,a3,ffffffffc02011a4 <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0201186:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc020118a:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base) {
ffffffffc020118e:	02081713          	slli	a4,a6,0x20
ffffffffc0201192:	9301                	srli	a4,a4,0x20
ffffffffc0201194:	00271793          	slli	a5,a4,0x2
ffffffffc0201198:	97ba                	add	a5,a5,a4
ffffffffc020119a:	078e                	slli	a5,a5,0x3
ffffffffc020119c:	97b2                	add	a5,a5,a2
ffffffffc020119e:	02f50e63          	beq	a0,a5,ffffffffc02011da <default_free_pages+0x120>
ffffffffc02011a2:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02011a4:	fe878713          	addi	a4,a5,-24
ffffffffc02011a8:	00d78d63          	beq	a5,a3,ffffffffc02011c2 <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02011ac:	490c                	lw	a1,16(a0)
ffffffffc02011ae:	02059613          	slli	a2,a1,0x20
ffffffffc02011b2:	9201                	srli	a2,a2,0x20
ffffffffc02011b4:	00261693          	slli	a3,a2,0x2
ffffffffc02011b8:	96b2                	add	a3,a3,a2
ffffffffc02011ba:	068e                	slli	a3,a3,0x3
ffffffffc02011bc:	96aa                	add	a3,a3,a0
ffffffffc02011be:	04d70063          	beq	a4,a3,ffffffffc02011fe <default_free_pages+0x144>
}
ffffffffc02011c2:	60a2                	ld	ra,8(sp)
ffffffffc02011c4:	0141                	addi	sp,sp,16
ffffffffc02011c6:	8082                	ret
ffffffffc02011c8:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02011ca:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02011ce:	e398                	sd	a4,0(a5)
ffffffffc02011d0:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02011d2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011d4:	ed1c                	sd	a5,24(a0)
}
ffffffffc02011d6:	0141                	addi	sp,sp,16
ffffffffc02011d8:	8082                	ret
            p->property += base->property;
ffffffffc02011da:	491c                	lw	a5,16(a0)
ffffffffc02011dc:	0107883b          	addw	a6,a5,a6
ffffffffc02011e0:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02011e4:	57f5                	li	a5,-3
ffffffffc02011e6:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02011ea:	01853803          	ld	a6,24(a0)
ffffffffc02011ee:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc02011f0:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02011f2:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc02011f6:	659c                	ld	a5,8(a1)
ffffffffc02011f8:	01073023          	sd	a6,0(a4)
ffffffffc02011fc:	b765                	j	ffffffffc02011a4 <default_free_pages+0xea>
            base->property += p->property;
ffffffffc02011fe:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201202:	ff078693          	addi	a3,a5,-16
ffffffffc0201206:	9db9                	addw	a1,a1,a4
ffffffffc0201208:	c90c                	sw	a1,16(a0)
ffffffffc020120a:	5775                	li	a4,-3
ffffffffc020120c:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201210:	6398                	ld	a4,0(a5)
ffffffffc0201212:	679c                	ld	a5,8(a5)
}
ffffffffc0201214:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201216:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201218:	e398                	sd	a4,0(a5)
ffffffffc020121a:	0141                	addi	sp,sp,16
ffffffffc020121c:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020121e:	00001697          	auipc	a3,0x1
ffffffffc0201222:	56268693          	addi	a3,a3,1378 # ffffffffc0202780 <commands+0xa30>
ffffffffc0201226:	00001617          	auipc	a2,0x1
ffffffffc020122a:	20260613          	addi	a2,a2,514 # ffffffffc0202428 <commands+0x6d8>
ffffffffc020122e:	08200593          	li	a1,130
ffffffffc0201232:	00001517          	auipc	a0,0x1
ffffffffc0201236:	20e50513          	addi	a0,a0,526 # ffffffffc0202440 <commands+0x6f0>
ffffffffc020123a:	972ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc020123e:	00001697          	auipc	a3,0x1
ffffffffc0201242:	56a68693          	addi	a3,a3,1386 # ffffffffc02027a8 <commands+0xa58>
ffffffffc0201246:	00001617          	auipc	a2,0x1
ffffffffc020124a:	1e260613          	addi	a2,a2,482 # ffffffffc0202428 <commands+0x6d8>
ffffffffc020124e:	07f00593          	li	a1,127
ffffffffc0201252:	00001517          	auipc	a0,0x1
ffffffffc0201256:	1ee50513          	addi	a0,a0,494 # ffffffffc0202440 <commands+0x6f0>
ffffffffc020125a:	952ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020125e <default_alloc_pages>:
    assert(n > 0);
ffffffffc020125e:	cd51                	beqz	a0,ffffffffc02012fa <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc0201260:	00005597          	auipc	a1,0x5
ffffffffc0201264:	1d858593          	addi	a1,a1,472 # ffffffffc0206438 <free_area>
ffffffffc0201268:	0105a803          	lw	a6,16(a1)
ffffffffc020126c:	862a                	mv	a2,a0
ffffffffc020126e:	02081793          	slli	a5,a6,0x20
ffffffffc0201272:	9381                	srli	a5,a5,0x20
ffffffffc0201274:	00a7ee63          	bltu	a5,a0,ffffffffc0201290 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201278:	87ae                	mv	a5,a1
ffffffffc020127a:	a801                	j	ffffffffc020128a <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020127c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201280:	02071693          	slli	a3,a4,0x20
ffffffffc0201284:	9281                	srli	a3,a3,0x20
ffffffffc0201286:	00c6f763          	bleu	a2,a3,ffffffffc0201294 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020128a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020128c:	feb798e3          	bne	a5,a1,ffffffffc020127c <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201290:	4501                	li	a0,0
}
ffffffffc0201292:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0201294:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0201298:	dd6d                	beqz	a0,ffffffffc0201292 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc020129a:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020129e:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02012a2:	00060e1b          	sext.w	t3,a2
ffffffffc02012a6:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02012aa:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02012ae:	02d67b63          	bleu	a3,a2,ffffffffc02012e4 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02012b2:	00261693          	slli	a3,a2,0x2
ffffffffc02012b6:	96b2                	add	a3,a3,a2
ffffffffc02012b8:	068e                	slli	a3,a3,0x3
ffffffffc02012ba:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02012bc:	41c7073b          	subw	a4,a4,t3
ffffffffc02012c0:	ca98                	sw	a4,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012c2:	00868613          	addi	a2,a3,8
ffffffffc02012c6:	4709                	li	a4,2
ffffffffc02012c8:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02012cc:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02012d0:	01868613          	addi	a2,a3,24
    prev->next = next->prev = elm;
ffffffffc02012d4:	0105a803          	lw	a6,16(a1)
ffffffffc02012d8:	e310                	sd	a2,0(a4)
ffffffffc02012da:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02012de:	f298                	sd	a4,32(a3)
    elm->prev = prev;
ffffffffc02012e0:	0116bc23          	sd	a7,24(a3)
        nr_free -= n;
ffffffffc02012e4:	41c8083b          	subw	a6,a6,t3
ffffffffc02012e8:	00005717          	auipc	a4,0x5
ffffffffc02012ec:	17072023          	sw	a6,352(a4) # ffffffffc0206448 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02012f0:	5775                	li	a4,-3
ffffffffc02012f2:	17c1                	addi	a5,a5,-16
ffffffffc02012f4:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02012f8:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02012fa:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02012fc:	00001697          	auipc	a3,0x1
ffffffffc0201300:	4ac68693          	addi	a3,a3,1196 # ffffffffc02027a8 <commands+0xa58>
ffffffffc0201304:	00001617          	auipc	a2,0x1
ffffffffc0201308:	12460613          	addi	a2,a2,292 # ffffffffc0202428 <commands+0x6d8>
ffffffffc020130c:	06100593          	li	a1,97
ffffffffc0201310:	00001517          	auipc	a0,0x1
ffffffffc0201314:	13050513          	addi	a0,a0,304 # ffffffffc0202440 <commands+0x6f0>
default_alloc_pages(size_t n) {
ffffffffc0201318:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020131a:	892ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020131e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020131e:	1141                	addi	sp,sp,-16
ffffffffc0201320:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201322:	c1fd                	beqz	a1,ffffffffc0201408 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc0201324:	00259693          	slli	a3,a1,0x2
ffffffffc0201328:	96ae                	add	a3,a3,a1
ffffffffc020132a:	068e                	slli	a3,a3,0x3
ffffffffc020132c:	96aa                	add	a3,a3,a0
ffffffffc020132e:	02d50463          	beq	a0,a3,ffffffffc0201356 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201332:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0201334:	87aa                	mv	a5,a0
ffffffffc0201336:	8b05                	andi	a4,a4,1
ffffffffc0201338:	e709                	bnez	a4,ffffffffc0201342 <default_init_memmap+0x24>
ffffffffc020133a:	a07d                	j	ffffffffc02013e8 <default_init_memmap+0xca>
ffffffffc020133c:	6798                	ld	a4,8(a5)
ffffffffc020133e:	8b05                	andi	a4,a4,1
ffffffffc0201340:	c745                	beqz	a4,ffffffffc02013e8 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc0201342:	0007a823          	sw	zero,16(a5)
ffffffffc0201346:	0007b423          	sd	zero,8(a5)
ffffffffc020134a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020134e:	02878793          	addi	a5,a5,40
ffffffffc0201352:	fed795e3          	bne	a5,a3,ffffffffc020133c <default_init_memmap+0x1e>
    base->property = n;
ffffffffc0201356:	2581                	sext.w	a1,a1
ffffffffc0201358:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020135a:	4789                	li	a5,2
ffffffffc020135c:	00850713          	addi	a4,a0,8
ffffffffc0201360:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201364:	00005697          	auipc	a3,0x5
ffffffffc0201368:	0d468693          	addi	a3,a3,212 # ffffffffc0206438 <free_area>
ffffffffc020136c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020136e:	669c                	ld	a5,8(a3)
ffffffffc0201370:	9db9                	addw	a1,a1,a4
ffffffffc0201372:	00005717          	auipc	a4,0x5
ffffffffc0201376:	0cb72b23          	sw	a1,214(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020137a:	04d78a63          	beq	a5,a3,ffffffffc02013ce <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc020137e:	fe878713          	addi	a4,a5,-24
ffffffffc0201382:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201384:	4801                	li	a6,0
ffffffffc0201386:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020138a:	00e56a63          	bltu	a0,a4,ffffffffc020139e <default_init_memmap+0x80>
    return listelm->next;
ffffffffc020138e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201390:	02d70563          	beq	a4,a3,ffffffffc02013ba <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201394:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201396:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020139a:	fee57ae3          	bleu	a4,a0,ffffffffc020138e <default_init_memmap+0x70>
ffffffffc020139e:	00080663          	beqz	a6,ffffffffc02013aa <default_init_memmap+0x8c>
ffffffffc02013a2:	00005717          	auipc	a4,0x5
ffffffffc02013a6:	08b73b23          	sd	a1,150(a4) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013aa:	6398                	ld	a4,0(a5)
}
ffffffffc02013ac:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02013ae:	e390                	sd	a2,0(a5)
ffffffffc02013b0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02013b2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02013b4:	ed18                	sd	a4,24(a0)
ffffffffc02013b6:	0141                	addi	sp,sp,16
ffffffffc02013b8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02013ba:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013bc:	f114                	sd	a3,32(a0)
ffffffffc02013be:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013c0:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02013c2:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013c4:	00d70e63          	beq	a4,a3,ffffffffc02013e0 <default_init_memmap+0xc2>
ffffffffc02013c8:	4805                	li	a6,1
ffffffffc02013ca:	87ba                	mv	a5,a4
ffffffffc02013cc:	b7e9                	j	ffffffffc0201396 <default_init_memmap+0x78>
}
ffffffffc02013ce:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02013d0:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02013d4:	e398                	sd	a4,0(a5)
ffffffffc02013d6:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02013d8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02013da:	ed1c                	sd	a5,24(a0)
}
ffffffffc02013dc:	0141                	addi	sp,sp,16
ffffffffc02013de:	8082                	ret
ffffffffc02013e0:	60a2                	ld	ra,8(sp)
ffffffffc02013e2:	e290                	sd	a2,0(a3)
ffffffffc02013e4:	0141                	addi	sp,sp,16
ffffffffc02013e6:	8082                	ret
        assert(PageReserved(p));
ffffffffc02013e8:	00001697          	auipc	a3,0x1
ffffffffc02013ec:	3c868693          	addi	a3,a3,968 # ffffffffc02027b0 <commands+0xa60>
ffffffffc02013f0:	00001617          	auipc	a2,0x1
ffffffffc02013f4:	03860613          	addi	a2,a2,56 # ffffffffc0202428 <commands+0x6d8>
ffffffffc02013f8:	04800593          	li	a1,72
ffffffffc02013fc:	00001517          	auipc	a0,0x1
ffffffffc0201400:	04450513          	addi	a0,a0,68 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0201404:	fa9fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201408:	00001697          	auipc	a3,0x1
ffffffffc020140c:	3a068693          	addi	a3,a3,928 # ffffffffc02027a8 <commands+0xa58>
ffffffffc0201410:	00001617          	auipc	a2,0x1
ffffffffc0201414:	01860613          	addi	a2,a2,24 # ffffffffc0202428 <commands+0x6d8>
ffffffffc0201418:	04500593          	li	a1,69
ffffffffc020141c:	00001517          	auipc	a0,0x1
ffffffffc0201420:	02450513          	addi	a0,a0,36 # ffffffffc0202440 <commands+0x6f0>
ffffffffc0201424:	f89fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201428 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201428:	100027f3          	csrr	a5,sstatus
ffffffffc020142c:	8b89                	andi	a5,a5,2
ffffffffc020142e:	eb89                	bnez	a5,ffffffffc0201440 <alloc_pages+0x18>
    struct Page *page = NULL;
    
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201430:	00005797          	auipc	a5,0x5
ffffffffc0201434:	02878793          	addi	a5,a5,40 # ffffffffc0206458 <pmm_manager>
ffffffffc0201438:	639c                	ld	a5,0(a5)
ffffffffc020143a:	0187b303          	ld	t1,24(a5)
ffffffffc020143e:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0201440:	1141                	addi	sp,sp,-16
ffffffffc0201442:	e406                	sd	ra,8(sp)
ffffffffc0201444:	e022                	sd	s0,0(sp)
ffffffffc0201446:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201448:	81cff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020144c:	00005797          	auipc	a5,0x5
ffffffffc0201450:	00c78793          	addi	a5,a5,12 # ffffffffc0206458 <pmm_manager>
ffffffffc0201454:	639c                	ld	a5,0(a5)
ffffffffc0201456:	8522                	mv	a0,s0
ffffffffc0201458:	6f9c                	ld	a5,24(a5)
ffffffffc020145a:	9782                	jalr	a5
ffffffffc020145c:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020145e:	800ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201462:	8522                	mv	a0,s0
ffffffffc0201464:	60a2                	ld	ra,8(sp)
ffffffffc0201466:	6402                	ld	s0,0(sp)
ffffffffc0201468:	0141                	addi	sp,sp,16
ffffffffc020146a:	8082                	ret

ffffffffc020146c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020146c:	100027f3          	csrr	a5,sstatus
ffffffffc0201470:	8b89                	andi	a5,a5,2
ffffffffc0201472:	eb89                	bnez	a5,ffffffffc0201484 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201474:	00005797          	auipc	a5,0x5
ffffffffc0201478:	fe478793          	addi	a5,a5,-28 # ffffffffc0206458 <pmm_manager>
ffffffffc020147c:	639c                	ld	a5,0(a5)
ffffffffc020147e:	0207b303          	ld	t1,32(a5)
ffffffffc0201482:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201484:	1101                	addi	sp,sp,-32
ffffffffc0201486:	ec06                	sd	ra,24(sp)
ffffffffc0201488:	e822                	sd	s0,16(sp)
ffffffffc020148a:	e426                	sd	s1,8(sp)
ffffffffc020148c:	842a                	mv	s0,a0
ffffffffc020148e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201490:	fd5fe0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201494:	00005797          	auipc	a5,0x5
ffffffffc0201498:	fc478793          	addi	a5,a5,-60 # ffffffffc0206458 <pmm_manager>
ffffffffc020149c:	639c                	ld	a5,0(a5)
ffffffffc020149e:	85a6                	mv	a1,s1
ffffffffc02014a0:	8522                	mv	a0,s0
ffffffffc02014a2:	739c                	ld	a5,32(a5)
ffffffffc02014a4:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02014a6:	6442                	ld	s0,16(sp)
ffffffffc02014a8:	60e2                	ld	ra,24(sp)
ffffffffc02014aa:	64a2                	ld	s1,8(sp)
ffffffffc02014ac:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02014ae:	fb1fe06f          	j	ffffffffc020045e <intr_enable>

ffffffffc02014b2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02014b2:	100027f3          	csrr	a5,sstatus
ffffffffc02014b6:	8b89                	andi	a5,a5,2
ffffffffc02014b8:	eb89                	bnez	a5,ffffffffc02014ca <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02014ba:	00005797          	auipc	a5,0x5
ffffffffc02014be:	f9e78793          	addi	a5,a5,-98 # ffffffffc0206458 <pmm_manager>
ffffffffc02014c2:	639c                	ld	a5,0(a5)
ffffffffc02014c4:	0287b303          	ld	t1,40(a5)
ffffffffc02014c8:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02014ca:	1141                	addi	sp,sp,-16
ffffffffc02014cc:	e406                	sd	ra,8(sp)
ffffffffc02014ce:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02014d0:	f95fe0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02014d4:	00005797          	auipc	a5,0x5
ffffffffc02014d8:	f8478793          	addi	a5,a5,-124 # ffffffffc0206458 <pmm_manager>
ffffffffc02014dc:	639c                	ld	a5,0(a5)
ffffffffc02014de:	779c                	ld	a5,40(a5)
ffffffffc02014e0:	9782                	jalr	a5
ffffffffc02014e2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02014e4:	f7bfe0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02014e8:	8522                	mv	a0,s0
ffffffffc02014ea:	60a2                	ld	ra,8(sp)
ffffffffc02014ec:	6402                	ld	s0,0(sp)
ffffffffc02014ee:	0141                	addi	sp,sp,16
ffffffffc02014f0:	8082                	ret

ffffffffc02014f2 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02014f2:	00001797          	auipc	a5,0x1
ffffffffc02014f6:	2ce78793          	addi	a5,a5,718 # ffffffffc02027c0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014fa:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02014fc:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014fe:	00001517          	auipc	a0,0x1
ffffffffc0201502:	31250513          	addi	a0,a0,786 # ffffffffc0202810 <default_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc0201506:	ec06                	sd	ra,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201508:	00005717          	auipc	a4,0x5
ffffffffc020150c:	f4f73823          	sd	a5,-176(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc0201510:	e822                	sd	s0,16(sp)
ffffffffc0201512:	e426                	sd	s1,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201514:	00005417          	auipc	s0,0x5
ffffffffc0201518:	f4440413          	addi	s0,s0,-188 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020151c:	b9bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0201520:	601c                	ld	a5,0(s0)
ffffffffc0201522:	679c                	ld	a5,8(a5)
ffffffffc0201524:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201526:	57f5                	li	a5,-3
ffffffffc0201528:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020152a:	00001517          	auipc	a0,0x1
ffffffffc020152e:	2fe50513          	addi	a0,a0,766 # ffffffffc0202828 <default_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201532:	00005717          	auipc	a4,0x5
ffffffffc0201536:	f2f73723          	sd	a5,-210(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020153a:	b7dfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020153e:	46c5                	li	a3,17
ffffffffc0201540:	06ee                	slli	a3,a3,0x1b
ffffffffc0201542:	40100613          	li	a2,1025
ffffffffc0201546:	16fd                	addi	a3,a3,-1
ffffffffc0201548:	0656                	slli	a2,a2,0x15
ffffffffc020154a:	07e005b7          	lui	a1,0x7e00
ffffffffc020154e:	00001517          	auipc	a0,0x1
ffffffffc0201552:	2f250513          	addi	a0,a0,754 # ffffffffc0202840 <default_pmm_manager+0x80>
ffffffffc0201556:	b61fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020155a:	777d                	lui	a4,0xfffff
ffffffffc020155c:	00006797          	auipc	a5,0x6
ffffffffc0201560:	f1378793          	addi	a5,a5,-237 # ffffffffc020746f <end+0xfff>
ffffffffc0201564:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201566:	00088737          	lui	a4,0x88
ffffffffc020156a:	00005697          	auipc	a3,0x5
ffffffffc020156e:	eae6b723          	sd	a4,-338(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201572:	4601                	li	a2,0
ffffffffc0201574:	00005717          	auipc	a4,0x5
ffffffffc0201578:	eef73a23          	sd	a5,-268(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020157c:	4681                	li	a3,0
ffffffffc020157e:	00005897          	auipc	a7,0x5
ffffffffc0201582:	e9a88893          	addi	a7,a7,-358 # ffffffffc0206418 <npage>
ffffffffc0201586:	00005597          	auipc	a1,0x5
ffffffffc020158a:	ee258593          	addi	a1,a1,-286 # ffffffffc0206468 <pages>
ffffffffc020158e:	4805                	li	a6,1
ffffffffc0201590:	fff80537          	lui	a0,0xfff80
ffffffffc0201594:	a011                	j	ffffffffc0201598 <pmm_init+0xa6>
ffffffffc0201596:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0201598:	97b2                	add	a5,a5,a2
ffffffffc020159a:	07a1                	addi	a5,a5,8
ffffffffc020159c:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02015a0:	0008b703          	ld	a4,0(a7)
ffffffffc02015a4:	0685                	addi	a3,a3,1
ffffffffc02015a6:	02860613          	addi	a2,a2,40
ffffffffc02015aa:	00a707b3          	add	a5,a4,a0
ffffffffc02015ae:	fef6e4e3          	bltu	a3,a5,ffffffffc0201596 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02015b2:	6190                	ld	a2,0(a1)
ffffffffc02015b4:	00271793          	slli	a5,a4,0x2
ffffffffc02015b8:	97ba                	add	a5,a5,a4
ffffffffc02015ba:	fec006b7          	lui	a3,0xfec00
ffffffffc02015be:	078e                	slli	a5,a5,0x3
ffffffffc02015c0:	96b2                	add	a3,a3,a2
ffffffffc02015c2:	96be                	add	a3,a3,a5
ffffffffc02015c4:	c02007b7          	lui	a5,0xc0200
ffffffffc02015c8:	08f6e863          	bltu	a3,a5,ffffffffc0201658 <pmm_init+0x166>
ffffffffc02015cc:	00005497          	auipc	s1,0x5
ffffffffc02015d0:	e9448493          	addi	s1,s1,-364 # ffffffffc0206460 <va_pa_offset>
ffffffffc02015d4:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc02015d6:	45c5                	li	a1,17
ffffffffc02015d8:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02015da:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc02015dc:	04b6e963          	bltu	a3,a1,ffffffffc020162e <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02015e0:	601c                	ld	a5,0(s0)
ffffffffc02015e2:	7b9c                	ld	a5,48(a5)
ffffffffc02015e4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02015e6:	00001517          	auipc	a0,0x1
ffffffffc02015ea:	2f250513          	addi	a0,a0,754 # ffffffffc02028d8 <default_pmm_manager+0x118>
ffffffffc02015ee:	ac9fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02015f2:	00004697          	auipc	a3,0x4
ffffffffc02015f6:	a0e68693          	addi	a3,a3,-1522 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02015fa:	00005797          	auipc	a5,0x5
ffffffffc02015fe:	e2d7b323          	sd	a3,-474(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201602:	c02007b7          	lui	a5,0xc0200
ffffffffc0201606:	06f6e563          	bltu	a3,a5,ffffffffc0201670 <pmm_init+0x17e>
ffffffffc020160a:	609c                	ld	a5,0(s1)
}
ffffffffc020160c:	6442                	ld	s0,16(sp)
ffffffffc020160e:	60e2                	ld	ra,24(sp)
ffffffffc0201610:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201612:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0201614:	8e9d                	sub	a3,a3,a5
ffffffffc0201616:	00005797          	auipc	a5,0x5
ffffffffc020161a:	e2d7bd23          	sd	a3,-454(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020161e:	00001517          	auipc	a0,0x1
ffffffffc0201622:	2da50513          	addi	a0,a0,730 # ffffffffc02028f8 <default_pmm_manager+0x138>
ffffffffc0201626:	8636                	mv	a2,a3
}
ffffffffc0201628:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020162a:	a8dfe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020162e:	6785                	lui	a5,0x1
ffffffffc0201630:	17fd                	addi	a5,a5,-1
ffffffffc0201632:	96be                	add	a3,a3,a5
ffffffffc0201634:	77fd                	lui	a5,0xfffff
ffffffffc0201636:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201638:	00c6d793          	srli	a5,a3,0xc
ffffffffc020163c:	04e7f663          	bleu	a4,a5,ffffffffc0201688 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0201640:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201642:	97aa                	add	a5,a5,a0
ffffffffc0201644:	00279513          	slli	a0,a5,0x2
ffffffffc0201648:	953e                	add	a0,a0,a5
ffffffffc020164a:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020164c:	8d95                	sub	a1,a1,a3
ffffffffc020164e:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201650:	81b1                	srli	a1,a1,0xc
ffffffffc0201652:	9532                	add	a0,a0,a2
ffffffffc0201654:	9782                	jalr	a5
ffffffffc0201656:	b769                	j	ffffffffc02015e0 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201658:	00001617          	auipc	a2,0x1
ffffffffc020165c:	21860613          	addi	a2,a2,536 # ffffffffc0202870 <default_pmm_manager+0xb0>
ffffffffc0201660:	06f00593          	li	a1,111
ffffffffc0201664:	00001517          	auipc	a0,0x1
ffffffffc0201668:	23450513          	addi	a0,a0,564 # ffffffffc0202898 <default_pmm_manager+0xd8>
ffffffffc020166c:	d41fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201670:	00001617          	auipc	a2,0x1
ffffffffc0201674:	20060613          	addi	a2,a2,512 # ffffffffc0202870 <default_pmm_manager+0xb0>
ffffffffc0201678:	08a00593          	li	a1,138
ffffffffc020167c:	00001517          	auipc	a0,0x1
ffffffffc0201680:	21c50513          	addi	a0,a0,540 # ffffffffc0202898 <default_pmm_manager+0xd8>
ffffffffc0201684:	d29fe0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201688:	00001617          	auipc	a2,0x1
ffffffffc020168c:	22060613          	addi	a2,a2,544 # ffffffffc02028a8 <default_pmm_manager+0xe8>
ffffffffc0201690:	06b00593          	li	a1,107
ffffffffc0201694:	00001517          	auipc	a0,0x1
ffffffffc0201698:	23450513          	addi	a0,a0,564 # ffffffffc02028c8 <default_pmm_manager+0x108>
ffffffffc020169c:	d11fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02016a0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02016a0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02016a4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02016a6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02016aa:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02016ac:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02016b0:	f022                	sd	s0,32(sp)
ffffffffc02016b2:	ec26                	sd	s1,24(sp)
ffffffffc02016b4:	e84a                	sd	s2,16(sp)
ffffffffc02016b6:	f406                	sd	ra,40(sp)
ffffffffc02016b8:	e44e                	sd	s3,8(sp)
ffffffffc02016ba:	84aa                	mv	s1,a0
ffffffffc02016bc:	892e                	mv	s2,a1
ffffffffc02016be:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02016c2:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02016c4:	03067e63          	bleu	a6,a2,ffffffffc0201700 <printnum+0x60>
ffffffffc02016c8:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02016ca:	00805763          	blez	s0,ffffffffc02016d8 <printnum+0x38>
ffffffffc02016ce:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02016d0:	85ca                	mv	a1,s2
ffffffffc02016d2:	854e                	mv	a0,s3
ffffffffc02016d4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02016d6:	fc65                	bnez	s0,ffffffffc02016ce <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016d8:	1a02                	slli	s4,s4,0x20
ffffffffc02016da:	020a5a13          	srli	s4,s4,0x20
ffffffffc02016de:	00001797          	auipc	a5,0x1
ffffffffc02016e2:	3ea78793          	addi	a5,a5,1002 # ffffffffc0202ac8 <error_string+0x38>
ffffffffc02016e6:	9a3e                	add	s4,s4,a5
}
ffffffffc02016e8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016ea:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02016ee:	70a2                	ld	ra,40(sp)
ffffffffc02016f0:	69a2                	ld	s3,8(sp)
ffffffffc02016f2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016f4:	85ca                	mv	a1,s2
ffffffffc02016f6:	8326                	mv	t1,s1
}
ffffffffc02016f8:	6942                	ld	s2,16(sp)
ffffffffc02016fa:	64e2                	ld	s1,24(sp)
ffffffffc02016fc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016fe:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201700:	03065633          	divu	a2,a2,a6
ffffffffc0201704:	8722                	mv	a4,s0
ffffffffc0201706:	f9bff0ef          	jal	ra,ffffffffc02016a0 <printnum>
ffffffffc020170a:	b7f9                	j	ffffffffc02016d8 <printnum+0x38>

ffffffffc020170c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020170c:	7119                	addi	sp,sp,-128
ffffffffc020170e:	f4a6                	sd	s1,104(sp)
ffffffffc0201710:	f0ca                	sd	s2,96(sp)
ffffffffc0201712:	e8d2                	sd	s4,80(sp)
ffffffffc0201714:	e4d6                	sd	s5,72(sp)
ffffffffc0201716:	e0da                	sd	s6,64(sp)
ffffffffc0201718:	fc5e                	sd	s7,56(sp)
ffffffffc020171a:	f862                	sd	s8,48(sp)
ffffffffc020171c:	f06a                	sd	s10,32(sp)
ffffffffc020171e:	fc86                	sd	ra,120(sp)
ffffffffc0201720:	f8a2                	sd	s0,112(sp)
ffffffffc0201722:	ecce                	sd	s3,88(sp)
ffffffffc0201724:	f466                	sd	s9,40(sp)
ffffffffc0201726:	ec6e                	sd	s11,24(sp)
ffffffffc0201728:	892a                	mv	s2,a0
ffffffffc020172a:	84ae                	mv	s1,a1
ffffffffc020172c:	8d32                	mv	s10,a2
ffffffffc020172e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201730:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201732:	00001a17          	auipc	s4,0x1
ffffffffc0201736:	206a0a13          	addi	s4,s4,518 # ffffffffc0202938 <default_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020173a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020173e:	00001c17          	auipc	s8,0x1
ffffffffc0201742:	352c0c13          	addi	s8,s8,850 # ffffffffc0202a90 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201746:	000d4503          	lbu	a0,0(s10)
ffffffffc020174a:	02500793          	li	a5,37
ffffffffc020174e:	001d0413          	addi	s0,s10,1
ffffffffc0201752:	00f50e63          	beq	a0,a5,ffffffffc020176e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201756:	c521                	beqz	a0,ffffffffc020179e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201758:	02500993          	li	s3,37
ffffffffc020175c:	a011                	j	ffffffffc0201760 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020175e:	c121                	beqz	a0,ffffffffc020179e <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201760:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201762:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201764:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201766:	fff44503          	lbu	a0,-1(s0)
ffffffffc020176a:	ff351ae3          	bne	a0,s3,ffffffffc020175e <vprintfmt+0x52>
ffffffffc020176e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201772:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201776:	4981                	li	s3,0
ffffffffc0201778:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020177a:	5cfd                	li	s9,-1
ffffffffc020177c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020177e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201782:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201784:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201788:	0ff6f693          	andi	a3,a3,255
ffffffffc020178c:	00140d13          	addi	s10,s0,1
ffffffffc0201790:	20d5e563          	bltu	a1,a3,ffffffffc020199a <vprintfmt+0x28e>
ffffffffc0201794:	068a                	slli	a3,a3,0x2
ffffffffc0201796:	96d2                	add	a3,a3,s4
ffffffffc0201798:	4294                	lw	a3,0(a3)
ffffffffc020179a:	96d2                	add	a3,a3,s4
ffffffffc020179c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020179e:	70e6                	ld	ra,120(sp)
ffffffffc02017a0:	7446                	ld	s0,112(sp)
ffffffffc02017a2:	74a6                	ld	s1,104(sp)
ffffffffc02017a4:	7906                	ld	s2,96(sp)
ffffffffc02017a6:	69e6                	ld	s3,88(sp)
ffffffffc02017a8:	6a46                	ld	s4,80(sp)
ffffffffc02017aa:	6aa6                	ld	s5,72(sp)
ffffffffc02017ac:	6b06                	ld	s6,64(sp)
ffffffffc02017ae:	7be2                	ld	s7,56(sp)
ffffffffc02017b0:	7c42                	ld	s8,48(sp)
ffffffffc02017b2:	7ca2                	ld	s9,40(sp)
ffffffffc02017b4:	7d02                	ld	s10,32(sp)
ffffffffc02017b6:	6de2                	ld	s11,24(sp)
ffffffffc02017b8:	6109                	addi	sp,sp,128
ffffffffc02017ba:	8082                	ret
    if (lflag >= 2) {
ffffffffc02017bc:	4705                	li	a4,1
ffffffffc02017be:	008a8593          	addi	a1,s5,8
ffffffffc02017c2:	01074463          	blt	a4,a6,ffffffffc02017ca <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02017c6:	26080363          	beqz	a6,ffffffffc0201a2c <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02017ca:	000ab603          	ld	a2,0(s5)
ffffffffc02017ce:	46c1                	li	a3,16
ffffffffc02017d0:	8aae                	mv	s5,a1
ffffffffc02017d2:	a06d                	j	ffffffffc020187c <vprintfmt+0x170>
            goto reswitch;
ffffffffc02017d4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02017d8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017da:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017dc:	b765                	j	ffffffffc0201784 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02017de:	000aa503          	lw	a0,0(s5)
ffffffffc02017e2:	85a6                	mv	a1,s1
ffffffffc02017e4:	0aa1                	addi	s5,s5,8
ffffffffc02017e6:	9902                	jalr	s2
            break;
ffffffffc02017e8:	bfb9                	j	ffffffffc0201746 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017ea:	4705                	li	a4,1
ffffffffc02017ec:	008a8993          	addi	s3,s5,8
ffffffffc02017f0:	01074463          	blt	a4,a6,ffffffffc02017f8 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02017f4:	22080463          	beqz	a6,ffffffffc0201a1c <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02017f8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02017fc:	24044463          	bltz	s0,ffffffffc0201a44 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0201800:	8622                	mv	a2,s0
ffffffffc0201802:	8ace                	mv	s5,s3
ffffffffc0201804:	46a9                	li	a3,10
ffffffffc0201806:	a89d                	j	ffffffffc020187c <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201808:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020180c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020180e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0201810:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201814:	8fb5                	xor	a5,a5,a3
ffffffffc0201816:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020181a:	1ad74363          	blt	a4,a3,ffffffffc02019c0 <vprintfmt+0x2b4>
ffffffffc020181e:	00369793          	slli	a5,a3,0x3
ffffffffc0201822:	97e2                	add	a5,a5,s8
ffffffffc0201824:	639c                	ld	a5,0(a5)
ffffffffc0201826:	18078d63          	beqz	a5,ffffffffc02019c0 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc020182a:	86be                	mv	a3,a5
ffffffffc020182c:	00001617          	auipc	a2,0x1
ffffffffc0201830:	34c60613          	addi	a2,a2,844 # ffffffffc0202b78 <error_string+0xe8>
ffffffffc0201834:	85a6                	mv	a1,s1
ffffffffc0201836:	854a                	mv	a0,s2
ffffffffc0201838:	240000ef          	jal	ra,ffffffffc0201a78 <printfmt>
ffffffffc020183c:	b729                	j	ffffffffc0201746 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020183e:	00144603          	lbu	a2,1(s0)
ffffffffc0201842:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201844:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201846:	bf3d                	j	ffffffffc0201784 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201848:	4705                	li	a4,1
ffffffffc020184a:	008a8593          	addi	a1,s5,8
ffffffffc020184e:	01074463          	blt	a4,a6,ffffffffc0201856 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201852:	1e080263          	beqz	a6,ffffffffc0201a36 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201856:	000ab603          	ld	a2,0(s5)
ffffffffc020185a:	46a1                	li	a3,8
ffffffffc020185c:	8aae                	mv	s5,a1
ffffffffc020185e:	a839                	j	ffffffffc020187c <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201860:	03000513          	li	a0,48
ffffffffc0201864:	85a6                	mv	a1,s1
ffffffffc0201866:	e03e                	sd	a5,0(sp)
ffffffffc0201868:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020186a:	85a6                	mv	a1,s1
ffffffffc020186c:	07800513          	li	a0,120
ffffffffc0201870:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201872:	0aa1                	addi	s5,s5,8
ffffffffc0201874:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201878:	6782                	ld	a5,0(sp)
ffffffffc020187a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020187c:	876e                	mv	a4,s11
ffffffffc020187e:	85a6                	mv	a1,s1
ffffffffc0201880:	854a                	mv	a0,s2
ffffffffc0201882:	e1fff0ef          	jal	ra,ffffffffc02016a0 <printnum>
            break;
ffffffffc0201886:	b5c1                	j	ffffffffc0201746 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201888:	000ab603          	ld	a2,0(s5)
ffffffffc020188c:	0aa1                	addi	s5,s5,8
ffffffffc020188e:	1c060663          	beqz	a2,ffffffffc0201a5a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201892:	00160413          	addi	s0,a2,1
ffffffffc0201896:	17b05c63          	blez	s11,ffffffffc0201a0e <vprintfmt+0x302>
ffffffffc020189a:	02d00593          	li	a1,45
ffffffffc020189e:	14b79263          	bne	a5,a1,ffffffffc02019e2 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018a2:	00064783          	lbu	a5,0(a2)
ffffffffc02018a6:	0007851b          	sext.w	a0,a5
ffffffffc02018aa:	c905                	beqz	a0,ffffffffc02018da <vprintfmt+0x1ce>
ffffffffc02018ac:	000cc563          	bltz	s9,ffffffffc02018b6 <vprintfmt+0x1aa>
ffffffffc02018b0:	3cfd                	addiw	s9,s9,-1
ffffffffc02018b2:	036c8263          	beq	s9,s6,ffffffffc02018d6 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02018b6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018b8:	18098463          	beqz	s3,ffffffffc0201a40 <vprintfmt+0x334>
ffffffffc02018bc:	3781                	addiw	a5,a5,-32
ffffffffc02018be:	18fbf163          	bleu	a5,s7,ffffffffc0201a40 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02018c2:	03f00513          	li	a0,63
ffffffffc02018c6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018c8:	0405                	addi	s0,s0,1
ffffffffc02018ca:	fff44783          	lbu	a5,-1(s0)
ffffffffc02018ce:	3dfd                	addiw	s11,s11,-1
ffffffffc02018d0:	0007851b          	sext.w	a0,a5
ffffffffc02018d4:	fd61                	bnez	a0,ffffffffc02018ac <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02018d6:	e7b058e3          	blez	s11,ffffffffc0201746 <vprintfmt+0x3a>
ffffffffc02018da:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02018dc:	85a6                	mv	a1,s1
ffffffffc02018de:	02000513          	li	a0,32
ffffffffc02018e2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02018e4:	e60d81e3          	beqz	s11,ffffffffc0201746 <vprintfmt+0x3a>
ffffffffc02018e8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02018ea:	85a6                	mv	a1,s1
ffffffffc02018ec:	02000513          	li	a0,32
ffffffffc02018f0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02018f2:	fe0d94e3          	bnez	s11,ffffffffc02018da <vprintfmt+0x1ce>
ffffffffc02018f6:	bd81                	j	ffffffffc0201746 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02018f8:	4705                	li	a4,1
ffffffffc02018fa:	008a8593          	addi	a1,s5,8
ffffffffc02018fe:	01074463          	blt	a4,a6,ffffffffc0201906 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0201902:	12080063          	beqz	a6,ffffffffc0201a22 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201906:	000ab603          	ld	a2,0(s5)
ffffffffc020190a:	46a9                	li	a3,10
ffffffffc020190c:	8aae                	mv	s5,a1
ffffffffc020190e:	b7bd                	j	ffffffffc020187c <vprintfmt+0x170>
ffffffffc0201910:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201914:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201918:	846a                	mv	s0,s10
ffffffffc020191a:	b5ad                	j	ffffffffc0201784 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020191c:	85a6                	mv	a1,s1
ffffffffc020191e:	02500513          	li	a0,37
ffffffffc0201922:	9902                	jalr	s2
            break;
ffffffffc0201924:	b50d                	j	ffffffffc0201746 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201926:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020192a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020192e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201930:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201932:	e40dd9e3          	bgez	s11,ffffffffc0201784 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201936:	8de6                	mv	s11,s9
ffffffffc0201938:	5cfd                	li	s9,-1
ffffffffc020193a:	b5a9                	j	ffffffffc0201784 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020193c:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201940:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201944:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201946:	bd3d                	j	ffffffffc0201784 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201948:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020194c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201950:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201952:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201956:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020195a:	fcd56ce3          	bltu	a0,a3,ffffffffc0201932 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020195e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201960:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201964:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201968:	0196873b          	addw	a4,a3,s9
ffffffffc020196c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201970:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201974:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201978:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020197c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201980:	fcd57fe3          	bleu	a3,a0,ffffffffc020195e <vprintfmt+0x252>
ffffffffc0201984:	b77d                	j	ffffffffc0201932 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201986:	fffdc693          	not	a3,s11
ffffffffc020198a:	96fd                	srai	a3,a3,0x3f
ffffffffc020198c:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201990:	00144603          	lbu	a2,1(s0)
ffffffffc0201994:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201996:	846a                	mv	s0,s10
ffffffffc0201998:	b3f5                	j	ffffffffc0201784 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020199a:	85a6                	mv	a1,s1
ffffffffc020199c:	02500513          	li	a0,37
ffffffffc02019a0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02019a2:	fff44703          	lbu	a4,-1(s0)
ffffffffc02019a6:	02500793          	li	a5,37
ffffffffc02019aa:	8d22                	mv	s10,s0
ffffffffc02019ac:	d8f70de3          	beq	a4,a5,ffffffffc0201746 <vprintfmt+0x3a>
ffffffffc02019b0:	02500713          	li	a4,37
ffffffffc02019b4:	1d7d                	addi	s10,s10,-1
ffffffffc02019b6:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02019ba:	fee79de3          	bne	a5,a4,ffffffffc02019b4 <vprintfmt+0x2a8>
ffffffffc02019be:	b361                	j	ffffffffc0201746 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02019c0:	00001617          	auipc	a2,0x1
ffffffffc02019c4:	1a860613          	addi	a2,a2,424 # ffffffffc0202b68 <error_string+0xd8>
ffffffffc02019c8:	85a6                	mv	a1,s1
ffffffffc02019ca:	854a                	mv	a0,s2
ffffffffc02019cc:	0ac000ef          	jal	ra,ffffffffc0201a78 <printfmt>
ffffffffc02019d0:	bb9d                	j	ffffffffc0201746 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02019d2:	00001617          	auipc	a2,0x1
ffffffffc02019d6:	18e60613          	addi	a2,a2,398 # ffffffffc0202b60 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02019da:	00001417          	auipc	s0,0x1
ffffffffc02019de:	18740413          	addi	s0,s0,391 # ffffffffc0202b61 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019e2:	8532                	mv	a0,a2
ffffffffc02019e4:	85e6                	mv	a1,s9
ffffffffc02019e6:	e032                	sd	a2,0(sp)
ffffffffc02019e8:	e43e                	sd	a5,8(sp)
ffffffffc02019ea:	1c2000ef          	jal	ra,ffffffffc0201bac <strnlen>
ffffffffc02019ee:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02019f2:	6602                	ld	a2,0(sp)
ffffffffc02019f4:	01b05d63          	blez	s11,ffffffffc0201a0e <vprintfmt+0x302>
ffffffffc02019f8:	67a2                	ld	a5,8(sp)
ffffffffc02019fa:	2781                	sext.w	a5,a5
ffffffffc02019fc:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02019fe:	6522                	ld	a0,8(sp)
ffffffffc0201a00:	85a6                	mv	a1,s1
ffffffffc0201a02:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201a04:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201a06:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201a08:	6602                	ld	a2,0(sp)
ffffffffc0201a0a:	fe0d9ae3          	bnez	s11,ffffffffc02019fe <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a0e:	00064783          	lbu	a5,0(a2)
ffffffffc0201a12:	0007851b          	sext.w	a0,a5
ffffffffc0201a16:	e8051be3          	bnez	a0,ffffffffc02018ac <vprintfmt+0x1a0>
ffffffffc0201a1a:	b335                	j	ffffffffc0201746 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201a1c:	000aa403          	lw	s0,0(s5)
ffffffffc0201a20:	bbf1                	j	ffffffffc02017fc <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201a22:	000ae603          	lwu	a2,0(s5)
ffffffffc0201a26:	46a9                	li	a3,10
ffffffffc0201a28:	8aae                	mv	s5,a1
ffffffffc0201a2a:	bd89                	j	ffffffffc020187c <vprintfmt+0x170>
ffffffffc0201a2c:	000ae603          	lwu	a2,0(s5)
ffffffffc0201a30:	46c1                	li	a3,16
ffffffffc0201a32:	8aae                	mv	s5,a1
ffffffffc0201a34:	b5a1                	j	ffffffffc020187c <vprintfmt+0x170>
ffffffffc0201a36:	000ae603          	lwu	a2,0(s5)
ffffffffc0201a3a:	46a1                	li	a3,8
ffffffffc0201a3c:	8aae                	mv	s5,a1
ffffffffc0201a3e:	bd3d                	j	ffffffffc020187c <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201a40:	9902                	jalr	s2
ffffffffc0201a42:	b559                	j	ffffffffc02018c8 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201a44:	85a6                	mv	a1,s1
ffffffffc0201a46:	02d00513          	li	a0,45
ffffffffc0201a4a:	e03e                	sd	a5,0(sp)
ffffffffc0201a4c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201a4e:	8ace                	mv	s5,s3
ffffffffc0201a50:	40800633          	neg	a2,s0
ffffffffc0201a54:	46a9                	li	a3,10
ffffffffc0201a56:	6782                	ld	a5,0(sp)
ffffffffc0201a58:	b515                	j	ffffffffc020187c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201a5a:	01b05663          	blez	s11,ffffffffc0201a66 <vprintfmt+0x35a>
ffffffffc0201a5e:	02d00693          	li	a3,45
ffffffffc0201a62:	f6d798e3          	bne	a5,a3,ffffffffc02019d2 <vprintfmt+0x2c6>
ffffffffc0201a66:	00001417          	auipc	s0,0x1
ffffffffc0201a6a:	0fb40413          	addi	s0,s0,251 # ffffffffc0202b61 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a6e:	02800513          	li	a0,40
ffffffffc0201a72:	02800793          	li	a5,40
ffffffffc0201a76:	bd1d                	j	ffffffffc02018ac <vprintfmt+0x1a0>

ffffffffc0201a78 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a78:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201a7a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a7e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a80:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a82:	ec06                	sd	ra,24(sp)
ffffffffc0201a84:	f83a                	sd	a4,48(sp)
ffffffffc0201a86:	fc3e                	sd	a5,56(sp)
ffffffffc0201a88:	e0c2                	sd	a6,64(sp)
ffffffffc0201a8a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201a8c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a8e:	c7fff0ef          	jal	ra,ffffffffc020170c <vprintfmt>
}
ffffffffc0201a92:	60e2                	ld	ra,24(sp)
ffffffffc0201a94:	6161                	addi	sp,sp,80
ffffffffc0201a96:	8082                	ret

ffffffffc0201a98 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201a98:	715d                	addi	sp,sp,-80
ffffffffc0201a9a:	e486                	sd	ra,72(sp)
ffffffffc0201a9c:	e0a2                	sd	s0,64(sp)
ffffffffc0201a9e:	fc26                	sd	s1,56(sp)
ffffffffc0201aa0:	f84a                	sd	s2,48(sp)
ffffffffc0201aa2:	f44e                	sd	s3,40(sp)
ffffffffc0201aa4:	f052                	sd	s4,32(sp)
ffffffffc0201aa6:	ec56                	sd	s5,24(sp)
ffffffffc0201aa8:	e85a                	sd	s6,16(sp)
ffffffffc0201aaa:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201aac:	c901                	beqz	a0,ffffffffc0201abc <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201aae:	85aa                	mv	a1,a0
ffffffffc0201ab0:	00001517          	auipc	a0,0x1
ffffffffc0201ab4:	0c850513          	addi	a0,a0,200 # ffffffffc0202b78 <error_string+0xe8>
ffffffffc0201ab8:	dfefe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201abc:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201abe:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201ac0:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201ac2:	4aa9                	li	s5,10
ffffffffc0201ac4:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201ac6:	00004b97          	auipc	s7,0x4
ffffffffc0201aca:	54ab8b93          	addi	s7,s7,1354 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ace:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201ad2:	e5cfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201ad6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201ad8:	00054b63          	bltz	a0,ffffffffc0201aee <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201adc:	00a95b63          	ble	a0,s2,ffffffffc0201af2 <readline+0x5a>
ffffffffc0201ae0:	029a5463          	ble	s1,s4,ffffffffc0201b08 <readline+0x70>
        c = getchar();
ffffffffc0201ae4:	e4afe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201ae8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201aea:	fe0559e3          	bgez	a0,ffffffffc0201adc <readline+0x44>
            return NULL;
ffffffffc0201aee:	4501                	li	a0,0
ffffffffc0201af0:	a099                	j	ffffffffc0201b36 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201af2:	03341463          	bne	s0,s3,ffffffffc0201b1a <readline+0x82>
ffffffffc0201af6:	e8b9                	bnez	s1,ffffffffc0201b4c <readline+0xb4>
        c = getchar();
ffffffffc0201af8:	e36fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201afc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201afe:	fe0548e3          	bltz	a0,ffffffffc0201aee <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201b02:	fea958e3          	ble	a0,s2,ffffffffc0201af2 <readline+0x5a>
ffffffffc0201b06:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201b08:	8522                	mv	a0,s0
ffffffffc0201b0a:	de0fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201b0e:	009b87b3          	add	a5,s7,s1
ffffffffc0201b12:	00878023          	sb	s0,0(a5)
ffffffffc0201b16:	2485                	addiw	s1,s1,1
ffffffffc0201b18:	bf6d                	j	ffffffffc0201ad2 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201b1a:	01540463          	beq	s0,s5,ffffffffc0201b22 <readline+0x8a>
ffffffffc0201b1e:	fb641ae3          	bne	s0,s6,ffffffffc0201ad2 <readline+0x3a>
            cputchar(c);
ffffffffc0201b22:	8522                	mv	a0,s0
ffffffffc0201b24:	dc6fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201b28:	00004517          	auipc	a0,0x4
ffffffffc0201b2c:	4e850513          	addi	a0,a0,1256 # ffffffffc0206010 <edata>
ffffffffc0201b30:	94aa                	add	s1,s1,a0
ffffffffc0201b32:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201b36:	60a6                	ld	ra,72(sp)
ffffffffc0201b38:	6406                	ld	s0,64(sp)
ffffffffc0201b3a:	74e2                	ld	s1,56(sp)
ffffffffc0201b3c:	7942                	ld	s2,48(sp)
ffffffffc0201b3e:	79a2                	ld	s3,40(sp)
ffffffffc0201b40:	7a02                	ld	s4,32(sp)
ffffffffc0201b42:	6ae2                	ld	s5,24(sp)
ffffffffc0201b44:	6b42                	ld	s6,16(sp)
ffffffffc0201b46:	6ba2                	ld	s7,8(sp)
ffffffffc0201b48:	6161                	addi	sp,sp,80
ffffffffc0201b4a:	8082                	ret
            cputchar(c);
ffffffffc0201b4c:	4521                	li	a0,8
ffffffffc0201b4e:	d9cfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201b52:	34fd                	addiw	s1,s1,-1
ffffffffc0201b54:	bfbd                	j	ffffffffc0201ad2 <readline+0x3a>

ffffffffc0201b56 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201b56:	00004797          	auipc	a5,0x4
ffffffffc0201b5a:	4b278793          	addi	a5,a5,1202 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201b5e:	6398                	ld	a4,0(a5)
ffffffffc0201b60:	4781                	li	a5,0
ffffffffc0201b62:	88ba                	mv	a7,a4
ffffffffc0201b64:	852a                	mv	a0,a0
ffffffffc0201b66:	85be                	mv	a1,a5
ffffffffc0201b68:	863e                	mv	a2,a5
ffffffffc0201b6a:	00000073          	ecall
ffffffffc0201b6e:	87aa                	mv	a5,a0
}
ffffffffc0201b70:	8082                	ret

ffffffffc0201b72 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201b72:	00005797          	auipc	a5,0x5
ffffffffc0201b76:	8b678793          	addi	a5,a5,-1866 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201b7a:	6398                	ld	a4,0(a5)
ffffffffc0201b7c:	4781                	li	a5,0
ffffffffc0201b7e:	88ba                	mv	a7,a4
ffffffffc0201b80:	852a                	mv	a0,a0
ffffffffc0201b82:	85be                	mv	a1,a5
ffffffffc0201b84:	863e                	mv	a2,a5
ffffffffc0201b86:	00000073          	ecall
ffffffffc0201b8a:	87aa                	mv	a5,a0
}
ffffffffc0201b8c:	8082                	ret

ffffffffc0201b8e <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201b8e:	00004797          	auipc	a5,0x4
ffffffffc0201b92:	47278793          	addi	a5,a5,1138 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201b96:	639c                	ld	a5,0(a5)
ffffffffc0201b98:	4501                	li	a0,0
ffffffffc0201b9a:	88be                	mv	a7,a5
ffffffffc0201b9c:	852a                	mv	a0,a0
ffffffffc0201b9e:	85aa                	mv	a1,a0
ffffffffc0201ba0:	862a                	mv	a2,a0
ffffffffc0201ba2:	00000073          	ecall
ffffffffc0201ba6:	852a                	mv	a0,a0
ffffffffc0201ba8:	2501                	sext.w	a0,a0
ffffffffc0201baa:	8082                	ret

ffffffffc0201bac <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201bac:	c185                	beqz	a1,ffffffffc0201bcc <strnlen+0x20>
ffffffffc0201bae:	00054783          	lbu	a5,0(a0)
ffffffffc0201bb2:	cf89                	beqz	a5,ffffffffc0201bcc <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201bb4:	4781                	li	a5,0
ffffffffc0201bb6:	a021                	j	ffffffffc0201bbe <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201bb8:	00074703          	lbu	a4,0(a4)
ffffffffc0201bbc:	c711                	beqz	a4,ffffffffc0201bc8 <strnlen+0x1c>
        cnt ++;
ffffffffc0201bbe:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201bc0:	00f50733          	add	a4,a0,a5
ffffffffc0201bc4:	fef59ae3          	bne	a1,a5,ffffffffc0201bb8 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201bc8:	853e                	mv	a0,a5
ffffffffc0201bca:	8082                	ret
    size_t cnt = 0;
ffffffffc0201bcc:	4781                	li	a5,0
}
ffffffffc0201bce:	853e                	mv	a0,a5
ffffffffc0201bd0:	8082                	ret

ffffffffc0201bd2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201bd2:	00054783          	lbu	a5,0(a0)
ffffffffc0201bd6:	0005c703          	lbu	a4,0(a1)
ffffffffc0201bda:	cb91                	beqz	a5,ffffffffc0201bee <strcmp+0x1c>
ffffffffc0201bdc:	00e79c63          	bne	a5,a4,ffffffffc0201bf4 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201be0:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201be2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201be6:	0585                	addi	a1,a1,1
ffffffffc0201be8:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201bec:	fbe5                	bnez	a5,ffffffffc0201bdc <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201bee:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201bf0:	9d19                	subw	a0,a0,a4
ffffffffc0201bf2:	8082                	ret
ffffffffc0201bf4:	0007851b          	sext.w	a0,a5
ffffffffc0201bf8:	9d19                	subw	a0,a0,a4
ffffffffc0201bfa:	8082                	ret

ffffffffc0201bfc <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201bfc:	00054783          	lbu	a5,0(a0)
ffffffffc0201c00:	cb91                	beqz	a5,ffffffffc0201c14 <strchr+0x18>
        if (*s == c) {
ffffffffc0201c02:	00b79563          	bne	a5,a1,ffffffffc0201c0c <strchr+0x10>
ffffffffc0201c06:	a809                	j	ffffffffc0201c18 <strchr+0x1c>
ffffffffc0201c08:	00b78763          	beq	a5,a1,ffffffffc0201c16 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201c0c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201c0e:	00054783          	lbu	a5,0(a0)
ffffffffc0201c12:	fbfd                	bnez	a5,ffffffffc0201c08 <strchr+0xc>
    }
    return NULL;
ffffffffc0201c14:	4501                	li	a0,0
}
ffffffffc0201c16:	8082                	ret
ffffffffc0201c18:	8082                	ret

ffffffffc0201c1a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201c1a:	ca01                	beqz	a2,ffffffffc0201c2a <memset+0x10>
ffffffffc0201c1c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201c1e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201c20:	0785                	addi	a5,a5,1
ffffffffc0201c22:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201c26:	fec79de3          	bne	a5,a2,ffffffffc0201c20 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201c2a:	8082                	ret
