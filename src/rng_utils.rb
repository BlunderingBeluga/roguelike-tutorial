# Useful tools for beseeching the great RNG.

module RNGUtilities
  def self.weighted_random(chances)
    sum = chances.inject(0) { |sum, item_and_weight| sum += item_and_weight.last }
    target = rand(sum)

    chances.each do |item, weight|
      return item if target <= weight
      target -= weight
    end
  end
  
  def self.from_level(table, dungeon_level)
    table.reverse_each do |value, level|
      return value if dungeon_level >= level
    end
    0
  end 
end