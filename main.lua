if arg[2] == "debug" then
    require("lldebugger").start()
end
-- Debug handler (end) from https://sheepolution.com/learn/book/bonus/vscode
-- I learned LOVE2D from this tutorial


function love.load()
    Object = require "classic" -- Classic library from https://github.com/rxi/classic
    require "player"
    player = Player(50, 50)
end

function love.update(dt)
    player:update(dt)
end

function love.draw()
    player:draw()
    love.graphics.print("speed_x = " .. player.speed_x, 20, 20)
    love.graphics.print("speed_y = " .. player.speed_y, 20, 40)
end