if arg[2] == "debug" then
    require("lldebugger").start()
end
-- Debug handler (end) from https://sheepolution.com/learn/book/bonus/vscode
-- I learned LOVE2D from this tutorial


function love.load()
    Object = require "classic" -- Classic library from https://github.com/rxi/classic
    local bump = require "bump" -- Bump library for collision from https://github.com/kikito/bump.lua
    world = bump.newWorld(64)
    require "player"
    player = Player(50, 50)
    world:add(player, player.x, player.y, player.width, player.height)
    solblock = {}
    luablock = {}
    world_state = 1
    require "ui"
    require "level"
    require "levels.1"
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
    player:update(dt)
end

function love.draw()
    level:draw()
    player:draw()
    drawUI()
end

function love.keypressed(key)
    player:keypressed(key)
end

function switchWorld()
    if world_state == 1 then
        world_state = 2
    elseif world_state == 2 then
        world_state = 1
    end
end