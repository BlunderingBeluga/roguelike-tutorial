require './lib/BearLibTerminal'
require './src/actor'
require './src/map'

class Game
  def initialize
    Terminal.open
    Terminal.set("window.title = 'sample Ruby roguelike'")
    Terminal.set("font: assets/Fix15Mono-Bold.ttf, size=8x16")
    @actors = []
    
    @player = Actor.new(40, 12, '@', 'white')
    @actors << @player
    
    @map = Map.new(80, 24)
    
    until @last_event == Terminal::TK_CLOSE
      Terminal.clear
      render
      Terminal.refresh
      @last_event = Terminal.read
      update
    end 
  end
  
  def render
    @map.render
    
    @actors.each do |actor|
      actor.render
    end
  end
  
  def update
    case @last_event
    when Terminal::TK_UP
      @player.y -= 1 unless @map.is_wall?(@player.x, @player.y - 1)
    when Terminal::TK_DOWN
      @player.y += 1 unless @map.is_wall?(@player.x, @player.y + 1)
    when Terminal::TK_LEFT
      @player.x -= 1 unless @map.is_wall?(@player.x - 1, @player.y)
    when Terminal::TK_RIGHT
      @player.x += 1 unless @map.is_wall?(@player.x + 1, @player.y)
    when Terminal::TK_CLOSE
      Terminal.close
      exit
    end
  end
end

Game.new