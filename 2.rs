use std::collections::HashMap;
use std::io::BufRead;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let file = std::fs::File::open(&args[1]).unwrap();
    let mut twos = 0;
    let mut threes = 0;
    for line in std::io::BufReader::new(&file).lines() {
        let mut counts = HashMap::new();

        for char in line.unwrap().chars() {
            if let Some(count) = counts.get_mut(&char) {
                *count += 1;
            } else {
                counts.insert(char, 1);
            }
        }

        if counts.values().any(|s| s == &2) {
            twos += 1;
        }
        if counts.values().any(|s| s == &3) {
            threes += 1;
        }
    }
    println!("{}", twos * threes);
}
