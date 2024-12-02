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
    require "level"
    require "levels.1"
    for y, row in ipairs(level.tilemap) do
        for x, tile in ipairs(row) do
            if tile == 1 then
                world:add(x..","..y, x * 20 - 20, y * 20 - 20, 20, 20)
            end
        end
    end
end

function love.update(dt)
    player:update(dt)
end

function love.draw()
    player:draw()
    level:draw()
end

function love.keypressed(key)
    player:keypressed(key)
end