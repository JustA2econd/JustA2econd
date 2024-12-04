function drawUI()
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.rectangle("line", 30, 30, 740, 50)
    if player.switch_meter_target >= -1 then
        love.graphics.setColor(0.9, 0.9, 0.9, 0.6)
        love.graphics.rectangle("fill", 30, 30, player.switch_meter_target * 7.4, 50)
        if not player.switch_meter_falling then
            love.graphics.setColor(0.9, 0.9, 0.9, 0.6)
            love.graphics.rectangle("fill", player.switch_meter_target * 7.4 + 30, 30, (player.switch_meter - player.switch_meter_target) * 7.4, 50)
            love.graphics.setColor(0.9, 0.9, 0.9, 0.8)
            love.graphics.line(player.switch_meter_target * 7.4 + 30, 30, player.switch_meter_target * 7.4 + 30, 80)
        end
    else
        love.graphics.setColor(0.9, 0.9, 0.9, 0.3)
        love.graphics.rectangle("fill", 30, 30, player.switch_meter * 7.4, 50)
    end
    love.graphics.setColor(1, 0, 0, 0.6)
    love.graphics.rectangle("fill", player.switch_meter_projection * 7.4 + 30, 30, (player.switch_meter - player.switch_meter_projection) * 7.4, 50)
end