class Container
  attr_reader :inventory, :size
  
  def initialize(owner, size = 0)
    @owner = owner
    @size = size # max capacity (0 = unlimited)
    @inventory = []
  end
  
  def add(actor)
    if @size > 0 and @inventory.size >= @size
      return false
    end
    @inventory << actor
  end
  
  def remove(actor)
    @inventory.delete(actor)
  end
end