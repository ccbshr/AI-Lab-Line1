x = int(input())
while x != 1:
    if x % 2 == 1:
        print(f"{x}*3+1={x*3+1}")
        x = x*3+1
    else:
        print(f"{x}/2={x//2}")
        x = x // 2
print("End")