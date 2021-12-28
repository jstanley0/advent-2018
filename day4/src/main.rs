use regex::Regex;
use std::collections::HashMap;
use std::io::BufRead;
use std::ops::Range;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let file = std::fs::File::open(&args[1]).unwrap();
    let ts_re = Regex::new(r"\[\d\d\d\d-\d\d-\d\d \d\d:(\d\d)\]").unwrap();
    let guard_re = Regex::new(r"Guard #(\d+) begins shift").unwrap();
    let mut log = Vec::new();
    for line in std::io::BufReader::new(&file).lines() {
        log.push(line.unwrap());
    }
    log.sort();

    let mut sleep_ranges = HashMap::<usize, Vec<Range<usize>>>::new();
    let mut current_guard = 0;
    let mut asleep_min = 0;
    for entry in &log {
        if let Some(caps) = guard_re.captures(&entry) {
            current_guard = caps[1].parse::<usize>().unwrap();
        } else {
            let caps = ts_re.captures(&entry).unwrap();
            let minute = caps[1].parse::<usize>().unwrap();
            if entry.contains("falls asleep") {
                asleep_min = minute;
            } else if entry.contains("wakes up") {
                if let Some(vec) = sleep_ranges.get_mut(&current_guard) {
                    vec.push(asleep_min..minute);
                } else {
                    sleep_ranges.insert(current_guard, vec![asleep_min..minute]);
                }
            }
        }
    }

    let mut sleepiest_guard = (0, 0);
    for (guard, sleeps) in sleep_ranges.iter() {
        let minutes_asleep = sleeps.iter().map(|range| range.len()).sum();
        if minutes_asleep > sleepiest_guard.1 {
            sleepiest_guard = (*guard, minutes_asleep)
        }
    }
    let sleepiest_guard = sleepiest_guard.0;
    println!("sleepiest_guard is {}", sleepiest_guard);

    let mut mins_asleep = [0u8; 60];
    for range in &sleep_ranges[&sleepiest_guard] {
        for min in range.clone() {
            mins_asleep[min] += 1;
        }
    }

    let mut sleepiest_minute = 0;
    for min in 1..60 {
        if mins_asleep[min] > mins_asleep[sleepiest_minute] {
            sleepiest_minute = min;
        }
    }

    println!("sleepiest minute is {}", sleepiest_minute);
    println!("answer to part 1 is {}", sleepiest_guard * sleepiest_minute);

    let mut guards_asleep_by_minute = HashMap::<usize, HashMap<usize, usize>>::new();
    for (guard, sleeps) in sleep_ranges.iter() {
        for range in sleeps.iter() {
            for min in range.clone() {
                if let Some(guard_hash) = guards_asleep_by_minute.get_mut(&min) {
                    if let Some(count) = guard_hash.get_mut(&guard) {
                        *count += 1;
                    } else {
                        guard_hash.insert(*guard, 1);
                    }
                } else {
                    let mut h = HashMap::<usize, usize>::new();
                    h.insert(*guard, 1);
                    guards_asleep_by_minute.insert(min, h);
                }
            }
        }
    }

    let mut meh = (0, 0, 0);
    for (minute, guard_hash) in guards_asleep_by_minute.iter() {
        for (guard, sleep_count) in guard_hash.iter() {
            if sleep_count > &meh.2 {
                meh = (*minute, *guard, *sleep_count);
            }
        }
    }

    println!("meh {:?}", meh);
    println!("the answer to part 2 is {}", meh.0 * meh.1);
}
