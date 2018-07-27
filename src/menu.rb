class MenuItem
  attr_accessor :x, :y
  attr_reader :name, :item
  
  def initialize(name, item = nil)
    @name = name
    @item = item if item
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
  def initialize(title, items)
    @title = title
    if items.first.is_a?(String)
      @items = items.map do |name|
        MenuItem.new(name)
      end
    else
      @items = items.map do |item|
        MenuItem.new(item.name, item)
      end
    end
    @last_value = false
    @done = false
  end
  
  def render
    x = Config::WINDOW_WIDTH / 2 - @title.size / 2
    Terminal.print(x, 1, @title)
    
    y = 3
    @items.each do |item|
      item.x = 1
      item.y = y
      item.render(selected?(item))
      y += 1
    end
  end
  
  def update(key)
    if key == Terminal::TK_ESCAPE
      @done = true
    end
  end
  
  def selected?(item)
    # dummy method
  end
  
  def retrieve_value
    @last_value
  end
  
  def done?
    @done
  end
end

class ClickableMenu < Menu
  def selected?(item)
    item.hover?($game.mouse_x, $game.mouse_y)
  end
  
  def update(key)
    super
    if key == Terminal::TK_MOUSE_LEFT
      @items.each do |item|
        if item.hover?($game.mouse_x, $game.mouse_y)
          @last_value = item
          @done = true
        end
      end
    end
  end
end

class ArrowKeyMenu < Menu
  def initialize(title, items)
    super
    @selected_item_index = 0
  end
  
  def selected?(item)
    @items.index(item) == @selected_item_index
  end
  
  def update(key)
    super
    case key
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
    when Terminal::TK_ENTER
      @last_value = @items[@selected_item_index]
      @done = true
    end
  end
end

class AlphabetMenu < Menu
  def render
    x = Config::WINDOW_WIDTH / 2 - @title.size / 2
    Terminal.print(x, 1, @title)
    
    y = 3
    shortcut = 'a'
    @items.each do |item|
      item.x = 6
      item.y = y
      Terminal.print(2, y, "(#{shortcut})")
      item.render(selected?(item))
      shortcut = shortcut.succ
      y += 1
    end
  end
  
  def update(key)
    super
    # This is a bit weird.
    # Terminal.read returns an integer. lib/BearLibTerminal.rb shows how key presses
    # are mapped to constants (Terminal::TK_A and so on). "a" is 4, so we subtract 4
    # to correct for that. `idx` gives us 0 for a, 1 for b, etc., so keys are
    # correctly mapped to items in the inventory array. 
    idx = key - 4
    if idx >= 0 and idx < @items.size
      @last_value = @items[idx]
      @done = true
    end
  end
end
    