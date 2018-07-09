class Attacker
  attr_accessor :owner, :power
  
  def initialize(owner, power)
    @owner, @power = owner, power
  end
  
  def attack(target)
    if target.destructible and not target.destructible.is_dead?
      if (@power - target.destructible.defense) > 0
        $stderr.puts("#{@owner.name} attacks #{target.name} for #{@power - target.destructible.defense} hit points.")
      else
        $stderr.puts("#{@owner.name} attacks #{target.name} but it has no effect!")
      end
      target.destructible.take_damage(@power)
    else
      $stderr.puts("#{@owner.name} attacks #{target.name} in vain.")
    end
  end
end