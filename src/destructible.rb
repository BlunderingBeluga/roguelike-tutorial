class Destructible
  attr_accessor :owner, :xp
  attr_reader :max_hp, :hp, :defense, :corpse_name
  
  def initialize(owner, max_hp, defense, corpse_name, xp)
    @owner = owner
    @max_hp = max_hp
    @hp = max_hp
    @defense = defense
    @corpse_name = corpse_name
    @xp = xp # either XP creature has earned (player) OR XP you get for killing creature (monster)
  end
  
  def is_dead?
    @hp <= 0
  end
  
  def take_damage(damage)
    damage -= @defense
    
    if damage > 0
      @hp -= damage
      if is_dead?
        die
      end
    else
      damage = 0
    end
    damage
  end
  
  def die
    @owner.char = '%'
    @owner.color = 'red'
    @owner.name = @corpse_name
    @owner.blocks = false
    @owner.priority = 3
    $game.sort_actors
  end
  
  def heal(amount)
    @hp += amount;
    if @hp > @max_hp
      amount -= (@hp - @max_hp)
      @hp = @max_hp
    end
    amount
  end
end

class MonsterDestructible < Destructible
  def die
    $game.gui.message("#{@owner.name} is dead. You gain #{@owner.destructible.xp} XP", 'red')
    $game.player.destructible.xp += @xp
    super
  end
end

class PlayerDestructible < Destructible
  def die
    # (singing) Humanity restored and then...
    $game.gui.message("You died!", 'red')
    super
    $game.status = :defeat
  end
end