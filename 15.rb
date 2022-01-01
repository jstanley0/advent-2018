require_relative '../2021/skim'
require 'pqueue'

Point = Struct.new(:x, :y) do
  def reading_order
    y * 1000 + x
  end

  def <(rhs)
    self.reading_order < rhs.reading_order
  end

  def <=>(rhs)
    self.reading_order <=> rhs.reading_order
  end

  # manhattan distance
  def dist(rhs)
    (self.x - rhs.x).abs + (self.y - rhs.y).abs
  end
end

QueueEntry = Struct.new(:point, :est_total_dist) do
  # break ties with "reading order" via Point#<
  def <=>(rhs)
    cmp = rhs.est_total_dist <=> est_total_dist
    cmp = rhs.point.reading_order <=> point.reading_order if cmp == 0
    cmp
  end
end

def build_path(path_links, target_point)
  path = [target_point]
  while (target_point = path_links[target_point])
    path.unshift target_point
  end
  path
end

def find_shortest_path(maze, from, to)
  fringe = PQueue.new
  fringe.push QueueEntry.new(from, from.dist(to))

  best_dist_to = {}
  best_dist_to[from] = 0

  path_links = {}

  until fringe.empty?
    current = fringe.pop
    return build_path(path_links, current.point) if current.point == to

    sub_dist = best_dist_to[current.point] + 1
    maze.nabes(*current.point, diag: false) do |val, x, y|
      nabe = Point.new(x, y)
      next unless val == '.' || nabe == to

      if best_dist_to[nabe].nil? || sub_dist < best_dist_to[nabe]
        best_dist_to[nabe] = sub_dist
        path_links[nabe] = current.point
        fringe.push QueueEntry.new(nabe, sub_dist + nabe.dist(to))
      elsif sub_dist == best_dist_to[nabe] && current.point < path_links[nabe]
        # reading order tiebreaker
        path_links[nabe] = current.point
      end
    end
  end

  nil
end

maze = Skim.read

UnitInfo = Struct.new(:type, :point, :hit_points, :attack_power) do
  def attack(power)
    self.hit_points -= power
  end

  def alive?
    hit_points > 0
  end

  def dead?
    !alive?
  end
end

unit_info = []
maze.each do |val, x, y|
  if val == 'G' || val == 'E'
    unit_info << UnitInfo.new(val, Point.new(x, y), 200, 3)
  end
end

rounds = 0
battle_over = false
loop do
  unit_info.sort_by!(&:point)
  unit_info.each do |my_info|
    next if my_info.dead?
    raise "stale map" unless maze[*my_info.point] == my_info.type

    enemies = unit_info.select { |u| u.alive? && u.type != my_info.type }
    if enemies.empty?
        battle_over = true
        break
    end

    enemies_in_range = enemies.select { |u| my_info.point.dist(u.point) == 1 }
    if enemies_in_range.empty?
      # find the closest enemy
      best_path = nil
      enemies.each do |enemy|
        path = find_shortest_path(maze, my_info.point, enemy.point) if maze.nv(*enemy.point, diag: false).include?('.')
        next unless path
        best_path = path if best_path.nil? || path.size < best_path.size
      end
      next if best_path.nil?

      # move one step toward the enemy
      raise "bad path" unless best_path.shift == my_info.point
      maze[*my_info.point] = '.'
      my_info.point = best_path.first
      maze[*my_info.point] = my_info.type

      # ... and then see if someone is in range
      enemies_in_range = enemies.select { |u| my_info.point.dist(u.point) == 1 }
    end

    target = enemies_in_range.min_by { |info| info.hit_points * 1_000_000 + info.point.reading_order }
    next unless target

    target.attack(my_info.attack_power)
    if target.dead?
      maze[*target.point] = '.'
    end
  end

  break if battle_over
  rounds += 1
  puts "round #{rounds} complete"
  maze.print
end

puts "battle ended after #{rounds} rounds"
hp = unit_info.select(&:alive?).map(&:hit_points).sum
puts "remaining hit points: #{hp}; outcome: #{hp * rounds}"
