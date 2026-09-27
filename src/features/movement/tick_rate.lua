local RunService = game:GetService("RunService")
local last_update = 0;
local random = Random.new();
local last = tick();
local tick_rate = 1;

local feat = Feature:new("tickrate", RunService.RenderStepped, LPH_NO_VIRTUALIZE(function()
    if EffectReplicator:FindEffect("Knocked") or EffectReplicator:FindEffect("Ragdoll") then return end
    
    local now = tick()
    local dt = now - last

    if dt < 1/12.5 then
        return
    end

    if aztup.flags.fly or aztup.flags.speed or aztup.flags.vehicle_speed then
        last_update = now;
        last = now;
        return    
end

    if now - last_update > 1.5 and aztup and aztup.flags then
        local min = math.min(aztup.flags.min_tick_rate, aztup.flags.max_tick_rate);
        local max = math.max(aztup.flags.min_tick_rate, aztup.flags.max_tick_rate);

        tick_rate = random:NextInteger(min, max);
        last_update = now;
    end

    services.RunService:Pause()
    workspace:StepPhysics(dt * (tick_rate / 100), { local_player.root_part })
    services.RunService:Run()

    last = now;
end));

function feat:enable()
    last = tick();
    last_update = 0;
end;

return feat