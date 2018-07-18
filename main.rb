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
    Terminal.set("input.filter = [keyboard, mouse]")
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
    dice = rand(100)
    if dice < 70
      # create a health potion
      health_potion = Actor.new(x, y, '!', 'health potion', 'purple', false)
      health_potion.pickable = Healer.new(health_potion, 4)
      @actors << health_potion
    elsif dice < 80
      # create a scroll of lightning bolt
      lightning_scroll = Actor.new(x, y, '#', 'scroll of lightning bolt', 'yellow', false)
      lightning_scroll.pickable = LightningBolt.new(lightning_scroll, 5, 20)
      @actors << lightning_scroll
    elsif dice < 90
      # create a scroll of fireball
      fireball_scroll = Actor.new(x, y, '#', 'scroll of fireball', 'orange', false)
      fireball_scroll.pickable = Fireball.new(fireball_scroll, 3, 12)
      @actors << fireball_scroll
    else
      # create a scroll of confusion
      confusion_scroll = Actor.new(x, y, '#', 'scroll of confusion', 'violet', false)
      confusion_scroll.pickable = Confuser.new(confusion_scroll, 10, 8)
      @actors << confusion_scroll
    end
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
  
  def distance_between(x1, y1, x2, y2)
    dx = x2 - x1
    dy = y2 - y1
    Math.sqrt(dx * dx + dy * dy)
  end
  
  def closest_monster(x, y, range)
    closest = nil
    best_distance = 1000
    @actors.each do |actor|
      if actor != @player and actor.destructible and not actor.destructible.is_dead?
        distance = distance_between(actor.x, actor.y, x, y)
        if distance < best_distance and (distance <= range or range == 0)
          best_distance = distance
          closest = actor
        end
      end
    end
    closest
  end
  
  def mouse_x
    Terminal.state(Terminal::TK_MOUSE_X)
  end
  
  def mouse_y
    Terminal.state(Terminal::TK_MOUSE_Y)
  end

  def pick_a_tile(max_range)
    loop do
      Terminal.clear
      # print green square if mouse is in range, red otherwise
      if @map.is_lit?(mouse_x, mouse_y) and (max_range == 0 or
        distance_between(@player.x, @player.y, mouse_x, mouse_y) <= max_range)
        Terminal.print(mouse_x, mouse_y, "[bkcolor=green] [/bkcolor]")
      else
        Terminal.print(mouse_x, mouse_y, "[bkcolor=red] [/bkcolor]")
      end
      render
      Terminal.refresh
      key = Terminal.read
      if key == Terminal::TK_MOUSE_LEFT
        return [mouse_x, mouse_y]
      elsif key == Terminal::TK_MOUSE_RIGHT
        return false
      elsif key == Terminal::TK_CLOSE
        Terminal.close
        exit
      end
    end
  end
end

$game = Game.new
$game.setup