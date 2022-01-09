nanobots = []
ARGF.each_line do |line|
  if (match = /pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)/.match(line))
    nanobots << match.to_a[1..4].compact.map(&:to_i)
  end
end

def count_bots_in_range(nanobots, test_bot)
  nanobots.count { |bot| bot[0..2].zip(test_bot[0..2]).map { |cp| (cp[0] - cp[1]).abs }.sum <= test_bot[3] }
end

best_bot = nanobots.max_by { |bot| bot[3] }
puts count_bots_in_range(nanobots, best_bot)

# ...

require 'z3'
x = Z3::Int("x")
y = Z3::Int("y")
z = Z3::Int("z")

def zabs(n)
  Z3::IfThenElse(n < 0, -n, n)
end

opt = Z3::Optimize.new
nanobots.each_with_index do |bot, ri|
  Z3::LowLevel.optimize_assert_soft(opt,
    zabs(x - bot[0]) + zabs(y - bot[1]) + zabs(z - bot[2]) <= bot[3],
    "1", nil)
end
opt.minimize(x + y + z)
opt.satisfiable?
puts opt.model.to_s
puts opt.model.to_h.values.map(&:to_i).sum
