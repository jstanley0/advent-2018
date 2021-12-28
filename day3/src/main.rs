use ndarray::Array2;
use regex::Regex;
use std::io::BufRead;
use std::ops::Range;

#[derive(Debug)]
struct Claim {
    num: usize,
    x: Range<usize>,
    y: Range<usize>,
}

fn uncontested_claim(claim: &Claim, mat: &Array2<usize>) -> bool {
    for x in claim.x.clone() {
        for y in claim.y.clone() {
            if mat[[x, y]] > 1 {
                return false;
            }
        }
    }
    true
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let file = std::fs::File::open(&args[1]).unwrap();
    let line_re = Regex::new(r"#(\d+) @ (\d+),(\d+): (\d+)x(\d+)").unwrap();
    let mut claims = Vec::new();
    for line in std::io::BufReader::new(&file).lines() {
        let line = line.unwrap();
        if let Some(caps) = line_re.captures(&line) {
            let num = caps[1].parse::<usize>().unwrap();
            let x = caps[2].parse::<usize>().unwrap();
            let y = caps[3].parse::<usize>().unwrap();
            let w = caps[4].parse::<usize>().unwrap();
            let h = caps[5].parse::<usize>().unwrap();
            claims.push(Claim {
                num: num,
                x: x..x + w,
                y: y..y + h,
            });
        }
    }

    let mut mat = Array2::<usize>::zeros((1000, 1000));
    for claim in &claims {
        for x in claim.x.clone() {
            for y in claim.y.clone() {
                mat[[x as usize, y as usize]] += 1;
            }
        }
    }

    let mut overlap = 0;
    mat.for_each(|n| {
        if n > &1 {
            overlap += 1
        }
    });

    println!("{}", overlap);

    for claim in &claims {
        if uncontested_claim(&claim, &mat) {
            println!("claim {} is uncontested", claim.num);
        }
    }
}
