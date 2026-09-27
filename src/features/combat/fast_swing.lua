
local feature = Feature:new("fast_swing");

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if table.find({
			"OffhandAttack", 
			"HeavyAttack", 
			"MediumAttack", 
			"LightAttack", 
			"UsingSpell" 
		}, effect.Class) then
			task.defer(function()
                effect:Remove(true)
            end)
		end
	end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;
end;

return feature