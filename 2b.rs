use std::io::BufRead;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let file = std::fs::File::open(&args[1]).unwrap();
    let words: Vec<String> = std::io::BufReader::new(&file)
        .lines()
        .map(|line| line.unwrap())
        .collect();

    for w0 in &words {
        for w1 in &words {
            if w0.len() == w1.len() {
                let mut common_letters = String::new();
                for pair in w0.chars().zip(w1.chars()) {
                    if pair.0 == pair.1 {
                        common_letters.push(pair.0);
                    }
                }
                if common_letters.len() == w0.len() - 1 {
                    println!("{}", common_letters);
                    return;
                }
            }
        }
    }
}
