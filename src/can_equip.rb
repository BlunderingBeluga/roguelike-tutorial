# For actors that can equip items

class CanEquip
  def initialize(owner)
    @owner = owner
    @slots = {}
  end
  
  def max_hp_bonus
    bonus = 0
    
    @slots.each do |slot, item|
      bonus += item.equippable.max_hp_bonus
    end
    bonus
  end
  
  def power_bonus
    bonus = 0
    
    @slots.each do |slot, item|
      bonus += item.equippable.power_bonus
    end
    bonus
  end
  
  def defense_bonus
    bonus = 0
    
    @slots.each do |slot, item|
      bonus += item.equippable.defense_bonus
    end
    bonus
  end
  
  def toggle_equip(equippable_actor)
    slot = equippable_actor.equippable.slot
    if @slots[slot]
      if @slots[slot] == equippable_actor
        $game.gui.message("Dequipped #{equippable_actor.name}.", 'yellow') # no, that isn't a word
        equippable_actor.equippable.equipped = false # this is starting to get ridiculous
        @slots.delete(slot)
      else
        $game.gui.message("There is already an item in that slot.", 'white')
      end
    else
      $game.gui.message("Equipped #{equippable_actor.name}.", 'green')
      equippable_actor.equippable.equipped = true
      @slots[slot] = equippable_actor
    end
  end
end
        