
local feature = Feature:new("no_roll_fatigue");

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if effect.Class == "RollCancelFatigue" or effect.Class == "DownComesTheClaw" then
			return task.defer(function()
				effect:Remove(true)
			end)		
end
		return nil	
end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;
end;

return feature