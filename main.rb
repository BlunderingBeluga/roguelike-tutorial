require './lib/BearLibTerminal'
require './config'
require './src/gui'
require './src/fov'
require './src/actor'
require './src/destructible'
require './src/ai'
require './src/pickable'
require './src/container'
require './src/attacker'
require './src/map'
require './src/rectangle'


class Game
  attr_accessor :status, :fov_recompute
  attr_reader :player, :map, :last_event, :actors, :gui
  
  def setup
    Terminal.open
    Terminal.set("window.title = 'sample Ruby roguelike'")
    Terminal.set("font: assets/Fix15Mono-Bold.ttf, size=14x14")
    Terminal.set(
      "window.size = #{Config::MAP_WIDTH}x#{Config::MAP_HEIGHT + Config::Gui::PANEL_HEIGHT}")
    
    @gui = Gui.new(1, Config::MAP_HEIGHT)
    @actors = []
    
    @player = Actor.new(1, 1, '@', 'player', 'white')
    @player.destructible = PlayerDestructible.new(player, 30, 2, 'your cadaver')
    @player.attacker = Attacker.new(player, 5)
    @player.ai = PlayerAi.new(player)
    @player.container = Container.new(player, 26)
    
    @map = Map.new(Config::MAP_WIDTH, Config::MAP_HEIGHT)
    @actors << @player # player must be first in list to render on top
    
    @fov_recompute = true
    
    @map.do_fov(@player.x, @player.y, Config::FOV_RADIUS)
    
    @game_status = :idle
    @gui.message("Welcome, stranger! Prepare to perish!", 'green')
    
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
      orc = Actor.new(x, y, 'o', 'orc', 'green')
      orc.destructible = MonsterDestructible.new(orc, 10, 0, 'dead orc')
      orc.attacker = Attacker.new(orc, 3)
      orc.ai = MonsterAi.new(orc)
      @actors << orc
    else
      # create a troll
      troll = Actor.new(x, y, 'T', 'troll', '0,128,0')
      troll.destructible = MonsterDestructible.new(troll, 16, 1, 'troll carcass')
      troll.attacker = Attacker.new(troll, 4)
      troll.ai = MonsterAi.new(troll)
      @actors << troll
    end
  end
  
  def create_item(x, y)
    health_potion = Actor.new(x, y, '!', 'health potion', 'purple', false)
    health_potion.pickable = Healer.new(health_potion, 4)
    @actors << health_potion
  end
  
  def render
    @map.render
    
    @actors.each do |actor|
      actor.render if @map.is_lit?(actor.x, actor.y)
    end
    
    @gui.render
  end
  
  def update
    @status = :idle
    
    @player.update
    if @status == :new_turn
      @actors.each do |actor|
        actor.update if actor != @player
      end
    end
    
    if @fov_recompute
      @map.clear_lights
      @map.do_fov(@player.x, @player.y, Config::FOV_RADIUS)
    end
    
    @fov_recompute = false
  end
  
  def send_to_back(actor)
    @actors.delete(actor)
    @actors.insert(0, actor)
  end
end

$game = Game.new
$game.setup