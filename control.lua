-- This file is part of belt-immunity-with-benefits mod
-- Licensed under the MIT License. See LICENSE file for details.

debug = settings.global["on-belt-speed-logging"].value

function init_player(player)
    if storage.modifiers == nil then
        storage.modifiers = {}
    end

    debug_log(player, "Initializing modifiers for player " .. tostring(player.name))
    if storage.modifiers[player.name] == nil then
        storage.modifiers[player.name] = {
            applied_value = 1,
            og_value = 0
        }
        debug_log(player, "Modifiers for player " .. tostring(player.name) .. " have been initialized.")
    end
end

function init_from_event(event)
    local player = game.get_player(event.player_index)
    init_player(player)
end

function init_all_players()
    for _, player in pairs(game.players) do
        init_player(player)
    end
end

script.on_event(defines.events.on_player_created, init_from_event)
script.on_event(defines.events.on_player_joined_game, init_all_players)
script.on_event(defines.events.on_player_respawned, init_from_event)
script.on_event(defines.events.on_singleplayer_init, init_all_players)
script.on_event(defines.events.on_multiplayer_init, init_all_players)

function set_modifier(player, value)
    storage.modifiers[player.name].applied_value = value
end

function get_modifier(player)
    return storage.modifiers[player.name].applied_value
end

function set_og_modifier(player, value)
    storage.modifiers[player.name].og_value = value
end

function get_og_modifier(player)
    return storage.modifiers[player.name].og_value
end

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
        if player.controller_type ~= defines.controllers.character then
            return
        end
        if not player.character.grid then
            return
        end

        local has_immunity = check_for_belt_immunity(player)
        if not has_immunity then
            return
        end

        if not storage.modifiers[player.name] then
            init_player(player)
        end

        if player.character_running_speed_modifier ~= nil and get_modifier(player) == 1 then
            set_og_modifier(player, player.character_running_speed_modifier)
        end

        debug_log(player, "Running speed: " .. tostring(player.character_running_speed))
        debug_log(player, "Current speed modifier: " .. tostring(player.character_running_speed_modifier)..", Original speed modifier:"..tostring(get_og_modifier(player)))

        local belt = find_entity_by_type(player, "transport-belt")
        if belt == nil then
            if get_modifier(player) ~= 1 then
                player.character_running_speed_modifier = get_og_modifier(player)
                set_modifier(player, 1)
                debug_log(player, "Speed has been reset")
            end
            return
        end

        if player.character.direction ~= belt.direction then
            return
        end

        local belt_speed = belt.prototype.belt_speed
        debug_log(player, "Belt speed: " .. tostring(belt_speed))

        local base_speed_before_last_modifier = player.character_running_speed/(get_modifier(player) + get_og_modifier(player))

        debug_log(player, "Base speed before modifiers: " .. tostring(base_speed_before_last_modifier))
        local modifier = (base_speed_before_last_modifier + belt_speed)/base_speed_before_last_modifier
        debug_log(player, "Modifier value: " .. tostring(modifier) .. ", Modifier to avoid: " .. tostring(get_modifier(player)) .. ", Modifier to be applied: " .. tostring(modifier - 1 + get_og_modifier(player)))
        is_different_modifier = (modifier ~= get_modifier(player))
        if is_different_modifier then
            debug_log(player, "Speed will be modified.")
            set_modifier(player, modifier)
            player.character_running_speed_modifier = modifier - 1 + get_og_modifier(player)
        end
    end
)
