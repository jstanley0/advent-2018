use regex::Regex;
use std::io::BufRead;
use std::ops::Range;

fn range_overlap(r1: &Range<i32>, r2: &Range<i32>) -> Option<Range<i32>> {
    if r1.start < r2.start {
        if r1.end <= r2.start {
            None
        } else {
            Some(r2.start..if r1.end < r2.end { r1.end } else { r2.end })
        }
    } else {
        if r2.end <= r1.start {
            None
        } else {
            Some(r1.start..if r2.end < r1.end { r2.end } else { r1.end })
        }
    }
}

#[derive(Debug, Clone)]
struct Claim {
    num: i32,
    x: Range<i32>,
    y: Range<i32>,
}

impl Claim {
    fn area(&self) -> i32 {
        (self.x.end - self.x.start) * (self.y.end - self.y.start)
    }

    fn intersect(&self, other: &Claim) -> Option<Claim> {
        let xr = range_overlap(&self.x, &other.x);
        let yr = range_overlap(&self.y, &other.y);
        if xr.is_none() || yr.is_none() {
            return None;
        }
        Some(Claim {
            num: 0,
            x: xr.unwrap(),
            y: yr.unwrap(),
        })
    }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let file = std::fs::File::open(&args[1]).unwrap();
    let line_re = Regex::new(r"#(\d+) @ (\d+),(\d+): (\d+)x(\d+)").unwrap();
    let mut claims = Vec::new();
    for line in std::io::BufReader::new(&file).lines() {
        let line = line.unwrap();
        if let Some(caps) = line_re.captures(&line) {
            let num = caps[1].parse::<i32>().unwrap();
            let x = caps[2].parse::<i32>().unwrap();
            let y = caps[3].parse::<i32>().unwrap();
            let w = caps[4].parse::<i32>().unwrap();
            let h = caps[5].parse::<i32>().unwrap();
            claims.push(Claim {
                num: num,
                x: x..x + w,
                y: y..y + h,
            });
        }
    }

    let mut add_claims = Vec::new();
    let mut sub_claims = Vec::new();
    for claim in &claims {
        let mut to_add = Vec::new();
        let mut to_sub = Vec::new();

        for add_claim in &add_claims {
            match claim.intersect(&add_claim) {
                Some(v) => to_sub.push(v),
                None => (),
            }
        }
        for sub_claim in &sub_claims {
            match claim.intersect(&sub_claim) {
                Some(v) => to_add.push(v),
                None => (),
            }
        }

        to_add.push(claim.clone());
        add_claims.append(&mut to_add);
        sub_claims.append(&mut to_sub);
    }
    println!(
        "nominal claims {}",
        claims.iter().map(|c| c.area()).sum::<i32>()
    );
    println!(
        "add_claims {}",
        add_claims.iter().map(|c| c.area()).sum::<i32>()
    );
    println!(
        "sub_claims {}",
        sub_claims.iter().map(|c| c.area()).sum::<i32>()
    );
}
