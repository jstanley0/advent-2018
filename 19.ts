const fs = require('fs');

interface Instruction {
    opcode: string;
    args: Array<number>;
}
type Program = Array<Instruction>;

function runProgram(program: Program, r0: number, ip_reg: number) {
    let regs = [r0, 0, 0, 0, 0, 0];
    let ip = 0;
    let n = 0;

    while(ip >= 0 && ip < program.length) {
        n += 1;
        if (ip_reg >= 0) {
            regs[ip_reg] = ip;
        }
        const inst = program[ip];

        switch(inst.opcode) {
        case 'addr':
            regs[inst.args[2]] = regs[inst.args[0]] + regs[inst.args[1]];
            break;
        case 'addi':
            regs[inst.args[2]] = regs[inst.args[0]] + inst.args[1];
            break;
        case 'mulr':
            regs[inst.args[2]] = regs[inst.args[0]] * regs[inst.args[1]];
            break;
        case 'muli':
            regs[inst.args[2]] = regs[inst.args[0]] * inst.args[1];
            break;
        case 'banr':
            regs[inst.args[2]] = regs[inst.args[0]] & regs[inst.args[1]];
            break;
        case 'bani':
            regs[inst.args[2]] = regs[inst.args[0]] & inst.args[1];
            break;
        case 'borr':
            regs[inst.args[2]] = regs[inst.args[0]] | regs[inst.args[1]];
            break;
        case 'bori':
            regs[inst.args[2]] = regs[inst.args[0]] | inst.args[1];
            break;
        case 'setr':
            regs[inst.args[2]] = regs[inst.args[0]];
            break;
        case 'seti':
            regs[inst.args[2]] = inst.args[0];
            break;
        case 'gtir':
            regs[inst.args[2]] = (inst.args[0] > regs[inst.args[1]]) ? 1 : 0;
            break;
        case 'gtri':
            regs[inst.args[2]] = (regs[inst.args[0]] > inst.args[1]) ? 1 : 0;
            break;
        case 'gtrr':
            regs[inst.args[2]] = (regs[inst.args[0]] > regs[inst.args[1]]) ? 1 : 0;
            break;
        case 'eqir':
            regs[inst.args[2]] = (inst.args[0] === regs[inst.args[1]]) ? 1 : 0;
            break;
        case 'eqri':
            regs[inst.args[2]] = (regs[inst.args[0]] === inst.args[1]) ? 1 : 0;
            break;
        case 'eqrr':
            regs[inst.args[2]] = (regs[inst.args[0]] === regs[inst.args[1]]) ? 1 : 0;
            break;
        }
        if (ip_reg >= 0) {
            ip = regs[ip_reg];
        }
        //console.log(inst, regs);
        ip++;
    }
    console.log(n, regs);
}

let program: Program = fs.readFileSync(process.argv[2], 'ascii')
    .split("\n")
    .filter(line => line.length > 0)
    .map(line => {
        let parts = line.split(" ");
        const opcode = parts.shift();
        return { opcode: opcode, args: parts.map(arg => parseInt(arg, 10)) }
    });

let ip_reg;
if (program[0].opcode == '#ip') {
    ip_reg = program.shift().args[0];
}
runProgram(program, parseInt(process.argv[3], 10), ip_reg);
