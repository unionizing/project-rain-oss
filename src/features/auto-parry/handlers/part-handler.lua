local action_builder = require("@src/features/auto-parry/data/effect-action")
local projectile_timing_data = {}
pcall(function()
	projectile_timing_data = require("@src/features/auto-parry/data/projectile_timings")
end)
local projectile_source_path = "rw_projectile_timings.lua"

local projectile_names = {}
local projectile_effect_data_map = {}

local function refresh_projectile_names()
	table.clear(projectile_names)
	local seen = {}

	for _, map in { projectile_effect_data_map } do
		for _, effect_data in map do
			local name = effect_data.name or effect_data.id
			if not seen[name] then
				seen[name] = true
				table.insert(projectile_names, name)
			end
		end
	end

	getgenv().projectile_names = projectile_names
end

local function set_projectile_effect_data(source, effect_data)
	if typeof(effect_data) ~= "table" then
		return false
	end

	effect_data.id = effect_data.id or source
	if not effect_data.id then
		return false
	end

	projectile_effect_data_map[effect_data.id] = effect_data
	return true
end

local function rebuild_projectile_effect_data(source_data)
	table.clear(projectile_effect_data_map)

	for source, effect_data in source_data do
		if not set_projectile_effect_data(source, effect_data) then
			warn(source, "invalid@projectile-timing")
		end
	end

	refresh_projectile_names()
end

rebuild_projectile_effect_data(projectile_timing_data)
refresh_projectile_names()

getgenv().load_projectile_timings = function(force_reload)
	local source_data = projectile_timing_data

	if force_reload then
		local can_read_file = isfile and readfile and loadstring
		if can_read_file then
			local ok, src = pcall(function()
				return readfile(projectile_source_path)
			end)
			if ok and typeof(src) == "string" and #src > 0 then
				local chunk, reason = loadstring(src, projectile_source_path)
				if chunk then
					local success, result = pcall(chunk)
					if success and typeof(result) == "table" then
						source_data = result
					else
						warn(string.format("[projectile timings] failed to run '%s': %s", projectile_source_path, tostring(result)))
					end
				else
					warn(string.format("[projectile timings] failed to compile '%s': %s", projectile_source_path, tostring(reason)))
				end
			else
				
			end
		end
	end

	rebuild_projectile_effect_data(source_data)
end

pcall(function()
	if LPH_OBFUSCATED and not getgenv().allowed_to_load_timings then
		return
	end

	getgenv().load_projectile_timings(true)
end)

if not LPH_OBFUSCATED and not is_chime then
	local last_update = tick()
	aztup.maid:give_task(services.RunService.RenderStepped:Connect(function()
		if tick() - last_update <= 0.5 then return end
		if not getgenv().dev_tools_data or not getgenv().dev_tools_data["hot-reload-timings"] then return end
		if not services.UserInputService:IsKeyDown(Enum.KeyCode.Backquote) then return end

		Logger:notify_sound("Reloaded projectile timings.")
		last_update = tick()
		xpcall(function()
			getgenv().load_projectile_timings(true)
		end, warn)
		last_update = tick()
	end))
end

local function debug_print(...)
	if not (aztup and aztup.flags and aztup.flags.auto_parry_debug) then return end
	setthreadidentity(8)
	Logger:short_notify(string.format(...))
