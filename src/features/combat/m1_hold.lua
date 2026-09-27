local self;
self = Feature:new("m1_hold", services.RunService.RenderStepped, LPH_NO_VIRTUALIZE(function()
    if not self.held then return end
    if not EffectReplicator:FindEffect("Equipped") then return end
    if aztup.flags.block_input and BlockInputManager:should_block_input() and aztup_options.blocked_safe_input_user_moves.Value.M1s then return end

    local remote = KeyHandler:get_cache("LeftClick") or KeyHandler:get_key("LeftClick");
    if not remote or not remote:IsDescendantOf(local_player.character) or not remote.Parent then
        remote = KeyHandler:get_key("LeftClick");
    end


    if not remote then return end
    remote:FireServer(not aztup.flags.no_aerials and general:in_air(), local_player.instance:GetMouse().Hit, {
		S = false,
		NOAERIALS = aztup.flags.no_aerials, 
		Space = false,
		Right = services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2),
		W = false,
		Left = true,
        ctrl = services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
    }); 
end));

function self:enable()
    pcall(function()
        game:GetService("ReplicatedStorage").Requests.UpdateUXSettings:FireServer("HoldM1", false);
    end);

    self.input_began_connection = services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        self.held = true;
    end);

    self.input_ended_connection = services.UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        self.held = false;
    end);
end;
 
function self:disable()
    if self.input_began_connection then
        self.input_began_connection:Disconnect();
        self.input_began_connection = nil;
    end

    if self.input_ended_connection then
        self.input_ended_connection:Disconnect();
        self.input_ended_connection = nil;
    end

    self.held = false;
end;

return self