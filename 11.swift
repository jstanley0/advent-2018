class CellGrid {
    var data = Array<Int>(repeating: 0, count: 300 * 300)

    init(serial_number: Int) {
        for x in 1...300 {
            for y in 1...300 {
                data[cell_address(x, y)] = calculate_energy(x, y, serial_number: serial_number)
            }
        }
    }

    func energy(_ x : Int, _ y : Int) -> Int {
        data[cell_address(x, y)]
    }

    func calculate_energy(_ x : Int, _ y : Int, serial_number : Int) -> Int {
        let rack_id = x + 10
        var power_level = rack_id * y
        power_level += serial_number
        power_level *= rack_id
        return (power_level / 100) % 10 - 5
    }

    func cell_address(_ x : Int, _ y : Int) -> Int {
        assert((1...300).contains(x))
        assert((1...300).contains(y))
        return (y - 1) * 300 + (x - 1)
    }
}

let args = CommandLine.arguments
let serial_number = Int(args[1])!

var grid = CellGrid(serial_number: serial_number)
var max_cell = (-999, 0, 0, 0)

for square in 1...300 {
    for x in 1...(300 - square + 1) {
        for y in 1...(300 - square + 1) {
            var sum = 0
            for a in 0..<square {
                for b in 0..<square {
                    sum += grid.energy(x + a, y + b)
                }
            }
            if sum > max_cell.0 {
                max_cell = (sum, x, y, square)
            }
        }
    }
    print(square)
}

print(max_cell)
