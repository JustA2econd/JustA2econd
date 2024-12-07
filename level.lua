Level = Object:extend()

function Level:new(tilemap)
    self.tilemap = tilemap
end

local function stencil_func_far()
    love.graphics.circle("fill", player.x + player.width / 2, player.y + player.height / 2, 180 + (player.switch_meter - player.switch_meter_projection) * 10)
end

local function stencil_func_near()
    love.graphics.circle("fill", player.x + player.width / 2, player.y + player.height / 2, 120 + (player.switch_meter - player.switch_meter_projection) * 10)
end

local function stencil_func_transition()
    love.graphics.circle("fill", player.x + player.width / 2, player.y + player.height / 2, (-20 + (player.switch_meter - player.switch_meter_projection)) * 20)
end

-- This is based on https://sheepolution.com/learn/book/18 (How to LÖVE - Tilemaps)
function Level:draw()
    love.graphics.setStencilTest()
    for y, row in ipairs(self.tilemap) do
        if y <= 30 then
            for x, tile in ipairs(row) do
                if x >= (camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 40 and x <= (camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 40 + 41 then
                    if (world_state == 1 and isDecor(tile) == 3) or (world_state == 2 and isDecor(tile) == 2) then
                        love.graphics.setColor(1, 1, 1, 0.15)
                        love.graphics.draw(DTiles[tonumber(tile:sub(2, -1))], x * 20 - 20, y * 20 - 20)

                        love.graphics.draw(DTiles[tonumber(tile:sub(2, -1))], x * 20 - 20, y * 20 - 20)

                        if player.switch_meter - player.switch_meter_projection >= 20 then
                            love.graphics.setColor(1, 1, 1, 0.6)
                            love.graphics.draw(DTiles[tonumber(tile:sub(2, -1))], x * 20 - 20, y * 20 - 20)
                        end
                    elseif (world_state == 1 and isDecor(tile) == 2) or (world_state == 2 and isDecor(tile) == 3) or isDecor(tile) == 1 then
                        love.graphics.setColor(1, 1, 1, 1)
                        
                        love.graphics.draw(DTiles[tonumber(tile:sub(2, -1))], x * 20 - 20, y * 20 - 20)
                    end
                end
            end
        end
    end
love.graphics.setStencilTest("greater", 0)
    for y, row in ipairs(self.tilemap) do
        if y <= 30 then
            for x, tile in ipairs(row) do
                if x >= (camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 40 and x <= (camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 40 + 41 then
                    if (world_state == 1 and isLua(tile)) or (world_state == 2 and isSol(tile)) then
                        love.graphics.stencil(stencil_func_far, "replace", 1)
                        if world_state == 1 then
                            love.graphics.setColor(0.75, 0.88, 1, 0.15)
                        elseif world_state == 2 then
                            love.graphics.setColor(1, 1, 0.75, 0.15)
                        end
                        love.graphics.rectangle("fill", x * 20 - 20, y * 20 - 20, 20, 20)

                        love.graphics.stencil(stencil_func_near, "replace", 1)
                        love.graphics.rectangle("fill", x * 20 - 20, y * 20 - 20, 20, 20)

                        if player.switch_meter - player.switch_meter_projection >= 20 then
                            if world_state == 1 then
                                love.graphics.setColor(0.75, 0.88, 1, 0.6)
                            elseif world_state == 2 then
                                love.graphics.setColor(1, 1, 0.75, 0.6)
                            end
                            love.graphics.stencil(stencil_func_transition, "replace", 1)
                            love.graphics.rectangle("fill", x * 20 - 20, y * 20 - 20, 20, 20)
                        end
                    end
                end
            end
        end
    end
    love.graphics.setStencilTest()
    for y, row in ipairs(self.tilemap) do
        if y <= 30 then
            for x, tile in ipairs(row) do
                if x >= (camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 40 and x <= (camera_settings.x + (camera_settings.trans_duration_x^2) * camera_settings.transition_x) * 40 + 41 then
                    if isWorld(tile) then
                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.draw(WTiles[tonumber(tile)], x * 20 - 20, y * 20 - 20)
                    else
                        if world_state == 1 and isSol(tile) then
                            love.graphics.setColor(1, 1, 0.75, 1)
                            love.graphics.draw(STiles[tonumber(tile:sub(2, -1))], x * 20 - 20, y * 20 - 20)
                        elseif world_state == 2 and isLua(tile) then
                            love.graphics.setColor(0.75, 0.88, 1, 1)
                            love.graphics.draw(STiles[tonumber(tile:sub(2, -1))], x * 20 - 20, y * 20 - 20)
                        end
                    end
                end
            end
        end
    end
end