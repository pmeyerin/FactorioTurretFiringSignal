require("shared")
local mod = {}
local gui_frame_name = mod_prefix .. "frame"
local gui_check_turret_firing = mod_prefix .. "turretFiring"

script.on_init(function()
    storage.track_firing_turrets = {}
end)

function mod.open_gui(entity, player)
	local frame = player.gui.relative[gui_frame_name]
	if frame then frame.destroy() end
	
	frame = player.gui.relative.add{
		type = "frame",
		name = gui_frame_name,
		caption = {"gui-control-behavior.circuit-connection"},
		anchor = {
			gui = defines.relative_gui_type.turret_gui,
			position = defines.relative_gui_position.right,
		},
	}

	local inner = frame.add{
		type = "frame",
		name = gui_inner_name,
		style = "inside_shallow_frame_with_padding",
		direction = "vertical",
	}

	inner.add{
		type = "checkbox",
		name = gui_check_turret_firing,
		caption = "Read Firing",
		state = storage.track_firing_turrets[entity.unit_number] ~= nil,
		tags = {unit_number = entity.unit_number},
	}
end

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity

  if entity then
	if event.entity and string.find(event.entity.type, '-turret') ~= nil then	
      local player = game.get_player(event.player_index) --[[@as LuaEntity]]
      mod.open_gui(entity, player)
    end
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
	if event.element.tags.unit_number == nil then
		return
	end
	--Can I be sure that my desired entity will always be near where the player is currently looking?
	local clickX = game.players[event.player_index]["position"]["x"]
	local clickY = game.players[event.player_index]["position"]["y"]
--	for surfaceIndex, surface in pairs(game.surfaces) do
--		game.print(surface["name"])
		local found = false
		local foundEntities = game.surfaces[1].find_entities_filtered{position={clickX, clickY}, radius = 50}
--		local foundEntities = surface.find_entities_filtered{force = "player"}
		for entityIndex, entity in pairs(foundEntities) do
			if entity["unit_number"] == event.element.tags["unit_number"] then
				storage.track_firing_turrets[entity["unit_number"]] = entity
				break
			end
		end
--		if found == true then
--			break;
--		end
--	end
end)

script.on_nth_tick(30,
function(event)
	for u_num, entity in pairs(storage.track_firing_turrets) do
		if (entity.shooting_target ~= nil) then
			game.print("a turret is shooting")
		end
	end

end)