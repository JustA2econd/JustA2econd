if arg[2] == "debug" then
    require("lldebugger").start()
end
-- Debug handler (end)


function love.load()
    player = {}
    player.x = 100
    player.y = 100
    player.speed_x = 0
    player.speed_y = 0
end

function love.update(db)
    if love.keyboard.isDown("right") and not love.keyboard.isDown("left") then
        player.speed_x = player.speed_x + 1000 * db
    elseif love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
        player.speed_x = player.speed_x - 1000 * db
    else
        if player.speed_x >= 10 then
            player.speed_x = player.speed_x - 1500 * db
        elseif player.speed_x <= -10 then
            player.speed_x = player.speed_x + 1500 * db
        else
            player.speed_x = 0
        end
    end

    if love.keyboard.isDown("up") then
        player.speed_y = -400
    end

    if player.speed_x >= 500 then
        player.speed_x = 500
    elseif player.speed_x <= -500 then
        player.speed_x = -500
    end
    player.x = player.x + player.speed_x * db
    player.y = player.y + player.speed_y * db
    player.speed_y = player.speed_y + 500 * db

end

function love.draw()
    love.graphics.rectangle("fill", player.x, player.y, 100, 100)
    love.graphics.print("speed_x = " .. player.speed_x, 20, 20)
    love.graphics.print("speed_y = " .. player.speed_y, 20, 40)
end


-- Error handler
local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
---@diagnostic disable-next-line: undefined-global
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end