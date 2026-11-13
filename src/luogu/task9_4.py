n,x=map(int,input().split())
sum1 = 0
for i in range(1,n+1):
    sum1 += str(i).count(str(x))
print(sum1)