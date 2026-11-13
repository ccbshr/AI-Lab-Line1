distance = int(input())
t_bike1 = 23
t_bike2 = 27
t_walk = distance/1.2
t_bike = distance/3 + t_bike1 + t_bike2
if t_bike < t_walk:
    print("Bike")
elif t_bike > t_walk:
    print("Walk")
else:
    print("All")