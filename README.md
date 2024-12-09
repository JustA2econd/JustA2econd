# Switchgate 
#### Video Demo: [https://youtu.be/H66CubGSiTw](https://youtu.be/H66CubGSiTw) 
#### Description: 
Switchgate is a 2D platformer made in the LOVE framework for Lua. Its main mechanic is the switch system, which changes what blocks the player can touch. 
 
## Files 
### main.lua 
This is the main script for the whole program. LOVE uses three main functions to run the program: 
 
- love.load, which runs once when the program starts, 
- love.update, which runs every frame to calculate all the game physics, and 
- love.draw, which runs every frame to draw everything to the screen. 
 
I have written more functions in this file to make certain game systems easier. 
 
In the love.load function, I set the title of the window, open libraries, load assets, and create all the game objects. The load function also reads a file called “controls.txt”, if it exists, to get the user’s preferences for their control scheme. 
 
The game uses four libraries. The Classic library is used for creating objects. Objects can have properties and scripts, and it is possible to create several of the same object. The Bump library handles collision and can even give certain objects in a collision world certain collision rules. The Lume library saves and loads files, and it is mainly used for saving and reading the controls.txt file. The final library, Gamera, handles moving the camera. Things drawn in the camera are essentially moving with the world, and anything drawn outside the camera follows the screen. 
 
The entire level is loaded at startup into a bump collision world using a tilemap, and each kind of tile can be added to one of two tables: 
 
- solblock, which keeps track of Sol blocks, and 
- luablock, which tracks Lua blocks. 
- A World block is not added to either table. 
 
The love.update function handles moving the camera, detecting clicks on the pause menu, and calling player.lua’s update function. The level is split up into several screen-sized chunks. If the player moves out of the camera’s view into another screen, this function will start moving the camera to the next screen. The function also zooms in to the player if they are charging a world switch. 
 
The draw function, *different from the love.draw function*, is defined to tell the camera what to draw. It’s a small function, only setting a default font, calling level.lua’s draw function, and the player.lua draw function. 
 
love.draw is where the actual drawing happens. It draws the title screen when it’s supposed to, tells the camera to run its draw function, and draws the UI that shows the player’s current switch meter. If the game is paused, love.draw also tells the pause menu to draw itself. 
 
LOVE has a function that handles what happens if the player presses a key. If the game was not paused, the player script is told to see if the pressed key does anything. If the game was paused, but something other than ESC was pressed, then the pause menu handles it. If ESC was pressed, at any point, the game will pause or unpause. 
 
Several functions were defined here to check whether a certain tile in the level belonged to a specific world state. isWorld returns true if the tile is a World block, isSol and isLua returns true if the tile is either a Sol block or a Lua block, and isDecor returns a number based on its world state if it is a decoration. 
 
The last function in main.lua, switchWorld, switches the world state between 1 (Sol) and 2 (Lua). The game starts at world state 0, which is used for the title screen. If the world is switched while world state is 0, it goes to 1, starting the game. 
 
The next scripts will be described in the order they are loaded in love.load. 
 
### assets.lua 
 
assets.lua contains two functions, loadGraphics and loadAudio. These are both called at the same time during program startup. 
 
loadGraphics loads two font objects. Both use the font Bahnschrift, but they have different sizes (30pt and 100pt). Next, it loads the title screen image, then all of the character sprites. The player character is split into two parts. The body of the character is drawn in its default colors. The outline and feet of the character are drawn on their own, matching the color of the current world state. The feet are the main thing that are animated on the character. 
 
The function then loads the level tile sprites. It goes through a number range of 1-30 and detects if the corresponding image files exist. If they do, it will load the images, once for the World tiles, and once for Special tiles, or Sol and Lua tiles. It is also checked if the corresponding Decor image exists and loads it if it does. If any image doesn’t exist, a placeholder image is loaded instead. This is done to prevent crashes if the wrong tile is used, and because of the way tiles are loaded in the level. Not every number in between 1-30 has a tile, but since the tile images are picked from a table, placeholders are used to make sure each tile is still in its corresponding space. Finally, the pause menu control icons are loaded. 
 
