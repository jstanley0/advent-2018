struct Group {
    var team = -1
    var unit_count = 0
    var unit_hp = 0
    var unit_attack = 0
    var initiative = 0
    var attack_type: String = ""
    var weak_to: [String] = []
    var immune_to: [String] = []

    func effective_power() -> Int {
        return self.unit_count * self.unit_attack
    }

    func damage_dealt(to defender: inout Group) -> Int {
        if defender.immune_to.contains(self.attack_type) {
            return 0
        }
        var damage = effective_power()
        if defender.weak_to.contains(self.attack_type) {
            damage *= 2
        }
        return damage
    }

    func attack(_ defender: inout Group) {
        let damage = self.damage_dealt(to: &defender)
        let units_killed = damage / defender.unit_hp;
        defender.unit_count -= units_killed
        if defender.unit_count < 0 {
            defender.unit_count = 0
        }
    }
}

func extractNumber(_ tokens: inout [String.SubSequence]) -> Int {
    while !tokens.isEmpty {
        let token = tokens.removeFirst()
        if let num = Int(token) {
            return num
        }
    }
    return -1
}

// how is this not built in??
// also why won't Swift let me split on e.g. ", "? that'd really make life easier
func strip(_ substr : String.SubSequence) -> String.SubSequence {
    return substr.drop(while: { $0 == " " })
}

// e.g. "35 units each with 3755 hit points (weak to cold; immune to fire, bludgeoning) with an attack that does 1021 bludgeoning damage at initiative 1"
// the parenthetical is optional
func parseGroup(_ _line: String, team: Int, boost: Int = 0) -> Group {
    var group = Group()
    group.team = team

    var line = _line
    if let openParen = line.firstIndex(of: "(") {
        let closeParen = line.firstIndex(of: ")")!
        let substr = line[openParen..<closeParen].dropFirst(1)
        let clauses = substr.split(separator: ";").map { strip($0) }
        for clause in clauses {
            let parts = clause.split(separator: " ", maxSplits: 2)
            if parts[1] != "to" {
                fatalError("expected 'to'")
            }
            let stuff = parts[2].split(separator: ",").map { strip($0) }
            switch parts[0] {
            case "weak":
                group.weak_to = stuff.map { String($0) }
            case "immune":
                group.immune_to = stuff.map { String($0) }
            default:
                fatalError("expected 'weak' or 'immune'")
            }
        }
        line.removeSubrange(openParen...closeParen)
    }

    var tokens = line.split(separator: " ")
    group.unit_count = extractNumber(&tokens)
    group.unit_hp = extractNumber(&tokens)
    group.unit_attack = extractNumber(&tokens) + boost
    group.attack_type = String(tokens.removeFirst())
    group.initiative = extractNumber(&tokens)

    return group
}

let boost = CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1]) ?? 0 : 0

var groups: [Group] = []
if readLine()! != "Immune System:" {
    fatalError("immune system units not found")
}
while let line = readLine() {
    if line.isEmpty {
        break
    }
    groups.append(parseGroup(line, team: 0, boost: boost))
}

if readLine()! != "Infection:" {
    fatalError("infection units not found")
}
while let line = readLine() {
    if line.isEmpty {
        break
    }
    groups.append(parseGroup(line, team: 1))
}

func fighting(_ groups: inout [Group]) -> Bool {
    var alive = [false, false]
    for group in groups {
        if group.unit_count > 0 {
            alive[group.team] = true
        }
    }
    if !alive[0] {
        print("the reindeer died. :(")
    } else if !alive[1] {
        print("the reindeer recovered! \\o/")
    }
    return alive[0] && alive[1]
}

while fighting(&groups) {
    // sort groups in descending order by effective power and then initiative
    groups.sort(by: { $0.effective_power() > $1.effective_power() ||
                      $0.effective_power() == $1.effective_power() && $0.initiative > $1.initiative })

    // attack_plan[attacker_index] = defender_index, or -1 if none
    var attack_plan = Array(repeating: -1, count: groups.count)
    for ai in 0..<groups.count {
        if groups[ai].unit_count == 0 {
            break   // at this point all remaining groups are dead
        }
        var targets: [[Int]] = []
        for di in 0..<groups.count {
            if groups[di].team == groups[ai].team || groups[di].unit_count == 0 || attack_plan.contains(di) {
                continue
            }
            let damage = groups[ai].damage_dealt(to: &groups[di])
            if damage > 0 {
                targets.append([damage, groups[di].effective_power(), groups[di].initiative, di])
            }
        }
        if targets.isEmpty {
            continue
        }
        // I am very sad that Swift can't compare arrays.
        targets.sort(by: {
            for i in 0..<$0.count {
                if $0[i] != $1[i] {
                    return $0[i] > $1[i]
                }
            }
            fatalError("unique defender constraint violated")
        })
        attack_plan[ai] = targets[0][3]
    }

    var initiative: [[Int]] = []
    for ai in 0..<groups.count {
        if attack_plan[ai] != -1 {
            initiative.append([groups[ai].initiative, ai])
        }
    }
    initiative.sort(by: { $0[0] > $1[0] })

    for ii in initiative {
        let ai = ii[1]
        let di = attack_plan[ai]
        if (di < 0) {
            fatalError("how did that happen")
        }
        groups[ai].attack(&groups[di])
    }
}

print(groups.map { $0.unit_count }.reduce(0, +))
