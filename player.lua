-- Create player class
Player = Object:extend()

-- Player object has many attributes
function Player:new(x, y)
    -- Position
    self.x = x
    self.y = y
    self.direction = 1
    -- Size
    self.width = 42
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
    self.walljump = -350 -- Wall jump height, gets smaller over time
    self.step = 0 -- Step phase, used to determine step sprite and sound
    self.step_cooldown = 0 -- Step cooldown, makes the footsteps slower
    self.cols = {} -- Table of collisions
    self.cols_len = 0 -- Length of collisions table
    self.normal_x = 0 -- Combined collision normals (how the player is colliding with the level)
    self.normal_y = 0
    
end

-- If the player is in Lua phase, collide with Lua blocks and pass through Sol blocks
local solFilter = function(item, other)
    for i, v in ipairs(solblock) do
        if v.name == other then
            return "cross"
        end
    end
    return "slide"
end

-- If the player is in Sol phase, collide with Sol blocks and pass through Lua blocks
local luaFilter = function(item, other)
    for i, v in ipairs(luablock) do
        if v.name == other then
            return "cross"
        end
    end
    return "slide"
end

function Player:update(dt)
    -- Apply gravity
    self.speed_y = self.speed_y + 700 * dt

    -- Set the player's direction
    if self.speed_x > 10 then
        self.direction = 1
    elseif self.speed_x < -10 then
        self.direction = -1
    end

    -- Update the switch meter
    -- If space (or whatever Switch is) is held, do something
    if love.keyboard.isDown(Swap.key) and not self.switch_meter_falling then
        -- If the switch is fully charged, switch phases
        if self.switch_meter_projection <= self.switch_meter_target then
            -- Switch world phase
            switchWorld()
            -- Play the switch sound
            SwitchSound:play()
            -- Stop playing the charge sound
            SwitchMeter:stop()
            -- Set the collision warning to false
            warning = false
            -- Set the meter projection (charge state) to equal the meter target (charge needed to switch)
            -- Do this to prevent more charge being lost than necessary
            self.switch_meter_projection = self.switch_meter_target
            -- Start making the switch meter fall
            self.switch_meter_falling = true
        
        -- If switch is less than 80% charged, charge it
        elseif self.switch_meter_target >= 0 and (self.switch_meter - self.switch_meter_projection < 40) then
            -- Increase the meter projection
            self.switch_meter_projection = self.switch_meter_projection - 50 * dt
            -- Play the charge sound
            if not SwitchMeter:isPlaying() then
                SwitchMeter:play()
            end
            -- Set the pitch, speed, and volume of the sound based on the current charge
            -- (Get higher pitched, faster, and louder with more charge)
            SwitchMeter:setPitch((self.switch_meter - self.switch_meter_projection) / 25 + 1)
            SwitchMeter:setVolume((self.switch_meter - self.switch_meter_projection) / 50)
        -- If switch is at least 80% charged, do something
        elseif self.switch_meter_target >= 0 and (self.switch_meter - self.switch_meter_projection >= 40) then
            -- Play the charge sound
            if not SwitchMeter:isPlaying() then
                SwitchMeter:play()
            end
            -- Set the pitch
            SwitchMeter:setPitch((self.switch_meter - self.switch_meter_projection) / 25 + 1)
            -- If switching would be fine, continue charging as normal
            if self:checkOtherState() then
                self.switch_meter_projection = self.switch_meter_projection - 50 * dt
                SwitchMeter:setVolume((self.switch_meter - self.switch_meter_projection) / 50)
            -- If switch would result in the player being inside a block, don't charge
            else
                -- Set the volume to quiet
                SwitchMeter:setVolume(0.3)
                -- Play the warning sound
                if not SwitchWarning:isPlaying() then
                    SwitchWarning:play()
                    -- Cycle the warning state to show either "PATH BLOCKED" (and change player blend mode) or "CAN'T SWITCH"
                    warning = not warning
                end
            end
        end
    -- If the meter is currently falling after a switch, decrease the meter
    elseif self.switch_meter_falling then
        -- Decrease the meter
        self.switch_meter = self.switch_meter - 50 * dt
        -- If the meter is now at or below the target, stop falling
        if self.switch_meter <= self.switch_meter_target then
            self.switch_meter_falling = false
            -- Set the new target
            self.switch_meter_target = self.switch_meter_target - 50
            -- Play the ready ping
            SwitchReady:play()
        end
    -- If space is not held, increase the meter
    else
        -- If regaining meter...
        if self.switch_meter_projection >= self.switch_meter then
            -- Increase the meter
            self.switch_meter = self.switch_meter + 33 * dt
            -- If the meter is over 100, reset it to 100
            if self.switch_meter > 100 then
                self.switch_meter = 100
            end
            -- If the charge sound is playing, stop it
            if SwitchMeter:isPlaying() then
                SwitchMeter:stop()
            end
            -- Set the warning to false
            warning = false
            -- Update the meter projection (charge) to match the meter
            self.switch_meter_projection = self.switch_meter
        -- If currently uncharging a swap
        else
            -- Update projection to be closed to current meter (decreasing the charge)
            self.switch_meter_projection = self.switch_meter_projection + 50 * dt
            -- If charge sound is not playing, play it
            if not SwitchMeter:isPlaying() then
                SwitchMeter:play()
            end
            -- Update the pitch, speed, and volume of the charge sound
            SwitchMeter:setPitch((self.switch_meter - self.switch_meter_projection) / 25 + 1)
            SwitchMeter:setVolume((self.switch_meter - self.switch_meter_projection) / 50)
        end
        -- Set the meter target to 50 less than the current meter
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
            self.step = 0
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
    slide = false
    -- If world state is 1, go through Lua blocks
    if world_state == 1 then
        self.x, self.y, self.cols, self.cols_len = world:move(player, self.x, self.y, luaFilter)
    -- If world state is 2, go through Sol blocks
    elseif world_state == 2 then
        self.x, self.y, self.cols, self.cols_len = world:move(player, self.x, self.y, solFilter)
    end
    -- If there are any collisions, update player accordingly
    if self.cols[1] then
        for i, collision in ipairs(self.cols) do
            -- If colliding with wall...
            if (collision.normal.x == 1 or collision.normal.x == -1) and collision.type ~= "cross" then
                -- Play a bump sound if going fast enough
                if self.speed_x < -300 or self.speed_x > 300 then
                    Bump:play()
                end
                -- Reset x speed to 0
                self.speed_x = 0
                -- Update player normal
                self.normal_x = collision.normal.x
                -- If player is falling, start wall sliding
                if self.speed_y > 100 then
                    -- Counteract gravity
                    self.speed_y = self.speed_y - 650 * dt
                    slide = true
                    -- Play slide sound
                    if not Slide:isPlaying() then
                        Slide:play()
                    end
                    -- Set direction to face away from the wall
                    self.direction = self.normal_x
                end
            end
            -- If colliding with floor or ceiling...
            if (collision.normal.y == 1 or collision.normal.y == -1) and collision.type ~= "cross" then
                -- Play landing sound depending on speed
                if collision.normal.y == -1 then
                    if self.speed_y > 600 then
                        LargeLanding:play()
                    elseif self.speed_y > 300 then
                        SmallLanding:play()
                    end
                end
                -- Reset y speed and update normal
                self.speed_y = 0
                self.normal_y = collision.normal.y
                
            end
        end
    end
    -- If not sliding, stop playing slide sound
    if not slide and Slide:isPlaying() then
        Slide:pause()
    end
    -- If moving on the ground, update step variables
    if (self.speed_x < -100 or self.speed_x > 100) and self.step_cooldown <= 0 and self.normal_y == -1 then
        if self.step == 0 then
            self.step = 1
            -- Play the step sound every other step phase
            Step:play()
        else
            self.step = 0
        end
        -- Set step cooldown based on speed
        self.step_cooldown = 50/(math.abs(self.speed_x))
    end

    -- Counteract gravity if on the floor
    if self.normal_y == -1 then
        self.speed_y = 0
        self.walljump = -350
    end

    -- Decrease step cooldown
    if self.step_cooldown > 0 then
        self.step_cooldown = self.step_cooldown - 2 * dt
    end
