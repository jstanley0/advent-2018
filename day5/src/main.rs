use std::io::BufRead;

fn react_polymer(polymer: &Vec<u8>) -> Vec<u8> {
    let mut bytes = polymer.clone();
    loop {
        let mut done = true;
        let mut i = 1;
        while i < bytes.len() {
            if bytes[i] != bytes[i - 1]
                && bytes[i].to_ascii_lowercase() == bytes[i - 1].to_ascii_lowercase()
            {
                bytes.remove(i - 1);
                bytes.remove(i - 1);
                done = false;
            } else {
                i += 1;
            }
        }
        if done {
            break;
        }
    }
    bytes
}

fn main() -> std::io::Result<()> {
    let args: Vec<String> = std::env::args().collect();
    let file = std::fs::File::open(&args[1])?;
    let mut line = String::new();
    std::io::BufReader::new(&file).read_line(&mut line)?;
    let bytes = line.trim_end().as_bytes().to_vec();

    let poly = react_polymer(&bytes);
    println!("reacting the polymer as-is: {}", poly.len());

    let mut elements: Vec<u8> = bytes.iter().map(|a| a.to_ascii_lowercase()).collect();
    elements.sort();
    elements.dedup();

    let mut min = bytes.len();
    for element in &elements {
        let reduction: Vec<u8> = bytes
            .iter()
            .filter_map(|a| {
                if a.to_ascii_lowercase() == *element {
                    None
                } else {
                    Some(*a)
                }
            })
            .collect();
        let poly = react_polymer(&reduction);
        println!("after removing {}: {}", (*element as char).to_string(), poly.len());
        if poly.len() < min {
            min = poly.len();
        }
    }

    println!("minimum size: {}", min);
    Ok(())
}
