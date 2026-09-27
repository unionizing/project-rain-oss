local sprint_keys, started_sprint, feature = {
    Enum.KeyCode.W,
    Enum.KeyCode.A,
    Enum.KeyCode.S,
    Enum.KeyCode.D
}, nil, nil;


feature = Feature:new("auto_sprint", services.UserInputService.InputBegan, LPH_NO_VIRTUALIZE(function(input: InputObject, gp: boolean)
    if gp or not table.find(sprint_keys, input.KeyCode) or started_sprint then return end

    started_sprint = true;

    task.delay(aztup.flags.auto_sprint_delay, function()
        if not started_sprint then return end

        local character_handler = local_player.character:FindFirstChild("CharacterHandler");
        local requests = character_handler and character_handler:FindFirstChild("Requests");
        local stop_sprint = requests and requests:FindFirstChild("StopSprint");
        if not stop_sprint then return end

        for _, connection in getconnections(stop_sprint.OnClientEvent) do
            local func = connection.Function;
            if not debug.getinfo(func).source:find("InputClient") then continue end
        
            local sprint_func = getfenv(func).Sprint;
            while local_player.humanoid.MoveDirection.Magnitude >= 0.1 do

                if not EffectReplicator:FindEffect("Sprinting") and not EffectReplicator:FindEffect("ClientCrouch") then
                    sprint_func(true);
                end;

                task.wait();
            end;
        end;
    end);

    local move_direction_conn;
    move_direction_conn = local_player.humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
        if local_player.humanoid.MoveDirection.Magnitude <= 0.1 then
            started_sprint = false;
            move_direction_conn:Disconnect();
            return        
end
    end);
end))

return feature