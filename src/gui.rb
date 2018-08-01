class Gui
  attr_accessor :log 
  
  def initialize(x, y)
    @log = []
    @x, @y = x, y
    @menu = nil
    @last_menu_value = nil
  end
  
  def clickable_menu(title, items)
    @menu = ClickableMenu.new(title, items)
    menu!
  end
  
  def arrow_key_menu(title, items)
    @menu = ArrowKeyMenu.new(title, items)
    menu!
  end
  
  def alphabet_menu(title, items)
    @menu = AlphabetMenu.new(title, items)
    menu!
  end
  
  def inventory_menu(title, items)
    @menu = InventoryMenu.new(title, items)
    menu!
  end
  
  def menu!
    loop do
      if @menu.done?
        @last_menu_value = @menu.retrieve_value
        @menu = nil
        break
      end
      Terminal.clear
      @menu.render
      Terminal.refresh
      # having Game#last_event occasionally be inaccurate has broken nothing (yet)
      key = Terminal.read 
      @menu.update(key)
    end
  end
  
  def last_menu_value
    @last_menu_value
  end
  
  def render
    render_bar(@x, @y, Config::Gui::BAR_WIDTH, 'HP', $game.player.destructible.hp,
      $game.player.destructible.max_hp, '255,115,115', '191,0,0')
    render_bar(@x, @y + 2, Config::Gui::BAR_WIDTH, "XP (#{$game.player.ai.xp_level})",
      $game.player.destructible.xp, $game.player.ai.next_level_xp, '185,115,255', '95,0,191')
      
    @log.each_with_index do |msg, y|
      Terminal.print(Config::Gui::MSG_X, y + @y, # FIXME: confusing variable names
        "[color=#{msg.color}]#{msg.text}[/color]")
    end
    
    Terminal.print(@x + 3, @y + 4, "Dungeon level #{$game.level}")
  end
  
  def message(text, color)
    if text.size >= Config::Gui::MSG_WIDTH
      lines = reformat_wrapped(text)
      lines.each do |line|
        message_line(line, color)
      end
    else
      message_line(text, color)
    end
  end
  
  private
  
  def message_line(text, color)
    if @log.size >= Config::Gui::MSG_HEIGHT
      @log.shift until @log.size == Config::Gui::MSG_HEIGHT - 1
    end
    
    @log << Message.new(text, color)
  end
  
  # From the Ruby Cookbook, 1.15: Word-Wrapping Lines of Text
  def reformat_wrapped(s, width = Config::Gui::MSG_WIDTH - 1)
  	  lines = []
  	  line = ""
  	  s.split(/\s+/).each do |word|
  	    if line.size + word.size >= width
  	      lines << line
  	      line = word
  	    elsif line.empty?
  	     line = word
  	    else
  	     line << " " << word
  	   end
  	   end
  	   lines << line if line
  	  return lines
  	end
  
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