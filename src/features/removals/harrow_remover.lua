
local feature = Feature:new("harrow_remover");

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if effect.Class == "Harrowed" then
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