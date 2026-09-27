
local feature = Feature:new("no_speed_debuff");

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if effect.Class == "Speed" and effect.Value < 0 or effect.Class == "SpeedOverride"  and effect.Value < 14 then
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