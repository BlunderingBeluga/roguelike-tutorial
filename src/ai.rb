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
  def update
    return false if @owner.destructible and @owner.destructible.is_dead?
    px, py = $game.player.x, $game.player.y
    
    # FIXME
    if @owner.x < px
      dx = 1
    elsif @owner.x > px
      dx = -1
    else
      dx = 0
    end
    
    if @owner.y < py
      dy = 1
    elsif @owner.y > py
      dy = -1
    else
      dy = 0
    end
    
    if $game.map.is_lit?(@owner.x, @owner.y)
      move_or_attack(dx, dy)
    end
  end
  
  def move_or_attack(dx, dy)
    tx, ty = @owner.x + dx, @owner.y + dy # target coordinates
    return false if $game.map.is_wall?(tx, ty)
    
    $game.actors.each do |actor|
      if actor != self and actor.x == tx and actor.y == ty
        if actor == $game.player 
          @owner.attacker.attack($game.player)
        end
        return false
      end
    end
    
    @owner.x = tx
    @owner.y = ty
  end
end