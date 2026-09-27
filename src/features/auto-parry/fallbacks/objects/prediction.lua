
local Fallback = require("@src/features/auto-parry/fallbacks/fallback");

return Fallback.new({
    getPriority = function(self)
        return 4 
    end,
    
    shouldExecute = function(self)
        local backpack = local_player.instance:FindFirstChild("Backpack");
        if not backpack then return end;

        local equalizer = backpack:FindFirstChild("Mantra:PredictionIntelligence{{Prediction}}");
        if not equalizer then return end;    

        local ether = local_player.character:FindFirstChild("Ether");
        if not ether or ether.Value < equalizer.Cost.Value + 50 then return end;

        for _, effect in EffectReplicator:GetEffects() do
            if effect.Class == "ToolLockCD" then
                if effect.Value == "Mantra:PredictionIntelligence{{Prediction}}" then
                    return                
end
            end
        end

        return aztup_options.fallbacks.Value["Prediction"]    
end,

    execute = function(self)
        local backpack = local_player.instance:FindFirstChild("Backpack");
        if not backpack then return end;

        local equalizer = backpack:FindFirstChild("Mantra:PredictionIntelligence{{Prediction}}");
        if not equalizer then return end;   
			
		local character_handler = local_player.character:FindFirstChild("CharacterHandler");
		local requests = character_handler and character_handler:FindFirstChild("Requests");
		local activate_mantra = requests and requests:FindFirstChild("ActivateMantra");

        if not activate_mantra then return end;

		activate_mantra:FireServer(equalizer)			
    end
})
