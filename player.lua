Player = Object:extend()

function Player:new(x, y)
    self.x = x
    self.y = y
    self.width = 50
    self.height = 50
    self.speed_x = 0
    self.speed_y = 0
end

function Player:update(dt)
    if love.keyboard.isDown("right") and not love.keyboard.isDown("left") then
        self.speed_x = self.speed_x + 1000 * dt
    elseif love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
        self.speed_x = self.speed_x - 1000 * dt
    else
        if self.speed_x >= 10 then
            self.speed_x = self.speed_x - 1500 * dt
        elseif self.speed_x <= -10 then
            self.speed_x = self.speed_x + 1500 * dt
        else
            self.speed_x = 0
        end
    end

    if love.keyboard.isDown("up") then
        self.speed_y = -400
    end

    if self.speed_x >= 500 then
        self.speed_x = 500
    elseif self.speed_x <= -500 then
        self.speed_x = -500
    end
    self.x = self.x + self.speed_x * dt
    self.y = self.y + self.speed_y * dt
    self.speed_y = self.speed_y + 500 * dt
end

function Player:draw()
    love.graphics.rectangle("fill", player.x, player.y, 100, 100)
end