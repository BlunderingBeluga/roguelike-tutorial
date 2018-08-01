class Attacker
  attr_accessor :owner, :base_power
  
  def initialize(owner, power)
    @owner, @base_power = owner, power
  end
  
  def power
    if @owner.can_equip
      bonus = @owner.can_equip.power_bonus
    else
      bonus = 0
    end
    @base_power + bonus
  end
  
  def attack(target)
    if target.destructible and not target.destructible.is_dead?
      if (power - target.destructible.defense) > 0
        $game.gui.message("#{@owner.name} attacks #{target.name} for " + 
        "#{power - target.destructible.defense} hit points.",
        @owner == $game.player ? 'red' : 'yellow')
      else
        $game.gui.message("#{@owner.name} attacks #{target.name} but it has no effect!", 'white')
      end
      target.destructible.take_damage(power)
    else
      $game.gui.message("#{@owner.name} attacks #{target.name} in vain.", 'white')
    end
  end
end