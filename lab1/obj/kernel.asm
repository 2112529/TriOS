
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	229000ef          	jal	ra,80200a4c <memset>

    cons_init();  // init the console
    80200028:	14c000ef          	jal	ra,80200174 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a3458593          	addi	a1,a1,-1484 # 80200a60 <etext+0x2>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a4c50513          	addi	a0,a0,-1460 # 80200a80 <etext+0x22>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>

    print_kerninfo();
    80200040:	060000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	140000ef          	jal	ra,80200184 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0e8000ef          	jal	ra,80200130 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	132000ef          	jal	ra,8020017e <intr_enable>
    
    while (1)
        ;
    80200050:	a001                	j	80200050 <kern_init+0x44>

0000000080200052 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    cons_putc(c);
    8020005a:	11c000ef          	jal	ra,80200176 <cons_putc>
    (*cnt)++;
    8020005e:	401c                	lw	a5,0(s0)
}
    80200060:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
}
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	862a                	mv	a2,a0
    8020007a:	004c                	addi	a1,sp,4
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd650513          	addi	a0,a0,-42 # 80200052 <cputch>
    80200084:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	5b2000ef          	jal	ra,80200646 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	9e650513          	addi	a0,a0,-1562 # 80200a88 <etext+0x2a>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5c58593          	addi	a1,a1,-164 # 8020000c <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	9f050513          	addi	a0,a0,-1552 # 80200aa8 <etext+0x4a>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	99a58593          	addi	a1,a1,-1638 # 80200a5e <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	9fc50513          	addi	a0,a0,-1540 # 80200ac8 <etext+0x6a>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	a0850513          	addi	a0,a0,-1528 # 80200ae8 <etext+0x8a>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	a1450513          	addi	a0,a0,-1516 # 80200b08 <etext+0xaa>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0478793          	addi	a5,a5,-252 # 8020000c <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	a0650513          	addi	a0,a0,-1530 # 80200b28 <etext+0xca>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	f41ff06f          	j	8020006c <cprintf>

0000000080200130 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200130:	1141                	addi	sp,sp,-16
    80200132:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200134:	02000793          	li	a5,32
    80200138:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013c:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200140:	67e1                	lui	a5,0x18
    80200142:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200146:	953e                	add	a0,a0,a5
    80200148:	0a7000ef          	jal	ra,802009ee <sbi_set_timer>
}
    8020014c:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014e:	00004797          	auipc	a5,0x4
    80200152:	ec07b923          	sd	zero,-302(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200156:	00001517          	auipc	a0,0x1
    8020015a:	a0250513          	addi	a0,a0,-1534 # 80200b58 <etext+0xfa>
}
    8020015e:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200160:	f0dff06f          	j	8020006c <cprintf>

0000000080200164 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200164:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200168:	67e1                	lui	a5,0x18
    8020016a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020016e:	953e                	add	a0,a0,a5
    80200170:	07f0006f          	j	802009ee <sbi_set_timer>

0000000080200174 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200174:	8082                	ret

0000000080200176 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200176:	0ff57513          	andi	a0,a0,255
    8020017a:	0590006f          	j	802009d2 <sbi_console_putchar>

000000008020017e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020017e:	100167f3          	csrrsi	a5,sstatus,2
    80200182:	8082                	ret

0000000080200184 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200184:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200188:	00000797          	auipc	a5,0x0
    8020018c:	39c78793          	addi	a5,a5,924 # 80200524 <__alltraps>
    80200190:	10579073          	csrw	stvec,a5
}
    80200194:	8082                	ret

0000000080200196 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200196:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200198:	1141                	addi	sp,sp,-16
    8020019a:	e022                	sd	s0,0(sp)
    8020019c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019e:	00001517          	auipc	a0,0x1
    802001a2:	b4a50513          	addi	a0,a0,-1206 # 80200ce8 <etext+0x28a>
