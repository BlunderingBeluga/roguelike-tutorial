class Ai
  attr_accessor :owner
  
  def initialize(owner)
    @owner = owner
  end
  
  def update
  end
end

class PlayerAi < Ai
  attr_reader :xp_level
  
  LEVEL_UP_BASE = 200
  LEVEL_UP_FACTOR = 150
  
  def initialize(owner)
    super
    @xp_level = 1
  end
  
  def next_level_xp
    LEVEL_UP_BASE + @xp_level * LEVEL_UP_FACTOR
  end
  
  def update
    return false if @owner.destructible and @owner.destructible.is_dead?
    
    advance_level if @owner.destructible.xp >= next_level_xp
    
    # handle keys
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
    when Terminal::TK_G
      # _G_et item
      found = false
      if actor = $game.actor_occupying(@owner.x, @owner.y) { |a| a.pickable }
        if actor.pickable.pick(@owner)
          found = true
          $game.status = :new_turn
          $game.gui.message("You pick up the #{actor.name}.", 'white')
        else
          found = true
          $game.gui.message("Your inventory is full.", 'red')
        end
      end
      unless found
        $game.gui.message("Nothing to pick up here.", 'white')
      end
    when Terminal::TK_I
      # View _I_nventory
      actor = choose_from_inventory
      if actor
        actor.pickable.use(@owner)
        $game.status = :new_turn
      end
    when Terminal::TK_D
      if Terminal.check?(Terminal::TK_CONTROL) and $DEBUG
        # _D_ebug instead
        debug_menu
        return
      end
      # _D_rop item
      actor = choose_from_inventory
      if actor
        actor.pickable.drop(@owner)
        $game.status = :new_turn
      end
    when Terminal::TK_PERIOD
      if Terminal.check?(Terminal::TK_SHIFT)
        # Go down (>)
        if $game.stairs.x == @owner.x and $game.stairs.y == @owner.y
          $game.next_level
        else
          $game.gui.message('There are no stairs here.', 'white')
        end
      end
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
    
    if actor = $game.actor_occupying(tx, ty)
      if (actor.destructible and actor.destructible.is_dead?) or actor.pickable
        $game.gui.message("There's a #{actor.name} here.", 'white')
      end
    end
    
    @owner.x = tx
    @owner.y = ty
  end
  
  def choose_from_inventory
    $game.gui.inventory_menu("Inventory", @owner.container.inventory)
    if $game.gui.last_menu_value
      return $game.gui.last_menu_value.item
    end
  end
  
  def debug_menu
    $game.gui.clickable_menu('Debug options', ['Spawn monster', 'Spawn item'])
    if $game.gui.last_menu_value
      case $game.gui.last_menu_value.name
      when 'Spawn monster'
        $game.gui.clickable_menu('Spawn monster',
          Config::ActorSpecs.monster_names.map { |name, freq| name.to_s })
        if $game.gui.last_menu_value
          mons = Config::ActorSpecs.monster($game.gui.last_menu_value.name.intern)
          $game.add_actor(mons)
          mons.x = $game.player.x + 1
          mons.y = $game.player.y + 1
        end
      when 'Spawn item'
        $game.gui.clickable_menu('Spawn item',
          Config::ActorSpecs.item_names.map { |name, freq| name.to_s })
        if $game.gui.last_menu_value
          item = Config::ActorSpecs.item($game.gui.last_menu_value.name.intern)
          $game.add_actor(item)
          item.x = $game.player.x + 1
          item.y = $game.player.y + 1
        end
      end
    end
  end
  
  def advance_level
    @owner.destructible.xp -= next_level_xp
    @xp_level += 1
    $game.gui.message("Your battle skills grow stronger! You reached level #{@xp_level}.", 'yellow')
    $game.gui.arrow_key_menu("Level up",
      ['Constitution (+20 HP)', 'Strength (+1 attack)', 'Agility (+1 defense)'])
    if $game.gui.last_menu_value
      case $game.gui.last_menu_value.name
      when 'Constitution (+20 HP)'
        @owner.destructible.base_max_hp += 20
        @owner.destructible.hp += 20
      when 'Strength (+1 attack)'
        @owner.attacker.base_power += 1
      when 'Agility (+1 defense)'
        @owner.destructible.base_defense += 1
      end
    end
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
    if $game.actor_occupying(tx, ty) { |a| a == $game.player }
      @owner.attacker.attack($game.player)
      return true
    end
    
    # slide along walls
    if not $game.map.is_wall?(tx, ty) and
      not $game.actor_occupying(tx, ty) { |a| a.blocks }
      @owner.x = tx
      @owner.y = ty
    elsif not $game.map.is_wall?(tx, @owner.y) and
      not $game.actor_occupying(tx, ty) { |a| a.blocks }
      @owner.x = tx
    elsif not $game.map.is_wall?(@owner.x, ty) and
      not $game.actor_occupying(tx, ty) { |a| a.blocks }
      @owner.y = ty
    else
      return false
    end
  end
end

class ConfusedMonsterAi < Ai
  def initialize(owner, nb_turns, old_ai)
    @owner, @nb_turns, @old_ai = owner, nb_turns, old_ai
    @old_color = @owner.color
    @owner.color = 'violet'
  end
  
  def update
    dx = rand(3) - 1
    dy = rand(3) - 1
    
    tx = @owner.x + dx
    ty = @owner.y + dy
    if not $game.map.is_wall?(tx, ty) and
      not $game.actor_occupying(tx, ty) { |a| a.blocks }
      @owner.x = tx
      @owner.y = ty
    elsif actor = $game.actor_occupying(tx, ty) { |a| a.destructible and not a.destructible.is_dead? }
      @owner.attacker.attack(actor)
    end
    @nb_turns -= 1
    if @nb_turns <= 0
      $game.gui.message("The #{@owner.name} is no longer confused!", 'red')
      @owner.ai = @old_ai
      # corpses should remain red
      @owner.color = @old_color unless @owner.destructible.is_dead? 
    end
  end
end
