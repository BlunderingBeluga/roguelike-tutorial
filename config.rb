module Config
  MAP_WIDTH = 60
  MAP_HEIGHT = 35
  
  module Gui
    PANEL_HEIGHT = 7
    BAR_WIDTH = 20 # width of health, mana, etc. display bars
    MSG_X = BAR_WIDTH + 2
    MSG_HEIGHT = PANEL_HEIGHT - 1
    MSG_WIDTH = MAP_WIDTH - MSG_X
  end
  
  SAVE_FILE = './save'
  
  ROOM_MAX_SIZE = 10
  ROOM_MIN_SIZE = 6
  MAX_ROOMS = 30 # you won't get that many, ROOM_TRIES is more accurate
  
  WINDOW_WIDTH = MAP_WIDTH
  WINDOW_HEIGHT = MAP_HEIGHT + Gui::PANEL_HEIGHT
  
  FOV_RADIUS = 8
  
  MONSTER_CAPS_BY_LEVEL = { 2 => 1, 3 => 4, 5 => 6 }
  ITEM_CAPS_BY_LEVEL = { 1 => 1, 2 => 4 }
  
  # how many turns monsters continue to chase players who have gone out of view
  TRACKING_TURNS = 3
  
  # Specifications for monsters and items, including their frequencies of appearance
  module ActorSpecs
    def self.monster_names
      {
        orc: 80,
        troll: RNGUtilities.from_level({ 15 => 3, 30 => 5, 60 => 7 }, $game.level)
      }
    end
    
    def self.monster(name)
      case name
      when :orc
        orc = Actor.new(1, 1, 'o', 'orc', 'green', 1)
        orc.destructible = MonsterDestructible.new(orc, 20, 0, 'dead orc', 35)
        orc.attacker = Attacker.new(orc, 4)
        orc.ai = MonsterAi.new(orc)
        return orc
      when :troll
        troll = Actor.new(1, 1, 'T', 'troll', '0,128,0', 1)
        troll.destructible = MonsterDestructible.new(troll, 30, 2, 'troll carcass', 100)
        troll.attacker = Attacker.new(troll, 8)
        troll.ai = MonsterAi.new(troll)
        return troll
      end
    end
    
    def self.item_names
      {
        health_potion: 35,
        confusion_scroll: RNGUtilities.from_level({ 10 => 2 }, $game.level),
        lightning_scroll: RNGUtilities.from_level({ 25 => 4 }, $game.level),
        fireball_scroll: RNGUtilities.from_level({ 25 => 6 }, $game.level)
      }
    end
    
    def self.item(name)
      case name
      when :health_potion
        health_potion = Actor.new(1, 1, '!', 'health potion', 'purple', 2, false)
        health_potion.pickable = Healer.new(health_potion, 40)
        return health_potion
      when :confusion_scroll
        confusion_scroll = Actor.new(1, 1, '#', 'scroll of confusion', 'violet', 2, false)
        confusion_scroll.pickable = Confuser.new(confusion_scroll, 10, 8)
        return confusion_scroll
      when :lightning_scroll
        lightning_scroll = Actor.new(1, 1, '#', 'scroll of lightning bolt', 'yellow', 2, false)
        lightning_scroll.pickable = LightningBolt.new(lightning_scroll, 5, 40)
        return lightning_scroll
      when :fireball_scroll
        fireball_scroll = Actor.new(1, 1, '#', 'scroll of fireball', 'orange', 2, false)
        fireball_scroll.pickable = Fireball.new(fireball_scroll, 3, 25)
        return fireball_scroll
      end
    end
  end
end