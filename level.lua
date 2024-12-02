Level = Object:extend()

function Level:new(tilemap)
    self.tilemap = tilemap
end

-- This is based on https://sheepolution.com/learn/book/18 (How to LÖVE - Tilemaps)
function Level:draw()
    for y, row in ipairs(self.tilemap) do
        for x, tile in ipairs(row) do
            if tile == 1 then
                love.graphics.rectangle("fill", x * 20 - 20, y * 20 - 20, 20, 20)
            end
        end
    end
end