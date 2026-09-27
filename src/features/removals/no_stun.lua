
local feature = Feature:new("no_stun");

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if aztup_options.no_stun_items.Value[effect.Class] then
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