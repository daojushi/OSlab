# lab4
## 练习1：分配并初始化一个进程控制块（需要编码）

alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。
    【提示】在alloc_proc函数的实现中，需要初始化的proc_struct结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：
    请说明proc_struct中struct context context和struct trapframe *tf成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）
### 代码  
```cpp
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    //LAB4:EXERCISE1 YOUR CODE
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state=PROC_UNINIT;
        proc->pid=-1;
        proc->runs=0;
        proc->kstack=0;
        proc->need_resched=0;
        proc->parent=NULL;
        proc->mm=NULL;
        proc->tf=NULL;
        proc->cr3=boot_cr3;
        proc->flags=0;
        memset(proc->name,0,PROC_NAME_LEN+1);
        memset(&(proc->context),0,sizeof(struct context));
    }
    return proc;
}
```
### 回答
- `struct context context`: 进程上下文，用于存储和恢复处理器寄存器的状态。它包含了一个进程执行的全部寄存器信息，允许在进程之间进行上下文切换。当处理器需要切换到一个新的进程时，它会保存当前进程的上下文并加载新进程的上下文，以确保进程的执行可以在之后被恢复。

- `struct trapframe *tf`: 中断帧，存储了当中断发生时处理器的状态。这包括了中断处理前处理器的状态，比如被中断时的寄存器值、中断原因等信息。当处理器发生中断或异常时，它会将当前的状态保存在这个结构中，并开始执行中断处理程序。在操作系统中，这个结构通常用于保存用户态进程被中断时的状态，便于在中断处理完后恢复用户进程的执行。

在实验中，这两个成员变量对于进程的管理和上下文切换非常重要。`context` 用于保存整个进程的上下文信息，而 `tf` 则用于在进程被中断时保存当前的处理器状态。
## 练习2：为新创建的内核线程分配资源（需要编码）

创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用do_fork函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们实际需要"fork"的东西就是stack和trapframe。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：

   >调用alloc_proc，首先获得一块用户信息块。
    为进程分配一个内核栈。
    复制原进程的内存管理信息到新进程（但内核线程不必做此事）
    复制原进程上下文到新进程
    将新进程添加到进程列表
    唤醒新进程
    返回新进程号

请在实验报告中简要说明你的设计实现过程。请回答如下问题：
   请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。
### 代码
```cpp
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    //    2. call setup_kstack to allocate a kernel stack for child process
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if((proc=alloc_proc())==NULL){
        goto fork_out;
    }
    if(setup_kstack(proc)!=0){
        goto bad_fork_cleanup_proc;
    }
    if(copy_mm(clone_flags,proc)!=0){
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc,stack,tf);
    proc->pid=get_pid();
    hash_proc(proc);
    list_add(&proc_list,&(proc->list_link));
    nr_process++;
    wakeup_proc(proc);
    ret=proc->pid;
    goto fork_out;

fork_out:
    return ret;

bad_fork_cleanup_kstack://清理内核栈
    put_kstack(proc);
bad_fork_cleanup_proc://清理进程
    kfree(proc);
    goto fork_out;
}
```
### 回答
是。
在ucore中，进程的pid是通过 `get_pid()` 这个函数来分配的。
它使用了静态变量 `last_pid` 作为记录最后一个分配的pid的值，并且在每次调用时递增这个值。如果当前 `last_pid` 的值大于等于 `next_safe`，则会执行标签为 `inside` 的分支。在 `inside` 分支中，会重置 `next_safe` 为 `MAX_PID`，然后在 `repeat` 标签处进行遍历检查。

遍历 `proc_list` 中的每个进程，如果发现某个进程的pid与 `last_pid` 相等，则将 `last_pid` 递增。如果遇到 `proc->pid` 大于 `last_pid` 且小于 `next_safe` 的情况，则更新 `next_safe` 的值为这个较小的pid。最后，返回 `last_pid` 作为新的唯一pid。

这种机制保证了分配的pid是唯一的，并且它不仅依赖于一个单独的静态变量，还通过遍历已有进程的pid来保证新分配的pid不会与已有的进程pid冲突。



## 练习3：编写proc_run 函数（需要编码）

proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：

   检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
    禁用中断。你可以使用/kern/sync/sync.h中定义好的宏local_intr_save(x)和local_intr_restore(x)来实现关、开中断。
    切换当前进程为要运行的进程。
    切换页表，以便使用新进程的地址空间。/libs/riscv.h中提供了lcr3(unsigned int cr3)函数，可实现修改CR3寄存器值的功能。
    实现上下文切换。/kern/process中已经预先编写好了switch.S，其中定义了switch_to()函数。可实现两个进程的context切换。
    允许中断。

请回答如下问题：

   在本实验的执行过程中，创建且运行了几个内核线程？

完成代码编写后，编译并运行代码：make qemu

如果可以得到如 附录A所示的显示内容（仅供参考，不是标准答案输出），则基本正确。
### 代码
```cpp
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        // LAB4:EXERCISE3 YOUR CODE
        /*
        * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
        * MACROs or Functions:
        *   local_intr_save():        Disable interrupts
        *   local_intr_restore():     Enable Interrupts
        *   lcr3():                   Modify the value of CR3 register
        *   switch_to():              Context switching between two processes
        */
        local_intr_save(proc->flags);//禁用中断
        //切换当前进程为要运行的进程
        struct proc_struct *prev=current,*next=proc;
        current=proc;
        //切换页表
        lcr3(next->cr3);
        //切换上下文
        switch_to(&(prev->context),&(next->context));
        //启用中断
        local_intr_restore(proc->flags);
    }
}
```
### 回答
创建且运行了2个内核线程:idle和init

## 扩展练习 Challenge：

   说明语句local_intr_save(intr_flag);....local_intr_restore(intr_flag);是如何实现开关中断的？

***
 `local_intr_save` 宏用于保存当前中断状态， `local_intr_restore` 宏用于根据之前保存的状态恢复中断。

1. `local_intr_save(x)` 宏会调用 `__intr_save()` 函数来保存当前中断状态，并将结果存储在变量 `x` 中。
2. `local_intr_restore(x)` 宏会根据之前保存的中断状态变量 `x` 来恢复中断状态。如果之前的状态表示中断应该被打开，它会调用 `__intr_restore(true)` 来使能中断。

具体地，`__intr_save()` 函数检查当前 CPU 状态寄存器（`sstatus`）的 `SSTATUS_SIE` 标志位，如果中断被允许，则先禁止中断并返回 `true`；如果中断被禁止，则直接返回 `false`。这样就可以通过该函数获取当前中断是否被允许。

而 `__intr_restore()` 函数接收一个布尔值作为参数，如果参数为 `true`，则会调用 `intr_enable()` 函数来启用中断。

这种方式通过宏的方式包装了底层的中断控制函数，使得开关中断的操作更加方便，并提供了一种在局部范围内保存和恢复中断状态的机制。