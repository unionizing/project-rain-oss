
local historys = {};
local position_player = {};
local objects = {};
position_player.__index = position_player;

position_player.make = function(player)
    local self = setmetatable({}, position_player);
    historys[player] = {};

    self.player = player;

    player.AncestryChanged:Connect(function()
        local history = historys[player];
        if history then
            table.clear(history);
            historys[player] = nil;
        end;
    end);

    return self
end;

position_player.track = function(self, position)
    local player = self.player;
    local history = historys[player];

    if #history >= 10 then
        table.remove(history, 1);
    end;

    table.insert(history, {
        timestamp = tick(),
        position = position
    });
end;

objects.__index = objects;

aztup.maid:give_task(function()
    for _, object in historys do
        table.clear(object);
        object = nil;
    end;

    table.clear(historys);
    table.clear(objects);
end);

aztup.maid:give_task(services.Players.PlayerAdded:Connect(function(player)
    objects[player] = position_player.make(player);
end));

for _, player in services.Players:GetPlayers() do
    objects[player] = position_player.make(player);
end;

aztup.maid:give_task(services.Players.PlayerRemoving:Connect(function(player)
    local history = historys[player];
    if history then
        table.clear(history);
        historys[player] = nil;
        objects[player] = nil;
    end;
end));

objects.get_history = function(player)
    return historys[player] or {}
end;

objects.yrate = function(player)
    local history = historys[player]
    if not history or #history < 2 then
        return nil
    end

    local latest = history[#history]
    local previous = history[#history - 1]
    local dt = latest.timestamp - previous.timestamp
    if dt <= 1e-4 then
        return nil
    end

    local prevLook = Vector3.new(previous.position.LookVector.X, 0, previous.position.LookVector.Z).Unit
    local latestLook = Vector3.new(latest.position.LookVector.X, 0, latest.position.LookVector.Z).Unit
    local dot = prevLook:Dot(latestLook)
    local crossY = prevLook:Cross(latestLook).Y
    local angle = math.atan2(crossY, dot)
    return angle / dt
end

objects.predict_rotation = function(player, dt)
    local history = historys[player]
    if not history or #history < 2 then
        return nil
    end

    local latest = history[#history]
    local previous = history[#history - 1]
    local deltaTime = latest.timestamp - previous.timestamp
    if deltaTime <= 1e-4 then
        return nil
    end

    local prevLook = Vector3.new(previous.position.LookVector.X, 0, previous.position.LookVector.Z).Unit
    local latestLook = Vector3.new(latest.position.LookVector.X, 0, latest.position.LookVector.Z).Unit
    local dot = prevLook:Dot(latestLook)
    local crossY = prevLook:Cross(latestLook).Y
    local angle = math.atan2(crossY, dot)
    local angularVelocity = angle / deltaTime

    local predictedAngle = angle + angularVelocity * dt
    local predictedRotation = CFrame.Angles(0, predictedAngle, 0)

    return predictedRotation, angularVelocity
end

objects.predict = function(player, dt, opts)
    local history = historys[player]
    if not history or #history < 2 then
        return nil
    end

    local latest = history[#history]
    local previous = history[#history - 1]

    local deltaTime = latest.timestamp - previous.timestamp
    if deltaTime <= 1e-4 then
        return nil
    end

    local delta = latest.position.Position - previous.position.Position
    local velocity = delta / deltaTime

    local predictedPos = latest.position.Position + velocity * dt

    local predicted = CFrame.new(predictedPos)

    local angularVelocity

    if opts.predict_rotation then
        angularVelocity = objects.yrate(player)

        if angularVelocity then
            predicted *= latest.position.Rotation *
                CFrame.Angles(0, angularVelocity * dt, 0)
        else
            predicted *= latest.position.Rotation
        end
    else
        predicted *= latest.position.Rotation
    end

    return predicted,{
        dt = dt,
        deltaTime = deltaTime,
        delta = delta,
        velocity = velocity,
        latest = latest.position,
        previous = previous.position,
        predictedPos = predictedPos,
        angularVelocity = angularVelocity,
    }
end

objects.our_predicted_position = function()
    
    
    local time = tick() - (Latency:half_ping())
    local history = historys[local_player.instance]

    table.sort(history, function(a, b)
        return a.timestamp < b.timestamp
    end);

    for i = #history,1,-1 do
        local object = history[i]

        if object.timestamp <= time then
            return object.position
        end
    end

    return local_player.root_part.CFrame
end

scheduler:add_task(1 / 15):Connect(function()
    for player, position_player in objects do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if character and hrp then
            local position = hrp.CFrame
            position_player:track(position)
        end
    end
end);

return objects