void print_regs(struct pushregs *gpr) {
    802001a6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a8:	ec5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ac:	640c                	ld	a1,8(s0)
    802001ae:	00001517          	auipc	a0,0x1
    802001b2:	b5250513          	addi	a0,a0,-1198 # 80200d00 <etext+0x2a2>
    802001b6:	eb7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001ba:	680c                	ld	a1,16(s0)
    802001bc:	00001517          	auipc	a0,0x1
    802001c0:	b5c50513          	addi	a0,a0,-1188 # 80200d18 <etext+0x2ba>
    802001c4:	ea9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c8:	6c0c                	ld	a1,24(s0)
    802001ca:	00001517          	auipc	a0,0x1
    802001ce:	b6650513          	addi	a0,a0,-1178 # 80200d30 <etext+0x2d2>
    802001d2:	e9bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d6:	700c                	ld	a1,32(s0)
    802001d8:	00001517          	auipc	a0,0x1
    802001dc:	b7050513          	addi	a0,a0,-1168 # 80200d48 <etext+0x2ea>
    802001e0:	e8dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e4:	740c                	ld	a1,40(s0)
    802001e6:	00001517          	auipc	a0,0x1
    802001ea:	b7a50513          	addi	a0,a0,-1158 # 80200d60 <etext+0x302>
    802001ee:	e7fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f2:	780c                	ld	a1,48(s0)
    802001f4:	00001517          	auipc	a0,0x1
    802001f8:	b8450513          	addi	a0,a0,-1148 # 80200d78 <etext+0x31a>
    802001fc:	e71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200200:	7c0c                	ld	a1,56(s0)
    80200202:	00001517          	auipc	a0,0x1
    80200206:	b8e50513          	addi	a0,a0,-1138 # 80200d90 <etext+0x332>
    8020020a:	e63ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020e:	602c                	ld	a1,64(s0)
    80200210:	00001517          	auipc	a0,0x1
    80200214:	b9850513          	addi	a0,a0,-1128 # 80200da8 <etext+0x34a>
    80200218:	e55ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021c:	642c                	ld	a1,72(s0)
    8020021e:	00001517          	auipc	a0,0x1
    80200222:	ba250513          	addi	a0,a0,-1118 # 80200dc0 <etext+0x362>
    80200226:	e47ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022a:	682c                	ld	a1,80(s0)
    8020022c:	00001517          	auipc	a0,0x1
    80200230:	bac50513          	addi	a0,a0,-1108 # 80200dd8 <etext+0x37a>
    80200234:	e39ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200238:	6c2c                	ld	a1,88(s0)
    8020023a:	00001517          	auipc	a0,0x1
    8020023e:	bb650513          	addi	a0,a0,-1098 # 80200df0 <etext+0x392>
    80200242:	e2bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200246:	702c                	ld	a1,96(s0)
    80200248:	00001517          	auipc	a0,0x1
    8020024c:	bc050513          	addi	a0,a0,-1088 # 80200e08 <etext+0x3aa>
    80200250:	e1dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200254:	742c                	ld	a1,104(s0)
    80200256:	00001517          	auipc	a0,0x1
    8020025a:	bca50513          	addi	a0,a0,-1078 # 80200e20 <etext+0x3c2>
    8020025e:	e0fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200262:	782c                	ld	a1,112(s0)
    80200264:	00001517          	auipc	a0,0x1
    80200268:	bd450513          	addi	a0,a0,-1068 # 80200e38 <etext+0x3da>
    8020026c:	e01ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200270:	7c2c                	ld	a1,120(s0)
    80200272:	00001517          	auipc	a0,0x1
    80200276:	bde50513          	addi	a0,a0,-1058 # 80200e50 <etext+0x3f2>
    8020027a:	df3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027e:	604c                	ld	a1,128(s0)
    80200280:	00001517          	auipc	a0,0x1
    80200284:	be850513          	addi	a0,a0,-1048 # 80200e68 <etext+0x40a>
    80200288:	de5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028c:	644c                	ld	a1,136(s0)
    8020028e:	00001517          	auipc	a0,0x1
    80200292:	bf250513          	addi	a0,a0,-1038 # 80200e80 <etext+0x422>
    80200296:	dd7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029a:	684c                	ld	a1,144(s0)
    8020029c:	00001517          	auipc	a0,0x1
    802002a0:	bfc50513          	addi	a0,a0,-1028 # 80200e98 <etext+0x43a>
    802002a4:	dc9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a8:	6c4c                	ld	a1,152(s0)
    802002aa:	00001517          	auipc	a0,0x1
    802002ae:	c0650513          	addi	a0,a0,-1018 # 80200eb0 <etext+0x452>
    802002b2:	dbbff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b6:	704c                	ld	a1,160(s0)
    802002b8:	00001517          	auipc	a0,0x1
    802002bc:	c1050513          	addi	a0,a0,-1008 # 80200ec8 <etext+0x46a>
    802002c0:	dadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c4:	744c                	ld	a1,168(s0)
    802002c6:	00001517          	auipc	a0,0x1
    802002ca:	c1a50513          	addi	a0,a0,-998 # 80200ee0 <etext+0x482>
    802002ce:	d9fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d2:	784c                	ld	a1,176(s0)
    802002d4:	00001517          	auipc	a0,0x1
    802002d8:	c2450513          	addi	a0,a0,-988 # 80200ef8 <etext+0x49a>
    802002dc:	d91ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e0:	7c4c                	ld	a1,184(s0)
    802002e2:	00001517          	auipc	a0,0x1
    802002e6:	c2e50513          	addi	a0,a0,-978 # 80200f10 <etext+0x4b2>
    802002ea:	d83ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ee:	606c                	ld	a1,192(s0)
    802002f0:	00001517          	auipc	a0,0x1
    802002f4:	c3850513          	addi	a0,a0,-968 # 80200f28 <etext+0x4ca>
    802002f8:	d75ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fc:	646c                	ld	a1,200(s0)
    802002fe:	00001517          	auipc	a0,0x1
    80200302:	c4250513          	addi	a0,a0,-958 # 80200f40 <etext+0x4e2>
    80200306:	d67ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030a:	686c                	ld	a1,208(s0)
    8020030c:	00001517          	auipc	a0,0x1
    80200310:	c4c50513          	addi	a0,a0,-948 # 80200f58 <etext+0x4fa>
    80200314:	d59ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200318:	6c6c                	ld	a1,216(s0)
    8020031a:	00001517          	auipc	a0,0x1
    8020031e:	c5650513          	addi	a0,a0,-938 # 80200f70 <etext+0x512>
    80200322:	d4bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200326:	706c                	ld	a1,224(s0)
    80200328:	00001517          	auipc	a0,0x1
    8020032c:	c6050513          	addi	a0,a0,-928 # 80200f88 <etext+0x52a>
    80200330:	d3dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200334:	746c                	ld	a1,232(s0)
    80200336:	00001517          	auipc	a0,0x1
    8020033a:	c6a50513          	addi	a0,a0,-918 # 80200fa0 <etext+0x542>
    8020033e:	d2fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200342:	786c                	ld	a1,240(s0)
    80200344:	00001517          	auipc	a0,0x1
    80200348:	c7450513          	addi	a0,a0,-908 # 80200fb8 <etext+0x55a>
    8020034c:	d21ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	7c6c                	ld	a1,248(s0)
}
    80200352:	6402                	ld	s0,0(sp)
    80200354:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	00001517          	auipc	a0,0x1
    8020035a:	c7a50513          	addi	a0,a0,-902 # 80200fd0 <etext+0x572>
}
    8020035e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200360:	d0dff06f          	j	8020006c <cprintf>

0000000080200364 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200364:	1141                	addi	sp,sp,-16
    80200366:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200368:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036c:	00001517          	auipc	a0,0x1
    80200370:	c7c50513          	addi	a0,a0,-900 # 80200fe8 <etext+0x58a>
