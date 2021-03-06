class Destructible
  attr_accessor :owner, :xp, :defense, :base_max_hp, :hp, :base_defense
  attr_reader :corpse_name
  
  def initialize(owner, max_hp, defense, corpse_name, xp)
    @owner = owner
    @base_max_hp = max_hp
    @hp = max_hp
    @base_defense = defense
    @corpse_name = corpse_name
    @xp = xp # either XP creature has earned (player) OR XP you get for killing creature (monster)
  end
  
  def max_hp
    if @owner.can_equip
      bonus = @owner.can_equip.max_hp_bonus
    else
      bonus = 0
    end
    @base_max_hp + bonus
  end
  
  def defense
    if @owner.can_equip
      bonus = @owner.can_equip.defense_bonus
    else
      bonus = 0
    end
    @base_defense + bonus
  end
  
  def is_dead?
    @hp <= 0
  end
  
  def take_damage(damage)
    damage -= defense
    
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
    @owner.ai = nil if @owner.ai
    $game.sort_actors
  end
  
  def heal(amount)
    @hp += amount;
    if @hp > max_hp
      amount -= (@hp - max_hp)
      @hp = max_hp
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