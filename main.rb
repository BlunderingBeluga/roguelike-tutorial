require './lib/BearLibTerminal'
require './src/fov'
require './src/actor'
require './src/map'
require './src/rectangle'
require './config'

class Game
  attr_reader :player, :map
  
  def setup
    Terminal.open
    Terminal.set("window.title = 'sample Ruby roguelike'")
    Terminal.set("font: assets/Fix15Mono-Bold.ttf, size=14x14")
    Terminal.set("window.size = #{Config::MAP_WIDTH}x#{Config::MAP_HEIGHT}")
    @actors = []
    
    @player = Actor.new(1, 1, '@', 'you', 'white')
    @actors << @player
    
    @map = Map.new(Config::MAP_WIDTH, Config::MAP_HEIGHT)
    
    @fov_recompute = true
    
    @map.do_fov(@player.x, @player.y, Config::FOV_RADIUS)
    
    @game_status = :idle
    
    until @last_event == Terminal::TK_CLOSE
      Terminal.clear
      render
      Terminal.refresh
      @last_event = Terminal.read
      update
    end 
  end
  
  def actor_occupying(x, y)
    @actors.each do |actor|
      if actor.x == x and actor.y == y
        return actor
      end
    end
    false
  end
  
  def create_monster(x, y)
    rng = rand(100)
    if rng < 80
      # create an orc
      @actors << Actor.new(x, y, 'o', 'orc', 'green')
    else
      # create a troll
      @actors << Actor.new(x, y, 'T', 'troll', '0,128,0')
    end
  end
  
  def render
    @map.render
    
    @actors.each do |actor|
      actor.render if @map.is_lit?(actor.x, actor.y)
    end
  end
  
  def update
    @status = :idle
    
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
    
    unless (dx == 0 and dy == 0)
      @status = :new_turn
      @fov_recompute = true if @player.move_or_attack(dx, dy)
    end
    
    if @status == :new_turn
      @actors.each do |actor|
        if @map.is_lit?(actor.x, actor.y) and actor != @player
          actor.update
        end
      end
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