void print_trapframe(struct trapframe *tf) {
    80200374:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200376:	cf7ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020037a:	8522                	mv	a0,s0
    8020037c:	e1bff0ef          	jal	ra,80200196 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200380:	10043583          	ld	a1,256(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	c7c50513          	addi	a0,a0,-900 # 80201000 <etext+0x5a2>
    8020038c:	ce1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200390:	10843583          	ld	a1,264(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	c8450513          	addi	a0,a0,-892 # 80201018 <etext+0x5ba>
    8020039c:	cd1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a0:	11043583          	ld	a1,272(s0)
    802003a4:	00001517          	auipc	a0,0x1
    802003a8:	c8c50513          	addi	a0,a0,-884 # 80201030 <etext+0x5d2>
    802003ac:	cc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	11843583          	ld	a1,280(s0)
}
    802003b4:	6402                	ld	s0,0(sp)
    802003b6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	00001517          	auipc	a0,0x1
    802003bc:	c9050513          	addi	a0,a0,-880 # 80201048 <etext+0x5ea>
}
    802003c0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c2:	cabff06f          	j	8020006c <cprintf>

00000000802003c6 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c6:	11853783          	ld	a5,280(a0)
    802003ca:	577d                	li	a4,-1
    802003cc:	8305                	srli	a4,a4,0x1
    802003ce:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d0:	472d                	li	a4,11
    802003d2:	08f76763          	bltu	a4,a5,80200460 <interrupt_handler+0x9a>
    802003d6:	00000717          	auipc	a4,0x0
    802003da:	79e70713          	addi	a4,a4,1950 # 80200b74 <etext+0x116>
    802003de:	078a                	slli	a5,a5,0x2
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	439c                	lw	a5,0(a5)
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	8b050513          	addi	a0,a0,-1872 # 80200c98 <etext+0x23a>
    802003f0:	c7dff06f          	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f4:	00001517          	auipc	a0,0x1
    802003f8:	88450513          	addi	a0,a0,-1916 # 80200c78 <etext+0x21a>
    802003fc:	c71ff06f          	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    80200400:	00001517          	auipc	a0,0x1
    80200404:	83850513          	addi	a0,a0,-1992 # 80200c38 <etext+0x1da>
    80200408:	c65ff06f          	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    8020040c:	00001517          	auipc	a0,0x1
    80200410:	84c50513          	addi	a0,a0,-1972 # 80200c58 <etext+0x1fa>
    80200414:	c59ff06f          	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200418:	00001517          	auipc	a0,0x1
    8020041c:	8b050513          	addi	a0,a0,-1872 # 80200cc8 <etext+0x26a>
    80200420:	c4dff06f          	j	8020006c <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200424:	1141                	addi	sp,sp,-16
    80200426:	e406                	sd	ra,8(sp)
            clock_set_next_event();
    80200428:	d3dff0ef          	jal	ra,80200164 <clock_set_next_event>
            if(ticks==100){
    8020042c:	00004797          	auipc	a5,0x4
    80200430:	bf478793          	addi	a5,a5,-1036 # 80204020 <ticks>
    80200434:	6394                	ld	a3,0(a5)
    80200436:	06400713          	li	a4,100
    8020043a:	02e68563          	beq	a3,a4,80200464 <interrupt_handler+0x9e>
            else ticks++;
    8020043e:	639c                	ld	a5,0(a5)
    80200440:	00004717          	auipc	a4,0x4
    80200444:	bd070713          	addi	a4,a4,-1072 # 80204010 <edata>
    80200448:	0785                	addi	a5,a5,1
    8020044a:	00004697          	auipc	a3,0x4
    8020044e:	bcf6bb23          	sd	a5,-1066(a3) # 80204020 <ticks>
            if(num==10)sbi_shutdown();
    80200452:	6318                	ld	a4,0(a4)
    80200454:	47a9                	li	a5,10
    80200456:	02f70e63          	beq	a4,a5,80200492 <interrupt_handler+0xcc>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020045a:	60a2                	ld	ra,8(sp)
    8020045c:	0141                	addi	sp,sp,16
    8020045e:	8082                	ret
            print_trapframe(tf);
    80200460:	f05ff06f          	j	80200364 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200464:	06400593          	li	a1,100
    80200468:	00001517          	auipc	a0,0x1
    8020046c:	85050513          	addi	a0,a0,-1968 # 80200cb8 <etext+0x25a>
    80200470:	bfdff0ef          	jal	ra,8020006c <cprintf>
                num++;
    80200474:	00004717          	auipc	a4,0x4
    80200478:	b9c70713          	addi	a4,a4,-1124 # 80204010 <edata>
                ticks=0;
    8020047c:	00004797          	auipc	a5,0x4
    80200480:	ba07b223          	sd	zero,-1116(a5) # 80204020 <ticks>
                num++;
    80200484:	631c                	ld	a5,0(a4)
    80200486:	0785                	addi	a5,a5,1
    80200488:	00004697          	auipc	a3,0x4
    8020048c:	b8f6b423          	sd	a5,-1144(a3) # 80204010 <edata>
    80200490:	b7c9                	j	80200452 <interrupt_handler+0x8c>
}
    80200492:	60a2                	ld	ra,8(sp)
    80200494:	0141                	addi	sp,sp,16
            if(num==10)sbi_shutdown();
    80200496:	5740006f          	j	80200a0a <sbi_shutdown>

000000008020049a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020049a:	11853783          	ld	a5,280(a0)
    8020049e:	472d                	li	a4,11
    802004a0:	02f76863          	bltu	a4,a5,802004d0 <exception_handler+0x36>
    802004a4:	4705                	li	a4,1
    802004a6:	00f71733          	sll	a4,a4,a5
    802004aa:	6785                	lui	a5,0x1
    802004ac:	17cd                	addi	a5,a5,-13
    802004ae:	8ff9                	and	a5,a5,a4
    802004b0:	ef99                	bnez	a5,802004ce <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004b2:	1141                	addi	sp,sp,-16
    802004b4:	e022                	sd	s0,0(sp)
    802004b6:	e406                	sd	ra,8(sp)
    802004b8:	00877793          	andi	a5,a4,8
    802004bc:	842a                	mv	s0,a0
    802004be:	eb9d                	bnez	a5,802004f4 <exception_handler+0x5a>
    802004c0:	8b11                	andi	a4,a4,4
    802004c2:	eb09                	bnez	a4,802004d4 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004c4:	6402                	ld	s0,0(sp)
    802004c6:	60a2                	ld	ra,8(sp)
    802004c8:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004ca:	e9bff06f          	j	80200364 <print_trapframe>
    802004ce:	8082                	ret
    802004d0:	e95ff06f          	j	80200364 <print_trapframe>
            cprintf("Exception type:Illegal instruction");
    802004d4:	00000517          	auipc	a0,0x0
    802004d8:	6d450513          	addi	a0,a0,1748 # 80200ba8 <etext+0x14a>
    802004dc:	b91ff0ef          	jal	ra,8020006c <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->gpr.ra);
    802004e0:	640c                	ld	a1,8(s0)
}
    802004e2:	6402                	ld	s0,0(sp)
    802004e4:	60a2                	ld	ra,8(sp)
            cprintf("Illegal instruction caught at 0x%08x\n", tf->gpr.ra);
    802004e6:	00000517          	auipc	a0,0x0
    802004ea:	6ea50513          	addi	a0,a0,1770 # 80200bd0 <etext+0x172>
}
    802004ee:	0141                	addi	sp,sp,16
            cprintf("ebreak caught at 0x%08x\n", tf->gpr.ra);
    802004f0:	b7dff06f          	j	8020006c <cprintf>
            cprintf("Exception type: breakpoint");
    802004f4:	00000517          	auipc	a0,0x0
    802004f8:	70450513          	addi	a0,a0,1796 # 80200bf8 <etext+0x19a>
    802004fc:	b71ff0ef          	jal	ra,8020006c <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->gpr.ra);
    80200500:	640c                	ld	a1,8(s0)
}
    80200502:	6402                	ld	s0,0(sp)
    80200504:	60a2                	ld	ra,8(sp)
            cprintf("ebreak caught at 0x%08x\n", tf->gpr.ra);
    80200506:	00000517          	auipc	a0,0x0
    8020050a:	71250513          	addi	a0,a0,1810 # 80200c18 <etext+0x1ba>
}
    8020050e:	0141                	addi	sp,sp,16
            cprintf("ebreak caught at 0x%08x\n", tf->gpr.ra);
    80200510:	b5dff06f          	j	8020006c <cprintf>

