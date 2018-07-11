class Ai
  attr_accessor :owner
  
  def initialize(owner)
    @owner = owner
  end
  
  def update
  end
end

class PlayerAi < Ai  
  def update
    return false if @owner.destructible and @owner.destructible.is_dead?
    
    dx, dy = 0, 0
    
    case $game.last_event
    when Terminal::TK_UP
      dy = -1
    when Terminal::TK_DOWN
      dy = 1
    when Terminal::TK_LEFT
      dx = -1
    when Terminal::TK_RIGHT
      dx = 1
    when Terminal::TK_CLOSE
      Terminal.close
      exit
    end
    
    unless (dx == 0 and dy == 0)
      $game.status = :new_turn
      $game.fov_recompute = true if move_or_attack(dx, dy)
    end 
  end
  
  def move_or_attack(dx, dy)
    tx, ty = @owner.x + dx, @owner.y + dy # target coordinates
    return false if $game.map.is_wall?(tx, ty)
  
    $game.actors.each do |actor|
      if actor.destructible and not actor.destructible.is_dead? and
        actor.x == tx and actor.y == ty
        @owner.attacker.attack(actor)
        return false
      end
    end
    
    $game.actors.each do |actor|
      if actor.destructible and actor.destructible.is_dead? and
        actor.x == tx and actor.y == ty
        $game.gui.message("There's a #{actor.name} here", 'white')
      end
    end
    
    @owner.x = tx
    @owner.y = ty
  end
end

class MonsterAi < Ai
  def initialize(owner)
    super
    @move_count = 0
  end
  
  def update
    return false if @owner.destructible and @owner.destructible.is_dead?
    
    if $game.map.is_lit?(@owner.x, @owner.y)
      @move_count = Config::TRACKING_TURNS
    else
      @move_count -= 1
    end
    if @move_count > 0
      px, py = $game.player.x, $game.player.y
      
      dx = px - @owner.x
      dy = py - @owner.y
      stepdx = dx == 0 ? 0 : (dx > 0 ? 1 : -1)
      stepdy = dy == 0 ? 0 : (dy > 0 ? 1 : -1)
      
      move_or_attack(stepdx, stepdy)
    end
  end
  
  def move_or_attack(dx, dy)
    tx, ty = @owner.x + dx, @owner.y + dy # target coordinates
    if $game.actor_occupying(tx, ty) == $game.player
      @owner.attacker.attack($game.player)
      return true
    end
    
    # slide along walls
    if not $game.map.is_wall?(tx, ty) and not $game.actor_occupying(tx, ty)
      @owner.x = tx
      @owner.y = ty
    elsif not $game.map.is_wall?(tx, @owner.y) and
      not $game.actor_occupying(tx, @owner.y)
      $stderr.puts "Allowing for x"
      @owner.x = tx
    elsif not $game.map.is_wall?(@owner.x, ty) and
      not $game.actor_occupying(@owner.x, ty)
      $stderr.puts "Allowing for y"
      @owner.y = ty
    else
      return false
    end
  end
end