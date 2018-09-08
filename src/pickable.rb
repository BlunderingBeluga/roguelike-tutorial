class Pickable
  def initialize(owner)
    @owner = owner
  end
  
  def pick(wearer)
    if wearer.container and wearer.container.add(@owner)
      $game.actors.delete(@owner)
      return true
    end
    false
  end
  
  def use(wearer)
    if wearer.can_equip and @owner.equippable
      wearer.can_equip.toggle_equip(@owner)
    elsif wearer.container
      wearer.container.remove(@owner)
      return true
    end
    false
  end
  
  def drop(wearer)
    if wearer.container
      wearer.container.remove(@owner)
      $game.add_actor(@owner)
      @owner.x = wearer.x
      @owner.y = wearer.y
      $game.gui.message("#{wearer.name} drops a #{@owner.name}.", 'white')
    end
  end
end

class Healer < Pickable
  def initialize(owner, amount)
    super(owner)
    @amount = amount
  end
  
  def use(wearer)
    if wearer.destructible
      healed = wearer.destructible.heal(@amount)
      if healed > 0
        $game.gui.message("You are healed for #{healed} HP.", 'green')
        return super
      else
        $game.gui.message("You are already at full health.", 'yellow')
      end
    end
    false
  end
end

class LightningBolt < Pickable
  attr_reader :range, :damage
  
  def initialize(owner, range, damage)
    @owner, @range, @damage = owner, range, damage
  end
  
  def use(wearer)
    closest = $game.closest_monster(wearer.x, wearer.y, @range)
    unless closest
      $game.gui.message('No enemy is close enough to strike.', 'white')
      return false
    end
    $game.gui.message("A lightning bolt strikes the #{closest.name} with a loud thunder!", 'cyan')
    $game.gui.message("The damage is #{@damage} hit points.", 'cyan')
    closest.destructible.take_damage(@damage)
    super
  end
end

class Fireball < Pickable
  attr_reader :range, :damage
  
  def initialize(owner, range, damage)
    @owner, @range, @damage = owner, range, damage
  end
  
  def use(wearer)
    $game.gui.message("Left-click a target tile for the fireball,", 'cyan')
    $game.gui.message("or right-click to cancel.", 'cyan')
    if (x, y = $game.pick_a_tile(@range)) and x and y
      $game.gui.message("The fireball explodes, burning everything within #{@range} tiles!", 'orange')
      $game.actors.each do |actor|
        if actor.destructible and not actor.destructible.is_dead? and
          $game.distance_between(actor.x, actor.y, x, y) <= @range
          $game.gui.message("The #{actor.name} gets burned for #{@damage} hit points.", 'orange')
          actor.destructible.take_damage(damage)
        end
      end
      super
    end
  end
end

class Confuser < Pickable
  def initialize(owner, nb_turns, range)
    @owner, @nb_turns, @range = owner, nb_turns, range
  end
  
  def use(wearer)
    $game.gui.message('Left-click an enemy to confuse it,', 'cyan')
    $game.gui.message('or right-click to cancel.', 'cyan')
    if (x, y = $game.pick_a_tile(@range)) and x and y
      actor = $game.actor_occupying(x, y) { |a| a.ai and a.blocks }
      unless actor
        $game.gui.message("No creature there to be confused.", 'white')
        return
      end
      if actor == $game.player
        $game.gui.message("That would be foolish.", 'peach')
        return
      end
      actor.ai = ConfusedMonsterAi.new(actor, @nb_turns, actor.ai)
      $game.gui.message("The eyes of the #{actor.name} look vacant,", 'lime')
      $game.gui.message("as he starts to stumble around!", 'lime')
      super
    end
  end
end