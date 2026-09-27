
local Fallback = require("@src/features/auto-parry/fallbacks/fallback");

return Fallback.new({
    getPriority = function(self)
        return 5 
    end,
    
    shouldExecute = function(self)
        local passives = local_player.character:GetAttribute("ssv_Passives");
        return not EffectReplicator:FindEffect("CriticalCool") and not EffectReplicator:FindEffect("UsingCritical") and passives and passives:find("Curse of the Unbidden") and aztup_options.fallbacks.Value["Curse of the Unbidden"]
    end,

    execute = function(self)
        KeyHandler:get_key("CriticalClick"):FireServer({
            S = false,
            NOAERIALS = false, 
            Space = false,
            Right = false,
            W = false,
            Left = true
        }, false);
    end
})
