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
    -- State-switch Meter
    self.switch_meter = 0
    self.switch_meter_projection = 0
    self.switch_meter_target = -50
    self.switch_meter_falling = false
    -- Other stuff
    self.walljump = -350
    self.step_cooldown = 0
    self.cols = {}
    self.cols_len = 0
    self.normal_x = 0
    self.normal_y = 0
    
end

local solFilter = function(item, other)
    for i, v in ipairs(solblock) do
        if v.name == other then
            return "cross"
        end
    end
    return "slide"
end

local luaFilter = function(item, other)
    for i, v in ipairs(luablock) do
        if v.name == other then
            return "cross"
        end
    end
    return "slide"
end

function Player:update(dt)
    -- Update the switch meter
    if love.keyboard.isDown(Swap.key) and not self.switch_meter_falling then
        if self.switch_meter_projection <= self.switch_meter_target then
            switchWorld()
            SwitchSound:play()
            SwitchMeter:stop()
            self.switch_meter_projection = self.switch_meter_target
            self.switch_meter_falling = true
        elseif self.switch_meter_target >= 0 and (self.switch_meter - self.switch_meter_projection < 40) then
            self.switch_meter_projection = self.switch_meter_projection - 50 * dt
            if not SwitchMeter:isPlaying() then
                SwitchMeter:play()
            end
            SwitchMeter:setPitch((self.switch_meter - self.switch_meter_projection) / 25 + 1)
            SwitchMeter:setVolume((self.switch_meter - self.switch_meter_projection) / 50)
        elseif self.switch_meter_target >= 0 and (self.switch_meter - self.switch_meter_projection >= 40) then
            if not SwitchMeter:isPlaying() then
                SwitchMeter:play()
            end
            SwitchMeter:setPitch((self.switch_meter - self.switch_meter_projection) / 25 + 1)
            if self:checkOtherState() then
                self.switch_meter_projection = self.switch_meter_projection - 50 * dt
                SwitchMeter:setVolume((self.switch_meter - self.switch_meter_projection) / 50)
            else
                SwitchMeter:setVolume(0.3)
            end
        end
    elseif self.switch_meter_falling then
        self.switch_meter = self.switch_meter - 50 * dt
        if self.switch_meter <= self.switch_meter_target then
            self.switch_meter_falling = false
            self.switch_meter_target = self.switch_meter_target - 50
            SwitchReady:play()
        end
    else
        if self.switch_meter_projection >= self.switch_meter then
            self.switch_meter = self.switch_meter + 33 * dt
            if self.switch_meter > 100 then
                self.switch_meter = 100
                if SwitchMeter:isPlaying() then
                    SwitchMeter:stop()
                end
            end
            self.switch_meter_projection = self.switch_meter
        else
            self.switch_meter_projection = self.switch_meter_projection + 50 * dt
            if not SwitchMeter:isPlaying() then
                SwitchMeter:play()
            end
            SwitchMeter:setPitch((self.switch_meter - self.switch_meter_projection) / 25 + 1)
            SwitchMeter:setVolume((self.switch_meter - self.switch_meter_projection) / 50)
        end
        self.switch_meter_target = self.switch_meter - 50
    end

    -- Accelerate right
    if love.keyboard.isDown(Right.key) and not love.keyboard.isDown(Left.key) then
        self.speed_x = self.speed_x + 1500 * dt
    -- Accelerate left
    elseif love.keyboard.isDown(Left.key) and not love.keyboard.isDown(Right.key) then
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
    if love.keyboard.isDown(Jump.key) and self.normal_y == -1 then
        self.speed_y = -400
        JumpSound:play()
    end

    -- Terminal velocity (x)
    if self.speed_x >= 500 then
        self.speed_x = 500
    elseif self.speed_x <= -500 then
        self.speed_x = -500
    end
    if self.speed_y >= 800 then
        self.speed_y = 800
    end

    -- Update positions based on speed
    self.x = self.x + self.speed_x * dt
    self.y = self.y + self.speed_y * dt

    -- Check for collision and adjust
    self.normal_x = 0
    self.normal_y = 0
    local slide = false
    if world_state == 1 then
        self.x, self.y, self.cols, self.cols_len = world:move(player, self.x, self.y, luaFilter)
    elseif world_state == 2 then
        self.x, self.y, self.cols, self.cols_len = world:move(player, self.x, self.y, solFilter)
    end
    if self.cols[1] then
        for i, collision in ipairs(self.cols) do
            if (collision.normal.x == 1 or collision.normal.x == -1) and collision.type ~= "cross" then
                if self.speed_x < -300 or self.speed_x > 300 then
                    Bump:play()
                end
                self.speed_x = 0
                self.normal_x = collision.normal.x
                if self.speed_y > 100 then
                    self.speed_y = self.speed_y - 650 * dt
                    slide = true
                    if not Slide:isPlaying() then
                        Slide:play()
                    end
                end
            end
            if (collision.normal.y == 1 or collision.normal.y == -1) and collision.type ~= "cross" then
                if collision.normal.y == -1 then
                    if self.speed_y > 600 then
                        LargeLanding:play()
                    elseif self.speed_y > 300 then
                        SmallLanding:play()
                    end
                end
                self.speed_y = 0
                self.normal_y = collision.normal.y
                
            end
        end
    end
    if not slide and Slide:isPlaying() then
        Slide:pause()
    end
    if (self.speed_x < -100 or self.speed_x > 100) and self.step_cooldown <= 0 and self.normal_y == -1 then
        Step:play()
        self.step_cooldown = 50/(math.abs(self.speed_x))
    end

    -- Apply gravity
    if self.normal_y ~= -1 then
        self.speed_y = self.speed_y + 700 * dt
    else
        self.speed_y = 0
        self.walljump = -350
    end

    if self.step_cooldown > 0 then
        self.step_cooldown = self.step_cooldown - 1 * dt
    end
end

function Player:draw()
    -- Draw the player
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end


function Player:keypressed(key)
    if key == Jump.key then
        -- Handle walljumping
        if self.normal_y == -1 then
            -- Do nothing (don't wall jump if on the floor)
        elseif self.normal_x == 1 then
            Walljump:play()
            if not (self.walljump > 0) then
                self.speed_y = self.walljump
                self.walljump = self.walljump + 100
            end
            self.speed_x = 400
        elseif self.normal_x == -1 then
            Walljump:play()
            if not (self.walljump > 0) then
                self.speed_y = self.walljump
                self.walljump = self.walljump + 100
            end
            self.speed_x = -400
        end
    end
end

function Player:checkOtherState()
    local test = {}
    test.x, test.y, test.cols, test.cols_len = 0, 0, 0, 0
    if world_state == 1 then
        test.x, test.y, test.cols, test.cols_len = world:check(player, self.x, self.y, luaFilter)
    elseif world_state == 2 then
        test.x, test.y, test.cols, test.cols_len = world:check(player, self.x, self.y, solFilter)
    end
    if self.cols[1] then
        for i, collision in ipairs(self.cols) do
            if collision.type == "cross" then
                return false
            end
        end
    end
    return true
end