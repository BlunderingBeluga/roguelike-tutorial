require './lib/BearLibTerminal'
require './config'
require './src/gui'
require './src/menu'
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
  attr_accessor :status, :fov_recompute, :done
  attr_reader :player, :map, :last_event, :actors, :gui, :stairs, :level
  
  def setup
    @actors = []
    
    @player = Actor.new(1, 1, '@', 'player', 'white', 1)
    @player.destructible = PlayerDestructible.new(player, 30, 2, 'your cadaver', 0)
    @player.attacker = Attacker.new(player, 5)
    @player.ai = PlayerAi.new(player)
    @player.container = Container.new(player, 26)
    add_actor(@player)
    
    @stairs = Actor.new(0, 0, '>', 'stairs', 'white', 4, false, false)
    add_actor(@stairs)
    
    @map = Map.new(Config::MAP_WIDTH, Config::MAP_HEIGHT)
    @level = 1
    
    @fov_recompute = true
    @done = false
    
    @map.do_fov(@player.x, @player.y, Config::FOV_RADIUS)
    
    @game_status = :idle
    @gui.message("Welcome, stranger! Prepare to perish!", 'green')
  end
  
  def load_game
    load_hash = {}
    File.open(Config::SAVE_FILE) do |f|
      load_hash = Marshal.load(f.read)
    end
    @actors = load_hash['actors']
    @gui = Gui.new(1, Config::MAP_HEIGHT)
    @gui.log = load_hash['log']
    @player = @actors[load_hash['player_idx']]
    @stairs = @actors[load_hash['stairs_idx']]
    @map = load_hash['map']
    @level = load_hash['level']
    @gui.message('Game loaded from save file.', 'orange')
  end
  
  def save
    save_hash = {}
    save_hash['actors'] = @actors
    save_hash['log'] = @gui.log
    save_hash['player_idx'] = @actors.index(@player)
    save_hash['stairs_idx'] = @actors.index(@stairs)
    save_hash['map'] = @map
    save_hash['level'] = @level
    File.open(Config::SAVE_FILE, 'w') do |f|
      f.write(Marshal.dump(save_hash))
    end
  end
  
  def save_exists?
    File.file?(Config::SAVE_FILE)
  end
  
  def shutdown
    Terminal.close
    exit
  end
  
  def run
    Terminal.open
    Terminal.set("window.title = 'sample Ruby roguelike'")
    Terminal.set("font: assets/Fix15Mono-Bold.ttf, size=14x14")
    Terminal.set("input.filter = [keyboard, mouse]")
    Terminal.set(
      "window.size = #{Config::WINDOW_WIDTH}x#{Config::WINDOW_HEIGHT}")
    @gui = Gui.new(1, Config::MAP_HEIGHT)
    @gui.clickable_menu("Sample Ruby Roguelike", ["New Game", "Load Game", "Quit"])
    if @gui.last_menu_value
      case @gui.last_menu_value.name
      when 'New Game'
        setup
      when 'Load Game'
        load_game if save_exists?
      when 'Quit'
        shutdown
      end
    else
      # close if ESCAPE is pressed in the startup menu
      shutdown
    end
    
    until @done == true
      Terminal.clear
      render
      Terminal.refresh
      @last_event = Terminal.read
      update
    end
    
    save
    shutdown 
  end
  
  def add_actor(actor)
    @actors << actor
    sort_actors
  end
  
  def sort_actors
    @actors.sort_by! { |a| a.priority }.reverse!
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
      orc = Actor.new(x, y, 'o', 'orc', 'green', 1)
      orc.destructible = MonsterDestructible.new(orc, 10, 0, 'dead orc', 35)
      orc.attacker = Attacker.new(orc, 3)
      orc.ai = MonsterAi.new(orc)
      add_actor(orc)
    else
      # create a troll
      troll = Actor.new(x, y, 'T', 'troll', '0,128,0', 1)
      troll.destructible = MonsterDestructible.new(troll, 16, 1, 'troll carcass', 100)
      troll.attacker = Attacker.new(troll, 4)
      troll.ai = MonsterAi.new(troll)
      add_actor(troll)
    end
  end
  
  def create_item(x, y)
    dice = rand(100)
    if dice < 70
      # create a health potion
      health_potion = Actor.new(x, y, '!', 'health potion', 'purple', 2, false)
      health_potion.pickable = Healer.new(health_potion, 4)
      add_actor(health_potion)
    elsif dice < 80
      # create a scroll of lightning bolt
      lightning_scroll = Actor.new(x, y, '#', 'scroll of lightning bolt', 'yellow', 2, false)
      lightning_scroll.pickable = LightningBolt.new(lightning_scroll, 5, 20)
      add_actor(lightning_scroll)
    elsif dice < 90
      # create a scroll of fireball
      fireball_scroll = Actor.new(x, y, '#', 'scroll of fireball', 'orange', 2, false)
      fireball_scroll.pickable = Fireball.new(fireball_scroll, 3, 12)
      add_actor(fireball_scroll)
    else
      # create a scroll of confusion
      confusion_scroll = Actor.new(x, y, '#', 'scroll of confusion', 'violet', 2, false)
      confusion_scroll.pickable = Confuser.new(confusion_scroll, 10, 8)
      add_actor(confusion_scroll)
    end
  end
  
  def render
    @map.render
    
    @actors.each do |actor|
      if @map.is_lit?(actor.x, actor.y)
        actor.render 
      elsif @map.is_explored?(actor.x, actor.y) and not actor.fov_only
        actor.render(false)
      end
    end
    
    @gui.render
  end
  
  def update
    @status = :idle
    
    @done = true if @last_event == Terminal::TK_CLOSE
    
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
  
  def next_level
    @level += 1
    @gui.message('You take a moment to rest, and recover your strength.', 'violet')
    @player.destructible.heal(@player.destructible.max_hp / 2)
    @gui.message('After a rare moment of peace, you descend deeper into the heart of the dungeon.',
      'red')
    
    @actors.clear
    add_actor(@player)
    add_actor(@stairs)
    
    @map = Map.new(Config::MAP_WIDTH, Config::MAP_HEIGHT)
    @fov_recompute = true
    @status = :new_turn
  end
end

$game = Game.new
$game.run