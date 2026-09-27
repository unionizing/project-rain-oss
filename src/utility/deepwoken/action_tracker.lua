local tracker = {};
tracker.__index = tracker;

function tracker:can_parry()
	if not EffectReplicator:FindEffect("Equipped") then
		return false
	end

	return not EffectReplicator:FindEffect("ParryCool")
end


function tracker:can_dodge()
	if EffectReplicator:HasAny("NoRoll", "PreventRoll", "Stun") then
		return false
	end

	return true
end

function tracker:activate_request(mantra)
	self.on_mantra_request:Fire(mantra);
end

function tracker.new(player_data)
    local self = setmetatable({}, tracker);
	self.on_mantra_request = Instance.new("BindableEvent");
	self.last_equip_call = false;

	player_data.character_added:connect(function()
		tracker.last_equip_call = false;
	end);

    return self
end

return tracker