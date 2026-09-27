







local feature = Feature:new("show_stored_damage");
local stored_damage_registry = require("@src/utility/stored_damage_registry");
local DataReplication = require(services.ReplicatedStorage.Info.DataReplication);

local function get_closest(poser_attacker)
	local value = poser_attacker.Value;
	local dist = 9e9;
	local targ;

	for _, char in value do
		local their_dist = (local_player.root_part.Position - char:GetPivot().Position).Magnitude;

		if dist > their_dist then
			dist = their_dist;
			targ = char;
		end;
	end;

	return targ
end;

function feature:enable()
	self.recent_target = nil;
	self.last_target_update = 0;
	self.last_ban_tick = 0;

	table.clear(stored_damage_registry);

	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		local has_poser = local_player.instance.Backpack:FindFirstChild("Weapon") and local_player.instance.Backpack:FindFirstChild("Weapon"):GetAttribute("PrimaryWeapon") == "Moppet";
		for _, item in local_player.character:GetChildren() do
			if item.Name ~= "RingEquipment" or item:GetAttribute("DisplayName") ~= "Poser's Ring" then continue end

			has_poser = true;
		end;

		if not has_poser then return end

		if effect.Class == "Unequipping" or effect.Class == "Equipping" then
			table.clear(stored_damage_registry);

			if effect.Class == "Unequipping" then
				self.last_ban_tick = tick();
			end;
		end;

		if effect.Class == "DamagedAnother" then
			local now = tick();
			self.recent_target = effect.Value;
			self.last_target_update = now;

			task.delay(1, function()
				if self.last_target_update == now then
					self.recent_target = nil;
				end;
			end);
		end;

		if effect.Class ~= "LandedLightAttack" or tick() - self.last_ban_tick < 1 then return end
		if not local_player.character or not local_player.root_part then return end

		local start = tick();
		local target do
			repeat
				task.wait();
				target = self.recent_target or (EffectReplicator:FindEffect("PoserAttacker") and get_closest(EffectReplicator:FindEffect("PoserAttacker")));
			until target or tick() - start > 0.5;
		end;

		if not target then return end

		local attach = workspace.Thrown and workspace.Thrown:FindFirstChild("Attach_" .. local_player.character.Name);
		local weapon = attach and attach:FindFirstChild("HandWeapon");
		local weapon_stats = weapon and weapon:FindFirstChild("Stats");
		if not weapon_stats then return end

		local scaling = weapon_stats:FindFirstChild("Scaling");
		if not scaling then return end

		local damage_done = 0;
		damage_done += weapon_stats.Damage.Value;

		local weapon_item = local_player.instance.Backpack:FindFirstChild("Weapon");
		local stars = weapon_item and weapon_item:GetAttribute("Quality") or 0;
		damage_done *= 1 + (0.02 * stars);

		local is_pve = target.Name:sub(1, 1) == "." and (target.Name:find("training_dummy") and target.Name:find("pve") or not target.Name:find("training_dummy"));

		local applied = {};
		for _, scale in scaling:GetChildren() do
			if not local_player.character:GetAttribute("Stat_" .. scale.Name) or applied[scale.Name] then continue end

			applied[scale.Name] = true;
			local scaling_value_pvp = scale.Value < 1 and scale.Value or scale.Value / 100;

			local scaling_amount = local_player.character:GetAttribute("Stat_" .. scale.Name) * scaling_value_pvp;
			damage_done += scaling_amount;
		end;

		if is_pve then
			damage_done *= 1 + (DataReplication.GetData().Level * 0.26);
		end;

		local humanoid = target:FindFirstChildOfClass("Humanoid");
		if not humanoid then return end

		stored_damage_registry[target] = stored_damage_registry[target] or 0;
		stored_damage_registry[target] += damage_done * (target.Name:sub(1, 1) == "." and 1.08 or 1);
		stored_damage_registry[target] = math.clamp(stored_damage_registry[target], 0, humanoid.MaxHealth * 0.7);
	end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
		self.added_hook = nil;
	end;

	table.clear(stored_damage_registry);
end;

return feature