class Actor
  attr_accessor :x, :y, :char, :color
  
  def initialize(x, y, char, color)
    @x, @y, @char, @color = x, y, char, color
  end
  
  def render
    Terminal.print(@x, @y, "[color=#{@color}]#{@char}[/color]")
  end
end