end

function Player:draw()
    -- If switch warning mode is true and playing warning sound, set blend mode so that the player is almost seethrough
    if SwitchWarning:isPlaying() and warning then
        love.graphics.setBlendMode("add")
    end
    -- Default colors to draw player body
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(PlayerBody, player.x + (21 + 21 * -self.direction), player.y, 0, self.direction, 1)

    -- If Sol phase, update outline color accordingly
    if world_state == 1 then
        love.graphics.setColor(1, 1, 0.75 + (self.switch_meter - self.switch_meter_projection)/200, 1)
    -- If Lua phase, update outline color accordingly
    elseif world_state == 2 then
        love.graphics.setColor(0.75 + (self.switch_meter - self.switch_meter_projection)/200, 0.88  + (self.switch_meter - self.switch_meter_projection)/416, 1, 1)
    end
    -- Draw the player
    -- If sliding, then use slide sprite
    if slide then
        love.graphics.draw(PlayerSlide, player.x + (21 + 21 * -self.direction), player.y, 0, self.direction, 1)
    -- If falling, use falling sprite
    elseif self.speed_y > 0 then
        love.graphics.draw(PlayerFall, player.x + (21 + 21 * -self.direction), player.y, 0, self.direction, 1)
    -- If jumping, use rising sprite
    elseif self.speed_y < -150 then
        love.graphics.draw(PlayerRise, player.x + (21 + 21 * -self.direction), player.y, 0, self.direction, 1)
    -- If not moving, use idle sprite
    elseif self.speed_x == 0 then
        love.graphics.draw(PlayerIdle, player.x + (21 + 21 * -self.direction), player.y, 0, self.direction, 1)
    -- Otherwise, use a step sprite
    else
        if self.step == 1 then
            love.graphics.draw(PlayerStep1, player.x + (21 + 21 * -self.direction), player.y, 0, self.direction, 1)
        else
            love.graphics.draw(PlayerStep2, player.x + (21 + 21 * -self.direction), player.y, 0, self.direction, 1)
        end
    end
    -- Reset blend mode
    love.graphics.setBlendMode("alpha")
