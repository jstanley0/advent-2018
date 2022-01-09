nanobots = [] of Array(Int64)
ARGF.each_line do |line|
  if (match = /pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)/.match(line))
    nanobots << match.to_a[1..4].compact.map(&.to_i64)
  end
end

def count_bots_in_range(nanobots, test_bot)
  nanobots.count { |bot| bot[0..2].zip(test_bot[0..2]).map { |cp| (cp[0] - cp[1]).abs }.sum <= test_bot[3] }
end

best_bot = nanobots.max_by { |bot| bot[3] }
puts count_bots_in_range(nanobots, best_bot)

# ...

dr = nanobots.map { |bot| [bot[0].abs + bot[1].abs + bot[2].abs, bot[3]] }.map { |dr| [[0i64, dr[0] - dr[1]].max, dr[0] + dr[1]] }.sort

q = [] of Array(Int64|Int32)
dr.each do |thing|
  q << [thing[0], 1]
  q << [thing[1], -1]
end
q.sort!

s = 0
ms = 0
mc = 0
q.each do |pair|
  s += pair[1]
  if s > ms
    ms = s
    mc = pair[0]
  end
end
puts ms, mc

# lol it worked for some people on reddit
