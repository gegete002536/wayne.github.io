# 字符串比较算法

主串长度为n，模式串长度为m，算法归纳如下：

- BF（Brute Force），暴力匹配算法，时间复杂度O(n*m)

- RK（Rabin-Karp），对于包含K种字符的串，使用K进制进行hash表示，通过对比子串和模式串的hash值，快速匹配。时间复杂度O(n)
- BM（Boyer-Moore）
- KMP
- Sundy算法
- Tire树，字典树
- AC自动机