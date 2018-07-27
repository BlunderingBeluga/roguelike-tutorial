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
  
  MAX_ROOM_MONSTERS = 3
  MAX_ROOM_ITEMS = 2
  
  # how many turns monsters continue to chase players who have gone out of view
  TRACKING_TURNS = 3
end