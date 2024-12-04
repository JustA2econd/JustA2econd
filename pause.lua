paused = false
editing = nil

local left_edit = function ()
    editing = Left
end
local right_edit = function ()
    editing = Right
end
local jump_edit = function ()
    editing = Jump
end
local switch_edit = function ()
    editing = Swap
end
left_button = Button(left_edit, 140, 180, 580, 49, 10, 5)
right_button = Button(right_edit, 140, 240, 580, 49, 10, 5)
jump_button = Button(jump_edit, 140, 300, 580, 49, 10, 5)
switch_button = Button(switch_edit, 140, 360, 580, 49, 10, 5)

buttons = {left_button, right_button, jump_button, switch_button}

for i, control in ipairs(controls) do
    local func = function ()
        editing = control
    end
    table.insert(buttons, Button(func, 140, 120 + (i * 60), 580, 49, 10, 5))
end

function pauseClick()
    local x, y = love.mouse.getPosition()
    for i, button in ipairs(buttons) do
        if x >= button.x and x <= button.x + button.width and y >= button.y and y <= button.y + button.height then
            button.click_function()
            return
        end
    end
    editing = nil
    return
end

function keyPressedWhilePaused(key)
    if editing then
        editing.key = key
        editing = nil
    end
end

function drawPauseMenu()
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("PAUSED", Bahnschrift_lg, 80, 60)
    for i, control in ipairs(controls) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(control.image, 80 + control.image:getWidth() / 2, 120 + (i * 60) + control.image:getHeight() / 2, control.image_rotate, 1, 1, control.image:getWidth() / 2, control.image:getHeight() / 2)
        
        if editing == control then
            buttons[i]:draw("editing")
        else
            buttons[i]:draw(string.upper(control.key))
        end
    end
end