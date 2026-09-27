
local last_update = 0
local feature
local old_agility
local was_on = false
local parser = require("@src/utility/deepwoken/ssv_parser");

feature = Feature:new("agility_spoofer", game:GetService("RunService").Heartbeat, (function()
        if tick() - last_update < (aztup.flags.agility_spoof_health and 0.075 or 1) then return end
        last_update = tick()

        local character = local_player.character
        if not character then return end

        local passive = character:FindFirstChild("PassiveAgility")
        if not passive then return end

        if aztup.flags.agility_spoofer then
            if not was_on then
                old_agility = passive.Value
                was_on = true
            end

            local target_agility = 8 + (aztup.flags.agility_spoof_amount / 10) * 2;
            if aztup.flags.agility_spoof_health then
                target_agility *= 1 + math.clamp((local_player.humanoid.Health / local_player.humanoid.MaxHealth) * aztup.flags.disallow_scaling_multiplier, 0, aztup.flags.disallow_scaling_multiplier);
            end
            

            passive.Value = target_agility;
        elseif was_on then
            passive.Value = old_agility
            was_on = false
        end
    end
))

function feature:enable()
    local character = local_player.character
    if not character then return end

    local passive = character:FindFirstChild("PassiveAgility")
    if passive then
        old_agility = passive.Value
        was_on = true
    end
end

function feature:disable()
    if not was_on then return end

    local character = local_player.character
    if not character then return end

    local passive = character:FindFirstChild("PassiveAgility")
    if passive and old_agility then
        passive.Value = old_agility
    end

    was_on = false
end

return feature