loadAudio loads all of the sound effects into the game. I generated all of the sound effects using [jsfxr (sfxr.me)](https://sfxr.me/), a website that generates 8-bit sounds. Most of the sound effects are used by the player or switch meter, except for the Pause and Unpause sound effects. 
 
### settings.lua 
 
The settings.lua script just creates a class to hold each control scheme. Control objects have: 
 
- ID, a unique number 1-4, 
- key, which is the specific key the user presses to activate the control, 
- image, which is the image used on the pause menu, and 
- image_rotate, the radians to rotate the image on the pause menu. 
 
This script also creates the default control scheme for the game, including controls for moving left, moving right, jumping, and switching. The control scheme is usually replaced by the controls.txt file. 
 
### button.lua 
 
button.lua creates the button class. LOVE doesn’t have on screen buttons built-in, so I wrote this script to create a simple button. Each button has a click function, which runs when the button is clicked in the pause menu, x and y coordinates, a height and width, and a text offset to show the button text correctly. 
 
Each button also has a very simple draw function. Each button is drawn as a white rectangle at the buttons coordinates with the correct width and height, and then the button’s text is printed in black with the text offset. 
 
### pause.lua 
 
This script handles all of the pause menu functions. First, when the script is loaded, every button is loaded with its parameters into a table. The control buttons are created with functions to edit the controls when they are clicked. Then, exit and reset buttons are added to close or restart the game. 
 
The pauseClick function checks where the mouse clicks if the game is paused. If the mouse clicked on one of the buttons, its function is executed. If no button was clicked on, any control scheme edits are canceled. 
 
keyPressedWhilePaused determines what to do if a keyboard key is pressed while paused. If a control scheme is being edited, it should be set to the button that was pressed. Then, the controls are saved to controls.txt so that the control scheme stays the same when the game is restarted. 
 
The drawPauseMenu function displays the pause menu. A transparent black overlay is created to make the pause menu stand out in front of the rest of the game. Then, text displaying “PAUSED” is shown in a big font, and then all the buttons are drawn. 
 
### player.lua 
 
player.lua creates a Player class and defines a lot of functions for the game mechanics. Player objects have many properties: 
 
- x and y coordinates, 
- direction (-1 or 1 for left and right), 
- width and height, 
- directional speed (x and y), 
- various switch meter properties, 
- walljump height, which decreases over time, 
- step, which is used for footsteps, 
- and some other properties. 
 
The player’s update function handles collision and moving the character based on the user’s input. Is the Switch key is held, the game will try to charge the switch meter. A switch takes 1 second to fully charge. The meter will not fully charge if the player is inside of a block of the opposite phase. This prevents the player from switching into a position they would be pushed out of. If a switch is charged, the meter should start decreasing and the world state should be switched. If space is not being pressed, the meter should be recharging. 
 
Next, the player should be affected by gravity, and the player should accelerate left or right if they are holding one of the movement buttons. Then, the player’s direction should be determined based on their speed. If the player is moving to the left, they should face the left. Then, slow down the player if they are going too fast. Next, If the user presses jump while on the ground, the player should jump. 
 
Next, update the position of the player based on their speed. Afterwards, check for collisions. If the player collides with a wall, stop them from moving into it. If they are running into the wall midair, they should slide down the wall. If they hit a floor, they should be marked as on the ground. 
 
After checking if the player is on the ground, the step variables are updated. If the player is running on the ground, they should take a step, which plays a footstep sound and switches the player’s running sprite. Finally, the player should not be affected by gravity if they are on the ground. 
 
The player’s draw function first checks if the player is being prevented from switching due to potential collision with the other world state’s tiles. If they are, the player will be drawn differently to allow the user to see which tiles are blocking them. Then, the player body is drawn at the player’s coordinates. The body sprite itself does not change. The player’s outline and feet are then drawn at the coordinates based on the player’s current state. If they are running, the running sprites should be drawn. If they are midair, the player should be drawn accordingly. 
 
A separate player function, keypressed, handles wall jumping. If the player is currently sliding on a wall, they can press the jump button to do a wall jump. When they do, the wall jump height is decreased until they hit the ground to prevent the player from skipping levels entirely by climbing up the wall. 
 
checkOtherState is the function that detects when the player would collide with a block if they switched. If the world is currently Sol, then the player can pass through Lua blocks, and vice versa. This function detects if they are currently inside of a block on the other world state. 
 
### ui.lua 
 
This script simply draws the switch meter at the top of the screen with a collection of rectangles. If the switch meter is full, the meter on screen will also be full. Otherwise, the meter will take up part of the UI container depending on how full the switch meter is. If the player is switching, a red rectangle shows the player’s current charge progress. If they are being prevented from switching, a warning flashes on the meter. 
 
### level.lua 
 
level.lua creates a level class that contains a tilemap. The tilemap is loaded into a level object at the beginning of the game. 
 
The draw function draws the current level. If a tile is a World tile or is part of the current world state, it is drawn onto the screen. If it is part of the opposite world state, it is only drawn if it is close by. Tiles are also only drawn if the camera is in the position to draw it. The script draws the level in a certain order. First, decorations are drawn.  Decorations can be World, Sol, or Lua, just like the other tiles. Then, tiles of the opposite world state are drawn nearby, and then World and current world state tiles are drawn. 
 
World tiles have their own sprites based on their value. Each tile value is based on its position to other tiles. Tiles can be edges, corners, or in the middle of big blocks. Sol and Lua tiles share their sprites but are colored beforehand by the level script to distinguish them from each other. 
 
### levels/___.lua 
 
Levels are loaded as Lua scripts defining a tilemap, which is basically a list of lists. Each tile on the tilemap has a value that determines what it looks like and it’s behaviors. There are currently two levels in this folder, 1.lua and test.lua, but only 1.lua is accessible in game. 1.lua is the main level of the game. test.lua is a small, 1 screen large level that was made to test the basic game mechanics. 