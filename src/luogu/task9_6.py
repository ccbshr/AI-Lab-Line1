n = int(input())
x = 1
s = 0
for i in range(1,n+1):
    x *= i
    i += 1
    s += x
print(s)