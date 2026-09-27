
local feature;
local passive = "Endurance Runner" 


local function get_passives()
    local effect_replicator = getgenv().EffectReplicator;
    if not effect_replicator then
        local success, result = pcall(require, game:GetService("ReplicatedStorage"):WaitForChild("EffectReplicator"));
        if success then
            effect_replicator = result;
        end;
    end;
    return effect_replicator and effect_replicator.Passives
end;

feature = Feature:new("endurance_runner_spoof", scheduler:add_task(2.5), (function()
    if not local_player.character then return end

    local passives = get_passives();
    if not passives then return end;

    if not passives[passive] then
        passives[passive] = true;
        feature.injected = true;
    end;
end));

function feature:disable()
    local passives = get_passives();
    if passives and self.injected then
        passives[passive] = nil;
    end;
    self.injected = false;
end

return feature