x,y,z, = map(int,input().split())
g = min(x,y,z)
while x % g !=0 or y % g !=0 or z % g != 0 :
    g -= 1
print(g)



