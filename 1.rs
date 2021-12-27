use std::io::BufRead;

fn read_lines<F>(mut f: F)
where
    F: FnMut(String),
{
    let args: Vec<String> = std::env::args().collect();
    let file = std::fs::File::open(&args[1]).expect("failed to open input");
    for lr in std::io::BufReader::new(&file).lines() {
        f(lr.expect("failed to read line"));
    }
}

fn main() {
    let mut sum = 0;
    read_lines(|line| {
        sum += line.parse::<i64>().expect("failed to parse number");
    });
    println!("{}", sum);
}
