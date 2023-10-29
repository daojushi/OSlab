
bin/kernel：     文件格式 elf64-littleriscv


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
ffffffffc0200042:	56260613          	addi	a2,a2,1378 # ffffffffc02115a0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	597030ef          	jal	ra,ffffffffc0203de4 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	27658593          	addi	a1,a1,630 # ffffffffc02042c8 <etext+0x4>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	28e50513          	addi	a0,a0,654 # ffffffffc02042e8 <etext+0x24>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	100000ef          	jal	ra,ffffffffc0200166 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	663020ef          	jal	ra,ffffffffc0202ecc <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	43f000ef          	jal	ra,ffffffffc0200cb0 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	35e000ef          	jal	ra,ffffffffc02003d4 <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	248010ef          	jal	ra,ffffffffc02012c2 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	3ae000ef          	jal	ra,ffffffffc020042c <clock_init>
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
ffffffffc020008c:	3f6000ef          	jal	ra,ffffffffc0200482 <cons_putc>
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
ffffffffc02000b2:	5c9030ef          	jal	ra,ffffffffc0203e7a <vprintfmt>
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
ffffffffc02000e6:	595030ef          	jal	ra,ffffffffc0203e7a <vprintfmt>
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
ffffffffc02000f2:	3900006f          	j	ffffffffc0200482 <cons_putc>

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
ffffffffc02000fa:	3be000ef          	jal	ra,ffffffffc02004b8 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200106:	00011317          	auipc	t1,0x11
ffffffffc020010a:	33a30313          	addi	t1,t1,826 # ffffffffc0211440 <is_panic>
ffffffffc020010e:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200112:	715d                	addi	sp,sp,-80
ffffffffc0200114:	ec06                	sd	ra,24(sp)
ffffffffc0200116:	e822                	sd	s0,16(sp)
ffffffffc0200118:	f436                	sd	a3,40(sp)
ffffffffc020011a:	f83a                	sd	a4,48(sp)
ffffffffc020011c:	fc3e                	sd	a5,56(sp)
ffffffffc020011e:	e0c2                	sd	a6,64(sp)
ffffffffc0200120:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200122:	02031c63          	bnez	t1,ffffffffc020015a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200126:	4785                	li	a5,1
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	00011717          	auipc	a4,0x11
ffffffffc020012e:	30f72b23          	sw	a5,790(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200132:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200134:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200136:	85aa                	mv	a1,a0
ffffffffc0200138:	00004517          	auipc	a0,0x4
ffffffffc020013c:	1b850513          	addi	a0,a0,440 # ffffffffc02042f0 <etext+0x2c>
    va_start(ap, fmt);
ffffffffc0200140:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200142:	f7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200146:	65a2                	ld	a1,8(sp)
ffffffffc0200148:	8522                	mv	a0,s0
ffffffffc020014a:	f55ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc020014e:	00006517          	auipc	a0,0x6
ffffffffc0200152:	b1250513          	addi	a0,a0,-1262 # ffffffffc0205c60 <default_pmm_manager+0x560>
ffffffffc0200156:	f69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020015a:	3a0000ef          	jal	ra,ffffffffc02004fa <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020015e:	4501                	li	a0,0
ffffffffc0200160:	132000ef          	jal	ra,ffffffffc0200292 <kmonitor>
ffffffffc0200164:	bfed                	j	ffffffffc020015e <__panic+0x58>

ffffffffc0200166 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200166:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200168:	00004517          	auipc	a0,0x4
ffffffffc020016c:	1d850513          	addi	a0,a0,472 # ffffffffc0204340 <etext+0x7c>
void print_kerninfo(void) {
ffffffffc0200170:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200172:	f4dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200176:	00000597          	auipc	a1,0x0
ffffffffc020017a:	ec058593          	addi	a1,a1,-320 # ffffffffc0200036 <kern_init>
ffffffffc020017e:	00004517          	auipc	a0,0x4
ffffffffc0200182:	1e250513          	addi	a0,a0,482 # ffffffffc0204360 <etext+0x9c>
ffffffffc0200186:	f39ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020018a:	00004597          	auipc	a1,0x4
ffffffffc020018e:	13a58593          	addi	a1,a1,314 # ffffffffc02042c4 <etext>
ffffffffc0200192:	00004517          	auipc	a0,0x4
ffffffffc0200196:	1ee50513          	addi	a0,a0,494 # ffffffffc0204380 <etext+0xbc>
ffffffffc020019a:	f25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020019e:	0000a597          	auipc	a1,0xa
ffffffffc02001a2:	ea258593          	addi	a1,a1,-350 # ffffffffc020a040 <edata>
ffffffffc02001a6:	00004517          	auipc	a0,0x4
ffffffffc02001aa:	1fa50513          	addi	a0,a0,506 # ffffffffc02043a0 <etext+0xdc>
ffffffffc02001ae:	f11ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001b2:	00011597          	auipc	a1,0x11
ffffffffc02001b6:	3ee58593          	addi	a1,a1,1006 # ffffffffc02115a0 <end>
ffffffffc02001ba:	00004517          	auipc	a0,0x4
ffffffffc02001be:	20650513          	addi	a0,a0,518 # ffffffffc02043c0 <etext+0xfc>
ffffffffc02001c2:	efdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001c6:	00011597          	auipc	a1,0x11
ffffffffc02001ca:	7d958593          	addi	a1,a1,2009 # ffffffffc021199f <end+0x3ff>
ffffffffc02001ce:	00000797          	auipc	a5,0x0
ffffffffc02001d2:	e6878793          	addi	a5,a5,-408 # ffffffffc0200036 <kern_init>
ffffffffc02001d6:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001da:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001de:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001e0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001e4:	95be                	add	a1,a1,a5
ffffffffc02001e6:	85a9                	srai	a1,a1,0xa
ffffffffc02001e8:	00004517          	auipc	a0,0x4
ffffffffc02001ec:	1f850513          	addi	a0,a0,504 # ffffffffc02043e0 <etext+0x11c>
}
ffffffffc02001f0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001f2:	ecdff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02001f6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001f6:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001f8:	00004617          	auipc	a2,0x4
ffffffffc02001fc:	11860613          	addi	a2,a2,280 # ffffffffc0204310 <etext+0x4c>
ffffffffc0200200:	04e00593          	li	a1,78
ffffffffc0200204:	00004517          	auipc	a0,0x4
ffffffffc0200208:	12450513          	addi	a0,a0,292 # ffffffffc0204328 <etext+0x64>
void print_stackframe(void) {
ffffffffc020020c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020020e:	ef9ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200212 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200214:	00004617          	auipc	a2,0x4
ffffffffc0200218:	2d460613          	addi	a2,a2,724 # ffffffffc02044e8 <commands+0xd8>
ffffffffc020021c:	00004597          	auipc	a1,0x4
ffffffffc0200220:	2ec58593          	addi	a1,a1,748 # ffffffffc0204508 <commands+0xf8>
ffffffffc0200224:	00004517          	auipc	a0,0x4
ffffffffc0200228:	2ec50513          	addi	a0,a0,748 # ffffffffc0204510 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020022c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020022e:	e91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200232:	00004617          	auipc	a2,0x4
ffffffffc0200236:	2ee60613          	addi	a2,a2,750 # ffffffffc0204520 <commands+0x110>
ffffffffc020023a:	00004597          	auipc	a1,0x4
ffffffffc020023e:	30e58593          	addi	a1,a1,782 # ffffffffc0204548 <commands+0x138>
ffffffffc0200242:	00004517          	auipc	a0,0x4
ffffffffc0200246:	2ce50513          	addi	a0,a0,718 # ffffffffc0204510 <commands+0x100>
ffffffffc020024a:	e75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020024e:	00004617          	auipc	a2,0x4
ffffffffc0200252:	30a60613          	addi	a2,a2,778 # ffffffffc0204558 <commands+0x148>
ffffffffc0200256:	00004597          	auipc	a1,0x4
ffffffffc020025a:	32258593          	addi	a1,a1,802 # ffffffffc0204578 <commands+0x168>
ffffffffc020025e:	00004517          	auipc	a0,0x4
ffffffffc0200262:	2b250513          	addi	a0,a0,690 # ffffffffc0204510 <commands+0x100>
ffffffffc0200266:	e59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020026a:	60a2                	ld	ra,8(sp)
ffffffffc020026c:	4501                	li	a0,0
ffffffffc020026e:	0141                	addi	sp,sp,16
ffffffffc0200270:	8082                	ret

ffffffffc0200272 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
ffffffffc0200274:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200276:	ef1ff0ef          	jal	ra,ffffffffc0200166 <print_kerninfo>
    return 0;
}
ffffffffc020027a:	60a2                	ld	ra,8(sp)
ffffffffc020027c:	4501                	li	a0,0
ffffffffc020027e:	0141                	addi	sp,sp,16
ffffffffc0200280:	8082                	ret

ffffffffc0200282 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
ffffffffc0200284:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200286:	f71ff0ef          	jal	ra,ffffffffc02001f6 <print_stackframe>
    return 0;
}
ffffffffc020028a:	60a2                	ld	ra,8(sp)
ffffffffc020028c:	4501                	li	a0,0
ffffffffc020028e:	0141                	addi	sp,sp,16
ffffffffc0200290:	8082                	ret

ffffffffc0200292 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200292:	7115                	addi	sp,sp,-224
ffffffffc0200294:	e962                	sd	s8,144(sp)
ffffffffc0200296:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200298:	00004517          	auipc	a0,0x4
ffffffffc020029c:	1c050513          	addi	a0,a0,448 # ffffffffc0204458 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002a0:	ed86                	sd	ra,216(sp)
ffffffffc02002a2:	e9a2                	sd	s0,208(sp)
ffffffffc02002a4:	e5a6                	sd	s1,200(sp)
ffffffffc02002a6:	e1ca                	sd	s2,192(sp)
ffffffffc02002a8:	fd4e                	sd	s3,184(sp)
ffffffffc02002aa:	f952                	sd	s4,176(sp)
ffffffffc02002ac:	f556                	sd	s5,168(sp)
ffffffffc02002ae:	f15a                	sd	s6,160(sp)
ffffffffc02002b0:	ed5e                	sd	s7,152(sp)
ffffffffc02002b2:	e566                	sd	s9,136(sp)
ffffffffc02002b4:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002b6:	e09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002ba:	00004517          	auipc	a0,0x4
ffffffffc02002be:	1c650513          	addi	a0,a0,454 # ffffffffc0204480 <commands+0x70>
ffffffffc02002c2:	dfdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc02002c6:	000c0563          	beqz	s8,ffffffffc02002d0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002ca:	8562                	mv	a0,s8
ffffffffc02002cc:	492000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc02002d0:	00004c97          	auipc	s9,0x4
ffffffffc02002d4:	140c8c93          	addi	s9,s9,320 # ffffffffc0204410 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002d8:	00005997          	auipc	s3,0x5
ffffffffc02002dc:	02898993          	addi	s3,s3,40 # ffffffffc0205300 <commands+0xef0>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	00004917          	auipc	s2,0x4
ffffffffc02002e4:	1c890913          	addi	s2,s2,456 # ffffffffc02044a8 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc02002e8:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002ea:	00004b17          	auipc	s6,0x4
ffffffffc02002ee:	1c6b0b13          	addi	s6,s6,454 # ffffffffc02044b0 <commands+0xa0>
    if (argc == 0) {
ffffffffc02002f2:	00004a97          	auipc	s5,0x4
ffffffffc02002f6:	216a8a93          	addi	s5,s5,534 # ffffffffc0204508 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002fc:	854e                	mv	a0,s3
ffffffffc02002fe:	709030ef          	jal	ra,ffffffffc0204206 <readline>
ffffffffc0200302:	842a                	mv	s0,a0
ffffffffc0200304:	dd65                	beqz	a0,ffffffffc02002fc <kmonitor+0x6a>
ffffffffc0200306:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020030a:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	c999                	beqz	a1,ffffffffc0200322 <kmonitor+0x90>
ffffffffc020030e:	854a                	mv	a0,s2
ffffffffc0200310:	2b7030ef          	jal	ra,ffffffffc0203dc6 <strchr>
ffffffffc0200314:	c925                	beqz	a0,ffffffffc0200384 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200316:	00144583          	lbu	a1,1(s0)
ffffffffc020031a:	00040023          	sb	zero,0(s0)
ffffffffc020031e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200320:	f5fd                	bnez	a1,ffffffffc020030e <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200322:	dce9                	beqz	s1,ffffffffc02002fc <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	6582                	ld	a1,0(sp)
ffffffffc0200326:	00004d17          	auipc	s10,0x4
ffffffffc020032a:	0ead0d13          	addi	s10,s10,234 # ffffffffc0204410 <commands>
    if (argc == 0) {
ffffffffc020032e:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200330:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200332:	0d61                	addi	s10,s10,24
ffffffffc0200334:	269030ef          	jal	ra,ffffffffc0203d9c <strcmp>
ffffffffc0200338:	c919                	beqz	a0,ffffffffc020034e <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020033a:	2405                	addiw	s0,s0,1
ffffffffc020033c:	09740463          	beq	s0,s7,ffffffffc02003c4 <kmonitor+0x132>
ffffffffc0200340:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200344:	6582                	ld	a1,0(sp)
ffffffffc0200346:	0d61                	addi	s10,s10,24
ffffffffc0200348:	255030ef          	jal	ra,ffffffffc0203d9c <strcmp>
ffffffffc020034c:	f57d                	bnez	a0,ffffffffc020033a <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020034e:	00141793          	slli	a5,s0,0x1
ffffffffc0200352:	97a2                	add	a5,a5,s0
ffffffffc0200354:	078e                	slli	a5,a5,0x3
ffffffffc0200356:	97e6                	add	a5,a5,s9
ffffffffc0200358:	6b9c                	ld	a5,16(a5)
ffffffffc020035a:	8662                	mv	a2,s8
ffffffffc020035c:	002c                	addi	a1,sp,8
ffffffffc020035e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200362:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200364:	f8055ce3          	bgez	a0,ffffffffc02002fc <kmonitor+0x6a>
}
ffffffffc0200368:	60ee                	ld	ra,216(sp)
ffffffffc020036a:	644e                	ld	s0,208(sp)
ffffffffc020036c:	64ae                	ld	s1,200(sp)
ffffffffc020036e:	690e                	ld	s2,192(sp)
ffffffffc0200370:	79ea                	ld	s3,184(sp)
ffffffffc0200372:	7a4a                	ld	s4,176(sp)
ffffffffc0200374:	7aaa                	ld	s5,168(sp)
ffffffffc0200376:	7b0a                	ld	s6,160(sp)
ffffffffc0200378:	6bea                	ld	s7,152(sp)
ffffffffc020037a:	6c4a                	ld	s8,144(sp)
ffffffffc020037c:	6caa                	ld	s9,136(sp)
ffffffffc020037e:	6d0a                	ld	s10,128(sp)
ffffffffc0200380:	612d                	addi	sp,sp,224
ffffffffc0200382:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200384:	00044783          	lbu	a5,0(s0)
ffffffffc0200388:	dfc9                	beqz	a5,ffffffffc0200322 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020038a:	03448863          	beq	s1,s4,ffffffffc02003ba <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020038e:	00349793          	slli	a5,s1,0x3
ffffffffc0200392:	0118                	addi	a4,sp,128
ffffffffc0200394:	97ba                	add	a5,a5,a4
ffffffffc0200396:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020039e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a0:	e591                	bnez	a1,ffffffffc02003ac <kmonitor+0x11a>
ffffffffc02003a2:	b749                	j	ffffffffc0200324 <kmonitor+0x92>
            buf ++;
ffffffffc02003a4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a6:	00044583          	lbu	a1,0(s0)
ffffffffc02003aa:	ddad                	beqz	a1,ffffffffc0200324 <kmonitor+0x92>
ffffffffc02003ac:	854a                	mv	a0,s2
ffffffffc02003ae:	219030ef          	jal	ra,ffffffffc0203dc6 <strchr>
ffffffffc02003b2:	d96d                	beqz	a0,ffffffffc02003a4 <kmonitor+0x112>
ffffffffc02003b4:	00044583          	lbu	a1,0(s0)
ffffffffc02003b8:	bf91                	j	ffffffffc020030c <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ba:	45c1                	li	a1,16
ffffffffc02003bc:	855a                	mv	a0,s6
ffffffffc02003be:	d01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02003c2:	b7f1                	j	ffffffffc020038e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c4:	6582                	ld	a1,0(sp)
ffffffffc02003c6:	00004517          	auipc	a0,0x4
ffffffffc02003ca:	10a50513          	addi	a0,a0,266 # ffffffffc02044d0 <commands+0xc0>
ffffffffc02003ce:	cf1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc02003d2:	b72d                	j	ffffffffc02002fc <kmonitor+0x6a>

ffffffffc02003d4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02003d4:	8082                	ret

ffffffffc02003d6 <ide_device_valid>:

#define MAX_IDE 2 
#define MAX_DISK_NSECS 56 
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }//ideno是ide设备的编号，最多有两个ide设备
ffffffffc02003d6:	00253513          	sltiu	a0,a0,2
ffffffffc02003da:	8082                	ret

ffffffffc02003dc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003dc:	03800513          	li	a0,56
ffffffffc02003e0:	8082                	ret

ffffffffc02003e2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {//从ide设备中读取数据到dst指向的内存区域
    int iobase = secno * SECTSIZE;//secno是从哪个扇区开始读取数据
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003e2:	0000a797          	auipc	a5,0xa
ffffffffc02003e6:	c5e78793          	addi	a5,a5,-930 # ffffffffc020a040 <edata>
ffffffffc02003ea:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {//从ide设备中读取数据到dst指向的内存区域
ffffffffc02003ee:	1141                	addi	sp,sp,-16
ffffffffc02003f0:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f2:	95be                	add	a1,a1,a5
ffffffffc02003f4:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {//从ide设备中读取数据到dst指向的内存区域
ffffffffc02003f8:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003fa:	1fd030ef          	jal	ra,ffffffffc0203df6 <memcpy>
    return 0;
}
ffffffffc02003fe:	60a2                	ld	ra,8(sp)
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	0141                	addi	sp,sp,16
ffffffffc0200404:	8082                	ret

ffffffffc0200406 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200406:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200408:	0095979b          	slliw	a5,a1,0x9
ffffffffc020040c:	0000a517          	auipc	a0,0xa
ffffffffc0200410:	c3450513          	addi	a0,a0,-972 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc0200414:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200416:	00969613          	slli	a2,a3,0x9
ffffffffc020041a:	85ba                	mv	a1,a4
ffffffffc020041c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020041e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200420:	1d7030ef          	jal	ra,ffffffffc0203df6 <memcpy>
    return 0;
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	4501                	li	a0,0
ffffffffc0200428:	0141                	addi	sp,sp,16
ffffffffc020042a:	8082                	ret

ffffffffc020042c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020042c:	67e1                	lui	a5,0x18
ffffffffc020042e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200432:	00011717          	auipc	a4,0x11
ffffffffc0200436:	00f73b23          	sd	a5,22(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020043e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200440:	953e                	add	a0,a0,a5
ffffffffc0200442:	4601                	li	a2,0
ffffffffc0200444:	4881                	li	a7,0
ffffffffc0200446:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020044a:	02000793          	li	a5,32
ffffffffc020044e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200452:	00004517          	auipc	a0,0x4
ffffffffc0200456:	13650513          	addi	a0,a0,310 # ffffffffc0204588 <commands+0x178>
    ticks = 0;
ffffffffc020045a:	00011797          	auipc	a5,0x11
ffffffffc020045e:	0007bf23          	sd	zero,30(a5) # ffffffffc0211478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200462:	c5dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200466 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200466:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020046a:	00011797          	auipc	a5,0x11
ffffffffc020046e:	fde78793          	addi	a5,a5,-34 # ffffffffc0211448 <timebase>
ffffffffc0200472:	639c                	ld	a5,0(a5)
ffffffffc0200474:	4581                	li	a1,0
ffffffffc0200476:	4601                	li	a2,0
ffffffffc0200478:	953e                	add	a0,a0,a5
ffffffffc020047a:	4881                	li	a7,0
ffffffffc020047c:	00000073          	ecall
ffffffffc0200480:	8082                	ret

ffffffffc0200482 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200482:	100027f3          	csrr	a5,sstatus
ffffffffc0200486:	8b89                	andi	a5,a5,2
ffffffffc0200488:	0ff57513          	andi	a0,a0,255
ffffffffc020048c:	e799                	bnez	a5,ffffffffc020049a <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020048e:	4581                	li	a1,0
ffffffffc0200490:	4601                	li	a2,0
ffffffffc0200492:	4885                	li	a7,1
ffffffffc0200494:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200498:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020049a:	1101                	addi	sp,sp,-32
ffffffffc020049c:	ec06                	sd	ra,24(sp)
ffffffffc020049e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02004a0:	05a000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004a4:	6522                	ld	a0,8(sp)
ffffffffc02004a6:	4581                	li	a1,0
ffffffffc02004a8:	4601                	li	a2,0
ffffffffc02004aa:	4885                	li	a7,1
ffffffffc02004ac:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004b0:	60e2                	ld	ra,24(sp)
ffffffffc02004b2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004b4:	0400006f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc02004b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004b8:	100027f3          	csrr	a5,sstatus
ffffffffc02004bc:	8b89                	andi	a5,a5,2
ffffffffc02004be:	eb89                	bnez	a5,ffffffffc02004d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004c0:	4501                	li	a0,0
ffffffffc02004c2:	4581                	li	a1,0
ffffffffc02004c4:	4601                	li	a2,0
ffffffffc02004c6:	4889                	li	a7,2
ffffffffc02004c8:	00000073          	ecall
ffffffffc02004cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004ce:	8082                	ret
int cons_getc(void) {
ffffffffc02004d0:	1101                	addi	sp,sp,-32
ffffffffc02004d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004d4:	026000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	4889                	li	a7,2
ffffffffc02004e0:	00000073          	ecall
ffffffffc02004e4:	2501                	sext.w	a0,a0
ffffffffc02004e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004e8:	00c000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
}
ffffffffc02004ec:	60e2                	ld	ra,24(sp)
ffffffffc02004ee:	6522                	ld	a0,8(sp)
ffffffffc02004f0:	6105                	addi	sp,sp,32
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
ffffffffc0200534:	35050513          	addi	a0,a0,848 # ffffffffc0204880 <commands+0x470>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	f4478793          	addi	a5,a5,-188 # ffffffffc0211480 <check_mm_struct>
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
ffffffffc0200556:	4990006f          	j	ffffffffc02011ee <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	34660613          	addi	a2,a2,838 # ffffffffc02048a0 <commands+0x490>
ffffffffc0200562:	07800593          	li	a1,120
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	35250513          	addi	a0,a0,850 # ffffffffc02048b8 <commands+0x4a8>
ffffffffc020056e:	b99ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	49a78793          	addi	a5,a5,1178 # ffffffffc0200a10 <__alltraps>
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
ffffffffc020059c:	33850513          	addi	a0,a0,824 # ffffffffc02048d0 <commands+0x4c0>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	34050513          	addi	a0,a0,832 # ffffffffc02048e8 <commands+0x4d8>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	34a50513          	addi	a0,a0,842 # ffffffffc0204900 <commands+0x4f0>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	35450513          	addi	a0,a0,852 # ffffffffc0204918 <commands+0x508>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	35e50513          	addi	a0,a0,862 # ffffffffc0204930 <commands+0x520>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	36850513          	addi	a0,a0,872 # ffffffffc0204948 <commands+0x538>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	37250513          	addi	a0,a0,882 # ffffffffc0204960 <commands+0x550>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	37c50513          	addi	a0,a0,892 # ffffffffc0204978 <commands+0x568>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	38650513          	addi	a0,a0,902 # ffffffffc0204990 <commands+0x580>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	39050513          	addi	a0,a0,912 # ffffffffc02049a8 <commands+0x598>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	39a50513          	addi	a0,a0,922 # ffffffffc02049c0 <commands+0x5b0>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	3a450513          	addi	a0,a0,932 # ffffffffc02049d8 <commands+0x5c8>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	3ae50513          	addi	a0,a0,942 # ffffffffc02049f0 <commands+0x5e0>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	3b850513          	addi	a0,a0,952 # ffffffffc0204a08 <commands+0x5f8>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	3c250513          	addi	a0,a0,962 # ffffffffc0204a20 <commands+0x610>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	3cc50513          	addi	a0,a0,972 # ffffffffc0204a38 <commands+0x628>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	3d650513          	addi	a0,a0,982 # ffffffffc0204a50 <commands+0x640>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	3e050513          	addi	a0,a0,992 # ffffffffc0204a68 <commands+0x658>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204a80 <commands+0x670>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	3f450513          	addi	a0,a0,1012 # ffffffffc0204a98 <commands+0x688>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	3fe50513          	addi	a0,a0,1022 # ffffffffc0204ab0 <commands+0x6a0>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	40850513          	addi	a0,a0,1032 # ffffffffc0204ac8 <commands+0x6b8>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	41250513          	addi	a0,a0,1042 # ffffffffc0204ae0 <commands+0x6d0>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	41c50513          	addi	a0,a0,1052 # ffffffffc0204af8 <commands+0x6e8>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	42650513          	addi	a0,a0,1062 # ffffffffc0204b10 <commands+0x700>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	43050513          	addi	a0,a0,1072 # ffffffffc0204b28 <commands+0x718>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	43a50513          	addi	a0,a0,1082 # ffffffffc0204b40 <commands+0x730>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	44450513          	addi	a0,a0,1092 # ffffffffc0204b58 <commands+0x748>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	44e50513          	addi	a0,a0,1102 # ffffffffc0204b70 <commands+0x760>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	45850513          	addi	a0,a0,1112 # ffffffffc0204b88 <commands+0x778>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	46250513          	addi	a0,a0,1122 # ffffffffc0204ba0 <commands+0x790>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	46850513          	addi	a0,a0,1128 # ffffffffc0204bb8 <commands+0x7a8>
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
ffffffffc020076a:	46a50513          	addi	a0,a0,1130 # ffffffffc0204bd0 <commands+0x7c0>
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
ffffffffc0200782:	46a50513          	addi	a0,a0,1130 # ffffffffc0204be8 <commands+0x7d8>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	47250513          	addi	a0,a0,1138 # ffffffffc0204c00 <commands+0x7f0>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00004517          	auipc	a0,0x4
ffffffffc02007a2:	47a50513          	addi	a0,a0,1146 # ffffffffc0204c18 <commands+0x808>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	47e50513          	addi	a0,a0,1150 # ffffffffc0204c30 <commands+0x820>
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
ffffffffc02007cc:	06f76f63          	bltu	a4,a5,ffffffffc020084a <interrupt_handler+0x8a>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	dd470713          	addi	a4,a4,-556 # ffffffffc02045a4 <commands+0x194>
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
ffffffffc02007e6:	04e50513          	addi	a0,a0,78 # ffffffffc0204830 <commands+0x420>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	02250513          	addi	a0,a0,34 # ffffffffc0204810 <commands+0x400>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	fd650513          	addi	a0,a0,-42 # ffffffffc02047d0 <commands+0x3c0>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	fea50513          	addi	a0,a0,-22 # ffffffffc02047f0 <commands+0x3e0>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	04e50513          	addi	a0,a0,78 # ffffffffc0204860 <commands+0x450>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200822:	c45ff0ef          	jal	ra,ffffffffc0200466 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200826:	00011797          	auipc	a5,0x11
ffffffffc020082a:	c5278793          	addi	a5,a5,-942 # ffffffffc0211478 <ticks>
ffffffffc020082e:	639c                	ld	a5,0(a5)
ffffffffc0200830:	06400713          	li	a4,100
ffffffffc0200834:	0785                	addi	a5,a5,1
ffffffffc0200836:	02e7f733          	remu	a4,a5,a4
ffffffffc020083a:	00011697          	auipc	a3,0x11
ffffffffc020083e:	c2f6bf23          	sd	a5,-962(a3) # ffffffffc0211478 <ticks>
ffffffffc0200842:	c711                	beqz	a4,ffffffffc020084e <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200844:	60a2                	ld	ra,8(sp)
ffffffffc0200846:	0141                	addi	sp,sp,16
ffffffffc0200848:	8082                	ret
            print_trapframe(tf);
ffffffffc020084a:	f15ff06f          	j	ffffffffc020075e <print_trapframe>
}
ffffffffc020084e:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200850:	06400593          	li	a1,100
ffffffffc0200854:	00004517          	auipc	a0,0x4
ffffffffc0200858:	ffc50513          	addi	a0,a0,-4 # ffffffffc0204850 <commands+0x440>
}
ffffffffc020085c:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020085e:	861ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200862 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200862:	11853783          	ld	a5,280(a0)
ffffffffc0200866:	473d                	li	a4,15
ffffffffc0200868:	16f76563          	bltu	a4,a5,ffffffffc02009d2 <exception_handler+0x170>
ffffffffc020086c:	00004717          	auipc	a4,0x4
ffffffffc0200870:	d6870713          	addi	a4,a4,-664 # ffffffffc02045d4 <commands+0x1c4>
ffffffffc0200874:	078a                	slli	a5,a5,0x2
ffffffffc0200876:	97ba                	add	a5,a5,a4
ffffffffc0200878:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020087a:	1101                	addi	sp,sp,-32
ffffffffc020087c:	e822                	sd	s0,16(sp)
ffffffffc020087e:	ec06                	sd	ra,24(sp)
ffffffffc0200880:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200882:	97ba                	add	a5,a5,a4
ffffffffc0200884:	842a                	mv	s0,a0
ffffffffc0200886:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200888:	00004517          	auipc	a0,0x4
ffffffffc020088c:	f3050513          	addi	a0,a0,-208 # ffffffffc02047b8 <commands+0x3a8>
ffffffffc0200890:	82fff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200894:	8522                	mv	a0,s0
ffffffffc0200896:	c6bff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc020089a:	84aa                	mv	s1,a0
ffffffffc020089c:	12051d63          	bnez	a0,ffffffffc02009d6 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008a0:	60e2                	ld	ra,24(sp)
ffffffffc02008a2:	6442                	ld	s0,16(sp)
ffffffffc02008a4:	64a2                	ld	s1,8(sp)
ffffffffc02008a6:	6105                	addi	sp,sp,32
ffffffffc02008a8:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008aa:	00004517          	auipc	a0,0x4
ffffffffc02008ae:	d6e50513          	addi	a0,a0,-658 # ffffffffc0204618 <commands+0x208>
}
ffffffffc02008b2:	6442                	ld	s0,16(sp)
ffffffffc02008b4:	60e2                	ld	ra,24(sp)
ffffffffc02008b6:	64a2                	ld	s1,8(sp)
ffffffffc02008b8:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008ba:	805ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008be:	00004517          	auipc	a0,0x4
ffffffffc02008c2:	d7a50513          	addi	a0,a0,-646 # ffffffffc0204638 <commands+0x228>
ffffffffc02008c6:	b7f5                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008c8:	00004517          	auipc	a0,0x4
ffffffffc02008cc:	d9050513          	addi	a0,a0,-624 # ffffffffc0204658 <commands+0x248>
ffffffffc02008d0:	b7cd                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008d2:	00004517          	auipc	a0,0x4
ffffffffc02008d6:	d9e50513          	addi	a0,a0,-610 # ffffffffc0204670 <commands+0x260>
ffffffffc02008da:	bfe1                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008dc:	00004517          	auipc	a0,0x4
ffffffffc02008e0:	da450513          	addi	a0,a0,-604 # ffffffffc0204680 <commands+0x270>
ffffffffc02008e4:	b7f9                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008e6:	00004517          	auipc	a0,0x4
ffffffffc02008ea:	dba50513          	addi	a0,a0,-582 # ffffffffc02046a0 <commands+0x290>
ffffffffc02008ee:	fd0ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008f2:	8522                	mv	a0,s0
ffffffffc02008f4:	c0dff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02008f8:	84aa                	mv	s1,a0
ffffffffc02008fa:	d15d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008fc:	8522                	mv	a0,s0
ffffffffc02008fe:	e61ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200902:	86a6                	mv	a3,s1
ffffffffc0200904:	00004617          	auipc	a2,0x4
ffffffffc0200908:	db460613          	addi	a2,a2,-588 # ffffffffc02046b8 <commands+0x2a8>
ffffffffc020090c:	0ca00593          	li	a1,202
ffffffffc0200910:	00004517          	auipc	a0,0x4
ffffffffc0200914:	fa850513          	addi	a0,a0,-88 # ffffffffc02048b8 <commands+0x4a8>
ffffffffc0200918:	feeff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020091c:	00004517          	auipc	a0,0x4
ffffffffc0200920:	dbc50513          	addi	a0,a0,-580 # ffffffffc02046d8 <commands+0x2c8>
ffffffffc0200924:	b779                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200926:	00004517          	auipc	a0,0x4
ffffffffc020092a:	dca50513          	addi	a0,a0,-566 # ffffffffc02046f0 <commands+0x2e0>
ffffffffc020092e:	f90ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200932:	8522                	mv	a0,s0
ffffffffc0200934:	bcdff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200938:	84aa                	mv	s1,a0
ffffffffc020093a:	d13d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020093c:	8522                	mv	a0,s0
ffffffffc020093e:	e21ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200942:	86a6                	mv	a3,s1
ffffffffc0200944:	00004617          	auipc	a2,0x4
ffffffffc0200948:	d7460613          	addi	a2,a2,-652 # ffffffffc02046b8 <commands+0x2a8>
ffffffffc020094c:	0d400593          	li	a1,212
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	f6850513          	addi	a0,a0,-152 # ffffffffc02048b8 <commands+0x4a8>
ffffffffc0200958:	faeff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020095c:	00004517          	auipc	a0,0x4
ffffffffc0200960:	dac50513          	addi	a0,a0,-596 # ffffffffc0204708 <commands+0x2f8>
ffffffffc0200964:	b7b9                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200966:	00004517          	auipc	a0,0x4
ffffffffc020096a:	dc250513          	addi	a0,a0,-574 # ffffffffc0204728 <commands+0x318>
ffffffffc020096e:	b791                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200970:	00004517          	auipc	a0,0x4
ffffffffc0200974:	dd850513          	addi	a0,a0,-552 # ffffffffc0204748 <commands+0x338>
ffffffffc0200978:	bf2d                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc020097a:	00004517          	auipc	a0,0x4
ffffffffc020097e:	dee50513          	addi	a0,a0,-530 # ffffffffc0204768 <commands+0x358>
ffffffffc0200982:	bf05                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200984:	00004517          	auipc	a0,0x4
ffffffffc0200988:	e0450513          	addi	a0,a0,-508 # ffffffffc0204788 <commands+0x378>
ffffffffc020098c:	b71d                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	e1250513          	addi	a0,a0,-494 # ffffffffc02047a0 <commands+0x390>
ffffffffc0200996:	f28ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020099a:	8522                	mv	a0,s0
ffffffffc020099c:	b65ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02009a0:	84aa                	mv	s1,a0
ffffffffc02009a2:	ee050fe3          	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009a6:	8522                	mv	a0,s0
ffffffffc02009a8:	db7ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ac:	86a6                	mv	a3,s1
ffffffffc02009ae:	00004617          	auipc	a2,0x4
ffffffffc02009b2:	d0a60613          	addi	a2,a2,-758 # ffffffffc02046b8 <commands+0x2a8>
ffffffffc02009b6:	0ea00593          	li	a1,234
ffffffffc02009ba:	00004517          	auipc	a0,0x4
ffffffffc02009be:	efe50513          	addi	a0,a0,-258 # ffffffffc02048b8 <commands+0x4a8>
ffffffffc02009c2:	f44ff0ef          	jal	ra,ffffffffc0200106 <__panic>
}
ffffffffc02009c6:	6442                	ld	s0,16(sp)
ffffffffc02009c8:	60e2                	ld	ra,24(sp)
ffffffffc02009ca:	64a2                	ld	s1,8(sp)
ffffffffc02009cc:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009ce:	d91ff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc02009d2:	d8dff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009d6:	8522                	mv	a0,s0
ffffffffc02009d8:	d87ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009dc:	86a6                	mv	a3,s1
ffffffffc02009de:	00004617          	auipc	a2,0x4
ffffffffc02009e2:	cda60613          	addi	a2,a2,-806 # ffffffffc02046b8 <commands+0x2a8>
ffffffffc02009e6:	0f100593          	li	a1,241
ffffffffc02009ea:	00004517          	auipc	a0,0x4
ffffffffc02009ee:	ece50513          	addi	a0,a0,-306 # ffffffffc02048b8 <commands+0x4a8>
ffffffffc02009f2:	f14ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02009f6 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009f6:	11853783          	ld	a5,280(a0)
ffffffffc02009fa:	0007c463          	bltz	a5,ffffffffc0200a02 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009fe:	e65ff06f          	j	ffffffffc0200862 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a02:	dbfff06f          	j	ffffffffc02007c0 <interrupt_handler>
	...

ffffffffc0200a10 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a10:	14011073          	csrw	sscratch,sp
ffffffffc0200a14:	712d                	addi	sp,sp,-288
ffffffffc0200a16:	e406                	sd	ra,8(sp)
ffffffffc0200a18:	ec0e                	sd	gp,24(sp)
ffffffffc0200a1a:	f012                	sd	tp,32(sp)
ffffffffc0200a1c:	f416                	sd	t0,40(sp)
ffffffffc0200a1e:	f81a                	sd	t1,48(sp)
ffffffffc0200a20:	fc1e                	sd	t2,56(sp)
ffffffffc0200a22:	e0a2                	sd	s0,64(sp)
ffffffffc0200a24:	e4a6                	sd	s1,72(sp)
ffffffffc0200a26:	e8aa                	sd	a0,80(sp)
ffffffffc0200a28:	ecae                	sd	a1,88(sp)
ffffffffc0200a2a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a2c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a2e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a30:	fcbe                	sd	a5,120(sp)
ffffffffc0200a32:	e142                	sd	a6,128(sp)
ffffffffc0200a34:	e546                	sd	a7,136(sp)
ffffffffc0200a36:	e94a                	sd	s2,144(sp)
ffffffffc0200a38:	ed4e                	sd	s3,152(sp)
ffffffffc0200a3a:	f152                	sd	s4,160(sp)
ffffffffc0200a3c:	f556                	sd	s5,168(sp)
ffffffffc0200a3e:	f95a                	sd	s6,176(sp)
ffffffffc0200a40:	fd5e                	sd	s7,184(sp)
ffffffffc0200a42:	e1e2                	sd	s8,192(sp)
ffffffffc0200a44:	e5e6                	sd	s9,200(sp)
ffffffffc0200a46:	e9ea                	sd	s10,208(sp)
ffffffffc0200a48:	edee                	sd	s11,216(sp)
ffffffffc0200a4a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a4c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a4e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a50:	fdfe                	sd	t6,248(sp)
ffffffffc0200a52:	14002473          	csrr	s0,sscratch
ffffffffc0200a56:	100024f3          	csrr	s1,sstatus
ffffffffc0200a5a:	14102973          	csrr	s2,sepc
ffffffffc0200a5e:	143029f3          	csrr	s3,stval
ffffffffc0200a62:	14202a73          	csrr	s4,scause
ffffffffc0200a66:	e822                	sd	s0,16(sp)
ffffffffc0200a68:	e226                	sd	s1,256(sp)
ffffffffc0200a6a:	e64a                	sd	s2,264(sp)
ffffffffc0200a6c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a6e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a70:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a72:	f85ff0ef          	jal	ra,ffffffffc02009f6 <trap>

ffffffffc0200a76 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a76:	6492                	ld	s1,256(sp)
ffffffffc0200a78:	6932                	ld	s2,264(sp)
ffffffffc0200a7a:	10049073          	csrw	sstatus,s1
ffffffffc0200a7e:	14191073          	csrw	sepc,s2
ffffffffc0200a82:	60a2                	ld	ra,8(sp)
ffffffffc0200a84:	61e2                	ld	gp,24(sp)
ffffffffc0200a86:	7202                	ld	tp,32(sp)
ffffffffc0200a88:	72a2                	ld	t0,40(sp)
ffffffffc0200a8a:	7342                	ld	t1,48(sp)
ffffffffc0200a8c:	73e2                	ld	t2,56(sp)
ffffffffc0200a8e:	6406                	ld	s0,64(sp)
ffffffffc0200a90:	64a6                	ld	s1,72(sp)
ffffffffc0200a92:	6546                	ld	a0,80(sp)
ffffffffc0200a94:	65e6                	ld	a1,88(sp)
ffffffffc0200a96:	7606                	ld	a2,96(sp)
ffffffffc0200a98:	76a6                	ld	a3,104(sp)
ffffffffc0200a9a:	7746                	ld	a4,112(sp)
ffffffffc0200a9c:	77e6                	ld	a5,120(sp)
ffffffffc0200a9e:	680a                	ld	a6,128(sp)
ffffffffc0200aa0:	68aa                	ld	a7,136(sp)
ffffffffc0200aa2:	694a                	ld	s2,144(sp)
ffffffffc0200aa4:	69ea                	ld	s3,152(sp)
ffffffffc0200aa6:	7a0a                	ld	s4,160(sp)
ffffffffc0200aa8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aaa:	7b4a                	ld	s6,176(sp)
ffffffffc0200aac:	7bea                	ld	s7,184(sp)
ffffffffc0200aae:	6c0e                	ld	s8,192(sp)
ffffffffc0200ab0:	6cae                	ld	s9,200(sp)
ffffffffc0200ab2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ab4:	6dee                	ld	s11,216(sp)
ffffffffc0200ab6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ab8:	7eae                	ld	t4,232(sp)
ffffffffc0200aba:	7f4e                	ld	t5,240(sp)
ffffffffc0200abc:	7fee                	ld	t6,248(sp)
ffffffffc0200abe:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ac0:	10200073          	sret
	...

ffffffffc0200ad0 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200ad0:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200ad2:	00004697          	auipc	a3,0x4
ffffffffc0200ad6:	17668693          	addi	a3,a3,374 # ffffffffc0204c48 <commands+0x838>
ffffffffc0200ada:	00004617          	auipc	a2,0x4
ffffffffc0200ade:	18e60613          	addi	a2,a2,398 # ffffffffc0204c68 <commands+0x858>
ffffffffc0200ae2:	07d00593          	li	a1,125
ffffffffc0200ae6:	00004517          	auipc	a0,0x4
ffffffffc0200aea:	19a50513          	addi	a0,a0,410 # ffffffffc0204c80 <commands+0x870>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200aee:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200af0:	e16ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200af4 <mm_create>:
mm_create(void) {
ffffffffc0200af4:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200af6:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200afa:	e022                	sd	s0,0(sp)
ffffffffc0200afc:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200afe:	743020ef          	jal	ra,ffffffffc0203a40 <kmalloc>
ffffffffc0200b02:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200b04:	c115                	beqz	a0,ffffffffc0200b28 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b06:	00011797          	auipc	a5,0x11
ffffffffc0200b0a:	95a78793          	addi	a5,a5,-1702 # ffffffffc0211460 <swap_init_ok>
ffffffffc0200b0e:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b10:	e408                	sd	a0,8(s0)
ffffffffc0200b12:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200b14:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200b18:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200b1c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b20:	2781                	sext.w	a5,a5
ffffffffc0200b22:	eb81                	bnez	a5,ffffffffc0200b32 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0200b24:	02053423          	sd	zero,40(a0)
}
ffffffffc0200b28:	8522                	mv	a0,s0
ffffffffc0200b2a:	60a2                	ld	ra,8(sp)
ffffffffc0200b2c:	6402                	ld	s0,0(sp)
ffffffffc0200b2e:	0141                	addi	sp,sp,16
ffffffffc0200b30:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b32:	631000ef          	jal	ra,ffffffffc0201962 <swap_init_mm>
}
ffffffffc0200b36:	8522                	mv	a0,s0
ffffffffc0200b38:	60a2                	ld	ra,8(sp)
ffffffffc0200b3a:	6402                	ld	s0,0(sp)
ffffffffc0200b3c:	0141                	addi	sp,sp,16
ffffffffc0200b3e:	8082                	ret

ffffffffc0200b40 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b40:	1101                	addi	sp,sp,-32
ffffffffc0200b42:	e04a                	sd	s2,0(sp)
ffffffffc0200b44:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b46:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b4a:	e822                	sd	s0,16(sp)
ffffffffc0200b4c:	e426                	sd	s1,8(sp)
ffffffffc0200b4e:	ec06                	sd	ra,24(sp)
ffffffffc0200b50:	84ae                	mv	s1,a1
ffffffffc0200b52:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b54:	6ed020ef          	jal	ra,ffffffffc0203a40 <kmalloc>
    if (vma != NULL) {
ffffffffc0200b58:	c509                	beqz	a0,ffffffffc0200b62 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200b5a:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200b5e:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200b60:	ed00                	sd	s0,24(a0)
}
ffffffffc0200b62:	60e2                	ld	ra,24(sp)
ffffffffc0200b64:	6442                	ld	s0,16(sp)
ffffffffc0200b66:	64a2                	ld	s1,8(sp)
ffffffffc0200b68:	6902                	ld	s2,0(sp)
ffffffffc0200b6a:	6105                	addi	sp,sp,32
ffffffffc0200b6c:	8082                	ret

ffffffffc0200b6e <find_vma>:
    if (mm != NULL) {
ffffffffc0200b6e:	c51d                	beqz	a0,ffffffffc0200b9c <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0200b70:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200b72:	c781                	beqz	a5,ffffffffc0200b7a <find_vma+0xc>
ffffffffc0200b74:	6798                	ld	a4,8(a5)
ffffffffc0200b76:	02e5f663          	bleu	a4,a1,ffffffffc0200ba2 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0200b7a:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b7c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200b7e:	00f50f63          	beq	a0,a5,ffffffffc0200b9c <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200b82:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b86:	fee5ebe3          	bltu	a1,a4,ffffffffc0200b7c <find_vma+0xe>
ffffffffc0200b8a:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200b8e:	fee5f7e3          	bleu	a4,a1,ffffffffc0200b7c <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0200b92:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0200b94:	c781                	beqz	a5,ffffffffc0200b9c <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0200b96:	e91c                	sd	a5,16(a0)
}
ffffffffc0200b98:	853e                	mv	a0,a5
ffffffffc0200b9a:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0200b9c:	4781                	li	a5,0
}
ffffffffc0200b9e:	853e                	mv	a0,a5
ffffffffc0200ba0:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ba2:	6b98                	ld	a4,16(a5)
ffffffffc0200ba4:	fce5fbe3          	bleu	a4,a1,ffffffffc0200b7a <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0200ba8:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0200baa:	b7fd                	j	ffffffffc0200b98 <find_vma+0x2a>

ffffffffc0200bac <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200bac:	6590                	ld	a2,8(a1)
ffffffffc0200bae:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200bb2:	1141                	addi	sp,sp,-16
ffffffffc0200bb4:	e406                	sd	ra,8(sp)
ffffffffc0200bb6:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200bb8:	01066863          	bltu	a2,a6,ffffffffc0200bc8 <insert_vma_struct+0x1c>
ffffffffc0200bbc:	a8b9                	j	ffffffffc0200c1a <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200bbe:	fe87b683          	ld	a3,-24(a5)
ffffffffc0200bc2:	04d66763          	bltu	a2,a3,ffffffffc0200c10 <insert_vma_struct+0x64>
ffffffffc0200bc6:	873e                	mv	a4,a5
ffffffffc0200bc8:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0200bca:	fef51ae3          	bne	a0,a5,ffffffffc0200bbe <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200bce:	02a70463          	beq	a4,a0,ffffffffc0200bf6 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200bd2:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200bd6:	fe873883          	ld	a7,-24(a4)
ffffffffc0200bda:	08d8f063          	bleu	a3,a7,ffffffffc0200c5a <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bde:	04d66e63          	bltu	a2,a3,ffffffffc0200c3a <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0200be2:	00f50a63          	beq	a0,a5,ffffffffc0200bf6 <insert_vma_struct+0x4a>
ffffffffc0200be6:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bea:	0506e863          	bltu	a3,a6,ffffffffc0200c3a <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0200bee:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200bf2:	02c6f263          	bleu	a2,a3,ffffffffc0200c16 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200bf6:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0200bf8:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200bfa:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200bfe:	e390                	sd	a2,0(a5)
ffffffffc0200c00:	e710                	sd	a2,8(a4)
}
ffffffffc0200c02:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200c04:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200c06:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0200c08:	2685                	addiw	a3,a3,1
ffffffffc0200c0a:	d114                	sw	a3,32(a0)
}
ffffffffc0200c0c:	0141                	addi	sp,sp,16
ffffffffc0200c0e:	8082                	ret
    if (le_prev != list) {
ffffffffc0200c10:	fca711e3          	bne	a4,a0,ffffffffc0200bd2 <insert_vma_struct+0x26>
ffffffffc0200c14:	bfd9                	j	ffffffffc0200bea <insert_vma_struct+0x3e>
ffffffffc0200c16:	ebbff0ef          	jal	ra,ffffffffc0200ad0 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c1a:	00004697          	auipc	a3,0x4
ffffffffc0200c1e:	0f668693          	addi	a3,a3,246 # ffffffffc0204d10 <commands+0x900>
ffffffffc0200c22:	00004617          	auipc	a2,0x4
ffffffffc0200c26:	04660613          	addi	a2,a2,70 # ffffffffc0204c68 <commands+0x858>
ffffffffc0200c2a:	08400593          	li	a1,132
ffffffffc0200c2e:	00004517          	auipc	a0,0x4
ffffffffc0200c32:	05250513          	addi	a0,a0,82 # ffffffffc0204c80 <commands+0x870>
ffffffffc0200c36:	cd0ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c3a:	00004697          	auipc	a3,0x4
ffffffffc0200c3e:	11668693          	addi	a3,a3,278 # ffffffffc0204d50 <commands+0x940>
ffffffffc0200c42:	00004617          	auipc	a2,0x4
ffffffffc0200c46:	02660613          	addi	a2,a2,38 # ffffffffc0204c68 <commands+0x858>
ffffffffc0200c4a:	07c00593          	li	a1,124
ffffffffc0200c4e:	00004517          	auipc	a0,0x4
ffffffffc0200c52:	03250513          	addi	a0,a0,50 # ffffffffc0204c80 <commands+0x870>
ffffffffc0200c56:	cb0ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c5a:	00004697          	auipc	a3,0x4
ffffffffc0200c5e:	0d668693          	addi	a3,a3,214 # ffffffffc0204d30 <commands+0x920>
ffffffffc0200c62:	00004617          	auipc	a2,0x4
ffffffffc0200c66:	00660613          	addi	a2,a2,6 # ffffffffc0204c68 <commands+0x858>
ffffffffc0200c6a:	07b00593          	li	a1,123
ffffffffc0200c6e:	00004517          	auipc	a0,0x4
ffffffffc0200c72:	01250513          	addi	a0,a0,18 # ffffffffc0204c80 <commands+0x870>
ffffffffc0200c76:	c90ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200c7a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200c7a:	1141                	addi	sp,sp,-16
ffffffffc0200c7c:	e022                	sd	s0,0(sp)
ffffffffc0200c7e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200c80:	6508                	ld	a0,8(a0)
ffffffffc0200c82:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200c84:	00a40e63          	beq	s0,a0,ffffffffc0200ca0 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c88:	6118                	ld	a4,0(a0)
ffffffffc0200c8a:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200c8c:	03000593          	li	a1,48
ffffffffc0200c90:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200c92:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200c94:	e398                	sd	a4,0(a5)
ffffffffc0200c96:	66d020ef          	jal	ra,ffffffffc0203b02 <kfree>
    return listelm->next;
ffffffffc0200c9a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200c9c:	fea416e3          	bne	s0,a0,ffffffffc0200c88 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200ca0:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200ca2:	6402                	ld	s0,0(sp)
ffffffffc0200ca4:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200ca6:	03000593          	li	a1,48
}
ffffffffc0200caa:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200cac:	6570206f          	j	ffffffffc0203b02 <kfree>

ffffffffc0200cb0 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200cb0:	715d                	addi	sp,sp,-80
ffffffffc0200cb2:	e486                	sd	ra,72(sp)
ffffffffc0200cb4:	e0a2                	sd	s0,64(sp)
ffffffffc0200cb6:	fc26                	sd	s1,56(sp)
ffffffffc0200cb8:	f84a                	sd	s2,48(sp)
ffffffffc0200cba:	f052                	sd	s4,32(sp)
ffffffffc0200cbc:	f44e                	sd	s3,40(sp)
ffffffffc0200cbe:	ec56                	sd	s5,24(sp)
ffffffffc0200cc0:	e85a                	sd	s6,16(sp)
ffffffffc0200cc2:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200cc4:	61f010ef          	jal	ra,ffffffffc0202ae2 <nr_free_pages>
ffffffffc0200cc8:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200cca:	619010ef          	jal	ra,ffffffffc0202ae2 <nr_free_pages>
ffffffffc0200cce:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0200cd0:	e25ff0ef          	jal	ra,ffffffffc0200af4 <mm_create>
    assert(mm != NULL);
ffffffffc0200cd4:	842a                	mv	s0,a0
ffffffffc0200cd6:	03200493          	li	s1,50
ffffffffc0200cda:	e919                	bnez	a0,ffffffffc0200cf0 <vmm_init+0x40>
ffffffffc0200cdc:	aeed                	j	ffffffffc02010d6 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc0200cde:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200ce0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200ce2:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200ce6:	14ed                	addi	s1,s1,-5
ffffffffc0200ce8:	8522                	mv	a0,s0
ffffffffc0200cea:	ec3ff0ef          	jal	ra,ffffffffc0200bac <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0200cee:	c88d                	beqz	s1,ffffffffc0200d20 <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200cf0:	03000513          	li	a0,48
ffffffffc0200cf4:	54d020ef          	jal	ra,ffffffffc0203a40 <kmalloc>
ffffffffc0200cf8:	85aa                	mv	a1,a0
ffffffffc0200cfa:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0200cfe:	f165                	bnez	a0,ffffffffc0200cde <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc0200d00:	00004697          	auipc	a3,0x4
ffffffffc0200d04:	2c868693          	addi	a3,a3,712 # ffffffffc0204fc8 <commands+0xbb8>
ffffffffc0200d08:	00004617          	auipc	a2,0x4
ffffffffc0200d0c:	f6060613          	addi	a2,a2,-160 # ffffffffc0204c68 <commands+0x858>
ffffffffc0200d10:	0ce00593          	li	a1,206
ffffffffc0200d14:	00004517          	auipc	a0,0x4
ffffffffc0200d18:	f6c50513          	addi	a0,a0,-148 # ffffffffc0204c80 <commands+0x870>
ffffffffc0200d1c:	beaff0ef          	jal	ra,ffffffffc0200106 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0200d20:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d24:	1f900993          	li	s3,505
ffffffffc0200d28:	a819                	j	ffffffffc0200d3e <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0200d2a:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d2c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d2e:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200d32:	0495                	addi	s1,s1,5
ffffffffc0200d34:	8522                	mv	a0,s0
ffffffffc0200d36:	e77ff0ef          	jal	ra,ffffffffc0200bac <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d3a:	03348a63          	beq	s1,s3,ffffffffc0200d6e <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200d3e:	03000513          	li	a0,48
ffffffffc0200d42:	4ff020ef          	jal	ra,ffffffffc0203a40 <kmalloc>
ffffffffc0200d46:	85aa                	mv	a1,a0
ffffffffc0200d48:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0200d4c:	fd79                	bnez	a0,ffffffffc0200d2a <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc0200d4e:	00004697          	auipc	a3,0x4
ffffffffc0200d52:	27a68693          	addi	a3,a3,634 # ffffffffc0204fc8 <commands+0xbb8>
ffffffffc0200d56:	00004617          	auipc	a2,0x4
ffffffffc0200d5a:	f1260613          	addi	a2,a2,-238 # ffffffffc0204c68 <commands+0x858>
ffffffffc0200d5e:	0d400593          	li	a1,212
ffffffffc0200d62:	00004517          	auipc	a0,0x4
ffffffffc0200d66:	f1e50513          	addi	a0,a0,-226 # ffffffffc0204c80 <commands+0x870>
ffffffffc0200d6a:	b9cff0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0200d6e:	6418                	ld	a4,8(s0)
ffffffffc0200d70:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200d72:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200d76:	2ae40063          	beq	s0,a4,ffffffffc0201016 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200d7a:	fe873603          	ld	a2,-24(a4)
ffffffffc0200d7e:	ffe78693          	addi	a3,a5,-2
ffffffffc0200d82:	20d61a63          	bne	a2,a3,ffffffffc0200f96 <vmm_init+0x2e6>
ffffffffc0200d86:	ff073683          	ld	a3,-16(a4)
ffffffffc0200d8a:	20d79663          	bne	a5,a3,ffffffffc0200f96 <vmm_init+0x2e6>
ffffffffc0200d8e:	0795                	addi	a5,a5,5
ffffffffc0200d90:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0200d92:	feb792e3          	bne	a5,a1,ffffffffc0200d76 <vmm_init+0xc6>
ffffffffc0200d96:	499d                	li	s3,7
ffffffffc0200d98:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200d9a:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200d9e:	85a6                	mv	a1,s1
ffffffffc0200da0:	8522                	mv	a0,s0
ffffffffc0200da2:	dcdff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
ffffffffc0200da6:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc0200da8:	2e050763          	beqz	a0,ffffffffc0201096 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200dac:	00148593          	addi	a1,s1,1
ffffffffc0200db0:	8522                	mv	a0,s0
ffffffffc0200db2:	dbdff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
ffffffffc0200db6:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0200db8:	2a050f63          	beqz	a0,ffffffffc0201076 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200dbc:	85ce                	mv	a1,s3
ffffffffc0200dbe:	8522                	mv	a0,s0
ffffffffc0200dc0:	dafff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
        assert(vma3 == NULL);
ffffffffc0200dc4:	28051963          	bnez	a0,ffffffffc0201056 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200dc8:	00348593          	addi	a1,s1,3
ffffffffc0200dcc:	8522                	mv	a0,s0
ffffffffc0200dce:	da1ff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
        assert(vma4 == NULL);
ffffffffc0200dd2:	26051263          	bnez	a0,ffffffffc0201036 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200dd6:	00448593          	addi	a1,s1,4
ffffffffc0200dda:	8522                	mv	a0,s0
ffffffffc0200ddc:	d93ff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
        assert(vma5 == NULL);
ffffffffc0200de0:	2c051b63          	bnez	a0,ffffffffc02010b6 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200de4:	008b3783          	ld	a5,8(s6)
ffffffffc0200de8:	1c979763          	bne	a5,s1,ffffffffc0200fb6 <vmm_init+0x306>
ffffffffc0200dec:	010b3783          	ld	a5,16(s6)
ffffffffc0200df0:	1d379363          	bne	a5,s3,ffffffffc0200fb6 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200df4:	008ab783          	ld	a5,8(s5)
ffffffffc0200df8:	1c979f63          	bne	a5,s1,ffffffffc0200fd6 <vmm_init+0x326>
ffffffffc0200dfc:	010ab783          	ld	a5,16(s5)
ffffffffc0200e00:	1d379b63          	bne	a5,s3,ffffffffc0200fd6 <vmm_init+0x326>
ffffffffc0200e04:	0495                	addi	s1,s1,5
ffffffffc0200e06:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e08:	f9749be3          	bne	s1,s7,ffffffffc0200d9e <vmm_init+0xee>
ffffffffc0200e0c:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0200e0e:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0200e10:	85a6                	mv	a1,s1
ffffffffc0200e12:	8522                	mv	a0,s0
ffffffffc0200e14:	d5bff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
ffffffffc0200e18:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0200e1c:	c90d                	beqz	a0,ffffffffc0200e4e <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0200e1e:	6914                	ld	a3,16(a0)
ffffffffc0200e20:	6510                	ld	a2,8(a0)
ffffffffc0200e22:	00004517          	auipc	a0,0x4
ffffffffc0200e26:	05e50513          	addi	a0,a0,94 # ffffffffc0204e80 <commands+0xa70>
ffffffffc0200e2a:	a94ff0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200e2e:	00004697          	auipc	a3,0x4
ffffffffc0200e32:	07a68693          	addi	a3,a3,122 # ffffffffc0204ea8 <commands+0xa98>
ffffffffc0200e36:	00004617          	auipc	a2,0x4
ffffffffc0200e3a:	e3260613          	addi	a2,a2,-462 # ffffffffc0204c68 <commands+0x858>
ffffffffc0200e3e:	0f600593          	li	a1,246
ffffffffc0200e42:	00004517          	auipc	a0,0x4
ffffffffc0200e46:	e3e50513          	addi	a0,a0,-450 # ffffffffc0204c80 <commands+0x870>
ffffffffc0200e4a:	abcff0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0200e4e:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0200e50:	fd3490e3          	bne	s1,s3,ffffffffc0200e10 <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc0200e54:	8522                	mv	a0,s0
ffffffffc0200e56:	e25ff0ef          	jal	ra,ffffffffc0200c7a <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200e5a:	489010ef          	jal	ra,ffffffffc0202ae2 <nr_free_pages>
ffffffffc0200e5e:	28aa1c63          	bne	s4,a0,ffffffffc02010f6 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200e62:	00004517          	auipc	a0,0x4
ffffffffc0200e66:	08650513          	addi	a0,a0,134 # ffffffffc0204ee8 <commands+0xad8>
ffffffffc0200e6a:	a54ff0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200e6e:	475010ef          	jal	ra,ffffffffc0202ae2 <nr_free_pages>
ffffffffc0200e72:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0200e74:	c81ff0ef          	jal	ra,ffffffffc0200af4 <mm_create>
ffffffffc0200e78:	00010797          	auipc	a5,0x10
ffffffffc0200e7c:	60a7b423          	sd	a0,1544(a5) # ffffffffc0211480 <check_mm_struct>
ffffffffc0200e80:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc0200e82:	2a050a63          	beqz	a0,ffffffffc0201136 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200e86:	00010797          	auipc	a5,0x10
ffffffffc0200e8a:	5e278793          	addi	a5,a5,1506 # ffffffffc0211468 <boot_pgdir>
ffffffffc0200e8e:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0200e90:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200e92:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0200e94:	32079d63          	bnez	a5,ffffffffc02011ce <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200e98:	03000513          	li	a0,48
ffffffffc0200e9c:	3a5020ef          	jal	ra,ffffffffc0203a40 <kmalloc>
ffffffffc0200ea0:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0200ea2:	14050a63          	beqz	a0,ffffffffc0200ff6 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc0200ea6:	002007b7          	lui	a5,0x200
ffffffffc0200eaa:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0200eae:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0200eb0:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0200eb2:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200eb6:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0200eb8:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200ebc:	cf1ff0ef          	jal	ra,ffffffffc0200bac <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0200ec0:	10000593          	li	a1,256
ffffffffc0200ec4:	8522                	mv	a0,s0
ffffffffc0200ec6:	ca9ff0ef          	jal	ra,ffffffffc0200b6e <find_vma>
ffffffffc0200eca:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0200ece:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0200ed2:	2aaa1263          	bne	s4,a0,ffffffffc0201176 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc0200ed6:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0200eda:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0200edc:	fee79de3          	bne	a5,a4,ffffffffc0200ed6 <vmm_init+0x226>
        sum += i;
ffffffffc0200ee0:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0200ee2:	10000793          	li	a5,256
        sum += i;
ffffffffc0200ee6:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0200eea:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0200eee:	0007c683          	lbu	a3,0(a5)
ffffffffc0200ef2:	0785                	addi	a5,a5,1
ffffffffc0200ef4:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0200ef6:	fec79ce3          	bne	a5,a2,ffffffffc0200eee <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0200efa:	2a071a63          	bnez	a4,ffffffffc02011ae <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0200efe:	4581                	li	a1,0
ffffffffc0200f00:	8526                	mv	a0,s1
ffffffffc0200f02:	687010ef          	jal	ra,ffffffffc0202d88 <page_remove>
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f06:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0200f08:	00010717          	auipc	a4,0x10
ffffffffc0200f0c:	56870713          	addi	a4,a4,1384 # ffffffffc0211470 <npage>
ffffffffc0200f10:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f12:	078a                	slli	a5,a5,0x2
ffffffffc0200f14:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f16:	28e7f063          	bleu	a4,a5,ffffffffc0201196 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f1a:	00005717          	auipc	a4,0x5
ffffffffc0200f1e:	19e70713          	addi	a4,a4,414 # ffffffffc02060b8 <nbase>
ffffffffc0200f22:	6318                	ld	a4,0(a4)
ffffffffc0200f24:	00010697          	auipc	a3,0x10
ffffffffc0200f28:	67468693          	addi	a3,a3,1652 # ffffffffc0211598 <pages>
ffffffffc0200f2c:	6288                	ld	a0,0(a3)
ffffffffc0200f2e:	8f99                	sub	a5,a5,a4
ffffffffc0200f30:	00379713          	slli	a4,a5,0x3
ffffffffc0200f34:	97ba                	add	a5,a5,a4
ffffffffc0200f36:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0200f38:	953e                	add	a0,a0,a5
ffffffffc0200f3a:	4585                	li	a1,1
ffffffffc0200f3c:	361010ef          	jal	ra,ffffffffc0202a9c <free_pages>

    pgdir[0] = 0;
ffffffffc0200f40:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0200f44:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0200f46:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0200f4a:	d31ff0ef          	jal	ra,ffffffffc0200c7a <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0200f4e:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc0200f50:	00010797          	auipc	a5,0x10
ffffffffc0200f54:	5207b823          	sd	zero,1328(a5) # ffffffffc0211480 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200f58:	38b010ef          	jal	ra,ffffffffc0202ae2 <nr_free_pages>
ffffffffc0200f5c:	1aa99d63          	bne	s3,a0,ffffffffc0201116 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0200f60:	00004517          	auipc	a0,0x4
ffffffffc0200f64:	03050513          	addi	a0,a0,48 # ffffffffc0204f90 <commands+0xb80>
ffffffffc0200f68:	956ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200f6c:	377010ef          	jal	ra,ffffffffc0202ae2 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0200f70:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200f72:	1ea91263          	bne	s2,a0,ffffffffc0201156 <vmm_init+0x4a6>
}
ffffffffc0200f76:	6406                	ld	s0,64(sp)
ffffffffc0200f78:	60a6                	ld	ra,72(sp)
ffffffffc0200f7a:	74e2                	ld	s1,56(sp)
ffffffffc0200f7c:	7942                	ld	s2,48(sp)
ffffffffc0200f7e:	79a2                	ld	s3,40(sp)
ffffffffc0200f80:	7a02                	ld	s4,32(sp)
ffffffffc0200f82:	6ae2                	ld	s5,24(sp)
ffffffffc0200f84:	6b42                	ld	s6,16(sp)
ffffffffc0200f86:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200f88:	00004517          	auipc	a0,0x4
ffffffffc0200f8c:	02850513          	addi	a0,a0,40 # ffffffffc0204fb0 <commands+0xba0>
}
ffffffffc0200f90:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200f92:	92cff06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200f96:	00004697          	auipc	a3,0x4
ffffffffc0200f9a:	e0268693          	addi	a3,a3,-510 # ffffffffc0204d98 <commands+0x988>
ffffffffc0200f9e:	00004617          	auipc	a2,0x4
ffffffffc0200fa2:	cca60613          	addi	a2,a2,-822 # ffffffffc0204c68 <commands+0x858>
ffffffffc0200fa6:	0dd00593          	li	a1,221
ffffffffc0200faa:	00004517          	auipc	a0,0x4
ffffffffc0200fae:	cd650513          	addi	a0,a0,-810 # ffffffffc0204c80 <commands+0x870>
ffffffffc0200fb2:	954ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200fb6:	00004697          	auipc	a3,0x4
ffffffffc0200fba:	e6a68693          	addi	a3,a3,-406 # ffffffffc0204e20 <commands+0xa10>
ffffffffc0200fbe:	00004617          	auipc	a2,0x4
ffffffffc0200fc2:	caa60613          	addi	a2,a2,-854 # ffffffffc0204c68 <commands+0x858>
ffffffffc0200fc6:	0ed00593          	li	a1,237
ffffffffc0200fca:	00004517          	auipc	a0,0x4
ffffffffc0200fce:	cb650513          	addi	a0,a0,-842 # ffffffffc0204c80 <commands+0x870>
ffffffffc0200fd2:	934ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200fd6:	00004697          	auipc	a3,0x4
ffffffffc0200fda:	e7a68693          	addi	a3,a3,-390 # ffffffffc0204e50 <commands+0xa40>
ffffffffc0200fde:	00004617          	auipc	a2,0x4
ffffffffc0200fe2:	c8a60613          	addi	a2,a2,-886 # ffffffffc0204c68 <commands+0x858>
ffffffffc0200fe6:	0ee00593          	li	a1,238
ffffffffc0200fea:	00004517          	auipc	a0,0x4
ffffffffc0200fee:	c9650513          	addi	a0,a0,-874 # ffffffffc0204c80 <commands+0x870>
ffffffffc0200ff2:	914ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(vma != NULL);
ffffffffc0200ff6:	00004697          	auipc	a3,0x4
ffffffffc0200ffa:	fd268693          	addi	a3,a3,-46 # ffffffffc0204fc8 <commands+0xbb8>
ffffffffc0200ffe:	00004617          	auipc	a2,0x4
ffffffffc0201002:	c6a60613          	addi	a2,a2,-918 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201006:	11100593          	li	a1,273
ffffffffc020100a:	00004517          	auipc	a0,0x4
ffffffffc020100e:	c7650513          	addi	a0,a0,-906 # ffffffffc0204c80 <commands+0x870>
ffffffffc0201012:	8f4ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201016:	00004697          	auipc	a3,0x4
ffffffffc020101a:	d6a68693          	addi	a3,a3,-662 # ffffffffc0204d80 <commands+0x970>
ffffffffc020101e:	00004617          	auipc	a2,0x4
ffffffffc0201022:	c4a60613          	addi	a2,a2,-950 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201026:	0db00593          	li	a1,219
ffffffffc020102a:	00004517          	auipc	a0,0x4
ffffffffc020102e:	c5650513          	addi	a0,a0,-938 # ffffffffc0204c80 <commands+0x870>
ffffffffc0201032:	8d4ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma4 == NULL);
ffffffffc0201036:	00004697          	auipc	a3,0x4
ffffffffc020103a:	dca68693          	addi	a3,a3,-566 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020103e:	00004617          	auipc	a2,0x4
ffffffffc0201042:	c2a60613          	addi	a2,a2,-982 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201046:	0e900593          	li	a1,233
ffffffffc020104a:	00004517          	auipc	a0,0x4
ffffffffc020104e:	c3650513          	addi	a0,a0,-970 # ffffffffc0204c80 <commands+0x870>
ffffffffc0201052:	8b4ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma3 == NULL);
ffffffffc0201056:	00004697          	auipc	a3,0x4
ffffffffc020105a:	d9a68693          	addi	a3,a3,-614 # ffffffffc0204df0 <commands+0x9e0>
ffffffffc020105e:	00004617          	auipc	a2,0x4
ffffffffc0201062:	c0a60613          	addi	a2,a2,-1014 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201066:	0e700593          	li	a1,231
ffffffffc020106a:	00004517          	auipc	a0,0x4
ffffffffc020106e:	c1650513          	addi	a0,a0,-1002 # ffffffffc0204c80 <commands+0x870>
ffffffffc0201072:	894ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2 != NULL);
ffffffffc0201076:	00004697          	auipc	a3,0x4
ffffffffc020107a:	d6a68693          	addi	a3,a3,-662 # ffffffffc0204de0 <commands+0x9d0>
ffffffffc020107e:	00004617          	auipc	a2,0x4
ffffffffc0201082:	bea60613          	addi	a2,a2,-1046 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201086:	0e500593          	li	a1,229
ffffffffc020108a:	00004517          	auipc	a0,0x4
ffffffffc020108e:	bf650513          	addi	a0,a0,-1034 # ffffffffc0204c80 <commands+0x870>
ffffffffc0201092:	874ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1 != NULL);
ffffffffc0201096:	00004697          	auipc	a3,0x4
ffffffffc020109a:	d3a68693          	addi	a3,a3,-710 # ffffffffc0204dd0 <commands+0x9c0>
ffffffffc020109e:	00004617          	auipc	a2,0x4
ffffffffc02010a2:	bca60613          	addi	a2,a2,-1078 # ffffffffc0204c68 <commands+0x858>
ffffffffc02010a6:	0e300593          	li	a1,227
ffffffffc02010aa:	00004517          	auipc	a0,0x4
ffffffffc02010ae:	bd650513          	addi	a0,a0,-1066 # ffffffffc0204c80 <commands+0x870>
ffffffffc02010b2:	854ff0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma5 == NULL);
ffffffffc02010b6:	00004697          	auipc	a3,0x4
ffffffffc02010ba:	d5a68693          	addi	a3,a3,-678 # ffffffffc0204e10 <commands+0xa00>
ffffffffc02010be:	00004617          	auipc	a2,0x4
ffffffffc02010c2:	baa60613          	addi	a2,a2,-1110 # ffffffffc0204c68 <commands+0x858>
ffffffffc02010c6:	0eb00593          	li	a1,235
ffffffffc02010ca:	00004517          	auipc	a0,0x4
ffffffffc02010ce:	bb650513          	addi	a0,a0,-1098 # ffffffffc0204c80 <commands+0x870>
ffffffffc02010d2:	834ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(mm != NULL);
ffffffffc02010d6:	00004697          	auipc	a3,0x4
ffffffffc02010da:	c9a68693          	addi	a3,a3,-870 # ffffffffc0204d70 <commands+0x960>
ffffffffc02010de:	00004617          	auipc	a2,0x4
ffffffffc02010e2:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0204c68 <commands+0x858>
ffffffffc02010e6:	0c700593          	li	a1,199
ffffffffc02010ea:	00004517          	auipc	a0,0x4
ffffffffc02010ee:	b9650513          	addi	a0,a0,-1130 # ffffffffc0204c80 <commands+0x870>
ffffffffc02010f2:	814ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02010f6:	00004697          	auipc	a3,0x4
ffffffffc02010fa:	dca68693          	addi	a3,a3,-566 # ffffffffc0204ec0 <commands+0xab0>
ffffffffc02010fe:	00004617          	auipc	a2,0x4
ffffffffc0201102:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201106:	0fb00593          	li	a1,251
ffffffffc020110a:	00004517          	auipc	a0,0x4
ffffffffc020110e:	b7650513          	addi	a0,a0,-1162 # ffffffffc0204c80 <commands+0x870>
ffffffffc0201112:	ff5fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201116:	00004697          	auipc	a3,0x4
ffffffffc020111a:	daa68693          	addi	a3,a3,-598 # ffffffffc0204ec0 <commands+0xab0>
ffffffffc020111e:	00004617          	auipc	a2,0x4
ffffffffc0201122:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201126:	12e00593          	li	a1,302
ffffffffc020112a:	00004517          	auipc	a0,0x4
ffffffffc020112e:	b5650513          	addi	a0,a0,-1194 # ffffffffc0204c80 <commands+0x870>
ffffffffc0201132:	fd5fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201136:	00004697          	auipc	a3,0x4
ffffffffc020113a:	dd268693          	addi	a3,a3,-558 # ffffffffc0204f08 <commands+0xaf8>
ffffffffc020113e:	00004617          	auipc	a2,0x4
ffffffffc0201142:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201146:	10a00593          	li	a1,266
ffffffffc020114a:	00004517          	auipc	a0,0x4
ffffffffc020114e:	b3650513          	addi	a0,a0,-1226 # ffffffffc0204c80 <commands+0x870>
ffffffffc0201152:	fb5fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201156:	00004697          	auipc	a3,0x4
ffffffffc020115a:	d6a68693          	addi	a3,a3,-662 # ffffffffc0204ec0 <commands+0xab0>
ffffffffc020115e:	00004617          	auipc	a2,0x4
ffffffffc0201162:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201166:	0bd00593          	li	a1,189
ffffffffc020116a:	00004517          	auipc	a0,0x4
ffffffffc020116e:	b1650513          	addi	a0,a0,-1258 # ffffffffc0204c80 <commands+0x870>
ffffffffc0201172:	f95fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0201176:	00004697          	auipc	a3,0x4
ffffffffc020117a:	dba68693          	addi	a3,a3,-582 # ffffffffc0204f30 <commands+0xb20>
ffffffffc020117e:	00004617          	auipc	a2,0x4
ffffffffc0201182:	aea60613          	addi	a2,a2,-1302 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201186:	11600593          	li	a1,278
ffffffffc020118a:	00004517          	auipc	a0,0x4
ffffffffc020118e:	af650513          	addi	a0,a0,-1290 # ffffffffc0204c80 <commands+0x870>
ffffffffc0201192:	f75fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201196:	00004617          	auipc	a2,0x4
ffffffffc020119a:	dca60613          	addi	a2,a2,-566 # ffffffffc0204f60 <commands+0xb50>
ffffffffc020119e:	06500593          	li	a1,101
ffffffffc02011a2:	00004517          	auipc	a0,0x4
ffffffffc02011a6:	dde50513          	addi	a0,a0,-546 # ffffffffc0204f80 <commands+0xb70>
ffffffffc02011aa:	f5dfe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(sum == 0);
ffffffffc02011ae:	00004697          	auipc	a3,0x4
ffffffffc02011b2:	da268693          	addi	a3,a3,-606 # ffffffffc0204f50 <commands+0xb40>
ffffffffc02011b6:	00004617          	auipc	a2,0x4
ffffffffc02011ba:	ab260613          	addi	a2,a2,-1358 # ffffffffc0204c68 <commands+0x858>
ffffffffc02011be:	12000593          	li	a1,288
ffffffffc02011c2:	00004517          	auipc	a0,0x4
ffffffffc02011c6:	abe50513          	addi	a0,a0,-1346 # ffffffffc0204c80 <commands+0x870>
ffffffffc02011ca:	f3dfe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02011ce:	00004697          	auipc	a3,0x4
ffffffffc02011d2:	d5268693          	addi	a3,a3,-686 # ffffffffc0204f20 <commands+0xb10>
ffffffffc02011d6:	00004617          	auipc	a2,0x4
ffffffffc02011da:	a9260613          	addi	a2,a2,-1390 # ffffffffc0204c68 <commands+0x858>
ffffffffc02011de:	10d00593          	li	a1,269
ffffffffc02011e2:	00004517          	auipc	a0,0x4
ffffffffc02011e6:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0204c80 <commands+0x870>
ffffffffc02011ea:	f1dfe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02011ee <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02011ee:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02011f0:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02011f2:	f022                	sd	s0,32(sp)
ffffffffc02011f4:	ec26                	sd	s1,24(sp)
ffffffffc02011f6:	f406                	sd	ra,40(sp)
ffffffffc02011f8:	e84a                	sd	s2,16(sp)
ffffffffc02011fa:	8432                	mv	s0,a2
ffffffffc02011fc:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02011fe:	971ff0ef          	jal	ra,ffffffffc0200b6e <find_vma>

    pgfault_num++;
ffffffffc0201202:	00010797          	auipc	a5,0x10
ffffffffc0201206:	24e78793          	addi	a5,a5,590 # ffffffffc0211450 <pgfault_num>
ffffffffc020120a:	439c                	lw	a5,0(a5)
ffffffffc020120c:	2785                	addiw	a5,a5,1
ffffffffc020120e:	00010717          	auipc	a4,0x10
ffffffffc0201212:	24f72123          	sw	a5,578(a4) # ffffffffc0211450 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201216:	c549                	beqz	a0,ffffffffc02012a0 <do_pgfault+0xb2>
ffffffffc0201218:	651c                	ld	a5,8(a0)
ffffffffc020121a:	08f46363          	bltu	s0,a5,ffffffffc02012a0 <do_pgfault+0xb2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020121e:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0201220:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201222:	8b89                	andi	a5,a5,2
ffffffffc0201224:	efa9                	bnez	a5,ffffffffc020127e <do_pgfault+0x90>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201226:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0201228:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020122a:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc020122c:	85a2                	mv	a1,s0
ffffffffc020122e:	4605                	li	a2,1
ffffffffc0201230:	0f3010ef          	jal	ra,ffffffffc0202b22 <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0201234:	610c                	ld	a1,0(a0)
ffffffffc0201236:	c5b1                	beqz	a1,ffffffffc0201282 <do_pgfault+0x94>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201238:	00010797          	auipc	a5,0x10
ffffffffc020123c:	22878793          	addi	a5,a5,552 # ffffffffc0211460 <swap_init_ok>
ffffffffc0201240:	439c                	lw	a5,0(a5)
ffffffffc0201242:	2781                	sext.w	a5,a5
ffffffffc0201244:	c7bd                	beqz	a5,ffffffffc02012b2 <do_pgfault+0xc4>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc0201246:	85a2                	mv	a1,s0
ffffffffc0201248:	0030                	addi	a2,sp,8
ffffffffc020124a:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc020124c:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc020124e:	049000ef          	jal	ra,ffffffffc0201a96 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0201252:	65a2                	ld	a1,8(sp)
ffffffffc0201254:	6c88                	ld	a0,24(s1)
ffffffffc0201256:	86ca                	mv	a3,s2
ffffffffc0201258:	8622                	mv	a2,s0
ffffffffc020125a:	3a1010ef          	jal	ra,ffffffffc0202dfa <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc020125e:	6622                	ld	a2,8(sp)
ffffffffc0201260:	4685                	li	a3,1
ffffffffc0201262:	85a2                	mv	a1,s0
ffffffffc0201264:	8526                	mv	a0,s1
ffffffffc0201266:	70c000ef          	jal	ra,ffffffffc0201972 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc020126a:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc020126c:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc020126e:	e320                	sd	s0,64(a4)
failed:
    return ret;
}
ffffffffc0201270:	70a2                	ld	ra,40(sp)
ffffffffc0201272:	7402                	ld	s0,32(sp)
ffffffffc0201274:	64e2                	ld	s1,24(sp)
ffffffffc0201276:	6942                	ld	s2,16(sp)
ffffffffc0201278:	853e                	mv	a0,a5
ffffffffc020127a:	6145                	addi	sp,sp,48
ffffffffc020127c:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc020127e:	4959                	li	s2,22
ffffffffc0201280:	b75d                	j	ffffffffc0201226 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201282:	6c88                	ld	a0,24(s1)
ffffffffc0201284:	864a                	mv	a2,s2
ffffffffc0201286:	85a2                	mv	a1,s0
ffffffffc0201288:	726020ef          	jal	ra,ffffffffc02039ae <pgdir_alloc_page>
   ret = 0;
ffffffffc020128c:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020128e:	f16d                	bnez	a0,ffffffffc0201270 <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201290:	00004517          	auipc	a0,0x4
ffffffffc0201294:	a3050513          	addi	a0,a0,-1488 # ffffffffc0204cc0 <commands+0x8b0>
ffffffffc0201298:	e27fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc020129c:	57f1                	li	a5,-4
            goto failed;
ffffffffc020129e:	bfc9                	j	ffffffffc0201270 <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02012a0:	85a2                	mv	a1,s0
ffffffffc02012a2:	00004517          	auipc	a0,0x4
ffffffffc02012a6:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0204c90 <commands+0x880>
ffffffffc02012aa:	e15fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc02012ae:	57f5                	li	a5,-3
        goto failed;
ffffffffc02012b0:	b7c1                	j	ffffffffc0201270 <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02012b2:	00004517          	auipc	a0,0x4
ffffffffc02012b6:	a3650513          	addi	a0,a0,-1482 # ffffffffc0204ce8 <commands+0x8d8>
ffffffffc02012ba:	e05fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc02012be:	57f1                	li	a5,-4
            goto failed;
ffffffffc02012c0:	bf45                	j	ffffffffc0201270 <do_pgfault+0x82>

ffffffffc02012c2 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02012c2:	7135                	addi	sp,sp,-160
ffffffffc02012c4:	ed06                	sd	ra,152(sp)
ffffffffc02012c6:	e922                	sd	s0,144(sp)
ffffffffc02012c8:	e526                	sd	s1,136(sp)
ffffffffc02012ca:	e14a                	sd	s2,128(sp)
ffffffffc02012cc:	fcce                	sd	s3,120(sp)
ffffffffc02012ce:	f8d2                	sd	s4,112(sp)
ffffffffc02012d0:	f4d6                	sd	s5,104(sp)
ffffffffc02012d2:	f0da                	sd	s6,96(sp)
ffffffffc02012d4:	ecde                	sd	s7,88(sp)
ffffffffc02012d6:	e8e2                	sd	s8,80(sp)
ffffffffc02012d8:	e4e6                	sd	s9,72(sp)
ffffffffc02012da:	e0ea                	sd	s10,64(sp)
ffffffffc02012dc:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02012de:	0e5020ef          	jal	ra,ffffffffc0203bc2 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02012e2:	00010797          	auipc	a5,0x10
ffffffffc02012e6:	23e78793          	addi	a5,a5,574 # ffffffffc0211520 <max_swap_offset>
ffffffffc02012ea:	6394                	ld	a3,0(a5)
ffffffffc02012ec:	010007b7          	lui	a5,0x1000
ffffffffc02012f0:	17e1                	addi	a5,a5,-8
ffffffffc02012f2:	ff968713          	addi	a4,a3,-7
ffffffffc02012f6:	42e7ea63          	bltu	a5,a4,ffffffffc020172a <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02012fa:	00009797          	auipc	a5,0x9
ffffffffc02012fe:	d0678793          	addi	a5,a5,-762 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc0201302:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0201304:	00010697          	auipc	a3,0x10
ffffffffc0201308:	14f6ba23          	sd	a5,340(a3) # ffffffffc0211458 <sm>
     int r = sm->init();
ffffffffc020130c:	9702                	jalr	a4
ffffffffc020130e:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc0201310:	c10d                	beqz	a0,ffffffffc0201332 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201312:	60ea                	ld	ra,152(sp)
ffffffffc0201314:	644a                	ld	s0,144(sp)
ffffffffc0201316:	855a                	mv	a0,s6
ffffffffc0201318:	64aa                	ld	s1,136(sp)
ffffffffc020131a:	690a                	ld	s2,128(sp)
ffffffffc020131c:	79e6                	ld	s3,120(sp)
ffffffffc020131e:	7a46                	ld	s4,112(sp)
ffffffffc0201320:	7aa6                	ld	s5,104(sp)
ffffffffc0201322:	7b06                	ld	s6,96(sp)
ffffffffc0201324:	6be6                	ld	s7,88(sp)
ffffffffc0201326:	6c46                	ld	s8,80(sp)
ffffffffc0201328:	6ca6                	ld	s9,72(sp)
ffffffffc020132a:	6d06                	ld	s10,64(sp)
ffffffffc020132c:	7de2                	ld	s11,56(sp)
ffffffffc020132e:	610d                	addi	sp,sp,160
ffffffffc0201330:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201332:	00010797          	auipc	a5,0x10
ffffffffc0201336:	12678793          	addi	a5,a5,294 # ffffffffc0211458 <sm>
ffffffffc020133a:	639c                	ld	a5,0(a5)
ffffffffc020133c:	00004517          	auipc	a0,0x4
ffffffffc0201340:	d1c50513          	addi	a0,a0,-740 # ffffffffc0205058 <commands+0xc48>
ffffffffc0201344:	00010417          	auipc	s0,0x10
ffffffffc0201348:	21c40413          	addi	s0,s0,540 # ffffffffc0211560 <free_area>
ffffffffc020134c:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020134e:	4785                	li	a5,1
ffffffffc0201350:	00010717          	auipc	a4,0x10
ffffffffc0201354:	10f72823          	sw	a5,272(a4) # ffffffffc0211460 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201358:	d67fe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020135c:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020135e:	2e878a63          	beq	a5,s0,ffffffffc0201652 <swap_init+0x390>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201362:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201366:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201368:	8b05                	andi	a4,a4,1
ffffffffc020136a:	2e070863          	beqz	a4,ffffffffc020165a <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc020136e:	4481                	li	s1,0
ffffffffc0201370:	4901                	li	s2,0
ffffffffc0201372:	a031                	j	ffffffffc020137e <swap_init+0xbc>
ffffffffc0201374:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0201378:	8b09                	andi	a4,a4,2
ffffffffc020137a:	2e070063          	beqz	a4,ffffffffc020165a <swap_init+0x398>
        count ++, total += p->property;
ffffffffc020137e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201382:	679c                	ld	a5,8(a5)
ffffffffc0201384:	2905                	addiw	s2,s2,1
ffffffffc0201386:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201388:	fe8796e3          	bne	a5,s0,ffffffffc0201374 <swap_init+0xb2>
ffffffffc020138c:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc020138e:	754010ef          	jal	ra,ffffffffc0202ae2 <nr_free_pages>
ffffffffc0201392:	5b351863          	bne	a0,s3,ffffffffc0201942 <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0201396:	8626                	mv	a2,s1
ffffffffc0201398:	85ca                	mv	a1,s2
ffffffffc020139a:	00004517          	auipc	a0,0x4
ffffffffc020139e:	d0650513          	addi	a0,a0,-762 # ffffffffc02050a0 <commands+0xc90>
ffffffffc02013a2:	d1dfe0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02013a6:	f4eff0ef          	jal	ra,ffffffffc0200af4 <mm_create>
ffffffffc02013aa:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02013ac:	50050b63          	beqz	a0,ffffffffc02018c2 <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02013b0:	00010797          	auipc	a5,0x10
ffffffffc02013b4:	0d078793          	addi	a5,a5,208 # ffffffffc0211480 <check_mm_struct>
ffffffffc02013b8:	639c                	ld	a5,0(a5)
ffffffffc02013ba:	52079463          	bnez	a5,ffffffffc02018e2 <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013be:	00010797          	auipc	a5,0x10
ffffffffc02013c2:	0aa78793          	addi	a5,a5,170 # ffffffffc0211468 <boot_pgdir>
ffffffffc02013c6:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc02013c8:	00010797          	auipc	a5,0x10
ffffffffc02013cc:	0aa7bc23          	sd	a0,184(a5) # ffffffffc0211480 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02013d0:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013d2:	ec3a                	sd	a4,24(sp)
ffffffffc02013d4:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02013d6:	52079663          	bnez	a5,ffffffffc0201902 <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02013da:	6599                	lui	a1,0x6
ffffffffc02013dc:	460d                	li	a2,3
ffffffffc02013de:	6505                	lui	a0,0x1
ffffffffc02013e0:	f60ff0ef          	jal	ra,ffffffffc0200b40 <vma_create>
ffffffffc02013e4:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02013e6:	52050e63          	beqz	a0,ffffffffc0201922 <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc02013ea:	855e                	mv	a0,s7
ffffffffc02013ec:	fc0ff0ef          	jal	ra,ffffffffc0200bac <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02013f0:	00004517          	auipc	a0,0x4
ffffffffc02013f4:	cf050513          	addi	a0,a0,-784 # ffffffffc02050e0 <commands+0xcd0>
ffffffffc02013f8:	cc7fe0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02013fc:	018bb503          	ld	a0,24(s7)
ffffffffc0201400:	4605                	li	a2,1
ffffffffc0201402:	6585                	lui	a1,0x1
ffffffffc0201404:	71e010ef          	jal	ra,ffffffffc0202b22 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201408:	40050d63          	beqz	a0,ffffffffc0201822 <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020140c:	00004517          	auipc	a0,0x4
ffffffffc0201410:	d2450513          	addi	a0,a0,-732 # ffffffffc0205130 <commands+0xd20>
ffffffffc0201414:	00010a17          	auipc	s4,0x10
ffffffffc0201418:	084a0a13          	addi	s4,s4,132 # ffffffffc0211498 <check_rp>
ffffffffc020141c:	ca3fe0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201420:	00010a97          	auipc	s5,0x10
ffffffffc0201424:	098a8a93          	addi	s5,s5,152 # ffffffffc02114b8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201428:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc020142a:	4505                	li	a0,1
ffffffffc020142c:	5e8010ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201430:	00a9b023          	sd	a0,0(s3)
          assert(check_rp[i] != NULL );
ffffffffc0201434:	2a050b63          	beqz	a0,ffffffffc02016ea <swap_init+0x428>
ffffffffc0201438:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc020143a:	8b89                	andi	a5,a5,2
ffffffffc020143c:	28079763          	bnez	a5,ffffffffc02016ca <swap_init+0x408>
ffffffffc0201440:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201442:	ff5994e3          	bne	s3,s5,ffffffffc020142a <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201446:	601c                	ld	a5,0(s0)
ffffffffc0201448:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc020144c:	00010d17          	auipc	s10,0x10
ffffffffc0201450:	04cd0d13          	addi	s10,s10,76 # ffffffffc0211498 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0201454:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0201456:	481c                	lw	a5,16(s0)
ffffffffc0201458:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc020145a:	00010797          	auipc	a5,0x10
ffffffffc020145e:	1087b723          	sd	s0,270(a5) # ffffffffc0211568 <free_area+0x8>
ffffffffc0201462:	00010797          	auipc	a5,0x10
ffffffffc0201466:	0e87bf23          	sd	s0,254(a5) # ffffffffc0211560 <free_area>
     nr_free = 0;
ffffffffc020146a:	00010797          	auipc	a5,0x10
ffffffffc020146e:	1007a323          	sw	zero,262(a5) # ffffffffc0211570 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0201472:	000d3503          	ld	a0,0(s10)
ffffffffc0201476:	4585                	li	a1,1
ffffffffc0201478:	0d21                	addi	s10,s10,8
ffffffffc020147a:	622010ef          	jal	ra,ffffffffc0202a9c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020147e:	ff5d1ae3          	bne	s10,s5,ffffffffc0201472 <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201482:	01042d03          	lw	s10,16(s0)
ffffffffc0201486:	4791                	li	a5,4
ffffffffc0201488:	36fd1d63          	bne	s10,a5,ffffffffc0201802 <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020148c:	00004517          	auipc	a0,0x4
ffffffffc0201490:	d2c50513          	addi	a0,a0,-724 # ffffffffc02051b8 <commands+0xda8>
ffffffffc0201494:	c2bfe0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201498:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020149a:	00010797          	auipc	a5,0x10
ffffffffc020149e:	fa07ab23          	sw	zero,-74(a5) # ffffffffc0211450 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02014a2:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02014a4:	00010797          	auipc	a5,0x10
ffffffffc02014a8:	fac78793          	addi	a5,a5,-84 # ffffffffc0211450 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02014ac:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02014b0:	4398                	lw	a4,0(a5)
ffffffffc02014b2:	4585                	li	a1,1
ffffffffc02014b4:	2701                	sext.w	a4,a4
ffffffffc02014b6:	30b71663          	bne	a4,a1,ffffffffc02017c2 <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02014ba:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02014be:	4394                	lw	a3,0(a5)
ffffffffc02014c0:	2681                	sext.w	a3,a3
ffffffffc02014c2:	32e69063          	bne	a3,a4,ffffffffc02017e2 <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02014c6:	6689                	lui	a3,0x2
ffffffffc02014c8:	462d                	li	a2,11
ffffffffc02014ca:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc02014ce:	4398                	lw	a4,0(a5)
ffffffffc02014d0:	4589                	li	a1,2
ffffffffc02014d2:	2701                	sext.w	a4,a4
ffffffffc02014d4:	26b71763          	bne	a4,a1,ffffffffc0201742 <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02014d8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02014dc:	4394                	lw	a3,0(a5)
ffffffffc02014de:	2681                	sext.w	a3,a3
ffffffffc02014e0:	28e69163          	bne	a3,a4,ffffffffc0201762 <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02014e4:	668d                	lui	a3,0x3
ffffffffc02014e6:	4631                	li	a2,12
ffffffffc02014e8:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc02014ec:	4398                	lw	a4,0(a5)
ffffffffc02014ee:	458d                	li	a1,3
ffffffffc02014f0:	2701                	sext.w	a4,a4
ffffffffc02014f2:	28b71863          	bne	a4,a1,ffffffffc0201782 <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02014f6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02014fa:	4394                	lw	a3,0(a5)
ffffffffc02014fc:	2681                	sext.w	a3,a3
ffffffffc02014fe:	2ae69263          	bne	a3,a4,ffffffffc02017a2 <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201502:	6691                	lui	a3,0x4
ffffffffc0201504:	4635                	li	a2,13
ffffffffc0201506:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc020150a:	4398                	lw	a4,0(a5)
ffffffffc020150c:	2701                	sext.w	a4,a4
ffffffffc020150e:	33a71a63          	bne	a4,s10,ffffffffc0201842 <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201512:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0201516:	439c                	lw	a5,0(a5)
ffffffffc0201518:	2781                	sext.w	a5,a5
ffffffffc020151a:	34e79463          	bne	a5,a4,ffffffffc0201862 <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020151e:	481c                	lw	a5,16(s0)
ffffffffc0201520:	36079163          	bnez	a5,ffffffffc0201882 <swap_init+0x5c0>
ffffffffc0201524:	00010797          	auipc	a5,0x10
ffffffffc0201528:	f9478793          	addi	a5,a5,-108 # ffffffffc02114b8 <swap_in_seq_no>
ffffffffc020152c:	00010717          	auipc	a4,0x10
ffffffffc0201530:	fb470713          	addi	a4,a4,-76 # ffffffffc02114e0 <swap_out_seq_no>
ffffffffc0201534:	00010617          	auipc	a2,0x10
ffffffffc0201538:	fac60613          	addi	a2,a2,-84 # ffffffffc02114e0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc020153c:	56fd                	li	a3,-1
ffffffffc020153e:	c394                	sw	a3,0(a5)
ffffffffc0201540:	c314                	sw	a3,0(a4)
ffffffffc0201542:	0791                	addi	a5,a5,4
ffffffffc0201544:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201546:	fec79ce3          	bne	a5,a2,ffffffffc020153e <swap_init+0x27c>
ffffffffc020154a:	00010697          	auipc	a3,0x10
ffffffffc020154e:	ff668693          	addi	a3,a3,-10 # ffffffffc0211540 <check_ptep>
ffffffffc0201552:	00010817          	auipc	a6,0x10
ffffffffc0201556:	f4680813          	addi	a6,a6,-186 # ffffffffc0211498 <check_rp>
ffffffffc020155a:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc020155c:	00010c97          	auipc	s9,0x10
ffffffffc0201560:	f14c8c93          	addi	s9,s9,-236 # ffffffffc0211470 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201564:	00010d97          	auipc	s11,0x10
ffffffffc0201568:	034d8d93          	addi	s11,s11,52 # ffffffffc0211598 <pages>
ffffffffc020156c:	00005d17          	auipc	s10,0x5
ffffffffc0201570:	b4cd0d13          	addi	s10,s10,-1204 # ffffffffc02060b8 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201574:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0201576:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020157a:	4601                	li	a2,0
ffffffffc020157c:	85e2                	mv	a1,s8
ffffffffc020157e:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0201580:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201582:	5a0010ef          	jal	ra,ffffffffc0202b22 <get_pte>
ffffffffc0201586:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201588:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020158a:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020158c:	16050f63          	beqz	a0,ffffffffc020170a <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201590:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201592:	0017f613          	andi	a2,a5,1
ffffffffc0201596:	10060263          	beqz	a2,ffffffffc020169a <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc020159a:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020159e:	078a                	slli	a5,a5,0x2
ffffffffc02015a0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02015a2:	10c7f863          	bleu	a2,a5,ffffffffc02016b2 <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc02015a6:	000d3603          	ld	a2,0(s10)
ffffffffc02015aa:	000db583          	ld	a1,0(s11)
ffffffffc02015ae:	00083503          	ld	a0,0(a6)
ffffffffc02015b2:	8f91                	sub	a5,a5,a2
ffffffffc02015b4:	00379613          	slli	a2,a5,0x3
ffffffffc02015b8:	97b2                	add	a5,a5,a2
ffffffffc02015ba:	078e                	slli	a5,a5,0x3
ffffffffc02015bc:	97ae                	add	a5,a5,a1
ffffffffc02015be:	0af51e63          	bne	a0,a5,ffffffffc020167a <swap_init+0x3b8>
ffffffffc02015c2:	6785                	lui	a5,0x1
ffffffffc02015c4:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02015c6:	6795                	lui	a5,0x5
ffffffffc02015c8:	06a1                	addi	a3,a3,8
ffffffffc02015ca:	0821                	addi	a6,a6,8
ffffffffc02015cc:	fafc14e3          	bne	s8,a5,ffffffffc0201574 <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02015d0:	00004517          	auipc	a0,0x4
ffffffffc02015d4:	cc850513          	addi	a0,a0,-824 # ffffffffc0205298 <commands+0xe88>
ffffffffc02015d8:	ae7fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc02015dc:	00010797          	auipc	a5,0x10
ffffffffc02015e0:	e7c78793          	addi	a5,a5,-388 # ffffffffc0211458 <sm>
ffffffffc02015e4:	639c                	ld	a5,0(a5)
ffffffffc02015e6:	7f9c                	ld	a5,56(a5)
ffffffffc02015e8:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02015ea:	2a051c63          	bnez	a0,ffffffffc02018a2 <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02015ee:	000a3503          	ld	a0,0(s4)
ffffffffc02015f2:	4585                	li	a1,1
ffffffffc02015f4:	0a21                	addi	s4,s4,8
ffffffffc02015f6:	4a6010ef          	jal	ra,ffffffffc0202a9c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02015fa:	ff5a1ae3          	bne	s4,s5,ffffffffc02015ee <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc02015fe:	855e                	mv	a0,s7
ffffffffc0201600:	e7aff0ef          	jal	ra,ffffffffc0200c7a <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0201604:	77a2                	ld	a5,40(sp)
ffffffffc0201606:	00010717          	auipc	a4,0x10
ffffffffc020160a:	f6f72523          	sw	a5,-150(a4) # ffffffffc0211570 <free_area+0x10>
     free_list = free_list_store;
ffffffffc020160e:	7782                	ld	a5,32(sp)
ffffffffc0201610:	00010717          	auipc	a4,0x10
ffffffffc0201614:	f4f73823          	sd	a5,-176(a4) # ffffffffc0211560 <free_area>
ffffffffc0201618:	00010797          	auipc	a5,0x10
ffffffffc020161c:	f537b823          	sd	s3,-176(a5) # ffffffffc0211568 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201620:	00898a63          	beq	s3,s0,ffffffffc0201634 <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201624:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0201628:	0089b983          	ld	s3,8(s3)
ffffffffc020162c:	397d                	addiw	s2,s2,-1
ffffffffc020162e:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201630:	fe899ae3          	bne	s3,s0,ffffffffc0201624 <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0201634:	8626                	mv	a2,s1
ffffffffc0201636:	85ca                	mv	a1,s2
ffffffffc0201638:	00004517          	auipc	a0,0x4
ffffffffc020163c:	c9050513          	addi	a0,a0,-880 # ffffffffc02052c8 <commands+0xeb8>
ffffffffc0201640:	a7ffe0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0201644:	00004517          	auipc	a0,0x4
ffffffffc0201648:	ca450513          	addi	a0,a0,-860 # ffffffffc02052e8 <commands+0xed8>
ffffffffc020164c:	a73fe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0201650:	b1c9                	j	ffffffffc0201312 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0201652:	4481                	li	s1,0
ffffffffc0201654:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201656:	4981                	li	s3,0
ffffffffc0201658:	bb1d                	j	ffffffffc020138e <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020165a:	00004697          	auipc	a3,0x4
ffffffffc020165e:	a1668693          	addi	a3,a3,-1514 # ffffffffc0205070 <commands+0xc60>
ffffffffc0201662:	00003617          	auipc	a2,0x3
ffffffffc0201666:	60660613          	addi	a2,a2,1542 # ffffffffc0204c68 <commands+0x858>
ffffffffc020166a:	0ba00593          	li	a1,186
ffffffffc020166e:	00004517          	auipc	a0,0x4
ffffffffc0201672:	9da50513          	addi	a0,a0,-1574 # ffffffffc0205048 <commands+0xc38>
ffffffffc0201676:	a91fe0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020167a:	00004697          	auipc	a3,0x4
ffffffffc020167e:	bf668693          	addi	a3,a3,-1034 # ffffffffc0205270 <commands+0xe60>
ffffffffc0201682:	00003617          	auipc	a2,0x3
ffffffffc0201686:	5e660613          	addi	a2,a2,1510 # ffffffffc0204c68 <commands+0x858>
ffffffffc020168a:	0fa00593          	li	a1,250
ffffffffc020168e:	00004517          	auipc	a0,0x4
ffffffffc0201692:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0205048 <commands+0xc38>
ffffffffc0201696:	a71fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020169a:	00004617          	auipc	a2,0x4
ffffffffc020169e:	bae60613          	addi	a2,a2,-1106 # ffffffffc0205248 <commands+0xe38>
ffffffffc02016a2:	07000593          	li	a1,112
ffffffffc02016a6:	00004517          	auipc	a0,0x4
ffffffffc02016aa:	8da50513          	addi	a0,a0,-1830 # ffffffffc0204f80 <commands+0xb70>
ffffffffc02016ae:	a59fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02016b2:	00004617          	auipc	a2,0x4
ffffffffc02016b6:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0204f60 <commands+0xb50>
ffffffffc02016ba:	06500593          	li	a1,101
ffffffffc02016be:	00004517          	auipc	a0,0x4
ffffffffc02016c2:	8c250513          	addi	a0,a0,-1854 # ffffffffc0204f80 <commands+0xb70>
ffffffffc02016c6:	a41fe0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02016ca:	00004697          	auipc	a3,0x4
ffffffffc02016ce:	aa668693          	addi	a3,a3,-1370 # ffffffffc0205170 <commands+0xd60>
ffffffffc02016d2:	00003617          	auipc	a2,0x3
ffffffffc02016d6:	59660613          	addi	a2,a2,1430 # ffffffffc0204c68 <commands+0x858>
ffffffffc02016da:	0db00593          	li	a1,219
ffffffffc02016de:	00004517          	auipc	a0,0x4
ffffffffc02016e2:	96a50513          	addi	a0,a0,-1686 # ffffffffc0205048 <commands+0xc38>
ffffffffc02016e6:	a21fe0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02016ea:	00004697          	auipc	a3,0x4
ffffffffc02016ee:	a6e68693          	addi	a3,a3,-1426 # ffffffffc0205158 <commands+0xd48>
ffffffffc02016f2:	00003617          	auipc	a2,0x3
ffffffffc02016f6:	57660613          	addi	a2,a2,1398 # ffffffffc0204c68 <commands+0x858>
ffffffffc02016fa:	0da00593          	li	a1,218
ffffffffc02016fe:	00004517          	auipc	a0,0x4
ffffffffc0201702:	94a50513          	addi	a0,a0,-1718 # ffffffffc0205048 <commands+0xc38>
ffffffffc0201706:	a01fe0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020170a:	00004697          	auipc	a3,0x4
ffffffffc020170e:	b2668693          	addi	a3,a3,-1242 # ffffffffc0205230 <commands+0xe20>
ffffffffc0201712:	00003617          	auipc	a2,0x3
ffffffffc0201716:	55660613          	addi	a2,a2,1366 # ffffffffc0204c68 <commands+0x858>
ffffffffc020171a:	0f900593          	li	a1,249
ffffffffc020171e:	00004517          	auipc	a0,0x4
ffffffffc0201722:	92a50513          	addi	a0,a0,-1750 # ffffffffc0205048 <commands+0xc38>
ffffffffc0201726:	9e1fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020172a:	00004617          	auipc	a2,0x4
ffffffffc020172e:	8fe60613          	addi	a2,a2,-1794 # ffffffffc0205028 <commands+0xc18>
ffffffffc0201732:	02700593          	li	a1,39
ffffffffc0201736:	00004517          	auipc	a0,0x4
ffffffffc020173a:	91250513          	addi	a0,a0,-1774 # ffffffffc0205048 <commands+0xc38>
ffffffffc020173e:	9c9fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc0201742:	00004697          	auipc	a3,0x4
ffffffffc0201746:	aae68693          	addi	a3,a3,-1362 # ffffffffc02051f0 <commands+0xde0>
ffffffffc020174a:	00003617          	auipc	a2,0x3
ffffffffc020174e:	51e60613          	addi	a2,a2,1310 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201752:	09500593          	li	a1,149
ffffffffc0201756:	00004517          	auipc	a0,0x4
ffffffffc020175a:	8f250513          	addi	a0,a0,-1806 # ffffffffc0205048 <commands+0xc38>
ffffffffc020175e:	9a9fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc0201762:	00004697          	auipc	a3,0x4
ffffffffc0201766:	a8e68693          	addi	a3,a3,-1394 # ffffffffc02051f0 <commands+0xde0>
ffffffffc020176a:	00003617          	auipc	a2,0x3
ffffffffc020176e:	4fe60613          	addi	a2,a2,1278 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201772:	09700593          	li	a1,151
ffffffffc0201776:	00004517          	auipc	a0,0x4
ffffffffc020177a:	8d250513          	addi	a0,a0,-1838 # ffffffffc0205048 <commands+0xc38>
ffffffffc020177e:	989fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc0201782:	00004697          	auipc	a3,0x4
ffffffffc0201786:	a7e68693          	addi	a3,a3,-1410 # ffffffffc0205200 <commands+0xdf0>
ffffffffc020178a:	00003617          	auipc	a2,0x3
ffffffffc020178e:	4de60613          	addi	a2,a2,1246 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201792:	09900593          	li	a1,153
ffffffffc0201796:	00004517          	auipc	a0,0x4
ffffffffc020179a:	8b250513          	addi	a0,a0,-1870 # ffffffffc0205048 <commands+0xc38>
ffffffffc020179e:	969fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc02017a2:	00004697          	auipc	a3,0x4
ffffffffc02017a6:	a5e68693          	addi	a3,a3,-1442 # ffffffffc0205200 <commands+0xdf0>
ffffffffc02017aa:	00003617          	auipc	a2,0x3
ffffffffc02017ae:	4be60613          	addi	a2,a2,1214 # ffffffffc0204c68 <commands+0x858>
ffffffffc02017b2:	09b00593          	li	a1,155
ffffffffc02017b6:	00004517          	auipc	a0,0x4
ffffffffc02017ba:	89250513          	addi	a0,a0,-1902 # ffffffffc0205048 <commands+0xc38>
ffffffffc02017be:	949fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc02017c2:	00004697          	auipc	a3,0x4
ffffffffc02017c6:	a1e68693          	addi	a3,a3,-1506 # ffffffffc02051e0 <commands+0xdd0>
ffffffffc02017ca:	00003617          	auipc	a2,0x3
ffffffffc02017ce:	49e60613          	addi	a2,a2,1182 # ffffffffc0204c68 <commands+0x858>
ffffffffc02017d2:	09100593          	li	a1,145
ffffffffc02017d6:	00004517          	auipc	a0,0x4
ffffffffc02017da:	87250513          	addi	a0,a0,-1934 # ffffffffc0205048 <commands+0xc38>
ffffffffc02017de:	929fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc02017e2:	00004697          	auipc	a3,0x4
ffffffffc02017e6:	9fe68693          	addi	a3,a3,-1538 # ffffffffc02051e0 <commands+0xdd0>
ffffffffc02017ea:	00003617          	auipc	a2,0x3
ffffffffc02017ee:	47e60613          	addi	a2,a2,1150 # ffffffffc0204c68 <commands+0x858>
ffffffffc02017f2:	09300593          	li	a1,147
ffffffffc02017f6:	00004517          	auipc	a0,0x4
ffffffffc02017fa:	85250513          	addi	a0,a0,-1966 # ffffffffc0205048 <commands+0xc38>
ffffffffc02017fe:	909fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201802:	00004697          	auipc	a3,0x4
ffffffffc0201806:	98e68693          	addi	a3,a3,-1650 # ffffffffc0205190 <commands+0xd80>
ffffffffc020180a:	00003617          	auipc	a2,0x3
ffffffffc020180e:	45e60613          	addi	a2,a2,1118 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201812:	0e800593          	li	a1,232
ffffffffc0201816:	00004517          	auipc	a0,0x4
ffffffffc020181a:	83250513          	addi	a0,a0,-1998 # ffffffffc0205048 <commands+0xc38>
ffffffffc020181e:	8e9fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201822:	00004697          	auipc	a3,0x4
ffffffffc0201826:	8f668693          	addi	a3,a3,-1802 # ffffffffc0205118 <commands+0xd08>
ffffffffc020182a:	00003617          	auipc	a2,0x3
ffffffffc020182e:	43e60613          	addi	a2,a2,1086 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201832:	0d500593          	li	a1,213
ffffffffc0201836:	00004517          	auipc	a0,0x4
ffffffffc020183a:	81250513          	addi	a0,a0,-2030 # ffffffffc0205048 <commands+0xc38>
ffffffffc020183e:	8c9fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0201842:	00004697          	auipc	a3,0x4
ffffffffc0201846:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0205210 <commands+0xe00>
ffffffffc020184a:	00003617          	auipc	a2,0x3
ffffffffc020184e:	41e60613          	addi	a2,a2,1054 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201852:	09d00593          	li	a1,157
ffffffffc0201856:	00003517          	auipc	a0,0x3
ffffffffc020185a:	7f250513          	addi	a0,a0,2034 # ffffffffc0205048 <commands+0xc38>
ffffffffc020185e:	8a9fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0201862:	00004697          	auipc	a3,0x4
ffffffffc0201866:	9ae68693          	addi	a3,a3,-1618 # ffffffffc0205210 <commands+0xe00>
ffffffffc020186a:	00003617          	auipc	a2,0x3
ffffffffc020186e:	3fe60613          	addi	a2,a2,1022 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201872:	09f00593          	li	a1,159
ffffffffc0201876:	00003517          	auipc	a0,0x3
ffffffffc020187a:	7d250513          	addi	a0,a0,2002 # ffffffffc0205048 <commands+0xc38>
ffffffffc020187e:	889fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert( nr_free == 0);         
ffffffffc0201882:	00004697          	auipc	a3,0x4
ffffffffc0201886:	99e68693          	addi	a3,a3,-1634 # ffffffffc0205220 <commands+0xe10>
ffffffffc020188a:	00003617          	auipc	a2,0x3
ffffffffc020188e:	3de60613          	addi	a2,a2,990 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201892:	0f100593          	li	a1,241
ffffffffc0201896:	00003517          	auipc	a0,0x3
ffffffffc020189a:	7b250513          	addi	a0,a0,1970 # ffffffffc0205048 <commands+0xc38>
ffffffffc020189e:	869fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(ret==0);
ffffffffc02018a2:	00004697          	auipc	a3,0x4
ffffffffc02018a6:	a1e68693          	addi	a3,a3,-1506 # ffffffffc02052c0 <commands+0xeb0>
ffffffffc02018aa:	00003617          	auipc	a2,0x3
ffffffffc02018ae:	3be60613          	addi	a2,a2,958 # ffffffffc0204c68 <commands+0x858>
ffffffffc02018b2:	10000593          	li	a1,256
ffffffffc02018b6:	00003517          	auipc	a0,0x3
ffffffffc02018ba:	79250513          	addi	a0,a0,1938 # ffffffffc0205048 <commands+0xc38>
ffffffffc02018be:	849fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(mm != NULL);
ffffffffc02018c2:	00003697          	auipc	a3,0x3
ffffffffc02018c6:	4ae68693          	addi	a3,a3,1198 # ffffffffc0204d70 <commands+0x960>
ffffffffc02018ca:	00003617          	auipc	a2,0x3
ffffffffc02018ce:	39e60613          	addi	a2,a2,926 # ffffffffc0204c68 <commands+0x858>
ffffffffc02018d2:	0c200593          	li	a1,194
ffffffffc02018d6:	00003517          	auipc	a0,0x3
ffffffffc02018da:	77250513          	addi	a0,a0,1906 # ffffffffc0205048 <commands+0xc38>
ffffffffc02018de:	829fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc02018e2:	00003697          	auipc	a3,0x3
ffffffffc02018e6:	7e668693          	addi	a3,a3,2022 # ffffffffc02050c8 <commands+0xcb8>
ffffffffc02018ea:	00003617          	auipc	a2,0x3
ffffffffc02018ee:	37e60613          	addi	a2,a2,894 # ffffffffc0204c68 <commands+0x858>
ffffffffc02018f2:	0c500593          	li	a1,197
ffffffffc02018f6:	00003517          	auipc	a0,0x3
ffffffffc02018fa:	75250513          	addi	a0,a0,1874 # ffffffffc0205048 <commands+0xc38>
ffffffffc02018fe:	809fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201902:	00003697          	auipc	a3,0x3
ffffffffc0201906:	61e68693          	addi	a3,a3,1566 # ffffffffc0204f20 <commands+0xb10>
ffffffffc020190a:	00003617          	auipc	a2,0x3
ffffffffc020190e:	35e60613          	addi	a2,a2,862 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201912:	0ca00593          	li	a1,202
ffffffffc0201916:	00003517          	auipc	a0,0x3
ffffffffc020191a:	73250513          	addi	a0,a0,1842 # ffffffffc0205048 <commands+0xc38>
ffffffffc020191e:	fe8fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(vma != NULL);
ffffffffc0201922:	00003697          	auipc	a3,0x3
ffffffffc0201926:	6a668693          	addi	a3,a3,1702 # ffffffffc0204fc8 <commands+0xbb8>
ffffffffc020192a:	00003617          	auipc	a2,0x3
ffffffffc020192e:	33e60613          	addi	a2,a2,830 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201932:	0cd00593          	li	a1,205
ffffffffc0201936:	00003517          	auipc	a0,0x3
ffffffffc020193a:	71250513          	addi	a0,a0,1810 # ffffffffc0205048 <commands+0xc38>
ffffffffc020193e:	fc8fe0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201942:	00003697          	auipc	a3,0x3
ffffffffc0201946:	73e68693          	addi	a3,a3,1854 # ffffffffc0205080 <commands+0xc70>
ffffffffc020194a:	00003617          	auipc	a2,0x3
ffffffffc020194e:	31e60613          	addi	a2,a2,798 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201952:	0bd00593          	li	a1,189
ffffffffc0201956:	00003517          	auipc	a0,0x3
ffffffffc020195a:	6f250513          	addi	a0,a0,1778 # ffffffffc0205048 <commands+0xc38>
ffffffffc020195e:	fa8fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201962 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0201962:	00010797          	auipc	a5,0x10
ffffffffc0201966:	af678793          	addi	a5,a5,-1290 # ffffffffc0211458 <sm>
ffffffffc020196a:	639c                	ld	a5,0(a5)
ffffffffc020196c:	0107b303          	ld	t1,16(a5)
ffffffffc0201970:	8302                	jr	t1

ffffffffc0201972 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0201972:	00010797          	auipc	a5,0x10
ffffffffc0201976:	ae678793          	addi	a5,a5,-1306 # ffffffffc0211458 <sm>
ffffffffc020197a:	639c                	ld	a5,0(a5)
ffffffffc020197c:	0207b303          	ld	t1,32(a5)
ffffffffc0201980:	8302                	jr	t1

ffffffffc0201982 <swap_out>:
{
ffffffffc0201982:	711d                	addi	sp,sp,-96
ffffffffc0201984:	ec86                	sd	ra,88(sp)
ffffffffc0201986:	e8a2                	sd	s0,80(sp)
ffffffffc0201988:	e4a6                	sd	s1,72(sp)
ffffffffc020198a:	e0ca                	sd	s2,64(sp)
ffffffffc020198c:	fc4e                	sd	s3,56(sp)
ffffffffc020198e:	f852                	sd	s4,48(sp)
ffffffffc0201990:	f456                	sd	s5,40(sp)
ffffffffc0201992:	f05a                	sd	s6,32(sp)
ffffffffc0201994:	ec5e                	sd	s7,24(sp)
ffffffffc0201996:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0201998:	cde9                	beqz	a1,ffffffffc0201a72 <swap_out+0xf0>
ffffffffc020199a:	8ab2                	mv	s5,a2
ffffffffc020199c:	892a                	mv	s2,a0
ffffffffc020199e:	8a2e                	mv	s4,a1
ffffffffc02019a0:	4401                	li	s0,0
ffffffffc02019a2:	00010997          	auipc	s3,0x10
ffffffffc02019a6:	ab698993          	addi	s3,s3,-1354 # ffffffffc0211458 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019aa:	00004b17          	auipc	s6,0x4
ffffffffc02019ae:	9beb0b13          	addi	s6,s6,-1602 # ffffffffc0205368 <commands+0xf58>
                    cprintf("SWAP: failed to save\n");
ffffffffc02019b2:	00004b97          	auipc	s7,0x4
ffffffffc02019b6:	99eb8b93          	addi	s7,s7,-1634 # ffffffffc0205350 <commands+0xf40>
ffffffffc02019ba:	a825                	j	ffffffffc02019f2 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019bc:	67a2                	ld	a5,8(sp)
ffffffffc02019be:	8626                	mv	a2,s1
ffffffffc02019c0:	85a2                	mv	a1,s0
ffffffffc02019c2:	63b4                	ld	a3,64(a5)
ffffffffc02019c4:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02019c6:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019c8:	82b1                	srli	a3,a3,0xc
ffffffffc02019ca:	0685                	addi	a3,a3,1
ffffffffc02019cc:	ef2fe0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02019d0:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02019d2:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02019d4:	613c                	ld	a5,64(a0)
ffffffffc02019d6:	83b1                	srli	a5,a5,0xc
ffffffffc02019d8:	0785                	addi	a5,a5,1
ffffffffc02019da:	07a2                	slli	a5,a5,0x8
ffffffffc02019dc:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc02019e0:	0bc010ef          	jal	ra,ffffffffc0202a9c <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc02019e4:	01893503          	ld	a0,24(s2)
ffffffffc02019e8:	85a6                	mv	a1,s1
ffffffffc02019ea:	7bf010ef          	jal	ra,ffffffffc02039a8 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc02019ee:	048a0d63          	beq	s4,s0,ffffffffc0201a48 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);//r=0表示成功找到了可以换出去的页面
ffffffffc02019f2:	0009b783          	ld	a5,0(s3)
ffffffffc02019f6:	8656                	mv	a2,s5
ffffffffc02019f8:	002c                	addi	a1,sp,8
ffffffffc02019fa:	7b9c                	ld	a5,48(a5)
ffffffffc02019fc:	854a                	mv	a0,s2
ffffffffc02019fe:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201a00:	e12d                	bnez	a0,ffffffffc0201a62 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201a02:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a04:	01893503          	ld	a0,24(s2)
ffffffffc0201a08:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201a0a:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a0c:	85a6                	mv	a1,s1
ffffffffc0201a0e:	114010ef          	jal	ra,ffffffffc0202b22 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a12:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a14:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a16:	8b85                	andi	a5,a5,1
ffffffffc0201a18:	cfb9                	beqz	a5,ffffffffc0201a76 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201a1a:	65a2                	ld	a1,8(sp)
ffffffffc0201a1c:	61bc                	ld	a5,64(a1)
ffffffffc0201a1e:	83b1                	srli	a5,a5,0xc
ffffffffc0201a20:	00178513          	addi	a0,a5,1
ffffffffc0201a24:	0522                	slli	a0,a0,0x8
ffffffffc0201a26:	27a020ef          	jal	ra,ffffffffc0203ca0 <swapfs_write>
ffffffffc0201a2a:	d949                	beqz	a0,ffffffffc02019bc <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201a2c:	855e                	mv	a0,s7
ffffffffc0201a2e:	e90fe0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a32:	0009b783          	ld	a5,0(s3)
ffffffffc0201a36:	6622                	ld	a2,8(sp)
ffffffffc0201a38:	4681                	li	a3,0
ffffffffc0201a3a:	739c                	ld	a5,32(a5)
ffffffffc0201a3c:	85a6                	mv	a1,s1
ffffffffc0201a3e:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201a40:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a42:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201a44:	fa8a17e3          	bne	s4,s0,ffffffffc02019f2 <swap_out+0x70>
}
ffffffffc0201a48:	8522                	mv	a0,s0
ffffffffc0201a4a:	60e6                	ld	ra,88(sp)
ffffffffc0201a4c:	6446                	ld	s0,80(sp)
ffffffffc0201a4e:	64a6                	ld	s1,72(sp)
ffffffffc0201a50:	6906                	ld	s2,64(sp)
ffffffffc0201a52:	79e2                	ld	s3,56(sp)
ffffffffc0201a54:	7a42                	ld	s4,48(sp)
ffffffffc0201a56:	7aa2                	ld	s5,40(sp)
ffffffffc0201a58:	7b02                	ld	s6,32(sp)
ffffffffc0201a5a:	6be2                	ld	s7,24(sp)
ffffffffc0201a5c:	6c42                	ld	s8,16(sp)
ffffffffc0201a5e:	6125                	addi	sp,sp,96
ffffffffc0201a60:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201a62:	85a2                	mv	a1,s0
ffffffffc0201a64:	00004517          	auipc	a0,0x4
ffffffffc0201a68:	8a450513          	addi	a0,a0,-1884 # ffffffffc0205308 <commands+0xef8>
ffffffffc0201a6c:	e52fe0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0201a70:	bfe1                	j	ffffffffc0201a48 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201a72:	4401                	li	s0,0
ffffffffc0201a74:	bfd1                	j	ffffffffc0201a48 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a76:	00004697          	auipc	a3,0x4
ffffffffc0201a7a:	8c268693          	addi	a3,a3,-1854 # ffffffffc0205338 <commands+0xf28>
ffffffffc0201a7e:	00003617          	auipc	a2,0x3
ffffffffc0201a82:	1ea60613          	addi	a2,a2,490 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201a86:	06600593          	li	a1,102
ffffffffc0201a8a:	00003517          	auipc	a0,0x3
ffffffffc0201a8e:	5be50513          	addi	a0,a0,1470 # ffffffffc0205048 <commands+0xc38>
ffffffffc0201a92:	e74fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201a96 <swap_in>:
{
ffffffffc0201a96:	7179                	addi	sp,sp,-48
ffffffffc0201a98:	e84a                	sd	s2,16(sp)
ffffffffc0201a9a:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0201a9c:	4505                	li	a0,1
{
ffffffffc0201a9e:	ec26                	sd	s1,24(sp)
ffffffffc0201aa0:	e44e                	sd	s3,8(sp)
ffffffffc0201aa2:	f406                	sd	ra,40(sp)
ffffffffc0201aa4:	f022                	sd	s0,32(sp)
ffffffffc0201aa6:	84ae                	mv	s1,a1
ffffffffc0201aa8:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0201aaa:	76b000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
     assert(result!=NULL);
ffffffffc0201aae:	c129                	beqz	a0,ffffffffc0201af0 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0201ab0:	842a                	mv	s0,a0
ffffffffc0201ab2:	01893503          	ld	a0,24(s2)
ffffffffc0201ab6:	4601                	li	a2,0
ffffffffc0201ab8:	85a6                	mv	a1,s1
ffffffffc0201aba:	068010ef          	jal	ra,ffffffffc0202b22 <get_pte>
ffffffffc0201abe:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0201ac0:	6108                	ld	a0,0(a0)
ffffffffc0201ac2:	85a2                	mv	a1,s0
ffffffffc0201ac4:	136020ef          	jal	ra,ffffffffc0203bfa <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0201ac8:	00093583          	ld	a1,0(s2)
ffffffffc0201acc:	8626                	mv	a2,s1
ffffffffc0201ace:	00003517          	auipc	a0,0x3
ffffffffc0201ad2:	51a50513          	addi	a0,a0,1306 # ffffffffc0204fe8 <commands+0xbd8>
ffffffffc0201ad6:	81a1                	srli	a1,a1,0x8
ffffffffc0201ad8:	de6fe0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0201adc:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0201ade:	0089b023          	sd	s0,0(s3)
}
ffffffffc0201ae2:	7402                	ld	s0,32(sp)
ffffffffc0201ae4:	64e2                	ld	s1,24(sp)
ffffffffc0201ae6:	6942                	ld	s2,16(sp)
ffffffffc0201ae8:	69a2                	ld	s3,8(sp)
ffffffffc0201aea:	4501                	li	a0,0
ffffffffc0201aec:	6145                	addi	sp,sp,48
ffffffffc0201aee:	8082                	ret
     assert(result!=NULL);
ffffffffc0201af0:	00003697          	auipc	a3,0x3
ffffffffc0201af4:	4e868693          	addi	a3,a3,1256 # ffffffffc0204fd8 <commands+0xbc8>
ffffffffc0201af8:	00003617          	auipc	a2,0x3
ffffffffc0201afc:	17060613          	addi	a2,a2,368 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201b00:	07c00593          	li	a1,124
ffffffffc0201b04:	00003517          	auipc	a0,0x3
ffffffffc0201b08:	54450513          	addi	a0,a0,1348 # ffffffffc0205048 <commands+0xc38>
ffffffffc0201b0c:	dfafe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201b10 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201b10:	00010797          	auipc	a5,0x10
ffffffffc0201b14:	a5078793          	addi	a5,a5,-1456 # ffffffffc0211560 <free_area>
ffffffffc0201b18:	e79c                	sd	a5,8(a5)
ffffffffc0201b1a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201b1c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201b20:	8082                	ret

ffffffffc0201b22 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201b22:	00010517          	auipc	a0,0x10
ffffffffc0201b26:	a4e56503          	lwu	a0,-1458(a0) # ffffffffc0211570 <free_area+0x10>
ffffffffc0201b2a:	8082                	ret

ffffffffc0201b2c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201b2c:	715d                	addi	sp,sp,-80
ffffffffc0201b2e:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0201b30:	00010917          	auipc	s2,0x10
ffffffffc0201b34:	a3090913          	addi	s2,s2,-1488 # ffffffffc0211560 <free_area>
ffffffffc0201b38:	00893783          	ld	a5,8(s2)
ffffffffc0201b3c:	e486                	sd	ra,72(sp)
ffffffffc0201b3e:	e0a2                	sd	s0,64(sp)
ffffffffc0201b40:	fc26                	sd	s1,56(sp)
ffffffffc0201b42:	f44e                	sd	s3,40(sp)
ffffffffc0201b44:	f052                	sd	s4,32(sp)
ffffffffc0201b46:	ec56                	sd	s5,24(sp)
ffffffffc0201b48:	e85a                	sd	s6,16(sp)
ffffffffc0201b4a:	e45e                	sd	s7,8(sp)
ffffffffc0201b4c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201b4e:	31278f63          	beq	a5,s2,ffffffffc0201e6c <default_check+0x340>
ffffffffc0201b52:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201b56:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201b58:	8b05                	andi	a4,a4,1
ffffffffc0201b5a:	30070d63          	beqz	a4,ffffffffc0201e74 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0201b5e:	4401                	li	s0,0
ffffffffc0201b60:	4481                	li	s1,0
ffffffffc0201b62:	a031                	j	ffffffffc0201b6e <default_check+0x42>
ffffffffc0201b64:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0201b68:	8b09                	andi	a4,a4,2
ffffffffc0201b6a:	30070563          	beqz	a4,ffffffffc0201e74 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0201b6e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201b72:	679c                	ld	a5,8(a5)
ffffffffc0201b74:	2485                	addiw	s1,s1,1
ffffffffc0201b76:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201b78:	ff2796e3          	bne	a5,s2,ffffffffc0201b64 <default_check+0x38>
ffffffffc0201b7c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0201b7e:	765000ef          	jal	ra,ffffffffc0202ae2 <nr_free_pages>
ffffffffc0201b82:	75351963          	bne	a0,s3,ffffffffc02022d4 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201b86:	4505                	li	a0,1
ffffffffc0201b88:	68d000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201b8c:	8a2a                	mv	s4,a0
ffffffffc0201b8e:	48050363          	beqz	a0,ffffffffc0202014 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201b92:	4505                	li	a0,1
ffffffffc0201b94:	681000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201b98:	89aa                	mv	s3,a0
ffffffffc0201b9a:	74050d63          	beqz	a0,ffffffffc02022f4 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201b9e:	4505                	li	a0,1
ffffffffc0201ba0:	675000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201ba4:	8aaa                	mv	s5,a0
ffffffffc0201ba6:	4e050763          	beqz	a0,ffffffffc0202094 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201baa:	2f3a0563          	beq	s4,s3,ffffffffc0201e94 <default_check+0x368>
ffffffffc0201bae:	2eaa0363          	beq	s4,a0,ffffffffc0201e94 <default_check+0x368>
ffffffffc0201bb2:	2ea98163          	beq	s3,a0,ffffffffc0201e94 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201bb6:	000a2783          	lw	a5,0(s4)
ffffffffc0201bba:	2e079d63          	bnez	a5,ffffffffc0201eb4 <default_check+0x388>
ffffffffc0201bbe:	0009a783          	lw	a5,0(s3)
ffffffffc0201bc2:	2e079963          	bnez	a5,ffffffffc0201eb4 <default_check+0x388>
ffffffffc0201bc6:	411c                	lw	a5,0(a0)
ffffffffc0201bc8:	2e079663          	bnez	a5,ffffffffc0201eb4 <default_check+0x388>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201bcc:	00010797          	auipc	a5,0x10
ffffffffc0201bd0:	9cc78793          	addi	a5,a5,-1588 # ffffffffc0211598 <pages>
ffffffffc0201bd4:	639c                	ld	a5,0(a5)
ffffffffc0201bd6:	00003717          	auipc	a4,0x3
ffffffffc0201bda:	7d270713          	addi	a4,a4,2002 # ffffffffc02053a8 <commands+0xf98>
ffffffffc0201bde:	630c                	ld	a1,0(a4)
ffffffffc0201be0:	40fa0733          	sub	a4,s4,a5
ffffffffc0201be4:	870d                	srai	a4,a4,0x3
ffffffffc0201be6:	02b70733          	mul	a4,a4,a1
ffffffffc0201bea:	00004697          	auipc	a3,0x4
ffffffffc0201bee:	4ce68693          	addi	a3,a3,1230 # ffffffffc02060b8 <nbase>
ffffffffc0201bf2:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201bf4:	00010697          	auipc	a3,0x10
ffffffffc0201bf8:	87c68693          	addi	a3,a3,-1924 # ffffffffc0211470 <npage>
ffffffffc0201bfc:	6294                	ld	a3,0(a3)
ffffffffc0201bfe:	06b2                	slli	a3,a3,0xc
ffffffffc0201c00:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c02:	0732                	slli	a4,a4,0xc
ffffffffc0201c04:	2cd77863          	bleu	a3,a4,ffffffffc0201ed4 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c08:	40f98733          	sub	a4,s3,a5
ffffffffc0201c0c:	870d                	srai	a4,a4,0x3
ffffffffc0201c0e:	02b70733          	mul	a4,a4,a1
ffffffffc0201c12:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c14:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201c16:	4ed77f63          	bleu	a3,a4,ffffffffc0202114 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c1a:	40f507b3          	sub	a5,a0,a5
ffffffffc0201c1e:	878d                	srai	a5,a5,0x3
ffffffffc0201c20:	02b787b3          	mul	a5,a5,a1
ffffffffc0201c24:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c26:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201c28:	34d7f663          	bleu	a3,a5,ffffffffc0201f74 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0201c2c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201c2e:	00093c03          	ld	s8,0(s2)
ffffffffc0201c32:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0201c36:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0201c3a:	00010797          	auipc	a5,0x10
ffffffffc0201c3e:	9327b723          	sd	s2,-1746(a5) # ffffffffc0211568 <free_area+0x8>
ffffffffc0201c42:	00010797          	auipc	a5,0x10
ffffffffc0201c46:	9127bf23          	sd	s2,-1762(a5) # ffffffffc0211560 <free_area>
    nr_free = 0;
ffffffffc0201c4a:	00010797          	auipc	a5,0x10
ffffffffc0201c4e:	9207a323          	sw	zero,-1754(a5) # ffffffffc0211570 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201c52:	5c3000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201c56:	2e051f63          	bnez	a0,ffffffffc0201f54 <default_check+0x428>
    free_page(p0);
ffffffffc0201c5a:	4585                	li	a1,1
ffffffffc0201c5c:	8552                	mv	a0,s4
ffffffffc0201c5e:	63f000ef          	jal	ra,ffffffffc0202a9c <free_pages>
    free_page(p1);
ffffffffc0201c62:	4585                	li	a1,1
ffffffffc0201c64:	854e                	mv	a0,s3
ffffffffc0201c66:	637000ef          	jal	ra,ffffffffc0202a9c <free_pages>
    free_page(p2);
ffffffffc0201c6a:	4585                	li	a1,1
ffffffffc0201c6c:	8556                	mv	a0,s5
ffffffffc0201c6e:	62f000ef          	jal	ra,ffffffffc0202a9c <free_pages>
    assert(nr_free == 3);
ffffffffc0201c72:	01092703          	lw	a4,16(s2)
ffffffffc0201c76:	478d                	li	a5,3
ffffffffc0201c78:	2af71e63          	bne	a4,a5,ffffffffc0201f34 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201c7c:	4505                	li	a0,1
ffffffffc0201c7e:	597000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201c82:	89aa                	mv	s3,a0
ffffffffc0201c84:	28050863          	beqz	a0,ffffffffc0201f14 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201c88:	4505                	li	a0,1
ffffffffc0201c8a:	58b000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201c8e:	8aaa                	mv	s5,a0
ffffffffc0201c90:	3e050263          	beqz	a0,ffffffffc0202074 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201c94:	4505                	li	a0,1
ffffffffc0201c96:	57f000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201c9a:	8a2a                	mv	s4,a0
ffffffffc0201c9c:	3a050c63          	beqz	a0,ffffffffc0202054 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0201ca0:	4505                	li	a0,1
ffffffffc0201ca2:	573000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201ca6:	38051763          	bnez	a0,ffffffffc0202034 <default_check+0x508>
    free_page(p0);
ffffffffc0201caa:	4585                	li	a1,1
ffffffffc0201cac:	854e                	mv	a0,s3
ffffffffc0201cae:	5ef000ef          	jal	ra,ffffffffc0202a9c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201cb2:	00893783          	ld	a5,8(s2)
ffffffffc0201cb6:	23278f63          	beq	a5,s2,ffffffffc0201ef4 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0201cba:	4505                	li	a0,1
ffffffffc0201cbc:	559000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201cc0:	32a99a63          	bne	s3,a0,ffffffffc0201ff4 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0201cc4:	4505                	li	a0,1
ffffffffc0201cc6:	54f000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201cca:	30051563          	bnez	a0,ffffffffc0201fd4 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0201cce:	01092783          	lw	a5,16(s2)
ffffffffc0201cd2:	2e079163          	bnez	a5,ffffffffc0201fb4 <default_check+0x488>
    free_page(p);
ffffffffc0201cd6:	854e                	mv	a0,s3
ffffffffc0201cd8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201cda:	00010797          	auipc	a5,0x10
ffffffffc0201cde:	8987b323          	sd	s8,-1914(a5) # ffffffffc0211560 <free_area>
ffffffffc0201ce2:	00010797          	auipc	a5,0x10
ffffffffc0201ce6:	8977b323          	sd	s7,-1914(a5) # ffffffffc0211568 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0201cea:	00010797          	auipc	a5,0x10
ffffffffc0201cee:	8967a323          	sw	s6,-1914(a5) # ffffffffc0211570 <free_area+0x10>
    free_page(p);
ffffffffc0201cf2:	5ab000ef          	jal	ra,ffffffffc0202a9c <free_pages>
    free_page(p1);
ffffffffc0201cf6:	4585                	li	a1,1
ffffffffc0201cf8:	8556                	mv	a0,s5
ffffffffc0201cfa:	5a3000ef          	jal	ra,ffffffffc0202a9c <free_pages>
    free_page(p2);
ffffffffc0201cfe:	4585                	li	a1,1
ffffffffc0201d00:	8552                	mv	a0,s4
ffffffffc0201d02:	59b000ef          	jal	ra,ffffffffc0202a9c <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201d06:	4515                	li	a0,5
ffffffffc0201d08:	50d000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201d0c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201d0e:	28050363          	beqz	a0,ffffffffc0201f94 <default_check+0x468>
ffffffffc0201d12:	651c                	ld	a5,8(a0)
ffffffffc0201d14:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0201d16:	8b85                	andi	a5,a5,1
ffffffffc0201d18:	54079e63          	bnez	a5,ffffffffc0202274 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201d1c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201d1e:	00093b03          	ld	s6,0(s2)
ffffffffc0201d22:	00893a83          	ld	s5,8(s2)
ffffffffc0201d26:	00010797          	auipc	a5,0x10
ffffffffc0201d2a:	8327bd23          	sd	s2,-1990(a5) # ffffffffc0211560 <free_area>
ffffffffc0201d2e:	00010797          	auipc	a5,0x10
ffffffffc0201d32:	8327bd23          	sd	s2,-1990(a5) # ffffffffc0211568 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0201d36:	4df000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201d3a:	50051d63          	bnez	a0,ffffffffc0202254 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201d3e:	09098a13          	addi	s4,s3,144
ffffffffc0201d42:	8552                	mv	a0,s4
ffffffffc0201d44:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201d46:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0201d4a:	00010797          	auipc	a5,0x10
ffffffffc0201d4e:	8207a323          	sw	zero,-2010(a5) # ffffffffc0211570 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201d52:	54b000ef          	jal	ra,ffffffffc0202a9c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201d56:	4511                	li	a0,4
ffffffffc0201d58:	4bd000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201d5c:	4c051c63          	bnez	a0,ffffffffc0202234 <default_check+0x708>
ffffffffc0201d60:	0989b783          	ld	a5,152(s3)
ffffffffc0201d64:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201d66:	8b85                	andi	a5,a5,1
ffffffffc0201d68:	4a078663          	beqz	a5,ffffffffc0202214 <default_check+0x6e8>
ffffffffc0201d6c:	0a89a703          	lw	a4,168(s3)
ffffffffc0201d70:	478d                	li	a5,3
ffffffffc0201d72:	4af71163          	bne	a4,a5,ffffffffc0202214 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201d76:	450d                	li	a0,3
ffffffffc0201d78:	49d000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201d7c:	8c2a                	mv	s8,a0
ffffffffc0201d7e:	46050b63          	beqz	a0,ffffffffc02021f4 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0201d82:	4505                	li	a0,1
ffffffffc0201d84:	491000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201d88:	44051663          	bnez	a0,ffffffffc02021d4 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0201d8c:	438a1463          	bne	s4,s8,ffffffffc02021b4 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201d90:	4585                	li	a1,1
ffffffffc0201d92:	854e                	mv	a0,s3
ffffffffc0201d94:	509000ef          	jal	ra,ffffffffc0202a9c <free_pages>
    free_pages(p1, 3);
ffffffffc0201d98:	458d                	li	a1,3
ffffffffc0201d9a:	8552                	mv	a0,s4
ffffffffc0201d9c:	501000ef          	jal	ra,ffffffffc0202a9c <free_pages>
ffffffffc0201da0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201da4:	04898c13          	addi	s8,s3,72
ffffffffc0201da8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201daa:	8b85                	andi	a5,a5,1
ffffffffc0201dac:	3e078463          	beqz	a5,ffffffffc0202194 <default_check+0x668>
ffffffffc0201db0:	0189a703          	lw	a4,24(s3)
ffffffffc0201db4:	4785                	li	a5,1
ffffffffc0201db6:	3cf71f63          	bne	a4,a5,ffffffffc0202194 <default_check+0x668>
ffffffffc0201dba:	008a3783          	ld	a5,8(s4)
ffffffffc0201dbe:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201dc0:	8b85                	andi	a5,a5,1
ffffffffc0201dc2:	3a078963          	beqz	a5,ffffffffc0202174 <default_check+0x648>
ffffffffc0201dc6:	018a2703          	lw	a4,24(s4)
ffffffffc0201dca:	478d                	li	a5,3
ffffffffc0201dcc:	3af71463          	bne	a4,a5,ffffffffc0202174 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201dd0:	4505                	li	a0,1
ffffffffc0201dd2:	443000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201dd6:	36a99f63          	bne	s3,a0,ffffffffc0202154 <default_check+0x628>
    free_page(p0);
ffffffffc0201dda:	4585                	li	a1,1
ffffffffc0201ddc:	4c1000ef          	jal	ra,ffffffffc0202a9c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201de0:	4509                	li	a0,2
ffffffffc0201de2:	433000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201de6:	34aa1763          	bne	s4,a0,ffffffffc0202134 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0201dea:	4589                	li	a1,2
ffffffffc0201dec:	4b1000ef          	jal	ra,ffffffffc0202a9c <free_pages>
    free_page(p2);
ffffffffc0201df0:	4585                	li	a1,1
ffffffffc0201df2:	8562                	mv	a0,s8
ffffffffc0201df4:	4a9000ef          	jal	ra,ffffffffc0202a9c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201df8:	4515                	li	a0,5
ffffffffc0201dfa:	41b000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201dfe:	89aa                	mv	s3,a0
ffffffffc0201e00:	48050a63          	beqz	a0,ffffffffc0202294 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0201e04:	4505                	li	a0,1
ffffffffc0201e06:	40f000ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0201e0a:	2e051563          	bnez	a0,ffffffffc02020f4 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0201e0e:	01092783          	lw	a5,16(s2)
ffffffffc0201e12:	2c079163          	bnez	a5,ffffffffc02020d4 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201e16:	4595                	li	a1,5
ffffffffc0201e18:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201e1a:	0000f797          	auipc	a5,0xf
ffffffffc0201e1e:	7577ab23          	sw	s7,1878(a5) # ffffffffc0211570 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0201e22:	0000f797          	auipc	a5,0xf
ffffffffc0201e26:	7367bf23          	sd	s6,1854(a5) # ffffffffc0211560 <free_area>
ffffffffc0201e2a:	0000f797          	auipc	a5,0xf
ffffffffc0201e2e:	7357bf23          	sd	s5,1854(a5) # ffffffffc0211568 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0201e32:	46b000ef          	jal	ra,ffffffffc0202a9c <free_pages>
    return listelm->next;
ffffffffc0201e36:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e3a:	01278963          	beq	a5,s2,ffffffffc0201e4c <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201e3e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201e42:	679c                	ld	a5,8(a5)
ffffffffc0201e44:	34fd                	addiw	s1,s1,-1
ffffffffc0201e46:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e48:	ff279be3          	bne	a5,s2,ffffffffc0201e3e <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0201e4c:	26049463          	bnez	s1,ffffffffc02020b4 <default_check+0x588>
    assert(total == 0);
ffffffffc0201e50:	46041263          	bnez	s0,ffffffffc02022b4 <default_check+0x788>
}
ffffffffc0201e54:	60a6                	ld	ra,72(sp)
ffffffffc0201e56:	6406                	ld	s0,64(sp)
ffffffffc0201e58:	74e2                	ld	s1,56(sp)
ffffffffc0201e5a:	7942                	ld	s2,48(sp)
ffffffffc0201e5c:	79a2                	ld	s3,40(sp)
ffffffffc0201e5e:	7a02                	ld	s4,32(sp)
ffffffffc0201e60:	6ae2                	ld	s5,24(sp)
ffffffffc0201e62:	6b42                	ld	s6,16(sp)
ffffffffc0201e64:	6ba2                	ld	s7,8(sp)
ffffffffc0201e66:	6c02                	ld	s8,0(sp)
ffffffffc0201e68:	6161                	addi	sp,sp,80
ffffffffc0201e6a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e6c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201e6e:	4401                	li	s0,0
ffffffffc0201e70:	4481                	li	s1,0
ffffffffc0201e72:	b331                	j	ffffffffc0201b7e <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0201e74:	00003697          	auipc	a3,0x3
ffffffffc0201e78:	1fc68693          	addi	a3,a3,508 # ffffffffc0205070 <commands+0xc60>
ffffffffc0201e7c:	00003617          	auipc	a2,0x3
ffffffffc0201e80:	dec60613          	addi	a2,a2,-532 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201e84:	0f000593          	li	a1,240
ffffffffc0201e88:	00003517          	auipc	a0,0x3
ffffffffc0201e8c:	52850513          	addi	a0,a0,1320 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0201e90:	a76fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201e94:	00003697          	auipc	a3,0x3
ffffffffc0201e98:	59468693          	addi	a3,a3,1428 # ffffffffc0205428 <commands+0x1018>
ffffffffc0201e9c:	00003617          	auipc	a2,0x3
ffffffffc0201ea0:	dcc60613          	addi	a2,a2,-564 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201ea4:	0bd00593          	li	a1,189
ffffffffc0201ea8:	00003517          	auipc	a0,0x3
ffffffffc0201eac:	50850513          	addi	a0,a0,1288 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0201eb0:	a56fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201eb4:	00003697          	auipc	a3,0x3
ffffffffc0201eb8:	59c68693          	addi	a3,a3,1436 # ffffffffc0205450 <commands+0x1040>
ffffffffc0201ebc:	00003617          	auipc	a2,0x3
ffffffffc0201ec0:	dac60613          	addi	a2,a2,-596 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201ec4:	0be00593          	li	a1,190
ffffffffc0201ec8:	00003517          	auipc	a0,0x3
ffffffffc0201ecc:	4e850513          	addi	a0,a0,1256 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0201ed0:	a36fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201ed4:	00003697          	auipc	a3,0x3
ffffffffc0201ed8:	5bc68693          	addi	a3,a3,1468 # ffffffffc0205490 <commands+0x1080>
ffffffffc0201edc:	00003617          	auipc	a2,0x3
ffffffffc0201ee0:	d8c60613          	addi	a2,a2,-628 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201ee4:	0c000593          	li	a1,192
ffffffffc0201ee8:	00003517          	auipc	a0,0x3
ffffffffc0201eec:	4c850513          	addi	a0,a0,1224 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0201ef0:	a16fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201ef4:	00003697          	auipc	a3,0x3
ffffffffc0201ef8:	62468693          	addi	a3,a3,1572 # ffffffffc0205518 <commands+0x1108>
ffffffffc0201efc:	00003617          	auipc	a2,0x3
ffffffffc0201f00:	d6c60613          	addi	a2,a2,-660 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201f04:	0d900593          	li	a1,217
ffffffffc0201f08:	00003517          	auipc	a0,0x3
ffffffffc0201f0c:	4a850513          	addi	a0,a0,1192 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0201f10:	9f6fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201f14:	00003697          	auipc	a3,0x3
ffffffffc0201f18:	4b468693          	addi	a3,a3,1204 # ffffffffc02053c8 <commands+0xfb8>
ffffffffc0201f1c:	00003617          	auipc	a2,0x3
ffffffffc0201f20:	d4c60613          	addi	a2,a2,-692 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201f24:	0d200593          	li	a1,210
ffffffffc0201f28:	00003517          	auipc	a0,0x3
ffffffffc0201f2c:	48850513          	addi	a0,a0,1160 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0201f30:	9d6fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 3);
ffffffffc0201f34:	00003697          	auipc	a3,0x3
ffffffffc0201f38:	5d468693          	addi	a3,a3,1492 # ffffffffc0205508 <commands+0x10f8>
ffffffffc0201f3c:	00003617          	auipc	a2,0x3
ffffffffc0201f40:	d2c60613          	addi	a2,a2,-724 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201f44:	0d000593          	li	a1,208
ffffffffc0201f48:	00003517          	auipc	a0,0x3
ffffffffc0201f4c:	46850513          	addi	a0,a0,1128 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0201f50:	9b6fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201f54:	00003697          	auipc	a3,0x3
ffffffffc0201f58:	59c68693          	addi	a3,a3,1436 # ffffffffc02054f0 <commands+0x10e0>
ffffffffc0201f5c:	00003617          	auipc	a2,0x3
ffffffffc0201f60:	d0c60613          	addi	a2,a2,-756 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201f64:	0cb00593          	li	a1,203
ffffffffc0201f68:	00003517          	auipc	a0,0x3
ffffffffc0201f6c:	44850513          	addi	a0,a0,1096 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0201f70:	996fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201f74:	00003697          	auipc	a3,0x3
ffffffffc0201f78:	55c68693          	addi	a3,a3,1372 # ffffffffc02054d0 <commands+0x10c0>
ffffffffc0201f7c:	00003617          	auipc	a2,0x3
ffffffffc0201f80:	cec60613          	addi	a2,a2,-788 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201f84:	0c200593          	li	a1,194
ffffffffc0201f88:	00003517          	auipc	a0,0x3
ffffffffc0201f8c:	42850513          	addi	a0,a0,1064 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0201f90:	976fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != NULL);
ffffffffc0201f94:	00003697          	auipc	a3,0x3
ffffffffc0201f98:	5bc68693          	addi	a3,a3,1468 # ffffffffc0205550 <commands+0x1140>
ffffffffc0201f9c:	00003617          	auipc	a2,0x3
ffffffffc0201fa0:	ccc60613          	addi	a2,a2,-820 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201fa4:	0f800593          	li	a1,248
ffffffffc0201fa8:	00003517          	auipc	a0,0x3
ffffffffc0201fac:	40850513          	addi	a0,a0,1032 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0201fb0:	956fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc0201fb4:	00003697          	auipc	a3,0x3
ffffffffc0201fb8:	26c68693          	addi	a3,a3,620 # ffffffffc0205220 <commands+0xe10>
ffffffffc0201fbc:	00003617          	auipc	a2,0x3
ffffffffc0201fc0:	cac60613          	addi	a2,a2,-852 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201fc4:	0df00593          	li	a1,223
ffffffffc0201fc8:	00003517          	auipc	a0,0x3
ffffffffc0201fcc:	3e850513          	addi	a0,a0,1000 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0201fd0:	936fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201fd4:	00003697          	auipc	a3,0x3
ffffffffc0201fd8:	51c68693          	addi	a3,a3,1308 # ffffffffc02054f0 <commands+0x10e0>
ffffffffc0201fdc:	00003617          	auipc	a2,0x3
ffffffffc0201fe0:	c8c60613          	addi	a2,a2,-884 # ffffffffc0204c68 <commands+0x858>
ffffffffc0201fe4:	0dd00593          	li	a1,221
ffffffffc0201fe8:	00003517          	auipc	a0,0x3
ffffffffc0201fec:	3c850513          	addi	a0,a0,968 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0201ff0:	916fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201ff4:	00003697          	auipc	a3,0x3
ffffffffc0201ff8:	53c68693          	addi	a3,a3,1340 # ffffffffc0205530 <commands+0x1120>
ffffffffc0201ffc:	00003617          	auipc	a2,0x3
ffffffffc0202000:	c6c60613          	addi	a2,a2,-916 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202004:	0dc00593          	li	a1,220
ffffffffc0202008:	00003517          	auipc	a0,0x3
ffffffffc020200c:	3a850513          	addi	a0,a0,936 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202010:	8f6fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202014:	00003697          	auipc	a3,0x3
ffffffffc0202018:	3b468693          	addi	a3,a3,948 # ffffffffc02053c8 <commands+0xfb8>
ffffffffc020201c:	00003617          	auipc	a2,0x3
ffffffffc0202020:	c4c60613          	addi	a2,a2,-948 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202024:	0b900593          	li	a1,185
ffffffffc0202028:	00003517          	auipc	a0,0x3
ffffffffc020202c:	38850513          	addi	a0,a0,904 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202030:	8d6fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202034:	00003697          	auipc	a3,0x3
ffffffffc0202038:	4bc68693          	addi	a3,a3,1212 # ffffffffc02054f0 <commands+0x10e0>
ffffffffc020203c:	00003617          	auipc	a2,0x3
ffffffffc0202040:	c2c60613          	addi	a2,a2,-980 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202044:	0d600593          	li	a1,214
ffffffffc0202048:	00003517          	auipc	a0,0x3
ffffffffc020204c:	36850513          	addi	a0,a0,872 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202050:	8b6fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202054:	00003697          	auipc	a3,0x3
ffffffffc0202058:	3b468693          	addi	a3,a3,948 # ffffffffc0205408 <commands+0xff8>
ffffffffc020205c:	00003617          	auipc	a2,0x3
ffffffffc0202060:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202064:	0d400593          	li	a1,212
ffffffffc0202068:	00003517          	auipc	a0,0x3
ffffffffc020206c:	34850513          	addi	a0,a0,840 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202070:	896fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202074:	00003697          	auipc	a3,0x3
ffffffffc0202078:	37468693          	addi	a3,a3,884 # ffffffffc02053e8 <commands+0xfd8>
ffffffffc020207c:	00003617          	auipc	a2,0x3
ffffffffc0202080:	bec60613          	addi	a2,a2,-1044 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202084:	0d300593          	li	a1,211
ffffffffc0202088:	00003517          	auipc	a0,0x3
ffffffffc020208c:	32850513          	addi	a0,a0,808 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202090:	876fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202094:	00003697          	auipc	a3,0x3
ffffffffc0202098:	37468693          	addi	a3,a3,884 # ffffffffc0205408 <commands+0xff8>
ffffffffc020209c:	00003617          	auipc	a2,0x3
ffffffffc02020a0:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0204c68 <commands+0x858>
ffffffffc02020a4:	0bb00593          	li	a1,187
ffffffffc02020a8:	00003517          	auipc	a0,0x3
ffffffffc02020ac:	30850513          	addi	a0,a0,776 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc02020b0:	856fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(count == 0);
ffffffffc02020b4:	00003697          	auipc	a3,0x3
ffffffffc02020b8:	5ec68693          	addi	a3,a3,1516 # ffffffffc02056a0 <commands+0x1290>
ffffffffc02020bc:	00003617          	auipc	a2,0x3
ffffffffc02020c0:	bac60613          	addi	a2,a2,-1108 # ffffffffc0204c68 <commands+0x858>
ffffffffc02020c4:	12500593          	li	a1,293
ffffffffc02020c8:	00003517          	auipc	a0,0x3
ffffffffc02020cc:	2e850513          	addi	a0,a0,744 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc02020d0:	836fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc02020d4:	00003697          	auipc	a3,0x3
ffffffffc02020d8:	14c68693          	addi	a3,a3,332 # ffffffffc0205220 <commands+0xe10>
ffffffffc02020dc:	00003617          	auipc	a2,0x3
ffffffffc02020e0:	b8c60613          	addi	a2,a2,-1140 # ffffffffc0204c68 <commands+0x858>
ffffffffc02020e4:	11a00593          	li	a1,282
ffffffffc02020e8:	00003517          	auipc	a0,0x3
ffffffffc02020ec:	2c850513          	addi	a0,a0,712 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc02020f0:	816fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02020f4:	00003697          	auipc	a3,0x3
ffffffffc02020f8:	3fc68693          	addi	a3,a3,1020 # ffffffffc02054f0 <commands+0x10e0>
ffffffffc02020fc:	00003617          	auipc	a2,0x3
ffffffffc0202100:	b6c60613          	addi	a2,a2,-1172 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202104:	11800593          	li	a1,280
ffffffffc0202108:	00003517          	auipc	a0,0x3
ffffffffc020210c:	2a850513          	addi	a0,a0,680 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202110:	ff7fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202114:	00003697          	auipc	a3,0x3
ffffffffc0202118:	39c68693          	addi	a3,a3,924 # ffffffffc02054b0 <commands+0x10a0>
ffffffffc020211c:	00003617          	auipc	a2,0x3
ffffffffc0202120:	b4c60613          	addi	a2,a2,-1204 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202124:	0c100593          	li	a1,193
ffffffffc0202128:	00003517          	auipc	a0,0x3
ffffffffc020212c:	28850513          	addi	a0,a0,648 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202130:	fd7fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202134:	00003697          	auipc	a3,0x3
ffffffffc0202138:	52c68693          	addi	a3,a3,1324 # ffffffffc0205660 <commands+0x1250>
ffffffffc020213c:	00003617          	auipc	a2,0x3
ffffffffc0202140:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202144:	11200593          	li	a1,274
ffffffffc0202148:	00003517          	auipc	a0,0x3
ffffffffc020214c:	26850513          	addi	a0,a0,616 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202150:	fb7fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202154:	00003697          	auipc	a3,0x3
ffffffffc0202158:	4ec68693          	addi	a3,a3,1260 # ffffffffc0205640 <commands+0x1230>
ffffffffc020215c:	00003617          	auipc	a2,0x3
ffffffffc0202160:	b0c60613          	addi	a2,a2,-1268 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202164:	11000593          	li	a1,272
ffffffffc0202168:	00003517          	auipc	a0,0x3
ffffffffc020216c:	24850513          	addi	a0,a0,584 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202170:	f97fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202174:	00003697          	auipc	a3,0x3
ffffffffc0202178:	4a468693          	addi	a3,a3,1188 # ffffffffc0205618 <commands+0x1208>
ffffffffc020217c:	00003617          	auipc	a2,0x3
ffffffffc0202180:	aec60613          	addi	a2,a2,-1300 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202184:	10e00593          	li	a1,270
ffffffffc0202188:	00003517          	auipc	a0,0x3
ffffffffc020218c:	22850513          	addi	a0,a0,552 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202190:	f77fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202194:	00003697          	auipc	a3,0x3
ffffffffc0202198:	45c68693          	addi	a3,a3,1116 # ffffffffc02055f0 <commands+0x11e0>
ffffffffc020219c:	00003617          	auipc	a2,0x3
ffffffffc02021a0:	acc60613          	addi	a2,a2,-1332 # ffffffffc0204c68 <commands+0x858>
ffffffffc02021a4:	10d00593          	li	a1,269
ffffffffc02021a8:	00003517          	auipc	a0,0x3
ffffffffc02021ac:	20850513          	addi	a0,a0,520 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc02021b0:	f57fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02021b4:	00003697          	auipc	a3,0x3
ffffffffc02021b8:	42c68693          	addi	a3,a3,1068 # ffffffffc02055e0 <commands+0x11d0>
ffffffffc02021bc:	00003617          	auipc	a2,0x3
ffffffffc02021c0:	aac60613          	addi	a2,a2,-1364 # ffffffffc0204c68 <commands+0x858>
ffffffffc02021c4:	10800593          	li	a1,264
ffffffffc02021c8:	00003517          	auipc	a0,0x3
ffffffffc02021cc:	1e850513          	addi	a0,a0,488 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc02021d0:	f37fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02021d4:	00003697          	auipc	a3,0x3
ffffffffc02021d8:	31c68693          	addi	a3,a3,796 # ffffffffc02054f0 <commands+0x10e0>
ffffffffc02021dc:	00003617          	auipc	a2,0x3
ffffffffc02021e0:	a8c60613          	addi	a2,a2,-1396 # ffffffffc0204c68 <commands+0x858>
ffffffffc02021e4:	10700593          	li	a1,263
ffffffffc02021e8:	00003517          	auipc	a0,0x3
ffffffffc02021ec:	1c850513          	addi	a0,a0,456 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc02021f0:	f17fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02021f4:	00003697          	auipc	a3,0x3
ffffffffc02021f8:	3cc68693          	addi	a3,a3,972 # ffffffffc02055c0 <commands+0x11b0>
ffffffffc02021fc:	00003617          	auipc	a2,0x3
ffffffffc0202200:	a6c60613          	addi	a2,a2,-1428 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202204:	10600593          	li	a1,262
ffffffffc0202208:	00003517          	auipc	a0,0x3
ffffffffc020220c:	1a850513          	addi	a0,a0,424 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202210:	ef7fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202214:	00003697          	auipc	a3,0x3
ffffffffc0202218:	37c68693          	addi	a3,a3,892 # ffffffffc0205590 <commands+0x1180>
ffffffffc020221c:	00003617          	auipc	a2,0x3
ffffffffc0202220:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202224:	10500593          	li	a1,261
ffffffffc0202228:	00003517          	auipc	a0,0x3
ffffffffc020222c:	18850513          	addi	a0,a0,392 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202230:	ed7fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202234:	00003697          	auipc	a3,0x3
ffffffffc0202238:	34468693          	addi	a3,a3,836 # ffffffffc0205578 <commands+0x1168>
ffffffffc020223c:	00003617          	auipc	a2,0x3
ffffffffc0202240:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202244:	10400593          	li	a1,260
ffffffffc0202248:	00003517          	auipc	a0,0x3
ffffffffc020224c:	16850513          	addi	a0,a0,360 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202250:	eb7fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202254:	00003697          	auipc	a3,0x3
ffffffffc0202258:	29c68693          	addi	a3,a3,668 # ffffffffc02054f0 <commands+0x10e0>
ffffffffc020225c:	00003617          	auipc	a2,0x3
ffffffffc0202260:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202264:	0fe00593          	li	a1,254
ffffffffc0202268:	00003517          	auipc	a0,0x3
ffffffffc020226c:	14850513          	addi	a0,a0,328 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202270:	e97fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202274:	00003697          	auipc	a3,0x3
ffffffffc0202278:	2ec68693          	addi	a3,a3,748 # ffffffffc0205560 <commands+0x1150>
ffffffffc020227c:	00003617          	auipc	a2,0x3
ffffffffc0202280:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202284:	0f900593          	li	a1,249
ffffffffc0202288:	00003517          	auipc	a0,0x3
ffffffffc020228c:	12850513          	addi	a0,a0,296 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202290:	e77fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202294:	00003697          	auipc	a3,0x3
ffffffffc0202298:	3ec68693          	addi	a3,a3,1004 # ffffffffc0205680 <commands+0x1270>
ffffffffc020229c:	00003617          	auipc	a2,0x3
ffffffffc02022a0:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0204c68 <commands+0x858>
ffffffffc02022a4:	11700593          	li	a1,279
ffffffffc02022a8:	00003517          	auipc	a0,0x3
ffffffffc02022ac:	10850513          	addi	a0,a0,264 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc02022b0:	e57fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == 0);
ffffffffc02022b4:	00003697          	auipc	a3,0x3
ffffffffc02022b8:	3fc68693          	addi	a3,a3,1020 # ffffffffc02056b0 <commands+0x12a0>
ffffffffc02022bc:	00003617          	auipc	a2,0x3
ffffffffc02022c0:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0204c68 <commands+0x858>
ffffffffc02022c4:	12600593          	li	a1,294
ffffffffc02022c8:	00003517          	auipc	a0,0x3
ffffffffc02022cc:	0e850513          	addi	a0,a0,232 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc02022d0:	e37fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == nr_free_pages());
ffffffffc02022d4:	00003697          	auipc	a3,0x3
ffffffffc02022d8:	dac68693          	addi	a3,a3,-596 # ffffffffc0205080 <commands+0xc70>
ffffffffc02022dc:	00003617          	auipc	a2,0x3
ffffffffc02022e0:	98c60613          	addi	a2,a2,-1652 # ffffffffc0204c68 <commands+0x858>
ffffffffc02022e4:	0f300593          	li	a1,243
ffffffffc02022e8:	00003517          	auipc	a0,0x3
ffffffffc02022ec:	0c850513          	addi	a0,a0,200 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc02022f0:	e17fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02022f4:	00003697          	auipc	a3,0x3
ffffffffc02022f8:	0f468693          	addi	a3,a3,244 # ffffffffc02053e8 <commands+0xfd8>
ffffffffc02022fc:	00003617          	auipc	a2,0x3
ffffffffc0202300:	96c60613          	addi	a2,a2,-1684 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202304:	0ba00593          	li	a1,186
ffffffffc0202308:	00003517          	auipc	a0,0x3
ffffffffc020230c:	0a850513          	addi	a0,a0,168 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202310:	df7fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202314 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202314:	1141                	addi	sp,sp,-16
ffffffffc0202316:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202318:	18058063          	beqz	a1,ffffffffc0202498 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc020231c:	00359693          	slli	a3,a1,0x3
ffffffffc0202320:	96ae                	add	a3,a3,a1
ffffffffc0202322:	068e                	slli	a3,a3,0x3
ffffffffc0202324:	96aa                	add	a3,a3,a0
ffffffffc0202326:	02d50d63          	beq	a0,a3,ffffffffc0202360 <default_free_pages+0x4c>
ffffffffc020232a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020232c:	8b85                	andi	a5,a5,1
ffffffffc020232e:	14079563          	bnez	a5,ffffffffc0202478 <default_free_pages+0x164>
ffffffffc0202332:	651c                	ld	a5,8(a0)
ffffffffc0202334:	8385                	srli	a5,a5,0x1
ffffffffc0202336:	8b85                	andi	a5,a5,1
ffffffffc0202338:	14079063          	bnez	a5,ffffffffc0202478 <default_free_pages+0x164>
ffffffffc020233c:	87aa                	mv	a5,a0
ffffffffc020233e:	a809                	j	ffffffffc0202350 <default_free_pages+0x3c>
ffffffffc0202340:	6798                	ld	a4,8(a5)
ffffffffc0202342:	8b05                	andi	a4,a4,1
ffffffffc0202344:	12071a63          	bnez	a4,ffffffffc0202478 <default_free_pages+0x164>
ffffffffc0202348:	6798                	ld	a4,8(a5)
ffffffffc020234a:	8b09                	andi	a4,a4,2
ffffffffc020234c:	12071663          	bnez	a4,ffffffffc0202478 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0202350:	0007b423          	sd	zero,8(a5)
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202354:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202358:	04878793          	addi	a5,a5,72
ffffffffc020235c:	fed792e3          	bne	a5,a3,ffffffffc0202340 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0202360:	2581                	sext.w	a1,a1
ffffffffc0202362:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0202364:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202368:	4789                	li	a5,2
ffffffffc020236a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020236e:	0000f697          	auipc	a3,0xf
ffffffffc0202372:	1f268693          	addi	a3,a3,498 # ffffffffc0211560 <free_area>
ffffffffc0202376:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202378:	669c                	ld	a5,8(a3)
ffffffffc020237a:	9db9                	addw	a1,a1,a4
ffffffffc020237c:	0000f717          	auipc	a4,0xf
ffffffffc0202380:	1eb72a23          	sw	a1,500(a4) # ffffffffc0211570 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0202384:	08d78f63          	beq	a5,a3,ffffffffc0202422 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0202388:	fe078713          	addi	a4,a5,-32
ffffffffc020238c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020238e:	4801                	li	a6,0
ffffffffc0202390:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0202394:	00e56a63          	bltu	a0,a4,ffffffffc02023a8 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0202398:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020239a:	02d70563          	beq	a4,a3,ffffffffc02023c4 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020239e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02023a0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02023a4:	fee57ae3          	bleu	a4,a0,ffffffffc0202398 <default_free_pages+0x84>
ffffffffc02023a8:	00080663          	beqz	a6,ffffffffc02023b4 <default_free_pages+0xa0>
ffffffffc02023ac:	0000f817          	auipc	a6,0xf
ffffffffc02023b0:	1ab83a23          	sd	a1,436(a6) # ffffffffc0211560 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02023b4:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02023b6:	e390                	sd	a2,0(a5)
ffffffffc02023b8:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02023ba:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02023bc:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc02023be:	02d59163          	bne	a1,a3,ffffffffc02023e0 <default_free_pages+0xcc>
ffffffffc02023c2:	a091                	j	ffffffffc0202406 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02023c4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02023c6:	f514                	sd	a3,40(a0)
ffffffffc02023c8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02023ca:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02023cc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02023ce:	00d70563          	beq	a4,a3,ffffffffc02023d8 <default_free_pages+0xc4>
ffffffffc02023d2:	4805                	li	a6,1
ffffffffc02023d4:	87ba                	mv	a5,a4
ffffffffc02023d6:	b7e9                	j	ffffffffc02023a0 <default_free_pages+0x8c>
ffffffffc02023d8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02023da:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02023dc:	02d78163          	beq	a5,a3,ffffffffc02023fe <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02023e0:	ff85a803          	lw	a6,-8(a1) # ff8 <BASE_ADDRESS-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc02023e4:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc02023e8:	02081713          	slli	a4,a6,0x20
ffffffffc02023ec:	9301                	srli	a4,a4,0x20
ffffffffc02023ee:	00371793          	slli	a5,a4,0x3
ffffffffc02023f2:	97ba                	add	a5,a5,a4
ffffffffc02023f4:	078e                	slli	a5,a5,0x3
ffffffffc02023f6:	97b2                	add	a5,a5,a2
ffffffffc02023f8:	02f50e63          	beq	a0,a5,ffffffffc0202434 <default_free_pages+0x120>
ffffffffc02023fc:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc02023fe:	fe078713          	addi	a4,a5,-32
ffffffffc0202402:	00d78d63          	beq	a5,a3,ffffffffc020241c <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0202406:	4d0c                	lw	a1,24(a0)
ffffffffc0202408:	02059613          	slli	a2,a1,0x20
ffffffffc020240c:	9201                	srli	a2,a2,0x20
ffffffffc020240e:	00361693          	slli	a3,a2,0x3
ffffffffc0202412:	96b2                	add	a3,a3,a2
ffffffffc0202414:	068e                	slli	a3,a3,0x3
ffffffffc0202416:	96aa                	add	a3,a3,a0
ffffffffc0202418:	04d70063          	beq	a4,a3,ffffffffc0202458 <default_free_pages+0x144>
}
ffffffffc020241c:	60a2                	ld	ra,8(sp)
ffffffffc020241e:	0141                	addi	sp,sp,16
ffffffffc0202420:	8082                	ret
ffffffffc0202422:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0202424:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0202428:	e398                	sd	a4,0(a5)
ffffffffc020242a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020242c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020242e:	f11c                	sd	a5,32(a0)
}
ffffffffc0202430:	0141                	addi	sp,sp,16
ffffffffc0202432:	8082                	ret
            p->property += base->property;
ffffffffc0202434:	4d1c                	lw	a5,24(a0)
ffffffffc0202436:	0107883b          	addw	a6,a5,a6
ffffffffc020243a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020243e:	57f5                	li	a5,-3
ffffffffc0202440:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202444:	02053803          	ld	a6,32(a0)
ffffffffc0202448:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc020244a:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020244c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0202450:	659c                	ld	a5,8(a1)
ffffffffc0202452:	01073023          	sd	a6,0(a4)
ffffffffc0202456:	b765                	j	ffffffffc02023fe <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0202458:	ff87a703          	lw	a4,-8(a5)
ffffffffc020245c:	fe878693          	addi	a3,a5,-24
ffffffffc0202460:	9db9                	addw	a1,a1,a4
ffffffffc0202462:	cd0c                	sw	a1,24(a0)
ffffffffc0202464:	5775                	li	a4,-3
ffffffffc0202466:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020246a:	6398                	ld	a4,0(a5)
ffffffffc020246c:	679c                	ld	a5,8(a5)
}
ffffffffc020246e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202470:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202472:	e398                	sd	a4,0(a5)
ffffffffc0202474:	0141                	addi	sp,sp,16
ffffffffc0202476:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202478:	00003697          	auipc	a3,0x3
ffffffffc020247c:	24868693          	addi	a3,a3,584 # ffffffffc02056c0 <commands+0x12b0>
ffffffffc0202480:	00002617          	auipc	a2,0x2
ffffffffc0202484:	7e860613          	addi	a2,a2,2024 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202488:	08300593          	li	a1,131
ffffffffc020248c:	00003517          	auipc	a0,0x3
ffffffffc0202490:	f2450513          	addi	a0,a0,-220 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc0202494:	c73fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc0202498:	00003697          	auipc	a3,0x3
ffffffffc020249c:	25068693          	addi	a3,a3,592 # ffffffffc02056e8 <commands+0x12d8>
ffffffffc02024a0:	00002617          	auipc	a2,0x2
ffffffffc02024a4:	7c860613          	addi	a2,a2,1992 # ffffffffc0204c68 <commands+0x858>
ffffffffc02024a8:	08000593          	li	a1,128
ffffffffc02024ac:	00003517          	auipc	a0,0x3
ffffffffc02024b0:	f0450513          	addi	a0,a0,-252 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc02024b4:	c53fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02024b8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02024b8:	cd51                	beqz	a0,ffffffffc0202554 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc02024ba:	0000f597          	auipc	a1,0xf
ffffffffc02024be:	0a658593          	addi	a1,a1,166 # ffffffffc0211560 <free_area>
ffffffffc02024c2:	0105a803          	lw	a6,16(a1)
ffffffffc02024c6:	862a                	mv	a2,a0
ffffffffc02024c8:	02081793          	slli	a5,a6,0x20
ffffffffc02024cc:	9381                	srli	a5,a5,0x20
ffffffffc02024ce:	00a7ee63          	bltu	a5,a0,ffffffffc02024ea <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02024d2:	87ae                	mv	a5,a1
ffffffffc02024d4:	a801                	j	ffffffffc02024e4 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02024d6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02024da:	02071693          	slli	a3,a4,0x20
ffffffffc02024de:	9281                	srli	a3,a3,0x20
ffffffffc02024e0:	00c6f763          	bleu	a2,a3,ffffffffc02024ee <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02024e4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02024e6:	feb798e3          	bne	a5,a1,ffffffffc02024d6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02024ea:	4501                	li	a0,0
}
ffffffffc02024ec:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02024ee:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc02024f2:	dd6d                	beqz	a0,ffffffffc02024ec <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02024f4:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02024f8:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02024fc:	00060e1b          	sext.w	t3,a2
ffffffffc0202500:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0202504:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0202508:	02d67b63          	bleu	a3,a2,ffffffffc020253e <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc020250c:	00361693          	slli	a3,a2,0x3
ffffffffc0202510:	96b2                	add	a3,a3,a2
ffffffffc0202512:	068e                	slli	a3,a3,0x3
ffffffffc0202514:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0202516:	41c7073b          	subw	a4,a4,t3
ffffffffc020251a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020251c:	00868613          	addi	a2,a3,8
ffffffffc0202520:	4709                	li	a4,2
ffffffffc0202522:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202526:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020252a:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020252e:	0105a803          	lw	a6,16(a1)
ffffffffc0202532:	e310                	sd	a2,0(a4)
ffffffffc0202534:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0202538:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020253a:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020253e:	41c8083b          	subw	a6,a6,t3
ffffffffc0202542:	0000f717          	auipc	a4,0xf
ffffffffc0202546:	03072723          	sw	a6,46(a4) # ffffffffc0211570 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020254a:	5775                	li	a4,-3
ffffffffc020254c:	17a1                	addi	a5,a5,-24
ffffffffc020254e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0202552:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202554:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202556:	00003697          	auipc	a3,0x3
ffffffffc020255a:	19268693          	addi	a3,a3,402 # ffffffffc02056e8 <commands+0x12d8>
ffffffffc020255e:	00002617          	auipc	a2,0x2
ffffffffc0202562:	70a60613          	addi	a2,a2,1802 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202566:	06200593          	li	a1,98
ffffffffc020256a:	00003517          	auipc	a0,0x3
ffffffffc020256e:	e4650513          	addi	a0,a0,-442 # ffffffffc02053b0 <commands+0xfa0>
default_alloc_pages(size_t n) {
ffffffffc0202572:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202574:	b93fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202578 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0202578:	1141                	addi	sp,sp,-16
ffffffffc020257a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020257c:	c1fd                	beqz	a1,ffffffffc0202662 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020257e:	00359693          	slli	a3,a1,0x3
ffffffffc0202582:	96ae                	add	a3,a3,a1
ffffffffc0202584:	068e                	slli	a3,a3,0x3
ffffffffc0202586:	96aa                	add	a3,a3,a0
ffffffffc0202588:	02d50463          	beq	a0,a3,ffffffffc02025b0 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020258c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020258e:	87aa                	mv	a5,a0
ffffffffc0202590:	8b05                	andi	a4,a4,1
ffffffffc0202592:	e709                	bnez	a4,ffffffffc020259c <default_init_memmap+0x24>
ffffffffc0202594:	a07d                	j	ffffffffc0202642 <default_init_memmap+0xca>
ffffffffc0202596:	6798                	ld	a4,8(a5)
ffffffffc0202598:	8b05                	andi	a4,a4,1
ffffffffc020259a:	c745                	beqz	a4,ffffffffc0202642 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc020259c:	0007ac23          	sw	zero,24(a5)
ffffffffc02025a0:	0007b423          	sd	zero,8(a5)
ffffffffc02025a4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02025a8:	04878793          	addi	a5,a5,72
ffffffffc02025ac:	fed795e3          	bne	a5,a3,ffffffffc0202596 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc02025b0:	2581                	sext.w	a1,a1
ffffffffc02025b2:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02025b4:	4789                	li	a5,2
ffffffffc02025b6:	00850713          	addi	a4,a0,8
ffffffffc02025ba:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02025be:	0000f697          	auipc	a3,0xf
ffffffffc02025c2:	fa268693          	addi	a3,a3,-94 # ffffffffc0211560 <free_area>
ffffffffc02025c6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02025c8:	669c                	ld	a5,8(a3)
ffffffffc02025ca:	9db9                	addw	a1,a1,a4
ffffffffc02025cc:	0000f717          	auipc	a4,0xf
ffffffffc02025d0:	fab72223          	sw	a1,-92(a4) # ffffffffc0211570 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02025d4:	04d78a63          	beq	a5,a3,ffffffffc0202628 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02025d8:	fe078713          	addi	a4,a5,-32
ffffffffc02025dc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02025de:	4801                	li	a6,0
ffffffffc02025e0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02025e4:	00e56a63          	bltu	a0,a4,ffffffffc02025f8 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc02025e8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02025ea:	02d70563          	beq	a4,a3,ffffffffc0202614 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02025ee:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02025f0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02025f4:	fee57ae3          	bleu	a4,a0,ffffffffc02025e8 <default_init_memmap+0x70>
ffffffffc02025f8:	00080663          	beqz	a6,ffffffffc0202604 <default_init_memmap+0x8c>
ffffffffc02025fc:	0000f717          	auipc	a4,0xf
ffffffffc0202600:	f6b73223          	sd	a1,-156(a4) # ffffffffc0211560 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202604:	6398                	ld	a4,0(a5)
}
ffffffffc0202606:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202608:	e390                	sd	a2,0(a5)
ffffffffc020260a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020260c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020260e:	f118                	sd	a4,32(a0)
ffffffffc0202610:	0141                	addi	sp,sp,16
ffffffffc0202612:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202614:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202616:	f514                	sd	a3,40(a0)
ffffffffc0202618:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020261a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020261c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020261e:	00d70e63          	beq	a4,a3,ffffffffc020263a <default_init_memmap+0xc2>
ffffffffc0202622:	4805                	li	a6,1
ffffffffc0202624:	87ba                	mv	a5,a4
ffffffffc0202626:	b7e9                	j	ffffffffc02025f0 <default_init_memmap+0x78>
}
ffffffffc0202628:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020262a:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020262e:	e398                	sd	a4,0(a5)
ffffffffc0202630:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0202632:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202634:	f11c                	sd	a5,32(a0)
}
ffffffffc0202636:	0141                	addi	sp,sp,16
ffffffffc0202638:	8082                	ret
ffffffffc020263a:	60a2                	ld	ra,8(sp)
ffffffffc020263c:	e290                	sd	a2,0(a3)
ffffffffc020263e:	0141                	addi	sp,sp,16
ffffffffc0202640:	8082                	ret
        assert(PageReserved(p));
ffffffffc0202642:	00003697          	auipc	a3,0x3
ffffffffc0202646:	0ae68693          	addi	a3,a3,174 # ffffffffc02056f0 <commands+0x12e0>
ffffffffc020264a:	00002617          	auipc	a2,0x2
ffffffffc020264e:	61e60613          	addi	a2,a2,1566 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202652:	04900593          	li	a1,73
ffffffffc0202656:	00003517          	auipc	a0,0x3
ffffffffc020265a:	d5a50513          	addi	a0,a0,-678 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc020265e:	aa9fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc0202662:	00003697          	auipc	a3,0x3
ffffffffc0202666:	08668693          	addi	a3,a3,134 # ffffffffc02056e8 <commands+0x12d8>
ffffffffc020266a:	00002617          	auipc	a2,0x2
ffffffffc020266e:	5fe60613          	addi	a2,a2,1534 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202672:	04600593          	li	a1,70
ffffffffc0202676:	00003517          	auipc	a0,0x3
ffffffffc020267a:	d3a50513          	addi	a0,a0,-710 # ffffffffc02053b0 <commands+0xfa0>
ffffffffc020267e:	a89fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202682 <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0202682:	0000f797          	auipc	a5,0xf
ffffffffc0202686:	e0678793          	addi	a5,a5,-506 # ffffffffc0211488 <pra_list_head>
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);

     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
ffffffffc020268a:	f51c                	sd	a5,40(a0)
ffffffffc020268c:	e79c                	sd	a5,8(a5)
ffffffffc020268e:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc0202690:	0000f717          	auipc	a4,0xf
ffffffffc0202694:	eef73423          	sd	a5,-280(a4) # ffffffffc0211578 <curr_ptr>
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0202698:	4501                	li	a0,0
ffffffffc020269a:	8082                	ret

ffffffffc020269c <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc020269c:	4501                	li	a0,0
ffffffffc020269e:	8082                	ret

ffffffffc02026a0 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02026a0:	4501                	li	a0,0
ffffffffc02026a2:	8082                	ret

ffffffffc02026a4 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02026a4:	4501                	li	a0,0
ffffffffc02026a6:	8082                	ret

ffffffffc02026a8 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc02026a8:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02026aa:	678d                	lui	a5,0x3
ffffffffc02026ac:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc02026ae:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02026b0:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02026b4:	0000f797          	auipc	a5,0xf
ffffffffc02026b8:	d9c78793          	addi	a5,a5,-612 # ffffffffc0211450 <pgfault_num>
ffffffffc02026bc:	4398                	lw	a4,0(a5)
ffffffffc02026be:	4691                	li	a3,4
ffffffffc02026c0:	2701                	sext.w	a4,a4
ffffffffc02026c2:	08d71f63          	bne	a4,a3,ffffffffc0202760 <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02026c6:	6685                	lui	a3,0x1
ffffffffc02026c8:	4629                	li	a2,10
ffffffffc02026ca:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02026ce:	4394                	lw	a3,0(a5)
ffffffffc02026d0:	2681                	sext.w	a3,a3
ffffffffc02026d2:	20e69763          	bne	a3,a4,ffffffffc02028e0 <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02026d6:	6711                	lui	a4,0x4
ffffffffc02026d8:	4635                	li	a2,13
ffffffffc02026da:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02026de:	4398                	lw	a4,0(a5)
ffffffffc02026e0:	2701                	sext.w	a4,a4
ffffffffc02026e2:	1cd71f63          	bne	a4,a3,ffffffffc02028c0 <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02026e6:	6689                	lui	a3,0x2
ffffffffc02026e8:	462d                	li	a2,11
ffffffffc02026ea:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02026ee:	4394                	lw	a3,0(a5)
ffffffffc02026f0:	2681                	sext.w	a3,a3
ffffffffc02026f2:	1ae69763          	bne	a3,a4,ffffffffc02028a0 <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02026f6:	6715                	lui	a4,0x5
ffffffffc02026f8:	46b9                	li	a3,14
ffffffffc02026fa:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02026fe:	4398                	lw	a4,0(a5)
ffffffffc0202700:	4695                	li	a3,5
ffffffffc0202702:	2701                	sext.w	a4,a4
ffffffffc0202704:	16d71e63          	bne	a4,a3,ffffffffc0202880 <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc0202708:	4394                	lw	a3,0(a5)
ffffffffc020270a:	2681                	sext.w	a3,a3
ffffffffc020270c:	14e69a63          	bne	a3,a4,ffffffffc0202860 <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc0202710:	4398                	lw	a4,0(a5)
ffffffffc0202712:	2701                	sext.w	a4,a4
ffffffffc0202714:	12d71663          	bne	a4,a3,ffffffffc0202840 <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc0202718:	4394                	lw	a3,0(a5)
ffffffffc020271a:	2681                	sext.w	a3,a3
ffffffffc020271c:	10e69263          	bne	a3,a4,ffffffffc0202820 <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc0202720:	4398                	lw	a4,0(a5)
ffffffffc0202722:	2701                	sext.w	a4,a4
ffffffffc0202724:	0cd71e63          	bne	a4,a3,ffffffffc0202800 <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc0202728:	4394                	lw	a3,0(a5)
ffffffffc020272a:	2681                	sext.w	a3,a3
ffffffffc020272c:	0ae69a63          	bne	a3,a4,ffffffffc02027e0 <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202730:	6715                	lui	a4,0x5
ffffffffc0202732:	46b9                	li	a3,14
ffffffffc0202734:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0202738:	4398                	lw	a4,0(a5)
ffffffffc020273a:	4695                	li	a3,5
ffffffffc020273c:	2701                	sext.w	a4,a4
ffffffffc020273e:	08d71163          	bne	a4,a3,ffffffffc02027c0 <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202742:	6705                	lui	a4,0x1
ffffffffc0202744:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0202748:	4729                	li	a4,10
ffffffffc020274a:	04e69b63          	bne	a3,a4,ffffffffc02027a0 <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc020274e:	439c                	lw	a5,0(a5)
ffffffffc0202750:	4719                	li	a4,6
ffffffffc0202752:	2781                	sext.w	a5,a5
ffffffffc0202754:	02e79663          	bne	a5,a4,ffffffffc0202780 <_clock_check_swap+0xd8>
}
ffffffffc0202758:	60a2                	ld	ra,8(sp)
ffffffffc020275a:	4501                	li	a0,0
ffffffffc020275c:	0141                	addi	sp,sp,16
ffffffffc020275e:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0202760:	00003697          	auipc	a3,0x3
ffffffffc0202764:	ab068693          	addi	a3,a3,-1360 # ffffffffc0205210 <commands+0xe00>
ffffffffc0202768:	00002617          	auipc	a2,0x2
ffffffffc020276c:	50060613          	addi	a2,a2,1280 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202770:	08b00593          	li	a1,139
ffffffffc0202774:	00003517          	auipc	a0,0x3
ffffffffc0202778:	fdc50513          	addi	a0,a0,-36 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc020277c:	98bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==6);
ffffffffc0202780:	00003697          	auipc	a3,0x3
ffffffffc0202784:	02068693          	addi	a3,a3,32 # ffffffffc02057a0 <default_pmm_manager+0xa0>
ffffffffc0202788:	00002617          	auipc	a2,0x2
ffffffffc020278c:	4e060613          	addi	a2,a2,1248 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202790:	0a200593          	li	a1,162
ffffffffc0202794:	00003517          	auipc	a0,0x3
ffffffffc0202798:	fbc50513          	addi	a0,a0,-68 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc020279c:	96bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02027a0:	00003697          	auipc	a3,0x3
ffffffffc02027a4:	fd868693          	addi	a3,a3,-40 # ffffffffc0205778 <default_pmm_manager+0x78>
ffffffffc02027a8:	00002617          	auipc	a2,0x2
ffffffffc02027ac:	4c060613          	addi	a2,a2,1216 # ffffffffc0204c68 <commands+0x858>
ffffffffc02027b0:	0a000593          	li	a1,160
ffffffffc02027b4:	00003517          	auipc	a0,0x3
ffffffffc02027b8:	f9c50513          	addi	a0,a0,-100 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc02027bc:	94bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc02027c0:	00003697          	auipc	a3,0x3
ffffffffc02027c4:	fa868693          	addi	a3,a3,-88 # ffffffffc0205768 <default_pmm_manager+0x68>
ffffffffc02027c8:	00002617          	auipc	a2,0x2
ffffffffc02027cc:	4a060613          	addi	a2,a2,1184 # ffffffffc0204c68 <commands+0x858>
ffffffffc02027d0:	09f00593          	li	a1,159
ffffffffc02027d4:	00003517          	auipc	a0,0x3
ffffffffc02027d8:	f7c50513          	addi	a0,a0,-132 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc02027dc:	92bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc02027e0:	00003697          	auipc	a3,0x3
ffffffffc02027e4:	f8868693          	addi	a3,a3,-120 # ffffffffc0205768 <default_pmm_manager+0x68>
ffffffffc02027e8:	00002617          	auipc	a2,0x2
ffffffffc02027ec:	48060613          	addi	a2,a2,1152 # ffffffffc0204c68 <commands+0x858>
ffffffffc02027f0:	09d00593          	li	a1,157
ffffffffc02027f4:	00003517          	auipc	a0,0x3
ffffffffc02027f8:	f5c50513          	addi	a0,a0,-164 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc02027fc:	90bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0202800:	00003697          	auipc	a3,0x3
ffffffffc0202804:	f6868693          	addi	a3,a3,-152 # ffffffffc0205768 <default_pmm_manager+0x68>
ffffffffc0202808:	00002617          	auipc	a2,0x2
ffffffffc020280c:	46060613          	addi	a2,a2,1120 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202810:	09b00593          	li	a1,155
ffffffffc0202814:	00003517          	auipc	a0,0x3
ffffffffc0202818:	f3c50513          	addi	a0,a0,-196 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc020281c:	8ebfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0202820:	00003697          	auipc	a3,0x3
ffffffffc0202824:	f4868693          	addi	a3,a3,-184 # ffffffffc0205768 <default_pmm_manager+0x68>
ffffffffc0202828:	00002617          	auipc	a2,0x2
ffffffffc020282c:	44060613          	addi	a2,a2,1088 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202830:	09900593          	li	a1,153
ffffffffc0202834:	00003517          	auipc	a0,0x3
ffffffffc0202838:	f1c50513          	addi	a0,a0,-228 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc020283c:	8cbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0202840:	00003697          	auipc	a3,0x3
ffffffffc0202844:	f2868693          	addi	a3,a3,-216 # ffffffffc0205768 <default_pmm_manager+0x68>
ffffffffc0202848:	00002617          	auipc	a2,0x2
ffffffffc020284c:	42060613          	addi	a2,a2,1056 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202850:	09700593          	li	a1,151
ffffffffc0202854:	00003517          	auipc	a0,0x3
ffffffffc0202858:	efc50513          	addi	a0,a0,-260 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc020285c:	8abfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0202860:	00003697          	auipc	a3,0x3
ffffffffc0202864:	f0868693          	addi	a3,a3,-248 # ffffffffc0205768 <default_pmm_manager+0x68>
ffffffffc0202868:	00002617          	auipc	a2,0x2
ffffffffc020286c:	40060613          	addi	a2,a2,1024 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202870:	09500593          	li	a1,149
ffffffffc0202874:	00003517          	auipc	a0,0x3
ffffffffc0202878:	edc50513          	addi	a0,a0,-292 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc020287c:	88bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0202880:	00003697          	auipc	a3,0x3
ffffffffc0202884:	ee868693          	addi	a3,a3,-280 # ffffffffc0205768 <default_pmm_manager+0x68>
ffffffffc0202888:	00002617          	auipc	a2,0x2
ffffffffc020288c:	3e060613          	addi	a2,a2,992 # ffffffffc0204c68 <commands+0x858>
ffffffffc0202890:	09300593          	li	a1,147
ffffffffc0202894:	00003517          	auipc	a0,0x3
ffffffffc0202898:	ebc50513          	addi	a0,a0,-324 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc020289c:	86bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc02028a0:	00003697          	auipc	a3,0x3
ffffffffc02028a4:	97068693          	addi	a3,a3,-1680 # ffffffffc0205210 <commands+0xe00>
ffffffffc02028a8:	00002617          	auipc	a2,0x2
ffffffffc02028ac:	3c060613          	addi	a2,a2,960 # ffffffffc0204c68 <commands+0x858>
ffffffffc02028b0:	09100593          	li	a1,145
ffffffffc02028b4:	00003517          	auipc	a0,0x3
ffffffffc02028b8:	e9c50513          	addi	a0,a0,-356 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc02028bc:	84bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc02028c0:	00003697          	auipc	a3,0x3
ffffffffc02028c4:	95068693          	addi	a3,a3,-1712 # ffffffffc0205210 <commands+0xe00>
ffffffffc02028c8:	00002617          	auipc	a2,0x2
ffffffffc02028cc:	3a060613          	addi	a2,a2,928 # ffffffffc0204c68 <commands+0x858>
ffffffffc02028d0:	08f00593          	li	a1,143
ffffffffc02028d4:	00003517          	auipc	a0,0x3
ffffffffc02028d8:	e7c50513          	addi	a0,a0,-388 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc02028dc:	82bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc02028e0:	00003697          	auipc	a3,0x3
ffffffffc02028e4:	93068693          	addi	a3,a3,-1744 # ffffffffc0205210 <commands+0xe00>
ffffffffc02028e8:	00002617          	auipc	a2,0x2
ffffffffc02028ec:	38060613          	addi	a2,a2,896 # ffffffffc0204c68 <commands+0x858>
ffffffffc02028f0:	08d00593          	li	a1,141
ffffffffc02028f4:	00003517          	auipc	a0,0x3
ffffffffc02028f8:	e5c50513          	addi	a0,a0,-420 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc02028fc:	80bfd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202900 <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202900:	751c                	ld	a5,40(a0)
{
ffffffffc0202902:	1141                	addi	sp,sp,-16
ffffffffc0202904:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0202906:	cfa5                	beqz	a5,ffffffffc020297e <_clock_swap_out_victim+0x7e>
     assert(in_tick==0);
ffffffffc0202908:	ea39                	bnez	a2,ffffffffc020295e <_clock_swap_out_victim+0x5e>
    return listelm->prev;
ffffffffc020290a:	639c                	ld	a5,0(a5)
     while ((curr_ptr = list_prev(curr_ptr))) {
ffffffffc020290c:	0000f717          	auipc	a4,0xf
ffffffffc0202910:	c6f73623          	sd	a5,-916(a4) # ffffffffc0211578 <curr_ptr>
ffffffffc0202914:	c395                	beqz	a5,ffffffffc0202938 <_clock_swap_out_victim+0x38>
        if (p->visited==0) {
ffffffffc0202916:	fe07b703          	ld	a4,-32(a5)
        struct Page *p = le2page(curr_ptr, pra_page_link);
ffffffffc020291a:	fd078693          	addi	a3,a5,-48
        if (p->visited==0) {
ffffffffc020291e:	e709                	bnez	a4,ffffffffc0202928 <_clock_swap_out_victim+0x28>
ffffffffc0202920:	a035                	j	ffffffffc020294c <_clock_swap_out_victim+0x4c>
ffffffffc0202922:	fe07b703          	ld	a4,-32(a5)
ffffffffc0202926:	cf09                	beqz	a4,ffffffffc0202940 <_clock_swap_out_victim+0x40>
            p->visited=0;
ffffffffc0202928:	fe07b023          	sd	zero,-32(a5)
ffffffffc020292c:	639c                	ld	a5,0(a5)
     while ((curr_ptr = list_prev(curr_ptr))) {
ffffffffc020292e:	fbf5                	bnez	a5,ffffffffc0202922 <_clock_swap_out_victim+0x22>
ffffffffc0202930:	0000f797          	auipc	a5,0xf
ffffffffc0202934:	c407b423          	sd	zero,-952(a5) # ffffffffc0211578 <curr_ptr>
}
ffffffffc0202938:	60a2                	ld	ra,8(sp)
ffffffffc020293a:	4501                	li	a0,0
ffffffffc020293c:	0141                	addi	sp,sp,16
ffffffffc020293e:	8082                	ret
        struct Page *p = le2page(curr_ptr, pra_page_link);
ffffffffc0202940:	fd078693          	addi	a3,a5,-48
ffffffffc0202944:	0000f717          	auipc	a4,0xf
ffffffffc0202948:	c2f73a23          	sd	a5,-972(a4) # ffffffffc0211578 <curr_ptr>
    __list_del(listelm->prev, listelm->next);
ffffffffc020294c:	6398                	ld	a4,0(a5)
ffffffffc020294e:	679c                	ld	a5,8(a5)
}
ffffffffc0202950:	60a2                	ld	ra,8(sp)
ffffffffc0202952:	4501                	li	a0,0
    prev->next = next;
ffffffffc0202954:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202956:	e398                	sd	a4,0(a5)
        *ptr_page = le2page(curr_ptr, pra_page_link);
ffffffffc0202958:	e194                	sd	a3,0(a1)
}
ffffffffc020295a:	0141                	addi	sp,sp,16
ffffffffc020295c:	8082                	ret
     assert(in_tick==0);
ffffffffc020295e:	00003697          	auipc	a3,0x3
ffffffffc0202962:	e9a68693          	addi	a3,a3,-358 # ffffffffc02057f8 <default_pmm_manager+0xf8>
ffffffffc0202966:	00002617          	auipc	a2,0x2
ffffffffc020296a:	30260613          	addi	a2,a2,770 # ffffffffc0204c68 <commands+0x858>
ffffffffc020296e:	04d00593          	li	a1,77
ffffffffc0202972:	00003517          	auipc	a0,0x3
ffffffffc0202976:	dde50513          	addi	a0,a0,-546 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc020297a:	f8cfd0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(head != NULL);
ffffffffc020297e:	00003697          	auipc	a3,0x3
ffffffffc0202982:	e6a68693          	addi	a3,a3,-406 # ffffffffc02057e8 <default_pmm_manager+0xe8>
ffffffffc0202986:	00002617          	auipc	a2,0x2
ffffffffc020298a:	2e260613          	addi	a2,a2,738 # ffffffffc0204c68 <commands+0x858>
ffffffffc020298e:	04c00593          	li	a1,76
ffffffffc0202992:	00003517          	auipc	a0,0x3
ffffffffc0202996:	dbe50513          	addi	a0,a0,-578 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc020299a:	f6cfd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc020299e <_clock_map_swappable>:
{
ffffffffc020299e:	1141                	addi	sp,sp,-16
ffffffffc02029a0:	e406                	sd	ra,8(sp)
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc02029a2:	03060793          	addi	a5,a2,48
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02029a6:	7518                	ld	a4,40(a0)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02029a8:	cb85                	beqz	a5,ffffffffc02029d8 <_clock_map_swappable+0x3a>
ffffffffc02029aa:	0000f697          	auipc	a3,0xf
ffffffffc02029ae:	bce68693          	addi	a3,a3,-1074 # ffffffffc0211578 <curr_ptr>
ffffffffc02029b2:	628c                	ld	a1,0(a3)
ffffffffc02029b4:	c195                	beqz	a1,ffffffffc02029d8 <_clock_map_swappable+0x3a>
    __list_add(elm, listelm, listelm->next);
ffffffffc02029b6:	6714                	ld	a3,8(a4)
    cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc02029b8:	00003517          	auipc	a0,0x3
ffffffffc02029bc:	e2050513          	addi	a0,a0,-480 # ffffffffc02057d8 <default_pmm_manager+0xd8>
    prev->next = next->prev = elm;
ffffffffc02029c0:	e29c                	sd	a5,0(a3)
ffffffffc02029c2:	e71c                	sd	a5,8(a4)
    page->visited=1;
ffffffffc02029c4:	4785                	li	a5,1
    elm->next = next;
ffffffffc02029c6:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc02029c8:	fa18                	sd	a4,48(a2)
ffffffffc02029ca:	ea1c                	sd	a5,16(a2)
    cprintf("curr_ptr %p\n", curr_ptr);
ffffffffc02029cc:	ef2fd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc02029d0:	60a2                	ld	ra,8(sp)
ffffffffc02029d2:	4501                	li	a0,0
ffffffffc02029d4:	0141                	addi	sp,sp,16
ffffffffc02029d6:	8082                	ret
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02029d8:	00003697          	auipc	a3,0x3
ffffffffc02029dc:	dd868693          	addi	a3,a3,-552 # ffffffffc02057b0 <default_pmm_manager+0xb0>
ffffffffc02029e0:	00002617          	auipc	a2,0x2
ffffffffc02029e4:	28860613          	addi	a2,a2,648 # ffffffffc0204c68 <commands+0x858>
ffffffffc02029e8:	03900593          	li	a1,57
ffffffffc02029ec:	00003517          	auipc	a0,0x3
ffffffffc02029f0:	d6450513          	addi	a0,a0,-668 # ffffffffc0205750 <default_pmm_manager+0x50>
ffffffffc02029f4:	f12fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02029f8 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02029f8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02029fa:	00002617          	auipc	a2,0x2
ffffffffc02029fe:	56660613          	addi	a2,a2,1382 # ffffffffc0204f60 <commands+0xb50>
ffffffffc0202a02:	06500593          	li	a1,101
ffffffffc0202a06:	00002517          	auipc	a0,0x2
ffffffffc0202a0a:	57a50513          	addi	a0,a0,1402 # ffffffffc0204f80 <commands+0xb70>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202a0e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202a10:	ef6fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202a14 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {//分配n个连续的物理页面
ffffffffc0202a14:	715d                	addi	sp,sp,-80
ffffffffc0202a16:	e0a2                	sd	s0,64(sp)
ffffffffc0202a18:	fc26                	sd	s1,56(sp)
ffffffffc0202a1a:	f84a                	sd	s2,48(sp)
ffffffffc0202a1c:	f44e                	sd	s3,40(sp)
ffffffffc0202a1e:	f052                	sd	s4,32(sp)
ffffffffc0202a20:	ec56                	sd	s5,24(sp)
ffffffffc0202a22:	e486                	sd	ra,72(sp)
ffffffffc0202a24:	842a                	mv	s0,a0
ffffffffc0202a26:	0000f497          	auipc	s1,0xf
ffffffffc0202a2a:	b5a48493          	addi	s1,s1,-1190 # ffffffffc0211580 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a2e:	4985                	li	s3,1
ffffffffc0202a30:	0000fa17          	auipc	s4,0xf
ffffffffc0202a34:	a30a0a13          	addi	s4,s4,-1488 # ffffffffc0211460 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a38:	0005091b          	sext.w	s2,a0
ffffffffc0202a3c:	0000fa97          	auipc	s5,0xf
ffffffffc0202a40:	a44a8a93          	addi	s5,s5,-1468 # ffffffffc0211480 <check_mm_struct>
ffffffffc0202a44:	a00d                	j	ffffffffc0202a66 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202a46:	609c                	ld	a5,0(s1)
ffffffffc0202a48:	6f9c                	ld	a5,24(a5)
ffffffffc0202a4a:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a4c:	4601                	li	a2,0
ffffffffc0202a4e:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a50:	ed0d                	bnez	a0,ffffffffc0202a8a <alloc_pages+0x76>
ffffffffc0202a52:	0289ec63          	bltu	s3,s0,ffffffffc0202a8a <alloc_pages+0x76>
ffffffffc0202a56:	000a2783          	lw	a5,0(s4)
ffffffffc0202a5a:	2781                	sext.w	a5,a5
ffffffffc0202a5c:	c79d                	beqz	a5,ffffffffc0202a8a <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a5e:	000ab503          	ld	a0,0(s5)
ffffffffc0202a62:	f21fe0ef          	jal	ra,ffffffffc0201982 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a66:	100027f3          	csrr	a5,sstatus
ffffffffc0202a6a:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202a6c:	8522                	mv	a0,s0
ffffffffc0202a6e:	dfe1                	beqz	a5,ffffffffc0202a46 <alloc_pages+0x32>
        intr_disable();
ffffffffc0202a70:	a8bfd0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0202a74:	609c                	ld	a5,0(s1)
ffffffffc0202a76:	8522                	mv	a0,s0
ffffffffc0202a78:	6f9c                	ld	a5,24(a5)
ffffffffc0202a7a:	9782                	jalr	a5
ffffffffc0202a7c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202a7e:	a77fd0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc0202a82:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0202a84:	4601                	li	a2,0
ffffffffc0202a86:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202a88:	d569                	beqz	a0,ffffffffc0202a52 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202a8a:	60a6                	ld	ra,72(sp)
ffffffffc0202a8c:	6406                	ld	s0,64(sp)
ffffffffc0202a8e:	74e2                	ld	s1,56(sp)
ffffffffc0202a90:	7942                	ld	s2,48(sp)
ffffffffc0202a92:	79a2                	ld	s3,40(sp)
ffffffffc0202a94:	7a02                	ld	s4,32(sp)
ffffffffc0202a96:	6ae2                	ld	s5,24(sp)
ffffffffc0202a98:	6161                	addi	sp,sp,80
ffffffffc0202a9a:	8082                	ret

ffffffffc0202a9c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202a9c:	100027f3          	csrr	a5,sstatus
ffffffffc0202aa0:	8b89                	andi	a5,a5,2
ffffffffc0202aa2:	eb89                	bnez	a5,ffffffffc0202ab4 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0202aa4:	0000f797          	auipc	a5,0xf
ffffffffc0202aa8:	adc78793          	addi	a5,a5,-1316 # ffffffffc0211580 <pmm_manager>
ffffffffc0202aac:	639c                	ld	a5,0(a5)
ffffffffc0202aae:	0207b303          	ld	t1,32(a5)
ffffffffc0202ab2:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0202ab4:	1101                	addi	sp,sp,-32
ffffffffc0202ab6:	ec06                	sd	ra,24(sp)
ffffffffc0202ab8:	e822                	sd	s0,16(sp)
ffffffffc0202aba:	e426                	sd	s1,8(sp)
ffffffffc0202abc:	842a                	mv	s0,a0
ffffffffc0202abe:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202ac0:	a3bfd0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202ac4:	0000f797          	auipc	a5,0xf
ffffffffc0202ac8:	abc78793          	addi	a5,a5,-1348 # ffffffffc0211580 <pmm_manager>
ffffffffc0202acc:	639c                	ld	a5,0(a5)
ffffffffc0202ace:	85a6                	mv	a1,s1
ffffffffc0202ad0:	8522                	mv	a0,s0
ffffffffc0202ad2:	739c                	ld	a5,32(a5)
ffffffffc0202ad4:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202ad6:	6442                	ld	s0,16(sp)
ffffffffc0202ad8:	60e2                	ld	ra,24(sp)
ffffffffc0202ada:	64a2                	ld	s1,8(sp)
ffffffffc0202adc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202ade:	a17fd06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc0202ae2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ae2:	100027f3          	csrr	a5,sstatus
ffffffffc0202ae6:	8b89                	andi	a5,a5,2
ffffffffc0202ae8:	eb89                	bnez	a5,ffffffffc0202afa <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202aea:	0000f797          	auipc	a5,0xf
ffffffffc0202aee:	a9678793          	addi	a5,a5,-1386 # ffffffffc0211580 <pmm_manager>
ffffffffc0202af2:	639c                	ld	a5,0(a5)
ffffffffc0202af4:	0287b303          	ld	t1,40(a5)
ffffffffc0202af8:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0202afa:	1141                	addi	sp,sp,-16
ffffffffc0202afc:	e406                	sd	ra,8(sp)
ffffffffc0202afe:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202b00:	9fbfd0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202b04:	0000f797          	auipc	a5,0xf
ffffffffc0202b08:	a7c78793          	addi	a5,a5,-1412 # ffffffffc0211580 <pmm_manager>
ffffffffc0202b0c:	639c                	ld	a5,0(a5)
ffffffffc0202b0e:	779c                	ld	a5,40(a5)
ffffffffc0202b10:	9782                	jalr	a5
ffffffffc0202b12:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b14:	9e1fd0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202b18:	8522                	mv	a0,s0
ffffffffc0202b1a:	60a2                	ld	ra,8(sp)
ffffffffc0202b1c:	6402                	ld	s0,0(sp)
ffffffffc0202b1e:	0141                	addi	sp,sp,16
ffffffffc0202b20:	8082                	ret

ffffffffc0202b22 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {//根据线性地址la，找到对应的页表项，然后返回页表项对应的页表项的地址，
ffffffffc0202b22:	715d                	addi	sp,sp,-80
ffffffffc0202b24:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202b26:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0202b2a:	1ff4f493          	andi	s1,s1,511
ffffffffc0202b2e:	048e                	slli	s1,s1,0x3
ffffffffc0202b30:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b32:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {//根据线性地址la，找到对应的页表项，然后返回页表项对应的页表项的地址，
ffffffffc0202b34:	f84a                	sd	s2,48(sp)
ffffffffc0202b36:	f44e                	sd	s3,40(sp)
ffffffffc0202b38:	f052                	sd	s4,32(sp)
ffffffffc0202b3a:	e486                	sd	ra,72(sp)
ffffffffc0202b3c:	e0a2                	sd	s0,64(sp)
ffffffffc0202b3e:	ec56                	sd	s5,24(sp)
ffffffffc0202b40:	e85a                	sd	s6,16(sp)
ffffffffc0202b42:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b44:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {//根据线性地址la，找到对应的页表项，然后返回页表项对应的页表项的地址，
ffffffffc0202b48:	892e                	mv	s2,a1
ffffffffc0202b4a:	8a32                	mv	s4,a2
ffffffffc0202b4c:	0000f997          	auipc	s3,0xf
ffffffffc0202b50:	92498993          	addi	s3,s3,-1756 # ffffffffc0211470 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202b54:	e3c9                	bnez	a5,ffffffffc0202bd6 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202b56:	16060163          	beqz	a2,ffffffffc0202cb8 <get_pte+0x196>
ffffffffc0202b5a:	4505                	li	a0,1
ffffffffc0202b5c:	eb9ff0ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0202b60:	842a                	mv	s0,a0
ffffffffc0202b62:	14050b63          	beqz	a0,ffffffffc0202cb8 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b66:	0000fb97          	auipc	s7,0xf
ffffffffc0202b6a:	a32b8b93          	addi	s7,s7,-1486 # ffffffffc0211598 <pages>
ffffffffc0202b6e:	000bb503          	ld	a0,0(s7)
ffffffffc0202b72:	00003797          	auipc	a5,0x3
ffffffffc0202b76:	83678793          	addi	a5,a5,-1994 # ffffffffc02053a8 <commands+0xf98>
ffffffffc0202b7a:	0007bb03          	ld	s6,0(a5)
ffffffffc0202b7e:	40a40533          	sub	a0,s0,a0
ffffffffc0202b82:	850d                	srai	a0,a0,0x3
ffffffffc0202b84:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202b88:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202b8a:	0000f997          	auipc	s3,0xf
ffffffffc0202b8e:	8e698993          	addi	s3,s3,-1818 # ffffffffc0211470 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202b92:	00080ab7          	lui	s5,0x80
ffffffffc0202b96:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202b9a:	c01c                	sw	a5,0(s0)
ffffffffc0202b9c:	57fd                	li	a5,-1
ffffffffc0202b9e:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202ba0:	9556                	add	a0,a0,s5
ffffffffc0202ba2:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ba4:	0532                	slli	a0,a0,0xc
ffffffffc0202ba6:	16e7f063          	bleu	a4,a5,ffffffffc0202d06 <get_pte+0x1e4>
ffffffffc0202baa:	0000f797          	auipc	a5,0xf
ffffffffc0202bae:	9de78793          	addi	a5,a5,-1570 # ffffffffc0211588 <va_pa_offset>
ffffffffc0202bb2:	639c                	ld	a5,0(a5)
ffffffffc0202bb4:	6605                	lui	a2,0x1
ffffffffc0202bb6:	4581                	li	a1,0
ffffffffc0202bb8:	953e                	add	a0,a0,a5
ffffffffc0202bba:	22a010ef          	jal	ra,ffffffffc0203de4 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202bbe:	000bb683          	ld	a3,0(s7)
ffffffffc0202bc2:	40d406b3          	sub	a3,s0,a3
ffffffffc0202bc6:	868d                	srai	a3,a3,0x3
ffffffffc0202bc8:	036686b3          	mul	a3,a3,s6
ffffffffc0202bcc:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202bce:	06aa                	slli	a3,a3,0xa
ffffffffc0202bd0:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202bd4:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202bd6:	77fd                	lui	a5,0xfffff
ffffffffc0202bd8:	068a                	slli	a3,a3,0x2
ffffffffc0202bda:	0009b703          	ld	a4,0(s3)
ffffffffc0202bde:	8efd                	and	a3,a3,a5
ffffffffc0202be0:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202be4:	0ce7fc63          	bleu	a4,a5,ffffffffc0202cbc <get_pte+0x19a>
ffffffffc0202be8:	0000fa97          	auipc	s5,0xf
ffffffffc0202bec:	9a0a8a93          	addi	s5,s5,-1632 # ffffffffc0211588 <va_pa_offset>
ffffffffc0202bf0:	000ab403          	ld	s0,0(s5)
ffffffffc0202bf4:	01595793          	srli	a5,s2,0x15
ffffffffc0202bf8:	1ff7f793          	andi	a5,a5,511
ffffffffc0202bfc:	96a2                	add	a3,a3,s0
ffffffffc0202bfe:	00379413          	slli	s0,a5,0x3
ffffffffc0202c02:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202c04:	6014                	ld	a3,0(s0)
ffffffffc0202c06:	0016f793          	andi	a5,a3,1
ffffffffc0202c0a:	ebbd                	bnez	a5,ffffffffc0202c80 <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202c0c:	0a0a0663          	beqz	s4,ffffffffc0202cb8 <get_pte+0x196>
ffffffffc0202c10:	4505                	li	a0,1
ffffffffc0202c12:	e03ff0ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0202c16:	84aa                	mv	s1,a0
ffffffffc0202c18:	c145                	beqz	a0,ffffffffc0202cb8 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c1a:	0000fb97          	auipc	s7,0xf
ffffffffc0202c1e:	97eb8b93          	addi	s7,s7,-1666 # ffffffffc0211598 <pages>
ffffffffc0202c22:	000bb503          	ld	a0,0(s7)
ffffffffc0202c26:	00002797          	auipc	a5,0x2
ffffffffc0202c2a:	78278793          	addi	a5,a5,1922 # ffffffffc02053a8 <commands+0xf98>
ffffffffc0202c2e:	0007bb03          	ld	s6,0(a5)
ffffffffc0202c32:	40a48533          	sub	a0,s1,a0
ffffffffc0202c36:	850d                	srai	a0,a0,0x3
ffffffffc0202c38:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202c3c:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c3e:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202c42:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202c46:	c09c                	sw	a5,0(s1)
ffffffffc0202c48:	57fd                	li	a5,-1
ffffffffc0202c4a:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c4c:	9552                	add	a0,a0,s4
ffffffffc0202c4e:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c50:	0532                	slli	a0,a0,0xc
ffffffffc0202c52:	08e7fd63          	bleu	a4,a5,ffffffffc0202cec <get_pte+0x1ca>
ffffffffc0202c56:	000ab783          	ld	a5,0(s5)
ffffffffc0202c5a:	6605                	lui	a2,0x1
ffffffffc0202c5c:	4581                	li	a1,0
ffffffffc0202c5e:	953e                	add	a0,a0,a5
ffffffffc0202c60:	184010ef          	jal	ra,ffffffffc0203de4 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c64:	000bb683          	ld	a3,0(s7)
ffffffffc0202c68:	40d486b3          	sub	a3,s1,a3
ffffffffc0202c6c:	868d                	srai	a3,a3,0x3
ffffffffc0202c6e:	036686b3          	mul	a3,a3,s6
ffffffffc0202c72:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202c74:	06aa                	slli	a3,a3,0xa
ffffffffc0202c76:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202c7a:	e014                	sd	a3,0(s0)
ffffffffc0202c7c:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202c80:	068a                	slli	a3,a3,0x2
ffffffffc0202c82:	757d                	lui	a0,0xfffff
ffffffffc0202c84:	8ee9                	and	a3,a3,a0
ffffffffc0202c86:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202c8a:	04e7f563          	bleu	a4,a5,ffffffffc0202cd4 <get_pte+0x1b2>
ffffffffc0202c8e:	000ab503          	ld	a0,0(s5)
ffffffffc0202c92:	00c95793          	srli	a5,s2,0xc
ffffffffc0202c96:	1ff7f793          	andi	a5,a5,511
ffffffffc0202c9a:	96aa                	add	a3,a3,a0
ffffffffc0202c9c:	00379513          	slli	a0,a5,0x3
ffffffffc0202ca0:	9536                	add	a0,a0,a3
}
ffffffffc0202ca2:	60a6                	ld	ra,72(sp)
ffffffffc0202ca4:	6406                	ld	s0,64(sp)
ffffffffc0202ca6:	74e2                	ld	s1,56(sp)
ffffffffc0202ca8:	7942                	ld	s2,48(sp)
ffffffffc0202caa:	79a2                	ld	s3,40(sp)
ffffffffc0202cac:	7a02                	ld	s4,32(sp)
ffffffffc0202cae:	6ae2                	ld	s5,24(sp)
ffffffffc0202cb0:	6b42                	ld	s6,16(sp)
ffffffffc0202cb2:	6ba2                	ld	s7,8(sp)
ffffffffc0202cb4:	6161                	addi	sp,sp,80
ffffffffc0202cb6:	8082                	ret
            return NULL;
ffffffffc0202cb8:	4501                	li	a0,0
ffffffffc0202cba:	b7e5                	j	ffffffffc0202ca2 <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202cbc:	00003617          	auipc	a2,0x3
ffffffffc0202cc0:	b6460613          	addi	a2,a2,-1180 # ffffffffc0205820 <default_pmm_manager+0x120>
ffffffffc0202cc4:	10200593          	li	a1,258
ffffffffc0202cc8:	00003517          	auipc	a0,0x3
ffffffffc0202ccc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0202cd0:	c36fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202cd4:	00003617          	auipc	a2,0x3
ffffffffc0202cd8:	b4c60613          	addi	a2,a2,-1204 # ffffffffc0205820 <default_pmm_manager+0x120>
ffffffffc0202cdc:	10f00593          	li	a1,271
ffffffffc0202ce0:	00003517          	auipc	a0,0x3
ffffffffc0202ce4:	b6850513          	addi	a0,a0,-1176 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0202ce8:	c1efd0ef          	jal	ra,ffffffffc0200106 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202cec:	86aa                	mv	a3,a0
ffffffffc0202cee:	00003617          	auipc	a2,0x3
ffffffffc0202cf2:	b3260613          	addi	a2,a2,-1230 # ffffffffc0205820 <default_pmm_manager+0x120>
ffffffffc0202cf6:	10b00593          	li	a1,267
ffffffffc0202cfa:	00003517          	auipc	a0,0x3
ffffffffc0202cfe:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0202d02:	c04fd0ef          	jal	ra,ffffffffc0200106 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202d06:	86aa                	mv	a3,a0
ffffffffc0202d08:	00003617          	auipc	a2,0x3
ffffffffc0202d0c:	b1860613          	addi	a2,a2,-1256 # ffffffffc0205820 <default_pmm_manager+0x120>
ffffffffc0202d10:	0ff00593          	li	a1,255
ffffffffc0202d14:	00003517          	auipc	a0,0x3
ffffffffc0202d18:	b3450513          	addi	a0,a0,-1228 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0202d1c:	beafd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202d20 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {//根据线性地址la，找到对应的页表项，然后返回页表项对应的页表项的地址
ffffffffc0202d20:	1141                	addi	sp,sp,-16
ffffffffc0202d22:	e022                	sd	s0,0(sp)
ffffffffc0202d24:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d26:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {//根据线性地址la，找到对应的页表项，然后返回页表项对应的页表项的地址
ffffffffc0202d28:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d2a:	df9ff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202d2e:	c011                	beqz	s0,ffffffffc0202d32 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202d30:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d32:	c521                	beqz	a0,ffffffffc0202d7a <get_page+0x5a>
ffffffffc0202d34:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202d36:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202d38:	0017f713          	andi	a4,a5,1
ffffffffc0202d3c:	e709                	bnez	a4,ffffffffc0202d46 <get_page+0x26>
}
ffffffffc0202d3e:	60a2                	ld	ra,8(sp)
ffffffffc0202d40:	6402                	ld	s0,0(sp)
ffffffffc0202d42:	0141                	addi	sp,sp,16
ffffffffc0202d44:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202d46:	0000e717          	auipc	a4,0xe
ffffffffc0202d4a:	72a70713          	addi	a4,a4,1834 # ffffffffc0211470 <npage>
ffffffffc0202d4e:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d50:	078a                	slli	a5,a5,0x2
ffffffffc0202d52:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d54:	02e7f863          	bleu	a4,a5,ffffffffc0202d84 <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d58:	fff80537          	lui	a0,0xfff80
ffffffffc0202d5c:	97aa                	add	a5,a5,a0
ffffffffc0202d5e:	0000f697          	auipc	a3,0xf
ffffffffc0202d62:	83a68693          	addi	a3,a3,-1990 # ffffffffc0211598 <pages>
ffffffffc0202d66:	6288                	ld	a0,0(a3)
ffffffffc0202d68:	60a2                	ld	ra,8(sp)
ffffffffc0202d6a:	6402                	ld	s0,0(sp)
ffffffffc0202d6c:	00379713          	slli	a4,a5,0x3
ffffffffc0202d70:	97ba                	add	a5,a5,a4
ffffffffc0202d72:	078e                	slli	a5,a5,0x3
ffffffffc0202d74:	953e                	add	a0,a0,a5
ffffffffc0202d76:	0141                	addi	sp,sp,16
ffffffffc0202d78:	8082                	ret
ffffffffc0202d7a:	60a2                	ld	ra,8(sp)
ffffffffc0202d7c:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0202d7e:	4501                	li	a0,0
}
ffffffffc0202d80:	0141                	addi	sp,sp,16
ffffffffc0202d82:	8082                	ret
ffffffffc0202d84:	c75ff0ef          	jal	ra,ffffffffc02029f8 <pa2page.part.4>

ffffffffc0202d88 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202d88:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d8a:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202d8c:	e406                	sd	ra,8(sp)
ffffffffc0202d8e:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202d90:	d93ff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
    if (ptep != NULL) {
ffffffffc0202d94:	c511                	beqz	a0,ffffffffc0202da0 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202d96:	611c                	ld	a5,0(a0)
ffffffffc0202d98:	842a                	mv	s0,a0
ffffffffc0202d9a:	0017f713          	andi	a4,a5,1
ffffffffc0202d9e:	e709                	bnez	a4,ffffffffc0202da8 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202da0:	60a2                	ld	ra,8(sp)
ffffffffc0202da2:	6402                	ld	s0,0(sp)
ffffffffc0202da4:	0141                	addi	sp,sp,16
ffffffffc0202da6:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202da8:	0000e717          	auipc	a4,0xe
ffffffffc0202dac:	6c870713          	addi	a4,a4,1736 # ffffffffc0211470 <npage>
ffffffffc0202db0:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202db2:	078a                	slli	a5,a5,0x2
ffffffffc0202db4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202db6:	04e7f063          	bleu	a4,a5,ffffffffc0202df6 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dba:	fff80737          	lui	a4,0xfff80
ffffffffc0202dbe:	97ba                	add	a5,a5,a4
ffffffffc0202dc0:	0000e717          	auipc	a4,0xe
ffffffffc0202dc4:	7d870713          	addi	a4,a4,2008 # ffffffffc0211598 <pages>
ffffffffc0202dc8:	6308                	ld	a0,0(a4)
ffffffffc0202dca:	00379713          	slli	a4,a5,0x3
ffffffffc0202dce:	97ba                	add	a5,a5,a4
ffffffffc0202dd0:	078e                	slli	a5,a5,0x3
ffffffffc0202dd2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202dd4:	411c                	lw	a5,0(a0)
ffffffffc0202dd6:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202dda:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202ddc:	cb09                	beqz	a4,ffffffffc0202dee <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202dde:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202de2:	12000073          	sfence.vma
}
ffffffffc0202de6:	60a2                	ld	ra,8(sp)
ffffffffc0202de8:	6402                	ld	s0,0(sp)
ffffffffc0202dea:	0141                	addi	sp,sp,16
ffffffffc0202dec:	8082                	ret
            free_page(page);
ffffffffc0202dee:	4585                	li	a1,1
ffffffffc0202df0:	cadff0ef          	jal	ra,ffffffffc0202a9c <free_pages>
ffffffffc0202df4:	b7ed                	j	ffffffffc0202dde <page_remove+0x56>
ffffffffc0202df6:	c03ff0ef          	jal	ra,ffffffffc02029f8 <pa2page.part.4>

ffffffffc0202dfa <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202dfa:	7179                	addi	sp,sp,-48
ffffffffc0202dfc:	87b2                	mv	a5,a2
ffffffffc0202dfe:	f022                	sd	s0,32(sp)
    //pgdir是页表基址(satp)，page对应物理页面，la是虚拟地址，perm是权限
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e00:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e02:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e04:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202e06:	ec26                	sd	s1,24(sp)
ffffffffc0202e08:	f406                	sd	ra,40(sp)
ffffffffc0202e0a:	e84a                	sd	s2,16(sp)
ffffffffc0202e0c:	e44e                	sd	s3,8(sp)
ffffffffc0202e0e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202e10:	d13ff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
    if (ptep == NULL) {
ffffffffc0202e14:	c945                	beqz	a0,ffffffffc0202ec4 <page_insert+0xca>
    page->ref += 1;
ffffffffc0202e16:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);//指向这个物理页面的虚拟地址增加了一个
    if (*ptep & PTE_V) { //原先存在映射
ffffffffc0202e18:	611c                	ld	a5,0(a0)
ffffffffc0202e1a:	892a                	mv	s2,a0
ffffffffc0202e1c:	0016871b          	addiw	a4,a3,1
ffffffffc0202e20:	c018                	sw	a4,0(s0)
ffffffffc0202e22:	0017f713          	andi	a4,a5,1
ffffffffc0202e26:	e339                	bnez	a4,ffffffffc0202e6c <page_insert+0x72>
ffffffffc0202e28:	0000e797          	auipc	a5,0xe
ffffffffc0202e2c:	77078793          	addi	a5,a5,1904 # ffffffffc0211598 <pages>
ffffffffc0202e30:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202e32:	00002717          	auipc	a4,0x2
ffffffffc0202e36:	57670713          	addi	a4,a4,1398 # ffffffffc02053a8 <commands+0xf98>
ffffffffc0202e3a:	40f407b3          	sub	a5,s0,a5
ffffffffc0202e3e:	6300                	ld	s0,0(a4)
ffffffffc0202e40:	878d                	srai	a5,a5,0x3
ffffffffc0202e42:	000806b7          	lui	a3,0x80
ffffffffc0202e46:	028787b3          	mul	a5,a5,s0
ffffffffc0202e4a:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202e4c:	07aa                	slli	a5,a5,0xa
ffffffffc0202e4e:	8fc5                	or	a5,a5,s1
ffffffffc0202e50:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {//如果原先这个虚拟地址映射到其他物理页面，那么需要删除映射
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);//构造页表项
ffffffffc0202e54:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e58:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);//页表改变之后要刷新TLB
    return 0;
ffffffffc0202e5c:	4501                	li	a0,0
}
ffffffffc0202e5e:	70a2                	ld	ra,40(sp)
ffffffffc0202e60:	7402                	ld	s0,32(sp)
ffffffffc0202e62:	64e2                	ld	s1,24(sp)
ffffffffc0202e64:	6942                	ld	s2,16(sp)
ffffffffc0202e66:	69a2                	ld	s3,8(sp)
ffffffffc0202e68:	6145                	addi	sp,sp,48
ffffffffc0202e6a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202e6c:	0000e717          	auipc	a4,0xe
ffffffffc0202e70:	60470713          	addi	a4,a4,1540 # ffffffffc0211470 <npage>
ffffffffc0202e74:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e76:	00279513          	slli	a0,a5,0x2
ffffffffc0202e7a:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e7c:	04e57663          	bleu	a4,a0,ffffffffc0202ec8 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e80:	fff807b7          	lui	a5,0xfff80
ffffffffc0202e84:	953e                	add	a0,a0,a5
ffffffffc0202e86:	0000e997          	auipc	s3,0xe
ffffffffc0202e8a:	71298993          	addi	s3,s3,1810 # ffffffffc0211598 <pages>
ffffffffc0202e8e:	0009b783          	ld	a5,0(s3)
ffffffffc0202e92:	00351713          	slli	a4,a0,0x3
ffffffffc0202e96:	953a                	add	a0,a0,a4
ffffffffc0202e98:	050e                	slli	a0,a0,0x3
ffffffffc0202e9a:	953e                	add	a0,a0,a5
        if (p == page) {//如果这个映射原先就有
ffffffffc0202e9c:	00a40e63          	beq	s0,a0,ffffffffc0202eb8 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0202ea0:	411c                	lw	a5,0(a0)
ffffffffc0202ea2:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202ea6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202ea8:	cb11                	beqz	a4,ffffffffc0202ebc <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202eaa:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202eae:	12000073          	sfence.vma
ffffffffc0202eb2:	0009b783          	ld	a5,0(s3)
ffffffffc0202eb6:	bfb5                	j	ffffffffc0202e32 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0202eb8:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202eba:	bfa5                	j	ffffffffc0202e32 <page_insert+0x38>
            free_page(page);
ffffffffc0202ebc:	4585                	li	a1,1
ffffffffc0202ebe:	bdfff0ef          	jal	ra,ffffffffc0202a9c <free_pages>
ffffffffc0202ec2:	b7e5                	j	ffffffffc0202eaa <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0202ec4:	5571                	li	a0,-4
ffffffffc0202ec6:	bf61                	j	ffffffffc0202e5e <page_insert+0x64>
ffffffffc0202ec8:	b31ff0ef          	jal	ra,ffffffffc02029f8 <pa2page.part.4>

ffffffffc0202ecc <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202ecc:	00003797          	auipc	a5,0x3
ffffffffc0202ed0:	83478793          	addi	a5,a5,-1996 # ffffffffc0205700 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202ed4:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202ed6:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202ed8:	00003517          	auipc	a0,0x3
ffffffffc0202edc:	9d850513          	addi	a0,a0,-1576 # ffffffffc02058b0 <default_pmm_manager+0x1b0>
void pmm_init(void) {
ffffffffc0202ee0:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202ee2:	0000e717          	auipc	a4,0xe
ffffffffc0202ee6:	68f73f23          	sd	a5,1694(a4) # ffffffffc0211580 <pmm_manager>
void pmm_init(void) {
ffffffffc0202eea:	e8a2                	sd	s0,80(sp)
ffffffffc0202eec:	e4a6                	sd	s1,72(sp)
ffffffffc0202eee:	e0ca                	sd	s2,64(sp)
ffffffffc0202ef0:	fc4e                	sd	s3,56(sp)
ffffffffc0202ef2:	f852                	sd	s4,48(sp)
ffffffffc0202ef4:	f456                	sd	s5,40(sp)
ffffffffc0202ef6:	f05a                	sd	s6,32(sp)
ffffffffc0202ef8:	ec5e                	sd	s7,24(sp)
ffffffffc0202efa:	e862                	sd	s8,16(sp)
ffffffffc0202efc:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202efe:	0000e417          	auipc	s0,0xe
ffffffffc0202f02:	68240413          	addi	s0,s0,1666 # ffffffffc0211580 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202f06:	9b8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0202f0a:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f0c:	49c5                	li	s3,17
ffffffffc0202f0e:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0202f12:	679c                	ld	a5,8(a5)
ffffffffc0202f14:	0000e497          	auipc	s1,0xe
ffffffffc0202f18:	55c48493          	addi	s1,s1,1372 # ffffffffc0211470 <npage>
ffffffffc0202f1c:	0000e917          	auipc	s2,0xe
ffffffffc0202f20:	67c90913          	addi	s2,s2,1660 # ffffffffc0211598 <pages>
ffffffffc0202f24:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f26:	57f5                	li	a5,-3
ffffffffc0202f28:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f2a:	07e006b7          	lui	a3,0x7e00
ffffffffc0202f2e:	01b99613          	slli	a2,s3,0x1b
ffffffffc0202f32:	015a1593          	slli	a1,s4,0x15
ffffffffc0202f36:	00003517          	auipc	a0,0x3
ffffffffc0202f3a:	99250513          	addi	a0,a0,-1646 # ffffffffc02058c8 <default_pmm_manager+0x1c8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202f3e:	0000e717          	auipc	a4,0xe
ffffffffc0202f42:	64f73523          	sd	a5,1610(a4) # ffffffffc0211588 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0202f46:	978fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0202f4a:	00003517          	auipc	a0,0x3
ffffffffc0202f4e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc02058f8 <default_pmm_manager+0x1f8>
ffffffffc0202f52:	96cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202f56:	01b99693          	slli	a3,s3,0x1b
ffffffffc0202f5a:	16fd                	addi	a3,a3,-1
ffffffffc0202f5c:	015a1613          	slli	a2,s4,0x15
ffffffffc0202f60:	07e005b7          	lui	a1,0x7e00
ffffffffc0202f64:	00003517          	auipc	a0,0x3
ffffffffc0202f68:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0205910 <default_pmm_manager+0x210>
ffffffffc0202f6c:	952fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202f70:	777d                	lui	a4,0xfffff
ffffffffc0202f72:	0000f797          	auipc	a5,0xf
ffffffffc0202f76:	62d78793          	addi	a5,a5,1581 # ffffffffc021259f <end+0xfff>
ffffffffc0202f7a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202f7c:	00088737          	lui	a4,0x88
ffffffffc0202f80:	0000e697          	auipc	a3,0xe
ffffffffc0202f84:	4ee6b823          	sd	a4,1264(a3) # ffffffffc0211470 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202f88:	0000e717          	auipc	a4,0xe
ffffffffc0202f8c:	60f73823          	sd	a5,1552(a4) # ffffffffc0211598 <pages>
ffffffffc0202f90:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202f92:	4701                	li	a4,0
ffffffffc0202f94:	4585                	li	a1,1
ffffffffc0202f96:	fff80637          	lui	a2,0xfff80
ffffffffc0202f9a:	a019                	j	ffffffffc0202fa0 <pmm_init+0xd4>
ffffffffc0202f9c:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0202fa0:	97b6                	add	a5,a5,a3
ffffffffc0202fa2:	07a1                	addi	a5,a5,8
ffffffffc0202fa4:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202fa8:	609c                	ld	a5,0(s1)
ffffffffc0202faa:	0705                	addi	a4,a4,1
ffffffffc0202fac:	04868693          	addi	a3,a3,72
ffffffffc0202fb0:	00c78533          	add	a0,a5,a2
ffffffffc0202fb4:	fea764e3          	bltu	a4,a0,ffffffffc0202f9c <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202fb8:	00093503          	ld	a0,0(s2)
ffffffffc0202fbc:	00379693          	slli	a3,a5,0x3
ffffffffc0202fc0:	96be                	add	a3,a3,a5
ffffffffc0202fc2:	fdc00737          	lui	a4,0xfdc00
ffffffffc0202fc6:	972a                	add	a4,a4,a0
ffffffffc0202fc8:	068e                	slli	a3,a3,0x3
ffffffffc0202fca:	96ba                	add	a3,a3,a4
ffffffffc0202fcc:	c0200737          	lui	a4,0xc0200
ffffffffc0202fd0:	58e6ea63          	bltu	a3,a4,ffffffffc0203564 <pmm_init+0x698>
ffffffffc0202fd4:	0000e997          	auipc	s3,0xe
ffffffffc0202fd8:	5b498993          	addi	s3,s3,1460 # ffffffffc0211588 <va_pa_offset>
ffffffffc0202fdc:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0202fe0:	45c5                	li	a1,17
ffffffffc0202fe2:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202fe4:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0202fe6:	44b6ef63          	bltu	a3,a1,ffffffffc0203444 <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202fea:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202fec:	0000e417          	auipc	s0,0xe
ffffffffc0202ff0:	47c40413          	addi	s0,s0,1148 # ffffffffc0211468 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202ff4:	7b9c                	ld	a5,48(a5)
ffffffffc0202ff6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202ff8:	00003517          	auipc	a0,0x3
ffffffffc0202ffc:	96850513          	addi	a0,a0,-1688 # ffffffffc0205960 <default_pmm_manager+0x260>
ffffffffc0203000:	8befd0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203004:	00006697          	auipc	a3,0x6
ffffffffc0203008:	ffc68693          	addi	a3,a3,-4 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc020300c:	0000e797          	auipc	a5,0xe
ffffffffc0203010:	44d7be23          	sd	a3,1116(a5) # ffffffffc0211468 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203014:	c02007b7          	lui	a5,0xc0200
ffffffffc0203018:	0ef6ece3          	bltu	a3,a5,ffffffffc0203910 <pmm_init+0xa44>
ffffffffc020301c:	0009b783          	ld	a5,0(s3)
ffffffffc0203020:	8e9d                	sub	a3,a3,a5
ffffffffc0203022:	0000e797          	auipc	a5,0xe
ffffffffc0203026:	56d7b723          	sd	a3,1390(a5) # ffffffffc0211590 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc020302a:	ab9ff0ef          	jal	ra,ffffffffc0202ae2 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020302e:	6098                	ld	a4,0(s1)
ffffffffc0203030:	c80007b7          	lui	a5,0xc8000
ffffffffc0203034:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0203036:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203038:	0ae7ece3          	bltu	a5,a4,ffffffffc02038f0 <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);//boot_pgdir是页表的虚拟地址，所以它的低12位应该是0
ffffffffc020303c:	6008                	ld	a0,0(s0)
ffffffffc020303e:	4c050363          	beqz	a0,ffffffffc0203504 <pmm_init+0x638>
ffffffffc0203042:	6785                	lui	a5,0x1
ffffffffc0203044:	17fd                	addi	a5,a5,-1
ffffffffc0203046:	8fe9                	and	a5,a5,a0
ffffffffc0203048:	2781                	sext.w	a5,a5
ffffffffc020304a:	4a079d63          	bnez	a5,ffffffffc0203504 <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020304e:	4601                	li	a2,0
ffffffffc0203050:	4581                	li	a1,0
ffffffffc0203052:	ccfff0ef          	jal	ra,ffffffffc0202d20 <get_page>
ffffffffc0203056:	4c051763          	bnez	a0,ffffffffc0203524 <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc020305a:	4505                	li	a0,1
ffffffffc020305c:	9b9ff0ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc0203060:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);//page_insert()，在页表里建立一个映射
ffffffffc0203062:	6008                	ld	a0,0(s0)
ffffffffc0203064:	4681                	li	a3,0
ffffffffc0203066:	4601                	li	a2,0
ffffffffc0203068:	85d6                	mv	a1,s5
ffffffffc020306a:	d91ff0ef          	jal	ra,ffffffffc0202dfa <page_insert>
ffffffffc020306e:	52051763          	bnez	a0,ffffffffc020359c <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203072:	6008                	ld	a0,0(s0)
ffffffffc0203074:	4601                	li	a2,0
ffffffffc0203076:	4581                	li	a1,0
ffffffffc0203078:	aabff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
ffffffffc020307c:	50050063          	beqz	a0,ffffffffc020357c <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0203080:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203082:	0017f713          	andi	a4,a5,1
ffffffffc0203086:	46070363          	beqz	a4,ffffffffc02034ec <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc020308a:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020308c:	078a                	slli	a5,a5,0x2
ffffffffc020308e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203090:	44c7f063          	bleu	a2,a5,ffffffffc02034d0 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0203094:	fff80737          	lui	a4,0xfff80
ffffffffc0203098:	97ba                	add	a5,a5,a4
ffffffffc020309a:	00379713          	slli	a4,a5,0x3
ffffffffc020309e:	00093683          	ld	a3,0(s2)
ffffffffc02030a2:	97ba                	add	a5,a5,a4
ffffffffc02030a4:	078e                	slli	a5,a5,0x3
ffffffffc02030a6:	97b6                	add	a5,a5,a3
ffffffffc02030a8:	5efa9463          	bne	s5,a5,ffffffffc0203690 <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc02030ac:	000aab83          	lw	s7,0(s5)
ffffffffc02030b0:	4785                	li	a5,1
ffffffffc02030b2:	5afb9f63          	bne	s7,a5,ffffffffc0203670 <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02030b6:	6008                	ld	a0,0(s0)
ffffffffc02030b8:	76fd                	lui	a3,0xfffff
ffffffffc02030ba:	611c                	ld	a5,0(a0)
ffffffffc02030bc:	078a                	slli	a5,a5,0x2
ffffffffc02030be:	8ff5                	and	a5,a5,a3
ffffffffc02030c0:	00c7d713          	srli	a4,a5,0xc
ffffffffc02030c4:	58c77963          	bleu	a2,a4,ffffffffc0203656 <pmm_init+0x78a>
ffffffffc02030c8:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030cc:	97e2                	add	a5,a5,s8
ffffffffc02030ce:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02030d2:	0b0a                	slli	s6,s6,0x2
ffffffffc02030d4:	00db7b33          	and	s6,s6,a3
ffffffffc02030d8:	00cb5793          	srli	a5,s6,0xc
ffffffffc02030dc:	56c7f063          	bleu	a2,a5,ffffffffc020363c <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02030e0:	4601                	li	a2,0
ffffffffc02030e2:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030e4:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02030e6:	a3dff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030ea:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02030ec:	53651863          	bne	a0,s6,ffffffffc020361c <pmm_init+0x750>
    //get_pte查找某个虚拟地址对应的页表项，如果不存在这个页表项，会为它分配各级的页表
    //get_pte()函数的第三个参数create，如果为1，表示如果页表项不存在，就创建一个页表项

    p2 = alloc_page();
ffffffffc02030f0:	4505                	li	a0,1
ffffffffc02030f2:	923ff0ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc02030f6:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02030f8:	6008                	ld	a0,0(s0)
ffffffffc02030fa:	46d1                	li	a3,20
ffffffffc02030fc:	6605                	lui	a2,0x1
ffffffffc02030fe:	85da                	mv	a1,s6
ffffffffc0203100:	cfbff0ef          	jal	ra,ffffffffc0202dfa <page_insert>
ffffffffc0203104:	4e051c63          	bnez	a0,ffffffffc02035fc <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203108:	6008                	ld	a0,0(s0)
ffffffffc020310a:	4601                	li	a2,0
ffffffffc020310c:	6585                	lui	a1,0x1
ffffffffc020310e:	a15ff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
ffffffffc0203112:	4c050563          	beqz	a0,ffffffffc02035dc <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc0203116:	611c                	ld	a5,0(a0)
ffffffffc0203118:	0107f713          	andi	a4,a5,16
ffffffffc020311c:	4a070063          	beqz	a4,ffffffffc02035bc <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0203120:	8b91                	andi	a5,a5,4
ffffffffc0203122:	66078763          	beqz	a5,ffffffffc0203790 <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203126:	6008                	ld	a0,0(s0)
ffffffffc0203128:	611c                	ld	a5,0(a0)
ffffffffc020312a:	8bc1                	andi	a5,a5,16
ffffffffc020312c:	64078263          	beqz	a5,ffffffffc0203770 <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0203130:	000b2783          	lw	a5,0(s6)
ffffffffc0203134:	61779e63          	bne	a5,s7,ffffffffc0203750 <pmm_init+0x884>
    //page_ref()函数用来检查映射关系是否实现，这个函数会返回一个物理页面被多少个虚拟页面所对应。

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203138:	4681                	li	a3,0
ffffffffc020313a:	6605                	lui	a2,0x1
ffffffffc020313c:	85d6                	mv	a1,s5
ffffffffc020313e:	cbdff0ef          	jal	ra,ffffffffc0202dfa <page_insert>
ffffffffc0203142:	5e051763          	bnez	a0,ffffffffc0203730 <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc0203146:	000aa703          	lw	a4,0(s5)
ffffffffc020314a:	4789                	li	a5,2
ffffffffc020314c:	5cf71263          	bne	a4,a5,ffffffffc0203710 <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0203150:	000b2783          	lw	a5,0(s6)
ffffffffc0203154:	58079e63          	bnez	a5,ffffffffc02036f0 <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203158:	6008                	ld	a0,0(s0)
ffffffffc020315a:	4601                	li	a2,0
ffffffffc020315c:	6585                	lui	a1,0x1
ffffffffc020315e:	9c5ff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
ffffffffc0203162:	56050763          	beqz	a0,ffffffffc02036d0 <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc0203166:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203168:	0016f793          	andi	a5,a3,1
ffffffffc020316c:	38078063          	beqz	a5,ffffffffc02034ec <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0203170:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203172:	00269793          	slli	a5,a3,0x2
ffffffffc0203176:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203178:	34e7fc63          	bleu	a4,a5,ffffffffc02034d0 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020317c:	fff80737          	lui	a4,0xfff80
ffffffffc0203180:	97ba                	add	a5,a5,a4
ffffffffc0203182:	00379713          	slli	a4,a5,0x3
ffffffffc0203186:	00093603          	ld	a2,0(s2)
ffffffffc020318a:	97ba                	add	a5,a5,a4
ffffffffc020318c:	078e                	slli	a5,a5,0x3
ffffffffc020318e:	97b2                	add	a5,a5,a2
ffffffffc0203190:	52fa9063          	bne	s5,a5,ffffffffc02036b0 <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203194:	8ac1                	andi	a3,a3,16
ffffffffc0203196:	6e069d63          	bnez	a3,ffffffffc0203890 <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc020319a:	6008                	ld	a0,0(s0)
ffffffffc020319c:	4581                	li	a1,0
ffffffffc020319e:	bebff0ef          	jal	ra,ffffffffc0202d88 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02031a2:	000aa703          	lw	a4,0(s5)
ffffffffc02031a6:	4785                	li	a5,1
ffffffffc02031a8:	6cf71463          	bne	a4,a5,ffffffffc0203870 <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc02031ac:	000b2783          	lw	a5,0(s6)
ffffffffc02031b0:	6a079063          	bnez	a5,ffffffffc0203850 <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02031b4:	6008                	ld	a0,0(s0)
ffffffffc02031b6:	6585                	lui	a1,0x1
ffffffffc02031b8:	bd1ff0ef          	jal	ra,ffffffffc0202d88 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02031bc:	000aa783          	lw	a5,0(s5)
ffffffffc02031c0:	66079863          	bnez	a5,ffffffffc0203830 <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc02031c4:	000b2783          	lw	a5,0(s6)
ffffffffc02031c8:	70079463          	bnez	a5,ffffffffc02038d0 <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02031cc:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02031d0:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02031d2:	000b3783          	ld	a5,0(s6)
ffffffffc02031d6:	078a                	slli	a5,a5,0x2
ffffffffc02031d8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031da:	2eb7fb63          	bleu	a1,a5,ffffffffc02034d0 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02031de:	fff80737          	lui	a4,0xfff80
ffffffffc02031e2:	973e                	add	a4,a4,a5
ffffffffc02031e4:	00371793          	slli	a5,a4,0x3
ffffffffc02031e8:	00093603          	ld	a2,0(s2)
ffffffffc02031ec:	97ba                	add	a5,a5,a4
ffffffffc02031ee:	078e                	slli	a5,a5,0x3
ffffffffc02031f0:	00f60733          	add	a4,a2,a5
ffffffffc02031f4:	4314                	lw	a3,0(a4)
ffffffffc02031f6:	4705                	li	a4,1
ffffffffc02031f8:	6ae69c63          	bne	a3,a4,ffffffffc02038b0 <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02031fc:	00002a97          	auipc	s5,0x2
ffffffffc0203200:	1aca8a93          	addi	s5,s5,428 # ffffffffc02053a8 <commands+0xf98>
ffffffffc0203204:	000ab703          	ld	a4,0(s5)
ffffffffc0203208:	4037d693          	srai	a3,a5,0x3
ffffffffc020320c:	00080bb7          	lui	s7,0x80
ffffffffc0203210:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203214:	577d                	li	a4,-1
ffffffffc0203216:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203218:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020321a:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020321c:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020321e:	2ab77b63          	bleu	a1,a4,ffffffffc02034d4 <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0203222:	0009b783          	ld	a5,0(s3)
ffffffffc0203226:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203228:	629c                	ld	a5,0(a3)
ffffffffc020322a:	078a                	slli	a5,a5,0x2
ffffffffc020322c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020322e:	2ab7f163          	bleu	a1,a5,ffffffffc02034d0 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0203232:	417787b3          	sub	a5,a5,s7
ffffffffc0203236:	00379513          	slli	a0,a5,0x3
ffffffffc020323a:	97aa                	add	a5,a5,a0
ffffffffc020323c:	00379513          	slli	a0,a5,0x3
ffffffffc0203240:	9532                	add	a0,a0,a2
ffffffffc0203242:	4585                	li	a1,1
ffffffffc0203244:	859ff0ef          	jal	ra,ffffffffc0202a9c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203248:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020324c:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020324e:	050a                	slli	a0,a0,0x2
ffffffffc0203250:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203252:	26f57f63          	bleu	a5,a0,ffffffffc02034d0 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0203256:	417507b3          	sub	a5,a0,s7
ffffffffc020325a:	00379513          	slli	a0,a5,0x3
ffffffffc020325e:	00093703          	ld	a4,0(s2)
ffffffffc0203262:	953e                	add	a0,a0,a5
ffffffffc0203264:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0203266:	4585                	li	a1,1
ffffffffc0203268:	953a                	add	a0,a0,a4
ffffffffc020326a:	833ff0ef          	jal	ra,ffffffffc0202a9c <free_pages>
    boot_pgdir[0] = 0;//清除测试的痕迹
ffffffffc020326e:	601c                	ld	a5,0(s0)
ffffffffc0203270:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0203274:	86fff0ef          	jal	ra,ffffffffc0202ae2 <nr_free_pages>
ffffffffc0203278:	2caa1663          	bne	s4,a0,ffffffffc0203544 <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020327c:	00003517          	auipc	a0,0x3
ffffffffc0203280:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0205c48 <default_pmm_manager+0x548>
ffffffffc0203284:	e3bfc0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0203288:	85bff0ef          	jal	ra,ffffffffc0202ae2 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020328c:	6098                	ld	a4,0(s1)
ffffffffc020328e:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0203292:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203294:	00c71693          	slli	a3,a4,0xc
ffffffffc0203298:	1cd7fd63          	bleu	a3,a5,ffffffffc0203472 <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020329c:	83b1                	srli	a5,a5,0xc
ffffffffc020329e:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02032a0:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02032a4:	1ce7f963          	bleu	a4,a5,ffffffffc0203476 <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02032a8:	7c7d                	lui	s8,0xfffff
ffffffffc02032aa:	6b85                	lui	s7,0x1
ffffffffc02032ac:	a029                	j	ffffffffc02032b6 <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02032ae:	00ca5713          	srli	a4,s4,0xc
ffffffffc02032b2:	1cf77263          	bleu	a5,a4,ffffffffc0203476 <pmm_init+0x5aa>
ffffffffc02032b6:	0009b583          	ld	a1,0(s3)
ffffffffc02032ba:	4601                	li	a2,0
ffffffffc02032bc:	95d2                	add	a1,a1,s4
ffffffffc02032be:	865ff0ef          	jal	ra,ffffffffc0202b22 <get_pte>
ffffffffc02032c2:	1c050763          	beqz	a0,ffffffffc0203490 <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02032c6:	611c                	ld	a5,0(a0)
ffffffffc02032c8:	078a                	slli	a5,a5,0x2
ffffffffc02032ca:	0187f7b3          	and	a5,a5,s8
ffffffffc02032ce:	1f479163          	bne	a5,s4,ffffffffc02034b0 <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02032d2:	609c                	ld	a5,0(s1)
ffffffffc02032d4:	9a5e                	add	s4,s4,s7
ffffffffc02032d6:	6008                	ld	a0,0(s0)
ffffffffc02032d8:	00c79713          	slli	a4,a5,0xc
ffffffffc02032dc:	fcea69e3          	bltu	s4,a4,ffffffffc02032ae <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02032e0:	611c                	ld	a5,0(a0)
ffffffffc02032e2:	6a079363          	bnez	a5,ffffffffc0203988 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc02032e6:	4505                	li	a0,1
ffffffffc02032e8:	f2cff0ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc02032ec:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02032ee:	6008                	ld	a0,0(s0)
ffffffffc02032f0:	4699                	li	a3,6
ffffffffc02032f2:	10000613          	li	a2,256
ffffffffc02032f6:	85d2                	mv	a1,s4
ffffffffc02032f8:	b03ff0ef          	jal	ra,ffffffffc0202dfa <page_insert>
ffffffffc02032fc:	66051663          	bnez	a0,ffffffffc0203968 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0203300:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0203304:	4785                	li	a5,1
ffffffffc0203306:	64f71163          	bne	a4,a5,ffffffffc0203948 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020330a:	6008                	ld	a0,0(s0)
ffffffffc020330c:	6b85                	lui	s7,0x1
ffffffffc020330e:	4699                	li	a3,6
ffffffffc0203310:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0203314:	85d2                	mv	a1,s4
ffffffffc0203316:	ae5ff0ef          	jal	ra,ffffffffc0202dfa <page_insert>
ffffffffc020331a:	60051763          	bnez	a0,ffffffffc0203928 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc020331e:	000a2703          	lw	a4,0(s4)
ffffffffc0203322:	4789                	li	a5,2
ffffffffc0203324:	4ef71663          	bne	a4,a5,ffffffffc0203810 <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0203328:	00003597          	auipc	a1,0x3
ffffffffc020332c:	a5858593          	addi	a1,a1,-1448 # ffffffffc0205d80 <default_pmm_manager+0x680>
ffffffffc0203330:	10000513          	li	a0,256
ffffffffc0203334:	257000ef          	jal	ra,ffffffffc0203d8a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203338:	100b8593          	addi	a1,s7,256
ffffffffc020333c:	10000513          	li	a0,256
ffffffffc0203340:	25d000ef          	jal	ra,ffffffffc0203d9c <strcmp>
ffffffffc0203344:	4a051663          	bnez	a0,ffffffffc02037f0 <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203348:	00093683          	ld	a3,0(s2)
ffffffffc020334c:	000abc83          	ld	s9,0(s5)
ffffffffc0203350:	00080c37          	lui	s8,0x80
ffffffffc0203354:	40da06b3          	sub	a3,s4,a3
ffffffffc0203358:	868d                	srai	a3,a3,0x3
ffffffffc020335a:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020335e:	5afd                	li	s5,-1
ffffffffc0203360:	609c                	ld	a5,0(s1)
ffffffffc0203362:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203366:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203368:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc020336c:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020336e:	16f77363          	bleu	a5,a4,ffffffffc02034d4 <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203372:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203376:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020337a:	96be                	add	a3,a3,a5
ffffffffc020337c:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb60>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203380:	1c7000ef          	jal	ra,ffffffffc0203d46 <strlen>
ffffffffc0203384:	44051663          	bnez	a0,ffffffffc02037d0 <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203388:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020338c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020338e:	000bb783          	ld	a5,0(s7)
ffffffffc0203392:	078a                	slli	a5,a5,0x2
ffffffffc0203394:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203396:	12e7fd63          	bleu	a4,a5,ffffffffc02034d0 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020339a:	418787b3          	sub	a5,a5,s8
ffffffffc020339e:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02033a2:	96be                	add	a3,a3,a5
ffffffffc02033a4:	039686b3          	mul	a3,a3,s9
ffffffffc02033a8:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033aa:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc02033ae:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02033b0:	12eaf263          	bleu	a4,s5,ffffffffc02034d4 <pmm_init+0x608>
ffffffffc02033b4:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02033b8:	4585                	li	a1,1
ffffffffc02033ba:	8552                	mv	a0,s4
ffffffffc02033bc:	99b6                	add	s3,s3,a3
ffffffffc02033be:	edeff0ef          	jal	ra,ffffffffc0202a9c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02033c2:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02033c6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033c8:	078a                	slli	a5,a5,0x2
ffffffffc02033ca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033cc:	10e7f263          	bleu	a4,a5,ffffffffc02034d0 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02033d0:	fff809b7          	lui	s3,0xfff80
ffffffffc02033d4:	97ce                	add	a5,a5,s3
ffffffffc02033d6:	00379513          	slli	a0,a5,0x3
ffffffffc02033da:	00093703          	ld	a4,0(s2)
ffffffffc02033de:	97aa                	add	a5,a5,a0
ffffffffc02033e0:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc02033e4:	953a                	add	a0,a0,a4
ffffffffc02033e6:	4585                	li	a1,1
ffffffffc02033e8:	eb4ff0ef          	jal	ra,ffffffffc0202a9c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02033ec:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02033f0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033f2:	050a                	slli	a0,a0,0x2
ffffffffc02033f4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033f6:	0cf57d63          	bleu	a5,a0,ffffffffc02034d0 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02033fa:	013507b3          	add	a5,a0,s3
ffffffffc02033fe:	00379513          	slli	a0,a5,0x3
ffffffffc0203402:	00093703          	ld	a4,0(s2)
ffffffffc0203406:	953e                	add	a0,a0,a5
ffffffffc0203408:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc020340a:	4585                	li	a1,1
ffffffffc020340c:	953a                	add	a0,a0,a4
ffffffffc020340e:	e8eff0ef          	jal	ra,ffffffffc0202a9c <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0203412:	601c                	ld	a5,0(s0)
ffffffffc0203414:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc0203418:	ecaff0ef          	jal	ra,ffffffffc0202ae2 <nr_free_pages>
ffffffffc020341c:	38ab1a63          	bne	s6,a0,ffffffffc02037b0 <pmm_init+0x8e4>
}
ffffffffc0203420:	6446                	ld	s0,80(sp)
ffffffffc0203422:	60e6                	ld	ra,88(sp)
ffffffffc0203424:	64a6                	ld	s1,72(sp)
ffffffffc0203426:	6906                	ld	s2,64(sp)
ffffffffc0203428:	79e2                	ld	s3,56(sp)
ffffffffc020342a:	7a42                	ld	s4,48(sp)
ffffffffc020342c:	7aa2                	ld	s5,40(sp)
ffffffffc020342e:	7b02                	ld	s6,32(sp)
ffffffffc0203430:	6be2                	ld	s7,24(sp)
ffffffffc0203432:	6c42                	ld	s8,16(sp)
ffffffffc0203434:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203436:	00003517          	auipc	a0,0x3
ffffffffc020343a:	9c250513          	addi	a0,a0,-1598 # ffffffffc0205df8 <default_pmm_manager+0x6f8>
}
ffffffffc020343e:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203440:	c7ffc06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203444:	6705                	lui	a4,0x1
ffffffffc0203446:	177d                	addi	a4,a4,-1
ffffffffc0203448:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc020344a:	00c6d713          	srli	a4,a3,0xc
ffffffffc020344e:	08f77163          	bleu	a5,a4,ffffffffc02034d0 <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc0203452:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0203456:	9732                	add	a4,a4,a2
ffffffffc0203458:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020345c:	767d                	lui	a2,0xfffff
ffffffffc020345e:	8ef1                	and	a3,a3,a2
ffffffffc0203460:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc0203462:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203466:	8d95                	sub	a1,a1,a3
ffffffffc0203468:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020346a:	81b1                	srli	a1,a1,0xc
ffffffffc020346c:	953e                	add	a0,a0,a5
ffffffffc020346e:	9702                	jalr	a4
ffffffffc0203470:	bead                	j	ffffffffc0202fea <pmm_init+0x11e>
ffffffffc0203472:	6008                	ld	a0,0(s0)
ffffffffc0203474:	b5b5                	j	ffffffffc02032e0 <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203476:	86d2                	mv	a3,s4
ffffffffc0203478:	00002617          	auipc	a2,0x2
ffffffffc020347c:	3a860613          	addi	a2,a2,936 # ffffffffc0205820 <default_pmm_manager+0x120>
ffffffffc0203480:	1d100593          	li	a1,465
ffffffffc0203484:	00002517          	auipc	a0,0x2
ffffffffc0203488:	3c450513          	addi	a0,a0,964 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020348c:	c7bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203490:	00002697          	auipc	a3,0x2
ffffffffc0203494:	7d868693          	addi	a3,a3,2008 # ffffffffc0205c68 <default_pmm_manager+0x568>
ffffffffc0203498:	00001617          	auipc	a2,0x1
ffffffffc020349c:	7d060613          	addi	a2,a2,2000 # ffffffffc0204c68 <commands+0x858>
ffffffffc02034a0:	1d100593          	li	a1,465
ffffffffc02034a4:	00002517          	auipc	a0,0x2
ffffffffc02034a8:	3a450513          	addi	a0,a0,932 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02034ac:	c5bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02034b0:	00002697          	auipc	a3,0x2
ffffffffc02034b4:	7f868693          	addi	a3,a3,2040 # ffffffffc0205ca8 <default_pmm_manager+0x5a8>
ffffffffc02034b8:	00001617          	auipc	a2,0x1
ffffffffc02034bc:	7b060613          	addi	a2,a2,1968 # ffffffffc0204c68 <commands+0x858>
ffffffffc02034c0:	1d200593          	li	a1,466
ffffffffc02034c4:	00002517          	auipc	a0,0x2
ffffffffc02034c8:	38450513          	addi	a0,a0,900 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02034cc:	c3bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc02034d0:	d28ff0ef          	jal	ra,ffffffffc02029f8 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02034d4:	00002617          	auipc	a2,0x2
ffffffffc02034d8:	34c60613          	addi	a2,a2,844 # ffffffffc0205820 <default_pmm_manager+0x120>
ffffffffc02034dc:	06a00593          	li	a1,106
ffffffffc02034e0:	00002517          	auipc	a0,0x2
ffffffffc02034e4:	aa050513          	addi	a0,a0,-1376 # ffffffffc0204f80 <commands+0xb70>
ffffffffc02034e8:	c1ffc0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02034ec:	00002617          	auipc	a2,0x2
ffffffffc02034f0:	d5c60613          	addi	a2,a2,-676 # ffffffffc0205248 <commands+0xe38>
ffffffffc02034f4:	07000593          	li	a1,112
ffffffffc02034f8:	00002517          	auipc	a0,0x2
ffffffffc02034fc:	a8850513          	addi	a0,a0,-1400 # ffffffffc0204f80 <commands+0xb70>
ffffffffc0203500:	c07fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);//boot_pgdir是页表的虚拟地址，所以它的低12位应该是0
ffffffffc0203504:	00002697          	auipc	a3,0x2
ffffffffc0203508:	49c68693          	addi	a3,a3,1180 # ffffffffc02059a0 <default_pmm_manager+0x2a0>
ffffffffc020350c:	00001617          	auipc	a2,0x1
ffffffffc0203510:	75c60613          	addi	a2,a2,1884 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203514:	19400593          	li	a1,404
ffffffffc0203518:	00002517          	auipc	a0,0x2
ffffffffc020351c:	33050513          	addi	a0,a0,816 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203520:	be7fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203524:	00002697          	auipc	a3,0x2
ffffffffc0203528:	4b468693          	addi	a3,a3,1204 # ffffffffc02059d8 <default_pmm_manager+0x2d8>
ffffffffc020352c:	00001617          	auipc	a2,0x1
ffffffffc0203530:	73c60613          	addi	a2,a2,1852 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203534:	19500593          	li	a1,405
ffffffffc0203538:	00002517          	auipc	a0,0x2
ffffffffc020353c:	31050513          	addi	a0,a0,784 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203540:	bc7fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203544:	00002697          	auipc	a3,0x2
ffffffffc0203548:	6e468693          	addi	a3,a3,1764 # ffffffffc0205c28 <default_pmm_manager+0x528>
ffffffffc020354c:	00001617          	auipc	a2,0x1
ffffffffc0203550:	71c60613          	addi	a2,a2,1820 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203554:	1c400593          	li	a1,452
ffffffffc0203558:	00002517          	auipc	a0,0x2
ffffffffc020355c:	2f050513          	addi	a0,a0,752 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203560:	ba7fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203564:	00002617          	auipc	a2,0x2
ffffffffc0203568:	3d460613          	addi	a2,a2,980 # ffffffffc0205938 <default_pmm_manager+0x238>
ffffffffc020356c:	07700593          	li	a1,119
ffffffffc0203570:	00002517          	auipc	a0,0x2
ffffffffc0203574:	2d850513          	addi	a0,a0,728 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203578:	b8ffc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020357c:	00002697          	auipc	a3,0x2
ffffffffc0203580:	4b468693          	addi	a3,a3,1204 # ffffffffc0205a30 <default_pmm_manager+0x330>
ffffffffc0203584:	00001617          	auipc	a2,0x1
ffffffffc0203588:	6e460613          	addi	a2,a2,1764 # ffffffffc0204c68 <commands+0x858>
ffffffffc020358c:	19b00593          	li	a1,411
ffffffffc0203590:	00002517          	auipc	a0,0x2
ffffffffc0203594:	2b850513          	addi	a0,a0,696 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203598:	b6ffc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);//page_insert()，在页表里建立一个映射
ffffffffc020359c:	00002697          	auipc	a3,0x2
ffffffffc02035a0:	46468693          	addi	a3,a3,1124 # ffffffffc0205a00 <default_pmm_manager+0x300>
ffffffffc02035a4:	00001617          	auipc	a2,0x1
ffffffffc02035a8:	6c460613          	addi	a2,a2,1732 # ffffffffc0204c68 <commands+0x858>
ffffffffc02035ac:	19900593          	li	a1,409
ffffffffc02035b0:	00002517          	auipc	a0,0x2
ffffffffc02035b4:	29850513          	addi	a0,a0,664 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02035b8:	b4ffc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02035bc:	00002697          	auipc	a3,0x2
ffffffffc02035c0:	56468693          	addi	a3,a3,1380 # ffffffffc0205b20 <default_pmm_manager+0x420>
ffffffffc02035c4:	00001617          	auipc	a2,0x1
ffffffffc02035c8:	6a460613          	addi	a2,a2,1700 # ffffffffc0204c68 <commands+0x858>
ffffffffc02035cc:	1a800593          	li	a1,424
ffffffffc02035d0:	00002517          	auipc	a0,0x2
ffffffffc02035d4:	27850513          	addi	a0,a0,632 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02035d8:	b2ffc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02035dc:	00002697          	auipc	a3,0x2
ffffffffc02035e0:	51468693          	addi	a3,a3,1300 # ffffffffc0205af0 <default_pmm_manager+0x3f0>
ffffffffc02035e4:	00001617          	auipc	a2,0x1
ffffffffc02035e8:	68460613          	addi	a2,a2,1668 # ffffffffc0204c68 <commands+0x858>
ffffffffc02035ec:	1a700593          	li	a1,423
ffffffffc02035f0:	00002517          	auipc	a0,0x2
ffffffffc02035f4:	25850513          	addi	a0,a0,600 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02035f8:	b0ffc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02035fc:	00002697          	auipc	a3,0x2
ffffffffc0203600:	4bc68693          	addi	a3,a3,1212 # ffffffffc0205ab8 <default_pmm_manager+0x3b8>
ffffffffc0203604:	00001617          	auipc	a2,0x1
ffffffffc0203608:	66460613          	addi	a2,a2,1636 # ffffffffc0204c68 <commands+0x858>
ffffffffc020360c:	1a600593          	li	a1,422
ffffffffc0203610:	00002517          	auipc	a0,0x2
ffffffffc0203614:	23850513          	addi	a0,a0,568 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203618:	aeffc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020361c:	00002697          	auipc	a3,0x2
ffffffffc0203620:	47468693          	addi	a3,a3,1140 # ffffffffc0205a90 <default_pmm_manager+0x390>
ffffffffc0203624:	00001617          	auipc	a2,0x1
ffffffffc0203628:	64460613          	addi	a2,a2,1604 # ffffffffc0204c68 <commands+0x858>
ffffffffc020362c:	1a100593          	li	a1,417
ffffffffc0203630:	00002517          	auipc	a0,0x2
ffffffffc0203634:	21850513          	addi	a0,a0,536 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203638:	acffc0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020363c:	86da                	mv	a3,s6
ffffffffc020363e:	00002617          	auipc	a2,0x2
ffffffffc0203642:	1e260613          	addi	a2,a2,482 # ffffffffc0205820 <default_pmm_manager+0x120>
ffffffffc0203646:	1a000593          	li	a1,416
ffffffffc020364a:	00002517          	auipc	a0,0x2
ffffffffc020364e:	1fe50513          	addi	a0,a0,510 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203652:	ab5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203656:	86be                	mv	a3,a5
ffffffffc0203658:	00002617          	auipc	a2,0x2
ffffffffc020365c:	1c860613          	addi	a2,a2,456 # ffffffffc0205820 <default_pmm_manager+0x120>
ffffffffc0203660:	19f00593          	li	a1,415
ffffffffc0203664:	00002517          	auipc	a0,0x2
ffffffffc0203668:	1e450513          	addi	a0,a0,484 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020366c:	a9bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203670:	00002697          	auipc	a3,0x2
ffffffffc0203674:	40868693          	addi	a3,a3,1032 # ffffffffc0205a78 <default_pmm_manager+0x378>
ffffffffc0203678:	00001617          	auipc	a2,0x1
ffffffffc020367c:	5f060613          	addi	a2,a2,1520 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203680:	19d00593          	li	a1,413
ffffffffc0203684:	00002517          	auipc	a0,0x2
ffffffffc0203688:	1c450513          	addi	a0,a0,452 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020368c:	a7bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203690:	00002697          	auipc	a3,0x2
ffffffffc0203694:	3d068693          	addi	a3,a3,976 # ffffffffc0205a60 <default_pmm_manager+0x360>
ffffffffc0203698:	00001617          	auipc	a2,0x1
ffffffffc020369c:	5d060613          	addi	a2,a2,1488 # ffffffffc0204c68 <commands+0x858>
ffffffffc02036a0:	19c00593          	li	a1,412
ffffffffc02036a4:	00002517          	auipc	a0,0x2
ffffffffc02036a8:	1a450513          	addi	a0,a0,420 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02036ac:	a5bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02036b0:	00002697          	auipc	a3,0x2
ffffffffc02036b4:	3b068693          	addi	a3,a3,944 # ffffffffc0205a60 <default_pmm_manager+0x360>
ffffffffc02036b8:	00001617          	auipc	a2,0x1
ffffffffc02036bc:	5b060613          	addi	a2,a2,1456 # ffffffffc0204c68 <commands+0x858>
ffffffffc02036c0:	1b200593          	li	a1,434
ffffffffc02036c4:	00002517          	auipc	a0,0x2
ffffffffc02036c8:	18450513          	addi	a0,a0,388 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02036cc:	a3bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02036d0:	00002697          	auipc	a3,0x2
ffffffffc02036d4:	42068693          	addi	a3,a3,1056 # ffffffffc0205af0 <default_pmm_manager+0x3f0>
ffffffffc02036d8:	00001617          	auipc	a2,0x1
ffffffffc02036dc:	59060613          	addi	a2,a2,1424 # ffffffffc0204c68 <commands+0x858>
ffffffffc02036e0:	1b100593          	li	a1,433
ffffffffc02036e4:	00002517          	auipc	a0,0x2
ffffffffc02036e8:	16450513          	addi	a0,a0,356 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02036ec:	a1bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02036f0:	00002697          	auipc	a3,0x2
ffffffffc02036f4:	4c868693          	addi	a3,a3,1224 # ffffffffc0205bb8 <default_pmm_manager+0x4b8>
ffffffffc02036f8:	00001617          	auipc	a2,0x1
ffffffffc02036fc:	57060613          	addi	a2,a2,1392 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203700:	1b000593          	li	a1,432
ffffffffc0203704:	00002517          	auipc	a0,0x2
ffffffffc0203708:	14450513          	addi	a0,a0,324 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020370c:	9fbfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203710:	00002697          	auipc	a3,0x2
ffffffffc0203714:	49068693          	addi	a3,a3,1168 # ffffffffc0205ba0 <default_pmm_manager+0x4a0>
ffffffffc0203718:	00001617          	auipc	a2,0x1
ffffffffc020371c:	55060613          	addi	a2,a2,1360 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203720:	1af00593          	li	a1,431
ffffffffc0203724:	00002517          	auipc	a0,0x2
ffffffffc0203728:	12450513          	addi	a0,a0,292 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020372c:	9dbfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203730:	00002697          	auipc	a3,0x2
ffffffffc0203734:	44068693          	addi	a3,a3,1088 # ffffffffc0205b70 <default_pmm_manager+0x470>
ffffffffc0203738:	00001617          	auipc	a2,0x1
ffffffffc020373c:	53060613          	addi	a2,a2,1328 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203740:	1ae00593          	li	a1,430
ffffffffc0203744:	00002517          	auipc	a0,0x2
ffffffffc0203748:	10450513          	addi	a0,a0,260 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020374c:	9bbfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203750:	00002697          	auipc	a3,0x2
ffffffffc0203754:	40868693          	addi	a3,a3,1032 # ffffffffc0205b58 <default_pmm_manager+0x458>
ffffffffc0203758:	00001617          	auipc	a2,0x1
ffffffffc020375c:	51060613          	addi	a2,a2,1296 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203760:	1ab00593          	li	a1,427
ffffffffc0203764:	00002517          	auipc	a0,0x2
ffffffffc0203768:	0e450513          	addi	a0,a0,228 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020376c:	99bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203770:	00002697          	auipc	a3,0x2
ffffffffc0203774:	3d068693          	addi	a3,a3,976 # ffffffffc0205b40 <default_pmm_manager+0x440>
ffffffffc0203778:	00001617          	auipc	a2,0x1
ffffffffc020377c:	4f060613          	addi	a2,a2,1264 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203780:	1aa00593          	li	a1,426
ffffffffc0203784:	00002517          	auipc	a0,0x2
ffffffffc0203788:	0c450513          	addi	a0,a0,196 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020378c:	97bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203790:	00002697          	auipc	a3,0x2
ffffffffc0203794:	3a068693          	addi	a3,a3,928 # ffffffffc0205b30 <default_pmm_manager+0x430>
ffffffffc0203798:	00001617          	auipc	a2,0x1
ffffffffc020379c:	4d060613          	addi	a2,a2,1232 # ffffffffc0204c68 <commands+0x858>
ffffffffc02037a0:	1a900593          	li	a1,425
ffffffffc02037a4:	00002517          	auipc	a0,0x2
ffffffffc02037a8:	0a450513          	addi	a0,a0,164 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02037ac:	95bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02037b0:	00002697          	auipc	a3,0x2
ffffffffc02037b4:	47868693          	addi	a3,a3,1144 # ffffffffc0205c28 <default_pmm_manager+0x528>
ffffffffc02037b8:	00001617          	auipc	a2,0x1
ffffffffc02037bc:	4b060613          	addi	a2,a2,1200 # ffffffffc0204c68 <commands+0x858>
ffffffffc02037c0:	1ec00593          	li	a1,492
ffffffffc02037c4:	00002517          	auipc	a0,0x2
ffffffffc02037c8:	08450513          	addi	a0,a0,132 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02037cc:	93bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02037d0:	00002697          	auipc	a3,0x2
ffffffffc02037d4:	60068693          	addi	a3,a3,1536 # ffffffffc0205dd0 <default_pmm_manager+0x6d0>
ffffffffc02037d8:	00001617          	auipc	a2,0x1
ffffffffc02037dc:	49060613          	addi	a2,a2,1168 # ffffffffc0204c68 <commands+0x858>
ffffffffc02037e0:	1e400593          	li	a1,484
ffffffffc02037e4:	00002517          	auipc	a0,0x2
ffffffffc02037e8:	06450513          	addi	a0,a0,100 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02037ec:	91bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02037f0:	00002697          	auipc	a3,0x2
ffffffffc02037f4:	5a868693          	addi	a3,a3,1448 # ffffffffc0205d98 <default_pmm_manager+0x698>
ffffffffc02037f8:	00001617          	auipc	a2,0x1
ffffffffc02037fc:	47060613          	addi	a2,a2,1136 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203800:	1e100593          	li	a1,481
ffffffffc0203804:	00002517          	auipc	a0,0x2
ffffffffc0203808:	04450513          	addi	a0,a0,68 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020380c:	8fbfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203810:	00002697          	auipc	a3,0x2
ffffffffc0203814:	55868693          	addi	a3,a3,1368 # ffffffffc0205d68 <default_pmm_manager+0x668>
ffffffffc0203818:	00001617          	auipc	a2,0x1
ffffffffc020381c:	45060613          	addi	a2,a2,1104 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203820:	1dd00593          	li	a1,477
ffffffffc0203824:	00002517          	auipc	a0,0x2
ffffffffc0203828:	02450513          	addi	a0,a0,36 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020382c:	8dbfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203830:	00002697          	auipc	a3,0x2
ffffffffc0203834:	3b868693          	addi	a3,a3,952 # ffffffffc0205be8 <default_pmm_manager+0x4e8>
ffffffffc0203838:	00001617          	auipc	a2,0x1
ffffffffc020383c:	43060613          	addi	a2,a2,1072 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203840:	1ba00593          	li	a1,442
ffffffffc0203844:	00002517          	auipc	a0,0x2
ffffffffc0203848:	00450513          	addi	a0,a0,4 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020384c:	8bbfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203850:	00002697          	auipc	a3,0x2
ffffffffc0203854:	36868693          	addi	a3,a3,872 # ffffffffc0205bb8 <default_pmm_manager+0x4b8>
ffffffffc0203858:	00001617          	auipc	a2,0x1
ffffffffc020385c:	41060613          	addi	a2,a2,1040 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203860:	1b700593          	li	a1,439
ffffffffc0203864:	00002517          	auipc	a0,0x2
ffffffffc0203868:	fe450513          	addi	a0,a0,-28 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020386c:	89bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203870:	00002697          	auipc	a3,0x2
ffffffffc0203874:	20868693          	addi	a3,a3,520 # ffffffffc0205a78 <default_pmm_manager+0x378>
ffffffffc0203878:	00001617          	auipc	a2,0x1
ffffffffc020387c:	3f060613          	addi	a2,a2,1008 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203880:	1b600593          	li	a1,438
ffffffffc0203884:	00002517          	auipc	a0,0x2
ffffffffc0203888:	fc450513          	addi	a0,a0,-60 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020388c:	87bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203890:	00002697          	auipc	a3,0x2
ffffffffc0203894:	34068693          	addi	a3,a3,832 # ffffffffc0205bd0 <default_pmm_manager+0x4d0>
ffffffffc0203898:	00001617          	auipc	a2,0x1
ffffffffc020389c:	3d060613          	addi	a2,a2,976 # ffffffffc0204c68 <commands+0x858>
ffffffffc02038a0:	1b300593          	li	a1,435
ffffffffc02038a4:	00002517          	auipc	a0,0x2
ffffffffc02038a8:	fa450513          	addi	a0,a0,-92 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02038ac:	85bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02038b0:	00002697          	auipc	a3,0x2
ffffffffc02038b4:	35068693          	addi	a3,a3,848 # ffffffffc0205c00 <default_pmm_manager+0x500>
ffffffffc02038b8:	00001617          	auipc	a2,0x1
ffffffffc02038bc:	3b060613          	addi	a2,a2,944 # ffffffffc0204c68 <commands+0x858>
ffffffffc02038c0:	1bd00593          	li	a1,445
ffffffffc02038c4:	00002517          	auipc	a0,0x2
ffffffffc02038c8:	f8450513          	addi	a0,a0,-124 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02038cc:	83bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02038d0:	00002697          	auipc	a3,0x2
ffffffffc02038d4:	2e868693          	addi	a3,a3,744 # ffffffffc0205bb8 <default_pmm_manager+0x4b8>
ffffffffc02038d8:	00001617          	auipc	a2,0x1
ffffffffc02038dc:	39060613          	addi	a2,a2,912 # ffffffffc0204c68 <commands+0x858>
ffffffffc02038e0:	1bb00593          	li	a1,443
ffffffffc02038e4:	00002517          	auipc	a0,0x2
ffffffffc02038e8:	f6450513          	addi	a0,a0,-156 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02038ec:	81bfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02038f0:	00002697          	auipc	a3,0x2
ffffffffc02038f4:	09068693          	addi	a3,a3,144 # ffffffffc0205980 <default_pmm_manager+0x280>
ffffffffc02038f8:	00001617          	auipc	a2,0x1
ffffffffc02038fc:	37060613          	addi	a2,a2,880 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203900:	19300593          	li	a1,403
ffffffffc0203904:	00002517          	auipc	a0,0x2
ffffffffc0203908:	f4450513          	addi	a0,a0,-188 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc020390c:	ffafc0ef          	jal	ra,ffffffffc0200106 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203910:	00002617          	auipc	a2,0x2
ffffffffc0203914:	02860613          	addi	a2,a2,40 # ffffffffc0205938 <default_pmm_manager+0x238>
ffffffffc0203918:	0bd00593          	li	a1,189
ffffffffc020391c:	00002517          	auipc	a0,0x2
ffffffffc0203920:	f2c50513          	addi	a0,a0,-212 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203924:	fe2fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203928:	00002697          	auipc	a3,0x2
ffffffffc020392c:	40068693          	addi	a3,a3,1024 # ffffffffc0205d28 <default_pmm_manager+0x628>
ffffffffc0203930:	00001617          	auipc	a2,0x1
ffffffffc0203934:	33860613          	addi	a2,a2,824 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203938:	1dc00593          	li	a1,476
ffffffffc020393c:	00002517          	auipc	a0,0x2
ffffffffc0203940:	f0c50513          	addi	a0,a0,-244 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203944:	fc2fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203948:	00002697          	auipc	a3,0x2
ffffffffc020394c:	3c868693          	addi	a3,a3,968 # ffffffffc0205d10 <default_pmm_manager+0x610>
ffffffffc0203950:	00001617          	auipc	a2,0x1
ffffffffc0203954:	31860613          	addi	a2,a2,792 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203958:	1db00593          	li	a1,475
ffffffffc020395c:	00002517          	auipc	a0,0x2
ffffffffc0203960:	eec50513          	addi	a0,a0,-276 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203964:	fa2fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203968:	00002697          	auipc	a3,0x2
ffffffffc020396c:	37068693          	addi	a3,a3,880 # ffffffffc0205cd8 <default_pmm_manager+0x5d8>
ffffffffc0203970:	00001617          	auipc	a2,0x1
ffffffffc0203974:	2f860613          	addi	a2,a2,760 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203978:	1da00593          	li	a1,474
ffffffffc020397c:	00002517          	auipc	a0,0x2
ffffffffc0203980:	ecc50513          	addi	a0,a0,-308 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203984:	f82fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203988:	00002697          	auipc	a3,0x2
ffffffffc020398c:	33868693          	addi	a3,a3,824 # ffffffffc0205cc0 <default_pmm_manager+0x5c0>
ffffffffc0203990:	00001617          	auipc	a2,0x1
ffffffffc0203994:	2d860613          	addi	a2,a2,728 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203998:	1d600593          	li	a1,470
ffffffffc020399c:	00002517          	auipc	a0,0x2
ffffffffc02039a0:	eac50513          	addi	a0,a0,-340 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc02039a4:	f62fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02039a8 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02039a8:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02039ac:	8082                	ret

ffffffffc02039ae <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02039ae:	7179                	addi	sp,sp,-48
ffffffffc02039b0:	e84a                	sd	s2,16(sp)
ffffffffc02039b2:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02039b4:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02039b6:	f022                	sd	s0,32(sp)
ffffffffc02039b8:	ec26                	sd	s1,24(sp)
ffffffffc02039ba:	e44e                	sd	s3,8(sp)
ffffffffc02039bc:	f406                	sd	ra,40(sp)
ffffffffc02039be:	84ae                	mv	s1,a1
ffffffffc02039c0:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02039c2:	852ff0ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
ffffffffc02039c6:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02039c8:	cd19                	beqz	a0,ffffffffc02039e6 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02039ca:	85aa                	mv	a1,a0
ffffffffc02039cc:	86ce                	mv	a3,s3
ffffffffc02039ce:	8626                	mv	a2,s1
ffffffffc02039d0:	854a                	mv	a0,s2
ffffffffc02039d2:	c28ff0ef          	jal	ra,ffffffffc0202dfa <page_insert>
ffffffffc02039d6:	ed39                	bnez	a0,ffffffffc0203a34 <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc02039d8:	0000e797          	auipc	a5,0xe
ffffffffc02039dc:	a8878793          	addi	a5,a5,-1400 # ffffffffc0211460 <swap_init_ok>
ffffffffc02039e0:	439c                	lw	a5,0(a5)
ffffffffc02039e2:	2781                	sext.w	a5,a5
ffffffffc02039e4:	eb89                	bnez	a5,ffffffffc02039f6 <pgdir_alloc_page+0x48>
}
ffffffffc02039e6:	8522                	mv	a0,s0
ffffffffc02039e8:	70a2                	ld	ra,40(sp)
ffffffffc02039ea:	7402                	ld	s0,32(sp)
ffffffffc02039ec:	64e2                	ld	s1,24(sp)
ffffffffc02039ee:	6942                	ld	s2,16(sp)
ffffffffc02039f0:	69a2                	ld	s3,8(sp)
ffffffffc02039f2:	6145                	addi	sp,sp,48
ffffffffc02039f4:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02039f6:	0000e797          	auipc	a5,0xe
ffffffffc02039fa:	a8a78793          	addi	a5,a5,-1398 # ffffffffc0211480 <check_mm_struct>
ffffffffc02039fe:	6388                	ld	a0,0(a5)
ffffffffc0203a00:	4681                	li	a3,0
ffffffffc0203a02:	8622                	mv	a2,s0
ffffffffc0203a04:	85a6                	mv	a1,s1
ffffffffc0203a06:	f6dfd0ef          	jal	ra,ffffffffc0201972 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203a0a:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203a0c:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0203a0e:	4785                	li	a5,1
ffffffffc0203a10:	fcf70be3          	beq	a4,a5,ffffffffc02039e6 <pgdir_alloc_page+0x38>
ffffffffc0203a14:	00002697          	auipc	a3,0x2
ffffffffc0203a18:	e8468693          	addi	a3,a3,-380 # ffffffffc0205898 <default_pmm_manager+0x198>
ffffffffc0203a1c:	00001617          	auipc	a2,0x1
ffffffffc0203a20:	24c60613          	addi	a2,a2,588 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203a24:	17b00593          	li	a1,379
ffffffffc0203a28:	00002517          	auipc	a0,0x2
ffffffffc0203a2c:	e2050513          	addi	a0,a0,-480 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203a30:	ed6fc0ef          	jal	ra,ffffffffc0200106 <__panic>
            free_page(page);
ffffffffc0203a34:	8522                	mv	a0,s0
ffffffffc0203a36:	4585                	li	a1,1
ffffffffc0203a38:	864ff0ef          	jal	ra,ffffffffc0202a9c <free_pages>
            return NULL;
ffffffffc0203a3c:	4401                	li	s0,0
ffffffffc0203a3e:	b765                	j	ffffffffc02039e6 <pgdir_alloc_page+0x38>

ffffffffc0203a40 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203a40:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203a42:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203a44:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203a46:	fff50713          	addi	a4,a0,-1
ffffffffc0203a4a:	17f9                	addi	a5,a5,-2
ffffffffc0203a4c:	04e7ee63          	bltu	a5,a4,ffffffffc0203aa8 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203a50:	6785                	lui	a5,0x1
ffffffffc0203a52:	17fd                	addi	a5,a5,-1
ffffffffc0203a54:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203a56:	8131                	srli	a0,a0,0xc
ffffffffc0203a58:	fbdfe0ef          	jal	ra,ffffffffc0202a14 <alloc_pages>
    assert(base != NULL);
ffffffffc0203a5c:	c159                	beqz	a0,ffffffffc0203ae2 <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203a5e:	0000e797          	auipc	a5,0xe
ffffffffc0203a62:	b3a78793          	addi	a5,a5,-1222 # ffffffffc0211598 <pages>
ffffffffc0203a66:	639c                	ld	a5,0(a5)
ffffffffc0203a68:	8d1d                	sub	a0,a0,a5
ffffffffc0203a6a:	00002797          	auipc	a5,0x2
ffffffffc0203a6e:	93e78793          	addi	a5,a5,-1730 # ffffffffc02053a8 <commands+0xf98>
ffffffffc0203a72:	6394                	ld	a3,0(a5)
ffffffffc0203a74:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a76:	0000e797          	auipc	a5,0xe
ffffffffc0203a7a:	9fa78793          	addi	a5,a5,-1542 # ffffffffc0211470 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203a7e:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a82:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203a84:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a88:	57fd                	li	a5,-1
ffffffffc0203a8a:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203a8c:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a8e:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203a90:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203a92:	02e7fb63          	bleu	a4,a5,ffffffffc0203ac8 <kmalloc+0x88>
ffffffffc0203a96:	0000e797          	auipc	a5,0xe
ffffffffc0203a9a:	af278793          	addi	a5,a5,-1294 # ffffffffc0211588 <va_pa_offset>
ffffffffc0203a9e:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203aa0:	60a2                	ld	ra,8(sp)
ffffffffc0203aa2:	953e                	add	a0,a0,a5
ffffffffc0203aa4:	0141                	addi	sp,sp,16
ffffffffc0203aa6:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203aa8:	00002697          	auipc	a3,0x2
ffffffffc0203aac:	dc068693          	addi	a3,a3,-576 # ffffffffc0205868 <default_pmm_manager+0x168>
ffffffffc0203ab0:	00001617          	auipc	a2,0x1
ffffffffc0203ab4:	1b860613          	addi	a2,a2,440 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203ab8:	1f400593          	li	a1,500
ffffffffc0203abc:	00002517          	auipc	a0,0x2
ffffffffc0203ac0:	d8c50513          	addi	a0,a0,-628 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203ac4:	e42fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203ac8:	86aa                	mv	a3,a0
ffffffffc0203aca:	00002617          	auipc	a2,0x2
ffffffffc0203ace:	d5660613          	addi	a2,a2,-682 # ffffffffc0205820 <default_pmm_manager+0x120>
ffffffffc0203ad2:	06a00593          	li	a1,106
ffffffffc0203ad6:	00001517          	auipc	a0,0x1
ffffffffc0203ada:	4aa50513          	addi	a0,a0,1194 # ffffffffc0204f80 <commands+0xb70>
ffffffffc0203ade:	e28fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(base != NULL);
ffffffffc0203ae2:	00002697          	auipc	a3,0x2
ffffffffc0203ae6:	da668693          	addi	a3,a3,-602 # ffffffffc0205888 <default_pmm_manager+0x188>
ffffffffc0203aea:	00001617          	auipc	a2,0x1
ffffffffc0203aee:	17e60613          	addi	a2,a2,382 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203af2:	1f700593          	li	a1,503
ffffffffc0203af6:	00002517          	auipc	a0,0x2
ffffffffc0203afa:	d5250513          	addi	a0,a0,-686 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203afe:	e08fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203b02 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203b02:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203b04:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203b06:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203b08:	fff58713          	addi	a4,a1,-1
ffffffffc0203b0c:	17f9                	addi	a5,a5,-2
ffffffffc0203b0e:	04e7eb63          	bltu	a5,a4,ffffffffc0203b64 <kfree+0x62>
    assert(ptr != NULL);
ffffffffc0203b12:	c941                	beqz	a0,ffffffffc0203ba2 <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203b14:	6785                	lui	a5,0x1
ffffffffc0203b16:	17fd                	addi	a5,a5,-1
ffffffffc0203b18:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203b1a:	c02007b7          	lui	a5,0xc0200
ffffffffc0203b1e:	81b1                	srli	a1,a1,0xc
ffffffffc0203b20:	06f56463          	bltu	a0,a5,ffffffffc0203b88 <kfree+0x86>
ffffffffc0203b24:	0000e797          	auipc	a5,0xe
ffffffffc0203b28:	a6478793          	addi	a5,a5,-1436 # ffffffffc0211588 <va_pa_offset>
ffffffffc0203b2c:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203b2e:	0000e717          	auipc	a4,0xe
ffffffffc0203b32:	94270713          	addi	a4,a4,-1726 # ffffffffc0211470 <npage>
ffffffffc0203b36:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203b38:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0203b3c:	83b1                	srli	a5,a5,0xc
ffffffffc0203b3e:	04e7f363          	bleu	a4,a5,ffffffffc0203b84 <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b42:	fff80537          	lui	a0,0xfff80
ffffffffc0203b46:	97aa                	add	a5,a5,a0
ffffffffc0203b48:	0000e697          	auipc	a3,0xe
ffffffffc0203b4c:	a5068693          	addi	a3,a3,-1456 # ffffffffc0211598 <pages>
ffffffffc0203b50:	6288                	ld	a0,0(a3)
ffffffffc0203b52:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203b56:	60a2                	ld	ra,8(sp)
ffffffffc0203b58:	97ba                	add	a5,a5,a4
ffffffffc0203b5a:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0203b5c:	953e                	add	a0,a0,a5
}
ffffffffc0203b5e:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc0203b60:	f3dfe06f          	j	ffffffffc0202a9c <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203b64:	00002697          	auipc	a3,0x2
ffffffffc0203b68:	d0468693          	addi	a3,a3,-764 # ffffffffc0205868 <default_pmm_manager+0x168>
ffffffffc0203b6c:	00001617          	auipc	a2,0x1
ffffffffc0203b70:	0fc60613          	addi	a2,a2,252 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203b74:	1fd00593          	li	a1,509
ffffffffc0203b78:	00002517          	auipc	a0,0x2
ffffffffc0203b7c:	cd050513          	addi	a0,a0,-816 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203b80:	d86fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203b84:	e75fe0ef          	jal	ra,ffffffffc02029f8 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203b88:	86aa                	mv	a3,a0
ffffffffc0203b8a:	00002617          	auipc	a2,0x2
ffffffffc0203b8e:	dae60613          	addi	a2,a2,-594 # ffffffffc0205938 <default_pmm_manager+0x238>
ffffffffc0203b92:	06c00593          	li	a1,108
ffffffffc0203b96:	00001517          	auipc	a0,0x1
ffffffffc0203b9a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204f80 <commands+0xb70>
ffffffffc0203b9e:	d68fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(ptr != NULL);
ffffffffc0203ba2:	00002697          	auipc	a3,0x2
ffffffffc0203ba6:	cb668693          	addi	a3,a3,-842 # ffffffffc0205858 <default_pmm_manager+0x158>
ffffffffc0203baa:	00001617          	auipc	a2,0x1
ffffffffc0203bae:	0be60613          	addi	a2,a2,190 # ffffffffc0204c68 <commands+0x858>
ffffffffc0203bb2:	1fe00593          	li	a1,510
ffffffffc0203bb6:	00002517          	auipc	a0,0x2
ffffffffc0203bba:	c9250513          	addi	a0,a0,-878 # ffffffffc0205848 <default_pmm_manager+0x148>
ffffffffc0203bbe:	d48fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203bc2 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203bc2:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203bc4:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203bc6:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203bc8:	80ffc0ef          	jal	ra,ffffffffc02003d6 <ide_device_valid>
ffffffffc0203bcc:	cd01                	beqz	a0,ffffffffc0203be4 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203bce:	4505                	li	a0,1
ffffffffc0203bd0:	80dfc0ef          	jal	ra,ffffffffc02003dc <ide_device_size>
}
ffffffffc0203bd4:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203bd6:	810d                	srli	a0,a0,0x3
ffffffffc0203bd8:	0000e797          	auipc	a5,0xe
ffffffffc0203bdc:	94a7b423          	sd	a0,-1720(a5) # ffffffffc0211520 <max_swap_offset>
}
ffffffffc0203be0:	0141                	addi	sp,sp,16
ffffffffc0203be2:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203be4:	00002617          	auipc	a2,0x2
ffffffffc0203be8:	23460613          	addi	a2,a2,564 # ffffffffc0205e18 <default_pmm_manager+0x718>
ffffffffc0203bec:	45b5                	li	a1,13
ffffffffc0203bee:	00002517          	auipc	a0,0x2
ffffffffc0203bf2:	24a50513          	addi	a0,a0,586 # ffffffffc0205e38 <default_pmm_manager+0x738>
ffffffffc0203bf6:	d10fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203bfa <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203bfa:	1141                	addi	sp,sp,-16
ffffffffc0203bfc:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203bfe:	00855793          	srli	a5,a0,0x8
ffffffffc0203c02:	c7b5                	beqz	a5,ffffffffc0203c6e <swapfs_read+0x74>
ffffffffc0203c04:	0000e717          	auipc	a4,0xe
ffffffffc0203c08:	91c70713          	addi	a4,a4,-1764 # ffffffffc0211520 <max_swap_offset>
ffffffffc0203c0c:	6318                	ld	a4,0(a4)
ffffffffc0203c0e:	06e7f063          	bleu	a4,a5,ffffffffc0203c6e <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c12:	0000e717          	auipc	a4,0xe
ffffffffc0203c16:	98670713          	addi	a4,a4,-1658 # ffffffffc0211598 <pages>
ffffffffc0203c1a:	6310                	ld	a2,0(a4)
ffffffffc0203c1c:	00001717          	auipc	a4,0x1
ffffffffc0203c20:	78c70713          	addi	a4,a4,1932 # ffffffffc02053a8 <commands+0xf98>
ffffffffc0203c24:	00002697          	auipc	a3,0x2
ffffffffc0203c28:	49468693          	addi	a3,a3,1172 # ffffffffc02060b8 <nbase>
ffffffffc0203c2c:	40c58633          	sub	a2,a1,a2
ffffffffc0203c30:	630c                	ld	a1,0(a4)
ffffffffc0203c32:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c34:	0000e717          	auipc	a4,0xe
ffffffffc0203c38:	83c70713          	addi	a4,a4,-1988 # ffffffffc0211470 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c3c:	02b60633          	mul	a2,a2,a1
ffffffffc0203c40:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203c44:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c46:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c48:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c4a:	57fd                	li	a5,-1
ffffffffc0203c4c:	83b1                	srli	a5,a5,0xc
ffffffffc0203c4e:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c50:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c52:	02e7fa63          	bleu	a4,a5,ffffffffc0203c86 <swapfs_read+0x8c>
ffffffffc0203c56:	0000e797          	auipc	a5,0xe
ffffffffc0203c5a:	93278793          	addi	a5,a5,-1742 # ffffffffc0211588 <va_pa_offset>
ffffffffc0203c5e:	639c                	ld	a5,0(a5)
}
ffffffffc0203c60:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c62:	46a1                	li	a3,8
ffffffffc0203c64:	963e                	add	a2,a2,a5
ffffffffc0203c66:	4505                	li	a0,1
}
ffffffffc0203c68:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c6a:	f78fc06f          	j	ffffffffc02003e2 <ide_read_secs>
ffffffffc0203c6e:	86aa                	mv	a3,a0
ffffffffc0203c70:	00002617          	auipc	a2,0x2
ffffffffc0203c74:	1e060613          	addi	a2,a2,480 # ffffffffc0205e50 <default_pmm_manager+0x750>
ffffffffc0203c78:	45d1                	li	a1,20
ffffffffc0203c7a:	00002517          	auipc	a0,0x2
ffffffffc0203c7e:	1be50513          	addi	a0,a0,446 # ffffffffc0205e38 <default_pmm_manager+0x738>
ffffffffc0203c82:	c84fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203c86:	86b2                	mv	a3,a2
ffffffffc0203c88:	06a00593          	li	a1,106
ffffffffc0203c8c:	00002617          	auipc	a2,0x2
ffffffffc0203c90:	b9460613          	addi	a2,a2,-1132 # ffffffffc0205820 <default_pmm_manager+0x120>
ffffffffc0203c94:	00001517          	auipc	a0,0x1
ffffffffc0203c98:	2ec50513          	addi	a0,a0,748 # ffffffffc0204f80 <commands+0xb70>
ffffffffc0203c9c:	c6afc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203ca0 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203ca0:	1141                	addi	sp,sp,-16
ffffffffc0203ca2:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ca4:	00855793          	srli	a5,a0,0x8
ffffffffc0203ca8:	c7b5                	beqz	a5,ffffffffc0203d14 <swapfs_write+0x74>
ffffffffc0203caa:	0000e717          	auipc	a4,0xe
ffffffffc0203cae:	87670713          	addi	a4,a4,-1930 # ffffffffc0211520 <max_swap_offset>
ffffffffc0203cb2:	6318                	ld	a4,0(a4)
ffffffffc0203cb4:	06e7f063          	bleu	a4,a5,ffffffffc0203d14 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cb8:	0000e717          	auipc	a4,0xe
ffffffffc0203cbc:	8e070713          	addi	a4,a4,-1824 # ffffffffc0211598 <pages>
ffffffffc0203cc0:	6310                	ld	a2,0(a4)
ffffffffc0203cc2:	00001717          	auipc	a4,0x1
ffffffffc0203cc6:	6e670713          	addi	a4,a4,1766 # ffffffffc02053a8 <commands+0xf98>
ffffffffc0203cca:	00002697          	auipc	a3,0x2
ffffffffc0203cce:	3ee68693          	addi	a3,a3,1006 # ffffffffc02060b8 <nbase>
ffffffffc0203cd2:	40c58633          	sub	a2,a1,a2
ffffffffc0203cd6:	630c                	ld	a1,0(a4)
ffffffffc0203cd8:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cda:	0000d717          	auipc	a4,0xd
ffffffffc0203cde:	79670713          	addi	a4,a4,1942 # ffffffffc0211470 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ce2:	02b60633          	mul	a2,a2,a1
ffffffffc0203ce6:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203cea:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cec:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cee:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cf0:	57fd                	li	a5,-1
ffffffffc0203cf2:	83b1                	srli	a5,a5,0xc
ffffffffc0203cf4:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cf6:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cf8:	02e7fa63          	bleu	a4,a5,ffffffffc0203d2c <swapfs_write+0x8c>
ffffffffc0203cfc:	0000e797          	auipc	a5,0xe
ffffffffc0203d00:	88c78793          	addi	a5,a5,-1908 # ffffffffc0211588 <va_pa_offset>
ffffffffc0203d04:	639c                	ld	a5,0(a5)
}
ffffffffc0203d06:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d08:	46a1                	li	a3,8
ffffffffc0203d0a:	963e                	add	a2,a2,a5
ffffffffc0203d0c:	4505                	li	a0,1
}
ffffffffc0203d0e:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d10:	ef6fc06f          	j	ffffffffc0200406 <ide_write_secs>
ffffffffc0203d14:	86aa                	mv	a3,a0
ffffffffc0203d16:	00002617          	auipc	a2,0x2
ffffffffc0203d1a:	13a60613          	addi	a2,a2,314 # ffffffffc0205e50 <default_pmm_manager+0x750>
ffffffffc0203d1e:	45e5                	li	a1,25
ffffffffc0203d20:	00002517          	auipc	a0,0x2
ffffffffc0203d24:	11850513          	addi	a0,a0,280 # ffffffffc0205e38 <default_pmm_manager+0x738>
ffffffffc0203d28:	bdefc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0203d2c:	86b2                	mv	a3,a2
ffffffffc0203d2e:	06a00593          	li	a1,106
ffffffffc0203d32:	00002617          	auipc	a2,0x2
ffffffffc0203d36:	aee60613          	addi	a2,a2,-1298 # ffffffffc0205820 <default_pmm_manager+0x120>
ffffffffc0203d3a:	00001517          	auipc	a0,0x1
ffffffffc0203d3e:	24650513          	addi	a0,a0,582 # ffffffffc0204f80 <commands+0xb70>
ffffffffc0203d42:	bc4fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203d46 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203d46:	00054783          	lbu	a5,0(a0)
ffffffffc0203d4a:	cb91                	beqz	a5,ffffffffc0203d5e <strlen+0x18>
    size_t cnt = 0;
ffffffffc0203d4c:	4781                	li	a5,0
        cnt ++;
ffffffffc0203d4e:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0203d50:	00f50733          	add	a4,a0,a5
ffffffffc0203d54:	00074703          	lbu	a4,0(a4)
ffffffffc0203d58:	fb7d                	bnez	a4,ffffffffc0203d4e <strlen+0x8>
    }
    return cnt;
}
ffffffffc0203d5a:	853e                	mv	a0,a5
ffffffffc0203d5c:	8082                	ret
    size_t cnt = 0;
ffffffffc0203d5e:	4781                	li	a5,0
}
ffffffffc0203d60:	853e                	mv	a0,a5
ffffffffc0203d62:	8082                	ret

ffffffffc0203d64 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d64:	c185                	beqz	a1,ffffffffc0203d84 <strnlen+0x20>
ffffffffc0203d66:	00054783          	lbu	a5,0(a0)
ffffffffc0203d6a:	cf89                	beqz	a5,ffffffffc0203d84 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0203d6c:	4781                	li	a5,0
ffffffffc0203d6e:	a021                	j	ffffffffc0203d76 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d70:	00074703          	lbu	a4,0(a4)
ffffffffc0203d74:	c711                	beqz	a4,ffffffffc0203d80 <strnlen+0x1c>
        cnt ++;
ffffffffc0203d76:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d78:	00f50733          	add	a4,a0,a5
ffffffffc0203d7c:	fef59ae3          	bne	a1,a5,ffffffffc0203d70 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0203d80:	853e                	mv	a0,a5
ffffffffc0203d82:	8082                	ret
    size_t cnt = 0;
ffffffffc0203d84:	4781                	li	a5,0
}
ffffffffc0203d86:	853e                	mv	a0,a5
ffffffffc0203d88:	8082                	ret

ffffffffc0203d8a <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203d8a:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203d8c:	0585                	addi	a1,a1,1
ffffffffc0203d8e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203d92:	0785                	addi	a5,a5,1
ffffffffc0203d94:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203d98:	fb75                	bnez	a4,ffffffffc0203d8c <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203d9a:	8082                	ret

ffffffffc0203d9c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203d9c:	00054783          	lbu	a5,0(a0)
ffffffffc0203da0:	0005c703          	lbu	a4,0(a1)
ffffffffc0203da4:	cb91                	beqz	a5,ffffffffc0203db8 <strcmp+0x1c>
ffffffffc0203da6:	00e79c63          	bne	a5,a4,ffffffffc0203dbe <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0203daa:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203dac:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0203db0:	0585                	addi	a1,a1,1
ffffffffc0203db2:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203db6:	fbe5                	bnez	a5,ffffffffc0203da6 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203db8:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203dba:	9d19                	subw	a0,a0,a4
ffffffffc0203dbc:	8082                	ret
ffffffffc0203dbe:	0007851b          	sext.w	a0,a5
ffffffffc0203dc2:	9d19                	subw	a0,a0,a4
ffffffffc0203dc4:	8082                	ret

ffffffffc0203dc6 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203dc6:	00054783          	lbu	a5,0(a0)
ffffffffc0203dca:	cb91                	beqz	a5,ffffffffc0203dde <strchr+0x18>
        if (*s == c) {
ffffffffc0203dcc:	00b79563          	bne	a5,a1,ffffffffc0203dd6 <strchr+0x10>
ffffffffc0203dd0:	a809                	j	ffffffffc0203de2 <strchr+0x1c>
ffffffffc0203dd2:	00b78763          	beq	a5,a1,ffffffffc0203de0 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0203dd6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203dd8:	00054783          	lbu	a5,0(a0)
ffffffffc0203ddc:	fbfd                	bnez	a5,ffffffffc0203dd2 <strchr+0xc>
    }
    return NULL;
ffffffffc0203dde:	4501                	li	a0,0
}
ffffffffc0203de0:	8082                	ret
ffffffffc0203de2:	8082                	ret

ffffffffc0203de4 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203de4:	ca01                	beqz	a2,ffffffffc0203df4 <memset+0x10>
ffffffffc0203de6:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203de8:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203dea:	0785                	addi	a5,a5,1
ffffffffc0203dec:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203df0:	fec79de3          	bne	a5,a2,ffffffffc0203dea <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203df4:	8082                	ret

ffffffffc0203df6 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203df6:	ca19                	beqz	a2,ffffffffc0203e0c <memcpy+0x16>
ffffffffc0203df8:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203dfa:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203dfc:	0585                	addi	a1,a1,1
ffffffffc0203dfe:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203e02:	0785                	addi	a5,a5,1
ffffffffc0203e04:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203e08:	fec59ae3          	bne	a1,a2,ffffffffc0203dfc <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203e0c:	8082                	ret

ffffffffc0203e0e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203e0e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e12:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203e14:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e18:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203e1a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e1e:	f022                	sd	s0,32(sp)
ffffffffc0203e20:	ec26                	sd	s1,24(sp)
ffffffffc0203e22:	e84a                	sd	s2,16(sp)
ffffffffc0203e24:	f406                	sd	ra,40(sp)
ffffffffc0203e26:	e44e                	sd	s3,8(sp)
ffffffffc0203e28:	84aa                	mv	s1,a0
ffffffffc0203e2a:	892e                	mv	s2,a1
ffffffffc0203e2c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203e30:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203e32:	03067e63          	bleu	a6,a2,ffffffffc0203e6e <printnum+0x60>
ffffffffc0203e36:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203e38:	00805763          	blez	s0,ffffffffc0203e46 <printnum+0x38>
ffffffffc0203e3c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203e3e:	85ca                	mv	a1,s2
ffffffffc0203e40:	854e                	mv	a0,s3
ffffffffc0203e42:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203e44:	fc65                	bnez	s0,ffffffffc0203e3c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e46:	1a02                	slli	s4,s4,0x20
ffffffffc0203e48:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203e4c:	00002797          	auipc	a5,0x2
ffffffffc0203e50:	1b478793          	addi	a5,a5,436 # ffffffffc0206000 <error_string+0x38>
ffffffffc0203e54:	9a3e                	add	s4,s4,a5
}
ffffffffc0203e56:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e58:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203e5c:	70a2                	ld	ra,40(sp)
ffffffffc0203e5e:	69a2                	ld	s3,8(sp)
ffffffffc0203e60:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e62:	85ca                	mv	a1,s2
ffffffffc0203e64:	8326                	mv	t1,s1
}
ffffffffc0203e66:	6942                	ld	s2,16(sp)
ffffffffc0203e68:	64e2                	ld	s1,24(sp)
ffffffffc0203e6a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e6c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203e6e:	03065633          	divu	a2,a2,a6
ffffffffc0203e72:	8722                	mv	a4,s0
ffffffffc0203e74:	f9bff0ef          	jal	ra,ffffffffc0203e0e <printnum>
ffffffffc0203e78:	b7f9                	j	ffffffffc0203e46 <printnum+0x38>

ffffffffc0203e7a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203e7a:	7119                	addi	sp,sp,-128
ffffffffc0203e7c:	f4a6                	sd	s1,104(sp)
ffffffffc0203e7e:	f0ca                	sd	s2,96(sp)
ffffffffc0203e80:	e8d2                	sd	s4,80(sp)
ffffffffc0203e82:	e4d6                	sd	s5,72(sp)
ffffffffc0203e84:	e0da                	sd	s6,64(sp)
ffffffffc0203e86:	fc5e                	sd	s7,56(sp)
ffffffffc0203e88:	f862                	sd	s8,48(sp)
ffffffffc0203e8a:	f06a                	sd	s10,32(sp)
ffffffffc0203e8c:	fc86                	sd	ra,120(sp)
ffffffffc0203e8e:	f8a2                	sd	s0,112(sp)
ffffffffc0203e90:	ecce                	sd	s3,88(sp)
ffffffffc0203e92:	f466                	sd	s9,40(sp)
ffffffffc0203e94:	ec6e                	sd	s11,24(sp)
ffffffffc0203e96:	892a                	mv	s2,a0
ffffffffc0203e98:	84ae                	mv	s1,a1
ffffffffc0203e9a:	8d32                	mv	s10,a2
ffffffffc0203e9c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203e9e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ea0:	00002a17          	auipc	s4,0x2
ffffffffc0203ea4:	fd0a0a13          	addi	s4,s4,-48 # ffffffffc0205e70 <default_pmm_manager+0x770>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203ea8:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203eac:	00002c17          	auipc	s8,0x2
ffffffffc0203eb0:	11cc0c13          	addi	s8,s8,284 # ffffffffc0205fc8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203eb4:	000d4503          	lbu	a0,0(s10)
ffffffffc0203eb8:	02500793          	li	a5,37
ffffffffc0203ebc:	001d0413          	addi	s0,s10,1
ffffffffc0203ec0:	00f50e63          	beq	a0,a5,ffffffffc0203edc <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203ec4:	c521                	beqz	a0,ffffffffc0203f0c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ec6:	02500993          	li	s3,37
ffffffffc0203eca:	a011                	j	ffffffffc0203ece <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203ecc:	c121                	beqz	a0,ffffffffc0203f0c <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203ece:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ed0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203ed2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ed4:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203ed8:	ff351ae3          	bne	a0,s3,ffffffffc0203ecc <vprintfmt+0x52>
ffffffffc0203edc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203ee0:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203ee4:	4981                	li	s3,0
ffffffffc0203ee6:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203ee8:	5cfd                	li	s9,-1
ffffffffc0203eea:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203eec:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203ef0:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ef2:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203ef6:	0ff6f693          	andi	a3,a3,255
ffffffffc0203efa:	00140d13          	addi	s10,s0,1
ffffffffc0203efe:	20d5e563          	bltu	a1,a3,ffffffffc0204108 <vprintfmt+0x28e>
ffffffffc0203f02:	068a                	slli	a3,a3,0x2
ffffffffc0203f04:	96d2                	add	a3,a3,s4
ffffffffc0203f06:	4294                	lw	a3,0(a3)
ffffffffc0203f08:	96d2                	add	a3,a3,s4
ffffffffc0203f0a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203f0c:	70e6                	ld	ra,120(sp)
ffffffffc0203f0e:	7446                	ld	s0,112(sp)
ffffffffc0203f10:	74a6                	ld	s1,104(sp)
ffffffffc0203f12:	7906                	ld	s2,96(sp)
ffffffffc0203f14:	69e6                	ld	s3,88(sp)
ffffffffc0203f16:	6a46                	ld	s4,80(sp)
ffffffffc0203f18:	6aa6                	ld	s5,72(sp)
ffffffffc0203f1a:	6b06                	ld	s6,64(sp)
ffffffffc0203f1c:	7be2                	ld	s7,56(sp)
ffffffffc0203f1e:	7c42                	ld	s8,48(sp)
ffffffffc0203f20:	7ca2                	ld	s9,40(sp)
ffffffffc0203f22:	7d02                	ld	s10,32(sp)
ffffffffc0203f24:	6de2                	ld	s11,24(sp)
ffffffffc0203f26:	6109                	addi	sp,sp,128
ffffffffc0203f28:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203f2a:	4705                	li	a4,1
ffffffffc0203f2c:	008a8593          	addi	a1,s5,8
ffffffffc0203f30:	01074463          	blt	a4,a6,ffffffffc0203f38 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203f34:	26080363          	beqz	a6,ffffffffc020419a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203f38:	000ab603          	ld	a2,0(s5)
ffffffffc0203f3c:	46c1                	li	a3,16
ffffffffc0203f3e:	8aae                	mv	s5,a1
ffffffffc0203f40:	a06d                	j	ffffffffc0203fea <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203f42:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203f46:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f48:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203f4a:	b765                	j	ffffffffc0203ef2 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203f4c:	000aa503          	lw	a0,0(s5)
ffffffffc0203f50:	85a6                	mv	a1,s1
ffffffffc0203f52:	0aa1                	addi	s5,s5,8
ffffffffc0203f54:	9902                	jalr	s2
            break;
ffffffffc0203f56:	bfb9                	j	ffffffffc0203eb4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203f58:	4705                	li	a4,1
ffffffffc0203f5a:	008a8993          	addi	s3,s5,8
ffffffffc0203f5e:	01074463          	blt	a4,a6,ffffffffc0203f66 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203f62:	22080463          	beqz	a6,ffffffffc020418a <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203f66:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203f6a:	24044463          	bltz	s0,ffffffffc02041b2 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203f6e:	8622                	mv	a2,s0
ffffffffc0203f70:	8ace                	mv	s5,s3
ffffffffc0203f72:	46a9                	li	a3,10
ffffffffc0203f74:	a89d                	j	ffffffffc0203fea <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203f76:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f7a:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203f7c:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203f7e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203f82:	8fb5                	xor	a5,a5,a3
ffffffffc0203f84:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f88:	1ad74363          	blt	a4,a3,ffffffffc020412e <vprintfmt+0x2b4>
ffffffffc0203f8c:	00369793          	slli	a5,a3,0x3
ffffffffc0203f90:	97e2                	add	a5,a5,s8
ffffffffc0203f92:	639c                	ld	a5,0(a5)
ffffffffc0203f94:	18078d63          	beqz	a5,ffffffffc020412e <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203f98:	86be                	mv	a3,a5
ffffffffc0203f9a:	00002617          	auipc	a2,0x2
ffffffffc0203f9e:	11660613          	addi	a2,a2,278 # ffffffffc02060b0 <error_string+0xe8>
ffffffffc0203fa2:	85a6                	mv	a1,s1
ffffffffc0203fa4:	854a                	mv	a0,s2
ffffffffc0203fa6:	240000ef          	jal	ra,ffffffffc02041e6 <printfmt>
ffffffffc0203faa:	b729                	j	ffffffffc0203eb4 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203fac:	00144603          	lbu	a2,1(s0)
ffffffffc0203fb0:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203fb2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203fb4:	bf3d                	j	ffffffffc0203ef2 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203fb6:	4705                	li	a4,1
ffffffffc0203fb8:	008a8593          	addi	a1,s5,8
ffffffffc0203fbc:	01074463          	blt	a4,a6,ffffffffc0203fc4 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203fc0:	1e080263          	beqz	a6,ffffffffc02041a4 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203fc4:	000ab603          	ld	a2,0(s5)
ffffffffc0203fc8:	46a1                	li	a3,8
ffffffffc0203fca:	8aae                	mv	s5,a1
ffffffffc0203fcc:	a839                	j	ffffffffc0203fea <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0203fce:	03000513          	li	a0,48
ffffffffc0203fd2:	85a6                	mv	a1,s1
ffffffffc0203fd4:	e03e                	sd	a5,0(sp)
ffffffffc0203fd6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203fd8:	85a6                	mv	a1,s1
ffffffffc0203fda:	07800513          	li	a0,120
ffffffffc0203fde:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203fe0:	0aa1                	addi	s5,s5,8
ffffffffc0203fe2:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203fe6:	6782                	ld	a5,0(sp)
ffffffffc0203fe8:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203fea:	876e                	mv	a4,s11
ffffffffc0203fec:	85a6                	mv	a1,s1
ffffffffc0203fee:	854a                	mv	a0,s2
ffffffffc0203ff0:	e1fff0ef          	jal	ra,ffffffffc0203e0e <printnum>
            break;
ffffffffc0203ff4:	b5c1                	j	ffffffffc0203eb4 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203ff6:	000ab603          	ld	a2,0(s5)
ffffffffc0203ffa:	0aa1                	addi	s5,s5,8
ffffffffc0203ffc:	1c060663          	beqz	a2,ffffffffc02041c8 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0204000:	00160413          	addi	s0,a2,1
ffffffffc0204004:	17b05c63          	blez	s11,ffffffffc020417c <vprintfmt+0x302>
ffffffffc0204008:	02d00593          	li	a1,45
ffffffffc020400c:	14b79263          	bne	a5,a1,ffffffffc0204150 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204010:	00064783          	lbu	a5,0(a2)
ffffffffc0204014:	0007851b          	sext.w	a0,a5
ffffffffc0204018:	c905                	beqz	a0,ffffffffc0204048 <vprintfmt+0x1ce>
ffffffffc020401a:	000cc563          	bltz	s9,ffffffffc0204024 <vprintfmt+0x1aa>
ffffffffc020401e:	3cfd                	addiw	s9,s9,-1
ffffffffc0204020:	036c8263          	beq	s9,s6,ffffffffc0204044 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204024:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204026:	18098463          	beqz	s3,ffffffffc02041ae <vprintfmt+0x334>
ffffffffc020402a:	3781                	addiw	a5,a5,-32
ffffffffc020402c:	18fbf163          	bleu	a5,s7,ffffffffc02041ae <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204030:	03f00513          	li	a0,63
ffffffffc0204034:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204036:	0405                	addi	s0,s0,1
ffffffffc0204038:	fff44783          	lbu	a5,-1(s0)
ffffffffc020403c:	3dfd                	addiw	s11,s11,-1
ffffffffc020403e:	0007851b          	sext.w	a0,a5
ffffffffc0204042:	fd61                	bnez	a0,ffffffffc020401a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0204044:	e7b058e3          	blez	s11,ffffffffc0203eb4 <vprintfmt+0x3a>
ffffffffc0204048:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020404a:	85a6                	mv	a1,s1
ffffffffc020404c:	02000513          	li	a0,32
ffffffffc0204050:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204052:	e60d81e3          	beqz	s11,ffffffffc0203eb4 <vprintfmt+0x3a>
ffffffffc0204056:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204058:	85a6                	mv	a1,s1
ffffffffc020405a:	02000513          	li	a0,32
ffffffffc020405e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204060:	fe0d94e3          	bnez	s11,ffffffffc0204048 <vprintfmt+0x1ce>
ffffffffc0204064:	bd81                	j	ffffffffc0203eb4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204066:	4705                	li	a4,1
ffffffffc0204068:	008a8593          	addi	a1,s5,8
ffffffffc020406c:	01074463          	blt	a4,a6,ffffffffc0204074 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204070:	12080063          	beqz	a6,ffffffffc0204190 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204074:	000ab603          	ld	a2,0(s5)
ffffffffc0204078:	46a9                	li	a3,10
ffffffffc020407a:	8aae                	mv	s5,a1
ffffffffc020407c:	b7bd                	j	ffffffffc0203fea <vprintfmt+0x170>
ffffffffc020407e:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204082:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204086:	846a                	mv	s0,s10
ffffffffc0204088:	b5ad                	j	ffffffffc0203ef2 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020408a:	85a6                	mv	a1,s1
ffffffffc020408c:	02500513          	li	a0,37
ffffffffc0204090:	9902                	jalr	s2
            break;
ffffffffc0204092:	b50d                	j	ffffffffc0203eb4 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204094:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204098:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020409c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020409e:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02040a0:	e40dd9e3          	bgez	s11,ffffffffc0203ef2 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02040a4:	8de6                	mv	s11,s9
ffffffffc02040a6:	5cfd                	li	s9,-1
ffffffffc02040a8:	b5a9                	j	ffffffffc0203ef2 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02040aa:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02040ae:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040b2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040b4:	bd3d                	j	ffffffffc0203ef2 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02040b6:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02040ba:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040be:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02040c0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02040c4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040c8:	fcd56ce3          	bltu	a0,a3,ffffffffc02040a0 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02040cc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02040ce:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02040d2:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02040d6:	0196873b          	addw	a4,a3,s9
ffffffffc02040da:	0017171b          	slliw	a4,a4,0x1
ffffffffc02040de:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02040e2:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02040e6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02040ea:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040ee:	fcd57fe3          	bleu	a3,a0,ffffffffc02040cc <vprintfmt+0x252>
ffffffffc02040f2:	b77d                	j	ffffffffc02040a0 <vprintfmt+0x226>
            if (width < 0)
ffffffffc02040f4:	fffdc693          	not	a3,s11
ffffffffc02040f8:	96fd                	srai	a3,a3,0x3f
ffffffffc02040fa:	00ddfdb3          	and	s11,s11,a3
ffffffffc02040fe:	00144603          	lbu	a2,1(s0)
ffffffffc0204102:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204104:	846a                	mv	s0,s10
ffffffffc0204106:	b3f5                	j	ffffffffc0203ef2 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0204108:	85a6                	mv	a1,s1
ffffffffc020410a:	02500513          	li	a0,37
ffffffffc020410e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204110:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204114:	02500793          	li	a5,37
ffffffffc0204118:	8d22                	mv	s10,s0
ffffffffc020411a:	d8f70de3          	beq	a4,a5,ffffffffc0203eb4 <vprintfmt+0x3a>
ffffffffc020411e:	02500713          	li	a4,37
ffffffffc0204122:	1d7d                	addi	s10,s10,-1
ffffffffc0204124:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204128:	fee79de3          	bne	a5,a4,ffffffffc0204122 <vprintfmt+0x2a8>
ffffffffc020412c:	b361                	j	ffffffffc0203eb4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020412e:	00002617          	auipc	a2,0x2
ffffffffc0204132:	f7260613          	addi	a2,a2,-142 # ffffffffc02060a0 <error_string+0xd8>
ffffffffc0204136:	85a6                	mv	a1,s1
ffffffffc0204138:	854a                	mv	a0,s2
ffffffffc020413a:	0ac000ef          	jal	ra,ffffffffc02041e6 <printfmt>
ffffffffc020413e:	bb9d                	j	ffffffffc0203eb4 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204140:	00002617          	auipc	a2,0x2
ffffffffc0204144:	f5860613          	addi	a2,a2,-168 # ffffffffc0206098 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204148:	00002417          	auipc	s0,0x2
ffffffffc020414c:	f5140413          	addi	s0,s0,-175 # ffffffffc0206099 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204150:	8532                	mv	a0,a2
ffffffffc0204152:	85e6                	mv	a1,s9
ffffffffc0204154:	e032                	sd	a2,0(sp)
ffffffffc0204156:	e43e                	sd	a5,8(sp)
ffffffffc0204158:	c0dff0ef          	jal	ra,ffffffffc0203d64 <strnlen>
ffffffffc020415c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204160:	6602                	ld	a2,0(sp)
ffffffffc0204162:	01b05d63          	blez	s11,ffffffffc020417c <vprintfmt+0x302>
ffffffffc0204166:	67a2                	ld	a5,8(sp)
ffffffffc0204168:	2781                	sext.w	a5,a5
ffffffffc020416a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020416c:	6522                	ld	a0,8(sp)
ffffffffc020416e:	85a6                	mv	a1,s1
ffffffffc0204170:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204172:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204174:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204176:	6602                	ld	a2,0(sp)
ffffffffc0204178:	fe0d9ae3          	bnez	s11,ffffffffc020416c <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020417c:	00064783          	lbu	a5,0(a2)
ffffffffc0204180:	0007851b          	sext.w	a0,a5
ffffffffc0204184:	e8051be3          	bnez	a0,ffffffffc020401a <vprintfmt+0x1a0>
ffffffffc0204188:	b335                	j	ffffffffc0203eb4 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020418a:	000aa403          	lw	s0,0(s5)
ffffffffc020418e:	bbf1                	j	ffffffffc0203f6a <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204190:	000ae603          	lwu	a2,0(s5)
ffffffffc0204194:	46a9                	li	a3,10
ffffffffc0204196:	8aae                	mv	s5,a1
ffffffffc0204198:	bd89                	j	ffffffffc0203fea <vprintfmt+0x170>
ffffffffc020419a:	000ae603          	lwu	a2,0(s5)
ffffffffc020419e:	46c1                	li	a3,16
ffffffffc02041a0:	8aae                	mv	s5,a1
ffffffffc02041a2:	b5a1                	j	ffffffffc0203fea <vprintfmt+0x170>
ffffffffc02041a4:	000ae603          	lwu	a2,0(s5)
ffffffffc02041a8:	46a1                	li	a3,8
ffffffffc02041aa:	8aae                	mv	s5,a1
ffffffffc02041ac:	bd3d                	j	ffffffffc0203fea <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02041ae:	9902                	jalr	s2
ffffffffc02041b0:	b559                	j	ffffffffc0204036 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02041b2:	85a6                	mv	a1,s1
ffffffffc02041b4:	02d00513          	li	a0,45
ffffffffc02041b8:	e03e                	sd	a5,0(sp)
ffffffffc02041ba:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02041bc:	8ace                	mv	s5,s3
ffffffffc02041be:	40800633          	neg	a2,s0
ffffffffc02041c2:	46a9                	li	a3,10
ffffffffc02041c4:	6782                	ld	a5,0(sp)
ffffffffc02041c6:	b515                	j	ffffffffc0203fea <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02041c8:	01b05663          	blez	s11,ffffffffc02041d4 <vprintfmt+0x35a>
ffffffffc02041cc:	02d00693          	li	a3,45
ffffffffc02041d0:	f6d798e3          	bne	a5,a3,ffffffffc0204140 <vprintfmt+0x2c6>
ffffffffc02041d4:	00002417          	auipc	s0,0x2
ffffffffc02041d8:	ec540413          	addi	s0,s0,-315 # ffffffffc0206099 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041dc:	02800513          	li	a0,40
ffffffffc02041e0:	02800793          	li	a5,40
ffffffffc02041e4:	bd1d                	j	ffffffffc020401a <vprintfmt+0x1a0>

ffffffffc02041e6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041e6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02041e8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041ec:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041ee:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041f0:	ec06                	sd	ra,24(sp)
ffffffffc02041f2:	f83a                	sd	a4,48(sp)
ffffffffc02041f4:	fc3e                	sd	a5,56(sp)
ffffffffc02041f6:	e0c2                	sd	a6,64(sp)
ffffffffc02041f8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02041fa:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041fc:	c7fff0ef          	jal	ra,ffffffffc0203e7a <vprintfmt>
}
ffffffffc0204200:	60e2                	ld	ra,24(sp)
ffffffffc0204202:	6161                	addi	sp,sp,80
ffffffffc0204204:	8082                	ret

ffffffffc0204206 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204206:	715d                	addi	sp,sp,-80
ffffffffc0204208:	e486                	sd	ra,72(sp)
ffffffffc020420a:	e0a2                	sd	s0,64(sp)
ffffffffc020420c:	fc26                	sd	s1,56(sp)
ffffffffc020420e:	f84a                	sd	s2,48(sp)
ffffffffc0204210:	f44e                	sd	s3,40(sp)
ffffffffc0204212:	f052                	sd	s4,32(sp)
ffffffffc0204214:	ec56                	sd	s5,24(sp)
ffffffffc0204216:	e85a                	sd	s6,16(sp)
ffffffffc0204218:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020421a:	c901                	beqz	a0,ffffffffc020422a <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020421c:	85aa                	mv	a1,a0
ffffffffc020421e:	00002517          	auipc	a0,0x2
ffffffffc0204222:	e9250513          	addi	a0,a0,-366 # ffffffffc02060b0 <error_string+0xe8>
ffffffffc0204226:	e99fb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc020422a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020422c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020422e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204230:	4aa9                	li	s5,10
ffffffffc0204232:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204234:	0000db97          	auipc	s7,0xd
ffffffffc0204238:	e0cb8b93          	addi	s7,s7,-500 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020423c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204240:	eb7fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204244:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204246:	00054b63          	bltz	a0,ffffffffc020425c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020424a:	00a95b63          	ble	a0,s2,ffffffffc0204260 <readline+0x5a>
ffffffffc020424e:	029a5463          	ble	s1,s4,ffffffffc0204276 <readline+0x70>
        c = getchar();
ffffffffc0204252:	ea5fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204256:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204258:	fe0559e3          	bgez	a0,ffffffffc020424a <readline+0x44>
            return NULL;
ffffffffc020425c:	4501                	li	a0,0
ffffffffc020425e:	a099                	j	ffffffffc02042a4 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0204260:	03341463          	bne	s0,s3,ffffffffc0204288 <readline+0x82>
ffffffffc0204264:	e8b9                	bnez	s1,ffffffffc02042ba <readline+0xb4>
        c = getchar();
ffffffffc0204266:	e91fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc020426a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020426c:	fe0548e3          	bltz	a0,ffffffffc020425c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204270:	fea958e3          	ble	a0,s2,ffffffffc0204260 <readline+0x5a>
ffffffffc0204274:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204276:	8522                	mv	a0,s0
ffffffffc0204278:	e7bfb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc020427c:	009b87b3          	add	a5,s7,s1
ffffffffc0204280:	00878023          	sb	s0,0(a5)
ffffffffc0204284:	2485                	addiw	s1,s1,1
ffffffffc0204286:	bf6d                	j	ffffffffc0204240 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0204288:	01540463          	beq	s0,s5,ffffffffc0204290 <readline+0x8a>
ffffffffc020428c:	fb641ae3          	bne	s0,s6,ffffffffc0204240 <readline+0x3a>
            cputchar(c);
ffffffffc0204290:	8522                	mv	a0,s0
ffffffffc0204292:	e61fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0204296:	0000d517          	auipc	a0,0xd
ffffffffc020429a:	daa50513          	addi	a0,a0,-598 # ffffffffc0211040 <buf>
ffffffffc020429e:	94aa                	add	s1,s1,a0
ffffffffc02042a0:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02042a4:	60a6                	ld	ra,72(sp)
ffffffffc02042a6:	6406                	ld	s0,64(sp)
ffffffffc02042a8:	74e2                	ld	s1,56(sp)
ffffffffc02042aa:	7942                	ld	s2,48(sp)
ffffffffc02042ac:	79a2                	ld	s3,40(sp)
ffffffffc02042ae:	7a02                	ld	s4,32(sp)
ffffffffc02042b0:	6ae2                	ld	s5,24(sp)
ffffffffc02042b2:	6b42                	ld	s6,16(sp)
ffffffffc02042b4:	6ba2                	ld	s7,8(sp)
ffffffffc02042b6:	6161                	addi	sp,sp,80
ffffffffc02042b8:	8082                	ret
            cputchar(c);
ffffffffc02042ba:	4521                	li	a0,8
ffffffffc02042bc:	e37fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc02042c0:	34fd                	addiw	s1,s1,-1
ffffffffc02042c2:	bfbd                	j	ffffffffc0204240 <readline+0x3a>
