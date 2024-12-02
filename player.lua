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
    -- Other stuff
    self.cols = {}
    self.cols_len = 0
    self.normal_x = 0
    self.normal_y = 0
    self.walljump = -350
end

function Player:update(dt)
    -- Accelerate right
    if love.keyboard.isDown("right") and not love.keyboard.isDown("left") then
        self.speed_x = self.speed_x + 1500 * dt
    -- Accelerate left
    elseif love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
        self.speed_x = self.speed_x - 1500 * dt
    -- If not touching one key, slow down
    else
        if self.speed_x >= 10 then
            self.speed_x = self.speed_x - 1500 * dt
        elseif self.speed_x <= -10 then
            self.speed_x = self.speed_x + 1500 * dt
        else
            self.speed_x = 0
        end
    end

    -- Jump
    if love.keyboard.isDown("up") and self.normal_y == -1 then
        self.speed_y = -400
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

    -- Check for collision and adjust
    self.normal_x = 0
    self.normal_y = 0
    self.x, self.y, self.cols, self.cols_len = world:move(player, self.x, self.y)
    if self.cols[1] then
        for i, collision in ipairs(self.cols) do
            if collision.normal.x == 1 or collision.normal.x == -1 then
                self.speed_x = 0
                self.normal_x = collision.normal.x
                if self.speed_y > 100 then
                    self.speed_y = self.speed_y - 650 * dt
                end
            end
            if collision.normal.y == 1 or collision.normal.y == -1 then
                self.speed_y = 0
                self.normal_y = collision.normal.y
            end
        end
    end

    -- Apply gravity
    if self.normal_y ~= -1 then
        self.speed_y = self.speed_y + 700 * dt
    else
        self.speed_y = 0
        self.walljump = -350
    end
end

function Player:draw()
    -- Draw the player
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    love.graphics.print("speed_y = "..self.speed_y, 30, 30)
end


function Player:keypressed(key)
    if key == "up" then
        -- Handle walljumping
        if self.normal_y == -1 then
            -- Do nothing (don't wall jump if on the floor)
        elseif self.normal_x == 1 then
            if not (self.walljump > 0) then
                self.speed_y = self.walljump
                self.walljump = self.walljump + 100
            end
            self.speed_x = 400
        elseif self.normal_x == -1 then
            if not (self.walljump > 0) then
                self.speed_y = self.walljump
                self.walljump = self.walljump + 100
            end
            self.speed_x = -400
        end
    end
end