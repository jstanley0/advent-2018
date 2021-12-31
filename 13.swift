let DIR : [Character] = ["^", ">", "v", "<"]
let TRACK : [Character] = ["|", "-", "|", "-"]
let SLASH_TURN = [1, -1, 1, -1]
let BACKSLASH_TURN = [-1, 1, -1, 1]
let DX = [0, 1, 0, -1]
let DY = [-1, 0, 1, 0]

class Cart {
    var x = 0
    var y = 0
    var dir = 0
    var turn = -1

    init(x : Int, y : Int, dir : Int) {
        self.x = x
        self.y = y
        self.dir = dir
    }
}

var maze : [[Character]] = []
while let line = readLine() {
    maze.append(Array(line))
}

var carts : [Cart] = []
for (y, row) in maze.enumerated() {
    for (x, c) in row.enumerated() {
        if let d = DIR.firstIndex(of: c) {
            maze[y][x] = TRACK[d]
            carts.append(Cart(x: x, y: y, dir: d))
        }
    }
}

func print_maze(maze : [[Character]], carts : [Cart]) {
    var maze_copy = maze
    for cart in carts {
        print("\(cart.x) \(cart.y) \(cart.dir)")
        maze_copy[cart.y][cart.x] = DIR[cart.dir]
    }

    for row in maze_copy {
        for c in row {
            print(c, terminator: "")
        }
        print("")
    }
}

var t = 0
while carts.count > 1 {
    // carts move ordered by current position
    carts.sort(by: {(l, r) -> Bool in l.y < r.y || l.y == r.y && l.x < r.x})

    //print_maze(maze: maze, carts: carts)
    var crashed_carts : [Int] = []
    for (i, cart) in carts.enumerated() {
        switch maze[cart.y][cart.x] {
        case "+":
            cart.dir += cart.turn
            cart.turn += 1
            if cart.turn > 1 {
                cart.turn = -1
            }
        case "/":
            cart.dir += SLASH_TURN[cart.dir]
        case "\\":
            cart.dir += BACKSLASH_TURN[cart.dir]
        default:
            // I like Swift but "switch must be exhaustive" is dumb and "default must contain statement" is also dumb
            break
        }

        if cart.dir < 0 {
            cart.dir += 4
        } else if cart.dir >= 4 {
            cart.dir -= 4
        }

        cart.x += DX[cart.dir]
        cart.y += DY[cart.dir]
        for (j, othercart) in carts.enumerated() {
            if j != i && cart.x == othercart.x && cart.y == othercart.y {
                print("crash at \(cart.x),\(cart.y) on t=\(t)")
                crashed_carts.append(i)
                crashed_carts.append(j)
            }
        }
    }

    crashed_carts.sort(by: >)
    for index in crashed_carts { carts.remove(at: index) }

    t += 1
}

print("remaining cart at \(carts[0].x),\(carts[0].y)")
