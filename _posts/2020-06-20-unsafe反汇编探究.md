







# asm中的伪寄存器

| register | function                                                     |
| -------- | ------------------------------------------------------------ |
| SB       | 静态基址指针（Static base pointer），内存起始地址：foo(SB)，foo的内存地址；foo<>(SB)，私有元素；foo + 8(SB)，foo之后8个字节处的地址 |
| FP       | 帧指针（Frame Pointer），用来传递函数参数，0(FP)是第一个参数，8(FP)是第二个参数 |
| PC       | 程序计数器（Program Counter）                                |
| SP       | 栈指针（Stack Pointer）                                      |



# LEAQ v.s. MOVQ

![LEAQ和MOVQ的区别](./leaq_vs_movq.jpg)

leaq 是直接赋值运算，movq是取地址中的值，即

- lea eax,[eax+2*eax]的效果是eax = eax + eax * 2

- mov edx [ebp+16]的效果是edx=*(dword* *)(ebp+16)



# 代码分析

```go
import (
	"fmt"
	"unsafe"
)

func main(){
	f := 10
	niPointer := (*float64)(unsafe.Pointer(&f))
	*niPointer = 0.01

	fmt.Printf("ptr:%v, value:%v", niPointer, *niPointer)
}
```

将这段代码进行编译，编译成golang的asm：

```
go tool compile -S -N -l main.go > main.asm // -N -l，禁止内联，禁止优化
```

为了探索unsafe.Pointer的实现，对以上代码的中的关键语句，结合汇编进行分析。

## golang中的内存分配

```
	f := 10 // main.go:9, 上面代码源码第9行
```

对应的汇编代码如下：

```asm
	
	0x0036 00054 (main.go:9)	PCDATA	$0, $1
	0x0036 00054 (main.go:9)	PCDATA	$1, $0
	0x0036 00054 (main.go:9)	LEAQ	type.int(SB), AX
	0x003d 00061 (main.go:9)	PCDATA	$0, $0
	0x003d 00061 (main.go:9)	MOVQ	AX, (SP)
	0x0041 00065 (main.go:9)	CALL	runtime.newobject(SB) // golang 根据type分配空间		0x0046 00070 (main.go:9)	PCDATA	$0, $1
	0x0046 00070 (main.go:9)	MOVQ	8(SP), AX // newobject所分配空间的的指针存于AX
	0x004b 00075 (main.go:9)	PCDATA	$1, $1
	0x004b 00075 (main.go:9)	MOVQ	AX, "".&f+104(SP) // 将AX中的值存放在[SP + 104],即&f
	0x0050 00080 (main.go:9)	PCDATA	$0, $0
	0x0050 00080 (main.go:9)	MOVQ	$10, (AX) // 向AX指向的地址赋值10
```

runtime.newobject()原型为：func newobject(typ *_type) unsafe.Pointer，根据type的类型，返回一个指向对应空间的指针，可能的实现为:

[原文链接]: https://andrestc.com/post/go-memory-allocation-pt1/

```
func newobject(typ *_type) unsafe.Pointer {
	return mallocgc(typ.size, typ, true)
}
```

## 指针转换

```
niPointer := (*float64)(unsafe.Pointer(&f)) // main.go:10
```

这个赋值语句理解很简单，niPointer是个栈空间变量，地址位于SP + 72， 这里通过两条赋值语句，先将&f的值赋予AX，再将AX的值赋予niPointer

```
    0x0057 00087 (main.go:10)	PCDATA	$0, $1
	0x0057 00087 (main.go:10)	PCDATA	$1, $0
	0x0057 00087 (main.go:10)	MOVQ	"".&f+104(SP), AX
	0x005c 00092 (main.go:10)	PCDATA	$1, $2
	0x005c 00092 (main.go:10)	MOVQ	AX, "".niPointer+72(SP) 
```

## 指针赋值

```
*niPointer = 0.01 // main.go:11
```

AL表示AX的低8位，AH表示AX的高8位，这里使用TEST Byte是为了修改标志位（ZF，SF），不去深究。

```
	0x0061 00097 (main.go:11)	TESTB	AL, (AX)
	0x0063 00099 (main.go:11)	MOVSD	$f64.3f847ae147ae147b(SB), X0
	0x006b 00107 (main.go:11)	PCDATA	$0, $0
	0x006b 00107 (main.go:11)	MOVSD	X0, (AX)
```

## 结论

从以上分析中可以看出，unsafe中的指针操作只是针对于golang编译器，突破编译器的一些安全检查和限制，对于底层实现来说，没有任何奇特的地方。

# 可以继续深究的问题

1. PCDATA在垃圾回收当中的作用及原理