local modded_parts = {};
local feat;
feat = Feature:new("vehicle_speed", game:GetService("RunService").Heartbeat, function(dt)
    local steering = EffectReplicator:FindEffect("Steering") or EffectReplicator:FindEffect("RootedGesture");
    local class = steering and steering.Class;
    if not steering then 
        aztup_toggles.vehicle_speed:SetValue(false);
        if aztup.flags.vehicle_noclip then
            aztup_toggles.vehicle_noclip:SetValue(false);
        end
        Logger:notify_sound("Not steering a boat. Toggling off boat speed.");
        return    
end
    local move_direction = local_player.humanoid.MoveDirection;
    

    steering = steering.Value;

    if class == "RootedGesture" then 
        steering = steering.Part0;
        sethiddenproperty(local_player.humanoid, "MoveDirectionInternal", Vector3.zero);
    end

    if not steering then return end
    local ship = steering:FindFirstAncestorWhichIsA("Model");
    if not ship then return end
    local character_handler = local_player.character:FindFirstChild("CharacterHandler");
    if not character_handler then return end
    local equip_weapon = character_handler.Requests.DrawWeapon;
    if not equip_weapon then return end

    local rep_requests = services.ReplicatedStorage:WaitForChild("Requests");
    rep_requests.MapOpen:FireServer(true);
    rep_requests.MapOpen:FireServer(false)
    equip_weapon:FireServer(true);
    feat.mapped = true;
    
    local bv: BodyVelocity = ship:FindFirstChild("BodyVelocity", true);
    if bv then
        bv.Velocity = move_direction.Magnitude > 0 and move_direction.Unit * aztup.flags.boat_speed or Vector3.zero;
        bv.P = move_direction.Magnitude > 0 and 9e9 or 0;
        bv.MaxForce = move_direction.Magnitude > 0 and Vector3.new(9e9, 9e9, 9e9) or Vector3.zero;
    end;

    for _, part in ship:GetDescendants() do
        if part:IsA("BasePart") then
            if aztup.flags.vehicle_noclip and part.CanCollide then
                part.CanCollide = false;
                table.insert(modded_parts, part);
            end;
        end;
    end;
end)

function feat:disable()
    for _, part in modded_parts do
        if part then
            part.CanCollide = true;
        end;
    end;

    table.clear(modded_parts);

    if self.mapped then
        local rep_requests = services.ReplicatedStorage:WaitForChild("Requests");
        for i = 1, 100 do
            rep_requests.MapOpen:FireServer(false)
            task.wait();
        end
    end
end

return feat