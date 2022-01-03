package main

import(
    "bufio"
    "os"
    "log"
    "fmt"
)

func count_neighbors(board []string, x, y int) (tree, lumber int) {
    for dx := -1; dx <= 1; dx++ {
        for dy := -1; dy <= 1; dy++ {
            xn, yn := x + dx, y + dy
            if xn == x && yn == y || xn < 0 || xn >= len(board[0]) || yn < 0 || yn >= len(board) {
                continue
            }
            switch board[yn][xn] {
            case '|':
                tree++
            case '#':
                lumber++
            }
        }
    }
    return
}

func iterate(board []string) []string {
    var new_board []string
    for y, row := range board {
        new_row := make([]rune, len(row))
        for x, c := range row {
            tree, lumber := count_neighbors(board, x, y)
            new_c := c

            switch(c) {
            case '.':
                if tree >= 3 {
                    new_c = '|'
                }
            case '|':
                if lumber >= 3 {
                    new_c = '#'
                }
            case '#':
                if lumber < 1 || tree < 1 {
                    new_c = '.'
                }
            }
            new_row[x] = new_c
        }
        new_board = append(new_board, string(new_row))
    }
    return new_board
}

func print_board(board []string) {
    for _, row := range board {
        fmt.Println(row)
    }
    fmt.Println()
}

func main() {
    if len(os.Args) < 2 {
        fmt.Println("no input file")
        return
    }

    file, err := os.Open(os.Args[1])
    if err != nil {
        log.Fatal(err)
    }
    defer file.Close()

    var board []string
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        board = append(board, scanner.Text())
    }

    for i := 0; i < 10; i++ {
        board = iterate(board)
        print_board(board)
    }

    wood := 0
    lumberyard := 0
    for _, row := range board {
        for _, c := range row {
            if c == '|' {
                wood++
            } else if c == '#' {
                lumberyard++
            }
        }
    }

    fmt.Println(wood, "*", lumberyard, "=", wood * lumberyard)
}
