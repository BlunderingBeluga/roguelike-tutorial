class MenuItem
  attr_accessor :x, :y
  attr_reader :name
  
  def initialize(name)
    @name = name
  end
  
  def hover?(x, y)
    return false unless @x and @y
    y == @y and x >= @x and x < @x + @name.size
  end
  
  def render(background = false)
    Terminal.print(@x, @y, background ? "[bkcolor=blue]#{@name}[/bkcolor]" : @name)
  end
end


class Menu
  def initialize(title, item_names)
    @title = title
    @items = item_names.map do |name|
      MenuItem.new(name)
    end
    @last_value = nil
    @selected_item_index = 0
  end
  
  def selected?(item)
    @items.index(item) == @selected_item_index
  end
  
  def render
    x = Config::MAP_WIDTH / 2 - @title.size / 2
    Terminal.print(x, 1, @title)
    
    y = 3
    @items.each do |item|
      item.x = 1
      item.y = y
      item.render(selected?(item))
      y += 1
    end
  end
  
  def retrieve_value
    if $game.last_event == Terminal::TK_ENTER
      return @items[@selected_item_index].name
    end
    return false
  end
    
  def update
    case $game.last_event
    when Terminal::TK_UP
      @selected_item_index -= 1
      if @selected_item_index < 0
        @selected_item_index = @items.size - 1
      end
    when Terminal::TK_DOWN
      @selected_item_index += 1
      if @selected_item_index > @items.size - 1
        @selected_item_index = 0
      end
    end
  end
end
