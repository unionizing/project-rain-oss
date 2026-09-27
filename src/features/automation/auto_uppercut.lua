
local feature = Feature:new("auto_uppercut");

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if effect.Class == "Crouching" then
    		KeyHandler:get_key("LeftClick"):FireServer(false, local_player.instance:GetMouse().Hit, {
				S = false,
				NOAERIALS = false, 
				Space = false,
				Right = false,
				W = false,
				Left = true,
				ctrl = true
    		}); 
		end
	end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;
end;

return feature