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
    if wearer.container
      wearer.container.remove(@owner)
      return true
    end
    false
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
        $game.gui.message("You are healed for #{@amount} HP.", 'white')
        return super
      else
        $game.gui.message("You are already at full health.", 'white')
      end
    end
    false
  end
end