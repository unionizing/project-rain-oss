
local feature = Feature:new("auto_roll_cancel");

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if effect.Class == "ClientDodge" then
            task.wait(Random.new():NextNumber(0.1, 0.15));
            
            local client_feint = EffectReplicator:CreateEffect("ClientFeint");
                
            if client_feint then
                client_feint:Debris(0.1);
            end;
        end
	end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;
end;

return feature