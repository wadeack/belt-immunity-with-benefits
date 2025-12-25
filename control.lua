-- This file is part of belt-immunity-with-benefits mod
-- Licensed under the MIT License. See LICENSE file for details.

original_speed_modifier = 0
speed_is_modified = false
--revert_modifier = 0
modifier_to_avoid = 1


function find_entities_filtered(player, entity_type, left_bound, right_bound)
    local result = player.surface.find_entities_filtered{area = {left_bound, right_bound}, type = entity_type}
    if #result > 0 then
        return result[1]
    else
        return nil
    end
end

function find_entity_by_type(player, entity_type)
    local entity_found = nil
    local direction = player.character.direction
    local left_bound = player.position
    local right_bound = player.position
    if direction == 0 then
        left_bound.y = left_bound.y - 1
        left_bound.x = left_bound.x - 0.1
        right_bound.x = right_bound.x + 0.1
    elseif direction == 4 then
        right_bound.x = right_bound.x + 1
        left_bound.y = left_bound.y - 0.1
        right_bound.y = right_bound.y + 0.1
    elseif direction == 8 then
        right_bound.y = right_bound.y + 1
        left_bound.x = left_bound.x - 0.1
        right_bound.x = right_bound.x + 0.1
    elseif direction == 12 then
        left_bound.x = left_bound.x - 1
        left_bound.y = left_bound.y - 0.1
        right_bound.y = right_bound.y + 0.1
    end
--    player.print("Checking position: " .. tostring(player.position.x) .. ", " .. tostring(player.position.y))
    return find_entities_filtered(player, entity_type, left_bound, right_bound)
end

function check_for_belt_immunity(player)
    for _, equipment in pairs(player.character.grid.equipment) do
        if equipment.name == 'belt-immunity-equipment' and equipment.energy > 0 then
--            player.print("immunity energy: " .. tostring(equipment.energy))
            return true
        end
    end
    return false
end

script.on_event(defines.events.on_player_changed_position,
    function(event)
        local player = game.get_player(event.player_index)
        if player.controller_type == defines.controllers.character and player.character.grid then
            local has_immunity = check_for_belt_immunity(player)
            if player.character_running_speed_modifier ~= nil then
                if speed_is_modified == false then
                    original_speed_modifier = player.character_running_speed_modifier
                end
            end
--            player.print("Running speed: " .. tostring(player.character_running_speed))
--            player.print("Running speed modifier: " .. tostring(player.character_running_speed_modifier).."Original speed mod:"..tostring(original_speed_modifier))
            if has_immunity then
                local belt = find_entity_by_type(player, "transport-belt")
                if belt ~= nil then
--                    player.print("Belt has been found")
                    if (player.character.direction == belt.direction) then
                        local belt_speed = belt.prototype.belt_speed
--                        player.print("Belt speed: " .. tostring(belt_speed))

                        local base_speed_before_last_modifier = player.character_running_speed/(modifier_to_avoid + original_speed_modifier)

--                        player.print("Speed check: " .. tostring(base_speed_before_last_modifier))
                        local modifier = (base_speed_before_last_modifier + belt_speed)/base_speed_before_last_modifier
--                        player.print("Modifier value: " .. tostring(modifier) .. ", Modifier to avoid: " .. tostring(modifier_to_avoid) .. ", Modifier to be applied: " .. tostring(modifier - 1 + original_speed_modifier))
                        is_different_modifier = (modifier ~= modifier_to_avoid)
                        if is_different_modifier then
--                            player.print("Speed will be modified.")

                            modifier_to_avoid = modifier
                            player.character_running_speed_modifier = modifier - 1 + original_speed_modifier
                            speed_is_modified = true
                        end
                    end
                else
                    if speed_is_modified == true then
                        player.character_running_speed_modifier = original_speed_modifier
--                        player.character_running_speed_modifier = player.character_running_speed_modifier * revert_modifier
                        speed_is_modified = false
                        modifier_to_avoid = 1
--                        player.print("Speed has been reset")
                    end
                end
            end
        end
    end
)

