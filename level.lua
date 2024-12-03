Level = Object:extend()

function Level:new(tilemap)
    self.tilemap = tilemap
end

local function stencil_func_far()
    love.graphics.circle("fill", player.x + player.width / 2, player.y + player.height / 2, 180)
end

local function stencil_func_near()
    love.graphics.circle("fill", player.x + player.width / 2, player.y + player.height / 2, 120)
end

-- This is based on https://sheepolution.com/learn/book/18 (How to LÖVE - Tilemaps)
function Level:draw()
    love.graphics.setStencilTest("greater", 0)
    
    for y, row in ipairs(self.tilemap) do
        for x, tile in ipairs(row) do
            if (world_state == 1 and tile == 3) or (world_state == 2 and tile == 2) then
                love.graphics.stencil(stencil_func_far, "replace", 1)
                if world_state == 1 then
                    love.graphics.setColor(0.75, 0.88, 1, 0.15)
                elseif world_state == 2 then
                    love.graphics.setColor(1, 1, 0.75, 0.1)
                end
                love.graphics.rectangle("fill", x * 20 - 20, y * 20 - 20, 20, 20)

                love.graphics.stencil(stencil_func_near, "replace", 1)
                love.graphics.rectangle("fill", x * 20 - 20, y * 20 - 20, 20, 20)
            end
        end
    end
    love.graphics.setStencilTest()
    for y, row in ipairs(self.tilemap) do
        for x, tile in ipairs(row) do
            if tile == 1 then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.rectangle("fill", x * 20 - 20, y * 20 - 20, 20, 20)
            elseif tile == world_state + 1 then
                if world_state == 1 then
                    love.graphics.setColor(1, 1, 0.75, 1)
                elseif world_state == 2 then
                    love.graphics.setColor(0.75, 0.88, 1, 1)
                end
                love.graphics.rectangle("fill", x * 20 - 20, y * 20 - 20, 20, 20)
            end
        end
    end
    
end