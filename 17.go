package main

import(
    "bufio"
    "os"
    "log"
    "fmt"
    "regexp"
    "strconv"
    "image"
    "image/color"
    "image/draw"
    "image/png"
)

type HLine struct {
    y int
    x0 int
    x1 int
}

type VLine struct {
    x int
    y0 int
    y1 int
}

var SAND color.Color = color.RGBA{255, 255, 192, 255}
var CLAY color.Color = color.RGBA{128,  96,  48, 255}
var SAND_WATER color.Color = color.RGBA{64, 128, 255, 255}
var WATER color.Color = color.RGBA{32, 48, 255, 255}

func pour(img *image.RGBA, x, y int) {
    var c color.Color
    for y < img.Bounds().Max.Y {
        c = img.At(x, y)
        if c != SAND {
            break
        }
        img.Set(x, y, SAND_WATER)
        y++
    }
    if y == img.Bounds().Max.Y {
        return  // off the bottom edge
    }

    if c == CLAY || c == WATER {
        y--
        fill_reservoir(img, x, y)
    }
}

// run left from the given point, returning inner X coordinate if a wall is hit,
// or pouring down a hole otherwise
func run_left(img *image.RGBA, x, y int) int {
    var c, b color.Color
    for x >= img.Bounds().Min.X {
        c = img.At(x, y)
        b = img.At(x, y + 1)
        if b != CLAY && b != WATER {
            pour(img, x, y)
            return -1
        }
        if c != SAND && c != SAND_WATER {
            break
        }
        img.Set(x, y, SAND_WATER)
        x--
    }
    return x + 1
}

func run_right(img *image.RGBA, x, y int) int {
    var c, b color.Color
    for x < img.Bounds().Max.X {
        c = img.At(x, y)
        b = img.At(x, y + 1)
        if b != CLAY && b != WATER {
            pour(img, x, y)
            return -1
        }
        if c != SAND && c != SAND_WATER {
            break
        }
        img.Set(x, y, SAND_WATER)
        x++
    }
    return x - 1
}

func fill_reservoir(img *image.RGBA, x, y int) {
    for y > 0 {
        left_edge := run_left(img, x, y)
        right_edge := run_right(img, x, y)
        if left_edge == -1 || right_edge == -1 {
            break
        }
        draw.Draw(img, image.Rectangle{image.Point{left_edge, y}, image.Point{right_edge + 1, y + 1}}, &image.Uniform{WATER}, image.ZP, draw.Src)
        y--
    }
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

    var hlines []HLine
    var vlines []VLine

    h_regex := regexp.MustCompile(`y=(\d+), x=(\d+)..(\d+)`)
    v_regex := regexp.MustCompile(`x=(\d+), y=(\d+)..(\d+)`)

    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        if h_match := h_regex.FindStringSubmatch(scanner.Text()); len(h_match) == 4 {
            y, _ := strconv.Atoi(h_match[1])
            x0, _ := strconv.Atoi(h_match[2])
            x1, _ := strconv.Atoi(h_match[3])
            hlines = append(hlines, HLine{y, x0, x1})
        } else if v_match := v_regex.FindStringSubmatch(scanner.Text()); len(v_match) == 4 {
            x, _ := strconv.Atoi(v_match[1])
            y0, _ := strconv.Atoi(v_match[2])
            y1, _ := strconv.Atoi(v_match[3])
            vlines = append(vlines, VLine{x, y0, y1})
        }
    }

    TL := image.Point{500, 5}
    BR := image.Point{500, 5}

    for _, hline := range hlines {
        if hline.y < TL.Y {
            TL.Y = hline.y
        } else if hline.y > BR.Y {
            BR.Y = hline.y
        }
        if hline.x0 < TL.X {
            TL.X = hline.x0
        }
        if hline.x1 > BR.X {
            BR.X = hline.x1
        }
    }

    for _, vline := range vlines {
        if vline.x < TL.X {
            TL.X = vline.x
        } else if vline.x > BR.X {
            BR.X = vline.x
        }
        if vline.y0 < TL.Y {
            TL.Y = vline.y0
        }
        if vline.y1 > BR.Y {
            BR.Y = vline.y1
        }
    }

    // because water can flow off to the sides, and because these rectangle ranges are half-open :P
    TL.X -= 1
    BR.X += 2
    BR.Y += 1

    fmt.Println("Coordinate range:", TL, "to", BR)

    img := image.NewRGBA(image.Rectangle{TL, BR})
    draw.Draw(img, img.Bounds(), &image.Uniform{SAND}, image.ZP, draw.Src)
    for _, hline := range hlines {
        draw.Draw(img, image.Rectangle{image.Point{hline.x0, hline.y}, image.Point{hline.x1 + 1, hline.y + 1}}, &image.Uniform{CLAY}, image.ZP, draw.Src)
    }
    for _, vline := range vlines {
        draw.Draw(img, image.Rectangle{image.Point{vline.x, vline.y0}, image.Point{vline.x + 1, vline.y1 + 1}}, &image.Uniform{CLAY}, image.ZP, draw.Src)
    }

    pour(img, 500, TL.Y)

    water_cells := 0
    res_cells := 0
    for x := TL.X; x < BR.X; x++ {
        for y := TL.Y; y < BR.Y; y++ {
            c := img.At(x, y)
            if c == WATER || c == SAND_WATER {
                water_cells++
            }
            if c == WATER {
                res_cells++
            }
        }
    }
    fmt.Println("water cells:", water_cells, ", stored water:", res_cells)

    pngfile, _ := os.Create("17.png")
    png.Encode(pngfile, img)
    pngfile.Close()
}

