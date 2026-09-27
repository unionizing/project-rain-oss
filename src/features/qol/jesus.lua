local last = tick();
local fake_water = Instance.new("Part");
fake_water.Transparency = 1;
fake_water.Size = Vector3.new(2048, 1, 2048);
fake_water.Anchored = true;
fake_water.Position = Vector3.new(0, 0, 0);
fake_water.Name = "FakeWater";

aztup.maid:give_task(fake_water);

local feature = Feature:new("jesus", scheduler:add_task(0.2), LPH_NO_VIRTUALIZE(function()
    if not is_etrean and not is_eastern then return end
    if not local_player.character then return end

    last = tick();
    fake_water.CFrame = CFrame.new(local_player.root_part.CFrame.X, -3, local_player.root_part.CFrame.Z);

    if not EffectReplicator then return end
    if EffectReplicator:HasEffect("NoSwim") then return end
    EffectReplicator:CreateEffect("NoSwim");
end));

function feature:enable()
    if not is_etrean and not is_eastern then return end
    fake_water.Parent = workspace;
end

function feature:disable()
    fake_water.Parent = nil;

    if not EffectReplicator then return end
    local effect = EffectReplicator:FindEffect("NoSwim");

    if effect then
        effect:Debris(0.1);
    end
end

return feature