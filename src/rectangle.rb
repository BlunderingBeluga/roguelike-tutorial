class Rect
  attr_reader :x1, :y1, :x2, :y2
  
  def initialize(x, y, w, h)
    @x1 = x
    @y1 = y
    @x2 = x + w
    @y2 = y + h
  end
  
  def center
    [(@x1 + @x2) / 2, (@y1 + @y2) / 2]
  end
  
  def intersect(other)
    (@x1 <= other.x2 and @x2 >= other.x1 and @y1 <= other.y2 and @y2 >= other.y1)
  end
end