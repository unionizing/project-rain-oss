local feature_class, was_on;
feature_class = Feature:new("no_sea");

function feature_class:enable()
    was_on = true;
    
    local_player.instance:AddTag("NoSea")
    local_player.instance:AddTag("LowGraphics")

    services.RunService:UnbindFromRenderStep("SeaWater");
    
    task.wait(0.2);
    local player_scripts = local_player.instance:FindFirstChild("PlayerScripts");
    if not player_scripts then return end;
    player_scripts.SeaClient.Enabled = false;
end;

function feature_class:disable()
    if was_on then
        was_on = false;
        local_player.instance:RemoveTag("NoSea")

        local player_scripts = local_player.instance:FindFirstChild("PlayerScripts");
        if not player_scripts then return end;
        player_scripts.SeaClient.Enabled = true;
    end;
end;

return feature_class