0000000080200514 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200514:	11853783          	ld	a5,280(a0)
    80200518:	0007c463          	bltz	a5,80200520 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    8020051c:	f7fff06f          	j	8020049a <exception_handler>
        interrupt_handler(tf);
    80200520:	ea7ff06f          	j	802003c6 <interrupt_handler>

0000000080200524 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200524:	14011073          	csrw	sscratch,sp
    80200528:	712d                	addi	sp,sp,-288
    8020052a:	e002                	sd	zero,0(sp)
    8020052c:	e406                	sd	ra,8(sp)
    8020052e:	ec0e                	sd	gp,24(sp)
    80200530:	f012                	sd	tp,32(sp)
    80200532:	f416                	sd	t0,40(sp)
    80200534:	f81a                	sd	t1,48(sp)
    80200536:	fc1e                	sd	t2,56(sp)
    80200538:	e0a2                	sd	s0,64(sp)
    8020053a:	e4a6                	sd	s1,72(sp)
    8020053c:	e8aa                	sd	a0,80(sp)
    8020053e:	ecae                	sd	a1,88(sp)
    80200540:	f0b2                	sd	a2,96(sp)
    80200542:	f4b6                	sd	a3,104(sp)
    80200544:	f8ba                	sd	a4,112(sp)
    80200546:	fcbe                	sd	a5,120(sp)
    80200548:	e142                	sd	a6,128(sp)
    8020054a:	e546                	sd	a7,136(sp)
    8020054c:	e94a                	sd	s2,144(sp)
    8020054e:	ed4e                	sd	s3,152(sp)
    80200550:	f152                	sd	s4,160(sp)
    80200552:	f556                	sd	s5,168(sp)
    80200554:	f95a                	sd	s6,176(sp)
    80200556:	fd5e                	sd	s7,184(sp)
    80200558:	e1e2                	sd	s8,192(sp)
    8020055a:	e5e6                	sd	s9,200(sp)
    8020055c:	e9ea                	sd	s10,208(sp)
    8020055e:	edee                	sd	s11,216(sp)
    80200560:	f1f2                	sd	t3,224(sp)
    80200562:	f5f6                	sd	t4,232(sp)
    80200564:	f9fa                	sd	t5,240(sp)
    80200566:	fdfe                	sd	t6,248(sp)
    80200568:	14001473          	csrrw	s0,sscratch,zero
    8020056c:	100024f3          	csrr	s1,sstatus
    80200570:	14102973          	csrr	s2,sepc
    80200574:	143029f3          	csrr	s3,stval
    80200578:	14202a73          	csrr	s4,scause
    8020057c:	e822                	sd	s0,16(sp)
    8020057e:	e226                	sd	s1,256(sp)
    80200580:	e64a                	sd	s2,264(sp)
    80200582:	ea4e                	sd	s3,272(sp)
    80200584:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200586:	850a                	mv	a0,sp
    jal trap
    80200588:	f8dff0ef          	jal	ra,80200514 <trap>

