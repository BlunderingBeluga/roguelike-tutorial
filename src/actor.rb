class Actor
  attr_accessor :x, :y, :char, :name, :color, :blocks, :attacker, :destructible,
    :ai, :pickable, :container
  
  def initialize(x, y, char, name, color, blocks = true)
    @x, @y, @char, @name, @color, @blocks = x, y, char, name, color, blocks
  end
  
  def render
    Terminal.print(@x, @y, "[color=#{@color}]#{@char}[/color]")
  end
  
  def update
    @ai.update if @ai
  end
end