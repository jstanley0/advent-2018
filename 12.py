PAD = 30
GENERATIONS = 20

import sys

state = '.' * PAD + sys.stdin.readline().strip().replace("initial state: ", "") + '.' * PAD
sys.stdin.readline()

rules = [line.strip().split(" => ") for line in sys.stdin.readlines()]
rules = {rule[0] : rule[1] for rule in rules}

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
            sum += i - PAD

    print(f"{g + 1}: {sum}")
