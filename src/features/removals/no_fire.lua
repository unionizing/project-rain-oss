
local feature = Feature:new("no_fire");

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if effect.Class == "Burning" then
            KeyHandler:get_key("ServerSlide"):FireServer(true)
            KeyHandler:get_key("ServerSlideStop"):FireServer()	
		end
	end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;
end;

return feature