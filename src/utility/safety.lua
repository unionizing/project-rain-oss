
local Safety = {};

function Safety:MobsNear(part : BasePart | CFrame, distance): number
    if not distance then distance = 200; end

    local players_near = 0;
    for _, mob in workspace.Live:GetChildren() do
        if not mob:FindFirstChild("HumanoidRootPart") then continue end;
        
        local mob_distance = (part.Position - mob:GetPivot().Position).Magnitude;
        if mob_distance <= distance then
            players_near = players_near + 1;
        end;
    end;
    
    return players_near
end;

function Safety:PlayersNear(part : BasePart | CFrame, distance): number
    if not distance then distance = 200; end

    local players_near = 0;
    for _, player in services.Players:GetPlayers() do
        if player == local_player.instance then continue end;
        if not player.Character then continue end;
        
        local player_distance = (part.Position - player.Character:GetPivot().Position).Magnitude;
        if player_distance <= distance then
            players_near = players_near + 1;
        end;
    end;
    
    return players_near
end;

function Safety:PlayerNear(magnitude): boolean
    if not magnitude then magnitude = 300; end
    
    for _, player in services.Players:GetPlayers() do
        if player == local_player.instance then continue end
        if not player.Character then continue end
        
        local dist = (local_player.root_part.Position - player.Character:GetPivot().Position).Magnitude
        if dist <= magnitude then
            return true
        end
    end
    
    return false
end

function Safety:PlayerSafeTween(cf, speed, ylevel)
    local function serverhop()
        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:hop(slot, 'any', true)
    end

    if not speed then speed = 250; end
    
    if self:PlayerNear() then
        serverhop()
        while task.wait() do end
    end
    
    if not ylevel then
        ylevel = math.random(8000, 10000)
    end
    
    local_player.root_part.CFrame = local_player.root_part.CFrame + Vector3.new(0, local_player.root_part.CFrame.Y + ylevel, 0)
    
    Tween.new(cf + Vector3.new(0, cf.Y + ylevel, 0), true, speed).wait()
    
    
    if self:PlayersNear(cf, 200) > 0 then
        serverhop()
        while task.wait() do end
    end
    
    
    local_player.root_part.CFrame = cf
end

function Safety:InDanger(): boolean
    return (local_player.humanoid:GetAttribute("DangerExpiration") and local_player.humanoid:GetAttribute("DangerExpiration") > 0)
end

return Safety