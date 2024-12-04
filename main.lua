if arg[2] == "debug" then
    require("lldebugger").start()
end
-- Debug handler (end) from https://sheepolution.com/learn/book/bonus/vscode
-- I learned LOVE2D from this tutorial


function love.load()
    Object = require "libraries.classic" -- Classic library from https://github.com/rxi/classic
    local bump = require "libraries.bump" -- Bump library for collision from https://github.com/kikito/bump.lua
    lume = require "libraries.lume" -- Lume library for saving and loading files from https://github.com/rxi/lume
    
    require "assets"
    loadGraphics()
    loadAudio()
    
    require "settings"

    if love.filesystem.getInfo("controls.txt") then
        local control_file = love.filesystem.read("controls.txt")
        local data = lume.deserialize(control_file)

        if data.left ~= nil and data.right ~= nil and data.jump ~= nil and data.switch ~= nil then
            Left.key = data.left
            Right.key = data.right
            Jump.key = data.jump
            Swap.key = data.switch
        end
    end
    
    require "button"
    require "pause"
    require "player"
    require "ui"
    require "level"
    require "levels.1"

    world = bump.newWorld(64)
    player = Player(50, 50)
    
    world:add(player, player.x, player.y, player.width, player.height)
    solblock = {}
    luablock = {}
    world_state = 1
    mouse_state = love.mouse.isDown(1)
    
    
    for y, row in ipairs(level.tilemap) do
        for x, tile in ipairs(row) do
            if tile == 1 then
                world:add(x..","..y, x * 20 - 20, y * 20 - 20, 20, 20)
            elseif tile == 2 then
                world:add(x..","..y, x * 20 - 20, y * 20 - 20, 20, 20)
                table.insert(solblock, {name = x..","..y, x = x, y = y})
            elseif tile == 3 then
                world:add(x..","..y, x * 20 - 20, y * 20 - 20, 20, 20)
                table.insert(luablock, {name = x..","..y, x = x, y = y})
            end
        end
    end
end

function love.update(dt)
    if not paused then
        player:update(dt)
    else
        if mouse_state ~= love.mouse.isDown(1) and not love.mouse.isDown(1) then
            pauseClick()
        end
    end
    mouse_state = love.mouse.isDown(1)
end

function love.draw()
    love.graphics.setFont(Bahnschrift_sm)
    level:draw()
    player:draw()
    drawUI()
    if paused then
        drawPauseMenu()
    end
end

function love.keypressed(key)
    if not paused then
        player:keypressed(key)
    elseif key ~= "escape" then
        keyPressedWhilePaused(key)
    end
    if key == "escape" then
        if paused then
            Unpause:play()
            editing = nil
            
            local data = {}
            data.left = Left.key
            data.right = Right.key
            data.jump = Jump.key
            data.switch = Swap.key
            local txt_data = lume.serialize(data)
            love.filesystem.write("controls.txt", txt_data)

            paused = false
        else
            Pause:play()
            paused = true
        end
    end
end

function switchWorld()
    if world_state == 1 then
        world_state = 2
    elseif world_state == 2 then
        world_state = 1
    end
end