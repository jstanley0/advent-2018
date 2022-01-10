coords = ARGF.each_line.map { |line| line.split(",").map(&.to_i) }.to_a

def dist(c1, c2)
  c1.zip(c2).map { |a, b| (a - b).abs }.sum
end

constellations = 0
memberships = [] of (Int32 | Nil)
memberships.concat(coords.map { nil })
coords.each_with_index do |c, i|
  (0..i-1).each do |j|
    if dist(c, coords[j]) <= 3
      if memberships[i] && memberships[j]
        if i != j
          coords.each_with_index do |_, k|
            memberships[k] = memberships[j] if memberships[k] == memberships[i]
          end
        end
      elsif memberships[i] && !memberships[j]
        memberships[j] = memberships[i]
      elsif !memberships[i] && memberships[j]
        memberships[i] = memberships[j]
      elsif !memberships[i] && !memberships[j]
        memberships[i] = memberships[j] = constellations
        constellations += 1
      end
    end
  end
end

disconnected_points = memberships.count(&.nil?)
nontrivial_constellations = memberships.compact.uniq.size
puts "#{nontrivial_constellations} + #{disconnected_points} = #{nontrivial_constellations + disconnected_points}"
