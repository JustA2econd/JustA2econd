-- Disable Vsync to make the built game less stuttery
function love.conf(t)
    t.window.vsync = 0
end