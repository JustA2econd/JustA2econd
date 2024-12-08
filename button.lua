-- Create UI button class
Button = Object:extend()

-- Each button has a click function, x/y coordinates, width, height, and text offsets
function Button:new(click_function, x, y, width, height, text_offset_x, text_offset_y)
    self.click_function = click_function
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text_offset_x = text_offset_x
    self.text_offset_y = text_offset_y
end

-- Function to draw a button
function Button:draw(text)
    -- Draw a white rectangle for the buton
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    -- Print black text for button text
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(text, self.x + self.text_offset_x, self.y + self.text_offset_y)
end