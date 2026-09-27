
local feature = Feature:new("auto_ardour");

local function has_passive(passive_name)
	return EffectReplicator and EffectReplicator.Passives and EffectReplicator.Passives[passive_name] ~= nil
end;

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if not local_player.instance or not local_player.character then return end;

		local character = local_player.character;
		if not has_passive("Murmur: Ardour") then return end
		
		local attach = workspace.Thrown and workspace.Thrown:FindFirstChild("Attach_" .. character.Name)
		local weapon = attach and attach:FindFirstChild("HandWeapon")
		if not weapon then return end;

		if weapon:FindFirstChild("ArdourHum") then
			return		
end;

		local character_handler = character:FindFirstChild("CharacterHandler");
		local requests = character_handler and character_handler:FindFirstChild("Requests");
		local ardour = requests and requests:FindFirstChild("Ardour");

		if ardour then
			ardour:FireServer();
		end;

		return nil	
end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;
end;

return feature