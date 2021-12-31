func splitNumber(_ num : Int) -> [Int] {
    Array(String(num)).map { Int(String($0))! }
}

let target = splitNumber(Int(CommandLine.arguments[1])!)[0...]

var recipes = [3, 7]
var elves = [0, 1]

var done = false
while !done {
    let s = elves.map { recipes[$0] }.reduce(0, +)
    for n in splitNumber(s) {
        recipes.append(n)
        //print(recipes)
        if recipes.count > target.count && recipes[(recipes.count - target.count)...] == target {
            done = true
            break
        }
    }
    for i in 0..<elves.count {
        elves[i] += recipes[elves[i]] + 1
        elves[i] %= recipes.count
    }
}

//print(recipes.map{String($0)}.joined())
print(recipes.count - target.count)
