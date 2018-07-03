require './lib/BearLibTerminal'
require './src/fov'
require './src/actor'
require './src/map'
require './src/rectangle'
require './config'

class Game
  attr_reader :player
  
  def setup
    Terminal.open
    Terminal.set("window.title = 'sample Ruby roguelike'")
    Terminal.set("font: assets/Fix15Mono-Bold.ttf, size=14x14")
    Terminal.set("window.size = #{Config::MAP_WIDTH}x#{Config::MAP_HEIGHT}")
    @actors = []
    
    @player = Actor.new(1, 1, '@', 'white')
    @actors << @player
    
    @map = Map.new(Config::MAP_WIDTH, Config::MAP_HEIGHT)
    
    @fov_recompute = true
    
    @map.do_fov(@player.x, @player.y, Config::FOV_RADIUS)
    
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
      actor.render if @map.is_lit?(actor.x, actor.y)
    end
  end
  
  def update
    dx, dy = 0, 0
    
    case @last_event
    when Terminal::TK_UP
      dy = -1
    when Terminal::TK_DOWN
      dy = 1
    when Terminal::TK_LEFT
      dx = -1
    when Terminal::TK_RIGHT
      dx = 1
    when Terminal::TK_CLOSE
      Terminal.close
      exit
    end
    
    unless (dx == 0 and dy == 0) or @map.is_wall?(@player.x + dx, @player.y + dy)
      @player.x += dx
      @player.y += dy
      @fov_recompute = true
    end
    
    if @fov_recompute
      @map.clear_lights
      @map.do_fov(@player.x, @player.y, Config::FOV_RADIUS)
    end
    
    @fov_recompute = false
  end
end

$game = Game.new
$game.setup