class Destructible
  attr_accessor :owner
  attr_reader :max_hp, :hp, :defense, :corpse_name
  
  def initialize(owner, max_hp, defense, corpse_name)
    @owner = owner
    @max_hp = max_hp
    @hp = max_hp
    @defense = defense
    @corpse_name = corpse_name
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
    $game.send_to_back(@owner)
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
    $game.gui.message("#{@owner.name} is dead", 'red')
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