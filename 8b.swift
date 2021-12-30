var data = readLine()!.split(separator: " ").map { Int($0)! }

func readNode(data: inout [Int]) -> Int {
    let childNodes = data.remove(at: 0)
    let metaCount = data.remove(at: 0)

    var childValues : [Int] = []
    for _ in 0..<childNodes {
        childValues.append(readNode(data: &data))
    }
    var sum = 0
    for _ in 0..<metaCount {
        let meta = data.remove(at: 0)
        if childValues.isEmpty {
            sum += meta;
        } else if meta > 0 && meta <= childValues.count {
            sum += childValues[meta - 1]
        }
    }
    return sum
}

print(readNode(data: &data))
