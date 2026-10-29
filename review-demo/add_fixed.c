/* 已修正版本：纯 C 语言，编译命令 gcc add_fixed.c -o add_fixed */
#include <stdio.h>

int add(int a, int b)
{
	return a + b;
}

int main(void)
{
	int result = add(2, 3);
	printf("%d\n", result);
	return 0;
}