end
local thrown = workspace:WaitForChild("Thrown", 9e9);
aztup.maid:give_task(thrown.DescendantAdded:Connect(function(part)
	
	if not (aztup and aztup.flags and aztup_options and local_player) then return end
	if not aztup.flags.auto_parry then return end

	local data;
	for _, item in projectile_effect_data_map do
		if item.is and item.is(part) then
			data = item
			break
		end
	end

	if not data then return end

    local str = data.name or data.actions and data.actions[1] and data.actions[1].name;
    if str and aztup_options.blocked_timings.Value[str] then return end
	
	local actions = action_builder.new()

	actions:get_signal():connect(function(id)
		local action = actions.actions[id]
		if not action then return end

		if not local_player.character or not local_player.root_part then return end

		local user = action.user
		if not user then return end
		if not TargetFilter.is_allowed(user, aztup_options.allowed_targets.Value) then return end

		local hitbox = action.hitbox or Vector3.zero
		local offset = action.offset or CFrame.new()
		local typ = action.type or "Parry"
		local when_s = action.when or 0
		local name = action.name or data.name or "(no name set)"
		local ignore_hitbox = action.ignore_hitbox

		local user_root = part
		if not user_root then return end

		local ping = (Latency and Latency.get_ping and Latency:get_ping()) or 0
		local delay_s = when_s - ping

		local input_task = (data.allow_block_input
			and not aztup_options.blocked_safe_input_moves.Value["Parts"]
			and BlockInputManager:add_task(
				name,
				user,
				function()
					if EffectReplicator:FindEffect("Knocked") then return end
					return ignore_hitbox
						or (not general:in_hitbox(hitbox, offset, local_player.root_part.CFrame, user_root.CFrame, false, action.shape == "ball"))
				end
			)) or { remove = function() end }

		if delay_s > 0 then
			task.wait(delay_s)
		end

		input_task:remove()

		if not ignore_hitbox and not general:in_hitbox(hitbox, offset, local_player.root_part.CFrame, user_root.CFrame, not aztup.flags.view_hitboxes, action.shape == "ball") then
			return
		end

		local user_flag = (user.Name:sub(1, 1) == ".") and "pve_" or "pvp_"

		if EffectReplicator:FindEffect("Knocked") and aztup_options.filters.Value["Dont Parry If Knocked"] then
			debug_print("[%s] Knocked, Skipping action %s", name, typ)
			return
		end

		if aztup.flags[user_flag .. "roll_if_unequipped"] and not EffectReplicator:FindEffect("Equipped") and typ == "Parry" then
			typ = "Dodge"
		end

		if aztup.flags[user_flag .. "auto_equip"] and not EffectReplicator:FindEffect("Equipped") then
			local character_handler = local_player.character:FindFirstChild("CharacterHandler")
			local requests = character_handler and character_handler:FindFirstChild("Requests")
			local equip_weapon = requests and requests:FindFirstChild("DrawWeapon")
			if equip_weapon then
				task.delay(0.1 + (math.random() / 1000), function()
					equip_weapon:FireServer(true)
				end)
			else
				debug_print("failed to find 'DrawWeapon'")
			end
		end

		if aztup_options.filters.Value["Dont Parry If Holding Block"] and general:is_holding_f() then
			setthreadidentity(8)
			debug_print("[%s] Skipping action, Holding F.", name)
			return
		end

		local chance_entry = chance_store:get_entry(data.name or data.id)
		local variation_weights = chance_entry and (chance_entry.outcome_weights or chance_entry.fail_weights or chance_entry.fail_actions)
		local variation_result = variation_weights and (DefendActionManager :: any):execute_failed_parry_variation(user, variation_weights) or "Parry"
		if variation_result ~= "Parry" and variation_result ~= "Dodge" then
			return debug_print("[%s] Action %i chance roll -> %s", name, id, variation_result)
		end

		if variation_result ~= "Parry" then
			debug_print("[%s] Action %i chance roll -> %s", name, id, variation_result)
		end

		if math.random() >= (aztup.flags[user_flag .. "parry_chance"] / 100) then
			debug_print("[%s] Skipping action %i due to global parry chance.", name, id)
			return
		end 
		
		if aztup_options.filters.Value["Dont Parry In Chime Countdown"] and is_chime then
			local simple_prompt = local_player.instance:FindFirstChild("SimplePrompt", true);
			if simple_prompt then
				if simple_prompt:GetAttribute("CurPrompt") and simple_prompt:GetAttribute("CurPrompt") > 1 then
					debug_print("[%s] In chime countdown, skipping action %i", name, id);
					return				
end
			end
		end

		debug_print("[%s] Performing action %i: %s", name, id, typ)

		if variation_result == "Dodge" then
			typ = "Dodge"
			debug_print("[%s] switched action %i to dodge.", name, id)
		end

		if typ == "Parry" then
			if action.allow_parry_to_roll then
				DefendActionManager:queue_generic_parry_task(user)
			else
				DefendActionManager:queue_generic_parry_task_no_convert(user)
			end
		elseif typ == "Dodge" then
			DefendActionManager:add_action(user, "dodge", tick())
		elseif typ == "Forced Full Dodge" then
			DefendActionManager:defend_action_dodge({ mob = user, type = "dodge", full = true, when = tick() })
		end

		return true
	end)

	task.spawn(function()
		if typeof(data.run) ~= "function" then return end
		local base_env = getfenv(data.run)
		local fake_env = setmetatable({
			weapon = require("@src/features/auto-parry/data/weapon"),
			mantra = require("@src/features/auto-parry/data/mantra"),
			thrown = workspace:FindFirstChild("Thrown"),
		}, { __index = base_env })
		setfenv(data.run, fake_env)
		local ok, err = pcall(data.run, actions, part)
		setfenv(data.run, base_env)
		if not ok then
			warn("effect-handler run() failed:", data.name or data.id, err)
		end
	end)
end))