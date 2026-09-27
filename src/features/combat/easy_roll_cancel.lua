
local feature = Feature:new("easy_roll_cancel");

function feature:go()
	if not EffectReplicator:FindEffect("ClientDodge") then return end

	local client_feint = EffectReplicator:CreateEffect("ClientFeint");
    if client_feint then
        client_feint:Debris(0.1);
    end;
end;

function feature:enable()
	self.input_connection = services.UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		
		self:go();
	end);
end;

function feature:disable()
	if self.input_connection then
		self.input_connection:Disconnect();
		self.input_connection = nil;
	end;
end;

return feature