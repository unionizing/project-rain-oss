
local last_update = 0;
local feature;
local passive = "Lightweight" 


local function get_passives()
	local effect_replicator = getgenv().EffectReplicator;
	if not effect_replicator then
		local success, result = pcall(require, game:GetService("ReplicatedStorage"):WaitForChild("EffectReplicator"));
		if success then
			effect_replicator = result;
		end;
	end;
	return effect_replicator and effect_replicator.Passives
end;

feature = Feature:new("lightweight_spoof", game:GetService("RunService").Heartbeat, (function()
	if tick() - last_update < 5 then return end
	if not local_player.character then return end

	last_update = tick();
	local passives = get_passives();
	if not passives then return end;

	if not passives[passive] then
		passives[passive] = true;
		feature.injected = true;
	end;
end));

function feature:enable()
	local passives = get_passives();
	if not passives then return end;

	self.injected = not passives[passive];
	if self.injected then
		passives[passive] = true;
	end;
end;

function feature:disable()
	local passives = get_passives();
	if passives and self.injected then
		passives[passive] = nil;
	end;
	self.injected = false;
end

return feature