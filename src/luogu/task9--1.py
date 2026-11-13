hight__apple = list(map(int, input().split()))
hight = int(input())
hight2 = hight + 30
x = 0
for apple in hight__apple:
    if apple <= hight:
        x += 1
    elif apple <= hight2:
        x += 1
print(x)


