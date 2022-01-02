from dataclasses import dataclass
import fileinput
import re

def addr(args, regs):
    regs[args[2]] = regs[args[0]] + regs[args[1]]

def addi(args, regs):
    regs[args[2]] = regs[args[0]] + args[1]

def mulr(args, regs):
    regs[args[2]] = regs[args[0]] * regs[args[1]]

def muli(args, regs):
    regs[args[2]] = regs[args[0]] * args[1]

def banr(args, regs):
    regs[args[2]] = regs[args[0]] & regs[args[1]]

def bani(args, regs):
    regs[args[2]] = regs[args[0]] & args[1]

def borr(args, regs):
    regs[args[2]] = regs[args[0]] | regs[args[1]]

def bori(args, regs):
    regs[args[2]] = regs[args[0]] | args[1]

def setr(args, regs):
    regs[args[2]] = regs[args[0]]

def seti(args, regs):
    regs[args[2]] = args[0]

def gtir(args, regs):
    regs[args[2]] = 1 if args[0] > regs[args[1]] else 0

def gtri(args, regs):
    regs[args[2]] = 1 if regs[args[0]] > args[1] else 0

def gtrr(args, regs):
    regs[args[2]] = 1 if regs[args[0]] > regs[args[1]] else 0

def eqir(args, regs):
    regs[args[2]] = 1 if args[0] == regs[args[1]] else 0

def eqri(args, regs):
    regs[args[2]] = 1 if regs[args[0]] == args[1] else 0

def eqrr(args, regs):
    regs[args[2]] = 1 if regs[args[0]] == regs[args[1]] else 0

operations = [addr, addi, mulr, muli, banr, bani, borr, bori, setr, seti, gtir, gtri, gtrr, eqir, eqri, eqrr]

@dataclass
class Sample:
    before: list[int]
    inst: list[int]
    after: list[int]

# example text:
# Before: [2, 3, 1, 0]
# 13 2 3 3
# After:  [2, 3, 1, 3]
def read_sample(f):
    bm = re.match(r"Before: \[(\d+), (\d+), (\d+), (\d+)\]", f.readline())
    if bm is None:
        return None
    im = re.match(r"(\d+) (\d+) (\d+) (\d+)", f.readline())
    am = re.match(r"After:  \[(\d+), (\d+), (\d+), (\d+)\]", f.readline())
    f.readline()
    return Sample([int(val) for val in bm.groups()],
                  [int(val) for val in im.groups()],
                  [int(val) for val in am.groups()])

samples = []
program = []
with fileinput.input() as f:
    while True:
        sample = read_sample(f)
        if sample is None:
            break
        samples.append(sample)

    while True:
        line = f.readline()
        if len(line) == 0:
            break
        nums = line.split(" ")
        if len(nums) == 4:
            nums = [int(num) for num in nums]
            program.append(nums)

# part 1
matched_samples = 0
for sample in samples:
    matched_opcodes = 0
    for operation in operations:
        regs = sample.before.copy()
        operation(sample.inst[1:], regs)
        if regs == sample.after:
            matched_opcodes += 1
    if matched_opcodes >= 3:
        matched_samples += 1

print(f"{matched_samples} / {len(samples)}")

# part 2
def opcode_operation_matches_samples(opcode, operation, samples):
    for sample in samples:
        if sample.inst[0] == opcode:
            regs = sample.before.copy()
            operation(sample.inst[1:], regs)
            if regs != sample.after:
                return False
    return True


possible_opcodes = [[opcode for opcode in range(16) if opcode_operation_matches_samples(opcode, operation, samples)] for operation in operations]

deduced_opcodes = set()
while any([len(po) > 1 for po in possible_opcodes]):
    for i in range(16):
        if len(possible_opcodes[i]) == 1 and possible_opcodes[i][0] not in deduced_opcodes:
            deduced_opcode = possible_opcodes[i][0]
            deduced_opcodes.add(deduced_opcode)
            for j in range(16):
                if j != i and deduced_opcode in possible_opcodes[j]:
                    possible_opcodes[j].remove(deduced_opcode)

opcode_map = [0] * 16
for i in range(16):
    opcode_map[possible_opcodes[i][0]] = i

operations = [operations[opcode_map[i]] for i in range(16)]

regs = [0] * 4
for inst in program:
    operations[inst[0]](inst[1:], regs)

print(regs)
