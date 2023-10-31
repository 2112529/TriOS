
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
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	02250513          	addi	a0,a0,34 # ffffffffc020a058 <edata>
ffffffffc020003e:	00015617          	auipc	a2,0x15
ffffffffc0200042:	5ba60613          	addi	a2,a2,1466 # ffffffffc02155f8 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	599040ef          	jal	ra,ffffffffc0204de6 <memset>

    cons_init();                // init the console
ffffffffc0200052:	4b4000ef          	jal	ra,ffffffffc0200506 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	dea58593          	addi	a1,a1,-534 # ffffffffc0204e40 <etext>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	e0250513          	addi	a0,a0,-510 # ffffffffc0204e60 <etext+0x20>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	16c000ef          	jal	ra,ffffffffc02001d6 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	010020ef          	jal	ra,ffffffffc020207e <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	56c000ef          	jal	ra,ffffffffc02005de <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5dc000ef          	jal	ra,ffffffffc0200652 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	209030ef          	jal	ra,ffffffffc0203a82 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	574040ef          	jal	ra,ffffffffc02045f2 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4f8000ef          	jal	ra,ffffffffc020057a <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	31b020ef          	jal	ra,ffffffffc0202ba0 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	426000ef          	jal	ra,ffffffffc02004b0 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	544000ef          	jal	ra,ffffffffc02005d2 <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	754040ef          	jal	ra,ffffffffc02047e6 <cpu_idle>

ffffffffc0200096 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200096:	715d                	addi	sp,sp,-80
ffffffffc0200098:	e486                	sd	ra,72(sp)
ffffffffc020009a:	e0a2                	sd	s0,64(sp)
ffffffffc020009c:	fc26                	sd	s1,56(sp)
ffffffffc020009e:	f84a                	sd	s2,48(sp)
ffffffffc02000a0:	f44e                	sd	s3,40(sp)
ffffffffc02000a2:	f052                	sd	s4,32(sp)
ffffffffc02000a4:	ec56                	sd	s5,24(sp)
ffffffffc02000a6:	e85a                	sd	s6,16(sp)
ffffffffc02000a8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000aa:	c901                	beqz	a0,ffffffffc02000ba <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000ac:	85aa                	mv	a1,a0
ffffffffc02000ae:	00005517          	auipc	a0,0x5
ffffffffc02000b2:	dba50513          	addi	a0,a0,-582 # ffffffffc0204e68 <etext+0x28>
ffffffffc02000b6:	0d8000ef          	jal	ra,ffffffffc020018e <cprintf>
readline(const char *prompt) {
ffffffffc02000ba:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000bc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000be:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c0:	4aa9                	li	s5,10
ffffffffc02000c2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c4:	0000ab97          	auipc	s7,0xa
ffffffffc02000c8:	f94b8b93          	addi	s7,s7,-108 # ffffffffc020a058 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	0f6000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	ble	s1,s4,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	0e4000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000e8:	fe0559e3          	bgez	a0,ffffffffc02000da <readline+0x44>
            return NULL;
ffffffffc02000ec:	4501                	li	a0,0
ffffffffc02000ee:	a099                	j	ffffffffc0200134 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f0:	03341463          	bne	s0,s3,ffffffffc0200118 <readline+0x82>
ffffffffc02000f4:	e8b9                	bnez	s1,ffffffffc020014a <readline+0xb4>
        c = getchar();
ffffffffc02000f6:	0d0000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000fa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000fc:	fe0548e3          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200100:	fea958e3          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc0200104:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200106:	8522                	mv	a0,s0
ffffffffc0200108:	0ba000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i ++] = c;
ffffffffc020010c:	009b87b3          	add	a5,s7,s1
ffffffffc0200110:	00878023          	sb	s0,0(a5)
ffffffffc0200114:	2485                	addiw	s1,s1,1
ffffffffc0200116:	bf6d                	j	ffffffffc02000d0 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200118:	01540463          	beq	s0,s5,ffffffffc0200120 <readline+0x8a>
ffffffffc020011c:	fb641ae3          	bne	s0,s6,ffffffffc02000d0 <readline+0x3a>
            cputchar(c);
ffffffffc0200120:	8522                	mv	a0,s0
ffffffffc0200122:	0a0000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i] = '\0';
ffffffffc0200126:	0000a517          	auipc	a0,0xa
ffffffffc020012a:	f3250513          	addi	a0,a0,-206 # ffffffffc020a058 <edata>
ffffffffc020012e:	94aa                	add	s1,s1,a0
ffffffffc0200130:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200134:	60a6                	ld	ra,72(sp)
ffffffffc0200136:	6406                	ld	s0,64(sp)
ffffffffc0200138:	74e2                	ld	s1,56(sp)
ffffffffc020013a:	7942                	ld	s2,48(sp)
ffffffffc020013c:	79a2                	ld	s3,40(sp)
ffffffffc020013e:	7a02                	ld	s4,32(sp)
ffffffffc0200140:	6ae2                	ld	s5,24(sp)
ffffffffc0200142:	6b42                	ld	s6,16(sp)
ffffffffc0200144:	6ba2                	ld	s7,8(sp)
ffffffffc0200146:	6161                	addi	sp,sp,80
ffffffffc0200148:	8082                	ret
            cputchar(c);
ffffffffc020014a:	4521                	li	a0,8
ffffffffc020014c:	076000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            i --;
ffffffffc0200150:	34fd                	addiw	s1,s1,-1
ffffffffc0200152:	bfbd                	j	ffffffffc02000d0 <readline+0x3a>

ffffffffc0200154 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200154:	1141                	addi	sp,sp,-16
ffffffffc0200156:	e022                	sd	s0,0(sp)
ffffffffc0200158:	e406                	sd	ra,8(sp)
ffffffffc020015a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020015c:	3ac000ef          	jal	ra,ffffffffc0200508 <cons_putc>
    (*cnt) ++;
ffffffffc0200160:	401c                	lw	a5,0(s0)
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200164:	2785                	addiw	a5,a5,1
ffffffffc0200166:	c01c                	sw	a5,0(s0)
}
ffffffffc0200168:	6402                	ld	s0,0(sp)
ffffffffc020016a:	0141                	addi	sp,sp,16
ffffffffc020016c:	8082                	ret

ffffffffc020016e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020016e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	86ae                	mv	a3,a1
ffffffffc0200172:	862a                	mv	a2,a0
ffffffffc0200174:	006c                	addi	a1,sp,12
ffffffffc0200176:	00000517          	auipc	a0,0x0
ffffffffc020017a:	fde50513          	addi	a0,a0,-34 # ffffffffc0200154 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc020017e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200180:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200182:	03b040ef          	jal	ra,ffffffffc02049bc <vprintfmt>
    return cnt;
}
ffffffffc0200186:	60e2                	ld	ra,24(sp)
ffffffffc0200188:	4532                	lw	a0,12(sp)
ffffffffc020018a:	6105                	addi	sp,sp,32
ffffffffc020018c:	8082                	ret

ffffffffc020018e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020018e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200194:	f42e                	sd	a1,40(sp)
ffffffffc0200196:	f832                	sd	a2,48(sp)
ffffffffc0200198:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019a:	862a                	mv	a2,a0
ffffffffc020019c:	004c                	addi	a1,sp,4
ffffffffc020019e:	00000517          	auipc	a0,0x0
ffffffffc02001a2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200154 <cputch>
ffffffffc02001a6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001a8:	ec06                	sd	ra,24(sp)
ffffffffc02001aa:	e0ba                	sd	a4,64(sp)
ffffffffc02001ac:	e4be                	sd	a5,72(sp)
ffffffffc02001ae:	e8c2                	sd	a6,80(sp)
ffffffffc02001b0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001b6:	007040ef          	jal	ra,ffffffffc02049bc <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ba:	60e2                	ld	ra,24(sp)
ffffffffc02001bc:	4512                	lw	a0,4(sp)
ffffffffc02001be:	6125                	addi	sp,sp,96
ffffffffc02001c0:	8082                	ret

ffffffffc02001c2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c2:	3460006f          	j	ffffffffc0200508 <cons_putc>

ffffffffc02001c6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001c6:	1141                	addi	sp,sp,-16
ffffffffc02001c8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001ca:	374000ef          	jal	ra,ffffffffc020053e <cons_getc>
ffffffffc02001ce:	dd75                	beqz	a0,ffffffffc02001ca <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001d0:	60a2                	ld	ra,8(sp)
ffffffffc02001d2:	0141                	addi	sp,sp,16
ffffffffc02001d4:	8082                	ret

ffffffffc02001d6 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001d6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001d8:	00005517          	auipc	a0,0x5
ffffffffc02001dc:	cc850513          	addi	a0,a0,-824 # ffffffffc0204ea0 <etext+0x60>
void print_kerninfo(void) {
ffffffffc02001e0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001e2:	fadff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001e6:	00000597          	auipc	a1,0x0
ffffffffc02001ea:	e5058593          	addi	a1,a1,-432 # ffffffffc0200036 <kern_init>
ffffffffc02001ee:	00005517          	auipc	a0,0x5
ffffffffc02001f2:	cd250513          	addi	a0,a0,-814 # ffffffffc0204ec0 <etext+0x80>
ffffffffc02001f6:	f99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001fa:	00005597          	auipc	a1,0x5
ffffffffc02001fe:	c4658593          	addi	a1,a1,-954 # ffffffffc0204e40 <etext>
ffffffffc0200202:	00005517          	auipc	a0,0x5
ffffffffc0200206:	cde50513          	addi	a0,a0,-802 # ffffffffc0204ee0 <etext+0xa0>
ffffffffc020020a:	f85ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020020e:	0000a597          	auipc	a1,0xa
ffffffffc0200212:	e4a58593          	addi	a1,a1,-438 # ffffffffc020a058 <edata>
ffffffffc0200216:	00005517          	auipc	a0,0x5
ffffffffc020021a:	cea50513          	addi	a0,a0,-790 # ffffffffc0204f00 <etext+0xc0>
ffffffffc020021e:	f71ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200222:	00015597          	auipc	a1,0x15
ffffffffc0200226:	3d658593          	addi	a1,a1,982 # ffffffffc02155f8 <end>
ffffffffc020022a:	00005517          	auipc	a0,0x5
ffffffffc020022e:	cf650513          	addi	a0,a0,-778 # ffffffffc0204f20 <etext+0xe0>
ffffffffc0200232:	f5dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200236:	00015597          	auipc	a1,0x15
ffffffffc020023a:	7c158593          	addi	a1,a1,1985 # ffffffffc02159f7 <end+0x3ff>
ffffffffc020023e:	00000797          	auipc	a5,0x0
ffffffffc0200242:	df878793          	addi	a5,a5,-520 # ffffffffc0200036 <kern_init>
ffffffffc0200246:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020024a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020024e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200250:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200254:	95be                	add	a1,a1,a5
ffffffffc0200256:	85a9                	srai	a1,a1,0xa
ffffffffc0200258:	00005517          	auipc	a0,0x5
ffffffffc020025c:	ce850513          	addi	a0,a0,-792 # ffffffffc0204f40 <etext+0x100>
}
ffffffffc0200260:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200262:	f2dff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200266 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200266:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200268:	00005617          	auipc	a2,0x5
ffffffffc020026c:	c0860613          	addi	a2,a2,-1016 # ffffffffc0204e70 <etext+0x30>
ffffffffc0200270:	04d00593          	li	a1,77
ffffffffc0200274:	00005517          	auipc	a0,0x5
ffffffffc0200278:	c1450513          	addi	a0,a0,-1004 # ffffffffc0204e88 <etext+0x48>
void print_stackframe(void) {
ffffffffc020027c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020027e:	1d2000ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200282 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200284:	00005617          	auipc	a2,0x5
ffffffffc0200288:	dcc60613          	addi	a2,a2,-564 # ffffffffc0205050 <commands+0xe0>
ffffffffc020028c:	00005597          	auipc	a1,0x5
ffffffffc0200290:	de458593          	addi	a1,a1,-540 # ffffffffc0205070 <commands+0x100>
ffffffffc0200294:	00005517          	auipc	a0,0x5
ffffffffc0200298:	de450513          	addi	a0,a0,-540 # ffffffffc0205078 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020029c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020029e:	ef1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002a2:	00005617          	auipc	a2,0x5
ffffffffc02002a6:	de660613          	addi	a2,a2,-538 # ffffffffc0205088 <commands+0x118>
ffffffffc02002aa:	00005597          	auipc	a1,0x5
ffffffffc02002ae:	e0658593          	addi	a1,a1,-506 # ffffffffc02050b0 <commands+0x140>
ffffffffc02002b2:	00005517          	auipc	a0,0x5
ffffffffc02002b6:	dc650513          	addi	a0,a0,-570 # ffffffffc0205078 <commands+0x108>
ffffffffc02002ba:	ed5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002be:	00005617          	auipc	a2,0x5
ffffffffc02002c2:	e0260613          	addi	a2,a2,-510 # ffffffffc02050c0 <commands+0x150>
ffffffffc02002c6:	00005597          	auipc	a1,0x5
ffffffffc02002ca:	e1a58593          	addi	a1,a1,-486 # ffffffffc02050e0 <commands+0x170>
ffffffffc02002ce:	00005517          	auipc	a0,0x5
ffffffffc02002d2:	daa50513          	addi	a0,a0,-598 # ffffffffc0205078 <commands+0x108>
ffffffffc02002d6:	eb9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc02002da:	60a2                	ld	ra,8(sp)
ffffffffc02002dc:	4501                	li	a0,0
ffffffffc02002de:	0141                	addi	sp,sp,16
ffffffffc02002e0:	8082                	ret

ffffffffc02002e2 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
ffffffffc02002e4:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002e6:	ef1ff0ef          	jal	ra,ffffffffc02001d6 <print_kerninfo>
    return 0;
}
ffffffffc02002ea:	60a2                	ld	ra,8(sp)
ffffffffc02002ec:	4501                	li	a0,0
ffffffffc02002ee:	0141                	addi	sp,sp,16
ffffffffc02002f0:	8082                	ret

ffffffffc02002f2 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002f2:	1141                	addi	sp,sp,-16
ffffffffc02002f4:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002f6:	f71ff0ef          	jal	ra,ffffffffc0200266 <print_stackframe>
    return 0;
}
ffffffffc02002fa:	60a2                	ld	ra,8(sp)
ffffffffc02002fc:	4501                	li	a0,0
ffffffffc02002fe:	0141                	addi	sp,sp,16
ffffffffc0200300:	8082                	ret

ffffffffc0200302 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200302:	7115                	addi	sp,sp,-224
ffffffffc0200304:	e962                	sd	s8,144(sp)
ffffffffc0200306:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200308:	00005517          	auipc	a0,0x5
ffffffffc020030c:	cb050513          	addi	a0,a0,-848 # ffffffffc0204fb8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200310:	ed86                	sd	ra,216(sp)
ffffffffc0200312:	e9a2                	sd	s0,208(sp)
ffffffffc0200314:	e5a6                	sd	s1,200(sp)
ffffffffc0200316:	e1ca                	sd	s2,192(sp)
ffffffffc0200318:	fd4e                	sd	s3,184(sp)
ffffffffc020031a:	f952                	sd	s4,176(sp)
ffffffffc020031c:	f556                	sd	s5,168(sp)
ffffffffc020031e:	f15a                	sd	s6,160(sp)
ffffffffc0200320:	ed5e                	sd	s7,152(sp)
ffffffffc0200322:	e566                	sd	s9,136(sp)
ffffffffc0200324:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200326:	e69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020032a:	00005517          	auipc	a0,0x5
ffffffffc020032e:	cb650513          	addi	a0,a0,-842 # ffffffffc0204fe0 <commands+0x70>
ffffffffc0200332:	e5dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200336:	000c0563          	beqz	s8,ffffffffc0200340 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020033a:	8562                	mv	a0,s8
ffffffffc020033c:	4fe000ef          	jal	ra,ffffffffc020083a <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200340:	4501                	li	a0,0
ffffffffc0200342:	4581                	li	a1,0
ffffffffc0200344:	4601                	li	a2,0
ffffffffc0200346:	48a1                	li	a7,8
ffffffffc0200348:	00000073          	ecall
ffffffffc020034c:	00005c97          	auipc	s9,0x5
ffffffffc0200350:	c24c8c93          	addi	s9,s9,-988 # ffffffffc0204f70 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200354:	00005997          	auipc	s3,0x5
ffffffffc0200358:	cb498993          	addi	s3,s3,-844 # ffffffffc0205008 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020035c:	00005917          	auipc	s2,0x5
ffffffffc0200360:	cb490913          	addi	s2,s2,-844 # ffffffffc0205010 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200364:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200366:	00005b17          	auipc	s6,0x5
ffffffffc020036a:	cb2b0b13          	addi	s6,s6,-846 # ffffffffc0205018 <commands+0xa8>
    if (argc == 0) {
ffffffffc020036e:	00005a97          	auipc	s5,0x5
ffffffffc0200372:	d02a8a93          	addi	s5,s5,-766 # ffffffffc0205070 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200376:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	854e                	mv	a0,s3
ffffffffc020037a:	d1dff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc020037e:	842a                	mv	s0,a0
ffffffffc0200380:	dd65                	beqz	a0,ffffffffc0200378 <kmonitor+0x76>
ffffffffc0200382:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200386:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200388:	c999                	beqz	a1,ffffffffc020039e <kmonitor+0x9c>
ffffffffc020038a:	854a                	mv	a0,s2
ffffffffc020038c:	23d040ef          	jal	ra,ffffffffc0204dc8 <strchr>
ffffffffc0200390:	c925                	beqz	a0,ffffffffc0200400 <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc0200392:	00144583          	lbu	a1,1(s0)
ffffffffc0200396:	00040023          	sb	zero,0(s0)
ffffffffc020039a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020039c:	f5fd                	bnez	a1,ffffffffc020038a <kmonitor+0x88>
    if (argc == 0) {
ffffffffc020039e:	dce9                	beqz	s1,ffffffffc0200378 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003a0:	6582                	ld	a1,0(sp)
ffffffffc02003a2:	00005d17          	auipc	s10,0x5
ffffffffc02003a6:	bced0d13          	addi	s10,s10,-1074 # ffffffffc0204f70 <commands>
    if (argc == 0) {
ffffffffc02003aa:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ac:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ae:	0d61                	addi	s10,s10,24
ffffffffc02003b0:	1ef040ef          	jal	ra,ffffffffc0204d9e <strcmp>
ffffffffc02003b4:	c919                	beqz	a0,ffffffffc02003ca <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b6:	2405                	addiw	s0,s0,1
ffffffffc02003b8:	09740463          	beq	s0,s7,ffffffffc0200440 <kmonitor+0x13e>
ffffffffc02003bc:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	0d61                	addi	s10,s10,24
ffffffffc02003c4:	1db040ef          	jal	ra,ffffffffc0204d9e <strcmp>
ffffffffc02003c8:	f57d                	bnez	a0,ffffffffc02003b6 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003ca:	00141793          	slli	a5,s0,0x1
ffffffffc02003ce:	97a2                	add	a5,a5,s0
ffffffffc02003d0:	078e                	slli	a5,a5,0x3
ffffffffc02003d2:	97e6                	add	a5,a5,s9
ffffffffc02003d4:	6b9c                	ld	a5,16(a5)
ffffffffc02003d6:	8662                	mv	a2,s8
ffffffffc02003d8:	002c                	addi	a1,sp,8
ffffffffc02003da:	fff4851b          	addiw	a0,s1,-1
ffffffffc02003de:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003e0:	f8055ce3          	bgez	a0,ffffffffc0200378 <kmonitor+0x76>
}
ffffffffc02003e4:	60ee                	ld	ra,216(sp)
ffffffffc02003e6:	644e                	ld	s0,208(sp)
ffffffffc02003e8:	64ae                	ld	s1,200(sp)
ffffffffc02003ea:	690e                	ld	s2,192(sp)
ffffffffc02003ec:	79ea                	ld	s3,184(sp)
ffffffffc02003ee:	7a4a                	ld	s4,176(sp)
ffffffffc02003f0:	7aaa                	ld	s5,168(sp)
ffffffffc02003f2:	7b0a                	ld	s6,160(sp)
ffffffffc02003f4:	6bea                	ld	s7,152(sp)
ffffffffc02003f6:	6c4a                	ld	s8,144(sp)
ffffffffc02003f8:	6caa                	ld	s9,136(sp)
ffffffffc02003fa:	6d0a                	ld	s10,128(sp)
ffffffffc02003fc:	612d                	addi	sp,sp,224
ffffffffc02003fe:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200400:	00044783          	lbu	a5,0(s0)
ffffffffc0200404:	dfc9                	beqz	a5,ffffffffc020039e <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200406:	03448863          	beq	s1,s4,ffffffffc0200436 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc020040a:	00349793          	slli	a5,s1,0x3
ffffffffc020040e:	0118                	addi	a4,sp,128
ffffffffc0200410:	97ba                	add	a5,a5,a4
ffffffffc0200412:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200416:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020041a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041c:	e591                	bnez	a1,ffffffffc0200428 <kmonitor+0x126>
ffffffffc020041e:	b749                	j	ffffffffc02003a0 <kmonitor+0x9e>
            buf ++;
ffffffffc0200420:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200422:	00044583          	lbu	a1,0(s0)
ffffffffc0200426:	ddad                	beqz	a1,ffffffffc02003a0 <kmonitor+0x9e>
ffffffffc0200428:	854a                	mv	a0,s2
ffffffffc020042a:	19f040ef          	jal	ra,ffffffffc0204dc8 <strchr>
ffffffffc020042e:	d96d                	beqz	a0,ffffffffc0200420 <kmonitor+0x11e>
ffffffffc0200430:	00044583          	lbu	a1,0(s0)
ffffffffc0200434:	bf91                	j	ffffffffc0200388 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	45c1                	li	a1,16
ffffffffc0200438:	855a                	mv	a0,s6
ffffffffc020043a:	d55ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020043e:	b7f1                	j	ffffffffc020040a <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200440:	6582                	ld	a1,0(sp)
ffffffffc0200442:	00005517          	auipc	a0,0x5
ffffffffc0200446:	bf650513          	addi	a0,a0,-1034 # ffffffffc0205038 <commands+0xc8>
ffffffffc020044a:	d45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc020044e:	b72d                	j	ffffffffc0200378 <kmonitor+0x76>

ffffffffc0200450 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200450:	00015317          	auipc	t1,0x15
ffffffffc0200454:	01830313          	addi	t1,t1,24 # ffffffffc0215468 <is_panic>
ffffffffc0200458:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020045c:	715d                	addi	sp,sp,-80
ffffffffc020045e:	ec06                	sd	ra,24(sp)
ffffffffc0200460:	e822                	sd	s0,16(sp)
ffffffffc0200462:	f436                	sd	a3,40(sp)
ffffffffc0200464:	f83a                	sd	a4,48(sp)
ffffffffc0200466:	fc3e                	sd	a5,56(sp)
ffffffffc0200468:	e0c2                	sd	a6,64(sp)
ffffffffc020046a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020046c:	02031c63          	bnez	t1,ffffffffc02004a4 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200470:	4785                	li	a5,1
ffffffffc0200472:	8432                	mv	s0,a2
ffffffffc0200474:	00015717          	auipc	a4,0x15
ffffffffc0200478:	fef72a23          	sw	a5,-12(a4) # ffffffffc0215468 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047c:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020047e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200480:	85aa                	mv	a1,a0
ffffffffc0200482:	00005517          	auipc	a0,0x5
ffffffffc0200486:	c6e50513          	addi	a0,a0,-914 # ffffffffc02050f0 <commands+0x180>
    va_start(ap, fmt);
ffffffffc020048a:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020048c:	d03ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200490:	65a2                	ld	a1,8(sp)
ffffffffc0200492:	8522                	mv	a0,s0
ffffffffc0200494:	cdbff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc0200498:	00006517          	auipc	a0,0x6
ffffffffc020049c:	c4850513          	addi	a0,a0,-952 # ffffffffc02060e0 <default_pmm_manager+0x500>
ffffffffc02004a0:	cefff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02004a4:	134000ef          	jal	ra,ffffffffc02005d8 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004a8:	4501                	li	a0,0
ffffffffc02004aa:	e59ff0ef          	jal	ra,ffffffffc0200302 <kmonitor>
ffffffffc02004ae:	bfed                	j	ffffffffc02004a8 <__panic+0x58>

ffffffffc02004b0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004b0:	67e1                	lui	a5,0x18
ffffffffc02004b2:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02004b6:	00015717          	auipc	a4,0x15
ffffffffc02004ba:	faf73d23          	sd	a5,-70(a4) # ffffffffc0215470 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004be:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004c2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004c4:	953e                	add	a0,a0,a5
ffffffffc02004c6:	4601                	li	a2,0
ffffffffc02004c8:	4881                	li	a7,0
ffffffffc02004ca:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004ce:	02000793          	li	a5,32
ffffffffc02004d2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d6:	00005517          	auipc	a0,0x5
ffffffffc02004da:	c3a50513          	addi	a0,a0,-966 # ffffffffc0205110 <commands+0x1a0>
    ticks = 0;
ffffffffc02004de:	00015797          	auipc	a5,0x15
ffffffffc02004e2:	fe07b523          	sd	zero,-22(a5) # ffffffffc02154c8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004e6:	ca9ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02004ea <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004ea:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004ee:	00015797          	auipc	a5,0x15
ffffffffc02004f2:	f8278793          	addi	a5,a5,-126 # ffffffffc0215470 <timebase>
ffffffffc02004f6:	639c                	ld	a5,0(a5)
ffffffffc02004f8:	4581                	li	a1,0
ffffffffc02004fa:	4601                	li	a2,0
ffffffffc02004fc:	953e                	add	a0,a0,a5
ffffffffc02004fe:	4881                	li	a7,0
ffffffffc0200500:	00000073          	ecall
ffffffffc0200504:	8082                	ret

ffffffffc0200506 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200506:	8082                	ret

ffffffffc0200508 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200508:	100027f3          	csrr	a5,sstatus
ffffffffc020050c:	8b89                	andi	a5,a5,2
ffffffffc020050e:	0ff57513          	andi	a0,a0,255
ffffffffc0200512:	e799                	bnez	a5,ffffffffc0200520 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200514:	4581                	li	a1,0
ffffffffc0200516:	4601                	li	a2,0
ffffffffc0200518:	4885                	li	a7,1
ffffffffc020051a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020051e:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200520:	1101                	addi	sp,sp,-32
ffffffffc0200522:	ec06                	sd	ra,24(sp)
ffffffffc0200524:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200526:	0b2000ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc020052a:	6522                	ld	a0,8(sp)
ffffffffc020052c:	4581                	li	a1,0
ffffffffc020052e:	4601                	li	a2,0
ffffffffc0200530:	4885                	li	a7,1
ffffffffc0200532:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200536:	60e2                	ld	ra,24(sp)
ffffffffc0200538:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020053a:	0980006f          	j	ffffffffc02005d2 <intr_enable>

ffffffffc020053e <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020053e:	100027f3          	csrr	a5,sstatus
ffffffffc0200542:	8b89                	andi	a5,a5,2
ffffffffc0200544:	eb89                	bnez	a5,ffffffffc0200556 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200546:	4501                	li	a0,0
ffffffffc0200548:	4581                	li	a1,0
ffffffffc020054a:	4601                	li	a2,0
ffffffffc020054c:	4889                	li	a7,2
ffffffffc020054e:	00000073          	ecall
ffffffffc0200552:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200554:	8082                	ret
int cons_getc(void) {
ffffffffc0200556:	1101                	addi	sp,sp,-32
ffffffffc0200558:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020055a:	07e000ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	4581                	li	a1,0
ffffffffc0200562:	4601                	li	a2,0
ffffffffc0200564:	4889                	li	a7,2
ffffffffc0200566:	00000073          	ecall
ffffffffc020056a:	2501                	sext.w	a0,a0
ffffffffc020056c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020056e:	064000ef          	jal	ra,ffffffffc02005d2 <intr_enable>
}
ffffffffc0200572:	60e2                	ld	ra,24(sp)
ffffffffc0200574:	6522                	ld	a0,8(sp)
ffffffffc0200576:	6105                	addi	sp,sp,32
ffffffffc0200578:	8082                	ret

ffffffffc020057a <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020057a:	8082                	ret

ffffffffc020057c <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020057c:	00253513          	sltiu	a0,a0,2
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200582:	03800513          	li	a0,56
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200588:	0000a797          	auipc	a5,0xa
ffffffffc020058c:	ed078793          	addi	a5,a5,-304 # ffffffffc020a458 <ide>
ffffffffc0200590:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200594:	1141                	addi	sp,sp,-16
ffffffffc0200596:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200598:	95be                	add	a1,a1,a5
ffffffffc020059a:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020059e:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005a0:	059040ef          	jal	ra,ffffffffc0204df8 <memcpy>
    return 0;
}
ffffffffc02005a4:	60a2                	ld	ra,8(sp)
ffffffffc02005a6:	4501                	li	a0,0
ffffffffc02005a8:	0141                	addi	sp,sp,16
ffffffffc02005aa:	8082                	ret

ffffffffc02005ac <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02005ac:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005ae:	0095979b          	slliw	a5,a1,0x9
ffffffffc02005b2:	0000a517          	auipc	a0,0xa
ffffffffc02005b6:	ea650513          	addi	a0,a0,-346 # ffffffffc020a458 <ide>
                   size_t nsecs) {
ffffffffc02005ba:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005bc:	00969613          	slli	a2,a3,0x9
ffffffffc02005c0:	85ba                	mv	a1,a4
ffffffffc02005c2:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02005c4:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005c6:	033040ef          	jal	ra,ffffffffc0204df8 <memcpy>
    return 0;
}
ffffffffc02005ca:	60a2                	ld	ra,8(sp)
ffffffffc02005cc:	4501                	li	a0,0
ffffffffc02005ce:	0141                	addi	sp,sp,16
ffffffffc02005d0:	8082                	ret

ffffffffc02005d2 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d2:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005d6:	8082                	ret

ffffffffc02005d8 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d8:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005dc:	8082                	ret

ffffffffc02005de <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005de:	8082                	ret

ffffffffc02005e0 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005e0:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005e4:	1141                	addi	sp,sp,-16
ffffffffc02005e6:	e022                	sd	s0,0(sp)
ffffffffc02005e8:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005ea:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ee:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005f0:	11053583          	ld	a1,272(a0)
ffffffffc02005f4:	05500613          	li	a2,85
ffffffffc02005f8:	c399                	beqz	a5,ffffffffc02005fe <pgfault_handler+0x1e>
ffffffffc02005fa:	04b00613          	li	a2,75
ffffffffc02005fe:	11843703          	ld	a4,280(s0)
ffffffffc0200602:	47bd                	li	a5,15
ffffffffc0200604:	05700693          	li	a3,87
ffffffffc0200608:	00f70463          	beq	a4,a5,ffffffffc0200610 <pgfault_handler+0x30>
ffffffffc020060c:	05200693          	li	a3,82
ffffffffc0200610:	00005517          	auipc	a0,0x5
ffffffffc0200614:	e6050513          	addi	a0,a0,-416 # ffffffffc0205470 <commands+0x500>
ffffffffc0200618:	b77ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020061c:	00015797          	auipc	a5,0x15
ffffffffc0200620:	fc478793          	addi	a5,a5,-60 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0200624:	6388                	ld	a0,0(a5)
ffffffffc0200626:	c911                	beqz	a0,ffffffffc020063a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200628:	11043603          	ld	a2,272(s0)
ffffffffc020062c:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200630:	6402                	ld	s0,0(sp)
ffffffffc0200632:	60a2                	ld	ra,8(sp)
ffffffffc0200634:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200636:	1930306f          	j	ffffffffc0203fc8 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020063a:	00005617          	auipc	a2,0x5
ffffffffc020063e:	e5660613          	addi	a2,a2,-426 # ffffffffc0205490 <commands+0x520>
ffffffffc0200642:	06300593          	li	a1,99
ffffffffc0200646:	00005517          	auipc	a0,0x5
ffffffffc020064a:	e6250513          	addi	a0,a0,-414 # ffffffffc02054a8 <commands+0x538>
ffffffffc020064e:	e03ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200652 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200652:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200656:	00000797          	auipc	a5,0x0
ffffffffc020065a:	50278793          	addi	a5,a5,1282 # ffffffffc0200b58 <__alltraps>
ffffffffc020065e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200662:	000407b7          	lui	a5,0x40
ffffffffc0200666:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020066a:	8082                	ret

ffffffffc020066c <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020066e:	1141                	addi	sp,sp,-16
ffffffffc0200670:	e022                	sd	s0,0(sp)
ffffffffc0200672:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	00005517          	auipc	a0,0x5
ffffffffc0200678:	e4c50513          	addi	a0,a0,-436 # ffffffffc02054c0 <commands+0x550>
void print_regs(struct pushregs *gpr) {
ffffffffc020067c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067e:	b11ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200682:	640c                	ld	a1,8(s0)
ffffffffc0200684:	00005517          	auipc	a0,0x5
ffffffffc0200688:	e5450513          	addi	a0,a0,-428 # ffffffffc02054d8 <commands+0x568>
ffffffffc020068c:	b03ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200690:	680c                	ld	a1,16(s0)
ffffffffc0200692:	00005517          	auipc	a0,0x5
ffffffffc0200696:	e5e50513          	addi	a0,a0,-418 # ffffffffc02054f0 <commands+0x580>
ffffffffc020069a:	af5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069e:	6c0c                	ld	a1,24(s0)
ffffffffc02006a0:	00005517          	auipc	a0,0x5
ffffffffc02006a4:	e6850513          	addi	a0,a0,-408 # ffffffffc0205508 <commands+0x598>
ffffffffc02006a8:	ae7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006ac:	700c                	ld	a1,32(s0)
ffffffffc02006ae:	00005517          	auipc	a0,0x5
ffffffffc02006b2:	e7250513          	addi	a0,a0,-398 # ffffffffc0205520 <commands+0x5b0>
ffffffffc02006b6:	ad9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ba:	740c                	ld	a1,40(s0)
ffffffffc02006bc:	00005517          	auipc	a0,0x5
ffffffffc02006c0:	e7c50513          	addi	a0,a0,-388 # ffffffffc0205538 <commands+0x5c8>
ffffffffc02006c4:	acbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c8:	780c                	ld	a1,48(s0)
ffffffffc02006ca:	00005517          	auipc	a0,0x5
ffffffffc02006ce:	e8650513          	addi	a0,a0,-378 # ffffffffc0205550 <commands+0x5e0>
ffffffffc02006d2:	abdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d6:	7c0c                	ld	a1,56(s0)
ffffffffc02006d8:	00005517          	auipc	a0,0x5
ffffffffc02006dc:	e9050513          	addi	a0,a0,-368 # ffffffffc0205568 <commands+0x5f8>
ffffffffc02006e0:	aafff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e4:	602c                	ld	a1,64(s0)
ffffffffc02006e6:	00005517          	auipc	a0,0x5
ffffffffc02006ea:	e9a50513          	addi	a0,a0,-358 # ffffffffc0205580 <commands+0x610>
ffffffffc02006ee:	aa1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006f2:	642c                	ld	a1,72(s0)
ffffffffc02006f4:	00005517          	auipc	a0,0x5
ffffffffc02006f8:	ea450513          	addi	a0,a0,-348 # ffffffffc0205598 <commands+0x628>
ffffffffc02006fc:	a93ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200700:	682c                	ld	a1,80(s0)
ffffffffc0200702:	00005517          	auipc	a0,0x5
ffffffffc0200706:	eae50513          	addi	a0,a0,-338 # ffffffffc02055b0 <commands+0x640>
ffffffffc020070a:	a85ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070e:	6c2c                	ld	a1,88(s0)
ffffffffc0200710:	00005517          	auipc	a0,0x5
ffffffffc0200714:	eb850513          	addi	a0,a0,-328 # ffffffffc02055c8 <commands+0x658>
ffffffffc0200718:	a77ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020071c:	702c                	ld	a1,96(s0)
ffffffffc020071e:	00005517          	auipc	a0,0x5
ffffffffc0200722:	ec250513          	addi	a0,a0,-318 # ffffffffc02055e0 <commands+0x670>
ffffffffc0200726:	a69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020072a:	742c                	ld	a1,104(s0)
ffffffffc020072c:	00005517          	auipc	a0,0x5
ffffffffc0200730:	ecc50513          	addi	a0,a0,-308 # ffffffffc02055f8 <commands+0x688>
ffffffffc0200734:	a5bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200738:	782c                	ld	a1,112(s0)
ffffffffc020073a:	00005517          	auipc	a0,0x5
ffffffffc020073e:	ed650513          	addi	a0,a0,-298 # ffffffffc0205610 <commands+0x6a0>
ffffffffc0200742:	a4dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200746:	7c2c                	ld	a1,120(s0)
ffffffffc0200748:	00005517          	auipc	a0,0x5
ffffffffc020074c:	ee050513          	addi	a0,a0,-288 # ffffffffc0205628 <commands+0x6b8>
ffffffffc0200750:	a3fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200754:	604c                	ld	a1,128(s0)
ffffffffc0200756:	00005517          	auipc	a0,0x5
ffffffffc020075a:	eea50513          	addi	a0,a0,-278 # ffffffffc0205640 <commands+0x6d0>
ffffffffc020075e:	a31ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200762:	644c                	ld	a1,136(s0)
ffffffffc0200764:	00005517          	auipc	a0,0x5
ffffffffc0200768:	ef450513          	addi	a0,a0,-268 # ffffffffc0205658 <commands+0x6e8>
ffffffffc020076c:	a23ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200770:	684c                	ld	a1,144(s0)
ffffffffc0200772:	00005517          	auipc	a0,0x5
ffffffffc0200776:	efe50513          	addi	a0,a0,-258 # ffffffffc0205670 <commands+0x700>
ffffffffc020077a:	a15ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077e:	6c4c                	ld	a1,152(s0)
ffffffffc0200780:	00005517          	auipc	a0,0x5
ffffffffc0200784:	f0850513          	addi	a0,a0,-248 # ffffffffc0205688 <commands+0x718>
ffffffffc0200788:	a07ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020078c:	704c                	ld	a1,160(s0)
ffffffffc020078e:	00005517          	auipc	a0,0x5
ffffffffc0200792:	f1250513          	addi	a0,a0,-238 # ffffffffc02056a0 <commands+0x730>
ffffffffc0200796:	9f9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020079a:	744c                	ld	a1,168(s0)
ffffffffc020079c:	00005517          	auipc	a0,0x5
ffffffffc02007a0:	f1c50513          	addi	a0,a0,-228 # ffffffffc02056b8 <commands+0x748>
ffffffffc02007a4:	9ebff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a8:	784c                	ld	a1,176(s0)
ffffffffc02007aa:	00005517          	auipc	a0,0x5
ffffffffc02007ae:	f2650513          	addi	a0,a0,-218 # ffffffffc02056d0 <commands+0x760>
ffffffffc02007b2:	9ddff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b6:	7c4c                	ld	a1,184(s0)
ffffffffc02007b8:	00005517          	auipc	a0,0x5
ffffffffc02007bc:	f3050513          	addi	a0,a0,-208 # ffffffffc02056e8 <commands+0x778>
ffffffffc02007c0:	9cfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c4:	606c                	ld	a1,192(s0)
ffffffffc02007c6:	00005517          	auipc	a0,0x5
ffffffffc02007ca:	f3a50513          	addi	a0,a0,-198 # ffffffffc0205700 <commands+0x790>
ffffffffc02007ce:	9c1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007d2:	646c                	ld	a1,200(s0)
ffffffffc02007d4:	00005517          	auipc	a0,0x5
ffffffffc02007d8:	f4450513          	addi	a0,a0,-188 # ffffffffc0205718 <commands+0x7a8>
ffffffffc02007dc:	9b3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e0:	686c                	ld	a1,208(s0)
ffffffffc02007e2:	00005517          	auipc	a0,0x5
ffffffffc02007e6:	f4e50513          	addi	a0,a0,-178 # ffffffffc0205730 <commands+0x7c0>
ffffffffc02007ea:	9a5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ee:	6c6c                	ld	a1,216(s0)
ffffffffc02007f0:	00005517          	auipc	a0,0x5
ffffffffc02007f4:	f5850513          	addi	a0,a0,-168 # ffffffffc0205748 <commands+0x7d8>
ffffffffc02007f8:	997ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007fc:	706c                	ld	a1,224(s0)
ffffffffc02007fe:	00005517          	auipc	a0,0x5
ffffffffc0200802:	f6250513          	addi	a0,a0,-158 # ffffffffc0205760 <commands+0x7f0>
ffffffffc0200806:	989ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020080a:	746c                	ld	a1,232(s0)
ffffffffc020080c:	00005517          	auipc	a0,0x5
ffffffffc0200810:	f6c50513          	addi	a0,a0,-148 # ffffffffc0205778 <commands+0x808>
ffffffffc0200814:	97bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200818:	786c                	ld	a1,240(s0)
ffffffffc020081a:	00005517          	auipc	a0,0x5
ffffffffc020081e:	f7650513          	addi	a0,a0,-138 # ffffffffc0205790 <commands+0x820>
ffffffffc0200822:	96dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200826:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200828:	6402                	ld	s0,0(sp)
ffffffffc020082a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082c:	00005517          	auipc	a0,0x5
ffffffffc0200830:	f7c50513          	addi	a0,a0,-132 # ffffffffc02057a8 <commands+0x838>
}
ffffffffc0200834:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	959ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020083a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020083a:	1141                	addi	sp,sp,-16
ffffffffc020083c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020083e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200842:	00005517          	auipc	a0,0x5
ffffffffc0200846:	f7e50513          	addi	a0,a0,-130 # ffffffffc02057c0 <commands+0x850>
void print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084c:	943ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200850:	8522                	mv	a0,s0
ffffffffc0200852:	e1bff0ef          	jal	ra,ffffffffc020066c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200856:	10043583          	ld	a1,256(s0)
ffffffffc020085a:	00005517          	auipc	a0,0x5
ffffffffc020085e:	f7e50513          	addi	a0,a0,-130 # ffffffffc02057d8 <commands+0x868>
ffffffffc0200862:	92dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200866:	10843583          	ld	a1,264(s0)
ffffffffc020086a:	00005517          	auipc	a0,0x5
ffffffffc020086e:	f8650513          	addi	a0,a0,-122 # ffffffffc02057f0 <commands+0x880>
ffffffffc0200872:	91dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200876:	11043583          	ld	a1,272(s0)
ffffffffc020087a:	00005517          	auipc	a0,0x5
ffffffffc020087e:	f8e50513          	addi	a0,a0,-114 # ffffffffc0205808 <commands+0x898>
ffffffffc0200882:	90dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200886:	11843583          	ld	a1,280(s0)
}
ffffffffc020088a:	6402                	ld	s0,0(sp)
ffffffffc020088c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	00005517          	auipc	a0,0x5
ffffffffc0200892:	f9250513          	addi	a0,a0,-110 # ffffffffc0205820 <commands+0x8b0>
}
ffffffffc0200896:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200898:	8f7ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020089c <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020089c:	11853783          	ld	a5,280(a0)
ffffffffc02008a0:	577d                	li	a4,-1
ffffffffc02008a2:	8305                	srli	a4,a4,0x1
ffffffffc02008a4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02008a6:	472d                	li	a4,11
ffffffffc02008a8:	08f76d63          	bltu	a4,a5,ffffffffc0200942 <interrupt_handler+0xa6>
ffffffffc02008ac:	00005717          	auipc	a4,0x5
ffffffffc02008b0:	88070713          	addi	a4,a4,-1920 # ffffffffc020512c <commands+0x1bc>
ffffffffc02008b4:	078a                	slli	a5,a5,0x2
ffffffffc02008b6:	97ba                	add	a5,a5,a4
ffffffffc02008b8:	439c                	lw	a5,0(a5)
ffffffffc02008ba:	97ba                	add	a5,a5,a4
ffffffffc02008bc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	b6250513          	addi	a0,a0,-1182 # ffffffffc0205420 <commands+0x4b0>
ffffffffc02008c6:	8c9ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008ca:	00005517          	auipc	a0,0x5
ffffffffc02008ce:	b3650513          	addi	a0,a0,-1226 # ffffffffc0205400 <commands+0x490>
ffffffffc02008d2:	8bdff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008d6:	00005517          	auipc	a0,0x5
ffffffffc02008da:	aea50513          	addi	a0,a0,-1302 # ffffffffc02053c0 <commands+0x450>
ffffffffc02008de:	8b1ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008e2:	00005517          	auipc	a0,0x5
ffffffffc02008e6:	afe50513          	addi	a0,a0,-1282 # ffffffffc02053e0 <commands+0x470>
ffffffffc02008ea:	8a5ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008ee:	00005517          	auipc	a0,0x5
ffffffffc02008f2:	b6250513          	addi	a0,a0,-1182 # ffffffffc0205450 <commands+0x4e0>
ffffffffc02008f6:	899ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008fa:	1141                	addi	sp,sp,-16
ffffffffc02008fc:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008fe:	bedff0ef          	jal	ra,ffffffffc02004ea <clock_set_next_event>
            if(ticks==100){
ffffffffc0200902:	00015797          	auipc	a5,0x15
ffffffffc0200906:	bc678793          	addi	a5,a5,-1082 # ffffffffc02154c8 <ticks>
ffffffffc020090a:	6394                	ld	a3,0(a5)
ffffffffc020090c:	06400713          	li	a4,100
ffffffffc0200910:	02e68b63          	beq	a3,a4,ffffffffc0200946 <interrupt_handler+0xaa>
            else ticks++;
ffffffffc0200914:	639c                	ld	a5,0(a5)
ffffffffc0200916:	00015717          	auipc	a4,0x15
ffffffffc020091a:	b6270713          	addi	a4,a4,-1182 # ffffffffc0215478 <num>
ffffffffc020091e:	0785                	addi	a5,a5,1
ffffffffc0200920:	00015697          	auipc	a3,0x15
ffffffffc0200924:	baf6b423          	sd	a5,-1112(a3) # ffffffffc02154c8 <ticks>
            if(num==10)sbi_shutdown();
ffffffffc0200928:	6318                	ld	a4,0(a4)
ffffffffc020092a:	47a9                	li	a5,10
ffffffffc020092c:	00f71863          	bne	a4,a5,ffffffffc020093c <interrupt_handler+0xa0>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200930:	4501                	li	a0,0
ffffffffc0200932:	4581                	li	a1,0
ffffffffc0200934:	4601                	li	a2,0
ffffffffc0200936:	48a1                	li	a7,8
ffffffffc0200938:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020093c:	60a2                	ld	ra,8(sp)
ffffffffc020093e:	0141                	addi	sp,sp,16
ffffffffc0200940:	8082                	ret
            print_trapframe(tf);
ffffffffc0200942:	ef9ff06f          	j	ffffffffc020083a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200946:	06400593          	li	a1,100
ffffffffc020094a:	00005517          	auipc	a0,0x5
ffffffffc020094e:	af650513          	addi	a0,a0,-1290 # ffffffffc0205440 <commands+0x4d0>
ffffffffc0200952:	83dff0ef          	jal	ra,ffffffffc020018e <cprintf>
                num++;
ffffffffc0200956:	00015717          	auipc	a4,0x15
ffffffffc020095a:	b2270713          	addi	a4,a4,-1246 # ffffffffc0215478 <num>
                ticks=0;
ffffffffc020095e:	00015797          	auipc	a5,0x15
ffffffffc0200962:	b607b523          	sd	zero,-1174(a5) # ffffffffc02154c8 <ticks>
                num++;
ffffffffc0200966:	631c                	ld	a5,0(a4)
ffffffffc0200968:	0785                	addi	a5,a5,1
ffffffffc020096a:	00015697          	auipc	a3,0x15
ffffffffc020096e:	b0f6b723          	sd	a5,-1266(a3) # ffffffffc0215478 <num>
ffffffffc0200972:	bf5d                	j	ffffffffc0200928 <interrupt_handler+0x8c>

ffffffffc0200974 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200974:	11853783          	ld	a5,280(a0)
ffffffffc0200978:	473d                	li	a4,15
ffffffffc020097a:	1af76463          	bltu	a4,a5,ffffffffc0200b22 <exception_handler+0x1ae>
ffffffffc020097e:	00004717          	auipc	a4,0x4
ffffffffc0200982:	7de70713          	addi	a4,a4,2014 # ffffffffc020515c <commands+0x1ec>
ffffffffc0200986:	078a                	slli	a5,a5,0x2
ffffffffc0200988:	97ba                	add	a5,a5,a4
ffffffffc020098a:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020098c:	1101                	addi	sp,sp,-32
ffffffffc020098e:	e822                	sd	s0,16(sp)
ffffffffc0200990:	ec06                	sd	ra,24(sp)
ffffffffc0200992:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200994:	97ba                	add	a5,a5,a4
ffffffffc0200996:	842a                	mv	s0,a0
ffffffffc0200998:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020099a:	00005517          	auipc	a0,0x5
ffffffffc020099e:	a0e50513          	addi	a0,a0,-1522 # ffffffffc02053a8 <commands+0x438>
ffffffffc02009a2:	fecff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009a6:	8522                	mv	a0,s0
ffffffffc02009a8:	c39ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc02009ac:	84aa                	mv	s1,a0
ffffffffc02009ae:	16051c63          	bnez	a0,ffffffffc0200b26 <exception_handler+0x1b2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02009b2:	60e2                	ld	ra,24(sp)
ffffffffc02009b4:	6442                	ld	s0,16(sp)
ffffffffc02009b6:	64a2                	ld	s1,8(sp)
ffffffffc02009b8:	6105                	addi	sp,sp,32
ffffffffc02009ba:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02009bc:	00004517          	auipc	a0,0x4
ffffffffc02009c0:	7e450513          	addi	a0,a0,2020 # ffffffffc02051a0 <commands+0x230>
}
ffffffffc02009c4:	6442                	ld	s0,16(sp)
ffffffffc02009c6:	60e2                	ld	ra,24(sp)
ffffffffc02009c8:	64a2                	ld	s1,8(sp)
ffffffffc02009ca:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02009cc:	fc2ff06f          	j	ffffffffc020018e <cprintf>
ffffffffc02009d0:	00004517          	auipc	a0,0x4
ffffffffc02009d4:	7f050513          	addi	a0,a0,2032 # ffffffffc02051c0 <commands+0x250>
ffffffffc02009d8:	b7f5                	j	ffffffffc02009c4 <exception_handler+0x50>
            cprintf("Exception type:Illegal instruction\n");
ffffffffc02009da:	00005517          	auipc	a0,0x5
ffffffffc02009de:	80650513          	addi	a0,a0,-2042 # ffffffffc02051e0 <commands+0x270>
ffffffffc02009e2:	facff0ef          	jal	ra,ffffffffc020018e <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc02009e6:	10843583          	ld	a1,264(s0)
ffffffffc02009ea:	00005517          	auipc	a0,0x5
ffffffffc02009ee:	81e50513          	addi	a0,a0,-2018 # ffffffffc0205208 <commands+0x298>
ffffffffc02009f2:	f9cff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc02009f6:	10843783          	ld	a5,264(s0)
ffffffffc02009fa:	0791                	addi	a5,a5,4
ffffffffc02009fc:	10f43423          	sd	a5,264(s0)
            break;  
ffffffffc0200a00:	bf4d                	j	ffffffffc02009b2 <exception_handler+0x3e>
            cprintf("Exception type: breakpoint\n");
ffffffffc0200a02:	00005517          	auipc	a0,0x5
ffffffffc0200a06:	82e50513          	addi	a0,a0,-2002 # ffffffffc0205230 <commands+0x2c0>
ffffffffc0200a0a:	f84ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc0200a0e:	10843583          	ld	a1,264(s0)
ffffffffc0200a12:	00005517          	auipc	a0,0x5
ffffffffc0200a16:	83e50513          	addi	a0,a0,-1986 # ffffffffc0205250 <commands+0x2e0>
ffffffffc0200a1a:	f74ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc0200a1e:	10843783          	ld	a5,264(s0)
ffffffffc0200a22:	0791                	addi	a5,a5,4
ffffffffc0200a24:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200a28:	b769                	j	ffffffffc02009b2 <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc0200a2a:	00005517          	auipc	a0,0x5
ffffffffc0200a2e:	84650513          	addi	a0,a0,-1978 # ffffffffc0205270 <commands+0x300>
ffffffffc0200a32:	bf49                	j	ffffffffc02009c4 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	85c50513          	addi	a0,a0,-1956 # ffffffffc0205290 <commands+0x320>
ffffffffc0200a3c:	f52ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a40:	8522                	mv	a0,s0
ffffffffc0200a42:	b9fff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200a46:	84aa                	mv	s1,a0
ffffffffc0200a48:	d52d                	beqz	a0,ffffffffc02009b2 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a4a:	8522                	mv	a0,s0
ffffffffc0200a4c:	defff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a50:	86a6                	mv	a3,s1
ffffffffc0200a52:	00005617          	auipc	a2,0x5
ffffffffc0200a56:	85660613          	addi	a2,a2,-1962 # ffffffffc02052a8 <commands+0x338>
ffffffffc0200a5a:	0bf00593          	li	a1,191
ffffffffc0200a5e:	00005517          	auipc	a0,0x5
ffffffffc0200a62:	a4a50513          	addi	a0,a0,-1462 # ffffffffc02054a8 <commands+0x538>
ffffffffc0200a66:	9ebff0ef          	jal	ra,ffffffffc0200450 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200a6a:	00005517          	auipc	a0,0x5
ffffffffc0200a6e:	85e50513          	addi	a0,a0,-1954 # ffffffffc02052c8 <commands+0x358>
ffffffffc0200a72:	bf89                	j	ffffffffc02009c4 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200a74:	00005517          	auipc	a0,0x5
ffffffffc0200a78:	86c50513          	addi	a0,a0,-1940 # ffffffffc02052e0 <commands+0x370>
ffffffffc0200a7c:	f12ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a80:	8522                	mv	a0,s0
ffffffffc0200a82:	b5fff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200a86:	84aa                	mv	s1,a0
ffffffffc0200a88:	f20505e3          	beqz	a0,ffffffffc02009b2 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a8c:	8522                	mv	a0,s0
ffffffffc0200a8e:	dadff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a92:	86a6                	mv	a3,s1
ffffffffc0200a94:	00005617          	auipc	a2,0x5
ffffffffc0200a98:	81460613          	addi	a2,a2,-2028 # ffffffffc02052a8 <commands+0x338>
ffffffffc0200a9c:	0c900593          	li	a1,201
ffffffffc0200aa0:	00005517          	auipc	a0,0x5
ffffffffc0200aa4:	a0850513          	addi	a0,a0,-1528 # ffffffffc02054a8 <commands+0x538>
ffffffffc0200aa8:	9a9ff0ef          	jal	ra,ffffffffc0200450 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200aac:	00005517          	auipc	a0,0x5
ffffffffc0200ab0:	84c50513          	addi	a0,a0,-1972 # ffffffffc02052f8 <commands+0x388>
ffffffffc0200ab4:	bf01                	j	ffffffffc02009c4 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200ab6:	00005517          	auipc	a0,0x5
ffffffffc0200aba:	86250513          	addi	a0,a0,-1950 # ffffffffc0205318 <commands+0x3a8>
ffffffffc0200abe:	b719                	j	ffffffffc02009c4 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ac0:	00005517          	auipc	a0,0x5
ffffffffc0200ac4:	87850513          	addi	a0,a0,-1928 # ffffffffc0205338 <commands+0x3c8>
ffffffffc0200ac8:	bdf5                	j	ffffffffc02009c4 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aca:	00005517          	auipc	a0,0x5
ffffffffc0200ace:	88e50513          	addi	a0,a0,-1906 # ffffffffc0205358 <commands+0x3e8>
ffffffffc0200ad2:	bdcd                	j	ffffffffc02009c4 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad4:	00005517          	auipc	a0,0x5
ffffffffc0200ad8:	8a450513          	addi	a0,a0,-1884 # ffffffffc0205378 <commands+0x408>
ffffffffc0200adc:	b5e5                	j	ffffffffc02009c4 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ade:	00005517          	auipc	a0,0x5
ffffffffc0200ae2:	8b250513          	addi	a0,a0,-1870 # ffffffffc0205390 <commands+0x420>
ffffffffc0200ae6:	ea8ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200aea:	8522                	mv	a0,s0
ffffffffc0200aec:	af5ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200af0:	84aa                	mv	s1,a0
ffffffffc0200af2:	ec0500e3          	beqz	a0,ffffffffc02009b2 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200af6:	8522                	mv	a0,s0
ffffffffc0200af8:	d43ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200afc:	86a6                	mv	a3,s1
ffffffffc0200afe:	00004617          	auipc	a2,0x4
ffffffffc0200b02:	7aa60613          	addi	a2,a2,1962 # ffffffffc02052a8 <commands+0x338>
ffffffffc0200b06:	0df00593          	li	a1,223
ffffffffc0200b0a:	00005517          	auipc	a0,0x5
ffffffffc0200b0e:	99e50513          	addi	a0,a0,-1634 # ffffffffc02054a8 <commands+0x538>
ffffffffc0200b12:	93fff0ef          	jal	ra,ffffffffc0200450 <__panic>
}
ffffffffc0200b16:	6442                	ld	s0,16(sp)
ffffffffc0200b18:	60e2                	ld	ra,24(sp)
ffffffffc0200b1a:	64a2                	ld	s1,8(sp)
ffffffffc0200b1c:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200b1e:	d1dff06f          	j	ffffffffc020083a <print_trapframe>
ffffffffc0200b22:	d19ff06f          	j	ffffffffc020083a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200b26:	8522                	mv	a0,s0
ffffffffc0200b28:	d13ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b2c:	86a6                	mv	a3,s1
ffffffffc0200b2e:	00004617          	auipc	a2,0x4
ffffffffc0200b32:	77a60613          	addi	a2,a2,1914 # ffffffffc02052a8 <commands+0x338>
ffffffffc0200b36:	0e600593          	li	a1,230
ffffffffc0200b3a:	00005517          	auipc	a0,0x5
ffffffffc0200b3e:	96e50513          	addi	a0,a0,-1682 # ffffffffc02054a8 <commands+0x538>
ffffffffc0200b42:	90fff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200b46 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200b46:	11853783          	ld	a5,280(a0)
ffffffffc0200b4a:	0007c463          	bltz	a5,ffffffffc0200b52 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200b4e:	e27ff06f          	j	ffffffffc0200974 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200b52:	d4bff06f          	j	ffffffffc020089c <interrupt_handler>
	...

ffffffffc0200b58 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200b58:	14011073          	csrw	sscratch,sp
ffffffffc0200b5c:	712d                	addi	sp,sp,-288
ffffffffc0200b5e:	e406                	sd	ra,8(sp)
ffffffffc0200b60:	ec0e                	sd	gp,24(sp)
ffffffffc0200b62:	f012                	sd	tp,32(sp)
ffffffffc0200b64:	f416                	sd	t0,40(sp)
ffffffffc0200b66:	f81a                	sd	t1,48(sp)
ffffffffc0200b68:	fc1e                	sd	t2,56(sp)
ffffffffc0200b6a:	e0a2                	sd	s0,64(sp)
ffffffffc0200b6c:	e4a6                	sd	s1,72(sp)
ffffffffc0200b6e:	e8aa                	sd	a0,80(sp)
ffffffffc0200b70:	ecae                	sd	a1,88(sp)
ffffffffc0200b72:	f0b2                	sd	a2,96(sp)
ffffffffc0200b74:	f4b6                	sd	a3,104(sp)
ffffffffc0200b76:	f8ba                	sd	a4,112(sp)
ffffffffc0200b78:	fcbe                	sd	a5,120(sp)
ffffffffc0200b7a:	e142                	sd	a6,128(sp)
ffffffffc0200b7c:	e546                	sd	a7,136(sp)
ffffffffc0200b7e:	e94a                	sd	s2,144(sp)
ffffffffc0200b80:	ed4e                	sd	s3,152(sp)
ffffffffc0200b82:	f152                	sd	s4,160(sp)
ffffffffc0200b84:	f556                	sd	s5,168(sp)
ffffffffc0200b86:	f95a                	sd	s6,176(sp)
ffffffffc0200b88:	fd5e                	sd	s7,184(sp)
ffffffffc0200b8a:	e1e2                	sd	s8,192(sp)
ffffffffc0200b8c:	e5e6                	sd	s9,200(sp)
ffffffffc0200b8e:	e9ea                	sd	s10,208(sp)
ffffffffc0200b90:	edee                	sd	s11,216(sp)
ffffffffc0200b92:	f1f2                	sd	t3,224(sp)
ffffffffc0200b94:	f5f6                	sd	t4,232(sp)
ffffffffc0200b96:	f9fa                	sd	t5,240(sp)
ffffffffc0200b98:	fdfe                	sd	t6,248(sp)
ffffffffc0200b9a:	14002473          	csrr	s0,sscratch
ffffffffc0200b9e:	100024f3          	csrr	s1,sstatus
ffffffffc0200ba2:	14102973          	csrr	s2,sepc
ffffffffc0200ba6:	143029f3          	csrr	s3,stval
ffffffffc0200baa:	14202a73          	csrr	s4,scause
ffffffffc0200bae:	e822                	sd	s0,16(sp)
ffffffffc0200bb0:	e226                	sd	s1,256(sp)
ffffffffc0200bb2:	e64a                	sd	s2,264(sp)
ffffffffc0200bb4:	ea4e                	sd	s3,272(sp)
ffffffffc0200bb6:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200bb8:	850a                	mv	a0,sp
    jal trap
ffffffffc0200bba:	f8dff0ef          	jal	ra,ffffffffc0200b46 <trap>

ffffffffc0200bbe <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200bbe:	6492                	ld	s1,256(sp)
ffffffffc0200bc0:	6932                	ld	s2,264(sp)
ffffffffc0200bc2:	10049073          	csrw	sstatus,s1
ffffffffc0200bc6:	14191073          	csrw	sepc,s2
ffffffffc0200bca:	60a2                	ld	ra,8(sp)
ffffffffc0200bcc:	61e2                	ld	gp,24(sp)
ffffffffc0200bce:	7202                	ld	tp,32(sp)
ffffffffc0200bd0:	72a2                	ld	t0,40(sp)
ffffffffc0200bd2:	7342                	ld	t1,48(sp)
ffffffffc0200bd4:	73e2                	ld	t2,56(sp)
ffffffffc0200bd6:	6406                	ld	s0,64(sp)
ffffffffc0200bd8:	64a6                	ld	s1,72(sp)
ffffffffc0200bda:	6546                	ld	a0,80(sp)
ffffffffc0200bdc:	65e6                	ld	a1,88(sp)
ffffffffc0200bde:	7606                	ld	a2,96(sp)
ffffffffc0200be0:	76a6                	ld	a3,104(sp)
ffffffffc0200be2:	7746                	ld	a4,112(sp)
ffffffffc0200be4:	77e6                	ld	a5,120(sp)
ffffffffc0200be6:	680a                	ld	a6,128(sp)
ffffffffc0200be8:	68aa                	ld	a7,136(sp)
ffffffffc0200bea:	694a                	ld	s2,144(sp)
ffffffffc0200bec:	69ea                	ld	s3,152(sp)
ffffffffc0200bee:	7a0a                	ld	s4,160(sp)
ffffffffc0200bf0:	7aaa                	ld	s5,168(sp)
ffffffffc0200bf2:	7b4a                	ld	s6,176(sp)
ffffffffc0200bf4:	7bea                	ld	s7,184(sp)
ffffffffc0200bf6:	6c0e                	ld	s8,192(sp)
ffffffffc0200bf8:	6cae                	ld	s9,200(sp)
ffffffffc0200bfa:	6d4e                	ld	s10,208(sp)
ffffffffc0200bfc:	6dee                	ld	s11,216(sp)
ffffffffc0200bfe:	7e0e                	ld	t3,224(sp)
ffffffffc0200c00:	7eae                	ld	t4,232(sp)
ffffffffc0200c02:	7f4e                	ld	t5,240(sp)
ffffffffc0200c04:	7fee                	ld	t6,248(sp)
ffffffffc0200c06:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200c08:	10200073          	sret

ffffffffc0200c0c <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200c0c:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200c0e:	bf45                	j	ffffffffc0200bbe <__trapret>
	...

ffffffffc0200c12 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200c12:	00015797          	auipc	a5,0x15
ffffffffc0200c16:	8be78793          	addi	a5,a5,-1858 # ffffffffc02154d0 <free_area>
ffffffffc0200c1a:	e79c                	sd	a5,8(a5)
ffffffffc0200c1c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200c1e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200c22:	8082                	ret

ffffffffc0200c24 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200c24:	00015517          	auipc	a0,0x15
ffffffffc0200c28:	8bc56503          	lwu	a0,-1860(a0) # ffffffffc02154e0 <free_area+0x10>
ffffffffc0200c2c:	8082                	ret

ffffffffc0200c2e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200c2e:	715d                	addi	sp,sp,-80
ffffffffc0200c30:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200c32:	00015917          	auipc	s2,0x15
ffffffffc0200c36:	89e90913          	addi	s2,s2,-1890 # ffffffffc02154d0 <free_area>
ffffffffc0200c3a:	00893783          	ld	a5,8(s2)
ffffffffc0200c3e:	e486                	sd	ra,72(sp)
ffffffffc0200c40:	e0a2                	sd	s0,64(sp)
ffffffffc0200c42:	fc26                	sd	s1,56(sp)
ffffffffc0200c44:	f44e                	sd	s3,40(sp)
ffffffffc0200c46:	f052                	sd	s4,32(sp)
ffffffffc0200c48:	ec56                	sd	s5,24(sp)
ffffffffc0200c4a:	e85a                	sd	s6,16(sp)
ffffffffc0200c4c:	e45e                	sd	s7,8(sp)
ffffffffc0200c4e:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c50:	31278463          	beq	a5,s2,ffffffffc0200f58 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200c54:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200c58:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200c5a:	8b05                	andi	a4,a4,1
ffffffffc0200c5c:	30070263          	beqz	a4,ffffffffc0200f60 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200c60:	4401                	li	s0,0
ffffffffc0200c62:	4481                	li	s1,0
ffffffffc0200c64:	a031                	j	ffffffffc0200c70 <default_check+0x42>
ffffffffc0200c66:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200c6a:	8b09                	andi	a4,a4,2
ffffffffc0200c6c:	2e070a63          	beqz	a4,ffffffffc0200f60 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200c70:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200c74:	679c                	ld	a5,8(a5)
ffffffffc0200c76:	2485                	addiw	s1,s1,1
ffffffffc0200c78:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c7a:	ff2796e3          	bne	a5,s2,ffffffffc0200c66 <default_check+0x38>
ffffffffc0200c7e:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200c80:	058010ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>
ffffffffc0200c84:	73351e63          	bne	a0,s3,ffffffffc02013c0 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c88:	4505                	li	a0,1
ffffffffc0200c8a:	781000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200c8e:	8a2a                	mv	s4,a0
ffffffffc0200c90:	46050863          	beqz	a0,ffffffffc0201100 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c94:	4505                	li	a0,1
ffffffffc0200c96:	775000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200c9a:	89aa                	mv	s3,a0
ffffffffc0200c9c:	74050263          	beqz	a0,ffffffffc02013e0 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ca0:	4505                	li	a0,1
ffffffffc0200ca2:	769000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200ca6:	8aaa                	mv	s5,a0
ffffffffc0200ca8:	4c050c63          	beqz	a0,ffffffffc0201180 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200cac:	2d3a0a63          	beq	s4,s3,ffffffffc0200f80 <default_check+0x352>
ffffffffc0200cb0:	2caa0863          	beq	s4,a0,ffffffffc0200f80 <default_check+0x352>
ffffffffc0200cb4:	2ca98663          	beq	s3,a0,ffffffffc0200f80 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200cb8:	000a2783          	lw	a5,0(s4)
ffffffffc0200cbc:	2e079263          	bnez	a5,ffffffffc0200fa0 <default_check+0x372>
ffffffffc0200cc0:	0009a783          	lw	a5,0(s3)
ffffffffc0200cc4:	2c079e63          	bnez	a5,ffffffffc0200fa0 <default_check+0x372>
ffffffffc0200cc8:	411c                	lw	a5,0(a0)
ffffffffc0200cca:	2c079b63          	bnez	a5,ffffffffc0200fa0 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200cce:	00015797          	auipc	a5,0x15
ffffffffc0200cd2:	83278793          	addi	a5,a5,-1998 # ffffffffc0215500 <pages>
ffffffffc0200cd6:	639c                	ld	a5,0(a5)
ffffffffc0200cd8:	00006717          	auipc	a4,0x6
ffffffffc0200cdc:	2b070713          	addi	a4,a4,688 # ffffffffc0206f88 <nbase>
ffffffffc0200ce0:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ce2:	00014717          	auipc	a4,0x14
ffffffffc0200ce6:	7ae70713          	addi	a4,a4,1966 # ffffffffc0215490 <npage>
ffffffffc0200cea:	6314                	ld	a3,0(a4)
ffffffffc0200cec:	40fa0733          	sub	a4,s4,a5
ffffffffc0200cf0:	8719                	srai	a4,a4,0x6
ffffffffc0200cf2:	9732                	add	a4,a4,a2
ffffffffc0200cf4:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cf6:	0732                	slli	a4,a4,0xc
ffffffffc0200cf8:	2cd77463          	bleu	a3,a4,ffffffffc0200fc0 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200cfc:	40f98733          	sub	a4,s3,a5
ffffffffc0200d00:	8719                	srai	a4,a4,0x6
ffffffffc0200d02:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d04:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200d06:	4ed77d63          	bleu	a3,a4,ffffffffc0201200 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200d0a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200d0e:	8799                	srai	a5,a5,0x6
ffffffffc0200d10:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d12:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d14:	34d7f663          	bleu	a3,a5,ffffffffc0201060 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200d18:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d1a:	00093c03          	ld	s8,0(s2)
ffffffffc0200d1e:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200d22:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200d26:	00014797          	auipc	a5,0x14
ffffffffc0200d2a:	7b27b923          	sd	s2,1970(a5) # ffffffffc02154d8 <free_area+0x8>
ffffffffc0200d2e:	00014797          	auipc	a5,0x14
ffffffffc0200d32:	7b27b123          	sd	s2,1954(a5) # ffffffffc02154d0 <free_area>
    nr_free = 0;
ffffffffc0200d36:	00014797          	auipc	a5,0x14
ffffffffc0200d3a:	7a07a523          	sw	zero,1962(a5) # ffffffffc02154e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200d3e:	6cd000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200d42:	2e051f63          	bnez	a0,ffffffffc0201040 <default_check+0x412>
    free_page(p0);
ffffffffc0200d46:	4585                	li	a1,1
ffffffffc0200d48:	8552                	mv	a0,s4
ffffffffc0200d4a:	749000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    free_page(p1);
ffffffffc0200d4e:	4585                	li	a1,1
ffffffffc0200d50:	854e                	mv	a0,s3
ffffffffc0200d52:	741000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    free_page(p2);
ffffffffc0200d56:	4585                	li	a1,1
ffffffffc0200d58:	8556                	mv	a0,s5
ffffffffc0200d5a:	739000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    assert(nr_free == 3);
ffffffffc0200d5e:	01092703          	lw	a4,16(s2)
ffffffffc0200d62:	478d                	li	a5,3
ffffffffc0200d64:	2af71e63          	bne	a4,a5,ffffffffc0201020 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d68:	4505                	li	a0,1
ffffffffc0200d6a:	6a1000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200d6e:	89aa                	mv	s3,a0
ffffffffc0200d70:	28050863          	beqz	a0,ffffffffc0201000 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d74:	4505                	li	a0,1
ffffffffc0200d76:	695000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200d7a:	8aaa                	mv	s5,a0
ffffffffc0200d7c:	3e050263          	beqz	a0,ffffffffc0201160 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d80:	4505                	li	a0,1
ffffffffc0200d82:	689000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200d86:	8a2a                	mv	s4,a0
ffffffffc0200d88:	3a050c63          	beqz	a0,ffffffffc0201140 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200d8c:	4505                	li	a0,1
ffffffffc0200d8e:	67d000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200d92:	38051763          	bnez	a0,ffffffffc0201120 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200d96:	4585                	li	a1,1
ffffffffc0200d98:	854e                	mv	a0,s3
ffffffffc0200d9a:	6f9000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d9e:	00893783          	ld	a5,8(s2)
ffffffffc0200da2:	23278f63          	beq	a5,s2,ffffffffc0200fe0 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200da6:	4505                	li	a0,1
ffffffffc0200da8:	663000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200dac:	32a99a63          	bne	s3,a0,ffffffffc02010e0 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200db0:	4505                	li	a0,1
ffffffffc0200db2:	659000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200db6:	30051563          	bnez	a0,ffffffffc02010c0 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200dba:	01092783          	lw	a5,16(s2)
ffffffffc0200dbe:	2e079163          	bnez	a5,ffffffffc02010a0 <default_check+0x472>
    free_page(p);
ffffffffc0200dc2:	854e                	mv	a0,s3
ffffffffc0200dc4:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200dc6:	00014797          	auipc	a5,0x14
ffffffffc0200dca:	7187b523          	sd	s8,1802(a5) # ffffffffc02154d0 <free_area>
ffffffffc0200dce:	00014797          	auipc	a5,0x14
ffffffffc0200dd2:	7177b523          	sd	s7,1802(a5) # ffffffffc02154d8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200dd6:	00014797          	auipc	a5,0x14
ffffffffc0200dda:	7167a523          	sw	s6,1802(a5) # ffffffffc02154e0 <free_area+0x10>
    free_page(p);
ffffffffc0200dde:	6b5000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    free_page(p1);
ffffffffc0200de2:	4585                	li	a1,1
ffffffffc0200de4:	8556                	mv	a0,s5
ffffffffc0200de6:	6ad000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    free_page(p2);
ffffffffc0200dea:	4585                	li	a1,1
ffffffffc0200dec:	8552                	mv	a0,s4
ffffffffc0200dee:	6a5000ef          	jal	ra,ffffffffc0201c92 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200df2:	4515                	li	a0,5
ffffffffc0200df4:	617000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200df8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200dfa:	28050363          	beqz	a0,ffffffffc0201080 <default_check+0x452>
ffffffffc0200dfe:	651c                	ld	a5,8(a0)
ffffffffc0200e00:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200e02:	8b85                	andi	a5,a5,1
ffffffffc0200e04:	54079e63          	bnez	a5,ffffffffc0201360 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200e08:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200e0a:	00093b03          	ld	s6,0(s2)
ffffffffc0200e0e:	00893a83          	ld	s5,8(s2)
ffffffffc0200e12:	00014797          	auipc	a5,0x14
ffffffffc0200e16:	6b27bf23          	sd	s2,1726(a5) # ffffffffc02154d0 <free_area>
ffffffffc0200e1a:	00014797          	auipc	a5,0x14
ffffffffc0200e1e:	6b27bf23          	sd	s2,1726(a5) # ffffffffc02154d8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200e22:	5e9000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200e26:	50051d63          	bnez	a0,ffffffffc0201340 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200e2a:	08098a13          	addi	s4,s3,128
ffffffffc0200e2e:	8552                	mv	a0,s4
ffffffffc0200e30:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200e32:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200e36:	00014797          	auipc	a5,0x14
ffffffffc0200e3a:	6a07a523          	sw	zero,1706(a5) # ffffffffc02154e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200e3e:	655000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200e42:	4511                	li	a0,4
ffffffffc0200e44:	5c7000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200e48:	4c051c63          	bnez	a0,ffffffffc0201320 <default_check+0x6f2>
ffffffffc0200e4c:	0889b783          	ld	a5,136(s3)
ffffffffc0200e50:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200e52:	8b85                	andi	a5,a5,1
ffffffffc0200e54:	4a078663          	beqz	a5,ffffffffc0201300 <default_check+0x6d2>
ffffffffc0200e58:	0909a703          	lw	a4,144(s3)
ffffffffc0200e5c:	478d                	li	a5,3
ffffffffc0200e5e:	4af71163          	bne	a4,a5,ffffffffc0201300 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200e62:	450d                	li	a0,3
ffffffffc0200e64:	5a7000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200e68:	8c2a                	mv	s8,a0
ffffffffc0200e6a:	46050b63          	beqz	a0,ffffffffc02012e0 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0200e6e:	4505                	li	a0,1
ffffffffc0200e70:	59b000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200e74:	44051663          	bnez	a0,ffffffffc02012c0 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0200e78:	438a1463          	bne	s4,s8,ffffffffc02012a0 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200e7c:	4585                	li	a1,1
ffffffffc0200e7e:	854e                	mv	a0,s3
ffffffffc0200e80:	613000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    free_pages(p1, 3);
ffffffffc0200e84:	458d                	li	a1,3
ffffffffc0200e86:	8552                	mv	a0,s4
ffffffffc0200e88:	60b000ef          	jal	ra,ffffffffc0201c92 <free_pages>
ffffffffc0200e8c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200e90:	04098c13          	addi	s8,s3,64
ffffffffc0200e94:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200e96:	8b85                	andi	a5,a5,1
ffffffffc0200e98:	3e078463          	beqz	a5,ffffffffc0201280 <default_check+0x652>
ffffffffc0200e9c:	0109a703          	lw	a4,16(s3)
ffffffffc0200ea0:	4785                	li	a5,1
ffffffffc0200ea2:	3cf71f63          	bne	a4,a5,ffffffffc0201280 <default_check+0x652>
ffffffffc0200ea6:	008a3783          	ld	a5,8(s4)
ffffffffc0200eaa:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200eac:	8b85                	andi	a5,a5,1
ffffffffc0200eae:	3a078963          	beqz	a5,ffffffffc0201260 <default_check+0x632>
ffffffffc0200eb2:	010a2703          	lw	a4,16(s4)
ffffffffc0200eb6:	478d                	li	a5,3
ffffffffc0200eb8:	3af71463          	bne	a4,a5,ffffffffc0201260 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200ebc:	4505                	li	a0,1
ffffffffc0200ebe:	54d000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200ec2:	36a99f63          	bne	s3,a0,ffffffffc0201240 <default_check+0x612>
    free_page(p0);
ffffffffc0200ec6:	4585                	li	a1,1
ffffffffc0200ec8:	5cb000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200ecc:	4509                	li	a0,2
ffffffffc0200ece:	53d000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200ed2:	34aa1763          	bne	s4,a0,ffffffffc0201220 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0200ed6:	4589                	li	a1,2
ffffffffc0200ed8:	5bb000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    free_page(p2);
ffffffffc0200edc:	4585                	li	a1,1
ffffffffc0200ede:	8562                	mv	a0,s8
ffffffffc0200ee0:	5b3000ef          	jal	ra,ffffffffc0201c92 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200ee4:	4515                	li	a0,5
ffffffffc0200ee6:	525000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200eea:	89aa                	mv	s3,a0
ffffffffc0200eec:	48050a63          	beqz	a0,ffffffffc0201380 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0200ef0:	4505                	li	a0,1
ffffffffc0200ef2:	519000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0200ef6:	2e051563          	bnez	a0,ffffffffc02011e0 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0200efa:	01092783          	lw	a5,16(s2)
ffffffffc0200efe:	2c079163          	bnez	a5,ffffffffc02011c0 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200f02:	4595                	li	a1,5
ffffffffc0200f04:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200f06:	00014797          	auipc	a5,0x14
ffffffffc0200f0a:	5d77ad23          	sw	s7,1498(a5) # ffffffffc02154e0 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200f0e:	00014797          	auipc	a5,0x14
ffffffffc0200f12:	5d67b123          	sd	s6,1474(a5) # ffffffffc02154d0 <free_area>
ffffffffc0200f16:	00014797          	auipc	a5,0x14
ffffffffc0200f1a:	5d57b123          	sd	s5,1474(a5) # ffffffffc02154d8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200f1e:	575000ef          	jal	ra,ffffffffc0201c92 <free_pages>
    return listelm->next;
ffffffffc0200f22:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f26:	01278963          	beq	a5,s2,ffffffffc0200f38 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200f2a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200f2e:	679c                	ld	a5,8(a5)
ffffffffc0200f30:	34fd                	addiw	s1,s1,-1
ffffffffc0200f32:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f34:	ff279be3          	bne	a5,s2,ffffffffc0200f2a <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0200f38:	26049463          	bnez	s1,ffffffffc02011a0 <default_check+0x572>
    assert(total == 0);
ffffffffc0200f3c:	46041263          	bnez	s0,ffffffffc02013a0 <default_check+0x772>
}
ffffffffc0200f40:	60a6                	ld	ra,72(sp)
ffffffffc0200f42:	6406                	ld	s0,64(sp)
ffffffffc0200f44:	74e2                	ld	s1,56(sp)
ffffffffc0200f46:	7942                	ld	s2,48(sp)
ffffffffc0200f48:	79a2                	ld	s3,40(sp)
ffffffffc0200f4a:	7a02                	ld	s4,32(sp)
ffffffffc0200f4c:	6ae2                	ld	s5,24(sp)
ffffffffc0200f4e:	6b42                	ld	s6,16(sp)
ffffffffc0200f50:	6ba2                	ld	s7,8(sp)
ffffffffc0200f52:	6c02                	ld	s8,0(sp)
ffffffffc0200f54:	6161                	addi	sp,sp,80
ffffffffc0200f56:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f58:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200f5a:	4401                	li	s0,0
ffffffffc0200f5c:	4481                	li	s1,0
ffffffffc0200f5e:	b30d                	j	ffffffffc0200c80 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200f60:	00005697          	auipc	a3,0x5
ffffffffc0200f64:	8d868693          	addi	a3,a3,-1832 # ffffffffc0205838 <commands+0x8c8>
ffffffffc0200f68:	00005617          	auipc	a2,0x5
ffffffffc0200f6c:	8e060613          	addi	a2,a2,-1824 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0200f70:	0f000593          	li	a1,240
ffffffffc0200f74:	00005517          	auipc	a0,0x5
ffffffffc0200f78:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0205860 <commands+0x8f0>
ffffffffc0200f7c:	cd4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f80:	00005697          	auipc	a3,0x5
ffffffffc0200f84:	97868693          	addi	a3,a3,-1672 # ffffffffc02058f8 <commands+0x988>
ffffffffc0200f88:	00005617          	auipc	a2,0x5
ffffffffc0200f8c:	8c060613          	addi	a2,a2,-1856 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0200f90:	0bd00593          	li	a1,189
ffffffffc0200f94:	00005517          	auipc	a0,0x5
ffffffffc0200f98:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0205860 <commands+0x8f0>
ffffffffc0200f9c:	cb4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200fa0:	00005697          	auipc	a3,0x5
ffffffffc0200fa4:	98068693          	addi	a3,a3,-1664 # ffffffffc0205920 <commands+0x9b0>
ffffffffc0200fa8:	00005617          	auipc	a2,0x5
ffffffffc0200fac:	8a060613          	addi	a2,a2,-1888 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0200fb0:	0be00593          	li	a1,190
ffffffffc0200fb4:	00005517          	auipc	a0,0x5
ffffffffc0200fb8:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0205860 <commands+0x8f0>
ffffffffc0200fbc:	c94ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200fc0:	00005697          	auipc	a3,0x5
ffffffffc0200fc4:	9a068693          	addi	a3,a3,-1632 # ffffffffc0205960 <commands+0x9f0>
ffffffffc0200fc8:	00005617          	auipc	a2,0x5
ffffffffc0200fcc:	88060613          	addi	a2,a2,-1920 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0200fd0:	0c000593          	li	a1,192
ffffffffc0200fd4:	00005517          	auipc	a0,0x5
ffffffffc0200fd8:	88c50513          	addi	a0,a0,-1908 # ffffffffc0205860 <commands+0x8f0>
ffffffffc0200fdc:	c74ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200fe0:	00005697          	auipc	a3,0x5
ffffffffc0200fe4:	a0868693          	addi	a3,a3,-1528 # ffffffffc02059e8 <commands+0xa78>
ffffffffc0200fe8:	00005617          	auipc	a2,0x5
ffffffffc0200fec:	86060613          	addi	a2,a2,-1952 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0200ff0:	0d900593          	li	a1,217
ffffffffc0200ff4:	00005517          	auipc	a0,0x5
ffffffffc0200ff8:	86c50513          	addi	a0,a0,-1940 # ffffffffc0205860 <commands+0x8f0>
ffffffffc0200ffc:	c54ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201000:	00005697          	auipc	a3,0x5
ffffffffc0201004:	89868693          	addi	a3,a3,-1896 # ffffffffc0205898 <commands+0x928>
ffffffffc0201008:	00005617          	auipc	a2,0x5
ffffffffc020100c:	84060613          	addi	a2,a2,-1984 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201010:	0d200593          	li	a1,210
ffffffffc0201014:	00005517          	auipc	a0,0x5
ffffffffc0201018:	84c50513          	addi	a0,a0,-1972 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020101c:	c34ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 3);
ffffffffc0201020:	00005697          	auipc	a3,0x5
ffffffffc0201024:	9b868693          	addi	a3,a3,-1608 # ffffffffc02059d8 <commands+0xa68>
ffffffffc0201028:	00005617          	auipc	a2,0x5
ffffffffc020102c:	82060613          	addi	a2,a2,-2016 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201030:	0d000593          	li	a1,208
ffffffffc0201034:	00005517          	auipc	a0,0x5
ffffffffc0201038:	82c50513          	addi	a0,a0,-2004 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020103c:	c14ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201040:	00005697          	auipc	a3,0x5
ffffffffc0201044:	98068693          	addi	a3,a3,-1664 # ffffffffc02059c0 <commands+0xa50>
ffffffffc0201048:	00005617          	auipc	a2,0x5
ffffffffc020104c:	80060613          	addi	a2,a2,-2048 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201050:	0cb00593          	li	a1,203
ffffffffc0201054:	00005517          	auipc	a0,0x5
ffffffffc0201058:	80c50513          	addi	a0,a0,-2036 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020105c:	bf4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201060:	00005697          	auipc	a3,0x5
ffffffffc0201064:	94068693          	addi	a3,a3,-1728 # ffffffffc02059a0 <commands+0xa30>
ffffffffc0201068:	00004617          	auipc	a2,0x4
ffffffffc020106c:	7e060613          	addi	a2,a2,2016 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201070:	0c200593          	li	a1,194
ffffffffc0201074:	00004517          	auipc	a0,0x4
ffffffffc0201078:	7ec50513          	addi	a0,a0,2028 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020107c:	bd4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 != NULL);
ffffffffc0201080:	00005697          	auipc	a3,0x5
ffffffffc0201084:	9b068693          	addi	a3,a3,-1616 # ffffffffc0205a30 <commands+0xac0>
ffffffffc0201088:	00004617          	auipc	a2,0x4
ffffffffc020108c:	7c060613          	addi	a2,a2,1984 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201090:	0f800593          	li	a1,248
ffffffffc0201094:	00004517          	auipc	a0,0x4
ffffffffc0201098:	7cc50513          	addi	a0,a0,1996 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020109c:	bb4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 0);
ffffffffc02010a0:	00005697          	auipc	a3,0x5
ffffffffc02010a4:	98068693          	addi	a3,a3,-1664 # ffffffffc0205a20 <commands+0xab0>
ffffffffc02010a8:	00004617          	auipc	a2,0x4
ffffffffc02010ac:	7a060613          	addi	a2,a2,1952 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02010b0:	0df00593          	li	a1,223
ffffffffc02010b4:	00004517          	auipc	a0,0x4
ffffffffc02010b8:	7ac50513          	addi	a0,a0,1964 # ffffffffc0205860 <commands+0x8f0>
ffffffffc02010bc:	b94ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010c0:	00005697          	auipc	a3,0x5
ffffffffc02010c4:	90068693          	addi	a3,a3,-1792 # ffffffffc02059c0 <commands+0xa50>
ffffffffc02010c8:	00004617          	auipc	a2,0x4
ffffffffc02010cc:	78060613          	addi	a2,a2,1920 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02010d0:	0dd00593          	li	a1,221
ffffffffc02010d4:	00004517          	auipc	a0,0x4
ffffffffc02010d8:	78c50513          	addi	a0,a0,1932 # ffffffffc0205860 <commands+0x8f0>
ffffffffc02010dc:	b74ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02010e0:	00005697          	auipc	a3,0x5
ffffffffc02010e4:	92068693          	addi	a3,a3,-1760 # ffffffffc0205a00 <commands+0xa90>
ffffffffc02010e8:	00004617          	auipc	a2,0x4
ffffffffc02010ec:	76060613          	addi	a2,a2,1888 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02010f0:	0dc00593          	li	a1,220
ffffffffc02010f4:	00004517          	auipc	a0,0x4
ffffffffc02010f8:	76c50513          	addi	a0,a0,1900 # ffffffffc0205860 <commands+0x8f0>
ffffffffc02010fc:	b54ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201100:	00004697          	auipc	a3,0x4
ffffffffc0201104:	79868693          	addi	a3,a3,1944 # ffffffffc0205898 <commands+0x928>
ffffffffc0201108:	00004617          	auipc	a2,0x4
ffffffffc020110c:	74060613          	addi	a2,a2,1856 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201110:	0b900593          	li	a1,185
ffffffffc0201114:	00004517          	auipc	a0,0x4
ffffffffc0201118:	74c50513          	addi	a0,a0,1868 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020111c:	b34ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201120:	00005697          	auipc	a3,0x5
ffffffffc0201124:	8a068693          	addi	a3,a3,-1888 # ffffffffc02059c0 <commands+0xa50>
ffffffffc0201128:	00004617          	auipc	a2,0x4
ffffffffc020112c:	72060613          	addi	a2,a2,1824 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201130:	0d600593          	li	a1,214
ffffffffc0201134:	00004517          	auipc	a0,0x4
ffffffffc0201138:	72c50513          	addi	a0,a0,1836 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020113c:	b14ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201140:	00004697          	auipc	a3,0x4
ffffffffc0201144:	79868693          	addi	a3,a3,1944 # ffffffffc02058d8 <commands+0x968>
ffffffffc0201148:	00004617          	auipc	a2,0x4
ffffffffc020114c:	70060613          	addi	a2,a2,1792 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201150:	0d400593          	li	a1,212
ffffffffc0201154:	00004517          	auipc	a0,0x4
ffffffffc0201158:	70c50513          	addi	a0,a0,1804 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020115c:	af4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201160:	00004697          	auipc	a3,0x4
ffffffffc0201164:	75868693          	addi	a3,a3,1880 # ffffffffc02058b8 <commands+0x948>
ffffffffc0201168:	00004617          	auipc	a2,0x4
ffffffffc020116c:	6e060613          	addi	a2,a2,1760 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201170:	0d300593          	li	a1,211
ffffffffc0201174:	00004517          	auipc	a0,0x4
ffffffffc0201178:	6ec50513          	addi	a0,a0,1772 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020117c:	ad4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201180:	00004697          	auipc	a3,0x4
ffffffffc0201184:	75868693          	addi	a3,a3,1880 # ffffffffc02058d8 <commands+0x968>
ffffffffc0201188:	00004617          	auipc	a2,0x4
ffffffffc020118c:	6c060613          	addi	a2,a2,1728 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201190:	0bb00593          	li	a1,187
ffffffffc0201194:	00004517          	auipc	a0,0x4
ffffffffc0201198:	6cc50513          	addi	a0,a0,1740 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020119c:	ab4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(count == 0);
ffffffffc02011a0:	00005697          	auipc	a3,0x5
ffffffffc02011a4:	9e068693          	addi	a3,a3,-1568 # ffffffffc0205b80 <commands+0xc10>
ffffffffc02011a8:	00004617          	auipc	a2,0x4
ffffffffc02011ac:	6a060613          	addi	a2,a2,1696 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02011b0:	12500593          	li	a1,293
ffffffffc02011b4:	00004517          	auipc	a0,0x4
ffffffffc02011b8:	6ac50513          	addi	a0,a0,1708 # ffffffffc0205860 <commands+0x8f0>
ffffffffc02011bc:	a94ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 0);
ffffffffc02011c0:	00005697          	auipc	a3,0x5
ffffffffc02011c4:	86068693          	addi	a3,a3,-1952 # ffffffffc0205a20 <commands+0xab0>
ffffffffc02011c8:	00004617          	auipc	a2,0x4
ffffffffc02011cc:	68060613          	addi	a2,a2,1664 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02011d0:	11a00593          	li	a1,282
ffffffffc02011d4:	00004517          	auipc	a0,0x4
ffffffffc02011d8:	68c50513          	addi	a0,a0,1676 # ffffffffc0205860 <commands+0x8f0>
ffffffffc02011dc:	a74ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011e0:	00004697          	auipc	a3,0x4
ffffffffc02011e4:	7e068693          	addi	a3,a3,2016 # ffffffffc02059c0 <commands+0xa50>
ffffffffc02011e8:	00004617          	auipc	a2,0x4
ffffffffc02011ec:	66060613          	addi	a2,a2,1632 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02011f0:	11800593          	li	a1,280
ffffffffc02011f4:	00004517          	auipc	a0,0x4
ffffffffc02011f8:	66c50513          	addi	a0,a0,1644 # ffffffffc0205860 <commands+0x8f0>
ffffffffc02011fc:	a54ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201200:	00004697          	auipc	a3,0x4
ffffffffc0201204:	78068693          	addi	a3,a3,1920 # ffffffffc0205980 <commands+0xa10>
ffffffffc0201208:	00004617          	auipc	a2,0x4
ffffffffc020120c:	64060613          	addi	a2,a2,1600 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201210:	0c100593          	li	a1,193
ffffffffc0201214:	00004517          	auipc	a0,0x4
ffffffffc0201218:	64c50513          	addi	a0,a0,1612 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020121c:	a34ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201220:	00005697          	auipc	a3,0x5
ffffffffc0201224:	92068693          	addi	a3,a3,-1760 # ffffffffc0205b40 <commands+0xbd0>
ffffffffc0201228:	00004617          	auipc	a2,0x4
ffffffffc020122c:	62060613          	addi	a2,a2,1568 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201230:	11200593          	li	a1,274
ffffffffc0201234:	00004517          	auipc	a0,0x4
ffffffffc0201238:	62c50513          	addi	a0,a0,1580 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020123c:	a14ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201240:	00005697          	auipc	a3,0x5
ffffffffc0201244:	8e068693          	addi	a3,a3,-1824 # ffffffffc0205b20 <commands+0xbb0>
ffffffffc0201248:	00004617          	auipc	a2,0x4
ffffffffc020124c:	60060613          	addi	a2,a2,1536 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201250:	11000593          	li	a1,272
ffffffffc0201254:	00004517          	auipc	a0,0x4
ffffffffc0201258:	60c50513          	addi	a0,a0,1548 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020125c:	9f4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201260:	00005697          	auipc	a3,0x5
ffffffffc0201264:	89868693          	addi	a3,a3,-1896 # ffffffffc0205af8 <commands+0xb88>
ffffffffc0201268:	00004617          	auipc	a2,0x4
ffffffffc020126c:	5e060613          	addi	a2,a2,1504 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201270:	10e00593          	li	a1,270
ffffffffc0201274:	00004517          	auipc	a0,0x4
ffffffffc0201278:	5ec50513          	addi	a0,a0,1516 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020127c:	9d4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201280:	00005697          	auipc	a3,0x5
ffffffffc0201284:	85068693          	addi	a3,a3,-1968 # ffffffffc0205ad0 <commands+0xb60>
ffffffffc0201288:	00004617          	auipc	a2,0x4
ffffffffc020128c:	5c060613          	addi	a2,a2,1472 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201290:	10d00593          	li	a1,269
ffffffffc0201294:	00004517          	auipc	a0,0x4
ffffffffc0201298:	5cc50513          	addi	a0,a0,1484 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020129c:	9b4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02012a0:	00005697          	auipc	a3,0x5
ffffffffc02012a4:	82068693          	addi	a3,a3,-2016 # ffffffffc0205ac0 <commands+0xb50>
ffffffffc02012a8:	00004617          	auipc	a2,0x4
ffffffffc02012ac:	5a060613          	addi	a2,a2,1440 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02012b0:	10800593          	li	a1,264
ffffffffc02012b4:	00004517          	auipc	a0,0x4
ffffffffc02012b8:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205860 <commands+0x8f0>
ffffffffc02012bc:	994ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012c0:	00004697          	auipc	a3,0x4
ffffffffc02012c4:	70068693          	addi	a3,a3,1792 # ffffffffc02059c0 <commands+0xa50>
ffffffffc02012c8:	00004617          	auipc	a2,0x4
ffffffffc02012cc:	58060613          	addi	a2,a2,1408 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02012d0:	10700593          	li	a1,263
ffffffffc02012d4:	00004517          	auipc	a0,0x4
ffffffffc02012d8:	58c50513          	addi	a0,a0,1420 # ffffffffc0205860 <commands+0x8f0>
ffffffffc02012dc:	974ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02012e0:	00004697          	auipc	a3,0x4
ffffffffc02012e4:	7c068693          	addi	a3,a3,1984 # ffffffffc0205aa0 <commands+0xb30>
ffffffffc02012e8:	00004617          	auipc	a2,0x4
ffffffffc02012ec:	56060613          	addi	a2,a2,1376 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02012f0:	10600593          	li	a1,262
ffffffffc02012f4:	00004517          	auipc	a0,0x4
ffffffffc02012f8:	56c50513          	addi	a0,a0,1388 # ffffffffc0205860 <commands+0x8f0>
ffffffffc02012fc:	954ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201300:	00004697          	auipc	a3,0x4
ffffffffc0201304:	77068693          	addi	a3,a3,1904 # ffffffffc0205a70 <commands+0xb00>
ffffffffc0201308:	00004617          	auipc	a2,0x4
ffffffffc020130c:	54060613          	addi	a2,a2,1344 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201310:	10500593          	li	a1,261
ffffffffc0201314:	00004517          	auipc	a0,0x4
ffffffffc0201318:	54c50513          	addi	a0,a0,1356 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020131c:	934ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201320:	00004697          	auipc	a3,0x4
ffffffffc0201324:	73868693          	addi	a3,a3,1848 # ffffffffc0205a58 <commands+0xae8>
ffffffffc0201328:	00004617          	auipc	a2,0x4
ffffffffc020132c:	52060613          	addi	a2,a2,1312 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201330:	10400593          	li	a1,260
ffffffffc0201334:	00004517          	auipc	a0,0x4
ffffffffc0201338:	52c50513          	addi	a0,a0,1324 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020133c:	914ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201340:	00004697          	auipc	a3,0x4
ffffffffc0201344:	68068693          	addi	a3,a3,1664 # ffffffffc02059c0 <commands+0xa50>
ffffffffc0201348:	00004617          	auipc	a2,0x4
ffffffffc020134c:	50060613          	addi	a2,a2,1280 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201350:	0fe00593          	li	a1,254
ffffffffc0201354:	00004517          	auipc	a0,0x4
ffffffffc0201358:	50c50513          	addi	a0,a0,1292 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020135c:	8f4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201360:	00004697          	auipc	a3,0x4
ffffffffc0201364:	6e068693          	addi	a3,a3,1760 # ffffffffc0205a40 <commands+0xad0>
ffffffffc0201368:	00004617          	auipc	a2,0x4
ffffffffc020136c:	4e060613          	addi	a2,a2,1248 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201370:	0f900593          	li	a1,249
ffffffffc0201374:	00004517          	auipc	a0,0x4
ffffffffc0201378:	4ec50513          	addi	a0,a0,1260 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020137c:	8d4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201380:	00004697          	auipc	a3,0x4
ffffffffc0201384:	7e068693          	addi	a3,a3,2016 # ffffffffc0205b60 <commands+0xbf0>
ffffffffc0201388:	00004617          	auipc	a2,0x4
ffffffffc020138c:	4c060613          	addi	a2,a2,1216 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201390:	11700593          	li	a1,279
ffffffffc0201394:	00004517          	auipc	a0,0x4
ffffffffc0201398:	4cc50513          	addi	a0,a0,1228 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020139c:	8b4ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(total == 0);
ffffffffc02013a0:	00004697          	auipc	a3,0x4
ffffffffc02013a4:	7f068693          	addi	a3,a3,2032 # ffffffffc0205b90 <commands+0xc20>
ffffffffc02013a8:	00004617          	auipc	a2,0x4
ffffffffc02013ac:	4a060613          	addi	a2,a2,1184 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02013b0:	12600593          	li	a1,294
ffffffffc02013b4:	00004517          	auipc	a0,0x4
ffffffffc02013b8:	4ac50513          	addi	a0,a0,1196 # ffffffffc0205860 <commands+0x8f0>
ffffffffc02013bc:	894ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(total == nr_free_pages());
ffffffffc02013c0:	00004697          	auipc	a3,0x4
ffffffffc02013c4:	4b868693          	addi	a3,a3,1208 # ffffffffc0205878 <commands+0x908>
ffffffffc02013c8:	00004617          	auipc	a2,0x4
ffffffffc02013cc:	48060613          	addi	a2,a2,1152 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02013d0:	0f300593          	li	a1,243
ffffffffc02013d4:	00004517          	auipc	a0,0x4
ffffffffc02013d8:	48c50513          	addi	a0,a0,1164 # ffffffffc0205860 <commands+0x8f0>
ffffffffc02013dc:	874ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013e0:	00004697          	auipc	a3,0x4
ffffffffc02013e4:	4d868693          	addi	a3,a3,1240 # ffffffffc02058b8 <commands+0x948>
ffffffffc02013e8:	00004617          	auipc	a2,0x4
ffffffffc02013ec:	46060613          	addi	a2,a2,1120 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02013f0:	0ba00593          	li	a1,186
ffffffffc02013f4:	00004517          	auipc	a0,0x4
ffffffffc02013f8:	46c50513          	addi	a0,a0,1132 # ffffffffc0205860 <commands+0x8f0>
ffffffffc02013fc:	854ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201400 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201400:	1141                	addi	sp,sp,-16
ffffffffc0201402:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201404:	16058e63          	beqz	a1,ffffffffc0201580 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0201408:	00659693          	slli	a3,a1,0x6
ffffffffc020140c:	96aa                	add	a3,a3,a0
ffffffffc020140e:	02d50d63          	beq	a0,a3,ffffffffc0201448 <default_free_pages+0x48>
ffffffffc0201412:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201414:	8b85                	andi	a5,a5,1
ffffffffc0201416:	14079563          	bnez	a5,ffffffffc0201560 <default_free_pages+0x160>
ffffffffc020141a:	651c                	ld	a5,8(a0)
ffffffffc020141c:	8385                	srli	a5,a5,0x1
ffffffffc020141e:	8b85                	andi	a5,a5,1
ffffffffc0201420:	14079063          	bnez	a5,ffffffffc0201560 <default_free_pages+0x160>
ffffffffc0201424:	87aa                	mv	a5,a0
ffffffffc0201426:	a809                	j	ffffffffc0201438 <default_free_pages+0x38>
ffffffffc0201428:	6798                	ld	a4,8(a5)
ffffffffc020142a:	8b05                	andi	a4,a4,1
ffffffffc020142c:	12071a63          	bnez	a4,ffffffffc0201560 <default_free_pages+0x160>
ffffffffc0201430:	6798                	ld	a4,8(a5)
ffffffffc0201432:	8b09                	andi	a4,a4,2
ffffffffc0201434:	12071663          	bnez	a4,ffffffffc0201560 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0201438:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc020143c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201440:	04078793          	addi	a5,a5,64
ffffffffc0201444:	fed792e3          	bne	a5,a3,ffffffffc0201428 <default_free_pages+0x28>
    base->property = n;
ffffffffc0201448:	2581                	sext.w	a1,a1
ffffffffc020144a:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020144c:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201450:	4789                	li	a5,2
ffffffffc0201452:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201456:	00014697          	auipc	a3,0x14
ffffffffc020145a:	07a68693          	addi	a3,a3,122 # ffffffffc02154d0 <free_area>
ffffffffc020145e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201460:	669c                	ld	a5,8(a3)
ffffffffc0201462:	9db9                	addw	a1,a1,a4
ffffffffc0201464:	00014717          	auipc	a4,0x14
ffffffffc0201468:	06b72e23          	sw	a1,124(a4) # ffffffffc02154e0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020146c:	0cd78163          	beq	a5,a3,ffffffffc020152e <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201470:	fe878713          	addi	a4,a5,-24
ffffffffc0201474:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201476:	4801                	li	a6,0
ffffffffc0201478:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020147c:	00e56a63          	bltu	a0,a4,ffffffffc0201490 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0201480:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201482:	04d70f63          	beq	a4,a3,ffffffffc02014e0 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201486:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201488:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020148c:	fee57ae3          	bleu	a4,a0,ffffffffc0201480 <default_free_pages+0x80>
ffffffffc0201490:	00080663          	beqz	a6,ffffffffc020149c <default_free_pages+0x9c>
ffffffffc0201494:	00014817          	auipc	a6,0x14
ffffffffc0201498:	02b83e23          	sd	a1,60(a6) # ffffffffc02154d0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020149c:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020149e:	e390                	sd	a2,0(a5)
ffffffffc02014a0:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02014a2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014a4:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02014a6:	06d58a63          	beq	a1,a3,ffffffffc020151a <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02014aa:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02014ae:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02014b2:	02061793          	slli	a5,a2,0x20
ffffffffc02014b6:	83e9                	srli	a5,a5,0x1a
ffffffffc02014b8:	97ba                	add	a5,a5,a4
ffffffffc02014ba:	04f51b63          	bne	a0,a5,ffffffffc0201510 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc02014be:	491c                	lw	a5,16(a0)
ffffffffc02014c0:	9e3d                	addw	a2,a2,a5
ffffffffc02014c2:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02014c6:	57f5                	li	a5,-3
ffffffffc02014c8:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014cc:	01853803          	ld	a6,24(a0)
ffffffffc02014d0:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc02014d2:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02014d4:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc02014d8:	659c                	ld	a5,8(a1)
ffffffffc02014da:	01063023          	sd	a6,0(a2)
ffffffffc02014de:	a815                	j	ffffffffc0201512 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc02014e0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02014e2:	f114                	sd	a3,32(a0)
ffffffffc02014e4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02014e6:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02014e8:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02014ea:	00d70563          	beq	a4,a3,ffffffffc02014f4 <default_free_pages+0xf4>
ffffffffc02014ee:	4805                	li	a6,1
ffffffffc02014f0:	87ba                	mv	a5,a4
ffffffffc02014f2:	bf59                	j	ffffffffc0201488 <default_free_pages+0x88>
ffffffffc02014f4:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02014f6:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02014f8:	00d78d63          	beq	a5,a3,ffffffffc0201512 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc02014fc:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201500:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201504:	02061793          	slli	a5,a2,0x20
ffffffffc0201508:	83e9                	srli	a5,a5,0x1a
ffffffffc020150a:	97ba                	add	a5,a5,a4
ffffffffc020150c:	faf509e3          	beq	a0,a5,ffffffffc02014be <default_free_pages+0xbe>
ffffffffc0201510:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201512:	fe878713          	addi	a4,a5,-24
ffffffffc0201516:	00d78963          	beq	a5,a3,ffffffffc0201528 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc020151a:	4910                	lw	a2,16(a0)
ffffffffc020151c:	02061693          	slli	a3,a2,0x20
ffffffffc0201520:	82e9                	srli	a3,a3,0x1a
ffffffffc0201522:	96aa                	add	a3,a3,a0
ffffffffc0201524:	00d70e63          	beq	a4,a3,ffffffffc0201540 <default_free_pages+0x140>
}
ffffffffc0201528:	60a2                	ld	ra,8(sp)
ffffffffc020152a:	0141                	addi	sp,sp,16
ffffffffc020152c:	8082                	ret
ffffffffc020152e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201530:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201534:	e398                	sd	a4,0(a5)
ffffffffc0201536:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201538:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020153a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020153c:	0141                	addi	sp,sp,16
ffffffffc020153e:	8082                	ret
            base->property += p->property;
ffffffffc0201540:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201544:	ff078693          	addi	a3,a5,-16
ffffffffc0201548:	9e39                	addw	a2,a2,a4
ffffffffc020154a:	c910                	sw	a2,16(a0)
ffffffffc020154c:	5775                	li	a4,-3
ffffffffc020154e:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201552:	6398                	ld	a4,0(a5)
ffffffffc0201554:	679c                	ld	a5,8(a5)
}
ffffffffc0201556:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201558:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020155a:	e398                	sd	a4,0(a5)
ffffffffc020155c:	0141                	addi	sp,sp,16
ffffffffc020155e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201560:	00004697          	auipc	a3,0x4
ffffffffc0201564:	64068693          	addi	a3,a3,1600 # ffffffffc0205ba0 <commands+0xc30>
ffffffffc0201568:	00004617          	auipc	a2,0x4
ffffffffc020156c:	2e060613          	addi	a2,a2,736 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201570:	08300593          	li	a1,131
ffffffffc0201574:	00004517          	auipc	a0,0x4
ffffffffc0201578:	2ec50513          	addi	a0,a0,748 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020157c:	ed5fe0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(n > 0);
ffffffffc0201580:	00004697          	auipc	a3,0x4
ffffffffc0201584:	64868693          	addi	a3,a3,1608 # ffffffffc0205bc8 <commands+0xc58>
ffffffffc0201588:	00004617          	auipc	a2,0x4
ffffffffc020158c:	2c060613          	addi	a2,a2,704 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201590:	08000593          	li	a1,128
ffffffffc0201594:	00004517          	auipc	a0,0x4
ffffffffc0201598:	2cc50513          	addi	a0,a0,716 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020159c:	eb5fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02015a0 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02015a0:	c959                	beqz	a0,ffffffffc0201636 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02015a2:	00014597          	auipc	a1,0x14
ffffffffc02015a6:	f2e58593          	addi	a1,a1,-210 # ffffffffc02154d0 <free_area>
ffffffffc02015aa:	0105a803          	lw	a6,16(a1)
ffffffffc02015ae:	862a                	mv	a2,a0
ffffffffc02015b0:	02081793          	slli	a5,a6,0x20
ffffffffc02015b4:	9381                	srli	a5,a5,0x20
ffffffffc02015b6:	00a7ee63          	bltu	a5,a0,ffffffffc02015d2 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02015ba:	87ae                	mv	a5,a1
ffffffffc02015bc:	a801                	j	ffffffffc02015cc <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02015be:	ff87a703          	lw	a4,-8(a5)
ffffffffc02015c2:	02071693          	slli	a3,a4,0x20
ffffffffc02015c6:	9281                	srli	a3,a3,0x20
ffffffffc02015c8:	00c6f763          	bleu	a2,a3,ffffffffc02015d6 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02015cc:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02015ce:	feb798e3          	bne	a5,a1,ffffffffc02015be <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02015d2:	4501                	li	a0,0
}
ffffffffc02015d4:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02015d6:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc02015da:	dd6d                	beqz	a0,ffffffffc02015d4 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02015dc:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02015e0:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02015e4:	00060e1b          	sext.w	t3,a2
ffffffffc02015e8:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02015ec:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02015f0:	02d67863          	bleu	a3,a2,ffffffffc0201620 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc02015f4:	061a                	slli	a2,a2,0x6
ffffffffc02015f6:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc02015f8:	41c7073b          	subw	a4,a4,t3
ffffffffc02015fc:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015fe:	00860693          	addi	a3,a2,8
ffffffffc0201602:	4709                	li	a4,2
ffffffffc0201604:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201608:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020160c:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201610:	0105a803          	lw	a6,16(a1)
ffffffffc0201614:	e314                	sd	a3,0(a4)
ffffffffc0201616:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc020161a:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc020161c:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201620:	41c8083b          	subw	a6,a6,t3
ffffffffc0201624:	00014717          	auipc	a4,0x14
ffffffffc0201628:	eb072e23          	sw	a6,-324(a4) # ffffffffc02154e0 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020162c:	5775                	li	a4,-3
ffffffffc020162e:	17c1                	addi	a5,a5,-16
ffffffffc0201630:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201634:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201636:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201638:	00004697          	auipc	a3,0x4
ffffffffc020163c:	59068693          	addi	a3,a3,1424 # ffffffffc0205bc8 <commands+0xc58>
ffffffffc0201640:	00004617          	auipc	a2,0x4
ffffffffc0201644:	20860613          	addi	a2,a2,520 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201648:	06200593          	li	a1,98
ffffffffc020164c:	00004517          	auipc	a0,0x4
ffffffffc0201650:	21450513          	addi	a0,a0,532 # ffffffffc0205860 <commands+0x8f0>
default_alloc_pages(size_t n) {
ffffffffc0201654:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201656:	dfbfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020165a <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020165a:	1141                	addi	sp,sp,-16
ffffffffc020165c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020165e:	c1ed                	beqz	a1,ffffffffc0201740 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0201660:	00659693          	slli	a3,a1,0x6
ffffffffc0201664:	96aa                	add	a3,a3,a0
ffffffffc0201666:	02d50463          	beq	a0,a3,ffffffffc020168e <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020166a:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020166c:	87aa                	mv	a5,a0
ffffffffc020166e:	8b05                	andi	a4,a4,1
ffffffffc0201670:	e709                	bnez	a4,ffffffffc020167a <default_init_memmap+0x20>
ffffffffc0201672:	a07d                	j	ffffffffc0201720 <default_init_memmap+0xc6>
ffffffffc0201674:	6798                	ld	a4,8(a5)
ffffffffc0201676:	8b05                	andi	a4,a4,1
ffffffffc0201678:	c745                	beqz	a4,ffffffffc0201720 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc020167a:	0007a823          	sw	zero,16(a5)
ffffffffc020167e:	0007b423          	sd	zero,8(a5)
ffffffffc0201682:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201686:	04078793          	addi	a5,a5,64
ffffffffc020168a:	fed795e3          	bne	a5,a3,ffffffffc0201674 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc020168e:	2581                	sext.w	a1,a1
ffffffffc0201690:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201692:	4789                	li	a5,2
ffffffffc0201694:	00850713          	addi	a4,a0,8
ffffffffc0201698:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020169c:	00014697          	auipc	a3,0x14
ffffffffc02016a0:	e3468693          	addi	a3,a3,-460 # ffffffffc02154d0 <free_area>
ffffffffc02016a4:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02016a6:	669c                	ld	a5,8(a3)
ffffffffc02016a8:	9db9                	addw	a1,a1,a4
ffffffffc02016aa:	00014717          	auipc	a4,0x14
ffffffffc02016ae:	e2b72b23          	sw	a1,-458(a4) # ffffffffc02154e0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02016b2:	04d78a63          	beq	a5,a3,ffffffffc0201706 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02016b6:	fe878713          	addi	a4,a5,-24
ffffffffc02016ba:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016bc:	4801                	li	a6,0
ffffffffc02016be:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016c2:	00e56a63          	bltu	a0,a4,ffffffffc02016d6 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc02016c6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016c8:	02d70563          	beq	a4,a3,ffffffffc02016f2 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016cc:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016ce:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016d2:	fee57ae3          	bleu	a4,a0,ffffffffc02016c6 <default_init_memmap+0x6c>
ffffffffc02016d6:	00080663          	beqz	a6,ffffffffc02016e2 <default_init_memmap+0x88>
ffffffffc02016da:	00014717          	auipc	a4,0x14
ffffffffc02016de:	deb73b23          	sd	a1,-522(a4) # ffffffffc02154d0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016e2:	6398                	ld	a4,0(a5)
}
ffffffffc02016e4:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02016e6:	e390                	sd	a2,0(a5)
ffffffffc02016e8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02016ea:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016ec:	ed18                	sd	a4,24(a0)
ffffffffc02016ee:	0141                	addi	sp,sp,16
ffffffffc02016f0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02016f2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016f4:	f114                	sd	a3,32(a0)
ffffffffc02016f6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02016f8:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02016fa:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016fc:	00d70e63          	beq	a4,a3,ffffffffc0201718 <default_init_memmap+0xbe>
ffffffffc0201700:	4805                	li	a6,1
ffffffffc0201702:	87ba                	mv	a5,a4
ffffffffc0201704:	b7e9                	j	ffffffffc02016ce <default_init_memmap+0x74>
}
ffffffffc0201706:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201708:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020170c:	e398                	sd	a4,0(a5)
ffffffffc020170e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201710:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201712:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201714:	0141                	addi	sp,sp,16
ffffffffc0201716:	8082                	ret
ffffffffc0201718:	60a2                	ld	ra,8(sp)
ffffffffc020171a:	e290                	sd	a2,0(a3)
ffffffffc020171c:	0141                	addi	sp,sp,16
ffffffffc020171e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201720:	00004697          	auipc	a3,0x4
ffffffffc0201724:	4b068693          	addi	a3,a3,1200 # ffffffffc0205bd0 <commands+0xc60>
ffffffffc0201728:	00004617          	auipc	a2,0x4
ffffffffc020172c:	12060613          	addi	a2,a2,288 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201730:	04900593          	li	a1,73
ffffffffc0201734:	00004517          	auipc	a0,0x4
ffffffffc0201738:	12c50513          	addi	a0,a0,300 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020173c:	d15fe0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(n > 0);
ffffffffc0201740:	00004697          	auipc	a3,0x4
ffffffffc0201744:	48868693          	addi	a3,a3,1160 # ffffffffc0205bc8 <commands+0xc58>
ffffffffc0201748:	00004617          	auipc	a2,0x4
ffffffffc020174c:	10060613          	addi	a2,a2,256 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0201750:	04600593          	li	a1,70
ffffffffc0201754:	00004517          	auipc	a0,0x4
ffffffffc0201758:	10c50513          	addi	a0,a0,268 # ffffffffc0205860 <commands+0x8f0>
ffffffffc020175c:	cf5fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201760 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201760:	c125                	beqz	a0,ffffffffc02017c0 <slob_free+0x60>
		return;

	if (size)
ffffffffc0201762:	e1a5                	bnez	a1,ffffffffc02017c2 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201764:	100027f3          	csrr	a5,sstatus
ffffffffc0201768:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020176a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020176c:	e3bd                	bnez	a5,ffffffffc02017d2 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020176e:	00009797          	auipc	a5,0x9
ffffffffc0201772:	8e278793          	addi	a5,a5,-1822 # ffffffffc020a050 <slobfree>
ffffffffc0201776:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201778:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020177a:	00a7fa63          	bleu	a0,a5,ffffffffc020178e <slob_free+0x2e>
ffffffffc020177e:	00e56c63          	bltu	a0,a4,ffffffffc0201796 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201782:	00e7fa63          	bleu	a4,a5,ffffffffc0201796 <slob_free+0x36>
    return 0;
ffffffffc0201786:	87ba                	mv	a5,a4
ffffffffc0201788:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020178a:	fea7eae3          	bltu	a5,a0,ffffffffc020177e <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020178e:	fee7ece3          	bltu	a5,a4,ffffffffc0201786 <slob_free+0x26>
ffffffffc0201792:	fee57ae3          	bleu	a4,a0,ffffffffc0201786 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201796:	4110                	lw	a2,0(a0)
ffffffffc0201798:	00461693          	slli	a3,a2,0x4
ffffffffc020179c:	96aa                	add	a3,a3,a0
ffffffffc020179e:	08d70b63          	beq	a4,a3,ffffffffc0201834 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02017a2:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02017a4:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02017a6:	00469713          	slli	a4,a3,0x4
ffffffffc02017aa:	973e                	add	a4,a4,a5
ffffffffc02017ac:	08e50f63          	beq	a0,a4,ffffffffc020184a <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02017b0:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02017b2:	00009717          	auipc	a4,0x9
ffffffffc02017b6:	88f73f23          	sd	a5,-1890(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc02017ba:	c199                	beqz	a1,ffffffffc02017c0 <slob_free+0x60>
        intr_enable();
ffffffffc02017bc:	e17fe06f          	j	ffffffffc02005d2 <intr_enable>
ffffffffc02017c0:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02017c2:	05bd                	addi	a1,a1,15
ffffffffc02017c4:	8191                	srli	a1,a1,0x4
ffffffffc02017c6:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017c8:	100027f3          	csrr	a5,sstatus
ffffffffc02017cc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02017ce:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017d0:	dfd9                	beqz	a5,ffffffffc020176e <slob_free+0xe>
{
ffffffffc02017d2:	1101                	addi	sp,sp,-32
ffffffffc02017d4:	e42a                	sd	a0,8(sp)
ffffffffc02017d6:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02017d8:	e01fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017dc:	00009797          	auipc	a5,0x9
ffffffffc02017e0:	87478793          	addi	a5,a5,-1932 # ffffffffc020a050 <slobfree>
ffffffffc02017e4:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc02017e6:	6522                	ld	a0,8(sp)
ffffffffc02017e8:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017ea:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017ec:	00a7fa63          	bleu	a0,a5,ffffffffc0201800 <slob_free+0xa0>
ffffffffc02017f0:	00e56c63          	bltu	a0,a4,ffffffffc0201808 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017f4:	00e7fa63          	bleu	a4,a5,ffffffffc0201808 <slob_free+0xa8>
    return 0;
ffffffffc02017f8:	87ba                	mv	a5,a4
ffffffffc02017fa:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017fc:	fea7eae3          	bltu	a5,a0,ffffffffc02017f0 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201800:	fee7ece3          	bltu	a5,a4,ffffffffc02017f8 <slob_free+0x98>
ffffffffc0201804:	fee57ae3          	bleu	a4,a0,ffffffffc02017f8 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201808:	4110                	lw	a2,0(a0)
ffffffffc020180a:	00461693          	slli	a3,a2,0x4
ffffffffc020180e:	96aa                	add	a3,a3,a0
ffffffffc0201810:	04d70763          	beq	a4,a3,ffffffffc020185e <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201814:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201816:	4394                	lw	a3,0(a5)
ffffffffc0201818:	00469713          	slli	a4,a3,0x4
ffffffffc020181c:	973e                	add	a4,a4,a5
ffffffffc020181e:	04e50663          	beq	a0,a4,ffffffffc020186a <slob_free+0x10a>
		cur->next = b;
ffffffffc0201822:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201824:	00009717          	auipc	a4,0x9
ffffffffc0201828:	82f73623          	sd	a5,-2004(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc020182c:	e58d                	bnez	a1,ffffffffc0201856 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc020182e:	60e2                	ld	ra,24(sp)
ffffffffc0201830:	6105                	addi	sp,sp,32
ffffffffc0201832:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201834:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201836:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201838:	9e35                	addw	a2,a2,a3
ffffffffc020183a:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc020183c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020183e:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201840:	00469713          	slli	a4,a3,0x4
ffffffffc0201844:	973e                	add	a4,a4,a5
ffffffffc0201846:	f6e515e3          	bne	a0,a4,ffffffffc02017b0 <slob_free+0x50>
		cur->units += b->units;
ffffffffc020184a:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc020184c:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc020184e:	9eb9                	addw	a3,a3,a4
ffffffffc0201850:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201852:	e790                	sd	a2,8(a5)
ffffffffc0201854:	bfb9                	j	ffffffffc02017b2 <slob_free+0x52>
}
ffffffffc0201856:	60e2                	ld	ra,24(sp)
ffffffffc0201858:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020185a:	d79fe06f          	j	ffffffffc02005d2 <intr_enable>
		b->units += cur->next->units;
ffffffffc020185e:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201860:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201862:	9e35                	addw	a2,a2,a3
ffffffffc0201864:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201866:	e518                	sd	a4,8(a0)
ffffffffc0201868:	b77d                	j	ffffffffc0201816 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc020186a:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc020186c:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc020186e:	9eb9                	addw	a3,a3,a4
ffffffffc0201870:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201872:	e790                	sd	a2,8(a5)
ffffffffc0201874:	bf45                	j	ffffffffc0201824 <slob_free+0xc4>

ffffffffc0201876 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201876:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201878:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc020187a:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020187e:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201880:	38a000ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
  if(!page)
ffffffffc0201884:	c139                	beqz	a0,ffffffffc02018ca <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201886:	00014797          	auipc	a5,0x14
ffffffffc020188a:	c7a78793          	addi	a5,a5,-902 # ffffffffc0215500 <pages>
ffffffffc020188e:	6394                	ld	a3,0(a5)
ffffffffc0201890:	00005797          	auipc	a5,0x5
ffffffffc0201894:	6f878793          	addi	a5,a5,1784 # ffffffffc0206f88 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201898:	00014717          	auipc	a4,0x14
ffffffffc020189c:	bf870713          	addi	a4,a4,-1032 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc02018a0:	40d506b3          	sub	a3,a0,a3
ffffffffc02018a4:	6388                	ld	a0,0(a5)
ffffffffc02018a6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02018a8:	57fd                	li	a5,-1
ffffffffc02018aa:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc02018ac:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc02018ae:	83b1                	srli	a5,a5,0xc
ffffffffc02018b0:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02018b2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02018b4:	00e7ff63          	bleu	a4,a5,ffffffffc02018d2 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc02018b8:	00014797          	auipc	a5,0x14
ffffffffc02018bc:	c3878793          	addi	a5,a5,-968 # ffffffffc02154f0 <va_pa_offset>
ffffffffc02018c0:	6388                	ld	a0,0(a5)
}
ffffffffc02018c2:	60a2                	ld	ra,8(sp)
ffffffffc02018c4:	9536                	add	a0,a0,a3
ffffffffc02018c6:	0141                	addi	sp,sp,16
ffffffffc02018c8:	8082                	ret
ffffffffc02018ca:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc02018cc:	4501                	li	a0,0
}
ffffffffc02018ce:	0141                	addi	sp,sp,16
ffffffffc02018d0:	8082                	ret
ffffffffc02018d2:	00004617          	auipc	a2,0x4
ffffffffc02018d6:	35e60613          	addi	a2,a2,862 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc02018da:	06900593          	li	a1,105
ffffffffc02018de:	00004517          	auipc	a0,0x4
ffffffffc02018e2:	37a50513          	addi	a0,a0,890 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc02018e6:	b6bfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02018ea <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02018ea:	7179                	addi	sp,sp,-48
ffffffffc02018ec:	f406                	sd	ra,40(sp)
ffffffffc02018ee:	f022                	sd	s0,32(sp)
ffffffffc02018f0:	ec26                	sd	s1,24(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02018f2:	01050713          	addi	a4,a0,16
ffffffffc02018f6:	6785                	lui	a5,0x1
ffffffffc02018f8:	0cf77b63          	bleu	a5,a4,ffffffffc02019ce <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02018fc:	00f50413          	addi	s0,a0,15
ffffffffc0201900:	8011                	srli	s0,s0,0x4
ffffffffc0201902:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201904:	10002673          	csrr	a2,sstatus
ffffffffc0201908:	8a09                	andi	a2,a2,2
ffffffffc020190a:	ea5d                	bnez	a2,ffffffffc02019c0 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc020190c:	00008497          	auipc	s1,0x8
ffffffffc0201910:	74448493          	addi	s1,s1,1860 # ffffffffc020a050 <slobfree>
ffffffffc0201914:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201916:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201918:	4398                	lw	a4,0(a5)
ffffffffc020191a:	0a875763          	ble	s0,a4,ffffffffc02019c8 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc020191e:	00f68a63          	beq	a3,a5,ffffffffc0201932 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201922:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201924:	4118                	lw	a4,0(a0)
ffffffffc0201926:	02875763          	ble	s0,a4,ffffffffc0201954 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc020192a:	6094                	ld	a3,0(s1)
ffffffffc020192c:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc020192e:	fef69ae3          	bne	a3,a5,ffffffffc0201922 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201932:	ea39                	bnez	a2,ffffffffc0201988 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201934:	4501                	li	a0,0
ffffffffc0201936:	f41ff0ef          	jal	ra,ffffffffc0201876 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc020193a:	cd29                	beqz	a0,ffffffffc0201994 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc020193c:	6585                	lui	a1,0x1
ffffffffc020193e:	e23ff0ef          	jal	ra,ffffffffc0201760 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201942:	10002673          	csrr	a2,sstatus
ffffffffc0201946:	8a09                	andi	a2,a2,2
ffffffffc0201948:	ea1d                	bnez	a2,ffffffffc020197e <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc020194a:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020194c:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020194e:	4118                	lw	a4,0(a0)
ffffffffc0201950:	fc874de3          	blt	a4,s0,ffffffffc020192a <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201954:	04e40663          	beq	s0,a4,ffffffffc02019a0 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201958:	00441693          	slli	a3,s0,0x4
ffffffffc020195c:	96aa                	add	a3,a3,a0
ffffffffc020195e:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201960:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201962:	9f01                	subw	a4,a4,s0
ffffffffc0201964:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201966:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201968:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc020196a:	00008717          	auipc	a4,0x8
ffffffffc020196e:	6ef73323          	sd	a5,1766(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0201972:	ee15                	bnez	a2,ffffffffc02019ae <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201974:	70a2                	ld	ra,40(sp)
ffffffffc0201976:	7402                	ld	s0,32(sp)
ffffffffc0201978:	64e2                	ld	s1,24(sp)
ffffffffc020197a:	6145                	addi	sp,sp,48
ffffffffc020197c:	8082                	ret
        intr_disable();
ffffffffc020197e:	c5bfe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc0201982:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201984:	609c                	ld	a5,0(s1)
ffffffffc0201986:	b7d9                	j	ffffffffc020194c <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201988:	c4bfe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc020198c:	4501                	li	a0,0
ffffffffc020198e:	ee9ff0ef          	jal	ra,ffffffffc0201876 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201992:	f54d                	bnez	a0,ffffffffc020193c <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201994:	70a2                	ld	ra,40(sp)
ffffffffc0201996:	7402                	ld	s0,32(sp)
ffffffffc0201998:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc020199a:	4501                	li	a0,0
}
ffffffffc020199c:	6145                	addi	sp,sp,48
ffffffffc020199e:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02019a0:	6518                	ld	a4,8(a0)
ffffffffc02019a2:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc02019a4:	00008717          	auipc	a4,0x8
ffffffffc02019a8:	6af73623          	sd	a5,1708(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc02019ac:	d661                	beqz	a2,ffffffffc0201974 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc02019ae:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02019b0:	c23fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
}
ffffffffc02019b4:	70a2                	ld	ra,40(sp)
ffffffffc02019b6:	7402                	ld	s0,32(sp)
ffffffffc02019b8:	6522                	ld	a0,8(sp)
ffffffffc02019ba:	64e2                	ld	s1,24(sp)
ffffffffc02019bc:	6145                	addi	sp,sp,48
ffffffffc02019be:	8082                	ret
        intr_disable();
ffffffffc02019c0:	c19fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc02019c4:	4605                	li	a2,1
ffffffffc02019c6:	b799                	j	ffffffffc020190c <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02019c8:	853e                	mv	a0,a5
ffffffffc02019ca:	87b6                	mv	a5,a3
ffffffffc02019cc:	b761                	j	ffffffffc0201954 <slob_alloc.isra.1.constprop.3+0x6a>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02019ce:	00004697          	auipc	a3,0x4
ffffffffc02019d2:	30268693          	addi	a3,a3,770 # ffffffffc0205cd0 <default_pmm_manager+0xf0>
ffffffffc02019d6:	00004617          	auipc	a2,0x4
ffffffffc02019da:	e7260613          	addi	a2,a2,-398 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02019de:	06300593          	li	a1,99
ffffffffc02019e2:	00004517          	auipc	a0,0x4
ffffffffc02019e6:	30e50513          	addi	a0,a0,782 # ffffffffc0205cf0 <default_pmm_manager+0x110>
ffffffffc02019ea:	a67fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02019ee <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02019ee:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02019f0:	00004517          	auipc	a0,0x4
ffffffffc02019f4:	31850513          	addi	a0,a0,792 # ffffffffc0205d08 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc02019f8:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02019fa:	f94fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02019fe:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201a00:	00004517          	auipc	a0,0x4
ffffffffc0201a04:	2b050513          	addi	a0,a0,688 # ffffffffc0205cb0 <default_pmm_manager+0xd0>
}
ffffffffc0201a08:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201a0a:	f84fe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201a0e <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201a0e:	1101                	addi	sp,sp,-32
ffffffffc0201a10:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a12:	6905                	lui	s2,0x1
{
ffffffffc0201a14:	e822                	sd	s0,16(sp)
ffffffffc0201a16:	ec06                	sd	ra,24(sp)
ffffffffc0201a18:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a1a:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc0201a1e:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a20:	04a7fc63          	bleu	a0,a5,ffffffffc0201a78 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201a24:	4561                	li	a0,24
ffffffffc0201a26:	ec5ff0ef          	jal	ra,ffffffffc02018ea <slob_alloc.isra.1.constprop.3>
ffffffffc0201a2a:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201a2c:	cd21                	beqz	a0,ffffffffc0201a84 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201a2e:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201a32:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201a34:	00f95763          	ble	a5,s2,ffffffffc0201a42 <kmalloc+0x34>
ffffffffc0201a38:	6705                	lui	a4,0x1
ffffffffc0201a3a:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201a3c:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201a3e:	fef74ee3          	blt	a4,a5,ffffffffc0201a3a <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201a42:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201a44:	e33ff0ef          	jal	ra,ffffffffc0201876 <__slob_get_free_pages.isra.0>
ffffffffc0201a48:	e488                	sd	a0,8(s1)
ffffffffc0201a4a:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201a4c:	c935                	beqz	a0,ffffffffc0201ac0 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a4e:	100027f3          	csrr	a5,sstatus
ffffffffc0201a52:	8b89                	andi	a5,a5,2
ffffffffc0201a54:	e3a1                	bnez	a5,ffffffffc0201a94 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201a56:	00014797          	auipc	a5,0x14
ffffffffc0201a5a:	a2a78793          	addi	a5,a5,-1494 # ffffffffc0215480 <bigblocks>
ffffffffc0201a5e:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201a60:	00014717          	auipc	a4,0x14
ffffffffc0201a64:	a2973023          	sd	s1,-1504(a4) # ffffffffc0215480 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201a68:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201a6a:	8522                	mv	a0,s0
ffffffffc0201a6c:	60e2                	ld	ra,24(sp)
ffffffffc0201a6e:	6442                	ld	s0,16(sp)
ffffffffc0201a70:	64a2                	ld	s1,8(sp)
ffffffffc0201a72:	6902                	ld	s2,0(sp)
ffffffffc0201a74:	6105                	addi	sp,sp,32
ffffffffc0201a76:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201a78:	0541                	addi	a0,a0,16
ffffffffc0201a7a:	e71ff0ef          	jal	ra,ffffffffc02018ea <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201a7e:	01050413          	addi	s0,a0,16
ffffffffc0201a82:	f565                	bnez	a0,ffffffffc0201a6a <kmalloc+0x5c>
ffffffffc0201a84:	4401                	li	s0,0
}
ffffffffc0201a86:	8522                	mv	a0,s0
ffffffffc0201a88:	60e2                	ld	ra,24(sp)
ffffffffc0201a8a:	6442                	ld	s0,16(sp)
ffffffffc0201a8c:	64a2                	ld	s1,8(sp)
ffffffffc0201a8e:	6902                	ld	s2,0(sp)
ffffffffc0201a90:	6105                	addi	sp,sp,32
ffffffffc0201a92:	8082                	ret
        intr_disable();
ffffffffc0201a94:	b45fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201a98:	00014797          	auipc	a5,0x14
ffffffffc0201a9c:	9e878793          	addi	a5,a5,-1560 # ffffffffc0215480 <bigblocks>
ffffffffc0201aa0:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201aa2:	00014717          	auipc	a4,0x14
ffffffffc0201aa6:	9c973f23          	sd	s1,-1570(a4) # ffffffffc0215480 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201aaa:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201aac:	b27fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201ab0:	6480                	ld	s0,8(s1)
}
ffffffffc0201ab2:	60e2                	ld	ra,24(sp)
ffffffffc0201ab4:	64a2                	ld	s1,8(sp)
ffffffffc0201ab6:	8522                	mv	a0,s0
ffffffffc0201ab8:	6442                	ld	s0,16(sp)
ffffffffc0201aba:	6902                	ld	s2,0(sp)
ffffffffc0201abc:	6105                	addi	sp,sp,32
ffffffffc0201abe:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ac0:	45e1                	li	a1,24
ffffffffc0201ac2:	8526                	mv	a0,s1
ffffffffc0201ac4:	c9dff0ef          	jal	ra,ffffffffc0201760 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201ac8:	b74d                	j	ffffffffc0201a6a <kmalloc+0x5c>

ffffffffc0201aca <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201aca:	c175                	beqz	a0,ffffffffc0201bae <kfree+0xe4>
{
ffffffffc0201acc:	1101                	addi	sp,sp,-32
ffffffffc0201ace:	e426                	sd	s1,8(sp)
ffffffffc0201ad0:	ec06                	sd	ra,24(sp)
ffffffffc0201ad2:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201ad4:	03451793          	slli	a5,a0,0x34
ffffffffc0201ad8:	84aa                	mv	s1,a0
ffffffffc0201ada:	eb8d                	bnez	a5,ffffffffc0201b0c <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201adc:	100027f3          	csrr	a5,sstatus
ffffffffc0201ae0:	8b89                	andi	a5,a5,2
ffffffffc0201ae2:	efc9                	bnez	a5,ffffffffc0201b7c <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ae4:	00014797          	auipc	a5,0x14
ffffffffc0201ae8:	99c78793          	addi	a5,a5,-1636 # ffffffffc0215480 <bigblocks>
ffffffffc0201aec:	6394                	ld	a3,0(a5)
ffffffffc0201aee:	ce99                	beqz	a3,ffffffffc0201b0c <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201af0:	669c                	ld	a5,8(a3)
ffffffffc0201af2:	6a80                	ld	s0,16(a3)
ffffffffc0201af4:	0af50e63          	beq	a0,a5,ffffffffc0201bb0 <kfree+0xe6>
    return 0;
ffffffffc0201af8:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201afa:	c801                	beqz	s0,ffffffffc0201b0a <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201afc:	6418                	ld	a4,8(s0)
ffffffffc0201afe:	681c                	ld	a5,16(s0)
ffffffffc0201b00:	00970f63          	beq	a4,s1,ffffffffc0201b1e <kfree+0x54>
ffffffffc0201b04:	86a2                	mv	a3,s0
ffffffffc0201b06:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b08:	f875                	bnez	s0,ffffffffc0201afc <kfree+0x32>
    if (flag) {
ffffffffc0201b0a:	e659                	bnez	a2,ffffffffc0201b98 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201b0c:	6442                	ld	s0,16(sp)
ffffffffc0201b0e:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b10:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201b14:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b16:	4581                	li	a1,0
}
ffffffffc0201b18:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b1a:	c47ff06f          	j	ffffffffc0201760 <slob_free>
				*last = bb->next;
ffffffffc0201b1e:	ea9c                	sd	a5,16(a3)
ffffffffc0201b20:	e641                	bnez	a2,ffffffffc0201ba8 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201b22:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201b26:	4018                	lw	a4,0(s0)
ffffffffc0201b28:	08f4ea63          	bltu	s1,a5,ffffffffc0201bbc <kfree+0xf2>
ffffffffc0201b2c:	00014797          	auipc	a5,0x14
ffffffffc0201b30:	9c478793          	addi	a5,a5,-1596 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201b34:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201b36:	00014797          	auipc	a5,0x14
ffffffffc0201b3a:	95a78793          	addi	a5,a5,-1702 # ffffffffc0215490 <npage>
ffffffffc0201b3e:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201b40:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201b42:	80b1                	srli	s1,s1,0xc
ffffffffc0201b44:	08f4f963          	bleu	a5,s1,ffffffffc0201bd6 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b48:	00005797          	auipc	a5,0x5
ffffffffc0201b4c:	44078793          	addi	a5,a5,1088 # ffffffffc0206f88 <nbase>
ffffffffc0201b50:	639c                	ld	a5,0(a5)
ffffffffc0201b52:	00014697          	auipc	a3,0x14
ffffffffc0201b56:	9ae68693          	addi	a3,a3,-1618 # ffffffffc0215500 <pages>
ffffffffc0201b5a:	6288                	ld	a0,0(a3)
ffffffffc0201b5c:	8c9d                	sub	s1,s1,a5
ffffffffc0201b5e:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201b60:	4585                	li	a1,1
ffffffffc0201b62:	9526                	add	a0,a0,s1
ffffffffc0201b64:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201b68:	12a000ef          	jal	ra,ffffffffc0201c92 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b6c:	8522                	mv	a0,s0
}
ffffffffc0201b6e:	6442                	ld	s0,16(sp)
ffffffffc0201b70:	60e2                	ld	ra,24(sp)
ffffffffc0201b72:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b74:	45e1                	li	a1,24
}
ffffffffc0201b76:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b78:	be9ff06f          	j	ffffffffc0201760 <slob_free>
        intr_disable();
ffffffffc0201b7c:	a5dfe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b80:	00014797          	auipc	a5,0x14
ffffffffc0201b84:	90078793          	addi	a5,a5,-1792 # ffffffffc0215480 <bigblocks>
ffffffffc0201b88:	6394                	ld	a3,0(a5)
ffffffffc0201b8a:	c699                	beqz	a3,ffffffffc0201b98 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201b8c:	669c                	ld	a5,8(a3)
ffffffffc0201b8e:	6a80                	ld	s0,16(a3)
ffffffffc0201b90:	00f48763          	beq	s1,a5,ffffffffc0201b9e <kfree+0xd4>
        return 1;
ffffffffc0201b94:	4605                	li	a2,1
ffffffffc0201b96:	b795                	j	ffffffffc0201afa <kfree+0x30>
        intr_enable();
ffffffffc0201b98:	a3bfe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201b9c:	bf85                	j	ffffffffc0201b0c <kfree+0x42>
				*last = bb->next;
ffffffffc0201b9e:	00014797          	auipc	a5,0x14
ffffffffc0201ba2:	8e87b123          	sd	s0,-1822(a5) # ffffffffc0215480 <bigblocks>
ffffffffc0201ba6:	8436                	mv	s0,a3
ffffffffc0201ba8:	a2bfe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201bac:	bf9d                	j	ffffffffc0201b22 <kfree+0x58>
ffffffffc0201bae:	8082                	ret
ffffffffc0201bb0:	00014797          	auipc	a5,0x14
ffffffffc0201bb4:	8c87b823          	sd	s0,-1840(a5) # ffffffffc0215480 <bigblocks>
ffffffffc0201bb8:	8436                	mv	s0,a3
ffffffffc0201bba:	b7a5                	j	ffffffffc0201b22 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201bbc:	86a6                	mv	a3,s1
ffffffffc0201bbe:	00004617          	auipc	a2,0x4
ffffffffc0201bc2:	0aa60613          	addi	a2,a2,170 # ffffffffc0205c68 <default_pmm_manager+0x88>
ffffffffc0201bc6:	06e00593          	li	a1,110
ffffffffc0201bca:	00004517          	auipc	a0,0x4
ffffffffc0201bce:	08e50513          	addi	a0,a0,142 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc0201bd2:	87ffe0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201bd6:	00004617          	auipc	a2,0x4
ffffffffc0201bda:	0ba60613          	addi	a2,a2,186 # ffffffffc0205c90 <default_pmm_manager+0xb0>
ffffffffc0201bde:	06200593          	li	a1,98
ffffffffc0201be2:	00004517          	auipc	a0,0x4
ffffffffc0201be6:	07650513          	addi	a0,a0,118 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc0201bea:	867fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201bee <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201bee:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201bf0:	00004617          	auipc	a2,0x4
ffffffffc0201bf4:	0a060613          	addi	a2,a2,160 # ffffffffc0205c90 <default_pmm_manager+0xb0>
ffffffffc0201bf8:	06200593          	li	a1,98
ffffffffc0201bfc:	00004517          	auipc	a0,0x4
ffffffffc0201c00:	05c50513          	addi	a0,a0,92 # ffffffffc0205c58 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201c04:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201c06:	84bfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201c0a <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201c0a:	715d                	addi	sp,sp,-80
ffffffffc0201c0c:	e0a2                	sd	s0,64(sp)
ffffffffc0201c0e:	fc26                	sd	s1,56(sp)
ffffffffc0201c10:	f84a                	sd	s2,48(sp)
ffffffffc0201c12:	f44e                	sd	s3,40(sp)
ffffffffc0201c14:	f052                	sd	s4,32(sp)
ffffffffc0201c16:	ec56                	sd	s5,24(sp)
ffffffffc0201c18:	e486                	sd	ra,72(sp)
ffffffffc0201c1a:	842a                	mv	s0,a0
ffffffffc0201c1c:	00014497          	auipc	s1,0x14
ffffffffc0201c20:	8cc48493          	addi	s1,s1,-1844 # ffffffffc02154e8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201c24:	4985                	li	s3,1
ffffffffc0201c26:	00014a17          	auipc	s4,0x14
ffffffffc0201c2a:	87aa0a13          	addi	s4,s4,-1926 # ffffffffc02154a0 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c2e:	0005091b          	sext.w	s2,a0
ffffffffc0201c32:	00014a97          	auipc	s5,0x14
ffffffffc0201c36:	9aea8a93          	addi	s5,s5,-1618 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0201c3a:	a00d                	j	ffffffffc0201c5c <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201c3c:	609c                	ld	a5,0(s1)
ffffffffc0201c3e:	6f9c                	ld	a5,24(a5)
ffffffffc0201c40:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c42:	4601                	li	a2,0
ffffffffc0201c44:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201c46:	ed0d                	bnez	a0,ffffffffc0201c80 <alloc_pages+0x76>
ffffffffc0201c48:	0289ec63          	bltu	s3,s0,ffffffffc0201c80 <alloc_pages+0x76>
ffffffffc0201c4c:	000a2783          	lw	a5,0(s4)
ffffffffc0201c50:	2781                	sext.w	a5,a5
ffffffffc0201c52:	c79d                	beqz	a5,ffffffffc0201c80 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c54:	000ab503          	ld	a0,0(s5)
ffffffffc0201c58:	6dc010ef          	jal	ra,ffffffffc0203334 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c5c:	100027f3          	csrr	a5,sstatus
ffffffffc0201c60:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201c62:	8522                	mv	a0,s0
ffffffffc0201c64:	dfe1                	beqz	a5,ffffffffc0201c3c <alloc_pages+0x32>
        intr_disable();
ffffffffc0201c66:	973fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc0201c6a:	609c                	ld	a5,0(s1)
ffffffffc0201c6c:	8522                	mv	a0,s0
ffffffffc0201c6e:	6f9c                	ld	a5,24(a5)
ffffffffc0201c70:	9782                	jalr	a5
ffffffffc0201c72:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201c74:	95ffe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201c78:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c7a:	4601                	li	a2,0
ffffffffc0201c7c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201c7e:	d569                	beqz	a0,ffffffffc0201c48 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201c80:	60a6                	ld	ra,72(sp)
ffffffffc0201c82:	6406                	ld	s0,64(sp)
ffffffffc0201c84:	74e2                	ld	s1,56(sp)
ffffffffc0201c86:	7942                	ld	s2,48(sp)
ffffffffc0201c88:	79a2                	ld	s3,40(sp)
ffffffffc0201c8a:	7a02                	ld	s4,32(sp)
ffffffffc0201c8c:	6ae2                	ld	s5,24(sp)
ffffffffc0201c8e:	6161                	addi	sp,sp,80
ffffffffc0201c90:	8082                	ret

ffffffffc0201c92 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c92:	100027f3          	csrr	a5,sstatus
ffffffffc0201c96:	8b89                	andi	a5,a5,2
ffffffffc0201c98:	eb89                	bnez	a5,ffffffffc0201caa <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201c9a:	00014797          	auipc	a5,0x14
ffffffffc0201c9e:	84e78793          	addi	a5,a5,-1970 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201ca2:	639c                	ld	a5,0(a5)
ffffffffc0201ca4:	0207b303          	ld	t1,32(a5)
ffffffffc0201ca8:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201caa:	1101                	addi	sp,sp,-32
ffffffffc0201cac:	ec06                	sd	ra,24(sp)
ffffffffc0201cae:	e822                	sd	s0,16(sp)
ffffffffc0201cb0:	e426                	sd	s1,8(sp)
ffffffffc0201cb2:	842a                	mv	s0,a0
ffffffffc0201cb4:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201cb6:	923fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201cba:	00014797          	auipc	a5,0x14
ffffffffc0201cbe:	82e78793          	addi	a5,a5,-2002 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201cc2:	639c                	ld	a5,0(a5)
ffffffffc0201cc4:	85a6                	mv	a1,s1
ffffffffc0201cc6:	8522                	mv	a0,s0
ffffffffc0201cc8:	739c                	ld	a5,32(a5)
ffffffffc0201cca:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201ccc:	6442                	ld	s0,16(sp)
ffffffffc0201cce:	60e2                	ld	ra,24(sp)
ffffffffc0201cd0:	64a2                	ld	s1,8(sp)
ffffffffc0201cd2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201cd4:	8fffe06f          	j	ffffffffc02005d2 <intr_enable>

ffffffffc0201cd8 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201cd8:	100027f3          	csrr	a5,sstatus
ffffffffc0201cdc:	8b89                	andi	a5,a5,2
ffffffffc0201cde:	eb89                	bnez	a5,ffffffffc0201cf0 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201ce0:	00014797          	auipc	a5,0x14
ffffffffc0201ce4:	80878793          	addi	a5,a5,-2040 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201ce8:	639c                	ld	a5,0(a5)
ffffffffc0201cea:	0287b303          	ld	t1,40(a5)
ffffffffc0201cee:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201cf0:	1141                	addi	sp,sp,-16
ffffffffc0201cf2:	e406                	sd	ra,8(sp)
ffffffffc0201cf4:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201cf6:	8e3fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201cfa:	00013797          	auipc	a5,0x13
ffffffffc0201cfe:	7ee78793          	addi	a5,a5,2030 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201d02:	639c                	ld	a5,0(a5)
ffffffffc0201d04:	779c                	ld	a5,40(a5)
ffffffffc0201d06:	9782                	jalr	a5
ffffffffc0201d08:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d0a:	8c9fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201d0e:	8522                	mv	a0,s0
ffffffffc0201d10:	60a2                	ld	ra,8(sp)
ffffffffc0201d12:	6402                	ld	s0,0(sp)
ffffffffc0201d14:	0141                	addi	sp,sp,16
ffffffffc0201d16:	8082                	ret

ffffffffc0201d18 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201d18:	7139                	addi	sp,sp,-64
ffffffffc0201d1a:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201d1c:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201d20:	1ff4f493          	andi	s1,s1,511
ffffffffc0201d24:	048e                	slli	s1,s1,0x3
ffffffffc0201d26:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201d28:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201d2a:	f04a                	sd	s2,32(sp)
ffffffffc0201d2c:	ec4e                	sd	s3,24(sp)
ffffffffc0201d2e:	e852                	sd	s4,16(sp)
ffffffffc0201d30:	fc06                	sd	ra,56(sp)
ffffffffc0201d32:	f822                	sd	s0,48(sp)
ffffffffc0201d34:	e456                	sd	s5,8(sp)
ffffffffc0201d36:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201d38:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201d3c:	892e                	mv	s2,a1
ffffffffc0201d3e:	8a32                	mv	s4,a2
ffffffffc0201d40:	00013997          	auipc	s3,0x13
ffffffffc0201d44:	75098993          	addi	s3,s3,1872 # ffffffffc0215490 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201d48:	e7bd                	bnez	a5,ffffffffc0201db6 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201d4a:	12060c63          	beqz	a2,ffffffffc0201e82 <get_pte+0x16a>
ffffffffc0201d4e:	4505                	li	a0,1
ffffffffc0201d50:	ebbff0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0201d54:	842a                	mv	s0,a0
ffffffffc0201d56:	12050663          	beqz	a0,ffffffffc0201e82 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201d5a:	00013b17          	auipc	s6,0x13
ffffffffc0201d5e:	7a6b0b13          	addi	s6,s6,1958 # ffffffffc0215500 <pages>
ffffffffc0201d62:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201d66:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d68:	00013997          	auipc	s3,0x13
ffffffffc0201d6c:	72898993          	addi	s3,s3,1832 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc0201d70:	40a40533          	sub	a0,s0,a0
ffffffffc0201d74:	00080ab7          	lui	s5,0x80
ffffffffc0201d78:	8519                	srai	a0,a0,0x6
ffffffffc0201d7a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201d7e:	c01c                	sw	a5,0(s0)
ffffffffc0201d80:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201d82:	9556                	add	a0,a0,s5
ffffffffc0201d84:	83b1                	srli	a5,a5,0xc
ffffffffc0201d86:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d88:	0532                	slli	a0,a0,0xc
ffffffffc0201d8a:	14e7f363          	bleu	a4,a5,ffffffffc0201ed0 <get_pte+0x1b8>
ffffffffc0201d8e:	00013797          	auipc	a5,0x13
ffffffffc0201d92:	76278793          	addi	a5,a5,1890 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201d96:	639c                	ld	a5,0(a5)
ffffffffc0201d98:	6605                	lui	a2,0x1
ffffffffc0201d9a:	4581                	li	a1,0
ffffffffc0201d9c:	953e                	add	a0,a0,a5
ffffffffc0201d9e:	048030ef          	jal	ra,ffffffffc0204de6 <memset>
    return page - pages + nbase;
ffffffffc0201da2:	000b3683          	ld	a3,0(s6)
ffffffffc0201da6:	40d406b3          	sub	a3,s0,a3
ffffffffc0201daa:	8699                	srai	a3,a3,0x6
ffffffffc0201dac:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201dae:	06aa                	slli	a3,a3,0xa
ffffffffc0201db0:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201db4:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201db6:	77fd                	lui	a5,0xfffff
ffffffffc0201db8:	068a                	slli	a3,a3,0x2
ffffffffc0201dba:	0009b703          	ld	a4,0(s3)
ffffffffc0201dbe:	8efd                	and	a3,a3,a5
ffffffffc0201dc0:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201dc4:	0ce7f163          	bleu	a4,a5,ffffffffc0201e86 <get_pte+0x16e>
ffffffffc0201dc8:	00013a97          	auipc	s5,0x13
ffffffffc0201dcc:	728a8a93          	addi	s5,s5,1832 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201dd0:	000ab403          	ld	s0,0(s5)
ffffffffc0201dd4:	01595793          	srli	a5,s2,0x15
ffffffffc0201dd8:	1ff7f793          	andi	a5,a5,511
ffffffffc0201ddc:	96a2                	add	a3,a3,s0
ffffffffc0201dde:	00379413          	slli	s0,a5,0x3
ffffffffc0201de2:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201de4:	6014                	ld	a3,0(s0)
ffffffffc0201de6:	0016f793          	andi	a5,a3,1
ffffffffc0201dea:	e3ad                	bnez	a5,ffffffffc0201e4c <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201dec:	080a0b63          	beqz	s4,ffffffffc0201e82 <get_pte+0x16a>
ffffffffc0201df0:	4505                	li	a0,1
ffffffffc0201df2:	e19ff0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0201df6:	84aa                	mv	s1,a0
ffffffffc0201df8:	c549                	beqz	a0,ffffffffc0201e82 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201dfa:	00013b17          	auipc	s6,0x13
ffffffffc0201dfe:	706b0b13          	addi	s6,s6,1798 # ffffffffc0215500 <pages>
ffffffffc0201e02:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201e06:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0201e08:	00080a37          	lui	s4,0x80
ffffffffc0201e0c:	40a48533          	sub	a0,s1,a0
ffffffffc0201e10:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e12:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201e16:	c09c                	sw	a5,0(s1)
ffffffffc0201e18:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201e1a:	9552                	add	a0,a0,s4
ffffffffc0201e1c:	83b1                	srli	a5,a5,0xc
ffffffffc0201e1e:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e20:	0532                	slli	a0,a0,0xc
ffffffffc0201e22:	08e7fa63          	bleu	a4,a5,ffffffffc0201eb6 <get_pte+0x19e>
ffffffffc0201e26:	000ab783          	ld	a5,0(s5)
ffffffffc0201e2a:	6605                	lui	a2,0x1
ffffffffc0201e2c:	4581                	li	a1,0
ffffffffc0201e2e:	953e                	add	a0,a0,a5
ffffffffc0201e30:	7b7020ef          	jal	ra,ffffffffc0204de6 <memset>
    return page - pages + nbase;
ffffffffc0201e34:	000b3683          	ld	a3,0(s6)
ffffffffc0201e38:	40d486b3          	sub	a3,s1,a3
ffffffffc0201e3c:	8699                	srai	a3,a3,0x6
ffffffffc0201e3e:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e40:	06aa                	slli	a3,a3,0xa
ffffffffc0201e42:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201e46:	e014                	sd	a3,0(s0)
ffffffffc0201e48:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201e4c:	068a                	slli	a3,a3,0x2
ffffffffc0201e4e:	757d                	lui	a0,0xfffff
ffffffffc0201e50:	8ee9                	and	a3,a3,a0
ffffffffc0201e52:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e56:	04e7f463          	bleu	a4,a5,ffffffffc0201e9e <get_pte+0x186>
ffffffffc0201e5a:	000ab503          	ld	a0,0(s5)
ffffffffc0201e5e:	00c95793          	srli	a5,s2,0xc
ffffffffc0201e62:	1ff7f793          	andi	a5,a5,511
ffffffffc0201e66:	96aa                	add	a3,a3,a0
ffffffffc0201e68:	00379513          	slli	a0,a5,0x3
ffffffffc0201e6c:	9536                	add	a0,a0,a3
}
ffffffffc0201e6e:	70e2                	ld	ra,56(sp)
ffffffffc0201e70:	7442                	ld	s0,48(sp)
ffffffffc0201e72:	74a2                	ld	s1,40(sp)
ffffffffc0201e74:	7902                	ld	s2,32(sp)
ffffffffc0201e76:	69e2                	ld	s3,24(sp)
ffffffffc0201e78:	6a42                	ld	s4,16(sp)
ffffffffc0201e7a:	6aa2                	ld	s5,8(sp)
ffffffffc0201e7c:	6b02                	ld	s6,0(sp)
ffffffffc0201e7e:	6121                	addi	sp,sp,64
ffffffffc0201e80:	8082                	ret
            return NULL;
ffffffffc0201e82:	4501                	li	a0,0
ffffffffc0201e84:	b7ed                	j	ffffffffc0201e6e <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e86:	00004617          	auipc	a2,0x4
ffffffffc0201e8a:	daa60613          	addi	a2,a2,-598 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc0201e8e:	0e400593          	li	a1,228
ffffffffc0201e92:	00004517          	auipc	a0,0x4
ffffffffc0201e96:	e8e50513          	addi	a0,a0,-370 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0201e9a:	db6fe0ef          	jal	ra,ffffffffc0200450 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201e9e:	00004617          	auipc	a2,0x4
ffffffffc0201ea2:	d9260613          	addi	a2,a2,-622 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc0201ea6:	0ef00593          	li	a1,239
ffffffffc0201eaa:	00004517          	auipc	a0,0x4
ffffffffc0201eae:	e7650513          	addi	a0,a0,-394 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0201eb2:	d9efe0ef          	jal	ra,ffffffffc0200450 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201eb6:	86aa                	mv	a3,a0
ffffffffc0201eb8:	00004617          	auipc	a2,0x4
ffffffffc0201ebc:	d7860613          	addi	a2,a2,-648 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc0201ec0:	0ec00593          	li	a1,236
ffffffffc0201ec4:	00004517          	auipc	a0,0x4
ffffffffc0201ec8:	e5c50513          	addi	a0,a0,-420 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0201ecc:	d84fe0ef          	jal	ra,ffffffffc0200450 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201ed0:	86aa                	mv	a3,a0
ffffffffc0201ed2:	00004617          	auipc	a2,0x4
ffffffffc0201ed6:	d5e60613          	addi	a2,a2,-674 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc0201eda:	0e100593          	li	a1,225
ffffffffc0201ede:	00004517          	auipc	a0,0x4
ffffffffc0201ee2:	e4250513          	addi	a0,a0,-446 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0201ee6:	d6afe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201eea <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201eea:	1141                	addi	sp,sp,-16
ffffffffc0201eec:	e022                	sd	s0,0(sp)
ffffffffc0201eee:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201ef0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201ef2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201ef4:	e25ff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201ef8:	c011                	beqz	s0,ffffffffc0201efc <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201efa:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201efc:	c129                	beqz	a0,ffffffffc0201f3e <get_page+0x54>
ffffffffc0201efe:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201f00:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201f02:	0017f713          	andi	a4,a5,1
ffffffffc0201f06:	e709                	bnez	a4,ffffffffc0201f10 <get_page+0x26>
}
ffffffffc0201f08:	60a2                	ld	ra,8(sp)
ffffffffc0201f0a:	6402                	ld	s0,0(sp)
ffffffffc0201f0c:	0141                	addi	sp,sp,16
ffffffffc0201f0e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201f10:	00013717          	auipc	a4,0x13
ffffffffc0201f14:	58070713          	addi	a4,a4,1408 # ffffffffc0215490 <npage>
ffffffffc0201f18:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f1a:	078a                	slli	a5,a5,0x2
ffffffffc0201f1c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f1e:	02e7f563          	bleu	a4,a5,ffffffffc0201f48 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f22:	00013717          	auipc	a4,0x13
ffffffffc0201f26:	5de70713          	addi	a4,a4,1502 # ffffffffc0215500 <pages>
ffffffffc0201f2a:	6308                	ld	a0,0(a4)
ffffffffc0201f2c:	60a2                	ld	ra,8(sp)
ffffffffc0201f2e:	6402                	ld	s0,0(sp)
ffffffffc0201f30:	fff80737          	lui	a4,0xfff80
ffffffffc0201f34:	97ba                	add	a5,a5,a4
ffffffffc0201f36:	079a                	slli	a5,a5,0x6
ffffffffc0201f38:	953e                	add	a0,a0,a5
ffffffffc0201f3a:	0141                	addi	sp,sp,16
ffffffffc0201f3c:	8082                	ret
ffffffffc0201f3e:	60a2                	ld	ra,8(sp)
ffffffffc0201f40:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201f42:	4501                	li	a0,0
}
ffffffffc0201f44:	0141                	addi	sp,sp,16
ffffffffc0201f46:	8082                	ret
ffffffffc0201f48:	ca7ff0ef          	jal	ra,ffffffffc0201bee <pa2page.part.4>

ffffffffc0201f4c <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201f4c:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f4e:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201f50:	e426                	sd	s1,8(sp)
ffffffffc0201f52:	ec06                	sd	ra,24(sp)
ffffffffc0201f54:	e822                	sd	s0,16(sp)
ffffffffc0201f56:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f58:	dc1ff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
    if (ptep != NULL) {
ffffffffc0201f5c:	c511                	beqz	a0,ffffffffc0201f68 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201f5e:	611c                	ld	a5,0(a0)
ffffffffc0201f60:	842a                	mv	s0,a0
ffffffffc0201f62:	0017f713          	andi	a4,a5,1
ffffffffc0201f66:	e711                	bnez	a4,ffffffffc0201f72 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201f68:	60e2                	ld	ra,24(sp)
ffffffffc0201f6a:	6442                	ld	s0,16(sp)
ffffffffc0201f6c:	64a2                	ld	s1,8(sp)
ffffffffc0201f6e:	6105                	addi	sp,sp,32
ffffffffc0201f70:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201f72:	00013717          	auipc	a4,0x13
ffffffffc0201f76:	51e70713          	addi	a4,a4,1310 # ffffffffc0215490 <npage>
ffffffffc0201f7a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f7c:	078a                	slli	a5,a5,0x2
ffffffffc0201f7e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f80:	02e7fe63          	bleu	a4,a5,ffffffffc0201fbc <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f84:	00013717          	auipc	a4,0x13
ffffffffc0201f88:	57c70713          	addi	a4,a4,1404 # ffffffffc0215500 <pages>
ffffffffc0201f8c:	6308                	ld	a0,0(a4)
ffffffffc0201f8e:	fff80737          	lui	a4,0xfff80
ffffffffc0201f92:	97ba                	add	a5,a5,a4
ffffffffc0201f94:	079a                	slli	a5,a5,0x6
ffffffffc0201f96:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201f98:	411c                	lw	a5,0(a0)
ffffffffc0201f9a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201f9e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201fa0:	cb11                	beqz	a4,ffffffffc0201fb4 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201fa2:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fa6:	12048073          	sfence.vma	s1
}
ffffffffc0201faa:	60e2                	ld	ra,24(sp)
ffffffffc0201fac:	6442                	ld	s0,16(sp)
ffffffffc0201fae:	64a2                	ld	s1,8(sp)
ffffffffc0201fb0:	6105                	addi	sp,sp,32
ffffffffc0201fb2:	8082                	ret
            free_page(page);
ffffffffc0201fb4:	4585                	li	a1,1
ffffffffc0201fb6:	cddff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
ffffffffc0201fba:	b7e5                	j	ffffffffc0201fa2 <page_remove+0x56>
ffffffffc0201fbc:	c33ff0ef          	jal	ra,ffffffffc0201bee <pa2page.part.4>

ffffffffc0201fc0 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201fc0:	7179                	addi	sp,sp,-48
ffffffffc0201fc2:	e44e                	sd	s3,8(sp)
ffffffffc0201fc4:	89b2                	mv	s3,a2
ffffffffc0201fc6:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201fc8:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201fca:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201fcc:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201fce:	ec26                	sd	s1,24(sp)
ffffffffc0201fd0:	f406                	sd	ra,40(sp)
ffffffffc0201fd2:	e84a                	sd	s2,16(sp)
ffffffffc0201fd4:	e052                	sd	s4,0(sp)
ffffffffc0201fd6:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201fd8:	d41ff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
    if (ptep == NULL) {
ffffffffc0201fdc:	cd49                	beqz	a0,ffffffffc0202076 <page_insert+0xb6>
    page->ref += 1;
ffffffffc0201fde:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201fe0:	611c                	ld	a5,0(a0)
ffffffffc0201fe2:	892a                	mv	s2,a0
ffffffffc0201fe4:	0016871b          	addiw	a4,a3,1
ffffffffc0201fe8:	c018                	sw	a4,0(s0)
ffffffffc0201fea:	0017f713          	andi	a4,a5,1
ffffffffc0201fee:	ef05                	bnez	a4,ffffffffc0202026 <page_insert+0x66>
ffffffffc0201ff0:	00013797          	auipc	a5,0x13
ffffffffc0201ff4:	51078793          	addi	a5,a5,1296 # ffffffffc0215500 <pages>
ffffffffc0201ff8:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0201ffa:	8c19                	sub	s0,s0,a4
ffffffffc0201ffc:	000806b7          	lui	a3,0x80
ffffffffc0202000:	8419                	srai	s0,s0,0x6
ffffffffc0202002:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202004:	042a                	slli	s0,s0,0xa
ffffffffc0202006:	8c45                	or	s0,s0,s1
ffffffffc0202008:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020200c:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202010:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0202014:	4501                	li	a0,0
}
ffffffffc0202016:	70a2                	ld	ra,40(sp)
ffffffffc0202018:	7402                	ld	s0,32(sp)
ffffffffc020201a:	64e2                	ld	s1,24(sp)
ffffffffc020201c:	6942                	ld	s2,16(sp)
ffffffffc020201e:	69a2                	ld	s3,8(sp)
ffffffffc0202020:	6a02                	ld	s4,0(sp)
ffffffffc0202022:	6145                	addi	sp,sp,48
ffffffffc0202024:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202026:	00013717          	auipc	a4,0x13
ffffffffc020202a:	46a70713          	addi	a4,a4,1130 # ffffffffc0215490 <npage>
ffffffffc020202e:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202030:	078a                	slli	a5,a5,0x2
ffffffffc0202032:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202034:	04e7f363          	bleu	a4,a5,ffffffffc020207a <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202038:	00013a17          	auipc	s4,0x13
ffffffffc020203c:	4c8a0a13          	addi	s4,s4,1224 # ffffffffc0215500 <pages>
ffffffffc0202040:	000a3703          	ld	a4,0(s4)
ffffffffc0202044:	fff80537          	lui	a0,0xfff80
ffffffffc0202048:	953e                	add	a0,a0,a5
ffffffffc020204a:	051a                	slli	a0,a0,0x6
ffffffffc020204c:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc020204e:	00a40a63          	beq	s0,a0,ffffffffc0202062 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0202052:	411c                	lw	a5,0(a0)
ffffffffc0202054:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202058:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc020205a:	c691                	beqz	a3,ffffffffc0202066 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020205c:	12098073          	sfence.vma	s3
ffffffffc0202060:	bf69                	j	ffffffffc0201ffa <page_insert+0x3a>
ffffffffc0202062:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202064:	bf59                	j	ffffffffc0201ffa <page_insert+0x3a>
            free_page(page);
ffffffffc0202066:	4585                	li	a1,1
ffffffffc0202068:	c2bff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
ffffffffc020206c:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202070:	12098073          	sfence.vma	s3
ffffffffc0202074:	b759                	j	ffffffffc0201ffa <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202076:	5571                	li	a0,-4
ffffffffc0202078:	bf79                	j	ffffffffc0202016 <page_insert+0x56>
ffffffffc020207a:	b75ff0ef          	jal	ra,ffffffffc0201bee <pa2page.part.4>

ffffffffc020207e <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020207e:	00004797          	auipc	a5,0x4
ffffffffc0202082:	b6278793          	addi	a5,a5,-1182 # ffffffffc0205be0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202086:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202088:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020208a:	00004517          	auipc	a0,0x4
ffffffffc020208e:	cbe50513          	addi	a0,a0,-834 # ffffffffc0205d48 <default_pmm_manager+0x168>
void pmm_init(void) {
ffffffffc0202092:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202094:	00013717          	auipc	a4,0x13
ffffffffc0202098:	44f73a23          	sd	a5,1108(a4) # ffffffffc02154e8 <pmm_manager>
void pmm_init(void) {
ffffffffc020209c:	e0a2                	sd	s0,64(sp)
ffffffffc020209e:	fc26                	sd	s1,56(sp)
ffffffffc02020a0:	f84a                	sd	s2,48(sp)
ffffffffc02020a2:	f44e                	sd	s3,40(sp)
ffffffffc02020a4:	f052                	sd	s4,32(sp)
ffffffffc02020a6:	ec56                	sd	s5,24(sp)
ffffffffc02020a8:	e85a                	sd	s6,16(sp)
ffffffffc02020aa:	e45e                	sd	s7,8(sp)
ffffffffc02020ac:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02020ae:	00013417          	auipc	s0,0x13
ffffffffc02020b2:	43a40413          	addi	s0,s0,1082 # ffffffffc02154e8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02020b6:	8d8fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc02020ba:	601c                	ld	a5,0(s0)
ffffffffc02020bc:	00013497          	auipc	s1,0x13
ffffffffc02020c0:	3d448493          	addi	s1,s1,980 # ffffffffc0215490 <npage>
ffffffffc02020c4:	00013917          	auipc	s2,0x13
ffffffffc02020c8:	43c90913          	addi	s2,s2,1084 # ffffffffc0215500 <pages>
ffffffffc02020cc:	679c                	ld	a5,8(a5)
ffffffffc02020ce:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02020d0:	57f5                	li	a5,-3
ffffffffc02020d2:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02020d4:	00004517          	auipc	a0,0x4
ffffffffc02020d8:	c8c50513          	addi	a0,a0,-884 # ffffffffc0205d60 <default_pmm_manager+0x180>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02020dc:	00013717          	auipc	a4,0x13
ffffffffc02020e0:	40f73a23          	sd	a5,1044(a4) # ffffffffc02154f0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02020e4:	8aafe0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02020e8:	46c5                	li	a3,17
ffffffffc02020ea:	06ee                	slli	a3,a3,0x1b
ffffffffc02020ec:	40100613          	li	a2,1025
ffffffffc02020f0:	16fd                	addi	a3,a3,-1
ffffffffc02020f2:	0656                	slli	a2,a2,0x15
ffffffffc02020f4:	07e005b7          	lui	a1,0x7e00
ffffffffc02020f8:	00004517          	auipc	a0,0x4
ffffffffc02020fc:	c8050513          	addi	a0,a0,-896 # ffffffffc0205d78 <default_pmm_manager+0x198>
ffffffffc0202100:	88efe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202104:	777d                	lui	a4,0xfffff
ffffffffc0202106:	00014797          	auipc	a5,0x14
ffffffffc020210a:	4f178793          	addi	a5,a5,1265 # ffffffffc02165f7 <end+0xfff>
ffffffffc020210e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202110:	00088737          	lui	a4,0x88
ffffffffc0202114:	00013697          	auipc	a3,0x13
ffffffffc0202118:	36e6be23          	sd	a4,892(a3) # ffffffffc0215490 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020211c:	00013717          	auipc	a4,0x13
ffffffffc0202120:	3ef73223          	sd	a5,996(a4) # ffffffffc0215500 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202124:	4701                	li	a4,0
ffffffffc0202126:	4685                	li	a3,1
ffffffffc0202128:	fff80837          	lui	a6,0xfff80
ffffffffc020212c:	a019                	j	ffffffffc0202132 <pmm_init+0xb4>
ffffffffc020212e:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0202132:	00671613          	slli	a2,a4,0x6
ffffffffc0202136:	97b2                	add	a5,a5,a2
ffffffffc0202138:	07a1                	addi	a5,a5,8
ffffffffc020213a:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020213e:	6090                	ld	a2,0(s1)
ffffffffc0202140:	0705                	addi	a4,a4,1
ffffffffc0202142:	010607b3          	add	a5,a2,a6
ffffffffc0202146:	fef764e3          	bltu	a4,a5,ffffffffc020212e <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020214a:	00093503          	ld	a0,0(s2)
ffffffffc020214e:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202152:	00661693          	slli	a3,a2,0x6
ffffffffc0202156:	97aa                	add	a5,a5,a0
ffffffffc0202158:	96be                	add	a3,a3,a5
ffffffffc020215a:	c02007b7          	lui	a5,0xc0200
ffffffffc020215e:	7af6ed63          	bltu	a3,a5,ffffffffc0202918 <pmm_init+0x89a>
ffffffffc0202162:	00013997          	auipc	s3,0x13
ffffffffc0202166:	38e98993          	addi	s3,s3,910 # ffffffffc02154f0 <va_pa_offset>
ffffffffc020216a:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc020216e:	47c5                	li	a5,17
ffffffffc0202170:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202172:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202174:	02f6f763          	bleu	a5,a3,ffffffffc02021a2 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202178:	6585                	lui	a1,0x1
ffffffffc020217a:	15fd                	addi	a1,a1,-1
ffffffffc020217c:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc020217e:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202182:	48c77a63          	bleu	a2,a4,ffffffffc0202616 <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0202186:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202188:	75fd                	lui	a1,0xfffff
ffffffffc020218a:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc020218c:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc020218e:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202190:	40d786b3          	sub	a3,a5,a3
ffffffffc0202194:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202196:	00c6d593          	srli	a1,a3,0xc
ffffffffc020219a:	953a                	add	a0,a0,a4
ffffffffc020219c:	9602                	jalr	a2
ffffffffc020219e:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02021a2:	00004517          	auipc	a0,0x4
ffffffffc02021a6:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0205da0 <default_pmm_manager+0x1c0>
ffffffffc02021aa:	fe5fd0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02021ae:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02021b0:	00013417          	auipc	s0,0x13
ffffffffc02021b4:	2d840413          	addi	s0,s0,728 # ffffffffc0215488 <boot_pgdir>
    pmm_manager->check();
ffffffffc02021b8:	7b9c                	ld	a5,48(a5)
ffffffffc02021ba:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02021bc:	00004517          	auipc	a0,0x4
ffffffffc02021c0:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0205db8 <default_pmm_manager+0x1d8>
ffffffffc02021c4:	fcbfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02021c8:	00007697          	auipc	a3,0x7
ffffffffc02021cc:	e3868693          	addi	a3,a3,-456 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc02021d0:	00013797          	auipc	a5,0x13
ffffffffc02021d4:	2ad7bc23          	sd	a3,696(a5) # ffffffffc0215488 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02021d8:	c02007b7          	lui	a5,0xc0200
ffffffffc02021dc:	10f6eae3          	bltu	a3,a5,ffffffffc0202af0 <pmm_init+0xa72>
ffffffffc02021e0:	0009b783          	ld	a5,0(s3)
ffffffffc02021e4:	8e9d                	sub	a3,a3,a5
ffffffffc02021e6:	00013797          	auipc	a5,0x13
ffffffffc02021ea:	30d7b923          	sd	a3,786(a5) # ffffffffc02154f8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc02021ee:	aebff0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02021f2:	6098                	ld	a4,0(s1)
ffffffffc02021f4:	c80007b7          	lui	a5,0xc8000
ffffffffc02021f8:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02021fa:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02021fc:	0ce7eae3          	bltu	a5,a4,ffffffffc0202ad0 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202200:	6008                	ld	a0,0(s0)
ffffffffc0202202:	44050463          	beqz	a0,ffffffffc020264a <pmm_init+0x5cc>
ffffffffc0202206:	6785                	lui	a5,0x1
ffffffffc0202208:	17fd                	addi	a5,a5,-1
ffffffffc020220a:	8fe9                	and	a5,a5,a0
ffffffffc020220c:	2781                	sext.w	a5,a5
ffffffffc020220e:	42079e63          	bnez	a5,ffffffffc020264a <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202212:	4601                	li	a2,0
ffffffffc0202214:	4581                	li	a1,0
ffffffffc0202216:	cd5ff0ef          	jal	ra,ffffffffc0201eea <get_page>
ffffffffc020221a:	78051b63          	bnez	a0,ffffffffc02029b0 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc020221e:	4505                	li	a0,1
ffffffffc0202220:	9ebff0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0202224:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202226:	6008                	ld	a0,0(s0)
ffffffffc0202228:	4681                	li	a3,0
ffffffffc020222a:	4601                	li	a2,0
ffffffffc020222c:	85d6                	mv	a1,s5
ffffffffc020222e:	d93ff0ef          	jal	ra,ffffffffc0201fc0 <page_insert>
ffffffffc0202232:	7a051f63          	bnez	a0,ffffffffc02029f0 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202236:	6008                	ld	a0,0(s0)
ffffffffc0202238:	4601                	li	a2,0
ffffffffc020223a:	4581                	li	a1,0
ffffffffc020223c:	addff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc0202240:	78050863          	beqz	a0,ffffffffc02029d0 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc0202244:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202246:	0017f713          	andi	a4,a5,1
ffffffffc020224a:	3e070463          	beqz	a4,ffffffffc0202632 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc020224e:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202250:	078a                	slli	a5,a5,0x2
ffffffffc0202252:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202254:	3ce7f163          	bleu	a4,a5,ffffffffc0202616 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202258:	00093683          	ld	a3,0(s2)
ffffffffc020225c:	fff80637          	lui	a2,0xfff80
ffffffffc0202260:	97b2                	add	a5,a5,a2
ffffffffc0202262:	079a                	slli	a5,a5,0x6
ffffffffc0202264:	97b6                	add	a5,a5,a3
ffffffffc0202266:	72fa9563          	bne	s5,a5,ffffffffc0202990 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc020226a:	000aab83          	lw	s7,0(s5)
ffffffffc020226e:	4785                	li	a5,1
ffffffffc0202270:	70fb9063          	bne	s7,a5,ffffffffc0202970 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202274:	6008                	ld	a0,0(s0)
ffffffffc0202276:	76fd                	lui	a3,0xfffff
ffffffffc0202278:	611c                	ld	a5,0(a0)
ffffffffc020227a:	078a                	slli	a5,a5,0x2
ffffffffc020227c:	8ff5                	and	a5,a5,a3
ffffffffc020227e:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202282:	66e67e63          	bleu	a4,a2,ffffffffc02028fe <pmm_init+0x880>
ffffffffc0202286:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020228a:	97e2                	add	a5,a5,s8
ffffffffc020228c:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0202290:	0b0a                	slli	s6,s6,0x2
ffffffffc0202292:	00db7b33          	and	s6,s6,a3
ffffffffc0202296:	00cb5793          	srli	a5,s6,0xc
ffffffffc020229a:	56e7f863          	bleu	a4,a5,ffffffffc020280a <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020229e:	4601                	li	a2,0
ffffffffc02022a0:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022a2:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02022a4:	a75ff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022a8:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02022aa:	55651063          	bne	a0,s6,ffffffffc02027ea <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc02022ae:	4505                	li	a0,1
ffffffffc02022b0:	95bff0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc02022b4:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02022b6:	6008                	ld	a0,0(s0)
ffffffffc02022b8:	46d1                	li	a3,20
ffffffffc02022ba:	6605                	lui	a2,0x1
ffffffffc02022bc:	85da                	mv	a1,s6
ffffffffc02022be:	d03ff0ef          	jal	ra,ffffffffc0201fc0 <page_insert>
ffffffffc02022c2:	50051463          	bnez	a0,ffffffffc02027ca <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02022c6:	6008                	ld	a0,0(s0)
ffffffffc02022c8:	4601                	li	a2,0
ffffffffc02022ca:	6585                	lui	a1,0x1
ffffffffc02022cc:	a4dff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc02022d0:	4c050d63          	beqz	a0,ffffffffc02027aa <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc02022d4:	611c                	ld	a5,0(a0)
ffffffffc02022d6:	0107f713          	andi	a4,a5,16
ffffffffc02022da:	4a070863          	beqz	a4,ffffffffc020278a <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc02022de:	8b91                	andi	a5,a5,4
ffffffffc02022e0:	48078563          	beqz	a5,ffffffffc020276a <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02022e4:	6008                	ld	a0,0(s0)
ffffffffc02022e6:	611c                	ld	a5,0(a0)
ffffffffc02022e8:	8bc1                	andi	a5,a5,16
ffffffffc02022ea:	46078063          	beqz	a5,ffffffffc020274a <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc02022ee:	000b2783          	lw	a5,0(s6)
ffffffffc02022f2:	43779c63          	bne	a5,s7,ffffffffc020272a <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02022f6:	4681                	li	a3,0
ffffffffc02022f8:	6605                	lui	a2,0x1
ffffffffc02022fa:	85d6                	mv	a1,s5
ffffffffc02022fc:	cc5ff0ef          	jal	ra,ffffffffc0201fc0 <page_insert>
ffffffffc0202300:	40051563          	bnez	a0,ffffffffc020270a <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc0202304:	000aa703          	lw	a4,0(s5)
ffffffffc0202308:	4789                	li	a5,2
ffffffffc020230a:	3ef71063          	bne	a4,a5,ffffffffc02026ea <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc020230e:	000b2783          	lw	a5,0(s6)
ffffffffc0202312:	3a079c63          	bnez	a5,ffffffffc02026ca <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202316:	6008                	ld	a0,0(s0)
ffffffffc0202318:	4601                	li	a2,0
ffffffffc020231a:	6585                	lui	a1,0x1
ffffffffc020231c:	9fdff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc0202320:	38050563          	beqz	a0,ffffffffc02026aa <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc0202324:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202326:	00177793          	andi	a5,a4,1
ffffffffc020232a:	30078463          	beqz	a5,ffffffffc0202632 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc020232e:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202330:	00271793          	slli	a5,a4,0x2
ffffffffc0202334:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202336:	2ed7f063          	bleu	a3,a5,ffffffffc0202616 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020233a:	00093683          	ld	a3,0(s2)
ffffffffc020233e:	fff80637          	lui	a2,0xfff80
ffffffffc0202342:	97b2                	add	a5,a5,a2
ffffffffc0202344:	079a                	slli	a5,a5,0x6
ffffffffc0202346:	97b6                	add	a5,a5,a3
ffffffffc0202348:	32fa9163          	bne	s5,a5,ffffffffc020266a <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc020234c:	8b41                	andi	a4,a4,16
ffffffffc020234e:	70071163          	bnez	a4,ffffffffc0202a50 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202352:	6008                	ld	a0,0(s0)
ffffffffc0202354:	4581                	li	a1,0
ffffffffc0202356:	bf7ff0ef          	jal	ra,ffffffffc0201f4c <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020235a:	000aa703          	lw	a4,0(s5)
ffffffffc020235e:	4785                	li	a5,1
ffffffffc0202360:	6cf71863          	bne	a4,a5,ffffffffc0202a30 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc0202364:	000b2783          	lw	a5,0(s6)
ffffffffc0202368:	6a079463          	bnez	a5,ffffffffc0202a10 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020236c:	6008                	ld	a0,0(s0)
ffffffffc020236e:	6585                	lui	a1,0x1
ffffffffc0202370:	bddff0ef          	jal	ra,ffffffffc0201f4c <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202374:	000aa783          	lw	a5,0(s5)
ffffffffc0202378:	50079363          	bnez	a5,ffffffffc020287e <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc020237c:	000b2783          	lw	a5,0(s6)
ffffffffc0202380:	4c079f63          	bnez	a5,ffffffffc020285e <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202384:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202388:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020238a:	000ab783          	ld	a5,0(s5)
ffffffffc020238e:	078a                	slli	a5,a5,0x2
ffffffffc0202390:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202392:	28c7f263          	bleu	a2,a5,ffffffffc0202616 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202396:	fff80737          	lui	a4,0xfff80
ffffffffc020239a:	00093503          	ld	a0,0(s2)
ffffffffc020239e:	97ba                	add	a5,a5,a4
ffffffffc02023a0:	079a                	slli	a5,a5,0x6
ffffffffc02023a2:	00f50733          	add	a4,a0,a5
ffffffffc02023a6:	4314                	lw	a3,0(a4)
ffffffffc02023a8:	4705                	li	a4,1
ffffffffc02023aa:	48e69a63          	bne	a3,a4,ffffffffc020283e <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc02023ae:	8799                	srai	a5,a5,0x6
ffffffffc02023b0:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc02023b4:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc02023b6:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02023b8:	8331                	srli	a4,a4,0xc
ffffffffc02023ba:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02023bc:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02023be:	46c77363          	bleu	a2,a4,ffffffffc0202824 <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02023c2:	0009b683          	ld	a3,0(s3)
ffffffffc02023c6:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc02023c8:	639c                	ld	a5,0(a5)
ffffffffc02023ca:	078a                	slli	a5,a5,0x2
ffffffffc02023cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023ce:	24c7f463          	bleu	a2,a5,ffffffffc0202616 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02023d2:	416787b3          	sub	a5,a5,s6
ffffffffc02023d6:	079a                	slli	a5,a5,0x6
ffffffffc02023d8:	953e                	add	a0,a0,a5
ffffffffc02023da:	4585                	li	a1,1
ffffffffc02023dc:	8b7ff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02023e0:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc02023e4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023e6:	078a                	slli	a5,a5,0x2
ffffffffc02023e8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023ea:	22e7f663          	bleu	a4,a5,ffffffffc0202616 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ee:	00093503          	ld	a0,0(s2)
ffffffffc02023f2:	416787b3          	sub	a5,a5,s6
ffffffffc02023f6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02023f8:	953e                	add	a0,a0,a5
ffffffffc02023fa:	4585                	li	a1,1
ffffffffc02023fc:	897ff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202400:	601c                	ld	a5,0(s0)
ffffffffc0202402:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202406:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020240a:	8cfff0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>
ffffffffc020240e:	68aa1163          	bne	s4,a0,ffffffffc0202a90 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202412:	00004517          	auipc	a0,0x4
ffffffffc0202416:	cb650513          	addi	a0,a0,-842 # ffffffffc02060c8 <default_pmm_manager+0x4e8>
ffffffffc020241a:	d75fd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc020241e:	8bbff0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202422:	6098                	ld	a4,0(s1)
ffffffffc0202424:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0202428:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020242a:	00c71693          	slli	a3,a4,0xc
ffffffffc020242e:	18d7f563          	bleu	a3,a5,ffffffffc02025b8 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202432:	83b1                	srli	a5,a5,0xc
ffffffffc0202434:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202436:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020243a:	1ae7f163          	bleu	a4,a5,ffffffffc02025dc <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020243e:	7bfd                	lui	s7,0xfffff
ffffffffc0202440:	6b05                	lui	s6,0x1
ffffffffc0202442:	a029                	j	ffffffffc020244c <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202444:	00cad713          	srli	a4,s5,0xc
ffffffffc0202448:	18f77a63          	bleu	a5,a4,ffffffffc02025dc <pmm_init+0x55e>
ffffffffc020244c:	0009b583          	ld	a1,0(s3)
ffffffffc0202450:	4601                	li	a2,0
ffffffffc0202452:	95d6                	add	a1,a1,s5
ffffffffc0202454:	8c5ff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc0202458:	16050263          	beqz	a0,ffffffffc02025bc <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020245c:	611c                	ld	a5,0(a0)
ffffffffc020245e:	078a                	slli	a5,a5,0x2
ffffffffc0202460:	0177f7b3          	and	a5,a5,s7
ffffffffc0202464:	19579963          	bne	a5,s5,ffffffffc02025f6 <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202468:	609c                	ld	a5,0(s1)
ffffffffc020246a:	9ada                	add	s5,s5,s6
ffffffffc020246c:	6008                	ld	a0,0(s0)
ffffffffc020246e:	00c79713          	slli	a4,a5,0xc
ffffffffc0202472:	fceae9e3          	bltu	s5,a4,ffffffffc0202444 <pmm_init+0x3c6>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc0202476:	611c                	ld	a5,0(a0)
ffffffffc0202478:	62079c63          	bnez	a5,ffffffffc0202ab0 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc020247c:	4505                	li	a0,1
ffffffffc020247e:	f8cff0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0202482:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202484:	6008                	ld	a0,0(s0)
ffffffffc0202486:	4699                	li	a3,6
ffffffffc0202488:	10000613          	li	a2,256
ffffffffc020248c:	85d6                	mv	a1,s5
ffffffffc020248e:	b33ff0ef          	jal	ra,ffffffffc0201fc0 <page_insert>
ffffffffc0202492:	1e051c63          	bnez	a0,ffffffffc020268a <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202496:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc020249a:	4785                	li	a5,1
ffffffffc020249c:	44f71163          	bne	a4,a5,ffffffffc02028de <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02024a0:	6008                	ld	a0,0(s0)
ffffffffc02024a2:	6b05                	lui	s6,0x1
ffffffffc02024a4:	4699                	li	a3,6
ffffffffc02024a6:	100b0613          	addi	a2,s6,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc02024aa:	85d6                	mv	a1,s5
ffffffffc02024ac:	b15ff0ef          	jal	ra,ffffffffc0201fc0 <page_insert>
ffffffffc02024b0:	40051763          	bnez	a0,ffffffffc02028be <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc02024b4:	000aa703          	lw	a4,0(s5)
ffffffffc02024b8:	4789                	li	a5,2
ffffffffc02024ba:	3ef71263          	bne	a4,a5,ffffffffc020289e <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02024be:	00004597          	auipc	a1,0x4
ffffffffc02024c2:	d4258593          	addi	a1,a1,-702 # ffffffffc0206200 <default_pmm_manager+0x620>
ffffffffc02024c6:	10000513          	li	a0,256
ffffffffc02024ca:	0c3020ef          	jal	ra,ffffffffc0204d8c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02024ce:	100b0593          	addi	a1,s6,256
ffffffffc02024d2:	10000513          	li	a0,256
ffffffffc02024d6:	0c9020ef          	jal	ra,ffffffffc0204d9e <strcmp>
ffffffffc02024da:	44051b63          	bnez	a0,ffffffffc0202930 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc02024de:	00093683          	ld	a3,0(s2)
ffffffffc02024e2:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02024e6:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc02024e8:	40da86b3          	sub	a3,s5,a3
ffffffffc02024ec:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02024ee:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02024f0:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02024f2:	00cb5b13          	srli	s6,s6,0xc
ffffffffc02024f6:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024fa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02024fc:	10f77f63          	bleu	a5,a4,ffffffffc020261a <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202500:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202504:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202508:	96be                	add	a3,a3,a5
ffffffffc020250a:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fde9b08>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020250e:	03b020ef          	jal	ra,ffffffffc0204d48 <strlen>
ffffffffc0202512:	54051f63          	bnez	a0,ffffffffc0202a70 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202516:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020251a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020251c:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde9a08>
ffffffffc0202520:	068a                	slli	a3,a3,0x2
ffffffffc0202522:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202524:	0ef6f963          	bleu	a5,a3,ffffffffc0202616 <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202528:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc020252c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020252e:	0efb7663          	bleu	a5,s6,ffffffffc020261a <pmm_init+0x59c>
ffffffffc0202532:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202536:	4585                	li	a1,1
ffffffffc0202538:	8556                	mv	a0,s5
ffffffffc020253a:	99b6                	add	s3,s3,a3
ffffffffc020253c:	f56ff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202540:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202544:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202546:	078a                	slli	a5,a5,0x2
ffffffffc0202548:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020254a:	0ce7f663          	bleu	a4,a5,ffffffffc0202616 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020254e:	00093503          	ld	a0,0(s2)
ffffffffc0202552:	fff809b7          	lui	s3,0xfff80
ffffffffc0202556:	97ce                	add	a5,a5,s3
ffffffffc0202558:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc020255a:	953e                	add	a0,a0,a5
ffffffffc020255c:	4585                	li	a1,1
ffffffffc020255e:	f34ff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202562:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202566:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202568:	078a                	slli	a5,a5,0x2
ffffffffc020256a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020256c:	0ae7f563          	bleu	a4,a5,ffffffffc0202616 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202570:	00093503          	ld	a0,0(s2)
ffffffffc0202574:	97ce                	add	a5,a5,s3
ffffffffc0202576:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202578:	953e                	add	a0,a0,a5
ffffffffc020257a:	4585                	li	a1,1
ffffffffc020257c:	f16ff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202580:	601c                	ld	a5,0(s0)
ffffffffc0202582:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202586:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020258a:	f4eff0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>
ffffffffc020258e:	3caa1163          	bne	s4,a0,ffffffffc0202950 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202592:	00004517          	auipc	a0,0x4
ffffffffc0202596:	ce650513          	addi	a0,a0,-794 # ffffffffc0206278 <default_pmm_manager+0x698>
ffffffffc020259a:	bf5fd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc020259e:	6406                	ld	s0,64(sp)
ffffffffc02025a0:	60a6                	ld	ra,72(sp)
ffffffffc02025a2:	74e2                	ld	s1,56(sp)
ffffffffc02025a4:	7942                	ld	s2,48(sp)
ffffffffc02025a6:	79a2                	ld	s3,40(sp)
ffffffffc02025a8:	7a02                	ld	s4,32(sp)
ffffffffc02025aa:	6ae2                	ld	s5,24(sp)
ffffffffc02025ac:	6b42                	ld	s6,16(sp)
ffffffffc02025ae:	6ba2                	ld	s7,8(sp)
ffffffffc02025b0:	6c02                	ld	s8,0(sp)
ffffffffc02025b2:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc02025b4:	c3aff06f          	j	ffffffffc02019ee <kmalloc_init>
ffffffffc02025b8:	6008                	ld	a0,0(s0)
ffffffffc02025ba:	bd75                	j	ffffffffc0202476 <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02025bc:	00004697          	auipc	a3,0x4
ffffffffc02025c0:	b2c68693          	addi	a3,a3,-1236 # ffffffffc02060e8 <default_pmm_manager+0x508>
ffffffffc02025c4:	00003617          	auipc	a2,0x3
ffffffffc02025c8:	28460613          	addi	a2,a2,644 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02025cc:	19d00593          	li	a1,413
ffffffffc02025d0:	00003517          	auipc	a0,0x3
ffffffffc02025d4:	75050513          	addi	a0,a0,1872 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02025d8:	e79fd0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc02025dc:	86d6                	mv	a3,s5
ffffffffc02025de:	00003617          	auipc	a2,0x3
ffffffffc02025e2:	65260613          	addi	a2,a2,1618 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc02025e6:	19d00593          	li	a1,413
ffffffffc02025ea:	00003517          	auipc	a0,0x3
ffffffffc02025ee:	73650513          	addi	a0,a0,1846 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02025f2:	e5ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02025f6:	00004697          	auipc	a3,0x4
ffffffffc02025fa:	b3268693          	addi	a3,a3,-1230 # ffffffffc0206128 <default_pmm_manager+0x548>
ffffffffc02025fe:	00003617          	auipc	a2,0x3
ffffffffc0202602:	24a60613          	addi	a2,a2,586 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202606:	19e00593          	li	a1,414
ffffffffc020260a:	00003517          	auipc	a0,0x3
ffffffffc020260e:	71650513          	addi	a0,a0,1814 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202612:	e3ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0202616:	dd8ff0ef          	jal	ra,ffffffffc0201bee <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc020261a:	00003617          	auipc	a2,0x3
ffffffffc020261e:	61660613          	addi	a2,a2,1558 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc0202622:	06900593          	li	a1,105
ffffffffc0202626:	00003517          	auipc	a0,0x3
ffffffffc020262a:	63250513          	addi	a0,a0,1586 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc020262e:	e23fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202632:	00004617          	auipc	a2,0x4
ffffffffc0202636:	88660613          	addi	a2,a2,-1914 # ffffffffc0205eb8 <default_pmm_manager+0x2d8>
ffffffffc020263a:	07400593          	li	a1,116
ffffffffc020263e:	00003517          	auipc	a0,0x3
ffffffffc0202642:	61a50513          	addi	a0,a0,1562 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc0202646:	e0bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020264a:	00003697          	auipc	a3,0x3
ffffffffc020264e:	7ae68693          	addi	a3,a3,1966 # ffffffffc0205df8 <default_pmm_manager+0x218>
ffffffffc0202652:	00003617          	auipc	a2,0x3
ffffffffc0202656:	1f660613          	addi	a2,a2,502 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020265a:	16100593          	li	a1,353
ffffffffc020265e:	00003517          	auipc	a0,0x3
ffffffffc0202662:	6c250513          	addi	a0,a0,1730 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202666:	debfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020266a:	00004697          	auipc	a3,0x4
ffffffffc020266e:	87668693          	addi	a3,a3,-1930 # ffffffffc0205ee0 <default_pmm_manager+0x300>
ffffffffc0202672:	00003617          	auipc	a2,0x3
ffffffffc0202676:	1d660613          	addi	a2,a2,470 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020267a:	17d00593          	li	a1,381
ffffffffc020267e:	00003517          	auipc	a0,0x3
ffffffffc0202682:	6a250513          	addi	a0,a0,1698 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202686:	dcbfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020268a:	00004697          	auipc	a3,0x4
ffffffffc020268e:	ace68693          	addi	a3,a3,-1330 # ffffffffc0206158 <default_pmm_manager+0x578>
ffffffffc0202692:	00003617          	auipc	a2,0x3
ffffffffc0202696:	1b660613          	addi	a2,a2,438 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020269a:	1a500593          	li	a1,421
ffffffffc020269e:	00003517          	auipc	a0,0x3
ffffffffc02026a2:	68250513          	addi	a0,a0,1666 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02026a6:	dabfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02026aa:	00004697          	auipc	a3,0x4
ffffffffc02026ae:	8c668693          	addi	a3,a3,-1850 # ffffffffc0205f70 <default_pmm_manager+0x390>
ffffffffc02026b2:	00003617          	auipc	a2,0x3
ffffffffc02026b6:	19660613          	addi	a2,a2,406 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02026ba:	17c00593          	li	a1,380
ffffffffc02026be:	00003517          	auipc	a0,0x3
ffffffffc02026c2:	66250513          	addi	a0,a0,1634 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02026c6:	d8bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02026ca:	00004697          	auipc	a3,0x4
ffffffffc02026ce:	96e68693          	addi	a3,a3,-1682 # ffffffffc0206038 <default_pmm_manager+0x458>
ffffffffc02026d2:	00003617          	auipc	a2,0x3
ffffffffc02026d6:	17660613          	addi	a2,a2,374 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02026da:	17b00593          	li	a1,379
ffffffffc02026de:	00003517          	auipc	a0,0x3
ffffffffc02026e2:	64250513          	addi	a0,a0,1602 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02026e6:	d6bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02026ea:	00004697          	auipc	a3,0x4
ffffffffc02026ee:	93668693          	addi	a3,a3,-1738 # ffffffffc0206020 <default_pmm_manager+0x440>
ffffffffc02026f2:	00003617          	auipc	a2,0x3
ffffffffc02026f6:	15660613          	addi	a2,a2,342 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02026fa:	17a00593          	li	a1,378
ffffffffc02026fe:	00003517          	auipc	a0,0x3
ffffffffc0202702:	62250513          	addi	a0,a0,1570 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202706:	d4bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020270a:	00004697          	auipc	a3,0x4
ffffffffc020270e:	8e668693          	addi	a3,a3,-1818 # ffffffffc0205ff0 <default_pmm_manager+0x410>
ffffffffc0202712:	00003617          	auipc	a2,0x3
ffffffffc0202716:	13660613          	addi	a2,a2,310 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020271a:	17900593          	li	a1,377
ffffffffc020271e:	00003517          	auipc	a0,0x3
ffffffffc0202722:	60250513          	addi	a0,a0,1538 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202726:	d2bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020272a:	00004697          	auipc	a3,0x4
ffffffffc020272e:	8ae68693          	addi	a3,a3,-1874 # ffffffffc0205fd8 <default_pmm_manager+0x3f8>
ffffffffc0202732:	00003617          	auipc	a2,0x3
ffffffffc0202736:	11660613          	addi	a2,a2,278 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020273a:	17700593          	li	a1,375
ffffffffc020273e:	00003517          	auipc	a0,0x3
ffffffffc0202742:	5e250513          	addi	a0,a0,1506 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202746:	d0bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020274a:	00004697          	auipc	a3,0x4
ffffffffc020274e:	87668693          	addi	a3,a3,-1930 # ffffffffc0205fc0 <default_pmm_manager+0x3e0>
ffffffffc0202752:	00003617          	auipc	a2,0x3
ffffffffc0202756:	0f660613          	addi	a2,a2,246 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020275a:	17600593          	li	a1,374
ffffffffc020275e:	00003517          	auipc	a0,0x3
ffffffffc0202762:	5c250513          	addi	a0,a0,1474 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202766:	cebfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020276a:	00004697          	auipc	a3,0x4
ffffffffc020276e:	84668693          	addi	a3,a3,-1978 # ffffffffc0205fb0 <default_pmm_manager+0x3d0>
ffffffffc0202772:	00003617          	auipc	a2,0x3
ffffffffc0202776:	0d660613          	addi	a2,a2,214 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020277a:	17500593          	li	a1,373
ffffffffc020277e:	00003517          	auipc	a0,0x3
ffffffffc0202782:	5a250513          	addi	a0,a0,1442 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202786:	ccbfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020278a:	00004697          	auipc	a3,0x4
ffffffffc020278e:	81668693          	addi	a3,a3,-2026 # ffffffffc0205fa0 <default_pmm_manager+0x3c0>
ffffffffc0202792:	00003617          	auipc	a2,0x3
ffffffffc0202796:	0b660613          	addi	a2,a2,182 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020279a:	17400593          	li	a1,372
ffffffffc020279e:	00003517          	auipc	a0,0x3
ffffffffc02027a2:	58250513          	addi	a0,a0,1410 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02027a6:	cabfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02027aa:	00003697          	auipc	a3,0x3
ffffffffc02027ae:	7c668693          	addi	a3,a3,1990 # ffffffffc0205f70 <default_pmm_manager+0x390>
ffffffffc02027b2:	00003617          	auipc	a2,0x3
ffffffffc02027b6:	09660613          	addi	a2,a2,150 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02027ba:	17300593          	li	a1,371
ffffffffc02027be:	00003517          	auipc	a0,0x3
ffffffffc02027c2:	56250513          	addi	a0,a0,1378 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02027c6:	c8bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02027ca:	00003697          	auipc	a3,0x3
ffffffffc02027ce:	76e68693          	addi	a3,a3,1902 # ffffffffc0205f38 <default_pmm_manager+0x358>
ffffffffc02027d2:	00003617          	auipc	a2,0x3
ffffffffc02027d6:	07660613          	addi	a2,a2,118 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02027da:	17200593          	li	a1,370
ffffffffc02027de:	00003517          	auipc	a0,0x3
ffffffffc02027e2:	54250513          	addi	a0,a0,1346 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02027e6:	c6bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02027ea:	00003697          	auipc	a3,0x3
ffffffffc02027ee:	72668693          	addi	a3,a3,1830 # ffffffffc0205f10 <default_pmm_manager+0x330>
ffffffffc02027f2:	00003617          	auipc	a2,0x3
ffffffffc02027f6:	05660613          	addi	a2,a2,86 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02027fa:	16f00593          	li	a1,367
ffffffffc02027fe:	00003517          	auipc	a0,0x3
ffffffffc0202802:	52250513          	addi	a0,a0,1314 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202806:	c4bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020280a:	86da                	mv	a3,s6
ffffffffc020280c:	00003617          	auipc	a2,0x3
ffffffffc0202810:	42460613          	addi	a2,a2,1060 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc0202814:	16e00593          	li	a1,366
ffffffffc0202818:	00003517          	auipc	a0,0x3
ffffffffc020281c:	50850513          	addi	a0,a0,1288 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202820:	c31fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202824:	86be                	mv	a3,a5
ffffffffc0202826:	00003617          	auipc	a2,0x3
ffffffffc020282a:	40a60613          	addi	a2,a2,1034 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc020282e:	06900593          	li	a1,105
ffffffffc0202832:	00003517          	auipc	a0,0x3
ffffffffc0202836:	42650513          	addi	a0,a0,1062 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc020283a:	c17fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020283e:	00004697          	auipc	a3,0x4
ffffffffc0202842:	84268693          	addi	a3,a3,-1982 # ffffffffc0206080 <default_pmm_manager+0x4a0>
ffffffffc0202846:	00003617          	auipc	a2,0x3
ffffffffc020284a:	00260613          	addi	a2,a2,2 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020284e:	18800593          	li	a1,392
ffffffffc0202852:	00003517          	auipc	a0,0x3
ffffffffc0202856:	4ce50513          	addi	a0,a0,1230 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc020285a:	bf7fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020285e:	00003697          	auipc	a3,0x3
ffffffffc0202862:	7da68693          	addi	a3,a3,2010 # ffffffffc0206038 <default_pmm_manager+0x458>
ffffffffc0202866:	00003617          	auipc	a2,0x3
ffffffffc020286a:	fe260613          	addi	a2,a2,-30 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020286e:	18600593          	li	a1,390
ffffffffc0202872:	00003517          	auipc	a0,0x3
ffffffffc0202876:	4ae50513          	addi	a0,a0,1198 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc020287a:	bd7fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020287e:	00003697          	auipc	a3,0x3
ffffffffc0202882:	7ea68693          	addi	a3,a3,2026 # ffffffffc0206068 <default_pmm_manager+0x488>
ffffffffc0202886:	00003617          	auipc	a2,0x3
ffffffffc020288a:	fc260613          	addi	a2,a2,-62 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020288e:	18500593          	li	a1,389
ffffffffc0202892:	00003517          	auipc	a0,0x3
ffffffffc0202896:	48e50513          	addi	a0,a0,1166 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc020289a:	bb7fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020289e:	00004697          	auipc	a3,0x4
ffffffffc02028a2:	94a68693          	addi	a3,a3,-1718 # ffffffffc02061e8 <default_pmm_manager+0x608>
ffffffffc02028a6:	00003617          	auipc	a2,0x3
ffffffffc02028aa:	fa260613          	addi	a2,a2,-94 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02028ae:	1a800593          	li	a1,424
ffffffffc02028b2:	00003517          	auipc	a0,0x3
ffffffffc02028b6:	46e50513          	addi	a0,a0,1134 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02028ba:	b97fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02028be:	00004697          	auipc	a3,0x4
ffffffffc02028c2:	8ea68693          	addi	a3,a3,-1814 # ffffffffc02061a8 <default_pmm_manager+0x5c8>
ffffffffc02028c6:	00003617          	auipc	a2,0x3
ffffffffc02028ca:	f8260613          	addi	a2,a2,-126 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02028ce:	1a700593          	li	a1,423
ffffffffc02028d2:	00003517          	auipc	a0,0x3
ffffffffc02028d6:	44e50513          	addi	a0,a0,1102 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02028da:	b77fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02028de:	00004697          	auipc	a3,0x4
ffffffffc02028e2:	8b268693          	addi	a3,a3,-1870 # ffffffffc0206190 <default_pmm_manager+0x5b0>
ffffffffc02028e6:	00003617          	auipc	a2,0x3
ffffffffc02028ea:	f6260613          	addi	a2,a2,-158 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02028ee:	1a600593          	li	a1,422
ffffffffc02028f2:	00003517          	auipc	a0,0x3
ffffffffc02028f6:	42e50513          	addi	a0,a0,1070 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02028fa:	b57fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02028fe:	86be                	mv	a3,a5
ffffffffc0202900:	00003617          	auipc	a2,0x3
ffffffffc0202904:	33060613          	addi	a2,a2,816 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc0202908:	16d00593          	li	a1,365
ffffffffc020290c:	00003517          	auipc	a0,0x3
ffffffffc0202910:	41450513          	addi	a0,a0,1044 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202914:	b3dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202918:	00003617          	auipc	a2,0x3
ffffffffc020291c:	35060613          	addi	a2,a2,848 # ffffffffc0205c68 <default_pmm_manager+0x88>
ffffffffc0202920:	07f00593          	li	a1,127
ffffffffc0202924:	00003517          	auipc	a0,0x3
ffffffffc0202928:	3fc50513          	addi	a0,a0,1020 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc020292c:	b25fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202930:	00004697          	auipc	a3,0x4
ffffffffc0202934:	8e868693          	addi	a3,a3,-1816 # ffffffffc0206218 <default_pmm_manager+0x638>
ffffffffc0202938:	00003617          	auipc	a2,0x3
ffffffffc020293c:	f1060613          	addi	a2,a2,-240 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202940:	1ac00593          	li	a1,428
ffffffffc0202944:	00003517          	auipc	a0,0x3
ffffffffc0202948:	3dc50513          	addi	a0,a0,988 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc020294c:	b05fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202950:	00003697          	auipc	a3,0x3
ffffffffc0202954:	75868693          	addi	a3,a3,1880 # ffffffffc02060a8 <default_pmm_manager+0x4c8>
ffffffffc0202958:	00003617          	auipc	a2,0x3
ffffffffc020295c:	ef060613          	addi	a2,a2,-272 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202960:	1b800593          	li	a1,440
ffffffffc0202964:	00003517          	auipc	a0,0x3
ffffffffc0202968:	3bc50513          	addi	a0,a0,956 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc020296c:	ae5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202970:	00003697          	auipc	a3,0x3
ffffffffc0202974:	58868693          	addi	a3,a3,1416 # ffffffffc0205ef8 <default_pmm_manager+0x318>
ffffffffc0202978:	00003617          	auipc	a2,0x3
ffffffffc020297c:	ed060613          	addi	a2,a2,-304 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202980:	16b00593          	li	a1,363
ffffffffc0202984:	00003517          	auipc	a0,0x3
ffffffffc0202988:	39c50513          	addi	a0,a0,924 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc020298c:	ac5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202990:	00003697          	auipc	a3,0x3
ffffffffc0202994:	55068693          	addi	a3,a3,1360 # ffffffffc0205ee0 <default_pmm_manager+0x300>
ffffffffc0202998:	00003617          	auipc	a2,0x3
ffffffffc020299c:	eb060613          	addi	a2,a2,-336 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02029a0:	16a00593          	li	a1,362
ffffffffc02029a4:	00003517          	auipc	a0,0x3
ffffffffc02029a8:	37c50513          	addi	a0,a0,892 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02029ac:	aa5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02029b0:	00003697          	auipc	a3,0x3
ffffffffc02029b4:	48068693          	addi	a3,a3,1152 # ffffffffc0205e30 <default_pmm_manager+0x250>
ffffffffc02029b8:	00003617          	auipc	a2,0x3
ffffffffc02029bc:	e9060613          	addi	a2,a2,-368 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02029c0:	16200593          	li	a1,354
ffffffffc02029c4:	00003517          	auipc	a0,0x3
ffffffffc02029c8:	35c50513          	addi	a0,a0,860 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02029cc:	a85fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02029d0:	00003697          	auipc	a3,0x3
ffffffffc02029d4:	4b868693          	addi	a3,a3,1208 # ffffffffc0205e88 <default_pmm_manager+0x2a8>
ffffffffc02029d8:	00003617          	auipc	a2,0x3
ffffffffc02029dc:	e7060613          	addi	a2,a2,-400 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02029e0:	16900593          	li	a1,361
ffffffffc02029e4:	00003517          	auipc	a0,0x3
ffffffffc02029e8:	33c50513          	addi	a0,a0,828 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc02029ec:	a65fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02029f0:	00003697          	auipc	a3,0x3
ffffffffc02029f4:	46868693          	addi	a3,a3,1128 # ffffffffc0205e58 <default_pmm_manager+0x278>
ffffffffc02029f8:	00003617          	auipc	a2,0x3
ffffffffc02029fc:	e5060613          	addi	a2,a2,-432 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202a00:	16600593          	li	a1,358
ffffffffc0202a04:	00003517          	auipc	a0,0x3
ffffffffc0202a08:	31c50513          	addi	a0,a0,796 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202a0c:	a45fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202a10:	00003697          	auipc	a3,0x3
ffffffffc0202a14:	62868693          	addi	a3,a3,1576 # ffffffffc0206038 <default_pmm_manager+0x458>
ffffffffc0202a18:	00003617          	auipc	a2,0x3
ffffffffc0202a1c:	e3060613          	addi	a2,a2,-464 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202a20:	18200593          	li	a1,386
ffffffffc0202a24:	00003517          	auipc	a0,0x3
ffffffffc0202a28:	2fc50513          	addi	a0,a0,764 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202a2c:	a25fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202a30:	00003697          	auipc	a3,0x3
ffffffffc0202a34:	4c868693          	addi	a3,a3,1224 # ffffffffc0205ef8 <default_pmm_manager+0x318>
ffffffffc0202a38:	00003617          	auipc	a2,0x3
ffffffffc0202a3c:	e1060613          	addi	a2,a2,-496 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202a40:	18100593          	li	a1,385
ffffffffc0202a44:	00003517          	auipc	a0,0x3
ffffffffc0202a48:	2dc50513          	addi	a0,a0,732 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202a4c:	a05fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202a50:	00003697          	auipc	a3,0x3
ffffffffc0202a54:	60068693          	addi	a3,a3,1536 # ffffffffc0206050 <default_pmm_manager+0x470>
ffffffffc0202a58:	00003617          	auipc	a2,0x3
ffffffffc0202a5c:	df060613          	addi	a2,a2,-528 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202a60:	17e00593          	li	a1,382
ffffffffc0202a64:	00003517          	auipc	a0,0x3
ffffffffc0202a68:	2bc50513          	addi	a0,a0,700 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202a6c:	9e5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a70:	00003697          	auipc	a3,0x3
ffffffffc0202a74:	7e068693          	addi	a3,a3,2016 # ffffffffc0206250 <default_pmm_manager+0x670>
ffffffffc0202a78:	00003617          	auipc	a2,0x3
ffffffffc0202a7c:	dd060613          	addi	a2,a2,-560 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202a80:	1af00593          	li	a1,431
ffffffffc0202a84:	00003517          	auipc	a0,0x3
ffffffffc0202a88:	29c50513          	addi	a0,a0,668 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202a8c:	9c5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202a90:	00003697          	auipc	a3,0x3
ffffffffc0202a94:	61868693          	addi	a3,a3,1560 # ffffffffc02060a8 <default_pmm_manager+0x4c8>
ffffffffc0202a98:	00003617          	auipc	a2,0x3
ffffffffc0202a9c:	db060613          	addi	a2,a2,-592 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202aa0:	19000593          	li	a1,400
ffffffffc0202aa4:	00003517          	auipc	a0,0x3
ffffffffc0202aa8:	27c50513          	addi	a0,a0,636 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202aac:	9a5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202ab0:	00003697          	auipc	a3,0x3
ffffffffc0202ab4:	69068693          	addi	a3,a3,1680 # ffffffffc0206140 <default_pmm_manager+0x560>
ffffffffc0202ab8:	00003617          	auipc	a2,0x3
ffffffffc0202abc:	d9060613          	addi	a2,a2,-624 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202ac0:	1a100593          	li	a1,417
ffffffffc0202ac4:	00003517          	auipc	a0,0x3
ffffffffc0202ac8:	25c50513          	addi	a0,a0,604 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202acc:	985fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202ad0:	00003697          	auipc	a3,0x3
ffffffffc0202ad4:	30868693          	addi	a3,a3,776 # ffffffffc0205dd8 <default_pmm_manager+0x1f8>
ffffffffc0202ad8:	00003617          	auipc	a2,0x3
ffffffffc0202adc:	d7060613          	addi	a2,a2,-656 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202ae0:	16000593          	li	a1,352
ffffffffc0202ae4:	00003517          	auipc	a0,0x3
ffffffffc0202ae8:	23c50513          	addi	a0,a0,572 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202aec:	965fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202af0:	00003617          	auipc	a2,0x3
ffffffffc0202af4:	17860613          	addi	a2,a2,376 # ffffffffc0205c68 <default_pmm_manager+0x88>
ffffffffc0202af8:	0c300593          	li	a1,195
ffffffffc0202afc:	00003517          	auipc	a0,0x3
ffffffffc0202b00:	22450513          	addi	a0,a0,548 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202b04:	94dfd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0202b08 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202b08:	12058073          	sfence.vma	a1
}
ffffffffc0202b0c:	8082                	ret

ffffffffc0202b0e <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202b0e:	7179                	addi	sp,sp,-48
ffffffffc0202b10:	e84a                	sd	s2,16(sp)
ffffffffc0202b12:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202b14:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202b16:	f022                	sd	s0,32(sp)
ffffffffc0202b18:	ec26                	sd	s1,24(sp)
ffffffffc0202b1a:	e44e                	sd	s3,8(sp)
ffffffffc0202b1c:	f406                	sd	ra,40(sp)
ffffffffc0202b1e:	84ae                	mv	s1,a1
ffffffffc0202b20:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202b22:	8e8ff0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0202b26:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202b28:	cd19                	beqz	a0,ffffffffc0202b46 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202b2a:	85aa                	mv	a1,a0
ffffffffc0202b2c:	86ce                	mv	a3,s3
ffffffffc0202b2e:	8626                	mv	a2,s1
ffffffffc0202b30:	854a                	mv	a0,s2
ffffffffc0202b32:	c8eff0ef          	jal	ra,ffffffffc0201fc0 <page_insert>
ffffffffc0202b36:	ed39                	bnez	a0,ffffffffc0202b94 <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202b38:	00013797          	auipc	a5,0x13
ffffffffc0202b3c:	96878793          	addi	a5,a5,-1688 # ffffffffc02154a0 <swap_init_ok>
ffffffffc0202b40:	439c                	lw	a5,0(a5)
ffffffffc0202b42:	2781                	sext.w	a5,a5
ffffffffc0202b44:	eb89                	bnez	a5,ffffffffc0202b56 <pgdir_alloc_page+0x48>
}
ffffffffc0202b46:	8522                	mv	a0,s0
ffffffffc0202b48:	70a2                	ld	ra,40(sp)
ffffffffc0202b4a:	7402                	ld	s0,32(sp)
ffffffffc0202b4c:	64e2                	ld	s1,24(sp)
ffffffffc0202b4e:	6942                	ld	s2,16(sp)
ffffffffc0202b50:	69a2                	ld	s3,8(sp)
ffffffffc0202b52:	6145                	addi	sp,sp,48
ffffffffc0202b54:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202b56:	00013797          	auipc	a5,0x13
ffffffffc0202b5a:	a8a78793          	addi	a5,a5,-1398 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0202b5e:	6388                	ld	a0,0(a5)
ffffffffc0202b60:	4681                	li	a3,0
ffffffffc0202b62:	8622                	mv	a2,s0
ffffffffc0202b64:	85a6                	mv	a1,s1
ffffffffc0202b66:	7be000ef          	jal	ra,ffffffffc0203324 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202b6a:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202b6c:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0202b6e:	4785                	li	a5,1
ffffffffc0202b70:	fcf70be3          	beq	a4,a5,ffffffffc0202b46 <pgdir_alloc_page+0x38>
ffffffffc0202b74:	00003697          	auipc	a3,0x3
ffffffffc0202b78:	1bc68693          	addi	a3,a3,444 # ffffffffc0205d30 <default_pmm_manager+0x150>
ffffffffc0202b7c:	00003617          	auipc	a2,0x3
ffffffffc0202b80:	ccc60613          	addi	a2,a2,-820 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202b84:	14800593          	li	a1,328
ffffffffc0202b88:	00003517          	auipc	a0,0x3
ffffffffc0202b8c:	19850513          	addi	a0,a0,408 # ffffffffc0205d20 <default_pmm_manager+0x140>
ffffffffc0202b90:	8c1fd0ef          	jal	ra,ffffffffc0200450 <__panic>
            free_page(page);
ffffffffc0202b94:	8522                	mv	a0,s0
ffffffffc0202b96:	4585                	li	a1,1
ffffffffc0202b98:	8faff0ef          	jal	ra,ffffffffc0201c92 <free_pages>
            return NULL;
ffffffffc0202b9c:	4401                	li	s0,0
ffffffffc0202b9e:	b765                	j	ffffffffc0202b46 <pgdir_alloc_page+0x38>

ffffffffc0202ba0 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202ba0:	7135                	addi	sp,sp,-160
ffffffffc0202ba2:	ed06                	sd	ra,152(sp)
ffffffffc0202ba4:	e922                	sd	s0,144(sp)
ffffffffc0202ba6:	e526                	sd	s1,136(sp)
ffffffffc0202ba8:	e14a                	sd	s2,128(sp)
ffffffffc0202baa:	fcce                	sd	s3,120(sp)
ffffffffc0202bac:	f8d2                	sd	s4,112(sp)
ffffffffc0202bae:	f4d6                	sd	s5,104(sp)
ffffffffc0202bb0:	f0da                	sd	s6,96(sp)
ffffffffc0202bb2:	ecde                	sd	s7,88(sp)
ffffffffc0202bb4:	e8e2                	sd	s8,80(sp)
ffffffffc0202bb6:	e4e6                	sd	s9,72(sp)
ffffffffc0202bb8:	e0ea                	sd	s10,64(sp)
ffffffffc0202bba:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202bbc:	4fa010ef          	jal	ra,ffffffffc02040b6 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202bc0:	00013797          	auipc	a5,0x13
ffffffffc0202bc4:	9d078793          	addi	a5,a5,-1584 # ffffffffc0215590 <max_swap_offset>
ffffffffc0202bc8:	6394                	ld	a3,0(a5)
ffffffffc0202bca:	010007b7          	lui	a5,0x1000
ffffffffc0202bce:	17e1                	addi	a5,a5,-8
ffffffffc0202bd0:	ff968713          	addi	a4,a3,-7
ffffffffc0202bd4:	4ae7e863          	bltu	a5,a4,ffffffffc0203084 <swap_init+0x4e4>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202bd8:	00007797          	auipc	a5,0x7
ffffffffc0202bdc:	43878793          	addi	a5,a5,1080 # ffffffffc020a010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202be0:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202be2:	00013697          	auipc	a3,0x13
ffffffffc0202be6:	8af6bb23          	sd	a5,-1866(a3) # ffffffffc0215498 <sm>
     int r = sm->init();
ffffffffc0202bea:	9702                	jalr	a4
ffffffffc0202bec:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202bee:	c10d                	beqz	a0,ffffffffc0202c10 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202bf0:	60ea                	ld	ra,152(sp)
ffffffffc0202bf2:	644a                	ld	s0,144(sp)
ffffffffc0202bf4:	8556                	mv	a0,s5
ffffffffc0202bf6:	64aa                	ld	s1,136(sp)
ffffffffc0202bf8:	690a                	ld	s2,128(sp)
ffffffffc0202bfa:	79e6                	ld	s3,120(sp)
ffffffffc0202bfc:	7a46                	ld	s4,112(sp)
ffffffffc0202bfe:	7aa6                	ld	s5,104(sp)
ffffffffc0202c00:	7b06                	ld	s6,96(sp)
ffffffffc0202c02:	6be6                	ld	s7,88(sp)
ffffffffc0202c04:	6c46                	ld	s8,80(sp)
ffffffffc0202c06:	6ca6                	ld	s9,72(sp)
ffffffffc0202c08:	6d06                	ld	s10,64(sp)
ffffffffc0202c0a:	7de2                	ld	s11,56(sp)
ffffffffc0202c0c:	610d                	addi	sp,sp,160
ffffffffc0202c0e:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202c10:	00013797          	auipc	a5,0x13
ffffffffc0202c14:	88878793          	addi	a5,a5,-1912 # ffffffffc0215498 <sm>
ffffffffc0202c18:	639c                	ld	a5,0(a5)
ffffffffc0202c1a:	00003517          	auipc	a0,0x3
ffffffffc0202c1e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0206318 <default_pmm_manager+0x738>
    return listelm->next;
ffffffffc0202c22:	00013417          	auipc	s0,0x13
ffffffffc0202c26:	8ae40413          	addi	s0,s0,-1874 # ffffffffc02154d0 <free_area>
ffffffffc0202c2a:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202c2c:	4785                	li	a5,1
ffffffffc0202c2e:	00013717          	auipc	a4,0x13
ffffffffc0202c32:	86f72923          	sw	a5,-1934(a4) # ffffffffc02154a0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202c36:	d58fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202c3a:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c3c:	36878863          	beq	a5,s0,ffffffffc0202fac <swap_init+0x40c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202c40:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202c44:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202c46:	8b05                	andi	a4,a4,1
ffffffffc0202c48:	36070663          	beqz	a4,ffffffffc0202fb4 <swap_init+0x414>
     int ret, count = 0, total = 0, i;
ffffffffc0202c4c:	4481                	li	s1,0
ffffffffc0202c4e:	4901                	li	s2,0
ffffffffc0202c50:	a031                	j	ffffffffc0202c5c <swap_init+0xbc>
ffffffffc0202c52:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202c56:	8b09                	andi	a4,a4,2
ffffffffc0202c58:	34070e63          	beqz	a4,ffffffffc0202fb4 <swap_init+0x414>
        count ++, total += p->property;
ffffffffc0202c5c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202c60:	679c                	ld	a5,8(a5)
ffffffffc0202c62:	2905                	addiw	s2,s2,1
ffffffffc0202c64:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c66:	fe8796e3          	bne	a5,s0,ffffffffc0202c52 <swap_init+0xb2>
ffffffffc0202c6a:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202c6c:	86cff0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>
ffffffffc0202c70:	69351263          	bne	a0,s3,ffffffffc02032f4 <swap_init+0x754>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202c74:	8626                	mv	a2,s1
ffffffffc0202c76:	85ca                	mv	a1,s2
ffffffffc0202c78:	00003517          	auipc	a0,0x3
ffffffffc0202c7c:	6b850513          	addi	a0,a0,1720 # ffffffffc0206330 <default_pmm_manager+0x750>
ffffffffc0202c80:	d0efd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202c84:	44b000ef          	jal	ra,ffffffffc02038ce <mm_create>
ffffffffc0202c88:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202c8a:	60050563          	beqz	a0,ffffffffc0203294 <swap_init+0x6f4>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202c8e:	00013797          	auipc	a5,0x13
ffffffffc0202c92:	95278793          	addi	a5,a5,-1710 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0202c96:	639c                	ld	a5,0(a5)
ffffffffc0202c98:	60079e63          	bnez	a5,ffffffffc02032b4 <swap_init+0x714>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c9c:	00012797          	auipc	a5,0x12
ffffffffc0202ca0:	7ec78793          	addi	a5,a5,2028 # ffffffffc0215488 <boot_pgdir>
ffffffffc0202ca4:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202ca8:	00013797          	auipc	a5,0x13
ffffffffc0202cac:	92a7bc23          	sd	a0,-1736(a5) # ffffffffc02155e0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202cb0:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202cb4:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202cb8:	4e079263          	bnez	a5,ffffffffc020319c <swap_init+0x5fc>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202cbc:	6599                	lui	a1,0x6
ffffffffc0202cbe:	460d                	li	a2,3
ffffffffc0202cc0:	6505                	lui	a0,0x1
ffffffffc0202cc2:	459000ef          	jal	ra,ffffffffc020391a <vma_create>
ffffffffc0202cc6:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202cc8:	4e050a63          	beqz	a0,ffffffffc02031bc <swap_init+0x61c>

     insert_vma_struct(mm, vma);
ffffffffc0202ccc:	855e                	mv	a0,s7
ffffffffc0202cce:	4b9000ef          	jal	ra,ffffffffc0203986 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202cd2:	00003517          	auipc	a0,0x3
ffffffffc0202cd6:	6ce50513          	addi	a0,a0,1742 # ffffffffc02063a0 <default_pmm_manager+0x7c0>
ffffffffc0202cda:	cb4fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202cde:	018bb503          	ld	a0,24(s7)
ffffffffc0202ce2:	4605                	li	a2,1
ffffffffc0202ce4:	6585                	lui	a1,0x1
ffffffffc0202ce6:	832ff0ef          	jal	ra,ffffffffc0201d18 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202cea:	4e050963          	beqz	a0,ffffffffc02031dc <swap_init+0x63c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202cee:	00003517          	auipc	a0,0x3
ffffffffc0202cf2:	70250513          	addi	a0,a0,1794 # ffffffffc02063f0 <default_pmm_manager+0x810>
ffffffffc0202cf6:	00013997          	auipc	s3,0x13
ffffffffc0202cfa:	81298993          	addi	s3,s3,-2030 # ffffffffc0215508 <check_rp>
ffffffffc0202cfe:	c90fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d02:	00013a17          	auipc	s4,0x13
ffffffffc0202d06:	826a0a13          	addi	s4,s4,-2010 # ffffffffc0215528 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202d0a:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202d0c:	4505                	li	a0,1
ffffffffc0202d0e:	efdfe0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
ffffffffc0202d12:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202d16:	32050763          	beqz	a0,ffffffffc0203044 <swap_init+0x4a4>
ffffffffc0202d1a:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202d1c:	8b89                	andi	a5,a5,2
ffffffffc0202d1e:	30079363          	bnez	a5,ffffffffc0203024 <swap_init+0x484>
ffffffffc0202d22:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d24:	ff4c14e3          	bne	s8,s4,ffffffffc0202d0c <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202d28:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202d2a:	00012c17          	auipc	s8,0x12
ffffffffc0202d2e:	7dec0c13          	addi	s8,s8,2014 # ffffffffc0215508 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202d32:	ec3e                	sd	a5,24(sp)
ffffffffc0202d34:	641c                	ld	a5,8(s0)
ffffffffc0202d36:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202d38:	481c                	lw	a5,16(s0)
ffffffffc0202d3a:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202d3c:	00012797          	auipc	a5,0x12
ffffffffc0202d40:	7887be23          	sd	s0,1948(a5) # ffffffffc02154d8 <free_area+0x8>
ffffffffc0202d44:	00012797          	auipc	a5,0x12
ffffffffc0202d48:	7887b623          	sd	s0,1932(a5) # ffffffffc02154d0 <free_area>
     nr_free = 0;
ffffffffc0202d4c:	00012797          	auipc	a5,0x12
ffffffffc0202d50:	7807aa23          	sw	zero,1940(a5) # ffffffffc02154e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202d54:	000c3503          	ld	a0,0(s8)
ffffffffc0202d58:	4585                	li	a1,1
ffffffffc0202d5a:	0c21                	addi	s8,s8,8
ffffffffc0202d5c:	f37fe0ef          	jal	ra,ffffffffc0201c92 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d60:	ff4c1ae3          	bne	s8,s4,ffffffffc0202d54 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d64:	01042c03          	lw	s8,16(s0)
ffffffffc0202d68:	4791                	li	a5,4
ffffffffc0202d6a:	50fc1563          	bne	s8,a5,ffffffffc0203274 <swap_init+0x6d4>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202d6e:	00003517          	auipc	a0,0x3
ffffffffc0202d72:	70a50513          	addi	a0,a0,1802 # ffffffffc0206478 <default_pmm_manager+0x898>
ffffffffc0202d76:	c18fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d7a:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202d7c:	00012797          	auipc	a5,0x12
ffffffffc0202d80:	7207a423          	sw	zero,1832(a5) # ffffffffc02154a4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d84:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202d86:	00012797          	auipc	a5,0x12
ffffffffc0202d8a:	71e78793          	addi	a5,a5,1822 # ffffffffc02154a4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d8e:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202d92:	4398                	lw	a4,0(a5)
ffffffffc0202d94:	4585                	li	a1,1
ffffffffc0202d96:	2701                	sext.w	a4,a4
ffffffffc0202d98:	38b71263          	bne	a4,a1,ffffffffc020311c <swap_init+0x57c>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202d9c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202da0:	4394                	lw	a3,0(a5)
ffffffffc0202da2:	2681                	sext.w	a3,a3
ffffffffc0202da4:	38e69c63          	bne	a3,a4,ffffffffc020313c <swap_init+0x59c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202da8:	6689                	lui	a3,0x2
ffffffffc0202daa:	462d                	li	a2,11
ffffffffc0202dac:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202db0:	4398                	lw	a4,0(a5)
ffffffffc0202db2:	4589                	li	a1,2
ffffffffc0202db4:	2701                	sext.w	a4,a4
ffffffffc0202db6:	2eb71363          	bne	a4,a1,ffffffffc020309c <swap_init+0x4fc>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202dba:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202dbe:	4394                	lw	a3,0(a5)
ffffffffc0202dc0:	2681                	sext.w	a3,a3
ffffffffc0202dc2:	2ee69d63          	bne	a3,a4,ffffffffc02030bc <swap_init+0x51c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202dc6:	668d                	lui	a3,0x3
ffffffffc0202dc8:	4631                	li	a2,12
ffffffffc0202dca:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202dce:	4398                	lw	a4,0(a5)
ffffffffc0202dd0:	458d                	li	a1,3
ffffffffc0202dd2:	2701                	sext.w	a4,a4
ffffffffc0202dd4:	30b71463          	bne	a4,a1,ffffffffc02030dc <swap_init+0x53c>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202dd8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202ddc:	4394                	lw	a3,0(a5)
ffffffffc0202dde:	2681                	sext.w	a3,a3
ffffffffc0202de0:	30e69e63          	bne	a3,a4,ffffffffc02030fc <swap_init+0x55c>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202de4:	6691                	lui	a3,0x4
ffffffffc0202de6:	4635                	li	a2,13
ffffffffc0202de8:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202dec:	4398                	lw	a4,0(a5)
ffffffffc0202dee:	2701                	sext.w	a4,a4
ffffffffc0202df0:	37871663          	bne	a4,s8,ffffffffc020315c <swap_init+0x5bc>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202df4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202df8:	439c                	lw	a5,0(a5)
ffffffffc0202dfa:	2781                	sext.w	a5,a5
ffffffffc0202dfc:	38e79063          	bne	a5,a4,ffffffffc020317c <swap_init+0x5dc>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202e00:	481c                	lw	a5,16(s0)
ffffffffc0202e02:	3e079d63          	bnez	a5,ffffffffc02031fc <swap_init+0x65c>
ffffffffc0202e06:	00012797          	auipc	a5,0x12
ffffffffc0202e0a:	72278793          	addi	a5,a5,1826 # ffffffffc0215528 <swap_in_seq_no>
ffffffffc0202e0e:	00012717          	auipc	a4,0x12
ffffffffc0202e12:	74270713          	addi	a4,a4,1858 # ffffffffc0215550 <swap_out_seq_no>
ffffffffc0202e16:	00012617          	auipc	a2,0x12
ffffffffc0202e1a:	73a60613          	addi	a2,a2,1850 # ffffffffc0215550 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202e1e:	56fd                	li	a3,-1
ffffffffc0202e20:	c394                	sw	a3,0(a5)
ffffffffc0202e22:	c314                	sw	a3,0(a4)
ffffffffc0202e24:	0791                	addi	a5,a5,4
ffffffffc0202e26:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202e28:	fef61ce3          	bne	a2,a5,ffffffffc0202e20 <swap_init+0x280>
ffffffffc0202e2c:	00012697          	auipc	a3,0x12
ffffffffc0202e30:	78468693          	addi	a3,a3,1924 # ffffffffc02155b0 <check_ptep>
ffffffffc0202e34:	00012817          	auipc	a6,0x12
ffffffffc0202e38:	6d480813          	addi	a6,a6,1748 # ffffffffc0215508 <check_rp>
ffffffffc0202e3c:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202e3e:	00012c97          	auipc	s9,0x12
ffffffffc0202e42:	652c8c93          	addi	s9,s9,1618 # ffffffffc0215490 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e46:	00004d97          	auipc	s11,0x4
ffffffffc0202e4a:	142d8d93          	addi	s11,s11,322 # ffffffffc0206f88 <nbase>
ffffffffc0202e4e:	00012c17          	auipc	s8,0x12
ffffffffc0202e52:	6b2c0c13          	addi	s8,s8,1714 # ffffffffc0215500 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202e56:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e5a:	4601                	li	a2,0
ffffffffc0202e5c:	85ea                	mv	a1,s10
ffffffffc0202e5e:	855a                	mv	a0,s6
ffffffffc0202e60:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202e62:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e64:	eb5fe0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc0202e68:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202e6a:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202e6c:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202e6e:	1e050b63          	beqz	a0,ffffffffc0203064 <swap_init+0x4c4>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202e72:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202e74:	0017f613          	andi	a2,a5,1
ffffffffc0202e78:	18060a63          	beqz	a2,ffffffffc020300c <swap_init+0x46c>
    if (PPN(pa) >= npage) {
ffffffffc0202e7c:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e80:	078a                	slli	a5,a5,0x2
ffffffffc0202e82:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e84:	14c7f863          	bleu	a2,a5,ffffffffc0202fd4 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e88:	000db703          	ld	a4,0(s11)
ffffffffc0202e8c:	000c3603          	ld	a2,0(s8)
ffffffffc0202e90:	00083583          	ld	a1,0(a6)
ffffffffc0202e94:	8f99                	sub	a5,a5,a4
ffffffffc0202e96:	079a                	slli	a5,a5,0x6
ffffffffc0202e98:	e43a                	sd	a4,8(sp)
ffffffffc0202e9a:	97b2                	add	a5,a5,a2
ffffffffc0202e9c:	14f59863          	bne	a1,a5,ffffffffc0202fec <swap_init+0x44c>
ffffffffc0202ea0:	6785                	lui	a5,0x1
ffffffffc0202ea2:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ea4:	6795                	lui	a5,0x5
ffffffffc0202ea6:	06a1                	addi	a3,a3,8
ffffffffc0202ea8:	0821                	addi	a6,a6,8
ffffffffc0202eaa:	fafd16e3          	bne	s10,a5,ffffffffc0202e56 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202eae:	00003517          	auipc	a0,0x3
ffffffffc0202eb2:	67250513          	addi	a0,a0,1650 # ffffffffc0206520 <default_pmm_manager+0x940>
ffffffffc0202eb6:	ad8fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0202eba:	00012797          	auipc	a5,0x12
ffffffffc0202ebe:	5de78793          	addi	a5,a5,1502 # ffffffffc0215498 <sm>
ffffffffc0202ec2:	639c                	ld	a5,0(a5)
ffffffffc0202ec4:	7f9c                	ld	a5,56(a5)
ffffffffc0202ec6:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202ec8:	40051663          	bnez	a0,ffffffffc02032d4 <swap_init+0x734>

     nr_free = nr_free_store;
ffffffffc0202ecc:	77a2                	ld	a5,40(sp)
ffffffffc0202ece:	00012717          	auipc	a4,0x12
ffffffffc0202ed2:	60f72923          	sw	a5,1554(a4) # ffffffffc02154e0 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202ed6:	67e2                	ld	a5,24(sp)
ffffffffc0202ed8:	00012717          	auipc	a4,0x12
ffffffffc0202edc:	5ef73c23          	sd	a5,1528(a4) # ffffffffc02154d0 <free_area>
ffffffffc0202ee0:	7782                	ld	a5,32(sp)
ffffffffc0202ee2:	00012717          	auipc	a4,0x12
ffffffffc0202ee6:	5ef73b23          	sd	a5,1526(a4) # ffffffffc02154d8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202eea:	0009b503          	ld	a0,0(s3)
ffffffffc0202eee:	4585                	li	a1,1
ffffffffc0202ef0:	09a1                	addi	s3,s3,8
ffffffffc0202ef2:	da1fe0ef          	jal	ra,ffffffffc0201c92 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ef6:	ff499ae3          	bne	s3,s4,ffffffffc0202eea <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202efa:	855e                	mv	a0,s7
ffffffffc0202efc:	359000ef          	jal	ra,ffffffffc0203a54 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202f00:	00012797          	auipc	a5,0x12
ffffffffc0202f04:	58878793          	addi	a5,a5,1416 # ffffffffc0215488 <boot_pgdir>
ffffffffc0202f08:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202f0a:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f0e:	6394                	ld	a3,0(a5)
ffffffffc0202f10:	068a                	slli	a3,a3,0x2
ffffffffc0202f12:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f14:	0ce6f063          	bleu	a4,a3,ffffffffc0202fd4 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f18:	67a2                	ld	a5,8(sp)
ffffffffc0202f1a:	000c3503          	ld	a0,0(s8)
ffffffffc0202f1e:	8e9d                	sub	a3,a3,a5
ffffffffc0202f20:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202f22:	8699                	srai	a3,a3,0x6
ffffffffc0202f24:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202f26:	57fd                	li	a5,-1
ffffffffc0202f28:	83b1                	srli	a5,a5,0xc
ffffffffc0202f2a:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202f2c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202f2e:	2ee7f763          	bleu	a4,a5,ffffffffc020321c <swap_init+0x67c>
     free_page(pde2page(pd0[0]));
ffffffffc0202f32:	00012797          	auipc	a5,0x12
ffffffffc0202f36:	5be78793          	addi	a5,a5,1470 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0202f3a:	639c                	ld	a5,0(a5)
ffffffffc0202f3c:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f3e:	629c                	ld	a5,0(a3)
ffffffffc0202f40:	078a                	slli	a5,a5,0x2
ffffffffc0202f42:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f44:	08e7f863          	bleu	a4,a5,ffffffffc0202fd4 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f48:	69a2                	ld	s3,8(sp)
ffffffffc0202f4a:	4585                	li	a1,1
ffffffffc0202f4c:	413787b3          	sub	a5,a5,s3
ffffffffc0202f50:	079a                	slli	a5,a5,0x6
ffffffffc0202f52:	953e                	add	a0,a0,a5
ffffffffc0202f54:	d3ffe0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f58:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202f5c:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202f60:	078a                	slli	a5,a5,0x2
ffffffffc0202f62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f64:	06e7f863          	bleu	a4,a5,ffffffffc0202fd4 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f68:	000c3503          	ld	a0,0(s8)
ffffffffc0202f6c:	413787b3          	sub	a5,a5,s3
ffffffffc0202f70:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202f72:	4585                	li	a1,1
ffffffffc0202f74:	953e                	add	a0,a0,a5
ffffffffc0202f76:	d1dfe0ef          	jal	ra,ffffffffc0201c92 <free_pages>
     pgdir[0] = 0;
ffffffffc0202f7a:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202f7e:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202f82:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f84:	00878963          	beq	a5,s0,ffffffffc0202f96 <swap_init+0x3f6>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202f88:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202f8c:	679c                	ld	a5,8(a5)
ffffffffc0202f8e:	397d                	addiw	s2,s2,-1
ffffffffc0202f90:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f92:	fe879be3          	bne	a5,s0,ffffffffc0202f88 <swap_init+0x3e8>
     }
     assert(count==0);
ffffffffc0202f96:	28091f63          	bnez	s2,ffffffffc0203234 <swap_init+0x694>
     assert(total==0);
ffffffffc0202f9a:	2a049d63          	bnez	s1,ffffffffc0203254 <swap_init+0x6b4>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202f9e:	00003517          	auipc	a0,0x3
ffffffffc0202fa2:	5d250513          	addi	a0,a0,1490 # ffffffffc0206570 <default_pmm_manager+0x990>
ffffffffc0202fa6:	9e8fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202faa:	b199                	j	ffffffffc0202bf0 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202fac:	4481                	li	s1,0
ffffffffc0202fae:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202fb0:	4981                	li	s3,0
ffffffffc0202fb2:	b96d                	j	ffffffffc0202c6c <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202fb4:	00003697          	auipc	a3,0x3
ffffffffc0202fb8:	88468693          	addi	a3,a3,-1916 # ffffffffc0205838 <commands+0x8c8>
ffffffffc0202fbc:	00003617          	auipc	a2,0x3
ffffffffc0202fc0:	88c60613          	addi	a2,a2,-1908 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202fc4:	0bd00593          	li	a1,189
ffffffffc0202fc8:	00003517          	auipc	a0,0x3
ffffffffc0202fcc:	34050513          	addi	a0,a0,832 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0202fd0:	c80fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202fd4:	00003617          	auipc	a2,0x3
ffffffffc0202fd8:	cbc60613          	addi	a2,a2,-836 # ffffffffc0205c90 <default_pmm_manager+0xb0>
ffffffffc0202fdc:	06200593          	li	a1,98
ffffffffc0202fe0:	00003517          	auipc	a0,0x3
ffffffffc0202fe4:	c7850513          	addi	a0,a0,-904 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc0202fe8:	c68fd0ef          	jal	ra,ffffffffc0200450 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202fec:	00003697          	auipc	a3,0x3
ffffffffc0202ff0:	50c68693          	addi	a3,a3,1292 # ffffffffc02064f8 <default_pmm_manager+0x918>
ffffffffc0202ff4:	00003617          	auipc	a2,0x3
ffffffffc0202ff8:	85460613          	addi	a2,a2,-1964 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0202ffc:	0fd00593          	li	a1,253
ffffffffc0203000:	00003517          	auipc	a0,0x3
ffffffffc0203004:	30850513          	addi	a0,a0,776 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203008:	c48fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020300c:	00003617          	auipc	a2,0x3
ffffffffc0203010:	eac60613          	addi	a2,a2,-340 # ffffffffc0205eb8 <default_pmm_manager+0x2d8>
ffffffffc0203014:	07400593          	li	a1,116
ffffffffc0203018:	00003517          	auipc	a0,0x3
ffffffffc020301c:	c4050513          	addi	a0,a0,-960 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc0203020:	c30fd0ef          	jal	ra,ffffffffc0200450 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203024:	00003697          	auipc	a3,0x3
ffffffffc0203028:	40c68693          	addi	a3,a3,1036 # ffffffffc0206430 <default_pmm_manager+0x850>
ffffffffc020302c:	00003617          	auipc	a2,0x3
ffffffffc0203030:	81c60613          	addi	a2,a2,-2020 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203034:	0de00593          	li	a1,222
ffffffffc0203038:	00003517          	auipc	a0,0x3
ffffffffc020303c:	2d050513          	addi	a0,a0,720 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203040:	c10fd0ef          	jal	ra,ffffffffc0200450 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203044:	00003697          	auipc	a3,0x3
ffffffffc0203048:	3d468693          	addi	a3,a3,980 # ffffffffc0206418 <default_pmm_manager+0x838>
ffffffffc020304c:	00002617          	auipc	a2,0x2
ffffffffc0203050:	7fc60613          	addi	a2,a2,2044 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203054:	0dd00593          	li	a1,221
ffffffffc0203058:	00003517          	auipc	a0,0x3
ffffffffc020305c:	2b050513          	addi	a0,a0,688 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203060:	bf0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203064:	00003697          	auipc	a3,0x3
ffffffffc0203068:	47c68693          	addi	a3,a3,1148 # ffffffffc02064e0 <default_pmm_manager+0x900>
ffffffffc020306c:	00002617          	auipc	a2,0x2
ffffffffc0203070:	7dc60613          	addi	a2,a2,2012 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203074:	0fc00593          	li	a1,252
ffffffffc0203078:	00003517          	auipc	a0,0x3
ffffffffc020307c:	29050513          	addi	a0,a0,656 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203080:	bd0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203084:	00003617          	auipc	a2,0x3
ffffffffc0203088:	26460613          	addi	a2,a2,612 # ffffffffc02062e8 <default_pmm_manager+0x708>
ffffffffc020308c:	02a00593          	li	a1,42
ffffffffc0203090:	00003517          	auipc	a0,0x3
ffffffffc0203094:	27850513          	addi	a0,a0,632 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203098:	bb8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==2);
ffffffffc020309c:	00003697          	auipc	a3,0x3
ffffffffc02030a0:	41468693          	addi	a3,a3,1044 # ffffffffc02064b0 <default_pmm_manager+0x8d0>
ffffffffc02030a4:	00002617          	auipc	a2,0x2
ffffffffc02030a8:	7a460613          	addi	a2,a2,1956 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02030ac:	09800593          	li	a1,152
ffffffffc02030b0:	00003517          	auipc	a0,0x3
ffffffffc02030b4:	25850513          	addi	a0,a0,600 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc02030b8:	b98fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==2);
ffffffffc02030bc:	00003697          	auipc	a3,0x3
ffffffffc02030c0:	3f468693          	addi	a3,a3,1012 # ffffffffc02064b0 <default_pmm_manager+0x8d0>
ffffffffc02030c4:	00002617          	auipc	a2,0x2
ffffffffc02030c8:	78460613          	addi	a2,a2,1924 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02030cc:	09a00593          	li	a1,154
ffffffffc02030d0:	00003517          	auipc	a0,0x3
ffffffffc02030d4:	23850513          	addi	a0,a0,568 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc02030d8:	b78fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==3);
ffffffffc02030dc:	00003697          	auipc	a3,0x3
ffffffffc02030e0:	3e468693          	addi	a3,a3,996 # ffffffffc02064c0 <default_pmm_manager+0x8e0>
ffffffffc02030e4:	00002617          	auipc	a2,0x2
ffffffffc02030e8:	76460613          	addi	a2,a2,1892 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02030ec:	09c00593          	li	a1,156
ffffffffc02030f0:	00003517          	auipc	a0,0x3
ffffffffc02030f4:	21850513          	addi	a0,a0,536 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc02030f8:	b58fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==3);
ffffffffc02030fc:	00003697          	auipc	a3,0x3
ffffffffc0203100:	3c468693          	addi	a3,a3,964 # ffffffffc02064c0 <default_pmm_manager+0x8e0>
ffffffffc0203104:	00002617          	auipc	a2,0x2
ffffffffc0203108:	74460613          	addi	a2,a2,1860 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020310c:	09e00593          	li	a1,158
ffffffffc0203110:	00003517          	auipc	a0,0x3
ffffffffc0203114:	1f850513          	addi	a0,a0,504 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203118:	b38fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==1);
ffffffffc020311c:	00003697          	auipc	a3,0x3
ffffffffc0203120:	38468693          	addi	a3,a3,900 # ffffffffc02064a0 <default_pmm_manager+0x8c0>
ffffffffc0203124:	00002617          	auipc	a2,0x2
ffffffffc0203128:	72460613          	addi	a2,a2,1828 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020312c:	09400593          	li	a1,148
ffffffffc0203130:	00003517          	auipc	a0,0x3
ffffffffc0203134:	1d850513          	addi	a0,a0,472 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203138:	b18fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==1);
ffffffffc020313c:	00003697          	auipc	a3,0x3
ffffffffc0203140:	36468693          	addi	a3,a3,868 # ffffffffc02064a0 <default_pmm_manager+0x8c0>
ffffffffc0203144:	00002617          	auipc	a2,0x2
ffffffffc0203148:	70460613          	addi	a2,a2,1796 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020314c:	09600593          	li	a1,150
ffffffffc0203150:	00003517          	auipc	a0,0x3
ffffffffc0203154:	1b850513          	addi	a0,a0,440 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203158:	af8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==4);
ffffffffc020315c:	00003697          	auipc	a3,0x3
ffffffffc0203160:	37468693          	addi	a3,a3,884 # ffffffffc02064d0 <default_pmm_manager+0x8f0>
ffffffffc0203164:	00002617          	auipc	a2,0x2
ffffffffc0203168:	6e460613          	addi	a2,a2,1764 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020316c:	0a000593          	li	a1,160
ffffffffc0203170:	00003517          	auipc	a0,0x3
ffffffffc0203174:	19850513          	addi	a0,a0,408 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203178:	ad8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==4);
ffffffffc020317c:	00003697          	auipc	a3,0x3
ffffffffc0203180:	35468693          	addi	a3,a3,852 # ffffffffc02064d0 <default_pmm_manager+0x8f0>
ffffffffc0203184:	00002617          	auipc	a2,0x2
ffffffffc0203188:	6c460613          	addi	a2,a2,1732 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020318c:	0a200593          	li	a1,162
ffffffffc0203190:	00003517          	auipc	a0,0x3
ffffffffc0203194:	17850513          	addi	a0,a0,376 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203198:	ab8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgdir[0] == 0);
ffffffffc020319c:	00003697          	auipc	a3,0x3
ffffffffc02031a0:	1e468693          	addi	a3,a3,484 # ffffffffc0206380 <default_pmm_manager+0x7a0>
ffffffffc02031a4:	00002617          	auipc	a2,0x2
ffffffffc02031a8:	6a460613          	addi	a2,a2,1700 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02031ac:	0cd00593          	li	a1,205
ffffffffc02031b0:	00003517          	auipc	a0,0x3
ffffffffc02031b4:	15850513          	addi	a0,a0,344 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc02031b8:	a98fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(vma != NULL);
ffffffffc02031bc:	00003697          	auipc	a3,0x3
ffffffffc02031c0:	1d468693          	addi	a3,a3,468 # ffffffffc0206390 <default_pmm_manager+0x7b0>
ffffffffc02031c4:	00002617          	auipc	a2,0x2
ffffffffc02031c8:	68460613          	addi	a2,a2,1668 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02031cc:	0d000593          	li	a1,208
ffffffffc02031d0:	00003517          	auipc	a0,0x3
ffffffffc02031d4:	13850513          	addi	a0,a0,312 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc02031d8:	a78fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02031dc:	00003697          	auipc	a3,0x3
ffffffffc02031e0:	1fc68693          	addi	a3,a3,508 # ffffffffc02063d8 <default_pmm_manager+0x7f8>
ffffffffc02031e4:	00002617          	auipc	a2,0x2
ffffffffc02031e8:	66460613          	addi	a2,a2,1636 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02031ec:	0d800593          	li	a1,216
ffffffffc02031f0:	00003517          	auipc	a0,0x3
ffffffffc02031f4:	11850513          	addi	a0,a0,280 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc02031f8:	a58fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert( nr_free == 0);         
ffffffffc02031fc:	00003697          	auipc	a3,0x3
ffffffffc0203200:	82468693          	addi	a3,a3,-2012 # ffffffffc0205a20 <commands+0xab0>
ffffffffc0203204:	00002617          	auipc	a2,0x2
ffffffffc0203208:	64460613          	addi	a2,a2,1604 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020320c:	0f400593          	li	a1,244
ffffffffc0203210:	00003517          	auipc	a0,0x3
ffffffffc0203214:	0f850513          	addi	a0,a0,248 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203218:	a38fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc020321c:	00003617          	auipc	a2,0x3
ffffffffc0203220:	a1460613          	addi	a2,a2,-1516 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc0203224:	06900593          	li	a1,105
ffffffffc0203228:	00003517          	auipc	a0,0x3
ffffffffc020322c:	a3050513          	addi	a0,a0,-1488 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc0203230:	a20fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(count==0);
ffffffffc0203234:	00003697          	auipc	a3,0x3
ffffffffc0203238:	31c68693          	addi	a3,a3,796 # ffffffffc0206550 <default_pmm_manager+0x970>
ffffffffc020323c:	00002617          	auipc	a2,0x2
ffffffffc0203240:	60c60613          	addi	a2,a2,1548 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203244:	11c00593          	li	a1,284
ffffffffc0203248:	00003517          	auipc	a0,0x3
ffffffffc020324c:	0c050513          	addi	a0,a0,192 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203250:	a00fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(total==0);
ffffffffc0203254:	00003697          	auipc	a3,0x3
ffffffffc0203258:	30c68693          	addi	a3,a3,780 # ffffffffc0206560 <default_pmm_manager+0x980>
ffffffffc020325c:	00002617          	auipc	a2,0x2
ffffffffc0203260:	5ec60613          	addi	a2,a2,1516 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203264:	11d00593          	li	a1,285
ffffffffc0203268:	00003517          	auipc	a0,0x3
ffffffffc020326c:	0a050513          	addi	a0,a0,160 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203270:	9e0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203274:	00003697          	auipc	a3,0x3
ffffffffc0203278:	1dc68693          	addi	a3,a3,476 # ffffffffc0206450 <default_pmm_manager+0x870>
ffffffffc020327c:	00002617          	auipc	a2,0x2
ffffffffc0203280:	5cc60613          	addi	a2,a2,1484 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203284:	0eb00593          	li	a1,235
ffffffffc0203288:	00003517          	auipc	a0,0x3
ffffffffc020328c:	08050513          	addi	a0,a0,128 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203290:	9c0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(mm != NULL);
ffffffffc0203294:	00003697          	auipc	a3,0x3
ffffffffc0203298:	0c468693          	addi	a3,a3,196 # ffffffffc0206358 <default_pmm_manager+0x778>
ffffffffc020329c:	00002617          	auipc	a2,0x2
ffffffffc02032a0:	5ac60613          	addi	a2,a2,1452 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02032a4:	0c500593          	li	a1,197
ffffffffc02032a8:	00003517          	auipc	a0,0x3
ffffffffc02032ac:	06050513          	addi	a0,a0,96 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc02032b0:	9a0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc02032b4:	00003697          	auipc	a3,0x3
ffffffffc02032b8:	0b468693          	addi	a3,a3,180 # ffffffffc0206368 <default_pmm_manager+0x788>
ffffffffc02032bc:	00002617          	auipc	a2,0x2
ffffffffc02032c0:	58c60613          	addi	a2,a2,1420 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02032c4:	0c800593          	li	a1,200
ffffffffc02032c8:	00003517          	auipc	a0,0x3
ffffffffc02032cc:	04050513          	addi	a0,a0,64 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc02032d0:	980fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(ret==0);
ffffffffc02032d4:	00003697          	auipc	a3,0x3
ffffffffc02032d8:	27468693          	addi	a3,a3,628 # ffffffffc0206548 <default_pmm_manager+0x968>
ffffffffc02032dc:	00002617          	auipc	a2,0x2
ffffffffc02032e0:	56c60613          	addi	a2,a2,1388 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02032e4:	10300593          	li	a1,259
ffffffffc02032e8:	00003517          	auipc	a0,0x3
ffffffffc02032ec:	02050513          	addi	a0,a0,32 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc02032f0:	960fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(total == nr_free_pages());
ffffffffc02032f4:	00002697          	auipc	a3,0x2
ffffffffc02032f8:	58468693          	addi	a3,a3,1412 # ffffffffc0205878 <commands+0x908>
ffffffffc02032fc:	00002617          	auipc	a2,0x2
ffffffffc0203300:	54c60613          	addi	a2,a2,1356 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203304:	0c000593          	li	a1,192
ffffffffc0203308:	00003517          	auipc	a0,0x3
ffffffffc020330c:	00050513          	mv	a0,a0
ffffffffc0203310:	940fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203314 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203314:	00012797          	auipc	a5,0x12
ffffffffc0203318:	18478793          	addi	a5,a5,388 # ffffffffc0215498 <sm>
ffffffffc020331c:	639c                	ld	a5,0(a5)
ffffffffc020331e:	0107b303          	ld	t1,16(a5)
ffffffffc0203322:	8302                	jr	t1

ffffffffc0203324 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203324:	00012797          	auipc	a5,0x12
ffffffffc0203328:	17478793          	addi	a5,a5,372 # ffffffffc0215498 <sm>
ffffffffc020332c:	639c                	ld	a5,0(a5)
ffffffffc020332e:	0207b303          	ld	t1,32(a5)
ffffffffc0203332:	8302                	jr	t1

ffffffffc0203334 <swap_out>:
{
ffffffffc0203334:	711d                	addi	sp,sp,-96
ffffffffc0203336:	ec86                	sd	ra,88(sp)
ffffffffc0203338:	e8a2                	sd	s0,80(sp)
ffffffffc020333a:	e4a6                	sd	s1,72(sp)
ffffffffc020333c:	e0ca                	sd	s2,64(sp)
ffffffffc020333e:	fc4e                	sd	s3,56(sp)
ffffffffc0203340:	f852                	sd	s4,48(sp)
ffffffffc0203342:	f456                	sd	s5,40(sp)
ffffffffc0203344:	f05a                	sd	s6,32(sp)
ffffffffc0203346:	ec5e                	sd	s7,24(sp)
ffffffffc0203348:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc020334a:	cde9                	beqz	a1,ffffffffc0203424 <swap_out+0xf0>
ffffffffc020334c:	8ab2                	mv	s5,a2
ffffffffc020334e:	892a                	mv	s2,a0
ffffffffc0203350:	8a2e                	mv	s4,a1
ffffffffc0203352:	4401                	li	s0,0
ffffffffc0203354:	00012997          	auipc	s3,0x12
ffffffffc0203358:	14498993          	addi	s3,s3,324 # ffffffffc0215498 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020335c:	00003b17          	auipc	s6,0x3
ffffffffc0203360:	294b0b13          	addi	s6,s6,660 # ffffffffc02065f0 <default_pmm_manager+0xa10>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203364:	00003b97          	auipc	s7,0x3
ffffffffc0203368:	274b8b93          	addi	s7,s7,628 # ffffffffc02065d8 <default_pmm_manager+0x9f8>
ffffffffc020336c:	a825                	j	ffffffffc02033a4 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020336e:	67a2                	ld	a5,8(sp)
ffffffffc0203370:	8626                	mv	a2,s1
ffffffffc0203372:	85a2                	mv	a1,s0
ffffffffc0203374:	7f94                	ld	a3,56(a5)
ffffffffc0203376:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203378:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020337a:	82b1                	srli	a3,a3,0xc
ffffffffc020337c:	0685                	addi	a3,a3,1
ffffffffc020337e:	e11fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203382:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203384:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203386:	7d1c                	ld	a5,56(a0)
ffffffffc0203388:	83b1                	srli	a5,a5,0xc
ffffffffc020338a:	0785                	addi	a5,a5,1
ffffffffc020338c:	07a2                	slli	a5,a5,0x8
ffffffffc020338e:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203392:	901fe0ef          	jal	ra,ffffffffc0201c92 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203396:	01893503          	ld	a0,24(s2)
ffffffffc020339a:	85a6                	mv	a1,s1
ffffffffc020339c:	f6cff0ef          	jal	ra,ffffffffc0202b08 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc02033a0:	048a0d63          	beq	s4,s0,ffffffffc02033fa <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc02033a4:	0009b783          	ld	a5,0(s3)
ffffffffc02033a8:	8656                	mv	a2,s5
ffffffffc02033aa:	002c                	addi	a1,sp,8
ffffffffc02033ac:	7b9c                	ld	a5,48(a5)
ffffffffc02033ae:	854a                	mv	a0,s2
ffffffffc02033b0:	9782                	jalr	a5
          if (r != 0) {
ffffffffc02033b2:	e12d                	bnez	a0,ffffffffc0203414 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc02033b4:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02033b6:	01893503          	ld	a0,24(s2)
ffffffffc02033ba:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc02033bc:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02033be:	85a6                	mv	a1,s1
ffffffffc02033c0:	959fe0ef          	jal	ra,ffffffffc0201d18 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc02033c4:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02033c6:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc02033c8:	8b85                	andi	a5,a5,1
ffffffffc02033ca:	cfb9                	beqz	a5,ffffffffc0203428 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc02033cc:	65a2                	ld	a1,8(sp)
ffffffffc02033ce:	7d9c                	ld	a5,56(a1)
ffffffffc02033d0:	83b1                	srli	a5,a5,0xc
ffffffffc02033d2:	00178513          	addi	a0,a5,1
ffffffffc02033d6:	0522                	slli	a0,a0,0x8
ffffffffc02033d8:	5af000ef          	jal	ra,ffffffffc0204186 <swapfs_write>
ffffffffc02033dc:	d949                	beqz	a0,ffffffffc020336e <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc02033de:	855e                	mv	a0,s7
ffffffffc02033e0:	daffc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02033e4:	0009b783          	ld	a5,0(s3)
ffffffffc02033e8:	6622                	ld	a2,8(sp)
ffffffffc02033ea:	4681                	li	a3,0
ffffffffc02033ec:	739c                	ld	a5,32(a5)
ffffffffc02033ee:	85a6                	mv	a1,s1
ffffffffc02033f0:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02033f2:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02033f4:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02033f6:	fa8a17e3          	bne	s4,s0,ffffffffc02033a4 <swap_out+0x70>
}
ffffffffc02033fa:	8522                	mv	a0,s0
ffffffffc02033fc:	60e6                	ld	ra,88(sp)
ffffffffc02033fe:	6446                	ld	s0,80(sp)
ffffffffc0203400:	64a6                	ld	s1,72(sp)
ffffffffc0203402:	6906                	ld	s2,64(sp)
ffffffffc0203404:	79e2                	ld	s3,56(sp)
ffffffffc0203406:	7a42                	ld	s4,48(sp)
ffffffffc0203408:	7aa2                	ld	s5,40(sp)
ffffffffc020340a:	7b02                	ld	s6,32(sp)
ffffffffc020340c:	6be2                	ld	s7,24(sp)
ffffffffc020340e:	6c42                	ld	s8,16(sp)
ffffffffc0203410:	6125                	addi	sp,sp,96
ffffffffc0203412:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203414:	85a2                	mv	a1,s0
ffffffffc0203416:	00003517          	auipc	a0,0x3
ffffffffc020341a:	17a50513          	addi	a0,a0,378 # ffffffffc0206590 <default_pmm_manager+0x9b0>
ffffffffc020341e:	d71fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203422:	bfe1                	j	ffffffffc02033fa <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203424:	4401                	li	s0,0
ffffffffc0203426:	bfd1                	j	ffffffffc02033fa <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203428:	00003697          	auipc	a3,0x3
ffffffffc020342c:	19868693          	addi	a3,a3,408 # ffffffffc02065c0 <default_pmm_manager+0x9e0>
ffffffffc0203430:	00002617          	auipc	a2,0x2
ffffffffc0203434:	41860613          	addi	a2,a2,1048 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203438:	06900593          	li	a1,105
ffffffffc020343c:	00003517          	auipc	a0,0x3
ffffffffc0203440:	ecc50513          	addi	a0,a0,-308 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc0203444:	80cfd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203448 <swap_in>:
{
ffffffffc0203448:	7179                	addi	sp,sp,-48
ffffffffc020344a:	e84a                	sd	s2,16(sp)
ffffffffc020344c:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc020344e:	4505                	li	a0,1
{
ffffffffc0203450:	ec26                	sd	s1,24(sp)
ffffffffc0203452:	e44e                	sd	s3,8(sp)
ffffffffc0203454:	f406                	sd	ra,40(sp)
ffffffffc0203456:	f022                	sd	s0,32(sp)
ffffffffc0203458:	84ae                	mv	s1,a1
ffffffffc020345a:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc020345c:	faefe0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
     assert(result!=NULL);
ffffffffc0203460:	c129                	beqz	a0,ffffffffc02034a2 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203462:	842a                	mv	s0,a0
ffffffffc0203464:	01893503          	ld	a0,24(s2)
ffffffffc0203468:	4601                	li	a2,0
ffffffffc020346a:	85a6                	mv	a1,s1
ffffffffc020346c:	8adfe0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc0203470:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203472:	6108                	ld	a0,0(a0)
ffffffffc0203474:	85a2                	mv	a1,s0
ffffffffc0203476:	479000ef          	jal	ra,ffffffffc02040ee <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc020347a:	00093583          	ld	a1,0(s2)
ffffffffc020347e:	8626                	mv	a2,s1
ffffffffc0203480:	00003517          	auipc	a0,0x3
ffffffffc0203484:	e2850513          	addi	a0,a0,-472 # ffffffffc02062a8 <default_pmm_manager+0x6c8>
ffffffffc0203488:	81a1                	srli	a1,a1,0x8
ffffffffc020348a:	d05fc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc020348e:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203490:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203494:	7402                	ld	s0,32(sp)
ffffffffc0203496:	64e2                	ld	s1,24(sp)
ffffffffc0203498:	6942                	ld	s2,16(sp)
ffffffffc020349a:	69a2                	ld	s3,8(sp)
ffffffffc020349c:	4501                	li	a0,0
ffffffffc020349e:	6145                	addi	sp,sp,48
ffffffffc02034a0:	8082                	ret
     assert(result!=NULL);
ffffffffc02034a2:	00003697          	auipc	a3,0x3
ffffffffc02034a6:	df668693          	addi	a3,a3,-522 # ffffffffc0206298 <default_pmm_manager+0x6b8>
ffffffffc02034aa:	00002617          	auipc	a2,0x2
ffffffffc02034ae:	39e60613          	addi	a2,a2,926 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02034b2:	07f00593          	li	a1,127
ffffffffc02034b6:	00003517          	auipc	a0,0x3
ffffffffc02034ba:	e5250513          	addi	a0,a0,-430 # ffffffffc0206308 <default_pmm_manager+0x728>
ffffffffc02034be:	f93fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02034c2 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02034c2:	00012797          	auipc	a5,0x12
ffffffffc02034c6:	10e78793          	addi	a5,a5,270 # ffffffffc02155d0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02034ca:	f51c                	sd	a5,40(a0)
ffffffffc02034cc:	e79c                	sd	a5,8(a5)
ffffffffc02034ce:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02034d0:	4501                	li	a0,0
ffffffffc02034d2:	8082                	ret

ffffffffc02034d4 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02034d4:	4501                	li	a0,0
ffffffffc02034d6:	8082                	ret

ffffffffc02034d8 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02034d8:	4501                	li	a0,0
ffffffffc02034da:	8082                	ret

ffffffffc02034dc <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02034dc:	4501                	li	a0,0
ffffffffc02034de:	8082                	ret

ffffffffc02034e0 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02034e0:	711d                	addi	sp,sp,-96
ffffffffc02034e2:	fc4e                	sd	s3,56(sp)
ffffffffc02034e4:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02034e6:	00003517          	auipc	a0,0x3
ffffffffc02034ea:	14a50513          	addi	a0,a0,330 # ffffffffc0206630 <default_pmm_manager+0xa50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02034ee:	698d                	lui	s3,0x3
ffffffffc02034f0:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02034f2:	e8a2                	sd	s0,80(sp)
ffffffffc02034f4:	e4a6                	sd	s1,72(sp)
ffffffffc02034f6:	ec86                	sd	ra,88(sp)
ffffffffc02034f8:	e0ca                	sd	s2,64(sp)
ffffffffc02034fa:	f456                	sd	s5,40(sp)
ffffffffc02034fc:	f05a                	sd	s6,32(sp)
ffffffffc02034fe:	ec5e                	sd	s7,24(sp)
ffffffffc0203500:	e862                	sd	s8,16(sp)
ffffffffc0203502:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203504:	00012417          	auipc	s0,0x12
ffffffffc0203508:	fa040413          	addi	s0,s0,-96 # ffffffffc02154a4 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020350c:	c83fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203510:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203514:	4004                	lw	s1,0(s0)
ffffffffc0203516:	4791                	li	a5,4
ffffffffc0203518:	2481                	sext.w	s1,s1
ffffffffc020351a:	14f49963          	bne	s1,a5,ffffffffc020366c <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020351e:	00003517          	auipc	a0,0x3
ffffffffc0203522:	15250513          	addi	a0,a0,338 # ffffffffc0206670 <default_pmm_manager+0xa90>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203526:	6a85                	lui	s5,0x1
ffffffffc0203528:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020352a:	c65fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020352e:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203532:	00042903          	lw	s2,0(s0)
ffffffffc0203536:	2901                	sext.w	s2,s2
ffffffffc0203538:	2a991a63          	bne	s2,s1,ffffffffc02037ec <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020353c:	00003517          	auipc	a0,0x3
ffffffffc0203540:	15c50513          	addi	a0,a0,348 # ffffffffc0206698 <default_pmm_manager+0xab8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203544:	6b91                	lui	s7,0x4
ffffffffc0203546:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203548:	c47fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020354c:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203550:	4004                	lw	s1,0(s0)
ffffffffc0203552:	2481                	sext.w	s1,s1
ffffffffc0203554:	27249c63          	bne	s1,s2,ffffffffc02037cc <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203558:	00003517          	auipc	a0,0x3
ffffffffc020355c:	16850513          	addi	a0,a0,360 # ffffffffc02066c0 <default_pmm_manager+0xae0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203560:	6909                	lui	s2,0x2
ffffffffc0203562:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203564:	c2bfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203568:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020356c:	401c                	lw	a5,0(s0)
ffffffffc020356e:	2781                	sext.w	a5,a5
ffffffffc0203570:	22979e63          	bne	a5,s1,ffffffffc02037ac <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203574:	00003517          	auipc	a0,0x3
ffffffffc0203578:	17450513          	addi	a0,a0,372 # ffffffffc02066e8 <default_pmm_manager+0xb08>
ffffffffc020357c:	c13fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203580:	6795                	lui	a5,0x5
ffffffffc0203582:	4739                	li	a4,14
ffffffffc0203584:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203588:	4004                	lw	s1,0(s0)
ffffffffc020358a:	4795                	li	a5,5
ffffffffc020358c:	2481                	sext.w	s1,s1
ffffffffc020358e:	1ef49f63          	bne	s1,a5,ffffffffc020378c <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203592:	00003517          	auipc	a0,0x3
ffffffffc0203596:	12e50513          	addi	a0,a0,302 # ffffffffc02066c0 <default_pmm_manager+0xae0>
ffffffffc020359a:	bf5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020359e:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc02035a2:	401c                	lw	a5,0(s0)
ffffffffc02035a4:	2781                	sext.w	a5,a5
ffffffffc02035a6:	1c979363          	bne	a5,s1,ffffffffc020376c <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02035aa:	00003517          	auipc	a0,0x3
ffffffffc02035ae:	0c650513          	addi	a0,a0,198 # ffffffffc0206670 <default_pmm_manager+0xa90>
ffffffffc02035b2:	bddfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02035b6:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02035ba:	401c                	lw	a5,0(s0)
ffffffffc02035bc:	4719                	li	a4,6
ffffffffc02035be:	2781                	sext.w	a5,a5
ffffffffc02035c0:	18e79663          	bne	a5,a4,ffffffffc020374c <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02035c4:	00003517          	auipc	a0,0x3
ffffffffc02035c8:	0fc50513          	addi	a0,a0,252 # ffffffffc02066c0 <default_pmm_manager+0xae0>
ffffffffc02035cc:	bc3fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02035d0:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc02035d4:	401c                	lw	a5,0(s0)
ffffffffc02035d6:	471d                	li	a4,7
ffffffffc02035d8:	2781                	sext.w	a5,a5
ffffffffc02035da:	14e79963          	bne	a5,a4,ffffffffc020372c <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02035de:	00003517          	auipc	a0,0x3
ffffffffc02035e2:	05250513          	addi	a0,a0,82 # ffffffffc0206630 <default_pmm_manager+0xa50>
ffffffffc02035e6:	ba9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035ea:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02035ee:	401c                	lw	a5,0(s0)
ffffffffc02035f0:	4721                	li	a4,8
ffffffffc02035f2:	2781                	sext.w	a5,a5
ffffffffc02035f4:	10e79c63          	bne	a5,a4,ffffffffc020370c <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02035f8:	00003517          	auipc	a0,0x3
ffffffffc02035fc:	0a050513          	addi	a0,a0,160 # ffffffffc0206698 <default_pmm_manager+0xab8>
ffffffffc0203600:	b8ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203604:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203608:	401c                	lw	a5,0(s0)
ffffffffc020360a:	4725                	li	a4,9
ffffffffc020360c:	2781                	sext.w	a5,a5
ffffffffc020360e:	0ce79f63          	bne	a5,a4,ffffffffc02036ec <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203612:	00003517          	auipc	a0,0x3
ffffffffc0203616:	0d650513          	addi	a0,a0,214 # ffffffffc02066e8 <default_pmm_manager+0xb08>
ffffffffc020361a:	b75fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020361e:	6795                	lui	a5,0x5
ffffffffc0203620:	4739                	li	a4,14
ffffffffc0203622:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0203626:	4004                	lw	s1,0(s0)
ffffffffc0203628:	47a9                	li	a5,10
ffffffffc020362a:	2481                	sext.w	s1,s1
ffffffffc020362c:	0af49063          	bne	s1,a5,ffffffffc02036cc <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203630:	00003517          	auipc	a0,0x3
ffffffffc0203634:	04050513          	addi	a0,a0,64 # ffffffffc0206670 <default_pmm_manager+0xa90>
ffffffffc0203638:	b57fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020363c:	6785                	lui	a5,0x1
ffffffffc020363e:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203642:	06979563          	bne	a5,s1,ffffffffc02036ac <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203646:	401c                	lw	a5,0(s0)
ffffffffc0203648:	472d                	li	a4,11
ffffffffc020364a:	2781                	sext.w	a5,a5
ffffffffc020364c:	04e79063          	bne	a5,a4,ffffffffc020368c <_fifo_check_swap+0x1ac>
}
ffffffffc0203650:	60e6                	ld	ra,88(sp)
ffffffffc0203652:	6446                	ld	s0,80(sp)
ffffffffc0203654:	64a6                	ld	s1,72(sp)
ffffffffc0203656:	6906                	ld	s2,64(sp)
ffffffffc0203658:	79e2                	ld	s3,56(sp)
ffffffffc020365a:	7a42                	ld	s4,48(sp)
ffffffffc020365c:	7aa2                	ld	s5,40(sp)
ffffffffc020365e:	7b02                	ld	s6,32(sp)
ffffffffc0203660:	6be2                	ld	s7,24(sp)
ffffffffc0203662:	6c42                	ld	s8,16(sp)
ffffffffc0203664:	6ca2                	ld	s9,8(sp)
ffffffffc0203666:	4501                	li	a0,0
ffffffffc0203668:	6125                	addi	sp,sp,96
ffffffffc020366a:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020366c:	00003697          	auipc	a3,0x3
ffffffffc0203670:	e6468693          	addi	a3,a3,-412 # ffffffffc02064d0 <default_pmm_manager+0x8f0>
ffffffffc0203674:	00002617          	auipc	a2,0x2
ffffffffc0203678:	1d460613          	addi	a2,a2,468 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020367c:	05100593          	li	a1,81
ffffffffc0203680:	00003517          	auipc	a0,0x3
ffffffffc0203684:	fd850513          	addi	a0,a0,-40 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc0203688:	dc9fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==11);
ffffffffc020368c:	00003697          	auipc	a3,0x3
ffffffffc0203690:	10c68693          	addi	a3,a3,268 # ffffffffc0206798 <default_pmm_manager+0xbb8>
ffffffffc0203694:	00002617          	auipc	a2,0x2
ffffffffc0203698:	1b460613          	addi	a2,a2,436 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020369c:	07300593          	li	a1,115
ffffffffc02036a0:	00003517          	auipc	a0,0x3
ffffffffc02036a4:	fb850513          	addi	a0,a0,-72 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc02036a8:	da9fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02036ac:	00003697          	auipc	a3,0x3
ffffffffc02036b0:	0c468693          	addi	a3,a3,196 # ffffffffc0206770 <default_pmm_manager+0xb90>
ffffffffc02036b4:	00002617          	auipc	a2,0x2
ffffffffc02036b8:	19460613          	addi	a2,a2,404 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02036bc:	07100593          	li	a1,113
ffffffffc02036c0:	00003517          	auipc	a0,0x3
ffffffffc02036c4:	f9850513          	addi	a0,a0,-104 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc02036c8:	d89fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==10);
ffffffffc02036cc:	00003697          	auipc	a3,0x3
ffffffffc02036d0:	09468693          	addi	a3,a3,148 # ffffffffc0206760 <default_pmm_manager+0xb80>
ffffffffc02036d4:	00002617          	auipc	a2,0x2
ffffffffc02036d8:	17460613          	addi	a2,a2,372 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02036dc:	06f00593          	li	a1,111
ffffffffc02036e0:	00003517          	auipc	a0,0x3
ffffffffc02036e4:	f7850513          	addi	a0,a0,-136 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc02036e8:	d69fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==9);
ffffffffc02036ec:	00003697          	auipc	a3,0x3
ffffffffc02036f0:	06468693          	addi	a3,a3,100 # ffffffffc0206750 <default_pmm_manager+0xb70>
ffffffffc02036f4:	00002617          	auipc	a2,0x2
ffffffffc02036f8:	15460613          	addi	a2,a2,340 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02036fc:	06c00593          	li	a1,108
ffffffffc0203700:	00003517          	auipc	a0,0x3
ffffffffc0203704:	f5850513          	addi	a0,a0,-168 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc0203708:	d49fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==8);
ffffffffc020370c:	00003697          	auipc	a3,0x3
ffffffffc0203710:	03468693          	addi	a3,a3,52 # ffffffffc0206740 <default_pmm_manager+0xb60>
ffffffffc0203714:	00002617          	auipc	a2,0x2
ffffffffc0203718:	13460613          	addi	a2,a2,308 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020371c:	06900593          	li	a1,105
ffffffffc0203720:	00003517          	auipc	a0,0x3
ffffffffc0203724:	f3850513          	addi	a0,a0,-200 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc0203728:	d29fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==7);
ffffffffc020372c:	00003697          	auipc	a3,0x3
ffffffffc0203730:	00468693          	addi	a3,a3,4 # ffffffffc0206730 <default_pmm_manager+0xb50>
ffffffffc0203734:	00002617          	auipc	a2,0x2
ffffffffc0203738:	11460613          	addi	a2,a2,276 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020373c:	06600593          	li	a1,102
ffffffffc0203740:	00003517          	auipc	a0,0x3
ffffffffc0203744:	f1850513          	addi	a0,a0,-232 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc0203748:	d09fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==6);
ffffffffc020374c:	00003697          	auipc	a3,0x3
ffffffffc0203750:	fd468693          	addi	a3,a3,-44 # ffffffffc0206720 <default_pmm_manager+0xb40>
ffffffffc0203754:	00002617          	auipc	a2,0x2
ffffffffc0203758:	0f460613          	addi	a2,a2,244 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020375c:	06300593          	li	a1,99
ffffffffc0203760:	00003517          	auipc	a0,0x3
ffffffffc0203764:	ef850513          	addi	a0,a0,-264 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc0203768:	ce9fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==5);
ffffffffc020376c:	00003697          	auipc	a3,0x3
ffffffffc0203770:	fa468693          	addi	a3,a3,-92 # ffffffffc0206710 <default_pmm_manager+0xb30>
ffffffffc0203774:	00002617          	auipc	a2,0x2
ffffffffc0203778:	0d460613          	addi	a2,a2,212 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020377c:	06000593          	li	a1,96
ffffffffc0203780:	00003517          	auipc	a0,0x3
ffffffffc0203784:	ed850513          	addi	a0,a0,-296 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc0203788:	cc9fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==5);
ffffffffc020378c:	00003697          	auipc	a3,0x3
ffffffffc0203790:	f8468693          	addi	a3,a3,-124 # ffffffffc0206710 <default_pmm_manager+0xb30>
ffffffffc0203794:	00002617          	auipc	a2,0x2
ffffffffc0203798:	0b460613          	addi	a2,a2,180 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020379c:	05d00593          	li	a1,93
ffffffffc02037a0:	00003517          	auipc	a0,0x3
ffffffffc02037a4:	eb850513          	addi	a0,a0,-328 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc02037a8:	ca9fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc02037ac:	00003697          	auipc	a3,0x3
ffffffffc02037b0:	d2468693          	addi	a3,a3,-732 # ffffffffc02064d0 <default_pmm_manager+0x8f0>
ffffffffc02037b4:	00002617          	auipc	a2,0x2
ffffffffc02037b8:	09460613          	addi	a2,a2,148 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02037bc:	05a00593          	li	a1,90
ffffffffc02037c0:	00003517          	auipc	a0,0x3
ffffffffc02037c4:	e9850513          	addi	a0,a0,-360 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc02037c8:	c89fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc02037cc:	00003697          	auipc	a3,0x3
ffffffffc02037d0:	d0468693          	addi	a3,a3,-764 # ffffffffc02064d0 <default_pmm_manager+0x8f0>
ffffffffc02037d4:	00002617          	auipc	a2,0x2
ffffffffc02037d8:	07460613          	addi	a2,a2,116 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02037dc:	05700593          	li	a1,87
ffffffffc02037e0:	00003517          	auipc	a0,0x3
ffffffffc02037e4:	e7850513          	addi	a0,a0,-392 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc02037e8:	c69fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc02037ec:	00003697          	auipc	a3,0x3
ffffffffc02037f0:	ce468693          	addi	a3,a3,-796 # ffffffffc02064d0 <default_pmm_manager+0x8f0>
ffffffffc02037f4:	00002617          	auipc	a2,0x2
ffffffffc02037f8:	05460613          	addi	a2,a2,84 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02037fc:	05400593          	li	a1,84
ffffffffc0203800:	00003517          	auipc	a0,0x3
ffffffffc0203804:	e5850513          	addi	a0,a0,-424 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc0203808:	c49fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020380c <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020380c:	751c                	ld	a5,40(a0)
{
ffffffffc020380e:	1141                	addi	sp,sp,-16
ffffffffc0203810:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203812:	cf91                	beqz	a5,ffffffffc020382e <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203814:	ee0d                	bnez	a2,ffffffffc020384e <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203816:	679c                	ld	a5,8(a5)
}
ffffffffc0203818:	60a2                	ld	ra,8(sp)
ffffffffc020381a:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc020381c:	6394                	ld	a3,0(a5)
ffffffffc020381e:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203820:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203824:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203826:	e314                	sd	a3,0(a4)
ffffffffc0203828:	e19c                	sd	a5,0(a1)
}
ffffffffc020382a:	0141                	addi	sp,sp,16
ffffffffc020382c:	8082                	ret
         assert(head != NULL);
ffffffffc020382e:	00003697          	auipc	a3,0x3
ffffffffc0203832:	f9a68693          	addi	a3,a3,-102 # ffffffffc02067c8 <default_pmm_manager+0xbe8>
ffffffffc0203836:	00002617          	auipc	a2,0x2
ffffffffc020383a:	01260613          	addi	a2,a2,18 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020383e:	04100593          	li	a1,65
ffffffffc0203842:	00003517          	auipc	a0,0x3
ffffffffc0203846:	e1650513          	addi	a0,a0,-490 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc020384a:	c07fc0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(in_tick==0);
ffffffffc020384e:	00003697          	auipc	a3,0x3
ffffffffc0203852:	f8a68693          	addi	a3,a3,-118 # ffffffffc02067d8 <default_pmm_manager+0xbf8>
ffffffffc0203856:	00002617          	auipc	a2,0x2
ffffffffc020385a:	ff260613          	addi	a2,a2,-14 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020385e:	04200593          	li	a1,66
ffffffffc0203862:	00003517          	auipc	a0,0x3
ffffffffc0203866:	df650513          	addi	a0,a0,-522 # ffffffffc0206658 <default_pmm_manager+0xa78>
ffffffffc020386a:	be7fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020386e <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020386e:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203872:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203874:	cb09                	beqz	a4,ffffffffc0203886 <_fifo_map_swappable+0x18>
ffffffffc0203876:	cb81                	beqz	a5,ffffffffc0203886 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203878:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc020387a:	e398                	sd	a4,0(a5)
}
ffffffffc020387c:	4501                	li	a0,0
ffffffffc020387e:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203880:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203882:	f614                	sd	a3,40(a2)
ffffffffc0203884:	8082                	ret
{
ffffffffc0203886:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203888:	00003697          	auipc	a3,0x3
ffffffffc020388c:	f2068693          	addi	a3,a3,-224 # ffffffffc02067a8 <default_pmm_manager+0xbc8>
ffffffffc0203890:	00002617          	auipc	a2,0x2
ffffffffc0203894:	fb860613          	addi	a2,a2,-72 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203898:	03200593          	li	a1,50
ffffffffc020389c:	00003517          	auipc	a0,0x3
ffffffffc02038a0:	dbc50513          	addi	a0,a0,-580 # ffffffffc0206658 <default_pmm_manager+0xa78>
{
ffffffffc02038a4:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02038a6:	babfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02038aa <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02038aa:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02038ac:	00003697          	auipc	a3,0x3
ffffffffc02038b0:	f5468693          	addi	a3,a3,-172 # ffffffffc0206800 <default_pmm_manager+0xc20>
ffffffffc02038b4:	00002617          	auipc	a2,0x2
ffffffffc02038b8:	f9460613          	addi	a2,a2,-108 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02038bc:	07e00593          	li	a1,126
ffffffffc02038c0:	00003517          	auipc	a0,0x3
ffffffffc02038c4:	f6050513          	addi	a0,a0,-160 # ffffffffc0206820 <default_pmm_manager+0xc40>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02038c8:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02038ca:	b87fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02038ce <mm_create>:
mm_create(void) {
ffffffffc02038ce:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02038d0:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02038d4:	e022                	sd	s0,0(sp)
ffffffffc02038d6:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02038d8:	936fe0ef          	jal	ra,ffffffffc0201a0e <kmalloc>
ffffffffc02038dc:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02038de:	c115                	beqz	a0,ffffffffc0203902 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02038e0:	00012797          	auipc	a5,0x12
ffffffffc02038e4:	bc078793          	addi	a5,a5,-1088 # ffffffffc02154a0 <swap_init_ok>
ffffffffc02038e8:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02038ea:	e408                	sd	a0,8(s0)
ffffffffc02038ec:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02038ee:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02038f2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02038f6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02038fa:	2781                	sext.w	a5,a5
ffffffffc02038fc:	eb81                	bnez	a5,ffffffffc020390c <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc02038fe:	02053423          	sd	zero,40(a0)
}
ffffffffc0203902:	8522                	mv	a0,s0
ffffffffc0203904:	60a2                	ld	ra,8(sp)
ffffffffc0203906:	6402                	ld	s0,0(sp)
ffffffffc0203908:	0141                	addi	sp,sp,16
ffffffffc020390a:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020390c:	a09ff0ef          	jal	ra,ffffffffc0203314 <swap_init_mm>
}
ffffffffc0203910:	8522                	mv	a0,s0
ffffffffc0203912:	60a2                	ld	ra,8(sp)
ffffffffc0203914:	6402                	ld	s0,0(sp)
ffffffffc0203916:	0141                	addi	sp,sp,16
ffffffffc0203918:	8082                	ret

ffffffffc020391a <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020391a:	1101                	addi	sp,sp,-32
ffffffffc020391c:	e04a                	sd	s2,0(sp)
ffffffffc020391e:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203920:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0203924:	e822                	sd	s0,16(sp)
ffffffffc0203926:	e426                	sd	s1,8(sp)
ffffffffc0203928:	ec06                	sd	ra,24(sp)
ffffffffc020392a:	84ae                	mv	s1,a1
ffffffffc020392c:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020392e:	8e0fe0ef          	jal	ra,ffffffffc0201a0e <kmalloc>
    if (vma != NULL) {
ffffffffc0203932:	c509                	beqz	a0,ffffffffc020393c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203934:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203938:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020393a:	cd00                	sw	s0,24(a0)
}
ffffffffc020393c:	60e2                	ld	ra,24(sp)
ffffffffc020393e:	6442                	ld	s0,16(sp)
ffffffffc0203940:	64a2                	ld	s1,8(sp)
ffffffffc0203942:	6902                	ld	s2,0(sp)
ffffffffc0203944:	6105                	addi	sp,sp,32
ffffffffc0203946:	8082                	ret

ffffffffc0203948 <find_vma>:
    if (mm != NULL) {
ffffffffc0203948:	c51d                	beqz	a0,ffffffffc0203976 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc020394a:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020394c:	c781                	beqz	a5,ffffffffc0203954 <find_vma+0xc>
ffffffffc020394e:	6798                	ld	a4,8(a5)
ffffffffc0203950:	02e5f663          	bleu	a4,a1,ffffffffc020397c <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0203954:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0203956:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203958:	00f50f63          	beq	a0,a5,ffffffffc0203976 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020395c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203960:	fee5ebe3          	bltu	a1,a4,ffffffffc0203956 <find_vma+0xe>
ffffffffc0203964:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203968:	fee5f7e3          	bleu	a4,a1,ffffffffc0203956 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc020396c:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc020396e:	c781                	beqz	a5,ffffffffc0203976 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0203970:	e91c                	sd	a5,16(a0)
}
ffffffffc0203972:	853e                	mv	a0,a5
ffffffffc0203974:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0203976:	4781                	li	a5,0
}
ffffffffc0203978:	853e                	mv	a0,a5
ffffffffc020397a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020397c:	6b98                	ld	a4,16(a5)
ffffffffc020397e:	fce5fbe3          	bleu	a4,a1,ffffffffc0203954 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0203982:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0203984:	b7fd                	j	ffffffffc0203972 <find_vma+0x2a>

ffffffffc0203986 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203986:	6590                	ld	a2,8(a1)
ffffffffc0203988:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020398c:	1141                	addi	sp,sp,-16
ffffffffc020398e:	e406                	sd	ra,8(sp)
ffffffffc0203990:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203992:	01066863          	bltu	a2,a6,ffffffffc02039a2 <insert_vma_struct+0x1c>
ffffffffc0203996:	a8b9                	j	ffffffffc02039f4 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203998:	fe87b683          	ld	a3,-24(a5)
ffffffffc020399c:	04d66763          	bltu	a2,a3,ffffffffc02039ea <insert_vma_struct+0x64>
ffffffffc02039a0:	873e                	mv	a4,a5
ffffffffc02039a2:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02039a4:	fef51ae3          	bne	a0,a5,ffffffffc0203998 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02039a8:	02a70463          	beq	a4,a0,ffffffffc02039d0 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02039ac:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02039b0:	fe873883          	ld	a7,-24(a4)
ffffffffc02039b4:	08d8f063          	bleu	a3,a7,ffffffffc0203a34 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02039b8:	04d66e63          	bltu	a2,a3,ffffffffc0203a14 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02039bc:	00f50a63          	beq	a0,a5,ffffffffc02039d0 <insert_vma_struct+0x4a>
ffffffffc02039c0:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02039c4:	0506e863          	bltu	a3,a6,ffffffffc0203a14 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02039c8:	ff07b603          	ld	a2,-16(a5)
ffffffffc02039cc:	02c6f263          	bleu	a2,a3,ffffffffc02039f0 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02039d0:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02039d2:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02039d4:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02039d8:	e390                	sd	a2,0(a5)
ffffffffc02039da:	e710                	sd	a2,8(a4)
}
ffffffffc02039dc:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02039de:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02039e0:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02039e2:	2685                	addiw	a3,a3,1
ffffffffc02039e4:	d114                	sw	a3,32(a0)
}
ffffffffc02039e6:	0141                	addi	sp,sp,16
ffffffffc02039e8:	8082                	ret
    if (le_prev != list) {
ffffffffc02039ea:	fca711e3          	bne	a4,a0,ffffffffc02039ac <insert_vma_struct+0x26>
ffffffffc02039ee:	bfd9                	j	ffffffffc02039c4 <insert_vma_struct+0x3e>
ffffffffc02039f0:	ebbff0ef          	jal	ra,ffffffffc02038aa <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02039f4:	00003697          	auipc	a3,0x3
ffffffffc02039f8:	edc68693          	addi	a3,a3,-292 # ffffffffc02068d0 <default_pmm_manager+0xcf0>
ffffffffc02039fc:	00002617          	auipc	a2,0x2
ffffffffc0203a00:	e4c60613          	addi	a2,a2,-436 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203a04:	08500593          	li	a1,133
ffffffffc0203a08:	00003517          	auipc	a0,0x3
ffffffffc0203a0c:	e1850513          	addi	a0,a0,-488 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203a10:	a41fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203a14:	00003697          	auipc	a3,0x3
ffffffffc0203a18:	efc68693          	addi	a3,a3,-260 # ffffffffc0206910 <default_pmm_manager+0xd30>
ffffffffc0203a1c:	00002617          	auipc	a2,0x2
ffffffffc0203a20:	e2c60613          	addi	a2,a2,-468 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203a24:	07d00593          	li	a1,125
ffffffffc0203a28:	00003517          	auipc	a0,0x3
ffffffffc0203a2c:	df850513          	addi	a0,a0,-520 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203a30:	a21fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203a34:	00003697          	auipc	a3,0x3
ffffffffc0203a38:	ebc68693          	addi	a3,a3,-324 # ffffffffc02068f0 <default_pmm_manager+0xd10>
ffffffffc0203a3c:	00002617          	auipc	a2,0x2
ffffffffc0203a40:	e0c60613          	addi	a2,a2,-500 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203a44:	07c00593          	li	a1,124
ffffffffc0203a48:	00003517          	auipc	a0,0x3
ffffffffc0203a4c:	dd850513          	addi	a0,a0,-552 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203a50:	a01fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203a54 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203a54:	1141                	addi	sp,sp,-16
ffffffffc0203a56:	e022                	sd	s0,0(sp)
ffffffffc0203a58:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203a5a:	6508                	ld	a0,8(a0)
ffffffffc0203a5c:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203a5e:	00a40c63          	beq	s0,a0,ffffffffc0203a76 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a62:	6118                	ld	a4,0(a0)
ffffffffc0203a64:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203a66:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a68:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a6a:	e398                	sd	a4,0(a5)
ffffffffc0203a6c:	85efe0ef          	jal	ra,ffffffffc0201aca <kfree>
    return listelm->next;
ffffffffc0203a70:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203a72:	fea418e3          	bne	s0,a0,ffffffffc0203a62 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0203a76:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203a78:	6402                	ld	s0,0(sp)
ffffffffc0203a7a:	60a2                	ld	ra,8(sp)
ffffffffc0203a7c:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0203a7e:	84cfe06f          	j	ffffffffc0201aca <kfree>

ffffffffc0203a82 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203a82:	7139                	addi	sp,sp,-64
ffffffffc0203a84:	f822                	sd	s0,48(sp)
ffffffffc0203a86:	f426                	sd	s1,40(sp)
ffffffffc0203a88:	fc06                	sd	ra,56(sp)
ffffffffc0203a8a:	f04a                	sd	s2,32(sp)
ffffffffc0203a8c:	ec4e                	sd	s3,24(sp)
ffffffffc0203a8e:	e852                	sd	s4,16(sp)
ffffffffc0203a90:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc0203a92:	e3dff0ef          	jal	ra,ffffffffc02038ce <mm_create>
    assert(mm != NULL);
ffffffffc0203a96:	842a                	mv	s0,a0
ffffffffc0203a98:	03200493          	li	s1,50
ffffffffc0203a9c:	e919                	bnez	a0,ffffffffc0203ab2 <vmm_init+0x30>
ffffffffc0203a9e:	a989                	j	ffffffffc0203ef0 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0203aa0:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203aa2:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203aa4:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203aa8:	14ed                	addi	s1,s1,-5
ffffffffc0203aaa:	8522                	mv	a0,s0
ffffffffc0203aac:	edbff0ef          	jal	ra,ffffffffc0203986 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203ab0:	c88d                	beqz	s1,ffffffffc0203ae2 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ab2:	03000513          	li	a0,48
ffffffffc0203ab6:	f59fd0ef          	jal	ra,ffffffffc0201a0e <kmalloc>
ffffffffc0203aba:	85aa                	mv	a1,a0
ffffffffc0203abc:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203ac0:	f165                	bnez	a0,ffffffffc0203aa0 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0203ac2:	00003697          	auipc	a3,0x3
ffffffffc0203ac6:	8ce68693          	addi	a3,a3,-1842 # ffffffffc0206390 <default_pmm_manager+0x7b0>
ffffffffc0203aca:	00002617          	auipc	a2,0x2
ffffffffc0203ace:	d7e60613          	addi	a2,a2,-642 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203ad2:	0c900593          	li	a1,201
ffffffffc0203ad6:	00003517          	auipc	a0,0x3
ffffffffc0203ada:	d4a50513          	addi	a0,a0,-694 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203ade:	973fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0203ae2:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203ae6:	1f900913          	li	s2,505
ffffffffc0203aea:	a819                	j	ffffffffc0203b00 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0203aec:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203aee:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203af0:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203af4:	0495                	addi	s1,s1,5
ffffffffc0203af6:	8522                	mv	a0,s0
ffffffffc0203af8:	e8fff0ef          	jal	ra,ffffffffc0203986 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203afc:	03248a63          	beq	s1,s2,ffffffffc0203b30 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203b00:	03000513          	li	a0,48
ffffffffc0203b04:	f0bfd0ef          	jal	ra,ffffffffc0201a0e <kmalloc>
ffffffffc0203b08:	85aa                	mv	a1,a0
ffffffffc0203b0a:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203b0e:	fd79                	bnez	a0,ffffffffc0203aec <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0203b10:	00003697          	auipc	a3,0x3
ffffffffc0203b14:	88068693          	addi	a3,a3,-1920 # ffffffffc0206390 <default_pmm_manager+0x7b0>
ffffffffc0203b18:	00002617          	auipc	a2,0x2
ffffffffc0203b1c:	d3060613          	addi	a2,a2,-720 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203b20:	0cf00593          	li	a1,207
ffffffffc0203b24:	00003517          	auipc	a0,0x3
ffffffffc0203b28:	cfc50513          	addi	a0,a0,-772 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203b2c:	925fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0203b30:	6418                	ld	a4,8(s0)
ffffffffc0203b32:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203b34:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203b38:	2ee40063          	beq	s0,a4,ffffffffc0203e18 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b3c:	fe873603          	ld	a2,-24(a4)
ffffffffc0203b40:	ffe78693          	addi	a3,a5,-2
ffffffffc0203b44:	24d61a63          	bne	a2,a3,ffffffffc0203d98 <vmm_init+0x316>
ffffffffc0203b48:	ff073683          	ld	a3,-16(a4)
ffffffffc0203b4c:	24f69663          	bne	a3,a5,ffffffffc0203d98 <vmm_init+0x316>
ffffffffc0203b50:	0795                	addi	a5,a5,5
ffffffffc0203b52:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203b54:	feb792e3          	bne	a5,a1,ffffffffc0203b38 <vmm_init+0xb6>
ffffffffc0203b58:	491d                	li	s2,7
ffffffffc0203b5a:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203b5c:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203b60:	85a6                	mv	a1,s1
ffffffffc0203b62:	8522                	mv	a0,s0
ffffffffc0203b64:	de5ff0ef          	jal	ra,ffffffffc0203948 <find_vma>
ffffffffc0203b68:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0203b6a:	30050763          	beqz	a0,ffffffffc0203e78 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203b6e:	00148593          	addi	a1,s1,1
ffffffffc0203b72:	8522                	mv	a0,s0
ffffffffc0203b74:	dd5ff0ef          	jal	ra,ffffffffc0203948 <find_vma>
ffffffffc0203b78:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203b7a:	2c050f63          	beqz	a0,ffffffffc0203e58 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203b7e:	85ca                	mv	a1,s2
ffffffffc0203b80:	8522                	mv	a0,s0
ffffffffc0203b82:	dc7ff0ef          	jal	ra,ffffffffc0203948 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203b86:	2a051963          	bnez	a0,ffffffffc0203e38 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203b8a:	00348593          	addi	a1,s1,3
ffffffffc0203b8e:	8522                	mv	a0,s0
ffffffffc0203b90:	db9ff0ef          	jal	ra,ffffffffc0203948 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203b94:	32051263          	bnez	a0,ffffffffc0203eb8 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203b98:	00448593          	addi	a1,s1,4
ffffffffc0203b9c:	8522                	mv	a0,s0
ffffffffc0203b9e:	dabff0ef          	jal	ra,ffffffffc0203948 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203ba2:	2e051b63          	bnez	a0,ffffffffc0203e98 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203ba6:	008a3783          	ld	a5,8(s4)
ffffffffc0203baa:	20979763          	bne	a5,s1,ffffffffc0203db8 <vmm_init+0x336>
ffffffffc0203bae:	010a3783          	ld	a5,16(s4)
ffffffffc0203bb2:	21279363          	bne	a5,s2,ffffffffc0203db8 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203bb6:	0089b783          	ld	a5,8(s3)
ffffffffc0203bba:	20979f63          	bne	a5,s1,ffffffffc0203dd8 <vmm_init+0x356>
ffffffffc0203bbe:	0109b783          	ld	a5,16(s3)
ffffffffc0203bc2:	21279b63          	bne	a5,s2,ffffffffc0203dd8 <vmm_init+0x356>
ffffffffc0203bc6:	0495                	addi	s1,s1,5
ffffffffc0203bc8:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203bca:	f9549be3          	bne	s1,s5,ffffffffc0203b60 <vmm_init+0xde>
ffffffffc0203bce:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203bd0:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203bd2:	85a6                	mv	a1,s1
ffffffffc0203bd4:	8522                	mv	a0,s0
ffffffffc0203bd6:	d73ff0ef          	jal	ra,ffffffffc0203948 <find_vma>
ffffffffc0203bda:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203bde:	c90d                	beqz	a0,ffffffffc0203c10 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203be0:	6914                	ld	a3,16(a0)
ffffffffc0203be2:	6510                	ld	a2,8(a0)
ffffffffc0203be4:	00003517          	auipc	a0,0x3
ffffffffc0203be8:	e4c50513          	addi	a0,a0,-436 # ffffffffc0206a30 <default_pmm_manager+0xe50>
ffffffffc0203bec:	da2fc0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203bf0:	00003697          	auipc	a3,0x3
ffffffffc0203bf4:	e6868693          	addi	a3,a3,-408 # ffffffffc0206a58 <default_pmm_manager+0xe78>
ffffffffc0203bf8:	00002617          	auipc	a2,0x2
ffffffffc0203bfc:	c5060613          	addi	a2,a2,-944 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203c00:	0f100593          	li	a1,241
ffffffffc0203c04:	00003517          	auipc	a0,0x3
ffffffffc0203c08:	c1c50513          	addi	a0,a0,-996 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203c0c:	845fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0203c10:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0203c12:	fd2490e3          	bne	s1,s2,ffffffffc0203bd2 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0203c16:	8522                	mv	a0,s0
ffffffffc0203c18:	e3dff0ef          	jal	ra,ffffffffc0203a54 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203c1c:	00003517          	auipc	a0,0x3
ffffffffc0203c20:	e5450513          	addi	a0,a0,-428 # ffffffffc0206a70 <default_pmm_manager+0xe90>
ffffffffc0203c24:	d6afc0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203c28:	8b0fe0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>
ffffffffc0203c2c:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0203c2e:	ca1ff0ef          	jal	ra,ffffffffc02038ce <mm_create>
ffffffffc0203c32:	00012797          	auipc	a5,0x12
ffffffffc0203c36:	9aa7b723          	sd	a0,-1618(a5) # ffffffffc02155e0 <check_mm_struct>
ffffffffc0203c3a:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0203c3c:	36050663          	beqz	a0,ffffffffc0203fa8 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203c40:	00012797          	auipc	a5,0x12
ffffffffc0203c44:	84878793          	addi	a5,a5,-1976 # ffffffffc0215488 <boot_pgdir>
ffffffffc0203c48:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0203c4c:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203c50:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203c54:	2c079e63          	bnez	a5,ffffffffc0203f30 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203c58:	03000513          	li	a0,48
ffffffffc0203c5c:	db3fd0ef          	jal	ra,ffffffffc0201a0e <kmalloc>
ffffffffc0203c60:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0203c62:	18050b63          	beqz	a0,ffffffffc0203df8 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0203c66:	002007b7          	lui	a5,0x200
ffffffffc0203c6a:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0203c6c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203c6e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203c70:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203c72:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0203c74:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203c78:	d0fff0ef          	jal	ra,ffffffffc0203986 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c7c:	10000593          	li	a1,256
ffffffffc0203c80:	8526                	mv	a0,s1
ffffffffc0203c82:	cc7ff0ef          	jal	ra,ffffffffc0203948 <find_vma>
ffffffffc0203c86:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203c8a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c8e:	2ca41163          	bne	s0,a0,ffffffffc0203f50 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0203c92:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203c96:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203c98:	fee79de3          	bne	a5,a4,ffffffffc0203c92 <vmm_init+0x210>
        sum += i;
ffffffffc0203c9c:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203c9e:	10000793          	li	a5,256
        sum += i;
ffffffffc0203ca2:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203ca6:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203caa:	0007c683          	lbu	a3,0(a5)
ffffffffc0203cae:	0785                	addi	a5,a5,1
ffffffffc0203cb0:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203cb2:	fec79ce3          	bne	a5,a2,ffffffffc0203caa <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0203cb6:	2c071963          	bnez	a4,ffffffffc0203f88 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cba:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203cbe:	00011a97          	auipc	s5,0x11
ffffffffc0203cc2:	7d2a8a93          	addi	s5,s5,2002 # ffffffffc0215490 <npage>
ffffffffc0203cc6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cca:	078a                	slli	a5,a5,0x2
ffffffffc0203ccc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203cce:	20e7f563          	bleu	a4,a5,ffffffffc0203ed8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cd2:	00003697          	auipc	a3,0x3
ffffffffc0203cd6:	2b668693          	addi	a3,a3,694 # ffffffffc0206f88 <nbase>
ffffffffc0203cda:	0006ba03          	ld	s4,0(a3)
ffffffffc0203cde:	414786b3          	sub	a3,a5,s4
ffffffffc0203ce2:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203ce4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203ce6:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0203ce8:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203cea:	83b1                	srli	a5,a5,0xc
ffffffffc0203cec:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cee:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203cf0:	28e7f063          	bleu	a4,a5,ffffffffc0203f70 <vmm_init+0x4ee>
ffffffffc0203cf4:	00011797          	auipc	a5,0x11
ffffffffc0203cf8:	7fc78793          	addi	a5,a5,2044 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0203cfc:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203cfe:	4581                	li	a1,0
ffffffffc0203d00:	854a                	mv	a0,s2
ffffffffc0203d02:	9436                	add	s0,s0,a3
ffffffffc0203d04:	a48fe0ef          	jal	ra,ffffffffc0201f4c <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d08:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203d0a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d0e:	078a                	slli	a5,a5,0x2
ffffffffc0203d10:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d12:	1ce7f363          	bleu	a4,a5,ffffffffc0203ed8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d16:	00011417          	auipc	s0,0x11
ffffffffc0203d1a:	7ea40413          	addi	s0,s0,2026 # ffffffffc0215500 <pages>
ffffffffc0203d1e:	6008                	ld	a0,0(s0)
ffffffffc0203d20:	414787b3          	sub	a5,a5,s4
ffffffffc0203d24:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203d26:	953e                	add	a0,a0,a5
ffffffffc0203d28:	4585                	li	a1,1
ffffffffc0203d2a:	f69fd0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d2e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203d32:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203d36:	078a                	slli	a5,a5,0x2
ffffffffc0203d38:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203d3a:	18e7ff63          	bleu	a4,a5,ffffffffc0203ed8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d3e:	6008                	ld	a0,0(s0)
ffffffffc0203d40:	414787b3          	sub	a5,a5,s4
ffffffffc0203d44:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203d46:	4585                	li	a1,1
ffffffffc0203d48:	953e                	add	a0,a0,a5
ffffffffc0203d4a:	f49fd0ef          	jal	ra,ffffffffc0201c92 <free_pages>
    pgdir[0] = 0;
ffffffffc0203d4e:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203d52:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0203d56:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0203d5a:	8526                	mv	a0,s1
ffffffffc0203d5c:	cf9ff0ef          	jal	ra,ffffffffc0203a54 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0203d60:	00012797          	auipc	a5,0x12
ffffffffc0203d64:	8807b023          	sd	zero,-1920(a5) # ffffffffc02155e0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d68:	f71fd0ef          	jal	ra,ffffffffc0201cd8 <nr_free_pages>
ffffffffc0203d6c:	1aa99263          	bne	s3,a0,ffffffffc0203f10 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203d70:	00003517          	auipc	a0,0x3
ffffffffc0203d74:	d9050513          	addi	a0,a0,-624 # ffffffffc0206b00 <default_pmm_manager+0xf20>
ffffffffc0203d78:	c16fc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203d7c:	7442                	ld	s0,48(sp)
ffffffffc0203d7e:	70e2                	ld	ra,56(sp)
ffffffffc0203d80:	74a2                	ld	s1,40(sp)
ffffffffc0203d82:	7902                	ld	s2,32(sp)
ffffffffc0203d84:	69e2                	ld	s3,24(sp)
ffffffffc0203d86:	6a42                	ld	s4,16(sp)
ffffffffc0203d88:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d8a:	00003517          	auipc	a0,0x3
ffffffffc0203d8e:	d9650513          	addi	a0,a0,-618 # ffffffffc0206b20 <default_pmm_manager+0xf40>
}
ffffffffc0203d92:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d94:	bfafc06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203d98:	00003697          	auipc	a3,0x3
ffffffffc0203d9c:	bb068693          	addi	a3,a3,-1104 # ffffffffc0206948 <default_pmm_manager+0xd68>
ffffffffc0203da0:	00002617          	auipc	a2,0x2
ffffffffc0203da4:	aa860613          	addi	a2,a2,-1368 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203da8:	0d800593          	li	a1,216
ffffffffc0203dac:	00003517          	auipc	a0,0x3
ffffffffc0203db0:	a7450513          	addi	a0,a0,-1420 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203db4:	e9cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203db8:	00003697          	auipc	a3,0x3
ffffffffc0203dbc:	c1868693          	addi	a3,a3,-1000 # ffffffffc02069d0 <default_pmm_manager+0xdf0>
ffffffffc0203dc0:	00002617          	auipc	a2,0x2
ffffffffc0203dc4:	a8860613          	addi	a2,a2,-1400 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203dc8:	0e800593          	li	a1,232
ffffffffc0203dcc:	00003517          	auipc	a0,0x3
ffffffffc0203dd0:	a5450513          	addi	a0,a0,-1452 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203dd4:	e7cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203dd8:	00003697          	auipc	a3,0x3
ffffffffc0203ddc:	c2868693          	addi	a3,a3,-984 # ffffffffc0206a00 <default_pmm_manager+0xe20>
ffffffffc0203de0:	00002617          	auipc	a2,0x2
ffffffffc0203de4:	a6860613          	addi	a2,a2,-1432 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203de8:	0e900593          	li	a1,233
ffffffffc0203dec:	00003517          	auipc	a0,0x3
ffffffffc0203df0:	a3450513          	addi	a0,a0,-1484 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203df4:	e5cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(vma != NULL);
ffffffffc0203df8:	00002697          	auipc	a3,0x2
ffffffffc0203dfc:	59868693          	addi	a3,a3,1432 # ffffffffc0206390 <default_pmm_manager+0x7b0>
ffffffffc0203e00:	00002617          	auipc	a2,0x2
ffffffffc0203e04:	a4860613          	addi	a2,a2,-1464 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203e08:	10800593          	li	a1,264
ffffffffc0203e0c:	00003517          	auipc	a0,0x3
ffffffffc0203e10:	a1450513          	addi	a0,a0,-1516 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203e14:	e3cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203e18:	00003697          	auipc	a3,0x3
ffffffffc0203e1c:	b1868693          	addi	a3,a3,-1256 # ffffffffc0206930 <default_pmm_manager+0xd50>
ffffffffc0203e20:	00002617          	auipc	a2,0x2
ffffffffc0203e24:	a2860613          	addi	a2,a2,-1496 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203e28:	0d600593          	li	a1,214
ffffffffc0203e2c:	00003517          	auipc	a0,0x3
ffffffffc0203e30:	9f450513          	addi	a0,a0,-1548 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203e34:	e1cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma3 == NULL);
ffffffffc0203e38:	00003697          	auipc	a3,0x3
ffffffffc0203e3c:	b6868693          	addi	a3,a3,-1176 # ffffffffc02069a0 <default_pmm_manager+0xdc0>
ffffffffc0203e40:	00002617          	auipc	a2,0x2
ffffffffc0203e44:	a0860613          	addi	a2,a2,-1528 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203e48:	0e200593          	li	a1,226
ffffffffc0203e4c:	00003517          	auipc	a0,0x3
ffffffffc0203e50:	9d450513          	addi	a0,a0,-1580 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203e54:	dfcfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma2 != NULL);
ffffffffc0203e58:	00003697          	auipc	a3,0x3
ffffffffc0203e5c:	b3868693          	addi	a3,a3,-1224 # ffffffffc0206990 <default_pmm_manager+0xdb0>
ffffffffc0203e60:	00002617          	auipc	a2,0x2
ffffffffc0203e64:	9e860613          	addi	a2,a2,-1560 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203e68:	0e000593          	li	a1,224
ffffffffc0203e6c:	00003517          	auipc	a0,0x3
ffffffffc0203e70:	9b450513          	addi	a0,a0,-1612 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203e74:	ddcfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma1 != NULL);
ffffffffc0203e78:	00003697          	auipc	a3,0x3
ffffffffc0203e7c:	b0868693          	addi	a3,a3,-1272 # ffffffffc0206980 <default_pmm_manager+0xda0>
ffffffffc0203e80:	00002617          	auipc	a2,0x2
ffffffffc0203e84:	9c860613          	addi	a2,a2,-1592 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203e88:	0de00593          	li	a1,222
ffffffffc0203e8c:	00003517          	auipc	a0,0x3
ffffffffc0203e90:	99450513          	addi	a0,a0,-1644 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203e94:	dbcfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma5 == NULL);
ffffffffc0203e98:	00003697          	auipc	a3,0x3
ffffffffc0203e9c:	b2868693          	addi	a3,a3,-1240 # ffffffffc02069c0 <default_pmm_manager+0xde0>
ffffffffc0203ea0:	00002617          	auipc	a2,0x2
ffffffffc0203ea4:	9a860613          	addi	a2,a2,-1624 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203ea8:	0e600593          	li	a1,230
ffffffffc0203eac:	00003517          	auipc	a0,0x3
ffffffffc0203eb0:	97450513          	addi	a0,a0,-1676 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203eb4:	d9cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma4 == NULL);
ffffffffc0203eb8:	00003697          	auipc	a3,0x3
ffffffffc0203ebc:	af868693          	addi	a3,a3,-1288 # ffffffffc02069b0 <default_pmm_manager+0xdd0>
ffffffffc0203ec0:	00002617          	auipc	a2,0x2
ffffffffc0203ec4:	98860613          	addi	a2,a2,-1656 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203ec8:	0e400593          	li	a1,228
ffffffffc0203ecc:	00003517          	auipc	a0,0x3
ffffffffc0203ed0:	95450513          	addi	a0,a0,-1708 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203ed4:	d7cfc0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203ed8:	00002617          	auipc	a2,0x2
ffffffffc0203edc:	db860613          	addi	a2,a2,-584 # ffffffffc0205c90 <default_pmm_manager+0xb0>
ffffffffc0203ee0:	06200593          	li	a1,98
ffffffffc0203ee4:	00002517          	auipc	a0,0x2
ffffffffc0203ee8:	d7450513          	addi	a0,a0,-652 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc0203eec:	d64fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(mm != NULL);
ffffffffc0203ef0:	00002697          	auipc	a3,0x2
ffffffffc0203ef4:	46868693          	addi	a3,a3,1128 # ffffffffc0206358 <default_pmm_manager+0x778>
ffffffffc0203ef8:	00002617          	auipc	a2,0x2
ffffffffc0203efc:	95060613          	addi	a2,a2,-1712 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203f00:	0c200593          	li	a1,194
ffffffffc0203f04:	00003517          	auipc	a0,0x3
ffffffffc0203f08:	91c50513          	addi	a0,a0,-1764 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203f0c:	d44fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203f10:	00003697          	auipc	a3,0x3
ffffffffc0203f14:	bc868693          	addi	a3,a3,-1080 # ffffffffc0206ad8 <default_pmm_manager+0xef8>
ffffffffc0203f18:	00002617          	auipc	a2,0x2
ffffffffc0203f1c:	93060613          	addi	a2,a2,-1744 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203f20:	12400593          	li	a1,292
ffffffffc0203f24:	00003517          	auipc	a0,0x3
ffffffffc0203f28:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203f2c:	d24fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203f30:	00002697          	auipc	a3,0x2
ffffffffc0203f34:	45068693          	addi	a3,a3,1104 # ffffffffc0206380 <default_pmm_manager+0x7a0>
ffffffffc0203f38:	00002617          	auipc	a2,0x2
ffffffffc0203f3c:	91060613          	addi	a2,a2,-1776 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203f40:	10500593          	li	a1,261
ffffffffc0203f44:	00003517          	auipc	a0,0x3
ffffffffc0203f48:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203f4c:	d04fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203f50:	00003697          	auipc	a3,0x3
ffffffffc0203f54:	b5868693          	addi	a3,a3,-1192 # ffffffffc0206aa8 <default_pmm_manager+0xec8>
ffffffffc0203f58:	00002617          	auipc	a2,0x2
ffffffffc0203f5c:	8f060613          	addi	a2,a2,-1808 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203f60:	10d00593          	li	a1,269
ffffffffc0203f64:	00003517          	auipc	a0,0x3
ffffffffc0203f68:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203f6c:	ce4fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203f70:	00002617          	auipc	a2,0x2
ffffffffc0203f74:	cc060613          	addi	a2,a2,-832 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc0203f78:	06900593          	li	a1,105
ffffffffc0203f7c:	00002517          	auipc	a0,0x2
ffffffffc0203f80:	cdc50513          	addi	a0,a0,-804 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc0203f84:	cccfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(sum == 0);
ffffffffc0203f88:	00003697          	auipc	a3,0x3
ffffffffc0203f8c:	b4068693          	addi	a3,a3,-1216 # ffffffffc0206ac8 <default_pmm_manager+0xee8>
ffffffffc0203f90:	00002617          	auipc	a2,0x2
ffffffffc0203f94:	8b860613          	addi	a2,a2,-1864 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203f98:	11700593          	li	a1,279
ffffffffc0203f9c:	00003517          	auipc	a0,0x3
ffffffffc0203fa0:	88450513          	addi	a0,a0,-1916 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203fa4:	cacfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203fa8:	00003697          	auipc	a3,0x3
ffffffffc0203fac:	ae868693          	addi	a3,a3,-1304 # ffffffffc0206a90 <default_pmm_manager+0xeb0>
ffffffffc0203fb0:	00002617          	auipc	a2,0x2
ffffffffc0203fb4:	89860613          	addi	a2,a2,-1896 # ffffffffc0205848 <commands+0x8d8>
ffffffffc0203fb8:	10100593          	li	a1,257
ffffffffc0203fbc:	00003517          	auipc	a0,0x3
ffffffffc0203fc0:	86450513          	addi	a0,a0,-1948 # ffffffffc0206820 <default_pmm_manager+0xc40>
ffffffffc0203fc4:	c8cfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203fc8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203fc8:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203fca:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203fcc:	f022                	sd	s0,32(sp)
ffffffffc0203fce:	ec26                	sd	s1,24(sp)
ffffffffc0203fd0:	f406                	sd	ra,40(sp)
ffffffffc0203fd2:	e84a                	sd	s2,16(sp)
ffffffffc0203fd4:	8432                	mv	s0,a2
ffffffffc0203fd6:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203fd8:	971ff0ef          	jal	ra,ffffffffc0203948 <find_vma>

    pgfault_num++;
ffffffffc0203fdc:	00011797          	auipc	a5,0x11
ffffffffc0203fe0:	4c878793          	addi	a5,a5,1224 # ffffffffc02154a4 <pgfault_num>
ffffffffc0203fe4:	439c                	lw	a5,0(a5)
ffffffffc0203fe6:	2785                	addiw	a5,a5,1
ffffffffc0203fe8:	00011717          	auipc	a4,0x11
ffffffffc0203fec:	4af72e23          	sw	a5,1212(a4) # ffffffffc02154a4 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203ff0:	c951                	beqz	a0,ffffffffc0204084 <do_pgfault+0xbc>
ffffffffc0203ff2:	651c                	ld	a5,8(a0)
ffffffffc0203ff4:	08f46863          	bltu	s0,a5,ffffffffc0204084 <do_pgfault+0xbc>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203ff8:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203ffa:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203ffc:	8b89                	andi	a5,a5,2
ffffffffc0203ffe:	e3b5                	bnez	a5,ffffffffc0204062 <do_pgfault+0x9a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204000:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204002:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204004:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204006:	85a2                	mv	a1,s0
ffffffffc0204008:	4605                	li	a2,1
ffffffffc020400a:	d0ffd0ef          	jal	ra,ffffffffc0201d18 <get_pte>
ffffffffc020400e:	cd41                	beqz	a0,ffffffffc02040a6 <do_pgfault+0xde>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204010:	610c                	ld	a1,0(a0)
ffffffffc0204012:	c9b1                	beqz	a1,ffffffffc0204066 <do_pgfault+0x9e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0204014:	00011797          	auipc	a5,0x11
ffffffffc0204018:	48c78793          	addi	a5,a5,1164 # ffffffffc02154a0 <swap_init_ok>
ffffffffc020401c:	439c                	lw	a5,0(a5)
ffffffffc020401e:	2781                	sext.w	a5,a5
ffffffffc0204020:	cbbd                	beqz	a5,ffffffffc0204096 <do_pgfault+0xce>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm, addr, &page);
ffffffffc0204022:	85a2                	mv	a1,s0
ffffffffc0204024:	0030                	addi	a2,sp,8
ffffffffc0204026:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204028:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc020402a:	c1eff0ef          	jal	ra,ffffffffc0203448 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc020402e:	65a2                	ld	a1,8(sp)
ffffffffc0204030:	6c88                	ld	a0,24(s1)
ffffffffc0204032:	86ca                	mv	a3,s2
ffffffffc0204034:	8622                	mv	a2,s0
ffffffffc0204036:	f8bfd0ef          	jal	ra,ffffffffc0201fc0 <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm,addr,page,swap_in);
ffffffffc020403a:	6622                	ld	a2,8(sp)
ffffffffc020403c:	fffff697          	auipc	a3,0xfffff
ffffffffc0204040:	40c68693          	addi	a3,a3,1036 # ffffffffc0203448 <swap_in>
ffffffffc0204044:	2681                	sext.w	a3,a3
ffffffffc0204046:	85a2                	mv	a1,s0
ffffffffc0204048:	8526                	mv	a0,s1
ffffffffc020404a:	adaff0ef          	jal	ra,ffffffffc0203324 <swap_map_swappable>

            
            page->pra_vaddr = addr;
ffffffffc020404e:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0204050:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0204052:	ff00                	sd	s0,56(a4)
failed:
    return ret;
}
ffffffffc0204054:	70a2                	ld	ra,40(sp)
ffffffffc0204056:	7402                	ld	s0,32(sp)
ffffffffc0204058:	64e2                	ld	s1,24(sp)
ffffffffc020405a:	6942                	ld	s2,16(sp)
ffffffffc020405c:	853e                	mv	a0,a5
ffffffffc020405e:	6145                	addi	sp,sp,48
ffffffffc0204060:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204062:	495d                	li	s2,23
ffffffffc0204064:	bf71                	j	ffffffffc0204000 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204066:	6c88                	ld	a0,24(s1)
ffffffffc0204068:	864a                	mv	a2,s2
ffffffffc020406a:	85a2                	mv	a1,s0
ffffffffc020406c:	aa3fe0ef          	jal	ra,ffffffffc0202b0e <pgdir_alloc_page>
   ret = 0;
ffffffffc0204070:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204072:	f16d                	bnez	a0,ffffffffc0204054 <do_pgfault+0x8c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204074:	00003517          	auipc	a0,0x3
ffffffffc0204078:	80c50513          	addi	a0,a0,-2036 # ffffffffc0206880 <default_pmm_manager+0xca0>
ffffffffc020407c:	912fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204080:	57f1                	li	a5,-4
            goto failed;
ffffffffc0204082:	bfc9                	j	ffffffffc0204054 <do_pgfault+0x8c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204084:	85a2                	mv	a1,s0
ffffffffc0204086:	00002517          	auipc	a0,0x2
ffffffffc020408a:	7aa50513          	addi	a0,a0,1962 # ffffffffc0206830 <default_pmm_manager+0xc50>
ffffffffc020408e:	900fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0204092:	57f5                	li	a5,-3
        goto failed;
ffffffffc0204094:	b7c1                	j	ffffffffc0204054 <do_pgfault+0x8c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204096:	00003517          	auipc	a0,0x3
ffffffffc020409a:	81250513          	addi	a0,a0,-2030 # ffffffffc02068a8 <default_pmm_manager+0xcc8>
ffffffffc020409e:	8f0fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc02040a2:	57f1                	li	a5,-4
            goto failed;
ffffffffc02040a4:	bf45                	j	ffffffffc0204054 <do_pgfault+0x8c>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc02040a6:	00002517          	auipc	a0,0x2
ffffffffc02040aa:	7ba50513          	addi	a0,a0,1978 # ffffffffc0206860 <default_pmm_manager+0xc80>
ffffffffc02040ae:	8e0fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc02040b2:	57f1                	li	a5,-4
        goto failed;
ffffffffc02040b4:	b745                	j	ffffffffc0204054 <do_pgfault+0x8c>

ffffffffc02040b6 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc02040b6:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02040b8:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc02040ba:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02040bc:	cc0fc0ef          	jal	ra,ffffffffc020057c <ide_device_valid>
ffffffffc02040c0:	cd01                	beqz	a0,ffffffffc02040d8 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02040c2:	4505                	li	a0,1
ffffffffc02040c4:	cbefc0ef          	jal	ra,ffffffffc0200582 <ide_device_size>
}
ffffffffc02040c8:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02040ca:	810d                	srli	a0,a0,0x3
ffffffffc02040cc:	00011797          	auipc	a5,0x11
ffffffffc02040d0:	4ca7b223          	sd	a0,1220(a5) # ffffffffc0215590 <max_swap_offset>
}
ffffffffc02040d4:	0141                	addi	sp,sp,16
ffffffffc02040d6:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc02040d8:	00003617          	auipc	a2,0x3
ffffffffc02040dc:	a6060613          	addi	a2,a2,-1440 # ffffffffc0206b38 <default_pmm_manager+0xf58>
ffffffffc02040e0:	45b5                	li	a1,13
ffffffffc02040e2:	00003517          	auipc	a0,0x3
ffffffffc02040e6:	a7650513          	addi	a0,a0,-1418 # ffffffffc0206b58 <default_pmm_manager+0xf78>
ffffffffc02040ea:	b66fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02040ee <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc02040ee:	1141                	addi	sp,sp,-16
ffffffffc02040f0:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040f2:	00855793          	srli	a5,a0,0x8
ffffffffc02040f6:	cfb9                	beqz	a5,ffffffffc0204154 <swapfs_read+0x66>
ffffffffc02040f8:	00011717          	auipc	a4,0x11
ffffffffc02040fc:	49870713          	addi	a4,a4,1176 # ffffffffc0215590 <max_swap_offset>
ffffffffc0204100:	6318                	ld	a4,0(a4)
ffffffffc0204102:	04e7f963          	bleu	a4,a5,ffffffffc0204154 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204106:	00011717          	auipc	a4,0x11
ffffffffc020410a:	3fa70713          	addi	a4,a4,1018 # ffffffffc0215500 <pages>
ffffffffc020410e:	6310                	ld	a2,0(a4)
ffffffffc0204110:	00003717          	auipc	a4,0x3
ffffffffc0204114:	e7870713          	addi	a4,a4,-392 # ffffffffc0206f88 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204118:	00011697          	auipc	a3,0x11
ffffffffc020411c:	37868693          	addi	a3,a3,888 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc0204120:	40c58633          	sub	a2,a1,a2
ffffffffc0204124:	630c                	ld	a1,0(a4)
ffffffffc0204126:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204128:	577d                	li	a4,-1
ffffffffc020412a:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc020412c:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc020412e:	8331                	srli	a4,a4,0xc
ffffffffc0204130:	8f71                	and	a4,a4,a2
ffffffffc0204132:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204136:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204138:	02d77a63          	bleu	a3,a4,ffffffffc020416c <swapfs_read+0x7e>
ffffffffc020413c:	00011797          	auipc	a5,0x11
ffffffffc0204140:	3b478793          	addi	a5,a5,948 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0204144:	639c                	ld	a5,0(a5)
}
ffffffffc0204146:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204148:	46a1                	li	a3,8
ffffffffc020414a:	963e                	add	a2,a2,a5
ffffffffc020414c:	4505                	li	a0,1
}
ffffffffc020414e:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204150:	c38fc06f          	j	ffffffffc0200588 <ide_read_secs>
ffffffffc0204154:	86aa                	mv	a3,a0
ffffffffc0204156:	00003617          	auipc	a2,0x3
ffffffffc020415a:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0206b70 <default_pmm_manager+0xf90>
ffffffffc020415e:	45d1                	li	a1,20
ffffffffc0204160:	00003517          	auipc	a0,0x3
ffffffffc0204164:	9f850513          	addi	a0,a0,-1544 # ffffffffc0206b58 <default_pmm_manager+0xf78>
ffffffffc0204168:	ae8fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc020416c:	86b2                	mv	a3,a2
ffffffffc020416e:	06900593          	li	a1,105
ffffffffc0204172:	00002617          	auipc	a2,0x2
ffffffffc0204176:	abe60613          	addi	a2,a2,-1346 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc020417a:	00002517          	auipc	a0,0x2
ffffffffc020417e:	ade50513          	addi	a0,a0,-1314 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc0204182:	acefc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204186 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204186:	1141                	addi	sp,sp,-16
ffffffffc0204188:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020418a:	00855793          	srli	a5,a0,0x8
ffffffffc020418e:	cfb9                	beqz	a5,ffffffffc02041ec <swapfs_write+0x66>
ffffffffc0204190:	00011717          	auipc	a4,0x11
ffffffffc0204194:	40070713          	addi	a4,a4,1024 # ffffffffc0215590 <max_swap_offset>
ffffffffc0204198:	6318                	ld	a4,0(a4)
ffffffffc020419a:	04e7f963          	bleu	a4,a5,ffffffffc02041ec <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc020419e:	00011717          	auipc	a4,0x11
ffffffffc02041a2:	36270713          	addi	a4,a4,866 # ffffffffc0215500 <pages>
ffffffffc02041a6:	6310                	ld	a2,0(a4)
ffffffffc02041a8:	00003717          	auipc	a4,0x3
ffffffffc02041ac:	de070713          	addi	a4,a4,-544 # ffffffffc0206f88 <nbase>
    return KADDR(page2pa(page));
ffffffffc02041b0:	00011697          	auipc	a3,0x11
ffffffffc02041b4:	2e068693          	addi	a3,a3,736 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc02041b8:	40c58633          	sub	a2,a1,a2
ffffffffc02041bc:	630c                	ld	a1,0(a4)
ffffffffc02041be:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc02041c0:	577d                	li	a4,-1
ffffffffc02041c2:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc02041c4:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc02041c6:	8331                	srli	a4,a4,0xc
ffffffffc02041c8:	8f71                	and	a4,a4,a2
ffffffffc02041ca:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02041ce:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02041d0:	02d77a63          	bleu	a3,a4,ffffffffc0204204 <swapfs_write+0x7e>
ffffffffc02041d4:	00011797          	auipc	a5,0x11
ffffffffc02041d8:	31c78793          	addi	a5,a5,796 # ffffffffc02154f0 <va_pa_offset>
ffffffffc02041dc:	639c                	ld	a5,0(a5)
}
ffffffffc02041de:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041e0:	46a1                	li	a3,8
ffffffffc02041e2:	963e                	add	a2,a2,a5
ffffffffc02041e4:	4505                	li	a0,1
}
ffffffffc02041e6:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02041e8:	bc4fc06f          	j	ffffffffc02005ac <ide_write_secs>
ffffffffc02041ec:	86aa                	mv	a3,a0
ffffffffc02041ee:	00003617          	auipc	a2,0x3
ffffffffc02041f2:	98260613          	addi	a2,a2,-1662 # ffffffffc0206b70 <default_pmm_manager+0xf90>
ffffffffc02041f6:	45e5                	li	a1,25
ffffffffc02041f8:	00003517          	auipc	a0,0x3
ffffffffc02041fc:	96050513          	addi	a0,a0,-1696 # ffffffffc0206b58 <default_pmm_manager+0xf78>
ffffffffc0204200:	a50fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0204204:	86b2                	mv	a3,a2
ffffffffc0204206:	06900593          	li	a1,105
ffffffffc020420a:	00002617          	auipc	a2,0x2
ffffffffc020420e:	a2660613          	addi	a2,a2,-1498 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc0204212:	00002517          	auipc	a0,0x2
ffffffffc0204216:	a4650513          	addi	a0,a0,-1466 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc020421a:	a36fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020421e <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc020421e:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204220:	9402                	jalr	s0

	jal do_exit
ffffffffc0204222:	3b4000ef          	jal	ra,ffffffffc02045d6 <do_exit>

ffffffffc0204226 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204226:	1101                	addi	sp,sp,-32
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204228:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc020422c:	e426                	sd	s1,8(sp)
ffffffffc020422e:	ec06                	sd	ra,24(sp)
ffffffffc0204230:	e822                	sd	s0,16(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204232:	fdcfd0ef          	jal	ra,ffffffffc0201a0e <kmalloc>
ffffffffc0204236:	84aa                	mv	s1,a0
    if (proc != NULL) {
ffffffffc0204238:	cd3d                	beqz	a0,ffffffffc02042b6 <alloc_proc+0x90>
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    //memset(proc, 0, sizeof(struct proc_struct));
    struct context *context_mem = (struct context*) kmalloc(sizeof(struct context));
ffffffffc020423a:	07000513          	li	a0,112
ffffffffc020423e:	fd0fd0ef          	jal	ra,ffffffffc0201a0e <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204242:	07000613          	li	a2,112
ffffffffc0204246:	4581                	li	a1,0
    struct context *context_mem = (struct context*) kmalloc(sizeof(struct context));
ffffffffc0204248:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020424a:	39d000ef          	jal	ra,ffffffffc0204de6 <memset>
    proc->state = PROC_UNINIT;
ffffffffc020424e:	57fd                	li	a5,-1
ffffffffc0204250:	1782                	slli	a5,a5,0x20
ffffffffc0204252:	e09c                	sd	a5,0(s1)
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    //初始化context结构体
    proc->context = *context_mem;
ffffffffc0204254:	8522                	mv	a0,s0
    proc->runs = 0;
ffffffffc0204256:	0004a423          	sw	zero,8(s1)
    proc->kstack = 0;
ffffffffc020425a:	0004b823          	sd	zero,16(s1)
    proc->need_resched = 0;
ffffffffc020425e:	0004ac23          	sw	zero,24(s1)
    proc->parent = NULL;
ffffffffc0204262:	0204b023          	sd	zero,32(s1)
    proc->mm = NULL;
ffffffffc0204266:	0204b423          	sd	zero,40(s1)
    proc->context = *context_mem;
ffffffffc020426a:	03048793          	addi	a5,s1,48
ffffffffc020426e:	06040813          	addi	a6,s0,96
ffffffffc0204272:	610c                	ld	a1,0(a0)
ffffffffc0204274:	6510                	ld	a2,8(a0)
ffffffffc0204276:	6914                	ld	a3,16(a0)
ffffffffc0204278:	6d18                	ld	a4,24(a0)
ffffffffc020427a:	e38c                	sd	a1,0(a5)
ffffffffc020427c:	e790                	sd	a2,8(a5)
ffffffffc020427e:	eb94                	sd	a3,16(a5)
ffffffffc0204280:	ef98                	sd	a4,24(a5)
ffffffffc0204282:	02050513          	addi	a0,a0,32
ffffffffc0204286:	02078793          	addi	a5,a5,32
ffffffffc020428a:	ff0514e3          	bne	a0,a6,ffffffffc0204272 <alloc_proc+0x4c>
ffffffffc020428e:	6114                	ld	a3,0(a0)
ffffffffc0204290:	6518                	ld	a4,8(a0)
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
    proc->flags = 0;
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204292:	4641                	li	a2,16
    proc->context = *context_mem;
ffffffffc0204294:	e394                	sd	a3,0(a5)
ffffffffc0204296:	e798                	sd	a4,8(a5)
    proc->cr3 = boot_cr3;
ffffffffc0204298:	00011797          	auipc	a5,0x11
ffffffffc020429c:	26078793          	addi	a5,a5,608 # ffffffffc02154f8 <boot_cr3>
ffffffffc02042a0:	639c                	ld	a5,0(a5)
    proc->tf = NULL;
ffffffffc02042a2:	0a04b023          	sd	zero,160(s1)
    proc->flags = 0;
ffffffffc02042a6:	0a04a823          	sw	zero,176(s1)
    proc->cr3 = boot_cr3;
ffffffffc02042aa:	f4dc                	sd	a5,168(s1)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042ac:	4581                	li	a1,0
ffffffffc02042ae:	0b448513          	addi	a0,s1,180
ffffffffc02042b2:	335000ef          	jal	ra,ffffffffc0204de6 <memset>
    }
    return proc;
}
ffffffffc02042b6:	60e2                	ld	ra,24(sp)
ffffffffc02042b8:	6442                	ld	s0,16(sp)
ffffffffc02042ba:	8526                	mv	a0,s1
ffffffffc02042bc:	64a2                	ld	s1,8(sp)
ffffffffc02042be:	6105                	addi	sp,sp,32
ffffffffc02042c0:	8082                	ret

ffffffffc02042c2 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc02042c2:	00011797          	auipc	a5,0x11
ffffffffc02042c6:	1e678793          	addi	a5,a5,486 # ffffffffc02154a8 <current>
ffffffffc02042ca:	639c                	ld	a5,0(a5)
ffffffffc02042cc:	73c8                	ld	a0,160(a5)
ffffffffc02042ce:	93ffc06f          	j	ffffffffc0200c0c <forkrets>

ffffffffc02042d2 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02042d2:	1101                	addi	sp,sp,-32
ffffffffc02042d4:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042d6:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02042da:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042dc:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02042de:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042e0:	8522                	mv	a0,s0
ffffffffc02042e2:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02042e4:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042e6:	301000ef          	jal	ra,ffffffffc0204de6 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02042ea:	8522                	mv	a0,s0
}
ffffffffc02042ec:	6442                	ld	s0,16(sp)
ffffffffc02042ee:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02042f0:	85a6                	mv	a1,s1
}
ffffffffc02042f2:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02042f4:	463d                	li	a2,15
}
ffffffffc02042f6:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02042f8:	3010006f          	j	ffffffffc0204df8 <memcpy>

ffffffffc02042fc <get_proc_name>:
get_proc_name(struct proc_struct *proc) {
ffffffffc02042fc:	1101                	addi	sp,sp,-32
ffffffffc02042fe:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204300:	00011417          	auipc	s0,0x11
ffffffffc0204304:	15840413          	addi	s0,s0,344 # ffffffffc0215458 <name.1566>
get_proc_name(struct proc_struct *proc) {
ffffffffc0204308:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc020430a:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc020430c:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc020430e:	4581                	li	a1,0
ffffffffc0204310:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc0204312:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204314:	2d3000ef          	jal	ra,ffffffffc0204de6 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204318:	8522                	mv	a0,s0
}
ffffffffc020431a:	6442                	ld	s0,16(sp)
ffffffffc020431c:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020431e:	0b448593          	addi	a1,s1,180
}
ffffffffc0204322:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204324:	463d                	li	a2,15
}
ffffffffc0204326:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204328:	2d10006f          	j	ffffffffc0204df8 <memcpy>

ffffffffc020432c <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020432c:	00011797          	auipc	a5,0x11
ffffffffc0204330:	17c78793          	addi	a5,a5,380 # ffffffffc02154a8 <current>
ffffffffc0204334:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc0204336:	1101                	addi	sp,sp,-32
ffffffffc0204338:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020433a:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc020433c:	e822                	sd	s0,16(sp)
ffffffffc020433e:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204340:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc0204342:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204344:	fb9ff0ef          	jal	ra,ffffffffc02042fc <get_proc_name>
ffffffffc0204348:	862a                	mv	a2,a0
ffffffffc020434a:	85a6                	mv	a1,s1
ffffffffc020434c:	00003517          	auipc	a0,0x3
ffffffffc0204350:	88c50513          	addi	a0,a0,-1908 # ffffffffc0206bd8 <default_pmm_manager+0xff8>
ffffffffc0204354:	e3bfb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc0204358:	85a2                	mv	a1,s0
ffffffffc020435a:	00003517          	auipc	a0,0x3
ffffffffc020435e:	8a650513          	addi	a0,a0,-1882 # ffffffffc0206c00 <default_pmm_manager+0x1020>
ffffffffc0204362:	e2dfb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0204366:	00003517          	auipc	a0,0x3
ffffffffc020436a:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0206c10 <default_pmm_manager+0x1030>
ffffffffc020436e:	e21fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc0204372:	60e2                	ld	ra,24(sp)
ffffffffc0204374:	6442                	ld	s0,16(sp)
ffffffffc0204376:	64a2                	ld	s1,8(sp)
ffffffffc0204378:	4501                	li	a0,0
ffffffffc020437a:	6105                	addi	sp,sp,32
ffffffffc020437c:	8082                	ret

ffffffffc020437e <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc020437e:	7179                	addi	sp,sp,-48
ffffffffc0204380:	f022                	sd	s0,32(sp)
    if (proc != current) {
ffffffffc0204382:	00011417          	auipc	s0,0x11
ffffffffc0204386:	12640413          	addi	s0,s0,294 # ffffffffc02154a8 <current>
ffffffffc020438a:	601c                	ld	a5,0(s0)
proc_run(struct proc_struct *proc) {
ffffffffc020438c:	f406                	sd	ra,40(sp)
ffffffffc020438e:	ec26                	sd	s1,24(sp)
    if (proc != current) {
ffffffffc0204390:	02a78963          	beq	a5,a0,ffffffffc02043c2 <proc_run+0x44>
       if (proc->pid == current->pid) 
ffffffffc0204394:	4154                	lw	a3,4(a0)
ffffffffc0204396:	43d8                	lw	a4,4(a5)
ffffffffc0204398:	02e68563          	beq	a3,a4,ffffffffc02043c2 <proc_run+0x44>
ffffffffc020439c:	85aa                	mv	a1,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020439e:	10002773          	csrr	a4,sstatus
ffffffffc02043a2:	8b09                	andi	a4,a4,2
    return 0;
ffffffffc02043a4:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02043a6:	eb0d                	bnez	a4,ffffffffc02043d8 <proc_run+0x5a>
        lcr3(proc->mm->pgdir);
ffffffffc02043a8:	7598                	ld	a4,40(a1)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc02043aa:	800006b7          	lui	a3,0x80000
ffffffffc02043ae:	6f18                	ld	a4,24(a4)
ffffffffc02043b0:	00c7571b          	srliw	a4,a4,0xc
ffffffffc02043b4:	8f55                	or	a4,a4,a3
ffffffffc02043b6:	18071073          	csrw	satp,a4
        switch_to(current,proc);
ffffffffc02043ba:	853e                	mv	a0,a5
ffffffffc02043bc:	446000ef          	jal	ra,ffffffffc0204802 <switch_to>
    if (flag) {
ffffffffc02043c0:	e491                	bnez	s1,ffffffffc02043cc <proc_run+0x4e>
}
ffffffffc02043c2:	70a2                	ld	ra,40(sp)
ffffffffc02043c4:	7402                	ld	s0,32(sp)
ffffffffc02043c6:	64e2                	ld	s1,24(sp)
ffffffffc02043c8:	6145                	addi	sp,sp,48
ffffffffc02043ca:	8082                	ret
ffffffffc02043cc:	7402                	ld	s0,32(sp)
ffffffffc02043ce:	70a2                	ld	ra,40(sp)
ffffffffc02043d0:	64e2                	ld	s1,24(sp)
ffffffffc02043d2:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc02043d4:	9fefc06f          	j	ffffffffc02005d2 <intr_enable>
ffffffffc02043d8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02043da:	9fefc0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        return 1;
ffffffffc02043de:	601c                	ld	a5,0(s0)
ffffffffc02043e0:	4485                	li	s1,1
ffffffffc02043e2:	65a2                	ld	a1,8(sp)
ffffffffc02043e4:	b7d1                	j	ffffffffc02043a8 <proc_run+0x2a>

ffffffffc02043e6 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc02043e6:	0005071b          	sext.w	a4,a0
ffffffffc02043ea:	6789                	lui	a5,0x2
ffffffffc02043ec:	fff7069b          	addiw	a3,a4,-1
ffffffffc02043f0:	17f9                	addi	a5,a5,-2
ffffffffc02043f2:	04d7e063          	bltu	a5,a3,ffffffffc0204432 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc02043f6:	1141                	addi	sp,sp,-16
ffffffffc02043f8:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02043fa:	45a9                	li	a1,10
ffffffffc02043fc:	842a                	mv	s0,a0
ffffffffc02043fe:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204400:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204402:	536000ef          	jal	ra,ffffffffc0204938 <hash32>
ffffffffc0204406:	02051693          	slli	a3,a0,0x20
ffffffffc020440a:	82f1                	srli	a3,a3,0x1c
ffffffffc020440c:	0000d517          	auipc	a0,0xd
ffffffffc0204410:	04c50513          	addi	a0,a0,76 # ffffffffc0211458 <hash_list>
ffffffffc0204414:	96aa                	add	a3,a3,a0
ffffffffc0204416:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204418:	a029                	j	ffffffffc0204422 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc020441a:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc020441e:	00870c63          	beq	a4,s0,ffffffffc0204436 <find_proc+0x50>
ffffffffc0204422:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204424:	fef69be3          	bne	a3,a5,ffffffffc020441a <find_proc+0x34>
}
ffffffffc0204428:	60a2                	ld	ra,8(sp)
ffffffffc020442a:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020442c:	4501                	li	a0,0
}
ffffffffc020442e:	0141                	addi	sp,sp,16
ffffffffc0204430:	8082                	ret
    return NULL;
ffffffffc0204432:	4501                	li	a0,0
}
ffffffffc0204434:	8082                	ret
ffffffffc0204436:	60a2                	ld	ra,8(sp)
ffffffffc0204438:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020443a:	f2878513          	addi	a0,a5,-216
}
ffffffffc020443e:	0141                	addi	sp,sp,16
ffffffffc0204440:	8082                	ret

ffffffffc0204442 <do_fork>:
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204442:	00011797          	auipc	a5,0x11
ffffffffc0204446:	07e78793          	addi	a5,a5,126 # ffffffffc02154c0 <nr_process>
ffffffffc020444a:	4398                	lw	a4,0(a5)
ffffffffc020444c:	6785                	lui	a5,0x1
ffffffffc020444e:	0ef75e63          	ble	a5,a4,ffffffffc020454a <do_fork+0x108>
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204452:	1101                	addi	sp,sp,-32
ffffffffc0204454:	e822                	sd	s0,16(sp)
ffffffffc0204456:	e426                	sd	s1,8(sp)
ffffffffc0204458:	e04a                	sd	s2,0(sp)
ffffffffc020445a:	ec06                	sd	ra,24(sp)
ffffffffc020445c:	84ae                	mv	s1,a1
ffffffffc020445e:	892a                	mv	s2,a0
    proc=alloc_proc();
ffffffffc0204460:	dc7ff0ef          	jal	ra,ffffffffc0204226 <alloc_proc>
ffffffffc0204464:	842a                	mv	s0,a0
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204466:	4509                	li	a0,2
ffffffffc0204468:	fa2fd0ef          	jal	ra,ffffffffc0201c0a <alloc_pages>
    if (page != NULL) {
ffffffffc020446c:	c129                	beqz	a0,ffffffffc02044ae <do_fork+0x6c>
    return page - pages + nbase;
ffffffffc020446e:	00011797          	auipc	a5,0x11
ffffffffc0204472:	09278793          	addi	a5,a5,146 # ffffffffc0215500 <pages>
ffffffffc0204476:	6394                	ld	a3,0(a5)
ffffffffc0204478:	00003797          	auipc	a5,0x3
ffffffffc020447c:	b1078793          	addi	a5,a5,-1264 # ffffffffc0206f88 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204480:	00011717          	auipc	a4,0x11
ffffffffc0204484:	01070713          	addi	a4,a4,16 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc0204488:	40d506b3          	sub	a3,a0,a3
ffffffffc020448c:	6388                	ld	a0,0(a5)
ffffffffc020448e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204490:	57fd                	li	a5,-1
ffffffffc0204492:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204494:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204496:	83b1                	srli	a5,a5,0xc
ffffffffc0204498:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020449a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020449c:	0ce7f963          	bleu	a4,a5,ffffffffc020456e <do_fork+0x12c>
ffffffffc02044a0:	00011797          	auipc	a5,0x11
ffffffffc02044a4:	05078793          	addi	a5,a5,80 # ffffffffc02154f0 <va_pa_offset>
ffffffffc02044a8:	639c                	ld	a5,0(a5)
ffffffffc02044aa:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02044ac:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc02044ae:	00011797          	auipc	a5,0x11
ffffffffc02044b2:	ffa78793          	addi	a5,a5,-6 # ffffffffc02154a8 <current>
ffffffffc02044b6:	639c                	ld	a5,0(a5)
ffffffffc02044b8:	779c                	ld	a5,40(a5)
ffffffffc02044ba:	ebd1                	bnez	a5,ffffffffc020454e <do_fork+0x10c>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02044bc:	681c                	ld	a5,16(s0)
ffffffffc02044be:	6709                	lui	a4,0x2
ffffffffc02044c0:	ee070713          	addi	a4,a4,-288 # 1ee0 <BASE_ADDRESS-0xffffffffc01fe120>
ffffffffc02044c4:	97ba                	add	a5,a5,a4
    copy_thread(proc,clone_flags,stack);
ffffffffc02044c6:	1902                	slli	s2,s2,0x20
    *(proc->tf) = *tf;
ffffffffc02044c8:	85a6                	mv	a1,s1
    copy_thread(proc,clone_flags,stack);
ffffffffc02044ca:	02095913          	srli	s2,s2,0x20
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02044ce:	f05c                	sd	a5,160(s0)
    *(proc->tf) = *tf;
ffffffffc02044d0:	873e                	mv	a4,a5
ffffffffc02044d2:	12048893          	addi	a7,s1,288
ffffffffc02044d6:	0005b803          	ld	a6,0(a1)
ffffffffc02044da:	6588                	ld	a0,8(a1)
ffffffffc02044dc:	6990                	ld	a2,16(a1)
ffffffffc02044de:	6d94                	ld	a3,24(a1)
ffffffffc02044e0:	01073023          	sd	a6,0(a4)
ffffffffc02044e4:	e708                	sd	a0,8(a4)
ffffffffc02044e6:	eb10                	sd	a2,16(a4)
ffffffffc02044e8:	ef14                	sd	a3,24(a4)
ffffffffc02044ea:	02058593          	addi	a1,a1,32
ffffffffc02044ee:	02070713          	addi	a4,a4,32
ffffffffc02044f2:	ff1592e3          	bne	a1,a7,ffffffffc02044d6 <do_fork+0x94>
    proc->tf->gpr.a0 = 0;
ffffffffc02044f6:	0407b823          	sd	zero,80(a5)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044fa:	00091363          	bnez	s2,ffffffffc0204500 <do_fork+0xbe>
ffffffffc02044fe:	893e                	mv	s2,a5
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204500:	4048                	lw	a0,4(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204502:	00000717          	auipc	a4,0x0
ffffffffc0204506:	dc070713          	addi	a4,a4,-576 # ffffffffc02042c2 <forkret>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020450a:	0127b823          	sd	s2,16(a5)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020450e:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204510:	fc1c                	sd	a5,56(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204512:	45a9                	li	a1,10
ffffffffc0204514:	424000ef          	jal	ra,ffffffffc0204938 <hash32>
ffffffffc0204518:	02051793          	slli	a5,a0,0x20
ffffffffc020451c:	83f1                	srli	a5,a5,0x1c
ffffffffc020451e:	0000d517          	auipc	a0,0xd
ffffffffc0204522:	f3a50513          	addi	a0,a0,-198 # ffffffffc0211458 <hash_list>
ffffffffc0204526:	97aa                	add	a5,a5,a0
    __list_add(elm, listelm, listelm->next);
ffffffffc0204528:	6798                	ld	a4,8(a5)
ffffffffc020452a:	0d840693          	addi	a3,s0,216
    wakeup_proc(proc);
ffffffffc020452e:	8522                	mv	a0,s0
    prev->next = next->prev = elm;
ffffffffc0204530:	e314                	sd	a3,0(a4)
ffffffffc0204532:	e794                	sd	a3,8(a5)
    elm->next = next;
ffffffffc0204534:	f078                	sd	a4,224(s0)
    elm->prev = prev;
ffffffffc0204536:	ec7c                	sd	a5,216(s0)
ffffffffc0204538:	334000ef          	jal	ra,ffffffffc020486c <wakeup_proc>
    ret=proc->pid;
ffffffffc020453c:	4048                	lw	a0,4(s0)
}
ffffffffc020453e:	60e2                	ld	ra,24(sp)
ffffffffc0204540:	6442                	ld	s0,16(sp)
ffffffffc0204542:	64a2                	ld	s1,8(sp)
ffffffffc0204544:	6902                	ld	s2,0(sp)
ffffffffc0204546:	6105                	addi	sp,sp,32
ffffffffc0204548:	8082                	ret
    int ret = -E_NO_FREE_PROC;
ffffffffc020454a:	556d                	li	a0,-5
}
ffffffffc020454c:	8082                	ret
    assert(current->mm == NULL);
ffffffffc020454e:	00002697          	auipc	a3,0x2
ffffffffc0204552:	65a68693          	addi	a3,a3,1626 # ffffffffc0206ba8 <default_pmm_manager+0xfc8>
ffffffffc0204556:	00001617          	auipc	a2,0x1
ffffffffc020455a:	2f260613          	addi	a2,a2,754 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020455e:	10e00593          	li	a1,270
ffffffffc0204562:	00002517          	auipc	a0,0x2
ffffffffc0204566:	65e50513          	addi	a0,a0,1630 # ffffffffc0206bc0 <default_pmm_manager+0xfe0>
ffffffffc020456a:	ee7fb0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc020456e:	00001617          	auipc	a2,0x1
ffffffffc0204572:	6c260613          	addi	a2,a2,1730 # ffffffffc0205c30 <default_pmm_manager+0x50>
ffffffffc0204576:	06900593          	li	a1,105
ffffffffc020457a:	00001517          	auipc	a0,0x1
ffffffffc020457e:	6de50513          	addi	a0,a0,1758 # ffffffffc0205c58 <default_pmm_manager+0x78>
ffffffffc0204582:	ecffb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204586 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204586:	7129                	addi	sp,sp,-320
ffffffffc0204588:	fa22                	sd	s0,304(sp)
ffffffffc020458a:	f626                	sd	s1,296(sp)
ffffffffc020458c:	f24a                	sd	s2,288(sp)
ffffffffc020458e:	84ae                	mv	s1,a1
ffffffffc0204590:	892a                	mv	s2,a0
ffffffffc0204592:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204594:	4581                	li	a1,0
ffffffffc0204596:	12000613          	li	a2,288
ffffffffc020459a:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020459c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020459e:	049000ef          	jal	ra,ffffffffc0204de6 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02045a2:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02045a4:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02045a6:	100027f3          	csrr	a5,sstatus
ffffffffc02045aa:	edd7f793          	andi	a5,a5,-291
ffffffffc02045ae:	1207e793          	ori	a5,a5,288
ffffffffc02045b2:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02045b4:	860a                	mv	a2,sp
ffffffffc02045b6:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02045ba:	00000797          	auipc	a5,0x0
ffffffffc02045be:	c6478793          	addi	a5,a5,-924 # ffffffffc020421e <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02045c2:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02045c4:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02045c6:	e7dff0ef          	jal	ra,ffffffffc0204442 <do_fork>
}
ffffffffc02045ca:	70f2                	ld	ra,312(sp)
ffffffffc02045cc:	7452                	ld	s0,304(sp)
ffffffffc02045ce:	74b2                	ld	s1,296(sp)
ffffffffc02045d0:	7912                	ld	s2,288(sp)
ffffffffc02045d2:	6131                	addi	sp,sp,320
ffffffffc02045d4:	8082                	ret

ffffffffc02045d6 <do_exit>:
do_exit(int error_code) {
ffffffffc02045d6:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc02045d8:	00002617          	auipc	a2,0x2
ffffffffc02045dc:	5b860613          	addi	a2,a2,1464 # ffffffffc0206b90 <default_pmm_manager+0xfb0>
ffffffffc02045e0:	16200593          	li	a1,354
ffffffffc02045e4:	00002517          	auipc	a0,0x2
ffffffffc02045e8:	5dc50513          	addi	a0,a0,1500 # ffffffffc0206bc0 <default_pmm_manager+0xfe0>
do_exit(int error_code) {
ffffffffc02045ec:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc02045ee:	e63fb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02045f2 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc02045f2:	00011797          	auipc	a5,0x11
ffffffffc02045f6:	ff678793          	addi	a5,a5,-10 # ffffffffc02155e8 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc02045fa:	1101                	addi	sp,sp,-32
ffffffffc02045fc:	00011717          	auipc	a4,0x11
ffffffffc0204600:	fef73a23          	sd	a5,-12(a4) # ffffffffc02155f0 <proc_list+0x8>
ffffffffc0204604:	00011717          	auipc	a4,0x11
ffffffffc0204608:	fef73223          	sd	a5,-28(a4) # ffffffffc02155e8 <proc_list>
ffffffffc020460c:	ec06                	sd	ra,24(sp)
ffffffffc020460e:	e822                	sd	s0,16(sp)
ffffffffc0204610:	e426                	sd	s1,8(sp)
ffffffffc0204612:	e04a                	sd	s2,0(sp)
ffffffffc0204614:	0000d797          	auipc	a5,0xd
ffffffffc0204618:	e4478793          	addi	a5,a5,-444 # ffffffffc0211458 <hash_list>
ffffffffc020461c:	00011717          	auipc	a4,0x11
ffffffffc0204620:	e3c70713          	addi	a4,a4,-452 # ffffffffc0215458 <name.1566>
ffffffffc0204624:	e79c                	sd	a5,8(a5)
ffffffffc0204626:	e39c                	sd	a5,0(a5)
ffffffffc0204628:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc020462a:	fee79de3          	bne	a5,a4,ffffffffc0204624 <proc_init+0x32>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc020462e:	bf9ff0ef          	jal	ra,ffffffffc0204226 <alloc_proc>
ffffffffc0204632:	00011797          	auipc	a5,0x11
ffffffffc0204636:	e6a7bf23          	sd	a0,-386(a5) # ffffffffc02154b0 <idleproc>
ffffffffc020463a:	00011417          	auipc	s0,0x11
ffffffffc020463e:	e7640413          	addi	s0,s0,-394 # ffffffffc02154b0 <idleproc>
ffffffffc0204642:	12050a63          	beqz	a0,ffffffffc0204776 <proc_init+0x184>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204646:	07000513          	li	a0,112
ffffffffc020464a:	bc4fd0ef          	jal	ra,ffffffffc0201a0e <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020464e:	07000613          	li	a2,112
ffffffffc0204652:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204654:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204656:	790000ef          	jal	ra,ffffffffc0204de6 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc020465a:	6008                	ld	a0,0(s0)
ffffffffc020465c:	85a6                	mv	a1,s1
ffffffffc020465e:	07000613          	li	a2,112
ffffffffc0204662:	03050513          	addi	a0,a0,48
ffffffffc0204666:	7aa000ef          	jal	ra,ffffffffc0204e10 <memcmp>
ffffffffc020466a:	892a                	mv	s2,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc020466c:	453d                	li	a0,15
ffffffffc020466e:	ba0fd0ef          	jal	ra,ffffffffc0201a0e <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204672:	463d                	li	a2,15
ffffffffc0204674:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204676:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204678:	76e000ef          	jal	ra,ffffffffc0204de6 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc020467c:	6008                	ld	a0,0(s0)
ffffffffc020467e:	463d                	li	a2,15
ffffffffc0204680:	85a6                	mv	a1,s1
ffffffffc0204682:	0b450513          	addi	a0,a0,180
ffffffffc0204686:	78a000ef          	jal	ra,ffffffffc0204e10 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc020468a:	601c                	ld	a5,0(s0)
ffffffffc020468c:	00011717          	auipc	a4,0x11
ffffffffc0204690:	e6c70713          	addi	a4,a4,-404 # ffffffffc02154f8 <boot_cr3>
ffffffffc0204694:	6318                	ld	a4,0(a4)
ffffffffc0204696:	77d4                	ld	a3,168(a5)
ffffffffc0204698:	08e68e63          	beq	a3,a4,ffffffffc0204734 <proc_init+0x142>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc020469c:	4709                	li	a4,2
ffffffffc020469e:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02046a0:	00003717          	auipc	a4,0x3
ffffffffc02046a4:	96070713          	addi	a4,a4,-1696 # ffffffffc0207000 <bootstack>
ffffffffc02046a8:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc02046aa:	4705                	li	a4,1
ffffffffc02046ac:	cf98                	sw	a4,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc02046ae:	00002597          	auipc	a1,0x2
ffffffffc02046b2:	5b258593          	addi	a1,a1,1458 # ffffffffc0206c60 <default_pmm_manager+0x1080>
ffffffffc02046b6:	853e                	mv	a0,a5
ffffffffc02046b8:	c1bff0ef          	jal	ra,ffffffffc02042d2 <set_proc_name>
    nr_process ++;
ffffffffc02046bc:	00011797          	auipc	a5,0x11
ffffffffc02046c0:	e0478793          	addi	a5,a5,-508 # ffffffffc02154c0 <nr_process>
ffffffffc02046c4:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc02046c6:	6018                	ld	a4,0(s0)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02046c8:	4601                	li	a2,0
    nr_process ++;
ffffffffc02046ca:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02046cc:	00002597          	auipc	a1,0x2
ffffffffc02046d0:	59c58593          	addi	a1,a1,1436 # ffffffffc0206c68 <default_pmm_manager+0x1088>
ffffffffc02046d4:	00000517          	auipc	a0,0x0
ffffffffc02046d8:	c5850513          	addi	a0,a0,-936 # ffffffffc020432c <init_main>
    nr_process ++;
ffffffffc02046dc:	00011697          	auipc	a3,0x11
ffffffffc02046e0:	def6a223          	sw	a5,-540(a3) # ffffffffc02154c0 <nr_process>
    current = idleproc;
ffffffffc02046e4:	00011797          	auipc	a5,0x11
ffffffffc02046e8:	dce7b223          	sd	a4,-572(a5) # ffffffffc02154a8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02046ec:	e9bff0ef          	jal	ra,ffffffffc0204586 <kernel_thread>
    if (pid <= 0) {
ffffffffc02046f0:	0ca05f63          	blez	a0,ffffffffc02047ce <proc_init+0x1dc>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02046f4:	cf3ff0ef          	jal	ra,ffffffffc02043e6 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc02046f8:	00002597          	auipc	a1,0x2
ffffffffc02046fc:	5a058593          	addi	a1,a1,1440 # ffffffffc0206c98 <default_pmm_manager+0x10b8>
    initproc = find_proc(pid);
ffffffffc0204700:	00011797          	auipc	a5,0x11
ffffffffc0204704:	daa7bc23          	sd	a0,-584(a5) # ffffffffc02154b8 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0204708:	bcbff0ef          	jal	ra,ffffffffc02042d2 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020470c:	601c                	ld	a5,0(s0)
ffffffffc020470e:	c3c5                	beqz	a5,ffffffffc02047ae <proc_init+0x1bc>
ffffffffc0204710:	43dc                	lw	a5,4(a5)
ffffffffc0204712:	efd1                	bnez	a5,ffffffffc02047ae <proc_init+0x1bc>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204714:	00011797          	auipc	a5,0x11
ffffffffc0204718:	da478793          	addi	a5,a5,-604 # ffffffffc02154b8 <initproc>
ffffffffc020471c:	639c                	ld	a5,0(a5)
ffffffffc020471e:	cba5                	beqz	a5,ffffffffc020478e <proc_init+0x19c>
ffffffffc0204720:	43d8                	lw	a4,4(a5)
ffffffffc0204722:	4785                	li	a5,1
ffffffffc0204724:	06f71563          	bne	a4,a5,ffffffffc020478e <proc_init+0x19c>
}
ffffffffc0204728:	60e2                	ld	ra,24(sp)
ffffffffc020472a:	6442                	ld	s0,16(sp)
ffffffffc020472c:	64a2                	ld	s1,8(sp)
ffffffffc020472e:	6902                	ld	s2,0(sp)
ffffffffc0204730:	6105                	addi	sp,sp,32
ffffffffc0204732:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204734:	73d8                	ld	a4,160(a5)
ffffffffc0204736:	f33d                	bnez	a4,ffffffffc020469c <proc_init+0xaa>
ffffffffc0204738:	f60912e3          	bnez	s2,ffffffffc020469c <proc_init+0xaa>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc020473c:	6394                	ld	a3,0(a5)
ffffffffc020473e:	577d                	li	a4,-1
ffffffffc0204740:	1702                	slli	a4,a4,0x20
ffffffffc0204742:	f4e69de3          	bne	a3,a4,ffffffffc020469c <proc_init+0xaa>
ffffffffc0204746:	4798                	lw	a4,8(a5)
ffffffffc0204748:	fb31                	bnez	a4,ffffffffc020469c <proc_init+0xaa>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc020474a:	6b98                	ld	a4,16(a5)
ffffffffc020474c:	fb21                	bnez	a4,ffffffffc020469c <proc_init+0xaa>
ffffffffc020474e:	4f98                	lw	a4,24(a5)
ffffffffc0204750:	2701                	sext.w	a4,a4
ffffffffc0204752:	f729                	bnez	a4,ffffffffc020469c <proc_init+0xaa>
ffffffffc0204754:	7398                	ld	a4,32(a5)
ffffffffc0204756:	f339                	bnez	a4,ffffffffc020469c <proc_init+0xaa>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204758:	7798                	ld	a4,40(a5)
ffffffffc020475a:	f329                	bnez	a4,ffffffffc020469c <proc_init+0xaa>
ffffffffc020475c:	0b07a703          	lw	a4,176(a5)
ffffffffc0204760:	8f49                	or	a4,a4,a0
ffffffffc0204762:	2701                	sext.w	a4,a4
ffffffffc0204764:	ff05                	bnez	a4,ffffffffc020469c <proc_init+0xaa>
        cprintf("alloc_proc() correct!\n");
ffffffffc0204766:	00002517          	auipc	a0,0x2
ffffffffc020476a:	4e250513          	addi	a0,a0,1250 # ffffffffc0206c48 <default_pmm_manager+0x1068>
ffffffffc020476e:	a21fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0204772:	601c                	ld	a5,0(s0)
ffffffffc0204774:	b725                	j	ffffffffc020469c <proc_init+0xaa>
        panic("cannot alloc idleproc.\n");
ffffffffc0204776:	00002617          	auipc	a2,0x2
ffffffffc020477a:	4ba60613          	addi	a2,a2,1210 # ffffffffc0206c30 <default_pmm_manager+0x1050>
ffffffffc020477e:	17a00593          	li	a1,378
ffffffffc0204782:	00002517          	auipc	a0,0x2
ffffffffc0204786:	43e50513          	addi	a0,a0,1086 # ffffffffc0206bc0 <default_pmm_manager+0xfe0>
ffffffffc020478a:	cc7fb0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020478e:	00002697          	auipc	a3,0x2
ffffffffc0204792:	53a68693          	addi	a3,a3,1338 # ffffffffc0206cc8 <default_pmm_manager+0x10e8>
ffffffffc0204796:	00001617          	auipc	a2,0x1
ffffffffc020479a:	0b260613          	addi	a2,a2,178 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020479e:	1a100593          	li	a1,417
ffffffffc02047a2:	00002517          	auipc	a0,0x2
ffffffffc02047a6:	41e50513          	addi	a0,a0,1054 # ffffffffc0206bc0 <default_pmm_manager+0xfe0>
ffffffffc02047aa:	ca7fb0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02047ae:	00002697          	auipc	a3,0x2
ffffffffc02047b2:	4f268693          	addi	a3,a3,1266 # ffffffffc0206ca0 <default_pmm_manager+0x10c0>
ffffffffc02047b6:	00001617          	auipc	a2,0x1
ffffffffc02047ba:	09260613          	addi	a2,a2,146 # ffffffffc0205848 <commands+0x8d8>
ffffffffc02047be:	1a000593          	li	a1,416
ffffffffc02047c2:	00002517          	auipc	a0,0x2
ffffffffc02047c6:	3fe50513          	addi	a0,a0,1022 # ffffffffc0206bc0 <default_pmm_manager+0xfe0>
ffffffffc02047ca:	c87fb0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("create init_main failed.\n");
ffffffffc02047ce:	00002617          	auipc	a2,0x2
ffffffffc02047d2:	4aa60613          	addi	a2,a2,1194 # ffffffffc0206c78 <default_pmm_manager+0x1098>
ffffffffc02047d6:	19a00593          	li	a1,410
ffffffffc02047da:	00002517          	auipc	a0,0x2
ffffffffc02047de:	3e650513          	addi	a0,a0,998 # ffffffffc0206bc0 <default_pmm_manager+0xfe0>
ffffffffc02047e2:	c6ffb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02047e6 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc02047e6:	1141                	addi	sp,sp,-16
ffffffffc02047e8:	e022                	sd	s0,0(sp)
ffffffffc02047ea:	e406                	sd	ra,8(sp)
ffffffffc02047ec:	00011417          	auipc	s0,0x11
ffffffffc02047f0:	cbc40413          	addi	s0,s0,-836 # ffffffffc02154a8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02047f4:	6018                	ld	a4,0(s0)
ffffffffc02047f6:	4f1c                	lw	a5,24(a4)
ffffffffc02047f8:	2781                	sext.w	a5,a5
ffffffffc02047fa:	dff5                	beqz	a5,ffffffffc02047f6 <cpu_idle+0x10>
            schedule();
ffffffffc02047fc:	0a2000ef          	jal	ra,ffffffffc020489e <schedule>
ffffffffc0204800:	bfd5                	j	ffffffffc02047f4 <cpu_idle+0xe>

ffffffffc0204802 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204802:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204806:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc020480a:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc020480c:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020480e:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204812:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204816:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc020481a:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020481e:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204822:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204826:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc020482a:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020482e:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204832:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204836:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc020483a:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020483e:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204840:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204842:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204846:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc020484a:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020484e:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204852:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204856:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc020485a:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020485e:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204862:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204866:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc020486a:	8082                	ret

ffffffffc020486c <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020486c:	411c                	lw	a5,0(a0)
ffffffffc020486e:	4705                	li	a4,1
ffffffffc0204870:	37f9                	addiw	a5,a5,-2
ffffffffc0204872:	00f77563          	bleu	a5,a4,ffffffffc020487c <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc0204876:	4789                	li	a5,2
ffffffffc0204878:	c11c                	sw	a5,0(a0)
ffffffffc020487a:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc020487c:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020487e:	00002697          	auipc	a3,0x2
ffffffffc0204882:	47268693          	addi	a3,a3,1138 # ffffffffc0206cf0 <default_pmm_manager+0x1110>
ffffffffc0204886:	00001617          	auipc	a2,0x1
ffffffffc020488a:	fc260613          	addi	a2,a2,-62 # ffffffffc0205848 <commands+0x8d8>
ffffffffc020488e:	45a5                	li	a1,9
ffffffffc0204890:	00002517          	auipc	a0,0x2
ffffffffc0204894:	4a050513          	addi	a0,a0,1184 # ffffffffc0206d30 <default_pmm_manager+0x1150>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204898:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020489a:	bb7fb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020489e <schedule>:
}

void
schedule(void) {
ffffffffc020489e:	1141                	addi	sp,sp,-16
ffffffffc02048a0:	e406                	sd	ra,8(sp)
ffffffffc02048a2:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02048a4:	100027f3          	csrr	a5,sstatus
ffffffffc02048a8:	8b89                	andi	a5,a5,2
ffffffffc02048aa:	4401                	li	s0,0
ffffffffc02048ac:	e3d1                	bnez	a5,ffffffffc0204930 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02048ae:	00011797          	auipc	a5,0x11
ffffffffc02048b2:	bfa78793          	addi	a5,a5,-1030 # ffffffffc02154a8 <current>
ffffffffc02048b6:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02048ba:	00011797          	auipc	a5,0x11
ffffffffc02048be:	bf678793          	addi	a5,a5,-1034 # ffffffffc02154b0 <idleproc>
ffffffffc02048c2:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc02048c4:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02048c8:	04a88e63          	beq	a7,a0,ffffffffc0204924 <schedule+0x86>
ffffffffc02048cc:	0c888693          	addi	a3,a7,200
ffffffffc02048d0:	00011617          	auipc	a2,0x11
ffffffffc02048d4:	d1860613          	addi	a2,a2,-744 # ffffffffc02155e8 <proc_list>
        le = last;
ffffffffc02048d8:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02048da:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02048dc:	4809                	li	a6,2
    return listelm->next;
ffffffffc02048de:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02048e0:	00c78863          	beq	a5,a2,ffffffffc02048f0 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02048e4:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02048e8:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02048ec:	01070463          	beq	a4,a6,ffffffffc02048f4 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc02048f0:	fef697e3          	bne	a3,a5,ffffffffc02048de <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02048f4:	c589                	beqz	a1,ffffffffc02048fe <schedule+0x60>
ffffffffc02048f6:	4198                	lw	a4,0(a1)
ffffffffc02048f8:	4789                	li	a5,2
ffffffffc02048fa:	00f70e63          	beq	a4,a5,ffffffffc0204916 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02048fe:	451c                	lw	a5,8(a0)
ffffffffc0204900:	2785                	addiw	a5,a5,1
ffffffffc0204902:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0204904:	00a88463          	beq	a7,a0,ffffffffc020490c <schedule+0x6e>
            proc_run(next);
ffffffffc0204908:	a77ff0ef          	jal	ra,ffffffffc020437e <proc_run>
    if (flag) {
ffffffffc020490c:	e419                	bnez	s0,ffffffffc020491a <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020490e:	60a2                	ld	ra,8(sp)
ffffffffc0204910:	6402                	ld	s0,0(sp)
ffffffffc0204912:	0141                	addi	sp,sp,16
ffffffffc0204914:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204916:	852e                	mv	a0,a1
ffffffffc0204918:	b7dd                	j	ffffffffc02048fe <schedule+0x60>
}
ffffffffc020491a:	6402                	ld	s0,0(sp)
ffffffffc020491c:	60a2                	ld	ra,8(sp)
ffffffffc020491e:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0204920:	cb3fb06f          	j	ffffffffc02005d2 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204924:	00011617          	auipc	a2,0x11
ffffffffc0204928:	cc460613          	addi	a2,a2,-828 # ffffffffc02155e8 <proc_list>
ffffffffc020492c:	86b2                	mv	a3,a2
ffffffffc020492e:	b76d                	j	ffffffffc02048d8 <schedule+0x3a>
        intr_disable();
ffffffffc0204930:	ca9fb0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        return 1;
ffffffffc0204934:	4405                	li	s0,1
ffffffffc0204936:	bfa5                	j	ffffffffc02048ae <schedule+0x10>

ffffffffc0204938 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204938:	9e3707b7          	lui	a5,0x9e370
ffffffffc020493c:	2785                	addiw	a5,a5,1
ffffffffc020493e:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0204942:	02000793          	li	a5,32
ffffffffc0204946:	40b785bb          	subw	a1,a5,a1
}
ffffffffc020494a:	00b5553b          	srlw	a0,a0,a1
ffffffffc020494e:	8082                	ret

ffffffffc0204950 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204950:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204954:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204956:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020495a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020495c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204960:	f022                	sd	s0,32(sp)
ffffffffc0204962:	ec26                	sd	s1,24(sp)
ffffffffc0204964:	e84a                	sd	s2,16(sp)
ffffffffc0204966:	f406                	sd	ra,40(sp)
ffffffffc0204968:	e44e                	sd	s3,8(sp)
ffffffffc020496a:	84aa                	mv	s1,a0
ffffffffc020496c:	892e                	mv	s2,a1
ffffffffc020496e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204972:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0204974:	03067e63          	bleu	a6,a2,ffffffffc02049b0 <printnum+0x60>
ffffffffc0204978:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020497a:	00805763          	blez	s0,ffffffffc0204988 <printnum+0x38>
ffffffffc020497e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204980:	85ca                	mv	a1,s2
ffffffffc0204982:	854e                	mv	a0,s3
ffffffffc0204984:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204986:	fc65                	bnez	s0,ffffffffc020497e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204988:	1a02                	slli	s4,s4,0x20
ffffffffc020498a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020498e:	00002797          	auipc	a5,0x2
ffffffffc0204992:	54a78793          	addi	a5,a5,1354 # ffffffffc0206ed8 <error_string+0x38>
ffffffffc0204996:	9a3e                	add	s4,s4,a5
}
ffffffffc0204998:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020499a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020499e:	70a2                	ld	ra,40(sp)
ffffffffc02049a0:	69a2                	ld	s3,8(sp)
ffffffffc02049a2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02049a4:	85ca                	mv	a1,s2
ffffffffc02049a6:	8326                	mv	t1,s1
}
ffffffffc02049a8:	6942                	ld	s2,16(sp)
ffffffffc02049aa:	64e2                	ld	s1,24(sp)
ffffffffc02049ac:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02049ae:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02049b0:	03065633          	divu	a2,a2,a6
ffffffffc02049b4:	8722                	mv	a4,s0
ffffffffc02049b6:	f9bff0ef          	jal	ra,ffffffffc0204950 <printnum>
ffffffffc02049ba:	b7f9                	j	ffffffffc0204988 <printnum+0x38>

ffffffffc02049bc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02049bc:	7119                	addi	sp,sp,-128
ffffffffc02049be:	f4a6                	sd	s1,104(sp)
ffffffffc02049c0:	f0ca                	sd	s2,96(sp)
ffffffffc02049c2:	e8d2                	sd	s4,80(sp)
ffffffffc02049c4:	e4d6                	sd	s5,72(sp)
ffffffffc02049c6:	e0da                	sd	s6,64(sp)
ffffffffc02049c8:	fc5e                	sd	s7,56(sp)
ffffffffc02049ca:	f862                	sd	s8,48(sp)
ffffffffc02049cc:	f06a                	sd	s10,32(sp)
ffffffffc02049ce:	fc86                	sd	ra,120(sp)
ffffffffc02049d0:	f8a2                	sd	s0,112(sp)
ffffffffc02049d2:	ecce                	sd	s3,88(sp)
ffffffffc02049d4:	f466                	sd	s9,40(sp)
ffffffffc02049d6:	ec6e                	sd	s11,24(sp)
ffffffffc02049d8:	892a                	mv	s2,a0
ffffffffc02049da:	84ae                	mv	s1,a1
ffffffffc02049dc:	8d32                	mv	s10,a2
ffffffffc02049de:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02049e0:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02049e2:	00002a17          	auipc	s4,0x2
ffffffffc02049e6:	366a0a13          	addi	s4,s4,870 # ffffffffc0206d48 <default_pmm_manager+0x1168>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02049ea:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02049ee:	00002c17          	auipc	s8,0x2
ffffffffc02049f2:	4b2c0c13          	addi	s8,s8,1202 # ffffffffc0206ea0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02049f6:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02049fa:	02500793          	li	a5,37
ffffffffc02049fe:	001d0413          	addi	s0,s10,1
ffffffffc0204a02:	00f50e63          	beq	a0,a5,ffffffffc0204a1e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204a06:	c521                	beqz	a0,ffffffffc0204a4e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204a08:	02500993          	li	s3,37
ffffffffc0204a0c:	a011                	j	ffffffffc0204a10 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204a0e:	c121                	beqz	a0,ffffffffc0204a4e <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0204a10:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204a12:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204a14:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204a16:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204a1a:	ff351ae3          	bne	a0,s3,ffffffffc0204a0e <vprintfmt+0x52>
ffffffffc0204a1e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204a22:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204a26:	4981                	li	s3,0
ffffffffc0204a28:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0204a2a:	5cfd                	li	s9,-1
ffffffffc0204a2c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a2e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0204a32:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a34:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204a38:	0ff6f693          	andi	a3,a3,255
ffffffffc0204a3c:	00140d13          	addi	s10,s0,1
ffffffffc0204a40:	20d5e563          	bltu	a1,a3,ffffffffc0204c4a <vprintfmt+0x28e>
ffffffffc0204a44:	068a                	slli	a3,a3,0x2
ffffffffc0204a46:	96d2                	add	a3,a3,s4
ffffffffc0204a48:	4294                	lw	a3,0(a3)
ffffffffc0204a4a:	96d2                	add	a3,a3,s4
ffffffffc0204a4c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204a4e:	70e6                	ld	ra,120(sp)
ffffffffc0204a50:	7446                	ld	s0,112(sp)
ffffffffc0204a52:	74a6                	ld	s1,104(sp)
ffffffffc0204a54:	7906                	ld	s2,96(sp)
ffffffffc0204a56:	69e6                	ld	s3,88(sp)
ffffffffc0204a58:	6a46                	ld	s4,80(sp)
ffffffffc0204a5a:	6aa6                	ld	s5,72(sp)
ffffffffc0204a5c:	6b06                	ld	s6,64(sp)
ffffffffc0204a5e:	7be2                	ld	s7,56(sp)
ffffffffc0204a60:	7c42                	ld	s8,48(sp)
ffffffffc0204a62:	7ca2                	ld	s9,40(sp)
ffffffffc0204a64:	7d02                	ld	s10,32(sp)
ffffffffc0204a66:	6de2                	ld	s11,24(sp)
ffffffffc0204a68:	6109                	addi	sp,sp,128
ffffffffc0204a6a:	8082                	ret
    if (lflag >= 2) {
ffffffffc0204a6c:	4705                	li	a4,1
ffffffffc0204a6e:	008a8593          	addi	a1,s5,8
ffffffffc0204a72:	01074463          	blt	a4,a6,ffffffffc0204a7a <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0204a76:	26080363          	beqz	a6,ffffffffc0204cdc <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0204a7a:	000ab603          	ld	a2,0(s5)
ffffffffc0204a7e:	46c1                	li	a3,16
ffffffffc0204a80:	8aae                	mv	s5,a1
ffffffffc0204a82:	a06d                	j	ffffffffc0204b2c <vprintfmt+0x170>
            goto reswitch;
ffffffffc0204a84:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204a88:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a8a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204a8c:	b765                	j	ffffffffc0204a34 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0204a8e:	000aa503          	lw	a0,0(s5)
ffffffffc0204a92:	85a6                	mv	a1,s1
ffffffffc0204a94:	0aa1                	addi	s5,s5,8
ffffffffc0204a96:	9902                	jalr	s2
            break;
ffffffffc0204a98:	bfb9                	j	ffffffffc02049f6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204a9a:	4705                	li	a4,1
ffffffffc0204a9c:	008a8993          	addi	s3,s5,8
ffffffffc0204aa0:	01074463          	blt	a4,a6,ffffffffc0204aa8 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0204aa4:	22080463          	beqz	a6,ffffffffc0204ccc <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0204aa8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0204aac:	24044463          	bltz	s0,ffffffffc0204cf4 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0204ab0:	8622                	mv	a2,s0
ffffffffc0204ab2:	8ace                	mv	s5,s3
ffffffffc0204ab4:	46a9                	li	a3,10
ffffffffc0204ab6:	a89d                	j	ffffffffc0204b2c <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0204ab8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204abc:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204abe:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0204ac0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204ac4:	8fb5                	xor	a5,a5,a3
ffffffffc0204ac6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204aca:	1ad74363          	blt	a4,a3,ffffffffc0204c70 <vprintfmt+0x2b4>
ffffffffc0204ace:	00369793          	slli	a5,a3,0x3
ffffffffc0204ad2:	97e2                	add	a5,a5,s8
ffffffffc0204ad4:	639c                	ld	a5,0(a5)
ffffffffc0204ad6:	18078d63          	beqz	a5,ffffffffc0204c70 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204ada:	86be                	mv	a3,a5
ffffffffc0204adc:	00000617          	auipc	a2,0x0
ffffffffc0204ae0:	38c60613          	addi	a2,a2,908 # ffffffffc0204e68 <etext+0x28>
ffffffffc0204ae4:	85a6                	mv	a1,s1
ffffffffc0204ae6:	854a                	mv	a0,s2
ffffffffc0204ae8:	240000ef          	jal	ra,ffffffffc0204d28 <printfmt>
ffffffffc0204aec:	b729                	j	ffffffffc02049f6 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204aee:	00144603          	lbu	a2,1(s0)
ffffffffc0204af2:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204af4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204af6:	bf3d                	j	ffffffffc0204a34 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204af8:	4705                	li	a4,1
ffffffffc0204afa:	008a8593          	addi	a1,s5,8
ffffffffc0204afe:	01074463          	blt	a4,a6,ffffffffc0204b06 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0204b02:	1e080263          	beqz	a6,ffffffffc0204ce6 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0204b06:	000ab603          	ld	a2,0(s5)
ffffffffc0204b0a:	46a1                	li	a3,8
ffffffffc0204b0c:	8aae                	mv	s5,a1
ffffffffc0204b0e:	a839                	j	ffffffffc0204b2c <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0204b10:	03000513          	li	a0,48
ffffffffc0204b14:	85a6                	mv	a1,s1
ffffffffc0204b16:	e03e                	sd	a5,0(sp)
ffffffffc0204b18:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204b1a:	85a6                	mv	a1,s1
ffffffffc0204b1c:	07800513          	li	a0,120
ffffffffc0204b20:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204b22:	0aa1                	addi	s5,s5,8
ffffffffc0204b24:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204b28:	6782                	ld	a5,0(sp)
ffffffffc0204b2a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204b2c:	876e                	mv	a4,s11
ffffffffc0204b2e:	85a6                	mv	a1,s1
ffffffffc0204b30:	854a                	mv	a0,s2
ffffffffc0204b32:	e1fff0ef          	jal	ra,ffffffffc0204950 <printnum>
            break;
ffffffffc0204b36:	b5c1                	j	ffffffffc02049f6 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204b38:	000ab603          	ld	a2,0(s5)
ffffffffc0204b3c:	0aa1                	addi	s5,s5,8
ffffffffc0204b3e:	1c060663          	beqz	a2,ffffffffc0204d0a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0204b42:	00160413          	addi	s0,a2,1
ffffffffc0204b46:	17b05c63          	blez	s11,ffffffffc0204cbe <vprintfmt+0x302>
ffffffffc0204b4a:	02d00593          	li	a1,45
ffffffffc0204b4e:	14b79263          	bne	a5,a1,ffffffffc0204c92 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204b52:	00064783          	lbu	a5,0(a2)
ffffffffc0204b56:	0007851b          	sext.w	a0,a5
ffffffffc0204b5a:	c905                	beqz	a0,ffffffffc0204b8a <vprintfmt+0x1ce>
ffffffffc0204b5c:	000cc563          	bltz	s9,ffffffffc0204b66 <vprintfmt+0x1aa>
ffffffffc0204b60:	3cfd                	addiw	s9,s9,-1
ffffffffc0204b62:	036c8263          	beq	s9,s6,ffffffffc0204b86 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204b66:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204b68:	18098463          	beqz	s3,ffffffffc0204cf0 <vprintfmt+0x334>
ffffffffc0204b6c:	3781                	addiw	a5,a5,-32
ffffffffc0204b6e:	18fbf163          	bleu	a5,s7,ffffffffc0204cf0 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204b72:	03f00513          	li	a0,63
ffffffffc0204b76:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204b78:	0405                	addi	s0,s0,1
ffffffffc0204b7a:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204b7e:	3dfd                	addiw	s11,s11,-1
ffffffffc0204b80:	0007851b          	sext.w	a0,a5
ffffffffc0204b84:	fd61                	bnez	a0,ffffffffc0204b5c <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0204b86:	e7b058e3          	blez	s11,ffffffffc02049f6 <vprintfmt+0x3a>
ffffffffc0204b8a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204b8c:	85a6                	mv	a1,s1
ffffffffc0204b8e:	02000513          	li	a0,32
ffffffffc0204b92:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204b94:	e60d81e3          	beqz	s11,ffffffffc02049f6 <vprintfmt+0x3a>
ffffffffc0204b98:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204b9a:	85a6                	mv	a1,s1
ffffffffc0204b9c:	02000513          	li	a0,32
ffffffffc0204ba0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204ba2:	fe0d94e3          	bnez	s11,ffffffffc0204b8a <vprintfmt+0x1ce>
ffffffffc0204ba6:	bd81                	j	ffffffffc02049f6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204ba8:	4705                	li	a4,1
ffffffffc0204baa:	008a8593          	addi	a1,s5,8
ffffffffc0204bae:	01074463          	blt	a4,a6,ffffffffc0204bb6 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204bb2:	12080063          	beqz	a6,ffffffffc0204cd2 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204bb6:	000ab603          	ld	a2,0(s5)
ffffffffc0204bba:	46a9                	li	a3,10
ffffffffc0204bbc:	8aae                	mv	s5,a1
ffffffffc0204bbe:	b7bd                	j	ffffffffc0204b2c <vprintfmt+0x170>
ffffffffc0204bc0:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204bc4:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bc8:	846a                	mv	s0,s10
ffffffffc0204bca:	b5ad                	j	ffffffffc0204a34 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204bcc:	85a6                	mv	a1,s1
ffffffffc0204bce:	02500513          	li	a0,37
ffffffffc0204bd2:	9902                	jalr	s2
            break;
ffffffffc0204bd4:	b50d                	j	ffffffffc02049f6 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204bd6:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204bda:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204bde:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204be0:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204be2:	e40dd9e3          	bgez	s11,ffffffffc0204a34 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204be6:	8de6                	mv	s11,s9
ffffffffc0204be8:	5cfd                	li	s9,-1
ffffffffc0204bea:	b5a9                	j	ffffffffc0204a34 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204bec:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204bf0:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bf4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204bf6:	bd3d                	j	ffffffffc0204a34 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204bf8:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204bfc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c00:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204c02:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204c06:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204c0a:	fcd56ce3          	bltu	a0,a3,ffffffffc0204be2 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204c0e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204c10:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204c14:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204c18:	0196873b          	addw	a4,a3,s9
ffffffffc0204c1c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204c20:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204c24:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204c28:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204c2c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204c30:	fcd57fe3          	bleu	a3,a0,ffffffffc0204c0e <vprintfmt+0x252>
ffffffffc0204c34:	b77d                	j	ffffffffc0204be2 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204c36:	fffdc693          	not	a3,s11
ffffffffc0204c3a:	96fd                	srai	a3,a3,0x3f
ffffffffc0204c3c:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204c40:	00144603          	lbu	a2,1(s0)
ffffffffc0204c44:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c46:	846a                	mv	s0,s10
ffffffffc0204c48:	b3f5                	j	ffffffffc0204a34 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0204c4a:	85a6                	mv	a1,s1
ffffffffc0204c4c:	02500513          	li	a0,37
ffffffffc0204c50:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204c52:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204c56:	02500793          	li	a5,37
ffffffffc0204c5a:	8d22                	mv	s10,s0
ffffffffc0204c5c:	d8f70de3          	beq	a4,a5,ffffffffc02049f6 <vprintfmt+0x3a>
ffffffffc0204c60:	02500713          	li	a4,37
ffffffffc0204c64:	1d7d                	addi	s10,s10,-1
ffffffffc0204c66:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204c6a:	fee79de3          	bne	a5,a4,ffffffffc0204c64 <vprintfmt+0x2a8>
ffffffffc0204c6e:	b361                	j	ffffffffc02049f6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204c70:	00002617          	auipc	a2,0x2
ffffffffc0204c74:	30860613          	addi	a2,a2,776 # ffffffffc0206f78 <error_string+0xd8>
ffffffffc0204c78:	85a6                	mv	a1,s1
ffffffffc0204c7a:	854a                	mv	a0,s2
ffffffffc0204c7c:	0ac000ef          	jal	ra,ffffffffc0204d28 <printfmt>
ffffffffc0204c80:	bb9d                	j	ffffffffc02049f6 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204c82:	00002617          	auipc	a2,0x2
ffffffffc0204c86:	2ee60613          	addi	a2,a2,750 # ffffffffc0206f70 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204c8a:	00002417          	auipc	s0,0x2
ffffffffc0204c8e:	2e740413          	addi	s0,s0,743 # ffffffffc0206f71 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204c92:	8532                	mv	a0,a2
ffffffffc0204c94:	85e6                	mv	a1,s9
ffffffffc0204c96:	e032                	sd	a2,0(sp)
ffffffffc0204c98:	e43e                	sd	a5,8(sp)
ffffffffc0204c9a:	0cc000ef          	jal	ra,ffffffffc0204d66 <strnlen>
ffffffffc0204c9e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204ca2:	6602                	ld	a2,0(sp)
ffffffffc0204ca4:	01b05d63          	blez	s11,ffffffffc0204cbe <vprintfmt+0x302>
ffffffffc0204ca8:	67a2                	ld	a5,8(sp)
ffffffffc0204caa:	2781                	sext.w	a5,a5
ffffffffc0204cac:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204cae:	6522                	ld	a0,8(sp)
ffffffffc0204cb0:	85a6                	mv	a1,s1
ffffffffc0204cb2:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204cb4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204cb6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204cb8:	6602                	ld	a2,0(sp)
ffffffffc0204cba:	fe0d9ae3          	bnez	s11,ffffffffc0204cae <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204cbe:	00064783          	lbu	a5,0(a2)
ffffffffc0204cc2:	0007851b          	sext.w	a0,a5
ffffffffc0204cc6:	e8051be3          	bnez	a0,ffffffffc0204b5c <vprintfmt+0x1a0>
ffffffffc0204cca:	b335                	j	ffffffffc02049f6 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0204ccc:	000aa403          	lw	s0,0(s5)
ffffffffc0204cd0:	bbf1                	j	ffffffffc0204aac <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204cd2:	000ae603          	lwu	a2,0(s5)
ffffffffc0204cd6:	46a9                	li	a3,10
ffffffffc0204cd8:	8aae                	mv	s5,a1
ffffffffc0204cda:	bd89                	j	ffffffffc0204b2c <vprintfmt+0x170>
ffffffffc0204cdc:	000ae603          	lwu	a2,0(s5)
ffffffffc0204ce0:	46c1                	li	a3,16
ffffffffc0204ce2:	8aae                	mv	s5,a1
ffffffffc0204ce4:	b5a1                	j	ffffffffc0204b2c <vprintfmt+0x170>
ffffffffc0204ce6:	000ae603          	lwu	a2,0(s5)
ffffffffc0204cea:	46a1                	li	a3,8
ffffffffc0204cec:	8aae                	mv	s5,a1
ffffffffc0204cee:	bd3d                	j	ffffffffc0204b2c <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204cf0:	9902                	jalr	s2
ffffffffc0204cf2:	b559                	j	ffffffffc0204b78 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204cf4:	85a6                	mv	a1,s1
ffffffffc0204cf6:	02d00513          	li	a0,45
ffffffffc0204cfa:	e03e                	sd	a5,0(sp)
ffffffffc0204cfc:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204cfe:	8ace                	mv	s5,s3
ffffffffc0204d00:	40800633          	neg	a2,s0
ffffffffc0204d04:	46a9                	li	a3,10
ffffffffc0204d06:	6782                	ld	a5,0(sp)
ffffffffc0204d08:	b515                	j	ffffffffc0204b2c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0204d0a:	01b05663          	blez	s11,ffffffffc0204d16 <vprintfmt+0x35a>
ffffffffc0204d0e:	02d00693          	li	a3,45
ffffffffc0204d12:	f6d798e3          	bne	a5,a3,ffffffffc0204c82 <vprintfmt+0x2c6>
ffffffffc0204d16:	00002417          	auipc	s0,0x2
ffffffffc0204d1a:	25b40413          	addi	s0,s0,603 # ffffffffc0206f71 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d1e:	02800513          	li	a0,40
ffffffffc0204d22:	02800793          	li	a5,40
ffffffffc0204d26:	bd1d                	j	ffffffffc0204b5c <vprintfmt+0x1a0>

ffffffffc0204d28 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204d28:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204d2a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204d2e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204d30:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204d32:	ec06                	sd	ra,24(sp)
ffffffffc0204d34:	f83a                	sd	a4,48(sp)
ffffffffc0204d36:	fc3e                	sd	a5,56(sp)
ffffffffc0204d38:	e0c2                	sd	a6,64(sp)
ffffffffc0204d3a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204d3c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204d3e:	c7fff0ef          	jal	ra,ffffffffc02049bc <vprintfmt>
}
ffffffffc0204d42:	60e2                	ld	ra,24(sp)
ffffffffc0204d44:	6161                	addi	sp,sp,80
ffffffffc0204d46:	8082                	ret

ffffffffc0204d48 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204d48:	00054783          	lbu	a5,0(a0)
ffffffffc0204d4c:	cb91                	beqz	a5,ffffffffc0204d60 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204d4e:	4781                	li	a5,0
        cnt ++;
ffffffffc0204d50:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204d52:	00f50733          	add	a4,a0,a5
ffffffffc0204d56:	00074703          	lbu	a4,0(a4)
ffffffffc0204d5a:	fb7d                	bnez	a4,ffffffffc0204d50 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204d5c:	853e                	mv	a0,a5
ffffffffc0204d5e:	8082                	ret
    size_t cnt = 0;
ffffffffc0204d60:	4781                	li	a5,0
}
ffffffffc0204d62:	853e                	mv	a0,a5
ffffffffc0204d64:	8082                	ret

ffffffffc0204d66 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204d66:	c185                	beqz	a1,ffffffffc0204d86 <strnlen+0x20>
ffffffffc0204d68:	00054783          	lbu	a5,0(a0)
ffffffffc0204d6c:	cf89                	beqz	a5,ffffffffc0204d86 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204d6e:	4781                	li	a5,0
ffffffffc0204d70:	a021                	j	ffffffffc0204d78 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204d72:	00074703          	lbu	a4,0(a4)
ffffffffc0204d76:	c711                	beqz	a4,ffffffffc0204d82 <strnlen+0x1c>
        cnt ++;
ffffffffc0204d78:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204d7a:	00f50733          	add	a4,a0,a5
ffffffffc0204d7e:	fef59ae3          	bne	a1,a5,ffffffffc0204d72 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204d82:	853e                	mv	a0,a5
ffffffffc0204d84:	8082                	ret
    size_t cnt = 0;
ffffffffc0204d86:	4781                	li	a5,0
}
ffffffffc0204d88:	853e                	mv	a0,a5
ffffffffc0204d8a:	8082                	ret

ffffffffc0204d8c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204d8c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204d8e:	0585                	addi	a1,a1,1
ffffffffc0204d90:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204d94:	0785                	addi	a5,a5,1
ffffffffc0204d96:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204d9a:	fb75                	bnez	a4,ffffffffc0204d8e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204d9c:	8082                	ret

ffffffffc0204d9e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204d9e:	00054783          	lbu	a5,0(a0)
ffffffffc0204da2:	0005c703          	lbu	a4,0(a1)
ffffffffc0204da6:	cb91                	beqz	a5,ffffffffc0204dba <strcmp+0x1c>
ffffffffc0204da8:	00e79c63          	bne	a5,a4,ffffffffc0204dc0 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0204dac:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204dae:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204db2:	0585                	addi	a1,a1,1
ffffffffc0204db4:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204db8:	fbe5                	bnez	a5,ffffffffc0204da8 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204dba:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204dbc:	9d19                	subw	a0,a0,a4
ffffffffc0204dbe:	8082                	ret
ffffffffc0204dc0:	0007851b          	sext.w	a0,a5
ffffffffc0204dc4:	9d19                	subw	a0,a0,a4
ffffffffc0204dc6:	8082                	ret

ffffffffc0204dc8 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204dc8:	00054783          	lbu	a5,0(a0)
ffffffffc0204dcc:	cb91                	beqz	a5,ffffffffc0204de0 <strchr+0x18>
        if (*s == c) {
ffffffffc0204dce:	00b79563          	bne	a5,a1,ffffffffc0204dd8 <strchr+0x10>
ffffffffc0204dd2:	a809                	j	ffffffffc0204de4 <strchr+0x1c>
ffffffffc0204dd4:	00b78763          	beq	a5,a1,ffffffffc0204de2 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204dd8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204dda:	00054783          	lbu	a5,0(a0)
ffffffffc0204dde:	fbfd                	bnez	a5,ffffffffc0204dd4 <strchr+0xc>
    }
    return NULL;
ffffffffc0204de0:	4501                	li	a0,0
}
ffffffffc0204de2:	8082                	ret
ffffffffc0204de4:	8082                	ret

ffffffffc0204de6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204de6:	ca01                	beqz	a2,ffffffffc0204df6 <memset+0x10>
ffffffffc0204de8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204dea:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204dec:	0785                	addi	a5,a5,1
ffffffffc0204dee:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204df2:	fec79de3          	bne	a5,a2,ffffffffc0204dec <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204df6:	8082                	ret

ffffffffc0204df8 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204df8:	ca19                	beqz	a2,ffffffffc0204e0e <memcpy+0x16>
ffffffffc0204dfa:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204dfc:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204dfe:	0585                	addi	a1,a1,1
ffffffffc0204e00:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204e04:	0785                	addi	a5,a5,1
ffffffffc0204e06:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204e0a:	fec59ae3          	bne	a1,a2,ffffffffc0204dfe <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204e0e:	8082                	ret

ffffffffc0204e10 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204e10:	c21d                	beqz	a2,ffffffffc0204e36 <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc0204e12:	00054783          	lbu	a5,0(a0)
ffffffffc0204e16:	0005c703          	lbu	a4,0(a1)
ffffffffc0204e1a:	962a                	add	a2,a2,a0
ffffffffc0204e1c:	00f70963          	beq	a4,a5,ffffffffc0204e2e <memcmp+0x1e>
ffffffffc0204e20:	a829                	j	ffffffffc0204e3a <memcmp+0x2a>
ffffffffc0204e22:	00054783          	lbu	a5,0(a0)
ffffffffc0204e26:	0005c703          	lbu	a4,0(a1)
ffffffffc0204e2a:	00e79863          	bne	a5,a4,ffffffffc0204e3a <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204e2e:	0505                	addi	a0,a0,1
ffffffffc0204e30:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc0204e32:	fea618e3          	bne	a2,a0,ffffffffc0204e22 <memcmp+0x12>
    }
    return 0;
ffffffffc0204e36:	4501                	li	a0,0
}
ffffffffc0204e38:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204e3a:	40e7853b          	subw	a0,a5,a4
ffffffffc0204e3e:	8082                	ret
