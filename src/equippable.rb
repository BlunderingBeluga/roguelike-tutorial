# For items that can be equipped, i.e. swords, shields, armor...

class Equippable
  attr_accessor :equipped
  attr_reader :slot, :power_bonus, :defense_bonus, :max_hp_bonus
  
  def initialize(owner, slot, power_bonus = 0, defense_bonus = 0, max_hp_bonus = 0)
    @owner = owner
    @slot = slot
    @power_bonus = power_bonus
    @defense_bonus = defense_bonus
    @max_hp_bonus = max_hp_bonus
    @equipped = false
  end
end