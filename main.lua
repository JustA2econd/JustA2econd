if arg[2] == "debug" then
    require("lldebugger").start()
end
-- Debug handler (end)


function love.load()

end

function love.update()

end

function love.draw()
    love.graphics.rectangle("line", 100, 100, 100, 100)
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