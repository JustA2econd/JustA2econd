Player = Object:extend()

function Player:new(x, y)
    -- Position
    self.x = x
    self.y = y
    -- Size
    self.width = 50
    self.height = 50
    -- Speed
    self.speed_x = 0
    self.speed_y = 0
    -- Touching level?
    self.ground = false
    self.wall = false
end

function Player:update(dt)
    -- Accelerate right
    if love.keyboard.isDown("right") and not love.keyboard.isDown("left") then
        self.speed_x = self.speed_x + 1000 * dt
    -- Accelerate left
    elseif love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
        self.speed_x = self.speed_x - 1000 * dt
    -- If not touching one key, slow down
    else
        if self.speed_x >= 10 then
            self.speed_x = self.speed_x - 1000 * dt
        elseif self.speed_x <= -10 then
            self.speed_x = self.speed_x + 1000 * dt
        else
            self.speed_x = 0
        end
    end

    -- Terminal velocity (x)
    if self.speed_x >= 500 then
        self.speed_x = 500
    elseif self.speed_x <= -500 then
        self.speed_x = -500
    end

    -- Update positions based on speed
    self.x = self.x + self.speed_x * dt
    self.y = self.y + self.speed_y * dt

    -- Check collision
    -- TODO

    -- Change gravity
    if not self.ground then
        self.speed_y = self.speed_y + 500 * dt
    else
        self.speed_y = 0
    end
end

function Player:draw()
    -- Draw the player
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end


function Player:keypressed(key)
    if key == "up" then
        self.speed_y = -400
    end
end