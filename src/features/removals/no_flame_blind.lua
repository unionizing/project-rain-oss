local old_f;
local feature = Feature:new("no_flame_blind");

function feature:enable()
    local m = base_require(game:GetService("ReplicatedStorage").ClientEffectModules.Attacks.Blade);
    old_f = hookfunction(m.BigFlash, LPH_NO_VIRTUALIZE(function() end));
end

function feature:disable()
    if old_f then
        local m = base_require(game:GetService("ReplicatedStorage").ClientEffectModules.Attacks.Blade);
        hookfunction(m.BigFlash, old_f);
    end
end

return feature