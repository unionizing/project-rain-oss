
local Fallback = require("@src/features/auto-parry/fallbacks/fallback");

return Fallback.new({
    getPriority = function(self)
        return 1 
    end,
    
    shouldExecute = function(self)
        local character = local_player.character
        if not character then
            return false
        end
    
        local tempo = character:FindFirstChild("Tempo")
        if not tempo then
            return false
        end
    
        if tempo.Value < 40 then
            return false
        end
    
        if not EffectReplicator:HasEffect("Equipped") then
            return false
        end
    
        if EffectReplicator:HasEffect("NoBurst") then
            return false
        end    

        return aztup_options.fallbacks.Value["Vent"]
    end,

    execute = function(self)
        local character_handler = local_player.character:FindFirstChild("CharacterHandler");
        local requests = character_handler and character_handler:FindFirstChild("Requests");
        local vent = requests and requests:FindFirstChild("Vent");

        if vent then
            vent:FireServer();
        end
    end
})