end


function Player:keypressed(key)
    -- If player pressed the jump key and is not on the floor,
    if key == Jump.key and self.speed_y ~= 0 then
        -- Handle walljumping
        if self.normal_x == 1 then
            -- If walljump height is above 0, then increase y speed
            if not (self.walljump > 0) then
                self.speed_y = self.walljump
                -- Decrease wall jump height
                self.walljump = self.walljump + 100
            end
            -- Set wall jump sound pitch accordingly and play
            Walljump:setPitch((self.walljump+350)/100)
            Walljump:play()
            -- Set x speed
            self.speed_x = 400
        elseif self.normal_x == -1 then
            if not (self.walljump > 0) then
                self.speed_y = self.walljump
                self.walljump = self.walljump + 100
            end
            Walljump:setPitch((self.walljump+350)/100)
            Walljump:play()
            self.speed_x = -400
        end
    end
end

-- Function to check is player would end up inside a block if switching
function Player:checkOtherState()
    -- Create test variables
    local test = {}
    test.x, test.y, test.cols, test.cols_len = 0, 0, 0, 0
    -- If Sol, pass through Lua
    if world_state == 1 then
        test.x, test.y, test.cols, test.cols_len = world:check(player, self.x, self.y, luaFilter)
    -- If Lua, pass through Sol
    elseif world_state == 2 then
        test.x, test.y, test.cols, test.cols_len = world:check(player, self.x, self.y, solFilter)
    end
    -- If there is at least 1 collision, handle it
    if self.cols[1] then
        -- If collision type "cross", player would intersect with block
        for i, collision in ipairs(self.cols) do
            if collision.type == "cross" then
                return false
            end
        end
    end
    -- If no collisions were type "cross", player will not be inside a block
    return true
end