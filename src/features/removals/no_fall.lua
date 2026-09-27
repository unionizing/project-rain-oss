local last = tick();
local feature = Feature:new("no_fall", scheduler:add_task(0.1), LPH_NO_VIRTUALIZE(function()
    if not EffectReplicator then return end
    if not local_player.character then return end

    last = tick();
    if EffectReplicator:FindEffect("NoFall") then return end

    EffectReplicator:CreateEffect("NoFall");
end));

function feature:disable()
    if not EffectReplicator then return end

    local effect = EffectReplicator:FindEffect("NoFall");

    if effect then
        effect:Debris(0.1);
    end
end

return feature