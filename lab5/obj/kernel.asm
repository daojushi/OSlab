
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

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
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	02a50513          	addi	a0,a0,42 # ffffffffc02a1060 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	5b260613          	addi	a2,a2,1458 # ffffffffc02ac5f0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	31e060ef          	jal	ra,ffffffffc020636c <memset>
    cons_init();                // init the console
ffffffffc0200052:	58e000ef          	jal	ra,ffffffffc02005e0 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	75258593          	addi	a1,a1,1874 # ffffffffc02067a8 <etext+0x2>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	76a50513          	addi	a0,a0,1898 # ffffffffc02067c8 <etext+0x22>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	25a000ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	677030ef          	jal	ra,ffffffffc0203ee4 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e2000ef          	jal	ra,ffffffffc0200654 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5ec000ef          	jal	ra,ffffffffc0200662 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	19c010ef          	jal	ra,ffffffffc0201216 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	6f9050ef          	jal	ra,ffffffffc0205f76 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4b0000ef          	jal	ra,ffffffffc0200532 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	1e4020ef          	jal	ra,ffffffffc020226a <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	500000ef          	jal	ra,ffffffffc020058a <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c8000ef          	jal	ra,ffffffffc0200656 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	030060ef          	jal	ra,ffffffffc02060c2 <cpu_idle>

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
ffffffffc020009e:	544000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
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
ffffffffc02000c4:	33e060ef          	jal	ra,ffffffffc0206402 <vprintfmt>
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
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
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
ffffffffc02000f8:	30a060ef          	jal	ra,ffffffffc0206402 <vprintfmt>
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
ffffffffc0200104:	4de0006f          	j	ffffffffc02005e2 <cons_putc>

ffffffffc0200108 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200108:	1101                	addi	sp,sp,-32
ffffffffc020010a:	e822                	sd	s0,16(sp)
ffffffffc020010c:	ec06                	sd	ra,24(sp)
ffffffffc020010e:	e426                	sd	s1,8(sp)
ffffffffc0200110:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200112:	00054503          	lbu	a0,0(a0)
ffffffffc0200116:	c51d                	beqz	a0,ffffffffc0200144 <cputs+0x3c>
ffffffffc0200118:	0405                	addi	s0,s0,1
ffffffffc020011a:	4485                	li	s1,1
ffffffffc020011c:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011e:	4c4000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
    (*cnt) ++;
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	fff44503          	lbu	a0,-1(s0)
ffffffffc020012c:	f96d                	bnez	a0,ffffffffc020011e <cputs+0x16>
ffffffffc020012e:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200132:	4529                	li	a0,10
ffffffffc0200134:	4ae000ef          	jal	ra,ffffffffc02005e2 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200138:	8522                	mv	a0,s0
ffffffffc020013a:	60e2                	ld	ra,24(sp)
ffffffffc020013c:	6442                	ld	s0,16(sp)
ffffffffc020013e:	64a2                	ld	s1,8(sp)
ffffffffc0200140:	6105                	addi	sp,sp,32
ffffffffc0200142:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200144:	4405                	li	s0,1
ffffffffc0200146:	b7f5                	j	ffffffffc0200132 <cputs+0x2a>

ffffffffc0200148 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200148:	1141                	addi	sp,sp,-16
ffffffffc020014a:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020014c:	4cc000ef          	jal	ra,ffffffffc0200618 <cons_getc>
ffffffffc0200150:	dd75                	beqz	a0,ffffffffc020014c <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200152:	60a2                	ld	ra,8(sp)
ffffffffc0200154:	0141                	addi	sp,sp,16
ffffffffc0200156:	8082                	ret

ffffffffc0200158 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200158:	715d                	addi	sp,sp,-80
ffffffffc020015a:	e486                	sd	ra,72(sp)
ffffffffc020015c:	e0a2                	sd	s0,64(sp)
ffffffffc020015e:	fc26                	sd	s1,56(sp)
ffffffffc0200160:	f84a                	sd	s2,48(sp)
ffffffffc0200162:	f44e                	sd	s3,40(sp)
ffffffffc0200164:	f052                	sd	s4,32(sp)
ffffffffc0200166:	ec56                	sd	s5,24(sp)
ffffffffc0200168:	e85a                	sd	s6,16(sp)
ffffffffc020016a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020016c:	c901                	beqz	a0,ffffffffc020017c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00006517          	auipc	a0,0x6
ffffffffc0200174:	66050513          	addi	a0,a0,1632 # ffffffffc02067d0 <etext+0x2a>
ffffffffc0200178:	f59ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020017c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020017e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200180:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200182:	4aa9                	li	s5,10
ffffffffc0200184:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200186:	000a1b97          	auipc	s7,0xa1
ffffffffc020018a:	edab8b93          	addi	s7,s7,-294 # ffffffffc02a1060 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200192:	fb7ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc0200196:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200198:	00054b63          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020019c:	00a95b63          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001a0:	029a5463          	ble	s1,s4,ffffffffc02001c8 <readline+0x70>
        c = getchar();
ffffffffc02001a4:	fa5ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001a8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001aa:	fe0559e3          	bgez	a0,ffffffffc020019c <readline+0x44>
            return NULL;
ffffffffc02001ae:	4501                	li	a0,0
ffffffffc02001b0:	a099                	j	ffffffffc02001f6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02001b2:	03341463          	bne	s0,s3,ffffffffc02001da <readline+0x82>
ffffffffc02001b6:	e8b9                	bnez	s1,ffffffffc020020c <readline+0xb4>
        c = getchar();
ffffffffc02001b8:	f91ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001bc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001be:	fe0548e3          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001c2:	fea958e3          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001c6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001c8:	8522                	mv	a0,s0
ffffffffc02001ca:	f3bff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc02001ce:	009b87b3          	add	a5,s7,s1
ffffffffc02001d2:	00878023          	sb	s0,0(a5)
ffffffffc02001d6:	2485                	addiw	s1,s1,1
ffffffffc02001d8:	bf6d                	j	ffffffffc0200192 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02001da:	01540463          	beq	s0,s5,ffffffffc02001e2 <readline+0x8a>
ffffffffc02001de:	fb641ae3          	bne	s0,s6,ffffffffc0200192 <readline+0x3a>
            cputchar(c);
ffffffffc02001e2:	8522                	mv	a0,s0
ffffffffc02001e4:	f21ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001e8:	000a1517          	auipc	a0,0xa1
ffffffffc02001ec:	e7850513          	addi	a0,a0,-392 # ffffffffc02a1060 <edata>
ffffffffc02001f0:	94aa                	add	s1,s1,a0
ffffffffc02001f2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001f6:	60a6                	ld	ra,72(sp)
ffffffffc02001f8:	6406                	ld	s0,64(sp)
ffffffffc02001fa:	74e2                	ld	s1,56(sp)
ffffffffc02001fc:	7942                	ld	s2,48(sp)
ffffffffc02001fe:	79a2                	ld	s3,40(sp)
ffffffffc0200200:	7a02                	ld	s4,32(sp)
ffffffffc0200202:	6ae2                	ld	s5,24(sp)
ffffffffc0200204:	6b42                	ld	s6,16(sp)
ffffffffc0200206:	6ba2                	ld	s7,8(sp)
ffffffffc0200208:	6161                	addi	sp,sp,80
ffffffffc020020a:	8082                	ret
            cputchar(c);
ffffffffc020020c:	4521                	li	a0,8
ffffffffc020020e:	ef7ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc0200212:	34fd                	addiw	s1,s1,-1
ffffffffc0200214:	bfbd                	j	ffffffffc0200192 <readline+0x3a>

ffffffffc0200216 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200216:	000ac317          	auipc	t1,0xac
ffffffffc020021a:	24a30313          	addi	t1,t1,586 # ffffffffc02ac460 <is_panic>
ffffffffc020021e:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200222:	715d                	addi	sp,sp,-80
ffffffffc0200224:	ec06                	sd	ra,24(sp)
ffffffffc0200226:	e822                	sd	s0,16(sp)
ffffffffc0200228:	f436                	sd	a3,40(sp)
ffffffffc020022a:	f83a                	sd	a4,48(sp)
ffffffffc020022c:	fc3e                	sd	a5,56(sp)
ffffffffc020022e:	e0c2                	sd	a6,64(sp)
ffffffffc0200230:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200232:	02031c63          	bnez	t1,ffffffffc020026a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200236:	4785                	li	a5,1
ffffffffc0200238:	8432                	mv	s0,a2
ffffffffc020023a:	000ac717          	auipc	a4,0xac
ffffffffc020023e:	22f73323          	sd	a5,550(a4) # ffffffffc02ac460 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200242:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200244:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200246:	85aa                	mv	a1,a0
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	59050513          	addi	a0,a0,1424 # ffffffffc02067d8 <etext+0x32>
    va_start(ap, fmt);
ffffffffc0200250:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200252:	e7fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200256:	65a2                	ld	a1,8(sp)
ffffffffc0200258:	8522                	mv	a0,s0
ffffffffc020025a:	e57ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020025e:	00008517          	auipc	a0,0x8
ffffffffc0200262:	0fa50513          	addi	a0,a0,250 # ffffffffc0208358 <default_pmm_manager+0x448>
ffffffffc0200266:	e6bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020026a:	4501                	li	a0,0
ffffffffc020026c:	4581                	li	a1,0
ffffffffc020026e:	4601                	li	a2,0
ffffffffc0200270:	48a1                	li	a7,8
ffffffffc0200272:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200276:	3e6000ef          	jal	ra,ffffffffc020065c <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020027a:	4501                	li	a0,0
ffffffffc020027c:	174000ef          	jal	ra,ffffffffc02003f0 <kmonitor>
ffffffffc0200280:	bfed                	j	ffffffffc020027a <__panic+0x64>

ffffffffc0200282 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200282:	715d                	addi	sp,sp,-80
ffffffffc0200284:	e822                	sd	s0,16(sp)
ffffffffc0200286:	fc3e                	sd	a5,56(sp)
ffffffffc0200288:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc020028a:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020028c:	862e                	mv	a2,a1
ffffffffc020028e:	85aa                	mv	a1,a0
ffffffffc0200290:	00006517          	auipc	a0,0x6
ffffffffc0200294:	56850513          	addi	a0,a0,1384 # ffffffffc02067f8 <etext+0x52>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200298:	ec06                	sd	ra,24(sp)
ffffffffc020029a:	f436                	sd	a3,40(sp)
ffffffffc020029c:	f83a                	sd	a4,48(sp)
ffffffffc020029e:	e0c2                	sd	a6,64(sp)
ffffffffc02002a0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002a2:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002a4:	e2dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002a8:	65a2                	ld	a1,8(sp)
ffffffffc02002aa:	8522                	mv	a0,s0
ffffffffc02002ac:	e05ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc02002b0:	00008517          	auipc	a0,0x8
ffffffffc02002b4:	0a850513          	addi	a0,a0,168 # ffffffffc0208358 <default_pmm_manager+0x448>
ffffffffc02002b8:	e19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);
}
ffffffffc02002bc:	60e2                	ld	ra,24(sp)
ffffffffc02002be:	6442                	ld	s0,16(sp)
ffffffffc02002c0:	6161                	addi	sp,sp,80
ffffffffc02002c2:	8082                	ret

ffffffffc02002c4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002c4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002c6:	00006517          	auipc	a0,0x6
ffffffffc02002ca:	58250513          	addi	a0,a0,1410 # ffffffffc0206848 <etext+0xa2>
void print_kerninfo(void) {
ffffffffc02002ce:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002d0:	e01ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002d4:	00000597          	auipc	a1,0x0
ffffffffc02002d8:	d6258593          	addi	a1,a1,-670 # ffffffffc0200036 <kern_init>
ffffffffc02002dc:	00006517          	auipc	a0,0x6
ffffffffc02002e0:	58c50513          	addi	a0,a0,1420 # ffffffffc0206868 <etext+0xc2>
ffffffffc02002e4:	dedff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002e8:	00006597          	auipc	a1,0x6
ffffffffc02002ec:	4be58593          	addi	a1,a1,1214 # ffffffffc02067a6 <etext>
ffffffffc02002f0:	00006517          	auipc	a0,0x6
ffffffffc02002f4:	59850513          	addi	a0,a0,1432 # ffffffffc0206888 <etext+0xe2>
ffffffffc02002f8:	dd9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002fc:	000a1597          	auipc	a1,0xa1
ffffffffc0200300:	d6458593          	addi	a1,a1,-668 # ffffffffc02a1060 <edata>
ffffffffc0200304:	00006517          	auipc	a0,0x6
ffffffffc0200308:	5a450513          	addi	a0,a0,1444 # ffffffffc02068a8 <etext+0x102>
ffffffffc020030c:	dc5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200310:	000ac597          	auipc	a1,0xac
ffffffffc0200314:	2e058593          	addi	a1,a1,736 # ffffffffc02ac5f0 <end>
ffffffffc0200318:	00006517          	auipc	a0,0x6
ffffffffc020031c:	5b050513          	addi	a0,a0,1456 # ffffffffc02068c8 <etext+0x122>
ffffffffc0200320:	db1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200324:	000ac597          	auipc	a1,0xac
ffffffffc0200328:	6cb58593          	addi	a1,a1,1739 # ffffffffc02ac9ef <end+0x3ff>
ffffffffc020032c:	00000797          	auipc	a5,0x0
ffffffffc0200330:	d0a78793          	addi	a5,a5,-758 # ffffffffc0200036 <kern_init>
ffffffffc0200334:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200338:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020033c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020033e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200342:	95be                	add	a1,a1,a5
ffffffffc0200344:	85a9                	srai	a1,a1,0xa
ffffffffc0200346:	00006517          	auipc	a0,0x6
ffffffffc020034a:	5a250513          	addi	a0,a0,1442 # ffffffffc02068e8 <etext+0x142>
}
ffffffffc020034e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200350:	d81ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200354 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200354:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200356:	00006617          	auipc	a2,0x6
ffffffffc020035a:	4c260613          	addi	a2,a2,1218 # ffffffffc0206818 <etext+0x72>
ffffffffc020035e:	04d00593          	li	a1,77
ffffffffc0200362:	00006517          	auipc	a0,0x6
ffffffffc0200366:	4ce50513          	addi	a0,a0,1230 # ffffffffc0206830 <etext+0x8a>
void print_stackframe(void) {
ffffffffc020036a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020036c:	eabff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200370 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200370:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200372:	00006617          	auipc	a2,0x6
ffffffffc0200376:	68660613          	addi	a2,a2,1670 # ffffffffc02069f8 <commands+0xe0>
ffffffffc020037a:	00006597          	auipc	a1,0x6
ffffffffc020037e:	69e58593          	addi	a1,a1,1694 # ffffffffc0206a18 <commands+0x100>
ffffffffc0200382:	00006517          	auipc	a0,0x6
ffffffffc0200386:	69e50513          	addi	a0,a0,1694 # ffffffffc0206a20 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020038a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020038c:	d45ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200390:	00006617          	auipc	a2,0x6
ffffffffc0200394:	6a060613          	addi	a2,a2,1696 # ffffffffc0206a30 <commands+0x118>
ffffffffc0200398:	00006597          	auipc	a1,0x6
ffffffffc020039c:	6c058593          	addi	a1,a1,1728 # ffffffffc0206a58 <commands+0x140>
ffffffffc02003a0:	00006517          	auipc	a0,0x6
ffffffffc02003a4:	68050513          	addi	a0,a0,1664 # ffffffffc0206a20 <commands+0x108>
ffffffffc02003a8:	d29ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02003ac:	00006617          	auipc	a2,0x6
ffffffffc02003b0:	6bc60613          	addi	a2,a2,1724 # ffffffffc0206a68 <commands+0x150>
ffffffffc02003b4:	00006597          	auipc	a1,0x6
ffffffffc02003b8:	6d458593          	addi	a1,a1,1748 # ffffffffc0206a88 <commands+0x170>
ffffffffc02003bc:	00006517          	auipc	a0,0x6
ffffffffc02003c0:	66450513          	addi	a0,a0,1636 # ffffffffc0206a20 <commands+0x108>
ffffffffc02003c4:	d0dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc02003c8:	60a2                	ld	ra,8(sp)
ffffffffc02003ca:	4501                	li	a0,0
ffffffffc02003cc:	0141                	addi	sp,sp,16
ffffffffc02003ce:	8082                	ret

ffffffffc02003d0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003d0:	1141                	addi	sp,sp,-16
ffffffffc02003d2:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003d4:	ef1ff0ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>
    return 0;
}
ffffffffc02003d8:	60a2                	ld	ra,8(sp)
ffffffffc02003da:	4501                	li	a0,0
ffffffffc02003dc:	0141                	addi	sp,sp,16
ffffffffc02003de:	8082                	ret

ffffffffc02003e0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003e0:	1141                	addi	sp,sp,-16
ffffffffc02003e2:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003e4:	f71ff0ef          	jal	ra,ffffffffc0200354 <print_stackframe>
    return 0;
}
ffffffffc02003e8:	60a2                	ld	ra,8(sp)
ffffffffc02003ea:	4501                	li	a0,0
ffffffffc02003ec:	0141                	addi	sp,sp,16
ffffffffc02003ee:	8082                	ret

ffffffffc02003f0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003f0:	7115                	addi	sp,sp,-224
ffffffffc02003f2:	e962                	sd	s8,144(sp)
ffffffffc02003f4:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003f6:	00006517          	auipc	a0,0x6
ffffffffc02003fa:	56a50513          	addi	a0,a0,1386 # ffffffffc0206960 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02003fe:	ed86                	sd	ra,216(sp)
ffffffffc0200400:	e9a2                	sd	s0,208(sp)
ffffffffc0200402:	e5a6                	sd	s1,200(sp)
ffffffffc0200404:	e1ca                	sd	s2,192(sp)
ffffffffc0200406:	fd4e                	sd	s3,184(sp)
ffffffffc0200408:	f952                	sd	s4,176(sp)
ffffffffc020040a:	f556                	sd	s5,168(sp)
ffffffffc020040c:	f15a                	sd	s6,160(sp)
ffffffffc020040e:	ed5e                	sd	s7,152(sp)
ffffffffc0200410:	e566                	sd	s9,136(sp)
ffffffffc0200412:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200414:	cbdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200418:	00006517          	auipc	a0,0x6
ffffffffc020041c:	57050513          	addi	a0,a0,1392 # ffffffffc0206988 <commands+0x70>
ffffffffc0200420:	cb1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200424:	000c0563          	beqz	s8,ffffffffc020042e <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200428:	8562                	mv	a0,s8
ffffffffc020042a:	420000ef          	jal	ra,ffffffffc020084a <print_trapframe>
ffffffffc020042e:	00006c97          	auipc	s9,0x6
ffffffffc0200432:	4eac8c93          	addi	s9,s9,1258 # ffffffffc0206918 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200436:	00006997          	auipc	s3,0x6
ffffffffc020043a:	57a98993          	addi	s3,s3,1402 # ffffffffc02069b0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043e:	00006917          	auipc	s2,0x6
ffffffffc0200442:	57a90913          	addi	s2,s2,1402 # ffffffffc02069b8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200446:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200448:	00006b17          	auipc	s6,0x6
ffffffffc020044c:	578b0b13          	addi	s6,s6,1400 # ffffffffc02069c0 <commands+0xa8>
    if (argc == 0) {
ffffffffc0200450:	00006a97          	auipc	s5,0x6
ffffffffc0200454:	5c8a8a93          	addi	s5,s5,1480 # ffffffffc0206a18 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200458:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020045a:	854e                	mv	a0,s3
ffffffffc020045c:	cfdff0ef          	jal	ra,ffffffffc0200158 <readline>
ffffffffc0200460:	842a                	mv	s0,a0
ffffffffc0200462:	dd65                	beqz	a0,ffffffffc020045a <kmonitor+0x6a>
ffffffffc0200464:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200468:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020046a:	c999                	beqz	a1,ffffffffc0200480 <kmonitor+0x90>
ffffffffc020046c:	854a                	mv	a0,s2
ffffffffc020046e:	6e1050ef          	jal	ra,ffffffffc020634e <strchr>
ffffffffc0200472:	c925                	beqz	a0,ffffffffc02004e2 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200474:	00144583          	lbu	a1,1(s0)
ffffffffc0200478:	00040023          	sb	zero,0(s0)
ffffffffc020047c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020047e:	f5fd                	bnez	a1,ffffffffc020046c <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200480:	dce9                	beqz	s1,ffffffffc020045a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	6582                	ld	a1,0(sp)
ffffffffc0200484:	00006d17          	auipc	s10,0x6
ffffffffc0200488:	494d0d13          	addi	s10,s10,1172 # ffffffffc0206918 <commands>
    if (argc == 0) {
ffffffffc020048c:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020048e:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200490:	0d61                	addi	s10,s10,24
ffffffffc0200492:	693050ef          	jal	ra,ffffffffc0206324 <strcmp>
ffffffffc0200496:	c919                	beqz	a0,ffffffffc02004ac <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200498:	2405                	addiw	s0,s0,1
ffffffffc020049a:	09740463          	beq	s0,s7,ffffffffc0200522 <kmonitor+0x132>
ffffffffc020049e:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02004a2:	6582                	ld	a1,0(sp)
ffffffffc02004a4:	0d61                	addi	s10,s10,24
ffffffffc02004a6:	67f050ef          	jal	ra,ffffffffc0206324 <strcmp>
ffffffffc02004aa:	f57d                	bnez	a0,ffffffffc0200498 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02004ac:	00141793          	slli	a5,s0,0x1
ffffffffc02004b0:	97a2                	add	a5,a5,s0
ffffffffc02004b2:	078e                	slli	a5,a5,0x3
ffffffffc02004b4:	97e6                	add	a5,a5,s9
ffffffffc02004b6:	6b9c                	ld	a5,16(a5)
ffffffffc02004b8:	8662                	mv	a2,s8
ffffffffc02004ba:	002c                	addi	a1,sp,8
ffffffffc02004bc:	fff4851b          	addiw	a0,s1,-1
ffffffffc02004c0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02004c2:	f8055ce3          	bgez	a0,ffffffffc020045a <kmonitor+0x6a>
}
ffffffffc02004c6:	60ee                	ld	ra,216(sp)
ffffffffc02004c8:	644e                	ld	s0,208(sp)
ffffffffc02004ca:	64ae                	ld	s1,200(sp)
ffffffffc02004cc:	690e                	ld	s2,192(sp)
ffffffffc02004ce:	79ea                	ld	s3,184(sp)
ffffffffc02004d0:	7a4a                	ld	s4,176(sp)
ffffffffc02004d2:	7aaa                	ld	s5,168(sp)
ffffffffc02004d4:	7b0a                	ld	s6,160(sp)
ffffffffc02004d6:	6bea                	ld	s7,152(sp)
ffffffffc02004d8:	6c4a                	ld	s8,144(sp)
ffffffffc02004da:	6caa                	ld	s9,136(sp)
ffffffffc02004dc:	6d0a                	ld	s10,128(sp)
ffffffffc02004de:	612d                	addi	sp,sp,224
ffffffffc02004e0:	8082                	ret
        if (*buf == '\0') {
ffffffffc02004e2:	00044783          	lbu	a5,0(s0)
ffffffffc02004e6:	dfc9                	beqz	a5,ffffffffc0200480 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02004e8:	03448863          	beq	s1,s4,ffffffffc0200518 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02004ec:	00349793          	slli	a5,s1,0x3
ffffffffc02004f0:	0118                	addi	a4,sp,128
ffffffffc02004f2:	97ba                	add	a5,a5,a4
ffffffffc02004f4:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f8:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004fc:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fe:	e591                	bnez	a1,ffffffffc020050a <kmonitor+0x11a>
ffffffffc0200500:	b749                	j	ffffffffc0200482 <kmonitor+0x92>
            buf ++;
ffffffffc0200502:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	ddad                	beqz	a1,ffffffffc0200482 <kmonitor+0x92>
ffffffffc020050a:	854a                	mv	a0,s2
ffffffffc020050c:	643050ef          	jal	ra,ffffffffc020634e <strchr>
ffffffffc0200510:	d96d                	beqz	a0,ffffffffc0200502 <kmonitor+0x112>
ffffffffc0200512:	00044583          	lbu	a1,0(s0)
ffffffffc0200516:	bf91                	j	ffffffffc020046a <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200518:	45c1                	li	a1,16
ffffffffc020051a:	855a                	mv	a0,s6
ffffffffc020051c:	bb5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200520:	b7f1                	j	ffffffffc02004ec <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200522:	6582                	ld	a1,0(sp)
ffffffffc0200524:	00006517          	auipc	a0,0x6
ffffffffc0200528:	4bc50513          	addi	a0,a0,1212 # ffffffffc02069e0 <commands+0xc8>
ffffffffc020052c:	ba5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc0200530:	b72d                	j	ffffffffc020045a <kmonitor+0x6a>

ffffffffc0200532 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200534:	00253513          	sltiu	a0,a0,2
ffffffffc0200538:	8082                	ret

ffffffffc020053a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020053a:	03800513          	li	a0,56
ffffffffc020053e:	8082                	ret

ffffffffc0200540 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200540:	000a1797          	auipc	a5,0xa1
ffffffffc0200544:	f2078793          	addi	a5,a5,-224 # ffffffffc02a1460 <ide>
ffffffffc0200548:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020054c:	1141                	addi	sp,sp,-16
ffffffffc020054e:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200550:	95be                	add	a1,a1,a5
ffffffffc0200552:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200556:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200558:	627050ef          	jal	ra,ffffffffc020637e <memcpy>
    return 0;
}
ffffffffc020055c:	60a2                	ld	ra,8(sp)
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	0141                	addi	sp,sp,16
ffffffffc0200562:	8082                	ret

ffffffffc0200564 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200564:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200566:	0095979b          	slliw	a5,a1,0x9
ffffffffc020056a:	000a1517          	auipc	a0,0xa1
ffffffffc020056e:	ef650513          	addi	a0,a0,-266 # ffffffffc02a1460 <ide>
                   size_t nsecs) {
ffffffffc0200572:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200574:	00969613          	slli	a2,a3,0x9
ffffffffc0200578:	85ba                	mv	a1,a4
ffffffffc020057a:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020057c:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020057e:	601050ef          	jal	ra,ffffffffc020637e <memcpy>
    return 0;
}
ffffffffc0200582:	60a2                	ld	ra,8(sp)
ffffffffc0200584:	4501                	li	a0,0
ffffffffc0200586:	0141                	addi	sp,sp,16
ffffffffc0200588:	8082                	ret

ffffffffc020058a <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020058a:	67e1                	lui	a5,0x18
ffffffffc020058c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc20>
ffffffffc0200590:	000ac717          	auipc	a4,0xac
ffffffffc0200594:	ecf73c23          	sd	a5,-296(a4) # ffffffffc02ac468 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200598:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020059c:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020059e:	953e                	add	a0,a0,a5
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4881                	li	a7,0
ffffffffc02005a4:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02005a8:	02000793          	li	a5,32
ffffffffc02005ac:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005b0:	00006517          	auipc	a0,0x6
ffffffffc02005b4:	4e850513          	addi	a0,a0,1256 # ffffffffc0206a98 <commands+0x180>
    ticks = 0;
ffffffffc02005b8:	000ac797          	auipc	a5,0xac
ffffffffc02005bc:	f007b423          	sd	zero,-248(a5) # ffffffffc02ac4c0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005c0:	b11ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02005c4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005c4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005c8:	000ac797          	auipc	a5,0xac
ffffffffc02005cc:	ea078793          	addi	a5,a5,-352 # ffffffffc02ac468 <timebase>
ffffffffc02005d0:	639c                	ld	a5,0(a5)
ffffffffc02005d2:	4581                	li	a1,0
ffffffffc02005d4:	4601                	li	a2,0
ffffffffc02005d6:	953e                	add	a0,a0,a5
ffffffffc02005d8:	4881                	li	a7,0
ffffffffc02005da:	00000073          	ecall
ffffffffc02005de:	8082                	ret

ffffffffc02005e0 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005e0:	8082                	ret

ffffffffc02005e2 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005e2:	100027f3          	csrr	a5,sstatus
ffffffffc02005e6:	8b89                	andi	a5,a5,2
ffffffffc02005e8:	0ff57513          	andi	a0,a0,255
ffffffffc02005ec:	e799                	bnez	a5,ffffffffc02005fa <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005ee:	4581                	li	a1,0
ffffffffc02005f0:	4601                	li	a2,0
ffffffffc02005f2:	4885                	li	a7,1
ffffffffc02005f4:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005f8:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005fa:	1101                	addi	sp,sp,-32
ffffffffc02005fc:	ec06                	sd	ra,24(sp)
ffffffffc02005fe:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200600:	05c000ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200604:	6522                	ld	a0,8(sp)
ffffffffc0200606:	4581                	li	a1,0
ffffffffc0200608:	4601                	li	a2,0
ffffffffc020060a:	4885                	li	a7,1
ffffffffc020060c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200610:	60e2                	ld	ra,24(sp)
ffffffffc0200612:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200614:	0420006f          	j	ffffffffc0200656 <intr_enable>

ffffffffc0200618 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200618:	100027f3          	csrr	a5,sstatus
ffffffffc020061c:	8b89                	andi	a5,a5,2
ffffffffc020061e:	eb89                	bnez	a5,ffffffffc0200630 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200620:	4501                	li	a0,0
ffffffffc0200622:	4581                	li	a1,0
ffffffffc0200624:	4601                	li	a2,0
ffffffffc0200626:	4889                	li	a7,2
ffffffffc0200628:	00000073          	ecall
ffffffffc020062c:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020062e:	8082                	ret
int cons_getc(void) {
ffffffffc0200630:	1101                	addi	sp,sp,-32
ffffffffc0200632:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200634:	028000ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0200638:	4501                	li	a0,0
ffffffffc020063a:	4581                	li	a1,0
ffffffffc020063c:	4601                	li	a2,0
ffffffffc020063e:	4889                	li	a7,2
ffffffffc0200640:	00000073          	ecall
ffffffffc0200644:	2501                	sext.w	a0,a0
ffffffffc0200646:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200648:	00e000ef          	jal	ra,ffffffffc0200656 <intr_enable>
}
ffffffffc020064c:	60e2                	ld	ra,24(sp)
ffffffffc020064e:	6522                	ld	a0,8(sp)
ffffffffc0200650:	6105                	addi	sp,sp,32
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200654:	8082                	ret

ffffffffc0200656 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200656:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020065a:	8082                	ret

ffffffffc020065c <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020065c:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200662:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200666:	00000797          	auipc	a5,0x0
ffffffffc020066a:	67a78793          	addi	a5,a5,1658 # ffffffffc0200ce0 <__alltraps>
ffffffffc020066e:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200672:	000407b7          	lui	a5,0x40
ffffffffc0200676:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020067a:	8082                	ret

ffffffffc020067c <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020067e:	1141                	addi	sp,sp,-16
ffffffffc0200680:	e022                	sd	s0,0(sp)
ffffffffc0200682:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	75c50513          	addi	a0,a0,1884 # ffffffffc0206de0 <commands+0x4c8>
void print_regs(struct pushregs* gpr) {
ffffffffc020068c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020068e:	a43ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200692:	640c                	ld	a1,8(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	76450513          	addi	a0,a0,1892 # ffffffffc0206df8 <commands+0x4e0>
ffffffffc020069c:	a35ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02006a0:	680c                	ld	a1,16(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	76e50513          	addi	a0,a0,1902 # ffffffffc0206e10 <commands+0x4f8>
ffffffffc02006aa:	a27ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006ae:	6c0c                	ld	a1,24(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	77850513          	addi	a0,a0,1912 # ffffffffc0206e28 <commands+0x510>
ffffffffc02006b8:	a19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006bc:	700c                	ld	a1,32(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	78250513          	addi	a0,a0,1922 # ffffffffc0206e40 <commands+0x528>
ffffffffc02006c6:	a0bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ca:	740c                	ld	a1,40(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	78c50513          	addi	a0,a0,1932 # ffffffffc0206e58 <commands+0x540>
ffffffffc02006d4:	9fdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d8:	780c                	ld	a1,48(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	79650513          	addi	a0,a0,1942 # ffffffffc0206e70 <commands+0x558>
ffffffffc02006e2:	9efff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006e6:	7c0c                	ld	a1,56(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	7a050513          	addi	a0,a0,1952 # ffffffffc0206e88 <commands+0x570>
ffffffffc02006f0:	9e1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006f4:	602c                	ld	a1,64(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	7aa50513          	addi	a0,a0,1962 # ffffffffc0206ea0 <commands+0x588>
ffffffffc02006fe:	9d3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200702:	642c                	ld	a1,72(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	7b450513          	addi	a0,a0,1972 # ffffffffc0206eb8 <commands+0x5a0>
ffffffffc020070c:	9c5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200710:	682c                	ld	a1,80(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	7be50513          	addi	a0,a0,1982 # ffffffffc0206ed0 <commands+0x5b8>
ffffffffc020071a:	9b7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020071e:	6c2c                	ld	a1,88(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	7c850513          	addi	a0,a0,1992 # ffffffffc0206ee8 <commands+0x5d0>
ffffffffc0200728:	9a9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020072c:	702c                	ld	a1,96(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	7d250513          	addi	a0,a0,2002 # ffffffffc0206f00 <commands+0x5e8>
ffffffffc0200736:	99bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020073a:	742c                	ld	a1,104(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	7dc50513          	addi	a0,a0,2012 # ffffffffc0206f18 <commands+0x600>
ffffffffc0200744:	98dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200748:	782c                	ld	a1,112(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	7e650513          	addi	a0,a0,2022 # ffffffffc0206f30 <commands+0x618>
ffffffffc0200752:	97fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200756:	7c2c                	ld	a1,120(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	7f050513          	addi	a0,a0,2032 # ffffffffc0206f48 <commands+0x630>
ffffffffc0200760:	971ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200764:	604c                	ld	a1,128(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	7fa50513          	addi	a0,a0,2042 # ffffffffc0206f60 <commands+0x648>
ffffffffc020076e:	963ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200772:	644c                	ld	a1,136(s0)
ffffffffc0200774:	00007517          	auipc	a0,0x7
ffffffffc0200778:	80450513          	addi	a0,a0,-2044 # ffffffffc0206f78 <commands+0x660>
ffffffffc020077c:	955ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200780:	684c                	ld	a1,144(s0)
ffffffffc0200782:	00007517          	auipc	a0,0x7
ffffffffc0200786:	80e50513          	addi	a0,a0,-2034 # ffffffffc0206f90 <commands+0x678>
ffffffffc020078a:	947ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020078e:	6c4c                	ld	a1,152(s0)
ffffffffc0200790:	00007517          	auipc	a0,0x7
ffffffffc0200794:	81850513          	addi	a0,a0,-2024 # ffffffffc0206fa8 <commands+0x690>
ffffffffc0200798:	939ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020079c:	704c                	ld	a1,160(s0)
ffffffffc020079e:	00007517          	auipc	a0,0x7
ffffffffc02007a2:	82250513          	addi	a0,a0,-2014 # ffffffffc0206fc0 <commands+0x6a8>
ffffffffc02007a6:	92bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007aa:	744c                	ld	a1,168(s0)
ffffffffc02007ac:	00007517          	auipc	a0,0x7
ffffffffc02007b0:	82c50513          	addi	a0,a0,-2004 # ffffffffc0206fd8 <commands+0x6c0>
ffffffffc02007b4:	91dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b8:	784c                	ld	a1,176(s0)
ffffffffc02007ba:	00007517          	auipc	a0,0x7
ffffffffc02007be:	83650513          	addi	a0,a0,-1994 # ffffffffc0206ff0 <commands+0x6d8>
ffffffffc02007c2:	90fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007c6:	7c4c                	ld	a1,184(s0)
ffffffffc02007c8:	00007517          	auipc	a0,0x7
ffffffffc02007cc:	84050513          	addi	a0,a0,-1984 # ffffffffc0207008 <commands+0x6f0>
ffffffffc02007d0:	901ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007d4:	606c                	ld	a1,192(s0)
ffffffffc02007d6:	00007517          	auipc	a0,0x7
ffffffffc02007da:	84a50513          	addi	a0,a0,-1974 # ffffffffc0207020 <commands+0x708>
ffffffffc02007de:	8f3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007e2:	646c                	ld	a1,200(s0)
ffffffffc02007e4:	00007517          	auipc	a0,0x7
ffffffffc02007e8:	85450513          	addi	a0,a0,-1964 # ffffffffc0207038 <commands+0x720>
ffffffffc02007ec:	8e5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007f0:	686c                	ld	a1,208(s0)
ffffffffc02007f2:	00007517          	auipc	a0,0x7
ffffffffc02007f6:	85e50513          	addi	a0,a0,-1954 # ffffffffc0207050 <commands+0x738>
ffffffffc02007fa:	8d7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200800:	00007517          	auipc	a0,0x7
ffffffffc0200804:	86850513          	addi	a0,a0,-1944 # ffffffffc0207068 <commands+0x750>
ffffffffc0200808:	8c9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020080c:	706c                	ld	a1,224(s0)
ffffffffc020080e:	00007517          	auipc	a0,0x7
ffffffffc0200812:	87250513          	addi	a0,a0,-1934 # ffffffffc0207080 <commands+0x768>
ffffffffc0200816:	8bbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020081a:	746c                	ld	a1,232(s0)
ffffffffc020081c:	00007517          	auipc	a0,0x7
ffffffffc0200820:	87c50513          	addi	a0,a0,-1924 # ffffffffc0207098 <commands+0x780>
ffffffffc0200824:	8adff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200828:	786c                	ld	a1,240(s0)
ffffffffc020082a:	00007517          	auipc	a0,0x7
ffffffffc020082e:	88650513          	addi	a0,a0,-1914 # ffffffffc02070b0 <commands+0x798>
ffffffffc0200832:	89fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200838:	6402                	ld	s0,0(sp)
ffffffffc020083a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083c:	00007517          	auipc	a0,0x7
ffffffffc0200840:	88c50513          	addi	a0,a0,-1908 # ffffffffc02070c8 <commands+0x7b0>
}
ffffffffc0200844:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200846:	88bff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020084a <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	1141                	addi	sp,sp,-16
ffffffffc020084c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084e:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	00007517          	auipc	a0,0x7
ffffffffc0200856:	88e50513          	addi	a0,a0,-1906 # ffffffffc02070e0 <commands+0x7c8>
print_trapframe(struct trapframe *tf) {
ffffffffc020085a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020085c:	875ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200860:	8522                	mv	a0,s0
ffffffffc0200862:	e1bff0ef          	jal	ra,ffffffffc020067c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200866:	10043583          	ld	a1,256(s0)
ffffffffc020086a:	00007517          	auipc	a0,0x7
ffffffffc020086e:	88e50513          	addi	a0,a0,-1906 # ffffffffc02070f8 <commands+0x7e0>
ffffffffc0200872:	85fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200876:	10843583          	ld	a1,264(s0)
ffffffffc020087a:	00007517          	auipc	a0,0x7
ffffffffc020087e:	89650513          	addi	a0,a0,-1898 # ffffffffc0207110 <commands+0x7f8>
ffffffffc0200882:	84fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200886:	11043583          	ld	a1,272(s0)
ffffffffc020088a:	00007517          	auipc	a0,0x7
ffffffffc020088e:	89e50513          	addi	a0,a0,-1890 # ffffffffc0207128 <commands+0x810>
ffffffffc0200892:	83fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	11843583          	ld	a1,280(s0)
}
ffffffffc020089a:	6402                	ld	s0,0(sp)
ffffffffc020089c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	00007517          	auipc	a0,0x7
ffffffffc02008a2:	89a50513          	addi	a0,a0,-1894 # ffffffffc0207138 <commands+0x820>
}
ffffffffc02008a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a8:	829ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02008ac <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b0:	000ac497          	auipc	s1,0xac
ffffffffc02008b4:	c1848493          	addi	s1,s1,-1000 # ffffffffc02ac4c8 <check_mm_struct>
ffffffffc02008b8:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ba:	e822                	sd	s0,16(sp)
ffffffffc02008bc:	ec06                	sd	ra,24(sp)
ffffffffc02008be:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008c0:	cbbd                	beqz	a5,ffffffffc0200936 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c2:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c6:	11053583          	ld	a1,272(a0)
ffffffffc02008ca:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ce:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008d2:	cba1                	beqz	a5,ffffffffc0200922 <pgfault_handler+0x76>
ffffffffc02008d4:	11843703          	ld	a4,280(s0)
ffffffffc02008d8:	47bd                	li	a5,15
ffffffffc02008da:	05700693          	li	a3,87
ffffffffc02008de:	00f70463          	beq	a4,a5,ffffffffc02008e6 <pgfault_handler+0x3a>
ffffffffc02008e2:	05200693          	li	a3,82
ffffffffc02008e6:	00006517          	auipc	a0,0x6
ffffffffc02008ea:	47a50513          	addi	a0,a0,1146 # ffffffffc0206d60 <commands+0x448>
ffffffffc02008ee:	fe2ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008f2:	6088                	ld	a0,0(s1)
ffffffffc02008f4:	c129                	beqz	a0,ffffffffc0200936 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	baa78793          	addi	a5,a5,-1110 # ffffffffc02ac4a0 <current>
ffffffffc02008fe:	6398                	ld	a4,0(a5)
ffffffffc0200900:	000ac797          	auipc	a5,0xac
ffffffffc0200904:	ba878793          	addi	a5,a5,-1112 # ffffffffc02ac4a8 <idleproc>
ffffffffc0200908:	639c                	ld	a5,0(a5)
ffffffffc020090a:	04f71763          	bne	a4,a5,ffffffffc0200958 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11843583          	ld	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
ffffffffc020091c:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	63f0006f          	j	ffffffffc020175c <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200922:	11843703          	ld	a4,280(s0)
ffffffffc0200926:	47bd                	li	a5,15
ffffffffc0200928:	05500613          	li	a2,85
ffffffffc020092c:	05700693          	li	a3,87
ffffffffc0200930:	faf719e3          	bne	a4,a5,ffffffffc02008e2 <pgfault_handler+0x36>
ffffffffc0200934:	bf4d                	j	ffffffffc02008e6 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200936:	000ac797          	auipc	a5,0xac
ffffffffc020093a:	b6a78793          	addi	a5,a5,-1174 # ffffffffc02ac4a0 <current>
ffffffffc020093e:	639c                	ld	a5,0(a5)
ffffffffc0200940:	cf85                	beqz	a5,ffffffffc0200978 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200942:	11043603          	ld	a2,272(s0)
ffffffffc0200946:	11843583          	ld	a1,280(s0)
}
ffffffffc020094a:	6442                	ld	s0,16(sp)
ffffffffc020094c:	60e2                	ld	ra,24(sp)
ffffffffc020094e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200950:	7788                	ld	a0,40(a5)
}
ffffffffc0200952:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200954:	6090006f          	j	ffffffffc020175c <do_pgfault>
        assert(current == idleproc);
ffffffffc0200958:	00006697          	auipc	a3,0x6
ffffffffc020095c:	42868693          	addi	a3,a3,1064 # ffffffffc0206d80 <commands+0x468>
ffffffffc0200960:	00006617          	auipc	a2,0x6
ffffffffc0200964:	43860613          	addi	a2,a2,1080 # ffffffffc0206d98 <commands+0x480>
ffffffffc0200968:	06b00593          	li	a1,107
ffffffffc020096c:	00006517          	auipc	a0,0x6
ffffffffc0200970:	44450513          	addi	a0,a0,1092 # ffffffffc0206db0 <commands+0x498>
ffffffffc0200974:	8a3ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200978:	8522                	mv	a0,s0
ffffffffc020097a:	ed1ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020097e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200982:	11043583          	ld	a1,272(s0)
ffffffffc0200986:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020098a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020098e:	e399                	bnez	a5,ffffffffc0200994 <pgfault_handler+0xe8>
ffffffffc0200990:	05500613          	li	a2,85
ffffffffc0200994:	11843703          	ld	a4,280(s0)
ffffffffc0200998:	47bd                	li	a5,15
ffffffffc020099a:	02f70663          	beq	a4,a5,ffffffffc02009c6 <pgfault_handler+0x11a>
ffffffffc020099e:	05200693          	li	a3,82
ffffffffc02009a2:	00006517          	auipc	a0,0x6
ffffffffc02009a6:	3be50513          	addi	a0,a0,958 # ffffffffc0206d60 <commands+0x448>
ffffffffc02009aa:	f26ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	41a60613          	addi	a2,a2,1050 # ffffffffc0206dc8 <commands+0x4b0>
ffffffffc02009b6:	07200593          	li	a1,114
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	3f650513          	addi	a0,a0,1014 # ffffffffc0206db0 <commands+0x498>
ffffffffc02009c2:	855ff0ef          	jal	ra,ffffffffc0200216 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009c6:	05700693          	li	a3,87
ffffffffc02009ca:	bfe1                	j	ffffffffc02009a2 <pgfault_handler+0xf6>

ffffffffc02009cc <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009cc:	11853783          	ld	a5,280(a0)
ffffffffc02009d0:	577d                	li	a4,-1
ffffffffc02009d2:	8305                	srli	a4,a4,0x1
ffffffffc02009d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009d6:	472d                	li	a4,11
ffffffffc02009d8:	08f76763          	bltu	a4,a5,ffffffffc0200a66 <interrupt_handler+0x9a>
ffffffffc02009dc:	00006717          	auipc	a4,0x6
ffffffffc02009e0:	0d870713          	addi	a4,a4,216 # ffffffffc0206ab4 <commands+0x19c>
ffffffffc02009e4:	078a                	slli	a5,a5,0x2
ffffffffc02009e6:	97ba                	add	a5,a5,a4
ffffffffc02009e8:	439c                	lw	a5,0(a5)
ffffffffc02009ea:	97ba                	add	a5,a5,a4
ffffffffc02009ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	33250513          	addi	a0,a0,818 # ffffffffc0206d20 <commands+0x408>
ffffffffc02009f6:	edaff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	30650513          	addi	a0,a0,774 # ffffffffc0206d00 <commands+0x3e8>
ffffffffc0200a02:	eceff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	2ba50513          	addi	a0,a0,698 # ffffffffc0206cc0 <commands+0x3a8>
ffffffffc0200a0e:	ec2ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	2ce50513          	addi	a0,a0,718 # ffffffffc0206ce0 <commands+0x3c8>
ffffffffc0200a1a:	eb6ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a1e:	00006517          	auipc	a0,0x6
ffffffffc0200a22:	32250513          	addi	a0,a0,802 # ffffffffc0206d40 <commands+0x428>
ffffffffc0200a26:	eaaff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a2a:	1141                	addi	sp,sp,-16
ffffffffc0200a2c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a2e:	b97ff0ef          	jal	ra,ffffffffc02005c4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a32:	000ac797          	auipc	a5,0xac
ffffffffc0200a36:	a8e78793          	addi	a5,a5,-1394 # ffffffffc02ac4c0 <ticks>
ffffffffc0200a3a:	639c                	ld	a5,0(a5)
ffffffffc0200a3c:	06400713          	li	a4,100
ffffffffc0200a40:	0785                	addi	a5,a5,1
ffffffffc0200a42:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a46:	000ac697          	auipc	a3,0xac
ffffffffc0200a4a:	a6f6bd23          	sd	a5,-1414(a3) # ffffffffc02ac4c0 <ticks>
ffffffffc0200a4e:	eb09                	bnez	a4,ffffffffc0200a60 <interrupt_handler+0x94>
ffffffffc0200a50:	000ac797          	auipc	a5,0xac
ffffffffc0200a54:	a5078793          	addi	a5,a5,-1456 # ffffffffc02ac4a0 <current>
ffffffffc0200a58:	639c                	ld	a5,0(a5)
ffffffffc0200a5a:	c399                	beqz	a5,ffffffffc0200a60 <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a5c:	4705                	li	a4,1
ffffffffc0200a5e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a60:	60a2                	ld	ra,8(sp)
ffffffffc0200a62:	0141                	addi	sp,sp,16
ffffffffc0200a64:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a66:	de5ff06f          	j	ffffffffc020084a <print_trapframe>

ffffffffc0200a6a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a6a:	11853783          	ld	a5,280(a0)
ffffffffc0200a6e:	473d                	li	a4,15
ffffffffc0200a70:	1af76e63          	bltu	a4,a5,ffffffffc0200c2c <exception_handler+0x1c2>
ffffffffc0200a74:	00006717          	auipc	a4,0x6
ffffffffc0200a78:	07070713          	addi	a4,a4,112 # ffffffffc0206ae4 <commands+0x1cc>
ffffffffc0200a7c:	078a                	slli	a5,a5,0x2
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a82:	1101                	addi	sp,sp,-32
ffffffffc0200a84:	e822                	sd	s0,16(sp)
ffffffffc0200a86:	ec06                	sd	ra,24(sp)
ffffffffc0200a88:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a8a:	97ba                	add	a5,a5,a4
ffffffffc0200a8c:	842a                	mv	s0,a0
ffffffffc0200a8e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	18850513          	addi	a0,a0,392 # ffffffffc0206c18 <commands+0x300>
ffffffffc0200a98:	e38ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            tf->epc += 4;
ffffffffc0200a9c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200aa0:	60e2                	ld	ra,24(sp)
ffffffffc0200aa2:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200aa4:	0791                	addi	a5,a5,4
ffffffffc0200aa6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aae:	7a00506f          	j	ffffffffc020624e <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	18650513          	addi	a0,a0,390 # ffffffffc0206c38 <commands+0x320>
}
ffffffffc0200aba:	6442                	ld	s0,16(sp)
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	64a2                	ld	s1,8(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	e0eff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ac6:	00006517          	auipc	a0,0x6
ffffffffc0200aca:	19250513          	addi	a0,a0,402 # ffffffffc0206c58 <commands+0x340>
ffffffffc0200ace:	b7f5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad0:	00006517          	auipc	a0,0x6
ffffffffc0200ad4:	1a850513          	addi	a0,a0,424 # ffffffffc0206c78 <commands+0x360>
ffffffffc0200ad8:	b7cd                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	1b650513          	addi	a0,a0,438 # ffffffffc0206c90 <commands+0x378>
ffffffffc0200ae2:	deeff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae6:	8522                	mv	a0,s0
ffffffffc0200ae8:	dc5ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200aec:	84aa                	mv	s1,a0
ffffffffc0200aee:	14051163          	bnez	a0,ffffffffc0200c30 <exception_handler+0x1c6>
}
ffffffffc0200af2:	60e2                	ld	ra,24(sp)
ffffffffc0200af4:	6442                	ld	s0,16(sp)
ffffffffc0200af6:	64a2                	ld	s1,8(sp)
ffffffffc0200af8:	6105                	addi	sp,sp,32
ffffffffc0200afa:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	1ac50513          	addi	a0,a0,428 # ffffffffc0206ca8 <commands+0x390>
ffffffffc0200b04:	dccff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	da3ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b0e:	84aa                	mv	s1,a0
ffffffffc0200b10:	d16d                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b12:	8522                	mv	a0,s0
ffffffffc0200b14:	d37ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b18:	86a6                	mv	a3,s1
ffffffffc0200b1a:	00006617          	auipc	a2,0x6
ffffffffc0200b1e:	0ae60613          	addi	a2,a2,174 # ffffffffc0206bc8 <commands+0x2b0>
ffffffffc0200b22:	0f800593          	li	a1,248
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	28a50513          	addi	a0,a0,650 # ffffffffc0206db0 <commands+0x498>
ffffffffc0200b2e:	ee8ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b32:	00006517          	auipc	a0,0x6
ffffffffc0200b36:	ff650513          	addi	a0,a0,-10 # ffffffffc0206b28 <commands+0x210>
ffffffffc0200b3a:	b741                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b3c:	00006517          	auipc	a0,0x6
ffffffffc0200b40:	00c50513          	addi	a0,a0,12 # ffffffffc0206b48 <commands+0x230>
ffffffffc0200b44:	bf9d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	02250513          	addi	a0,a0,34 # ffffffffc0206b68 <commands+0x250>
ffffffffc0200b4e:	b7b5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b50:	00006517          	auipc	a0,0x6
ffffffffc0200b54:	03050513          	addi	a0,a0,48 # ffffffffc0206b80 <commands+0x268>
ffffffffc0200b58:	d78ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b5c:	6458                	ld	a4,136(s0)
ffffffffc0200b5e:	47a9                	li	a5,10
ffffffffc0200b60:	f8f719e3          	bne	a4,a5,ffffffffc0200af2 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b64:	10843783          	ld	a5,264(s0)
ffffffffc0200b68:	0791                	addi	a5,a5,4
ffffffffc0200b6a:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b6e:	6e0050ef          	jal	ra,ffffffffc020624e <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	000ac797          	auipc	a5,0xac
ffffffffc0200b76:	92e78793          	addi	a5,a5,-1746 # ffffffffc02ac4a0 <current>
ffffffffc0200b7a:	639c                	ld	a5,0(a5)
ffffffffc0200b7c:	8522                	mv	a0,s0
}
ffffffffc0200b7e:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b80:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b82:	60e2                	ld	ra,24(sp)
ffffffffc0200b84:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b86:	6589                	lui	a1,0x2
ffffffffc0200b88:	95be                	add	a1,a1,a5
}
ffffffffc0200b8a:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b8c:	2220006f          	j	ffffffffc0200dae <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b90:	00006517          	auipc	a0,0x6
ffffffffc0200b94:	00050513          	mv	a0,a0
ffffffffc0200b98:	b70d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	01650513          	addi	a0,a0,22 # ffffffffc0206bb0 <commands+0x298>
ffffffffc0200ba2:	d2eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ba6:	8522                	mv	a0,s0
ffffffffc0200ba8:	d05ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bac:	84aa                	mv	s1,a0
ffffffffc0200bae:	d131                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	c99ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bb6:	86a6                	mv	a3,s1
ffffffffc0200bb8:	00006617          	auipc	a2,0x6
ffffffffc0200bbc:	01060613          	addi	a2,a2,16 # ffffffffc0206bc8 <commands+0x2b0>
ffffffffc0200bc0:	0cd00593          	li	a1,205
ffffffffc0200bc4:	00006517          	auipc	a0,0x6
ffffffffc0200bc8:	1ec50513          	addi	a0,a0,492 # ffffffffc0206db0 <commands+0x498>
ffffffffc0200bcc:	e4aff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	03050513          	addi	a0,a0,48 # ffffffffc0206c00 <commands+0x2e8>
ffffffffc0200bd8:	cf8ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bdc:	8522                	mv	a0,s0
ffffffffc0200bde:	ccfff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200be2:	84aa                	mv	s1,a0
ffffffffc0200be4:	f00507e3          	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200be8:	8522                	mv	a0,s0
ffffffffc0200bea:	c61ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bee:	86a6                	mv	a3,s1
ffffffffc0200bf0:	00006617          	auipc	a2,0x6
ffffffffc0200bf4:	fd860613          	addi	a2,a2,-40 # ffffffffc0206bc8 <commands+0x2b0>
ffffffffc0200bf8:	0d700593          	li	a1,215
ffffffffc0200bfc:	00006517          	auipc	a0,0x6
ffffffffc0200c00:	1b450513          	addi	a0,a0,436 # ffffffffc0206db0 <commands+0x498>
ffffffffc0200c04:	e12ff0ef          	jal	ra,ffffffffc0200216 <__panic>
}
ffffffffc0200c08:	6442                	ld	s0,16(sp)
ffffffffc0200c0a:	60e2                	ld	ra,24(sp)
ffffffffc0200c0c:	64a2                	ld	s1,8(sp)
ffffffffc0200c0e:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c10:	c3bff06f          	j	ffffffffc020084a <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c14:	00006617          	auipc	a2,0x6
ffffffffc0200c18:	fd460613          	addi	a2,a2,-44 # ffffffffc0206be8 <commands+0x2d0>
ffffffffc0200c1c:	0d100593          	li	a1,209
ffffffffc0200c20:	00006517          	auipc	a0,0x6
ffffffffc0200c24:	19050513          	addi	a0,a0,400 # ffffffffc0206db0 <commands+0x498>
ffffffffc0200c28:	deeff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200c2c:	c1fff06f          	j	ffffffffc020084a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c30:	8522                	mv	a0,s0
ffffffffc0200c32:	c19ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c36:	86a6                	mv	a3,s1
ffffffffc0200c38:	00006617          	auipc	a2,0x6
ffffffffc0200c3c:	f9060613          	addi	a2,a2,-112 # ffffffffc0206bc8 <commands+0x2b0>
ffffffffc0200c40:	0f100593          	li	a1,241
ffffffffc0200c44:	00006517          	auipc	a0,0x6
ffffffffc0200c48:	16c50513          	addi	a0,a0,364 # ffffffffc0206db0 <commands+0x498>
ffffffffc0200c4c:	dcaff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200c50 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c50:	1101                	addi	sp,sp,-32
ffffffffc0200c52:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c54:	000ac417          	auipc	s0,0xac
ffffffffc0200c58:	84c40413          	addi	s0,s0,-1972 # ffffffffc02ac4a0 <current>
ffffffffc0200c5c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c5e:	ec06                	sd	ra,24(sp)
ffffffffc0200c60:	e426                	sd	s1,8(sp)
ffffffffc0200c62:	e04a                	sd	s2,0(sp)
ffffffffc0200c64:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c68:	cf1d                	beqz	a4,ffffffffc0200ca6 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c6a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c6e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c72:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c74:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0206c463          	bltz	a3,ffffffffc0200ca0 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c7c:	defff0ef          	jal	ra,ffffffffc0200a6a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c80:	601c                	ld	a5,0(s0)
ffffffffc0200c82:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c86:	e499                	bnez	s1,ffffffffc0200c94 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c88:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c8c:	8b05                	andi	a4,a4,1
ffffffffc0200c8e:	e339                	bnez	a4,ffffffffc0200cd4 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c90:	6f9c                	ld	a5,24(a5)
ffffffffc0200c92:	eb95                	bnez	a5,ffffffffc0200cc6 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	6442                	ld	s0,16(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
ffffffffc0200c9e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200ca0:	d2dff0ef          	jal	ra,ffffffffc02009cc <interrupt_handler>
ffffffffc0200ca4:	bff1                	j	ffffffffc0200c80 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ca6:	0006c963          	bltz	a3,ffffffffc0200cb8 <trap+0x68>
}
ffffffffc0200caa:	6442                	ld	s0,16(sp)
ffffffffc0200cac:	60e2                	ld	ra,24(sp)
ffffffffc0200cae:	64a2                	ld	s1,8(sp)
ffffffffc0200cb0:	6902                	ld	s2,0(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cb4:	db7ff06f          	j	ffffffffc0200a6a <exception_handler>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cc2:	d0bff06f          	j	ffffffffc02009cc <interrupt_handler>
}
ffffffffc0200cc6:	6442                	ld	s0,16(sp)
ffffffffc0200cc8:	60e2                	ld	ra,24(sp)
ffffffffc0200cca:	64a2                	ld	s1,8(sp)
ffffffffc0200ccc:	6902                	ld	s2,0(sp)
ffffffffc0200cce:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cd0:	4880506f          	j	ffffffffc0206158 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cd4:	555d                	li	a0,-9
ffffffffc0200cd6:	0eb040ef          	jal	ra,ffffffffc02055c0 <do_exit>
ffffffffc0200cda:	601c                	ld	a5,0(s0)
ffffffffc0200cdc:	bf55                	j	ffffffffc0200c90 <trap+0x40>
	...

ffffffffc0200ce0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ce0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ce4:	00011463          	bnez	sp,ffffffffc0200cec <__alltraps+0xc>
ffffffffc0200ce8:	14002173          	csrr	sp,sscratch
ffffffffc0200cec:	712d                	addi	sp,sp,-288
ffffffffc0200cee:	e002                	sd	zero,0(sp)
ffffffffc0200cf0:	e406                	sd	ra,8(sp)
ffffffffc0200cf2:	ec0e                	sd	gp,24(sp)
ffffffffc0200cf4:	f012                	sd	tp,32(sp)
ffffffffc0200cf6:	f416                	sd	t0,40(sp)
ffffffffc0200cf8:	f81a                	sd	t1,48(sp)
ffffffffc0200cfa:	fc1e                	sd	t2,56(sp)
ffffffffc0200cfc:	e0a2                	sd	s0,64(sp)
ffffffffc0200cfe:	e4a6                	sd	s1,72(sp)
ffffffffc0200d00:	e8aa                	sd	a0,80(sp)
ffffffffc0200d02:	ecae                	sd	a1,88(sp)
ffffffffc0200d04:	f0b2                	sd	a2,96(sp)
ffffffffc0200d06:	f4b6                	sd	a3,104(sp)
ffffffffc0200d08:	f8ba                	sd	a4,112(sp)
ffffffffc0200d0a:	fcbe                	sd	a5,120(sp)
ffffffffc0200d0c:	e142                	sd	a6,128(sp)
ffffffffc0200d0e:	e546                	sd	a7,136(sp)
ffffffffc0200d10:	e94a                	sd	s2,144(sp)
ffffffffc0200d12:	ed4e                	sd	s3,152(sp)
ffffffffc0200d14:	f152                	sd	s4,160(sp)
ffffffffc0200d16:	f556                	sd	s5,168(sp)
ffffffffc0200d18:	f95a                	sd	s6,176(sp)
ffffffffc0200d1a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d1c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d1e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d20:	e9ea                	sd	s10,208(sp)
ffffffffc0200d22:	edee                	sd	s11,216(sp)
ffffffffc0200d24:	f1f2                	sd	t3,224(sp)
ffffffffc0200d26:	f5f6                	sd	t4,232(sp)
ffffffffc0200d28:	f9fa                	sd	t5,240(sp)
ffffffffc0200d2a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d2c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d30:	100024f3          	csrr	s1,sstatus
ffffffffc0200d34:	14102973          	csrr	s2,sepc
ffffffffc0200d38:	143029f3          	csrr	s3,stval
ffffffffc0200d3c:	14202a73          	csrr	s4,scause
ffffffffc0200d40:	e822                	sd	s0,16(sp)
ffffffffc0200d42:	e226                	sd	s1,256(sp)
ffffffffc0200d44:	e64a                	sd	s2,264(sp)
ffffffffc0200d46:	ea4e                	sd	s3,272(sp)
ffffffffc0200d48:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d4a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d4c:	f05ff0ef          	jal	ra,ffffffffc0200c50 <trap>

ffffffffc0200d50 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d50:	6492                	ld	s1,256(sp)
ffffffffc0200d52:	6932                	ld	s2,264(sp)
ffffffffc0200d54:	1004f413          	andi	s0,s1,256
ffffffffc0200d58:	e401                	bnez	s0,ffffffffc0200d60 <__trapret+0x10>
ffffffffc0200d5a:	1200                	addi	s0,sp,288
ffffffffc0200d5c:	14041073          	csrw	sscratch,s0
ffffffffc0200d60:	10049073          	csrw	sstatus,s1
ffffffffc0200d64:	14191073          	csrw	sepc,s2
ffffffffc0200d68:	60a2                	ld	ra,8(sp)
ffffffffc0200d6a:	61e2                	ld	gp,24(sp)
ffffffffc0200d6c:	7202                	ld	tp,32(sp)
ffffffffc0200d6e:	72a2                	ld	t0,40(sp)
ffffffffc0200d70:	7342                	ld	t1,48(sp)
ffffffffc0200d72:	73e2                	ld	t2,56(sp)
ffffffffc0200d74:	6406                	ld	s0,64(sp)
ffffffffc0200d76:	64a6                	ld	s1,72(sp)
ffffffffc0200d78:	6546                	ld	a0,80(sp)
ffffffffc0200d7a:	65e6                	ld	a1,88(sp)
ffffffffc0200d7c:	7606                	ld	a2,96(sp)
ffffffffc0200d7e:	76a6                	ld	a3,104(sp)
ffffffffc0200d80:	7746                	ld	a4,112(sp)
ffffffffc0200d82:	77e6                	ld	a5,120(sp)
ffffffffc0200d84:	680a                	ld	a6,128(sp)
ffffffffc0200d86:	68aa                	ld	a7,136(sp)
ffffffffc0200d88:	694a                	ld	s2,144(sp)
ffffffffc0200d8a:	69ea                	ld	s3,152(sp)
ffffffffc0200d8c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d8e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d90:	7b4a                	ld	s6,176(sp)
ffffffffc0200d92:	7bea                	ld	s7,184(sp)
ffffffffc0200d94:	6c0e                	ld	s8,192(sp)
ffffffffc0200d96:	6cae                	ld	s9,200(sp)
ffffffffc0200d98:	6d4e                	ld	s10,208(sp)
ffffffffc0200d9a:	6dee                	ld	s11,216(sp)
ffffffffc0200d9c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d9e:	7eae                	ld	t4,232(sp)
ffffffffc0200da0:	7f4e                	ld	t5,240(sp)
ffffffffc0200da2:	7fee                	ld	t6,248(sp)
ffffffffc0200da4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200da6:	10200073          	sret

ffffffffc0200daa <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200daa:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200dac:	b755                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200dae <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200dae:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7698>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200db2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200db6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200dba:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dbe:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dc2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dc6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dca:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dce:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dd2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dd4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dd6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dd8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dda:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200ddc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dde:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200de0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200de2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200de4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200de6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200de8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dea:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dec:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dee:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200df0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200df2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200df4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200df6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200df8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dfa:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dfc:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dfe:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e00:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e02:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e04:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e06:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e08:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e0a:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e0c:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e0e:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e10:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e12:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e14:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e16:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e18:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e1a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e1c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e1e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e20:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e22:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e24:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e26:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e28:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e2a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e2c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e2e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e30:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e32:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e34:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e36:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e38:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e3a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e3c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e3e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e40:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e42:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e44:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e46:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e48:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e4a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e4c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e4e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e50:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e52:	812e                	mv	sp,a1
ffffffffc0200e54:	bdf5                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200e56 <check_vma_overlap.isra.1.part.2>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e56:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200e58:	00006697          	auipc	a3,0x6
ffffffffc0200e5c:	2f868693          	addi	a3,a3,760 # ffffffffc0207150 <commands+0x838>
ffffffffc0200e60:	00006617          	auipc	a2,0x6
ffffffffc0200e64:	f3860613          	addi	a2,a2,-200 # ffffffffc0206d98 <commands+0x480>
ffffffffc0200e68:	06d00593          	li	a1,109
ffffffffc0200e6c:	00006517          	auipc	a0,0x6
ffffffffc0200e70:	30450513          	addi	a0,a0,772 # ffffffffc0207170 <commands+0x858>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200e74:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200e76:	ba0ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200e7a <mm_create>:
mm_create(void) {
ffffffffc0200e7a:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e7c:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0200e80:	e022                	sd	s0,0(sp)
ffffffffc0200e82:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e84:	206010ef          	jal	ra,ffffffffc020208a <kmalloc>
ffffffffc0200e88:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200e8a:	c515                	beqz	a0,ffffffffc0200eb6 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200e8c:	000ab797          	auipc	a5,0xab
ffffffffc0200e90:	5fc78793          	addi	a5,a5,1532 # ffffffffc02ac488 <swap_init_ok>
ffffffffc0200e94:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e96:	e408                	sd	a0,8(s0)
ffffffffc0200e98:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200e9a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200e9e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200ea2:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ea6:	2781                	sext.w	a5,a5
ffffffffc0200ea8:	ef81                	bnez	a5,ffffffffc0200ec0 <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0200eaa:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0200eae:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0200eb2:	02043c23          	sd	zero,56(s0)
}
ffffffffc0200eb6:	8522                	mv	a0,s0
ffffffffc0200eb8:	60a2                	ld	ra,8(sp)
ffffffffc0200eba:	6402                	ld	s0,0(sp)
ffffffffc0200ebc:	0141                	addi	sp,sp,16
ffffffffc0200ebe:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ec0:	32b010ef          	jal	ra,ffffffffc02029ea <swap_init_mm>
ffffffffc0200ec4:	b7ed                	j	ffffffffc0200eae <mm_create+0x34>

ffffffffc0200ec6 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200ec6:	1101                	addi	sp,sp,-32
ffffffffc0200ec8:	e04a                	sd	s2,0(sp)
ffffffffc0200eca:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ecc:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200ed0:	e822                	sd	s0,16(sp)
ffffffffc0200ed2:	e426                	sd	s1,8(sp)
ffffffffc0200ed4:	ec06                	sd	ra,24(sp)
ffffffffc0200ed6:	84ae                	mv	s1,a1
ffffffffc0200ed8:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200eda:	1b0010ef          	jal	ra,ffffffffc020208a <kmalloc>
    if (vma != NULL) {
ffffffffc0200ede:	c509                	beqz	a0,ffffffffc0200ee8 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200ee0:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200ee4:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200ee6:	cd00                	sw	s0,24(a0)
}
ffffffffc0200ee8:	60e2                	ld	ra,24(sp)
ffffffffc0200eea:	6442                	ld	s0,16(sp)
ffffffffc0200eec:	64a2                	ld	s1,8(sp)
ffffffffc0200eee:	6902                	ld	s2,0(sp)
ffffffffc0200ef0:	6105                	addi	sp,sp,32
ffffffffc0200ef2:	8082                	ret

ffffffffc0200ef4 <find_vma>:
    if (mm != NULL) {
ffffffffc0200ef4:	c51d                	beqz	a0,ffffffffc0200f22 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0200ef6:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200ef8:	c781                	beqz	a5,ffffffffc0200f00 <find_vma+0xc>
ffffffffc0200efa:	6798                	ld	a4,8(a5)
ffffffffc0200efc:	02e5f663          	bleu	a4,a1,ffffffffc0200f28 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0200f00:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200f02:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200f04:	00f50f63          	beq	a0,a5,ffffffffc0200f22 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200f08:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200f0c:	fee5ebe3          	bltu	a1,a4,ffffffffc0200f02 <find_vma+0xe>
ffffffffc0200f10:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200f14:	fee5f7e3          	bleu	a4,a1,ffffffffc0200f02 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0200f18:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0200f1a:	c781                	beqz	a5,ffffffffc0200f22 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0200f1c:	e91c                	sd	a5,16(a0)
}
ffffffffc0200f1e:	853e                	mv	a0,a5
ffffffffc0200f20:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0200f22:	4781                	li	a5,0
}
ffffffffc0200f24:	853e                	mv	a0,a5
ffffffffc0200f26:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200f28:	6b98                	ld	a4,16(a5)
ffffffffc0200f2a:	fce5fbe3          	bleu	a4,a1,ffffffffc0200f00 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0200f2e:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0200f30:	b7fd                	j	ffffffffc0200f1e <find_vma+0x2a>

ffffffffc0200f32 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f32:	6590                	ld	a2,8(a1)
ffffffffc0200f34:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200f38:	1141                	addi	sp,sp,-16
ffffffffc0200f3a:	e406                	sd	ra,8(sp)
ffffffffc0200f3c:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f3e:	01066863          	bltu	a2,a6,ffffffffc0200f4e <insert_vma_struct+0x1c>
ffffffffc0200f42:	a8b9                	j	ffffffffc0200fa0 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200f44:	fe87b683          	ld	a3,-24(a5)
ffffffffc0200f48:	04d66763          	bltu	a2,a3,ffffffffc0200f96 <insert_vma_struct+0x64>
ffffffffc0200f4c:	873e                	mv	a4,a5
ffffffffc0200f4e:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0200f50:	fef51ae3          	bne	a0,a5,ffffffffc0200f44 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200f54:	02a70463          	beq	a4,a0,ffffffffc0200f7c <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200f58:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f5c:	fe873883          	ld	a7,-24(a4)
ffffffffc0200f60:	08d8f063          	bleu	a3,a7,ffffffffc0200fe0 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f64:	04d66e63          	bltu	a2,a3,ffffffffc0200fc0 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0200f68:	00f50a63          	beq	a0,a5,ffffffffc0200f7c <insert_vma_struct+0x4a>
ffffffffc0200f6c:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f70:	0506e863          	bltu	a3,a6,ffffffffc0200fc0 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0200f74:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200f78:	02c6f263          	bleu	a2,a3,ffffffffc0200f9c <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200f7c:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0200f7e:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200f80:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200f84:	e390                	sd	a2,0(a5)
ffffffffc0200f86:	e710                	sd	a2,8(a4)
}
ffffffffc0200f88:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200f8a:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200f8c:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0200f8e:	2685                	addiw	a3,a3,1
ffffffffc0200f90:	d114                	sw	a3,32(a0)
}
ffffffffc0200f92:	0141                	addi	sp,sp,16
ffffffffc0200f94:	8082                	ret
    if (le_prev != list) {
ffffffffc0200f96:	fca711e3          	bne	a4,a0,ffffffffc0200f58 <insert_vma_struct+0x26>
ffffffffc0200f9a:	bfd9                	j	ffffffffc0200f70 <insert_vma_struct+0x3e>
ffffffffc0200f9c:	ebbff0ef          	jal	ra,ffffffffc0200e56 <check_vma_overlap.isra.1.part.2>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200fa0:	00006697          	auipc	a3,0x6
ffffffffc0200fa4:	30868693          	addi	a3,a3,776 # ffffffffc02072a8 <commands+0x990>
ffffffffc0200fa8:	00006617          	auipc	a2,0x6
ffffffffc0200fac:	df060613          	addi	a2,a2,-528 # ffffffffc0206d98 <commands+0x480>
ffffffffc0200fb0:	07400593          	li	a1,116
ffffffffc0200fb4:	00006517          	auipc	a0,0x6
ffffffffc0200fb8:	1bc50513          	addi	a0,a0,444 # ffffffffc0207170 <commands+0x858>
ffffffffc0200fbc:	a5aff0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200fc0:	00006697          	auipc	a3,0x6
ffffffffc0200fc4:	32868693          	addi	a3,a3,808 # ffffffffc02072e8 <commands+0x9d0>
ffffffffc0200fc8:	00006617          	auipc	a2,0x6
ffffffffc0200fcc:	dd060613          	addi	a2,a2,-560 # ffffffffc0206d98 <commands+0x480>
ffffffffc0200fd0:	06c00593          	li	a1,108
ffffffffc0200fd4:	00006517          	auipc	a0,0x6
ffffffffc0200fd8:	19c50513          	addi	a0,a0,412 # ffffffffc0207170 <commands+0x858>
ffffffffc0200fdc:	a3aff0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200fe0:	00006697          	auipc	a3,0x6
ffffffffc0200fe4:	2e868693          	addi	a3,a3,744 # ffffffffc02072c8 <commands+0x9b0>
ffffffffc0200fe8:	00006617          	auipc	a2,0x6
ffffffffc0200fec:	db060613          	addi	a2,a2,-592 # ffffffffc0206d98 <commands+0x480>
ffffffffc0200ff0:	06b00593          	li	a1,107
ffffffffc0200ff4:	00006517          	auipc	a0,0x6
ffffffffc0200ff8:	17c50513          	addi	a0,a0,380 # ffffffffc0207170 <commands+0x858>
ffffffffc0200ffc:	a1aff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201000 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0201000:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0201002:	1141                	addi	sp,sp,-16
ffffffffc0201004:	e406                	sd	ra,8(sp)
ffffffffc0201006:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0201008:	e78d                	bnez	a5,ffffffffc0201032 <mm_destroy+0x32>
ffffffffc020100a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020100c:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020100e:	00a40c63          	beq	s0,a0,ffffffffc0201026 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201012:	6118                	ld	a4,0(a0)
ffffffffc0201014:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0201016:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201018:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020101a:	e398                	sd	a4,0(a5)
ffffffffc020101c:	12a010ef          	jal	ra,ffffffffc0202146 <kfree>
    return listelm->next;
ffffffffc0201020:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201022:	fea418e3          	bne	s0,a0,ffffffffc0201012 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0201026:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201028:	6402                	ld	s0,0(sp)
ffffffffc020102a:	60a2                	ld	ra,8(sp)
ffffffffc020102c:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020102e:	1180106f          	j	ffffffffc0202146 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0201032:	00006697          	auipc	a3,0x6
ffffffffc0201036:	2d668693          	addi	a3,a3,726 # ffffffffc0207308 <commands+0x9f0>
ffffffffc020103a:	00006617          	auipc	a2,0x6
ffffffffc020103e:	d5e60613          	addi	a2,a2,-674 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201042:	09400593          	li	a1,148
ffffffffc0201046:	00006517          	auipc	a0,0x6
ffffffffc020104a:	12a50513          	addi	a0,a0,298 # ffffffffc0207170 <commands+0x858>
ffffffffc020104e:	9c8ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201052 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201052:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc0201054:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201056:	17fd                	addi	a5,a5,-1
ffffffffc0201058:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc020105a:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020105c:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc0201060:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201062:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc0201064:	fc06                	sd	ra,56(sp)
ffffffffc0201066:	f04a                	sd	s2,32(sp)
ffffffffc0201068:	ec4e                	sd	s3,24(sp)
ffffffffc020106a:	e852                	sd	s4,16(sp)
ffffffffc020106c:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020106e:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc0201072:	002007b7          	lui	a5,0x200
ffffffffc0201076:	01047433          	and	s0,s0,a6
ffffffffc020107a:	06f4e363          	bltu	s1,a5,ffffffffc02010e0 <mm_map+0x8e>
ffffffffc020107e:	0684f163          	bleu	s0,s1,ffffffffc02010e0 <mm_map+0x8e>
ffffffffc0201082:	4785                	li	a5,1
ffffffffc0201084:	07fe                	slli	a5,a5,0x1f
ffffffffc0201086:	0487ed63          	bltu	a5,s0,ffffffffc02010e0 <mm_map+0x8e>
ffffffffc020108a:	89aa                	mv	s3,a0
ffffffffc020108c:	8a3a                	mv	s4,a4
ffffffffc020108e:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0201090:	c931                	beqz	a0,ffffffffc02010e4 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0201092:	85a6                	mv	a1,s1
ffffffffc0201094:	e61ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc0201098:	c501                	beqz	a0,ffffffffc02010a0 <mm_map+0x4e>
ffffffffc020109a:	651c                	ld	a5,8(a0)
ffffffffc020109c:	0487e263          	bltu	a5,s0,ffffffffc02010e0 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02010a0:	03000513          	li	a0,48
ffffffffc02010a4:	7e7000ef          	jal	ra,ffffffffc020208a <kmalloc>
ffffffffc02010a8:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02010aa:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02010ac:	02090163          	beqz	s2,ffffffffc02010ce <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02010b0:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02010b2:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02010b6:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02010ba:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02010be:	85ca                	mv	a1,s2
ffffffffc02010c0:	e73ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02010c4:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc02010c6:	000a0463          	beqz	s4,ffffffffc02010ce <mm_map+0x7c>
        *vma_store = vma;
ffffffffc02010ca:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02010ce:	70e2                	ld	ra,56(sp)
ffffffffc02010d0:	7442                	ld	s0,48(sp)
ffffffffc02010d2:	74a2                	ld	s1,40(sp)
ffffffffc02010d4:	7902                	ld	s2,32(sp)
ffffffffc02010d6:	69e2                	ld	s3,24(sp)
ffffffffc02010d8:	6a42                	ld	s4,16(sp)
ffffffffc02010da:	6aa2                	ld	s5,8(sp)
ffffffffc02010dc:	6121                	addi	sp,sp,64
ffffffffc02010de:	8082                	ret
        return -E_INVAL;
ffffffffc02010e0:	5575                	li	a0,-3
ffffffffc02010e2:	b7f5                	j	ffffffffc02010ce <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc02010e4:	00006697          	auipc	a3,0x6
ffffffffc02010e8:	23c68693          	addi	a3,a3,572 # ffffffffc0207320 <commands+0xa08>
ffffffffc02010ec:	00006617          	auipc	a2,0x6
ffffffffc02010f0:	cac60613          	addi	a2,a2,-852 # ffffffffc0206d98 <commands+0x480>
ffffffffc02010f4:	0a700593          	li	a1,167
ffffffffc02010f8:	00006517          	auipc	a0,0x6
ffffffffc02010fc:	07850513          	addi	a0,a0,120 # ffffffffc0207170 <commands+0x858>
ffffffffc0201100:	916ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201104 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0201104:	7139                	addi	sp,sp,-64
ffffffffc0201106:	fc06                	sd	ra,56(sp)
ffffffffc0201108:	f822                	sd	s0,48(sp)
ffffffffc020110a:	f426                	sd	s1,40(sp)
ffffffffc020110c:	f04a                	sd	s2,32(sp)
ffffffffc020110e:	ec4e                	sd	s3,24(sp)
ffffffffc0201110:	e852                	sd	s4,16(sp)
ffffffffc0201112:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0201114:	c535                	beqz	a0,ffffffffc0201180 <dup_mmap+0x7c>
ffffffffc0201116:	892a                	mv	s2,a0
ffffffffc0201118:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020111a:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020111c:	e59d                	bnez	a1,ffffffffc020114a <dup_mmap+0x46>
ffffffffc020111e:	a08d                	j	ffffffffc0201180 <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0201120:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0201122:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5588>
        insert_vma_struct(to, nvma);
ffffffffc0201126:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0201128:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc020112c:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc0201130:	e03ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>

        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0201134:	ff043683          	ld	a3,-16(s0)
ffffffffc0201138:	fe843603          	ld	a2,-24(s0)
ffffffffc020113c:	6c8c                	ld	a1,24(s1)
ffffffffc020113e:	01893503          	ld	a0,24(s2)
ffffffffc0201142:	4705                	li	a4,1
ffffffffc0201144:	02b030ef          	jal	ra,ffffffffc020496e <copy_range>
ffffffffc0201148:	e105                	bnez	a0,ffffffffc0201168 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc020114a:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc020114c:	02848863          	beq	s1,s0,ffffffffc020117c <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201150:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0201154:	fe843a83          	ld	s5,-24(s0)
ffffffffc0201158:	ff043a03          	ld	s4,-16(s0)
ffffffffc020115c:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201160:	72b000ef          	jal	ra,ffffffffc020208a <kmalloc>
ffffffffc0201164:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc0201166:	fd4d                	bnez	a0,ffffffffc0201120 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0201168:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020116a:	70e2                	ld	ra,56(sp)
ffffffffc020116c:	7442                	ld	s0,48(sp)
ffffffffc020116e:	74a2                	ld	s1,40(sp)
ffffffffc0201170:	7902                	ld	s2,32(sp)
ffffffffc0201172:	69e2                	ld	s3,24(sp)
ffffffffc0201174:	6a42                	ld	s4,16(sp)
ffffffffc0201176:	6aa2                	ld	s5,8(sp)
ffffffffc0201178:	6121                	addi	sp,sp,64
ffffffffc020117a:	8082                	ret
    return 0;
ffffffffc020117c:	4501                	li	a0,0
ffffffffc020117e:	b7f5                	j	ffffffffc020116a <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc0201180:	00006697          	auipc	a3,0x6
ffffffffc0201184:	0e868693          	addi	a3,a3,232 # ffffffffc0207268 <commands+0x950>
ffffffffc0201188:	00006617          	auipc	a2,0x6
ffffffffc020118c:	c1060613          	addi	a2,a2,-1008 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201190:	0c000593          	li	a1,192
ffffffffc0201194:	00006517          	auipc	a0,0x6
ffffffffc0201198:	fdc50513          	addi	a0,a0,-36 # ffffffffc0207170 <commands+0x858>
ffffffffc020119c:	87aff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02011a0 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02011a0:	1101                	addi	sp,sp,-32
ffffffffc02011a2:	ec06                	sd	ra,24(sp)
ffffffffc02011a4:	e822                	sd	s0,16(sp)
ffffffffc02011a6:	e426                	sd	s1,8(sp)
ffffffffc02011a8:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02011aa:	c531                	beqz	a0,ffffffffc02011f6 <exit_mmap+0x56>
ffffffffc02011ac:	591c                	lw	a5,48(a0)
ffffffffc02011ae:	84aa                	mv	s1,a0
ffffffffc02011b0:	e3b9                	bnez	a5,ffffffffc02011f6 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02011b2:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02011b4:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02011b8:	02850663          	beq	a0,s0,ffffffffc02011e4 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02011bc:	ff043603          	ld	a2,-16(s0)
ffffffffc02011c0:	fe843583          	ld	a1,-24(s0)
ffffffffc02011c4:	854a                	mv	a0,s2
ffffffffc02011c6:	07f020ef          	jal	ra,ffffffffc0203a44 <unmap_range>
ffffffffc02011ca:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02011cc:	fe8498e3          	bne	s1,s0,ffffffffc02011bc <exit_mmap+0x1c>
ffffffffc02011d0:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc02011d2:	00848c63          	beq	s1,s0,ffffffffc02011ea <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02011d6:	ff043603          	ld	a2,-16(s0)
ffffffffc02011da:	fe843583          	ld	a1,-24(s0)
ffffffffc02011de:	854a                	mv	a0,s2
ffffffffc02011e0:	17d020ef          	jal	ra,ffffffffc0203b5c <exit_range>
ffffffffc02011e4:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02011e6:	fe8498e3          	bne	s1,s0,ffffffffc02011d6 <exit_mmap+0x36>
    }
}
ffffffffc02011ea:	60e2                	ld	ra,24(sp)
ffffffffc02011ec:	6442                	ld	s0,16(sp)
ffffffffc02011ee:	64a2                	ld	s1,8(sp)
ffffffffc02011f0:	6902                	ld	s2,0(sp)
ffffffffc02011f2:	6105                	addi	sp,sp,32
ffffffffc02011f4:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02011f6:	00006697          	auipc	a3,0x6
ffffffffc02011fa:	09268693          	addi	a3,a3,146 # ffffffffc0207288 <commands+0x970>
ffffffffc02011fe:	00006617          	auipc	a2,0x6
ffffffffc0201202:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201206:	0d600593          	li	a1,214
ffffffffc020120a:	00006517          	auipc	a0,0x6
ffffffffc020120e:	f6650513          	addi	a0,a0,-154 # ffffffffc0207170 <commands+0x858>
ffffffffc0201212:	804ff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201216 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201216:	7139                	addi	sp,sp,-64
ffffffffc0201218:	f822                	sd	s0,48(sp)
ffffffffc020121a:	f426                	sd	s1,40(sp)
ffffffffc020121c:	fc06                	sd	ra,56(sp)
ffffffffc020121e:	f04a                	sd	s2,32(sp)
ffffffffc0201220:	ec4e                	sd	s3,24(sp)
ffffffffc0201222:	e852                	sd	s4,16(sp)
ffffffffc0201224:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0201226:	c55ff0ef          	jal	ra,ffffffffc0200e7a <mm_create>
    assert(mm != NULL);
ffffffffc020122a:	842a                	mv	s0,a0
ffffffffc020122c:	03200493          	li	s1,50
ffffffffc0201230:	e919                	bnez	a0,ffffffffc0201246 <vmm_init+0x30>
ffffffffc0201232:	a989                	j	ffffffffc0201684 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0201234:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201236:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201238:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020123c:	14ed                	addi	s1,s1,-5
ffffffffc020123e:	8522                	mv	a0,s0
ffffffffc0201240:	cf3ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201244:	c88d                	beqz	s1,ffffffffc0201276 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201246:	03000513          	li	a0,48
ffffffffc020124a:	641000ef          	jal	ra,ffffffffc020208a <kmalloc>
ffffffffc020124e:	85aa                	mv	a1,a0
ffffffffc0201250:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201254:	f165                	bnez	a0,ffffffffc0201234 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0201256:	00006697          	auipc	a3,0x6
ffffffffc020125a:	34a68693          	addi	a3,a3,842 # ffffffffc02075a0 <commands+0xc88>
ffffffffc020125e:	00006617          	auipc	a2,0x6
ffffffffc0201262:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201266:	11300593          	li	a1,275
ffffffffc020126a:	00006517          	auipc	a0,0x6
ffffffffc020126e:	f0650513          	addi	a0,a0,-250 # ffffffffc0207170 <commands+0x858>
ffffffffc0201272:	fa5fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0201276:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020127a:	1f900913          	li	s2,505
ffffffffc020127e:	a819                	j	ffffffffc0201294 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201280:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201282:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201284:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201288:	0495                	addi	s1,s1,5
ffffffffc020128a:	8522                	mv	a0,s0
ffffffffc020128c:	ca7ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201290:	03248a63          	beq	s1,s2,ffffffffc02012c4 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201294:	03000513          	li	a0,48
ffffffffc0201298:	5f3000ef          	jal	ra,ffffffffc020208a <kmalloc>
ffffffffc020129c:	85aa                	mv	a1,a0
ffffffffc020129e:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02012a2:	fd79                	bnez	a0,ffffffffc0201280 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02012a4:	00006697          	auipc	a3,0x6
ffffffffc02012a8:	2fc68693          	addi	a3,a3,764 # ffffffffc02075a0 <commands+0xc88>
ffffffffc02012ac:	00006617          	auipc	a2,0x6
ffffffffc02012b0:	aec60613          	addi	a2,a2,-1300 # ffffffffc0206d98 <commands+0x480>
ffffffffc02012b4:	11900593          	li	a1,281
ffffffffc02012b8:	00006517          	auipc	a0,0x6
ffffffffc02012bc:	eb850513          	addi	a0,a0,-328 # ffffffffc0207170 <commands+0x858>
ffffffffc02012c0:	f57fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc02012c4:	6418                	ld	a4,8(s0)
ffffffffc02012c6:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02012c8:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02012cc:	2ee40063          	beq	s0,a4,ffffffffc02015ac <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02012d0:	fe873603          	ld	a2,-24(a4)
ffffffffc02012d4:	ffe78693          	addi	a3,a5,-2
ffffffffc02012d8:	24d61a63          	bne	a2,a3,ffffffffc020152c <vmm_init+0x316>
ffffffffc02012dc:	ff073683          	ld	a3,-16(a4)
ffffffffc02012e0:	24f69663          	bne	a3,a5,ffffffffc020152c <vmm_init+0x316>
ffffffffc02012e4:	0795                	addi	a5,a5,5
ffffffffc02012e6:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02012e8:	feb792e3          	bne	a5,a1,ffffffffc02012cc <vmm_init+0xb6>
ffffffffc02012ec:	491d                	li	s2,7
ffffffffc02012ee:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02012f0:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02012f4:	85a6                	mv	a1,s1
ffffffffc02012f6:	8522                	mv	a0,s0
ffffffffc02012f8:	bfdff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc02012fc:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc02012fe:	30050763          	beqz	a0,ffffffffc020160c <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0201302:	00148593          	addi	a1,s1,1
ffffffffc0201306:	8522                	mv	a0,s0
ffffffffc0201308:	bedff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc020130c:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020130e:	2c050f63          	beqz	a0,ffffffffc02015ec <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201312:	85ca                	mv	a1,s2
ffffffffc0201314:	8522                	mv	a0,s0
ffffffffc0201316:	bdfff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
        assert(vma3 == NULL);
ffffffffc020131a:	2a051963          	bnez	a0,ffffffffc02015cc <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020131e:	00348593          	addi	a1,s1,3
ffffffffc0201322:	8522                	mv	a0,s0
ffffffffc0201324:	bd1ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
        assert(vma4 == NULL);
ffffffffc0201328:	32051263          	bnez	a0,ffffffffc020164c <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020132c:	00448593          	addi	a1,s1,4
ffffffffc0201330:	8522                	mv	a0,s0
ffffffffc0201332:	bc3ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
        assert(vma5 == NULL);
ffffffffc0201336:	2e051b63          	bnez	a0,ffffffffc020162c <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020133a:	008a3783          	ld	a5,8(s4)
ffffffffc020133e:	20979763          	bne	a5,s1,ffffffffc020154c <vmm_init+0x336>
ffffffffc0201342:	010a3783          	ld	a5,16(s4)
ffffffffc0201346:	21279363          	bne	a5,s2,ffffffffc020154c <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020134a:	0089b783          	ld	a5,8(s3)
ffffffffc020134e:	20979f63          	bne	a5,s1,ffffffffc020156c <vmm_init+0x356>
ffffffffc0201352:	0109b783          	ld	a5,16(s3)
ffffffffc0201356:	21279b63          	bne	a5,s2,ffffffffc020156c <vmm_init+0x356>
ffffffffc020135a:	0495                	addi	s1,s1,5
ffffffffc020135c:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020135e:	f9549be3          	bne	s1,s5,ffffffffc02012f4 <vmm_init+0xde>
ffffffffc0201362:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201364:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201366:	85a6                	mv	a1,s1
ffffffffc0201368:	8522                	mv	a0,s0
ffffffffc020136a:	b8bff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc020136e:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0201372:	c90d                	beqz	a0,ffffffffc02013a4 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201374:	6914                	ld	a3,16(a0)
ffffffffc0201376:	6510                	ld	a2,8(a0)
ffffffffc0201378:	00006517          	auipc	a0,0x6
ffffffffc020137c:	0b850513          	addi	a0,a0,184 # ffffffffc0207430 <commands+0xb18>
ffffffffc0201380:	d51fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201384:	00006697          	auipc	a3,0x6
ffffffffc0201388:	0d468693          	addi	a3,a3,212 # ffffffffc0207458 <commands+0xb40>
ffffffffc020138c:	00006617          	auipc	a2,0x6
ffffffffc0201390:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201394:	13b00593          	li	a1,315
ffffffffc0201398:	00006517          	auipc	a0,0x6
ffffffffc020139c:	dd850513          	addi	a0,a0,-552 # ffffffffc0207170 <commands+0x858>
ffffffffc02013a0:	e77fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc02013a4:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02013a6:	fd2490e3          	bne	s1,s2,ffffffffc0201366 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02013aa:	8522                	mv	a0,s0
ffffffffc02013ac:	c55ff0ef          	jal	ra,ffffffffc0201000 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02013b0:	00006517          	auipc	a0,0x6
ffffffffc02013b4:	0c050513          	addi	a0,a0,192 # ffffffffc0207470 <commands+0xb58>
ffffffffc02013b8:	d19fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02013bc:	414020ef          	jal	ra,ffffffffc02037d0 <nr_free_pages>
ffffffffc02013c0:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02013c2:	ab9ff0ef          	jal	ra,ffffffffc0200e7a <mm_create>
ffffffffc02013c6:	000ab797          	auipc	a5,0xab
ffffffffc02013ca:	10a7b123          	sd	a0,258(a5) # ffffffffc02ac4c8 <check_mm_struct>
ffffffffc02013ce:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc02013d0:	36050663          	beqz	a0,ffffffffc020173c <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013d4:	000ab797          	auipc	a5,0xab
ffffffffc02013d8:	0bc78793          	addi	a5,a5,188 # ffffffffc02ac490 <boot_pgdir>
ffffffffc02013dc:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02013e0:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02013e4:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02013e8:	2c079e63          	bnez	a5,ffffffffc02016c4 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013ec:	03000513          	li	a0,48
ffffffffc02013f0:	49b000ef          	jal	ra,ffffffffc020208a <kmalloc>
ffffffffc02013f4:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc02013f6:	18050b63          	beqz	a0,ffffffffc020158c <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc02013fa:	002007b7          	lui	a5,0x200
ffffffffc02013fe:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0201400:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0201402:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0201404:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0201406:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0201408:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc020140c:	b27ff0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0201410:	10000593          	li	a1,256
ffffffffc0201414:	8526                	mv	a0,s1
ffffffffc0201416:	adfff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc020141a:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020141e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0201422:	2ca41163          	bne	s0,a0,ffffffffc02016e4 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0201426:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5580>
        sum += i;
ffffffffc020142a:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020142c:	fee79de3          	bne	a5,a4,ffffffffc0201426 <vmm_init+0x210>
        sum += i;
ffffffffc0201430:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0201432:	10000793          	li	a5,256
        sum += i;
ffffffffc0201436:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8222>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020143a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020143e:	0007c683          	lbu	a3,0(a5)
ffffffffc0201442:	0785                	addi	a5,a5,1
ffffffffc0201444:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0201446:	fec79ce3          	bne	a5,a2,ffffffffc020143e <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc020144a:	2c071963          	bnez	a4,ffffffffc020171c <vmm_init+0x506>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc020144e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201452:	000aba97          	auipc	s5,0xab
ffffffffc0201456:	046a8a93          	addi	s5,s5,70 # ffffffffc02ac498 <npage>
ffffffffc020145a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020145e:	078a                	slli	a5,a5,0x2
ffffffffc0201460:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201462:	20e7f563          	bleu	a4,a5,ffffffffc020166c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201466:	00008697          	auipc	a3,0x8
ffffffffc020146a:	a6a68693          	addi	a3,a3,-1430 # ffffffffc0208ed0 <nbase>
ffffffffc020146e:	0006ba03          	ld	s4,0(a3)
ffffffffc0201472:	414786b3          	sub	a3,a5,s4
ffffffffc0201476:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201478:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020147a:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020147c:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc020147e:	83b1                	srli	a5,a5,0xc
ffffffffc0201480:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201482:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201484:	28e7f063          	bleu	a4,a5,ffffffffc0201704 <vmm_init+0x4ee>
ffffffffc0201488:	000ab797          	auipc	a5,0xab
ffffffffc020148c:	14078793          	addi	a5,a5,320 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0201490:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201492:	4581                	li	a1,0
ffffffffc0201494:	854a                	mv	a0,s2
ffffffffc0201496:	9436                	add	s0,s0,a3
ffffffffc0201498:	11b020ef          	jal	ra,ffffffffc0203db2 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020149c:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020149e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014a2:	078a                	slli	a5,a5,0x2
ffffffffc02014a4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014a6:	1ce7f363          	bleu	a4,a5,ffffffffc020166c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02014aa:	000ab417          	auipc	s0,0xab
ffffffffc02014ae:	12e40413          	addi	s0,s0,302 # ffffffffc02ac5d8 <pages>
ffffffffc02014b2:	6008                	ld	a0,0(s0)
ffffffffc02014b4:	414787b3          	sub	a5,a5,s4
ffffffffc02014b8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02014ba:	953e                	add	a0,a0,a5
ffffffffc02014bc:	4585                	li	a1,1
ffffffffc02014be:	2cc020ef          	jal	ra,ffffffffc020378a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014c2:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02014c6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014ca:	078a                	slli	a5,a5,0x2
ffffffffc02014cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014ce:	18e7ff63          	bleu	a4,a5,ffffffffc020166c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02014d2:	6008                	ld	a0,0(s0)
ffffffffc02014d4:	414787b3          	sub	a5,a5,s4
ffffffffc02014d8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02014da:	4585                	li	a1,1
ffffffffc02014dc:	953e                	add	a0,a0,a5
ffffffffc02014de:	2ac020ef          	jal	ra,ffffffffc020378a <free_pages>
    pgdir[0] = 0;
ffffffffc02014e2:	00093023          	sd	zero,0(s2)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc02014e6:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc02014ea:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc02014ee:	8526                	mv	a0,s1
ffffffffc02014f0:	b11ff0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02014f4:	000ab797          	auipc	a5,0xab
ffffffffc02014f8:	fc07ba23          	sd	zero,-44(a5) # ffffffffc02ac4c8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02014fc:	2d4020ef          	jal	ra,ffffffffc02037d0 <nr_free_pages>
ffffffffc0201500:	1aa99263          	bne	s3,a0,ffffffffc02016a4 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0201504:	00006517          	auipc	a0,0x6
ffffffffc0201508:	06450513          	addi	a0,a0,100 # ffffffffc0207568 <commands+0xc50>
ffffffffc020150c:	bc5fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201510:	7442                	ld	s0,48(sp)
ffffffffc0201512:	70e2                	ld	ra,56(sp)
ffffffffc0201514:	74a2                	ld	s1,40(sp)
ffffffffc0201516:	7902                	ld	s2,32(sp)
ffffffffc0201518:	69e2                	ld	s3,24(sp)
ffffffffc020151a:	6a42                	ld	s4,16(sp)
ffffffffc020151c:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020151e:	00006517          	auipc	a0,0x6
ffffffffc0201522:	06a50513          	addi	a0,a0,106 # ffffffffc0207588 <commands+0xc70>
}
ffffffffc0201526:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201528:	ba9fe06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020152c:	00006697          	auipc	a3,0x6
ffffffffc0201530:	e1c68693          	addi	a3,a3,-484 # ffffffffc0207348 <commands+0xa30>
ffffffffc0201534:	00006617          	auipc	a2,0x6
ffffffffc0201538:	86460613          	addi	a2,a2,-1948 # ffffffffc0206d98 <commands+0x480>
ffffffffc020153c:	12200593          	li	a1,290
ffffffffc0201540:	00006517          	auipc	a0,0x6
ffffffffc0201544:	c3050513          	addi	a0,a0,-976 # ffffffffc0207170 <commands+0x858>
ffffffffc0201548:	ccffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020154c:	00006697          	auipc	a3,0x6
ffffffffc0201550:	e8468693          	addi	a3,a3,-380 # ffffffffc02073d0 <commands+0xab8>
ffffffffc0201554:	00006617          	auipc	a2,0x6
ffffffffc0201558:	84460613          	addi	a2,a2,-1980 # ffffffffc0206d98 <commands+0x480>
ffffffffc020155c:	13200593          	li	a1,306
ffffffffc0201560:	00006517          	auipc	a0,0x6
ffffffffc0201564:	c1050513          	addi	a0,a0,-1008 # ffffffffc0207170 <commands+0x858>
ffffffffc0201568:	caffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020156c:	00006697          	auipc	a3,0x6
ffffffffc0201570:	e9468693          	addi	a3,a3,-364 # ffffffffc0207400 <commands+0xae8>
ffffffffc0201574:	00006617          	auipc	a2,0x6
ffffffffc0201578:	82460613          	addi	a2,a2,-2012 # ffffffffc0206d98 <commands+0x480>
ffffffffc020157c:	13300593          	li	a1,307
ffffffffc0201580:	00006517          	auipc	a0,0x6
ffffffffc0201584:	bf050513          	addi	a0,a0,-1040 # ffffffffc0207170 <commands+0x858>
ffffffffc0201588:	c8ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(vma != NULL);
ffffffffc020158c:	00006697          	auipc	a3,0x6
ffffffffc0201590:	01468693          	addi	a3,a3,20 # ffffffffc02075a0 <commands+0xc88>
ffffffffc0201594:	00006617          	auipc	a2,0x6
ffffffffc0201598:	80460613          	addi	a2,a2,-2044 # ffffffffc0206d98 <commands+0x480>
ffffffffc020159c:	15200593          	li	a1,338
ffffffffc02015a0:	00006517          	auipc	a0,0x6
ffffffffc02015a4:	bd050513          	addi	a0,a0,-1072 # ffffffffc0207170 <commands+0x858>
ffffffffc02015a8:	c6ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02015ac:	00006697          	auipc	a3,0x6
ffffffffc02015b0:	d8468693          	addi	a3,a3,-636 # ffffffffc0207330 <commands+0xa18>
ffffffffc02015b4:	00005617          	auipc	a2,0x5
ffffffffc02015b8:	7e460613          	addi	a2,a2,2020 # ffffffffc0206d98 <commands+0x480>
ffffffffc02015bc:	12000593          	li	a1,288
ffffffffc02015c0:	00006517          	auipc	a0,0x6
ffffffffc02015c4:	bb050513          	addi	a0,a0,-1104 # ffffffffc0207170 <commands+0x858>
ffffffffc02015c8:	c4ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma3 == NULL);
ffffffffc02015cc:	00006697          	auipc	a3,0x6
ffffffffc02015d0:	dd468693          	addi	a3,a3,-556 # ffffffffc02073a0 <commands+0xa88>
ffffffffc02015d4:	00005617          	auipc	a2,0x5
ffffffffc02015d8:	7c460613          	addi	a2,a2,1988 # ffffffffc0206d98 <commands+0x480>
ffffffffc02015dc:	12c00593          	li	a1,300
ffffffffc02015e0:	00006517          	auipc	a0,0x6
ffffffffc02015e4:	b9050513          	addi	a0,a0,-1136 # ffffffffc0207170 <commands+0x858>
ffffffffc02015e8:	c2ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2 != NULL);
ffffffffc02015ec:	00006697          	auipc	a3,0x6
ffffffffc02015f0:	da468693          	addi	a3,a3,-604 # ffffffffc0207390 <commands+0xa78>
ffffffffc02015f4:	00005617          	auipc	a2,0x5
ffffffffc02015f8:	7a460613          	addi	a2,a2,1956 # ffffffffc0206d98 <commands+0x480>
ffffffffc02015fc:	12a00593          	li	a1,298
ffffffffc0201600:	00006517          	auipc	a0,0x6
ffffffffc0201604:	b7050513          	addi	a0,a0,-1168 # ffffffffc0207170 <commands+0x858>
ffffffffc0201608:	c0ffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1 != NULL);
ffffffffc020160c:	00006697          	auipc	a3,0x6
ffffffffc0201610:	d7468693          	addi	a3,a3,-652 # ffffffffc0207380 <commands+0xa68>
ffffffffc0201614:	00005617          	auipc	a2,0x5
ffffffffc0201618:	78460613          	addi	a2,a2,1924 # ffffffffc0206d98 <commands+0x480>
ffffffffc020161c:	12800593          	li	a1,296
ffffffffc0201620:	00006517          	auipc	a0,0x6
ffffffffc0201624:	b5050513          	addi	a0,a0,-1200 # ffffffffc0207170 <commands+0x858>
ffffffffc0201628:	beffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma5 == NULL);
ffffffffc020162c:	00006697          	auipc	a3,0x6
ffffffffc0201630:	d9468693          	addi	a3,a3,-620 # ffffffffc02073c0 <commands+0xaa8>
ffffffffc0201634:	00005617          	auipc	a2,0x5
ffffffffc0201638:	76460613          	addi	a2,a2,1892 # ffffffffc0206d98 <commands+0x480>
ffffffffc020163c:	13000593          	li	a1,304
ffffffffc0201640:	00006517          	auipc	a0,0x6
ffffffffc0201644:	b3050513          	addi	a0,a0,-1232 # ffffffffc0207170 <commands+0x858>
ffffffffc0201648:	bcffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma4 == NULL);
ffffffffc020164c:	00006697          	auipc	a3,0x6
ffffffffc0201650:	d6468693          	addi	a3,a3,-668 # ffffffffc02073b0 <commands+0xa98>
ffffffffc0201654:	00005617          	auipc	a2,0x5
ffffffffc0201658:	74460613          	addi	a2,a2,1860 # ffffffffc0206d98 <commands+0x480>
ffffffffc020165c:	12e00593          	li	a1,302
ffffffffc0201660:	00006517          	auipc	a0,0x6
ffffffffc0201664:	b1050513          	addi	a0,a0,-1264 # ffffffffc0207170 <commands+0x858>
ffffffffc0201668:	baffe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020166c:	00006617          	auipc	a2,0x6
ffffffffc0201670:	e7c60613          	addi	a2,a2,-388 # ffffffffc02074e8 <commands+0xbd0>
ffffffffc0201674:	06200593          	li	a1,98
ffffffffc0201678:	00006517          	auipc	a0,0x6
ffffffffc020167c:	e9050513          	addi	a0,a0,-368 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0201680:	b97fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(mm != NULL);
ffffffffc0201684:	00006697          	auipc	a3,0x6
ffffffffc0201688:	c9c68693          	addi	a3,a3,-868 # ffffffffc0207320 <commands+0xa08>
ffffffffc020168c:	00005617          	auipc	a2,0x5
ffffffffc0201690:	70c60613          	addi	a2,a2,1804 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201694:	10c00593          	li	a1,268
ffffffffc0201698:	00006517          	auipc	a0,0x6
ffffffffc020169c:	ad850513          	addi	a0,a0,-1320 # ffffffffc0207170 <commands+0x858>
ffffffffc02016a0:	b77fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02016a4:	00006697          	auipc	a3,0x6
ffffffffc02016a8:	e9c68693          	addi	a3,a3,-356 # ffffffffc0207540 <commands+0xc28>
ffffffffc02016ac:	00005617          	auipc	a2,0x5
ffffffffc02016b0:	6ec60613          	addi	a2,a2,1772 # ffffffffc0206d98 <commands+0x480>
ffffffffc02016b4:	17000593          	li	a1,368
ffffffffc02016b8:	00006517          	auipc	a0,0x6
ffffffffc02016bc:	ab850513          	addi	a0,a0,-1352 # ffffffffc0207170 <commands+0x858>
ffffffffc02016c0:	b57fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02016c4:	00006697          	auipc	a3,0x6
ffffffffc02016c8:	de468693          	addi	a3,a3,-540 # ffffffffc02074a8 <commands+0xb90>
ffffffffc02016cc:	00005617          	auipc	a2,0x5
ffffffffc02016d0:	6cc60613          	addi	a2,a2,1740 # ffffffffc0206d98 <commands+0x480>
ffffffffc02016d4:	14f00593          	li	a1,335
ffffffffc02016d8:	00006517          	auipc	a0,0x6
ffffffffc02016dc:	a9850513          	addi	a0,a0,-1384 # ffffffffc0207170 <commands+0x858>
ffffffffc02016e0:	b37fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02016e4:	00006697          	auipc	a3,0x6
ffffffffc02016e8:	dd468693          	addi	a3,a3,-556 # ffffffffc02074b8 <commands+0xba0>
ffffffffc02016ec:	00005617          	auipc	a2,0x5
ffffffffc02016f0:	6ac60613          	addi	a2,a2,1708 # ffffffffc0206d98 <commands+0x480>
ffffffffc02016f4:	15700593          	li	a1,343
ffffffffc02016f8:	00006517          	auipc	a0,0x6
ffffffffc02016fc:	a7850513          	addi	a0,a0,-1416 # ffffffffc0207170 <commands+0x858>
ffffffffc0201700:	b17fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201704:	00006617          	auipc	a2,0x6
ffffffffc0201708:	e1460613          	addi	a2,a2,-492 # ffffffffc0207518 <commands+0xc00>
ffffffffc020170c:	06900593          	li	a1,105
ffffffffc0201710:	00006517          	auipc	a0,0x6
ffffffffc0201714:	df850513          	addi	a0,a0,-520 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0201718:	afffe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(sum == 0);
ffffffffc020171c:	00006697          	auipc	a3,0x6
ffffffffc0201720:	dbc68693          	addi	a3,a3,-580 # ffffffffc02074d8 <commands+0xbc0>
ffffffffc0201724:	00005617          	auipc	a2,0x5
ffffffffc0201728:	67460613          	addi	a2,a2,1652 # ffffffffc0206d98 <commands+0x480>
ffffffffc020172c:	16300593          	li	a1,355
ffffffffc0201730:	00006517          	auipc	a0,0x6
ffffffffc0201734:	a4050513          	addi	a0,a0,-1472 # ffffffffc0207170 <commands+0x858>
ffffffffc0201738:	adffe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020173c:	00006697          	auipc	a3,0x6
ffffffffc0201740:	d5468693          	addi	a3,a3,-684 # ffffffffc0207490 <commands+0xb78>
ffffffffc0201744:	00005617          	auipc	a2,0x5
ffffffffc0201748:	65460613          	addi	a2,a2,1620 # ffffffffc0206d98 <commands+0x480>
ffffffffc020174c:	14b00593          	li	a1,331
ffffffffc0201750:	00006517          	auipc	a0,0x6
ffffffffc0201754:	a2050513          	addi	a0,a0,-1504 # ffffffffc0207170 <commands+0x858>
ffffffffc0201758:	abffe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020175c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020175c:	715d                	addi	sp,sp,-80
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020175e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201760:	e0a2                	sd	s0,64(sp)
ffffffffc0201762:	fc26                	sd	s1,56(sp)
ffffffffc0201764:	e486                	sd	ra,72(sp)
ffffffffc0201766:	f84a                	sd	s2,48(sp)
ffffffffc0201768:	f44e                	sd	s3,40(sp)
ffffffffc020176a:	f052                	sd	s4,32(sp)
ffffffffc020176c:	ec56                	sd	s5,24(sp)
ffffffffc020176e:	8432                	mv	s0,a2
ffffffffc0201770:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201772:	f82ff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>

    pgfault_num++;
ffffffffc0201776:	000ab797          	auipc	a5,0xab
ffffffffc020177a:	cfa78793          	addi	a5,a5,-774 # ffffffffc02ac470 <pgfault_num>
ffffffffc020177e:	439c                	lw	a5,0(a5)
ffffffffc0201780:	2785                	addiw	a5,a5,1
ffffffffc0201782:	000ab717          	auipc	a4,0xab
ffffffffc0201786:	cef72723          	sw	a5,-786(a4) # ffffffffc02ac470 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc020178a:	14050a63          	beqz	a0,ffffffffc02018de <do_pgfault+0x182>
ffffffffc020178e:	651c                	ld	a5,8(a0)
ffffffffc0201790:	14f46763          	bltu	s0,a5,ffffffffc02018de <do_pgfault+0x182>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }

    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201794:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0201796:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201798:	8b89                	andi	a5,a5,2
ffffffffc020179a:	eba5                	bnez	a5,ffffffffc020180a <do_pgfault+0xae>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020179c:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020179e:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02017a0:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02017a2:	85a2                	mv	a1,s0
ffffffffc02017a4:	4605                	li	a2,1
ffffffffc02017a6:	06a020ef          	jal	ra,ffffffffc0203810 <get_pte>
ffffffffc02017aa:	892a                	mv	s2,a0
ffffffffc02017ac:	14050b63          	beqz	a0,ffffffffc0201902 <do_pgfault+0x1a6>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }

    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02017b0:	6110                	ld	a2,0(a0)
ffffffffc02017b2:	10060263          	beqz	a2,ffffffffc02018b6 <do_pgfault+0x15a>
            goto failed;
        }
    } 
    else 
    {
        struct Page *page=NULL;
ffffffffc02017b6:	e402                	sd	zero,8(sp)
        // 如果当前页错误的原因是写入了只读页面
        if (*ptep & PTE_V) {
ffffffffc02017b8:	00167793          	andi	a5,a2,1
ffffffffc02017bc:	eba9                	bnez	a5,ffffffffc020180e <do_pgfault+0xb2>
                // 保留当前物理页并重设其权限
                page_insert(mm->pgdir, page, addr, perm);
        }
        else
        {
            if(swap_init_ok) {
ffffffffc02017be:	000ab797          	auipc	a5,0xab
ffffffffc02017c2:	cca78793          	addi	a5,a5,-822 # ffffffffc02ac488 <swap_init_ok>
ffffffffc02017c6:	439c                	lw	a5,0(a5)
ffffffffc02017c8:	2781                	sext.w	a5,a5
ffffffffc02017ca:	12078363          	beqz	a5,ffffffffc02018f0 <do_pgfault+0x194>
                swap_in(mm, addr, &page);
ffffffffc02017ce:	85a2                	mv	a1,s0
ffffffffc02017d0:	0030                	addi	a2,sp,8
ffffffffc02017d2:	8526                	mv	a0,s1
ffffffffc02017d4:	34a010ef          	jal	ra,ffffffffc0202b1e <swap_in>
                page_insert(mm->pgdir, page, addr, perm);
ffffffffc02017d8:	65a2                	ld	a1,8(sp)
ffffffffc02017da:	6c88                	ld	a0,24(s1)
ffffffffc02017dc:	86ce                	mv	a3,s3
ffffffffc02017de:	8622                	mv	a2,s0
ffffffffc02017e0:	646020ef          	jal	ra,ffffffffc0203e26 <page_insert>
                cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
                goto failed;
            }
        }
        // 当前缺失的页已经加载回内存中，所以设置当前页为可交换。
        swap_map_swappable(mm, addr, page, 1);
ffffffffc02017e4:	6622                	ld	a2,8(sp)
ffffffffc02017e6:	4685                	li	a3,1
ffffffffc02017e8:	85a2                	mv	a1,s0
ffffffffc02017ea:	8526                	mv	a0,s1
ffffffffc02017ec:	20e010ef          	jal	ra,ffffffffc02029fa <swap_map_swappable>
        page->pra_vaddr = addr;
ffffffffc02017f0:	6722                	ld	a4,8(sp)
    }
    ret = 0;
ffffffffc02017f2:	4781                	li	a5,0
        page->pra_vaddr = addr;
ffffffffc02017f4:	ff00                	sd	s0,56(a4)
failed:
    return ret;
}
ffffffffc02017f6:	60a6                	ld	ra,72(sp)
ffffffffc02017f8:	6406                	ld	s0,64(sp)
ffffffffc02017fa:	74e2                	ld	s1,56(sp)
ffffffffc02017fc:	7942                	ld	s2,48(sp)
ffffffffc02017fe:	79a2                	ld	s3,40(sp)
ffffffffc0201800:	7a02                	ld	s4,32(sp)
ffffffffc0201802:	6ae2                	ld	s5,24(sp)
ffffffffc0201804:	853e                	mv	a0,a5
ffffffffc0201806:	6161                	addi	sp,sp,80
ffffffffc0201808:	8082                	ret
        perm |= READ_WRITE;
ffffffffc020180a:	49dd                	li	s3,23
ffffffffc020180c:	bf41                	j	ffffffffc020179c <do_pgfault+0x40>
            cprintf("\n\nCOW: ptep 0x%x, pte 0x%x\n",ptep, *ptep);
ffffffffc020180e:	85aa                	mv	a1,a0
ffffffffc0201810:	00006517          	auipc	a0,0x6
ffffffffc0201814:	9e850513          	addi	a0,a0,-1560 # ffffffffc02071f8 <commands+0x8e0>
ffffffffc0201818:	8b9fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            page = pte2page(*ptep);
ffffffffc020181c:	00093783          	ld	a5,0(s2)
    if (!(pte & PTE_V)) {
ffffffffc0201820:	0017f713          	andi	a4,a5,1
ffffffffc0201824:	10070463          	beqz	a4,ffffffffc020192c <do_pgfault+0x1d0>
    if (PPN(pa) >= npage) {
ffffffffc0201828:	000aba17          	auipc	s4,0xab
ffffffffc020182c:	c70a0a13          	addi	s4,s4,-912 # ffffffffc02ac498 <npage>
ffffffffc0201830:	000a3703          	ld	a4,0(s4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201834:	078a                	slli	a5,a5,0x2
ffffffffc0201836:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201838:	10e7f663          	bleu	a4,a5,ffffffffc0201944 <do_pgfault+0x1e8>
    return &pages[PPN(pa) - nbase];
ffffffffc020183c:	00007717          	auipc	a4,0x7
ffffffffc0201840:	69470713          	addi	a4,a4,1684 # ffffffffc0208ed0 <nbase>
ffffffffc0201844:	00073903          	ld	s2,0(a4)
ffffffffc0201848:	000aba97          	auipc	s5,0xab
ffffffffc020184c:	d90a8a93          	addi	s5,s5,-624 # ffffffffc02ac5d8 <pages>
ffffffffc0201850:	000ab583          	ld	a1,0(s5)
ffffffffc0201854:	412787b3          	sub	a5,a5,s2
ffffffffc0201858:	079a                	slli	a5,a5,0x6
ffffffffc020185a:	95be                	add	a1,a1,a5
            if(page_ref(page) > 1)
ffffffffc020185c:	4198                	lw	a4,0(a1)
ffffffffc020185e:	4785                	li	a5,1
            page = pte2page(*ptep);
ffffffffc0201860:	e42e                	sd	a1,8(sp)
    return page->ref;
ffffffffc0201862:	6c88                	ld	a0,24(s1)
            if(page_ref(page) > 1)
ffffffffc0201864:	06e7d863          	ble	a4,a5,ffffffffc02018d4 <do_pgfault+0x178>
                struct Page* new_page = pgdir_alloc_page(mm->pgdir, addr, perm);
ffffffffc0201868:	864e                	mv	a2,s3
ffffffffc020186a:	85a2                	mv	a1,s0
ffffffffc020186c:	3b8030ef          	jal	ra,ffffffffc0204c24 <pgdir_alloc_page>
    return page - pages + nbase;
ffffffffc0201870:	000ab783          	ld	a5,0(s5)
ffffffffc0201874:	66a2                	ld	a3,8(sp)
    return KADDR(page2pa(page));
ffffffffc0201876:	577d                	li	a4,-1
ffffffffc0201878:	000a3603          	ld	a2,0(s4)
    return page - pages + nbase;
ffffffffc020187c:	8e9d                	sub	a3,a3,a5
ffffffffc020187e:	8699                	srai	a3,a3,0x6
ffffffffc0201880:	96ca                	add	a3,a3,s2
    return KADDR(page2pa(page));
ffffffffc0201882:	8331                	srli	a4,a4,0xc
ffffffffc0201884:	00e6f5b3          	and	a1,a3,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0201888:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020188a:	08c5f563          	bleu	a2,a1,ffffffffc0201914 <do_pgfault+0x1b8>
    return page - pages + nbase;
ffffffffc020188e:	40f507b3          	sub	a5,a0,a5
    return KADDR(page2pa(page));
ffffffffc0201892:	000ab597          	auipc	a1,0xab
ffffffffc0201896:	d3658593          	addi	a1,a1,-714 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc020189a:	6188                	ld	a0,0(a1)
    return page - pages + nbase;
ffffffffc020189c:	8799                	srai	a5,a5,0x6
ffffffffc020189e:	97ca                	add	a5,a5,s2
    return KADDR(page2pa(page));
ffffffffc02018a0:	8f7d                	and	a4,a4,a5
ffffffffc02018a2:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02018a6:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02018a8:	06c77563          	bleu	a2,a4,ffffffffc0201912 <do_pgfault+0x1b6>
                memcpy(dst_kva, src_kva, PGSIZE);
ffffffffc02018ac:	6605                	lui	a2,0x1
ffffffffc02018ae:	953e                	add	a0,a0,a5
ffffffffc02018b0:	2cf040ef          	jal	ra,ffffffffc020637e <memcpy>
ffffffffc02018b4:	bf05                	j	ffffffffc02017e4 <do_pgfault+0x88>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02018b6:	6c88                	ld	a0,24(s1)
ffffffffc02018b8:	864e                	mv	a2,s3
ffffffffc02018ba:	85a2                	mv	a1,s0
ffffffffc02018bc:	368030ef          	jal	ra,ffffffffc0204c24 <pgdir_alloc_page>
    ret = 0;
ffffffffc02018c0:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02018c2:	f915                	bnez	a0,ffffffffc02017f6 <do_pgfault+0x9a>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02018c4:	00006517          	auipc	a0,0x6
ffffffffc02018c8:	90c50513          	addi	a0,a0,-1780 # ffffffffc02071d0 <commands+0x8b8>
ffffffffc02018cc:	805fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02018d0:	57f1                	li	a5,-4
            goto failed;
ffffffffc02018d2:	b715                	j	ffffffffc02017f6 <do_pgfault+0x9a>
                page_insert(mm->pgdir, page, addr, perm);
ffffffffc02018d4:	86ce                	mv	a3,s3
ffffffffc02018d6:	8622                	mv	a2,s0
ffffffffc02018d8:	54e020ef          	jal	ra,ffffffffc0203e26 <page_insert>
ffffffffc02018dc:	b721                	j	ffffffffc02017e4 <do_pgfault+0x88>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02018de:	85a2                	mv	a1,s0
ffffffffc02018e0:	00006517          	auipc	a0,0x6
ffffffffc02018e4:	8a050513          	addi	a0,a0,-1888 # ffffffffc0207180 <commands+0x868>
ffffffffc02018e8:	fe8fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc02018ec:	57f5                	li	a5,-3
        goto failed;
ffffffffc02018ee:	b721                	j	ffffffffc02017f6 <do_pgfault+0x9a>
                cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
ffffffffc02018f0:	85b2                	mv	a1,a2
ffffffffc02018f2:	00006517          	auipc	a0,0x6
ffffffffc02018f6:	94e50513          	addi	a0,a0,-1714 # ffffffffc0207240 <commands+0x928>
ffffffffc02018fa:	fd6fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02018fe:	57f1                	li	a5,-4
ffffffffc0201900:	bddd                	j	ffffffffc02017f6 <do_pgfault+0x9a>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0201902:	00006517          	auipc	a0,0x6
ffffffffc0201906:	8ae50513          	addi	a0,a0,-1874 # ffffffffc02071b0 <commands+0x898>
ffffffffc020190a:	fc6fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020190e:	57f1                	li	a5,-4
        goto failed;
ffffffffc0201910:	b5dd                	j	ffffffffc02017f6 <do_pgfault+0x9a>
ffffffffc0201912:	86be                	mv	a3,a5
ffffffffc0201914:	00006617          	auipc	a2,0x6
ffffffffc0201918:	c0460613          	addi	a2,a2,-1020 # ffffffffc0207518 <commands+0xc00>
ffffffffc020191c:	06900593          	li	a1,105
ffffffffc0201920:	00006517          	auipc	a0,0x6
ffffffffc0201924:	be850513          	addi	a0,a0,-1048 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0201928:	8effe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020192c:	00006617          	auipc	a2,0x6
ffffffffc0201930:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0207218 <commands+0x900>
ffffffffc0201934:	07400593          	li	a1,116
ffffffffc0201938:	00006517          	auipc	a0,0x6
ffffffffc020193c:	bd050513          	addi	a0,a0,-1072 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0201940:	8d7fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201944:	00006617          	auipc	a2,0x6
ffffffffc0201948:	ba460613          	addi	a2,a2,-1116 # ffffffffc02074e8 <commands+0xbd0>
ffffffffc020194c:	06200593          	li	a1,98
ffffffffc0201950:	00006517          	auipc	a0,0x6
ffffffffc0201954:	bb850513          	addi	a0,a0,-1096 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0201958:	8bffe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020195c <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc020195c:	7179                	addi	sp,sp,-48
ffffffffc020195e:	f022                	sd	s0,32(sp)
ffffffffc0201960:	f406                	sd	ra,40(sp)
ffffffffc0201962:	ec26                	sd	s1,24(sp)
ffffffffc0201964:	e84a                	sd	s2,16(sp)
ffffffffc0201966:	e44e                	sd	s3,8(sp)
ffffffffc0201968:	e052                	sd	s4,0(sp)
ffffffffc020196a:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc020196c:	c135                	beqz	a0,ffffffffc02019d0 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc020196e:	002007b7          	lui	a5,0x200
ffffffffc0201972:	04f5e663          	bltu	a1,a5,ffffffffc02019be <user_mem_check+0x62>
ffffffffc0201976:	00c584b3          	add	s1,a1,a2
ffffffffc020197a:	0495f263          	bleu	s1,a1,ffffffffc02019be <user_mem_check+0x62>
ffffffffc020197e:	4785                	li	a5,1
ffffffffc0201980:	07fe                	slli	a5,a5,0x1f
ffffffffc0201982:	0297ee63          	bltu	a5,s1,ffffffffc02019be <user_mem_check+0x62>
ffffffffc0201986:	892a                	mv	s2,a0
ffffffffc0201988:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020198a:	6a05                	lui	s4,0x1
ffffffffc020198c:	a821                	j	ffffffffc02019a4 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc020198e:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0201992:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201994:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201996:	c685                	beqz	a3,ffffffffc02019be <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201998:	c399                	beqz	a5,ffffffffc020199e <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc020199a:	02e46263          	bltu	s0,a4,ffffffffc02019be <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc020199e:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc02019a0:	04947663          	bleu	s1,s0,ffffffffc02019ec <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc02019a4:	85a2                	mv	a1,s0
ffffffffc02019a6:	854a                	mv	a0,s2
ffffffffc02019a8:	d4cff0ef          	jal	ra,ffffffffc0200ef4 <find_vma>
ffffffffc02019ac:	c909                	beqz	a0,ffffffffc02019be <user_mem_check+0x62>
ffffffffc02019ae:	6518                	ld	a4,8(a0)
ffffffffc02019b0:	00e46763          	bltu	s0,a4,ffffffffc02019be <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02019b4:	4d1c                	lw	a5,24(a0)
ffffffffc02019b6:	fc099ce3          	bnez	s3,ffffffffc020198e <user_mem_check+0x32>
ffffffffc02019ba:	8b85                	andi	a5,a5,1
ffffffffc02019bc:	f3ed                	bnez	a5,ffffffffc020199e <user_mem_check+0x42>
            return 0;
ffffffffc02019be:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc02019c0:	70a2                	ld	ra,40(sp)
ffffffffc02019c2:	7402                	ld	s0,32(sp)
ffffffffc02019c4:	64e2                	ld	s1,24(sp)
ffffffffc02019c6:	6942                	ld	s2,16(sp)
ffffffffc02019c8:	69a2                	ld	s3,8(sp)
ffffffffc02019ca:	6a02                	ld	s4,0(sp)
ffffffffc02019cc:	6145                	addi	sp,sp,48
ffffffffc02019ce:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc02019d0:	c02007b7          	lui	a5,0xc0200
ffffffffc02019d4:	4501                	li	a0,0
ffffffffc02019d6:	fef5e5e3          	bltu	a1,a5,ffffffffc02019c0 <user_mem_check+0x64>
ffffffffc02019da:	962e                	add	a2,a2,a1
ffffffffc02019dc:	fec5f2e3          	bleu	a2,a1,ffffffffc02019c0 <user_mem_check+0x64>
ffffffffc02019e0:	c8000537          	lui	a0,0xc8000
ffffffffc02019e4:	0505                	addi	a0,a0,1
ffffffffc02019e6:	00a63533          	sltu	a0,a2,a0
ffffffffc02019ea:	bfd9                	j	ffffffffc02019c0 <user_mem_check+0x64>
        return 1;
ffffffffc02019ec:	4505                	li	a0,1
ffffffffc02019ee:	bfc9                	j	ffffffffc02019c0 <user_mem_check+0x64>

ffffffffc02019f0 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02019f0:	000ab797          	auipc	a5,0xab
ffffffffc02019f4:	ae078793          	addi	a5,a5,-1312 # ffffffffc02ac4d0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02019f8:	f51c                	sd	a5,40(a0)
ffffffffc02019fa:	e79c                	sd	a5,8(a5)
ffffffffc02019fc:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02019fe:	4501                	li	a0,0
ffffffffc0201a00:	8082                	ret

ffffffffc0201a02 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0201a02:	4501                	li	a0,0
ffffffffc0201a04:	8082                	ret

ffffffffc0201a06 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0201a06:	4501                	li	a0,0
ffffffffc0201a08:	8082                	ret

ffffffffc0201a0a <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0201a0a:	4501                	li	a0,0
ffffffffc0201a0c:	8082                	ret

ffffffffc0201a0e <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0201a0e:	711d                	addi	sp,sp,-96
ffffffffc0201a10:	fc4e                	sd	s3,56(sp)
ffffffffc0201a12:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201a14:	00006517          	auipc	a0,0x6
ffffffffc0201a18:	b9c50513          	addi	a0,a0,-1124 # ffffffffc02075b0 <commands+0xc98>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201a1c:	698d                	lui	s3,0x3
ffffffffc0201a1e:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0201a20:	e8a2                	sd	s0,80(sp)
ffffffffc0201a22:	e4a6                	sd	s1,72(sp)
ffffffffc0201a24:	ec86                	sd	ra,88(sp)
ffffffffc0201a26:	e0ca                	sd	s2,64(sp)
ffffffffc0201a28:	f456                	sd	s5,40(sp)
ffffffffc0201a2a:	f05a                	sd	s6,32(sp)
ffffffffc0201a2c:	ec5e                	sd	s7,24(sp)
ffffffffc0201a2e:	e862                	sd	s8,16(sp)
ffffffffc0201a30:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0201a32:	000ab417          	auipc	s0,0xab
ffffffffc0201a36:	a3e40413          	addi	s0,s0,-1474 # ffffffffc02ac470 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201a3a:	e96fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201a3e:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6578>
    assert(pgfault_num==4);
ffffffffc0201a42:	4004                	lw	s1,0(s0)
ffffffffc0201a44:	4791                	li	a5,4
ffffffffc0201a46:	2481                	sext.w	s1,s1
ffffffffc0201a48:	14f49963          	bne	s1,a5,ffffffffc0201b9a <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201a4c:	00006517          	auipc	a0,0x6
ffffffffc0201a50:	bb450513          	addi	a0,a0,-1100 # ffffffffc0207600 <commands+0xce8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201a54:	6a85                	lui	s5,0x1
ffffffffc0201a56:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201a58:	e78fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201a5c:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
    assert(pgfault_num==4);
ffffffffc0201a60:	00042903          	lw	s2,0(s0)
ffffffffc0201a64:	2901                	sext.w	s2,s2
ffffffffc0201a66:	2a991a63          	bne	s2,s1,ffffffffc0201d1a <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201a6a:	00006517          	auipc	a0,0x6
ffffffffc0201a6e:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0207628 <commands+0xd10>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201a72:	6b91                	lui	s7,0x4
ffffffffc0201a74:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201a76:	e5afe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201a7a:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5578>
    assert(pgfault_num==4);
ffffffffc0201a7e:	4004                	lw	s1,0(s0)
ffffffffc0201a80:	2481                	sext.w	s1,s1
ffffffffc0201a82:	27249c63          	bne	s1,s2,ffffffffc0201cfa <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201a86:	00006517          	auipc	a0,0x6
ffffffffc0201a8a:	bca50513          	addi	a0,a0,-1078 # ffffffffc0207650 <commands+0xd38>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201a8e:	6909                	lui	s2,0x2
ffffffffc0201a90:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201a92:	e3efe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201a96:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7578>
    assert(pgfault_num==4);
ffffffffc0201a9a:	401c                	lw	a5,0(s0)
ffffffffc0201a9c:	2781                	sext.w	a5,a5
ffffffffc0201a9e:	22979e63          	bne	a5,s1,ffffffffc0201cda <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201aa2:	00006517          	auipc	a0,0x6
ffffffffc0201aa6:	bd650513          	addi	a0,a0,-1066 # ffffffffc0207678 <commands+0xd60>
ffffffffc0201aaa:	e26fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201aae:	6795                	lui	a5,0x5
ffffffffc0201ab0:	4739                	li	a4,14
ffffffffc0201ab2:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4578>
    assert(pgfault_num==5);
ffffffffc0201ab6:	4004                	lw	s1,0(s0)
ffffffffc0201ab8:	4795                	li	a5,5
ffffffffc0201aba:	2481                	sext.w	s1,s1
ffffffffc0201abc:	1ef49f63          	bne	s1,a5,ffffffffc0201cba <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201ac0:	00006517          	auipc	a0,0x6
ffffffffc0201ac4:	b9050513          	addi	a0,a0,-1136 # ffffffffc0207650 <commands+0xd38>
ffffffffc0201ac8:	e08fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201acc:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0201ad0:	401c                	lw	a5,0(s0)
ffffffffc0201ad2:	2781                	sext.w	a5,a5
ffffffffc0201ad4:	1c979363          	bne	a5,s1,ffffffffc0201c9a <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201ad8:	00006517          	auipc	a0,0x6
ffffffffc0201adc:	b2850513          	addi	a0,a0,-1240 # ffffffffc0207600 <commands+0xce8>
ffffffffc0201ae0:	df0fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201ae4:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0201ae8:	401c                	lw	a5,0(s0)
ffffffffc0201aea:	4719                	li	a4,6
ffffffffc0201aec:	2781                	sext.w	a5,a5
ffffffffc0201aee:	18e79663          	bne	a5,a4,ffffffffc0201c7a <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201af2:	00006517          	auipc	a0,0x6
ffffffffc0201af6:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0207650 <commands+0xd38>
ffffffffc0201afa:	dd6fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201afe:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0201b02:	401c                	lw	a5,0(s0)
ffffffffc0201b04:	471d                	li	a4,7
ffffffffc0201b06:	2781                	sext.w	a5,a5
ffffffffc0201b08:	14e79963          	bne	a5,a4,ffffffffc0201c5a <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201b0c:	00006517          	auipc	a0,0x6
ffffffffc0201b10:	aa450513          	addi	a0,a0,-1372 # ffffffffc02075b0 <commands+0xc98>
ffffffffc0201b14:	dbcfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201b18:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0201b1c:	401c                	lw	a5,0(s0)
ffffffffc0201b1e:	4721                	li	a4,8
ffffffffc0201b20:	2781                	sext.w	a5,a5
ffffffffc0201b22:	10e79c63          	bne	a5,a4,ffffffffc0201c3a <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201b26:	00006517          	auipc	a0,0x6
ffffffffc0201b2a:	b0250513          	addi	a0,a0,-1278 # ffffffffc0207628 <commands+0xd10>
ffffffffc0201b2e:	da2fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201b32:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0201b36:	401c                	lw	a5,0(s0)
ffffffffc0201b38:	4725                	li	a4,9
ffffffffc0201b3a:	2781                	sext.w	a5,a5
ffffffffc0201b3c:	0ce79f63          	bne	a5,a4,ffffffffc0201c1a <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201b40:	00006517          	auipc	a0,0x6
ffffffffc0201b44:	b3850513          	addi	a0,a0,-1224 # ffffffffc0207678 <commands+0xd60>
ffffffffc0201b48:	d88fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201b4c:	6795                	lui	a5,0x5
ffffffffc0201b4e:	4739                	li	a4,14
ffffffffc0201b50:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4578>
    assert(pgfault_num==10);
ffffffffc0201b54:	4004                	lw	s1,0(s0)
ffffffffc0201b56:	47a9                	li	a5,10
ffffffffc0201b58:	2481                	sext.w	s1,s1
ffffffffc0201b5a:	0af49063          	bne	s1,a5,ffffffffc0201bfa <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201b5e:	00006517          	auipc	a0,0x6
ffffffffc0201b62:	aa250513          	addi	a0,a0,-1374 # ffffffffc0207600 <commands+0xce8>
ffffffffc0201b66:	d6afe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201b6a:	6785                	lui	a5,0x1
ffffffffc0201b6c:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
ffffffffc0201b70:	06979563          	bne	a5,s1,ffffffffc0201bda <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0201b74:	401c                	lw	a5,0(s0)
ffffffffc0201b76:	472d                	li	a4,11
ffffffffc0201b78:	2781                	sext.w	a5,a5
ffffffffc0201b7a:	04e79063          	bne	a5,a4,ffffffffc0201bba <_fifo_check_swap+0x1ac>
}
ffffffffc0201b7e:	60e6                	ld	ra,88(sp)
ffffffffc0201b80:	6446                	ld	s0,80(sp)
ffffffffc0201b82:	64a6                	ld	s1,72(sp)
ffffffffc0201b84:	6906                	ld	s2,64(sp)
ffffffffc0201b86:	79e2                	ld	s3,56(sp)
ffffffffc0201b88:	7a42                	ld	s4,48(sp)
ffffffffc0201b8a:	7aa2                	ld	s5,40(sp)
ffffffffc0201b8c:	7b02                	ld	s6,32(sp)
ffffffffc0201b8e:	6be2                	ld	s7,24(sp)
ffffffffc0201b90:	6c42                	ld	s8,16(sp)
ffffffffc0201b92:	6ca2                	ld	s9,8(sp)
ffffffffc0201b94:	4501                	li	a0,0
ffffffffc0201b96:	6125                	addi	sp,sp,96
ffffffffc0201b98:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0201b9a:	00006697          	auipc	a3,0x6
ffffffffc0201b9e:	a3e68693          	addi	a3,a3,-1474 # ffffffffc02075d8 <commands+0xcc0>
ffffffffc0201ba2:	00005617          	auipc	a2,0x5
ffffffffc0201ba6:	1f660613          	addi	a2,a2,502 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201baa:	05100593          	li	a1,81
ffffffffc0201bae:	00006517          	auipc	a0,0x6
ffffffffc0201bb2:	a3a50513          	addi	a0,a0,-1478 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201bb6:	e60fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==11);
ffffffffc0201bba:	00006697          	auipc	a3,0x6
ffffffffc0201bbe:	b6e68693          	addi	a3,a3,-1170 # ffffffffc0207728 <commands+0xe10>
ffffffffc0201bc2:	00005617          	auipc	a2,0x5
ffffffffc0201bc6:	1d660613          	addi	a2,a2,470 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201bca:	07300593          	li	a1,115
ffffffffc0201bce:	00006517          	auipc	a0,0x6
ffffffffc0201bd2:	a1a50513          	addi	a0,a0,-1510 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201bd6:	e40fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201bda:	00006697          	auipc	a3,0x6
ffffffffc0201bde:	b2668693          	addi	a3,a3,-1242 # ffffffffc0207700 <commands+0xde8>
ffffffffc0201be2:	00005617          	auipc	a2,0x5
ffffffffc0201be6:	1b660613          	addi	a2,a2,438 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201bea:	07100593          	li	a1,113
ffffffffc0201bee:	00006517          	auipc	a0,0x6
ffffffffc0201bf2:	9fa50513          	addi	a0,a0,-1542 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201bf6:	e20fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==10);
ffffffffc0201bfa:	00006697          	auipc	a3,0x6
ffffffffc0201bfe:	af668693          	addi	a3,a3,-1290 # ffffffffc02076f0 <commands+0xdd8>
ffffffffc0201c02:	00005617          	auipc	a2,0x5
ffffffffc0201c06:	19660613          	addi	a2,a2,406 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201c0a:	06f00593          	li	a1,111
ffffffffc0201c0e:	00006517          	auipc	a0,0x6
ffffffffc0201c12:	9da50513          	addi	a0,a0,-1574 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201c16:	e00fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==9);
ffffffffc0201c1a:	00006697          	auipc	a3,0x6
ffffffffc0201c1e:	ac668693          	addi	a3,a3,-1338 # ffffffffc02076e0 <commands+0xdc8>
ffffffffc0201c22:	00005617          	auipc	a2,0x5
ffffffffc0201c26:	17660613          	addi	a2,a2,374 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201c2a:	06c00593          	li	a1,108
ffffffffc0201c2e:	00006517          	auipc	a0,0x6
ffffffffc0201c32:	9ba50513          	addi	a0,a0,-1606 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201c36:	de0fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==8);
ffffffffc0201c3a:	00006697          	auipc	a3,0x6
ffffffffc0201c3e:	a9668693          	addi	a3,a3,-1386 # ffffffffc02076d0 <commands+0xdb8>
ffffffffc0201c42:	00005617          	auipc	a2,0x5
ffffffffc0201c46:	15660613          	addi	a2,a2,342 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201c4a:	06900593          	li	a1,105
ffffffffc0201c4e:	00006517          	auipc	a0,0x6
ffffffffc0201c52:	99a50513          	addi	a0,a0,-1638 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201c56:	dc0fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==7);
ffffffffc0201c5a:	00006697          	auipc	a3,0x6
ffffffffc0201c5e:	a6668693          	addi	a3,a3,-1434 # ffffffffc02076c0 <commands+0xda8>
ffffffffc0201c62:	00005617          	auipc	a2,0x5
ffffffffc0201c66:	13660613          	addi	a2,a2,310 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201c6a:	06600593          	li	a1,102
ffffffffc0201c6e:	00006517          	auipc	a0,0x6
ffffffffc0201c72:	97a50513          	addi	a0,a0,-1670 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201c76:	da0fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==6);
ffffffffc0201c7a:	00006697          	auipc	a3,0x6
ffffffffc0201c7e:	a3668693          	addi	a3,a3,-1482 # ffffffffc02076b0 <commands+0xd98>
ffffffffc0201c82:	00005617          	auipc	a2,0x5
ffffffffc0201c86:	11660613          	addi	a2,a2,278 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201c8a:	06300593          	li	a1,99
ffffffffc0201c8e:	00006517          	auipc	a0,0x6
ffffffffc0201c92:	95a50513          	addi	a0,a0,-1702 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201c96:	d80fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc0201c9a:	00006697          	auipc	a3,0x6
ffffffffc0201c9e:	a0668693          	addi	a3,a3,-1530 # ffffffffc02076a0 <commands+0xd88>
ffffffffc0201ca2:	00005617          	auipc	a2,0x5
ffffffffc0201ca6:	0f660613          	addi	a2,a2,246 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201caa:	06000593          	li	a1,96
ffffffffc0201cae:	00006517          	auipc	a0,0x6
ffffffffc0201cb2:	93a50513          	addi	a0,a0,-1734 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201cb6:	d60fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc0201cba:	00006697          	auipc	a3,0x6
ffffffffc0201cbe:	9e668693          	addi	a3,a3,-1562 # ffffffffc02076a0 <commands+0xd88>
ffffffffc0201cc2:	00005617          	auipc	a2,0x5
ffffffffc0201cc6:	0d660613          	addi	a2,a2,214 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201cca:	05d00593          	li	a1,93
ffffffffc0201cce:	00006517          	auipc	a0,0x6
ffffffffc0201cd2:	91a50513          	addi	a0,a0,-1766 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201cd6:	d40fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0201cda:	00006697          	auipc	a3,0x6
ffffffffc0201cde:	8fe68693          	addi	a3,a3,-1794 # ffffffffc02075d8 <commands+0xcc0>
ffffffffc0201ce2:	00005617          	auipc	a2,0x5
ffffffffc0201ce6:	0b660613          	addi	a2,a2,182 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201cea:	05a00593          	li	a1,90
ffffffffc0201cee:	00006517          	auipc	a0,0x6
ffffffffc0201cf2:	8fa50513          	addi	a0,a0,-1798 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201cf6:	d20fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0201cfa:	00006697          	auipc	a3,0x6
ffffffffc0201cfe:	8de68693          	addi	a3,a3,-1826 # ffffffffc02075d8 <commands+0xcc0>
ffffffffc0201d02:	00005617          	auipc	a2,0x5
ffffffffc0201d06:	09660613          	addi	a2,a2,150 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201d0a:	05700593          	li	a1,87
ffffffffc0201d0e:	00006517          	auipc	a0,0x6
ffffffffc0201d12:	8da50513          	addi	a0,a0,-1830 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201d16:	d00fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0201d1a:	00006697          	auipc	a3,0x6
ffffffffc0201d1e:	8be68693          	addi	a3,a3,-1858 # ffffffffc02075d8 <commands+0xcc0>
ffffffffc0201d22:	00005617          	auipc	a2,0x5
ffffffffc0201d26:	07660613          	addi	a2,a2,118 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201d2a:	05400593          	li	a1,84
ffffffffc0201d2e:	00006517          	auipc	a0,0x6
ffffffffc0201d32:	8ba50513          	addi	a0,a0,-1862 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201d36:	ce0fe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201d3a <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201d3a:	751c                	ld	a5,40(a0)
{
ffffffffc0201d3c:	1141                	addi	sp,sp,-16
ffffffffc0201d3e:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0201d40:	cf91                	beqz	a5,ffffffffc0201d5c <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0201d42:	ee0d                	bnez	a2,ffffffffc0201d7c <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0201d44:	679c                	ld	a5,8(a5)
}
ffffffffc0201d46:	60a2                	ld	ra,8(sp)
ffffffffc0201d48:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0201d4a:	6394                	ld	a3,0(a5)
ffffffffc0201d4c:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201d4e:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0201d52:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201d54:	e314                	sd	a3,0(a4)
ffffffffc0201d56:	e19c                	sd	a5,0(a1)
}
ffffffffc0201d58:	0141                	addi	sp,sp,16
ffffffffc0201d5a:	8082                	ret
         assert(head != NULL);
ffffffffc0201d5c:	00006697          	auipc	a3,0x6
ffffffffc0201d60:	9fc68693          	addi	a3,a3,-1540 # ffffffffc0207758 <commands+0xe40>
ffffffffc0201d64:	00005617          	auipc	a2,0x5
ffffffffc0201d68:	03460613          	addi	a2,a2,52 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201d6c:	04100593          	li	a1,65
ffffffffc0201d70:	00006517          	auipc	a0,0x6
ffffffffc0201d74:	87850513          	addi	a0,a0,-1928 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201d78:	c9efe0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(in_tick==0);
ffffffffc0201d7c:	00006697          	auipc	a3,0x6
ffffffffc0201d80:	9ec68693          	addi	a3,a3,-1556 # ffffffffc0207768 <commands+0xe50>
ffffffffc0201d84:	00005617          	auipc	a2,0x5
ffffffffc0201d88:	01460613          	addi	a2,a2,20 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201d8c:	04200593          	li	a1,66
ffffffffc0201d90:	00006517          	auipc	a0,0x6
ffffffffc0201d94:	85850513          	addi	a0,a0,-1960 # ffffffffc02075e8 <commands+0xcd0>
ffffffffc0201d98:	c7efe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201d9c <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0201d9c:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201da0:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0201da2:	cb09                	beqz	a4,ffffffffc0201db4 <_fifo_map_swappable+0x18>
ffffffffc0201da4:	cb81                	beqz	a5,ffffffffc0201db4 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201da6:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201da8:	e398                	sd	a4,0(a5)
}
ffffffffc0201daa:	4501                	li	a0,0
ffffffffc0201dac:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0201dae:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0201db0:	f614                	sd	a3,40(a2)
ffffffffc0201db2:	8082                	ret
{
ffffffffc0201db4:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0201db6:	00006697          	auipc	a3,0x6
ffffffffc0201dba:	98268693          	addi	a3,a3,-1662 # ffffffffc0207738 <commands+0xe20>
ffffffffc0201dbe:	00005617          	auipc	a2,0x5
ffffffffc0201dc2:	fda60613          	addi	a2,a2,-38 # ffffffffc0206d98 <commands+0x480>
ffffffffc0201dc6:	03200593          	li	a1,50
ffffffffc0201dca:	00006517          	auipc	a0,0x6
ffffffffc0201dce:	81e50513          	addi	a0,a0,-2018 # ffffffffc02075e8 <commands+0xcd0>
{
ffffffffc0201dd2:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0201dd4:	c42fe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201dd8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201dd8:	c125                	beqz	a0,ffffffffc0201e38 <slob_free+0x60>
		return;

	if (size)
ffffffffc0201dda:	e1a5                	bnez	a1,ffffffffc0201e3a <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ddc:	100027f3          	csrr	a5,sstatus
ffffffffc0201de0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201de2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201de4:	e3bd                	bnez	a5,ffffffffc0201e4a <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201de6:	0009f797          	auipc	a5,0x9f
ffffffffc0201dea:	26a78793          	addi	a5,a5,618 # ffffffffc02a1050 <slobfree>
ffffffffc0201dee:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201df0:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201df2:	00a7fa63          	bleu	a0,a5,ffffffffc0201e06 <slob_free+0x2e>
ffffffffc0201df6:	00e56c63          	bltu	a0,a4,ffffffffc0201e0e <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201dfa:	00e7fa63          	bleu	a4,a5,ffffffffc0201e0e <slob_free+0x36>
    return 0;
ffffffffc0201dfe:	87ba                	mv	a5,a4
ffffffffc0201e00:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201e02:	fea7eae3          	bltu	a5,a0,ffffffffc0201df6 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201e06:	fee7ece3          	bltu	a5,a4,ffffffffc0201dfe <slob_free+0x26>
ffffffffc0201e0a:	fee57ae3          	bleu	a4,a0,ffffffffc0201dfe <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201e0e:	4110                	lw	a2,0(a0)
ffffffffc0201e10:	00461693          	slli	a3,a2,0x4
ffffffffc0201e14:	96aa                	add	a3,a3,a0
ffffffffc0201e16:	08d70b63          	beq	a4,a3,ffffffffc0201eac <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201e1a:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0201e1c:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201e1e:	00469713          	slli	a4,a3,0x4
ffffffffc0201e22:	973e                	add	a4,a4,a5
ffffffffc0201e24:	08e50f63          	beq	a0,a4,ffffffffc0201ec2 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201e28:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0201e2a:	0009f717          	auipc	a4,0x9f
ffffffffc0201e2e:	22f73323          	sd	a5,550(a4) # ffffffffc02a1050 <slobfree>
    if (flag) {
ffffffffc0201e32:	c199                	beqz	a1,ffffffffc0201e38 <slob_free+0x60>
        intr_enable();
ffffffffc0201e34:	823fe06f          	j	ffffffffc0200656 <intr_enable>
ffffffffc0201e38:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201e3a:	05bd                	addi	a1,a1,15
ffffffffc0201e3c:	8191                	srli	a1,a1,0x4
ffffffffc0201e3e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e40:	100027f3          	csrr	a5,sstatus
ffffffffc0201e44:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201e46:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e48:	dfd9                	beqz	a5,ffffffffc0201de6 <slob_free+0xe>
{
ffffffffc0201e4a:	1101                	addi	sp,sp,-32
ffffffffc0201e4c:	e42a                	sd	a0,8(sp)
ffffffffc0201e4e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201e50:	80dfe0ef          	jal	ra,ffffffffc020065c <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201e54:	0009f797          	auipc	a5,0x9f
ffffffffc0201e58:	1fc78793          	addi	a5,a5,508 # ffffffffc02a1050 <slobfree>
ffffffffc0201e5c:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201e5e:	6522                	ld	a0,8(sp)
ffffffffc0201e60:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201e62:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201e64:	00a7fa63          	bleu	a0,a5,ffffffffc0201e78 <slob_free+0xa0>
ffffffffc0201e68:	00e56c63          	bltu	a0,a4,ffffffffc0201e80 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201e6c:	00e7fa63          	bleu	a4,a5,ffffffffc0201e80 <slob_free+0xa8>
    return 0;
ffffffffc0201e70:	87ba                	mv	a5,a4
ffffffffc0201e72:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201e74:	fea7eae3          	bltu	a5,a0,ffffffffc0201e68 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201e78:	fee7ece3          	bltu	a5,a4,ffffffffc0201e70 <slob_free+0x98>
ffffffffc0201e7c:	fee57ae3          	bleu	a4,a0,ffffffffc0201e70 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201e80:	4110                	lw	a2,0(a0)
ffffffffc0201e82:	00461693          	slli	a3,a2,0x4
ffffffffc0201e86:	96aa                	add	a3,a3,a0
ffffffffc0201e88:	04d70763          	beq	a4,a3,ffffffffc0201ed6 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201e8c:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201e8e:	4394                	lw	a3,0(a5)
ffffffffc0201e90:	00469713          	slli	a4,a3,0x4
ffffffffc0201e94:	973e                	add	a4,a4,a5
ffffffffc0201e96:	04e50663          	beq	a0,a4,ffffffffc0201ee2 <slob_free+0x10a>
		cur->next = b;
ffffffffc0201e9a:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201e9c:	0009f717          	auipc	a4,0x9f
ffffffffc0201ea0:	1af73a23          	sd	a5,436(a4) # ffffffffc02a1050 <slobfree>
    if (flag) {
ffffffffc0201ea4:	e58d                	bnez	a1,ffffffffc0201ece <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201ea6:	60e2                	ld	ra,24(sp)
ffffffffc0201ea8:	6105                	addi	sp,sp,32
ffffffffc0201eaa:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201eac:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201eae:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201eb0:	9e35                	addw	a2,a2,a3
ffffffffc0201eb2:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201eb4:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201eb6:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201eb8:	00469713          	slli	a4,a3,0x4
ffffffffc0201ebc:	973e                	add	a4,a4,a5
ffffffffc0201ebe:	f6e515e3          	bne	a0,a4,ffffffffc0201e28 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201ec2:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201ec4:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201ec6:	9eb9                	addw	a3,a3,a4
ffffffffc0201ec8:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201eca:	e790                	sd	a2,8(a5)
ffffffffc0201ecc:	bfb9                	j	ffffffffc0201e2a <slob_free+0x52>
}
ffffffffc0201ece:	60e2                	ld	ra,24(sp)
ffffffffc0201ed0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201ed2:	f84fe06f          	j	ffffffffc0200656 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201ed6:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201ed8:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201eda:	9e35                	addw	a2,a2,a3
ffffffffc0201edc:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201ede:	e518                	sd	a4,8(a0)
ffffffffc0201ee0:	b77d                	j	ffffffffc0201e8e <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201ee2:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201ee4:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201ee6:	9eb9                	addw	a3,a3,a4
ffffffffc0201ee8:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201eea:	e790                	sd	a2,8(a5)
ffffffffc0201eec:	bf45                	j	ffffffffc0201e9c <slob_free+0xc4>

ffffffffc0201eee <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201eee:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ef0:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ef2:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ef6:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ef8:	00b010ef          	jal	ra,ffffffffc0203702 <alloc_pages>
  if(!page)
ffffffffc0201efc:	c139                	beqz	a0,ffffffffc0201f42 <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201efe:	000aa797          	auipc	a5,0xaa
ffffffffc0201f02:	6da78793          	addi	a5,a5,1754 # ffffffffc02ac5d8 <pages>
ffffffffc0201f06:	6394                	ld	a3,0(a5)
ffffffffc0201f08:	00007797          	auipc	a5,0x7
ffffffffc0201f0c:	fc878793          	addi	a5,a5,-56 # ffffffffc0208ed0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201f10:	000aa717          	auipc	a4,0xaa
ffffffffc0201f14:	58870713          	addi	a4,a4,1416 # ffffffffc02ac498 <npage>
    return page - pages + nbase;
ffffffffc0201f18:	40d506b3          	sub	a3,a0,a3
ffffffffc0201f1c:	6388                	ld	a0,0(a5)
ffffffffc0201f1e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201f20:	57fd                	li	a5,-1
ffffffffc0201f22:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201f24:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201f26:	83b1                	srli	a5,a5,0xc
ffffffffc0201f28:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f2a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201f2c:	00e7ff63          	bleu	a4,a5,ffffffffc0201f4a <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201f30:	000aa797          	auipc	a5,0xaa
ffffffffc0201f34:	69878793          	addi	a5,a5,1688 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0201f38:	6388                	ld	a0,0(a5)
}
ffffffffc0201f3a:	60a2                	ld	ra,8(sp)
ffffffffc0201f3c:	9536                	add	a0,a0,a3
ffffffffc0201f3e:	0141                	addi	sp,sp,16
ffffffffc0201f40:	8082                	ret
ffffffffc0201f42:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201f44:	4501                	li	a0,0
}
ffffffffc0201f46:	0141                	addi	sp,sp,16
ffffffffc0201f48:	8082                	ret
ffffffffc0201f4a:	00005617          	auipc	a2,0x5
ffffffffc0201f4e:	5ce60613          	addi	a2,a2,1486 # ffffffffc0207518 <commands+0xc00>
ffffffffc0201f52:	06900593          	li	a1,105
ffffffffc0201f56:	00005517          	auipc	a0,0x5
ffffffffc0201f5a:	5b250513          	addi	a0,a0,1458 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0201f5e:	ab8fe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201f62 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201f62:	7179                	addi	sp,sp,-48
ffffffffc0201f64:	f406                	sd	ra,40(sp)
ffffffffc0201f66:	f022                	sd	s0,32(sp)
ffffffffc0201f68:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201f6a:	01050713          	addi	a4,a0,16
ffffffffc0201f6e:	6785                	lui	a5,0x1
ffffffffc0201f70:	0cf77b63          	bleu	a5,a4,ffffffffc0202046 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201f74:	00f50413          	addi	s0,a0,15
ffffffffc0201f78:	8011                	srli	s0,s0,0x4
ffffffffc0201f7a:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f7c:	10002673          	csrr	a2,sstatus
ffffffffc0201f80:	8a09                	andi	a2,a2,2
ffffffffc0201f82:	ea5d                	bnez	a2,ffffffffc0202038 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201f84:	0009f497          	auipc	s1,0x9f
ffffffffc0201f88:	0cc48493          	addi	s1,s1,204 # ffffffffc02a1050 <slobfree>
ffffffffc0201f8c:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201f8e:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201f90:	4398                	lw	a4,0(a5)
ffffffffc0201f92:	0a875763          	ble	s0,a4,ffffffffc0202040 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201f96:	00f68a63          	beq	a3,a5,ffffffffc0201faa <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201f9a:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201f9c:	4118                	lw	a4,0(a0)
ffffffffc0201f9e:	02875763          	ble	s0,a4,ffffffffc0201fcc <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201fa2:	6094                	ld	a3,0(s1)
ffffffffc0201fa4:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201fa6:	fef69ae3          	bne	a3,a5,ffffffffc0201f9a <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201faa:	ea39                	bnez	a2,ffffffffc0202000 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201fac:	4501                	li	a0,0
ffffffffc0201fae:	f41ff0ef          	jal	ra,ffffffffc0201eee <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201fb2:	cd29                	beqz	a0,ffffffffc020200c <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201fb4:	6585                	lui	a1,0x1
ffffffffc0201fb6:	e23ff0ef          	jal	ra,ffffffffc0201dd8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201fba:	10002673          	csrr	a2,sstatus
ffffffffc0201fbe:	8a09                	andi	a2,a2,2
ffffffffc0201fc0:	ea1d                	bnez	a2,ffffffffc0201ff6 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201fc2:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201fc4:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201fc6:	4118                	lw	a4,0(a0)
ffffffffc0201fc8:	fc874de3          	blt	a4,s0,ffffffffc0201fa2 <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201fcc:	04e40663          	beq	s0,a4,ffffffffc0202018 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201fd0:	00441693          	slli	a3,s0,0x4
ffffffffc0201fd4:	96aa                	add	a3,a3,a0
ffffffffc0201fd6:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201fd8:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201fda:	9f01                	subw	a4,a4,s0
ffffffffc0201fdc:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201fde:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201fe0:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201fe2:	0009f717          	auipc	a4,0x9f
ffffffffc0201fe6:	06f73723          	sd	a5,110(a4) # ffffffffc02a1050 <slobfree>
    if (flag) {
ffffffffc0201fea:	ee15                	bnez	a2,ffffffffc0202026 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201fec:	70a2                	ld	ra,40(sp)
ffffffffc0201fee:	7402                	ld	s0,32(sp)
ffffffffc0201ff0:	64e2                	ld	s1,24(sp)
ffffffffc0201ff2:	6145                	addi	sp,sp,48
ffffffffc0201ff4:	8082                	ret
        intr_disable();
ffffffffc0201ff6:	e66fe0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0201ffa:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201ffc:	609c                	ld	a5,0(s1)
ffffffffc0201ffe:	b7d9                	j	ffffffffc0201fc4 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0202000:	e56fe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202004:	4501                	li	a0,0
ffffffffc0202006:	ee9ff0ef          	jal	ra,ffffffffc0201eee <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc020200a:	f54d                	bnez	a0,ffffffffc0201fb4 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc020200c:	70a2                	ld	ra,40(sp)
ffffffffc020200e:	7402                	ld	s0,32(sp)
ffffffffc0202010:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0202012:	4501                	li	a0,0
}
ffffffffc0202014:	6145                	addi	sp,sp,48
ffffffffc0202016:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0202018:	6518                	ld	a4,8(a0)
ffffffffc020201a:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc020201c:	0009f717          	auipc	a4,0x9f
ffffffffc0202020:	02f73a23          	sd	a5,52(a4) # ffffffffc02a1050 <slobfree>
    if (flag) {
ffffffffc0202024:	d661                	beqz	a2,ffffffffc0201fec <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0202026:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202028:	e2efe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
}
ffffffffc020202c:	70a2                	ld	ra,40(sp)
ffffffffc020202e:	7402                	ld	s0,32(sp)
ffffffffc0202030:	6522                	ld	a0,8(sp)
ffffffffc0202032:	64e2                	ld	s1,24(sp)
ffffffffc0202034:	6145                	addi	sp,sp,48
ffffffffc0202036:	8082                	ret
        intr_disable();
ffffffffc0202038:	e24fe0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc020203c:	4605                	li	a2,1
ffffffffc020203e:	b799                	j	ffffffffc0201f84 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202040:	853e                	mv	a0,a5
ffffffffc0202042:	87b6                	mv	a5,a3
ffffffffc0202044:	b761                	j	ffffffffc0201fcc <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202046:	00005697          	auipc	a3,0x5
ffffffffc020204a:	79268693          	addi	a3,a3,1938 # ffffffffc02077d8 <commands+0xec0>
ffffffffc020204e:	00005617          	auipc	a2,0x5
ffffffffc0202052:	d4a60613          	addi	a2,a2,-694 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202056:	06400593          	li	a1,100
ffffffffc020205a:	00005517          	auipc	a0,0x5
ffffffffc020205e:	79e50513          	addi	a0,a0,1950 # ffffffffc02077f8 <commands+0xee0>
ffffffffc0202062:	9b4fe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202066 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0202066:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0202068:	00005517          	auipc	a0,0x5
ffffffffc020206c:	7a850513          	addi	a0,a0,1960 # ffffffffc0207810 <commands+0xef8>
kmalloc_init(void) {
ffffffffc0202070:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0202072:	85efe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0202076:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202078:	00005517          	auipc	a0,0x5
ffffffffc020207c:	74050513          	addi	a0,a0,1856 # ffffffffc02077b8 <commands+0xea0>
}
ffffffffc0202080:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202082:	84efe06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0202086 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0202086:	4501                	li	a0,0
ffffffffc0202088:	8082                	ret

ffffffffc020208a <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc020208a:	1101                	addi	sp,sp,-32
ffffffffc020208c:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020208e:	6905                	lui	s2,0x1
{
ffffffffc0202090:	e822                	sd	s0,16(sp)
ffffffffc0202092:	ec06                	sd	ra,24(sp)
ffffffffc0202094:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202096:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8589>
{
ffffffffc020209a:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020209c:	04a7fc63          	bleu	a0,a5,ffffffffc02020f4 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02020a0:	4561                	li	a0,24
ffffffffc02020a2:	ec1ff0ef          	jal	ra,ffffffffc0201f62 <slob_alloc.isra.1.constprop.3>
ffffffffc02020a6:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02020a8:	cd21                	beqz	a0,ffffffffc0202100 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc02020aa:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02020ae:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02020b0:	00f95763          	ble	a5,s2,ffffffffc02020be <kmalloc+0x34>
ffffffffc02020b4:	6705                	lui	a4,0x1
ffffffffc02020b6:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02020b8:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02020ba:	fef74ee3          	blt	a4,a5,ffffffffc02020b6 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02020be:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02020c0:	e2fff0ef          	jal	ra,ffffffffc0201eee <__slob_get_free_pages.isra.0>
ffffffffc02020c4:	e488                	sd	a0,8(s1)
ffffffffc02020c6:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02020c8:	c935                	beqz	a0,ffffffffc020213c <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020ca:	100027f3          	csrr	a5,sstatus
ffffffffc02020ce:	8b89                	andi	a5,a5,2
ffffffffc02020d0:	e3a1                	bnez	a5,ffffffffc0202110 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc02020d2:	000aa797          	auipc	a5,0xaa
ffffffffc02020d6:	3a678793          	addi	a5,a5,934 # ffffffffc02ac478 <bigblocks>
ffffffffc02020da:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc02020dc:	000aa717          	auipc	a4,0xaa
ffffffffc02020e0:	38973e23          	sd	s1,924(a4) # ffffffffc02ac478 <bigblocks>
		bb->next = bigblocks;
ffffffffc02020e4:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc02020e6:	8522                	mv	a0,s0
ffffffffc02020e8:	60e2                	ld	ra,24(sp)
ffffffffc02020ea:	6442                	ld	s0,16(sp)
ffffffffc02020ec:	64a2                	ld	s1,8(sp)
ffffffffc02020ee:	6902                	ld	s2,0(sp)
ffffffffc02020f0:	6105                	addi	sp,sp,32
ffffffffc02020f2:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc02020f4:	0541                	addi	a0,a0,16
ffffffffc02020f6:	e6dff0ef          	jal	ra,ffffffffc0201f62 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc02020fa:	01050413          	addi	s0,a0,16
ffffffffc02020fe:	f565                	bnez	a0,ffffffffc02020e6 <kmalloc+0x5c>
ffffffffc0202100:	4401                	li	s0,0
}
ffffffffc0202102:	8522                	mv	a0,s0
ffffffffc0202104:	60e2                	ld	ra,24(sp)
ffffffffc0202106:	6442                	ld	s0,16(sp)
ffffffffc0202108:	64a2                	ld	s1,8(sp)
ffffffffc020210a:	6902                	ld	s2,0(sp)
ffffffffc020210c:	6105                	addi	sp,sp,32
ffffffffc020210e:	8082                	ret
        intr_disable();
ffffffffc0202110:	d4cfe0ef          	jal	ra,ffffffffc020065c <intr_disable>
		bb->next = bigblocks;
ffffffffc0202114:	000aa797          	auipc	a5,0xaa
ffffffffc0202118:	36478793          	addi	a5,a5,868 # ffffffffc02ac478 <bigblocks>
ffffffffc020211c:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc020211e:	000aa717          	auipc	a4,0xaa
ffffffffc0202122:	34973d23          	sd	s1,858(a4) # ffffffffc02ac478 <bigblocks>
		bb->next = bigblocks;
ffffffffc0202126:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0202128:	d2efe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc020212c:	6480                	ld	s0,8(s1)
}
ffffffffc020212e:	60e2                	ld	ra,24(sp)
ffffffffc0202130:	64a2                	ld	s1,8(sp)
ffffffffc0202132:	8522                	mv	a0,s0
ffffffffc0202134:	6442                	ld	s0,16(sp)
ffffffffc0202136:	6902                	ld	s2,0(sp)
ffffffffc0202138:	6105                	addi	sp,sp,32
ffffffffc020213a:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc020213c:	45e1                	li	a1,24
ffffffffc020213e:	8526                	mv	a0,s1
ffffffffc0202140:	c99ff0ef          	jal	ra,ffffffffc0201dd8 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0202144:	b74d                	j	ffffffffc02020e6 <kmalloc+0x5c>

ffffffffc0202146 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0202146:	c175                	beqz	a0,ffffffffc020222a <kfree+0xe4>
{
ffffffffc0202148:	1101                	addi	sp,sp,-32
ffffffffc020214a:	e426                	sd	s1,8(sp)
ffffffffc020214c:	ec06                	sd	ra,24(sp)
ffffffffc020214e:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0202150:	03451793          	slli	a5,a0,0x34
ffffffffc0202154:	84aa                	mv	s1,a0
ffffffffc0202156:	eb8d                	bnez	a5,ffffffffc0202188 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202158:	100027f3          	csrr	a5,sstatus
ffffffffc020215c:	8b89                	andi	a5,a5,2
ffffffffc020215e:	efc9                	bnez	a5,ffffffffc02021f8 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202160:	000aa797          	auipc	a5,0xaa
ffffffffc0202164:	31878793          	addi	a5,a5,792 # ffffffffc02ac478 <bigblocks>
ffffffffc0202168:	6394                	ld	a3,0(a5)
ffffffffc020216a:	ce99                	beqz	a3,ffffffffc0202188 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc020216c:	669c                	ld	a5,8(a3)
ffffffffc020216e:	6a80                	ld	s0,16(a3)
ffffffffc0202170:	0af50e63          	beq	a0,a5,ffffffffc020222c <kfree+0xe6>
    return 0;
ffffffffc0202174:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202176:	c801                	beqz	s0,ffffffffc0202186 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0202178:	6418                	ld	a4,8(s0)
ffffffffc020217a:	681c                	ld	a5,16(s0)
ffffffffc020217c:	00970f63          	beq	a4,s1,ffffffffc020219a <kfree+0x54>
ffffffffc0202180:	86a2                	mv	a3,s0
ffffffffc0202182:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202184:	f875                	bnez	s0,ffffffffc0202178 <kfree+0x32>
    if (flag) {
ffffffffc0202186:	e659                	bnez	a2,ffffffffc0202214 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0202188:	6442                	ld	s0,16(sp)
ffffffffc020218a:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020218c:	ff048513          	addi	a0,s1,-16
}
ffffffffc0202190:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202192:	4581                	li	a1,0
}
ffffffffc0202194:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202196:	c43ff06f          	j	ffffffffc0201dd8 <slob_free>
				*last = bb->next;
ffffffffc020219a:	ea9c                	sd	a5,16(a3)
ffffffffc020219c:	e641                	bnez	a2,ffffffffc0202224 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc020219e:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02021a2:	4018                	lw	a4,0(s0)
ffffffffc02021a4:	08f4ea63          	bltu	s1,a5,ffffffffc0202238 <kfree+0xf2>
ffffffffc02021a8:	000aa797          	auipc	a5,0xaa
ffffffffc02021ac:	42078793          	addi	a5,a5,1056 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc02021b0:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02021b2:	000aa797          	auipc	a5,0xaa
ffffffffc02021b6:	2e678793          	addi	a5,a5,742 # ffffffffc02ac498 <npage>
ffffffffc02021ba:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02021bc:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc02021be:	80b1                	srli	s1,s1,0xc
ffffffffc02021c0:	08f4f963          	bleu	a5,s1,ffffffffc0202252 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc02021c4:	00007797          	auipc	a5,0x7
ffffffffc02021c8:	d0c78793          	addi	a5,a5,-756 # ffffffffc0208ed0 <nbase>
ffffffffc02021cc:	639c                	ld	a5,0(a5)
ffffffffc02021ce:	000aa697          	auipc	a3,0xaa
ffffffffc02021d2:	40a68693          	addi	a3,a3,1034 # ffffffffc02ac5d8 <pages>
ffffffffc02021d6:	6288                	ld	a0,0(a3)
ffffffffc02021d8:	8c9d                	sub	s1,s1,a5
ffffffffc02021da:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc02021dc:	4585                	li	a1,1
ffffffffc02021de:	9526                	add	a0,a0,s1
ffffffffc02021e0:	00e595bb          	sllw	a1,a1,a4
ffffffffc02021e4:	5a6010ef          	jal	ra,ffffffffc020378a <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02021e8:	8522                	mv	a0,s0
}
ffffffffc02021ea:	6442                	ld	s0,16(sp)
ffffffffc02021ec:	60e2                	ld	ra,24(sp)
ffffffffc02021ee:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02021f0:	45e1                	li	a1,24
}
ffffffffc02021f2:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02021f4:	be5ff06f          	j	ffffffffc0201dd8 <slob_free>
        intr_disable();
ffffffffc02021f8:	c64fe0ef          	jal	ra,ffffffffc020065c <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02021fc:	000aa797          	auipc	a5,0xaa
ffffffffc0202200:	27c78793          	addi	a5,a5,636 # ffffffffc02ac478 <bigblocks>
ffffffffc0202204:	6394                	ld	a3,0(a5)
ffffffffc0202206:	c699                	beqz	a3,ffffffffc0202214 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0202208:	669c                	ld	a5,8(a3)
ffffffffc020220a:	6a80                	ld	s0,16(a3)
ffffffffc020220c:	00f48763          	beq	s1,a5,ffffffffc020221a <kfree+0xd4>
        return 1;
ffffffffc0202210:	4605                	li	a2,1
ffffffffc0202212:	b795                	j	ffffffffc0202176 <kfree+0x30>
        intr_enable();
ffffffffc0202214:	c42fe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0202218:	bf85                	j	ffffffffc0202188 <kfree+0x42>
				*last = bb->next;
ffffffffc020221a:	000aa797          	auipc	a5,0xaa
ffffffffc020221e:	2487bf23          	sd	s0,606(a5) # ffffffffc02ac478 <bigblocks>
ffffffffc0202222:	8436                	mv	s0,a3
ffffffffc0202224:	c32fe0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0202228:	bf9d                	j	ffffffffc020219e <kfree+0x58>
ffffffffc020222a:	8082                	ret
ffffffffc020222c:	000aa797          	auipc	a5,0xaa
ffffffffc0202230:	2487b623          	sd	s0,588(a5) # ffffffffc02ac478 <bigblocks>
ffffffffc0202234:	8436                	mv	s0,a3
ffffffffc0202236:	b7a5                	j	ffffffffc020219e <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0202238:	86a6                	mv	a3,s1
ffffffffc020223a:	00005617          	auipc	a2,0x5
ffffffffc020223e:	55660613          	addi	a2,a2,1366 # ffffffffc0207790 <commands+0xe78>
ffffffffc0202242:	06e00593          	li	a1,110
ffffffffc0202246:	00005517          	auipc	a0,0x5
ffffffffc020224a:	2c250513          	addi	a0,a0,706 # ffffffffc0207508 <commands+0xbf0>
ffffffffc020224e:	fc9fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202252:	00005617          	auipc	a2,0x5
ffffffffc0202256:	29660613          	addi	a2,a2,662 # ffffffffc02074e8 <commands+0xbd0>
ffffffffc020225a:	06200593          	li	a1,98
ffffffffc020225e:	00005517          	auipc	a0,0x5
ffffffffc0202262:	2aa50513          	addi	a0,a0,682 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0202266:	fb1fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020226a <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020226a:	7135                	addi	sp,sp,-160
ffffffffc020226c:	ed06                	sd	ra,152(sp)
ffffffffc020226e:	e922                	sd	s0,144(sp)
ffffffffc0202270:	e526                	sd	s1,136(sp)
ffffffffc0202272:	e14a                	sd	s2,128(sp)
ffffffffc0202274:	fcce                	sd	s3,120(sp)
ffffffffc0202276:	f8d2                	sd	s4,112(sp)
ffffffffc0202278:	f4d6                	sd	s5,104(sp)
ffffffffc020227a:	f0da                	sd	s6,96(sp)
ffffffffc020227c:	ecde                	sd	s7,88(sp)
ffffffffc020227e:	e8e2                	sd	s8,80(sp)
ffffffffc0202280:	e4e6                	sd	s9,72(sp)
ffffffffc0202282:	e0ea                	sd	s10,64(sp)
ffffffffc0202284:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202286:	233020ef          	jal	ra,ffffffffc0204cb8 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020228a:	000aa797          	auipc	a5,0xaa
ffffffffc020228e:	2de78793          	addi	a5,a5,734 # ffffffffc02ac568 <max_swap_offset>
ffffffffc0202292:	6394                	ld	a3,0(a5)
ffffffffc0202294:	010007b7          	lui	a5,0x1000
ffffffffc0202298:	17e1                	addi	a5,a5,-8
ffffffffc020229a:	ff968713          	addi	a4,a3,-7
ffffffffc020229e:	4ae7ee63          	bltu	a5,a4,ffffffffc020275a <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02022a2:	0009f797          	auipc	a5,0x9f
ffffffffc02022a6:	d5e78793          	addi	a5,a5,-674 # ffffffffc02a1000 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02022aa:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02022ac:	000aa697          	auipc	a3,0xaa
ffffffffc02022b0:	1cf6ba23          	sd	a5,468(a3) # ffffffffc02ac480 <sm>
     int r = sm->init();
ffffffffc02022b4:	9702                	jalr	a4
ffffffffc02022b6:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02022b8:	c10d                	beqz	a0,ffffffffc02022da <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02022ba:	60ea                	ld	ra,152(sp)
ffffffffc02022bc:	644a                	ld	s0,144(sp)
ffffffffc02022be:	8556                	mv	a0,s5
ffffffffc02022c0:	64aa                	ld	s1,136(sp)
ffffffffc02022c2:	690a                	ld	s2,128(sp)
ffffffffc02022c4:	79e6                	ld	s3,120(sp)
ffffffffc02022c6:	7a46                	ld	s4,112(sp)
ffffffffc02022c8:	7aa6                	ld	s5,104(sp)
ffffffffc02022ca:	7b06                	ld	s6,96(sp)
ffffffffc02022cc:	6be6                	ld	s7,88(sp)
ffffffffc02022ce:	6c46                	ld	s8,80(sp)
ffffffffc02022d0:	6ca6                	ld	s9,72(sp)
ffffffffc02022d2:	6d06                	ld	s10,64(sp)
ffffffffc02022d4:	7de2                	ld	s11,56(sp)
ffffffffc02022d6:	610d                	addi	sp,sp,160
ffffffffc02022d8:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02022da:	000aa797          	auipc	a5,0xaa
ffffffffc02022de:	1a678793          	addi	a5,a5,422 # ffffffffc02ac480 <sm>
ffffffffc02022e2:	639c                	ld	a5,0(a5)
ffffffffc02022e4:	00005517          	auipc	a0,0x5
ffffffffc02022e8:	5c450513          	addi	a0,a0,1476 # ffffffffc02078a8 <commands+0xf90>
    return listelm->next;
ffffffffc02022ec:	000aa417          	auipc	s0,0xaa
ffffffffc02022f0:	2bc40413          	addi	s0,s0,700 # ffffffffc02ac5a8 <free_area>
ffffffffc02022f4:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02022f6:	4785                	li	a5,1
ffffffffc02022f8:	000aa717          	auipc	a4,0xaa
ffffffffc02022fc:	18f72823          	sw	a5,400(a4) # ffffffffc02ac488 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202300:	dd1fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202304:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202306:	36878e63          	beq	a5,s0,ffffffffc0202682 <swap_init+0x418>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020230a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020230e:	8305                	srli	a4,a4,0x1
ffffffffc0202310:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202312:	36070c63          	beqz	a4,ffffffffc020268a <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0202316:	4481                	li	s1,0
ffffffffc0202318:	4901                	li	s2,0
ffffffffc020231a:	a031                	j	ffffffffc0202326 <swap_init+0xbc>
ffffffffc020231c:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202320:	8b09                	andi	a4,a4,2
ffffffffc0202322:	36070463          	beqz	a4,ffffffffc020268a <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0202326:	ff87a703          	lw	a4,-8(a5)
ffffffffc020232a:	679c                	ld	a5,8(a5)
ffffffffc020232c:	2905                	addiw	s2,s2,1
ffffffffc020232e:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202330:	fe8796e3          	bne	a5,s0,ffffffffc020231c <swap_init+0xb2>
ffffffffc0202334:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202336:	49a010ef          	jal	ra,ffffffffc02037d0 <nr_free_pages>
ffffffffc020233a:	69351863          	bne	a0,s3,ffffffffc02029ca <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020233e:	8626                	mv	a2,s1
ffffffffc0202340:	85ca                	mv	a1,s2
ffffffffc0202342:	00005517          	auipc	a0,0x5
ffffffffc0202346:	5ae50513          	addi	a0,a0,1454 # ffffffffc02078f0 <commands+0xfd8>
ffffffffc020234a:	d87fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020234e:	b2dfe0ef          	jal	ra,ffffffffc0200e7a <mm_create>
ffffffffc0202352:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202354:	60050b63          	beqz	a0,ffffffffc020296a <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202358:	000aa797          	auipc	a5,0xaa
ffffffffc020235c:	17078793          	addi	a5,a5,368 # ffffffffc02ac4c8 <check_mm_struct>
ffffffffc0202360:	639c                	ld	a5,0(a5)
ffffffffc0202362:	62079463          	bnez	a5,ffffffffc020298a <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202366:	000aa797          	auipc	a5,0xaa
ffffffffc020236a:	12a78793          	addi	a5,a5,298 # ffffffffc02ac490 <boot_pgdir>
ffffffffc020236e:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202372:	000aa797          	auipc	a5,0xaa
ffffffffc0202376:	14a7bb23          	sd	a0,342(a5) # ffffffffc02ac4c8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020237a:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020237e:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202382:	4e079863          	bnez	a5,ffffffffc0202872 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202386:	6599                	lui	a1,0x6
ffffffffc0202388:	460d                	li	a2,3
ffffffffc020238a:	6505                	lui	a0,0x1
ffffffffc020238c:	b3bfe0ef          	jal	ra,ffffffffc0200ec6 <vma_create>
ffffffffc0202390:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202392:	50050063          	beqz	a0,ffffffffc0202892 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc0202396:	855e                	mv	a0,s7
ffffffffc0202398:	b9bfe0ef          	jal	ra,ffffffffc0200f32 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020239c:	00005517          	auipc	a0,0x5
ffffffffc02023a0:	59450513          	addi	a0,a0,1428 # ffffffffc0207930 <commands+0x1018>
ffffffffc02023a4:	d2dfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02023a8:	018bb503          	ld	a0,24(s7)
ffffffffc02023ac:	4605                	li	a2,1
ffffffffc02023ae:	6585                	lui	a1,0x1
ffffffffc02023b0:	460010ef          	jal	ra,ffffffffc0203810 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02023b4:	4e050f63          	beqz	a0,ffffffffc02028b2 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02023b8:	00005517          	auipc	a0,0x5
ffffffffc02023bc:	5c850513          	addi	a0,a0,1480 # ffffffffc0207980 <commands+0x1068>
ffffffffc02023c0:	000aa997          	auipc	s3,0xaa
ffffffffc02023c4:	12098993          	addi	s3,s3,288 # ffffffffc02ac4e0 <check_rp>
ffffffffc02023c8:	d09fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02023cc:	000aaa17          	auipc	s4,0xaa
ffffffffc02023d0:	134a0a13          	addi	s4,s4,308 # ffffffffc02ac500 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02023d4:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02023d6:	4505                	li	a0,1
ffffffffc02023d8:	32a010ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc02023dc:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02023e0:	32050d63          	beqz	a0,ffffffffc020271a <swap_init+0x4b0>
ffffffffc02023e4:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02023e6:	8b89                	andi	a5,a5,2
ffffffffc02023e8:	30079963          	bnez	a5,ffffffffc02026fa <swap_init+0x490>
ffffffffc02023ec:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02023ee:	ff4c14e3          	bne	s8,s4,ffffffffc02023d6 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02023f2:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02023f4:	000aac17          	auipc	s8,0xaa
ffffffffc02023f8:	0ecc0c13          	addi	s8,s8,236 # ffffffffc02ac4e0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02023fc:	ec3e                	sd	a5,24(sp)
ffffffffc02023fe:	641c                	ld	a5,8(s0)
ffffffffc0202400:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202402:	481c                	lw	a5,16(s0)
ffffffffc0202404:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202406:	000aa797          	auipc	a5,0xaa
ffffffffc020240a:	1a87b523          	sd	s0,426(a5) # ffffffffc02ac5b0 <free_area+0x8>
ffffffffc020240e:	000aa797          	auipc	a5,0xaa
ffffffffc0202412:	1887bd23          	sd	s0,410(a5) # ffffffffc02ac5a8 <free_area>
     nr_free = 0;
ffffffffc0202416:	000aa797          	auipc	a5,0xaa
ffffffffc020241a:	1a07a123          	sw	zero,418(a5) # ffffffffc02ac5b8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020241e:	000c3503          	ld	a0,0(s8)
ffffffffc0202422:	4585                	li	a1,1
ffffffffc0202424:	0c21                	addi	s8,s8,8
ffffffffc0202426:	364010ef          	jal	ra,ffffffffc020378a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020242a:	ff4c1ae3          	bne	s8,s4,ffffffffc020241e <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020242e:	01042c03          	lw	s8,16(s0)
ffffffffc0202432:	4791                	li	a5,4
ffffffffc0202434:	50fc1b63          	bne	s8,a5,ffffffffc020294a <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202438:	00005517          	auipc	a0,0x5
ffffffffc020243c:	5d050513          	addi	a0,a0,1488 # ffffffffc0207a08 <commands+0x10f0>
ffffffffc0202440:	c91fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202444:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202446:	000aa797          	auipc	a5,0xaa
ffffffffc020244a:	0207a523          	sw	zero,42(a5) # ffffffffc02ac470 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020244e:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202450:	000aa797          	auipc	a5,0xaa
ffffffffc0202454:	02078793          	addi	a5,a5,32 # ffffffffc02ac470 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202458:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
     assert(pgfault_num==1);
ffffffffc020245c:	4398                	lw	a4,0(a5)
ffffffffc020245e:	4585                	li	a1,1
ffffffffc0202460:	2701                	sext.w	a4,a4
ffffffffc0202462:	38b71863          	bne	a4,a1,ffffffffc02027f2 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202466:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020246a:	4394                	lw	a3,0(a5)
ffffffffc020246c:	2681                	sext.w	a3,a3
ffffffffc020246e:	3ae69263          	bne	a3,a4,ffffffffc0202812 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202472:	6689                	lui	a3,0x2
ffffffffc0202474:	462d                	li	a2,11
ffffffffc0202476:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7578>
     assert(pgfault_num==2);
ffffffffc020247a:	4398                	lw	a4,0(a5)
ffffffffc020247c:	4589                	li	a1,2
ffffffffc020247e:	2701                	sext.w	a4,a4
ffffffffc0202480:	2eb71963          	bne	a4,a1,ffffffffc0202772 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202484:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202488:	4394                	lw	a3,0(a5)
ffffffffc020248a:	2681                	sext.w	a3,a3
ffffffffc020248c:	30e69363          	bne	a3,a4,ffffffffc0202792 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202490:	668d                	lui	a3,0x3
ffffffffc0202492:	4631                	li	a2,12
ffffffffc0202494:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6578>
     assert(pgfault_num==3);
ffffffffc0202498:	4398                	lw	a4,0(a5)
ffffffffc020249a:	458d                	li	a1,3
ffffffffc020249c:	2701                	sext.w	a4,a4
ffffffffc020249e:	30b71a63          	bne	a4,a1,ffffffffc02027b2 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02024a2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02024a6:	4394                	lw	a3,0(a5)
ffffffffc02024a8:	2681                	sext.w	a3,a3
ffffffffc02024aa:	32e69463          	bne	a3,a4,ffffffffc02027d2 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02024ae:	6691                	lui	a3,0x4
ffffffffc02024b0:	4635                	li	a2,13
ffffffffc02024b2:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5578>
     assert(pgfault_num==4);
ffffffffc02024b6:	4398                	lw	a4,0(a5)
ffffffffc02024b8:	2701                	sext.w	a4,a4
ffffffffc02024ba:	37871c63          	bne	a4,s8,ffffffffc0202832 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02024be:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02024c2:	439c                	lw	a5,0(a5)
ffffffffc02024c4:	2781                	sext.w	a5,a5
ffffffffc02024c6:	38e79663          	bne	a5,a4,ffffffffc0202852 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02024ca:	481c                	lw	a5,16(s0)
ffffffffc02024cc:	40079363          	bnez	a5,ffffffffc02028d2 <swap_init+0x668>
ffffffffc02024d0:	000aa797          	auipc	a5,0xaa
ffffffffc02024d4:	03078793          	addi	a5,a5,48 # ffffffffc02ac500 <swap_in_seq_no>
ffffffffc02024d8:	000aa717          	auipc	a4,0xaa
ffffffffc02024dc:	05070713          	addi	a4,a4,80 # ffffffffc02ac528 <swap_out_seq_no>
ffffffffc02024e0:	000aa617          	auipc	a2,0xaa
ffffffffc02024e4:	04860613          	addi	a2,a2,72 # ffffffffc02ac528 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02024e8:	56fd                	li	a3,-1
ffffffffc02024ea:	c394                	sw	a3,0(a5)
ffffffffc02024ec:	c314                	sw	a3,0(a4)
ffffffffc02024ee:	0791                	addi	a5,a5,4
ffffffffc02024f0:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02024f2:	fef61ce3          	bne	a2,a5,ffffffffc02024ea <swap_init+0x280>
ffffffffc02024f6:	000aa697          	auipc	a3,0xaa
ffffffffc02024fa:	09268693          	addi	a3,a3,146 # ffffffffc02ac588 <check_ptep>
ffffffffc02024fe:	000aa817          	auipc	a6,0xaa
ffffffffc0202502:	fe280813          	addi	a6,a6,-30 # ffffffffc02ac4e0 <check_rp>
ffffffffc0202506:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202508:	000aac97          	auipc	s9,0xaa
ffffffffc020250c:	f90c8c93          	addi	s9,s9,-112 # ffffffffc02ac498 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202510:	00007d97          	auipc	s11,0x7
ffffffffc0202514:	9c0d8d93          	addi	s11,s11,-1600 # ffffffffc0208ed0 <nbase>
ffffffffc0202518:	000aac17          	auipc	s8,0xaa
ffffffffc020251c:	0c0c0c13          	addi	s8,s8,192 # ffffffffc02ac5d8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202520:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202524:	4601                	li	a2,0
ffffffffc0202526:	85ea                	mv	a1,s10
ffffffffc0202528:	855a                	mv	a0,s6
ffffffffc020252a:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020252c:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020252e:	2e2010ef          	jal	ra,ffffffffc0203810 <get_pte>
ffffffffc0202532:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202534:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202536:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202538:	20050163          	beqz	a0,ffffffffc020273a <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020253c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020253e:	0017f613          	andi	a2,a5,1
ffffffffc0202542:	1a060063          	beqz	a2,ffffffffc02026e2 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0202546:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020254a:	078a                	slli	a5,a5,0x2
ffffffffc020254c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020254e:	14c7fe63          	bleu	a2,a5,ffffffffc02026aa <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0202552:	000db703          	ld	a4,0(s11)
ffffffffc0202556:	000c3603          	ld	a2,0(s8)
ffffffffc020255a:	00083583          	ld	a1,0(a6)
ffffffffc020255e:	8f99                	sub	a5,a5,a4
ffffffffc0202560:	079a                	slli	a5,a5,0x6
ffffffffc0202562:	e43a                	sd	a4,8(sp)
ffffffffc0202564:	97b2                	add	a5,a5,a2
ffffffffc0202566:	14f59e63          	bne	a1,a5,ffffffffc02026c2 <swap_init+0x458>
ffffffffc020256a:	6785                	lui	a5,0x1
ffffffffc020256c:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020256e:	6795                	lui	a5,0x5
ffffffffc0202570:	06a1                	addi	a3,a3,8
ffffffffc0202572:	0821                	addi	a6,a6,8
ffffffffc0202574:	fafd16e3          	bne	s10,a5,ffffffffc0202520 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202578:	00005517          	auipc	a0,0x5
ffffffffc020257c:	53850513          	addi	a0,a0,1336 # ffffffffc0207ab0 <commands+0x1198>
ffffffffc0202580:	b51fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc0202584:	000aa797          	auipc	a5,0xaa
ffffffffc0202588:	efc78793          	addi	a5,a5,-260 # ffffffffc02ac480 <sm>
ffffffffc020258c:	639c                	ld	a5,0(a5)
ffffffffc020258e:	7f9c                	ld	a5,56(a5)
ffffffffc0202590:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202592:	40051c63          	bnez	a0,ffffffffc02029aa <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc0202596:	77a2                	ld	a5,40(sp)
ffffffffc0202598:	000aa717          	auipc	a4,0xaa
ffffffffc020259c:	02f72023          	sw	a5,32(a4) # ffffffffc02ac5b8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02025a0:	67e2                	ld	a5,24(sp)
ffffffffc02025a2:	000aa717          	auipc	a4,0xaa
ffffffffc02025a6:	00f73323          	sd	a5,6(a4) # ffffffffc02ac5a8 <free_area>
ffffffffc02025aa:	7782                	ld	a5,32(sp)
ffffffffc02025ac:	000aa717          	auipc	a4,0xaa
ffffffffc02025b0:	00f73223          	sd	a5,4(a4) # ffffffffc02ac5b0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02025b4:	0009b503          	ld	a0,0(s3)
ffffffffc02025b8:	4585                	li	a1,1
ffffffffc02025ba:	09a1                	addi	s3,s3,8
ffffffffc02025bc:	1ce010ef          	jal	ra,ffffffffc020378a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02025c0:	ff499ae3          	bne	s3,s4,ffffffffc02025b4 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02025c4:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02025c8:	855e                	mv	a0,s7
ffffffffc02025ca:	a37fe0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02025ce:	000aa797          	auipc	a5,0xaa
ffffffffc02025d2:	ec278793          	addi	a5,a5,-318 # ffffffffc02ac490 <boot_pgdir>
ffffffffc02025d6:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02025d8:	000aa697          	auipc	a3,0xaa
ffffffffc02025dc:	ee06b823          	sd	zero,-272(a3) # ffffffffc02ac4c8 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02025e0:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02025e4:	6394                	ld	a3,0(a5)
ffffffffc02025e6:	068a                	slli	a3,a3,0x2
ffffffffc02025e8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025ea:	0ce6f063          	bleu	a4,a3,ffffffffc02026aa <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02025ee:	67a2                	ld	a5,8(sp)
ffffffffc02025f0:	000c3503          	ld	a0,0(s8)
ffffffffc02025f4:	8e9d                	sub	a3,a3,a5
ffffffffc02025f6:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02025f8:	8699                	srai	a3,a3,0x6
ffffffffc02025fa:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02025fc:	57fd                	li	a5,-1
ffffffffc02025fe:	83b1                	srli	a5,a5,0xc
ffffffffc0202600:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202602:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202604:	2ee7f763          	bleu	a4,a5,ffffffffc02028f2 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc0202608:	000aa797          	auipc	a5,0xaa
ffffffffc020260c:	fc078793          	addi	a5,a5,-64 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0202610:	639c                	ld	a5,0(a5)
ffffffffc0202612:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202614:	629c                	ld	a5,0(a3)
ffffffffc0202616:	078a                	slli	a5,a5,0x2
ffffffffc0202618:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020261a:	08e7f863          	bleu	a4,a5,ffffffffc02026aa <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020261e:	69a2                	ld	s3,8(sp)
ffffffffc0202620:	4585                	li	a1,1
ffffffffc0202622:	413787b3          	sub	a5,a5,s3
ffffffffc0202626:	079a                	slli	a5,a5,0x6
ffffffffc0202628:	953e                	add	a0,a0,a5
ffffffffc020262a:	160010ef          	jal	ra,ffffffffc020378a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020262e:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202632:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202636:	078a                	slli	a5,a5,0x2
ffffffffc0202638:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020263a:	06e7f863          	bleu	a4,a5,ffffffffc02026aa <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020263e:	000c3503          	ld	a0,0(s8)
ffffffffc0202642:	413787b3          	sub	a5,a5,s3
ffffffffc0202646:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202648:	4585                	li	a1,1
ffffffffc020264a:	953e                	add	a0,a0,a5
ffffffffc020264c:	13e010ef          	jal	ra,ffffffffc020378a <free_pages>
     pgdir[0] = 0;
ffffffffc0202650:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202654:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202658:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020265a:	00878963          	beq	a5,s0,ffffffffc020266c <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020265e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202662:	679c                	ld	a5,8(a5)
ffffffffc0202664:	397d                	addiw	s2,s2,-1
ffffffffc0202666:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202668:	fe879be3          	bne	a5,s0,ffffffffc020265e <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc020266c:	28091f63          	bnez	s2,ffffffffc020290a <swap_init+0x6a0>
     assert(total==0);
ffffffffc0202670:	2a049d63          	bnez	s1,ffffffffc020292a <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202674:	00005517          	auipc	a0,0x5
ffffffffc0202678:	48c50513          	addi	a0,a0,1164 # ffffffffc0207b00 <commands+0x11e8>
ffffffffc020267c:	a55fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202680:	b92d                	j	ffffffffc02022ba <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202682:	4481                	li	s1,0
ffffffffc0202684:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202686:	4981                	li	s3,0
ffffffffc0202688:	b17d                	j	ffffffffc0202336 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020268a:	00005697          	auipc	a3,0x5
ffffffffc020268e:	23668693          	addi	a3,a3,566 # ffffffffc02078c0 <commands+0xfa8>
ffffffffc0202692:	00004617          	auipc	a2,0x4
ffffffffc0202696:	70660613          	addi	a2,a2,1798 # ffffffffc0206d98 <commands+0x480>
ffffffffc020269a:	0bc00593          	li	a1,188
ffffffffc020269e:	00005517          	auipc	a0,0x5
ffffffffc02026a2:	1fa50513          	addi	a0,a0,506 # ffffffffc0207898 <commands+0xf80>
ffffffffc02026a6:	b71fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02026aa:	00005617          	auipc	a2,0x5
ffffffffc02026ae:	e3e60613          	addi	a2,a2,-450 # ffffffffc02074e8 <commands+0xbd0>
ffffffffc02026b2:	06200593          	li	a1,98
ffffffffc02026b6:	00005517          	auipc	a0,0x5
ffffffffc02026ba:	e5250513          	addi	a0,a0,-430 # ffffffffc0207508 <commands+0xbf0>
ffffffffc02026be:	b59fd0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02026c2:	00005697          	auipc	a3,0x5
ffffffffc02026c6:	3c668693          	addi	a3,a3,966 # ffffffffc0207a88 <commands+0x1170>
ffffffffc02026ca:	00004617          	auipc	a2,0x4
ffffffffc02026ce:	6ce60613          	addi	a2,a2,1742 # ffffffffc0206d98 <commands+0x480>
ffffffffc02026d2:	0fc00593          	li	a1,252
ffffffffc02026d6:	00005517          	auipc	a0,0x5
ffffffffc02026da:	1c250513          	addi	a0,a0,450 # ffffffffc0207898 <commands+0xf80>
ffffffffc02026de:	b39fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02026e2:	00005617          	auipc	a2,0x5
ffffffffc02026e6:	b3660613          	addi	a2,a2,-1226 # ffffffffc0207218 <commands+0x900>
ffffffffc02026ea:	07400593          	li	a1,116
ffffffffc02026ee:	00005517          	auipc	a0,0x5
ffffffffc02026f2:	e1a50513          	addi	a0,a0,-486 # ffffffffc0207508 <commands+0xbf0>
ffffffffc02026f6:	b21fd0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02026fa:	00005697          	auipc	a3,0x5
ffffffffc02026fe:	2c668693          	addi	a3,a3,710 # ffffffffc02079c0 <commands+0x10a8>
ffffffffc0202702:	00004617          	auipc	a2,0x4
ffffffffc0202706:	69660613          	addi	a2,a2,1686 # ffffffffc0206d98 <commands+0x480>
ffffffffc020270a:	0dd00593          	li	a1,221
ffffffffc020270e:	00005517          	auipc	a0,0x5
ffffffffc0202712:	18a50513          	addi	a0,a0,394 # ffffffffc0207898 <commands+0xf80>
ffffffffc0202716:	b01fd0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020271a:	00005697          	auipc	a3,0x5
ffffffffc020271e:	28e68693          	addi	a3,a3,654 # ffffffffc02079a8 <commands+0x1090>
ffffffffc0202722:	00004617          	auipc	a2,0x4
ffffffffc0202726:	67660613          	addi	a2,a2,1654 # ffffffffc0206d98 <commands+0x480>
ffffffffc020272a:	0dc00593          	li	a1,220
ffffffffc020272e:	00005517          	auipc	a0,0x5
ffffffffc0202732:	16a50513          	addi	a0,a0,362 # ffffffffc0207898 <commands+0xf80>
ffffffffc0202736:	ae1fd0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020273a:	00005697          	auipc	a3,0x5
ffffffffc020273e:	33668693          	addi	a3,a3,822 # ffffffffc0207a70 <commands+0x1158>
ffffffffc0202742:	00004617          	auipc	a2,0x4
ffffffffc0202746:	65660613          	addi	a2,a2,1622 # ffffffffc0206d98 <commands+0x480>
ffffffffc020274a:	0fb00593          	li	a1,251
ffffffffc020274e:	00005517          	auipc	a0,0x5
ffffffffc0202752:	14a50513          	addi	a0,a0,330 # ffffffffc0207898 <commands+0xf80>
ffffffffc0202756:	ac1fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020275a:	00005617          	auipc	a2,0x5
ffffffffc020275e:	11e60613          	addi	a2,a2,286 # ffffffffc0207878 <commands+0xf60>
ffffffffc0202762:	02800593          	li	a1,40
ffffffffc0202766:	00005517          	auipc	a0,0x5
ffffffffc020276a:	13250513          	addi	a0,a0,306 # ffffffffc0207898 <commands+0xf80>
ffffffffc020276e:	aa9fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc0202772:	00005697          	auipc	a3,0x5
ffffffffc0202776:	2ce68693          	addi	a3,a3,718 # ffffffffc0207a40 <commands+0x1128>
ffffffffc020277a:	00004617          	auipc	a2,0x4
ffffffffc020277e:	61e60613          	addi	a2,a2,1566 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202782:	09700593          	li	a1,151
ffffffffc0202786:	00005517          	auipc	a0,0x5
ffffffffc020278a:	11250513          	addi	a0,a0,274 # ffffffffc0207898 <commands+0xf80>
ffffffffc020278e:	a89fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc0202792:	00005697          	auipc	a3,0x5
ffffffffc0202796:	2ae68693          	addi	a3,a3,686 # ffffffffc0207a40 <commands+0x1128>
ffffffffc020279a:	00004617          	auipc	a2,0x4
ffffffffc020279e:	5fe60613          	addi	a2,a2,1534 # ffffffffc0206d98 <commands+0x480>
ffffffffc02027a2:	09900593          	li	a1,153
ffffffffc02027a6:	00005517          	auipc	a0,0x5
ffffffffc02027aa:	0f250513          	addi	a0,a0,242 # ffffffffc0207898 <commands+0xf80>
ffffffffc02027ae:	a69fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc02027b2:	00005697          	auipc	a3,0x5
ffffffffc02027b6:	29e68693          	addi	a3,a3,670 # ffffffffc0207a50 <commands+0x1138>
ffffffffc02027ba:	00004617          	auipc	a2,0x4
ffffffffc02027be:	5de60613          	addi	a2,a2,1502 # ffffffffc0206d98 <commands+0x480>
ffffffffc02027c2:	09b00593          	li	a1,155
ffffffffc02027c6:	00005517          	auipc	a0,0x5
ffffffffc02027ca:	0d250513          	addi	a0,a0,210 # ffffffffc0207898 <commands+0xf80>
ffffffffc02027ce:	a49fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc02027d2:	00005697          	auipc	a3,0x5
ffffffffc02027d6:	27e68693          	addi	a3,a3,638 # ffffffffc0207a50 <commands+0x1138>
ffffffffc02027da:	00004617          	auipc	a2,0x4
ffffffffc02027de:	5be60613          	addi	a2,a2,1470 # ffffffffc0206d98 <commands+0x480>
ffffffffc02027e2:	09d00593          	li	a1,157
ffffffffc02027e6:	00005517          	auipc	a0,0x5
ffffffffc02027ea:	0b250513          	addi	a0,a0,178 # ffffffffc0207898 <commands+0xf80>
ffffffffc02027ee:	a29fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc02027f2:	00005697          	auipc	a3,0x5
ffffffffc02027f6:	23e68693          	addi	a3,a3,574 # ffffffffc0207a30 <commands+0x1118>
ffffffffc02027fa:	00004617          	auipc	a2,0x4
ffffffffc02027fe:	59e60613          	addi	a2,a2,1438 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202802:	09300593          	li	a1,147
ffffffffc0202806:	00005517          	auipc	a0,0x5
ffffffffc020280a:	09250513          	addi	a0,a0,146 # ffffffffc0207898 <commands+0xf80>
ffffffffc020280e:	a09fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc0202812:	00005697          	auipc	a3,0x5
ffffffffc0202816:	21e68693          	addi	a3,a3,542 # ffffffffc0207a30 <commands+0x1118>
ffffffffc020281a:	00004617          	auipc	a2,0x4
ffffffffc020281e:	57e60613          	addi	a2,a2,1406 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202822:	09500593          	li	a1,149
ffffffffc0202826:	00005517          	auipc	a0,0x5
ffffffffc020282a:	07250513          	addi	a0,a0,114 # ffffffffc0207898 <commands+0xf80>
ffffffffc020282e:	9e9fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc0202832:	00005697          	auipc	a3,0x5
ffffffffc0202836:	da668693          	addi	a3,a3,-602 # ffffffffc02075d8 <commands+0xcc0>
ffffffffc020283a:	00004617          	auipc	a2,0x4
ffffffffc020283e:	55e60613          	addi	a2,a2,1374 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202842:	09f00593          	li	a1,159
ffffffffc0202846:	00005517          	auipc	a0,0x5
ffffffffc020284a:	05250513          	addi	a0,a0,82 # ffffffffc0207898 <commands+0xf80>
ffffffffc020284e:	9c9fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc0202852:	00005697          	auipc	a3,0x5
ffffffffc0202856:	d8668693          	addi	a3,a3,-634 # ffffffffc02075d8 <commands+0xcc0>
ffffffffc020285a:	00004617          	auipc	a2,0x4
ffffffffc020285e:	53e60613          	addi	a2,a2,1342 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202862:	0a100593          	li	a1,161
ffffffffc0202866:	00005517          	auipc	a0,0x5
ffffffffc020286a:	03250513          	addi	a0,a0,50 # ffffffffc0207898 <commands+0xf80>
ffffffffc020286e:	9a9fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202872:	00005697          	auipc	a3,0x5
ffffffffc0202876:	c3668693          	addi	a3,a3,-970 # ffffffffc02074a8 <commands+0xb90>
ffffffffc020287a:	00004617          	auipc	a2,0x4
ffffffffc020287e:	51e60613          	addi	a2,a2,1310 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202882:	0cc00593          	li	a1,204
ffffffffc0202886:	00005517          	auipc	a0,0x5
ffffffffc020288a:	01250513          	addi	a0,a0,18 # ffffffffc0207898 <commands+0xf80>
ffffffffc020288e:	989fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(vma != NULL);
ffffffffc0202892:	00005697          	auipc	a3,0x5
ffffffffc0202896:	d0e68693          	addi	a3,a3,-754 # ffffffffc02075a0 <commands+0xc88>
ffffffffc020289a:	00004617          	auipc	a2,0x4
ffffffffc020289e:	4fe60613          	addi	a2,a2,1278 # ffffffffc0206d98 <commands+0x480>
ffffffffc02028a2:	0cf00593          	li	a1,207
ffffffffc02028a6:	00005517          	auipc	a0,0x5
ffffffffc02028aa:	ff250513          	addi	a0,a0,-14 # ffffffffc0207898 <commands+0xf80>
ffffffffc02028ae:	969fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02028b2:	00005697          	auipc	a3,0x5
ffffffffc02028b6:	0b668693          	addi	a3,a3,182 # ffffffffc0207968 <commands+0x1050>
ffffffffc02028ba:	00004617          	auipc	a2,0x4
ffffffffc02028be:	4de60613          	addi	a2,a2,1246 # ffffffffc0206d98 <commands+0x480>
ffffffffc02028c2:	0d700593          	li	a1,215
ffffffffc02028c6:	00005517          	auipc	a0,0x5
ffffffffc02028ca:	fd250513          	addi	a0,a0,-46 # ffffffffc0207898 <commands+0xf80>
ffffffffc02028ce:	949fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert( nr_free == 0);         
ffffffffc02028d2:	00005697          	auipc	a3,0x5
ffffffffc02028d6:	18e68693          	addi	a3,a3,398 # ffffffffc0207a60 <commands+0x1148>
ffffffffc02028da:	00004617          	auipc	a2,0x4
ffffffffc02028de:	4be60613          	addi	a2,a2,1214 # ffffffffc0206d98 <commands+0x480>
ffffffffc02028e2:	0f300593          	li	a1,243
ffffffffc02028e6:	00005517          	auipc	a0,0x5
ffffffffc02028ea:	fb250513          	addi	a0,a0,-78 # ffffffffc0207898 <commands+0xf80>
ffffffffc02028ee:	929fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc02028f2:	00005617          	auipc	a2,0x5
ffffffffc02028f6:	c2660613          	addi	a2,a2,-986 # ffffffffc0207518 <commands+0xc00>
ffffffffc02028fa:	06900593          	li	a1,105
ffffffffc02028fe:	00005517          	auipc	a0,0x5
ffffffffc0202902:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0202906:	911fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(count==0);
ffffffffc020290a:	00005697          	auipc	a3,0x5
ffffffffc020290e:	1d668693          	addi	a3,a3,470 # ffffffffc0207ae0 <commands+0x11c8>
ffffffffc0202912:	00004617          	auipc	a2,0x4
ffffffffc0202916:	48660613          	addi	a2,a2,1158 # ffffffffc0206d98 <commands+0x480>
ffffffffc020291a:	11d00593          	li	a1,285
ffffffffc020291e:	00005517          	auipc	a0,0x5
ffffffffc0202922:	f7a50513          	addi	a0,a0,-134 # ffffffffc0207898 <commands+0xf80>
ffffffffc0202926:	8f1fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total==0);
ffffffffc020292a:	00005697          	auipc	a3,0x5
ffffffffc020292e:	1c668693          	addi	a3,a3,454 # ffffffffc0207af0 <commands+0x11d8>
ffffffffc0202932:	00004617          	auipc	a2,0x4
ffffffffc0202936:	46660613          	addi	a2,a2,1126 # ffffffffc0206d98 <commands+0x480>
ffffffffc020293a:	11e00593          	li	a1,286
ffffffffc020293e:	00005517          	auipc	a0,0x5
ffffffffc0202942:	f5a50513          	addi	a0,a0,-166 # ffffffffc0207898 <commands+0xf80>
ffffffffc0202946:	8d1fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020294a:	00005697          	auipc	a3,0x5
ffffffffc020294e:	09668693          	addi	a3,a3,150 # ffffffffc02079e0 <commands+0x10c8>
ffffffffc0202952:	00004617          	auipc	a2,0x4
ffffffffc0202956:	44660613          	addi	a2,a2,1094 # ffffffffc0206d98 <commands+0x480>
ffffffffc020295a:	0ea00593          	li	a1,234
ffffffffc020295e:	00005517          	auipc	a0,0x5
ffffffffc0202962:	f3a50513          	addi	a0,a0,-198 # ffffffffc0207898 <commands+0xf80>
ffffffffc0202966:	8b1fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(mm != NULL);
ffffffffc020296a:	00005697          	auipc	a3,0x5
ffffffffc020296e:	9b668693          	addi	a3,a3,-1610 # ffffffffc0207320 <commands+0xa08>
ffffffffc0202972:	00004617          	auipc	a2,0x4
ffffffffc0202976:	42660613          	addi	a2,a2,1062 # ffffffffc0206d98 <commands+0x480>
ffffffffc020297a:	0c400593          	li	a1,196
ffffffffc020297e:	00005517          	auipc	a0,0x5
ffffffffc0202982:	f1a50513          	addi	a0,a0,-230 # ffffffffc0207898 <commands+0xf80>
ffffffffc0202986:	891fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020298a:	00005697          	auipc	a3,0x5
ffffffffc020298e:	f8e68693          	addi	a3,a3,-114 # ffffffffc0207918 <commands+0x1000>
ffffffffc0202992:	00004617          	auipc	a2,0x4
ffffffffc0202996:	40660613          	addi	a2,a2,1030 # ffffffffc0206d98 <commands+0x480>
ffffffffc020299a:	0c700593          	li	a1,199
ffffffffc020299e:	00005517          	auipc	a0,0x5
ffffffffc02029a2:	efa50513          	addi	a0,a0,-262 # ffffffffc0207898 <commands+0xf80>
ffffffffc02029a6:	871fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(ret==0);
ffffffffc02029aa:	00005697          	auipc	a3,0x5
ffffffffc02029ae:	12e68693          	addi	a3,a3,302 # ffffffffc0207ad8 <commands+0x11c0>
ffffffffc02029b2:	00004617          	auipc	a2,0x4
ffffffffc02029b6:	3e660613          	addi	a2,a2,998 # ffffffffc0206d98 <commands+0x480>
ffffffffc02029ba:	10200593          	li	a1,258
ffffffffc02029be:	00005517          	auipc	a0,0x5
ffffffffc02029c2:	eda50513          	addi	a0,a0,-294 # ffffffffc0207898 <commands+0xf80>
ffffffffc02029c6:	851fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total == nr_free_pages());
ffffffffc02029ca:	00005697          	auipc	a3,0x5
ffffffffc02029ce:	f0668693          	addi	a3,a3,-250 # ffffffffc02078d0 <commands+0xfb8>
ffffffffc02029d2:	00004617          	auipc	a2,0x4
ffffffffc02029d6:	3c660613          	addi	a2,a2,966 # ffffffffc0206d98 <commands+0x480>
ffffffffc02029da:	0bf00593          	li	a1,191
ffffffffc02029de:	00005517          	auipc	a0,0x5
ffffffffc02029e2:	eba50513          	addi	a0,a0,-326 # ffffffffc0207898 <commands+0xf80>
ffffffffc02029e6:	831fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02029ea <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02029ea:	000aa797          	auipc	a5,0xaa
ffffffffc02029ee:	a9678793          	addi	a5,a5,-1386 # ffffffffc02ac480 <sm>
ffffffffc02029f2:	639c                	ld	a5,0(a5)
ffffffffc02029f4:	0107b303          	ld	t1,16(a5)
ffffffffc02029f8:	8302                	jr	t1

ffffffffc02029fa <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02029fa:	000aa797          	auipc	a5,0xaa
ffffffffc02029fe:	a8678793          	addi	a5,a5,-1402 # ffffffffc02ac480 <sm>
ffffffffc0202a02:	639c                	ld	a5,0(a5)
ffffffffc0202a04:	0207b303          	ld	t1,32(a5)
ffffffffc0202a08:	8302                	jr	t1

ffffffffc0202a0a <swap_out>:
{
ffffffffc0202a0a:	711d                	addi	sp,sp,-96
ffffffffc0202a0c:	ec86                	sd	ra,88(sp)
ffffffffc0202a0e:	e8a2                	sd	s0,80(sp)
ffffffffc0202a10:	e4a6                	sd	s1,72(sp)
ffffffffc0202a12:	e0ca                	sd	s2,64(sp)
ffffffffc0202a14:	fc4e                	sd	s3,56(sp)
ffffffffc0202a16:	f852                	sd	s4,48(sp)
ffffffffc0202a18:	f456                	sd	s5,40(sp)
ffffffffc0202a1a:	f05a                	sd	s6,32(sp)
ffffffffc0202a1c:	ec5e                	sd	s7,24(sp)
ffffffffc0202a1e:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202a20:	cde9                	beqz	a1,ffffffffc0202afa <swap_out+0xf0>
ffffffffc0202a22:	8ab2                	mv	s5,a2
ffffffffc0202a24:	892a                	mv	s2,a0
ffffffffc0202a26:	8a2e                	mv	s4,a1
ffffffffc0202a28:	4401                	li	s0,0
ffffffffc0202a2a:	000aa997          	auipc	s3,0xaa
ffffffffc0202a2e:	a5698993          	addi	s3,s3,-1450 # ffffffffc02ac480 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202a32:	00005b17          	auipc	s6,0x5
ffffffffc0202a36:	14eb0b13          	addi	s6,s6,334 # ffffffffc0207b80 <commands+0x1268>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202a3a:	00005b97          	auipc	s7,0x5
ffffffffc0202a3e:	12eb8b93          	addi	s7,s7,302 # ffffffffc0207b68 <commands+0x1250>
ffffffffc0202a42:	a825                	j	ffffffffc0202a7a <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202a44:	67a2                	ld	a5,8(sp)
ffffffffc0202a46:	8626                	mv	a2,s1
ffffffffc0202a48:	85a2                	mv	a1,s0
ffffffffc0202a4a:	7f94                	ld	a3,56(a5)
ffffffffc0202a4c:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202a4e:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202a50:	82b1                	srli	a3,a3,0xc
ffffffffc0202a52:	0685                	addi	a3,a3,1
ffffffffc0202a54:	e7cfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202a58:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202a5a:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202a5c:	7d1c                	ld	a5,56(a0)
ffffffffc0202a5e:	83b1                	srli	a5,a5,0xc
ffffffffc0202a60:	0785                	addi	a5,a5,1
ffffffffc0202a62:	07a2                	slli	a5,a5,0x8
ffffffffc0202a64:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202a68:	523000ef          	jal	ra,ffffffffc020378a <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202a6c:	01893503          	ld	a0,24(s2)
ffffffffc0202a70:	85a6                	mv	a1,s1
ffffffffc0202a72:	1ac020ef          	jal	ra,ffffffffc0204c1e <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202a76:	048a0d63          	beq	s4,s0,ffffffffc0202ad0 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202a7a:	0009b783          	ld	a5,0(s3)
ffffffffc0202a7e:	8656                	mv	a2,s5
ffffffffc0202a80:	002c                	addi	a1,sp,8
ffffffffc0202a82:	7b9c                	ld	a5,48(a5)
ffffffffc0202a84:	854a                	mv	a0,s2
ffffffffc0202a86:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202a88:	e12d                	bnez	a0,ffffffffc0202aea <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202a8a:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202a8c:	01893503          	ld	a0,24(s2)
ffffffffc0202a90:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202a92:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202a94:	85a6                	mv	a1,s1
ffffffffc0202a96:	57b000ef          	jal	ra,ffffffffc0203810 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202a9a:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202a9c:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202a9e:	8b85                	andi	a5,a5,1
ffffffffc0202aa0:	cfb9                	beqz	a5,ffffffffc0202afe <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202aa2:	65a2                	ld	a1,8(sp)
ffffffffc0202aa4:	7d9c                	ld	a5,56(a1)
ffffffffc0202aa6:	83b1                	srli	a5,a5,0xc
ffffffffc0202aa8:	00178513          	addi	a0,a5,1
ffffffffc0202aac:	0522                	slli	a0,a0,0x8
ffffffffc0202aae:	2da020ef          	jal	ra,ffffffffc0204d88 <swapfs_write>
ffffffffc0202ab2:	d949                	beqz	a0,ffffffffc0202a44 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202ab4:	855e                	mv	a0,s7
ffffffffc0202ab6:	e1afd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202aba:	0009b783          	ld	a5,0(s3)
ffffffffc0202abe:	6622                	ld	a2,8(sp)
ffffffffc0202ac0:	4681                	li	a3,0
ffffffffc0202ac2:	739c                	ld	a5,32(a5)
ffffffffc0202ac4:	85a6                	mv	a1,s1
ffffffffc0202ac6:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202ac8:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202aca:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202acc:	fa8a17e3          	bne	s4,s0,ffffffffc0202a7a <swap_out+0x70>
}
ffffffffc0202ad0:	8522                	mv	a0,s0
ffffffffc0202ad2:	60e6                	ld	ra,88(sp)
ffffffffc0202ad4:	6446                	ld	s0,80(sp)
ffffffffc0202ad6:	64a6                	ld	s1,72(sp)
ffffffffc0202ad8:	6906                	ld	s2,64(sp)
ffffffffc0202ada:	79e2                	ld	s3,56(sp)
ffffffffc0202adc:	7a42                	ld	s4,48(sp)
ffffffffc0202ade:	7aa2                	ld	s5,40(sp)
ffffffffc0202ae0:	7b02                	ld	s6,32(sp)
ffffffffc0202ae2:	6be2                	ld	s7,24(sp)
ffffffffc0202ae4:	6c42                	ld	s8,16(sp)
ffffffffc0202ae6:	6125                	addi	sp,sp,96
ffffffffc0202ae8:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202aea:	85a2                	mv	a1,s0
ffffffffc0202aec:	00005517          	auipc	a0,0x5
ffffffffc0202af0:	03450513          	addi	a0,a0,52 # ffffffffc0207b20 <commands+0x1208>
ffffffffc0202af4:	ddcfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc0202af8:	bfe1                	j	ffffffffc0202ad0 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202afa:	4401                	li	s0,0
ffffffffc0202afc:	bfd1                	j	ffffffffc0202ad0 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202afe:	00005697          	auipc	a3,0x5
ffffffffc0202b02:	05268693          	addi	a3,a3,82 # ffffffffc0207b50 <commands+0x1238>
ffffffffc0202b06:	00004617          	auipc	a2,0x4
ffffffffc0202b0a:	29260613          	addi	a2,a2,658 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202b0e:	06800593          	li	a1,104
ffffffffc0202b12:	00005517          	auipc	a0,0x5
ffffffffc0202b16:	d8650513          	addi	a0,a0,-634 # ffffffffc0207898 <commands+0xf80>
ffffffffc0202b1a:	efcfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202b1e <swap_in>:
{
ffffffffc0202b1e:	7179                	addi	sp,sp,-48
ffffffffc0202b20:	e84a                	sd	s2,16(sp)
ffffffffc0202b22:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202b24:	4505                	li	a0,1
{
ffffffffc0202b26:	ec26                	sd	s1,24(sp)
ffffffffc0202b28:	e44e                	sd	s3,8(sp)
ffffffffc0202b2a:	f406                	sd	ra,40(sp)
ffffffffc0202b2c:	f022                	sd	s0,32(sp)
ffffffffc0202b2e:	84ae                	mv	s1,a1
ffffffffc0202b30:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202b32:	3d1000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
     assert(result!=NULL);
ffffffffc0202b36:	c129                	beqz	a0,ffffffffc0202b78 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202b38:	842a                	mv	s0,a0
ffffffffc0202b3a:	01893503          	ld	a0,24(s2)
ffffffffc0202b3e:	4601                	li	a2,0
ffffffffc0202b40:	85a6                	mv	a1,s1
ffffffffc0202b42:	4cf000ef          	jal	ra,ffffffffc0203810 <get_pte>
ffffffffc0202b46:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202b48:	6108                	ld	a0,0(a0)
ffffffffc0202b4a:	85a2                	mv	a1,s0
ffffffffc0202b4c:	1a4020ef          	jal	ra,ffffffffc0204cf0 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202b50:	00093583          	ld	a1,0(s2)
ffffffffc0202b54:	8626                	mv	a2,s1
ffffffffc0202b56:	00005517          	auipc	a0,0x5
ffffffffc0202b5a:	ce250513          	addi	a0,a0,-798 # ffffffffc0207838 <commands+0xf20>
ffffffffc0202b5e:	81a1                	srli	a1,a1,0x8
ffffffffc0202b60:	d70fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202b64:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202b66:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202b6a:	7402                	ld	s0,32(sp)
ffffffffc0202b6c:	64e2                	ld	s1,24(sp)
ffffffffc0202b6e:	6942                	ld	s2,16(sp)
ffffffffc0202b70:	69a2                	ld	s3,8(sp)
ffffffffc0202b72:	4501                	li	a0,0
ffffffffc0202b74:	6145                	addi	sp,sp,48
ffffffffc0202b76:	8082                	ret
     assert(result!=NULL);
ffffffffc0202b78:	00005697          	auipc	a3,0x5
ffffffffc0202b7c:	cb068693          	addi	a3,a3,-848 # ffffffffc0207828 <commands+0xf10>
ffffffffc0202b80:	00004617          	auipc	a2,0x4
ffffffffc0202b84:	21860613          	addi	a2,a2,536 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202b88:	07e00593          	li	a1,126
ffffffffc0202b8c:	00005517          	auipc	a0,0x5
ffffffffc0202b90:	d0c50513          	addi	a0,a0,-756 # ffffffffc0207898 <commands+0xf80>
ffffffffc0202b94:	e82fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202b98 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202b98:	000aa797          	auipc	a5,0xaa
ffffffffc0202b9c:	a1078793          	addi	a5,a5,-1520 # ffffffffc02ac5a8 <free_area>
ffffffffc0202ba0:	e79c                	sd	a5,8(a5)
ffffffffc0202ba2:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202ba4:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202ba8:	8082                	ret

ffffffffc0202baa <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202baa:	000aa517          	auipc	a0,0xaa
ffffffffc0202bae:	a0e56503          	lwu	a0,-1522(a0) # ffffffffc02ac5b8 <free_area+0x10>
ffffffffc0202bb2:	8082                	ret

ffffffffc0202bb4 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202bb4:	715d                	addi	sp,sp,-80
ffffffffc0202bb6:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0202bb8:	000aa917          	auipc	s2,0xaa
ffffffffc0202bbc:	9f090913          	addi	s2,s2,-1552 # ffffffffc02ac5a8 <free_area>
ffffffffc0202bc0:	00893783          	ld	a5,8(s2)
ffffffffc0202bc4:	e486                	sd	ra,72(sp)
ffffffffc0202bc6:	e0a2                	sd	s0,64(sp)
ffffffffc0202bc8:	fc26                	sd	s1,56(sp)
ffffffffc0202bca:	f44e                	sd	s3,40(sp)
ffffffffc0202bcc:	f052                	sd	s4,32(sp)
ffffffffc0202bce:	ec56                	sd	s5,24(sp)
ffffffffc0202bd0:	e85a                	sd	s6,16(sp)
ffffffffc0202bd2:	e45e                	sd	s7,8(sp)
ffffffffc0202bd4:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202bd6:	31278463          	beq	a5,s2,ffffffffc0202ede <default_check+0x32a>
ffffffffc0202bda:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202bde:	8305                	srli	a4,a4,0x1
ffffffffc0202be0:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202be2:	30070263          	beqz	a4,ffffffffc0202ee6 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0202be6:	4401                	li	s0,0
ffffffffc0202be8:	4481                	li	s1,0
ffffffffc0202bea:	a031                	j	ffffffffc0202bf6 <default_check+0x42>
ffffffffc0202bec:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202bf0:	8b09                	andi	a4,a4,2
ffffffffc0202bf2:	2e070a63          	beqz	a4,ffffffffc0202ee6 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0202bf6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202bfa:	679c                	ld	a5,8(a5)
ffffffffc0202bfc:	2485                	addiw	s1,s1,1
ffffffffc0202bfe:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202c00:	ff2796e3          	bne	a5,s2,ffffffffc0202bec <default_check+0x38>
ffffffffc0202c04:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0202c06:	3cb000ef          	jal	ra,ffffffffc02037d0 <nr_free_pages>
ffffffffc0202c0a:	73351e63          	bne	a0,s3,ffffffffc0203346 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202c0e:	4505                	li	a0,1
ffffffffc0202c10:	2f3000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202c14:	8a2a                	mv	s4,a0
ffffffffc0202c16:	46050863          	beqz	a0,ffffffffc0203086 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202c1a:	4505                	li	a0,1
ffffffffc0202c1c:	2e7000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202c20:	89aa                	mv	s3,a0
ffffffffc0202c22:	74050263          	beqz	a0,ffffffffc0203366 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202c26:	4505                	li	a0,1
ffffffffc0202c28:	2db000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202c2c:	8aaa                	mv	s5,a0
ffffffffc0202c2e:	4c050c63          	beqz	a0,ffffffffc0203106 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202c32:	2d3a0a63          	beq	s4,s3,ffffffffc0202f06 <default_check+0x352>
ffffffffc0202c36:	2caa0863          	beq	s4,a0,ffffffffc0202f06 <default_check+0x352>
ffffffffc0202c3a:	2ca98663          	beq	s3,a0,ffffffffc0202f06 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202c3e:	000a2783          	lw	a5,0(s4)
ffffffffc0202c42:	2e079263          	bnez	a5,ffffffffc0202f26 <default_check+0x372>
ffffffffc0202c46:	0009a783          	lw	a5,0(s3)
ffffffffc0202c4a:	2c079e63          	bnez	a5,ffffffffc0202f26 <default_check+0x372>
ffffffffc0202c4e:	411c                	lw	a5,0(a0)
ffffffffc0202c50:	2c079b63          	bnez	a5,ffffffffc0202f26 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0202c54:	000aa797          	auipc	a5,0xaa
ffffffffc0202c58:	98478793          	addi	a5,a5,-1660 # ffffffffc02ac5d8 <pages>
ffffffffc0202c5c:	639c                	ld	a5,0(a5)
ffffffffc0202c5e:	00006717          	auipc	a4,0x6
ffffffffc0202c62:	27270713          	addi	a4,a4,626 # ffffffffc0208ed0 <nbase>
ffffffffc0202c66:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202c68:	000aa717          	auipc	a4,0xaa
ffffffffc0202c6c:	83070713          	addi	a4,a4,-2000 # ffffffffc02ac498 <npage>
ffffffffc0202c70:	6314                	ld	a3,0(a4)
ffffffffc0202c72:	40fa0733          	sub	a4,s4,a5
ffffffffc0202c76:	8719                	srai	a4,a4,0x6
ffffffffc0202c78:	9732                	add	a4,a4,a2
ffffffffc0202c7a:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c7c:	0732                	slli	a4,a4,0xc
ffffffffc0202c7e:	2cd77463          	bleu	a3,a4,ffffffffc0202f46 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0202c82:	40f98733          	sub	a4,s3,a5
ffffffffc0202c86:	8719                	srai	a4,a4,0x6
ffffffffc0202c88:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c8a:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202c8c:	4ed77d63          	bleu	a3,a4,ffffffffc0203186 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0202c90:	40f507b3          	sub	a5,a0,a5
ffffffffc0202c94:	8799                	srai	a5,a5,0x6
ffffffffc0202c96:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c98:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202c9a:	34d7f663          	bleu	a3,a5,ffffffffc0202fe6 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0202c9e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202ca0:	00093c03          	ld	s8,0(s2)
ffffffffc0202ca4:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0202ca8:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0202cac:	000aa797          	auipc	a5,0xaa
ffffffffc0202cb0:	9127b223          	sd	s2,-1788(a5) # ffffffffc02ac5b0 <free_area+0x8>
ffffffffc0202cb4:	000aa797          	auipc	a5,0xaa
ffffffffc0202cb8:	8f27ba23          	sd	s2,-1804(a5) # ffffffffc02ac5a8 <free_area>
    nr_free = 0;
ffffffffc0202cbc:	000aa797          	auipc	a5,0xaa
ffffffffc0202cc0:	8e07ae23          	sw	zero,-1796(a5) # ffffffffc02ac5b8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202cc4:	23f000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202cc8:	2e051f63          	bnez	a0,ffffffffc0202fc6 <default_check+0x412>
    free_page(p0);
ffffffffc0202ccc:	4585                	li	a1,1
ffffffffc0202cce:	8552                	mv	a0,s4
ffffffffc0202cd0:	2bb000ef          	jal	ra,ffffffffc020378a <free_pages>
    free_page(p1);
ffffffffc0202cd4:	4585                	li	a1,1
ffffffffc0202cd6:	854e                	mv	a0,s3
ffffffffc0202cd8:	2b3000ef          	jal	ra,ffffffffc020378a <free_pages>
    free_page(p2);
ffffffffc0202cdc:	4585                	li	a1,1
ffffffffc0202cde:	8556                	mv	a0,s5
ffffffffc0202ce0:	2ab000ef          	jal	ra,ffffffffc020378a <free_pages>
    assert(nr_free == 3);
ffffffffc0202ce4:	01092703          	lw	a4,16(s2)
ffffffffc0202ce8:	478d                	li	a5,3
ffffffffc0202cea:	2af71e63          	bne	a4,a5,ffffffffc0202fa6 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202cee:	4505                	li	a0,1
ffffffffc0202cf0:	213000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202cf4:	89aa                	mv	s3,a0
ffffffffc0202cf6:	28050863          	beqz	a0,ffffffffc0202f86 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202cfa:	4505                	li	a0,1
ffffffffc0202cfc:	207000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202d00:	8aaa                	mv	s5,a0
ffffffffc0202d02:	3e050263          	beqz	a0,ffffffffc02030e6 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202d06:	4505                	li	a0,1
ffffffffc0202d08:	1fb000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202d0c:	8a2a                	mv	s4,a0
ffffffffc0202d0e:	3a050c63          	beqz	a0,ffffffffc02030c6 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0202d12:	4505                	li	a0,1
ffffffffc0202d14:	1ef000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202d18:	38051763          	bnez	a0,ffffffffc02030a6 <default_check+0x4f2>
    free_page(p0);
ffffffffc0202d1c:	4585                	li	a1,1
ffffffffc0202d1e:	854e                	mv	a0,s3
ffffffffc0202d20:	26b000ef          	jal	ra,ffffffffc020378a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202d24:	00893783          	ld	a5,8(s2)
ffffffffc0202d28:	23278f63          	beq	a5,s2,ffffffffc0202f66 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0202d2c:	4505                	li	a0,1
ffffffffc0202d2e:	1d5000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202d32:	32a99a63          	bne	s3,a0,ffffffffc0203066 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0202d36:	4505                	li	a0,1
ffffffffc0202d38:	1cb000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202d3c:	30051563          	bnez	a0,ffffffffc0203046 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0202d40:	01092783          	lw	a5,16(s2)
ffffffffc0202d44:	2e079163          	bnez	a5,ffffffffc0203026 <default_check+0x472>
    free_page(p);
ffffffffc0202d48:	854e                	mv	a0,s3
ffffffffc0202d4a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202d4c:	000aa797          	auipc	a5,0xaa
ffffffffc0202d50:	8587be23          	sd	s8,-1956(a5) # ffffffffc02ac5a8 <free_area>
ffffffffc0202d54:	000aa797          	auipc	a5,0xaa
ffffffffc0202d58:	8577be23          	sd	s7,-1956(a5) # ffffffffc02ac5b0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0202d5c:	000aa797          	auipc	a5,0xaa
ffffffffc0202d60:	8567ae23          	sw	s6,-1956(a5) # ffffffffc02ac5b8 <free_area+0x10>
    free_page(p);
ffffffffc0202d64:	227000ef          	jal	ra,ffffffffc020378a <free_pages>
    free_page(p1);
ffffffffc0202d68:	4585                	li	a1,1
ffffffffc0202d6a:	8556                	mv	a0,s5
ffffffffc0202d6c:	21f000ef          	jal	ra,ffffffffc020378a <free_pages>
    free_page(p2);
ffffffffc0202d70:	4585                	li	a1,1
ffffffffc0202d72:	8552                	mv	a0,s4
ffffffffc0202d74:	217000ef          	jal	ra,ffffffffc020378a <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202d78:	4515                	li	a0,5
ffffffffc0202d7a:	189000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202d7e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202d80:	28050363          	beqz	a0,ffffffffc0203006 <default_check+0x452>
ffffffffc0202d84:	651c                	ld	a5,8(a0)
ffffffffc0202d86:	8385                	srli	a5,a5,0x1
ffffffffc0202d88:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0202d8a:	54079e63          	bnez	a5,ffffffffc02032e6 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202d8e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202d90:	00093b03          	ld	s6,0(s2)
ffffffffc0202d94:	00893a83          	ld	s5,8(s2)
ffffffffc0202d98:	000aa797          	auipc	a5,0xaa
ffffffffc0202d9c:	8127b823          	sd	s2,-2032(a5) # ffffffffc02ac5a8 <free_area>
ffffffffc0202da0:	000aa797          	auipc	a5,0xaa
ffffffffc0202da4:	8127b823          	sd	s2,-2032(a5) # ffffffffc02ac5b0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0202da8:	15b000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202dac:	50051d63          	bnez	a0,ffffffffc02032c6 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202db0:	08098a13          	addi	s4,s3,128
ffffffffc0202db4:	8552                	mv	a0,s4
ffffffffc0202db6:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202db8:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0202dbc:	000a9797          	auipc	a5,0xa9
ffffffffc0202dc0:	7e07ae23          	sw	zero,2044(a5) # ffffffffc02ac5b8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202dc4:	1c7000ef          	jal	ra,ffffffffc020378a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202dc8:	4511                	li	a0,4
ffffffffc0202dca:	139000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202dce:	4c051c63          	bnez	a0,ffffffffc02032a6 <default_check+0x6f2>
ffffffffc0202dd2:	0889b783          	ld	a5,136(s3)
ffffffffc0202dd6:	8385                	srli	a5,a5,0x1
ffffffffc0202dd8:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202dda:	4a078663          	beqz	a5,ffffffffc0203286 <default_check+0x6d2>
ffffffffc0202dde:	0909a703          	lw	a4,144(s3)
ffffffffc0202de2:	478d                	li	a5,3
ffffffffc0202de4:	4af71163          	bne	a4,a5,ffffffffc0203286 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202de8:	450d                	li	a0,3
ffffffffc0202dea:	119000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202dee:	8c2a                	mv	s8,a0
ffffffffc0202df0:	46050b63          	beqz	a0,ffffffffc0203266 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0202df4:	4505                	li	a0,1
ffffffffc0202df6:	10d000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202dfa:	44051663          	bnez	a0,ffffffffc0203246 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0202dfe:	438a1463          	bne	s4,s8,ffffffffc0203226 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202e02:	4585                	li	a1,1
ffffffffc0202e04:	854e                	mv	a0,s3
ffffffffc0202e06:	185000ef          	jal	ra,ffffffffc020378a <free_pages>
    free_pages(p1, 3);
ffffffffc0202e0a:	458d                	li	a1,3
ffffffffc0202e0c:	8552                	mv	a0,s4
ffffffffc0202e0e:	17d000ef          	jal	ra,ffffffffc020378a <free_pages>
ffffffffc0202e12:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202e16:	04098c13          	addi	s8,s3,64
ffffffffc0202e1a:	8385                	srli	a5,a5,0x1
ffffffffc0202e1c:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202e1e:	3e078463          	beqz	a5,ffffffffc0203206 <default_check+0x652>
ffffffffc0202e22:	0109a703          	lw	a4,16(s3)
ffffffffc0202e26:	4785                	li	a5,1
ffffffffc0202e28:	3cf71f63          	bne	a4,a5,ffffffffc0203206 <default_check+0x652>
ffffffffc0202e2c:	008a3783          	ld	a5,8(s4)
ffffffffc0202e30:	8385                	srli	a5,a5,0x1
ffffffffc0202e32:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202e34:	3a078963          	beqz	a5,ffffffffc02031e6 <default_check+0x632>
ffffffffc0202e38:	010a2703          	lw	a4,16(s4)
ffffffffc0202e3c:	478d                	li	a5,3
ffffffffc0202e3e:	3af71463          	bne	a4,a5,ffffffffc02031e6 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202e42:	4505                	li	a0,1
ffffffffc0202e44:	0bf000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202e48:	36a99f63          	bne	s3,a0,ffffffffc02031c6 <default_check+0x612>
    free_page(p0);
ffffffffc0202e4c:	4585                	li	a1,1
ffffffffc0202e4e:	13d000ef          	jal	ra,ffffffffc020378a <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202e52:	4509                	li	a0,2
ffffffffc0202e54:	0af000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202e58:	34aa1763          	bne	s4,a0,ffffffffc02031a6 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0202e5c:	4589                	li	a1,2
ffffffffc0202e5e:	12d000ef          	jal	ra,ffffffffc020378a <free_pages>
    free_page(p2);
ffffffffc0202e62:	4585                	li	a1,1
ffffffffc0202e64:	8562                	mv	a0,s8
ffffffffc0202e66:	125000ef          	jal	ra,ffffffffc020378a <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202e6a:	4515                	li	a0,5
ffffffffc0202e6c:	097000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202e70:	89aa                	mv	s3,a0
ffffffffc0202e72:	48050a63          	beqz	a0,ffffffffc0203306 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0202e76:	4505                	li	a0,1
ffffffffc0202e78:	08b000ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0202e7c:	2e051563          	bnez	a0,ffffffffc0203166 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0202e80:	01092783          	lw	a5,16(s2)
ffffffffc0202e84:	2c079163          	bnez	a5,ffffffffc0203146 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202e88:	4595                	li	a1,5
ffffffffc0202e8a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202e8c:	000a9797          	auipc	a5,0xa9
ffffffffc0202e90:	7377a623          	sw	s7,1836(a5) # ffffffffc02ac5b8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0202e94:	000a9797          	auipc	a5,0xa9
ffffffffc0202e98:	7167ba23          	sd	s6,1812(a5) # ffffffffc02ac5a8 <free_area>
ffffffffc0202e9c:	000a9797          	auipc	a5,0xa9
ffffffffc0202ea0:	7157ba23          	sd	s5,1812(a5) # ffffffffc02ac5b0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0202ea4:	0e7000ef          	jal	ra,ffffffffc020378a <free_pages>
    return listelm->next;
ffffffffc0202ea8:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202eac:	01278963          	beq	a5,s2,ffffffffc0202ebe <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202eb0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202eb4:	679c                	ld	a5,8(a5)
ffffffffc0202eb6:	34fd                	addiw	s1,s1,-1
ffffffffc0202eb8:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202eba:	ff279be3          	bne	a5,s2,ffffffffc0202eb0 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0202ebe:	26049463          	bnez	s1,ffffffffc0203126 <default_check+0x572>
    assert(total == 0);
ffffffffc0202ec2:	46041263          	bnez	s0,ffffffffc0203326 <default_check+0x772>
}
ffffffffc0202ec6:	60a6                	ld	ra,72(sp)
ffffffffc0202ec8:	6406                	ld	s0,64(sp)
ffffffffc0202eca:	74e2                	ld	s1,56(sp)
ffffffffc0202ecc:	7942                	ld	s2,48(sp)
ffffffffc0202ece:	79a2                	ld	s3,40(sp)
ffffffffc0202ed0:	7a02                	ld	s4,32(sp)
ffffffffc0202ed2:	6ae2                	ld	s5,24(sp)
ffffffffc0202ed4:	6b42                	ld	s6,16(sp)
ffffffffc0202ed6:	6ba2                	ld	s7,8(sp)
ffffffffc0202ed8:	6c02                	ld	s8,0(sp)
ffffffffc0202eda:	6161                	addi	sp,sp,80
ffffffffc0202edc:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202ede:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202ee0:	4401                	li	s0,0
ffffffffc0202ee2:	4481                	li	s1,0
ffffffffc0202ee4:	b30d                	j	ffffffffc0202c06 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0202ee6:	00005697          	auipc	a3,0x5
ffffffffc0202eea:	9da68693          	addi	a3,a3,-1574 # ffffffffc02078c0 <commands+0xfa8>
ffffffffc0202eee:	00004617          	auipc	a2,0x4
ffffffffc0202ef2:	eaa60613          	addi	a2,a2,-342 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202ef6:	0f000593          	li	a1,240
ffffffffc0202efa:	00005517          	auipc	a0,0x5
ffffffffc0202efe:	cc650513          	addi	a0,a0,-826 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0202f02:	b14fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202f06:	00005697          	auipc	a3,0x5
ffffffffc0202f0a:	d3268693          	addi	a3,a3,-718 # ffffffffc0207c38 <commands+0x1320>
ffffffffc0202f0e:	00004617          	auipc	a2,0x4
ffffffffc0202f12:	e8a60613          	addi	a2,a2,-374 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202f16:	0bd00593          	li	a1,189
ffffffffc0202f1a:	00005517          	auipc	a0,0x5
ffffffffc0202f1e:	ca650513          	addi	a0,a0,-858 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0202f22:	af4fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202f26:	00005697          	auipc	a3,0x5
ffffffffc0202f2a:	d3a68693          	addi	a3,a3,-710 # ffffffffc0207c60 <commands+0x1348>
ffffffffc0202f2e:	00004617          	auipc	a2,0x4
ffffffffc0202f32:	e6a60613          	addi	a2,a2,-406 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202f36:	0be00593          	li	a1,190
ffffffffc0202f3a:	00005517          	auipc	a0,0x5
ffffffffc0202f3e:	c8650513          	addi	a0,a0,-890 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0202f42:	ad4fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202f46:	00005697          	auipc	a3,0x5
ffffffffc0202f4a:	d5a68693          	addi	a3,a3,-678 # ffffffffc0207ca0 <commands+0x1388>
ffffffffc0202f4e:	00004617          	auipc	a2,0x4
ffffffffc0202f52:	e4a60613          	addi	a2,a2,-438 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202f56:	0c000593          	li	a1,192
ffffffffc0202f5a:	00005517          	auipc	a0,0x5
ffffffffc0202f5e:	c6650513          	addi	a0,a0,-922 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0202f62:	ab4fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202f66:	00005697          	auipc	a3,0x5
ffffffffc0202f6a:	dc268693          	addi	a3,a3,-574 # ffffffffc0207d28 <commands+0x1410>
ffffffffc0202f6e:	00004617          	auipc	a2,0x4
ffffffffc0202f72:	e2a60613          	addi	a2,a2,-470 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202f76:	0d900593          	li	a1,217
ffffffffc0202f7a:	00005517          	auipc	a0,0x5
ffffffffc0202f7e:	c4650513          	addi	a0,a0,-954 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0202f82:	a94fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202f86:	00005697          	auipc	a3,0x5
ffffffffc0202f8a:	c5268693          	addi	a3,a3,-942 # ffffffffc0207bd8 <commands+0x12c0>
ffffffffc0202f8e:	00004617          	auipc	a2,0x4
ffffffffc0202f92:	e0a60613          	addi	a2,a2,-502 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202f96:	0d200593          	li	a1,210
ffffffffc0202f9a:	00005517          	auipc	a0,0x5
ffffffffc0202f9e:	c2650513          	addi	a0,a0,-986 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0202fa2:	a74fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 3);
ffffffffc0202fa6:	00005697          	auipc	a3,0x5
ffffffffc0202faa:	d7268693          	addi	a3,a3,-654 # ffffffffc0207d18 <commands+0x1400>
ffffffffc0202fae:	00004617          	auipc	a2,0x4
ffffffffc0202fb2:	dea60613          	addi	a2,a2,-534 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202fb6:	0d000593          	li	a1,208
ffffffffc0202fba:	00005517          	auipc	a0,0x5
ffffffffc0202fbe:	c0650513          	addi	a0,a0,-1018 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0202fc2:	a54fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202fc6:	00005697          	auipc	a3,0x5
ffffffffc0202fca:	d3a68693          	addi	a3,a3,-710 # ffffffffc0207d00 <commands+0x13e8>
ffffffffc0202fce:	00004617          	auipc	a2,0x4
ffffffffc0202fd2:	dca60613          	addi	a2,a2,-566 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202fd6:	0cb00593          	li	a1,203
ffffffffc0202fda:	00005517          	auipc	a0,0x5
ffffffffc0202fde:	be650513          	addi	a0,a0,-1050 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0202fe2:	a34fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202fe6:	00005697          	auipc	a3,0x5
ffffffffc0202fea:	cfa68693          	addi	a3,a3,-774 # ffffffffc0207ce0 <commands+0x13c8>
ffffffffc0202fee:	00004617          	auipc	a2,0x4
ffffffffc0202ff2:	daa60613          	addi	a2,a2,-598 # ffffffffc0206d98 <commands+0x480>
ffffffffc0202ff6:	0c200593          	li	a1,194
ffffffffc0202ffa:	00005517          	auipc	a0,0x5
ffffffffc0202ffe:	bc650513          	addi	a0,a0,-1082 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203002:	a14fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != NULL);
ffffffffc0203006:	00005697          	auipc	a3,0x5
ffffffffc020300a:	d5a68693          	addi	a3,a3,-678 # ffffffffc0207d60 <commands+0x1448>
ffffffffc020300e:	00004617          	auipc	a2,0x4
ffffffffc0203012:	d8a60613          	addi	a2,a2,-630 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203016:	0f800593          	li	a1,248
ffffffffc020301a:	00005517          	auipc	a0,0x5
ffffffffc020301e:	ba650513          	addi	a0,a0,-1114 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203022:	9f4fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc0203026:	00005697          	auipc	a3,0x5
ffffffffc020302a:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0207a60 <commands+0x1148>
ffffffffc020302e:	00004617          	auipc	a2,0x4
ffffffffc0203032:	d6a60613          	addi	a2,a2,-662 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203036:	0df00593          	li	a1,223
ffffffffc020303a:	00005517          	auipc	a0,0x5
ffffffffc020303e:	b8650513          	addi	a0,a0,-1146 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203042:	9d4fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203046:	00005697          	auipc	a3,0x5
ffffffffc020304a:	cba68693          	addi	a3,a3,-838 # ffffffffc0207d00 <commands+0x13e8>
ffffffffc020304e:	00004617          	auipc	a2,0x4
ffffffffc0203052:	d4a60613          	addi	a2,a2,-694 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203056:	0dd00593          	li	a1,221
ffffffffc020305a:	00005517          	auipc	a0,0x5
ffffffffc020305e:	b6650513          	addi	a0,a0,-1178 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203062:	9b4fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0203066:	00005697          	auipc	a3,0x5
ffffffffc020306a:	cda68693          	addi	a3,a3,-806 # ffffffffc0207d40 <commands+0x1428>
ffffffffc020306e:	00004617          	auipc	a2,0x4
ffffffffc0203072:	d2a60613          	addi	a2,a2,-726 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203076:	0dc00593          	li	a1,220
ffffffffc020307a:	00005517          	auipc	a0,0x5
ffffffffc020307e:	b4650513          	addi	a0,a0,-1210 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203082:	994fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203086:	00005697          	auipc	a3,0x5
ffffffffc020308a:	b5268693          	addi	a3,a3,-1198 # ffffffffc0207bd8 <commands+0x12c0>
ffffffffc020308e:	00004617          	auipc	a2,0x4
ffffffffc0203092:	d0a60613          	addi	a2,a2,-758 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203096:	0b900593          	li	a1,185
ffffffffc020309a:	00005517          	auipc	a0,0x5
ffffffffc020309e:	b2650513          	addi	a0,a0,-1242 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc02030a2:	974fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02030a6:	00005697          	auipc	a3,0x5
ffffffffc02030aa:	c5a68693          	addi	a3,a3,-934 # ffffffffc0207d00 <commands+0x13e8>
ffffffffc02030ae:	00004617          	auipc	a2,0x4
ffffffffc02030b2:	cea60613          	addi	a2,a2,-790 # ffffffffc0206d98 <commands+0x480>
ffffffffc02030b6:	0d600593          	li	a1,214
ffffffffc02030ba:	00005517          	auipc	a0,0x5
ffffffffc02030be:	b0650513          	addi	a0,a0,-1274 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc02030c2:	954fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02030c6:	00005697          	auipc	a3,0x5
ffffffffc02030ca:	b5268693          	addi	a3,a3,-1198 # ffffffffc0207c18 <commands+0x1300>
ffffffffc02030ce:	00004617          	auipc	a2,0x4
ffffffffc02030d2:	cca60613          	addi	a2,a2,-822 # ffffffffc0206d98 <commands+0x480>
ffffffffc02030d6:	0d400593          	li	a1,212
ffffffffc02030da:	00005517          	auipc	a0,0x5
ffffffffc02030de:	ae650513          	addi	a0,a0,-1306 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc02030e2:	934fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02030e6:	00005697          	auipc	a3,0x5
ffffffffc02030ea:	b1268693          	addi	a3,a3,-1262 # ffffffffc0207bf8 <commands+0x12e0>
ffffffffc02030ee:	00004617          	auipc	a2,0x4
ffffffffc02030f2:	caa60613          	addi	a2,a2,-854 # ffffffffc0206d98 <commands+0x480>
ffffffffc02030f6:	0d300593          	li	a1,211
ffffffffc02030fa:	00005517          	auipc	a0,0x5
ffffffffc02030fe:	ac650513          	addi	a0,a0,-1338 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203102:	914fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203106:	00005697          	auipc	a3,0x5
ffffffffc020310a:	b1268693          	addi	a3,a3,-1262 # ffffffffc0207c18 <commands+0x1300>
ffffffffc020310e:	00004617          	auipc	a2,0x4
ffffffffc0203112:	c8a60613          	addi	a2,a2,-886 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203116:	0bb00593          	li	a1,187
ffffffffc020311a:	00005517          	auipc	a0,0x5
ffffffffc020311e:	aa650513          	addi	a0,a0,-1370 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203122:	8f4fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(count == 0);
ffffffffc0203126:	00005697          	auipc	a3,0x5
ffffffffc020312a:	d8a68693          	addi	a3,a3,-630 # ffffffffc0207eb0 <commands+0x1598>
ffffffffc020312e:	00004617          	auipc	a2,0x4
ffffffffc0203132:	c6a60613          	addi	a2,a2,-918 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203136:	12500593          	li	a1,293
ffffffffc020313a:	00005517          	auipc	a0,0x5
ffffffffc020313e:	a8650513          	addi	a0,a0,-1402 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203142:	8d4fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc0203146:	00005697          	auipc	a3,0x5
ffffffffc020314a:	91a68693          	addi	a3,a3,-1766 # ffffffffc0207a60 <commands+0x1148>
ffffffffc020314e:	00004617          	auipc	a2,0x4
ffffffffc0203152:	c4a60613          	addi	a2,a2,-950 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203156:	11a00593          	li	a1,282
ffffffffc020315a:	00005517          	auipc	a0,0x5
ffffffffc020315e:	a6650513          	addi	a0,a0,-1434 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203162:	8b4fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203166:	00005697          	auipc	a3,0x5
ffffffffc020316a:	b9a68693          	addi	a3,a3,-1126 # ffffffffc0207d00 <commands+0x13e8>
ffffffffc020316e:	00004617          	auipc	a2,0x4
ffffffffc0203172:	c2a60613          	addi	a2,a2,-982 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203176:	11800593          	li	a1,280
ffffffffc020317a:	00005517          	auipc	a0,0x5
ffffffffc020317e:	a4650513          	addi	a0,a0,-1466 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203182:	894fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203186:	00005697          	auipc	a3,0x5
ffffffffc020318a:	b3a68693          	addi	a3,a3,-1222 # ffffffffc0207cc0 <commands+0x13a8>
ffffffffc020318e:	00004617          	auipc	a2,0x4
ffffffffc0203192:	c0a60613          	addi	a2,a2,-1014 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203196:	0c100593          	li	a1,193
ffffffffc020319a:	00005517          	auipc	a0,0x5
ffffffffc020319e:	a2650513          	addi	a0,a0,-1498 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc02031a2:	874fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02031a6:	00005697          	auipc	a3,0x5
ffffffffc02031aa:	cca68693          	addi	a3,a3,-822 # ffffffffc0207e70 <commands+0x1558>
ffffffffc02031ae:	00004617          	auipc	a2,0x4
ffffffffc02031b2:	bea60613          	addi	a2,a2,-1046 # ffffffffc0206d98 <commands+0x480>
ffffffffc02031b6:	11200593          	li	a1,274
ffffffffc02031ba:	00005517          	auipc	a0,0x5
ffffffffc02031be:	a0650513          	addi	a0,a0,-1530 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc02031c2:	854fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02031c6:	00005697          	auipc	a3,0x5
ffffffffc02031ca:	c8a68693          	addi	a3,a3,-886 # ffffffffc0207e50 <commands+0x1538>
ffffffffc02031ce:	00004617          	auipc	a2,0x4
ffffffffc02031d2:	bca60613          	addi	a2,a2,-1078 # ffffffffc0206d98 <commands+0x480>
ffffffffc02031d6:	11000593          	li	a1,272
ffffffffc02031da:	00005517          	auipc	a0,0x5
ffffffffc02031de:	9e650513          	addi	a0,a0,-1562 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc02031e2:	834fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02031e6:	00005697          	auipc	a3,0x5
ffffffffc02031ea:	c4268693          	addi	a3,a3,-958 # ffffffffc0207e28 <commands+0x1510>
ffffffffc02031ee:	00004617          	auipc	a2,0x4
ffffffffc02031f2:	baa60613          	addi	a2,a2,-1110 # ffffffffc0206d98 <commands+0x480>
ffffffffc02031f6:	10e00593          	li	a1,270
ffffffffc02031fa:	00005517          	auipc	a0,0x5
ffffffffc02031fe:	9c650513          	addi	a0,a0,-1594 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203202:	814fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203206:	00005697          	auipc	a3,0x5
ffffffffc020320a:	bfa68693          	addi	a3,a3,-1030 # ffffffffc0207e00 <commands+0x14e8>
ffffffffc020320e:	00004617          	auipc	a2,0x4
ffffffffc0203212:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203216:	10d00593          	li	a1,269
ffffffffc020321a:	00005517          	auipc	a0,0x5
ffffffffc020321e:	9a650513          	addi	a0,a0,-1626 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203222:	ff5fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0203226:	00005697          	auipc	a3,0x5
ffffffffc020322a:	bca68693          	addi	a3,a3,-1078 # ffffffffc0207df0 <commands+0x14d8>
ffffffffc020322e:	00004617          	auipc	a2,0x4
ffffffffc0203232:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203236:	10800593          	li	a1,264
ffffffffc020323a:	00005517          	auipc	a0,0x5
ffffffffc020323e:	98650513          	addi	a0,a0,-1658 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203242:	fd5fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203246:	00005697          	auipc	a3,0x5
ffffffffc020324a:	aba68693          	addi	a3,a3,-1350 # ffffffffc0207d00 <commands+0x13e8>
ffffffffc020324e:	00004617          	auipc	a2,0x4
ffffffffc0203252:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203256:	10700593          	li	a1,263
ffffffffc020325a:	00005517          	auipc	a0,0x5
ffffffffc020325e:	96650513          	addi	a0,a0,-1690 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203262:	fb5fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203266:	00005697          	auipc	a3,0x5
ffffffffc020326a:	b6a68693          	addi	a3,a3,-1174 # ffffffffc0207dd0 <commands+0x14b8>
ffffffffc020326e:	00004617          	auipc	a2,0x4
ffffffffc0203272:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203276:	10600593          	li	a1,262
ffffffffc020327a:	00005517          	auipc	a0,0x5
ffffffffc020327e:	94650513          	addi	a0,a0,-1722 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203282:	f95fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203286:	00005697          	auipc	a3,0x5
ffffffffc020328a:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0207da0 <commands+0x1488>
ffffffffc020328e:	00004617          	auipc	a2,0x4
ffffffffc0203292:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203296:	10500593          	li	a1,261
ffffffffc020329a:	00005517          	auipc	a0,0x5
ffffffffc020329e:	92650513          	addi	a0,a0,-1754 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc02032a2:	f75fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02032a6:	00005697          	auipc	a3,0x5
ffffffffc02032aa:	ae268693          	addi	a3,a3,-1310 # ffffffffc0207d88 <commands+0x1470>
ffffffffc02032ae:	00004617          	auipc	a2,0x4
ffffffffc02032b2:	aea60613          	addi	a2,a2,-1302 # ffffffffc0206d98 <commands+0x480>
ffffffffc02032b6:	10400593          	li	a1,260
ffffffffc02032ba:	00005517          	auipc	a0,0x5
ffffffffc02032be:	90650513          	addi	a0,a0,-1786 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc02032c2:	f55fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02032c6:	00005697          	auipc	a3,0x5
ffffffffc02032ca:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0207d00 <commands+0x13e8>
ffffffffc02032ce:	00004617          	auipc	a2,0x4
ffffffffc02032d2:	aca60613          	addi	a2,a2,-1334 # ffffffffc0206d98 <commands+0x480>
ffffffffc02032d6:	0fe00593          	li	a1,254
ffffffffc02032da:	00005517          	auipc	a0,0x5
ffffffffc02032de:	8e650513          	addi	a0,a0,-1818 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc02032e2:	f35fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!PageProperty(p0));
ffffffffc02032e6:	00005697          	auipc	a3,0x5
ffffffffc02032ea:	a8a68693          	addi	a3,a3,-1398 # ffffffffc0207d70 <commands+0x1458>
ffffffffc02032ee:	00004617          	auipc	a2,0x4
ffffffffc02032f2:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0206d98 <commands+0x480>
ffffffffc02032f6:	0f900593          	li	a1,249
ffffffffc02032fa:	00005517          	auipc	a0,0x5
ffffffffc02032fe:	8c650513          	addi	a0,a0,-1850 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203302:	f15fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203306:	00005697          	auipc	a3,0x5
ffffffffc020330a:	b8a68693          	addi	a3,a3,-1142 # ffffffffc0207e90 <commands+0x1578>
ffffffffc020330e:	00004617          	auipc	a2,0x4
ffffffffc0203312:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203316:	11700593          	li	a1,279
ffffffffc020331a:	00005517          	auipc	a0,0x5
ffffffffc020331e:	8a650513          	addi	a0,a0,-1882 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203322:	ef5fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == 0);
ffffffffc0203326:	00005697          	auipc	a3,0x5
ffffffffc020332a:	b9a68693          	addi	a3,a3,-1126 # ffffffffc0207ec0 <commands+0x15a8>
ffffffffc020332e:	00004617          	auipc	a2,0x4
ffffffffc0203332:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203336:	12600593          	li	a1,294
ffffffffc020333a:	00005517          	auipc	a0,0x5
ffffffffc020333e:	88650513          	addi	a0,a0,-1914 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203342:	ed5fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == nr_free_pages());
ffffffffc0203346:	00004697          	auipc	a3,0x4
ffffffffc020334a:	58a68693          	addi	a3,a3,1418 # ffffffffc02078d0 <commands+0xfb8>
ffffffffc020334e:	00004617          	auipc	a2,0x4
ffffffffc0203352:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203356:	0f300593          	li	a1,243
ffffffffc020335a:	00005517          	auipc	a0,0x5
ffffffffc020335e:	86650513          	addi	a0,a0,-1946 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203362:	eb5fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203366:	00005697          	auipc	a3,0x5
ffffffffc020336a:	89268693          	addi	a3,a3,-1902 # ffffffffc0207bf8 <commands+0x12e0>
ffffffffc020336e:	00004617          	auipc	a2,0x4
ffffffffc0203372:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203376:	0ba00593          	li	a1,186
ffffffffc020337a:	00005517          	auipc	a0,0x5
ffffffffc020337e:	84650513          	addi	a0,a0,-1978 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203382:	e95fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203386 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203386:	1141                	addi	sp,sp,-16
ffffffffc0203388:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020338a:	16058e63          	beqz	a1,ffffffffc0203506 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc020338e:	00659693          	slli	a3,a1,0x6
ffffffffc0203392:	96aa                	add	a3,a3,a0
ffffffffc0203394:	02d50d63          	beq	a0,a3,ffffffffc02033ce <default_free_pages+0x48>
ffffffffc0203398:	651c                	ld	a5,8(a0)
ffffffffc020339a:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020339c:	14079563          	bnez	a5,ffffffffc02034e6 <default_free_pages+0x160>
ffffffffc02033a0:	651c                	ld	a5,8(a0)
ffffffffc02033a2:	8385                	srli	a5,a5,0x1
ffffffffc02033a4:	8b85                	andi	a5,a5,1
ffffffffc02033a6:	14079063          	bnez	a5,ffffffffc02034e6 <default_free_pages+0x160>
ffffffffc02033aa:	87aa                	mv	a5,a0
ffffffffc02033ac:	a809                	j	ffffffffc02033be <default_free_pages+0x38>
ffffffffc02033ae:	6798                	ld	a4,8(a5)
ffffffffc02033b0:	8b05                	andi	a4,a4,1
ffffffffc02033b2:	12071a63          	bnez	a4,ffffffffc02034e6 <default_free_pages+0x160>
ffffffffc02033b6:	6798                	ld	a4,8(a5)
ffffffffc02033b8:	8b09                	andi	a4,a4,2
ffffffffc02033ba:	12071663          	bnez	a4,ffffffffc02034e6 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02033be:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02033c2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02033c6:	04078793          	addi	a5,a5,64
ffffffffc02033ca:	fed792e3          	bne	a5,a3,ffffffffc02033ae <default_free_pages+0x28>
    base->property = n;
ffffffffc02033ce:	2581                	sext.w	a1,a1
ffffffffc02033d0:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02033d2:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02033d6:	4789                	li	a5,2
ffffffffc02033d8:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02033dc:	000a9697          	auipc	a3,0xa9
ffffffffc02033e0:	1cc68693          	addi	a3,a3,460 # ffffffffc02ac5a8 <free_area>
ffffffffc02033e4:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02033e6:	669c                	ld	a5,8(a3)
ffffffffc02033e8:	9db9                	addw	a1,a1,a4
ffffffffc02033ea:	000a9717          	auipc	a4,0xa9
ffffffffc02033ee:	1cb72723          	sw	a1,462(a4) # ffffffffc02ac5b8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02033f2:	0cd78163          	beq	a5,a3,ffffffffc02034b4 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02033f6:	fe878713          	addi	a4,a5,-24
ffffffffc02033fa:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02033fc:	4801                	li	a6,0
ffffffffc02033fe:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0203402:	00e56a63          	bltu	a0,a4,ffffffffc0203416 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0203406:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203408:	04d70f63          	beq	a4,a3,ffffffffc0203466 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020340c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020340e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203412:	fee57ae3          	bleu	a4,a0,ffffffffc0203406 <default_free_pages+0x80>
ffffffffc0203416:	00080663          	beqz	a6,ffffffffc0203422 <default_free_pages+0x9c>
ffffffffc020341a:	000a9817          	auipc	a6,0xa9
ffffffffc020341e:	18b83723          	sd	a1,398(a6) # ffffffffc02ac5a8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203422:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203424:	e390                	sd	a2,0(a5)
ffffffffc0203426:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0203428:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020342a:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc020342c:	06d58a63          	beq	a1,a3,ffffffffc02034a0 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0203430:	ff85a603          	lw	a2,-8(a1) # ff8 <_binary_obj___user_faultread_out_size-0x8580>
        p = le2page(le, page_link);
ffffffffc0203434:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0203438:	02061793          	slli	a5,a2,0x20
ffffffffc020343c:	83e9                	srli	a5,a5,0x1a
ffffffffc020343e:	97ba                	add	a5,a5,a4
ffffffffc0203440:	04f51b63          	bne	a0,a5,ffffffffc0203496 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0203444:	491c                	lw	a5,16(a0)
ffffffffc0203446:	9e3d                	addw	a2,a2,a5
ffffffffc0203448:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020344c:	57f5                	li	a5,-3
ffffffffc020344e:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203452:	01853803          	ld	a6,24(a0)
ffffffffc0203456:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0203458:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc020345a:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc020345e:	659c                	ld	a5,8(a1)
ffffffffc0203460:	01063023          	sd	a6,0(a2)
ffffffffc0203464:	a815                	j	ffffffffc0203498 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0203466:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203468:	f114                	sd	a3,32(a0)
ffffffffc020346a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020346c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020346e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203470:	00d70563          	beq	a4,a3,ffffffffc020347a <default_free_pages+0xf4>
ffffffffc0203474:	4805                	li	a6,1
ffffffffc0203476:	87ba                	mv	a5,a4
ffffffffc0203478:	bf59                	j	ffffffffc020340e <default_free_pages+0x88>
ffffffffc020347a:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020347c:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020347e:	00d78d63          	beq	a5,a3,ffffffffc0203498 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0203482:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0203486:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020348a:	02061793          	slli	a5,a2,0x20
ffffffffc020348e:	83e9                	srli	a5,a5,0x1a
ffffffffc0203490:	97ba                	add	a5,a5,a4
ffffffffc0203492:	faf509e3          	beq	a0,a5,ffffffffc0203444 <default_free_pages+0xbe>
ffffffffc0203496:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0203498:	fe878713          	addi	a4,a5,-24
ffffffffc020349c:	00d78963          	beq	a5,a3,ffffffffc02034ae <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc02034a0:	4910                	lw	a2,16(a0)
ffffffffc02034a2:	02061693          	slli	a3,a2,0x20
ffffffffc02034a6:	82e9                	srli	a3,a3,0x1a
ffffffffc02034a8:	96aa                	add	a3,a3,a0
ffffffffc02034aa:	00d70e63          	beq	a4,a3,ffffffffc02034c6 <default_free_pages+0x140>
}
ffffffffc02034ae:	60a2                	ld	ra,8(sp)
ffffffffc02034b0:	0141                	addi	sp,sp,16
ffffffffc02034b2:	8082                	ret
ffffffffc02034b4:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02034b6:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02034ba:	e398                	sd	a4,0(a5)
ffffffffc02034bc:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02034be:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02034c0:	ed1c                	sd	a5,24(a0)
}
ffffffffc02034c2:	0141                	addi	sp,sp,16
ffffffffc02034c4:	8082                	ret
            base->property += p->property;
ffffffffc02034c6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02034ca:	ff078693          	addi	a3,a5,-16
ffffffffc02034ce:	9e39                	addw	a2,a2,a4
ffffffffc02034d0:	c910                	sw	a2,16(a0)
ffffffffc02034d2:	5775                	li	a4,-3
ffffffffc02034d4:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02034d8:	6398                	ld	a4,0(a5)
ffffffffc02034da:	679c                	ld	a5,8(a5)
}
ffffffffc02034dc:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02034de:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02034e0:	e398                	sd	a4,0(a5)
ffffffffc02034e2:	0141                	addi	sp,sp,16
ffffffffc02034e4:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02034e6:	00005697          	auipc	a3,0x5
ffffffffc02034ea:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0207ed0 <commands+0x15b8>
ffffffffc02034ee:	00004617          	auipc	a2,0x4
ffffffffc02034f2:	8aa60613          	addi	a2,a2,-1878 # ffffffffc0206d98 <commands+0x480>
ffffffffc02034f6:	08300593          	li	a1,131
ffffffffc02034fa:	00004517          	auipc	a0,0x4
ffffffffc02034fe:	6c650513          	addi	a0,a0,1734 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203502:	d15fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc0203506:	00005697          	auipc	a3,0x5
ffffffffc020350a:	9f268693          	addi	a3,a3,-1550 # ffffffffc0207ef8 <commands+0x15e0>
ffffffffc020350e:	00004617          	auipc	a2,0x4
ffffffffc0203512:	88a60613          	addi	a2,a2,-1910 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203516:	08000593          	li	a1,128
ffffffffc020351a:	00004517          	auipc	a0,0x4
ffffffffc020351e:	6a650513          	addi	a0,a0,1702 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc0203522:	cf5fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203526 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203526:	c959                	beqz	a0,ffffffffc02035bc <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0203528:	000a9597          	auipc	a1,0xa9
ffffffffc020352c:	08058593          	addi	a1,a1,128 # ffffffffc02ac5a8 <free_area>
ffffffffc0203530:	0105a803          	lw	a6,16(a1)
ffffffffc0203534:	862a                	mv	a2,a0
ffffffffc0203536:	02081793          	slli	a5,a6,0x20
ffffffffc020353a:	9381                	srli	a5,a5,0x20
ffffffffc020353c:	00a7ee63          	bltu	a5,a0,ffffffffc0203558 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203540:	87ae                	mv	a5,a1
ffffffffc0203542:	a801                	j	ffffffffc0203552 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203544:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203548:	02071693          	slli	a3,a4,0x20
ffffffffc020354c:	9281                	srli	a3,a3,0x20
ffffffffc020354e:	00c6f763          	bleu	a2,a3,ffffffffc020355c <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203552:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203554:	feb798e3          	bne	a5,a1,ffffffffc0203544 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0203558:	4501                	li	a0,0
}
ffffffffc020355a:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020355c:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0203560:	dd6d                	beqz	a0,ffffffffc020355a <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0203562:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203566:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020356a:	00060e1b          	sext.w	t3,a2
ffffffffc020356e:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203572:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0203576:	02d67863          	bleu	a3,a2,ffffffffc02035a6 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc020357a:	061a                	slli	a2,a2,0x6
ffffffffc020357c:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc020357e:	41c7073b          	subw	a4,a4,t3
ffffffffc0203582:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203584:	00860693          	addi	a3,a2,8
ffffffffc0203588:	4709                	li	a4,2
ffffffffc020358a:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc020358e:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203592:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0203596:	0105a803          	lw	a6,16(a1)
ffffffffc020359a:	e314                	sd	a3,0(a4)
ffffffffc020359c:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc02035a0:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc02035a2:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc02035a6:	41c8083b          	subw	a6,a6,t3
ffffffffc02035aa:	000a9717          	auipc	a4,0xa9
ffffffffc02035ae:	01072723          	sw	a6,14(a4) # ffffffffc02ac5b8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02035b2:	5775                	li	a4,-3
ffffffffc02035b4:	17c1                	addi	a5,a5,-16
ffffffffc02035b6:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02035ba:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02035bc:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02035be:	00005697          	auipc	a3,0x5
ffffffffc02035c2:	93a68693          	addi	a3,a3,-1734 # ffffffffc0207ef8 <commands+0x15e0>
ffffffffc02035c6:	00003617          	auipc	a2,0x3
ffffffffc02035ca:	7d260613          	addi	a2,a2,2002 # ffffffffc0206d98 <commands+0x480>
ffffffffc02035ce:	06200593          	li	a1,98
ffffffffc02035d2:	00004517          	auipc	a0,0x4
ffffffffc02035d6:	5ee50513          	addi	a0,a0,1518 # ffffffffc0207bc0 <commands+0x12a8>
default_alloc_pages(size_t n) {
ffffffffc02035da:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02035dc:	c3bfc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02035e0 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02035e0:	1141                	addi	sp,sp,-16
ffffffffc02035e2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02035e4:	c1ed                	beqz	a1,ffffffffc02036c6 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02035e6:	00659693          	slli	a3,a1,0x6
ffffffffc02035ea:	96aa                	add	a3,a3,a0
ffffffffc02035ec:	02d50463          	beq	a0,a3,ffffffffc0203614 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02035f0:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02035f2:	87aa                	mv	a5,a0
ffffffffc02035f4:	8b05                	andi	a4,a4,1
ffffffffc02035f6:	e709                	bnez	a4,ffffffffc0203600 <default_init_memmap+0x20>
ffffffffc02035f8:	a07d                	j	ffffffffc02036a6 <default_init_memmap+0xc6>
ffffffffc02035fa:	6798                	ld	a4,8(a5)
ffffffffc02035fc:	8b05                	andi	a4,a4,1
ffffffffc02035fe:	c745                	beqz	a4,ffffffffc02036a6 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0203600:	0007a823          	sw	zero,16(a5)
ffffffffc0203604:	0007b423          	sd	zero,8(a5)
ffffffffc0203608:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020360c:	04078793          	addi	a5,a5,64
ffffffffc0203610:	fed795e3          	bne	a5,a3,ffffffffc02035fa <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0203614:	2581                	sext.w	a1,a1
ffffffffc0203616:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203618:	4789                	li	a5,2
ffffffffc020361a:	00850713          	addi	a4,a0,8
ffffffffc020361e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0203622:	000a9697          	auipc	a3,0xa9
ffffffffc0203626:	f8668693          	addi	a3,a3,-122 # ffffffffc02ac5a8 <free_area>
ffffffffc020362a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020362c:	669c                	ld	a5,8(a3)
ffffffffc020362e:	9db9                	addw	a1,a1,a4
ffffffffc0203630:	000a9717          	auipc	a4,0xa9
ffffffffc0203634:	f8b72423          	sw	a1,-120(a4) # ffffffffc02ac5b8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203638:	04d78a63          	beq	a5,a3,ffffffffc020368c <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc020363c:	fe878713          	addi	a4,a5,-24
ffffffffc0203640:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203642:	4801                	li	a6,0
ffffffffc0203644:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0203648:	00e56a63          	bltu	a0,a4,ffffffffc020365c <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc020364c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020364e:	02d70563          	beq	a4,a3,ffffffffc0203678 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203652:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203654:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203658:	fee57ae3          	bleu	a4,a0,ffffffffc020364c <default_init_memmap+0x6c>
ffffffffc020365c:	00080663          	beqz	a6,ffffffffc0203668 <default_init_memmap+0x88>
ffffffffc0203660:	000a9717          	auipc	a4,0xa9
ffffffffc0203664:	f4b73423          	sd	a1,-184(a4) # ffffffffc02ac5a8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203668:	6398                	ld	a4,0(a5)
}
ffffffffc020366a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020366c:	e390                	sd	a2,0(a5)
ffffffffc020366e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203670:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203672:	ed18                	sd	a4,24(a0)
ffffffffc0203674:	0141                	addi	sp,sp,16
ffffffffc0203676:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203678:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020367a:	f114                	sd	a3,32(a0)
ffffffffc020367c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020367e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0203680:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203682:	00d70e63          	beq	a4,a3,ffffffffc020369e <default_init_memmap+0xbe>
ffffffffc0203686:	4805                	li	a6,1
ffffffffc0203688:	87ba                	mv	a5,a4
ffffffffc020368a:	b7e9                	j	ffffffffc0203654 <default_init_memmap+0x74>
}
ffffffffc020368c:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020368e:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0203692:	e398                	sd	a4,0(a5)
ffffffffc0203694:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203696:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203698:	ed1c                	sd	a5,24(a0)
}
ffffffffc020369a:	0141                	addi	sp,sp,16
ffffffffc020369c:	8082                	ret
ffffffffc020369e:	60a2                	ld	ra,8(sp)
ffffffffc02036a0:	e290                	sd	a2,0(a3)
ffffffffc02036a2:	0141                	addi	sp,sp,16
ffffffffc02036a4:	8082                	ret
        assert(PageReserved(p));
ffffffffc02036a6:	00005697          	auipc	a3,0x5
ffffffffc02036aa:	85a68693          	addi	a3,a3,-1958 # ffffffffc0207f00 <commands+0x15e8>
ffffffffc02036ae:	00003617          	auipc	a2,0x3
ffffffffc02036b2:	6ea60613          	addi	a2,a2,1770 # ffffffffc0206d98 <commands+0x480>
ffffffffc02036b6:	04900593          	li	a1,73
ffffffffc02036ba:	00004517          	auipc	a0,0x4
ffffffffc02036be:	50650513          	addi	a0,a0,1286 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc02036c2:	b55fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc02036c6:	00005697          	auipc	a3,0x5
ffffffffc02036ca:	83268693          	addi	a3,a3,-1998 # ffffffffc0207ef8 <commands+0x15e0>
ffffffffc02036ce:	00003617          	auipc	a2,0x3
ffffffffc02036d2:	6ca60613          	addi	a2,a2,1738 # ffffffffc0206d98 <commands+0x480>
ffffffffc02036d6:	04600593          	li	a1,70
ffffffffc02036da:	00004517          	auipc	a0,0x4
ffffffffc02036de:	4e650513          	addi	a0,a0,1254 # ffffffffc0207bc0 <commands+0x12a8>
ffffffffc02036e2:	b35fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02036e6 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc02036e6:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02036e8:	00004617          	auipc	a2,0x4
ffffffffc02036ec:	e0060613          	addi	a2,a2,-512 # ffffffffc02074e8 <commands+0xbd0>
ffffffffc02036f0:	06200593          	li	a1,98
ffffffffc02036f4:	00004517          	auipc	a0,0x4
ffffffffc02036f8:	e1450513          	addi	a0,a0,-492 # ffffffffc0207508 <commands+0xbf0>
pa2page(uintptr_t pa) {
ffffffffc02036fc:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02036fe:	b19fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203702 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0203702:	715d                	addi	sp,sp,-80
ffffffffc0203704:	e0a2                	sd	s0,64(sp)
ffffffffc0203706:	fc26                	sd	s1,56(sp)
ffffffffc0203708:	f84a                	sd	s2,48(sp)
ffffffffc020370a:	f44e                	sd	s3,40(sp)
ffffffffc020370c:	f052                	sd	s4,32(sp)
ffffffffc020370e:	ec56                	sd	s5,24(sp)
ffffffffc0203710:	e486                	sd	ra,72(sp)
ffffffffc0203712:	842a                	mv	s0,a0
ffffffffc0203714:	000a9497          	auipc	s1,0xa9
ffffffffc0203718:	eac48493          	addi	s1,s1,-340 # ffffffffc02ac5c0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020371c:	4985                	li	s3,1
ffffffffc020371e:	000a9a17          	auipc	s4,0xa9
ffffffffc0203722:	d6aa0a13          	addi	s4,s4,-662 # ffffffffc02ac488 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0203726:	0005091b          	sext.w	s2,a0
ffffffffc020372a:	000a9a97          	auipc	s5,0xa9
ffffffffc020372e:	d9ea8a93          	addi	s5,s5,-610 # ffffffffc02ac4c8 <check_mm_struct>
ffffffffc0203732:	a00d                	j	ffffffffc0203754 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0203734:	609c                	ld	a5,0(s1)
ffffffffc0203736:	6f9c                	ld	a5,24(a5)
ffffffffc0203738:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc020373a:	4601                	li	a2,0
ffffffffc020373c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020373e:	ed0d                	bnez	a0,ffffffffc0203778 <alloc_pages+0x76>
ffffffffc0203740:	0289ec63          	bltu	s3,s0,ffffffffc0203778 <alloc_pages+0x76>
ffffffffc0203744:	000a2783          	lw	a5,0(s4)
ffffffffc0203748:	2781                	sext.w	a5,a5
ffffffffc020374a:	c79d                	beqz	a5,ffffffffc0203778 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc020374c:	000ab503          	ld	a0,0(s5)
ffffffffc0203750:	abaff0ef          	jal	ra,ffffffffc0202a0a <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203754:	100027f3          	csrr	a5,sstatus
ffffffffc0203758:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc020375a:	8522                	mv	a0,s0
ffffffffc020375c:	dfe1                	beqz	a5,ffffffffc0203734 <alloc_pages+0x32>
        intr_disable();
ffffffffc020375e:	efffc0ef          	jal	ra,ffffffffc020065c <intr_disable>
ffffffffc0203762:	609c                	ld	a5,0(s1)
ffffffffc0203764:	8522                	mv	a0,s0
ffffffffc0203766:	6f9c                	ld	a5,24(a5)
ffffffffc0203768:	9782                	jalr	a5
ffffffffc020376a:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020376c:	eebfc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc0203770:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0203772:	4601                	li	a2,0
ffffffffc0203774:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0203776:	d569                	beqz	a0,ffffffffc0203740 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0203778:	60a6                	ld	ra,72(sp)
ffffffffc020377a:	6406                	ld	s0,64(sp)
ffffffffc020377c:	74e2                	ld	s1,56(sp)
ffffffffc020377e:	7942                	ld	s2,48(sp)
ffffffffc0203780:	79a2                	ld	s3,40(sp)
ffffffffc0203782:	7a02                	ld	s4,32(sp)
ffffffffc0203784:	6ae2                	ld	s5,24(sp)
ffffffffc0203786:	6161                	addi	sp,sp,80
ffffffffc0203788:	8082                	ret

ffffffffc020378a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020378a:	100027f3          	csrr	a5,sstatus
ffffffffc020378e:	8b89                	andi	a5,a5,2
ffffffffc0203790:	eb89                	bnez	a5,ffffffffc02037a2 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0203792:	000a9797          	auipc	a5,0xa9
ffffffffc0203796:	e2e78793          	addi	a5,a5,-466 # ffffffffc02ac5c0 <pmm_manager>
ffffffffc020379a:	639c                	ld	a5,0(a5)
ffffffffc020379c:	0207b303          	ld	t1,32(a5)
ffffffffc02037a0:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc02037a2:	1101                	addi	sp,sp,-32
ffffffffc02037a4:	ec06                	sd	ra,24(sp)
ffffffffc02037a6:	e822                	sd	s0,16(sp)
ffffffffc02037a8:	e426                	sd	s1,8(sp)
ffffffffc02037aa:	842a                	mv	s0,a0
ffffffffc02037ac:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02037ae:	eaffc0ef          	jal	ra,ffffffffc020065c <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02037b2:	000a9797          	auipc	a5,0xa9
ffffffffc02037b6:	e0e78793          	addi	a5,a5,-498 # ffffffffc02ac5c0 <pmm_manager>
ffffffffc02037ba:	639c                	ld	a5,0(a5)
ffffffffc02037bc:	85a6                	mv	a1,s1
ffffffffc02037be:	8522                	mv	a0,s0
ffffffffc02037c0:	739c                	ld	a5,32(a5)
ffffffffc02037c2:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02037c4:	6442                	ld	s0,16(sp)
ffffffffc02037c6:	60e2                	ld	ra,24(sp)
ffffffffc02037c8:	64a2                	ld	s1,8(sp)
ffffffffc02037ca:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02037cc:	e8bfc06f          	j	ffffffffc0200656 <intr_enable>

ffffffffc02037d0 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02037d0:	100027f3          	csrr	a5,sstatus
ffffffffc02037d4:	8b89                	andi	a5,a5,2
ffffffffc02037d6:	eb89                	bnez	a5,ffffffffc02037e8 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02037d8:	000a9797          	auipc	a5,0xa9
ffffffffc02037dc:	de878793          	addi	a5,a5,-536 # ffffffffc02ac5c0 <pmm_manager>
ffffffffc02037e0:	639c                	ld	a5,0(a5)
ffffffffc02037e2:	0287b303          	ld	t1,40(a5)
ffffffffc02037e6:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02037e8:	1141                	addi	sp,sp,-16
ffffffffc02037ea:	e406                	sd	ra,8(sp)
ffffffffc02037ec:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02037ee:	e6ffc0ef          	jal	ra,ffffffffc020065c <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02037f2:	000a9797          	auipc	a5,0xa9
ffffffffc02037f6:	dce78793          	addi	a5,a5,-562 # ffffffffc02ac5c0 <pmm_manager>
ffffffffc02037fa:	639c                	ld	a5,0(a5)
ffffffffc02037fc:	779c                	ld	a5,40(a5)
ffffffffc02037fe:	9782                	jalr	a5
ffffffffc0203800:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203802:	e55fc0ef          	jal	ra,ffffffffc0200656 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0203806:	8522                	mv	a0,s0
ffffffffc0203808:	60a2                	ld	ra,8(sp)
ffffffffc020380a:	6402                	ld	s0,0(sp)
ffffffffc020380c:	0141                	addi	sp,sp,16
ffffffffc020380e:	8082                	ret

ffffffffc0203810 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203810:	7139                	addi	sp,sp,-64
ffffffffc0203812:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0203814:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0203818:	1ff4f493          	andi	s1,s1,511
ffffffffc020381c:	048e                	slli	s1,s1,0x3
ffffffffc020381e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203820:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203822:	f04a                	sd	s2,32(sp)
ffffffffc0203824:	ec4e                	sd	s3,24(sp)
ffffffffc0203826:	e852                	sd	s4,16(sp)
ffffffffc0203828:	fc06                	sd	ra,56(sp)
ffffffffc020382a:	f822                	sd	s0,48(sp)
ffffffffc020382c:	e456                	sd	s5,8(sp)
ffffffffc020382e:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203830:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203834:	892e                	mv	s2,a1
ffffffffc0203836:	8a32                	mv	s4,a2
ffffffffc0203838:	000a9997          	auipc	s3,0xa9
ffffffffc020383c:	c6098993          	addi	s3,s3,-928 # ffffffffc02ac498 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0203840:	e7bd                	bnez	a5,ffffffffc02038ae <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203842:	12060c63          	beqz	a2,ffffffffc020397a <get_pte+0x16a>
ffffffffc0203846:	4505                	li	a0,1
ffffffffc0203848:	ebbff0ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc020384c:	842a                	mv	s0,a0
ffffffffc020384e:	12050663          	beqz	a0,ffffffffc020397a <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203852:	000a9b17          	auipc	s6,0xa9
ffffffffc0203856:	d86b0b13          	addi	s6,s6,-634 # ffffffffc02ac5d8 <pages>
ffffffffc020385a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020385e:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203860:	000a9997          	auipc	s3,0xa9
ffffffffc0203864:	c3898993          	addi	s3,s3,-968 # ffffffffc02ac498 <npage>
    return page - pages + nbase;
ffffffffc0203868:	40a40533          	sub	a0,s0,a0
ffffffffc020386c:	00080ab7          	lui	s5,0x80
ffffffffc0203870:	8519                	srai	a0,a0,0x6
ffffffffc0203872:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0203876:	c01c                	sw	a5,0(s0)
ffffffffc0203878:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020387a:	9556                	add	a0,a0,s5
ffffffffc020387c:	83b1                	srli	a5,a5,0xc
ffffffffc020387e:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203880:	0532                	slli	a0,a0,0xc
ffffffffc0203882:	14e7f363          	bleu	a4,a5,ffffffffc02039c8 <get_pte+0x1b8>
ffffffffc0203886:	000a9797          	auipc	a5,0xa9
ffffffffc020388a:	d4278793          	addi	a5,a5,-702 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc020388e:	639c                	ld	a5,0(a5)
ffffffffc0203890:	6605                	lui	a2,0x1
ffffffffc0203892:	4581                	li	a1,0
ffffffffc0203894:	953e                	add	a0,a0,a5
ffffffffc0203896:	2d7020ef          	jal	ra,ffffffffc020636c <memset>
    return page - pages + nbase;
ffffffffc020389a:	000b3683          	ld	a3,0(s6)
ffffffffc020389e:	40d406b3          	sub	a3,s0,a3
ffffffffc02038a2:	8699                	srai	a3,a3,0x6
ffffffffc02038a4:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02038a6:	06aa                	slli	a3,a3,0xa
ffffffffc02038a8:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02038ac:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02038ae:	77fd                	lui	a5,0xfffff
ffffffffc02038b0:	068a                	slli	a3,a3,0x2
ffffffffc02038b2:	0009b703          	ld	a4,0(s3)
ffffffffc02038b6:	8efd                	and	a3,a3,a5
ffffffffc02038b8:	00c6d793          	srli	a5,a3,0xc
ffffffffc02038bc:	0ce7f163          	bleu	a4,a5,ffffffffc020397e <get_pte+0x16e>
ffffffffc02038c0:	000a9a97          	auipc	s5,0xa9
ffffffffc02038c4:	d08a8a93          	addi	s5,s5,-760 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc02038c8:	000ab403          	ld	s0,0(s5)
ffffffffc02038cc:	01595793          	srli	a5,s2,0x15
ffffffffc02038d0:	1ff7f793          	andi	a5,a5,511
ffffffffc02038d4:	96a2                	add	a3,a3,s0
ffffffffc02038d6:	00379413          	slli	s0,a5,0x3
ffffffffc02038da:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc02038dc:	6014                	ld	a3,0(s0)
ffffffffc02038de:	0016f793          	andi	a5,a3,1
ffffffffc02038e2:	e3ad                	bnez	a5,ffffffffc0203944 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02038e4:	080a0b63          	beqz	s4,ffffffffc020397a <get_pte+0x16a>
ffffffffc02038e8:	4505                	li	a0,1
ffffffffc02038ea:	e19ff0ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc02038ee:	84aa                	mv	s1,a0
ffffffffc02038f0:	c549                	beqz	a0,ffffffffc020397a <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02038f2:	000a9b17          	auipc	s6,0xa9
ffffffffc02038f6:	ce6b0b13          	addi	s6,s6,-794 # ffffffffc02ac5d8 <pages>
ffffffffc02038fa:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc02038fe:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0203900:	00080a37          	lui	s4,0x80
ffffffffc0203904:	40a48533          	sub	a0,s1,a0
ffffffffc0203908:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020390a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020390e:	c09c                	sw	a5,0(s1)
ffffffffc0203910:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0203912:	9552                	add	a0,a0,s4
ffffffffc0203914:	83b1                	srli	a5,a5,0xc
ffffffffc0203916:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203918:	0532                	slli	a0,a0,0xc
ffffffffc020391a:	08e7fa63          	bleu	a4,a5,ffffffffc02039ae <get_pte+0x19e>
ffffffffc020391e:	000ab783          	ld	a5,0(s5)
ffffffffc0203922:	6605                	lui	a2,0x1
ffffffffc0203924:	4581                	li	a1,0
ffffffffc0203926:	953e                	add	a0,a0,a5
ffffffffc0203928:	245020ef          	jal	ra,ffffffffc020636c <memset>
    return page - pages + nbase;
ffffffffc020392c:	000b3683          	ld	a3,0(s6)
ffffffffc0203930:	40d486b3          	sub	a3,s1,a3
ffffffffc0203934:	8699                	srai	a3,a3,0x6
ffffffffc0203936:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203938:	06aa                	slli	a3,a3,0xa
ffffffffc020393a:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020393e:	e014                	sd	a3,0(s0)
ffffffffc0203940:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203944:	068a                	slli	a3,a3,0x2
ffffffffc0203946:	757d                	lui	a0,0xfffff
ffffffffc0203948:	8ee9                	and	a3,a3,a0
ffffffffc020394a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020394e:	04e7f463          	bleu	a4,a5,ffffffffc0203996 <get_pte+0x186>
ffffffffc0203952:	000ab503          	ld	a0,0(s5)
ffffffffc0203956:	00c95793          	srli	a5,s2,0xc
ffffffffc020395a:	1ff7f793          	andi	a5,a5,511
ffffffffc020395e:	96aa                	add	a3,a3,a0
ffffffffc0203960:	00379513          	slli	a0,a5,0x3
ffffffffc0203964:	9536                	add	a0,a0,a3
}
ffffffffc0203966:	70e2                	ld	ra,56(sp)
ffffffffc0203968:	7442                	ld	s0,48(sp)
ffffffffc020396a:	74a2                	ld	s1,40(sp)
ffffffffc020396c:	7902                	ld	s2,32(sp)
ffffffffc020396e:	69e2                	ld	s3,24(sp)
ffffffffc0203970:	6a42                	ld	s4,16(sp)
ffffffffc0203972:	6aa2                	ld	s5,8(sp)
ffffffffc0203974:	6b02                	ld	s6,0(sp)
ffffffffc0203976:	6121                	addi	sp,sp,64
ffffffffc0203978:	8082                	ret
            return NULL;
ffffffffc020397a:	4501                	li	a0,0
ffffffffc020397c:	b7ed                	j	ffffffffc0203966 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020397e:	00004617          	auipc	a2,0x4
ffffffffc0203982:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0207518 <commands+0xc00>
ffffffffc0203986:	0e300593          	li	a1,227
ffffffffc020398a:	00004517          	auipc	a0,0x4
ffffffffc020398e:	63650513          	addi	a0,a0,1590 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0203992:	885fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203996:	00004617          	auipc	a2,0x4
ffffffffc020399a:	b8260613          	addi	a2,a2,-1150 # ffffffffc0207518 <commands+0xc00>
ffffffffc020399e:	0ee00593          	li	a1,238
ffffffffc02039a2:	00004517          	auipc	a0,0x4
ffffffffc02039a6:	61e50513          	addi	a0,a0,1566 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02039aa:	86dfc0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02039ae:	86aa                	mv	a3,a0
ffffffffc02039b0:	00004617          	auipc	a2,0x4
ffffffffc02039b4:	b6860613          	addi	a2,a2,-1176 # ffffffffc0207518 <commands+0xc00>
ffffffffc02039b8:	0eb00593          	li	a1,235
ffffffffc02039bc:	00004517          	auipc	a0,0x4
ffffffffc02039c0:	60450513          	addi	a0,a0,1540 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02039c4:	853fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02039c8:	86aa                	mv	a3,a0
ffffffffc02039ca:	00004617          	auipc	a2,0x4
ffffffffc02039ce:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0207518 <commands+0xc00>
ffffffffc02039d2:	0df00593          	li	a1,223
ffffffffc02039d6:	00004517          	auipc	a0,0x4
ffffffffc02039da:	5ea50513          	addi	a0,a0,1514 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02039de:	839fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02039e2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02039e2:	1141                	addi	sp,sp,-16
ffffffffc02039e4:	e022                	sd	s0,0(sp)
ffffffffc02039e6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02039e8:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02039ea:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02039ec:	e25ff0ef          	jal	ra,ffffffffc0203810 <get_pte>
    if (ptep_store != NULL) {
ffffffffc02039f0:	c011                	beqz	s0,ffffffffc02039f4 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02039f2:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02039f4:	c129                	beqz	a0,ffffffffc0203a36 <get_page+0x54>
ffffffffc02039f6:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02039f8:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02039fa:	0017f713          	andi	a4,a5,1
ffffffffc02039fe:	e709                	bnez	a4,ffffffffc0203a08 <get_page+0x26>
}
ffffffffc0203a00:	60a2                	ld	ra,8(sp)
ffffffffc0203a02:	6402                	ld	s0,0(sp)
ffffffffc0203a04:	0141                	addi	sp,sp,16
ffffffffc0203a06:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0203a08:	000a9717          	auipc	a4,0xa9
ffffffffc0203a0c:	a9070713          	addi	a4,a4,-1392 # ffffffffc02ac498 <npage>
ffffffffc0203a10:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203a12:	078a                	slli	a5,a5,0x2
ffffffffc0203a14:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a16:	02e7f563          	bleu	a4,a5,ffffffffc0203a40 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a1a:	000a9717          	auipc	a4,0xa9
ffffffffc0203a1e:	bbe70713          	addi	a4,a4,-1090 # ffffffffc02ac5d8 <pages>
ffffffffc0203a22:	6308                	ld	a0,0(a4)
ffffffffc0203a24:	60a2                	ld	ra,8(sp)
ffffffffc0203a26:	6402                	ld	s0,0(sp)
ffffffffc0203a28:	fff80737          	lui	a4,0xfff80
ffffffffc0203a2c:	97ba                	add	a5,a5,a4
ffffffffc0203a2e:	079a                	slli	a5,a5,0x6
ffffffffc0203a30:	953e                	add	a0,a0,a5
ffffffffc0203a32:	0141                	addi	sp,sp,16
ffffffffc0203a34:	8082                	ret
ffffffffc0203a36:	60a2                	ld	ra,8(sp)
ffffffffc0203a38:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0203a3a:	4501                	li	a0,0
}
ffffffffc0203a3c:	0141                	addi	sp,sp,16
ffffffffc0203a3e:	8082                	ret
ffffffffc0203a40:	ca7ff0ef          	jal	ra,ffffffffc02036e6 <pa2page.part.4>

ffffffffc0203a44 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203a44:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203a46:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203a4a:	ec86                	sd	ra,88(sp)
ffffffffc0203a4c:	e8a2                	sd	s0,80(sp)
ffffffffc0203a4e:	e4a6                	sd	s1,72(sp)
ffffffffc0203a50:	e0ca                	sd	s2,64(sp)
ffffffffc0203a52:	fc4e                	sd	s3,56(sp)
ffffffffc0203a54:	f852                	sd	s4,48(sp)
ffffffffc0203a56:	f456                	sd	s5,40(sp)
ffffffffc0203a58:	f05a                	sd	s6,32(sp)
ffffffffc0203a5a:	ec5e                	sd	s7,24(sp)
ffffffffc0203a5c:	e862                	sd	s8,16(sp)
ffffffffc0203a5e:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203a60:	03479713          	slli	a4,a5,0x34
ffffffffc0203a64:	eb71                	bnez	a4,ffffffffc0203b38 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc0203a66:	002007b7          	lui	a5,0x200
ffffffffc0203a6a:	842e                	mv	s0,a1
ffffffffc0203a6c:	0af5e663          	bltu	a1,a5,ffffffffc0203b18 <unmap_range+0xd4>
ffffffffc0203a70:	8932                	mv	s2,a2
ffffffffc0203a72:	0ac5f363          	bleu	a2,a1,ffffffffc0203b18 <unmap_range+0xd4>
ffffffffc0203a76:	4785                	li	a5,1
ffffffffc0203a78:	07fe                	slli	a5,a5,0x1f
ffffffffc0203a7a:	08c7ef63          	bltu	a5,a2,ffffffffc0203b18 <unmap_range+0xd4>
ffffffffc0203a7e:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0203a80:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203a82:	000a9c97          	auipc	s9,0xa9
ffffffffc0203a86:	a16c8c93          	addi	s9,s9,-1514 # ffffffffc02ac498 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a8a:	000a9c17          	auipc	s8,0xa9
ffffffffc0203a8e:	b4ec0c13          	addi	s8,s8,-1202 # ffffffffc02ac5d8 <pages>
ffffffffc0203a92:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203a96:	00200b37          	lui	s6,0x200
ffffffffc0203a9a:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0203a9e:	4601                	li	a2,0
ffffffffc0203aa0:	85a2                	mv	a1,s0
ffffffffc0203aa2:	854e                	mv	a0,s3
ffffffffc0203aa4:	d6dff0ef          	jal	ra,ffffffffc0203810 <get_pte>
ffffffffc0203aa8:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0203aaa:	cd21                	beqz	a0,ffffffffc0203b02 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc0203aac:	611c                	ld	a5,0(a0)
ffffffffc0203aae:	e38d                	bnez	a5,ffffffffc0203ad0 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc0203ab0:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203ab2:	ff2466e3          	bltu	s0,s2,ffffffffc0203a9e <unmap_range+0x5a>
}
ffffffffc0203ab6:	60e6                	ld	ra,88(sp)
ffffffffc0203ab8:	6446                	ld	s0,80(sp)
ffffffffc0203aba:	64a6                	ld	s1,72(sp)
ffffffffc0203abc:	6906                	ld	s2,64(sp)
ffffffffc0203abe:	79e2                	ld	s3,56(sp)
ffffffffc0203ac0:	7a42                	ld	s4,48(sp)
ffffffffc0203ac2:	7aa2                	ld	s5,40(sp)
ffffffffc0203ac4:	7b02                	ld	s6,32(sp)
ffffffffc0203ac6:	6be2                	ld	s7,24(sp)
ffffffffc0203ac8:	6c42                	ld	s8,16(sp)
ffffffffc0203aca:	6ca2                	ld	s9,8(sp)
ffffffffc0203acc:	6125                	addi	sp,sp,96
ffffffffc0203ace:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203ad0:	0017f713          	andi	a4,a5,1
ffffffffc0203ad4:	df71                	beqz	a4,ffffffffc0203ab0 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0203ad6:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203ada:	078a                	slli	a5,a5,0x2
ffffffffc0203adc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203ade:	06e7fd63          	bleu	a4,a5,ffffffffc0203b58 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ae2:	000c3503          	ld	a0,0(s8)
ffffffffc0203ae6:	97de                	add	a5,a5,s7
ffffffffc0203ae8:	079a                	slli	a5,a5,0x6
ffffffffc0203aea:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203aec:	411c                	lw	a5,0(a0)
ffffffffc0203aee:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203af2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203af4:	cf11                	beqz	a4,ffffffffc0203b10 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203af6:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203afa:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0203afe:	9452                	add	s0,s0,s4
ffffffffc0203b00:	bf4d                	j	ffffffffc0203ab2 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203b02:	945a                	add	s0,s0,s6
ffffffffc0203b04:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0203b08:	d45d                	beqz	s0,ffffffffc0203ab6 <unmap_range+0x72>
ffffffffc0203b0a:	f9246ae3          	bltu	s0,s2,ffffffffc0203a9e <unmap_range+0x5a>
ffffffffc0203b0e:	b765                	j	ffffffffc0203ab6 <unmap_range+0x72>
            free_page(page);
ffffffffc0203b10:	4585                	li	a1,1
ffffffffc0203b12:	c79ff0ef          	jal	ra,ffffffffc020378a <free_pages>
ffffffffc0203b16:	b7c5                	j	ffffffffc0203af6 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0203b18:	00005697          	auipc	a3,0x5
ffffffffc0203b1c:	a2868693          	addi	a3,a3,-1496 # ffffffffc0208540 <default_pmm_manager+0x630>
ffffffffc0203b20:	00003617          	auipc	a2,0x3
ffffffffc0203b24:	27860613          	addi	a2,a2,632 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203b28:	11000593          	li	a1,272
ffffffffc0203b2c:	00004517          	auipc	a0,0x4
ffffffffc0203b30:	49450513          	addi	a0,a0,1172 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0203b34:	ee2fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203b38:	00005697          	auipc	a3,0x5
ffffffffc0203b3c:	9d868693          	addi	a3,a3,-1576 # ffffffffc0208510 <default_pmm_manager+0x600>
ffffffffc0203b40:	00003617          	auipc	a2,0x3
ffffffffc0203b44:	25860613          	addi	a2,a2,600 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203b48:	10f00593          	li	a1,271
ffffffffc0203b4c:	00004517          	auipc	a0,0x4
ffffffffc0203b50:	47450513          	addi	a0,a0,1140 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0203b54:	ec2fc0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0203b58:	b8fff0ef          	jal	ra,ffffffffc02036e6 <pa2page.part.4>

ffffffffc0203b5c <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203b5c:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203b5e:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0203b62:	fc86                	sd	ra,120(sp)
ffffffffc0203b64:	f8a2                	sd	s0,112(sp)
ffffffffc0203b66:	f4a6                	sd	s1,104(sp)
ffffffffc0203b68:	f0ca                	sd	s2,96(sp)
ffffffffc0203b6a:	ecce                	sd	s3,88(sp)
ffffffffc0203b6c:	e8d2                	sd	s4,80(sp)
ffffffffc0203b6e:	e4d6                	sd	s5,72(sp)
ffffffffc0203b70:	e0da                	sd	s6,64(sp)
ffffffffc0203b72:	fc5e                	sd	s7,56(sp)
ffffffffc0203b74:	f862                	sd	s8,48(sp)
ffffffffc0203b76:	f466                	sd	s9,40(sp)
ffffffffc0203b78:	f06a                	sd	s10,32(sp)
ffffffffc0203b7a:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203b7c:	03479713          	slli	a4,a5,0x34
ffffffffc0203b80:	1c071163          	bnez	a4,ffffffffc0203d42 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc0203b84:	002007b7          	lui	a5,0x200
ffffffffc0203b88:	20f5e563          	bltu	a1,a5,ffffffffc0203d92 <exit_range+0x236>
ffffffffc0203b8c:	8b32                	mv	s6,a2
ffffffffc0203b8e:	20c5f263          	bleu	a2,a1,ffffffffc0203d92 <exit_range+0x236>
ffffffffc0203b92:	4785                	li	a5,1
ffffffffc0203b94:	07fe                	slli	a5,a5,0x1f
ffffffffc0203b96:	1ec7ee63          	bltu	a5,a2,ffffffffc0203d92 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0203b9a:	c00009b7          	lui	s3,0xc0000
ffffffffc0203b9e:	400007b7          	lui	a5,0x40000
ffffffffc0203ba2:	0135f9b3          	and	s3,a1,s3
ffffffffc0203ba6:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0203ba8:	c0000337          	lui	t1,0xc0000
ffffffffc0203bac:	00698933          	add	s2,s3,t1
ffffffffc0203bb0:	01e95913          	srli	s2,s2,0x1e
ffffffffc0203bb4:	1ff97913          	andi	s2,s2,511
ffffffffc0203bb8:	8e2a                	mv	t3,a0
ffffffffc0203bba:	090e                	slli	s2,s2,0x3
ffffffffc0203bbc:	9972                	add	s2,s2,t3
ffffffffc0203bbe:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203bc2:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0203bc6:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0203bc8:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0203bcc:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc0203bce:	000a9d17          	auipc	s10,0xa9
ffffffffc0203bd2:	8cad0d13          	addi	s10,s10,-1846 # ffffffffc02ac498 <npage>
    return KADDR(page2pa(page));
ffffffffc0203bd6:	00cddd93          	srli	s11,s11,0xc
ffffffffc0203bda:	000a9717          	auipc	a4,0xa9
ffffffffc0203bde:	9ee70713          	addi	a4,a4,-1554 # ffffffffc02ac5c8 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0203be2:	000a9e97          	auipc	t4,0xa9
ffffffffc0203be6:	9f6e8e93          	addi	t4,t4,-1546 # ffffffffc02ac5d8 <pages>
        if (pde1&PTE_V){
ffffffffc0203bea:	e79d                	bnez	a5,ffffffffc0203c18 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc0203bec:	12098963          	beqz	s3,ffffffffc0203d1e <exit_range+0x1c2>
ffffffffc0203bf0:	400007b7          	lui	a5,0x40000
ffffffffc0203bf4:	84ce                	mv	s1,s3
ffffffffc0203bf6:	97ce                	add	a5,a5,s3
ffffffffc0203bf8:	1369f363          	bleu	s6,s3,ffffffffc0203d1e <exit_range+0x1c2>
ffffffffc0203bfc:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0203bfe:	00698933          	add	s2,s3,t1
ffffffffc0203c02:	01e95913          	srli	s2,s2,0x1e
ffffffffc0203c06:	1ff97913          	andi	s2,s2,511
ffffffffc0203c0a:	090e                	slli	s2,s2,0x3
ffffffffc0203c0c:	9972                	add	s2,s2,t3
ffffffffc0203c0e:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc0203c12:	001bf793          	andi	a5,s7,1
ffffffffc0203c16:	dbf9                	beqz	a5,ffffffffc0203bec <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0203c18:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c1c:	0b8a                	slli	s7,s7,0x2
ffffffffc0203c1e:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c22:	14fbfc63          	bleu	a5,s7,ffffffffc0203d7a <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c26:	fff80ab7          	lui	s5,0xfff80
ffffffffc0203c2a:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc0203c2c:	000806b7          	lui	a3,0x80
ffffffffc0203c30:	96d6                	add	a3,a3,s5
ffffffffc0203c32:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0203c36:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc0203c3a:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c3c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203c3e:	12f67263          	bleu	a5,a2,ffffffffc0203d62 <exit_range+0x206>
ffffffffc0203c42:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0203c46:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0203c48:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc0203c4c:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc0203c4e:	00080837          	lui	a6,0x80
ffffffffc0203c52:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc0203c54:	00200c37          	lui	s8,0x200
ffffffffc0203c58:	a801                	j	ffffffffc0203c68 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc0203c5a:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc0203c5c:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203c5e:	c0d9                	beqz	s1,ffffffffc0203ce4 <exit_range+0x188>
ffffffffc0203c60:	0934f263          	bleu	s3,s1,ffffffffc0203ce4 <exit_range+0x188>
ffffffffc0203c64:	0d64fc63          	bleu	s6,s1,ffffffffc0203d3c <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0203c68:	0154d413          	srli	s0,s1,0x15
ffffffffc0203c6c:	1ff47413          	andi	s0,s0,511
ffffffffc0203c70:	040e                	slli	s0,s0,0x3
ffffffffc0203c72:	9452                	add	s0,s0,s4
ffffffffc0203c74:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc0203c76:	0017f693          	andi	a3,a5,1
ffffffffc0203c7a:	d2e5                	beqz	a3,ffffffffc0203c5a <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc0203c7c:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c80:	00279513          	slli	a0,a5,0x2
ffffffffc0203c84:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c86:	0eb57a63          	bleu	a1,a0,ffffffffc0203d7a <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c8a:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc0203c8c:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc0203c90:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc0203c94:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c96:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203c98:	0cb7f563          	bleu	a1,a5,ffffffffc0203d62 <exit_range+0x206>
ffffffffc0203c9c:	631c                	ld	a5,0(a4)
ffffffffc0203c9e:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203ca0:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc0203ca4:	629c                	ld	a5,0(a3)
ffffffffc0203ca6:	8b85                	andi	a5,a5,1
ffffffffc0203ca8:	fbd5                	bnez	a5,ffffffffc0203c5c <exit_range+0x100>
ffffffffc0203caa:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0203cac:	fed59ce3          	bne	a1,a3,ffffffffc0203ca4 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cb0:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0203cb4:	4585                	li	a1,1
ffffffffc0203cb6:	e072                	sd	t3,0(sp)
ffffffffc0203cb8:	953e                	add	a0,a0,a5
ffffffffc0203cba:	ad1ff0ef          	jal	ra,ffffffffc020378a <free_pages>
                d0start += PTSIZE;
ffffffffc0203cbe:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0203cc0:	00043023          	sd	zero,0(s0)
ffffffffc0203cc4:	000a9e97          	auipc	t4,0xa9
ffffffffc0203cc8:	914e8e93          	addi	t4,t4,-1772 # ffffffffc02ac5d8 <pages>
ffffffffc0203ccc:	6e02                	ld	t3,0(sp)
ffffffffc0203cce:	c0000337          	lui	t1,0xc0000
ffffffffc0203cd2:	fff808b7          	lui	a7,0xfff80
ffffffffc0203cd6:	00080837          	lui	a6,0x80
ffffffffc0203cda:	000a9717          	auipc	a4,0xa9
ffffffffc0203cde:	8ee70713          	addi	a4,a4,-1810 # ffffffffc02ac5c8 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0203ce2:	fcbd                	bnez	s1,ffffffffc0203c60 <exit_range+0x104>
            if (free_pd0) {
ffffffffc0203ce4:	f00c84e3          	beqz	s9,ffffffffc0203bec <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0203ce8:	000d3783          	ld	a5,0(s10)
ffffffffc0203cec:	e072                	sd	t3,0(sp)
ffffffffc0203cee:	08fbf663          	bleu	a5,s7,ffffffffc0203d7a <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cf2:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0203cf6:	67a2                	ld	a5,8(sp)
ffffffffc0203cf8:	4585                	li	a1,1
ffffffffc0203cfa:	953e                	add	a0,a0,a5
ffffffffc0203cfc:	a8fff0ef          	jal	ra,ffffffffc020378a <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0203d00:	00093023          	sd	zero,0(s2)
ffffffffc0203d04:	000a9717          	auipc	a4,0xa9
ffffffffc0203d08:	8c470713          	addi	a4,a4,-1852 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0203d0c:	c0000337          	lui	t1,0xc0000
ffffffffc0203d10:	6e02                	ld	t3,0(sp)
ffffffffc0203d12:	000a9e97          	auipc	t4,0xa9
ffffffffc0203d16:	8c6e8e93          	addi	t4,t4,-1850 # ffffffffc02ac5d8 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc0203d1a:	ec099be3          	bnez	s3,ffffffffc0203bf0 <exit_range+0x94>
}
ffffffffc0203d1e:	70e6                	ld	ra,120(sp)
ffffffffc0203d20:	7446                	ld	s0,112(sp)
ffffffffc0203d22:	74a6                	ld	s1,104(sp)
ffffffffc0203d24:	7906                	ld	s2,96(sp)
ffffffffc0203d26:	69e6                	ld	s3,88(sp)
ffffffffc0203d28:	6a46                	ld	s4,80(sp)
ffffffffc0203d2a:	6aa6                	ld	s5,72(sp)
ffffffffc0203d2c:	6b06                	ld	s6,64(sp)
ffffffffc0203d2e:	7be2                	ld	s7,56(sp)
ffffffffc0203d30:	7c42                	ld	s8,48(sp)
ffffffffc0203d32:	7ca2                	ld	s9,40(sp)
ffffffffc0203d34:	7d02                	ld	s10,32(sp)
ffffffffc0203d36:	6de2                	ld	s11,24(sp)
ffffffffc0203d38:	6109                	addi	sp,sp,128
ffffffffc0203d3a:	8082                	ret
            if (free_pd0) {
ffffffffc0203d3c:	ea0c8ae3          	beqz	s9,ffffffffc0203bf0 <exit_range+0x94>
ffffffffc0203d40:	b765                	j	ffffffffc0203ce8 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203d42:	00004697          	auipc	a3,0x4
ffffffffc0203d46:	7ce68693          	addi	a3,a3,1998 # ffffffffc0208510 <default_pmm_manager+0x600>
ffffffffc0203d4a:	00003617          	auipc	a2,0x3
ffffffffc0203d4e:	04e60613          	addi	a2,a2,78 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203d52:	12000593          	li	a1,288
ffffffffc0203d56:	00004517          	auipc	a0,0x4
ffffffffc0203d5a:	26a50513          	addi	a0,a0,618 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0203d5e:	cb8fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203d62:	00003617          	auipc	a2,0x3
ffffffffc0203d66:	7b660613          	addi	a2,a2,1974 # ffffffffc0207518 <commands+0xc00>
ffffffffc0203d6a:	06900593          	li	a1,105
ffffffffc0203d6e:	00003517          	auipc	a0,0x3
ffffffffc0203d72:	79a50513          	addi	a0,a0,1946 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0203d76:	ca0fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203d7a:	00003617          	auipc	a2,0x3
ffffffffc0203d7e:	76e60613          	addi	a2,a2,1902 # ffffffffc02074e8 <commands+0xbd0>
ffffffffc0203d82:	06200593          	li	a1,98
ffffffffc0203d86:	00003517          	auipc	a0,0x3
ffffffffc0203d8a:	78250513          	addi	a0,a0,1922 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0203d8e:	c88fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203d92:	00004697          	auipc	a3,0x4
ffffffffc0203d96:	7ae68693          	addi	a3,a3,1966 # ffffffffc0208540 <default_pmm_manager+0x630>
ffffffffc0203d9a:	00003617          	auipc	a2,0x3
ffffffffc0203d9e:	ffe60613          	addi	a2,a2,-2 # ffffffffc0206d98 <commands+0x480>
ffffffffc0203da2:	12100593          	li	a1,289
ffffffffc0203da6:	00004517          	auipc	a0,0x4
ffffffffc0203daa:	21a50513          	addi	a0,a0,538 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0203dae:	c68fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203db2 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203db2:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203db4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203db6:	e426                	sd	s1,8(sp)
ffffffffc0203db8:	ec06                	sd	ra,24(sp)
ffffffffc0203dba:	e822                	sd	s0,16(sp)
ffffffffc0203dbc:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203dbe:	a53ff0ef          	jal	ra,ffffffffc0203810 <get_pte>
    if (ptep != NULL) {
ffffffffc0203dc2:	c511                	beqz	a0,ffffffffc0203dce <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203dc4:	611c                	ld	a5,0(a0)
ffffffffc0203dc6:	842a                	mv	s0,a0
ffffffffc0203dc8:	0017f713          	andi	a4,a5,1
ffffffffc0203dcc:	e711                	bnez	a4,ffffffffc0203dd8 <page_remove+0x26>
}
ffffffffc0203dce:	60e2                	ld	ra,24(sp)
ffffffffc0203dd0:	6442                	ld	s0,16(sp)
ffffffffc0203dd2:	64a2                	ld	s1,8(sp)
ffffffffc0203dd4:	6105                	addi	sp,sp,32
ffffffffc0203dd6:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0203dd8:	000a8717          	auipc	a4,0xa8
ffffffffc0203ddc:	6c070713          	addi	a4,a4,1728 # ffffffffc02ac498 <npage>
ffffffffc0203de0:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203de2:	078a                	slli	a5,a5,0x2
ffffffffc0203de4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203de6:	02e7fe63          	bleu	a4,a5,ffffffffc0203e22 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0203dea:	000a8717          	auipc	a4,0xa8
ffffffffc0203dee:	7ee70713          	addi	a4,a4,2030 # ffffffffc02ac5d8 <pages>
ffffffffc0203df2:	6308                	ld	a0,0(a4)
ffffffffc0203df4:	fff80737          	lui	a4,0xfff80
ffffffffc0203df8:	97ba                	add	a5,a5,a4
ffffffffc0203dfa:	079a                	slli	a5,a5,0x6
ffffffffc0203dfc:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0203dfe:	411c                	lw	a5,0(a0)
ffffffffc0203e00:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203e04:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203e06:	cb11                	beqz	a4,ffffffffc0203e1a <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203e08:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203e0c:	12048073          	sfence.vma	s1
}
ffffffffc0203e10:	60e2                	ld	ra,24(sp)
ffffffffc0203e12:	6442                	ld	s0,16(sp)
ffffffffc0203e14:	64a2                	ld	s1,8(sp)
ffffffffc0203e16:	6105                	addi	sp,sp,32
ffffffffc0203e18:	8082                	ret
            free_page(page);
ffffffffc0203e1a:	4585                	li	a1,1
ffffffffc0203e1c:	96fff0ef          	jal	ra,ffffffffc020378a <free_pages>
ffffffffc0203e20:	b7e5                	j	ffffffffc0203e08 <page_remove+0x56>
ffffffffc0203e22:	8c5ff0ef          	jal	ra,ffffffffc02036e6 <pa2page.part.4>

ffffffffc0203e26 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203e26:	7179                	addi	sp,sp,-48
ffffffffc0203e28:	e44e                	sd	s3,8(sp)
ffffffffc0203e2a:	89b2                	mv	s3,a2
ffffffffc0203e2c:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203e2e:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203e30:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203e32:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0203e34:	ec26                	sd	s1,24(sp)
ffffffffc0203e36:	f406                	sd	ra,40(sp)
ffffffffc0203e38:	e84a                	sd	s2,16(sp)
ffffffffc0203e3a:	e052                	sd	s4,0(sp)
ffffffffc0203e3c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0203e3e:	9d3ff0ef          	jal	ra,ffffffffc0203810 <get_pte>
    if (ptep == NULL) {
ffffffffc0203e42:	cd49                	beqz	a0,ffffffffc0203edc <page_insert+0xb6>
    page->ref += 1;
ffffffffc0203e44:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0203e46:	611c                	ld	a5,0(a0)
ffffffffc0203e48:	892a                	mv	s2,a0
ffffffffc0203e4a:	0016871b          	addiw	a4,a3,1
ffffffffc0203e4e:	c018                	sw	a4,0(s0)
ffffffffc0203e50:	0017f713          	andi	a4,a5,1
ffffffffc0203e54:	ef05                	bnez	a4,ffffffffc0203e8c <page_insert+0x66>
ffffffffc0203e56:	000a8797          	auipc	a5,0xa8
ffffffffc0203e5a:	78278793          	addi	a5,a5,1922 # ffffffffc02ac5d8 <pages>
ffffffffc0203e5e:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0203e60:	8c19                	sub	s0,s0,a4
ffffffffc0203e62:	000806b7          	lui	a3,0x80
ffffffffc0203e66:	8419                	srai	s0,s0,0x6
ffffffffc0203e68:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203e6a:	042a                	slli	s0,s0,0xa
ffffffffc0203e6c:	8c45                	or	s0,s0,s1
ffffffffc0203e6e:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0203e72:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203e76:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0203e7a:	4501                	li	a0,0
}
ffffffffc0203e7c:	70a2                	ld	ra,40(sp)
ffffffffc0203e7e:	7402                	ld	s0,32(sp)
ffffffffc0203e80:	64e2                	ld	s1,24(sp)
ffffffffc0203e82:	6942                	ld	s2,16(sp)
ffffffffc0203e84:	69a2                	ld	s3,8(sp)
ffffffffc0203e86:	6a02                	ld	s4,0(sp)
ffffffffc0203e88:	6145                	addi	sp,sp,48
ffffffffc0203e8a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0203e8c:	000a8717          	auipc	a4,0xa8
ffffffffc0203e90:	60c70713          	addi	a4,a4,1548 # ffffffffc02ac498 <npage>
ffffffffc0203e94:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203e96:	078a                	slli	a5,a5,0x2
ffffffffc0203e98:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203e9a:	04e7f363          	bleu	a4,a5,ffffffffc0203ee0 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0203e9e:	000a8a17          	auipc	s4,0xa8
ffffffffc0203ea2:	73aa0a13          	addi	s4,s4,1850 # ffffffffc02ac5d8 <pages>
ffffffffc0203ea6:	000a3703          	ld	a4,0(s4)
ffffffffc0203eaa:	fff80537          	lui	a0,0xfff80
ffffffffc0203eae:	953e                	add	a0,a0,a5
ffffffffc0203eb0:	051a                	slli	a0,a0,0x6
ffffffffc0203eb2:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0203eb4:	00a40a63          	beq	s0,a0,ffffffffc0203ec8 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0203eb8:	411c                	lw	a5,0(a0)
ffffffffc0203eba:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203ebe:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0203ec0:	c691                	beqz	a3,ffffffffc0203ecc <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203ec2:	12098073          	sfence.vma	s3
ffffffffc0203ec6:	bf69                	j	ffffffffc0203e60 <page_insert+0x3a>
ffffffffc0203ec8:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203eca:	bf59                	j	ffffffffc0203e60 <page_insert+0x3a>
            free_page(page);
ffffffffc0203ecc:	4585                	li	a1,1
ffffffffc0203ece:	8bdff0ef          	jal	ra,ffffffffc020378a <free_pages>
ffffffffc0203ed2:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203ed6:	12098073          	sfence.vma	s3
ffffffffc0203eda:	b759                	j	ffffffffc0203e60 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203edc:	5571                	li	a0,-4
ffffffffc0203ede:	bf79                	j	ffffffffc0203e7c <page_insert+0x56>
ffffffffc0203ee0:	807ff0ef          	jal	ra,ffffffffc02036e6 <pa2page.part.4>

ffffffffc0203ee4 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203ee4:	00004797          	auipc	a5,0x4
ffffffffc0203ee8:	02c78793          	addi	a5,a5,44 # ffffffffc0207f10 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203eec:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0203eee:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203ef0:	00004517          	auipc	a0,0x4
ffffffffc0203ef4:	0f850513          	addi	a0,a0,248 # ffffffffc0207fe8 <default_pmm_manager+0xd8>
void pmm_init(void) {
ffffffffc0203ef8:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203efa:	000a8717          	auipc	a4,0xa8
ffffffffc0203efe:	6cf73323          	sd	a5,1734(a4) # ffffffffc02ac5c0 <pmm_manager>
void pmm_init(void) {
ffffffffc0203f02:	e0a2                	sd	s0,64(sp)
ffffffffc0203f04:	fc26                	sd	s1,56(sp)
ffffffffc0203f06:	f84a                	sd	s2,48(sp)
ffffffffc0203f08:	f44e                	sd	s3,40(sp)
ffffffffc0203f0a:	f052                	sd	s4,32(sp)
ffffffffc0203f0c:	ec56                	sd	s5,24(sp)
ffffffffc0203f0e:	e85a                	sd	s6,16(sp)
ffffffffc0203f10:	e45e                	sd	s7,8(sp)
ffffffffc0203f12:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203f14:	000a8417          	auipc	s0,0xa8
ffffffffc0203f18:	6ac40413          	addi	s0,s0,1708 # ffffffffc02ac5c0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203f1c:	9b4fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc0203f20:	601c                	ld	a5,0(s0)
ffffffffc0203f22:	000a8497          	auipc	s1,0xa8
ffffffffc0203f26:	57648493          	addi	s1,s1,1398 # ffffffffc02ac498 <npage>
ffffffffc0203f2a:	000a8917          	auipc	s2,0xa8
ffffffffc0203f2e:	6ae90913          	addi	s2,s2,1710 # ffffffffc02ac5d8 <pages>
ffffffffc0203f32:	679c                	ld	a5,8(a5)
ffffffffc0203f34:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203f36:	57f5                	li	a5,-3
ffffffffc0203f38:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0203f3a:	00004517          	auipc	a0,0x4
ffffffffc0203f3e:	0c650513          	addi	a0,a0,198 # ffffffffc0208000 <default_pmm_manager+0xf0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203f42:	000a8717          	auipc	a4,0xa8
ffffffffc0203f46:	68f73323          	sd	a5,1670(a4) # ffffffffc02ac5c8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0203f4a:	986fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203f4e:	46c5                	li	a3,17
ffffffffc0203f50:	06ee                	slli	a3,a3,0x1b
ffffffffc0203f52:	40100613          	li	a2,1025
ffffffffc0203f56:	16fd                	addi	a3,a3,-1
ffffffffc0203f58:	0656                	slli	a2,a2,0x15
ffffffffc0203f5a:	07e005b7          	lui	a1,0x7e00
ffffffffc0203f5e:	00004517          	auipc	a0,0x4
ffffffffc0203f62:	0ba50513          	addi	a0,a0,186 # ffffffffc0208018 <default_pmm_manager+0x108>
ffffffffc0203f66:	96afc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203f6a:	777d                	lui	a4,0xfffff
ffffffffc0203f6c:	000a9797          	auipc	a5,0xa9
ffffffffc0203f70:	68378793          	addi	a5,a5,1667 # ffffffffc02ad5ef <end+0xfff>
ffffffffc0203f74:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0203f76:	00088737          	lui	a4,0x88
ffffffffc0203f7a:	000a8697          	auipc	a3,0xa8
ffffffffc0203f7e:	50e6bf23          	sd	a4,1310(a3) # ffffffffc02ac498 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203f82:	000a8717          	auipc	a4,0xa8
ffffffffc0203f86:	64f73b23          	sd	a5,1622(a4) # ffffffffc02ac5d8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203f8a:	4701                	li	a4,0
ffffffffc0203f8c:	4685                	li	a3,1
ffffffffc0203f8e:	fff80837          	lui	a6,0xfff80
ffffffffc0203f92:	a019                	j	ffffffffc0203f98 <pmm_init+0xb4>
ffffffffc0203f94:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0203f98:	00671613          	slli	a2,a4,0x6
ffffffffc0203f9c:	97b2                	add	a5,a5,a2
ffffffffc0203f9e:	07a1                	addi	a5,a5,8
ffffffffc0203fa0:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203fa4:	6090                	ld	a2,0(s1)
ffffffffc0203fa6:	0705                	addi	a4,a4,1
ffffffffc0203fa8:	010607b3          	add	a5,a2,a6
ffffffffc0203fac:	fef764e3          	bltu	a4,a5,ffffffffc0203f94 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203fb0:	00093503          	ld	a0,0(s2)
ffffffffc0203fb4:	fe0007b7          	lui	a5,0xfe000
ffffffffc0203fb8:	00661693          	slli	a3,a2,0x6
ffffffffc0203fbc:	97aa                	add	a5,a5,a0
ffffffffc0203fbe:	96be                	add	a3,a3,a5
ffffffffc0203fc0:	c02007b7          	lui	a5,0xc0200
ffffffffc0203fc4:	7af6ed63          	bltu	a3,a5,ffffffffc020477e <pmm_init+0x89a>
ffffffffc0203fc8:	000a8997          	auipc	s3,0xa8
ffffffffc0203fcc:	60098993          	addi	s3,s3,1536 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0203fd0:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0203fd4:	47c5                	li	a5,17
ffffffffc0203fd6:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203fd8:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0203fda:	02f6f763          	bleu	a5,a3,ffffffffc0204008 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203fde:	6585                	lui	a1,0x1
ffffffffc0203fe0:	15fd                	addi	a1,a1,-1
ffffffffc0203fe2:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0203fe4:	00c6d713          	srli	a4,a3,0xc
ffffffffc0203fe8:	48c77a63          	bleu	a2,a4,ffffffffc020447c <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0203fec:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203fee:	75fd                	lui	a1,0xfffff
ffffffffc0203ff0:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0203ff2:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0203ff4:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203ff6:	40d786b3          	sub	a3,a5,a3
ffffffffc0203ffa:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0203ffc:	00c6d593          	srli	a1,a3,0xc
ffffffffc0204000:	953a                	add	a0,a0,a4
ffffffffc0204002:	9602                	jalr	a2
ffffffffc0204004:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0204008:	00004517          	auipc	a0,0x4
ffffffffc020400c:	03850513          	addi	a0,a0,56 # ffffffffc0208040 <default_pmm_manager+0x130>
ffffffffc0204010:	8c0fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0204014:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0204016:	000a8417          	auipc	s0,0xa8
ffffffffc020401a:	47a40413          	addi	s0,s0,1146 # ffffffffc02ac490 <boot_pgdir>
    pmm_manager->check();
ffffffffc020401e:	7b9c                	ld	a5,48(a5)
ffffffffc0204020:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0204022:	00004517          	auipc	a0,0x4
ffffffffc0204026:	03650513          	addi	a0,a0,54 # ffffffffc0208058 <default_pmm_manager+0x148>
ffffffffc020402a:	8a6fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020402e:	00007697          	auipc	a3,0x7
ffffffffc0204032:	fd268693          	addi	a3,a3,-46 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0204036:	000a8797          	auipc	a5,0xa8
ffffffffc020403a:	44d7bd23          	sd	a3,1114(a5) # ffffffffc02ac490 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020403e:	c02007b7          	lui	a5,0xc0200
ffffffffc0204042:	10f6eae3          	bltu	a3,a5,ffffffffc0204956 <pmm_init+0xa72>
ffffffffc0204046:	0009b783          	ld	a5,0(s3)
ffffffffc020404a:	8e9d                	sub	a3,a3,a5
ffffffffc020404c:	000a8797          	auipc	a5,0xa8
ffffffffc0204050:	58d7b223          	sd	a3,1412(a5) # ffffffffc02ac5d0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0204054:	f7cff0ef          	jal	ra,ffffffffc02037d0 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0204058:	6098                	ld	a4,0(s1)
ffffffffc020405a:	c80007b7          	lui	a5,0xc8000
ffffffffc020405e:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0204060:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0204062:	0ce7eae3          	bltu	a5,a4,ffffffffc0204936 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0204066:	6008                	ld	a0,0(s0)
ffffffffc0204068:	44050463          	beqz	a0,ffffffffc02044b0 <pmm_init+0x5cc>
ffffffffc020406c:	6785                	lui	a5,0x1
ffffffffc020406e:	17fd                	addi	a5,a5,-1
ffffffffc0204070:	8fe9                	and	a5,a5,a0
ffffffffc0204072:	2781                	sext.w	a5,a5
ffffffffc0204074:	42079e63          	bnez	a5,ffffffffc02044b0 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0204078:	4601                	li	a2,0
ffffffffc020407a:	4581                	li	a1,0
ffffffffc020407c:	967ff0ef          	jal	ra,ffffffffc02039e2 <get_page>
ffffffffc0204080:	78051b63          	bnez	a0,ffffffffc0204816 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0204084:	4505                	li	a0,1
ffffffffc0204086:	e7cff0ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc020408a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020408c:	6008                	ld	a0,0(s0)
ffffffffc020408e:	4681                	li	a3,0
ffffffffc0204090:	4601                	li	a2,0
ffffffffc0204092:	85d6                	mv	a1,s5
ffffffffc0204094:	d93ff0ef          	jal	ra,ffffffffc0203e26 <page_insert>
ffffffffc0204098:	7a051f63          	bnez	a0,ffffffffc0204856 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020409c:	6008                	ld	a0,0(s0)
ffffffffc020409e:	4601                	li	a2,0
ffffffffc02040a0:	4581                	li	a1,0
ffffffffc02040a2:	f6eff0ef          	jal	ra,ffffffffc0203810 <get_pte>
ffffffffc02040a6:	78050863          	beqz	a0,ffffffffc0204836 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02040aa:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02040ac:	0017f713          	andi	a4,a5,1
ffffffffc02040b0:	3e070463          	beqz	a4,ffffffffc0204498 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02040b4:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02040b6:	078a                	slli	a5,a5,0x2
ffffffffc02040b8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02040ba:	3ce7f163          	bleu	a4,a5,ffffffffc020447c <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02040be:	00093683          	ld	a3,0(s2)
ffffffffc02040c2:	fff80637          	lui	a2,0xfff80
ffffffffc02040c6:	97b2                	add	a5,a5,a2
ffffffffc02040c8:	079a                	slli	a5,a5,0x6
ffffffffc02040ca:	97b6                	add	a5,a5,a3
ffffffffc02040cc:	72fa9563          	bne	s5,a5,ffffffffc02047f6 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc02040d0:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
ffffffffc02040d4:	4785                	li	a5,1
ffffffffc02040d6:	70fb9063          	bne	s7,a5,ffffffffc02047d6 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02040da:	6008                	ld	a0,0(s0)
ffffffffc02040dc:	76fd                	lui	a3,0xfffff
ffffffffc02040de:	611c                	ld	a5,0(a0)
ffffffffc02040e0:	078a                	slli	a5,a5,0x2
ffffffffc02040e2:	8ff5                	and	a5,a5,a3
ffffffffc02040e4:	00c7d613          	srli	a2,a5,0xc
ffffffffc02040e8:	66e67e63          	bleu	a4,a2,ffffffffc0204764 <pmm_init+0x880>
ffffffffc02040ec:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02040f0:	97e2                	add	a5,a5,s8
ffffffffc02040f2:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
ffffffffc02040f6:	0b0a                	slli	s6,s6,0x2
ffffffffc02040f8:	00db7b33          	and	s6,s6,a3
ffffffffc02040fc:	00cb5793          	srli	a5,s6,0xc
ffffffffc0204100:	56e7f863          	bleu	a4,a5,ffffffffc0204670 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204104:	4601                	li	a2,0
ffffffffc0204106:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204108:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020410a:	f06ff0ef          	jal	ra,ffffffffc0203810 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020410e:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204110:	55651063          	bne	a0,s6,ffffffffc0204650 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0204114:	4505                	li	a0,1
ffffffffc0204116:	decff0ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc020411a:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020411c:	6008                	ld	a0,0(s0)
ffffffffc020411e:	46d1                	li	a3,20
ffffffffc0204120:	6605                	lui	a2,0x1
ffffffffc0204122:	85da                	mv	a1,s6
ffffffffc0204124:	d03ff0ef          	jal	ra,ffffffffc0203e26 <page_insert>
ffffffffc0204128:	50051463          	bnez	a0,ffffffffc0204630 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020412c:	6008                	ld	a0,0(s0)
ffffffffc020412e:	4601                	li	a2,0
ffffffffc0204130:	6585                	lui	a1,0x1
ffffffffc0204132:	edeff0ef          	jal	ra,ffffffffc0203810 <get_pte>
ffffffffc0204136:	4c050d63          	beqz	a0,ffffffffc0204610 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc020413a:	611c                	ld	a5,0(a0)
ffffffffc020413c:	0107f713          	andi	a4,a5,16
ffffffffc0204140:	4a070863          	beqz	a4,ffffffffc02045f0 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0204144:	8b91                	andi	a5,a5,4
ffffffffc0204146:	48078563          	beqz	a5,ffffffffc02045d0 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020414a:	6008                	ld	a0,0(s0)
ffffffffc020414c:	611c                	ld	a5,0(a0)
ffffffffc020414e:	8bc1                	andi	a5,a5,16
ffffffffc0204150:	46078063          	beqz	a5,ffffffffc02045b0 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0204154:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5580>
ffffffffc0204158:	43779c63          	bne	a5,s7,ffffffffc0204590 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020415c:	4681                	li	a3,0
ffffffffc020415e:	6605                	lui	a2,0x1
ffffffffc0204160:	85d6                	mv	a1,s5
ffffffffc0204162:	cc5ff0ef          	jal	ra,ffffffffc0203e26 <page_insert>
ffffffffc0204166:	40051563          	bnez	a0,ffffffffc0204570 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc020416a:	000aa703          	lw	a4,0(s5)
ffffffffc020416e:	4789                	li	a5,2
ffffffffc0204170:	3ef71063          	bne	a4,a5,ffffffffc0204550 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc0204174:	000b2783          	lw	a5,0(s6)
ffffffffc0204178:	3a079c63          	bnez	a5,ffffffffc0204530 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020417c:	6008                	ld	a0,0(s0)
ffffffffc020417e:	4601                	li	a2,0
ffffffffc0204180:	6585                	lui	a1,0x1
ffffffffc0204182:	e8eff0ef          	jal	ra,ffffffffc0203810 <get_pte>
ffffffffc0204186:	38050563          	beqz	a0,ffffffffc0204510 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc020418a:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020418c:	00177793          	andi	a5,a4,1
ffffffffc0204190:	30078463          	beqz	a5,ffffffffc0204498 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0204194:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204196:	00271793          	slli	a5,a4,0x2
ffffffffc020419a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020419c:	2ed7f063          	bleu	a3,a5,ffffffffc020447c <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02041a0:	00093683          	ld	a3,0(s2)
ffffffffc02041a4:	fff80637          	lui	a2,0xfff80
ffffffffc02041a8:	97b2                	add	a5,a5,a2
ffffffffc02041aa:	079a                	slli	a5,a5,0x6
ffffffffc02041ac:	97b6                	add	a5,a5,a3
ffffffffc02041ae:	32fa9163          	bne	s5,a5,ffffffffc02044d0 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc02041b2:	8b41                	andi	a4,a4,16
ffffffffc02041b4:	70071163          	bnez	a4,ffffffffc02048b6 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02041b8:	6008                	ld	a0,0(s0)
ffffffffc02041ba:	4581                	li	a1,0
ffffffffc02041bc:	bf7ff0ef          	jal	ra,ffffffffc0203db2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02041c0:	000aa703          	lw	a4,0(s5)
ffffffffc02041c4:	4785                	li	a5,1
ffffffffc02041c6:	6cf71863          	bne	a4,a5,ffffffffc0204896 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc02041ca:	000b2783          	lw	a5,0(s6)
ffffffffc02041ce:	6a079463          	bnez	a5,ffffffffc0204876 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02041d2:	6008                	ld	a0,0(s0)
ffffffffc02041d4:	6585                	lui	a1,0x1
ffffffffc02041d6:	bddff0ef          	jal	ra,ffffffffc0203db2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02041da:	000aa783          	lw	a5,0(s5)
ffffffffc02041de:	50079363          	bnez	a5,ffffffffc02046e4 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc02041e2:	000b2783          	lw	a5,0(s6)
ffffffffc02041e6:	4c079f63          	bnez	a5,ffffffffc02046c4 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02041ea:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02041ee:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02041f0:	000ab783          	ld	a5,0(s5)
ffffffffc02041f4:	078a                	slli	a5,a5,0x2
ffffffffc02041f6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02041f8:	28c7f263          	bleu	a2,a5,ffffffffc020447c <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02041fc:	fff80737          	lui	a4,0xfff80
ffffffffc0204200:	00093503          	ld	a0,0(s2)
ffffffffc0204204:	97ba                	add	a5,a5,a4
ffffffffc0204206:	079a                	slli	a5,a5,0x6
ffffffffc0204208:	00f50733          	add	a4,a0,a5
ffffffffc020420c:	4314                	lw	a3,0(a4)
ffffffffc020420e:	4705                	li	a4,1
ffffffffc0204210:	48e69a63          	bne	a3,a4,ffffffffc02046a4 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0204214:	8799                	srai	a5,a5,0x6
ffffffffc0204216:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020421a:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc020421c:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020421e:	8331                	srli	a4,a4,0xc
ffffffffc0204220:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204222:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0204224:	46c77363          	bleu	a2,a4,ffffffffc020468a <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0204228:	0009b683          	ld	a3,0(s3)
ffffffffc020422c:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020422e:	639c                	ld	a5,0(a5)
ffffffffc0204230:	078a                	slli	a5,a5,0x2
ffffffffc0204232:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204234:	24c7f463          	bleu	a2,a5,ffffffffc020447c <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0204238:	416787b3          	sub	a5,a5,s6
ffffffffc020423c:	079a                	slli	a5,a5,0x6
ffffffffc020423e:	953e                	add	a0,a0,a5
ffffffffc0204240:	4585                	li	a1,1
ffffffffc0204242:	d48ff0ef          	jal	ra,ffffffffc020378a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204246:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020424a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020424c:	078a                	slli	a5,a5,0x2
ffffffffc020424e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204250:	22e7f663          	bleu	a4,a5,ffffffffc020447c <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0204254:	00093503          	ld	a0,0(s2)
ffffffffc0204258:	416787b3          	sub	a5,a5,s6
ffffffffc020425c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020425e:	953e                	add	a0,a0,a5
ffffffffc0204260:	4585                	li	a1,1
ffffffffc0204262:	d28ff0ef          	jal	ra,ffffffffc020378a <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0204266:	601c                	ld	a5,0(s0)
ffffffffc0204268:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc020426c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0204270:	d60ff0ef          	jal	ra,ffffffffc02037d0 <nr_free_pages>
ffffffffc0204274:	68aa1163          	bne	s4,a0,ffffffffc02048f6 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0204278:	00004517          	auipc	a0,0x4
ffffffffc020427c:	0c850513          	addi	a0,a0,200 # ffffffffc0208340 <default_pmm_manager+0x430>
ffffffffc0204280:	e51fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0204284:	d4cff0ef          	jal	ra,ffffffffc02037d0 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0204288:	6098                	ld	a4,0(s1)
ffffffffc020428a:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc020428e:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0204290:	00c71693          	slli	a3,a4,0xc
ffffffffc0204294:	18d7f563          	bleu	a3,a5,ffffffffc020441e <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204298:	83b1                	srli	a5,a5,0xc
ffffffffc020429a:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020429c:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02042a0:	1ae7f163          	bleu	a4,a5,ffffffffc0204442 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02042a4:	7bfd                	lui	s7,0xfffff
ffffffffc02042a6:	6b05                	lui	s6,0x1
ffffffffc02042a8:	a029                	j	ffffffffc02042b2 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02042aa:	00cad713          	srli	a4,s5,0xc
ffffffffc02042ae:	18f77a63          	bleu	a5,a4,ffffffffc0204442 <pmm_init+0x55e>
ffffffffc02042b2:	0009b583          	ld	a1,0(s3)
ffffffffc02042b6:	4601                	li	a2,0
ffffffffc02042b8:	95d6                	add	a1,a1,s5
ffffffffc02042ba:	d56ff0ef          	jal	ra,ffffffffc0203810 <get_pte>
ffffffffc02042be:	16050263          	beqz	a0,ffffffffc0204422 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02042c2:	611c                	ld	a5,0(a0)
ffffffffc02042c4:	078a                	slli	a5,a5,0x2
ffffffffc02042c6:	0177f7b3          	and	a5,a5,s7
ffffffffc02042ca:	19579963          	bne	a5,s5,ffffffffc020445c <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02042ce:	609c                	ld	a5,0(s1)
ffffffffc02042d0:	9ada                	add	s5,s5,s6
ffffffffc02042d2:	6008                	ld	a0,0(s0)
ffffffffc02042d4:	00c79713          	slli	a4,a5,0xc
ffffffffc02042d8:	fceae9e3          	bltu	s5,a4,ffffffffc02042aa <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02042dc:	611c                	ld	a5,0(a0)
ffffffffc02042de:	62079c63          	bnez	a5,ffffffffc0204916 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc02042e2:	4505                	li	a0,1
ffffffffc02042e4:	c1eff0ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc02042e8:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02042ea:	6008                	ld	a0,0(s0)
ffffffffc02042ec:	4699                	li	a3,6
ffffffffc02042ee:	10000613          	li	a2,256
ffffffffc02042f2:	85d6                	mv	a1,s5
ffffffffc02042f4:	b33ff0ef          	jal	ra,ffffffffc0203e26 <page_insert>
ffffffffc02042f8:	1e051c63          	bnez	a0,ffffffffc02044f0 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc02042fc:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0204300:	4785                	li	a5,1
ffffffffc0204302:	44f71163          	bne	a4,a5,ffffffffc0204744 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0204306:	6008                	ld	a0,0(s0)
ffffffffc0204308:	6b05                	lui	s6,0x1
ffffffffc020430a:	4699                	li	a3,6
ffffffffc020430c:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8478>
ffffffffc0204310:	85d6                	mv	a1,s5
ffffffffc0204312:	b15ff0ef          	jal	ra,ffffffffc0203e26 <page_insert>
ffffffffc0204316:	40051763          	bnez	a0,ffffffffc0204724 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc020431a:	000aa703          	lw	a4,0(s5)
ffffffffc020431e:	4789                	li	a5,2
ffffffffc0204320:	3ef71263          	bne	a4,a5,ffffffffc0204704 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0204324:	00004597          	auipc	a1,0x4
ffffffffc0204328:	15458593          	addi	a1,a1,340 # ffffffffc0208478 <default_pmm_manager+0x568>
ffffffffc020432c:	10000513          	li	a0,256
ffffffffc0204330:	7e3010ef          	jal	ra,ffffffffc0206312 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0204334:	100b0593          	addi	a1,s6,256
ffffffffc0204338:	10000513          	li	a0,256
ffffffffc020433c:	7e9010ef          	jal	ra,ffffffffc0206324 <strcmp>
ffffffffc0204340:	44051b63          	bnez	a0,ffffffffc0204796 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0204344:	00093683          	ld	a3,0(s2)
ffffffffc0204348:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc020434c:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc020434e:	40da86b3          	sub	a3,s5,a3
ffffffffc0204352:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204354:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0204356:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0204358:	00cb5b13          	srli	s6,s6,0xc
ffffffffc020435c:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0204360:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204362:	10f77f63          	bleu	a5,a4,ffffffffc0204480 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0204366:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020436a:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020436e:	96be                	add	a3,a3,a5
ffffffffc0204370:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52b10>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0204374:	75b010ef          	jal	ra,ffffffffc02062ce <strlen>
ffffffffc0204378:	54051f63          	bnez	a0,ffffffffc02048d6 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020437c:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0204380:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204382:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52a10>
ffffffffc0204386:	068a                	slli	a3,a3,0x2
ffffffffc0204388:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020438a:	0ef6f963          	bleu	a5,a3,ffffffffc020447c <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc020438e:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0204392:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204394:	0efb7663          	bleu	a5,s6,ffffffffc0204480 <pmm_init+0x59c>
ffffffffc0204398:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc020439c:	4585                	li	a1,1
ffffffffc020439e:	8556                	mv	a0,s5
ffffffffc02043a0:	99b6                	add	s3,s3,a3
ffffffffc02043a2:	be8ff0ef          	jal	ra,ffffffffc020378a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02043a6:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02043aa:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02043ac:	078a                	slli	a5,a5,0x2
ffffffffc02043ae:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02043b0:	0ce7f663          	bleu	a4,a5,ffffffffc020447c <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02043b4:	00093503          	ld	a0,0(s2)
ffffffffc02043b8:	fff809b7          	lui	s3,0xfff80
ffffffffc02043bc:	97ce                	add	a5,a5,s3
ffffffffc02043be:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02043c0:	953e                	add	a0,a0,a5
ffffffffc02043c2:	4585                	li	a1,1
ffffffffc02043c4:	bc6ff0ef          	jal	ra,ffffffffc020378a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02043c8:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02043cc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02043ce:	078a                	slli	a5,a5,0x2
ffffffffc02043d0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02043d2:	0ae7f563          	bleu	a4,a5,ffffffffc020447c <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02043d6:	00093503          	ld	a0,0(s2)
ffffffffc02043da:	97ce                	add	a5,a5,s3
ffffffffc02043dc:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02043de:	953e                	add	a0,a0,a5
ffffffffc02043e0:	4585                	li	a1,1
ffffffffc02043e2:	ba8ff0ef          	jal	ra,ffffffffc020378a <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02043e6:	601c                	ld	a5,0(s0)
ffffffffc02043e8:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc02043ec:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02043f0:	be0ff0ef          	jal	ra,ffffffffc02037d0 <nr_free_pages>
ffffffffc02043f4:	3caa1163          	bne	s4,a0,ffffffffc02047b6 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02043f8:	00004517          	auipc	a0,0x4
ffffffffc02043fc:	0f850513          	addi	a0,a0,248 # ffffffffc02084f0 <default_pmm_manager+0x5e0>
ffffffffc0204400:	cd1fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0204404:	6406                	ld	s0,64(sp)
ffffffffc0204406:	60a6                	ld	ra,72(sp)
ffffffffc0204408:	74e2                	ld	s1,56(sp)
ffffffffc020440a:	7942                	ld	s2,48(sp)
ffffffffc020440c:	79a2                	ld	s3,40(sp)
ffffffffc020440e:	7a02                	ld	s4,32(sp)
ffffffffc0204410:	6ae2                	ld	s5,24(sp)
ffffffffc0204412:	6b42                	ld	s6,16(sp)
ffffffffc0204414:	6ba2                	ld	s7,8(sp)
ffffffffc0204416:	6c02                	ld	s8,0(sp)
ffffffffc0204418:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc020441a:	c4dfd06f          	j	ffffffffc0202066 <kmalloc_init>
ffffffffc020441e:	6008                	ld	a0,0(s0)
ffffffffc0204420:	bd75                	j	ffffffffc02042dc <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0204422:	00004697          	auipc	a3,0x4
ffffffffc0204426:	f3e68693          	addi	a3,a3,-194 # ffffffffc0208360 <default_pmm_manager+0x450>
ffffffffc020442a:	00003617          	auipc	a2,0x3
ffffffffc020442e:	96e60613          	addi	a2,a2,-1682 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204432:	21d00593          	li	a1,541
ffffffffc0204436:	00004517          	auipc	a0,0x4
ffffffffc020443a:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc020443e:	dd9fb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204442:	86d6                	mv	a3,s5
ffffffffc0204444:	00003617          	auipc	a2,0x3
ffffffffc0204448:	0d460613          	addi	a2,a2,212 # ffffffffc0207518 <commands+0xc00>
ffffffffc020444c:	21d00593          	li	a1,541
ffffffffc0204450:	00004517          	auipc	a0,0x4
ffffffffc0204454:	b7050513          	addi	a0,a0,-1168 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204458:	dbffb0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020445c:	00004697          	auipc	a3,0x4
ffffffffc0204460:	f4468693          	addi	a3,a3,-188 # ffffffffc02083a0 <default_pmm_manager+0x490>
ffffffffc0204464:	00003617          	auipc	a2,0x3
ffffffffc0204468:	93460613          	addi	a2,a2,-1740 # ffffffffc0206d98 <commands+0x480>
ffffffffc020446c:	21e00593          	li	a1,542
ffffffffc0204470:	00004517          	auipc	a0,0x4
ffffffffc0204474:	b5050513          	addi	a0,a0,-1200 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204478:	d9ffb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc020447c:	a6aff0ef          	jal	ra,ffffffffc02036e6 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0204480:	00003617          	auipc	a2,0x3
ffffffffc0204484:	09860613          	addi	a2,a2,152 # ffffffffc0207518 <commands+0xc00>
ffffffffc0204488:	06900593          	li	a1,105
ffffffffc020448c:	00003517          	auipc	a0,0x3
ffffffffc0204490:	07c50513          	addi	a0,a0,124 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0204494:	d83fb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0204498:	00003617          	auipc	a2,0x3
ffffffffc020449c:	d8060613          	addi	a2,a2,-640 # ffffffffc0207218 <commands+0x900>
ffffffffc02044a0:	07400593          	li	a1,116
ffffffffc02044a4:	00003517          	auipc	a0,0x3
ffffffffc02044a8:	06450513          	addi	a0,a0,100 # ffffffffc0207508 <commands+0xbf0>
ffffffffc02044ac:	d6bfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02044b0:	00004697          	auipc	a3,0x4
ffffffffc02044b4:	be868693          	addi	a3,a3,-1048 # ffffffffc0208098 <default_pmm_manager+0x188>
ffffffffc02044b8:	00003617          	auipc	a2,0x3
ffffffffc02044bc:	8e060613          	addi	a2,a2,-1824 # ffffffffc0206d98 <commands+0x480>
ffffffffc02044c0:	1e100593          	li	a1,481
ffffffffc02044c4:	00004517          	auipc	a0,0x4
ffffffffc02044c8:	afc50513          	addi	a0,a0,-1284 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02044cc:	d4bfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02044d0:	00004697          	auipc	a3,0x4
ffffffffc02044d4:	c8868693          	addi	a3,a3,-888 # ffffffffc0208158 <default_pmm_manager+0x248>
ffffffffc02044d8:	00003617          	auipc	a2,0x3
ffffffffc02044dc:	8c060613          	addi	a2,a2,-1856 # ffffffffc0206d98 <commands+0x480>
ffffffffc02044e0:	1fd00593          	li	a1,509
ffffffffc02044e4:	00004517          	auipc	a0,0x4
ffffffffc02044e8:	adc50513          	addi	a0,a0,-1316 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02044ec:	d2bfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02044f0:	00004697          	auipc	a3,0x4
ffffffffc02044f4:	ee068693          	addi	a3,a3,-288 # ffffffffc02083d0 <default_pmm_manager+0x4c0>
ffffffffc02044f8:	00003617          	auipc	a2,0x3
ffffffffc02044fc:	8a060613          	addi	a2,a2,-1888 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204500:	22600593          	li	a1,550
ffffffffc0204504:	00004517          	auipc	a0,0x4
ffffffffc0204508:	abc50513          	addi	a0,a0,-1348 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc020450c:	d0bfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204510:	00004697          	auipc	a3,0x4
ffffffffc0204514:	cd868693          	addi	a3,a3,-808 # ffffffffc02081e8 <default_pmm_manager+0x2d8>
ffffffffc0204518:	00003617          	auipc	a2,0x3
ffffffffc020451c:	88060613          	addi	a2,a2,-1920 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204520:	1fc00593          	li	a1,508
ffffffffc0204524:	00004517          	auipc	a0,0x4
ffffffffc0204528:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc020452c:	cebfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204530:	00004697          	auipc	a3,0x4
ffffffffc0204534:	d8068693          	addi	a3,a3,-640 # ffffffffc02082b0 <default_pmm_manager+0x3a0>
ffffffffc0204538:	00003617          	auipc	a2,0x3
ffffffffc020453c:	86060613          	addi	a2,a2,-1952 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204540:	1fb00593          	li	a1,507
ffffffffc0204544:	00004517          	auipc	a0,0x4
ffffffffc0204548:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc020454c:	ccbfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0204550:	00004697          	auipc	a3,0x4
ffffffffc0204554:	d4868693          	addi	a3,a3,-696 # ffffffffc0208298 <default_pmm_manager+0x388>
ffffffffc0204558:	00003617          	auipc	a2,0x3
ffffffffc020455c:	84060613          	addi	a2,a2,-1984 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204560:	1fa00593          	li	a1,506
ffffffffc0204564:	00004517          	auipc	a0,0x4
ffffffffc0204568:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc020456c:	cabfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0204570:	00004697          	auipc	a3,0x4
ffffffffc0204574:	cf868693          	addi	a3,a3,-776 # ffffffffc0208268 <default_pmm_manager+0x358>
ffffffffc0204578:	00003617          	auipc	a2,0x3
ffffffffc020457c:	82060613          	addi	a2,a2,-2016 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204580:	1f900593          	li	a1,505
ffffffffc0204584:	00004517          	auipc	a0,0x4
ffffffffc0204588:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc020458c:	c8bfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0204590:	00004697          	auipc	a3,0x4
ffffffffc0204594:	cc068693          	addi	a3,a3,-832 # ffffffffc0208250 <default_pmm_manager+0x340>
ffffffffc0204598:	00003617          	auipc	a2,0x3
ffffffffc020459c:	80060613          	addi	a2,a2,-2048 # ffffffffc0206d98 <commands+0x480>
ffffffffc02045a0:	1f700593          	li	a1,503
ffffffffc02045a4:	00004517          	auipc	a0,0x4
ffffffffc02045a8:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02045ac:	c6bfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02045b0:	00004697          	auipc	a3,0x4
ffffffffc02045b4:	c8868693          	addi	a3,a3,-888 # ffffffffc0208238 <default_pmm_manager+0x328>
ffffffffc02045b8:	00002617          	auipc	a2,0x2
ffffffffc02045bc:	7e060613          	addi	a2,a2,2016 # ffffffffc0206d98 <commands+0x480>
ffffffffc02045c0:	1f600593          	li	a1,502
ffffffffc02045c4:	00004517          	auipc	a0,0x4
ffffffffc02045c8:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02045cc:	c4bfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02045d0:	00004697          	auipc	a3,0x4
ffffffffc02045d4:	c5868693          	addi	a3,a3,-936 # ffffffffc0208228 <default_pmm_manager+0x318>
ffffffffc02045d8:	00002617          	auipc	a2,0x2
ffffffffc02045dc:	7c060613          	addi	a2,a2,1984 # ffffffffc0206d98 <commands+0x480>
ffffffffc02045e0:	1f500593          	li	a1,501
ffffffffc02045e4:	00004517          	auipc	a0,0x4
ffffffffc02045e8:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02045ec:	c2bfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02045f0:	00004697          	auipc	a3,0x4
ffffffffc02045f4:	c2868693          	addi	a3,a3,-984 # ffffffffc0208218 <default_pmm_manager+0x308>
ffffffffc02045f8:	00002617          	auipc	a2,0x2
ffffffffc02045fc:	7a060613          	addi	a2,a2,1952 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204600:	1f400593          	li	a1,500
ffffffffc0204604:	00004517          	auipc	a0,0x4
ffffffffc0204608:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc020460c:	c0bfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0204610:	00004697          	auipc	a3,0x4
ffffffffc0204614:	bd868693          	addi	a3,a3,-1064 # ffffffffc02081e8 <default_pmm_manager+0x2d8>
ffffffffc0204618:	00002617          	auipc	a2,0x2
ffffffffc020461c:	78060613          	addi	a2,a2,1920 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204620:	1f300593          	li	a1,499
ffffffffc0204624:	00004517          	auipc	a0,0x4
ffffffffc0204628:	99c50513          	addi	a0,a0,-1636 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc020462c:	bebfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0204630:	00004697          	auipc	a3,0x4
ffffffffc0204634:	b8068693          	addi	a3,a3,-1152 # ffffffffc02081b0 <default_pmm_manager+0x2a0>
ffffffffc0204638:	00002617          	auipc	a2,0x2
ffffffffc020463c:	76060613          	addi	a2,a2,1888 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204640:	1f200593          	li	a1,498
ffffffffc0204644:	00004517          	auipc	a0,0x4
ffffffffc0204648:	97c50513          	addi	a0,a0,-1668 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc020464c:	bcbfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0204650:	00004697          	auipc	a3,0x4
ffffffffc0204654:	b3868693          	addi	a3,a3,-1224 # ffffffffc0208188 <default_pmm_manager+0x278>
ffffffffc0204658:	00002617          	auipc	a2,0x2
ffffffffc020465c:	74060613          	addi	a2,a2,1856 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204660:	1ef00593          	li	a1,495
ffffffffc0204664:	00004517          	auipc	a0,0x4
ffffffffc0204668:	95c50513          	addi	a0,a0,-1700 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc020466c:	babfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0204670:	86da                	mv	a3,s6
ffffffffc0204672:	00003617          	auipc	a2,0x3
ffffffffc0204676:	ea660613          	addi	a2,a2,-346 # ffffffffc0207518 <commands+0xc00>
ffffffffc020467a:	1ee00593          	li	a1,494
ffffffffc020467e:	00004517          	auipc	a0,0x4
ffffffffc0204682:	94250513          	addi	a0,a0,-1726 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204686:	b91fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc020468a:	86be                	mv	a3,a5
ffffffffc020468c:	00003617          	auipc	a2,0x3
ffffffffc0204690:	e8c60613          	addi	a2,a2,-372 # ffffffffc0207518 <commands+0xc00>
ffffffffc0204694:	06900593          	li	a1,105
ffffffffc0204698:	00003517          	auipc	a0,0x3
ffffffffc020469c:	e7050513          	addi	a0,a0,-400 # ffffffffc0207508 <commands+0xbf0>
ffffffffc02046a0:	b77fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02046a4:	00004697          	auipc	a3,0x4
ffffffffc02046a8:	c5468693          	addi	a3,a3,-940 # ffffffffc02082f8 <default_pmm_manager+0x3e8>
ffffffffc02046ac:	00002617          	auipc	a2,0x2
ffffffffc02046b0:	6ec60613          	addi	a2,a2,1772 # ffffffffc0206d98 <commands+0x480>
ffffffffc02046b4:	20800593          	li	a1,520
ffffffffc02046b8:	00004517          	auipc	a0,0x4
ffffffffc02046bc:	90850513          	addi	a0,a0,-1784 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02046c0:	b57fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02046c4:	00004697          	auipc	a3,0x4
ffffffffc02046c8:	bec68693          	addi	a3,a3,-1044 # ffffffffc02082b0 <default_pmm_manager+0x3a0>
ffffffffc02046cc:	00002617          	auipc	a2,0x2
ffffffffc02046d0:	6cc60613          	addi	a2,a2,1740 # ffffffffc0206d98 <commands+0x480>
ffffffffc02046d4:	20600593          	li	a1,518
ffffffffc02046d8:	00004517          	auipc	a0,0x4
ffffffffc02046dc:	8e850513          	addi	a0,a0,-1816 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02046e0:	b37fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02046e4:	00004697          	auipc	a3,0x4
ffffffffc02046e8:	bfc68693          	addi	a3,a3,-1028 # ffffffffc02082e0 <default_pmm_manager+0x3d0>
ffffffffc02046ec:	00002617          	auipc	a2,0x2
ffffffffc02046f0:	6ac60613          	addi	a2,a2,1708 # ffffffffc0206d98 <commands+0x480>
ffffffffc02046f4:	20500593          	li	a1,517
ffffffffc02046f8:	00004517          	auipc	a0,0x4
ffffffffc02046fc:	8c850513          	addi	a0,a0,-1848 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204700:	b17fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0204704:	00004697          	auipc	a3,0x4
ffffffffc0204708:	d5c68693          	addi	a3,a3,-676 # ffffffffc0208460 <default_pmm_manager+0x550>
ffffffffc020470c:	00002617          	auipc	a2,0x2
ffffffffc0204710:	68c60613          	addi	a2,a2,1676 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204714:	22900593          	li	a1,553
ffffffffc0204718:	00004517          	auipc	a0,0x4
ffffffffc020471c:	8a850513          	addi	a0,a0,-1880 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204720:	af7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0204724:	00004697          	auipc	a3,0x4
ffffffffc0204728:	cfc68693          	addi	a3,a3,-772 # ffffffffc0208420 <default_pmm_manager+0x510>
ffffffffc020472c:	00002617          	auipc	a2,0x2
ffffffffc0204730:	66c60613          	addi	a2,a2,1644 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204734:	22800593          	li	a1,552
ffffffffc0204738:	00004517          	auipc	a0,0x4
ffffffffc020473c:	88850513          	addi	a0,a0,-1912 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204740:	ad7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0204744:	00004697          	auipc	a3,0x4
ffffffffc0204748:	cc468693          	addi	a3,a3,-828 # ffffffffc0208408 <default_pmm_manager+0x4f8>
ffffffffc020474c:	00002617          	auipc	a2,0x2
ffffffffc0204750:	64c60613          	addi	a2,a2,1612 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204754:	22700593          	li	a1,551
ffffffffc0204758:	00004517          	auipc	a0,0x4
ffffffffc020475c:	86850513          	addi	a0,a0,-1944 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204760:	ab7fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0204764:	86be                	mv	a3,a5
ffffffffc0204766:	00003617          	auipc	a2,0x3
ffffffffc020476a:	db260613          	addi	a2,a2,-590 # ffffffffc0207518 <commands+0xc00>
ffffffffc020476e:	1ed00593          	li	a1,493
ffffffffc0204772:	00004517          	auipc	a0,0x4
ffffffffc0204776:	84e50513          	addi	a0,a0,-1970 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc020477a:	a9dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020477e:	00003617          	auipc	a2,0x3
ffffffffc0204782:	01260613          	addi	a2,a2,18 # ffffffffc0207790 <commands+0xe78>
ffffffffc0204786:	07f00593          	li	a1,127
ffffffffc020478a:	00004517          	auipc	a0,0x4
ffffffffc020478e:	83650513          	addi	a0,a0,-1994 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204792:	a85fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0204796:	00004697          	auipc	a3,0x4
ffffffffc020479a:	cfa68693          	addi	a3,a3,-774 # ffffffffc0208490 <default_pmm_manager+0x580>
ffffffffc020479e:	00002617          	auipc	a2,0x2
ffffffffc02047a2:	5fa60613          	addi	a2,a2,1530 # ffffffffc0206d98 <commands+0x480>
ffffffffc02047a6:	22d00593          	li	a1,557
ffffffffc02047aa:	00004517          	auipc	a0,0x4
ffffffffc02047ae:	81650513          	addi	a0,a0,-2026 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02047b2:	a65fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02047b6:	00004697          	auipc	a3,0x4
ffffffffc02047ba:	b6a68693          	addi	a3,a3,-1174 # ffffffffc0208320 <default_pmm_manager+0x410>
ffffffffc02047be:	00002617          	auipc	a2,0x2
ffffffffc02047c2:	5da60613          	addi	a2,a2,1498 # ffffffffc0206d98 <commands+0x480>
ffffffffc02047c6:	23900593          	li	a1,569
ffffffffc02047ca:	00003517          	auipc	a0,0x3
ffffffffc02047ce:	7f650513          	addi	a0,a0,2038 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02047d2:	a45fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02047d6:	00004697          	auipc	a3,0x4
ffffffffc02047da:	99a68693          	addi	a3,a3,-1638 # ffffffffc0208170 <default_pmm_manager+0x260>
ffffffffc02047de:	00002617          	auipc	a2,0x2
ffffffffc02047e2:	5ba60613          	addi	a2,a2,1466 # ffffffffc0206d98 <commands+0x480>
ffffffffc02047e6:	1eb00593          	li	a1,491
ffffffffc02047ea:	00003517          	auipc	a0,0x3
ffffffffc02047ee:	7d650513          	addi	a0,a0,2006 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02047f2:	a25fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02047f6:	00004697          	auipc	a3,0x4
ffffffffc02047fa:	96268693          	addi	a3,a3,-1694 # ffffffffc0208158 <default_pmm_manager+0x248>
ffffffffc02047fe:	00002617          	auipc	a2,0x2
ffffffffc0204802:	59a60613          	addi	a2,a2,1434 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204806:	1ea00593          	li	a1,490
ffffffffc020480a:	00003517          	auipc	a0,0x3
ffffffffc020480e:	7b650513          	addi	a0,a0,1974 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204812:	a05fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0204816:	00004697          	auipc	a3,0x4
ffffffffc020481a:	8ba68693          	addi	a3,a3,-1862 # ffffffffc02080d0 <default_pmm_manager+0x1c0>
ffffffffc020481e:	00002617          	auipc	a2,0x2
ffffffffc0204822:	57a60613          	addi	a2,a2,1402 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204826:	1e200593          	li	a1,482
ffffffffc020482a:	00003517          	auipc	a0,0x3
ffffffffc020482e:	79650513          	addi	a0,a0,1942 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204832:	9e5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0204836:	00004697          	auipc	a3,0x4
ffffffffc020483a:	8f268693          	addi	a3,a3,-1806 # ffffffffc0208128 <default_pmm_manager+0x218>
ffffffffc020483e:	00002617          	auipc	a2,0x2
ffffffffc0204842:	55a60613          	addi	a2,a2,1370 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204846:	1e900593          	li	a1,489
ffffffffc020484a:	00003517          	auipc	a0,0x3
ffffffffc020484e:	77650513          	addi	a0,a0,1910 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204852:	9c5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0204856:	00004697          	auipc	a3,0x4
ffffffffc020485a:	8a268693          	addi	a3,a3,-1886 # ffffffffc02080f8 <default_pmm_manager+0x1e8>
ffffffffc020485e:	00002617          	auipc	a2,0x2
ffffffffc0204862:	53a60613          	addi	a2,a2,1338 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204866:	1e600593          	li	a1,486
ffffffffc020486a:	00003517          	auipc	a0,0x3
ffffffffc020486e:	75650513          	addi	a0,a0,1878 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204872:	9a5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0204876:	00004697          	auipc	a3,0x4
ffffffffc020487a:	a3a68693          	addi	a3,a3,-1478 # ffffffffc02082b0 <default_pmm_manager+0x3a0>
ffffffffc020487e:	00002617          	auipc	a2,0x2
ffffffffc0204882:	51a60613          	addi	a2,a2,1306 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204886:	20200593          	li	a1,514
ffffffffc020488a:	00003517          	auipc	a0,0x3
ffffffffc020488e:	73650513          	addi	a0,a0,1846 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204892:	985fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0204896:	00004697          	auipc	a3,0x4
ffffffffc020489a:	8da68693          	addi	a3,a3,-1830 # ffffffffc0208170 <default_pmm_manager+0x260>
ffffffffc020489e:	00002617          	auipc	a2,0x2
ffffffffc02048a2:	4fa60613          	addi	a2,a2,1274 # ffffffffc0206d98 <commands+0x480>
ffffffffc02048a6:	20100593          	li	a1,513
ffffffffc02048aa:	00003517          	auipc	a0,0x3
ffffffffc02048ae:	71650513          	addi	a0,a0,1814 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02048b2:	965fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02048b6:	00004697          	auipc	a3,0x4
ffffffffc02048ba:	a1268693          	addi	a3,a3,-1518 # ffffffffc02082c8 <default_pmm_manager+0x3b8>
ffffffffc02048be:	00002617          	auipc	a2,0x2
ffffffffc02048c2:	4da60613          	addi	a2,a2,1242 # ffffffffc0206d98 <commands+0x480>
ffffffffc02048c6:	1fe00593          	li	a1,510
ffffffffc02048ca:	00003517          	auipc	a0,0x3
ffffffffc02048ce:	6f650513          	addi	a0,a0,1782 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02048d2:	945fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02048d6:	00004697          	auipc	a3,0x4
ffffffffc02048da:	bf268693          	addi	a3,a3,-1038 # ffffffffc02084c8 <default_pmm_manager+0x5b8>
ffffffffc02048de:	00002617          	auipc	a2,0x2
ffffffffc02048e2:	4ba60613          	addi	a2,a2,1210 # ffffffffc0206d98 <commands+0x480>
ffffffffc02048e6:	23000593          	li	a1,560
ffffffffc02048ea:	00003517          	auipc	a0,0x3
ffffffffc02048ee:	6d650513          	addi	a0,a0,1750 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc02048f2:	925fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02048f6:	00004697          	auipc	a3,0x4
ffffffffc02048fa:	a2a68693          	addi	a3,a3,-1494 # ffffffffc0208320 <default_pmm_manager+0x410>
ffffffffc02048fe:	00002617          	auipc	a2,0x2
ffffffffc0204902:	49a60613          	addi	a2,a2,1178 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204906:	21000593          	li	a1,528
ffffffffc020490a:	00003517          	auipc	a0,0x3
ffffffffc020490e:	6b650513          	addi	a0,a0,1718 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204912:	905fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0204916:	00004697          	auipc	a3,0x4
ffffffffc020491a:	aa268693          	addi	a3,a3,-1374 # ffffffffc02083b8 <default_pmm_manager+0x4a8>
ffffffffc020491e:	00002617          	auipc	a2,0x2
ffffffffc0204922:	47a60613          	addi	a2,a2,1146 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204926:	22200593          	li	a1,546
ffffffffc020492a:	00003517          	auipc	a0,0x3
ffffffffc020492e:	69650513          	addi	a0,a0,1686 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204932:	8e5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0204936:	00003697          	auipc	a3,0x3
ffffffffc020493a:	74268693          	addi	a3,a3,1858 # ffffffffc0208078 <default_pmm_manager+0x168>
ffffffffc020493e:	00002617          	auipc	a2,0x2
ffffffffc0204942:	45a60613          	addi	a2,a2,1114 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204946:	1e000593          	li	a1,480
ffffffffc020494a:	00003517          	auipc	a0,0x3
ffffffffc020494e:	67650513          	addi	a0,a0,1654 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204952:	8c5fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0204956:	00003617          	auipc	a2,0x3
ffffffffc020495a:	e3a60613          	addi	a2,a2,-454 # ffffffffc0207790 <commands+0xe78>
ffffffffc020495e:	0c100593          	li	a1,193
ffffffffc0204962:	00003517          	auipc	a0,0x3
ffffffffc0204966:	65e50513          	addi	a0,a0,1630 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc020496a:	8adfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020496e <copy_range>:
               bool share) {
ffffffffc020496e:	7119                	addi	sp,sp,-128
ffffffffc0204970:	f0ca                	sd	s2,96(sp)
ffffffffc0204972:	8936                	mv	s2,a3
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204974:	8ed1                	or	a3,a3,a2
               bool share) {
ffffffffc0204976:	fc86                	sd	ra,120(sp)
ffffffffc0204978:	f8a2                	sd	s0,112(sp)
ffffffffc020497a:	f4a6                	sd	s1,104(sp)
ffffffffc020497c:	ecce                	sd	s3,88(sp)
ffffffffc020497e:	e8d2                	sd	s4,80(sp)
ffffffffc0204980:	e4d6                	sd	s5,72(sp)
ffffffffc0204982:	e0da                	sd	s6,64(sp)
ffffffffc0204984:	fc5e                	sd	s7,56(sp)
ffffffffc0204986:	f862                	sd	s8,48(sp)
ffffffffc0204988:	f466                	sd	s9,40(sp)
ffffffffc020498a:	f06a                	sd	s10,32(sp)
ffffffffc020498c:	ec6e                	sd	s11,24(sp)
ffffffffc020498e:	e03a                	sd	a4,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204990:	03469793          	slli	a5,a3,0x34
ffffffffc0204994:	26079563          	bnez	a5,ffffffffc0204bfe <copy_range+0x290>
    assert(USER_ACCESS(start, end));
ffffffffc0204998:	00200737          	lui	a4,0x200
ffffffffc020499c:	8db2                	mv	s11,a2
ffffffffc020499e:	22e66463          	bltu	a2,a4,ffffffffc0204bc6 <copy_range+0x258>
ffffffffc02049a2:	23267263          	bleu	s2,a2,ffffffffc0204bc6 <copy_range+0x258>
ffffffffc02049a6:	4705                	li	a4,1
ffffffffc02049a8:	077e                	slli	a4,a4,0x1f
ffffffffc02049aa:	21276e63          	bltu	a4,s2,ffffffffc0204bc6 <copy_range+0x258>
ffffffffc02049ae:	5afd                	li	s5,-1
ffffffffc02049b0:	8b2a                	mv	s6,a0
ffffffffc02049b2:	84ae                	mv	s1,a1
        start += PGSIZE;
ffffffffc02049b4:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02049b6:	000a8c97          	auipc	s9,0xa8
ffffffffc02049ba:	ae2c8c93          	addi	s9,s9,-1310 # ffffffffc02ac498 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02049be:	000a8c17          	auipc	s8,0xa8
ffffffffc02049c2:	c1ac0c13          	addi	s8,s8,-998 # ffffffffc02ac5d8 <pages>
    return page - pages + nbase;
ffffffffc02049c6:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc02049ca:	00cada93          	srli	s5,s5,0xc
ffffffffc02049ce:	000a8d17          	auipc	s10,0xa8
ffffffffc02049d2:	bfad0d13          	addi	s10,s10,-1030 # ffffffffc02ac5c8 <va_pa_offset>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02049d6:	4601                	li	a2,0
ffffffffc02049d8:	85ee                	mv	a1,s11
ffffffffc02049da:	8526                	mv	a0,s1
ffffffffc02049dc:	e35fe0ef          	jal	ra,ffffffffc0203810 <get_pte>
ffffffffc02049e0:	842a                	mv	s0,a0
        if (ptep == NULL) {
ffffffffc02049e2:	c179                	beqz	a0,ffffffffc0204aa8 <copy_range+0x13a>
        if (*ptep & PTE_V) {
ffffffffc02049e4:	6118                	ld	a4,0(a0)
ffffffffc02049e6:	8b05                	andi	a4,a4,1
ffffffffc02049e8:	e705                	bnez	a4,ffffffffc0204a10 <copy_range+0xa2>
        start += PGSIZE;
ffffffffc02049ea:	9dd2                	add	s11,s11,s4
    } while (start != 0 && start < end);
ffffffffc02049ec:	ff2de5e3          	bltu	s11,s2,ffffffffc02049d6 <copy_range+0x68>
    return 0;
ffffffffc02049f0:	4501                	li	a0,0
}
ffffffffc02049f2:	70e6                	ld	ra,120(sp)
ffffffffc02049f4:	7446                	ld	s0,112(sp)
ffffffffc02049f6:	74a6                	ld	s1,104(sp)
ffffffffc02049f8:	7906                	ld	s2,96(sp)
ffffffffc02049fa:	69e6                	ld	s3,88(sp)
ffffffffc02049fc:	6a46                	ld	s4,80(sp)
ffffffffc02049fe:	6aa6                	ld	s5,72(sp)
ffffffffc0204a00:	6b06                	ld	s6,64(sp)
ffffffffc0204a02:	7be2                	ld	s7,56(sp)
ffffffffc0204a04:	7c42                	ld	s8,48(sp)
ffffffffc0204a06:	7ca2                	ld	s9,40(sp)
ffffffffc0204a08:	7d02                	ld	s10,32(sp)
ffffffffc0204a0a:	6de2                	ld	s11,24(sp)
ffffffffc0204a0c:	6109                	addi	sp,sp,128
ffffffffc0204a0e:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0204a10:	4605                	li	a2,1
ffffffffc0204a12:	85ee                	mv	a1,s11
ffffffffc0204a14:	855a                	mv	a0,s6
ffffffffc0204a16:	dfbfe0ef          	jal	ra,ffffffffc0203810 <get_pte>
ffffffffc0204a1a:	12050b63          	beqz	a0,ffffffffc0204b50 <copy_range+0x1e2>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0204a1e:	6018                	ld	a4,0(s0)
    if (!(pte & PTE_V)) {
ffffffffc0204a20:	00177693          	andi	a3,a4,1
ffffffffc0204a24:	0007099b          	sext.w	s3,a4
ffffffffc0204a28:	16068363          	beqz	a3,ffffffffc0204b8e <copy_range+0x220>
    if (PPN(pa) >= npage) {
ffffffffc0204a2c:	000cb683          	ld	a3,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204a30:	070a                	slli	a4,a4,0x2
ffffffffc0204a32:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204a34:	1ad77963          	bleu	a3,a4,ffffffffc0204be6 <copy_range+0x278>
    return &pages[PPN(pa) - nbase];
ffffffffc0204a38:	fff807b7          	lui	a5,0xfff80
ffffffffc0204a3c:	973e                	add	a4,a4,a5
ffffffffc0204a3e:	000c3403          	ld	s0,0(s8)
            if(share)
ffffffffc0204a42:	6782                	ld	a5,0(sp)
ffffffffc0204a44:	071a                	slli	a4,a4,0x6
ffffffffc0204a46:	943a                	add	s0,s0,a4
ffffffffc0204a48:	cfad                	beqz	a5,ffffffffc0204ac2 <copy_range+0x154>
    return page - pages + nbase;
ffffffffc0204a4a:	8719                	srai	a4,a4,0x6
ffffffffc0204a4c:	975e                	add	a4,a4,s7
    return KADDR(page2pa(page));
ffffffffc0204a4e:	01577633          	and	a2,a4,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a52:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc0204a54:	10d67063          	bleu	a3,a2,ffffffffc0204b54 <copy_range+0x1e6>
ffffffffc0204a58:	000d3583          	ld	a1,0(s10)
                cprintf("Sharing the page 0x%x\n", page2kva(page));
ffffffffc0204a5c:	00003517          	auipc	a0,0x3
ffffffffc0204a60:	50450513          	addi	a0,a0,1284 # ffffffffc0207f60 <default_pmm_manager+0x50>
                page_insert(from, page, start, perm & ~PTE_W);
ffffffffc0204a64:	01b9f993          	andi	s3,s3,27
                cprintf("Sharing the page 0x%x\n", page2kva(page));
ffffffffc0204a68:	95ba                	add	a1,a1,a4
ffffffffc0204a6a:	e66fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                page_insert(from, page, start, perm & ~PTE_W);
ffffffffc0204a6e:	86ce                	mv	a3,s3
ffffffffc0204a70:	866e                	mv	a2,s11
ffffffffc0204a72:	85a2                	mv	a1,s0
ffffffffc0204a74:	8526                	mv	a0,s1
ffffffffc0204a76:	bb0ff0ef          	jal	ra,ffffffffc0203e26 <page_insert>
                ret = page_insert(to, page, start, perm & ~PTE_W);
ffffffffc0204a7a:	86ce                	mv	a3,s3
ffffffffc0204a7c:	866e                	mv	a2,s11
ffffffffc0204a7e:	85a2                	mv	a1,s0
ffffffffc0204a80:	855a                	mv	a0,s6
ffffffffc0204a82:	ba4ff0ef          	jal	ra,ffffffffc0203e26 <page_insert>
            assert(ret == 0);
ffffffffc0204a86:	d135                	beqz	a0,ffffffffc02049ea <copy_range+0x7c>
ffffffffc0204a88:	00003697          	auipc	a3,0x3
ffffffffc0204a8c:	52868693          	addi	a3,a3,1320 # ffffffffc0207fb0 <default_pmm_manager+0xa0>
ffffffffc0204a90:	00002617          	auipc	a2,0x2
ffffffffc0204a94:	30860613          	addi	a2,a2,776 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204a98:	18200593          	li	a1,386
ffffffffc0204a9c:	00003517          	auipc	a0,0x3
ffffffffc0204aa0:	52450513          	addi	a0,a0,1316 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204aa4:	f72fb0ef          	jal	ra,ffffffffc0200216 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0204aa8:	00200737          	lui	a4,0x200
ffffffffc0204aac:	00ed87b3          	add	a5,s11,a4
ffffffffc0204ab0:	ffe00737          	lui	a4,0xffe00
ffffffffc0204ab4:	00e7fdb3          	and	s11,a5,a4
    } while (start != 0 && start < end);
ffffffffc0204ab8:	f20d8ce3          	beqz	s11,ffffffffc02049f0 <copy_range+0x82>
ffffffffc0204abc:	f12dede3          	bltu	s11,s2,ffffffffc02049d6 <copy_range+0x68>
ffffffffc0204ac0:	bf05                	j	ffffffffc02049f0 <copy_range+0x82>
                struct Page *npage = alloc_page();
ffffffffc0204ac2:	4505                	li	a0,1
ffffffffc0204ac4:	c3ffe0ef          	jal	ra,ffffffffc0203702 <alloc_pages>
                assert(page!=NULL);
ffffffffc0204ac8:	c05d                	beqz	s0,ffffffffc0204b6e <copy_range+0x200>
                assert(npage!=NULL);
ffffffffc0204aca:	cd71                	beqz	a0,ffffffffc0204ba6 <copy_range+0x238>
    return page - pages + nbase;
ffffffffc0204acc:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204ad0:	000cb703          	ld	a4,0(s9)
    return page - pages + nbase;
ffffffffc0204ad4:	40d506b3          	sub	a3,a0,a3
ffffffffc0204ad8:	8699                	srai	a3,a3,0x6
ffffffffc0204ada:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204adc:	0156f633          	and	a2,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ae0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ae2:	06e67a63          	bleu	a4,a2,ffffffffc0204b56 <copy_range+0x1e8>
ffffffffc0204ae6:	000d3583          	ld	a1,0(s10)
ffffffffc0204aea:	e42a                	sd	a0,8(sp)
                cprintf("alloc a new page 0x%x\n", page2kva(npage));
ffffffffc0204aec:	00003517          	auipc	a0,0x3
ffffffffc0204af0:	4ac50513          	addi	a0,a0,1196 # ffffffffc0207f98 <default_pmm_manager+0x88>
ffffffffc0204af4:	95b6                	add	a1,a1,a3
ffffffffc0204af6:	ddafb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return page - pages + nbase;
ffffffffc0204afa:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204afe:	000cb603          	ld	a2,0(s9)
ffffffffc0204b02:	6822                	ld	a6,8(sp)
    return page - pages + nbase;
ffffffffc0204b04:	40e406b3          	sub	a3,s0,a4
ffffffffc0204b08:	8699                	srai	a3,a3,0x6
ffffffffc0204b0a:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204b0c:	0156f5b3          	and	a1,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b10:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b12:	04c5f263          	bleu	a2,a1,ffffffffc0204b56 <copy_range+0x1e8>
    return page - pages + nbase;
ffffffffc0204b16:	40e80733          	sub	a4,a6,a4
    return KADDR(page2pa(page));
ffffffffc0204b1a:	000d3503          	ld	a0,0(s10)
    return page - pages + nbase;
ffffffffc0204b1e:	8719                	srai	a4,a4,0x6
ffffffffc0204b20:	975e                	add	a4,a4,s7
    return KADDR(page2pa(page));
ffffffffc0204b22:	015778b3          	and	a7,a4,s5
ffffffffc0204b26:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b2a:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc0204b2c:	02c8f463          	bleu	a2,a7,ffffffffc0204b54 <copy_range+0x1e6>
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc0204b30:	6605                	lui	a2,0x1
ffffffffc0204b32:	953a                	add	a0,a0,a4
ffffffffc0204b34:	e442                	sd	a6,8(sp)
ffffffffc0204b36:	049010ef          	jal	ra,ffffffffc020637e <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc0204b3a:	6822                	ld	a6,8(sp)
ffffffffc0204b3c:	01f9f693          	andi	a3,s3,31
ffffffffc0204b40:	866e                	mv	a2,s11
ffffffffc0204b42:	85c2                	mv	a1,a6
ffffffffc0204b44:	855a                	mv	a0,s6
ffffffffc0204b46:	ae0ff0ef          	jal	ra,ffffffffc0203e26 <page_insert>
            assert(ret == 0);
ffffffffc0204b4a:	ea0500e3          	beqz	a0,ffffffffc02049ea <copy_range+0x7c>
ffffffffc0204b4e:	bf2d                	j	ffffffffc0204a88 <copy_range+0x11a>
                return -E_NO_MEM;
ffffffffc0204b50:	5571                	li	a0,-4
ffffffffc0204b52:	b545                	j	ffffffffc02049f2 <copy_range+0x84>
ffffffffc0204b54:	86ba                	mv	a3,a4
ffffffffc0204b56:	00003617          	auipc	a2,0x3
ffffffffc0204b5a:	9c260613          	addi	a2,a2,-1598 # ffffffffc0207518 <commands+0xc00>
ffffffffc0204b5e:	06900593          	li	a1,105
ffffffffc0204b62:	00003517          	auipc	a0,0x3
ffffffffc0204b66:	9a650513          	addi	a0,a0,-1626 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0204b6a:	eacfb0ef          	jal	ra,ffffffffc0200216 <__panic>
                assert(page!=NULL);
ffffffffc0204b6e:	00003697          	auipc	a3,0x3
ffffffffc0204b72:	40a68693          	addi	a3,a3,1034 # ffffffffc0207f78 <default_pmm_manager+0x68>
ffffffffc0204b76:	00002617          	auipc	a2,0x2
ffffffffc0204b7a:	22260613          	addi	a2,a2,546 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204b7e:	17a00593          	li	a1,378
ffffffffc0204b82:	00003517          	auipc	a0,0x3
ffffffffc0204b86:	43e50513          	addi	a0,a0,1086 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204b8a:	e8cfb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0204b8e:	00002617          	auipc	a2,0x2
ffffffffc0204b92:	68a60613          	addi	a2,a2,1674 # ffffffffc0207218 <commands+0x900>
ffffffffc0204b96:	07400593          	li	a1,116
ffffffffc0204b9a:	00003517          	auipc	a0,0x3
ffffffffc0204b9e:	96e50513          	addi	a0,a0,-1682 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0204ba2:	e74fb0ef          	jal	ra,ffffffffc0200216 <__panic>
                assert(npage!=NULL);
ffffffffc0204ba6:	00003697          	auipc	a3,0x3
ffffffffc0204baa:	3e268693          	addi	a3,a3,994 # ffffffffc0207f88 <default_pmm_manager+0x78>
ffffffffc0204bae:	00002617          	auipc	a2,0x2
ffffffffc0204bb2:	1ea60613          	addi	a2,a2,490 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204bb6:	17b00593          	li	a1,379
ffffffffc0204bba:	00003517          	auipc	a0,0x3
ffffffffc0204bbe:	40650513          	addi	a0,a0,1030 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204bc2:	e54fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0204bc6:	00004697          	auipc	a3,0x4
ffffffffc0204bca:	97a68693          	addi	a3,a3,-1670 # ffffffffc0208540 <default_pmm_manager+0x630>
ffffffffc0204bce:	00002617          	auipc	a2,0x2
ffffffffc0204bd2:	1ca60613          	addi	a2,a2,458 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204bd6:	15e00593          	li	a1,350
ffffffffc0204bda:	00003517          	auipc	a0,0x3
ffffffffc0204bde:	3e650513          	addi	a0,a0,998 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204be2:	e34fb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204be6:	00003617          	auipc	a2,0x3
ffffffffc0204bea:	90260613          	addi	a2,a2,-1790 # ffffffffc02074e8 <commands+0xbd0>
ffffffffc0204bee:	06200593          	li	a1,98
ffffffffc0204bf2:	00003517          	auipc	a0,0x3
ffffffffc0204bf6:	91650513          	addi	a0,a0,-1770 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0204bfa:	e1cfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0204bfe:	00004697          	auipc	a3,0x4
ffffffffc0204c02:	91268693          	addi	a3,a3,-1774 # ffffffffc0208510 <default_pmm_manager+0x600>
ffffffffc0204c06:	00002617          	auipc	a2,0x2
ffffffffc0204c0a:	19260613          	addi	a2,a2,402 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204c0e:	15d00593          	li	a1,349
ffffffffc0204c12:	00003517          	auipc	a0,0x3
ffffffffc0204c16:	3ae50513          	addi	a0,a0,942 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204c1a:	dfcfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204c1e <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0204c1e:	12058073          	sfence.vma	a1
}
ffffffffc0204c22:	8082                	ret

ffffffffc0204c24 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204c24:	7179                	addi	sp,sp,-48
ffffffffc0204c26:	e84a                	sd	s2,16(sp)
ffffffffc0204c28:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0204c2a:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0204c2c:	f022                	sd	s0,32(sp)
ffffffffc0204c2e:	ec26                	sd	s1,24(sp)
ffffffffc0204c30:	e44e                	sd	s3,8(sp)
ffffffffc0204c32:	f406                	sd	ra,40(sp)
ffffffffc0204c34:	84ae                	mv	s1,a1
ffffffffc0204c36:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0204c38:	acbfe0ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0204c3c:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0204c3e:	cd1d                	beqz	a0,ffffffffc0204c7c <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0204c40:	85aa                	mv	a1,a0
ffffffffc0204c42:	86ce                	mv	a3,s3
ffffffffc0204c44:	8626                	mv	a2,s1
ffffffffc0204c46:	854a                	mv	a0,s2
ffffffffc0204c48:	9deff0ef          	jal	ra,ffffffffc0203e26 <page_insert>
ffffffffc0204c4c:	e121                	bnez	a0,ffffffffc0204c8c <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc0204c4e:	000a8797          	auipc	a5,0xa8
ffffffffc0204c52:	83a78793          	addi	a5,a5,-1990 # ffffffffc02ac488 <swap_init_ok>
ffffffffc0204c56:	439c                	lw	a5,0(a5)
ffffffffc0204c58:	2781                	sext.w	a5,a5
ffffffffc0204c5a:	c38d                	beqz	a5,ffffffffc0204c7c <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc0204c5c:	000a8797          	auipc	a5,0xa8
ffffffffc0204c60:	86c78793          	addi	a5,a5,-1940 # ffffffffc02ac4c8 <check_mm_struct>
ffffffffc0204c64:	6388                	ld	a0,0(a5)
ffffffffc0204c66:	c919                	beqz	a0,ffffffffc0204c7c <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0204c68:	4681                	li	a3,0
ffffffffc0204c6a:	8622                	mv	a2,s0
ffffffffc0204c6c:	85a6                	mv	a1,s1
ffffffffc0204c6e:	d8dfd0ef          	jal	ra,ffffffffc02029fa <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0204c72:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0204c74:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0204c76:	4785                	li	a5,1
ffffffffc0204c78:	02f71063          	bne	a4,a5,ffffffffc0204c98 <pgdir_alloc_page+0x74>
}
ffffffffc0204c7c:	8522                	mv	a0,s0
ffffffffc0204c7e:	70a2                	ld	ra,40(sp)
ffffffffc0204c80:	7402                	ld	s0,32(sp)
ffffffffc0204c82:	64e2                	ld	s1,24(sp)
ffffffffc0204c84:	6942                	ld	s2,16(sp)
ffffffffc0204c86:	69a2                	ld	s3,8(sp)
ffffffffc0204c88:	6145                	addi	sp,sp,48
ffffffffc0204c8a:	8082                	ret
            free_page(page);
ffffffffc0204c8c:	8522                	mv	a0,s0
ffffffffc0204c8e:	4585                	li	a1,1
ffffffffc0204c90:	afbfe0ef          	jal	ra,ffffffffc020378a <free_pages>
            return NULL;
ffffffffc0204c94:	4401                	li	s0,0
ffffffffc0204c96:	b7dd                	j	ffffffffc0204c7c <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc0204c98:	00003697          	auipc	a3,0x3
ffffffffc0204c9c:	33868693          	addi	a3,a3,824 # ffffffffc0207fd0 <default_pmm_manager+0xc0>
ffffffffc0204ca0:	00002617          	auipc	a2,0x2
ffffffffc0204ca4:	0f860613          	addi	a2,a2,248 # ffffffffc0206d98 <commands+0x480>
ffffffffc0204ca8:	1c100593          	li	a1,449
ffffffffc0204cac:	00003517          	auipc	a0,0x3
ffffffffc0204cb0:	31450513          	addi	a0,a0,788 # ffffffffc0207fc0 <default_pmm_manager+0xb0>
ffffffffc0204cb4:	d62fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204cb8 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204cb8:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204cba:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204cbc:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204cbe:	877fb0ef          	jal	ra,ffffffffc0200534 <ide_device_valid>
ffffffffc0204cc2:	cd01                	beqz	a0,ffffffffc0204cda <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204cc4:	4505                	li	a0,1
ffffffffc0204cc6:	875fb0ef          	jal	ra,ffffffffc020053a <ide_device_size>
}
ffffffffc0204cca:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204ccc:	810d                	srli	a0,a0,0x3
ffffffffc0204cce:	000a8797          	auipc	a5,0xa8
ffffffffc0204cd2:	88a7bd23          	sd	a0,-1894(a5) # ffffffffc02ac568 <max_swap_offset>
}
ffffffffc0204cd6:	0141                	addi	sp,sp,16
ffffffffc0204cd8:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204cda:	00004617          	auipc	a2,0x4
ffffffffc0204cde:	87e60613          	addi	a2,a2,-1922 # ffffffffc0208558 <default_pmm_manager+0x648>
ffffffffc0204ce2:	45b5                	li	a1,13
ffffffffc0204ce4:	00004517          	auipc	a0,0x4
ffffffffc0204ce8:	89450513          	addi	a0,a0,-1900 # ffffffffc0208578 <default_pmm_manager+0x668>
ffffffffc0204cec:	d2afb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204cf0 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204cf0:	1141                	addi	sp,sp,-16
ffffffffc0204cf2:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204cf4:	00855793          	srli	a5,a0,0x8
ffffffffc0204cf8:	cfb9                	beqz	a5,ffffffffc0204d56 <swapfs_read+0x66>
ffffffffc0204cfa:	000a8717          	auipc	a4,0xa8
ffffffffc0204cfe:	86e70713          	addi	a4,a4,-1938 # ffffffffc02ac568 <max_swap_offset>
ffffffffc0204d02:	6318                	ld	a4,0(a4)
ffffffffc0204d04:	04e7f963          	bleu	a4,a5,ffffffffc0204d56 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204d08:	000a8717          	auipc	a4,0xa8
ffffffffc0204d0c:	8d070713          	addi	a4,a4,-1840 # ffffffffc02ac5d8 <pages>
ffffffffc0204d10:	6310                	ld	a2,0(a4)
ffffffffc0204d12:	00004717          	auipc	a4,0x4
ffffffffc0204d16:	1be70713          	addi	a4,a4,446 # ffffffffc0208ed0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204d1a:	000a7697          	auipc	a3,0xa7
ffffffffc0204d1e:	77e68693          	addi	a3,a3,1918 # ffffffffc02ac498 <npage>
    return page - pages + nbase;
ffffffffc0204d22:	40c58633          	sub	a2,a1,a2
ffffffffc0204d26:	630c                	ld	a1,0(a4)
ffffffffc0204d28:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204d2a:	577d                	li	a4,-1
ffffffffc0204d2c:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204d2e:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204d30:	8331                	srli	a4,a4,0xc
ffffffffc0204d32:	8f71                	and	a4,a4,a2
ffffffffc0204d34:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d38:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204d3a:	02d77a63          	bleu	a3,a4,ffffffffc0204d6e <swapfs_read+0x7e>
ffffffffc0204d3e:	000a8797          	auipc	a5,0xa8
ffffffffc0204d42:	88a78793          	addi	a5,a5,-1910 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0204d46:	639c                	ld	a5,0(a5)
}
ffffffffc0204d48:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d4a:	46a1                	li	a3,8
ffffffffc0204d4c:	963e                	add	a2,a2,a5
ffffffffc0204d4e:	4505                	li	a0,1
}
ffffffffc0204d50:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d52:	feefb06f          	j	ffffffffc0200540 <ide_read_secs>
ffffffffc0204d56:	86aa                	mv	a3,a0
ffffffffc0204d58:	00004617          	auipc	a2,0x4
ffffffffc0204d5c:	83860613          	addi	a2,a2,-1992 # ffffffffc0208590 <default_pmm_manager+0x680>
ffffffffc0204d60:	45d1                	li	a1,20
ffffffffc0204d62:	00004517          	auipc	a0,0x4
ffffffffc0204d66:	81650513          	addi	a0,a0,-2026 # ffffffffc0208578 <default_pmm_manager+0x668>
ffffffffc0204d6a:	cacfb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204d6e:	86b2                	mv	a3,a2
ffffffffc0204d70:	06900593          	li	a1,105
ffffffffc0204d74:	00002617          	auipc	a2,0x2
ffffffffc0204d78:	7a460613          	addi	a2,a2,1956 # ffffffffc0207518 <commands+0xc00>
ffffffffc0204d7c:	00002517          	auipc	a0,0x2
ffffffffc0204d80:	78c50513          	addi	a0,a0,1932 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0204d84:	c92fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204d88 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204d88:	1141                	addi	sp,sp,-16
ffffffffc0204d8a:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d8c:	00855793          	srli	a5,a0,0x8
ffffffffc0204d90:	cfb9                	beqz	a5,ffffffffc0204dee <swapfs_write+0x66>
ffffffffc0204d92:	000a7717          	auipc	a4,0xa7
ffffffffc0204d96:	7d670713          	addi	a4,a4,2006 # ffffffffc02ac568 <max_swap_offset>
ffffffffc0204d9a:	6318                	ld	a4,0(a4)
ffffffffc0204d9c:	04e7f963          	bleu	a4,a5,ffffffffc0204dee <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204da0:	000a8717          	auipc	a4,0xa8
ffffffffc0204da4:	83870713          	addi	a4,a4,-1992 # ffffffffc02ac5d8 <pages>
ffffffffc0204da8:	6310                	ld	a2,0(a4)
ffffffffc0204daa:	00004717          	auipc	a4,0x4
ffffffffc0204dae:	12670713          	addi	a4,a4,294 # ffffffffc0208ed0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204db2:	000a7697          	auipc	a3,0xa7
ffffffffc0204db6:	6e668693          	addi	a3,a3,1766 # ffffffffc02ac498 <npage>
    return page - pages + nbase;
ffffffffc0204dba:	40c58633          	sub	a2,a1,a2
ffffffffc0204dbe:	630c                	ld	a1,0(a4)
ffffffffc0204dc0:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204dc2:	577d                	li	a4,-1
ffffffffc0204dc4:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204dc6:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204dc8:	8331                	srli	a4,a4,0xc
ffffffffc0204dca:	8f71                	and	a4,a4,a2
ffffffffc0204dcc:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204dd0:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204dd2:	02d77a63          	bleu	a3,a4,ffffffffc0204e06 <swapfs_write+0x7e>
ffffffffc0204dd6:	000a7797          	auipc	a5,0xa7
ffffffffc0204dda:	7f278793          	addi	a5,a5,2034 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0204dde:	639c                	ld	a5,0(a5)
}
ffffffffc0204de0:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204de2:	46a1                	li	a3,8
ffffffffc0204de4:	963e                	add	a2,a2,a5
ffffffffc0204de6:	4505                	li	a0,1
}
ffffffffc0204de8:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204dea:	f7afb06f          	j	ffffffffc0200564 <ide_write_secs>
ffffffffc0204dee:	86aa                	mv	a3,a0
ffffffffc0204df0:	00003617          	auipc	a2,0x3
ffffffffc0204df4:	7a060613          	addi	a2,a2,1952 # ffffffffc0208590 <default_pmm_manager+0x680>
ffffffffc0204df8:	45e5                	li	a1,25
ffffffffc0204dfa:	00003517          	auipc	a0,0x3
ffffffffc0204dfe:	77e50513          	addi	a0,a0,1918 # ffffffffc0208578 <default_pmm_manager+0x668>
ffffffffc0204e02:	c14fb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204e06:	86b2                	mv	a3,a2
ffffffffc0204e08:	06900593          	li	a1,105
ffffffffc0204e0c:	00002617          	auipc	a2,0x2
ffffffffc0204e10:	70c60613          	addi	a2,a2,1804 # ffffffffc0207518 <commands+0xc00>
ffffffffc0204e14:	00002517          	auipc	a0,0x2
ffffffffc0204e18:	6f450513          	addi	a0,a0,1780 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0204e1c:	bfafb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204e20 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204e20:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204e24:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204e28:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204e2a:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204e2c:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204e30:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204e34:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204e38:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204e3c:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204e40:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204e44:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204e48:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204e4c:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204e50:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204e54:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204e58:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204e5c:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204e5e:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204e60:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204e64:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204e68:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204e6c:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204e70:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204e74:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204e78:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204e7c:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204e80:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204e84:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204e88:	8082                	ret

ffffffffc0204e8a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204e8a:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204e8c:	9402                	jalr	s0

	jal do_exit
ffffffffc0204e8e:	732000ef          	jal	ra,ffffffffc02055c0 <do_exit>

ffffffffc0204e92 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204e92:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204e94:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204e98:	e022                	sd	s0,0(sp)
ffffffffc0204e9a:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204e9c:	9eefd0ef          	jal	ra,ffffffffc020208a <kmalloc>
ffffffffc0204ea0:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204ea2:	cd29                	beqz	a0,ffffffffc0204efc <alloc_proc+0x6a>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    proc->state = PROC_UNINIT;
ffffffffc0204ea4:	57fd                	li	a5,-1
ffffffffc0204ea6:	1782                	slli	a5,a5,0x20
ffffffffc0204ea8:	e11c                	sd	a5,0(a0)
    proc->runs = 0;
    proc->kstack = 0;
    proc-> need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204eaa:	07000613          	li	a2,112
ffffffffc0204eae:	4581                	li	a1,0
    proc->runs = 0;
ffffffffc0204eb0:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204eb4:	00053823          	sd	zero,16(a0)
    proc-> need_resched = 0;
ffffffffc0204eb8:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;
ffffffffc0204ebc:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204ec0:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204ec4:	03050513          	addi	a0,a0,48
ffffffffc0204ec8:	4a4010ef          	jal	ra,ffffffffc020636c <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc0204ecc:	000a7797          	auipc	a5,0xa7
ffffffffc0204ed0:	70478793          	addi	a5,a5,1796 # ffffffffc02ac5d0 <boot_cr3>
ffffffffc0204ed4:	639c                	ld	a5,0(a5)
    proc->tf = NULL;
ffffffffc0204ed6:	0a043023          	sd	zero,160(s0)
    proc->flags = 0;
ffffffffc0204eda:	0a042823          	sw	zero,176(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204ede:	f45c                	sd	a5,168(s0)
    memset(&(proc->name), 0, PROC_NAME_LEN + 1);                
ffffffffc0204ee0:	4641                	li	a2,16
ffffffffc0204ee2:	4581                	li	a1,0
ffffffffc0204ee4:	0b440513          	addi	a0,s0,180
ffffffffc0204ee8:	484010ef          	jal	ra,ffffffffc020636c <memset>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->wait_state = 0;
ffffffffc0204eec:	0e042623          	sw	zero,236(s0)
    proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0204ef0:	10043023          	sd	zero,256(s0)
ffffffffc0204ef4:	0e043c23          	sd	zero,248(s0)
ffffffffc0204ef8:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc0204efc:	8522                	mv	a0,s0
ffffffffc0204efe:	60a2                	ld	ra,8(sp)
ffffffffc0204f00:	6402                	ld	s0,0(sp)
ffffffffc0204f02:	0141                	addi	sp,sp,16
ffffffffc0204f04:	8082                	ret

ffffffffc0204f06 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204f06:	000a7797          	auipc	a5,0xa7
ffffffffc0204f0a:	59a78793          	addi	a5,a5,1434 # ffffffffc02ac4a0 <current>
ffffffffc0204f0e:	639c                	ld	a5,0(a5)
ffffffffc0204f10:	73c8                	ld	a0,160(a5)
ffffffffc0204f12:	e99fb06f          	j	ffffffffc0200daa <forkrets>

ffffffffc0204f16 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204f16:	000a7797          	auipc	a5,0xa7
ffffffffc0204f1a:	58a78793          	addi	a5,a5,1418 # ffffffffc02ac4a0 <current>
ffffffffc0204f1e:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204f20:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204f22:	00004617          	auipc	a2,0x4
ffffffffc0204f26:	a7e60613          	addi	a2,a2,-1410 # ffffffffc02089a0 <default_pmm_manager+0xa90>
ffffffffc0204f2a:	43cc                	lw	a1,4(a5)
ffffffffc0204f2c:	00004517          	auipc	a0,0x4
ffffffffc0204f30:	a8450513          	addi	a0,a0,-1404 # ffffffffc02089b0 <default_pmm_manager+0xaa0>
user_main(void *arg) {
ffffffffc0204f34:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204f36:	99afb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204f3a:	00004797          	auipc	a5,0x4
ffffffffc0204f3e:	a6678793          	addi	a5,a5,-1434 # ffffffffc02089a0 <default_pmm_manager+0xa90>
ffffffffc0204f42:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204f46:	39e70713          	addi	a4,a4,926 # a2e0 <_binary_obj___user_forktest_out_size>
ffffffffc0204f4a:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204f4c:	853e                	mv	a0,a5
ffffffffc0204f4e:	00092717          	auipc	a4,0x92
ffffffffc0204f52:	dd270713          	addi	a4,a4,-558 # ffffffffc0296d20 <_binary_obj___user_forktest_out_start>
ffffffffc0204f56:	f03a                	sd	a4,32(sp)
ffffffffc0204f58:	f43e                	sd	a5,40(sp)
ffffffffc0204f5a:	e802                	sd	zero,16(sp)
ffffffffc0204f5c:	372010ef          	jal	ra,ffffffffc02062ce <strlen>
ffffffffc0204f60:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204f62:	4511                	li	a0,4
ffffffffc0204f64:	55a2                	lw	a1,40(sp)
ffffffffc0204f66:	4662                	lw	a2,24(sp)
ffffffffc0204f68:	5682                	lw	a3,32(sp)
ffffffffc0204f6a:	4722                	lw	a4,8(sp)
ffffffffc0204f6c:	48a9                	li	a7,10
ffffffffc0204f6e:	9002                	ebreak
ffffffffc0204f70:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204f72:	65c2                	ld	a1,16(sp)
ffffffffc0204f74:	00004517          	auipc	a0,0x4
ffffffffc0204f78:	a6450513          	addi	a0,a0,-1436 # ffffffffc02089d8 <default_pmm_manager+0xac8>
ffffffffc0204f7c:	954fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204f80:	00004617          	auipc	a2,0x4
ffffffffc0204f84:	a6860613          	addi	a2,a2,-1432 # ffffffffc02089e8 <default_pmm_manager+0xad8>
ffffffffc0204f88:	34800593          	li	a1,840
ffffffffc0204f8c:	00004517          	auipc	a0,0x4
ffffffffc0204f90:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0204f94:	a82fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204f98 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204f98:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204f9a:	1141                	addi	sp,sp,-16
ffffffffc0204f9c:	e406                	sd	ra,8(sp)
ffffffffc0204f9e:	c02007b7          	lui	a5,0xc0200
ffffffffc0204fa2:	04f6e263          	bltu	a3,a5,ffffffffc0204fe6 <put_pgdir+0x4e>
ffffffffc0204fa6:	000a7797          	auipc	a5,0xa7
ffffffffc0204faa:	62278793          	addi	a5,a5,1570 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0204fae:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204fb0:	000a7797          	auipc	a5,0xa7
ffffffffc0204fb4:	4e878793          	addi	a5,a5,1256 # ffffffffc02ac498 <npage>
ffffffffc0204fb8:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204fba:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204fbc:	82b1                	srli	a3,a3,0xc
ffffffffc0204fbe:	04f6f063          	bleu	a5,a3,ffffffffc0204ffe <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204fc2:	00004797          	auipc	a5,0x4
ffffffffc0204fc6:	f0e78793          	addi	a5,a5,-242 # ffffffffc0208ed0 <nbase>
ffffffffc0204fca:	639c                	ld	a5,0(a5)
ffffffffc0204fcc:	000a7717          	auipc	a4,0xa7
ffffffffc0204fd0:	60c70713          	addi	a4,a4,1548 # ffffffffc02ac5d8 <pages>
ffffffffc0204fd4:	6308                	ld	a0,0(a4)
}
ffffffffc0204fd6:	60a2                	ld	ra,8(sp)
ffffffffc0204fd8:	8e9d                	sub	a3,a3,a5
ffffffffc0204fda:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204fdc:	4585                	li	a1,1
ffffffffc0204fde:	9536                	add	a0,a0,a3
}
ffffffffc0204fe0:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204fe2:	fa8fe06f          	j	ffffffffc020378a <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204fe6:	00002617          	auipc	a2,0x2
ffffffffc0204fea:	7aa60613          	addi	a2,a2,1962 # ffffffffc0207790 <commands+0xe78>
ffffffffc0204fee:	06e00593          	li	a1,110
ffffffffc0204ff2:	00002517          	auipc	a0,0x2
ffffffffc0204ff6:	51650513          	addi	a0,a0,1302 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0204ffa:	a1cfb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204ffe:	00002617          	auipc	a2,0x2
ffffffffc0205002:	4ea60613          	addi	a2,a2,1258 # ffffffffc02074e8 <commands+0xbd0>
ffffffffc0205006:	06200593          	li	a1,98
ffffffffc020500a:	00002517          	auipc	a0,0x2
ffffffffc020500e:	4fe50513          	addi	a0,a0,1278 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0205012:	a04fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205016 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0205016:	1101                	addi	sp,sp,-32
ffffffffc0205018:	e426                	sd	s1,8(sp)
ffffffffc020501a:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc020501c:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc020501e:	ec06                	sd	ra,24(sp)
ffffffffc0205020:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0205022:	ee0fe0ef          	jal	ra,ffffffffc0203702 <alloc_pages>
ffffffffc0205026:	c125                	beqz	a0,ffffffffc0205086 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0205028:	000a7797          	auipc	a5,0xa7
ffffffffc020502c:	5b078793          	addi	a5,a5,1456 # ffffffffc02ac5d8 <pages>
ffffffffc0205030:	6394                	ld	a3,0(a5)
ffffffffc0205032:	00004797          	auipc	a5,0x4
ffffffffc0205036:	e9e78793          	addi	a5,a5,-354 # ffffffffc0208ed0 <nbase>
ffffffffc020503a:	6380                	ld	s0,0(a5)
ffffffffc020503c:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0205040:	000a7717          	auipc	a4,0xa7
ffffffffc0205044:	45870713          	addi	a4,a4,1112 # ffffffffc02ac498 <npage>
    return page - pages + nbase;
ffffffffc0205048:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020504a:	57fd                	li	a5,-1
ffffffffc020504c:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc020504e:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0205050:	83b1                	srli	a5,a5,0xc
ffffffffc0205052:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205054:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205056:	02e7fa63          	bleu	a4,a5,ffffffffc020508a <setup_pgdir+0x74>
ffffffffc020505a:	000a7797          	auipc	a5,0xa7
ffffffffc020505e:	56e78793          	addi	a5,a5,1390 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0205062:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205064:	000a7797          	auipc	a5,0xa7
ffffffffc0205068:	42c78793          	addi	a5,a5,1068 # ffffffffc02ac490 <boot_pgdir>
ffffffffc020506c:	638c                	ld	a1,0(a5)
ffffffffc020506e:	9436                	add	s0,s0,a3
ffffffffc0205070:	6605                	lui	a2,0x1
ffffffffc0205072:	8522                	mv	a0,s0
ffffffffc0205074:	30a010ef          	jal	ra,ffffffffc020637e <memcpy>
    return 0;
ffffffffc0205078:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc020507a:	ec80                	sd	s0,24(s1)
}
ffffffffc020507c:	60e2                	ld	ra,24(sp)
ffffffffc020507e:	6442                	ld	s0,16(sp)
ffffffffc0205080:	64a2                	ld	s1,8(sp)
ffffffffc0205082:	6105                	addi	sp,sp,32
ffffffffc0205084:	8082                	ret
        return -E_NO_MEM;
ffffffffc0205086:	5571                	li	a0,-4
ffffffffc0205088:	bfd5                	j	ffffffffc020507c <setup_pgdir+0x66>
ffffffffc020508a:	00002617          	auipc	a2,0x2
ffffffffc020508e:	48e60613          	addi	a2,a2,1166 # ffffffffc0207518 <commands+0xc00>
ffffffffc0205092:	06900593          	li	a1,105
ffffffffc0205096:	00002517          	auipc	a0,0x2
ffffffffc020509a:	47250513          	addi	a0,a0,1138 # ffffffffc0207508 <commands+0xbf0>
ffffffffc020509e:	978fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02050a2 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02050a2:	1101                	addi	sp,sp,-32
ffffffffc02050a4:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050a6:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02050aa:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050ac:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02050ae:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050b0:	8522                	mv	a0,s0
ffffffffc02050b2:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02050b4:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050b6:	2b6010ef          	jal	ra,ffffffffc020636c <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050ba:	8522                	mv	a0,s0
}
ffffffffc02050bc:	6442                	ld	s0,16(sp)
ffffffffc02050be:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050c0:	85a6                	mv	a1,s1
}
ffffffffc02050c2:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050c4:	463d                	li	a2,15
}
ffffffffc02050c6:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050c8:	2b60106f          	j	ffffffffc020637e <memcpy>

ffffffffc02050cc <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc02050cc:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc02050ce:	000a7797          	auipc	a5,0xa7
ffffffffc02050d2:	3d278793          	addi	a5,a5,978 # ffffffffc02ac4a0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc02050d6:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc02050d8:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc02050da:	ec06                	sd	ra,24(sp)
ffffffffc02050dc:	e822                	sd	s0,16(sp)
ffffffffc02050de:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc02050e0:	02a48b63          	beq	s1,a0,ffffffffc0205116 <proc_run+0x4a>
ffffffffc02050e4:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050e6:	100027f3          	csrr	a5,sstatus
ffffffffc02050ea:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050ec:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050ee:	e3a9                	bnez	a5,ffffffffc0205130 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc02050f0:	745c                	ld	a5,168(s0)
        current = proc;
ffffffffc02050f2:	000a7717          	auipc	a4,0xa7
ffffffffc02050f6:	3a873723          	sd	s0,942(a4) # ffffffffc02ac4a0 <current>
ffffffffc02050fa:	577d                	li	a4,-1
ffffffffc02050fc:	177e                	slli	a4,a4,0x3f
ffffffffc02050fe:	83b1                	srli	a5,a5,0xc
ffffffffc0205100:	8fd9                	or	a5,a5,a4
ffffffffc0205102:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(next->context));
ffffffffc0205106:	03040593          	addi	a1,s0,48
ffffffffc020510a:	03048513          	addi	a0,s1,48
ffffffffc020510e:	d13ff0ef          	jal	ra,ffffffffc0204e20 <switch_to>
    if (flag) {
ffffffffc0205112:	00091863          	bnez	s2,ffffffffc0205122 <proc_run+0x56>
}
ffffffffc0205116:	60e2                	ld	ra,24(sp)
ffffffffc0205118:	6442                	ld	s0,16(sp)
ffffffffc020511a:	64a2                	ld	s1,8(sp)
ffffffffc020511c:	6902                	ld	s2,0(sp)
ffffffffc020511e:	6105                	addi	sp,sp,32
ffffffffc0205120:	8082                	ret
ffffffffc0205122:	6442                	ld	s0,16(sp)
ffffffffc0205124:	60e2                	ld	ra,24(sp)
ffffffffc0205126:	64a2                	ld	s1,8(sp)
ffffffffc0205128:	6902                	ld	s2,0(sp)
ffffffffc020512a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020512c:	d2afb06f          	j	ffffffffc0200656 <intr_enable>
        intr_disable();
ffffffffc0205130:	d2cfb0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0205134:	4905                	li	s2,1
ffffffffc0205136:	bf6d                	j	ffffffffc02050f0 <proc_run+0x24>

ffffffffc0205138 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205138:	0005071b          	sext.w	a4,a0
ffffffffc020513c:	6789                	lui	a5,0x2
ffffffffc020513e:	fff7069b          	addiw	a3,a4,-1
ffffffffc0205142:	17f9                	addi	a5,a5,-2
ffffffffc0205144:	04d7e063          	bltu	a5,a3,ffffffffc0205184 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0205148:	1141                	addi	sp,sp,-16
ffffffffc020514a:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020514c:	45a9                	li	a1,10
ffffffffc020514e:	842a                	mv	s0,a0
ffffffffc0205150:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0205152:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205154:	63a010ef          	jal	ra,ffffffffc020678e <hash32>
ffffffffc0205158:	02051693          	slli	a3,a0,0x20
ffffffffc020515c:	82f1                	srli	a3,a3,0x1c
ffffffffc020515e:	000a3517          	auipc	a0,0xa3
ffffffffc0205162:	30250513          	addi	a0,a0,770 # ffffffffc02a8460 <hash_list>
ffffffffc0205166:	96aa                	add	a3,a3,a0
ffffffffc0205168:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc020516a:	a029                	j	ffffffffc0205174 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc020516c:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x764c>
ffffffffc0205170:	00870c63          	beq	a4,s0,ffffffffc0205188 <find_proc+0x50>
    return listelm->next;
ffffffffc0205174:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205176:	fef69be3          	bne	a3,a5,ffffffffc020516c <find_proc+0x34>
}
ffffffffc020517a:	60a2                	ld	ra,8(sp)
ffffffffc020517c:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020517e:	4501                	li	a0,0
}
ffffffffc0205180:	0141                	addi	sp,sp,16
ffffffffc0205182:	8082                	ret
    return NULL;
ffffffffc0205184:	4501                	li	a0,0
}
ffffffffc0205186:	8082                	ret
ffffffffc0205188:	60a2                	ld	ra,8(sp)
ffffffffc020518a:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020518c:	f2878513          	addi	a0,a5,-216
}
ffffffffc0205190:	0141                	addi	sp,sp,16
ffffffffc0205192:	8082                	ret

ffffffffc0205194 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0205194:	7159                	addi	sp,sp,-112
ffffffffc0205196:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205198:	000a7a17          	auipc	s4,0xa7
ffffffffc020519c:	320a0a13          	addi	s4,s4,800 # ffffffffc02ac4b8 <nr_process>
ffffffffc02051a0:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02051a4:	f486                	sd	ra,104(sp)
ffffffffc02051a6:	f0a2                	sd	s0,96(sp)
ffffffffc02051a8:	eca6                	sd	s1,88(sp)
ffffffffc02051aa:	e8ca                	sd	s2,80(sp)
ffffffffc02051ac:	e4ce                	sd	s3,72(sp)
ffffffffc02051ae:	fc56                	sd	s5,56(sp)
ffffffffc02051b0:	f85a                	sd	s6,48(sp)
ffffffffc02051b2:	f45e                	sd	s7,40(sp)
ffffffffc02051b4:	f062                	sd	s8,32(sp)
ffffffffc02051b6:	ec66                	sd	s9,24(sp)
ffffffffc02051b8:	e86a                	sd	s10,16(sp)
ffffffffc02051ba:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02051bc:	6785                	lui	a5,0x1
ffffffffc02051be:	30f75a63          	ble	a5,a4,ffffffffc02054d2 <do_fork+0x33e>
ffffffffc02051c2:	89aa                	mv	s3,a0
ffffffffc02051c4:	892e                	mv	s2,a1
ffffffffc02051c6:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc02051c8:	ccbff0ef          	jal	ra,ffffffffc0204e92 <alloc_proc>
ffffffffc02051cc:	842a                	mv	s0,a0
ffffffffc02051ce:	2e050463          	beqz	a0,ffffffffc02054b6 <do_fork+0x322>
    proc->parent = current;
ffffffffc02051d2:	000a7c17          	auipc	s8,0xa7
ffffffffc02051d6:	2cec0c13          	addi	s8,s8,718 # ffffffffc02ac4a0 <current>
ffffffffc02051da:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);//make sure current process's wait_state is 0
ffffffffc02051de:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x848c>
    proc->parent = current;
ffffffffc02051e2:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);//make sure current process's wait_state is 0
ffffffffc02051e4:	30071563          	bnez	a4,ffffffffc02054ee <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02051e8:	4509                	li	a0,2
ffffffffc02051ea:	d18fe0ef          	jal	ra,ffffffffc0203702 <alloc_pages>
    if (page != NULL) {
ffffffffc02051ee:	2c050163          	beqz	a0,ffffffffc02054b0 <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc02051f2:	000a7a97          	auipc	s5,0xa7
ffffffffc02051f6:	3e6a8a93          	addi	s5,s5,998 # ffffffffc02ac5d8 <pages>
ffffffffc02051fa:	000ab683          	ld	a3,0(s5)
ffffffffc02051fe:	00004b17          	auipc	s6,0x4
ffffffffc0205202:	cd2b0b13          	addi	s6,s6,-814 # ffffffffc0208ed0 <nbase>
ffffffffc0205206:	000b3783          	ld	a5,0(s6)
ffffffffc020520a:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc020520e:	000a7b97          	auipc	s7,0xa7
ffffffffc0205212:	28ab8b93          	addi	s7,s7,650 # ffffffffc02ac498 <npage>
    return page - pages + nbase;
ffffffffc0205216:	8699                	srai	a3,a3,0x6
ffffffffc0205218:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020521a:	000bb703          	ld	a4,0(s7)
ffffffffc020521e:	57fd                	li	a5,-1
ffffffffc0205220:	83b1                	srli	a5,a5,0xc
ffffffffc0205222:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205224:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205226:	2ae7f863          	bleu	a4,a5,ffffffffc02054d6 <do_fork+0x342>
ffffffffc020522a:	000a7c97          	auipc	s9,0xa7
ffffffffc020522e:	39ec8c93          	addi	s9,s9,926 # ffffffffc02ac5c8 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205232:	000c3703          	ld	a4,0(s8)
ffffffffc0205236:	000cb783          	ld	a5,0(s9)
ffffffffc020523a:	02873c03          	ld	s8,40(a4)
ffffffffc020523e:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205240:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc0205242:	020c0863          	beqz	s8,ffffffffc0205272 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc0205246:	1009f993          	andi	s3,s3,256
ffffffffc020524a:	1e098163          	beqz	s3,ffffffffc020542c <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc020524e:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205252:	018c3783          	ld	a5,24(s8)
ffffffffc0205256:	c02006b7          	lui	a3,0xc0200
ffffffffc020525a:	2705                	addiw	a4,a4,1
ffffffffc020525c:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc0205260:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205264:	2ad7e563          	bltu	a5,a3,ffffffffc020550e <do_fork+0x37a>
ffffffffc0205268:	000cb703          	ld	a4,0(s9)
ffffffffc020526c:	6814                	ld	a3,16(s0)
ffffffffc020526e:	8f99                	sub	a5,a5,a4
ffffffffc0205270:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205272:	6789                	lui	a5,0x2
ffffffffc0205274:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7698>
ffffffffc0205278:	96be                	add	a3,a3,a5
ffffffffc020527a:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc020527c:	87b6                	mv	a5,a3
ffffffffc020527e:	12048813          	addi	a6,s1,288
ffffffffc0205282:	6088                	ld	a0,0(s1)
ffffffffc0205284:	648c                	ld	a1,8(s1)
ffffffffc0205286:	6890                	ld	a2,16(s1)
ffffffffc0205288:	6c98                	ld	a4,24(s1)
ffffffffc020528a:	e388                	sd	a0,0(a5)
ffffffffc020528c:	e78c                	sd	a1,8(a5)
ffffffffc020528e:	eb90                	sd	a2,16(a5)
ffffffffc0205290:	ef98                	sd	a4,24(a5)
ffffffffc0205292:	02048493          	addi	s1,s1,32
ffffffffc0205296:	02078793          	addi	a5,a5,32
ffffffffc020529a:	ff0494e3          	bne	s1,a6,ffffffffc0205282 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc020529e:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02052a2:	12090e63          	beqz	s2,ffffffffc02053de <do_fork+0x24a>
ffffffffc02052a6:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02052aa:	00000797          	auipc	a5,0x0
ffffffffc02052ae:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204f06 <forkret>
ffffffffc02052b2:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02052b4:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052b6:	100027f3          	csrr	a5,sstatus
ffffffffc02052ba:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02052bc:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052be:	12079f63          	bnez	a5,ffffffffc02053fc <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc02052c2:	0009c797          	auipc	a5,0x9c
ffffffffc02052c6:	d9678793          	addi	a5,a5,-618 # ffffffffc02a1058 <last_pid.1691>
ffffffffc02052ca:	439c                	lw	a5,0(a5)
ffffffffc02052cc:	6709                	lui	a4,0x2
ffffffffc02052ce:	0017851b          	addiw	a0,a5,1
ffffffffc02052d2:	0009c697          	auipc	a3,0x9c
ffffffffc02052d6:	d8a6a323          	sw	a0,-634(a3) # ffffffffc02a1058 <last_pid.1691>
ffffffffc02052da:	14e55263          	ble	a4,a0,ffffffffc020541e <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc02052de:	0009c797          	auipc	a5,0x9c
ffffffffc02052e2:	d7e78793          	addi	a5,a5,-642 # ffffffffc02a105c <next_safe.1690>
ffffffffc02052e6:	439c                	lw	a5,0(a5)
ffffffffc02052e8:	000a7497          	auipc	s1,0xa7
ffffffffc02052ec:	2f848493          	addi	s1,s1,760 # ffffffffc02ac5e0 <proc_list>
ffffffffc02052f0:	06f54063          	blt	a0,a5,ffffffffc0205350 <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc02052f4:	6789                	lui	a5,0x2
ffffffffc02052f6:	0009c717          	auipc	a4,0x9c
ffffffffc02052fa:	d6f72323          	sw	a5,-666(a4) # ffffffffc02a105c <next_safe.1690>
ffffffffc02052fe:	4581                	li	a1,0
ffffffffc0205300:	87aa                	mv	a5,a0
ffffffffc0205302:	000a7497          	auipc	s1,0xa7
ffffffffc0205306:	2de48493          	addi	s1,s1,734 # ffffffffc02ac5e0 <proc_list>
    repeat:
ffffffffc020530a:	6889                	lui	a7,0x2
ffffffffc020530c:	882e                	mv	a6,a1
ffffffffc020530e:	6609                	lui	a2,0x2
        le = list;
ffffffffc0205310:	000a7697          	auipc	a3,0xa7
ffffffffc0205314:	2d068693          	addi	a3,a3,720 # ffffffffc02ac5e0 <proc_list>
ffffffffc0205318:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc020531a:	00968f63          	beq	a3,s1,ffffffffc0205338 <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc020531e:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205322:	0ae78963          	beq	a5,a4,ffffffffc02053d4 <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205326:	fee7d9e3          	ble	a4,a5,ffffffffc0205318 <do_fork+0x184>
ffffffffc020532a:	fec757e3          	ble	a2,a4,ffffffffc0205318 <do_fork+0x184>
ffffffffc020532e:	6694                	ld	a3,8(a3)
ffffffffc0205330:	863a                	mv	a2,a4
ffffffffc0205332:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0205334:	fe9695e3          	bne	a3,s1,ffffffffc020531e <do_fork+0x18a>
ffffffffc0205338:	c591                	beqz	a1,ffffffffc0205344 <do_fork+0x1b0>
ffffffffc020533a:	0009c717          	auipc	a4,0x9c
ffffffffc020533e:	d0f72f23          	sw	a5,-738(a4) # ffffffffc02a1058 <last_pid.1691>
ffffffffc0205342:	853e                	mv	a0,a5
ffffffffc0205344:	00080663          	beqz	a6,ffffffffc0205350 <do_fork+0x1bc>
ffffffffc0205348:	0009c797          	auipc	a5,0x9c
ffffffffc020534c:	d0c7aa23          	sw	a2,-748(a5) # ffffffffc02a105c <next_safe.1690>
        proc->pid = get_pid();
ffffffffc0205350:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205352:	45a9                	li	a1,10
ffffffffc0205354:	2501                	sext.w	a0,a0
ffffffffc0205356:	438010ef          	jal	ra,ffffffffc020678e <hash32>
ffffffffc020535a:	1502                	slli	a0,a0,0x20
ffffffffc020535c:	000a3797          	auipc	a5,0xa3
ffffffffc0205360:	10478793          	addi	a5,a5,260 # ffffffffc02a8460 <hash_list>
ffffffffc0205364:	8171                	srli	a0,a0,0x1c
ffffffffc0205366:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205368:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020536a:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020536c:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0205370:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205372:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0205374:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205376:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0205378:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc020537c:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc020537e:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0205380:	e21c                	sd	a5,0(a2)
ffffffffc0205382:	000a7597          	auipc	a1,0xa7
ffffffffc0205386:	26f5b323          	sd	a5,614(a1) # ffffffffc02ac5e8 <proc_list+0x8>
    elm->next = next;
ffffffffc020538a:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc020538c:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc020538e:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205392:	10e43023          	sd	a4,256(s0)
ffffffffc0205396:	c311                	beqz	a4,ffffffffc020539a <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc0205398:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc020539a:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc020539e:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc02053a0:	2785                	addiw	a5,a5,1
ffffffffc02053a2:	000a7717          	auipc	a4,0xa7
ffffffffc02053a6:	10f72b23          	sw	a5,278(a4) # ffffffffc02ac4b8 <nr_process>
    if (flag) {
ffffffffc02053aa:	10091863          	bnez	s2,ffffffffc02054ba <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc02053ae:	8522                	mv	a0,s0
ffffffffc02053b0:	52d000ef          	jal	ra,ffffffffc02060dc <wakeup_proc>
    ret = proc->pid;
ffffffffc02053b4:	4048                	lw	a0,4(s0)
}
ffffffffc02053b6:	70a6                	ld	ra,104(sp)
ffffffffc02053b8:	7406                	ld	s0,96(sp)
ffffffffc02053ba:	64e6                	ld	s1,88(sp)
ffffffffc02053bc:	6946                	ld	s2,80(sp)
ffffffffc02053be:	69a6                	ld	s3,72(sp)
ffffffffc02053c0:	6a06                	ld	s4,64(sp)
ffffffffc02053c2:	7ae2                	ld	s5,56(sp)
ffffffffc02053c4:	7b42                	ld	s6,48(sp)
ffffffffc02053c6:	7ba2                	ld	s7,40(sp)
ffffffffc02053c8:	7c02                	ld	s8,32(sp)
ffffffffc02053ca:	6ce2                	ld	s9,24(sp)
ffffffffc02053cc:	6d42                	ld	s10,16(sp)
ffffffffc02053ce:	6da2                	ld	s11,8(sp)
ffffffffc02053d0:	6165                	addi	sp,sp,112
ffffffffc02053d2:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc02053d4:	2785                	addiw	a5,a5,1
ffffffffc02053d6:	0ec7d563          	ble	a2,a5,ffffffffc02054c0 <do_fork+0x32c>
ffffffffc02053da:	4585                	li	a1,1
ffffffffc02053dc:	bf35                	j	ffffffffc0205318 <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02053de:	8936                	mv	s2,a3
ffffffffc02053e0:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02053e4:	00000797          	auipc	a5,0x0
ffffffffc02053e8:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204f06 <forkret>
ffffffffc02053ec:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02053ee:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053f0:	100027f3          	csrr	a5,sstatus
ffffffffc02053f4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02053f6:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053f8:	ec0785e3          	beqz	a5,ffffffffc02052c2 <do_fork+0x12e>
        intr_disable();
ffffffffc02053fc:	a60fb0ef          	jal	ra,ffffffffc020065c <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205400:	0009c797          	auipc	a5,0x9c
ffffffffc0205404:	c5878793          	addi	a5,a5,-936 # ffffffffc02a1058 <last_pid.1691>
ffffffffc0205408:	439c                	lw	a5,0(a5)
ffffffffc020540a:	6709                	lui	a4,0x2
        return 1;
ffffffffc020540c:	4905                	li	s2,1
ffffffffc020540e:	0017851b          	addiw	a0,a5,1
ffffffffc0205412:	0009c697          	auipc	a3,0x9c
ffffffffc0205416:	c4a6a323          	sw	a0,-954(a3) # ffffffffc02a1058 <last_pid.1691>
ffffffffc020541a:	ece542e3          	blt	a0,a4,ffffffffc02052de <do_fork+0x14a>
        last_pid = 1;
ffffffffc020541e:	4785                	li	a5,1
ffffffffc0205420:	0009c717          	auipc	a4,0x9c
ffffffffc0205424:	c2f72c23          	sw	a5,-968(a4) # ffffffffc02a1058 <last_pid.1691>
ffffffffc0205428:	4505                	li	a0,1
ffffffffc020542a:	b5e9                	j	ffffffffc02052f4 <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc020542c:	a4ffb0ef          	jal	ra,ffffffffc0200e7a <mm_create>
ffffffffc0205430:	8d2a                	mv	s10,a0
ffffffffc0205432:	c539                	beqz	a0,ffffffffc0205480 <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205434:	be3ff0ef          	jal	ra,ffffffffc0205016 <setup_pgdir>
ffffffffc0205438:	e949                	bnez	a0,ffffffffc02054ca <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc020543a:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020543e:	4785                	li	a5,1
ffffffffc0205440:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc0205444:	8b85                	andi	a5,a5,1
ffffffffc0205446:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205448:	c799                	beqz	a5,ffffffffc0205456 <do_fork+0x2c2>
        schedule();
ffffffffc020544a:	50f000ef          	jal	ra,ffffffffc0206158 <schedule>
ffffffffc020544e:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc0205452:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc0205454:	fbfd                	bnez	a5,ffffffffc020544a <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205456:	85e2                	mv	a1,s8
ffffffffc0205458:	856a                	mv	a0,s10
ffffffffc020545a:	cabfb0ef          	jal	ra,ffffffffc0201104 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020545e:	57f9                	li	a5,-2
ffffffffc0205460:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc0205464:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205466:	c3e9                	beqz	a5,ffffffffc0205528 <do_fork+0x394>
    if (ret != 0) {
ffffffffc0205468:	8c6a                	mv	s8,s10
ffffffffc020546a:	de0502e3          	beqz	a0,ffffffffc020524e <do_fork+0xba>
    exit_mmap(mm);
ffffffffc020546e:	856a                	mv	a0,s10
ffffffffc0205470:	d31fb0ef          	jal	ra,ffffffffc02011a0 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205474:	856a                	mv	a0,s10
ffffffffc0205476:	b23ff0ef          	jal	ra,ffffffffc0204f98 <put_pgdir>
    mm_destroy(mm);
ffffffffc020547a:	856a                	mv	a0,s10
ffffffffc020547c:	b85fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205480:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205482:	c02007b7          	lui	a5,0xc0200
ffffffffc0205486:	0cf6e963          	bltu	a3,a5,ffffffffc0205558 <do_fork+0x3c4>
ffffffffc020548a:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc020548e:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0205492:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205496:	83b1                	srli	a5,a5,0xc
ffffffffc0205498:	0ae7f463          	bleu	a4,a5,ffffffffc0205540 <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc020549c:	000b3703          	ld	a4,0(s6)
ffffffffc02054a0:	000ab503          	ld	a0,0(s5)
ffffffffc02054a4:	4589                	li	a1,2
ffffffffc02054a6:	8f99                	sub	a5,a5,a4
ffffffffc02054a8:	079a                	slli	a5,a5,0x6
ffffffffc02054aa:	953e                	add	a0,a0,a5
ffffffffc02054ac:	adefe0ef          	jal	ra,ffffffffc020378a <free_pages>
    kfree(proc);
ffffffffc02054b0:	8522                	mv	a0,s0
ffffffffc02054b2:	c95fc0ef          	jal	ra,ffffffffc0202146 <kfree>
    ret = -E_NO_MEM;
ffffffffc02054b6:	5571                	li	a0,-4
    return ret;
ffffffffc02054b8:	bdfd                	j	ffffffffc02053b6 <do_fork+0x222>
        intr_enable();
ffffffffc02054ba:	99cfb0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc02054be:	bdc5                	j	ffffffffc02053ae <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc02054c0:	0117c363          	blt	a5,a7,ffffffffc02054c6 <do_fork+0x332>
                        last_pid = 1;
ffffffffc02054c4:	4785                	li	a5,1
                    goto repeat;
ffffffffc02054c6:	4585                	li	a1,1
ffffffffc02054c8:	b591                	j	ffffffffc020530c <do_fork+0x178>
    mm_destroy(mm);
ffffffffc02054ca:	856a                	mv	a0,s10
ffffffffc02054cc:	b35fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
ffffffffc02054d0:	bf45                	j	ffffffffc0205480 <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc02054d2:	556d                	li	a0,-5
ffffffffc02054d4:	b5cd                	j	ffffffffc02053b6 <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc02054d6:	00002617          	auipc	a2,0x2
ffffffffc02054da:	04260613          	addi	a2,a2,66 # ffffffffc0207518 <commands+0xc00>
ffffffffc02054de:	06900593          	li	a1,105
ffffffffc02054e2:	00002517          	auipc	a0,0x2
ffffffffc02054e6:	02650513          	addi	a0,a0,38 # ffffffffc0207508 <commands+0xbf0>
ffffffffc02054ea:	d2dfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(current->wait_state == 0);//make sure current process's wait_state is 0
ffffffffc02054ee:	00003697          	auipc	a3,0x3
ffffffffc02054f2:	28a68693          	addi	a3,a3,650 # ffffffffc0208778 <default_pmm_manager+0x868>
ffffffffc02054f6:	00002617          	auipc	a2,0x2
ffffffffc02054fa:	8a260613          	addi	a2,a2,-1886 # ffffffffc0206d98 <commands+0x480>
ffffffffc02054fe:	19f00593          	li	a1,415
ffffffffc0205502:	00003517          	auipc	a0,0x3
ffffffffc0205506:	50650513          	addi	a0,a0,1286 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc020550a:	d0dfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020550e:	86be                	mv	a3,a5
ffffffffc0205510:	00002617          	auipc	a2,0x2
ffffffffc0205514:	28060613          	addi	a2,a2,640 # ffffffffc0207790 <commands+0xe78>
ffffffffc0205518:	16300593          	li	a1,355
ffffffffc020551c:	00003517          	auipc	a0,0x3
ffffffffc0205520:	4ec50513          	addi	a0,a0,1260 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0205524:	cf3fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("Unlock failed.\n");
ffffffffc0205528:	00003617          	auipc	a2,0x3
ffffffffc020552c:	27060613          	addi	a2,a2,624 # ffffffffc0208798 <default_pmm_manager+0x888>
ffffffffc0205530:	03100593          	li	a1,49
ffffffffc0205534:	00003517          	auipc	a0,0x3
ffffffffc0205538:	27450513          	addi	a0,a0,628 # ffffffffc02087a8 <default_pmm_manager+0x898>
ffffffffc020553c:	cdbfa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205540:	00002617          	auipc	a2,0x2
ffffffffc0205544:	fa860613          	addi	a2,a2,-88 # ffffffffc02074e8 <commands+0xbd0>
ffffffffc0205548:	06200593          	li	a1,98
ffffffffc020554c:	00002517          	auipc	a0,0x2
ffffffffc0205550:	fbc50513          	addi	a0,a0,-68 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0205554:	cc3fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205558:	00002617          	auipc	a2,0x2
ffffffffc020555c:	23860613          	addi	a2,a2,568 # ffffffffc0207790 <commands+0xe78>
ffffffffc0205560:	06e00593          	li	a1,110
ffffffffc0205564:	00002517          	auipc	a0,0x2
ffffffffc0205568:	fa450513          	addi	a0,a0,-92 # ffffffffc0207508 <commands+0xbf0>
ffffffffc020556c:	cabfa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205570 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205570:	7129                	addi	sp,sp,-320
ffffffffc0205572:	fa22                	sd	s0,304(sp)
ffffffffc0205574:	f626                	sd	s1,296(sp)
ffffffffc0205576:	f24a                	sd	s2,288(sp)
ffffffffc0205578:	84ae                	mv	s1,a1
ffffffffc020557a:	892a                	mv	s2,a0
ffffffffc020557c:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020557e:	4581                	li	a1,0
ffffffffc0205580:	12000613          	li	a2,288
ffffffffc0205584:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205586:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205588:	5e5000ef          	jal	ra,ffffffffc020636c <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020558c:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020558e:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205590:	100027f3          	csrr	a5,sstatus
ffffffffc0205594:	edd7f793          	andi	a5,a5,-291
ffffffffc0205598:	1207e793          	ori	a5,a5,288
ffffffffc020559c:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020559e:	860a                	mv	a2,sp
ffffffffc02055a0:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02055a4:	00000797          	auipc	a5,0x0
ffffffffc02055a8:	8e678793          	addi	a5,a5,-1818 # ffffffffc0204e8a <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02055ac:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02055ae:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02055b0:	be5ff0ef          	jal	ra,ffffffffc0205194 <do_fork>
}
ffffffffc02055b4:	70f2                	ld	ra,312(sp)
ffffffffc02055b6:	7452                	ld	s0,304(sp)
ffffffffc02055b8:	74b2                	ld	s1,296(sp)
ffffffffc02055ba:	7912                	ld	s2,288(sp)
ffffffffc02055bc:	6131                	addi	sp,sp,320
ffffffffc02055be:	8082                	ret

ffffffffc02055c0 <do_exit>:
do_exit(int error_code) {
ffffffffc02055c0:	7179                	addi	sp,sp,-48
ffffffffc02055c2:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc02055c4:	000a7717          	auipc	a4,0xa7
ffffffffc02055c8:	ee470713          	addi	a4,a4,-284 # ffffffffc02ac4a8 <idleproc>
ffffffffc02055cc:	000a7917          	auipc	s2,0xa7
ffffffffc02055d0:	ed490913          	addi	s2,s2,-300 # ffffffffc02ac4a0 <current>
ffffffffc02055d4:	00093783          	ld	a5,0(s2)
ffffffffc02055d8:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc02055da:	f406                	sd	ra,40(sp)
ffffffffc02055dc:	f022                	sd	s0,32(sp)
ffffffffc02055de:	ec26                	sd	s1,24(sp)
ffffffffc02055e0:	e44e                	sd	s3,8(sp)
ffffffffc02055e2:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc02055e4:	0ce78c63          	beq	a5,a4,ffffffffc02056bc <do_exit+0xfc>
    if (current == initproc) {
ffffffffc02055e8:	000a7417          	auipc	s0,0xa7
ffffffffc02055ec:	ec840413          	addi	s0,s0,-312 # ffffffffc02ac4b0 <initproc>
ffffffffc02055f0:	6018                	ld	a4,0(s0)
ffffffffc02055f2:	0ee78b63          	beq	a5,a4,ffffffffc02056e8 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc02055f6:	7784                	ld	s1,40(a5)
ffffffffc02055f8:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc02055fa:	c48d                	beqz	s1,ffffffffc0205624 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc02055fc:	000a7797          	auipc	a5,0xa7
ffffffffc0205600:	fd478793          	addi	a5,a5,-44 # ffffffffc02ac5d0 <boot_cr3>
ffffffffc0205604:	639c                	ld	a5,0(a5)
ffffffffc0205606:	577d                	li	a4,-1
ffffffffc0205608:	177e                	slli	a4,a4,0x3f
ffffffffc020560a:	83b1                	srli	a5,a5,0xc
ffffffffc020560c:	8fd9                	or	a5,a5,a4
ffffffffc020560e:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205612:	589c                	lw	a5,48(s1)
ffffffffc0205614:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205618:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc020561a:	cf4d                	beqz	a4,ffffffffc02056d4 <do_exit+0x114>
        current->mm = NULL;
ffffffffc020561c:	00093783          	ld	a5,0(s2)
ffffffffc0205620:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205624:	00093783          	ld	a5,0(s2)
ffffffffc0205628:	470d                	li	a4,3
ffffffffc020562a:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc020562c:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205630:	100027f3          	csrr	a5,sstatus
ffffffffc0205634:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205636:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205638:	e7e1                	bnez	a5,ffffffffc0205700 <do_exit+0x140>
        proc = current->parent;
ffffffffc020563a:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020563e:	800007b7          	lui	a5,0x80000
ffffffffc0205642:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205644:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205646:	0ec52703          	lw	a4,236(a0)
ffffffffc020564a:	0af70f63          	beq	a4,a5,ffffffffc0205708 <do_exit+0x148>
ffffffffc020564e:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205652:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205656:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205658:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc020565a:	7afc                	ld	a5,240(a3)
ffffffffc020565c:	cb95                	beqz	a5,ffffffffc0205690 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc020565e:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5680>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205662:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc0205664:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205666:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205668:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020566c:	10e7b023          	sd	a4,256(a5)
ffffffffc0205670:	c311                	beqz	a4,ffffffffc0205674 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc0205672:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205674:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205676:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205678:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020567a:	fe9710e3          	bne	a4,s1,ffffffffc020565a <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020567e:	0ec52783          	lw	a5,236(a0)
ffffffffc0205682:	fd379ce3          	bne	a5,s3,ffffffffc020565a <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205686:	257000ef          	jal	ra,ffffffffc02060dc <wakeup_proc>
ffffffffc020568a:	00093683          	ld	a3,0(s2)
ffffffffc020568e:	b7f1                	j	ffffffffc020565a <do_exit+0x9a>
    if (flag) {
ffffffffc0205690:	020a1363          	bnez	s4,ffffffffc02056b6 <do_exit+0xf6>
    schedule();
ffffffffc0205694:	2c5000ef          	jal	ra,ffffffffc0206158 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205698:	00093783          	ld	a5,0(s2)
ffffffffc020569c:	00003617          	auipc	a2,0x3
ffffffffc02056a0:	0bc60613          	addi	a2,a2,188 # ffffffffc0208758 <default_pmm_manager+0x848>
ffffffffc02056a4:	20000593          	li	a1,512
ffffffffc02056a8:	43d4                	lw	a3,4(a5)
ffffffffc02056aa:	00003517          	auipc	a0,0x3
ffffffffc02056ae:	35e50513          	addi	a0,a0,862 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc02056b2:	b65fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_enable();
ffffffffc02056b6:	fa1fa0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc02056ba:	bfe9                	j	ffffffffc0205694 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc02056bc:	00003617          	auipc	a2,0x3
ffffffffc02056c0:	07c60613          	addi	a2,a2,124 # ffffffffc0208738 <default_pmm_manager+0x828>
ffffffffc02056c4:	1d400593          	li	a1,468
ffffffffc02056c8:	00003517          	auipc	a0,0x3
ffffffffc02056cc:	34050513          	addi	a0,a0,832 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc02056d0:	b47fa0ef          	jal	ra,ffffffffc0200216 <__panic>
            exit_mmap(mm);
ffffffffc02056d4:	8526                	mv	a0,s1
ffffffffc02056d6:	acbfb0ef          	jal	ra,ffffffffc02011a0 <exit_mmap>
            put_pgdir(mm);
ffffffffc02056da:	8526                	mv	a0,s1
ffffffffc02056dc:	8bdff0ef          	jal	ra,ffffffffc0204f98 <put_pgdir>
            mm_destroy(mm);
ffffffffc02056e0:	8526                	mv	a0,s1
ffffffffc02056e2:	91ffb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
ffffffffc02056e6:	bf1d                	j	ffffffffc020561c <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc02056e8:	00003617          	auipc	a2,0x3
ffffffffc02056ec:	06060613          	addi	a2,a2,96 # ffffffffc0208748 <default_pmm_manager+0x838>
ffffffffc02056f0:	1d700593          	li	a1,471
ffffffffc02056f4:	00003517          	auipc	a0,0x3
ffffffffc02056f8:	31450513          	addi	a0,a0,788 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc02056fc:	b1bfa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_disable();
ffffffffc0205700:	f5dfa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0205704:	4a05                	li	s4,1
ffffffffc0205706:	bf15                	j	ffffffffc020563a <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc0205708:	1d5000ef          	jal	ra,ffffffffc02060dc <wakeup_proc>
ffffffffc020570c:	b789                	j	ffffffffc020564e <do_exit+0x8e>

ffffffffc020570e <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc020570e:	7139                	addi	sp,sp,-64
ffffffffc0205710:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205712:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0205716:	f426                	sd	s1,40(sp)
ffffffffc0205718:	f04a                	sd	s2,32(sp)
ffffffffc020571a:	ec4e                	sd	s3,24(sp)
ffffffffc020571c:	e456                	sd	s5,8(sp)
ffffffffc020571e:	e05a                	sd	s6,0(sp)
ffffffffc0205720:	fc06                	sd	ra,56(sp)
ffffffffc0205722:	f822                	sd	s0,48(sp)
ffffffffc0205724:	89aa                	mv	s3,a0
ffffffffc0205726:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc0205728:	000a7917          	auipc	s2,0xa7
ffffffffc020572c:	d7890913          	addi	s2,s2,-648 # ffffffffc02ac4a0 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205730:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205732:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc0205734:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc0205736:	02098f63          	beqz	s3,ffffffffc0205774 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc020573a:	854e                	mv	a0,s3
ffffffffc020573c:	9fdff0ef          	jal	ra,ffffffffc0205138 <find_proc>
ffffffffc0205740:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc0205742:	12050063          	beqz	a0,ffffffffc0205862 <do_wait.part.1+0x154>
ffffffffc0205746:	00093703          	ld	a4,0(s2)
ffffffffc020574a:	711c                	ld	a5,32(a0)
ffffffffc020574c:	10e79b63          	bne	a5,a4,ffffffffc0205862 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205750:	411c                	lw	a5,0(a0)
ffffffffc0205752:	02978c63          	beq	a5,s1,ffffffffc020578a <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0205756:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc020575a:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc020575e:	1fb000ef          	jal	ra,ffffffffc0206158 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205762:	00093783          	ld	a5,0(s2)
ffffffffc0205766:	0b07a783          	lw	a5,176(a5)
ffffffffc020576a:	8b85                	andi	a5,a5,1
ffffffffc020576c:	d7e9                	beqz	a5,ffffffffc0205736 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc020576e:	555d                	li	a0,-9
ffffffffc0205770:	e51ff0ef          	jal	ra,ffffffffc02055c0 <do_exit>
        proc = current->cptr;
ffffffffc0205774:	00093703          	ld	a4,0(s2)
ffffffffc0205778:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020577a:	e409                	bnez	s0,ffffffffc0205784 <do_wait.part.1+0x76>
ffffffffc020577c:	a0dd                	j	ffffffffc0205862 <do_wait.part.1+0x154>
ffffffffc020577e:	10043403          	ld	s0,256(s0)
ffffffffc0205782:	d871                	beqz	s0,ffffffffc0205756 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205784:	401c                	lw	a5,0(s0)
ffffffffc0205786:	fe979ce3          	bne	a5,s1,ffffffffc020577e <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc020578a:	000a7797          	auipc	a5,0xa7
ffffffffc020578e:	d1e78793          	addi	a5,a5,-738 # ffffffffc02ac4a8 <idleproc>
ffffffffc0205792:	639c                	ld	a5,0(a5)
ffffffffc0205794:	0c878d63          	beq	a5,s0,ffffffffc020586e <do_wait.part.1+0x160>
ffffffffc0205798:	000a7797          	auipc	a5,0xa7
ffffffffc020579c:	d1878793          	addi	a5,a5,-744 # ffffffffc02ac4b0 <initproc>
ffffffffc02057a0:	639c                	ld	a5,0(a5)
ffffffffc02057a2:	0cf40663          	beq	s0,a5,ffffffffc020586e <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc02057a6:	000b0663          	beqz	s6,ffffffffc02057b2 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc02057aa:	0e842783          	lw	a5,232(s0)
ffffffffc02057ae:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02057b2:	100027f3          	csrr	a5,sstatus
ffffffffc02057b6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02057b8:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02057ba:	e7d5                	bnez	a5,ffffffffc0205866 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc02057bc:	6c70                	ld	a2,216(s0)
ffffffffc02057be:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02057c0:	10043703          	ld	a4,256(s0)
ffffffffc02057c4:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02057c6:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02057c8:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02057ca:	6470                	ld	a2,200(s0)
ffffffffc02057cc:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02057ce:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02057d0:	e290                	sd	a2,0(a3)
ffffffffc02057d2:	c319                	beqz	a4,ffffffffc02057d8 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc02057d4:	ff7c                	sd	a5,248(a4)
ffffffffc02057d6:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc02057d8:	c3d1                	beqz	a5,ffffffffc020585c <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc02057da:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc02057de:	000a7797          	auipc	a5,0xa7
ffffffffc02057e2:	cda78793          	addi	a5,a5,-806 # ffffffffc02ac4b8 <nr_process>
ffffffffc02057e6:	439c                	lw	a5,0(a5)
ffffffffc02057e8:	37fd                	addiw	a5,a5,-1
ffffffffc02057ea:	000a7717          	auipc	a4,0xa7
ffffffffc02057ee:	ccf72723          	sw	a5,-818(a4) # ffffffffc02ac4b8 <nr_process>
    if (flag) {
ffffffffc02057f2:	e1b5                	bnez	a1,ffffffffc0205856 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02057f4:	6814                	ld	a3,16(s0)
ffffffffc02057f6:	c02007b7          	lui	a5,0xc0200
ffffffffc02057fa:	0af6e263          	bltu	a3,a5,ffffffffc020589e <do_wait.part.1+0x190>
ffffffffc02057fe:	000a7797          	auipc	a5,0xa7
ffffffffc0205802:	dca78793          	addi	a5,a5,-566 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0205806:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205808:	000a7797          	auipc	a5,0xa7
ffffffffc020580c:	c9078793          	addi	a5,a5,-880 # ffffffffc02ac498 <npage>
ffffffffc0205810:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205812:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205814:	82b1                	srli	a3,a3,0xc
ffffffffc0205816:	06f6f863          	bleu	a5,a3,ffffffffc0205886 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc020581a:	00003797          	auipc	a5,0x3
ffffffffc020581e:	6b678793          	addi	a5,a5,1718 # ffffffffc0208ed0 <nbase>
ffffffffc0205822:	639c                	ld	a5,0(a5)
ffffffffc0205824:	000a7717          	auipc	a4,0xa7
ffffffffc0205828:	db470713          	addi	a4,a4,-588 # ffffffffc02ac5d8 <pages>
ffffffffc020582c:	6308                	ld	a0,0(a4)
ffffffffc020582e:	8e9d                	sub	a3,a3,a5
ffffffffc0205830:	069a                	slli	a3,a3,0x6
ffffffffc0205832:	9536                	add	a0,a0,a3
ffffffffc0205834:	4589                	li	a1,2
ffffffffc0205836:	f55fd0ef          	jal	ra,ffffffffc020378a <free_pages>
    kfree(proc);
ffffffffc020583a:	8522                	mv	a0,s0
ffffffffc020583c:	90bfc0ef          	jal	ra,ffffffffc0202146 <kfree>
    return 0;
ffffffffc0205840:	4501                	li	a0,0
}
ffffffffc0205842:	70e2                	ld	ra,56(sp)
ffffffffc0205844:	7442                	ld	s0,48(sp)
ffffffffc0205846:	74a2                	ld	s1,40(sp)
ffffffffc0205848:	7902                	ld	s2,32(sp)
ffffffffc020584a:	69e2                	ld	s3,24(sp)
ffffffffc020584c:	6a42                	ld	s4,16(sp)
ffffffffc020584e:	6aa2                	ld	s5,8(sp)
ffffffffc0205850:	6b02                	ld	s6,0(sp)
ffffffffc0205852:	6121                	addi	sp,sp,64
ffffffffc0205854:	8082                	ret
        intr_enable();
ffffffffc0205856:	e01fa0ef          	jal	ra,ffffffffc0200656 <intr_enable>
ffffffffc020585a:	bf69                	j	ffffffffc02057f4 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc020585c:	701c                	ld	a5,32(s0)
ffffffffc020585e:	fbf8                	sd	a4,240(a5)
ffffffffc0205860:	bfbd                	j	ffffffffc02057de <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc0205862:	5579                	li	a0,-2
ffffffffc0205864:	bff9                	j	ffffffffc0205842 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc0205866:	df7fa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc020586a:	4585                	li	a1,1
ffffffffc020586c:	bf81                	j	ffffffffc02057bc <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc020586e:	00003617          	auipc	a2,0x3
ffffffffc0205872:	f5260613          	addi	a2,a2,-174 # ffffffffc02087c0 <default_pmm_manager+0x8b0>
ffffffffc0205876:	2f600593          	li	a1,758
ffffffffc020587a:	00003517          	auipc	a0,0x3
ffffffffc020587e:	18e50513          	addi	a0,a0,398 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0205882:	995fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205886:	00002617          	auipc	a2,0x2
ffffffffc020588a:	c6260613          	addi	a2,a2,-926 # ffffffffc02074e8 <commands+0xbd0>
ffffffffc020588e:	06200593          	li	a1,98
ffffffffc0205892:	00002517          	auipc	a0,0x2
ffffffffc0205896:	c7650513          	addi	a0,a0,-906 # ffffffffc0207508 <commands+0xbf0>
ffffffffc020589a:	97dfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020589e:	00002617          	auipc	a2,0x2
ffffffffc02058a2:	ef260613          	addi	a2,a2,-270 # ffffffffc0207790 <commands+0xe78>
ffffffffc02058a6:	06e00593          	li	a1,110
ffffffffc02058aa:	00002517          	auipc	a0,0x2
ffffffffc02058ae:	c5e50513          	addi	a0,a0,-930 # ffffffffc0207508 <commands+0xbf0>
ffffffffc02058b2:	965fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02058b6 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02058b6:	1141                	addi	sp,sp,-16
ffffffffc02058b8:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02058ba:	f17fd0ef          	jal	ra,ffffffffc02037d0 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02058be:	fc8fc0ef          	jal	ra,ffffffffc0202086 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02058c2:	4601                	li	a2,0
ffffffffc02058c4:	4581                	li	a1,0
ffffffffc02058c6:	fffff517          	auipc	a0,0xfffff
ffffffffc02058ca:	65050513          	addi	a0,a0,1616 # ffffffffc0204f16 <user_main>
ffffffffc02058ce:	ca3ff0ef          	jal	ra,ffffffffc0205570 <kernel_thread>
    if (pid <= 0) {
ffffffffc02058d2:	00a04563          	bgtz	a0,ffffffffc02058dc <init_main+0x26>
ffffffffc02058d6:	a841                	j	ffffffffc0205966 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02058d8:	081000ef          	jal	ra,ffffffffc0206158 <schedule>
    if (code_store != NULL) {
ffffffffc02058dc:	4581                	li	a1,0
ffffffffc02058de:	4501                	li	a0,0
ffffffffc02058e0:	e2fff0ef          	jal	ra,ffffffffc020570e <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc02058e4:	d975                	beqz	a0,ffffffffc02058d8 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02058e6:	00003517          	auipc	a0,0x3
ffffffffc02058ea:	f1a50513          	addi	a0,a0,-230 # ffffffffc0208800 <default_pmm_manager+0x8f0>
ffffffffc02058ee:	fe2fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02058f2:	000a7797          	auipc	a5,0xa7
ffffffffc02058f6:	bbe78793          	addi	a5,a5,-1090 # ffffffffc02ac4b0 <initproc>
ffffffffc02058fa:	639c                	ld	a5,0(a5)
ffffffffc02058fc:	7bf8                	ld	a4,240(a5)
ffffffffc02058fe:	e721                	bnez	a4,ffffffffc0205946 <init_main+0x90>
ffffffffc0205900:	7ff8                	ld	a4,248(a5)
ffffffffc0205902:	e331                	bnez	a4,ffffffffc0205946 <init_main+0x90>
ffffffffc0205904:	1007b703          	ld	a4,256(a5)
ffffffffc0205908:	ef1d                	bnez	a4,ffffffffc0205946 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc020590a:	000a7717          	auipc	a4,0xa7
ffffffffc020590e:	bae70713          	addi	a4,a4,-1106 # ffffffffc02ac4b8 <nr_process>
ffffffffc0205912:	4314                	lw	a3,0(a4)
ffffffffc0205914:	4709                	li	a4,2
ffffffffc0205916:	0ae69463          	bne	a3,a4,ffffffffc02059be <init_main+0x108>
    return listelm->next;
ffffffffc020591a:	000a7697          	auipc	a3,0xa7
ffffffffc020591e:	cc668693          	addi	a3,a3,-826 # ffffffffc02ac5e0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205922:	6698                	ld	a4,8(a3)
ffffffffc0205924:	0c878793          	addi	a5,a5,200
ffffffffc0205928:	06f71b63          	bne	a4,a5,ffffffffc020599e <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020592c:	629c                	ld	a5,0(a3)
ffffffffc020592e:	04f71863          	bne	a4,a5,ffffffffc020597e <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0205932:	00003517          	auipc	a0,0x3
ffffffffc0205936:	fb650513          	addi	a0,a0,-74 # ffffffffc02088e8 <default_pmm_manager+0x9d8>
ffffffffc020593a:	f96fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc020593e:	60a2                	ld	ra,8(sp)
ffffffffc0205940:	4501                	li	a0,0
ffffffffc0205942:	0141                	addi	sp,sp,16
ffffffffc0205944:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205946:	00003697          	auipc	a3,0x3
ffffffffc020594a:	ee268693          	addi	a3,a3,-286 # ffffffffc0208828 <default_pmm_manager+0x918>
ffffffffc020594e:	00001617          	auipc	a2,0x1
ffffffffc0205952:	44a60613          	addi	a2,a2,1098 # ffffffffc0206d98 <commands+0x480>
ffffffffc0205956:	35b00593          	li	a1,859
ffffffffc020595a:	00003517          	auipc	a0,0x3
ffffffffc020595e:	0ae50513          	addi	a0,a0,174 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0205962:	8b5fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205966:	00003617          	auipc	a2,0x3
ffffffffc020596a:	e7a60613          	addi	a2,a2,-390 # ffffffffc02087e0 <default_pmm_manager+0x8d0>
ffffffffc020596e:	35300593          	li	a1,851
ffffffffc0205972:	00003517          	auipc	a0,0x3
ffffffffc0205976:	09650513          	addi	a0,a0,150 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc020597a:	89dfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020597e:	00003697          	auipc	a3,0x3
ffffffffc0205982:	f3a68693          	addi	a3,a3,-198 # ffffffffc02088b8 <default_pmm_manager+0x9a8>
ffffffffc0205986:	00001617          	auipc	a2,0x1
ffffffffc020598a:	41260613          	addi	a2,a2,1042 # ffffffffc0206d98 <commands+0x480>
ffffffffc020598e:	35e00593          	li	a1,862
ffffffffc0205992:	00003517          	auipc	a0,0x3
ffffffffc0205996:	07650513          	addi	a0,a0,118 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc020599a:	87dfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020599e:	00003697          	auipc	a3,0x3
ffffffffc02059a2:	eea68693          	addi	a3,a3,-278 # ffffffffc0208888 <default_pmm_manager+0x978>
ffffffffc02059a6:	00001617          	auipc	a2,0x1
ffffffffc02059aa:	3f260613          	addi	a2,a2,1010 # ffffffffc0206d98 <commands+0x480>
ffffffffc02059ae:	35d00593          	li	a1,861
ffffffffc02059b2:	00003517          	auipc	a0,0x3
ffffffffc02059b6:	05650513          	addi	a0,a0,86 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc02059ba:	85dfa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_process == 2);
ffffffffc02059be:	00003697          	auipc	a3,0x3
ffffffffc02059c2:	eba68693          	addi	a3,a3,-326 # ffffffffc0208878 <default_pmm_manager+0x968>
ffffffffc02059c6:	00001617          	auipc	a2,0x1
ffffffffc02059ca:	3d260613          	addi	a2,a2,978 # ffffffffc0206d98 <commands+0x480>
ffffffffc02059ce:	35c00593          	li	a1,860
ffffffffc02059d2:	00003517          	auipc	a0,0x3
ffffffffc02059d6:	03650513          	addi	a0,a0,54 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc02059da:	83dfa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02059de <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059de:	7135                	addi	sp,sp,-160
ffffffffc02059e0:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02059e2:	000a7a17          	auipc	s4,0xa7
ffffffffc02059e6:	abea0a13          	addi	s4,s4,-1346 # ffffffffc02ac4a0 <current>
ffffffffc02059ea:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059ee:	e14a                	sd	s2,128(sp)
ffffffffc02059f0:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02059f2:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059f6:	fcce                	sd	s3,120(sp)
ffffffffc02059f8:	f0da                	sd	s6,96(sp)
ffffffffc02059fa:	89aa                	mv	s3,a0
ffffffffc02059fc:	842e                	mv	s0,a1
ffffffffc02059fe:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205a00:	4681                	li	a3,0
ffffffffc0205a02:	862e                	mv	a2,a1
ffffffffc0205a04:	85aa                	mv	a1,a0
ffffffffc0205a06:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205a08:	ed06                	sd	ra,152(sp)
ffffffffc0205a0a:	e526                	sd	s1,136(sp)
ffffffffc0205a0c:	f4d6                	sd	s5,104(sp)
ffffffffc0205a0e:	ecde                	sd	s7,88(sp)
ffffffffc0205a10:	e8e2                	sd	s8,80(sp)
ffffffffc0205a12:	e4e6                	sd	s9,72(sp)
ffffffffc0205a14:	e0ea                	sd	s10,64(sp)
ffffffffc0205a16:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205a18:	f45fb0ef          	jal	ra,ffffffffc020195c <user_mem_check>
ffffffffc0205a1c:	40050463          	beqz	a0,ffffffffc0205e24 <do_execve+0x446>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205a20:	4641                	li	a2,16
ffffffffc0205a22:	4581                	li	a1,0
ffffffffc0205a24:	1008                	addi	a0,sp,32
ffffffffc0205a26:	147000ef          	jal	ra,ffffffffc020636c <memset>
    memcpy(local_name, name, len);
ffffffffc0205a2a:	47bd                	li	a5,15
ffffffffc0205a2c:	8622                	mv	a2,s0
ffffffffc0205a2e:	0687ee63          	bltu	a5,s0,ffffffffc0205aaa <do_execve+0xcc>
ffffffffc0205a32:	85ce                	mv	a1,s3
ffffffffc0205a34:	1008                	addi	a0,sp,32
ffffffffc0205a36:	149000ef          	jal	ra,ffffffffc020637e <memcpy>
    if (mm != NULL) {
ffffffffc0205a3a:	06090f63          	beqz	s2,ffffffffc0205ab8 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205a3e:	00002517          	auipc	a0,0x2
ffffffffc0205a42:	8e250513          	addi	a0,a0,-1822 # ffffffffc0207320 <commands+0xa08>
ffffffffc0205a46:	ec2fa0ef          	jal	ra,ffffffffc0200108 <cputs>
        lcr3(boot_cr3);
ffffffffc0205a4a:	000a7797          	auipc	a5,0xa7
ffffffffc0205a4e:	b8678793          	addi	a5,a5,-1146 # ffffffffc02ac5d0 <boot_cr3>
ffffffffc0205a52:	639c                	ld	a5,0(a5)
ffffffffc0205a54:	577d                	li	a4,-1
ffffffffc0205a56:	177e                	slli	a4,a4,0x3f
ffffffffc0205a58:	83b1                	srli	a5,a5,0xc
ffffffffc0205a5a:	8fd9                	or	a5,a5,a4
ffffffffc0205a5c:	18079073          	csrw	satp,a5
ffffffffc0205a60:	03092783          	lw	a5,48(s2)
ffffffffc0205a64:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205a68:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205a6c:	28070b63          	beqz	a4,ffffffffc0205d02 <do_execve+0x324>
        current->mm = NULL;
ffffffffc0205a70:	000a3783          	ld	a5,0(s4)
ffffffffc0205a74:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205a78:	c02fb0ef          	jal	ra,ffffffffc0200e7a <mm_create>
ffffffffc0205a7c:	892a                	mv	s2,a0
ffffffffc0205a7e:	c135                	beqz	a0,ffffffffc0205ae2 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205a80:	d96ff0ef          	jal	ra,ffffffffc0205016 <setup_pgdir>
ffffffffc0205a84:	e931                	bnez	a0,ffffffffc0205ad8 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205a86:	000b2703          	lw	a4,0(s6)
ffffffffc0205a8a:	464c47b7          	lui	a5,0x464c4
ffffffffc0205a8e:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9aff>
ffffffffc0205a92:	04f70a63          	beq	a4,a5,ffffffffc0205ae6 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc0205a96:	854a                	mv	a0,s2
ffffffffc0205a98:	d00ff0ef          	jal	ra,ffffffffc0204f98 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205a9c:	854a                	mv	a0,s2
ffffffffc0205a9e:	d62fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205aa2:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc0205aa4:	854e                	mv	a0,s3
ffffffffc0205aa6:	b1bff0ef          	jal	ra,ffffffffc02055c0 <do_exit>
    memcpy(local_name, name, len);
ffffffffc0205aaa:	463d                	li	a2,15
ffffffffc0205aac:	85ce                	mv	a1,s3
ffffffffc0205aae:	1008                	addi	a0,sp,32
ffffffffc0205ab0:	0cf000ef          	jal	ra,ffffffffc020637e <memcpy>
    if (mm != NULL) {
ffffffffc0205ab4:	f80915e3          	bnez	s2,ffffffffc0205a3e <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc0205ab8:	000a3783          	ld	a5,0(s4)
ffffffffc0205abc:	779c                	ld	a5,40(a5)
ffffffffc0205abe:	dfcd                	beqz	a5,ffffffffc0205a78 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205ac0:	00003617          	auipc	a2,0x3
ffffffffc0205ac4:	af060613          	addi	a2,a2,-1296 # ffffffffc02085b0 <default_pmm_manager+0x6a0>
ffffffffc0205ac8:	20a00593          	li	a1,522
ffffffffc0205acc:	00003517          	auipc	a0,0x3
ffffffffc0205ad0:	f3c50513          	addi	a0,a0,-196 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0205ad4:	f42fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    mm_destroy(mm);
ffffffffc0205ad8:	854a                	mv	a0,s2
ffffffffc0205ada:	d26fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205ade:	59f1                	li	s3,-4
ffffffffc0205ae0:	b7d1                	j	ffffffffc0205aa4 <do_execve+0xc6>
ffffffffc0205ae2:	59f1                	li	s3,-4
ffffffffc0205ae4:	b7c1                	j	ffffffffc0205aa4 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205ae6:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205aea:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205aee:	00371793          	slli	a5,a4,0x3
ffffffffc0205af2:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205af4:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205af6:	078e                	slli	a5,a5,0x3
ffffffffc0205af8:	97a2                	add	a5,a5,s0
ffffffffc0205afa:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205afc:	02f47b63          	bleu	a5,s0,ffffffffc0205b32 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc0205b00:	5bfd                	li	s7,-1
ffffffffc0205b02:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0205b06:	000a7d97          	auipc	s11,0xa7
ffffffffc0205b0a:	ad2d8d93          	addi	s11,s11,-1326 # ffffffffc02ac5d8 <pages>
ffffffffc0205b0e:	00003d17          	auipc	s10,0x3
ffffffffc0205b12:	3c2d0d13          	addi	s10,s10,962 # ffffffffc0208ed0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205b16:	e43e                	sd	a5,8(sp)
ffffffffc0205b18:	000a7c97          	auipc	s9,0xa7
ffffffffc0205b1c:	980c8c93          	addi	s9,s9,-1664 # ffffffffc02ac498 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205b20:	4018                	lw	a4,0(s0)
ffffffffc0205b22:	4785                	li	a5,1
ffffffffc0205b24:	0ef70d63          	beq	a4,a5,ffffffffc0205c1e <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc0205b28:	67e2                	ld	a5,24(sp)
ffffffffc0205b2a:	03840413          	addi	s0,s0,56
ffffffffc0205b2e:	fef469e3          	bltu	s0,a5,ffffffffc0205b20 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205b32:	4701                	li	a4,0
ffffffffc0205b34:	46ad                	li	a3,11
ffffffffc0205b36:	00100637          	lui	a2,0x100
ffffffffc0205b3a:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205b3e:	854a                	mv	a0,s2
ffffffffc0205b40:	d12fb0ef          	jal	ra,ffffffffc0201052 <mm_map>
ffffffffc0205b44:	89aa                	mv	s3,a0
ffffffffc0205b46:	1a051463          	bnez	a0,ffffffffc0205cee <do_execve+0x310>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205b4a:	01893503          	ld	a0,24(s2)
ffffffffc0205b4e:	467d                	li	a2,31
ffffffffc0205b50:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205b54:	8d0ff0ef          	jal	ra,ffffffffc0204c24 <pgdir_alloc_page>
ffffffffc0205b58:	36050263          	beqz	a0,ffffffffc0205ebc <do_execve+0x4de>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b5c:	01893503          	ld	a0,24(s2)
ffffffffc0205b60:	467d                	li	a2,31
ffffffffc0205b62:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205b66:	8beff0ef          	jal	ra,ffffffffc0204c24 <pgdir_alloc_page>
ffffffffc0205b6a:	32050963          	beqz	a0,ffffffffc0205e9c <do_execve+0x4be>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b6e:	01893503          	ld	a0,24(s2)
ffffffffc0205b72:	467d                	li	a2,31
ffffffffc0205b74:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205b78:	8acff0ef          	jal	ra,ffffffffc0204c24 <pgdir_alloc_page>
ffffffffc0205b7c:	30050063          	beqz	a0,ffffffffc0205e7c <do_execve+0x49e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b80:	01893503          	ld	a0,24(s2)
ffffffffc0205b84:	467d                	li	a2,31
ffffffffc0205b86:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205b8a:	89aff0ef          	jal	ra,ffffffffc0204c24 <pgdir_alloc_page>
ffffffffc0205b8e:	2c050763          	beqz	a0,ffffffffc0205e5c <do_execve+0x47e>
    mm->mm_count += 1;
ffffffffc0205b92:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0205b96:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205b9a:	01893683          	ld	a3,24(s2)
ffffffffc0205b9e:	2785                	addiw	a5,a5,1
ffffffffc0205ba0:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0205ba4:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf55a8>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205ba8:	c02007b7          	lui	a5,0xc0200
ffffffffc0205bac:	28f6ec63          	bltu	a3,a5,ffffffffc0205e44 <do_execve+0x466>
ffffffffc0205bb0:	000a7797          	auipc	a5,0xa7
ffffffffc0205bb4:	a1878793          	addi	a5,a5,-1512 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0205bb8:	639c                	ld	a5,0(a5)
ffffffffc0205bba:	577d                	li	a4,-1
ffffffffc0205bbc:	177e                	slli	a4,a4,0x3f
ffffffffc0205bbe:	8e9d                	sub	a3,a3,a5
ffffffffc0205bc0:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205bc4:	f654                	sd	a3,168(a2)
ffffffffc0205bc6:	8fd9                	or	a5,a5,a4
ffffffffc0205bc8:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205bcc:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205bce:	4581                	li	a1,0
ffffffffc0205bd0:	12000613          	li	a2,288
ffffffffc0205bd4:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205bd6:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205bda:	792000ef          	jal	ra,ffffffffc020636c <memset>
    tf->epc = elf->e_entry;
ffffffffc0205bde:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp=USTACKTOP;
ffffffffc0205be2:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205be4:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205be8:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp=USTACKTOP;
ffffffffc0205bec:	07fe                	slli	a5,a5,0x1f
ffffffffc0205bee:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205bf0:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205bf4:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205bf8:	100c                	addi	a1,sp,32
ffffffffc0205bfa:	ca8ff0ef          	jal	ra,ffffffffc02050a2 <set_proc_name>
}
ffffffffc0205bfe:	60ea                	ld	ra,152(sp)
ffffffffc0205c00:	644a                	ld	s0,144(sp)
ffffffffc0205c02:	854e                	mv	a0,s3
ffffffffc0205c04:	64aa                	ld	s1,136(sp)
ffffffffc0205c06:	690a                	ld	s2,128(sp)
ffffffffc0205c08:	79e6                	ld	s3,120(sp)
ffffffffc0205c0a:	7a46                	ld	s4,112(sp)
ffffffffc0205c0c:	7aa6                	ld	s5,104(sp)
ffffffffc0205c0e:	7b06                	ld	s6,96(sp)
ffffffffc0205c10:	6be6                	ld	s7,88(sp)
ffffffffc0205c12:	6c46                	ld	s8,80(sp)
ffffffffc0205c14:	6ca6                	ld	s9,72(sp)
ffffffffc0205c16:	6d06                	ld	s10,64(sp)
ffffffffc0205c18:	7de2                	ld	s11,56(sp)
ffffffffc0205c1a:	610d                	addi	sp,sp,160
ffffffffc0205c1c:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205c1e:	7410                	ld	a2,40(s0)
ffffffffc0205c20:	701c                	ld	a5,32(s0)
ffffffffc0205c22:	20f66363          	bltu	a2,a5,ffffffffc0205e28 <do_execve+0x44a>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205c26:	405c                	lw	a5,4(s0)
ffffffffc0205c28:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205c2c:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205c30:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205c32:	0e071263          	bnez	a4,ffffffffc0205d16 <do_execve+0x338>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205c36:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c38:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205c3a:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c3c:	c789                	beqz	a5,ffffffffc0205c46 <do_execve+0x268>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205c3e:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c40:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205c44:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205c46:	0026f793          	andi	a5,a3,2
ffffffffc0205c4a:	efe1                	bnez	a5,ffffffffc0205d22 <do_execve+0x344>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205c4c:	0046f793          	andi	a5,a3,4
ffffffffc0205c50:	c789                	beqz	a5,ffffffffc0205c5a <do_execve+0x27c>
ffffffffc0205c52:	6782                	ld	a5,0(sp)
ffffffffc0205c54:	0087e793          	ori	a5,a5,8
ffffffffc0205c58:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205c5a:	680c                	ld	a1,16(s0)
ffffffffc0205c5c:	4701                	li	a4,0
ffffffffc0205c5e:	854a                	mv	a0,s2
ffffffffc0205c60:	bf2fb0ef          	jal	ra,ffffffffc0201052 <mm_map>
ffffffffc0205c64:	89aa                	mv	s3,a0
ffffffffc0205c66:	e541                	bnez	a0,ffffffffc0205cee <do_execve+0x310>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c68:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c6c:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c70:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c74:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c76:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c78:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c7a:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205c7e:	053bef63          	bltu	s7,s3,ffffffffc0205cdc <do_execve+0x2fe>
ffffffffc0205c82:	aa79                	j	ffffffffc0205e20 <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c84:	6785                	lui	a5,0x1
ffffffffc0205c86:	418b8533          	sub	a0,s7,s8
ffffffffc0205c8a:	9c3e                	add	s8,s8,a5
ffffffffc0205c8c:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205c90:	0189f463          	bleu	s8,s3,ffffffffc0205c98 <do_execve+0x2ba>
                size -= la - end;
ffffffffc0205c94:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205c98:	000db683          	ld	a3,0(s11)
ffffffffc0205c9c:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205ca0:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205ca2:	40d486b3          	sub	a3,s1,a3
ffffffffc0205ca6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205ca8:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205cac:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205cae:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205cb2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205cb4:	16c5fc63          	bleu	a2,a1,ffffffffc0205e2c <do_execve+0x44e>
ffffffffc0205cb8:	000a7797          	auipc	a5,0xa7
ffffffffc0205cbc:	91078793          	addi	a5,a5,-1776 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0205cc0:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205cc4:	85d6                	mv	a1,s5
ffffffffc0205cc6:	8642                	mv	a2,a6
ffffffffc0205cc8:	96c6                	add	a3,a3,a7
ffffffffc0205cca:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205ccc:	9bc2                	add	s7,s7,a6
ffffffffc0205cce:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205cd0:	6ae000ef          	jal	ra,ffffffffc020637e <memcpy>
            start += size, from += size;
ffffffffc0205cd4:	6842                	ld	a6,16(sp)
ffffffffc0205cd6:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205cd8:	053bf863          	bleu	s3,s7,ffffffffc0205d28 <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205cdc:	01893503          	ld	a0,24(s2)
ffffffffc0205ce0:	6602                	ld	a2,0(sp)
ffffffffc0205ce2:	85e2                	mv	a1,s8
ffffffffc0205ce4:	f41fe0ef          	jal	ra,ffffffffc0204c24 <pgdir_alloc_page>
ffffffffc0205ce8:	84aa                	mv	s1,a0
ffffffffc0205cea:	fd49                	bnez	a0,ffffffffc0205c84 <do_execve+0x2a6>
        ret = -E_NO_MEM;
ffffffffc0205cec:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205cee:	854a                	mv	a0,s2
ffffffffc0205cf0:	cb0fb0ef          	jal	ra,ffffffffc02011a0 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205cf4:	854a                	mv	a0,s2
ffffffffc0205cf6:	aa2ff0ef          	jal	ra,ffffffffc0204f98 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205cfa:	854a                	mv	a0,s2
ffffffffc0205cfc:	b04fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
    return ret;
ffffffffc0205d00:	b355                	j	ffffffffc0205aa4 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205d02:	854a                	mv	a0,s2
ffffffffc0205d04:	c9cfb0ef          	jal	ra,ffffffffc02011a0 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205d08:	854a                	mv	a0,s2
ffffffffc0205d0a:	a8eff0ef          	jal	ra,ffffffffc0204f98 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205d0e:	854a                	mv	a0,s2
ffffffffc0205d10:	af0fb0ef          	jal	ra,ffffffffc0201000 <mm_destroy>
ffffffffc0205d14:	bbb1                	j	ffffffffc0205a70 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205d16:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205d1a:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205d1c:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205d1e:	f20790e3          	bnez	a5,ffffffffc0205c3e <do_execve+0x260>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205d22:	47dd                	li	a5,23
ffffffffc0205d24:	e03e                	sd	a5,0(sp)
ffffffffc0205d26:	b71d                	j	ffffffffc0205c4c <do_execve+0x26e>
ffffffffc0205d28:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205d2c:	7414                	ld	a3,40(s0)
ffffffffc0205d2e:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205d30:	098bf163          	bleu	s8,s7,ffffffffc0205db2 <do_execve+0x3d4>
            if (start == end) {
ffffffffc0205d34:	df798ae3          	beq	s3,s7,ffffffffc0205b28 <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205d38:	6505                	lui	a0,0x1
ffffffffc0205d3a:	955e                	add	a0,a0,s7
ffffffffc0205d3c:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205d40:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205d44:	0d89fb63          	bleu	s8,s3,ffffffffc0205e1a <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0205d48:	000db683          	ld	a3,0(s11)
ffffffffc0205d4c:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205d50:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205d52:	40d486b3          	sub	a3,s1,a3
ffffffffc0205d56:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205d58:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205d5c:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205d5e:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205d62:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205d64:	0cc5f463          	bleu	a2,a1,ffffffffc0205e2c <do_execve+0x44e>
ffffffffc0205d68:	000a7617          	auipc	a2,0xa7
ffffffffc0205d6c:	86060613          	addi	a2,a2,-1952 # ffffffffc02ac5c8 <va_pa_offset>
ffffffffc0205d70:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d74:	4581                	li	a1,0
ffffffffc0205d76:	8656                	mv	a2,s5
ffffffffc0205d78:	96c2                	add	a3,a3,a6
ffffffffc0205d7a:	9536                	add	a0,a0,a3
ffffffffc0205d7c:	5f0000ef          	jal	ra,ffffffffc020636c <memset>
            start += size;
ffffffffc0205d80:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205d84:	0389f463          	bleu	s8,s3,ffffffffc0205dac <do_execve+0x3ce>
ffffffffc0205d88:	dae980e3          	beq	s3,a4,ffffffffc0205b28 <do_execve+0x14a>
ffffffffc0205d8c:	00003697          	auipc	a3,0x3
ffffffffc0205d90:	84c68693          	addi	a3,a3,-1972 # ffffffffc02085d8 <default_pmm_manager+0x6c8>
ffffffffc0205d94:	00001617          	auipc	a2,0x1
ffffffffc0205d98:	00460613          	addi	a2,a2,4 # ffffffffc0206d98 <commands+0x480>
ffffffffc0205d9c:	25f00593          	li	a1,607
ffffffffc0205da0:	00003517          	auipc	a0,0x3
ffffffffc0205da4:	c6850513          	addi	a0,a0,-920 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0205da8:	c6efa0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0205dac:	ff8710e3          	bne	a4,s8,ffffffffc0205d8c <do_execve+0x3ae>
ffffffffc0205db0:	8be2                	mv	s7,s8
ffffffffc0205db2:	000a7a97          	auipc	s5,0xa7
ffffffffc0205db6:	816a8a93          	addi	s5,s5,-2026 # ffffffffc02ac5c8 <va_pa_offset>
        while (start < end) {
ffffffffc0205dba:	053be763          	bltu	s7,s3,ffffffffc0205e08 <do_execve+0x42a>
ffffffffc0205dbe:	b3ad                	j	ffffffffc0205b28 <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205dc0:	6785                	lui	a5,0x1
ffffffffc0205dc2:	418b8533          	sub	a0,s7,s8
ffffffffc0205dc6:	9c3e                	add	s8,s8,a5
ffffffffc0205dc8:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205dcc:	0189f463          	bleu	s8,s3,ffffffffc0205dd4 <do_execve+0x3f6>
                size -= la - end;
ffffffffc0205dd0:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205dd4:	000db683          	ld	a3,0(s11)
ffffffffc0205dd8:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205ddc:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205dde:	40d486b3          	sub	a3,s1,a3
ffffffffc0205de2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205de4:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205de8:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205dea:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205dee:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205df0:	02b87e63          	bleu	a1,a6,ffffffffc0205e2c <do_execve+0x44e>
ffffffffc0205df4:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205df8:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205dfa:	4581                	li	a1,0
ffffffffc0205dfc:	96c2                	add	a3,a3,a6
ffffffffc0205dfe:	9536                	add	a0,a0,a3
ffffffffc0205e00:	56c000ef          	jal	ra,ffffffffc020636c <memset>
        while (start < end) {
ffffffffc0205e04:	d33bf2e3          	bleu	s3,s7,ffffffffc0205b28 <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205e08:	01893503          	ld	a0,24(s2)
ffffffffc0205e0c:	6602                	ld	a2,0(sp)
ffffffffc0205e0e:	85e2                	mv	a1,s8
ffffffffc0205e10:	e15fe0ef          	jal	ra,ffffffffc0204c24 <pgdir_alloc_page>
ffffffffc0205e14:	84aa                	mv	s1,a0
ffffffffc0205e16:	f54d                	bnez	a0,ffffffffc0205dc0 <do_execve+0x3e2>
ffffffffc0205e18:	bdd1                	j	ffffffffc0205cec <do_execve+0x30e>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205e1a:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205e1e:	b72d                	j	ffffffffc0205d48 <do_execve+0x36a>
        while (start < end) {
ffffffffc0205e20:	89de                	mv	s3,s7
ffffffffc0205e22:	b729                	j	ffffffffc0205d2c <do_execve+0x34e>
        return -E_INVAL;
ffffffffc0205e24:	59f5                	li	s3,-3
ffffffffc0205e26:	bbe1                	j	ffffffffc0205bfe <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205e28:	59e1                	li	s3,-8
ffffffffc0205e2a:	b5d1                	j	ffffffffc0205cee <do_execve+0x310>
ffffffffc0205e2c:	00001617          	auipc	a2,0x1
ffffffffc0205e30:	6ec60613          	addi	a2,a2,1772 # ffffffffc0207518 <commands+0xc00>
ffffffffc0205e34:	06900593          	li	a1,105
ffffffffc0205e38:	00001517          	auipc	a0,0x1
ffffffffc0205e3c:	6d050513          	addi	a0,a0,1744 # ffffffffc0207508 <commands+0xbf0>
ffffffffc0205e40:	bd6fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205e44:	00002617          	auipc	a2,0x2
ffffffffc0205e48:	94c60613          	addi	a2,a2,-1716 # ffffffffc0207790 <commands+0xe78>
ffffffffc0205e4c:	27a00593          	li	a1,634
ffffffffc0205e50:	00003517          	auipc	a0,0x3
ffffffffc0205e54:	bb850513          	addi	a0,a0,-1096 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0205e58:	bbefa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e5c:	00003697          	auipc	a3,0x3
ffffffffc0205e60:	89468693          	addi	a3,a3,-1900 # ffffffffc02086f0 <default_pmm_manager+0x7e0>
ffffffffc0205e64:	00001617          	auipc	a2,0x1
ffffffffc0205e68:	f3460613          	addi	a2,a2,-204 # ffffffffc0206d98 <commands+0x480>
ffffffffc0205e6c:	27500593          	li	a1,629
ffffffffc0205e70:	00003517          	auipc	a0,0x3
ffffffffc0205e74:	b9850513          	addi	a0,a0,-1128 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0205e78:	b9efa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e7c:	00003697          	auipc	a3,0x3
ffffffffc0205e80:	82c68693          	addi	a3,a3,-2004 # ffffffffc02086a8 <default_pmm_manager+0x798>
ffffffffc0205e84:	00001617          	auipc	a2,0x1
ffffffffc0205e88:	f1460613          	addi	a2,a2,-236 # ffffffffc0206d98 <commands+0x480>
ffffffffc0205e8c:	27400593          	li	a1,628
ffffffffc0205e90:	00003517          	auipc	a0,0x3
ffffffffc0205e94:	b7850513          	addi	a0,a0,-1160 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0205e98:	b7efa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e9c:	00002697          	auipc	a3,0x2
ffffffffc0205ea0:	7c468693          	addi	a3,a3,1988 # ffffffffc0208660 <default_pmm_manager+0x750>
ffffffffc0205ea4:	00001617          	auipc	a2,0x1
ffffffffc0205ea8:	ef460613          	addi	a2,a2,-268 # ffffffffc0206d98 <commands+0x480>
ffffffffc0205eac:	27300593          	li	a1,627
ffffffffc0205eb0:	00003517          	auipc	a0,0x3
ffffffffc0205eb4:	b5850513          	addi	a0,a0,-1192 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0205eb8:	b5efa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205ebc:	00002697          	auipc	a3,0x2
ffffffffc0205ec0:	75c68693          	addi	a3,a3,1884 # ffffffffc0208618 <default_pmm_manager+0x708>
ffffffffc0205ec4:	00001617          	auipc	a2,0x1
ffffffffc0205ec8:	ed460613          	addi	a2,a2,-300 # ffffffffc0206d98 <commands+0x480>
ffffffffc0205ecc:	27200593          	li	a1,626
ffffffffc0205ed0:	00003517          	auipc	a0,0x3
ffffffffc0205ed4:	b3850513          	addi	a0,a0,-1224 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0205ed8:	b3efa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205edc <do_yield>:
    current->need_resched = 1;
ffffffffc0205edc:	000a6797          	auipc	a5,0xa6
ffffffffc0205ee0:	5c478793          	addi	a5,a5,1476 # ffffffffc02ac4a0 <current>
ffffffffc0205ee4:	639c                	ld	a5,0(a5)
ffffffffc0205ee6:	4705                	li	a4,1
}
ffffffffc0205ee8:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205eea:	ef98                	sd	a4,24(a5)
}
ffffffffc0205eec:	8082                	ret

ffffffffc0205eee <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205eee:	1101                	addi	sp,sp,-32
ffffffffc0205ef0:	e822                	sd	s0,16(sp)
ffffffffc0205ef2:	e426                	sd	s1,8(sp)
ffffffffc0205ef4:	ec06                	sd	ra,24(sp)
ffffffffc0205ef6:	842e                	mv	s0,a1
ffffffffc0205ef8:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205efa:	cd81                	beqz	a1,ffffffffc0205f12 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205efc:	000a6797          	auipc	a5,0xa6
ffffffffc0205f00:	5a478793          	addi	a5,a5,1444 # ffffffffc02ac4a0 <current>
ffffffffc0205f04:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205f06:	4685                	li	a3,1
ffffffffc0205f08:	4611                	li	a2,4
ffffffffc0205f0a:	7788                	ld	a0,40(a5)
ffffffffc0205f0c:	a51fb0ef          	jal	ra,ffffffffc020195c <user_mem_check>
ffffffffc0205f10:	c909                	beqz	a0,ffffffffc0205f22 <do_wait+0x34>
ffffffffc0205f12:	85a2                	mv	a1,s0
}
ffffffffc0205f14:	6442                	ld	s0,16(sp)
ffffffffc0205f16:	60e2                	ld	ra,24(sp)
ffffffffc0205f18:	8526                	mv	a0,s1
ffffffffc0205f1a:	64a2                	ld	s1,8(sp)
ffffffffc0205f1c:	6105                	addi	sp,sp,32
ffffffffc0205f1e:	ff0ff06f          	j	ffffffffc020570e <do_wait.part.1>
ffffffffc0205f22:	60e2                	ld	ra,24(sp)
ffffffffc0205f24:	6442                	ld	s0,16(sp)
ffffffffc0205f26:	64a2                	ld	s1,8(sp)
ffffffffc0205f28:	5575                	li	a0,-3
ffffffffc0205f2a:	6105                	addi	sp,sp,32
ffffffffc0205f2c:	8082                	ret

ffffffffc0205f2e <do_kill>:
do_kill(int pid) {
ffffffffc0205f2e:	1141                	addi	sp,sp,-16
ffffffffc0205f30:	e406                	sd	ra,8(sp)
ffffffffc0205f32:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205f34:	a04ff0ef          	jal	ra,ffffffffc0205138 <find_proc>
ffffffffc0205f38:	cd0d                	beqz	a0,ffffffffc0205f72 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205f3a:	0b052703          	lw	a4,176(a0)
ffffffffc0205f3e:	00177693          	andi	a3,a4,1
ffffffffc0205f42:	e695                	bnez	a3,ffffffffc0205f6e <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205f44:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205f48:	00176713          	ori	a4,a4,1
ffffffffc0205f4c:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205f50:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205f52:	0006c763          	bltz	a3,ffffffffc0205f60 <do_kill+0x32>
}
ffffffffc0205f56:	8522                	mv	a0,s0
ffffffffc0205f58:	60a2                	ld	ra,8(sp)
ffffffffc0205f5a:	6402                	ld	s0,0(sp)
ffffffffc0205f5c:	0141                	addi	sp,sp,16
ffffffffc0205f5e:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205f60:	17c000ef          	jal	ra,ffffffffc02060dc <wakeup_proc>
}
ffffffffc0205f64:	8522                	mv	a0,s0
ffffffffc0205f66:	60a2                	ld	ra,8(sp)
ffffffffc0205f68:	6402                	ld	s0,0(sp)
ffffffffc0205f6a:	0141                	addi	sp,sp,16
ffffffffc0205f6c:	8082                	ret
        return -E_KILLED;
ffffffffc0205f6e:	545d                	li	s0,-9
ffffffffc0205f70:	b7dd                	j	ffffffffc0205f56 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205f72:	5475                	li	s0,-3
ffffffffc0205f74:	b7cd                	j	ffffffffc0205f56 <do_kill+0x28>

ffffffffc0205f76 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205f76:	000a6797          	auipc	a5,0xa6
ffffffffc0205f7a:	66a78793          	addi	a5,a5,1642 # ffffffffc02ac5e0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205f7e:	1101                	addi	sp,sp,-32
ffffffffc0205f80:	000a6717          	auipc	a4,0xa6
ffffffffc0205f84:	66f73423          	sd	a5,1640(a4) # ffffffffc02ac5e8 <proc_list+0x8>
ffffffffc0205f88:	000a6717          	auipc	a4,0xa6
ffffffffc0205f8c:	64f73c23          	sd	a5,1624(a4) # ffffffffc02ac5e0 <proc_list>
ffffffffc0205f90:	ec06                	sd	ra,24(sp)
ffffffffc0205f92:	e822                	sd	s0,16(sp)
ffffffffc0205f94:	e426                	sd	s1,8(sp)
ffffffffc0205f96:	000a2797          	auipc	a5,0xa2
ffffffffc0205f9a:	4ca78793          	addi	a5,a5,1226 # ffffffffc02a8460 <hash_list>
ffffffffc0205f9e:	000a6717          	auipc	a4,0xa6
ffffffffc0205fa2:	4c270713          	addi	a4,a4,1218 # ffffffffc02ac460 <is_panic>
ffffffffc0205fa6:	e79c                	sd	a5,8(a5)
ffffffffc0205fa8:	e39c                	sd	a5,0(a5)
ffffffffc0205faa:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205fac:	fee79de3          	bne	a5,a4,ffffffffc0205fa6 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205fb0:	ee3fe0ef          	jal	ra,ffffffffc0204e92 <alloc_proc>
ffffffffc0205fb4:	000a6717          	auipc	a4,0xa6
ffffffffc0205fb8:	4ea73a23          	sd	a0,1268(a4) # ffffffffc02ac4a8 <idleproc>
ffffffffc0205fbc:	000a6497          	auipc	s1,0xa6
ffffffffc0205fc0:	4ec48493          	addi	s1,s1,1260 # ffffffffc02ac4a8 <idleproc>
ffffffffc0205fc4:	c559                	beqz	a0,ffffffffc0206052 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205fc6:	4709                	li	a4,2
ffffffffc0205fc8:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205fca:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205fcc:	00003717          	auipc	a4,0x3
ffffffffc0205fd0:	03470713          	addi	a4,a4,52 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205fd4:	00003597          	auipc	a1,0x3
ffffffffc0205fd8:	94c58593          	addi	a1,a1,-1716 # ffffffffc0208920 <default_pmm_manager+0xa10>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205fdc:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205fde:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205fe0:	8c2ff0ef          	jal	ra,ffffffffc02050a2 <set_proc_name>
    nr_process ++;
ffffffffc0205fe4:	000a6797          	auipc	a5,0xa6
ffffffffc0205fe8:	4d478793          	addi	a5,a5,1236 # ffffffffc02ac4b8 <nr_process>
ffffffffc0205fec:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205fee:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ff0:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205ff2:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ff4:	4581                	li	a1,0
ffffffffc0205ff6:	00000517          	auipc	a0,0x0
ffffffffc0205ffa:	8c050513          	addi	a0,a0,-1856 # ffffffffc02058b6 <init_main>
    nr_process ++;
ffffffffc0205ffe:	000a6697          	auipc	a3,0xa6
ffffffffc0206002:	4af6ad23          	sw	a5,1210(a3) # ffffffffc02ac4b8 <nr_process>
    current = idleproc;
ffffffffc0206006:	000a6797          	auipc	a5,0xa6
ffffffffc020600a:	48e7bd23          	sd	a4,1178(a5) # ffffffffc02ac4a0 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020600e:	d62ff0ef          	jal	ra,ffffffffc0205570 <kernel_thread>
    if (pid <= 0) {
ffffffffc0206012:	08a05c63          	blez	a0,ffffffffc02060aa <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0206016:	922ff0ef          	jal	ra,ffffffffc0205138 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc020601a:	00003597          	auipc	a1,0x3
ffffffffc020601e:	92e58593          	addi	a1,a1,-1746 # ffffffffc0208948 <default_pmm_manager+0xa38>
    initproc = find_proc(pid);
ffffffffc0206022:	000a6797          	auipc	a5,0xa6
ffffffffc0206026:	48a7b723          	sd	a0,1166(a5) # ffffffffc02ac4b0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc020602a:	878ff0ef          	jal	ra,ffffffffc02050a2 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020602e:	609c                	ld	a5,0(s1)
ffffffffc0206030:	cfa9                	beqz	a5,ffffffffc020608a <proc_init+0x114>
ffffffffc0206032:	43dc                	lw	a5,4(a5)
ffffffffc0206034:	ebb9                	bnez	a5,ffffffffc020608a <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0206036:	000a6797          	auipc	a5,0xa6
ffffffffc020603a:	47a78793          	addi	a5,a5,1146 # ffffffffc02ac4b0 <initproc>
ffffffffc020603e:	639c                	ld	a5,0(a5)
ffffffffc0206040:	c78d                	beqz	a5,ffffffffc020606a <proc_init+0xf4>
ffffffffc0206042:	43dc                	lw	a5,4(a5)
ffffffffc0206044:	02879363          	bne	a5,s0,ffffffffc020606a <proc_init+0xf4>
}
ffffffffc0206048:	60e2                	ld	ra,24(sp)
ffffffffc020604a:	6442                	ld	s0,16(sp)
ffffffffc020604c:	64a2                	ld	s1,8(sp)
ffffffffc020604e:	6105                	addi	sp,sp,32
ffffffffc0206050:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0206052:	00003617          	auipc	a2,0x3
ffffffffc0206056:	8b660613          	addi	a2,a2,-1866 # ffffffffc0208908 <default_pmm_manager+0x9f8>
ffffffffc020605a:	37000593          	li	a1,880
ffffffffc020605e:	00003517          	auipc	a0,0x3
ffffffffc0206062:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0206066:	9b0fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020606a:	00003697          	auipc	a3,0x3
ffffffffc020606e:	90e68693          	addi	a3,a3,-1778 # ffffffffc0208978 <default_pmm_manager+0xa68>
ffffffffc0206072:	00001617          	auipc	a2,0x1
ffffffffc0206076:	d2660613          	addi	a2,a2,-730 # ffffffffc0206d98 <commands+0x480>
ffffffffc020607a:	38500593          	li	a1,901
ffffffffc020607e:	00003517          	auipc	a0,0x3
ffffffffc0206082:	98a50513          	addi	a0,a0,-1654 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc0206086:	990fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020608a:	00003697          	auipc	a3,0x3
ffffffffc020608e:	8c668693          	addi	a3,a3,-1850 # ffffffffc0208950 <default_pmm_manager+0xa40>
ffffffffc0206092:	00001617          	auipc	a2,0x1
ffffffffc0206096:	d0660613          	addi	a2,a2,-762 # ffffffffc0206d98 <commands+0x480>
ffffffffc020609a:	38400593          	li	a1,900
ffffffffc020609e:	00003517          	auipc	a0,0x3
ffffffffc02060a2:	96a50513          	addi	a0,a0,-1686 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc02060a6:	970fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create init_main failed.\n");
ffffffffc02060aa:	00003617          	auipc	a2,0x3
ffffffffc02060ae:	87e60613          	addi	a2,a2,-1922 # ffffffffc0208928 <default_pmm_manager+0xa18>
ffffffffc02060b2:	37e00593          	li	a1,894
ffffffffc02060b6:	00003517          	auipc	a0,0x3
ffffffffc02060ba:	95250513          	addi	a0,a0,-1710 # ffffffffc0208a08 <default_pmm_manager+0xaf8>
ffffffffc02060be:	958fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02060c2 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc02060c2:	1141                	addi	sp,sp,-16
ffffffffc02060c4:	e022                	sd	s0,0(sp)
ffffffffc02060c6:	e406                	sd	ra,8(sp)
ffffffffc02060c8:	000a6417          	auipc	s0,0xa6
ffffffffc02060cc:	3d840413          	addi	s0,s0,984 # ffffffffc02ac4a0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02060d0:	6018                	ld	a4,0(s0)
ffffffffc02060d2:	6f1c                	ld	a5,24(a4)
ffffffffc02060d4:	dffd                	beqz	a5,ffffffffc02060d2 <cpu_idle+0x10>
            schedule();
ffffffffc02060d6:	082000ef          	jal	ra,ffffffffc0206158 <schedule>
ffffffffc02060da:	bfdd                	j	ffffffffc02060d0 <cpu_idle+0xe>

ffffffffc02060dc <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060dc:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc02060de:	1101                	addi	sp,sp,-32
ffffffffc02060e0:	ec06                	sd	ra,24(sp)
ffffffffc02060e2:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060e4:	478d                	li	a5,3
ffffffffc02060e6:	04f70a63          	beq	a4,a5,ffffffffc020613a <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060ea:	100027f3          	csrr	a5,sstatus
ffffffffc02060ee:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02060f0:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060f2:	ef8d                	bnez	a5,ffffffffc020612c <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02060f4:	4789                	li	a5,2
ffffffffc02060f6:	00f70f63          	beq	a4,a5,ffffffffc0206114 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc02060fa:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc02060fc:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0206100:	e409                	bnez	s0,ffffffffc020610a <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206102:	60e2                	ld	ra,24(sp)
ffffffffc0206104:	6442                	ld	s0,16(sp)
ffffffffc0206106:	6105                	addi	sp,sp,32
ffffffffc0206108:	8082                	ret
ffffffffc020610a:	6442                	ld	s0,16(sp)
ffffffffc020610c:	60e2                	ld	ra,24(sp)
ffffffffc020610e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0206110:	d46fa06f          	j	ffffffffc0200656 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0206114:	00003617          	auipc	a2,0x3
ffffffffc0206118:	94460613          	addi	a2,a2,-1724 # ffffffffc0208a58 <default_pmm_manager+0xb48>
ffffffffc020611c:	45c9                	li	a1,18
ffffffffc020611e:	00003517          	auipc	a0,0x3
ffffffffc0206122:	92250513          	addi	a0,a0,-1758 # ffffffffc0208a40 <default_pmm_manager+0xb30>
ffffffffc0206126:	95cfa0ef          	jal	ra,ffffffffc0200282 <__warn>
ffffffffc020612a:	bfd9                	j	ffffffffc0206100 <wakeup_proc+0x24>
ffffffffc020612c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020612e:	d2efa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc0206132:	6522                	ld	a0,8(sp)
ffffffffc0206134:	4405                	li	s0,1
ffffffffc0206136:	4118                	lw	a4,0(a0)
ffffffffc0206138:	bf75                	j	ffffffffc02060f4 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020613a:	00003697          	auipc	a3,0x3
ffffffffc020613e:	8e668693          	addi	a3,a3,-1818 # ffffffffc0208a20 <default_pmm_manager+0xb10>
ffffffffc0206142:	00001617          	auipc	a2,0x1
ffffffffc0206146:	c5660613          	addi	a2,a2,-938 # ffffffffc0206d98 <commands+0x480>
ffffffffc020614a:	45a5                	li	a1,9
ffffffffc020614c:	00003517          	auipc	a0,0x3
ffffffffc0206150:	8f450513          	addi	a0,a0,-1804 # ffffffffc0208a40 <default_pmm_manager+0xb30>
ffffffffc0206154:	8c2fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0206158 <schedule>:

void
schedule(void) {
ffffffffc0206158:	1141                	addi	sp,sp,-16
ffffffffc020615a:	e406                	sd	ra,8(sp)
ffffffffc020615c:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020615e:	100027f3          	csrr	a5,sstatus
ffffffffc0206162:	8b89                	andi	a5,a5,2
ffffffffc0206164:	4401                	li	s0,0
ffffffffc0206166:	e3d1                	bnez	a5,ffffffffc02061ea <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0206168:	000a6797          	auipc	a5,0xa6
ffffffffc020616c:	33878793          	addi	a5,a5,824 # ffffffffc02ac4a0 <current>
ffffffffc0206170:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206174:	000a6797          	auipc	a5,0xa6
ffffffffc0206178:	33478793          	addi	a5,a5,820 # ffffffffc02ac4a8 <idleproc>
ffffffffc020617c:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc020617e:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x7560>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206182:	04a88e63          	beq	a7,a0,ffffffffc02061de <schedule+0x86>
ffffffffc0206186:	0c888693          	addi	a3,a7,200
ffffffffc020618a:	000a6617          	auipc	a2,0xa6
ffffffffc020618e:	45660613          	addi	a2,a2,1110 # ffffffffc02ac5e0 <proc_list>
        le = last;
ffffffffc0206192:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0206194:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206196:	4809                	li	a6,2
    return listelm->next;
ffffffffc0206198:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc020619a:	00c78863          	beq	a5,a2,ffffffffc02061aa <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020619e:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02061a2:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02061a6:	01070463          	beq	a4,a6,ffffffffc02061ae <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc02061aa:	fef697e3          	bne	a3,a5,ffffffffc0206198 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02061ae:	c589                	beqz	a1,ffffffffc02061b8 <schedule+0x60>
ffffffffc02061b0:	4198                	lw	a4,0(a1)
ffffffffc02061b2:	4789                	li	a5,2
ffffffffc02061b4:	00f70e63          	beq	a4,a5,ffffffffc02061d0 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02061b8:	451c                	lw	a5,8(a0)
ffffffffc02061ba:	2785                	addiw	a5,a5,1
ffffffffc02061bc:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02061be:	00a88463          	beq	a7,a0,ffffffffc02061c6 <schedule+0x6e>
            proc_run(next);
ffffffffc02061c2:	f0bfe0ef          	jal	ra,ffffffffc02050cc <proc_run>
    if (flag) {
ffffffffc02061c6:	e419                	bnez	s0,ffffffffc02061d4 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02061c8:	60a2                	ld	ra,8(sp)
ffffffffc02061ca:	6402                	ld	s0,0(sp)
ffffffffc02061cc:	0141                	addi	sp,sp,16
ffffffffc02061ce:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02061d0:	852e                	mv	a0,a1
ffffffffc02061d2:	b7dd                	j	ffffffffc02061b8 <schedule+0x60>
}
ffffffffc02061d4:	6402                	ld	s0,0(sp)
ffffffffc02061d6:	60a2                	ld	ra,8(sp)
ffffffffc02061d8:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02061da:	c7cfa06f          	j	ffffffffc0200656 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02061de:	000a6617          	auipc	a2,0xa6
ffffffffc02061e2:	40260613          	addi	a2,a2,1026 # ffffffffc02ac5e0 <proc_list>
ffffffffc02061e6:	86b2                	mv	a3,a2
ffffffffc02061e8:	b76d                	j	ffffffffc0206192 <schedule+0x3a>
        intr_disable();
ffffffffc02061ea:	c72fa0ef          	jal	ra,ffffffffc020065c <intr_disable>
        return 1;
ffffffffc02061ee:	4405                	li	s0,1
ffffffffc02061f0:	bfa5                	j	ffffffffc0206168 <schedule+0x10>

ffffffffc02061f2 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc02061f2:	000a6797          	auipc	a5,0xa6
ffffffffc02061f6:	2ae78793          	addi	a5,a5,686 # ffffffffc02ac4a0 <current>
ffffffffc02061fa:	639c                	ld	a5,0(a5)
}
ffffffffc02061fc:	43c8                	lw	a0,4(a5)
ffffffffc02061fe:	8082                	ret

ffffffffc0206200 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206200:	4501                	li	a0,0
ffffffffc0206202:	8082                	ret

ffffffffc0206204 <sys_putc>:
    cputchar(c);
ffffffffc0206204:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206206:	1141                	addi	sp,sp,-16
ffffffffc0206208:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020620a:	efbf90ef          	jal	ra,ffffffffc0200104 <cputchar>
}
ffffffffc020620e:	60a2                	ld	ra,8(sp)
ffffffffc0206210:	4501                	li	a0,0
ffffffffc0206212:	0141                	addi	sp,sp,16
ffffffffc0206214:	8082                	ret

ffffffffc0206216 <sys_kill>:
    return do_kill(pid);
ffffffffc0206216:	4108                	lw	a0,0(a0)
ffffffffc0206218:	d17ff06f          	j	ffffffffc0205f2e <do_kill>

ffffffffc020621c <sys_yield>:
    return do_yield();
ffffffffc020621c:	cc1ff06f          	j	ffffffffc0205edc <do_yield>

ffffffffc0206220 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206220:	6d14                	ld	a3,24(a0)
ffffffffc0206222:	6910                	ld	a2,16(a0)
ffffffffc0206224:	650c                	ld	a1,8(a0)
ffffffffc0206226:	6108                	ld	a0,0(a0)
ffffffffc0206228:	fb6ff06f          	j	ffffffffc02059de <do_execve>

ffffffffc020622c <sys_wait>:
    return do_wait(pid, store);
ffffffffc020622c:	650c                	ld	a1,8(a0)
ffffffffc020622e:	4108                	lw	a0,0(a0)
ffffffffc0206230:	cbfff06f          	j	ffffffffc0205eee <do_wait>

ffffffffc0206234 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206234:	000a6797          	auipc	a5,0xa6
ffffffffc0206238:	26c78793          	addi	a5,a5,620 # ffffffffc02ac4a0 <current>
ffffffffc020623c:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc020623e:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0206240:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206242:	6a0c                	ld	a1,16(a2)
ffffffffc0206244:	f51fe06f          	j	ffffffffc0205194 <do_fork>

ffffffffc0206248 <sys_exit>:
    return do_exit(error_code);
ffffffffc0206248:	4108                	lw	a0,0(a0)
ffffffffc020624a:	b76ff06f          	j	ffffffffc02055c0 <do_exit>

ffffffffc020624e <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc020624e:	715d                	addi	sp,sp,-80
ffffffffc0206250:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206252:	000a6497          	auipc	s1,0xa6
ffffffffc0206256:	24e48493          	addi	s1,s1,590 # ffffffffc02ac4a0 <current>
ffffffffc020625a:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc020625c:	e0a2                	sd	s0,64(sp)
ffffffffc020625e:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206260:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0206262:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206264:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0206266:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020626a:	0327ee63          	bltu	a5,s2,ffffffffc02062a6 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc020626e:	00391713          	slli	a4,s2,0x3
ffffffffc0206272:	00003797          	auipc	a5,0x3
ffffffffc0206276:	84e78793          	addi	a5,a5,-1970 # ffffffffc0208ac0 <syscalls>
ffffffffc020627a:	97ba                	add	a5,a5,a4
ffffffffc020627c:	639c                	ld	a5,0(a5)
ffffffffc020627e:	c785                	beqz	a5,ffffffffc02062a6 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206280:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0206282:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0206284:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0206286:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0206288:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc020628a:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc020628c:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc020628e:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0206290:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0206292:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206294:	0028                	addi	a0,sp,8
ffffffffc0206296:	9782                	jalr	a5
ffffffffc0206298:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc020629a:	60a6                	ld	ra,72(sp)
ffffffffc020629c:	6406                	ld	s0,64(sp)
ffffffffc020629e:	74e2                	ld	s1,56(sp)
ffffffffc02062a0:	7942                	ld	s2,48(sp)
ffffffffc02062a2:	6161                	addi	sp,sp,80
ffffffffc02062a4:	8082                	ret
    print_trapframe(tf);
ffffffffc02062a6:	8522                	mv	a0,s0
ffffffffc02062a8:	da2fa0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02062ac:	609c                	ld	a5,0(s1)
ffffffffc02062ae:	86ca                	mv	a3,s2
ffffffffc02062b0:	00002617          	auipc	a2,0x2
ffffffffc02062b4:	7c860613          	addi	a2,a2,1992 # ffffffffc0208a78 <default_pmm_manager+0xb68>
ffffffffc02062b8:	43d8                	lw	a4,4(a5)
ffffffffc02062ba:	06300593          	li	a1,99
ffffffffc02062be:	0b478793          	addi	a5,a5,180
ffffffffc02062c2:	00002517          	auipc	a0,0x2
ffffffffc02062c6:	7e650513          	addi	a0,a0,2022 # ffffffffc0208aa8 <default_pmm_manager+0xb98>
ffffffffc02062ca:	f4df90ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02062ce <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02062ce:	00054783          	lbu	a5,0(a0)
ffffffffc02062d2:	cb91                	beqz	a5,ffffffffc02062e6 <strlen+0x18>
    size_t cnt = 0;
ffffffffc02062d4:	4781                	li	a5,0
        cnt ++;
ffffffffc02062d6:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02062d8:	00f50733          	add	a4,a0,a5
ffffffffc02062dc:	00074703          	lbu	a4,0(a4)
ffffffffc02062e0:	fb7d                	bnez	a4,ffffffffc02062d6 <strlen+0x8>
    }
    return cnt;
}
ffffffffc02062e2:	853e                	mv	a0,a5
ffffffffc02062e4:	8082                	ret
    size_t cnt = 0;
ffffffffc02062e6:	4781                	li	a5,0
}
ffffffffc02062e8:	853e                	mv	a0,a5
ffffffffc02062ea:	8082                	ret

ffffffffc02062ec <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02062ec:	c185                	beqz	a1,ffffffffc020630c <strnlen+0x20>
ffffffffc02062ee:	00054783          	lbu	a5,0(a0)
ffffffffc02062f2:	cf89                	beqz	a5,ffffffffc020630c <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02062f4:	4781                	li	a5,0
ffffffffc02062f6:	a021                	j	ffffffffc02062fe <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02062f8:	00074703          	lbu	a4,0(a4)
ffffffffc02062fc:	c711                	beqz	a4,ffffffffc0206308 <strnlen+0x1c>
        cnt ++;
ffffffffc02062fe:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206300:	00f50733          	add	a4,a0,a5
ffffffffc0206304:	fef59ae3          	bne	a1,a5,ffffffffc02062f8 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0206308:	853e                	mv	a0,a5
ffffffffc020630a:	8082                	ret
    size_t cnt = 0;
ffffffffc020630c:	4781                	li	a5,0
}
ffffffffc020630e:	853e                	mv	a0,a5
ffffffffc0206310:	8082                	ret

ffffffffc0206312 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206312:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206314:	0585                	addi	a1,a1,1
ffffffffc0206316:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020631a:	0785                	addi	a5,a5,1
ffffffffc020631c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206320:	fb75                	bnez	a4,ffffffffc0206314 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206322:	8082                	ret

ffffffffc0206324 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206324:	00054783          	lbu	a5,0(a0)
ffffffffc0206328:	0005c703          	lbu	a4,0(a1)
ffffffffc020632c:	cb91                	beqz	a5,ffffffffc0206340 <strcmp+0x1c>
ffffffffc020632e:	00e79c63          	bne	a5,a4,ffffffffc0206346 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0206332:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206334:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0206338:	0585                	addi	a1,a1,1
ffffffffc020633a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020633e:	fbe5                	bnez	a5,ffffffffc020632e <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206340:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206342:	9d19                	subw	a0,a0,a4
ffffffffc0206344:	8082                	ret
ffffffffc0206346:	0007851b          	sext.w	a0,a5
ffffffffc020634a:	9d19                	subw	a0,a0,a4
ffffffffc020634c:	8082                	ret

ffffffffc020634e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020634e:	00054783          	lbu	a5,0(a0)
ffffffffc0206352:	cb91                	beqz	a5,ffffffffc0206366 <strchr+0x18>
        if (*s == c) {
ffffffffc0206354:	00b79563          	bne	a5,a1,ffffffffc020635e <strchr+0x10>
ffffffffc0206358:	a809                	j	ffffffffc020636a <strchr+0x1c>
ffffffffc020635a:	00b78763          	beq	a5,a1,ffffffffc0206368 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020635e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206360:	00054783          	lbu	a5,0(a0)
ffffffffc0206364:	fbfd                	bnez	a5,ffffffffc020635a <strchr+0xc>
    }
    return NULL;
ffffffffc0206366:	4501                	li	a0,0
}
ffffffffc0206368:	8082                	ret
ffffffffc020636a:	8082                	ret

ffffffffc020636c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020636c:	ca01                	beqz	a2,ffffffffc020637c <memset+0x10>
ffffffffc020636e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206370:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206372:	0785                	addi	a5,a5,1
ffffffffc0206374:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206378:	fec79de3          	bne	a5,a2,ffffffffc0206372 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020637c:	8082                	ret

ffffffffc020637e <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020637e:	ca19                	beqz	a2,ffffffffc0206394 <memcpy+0x16>
ffffffffc0206380:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0206382:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206384:	0585                	addi	a1,a1,1
ffffffffc0206386:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020638a:	0785                	addi	a5,a5,1
ffffffffc020638c:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206390:	fec59ae3          	bne	a1,a2,ffffffffc0206384 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206394:	8082                	ret

ffffffffc0206396 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206396:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020639a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020639c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02063a0:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02063a2:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02063a6:	f022                	sd	s0,32(sp)
ffffffffc02063a8:	ec26                	sd	s1,24(sp)
ffffffffc02063aa:	e84a                	sd	s2,16(sp)
ffffffffc02063ac:	f406                	sd	ra,40(sp)
ffffffffc02063ae:	e44e                	sd	s3,8(sp)
ffffffffc02063b0:	84aa                	mv	s1,a0
ffffffffc02063b2:	892e                	mv	s2,a1
ffffffffc02063b4:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02063b8:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02063ba:	03067e63          	bleu	a6,a2,ffffffffc02063f6 <printnum+0x60>
ffffffffc02063be:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02063c0:	00805763          	blez	s0,ffffffffc02063ce <printnum+0x38>
ffffffffc02063c4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02063c6:	85ca                	mv	a1,s2
ffffffffc02063c8:	854e                	mv	a0,s3
ffffffffc02063ca:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02063cc:	fc65                	bnez	s0,ffffffffc02063c4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063ce:	1a02                	slli	s4,s4,0x20
ffffffffc02063d0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02063d4:	00003797          	auipc	a5,0x3
ffffffffc02063d8:	a0c78793          	addi	a5,a5,-1524 # ffffffffc0208de0 <error_string+0xc8>
ffffffffc02063dc:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02063de:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063e0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02063e4:	70a2                	ld	ra,40(sp)
ffffffffc02063e6:	69a2                	ld	s3,8(sp)
ffffffffc02063e8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063ea:	85ca                	mv	a1,s2
ffffffffc02063ec:	8326                	mv	t1,s1
}
ffffffffc02063ee:	6942                	ld	s2,16(sp)
ffffffffc02063f0:	64e2                	ld	s1,24(sp)
ffffffffc02063f2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02063f4:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02063f6:	03065633          	divu	a2,a2,a6
ffffffffc02063fa:	8722                	mv	a4,s0
ffffffffc02063fc:	f9bff0ef          	jal	ra,ffffffffc0206396 <printnum>
ffffffffc0206400:	b7f9                	j	ffffffffc02063ce <printnum+0x38>

ffffffffc0206402 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206402:	7119                	addi	sp,sp,-128
ffffffffc0206404:	f4a6                	sd	s1,104(sp)
ffffffffc0206406:	f0ca                	sd	s2,96(sp)
ffffffffc0206408:	e8d2                	sd	s4,80(sp)
ffffffffc020640a:	e4d6                	sd	s5,72(sp)
ffffffffc020640c:	e0da                	sd	s6,64(sp)
ffffffffc020640e:	fc5e                	sd	s7,56(sp)
ffffffffc0206410:	f862                	sd	s8,48(sp)
ffffffffc0206412:	f06a                	sd	s10,32(sp)
ffffffffc0206414:	fc86                	sd	ra,120(sp)
ffffffffc0206416:	f8a2                	sd	s0,112(sp)
ffffffffc0206418:	ecce                	sd	s3,88(sp)
ffffffffc020641a:	f466                	sd	s9,40(sp)
ffffffffc020641c:	ec6e                	sd	s11,24(sp)
ffffffffc020641e:	892a                	mv	s2,a0
ffffffffc0206420:	84ae                	mv	s1,a1
ffffffffc0206422:	8d32                	mv	s10,a2
ffffffffc0206424:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206426:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206428:	00002a17          	auipc	s4,0x2
ffffffffc020642c:	798a0a13          	addi	s4,s4,1944 # ffffffffc0208bc0 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206430:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206434:	00003c17          	auipc	s8,0x3
ffffffffc0206438:	8e4c0c13          	addi	s8,s8,-1820 # ffffffffc0208d18 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020643c:	000d4503          	lbu	a0,0(s10)
ffffffffc0206440:	02500793          	li	a5,37
ffffffffc0206444:	001d0413          	addi	s0,s10,1
ffffffffc0206448:	00f50e63          	beq	a0,a5,ffffffffc0206464 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc020644c:	c521                	beqz	a0,ffffffffc0206494 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020644e:	02500993          	li	s3,37
ffffffffc0206452:	a011                	j	ffffffffc0206456 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0206454:	c121                	beqz	a0,ffffffffc0206494 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0206456:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206458:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020645a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020645c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206460:	ff351ae3          	bne	a0,s3,ffffffffc0206454 <vprintfmt+0x52>
ffffffffc0206464:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0206468:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020646c:	4981                	li	s3,0
ffffffffc020646e:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0206470:	5cfd                	li	s9,-1
ffffffffc0206472:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206474:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0206478:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020647a:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020647e:	0ff6f693          	andi	a3,a3,255
ffffffffc0206482:	00140d13          	addi	s10,s0,1
ffffffffc0206486:	20d5e563          	bltu	a1,a3,ffffffffc0206690 <vprintfmt+0x28e>
ffffffffc020648a:	068a                	slli	a3,a3,0x2
ffffffffc020648c:	96d2                	add	a3,a3,s4
ffffffffc020648e:	4294                	lw	a3,0(a3)
ffffffffc0206490:	96d2                	add	a3,a3,s4
ffffffffc0206492:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206494:	70e6                	ld	ra,120(sp)
ffffffffc0206496:	7446                	ld	s0,112(sp)
ffffffffc0206498:	74a6                	ld	s1,104(sp)
ffffffffc020649a:	7906                	ld	s2,96(sp)
ffffffffc020649c:	69e6                	ld	s3,88(sp)
ffffffffc020649e:	6a46                	ld	s4,80(sp)
ffffffffc02064a0:	6aa6                	ld	s5,72(sp)
ffffffffc02064a2:	6b06                	ld	s6,64(sp)
ffffffffc02064a4:	7be2                	ld	s7,56(sp)
ffffffffc02064a6:	7c42                	ld	s8,48(sp)
ffffffffc02064a8:	7ca2                	ld	s9,40(sp)
ffffffffc02064aa:	7d02                	ld	s10,32(sp)
ffffffffc02064ac:	6de2                	ld	s11,24(sp)
ffffffffc02064ae:	6109                	addi	sp,sp,128
ffffffffc02064b0:	8082                	ret
    if (lflag >= 2) {
ffffffffc02064b2:	4705                	li	a4,1
ffffffffc02064b4:	008a8593          	addi	a1,s5,8
ffffffffc02064b8:	01074463          	blt	a4,a6,ffffffffc02064c0 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02064bc:	26080363          	beqz	a6,ffffffffc0206722 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02064c0:	000ab603          	ld	a2,0(s5)
ffffffffc02064c4:	46c1                	li	a3,16
ffffffffc02064c6:	8aae                	mv	s5,a1
ffffffffc02064c8:	a06d                	j	ffffffffc0206572 <vprintfmt+0x170>
            goto reswitch;
ffffffffc02064ca:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02064ce:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064d0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02064d2:	b765                	j	ffffffffc020647a <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02064d4:	000aa503          	lw	a0,0(s5)
ffffffffc02064d8:	85a6                	mv	a1,s1
ffffffffc02064da:	0aa1                	addi	s5,s5,8
ffffffffc02064dc:	9902                	jalr	s2
            break;
ffffffffc02064de:	bfb9                	j	ffffffffc020643c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02064e0:	4705                	li	a4,1
ffffffffc02064e2:	008a8993          	addi	s3,s5,8
ffffffffc02064e6:	01074463          	blt	a4,a6,ffffffffc02064ee <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02064ea:	22080463          	beqz	a6,ffffffffc0206712 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02064ee:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02064f2:	24044463          	bltz	s0,ffffffffc020673a <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02064f6:	8622                	mv	a2,s0
ffffffffc02064f8:	8ace                	mv	s5,s3
ffffffffc02064fa:	46a9                	li	a3,10
ffffffffc02064fc:	a89d                	j	ffffffffc0206572 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02064fe:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206502:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206504:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0206506:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020650a:	8fb5                	xor	a5,a5,a3
ffffffffc020650c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206510:	1ad74363          	blt	a4,a3,ffffffffc02066b6 <vprintfmt+0x2b4>
ffffffffc0206514:	00369793          	slli	a5,a3,0x3
ffffffffc0206518:	97e2                	add	a5,a5,s8
ffffffffc020651a:	639c                	ld	a5,0(a5)
ffffffffc020651c:	18078d63          	beqz	a5,ffffffffc02066b6 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206520:	86be                	mv	a3,a5
ffffffffc0206522:	00000617          	auipc	a2,0x0
ffffffffc0206526:	2ae60613          	addi	a2,a2,686 # ffffffffc02067d0 <etext+0x2a>
ffffffffc020652a:	85a6                	mv	a1,s1
ffffffffc020652c:	854a                	mv	a0,s2
ffffffffc020652e:	240000ef          	jal	ra,ffffffffc020676e <printfmt>
ffffffffc0206532:	b729                	j	ffffffffc020643c <vprintfmt+0x3a>
            lflag ++;
ffffffffc0206534:	00144603          	lbu	a2,1(s0)
ffffffffc0206538:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020653a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020653c:	bf3d                	j	ffffffffc020647a <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020653e:	4705                	li	a4,1
ffffffffc0206540:	008a8593          	addi	a1,s5,8
ffffffffc0206544:	01074463          	blt	a4,a6,ffffffffc020654c <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0206548:	1e080263          	beqz	a6,ffffffffc020672c <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc020654c:	000ab603          	ld	a2,0(s5)
ffffffffc0206550:	46a1                	li	a3,8
ffffffffc0206552:	8aae                	mv	s5,a1
ffffffffc0206554:	a839                	j	ffffffffc0206572 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0206556:	03000513          	li	a0,48
ffffffffc020655a:	85a6                	mv	a1,s1
ffffffffc020655c:	e03e                	sd	a5,0(sp)
ffffffffc020655e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206560:	85a6                	mv	a1,s1
ffffffffc0206562:	07800513          	li	a0,120
ffffffffc0206566:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206568:	0aa1                	addi	s5,s5,8
ffffffffc020656a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020656e:	6782                	ld	a5,0(sp)
ffffffffc0206570:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206572:	876e                	mv	a4,s11
ffffffffc0206574:	85a6                	mv	a1,s1
ffffffffc0206576:	854a                	mv	a0,s2
ffffffffc0206578:	e1fff0ef          	jal	ra,ffffffffc0206396 <printnum>
            break;
ffffffffc020657c:	b5c1                	j	ffffffffc020643c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020657e:	000ab603          	ld	a2,0(s5)
ffffffffc0206582:	0aa1                	addi	s5,s5,8
ffffffffc0206584:	1c060663          	beqz	a2,ffffffffc0206750 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0206588:	00160413          	addi	s0,a2,1
ffffffffc020658c:	17b05c63          	blez	s11,ffffffffc0206704 <vprintfmt+0x302>
ffffffffc0206590:	02d00593          	li	a1,45
ffffffffc0206594:	14b79263          	bne	a5,a1,ffffffffc02066d8 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206598:	00064783          	lbu	a5,0(a2)
ffffffffc020659c:	0007851b          	sext.w	a0,a5
ffffffffc02065a0:	c905                	beqz	a0,ffffffffc02065d0 <vprintfmt+0x1ce>
ffffffffc02065a2:	000cc563          	bltz	s9,ffffffffc02065ac <vprintfmt+0x1aa>
ffffffffc02065a6:	3cfd                	addiw	s9,s9,-1
ffffffffc02065a8:	036c8263          	beq	s9,s6,ffffffffc02065cc <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02065ac:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02065ae:	18098463          	beqz	s3,ffffffffc0206736 <vprintfmt+0x334>
ffffffffc02065b2:	3781                	addiw	a5,a5,-32
ffffffffc02065b4:	18fbf163          	bleu	a5,s7,ffffffffc0206736 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02065b8:	03f00513          	li	a0,63
ffffffffc02065bc:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065be:	0405                	addi	s0,s0,1
ffffffffc02065c0:	fff44783          	lbu	a5,-1(s0)
ffffffffc02065c4:	3dfd                	addiw	s11,s11,-1
ffffffffc02065c6:	0007851b          	sext.w	a0,a5
ffffffffc02065ca:	fd61                	bnez	a0,ffffffffc02065a2 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02065cc:	e7b058e3          	blez	s11,ffffffffc020643c <vprintfmt+0x3a>
ffffffffc02065d0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02065d2:	85a6                	mv	a1,s1
ffffffffc02065d4:	02000513          	li	a0,32
ffffffffc02065d8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02065da:	e60d81e3          	beqz	s11,ffffffffc020643c <vprintfmt+0x3a>
ffffffffc02065de:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02065e0:	85a6                	mv	a1,s1
ffffffffc02065e2:	02000513          	li	a0,32
ffffffffc02065e6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02065e8:	fe0d94e3          	bnez	s11,ffffffffc02065d0 <vprintfmt+0x1ce>
ffffffffc02065ec:	bd81                	j	ffffffffc020643c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02065ee:	4705                	li	a4,1
ffffffffc02065f0:	008a8593          	addi	a1,s5,8
ffffffffc02065f4:	01074463          	blt	a4,a6,ffffffffc02065fc <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02065f8:	12080063          	beqz	a6,ffffffffc0206718 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02065fc:	000ab603          	ld	a2,0(s5)
ffffffffc0206600:	46a9                	li	a3,10
ffffffffc0206602:	8aae                	mv	s5,a1
ffffffffc0206604:	b7bd                	j	ffffffffc0206572 <vprintfmt+0x170>
ffffffffc0206606:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc020660a:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020660e:	846a                	mv	s0,s10
ffffffffc0206610:	b5ad                	j	ffffffffc020647a <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0206612:	85a6                	mv	a1,s1
ffffffffc0206614:	02500513          	li	a0,37
ffffffffc0206618:	9902                	jalr	s2
            break;
ffffffffc020661a:	b50d                	j	ffffffffc020643c <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc020661c:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0206620:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206624:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206626:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0206628:	e40dd9e3          	bgez	s11,ffffffffc020647a <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020662c:	8de6                	mv	s11,s9
ffffffffc020662e:	5cfd                	li	s9,-1
ffffffffc0206630:	b5a9                	j	ffffffffc020647a <vprintfmt+0x78>
            goto reswitch;
ffffffffc0206632:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0206636:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020663a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020663c:	bd3d                	j	ffffffffc020647a <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc020663e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0206642:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206646:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206648:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020664c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206650:	fcd56ce3          	bltu	a0,a3,ffffffffc0206628 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0206654:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206656:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020665a:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020665e:	0196873b          	addw	a4,a3,s9
ffffffffc0206662:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206666:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020666a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020666e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0206672:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206676:	fcd57fe3          	bleu	a3,a0,ffffffffc0206654 <vprintfmt+0x252>
ffffffffc020667a:	b77d                	j	ffffffffc0206628 <vprintfmt+0x226>
            if (width < 0)
ffffffffc020667c:	fffdc693          	not	a3,s11
ffffffffc0206680:	96fd                	srai	a3,a3,0x3f
ffffffffc0206682:	00ddfdb3          	and	s11,s11,a3
ffffffffc0206686:	00144603          	lbu	a2,1(s0)
ffffffffc020668a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020668c:	846a                	mv	s0,s10
ffffffffc020668e:	b3f5                	j	ffffffffc020647a <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0206690:	85a6                	mv	a1,s1
ffffffffc0206692:	02500513          	li	a0,37
ffffffffc0206696:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206698:	fff44703          	lbu	a4,-1(s0)
ffffffffc020669c:	02500793          	li	a5,37
ffffffffc02066a0:	8d22                	mv	s10,s0
ffffffffc02066a2:	d8f70de3          	beq	a4,a5,ffffffffc020643c <vprintfmt+0x3a>
ffffffffc02066a6:	02500713          	li	a4,37
ffffffffc02066aa:	1d7d                	addi	s10,s10,-1
ffffffffc02066ac:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02066b0:	fee79de3          	bne	a5,a4,ffffffffc02066aa <vprintfmt+0x2a8>
ffffffffc02066b4:	b361                	j	ffffffffc020643c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02066b6:	00003617          	auipc	a2,0x3
ffffffffc02066ba:	80a60613          	addi	a2,a2,-2038 # ffffffffc0208ec0 <error_string+0x1a8>
ffffffffc02066be:	85a6                	mv	a1,s1
ffffffffc02066c0:	854a                	mv	a0,s2
ffffffffc02066c2:	0ac000ef          	jal	ra,ffffffffc020676e <printfmt>
ffffffffc02066c6:	bb9d                	j	ffffffffc020643c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02066c8:	00002617          	auipc	a2,0x2
ffffffffc02066cc:	7f060613          	addi	a2,a2,2032 # ffffffffc0208eb8 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc02066d0:	00002417          	auipc	s0,0x2
ffffffffc02066d4:	7e940413          	addi	s0,s0,2025 # ffffffffc0208eb9 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02066d8:	8532                	mv	a0,a2
ffffffffc02066da:	85e6                	mv	a1,s9
ffffffffc02066dc:	e032                	sd	a2,0(sp)
ffffffffc02066de:	e43e                	sd	a5,8(sp)
ffffffffc02066e0:	c0dff0ef          	jal	ra,ffffffffc02062ec <strnlen>
ffffffffc02066e4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02066e8:	6602                	ld	a2,0(sp)
ffffffffc02066ea:	01b05d63          	blez	s11,ffffffffc0206704 <vprintfmt+0x302>
ffffffffc02066ee:	67a2                	ld	a5,8(sp)
ffffffffc02066f0:	2781                	sext.w	a5,a5
ffffffffc02066f2:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02066f4:	6522                	ld	a0,8(sp)
ffffffffc02066f6:	85a6                	mv	a1,s1
ffffffffc02066f8:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02066fa:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02066fc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02066fe:	6602                	ld	a2,0(sp)
ffffffffc0206700:	fe0d9ae3          	bnez	s11,ffffffffc02066f4 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206704:	00064783          	lbu	a5,0(a2)
ffffffffc0206708:	0007851b          	sext.w	a0,a5
ffffffffc020670c:	e8051be3          	bnez	a0,ffffffffc02065a2 <vprintfmt+0x1a0>
ffffffffc0206710:	b335                	j	ffffffffc020643c <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0206712:	000aa403          	lw	s0,0(s5)
ffffffffc0206716:	bbf1                	j	ffffffffc02064f2 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0206718:	000ae603          	lwu	a2,0(s5)
ffffffffc020671c:	46a9                	li	a3,10
ffffffffc020671e:	8aae                	mv	s5,a1
ffffffffc0206720:	bd89                	j	ffffffffc0206572 <vprintfmt+0x170>
ffffffffc0206722:	000ae603          	lwu	a2,0(s5)
ffffffffc0206726:	46c1                	li	a3,16
ffffffffc0206728:	8aae                	mv	s5,a1
ffffffffc020672a:	b5a1                	j	ffffffffc0206572 <vprintfmt+0x170>
ffffffffc020672c:	000ae603          	lwu	a2,0(s5)
ffffffffc0206730:	46a1                	li	a3,8
ffffffffc0206732:	8aae                	mv	s5,a1
ffffffffc0206734:	bd3d                	j	ffffffffc0206572 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0206736:	9902                	jalr	s2
ffffffffc0206738:	b559                	j	ffffffffc02065be <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020673a:	85a6                	mv	a1,s1
ffffffffc020673c:	02d00513          	li	a0,45
ffffffffc0206740:	e03e                	sd	a5,0(sp)
ffffffffc0206742:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206744:	8ace                	mv	s5,s3
ffffffffc0206746:	40800633          	neg	a2,s0
ffffffffc020674a:	46a9                	li	a3,10
ffffffffc020674c:	6782                	ld	a5,0(sp)
ffffffffc020674e:	b515                	j	ffffffffc0206572 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0206750:	01b05663          	blez	s11,ffffffffc020675c <vprintfmt+0x35a>
ffffffffc0206754:	02d00693          	li	a3,45
ffffffffc0206758:	f6d798e3          	bne	a5,a3,ffffffffc02066c8 <vprintfmt+0x2c6>
ffffffffc020675c:	00002417          	auipc	s0,0x2
ffffffffc0206760:	75d40413          	addi	s0,s0,1885 # ffffffffc0208eb9 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206764:	02800513          	li	a0,40
ffffffffc0206768:	02800793          	li	a5,40
ffffffffc020676c:	bd1d                	j	ffffffffc02065a2 <vprintfmt+0x1a0>

ffffffffc020676e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020676e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206770:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206774:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206776:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206778:	ec06                	sd	ra,24(sp)
ffffffffc020677a:	f83a                	sd	a4,48(sp)
ffffffffc020677c:	fc3e                	sd	a5,56(sp)
ffffffffc020677e:	e0c2                	sd	a6,64(sp)
ffffffffc0206780:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206782:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206784:	c7fff0ef          	jal	ra,ffffffffc0206402 <vprintfmt>
}
ffffffffc0206788:	60e2                	ld	ra,24(sp)
ffffffffc020678a:	6161                	addi	sp,sp,80
ffffffffc020678c:	8082                	ret

ffffffffc020678e <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020678e:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206792:	2785                	addiw	a5,a5,1
ffffffffc0206794:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0206798:	02000793          	li	a5,32
ffffffffc020679c:	40b785bb          	subw	a1,a5,a1
}
ffffffffc02067a0:	00b5553b          	srlw	a0,a0,a1
ffffffffc02067a4:	8082                	ret
