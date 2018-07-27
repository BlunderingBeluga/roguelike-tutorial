class Actor
  attr_accessor :x, :y, :char, :name, :color, :blocks, :attacker, :destructible,
    :ai, :pickable, :container, :priority, :fov_only
  
  def initialize(x, y, char, name, color, priority, blocks = true, fov_only = true)
    @x, @y, @char, @name, @color, @priority = x, y, char, name, color, priority
    @blocks = blocks
    @fov_only = fov_only # whether to only display when in FOV
  end
  
  def render(in_fov = true)
    Terminal.print(@x, @y, "[color=#{in_fov ? @color : 'gray'}]#{@char}[/color]")
  end
  
  def update
    @ai.update if @ai
  end
end