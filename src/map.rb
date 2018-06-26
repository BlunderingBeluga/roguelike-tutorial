class Tile
  attr_accessor :can_walk
  
  def initialize(can_walk)
    @can_walk = can_walk
  end
end

class Map
  attr_reader :width, :height, :tiles
  
  def initialize(width, height)
    @width, @height = width, height
    @tiles = []
    (@width * @height).times do
      @tiles << Tile.new(true)
    end
    
    set_wall(30, 12)
    set_wall(50, 12)
  end
  
  def is_wall?(x, y)
    x < 0 or y < 0 or x >= @width or y >= @height or not @tiles[x + y * width].can_walk
  end
  
  def set_wall(x, y)
    @tiles[x + y * width].can_walk = false
  end
  
  def render
    @width.times do |x|
      @height.times do |y|
        Terminal.print(x, y, is_wall?(x, y) ? "#" : ".")
      end
    end
  end
  
end