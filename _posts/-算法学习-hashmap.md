# Hash表

## Hash函数设计要求

1. 散列函数得到的是一个非负整数（散列表源于对数组按下标访问的时候，时间复杂度是O(1)，Hash(key)即数组索引）；

2. 如果 key1 == key2 ，那么Hash(key1) == Hash(key2)；

3. 如果 key1 != key2 ，那么Hash(key1) != Hash(key2)，即好的Hash函数应该没有散列冲突，但是由于空间的限制，实际设计中，很难达到。

## 散列冲突

- 开放寻址法：线性探测法、二次探测、双重散列
  - 线性探测法，即在hash(key)时，如果发生散列冲突，则依次探测下一个空位置，返回位置索引。需要注意，在删除元素时，不能直接删除，而是要通过一个状态字段，标记为delete。
  - 二次探测，将线性探测的步长增加为二次方，即hash(key) + 0^2，hash(key) + 1^2，hash(key) + 2^2...
  - 双重散列，即用多个hash函数，直到找到一个空位置。
- 链表法

散列表使用装载因子来表示散列冲突的情况，装载因子越大，说明发生散列冲突的概率越大，需要扩桶或者扩容。

**当数据量比较小，并且装载因子较小的时候，比较适合采用开发寻址法。优点是，可以利用CPU缓存进行加速，由于没有链表，不涉及指针，序列化和反序列化比较简单。缺点是，冲突代价高，因此装载因子不能太大。**

**链表法比较适合存储大对象，大数据量的散列表。链表法对装载因子容忍度较高，但是由于链表不连续，对CPU缓存不是很友好。**

# golang map的实现探究

## map的内存分配（初始化）

```
	m := make(map[int]string, 1)
	m[1] = "1"
```

其中，赋值语句对应的汇编为：

```
	0x0101 00257 (main.go:14)	PCDATA	$0, $1
	0x0101 00257 (main.go:14)	LEAQ	type.map[int]string(SB), AX
	0x0108 00264 (main.go:14)	PCDATA	$0, $0
	0x0108 00264 (main.go:14)	MOVQ	AX, (SP)
	0x010c 00268 (main.go:14)	PCDATA	$0, $1
	0x010c 00268 (main.go:14)	MOVQ	"".m+80(SP), AX
	0x0111 00273 (main.go:14)	PCDATA	$0, $0
	0x0111 00273 (main.go:14)	MOVQ	AX, 8(SP)
	0x0116 00278 (main.go:14)	MOVQ	$1, 16(SP)
	0x011f 00287 (main.go:14)	CALL	runtime.mapassign_fast64(SB)
	0x0124 00292 (main.go:14)	PCDATA	$0, $2
	0x0124 00292 (main.go:14)	MOVQ	24(SP), DI
	0x0129 00297 (main.go:14)	MOVQ	DI, ""..autotmp_10+136(SP)
	0x0131 00305 (main.go:14)	TESTB	AL, (DI)
	0x0133 00307 (main.go:14)	MOVQ	$1, 8(DI)
	0x013b 00315 (main.go:14)	PCDATA	$0, $-2
	0x013b 00315 (main.go:14)	PCDATA	$1, $-2
	0x013b 00315 (main.go:14)	CMPL	runtime.writeBarrier(SB), $0
	0x0142 00322 (main.go:14)	JEQ	329
	0x0144 00324 (main.go:14)	JMP	806
	0x0149 00329 (main.go:14)	LEAQ	go.string."1"(SB), AX
	0x0150 00336 (main.go:14)	MOVQ	AX, (DI)
	0x0153 00339 (main.go:14)	JMP	341
```

可以看出，赋值操作是通过runtime.mapassign_fast64来实现的，函数原型如下：

```
func mapassign_fast64(t *maptype, h *hmap, key uint64) unsafe.Pointer
```

分析这个函数，可以得出如下结论：

- go中map是通过一组bucket来存储key/value对的，先存储所有key，再存储所有element，key1/key2/key3/.../elm1/elm2/elm3/...
- 采用线性探测法来解决散列冲突
- ...



