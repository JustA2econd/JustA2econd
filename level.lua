-- Create level class
Level = Object:extend()

-- The level has a tilemap
function Level:new(tilemap)
    self.tilemap = tilemap
end

-- Set stencil functions for showing nearby objects in the opposite phase
local function stencil_func_far()
    love.graphics.circle("fill", player.x + player.width / 2, player.y + player.height / 2, 180 + (player.switch_meter - player.switch_meter_projection) * 10)
end
local function stencil_func_near()
    love.graphics.circle("fill", player.x + player.width / 2, player.y + player.height / 2, 120 + (player.switch_meter - player.switch_meter_projection) * 10)
end
local function stencil_func_transition()
    love.graphics.circle("fill", player.x + player.width / 2, player.y + player.height / 2, (-20 + (player.switch_meter - player.switch_meter_projection)) * 20)
end
local function stencil_func_full()
    love.graphics.circle("fill", player.x + player.width / 2, player.y + player.height / 2, 1100)
end

-- This is based on https://sheepolution.com/learn/book/18 (How to LÖVE - Tilemaps)
function Level:draw()
    -- Set stencil mode
    love.graphics.setStencilTest("greater", 0)
    -- Draw decorations first
    for y, row in ipairs(self.tilemap) do
        -- Don't draw tiles below the screen
        if y <= 30 then
            for x, tile in ipairs(row) do
                -- Only draw tiles if they will be on screen
                if x >= (camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 40 and x <= (camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 40 + 41 then
                    -- If tile is in opposite phase...
                    if (world_state == 1 and isDecor(tile) == 3) or (world_state == 2 and isDecor(tile) == 2) then
                        -- Draw the tile transparent
                        love.graphics.setColor(1, 1, 1, 0.15)
                        -- Use the far stencil to draw the tiles a little bit it they are somewhat close
                        love.graphics.stencil(stencil_func_far, "replace", 1)
                        -- Draw decor tiles
                        love.graphics.draw(DTiles[tonumber(tile:sub(2, -1))], x * 20 - 20, y * 20 - 20)

                        -- Use the near stencil to draw tiles less transparent if they are really close
                        love.graphics.stencil(stencil_func_near, "replace", 1)
                        love.graphics.draw(DTiles[tonumber(tile:sub(2, -1))], x * 20 - 20, y * 20 - 20)

                        -- If the player is charging a switch, draw tiles less transparent
                        if player.switch_meter - player.switch_meter_projection >= 20 then
                            -- Set a less transparent color
                            love.graphics.setColor(1, 1, 1, 0.6)
                            -- Set stencil
                            love.graphics.stencil(stencil_func_transition, "replace", 1)
                            -- Draw
                            love.graphics.draw(DTiles[tonumber(tile:sub(2, -1))], x * 20 - 20, y * 20 - 20)
                        end
                    -- If the current tile is in phase or a World tile, draw it opaque
                    elseif (world_state == 1 and isDecor(tile) == 2) or (world_state == 2 and isDecor(tile) == 3) or isDecor(tile) == 1 then
                        -- Set a non-transparent color
                        love.graphics.setColor(1, 1, 1, 1)
                        -- Use the full stencil to draw the whole screen
                        love.graphics.stencil(stencil_func_full, "replace", 1)
                        -- Draw tile
                        love.graphics.draw(DTiles[tonumber(tile:sub(2, -1))], x * 20 - 20, y * 20 - 20)
                    end
                end
            end
        end
    end
    -- Next, draw out of phase tiles
    for y, row in ipairs(self.tilemap) do
        if y <= 30 then
            for x, tile in ipairs(row) do
                if x >= (camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 40 and x <= (camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 40 + 41 then
                    -- If tile is of opposite phase...
                    if (world_state == 1 and isLua(tile)) or (world_state == 2 and isSol(tile)) then
                        -- Use the far stencil
                        love.graphics.stencil(stencil_func_far, "replace", 1)
                        -- If Sol, set transparent Lua colors
                        if world_state == 1 then
                            love.graphics.setColor(0.75, 0.88, 1, 0.15)
                        -- If Lua, set transparent Sol colors
                        elseif world_state == 2 then
                            love.graphics.setColor(1, 1, 0.75, 0.15)
                        end
                        -- Draw a rectangle where the tile would be
                        love.graphics.rectangle("fill", x * 20 - 20, y * 20 - 20, 20, 20)
                        -- Use the near stencil
                        love.graphics.stencil(stencil_func_near, "replace", 1)
                        -- Draw nearby rectangles again
                        love.graphics.rectangle("fill", x * 20 - 20, y * 20 - 20, 20, 20)

                        -- If player is charging, draw tiles less transparent
                        if player.switch_meter - player.switch_meter_projection >= 20 then
                            -- If Sol, set Lua colors
                            if world_state == 1 then
                                love.graphics.setColor(0.75, 0.88, 1, 0.6)
                            -- If Lua, set Sol colors
                            elseif world_state == 2 then
                                love.graphics.setColor(1, 1, 0.75, 0.6)
                            end
                            -- Use transitioning stencil
                            love.graphics.stencil(stencil_func_transition, "replace", 1)
                            -- Draw rectangle
                            love.graphics.rectangle("fill", x * 20 - 20, y * 20 - 20, 20, 20)
                        end
                    end
                end
            end
        end
    end
    -- Finally, draw in phase tiles and world tiles
    -- Set the full stencil so that the whole screen is drawn
    love.graphics.stencil(stencil_func_full, "replace", 1)
    for y, row in ipairs(self.tilemap) do
        if y <= 30 then
            for x, tile in ipairs(row) do
                if x >= (camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 40 and x <= (camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 40 + 41 then
                    -- If world tile, set default color and draw tile sprite
                    if isWorld(tile) then
                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.draw(WTiles[tonumber(tile)], x * 20 - 20, y * 20 - 20)
                    else
                        -- If Sol tile, set Sol color and draw tile sprite
                        if world_state == 1 and isSol(tile) then
                            love.graphics.setColor(1, 1, 0.75, 1)
                            love.graphics.draw(STiles[tonumber(tile:sub(2, -1))], x * 20 - 20, y * 20 - 20)
                        -- If Lua tile, set Lua color and draw sprite
                        elseif world_state == 2 and isLua(tile) then
                            love.graphics.setColor(0.75, 0.88, 1, 1)
                            love.graphics.draw(STiles[tonumber(tile:sub(2, -1))], x * 20 - 20, y * 20 - 20)
                        end
                    end
                end
            end
        end
    end
    -- Reset stencil mode
    love.graphics.setStencilTest()
end