000000008020058c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    8020058c:	6492                	ld	s1,256(sp)
    8020058e:	6932                	ld	s2,264(sp)
    80200590:	10049073          	csrw	sstatus,s1
    80200594:	14191073          	csrw	sepc,s2
    80200598:	60a2                	ld	ra,8(sp)
    8020059a:	61e2                	ld	gp,24(sp)
    8020059c:	7202                	ld	tp,32(sp)
    8020059e:	72a2                	ld	t0,40(sp)
    802005a0:	7342                	ld	t1,48(sp)
    802005a2:	73e2                	ld	t2,56(sp)
    802005a4:	6406                	ld	s0,64(sp)
    802005a6:	64a6                	ld	s1,72(sp)
    802005a8:	6546                	ld	a0,80(sp)
    802005aa:	65e6                	ld	a1,88(sp)
    802005ac:	7606                	ld	a2,96(sp)
    802005ae:	76a6                	ld	a3,104(sp)
    802005b0:	7746                	ld	a4,112(sp)
    802005b2:	77e6                	ld	a5,120(sp)
    802005b4:	680a                	ld	a6,128(sp)
    802005b6:	68aa                	ld	a7,136(sp)
    802005b8:	694a                	ld	s2,144(sp)
    802005ba:	69ea                	ld	s3,152(sp)
    802005bc:	7a0a                	ld	s4,160(sp)
    802005be:	7aaa                	ld	s5,168(sp)
    802005c0:	7b4a                	ld	s6,176(sp)
    802005c2:	7bea                	ld	s7,184(sp)
    802005c4:	6c0e                	ld	s8,192(sp)
    802005c6:	6cae                	ld	s9,200(sp)
    802005c8:	6d4e                	ld	s10,208(sp)
    802005ca:	6dee                	ld	s11,216(sp)
    802005cc:	7e0e                	ld	t3,224(sp)
    802005ce:	7eae                	ld	t4,232(sp)
    802005d0:	7f4e                	ld	t5,240(sp)
    802005d2:	7fee                	ld	t6,248(sp)
    802005d4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005d6:	10200073          	sret

00000000802005da <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005da:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005de:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005e0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005e4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005e6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005ea:	f022                	sd	s0,32(sp)
    802005ec:	ec26                	sd	s1,24(sp)
    802005ee:	e84a                	sd	s2,16(sp)
    802005f0:	f406                	sd	ra,40(sp)
    802005f2:	e44e                	sd	s3,8(sp)
    802005f4:	84aa                	mv	s1,a0
    802005f6:	892e                	mv	s2,a1
    802005f8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005fc:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    802005fe:	03067e63          	bleu	a6,a2,8020063a <printnum+0x60>
    80200602:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200604:	00805763          	blez	s0,80200612 <printnum+0x38>
    80200608:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020060a:	85ca                	mv	a1,s2
    8020060c:	854e                	mv	a0,s3
    8020060e:	9482                	jalr	s1
        while (-- width > 0)
    80200610:	fc65                	bnez	s0,80200608 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200612:	1a02                	slli	s4,s4,0x20
    80200614:	020a5a13          	srli	s4,s4,0x20
    80200618:	00001797          	auipc	a5,0x1
    8020061c:	bd878793          	addi	a5,a5,-1064 # 802011f0 <error_string+0x38>
    80200620:	9a3e                	add	s4,s4,a5
}
    80200622:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200624:	000a4503          	lbu	a0,0(s4)
}
    80200628:	70a2                	ld	ra,40(sp)
    8020062a:	69a2                	ld	s3,8(sp)
    8020062c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020062e:	85ca                	mv	a1,s2
    80200630:	8326                	mv	t1,s1
}
    80200632:	6942                	ld	s2,16(sp)
    80200634:	64e2                	ld	s1,24(sp)
    80200636:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200638:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020063a:	03065633          	divu	a2,a2,a6
    8020063e:	8722                	mv	a4,s0
    80200640:	f9bff0ef          	jal	ra,802005da <printnum>
    80200644:	b7f9                	j	80200612 <printnum+0x38>

