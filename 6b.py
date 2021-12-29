import sys

coords = []
with open(sys.argv[1], 'r') as file:
    for line in file:
        coords.append([int(i) for i in line.split(",")])

offset = max([i for pair in coords for i in pair])
size = offset * 3
matrix = [[(-1, 0)] * size for i in range(size)]

coords = [(coord[0] + offset, coord[1] + offset) for coord in coords]

regions = 0
for y in range(len(matrix)):
    for x in range(len(matrix[y])):
        dist = sum([abs(coord[0] - x) + abs(coord[1] - y) for coord in coords])
        if dist < 10000:
            regions += 1

print(regions)
