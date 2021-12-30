var data = readLine()!.split(separator: " ").map { Int($0)! }

func readNode(data: inout [Int]) -> Int {
    let childNodes = data.remove(at: 0)
    let metaCount = data.remove(at: 0)

    var sum = 0
    for _ in 0..<childNodes {
        sum += readNode(data: &data)
    }
    for _ in 0..<metaCount {
        sum += data.remove(at: 0)
    }
    return sum
}

print(readNode(data: &data))
