# Ruby Roguelike

![/r/roguelikedev does the Complete Roguelike Tutorial](https://i.imgur.com/EYJFgdI.png)

Here can be found my attempts to follow along with [/r/roguelikedev](https://www.reddit.com/r/roguelikedev/)'s 2018 dev-along for the [Complete Roguelike Tutorial](http://rogueliketutorials.com/libtcod/1). I'll be porting it to Ruby and [BearLibTerminal](http://foo.wyrd.name/en:bearlibterminal).

## Running

Make sure you have Ruby installed properly.

This _should_ run on Windows, Linux, and OS X.

Clone the repo:

    git clone https://github.com/BlunderingBeluga/roguelike-tutorial

and run `ruby main.rb`. To be able to use the debug menus, run `ruby -d main.rb` instead.

## Controls

Arrow keys: move   
G: pick up an item  
I: view inventory  
D: drop an item  
CTRL-D (with `ruby -d main.rb`): debug menu, spawn items and monsters
\>: go down
