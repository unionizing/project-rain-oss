
local feature = Feature:new("backstab_movestacker");

function feature:enable()
    local ready = false;
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if effect.Class == "backstabDebounce" then
            ready = true;
            task.delay(3, function()
                ready = false;
            end)
        end
	end);
 
    self.removed_hook = EffectReplicatorHandler:hook("removed", function(effect)
		if effect.Class == "Action" and ready then
            task.wait(Latency:half_ping())
            ready = false;

            local backpack = local_player.instance:FindFirstChild("Backpack");
			if not backpack then return end;

            local mantras = table.clone(aztup_options.backstab_movestacker_mantras.Value);
            local decided_mantra;
	        for _, effect in EffectReplicator:GetEffects() do
	        	if effect.Class == "ToolLockCD" then
	        		local tool = backpack:FindFirstChild(effect.Value);
                    if tool and tool:GetAttribute("DefaultName") then
                        mantras[tool:GetAttribute("DefaultName")] = nil;
                    end
	        	end
	        end

            decided_mantra = next(mantras);
            if not decided_mantra then return end

            local mantra_tool;
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:GetAttribute("DefaultName") == decided_mantra then
                    mantra_tool = tool;
                    break                
end
            end
            
			if not mantra_tool then return end;
			
			local character_handler = local_player.character:FindFirstChild("CharacterHandler");
			local requests = character_handler and character_handler:FindFirstChild("Requests");
			local activate_mantra = requests and requests:FindFirstChild("ActivateMantra");

			activate_mantra:FireServer(mantra_tool)			
		end
	end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;
    
	if self.removed_hook then
		self.removed_hook:remove();
	end;
end;

return feature