local feature = Feature:new("speed", game:GetService("RunService").PreSimulation, LPH_NO_VIRTUALIZE(function()
    if is_chime and aztup.flags.chime_safety then
        return aztup_toggles.speed:SetValue(false)    
end;

    if aztup.flags.fly then return end


    local direction = Vector3.zero;

    if local_player.humanoid.MoveDirection.Magnitude > 0 then
        direction = local_player.humanoid.MoveDirection.Unit;
    end

    local_player.root_part.AssemblyLinearVelocity *= Vector3.new(0,1,0);
    local_player.root_part.AssemblyLinearVelocity += direction * aztup.flags.walk_speed

    local sensor = local_player.root_part:FindFirstChild("GroundSensor");
    if sensor and sensor.SensedPart then
        local sensed_part = sensor.SensedPart;
        if sensed_part.CollisionGroup == "Ship" then
            local ship_model = sensed_part:FindFirstAncestorOfClass("Model");
            if ship_model and ship_model:FindFirstChild("BodyVelocity", true) then
                local velocity = ship_model:FindFirstChild("BodyVelocity", true).Velocity;
                local_player.root_part.AssemblyLinearVelocity += Vector3.new(velocity.X, 0, velocity.Z);
            end
        end
    end

    return
end));

function feature:enable()
    EffectReplicator:CreateEffect("OverrideSpeedCap");
end;

function feature:disable()
    local effect = EffectReplicator:FindEffect("OverrideSpeedCap");
    if effect then
        effect:Debris(1);
    end;
end;

return feature