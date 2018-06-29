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
      @tiles << Tile.new(false)
    end
    
    make_map
  end
  
  def is_wall?(x, y)
    x < 0 or y < 0 or x >= @width or y >= @height or not @tiles[x + y * width].can_walk
  end

  def render
    @width.times do |x|
      @height.times do |y|
        Terminal.print(x, y, is_wall?(x, y) ? "#" : ".")
      end
    end
  end
  
  def make_map
    rooms = []
    num_rooms = 0
    
    1.upto(Config::MAX_ROOMS) do
      w = rand(Config::ROOM_MAX_SIZE - Config::ROOM_MIN_SIZE) + Config::ROOM_MIN_SIZE
      h = rand(Config::ROOM_MAX_SIZE - Config::ROOM_MIN_SIZE) + Config::ROOM_MIN_SIZE
      
      x = rand(Config::MAP_WIDTH - w - 4) + 3
      y = rand(Config::MAP_HEIGHT - h - 4) + 3
      
      new_room = Rect.new(x, y, w, h)
      
      valid = true
      rooms.each do |other_room|
        valid = false if new_room.intersect(other_room)
      end
      
      if valid
        create_room(new_room)
      
        new_x, new_y = new_room.center
      
        if num_rooms == 0
          $game.player.x = new_x
          $game.player.y = new_y
        else
          prev_x, prev_y = rooms.last.center
          if rand(2)
            create_h_tunnel(prev_x, new_x, prev_y)
            create_v_tunnel(prev_y, new_y, new_x)
          else
            create_v_tunnel(prev_y, new_y, prev_x)
            create_h_tunnel(prev_x, new_x, new_y)
          end
        end
        
        rooms << new_room
        num_rooms += 1
      end
    end
  end
  
  def create_room(room)
    ((room.x1 + 1)..room.x2).each do |x|
      ((room.y1 + 1)..room.y2).each do |y|
        @tiles[x + y * width].can_walk = true
      end
    end
  end
  
  def create_h_tunnel(x1, x2, y)
    ([x1, x2].min..([x1, x2].max)).each do |x|
      @tiles[x + y * width].can_walk = true
    end
  end
  
  def create_v_tunnel(y1, y2, x)
    ([y1, y2].min..([y1, y2].max)).each do |y|
      @tiles[x + y * width].can_walk = true
    end
  end
end