class Gui
  attr_accessor :log 
  
  def initialize(x, y)
    @log = []
    @x, @y = x, y
    @menu = nil
    @menu_handler = nil
    @last_menu_value = nil
  end
  
  # About the use of Gui#menu:
  # The block will be called every time a key is pressed while the menu is open
  # with the Gui itself passed as a parameter
  # for instance:
  # Gui.menu("Inventory", ["sword", "lantern", "ration"]) do |gui|
  #   (do something with the Gui)
  # end
  # This means you can access Gui#last_menu_value, Gui#close, etc. in response
  # to the key press.
  def menu(title, items, &block)
    @menu = Menu.new(title, items)
    @menu_handler = block
  end
  
  def menu?
    !!@menu
  end
  
  def last_menu_value
    return false unless @menu or @last_menu_value
    return @last_menu_value unless @menu
    val = @menu.retrieve_value
    if val
      @last_menu_value = val
    end
    return @last_menu_value
  end
  
  def update
    close_menu if $game.last_event == Terminal::TK_ESCAPE
    @menu.update if menu?
    @menu_handler.call(self)
  end
  
  def close_menu
    @last_menu_value = nil
    @menu = nil
    @menu_handler = nil
  end
  
  def render
    if menu?
      @menu.render
      return
    end
    
    render_bar(@x, @y, Config::Gui::BAR_WIDTH, 'HP', $game.player.destructible.hp,
      $game.player.destructible.max_hp, '255,115,115', '191,0,0')
      
    @log.each_with_index do |msg, y|
      Terminal.print(Config::Gui::MSG_X, y + @y, # FIXME: confusing variable names
        "[color=#{msg.color}]#{msg.text}[/color]")
    end
  end
  
  def message(text, color)
    if @log.size >= Config::Gui::MSG_HEIGHT
      @log.shift until @log.size == Config::Gui::MSG_HEIGHT - 1
    end
    
    @log << Message.new(text, color)
  end
  
  private
  
  def render_bar(x, y, width, name, value, max_value, bar_color, back_color)
    background = "[bkcolor=#{back_color}] [/bkcolor]" * width
    Terminal.print(x, y, background)
    
    bar_width = ((value.to_f / max_value) * width).to_i
    if bar_width > 0
      foreground = "[bkcolor=#{bar_color}] [/bkcolor]" * bar_width
      Terminal.print(x, y, foreground)
    end
    
    data = "#{name}: #{value}/#{max_value}"
    Terminal.print(x + (width / 2) - (data.size / 2), y, data)
  end
end

class Message
  attr_reader :text, :color
  
  def initialize(text, color)
    @text, @color = text, color
  end
end