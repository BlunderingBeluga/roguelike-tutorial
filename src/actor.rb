class Actor
  attr_accessor :x, :y, :char, :name, :color, :blocks, :attacker, :destructible,
    :ai, :pickable, :container, :priority
  
  def initialize(x, y, char, name, color, priority, blocks = true)
    @x, @y, @char, @name, @color, @priority, @blocks = x, y, char, name, color, priority, blocks
  end
  
  def render
    Terminal.print(@x, @y, "[color=#{@color}]#{@char}[/color]")
  end
  
  def update
    @ai.update if @ai
  end
end