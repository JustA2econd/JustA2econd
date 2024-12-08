-- Set pause variables
paused = false
editing = nil
buttons = {}

-- Set button functions
local exit = function()
    love.event.quit(0)
end
local reset = function()
    love.event.quit("restart")
end

-- Set button functions for controls
for i, control in ipairs(controls) do
    local func = function ()
        editing = control
    end
    -- Add control buttons to buttons table
    table.insert(buttons, Button(func, 140, 120 + (i * 60), 580, 49, 10, 5))
end

-- Create exit and reset button
table.insert(buttons, Button(exit, 140, 420, 285, 49, 10, 5))
table.insert(buttons, Button(reset, 435, 420, 285, 49, 10, 5))

-- Check if the player clicked on a button
function pauseClick()
    local x, y = love.mouse.getPosition()
    for i, button in ipairs(buttons) do
        -- If a button was clicked, do the button's function
        if x >= button.x and x <= button.x + button.width and y >= button.y and y <= button.y + button.height then
            button.click_function()
            return
        end
    end
    -- If no button was clicked, reset editing status
    editing = nil
end

-- If a button was pressed while the game is paused, handle it
function keyPressedWhilePaused(key)
    -- If editing a keybind,
    if editing then
        -- Set the current keybind to the key pressed
        editing.key = key
        -- Reset editing status
        editing = nil
         -- Get the current selected control scheme
         local data = {}
         data.left = Left.key
         data.right = Right.key
         data.jump = Jump.key
         data.switch = Swap.key
         -- Save the controls to a file, so that it is returned when the game starts again
         local txt_data = lume.serialize(data)
         love.filesystem.write("controls.txt", txt_data)
    end
end

-- Draw the pause menu
function drawPauseMenu()
    -- Create a transparent overlay over the rest of the screen
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    -- Print large white text that says "PAUSED"
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("PAUSED", Bahnschrift_lg, 80, 60)
    -- For each control button...
    for i, control in ipairs(controls) do
        -- Draw the control's image
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(control.image, 80 + control.image:getWidth() / 2, 120 + (i * 60) + control.image:getHeight() / 2, control.image_rotate, 1, 1, control.image:getWidth() / 2, control.image:getHeight() / 2)
        -- If editing the control, then say "editing"
        if editing == control then
            buttons[i]:draw("editing")
        -- Otherwise, show the keybind
        else
            buttons[i]:draw(string.upper(control.key))
        end
    end
    -- Draw the exit and restart buttons
    buttons[5]:draw("EXIT")
    buttons[6]:draw("RESTART")
end