0000000080200646 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200646:	7119                	addi	sp,sp,-128
    80200648:	f4a6                	sd	s1,104(sp)
    8020064a:	f0ca                	sd	s2,96(sp)
    8020064c:	e8d2                	sd	s4,80(sp)
    8020064e:	e4d6                	sd	s5,72(sp)
    80200650:	e0da                	sd	s6,64(sp)
    80200652:	fc5e                	sd	s7,56(sp)
    80200654:	f862                	sd	s8,48(sp)
    80200656:	f06a                	sd	s10,32(sp)
    80200658:	fc86                	sd	ra,120(sp)
    8020065a:	f8a2                	sd	s0,112(sp)
    8020065c:	ecce                	sd	s3,88(sp)
    8020065e:	f466                	sd	s9,40(sp)
    80200660:	ec6e                	sd	s11,24(sp)
    80200662:	892a                	mv	s2,a0
    80200664:	84ae                	mv	s1,a1
    80200666:	8d32                	mv	s10,a2
    80200668:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020066a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    8020066c:	00001a17          	auipc	s4,0x1
    80200670:	9f0a0a13          	addi	s4,s4,-1552 # 8020105c <etext+0x5fe>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200674:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200678:	00001c17          	auipc	s8,0x1
    8020067c:	b40c0c13          	addi	s8,s8,-1216 # 802011b8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200680:	000d4503          	lbu	a0,0(s10)
    80200684:	02500793          	li	a5,37
    80200688:	001d0413          	addi	s0,s10,1
    8020068c:	00f50e63          	beq	a0,a5,802006a8 <vprintfmt+0x62>
            if (ch == '\0') {
    80200690:	c521                	beqz	a0,802006d8 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200692:	02500993          	li	s3,37
    80200696:	a011                	j	8020069a <vprintfmt+0x54>
            if (ch == '\0') {
    80200698:	c121                	beqz	a0,802006d8 <vprintfmt+0x92>
            putch(ch, putdat);
    8020069a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020069c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    8020069e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a0:	fff44503          	lbu	a0,-1(s0)
    802006a4:	ff351ae3          	bne	a0,s3,80200698 <vprintfmt+0x52>
    802006a8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006ac:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006b0:	4981                	li	s3,0
    802006b2:	4801                	li	a6,0
        width = precision = -1;
    802006b4:	5cfd                	li	s9,-1
    802006b6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802006b8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802006bc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006be:	fdd6069b          	addiw	a3,a2,-35
    802006c2:	0ff6f693          	andi	a3,a3,255
    802006c6:	00140d13          	addi	s10,s0,1
    802006ca:	20d5e563          	bltu	a1,a3,802008d4 <vprintfmt+0x28e>
    802006ce:	068a                	slli	a3,a3,0x2
    802006d0:	96d2                	add	a3,a3,s4
    802006d2:	4294                	lw	a3,0(a3)
    802006d4:	96d2                	add	a3,a3,s4
    802006d6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006d8:	70e6                	ld	ra,120(sp)
    802006da:	7446                	ld	s0,112(sp)
    802006dc:	74a6                	ld	s1,104(sp)
    802006de:	7906                	ld	s2,96(sp)
    802006e0:	69e6                	ld	s3,88(sp)
    802006e2:	6a46                	ld	s4,80(sp)
    802006e4:	6aa6                	ld	s5,72(sp)
    802006e6:	6b06                	ld	s6,64(sp)
    802006e8:	7be2                	ld	s7,56(sp)
    802006ea:	7c42                	ld	s8,48(sp)
    802006ec:	7ca2                	ld	s9,40(sp)
    802006ee:	7d02                	ld	s10,32(sp)
    802006f0:	6de2                	ld	s11,24(sp)
    802006f2:	6109                	addi	sp,sp,128
    802006f4:	8082                	ret
    if (lflag >= 2) {
    802006f6:	4705                	li	a4,1
    802006f8:	008a8593          	addi	a1,s5,8
    802006fc:	01074463          	blt	a4,a6,80200704 <vprintfmt+0xbe>
    else if (lflag) {
    80200700:	26080363          	beqz	a6,80200966 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200704:	000ab603          	ld	a2,0(s5)
    80200708:	46c1                	li	a3,16
    8020070a:	8aae                	mv	s5,a1
    8020070c:	a06d                	j	802007b6 <vprintfmt+0x170>
            goto reswitch;
    8020070e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200712:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200714:	846a                	mv	s0,s10
            goto reswitch;
    80200716:	b765                	j	802006be <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    80200718:	000aa503          	lw	a0,0(s5)
    8020071c:	85a6                	mv	a1,s1
    8020071e:	0aa1                	addi	s5,s5,8
    80200720:	9902                	jalr	s2
            break;
    80200722:	bfb9                	j	80200680 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200724:	4705                	li	a4,1
    80200726:	008a8993          	addi	s3,s5,8
    8020072a:	01074463          	blt	a4,a6,80200732 <vprintfmt+0xec>
    else if (lflag) {
    8020072e:	22080463          	beqz	a6,80200956 <vprintfmt+0x310>
        return va_arg(*ap, long);
    80200732:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    80200736:	24044463          	bltz	s0,8020097e <vprintfmt+0x338>
            num = getint(&ap, lflag);
    8020073a:	8622                	mv	a2,s0
    8020073c:	8ace                	mv	s5,s3
    8020073e:	46a9                	li	a3,10
    80200740:	a89d                	j	802007b6 <vprintfmt+0x170>
            err = va_arg(ap, int);
    80200742:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200746:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200748:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020074a:	41f7d69b          	sraiw	a3,a5,0x1f
    8020074e:	8fb5                	xor	a5,a5,a3
    80200750:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200754:	1ad74363          	blt	a4,a3,802008fa <vprintfmt+0x2b4>
    80200758:	00369793          	slli	a5,a3,0x3
    8020075c:	97e2                	add	a5,a5,s8
    8020075e:	639c                	ld	a5,0(a5)
    80200760:	18078d63          	beqz	a5,802008fa <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200764:	86be                	mv	a3,a5
    80200766:	00001617          	auipc	a2,0x1
    8020076a:	b3a60613          	addi	a2,a2,-1222 # 802012a0 <error_string+0xe8>
    8020076e:	85a6                	mv	a1,s1
    80200770:	854a                	mv	a0,s2
    80200772:	240000ef          	jal	ra,802009b2 <printfmt>
    80200776:	b729                	j	80200680 <vprintfmt+0x3a>
            lflag ++;
    80200778:	00144603          	lbu	a2,1(s0)
    8020077c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020077e:	846a                	mv	s0,s10
            goto reswitch;
    80200780:	bf3d                	j	802006be <vprintfmt+0x78>
    if (lflag >= 2) {
    80200782:	4705                	li	a4,1
    80200784:	008a8593          	addi	a1,s5,8
    80200788:	01074463          	blt	a4,a6,80200790 <vprintfmt+0x14a>
    else if (lflag) {
    8020078c:	1e080263          	beqz	a6,80200970 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    80200790:	000ab603          	ld	a2,0(s5)
    80200794:	46a1                	li	a3,8
    80200796:	8aae                	mv	s5,a1
    80200798:	a839                	j	802007b6 <vprintfmt+0x170>
            putch('0', putdat);
    8020079a:	03000513          	li	a0,48
    8020079e:	85a6                	mv	a1,s1
    802007a0:	e03e                	sd	a5,0(sp)
    802007a2:	9902                	jalr	s2
            putch('x', putdat);
    802007a4:	85a6                	mv	a1,s1
    802007a6:	07800513          	li	a0,120
    802007aa:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007ac:	0aa1                	addi	s5,s5,8
    802007ae:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007b2:	6782                	ld	a5,0(sp)
    802007b4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802007b6:	876e                	mv	a4,s11
    802007b8:	85a6                	mv	a1,s1
    802007ba:	854a                	mv	a0,s2
    802007bc:	e1fff0ef          	jal	ra,802005da <printnum>
            break;
    802007c0:	b5c1                	j	80200680 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007c2:	000ab603          	ld	a2,0(s5)
    802007c6:	0aa1                	addi	s5,s5,8
    802007c8:	1c060663          	beqz	a2,80200994 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    802007cc:	00160413          	addi	s0,a2,1
    802007d0:	17b05c63          	blez	s11,80200948 <vprintfmt+0x302>
    802007d4:	02d00593          	li	a1,45
    802007d8:	14b79263          	bne	a5,a1,8020091c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007dc:	00064783          	lbu	a5,0(a2)
    802007e0:	0007851b          	sext.w	a0,a5
    802007e4:	c905                	beqz	a0,80200814 <vprintfmt+0x1ce>
    802007e6:	000cc563          	bltz	s9,802007f0 <vprintfmt+0x1aa>
    802007ea:	3cfd                	addiw	s9,s9,-1
    802007ec:	036c8263          	beq	s9,s6,80200810 <vprintfmt+0x1ca>
                    putch('?', putdat);
    802007f0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    802007f2:	18098463          	beqz	s3,8020097a <vprintfmt+0x334>
    802007f6:	3781                	addiw	a5,a5,-32
    802007f8:	18fbf163          	bleu	a5,s7,8020097a <vprintfmt+0x334>
                    putch('?', putdat);
    802007fc:	03f00513          	li	a0,63
    80200800:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200802:	0405                	addi	s0,s0,1
    80200804:	fff44783          	lbu	a5,-1(s0)
    80200808:	3dfd                	addiw	s11,s11,-1
    8020080a:	0007851b          	sext.w	a0,a5
    8020080e:	fd61                	bnez	a0,802007e6 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200810:	e7b058e3          	blez	s11,80200680 <vprintfmt+0x3a>
    80200814:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200816:	85a6                	mv	a1,s1
    80200818:	02000513          	li	a0,32
    8020081c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020081e:	e60d81e3          	beqz	s11,80200680 <vprintfmt+0x3a>
    80200822:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200824:	85a6                	mv	a1,s1
    80200826:	02000513          	li	a0,32
    8020082a:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020082c:	fe0d94e3          	bnez	s11,80200814 <vprintfmt+0x1ce>
    80200830:	bd81                	j	80200680 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200832:	4705                	li	a4,1
    80200834:	008a8593          	addi	a1,s5,8
    80200838:	01074463          	blt	a4,a6,80200840 <vprintfmt+0x1fa>
    else if (lflag) {
    8020083c:	12080063          	beqz	a6,8020095c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200840:	000ab603          	ld	a2,0(s5)
    80200844:	46a9                	li	a3,10
    80200846:	8aae                	mv	s5,a1
    80200848:	b7bd                	j	802007b6 <vprintfmt+0x170>
    8020084a:	00144603          	lbu	a2,1(s0)
            padc = '-';
    8020084e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    80200852:	846a                	mv	s0,s10
    80200854:	b5ad                	j	802006be <vprintfmt+0x78>
            putch(ch, putdat);
    80200856:	85a6                	mv	a1,s1
    80200858:	02500513          	li	a0,37
    8020085c:	9902                	jalr	s2
            break;
    8020085e:	b50d                	j	80200680 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200860:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200864:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200868:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020086a:	846a                	mv	s0,s10
            if (width < 0)
    8020086c:	e40dd9e3          	bgez	s11,802006be <vprintfmt+0x78>
                width = precision, precision = -1;
    80200870:	8de6                	mv	s11,s9
    80200872:	5cfd                	li	s9,-1
    80200874:	b5a9                	j	802006be <vprintfmt+0x78>
            goto reswitch;
    80200876:	00144603          	lbu	a2,1(s0)
            padc = '0';
    8020087a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    8020087e:	846a                	mv	s0,s10
            goto reswitch;
    80200880:	bd3d                	j	802006be <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    80200882:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    80200886:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020088a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    8020088c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200890:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200894:	fcd56ce3          	bltu	a0,a3,8020086c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    80200898:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020089a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    8020089e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802008a2:	0196873b          	addw	a4,a3,s9
    802008a6:	0017171b          	slliw	a4,a4,0x1
    802008aa:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802008ae:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802008b2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802008b6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008ba:	fcd57fe3          	bleu	a3,a0,80200898 <vprintfmt+0x252>
    802008be:	b77d                	j	8020086c <vprintfmt+0x226>
            if (width < 0)
    802008c0:	fffdc693          	not	a3,s11
    802008c4:	96fd                	srai	a3,a3,0x3f
    802008c6:	00ddfdb3          	and	s11,s11,a3
    802008ca:	00144603          	lbu	a2,1(s0)
    802008ce:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802008d0:	846a                	mv	s0,s10
    802008d2:	b3f5                	j	802006be <vprintfmt+0x78>
            putch('%', putdat);
    802008d4:	85a6                	mv	a1,s1
    802008d6:	02500513          	li	a0,37
    802008da:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802008dc:	fff44703          	lbu	a4,-1(s0)
    802008e0:	02500793          	li	a5,37
    802008e4:	8d22                	mv	s10,s0
    802008e6:	d8f70de3          	beq	a4,a5,80200680 <vprintfmt+0x3a>
    802008ea:	02500713          	li	a4,37
    802008ee:	1d7d                	addi	s10,s10,-1
    802008f0:	fffd4783          	lbu	a5,-1(s10)
    802008f4:	fee79de3          	bne	a5,a4,802008ee <vprintfmt+0x2a8>
    802008f8:	b361                	j	80200680 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008fa:	00001617          	auipc	a2,0x1
    802008fe:	99660613          	addi	a2,a2,-1642 # 80201290 <error_string+0xd8>
    80200902:	85a6                	mv	a1,s1
    80200904:	854a                	mv	a0,s2
    80200906:	0ac000ef          	jal	ra,802009b2 <printfmt>
    8020090a:	bb9d                	j	80200680 <vprintfmt+0x3a>
                p = "(null)";
    8020090c:	00001617          	auipc	a2,0x1
    80200910:	97c60613          	addi	a2,a2,-1668 # 80201288 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200914:	00001417          	auipc	s0,0x1
    80200918:	97540413          	addi	s0,s0,-1675 # 80201289 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020091c:	8532                	mv	a0,a2
    8020091e:	85e6                	mv	a1,s9
    80200920:	e032                	sd	a2,0(sp)
    80200922:	e43e                	sd	a5,8(sp)
    80200924:	102000ef          	jal	ra,80200a26 <strnlen>
    80200928:	40ad8dbb          	subw	s11,s11,a0
    8020092c:	6602                	ld	a2,0(sp)
    8020092e:	01b05d63          	blez	s11,80200948 <vprintfmt+0x302>
    80200932:	67a2                	ld	a5,8(sp)
    80200934:	2781                	sext.w	a5,a5
    80200936:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200938:	6522                	ld	a0,8(sp)
    8020093a:	85a6                	mv	a1,s1
    8020093c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020093e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200940:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200942:	6602                	ld	a2,0(sp)
    80200944:	fe0d9ae3          	bnez	s11,80200938 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200948:	00064783          	lbu	a5,0(a2)
    8020094c:	0007851b          	sext.w	a0,a5
    80200950:	e8051be3          	bnez	a0,802007e6 <vprintfmt+0x1a0>
    80200954:	b335                	j	80200680 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    80200956:	000aa403          	lw	s0,0(s5)
    8020095a:	bbf1                	j	80200736 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    8020095c:	000ae603          	lwu	a2,0(s5)
    80200960:	46a9                	li	a3,10
    80200962:	8aae                	mv	s5,a1
    80200964:	bd89                	j	802007b6 <vprintfmt+0x170>
    80200966:	000ae603          	lwu	a2,0(s5)
    8020096a:	46c1                	li	a3,16
    8020096c:	8aae                	mv	s5,a1
    8020096e:	b5a1                	j	802007b6 <vprintfmt+0x170>
    80200970:	000ae603          	lwu	a2,0(s5)
    80200974:	46a1                	li	a3,8
    80200976:	8aae                	mv	s5,a1
    80200978:	bd3d                	j	802007b6 <vprintfmt+0x170>
                    putch(ch, putdat);
    8020097a:	9902                	jalr	s2
    8020097c:	b559                	j	80200802 <vprintfmt+0x1bc>
                putch('-', putdat);
    8020097e:	85a6                	mv	a1,s1
    80200980:	02d00513          	li	a0,45
    80200984:	e03e                	sd	a5,0(sp)
    80200986:	9902                	jalr	s2
                num = -(long long)num;
    80200988:	8ace                	mv	s5,s3
    8020098a:	40800633          	neg	a2,s0
    8020098e:	46a9                	li	a3,10
    80200990:	6782                	ld	a5,0(sp)
    80200992:	b515                	j	802007b6 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    80200994:	01b05663          	blez	s11,802009a0 <vprintfmt+0x35a>
    80200998:	02d00693          	li	a3,45
    8020099c:	f6d798e3          	bne	a5,a3,8020090c <vprintfmt+0x2c6>
    802009a0:	00001417          	auipc	s0,0x1
    802009a4:	8e940413          	addi	s0,s0,-1815 # 80201289 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009a8:	02800513          	li	a0,40
    802009ac:	02800793          	li	a5,40
    802009b0:	bd1d                	j	802007e6 <vprintfmt+0x1a0>

00000000802009b2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009b2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009b4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009b8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009ba:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009bc:	ec06                	sd	ra,24(sp)
    802009be:	f83a                	sd	a4,48(sp)
    802009c0:	fc3e                	sd	a5,56(sp)
    802009c2:	e0c2                	sd	a6,64(sp)
    802009c4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009c6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009c8:	c7fff0ef          	jal	ra,80200646 <vprintfmt>
}
    802009cc:	60e2                	ld	ra,24(sp)
    802009ce:	6161                	addi	sp,sp,80
    802009d0:	8082                	ret

00000000802009d2 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802009d2:	00003797          	auipc	a5,0x3
    802009d6:	62e78793          	addi	a5,a5,1582 # 80204000 <bootstacktop>
    __asm__ volatile (
    802009da:	6398                	ld	a4,0(a5)
    802009dc:	4781                	li	a5,0
    802009de:	88ba                	mv	a7,a4
    802009e0:	852a                	mv	a0,a0
    802009e2:	85be                	mv	a1,a5
    802009e4:	863e                	mv	a2,a5
    802009e6:	00000073          	ecall
    802009ea:	87aa                	mv	a5,a0
}
    802009ec:	8082                	ret

00000000802009ee <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    802009ee:	00003797          	auipc	a5,0x3
    802009f2:	62a78793          	addi	a5,a5,1578 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    802009f6:	6398                	ld	a4,0(a5)
    802009f8:	4781                	li	a5,0
    802009fa:	88ba                	mv	a7,a4
    802009fc:	852a                	mv	a0,a0
    802009fe:	85be                	mv	a1,a5
    80200a00:	863e                	mv	a2,a5
    80200a02:	00000073          	ecall
    80200a06:	87aa                	mv	a5,a0
}
    80200a08:	8082                	ret

0000000080200a0a <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a0a:	00003797          	auipc	a5,0x3
    80200a0e:	5fe78793          	addi	a5,a5,1534 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a12:	6398                	ld	a4,0(a5)
    80200a14:	4781                	li	a5,0
    80200a16:	88ba                	mv	a7,a4
    80200a18:	853e                	mv	a0,a5
    80200a1a:	85be                	mv	a1,a5
    80200a1c:	863e                	mv	a2,a5
    80200a1e:	00000073          	ecall
    80200a22:	87aa                	mv	a5,a0
    80200a24:	8082                	ret

0000000080200a26 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200a26:	c185                	beqz	a1,80200a46 <strnlen+0x20>
    80200a28:	00054783          	lbu	a5,0(a0)
    80200a2c:	cf89                	beqz	a5,80200a46 <strnlen+0x20>
    size_t cnt = 0;
    80200a2e:	4781                	li	a5,0
    80200a30:	a021                	j	80200a38 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a32:	00074703          	lbu	a4,0(a4)
    80200a36:	c711                	beqz	a4,80200a42 <strnlen+0x1c>
        cnt ++;
    80200a38:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a3a:	00f50733          	add	a4,a0,a5
    80200a3e:	fef59ae3          	bne	a1,a5,80200a32 <strnlen+0xc>
    }
    return cnt;
}
    80200a42:	853e                	mv	a0,a5
    80200a44:	8082                	ret
    size_t cnt = 0;
    80200a46:	4781                	li	a5,0
}
    80200a48:	853e                	mv	a0,a5
    80200a4a:	8082                	ret

0000000080200a4c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a4c:	ca01                	beqz	a2,80200a5c <memset+0x10>
    80200a4e:	962a                	add	a2,a2,a0
    char *p = s;
    80200a50:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a52:	0785                	addi	a5,a5,1
    80200a54:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a58:	fec79de3          	bne	a5,a2,80200a52 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a5c:	8082                	ret
