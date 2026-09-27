
local locked = false

local function playerCheck(mag, custom)
    for _, player in services.Players:GetPlayers() do
        if not player.Character then continue end
        if player == local_player.instance then continue end

        local hrp = player.Character:FindFirstChild("HumanoidRootPart");
        if not hrp then continue end

        local dist = ((custom or local_player.root_part.Position) - hrp.Position).Magnitude;
        if dist <= mag then
            return true        
end
    end
    return false
end

local function has_ankle_weights_equipped()
    local character = local_player.character
    if not character then return false end

    local leg = character:FindFirstChild("Left Leg")
    if not leg then return false end

    return leg:FindFirstChild("AnkleWeight") ~= nil
end

local feature = Feature:new("auto_train_agility", services.RunService.Heartbeat, LPH_NO_VIRTUALIZE(function()
    if not local_player.character or not local_player.root_part or not local_player.humanoid then return end
    if locked then return end
    if EffectReplicator:HasEffect("Knocked") then return end
    if EffectReplicator:FindEffect("Danger") then return end
    if aztup.features.m1_hold.held then return end
    if playerCheck(100) then return end
    if not has_ankle_weights_equipped() then return end
    if ab_builder:missing_for("Agility") <= 0 then return end

    locked = true

    KeyHandler:get_key("Dodge"):FireServer("roll", nil, nil, false);

    task.delay(0.15, function()
        KeyHandler:get_key("StopDodge"):FireServer({
            W = false,
            Right = true,
            S = false,
            NOAERIALS = false
        }, EffectReplicator:HasEffect("LightAttack"));
    end);

    task.delay(0.5, function()
        locked = false
    end)
end))

return feature
