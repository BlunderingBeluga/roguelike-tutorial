class Actor
  attr_accessor :x, :y, :char, :name, :color
  
  def initialize(x, y, char, name, color)
    @x, @y, @char, @name, @color = x, y, char, name, color
  end
  
  def render
    Terminal.print(@x, @y, "[color=#{@color}]#{@char}[/color]")
  end
  
  def update
    messages = ["The #{@name} growls!", "The #{@name} grunts!",
      "The #{@name} roars with rage!"]
    $stderr.puts(messages.sample)
  end
  
  def move_or_attack(dx, dy)
    return false if $game.map.is_wall?(@x + dx, @y + dy)
    if enemy = $game.actor_occupying(@x + dx, @y + dy)
      $stderr.puts("The #{enemy.name} laughs at your puny efforts to attack him!")
      return false
    end
    @x += dx
    @y += dy
    true
  end
end