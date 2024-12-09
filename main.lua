-- I learned LOVE2D from https://sheepolution.com/learn/book/bonus/vscode


function love.load()
    love.window.setTitle("Switchgate")
    love.graphics.setDefaultFilter( 'nearest', 'nearest' ) -- Suggested by https://github.com/kikito/gamera?tab=readme-ov-file#faq to remove blur

    Object = require "libraries.classic" -- Classic library from https://github.com/rxi/classic
    local bump = require "libraries.bump" -- Bump library for collision from https://github.com/kikito/bump.lua
    lume = require "libraries.lume" -- Lume library for saving and loading files from https://github.com/rxi/lume
    local gamera = require "libraries.gamera" -- Gamera library controls the camera from https://github.com/kikito/gamera
    
    -- Create camera to follow the player in the level
    cam = gamera.new(0, 0, 800, 600)
    camera_settings = {["x"]=-1, ["y"]=0, ["transition_x"]=0, ["trans_duration_x"]=0}

    -- Load all assets
    require "assets"
    loadGraphics()
    loadAudio()
    
    -- Load the settings
    require "settings"

    -- If there is a controls file, replace the current controls
    if love.filesystem.getInfo("controls.txt") then
        -- Read the file and deserialize it
        local control_file = love.filesystem.read("controls.txt")
        local data = lume.deserialize(control_file)

        -- If all of the correct data exists, swap the in game controls
        if data.left ~= nil and data.right ~= nil and data.jump ~= nil and data.switch ~= nil then
            Left.key = data.left
            Right.key = data.right
            Jump.key = data.jump
            Swap.key = data.switch
        end
    end
    
    -- Load all other scripts
    require "button"
    require "pause"
    require "player"
    require "ui"
    require "level"
    -- Load the level data
    require "levels.1"

    -- Create bump world for collision detection
    world = bump.newWorld(64)
    -- Spawn the player at the start of the level
    player = Player(28, 25)
    -- Set the switch-collision prevention warning to false by default
    warning = false
    -- Add the player to the world
    world:add(player, player.x, player.y, player.width, player.height)

    -- Create tables to hold the two phases of blocks
    solblock = {}
    luablock = {} -- This naming scheme is unrelated to the fact I am programming in Lua
    -- World state is 0 by default (0 = title screen, used once; 1 = Sol blocks collide with player, Lua blocks don't; 2 = opposite of that)
    world_state = 0
    -- Initialize the mouse_state variable do detect mouse left click
    mouse_state = love.mouse.isDown(1)
    
    -- Add the level to the bump world
    for y, row in ipairs(level.tilemap) do
        for x, tile in ipairs(row) do
            -- If the tile is a World tile (always collides), add it to the world
            if isWorld(tile) then
                world:add(x..","..y, x * 20 - 20, y * 20 - 20, 20, 20)
            -- If the tile is a Sol tile (collides when in Sol phase), add it to the world and the solblock table
            elseif isSol(tile) then
                world:add(x..","..y, x * 20 - 20, y * 20 - 20, 20, 20)
                table.insert(solblock, {name = x..","..y, x = x, y = y})
            -- If the tile is a Lua tile (collides when in Lua phase), add it to the world and the luablock table
            elseif isLua(tile) then
                world:add(x..","..y, x * 20 - 20, y * 20 - 20, 20, 20)
                table.insert(luablock, {name = x..","..y, x = x, y = y})
            end
        end
    end
end

function love.update(dt)
    -- Update the camera if not on the title screen
    if world_state ~= 0 then
        -- Set the camera position to centered on the player
        -- (Because of how the camera is set up, this only matters when zooming in)
        cam:setPosition(player.x + player.width/2, player.y + player.height/2)

        -- If the camera is not moving, check if the player is outside of the camera
        if camera_settings.transition_x == 0 then
            -- If player is too far right, trigger the right-moving transition
            if player.x > (camera_settings.x + 1) * 800 then
                camera_settings.transition_x = -1
                camera_settings.trans_duration_x = 1
                camera_settings.x = camera_settings.x + 1
            -- If player is too far left, trigger the left-moving transition
            elseif (player.x + player.width) < camera_settings.x * 800 then
                camera_settings.transition_x = 1
                camera_settings.trans_duration_x = 1
                camera_settings.x = camera_settings.x - 1
            end
        end
    end

    -- Set the camera world borders to keep the camera on the level
    cam:setWorld((camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 800, camera_settings.y * 800, 800, 600)

    -- Scale the camera based on the current switch meter charging status
    -- (Zoom in further if closer to switching)
    cam:setScale(((player.switch_meter - player.switch_meter_projection)/80)^2 + 1)

    -- If not paused, update the player's position
    if not paused then
        player:update(dt)
    -- If paused, check the mouse
    else
        if mouse_state ~= love.mouse.isDown(1) and not love.mouse.isDown(1) then
            pauseClick()
        end
    end
    -- Update the mouse_state variable
    mouse_state = love.mouse.isDown(1)

    -- If the camera is currently transitioning between level screens, update the transition timer
    if camera_settings.trans_duration_x > 0 then
        camera_settings.trans_duration_x = camera_settings.trans_duration_x - 1 * dt
    -- If not transitioning, set the transition status to 0
    else
        camera_settings.trans_duration_x = 0
        camera_settings.transition_x = 0
    end
end

function draw()
    -- Draw the level and player based on the world coordinates
    love.graphics.setFont(Bahnschrift_sm)
    level:draw()
    player:draw()
end

function love.draw()
    -- If world state 0, draw title screen
    love.graphics.setColor(1, 1, 1, 1)
    if world_state == 0 then
        love.graphics.draw(Title, 0, 0)
    end
    -- Draw things based on the world coordinates
    cam:draw(draw)
    -- Draw the UI (and pause menu) based on the screen coordinates (AKA follows the screen)
    drawUI()
    if paused then
        drawPauseMenu()
    end
end

-- If a key is pressed...
function love.keypressed(key)
    -- If the game is not paused, tell the player script to interpret the key press
    if not paused then
        player:keypressed(key)
    -- If the game is paused, but the button was not [ESC] then interpret the key press in the pause menu
    elseif key ~= "escape" then
        keyPressedWhilePaused(key)
    end

    -- If [ESC] was pressed, pause or unpause the game
    if key == "escape" then
        -- Unpause the game if it's already paused
        if paused then
            -- Play the unpause sound
            Unpause:play()
            -- Reset control editing status
            editing = nil
            -- Unpause
            paused = false
        -- Pause the game if it's not paused
        else
            -- Play the pause sound
            Pause:play()
            -- Pause
            paused = true
        end
    end
end

-- Functions to check of a tile is part of the World, Sol, Lua, or a Decoration
-- Can create false positives, but that would only happen if something happened during level creation
function isWorld(input)
    for i=1,30 do
        -- True if the tile is a number between 1-30 (i.e. 1, 2, 26, etc.)
        if input == tostring(i) then
            return true
        end
    end
    return false
end

function isSol(input)
    for i=1,30 do
        -- True if the tile is "a#", where # is 1-30 (i.e. a1, a2, a26, etc.)
        if input == "a"..i then
            return true
        end
    end
    return false
end

function isLua(input)
    for i=1,30 do
        -- True if the tile is "b#", where # is 1-30 (i.e. b1, b2, b26, etc.)
        if input == "b"..i then
            return true
        end
    end
    return false
end

function isDecor(input)
    for i=1,30 do
        -- Is decor if tile is "d#", where # is 1-30 (i.e. d1, d2, d26, etc.)
        -- Return a number based on the phase the decoration belongs to
        if input == "d"..i then
            -- If d1 - d10, then tile is world decor (always visible)
            if i >= 1 and i <= 10 then
                return 1
            -- If d11 - d20, then tile is Sol decor (only visible in Sol phase)
            elseif i >= 11 and i <= 20 then
                return 2
            -- If d21 - d30, then tile is Lua decor (only visible in Lua phase)
            elseif i >= 21 and i <= 30 then
                return 3
            end
        end
    end
    return 0
end

-- Switch the world phase
function switchWorld()
    -- If currently in Sol, switch to Lua
    if world_state == 1 then
        world_state = 2
    -- If currently in Lua, switch to Sol
    else
        world_state = 1
    end
end