Button = Object:extend()

function Button:new(click_function, x, y, width, height, text_offset_x, text_offset_y)
    self.click_function = click_function
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text_offset_x = text_offset_x
    self.text_offset_y = text_offset_y
end

function Button:draw(text)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(text, self.x + self.text_offset_x, self.y + self.text_offset_y)
end