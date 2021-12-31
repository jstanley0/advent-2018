LPAD = 10
PAD = 300
GENERATIONS = 200

import sys

state = '.' * LPAD + sys.stdin.readline().strip().replace("initial state: ", "") + '.' * PAD
sys.stdin.readline()

rules = [line.strip().split(" => ") for line in sys.stdin.readlines()]
rules = {rule[0] : rule[1] for rule in rules}
last_sum = 0

for g in range(GENERATIONS):
    ng = ['.'] * len(state)
    for i in range(len(state) - 5):
        s = state[i : i + 5]
        if s in rules:
            ng[i + 2] = rules[s]
    state = "".join(ng)

    sum = 0
    for i in range(len(state)):
        if state[i] == '#':
            sum += i - LPAD

    print(f"{g + 1}: {sum} {sum - last_sum}")
    last_sum = sum
