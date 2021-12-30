import fileinput
import re

all_steps = set()
deps = {}
input_re = re.compile(r"Step ([A-Z]+) must be finished before step ([A-Z]+) can begin\.")
for line in fileinput.input():
    match = input_re.match(line)
    if match is not None:
        all_steps.add(match.group(1))
        all_steps.add(match.group(2))
        if match.group(2) not in deps:
            deps[match.group(2)] = []
        deps[match.group(2)].append(match.group(1))

all_steps = list(all_steps)
all_steps.sort()

completed = []
while len(completed) < len(all_steps):
    for step in all_steps:
        if step not in completed:
            if step not in deps or all([d in completed for d in deps[step]]):
                completed.append(step)
                break

print("".join(completed))

