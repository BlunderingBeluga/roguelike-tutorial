class Actor
  attr_accessor :x, :y, :char, :name, :color, :blocks, :attacker, :destructible, :ai
  
  def initialize(x, y, char, name, color, blocks = true)
    @x, @y, @char, @name, @color, @blocks = x, y, char, name, color, blocks
  end
  
  def render
    Terminal.print(@x, @y, "[color=#{@color}]#{@char}[/color]")
  end
  
  def update
    @ai.update if @ai
  end
  
  def move_or_attack(dx, dy)
    return false if $game.map.is_wall?(@x + dx, @y + dy)
    if enemy = $game.actor_occupying(@x + dx, @y + dy) and enemy.blocks
      $stderr.puts("The #{enemy.name} laughs at your puny efforts to attack him!")
      return false
    end
    @x += dx
    @y += dy
    true
  end
end