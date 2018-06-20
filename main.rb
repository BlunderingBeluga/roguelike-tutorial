require './lib/BearLibTerminal'

class Game
  def initialize
    Terminal.open
    Terminal.set("window.title = 'sample Ruby roguelike'")
    Terminal.set("font: assets/Fix15Mono-Bold.ttf, size=8x16")
    @player_x = 40
    @player_y = 12
    @last_event = nil
    
    until @last_event == Terminal::TK_CLOSE
      Terminal.clear
      render
      Terminal.refresh
      @last_event = Terminal.read
      update
    end 
  end
  
  def render
    Terminal.print(@player_x, @player_y, '@')
  end
  
  def update
    case @last_event
    when Terminal::TK_UP
      @player_y -= 1
    when Terminal::TK_DOWN
      @player_y += 1
    when Terminal::TK_LEFT
      @player_x -= 1
    when Terminal::TK_RIGHT
      @player_x += 1
    when Terminal::TK_CLOSE
      Terminal.close
      exit
    end
  end
end

Game.new