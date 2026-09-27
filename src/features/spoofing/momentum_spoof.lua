
local last = 0;

local feat = Feature:new("max_momentum_spoof", services.RunService.Stepped, (function()
    if tick() - last < 0.1 or not EffectReplicator then return end
    if not local_player.character then return end
    last = tick();
    
    local momentum = EffectReplicator:FindEffect("ForceMomentum")
    
    if not momentum then
        EffectReplicator:CreateEffect("ForceMomentum", {Value = 10})
        return
    end

    if momentum.Value ~= 10 then
        momentum.Value = 10
    end
    
    if momentum.Disabled ~= false then
        momentum.Disabled = false 
    end
end))

function feat:disable()
    if not EffectReplicator then return end
    
    local momentum = EffectReplicator:FindEffect("ForceMomentum")
    if momentum then
        momentum.Disabled = true
        momentum.Value = 0 
    end
end

return feat