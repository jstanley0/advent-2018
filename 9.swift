let args = CommandLine.arguments
let players = Int(args[1])!
let hi_marble = Int(args[2])!

var scores = Array(repeating: 0, count: players)
var circle = [0]
var marble = 1
var pos = 0
var player = 0

while marble <= hi_marble {
    if marble % 23 == 0 {
        scores[player] += marble
        pos -= 7
        if pos < 0 { pos += circle.count }
        scores[player] += circle.remove(at: pos)
    } else {
        pos = (pos + 2) % circle.count
        circle.insert(marble, at: pos)
    }
    player = (player + 1) % players
    marble += 1
}

print(scores)
print(scores.max()!)
