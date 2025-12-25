-- This file is part of belt-immunity-with-benefits mod
-- Licensed under the MIT License. See LICENSE file for details.

original_speed_modifier = 0
speed_is_modified = false
modifier_to_avoid = 1
debug = settings.global["on-belt-speed-logging"].value

function debug_log(player, message)
    if debug then
        player.print(message)
    end
end

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
    return find_entities_filtered(player, entity_type, left_bound, right_bound)
end

function check_for_belt_immunity(player)
    for _, equipment in pairs(player.character.grid.equipment) do
        if equipment.name == 'belt-immunity-equipment' and equipment.energy > 0 then
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
            debug_log(player, "Running speed: " .. tostring(player.character_running_speed))
            debug_log(player, "Current speed modifier: " .. tostring(player.character_running_speed_modifier)..", Original speed modifier:"..tostring(original_speed_modifier))

            if not has_immunity then
                return
            end

            local belt = find_entity_by_type(player, "transport-belt")
            if belt == nil then
                if speed_is_modified == true then
                    player.character_running_speed_modifier = original_speed_modifier
                    speed_is_modified = false
                    modifier_to_avoid = 1
                    debug_log(player, "Speed has been reset")
                end
                return
            end

            if not (player.character.direction == belt.direction) then
                return
            end

            local belt_speed = belt.prototype.belt_speed
            debug_log(player, "Belt speed: " .. tostring(belt_speed))

            local base_speed_before_last_modifier = player.character_running_speed/(modifier_to_avoid + original_speed_modifier)

            debug_log(player, "Base speed before modifiers: " .. tostring(base_speed_before_last_modifier))
            local modifier = (base_speed_before_last_modifier + belt_speed)/base_speed_before_last_modifier
            debug_log(player, "Modifier value: " .. tostring(modifier) .. ", Modifier to avoid: " .. tostring(modifier_to_avoid) .. ", Modifier to be applied: " .. tostring(modifier - 1 + original_speed_modifier))
            is_different_modifier = (modifier ~= modifier_to_avoid)
            if is_different_modifier then
                debug_log(player, "Speed will be modified.")

                modifier_to_avoid = modifier
                player.character_running_speed_modifier = modifier - 1 + original_speed_modifier
                speed_is_modified = true
            end
        end
    end
)
