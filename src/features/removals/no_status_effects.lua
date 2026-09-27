
local feature = Feature:new("no_status_effects");

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		task.defer(function()
            effect:Remove(true)
        end)
	end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;
end;

return feature