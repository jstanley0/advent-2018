let args = CommandLine.arguments
let count = Int(args[1])!

var recipes = [3, 7]
var elves = [0, 1]

while recipes.count < count + 10 {
    let s = elves.map { recipes[$0] }.reduce(0, +)
    for n in Array(String(s)) {
        recipes.append(Int(String(n))!)
    }
    for i in 0..<elves.count {
        elves[i] += recipes[elves[i]] + 1
        elves[i] %= recipes.count
    }
}

print(recipes[recipes.count-10..<recipes.count].map{String($0)}.joined())
