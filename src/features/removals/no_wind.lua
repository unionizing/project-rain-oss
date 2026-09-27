return Feature:new("no_wind", game:GetService("RunService").PreSimulation, LPH_NO_VIRTUALIZE(function()
    if not local_player.character and not local_player.root_part or is_chime then return end

    if local_player.root_part:FindFirstChild("WindPusher") then
        local_player.root_part:FindFirstChild("WindPusher").Parent = nil
    end

    if not EffectReplicator then return end

    local StrongWindEffect = EffectReplicator:FindEffect("StrongWind");
    local StrongWindPos = StrongWindEffect and StrongWindEffect.Value
    local StrongWind = StrongWindPos and workspace.Thrown:FindFirstChild("WindSide")
    
    if StrongWind then
        local cf = CFrame.new(Vector3.new(), StrongWindPos)
        local WindPosition = CFrame.new(workspace.CurrentCamera.CFrame.p) * cf * CFrame.new(3, -5, 50)
        local LookCF = CFrame.new(local_player.root_part.Position, Vector3.new(WindPosition.Position.X, local_player.root_part.Position.Y, WindPosition.Position.Z))
        local_player.root_part.CFrame = LookCF;
    end
end))