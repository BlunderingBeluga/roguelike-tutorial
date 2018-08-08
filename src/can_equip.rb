# For actors that can equip items

class CanEquip
  attr_reader :slots
  
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
  
  def dequip(equipment)
    $game.gui.message("Dequipped #{equipment.name}.", 'yellow')
    equipment.equippable.equipped = false # this is starting to get ridiculous
    @slots.delete(equipment.equippable.slot)
  end
  
  def equip(equipment)
    $game.gui.message("Equipped #{equipment.name}.", 'green')
    equipment.equippable.equipped = true
    @slots[equipment.equippable.slot] = equipment
  end
  
  def toggle_equip(equipment)
    slot = equipment.equippable.slot
    if @slots[slot]
      if @slots[slot] == equipment
        dequip(equipment)
      else
        $game.gui.message("There is already an item in that slot.", 'white')
      end
    else
      equip(equipment)
    end
  end
end
        