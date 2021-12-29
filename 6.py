import sys

coords = []
with open(sys.argv[1], 'r') as file:
    for line in file:
        coords.append([int(i) for i in line.split(",")])

offset = max([i for pair in coords for i in pair])
size = offset * 3
matrix = [[(-1, 0)] * size for i in range(size)]

coords = [(coord[0] + offset, coord[1] + offset) for coord in coords]

for i in range(len(coords)):
    for y in range(len(matrix)):
        for x in range(len(matrix[y])):
            my_dist = abs(coords[i][0] - x) + abs(coords[i][1] - y)
            ci, dist = matrix[y][x]
            if ci == -1 or my_dist < dist:
                matrix[y][x] = (i, my_dist)
            elif my_dist == dist:
                matrix[y][x] = (-2, my_dist)

counts = {}
for row in matrix:
    for cell in row:
        ci, _dist = cell
        if ci not in counts:
            counts[ci] = 0
        counts[ci] += 1

for i in range(len(matrix)):
    for ci in [matrix[i][0][0], matrix[0][i][0], matrix[i][-1][0], matrix[-1][i][0]]:
        if ci in counts:
            counts.pop(ci)

print(counts)
print(max(counts.values()))

