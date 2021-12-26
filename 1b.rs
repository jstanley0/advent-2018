use std::io::BufRead;
use std::collections::HashSet;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let file = std::fs::File::open(&args[1]).unwrap();
    let data: Vec<i64> = std::io::BufReader::new(&file).lines().map(|line| {
        line.unwrap().parse::<i64>().unwrap()
    }).collect();

    let mut sum = 0;
    let mut sums_seen = HashSet::new();

    loop {
        for number in &data {
            sums_seen.insert(sum);
            sum += number;
            if sums_seen.contains(&sum) {
                println!("repeated frequency: {}", sum);
                return;
            }
        }
    }
}
