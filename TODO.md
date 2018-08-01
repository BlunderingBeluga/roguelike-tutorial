# TODO

## Bugfixes

* In general: things not seeming to realize properly what other things are in their spaces, such as:
    * Monsters walking on corpses mishandled
    * Items dropped onto corpses (or stairs) not being accessible
		* Player and monster spawning on same square
* Game can't be closed while inside a menu
* Confused carcasses still moving after death
* Healing potion on player with less than 4 HP of damage giving incorrect number for amount healed
* Canceling a targeted effect silently wastes a turn
* Level-up occurs one turn late

## Features

* Better documentation of how the menu system works
* Auto-switch equipped items (attempting to equip an item to a full slot)
* Less awkward way to store specs for monsters and items
