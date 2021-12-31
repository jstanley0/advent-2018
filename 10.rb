require_relative '../2021/skim'
Particle = Struct.new(:x, :y, :dx, :dy)

particles = ARGF.lines.map { |line| Particle.new(*line.scan(/-?\d+/).map(&:to_i)) }
puts "x: #{particles.map(&:x).minmax}"
puts "y: #{particles.map(&:y).minmax}"

t = 0
total_dist = particles.inject(0) { |sum, particle| sum + particle.x.abs + particle.y.abs }
loop do
  new_particles = particles.map { |p| Particle.new(p.x + p.dx, p.y + p.dy, p.dx, p.dy) }
  new_total_dist = particles.inject(0) { |sum, particle| sum + Math.sqrt(particle.x * particle.x + particle.y * particle.y) }
  if new_total_dist > total_dist
    break
  end
  particles = new_particles
  total_dist = new_total_dist
  t += 1
end

xr = particles.map(&:x).minmax
yr = particles.map(&:y).minmax
puts "after t=#{t}, xr=#{xr}, yr=#{yr}"

skim = Skim.new(xr[1] - xr[0] + 1, yr[1] - yr[0] + 1, ' ')
particles.each do |p|
  skim[p.x - xr[0], p.y - yr[0]] = '#'
end
skim.print
