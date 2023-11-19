
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
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	02a50513          	addi	a0,a0,42 # ffffffffc020a060 <edata>
ffffffffc020003e:	00015617          	auipc	a2,0x15
ffffffffc0200042:	5c260613          	addi	a2,a2,1474 # ffffffffc0215600 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	1d5040ef          	jal	ra,ffffffffc0204a22 <memset>

    cons_init();                // init the console
ffffffffc0200052:	50c000ef          	jal	ra,ffffffffc020055e <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	e3a58593          	addi	a1,a1,-454 # ffffffffc0204e90 <etext+0x4>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	e5250513          	addi	a0,a0,-430 # ffffffffc0204eb0 <etext+0x24>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	1cc000ef          	jal	ra,ffffffffc0200236 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	4ba030ef          	jal	ra,ffffffffc0203528 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	560000ef          	jal	ra,ffffffffc02005d2 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5dc000ef          	jal	ra,ffffffffc0200652 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	4fd000ef          	jal	ra,ffffffffc0200d76 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	62a040ef          	jal	ra,ffffffffc02046a8 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	42e000ef          	jal	ra,ffffffffc02004b0 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	3a3010ef          	jal	ra,ffffffffc0201c28 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	47e000ef          	jal	ra,ffffffffc0200508 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	546000ef          	jal	ra,ffffffffc02005d4 <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	00b040ef          	jal	ra,ffffffffc020489c <cpu_idle>

ffffffffc0200096 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200096:	1141                	addi	sp,sp,-16
ffffffffc0200098:	e022                	sd	s0,0(sp)
ffffffffc020009a:	e406                	sd	ra,8(sp)
ffffffffc020009c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009e:	4c2000ef          	jal	ra,ffffffffc0200560 <cons_putc>
    (*cnt) ++;
ffffffffc02000a2:	401c                	lw	a5,0(s0)
}
ffffffffc02000a4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a6:	2785                	addiw	a5,a5,1
ffffffffc02000a8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000aa:	6402                	ld	s0,0(sp)
ffffffffc02000ac:	0141                	addi	sp,sp,16
ffffffffc02000ae:	8082                	ret

ffffffffc02000b0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b0:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	86ae                	mv	a3,a1
ffffffffc02000b4:	862a                	mv	a2,a0
ffffffffc02000b6:	006c                	addi	a1,sp,12
ffffffffc02000b8:	00000517          	auipc	a0,0x0
ffffffffc02000bc:	fde50513          	addi	a0,a0,-34 # ffffffffc0200096 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000c2:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c4:	225040ef          	jal	ra,ffffffffc0204ae8 <vprintfmt>
    return cnt;
}
ffffffffc02000c8:	60e2                	ld	ra,24(sp)
ffffffffc02000ca:	4532                	lw	a0,12(sp)
ffffffffc02000cc:	6105                	addi	sp,sp,32
ffffffffc02000ce:	8082                	ret

ffffffffc02000d0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	f42e                	sd	a1,40(sp)
ffffffffc02000d8:	f832                	sd	a2,48(sp)
ffffffffc02000da:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	862a                	mv	a2,a0
ffffffffc02000de:	004c                	addi	a1,sp,4
ffffffffc02000e0:	00000517          	auipc	a0,0x0
ffffffffc02000e4:	fb650513          	addi	a0,a0,-74 # ffffffffc0200096 <cputch>
ffffffffc02000e8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e0ba                	sd	a4,64(sp)
ffffffffc02000ee:	e4be                	sd	a5,72(sp)
ffffffffc02000f0:	e8c2                	sd	a6,80(sp)
ffffffffc02000f2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f8:	1f1040ef          	jal	ra,ffffffffc0204ae8 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fc:	60e2                	ld	ra,24(sp)
ffffffffc02000fe:	4512                	lw	a0,4(sp)
ffffffffc0200100:	6125                	addi	sp,sp,96
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200104:	45c0006f          	j	ffffffffc0200560 <cons_putc>

ffffffffc0200108 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200108:	1141                	addi	sp,sp,-16
ffffffffc020010a:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020010c:	48a000ef          	jal	ra,ffffffffc0200596 <cons_getc>
ffffffffc0200110:	dd75                	beqz	a0,ffffffffc020010c <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200112:	60a2                	ld	ra,8(sp)
ffffffffc0200114:	0141                	addi	sp,sp,16
ffffffffc0200116:	8082                	ret

ffffffffc0200118 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200118:	715d                	addi	sp,sp,-80
ffffffffc020011a:	e486                	sd	ra,72(sp)
ffffffffc020011c:	e0a2                	sd	s0,64(sp)
ffffffffc020011e:	fc26                	sd	s1,56(sp)
ffffffffc0200120:	f84a                	sd	s2,48(sp)
ffffffffc0200122:	f44e                	sd	s3,40(sp)
ffffffffc0200124:	f052                	sd	s4,32(sp)
ffffffffc0200126:	ec56                	sd	s5,24(sp)
ffffffffc0200128:	e85a                	sd	s6,16(sp)
ffffffffc020012a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020012c:	c901                	beqz	a0,ffffffffc020013c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020012e:	85aa                	mv	a1,a0
ffffffffc0200130:	00005517          	auipc	a0,0x5
ffffffffc0200134:	d8850513          	addi	a0,a0,-632 # ffffffffc0204eb8 <etext+0x2c>
ffffffffc0200138:	f99ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020013c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020013e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200140:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200142:	4aa9                	li	s5,10
ffffffffc0200144:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200146:	0000ab97          	auipc	s7,0xa
ffffffffc020014a:	f1ab8b93          	addi	s7,s7,-230 # ffffffffc020a060 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020014e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200152:	fb7ff0ef          	jal	ra,ffffffffc0200108 <getchar>
ffffffffc0200156:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200158:	00054b63          	bltz	a0,ffffffffc020016e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020015c:	00a95b63          	ble	a0,s2,ffffffffc0200172 <readline+0x5a>
ffffffffc0200160:	029a5463          	ble	s1,s4,ffffffffc0200188 <readline+0x70>
        c = getchar();
ffffffffc0200164:	fa5ff0ef          	jal	ra,ffffffffc0200108 <getchar>
ffffffffc0200168:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020016a:	fe0559e3          	bgez	a0,ffffffffc020015c <readline+0x44>
            return NULL;
ffffffffc020016e:	4501                	li	a0,0
ffffffffc0200170:	a099                	j	ffffffffc02001b6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0200172:	03341463          	bne	s0,s3,ffffffffc020019a <readline+0x82>
ffffffffc0200176:	e8b9                	bnez	s1,ffffffffc02001cc <readline+0xb4>
        c = getchar();
ffffffffc0200178:	f91ff0ef          	jal	ra,ffffffffc0200108 <getchar>
ffffffffc020017c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020017e:	fe0548e3          	bltz	a0,ffffffffc020016e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200182:	fea958e3          	ble	a0,s2,ffffffffc0200172 <readline+0x5a>
ffffffffc0200186:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200188:	8522                	mv	a0,s0
ffffffffc020018a:	f7bff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc020018e:	009b87b3          	add	a5,s7,s1
ffffffffc0200192:	00878023          	sb	s0,0(a5)
ffffffffc0200196:	2485                	addiw	s1,s1,1
ffffffffc0200198:	bf6d                	j	ffffffffc0200152 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020019a:	01540463          	beq	s0,s5,ffffffffc02001a2 <readline+0x8a>
ffffffffc020019e:	fb641ae3          	bne	s0,s6,ffffffffc0200152 <readline+0x3a>
            cputchar(c);
ffffffffc02001a2:	8522                	mv	a0,s0
ffffffffc02001a4:	f61ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001a8:	0000a517          	auipc	a0,0xa
ffffffffc02001ac:	eb850513          	addi	a0,a0,-328 # ffffffffc020a060 <edata>
ffffffffc02001b0:	94aa                	add	s1,s1,a0
ffffffffc02001b2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001b6:	60a6                	ld	ra,72(sp)
ffffffffc02001b8:	6406                	ld	s0,64(sp)
ffffffffc02001ba:	74e2                	ld	s1,56(sp)
ffffffffc02001bc:	7942                	ld	s2,48(sp)
ffffffffc02001be:	79a2                	ld	s3,40(sp)
ffffffffc02001c0:	7a02                	ld	s4,32(sp)
ffffffffc02001c2:	6ae2                	ld	s5,24(sp)
ffffffffc02001c4:	6b42                	ld	s6,16(sp)
ffffffffc02001c6:	6ba2                	ld	s7,8(sp)
ffffffffc02001c8:	6161                	addi	sp,sp,80
ffffffffc02001ca:	8082                	ret
            cputchar(c);
ffffffffc02001cc:	4521                	li	a0,8
ffffffffc02001ce:	f37ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc02001d2:	34fd                	addiw	s1,s1,-1
ffffffffc02001d4:	bfbd                	j	ffffffffc0200152 <readline+0x3a>

ffffffffc02001d6 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001d6:	00015317          	auipc	t1,0x15
ffffffffc02001da:	29a30313          	addi	t1,t1,666 # ffffffffc0215470 <is_panic>
ffffffffc02001de:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001e2:	715d                	addi	sp,sp,-80
ffffffffc02001e4:	ec06                	sd	ra,24(sp)
ffffffffc02001e6:	e822                	sd	s0,16(sp)
ffffffffc02001e8:	f436                	sd	a3,40(sp)
ffffffffc02001ea:	f83a                	sd	a4,48(sp)
ffffffffc02001ec:	fc3e                	sd	a5,56(sp)
ffffffffc02001ee:	e0c2                	sd	a6,64(sp)
ffffffffc02001f0:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001f2:	02031c63          	bnez	t1,ffffffffc020022a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001f6:	4785                	li	a5,1
ffffffffc02001f8:	8432                	mv	s0,a2
ffffffffc02001fa:	00015717          	auipc	a4,0x15
ffffffffc02001fe:	26f72b23          	sw	a5,630(a4) # ffffffffc0215470 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200202:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200204:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200206:	85aa                	mv	a1,a0
ffffffffc0200208:	00005517          	auipc	a0,0x5
ffffffffc020020c:	cb850513          	addi	a0,a0,-840 # ffffffffc0204ec0 <etext+0x34>
    va_start(ap, fmt);
ffffffffc0200210:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200212:	ebfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200216:	65a2                	ld	a1,8(sp)
ffffffffc0200218:	8522                	mv	a0,s0
ffffffffc020021a:	e97ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020021e:	00006517          	auipc	a0,0x6
ffffffffc0200222:	74a50513          	addi	a0,a0,1866 # ffffffffc0206968 <default_pmm_manager+0x3e8>
ffffffffc0200226:	eabff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020022a:	3b0000ef          	jal	ra,ffffffffc02005da <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020022e:	4501                	li	a0,0
ffffffffc0200230:	132000ef          	jal	ra,ffffffffc0200362 <kmonitor>
ffffffffc0200234:	bfed                	j	ffffffffc020022e <__panic+0x58>

ffffffffc0200236 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200236:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200238:	00005517          	auipc	a0,0x5
ffffffffc020023c:	cd850513          	addi	a0,a0,-808 # ffffffffc0204f10 <etext+0x84>
void print_kerninfo(void) {
ffffffffc0200240:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200242:	e8fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200246:	00000597          	auipc	a1,0x0
ffffffffc020024a:	df058593          	addi	a1,a1,-528 # ffffffffc0200036 <kern_init>
ffffffffc020024e:	00005517          	auipc	a0,0x5
ffffffffc0200252:	ce250513          	addi	a0,a0,-798 # ffffffffc0204f30 <etext+0xa4>
ffffffffc0200256:	e7bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020025a:	00005597          	auipc	a1,0x5
ffffffffc020025e:	c3258593          	addi	a1,a1,-974 # ffffffffc0204e8c <etext>
ffffffffc0200262:	00005517          	auipc	a0,0x5
ffffffffc0200266:	cee50513          	addi	a0,a0,-786 # ffffffffc0204f50 <etext+0xc4>
ffffffffc020026a:	e67ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020026e:	0000a597          	auipc	a1,0xa
ffffffffc0200272:	df258593          	addi	a1,a1,-526 # ffffffffc020a060 <edata>
ffffffffc0200276:	00005517          	auipc	a0,0x5
ffffffffc020027a:	cfa50513          	addi	a0,a0,-774 # ffffffffc0204f70 <etext+0xe4>
ffffffffc020027e:	e53ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200282:	00015597          	auipc	a1,0x15
ffffffffc0200286:	37e58593          	addi	a1,a1,894 # ffffffffc0215600 <end>
ffffffffc020028a:	00005517          	auipc	a0,0x5
ffffffffc020028e:	d0650513          	addi	a0,a0,-762 # ffffffffc0204f90 <etext+0x104>
ffffffffc0200292:	e3fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200296:	00015597          	auipc	a1,0x15
ffffffffc020029a:	76958593          	addi	a1,a1,1897 # ffffffffc02159ff <end+0x3ff>
ffffffffc020029e:	00000797          	auipc	a5,0x0
ffffffffc02002a2:	d9878793          	addi	a5,a5,-616 # ffffffffc0200036 <kern_init>
ffffffffc02002a6:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002aa:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02002ae:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002b4:	95be                	add	a1,a1,a5
ffffffffc02002b6:	85a9                	srai	a1,a1,0xa
ffffffffc02002b8:	00005517          	auipc	a0,0x5
ffffffffc02002bc:	cf850513          	addi	a0,a0,-776 # ffffffffc0204fb0 <etext+0x124>
}
ffffffffc02002c0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002c2:	e0fff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02002c6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002c6:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002c8:	00005617          	auipc	a2,0x5
ffffffffc02002cc:	c1860613          	addi	a2,a2,-1000 # ffffffffc0204ee0 <etext+0x54>
ffffffffc02002d0:	04d00593          	li	a1,77
ffffffffc02002d4:	00005517          	auipc	a0,0x5
ffffffffc02002d8:	c2450513          	addi	a0,a0,-988 # ffffffffc0204ef8 <etext+0x6c>
void print_stackframe(void) {
ffffffffc02002dc:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002de:	ef9ff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02002e2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e4:	00005617          	auipc	a2,0x5
ffffffffc02002e8:	ddc60613          	addi	a2,a2,-548 # ffffffffc02050c0 <commands+0xe0>
ffffffffc02002ec:	00005597          	auipc	a1,0x5
ffffffffc02002f0:	df458593          	addi	a1,a1,-524 # ffffffffc02050e0 <commands+0x100>
ffffffffc02002f4:	00005517          	auipc	a0,0x5
ffffffffc02002f8:	df450513          	addi	a0,a0,-524 # ffffffffc02050e8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002fc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002fe:	dd3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200302:	00005617          	auipc	a2,0x5
ffffffffc0200306:	df660613          	addi	a2,a2,-522 # ffffffffc02050f8 <commands+0x118>
ffffffffc020030a:	00005597          	auipc	a1,0x5
ffffffffc020030e:	e1658593          	addi	a1,a1,-490 # ffffffffc0205120 <commands+0x140>
ffffffffc0200312:	00005517          	auipc	a0,0x5
ffffffffc0200316:	dd650513          	addi	a0,a0,-554 # ffffffffc02050e8 <commands+0x108>
ffffffffc020031a:	db7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020031e:	00005617          	auipc	a2,0x5
ffffffffc0200322:	e1260613          	addi	a2,a2,-494 # ffffffffc0205130 <commands+0x150>
ffffffffc0200326:	00005597          	auipc	a1,0x5
ffffffffc020032a:	e2a58593          	addi	a1,a1,-470 # ffffffffc0205150 <commands+0x170>
ffffffffc020032e:	00005517          	auipc	a0,0x5
ffffffffc0200332:	dba50513          	addi	a0,a0,-582 # ffffffffc02050e8 <commands+0x108>
ffffffffc0200336:	d9bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc020033a:	60a2                	ld	ra,8(sp)
ffffffffc020033c:	4501                	li	a0,0
ffffffffc020033e:	0141                	addi	sp,sp,16
ffffffffc0200340:	8082                	ret

ffffffffc0200342 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200342:	1141                	addi	sp,sp,-16
ffffffffc0200344:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200346:	ef1ff0ef          	jal	ra,ffffffffc0200236 <print_kerninfo>
    return 0;
}
ffffffffc020034a:	60a2                	ld	ra,8(sp)
ffffffffc020034c:	4501                	li	a0,0
ffffffffc020034e:	0141                	addi	sp,sp,16
ffffffffc0200350:	8082                	ret

ffffffffc0200352 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200352:	1141                	addi	sp,sp,-16
ffffffffc0200354:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200356:	f71ff0ef          	jal	ra,ffffffffc02002c6 <print_stackframe>
    return 0;
}
ffffffffc020035a:	60a2                	ld	ra,8(sp)
ffffffffc020035c:	4501                	li	a0,0
ffffffffc020035e:	0141                	addi	sp,sp,16
ffffffffc0200360:	8082                	ret

ffffffffc0200362 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200362:	7115                	addi	sp,sp,-224
ffffffffc0200364:	e962                	sd	s8,144(sp)
ffffffffc0200366:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200368:	00005517          	auipc	a0,0x5
ffffffffc020036c:	cc050513          	addi	a0,a0,-832 # ffffffffc0205028 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200370:	ed86                	sd	ra,216(sp)
ffffffffc0200372:	e9a2                	sd	s0,208(sp)
ffffffffc0200374:	e5a6                	sd	s1,200(sp)
ffffffffc0200376:	e1ca                	sd	s2,192(sp)
ffffffffc0200378:	fd4e                	sd	s3,184(sp)
ffffffffc020037a:	f952                	sd	s4,176(sp)
ffffffffc020037c:	f556                	sd	s5,168(sp)
ffffffffc020037e:	f15a                	sd	s6,160(sp)
ffffffffc0200380:	ed5e                	sd	s7,152(sp)
ffffffffc0200382:	e566                	sd	s9,136(sp)
ffffffffc0200384:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200386:	d4bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020038a:	00005517          	auipc	a0,0x5
ffffffffc020038e:	cc650513          	addi	a0,a0,-826 # ffffffffc0205050 <commands+0x70>
ffffffffc0200392:	d3fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200396:	000c0563          	beqz	s8,ffffffffc02003a0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020039a:	8562                	mv	a0,s8
ffffffffc020039c:	49e000ef          	jal	ra,ffffffffc020083a <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02003a0:	4501                	li	a0,0
ffffffffc02003a2:	4581                	li	a1,0
ffffffffc02003a4:	4601                	li	a2,0
ffffffffc02003a6:	48a1                	li	a7,8
ffffffffc02003a8:	00000073          	ecall
ffffffffc02003ac:	00005c97          	auipc	s9,0x5
ffffffffc02003b0:	c34c8c93          	addi	s9,s9,-972 # ffffffffc0204fe0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b4:	00005997          	auipc	s3,0x5
ffffffffc02003b8:	cc498993          	addi	s3,s3,-828 # ffffffffc0205078 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003bc:	00005917          	auipc	s2,0x5
ffffffffc02003c0:	cc490913          	addi	s2,s2,-828 # ffffffffc0205080 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02003c4:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003c6:	00005b17          	auipc	s6,0x5
ffffffffc02003ca:	cc2b0b13          	addi	s6,s6,-830 # ffffffffc0205088 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003ce:	00005a97          	auipc	s5,0x5
ffffffffc02003d2:	d12a8a93          	addi	s5,s5,-750 # ffffffffc02050e0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d6:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003d8:	854e                	mv	a0,s3
ffffffffc02003da:	d3fff0ef          	jal	ra,ffffffffc0200118 <readline>
ffffffffc02003de:	842a                	mv	s0,a0
ffffffffc02003e0:	dd65                	beqz	a0,ffffffffc02003d8 <kmonitor+0x76>
ffffffffc02003e2:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003e6:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e8:	c999                	beqz	a1,ffffffffc02003fe <kmonitor+0x9c>
ffffffffc02003ea:	854a                	mv	a0,s2
ffffffffc02003ec:	618040ef          	jal	ra,ffffffffc0204a04 <strchr>
ffffffffc02003f0:	c925                	beqz	a0,ffffffffc0200460 <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc02003f2:	00144583          	lbu	a1,1(s0)
ffffffffc02003f6:	00040023          	sb	zero,0(s0)
ffffffffc02003fa:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003fc:	f5fd                	bnez	a1,ffffffffc02003ea <kmonitor+0x88>
    if (argc == 0) {
ffffffffc02003fe:	dce9                	beqz	s1,ffffffffc02003d8 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200400:	6582                	ld	a1,0(sp)
ffffffffc0200402:	00005d17          	auipc	s10,0x5
ffffffffc0200406:	bded0d13          	addi	s10,s10,-1058 # ffffffffc0204fe0 <commands>
    if (argc == 0) {
ffffffffc020040a:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020040c:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020040e:	0d61                	addi	s10,s10,24
ffffffffc0200410:	5ca040ef          	jal	ra,ffffffffc02049da <strcmp>
ffffffffc0200414:	c919                	beqz	a0,ffffffffc020042a <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200416:	2405                	addiw	s0,s0,1
ffffffffc0200418:	09740463          	beq	s0,s7,ffffffffc02004a0 <kmonitor+0x13e>
ffffffffc020041c:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200420:	6582                	ld	a1,0(sp)
ffffffffc0200422:	0d61                	addi	s10,s10,24
ffffffffc0200424:	5b6040ef          	jal	ra,ffffffffc02049da <strcmp>
ffffffffc0200428:	f57d                	bnez	a0,ffffffffc0200416 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020042a:	00141793          	slli	a5,s0,0x1
ffffffffc020042e:	97a2                	add	a5,a5,s0
ffffffffc0200430:	078e                	slli	a5,a5,0x3
ffffffffc0200432:	97e6                	add	a5,a5,s9
ffffffffc0200434:	6b9c                	ld	a5,16(a5)
ffffffffc0200436:	8662                	mv	a2,s8
ffffffffc0200438:	002c                	addi	a1,sp,8
ffffffffc020043a:	fff4851b          	addiw	a0,s1,-1
ffffffffc020043e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200440:	f8055ce3          	bgez	a0,ffffffffc02003d8 <kmonitor+0x76>
}
ffffffffc0200444:	60ee                	ld	ra,216(sp)
ffffffffc0200446:	644e                	ld	s0,208(sp)
ffffffffc0200448:	64ae                	ld	s1,200(sp)
ffffffffc020044a:	690e                	ld	s2,192(sp)
ffffffffc020044c:	79ea                	ld	s3,184(sp)
ffffffffc020044e:	7a4a                	ld	s4,176(sp)
ffffffffc0200450:	7aaa                	ld	s5,168(sp)
ffffffffc0200452:	7b0a                	ld	s6,160(sp)
ffffffffc0200454:	6bea                	ld	s7,152(sp)
ffffffffc0200456:	6c4a                	ld	s8,144(sp)
ffffffffc0200458:	6caa                	ld	s9,136(sp)
ffffffffc020045a:	6d0a                	ld	s10,128(sp)
ffffffffc020045c:	612d                	addi	sp,sp,224
ffffffffc020045e:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200460:	00044783          	lbu	a5,0(s0)
ffffffffc0200464:	dfc9                	beqz	a5,ffffffffc02003fe <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200466:	03448863          	beq	s1,s4,ffffffffc0200496 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc020046a:	00349793          	slli	a5,s1,0x3
ffffffffc020046e:	0118                	addi	a4,sp,128
ffffffffc0200470:	97ba                	add	a5,a5,a4
ffffffffc0200472:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200476:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020047a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020047c:	e591                	bnez	a1,ffffffffc0200488 <kmonitor+0x126>
ffffffffc020047e:	b749                	j	ffffffffc0200400 <kmonitor+0x9e>
            buf ++;
ffffffffc0200480:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200482:	00044583          	lbu	a1,0(s0)
ffffffffc0200486:	ddad                	beqz	a1,ffffffffc0200400 <kmonitor+0x9e>
ffffffffc0200488:	854a                	mv	a0,s2
ffffffffc020048a:	57a040ef          	jal	ra,ffffffffc0204a04 <strchr>
ffffffffc020048e:	d96d                	beqz	a0,ffffffffc0200480 <kmonitor+0x11e>
ffffffffc0200490:	00044583          	lbu	a1,0(s0)
ffffffffc0200494:	bf91                	j	ffffffffc02003e8 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200496:	45c1                	li	a1,16
ffffffffc0200498:	855a                	mv	a0,s6
ffffffffc020049a:	c37ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020049e:	b7f1                	j	ffffffffc020046a <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02004a0:	6582                	ld	a1,0(sp)
ffffffffc02004a2:	00005517          	auipc	a0,0x5
ffffffffc02004a6:	c0650513          	addi	a0,a0,-1018 # ffffffffc02050a8 <commands+0xc8>
ffffffffc02004aa:	c27ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc02004ae:	b72d                	j	ffffffffc02003d8 <kmonitor+0x76>

ffffffffc02004b0 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02004b0:	8082                	ret

ffffffffc02004b2 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02004b2:	00253513          	sltiu	a0,a0,2
ffffffffc02004b6:	8082                	ret

ffffffffc02004b8 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004b8:	03800513          	li	a0,56
ffffffffc02004bc:	8082                	ret

ffffffffc02004be <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004be:	0000a797          	auipc	a5,0xa
ffffffffc02004c2:	fa278793          	addi	a5,a5,-94 # ffffffffc020a460 <ide>
ffffffffc02004c6:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004ca:	1141                	addi	sp,sp,-16
ffffffffc02004cc:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ce:	95be                	add	a1,a1,a5
ffffffffc02004d0:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004d4:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004d6:	55e040ef          	jal	ra,ffffffffc0204a34 <memcpy>
    return 0;
}
ffffffffc02004da:	60a2                	ld	ra,8(sp)
ffffffffc02004dc:	4501                	li	a0,0
ffffffffc02004de:	0141                	addi	sp,sp,16
ffffffffc02004e0:	8082                	ret

ffffffffc02004e2 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004e2:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e4:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004e8:	0000a517          	auipc	a0,0xa
ffffffffc02004ec:	f7850513          	addi	a0,a0,-136 # ffffffffc020a460 <ide>
                   size_t nsecs) {
ffffffffc02004f0:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004f2:	00969613          	slli	a2,a3,0x9
ffffffffc02004f6:	85ba                	mv	a1,a4
ffffffffc02004f8:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004fa:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004fc:	538040ef          	jal	ra,ffffffffc0204a34 <memcpy>
    return 0;
}
ffffffffc0200500:	60a2                	ld	ra,8(sp)
ffffffffc0200502:	4501                	li	a0,0
ffffffffc0200504:	0141                	addi	sp,sp,16
ffffffffc0200506:	8082                	ret

ffffffffc0200508 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200508:	67e1                	lui	a5,0x18
ffffffffc020050a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020050e:	00015717          	auipc	a4,0x15
ffffffffc0200512:	f6f73523          	sd	a5,-150(a4) # ffffffffc0215478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200516:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020051a:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020051c:	953e                	add	a0,a0,a5
ffffffffc020051e:	4601                	li	a2,0
ffffffffc0200520:	4881                	li	a7,0
ffffffffc0200522:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200526:	02000793          	li	a5,32
ffffffffc020052a:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020052e:	00005517          	auipc	a0,0x5
ffffffffc0200532:	c3250513          	addi	a0,a0,-974 # ffffffffc0205160 <commands+0x180>
    ticks = 0;
ffffffffc0200536:	00015797          	auipc	a5,0x15
ffffffffc020053a:	f807bd23          	sd	zero,-102(a5) # ffffffffc02154d0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020053e:	b93ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200542 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200542:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200546:	00015797          	auipc	a5,0x15
ffffffffc020054a:	f3278793          	addi	a5,a5,-206 # ffffffffc0215478 <timebase>
ffffffffc020054e:	639c                	ld	a5,0(a5)
ffffffffc0200550:	4581                	li	a1,0
ffffffffc0200552:	4601                	li	a2,0
ffffffffc0200554:	953e                	add	a0,a0,a5
ffffffffc0200556:	4881                	li	a7,0
ffffffffc0200558:	00000073          	ecall
ffffffffc020055c:	8082                	ret

ffffffffc020055e <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020055e:	8082                	ret

ffffffffc0200560 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200560:	100027f3          	csrr	a5,sstatus
ffffffffc0200564:	8b89                	andi	a5,a5,2
ffffffffc0200566:	0ff57513          	andi	a0,a0,255
ffffffffc020056a:	e799                	bnez	a5,ffffffffc0200578 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020056c:	4581                	li	a1,0
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4885                	li	a7,1
ffffffffc0200572:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200576:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200578:	1101                	addi	sp,sp,-32
ffffffffc020057a:	ec06                	sd	ra,24(sp)
ffffffffc020057c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020057e:	05c000ef          	jal	ra,ffffffffc02005da <intr_disable>
ffffffffc0200582:	6522                	ld	a0,8(sp)
ffffffffc0200584:	4581                	li	a1,0
ffffffffc0200586:	4601                	li	a2,0
ffffffffc0200588:	4885                	li	a7,1
ffffffffc020058a:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020058e:	60e2                	ld	ra,24(sp)
ffffffffc0200590:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200592:	0420006f          	j	ffffffffc02005d4 <intr_enable>

ffffffffc0200596 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200596:	100027f3          	csrr	a5,sstatus
ffffffffc020059a:	8b89                	andi	a5,a5,2
ffffffffc020059c:	eb89                	bnez	a5,ffffffffc02005ae <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020059e:	4501                	li	a0,0
ffffffffc02005a0:	4581                	li	a1,0
ffffffffc02005a2:	4601                	li	a2,0
ffffffffc02005a4:	4889                	li	a7,2
ffffffffc02005a6:	00000073          	ecall
ffffffffc02005aa:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005ac:	8082                	ret
int cons_getc(void) {
ffffffffc02005ae:	1101                	addi	sp,sp,-32
ffffffffc02005b0:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005b2:	028000ef          	jal	ra,ffffffffc02005da <intr_disable>
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	4581                	li	a1,0
ffffffffc02005ba:	4601                	li	a2,0
ffffffffc02005bc:	4889                	li	a7,2
ffffffffc02005be:	00000073          	ecall
ffffffffc02005c2:	2501                	sext.w	a0,a0
ffffffffc02005c4:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005c6:	00e000ef          	jal	ra,ffffffffc02005d4 <intr_enable>
}
ffffffffc02005ca:	60e2                	ld	ra,24(sp)
ffffffffc02005cc:	6522                	ld	a0,8(sp)
ffffffffc02005ce:	6105                	addi	sp,sp,32
ffffffffc02005d0:	8082                	ret

ffffffffc02005d2 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005d2:	8082                	ret

ffffffffc02005d4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005d8:	8082                	ret

ffffffffc02005da <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005da:	100177f3          	csrrci	a5,sstatus,2
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
ffffffffc0200614:	e4850513          	addi	a0,a0,-440 # ffffffffc0205458 <commands+0x478>
ffffffffc0200618:	ab9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020061c:	00015797          	auipc	a5,0x15
ffffffffc0200620:	ebc78793          	addi	a5,a5,-324 # ffffffffc02154d8 <check_mm_struct>
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
ffffffffc0200636:	4870006f          	j	ffffffffc02012bc <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020063a:	00005617          	auipc	a2,0x5
ffffffffc020063e:	e3e60613          	addi	a2,a2,-450 # ffffffffc0205478 <commands+0x498>
ffffffffc0200642:	06200593          	li	a1,98
ffffffffc0200646:	00005517          	auipc	a0,0x5
ffffffffc020064a:	e4a50513          	addi	a0,a0,-438 # ffffffffc0205490 <commands+0x4b0>
ffffffffc020064e:	b89ff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0200652 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200652:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200656:	00000797          	auipc	a5,0x0
ffffffffc020065a:	48e78793          	addi	a5,a5,1166 # ffffffffc0200ae4 <__alltraps>
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
ffffffffc0200678:	e3450513          	addi	a0,a0,-460 # ffffffffc02054a8 <commands+0x4c8>
void print_regs(struct pushregs *gpr) {
ffffffffc020067c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067e:	a53ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200682:	640c                	ld	a1,8(s0)
ffffffffc0200684:	00005517          	auipc	a0,0x5
ffffffffc0200688:	e3c50513          	addi	a0,a0,-452 # ffffffffc02054c0 <commands+0x4e0>
ffffffffc020068c:	a45ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200690:	680c                	ld	a1,16(s0)
ffffffffc0200692:	00005517          	auipc	a0,0x5
ffffffffc0200696:	e4650513          	addi	a0,a0,-442 # ffffffffc02054d8 <commands+0x4f8>
ffffffffc020069a:	a37ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069e:	6c0c                	ld	a1,24(s0)
ffffffffc02006a0:	00005517          	auipc	a0,0x5
ffffffffc02006a4:	e5050513          	addi	a0,a0,-432 # ffffffffc02054f0 <commands+0x510>
ffffffffc02006a8:	a29ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006ac:	700c                	ld	a1,32(s0)
ffffffffc02006ae:	00005517          	auipc	a0,0x5
ffffffffc02006b2:	e5a50513          	addi	a0,a0,-422 # ffffffffc0205508 <commands+0x528>
ffffffffc02006b6:	a1bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ba:	740c                	ld	a1,40(s0)
ffffffffc02006bc:	00005517          	auipc	a0,0x5
ffffffffc02006c0:	e6450513          	addi	a0,a0,-412 # ffffffffc0205520 <commands+0x540>
ffffffffc02006c4:	a0dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c8:	780c                	ld	a1,48(s0)
ffffffffc02006ca:	00005517          	auipc	a0,0x5
ffffffffc02006ce:	e6e50513          	addi	a0,a0,-402 # ffffffffc0205538 <commands+0x558>
ffffffffc02006d2:	9ffff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d6:	7c0c                	ld	a1,56(s0)
ffffffffc02006d8:	00005517          	auipc	a0,0x5
ffffffffc02006dc:	e7850513          	addi	a0,a0,-392 # ffffffffc0205550 <commands+0x570>
ffffffffc02006e0:	9f1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e4:	602c                	ld	a1,64(s0)
ffffffffc02006e6:	00005517          	auipc	a0,0x5
ffffffffc02006ea:	e8250513          	addi	a0,a0,-382 # ffffffffc0205568 <commands+0x588>
ffffffffc02006ee:	9e3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006f2:	642c                	ld	a1,72(s0)
ffffffffc02006f4:	00005517          	auipc	a0,0x5
ffffffffc02006f8:	e8c50513          	addi	a0,a0,-372 # ffffffffc0205580 <commands+0x5a0>
ffffffffc02006fc:	9d5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200700:	682c                	ld	a1,80(s0)
ffffffffc0200702:	00005517          	auipc	a0,0x5
ffffffffc0200706:	e9650513          	addi	a0,a0,-362 # ffffffffc0205598 <commands+0x5b8>
ffffffffc020070a:	9c7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070e:	6c2c                	ld	a1,88(s0)
ffffffffc0200710:	00005517          	auipc	a0,0x5
ffffffffc0200714:	ea050513          	addi	a0,a0,-352 # ffffffffc02055b0 <commands+0x5d0>
ffffffffc0200718:	9b9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020071c:	702c                	ld	a1,96(s0)
ffffffffc020071e:	00005517          	auipc	a0,0x5
ffffffffc0200722:	eaa50513          	addi	a0,a0,-342 # ffffffffc02055c8 <commands+0x5e8>
ffffffffc0200726:	9abff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020072a:	742c                	ld	a1,104(s0)
ffffffffc020072c:	00005517          	auipc	a0,0x5
ffffffffc0200730:	eb450513          	addi	a0,a0,-332 # ffffffffc02055e0 <commands+0x600>
ffffffffc0200734:	99dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200738:	782c                	ld	a1,112(s0)
ffffffffc020073a:	00005517          	auipc	a0,0x5
ffffffffc020073e:	ebe50513          	addi	a0,a0,-322 # ffffffffc02055f8 <commands+0x618>
ffffffffc0200742:	98fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200746:	7c2c                	ld	a1,120(s0)
ffffffffc0200748:	00005517          	auipc	a0,0x5
ffffffffc020074c:	ec850513          	addi	a0,a0,-312 # ffffffffc0205610 <commands+0x630>
ffffffffc0200750:	981ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200754:	604c                	ld	a1,128(s0)
ffffffffc0200756:	00005517          	auipc	a0,0x5
ffffffffc020075a:	ed250513          	addi	a0,a0,-302 # ffffffffc0205628 <commands+0x648>
ffffffffc020075e:	973ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200762:	644c                	ld	a1,136(s0)
ffffffffc0200764:	00005517          	auipc	a0,0x5
ffffffffc0200768:	edc50513          	addi	a0,a0,-292 # ffffffffc0205640 <commands+0x660>
ffffffffc020076c:	965ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200770:	684c                	ld	a1,144(s0)
ffffffffc0200772:	00005517          	auipc	a0,0x5
ffffffffc0200776:	ee650513          	addi	a0,a0,-282 # ffffffffc0205658 <commands+0x678>
ffffffffc020077a:	957ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077e:	6c4c                	ld	a1,152(s0)
ffffffffc0200780:	00005517          	auipc	a0,0x5
ffffffffc0200784:	ef050513          	addi	a0,a0,-272 # ffffffffc0205670 <commands+0x690>
ffffffffc0200788:	949ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020078c:	704c                	ld	a1,160(s0)
ffffffffc020078e:	00005517          	auipc	a0,0x5
ffffffffc0200792:	efa50513          	addi	a0,a0,-262 # ffffffffc0205688 <commands+0x6a8>
ffffffffc0200796:	93bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020079a:	744c                	ld	a1,168(s0)
ffffffffc020079c:	00005517          	auipc	a0,0x5
ffffffffc02007a0:	f0450513          	addi	a0,a0,-252 # ffffffffc02056a0 <commands+0x6c0>
ffffffffc02007a4:	92dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a8:	784c                	ld	a1,176(s0)
ffffffffc02007aa:	00005517          	auipc	a0,0x5
ffffffffc02007ae:	f0e50513          	addi	a0,a0,-242 # ffffffffc02056b8 <commands+0x6d8>
ffffffffc02007b2:	91fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b6:	7c4c                	ld	a1,184(s0)
ffffffffc02007b8:	00005517          	auipc	a0,0x5
ffffffffc02007bc:	f1850513          	addi	a0,a0,-232 # ffffffffc02056d0 <commands+0x6f0>
ffffffffc02007c0:	911ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c4:	606c                	ld	a1,192(s0)
ffffffffc02007c6:	00005517          	auipc	a0,0x5
ffffffffc02007ca:	f2250513          	addi	a0,a0,-222 # ffffffffc02056e8 <commands+0x708>
ffffffffc02007ce:	903ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007d2:	646c                	ld	a1,200(s0)
ffffffffc02007d4:	00005517          	auipc	a0,0x5
ffffffffc02007d8:	f2c50513          	addi	a0,a0,-212 # ffffffffc0205700 <commands+0x720>
ffffffffc02007dc:	8f5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e0:	686c                	ld	a1,208(s0)
ffffffffc02007e2:	00005517          	auipc	a0,0x5
ffffffffc02007e6:	f3650513          	addi	a0,a0,-202 # ffffffffc0205718 <commands+0x738>
ffffffffc02007ea:	8e7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ee:	6c6c                	ld	a1,216(s0)
ffffffffc02007f0:	00005517          	auipc	a0,0x5
ffffffffc02007f4:	f4050513          	addi	a0,a0,-192 # ffffffffc0205730 <commands+0x750>
ffffffffc02007f8:	8d9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007fc:	706c                	ld	a1,224(s0)
ffffffffc02007fe:	00005517          	auipc	a0,0x5
ffffffffc0200802:	f4a50513          	addi	a0,a0,-182 # ffffffffc0205748 <commands+0x768>
ffffffffc0200806:	8cbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020080a:	746c                	ld	a1,232(s0)
ffffffffc020080c:	00005517          	auipc	a0,0x5
ffffffffc0200810:	f5450513          	addi	a0,a0,-172 # ffffffffc0205760 <commands+0x780>
ffffffffc0200814:	8bdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200818:	786c                	ld	a1,240(s0)
ffffffffc020081a:	00005517          	auipc	a0,0x5
ffffffffc020081e:	f5e50513          	addi	a0,a0,-162 # ffffffffc0205778 <commands+0x798>
ffffffffc0200822:	8afff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200826:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200828:	6402                	ld	s0,0(sp)
ffffffffc020082a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082c:	00005517          	auipc	a0,0x5
ffffffffc0200830:	f6450513          	addi	a0,a0,-156 # ffffffffc0205790 <commands+0x7b0>
}
ffffffffc0200834:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	89bff06f          	j	ffffffffc02000d0 <cprintf>

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
ffffffffc0200846:	f6650513          	addi	a0,a0,-154 # ffffffffc02057a8 <commands+0x7c8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084c:	885ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200850:	8522                	mv	a0,s0
ffffffffc0200852:	e1bff0ef          	jal	ra,ffffffffc020066c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200856:	10043583          	ld	a1,256(s0)
ffffffffc020085a:	00005517          	auipc	a0,0x5
ffffffffc020085e:	f6650513          	addi	a0,a0,-154 # ffffffffc02057c0 <commands+0x7e0>
ffffffffc0200862:	86fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200866:	10843583          	ld	a1,264(s0)
ffffffffc020086a:	00005517          	auipc	a0,0x5
ffffffffc020086e:	f6e50513          	addi	a0,a0,-146 # ffffffffc02057d8 <commands+0x7f8>
ffffffffc0200872:	85fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200876:	11043583          	ld	a1,272(s0)
ffffffffc020087a:	00005517          	auipc	a0,0x5
ffffffffc020087e:	f7650513          	addi	a0,a0,-138 # ffffffffc02057f0 <commands+0x810>
ffffffffc0200882:	84fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200886:	11843583          	ld	a1,280(s0)
}
ffffffffc020088a:	6402                	ld	s0,0(sp)
ffffffffc020088c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	00005517          	auipc	a0,0x5
ffffffffc0200892:	f7a50513          	addi	a0,a0,-134 # ffffffffc0205808 <commands+0x828>
}
ffffffffc0200896:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200898:	839ff06f          	j	ffffffffc02000d0 <cprintf>

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
ffffffffc02008a8:	06f76f63          	bltu	a4,a5,ffffffffc0200926 <interrupt_handler+0x8a>
ffffffffc02008ac:	00005717          	auipc	a4,0x5
ffffffffc02008b0:	8d070713          	addi	a4,a4,-1840 # ffffffffc020517c <commands+0x19c>
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
ffffffffc02008c2:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0205408 <commands+0x428>
ffffffffc02008c6:	80bff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008ca:	00005517          	auipc	a0,0x5
ffffffffc02008ce:	b1e50513          	addi	a0,a0,-1250 # ffffffffc02053e8 <commands+0x408>
ffffffffc02008d2:	ffeff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008d6:	00005517          	auipc	a0,0x5
ffffffffc02008da:	ad250513          	addi	a0,a0,-1326 # ffffffffc02053a8 <commands+0x3c8>
ffffffffc02008de:	ff2ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008e2:	00005517          	auipc	a0,0x5
ffffffffc02008e6:	ae650513          	addi	a0,a0,-1306 # ffffffffc02053c8 <commands+0x3e8>
ffffffffc02008ea:	fe6ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008ee:	00005517          	auipc	a0,0x5
ffffffffc02008f2:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0205438 <commands+0x458>
ffffffffc02008f6:	fdaff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008fa:	1141                	addi	sp,sp,-16
ffffffffc02008fc:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008fe:	c45ff0ef          	jal	ra,ffffffffc0200542 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200902:	00015797          	auipc	a5,0x15
ffffffffc0200906:	bce78793          	addi	a5,a5,-1074 # ffffffffc02154d0 <ticks>
ffffffffc020090a:	639c                	ld	a5,0(a5)
ffffffffc020090c:	06400713          	li	a4,100
ffffffffc0200910:	0785                	addi	a5,a5,1
ffffffffc0200912:	02e7f733          	remu	a4,a5,a4
ffffffffc0200916:	00015697          	auipc	a3,0x15
ffffffffc020091a:	baf6bd23          	sd	a5,-1094(a3) # ffffffffc02154d0 <ticks>
ffffffffc020091e:	c711                	beqz	a4,ffffffffc020092a <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200920:	60a2                	ld	ra,8(sp)
ffffffffc0200922:	0141                	addi	sp,sp,16
ffffffffc0200924:	8082                	ret
            print_trapframe(tf);
ffffffffc0200926:	f15ff06f          	j	ffffffffc020083a <print_trapframe>
}
ffffffffc020092a:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020092c:	06400593          	li	a1,100
ffffffffc0200930:	00005517          	auipc	a0,0x5
ffffffffc0200934:	af850513          	addi	a0,a0,-1288 # ffffffffc0205428 <commands+0x448>
}
ffffffffc0200938:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020093a:	f96ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020093e <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020093e:	11853783          	ld	a5,280(a0)
ffffffffc0200942:	473d                	li	a4,15
ffffffffc0200944:	16f76563          	bltu	a4,a5,ffffffffc0200aae <exception_handler+0x170>
ffffffffc0200948:	00005717          	auipc	a4,0x5
ffffffffc020094c:	86470713          	addi	a4,a4,-1948 # ffffffffc02051ac <commands+0x1cc>
ffffffffc0200950:	078a                	slli	a5,a5,0x2
ffffffffc0200952:	97ba                	add	a5,a5,a4
ffffffffc0200954:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200956:	1101                	addi	sp,sp,-32
ffffffffc0200958:	e822                	sd	s0,16(sp)
ffffffffc020095a:	ec06                	sd	ra,24(sp)
ffffffffc020095c:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc020095e:	97ba                	add	a5,a5,a4
ffffffffc0200960:	842a                	mv	s0,a0
ffffffffc0200962:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200964:	00005517          	auipc	a0,0x5
ffffffffc0200968:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0205390 <commands+0x3b0>
ffffffffc020096c:	f64ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200970:	8522                	mv	a0,s0
ffffffffc0200972:	c6fff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200976:	84aa                	mv	s1,a0
ffffffffc0200978:	12051d63          	bnez	a0,ffffffffc0200ab2 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020097c:	60e2                	ld	ra,24(sp)
ffffffffc020097e:	6442                	ld	s0,16(sp)
ffffffffc0200980:	64a2                	ld	s1,8(sp)
ffffffffc0200982:	6105                	addi	sp,sp,32
ffffffffc0200984:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200986:	00005517          	auipc	a0,0x5
ffffffffc020098a:	86a50513          	addi	a0,a0,-1942 # ffffffffc02051f0 <commands+0x210>
}
ffffffffc020098e:	6442                	ld	s0,16(sp)
ffffffffc0200990:	60e2                	ld	ra,24(sp)
ffffffffc0200992:	64a2                	ld	s1,8(sp)
ffffffffc0200994:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200996:	f3aff06f          	j	ffffffffc02000d0 <cprintf>
ffffffffc020099a:	00005517          	auipc	a0,0x5
ffffffffc020099e:	87650513          	addi	a0,a0,-1930 # ffffffffc0205210 <commands+0x230>
ffffffffc02009a2:	b7f5                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02009a4:	00005517          	auipc	a0,0x5
ffffffffc02009a8:	88c50513          	addi	a0,a0,-1908 # ffffffffc0205230 <commands+0x250>
ffffffffc02009ac:	b7cd                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02009ae:	00005517          	auipc	a0,0x5
ffffffffc02009b2:	89a50513          	addi	a0,a0,-1894 # ffffffffc0205248 <commands+0x268>
ffffffffc02009b6:	bfe1                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02009b8:	00005517          	auipc	a0,0x5
ffffffffc02009bc:	8a050513          	addi	a0,a0,-1888 # ffffffffc0205258 <commands+0x278>
ffffffffc02009c0:	b7f9                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02009c2:	00005517          	auipc	a0,0x5
ffffffffc02009c6:	8b650513          	addi	a0,a0,-1866 # ffffffffc0205278 <commands+0x298>
ffffffffc02009ca:	f06ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ce:	8522                	mv	a0,s0
ffffffffc02009d0:	c11ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc02009d4:	84aa                	mv	s1,a0
ffffffffc02009d6:	d15d                	beqz	a0,ffffffffc020097c <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009d8:	8522                	mv	a0,s0
ffffffffc02009da:	e61ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009de:	86a6                	mv	a3,s1
ffffffffc02009e0:	00005617          	auipc	a2,0x5
ffffffffc02009e4:	8b060613          	addi	a2,a2,-1872 # ffffffffc0205290 <commands+0x2b0>
ffffffffc02009e8:	0b300593          	li	a1,179
ffffffffc02009ec:	00005517          	auipc	a0,0x5
ffffffffc02009f0:	aa450513          	addi	a0,a0,-1372 # ffffffffc0205490 <commands+0x4b0>
ffffffffc02009f4:	fe2ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009f8:	00005517          	auipc	a0,0x5
ffffffffc02009fc:	8b850513          	addi	a0,a0,-1864 # ffffffffc02052b0 <commands+0x2d0>
ffffffffc0200a00:	b779                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200a02:	00005517          	auipc	a0,0x5
ffffffffc0200a06:	8c650513          	addi	a0,a0,-1850 # ffffffffc02052c8 <commands+0x2e8>
ffffffffc0200a0a:	ec6ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a0e:	8522                	mv	a0,s0
ffffffffc0200a10:	bd1ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200a14:	84aa                	mv	s1,a0
ffffffffc0200a16:	d13d                	beqz	a0,ffffffffc020097c <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a18:	8522                	mv	a0,s0
ffffffffc0200a1a:	e21ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a1e:	86a6                	mv	a3,s1
ffffffffc0200a20:	00005617          	auipc	a2,0x5
ffffffffc0200a24:	87060613          	addi	a2,a2,-1936 # ffffffffc0205290 <commands+0x2b0>
ffffffffc0200a28:	0bd00593          	li	a1,189
ffffffffc0200a2c:	00005517          	auipc	a0,0x5
ffffffffc0200a30:	a6450513          	addi	a0,a0,-1436 # ffffffffc0205490 <commands+0x4b0>
ffffffffc0200a34:	fa2ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a38:	00005517          	auipc	a0,0x5
ffffffffc0200a3c:	8a850513          	addi	a0,a0,-1880 # ffffffffc02052e0 <commands+0x300>
ffffffffc0200a40:	b7b9                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a42:	00005517          	auipc	a0,0x5
ffffffffc0200a46:	8be50513          	addi	a0,a0,-1858 # ffffffffc0205300 <commands+0x320>
ffffffffc0200a4a:	b791                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a4c:	00005517          	auipc	a0,0x5
ffffffffc0200a50:	8d450513          	addi	a0,a0,-1836 # ffffffffc0205320 <commands+0x340>
ffffffffc0200a54:	bf2d                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a56:	00005517          	auipc	a0,0x5
ffffffffc0200a5a:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0205340 <commands+0x360>
ffffffffc0200a5e:	bf05                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a60:	00005517          	auipc	a0,0x5
ffffffffc0200a64:	90050513          	addi	a0,a0,-1792 # ffffffffc0205360 <commands+0x380>
ffffffffc0200a68:	b71d                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a6a:	00005517          	auipc	a0,0x5
ffffffffc0200a6e:	90e50513          	addi	a0,a0,-1778 # ffffffffc0205378 <commands+0x398>
ffffffffc0200a72:	e5eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a76:	8522                	mv	a0,s0
ffffffffc0200a78:	b69ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200a7c:	84aa                	mv	s1,a0
ffffffffc0200a7e:	ee050fe3          	beqz	a0,ffffffffc020097c <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a82:	8522                	mv	a0,s0
ffffffffc0200a84:	db7ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a88:	86a6                	mv	a3,s1
ffffffffc0200a8a:	00005617          	auipc	a2,0x5
ffffffffc0200a8e:	80660613          	addi	a2,a2,-2042 # ffffffffc0205290 <commands+0x2b0>
ffffffffc0200a92:	0d300593          	li	a1,211
ffffffffc0200a96:	00005517          	auipc	a0,0x5
ffffffffc0200a9a:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0205490 <commands+0x4b0>
ffffffffc0200a9e:	f38ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
}
ffffffffc0200aa2:	6442                	ld	s0,16(sp)
ffffffffc0200aa4:	60e2                	ld	ra,24(sp)
ffffffffc0200aa6:	64a2                	ld	s1,8(sp)
ffffffffc0200aa8:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200aaa:	d91ff06f          	j	ffffffffc020083a <print_trapframe>
ffffffffc0200aae:	d8dff06f          	j	ffffffffc020083a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200ab2:	8522                	mv	a0,s0
ffffffffc0200ab4:	d87ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ab8:	86a6                	mv	a3,s1
ffffffffc0200aba:	00004617          	auipc	a2,0x4
ffffffffc0200abe:	7d660613          	addi	a2,a2,2006 # ffffffffc0205290 <commands+0x2b0>
ffffffffc0200ac2:	0da00593          	li	a1,218
ffffffffc0200ac6:	00005517          	auipc	a0,0x5
ffffffffc0200aca:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0205490 <commands+0x4b0>
ffffffffc0200ace:	f08ff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0200ad2 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ad2:	11853783          	ld	a5,280(a0)
ffffffffc0200ad6:	0007c463          	bltz	a5,ffffffffc0200ade <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ada:	e65ff06f          	j	ffffffffc020093e <exception_handler>
        interrupt_handler(tf);
ffffffffc0200ade:	dbfff06f          	j	ffffffffc020089c <interrupt_handler>
	...

ffffffffc0200ae4 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ae4:	14011073          	csrw	sscratch,sp
ffffffffc0200ae8:	712d                	addi	sp,sp,-288
ffffffffc0200aea:	e406                	sd	ra,8(sp)
ffffffffc0200aec:	ec0e                	sd	gp,24(sp)
ffffffffc0200aee:	f012                	sd	tp,32(sp)
ffffffffc0200af0:	f416                	sd	t0,40(sp)
ffffffffc0200af2:	f81a                	sd	t1,48(sp)
ffffffffc0200af4:	fc1e                	sd	t2,56(sp)
ffffffffc0200af6:	e0a2                	sd	s0,64(sp)
ffffffffc0200af8:	e4a6                	sd	s1,72(sp)
ffffffffc0200afa:	e8aa                	sd	a0,80(sp)
ffffffffc0200afc:	ecae                	sd	a1,88(sp)
ffffffffc0200afe:	f0b2                	sd	a2,96(sp)
ffffffffc0200b00:	f4b6                	sd	a3,104(sp)
ffffffffc0200b02:	f8ba                	sd	a4,112(sp)
ffffffffc0200b04:	fcbe                	sd	a5,120(sp)
ffffffffc0200b06:	e142                	sd	a6,128(sp)
ffffffffc0200b08:	e546                	sd	a7,136(sp)
ffffffffc0200b0a:	e94a                	sd	s2,144(sp)
ffffffffc0200b0c:	ed4e                	sd	s3,152(sp)
ffffffffc0200b0e:	f152                	sd	s4,160(sp)
ffffffffc0200b10:	f556                	sd	s5,168(sp)
ffffffffc0200b12:	f95a                	sd	s6,176(sp)
ffffffffc0200b14:	fd5e                	sd	s7,184(sp)
ffffffffc0200b16:	e1e2                	sd	s8,192(sp)
ffffffffc0200b18:	e5e6                	sd	s9,200(sp)
ffffffffc0200b1a:	e9ea                	sd	s10,208(sp)
ffffffffc0200b1c:	edee                	sd	s11,216(sp)
ffffffffc0200b1e:	f1f2                	sd	t3,224(sp)
ffffffffc0200b20:	f5f6                	sd	t4,232(sp)
ffffffffc0200b22:	f9fa                	sd	t5,240(sp)
ffffffffc0200b24:	fdfe                	sd	t6,248(sp)
ffffffffc0200b26:	14002473          	csrr	s0,sscratch
ffffffffc0200b2a:	100024f3          	csrr	s1,sstatus
ffffffffc0200b2e:	14102973          	csrr	s2,sepc
ffffffffc0200b32:	143029f3          	csrr	s3,stval
ffffffffc0200b36:	14202a73          	csrr	s4,scause
ffffffffc0200b3a:	e822                	sd	s0,16(sp)
ffffffffc0200b3c:	e226                	sd	s1,256(sp)
ffffffffc0200b3e:	e64a                	sd	s2,264(sp)
ffffffffc0200b40:	ea4e                	sd	s3,272(sp)
ffffffffc0200b42:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b44:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b46:	f8dff0ef          	jal	ra,ffffffffc0200ad2 <trap>

ffffffffc0200b4a <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b4a:	6492                	ld	s1,256(sp)
ffffffffc0200b4c:	6932                	ld	s2,264(sp)
ffffffffc0200b4e:	10049073          	csrw	sstatus,s1
ffffffffc0200b52:	14191073          	csrw	sepc,s2
ffffffffc0200b56:	60a2                	ld	ra,8(sp)
ffffffffc0200b58:	61e2                	ld	gp,24(sp)
ffffffffc0200b5a:	7202                	ld	tp,32(sp)
ffffffffc0200b5c:	72a2                	ld	t0,40(sp)
ffffffffc0200b5e:	7342                	ld	t1,48(sp)
ffffffffc0200b60:	73e2                	ld	t2,56(sp)
ffffffffc0200b62:	6406                	ld	s0,64(sp)
ffffffffc0200b64:	64a6                	ld	s1,72(sp)
ffffffffc0200b66:	6546                	ld	a0,80(sp)
ffffffffc0200b68:	65e6                	ld	a1,88(sp)
ffffffffc0200b6a:	7606                	ld	a2,96(sp)
ffffffffc0200b6c:	76a6                	ld	a3,104(sp)
ffffffffc0200b6e:	7746                	ld	a4,112(sp)
ffffffffc0200b70:	77e6                	ld	a5,120(sp)
ffffffffc0200b72:	680a                	ld	a6,128(sp)
ffffffffc0200b74:	68aa                	ld	a7,136(sp)
ffffffffc0200b76:	694a                	ld	s2,144(sp)
ffffffffc0200b78:	69ea                	ld	s3,152(sp)
ffffffffc0200b7a:	7a0a                	ld	s4,160(sp)
ffffffffc0200b7c:	7aaa                	ld	s5,168(sp)
ffffffffc0200b7e:	7b4a                	ld	s6,176(sp)
ffffffffc0200b80:	7bea                	ld	s7,184(sp)
ffffffffc0200b82:	6c0e                	ld	s8,192(sp)
ffffffffc0200b84:	6cae                	ld	s9,200(sp)
ffffffffc0200b86:	6d4e                	ld	s10,208(sp)
ffffffffc0200b88:	6dee                	ld	s11,216(sp)
ffffffffc0200b8a:	7e0e                	ld	t3,224(sp)
ffffffffc0200b8c:	7eae                	ld	t4,232(sp)
ffffffffc0200b8e:	7f4e                	ld	t5,240(sp)
ffffffffc0200b90:	7fee                	ld	t6,248(sp)
ffffffffc0200b92:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b94:	10200073          	sret

ffffffffc0200b98 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b98:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b9a:	bf45                	j	ffffffffc0200b4a <__trapret>
	...

ffffffffc0200b9e <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200b9e:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200ba0:	00005697          	auipc	a3,0x5
ffffffffc0200ba4:	c8068693          	addi	a3,a3,-896 # ffffffffc0205820 <commands+0x840>
ffffffffc0200ba8:	00005617          	auipc	a2,0x5
ffffffffc0200bac:	c9860613          	addi	a2,a2,-872 # ffffffffc0205840 <commands+0x860>
ffffffffc0200bb0:	07e00593          	li	a1,126
ffffffffc0200bb4:	00005517          	auipc	a0,0x5
ffffffffc0200bb8:	ca450513          	addi	a0,a0,-860 # ffffffffc0205858 <commands+0x878>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200bbc:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200bbe:	e18ff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0200bc2 <mm_create>:
mm_create(void) {
ffffffffc0200bc2:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200bc4:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200bc8:	e022                	sd	s0,0(sp)
ffffffffc0200bca:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200bcc:	67d000ef          	jal	ra,ffffffffc0201a48 <kmalloc>
ffffffffc0200bd0:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200bd2:	c115                	beqz	a0,ffffffffc0200bf6 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200bd4:	00015797          	auipc	a5,0x15
ffffffffc0200bd8:	8c478793          	addi	a5,a5,-1852 # ffffffffc0215498 <swap_init_ok>
ffffffffc0200bdc:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200bde:	e408                	sd	a0,8(s0)
ffffffffc0200be0:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200be2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200be6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200bea:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200bee:	2781                	sext.w	a5,a5
ffffffffc0200bf0:	eb81                	bnez	a5,ffffffffc0200c00 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0200bf2:	02053423          	sd	zero,40(a0)
}
ffffffffc0200bf6:	8522                	mv	a0,s0
ffffffffc0200bf8:	60a2                	ld	ra,8(sp)
ffffffffc0200bfa:	6402                	ld	s0,0(sp)
ffffffffc0200bfc:	0141                	addi	sp,sp,16
ffffffffc0200bfe:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200c00:	79c010ef          	jal	ra,ffffffffc020239c <swap_init_mm>
}
ffffffffc0200c04:	8522                	mv	a0,s0
ffffffffc0200c06:	60a2                	ld	ra,8(sp)
ffffffffc0200c08:	6402                	ld	s0,0(sp)
ffffffffc0200c0a:	0141                	addi	sp,sp,16
ffffffffc0200c0c:	8082                	ret

ffffffffc0200c0e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200c0e:	1101                	addi	sp,sp,-32
ffffffffc0200c10:	e04a                	sd	s2,0(sp)
ffffffffc0200c12:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200c14:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200c18:	e822                	sd	s0,16(sp)
ffffffffc0200c1a:	e426                	sd	s1,8(sp)
ffffffffc0200c1c:	ec06                	sd	ra,24(sp)
ffffffffc0200c1e:	84ae                	mv	s1,a1
ffffffffc0200c20:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200c22:	627000ef          	jal	ra,ffffffffc0201a48 <kmalloc>
    if (vma != NULL) {
ffffffffc0200c26:	c509                	beqz	a0,ffffffffc0200c30 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200c28:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200c2c:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200c2e:	cd00                	sw	s0,24(a0)
}
ffffffffc0200c30:	60e2                	ld	ra,24(sp)
ffffffffc0200c32:	6442                	ld	s0,16(sp)
ffffffffc0200c34:	64a2                	ld	s1,8(sp)
ffffffffc0200c36:	6902                	ld	s2,0(sp)
ffffffffc0200c38:	6105                	addi	sp,sp,32
ffffffffc0200c3a:	8082                	ret

ffffffffc0200c3c <find_vma>:
    if (mm != NULL) {
ffffffffc0200c3c:	c51d                	beqz	a0,ffffffffc0200c6a <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0200c3e:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200c40:	c781                	beqz	a5,ffffffffc0200c48 <find_vma+0xc>
ffffffffc0200c42:	6798                	ld	a4,8(a5)
ffffffffc0200c44:	02e5f663          	bleu	a4,a1,ffffffffc0200c70 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0200c48:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200c4a:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200c4c:	00f50f63          	beq	a0,a5,ffffffffc0200c6a <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200c50:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200c54:	fee5ebe3          	bltu	a1,a4,ffffffffc0200c4a <find_vma+0xe>
ffffffffc0200c58:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200c5c:	fee5f7e3          	bleu	a4,a1,ffffffffc0200c4a <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0200c60:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0200c62:	c781                	beqz	a5,ffffffffc0200c6a <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0200c64:	e91c                	sd	a5,16(a0)
}
ffffffffc0200c66:	853e                	mv	a0,a5
ffffffffc0200c68:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0200c6a:	4781                	li	a5,0
}
ffffffffc0200c6c:	853e                	mv	a0,a5
ffffffffc0200c6e:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200c70:	6b98                	ld	a4,16(a5)
ffffffffc0200c72:	fce5fbe3          	bleu	a4,a1,ffffffffc0200c48 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0200c76:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0200c78:	b7fd                	j	ffffffffc0200c66 <find_vma+0x2a>

ffffffffc0200c7a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c7a:	6590                	ld	a2,8(a1)
ffffffffc0200c7c:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200c80:	1141                	addi	sp,sp,-16
ffffffffc0200c82:	e406                	sd	ra,8(sp)
ffffffffc0200c84:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c86:	01066863          	bltu	a2,a6,ffffffffc0200c96 <insert_vma_struct+0x1c>
ffffffffc0200c8a:	a8b9                	j	ffffffffc0200ce8 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200c8c:	fe87b683          	ld	a3,-24(a5)
ffffffffc0200c90:	04d66763          	bltu	a2,a3,ffffffffc0200cde <insert_vma_struct+0x64>
ffffffffc0200c94:	873e                	mv	a4,a5
ffffffffc0200c96:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0200c98:	fef51ae3          	bne	a0,a5,ffffffffc0200c8c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200c9c:	02a70463          	beq	a4,a0,ffffffffc0200cc4 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200ca0:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200ca4:	fe873883          	ld	a7,-24(a4)
ffffffffc0200ca8:	08d8f063          	bleu	a3,a7,ffffffffc0200d28 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200cac:	04d66e63          	bltu	a2,a3,ffffffffc0200d08 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0200cb0:	00f50a63          	beq	a0,a5,ffffffffc0200cc4 <insert_vma_struct+0x4a>
ffffffffc0200cb4:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200cb8:	0506e863          	bltu	a3,a6,ffffffffc0200d08 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0200cbc:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200cc0:	02c6f263          	bleu	a2,a3,ffffffffc0200ce4 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200cc4:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0200cc6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200cc8:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200ccc:	e390                	sd	a2,0(a5)
ffffffffc0200cce:	e710                	sd	a2,8(a4)
}
ffffffffc0200cd0:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200cd2:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200cd4:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0200cd6:	2685                	addiw	a3,a3,1
ffffffffc0200cd8:	d114                	sw	a3,32(a0)
}
ffffffffc0200cda:	0141                	addi	sp,sp,16
ffffffffc0200cdc:	8082                	ret
    if (le_prev != list) {
ffffffffc0200cde:	fca711e3          	bne	a4,a0,ffffffffc0200ca0 <insert_vma_struct+0x26>
ffffffffc0200ce2:	bfd9                	j	ffffffffc0200cb8 <insert_vma_struct+0x3e>
ffffffffc0200ce4:	ebbff0ef          	jal	ra,ffffffffc0200b9e <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200ce8:	00005697          	auipc	a3,0x5
ffffffffc0200cec:	c2068693          	addi	a3,a3,-992 # ffffffffc0205908 <commands+0x928>
ffffffffc0200cf0:	00005617          	auipc	a2,0x5
ffffffffc0200cf4:	b5060613          	addi	a2,a2,-1200 # ffffffffc0205840 <commands+0x860>
ffffffffc0200cf8:	08500593          	li	a1,133
ffffffffc0200cfc:	00005517          	auipc	a0,0x5
ffffffffc0200d00:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0205858 <commands+0x878>
ffffffffc0200d04:	cd2ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200d08:	00005697          	auipc	a3,0x5
ffffffffc0200d0c:	c4068693          	addi	a3,a3,-960 # ffffffffc0205948 <commands+0x968>
ffffffffc0200d10:	00005617          	auipc	a2,0x5
ffffffffc0200d14:	b3060613          	addi	a2,a2,-1232 # ffffffffc0205840 <commands+0x860>
ffffffffc0200d18:	07d00593          	li	a1,125
ffffffffc0200d1c:	00005517          	auipc	a0,0x5
ffffffffc0200d20:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0205858 <commands+0x878>
ffffffffc0200d24:	cb2ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200d28:	00005697          	auipc	a3,0x5
ffffffffc0200d2c:	c0068693          	addi	a3,a3,-1024 # ffffffffc0205928 <commands+0x948>
ffffffffc0200d30:	00005617          	auipc	a2,0x5
ffffffffc0200d34:	b1060613          	addi	a2,a2,-1264 # ffffffffc0205840 <commands+0x860>
ffffffffc0200d38:	07c00593          	li	a1,124
ffffffffc0200d3c:	00005517          	auipc	a0,0x5
ffffffffc0200d40:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0205858 <commands+0x878>
ffffffffc0200d44:	c92ff0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0200d48 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200d48:	1141                	addi	sp,sp,-16
ffffffffc0200d4a:	e022                	sd	s0,0(sp)
ffffffffc0200d4c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200d4e:	6508                	ld	a0,8(a0)
ffffffffc0200d50:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200d52:	00a40c63          	beq	s0,a0,ffffffffc0200d6a <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d56:	6118                	ld	a4,0(a0)
ffffffffc0200d58:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200d5a:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200d5c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200d5e:	e398                	sd	a4,0(a5)
ffffffffc0200d60:	5a5000ef          	jal	ra,ffffffffc0201b04 <kfree>
    return listelm->next;
ffffffffc0200d64:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200d66:	fea418e3          	bne	s0,a0,ffffffffc0200d56 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0200d6a:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200d6c:	6402                	ld	s0,0(sp)
ffffffffc0200d6e:	60a2                	ld	ra,8(sp)
ffffffffc0200d70:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0200d72:	5930006f          	j	ffffffffc0201b04 <kfree>

ffffffffc0200d76 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200d76:	7139                	addi	sp,sp,-64
ffffffffc0200d78:	f822                	sd	s0,48(sp)
ffffffffc0200d7a:	f426                	sd	s1,40(sp)
ffffffffc0200d7c:	fc06                	sd	ra,56(sp)
ffffffffc0200d7e:	f04a                	sd	s2,32(sp)
ffffffffc0200d80:	ec4e                	sd	s3,24(sp)
ffffffffc0200d82:	e852                	sd	s4,16(sp)
ffffffffc0200d84:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc0200d86:	e3dff0ef          	jal	ra,ffffffffc0200bc2 <mm_create>
    assert(mm != NULL);
ffffffffc0200d8a:	842a                	mv	s0,a0
ffffffffc0200d8c:	03200493          	li	s1,50
ffffffffc0200d90:	e919                	bnez	a0,ffffffffc0200da6 <vmm_init+0x30>
ffffffffc0200d92:	a989                	j	ffffffffc02011e4 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0200d94:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d96:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d98:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200d9c:	14ed                	addi	s1,s1,-5
ffffffffc0200d9e:	8522                	mv	a0,s0
ffffffffc0200da0:	edbff0ef          	jal	ra,ffffffffc0200c7a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0200da4:	c88d                	beqz	s1,ffffffffc0200dd6 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200da6:	03000513          	li	a0,48
ffffffffc0200daa:	49f000ef          	jal	ra,ffffffffc0201a48 <kmalloc>
ffffffffc0200dae:	85aa                	mv	a1,a0
ffffffffc0200db0:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0200db4:	f165                	bnez	a0,ffffffffc0200d94 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0200db6:	00005697          	auipc	a3,0x5
ffffffffc0200dba:	e3268693          	addi	a3,a3,-462 # ffffffffc0205be8 <commands+0xc08>
ffffffffc0200dbe:	00005617          	auipc	a2,0x5
ffffffffc0200dc2:	a8260613          	addi	a2,a2,-1406 # ffffffffc0205840 <commands+0x860>
ffffffffc0200dc6:	0c900593          	li	a1,201
ffffffffc0200dca:	00005517          	auipc	a0,0x5
ffffffffc0200dce:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0205858 <commands+0x878>
ffffffffc0200dd2:	c04ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0200dd6:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200dda:	1f900913          	li	s2,505
ffffffffc0200dde:	a819                	j	ffffffffc0200df4 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0200de0:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200de2:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200de4:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200de8:	0495                	addi	s1,s1,5
ffffffffc0200dea:	8522                	mv	a0,s0
ffffffffc0200dec:	e8fff0ef          	jal	ra,ffffffffc0200c7a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200df0:	03248a63          	beq	s1,s2,ffffffffc0200e24 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200df4:	03000513          	li	a0,48
ffffffffc0200df8:	451000ef          	jal	ra,ffffffffc0201a48 <kmalloc>
ffffffffc0200dfc:	85aa                	mv	a1,a0
ffffffffc0200dfe:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0200e02:	fd79                	bnez	a0,ffffffffc0200de0 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0200e04:	00005697          	auipc	a3,0x5
ffffffffc0200e08:	de468693          	addi	a3,a3,-540 # ffffffffc0205be8 <commands+0xc08>
ffffffffc0200e0c:	00005617          	auipc	a2,0x5
ffffffffc0200e10:	a3460613          	addi	a2,a2,-1484 # ffffffffc0205840 <commands+0x860>
ffffffffc0200e14:	0cf00593          	li	a1,207
ffffffffc0200e18:	00005517          	auipc	a0,0x5
ffffffffc0200e1c:	a4050513          	addi	a0,a0,-1472 # ffffffffc0205858 <commands+0x878>
ffffffffc0200e20:	bb6ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0200e24:	6418                	ld	a4,8(s0)
ffffffffc0200e26:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200e28:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200e2c:	2ee40063          	beq	s0,a4,ffffffffc020110c <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200e30:	fe873603          	ld	a2,-24(a4)
ffffffffc0200e34:	ffe78693          	addi	a3,a5,-2
ffffffffc0200e38:	24d61a63          	bne	a2,a3,ffffffffc020108c <vmm_init+0x316>
ffffffffc0200e3c:	ff073683          	ld	a3,-16(a4)
ffffffffc0200e40:	24f69663          	bne	a3,a5,ffffffffc020108c <vmm_init+0x316>
ffffffffc0200e44:	0795                	addi	a5,a5,5
ffffffffc0200e46:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0200e48:	feb792e3          	bne	a5,a1,ffffffffc0200e2c <vmm_init+0xb6>
ffffffffc0200e4c:	491d                	li	s2,7
ffffffffc0200e4e:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e50:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200e54:	85a6                	mv	a1,s1
ffffffffc0200e56:	8522                	mv	a0,s0
ffffffffc0200e58:	de5ff0ef          	jal	ra,ffffffffc0200c3c <find_vma>
ffffffffc0200e5c:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0200e5e:	30050763          	beqz	a0,ffffffffc020116c <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200e62:	00148593          	addi	a1,s1,1
ffffffffc0200e66:	8522                	mv	a0,s0
ffffffffc0200e68:	dd5ff0ef          	jal	ra,ffffffffc0200c3c <find_vma>
ffffffffc0200e6c:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0200e6e:	2c050f63          	beqz	a0,ffffffffc020114c <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200e72:	85ca                	mv	a1,s2
ffffffffc0200e74:	8522                	mv	a0,s0
ffffffffc0200e76:	dc7ff0ef          	jal	ra,ffffffffc0200c3c <find_vma>
        assert(vma3 == NULL);
ffffffffc0200e7a:	2a051963          	bnez	a0,ffffffffc020112c <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200e7e:	00348593          	addi	a1,s1,3
ffffffffc0200e82:	8522                	mv	a0,s0
ffffffffc0200e84:	db9ff0ef          	jal	ra,ffffffffc0200c3c <find_vma>
        assert(vma4 == NULL);
ffffffffc0200e88:	32051263          	bnez	a0,ffffffffc02011ac <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200e8c:	00448593          	addi	a1,s1,4
ffffffffc0200e90:	8522                	mv	a0,s0
ffffffffc0200e92:	dabff0ef          	jal	ra,ffffffffc0200c3c <find_vma>
        assert(vma5 == NULL);
ffffffffc0200e96:	2e051b63          	bnez	a0,ffffffffc020118c <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200e9a:	008a3783          	ld	a5,8(s4)
ffffffffc0200e9e:	20979763          	bne	a5,s1,ffffffffc02010ac <vmm_init+0x336>
ffffffffc0200ea2:	010a3783          	ld	a5,16(s4)
ffffffffc0200ea6:	21279363          	bne	a5,s2,ffffffffc02010ac <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200eaa:	0089b783          	ld	a5,8(s3)
ffffffffc0200eae:	20979f63          	bne	a5,s1,ffffffffc02010cc <vmm_init+0x356>
ffffffffc0200eb2:	0109b783          	ld	a5,16(s3)
ffffffffc0200eb6:	21279b63          	bne	a5,s2,ffffffffc02010cc <vmm_init+0x356>
ffffffffc0200eba:	0495                	addi	s1,s1,5
ffffffffc0200ebc:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200ebe:	f9549be3          	bne	s1,s5,ffffffffc0200e54 <vmm_init+0xde>
ffffffffc0200ec2:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0200ec4:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0200ec6:	85a6                	mv	a1,s1
ffffffffc0200ec8:	8522                	mv	a0,s0
ffffffffc0200eca:	d73ff0ef          	jal	ra,ffffffffc0200c3c <find_vma>
ffffffffc0200ece:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0200ed2:	c90d                	beqz	a0,ffffffffc0200f04 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0200ed4:	6914                	ld	a3,16(a0)
ffffffffc0200ed6:	6510                	ld	a2,8(a0)
ffffffffc0200ed8:	00005517          	auipc	a0,0x5
ffffffffc0200edc:	ba050513          	addi	a0,a0,-1120 # ffffffffc0205a78 <commands+0xa98>
ffffffffc0200ee0:	9f0ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200ee4:	00005697          	auipc	a3,0x5
ffffffffc0200ee8:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0205aa0 <commands+0xac0>
ffffffffc0200eec:	00005617          	auipc	a2,0x5
ffffffffc0200ef0:	95460613          	addi	a2,a2,-1708 # ffffffffc0205840 <commands+0x860>
ffffffffc0200ef4:	0f100593          	li	a1,241
ffffffffc0200ef8:	00005517          	auipc	a0,0x5
ffffffffc0200efc:	96050513          	addi	a0,a0,-1696 # ffffffffc0205858 <commands+0x878>
ffffffffc0200f00:	ad6ff0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0200f04:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0200f06:	fd2490e3          	bne	s1,s2,ffffffffc0200ec6 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0200f0a:	8522                	mv	a0,s0
ffffffffc0200f0c:	e3dff0ef          	jal	ra,ffffffffc0200d48 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200f10:	00005517          	auipc	a0,0x5
ffffffffc0200f14:	ba850513          	addi	a0,a0,-1112 # ffffffffc0205ab8 <commands+0xad8>
ffffffffc0200f18:	9b8ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200f1c:	266020ef          	jal	ra,ffffffffc0203182 <nr_free_pages>
ffffffffc0200f20:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0200f22:	ca1ff0ef          	jal	ra,ffffffffc0200bc2 <mm_create>
ffffffffc0200f26:	00014797          	auipc	a5,0x14
ffffffffc0200f2a:	5aa7b923          	sd	a0,1458(a5) # ffffffffc02154d8 <check_mm_struct>
ffffffffc0200f2e:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0200f30:	36050663          	beqz	a0,ffffffffc020129c <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200f34:	00014797          	auipc	a5,0x14
ffffffffc0200f38:	56c78793          	addi	a5,a5,1388 # ffffffffc02154a0 <boot_pgdir>
ffffffffc0200f3c:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0200f40:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200f44:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0200f48:	2c079e63          	bnez	a5,ffffffffc0201224 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200f4c:	03000513          	li	a0,48
ffffffffc0200f50:	2f9000ef          	jal	ra,ffffffffc0201a48 <kmalloc>
ffffffffc0200f54:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0200f56:	18050b63          	beqz	a0,ffffffffc02010ec <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0200f5a:	002007b7          	lui	a5,0x200
ffffffffc0200f5e:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0200f60:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0200f62:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0200f64:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0200f66:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0200f68:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0200f6c:	d0fff0ef          	jal	ra,ffffffffc0200c7a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f70:	10000593          	li	a1,256
ffffffffc0200f74:	8526                	mv	a0,s1
ffffffffc0200f76:	cc7ff0ef          	jal	ra,ffffffffc0200c3c <find_vma>
ffffffffc0200f7a:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0200f7e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f82:	2ca41163          	bne	s0,a0,ffffffffc0201244 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0200f86:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0200f8a:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0200f8c:	fee79de3          	bne	a5,a4,ffffffffc0200f86 <vmm_init+0x210>
        sum += i;
ffffffffc0200f90:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0200f92:	10000793          	li	a5,256
        sum += i;
ffffffffc0200f96:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0200f9a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0200f9e:	0007c683          	lbu	a3,0(a5)
ffffffffc0200fa2:	0785                	addi	a5,a5,1
ffffffffc0200fa4:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0200fa6:	fec79ce3          	bne	a5,a2,ffffffffc0200f9e <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0200faa:	2c071963          	bnez	a4,ffffffffc020127c <vmm_init+0x506>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200fae:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200fb2:	00014a97          	auipc	s5,0x14
ffffffffc0200fb6:	4f6a8a93          	addi	s5,s5,1270 # ffffffffc02154a8 <npage>
ffffffffc0200fba:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0200fbe:	078a                	slli	a5,a5,0x2
ffffffffc0200fc0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200fc2:	20e7f563          	bleu	a4,a5,ffffffffc02011cc <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0200fc6:	00006697          	auipc	a3,0x6
ffffffffc0200fca:	faa68693          	addi	a3,a3,-86 # ffffffffc0206f70 <nbase>
ffffffffc0200fce:	0006ba03          	ld	s4,0(a3)
ffffffffc0200fd2:	414786b3          	sub	a3,a5,s4
ffffffffc0200fd6:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0200fd8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0200fda:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0200fdc:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0200fde:	83b1                	srli	a5,a5,0xc
ffffffffc0200fe0:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fe2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0200fe4:	28e7f063          	bleu	a4,a5,ffffffffc0201264 <vmm_init+0x4ee>
ffffffffc0200fe8:	00014797          	auipc	a5,0x14
ffffffffc0200fec:	5f078793          	addi	a5,a5,1520 # ffffffffc02155d8 <va_pa_offset>
ffffffffc0200ff0:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0200ff2:	4581                	li	a1,0
ffffffffc0200ff4:	854a                	mv	a0,s2
ffffffffc0200ff6:	9436                	add	s0,s0,a3
ffffffffc0200ff8:	3fe020ef          	jal	ra,ffffffffc02033f6 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0200ffc:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0200ffe:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201002:	078a                	slli	a5,a5,0x2
ffffffffc0201004:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201006:	1ce7f363          	bleu	a4,a5,ffffffffc02011cc <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020100a:	00014417          	auipc	s0,0x14
ffffffffc020100e:	5de40413          	addi	s0,s0,1502 # ffffffffc02155e8 <pages>
ffffffffc0201012:	6008                	ld	a0,0(s0)
ffffffffc0201014:	414787b3          	sub	a5,a5,s4
ffffffffc0201018:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc020101a:	953e                	add	a0,a0,a5
ffffffffc020101c:	4585                	li	a1,1
ffffffffc020101e:	11e020ef          	jal	ra,ffffffffc020313c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201022:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201026:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020102a:	078a                	slli	a5,a5,0x2
ffffffffc020102c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020102e:	18e7ff63          	bleu	a4,a5,ffffffffc02011cc <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201032:	6008                	ld	a0,0(s0)
ffffffffc0201034:	414787b3          	sub	a5,a5,s4
ffffffffc0201038:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020103a:	4585                	li	a1,1
ffffffffc020103c:	953e                	add	a0,a0,a5
ffffffffc020103e:	0fe020ef          	jal	ra,ffffffffc020313c <free_pages>
    pgdir[0] = 0;
ffffffffc0201042:	00093023          	sd	zero,0(s2)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc0201046:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc020104a:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc020104e:	8526                	mv	a0,s1
ffffffffc0201050:	cf9ff0ef          	jal	ra,ffffffffc0200d48 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0201054:	00014797          	auipc	a5,0x14
ffffffffc0201058:	4807b223          	sd	zero,1156(a5) # ffffffffc02154d8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020105c:	126020ef          	jal	ra,ffffffffc0203182 <nr_free_pages>
ffffffffc0201060:	1aa99263          	bne	s3,a0,ffffffffc0201204 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0201064:	00005517          	auipc	a0,0x5
ffffffffc0201068:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0205bb0 <commands+0xbd0>
ffffffffc020106c:	864ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201070:	7442                	ld	s0,48(sp)
ffffffffc0201072:	70e2                	ld	ra,56(sp)
ffffffffc0201074:	74a2                	ld	s1,40(sp)
ffffffffc0201076:	7902                	ld	s2,32(sp)
ffffffffc0201078:	69e2                	ld	s3,24(sp)
ffffffffc020107a:	6a42                	ld	s4,16(sp)
ffffffffc020107c:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020107e:	00005517          	auipc	a0,0x5
ffffffffc0201082:	b5250513          	addi	a0,a0,-1198 # ffffffffc0205bd0 <commands+0xbf0>
}
ffffffffc0201086:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201088:	848ff06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020108c:	00005697          	auipc	a3,0x5
ffffffffc0201090:	90468693          	addi	a3,a3,-1788 # ffffffffc0205990 <commands+0x9b0>
ffffffffc0201094:	00004617          	auipc	a2,0x4
ffffffffc0201098:	7ac60613          	addi	a2,a2,1964 # ffffffffc0205840 <commands+0x860>
ffffffffc020109c:	0d800593          	li	a1,216
ffffffffc02010a0:	00004517          	auipc	a0,0x4
ffffffffc02010a4:	7b850513          	addi	a0,a0,1976 # ffffffffc0205858 <commands+0x878>
ffffffffc02010a8:	92eff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02010ac:	00005697          	auipc	a3,0x5
ffffffffc02010b0:	96c68693          	addi	a3,a3,-1684 # ffffffffc0205a18 <commands+0xa38>
ffffffffc02010b4:	00004617          	auipc	a2,0x4
ffffffffc02010b8:	78c60613          	addi	a2,a2,1932 # ffffffffc0205840 <commands+0x860>
ffffffffc02010bc:	0e800593          	li	a1,232
ffffffffc02010c0:	00004517          	auipc	a0,0x4
ffffffffc02010c4:	79850513          	addi	a0,a0,1944 # ffffffffc0205858 <commands+0x878>
ffffffffc02010c8:	90eff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02010cc:	00005697          	auipc	a3,0x5
ffffffffc02010d0:	97c68693          	addi	a3,a3,-1668 # ffffffffc0205a48 <commands+0xa68>
ffffffffc02010d4:	00004617          	auipc	a2,0x4
ffffffffc02010d8:	76c60613          	addi	a2,a2,1900 # ffffffffc0205840 <commands+0x860>
ffffffffc02010dc:	0e900593          	li	a1,233
ffffffffc02010e0:	00004517          	auipc	a0,0x4
ffffffffc02010e4:	77850513          	addi	a0,a0,1912 # ffffffffc0205858 <commands+0x878>
ffffffffc02010e8:	8eeff0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(vma != NULL);
ffffffffc02010ec:	00005697          	auipc	a3,0x5
ffffffffc02010f0:	afc68693          	addi	a3,a3,-1284 # ffffffffc0205be8 <commands+0xc08>
ffffffffc02010f4:	00004617          	auipc	a2,0x4
ffffffffc02010f8:	74c60613          	addi	a2,a2,1868 # ffffffffc0205840 <commands+0x860>
ffffffffc02010fc:	10800593          	li	a1,264
ffffffffc0201100:	00004517          	auipc	a0,0x4
ffffffffc0201104:	75850513          	addi	a0,a0,1880 # ffffffffc0205858 <commands+0x878>
ffffffffc0201108:	8ceff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020110c:	00005697          	auipc	a3,0x5
ffffffffc0201110:	86c68693          	addi	a3,a3,-1940 # ffffffffc0205978 <commands+0x998>
ffffffffc0201114:	00004617          	auipc	a2,0x4
ffffffffc0201118:	72c60613          	addi	a2,a2,1836 # ffffffffc0205840 <commands+0x860>
ffffffffc020111c:	0d600593          	li	a1,214
ffffffffc0201120:	00004517          	auipc	a0,0x4
ffffffffc0201124:	73850513          	addi	a0,a0,1848 # ffffffffc0205858 <commands+0x878>
ffffffffc0201128:	8aeff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma3 == NULL);
ffffffffc020112c:	00005697          	auipc	a3,0x5
ffffffffc0201130:	8bc68693          	addi	a3,a3,-1860 # ffffffffc02059e8 <commands+0xa08>
ffffffffc0201134:	00004617          	auipc	a2,0x4
ffffffffc0201138:	70c60613          	addi	a2,a2,1804 # ffffffffc0205840 <commands+0x860>
ffffffffc020113c:	0e200593          	li	a1,226
ffffffffc0201140:	00004517          	auipc	a0,0x4
ffffffffc0201144:	71850513          	addi	a0,a0,1816 # ffffffffc0205858 <commands+0x878>
ffffffffc0201148:	88eff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma2 != NULL);
ffffffffc020114c:	00005697          	auipc	a3,0x5
ffffffffc0201150:	88c68693          	addi	a3,a3,-1908 # ffffffffc02059d8 <commands+0x9f8>
ffffffffc0201154:	00004617          	auipc	a2,0x4
ffffffffc0201158:	6ec60613          	addi	a2,a2,1772 # ffffffffc0205840 <commands+0x860>
ffffffffc020115c:	0e000593          	li	a1,224
ffffffffc0201160:	00004517          	auipc	a0,0x4
ffffffffc0201164:	6f850513          	addi	a0,a0,1784 # ffffffffc0205858 <commands+0x878>
ffffffffc0201168:	86eff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma1 != NULL);
ffffffffc020116c:	00005697          	auipc	a3,0x5
ffffffffc0201170:	85c68693          	addi	a3,a3,-1956 # ffffffffc02059c8 <commands+0x9e8>
ffffffffc0201174:	00004617          	auipc	a2,0x4
ffffffffc0201178:	6cc60613          	addi	a2,a2,1740 # ffffffffc0205840 <commands+0x860>
ffffffffc020117c:	0de00593          	li	a1,222
ffffffffc0201180:	00004517          	auipc	a0,0x4
ffffffffc0201184:	6d850513          	addi	a0,a0,1752 # ffffffffc0205858 <commands+0x878>
ffffffffc0201188:	84eff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma5 == NULL);
ffffffffc020118c:	00005697          	auipc	a3,0x5
ffffffffc0201190:	87c68693          	addi	a3,a3,-1924 # ffffffffc0205a08 <commands+0xa28>
ffffffffc0201194:	00004617          	auipc	a2,0x4
ffffffffc0201198:	6ac60613          	addi	a2,a2,1708 # ffffffffc0205840 <commands+0x860>
ffffffffc020119c:	0e600593          	li	a1,230
ffffffffc02011a0:	00004517          	auipc	a0,0x4
ffffffffc02011a4:	6b850513          	addi	a0,a0,1720 # ffffffffc0205858 <commands+0x878>
ffffffffc02011a8:	82eff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(vma4 == NULL);
ffffffffc02011ac:	00005697          	auipc	a3,0x5
ffffffffc02011b0:	84c68693          	addi	a3,a3,-1972 # ffffffffc02059f8 <commands+0xa18>
ffffffffc02011b4:	00004617          	auipc	a2,0x4
ffffffffc02011b8:	68c60613          	addi	a2,a2,1676 # ffffffffc0205840 <commands+0x860>
ffffffffc02011bc:	0e400593          	li	a1,228
ffffffffc02011c0:	00004517          	auipc	a0,0x4
ffffffffc02011c4:	69850513          	addi	a0,a0,1688 # ffffffffc0205858 <commands+0x878>
ffffffffc02011c8:	80eff0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011cc:	00005617          	auipc	a2,0x5
ffffffffc02011d0:	96460613          	addi	a2,a2,-1692 # ffffffffc0205b30 <commands+0xb50>
ffffffffc02011d4:	06200593          	li	a1,98
ffffffffc02011d8:	00005517          	auipc	a0,0x5
ffffffffc02011dc:	97850513          	addi	a0,a0,-1672 # ffffffffc0205b50 <commands+0xb70>
ffffffffc02011e0:	ff7fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(mm != NULL);
ffffffffc02011e4:	00004697          	auipc	a3,0x4
ffffffffc02011e8:	78468693          	addi	a3,a3,1924 # ffffffffc0205968 <commands+0x988>
ffffffffc02011ec:	00004617          	auipc	a2,0x4
ffffffffc02011f0:	65460613          	addi	a2,a2,1620 # ffffffffc0205840 <commands+0x860>
ffffffffc02011f4:	0c200593          	li	a1,194
ffffffffc02011f8:	00004517          	auipc	a0,0x4
ffffffffc02011fc:	66050513          	addi	a0,a0,1632 # ffffffffc0205858 <commands+0x878>
ffffffffc0201200:	fd7fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201204:	00005697          	auipc	a3,0x5
ffffffffc0201208:	98468693          	addi	a3,a3,-1660 # ffffffffc0205b88 <commands+0xba8>
ffffffffc020120c:	00004617          	auipc	a2,0x4
ffffffffc0201210:	63460613          	addi	a2,a2,1588 # ffffffffc0205840 <commands+0x860>
ffffffffc0201214:	12400593          	li	a1,292
ffffffffc0201218:	00004517          	auipc	a0,0x4
ffffffffc020121c:	64050513          	addi	a0,a0,1600 # ffffffffc0205858 <commands+0x878>
ffffffffc0201220:	fb7fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201224:	00005697          	auipc	a3,0x5
ffffffffc0201228:	8cc68693          	addi	a3,a3,-1844 # ffffffffc0205af0 <commands+0xb10>
ffffffffc020122c:	00004617          	auipc	a2,0x4
ffffffffc0201230:	61460613          	addi	a2,a2,1556 # ffffffffc0205840 <commands+0x860>
ffffffffc0201234:	10500593          	li	a1,261
ffffffffc0201238:	00004517          	auipc	a0,0x4
ffffffffc020123c:	62050513          	addi	a0,a0,1568 # ffffffffc0205858 <commands+0x878>
ffffffffc0201240:	f97fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0201244:	00005697          	auipc	a3,0x5
ffffffffc0201248:	8bc68693          	addi	a3,a3,-1860 # ffffffffc0205b00 <commands+0xb20>
ffffffffc020124c:	00004617          	auipc	a2,0x4
ffffffffc0201250:	5f460613          	addi	a2,a2,1524 # ffffffffc0205840 <commands+0x860>
ffffffffc0201254:	10d00593          	li	a1,269
ffffffffc0201258:	00004517          	auipc	a0,0x4
ffffffffc020125c:	60050513          	addi	a0,a0,1536 # ffffffffc0205858 <commands+0x878>
ffffffffc0201260:	f77fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201264:	00005617          	auipc	a2,0x5
ffffffffc0201268:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0205b60 <commands+0xb80>
ffffffffc020126c:	06900593          	li	a1,105
ffffffffc0201270:	00005517          	auipc	a0,0x5
ffffffffc0201274:	8e050513          	addi	a0,a0,-1824 # ffffffffc0205b50 <commands+0xb70>
ffffffffc0201278:	f5ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(sum == 0);
ffffffffc020127c:	00005697          	auipc	a3,0x5
ffffffffc0201280:	8a468693          	addi	a3,a3,-1884 # ffffffffc0205b20 <commands+0xb40>
ffffffffc0201284:	00004617          	auipc	a2,0x4
ffffffffc0201288:	5bc60613          	addi	a2,a2,1468 # ffffffffc0205840 <commands+0x860>
ffffffffc020128c:	11700593          	li	a1,279
ffffffffc0201290:	00004517          	auipc	a0,0x4
ffffffffc0201294:	5c850513          	addi	a0,a0,1480 # ffffffffc0205858 <commands+0x878>
ffffffffc0201298:	f3ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020129c:	00005697          	auipc	a3,0x5
ffffffffc02012a0:	83c68693          	addi	a3,a3,-1988 # ffffffffc0205ad8 <commands+0xaf8>
ffffffffc02012a4:	00004617          	auipc	a2,0x4
ffffffffc02012a8:	59c60613          	addi	a2,a2,1436 # ffffffffc0205840 <commands+0x860>
ffffffffc02012ac:	10100593          	li	a1,257
ffffffffc02012b0:	00004517          	auipc	a0,0x4
ffffffffc02012b4:	5a850513          	addi	a0,a0,1448 # ffffffffc0205858 <commands+0x878>
ffffffffc02012b8:	f1ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02012bc <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc02012bc:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02012be:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc02012c0:	f022                	sd	s0,32(sp)
ffffffffc02012c2:	ec26                	sd	s1,24(sp)
ffffffffc02012c4:	f406                	sd	ra,40(sp)
ffffffffc02012c6:	e84a                	sd	s2,16(sp)
ffffffffc02012c8:	8432                	mv	s0,a2
ffffffffc02012ca:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02012cc:	971ff0ef          	jal	ra,ffffffffc0200c3c <find_vma>

    pgfault_num++;
ffffffffc02012d0:	00014797          	auipc	a5,0x14
ffffffffc02012d4:	1b078793          	addi	a5,a5,432 # ffffffffc0215480 <pgfault_num>
ffffffffc02012d8:	439c                	lw	a5,0(a5)
ffffffffc02012da:	2785                	addiw	a5,a5,1
ffffffffc02012dc:	00014717          	auipc	a4,0x14
ffffffffc02012e0:	1af72223          	sw	a5,420(a4) # ffffffffc0215480 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02012e4:	c551                	beqz	a0,ffffffffc0201370 <do_pgfault+0xb4>
ffffffffc02012e6:	651c                	ld	a5,8(a0)
ffffffffc02012e8:	08f46463          	bltu	s0,a5,ffffffffc0201370 <do_pgfault+0xb4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02012ec:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02012ee:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02012f0:	8b89                	andi	a5,a5,2
ffffffffc02012f2:	efb1                	bnez	a5,ffffffffc020134e <do_pgfault+0x92>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012f4:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02012f6:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012f8:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02012fa:	85a2                	mv	a1,s0
ffffffffc02012fc:	4605                	li	a2,1
ffffffffc02012fe:	6c5010ef          	jal	ra,ffffffffc02031c2 <get_pte>
ffffffffc0201302:	c941                	beqz	a0,ffffffffc0201392 <do_pgfault+0xd6>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0201304:	610c                	ld	a1,0(a0)
ffffffffc0201306:	c5b1                	beqz	a1,ffffffffc0201352 <do_pgfault+0x96>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201308:	00014797          	auipc	a5,0x14
ffffffffc020130c:	19078793          	addi	a5,a5,400 # ffffffffc0215498 <swap_init_ok>
ffffffffc0201310:	439c                	lw	a5,0(a5)
ffffffffc0201312:	2781                	sext.w	a5,a5
ffffffffc0201314:	c7bd                	beqz	a5,ffffffffc0201382 <do_pgfault+0xc6>
            struct Page *page = NULL;
            swap_in(mm,addr,&page);
ffffffffc0201316:	85a2                	mv	a1,s0
ffffffffc0201318:	0030                	addi	a2,sp,8
ffffffffc020131a:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc020131c:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc020131e:	1b2010ef          	jal	ra,ffffffffc02024d0 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0201322:	65a2                	ld	a1,8(sp)
ffffffffc0201324:	6c88                	ld	a0,24(s1)
ffffffffc0201326:	86ca                	mv	a3,s2
ffffffffc0201328:	8622                	mv	a2,s0
ffffffffc020132a:	140020ef          	jal	ra,ffffffffc020346a <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc020132e:	6622                	ld	a2,8(sp)
ffffffffc0201330:	4685                	li	a3,1
ffffffffc0201332:	85a2                	mv	a1,s0
ffffffffc0201334:	8526                	mv	a0,s1
ffffffffc0201336:	076010ef          	jal	ra,ffffffffc02023ac <swap_map_swappable>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc020133a:	6722                	ld	a4,8(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc020133c:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc020133e:	ff00                	sd	s0,56(a4)
failed:
    return ret;
}
ffffffffc0201340:	70a2                	ld	ra,40(sp)
ffffffffc0201342:	7402                	ld	s0,32(sp)
ffffffffc0201344:	64e2                	ld	s1,24(sp)
ffffffffc0201346:	6942                	ld	s2,16(sp)
ffffffffc0201348:	853e                	mv	a0,a5
ffffffffc020134a:	6145                	addi	sp,sp,48
ffffffffc020134c:	8082                	ret
        perm |= READ_WRITE;
ffffffffc020134e:	495d                	li	s2,23
ffffffffc0201350:	b755                	j	ffffffffc02012f4 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201352:	6c88                	ld	a0,24(s1)
ffffffffc0201354:	864a                	mv	a2,s2
ffffffffc0201356:	85a2                	mv	a1,s0
ffffffffc0201358:	461020ef          	jal	ra,ffffffffc0203fb8 <pgdir_alloc_page>
   ret = 0;
ffffffffc020135c:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020135e:	f16d                	bnez	a0,ffffffffc0201340 <do_pgfault+0x84>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201360:	00004517          	auipc	a0,0x4
ffffffffc0201364:	55850513          	addi	a0,a0,1368 # ffffffffc02058b8 <commands+0x8d8>
ffffffffc0201368:	d69fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020136c:	57f1                	li	a5,-4
            goto failed;
ffffffffc020136e:	bfc9                	j	ffffffffc0201340 <do_pgfault+0x84>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201370:	85a2                	mv	a1,s0
ffffffffc0201372:	00004517          	auipc	a0,0x4
ffffffffc0201376:	4f650513          	addi	a0,a0,1270 # ffffffffc0205868 <commands+0x888>
ffffffffc020137a:	d57fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc020137e:	57f5                	li	a5,-3
        goto failed;
ffffffffc0201380:	b7c1                	j	ffffffffc0201340 <do_pgfault+0x84>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201382:	00004517          	auipc	a0,0x4
ffffffffc0201386:	55e50513          	addi	a0,a0,1374 # ffffffffc02058e0 <commands+0x900>
ffffffffc020138a:	d47fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020138e:	57f1                	li	a5,-4
            goto failed;
ffffffffc0201390:	bf45                	j	ffffffffc0201340 <do_pgfault+0x84>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0201392:	00004517          	auipc	a0,0x4
ffffffffc0201396:	50650513          	addi	a0,a0,1286 # ffffffffc0205898 <commands+0x8b8>
ffffffffc020139a:	d37fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020139e:	57f1                	li	a5,-4
        goto failed;
ffffffffc02013a0:	b745                	j	ffffffffc0201340 <do_pgfault+0x84>

ffffffffc02013a2 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02013a2:	00014797          	auipc	a5,0x14
ffffffffc02013a6:	13e78793          	addi	a5,a5,318 # ffffffffc02154e0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02013aa:	f51c                	sd	a5,40(a0)
ffffffffc02013ac:	e79c                	sd	a5,8(a5)
ffffffffc02013ae:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02013b0:	4501                	li	a0,0
ffffffffc02013b2:	8082                	ret

ffffffffc02013b4 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02013b4:	4501                	li	a0,0
ffffffffc02013b6:	8082                	ret

ffffffffc02013b8 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02013b8:	4501                	li	a0,0
ffffffffc02013ba:	8082                	ret

ffffffffc02013bc <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02013bc:	4501                	li	a0,0
ffffffffc02013be:	8082                	ret

ffffffffc02013c0 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02013c0:	711d                	addi	sp,sp,-96
ffffffffc02013c2:	fc4e                	sd	s3,56(sp)
ffffffffc02013c4:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02013c6:	00005517          	auipc	a0,0x5
ffffffffc02013ca:	83250513          	addi	a0,a0,-1998 # ffffffffc0205bf8 <commands+0xc18>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02013ce:	698d                	lui	s3,0x3
ffffffffc02013d0:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02013d2:	e8a2                	sd	s0,80(sp)
ffffffffc02013d4:	e4a6                	sd	s1,72(sp)
ffffffffc02013d6:	ec86                	sd	ra,88(sp)
ffffffffc02013d8:	e0ca                	sd	s2,64(sp)
ffffffffc02013da:	f456                	sd	s5,40(sp)
ffffffffc02013dc:	f05a                	sd	s6,32(sp)
ffffffffc02013de:	ec5e                	sd	s7,24(sp)
ffffffffc02013e0:	e862                	sd	s8,16(sp)
ffffffffc02013e2:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc02013e4:	00014417          	auipc	s0,0x14
ffffffffc02013e8:	09c40413          	addi	s0,s0,156 # ffffffffc0215480 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02013ec:	ce5fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02013f0:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02013f4:	4004                	lw	s1,0(s0)
ffffffffc02013f6:	4791                	li	a5,4
ffffffffc02013f8:	2481                	sext.w	s1,s1
ffffffffc02013fa:	14f49963          	bne	s1,a5,ffffffffc020154c <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02013fe:	00005517          	auipc	a0,0x5
ffffffffc0201402:	84a50513          	addi	a0,a0,-1974 # ffffffffc0205c48 <commands+0xc68>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201406:	6a85                	lui	s5,0x1
ffffffffc0201408:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020140a:	cc7fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020140e:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0201412:	00042903          	lw	s2,0(s0)
ffffffffc0201416:	2901                	sext.w	s2,s2
ffffffffc0201418:	2a991a63          	bne	s2,s1,ffffffffc02016cc <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020141c:	00005517          	auipc	a0,0x5
ffffffffc0201420:	85450513          	addi	a0,a0,-1964 # ffffffffc0205c70 <commands+0xc90>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201424:	6b91                	lui	s7,0x4
ffffffffc0201426:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201428:	ca9fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020142c:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0201430:	4004                	lw	s1,0(s0)
ffffffffc0201432:	2481                	sext.w	s1,s1
ffffffffc0201434:	27249c63          	bne	s1,s2,ffffffffc02016ac <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201438:	00005517          	auipc	a0,0x5
ffffffffc020143c:	86050513          	addi	a0,a0,-1952 # ffffffffc0205c98 <commands+0xcb8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201440:	6909                	lui	s2,0x2
ffffffffc0201442:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201444:	c8dfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201448:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020144c:	401c                	lw	a5,0(s0)
ffffffffc020144e:	2781                	sext.w	a5,a5
ffffffffc0201450:	22979e63          	bne	a5,s1,ffffffffc020168c <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201454:	00005517          	auipc	a0,0x5
ffffffffc0201458:	86c50513          	addi	a0,a0,-1940 # ffffffffc0205cc0 <commands+0xce0>
ffffffffc020145c:	c75fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201460:	6795                	lui	a5,0x5
ffffffffc0201462:	4739                	li	a4,14
ffffffffc0201464:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0201468:	4004                	lw	s1,0(s0)
ffffffffc020146a:	4795                	li	a5,5
ffffffffc020146c:	2481                	sext.w	s1,s1
ffffffffc020146e:	1ef49f63          	bne	s1,a5,ffffffffc020166c <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201472:	00005517          	auipc	a0,0x5
ffffffffc0201476:	82650513          	addi	a0,a0,-2010 # ffffffffc0205c98 <commands+0xcb8>
ffffffffc020147a:	c57fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020147e:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0201482:	401c                	lw	a5,0(s0)
ffffffffc0201484:	2781                	sext.w	a5,a5
ffffffffc0201486:	1c979363          	bne	a5,s1,ffffffffc020164c <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020148a:	00004517          	auipc	a0,0x4
ffffffffc020148e:	7be50513          	addi	a0,a0,1982 # ffffffffc0205c48 <commands+0xc68>
ffffffffc0201492:	c3ffe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201496:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc020149a:	401c                	lw	a5,0(s0)
ffffffffc020149c:	4719                	li	a4,6
ffffffffc020149e:	2781                	sext.w	a5,a5
ffffffffc02014a0:	18e79663          	bne	a5,a4,ffffffffc020162c <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02014a4:	00004517          	auipc	a0,0x4
ffffffffc02014a8:	7f450513          	addi	a0,a0,2036 # ffffffffc0205c98 <commands+0xcb8>
ffffffffc02014ac:	c25fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02014b0:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc02014b4:	401c                	lw	a5,0(s0)
ffffffffc02014b6:	471d                	li	a4,7
ffffffffc02014b8:	2781                	sext.w	a5,a5
ffffffffc02014ba:	14e79963          	bne	a5,a4,ffffffffc020160c <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02014be:	00004517          	auipc	a0,0x4
ffffffffc02014c2:	73a50513          	addi	a0,a0,1850 # ffffffffc0205bf8 <commands+0xc18>
ffffffffc02014c6:	c0bfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02014ca:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02014ce:	401c                	lw	a5,0(s0)
ffffffffc02014d0:	4721                	li	a4,8
ffffffffc02014d2:	2781                	sext.w	a5,a5
ffffffffc02014d4:	10e79c63          	bne	a5,a4,ffffffffc02015ec <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02014d8:	00004517          	auipc	a0,0x4
ffffffffc02014dc:	79850513          	addi	a0,a0,1944 # ffffffffc0205c70 <commands+0xc90>
ffffffffc02014e0:	bf1fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02014e4:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc02014e8:	401c                	lw	a5,0(s0)
ffffffffc02014ea:	4725                	li	a4,9
ffffffffc02014ec:	2781                	sext.w	a5,a5
ffffffffc02014ee:	0ce79f63          	bne	a5,a4,ffffffffc02015cc <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02014f2:	00004517          	auipc	a0,0x4
ffffffffc02014f6:	7ce50513          	addi	a0,a0,1998 # ffffffffc0205cc0 <commands+0xce0>
ffffffffc02014fa:	bd7fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02014fe:	6795                	lui	a5,0x5
ffffffffc0201500:	4739                	li	a4,14
ffffffffc0201502:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0201506:	4004                	lw	s1,0(s0)
ffffffffc0201508:	47a9                	li	a5,10
ffffffffc020150a:	2481                	sext.w	s1,s1
ffffffffc020150c:	0af49063          	bne	s1,a5,ffffffffc02015ac <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201510:	00004517          	auipc	a0,0x4
ffffffffc0201514:	73850513          	addi	a0,a0,1848 # ffffffffc0205c48 <commands+0xc68>
ffffffffc0201518:	bb9fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020151c:	6785                	lui	a5,0x1
ffffffffc020151e:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201522:	06979563          	bne	a5,s1,ffffffffc020158c <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0201526:	401c                	lw	a5,0(s0)
ffffffffc0201528:	472d                	li	a4,11
ffffffffc020152a:	2781                	sext.w	a5,a5
ffffffffc020152c:	04e79063          	bne	a5,a4,ffffffffc020156c <_fifo_check_swap+0x1ac>
}
ffffffffc0201530:	60e6                	ld	ra,88(sp)
ffffffffc0201532:	6446                	ld	s0,80(sp)
ffffffffc0201534:	64a6                	ld	s1,72(sp)
ffffffffc0201536:	6906                	ld	s2,64(sp)
ffffffffc0201538:	79e2                	ld	s3,56(sp)
ffffffffc020153a:	7a42                	ld	s4,48(sp)
ffffffffc020153c:	7aa2                	ld	s5,40(sp)
ffffffffc020153e:	7b02                	ld	s6,32(sp)
ffffffffc0201540:	6be2                	ld	s7,24(sp)
ffffffffc0201542:	6c42                	ld	s8,16(sp)
ffffffffc0201544:	6ca2                	ld	s9,8(sp)
ffffffffc0201546:	4501                	li	a0,0
ffffffffc0201548:	6125                	addi	sp,sp,96
ffffffffc020154a:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020154c:	00004697          	auipc	a3,0x4
ffffffffc0201550:	6d468693          	addi	a3,a3,1748 # ffffffffc0205c20 <commands+0xc40>
ffffffffc0201554:	00004617          	auipc	a2,0x4
ffffffffc0201558:	2ec60613          	addi	a2,a2,748 # ffffffffc0205840 <commands+0x860>
ffffffffc020155c:	05600593          	li	a1,86
ffffffffc0201560:	00004517          	auipc	a0,0x4
ffffffffc0201564:	6d050513          	addi	a0,a0,1744 # ffffffffc0205c30 <commands+0xc50>
ffffffffc0201568:	c6ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==11);
ffffffffc020156c:	00005697          	auipc	a3,0x5
ffffffffc0201570:	80468693          	addi	a3,a3,-2044 # ffffffffc0205d70 <commands+0xd90>
ffffffffc0201574:	00004617          	auipc	a2,0x4
ffffffffc0201578:	2cc60613          	addi	a2,a2,716 # ffffffffc0205840 <commands+0x860>
ffffffffc020157c:	07800593          	li	a1,120
ffffffffc0201580:	00004517          	auipc	a0,0x4
ffffffffc0201584:	6b050513          	addi	a0,a0,1712 # ffffffffc0205c30 <commands+0xc50>
ffffffffc0201588:	c4ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020158c:	00004697          	auipc	a3,0x4
ffffffffc0201590:	7bc68693          	addi	a3,a3,1980 # ffffffffc0205d48 <commands+0xd68>
ffffffffc0201594:	00004617          	auipc	a2,0x4
ffffffffc0201598:	2ac60613          	addi	a2,a2,684 # ffffffffc0205840 <commands+0x860>
ffffffffc020159c:	07600593          	li	a1,118
ffffffffc02015a0:	00004517          	auipc	a0,0x4
ffffffffc02015a4:	69050513          	addi	a0,a0,1680 # ffffffffc0205c30 <commands+0xc50>
ffffffffc02015a8:	c2ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==10);
ffffffffc02015ac:	00004697          	auipc	a3,0x4
ffffffffc02015b0:	78c68693          	addi	a3,a3,1932 # ffffffffc0205d38 <commands+0xd58>
ffffffffc02015b4:	00004617          	auipc	a2,0x4
ffffffffc02015b8:	28c60613          	addi	a2,a2,652 # ffffffffc0205840 <commands+0x860>
ffffffffc02015bc:	07400593          	li	a1,116
ffffffffc02015c0:	00004517          	auipc	a0,0x4
ffffffffc02015c4:	67050513          	addi	a0,a0,1648 # ffffffffc0205c30 <commands+0xc50>
ffffffffc02015c8:	c0ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==9);
ffffffffc02015cc:	00004697          	auipc	a3,0x4
ffffffffc02015d0:	75c68693          	addi	a3,a3,1884 # ffffffffc0205d28 <commands+0xd48>
ffffffffc02015d4:	00004617          	auipc	a2,0x4
ffffffffc02015d8:	26c60613          	addi	a2,a2,620 # ffffffffc0205840 <commands+0x860>
ffffffffc02015dc:	07100593          	li	a1,113
ffffffffc02015e0:	00004517          	auipc	a0,0x4
ffffffffc02015e4:	65050513          	addi	a0,a0,1616 # ffffffffc0205c30 <commands+0xc50>
ffffffffc02015e8:	beffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==8);
ffffffffc02015ec:	00004697          	auipc	a3,0x4
ffffffffc02015f0:	72c68693          	addi	a3,a3,1836 # ffffffffc0205d18 <commands+0xd38>
ffffffffc02015f4:	00004617          	auipc	a2,0x4
ffffffffc02015f8:	24c60613          	addi	a2,a2,588 # ffffffffc0205840 <commands+0x860>
ffffffffc02015fc:	06e00593          	li	a1,110
ffffffffc0201600:	00004517          	auipc	a0,0x4
ffffffffc0201604:	63050513          	addi	a0,a0,1584 # ffffffffc0205c30 <commands+0xc50>
ffffffffc0201608:	bcffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==7);
ffffffffc020160c:	00004697          	auipc	a3,0x4
ffffffffc0201610:	6fc68693          	addi	a3,a3,1788 # ffffffffc0205d08 <commands+0xd28>
ffffffffc0201614:	00004617          	auipc	a2,0x4
ffffffffc0201618:	22c60613          	addi	a2,a2,556 # ffffffffc0205840 <commands+0x860>
ffffffffc020161c:	06b00593          	li	a1,107
ffffffffc0201620:	00004517          	auipc	a0,0x4
ffffffffc0201624:	61050513          	addi	a0,a0,1552 # ffffffffc0205c30 <commands+0xc50>
ffffffffc0201628:	baffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==6);
ffffffffc020162c:	00004697          	auipc	a3,0x4
ffffffffc0201630:	6cc68693          	addi	a3,a3,1740 # ffffffffc0205cf8 <commands+0xd18>
ffffffffc0201634:	00004617          	auipc	a2,0x4
ffffffffc0201638:	20c60613          	addi	a2,a2,524 # ffffffffc0205840 <commands+0x860>
ffffffffc020163c:	06800593          	li	a1,104
ffffffffc0201640:	00004517          	auipc	a0,0x4
ffffffffc0201644:	5f050513          	addi	a0,a0,1520 # ffffffffc0205c30 <commands+0xc50>
ffffffffc0201648:	b8ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==5);
ffffffffc020164c:	00004697          	auipc	a3,0x4
ffffffffc0201650:	69c68693          	addi	a3,a3,1692 # ffffffffc0205ce8 <commands+0xd08>
ffffffffc0201654:	00004617          	auipc	a2,0x4
ffffffffc0201658:	1ec60613          	addi	a2,a2,492 # ffffffffc0205840 <commands+0x860>
ffffffffc020165c:	06500593          	li	a1,101
ffffffffc0201660:	00004517          	auipc	a0,0x4
ffffffffc0201664:	5d050513          	addi	a0,a0,1488 # ffffffffc0205c30 <commands+0xc50>
ffffffffc0201668:	b6ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==5);
ffffffffc020166c:	00004697          	auipc	a3,0x4
ffffffffc0201670:	67c68693          	addi	a3,a3,1660 # ffffffffc0205ce8 <commands+0xd08>
ffffffffc0201674:	00004617          	auipc	a2,0x4
ffffffffc0201678:	1cc60613          	addi	a2,a2,460 # ffffffffc0205840 <commands+0x860>
ffffffffc020167c:	06200593          	li	a1,98
ffffffffc0201680:	00004517          	auipc	a0,0x4
ffffffffc0201684:	5b050513          	addi	a0,a0,1456 # ffffffffc0205c30 <commands+0xc50>
ffffffffc0201688:	b4ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==4);
ffffffffc020168c:	00004697          	auipc	a3,0x4
ffffffffc0201690:	59468693          	addi	a3,a3,1428 # ffffffffc0205c20 <commands+0xc40>
ffffffffc0201694:	00004617          	auipc	a2,0x4
ffffffffc0201698:	1ac60613          	addi	a2,a2,428 # ffffffffc0205840 <commands+0x860>
ffffffffc020169c:	05f00593          	li	a1,95
ffffffffc02016a0:	00004517          	auipc	a0,0x4
ffffffffc02016a4:	59050513          	addi	a0,a0,1424 # ffffffffc0205c30 <commands+0xc50>
ffffffffc02016a8:	b2ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==4);
ffffffffc02016ac:	00004697          	auipc	a3,0x4
ffffffffc02016b0:	57468693          	addi	a3,a3,1396 # ffffffffc0205c20 <commands+0xc40>
ffffffffc02016b4:	00004617          	auipc	a2,0x4
ffffffffc02016b8:	18c60613          	addi	a2,a2,396 # ffffffffc0205840 <commands+0x860>
ffffffffc02016bc:	05c00593          	li	a1,92
ffffffffc02016c0:	00004517          	auipc	a0,0x4
ffffffffc02016c4:	57050513          	addi	a0,a0,1392 # ffffffffc0205c30 <commands+0xc50>
ffffffffc02016c8:	b0ffe0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pgfault_num==4);
ffffffffc02016cc:	00004697          	auipc	a3,0x4
ffffffffc02016d0:	55468693          	addi	a3,a3,1364 # ffffffffc0205c20 <commands+0xc40>
ffffffffc02016d4:	00004617          	auipc	a2,0x4
ffffffffc02016d8:	16c60613          	addi	a2,a2,364 # ffffffffc0205840 <commands+0x860>
ffffffffc02016dc:	05900593          	li	a1,89
ffffffffc02016e0:	00004517          	auipc	a0,0x4
ffffffffc02016e4:	55050513          	addi	a0,a0,1360 # ffffffffc0205c30 <commands+0xc50>
ffffffffc02016e8:	aeffe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02016ec <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02016ec:	7518                	ld	a4,40(a0)
{
ffffffffc02016ee:	1141                	addi	sp,sp,-16
ffffffffc02016f0:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02016f2:	c731                	beqz	a4,ffffffffc020173e <_fifo_swap_out_victim+0x52>
     assert(in_tick==0);
ffffffffc02016f4:	e60d                	bnez	a2,ffffffffc020171e <_fifo_swap_out_victim+0x32>
    return listelm->prev;
ffffffffc02016f6:	631c                	ld	a5,0(a4)
    if(entry != head) {
ffffffffc02016f8:	00f70d63          	beq	a4,a5,ffffffffc0201712 <_fifo_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02016fc:	6394                	ld	a3,0(a5)
ffffffffc02016fe:	6798                	ld	a4,8(a5)
}
ffffffffc0201700:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201702:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0201706:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201708:	e314                	sd	a3,0(a4)
ffffffffc020170a:	e19c                	sd	a5,0(a1)
}
ffffffffc020170c:	4501                	li	a0,0
ffffffffc020170e:	0141                	addi	sp,sp,16
ffffffffc0201710:	8082                	ret
ffffffffc0201712:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc0201714:	0005b023          	sd	zero,0(a1)
}
ffffffffc0201718:	4501                	li	a0,0
ffffffffc020171a:	0141                	addi	sp,sp,16
ffffffffc020171c:	8082                	ret
     assert(in_tick==0);
ffffffffc020171e:	00004697          	auipc	a3,0x4
ffffffffc0201722:	69268693          	addi	a3,a3,1682 # ffffffffc0205db0 <commands+0xdd0>
ffffffffc0201726:	00004617          	auipc	a2,0x4
ffffffffc020172a:	11a60613          	addi	a2,a2,282 # ffffffffc0205840 <commands+0x860>
ffffffffc020172e:	04200593          	li	a1,66
ffffffffc0201732:	00004517          	auipc	a0,0x4
ffffffffc0201736:	4fe50513          	addi	a0,a0,1278 # ffffffffc0205c30 <commands+0xc50>
ffffffffc020173a:	a9dfe0ef          	jal	ra,ffffffffc02001d6 <__panic>
         assert(head != NULL);
ffffffffc020173e:	00004697          	auipc	a3,0x4
ffffffffc0201742:	66268693          	addi	a3,a3,1634 # ffffffffc0205da0 <commands+0xdc0>
ffffffffc0201746:	00004617          	auipc	a2,0x4
ffffffffc020174a:	0fa60613          	addi	a2,a2,250 # ffffffffc0205840 <commands+0x860>
ffffffffc020174e:	04100593          	li	a1,65
ffffffffc0201752:	00004517          	auipc	a0,0x4
ffffffffc0201756:	4de50513          	addi	a0,a0,1246 # ffffffffc0205c30 <commands+0xc50>
ffffffffc020175a:	a7dfe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc020175e <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020175e:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201762:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0201764:	cb09                	beqz	a4,ffffffffc0201776 <_fifo_map_swappable+0x18>
ffffffffc0201766:	cb81                	beqz	a5,ffffffffc0201776 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm, listelm->next);
ffffffffc0201768:	6794                	ld	a3,8(a5)
}
ffffffffc020176a:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc020176c:	e298                	sd	a4,0(a3)
ffffffffc020176e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201770:	fa14                	sd	a3,48(a2)
    elm->prev = prev;
ffffffffc0201772:	f61c                	sd	a5,40(a2)
ffffffffc0201774:	8082                	ret
{
ffffffffc0201776:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0201778:	00004697          	auipc	a3,0x4
ffffffffc020177c:	60868693          	addi	a3,a3,1544 # ffffffffc0205d80 <commands+0xda0>
ffffffffc0201780:	00004617          	auipc	a2,0x4
ffffffffc0201784:	0c060613          	addi	a2,a2,192 # ffffffffc0205840 <commands+0x860>
ffffffffc0201788:	03200593          	li	a1,50
ffffffffc020178c:	00004517          	auipc	a0,0x4
ffffffffc0201790:	4a450513          	addi	a0,a0,1188 # ffffffffc0205c30 <commands+0xc50>
{
ffffffffc0201794:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0201796:	a41fe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc020179a <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc020179a:	c125                	beqz	a0,ffffffffc02017fa <slob_free+0x60>
		return;

	if (size)
ffffffffc020179c:	e1a5                	bnez	a1,ffffffffc02017fc <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020179e:	100027f3          	csrr	a5,sstatus
ffffffffc02017a2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02017a4:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017a6:	e3bd                	bnez	a5,ffffffffc020180c <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017a8:	00009797          	auipc	a5,0x9
ffffffffc02017ac:	8a878793          	addi	a5,a5,-1880 # ffffffffc020a050 <slobfree>
ffffffffc02017b0:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017b2:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017b4:	00a7fa63          	bleu	a0,a5,ffffffffc02017c8 <slob_free+0x2e>
ffffffffc02017b8:	00e56c63          	bltu	a0,a4,ffffffffc02017d0 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017bc:	00e7fa63          	bleu	a4,a5,ffffffffc02017d0 <slob_free+0x36>
    return 0;
ffffffffc02017c0:	87ba                	mv	a5,a4
ffffffffc02017c2:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017c4:	fea7eae3          	bltu	a5,a0,ffffffffc02017b8 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017c8:	fee7ece3          	bltu	a5,a4,ffffffffc02017c0 <slob_free+0x26>
ffffffffc02017cc:	fee57ae3          	bleu	a4,a0,ffffffffc02017c0 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02017d0:	4110                	lw	a2,0(a0)
ffffffffc02017d2:	00461693          	slli	a3,a2,0x4
ffffffffc02017d6:	96aa                	add	a3,a3,a0
ffffffffc02017d8:	08d70b63          	beq	a4,a3,ffffffffc020186e <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02017dc:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02017de:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02017e0:	00469713          	slli	a4,a3,0x4
ffffffffc02017e4:	973e                	add	a4,a4,a5
ffffffffc02017e6:	08e50f63          	beq	a0,a4,ffffffffc0201884 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02017ea:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02017ec:	00009717          	auipc	a4,0x9
ffffffffc02017f0:	86f73223          	sd	a5,-1948(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc02017f4:	c199                	beqz	a1,ffffffffc02017fa <slob_free+0x60>
        intr_enable();
ffffffffc02017f6:	ddffe06f          	j	ffffffffc02005d4 <intr_enable>
ffffffffc02017fa:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02017fc:	05bd                	addi	a1,a1,15
ffffffffc02017fe:	8191                	srli	a1,a1,0x4
ffffffffc0201800:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201802:	100027f3          	csrr	a5,sstatus
ffffffffc0201806:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201808:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020180a:	dfd9                	beqz	a5,ffffffffc02017a8 <slob_free+0xe>
{
ffffffffc020180c:	1101                	addi	sp,sp,-32
ffffffffc020180e:	e42a                	sd	a0,8(sp)
ffffffffc0201810:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201812:	dc9fe0ef          	jal	ra,ffffffffc02005da <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201816:	00009797          	auipc	a5,0x9
ffffffffc020181a:	83a78793          	addi	a5,a5,-1990 # ffffffffc020a050 <slobfree>
ffffffffc020181e:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201820:	6522                	ld	a0,8(sp)
ffffffffc0201822:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201824:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201826:	00a7fa63          	bleu	a0,a5,ffffffffc020183a <slob_free+0xa0>
ffffffffc020182a:	00e56c63          	bltu	a0,a4,ffffffffc0201842 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020182e:	00e7fa63          	bleu	a4,a5,ffffffffc0201842 <slob_free+0xa8>
    return 0;
ffffffffc0201832:	87ba                	mv	a5,a4
ffffffffc0201834:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201836:	fea7eae3          	bltu	a5,a0,ffffffffc020182a <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020183a:	fee7ece3          	bltu	a5,a4,ffffffffc0201832 <slob_free+0x98>
ffffffffc020183e:	fee57ae3          	bleu	a4,a0,ffffffffc0201832 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201842:	4110                	lw	a2,0(a0)
ffffffffc0201844:	00461693          	slli	a3,a2,0x4
ffffffffc0201848:	96aa                	add	a3,a3,a0
ffffffffc020184a:	04d70763          	beq	a4,a3,ffffffffc0201898 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc020184e:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201850:	4394                	lw	a3,0(a5)
ffffffffc0201852:	00469713          	slli	a4,a3,0x4
ffffffffc0201856:	973e                	add	a4,a4,a5
ffffffffc0201858:	04e50663          	beq	a0,a4,ffffffffc02018a4 <slob_free+0x10a>
		cur->next = b;
ffffffffc020185c:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc020185e:	00008717          	auipc	a4,0x8
ffffffffc0201862:	7ef73923          	sd	a5,2034(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0201866:	e58d                	bnez	a1,ffffffffc0201890 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201868:	60e2                	ld	ra,24(sp)
ffffffffc020186a:	6105                	addi	sp,sp,32
ffffffffc020186c:	8082                	ret
		b->units += cur->next->units;
ffffffffc020186e:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201870:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201872:	9e35                	addw	a2,a2,a3
ffffffffc0201874:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201876:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201878:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020187a:	00469713          	slli	a4,a3,0x4
ffffffffc020187e:	973e                	add	a4,a4,a5
ffffffffc0201880:	f6e515e3          	bne	a0,a4,ffffffffc02017ea <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201884:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201886:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201888:	9eb9                	addw	a3,a3,a4
ffffffffc020188a:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc020188c:	e790                	sd	a2,8(a5)
ffffffffc020188e:	bfb9                	j	ffffffffc02017ec <slob_free+0x52>
}
ffffffffc0201890:	60e2                	ld	ra,24(sp)
ffffffffc0201892:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201894:	d41fe06f          	j	ffffffffc02005d4 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201898:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020189a:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc020189c:	9e35                	addw	a2,a2,a3
ffffffffc020189e:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc02018a0:	e518                	sd	a4,8(a0)
ffffffffc02018a2:	b77d                	j	ffffffffc0201850 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc02018a4:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02018a6:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02018a8:	9eb9                	addw	a3,a3,a4
ffffffffc02018aa:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02018ac:	e790                	sd	a2,8(a5)
ffffffffc02018ae:	bf45                	j	ffffffffc020185e <slob_free+0xc4>

ffffffffc02018b0 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02018b0:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02018b2:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02018b4:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02018b8:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02018ba:	7fa010ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
  if(!page)
ffffffffc02018be:	c139                	beqz	a0,ffffffffc0201904 <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc02018c0:	00014797          	auipc	a5,0x14
ffffffffc02018c4:	d2878793          	addi	a5,a5,-728 # ffffffffc02155e8 <pages>
ffffffffc02018c8:	6394                	ld	a3,0(a5)
ffffffffc02018ca:	00005797          	auipc	a5,0x5
ffffffffc02018ce:	6a678793          	addi	a5,a5,1702 # ffffffffc0206f70 <nbase>
    return KADDR(page2pa(page));
ffffffffc02018d2:	00014717          	auipc	a4,0x14
ffffffffc02018d6:	bd670713          	addi	a4,a4,-1066 # ffffffffc02154a8 <npage>
    return page - pages + nbase;
ffffffffc02018da:	40d506b3          	sub	a3,a0,a3
ffffffffc02018de:	6388                	ld	a0,0(a5)
ffffffffc02018e0:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02018e2:	57fd                	li	a5,-1
ffffffffc02018e4:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc02018e6:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc02018e8:	83b1                	srli	a5,a5,0xc
ffffffffc02018ea:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02018ec:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02018ee:	00e7ff63          	bleu	a4,a5,ffffffffc020190c <__slob_get_free_pages.isra.0+0x5c>
ffffffffc02018f2:	00014797          	auipc	a5,0x14
ffffffffc02018f6:	ce678793          	addi	a5,a5,-794 # ffffffffc02155d8 <va_pa_offset>
ffffffffc02018fa:	6388                	ld	a0,0(a5)
}
ffffffffc02018fc:	60a2                	ld	ra,8(sp)
ffffffffc02018fe:	9536                	add	a0,a0,a3
ffffffffc0201900:	0141                	addi	sp,sp,16
ffffffffc0201902:	8082                	ret
ffffffffc0201904:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201906:	4501                	li	a0,0
}
ffffffffc0201908:	0141                	addi	sp,sp,16
ffffffffc020190a:	8082                	ret
ffffffffc020190c:	00004617          	auipc	a2,0x4
ffffffffc0201910:	25460613          	addi	a2,a2,596 # ffffffffc0205b60 <commands+0xb80>
ffffffffc0201914:	06900593          	li	a1,105
ffffffffc0201918:	00004517          	auipc	a0,0x4
ffffffffc020191c:	23850513          	addi	a0,a0,568 # ffffffffc0205b50 <commands+0xb70>
ffffffffc0201920:	8b7fe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0201924 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201924:	7179                	addi	sp,sp,-48
ffffffffc0201926:	f406                	sd	ra,40(sp)
ffffffffc0201928:	f022                	sd	s0,32(sp)
ffffffffc020192a:	ec26                	sd	s1,24(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020192c:	01050713          	addi	a4,a0,16
ffffffffc0201930:	6785                	lui	a5,0x1
ffffffffc0201932:	0cf77b63          	bleu	a5,a4,ffffffffc0201a08 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201936:	00f50413          	addi	s0,a0,15
ffffffffc020193a:	8011                	srli	s0,s0,0x4
ffffffffc020193c:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020193e:	10002673          	csrr	a2,sstatus
ffffffffc0201942:	8a09                	andi	a2,a2,2
ffffffffc0201944:	ea5d                	bnez	a2,ffffffffc02019fa <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201946:	00008497          	auipc	s1,0x8
ffffffffc020194a:	70a48493          	addi	s1,s1,1802 # ffffffffc020a050 <slobfree>
ffffffffc020194e:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201950:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201952:	4398                	lw	a4,0(a5)
ffffffffc0201954:	0a875763          	ble	s0,a4,ffffffffc0201a02 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201958:	00f68a63          	beq	a3,a5,ffffffffc020196c <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020195c:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020195e:	4118                	lw	a4,0(a0)
ffffffffc0201960:	02875763          	ble	s0,a4,ffffffffc020198e <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201964:	6094                	ld	a3,0(s1)
ffffffffc0201966:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201968:	fef69ae3          	bne	a3,a5,ffffffffc020195c <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc020196c:	ea39                	bnez	a2,ffffffffc02019c2 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc020196e:	4501                	li	a0,0
ffffffffc0201970:	f41ff0ef          	jal	ra,ffffffffc02018b0 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201974:	cd29                	beqz	a0,ffffffffc02019ce <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201976:	6585                	lui	a1,0x1
ffffffffc0201978:	e23ff0ef          	jal	ra,ffffffffc020179a <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020197c:	10002673          	csrr	a2,sstatus
ffffffffc0201980:	8a09                	andi	a2,a2,2
ffffffffc0201982:	ea1d                	bnez	a2,ffffffffc02019b8 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201984:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201986:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201988:	4118                	lw	a4,0(a0)
ffffffffc020198a:	fc874de3          	blt	a4,s0,ffffffffc0201964 <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc020198e:	04e40663          	beq	s0,a4,ffffffffc02019da <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201992:	00441693          	slli	a3,s0,0x4
ffffffffc0201996:	96aa                	add	a3,a3,a0
ffffffffc0201998:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc020199a:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc020199c:	9f01                	subw	a4,a4,s0
ffffffffc020199e:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02019a0:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02019a2:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc02019a4:	00008717          	auipc	a4,0x8
ffffffffc02019a8:	6af73623          	sd	a5,1708(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc02019ac:	ee15                	bnez	a2,ffffffffc02019e8 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc02019ae:	70a2                	ld	ra,40(sp)
ffffffffc02019b0:	7402                	ld	s0,32(sp)
ffffffffc02019b2:	64e2                	ld	s1,24(sp)
ffffffffc02019b4:	6145                	addi	sp,sp,48
ffffffffc02019b6:	8082                	ret
        intr_disable();
ffffffffc02019b8:	c23fe0ef          	jal	ra,ffffffffc02005da <intr_disable>
ffffffffc02019bc:	4605                	li	a2,1
			cur = slobfree;
ffffffffc02019be:	609c                	ld	a5,0(s1)
ffffffffc02019c0:	b7d9                	j	ffffffffc0201986 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc02019c2:	c13fe0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02019c6:	4501                	li	a0,0
ffffffffc02019c8:	ee9ff0ef          	jal	ra,ffffffffc02018b0 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02019cc:	f54d                	bnez	a0,ffffffffc0201976 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc02019ce:	70a2                	ld	ra,40(sp)
ffffffffc02019d0:	7402                	ld	s0,32(sp)
ffffffffc02019d2:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc02019d4:	4501                	li	a0,0
}
ffffffffc02019d6:	6145                	addi	sp,sp,48
ffffffffc02019d8:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02019da:	6518                	ld	a4,8(a0)
ffffffffc02019dc:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc02019de:	00008717          	auipc	a4,0x8
ffffffffc02019e2:	66f73923          	sd	a5,1650(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc02019e6:	d661                	beqz	a2,ffffffffc02019ae <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc02019e8:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02019ea:	bebfe0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
}
ffffffffc02019ee:	70a2                	ld	ra,40(sp)
ffffffffc02019f0:	7402                	ld	s0,32(sp)
ffffffffc02019f2:	6522                	ld	a0,8(sp)
ffffffffc02019f4:	64e2                	ld	s1,24(sp)
ffffffffc02019f6:	6145                	addi	sp,sp,48
ffffffffc02019f8:	8082                	ret
        intr_disable();
ffffffffc02019fa:	be1fe0ef          	jal	ra,ffffffffc02005da <intr_disable>
ffffffffc02019fe:	4605                	li	a2,1
ffffffffc0201a00:	b799                	j	ffffffffc0201946 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a02:	853e                	mv	a0,a5
ffffffffc0201a04:	87b6                	mv	a5,a3
ffffffffc0201a06:	b761                	j	ffffffffc020198e <slob_alloc.isra.1.constprop.3+0x6a>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201a08:	00004697          	auipc	a3,0x4
ffffffffc0201a0c:	41868693          	addi	a3,a3,1048 # ffffffffc0205e20 <commands+0xe40>
ffffffffc0201a10:	00004617          	auipc	a2,0x4
ffffffffc0201a14:	e3060613          	addi	a2,a2,-464 # ffffffffc0205840 <commands+0x860>
ffffffffc0201a18:	06300593          	li	a1,99
ffffffffc0201a1c:	00004517          	auipc	a0,0x4
ffffffffc0201a20:	42450513          	addi	a0,a0,1060 # ffffffffc0205e40 <commands+0xe60>
ffffffffc0201a24:	fb2fe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0201a28 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201a28:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201a2a:	00004517          	auipc	a0,0x4
ffffffffc0201a2e:	42e50513          	addi	a0,a0,1070 # ffffffffc0205e58 <commands+0xe78>
kmalloc_init(void) {
ffffffffc0201a32:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201a34:	e9cfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201a38:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201a3a:	00004517          	auipc	a0,0x4
ffffffffc0201a3e:	3c650513          	addi	a0,a0,966 # ffffffffc0205e00 <commands+0xe20>
}
ffffffffc0201a42:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201a44:	e8cfe06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0201a48 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201a48:	1101                	addi	sp,sp,-32
ffffffffc0201a4a:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a4c:	6905                	lui	s2,0x1
{
ffffffffc0201a4e:	e822                	sd	s0,16(sp)
ffffffffc0201a50:	ec06                	sd	ra,24(sp)
ffffffffc0201a52:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a54:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc0201a58:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201a5a:	04a7fc63          	bleu	a0,a5,ffffffffc0201ab2 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201a5e:	4561                	li	a0,24
ffffffffc0201a60:	ec5ff0ef          	jal	ra,ffffffffc0201924 <slob_alloc.isra.1.constprop.3>
ffffffffc0201a64:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201a66:	cd21                	beqz	a0,ffffffffc0201abe <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201a68:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201a6c:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201a6e:	00f95763          	ble	a5,s2,ffffffffc0201a7c <kmalloc+0x34>
ffffffffc0201a72:	6705                	lui	a4,0x1
ffffffffc0201a74:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201a76:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201a78:	fef74ee3          	blt	a4,a5,ffffffffc0201a74 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201a7c:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201a7e:	e33ff0ef          	jal	ra,ffffffffc02018b0 <__slob_get_free_pages.isra.0>
ffffffffc0201a82:	e488                	sd	a0,8(s1)
ffffffffc0201a84:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201a86:	c935                	beqz	a0,ffffffffc0201afa <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a88:	100027f3          	csrr	a5,sstatus
ffffffffc0201a8c:	8b89                	andi	a5,a5,2
ffffffffc0201a8e:	e3a1                	bnez	a5,ffffffffc0201ace <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201a90:	00014797          	auipc	a5,0x14
ffffffffc0201a94:	9f878793          	addi	a5,a5,-1544 # ffffffffc0215488 <bigblocks>
ffffffffc0201a98:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201a9a:	00014717          	auipc	a4,0x14
ffffffffc0201a9e:	9e973723          	sd	s1,-1554(a4) # ffffffffc0215488 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201aa2:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201aa4:	8522                	mv	a0,s0
ffffffffc0201aa6:	60e2                	ld	ra,24(sp)
ffffffffc0201aa8:	6442                	ld	s0,16(sp)
ffffffffc0201aaa:	64a2                	ld	s1,8(sp)
ffffffffc0201aac:	6902                	ld	s2,0(sp)
ffffffffc0201aae:	6105                	addi	sp,sp,32
ffffffffc0201ab0:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201ab2:	0541                	addi	a0,a0,16
ffffffffc0201ab4:	e71ff0ef          	jal	ra,ffffffffc0201924 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201ab8:	01050413          	addi	s0,a0,16
ffffffffc0201abc:	f565                	bnez	a0,ffffffffc0201aa4 <kmalloc+0x5c>
ffffffffc0201abe:	4401                	li	s0,0
}
ffffffffc0201ac0:	8522                	mv	a0,s0
ffffffffc0201ac2:	60e2                	ld	ra,24(sp)
ffffffffc0201ac4:	6442                	ld	s0,16(sp)
ffffffffc0201ac6:	64a2                	ld	s1,8(sp)
ffffffffc0201ac8:	6902                	ld	s2,0(sp)
ffffffffc0201aca:	6105                	addi	sp,sp,32
ffffffffc0201acc:	8082                	ret
        intr_disable();
ffffffffc0201ace:	b0dfe0ef          	jal	ra,ffffffffc02005da <intr_disable>
		bb->next = bigblocks;
ffffffffc0201ad2:	00014797          	auipc	a5,0x14
ffffffffc0201ad6:	9b678793          	addi	a5,a5,-1610 # ffffffffc0215488 <bigblocks>
ffffffffc0201ada:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201adc:	00014717          	auipc	a4,0x14
ffffffffc0201ae0:	9a973623          	sd	s1,-1620(a4) # ffffffffc0215488 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201ae4:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201ae6:	aeffe0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
ffffffffc0201aea:	6480                	ld	s0,8(s1)
}
ffffffffc0201aec:	60e2                	ld	ra,24(sp)
ffffffffc0201aee:	64a2                	ld	s1,8(sp)
ffffffffc0201af0:	8522                	mv	a0,s0
ffffffffc0201af2:	6442                	ld	s0,16(sp)
ffffffffc0201af4:	6902                	ld	s2,0(sp)
ffffffffc0201af6:	6105                	addi	sp,sp,32
ffffffffc0201af8:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201afa:	45e1                	li	a1,24
ffffffffc0201afc:	8526                	mv	a0,s1
ffffffffc0201afe:	c9dff0ef          	jal	ra,ffffffffc020179a <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201b02:	b74d                	j	ffffffffc0201aa4 <kmalloc+0x5c>

ffffffffc0201b04 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201b04:	c175                	beqz	a0,ffffffffc0201be8 <kfree+0xe4>
{
ffffffffc0201b06:	1101                	addi	sp,sp,-32
ffffffffc0201b08:	e426                	sd	s1,8(sp)
ffffffffc0201b0a:	ec06                	sd	ra,24(sp)
ffffffffc0201b0c:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201b0e:	03451793          	slli	a5,a0,0x34
ffffffffc0201b12:	84aa                	mv	s1,a0
ffffffffc0201b14:	eb8d                	bnez	a5,ffffffffc0201b46 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b16:	100027f3          	csrr	a5,sstatus
ffffffffc0201b1a:	8b89                	andi	a5,a5,2
ffffffffc0201b1c:	efc9                	bnez	a5,ffffffffc0201bb6 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b1e:	00014797          	auipc	a5,0x14
ffffffffc0201b22:	96a78793          	addi	a5,a5,-1686 # ffffffffc0215488 <bigblocks>
ffffffffc0201b26:	6394                	ld	a3,0(a5)
ffffffffc0201b28:	ce99                	beqz	a3,ffffffffc0201b46 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201b2a:	669c                	ld	a5,8(a3)
ffffffffc0201b2c:	6a80                	ld	s0,16(a3)
ffffffffc0201b2e:	0af50e63          	beq	a0,a5,ffffffffc0201bea <kfree+0xe6>
    return 0;
ffffffffc0201b32:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b34:	c801                	beqz	s0,ffffffffc0201b44 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201b36:	6418                	ld	a4,8(s0)
ffffffffc0201b38:	681c                	ld	a5,16(s0)
ffffffffc0201b3a:	00970f63          	beq	a4,s1,ffffffffc0201b58 <kfree+0x54>
ffffffffc0201b3e:	86a2                	mv	a3,s0
ffffffffc0201b40:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b42:	f875                	bnez	s0,ffffffffc0201b36 <kfree+0x32>
    if (flag) {
ffffffffc0201b44:	e659                	bnez	a2,ffffffffc0201bd2 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201b46:	6442                	ld	s0,16(sp)
ffffffffc0201b48:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b4a:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201b4e:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b50:	4581                	li	a1,0
}
ffffffffc0201b52:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b54:	c47ff06f          	j	ffffffffc020179a <slob_free>
				*last = bb->next;
ffffffffc0201b58:	ea9c                	sd	a5,16(a3)
ffffffffc0201b5a:	e641                	bnez	a2,ffffffffc0201be2 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201b5c:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201b60:	4018                	lw	a4,0(s0)
ffffffffc0201b62:	08f4ea63          	bltu	s1,a5,ffffffffc0201bf6 <kfree+0xf2>
ffffffffc0201b66:	00014797          	auipc	a5,0x14
ffffffffc0201b6a:	a7278793          	addi	a5,a5,-1422 # ffffffffc02155d8 <va_pa_offset>
ffffffffc0201b6e:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201b70:	00014797          	auipc	a5,0x14
ffffffffc0201b74:	93878793          	addi	a5,a5,-1736 # ffffffffc02154a8 <npage>
ffffffffc0201b78:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201b7a:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201b7c:	80b1                	srli	s1,s1,0xc
ffffffffc0201b7e:	08f4f963          	bleu	a5,s1,ffffffffc0201c10 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b82:	00005797          	auipc	a5,0x5
ffffffffc0201b86:	3ee78793          	addi	a5,a5,1006 # ffffffffc0206f70 <nbase>
ffffffffc0201b8a:	639c                	ld	a5,0(a5)
ffffffffc0201b8c:	00014697          	auipc	a3,0x14
ffffffffc0201b90:	a5c68693          	addi	a3,a3,-1444 # ffffffffc02155e8 <pages>
ffffffffc0201b94:	6288                	ld	a0,0(a3)
ffffffffc0201b96:	8c9d                	sub	s1,s1,a5
ffffffffc0201b98:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201b9a:	4585                	li	a1,1
ffffffffc0201b9c:	9526                	add	a0,a0,s1
ffffffffc0201b9e:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201ba2:	59a010ef          	jal	ra,ffffffffc020313c <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ba6:	8522                	mv	a0,s0
}
ffffffffc0201ba8:	6442                	ld	s0,16(sp)
ffffffffc0201baa:	60e2                	ld	ra,24(sp)
ffffffffc0201bac:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201bae:	45e1                	li	a1,24
}
ffffffffc0201bb0:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201bb2:	be9ff06f          	j	ffffffffc020179a <slob_free>
        intr_disable();
ffffffffc0201bb6:	a25fe0ef          	jal	ra,ffffffffc02005da <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201bba:	00014797          	auipc	a5,0x14
ffffffffc0201bbe:	8ce78793          	addi	a5,a5,-1842 # ffffffffc0215488 <bigblocks>
ffffffffc0201bc2:	6394                	ld	a3,0(a5)
ffffffffc0201bc4:	c699                	beqz	a3,ffffffffc0201bd2 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201bc6:	669c                	ld	a5,8(a3)
ffffffffc0201bc8:	6a80                	ld	s0,16(a3)
ffffffffc0201bca:	00f48763          	beq	s1,a5,ffffffffc0201bd8 <kfree+0xd4>
        return 1;
ffffffffc0201bce:	4605                	li	a2,1
ffffffffc0201bd0:	b795                	j	ffffffffc0201b34 <kfree+0x30>
        intr_enable();
ffffffffc0201bd2:	a03fe0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
ffffffffc0201bd6:	bf85                	j	ffffffffc0201b46 <kfree+0x42>
				*last = bb->next;
ffffffffc0201bd8:	00014797          	auipc	a5,0x14
ffffffffc0201bdc:	8a87b823          	sd	s0,-1872(a5) # ffffffffc0215488 <bigblocks>
ffffffffc0201be0:	8436                	mv	s0,a3
ffffffffc0201be2:	9f3fe0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
ffffffffc0201be6:	bf9d                	j	ffffffffc0201b5c <kfree+0x58>
ffffffffc0201be8:	8082                	ret
ffffffffc0201bea:	00014797          	auipc	a5,0x14
ffffffffc0201bee:	8887bf23          	sd	s0,-1890(a5) # ffffffffc0215488 <bigblocks>
ffffffffc0201bf2:	8436                	mv	s0,a3
ffffffffc0201bf4:	b7a5                	j	ffffffffc0201b5c <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201bf6:	86a6                	mv	a3,s1
ffffffffc0201bf8:	00004617          	auipc	a2,0x4
ffffffffc0201bfc:	1e060613          	addi	a2,a2,480 # ffffffffc0205dd8 <commands+0xdf8>
ffffffffc0201c00:	06e00593          	li	a1,110
ffffffffc0201c04:	00004517          	auipc	a0,0x4
ffffffffc0201c08:	f4c50513          	addi	a0,a0,-180 # ffffffffc0205b50 <commands+0xb70>
ffffffffc0201c0c:	dcafe0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201c10:	00004617          	auipc	a2,0x4
ffffffffc0201c14:	f2060613          	addi	a2,a2,-224 # ffffffffc0205b30 <commands+0xb50>
ffffffffc0201c18:	06200593          	li	a1,98
ffffffffc0201c1c:	00004517          	auipc	a0,0x4
ffffffffc0201c20:	f3450513          	addi	a0,a0,-204 # ffffffffc0205b50 <commands+0xb70>
ffffffffc0201c24:	db2fe0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0201c28 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0201c28:	7135                	addi	sp,sp,-160
ffffffffc0201c2a:	ed06                	sd	ra,152(sp)
ffffffffc0201c2c:	e922                	sd	s0,144(sp)
ffffffffc0201c2e:	e526                	sd	s1,136(sp)
ffffffffc0201c30:	e14a                	sd	s2,128(sp)
ffffffffc0201c32:	fcce                	sd	s3,120(sp)
ffffffffc0201c34:	f8d2                	sd	s4,112(sp)
ffffffffc0201c36:	f4d6                	sd	s5,104(sp)
ffffffffc0201c38:	f0da                	sd	s6,96(sp)
ffffffffc0201c3a:	ecde                	sd	s7,88(sp)
ffffffffc0201c3c:	e8e2                	sd	s8,80(sp)
ffffffffc0201c3e:	e4e6                	sd	s9,72(sp)
ffffffffc0201c40:	e0ea                	sd	s10,64(sp)
ffffffffc0201c42:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0201c44:	406020ef          	jal	ra,ffffffffc020404a <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0201c48:	00014797          	auipc	a5,0x14
ffffffffc0201c4c:	93078793          	addi	a5,a5,-1744 # ffffffffc0215578 <max_swap_offset>
ffffffffc0201c50:	6394                	ld	a3,0(a5)
ffffffffc0201c52:	010007b7          	lui	a5,0x1000
ffffffffc0201c56:	17e1                	addi	a5,a5,-8
ffffffffc0201c58:	ff968713          	addi	a4,a3,-7
ffffffffc0201c5c:	4ae7e863          	bltu	a5,a4,ffffffffc020210c <swap_init+0x4e4>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0201c60:	00008797          	auipc	a5,0x8
ffffffffc0201c64:	3a078793          	addi	a5,a5,928 # ffffffffc020a000 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0201c68:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0201c6a:	00014697          	auipc	a3,0x14
ffffffffc0201c6e:	82f6b323          	sd	a5,-2010(a3) # ffffffffc0215490 <sm>
     int r = sm->init();
ffffffffc0201c72:	9702                	jalr	a4
ffffffffc0201c74:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0201c76:	c10d                	beqz	a0,ffffffffc0201c98 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201c78:	60ea                	ld	ra,152(sp)
ffffffffc0201c7a:	644a                	ld	s0,144(sp)
ffffffffc0201c7c:	8556                	mv	a0,s5
ffffffffc0201c7e:	64aa                	ld	s1,136(sp)
ffffffffc0201c80:	690a                	ld	s2,128(sp)
ffffffffc0201c82:	79e6                	ld	s3,120(sp)
ffffffffc0201c84:	7a46                	ld	s4,112(sp)
ffffffffc0201c86:	7aa6                	ld	s5,104(sp)
ffffffffc0201c88:	7b06                	ld	s6,96(sp)
ffffffffc0201c8a:	6be6                	ld	s7,88(sp)
ffffffffc0201c8c:	6c46                	ld	s8,80(sp)
ffffffffc0201c8e:	6ca6                	ld	s9,72(sp)
ffffffffc0201c90:	6d06                	ld	s10,64(sp)
ffffffffc0201c92:	7de2                	ld	s11,56(sp)
ffffffffc0201c94:	610d                	addi	sp,sp,160
ffffffffc0201c96:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201c98:	00013797          	auipc	a5,0x13
ffffffffc0201c9c:	7f878793          	addi	a5,a5,2040 # ffffffffc0215490 <sm>
ffffffffc0201ca0:	639c                	ld	a5,0(a5)
ffffffffc0201ca2:	00004517          	auipc	a0,0x4
ffffffffc0201ca6:	24e50513          	addi	a0,a0,590 # ffffffffc0205ef0 <commands+0xf10>
    return listelm->next;
ffffffffc0201caa:	00014417          	auipc	s0,0x14
ffffffffc0201cae:	90e40413          	addi	s0,s0,-1778 # ffffffffc02155b8 <free_area>
ffffffffc0201cb2:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0201cb4:	4785                	li	a5,1
ffffffffc0201cb6:	00013717          	auipc	a4,0x13
ffffffffc0201cba:	7ef72123          	sw	a5,2018(a4) # ffffffffc0215498 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201cbe:	c12fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0201cc2:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201cc4:	36878863          	beq	a5,s0,ffffffffc0202034 <swap_init+0x40c>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201cc8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201ccc:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201cce:	8b05                	andi	a4,a4,1
ffffffffc0201cd0:	36070663          	beqz	a4,ffffffffc020203c <swap_init+0x414>
     int ret, count = 0, total = 0, i;
ffffffffc0201cd4:	4481                	li	s1,0
ffffffffc0201cd6:	4901                	li	s2,0
ffffffffc0201cd8:	a031                	j	ffffffffc0201ce4 <swap_init+0xbc>
ffffffffc0201cda:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0201cde:	8b09                	andi	a4,a4,2
ffffffffc0201ce0:	34070e63          	beqz	a4,ffffffffc020203c <swap_init+0x414>
        count ++, total += p->property;
ffffffffc0201ce4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201ce8:	679c                	ld	a5,8(a5)
ffffffffc0201cea:	2905                	addiw	s2,s2,1
ffffffffc0201cec:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201cee:	fe8796e3          	bne	a5,s0,ffffffffc0201cda <swap_init+0xb2>
ffffffffc0201cf2:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0201cf4:	48e010ef          	jal	ra,ffffffffc0203182 <nr_free_pages>
ffffffffc0201cf8:	69351263          	bne	a0,s3,ffffffffc020237c <swap_init+0x754>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0201cfc:	8626                	mv	a2,s1
ffffffffc0201cfe:	85ca                	mv	a1,s2
ffffffffc0201d00:	00004517          	auipc	a0,0x4
ffffffffc0201d04:	23850513          	addi	a0,a0,568 # ffffffffc0205f38 <commands+0xf58>
ffffffffc0201d08:	bc8fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201d0c:	eb7fe0ef          	jal	ra,ffffffffc0200bc2 <mm_create>
ffffffffc0201d10:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0201d12:	60050563          	beqz	a0,ffffffffc020231c <swap_init+0x6f4>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0201d16:	00013797          	auipc	a5,0x13
ffffffffc0201d1a:	7c278793          	addi	a5,a5,1986 # ffffffffc02154d8 <check_mm_struct>
ffffffffc0201d1e:	639c                	ld	a5,0(a5)
ffffffffc0201d20:	60079e63          	bnez	a5,ffffffffc020233c <swap_init+0x714>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201d24:	00013797          	auipc	a5,0x13
ffffffffc0201d28:	77c78793          	addi	a5,a5,1916 # ffffffffc02154a0 <boot_pgdir>
ffffffffc0201d2c:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0201d30:	00013797          	auipc	a5,0x13
ffffffffc0201d34:	7aa7b423          	sd	a0,1960(a5) # ffffffffc02154d8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0201d38:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201d3c:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201d40:	4e079263          	bnez	a5,ffffffffc0202224 <swap_init+0x5fc>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201d44:	6599                	lui	a1,0x6
ffffffffc0201d46:	460d                	li	a2,3
ffffffffc0201d48:	6505                	lui	a0,0x1
ffffffffc0201d4a:	ec5fe0ef          	jal	ra,ffffffffc0200c0e <vma_create>
ffffffffc0201d4e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201d50:	4e050a63          	beqz	a0,ffffffffc0202244 <swap_init+0x61c>

     insert_vma_struct(mm, vma);
ffffffffc0201d54:	855e                	mv	a0,s7
ffffffffc0201d56:	f25fe0ef          	jal	ra,ffffffffc0200c7a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0201d5a:	00004517          	auipc	a0,0x4
ffffffffc0201d5e:	21e50513          	addi	a0,a0,542 # ffffffffc0205f78 <commands+0xf98>
ffffffffc0201d62:	b6efe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201d66:	018bb503          	ld	a0,24(s7)
ffffffffc0201d6a:	4605                	li	a2,1
ffffffffc0201d6c:	6585                	lui	a1,0x1
ffffffffc0201d6e:	454010ef          	jal	ra,ffffffffc02031c2 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201d72:	4e050963          	beqz	a0,ffffffffc0202264 <swap_init+0x63c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201d76:	00004517          	auipc	a0,0x4
ffffffffc0201d7a:	25250513          	addi	a0,a0,594 # ffffffffc0205fc8 <commands+0xfe8>
ffffffffc0201d7e:	00013997          	auipc	s3,0x13
ffffffffc0201d82:	77298993          	addi	s3,s3,1906 # ffffffffc02154f0 <check_rp>
ffffffffc0201d86:	b4afe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201d8a:	00013a17          	auipc	s4,0x13
ffffffffc0201d8e:	786a0a13          	addi	s4,s4,1926 # ffffffffc0215510 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201d92:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0201d94:	4505                	li	a0,1
ffffffffc0201d96:	31e010ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc0201d9a:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0201d9e:	32050763          	beqz	a0,ffffffffc02020cc <swap_init+0x4a4>
ffffffffc0201da2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201da4:	8b89                	andi	a5,a5,2
ffffffffc0201da6:	30079363          	bnez	a5,ffffffffc02020ac <swap_init+0x484>
ffffffffc0201daa:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201dac:	ff4c14e3          	bne	s8,s4,ffffffffc0201d94 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201db0:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0201db2:	00013c17          	auipc	s8,0x13
ffffffffc0201db6:	73ec0c13          	addi	s8,s8,1854 # ffffffffc02154f0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0201dba:	ec3e                	sd	a5,24(sp)
ffffffffc0201dbc:	641c                	ld	a5,8(s0)
ffffffffc0201dbe:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0201dc0:	481c                	lw	a5,16(s0)
ffffffffc0201dc2:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0201dc4:	00013797          	auipc	a5,0x13
ffffffffc0201dc8:	7e87be23          	sd	s0,2044(a5) # ffffffffc02155c0 <free_area+0x8>
ffffffffc0201dcc:	00013797          	auipc	a5,0x13
ffffffffc0201dd0:	7e87b623          	sd	s0,2028(a5) # ffffffffc02155b8 <free_area>
     nr_free = 0;
ffffffffc0201dd4:	00013797          	auipc	a5,0x13
ffffffffc0201dd8:	7e07aa23          	sw	zero,2036(a5) # ffffffffc02155c8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0201ddc:	000c3503          	ld	a0,0(s8)
ffffffffc0201de0:	4585                	li	a1,1
ffffffffc0201de2:	0c21                	addi	s8,s8,8
ffffffffc0201de4:	358010ef          	jal	ra,ffffffffc020313c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201de8:	ff4c1ae3          	bne	s8,s4,ffffffffc0201ddc <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201dec:	01042c03          	lw	s8,16(s0)
ffffffffc0201df0:	4791                	li	a5,4
ffffffffc0201df2:	50fc1563          	bne	s8,a5,ffffffffc02022fc <swap_init+0x6d4>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0201df6:	00004517          	auipc	a0,0x4
ffffffffc0201dfa:	25a50513          	addi	a0,a0,602 # ffffffffc0206050 <commands+0x1070>
ffffffffc0201dfe:	ad2fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201e02:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0201e04:	00013797          	auipc	a5,0x13
ffffffffc0201e08:	6607ae23          	sw	zero,1660(a5) # ffffffffc0215480 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201e0c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0201e0e:	00013797          	auipc	a5,0x13
ffffffffc0201e12:	67278793          	addi	a5,a5,1650 # ffffffffc0215480 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201e16:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0201e1a:	4398                	lw	a4,0(a5)
ffffffffc0201e1c:	4585                	li	a1,1
ffffffffc0201e1e:	2701                	sext.w	a4,a4
ffffffffc0201e20:	38b71263          	bne	a4,a1,ffffffffc02021a4 <swap_init+0x57c>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0201e24:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0201e28:	4394                	lw	a3,0(a5)
ffffffffc0201e2a:	2681                	sext.w	a3,a3
ffffffffc0201e2c:	38e69c63          	bne	a3,a4,ffffffffc02021c4 <swap_init+0x59c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201e30:	6689                	lui	a3,0x2
ffffffffc0201e32:	462d                	li	a2,11
ffffffffc0201e34:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0201e38:	4398                	lw	a4,0(a5)
ffffffffc0201e3a:	4589                	li	a1,2
ffffffffc0201e3c:	2701                	sext.w	a4,a4
ffffffffc0201e3e:	2eb71363          	bne	a4,a1,ffffffffc0202124 <swap_init+0x4fc>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0201e42:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0201e46:	4394                	lw	a3,0(a5)
ffffffffc0201e48:	2681                	sext.w	a3,a3
ffffffffc0201e4a:	2ee69d63          	bne	a3,a4,ffffffffc0202144 <swap_init+0x51c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201e4e:	668d                	lui	a3,0x3
ffffffffc0201e50:	4631                	li	a2,12
ffffffffc0201e52:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201e56:	4398                	lw	a4,0(a5)
ffffffffc0201e58:	458d                	li	a1,3
ffffffffc0201e5a:	2701                	sext.w	a4,a4
ffffffffc0201e5c:	30b71463          	bne	a4,a1,ffffffffc0202164 <swap_init+0x53c>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0201e60:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0201e64:	4394                	lw	a3,0(a5)
ffffffffc0201e66:	2681                	sext.w	a3,a3
ffffffffc0201e68:	30e69e63          	bne	a3,a4,ffffffffc0202184 <swap_init+0x55c>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201e6c:	6691                	lui	a3,0x4
ffffffffc0201e6e:	4635                	li	a2,13
ffffffffc0201e70:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0201e74:	4398                	lw	a4,0(a5)
ffffffffc0201e76:	2701                	sext.w	a4,a4
ffffffffc0201e78:	37871663          	bne	a4,s8,ffffffffc02021e4 <swap_init+0x5bc>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201e7c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0201e80:	439c                	lw	a5,0(a5)
ffffffffc0201e82:	2781                	sext.w	a5,a5
ffffffffc0201e84:	38e79063          	bne	a5,a4,ffffffffc0202204 <swap_init+0x5dc>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201e88:	481c                	lw	a5,16(s0)
ffffffffc0201e8a:	3e079d63          	bnez	a5,ffffffffc0202284 <swap_init+0x65c>
ffffffffc0201e8e:	00013797          	auipc	a5,0x13
ffffffffc0201e92:	68278793          	addi	a5,a5,1666 # ffffffffc0215510 <swap_in_seq_no>
ffffffffc0201e96:	00013717          	auipc	a4,0x13
ffffffffc0201e9a:	6a270713          	addi	a4,a4,1698 # ffffffffc0215538 <swap_out_seq_no>
ffffffffc0201e9e:	00013617          	auipc	a2,0x13
ffffffffc0201ea2:	69a60613          	addi	a2,a2,1690 # ffffffffc0215538 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201ea6:	56fd                	li	a3,-1
ffffffffc0201ea8:	c394                	sw	a3,0(a5)
ffffffffc0201eaa:	c314                	sw	a3,0(a4)
ffffffffc0201eac:	0791                	addi	a5,a5,4
ffffffffc0201eae:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201eb0:	fef61ce3          	bne	a2,a5,ffffffffc0201ea8 <swap_init+0x280>
ffffffffc0201eb4:	00013697          	auipc	a3,0x13
ffffffffc0201eb8:	6e468693          	addi	a3,a3,1764 # ffffffffc0215598 <check_ptep>
ffffffffc0201ebc:	00013817          	auipc	a6,0x13
ffffffffc0201ec0:	63480813          	addi	a6,a6,1588 # ffffffffc02154f0 <check_rp>
ffffffffc0201ec4:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0201ec6:	00013c97          	auipc	s9,0x13
ffffffffc0201eca:	5e2c8c93          	addi	s9,s9,1506 # ffffffffc02154a8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ece:	00005d97          	auipc	s11,0x5
ffffffffc0201ed2:	0a2d8d93          	addi	s11,s11,162 # ffffffffc0206f70 <nbase>
ffffffffc0201ed6:	00013c17          	auipc	s8,0x13
ffffffffc0201eda:	712c0c13          	addi	s8,s8,1810 # ffffffffc02155e8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201ede:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201ee2:	4601                	li	a2,0
ffffffffc0201ee4:	85ea                	mv	a1,s10
ffffffffc0201ee6:	855a                	mv	a0,s6
ffffffffc0201ee8:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0201eea:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201eec:	2d6010ef          	jal	ra,ffffffffc02031c2 <get_pte>
ffffffffc0201ef0:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201ef2:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201ef4:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0201ef6:	1e050b63          	beqz	a0,ffffffffc02020ec <swap_init+0x4c4>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201efa:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201efc:	0017f613          	andi	a2,a5,1
ffffffffc0201f00:	18060a63          	beqz	a2,ffffffffc0202094 <swap_init+0x46c>
    if (PPN(pa) >= npage) {
ffffffffc0201f04:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f08:	078a                	slli	a5,a5,0x2
ffffffffc0201f0a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f0c:	14c7f863          	bleu	a2,a5,ffffffffc020205c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f10:	000db703          	ld	a4,0(s11)
ffffffffc0201f14:	000c3603          	ld	a2,0(s8)
ffffffffc0201f18:	00083583          	ld	a1,0(a6)
ffffffffc0201f1c:	8f99                	sub	a5,a5,a4
ffffffffc0201f1e:	079a                	slli	a5,a5,0x6
ffffffffc0201f20:	e43a                	sd	a4,8(sp)
ffffffffc0201f22:	97b2                	add	a5,a5,a2
ffffffffc0201f24:	14f59863          	bne	a1,a5,ffffffffc0202074 <swap_init+0x44c>
ffffffffc0201f28:	6785                	lui	a5,0x1
ffffffffc0201f2a:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201f2c:	6795                	lui	a5,0x5
ffffffffc0201f2e:	06a1                	addi	a3,a3,8
ffffffffc0201f30:	0821                	addi	a6,a6,8
ffffffffc0201f32:	fafd16e3          	bne	s10,a5,ffffffffc0201ede <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201f36:	00004517          	auipc	a0,0x4
ffffffffc0201f3a:	1ea50513          	addi	a0,a0,490 # ffffffffc0206120 <commands+0x1140>
ffffffffc0201f3e:	992fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc0201f42:	00013797          	auipc	a5,0x13
ffffffffc0201f46:	54e78793          	addi	a5,a5,1358 # ffffffffc0215490 <sm>
ffffffffc0201f4a:	639c                	ld	a5,0(a5)
ffffffffc0201f4c:	7f9c                	ld	a5,56(a5)
ffffffffc0201f4e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0201f50:	40051663          	bnez	a0,ffffffffc020235c <swap_init+0x734>

     nr_free = nr_free_store;
ffffffffc0201f54:	77a2                	ld	a5,40(sp)
ffffffffc0201f56:	00013717          	auipc	a4,0x13
ffffffffc0201f5a:	66f72923          	sw	a5,1650(a4) # ffffffffc02155c8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0201f5e:	67e2                	ld	a5,24(sp)
ffffffffc0201f60:	00013717          	auipc	a4,0x13
ffffffffc0201f64:	64f73c23          	sd	a5,1624(a4) # ffffffffc02155b8 <free_area>
ffffffffc0201f68:	7782                	ld	a5,32(sp)
ffffffffc0201f6a:	00013717          	auipc	a4,0x13
ffffffffc0201f6e:	64f73b23          	sd	a5,1622(a4) # ffffffffc02155c0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201f72:	0009b503          	ld	a0,0(s3)
ffffffffc0201f76:	4585                	li	a1,1
ffffffffc0201f78:	09a1                	addi	s3,s3,8
ffffffffc0201f7a:	1c2010ef          	jal	ra,ffffffffc020313c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201f7e:	ff499ae3          	bne	s3,s4,ffffffffc0201f72 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0201f82:	855e                	mv	a0,s7
ffffffffc0201f84:	dc5fe0ef          	jal	ra,ffffffffc0200d48 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201f88:	00013797          	auipc	a5,0x13
ffffffffc0201f8c:	51878793          	addi	a5,a5,1304 # ffffffffc02154a0 <boot_pgdir>
ffffffffc0201f90:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201f92:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f96:	6394                	ld	a3,0(a5)
ffffffffc0201f98:	068a                	slli	a3,a3,0x2
ffffffffc0201f9a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f9c:	0ce6f063          	bleu	a4,a3,ffffffffc020205c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fa0:	67a2                	ld	a5,8(sp)
ffffffffc0201fa2:	000c3503          	ld	a0,0(s8)
ffffffffc0201fa6:	8e9d                	sub	a3,a3,a5
ffffffffc0201fa8:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201faa:	8699                	srai	a3,a3,0x6
ffffffffc0201fac:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0201fae:	57fd                	li	a5,-1
ffffffffc0201fb0:	83b1                	srli	a5,a5,0xc
ffffffffc0201fb2:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fb4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201fb6:	2ee7f763          	bleu	a4,a5,ffffffffc02022a4 <swap_init+0x67c>
     free_page(pde2page(pd0[0]));
ffffffffc0201fba:	00013797          	auipc	a5,0x13
ffffffffc0201fbe:	61e78793          	addi	a5,a5,1566 # ffffffffc02155d8 <va_pa_offset>
ffffffffc0201fc2:	639c                	ld	a5,0(a5)
ffffffffc0201fc4:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fc6:	629c                	ld	a5,0(a3)
ffffffffc0201fc8:	078a                	slli	a5,a5,0x2
ffffffffc0201fca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fcc:	08e7f863          	bleu	a4,a5,ffffffffc020205c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fd0:	69a2                	ld	s3,8(sp)
ffffffffc0201fd2:	4585                	li	a1,1
ffffffffc0201fd4:	413787b3          	sub	a5,a5,s3
ffffffffc0201fd8:	079a                	slli	a5,a5,0x6
ffffffffc0201fda:	953e                	add	a0,a0,a5
ffffffffc0201fdc:	160010ef          	jal	ra,ffffffffc020313c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fe0:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201fe4:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fe8:	078a                	slli	a5,a5,0x2
ffffffffc0201fea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fec:	06e7f863          	bleu	a4,a5,ffffffffc020205c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ff0:	000c3503          	ld	a0,0(s8)
ffffffffc0201ff4:	413787b3          	sub	a5,a5,s3
ffffffffc0201ff8:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0201ffa:	4585                	li	a1,1
ffffffffc0201ffc:	953e                	add	a0,a0,a5
ffffffffc0201ffe:	13e010ef          	jal	ra,ffffffffc020313c <free_pages>
     pgdir[0] = 0;
ffffffffc0202002:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202006:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020200a:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020200c:	00878963          	beq	a5,s0,ffffffffc020201e <swap_init+0x3f6>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202010:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202014:	679c                	ld	a5,8(a5)
ffffffffc0202016:	397d                	addiw	s2,s2,-1
ffffffffc0202018:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020201a:	fe879be3          	bne	a5,s0,ffffffffc0202010 <swap_init+0x3e8>
     }
     assert(count==0);
ffffffffc020201e:	28091f63          	bnez	s2,ffffffffc02022bc <swap_init+0x694>
     assert(total==0);
ffffffffc0202022:	2a049d63          	bnez	s1,ffffffffc02022dc <swap_init+0x6b4>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202026:	00004517          	auipc	a0,0x4
ffffffffc020202a:	14a50513          	addi	a0,a0,330 # ffffffffc0206170 <commands+0x1190>
ffffffffc020202e:	8a2fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202032:	b199                	j	ffffffffc0201c78 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202034:	4481                	li	s1,0
ffffffffc0202036:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202038:	4981                	li	s3,0
ffffffffc020203a:	b96d                	j	ffffffffc0201cf4 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020203c:	00004697          	auipc	a3,0x4
ffffffffc0202040:	ecc68693          	addi	a3,a3,-308 # ffffffffc0205f08 <commands+0xf28>
ffffffffc0202044:	00003617          	auipc	a2,0x3
ffffffffc0202048:	7fc60613          	addi	a2,a2,2044 # ffffffffc0205840 <commands+0x860>
ffffffffc020204c:	0bd00593          	li	a1,189
ffffffffc0202050:	00004517          	auipc	a0,0x4
ffffffffc0202054:	e9050513          	addi	a0,a0,-368 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202058:	97efe0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020205c:	00004617          	auipc	a2,0x4
ffffffffc0202060:	ad460613          	addi	a2,a2,-1324 # ffffffffc0205b30 <commands+0xb50>
ffffffffc0202064:	06200593          	li	a1,98
ffffffffc0202068:	00004517          	auipc	a0,0x4
ffffffffc020206c:	ae850513          	addi	a0,a0,-1304 # ffffffffc0205b50 <commands+0xb70>
ffffffffc0202070:	966fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202074:	00004697          	auipc	a3,0x4
ffffffffc0202078:	08468693          	addi	a3,a3,132 # ffffffffc02060f8 <commands+0x1118>
ffffffffc020207c:	00003617          	auipc	a2,0x3
ffffffffc0202080:	7c460613          	addi	a2,a2,1988 # ffffffffc0205840 <commands+0x860>
ffffffffc0202084:	0fd00593          	li	a1,253
ffffffffc0202088:	00004517          	auipc	a0,0x4
ffffffffc020208c:	e5850513          	addi	a0,a0,-424 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202090:	946fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202094:	00004617          	auipc	a2,0x4
ffffffffc0202098:	03c60613          	addi	a2,a2,60 # ffffffffc02060d0 <commands+0x10f0>
ffffffffc020209c:	07400593          	li	a1,116
ffffffffc02020a0:	00004517          	auipc	a0,0x4
ffffffffc02020a4:	ab050513          	addi	a0,a0,-1360 # ffffffffc0205b50 <commands+0xb70>
ffffffffc02020a8:	92efe0ef          	jal	ra,ffffffffc02001d6 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02020ac:	00004697          	auipc	a3,0x4
ffffffffc02020b0:	f5c68693          	addi	a3,a3,-164 # ffffffffc0206008 <commands+0x1028>
ffffffffc02020b4:	00003617          	auipc	a2,0x3
ffffffffc02020b8:	78c60613          	addi	a2,a2,1932 # ffffffffc0205840 <commands+0x860>
ffffffffc02020bc:	0de00593          	li	a1,222
ffffffffc02020c0:	00004517          	auipc	a0,0x4
ffffffffc02020c4:	e2050513          	addi	a0,a0,-480 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc02020c8:	90efe0ef          	jal	ra,ffffffffc02001d6 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02020cc:	00004697          	auipc	a3,0x4
ffffffffc02020d0:	f2468693          	addi	a3,a3,-220 # ffffffffc0205ff0 <commands+0x1010>
ffffffffc02020d4:	00003617          	auipc	a2,0x3
ffffffffc02020d8:	76c60613          	addi	a2,a2,1900 # ffffffffc0205840 <commands+0x860>
ffffffffc02020dc:	0dd00593          	li	a1,221
ffffffffc02020e0:	00004517          	auipc	a0,0x4
ffffffffc02020e4:	e0050513          	addi	a0,a0,-512 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc02020e8:	8eefe0ef          	jal	ra,ffffffffc02001d6 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02020ec:	00004697          	auipc	a3,0x4
ffffffffc02020f0:	fcc68693          	addi	a3,a3,-52 # ffffffffc02060b8 <commands+0x10d8>
ffffffffc02020f4:	00003617          	auipc	a2,0x3
ffffffffc02020f8:	74c60613          	addi	a2,a2,1868 # ffffffffc0205840 <commands+0x860>
ffffffffc02020fc:	0fc00593          	li	a1,252
ffffffffc0202100:	00004517          	auipc	a0,0x4
ffffffffc0202104:	de050513          	addi	a0,a0,-544 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202108:	8cefe0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020210c:	00004617          	auipc	a2,0x4
ffffffffc0202110:	db460613          	addi	a2,a2,-588 # ffffffffc0205ec0 <commands+0xee0>
ffffffffc0202114:	02a00593          	li	a1,42
ffffffffc0202118:	00004517          	auipc	a0,0x4
ffffffffc020211c:	dc850513          	addi	a0,a0,-568 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202120:	8b6fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==2);
ffffffffc0202124:	00004697          	auipc	a3,0x4
ffffffffc0202128:	f6468693          	addi	a3,a3,-156 # ffffffffc0206088 <commands+0x10a8>
ffffffffc020212c:	00003617          	auipc	a2,0x3
ffffffffc0202130:	71460613          	addi	a2,a2,1812 # ffffffffc0205840 <commands+0x860>
ffffffffc0202134:	09800593          	li	a1,152
ffffffffc0202138:	00004517          	auipc	a0,0x4
ffffffffc020213c:	da850513          	addi	a0,a0,-600 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202140:	896fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==2);
ffffffffc0202144:	00004697          	auipc	a3,0x4
ffffffffc0202148:	f4468693          	addi	a3,a3,-188 # ffffffffc0206088 <commands+0x10a8>
ffffffffc020214c:	00003617          	auipc	a2,0x3
ffffffffc0202150:	6f460613          	addi	a2,a2,1780 # ffffffffc0205840 <commands+0x860>
ffffffffc0202154:	09a00593          	li	a1,154
ffffffffc0202158:	00004517          	auipc	a0,0x4
ffffffffc020215c:	d8850513          	addi	a0,a0,-632 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202160:	876fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==3);
ffffffffc0202164:	00004697          	auipc	a3,0x4
ffffffffc0202168:	f3468693          	addi	a3,a3,-204 # ffffffffc0206098 <commands+0x10b8>
ffffffffc020216c:	00003617          	auipc	a2,0x3
ffffffffc0202170:	6d460613          	addi	a2,a2,1748 # ffffffffc0205840 <commands+0x860>
ffffffffc0202174:	09c00593          	li	a1,156
ffffffffc0202178:	00004517          	auipc	a0,0x4
ffffffffc020217c:	d6850513          	addi	a0,a0,-664 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202180:	856fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==3);
ffffffffc0202184:	00004697          	auipc	a3,0x4
ffffffffc0202188:	f1468693          	addi	a3,a3,-236 # ffffffffc0206098 <commands+0x10b8>
ffffffffc020218c:	00003617          	auipc	a2,0x3
ffffffffc0202190:	6b460613          	addi	a2,a2,1716 # ffffffffc0205840 <commands+0x860>
ffffffffc0202194:	09e00593          	li	a1,158
ffffffffc0202198:	00004517          	auipc	a0,0x4
ffffffffc020219c:	d4850513          	addi	a0,a0,-696 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc02021a0:	836fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==1);
ffffffffc02021a4:	00004697          	auipc	a3,0x4
ffffffffc02021a8:	ed468693          	addi	a3,a3,-300 # ffffffffc0206078 <commands+0x1098>
ffffffffc02021ac:	00003617          	auipc	a2,0x3
ffffffffc02021b0:	69460613          	addi	a2,a2,1684 # ffffffffc0205840 <commands+0x860>
ffffffffc02021b4:	09400593          	li	a1,148
ffffffffc02021b8:	00004517          	auipc	a0,0x4
ffffffffc02021bc:	d2850513          	addi	a0,a0,-728 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc02021c0:	816fe0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==1);
ffffffffc02021c4:	00004697          	auipc	a3,0x4
ffffffffc02021c8:	eb468693          	addi	a3,a3,-332 # ffffffffc0206078 <commands+0x1098>
ffffffffc02021cc:	00003617          	auipc	a2,0x3
ffffffffc02021d0:	67460613          	addi	a2,a2,1652 # ffffffffc0205840 <commands+0x860>
ffffffffc02021d4:	09600593          	li	a1,150
ffffffffc02021d8:	00004517          	auipc	a0,0x4
ffffffffc02021dc:	d0850513          	addi	a0,a0,-760 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc02021e0:	ff7fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==4);
ffffffffc02021e4:	00004697          	auipc	a3,0x4
ffffffffc02021e8:	a3c68693          	addi	a3,a3,-1476 # ffffffffc0205c20 <commands+0xc40>
ffffffffc02021ec:	00003617          	auipc	a2,0x3
ffffffffc02021f0:	65460613          	addi	a2,a2,1620 # ffffffffc0205840 <commands+0x860>
ffffffffc02021f4:	0a000593          	li	a1,160
ffffffffc02021f8:	00004517          	auipc	a0,0x4
ffffffffc02021fc:	ce850513          	addi	a0,a0,-792 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202200:	fd7fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgfault_num==4);
ffffffffc0202204:	00004697          	auipc	a3,0x4
ffffffffc0202208:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0205c20 <commands+0xc40>
ffffffffc020220c:	00003617          	auipc	a2,0x3
ffffffffc0202210:	63460613          	addi	a2,a2,1588 # ffffffffc0205840 <commands+0x860>
ffffffffc0202214:	0a200593          	li	a1,162
ffffffffc0202218:	00004517          	auipc	a0,0x4
ffffffffc020221c:	cc850513          	addi	a0,a0,-824 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202220:	fb7fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202224:	00004697          	auipc	a3,0x4
ffffffffc0202228:	8cc68693          	addi	a3,a3,-1844 # ffffffffc0205af0 <commands+0xb10>
ffffffffc020222c:	00003617          	auipc	a2,0x3
ffffffffc0202230:	61460613          	addi	a2,a2,1556 # ffffffffc0205840 <commands+0x860>
ffffffffc0202234:	0cd00593          	li	a1,205
ffffffffc0202238:	00004517          	auipc	a0,0x4
ffffffffc020223c:	ca850513          	addi	a0,a0,-856 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202240:	f97fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(vma != NULL);
ffffffffc0202244:	00004697          	auipc	a3,0x4
ffffffffc0202248:	9a468693          	addi	a3,a3,-1628 # ffffffffc0205be8 <commands+0xc08>
ffffffffc020224c:	00003617          	auipc	a2,0x3
ffffffffc0202250:	5f460613          	addi	a2,a2,1524 # ffffffffc0205840 <commands+0x860>
ffffffffc0202254:	0d000593          	li	a1,208
ffffffffc0202258:	00004517          	auipc	a0,0x4
ffffffffc020225c:	c8850513          	addi	a0,a0,-888 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202260:	f77fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202264:	00004697          	auipc	a3,0x4
ffffffffc0202268:	d4c68693          	addi	a3,a3,-692 # ffffffffc0205fb0 <commands+0xfd0>
ffffffffc020226c:	00003617          	auipc	a2,0x3
ffffffffc0202270:	5d460613          	addi	a2,a2,1492 # ffffffffc0205840 <commands+0x860>
ffffffffc0202274:	0d800593          	li	a1,216
ffffffffc0202278:	00004517          	auipc	a0,0x4
ffffffffc020227c:	c6850513          	addi	a0,a0,-920 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202280:	f57fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert( nr_free == 0);         
ffffffffc0202284:	00004697          	auipc	a3,0x4
ffffffffc0202288:	e2468693          	addi	a3,a3,-476 # ffffffffc02060a8 <commands+0x10c8>
ffffffffc020228c:	00003617          	auipc	a2,0x3
ffffffffc0202290:	5b460613          	addi	a2,a2,1460 # ffffffffc0205840 <commands+0x860>
ffffffffc0202294:	0f400593          	li	a1,244
ffffffffc0202298:	00004517          	auipc	a0,0x4
ffffffffc020229c:	c4850513          	addi	a0,a0,-952 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc02022a0:	f37fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return KADDR(page2pa(page));
ffffffffc02022a4:	00004617          	auipc	a2,0x4
ffffffffc02022a8:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0205b60 <commands+0xb80>
ffffffffc02022ac:	06900593          	li	a1,105
ffffffffc02022b0:	00004517          	auipc	a0,0x4
ffffffffc02022b4:	8a050513          	addi	a0,a0,-1888 # ffffffffc0205b50 <commands+0xb70>
ffffffffc02022b8:	f1ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(count==0);
ffffffffc02022bc:	00004697          	auipc	a3,0x4
ffffffffc02022c0:	e9468693          	addi	a3,a3,-364 # ffffffffc0206150 <commands+0x1170>
ffffffffc02022c4:	00003617          	auipc	a2,0x3
ffffffffc02022c8:	57c60613          	addi	a2,a2,1404 # ffffffffc0205840 <commands+0x860>
ffffffffc02022cc:	11c00593          	li	a1,284
ffffffffc02022d0:	00004517          	auipc	a0,0x4
ffffffffc02022d4:	c1050513          	addi	a0,a0,-1008 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc02022d8:	efffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(total==0);
ffffffffc02022dc:	00004697          	auipc	a3,0x4
ffffffffc02022e0:	e8468693          	addi	a3,a3,-380 # ffffffffc0206160 <commands+0x1180>
ffffffffc02022e4:	00003617          	auipc	a2,0x3
ffffffffc02022e8:	55c60613          	addi	a2,a2,1372 # ffffffffc0205840 <commands+0x860>
ffffffffc02022ec:	11d00593          	li	a1,285
ffffffffc02022f0:	00004517          	auipc	a0,0x4
ffffffffc02022f4:	bf050513          	addi	a0,a0,-1040 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc02022f8:	edffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02022fc:	00004697          	auipc	a3,0x4
ffffffffc0202300:	d2c68693          	addi	a3,a3,-724 # ffffffffc0206028 <commands+0x1048>
ffffffffc0202304:	00003617          	auipc	a2,0x3
ffffffffc0202308:	53c60613          	addi	a2,a2,1340 # ffffffffc0205840 <commands+0x860>
ffffffffc020230c:	0eb00593          	li	a1,235
ffffffffc0202310:	00004517          	auipc	a0,0x4
ffffffffc0202314:	bd050513          	addi	a0,a0,-1072 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202318:	ebffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(mm != NULL);
ffffffffc020231c:	00003697          	auipc	a3,0x3
ffffffffc0202320:	64c68693          	addi	a3,a3,1612 # ffffffffc0205968 <commands+0x988>
ffffffffc0202324:	00003617          	auipc	a2,0x3
ffffffffc0202328:	51c60613          	addi	a2,a2,1308 # ffffffffc0205840 <commands+0x860>
ffffffffc020232c:	0c500593          	li	a1,197
ffffffffc0202330:	00004517          	auipc	a0,0x4
ffffffffc0202334:	bb050513          	addi	a0,a0,-1104 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202338:	e9ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020233c:	00004697          	auipc	a3,0x4
ffffffffc0202340:	c2468693          	addi	a3,a3,-988 # ffffffffc0205f60 <commands+0xf80>
ffffffffc0202344:	00003617          	auipc	a2,0x3
ffffffffc0202348:	4fc60613          	addi	a2,a2,1276 # ffffffffc0205840 <commands+0x860>
ffffffffc020234c:	0c800593          	li	a1,200
ffffffffc0202350:	00004517          	auipc	a0,0x4
ffffffffc0202354:	b9050513          	addi	a0,a0,-1136 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202358:	e7ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(ret==0);
ffffffffc020235c:	00004697          	auipc	a3,0x4
ffffffffc0202360:	dec68693          	addi	a3,a3,-532 # ffffffffc0206148 <commands+0x1168>
ffffffffc0202364:	00003617          	auipc	a2,0x3
ffffffffc0202368:	4dc60613          	addi	a2,a2,1244 # ffffffffc0205840 <commands+0x860>
ffffffffc020236c:	10300593          	li	a1,259
ffffffffc0202370:	00004517          	auipc	a0,0x4
ffffffffc0202374:	b7050513          	addi	a0,a0,-1168 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202378:	e5ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>
     assert(total == nr_free_pages());
ffffffffc020237c:	00004697          	auipc	a3,0x4
ffffffffc0202380:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0205f18 <commands+0xf38>
ffffffffc0202384:	00003617          	auipc	a2,0x3
ffffffffc0202388:	4bc60613          	addi	a2,a2,1212 # ffffffffc0205840 <commands+0x860>
ffffffffc020238c:	0c000593          	li	a1,192
ffffffffc0202390:	00004517          	auipc	a0,0x4
ffffffffc0202394:	b5050513          	addi	a0,a0,-1200 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202398:	e3ffd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc020239c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc020239c:	00013797          	auipc	a5,0x13
ffffffffc02023a0:	0f478793          	addi	a5,a5,244 # ffffffffc0215490 <sm>
ffffffffc02023a4:	639c                	ld	a5,0(a5)
ffffffffc02023a6:	0107b303          	ld	t1,16(a5)
ffffffffc02023aa:	8302                	jr	t1

ffffffffc02023ac <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02023ac:	00013797          	auipc	a5,0x13
ffffffffc02023b0:	0e478793          	addi	a5,a5,228 # ffffffffc0215490 <sm>
ffffffffc02023b4:	639c                	ld	a5,0(a5)
ffffffffc02023b6:	0207b303          	ld	t1,32(a5)
ffffffffc02023ba:	8302                	jr	t1

ffffffffc02023bc <swap_out>:
{
ffffffffc02023bc:	711d                	addi	sp,sp,-96
ffffffffc02023be:	ec86                	sd	ra,88(sp)
ffffffffc02023c0:	e8a2                	sd	s0,80(sp)
ffffffffc02023c2:	e4a6                	sd	s1,72(sp)
ffffffffc02023c4:	e0ca                	sd	s2,64(sp)
ffffffffc02023c6:	fc4e                	sd	s3,56(sp)
ffffffffc02023c8:	f852                	sd	s4,48(sp)
ffffffffc02023ca:	f456                	sd	s5,40(sp)
ffffffffc02023cc:	f05a                	sd	s6,32(sp)
ffffffffc02023ce:	ec5e                	sd	s7,24(sp)
ffffffffc02023d0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02023d2:	cde9                	beqz	a1,ffffffffc02024ac <swap_out+0xf0>
ffffffffc02023d4:	8ab2                	mv	s5,a2
ffffffffc02023d6:	892a                	mv	s2,a0
ffffffffc02023d8:	8a2e                	mv	s4,a1
ffffffffc02023da:	4401                	li	s0,0
ffffffffc02023dc:	00013997          	auipc	s3,0x13
ffffffffc02023e0:	0b498993          	addi	s3,s3,180 # ffffffffc0215490 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02023e4:	00004b17          	auipc	s6,0x4
ffffffffc02023e8:	e0cb0b13          	addi	s6,s6,-500 # ffffffffc02061f0 <commands+0x1210>
                    cprintf("SWAP: failed to save\n");
ffffffffc02023ec:	00004b97          	auipc	s7,0x4
ffffffffc02023f0:	decb8b93          	addi	s7,s7,-532 # ffffffffc02061d8 <commands+0x11f8>
ffffffffc02023f4:	a825                	j	ffffffffc020242c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02023f6:	67a2                	ld	a5,8(sp)
ffffffffc02023f8:	8626                	mv	a2,s1
ffffffffc02023fa:	85a2                	mv	a1,s0
ffffffffc02023fc:	7f94                	ld	a3,56(a5)
ffffffffc02023fe:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202400:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202402:	82b1                	srli	a3,a3,0xc
ffffffffc0202404:	0685                	addi	a3,a3,1
ffffffffc0202406:	ccbfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020240a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020240c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020240e:	7d1c                	ld	a5,56(a0)
ffffffffc0202410:	83b1                	srli	a5,a5,0xc
ffffffffc0202412:	0785                	addi	a5,a5,1
ffffffffc0202414:	07a2                	slli	a5,a5,0x8
ffffffffc0202416:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc020241a:	523000ef          	jal	ra,ffffffffc020313c <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020241e:	01893503          	ld	a0,24(s2)
ffffffffc0202422:	85a6                	mv	a1,s1
ffffffffc0202424:	38f010ef          	jal	ra,ffffffffc0203fb2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202428:	048a0d63          	beq	s4,s0,ffffffffc0202482 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020242c:	0009b783          	ld	a5,0(s3)
ffffffffc0202430:	8656                	mv	a2,s5
ffffffffc0202432:	002c                	addi	a1,sp,8
ffffffffc0202434:	7b9c                	ld	a5,48(a5)
ffffffffc0202436:	854a                	mv	a0,s2
ffffffffc0202438:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020243a:	e12d                	bnez	a0,ffffffffc020249c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020243c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020243e:	01893503          	ld	a0,24(s2)
ffffffffc0202442:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202444:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202446:	85a6                	mv	a1,s1
ffffffffc0202448:	57b000ef          	jal	ra,ffffffffc02031c2 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020244c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020244e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202450:	8b85                	andi	a5,a5,1
ffffffffc0202452:	cfb9                	beqz	a5,ffffffffc02024b0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202454:	65a2                	ld	a1,8(sp)
ffffffffc0202456:	7d9c                	ld	a5,56(a1)
ffffffffc0202458:	83b1                	srli	a5,a5,0xc
ffffffffc020245a:	00178513          	addi	a0,a5,1
ffffffffc020245e:	0522                	slli	a0,a0,0x8
ffffffffc0202460:	4bb010ef          	jal	ra,ffffffffc020411a <swapfs_write>
ffffffffc0202464:	d949                	beqz	a0,ffffffffc02023f6 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202466:	855e                	mv	a0,s7
ffffffffc0202468:	c69fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020246c:	0009b783          	ld	a5,0(s3)
ffffffffc0202470:	6622                	ld	a2,8(sp)
ffffffffc0202472:	4681                	li	a3,0
ffffffffc0202474:	739c                	ld	a5,32(a5)
ffffffffc0202476:	85a6                	mv	a1,s1
ffffffffc0202478:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc020247a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020247c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc020247e:	fa8a17e3          	bne	s4,s0,ffffffffc020242c <swap_out+0x70>
}
ffffffffc0202482:	8522                	mv	a0,s0
ffffffffc0202484:	60e6                	ld	ra,88(sp)
ffffffffc0202486:	6446                	ld	s0,80(sp)
ffffffffc0202488:	64a6                	ld	s1,72(sp)
ffffffffc020248a:	6906                	ld	s2,64(sp)
ffffffffc020248c:	79e2                	ld	s3,56(sp)
ffffffffc020248e:	7a42                	ld	s4,48(sp)
ffffffffc0202490:	7aa2                	ld	s5,40(sp)
ffffffffc0202492:	7b02                	ld	s6,32(sp)
ffffffffc0202494:	6be2                	ld	s7,24(sp)
ffffffffc0202496:	6c42                	ld	s8,16(sp)
ffffffffc0202498:	6125                	addi	sp,sp,96
ffffffffc020249a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020249c:	85a2                	mv	a1,s0
ffffffffc020249e:	00004517          	auipc	a0,0x4
ffffffffc02024a2:	cf250513          	addi	a0,a0,-782 # ffffffffc0206190 <commands+0x11b0>
ffffffffc02024a6:	c2bfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc02024aa:	bfe1                	j	ffffffffc0202482 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02024ac:	4401                	li	s0,0
ffffffffc02024ae:	bfd1                	j	ffffffffc0202482 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02024b0:	00004697          	auipc	a3,0x4
ffffffffc02024b4:	d1068693          	addi	a3,a3,-752 # ffffffffc02061c0 <commands+0x11e0>
ffffffffc02024b8:	00003617          	auipc	a2,0x3
ffffffffc02024bc:	38860613          	addi	a2,a2,904 # ffffffffc0205840 <commands+0x860>
ffffffffc02024c0:	06900593          	li	a1,105
ffffffffc02024c4:	00004517          	auipc	a0,0x4
ffffffffc02024c8:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc02024cc:	d0bfd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02024d0 <swap_in>:
{
ffffffffc02024d0:	7179                	addi	sp,sp,-48
ffffffffc02024d2:	e84a                	sd	s2,16(sp)
ffffffffc02024d4:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02024d6:	4505                	li	a0,1
{
ffffffffc02024d8:	ec26                	sd	s1,24(sp)
ffffffffc02024da:	e44e                	sd	s3,8(sp)
ffffffffc02024dc:	f406                	sd	ra,40(sp)
ffffffffc02024de:	f022                	sd	s0,32(sp)
ffffffffc02024e0:	84ae                	mv	s1,a1
ffffffffc02024e2:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02024e4:	3d1000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
     assert(result!=NULL);
ffffffffc02024e8:	c129                	beqz	a0,ffffffffc020252a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02024ea:	842a                	mv	s0,a0
ffffffffc02024ec:	01893503          	ld	a0,24(s2)
ffffffffc02024f0:	4601                	li	a2,0
ffffffffc02024f2:	85a6                	mv	a1,s1
ffffffffc02024f4:	4cf000ef          	jal	ra,ffffffffc02031c2 <get_pte>
ffffffffc02024f8:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02024fa:	6108                	ld	a0,0(a0)
ffffffffc02024fc:	85a2                	mv	a1,s0
ffffffffc02024fe:	385010ef          	jal	ra,ffffffffc0204082 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202502:	00093583          	ld	a1,0(s2)
ffffffffc0202506:	8626                	mv	a2,s1
ffffffffc0202508:	00004517          	auipc	a0,0x4
ffffffffc020250c:	97850513          	addi	a0,a0,-1672 # ffffffffc0205e80 <commands+0xea0>
ffffffffc0202510:	81a1                	srli	a1,a1,0x8
ffffffffc0202512:	bbffd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202516:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202518:	0089b023          	sd	s0,0(s3)
}
ffffffffc020251c:	7402                	ld	s0,32(sp)
ffffffffc020251e:	64e2                	ld	s1,24(sp)
ffffffffc0202520:	6942                	ld	s2,16(sp)
ffffffffc0202522:	69a2                	ld	s3,8(sp)
ffffffffc0202524:	4501                	li	a0,0
ffffffffc0202526:	6145                	addi	sp,sp,48
ffffffffc0202528:	8082                	ret
     assert(result!=NULL);
ffffffffc020252a:	00004697          	auipc	a3,0x4
ffffffffc020252e:	94668693          	addi	a3,a3,-1722 # ffffffffc0205e70 <commands+0xe90>
ffffffffc0202532:	00003617          	auipc	a2,0x3
ffffffffc0202536:	30e60613          	addi	a2,a2,782 # ffffffffc0205840 <commands+0x860>
ffffffffc020253a:	07f00593          	li	a1,127
ffffffffc020253e:	00004517          	auipc	a0,0x4
ffffffffc0202542:	9a250513          	addi	a0,a0,-1630 # ffffffffc0205ee0 <commands+0xf00>
ffffffffc0202546:	c91fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc020254a <default_init>:
    elm->prev = elm->next = elm;
ffffffffc020254a:	00013797          	auipc	a5,0x13
ffffffffc020254e:	06e78793          	addi	a5,a5,110 # ffffffffc02155b8 <free_area>
ffffffffc0202552:	e79c                	sd	a5,8(a5)
ffffffffc0202554:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202556:	0007a823          	sw	zero,16(a5)
}
ffffffffc020255a:	8082                	ret

ffffffffc020255c <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020255c:	00013517          	auipc	a0,0x13
ffffffffc0202560:	06c56503          	lwu	a0,108(a0) # ffffffffc02155c8 <free_area+0x10>
ffffffffc0202564:	8082                	ret

ffffffffc0202566 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202566:	715d                	addi	sp,sp,-80
ffffffffc0202568:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc020256a:	00013917          	auipc	s2,0x13
ffffffffc020256e:	04e90913          	addi	s2,s2,78 # ffffffffc02155b8 <free_area>
ffffffffc0202572:	00893783          	ld	a5,8(s2)
ffffffffc0202576:	e486                	sd	ra,72(sp)
ffffffffc0202578:	e0a2                	sd	s0,64(sp)
ffffffffc020257a:	fc26                	sd	s1,56(sp)
ffffffffc020257c:	f44e                	sd	s3,40(sp)
ffffffffc020257e:	f052                	sd	s4,32(sp)
ffffffffc0202580:	ec56                	sd	s5,24(sp)
ffffffffc0202582:	e85a                	sd	s6,16(sp)
ffffffffc0202584:	e45e                	sd	s7,8(sp)
ffffffffc0202586:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202588:	31278463          	beq	a5,s2,ffffffffc0202890 <default_check+0x32a>
ffffffffc020258c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202590:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202592:	8b05                	andi	a4,a4,1
ffffffffc0202594:	30070263          	beqz	a4,ffffffffc0202898 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0202598:	4401                	li	s0,0
ffffffffc020259a:	4481                	li	s1,0
ffffffffc020259c:	a031                	j	ffffffffc02025a8 <default_check+0x42>
ffffffffc020259e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc02025a2:	8b09                	andi	a4,a4,2
ffffffffc02025a4:	2e070a63          	beqz	a4,ffffffffc0202898 <default_check+0x332>
        count ++, total += p->property;
ffffffffc02025a8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02025ac:	679c                	ld	a5,8(a5)
ffffffffc02025ae:	2485                	addiw	s1,s1,1
ffffffffc02025b0:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02025b2:	ff2796e3          	bne	a5,s2,ffffffffc020259e <default_check+0x38>
ffffffffc02025b6:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc02025b8:	3cb000ef          	jal	ra,ffffffffc0203182 <nr_free_pages>
ffffffffc02025bc:	73351e63          	bne	a0,s3,ffffffffc0202cf8 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02025c0:	4505                	li	a0,1
ffffffffc02025c2:	2f3000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02025c6:	8a2a                	mv	s4,a0
ffffffffc02025c8:	46050863          	beqz	a0,ffffffffc0202a38 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02025cc:	4505                	li	a0,1
ffffffffc02025ce:	2e7000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02025d2:	89aa                	mv	s3,a0
ffffffffc02025d4:	74050263          	beqz	a0,ffffffffc0202d18 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02025d8:	4505                	li	a0,1
ffffffffc02025da:	2db000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02025de:	8aaa                	mv	s5,a0
ffffffffc02025e0:	4c050c63          	beqz	a0,ffffffffc0202ab8 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02025e4:	2d3a0a63          	beq	s4,s3,ffffffffc02028b8 <default_check+0x352>
ffffffffc02025e8:	2caa0863          	beq	s4,a0,ffffffffc02028b8 <default_check+0x352>
ffffffffc02025ec:	2ca98663          	beq	s3,a0,ffffffffc02028b8 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02025f0:	000a2783          	lw	a5,0(s4)
ffffffffc02025f4:	2e079263          	bnez	a5,ffffffffc02028d8 <default_check+0x372>
ffffffffc02025f8:	0009a783          	lw	a5,0(s3)
ffffffffc02025fc:	2c079e63          	bnez	a5,ffffffffc02028d8 <default_check+0x372>
ffffffffc0202600:	411c                	lw	a5,0(a0)
ffffffffc0202602:	2c079b63          	bnez	a5,ffffffffc02028d8 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0202606:	00013797          	auipc	a5,0x13
ffffffffc020260a:	fe278793          	addi	a5,a5,-30 # ffffffffc02155e8 <pages>
ffffffffc020260e:	639c                	ld	a5,0(a5)
ffffffffc0202610:	00005717          	auipc	a4,0x5
ffffffffc0202614:	96070713          	addi	a4,a4,-1696 # ffffffffc0206f70 <nbase>
ffffffffc0202618:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020261a:	00013717          	auipc	a4,0x13
ffffffffc020261e:	e8e70713          	addi	a4,a4,-370 # ffffffffc02154a8 <npage>
ffffffffc0202622:	6314                	ld	a3,0(a4)
ffffffffc0202624:	40fa0733          	sub	a4,s4,a5
ffffffffc0202628:	8719                	srai	a4,a4,0x6
ffffffffc020262a:	9732                	add	a4,a4,a2
ffffffffc020262c:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020262e:	0732                	slli	a4,a4,0xc
ffffffffc0202630:	2cd77463          	bleu	a3,a4,ffffffffc02028f8 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0202634:	40f98733          	sub	a4,s3,a5
ffffffffc0202638:	8719                	srai	a4,a4,0x6
ffffffffc020263a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020263c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020263e:	4ed77d63          	bleu	a3,a4,ffffffffc0202b38 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0202642:	40f507b3          	sub	a5,a0,a5
ffffffffc0202646:	8799                	srai	a5,a5,0x6
ffffffffc0202648:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020264a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020264c:	34d7f663          	bleu	a3,a5,ffffffffc0202998 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0202650:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202652:	00093c03          	ld	s8,0(s2)
ffffffffc0202656:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc020265a:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc020265e:	00013797          	auipc	a5,0x13
ffffffffc0202662:	f727b123          	sd	s2,-158(a5) # ffffffffc02155c0 <free_area+0x8>
ffffffffc0202666:	00013797          	auipc	a5,0x13
ffffffffc020266a:	f527b923          	sd	s2,-174(a5) # ffffffffc02155b8 <free_area>
    nr_free = 0;
ffffffffc020266e:	00013797          	auipc	a5,0x13
ffffffffc0202672:	f407ad23          	sw	zero,-166(a5) # ffffffffc02155c8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202676:	23f000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc020267a:	2e051f63          	bnez	a0,ffffffffc0202978 <default_check+0x412>
    free_page(p0);
ffffffffc020267e:	4585                	li	a1,1
ffffffffc0202680:	8552                	mv	a0,s4
ffffffffc0202682:	2bb000ef          	jal	ra,ffffffffc020313c <free_pages>
    free_page(p1);
ffffffffc0202686:	4585                	li	a1,1
ffffffffc0202688:	854e                	mv	a0,s3
ffffffffc020268a:	2b3000ef          	jal	ra,ffffffffc020313c <free_pages>
    free_page(p2);
ffffffffc020268e:	4585                	li	a1,1
ffffffffc0202690:	8556                	mv	a0,s5
ffffffffc0202692:	2ab000ef          	jal	ra,ffffffffc020313c <free_pages>
    assert(nr_free == 3);
ffffffffc0202696:	01092703          	lw	a4,16(s2)
ffffffffc020269a:	478d                	li	a5,3
ffffffffc020269c:	2af71e63          	bne	a4,a5,ffffffffc0202958 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02026a0:	4505                	li	a0,1
ffffffffc02026a2:	213000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02026a6:	89aa                	mv	s3,a0
ffffffffc02026a8:	28050863          	beqz	a0,ffffffffc0202938 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02026ac:	4505                	li	a0,1
ffffffffc02026ae:	207000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02026b2:	8aaa                	mv	s5,a0
ffffffffc02026b4:	3e050263          	beqz	a0,ffffffffc0202a98 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02026b8:	4505                	li	a0,1
ffffffffc02026ba:	1fb000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02026be:	8a2a                	mv	s4,a0
ffffffffc02026c0:	3a050c63          	beqz	a0,ffffffffc0202a78 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc02026c4:	4505                	li	a0,1
ffffffffc02026c6:	1ef000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02026ca:	38051763          	bnez	a0,ffffffffc0202a58 <default_check+0x4f2>
    free_page(p0);
ffffffffc02026ce:	4585                	li	a1,1
ffffffffc02026d0:	854e                	mv	a0,s3
ffffffffc02026d2:	26b000ef          	jal	ra,ffffffffc020313c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02026d6:	00893783          	ld	a5,8(s2)
ffffffffc02026da:	23278f63          	beq	a5,s2,ffffffffc0202918 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc02026de:	4505                	li	a0,1
ffffffffc02026e0:	1d5000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02026e4:	32a99a63          	bne	s3,a0,ffffffffc0202a18 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc02026e8:	4505                	li	a0,1
ffffffffc02026ea:	1cb000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02026ee:	30051563          	bnez	a0,ffffffffc02029f8 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc02026f2:	01092783          	lw	a5,16(s2)
ffffffffc02026f6:	2e079163          	bnez	a5,ffffffffc02029d8 <default_check+0x472>
    free_page(p);
ffffffffc02026fa:	854e                	mv	a0,s3
ffffffffc02026fc:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02026fe:	00013797          	auipc	a5,0x13
ffffffffc0202702:	eb87bd23          	sd	s8,-326(a5) # ffffffffc02155b8 <free_area>
ffffffffc0202706:	00013797          	auipc	a5,0x13
ffffffffc020270a:	eb77bd23          	sd	s7,-326(a5) # ffffffffc02155c0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020270e:	00013797          	auipc	a5,0x13
ffffffffc0202712:	eb67ad23          	sw	s6,-326(a5) # ffffffffc02155c8 <free_area+0x10>
    free_page(p);
ffffffffc0202716:	227000ef          	jal	ra,ffffffffc020313c <free_pages>
    free_page(p1);
ffffffffc020271a:	4585                	li	a1,1
ffffffffc020271c:	8556                	mv	a0,s5
ffffffffc020271e:	21f000ef          	jal	ra,ffffffffc020313c <free_pages>
    free_page(p2);
ffffffffc0202722:	4585                	li	a1,1
ffffffffc0202724:	8552                	mv	a0,s4
ffffffffc0202726:	217000ef          	jal	ra,ffffffffc020313c <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020272a:	4515                	li	a0,5
ffffffffc020272c:	189000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc0202730:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202732:	28050363          	beqz	a0,ffffffffc02029b8 <default_check+0x452>
ffffffffc0202736:	651c                	ld	a5,8(a0)
ffffffffc0202738:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc020273a:	8b85                	andi	a5,a5,1
ffffffffc020273c:	54079e63          	bnez	a5,ffffffffc0202c98 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202740:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202742:	00093b03          	ld	s6,0(s2)
ffffffffc0202746:	00893a83          	ld	s5,8(s2)
ffffffffc020274a:	00013797          	auipc	a5,0x13
ffffffffc020274e:	e727b723          	sd	s2,-402(a5) # ffffffffc02155b8 <free_area>
ffffffffc0202752:	00013797          	auipc	a5,0x13
ffffffffc0202756:	e727b723          	sd	s2,-402(a5) # ffffffffc02155c0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc020275a:	15b000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc020275e:	50051d63          	bnez	a0,ffffffffc0202c78 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202762:	08098a13          	addi	s4,s3,128
ffffffffc0202766:	8552                	mv	a0,s4
ffffffffc0202768:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020276a:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020276e:	00013797          	auipc	a5,0x13
ffffffffc0202772:	e407ad23          	sw	zero,-422(a5) # ffffffffc02155c8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202776:	1c7000ef          	jal	ra,ffffffffc020313c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020277a:	4511                	li	a0,4
ffffffffc020277c:	139000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc0202780:	4c051c63          	bnez	a0,ffffffffc0202c58 <default_check+0x6f2>
ffffffffc0202784:	0889b783          	ld	a5,136(s3)
ffffffffc0202788:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020278a:	8b85                	andi	a5,a5,1
ffffffffc020278c:	4a078663          	beqz	a5,ffffffffc0202c38 <default_check+0x6d2>
ffffffffc0202790:	0909a703          	lw	a4,144(s3)
ffffffffc0202794:	478d                	li	a5,3
ffffffffc0202796:	4af71163          	bne	a4,a5,ffffffffc0202c38 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020279a:	450d                	li	a0,3
ffffffffc020279c:	119000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02027a0:	8c2a                	mv	s8,a0
ffffffffc02027a2:	46050b63          	beqz	a0,ffffffffc0202c18 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc02027a6:	4505                	li	a0,1
ffffffffc02027a8:	10d000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02027ac:	44051663          	bnez	a0,ffffffffc0202bf8 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02027b0:	438a1463          	bne	s4,s8,ffffffffc0202bd8 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02027b4:	4585                	li	a1,1
ffffffffc02027b6:	854e                	mv	a0,s3
ffffffffc02027b8:	185000ef          	jal	ra,ffffffffc020313c <free_pages>
    free_pages(p1, 3);
ffffffffc02027bc:	458d                	li	a1,3
ffffffffc02027be:	8552                	mv	a0,s4
ffffffffc02027c0:	17d000ef          	jal	ra,ffffffffc020313c <free_pages>
ffffffffc02027c4:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02027c8:	04098c13          	addi	s8,s3,64
ffffffffc02027cc:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02027ce:	8b85                	andi	a5,a5,1
ffffffffc02027d0:	3e078463          	beqz	a5,ffffffffc0202bb8 <default_check+0x652>
ffffffffc02027d4:	0109a703          	lw	a4,16(s3)
ffffffffc02027d8:	4785                	li	a5,1
ffffffffc02027da:	3cf71f63          	bne	a4,a5,ffffffffc0202bb8 <default_check+0x652>
ffffffffc02027de:	008a3783          	ld	a5,8(s4)
ffffffffc02027e2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02027e4:	8b85                	andi	a5,a5,1
ffffffffc02027e6:	3a078963          	beqz	a5,ffffffffc0202b98 <default_check+0x632>
ffffffffc02027ea:	010a2703          	lw	a4,16(s4)
ffffffffc02027ee:	478d                	li	a5,3
ffffffffc02027f0:	3af71463          	bne	a4,a5,ffffffffc0202b98 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02027f4:	4505                	li	a0,1
ffffffffc02027f6:	0bf000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02027fa:	36a99f63          	bne	s3,a0,ffffffffc0202b78 <default_check+0x612>
    free_page(p0);
ffffffffc02027fe:	4585                	li	a1,1
ffffffffc0202800:	13d000ef          	jal	ra,ffffffffc020313c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202804:	4509                	li	a0,2
ffffffffc0202806:	0af000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc020280a:	34aa1763          	bne	s4,a0,ffffffffc0202b58 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc020280e:	4589                	li	a1,2
ffffffffc0202810:	12d000ef          	jal	ra,ffffffffc020313c <free_pages>
    free_page(p2);
ffffffffc0202814:	4585                	li	a1,1
ffffffffc0202816:	8562                	mv	a0,s8
ffffffffc0202818:	125000ef          	jal	ra,ffffffffc020313c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020281c:	4515                	li	a0,5
ffffffffc020281e:	097000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc0202822:	89aa                	mv	s3,a0
ffffffffc0202824:	48050a63          	beqz	a0,ffffffffc0202cb8 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0202828:	4505                	li	a0,1
ffffffffc020282a:	08b000ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc020282e:	2e051563          	bnez	a0,ffffffffc0202b18 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0202832:	01092783          	lw	a5,16(s2)
ffffffffc0202836:	2c079163          	bnez	a5,ffffffffc0202af8 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020283a:	4595                	li	a1,5
ffffffffc020283c:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020283e:	00013797          	auipc	a5,0x13
ffffffffc0202842:	d977a523          	sw	s7,-630(a5) # ffffffffc02155c8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0202846:	00013797          	auipc	a5,0x13
ffffffffc020284a:	d767b923          	sd	s6,-654(a5) # ffffffffc02155b8 <free_area>
ffffffffc020284e:	00013797          	auipc	a5,0x13
ffffffffc0202852:	d757b923          	sd	s5,-654(a5) # ffffffffc02155c0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0202856:	0e7000ef          	jal	ra,ffffffffc020313c <free_pages>
    return listelm->next;
ffffffffc020285a:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020285e:	01278963          	beq	a5,s2,ffffffffc0202870 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202862:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202866:	679c                	ld	a5,8(a5)
ffffffffc0202868:	34fd                	addiw	s1,s1,-1
ffffffffc020286a:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020286c:	ff279be3          	bne	a5,s2,ffffffffc0202862 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0202870:	26049463          	bnez	s1,ffffffffc0202ad8 <default_check+0x572>
    assert(total == 0);
ffffffffc0202874:	46041263          	bnez	s0,ffffffffc0202cd8 <default_check+0x772>
}
ffffffffc0202878:	60a6                	ld	ra,72(sp)
ffffffffc020287a:	6406                	ld	s0,64(sp)
ffffffffc020287c:	74e2                	ld	s1,56(sp)
ffffffffc020287e:	7942                	ld	s2,48(sp)
ffffffffc0202880:	79a2                	ld	s3,40(sp)
ffffffffc0202882:	7a02                	ld	s4,32(sp)
ffffffffc0202884:	6ae2                	ld	s5,24(sp)
ffffffffc0202886:	6b42                	ld	s6,16(sp)
ffffffffc0202888:	6ba2                	ld	s7,8(sp)
ffffffffc020288a:	6c02                	ld	s8,0(sp)
ffffffffc020288c:	6161                	addi	sp,sp,80
ffffffffc020288e:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202890:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202892:	4401                	li	s0,0
ffffffffc0202894:	4481                	li	s1,0
ffffffffc0202896:	b30d                	j	ffffffffc02025b8 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0202898:	00003697          	auipc	a3,0x3
ffffffffc020289c:	67068693          	addi	a3,a3,1648 # ffffffffc0205f08 <commands+0xf28>
ffffffffc02028a0:	00003617          	auipc	a2,0x3
ffffffffc02028a4:	fa060613          	addi	a2,a2,-96 # ffffffffc0205840 <commands+0x860>
ffffffffc02028a8:	0f000593          	li	a1,240
ffffffffc02028ac:	00004517          	auipc	a0,0x4
ffffffffc02028b0:	98450513          	addi	a0,a0,-1660 # ffffffffc0206230 <commands+0x1250>
ffffffffc02028b4:	923fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02028b8:	00004697          	auipc	a3,0x4
ffffffffc02028bc:	9f068693          	addi	a3,a3,-1552 # ffffffffc02062a8 <commands+0x12c8>
ffffffffc02028c0:	00003617          	auipc	a2,0x3
ffffffffc02028c4:	f8060613          	addi	a2,a2,-128 # ffffffffc0205840 <commands+0x860>
ffffffffc02028c8:	0bd00593          	li	a1,189
ffffffffc02028cc:	00004517          	auipc	a0,0x4
ffffffffc02028d0:	96450513          	addi	a0,a0,-1692 # ffffffffc0206230 <commands+0x1250>
ffffffffc02028d4:	903fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02028d8:	00004697          	auipc	a3,0x4
ffffffffc02028dc:	9f868693          	addi	a3,a3,-1544 # ffffffffc02062d0 <commands+0x12f0>
ffffffffc02028e0:	00003617          	auipc	a2,0x3
ffffffffc02028e4:	f6060613          	addi	a2,a2,-160 # ffffffffc0205840 <commands+0x860>
ffffffffc02028e8:	0be00593          	li	a1,190
ffffffffc02028ec:	00004517          	auipc	a0,0x4
ffffffffc02028f0:	94450513          	addi	a0,a0,-1724 # ffffffffc0206230 <commands+0x1250>
ffffffffc02028f4:	8e3fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02028f8:	00004697          	auipc	a3,0x4
ffffffffc02028fc:	a1868693          	addi	a3,a3,-1512 # ffffffffc0206310 <commands+0x1330>
ffffffffc0202900:	00003617          	auipc	a2,0x3
ffffffffc0202904:	f4060613          	addi	a2,a2,-192 # ffffffffc0205840 <commands+0x860>
ffffffffc0202908:	0c000593          	li	a1,192
ffffffffc020290c:	00004517          	auipc	a0,0x4
ffffffffc0202910:	92450513          	addi	a0,a0,-1756 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202914:	8c3fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202918:	00004697          	auipc	a3,0x4
ffffffffc020291c:	a8068693          	addi	a3,a3,-1408 # ffffffffc0206398 <commands+0x13b8>
ffffffffc0202920:	00003617          	auipc	a2,0x3
ffffffffc0202924:	f2060613          	addi	a2,a2,-224 # ffffffffc0205840 <commands+0x860>
ffffffffc0202928:	0d900593          	li	a1,217
ffffffffc020292c:	00004517          	auipc	a0,0x4
ffffffffc0202930:	90450513          	addi	a0,a0,-1788 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202934:	8a3fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202938:	00004697          	auipc	a3,0x4
ffffffffc020293c:	91068693          	addi	a3,a3,-1776 # ffffffffc0206248 <commands+0x1268>
ffffffffc0202940:	00003617          	auipc	a2,0x3
ffffffffc0202944:	f0060613          	addi	a2,a2,-256 # ffffffffc0205840 <commands+0x860>
ffffffffc0202948:	0d200593          	li	a1,210
ffffffffc020294c:	00004517          	auipc	a0,0x4
ffffffffc0202950:	8e450513          	addi	a0,a0,-1820 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202954:	883fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free == 3);
ffffffffc0202958:	00004697          	auipc	a3,0x4
ffffffffc020295c:	a3068693          	addi	a3,a3,-1488 # ffffffffc0206388 <commands+0x13a8>
ffffffffc0202960:	00003617          	auipc	a2,0x3
ffffffffc0202964:	ee060613          	addi	a2,a2,-288 # ffffffffc0205840 <commands+0x860>
ffffffffc0202968:	0d000593          	li	a1,208
ffffffffc020296c:	00004517          	auipc	a0,0x4
ffffffffc0202970:	8c450513          	addi	a0,a0,-1852 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202974:	863fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202978:	00004697          	auipc	a3,0x4
ffffffffc020297c:	9f868693          	addi	a3,a3,-1544 # ffffffffc0206370 <commands+0x1390>
ffffffffc0202980:	00003617          	auipc	a2,0x3
ffffffffc0202984:	ec060613          	addi	a2,a2,-320 # ffffffffc0205840 <commands+0x860>
ffffffffc0202988:	0cb00593          	li	a1,203
ffffffffc020298c:	00004517          	auipc	a0,0x4
ffffffffc0202990:	8a450513          	addi	a0,a0,-1884 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202994:	843fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202998:	00004697          	auipc	a3,0x4
ffffffffc020299c:	9b868693          	addi	a3,a3,-1608 # ffffffffc0206350 <commands+0x1370>
ffffffffc02029a0:	00003617          	auipc	a2,0x3
ffffffffc02029a4:	ea060613          	addi	a2,a2,-352 # ffffffffc0205840 <commands+0x860>
ffffffffc02029a8:	0c200593          	li	a1,194
ffffffffc02029ac:	00004517          	auipc	a0,0x4
ffffffffc02029b0:	88450513          	addi	a0,a0,-1916 # ffffffffc0206230 <commands+0x1250>
ffffffffc02029b4:	823fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(p0 != NULL);
ffffffffc02029b8:	00004697          	auipc	a3,0x4
ffffffffc02029bc:	a1868693          	addi	a3,a3,-1512 # ffffffffc02063d0 <commands+0x13f0>
ffffffffc02029c0:	00003617          	auipc	a2,0x3
ffffffffc02029c4:	e8060613          	addi	a2,a2,-384 # ffffffffc0205840 <commands+0x860>
ffffffffc02029c8:	0f800593          	li	a1,248
ffffffffc02029cc:	00004517          	auipc	a0,0x4
ffffffffc02029d0:	86450513          	addi	a0,a0,-1948 # ffffffffc0206230 <commands+0x1250>
ffffffffc02029d4:	803fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free == 0);
ffffffffc02029d8:	00003697          	auipc	a3,0x3
ffffffffc02029dc:	6d068693          	addi	a3,a3,1744 # ffffffffc02060a8 <commands+0x10c8>
ffffffffc02029e0:	00003617          	auipc	a2,0x3
ffffffffc02029e4:	e6060613          	addi	a2,a2,-416 # ffffffffc0205840 <commands+0x860>
ffffffffc02029e8:	0df00593          	li	a1,223
ffffffffc02029ec:	00004517          	auipc	a0,0x4
ffffffffc02029f0:	84450513          	addi	a0,a0,-1980 # ffffffffc0206230 <commands+0x1250>
ffffffffc02029f4:	fe2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02029f8:	00004697          	auipc	a3,0x4
ffffffffc02029fc:	97868693          	addi	a3,a3,-1672 # ffffffffc0206370 <commands+0x1390>
ffffffffc0202a00:	00003617          	auipc	a2,0x3
ffffffffc0202a04:	e4060613          	addi	a2,a2,-448 # ffffffffc0205840 <commands+0x860>
ffffffffc0202a08:	0dd00593          	li	a1,221
ffffffffc0202a0c:	00004517          	auipc	a0,0x4
ffffffffc0202a10:	82450513          	addi	a0,a0,-2012 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202a14:	fc2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202a18:	00004697          	auipc	a3,0x4
ffffffffc0202a1c:	99868693          	addi	a3,a3,-1640 # ffffffffc02063b0 <commands+0x13d0>
ffffffffc0202a20:	00003617          	auipc	a2,0x3
ffffffffc0202a24:	e2060613          	addi	a2,a2,-480 # ffffffffc0205840 <commands+0x860>
ffffffffc0202a28:	0dc00593          	li	a1,220
ffffffffc0202a2c:	00004517          	auipc	a0,0x4
ffffffffc0202a30:	80450513          	addi	a0,a0,-2044 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202a34:	fa2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202a38:	00004697          	auipc	a3,0x4
ffffffffc0202a3c:	81068693          	addi	a3,a3,-2032 # ffffffffc0206248 <commands+0x1268>
ffffffffc0202a40:	00003617          	auipc	a2,0x3
ffffffffc0202a44:	e0060613          	addi	a2,a2,-512 # ffffffffc0205840 <commands+0x860>
ffffffffc0202a48:	0b900593          	li	a1,185
ffffffffc0202a4c:	00003517          	auipc	a0,0x3
ffffffffc0202a50:	7e450513          	addi	a0,a0,2020 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202a54:	f82fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202a58:	00004697          	auipc	a3,0x4
ffffffffc0202a5c:	91868693          	addi	a3,a3,-1768 # ffffffffc0206370 <commands+0x1390>
ffffffffc0202a60:	00003617          	auipc	a2,0x3
ffffffffc0202a64:	de060613          	addi	a2,a2,-544 # ffffffffc0205840 <commands+0x860>
ffffffffc0202a68:	0d600593          	li	a1,214
ffffffffc0202a6c:	00003517          	auipc	a0,0x3
ffffffffc0202a70:	7c450513          	addi	a0,a0,1988 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202a74:	f62fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202a78:	00004697          	auipc	a3,0x4
ffffffffc0202a7c:	81068693          	addi	a3,a3,-2032 # ffffffffc0206288 <commands+0x12a8>
ffffffffc0202a80:	00003617          	auipc	a2,0x3
ffffffffc0202a84:	dc060613          	addi	a2,a2,-576 # ffffffffc0205840 <commands+0x860>
ffffffffc0202a88:	0d400593          	li	a1,212
ffffffffc0202a8c:	00003517          	auipc	a0,0x3
ffffffffc0202a90:	7a450513          	addi	a0,a0,1956 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202a94:	f42fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202a98:	00003697          	auipc	a3,0x3
ffffffffc0202a9c:	7d068693          	addi	a3,a3,2000 # ffffffffc0206268 <commands+0x1288>
ffffffffc0202aa0:	00003617          	auipc	a2,0x3
ffffffffc0202aa4:	da060613          	addi	a2,a2,-608 # ffffffffc0205840 <commands+0x860>
ffffffffc0202aa8:	0d300593          	li	a1,211
ffffffffc0202aac:	00003517          	auipc	a0,0x3
ffffffffc0202ab0:	78450513          	addi	a0,a0,1924 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202ab4:	f22fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202ab8:	00003697          	auipc	a3,0x3
ffffffffc0202abc:	7d068693          	addi	a3,a3,2000 # ffffffffc0206288 <commands+0x12a8>
ffffffffc0202ac0:	00003617          	auipc	a2,0x3
ffffffffc0202ac4:	d8060613          	addi	a2,a2,-640 # ffffffffc0205840 <commands+0x860>
ffffffffc0202ac8:	0bb00593          	li	a1,187
ffffffffc0202acc:	00003517          	auipc	a0,0x3
ffffffffc0202ad0:	76450513          	addi	a0,a0,1892 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202ad4:	f02fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(count == 0);
ffffffffc0202ad8:	00004697          	auipc	a3,0x4
ffffffffc0202adc:	a4868693          	addi	a3,a3,-1464 # ffffffffc0206520 <commands+0x1540>
ffffffffc0202ae0:	00003617          	auipc	a2,0x3
ffffffffc0202ae4:	d6060613          	addi	a2,a2,-672 # ffffffffc0205840 <commands+0x860>
ffffffffc0202ae8:	12500593          	li	a1,293
ffffffffc0202aec:	00003517          	auipc	a0,0x3
ffffffffc0202af0:	74450513          	addi	a0,a0,1860 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202af4:	ee2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free == 0);
ffffffffc0202af8:	00003697          	auipc	a3,0x3
ffffffffc0202afc:	5b068693          	addi	a3,a3,1456 # ffffffffc02060a8 <commands+0x10c8>
ffffffffc0202b00:	00003617          	auipc	a2,0x3
ffffffffc0202b04:	d4060613          	addi	a2,a2,-704 # ffffffffc0205840 <commands+0x860>
ffffffffc0202b08:	11a00593          	li	a1,282
ffffffffc0202b0c:	00003517          	auipc	a0,0x3
ffffffffc0202b10:	72450513          	addi	a0,a0,1828 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202b14:	ec2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202b18:	00004697          	auipc	a3,0x4
ffffffffc0202b1c:	85868693          	addi	a3,a3,-1960 # ffffffffc0206370 <commands+0x1390>
ffffffffc0202b20:	00003617          	auipc	a2,0x3
ffffffffc0202b24:	d2060613          	addi	a2,a2,-736 # ffffffffc0205840 <commands+0x860>
ffffffffc0202b28:	11800593          	li	a1,280
ffffffffc0202b2c:	00003517          	auipc	a0,0x3
ffffffffc0202b30:	70450513          	addi	a0,a0,1796 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202b34:	ea2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202b38:	00003697          	auipc	a3,0x3
ffffffffc0202b3c:	7f868693          	addi	a3,a3,2040 # ffffffffc0206330 <commands+0x1350>
ffffffffc0202b40:	00003617          	auipc	a2,0x3
ffffffffc0202b44:	d0060613          	addi	a2,a2,-768 # ffffffffc0205840 <commands+0x860>
ffffffffc0202b48:	0c100593          	li	a1,193
ffffffffc0202b4c:	00003517          	auipc	a0,0x3
ffffffffc0202b50:	6e450513          	addi	a0,a0,1764 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202b54:	e82fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202b58:	00004697          	auipc	a3,0x4
ffffffffc0202b5c:	98868693          	addi	a3,a3,-1656 # ffffffffc02064e0 <commands+0x1500>
ffffffffc0202b60:	00003617          	auipc	a2,0x3
ffffffffc0202b64:	ce060613          	addi	a2,a2,-800 # ffffffffc0205840 <commands+0x860>
ffffffffc0202b68:	11200593          	li	a1,274
ffffffffc0202b6c:	00003517          	auipc	a0,0x3
ffffffffc0202b70:	6c450513          	addi	a0,a0,1732 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202b74:	e62fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202b78:	00004697          	auipc	a3,0x4
ffffffffc0202b7c:	94868693          	addi	a3,a3,-1720 # ffffffffc02064c0 <commands+0x14e0>
ffffffffc0202b80:	00003617          	auipc	a2,0x3
ffffffffc0202b84:	cc060613          	addi	a2,a2,-832 # ffffffffc0205840 <commands+0x860>
ffffffffc0202b88:	11000593          	li	a1,272
ffffffffc0202b8c:	00003517          	auipc	a0,0x3
ffffffffc0202b90:	6a450513          	addi	a0,a0,1700 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202b94:	e42fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202b98:	00004697          	auipc	a3,0x4
ffffffffc0202b9c:	90068693          	addi	a3,a3,-1792 # ffffffffc0206498 <commands+0x14b8>
ffffffffc0202ba0:	00003617          	auipc	a2,0x3
ffffffffc0202ba4:	ca060613          	addi	a2,a2,-864 # ffffffffc0205840 <commands+0x860>
ffffffffc0202ba8:	10e00593          	li	a1,270
ffffffffc0202bac:	00003517          	auipc	a0,0x3
ffffffffc0202bb0:	68450513          	addi	a0,a0,1668 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202bb4:	e22fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202bb8:	00004697          	auipc	a3,0x4
ffffffffc0202bbc:	8b868693          	addi	a3,a3,-1864 # ffffffffc0206470 <commands+0x1490>
ffffffffc0202bc0:	00003617          	auipc	a2,0x3
ffffffffc0202bc4:	c8060613          	addi	a2,a2,-896 # ffffffffc0205840 <commands+0x860>
ffffffffc0202bc8:	10d00593          	li	a1,269
ffffffffc0202bcc:	00003517          	auipc	a0,0x3
ffffffffc0202bd0:	66450513          	addi	a0,a0,1636 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202bd4:	e02fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202bd8:	00004697          	auipc	a3,0x4
ffffffffc0202bdc:	88868693          	addi	a3,a3,-1912 # ffffffffc0206460 <commands+0x1480>
ffffffffc0202be0:	00003617          	auipc	a2,0x3
ffffffffc0202be4:	c6060613          	addi	a2,a2,-928 # ffffffffc0205840 <commands+0x860>
ffffffffc0202be8:	10800593          	li	a1,264
ffffffffc0202bec:	00003517          	auipc	a0,0x3
ffffffffc0202bf0:	64450513          	addi	a0,a0,1604 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202bf4:	de2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202bf8:	00003697          	auipc	a3,0x3
ffffffffc0202bfc:	77868693          	addi	a3,a3,1912 # ffffffffc0206370 <commands+0x1390>
ffffffffc0202c00:	00003617          	auipc	a2,0x3
ffffffffc0202c04:	c4060613          	addi	a2,a2,-960 # ffffffffc0205840 <commands+0x860>
ffffffffc0202c08:	10700593          	li	a1,263
ffffffffc0202c0c:	00003517          	auipc	a0,0x3
ffffffffc0202c10:	62450513          	addi	a0,a0,1572 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202c14:	dc2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202c18:	00004697          	auipc	a3,0x4
ffffffffc0202c1c:	82868693          	addi	a3,a3,-2008 # ffffffffc0206440 <commands+0x1460>
ffffffffc0202c20:	00003617          	auipc	a2,0x3
ffffffffc0202c24:	c2060613          	addi	a2,a2,-992 # ffffffffc0205840 <commands+0x860>
ffffffffc0202c28:	10600593          	li	a1,262
ffffffffc0202c2c:	00003517          	auipc	a0,0x3
ffffffffc0202c30:	60450513          	addi	a0,a0,1540 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202c34:	da2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202c38:	00003697          	auipc	a3,0x3
ffffffffc0202c3c:	7d868693          	addi	a3,a3,2008 # ffffffffc0206410 <commands+0x1430>
ffffffffc0202c40:	00003617          	auipc	a2,0x3
ffffffffc0202c44:	c0060613          	addi	a2,a2,-1024 # ffffffffc0205840 <commands+0x860>
ffffffffc0202c48:	10500593          	li	a1,261
ffffffffc0202c4c:	00003517          	auipc	a0,0x3
ffffffffc0202c50:	5e450513          	addi	a0,a0,1508 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202c54:	d82fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202c58:	00003697          	auipc	a3,0x3
ffffffffc0202c5c:	7a068693          	addi	a3,a3,1952 # ffffffffc02063f8 <commands+0x1418>
ffffffffc0202c60:	00003617          	auipc	a2,0x3
ffffffffc0202c64:	be060613          	addi	a2,a2,-1056 # ffffffffc0205840 <commands+0x860>
ffffffffc0202c68:	10400593          	li	a1,260
ffffffffc0202c6c:	00003517          	auipc	a0,0x3
ffffffffc0202c70:	5c450513          	addi	a0,a0,1476 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202c74:	d62fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202c78:	00003697          	auipc	a3,0x3
ffffffffc0202c7c:	6f868693          	addi	a3,a3,1784 # ffffffffc0206370 <commands+0x1390>
ffffffffc0202c80:	00003617          	auipc	a2,0x3
ffffffffc0202c84:	bc060613          	addi	a2,a2,-1088 # ffffffffc0205840 <commands+0x860>
ffffffffc0202c88:	0fe00593          	li	a1,254
ffffffffc0202c8c:	00003517          	auipc	a0,0x3
ffffffffc0202c90:	5a450513          	addi	a0,a0,1444 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202c94:	d42fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202c98:	00003697          	auipc	a3,0x3
ffffffffc0202c9c:	74868693          	addi	a3,a3,1864 # ffffffffc02063e0 <commands+0x1400>
ffffffffc0202ca0:	00003617          	auipc	a2,0x3
ffffffffc0202ca4:	ba060613          	addi	a2,a2,-1120 # ffffffffc0205840 <commands+0x860>
ffffffffc0202ca8:	0f900593          	li	a1,249
ffffffffc0202cac:	00003517          	auipc	a0,0x3
ffffffffc0202cb0:	58450513          	addi	a0,a0,1412 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202cb4:	d22fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202cb8:	00004697          	auipc	a3,0x4
ffffffffc0202cbc:	84868693          	addi	a3,a3,-1976 # ffffffffc0206500 <commands+0x1520>
ffffffffc0202cc0:	00003617          	auipc	a2,0x3
ffffffffc0202cc4:	b8060613          	addi	a2,a2,-1152 # ffffffffc0205840 <commands+0x860>
ffffffffc0202cc8:	11700593          	li	a1,279
ffffffffc0202ccc:	00003517          	auipc	a0,0x3
ffffffffc0202cd0:	56450513          	addi	a0,a0,1380 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202cd4:	d02fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(total == 0);
ffffffffc0202cd8:	00004697          	auipc	a3,0x4
ffffffffc0202cdc:	85868693          	addi	a3,a3,-1960 # ffffffffc0206530 <commands+0x1550>
ffffffffc0202ce0:	00003617          	auipc	a2,0x3
ffffffffc0202ce4:	b6060613          	addi	a2,a2,-1184 # ffffffffc0205840 <commands+0x860>
ffffffffc0202ce8:	12600593          	li	a1,294
ffffffffc0202cec:	00003517          	auipc	a0,0x3
ffffffffc0202cf0:	54450513          	addi	a0,a0,1348 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202cf4:	ce2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(total == nr_free_pages());
ffffffffc0202cf8:	00003697          	auipc	a3,0x3
ffffffffc0202cfc:	22068693          	addi	a3,a3,544 # ffffffffc0205f18 <commands+0xf38>
ffffffffc0202d00:	00003617          	auipc	a2,0x3
ffffffffc0202d04:	b4060613          	addi	a2,a2,-1216 # ffffffffc0205840 <commands+0x860>
ffffffffc0202d08:	0f300593          	li	a1,243
ffffffffc0202d0c:	00003517          	auipc	a0,0x3
ffffffffc0202d10:	52450513          	addi	a0,a0,1316 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202d14:	cc2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202d18:	00003697          	auipc	a3,0x3
ffffffffc0202d1c:	55068693          	addi	a3,a3,1360 # ffffffffc0206268 <commands+0x1288>
ffffffffc0202d20:	00003617          	auipc	a2,0x3
ffffffffc0202d24:	b2060613          	addi	a2,a2,-1248 # ffffffffc0205840 <commands+0x860>
ffffffffc0202d28:	0ba00593          	li	a1,186
ffffffffc0202d2c:	00003517          	auipc	a0,0x3
ffffffffc0202d30:	50450513          	addi	a0,a0,1284 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202d34:	ca2fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0202d38 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202d38:	1141                	addi	sp,sp,-16
ffffffffc0202d3a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202d3c:	16058e63          	beqz	a1,ffffffffc0202eb8 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0202d40:	00659693          	slli	a3,a1,0x6
ffffffffc0202d44:	96aa                	add	a3,a3,a0
ffffffffc0202d46:	02d50d63          	beq	a0,a3,ffffffffc0202d80 <default_free_pages+0x48>
ffffffffc0202d4a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202d4c:	8b85                	andi	a5,a5,1
ffffffffc0202d4e:	14079563          	bnez	a5,ffffffffc0202e98 <default_free_pages+0x160>
ffffffffc0202d52:	651c                	ld	a5,8(a0)
ffffffffc0202d54:	8385                	srli	a5,a5,0x1
ffffffffc0202d56:	8b85                	andi	a5,a5,1
ffffffffc0202d58:	14079063          	bnez	a5,ffffffffc0202e98 <default_free_pages+0x160>
ffffffffc0202d5c:	87aa                	mv	a5,a0
ffffffffc0202d5e:	a809                	j	ffffffffc0202d70 <default_free_pages+0x38>
ffffffffc0202d60:	6798                	ld	a4,8(a5)
ffffffffc0202d62:	8b05                	andi	a4,a4,1
ffffffffc0202d64:	12071a63          	bnez	a4,ffffffffc0202e98 <default_free_pages+0x160>
ffffffffc0202d68:	6798                	ld	a4,8(a5)
ffffffffc0202d6a:	8b09                	andi	a4,a4,2
ffffffffc0202d6c:	12071663          	bnez	a4,ffffffffc0202e98 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0202d70:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0202d74:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202d78:	04078793          	addi	a5,a5,64
ffffffffc0202d7c:	fed792e3          	bne	a5,a3,ffffffffc0202d60 <default_free_pages+0x28>
    base->property = n;
ffffffffc0202d80:	2581                	sext.w	a1,a1
ffffffffc0202d82:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0202d84:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202d88:	4789                	li	a5,2
ffffffffc0202d8a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0202d8e:	00013697          	auipc	a3,0x13
ffffffffc0202d92:	82a68693          	addi	a3,a3,-2006 # ffffffffc02155b8 <free_area>
ffffffffc0202d96:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202d98:	669c                	ld	a5,8(a3)
ffffffffc0202d9a:	9db9                	addw	a1,a1,a4
ffffffffc0202d9c:	00013717          	auipc	a4,0x13
ffffffffc0202da0:	82b72623          	sw	a1,-2004(a4) # ffffffffc02155c8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0202da4:	0cd78163          	beq	a5,a3,ffffffffc0202e66 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0202da8:	fe878713          	addi	a4,a5,-24
ffffffffc0202dac:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202dae:	4801                	li	a6,0
ffffffffc0202db0:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0202db4:	00e56a63          	bltu	a0,a4,ffffffffc0202dc8 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0202db8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202dba:	04d70f63          	beq	a4,a3,ffffffffc0202e18 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202dbe:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202dc0:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0202dc4:	fee57ae3          	bleu	a4,a0,ffffffffc0202db8 <default_free_pages+0x80>
ffffffffc0202dc8:	00080663          	beqz	a6,ffffffffc0202dd4 <default_free_pages+0x9c>
ffffffffc0202dcc:	00012817          	auipc	a6,0x12
ffffffffc0202dd0:	7eb83623          	sd	a1,2028(a6) # ffffffffc02155b8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202dd4:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202dd6:	e390                	sd	a2,0(a5)
ffffffffc0202dd8:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0202dda:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202ddc:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0202dde:	06d58a63          	beq	a1,a3,ffffffffc0202e52 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0202de2:	ff85a603          	lw	a2,-8(a1) # ff8 <BASE_ADDRESS-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc0202de6:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0202dea:	02061793          	slli	a5,a2,0x20
ffffffffc0202dee:	83e9                	srli	a5,a5,0x1a
ffffffffc0202df0:	97ba                	add	a5,a5,a4
ffffffffc0202df2:	04f51b63          	bne	a0,a5,ffffffffc0202e48 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0202df6:	491c                	lw	a5,16(a0)
ffffffffc0202df8:	9e3d                	addw	a2,a2,a5
ffffffffc0202dfa:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202dfe:	57f5                	li	a5,-3
ffffffffc0202e00:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202e04:	01853803          	ld	a6,24(a0)
ffffffffc0202e08:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0202e0a:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc0202e0c:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0202e10:	659c                	ld	a5,8(a1)
ffffffffc0202e12:	01063023          	sd	a6,0(a2)
ffffffffc0202e16:	a815                	j	ffffffffc0202e4a <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0202e18:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202e1a:	f114                	sd	a3,32(a0)
ffffffffc0202e1c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202e1e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0202e20:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202e22:	00d70563          	beq	a4,a3,ffffffffc0202e2c <default_free_pages+0xf4>
ffffffffc0202e26:	4805                	li	a6,1
ffffffffc0202e28:	87ba                	mv	a5,a4
ffffffffc0202e2a:	bf59                	j	ffffffffc0202dc0 <default_free_pages+0x88>
ffffffffc0202e2c:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0202e2e:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0202e30:	00d78d63          	beq	a5,a3,ffffffffc0202e4a <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0202e34:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0202e38:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0202e3c:	02061793          	slli	a5,a2,0x20
ffffffffc0202e40:	83e9                	srli	a5,a5,0x1a
ffffffffc0202e42:	97ba                	add	a5,a5,a4
ffffffffc0202e44:	faf509e3          	beq	a0,a5,ffffffffc0202df6 <default_free_pages+0xbe>
ffffffffc0202e48:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0202e4a:	fe878713          	addi	a4,a5,-24
ffffffffc0202e4e:	00d78963          	beq	a5,a3,ffffffffc0202e60 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0202e52:	4910                	lw	a2,16(a0)
ffffffffc0202e54:	02061693          	slli	a3,a2,0x20
ffffffffc0202e58:	82e9                	srli	a3,a3,0x1a
ffffffffc0202e5a:	96aa                	add	a3,a3,a0
ffffffffc0202e5c:	00d70e63          	beq	a4,a3,ffffffffc0202e78 <default_free_pages+0x140>
}
ffffffffc0202e60:	60a2                	ld	ra,8(sp)
ffffffffc0202e62:	0141                	addi	sp,sp,16
ffffffffc0202e64:	8082                	ret
ffffffffc0202e66:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0202e68:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0202e6c:	e398                	sd	a4,0(a5)
ffffffffc0202e6e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0202e70:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202e72:	ed1c                	sd	a5,24(a0)
}
ffffffffc0202e74:	0141                	addi	sp,sp,16
ffffffffc0202e76:	8082                	ret
            base->property += p->property;
ffffffffc0202e78:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202e7c:	ff078693          	addi	a3,a5,-16
ffffffffc0202e80:	9e39                	addw	a2,a2,a4
ffffffffc0202e82:	c910                	sw	a2,16(a0)
ffffffffc0202e84:	5775                	li	a4,-3
ffffffffc0202e86:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202e8a:	6398                	ld	a4,0(a5)
ffffffffc0202e8c:	679c                	ld	a5,8(a5)
}
ffffffffc0202e8e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202e90:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202e92:	e398                	sd	a4,0(a5)
ffffffffc0202e94:	0141                	addi	sp,sp,16
ffffffffc0202e96:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202e98:	00003697          	auipc	a3,0x3
ffffffffc0202e9c:	6a868693          	addi	a3,a3,1704 # ffffffffc0206540 <commands+0x1560>
ffffffffc0202ea0:	00003617          	auipc	a2,0x3
ffffffffc0202ea4:	9a060613          	addi	a2,a2,-1632 # ffffffffc0205840 <commands+0x860>
ffffffffc0202ea8:	08300593          	li	a1,131
ffffffffc0202eac:	00003517          	auipc	a0,0x3
ffffffffc0202eb0:	38450513          	addi	a0,a0,900 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202eb4:	b22fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(n > 0);
ffffffffc0202eb8:	00003697          	auipc	a3,0x3
ffffffffc0202ebc:	6b068693          	addi	a3,a3,1712 # ffffffffc0206568 <commands+0x1588>
ffffffffc0202ec0:	00003617          	auipc	a2,0x3
ffffffffc0202ec4:	98060613          	addi	a2,a2,-1664 # ffffffffc0205840 <commands+0x860>
ffffffffc0202ec8:	08000593          	li	a1,128
ffffffffc0202ecc:	00003517          	auipc	a0,0x3
ffffffffc0202ed0:	36450513          	addi	a0,a0,868 # ffffffffc0206230 <commands+0x1250>
ffffffffc0202ed4:	b02fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0202ed8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202ed8:	c959                	beqz	a0,ffffffffc0202f6e <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0202eda:	00012597          	auipc	a1,0x12
ffffffffc0202ede:	6de58593          	addi	a1,a1,1758 # ffffffffc02155b8 <free_area>
ffffffffc0202ee2:	0105a803          	lw	a6,16(a1)
ffffffffc0202ee6:	862a                	mv	a2,a0
ffffffffc0202ee8:	02081793          	slli	a5,a6,0x20
ffffffffc0202eec:	9381                	srli	a5,a5,0x20
ffffffffc0202eee:	00a7ee63          	bltu	a5,a0,ffffffffc0202f0a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0202ef2:	87ae                	mv	a5,a1
ffffffffc0202ef4:	a801                	j	ffffffffc0202f04 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0202ef6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202efa:	02071693          	slli	a3,a4,0x20
ffffffffc0202efe:	9281                	srli	a3,a3,0x20
ffffffffc0202f00:	00c6f763          	bleu	a2,a3,ffffffffc0202f0e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0202f04:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202f06:	feb798e3          	bne	a5,a1,ffffffffc0202ef6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0202f0a:	4501                	li	a0,0
}
ffffffffc0202f0c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0202f0e:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0202f12:	dd6d                	beqz	a0,ffffffffc0202f0c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0202f14:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202f18:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0202f1c:	00060e1b          	sext.w	t3,a2
ffffffffc0202f20:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0202f24:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0202f28:	02d67863          	bleu	a3,a2,ffffffffc0202f58 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0202f2c:	061a                	slli	a2,a2,0x6
ffffffffc0202f2e:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0202f30:	41c7073b          	subw	a4,a4,t3
ffffffffc0202f34:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202f36:	00860693          	addi	a3,a2,8
ffffffffc0202f3a:	4709                	li	a4,2
ffffffffc0202f3c:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202f40:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202f44:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0202f48:	0105a803          	lw	a6,16(a1)
ffffffffc0202f4c:	e314                	sd	a3,0(a4)
ffffffffc0202f4e:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0202f52:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0202f54:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0202f58:	41c8083b          	subw	a6,a6,t3
ffffffffc0202f5c:	00012717          	auipc	a4,0x12
ffffffffc0202f60:	67072623          	sw	a6,1644(a4) # ffffffffc02155c8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202f64:	5775                	li	a4,-3
ffffffffc0202f66:	17c1                	addi	a5,a5,-16
ffffffffc0202f68:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0202f6c:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202f6e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202f70:	00003697          	auipc	a3,0x3
ffffffffc0202f74:	5f868693          	addi	a3,a3,1528 # ffffffffc0206568 <commands+0x1588>
ffffffffc0202f78:	00003617          	auipc	a2,0x3
ffffffffc0202f7c:	8c860613          	addi	a2,a2,-1848 # ffffffffc0205840 <commands+0x860>
ffffffffc0202f80:	06200593          	li	a1,98
ffffffffc0202f84:	00003517          	auipc	a0,0x3
ffffffffc0202f88:	2ac50513          	addi	a0,a0,684 # ffffffffc0206230 <commands+0x1250>
default_alloc_pages(size_t n) {
ffffffffc0202f8c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202f8e:	a48fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0202f92 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0202f92:	1141                	addi	sp,sp,-16
ffffffffc0202f94:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202f96:	c1ed                	beqz	a1,ffffffffc0203078 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0202f98:	00659693          	slli	a3,a1,0x6
ffffffffc0202f9c:	96aa                	add	a3,a3,a0
ffffffffc0202f9e:	02d50463          	beq	a0,a3,ffffffffc0202fc6 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202fa2:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0202fa4:	87aa                	mv	a5,a0
ffffffffc0202fa6:	8b05                	andi	a4,a4,1
ffffffffc0202fa8:	e709                	bnez	a4,ffffffffc0202fb2 <default_init_memmap+0x20>
ffffffffc0202faa:	a07d                	j	ffffffffc0203058 <default_init_memmap+0xc6>
ffffffffc0202fac:	6798                	ld	a4,8(a5)
ffffffffc0202fae:	8b05                	andi	a4,a4,1
ffffffffc0202fb0:	c745                	beqz	a4,ffffffffc0203058 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0202fb2:	0007a823          	sw	zero,16(a5)
ffffffffc0202fb6:	0007b423          	sd	zero,8(a5)
ffffffffc0202fba:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202fbe:	04078793          	addi	a5,a5,64
ffffffffc0202fc2:	fed795e3          	bne	a5,a3,ffffffffc0202fac <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0202fc6:	2581                	sext.w	a1,a1
ffffffffc0202fc8:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202fca:	4789                	li	a5,2
ffffffffc0202fcc:	00850713          	addi	a4,a0,8
ffffffffc0202fd0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202fd4:	00012697          	auipc	a3,0x12
ffffffffc0202fd8:	5e468693          	addi	a3,a3,1508 # ffffffffc02155b8 <free_area>
ffffffffc0202fdc:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202fde:	669c                	ld	a5,8(a3)
ffffffffc0202fe0:	9db9                	addw	a1,a1,a4
ffffffffc0202fe2:	00012717          	auipc	a4,0x12
ffffffffc0202fe6:	5eb72323          	sw	a1,1510(a4) # ffffffffc02155c8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0202fea:	04d78a63          	beq	a5,a3,ffffffffc020303e <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0202fee:	fe878713          	addi	a4,a5,-24
ffffffffc0202ff2:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202ff4:	4801                	li	a6,0
ffffffffc0202ff6:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0202ffa:	00e56a63          	bltu	a0,a4,ffffffffc020300e <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0202ffe:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203000:	02d70563          	beq	a4,a3,ffffffffc020302a <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203004:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203006:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020300a:	fee57ae3          	bleu	a4,a0,ffffffffc0202ffe <default_init_memmap+0x6c>
ffffffffc020300e:	00080663          	beqz	a6,ffffffffc020301a <default_init_memmap+0x88>
ffffffffc0203012:	00012717          	auipc	a4,0x12
ffffffffc0203016:	5ab73323          	sd	a1,1446(a4) # ffffffffc02155b8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020301a:	6398                	ld	a4,0(a5)
}
ffffffffc020301c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020301e:	e390                	sd	a2,0(a5)
ffffffffc0203020:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203022:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203024:	ed18                	sd	a4,24(a0)
ffffffffc0203026:	0141                	addi	sp,sp,16
ffffffffc0203028:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020302a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020302c:	f114                	sd	a3,32(a0)
ffffffffc020302e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203030:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0203032:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203034:	00d70e63          	beq	a4,a3,ffffffffc0203050 <default_init_memmap+0xbe>
ffffffffc0203038:	4805                	li	a6,1
ffffffffc020303a:	87ba                	mv	a5,a4
ffffffffc020303c:	b7e9                	j	ffffffffc0203006 <default_init_memmap+0x74>
}
ffffffffc020303e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203040:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0203044:	e398                	sd	a4,0(a5)
ffffffffc0203046:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203048:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020304a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020304c:	0141                	addi	sp,sp,16
ffffffffc020304e:	8082                	ret
ffffffffc0203050:	60a2                	ld	ra,8(sp)
ffffffffc0203052:	e290                	sd	a2,0(a3)
ffffffffc0203054:	0141                	addi	sp,sp,16
ffffffffc0203056:	8082                	ret
        assert(PageReserved(p));
ffffffffc0203058:	00003697          	auipc	a3,0x3
ffffffffc020305c:	51868693          	addi	a3,a3,1304 # ffffffffc0206570 <commands+0x1590>
ffffffffc0203060:	00002617          	auipc	a2,0x2
ffffffffc0203064:	7e060613          	addi	a2,a2,2016 # ffffffffc0205840 <commands+0x860>
ffffffffc0203068:	04900593          	li	a1,73
ffffffffc020306c:	00003517          	auipc	a0,0x3
ffffffffc0203070:	1c450513          	addi	a0,a0,452 # ffffffffc0206230 <commands+0x1250>
ffffffffc0203074:	962fd0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(n > 0);
ffffffffc0203078:	00003697          	auipc	a3,0x3
ffffffffc020307c:	4f068693          	addi	a3,a3,1264 # ffffffffc0206568 <commands+0x1588>
ffffffffc0203080:	00002617          	auipc	a2,0x2
ffffffffc0203084:	7c060613          	addi	a2,a2,1984 # ffffffffc0205840 <commands+0x860>
ffffffffc0203088:	04600593          	li	a1,70
ffffffffc020308c:	00003517          	auipc	a0,0x3
ffffffffc0203090:	1a450513          	addi	a0,a0,420 # ffffffffc0206230 <commands+0x1250>
ffffffffc0203094:	942fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0203098 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0203098:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020309a:	00003617          	auipc	a2,0x3
ffffffffc020309e:	a9660613          	addi	a2,a2,-1386 # ffffffffc0205b30 <commands+0xb50>
ffffffffc02030a2:	06200593          	li	a1,98
ffffffffc02030a6:	00003517          	auipc	a0,0x3
ffffffffc02030aa:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0205b50 <commands+0xb70>
pa2page(uintptr_t pa) {
ffffffffc02030ae:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02030b0:	926fd0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02030b4 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02030b4:	715d                	addi	sp,sp,-80
ffffffffc02030b6:	e0a2                	sd	s0,64(sp)
ffffffffc02030b8:	fc26                	sd	s1,56(sp)
ffffffffc02030ba:	f84a                	sd	s2,48(sp)
ffffffffc02030bc:	f44e                	sd	s3,40(sp)
ffffffffc02030be:	f052                	sd	s4,32(sp)
ffffffffc02030c0:	ec56                	sd	s5,24(sp)
ffffffffc02030c2:	e486                	sd	ra,72(sp)
ffffffffc02030c4:	842a                	mv	s0,a0
ffffffffc02030c6:	00012497          	auipc	s1,0x12
ffffffffc02030ca:	50a48493          	addi	s1,s1,1290 # ffffffffc02155d0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02030ce:	4985                	li	s3,1
ffffffffc02030d0:	00012a17          	auipc	s4,0x12
ffffffffc02030d4:	3c8a0a13          	addi	s4,s4,968 # ffffffffc0215498 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02030d8:	0005091b          	sext.w	s2,a0
ffffffffc02030dc:	00012a97          	auipc	s5,0x12
ffffffffc02030e0:	3fca8a93          	addi	s5,s5,1020 # ffffffffc02154d8 <check_mm_struct>
ffffffffc02030e4:	a00d                	j	ffffffffc0203106 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc02030e6:	609c                	ld	a5,0(s1)
ffffffffc02030e8:	6f9c                	ld	a5,24(a5)
ffffffffc02030ea:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc02030ec:	4601                	li	a2,0
ffffffffc02030ee:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02030f0:	ed0d                	bnez	a0,ffffffffc020312a <alloc_pages+0x76>
ffffffffc02030f2:	0289ec63          	bltu	s3,s0,ffffffffc020312a <alloc_pages+0x76>
ffffffffc02030f6:	000a2783          	lw	a5,0(s4)
ffffffffc02030fa:	2781                	sext.w	a5,a5
ffffffffc02030fc:	c79d                	beqz	a5,ffffffffc020312a <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc02030fe:	000ab503          	ld	a0,0(s5)
ffffffffc0203102:	abaff0ef          	jal	ra,ffffffffc02023bc <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203106:	100027f3          	csrr	a5,sstatus
ffffffffc020310a:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc020310c:	8522                	mv	a0,s0
ffffffffc020310e:	dfe1                	beqz	a5,ffffffffc02030e6 <alloc_pages+0x32>
        intr_disable();
ffffffffc0203110:	ccafd0ef          	jal	ra,ffffffffc02005da <intr_disable>
ffffffffc0203114:	609c                	ld	a5,0(s1)
ffffffffc0203116:	8522                	mv	a0,s0
ffffffffc0203118:	6f9c                	ld	a5,24(a5)
ffffffffc020311a:	9782                	jalr	a5
ffffffffc020311c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020311e:	cb6fd0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
ffffffffc0203122:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0203124:	4601                	li	a2,0
ffffffffc0203126:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203128:	d569                	beqz	a0,ffffffffc02030f2 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020312a:	60a6                	ld	ra,72(sp)
ffffffffc020312c:	6406                	ld	s0,64(sp)
ffffffffc020312e:	74e2                	ld	s1,56(sp)
ffffffffc0203130:	7942                	ld	s2,48(sp)
ffffffffc0203132:	79a2                	ld	s3,40(sp)
ffffffffc0203134:	7a02                	ld	s4,32(sp)
ffffffffc0203136:	6ae2                	ld	s5,24(sp)
ffffffffc0203138:	6161                	addi	sp,sp,80
ffffffffc020313a:	8082                	ret

ffffffffc020313c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020313c:	100027f3          	csrr	a5,sstatus
ffffffffc0203140:	8b89                	andi	a5,a5,2
ffffffffc0203142:	eb89                	bnez	a5,ffffffffc0203154 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0203144:	00012797          	auipc	a5,0x12
ffffffffc0203148:	48c78793          	addi	a5,a5,1164 # ffffffffc02155d0 <pmm_manager>
ffffffffc020314c:	639c                	ld	a5,0(a5)
ffffffffc020314e:	0207b303          	ld	t1,32(a5)
ffffffffc0203152:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0203154:	1101                	addi	sp,sp,-32
ffffffffc0203156:	ec06                	sd	ra,24(sp)
ffffffffc0203158:	e822                	sd	s0,16(sp)
ffffffffc020315a:	e426                	sd	s1,8(sp)
ffffffffc020315c:	842a                	mv	s0,a0
ffffffffc020315e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0203160:	c7afd0ef          	jal	ra,ffffffffc02005da <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203164:	00012797          	auipc	a5,0x12
ffffffffc0203168:	46c78793          	addi	a5,a5,1132 # ffffffffc02155d0 <pmm_manager>
ffffffffc020316c:	639c                	ld	a5,0(a5)
ffffffffc020316e:	85a6                	mv	a1,s1
ffffffffc0203170:	8522                	mv	a0,s0
ffffffffc0203172:	739c                	ld	a5,32(a5)
ffffffffc0203174:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0203176:	6442                	ld	s0,16(sp)
ffffffffc0203178:	60e2                	ld	ra,24(sp)
ffffffffc020317a:	64a2                	ld	s1,8(sp)
ffffffffc020317c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020317e:	c56fd06f          	j	ffffffffc02005d4 <intr_enable>

ffffffffc0203182 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203182:	100027f3          	csrr	a5,sstatus
ffffffffc0203186:	8b89                	andi	a5,a5,2
ffffffffc0203188:	eb89                	bnez	a5,ffffffffc020319a <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020318a:	00012797          	auipc	a5,0x12
ffffffffc020318e:	44678793          	addi	a5,a5,1094 # ffffffffc02155d0 <pmm_manager>
ffffffffc0203192:	639c                	ld	a5,0(a5)
ffffffffc0203194:	0287b303          	ld	t1,40(a5)
ffffffffc0203198:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc020319a:	1141                	addi	sp,sp,-16
ffffffffc020319c:	e406                	sd	ra,8(sp)
ffffffffc020319e:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02031a0:	c3afd0ef          	jal	ra,ffffffffc02005da <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02031a4:	00012797          	auipc	a5,0x12
ffffffffc02031a8:	42c78793          	addi	a5,a5,1068 # ffffffffc02155d0 <pmm_manager>
ffffffffc02031ac:	639c                	ld	a5,0(a5)
ffffffffc02031ae:	779c                	ld	a5,40(a5)
ffffffffc02031b0:	9782                	jalr	a5
ffffffffc02031b2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02031b4:	c20fd0ef          	jal	ra,ffffffffc02005d4 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02031b8:	8522                	mv	a0,s0
ffffffffc02031ba:	60a2                	ld	ra,8(sp)
ffffffffc02031bc:	6402                	ld	s0,0(sp)
ffffffffc02031be:	0141                	addi	sp,sp,16
ffffffffc02031c0:	8082                	ret

ffffffffc02031c2 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02031c2:	7139                	addi	sp,sp,-64
ffffffffc02031c4:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02031c6:	01e5d493          	srli	s1,a1,0x1e
ffffffffc02031ca:	1ff4f493          	andi	s1,s1,511
ffffffffc02031ce:	048e                	slli	s1,s1,0x3
ffffffffc02031d0:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc02031d2:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02031d4:	f04a                	sd	s2,32(sp)
ffffffffc02031d6:	ec4e                	sd	s3,24(sp)
ffffffffc02031d8:	e852                	sd	s4,16(sp)
ffffffffc02031da:	fc06                	sd	ra,56(sp)
ffffffffc02031dc:	f822                	sd	s0,48(sp)
ffffffffc02031de:	e456                	sd	s5,8(sp)
ffffffffc02031e0:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02031e2:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02031e6:	892e                	mv	s2,a1
ffffffffc02031e8:	8a32                	mv	s4,a2
ffffffffc02031ea:	00012997          	auipc	s3,0x12
ffffffffc02031ee:	2be98993          	addi	s3,s3,702 # ffffffffc02154a8 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02031f2:	e7bd                	bnez	a5,ffffffffc0203260 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02031f4:	12060c63          	beqz	a2,ffffffffc020332c <get_pte+0x16a>
ffffffffc02031f8:	4505                	li	a0,1
ffffffffc02031fa:	ebbff0ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02031fe:	842a                	mv	s0,a0
ffffffffc0203200:	12050663          	beqz	a0,ffffffffc020332c <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203204:	00012b17          	auipc	s6,0x12
ffffffffc0203208:	3e4b0b13          	addi	s6,s6,996 # ffffffffc02155e8 <pages>
ffffffffc020320c:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0203210:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203212:	00012997          	auipc	s3,0x12
ffffffffc0203216:	29698993          	addi	s3,s3,662 # ffffffffc02154a8 <npage>
    return page - pages + nbase;
ffffffffc020321a:	40a40533          	sub	a0,s0,a0
ffffffffc020321e:	00080ab7          	lui	s5,0x80
ffffffffc0203222:	8519                	srai	a0,a0,0x6
ffffffffc0203224:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0203228:	c01c                	sw	a5,0(s0)
ffffffffc020322a:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020322c:	9556                	add	a0,a0,s5
ffffffffc020322e:	83b1                	srli	a5,a5,0xc
ffffffffc0203230:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203232:	0532                	slli	a0,a0,0xc
ffffffffc0203234:	14e7f363          	bleu	a4,a5,ffffffffc020337a <get_pte+0x1b8>
ffffffffc0203238:	00012797          	auipc	a5,0x12
ffffffffc020323c:	3a078793          	addi	a5,a5,928 # ffffffffc02155d8 <va_pa_offset>
ffffffffc0203240:	639c                	ld	a5,0(a5)
ffffffffc0203242:	6605                	lui	a2,0x1
ffffffffc0203244:	4581                	li	a1,0
ffffffffc0203246:	953e                	add	a0,a0,a5
ffffffffc0203248:	7da010ef          	jal	ra,ffffffffc0204a22 <memset>
    return page - pages + nbase;
ffffffffc020324c:	000b3683          	ld	a3,0(s6)
ffffffffc0203250:	40d406b3          	sub	a3,s0,a3
ffffffffc0203254:	8699                	srai	a3,a3,0x6
ffffffffc0203256:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203258:	06aa                	slli	a3,a3,0xa
ffffffffc020325a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020325e:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203260:	77fd                	lui	a5,0xfffff
ffffffffc0203262:	068a                	slli	a3,a3,0x2
ffffffffc0203264:	0009b703          	ld	a4,0(s3)
ffffffffc0203268:	8efd                	and	a3,a3,a5
ffffffffc020326a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020326e:	0ce7f163          	bleu	a4,a5,ffffffffc0203330 <get_pte+0x16e>
ffffffffc0203272:	00012a97          	auipc	s5,0x12
ffffffffc0203276:	366a8a93          	addi	s5,s5,870 # ffffffffc02155d8 <va_pa_offset>
ffffffffc020327a:	000ab403          	ld	s0,0(s5)
ffffffffc020327e:	01595793          	srli	a5,s2,0x15
ffffffffc0203282:	1ff7f793          	andi	a5,a5,511
ffffffffc0203286:	96a2                	add	a3,a3,s0
ffffffffc0203288:	00379413          	slli	s0,a5,0x3
ffffffffc020328c:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020328e:	6014                	ld	a3,0(s0)
ffffffffc0203290:	0016f793          	andi	a5,a3,1
ffffffffc0203294:	e3ad                	bnez	a5,ffffffffc02032f6 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203296:	080a0b63          	beqz	s4,ffffffffc020332c <get_pte+0x16a>
ffffffffc020329a:	4505                	li	a0,1
ffffffffc020329c:	e19ff0ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02032a0:	84aa                	mv	s1,a0
ffffffffc02032a2:	c549                	beqz	a0,ffffffffc020332c <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02032a4:	00012b17          	auipc	s6,0x12
ffffffffc02032a8:	344b0b13          	addi	s6,s6,836 # ffffffffc02155e8 <pages>
ffffffffc02032ac:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc02032b0:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc02032b2:	00080a37          	lui	s4,0x80
ffffffffc02032b6:	40a48533          	sub	a0,s1,a0
ffffffffc02032ba:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02032bc:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc02032c0:	c09c                	sw	a5,0(s1)
ffffffffc02032c2:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc02032c4:	9552                	add	a0,a0,s4
ffffffffc02032c6:	83b1                	srli	a5,a5,0xc
ffffffffc02032c8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02032ca:	0532                	slli	a0,a0,0xc
ffffffffc02032cc:	08e7fa63          	bleu	a4,a5,ffffffffc0203360 <get_pte+0x19e>
ffffffffc02032d0:	000ab783          	ld	a5,0(s5)
ffffffffc02032d4:	6605                	lui	a2,0x1
ffffffffc02032d6:	4581                	li	a1,0
ffffffffc02032d8:	953e                	add	a0,a0,a5
ffffffffc02032da:	748010ef          	jal	ra,ffffffffc0204a22 <memset>
    return page - pages + nbase;
ffffffffc02032de:	000b3683          	ld	a3,0(s6)
ffffffffc02032e2:	40d486b3          	sub	a3,s1,a3
ffffffffc02032e6:	8699                	srai	a3,a3,0x6
ffffffffc02032e8:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02032ea:	06aa                	slli	a3,a3,0xa
ffffffffc02032ec:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02032f0:	e014                	sd	a3,0(s0)
ffffffffc02032f2:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02032f6:	068a                	slli	a3,a3,0x2
ffffffffc02032f8:	757d                	lui	a0,0xfffff
ffffffffc02032fa:	8ee9                	and	a3,a3,a0
ffffffffc02032fc:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203300:	04e7f463          	bleu	a4,a5,ffffffffc0203348 <get_pte+0x186>
ffffffffc0203304:	000ab503          	ld	a0,0(s5)
ffffffffc0203308:	00c95793          	srli	a5,s2,0xc
ffffffffc020330c:	1ff7f793          	andi	a5,a5,511
ffffffffc0203310:	96aa                	add	a3,a3,a0
ffffffffc0203312:	00379513          	slli	a0,a5,0x3
ffffffffc0203316:	9536                	add	a0,a0,a3
}
ffffffffc0203318:	70e2                	ld	ra,56(sp)
ffffffffc020331a:	7442                	ld	s0,48(sp)
ffffffffc020331c:	74a2                	ld	s1,40(sp)
ffffffffc020331e:	7902                	ld	s2,32(sp)
ffffffffc0203320:	69e2                	ld	s3,24(sp)
ffffffffc0203322:	6a42                	ld	s4,16(sp)
ffffffffc0203324:	6aa2                	ld	s5,8(sp)
ffffffffc0203326:	6b02                	ld	s6,0(sp)
ffffffffc0203328:	6121                	addi	sp,sp,64
ffffffffc020332a:	8082                	ret
            return NULL;
ffffffffc020332c:	4501                	li	a0,0
ffffffffc020332e:	b7ed                	j	ffffffffc0203318 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0203330:	00003617          	auipc	a2,0x3
ffffffffc0203334:	83060613          	addi	a2,a2,-2000 # ffffffffc0205b60 <commands+0xb80>
ffffffffc0203338:	0e400593          	li	a1,228
ffffffffc020333c:	00003517          	auipc	a0,0x3
ffffffffc0203340:	29450513          	addi	a0,a0,660 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203344:	e93fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203348:	00003617          	auipc	a2,0x3
ffffffffc020334c:	81860613          	addi	a2,a2,-2024 # ffffffffc0205b60 <commands+0xb80>
ffffffffc0203350:	0ef00593          	li	a1,239
ffffffffc0203354:	00003517          	auipc	a0,0x3
ffffffffc0203358:	27c50513          	addi	a0,a0,636 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc020335c:	e7bfc0ef          	jal	ra,ffffffffc02001d6 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203360:	86aa                	mv	a3,a0
ffffffffc0203362:	00002617          	auipc	a2,0x2
ffffffffc0203366:	7fe60613          	addi	a2,a2,2046 # ffffffffc0205b60 <commands+0xb80>
ffffffffc020336a:	0ec00593          	li	a1,236
ffffffffc020336e:	00003517          	auipc	a0,0x3
ffffffffc0203372:	26250513          	addi	a0,a0,610 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203376:	e61fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020337a:	86aa                	mv	a3,a0
ffffffffc020337c:	00002617          	auipc	a2,0x2
ffffffffc0203380:	7e460613          	addi	a2,a2,2020 # ffffffffc0205b60 <commands+0xb80>
ffffffffc0203384:	0e100593          	li	a1,225
ffffffffc0203388:	00003517          	auipc	a0,0x3
ffffffffc020338c:	24850513          	addi	a0,a0,584 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203390:	e47fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0203394 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0203394:	1141                	addi	sp,sp,-16
ffffffffc0203396:	e022                	sd	s0,0(sp)
ffffffffc0203398:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020339a:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020339c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020339e:	e25ff0ef          	jal	ra,ffffffffc02031c2 <get_pte>
    if (ptep_store != NULL) {
ffffffffc02033a2:	c011                	beqz	s0,ffffffffc02033a6 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02033a4:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02033a6:	c129                	beqz	a0,ffffffffc02033e8 <get_page+0x54>
ffffffffc02033a8:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02033aa:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02033ac:	0017f713          	andi	a4,a5,1
ffffffffc02033b0:	e709                	bnez	a4,ffffffffc02033ba <get_page+0x26>
}
ffffffffc02033b2:	60a2                	ld	ra,8(sp)
ffffffffc02033b4:	6402                	ld	s0,0(sp)
ffffffffc02033b6:	0141                	addi	sp,sp,16
ffffffffc02033b8:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02033ba:	00012717          	auipc	a4,0x12
ffffffffc02033be:	0ee70713          	addi	a4,a4,238 # ffffffffc02154a8 <npage>
ffffffffc02033c2:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02033c4:	078a                	slli	a5,a5,0x2
ffffffffc02033c6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033c8:	02e7f563          	bleu	a4,a5,ffffffffc02033f2 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc02033cc:	00012717          	auipc	a4,0x12
ffffffffc02033d0:	21c70713          	addi	a4,a4,540 # ffffffffc02155e8 <pages>
ffffffffc02033d4:	6308                	ld	a0,0(a4)
ffffffffc02033d6:	60a2                	ld	ra,8(sp)
ffffffffc02033d8:	6402                	ld	s0,0(sp)
ffffffffc02033da:	fff80737          	lui	a4,0xfff80
ffffffffc02033de:	97ba                	add	a5,a5,a4
ffffffffc02033e0:	079a                	slli	a5,a5,0x6
ffffffffc02033e2:	953e                	add	a0,a0,a5
ffffffffc02033e4:	0141                	addi	sp,sp,16
ffffffffc02033e6:	8082                	ret
ffffffffc02033e8:	60a2                	ld	ra,8(sp)
ffffffffc02033ea:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02033ec:	4501                	li	a0,0
}
ffffffffc02033ee:	0141                	addi	sp,sp,16
ffffffffc02033f0:	8082                	ret
ffffffffc02033f2:	ca7ff0ef          	jal	ra,ffffffffc0203098 <pa2page.part.4>

ffffffffc02033f6 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02033f6:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02033f8:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02033fa:	e426                	sd	s1,8(sp)
ffffffffc02033fc:	ec06                	sd	ra,24(sp)
ffffffffc02033fe:	e822                	sd	s0,16(sp)
ffffffffc0203400:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203402:	dc1ff0ef          	jal	ra,ffffffffc02031c2 <get_pte>
    if (ptep != NULL) {
ffffffffc0203406:	c511                	beqz	a0,ffffffffc0203412 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203408:	611c                	ld	a5,0(a0)
ffffffffc020340a:	842a                	mv	s0,a0
ffffffffc020340c:	0017f713          	andi	a4,a5,1
ffffffffc0203410:	e711                	bnez	a4,ffffffffc020341c <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0203412:	60e2                	ld	ra,24(sp)
ffffffffc0203414:	6442                	ld	s0,16(sp)
ffffffffc0203416:	64a2                	ld	s1,8(sp)
ffffffffc0203418:	6105                	addi	sp,sp,32
ffffffffc020341a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020341c:	00012717          	auipc	a4,0x12
ffffffffc0203420:	08c70713          	addi	a4,a4,140 # ffffffffc02154a8 <npage>
ffffffffc0203424:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203426:	078a                	slli	a5,a5,0x2
ffffffffc0203428:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020342a:	02e7fe63          	bleu	a4,a5,ffffffffc0203466 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc020342e:	00012717          	auipc	a4,0x12
ffffffffc0203432:	1ba70713          	addi	a4,a4,442 # ffffffffc02155e8 <pages>
ffffffffc0203436:	6308                	ld	a0,0(a4)
ffffffffc0203438:	fff80737          	lui	a4,0xfff80
ffffffffc020343c:	97ba                	add	a5,a5,a4
ffffffffc020343e:	079a                	slli	a5,a5,0x6
ffffffffc0203440:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203442:	411c                	lw	a5,0(a0)
ffffffffc0203444:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203448:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020344a:	cb11                	beqz	a4,ffffffffc020345e <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020344c:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203450:	12048073          	sfence.vma	s1
}
ffffffffc0203454:	60e2                	ld	ra,24(sp)
ffffffffc0203456:	6442                	ld	s0,16(sp)
ffffffffc0203458:	64a2                	ld	s1,8(sp)
ffffffffc020345a:	6105                	addi	sp,sp,32
ffffffffc020345c:	8082                	ret
            free_page(page);
ffffffffc020345e:	4585                	li	a1,1
ffffffffc0203460:	cddff0ef          	jal	ra,ffffffffc020313c <free_pages>
ffffffffc0203464:	b7e5                	j	ffffffffc020344c <page_remove+0x56>
ffffffffc0203466:	c33ff0ef          	jal	ra,ffffffffc0203098 <pa2page.part.4>

ffffffffc020346a <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020346a:	7179                	addi	sp,sp,-48
ffffffffc020346c:	e44e                	sd	s3,8(sp)
ffffffffc020346e:	89b2                	mv	s3,a2
ffffffffc0203470:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203472:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203474:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203476:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203478:	ec26                	sd	s1,24(sp)
ffffffffc020347a:	f406                	sd	ra,40(sp)
ffffffffc020347c:	e84a                	sd	s2,16(sp)
ffffffffc020347e:	e052                	sd	s4,0(sp)
ffffffffc0203480:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203482:	d41ff0ef          	jal	ra,ffffffffc02031c2 <get_pte>
    if (ptep == NULL) {
ffffffffc0203486:	cd49                	beqz	a0,ffffffffc0203520 <page_insert+0xb6>
    page->ref += 1;
ffffffffc0203488:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc020348a:	611c                	ld	a5,0(a0)
ffffffffc020348c:	892a                	mv	s2,a0
ffffffffc020348e:	0016871b          	addiw	a4,a3,1
ffffffffc0203492:	c018                	sw	a4,0(s0)
ffffffffc0203494:	0017f713          	andi	a4,a5,1
ffffffffc0203498:	ef05                	bnez	a4,ffffffffc02034d0 <page_insert+0x66>
ffffffffc020349a:	00012797          	auipc	a5,0x12
ffffffffc020349e:	14e78793          	addi	a5,a5,334 # ffffffffc02155e8 <pages>
ffffffffc02034a2:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02034a4:	8c19                	sub	s0,s0,a4
ffffffffc02034a6:	000806b7          	lui	a3,0x80
ffffffffc02034aa:	8419                	srai	s0,s0,0x6
ffffffffc02034ac:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02034ae:	042a                	slli	s0,s0,0xa
ffffffffc02034b0:	8c45                	or	s0,s0,s1
ffffffffc02034b2:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02034b6:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02034ba:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02034be:	4501                	li	a0,0
}
ffffffffc02034c0:	70a2                	ld	ra,40(sp)
ffffffffc02034c2:	7402                	ld	s0,32(sp)
ffffffffc02034c4:	64e2                	ld	s1,24(sp)
ffffffffc02034c6:	6942                	ld	s2,16(sp)
ffffffffc02034c8:	69a2                	ld	s3,8(sp)
ffffffffc02034ca:	6a02                	ld	s4,0(sp)
ffffffffc02034cc:	6145                	addi	sp,sp,48
ffffffffc02034ce:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02034d0:	00012717          	auipc	a4,0x12
ffffffffc02034d4:	fd870713          	addi	a4,a4,-40 # ffffffffc02154a8 <npage>
ffffffffc02034d8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02034da:	078a                	slli	a5,a5,0x2
ffffffffc02034dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02034de:	04e7f363          	bleu	a4,a5,ffffffffc0203524 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02034e2:	00012a17          	auipc	s4,0x12
ffffffffc02034e6:	106a0a13          	addi	s4,s4,262 # ffffffffc02155e8 <pages>
ffffffffc02034ea:	000a3703          	ld	a4,0(s4)
ffffffffc02034ee:	fff80537          	lui	a0,0xfff80
ffffffffc02034f2:	953e                	add	a0,a0,a5
ffffffffc02034f4:	051a                	slli	a0,a0,0x6
ffffffffc02034f6:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc02034f8:	00a40a63          	beq	s0,a0,ffffffffc020350c <page_insert+0xa2>
    page->ref -= 1;
ffffffffc02034fc:	411c                	lw	a5,0(a0)
ffffffffc02034fe:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203502:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0203504:	c691                	beqz	a3,ffffffffc0203510 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203506:	12098073          	sfence.vma	s3
ffffffffc020350a:	bf69                	j	ffffffffc02034a4 <page_insert+0x3a>
ffffffffc020350c:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020350e:	bf59                	j	ffffffffc02034a4 <page_insert+0x3a>
            free_page(page);
ffffffffc0203510:	4585                	li	a1,1
ffffffffc0203512:	c2bff0ef          	jal	ra,ffffffffc020313c <free_pages>
ffffffffc0203516:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020351a:	12098073          	sfence.vma	s3
ffffffffc020351e:	b759                	j	ffffffffc02034a4 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203520:	5571                	li	a0,-4
ffffffffc0203522:	bf79                	j	ffffffffc02034c0 <page_insert+0x56>
ffffffffc0203524:	b75ff0ef          	jal	ra,ffffffffc0203098 <pa2page.part.4>

ffffffffc0203528 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203528:	00003797          	auipc	a5,0x3
ffffffffc020352c:	05878793          	addi	a5,a5,88 # ffffffffc0206580 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203530:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203532:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203534:	00003517          	auipc	a0,0x3
ffffffffc0203538:	0c450513          	addi	a0,a0,196 # ffffffffc02065f8 <default_pmm_manager+0x78>
void pmm_init(void) {
ffffffffc020353c:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020353e:	00012717          	auipc	a4,0x12
ffffffffc0203542:	08f73923          	sd	a5,146(a4) # ffffffffc02155d0 <pmm_manager>
void pmm_init(void) {
ffffffffc0203546:	e0a2                	sd	s0,64(sp)
ffffffffc0203548:	fc26                	sd	s1,56(sp)
ffffffffc020354a:	f84a                	sd	s2,48(sp)
ffffffffc020354c:	f44e                	sd	s3,40(sp)
ffffffffc020354e:	f052                	sd	s4,32(sp)
ffffffffc0203550:	ec56                	sd	s5,24(sp)
ffffffffc0203552:	e85a                	sd	s6,16(sp)
ffffffffc0203554:	e45e                	sd	s7,8(sp)
ffffffffc0203556:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203558:	00012417          	auipc	s0,0x12
ffffffffc020355c:	07840413          	addi	s0,s0,120 # ffffffffc02155d0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203560:	b71fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc0203564:	601c                	ld	a5,0(s0)
ffffffffc0203566:	00012497          	auipc	s1,0x12
ffffffffc020356a:	f4248493          	addi	s1,s1,-190 # ffffffffc02154a8 <npage>
ffffffffc020356e:	00012917          	auipc	s2,0x12
ffffffffc0203572:	07a90913          	addi	s2,s2,122 # ffffffffc02155e8 <pages>
ffffffffc0203576:	679c                	ld	a5,8(a5)
ffffffffc0203578:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020357a:	57f5                	li	a5,-3
ffffffffc020357c:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020357e:	00003517          	auipc	a0,0x3
ffffffffc0203582:	09250513          	addi	a0,a0,146 # ffffffffc0206610 <default_pmm_manager+0x90>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203586:	00012717          	auipc	a4,0x12
ffffffffc020358a:	04f73923          	sd	a5,82(a4) # ffffffffc02155d8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020358e:	b43fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203592:	46c5                	li	a3,17
ffffffffc0203594:	06ee                	slli	a3,a3,0x1b
ffffffffc0203596:	40100613          	li	a2,1025
ffffffffc020359a:	16fd                	addi	a3,a3,-1
ffffffffc020359c:	0656                	slli	a2,a2,0x15
ffffffffc020359e:	07e005b7          	lui	a1,0x7e00
ffffffffc02035a2:	00003517          	auipc	a0,0x3
ffffffffc02035a6:	08650513          	addi	a0,a0,134 # ffffffffc0206628 <default_pmm_manager+0xa8>
ffffffffc02035aa:	b27fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02035ae:	777d                	lui	a4,0xfffff
ffffffffc02035b0:	00013797          	auipc	a5,0x13
ffffffffc02035b4:	04f78793          	addi	a5,a5,79 # ffffffffc02165ff <end+0xfff>
ffffffffc02035b8:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02035ba:	00088737          	lui	a4,0x88
ffffffffc02035be:	00012697          	auipc	a3,0x12
ffffffffc02035c2:	eee6b523          	sd	a4,-278(a3) # ffffffffc02154a8 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02035c6:	00012717          	auipc	a4,0x12
ffffffffc02035ca:	02f73123          	sd	a5,34(a4) # ffffffffc02155e8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02035ce:	4701                	li	a4,0
ffffffffc02035d0:	4685                	li	a3,1
ffffffffc02035d2:	fff80837          	lui	a6,0xfff80
ffffffffc02035d6:	a019                	j	ffffffffc02035dc <pmm_init+0xb4>
ffffffffc02035d8:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02035dc:	00671613          	slli	a2,a4,0x6
ffffffffc02035e0:	97b2                	add	a5,a5,a2
ffffffffc02035e2:	07a1                	addi	a5,a5,8
ffffffffc02035e4:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02035e8:	6090                	ld	a2,0(s1)
ffffffffc02035ea:	0705                	addi	a4,a4,1
ffffffffc02035ec:	010607b3          	add	a5,a2,a6
ffffffffc02035f0:	fef764e3          	bltu	a4,a5,ffffffffc02035d8 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02035f4:	00093503          	ld	a0,0(s2)
ffffffffc02035f8:	fe0007b7          	lui	a5,0xfe000
ffffffffc02035fc:	00661693          	slli	a3,a2,0x6
ffffffffc0203600:	97aa                	add	a5,a5,a0
ffffffffc0203602:	96be                	add	a3,a3,a5
ffffffffc0203604:	c02007b7          	lui	a5,0xc0200
ffffffffc0203608:	7af6ed63          	bltu	a3,a5,ffffffffc0203dc2 <pmm_init+0x89a>
ffffffffc020360c:	00012997          	auipc	s3,0x12
ffffffffc0203610:	fcc98993          	addi	s3,s3,-52 # ffffffffc02155d8 <va_pa_offset>
ffffffffc0203614:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203618:	47c5                	li	a5,17
ffffffffc020361a:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020361c:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020361e:	02f6f763          	bleu	a5,a3,ffffffffc020364c <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203622:	6585                	lui	a1,0x1
ffffffffc0203624:	15fd                	addi	a1,a1,-1
ffffffffc0203626:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0203628:	00c6d713          	srli	a4,a3,0xc
ffffffffc020362c:	48c77a63          	bleu	a2,a4,ffffffffc0203ac0 <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0203630:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203632:	75fd                	lui	a1,0xfffff
ffffffffc0203634:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0203636:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0203638:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020363a:	40d786b3          	sub	a3,a5,a3
ffffffffc020363e:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0203640:	00c6d593          	srli	a1,a3,0xc
ffffffffc0203644:	953a                	add	a0,a0,a4
ffffffffc0203646:	9602                	jalr	a2
ffffffffc0203648:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020364c:	00003517          	auipc	a0,0x3
ffffffffc0203650:	00450513          	addi	a0,a0,4 # ffffffffc0206650 <default_pmm_manager+0xd0>
ffffffffc0203654:	a7dfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203658:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020365a:	00012417          	auipc	s0,0x12
ffffffffc020365e:	e4640413          	addi	s0,s0,-442 # ffffffffc02154a0 <boot_pgdir>
    pmm_manager->check();
ffffffffc0203662:	7b9c                	ld	a5,48(a5)
ffffffffc0203664:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203666:	00003517          	auipc	a0,0x3
ffffffffc020366a:	00250513          	addi	a0,a0,2 # ffffffffc0206668 <default_pmm_manager+0xe8>
ffffffffc020366e:	a63fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203672:	00006697          	auipc	a3,0x6
ffffffffc0203676:	98e68693          	addi	a3,a3,-1650 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc020367a:	00012797          	auipc	a5,0x12
ffffffffc020367e:	e2d7b323          	sd	a3,-474(a5) # ffffffffc02154a0 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203682:	c02007b7          	lui	a5,0xc0200
ffffffffc0203686:	10f6eae3          	bltu	a3,a5,ffffffffc0203f9a <pmm_init+0xa72>
ffffffffc020368a:	0009b783          	ld	a5,0(s3)
ffffffffc020368e:	8e9d                	sub	a3,a3,a5
ffffffffc0203690:	00012797          	auipc	a5,0x12
ffffffffc0203694:	f4d7b823          	sd	a3,-176(a5) # ffffffffc02155e0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0203698:	aebff0ef          	jal	ra,ffffffffc0203182 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020369c:	6098                	ld	a4,0(s1)
ffffffffc020369e:	c80007b7          	lui	a5,0xc8000
ffffffffc02036a2:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02036a4:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02036a6:	0ce7eae3          	bltu	a5,a4,ffffffffc0203f7a <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02036aa:	6008                	ld	a0,0(s0)
ffffffffc02036ac:	44050463          	beqz	a0,ffffffffc0203af4 <pmm_init+0x5cc>
ffffffffc02036b0:	6785                	lui	a5,0x1
ffffffffc02036b2:	17fd                	addi	a5,a5,-1
ffffffffc02036b4:	8fe9                	and	a5,a5,a0
ffffffffc02036b6:	2781                	sext.w	a5,a5
ffffffffc02036b8:	42079e63          	bnez	a5,ffffffffc0203af4 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02036bc:	4601                	li	a2,0
ffffffffc02036be:	4581                	li	a1,0
ffffffffc02036c0:	cd5ff0ef          	jal	ra,ffffffffc0203394 <get_page>
ffffffffc02036c4:	78051b63          	bnez	a0,ffffffffc0203e5a <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02036c8:	4505                	li	a0,1
ffffffffc02036ca:	9ebff0ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc02036ce:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02036d0:	6008                	ld	a0,0(s0)
ffffffffc02036d2:	4681                	li	a3,0
ffffffffc02036d4:	4601                	li	a2,0
ffffffffc02036d6:	85d6                	mv	a1,s5
ffffffffc02036d8:	d93ff0ef          	jal	ra,ffffffffc020346a <page_insert>
ffffffffc02036dc:	7a051f63          	bnez	a0,ffffffffc0203e9a <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02036e0:	6008                	ld	a0,0(s0)
ffffffffc02036e2:	4601                	li	a2,0
ffffffffc02036e4:	4581                	li	a1,0
ffffffffc02036e6:	addff0ef          	jal	ra,ffffffffc02031c2 <get_pte>
ffffffffc02036ea:	78050863          	beqz	a0,ffffffffc0203e7a <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02036ee:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02036f0:	0017f713          	andi	a4,a5,1
ffffffffc02036f4:	3e070463          	beqz	a4,ffffffffc0203adc <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02036f8:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02036fa:	078a                	slli	a5,a5,0x2
ffffffffc02036fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036fe:	3ce7f163          	bleu	a4,a5,ffffffffc0203ac0 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0203702:	00093683          	ld	a3,0(s2)
ffffffffc0203706:	fff80637          	lui	a2,0xfff80
ffffffffc020370a:	97b2                	add	a5,a5,a2
ffffffffc020370c:	079a                	slli	a5,a5,0x6
ffffffffc020370e:	97b6                	add	a5,a5,a3
ffffffffc0203710:	72fa9563          	bne	s5,a5,ffffffffc0203e3a <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0203714:	000aab83          	lw	s7,0(s5)
ffffffffc0203718:	4785                	li	a5,1
ffffffffc020371a:	70fb9063          	bne	s7,a5,ffffffffc0203e1a <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020371e:	6008                	ld	a0,0(s0)
ffffffffc0203720:	76fd                	lui	a3,0xfffff
ffffffffc0203722:	611c                	ld	a5,0(a0)
ffffffffc0203724:	078a                	slli	a5,a5,0x2
ffffffffc0203726:	8ff5                	and	a5,a5,a3
ffffffffc0203728:	00c7d613          	srli	a2,a5,0xc
ffffffffc020372c:	66e67e63          	bleu	a4,a2,ffffffffc0203da8 <pmm_init+0x880>
ffffffffc0203730:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203734:	97e2                	add	a5,a5,s8
ffffffffc0203736:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc020373a:	0b0a                	slli	s6,s6,0x2
ffffffffc020373c:	00db7b33          	and	s6,s6,a3
ffffffffc0203740:	00cb5793          	srli	a5,s6,0xc
ffffffffc0203744:	56e7f863          	bleu	a4,a5,ffffffffc0203cb4 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203748:	4601                	li	a2,0
ffffffffc020374a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020374c:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020374e:	a75ff0ef          	jal	ra,ffffffffc02031c2 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203752:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203754:	55651063          	bne	a0,s6,ffffffffc0203c94 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0203758:	4505                	li	a0,1
ffffffffc020375a:	95bff0ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc020375e:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203760:	6008                	ld	a0,0(s0)
ffffffffc0203762:	46d1                	li	a3,20
ffffffffc0203764:	6605                	lui	a2,0x1
ffffffffc0203766:	85da                	mv	a1,s6
ffffffffc0203768:	d03ff0ef          	jal	ra,ffffffffc020346a <page_insert>
ffffffffc020376c:	50051463          	bnez	a0,ffffffffc0203c74 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203770:	6008                	ld	a0,0(s0)
ffffffffc0203772:	4601                	li	a2,0
ffffffffc0203774:	6585                	lui	a1,0x1
ffffffffc0203776:	a4dff0ef          	jal	ra,ffffffffc02031c2 <get_pte>
ffffffffc020377a:	4c050d63          	beqz	a0,ffffffffc0203c54 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc020377e:	611c                	ld	a5,0(a0)
ffffffffc0203780:	0107f713          	andi	a4,a5,16
ffffffffc0203784:	4a070863          	beqz	a4,ffffffffc0203c34 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0203788:	8b91                	andi	a5,a5,4
ffffffffc020378a:	48078563          	beqz	a5,ffffffffc0203c14 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020378e:	6008                	ld	a0,0(s0)
ffffffffc0203790:	611c                	ld	a5,0(a0)
ffffffffc0203792:	8bc1                	andi	a5,a5,16
ffffffffc0203794:	46078063          	beqz	a5,ffffffffc0203bf4 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0203798:	000b2783          	lw	a5,0(s6)
ffffffffc020379c:	43779c63          	bne	a5,s7,ffffffffc0203bd4 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02037a0:	4681                	li	a3,0
ffffffffc02037a2:	6605                	lui	a2,0x1
ffffffffc02037a4:	85d6                	mv	a1,s5
ffffffffc02037a6:	cc5ff0ef          	jal	ra,ffffffffc020346a <page_insert>
ffffffffc02037aa:	40051563          	bnez	a0,ffffffffc0203bb4 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02037ae:	000aa703          	lw	a4,0(s5)
ffffffffc02037b2:	4789                	li	a5,2
ffffffffc02037b4:	3ef71063          	bne	a4,a5,ffffffffc0203b94 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02037b8:	000b2783          	lw	a5,0(s6)
ffffffffc02037bc:	3a079c63          	bnez	a5,ffffffffc0203b74 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02037c0:	6008                	ld	a0,0(s0)
ffffffffc02037c2:	4601                	li	a2,0
ffffffffc02037c4:	6585                	lui	a1,0x1
ffffffffc02037c6:	9fdff0ef          	jal	ra,ffffffffc02031c2 <get_pte>
ffffffffc02037ca:	38050563          	beqz	a0,ffffffffc0203b54 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02037ce:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02037d0:	00177793          	andi	a5,a4,1
ffffffffc02037d4:	30078463          	beqz	a5,ffffffffc0203adc <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02037d8:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02037da:	00271793          	slli	a5,a4,0x2
ffffffffc02037de:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037e0:	2ed7f063          	bleu	a3,a5,ffffffffc0203ac0 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02037e4:	00093683          	ld	a3,0(s2)
ffffffffc02037e8:	fff80637          	lui	a2,0xfff80
ffffffffc02037ec:	97b2                	add	a5,a5,a2
ffffffffc02037ee:	079a                	slli	a5,a5,0x6
ffffffffc02037f0:	97b6                	add	a5,a5,a3
ffffffffc02037f2:	32fa9163          	bne	s5,a5,ffffffffc0203b14 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc02037f6:	8b41                	andi	a4,a4,16
ffffffffc02037f8:	70071163          	bnez	a4,ffffffffc0203efa <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02037fc:	6008                	ld	a0,0(s0)
ffffffffc02037fe:	4581                	li	a1,0
ffffffffc0203800:	bf7ff0ef          	jal	ra,ffffffffc02033f6 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203804:	000aa703          	lw	a4,0(s5)
ffffffffc0203808:	4785                	li	a5,1
ffffffffc020380a:	6cf71863          	bne	a4,a5,ffffffffc0203eda <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc020380e:	000b2783          	lw	a5,0(s6)
ffffffffc0203812:	6a079463          	bnez	a5,ffffffffc0203eba <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0203816:	6008                	ld	a0,0(s0)
ffffffffc0203818:	6585                	lui	a1,0x1
ffffffffc020381a:	bddff0ef          	jal	ra,ffffffffc02033f6 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020381e:	000aa783          	lw	a5,0(s5)
ffffffffc0203822:	50079363          	bnez	a5,ffffffffc0203d28 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0203826:	000b2783          	lw	a5,0(s6)
ffffffffc020382a:	4c079f63          	bnez	a5,ffffffffc0203d08 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020382e:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203832:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203834:	000ab783          	ld	a5,0(s5)
ffffffffc0203838:	078a                	slli	a5,a5,0x2
ffffffffc020383a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020383c:	28c7f263          	bleu	a2,a5,ffffffffc0203ac0 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0203840:	fff80737          	lui	a4,0xfff80
ffffffffc0203844:	00093503          	ld	a0,0(s2)
ffffffffc0203848:	97ba                	add	a5,a5,a4
ffffffffc020384a:	079a                	slli	a5,a5,0x6
ffffffffc020384c:	00f50733          	add	a4,a0,a5
ffffffffc0203850:	4314                	lw	a3,0(a4)
ffffffffc0203852:	4705                	li	a4,1
ffffffffc0203854:	48e69a63          	bne	a3,a4,ffffffffc0203ce8 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0203858:	8799                	srai	a5,a5,0x6
ffffffffc020385a:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020385e:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc0203860:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0203862:	8331                	srli	a4,a4,0xc
ffffffffc0203864:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0203866:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203868:	46c77363          	bleu	a2,a4,ffffffffc0203cce <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020386c:	0009b683          	ld	a3,0(s3)
ffffffffc0203870:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0203872:	639c                	ld	a5,0(a5)
ffffffffc0203874:	078a                	slli	a5,a5,0x2
ffffffffc0203876:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203878:	24c7f463          	bleu	a2,a5,ffffffffc0203ac0 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020387c:	416787b3          	sub	a5,a5,s6
ffffffffc0203880:	079a                	slli	a5,a5,0x6
ffffffffc0203882:	953e                	add	a0,a0,a5
ffffffffc0203884:	4585                	li	a1,1
ffffffffc0203886:	8b7ff0ef          	jal	ra,ffffffffc020313c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020388a:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020388e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203890:	078a                	slli	a5,a5,0x2
ffffffffc0203892:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203894:	22e7f663          	bleu	a4,a5,ffffffffc0203ac0 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0203898:	00093503          	ld	a0,0(s2)
ffffffffc020389c:	416787b3          	sub	a5,a5,s6
ffffffffc02038a0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02038a2:	953e                	add	a0,a0,a5
ffffffffc02038a4:	4585                	li	a1,1
ffffffffc02038a6:	897ff0ef          	jal	ra,ffffffffc020313c <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02038aa:	601c                	ld	a5,0(s0)
ffffffffc02038ac:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02038b0:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02038b4:	8cfff0ef          	jal	ra,ffffffffc0203182 <nr_free_pages>
ffffffffc02038b8:	68aa1163          	bne	s4,a0,ffffffffc0203f3a <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02038bc:	00003517          	auipc	a0,0x3
ffffffffc02038c0:	09450513          	addi	a0,a0,148 # ffffffffc0206950 <default_pmm_manager+0x3d0>
ffffffffc02038c4:	80dfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02038c8:	8bbff0ef          	jal	ra,ffffffffc0203182 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02038cc:	6098                	ld	a4,0(s1)
ffffffffc02038ce:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02038d2:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02038d4:	00c71693          	slli	a3,a4,0xc
ffffffffc02038d8:	18d7f563          	bleu	a3,a5,ffffffffc0203a62 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02038dc:	83b1                	srli	a5,a5,0xc
ffffffffc02038de:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02038e0:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02038e4:	1ae7f163          	bleu	a4,a5,ffffffffc0203a86 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02038e8:	7bfd                	lui	s7,0xfffff
ffffffffc02038ea:	6b05                	lui	s6,0x1
ffffffffc02038ec:	a029                	j	ffffffffc02038f6 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02038ee:	00cad713          	srli	a4,s5,0xc
ffffffffc02038f2:	18f77a63          	bleu	a5,a4,ffffffffc0203a86 <pmm_init+0x55e>
ffffffffc02038f6:	0009b583          	ld	a1,0(s3)
ffffffffc02038fa:	4601                	li	a2,0
ffffffffc02038fc:	95d6                	add	a1,a1,s5
ffffffffc02038fe:	8c5ff0ef          	jal	ra,ffffffffc02031c2 <get_pte>
ffffffffc0203902:	16050263          	beqz	a0,ffffffffc0203a66 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203906:	611c                	ld	a5,0(a0)
ffffffffc0203908:	078a                	slli	a5,a5,0x2
ffffffffc020390a:	0177f7b3          	and	a5,a5,s7
ffffffffc020390e:	19579963          	bne	a5,s5,ffffffffc0203aa0 <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203912:	609c                	ld	a5,0(s1)
ffffffffc0203914:	9ada                	add	s5,s5,s6
ffffffffc0203916:	6008                	ld	a0,0(s0)
ffffffffc0203918:	00c79713          	slli	a4,a5,0xc
ffffffffc020391c:	fceae9e3          	bltu	s5,a4,ffffffffc02038ee <pmm_init+0x3c6>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc0203920:	611c                	ld	a5,0(a0)
ffffffffc0203922:	62079c63          	bnez	a5,ffffffffc0203f5a <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0203926:	4505                	li	a0,1
ffffffffc0203928:	f8cff0ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc020392c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020392e:	6008                	ld	a0,0(s0)
ffffffffc0203930:	4699                	li	a3,6
ffffffffc0203932:	10000613          	li	a2,256
ffffffffc0203936:	85d6                	mv	a1,s5
ffffffffc0203938:	b33ff0ef          	jal	ra,ffffffffc020346a <page_insert>
ffffffffc020393c:	1e051c63          	bnez	a0,ffffffffc0203b34 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0203940:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0203944:	4785                	li	a5,1
ffffffffc0203946:	44f71163          	bne	a4,a5,ffffffffc0203d88 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020394a:	6008                	ld	a0,0(s0)
ffffffffc020394c:	6b05                	lui	s6,0x1
ffffffffc020394e:	4699                	li	a3,6
ffffffffc0203950:	100b0613          	addi	a2,s6,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0203954:	85d6                	mv	a1,s5
ffffffffc0203956:	b15ff0ef          	jal	ra,ffffffffc020346a <page_insert>
ffffffffc020395a:	40051763          	bnez	a0,ffffffffc0203d68 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc020395e:	000aa703          	lw	a4,0(s5)
ffffffffc0203962:	4789                	li	a5,2
ffffffffc0203964:	3ef71263          	bne	a4,a5,ffffffffc0203d48 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0203968:	00003597          	auipc	a1,0x3
ffffffffc020396c:	12058593          	addi	a1,a1,288 # ffffffffc0206a88 <default_pmm_manager+0x508>
ffffffffc0203970:	10000513          	li	a0,256
ffffffffc0203974:	054010ef          	jal	ra,ffffffffc02049c8 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203978:	100b0593          	addi	a1,s6,256
ffffffffc020397c:	10000513          	li	a0,256
ffffffffc0203980:	05a010ef          	jal	ra,ffffffffc02049da <strcmp>
ffffffffc0203984:	44051b63          	bnez	a0,ffffffffc0203dda <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0203988:	00093683          	ld	a3,0(s2)
ffffffffc020398c:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0203990:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0203992:	40da86b3          	sub	a3,s5,a3
ffffffffc0203996:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203998:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020399a:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020399c:	00cb5b13          	srli	s6,s6,0xc
ffffffffc02039a0:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02039a4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02039a6:	10f77f63          	bleu	a5,a4,ffffffffc0203ac4 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02039aa:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02039ae:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02039b2:	96be                	add	a3,a3,a5
ffffffffc02039b4:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fde9b00>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02039b8:	7cd000ef          	jal	ra,ffffffffc0204984 <strlen>
ffffffffc02039bc:	54051f63          	bnez	a0,ffffffffc0203f1a <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02039c0:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02039c4:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02039c6:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde9a00>
ffffffffc02039ca:	068a                	slli	a3,a3,0x2
ffffffffc02039cc:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02039ce:	0ef6f963          	bleu	a5,a3,ffffffffc0203ac0 <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc02039d2:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02039d6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02039d8:	0efb7663          	bleu	a5,s6,ffffffffc0203ac4 <pmm_init+0x59c>
ffffffffc02039dc:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02039e0:	4585                	li	a1,1
ffffffffc02039e2:	8556                	mv	a0,s5
ffffffffc02039e4:	99b6                	add	s3,s3,a3
ffffffffc02039e6:	f56ff0ef          	jal	ra,ffffffffc020313c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02039ea:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02039ee:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02039f0:	078a                	slli	a5,a5,0x2
ffffffffc02039f2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02039f4:	0ce7f663          	bleu	a4,a5,ffffffffc0203ac0 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02039f8:	00093503          	ld	a0,0(s2)
ffffffffc02039fc:	fff809b7          	lui	s3,0xfff80
ffffffffc0203a00:	97ce                	add	a5,a5,s3
ffffffffc0203a02:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203a04:	953e                	add	a0,a0,a5
ffffffffc0203a06:	4585                	li	a1,1
ffffffffc0203a08:	f34ff0ef          	jal	ra,ffffffffc020313c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a0c:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0203a10:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a12:	078a                	slli	a5,a5,0x2
ffffffffc0203a14:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a16:	0ae7f563          	bleu	a4,a5,ffffffffc0203ac0 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a1a:	00093503          	ld	a0,0(s2)
ffffffffc0203a1e:	97ce                	add	a5,a5,s3
ffffffffc0203a20:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203a22:	953e                	add	a0,a0,a5
ffffffffc0203a24:	4585                	li	a1,1
ffffffffc0203a26:	f16ff0ef          	jal	ra,ffffffffc020313c <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0203a2a:	601c                	ld	a5,0(s0)
ffffffffc0203a2c:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0203a30:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0203a34:	f4eff0ef          	jal	ra,ffffffffc0203182 <nr_free_pages>
ffffffffc0203a38:	3caa1163          	bne	s4,a0,ffffffffc0203dfa <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203a3c:	00003517          	auipc	a0,0x3
ffffffffc0203a40:	0c450513          	addi	a0,a0,196 # ffffffffc0206b00 <default_pmm_manager+0x580>
ffffffffc0203a44:	e8cfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0203a48:	6406                	ld	s0,64(sp)
ffffffffc0203a4a:	60a6                	ld	ra,72(sp)
ffffffffc0203a4c:	74e2                	ld	s1,56(sp)
ffffffffc0203a4e:	7942                	ld	s2,48(sp)
ffffffffc0203a50:	79a2                	ld	s3,40(sp)
ffffffffc0203a52:	7a02                	ld	s4,32(sp)
ffffffffc0203a54:	6ae2                	ld	s5,24(sp)
ffffffffc0203a56:	6b42                	ld	s6,16(sp)
ffffffffc0203a58:	6ba2                	ld	s7,8(sp)
ffffffffc0203a5a:	6c02                	ld	s8,0(sp)
ffffffffc0203a5c:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0203a5e:	fcbfd06f          	j	ffffffffc0201a28 <kmalloc_init>
ffffffffc0203a62:	6008                	ld	a0,0(s0)
ffffffffc0203a64:	bd75                	j	ffffffffc0203920 <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203a66:	00003697          	auipc	a3,0x3
ffffffffc0203a6a:	f0a68693          	addi	a3,a3,-246 # ffffffffc0206970 <default_pmm_manager+0x3f0>
ffffffffc0203a6e:	00002617          	auipc	a2,0x2
ffffffffc0203a72:	dd260613          	addi	a2,a2,-558 # ffffffffc0205840 <commands+0x860>
ffffffffc0203a76:	19d00593          	li	a1,413
ffffffffc0203a7a:	00003517          	auipc	a0,0x3
ffffffffc0203a7e:	b5650513          	addi	a0,a0,-1194 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203a82:	f54fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0203a86:	86d6                	mv	a3,s5
ffffffffc0203a88:	00002617          	auipc	a2,0x2
ffffffffc0203a8c:	0d860613          	addi	a2,a2,216 # ffffffffc0205b60 <commands+0xb80>
ffffffffc0203a90:	19d00593          	li	a1,413
ffffffffc0203a94:	00003517          	auipc	a0,0x3
ffffffffc0203a98:	b3c50513          	addi	a0,a0,-1220 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203a9c:	f3afc0ef          	jal	ra,ffffffffc02001d6 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203aa0:	00003697          	auipc	a3,0x3
ffffffffc0203aa4:	f1068693          	addi	a3,a3,-240 # ffffffffc02069b0 <default_pmm_manager+0x430>
ffffffffc0203aa8:	00002617          	auipc	a2,0x2
ffffffffc0203aac:	d9860613          	addi	a2,a2,-616 # ffffffffc0205840 <commands+0x860>
ffffffffc0203ab0:	19e00593          	li	a1,414
ffffffffc0203ab4:	00003517          	auipc	a0,0x3
ffffffffc0203ab8:	b1c50513          	addi	a0,a0,-1252 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203abc:	f1afc0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0203ac0:	dd8ff0ef          	jal	ra,ffffffffc0203098 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0203ac4:	00002617          	auipc	a2,0x2
ffffffffc0203ac8:	09c60613          	addi	a2,a2,156 # ffffffffc0205b60 <commands+0xb80>
ffffffffc0203acc:	06900593          	li	a1,105
ffffffffc0203ad0:	00002517          	auipc	a0,0x2
ffffffffc0203ad4:	08050513          	addi	a0,a0,128 # ffffffffc0205b50 <commands+0xb70>
ffffffffc0203ad8:	efefc0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203adc:	00002617          	auipc	a2,0x2
ffffffffc0203ae0:	5f460613          	addi	a2,a2,1524 # ffffffffc02060d0 <commands+0x10f0>
ffffffffc0203ae4:	07400593          	li	a1,116
ffffffffc0203ae8:	00002517          	auipc	a0,0x2
ffffffffc0203aec:	06850513          	addi	a0,a0,104 # ffffffffc0205b50 <commands+0xb70>
ffffffffc0203af0:	ee6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203af4:	00003697          	auipc	a3,0x3
ffffffffc0203af8:	bb468693          	addi	a3,a3,-1100 # ffffffffc02066a8 <default_pmm_manager+0x128>
ffffffffc0203afc:	00002617          	auipc	a2,0x2
ffffffffc0203b00:	d4460613          	addi	a2,a2,-700 # ffffffffc0205840 <commands+0x860>
ffffffffc0203b04:	16100593          	li	a1,353
ffffffffc0203b08:	00003517          	auipc	a0,0x3
ffffffffc0203b0c:	ac850513          	addi	a0,a0,-1336 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203b10:	ec6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203b14:	00003697          	auipc	a3,0x3
ffffffffc0203b18:	c5468693          	addi	a3,a3,-940 # ffffffffc0206768 <default_pmm_manager+0x1e8>
ffffffffc0203b1c:	00002617          	auipc	a2,0x2
ffffffffc0203b20:	d2460613          	addi	a2,a2,-732 # ffffffffc0205840 <commands+0x860>
ffffffffc0203b24:	17d00593          	li	a1,381
ffffffffc0203b28:	00003517          	auipc	a0,0x3
ffffffffc0203b2c:	aa850513          	addi	a0,a0,-1368 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203b30:	ea6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203b34:	00003697          	auipc	a3,0x3
ffffffffc0203b38:	eac68693          	addi	a3,a3,-340 # ffffffffc02069e0 <default_pmm_manager+0x460>
ffffffffc0203b3c:	00002617          	auipc	a2,0x2
ffffffffc0203b40:	d0460613          	addi	a2,a2,-764 # ffffffffc0205840 <commands+0x860>
ffffffffc0203b44:	1a500593          	li	a1,421
ffffffffc0203b48:	00003517          	auipc	a0,0x3
ffffffffc0203b4c:	a8850513          	addi	a0,a0,-1400 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203b50:	e86fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203b54:	00003697          	auipc	a3,0x3
ffffffffc0203b58:	ca468693          	addi	a3,a3,-860 # ffffffffc02067f8 <default_pmm_manager+0x278>
ffffffffc0203b5c:	00002617          	auipc	a2,0x2
ffffffffc0203b60:	ce460613          	addi	a2,a2,-796 # ffffffffc0205840 <commands+0x860>
ffffffffc0203b64:	17c00593          	li	a1,380
ffffffffc0203b68:	00003517          	auipc	a0,0x3
ffffffffc0203b6c:	a6850513          	addi	a0,a0,-1432 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203b70:	e66fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203b74:	00003697          	auipc	a3,0x3
ffffffffc0203b78:	d4c68693          	addi	a3,a3,-692 # ffffffffc02068c0 <default_pmm_manager+0x340>
ffffffffc0203b7c:	00002617          	auipc	a2,0x2
ffffffffc0203b80:	cc460613          	addi	a2,a2,-828 # ffffffffc0205840 <commands+0x860>
ffffffffc0203b84:	17b00593          	li	a1,379
ffffffffc0203b88:	00003517          	auipc	a0,0x3
ffffffffc0203b8c:	a4850513          	addi	a0,a0,-1464 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203b90:	e46fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203b94:	00003697          	auipc	a3,0x3
ffffffffc0203b98:	d1468693          	addi	a3,a3,-748 # ffffffffc02068a8 <default_pmm_manager+0x328>
ffffffffc0203b9c:	00002617          	auipc	a2,0x2
ffffffffc0203ba0:	ca460613          	addi	a2,a2,-860 # ffffffffc0205840 <commands+0x860>
ffffffffc0203ba4:	17a00593          	li	a1,378
ffffffffc0203ba8:	00003517          	auipc	a0,0x3
ffffffffc0203bac:	a2850513          	addi	a0,a0,-1496 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203bb0:	e26fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203bb4:	00003697          	auipc	a3,0x3
ffffffffc0203bb8:	cc468693          	addi	a3,a3,-828 # ffffffffc0206878 <default_pmm_manager+0x2f8>
ffffffffc0203bbc:	00002617          	auipc	a2,0x2
ffffffffc0203bc0:	c8460613          	addi	a2,a2,-892 # ffffffffc0205840 <commands+0x860>
ffffffffc0203bc4:	17900593          	li	a1,377
ffffffffc0203bc8:	00003517          	auipc	a0,0x3
ffffffffc0203bcc:	a0850513          	addi	a0,a0,-1528 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203bd0:	e06fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203bd4:	00003697          	auipc	a3,0x3
ffffffffc0203bd8:	c8c68693          	addi	a3,a3,-884 # ffffffffc0206860 <default_pmm_manager+0x2e0>
ffffffffc0203bdc:	00002617          	auipc	a2,0x2
ffffffffc0203be0:	c6460613          	addi	a2,a2,-924 # ffffffffc0205840 <commands+0x860>
ffffffffc0203be4:	17700593          	li	a1,375
ffffffffc0203be8:	00003517          	auipc	a0,0x3
ffffffffc0203bec:	9e850513          	addi	a0,a0,-1560 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203bf0:	de6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203bf4:	00003697          	auipc	a3,0x3
ffffffffc0203bf8:	c5468693          	addi	a3,a3,-940 # ffffffffc0206848 <default_pmm_manager+0x2c8>
ffffffffc0203bfc:	00002617          	auipc	a2,0x2
ffffffffc0203c00:	c4460613          	addi	a2,a2,-956 # ffffffffc0205840 <commands+0x860>
ffffffffc0203c04:	17600593          	li	a1,374
ffffffffc0203c08:	00003517          	auipc	a0,0x3
ffffffffc0203c0c:	9c850513          	addi	a0,a0,-1592 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203c10:	dc6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203c14:	00003697          	auipc	a3,0x3
ffffffffc0203c18:	c2468693          	addi	a3,a3,-988 # ffffffffc0206838 <default_pmm_manager+0x2b8>
ffffffffc0203c1c:	00002617          	auipc	a2,0x2
ffffffffc0203c20:	c2460613          	addi	a2,a2,-988 # ffffffffc0205840 <commands+0x860>
ffffffffc0203c24:	17500593          	li	a1,373
ffffffffc0203c28:	00003517          	auipc	a0,0x3
ffffffffc0203c2c:	9a850513          	addi	a0,a0,-1624 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203c30:	da6fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203c34:	00003697          	auipc	a3,0x3
ffffffffc0203c38:	bf468693          	addi	a3,a3,-1036 # ffffffffc0206828 <default_pmm_manager+0x2a8>
ffffffffc0203c3c:	00002617          	auipc	a2,0x2
ffffffffc0203c40:	c0460613          	addi	a2,a2,-1020 # ffffffffc0205840 <commands+0x860>
ffffffffc0203c44:	17400593          	li	a1,372
ffffffffc0203c48:	00003517          	auipc	a0,0x3
ffffffffc0203c4c:	98850513          	addi	a0,a0,-1656 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203c50:	d86fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203c54:	00003697          	auipc	a3,0x3
ffffffffc0203c58:	ba468693          	addi	a3,a3,-1116 # ffffffffc02067f8 <default_pmm_manager+0x278>
ffffffffc0203c5c:	00002617          	auipc	a2,0x2
ffffffffc0203c60:	be460613          	addi	a2,a2,-1052 # ffffffffc0205840 <commands+0x860>
ffffffffc0203c64:	17300593          	li	a1,371
ffffffffc0203c68:	00003517          	auipc	a0,0x3
ffffffffc0203c6c:	96850513          	addi	a0,a0,-1688 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203c70:	d66fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203c74:	00003697          	auipc	a3,0x3
ffffffffc0203c78:	b4c68693          	addi	a3,a3,-1204 # ffffffffc02067c0 <default_pmm_manager+0x240>
ffffffffc0203c7c:	00002617          	auipc	a2,0x2
ffffffffc0203c80:	bc460613          	addi	a2,a2,-1084 # ffffffffc0205840 <commands+0x860>
ffffffffc0203c84:	17200593          	li	a1,370
ffffffffc0203c88:	00003517          	auipc	a0,0x3
ffffffffc0203c8c:	94850513          	addi	a0,a0,-1720 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203c90:	d46fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203c94:	00003697          	auipc	a3,0x3
ffffffffc0203c98:	b0468693          	addi	a3,a3,-1276 # ffffffffc0206798 <default_pmm_manager+0x218>
ffffffffc0203c9c:	00002617          	auipc	a2,0x2
ffffffffc0203ca0:	ba460613          	addi	a2,a2,-1116 # ffffffffc0205840 <commands+0x860>
ffffffffc0203ca4:	16f00593          	li	a1,367
ffffffffc0203ca8:	00003517          	auipc	a0,0x3
ffffffffc0203cac:	92850513          	addi	a0,a0,-1752 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203cb0:	d26fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203cb4:	86da                	mv	a3,s6
ffffffffc0203cb6:	00002617          	auipc	a2,0x2
ffffffffc0203cba:	eaa60613          	addi	a2,a2,-342 # ffffffffc0205b60 <commands+0xb80>
ffffffffc0203cbe:	16e00593          	li	a1,366
ffffffffc0203cc2:	00003517          	auipc	a0,0x3
ffffffffc0203cc6:	90e50513          	addi	a0,a0,-1778 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203cca:	d0cfc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203cce:	86be                	mv	a3,a5
ffffffffc0203cd0:	00002617          	auipc	a2,0x2
ffffffffc0203cd4:	e9060613          	addi	a2,a2,-368 # ffffffffc0205b60 <commands+0xb80>
ffffffffc0203cd8:	06900593          	li	a1,105
ffffffffc0203cdc:	00002517          	auipc	a0,0x2
ffffffffc0203ce0:	e7450513          	addi	a0,a0,-396 # ffffffffc0205b50 <commands+0xb70>
ffffffffc0203ce4:	cf2fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203ce8:	00003697          	auipc	a3,0x3
ffffffffc0203cec:	c2068693          	addi	a3,a3,-992 # ffffffffc0206908 <default_pmm_manager+0x388>
ffffffffc0203cf0:	00002617          	auipc	a2,0x2
ffffffffc0203cf4:	b5060613          	addi	a2,a2,-1200 # ffffffffc0205840 <commands+0x860>
ffffffffc0203cf8:	18800593          	li	a1,392
ffffffffc0203cfc:	00003517          	auipc	a0,0x3
ffffffffc0203d00:	8d450513          	addi	a0,a0,-1836 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203d04:	cd2fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203d08:	00003697          	auipc	a3,0x3
ffffffffc0203d0c:	bb868693          	addi	a3,a3,-1096 # ffffffffc02068c0 <default_pmm_manager+0x340>
ffffffffc0203d10:	00002617          	auipc	a2,0x2
ffffffffc0203d14:	b3060613          	addi	a2,a2,-1232 # ffffffffc0205840 <commands+0x860>
ffffffffc0203d18:	18600593          	li	a1,390
ffffffffc0203d1c:	00003517          	auipc	a0,0x3
ffffffffc0203d20:	8b450513          	addi	a0,a0,-1868 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203d24:	cb2fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203d28:	00003697          	auipc	a3,0x3
ffffffffc0203d2c:	bc868693          	addi	a3,a3,-1080 # ffffffffc02068f0 <default_pmm_manager+0x370>
ffffffffc0203d30:	00002617          	auipc	a2,0x2
ffffffffc0203d34:	b1060613          	addi	a2,a2,-1264 # ffffffffc0205840 <commands+0x860>
ffffffffc0203d38:	18500593          	li	a1,389
ffffffffc0203d3c:	00003517          	auipc	a0,0x3
ffffffffc0203d40:	89450513          	addi	a0,a0,-1900 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203d44:	c92fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203d48:	00003697          	auipc	a3,0x3
ffffffffc0203d4c:	d2868693          	addi	a3,a3,-728 # ffffffffc0206a70 <default_pmm_manager+0x4f0>
ffffffffc0203d50:	00002617          	auipc	a2,0x2
ffffffffc0203d54:	af060613          	addi	a2,a2,-1296 # ffffffffc0205840 <commands+0x860>
ffffffffc0203d58:	1a800593          	li	a1,424
ffffffffc0203d5c:	00003517          	auipc	a0,0x3
ffffffffc0203d60:	87450513          	addi	a0,a0,-1932 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203d64:	c72fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203d68:	00003697          	auipc	a3,0x3
ffffffffc0203d6c:	cc868693          	addi	a3,a3,-824 # ffffffffc0206a30 <default_pmm_manager+0x4b0>
ffffffffc0203d70:	00002617          	auipc	a2,0x2
ffffffffc0203d74:	ad060613          	addi	a2,a2,-1328 # ffffffffc0205840 <commands+0x860>
ffffffffc0203d78:	1a700593          	li	a1,423
ffffffffc0203d7c:	00003517          	auipc	a0,0x3
ffffffffc0203d80:	85450513          	addi	a0,a0,-1964 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203d84:	c52fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203d88:	00003697          	auipc	a3,0x3
ffffffffc0203d8c:	c9068693          	addi	a3,a3,-880 # ffffffffc0206a18 <default_pmm_manager+0x498>
ffffffffc0203d90:	00002617          	auipc	a2,0x2
ffffffffc0203d94:	ab060613          	addi	a2,a2,-1360 # ffffffffc0205840 <commands+0x860>
ffffffffc0203d98:	1a600593          	li	a1,422
ffffffffc0203d9c:	00003517          	auipc	a0,0x3
ffffffffc0203da0:	83450513          	addi	a0,a0,-1996 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203da4:	c32fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203da8:	86be                	mv	a3,a5
ffffffffc0203daa:	00002617          	auipc	a2,0x2
ffffffffc0203dae:	db660613          	addi	a2,a2,-586 # ffffffffc0205b60 <commands+0xb80>
ffffffffc0203db2:	16d00593          	li	a1,365
ffffffffc0203db6:	00003517          	auipc	a0,0x3
ffffffffc0203dba:	81a50513          	addi	a0,a0,-2022 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203dbe:	c18fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203dc2:	00002617          	auipc	a2,0x2
ffffffffc0203dc6:	01660613          	addi	a2,a2,22 # ffffffffc0205dd8 <commands+0xdf8>
ffffffffc0203dca:	07f00593          	li	a1,127
ffffffffc0203dce:	00003517          	auipc	a0,0x3
ffffffffc0203dd2:	80250513          	addi	a0,a0,-2046 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203dd6:	c00fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203dda:	00003697          	auipc	a3,0x3
ffffffffc0203dde:	cc668693          	addi	a3,a3,-826 # ffffffffc0206aa0 <default_pmm_manager+0x520>
ffffffffc0203de2:	00002617          	auipc	a2,0x2
ffffffffc0203de6:	a5e60613          	addi	a2,a2,-1442 # ffffffffc0205840 <commands+0x860>
ffffffffc0203dea:	1ac00593          	li	a1,428
ffffffffc0203dee:	00002517          	auipc	a0,0x2
ffffffffc0203df2:	7e250513          	addi	a0,a0,2018 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203df6:	be0fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203dfa:	00003697          	auipc	a3,0x3
ffffffffc0203dfe:	b3668693          	addi	a3,a3,-1226 # ffffffffc0206930 <default_pmm_manager+0x3b0>
ffffffffc0203e02:	00002617          	auipc	a2,0x2
ffffffffc0203e06:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0205840 <commands+0x860>
ffffffffc0203e0a:	1b800593          	li	a1,440
ffffffffc0203e0e:	00002517          	auipc	a0,0x2
ffffffffc0203e12:	7c250513          	addi	a0,a0,1986 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203e16:	bc0fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203e1a:	00003697          	auipc	a3,0x3
ffffffffc0203e1e:	96668693          	addi	a3,a3,-1690 # ffffffffc0206780 <default_pmm_manager+0x200>
ffffffffc0203e22:	00002617          	auipc	a2,0x2
ffffffffc0203e26:	a1e60613          	addi	a2,a2,-1506 # ffffffffc0205840 <commands+0x860>
ffffffffc0203e2a:	16b00593          	li	a1,363
ffffffffc0203e2e:	00002517          	auipc	a0,0x2
ffffffffc0203e32:	7a250513          	addi	a0,a0,1954 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203e36:	ba0fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203e3a:	00003697          	auipc	a3,0x3
ffffffffc0203e3e:	92e68693          	addi	a3,a3,-1746 # ffffffffc0206768 <default_pmm_manager+0x1e8>
ffffffffc0203e42:	00002617          	auipc	a2,0x2
ffffffffc0203e46:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0205840 <commands+0x860>
ffffffffc0203e4a:	16a00593          	li	a1,362
ffffffffc0203e4e:	00002517          	auipc	a0,0x2
ffffffffc0203e52:	78250513          	addi	a0,a0,1922 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203e56:	b80fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203e5a:	00003697          	auipc	a3,0x3
ffffffffc0203e5e:	88668693          	addi	a3,a3,-1914 # ffffffffc02066e0 <default_pmm_manager+0x160>
ffffffffc0203e62:	00002617          	auipc	a2,0x2
ffffffffc0203e66:	9de60613          	addi	a2,a2,-1570 # ffffffffc0205840 <commands+0x860>
ffffffffc0203e6a:	16200593          	li	a1,354
ffffffffc0203e6e:	00002517          	auipc	a0,0x2
ffffffffc0203e72:	76250513          	addi	a0,a0,1890 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203e76:	b60fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203e7a:	00003697          	auipc	a3,0x3
ffffffffc0203e7e:	8be68693          	addi	a3,a3,-1858 # ffffffffc0206738 <default_pmm_manager+0x1b8>
ffffffffc0203e82:	00002617          	auipc	a2,0x2
ffffffffc0203e86:	9be60613          	addi	a2,a2,-1602 # ffffffffc0205840 <commands+0x860>
ffffffffc0203e8a:	16900593          	li	a1,361
ffffffffc0203e8e:	00002517          	auipc	a0,0x2
ffffffffc0203e92:	74250513          	addi	a0,a0,1858 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203e96:	b40fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203e9a:	00003697          	auipc	a3,0x3
ffffffffc0203e9e:	86e68693          	addi	a3,a3,-1938 # ffffffffc0206708 <default_pmm_manager+0x188>
ffffffffc0203ea2:	00002617          	auipc	a2,0x2
ffffffffc0203ea6:	99e60613          	addi	a2,a2,-1634 # ffffffffc0205840 <commands+0x860>
ffffffffc0203eaa:	16600593          	li	a1,358
ffffffffc0203eae:	00002517          	auipc	a0,0x2
ffffffffc0203eb2:	72250513          	addi	a0,a0,1826 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203eb6:	b20fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203eba:	00003697          	auipc	a3,0x3
ffffffffc0203ebe:	a0668693          	addi	a3,a3,-1530 # ffffffffc02068c0 <default_pmm_manager+0x340>
ffffffffc0203ec2:	00002617          	auipc	a2,0x2
ffffffffc0203ec6:	97e60613          	addi	a2,a2,-1666 # ffffffffc0205840 <commands+0x860>
ffffffffc0203eca:	18200593          	li	a1,386
ffffffffc0203ece:	00002517          	auipc	a0,0x2
ffffffffc0203ed2:	70250513          	addi	a0,a0,1794 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203ed6:	b00fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203eda:	00003697          	auipc	a3,0x3
ffffffffc0203ede:	8a668693          	addi	a3,a3,-1882 # ffffffffc0206780 <default_pmm_manager+0x200>
ffffffffc0203ee2:	00002617          	auipc	a2,0x2
ffffffffc0203ee6:	95e60613          	addi	a2,a2,-1698 # ffffffffc0205840 <commands+0x860>
ffffffffc0203eea:	18100593          	li	a1,385
ffffffffc0203eee:	00002517          	auipc	a0,0x2
ffffffffc0203ef2:	6e250513          	addi	a0,a0,1762 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203ef6:	ae0fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203efa:	00003697          	auipc	a3,0x3
ffffffffc0203efe:	9de68693          	addi	a3,a3,-1570 # ffffffffc02068d8 <default_pmm_manager+0x358>
ffffffffc0203f02:	00002617          	auipc	a2,0x2
ffffffffc0203f06:	93e60613          	addi	a2,a2,-1730 # ffffffffc0205840 <commands+0x860>
ffffffffc0203f0a:	17e00593          	li	a1,382
ffffffffc0203f0e:	00002517          	auipc	a0,0x2
ffffffffc0203f12:	6c250513          	addi	a0,a0,1730 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203f16:	ac0fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203f1a:	00003697          	auipc	a3,0x3
ffffffffc0203f1e:	bbe68693          	addi	a3,a3,-1090 # ffffffffc0206ad8 <default_pmm_manager+0x558>
ffffffffc0203f22:	00002617          	auipc	a2,0x2
ffffffffc0203f26:	91e60613          	addi	a2,a2,-1762 # ffffffffc0205840 <commands+0x860>
ffffffffc0203f2a:	1af00593          	li	a1,431
ffffffffc0203f2e:	00002517          	auipc	a0,0x2
ffffffffc0203f32:	6a250513          	addi	a0,a0,1698 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203f36:	aa0fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203f3a:	00003697          	auipc	a3,0x3
ffffffffc0203f3e:	9f668693          	addi	a3,a3,-1546 # ffffffffc0206930 <default_pmm_manager+0x3b0>
ffffffffc0203f42:	00002617          	auipc	a2,0x2
ffffffffc0203f46:	8fe60613          	addi	a2,a2,-1794 # ffffffffc0205840 <commands+0x860>
ffffffffc0203f4a:	19000593          	li	a1,400
ffffffffc0203f4e:	00002517          	auipc	a0,0x2
ffffffffc0203f52:	68250513          	addi	a0,a0,1666 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203f56:	a80fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203f5a:	00003697          	auipc	a3,0x3
ffffffffc0203f5e:	a6e68693          	addi	a3,a3,-1426 # ffffffffc02069c8 <default_pmm_manager+0x448>
ffffffffc0203f62:	00002617          	auipc	a2,0x2
ffffffffc0203f66:	8de60613          	addi	a2,a2,-1826 # ffffffffc0205840 <commands+0x860>
ffffffffc0203f6a:	1a100593          	li	a1,417
ffffffffc0203f6e:	00002517          	auipc	a0,0x2
ffffffffc0203f72:	66250513          	addi	a0,a0,1634 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203f76:	a60fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203f7a:	00002697          	auipc	a3,0x2
ffffffffc0203f7e:	70e68693          	addi	a3,a3,1806 # ffffffffc0206688 <default_pmm_manager+0x108>
ffffffffc0203f82:	00002617          	auipc	a2,0x2
ffffffffc0203f86:	8be60613          	addi	a2,a2,-1858 # ffffffffc0205840 <commands+0x860>
ffffffffc0203f8a:	16000593          	li	a1,352
ffffffffc0203f8e:	00002517          	auipc	a0,0x2
ffffffffc0203f92:	64250513          	addi	a0,a0,1602 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203f96:	a40fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203f9a:	00002617          	auipc	a2,0x2
ffffffffc0203f9e:	e3e60613          	addi	a2,a2,-450 # ffffffffc0205dd8 <commands+0xdf8>
ffffffffc0203fa2:	0c300593          	li	a1,195
ffffffffc0203fa6:	00002517          	auipc	a0,0x2
ffffffffc0203faa:	62a50513          	addi	a0,a0,1578 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc0203fae:	a28fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0203fb2 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203fb2:	12058073          	sfence.vma	a1
}
ffffffffc0203fb6:	8082                	ret

ffffffffc0203fb8 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203fb8:	7179                	addi	sp,sp,-48
ffffffffc0203fba:	e84a                	sd	s2,16(sp)
ffffffffc0203fbc:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203fbe:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203fc0:	f022                	sd	s0,32(sp)
ffffffffc0203fc2:	ec26                	sd	s1,24(sp)
ffffffffc0203fc4:	e44e                	sd	s3,8(sp)
ffffffffc0203fc6:	f406                	sd	ra,40(sp)
ffffffffc0203fc8:	84ae                	mv	s1,a1
ffffffffc0203fca:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203fcc:	8e8ff0ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
ffffffffc0203fd0:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203fd2:	cd19                	beqz	a0,ffffffffc0203ff0 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203fd4:	85aa                	mv	a1,a0
ffffffffc0203fd6:	86ce                	mv	a3,s3
ffffffffc0203fd8:	8626                	mv	a2,s1
ffffffffc0203fda:	854a                	mv	a0,s2
ffffffffc0203fdc:	c8eff0ef          	jal	ra,ffffffffc020346a <page_insert>
ffffffffc0203fe0:	ed39                	bnez	a0,ffffffffc020403e <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0203fe2:	00011797          	auipc	a5,0x11
ffffffffc0203fe6:	4b678793          	addi	a5,a5,1206 # ffffffffc0215498 <swap_init_ok>
ffffffffc0203fea:	439c                	lw	a5,0(a5)
ffffffffc0203fec:	2781                	sext.w	a5,a5
ffffffffc0203fee:	eb89                	bnez	a5,ffffffffc0204000 <pgdir_alloc_page+0x48>
}
ffffffffc0203ff0:	8522                	mv	a0,s0
ffffffffc0203ff2:	70a2                	ld	ra,40(sp)
ffffffffc0203ff4:	7402                	ld	s0,32(sp)
ffffffffc0203ff6:	64e2                	ld	s1,24(sp)
ffffffffc0203ff8:	6942                	ld	s2,16(sp)
ffffffffc0203ffa:	69a2                	ld	s3,8(sp)
ffffffffc0203ffc:	6145                	addi	sp,sp,48
ffffffffc0203ffe:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204000:	00011797          	auipc	a5,0x11
ffffffffc0204004:	4d878793          	addi	a5,a5,1240 # ffffffffc02154d8 <check_mm_struct>
ffffffffc0204008:	6388                	ld	a0,0(a5)
ffffffffc020400a:	4681                	li	a3,0
ffffffffc020400c:	8622                	mv	a2,s0
ffffffffc020400e:	85a6                	mv	a1,s1
ffffffffc0204010:	b9cfe0ef          	jal	ra,ffffffffc02023ac <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0204014:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0204016:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0204018:	4785                	li	a5,1
ffffffffc020401a:	fcf70be3          	beq	a4,a5,ffffffffc0203ff0 <pgdir_alloc_page+0x38>
ffffffffc020401e:	00002697          	auipc	a3,0x2
ffffffffc0204022:	5c268693          	addi	a3,a3,1474 # ffffffffc02065e0 <default_pmm_manager+0x60>
ffffffffc0204026:	00002617          	auipc	a2,0x2
ffffffffc020402a:	81a60613          	addi	a2,a2,-2022 # ffffffffc0205840 <commands+0x860>
ffffffffc020402e:	14800593          	li	a1,328
ffffffffc0204032:	00002517          	auipc	a0,0x2
ffffffffc0204036:	59e50513          	addi	a0,a0,1438 # ffffffffc02065d0 <default_pmm_manager+0x50>
ffffffffc020403a:	99cfc0ef          	jal	ra,ffffffffc02001d6 <__panic>
            free_page(page);
ffffffffc020403e:	8522                	mv	a0,s0
ffffffffc0204040:	4585                	li	a1,1
ffffffffc0204042:	8faff0ef          	jal	ra,ffffffffc020313c <free_pages>
            return NULL;
ffffffffc0204046:	4401                	li	s0,0
ffffffffc0204048:	b765                	j	ffffffffc0203ff0 <pgdir_alloc_page+0x38>

ffffffffc020404a <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc020404a:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc020404c:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc020404e:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204050:	c62fc0ef          	jal	ra,ffffffffc02004b2 <ide_device_valid>
ffffffffc0204054:	cd01                	beqz	a0,ffffffffc020406c <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204056:	4505                	li	a0,1
ffffffffc0204058:	c60fc0ef          	jal	ra,ffffffffc02004b8 <ide_device_size>
}
ffffffffc020405c:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc020405e:	810d                	srli	a0,a0,0x3
ffffffffc0204060:	00011797          	auipc	a5,0x11
ffffffffc0204064:	50a7bc23          	sd	a0,1304(a5) # ffffffffc0215578 <max_swap_offset>
}
ffffffffc0204068:	0141                	addi	sp,sp,16
ffffffffc020406a:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc020406c:	00003617          	auipc	a2,0x3
ffffffffc0204070:	ab460613          	addi	a2,a2,-1356 # ffffffffc0206b20 <default_pmm_manager+0x5a0>
ffffffffc0204074:	45b5                	li	a1,13
ffffffffc0204076:	00003517          	auipc	a0,0x3
ffffffffc020407a:	aca50513          	addi	a0,a0,-1334 # ffffffffc0206b40 <default_pmm_manager+0x5c0>
ffffffffc020407e:	958fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc0204082 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204082:	1141                	addi	sp,sp,-16
ffffffffc0204084:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204086:	00855793          	srli	a5,a0,0x8
ffffffffc020408a:	cfb9                	beqz	a5,ffffffffc02040e8 <swapfs_read+0x66>
ffffffffc020408c:	00011717          	auipc	a4,0x11
ffffffffc0204090:	4ec70713          	addi	a4,a4,1260 # ffffffffc0215578 <max_swap_offset>
ffffffffc0204094:	6318                	ld	a4,0(a4)
ffffffffc0204096:	04e7f963          	bleu	a4,a5,ffffffffc02040e8 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc020409a:	00011717          	auipc	a4,0x11
ffffffffc020409e:	54e70713          	addi	a4,a4,1358 # ffffffffc02155e8 <pages>
ffffffffc02040a2:	6310                	ld	a2,0(a4)
ffffffffc02040a4:	00003717          	auipc	a4,0x3
ffffffffc02040a8:	ecc70713          	addi	a4,a4,-308 # ffffffffc0206f70 <nbase>
    return KADDR(page2pa(page));
ffffffffc02040ac:	00011697          	auipc	a3,0x11
ffffffffc02040b0:	3fc68693          	addi	a3,a3,1020 # ffffffffc02154a8 <npage>
    return page - pages + nbase;
ffffffffc02040b4:	40c58633          	sub	a2,a1,a2
ffffffffc02040b8:	630c                	ld	a1,0(a4)
ffffffffc02040ba:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc02040bc:	577d                	li	a4,-1
ffffffffc02040be:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc02040c0:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc02040c2:	8331                	srli	a4,a4,0xc
ffffffffc02040c4:	8f71                	and	a4,a4,a2
ffffffffc02040c6:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02040ca:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02040cc:	02d77a63          	bleu	a3,a4,ffffffffc0204100 <swapfs_read+0x7e>
ffffffffc02040d0:	00011797          	auipc	a5,0x11
ffffffffc02040d4:	50878793          	addi	a5,a5,1288 # ffffffffc02155d8 <va_pa_offset>
ffffffffc02040d8:	639c                	ld	a5,0(a5)
}
ffffffffc02040da:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040dc:	46a1                	li	a3,8
ffffffffc02040de:	963e                	add	a2,a2,a5
ffffffffc02040e0:	4505                	li	a0,1
}
ffffffffc02040e2:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040e4:	bdafc06f          	j	ffffffffc02004be <ide_read_secs>
ffffffffc02040e8:	86aa                	mv	a3,a0
ffffffffc02040ea:	00003617          	auipc	a2,0x3
ffffffffc02040ee:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0206b58 <default_pmm_manager+0x5d8>
ffffffffc02040f2:	45d1                	li	a1,20
ffffffffc02040f4:	00003517          	auipc	a0,0x3
ffffffffc02040f8:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0206b40 <default_pmm_manager+0x5c0>
ffffffffc02040fc:	8dafc0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0204100:	86b2                	mv	a3,a2
ffffffffc0204102:	06900593          	li	a1,105
ffffffffc0204106:	00002617          	auipc	a2,0x2
ffffffffc020410a:	a5a60613          	addi	a2,a2,-1446 # ffffffffc0205b60 <commands+0xb80>
ffffffffc020410e:	00002517          	auipc	a0,0x2
ffffffffc0204112:	a4250513          	addi	a0,a0,-1470 # ffffffffc0205b50 <commands+0xb70>
ffffffffc0204116:	8c0fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc020411a <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc020411a:	1141                	addi	sp,sp,-16
ffffffffc020411c:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020411e:	00855793          	srli	a5,a0,0x8
ffffffffc0204122:	cfb9                	beqz	a5,ffffffffc0204180 <swapfs_write+0x66>
ffffffffc0204124:	00011717          	auipc	a4,0x11
ffffffffc0204128:	45470713          	addi	a4,a4,1108 # ffffffffc0215578 <max_swap_offset>
ffffffffc020412c:	6318                	ld	a4,0(a4)
ffffffffc020412e:	04e7f963          	bleu	a4,a5,ffffffffc0204180 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204132:	00011717          	auipc	a4,0x11
ffffffffc0204136:	4b670713          	addi	a4,a4,1206 # ffffffffc02155e8 <pages>
ffffffffc020413a:	6310                	ld	a2,0(a4)
ffffffffc020413c:	00003717          	auipc	a4,0x3
ffffffffc0204140:	e3470713          	addi	a4,a4,-460 # ffffffffc0206f70 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204144:	00011697          	auipc	a3,0x11
ffffffffc0204148:	36468693          	addi	a3,a3,868 # ffffffffc02154a8 <npage>
    return page - pages + nbase;
ffffffffc020414c:	40c58633          	sub	a2,a1,a2
ffffffffc0204150:	630c                	ld	a1,0(a4)
ffffffffc0204152:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204154:	577d                	li	a4,-1
ffffffffc0204156:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204158:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc020415a:	8331                	srli	a4,a4,0xc
ffffffffc020415c:	8f71                	and	a4,a4,a2
ffffffffc020415e:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204162:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204164:	02d77a63          	bleu	a3,a4,ffffffffc0204198 <swapfs_write+0x7e>
ffffffffc0204168:	00011797          	auipc	a5,0x11
ffffffffc020416c:	47078793          	addi	a5,a5,1136 # ffffffffc02155d8 <va_pa_offset>
ffffffffc0204170:	639c                	ld	a5,0(a5)
}
ffffffffc0204172:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204174:	46a1                	li	a3,8
ffffffffc0204176:	963e                	add	a2,a2,a5
ffffffffc0204178:	4505                	li	a0,1
}
ffffffffc020417a:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020417c:	b66fc06f          	j	ffffffffc02004e2 <ide_write_secs>
ffffffffc0204180:	86aa                	mv	a3,a0
ffffffffc0204182:	00003617          	auipc	a2,0x3
ffffffffc0204186:	9d660613          	addi	a2,a2,-1578 # ffffffffc0206b58 <default_pmm_manager+0x5d8>
ffffffffc020418a:	45e5                	li	a1,25
ffffffffc020418c:	00003517          	auipc	a0,0x3
ffffffffc0204190:	9b450513          	addi	a0,a0,-1612 # ffffffffc0206b40 <default_pmm_manager+0x5c0>
ffffffffc0204194:	842fc0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0204198:	86b2                	mv	a3,a2
ffffffffc020419a:	06900593          	li	a1,105
ffffffffc020419e:	00002617          	auipc	a2,0x2
ffffffffc02041a2:	9c260613          	addi	a2,a2,-1598 # ffffffffc0205b60 <commands+0xb80>
ffffffffc02041a6:	00002517          	auipc	a0,0x2
ffffffffc02041aa:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0205b50 <commands+0xb70>
ffffffffc02041ae:	828fc0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02041b2 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02041b2:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc02041b6:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02041ba:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02041bc:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02041be:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02041c2:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02041c6:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02041ca:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02041ce:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02041d2:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02041d6:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02041da:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02041de:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02041e2:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02041e6:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02041ea:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02041ee:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02041f0:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02041f2:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02041f6:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02041fa:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02041fe:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204202:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204206:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc020420a:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020420e:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204212:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204216:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc020421a:	8082                	ret

ffffffffc020421c <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc020421c:	8526                	mv	a0,s1
	jalr s0
ffffffffc020421e:	9402                	jalr	s0

	jal do_exit
ffffffffc0204220:	46c000ef          	jal	ra,ffffffffc020468c <do_exit>

ffffffffc0204224 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204224:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204226:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc020422a:	e022                	sd	s0,0(sp)
ffffffffc020422c:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020422e:	81bfd0ef          	jal	ra,ffffffffc0201a48 <kmalloc>
ffffffffc0204232:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204234:	c529                	beqz	a0,ffffffffc020427e <alloc_proc+0x5a>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state=PROC_UNINIT;
ffffffffc0204236:	57fd                	li	a5,-1
ffffffffc0204238:	1782                	slli	a5,a5,0x20
ffffffffc020423a:	e11c                	sd	a5,0(a0)
        proc->kstack=0;
        proc->need_resched=0;
        proc->parent=NULL;
        proc->mm=NULL;
        proc->tf=NULL;
        proc->cr3=boot_cr3;
ffffffffc020423c:	00011797          	auipc	a5,0x11
ffffffffc0204240:	3a478793          	addi	a5,a5,932 # ffffffffc02155e0 <boot_cr3>
ffffffffc0204244:	639c                	ld	a5,0(a5)
        proc->flags=0;
        memset(proc->name,0,PROC_NAME_LEN+1);
ffffffffc0204246:	4641                	li	a2,16
ffffffffc0204248:	4581                	li	a1,0
        proc->runs=0;
ffffffffc020424a:	00052423          	sw	zero,8(a0)
        proc->kstack=0;
ffffffffc020424e:	00053823          	sd	zero,16(a0)
        proc->need_resched=0;
ffffffffc0204252:	00052c23          	sw	zero,24(a0)
        proc->parent=NULL;
ffffffffc0204256:	02053023          	sd	zero,32(a0)
        proc->mm=NULL;
ffffffffc020425a:	02053423          	sd	zero,40(a0)
        proc->tf=NULL;
ffffffffc020425e:	0a053023          	sd	zero,160(a0)
        proc->cr3=boot_cr3;
ffffffffc0204262:	f55c                	sd	a5,168(a0)
        proc->flags=0;
ffffffffc0204264:	0a052823          	sw	zero,176(a0)
        memset(proc->name,0,PROC_NAME_LEN+1);
ffffffffc0204268:	0b450513          	addi	a0,a0,180
ffffffffc020426c:	7b6000ef          	jal	ra,ffffffffc0204a22 <memset>
        memset(&(proc->context),0,sizeof(struct context));
ffffffffc0204270:	07000613          	li	a2,112
ffffffffc0204274:	4581                	li	a1,0
ffffffffc0204276:	03040513          	addi	a0,s0,48
ffffffffc020427a:	7a8000ef          	jal	ra,ffffffffc0204a22 <memset>
    }
    return proc;
}
ffffffffc020427e:	8522                	mv	a0,s0
ffffffffc0204280:	60a2                	ld	ra,8(sp)
ffffffffc0204282:	6402                	ld	s0,0(sp)
ffffffffc0204284:	0141                	addi	sp,sp,16
ffffffffc0204286:	8082                	ret

ffffffffc0204288 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204288:	00011797          	auipc	a5,0x11
ffffffffc020428c:	22878793          	addi	a5,a5,552 # ffffffffc02154b0 <current>
ffffffffc0204290:	639c                	ld	a5,0(a5)
ffffffffc0204292:	73c8                	ld	a0,160(a5)
ffffffffc0204294:	905fc06f          	j	ffffffffc0200b98 <forkrets>

ffffffffc0204298 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204298:	1101                	addi	sp,sp,-32
ffffffffc020429a:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020429c:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02042a0:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042a2:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02042a4:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042a6:	8522                	mv	a0,s0
ffffffffc02042a8:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02042aa:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042ac:	776000ef          	jal	ra,ffffffffc0204a22 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02042b0:	8522                	mv	a0,s0
}
ffffffffc02042b2:	6442                	ld	s0,16(sp)
ffffffffc02042b4:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02042b6:	85a6                	mv	a1,s1
}
ffffffffc02042b8:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02042ba:	463d                	li	a2,15
}
ffffffffc02042bc:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02042be:	7760006f          	j	ffffffffc0204a34 <memcpy>

ffffffffc02042c2 <get_proc_name>:
get_proc_name(struct proc_struct *proc) {
ffffffffc02042c2:	1101                	addi	sp,sp,-32
ffffffffc02042c4:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc02042c6:	00011417          	auipc	s0,0x11
ffffffffc02042ca:	19a40413          	addi	s0,s0,410 # ffffffffc0215460 <name.1565>
get_proc_name(struct proc_struct *proc) {
ffffffffc02042ce:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc02042d0:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc02042d2:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc02042d4:	4581                	li	a1,0
ffffffffc02042d6:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc02042d8:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02042da:	748000ef          	jal	ra,ffffffffc0204a22 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042de:	8522                	mv	a0,s0
}
ffffffffc02042e0:	6442                	ld	s0,16(sp)
ffffffffc02042e2:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042e4:	0b448593          	addi	a1,s1,180
}
ffffffffc02042e8:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042ea:	463d                	li	a2,15
}
ffffffffc02042ec:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042ee:	7460006f          	j	ffffffffc0204a34 <memcpy>

ffffffffc02042f2 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042f2:	00011797          	auipc	a5,0x11
ffffffffc02042f6:	1be78793          	addi	a5,a5,446 # ffffffffc02154b0 <current>
ffffffffc02042fa:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc02042fc:	1101                	addi	sp,sp,-32
ffffffffc02042fe:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204300:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc0204302:	e822                	sd	s0,16(sp)
ffffffffc0204304:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204306:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc0204308:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020430a:	fb9ff0ef          	jal	ra,ffffffffc02042c2 <get_proc_name>
ffffffffc020430e:	862a                	mv	a2,a0
ffffffffc0204310:	85a6                	mv	a1,s1
ffffffffc0204312:	00003517          	auipc	a0,0x3
ffffffffc0204316:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0206bc0 <default_pmm_manager+0x640>
ffffffffc020431a:	db7fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc020431e:	85a2                	mv	a1,s0
ffffffffc0204320:	00003517          	auipc	a0,0x3
ffffffffc0204324:	8c850513          	addi	a0,a0,-1848 # ffffffffc0206be8 <default_pmm_manager+0x668>
ffffffffc0204328:	da9fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc020432c:	00003517          	auipc	a0,0x3
ffffffffc0204330:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0206bf8 <default_pmm_manager+0x678>
ffffffffc0204334:	d9dfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc0204338:	60e2                	ld	ra,24(sp)
ffffffffc020433a:	6442                	ld	s0,16(sp)
ffffffffc020433c:	64a2                	ld	s1,8(sp)
ffffffffc020433e:	4501                	li	a0,0
ffffffffc0204340:	6105                	addi	sp,sp,32
ffffffffc0204342:	8082                	ret

ffffffffc0204344 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204344:	1101                	addi	sp,sp,-32
ffffffffc0204346:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204348:	00011497          	auipc	s1,0x11
ffffffffc020434c:	16848493          	addi	s1,s1,360 # ffffffffc02154b0 <current>
ffffffffc0204350:	6098                	ld	a4,0(s1)
proc_run(struct proc_struct *proc) {
ffffffffc0204352:	ec06                	sd	ra,24(sp)
ffffffffc0204354:	e822                	sd	s0,16(sp)
    if (proc != current) {
ffffffffc0204356:	02a70f63          	beq	a4,a0,ffffffffc0204394 <proc_run+0x50>
ffffffffc020435a:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020435c:	100027f3          	csrr	a5,sstatus
ffffffffc0204360:	8b89                	andi	a5,a5,2
ffffffffc0204362:	4681                	li	a3,0
ffffffffc0204364:	e3b9                	bnez	a5,ffffffffc02043aa <proc_run+0x66>
        lcr3(next->cr3);
ffffffffc0204366:	745c                	ld	a5,168(s0)
        local_intr_save(proc->flags);
ffffffffc0204368:	0ad42823          	sw	a3,176(s0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc020436c:	800006b7          	lui	a3,0x80000
ffffffffc0204370:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204374:	8fd5                	or	a5,a5,a3
        current=proc;
ffffffffc0204376:	00011697          	auipc	a3,0x11
ffffffffc020437a:	1286bd23          	sd	s0,314(a3) # ffffffffc02154b0 <current>
ffffffffc020437e:	18079073          	csrw	satp,a5
        switch_to(&(prev->context),&(next->context));
ffffffffc0204382:	03040593          	addi	a1,s0,48
ffffffffc0204386:	03070513          	addi	a0,a4,48
ffffffffc020438a:	e29ff0ef          	jal	ra,ffffffffc02041b2 <switch_to>
    if (flag) {
ffffffffc020438e:	0b042783          	lw	a5,176(s0)
ffffffffc0204392:	e791                	bnez	a5,ffffffffc020439e <proc_run+0x5a>
}
ffffffffc0204394:	60e2                	ld	ra,24(sp)
ffffffffc0204396:	6442                	ld	s0,16(sp)
ffffffffc0204398:	64a2                	ld	s1,8(sp)
ffffffffc020439a:	6105                	addi	sp,sp,32
ffffffffc020439c:	8082                	ret
ffffffffc020439e:	6442                	ld	s0,16(sp)
ffffffffc02043a0:	60e2                	ld	ra,24(sp)
ffffffffc02043a2:	64a2                	ld	s1,8(sp)
ffffffffc02043a4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02043a6:	a2efc06f          	j	ffffffffc02005d4 <intr_enable>
        intr_disable();
ffffffffc02043aa:	a30fc0ef          	jal	ra,ffffffffc02005da <intr_disable>
        return 1;
ffffffffc02043ae:	6098                	ld	a4,0(s1)
        intr_disable();
ffffffffc02043b0:	4685                	li	a3,1
ffffffffc02043b2:	bf55                	j	ffffffffc0204366 <proc_run+0x22>

ffffffffc02043b4 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc02043b4:	0005071b          	sext.w	a4,a0
ffffffffc02043b8:	6789                	lui	a5,0x2
ffffffffc02043ba:	fff7069b          	addiw	a3,a4,-1
ffffffffc02043be:	17f9                	addi	a5,a5,-2
ffffffffc02043c0:	04d7e063          	bltu	a5,a3,ffffffffc0204400 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc02043c4:	1141                	addi	sp,sp,-16
ffffffffc02043c6:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02043c8:	45a9                	li	a1,10
ffffffffc02043ca:	842a                	mv	s0,a0
ffffffffc02043cc:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc02043ce:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02043d0:	2a5000ef          	jal	ra,ffffffffc0204e74 <hash32>
ffffffffc02043d4:	02051693          	slli	a3,a0,0x20
ffffffffc02043d8:	82f1                	srli	a3,a3,0x1c
ffffffffc02043da:	0000d517          	auipc	a0,0xd
ffffffffc02043de:	08650513          	addi	a0,a0,134 # ffffffffc0211460 <hash_list>
ffffffffc02043e2:	96aa                	add	a3,a3,a0
ffffffffc02043e4:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc02043e6:	a029                	j	ffffffffc02043f0 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc02043e8:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc02043ec:	00870c63          	beq	a4,s0,ffffffffc0204404 <find_proc+0x50>
    return listelm->next;
ffffffffc02043f0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02043f2:	fef69be3          	bne	a3,a5,ffffffffc02043e8 <find_proc+0x34>
}
ffffffffc02043f6:	60a2                	ld	ra,8(sp)
ffffffffc02043f8:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02043fa:	4501                	li	a0,0
}
ffffffffc02043fc:	0141                	addi	sp,sp,16
ffffffffc02043fe:	8082                	ret
    return NULL;
ffffffffc0204400:	4501                	li	a0,0
}
ffffffffc0204402:	8082                	ret
ffffffffc0204404:	60a2                	ld	ra,8(sp)
ffffffffc0204406:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204408:	f2878513          	addi	a0,a5,-216
}
ffffffffc020440c:	0141                	addi	sp,sp,16
ffffffffc020440e:	8082                	ret

ffffffffc0204410 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204410:	7179                	addi	sp,sp,-48
ffffffffc0204412:	e84a                	sd	s2,16(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204414:	00011917          	auipc	s2,0x11
ffffffffc0204418:	0b490913          	addi	s2,s2,180 # ffffffffc02154c8 <nr_process>
ffffffffc020441c:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204420:	f406                	sd	ra,40(sp)
ffffffffc0204422:	f022                	sd	s0,32(sp)
ffffffffc0204424:	ec26                	sd	s1,24(sp)
ffffffffc0204426:	e44e                	sd	s3,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204428:	6785                	lui	a5,0x1
ffffffffc020442a:	1cf75963          	ble	a5,a4,ffffffffc02045fc <do_fork+0x1ec>
ffffffffc020442e:	89ae                	mv	s3,a1
ffffffffc0204430:	84b2                	mv	s1,a2
    if((proc=alloc_proc())==NULL){
ffffffffc0204432:	df3ff0ef          	jal	ra,ffffffffc0204224 <alloc_proc>
ffffffffc0204436:	842a                	mv	s0,a0
ffffffffc0204438:	1c050463          	beqz	a0,ffffffffc0204600 <do_fork+0x1f0>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020443c:	4509                	li	a0,2
ffffffffc020443e:	c77fe0ef          	jal	ra,ffffffffc02030b4 <alloc_pages>
    if (page != NULL) {
ffffffffc0204442:	1a050863          	beqz	a0,ffffffffc02045f2 <do_fork+0x1e2>
    return page - pages + nbase;
ffffffffc0204446:	00011797          	auipc	a5,0x11
ffffffffc020444a:	1a278793          	addi	a5,a5,418 # ffffffffc02155e8 <pages>
ffffffffc020444e:	6394                	ld	a3,0(a5)
ffffffffc0204450:	00003797          	auipc	a5,0x3
ffffffffc0204454:	b2078793          	addi	a5,a5,-1248 # ffffffffc0206f70 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204458:	00011717          	auipc	a4,0x11
ffffffffc020445c:	05070713          	addi	a4,a4,80 # ffffffffc02154a8 <npage>
    return page - pages + nbase;
ffffffffc0204460:	40d506b3          	sub	a3,a0,a3
ffffffffc0204464:	6388                	ld	a0,0(a5)
ffffffffc0204466:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204468:	57fd                	li	a5,-1
ffffffffc020446a:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc020446c:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc020446e:	83b1                	srli	a5,a5,0xc
ffffffffc0204470:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204472:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204474:	1ae7f863          	bleu	a4,a5,ffffffffc0204624 <do_fork+0x214>
    assert(current->mm == NULL);
ffffffffc0204478:	00011797          	auipc	a5,0x11
ffffffffc020447c:	03878793          	addi	a5,a5,56 # ffffffffc02154b0 <current>
ffffffffc0204480:	639c                	ld	a5,0(a5)
ffffffffc0204482:	00011717          	auipc	a4,0x11
ffffffffc0204486:	15670713          	addi	a4,a4,342 # ffffffffc02155d8 <va_pa_offset>
ffffffffc020448a:	6318                	ld	a4,0(a4)
ffffffffc020448c:	779c                	ld	a5,40(a5)
ffffffffc020448e:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204490:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc0204492:	16079963          	bnez	a5,ffffffffc0204604 <do_fork+0x1f4>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204496:	6789                	lui	a5,0x2
ffffffffc0204498:	ee078793          	addi	a5,a5,-288 # 1ee0 <BASE_ADDRESS-0xffffffffc01fe120>
ffffffffc020449c:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc020449e:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02044a0:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc02044a2:	87b6                	mv	a5,a3
ffffffffc02044a4:	12048893          	addi	a7,s1,288
ffffffffc02044a8:	00063803          	ld	a6,0(a2)
ffffffffc02044ac:	6608                	ld	a0,8(a2)
ffffffffc02044ae:	6a0c                	ld	a1,16(a2)
ffffffffc02044b0:	6e18                	ld	a4,24(a2)
ffffffffc02044b2:	0107b023          	sd	a6,0(a5)
ffffffffc02044b6:	e788                	sd	a0,8(a5)
ffffffffc02044b8:	eb8c                	sd	a1,16(a5)
ffffffffc02044ba:	ef98                	sd	a4,24(a5)
ffffffffc02044bc:	02060613          	addi	a2,a2,32
ffffffffc02044c0:	02078793          	addi	a5,a5,32
ffffffffc02044c4:	ff1612e3          	bne	a2,a7,ffffffffc02044a8 <do_fork+0x98>
    proc->tf->gpr.a0 = 0;
ffffffffc02044c8:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044cc:	10098563          	beqz	s3,ffffffffc02045d6 <do_fork+0x1c6>
    if (++ last_pid >= MAX_PID) {
ffffffffc02044d0:	00006797          	auipc	a5,0x6
ffffffffc02044d4:	b8878793          	addi	a5,a5,-1144 # ffffffffc020a058 <last_pid.1575>
ffffffffc02044d8:	439c                	lw	a5,0(a5)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044da:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044de:	00000717          	auipc	a4,0x0
ffffffffc02044e2:	daa70713          	addi	a4,a4,-598 # ffffffffc0204288 <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc02044e6:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044ea:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02044ec:	fc14                	sd	a3,56(s0)
    if (++ last_pid >= MAX_PID) {
ffffffffc02044ee:	00006717          	auipc	a4,0x6
ffffffffc02044f2:	b6a72523          	sw	a0,-1174(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc02044f6:	6789                	lui	a5,0x2
ffffffffc02044f8:	0ef55163          	ble	a5,a0,ffffffffc02045da <do_fork+0x1ca>
    if (last_pid >= next_safe) {
ffffffffc02044fc:	00006797          	auipc	a5,0x6
ffffffffc0204500:	b6078793          	addi	a5,a5,-1184 # ffffffffc020a05c <next_safe.1574>
ffffffffc0204504:	439c                	lw	a5,0(a5)
ffffffffc0204506:	00011497          	auipc	s1,0x11
ffffffffc020450a:	0ea48493          	addi	s1,s1,234 # ffffffffc02155f0 <proc_list>
ffffffffc020450e:	06f54063          	blt	a0,a5,ffffffffc020456e <do_fork+0x15e>
        next_safe = MAX_PID;
ffffffffc0204512:	6789                	lui	a5,0x2
ffffffffc0204514:	00006717          	auipc	a4,0x6
ffffffffc0204518:	b4f72423          	sw	a5,-1208(a4) # ffffffffc020a05c <next_safe.1574>
ffffffffc020451c:	4581                	li	a1,0
ffffffffc020451e:	87aa                	mv	a5,a0
ffffffffc0204520:	00011497          	auipc	s1,0x11
ffffffffc0204524:	0d048493          	addi	s1,s1,208 # ffffffffc02155f0 <proc_list>
    repeat:
ffffffffc0204528:	6889                	lui	a7,0x2
ffffffffc020452a:	882e                	mv	a6,a1
ffffffffc020452c:	6609                	lui	a2,0x2
        le = list;
ffffffffc020452e:	00011697          	auipc	a3,0x11
ffffffffc0204532:	0c268693          	addi	a3,a3,194 # ffffffffc02155f0 <proc_list>
ffffffffc0204536:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0204538:	00968f63          	beq	a3,s1,ffffffffc0204556 <do_fork+0x146>
            if (proc->pid == last_pid) {
ffffffffc020453c:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0204540:	08e78663          	beq	a5,a4,ffffffffc02045cc <do_fork+0x1bc>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204544:	fee7d9e3          	ble	a4,a5,ffffffffc0204536 <do_fork+0x126>
ffffffffc0204548:	fec757e3          	ble	a2,a4,ffffffffc0204536 <do_fork+0x126>
ffffffffc020454c:	6694                	ld	a3,8(a3)
ffffffffc020454e:	863a                	mv	a2,a4
ffffffffc0204550:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0204552:	fe9695e3          	bne	a3,s1,ffffffffc020453c <do_fork+0x12c>
ffffffffc0204556:	c591                	beqz	a1,ffffffffc0204562 <do_fork+0x152>
ffffffffc0204558:	00006717          	auipc	a4,0x6
ffffffffc020455c:	b0f72023          	sw	a5,-1280(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc0204560:	853e                	mv	a0,a5
ffffffffc0204562:	00080663          	beqz	a6,ffffffffc020456e <do_fork+0x15e>
ffffffffc0204566:	00006797          	auipc	a5,0x6
ffffffffc020456a:	aec7ab23          	sw	a2,-1290(a5) # ffffffffc020a05c <next_safe.1574>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020456e:	45a9                	li	a1,10
    proc->pid=get_pid();
ffffffffc0204570:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204572:	2501                	sext.w	a0,a0
ffffffffc0204574:	101000ef          	jal	ra,ffffffffc0204e74 <hash32>
ffffffffc0204578:	1502                	slli	a0,a0,0x20
ffffffffc020457a:	0000d797          	auipc	a5,0xd
ffffffffc020457e:	ee678793          	addi	a5,a5,-282 # ffffffffc0211460 <hash_list>
ffffffffc0204582:	8171                	srli	a0,a0,0x1c
ffffffffc0204584:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204586:	6518                	ld	a4,8(a0)
ffffffffc0204588:	0d840793          	addi	a5,s0,216
ffffffffc020458c:	6494                	ld	a3,8(s1)
    prev->next = next->prev = elm;
ffffffffc020458e:	e31c                	sd	a5,0(a4)
ffffffffc0204590:	e51c                	sd	a5,8(a0)
    nr_process++;
ffffffffc0204592:	00092783          	lw	a5,0(s2)
    elm->next = next;
ffffffffc0204596:	f078                	sd	a4,224(s0)
    elm->prev = prev;
ffffffffc0204598:	ec68                	sd	a0,216(s0)
    list_add(&proc_list,&(proc->list_link));
ffffffffc020459a:	0c840713          	addi	a4,s0,200
    prev->next = next->prev = elm;
ffffffffc020459e:	e298                	sd	a4,0(a3)
    nr_process++;
ffffffffc02045a0:	2785                	addiw	a5,a5,1
    elm->next = next;
ffffffffc02045a2:	e874                	sd	a3,208(s0)
    wakeup_proc(proc);
ffffffffc02045a4:	8522                	mv	a0,s0
    elm->prev = prev;
ffffffffc02045a6:	e464                	sd	s1,200(s0)
    prev->next = next->prev = elm;
ffffffffc02045a8:	00011697          	auipc	a3,0x11
ffffffffc02045ac:	04e6b823          	sd	a4,80(a3) # ffffffffc02155f8 <proc_list+0x8>
    nr_process++;
ffffffffc02045b0:	00011717          	auipc	a4,0x11
ffffffffc02045b4:	f0f72c23          	sw	a5,-232(a4) # ffffffffc02154c8 <nr_process>
    wakeup_proc(proc);
ffffffffc02045b8:	300000ef          	jal	ra,ffffffffc02048b8 <wakeup_proc>
    ret=proc->pid;
ffffffffc02045bc:	4048                	lw	a0,4(s0)
}
ffffffffc02045be:	70a2                	ld	ra,40(sp)
ffffffffc02045c0:	7402                	ld	s0,32(sp)
ffffffffc02045c2:	64e2                	ld	s1,24(sp)
ffffffffc02045c4:	6942                	ld	s2,16(sp)
ffffffffc02045c6:	69a2                	ld	s3,8(sp)
ffffffffc02045c8:	6145                	addi	sp,sp,48
ffffffffc02045ca:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc02045cc:	2785                	addiw	a5,a5,1
ffffffffc02045ce:	00c7dd63          	ble	a2,a5,ffffffffc02045e8 <do_fork+0x1d8>
ffffffffc02045d2:	4585                	li	a1,1
ffffffffc02045d4:	b78d                	j	ffffffffc0204536 <do_fork+0x126>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02045d6:	89b6                	mv	s3,a3
ffffffffc02045d8:	bde5                	j	ffffffffc02044d0 <do_fork+0xc0>
        last_pid = 1;
ffffffffc02045da:	4785                	li	a5,1
ffffffffc02045dc:	00006717          	auipc	a4,0x6
ffffffffc02045e0:	a6f72e23          	sw	a5,-1412(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc02045e4:	4505                	li	a0,1
ffffffffc02045e6:	b735                	j	ffffffffc0204512 <do_fork+0x102>
                    if (last_pid >= MAX_PID) {
ffffffffc02045e8:	0117c363          	blt	a5,a7,ffffffffc02045ee <do_fork+0x1de>
                        last_pid = 1;
ffffffffc02045ec:	4785                	li	a5,1
                    goto repeat;
ffffffffc02045ee:	4585                	li	a1,1
ffffffffc02045f0:	bf2d                	j	ffffffffc020452a <do_fork+0x11a>
    kfree(proc);
ffffffffc02045f2:	8522                	mv	a0,s0
ffffffffc02045f4:	d10fd0ef          	jal	ra,ffffffffc0201b04 <kfree>
    ret = -E_NO_MEM;
ffffffffc02045f8:	5571                	li	a0,-4
    goto fork_out;
ffffffffc02045fa:	b7d1                	j	ffffffffc02045be <do_fork+0x1ae>
    int ret = -E_NO_FREE_PROC;
ffffffffc02045fc:	556d                	li	a0,-5
ffffffffc02045fe:	b7c1                	j	ffffffffc02045be <do_fork+0x1ae>
    ret = -E_NO_MEM;
ffffffffc0204600:	5571                	li	a0,-4
ffffffffc0204602:	bf75                	j	ffffffffc02045be <do_fork+0x1ae>
    assert(current->mm == NULL);
ffffffffc0204604:	00002697          	auipc	a3,0x2
ffffffffc0204608:	58c68693          	addi	a3,a3,1420 # ffffffffc0206b90 <default_pmm_manager+0x610>
ffffffffc020460c:	00001617          	auipc	a2,0x1
ffffffffc0204610:	23460613          	addi	a2,a2,564 # ffffffffc0205840 <commands+0x860>
ffffffffc0204614:	10700593          	li	a1,263
ffffffffc0204618:	00002517          	auipc	a0,0x2
ffffffffc020461c:	59050513          	addi	a0,a0,1424 # ffffffffc0206ba8 <default_pmm_manager+0x628>
ffffffffc0204620:	bb7fb0ef          	jal	ra,ffffffffc02001d6 <__panic>
ffffffffc0204624:	00001617          	auipc	a2,0x1
ffffffffc0204628:	53c60613          	addi	a2,a2,1340 # ffffffffc0205b60 <commands+0xb80>
ffffffffc020462c:	06900593          	li	a1,105
ffffffffc0204630:	00001517          	auipc	a0,0x1
ffffffffc0204634:	52050513          	addi	a0,a0,1312 # ffffffffc0205b50 <commands+0xb70>
ffffffffc0204638:	b9ffb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc020463c <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020463c:	7129                	addi	sp,sp,-320
ffffffffc020463e:	fa22                	sd	s0,304(sp)
ffffffffc0204640:	f626                	sd	s1,296(sp)
ffffffffc0204642:	f24a                	sd	s2,288(sp)
ffffffffc0204644:	84ae                	mv	s1,a1
ffffffffc0204646:	892a                	mv	s2,a0
ffffffffc0204648:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020464a:	4581                	li	a1,0
ffffffffc020464c:	12000613          	li	a2,288
ffffffffc0204650:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204652:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204654:	3ce000ef          	jal	ra,ffffffffc0204a22 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204658:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020465a:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020465c:	100027f3          	csrr	a5,sstatus
ffffffffc0204660:	edd7f793          	andi	a5,a5,-291
ffffffffc0204664:	1207e793          	ori	a5,a5,288
ffffffffc0204668:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020466a:	860a                	mv	a2,sp
ffffffffc020466c:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204670:	00000797          	auipc	a5,0x0
ffffffffc0204674:	bac78793          	addi	a5,a5,-1108 # ffffffffc020421c <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204678:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020467a:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020467c:	d95ff0ef          	jal	ra,ffffffffc0204410 <do_fork>
}
ffffffffc0204680:	70f2                	ld	ra,312(sp)
ffffffffc0204682:	7452                	ld	s0,304(sp)
ffffffffc0204684:	74b2                	ld	s1,296(sp)
ffffffffc0204686:	7912                	ld	s2,288(sp)
ffffffffc0204688:	6131                	addi	sp,sp,320
ffffffffc020468a:	8082                	ret

ffffffffc020468c <do_exit>:
do_exit(int error_code) {
ffffffffc020468c:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc020468e:	00002617          	auipc	a2,0x2
ffffffffc0204692:	4ea60613          	addi	a2,a2,1258 # ffffffffc0206b78 <default_pmm_manager+0x5f8>
ffffffffc0204696:	16300593          	li	a1,355
ffffffffc020469a:	00002517          	auipc	a0,0x2
ffffffffc020469e:	50e50513          	addi	a0,a0,1294 # ffffffffc0206ba8 <default_pmm_manager+0x628>
do_exit(int error_code) {
ffffffffc02046a2:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc02046a4:	b33fb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02046a8 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc02046a8:	00011797          	auipc	a5,0x11
ffffffffc02046ac:	f4878793          	addi	a5,a5,-184 # ffffffffc02155f0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc02046b0:	1101                	addi	sp,sp,-32
ffffffffc02046b2:	00011717          	auipc	a4,0x11
ffffffffc02046b6:	f4f73323          	sd	a5,-186(a4) # ffffffffc02155f8 <proc_list+0x8>
ffffffffc02046ba:	00011717          	auipc	a4,0x11
ffffffffc02046be:	f2f73b23          	sd	a5,-202(a4) # ffffffffc02155f0 <proc_list>
ffffffffc02046c2:	ec06                	sd	ra,24(sp)
ffffffffc02046c4:	e822                	sd	s0,16(sp)
ffffffffc02046c6:	e426                	sd	s1,8(sp)
ffffffffc02046c8:	e04a                	sd	s2,0(sp)
ffffffffc02046ca:	0000d797          	auipc	a5,0xd
ffffffffc02046ce:	d9678793          	addi	a5,a5,-618 # ffffffffc0211460 <hash_list>
ffffffffc02046d2:	00011717          	auipc	a4,0x11
ffffffffc02046d6:	d8e70713          	addi	a4,a4,-626 # ffffffffc0215460 <name.1565>
ffffffffc02046da:	e79c                	sd	a5,8(a5)
ffffffffc02046dc:	e39c                	sd	a5,0(a5)
ffffffffc02046de:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc02046e0:	fee79de3          	bne	a5,a4,ffffffffc02046da <proc_init+0x32>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02046e4:	b41ff0ef          	jal	ra,ffffffffc0204224 <alloc_proc>
ffffffffc02046e8:	00011797          	auipc	a5,0x11
ffffffffc02046ec:	dca7b823          	sd	a0,-560(a5) # ffffffffc02154b8 <idleproc>
ffffffffc02046f0:	00011417          	auipc	s0,0x11
ffffffffc02046f4:	dc840413          	addi	s0,s0,-568 # ffffffffc02154b8 <idleproc>
ffffffffc02046f8:	12050a63          	beqz	a0,ffffffffc020482c <proc_init+0x184>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02046fc:	07000513          	li	a0,112
ffffffffc0204700:	b48fd0ef          	jal	ra,ffffffffc0201a48 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204704:	07000613          	li	a2,112
ffffffffc0204708:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc020470a:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020470c:	316000ef          	jal	ra,ffffffffc0204a22 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc0204710:	6008                	ld	a0,0(s0)
ffffffffc0204712:	85a6                	mv	a1,s1
ffffffffc0204714:	07000613          	li	a2,112
ffffffffc0204718:	03050513          	addi	a0,a0,48
ffffffffc020471c:	330000ef          	jal	ra,ffffffffc0204a4c <memcmp>
ffffffffc0204720:	892a                	mv	s2,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204722:	453d                	li	a0,15
ffffffffc0204724:	b24fd0ef          	jal	ra,ffffffffc0201a48 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204728:	463d                	li	a2,15
ffffffffc020472a:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc020472c:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020472e:	2f4000ef          	jal	ra,ffffffffc0204a22 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc0204732:	6008                	ld	a0,0(s0)
ffffffffc0204734:	463d                	li	a2,15
ffffffffc0204736:	85a6                	mv	a1,s1
ffffffffc0204738:	0b450513          	addi	a0,a0,180
ffffffffc020473c:	310000ef          	jal	ra,ffffffffc0204a4c <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204740:	601c                	ld	a5,0(s0)
ffffffffc0204742:	00011717          	auipc	a4,0x11
ffffffffc0204746:	e9e70713          	addi	a4,a4,-354 # ffffffffc02155e0 <boot_cr3>
ffffffffc020474a:	6318                	ld	a4,0(a4)
ffffffffc020474c:	77d4                	ld	a3,168(a5)
ffffffffc020474e:	08e68e63          	beq	a3,a4,ffffffffc02047ea <proc_init+0x142>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204752:	4709                	li	a4,2
ffffffffc0204754:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204756:	00003717          	auipc	a4,0x3
ffffffffc020475a:	8aa70713          	addi	a4,a4,-1878 # ffffffffc0207000 <bootstack>
ffffffffc020475e:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc0204760:	4705                	li	a4,1
ffffffffc0204762:	cf98                	sw	a4,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc0204764:	00002597          	auipc	a1,0x2
ffffffffc0204768:	4e458593          	addi	a1,a1,1252 # ffffffffc0206c48 <default_pmm_manager+0x6c8>
ffffffffc020476c:	853e                	mv	a0,a5
ffffffffc020476e:	b2bff0ef          	jal	ra,ffffffffc0204298 <set_proc_name>
    nr_process ++;
ffffffffc0204772:	00011797          	auipc	a5,0x11
ffffffffc0204776:	d5678793          	addi	a5,a5,-682 # ffffffffc02154c8 <nr_process>
ffffffffc020477a:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc020477c:	6018                	ld	a4,0(s0)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020477e:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204780:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204782:	00002597          	auipc	a1,0x2
ffffffffc0204786:	4ce58593          	addi	a1,a1,1230 # ffffffffc0206c50 <default_pmm_manager+0x6d0>
ffffffffc020478a:	00000517          	auipc	a0,0x0
ffffffffc020478e:	b6850513          	addi	a0,a0,-1176 # ffffffffc02042f2 <init_main>
    nr_process ++;
ffffffffc0204792:	00011697          	auipc	a3,0x11
ffffffffc0204796:	d2f6ab23          	sw	a5,-714(a3) # ffffffffc02154c8 <nr_process>
    current = idleproc;
ffffffffc020479a:	00011797          	auipc	a5,0x11
ffffffffc020479e:	d0e7bb23          	sd	a4,-746(a5) # ffffffffc02154b0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02047a2:	e9bff0ef          	jal	ra,ffffffffc020463c <kernel_thread>
    if (pid <= 0) {
ffffffffc02047a6:	0ca05f63          	blez	a0,ffffffffc0204884 <proc_init+0x1dc>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02047aa:	c0bff0ef          	jal	ra,ffffffffc02043b4 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc02047ae:	00002597          	auipc	a1,0x2
ffffffffc02047b2:	4d258593          	addi	a1,a1,1234 # ffffffffc0206c80 <default_pmm_manager+0x700>
    initproc = find_proc(pid);
ffffffffc02047b6:	00011797          	auipc	a5,0x11
ffffffffc02047ba:	d0a7b523          	sd	a0,-758(a5) # ffffffffc02154c0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc02047be:	adbff0ef          	jal	ra,ffffffffc0204298 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02047c2:	601c                	ld	a5,0(s0)
ffffffffc02047c4:	c3c5                	beqz	a5,ffffffffc0204864 <proc_init+0x1bc>
ffffffffc02047c6:	43dc                	lw	a5,4(a5)
ffffffffc02047c8:	efd1                	bnez	a5,ffffffffc0204864 <proc_init+0x1bc>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02047ca:	00011797          	auipc	a5,0x11
ffffffffc02047ce:	cf678793          	addi	a5,a5,-778 # ffffffffc02154c0 <initproc>
ffffffffc02047d2:	639c                	ld	a5,0(a5)
ffffffffc02047d4:	cba5                	beqz	a5,ffffffffc0204844 <proc_init+0x19c>
ffffffffc02047d6:	43d8                	lw	a4,4(a5)
ffffffffc02047d8:	4785                	li	a5,1
ffffffffc02047da:	06f71563          	bne	a4,a5,ffffffffc0204844 <proc_init+0x19c>
}
ffffffffc02047de:	60e2                	ld	ra,24(sp)
ffffffffc02047e0:	6442                	ld	s0,16(sp)
ffffffffc02047e2:	64a2                	ld	s1,8(sp)
ffffffffc02047e4:	6902                	ld	s2,0(sp)
ffffffffc02047e6:	6105                	addi	sp,sp,32
ffffffffc02047e8:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02047ea:	73d8                	ld	a4,160(a5)
ffffffffc02047ec:	f33d                	bnez	a4,ffffffffc0204752 <proc_init+0xaa>
ffffffffc02047ee:	f60912e3          	bnez	s2,ffffffffc0204752 <proc_init+0xaa>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02047f2:	6394                	ld	a3,0(a5)
ffffffffc02047f4:	577d                	li	a4,-1
ffffffffc02047f6:	1702                	slli	a4,a4,0x20
ffffffffc02047f8:	f4e69de3          	bne	a3,a4,ffffffffc0204752 <proc_init+0xaa>
ffffffffc02047fc:	4798                	lw	a4,8(a5)
ffffffffc02047fe:	fb31                	bnez	a4,ffffffffc0204752 <proc_init+0xaa>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc0204800:	6b98                	ld	a4,16(a5)
ffffffffc0204802:	fb21                	bnez	a4,ffffffffc0204752 <proc_init+0xaa>
ffffffffc0204804:	4f98                	lw	a4,24(a5)
ffffffffc0204806:	2701                	sext.w	a4,a4
ffffffffc0204808:	f729                	bnez	a4,ffffffffc0204752 <proc_init+0xaa>
ffffffffc020480a:	7398                	ld	a4,32(a5)
ffffffffc020480c:	f339                	bnez	a4,ffffffffc0204752 <proc_init+0xaa>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc020480e:	7798                	ld	a4,40(a5)
ffffffffc0204810:	f329                	bnez	a4,ffffffffc0204752 <proc_init+0xaa>
ffffffffc0204812:	0b07a703          	lw	a4,176(a5)
ffffffffc0204816:	8f49                	or	a4,a4,a0
ffffffffc0204818:	2701                	sext.w	a4,a4
ffffffffc020481a:	ff05                	bnez	a4,ffffffffc0204752 <proc_init+0xaa>
        cprintf("alloc_proc() correct!\n");
ffffffffc020481c:	00002517          	auipc	a0,0x2
ffffffffc0204820:	41450513          	addi	a0,a0,1044 # ffffffffc0206c30 <default_pmm_manager+0x6b0>
ffffffffc0204824:	8adfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204828:	601c                	ld	a5,0(s0)
ffffffffc020482a:	b725                	j	ffffffffc0204752 <proc_init+0xaa>
        panic("cannot alloc idleproc.\n");
ffffffffc020482c:	00002617          	auipc	a2,0x2
ffffffffc0204830:	3ec60613          	addi	a2,a2,1004 # ffffffffc0206c18 <default_pmm_manager+0x698>
ffffffffc0204834:	17b00593          	li	a1,379
ffffffffc0204838:	00002517          	auipc	a0,0x2
ffffffffc020483c:	37050513          	addi	a0,a0,880 # ffffffffc0206ba8 <default_pmm_manager+0x628>
ffffffffc0204840:	997fb0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204844:	00002697          	auipc	a3,0x2
ffffffffc0204848:	46c68693          	addi	a3,a3,1132 # ffffffffc0206cb0 <default_pmm_manager+0x730>
ffffffffc020484c:	00001617          	auipc	a2,0x1
ffffffffc0204850:	ff460613          	addi	a2,a2,-12 # ffffffffc0205840 <commands+0x860>
ffffffffc0204854:	1a200593          	li	a1,418
ffffffffc0204858:	00002517          	auipc	a0,0x2
ffffffffc020485c:	35050513          	addi	a0,a0,848 # ffffffffc0206ba8 <default_pmm_manager+0x628>
ffffffffc0204860:	977fb0ef          	jal	ra,ffffffffc02001d6 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204864:	00002697          	auipc	a3,0x2
ffffffffc0204868:	42468693          	addi	a3,a3,1060 # ffffffffc0206c88 <default_pmm_manager+0x708>
ffffffffc020486c:	00001617          	auipc	a2,0x1
ffffffffc0204870:	fd460613          	addi	a2,a2,-44 # ffffffffc0205840 <commands+0x860>
ffffffffc0204874:	1a100593          	li	a1,417
ffffffffc0204878:	00002517          	auipc	a0,0x2
ffffffffc020487c:	33050513          	addi	a0,a0,816 # ffffffffc0206ba8 <default_pmm_manager+0x628>
ffffffffc0204880:	957fb0ef          	jal	ra,ffffffffc02001d6 <__panic>
        panic("create init_main failed.\n");
ffffffffc0204884:	00002617          	auipc	a2,0x2
ffffffffc0204888:	3dc60613          	addi	a2,a2,988 # ffffffffc0206c60 <default_pmm_manager+0x6e0>
ffffffffc020488c:	19b00593          	li	a1,411
ffffffffc0204890:	00002517          	auipc	a0,0x2
ffffffffc0204894:	31850513          	addi	a0,a0,792 # ffffffffc0206ba8 <default_pmm_manager+0x628>
ffffffffc0204898:	93ffb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc020489c <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc020489c:	1141                	addi	sp,sp,-16
ffffffffc020489e:	e022                	sd	s0,0(sp)
ffffffffc02048a0:	e406                	sd	ra,8(sp)
ffffffffc02048a2:	00011417          	auipc	s0,0x11
ffffffffc02048a6:	c0e40413          	addi	s0,s0,-1010 # ffffffffc02154b0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02048aa:	6018                	ld	a4,0(s0)
ffffffffc02048ac:	4f1c                	lw	a5,24(a4)
ffffffffc02048ae:	2781                	sext.w	a5,a5
ffffffffc02048b0:	dff5                	beqz	a5,ffffffffc02048ac <cpu_idle+0x10>
            schedule();
ffffffffc02048b2:	038000ef          	jal	ra,ffffffffc02048ea <schedule>
ffffffffc02048b6:	bfd5                	j	ffffffffc02048aa <cpu_idle+0xe>

ffffffffc02048b8 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02048b8:	411c                	lw	a5,0(a0)
ffffffffc02048ba:	4705                	li	a4,1
ffffffffc02048bc:	37f9                	addiw	a5,a5,-2
ffffffffc02048be:	00f77563          	bleu	a5,a4,ffffffffc02048c8 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc02048c2:	4789                	li	a5,2
ffffffffc02048c4:	c11c                	sw	a5,0(a0)
ffffffffc02048c6:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc02048c8:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02048ca:	00002697          	auipc	a3,0x2
ffffffffc02048ce:	40e68693          	addi	a3,a3,1038 # ffffffffc0206cd8 <default_pmm_manager+0x758>
ffffffffc02048d2:	00001617          	auipc	a2,0x1
ffffffffc02048d6:	f6e60613          	addi	a2,a2,-146 # ffffffffc0205840 <commands+0x860>
ffffffffc02048da:	45a5                	li	a1,9
ffffffffc02048dc:	00002517          	auipc	a0,0x2
ffffffffc02048e0:	43c50513          	addi	a0,a0,1084 # ffffffffc0206d18 <default_pmm_manager+0x798>
wakeup_proc(struct proc_struct *proc) {
ffffffffc02048e4:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02048e6:	8f1fb0ef          	jal	ra,ffffffffc02001d6 <__panic>

ffffffffc02048ea <schedule>:
}

void
schedule(void) {
ffffffffc02048ea:	1141                	addi	sp,sp,-16
ffffffffc02048ec:	e406                	sd	ra,8(sp)
ffffffffc02048ee:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02048f0:	100027f3          	csrr	a5,sstatus
ffffffffc02048f4:	8b89                	andi	a5,a5,2
ffffffffc02048f6:	4401                	li	s0,0
ffffffffc02048f8:	e3d1                	bnez	a5,ffffffffc020497c <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02048fa:	00011797          	auipc	a5,0x11
ffffffffc02048fe:	bb678793          	addi	a5,a5,-1098 # ffffffffc02154b0 <current>
ffffffffc0204902:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204906:	00011797          	auipc	a5,0x11
ffffffffc020490a:	bb278793          	addi	a5,a5,-1102 # ffffffffc02154b8 <idleproc>
ffffffffc020490e:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0204910:	0008ac23          	sw	zero,24(a7) # 2018 <BASE_ADDRESS-0xffffffffc01fdfe8>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204914:	04a88e63          	beq	a7,a0,ffffffffc0204970 <schedule+0x86>
ffffffffc0204918:	0c888693          	addi	a3,a7,200
ffffffffc020491c:	00011617          	auipc	a2,0x11
ffffffffc0204920:	cd460613          	addi	a2,a2,-812 # ffffffffc02155f0 <proc_list>
        le = last;
ffffffffc0204924:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0204926:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204928:	4809                	li	a6,2
    return listelm->next;
ffffffffc020492a:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc020492c:	00c78863          	beq	a5,a2,ffffffffc020493c <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204930:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0204934:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204938:	01070463          	beq	a4,a6,ffffffffc0204940 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc020493c:	fef697e3          	bne	a3,a5,ffffffffc020492a <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204940:	c589                	beqz	a1,ffffffffc020494a <schedule+0x60>
ffffffffc0204942:	4198                	lw	a4,0(a1)
ffffffffc0204944:	4789                	li	a5,2
ffffffffc0204946:	00f70e63          	beq	a4,a5,ffffffffc0204962 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020494a:	451c                	lw	a5,8(a0)
ffffffffc020494c:	2785                	addiw	a5,a5,1
ffffffffc020494e:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0204950:	00a88463          	beq	a7,a0,ffffffffc0204958 <schedule+0x6e>
            proc_run(next);
ffffffffc0204954:	9f1ff0ef          	jal	ra,ffffffffc0204344 <proc_run>
    if (flag) {
ffffffffc0204958:	e419                	bnez	s0,ffffffffc0204966 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020495a:	60a2                	ld	ra,8(sp)
ffffffffc020495c:	6402                	ld	s0,0(sp)
ffffffffc020495e:	0141                	addi	sp,sp,16
ffffffffc0204960:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204962:	852e                	mv	a0,a1
ffffffffc0204964:	b7dd                	j	ffffffffc020494a <schedule+0x60>
}
ffffffffc0204966:	6402                	ld	s0,0(sp)
ffffffffc0204968:	60a2                	ld	ra,8(sp)
ffffffffc020496a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020496c:	c69fb06f          	j	ffffffffc02005d4 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204970:	00011617          	auipc	a2,0x11
ffffffffc0204974:	c8060613          	addi	a2,a2,-896 # ffffffffc02155f0 <proc_list>
ffffffffc0204978:	86b2                	mv	a3,a2
ffffffffc020497a:	b76d                	j	ffffffffc0204924 <schedule+0x3a>
        intr_disable();
ffffffffc020497c:	c5ffb0ef          	jal	ra,ffffffffc02005da <intr_disable>
        return 1;
ffffffffc0204980:	4405                	li	s0,1
ffffffffc0204982:	bfa5                	j	ffffffffc02048fa <schedule+0x10>

ffffffffc0204984 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204984:	00054783          	lbu	a5,0(a0)
ffffffffc0204988:	cb91                	beqz	a5,ffffffffc020499c <strlen+0x18>
    size_t cnt = 0;
ffffffffc020498a:	4781                	li	a5,0
        cnt ++;
ffffffffc020498c:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020498e:	00f50733          	add	a4,a0,a5
ffffffffc0204992:	00074703          	lbu	a4,0(a4)
ffffffffc0204996:	fb7d                	bnez	a4,ffffffffc020498c <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204998:	853e                	mv	a0,a5
ffffffffc020499a:	8082                	ret
    size_t cnt = 0;
ffffffffc020499c:	4781                	li	a5,0
}
ffffffffc020499e:	853e                	mv	a0,a5
ffffffffc02049a0:	8082                	ret

ffffffffc02049a2 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02049a2:	c185                	beqz	a1,ffffffffc02049c2 <strnlen+0x20>
ffffffffc02049a4:	00054783          	lbu	a5,0(a0)
ffffffffc02049a8:	cf89                	beqz	a5,ffffffffc02049c2 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02049aa:	4781                	li	a5,0
ffffffffc02049ac:	a021                	j	ffffffffc02049b4 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02049ae:	00074703          	lbu	a4,0(a4)
ffffffffc02049b2:	c711                	beqz	a4,ffffffffc02049be <strnlen+0x1c>
        cnt ++;
ffffffffc02049b4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02049b6:	00f50733          	add	a4,a0,a5
ffffffffc02049ba:	fef59ae3          	bne	a1,a5,ffffffffc02049ae <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02049be:	853e                	mv	a0,a5
ffffffffc02049c0:	8082                	ret
    size_t cnt = 0;
ffffffffc02049c2:	4781                	li	a5,0
}
ffffffffc02049c4:	853e                	mv	a0,a5
ffffffffc02049c6:	8082                	ret

ffffffffc02049c8 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02049c8:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02049ca:	0585                	addi	a1,a1,1
ffffffffc02049cc:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02049d0:	0785                	addi	a5,a5,1
ffffffffc02049d2:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02049d6:	fb75                	bnez	a4,ffffffffc02049ca <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02049d8:	8082                	ret

ffffffffc02049da <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02049da:	00054783          	lbu	a5,0(a0)
ffffffffc02049de:	0005c703          	lbu	a4,0(a1)
ffffffffc02049e2:	cb91                	beqz	a5,ffffffffc02049f6 <strcmp+0x1c>
ffffffffc02049e4:	00e79c63          	bne	a5,a4,ffffffffc02049fc <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02049e8:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02049ea:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02049ee:	0585                	addi	a1,a1,1
ffffffffc02049f0:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02049f4:	fbe5                	bnez	a5,ffffffffc02049e4 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02049f6:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02049f8:	9d19                	subw	a0,a0,a4
ffffffffc02049fa:	8082                	ret
ffffffffc02049fc:	0007851b          	sext.w	a0,a5
ffffffffc0204a00:	9d19                	subw	a0,a0,a4
ffffffffc0204a02:	8082                	ret

ffffffffc0204a04 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204a04:	00054783          	lbu	a5,0(a0)
ffffffffc0204a08:	cb91                	beqz	a5,ffffffffc0204a1c <strchr+0x18>
        if (*s == c) {
ffffffffc0204a0a:	00b79563          	bne	a5,a1,ffffffffc0204a14 <strchr+0x10>
ffffffffc0204a0e:	a809                	j	ffffffffc0204a20 <strchr+0x1c>
ffffffffc0204a10:	00b78763          	beq	a5,a1,ffffffffc0204a1e <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204a14:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204a16:	00054783          	lbu	a5,0(a0)
ffffffffc0204a1a:	fbfd                	bnez	a5,ffffffffc0204a10 <strchr+0xc>
    }
    return NULL;
ffffffffc0204a1c:	4501                	li	a0,0
}
ffffffffc0204a1e:	8082                	ret
ffffffffc0204a20:	8082                	ret

ffffffffc0204a22 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204a22:	ca01                	beqz	a2,ffffffffc0204a32 <memset+0x10>
ffffffffc0204a24:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204a26:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204a28:	0785                	addi	a5,a5,1
ffffffffc0204a2a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204a2e:	fec79de3          	bne	a5,a2,ffffffffc0204a28 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204a32:	8082                	ret

ffffffffc0204a34 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204a34:	ca19                	beqz	a2,ffffffffc0204a4a <memcpy+0x16>
ffffffffc0204a36:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204a38:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204a3a:	0585                	addi	a1,a1,1
ffffffffc0204a3c:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204a40:	0785                	addi	a5,a5,1
ffffffffc0204a42:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204a46:	fec59ae3          	bne	a1,a2,ffffffffc0204a3a <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204a4a:	8082                	ret

ffffffffc0204a4c <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204a4c:	c21d                	beqz	a2,ffffffffc0204a72 <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc0204a4e:	00054783          	lbu	a5,0(a0)
ffffffffc0204a52:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a56:	962a                	add	a2,a2,a0
ffffffffc0204a58:	00f70963          	beq	a4,a5,ffffffffc0204a6a <memcmp+0x1e>
ffffffffc0204a5c:	a829                	j	ffffffffc0204a76 <memcmp+0x2a>
ffffffffc0204a5e:	00054783          	lbu	a5,0(a0)
ffffffffc0204a62:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a66:	00e79863          	bne	a5,a4,ffffffffc0204a76 <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204a6a:	0505                	addi	a0,a0,1
ffffffffc0204a6c:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc0204a6e:	fea618e3          	bne	a2,a0,ffffffffc0204a5e <memcmp+0x12>
    }
    return 0;
ffffffffc0204a72:	4501                	li	a0,0
}
ffffffffc0204a74:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204a76:	40e7853b          	subw	a0,a5,a4
ffffffffc0204a7a:	8082                	ret

ffffffffc0204a7c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204a7c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a80:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204a82:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a86:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204a88:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204a8c:	f022                	sd	s0,32(sp)
ffffffffc0204a8e:	ec26                	sd	s1,24(sp)
ffffffffc0204a90:	e84a                	sd	s2,16(sp)
ffffffffc0204a92:	f406                	sd	ra,40(sp)
ffffffffc0204a94:	e44e                	sd	s3,8(sp)
ffffffffc0204a96:	84aa                	mv	s1,a0
ffffffffc0204a98:	892e                	mv	s2,a1
ffffffffc0204a9a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204a9e:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0204aa0:	03067e63          	bleu	a6,a2,ffffffffc0204adc <printnum+0x60>
ffffffffc0204aa4:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204aa6:	00805763          	blez	s0,ffffffffc0204ab4 <printnum+0x38>
ffffffffc0204aaa:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204aac:	85ca                	mv	a1,s2
ffffffffc0204aae:	854e                	mv	a0,s3
ffffffffc0204ab0:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204ab2:	fc65                	bnez	s0,ffffffffc0204aaa <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204ab4:	1a02                	slli	s4,s4,0x20
ffffffffc0204ab6:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204aba:	00002797          	auipc	a5,0x2
ffffffffc0204abe:	40678793          	addi	a5,a5,1030 # ffffffffc0206ec0 <error_string+0x38>
ffffffffc0204ac2:	9a3e                	add	s4,s4,a5
}
ffffffffc0204ac4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204ac6:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204aca:	70a2                	ld	ra,40(sp)
ffffffffc0204acc:	69a2                	ld	s3,8(sp)
ffffffffc0204ace:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204ad0:	85ca                	mv	a1,s2
ffffffffc0204ad2:	8326                	mv	t1,s1
}
ffffffffc0204ad4:	6942                	ld	s2,16(sp)
ffffffffc0204ad6:	64e2                	ld	s1,24(sp)
ffffffffc0204ad8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204ada:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204adc:	03065633          	divu	a2,a2,a6
ffffffffc0204ae0:	8722                	mv	a4,s0
ffffffffc0204ae2:	f9bff0ef          	jal	ra,ffffffffc0204a7c <printnum>
ffffffffc0204ae6:	b7f9                	j	ffffffffc0204ab4 <printnum+0x38>

ffffffffc0204ae8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204ae8:	7119                	addi	sp,sp,-128
ffffffffc0204aea:	f4a6                	sd	s1,104(sp)
ffffffffc0204aec:	f0ca                	sd	s2,96(sp)
ffffffffc0204aee:	e8d2                	sd	s4,80(sp)
ffffffffc0204af0:	e4d6                	sd	s5,72(sp)
ffffffffc0204af2:	e0da                	sd	s6,64(sp)
ffffffffc0204af4:	fc5e                	sd	s7,56(sp)
ffffffffc0204af6:	f862                	sd	s8,48(sp)
ffffffffc0204af8:	f06a                	sd	s10,32(sp)
ffffffffc0204afa:	fc86                	sd	ra,120(sp)
ffffffffc0204afc:	f8a2                	sd	s0,112(sp)
ffffffffc0204afe:	ecce                	sd	s3,88(sp)
ffffffffc0204b00:	f466                	sd	s9,40(sp)
ffffffffc0204b02:	ec6e                	sd	s11,24(sp)
ffffffffc0204b04:	892a                	mv	s2,a0
ffffffffc0204b06:	84ae                	mv	s1,a1
ffffffffc0204b08:	8d32                	mv	s10,a2
ffffffffc0204b0a:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204b0c:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b0e:	00002a17          	auipc	s4,0x2
ffffffffc0204b12:	222a0a13          	addi	s4,s4,546 # ffffffffc0206d30 <default_pmm_manager+0x7b0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204b16:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204b1a:	00002c17          	auipc	s8,0x2
ffffffffc0204b1e:	36ec0c13          	addi	s8,s8,878 # ffffffffc0206e88 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b22:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0204b26:	02500793          	li	a5,37
ffffffffc0204b2a:	001d0413          	addi	s0,s10,1
ffffffffc0204b2e:	00f50e63          	beq	a0,a5,ffffffffc0204b4a <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204b32:	c521                	beqz	a0,ffffffffc0204b7a <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b34:	02500993          	li	s3,37
ffffffffc0204b38:	a011                	j	ffffffffc0204b3c <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204b3a:	c121                	beqz	a0,ffffffffc0204b7a <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0204b3c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b3e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204b40:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b42:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204b46:	ff351ae3          	bne	a0,s3,ffffffffc0204b3a <vprintfmt+0x52>
ffffffffc0204b4a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204b4e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204b52:	4981                	li	s3,0
ffffffffc0204b54:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0204b56:	5cfd                	li	s9,-1
ffffffffc0204b58:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b5a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0204b5e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b60:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204b64:	0ff6f693          	andi	a3,a3,255
ffffffffc0204b68:	00140d13          	addi	s10,s0,1
ffffffffc0204b6c:	20d5e563          	bltu	a1,a3,ffffffffc0204d76 <vprintfmt+0x28e>
ffffffffc0204b70:	068a                	slli	a3,a3,0x2
ffffffffc0204b72:	96d2                	add	a3,a3,s4
ffffffffc0204b74:	4294                	lw	a3,0(a3)
ffffffffc0204b76:	96d2                	add	a3,a3,s4
ffffffffc0204b78:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204b7a:	70e6                	ld	ra,120(sp)
ffffffffc0204b7c:	7446                	ld	s0,112(sp)
ffffffffc0204b7e:	74a6                	ld	s1,104(sp)
ffffffffc0204b80:	7906                	ld	s2,96(sp)
ffffffffc0204b82:	69e6                	ld	s3,88(sp)
ffffffffc0204b84:	6a46                	ld	s4,80(sp)
ffffffffc0204b86:	6aa6                	ld	s5,72(sp)
ffffffffc0204b88:	6b06                	ld	s6,64(sp)
ffffffffc0204b8a:	7be2                	ld	s7,56(sp)
ffffffffc0204b8c:	7c42                	ld	s8,48(sp)
ffffffffc0204b8e:	7ca2                	ld	s9,40(sp)
ffffffffc0204b90:	7d02                	ld	s10,32(sp)
ffffffffc0204b92:	6de2                	ld	s11,24(sp)
ffffffffc0204b94:	6109                	addi	sp,sp,128
ffffffffc0204b96:	8082                	ret
    if (lflag >= 2) {
ffffffffc0204b98:	4705                	li	a4,1
ffffffffc0204b9a:	008a8593          	addi	a1,s5,8
ffffffffc0204b9e:	01074463          	blt	a4,a6,ffffffffc0204ba6 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0204ba2:	26080363          	beqz	a6,ffffffffc0204e08 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0204ba6:	000ab603          	ld	a2,0(s5)
ffffffffc0204baa:	46c1                	li	a3,16
ffffffffc0204bac:	8aae                	mv	s5,a1
ffffffffc0204bae:	a06d                	j	ffffffffc0204c58 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0204bb0:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204bb4:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bb6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204bb8:	b765                	j	ffffffffc0204b60 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0204bba:	000aa503          	lw	a0,0(s5)
ffffffffc0204bbe:	85a6                	mv	a1,s1
ffffffffc0204bc0:	0aa1                	addi	s5,s5,8
ffffffffc0204bc2:	9902                	jalr	s2
            break;
ffffffffc0204bc4:	bfb9                	j	ffffffffc0204b22 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204bc6:	4705                	li	a4,1
ffffffffc0204bc8:	008a8993          	addi	s3,s5,8
ffffffffc0204bcc:	01074463          	blt	a4,a6,ffffffffc0204bd4 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0204bd0:	22080463          	beqz	a6,ffffffffc0204df8 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0204bd4:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0204bd8:	24044463          	bltz	s0,ffffffffc0204e20 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0204bdc:	8622                	mv	a2,s0
ffffffffc0204bde:	8ace                	mv	s5,s3
ffffffffc0204be0:	46a9                	li	a3,10
ffffffffc0204be2:	a89d                	j	ffffffffc0204c58 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0204be4:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204be8:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204bea:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0204bec:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204bf0:	8fb5                	xor	a5,a5,a3
ffffffffc0204bf2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204bf6:	1ad74363          	blt	a4,a3,ffffffffc0204d9c <vprintfmt+0x2b4>
ffffffffc0204bfa:	00369793          	slli	a5,a3,0x3
ffffffffc0204bfe:	97e2                	add	a5,a5,s8
ffffffffc0204c00:	639c                	ld	a5,0(a5)
ffffffffc0204c02:	18078d63          	beqz	a5,ffffffffc0204d9c <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204c06:	86be                	mv	a3,a5
ffffffffc0204c08:	00000617          	auipc	a2,0x0
ffffffffc0204c0c:	2b060613          	addi	a2,a2,688 # ffffffffc0204eb8 <etext+0x2c>
ffffffffc0204c10:	85a6                	mv	a1,s1
ffffffffc0204c12:	854a                	mv	a0,s2
ffffffffc0204c14:	240000ef          	jal	ra,ffffffffc0204e54 <printfmt>
ffffffffc0204c18:	b729                	j	ffffffffc0204b22 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204c1a:	00144603          	lbu	a2,1(s0)
ffffffffc0204c1e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c20:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c22:	bf3d                	j	ffffffffc0204b60 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204c24:	4705                	li	a4,1
ffffffffc0204c26:	008a8593          	addi	a1,s5,8
ffffffffc0204c2a:	01074463          	blt	a4,a6,ffffffffc0204c32 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0204c2e:	1e080263          	beqz	a6,ffffffffc0204e12 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0204c32:	000ab603          	ld	a2,0(s5)
ffffffffc0204c36:	46a1                	li	a3,8
ffffffffc0204c38:	8aae                	mv	s5,a1
ffffffffc0204c3a:	a839                	j	ffffffffc0204c58 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0204c3c:	03000513          	li	a0,48
ffffffffc0204c40:	85a6                	mv	a1,s1
ffffffffc0204c42:	e03e                	sd	a5,0(sp)
ffffffffc0204c44:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204c46:	85a6                	mv	a1,s1
ffffffffc0204c48:	07800513          	li	a0,120
ffffffffc0204c4c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204c4e:	0aa1                	addi	s5,s5,8
ffffffffc0204c50:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204c54:	6782                	ld	a5,0(sp)
ffffffffc0204c56:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204c58:	876e                	mv	a4,s11
ffffffffc0204c5a:	85a6                	mv	a1,s1
ffffffffc0204c5c:	854a                	mv	a0,s2
ffffffffc0204c5e:	e1fff0ef          	jal	ra,ffffffffc0204a7c <printnum>
            break;
ffffffffc0204c62:	b5c1                	j	ffffffffc0204b22 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204c64:	000ab603          	ld	a2,0(s5)
ffffffffc0204c68:	0aa1                	addi	s5,s5,8
ffffffffc0204c6a:	1c060663          	beqz	a2,ffffffffc0204e36 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0204c6e:	00160413          	addi	s0,a2,1
ffffffffc0204c72:	17b05c63          	blez	s11,ffffffffc0204dea <vprintfmt+0x302>
ffffffffc0204c76:	02d00593          	li	a1,45
ffffffffc0204c7a:	14b79263          	bne	a5,a1,ffffffffc0204dbe <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204c7e:	00064783          	lbu	a5,0(a2)
ffffffffc0204c82:	0007851b          	sext.w	a0,a5
ffffffffc0204c86:	c905                	beqz	a0,ffffffffc0204cb6 <vprintfmt+0x1ce>
ffffffffc0204c88:	000cc563          	bltz	s9,ffffffffc0204c92 <vprintfmt+0x1aa>
ffffffffc0204c8c:	3cfd                	addiw	s9,s9,-1
ffffffffc0204c8e:	036c8263          	beq	s9,s6,ffffffffc0204cb2 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204c92:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204c94:	18098463          	beqz	s3,ffffffffc0204e1c <vprintfmt+0x334>
ffffffffc0204c98:	3781                	addiw	a5,a5,-32
ffffffffc0204c9a:	18fbf163          	bleu	a5,s7,ffffffffc0204e1c <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204c9e:	03f00513          	li	a0,63
ffffffffc0204ca2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204ca4:	0405                	addi	s0,s0,1
ffffffffc0204ca6:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204caa:	3dfd                	addiw	s11,s11,-1
ffffffffc0204cac:	0007851b          	sext.w	a0,a5
ffffffffc0204cb0:	fd61                	bnez	a0,ffffffffc0204c88 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0204cb2:	e7b058e3          	blez	s11,ffffffffc0204b22 <vprintfmt+0x3a>
ffffffffc0204cb6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204cb8:	85a6                	mv	a1,s1
ffffffffc0204cba:	02000513          	li	a0,32
ffffffffc0204cbe:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204cc0:	e60d81e3          	beqz	s11,ffffffffc0204b22 <vprintfmt+0x3a>
ffffffffc0204cc4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204cc6:	85a6                	mv	a1,s1
ffffffffc0204cc8:	02000513          	li	a0,32
ffffffffc0204ccc:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204cce:	fe0d94e3          	bnez	s11,ffffffffc0204cb6 <vprintfmt+0x1ce>
ffffffffc0204cd2:	bd81                	j	ffffffffc0204b22 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204cd4:	4705                	li	a4,1
ffffffffc0204cd6:	008a8593          	addi	a1,s5,8
ffffffffc0204cda:	01074463          	blt	a4,a6,ffffffffc0204ce2 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204cde:	12080063          	beqz	a6,ffffffffc0204dfe <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204ce2:	000ab603          	ld	a2,0(s5)
ffffffffc0204ce6:	46a9                	li	a3,10
ffffffffc0204ce8:	8aae                	mv	s5,a1
ffffffffc0204cea:	b7bd                	j	ffffffffc0204c58 <vprintfmt+0x170>
ffffffffc0204cec:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204cf0:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cf4:	846a                	mv	s0,s10
ffffffffc0204cf6:	b5ad                	j	ffffffffc0204b60 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204cf8:	85a6                	mv	a1,s1
ffffffffc0204cfa:	02500513          	li	a0,37
ffffffffc0204cfe:	9902                	jalr	s2
            break;
ffffffffc0204d00:	b50d                	j	ffffffffc0204b22 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204d02:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204d06:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204d0a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d0c:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204d0e:	e40dd9e3          	bgez	s11,ffffffffc0204b60 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204d12:	8de6                	mv	s11,s9
ffffffffc0204d14:	5cfd                	li	s9,-1
ffffffffc0204d16:	b5a9                	j	ffffffffc0204b60 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204d18:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204d1c:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d20:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204d22:	bd3d                	j	ffffffffc0204b60 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204d24:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204d28:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d2c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204d2e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204d32:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204d36:	fcd56ce3          	bltu	a0,a3,ffffffffc0204d0e <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204d3a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204d3c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204d40:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204d44:	0196873b          	addw	a4,a3,s9
ffffffffc0204d48:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204d4c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204d50:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204d54:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204d58:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204d5c:	fcd57fe3          	bleu	a3,a0,ffffffffc0204d3a <vprintfmt+0x252>
ffffffffc0204d60:	b77d                	j	ffffffffc0204d0e <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204d62:	fffdc693          	not	a3,s11
ffffffffc0204d66:	96fd                	srai	a3,a3,0x3f
ffffffffc0204d68:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204d6c:	00144603          	lbu	a2,1(s0)
ffffffffc0204d70:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d72:	846a                	mv	s0,s10
ffffffffc0204d74:	b3f5                	j	ffffffffc0204b60 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0204d76:	85a6                	mv	a1,s1
ffffffffc0204d78:	02500513          	li	a0,37
ffffffffc0204d7c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204d7e:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204d82:	02500793          	li	a5,37
ffffffffc0204d86:	8d22                	mv	s10,s0
ffffffffc0204d88:	d8f70de3          	beq	a4,a5,ffffffffc0204b22 <vprintfmt+0x3a>
ffffffffc0204d8c:	02500713          	li	a4,37
ffffffffc0204d90:	1d7d                	addi	s10,s10,-1
ffffffffc0204d92:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204d96:	fee79de3          	bne	a5,a4,ffffffffc0204d90 <vprintfmt+0x2a8>
ffffffffc0204d9a:	b361                	j	ffffffffc0204b22 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204d9c:	00002617          	auipc	a2,0x2
ffffffffc0204da0:	1c460613          	addi	a2,a2,452 # ffffffffc0206f60 <error_string+0xd8>
ffffffffc0204da4:	85a6                	mv	a1,s1
ffffffffc0204da6:	854a                	mv	a0,s2
ffffffffc0204da8:	0ac000ef          	jal	ra,ffffffffc0204e54 <printfmt>
ffffffffc0204dac:	bb9d                	j	ffffffffc0204b22 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204dae:	00002617          	auipc	a2,0x2
ffffffffc0204db2:	1aa60613          	addi	a2,a2,426 # ffffffffc0206f58 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204db6:	00002417          	auipc	s0,0x2
ffffffffc0204dba:	1a340413          	addi	s0,s0,419 # ffffffffc0206f59 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204dbe:	8532                	mv	a0,a2
ffffffffc0204dc0:	85e6                	mv	a1,s9
ffffffffc0204dc2:	e032                	sd	a2,0(sp)
ffffffffc0204dc4:	e43e                	sd	a5,8(sp)
ffffffffc0204dc6:	bddff0ef          	jal	ra,ffffffffc02049a2 <strnlen>
ffffffffc0204dca:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204dce:	6602                	ld	a2,0(sp)
ffffffffc0204dd0:	01b05d63          	blez	s11,ffffffffc0204dea <vprintfmt+0x302>
ffffffffc0204dd4:	67a2                	ld	a5,8(sp)
ffffffffc0204dd6:	2781                	sext.w	a5,a5
ffffffffc0204dd8:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204dda:	6522                	ld	a0,8(sp)
ffffffffc0204ddc:	85a6                	mv	a1,s1
ffffffffc0204dde:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204de0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204de2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204de4:	6602                	ld	a2,0(sp)
ffffffffc0204de6:	fe0d9ae3          	bnez	s11,ffffffffc0204dda <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204dea:	00064783          	lbu	a5,0(a2)
ffffffffc0204dee:	0007851b          	sext.w	a0,a5
ffffffffc0204df2:	e8051be3          	bnez	a0,ffffffffc0204c88 <vprintfmt+0x1a0>
ffffffffc0204df6:	b335                	j	ffffffffc0204b22 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0204df8:	000aa403          	lw	s0,0(s5)
ffffffffc0204dfc:	bbf1                	j	ffffffffc0204bd8 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204dfe:	000ae603          	lwu	a2,0(s5)
ffffffffc0204e02:	46a9                	li	a3,10
ffffffffc0204e04:	8aae                	mv	s5,a1
ffffffffc0204e06:	bd89                	j	ffffffffc0204c58 <vprintfmt+0x170>
ffffffffc0204e08:	000ae603          	lwu	a2,0(s5)
ffffffffc0204e0c:	46c1                	li	a3,16
ffffffffc0204e0e:	8aae                	mv	s5,a1
ffffffffc0204e10:	b5a1                	j	ffffffffc0204c58 <vprintfmt+0x170>
ffffffffc0204e12:	000ae603          	lwu	a2,0(s5)
ffffffffc0204e16:	46a1                	li	a3,8
ffffffffc0204e18:	8aae                	mv	s5,a1
ffffffffc0204e1a:	bd3d                	j	ffffffffc0204c58 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204e1c:	9902                	jalr	s2
ffffffffc0204e1e:	b559                	j	ffffffffc0204ca4 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204e20:	85a6                	mv	a1,s1
ffffffffc0204e22:	02d00513          	li	a0,45
ffffffffc0204e26:	e03e                	sd	a5,0(sp)
ffffffffc0204e28:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204e2a:	8ace                	mv	s5,s3
ffffffffc0204e2c:	40800633          	neg	a2,s0
ffffffffc0204e30:	46a9                	li	a3,10
ffffffffc0204e32:	6782                	ld	a5,0(sp)
ffffffffc0204e34:	b515                	j	ffffffffc0204c58 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0204e36:	01b05663          	blez	s11,ffffffffc0204e42 <vprintfmt+0x35a>
ffffffffc0204e3a:	02d00693          	li	a3,45
ffffffffc0204e3e:	f6d798e3          	bne	a5,a3,ffffffffc0204dae <vprintfmt+0x2c6>
ffffffffc0204e42:	00002417          	auipc	s0,0x2
ffffffffc0204e46:	11740413          	addi	s0,s0,279 # ffffffffc0206f59 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e4a:	02800513          	li	a0,40
ffffffffc0204e4e:	02800793          	li	a5,40
ffffffffc0204e52:	bd1d                	j	ffffffffc0204c88 <vprintfmt+0x1a0>

ffffffffc0204e54 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e54:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204e56:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e5a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e5c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e5e:	ec06                	sd	ra,24(sp)
ffffffffc0204e60:	f83a                	sd	a4,48(sp)
ffffffffc0204e62:	fc3e                	sd	a5,56(sp)
ffffffffc0204e64:	e0c2                	sd	a6,64(sp)
ffffffffc0204e66:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204e68:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e6a:	c7fff0ef          	jal	ra,ffffffffc0204ae8 <vprintfmt>
}
ffffffffc0204e6e:	60e2                	ld	ra,24(sp)
ffffffffc0204e70:	6161                	addi	sp,sp,80
ffffffffc0204e72:	8082                	ret

ffffffffc0204e74 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204e74:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204e78:	2785                	addiw	a5,a5,1
ffffffffc0204e7a:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0204e7e:	02000793          	li	a5,32
ffffffffc0204e82:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0204e86:	00b5553b          	srlw	a0,a0,a1
ffffffffc0204e8a:	8082                	ret
