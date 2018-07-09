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
end

class MonsterDestructible < Destructible
  def die
    $stderr.puts("#{@owner.name} is dead")
    super
  end
end

class PlayerDestructible < Destructible
  def die
    # (singing) Humanity restored and then...
    $stderr.puts("You died!")
    super
    $game.status = :defeat
  end
end