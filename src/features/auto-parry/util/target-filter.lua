local TargetFilter = {}
local reputation_system;

function TargetFilter.get_target_kind(entity: Instance?): string
	if not entity then
		return "Unknown"
	end

	local plr = services.Players:GetPlayerFromCharacter(entity)
	if plr then
		return "PVP"
	end

	if entity.Name and entity.Name:sub(1, 1) == "." then
		return "PVE"
	end

	return "Other"
end

function TargetFilter.is_allowed(entity: Instance?, allowed_targets): boolean
	
	if not allowed_targets then
		return true
	end

	if aztup_options.filters.Value["Dont Parry If Ally"] and aztup.flags.ally_system then
		if entity and entity:IsA("Model") then
			local plr = services.Players:GetPlayerFromCharacter(entity)
			if plr then
				local is_ally = false

				
				if not is_ally
					and table.find(aztup_options.ally_settings.Value, "Deepwoken Allys")
					and local_player
					and local_player.character
					and (function()
						if not reputation_system then
							local modules = services.ReplicatedStorage:WaitForChild("Modules");
							reputation_system = base_require(modules:WaitForChild("ReputationSystem"));
						end

						return reputation_system
					end)()
					and reputation_system:IsAlly(local_player.character, entity)
				then 
					is_ally = true
				end

				
				if not is_ally
					and table.find(aztup_options.ally_settings.Value, "Roblox Friends")
					and general:is_friends_with_sync(plr)
				then
					is_ally = true
				end

				
				if not is_ally
					and table.find(aztup_options.ally_settings.Value, "Custom Players")
				then
					local list = tostring(aztup_options.ally_players_input.Value)
					if #list > 0 then
						for name in string.gmatch(list, "([^;]+)") do
							if plr.Name == name:gsub("^%s*(.-)%s*$", "%1") then
								is_ally = true
								break
							end
						end
					end
				end

				
				if not is_ally
					and table.find(aztup_options.ally_settings.Value, "Custom Guilds")
				then
					local guild = plr:GetAttribute("Guild")
					if typeof(guild) == "string" and #guild > 0 then
						local list = tostring(aztup_options.ally_guilds_input.Value)
						if #list > 0 then
							for g in string.gmatch(list, "([^;]+)") do
								if guild == g:gsub("^%s*(.-)%s*$", "%1") then
									is_ally = true
									break
								end
							end
						end
					end
				end

				
				if not is_ally
					and general:is_teammate(plr)
				then
					if local_player
						and local_player.instance
						and plr
					then
						local my_guild = local_player.instance:GetAttribute("Guild")
						local their_guild = plr:GetAttribute("Guild")
						if typeof(my_guild) == "string"
							and #my_guild > 0
							and my_guild == their_guild
						then
							is_ally = true
						end
					end
				end

				if is_ally then
					return false
				end
			end
		end
	end;

	if allowed_targets.All then
		return true
	end

	local kind = TargetFilter.get_target_kind(entity)

	if kind == "Unknown" then
		return allowed_targets.Unknown == true
	end

	if kind == "PVP" then
		return allowed_targets.PVP == true
	end

	if kind == "PVE" then
		return allowed_targets.PVE == true
	end

	
	return true
end

return TargetFilter
