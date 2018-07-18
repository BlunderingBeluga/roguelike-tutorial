# TODO

## Bugfixes

* Mishandling of corpses stacked on top of items (attempting to grab corpse, therefore preventing player from picking up item)
* Check if monsters walking on corpses and/or monsters walking on items are mishandled

## Features

* `Menu` class and debug menu to spawn items & monsters
* Improve display of items with range (`Game#pick_a_tile`) (less garish colors, show the affected area of area effects)
* Allow overly long log messages to wrap