class Gui
  def initialize(x, y)
    @log = []
    @x, @y = x, y
  end
  
  def render
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