
local feature = Feature:new("easy_feint");

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if not services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

		local feint_timing: string = aztup_options.easy_feint_timing.Value;

		if effect.Class == "Telegraph_Generic" and feint_timing == "Late" or effect.Class == "LightAttack" and feint_timing == "Early" then 
			if not EffectReplicator:FindEffect("LightAttack") then return end
			local character_handler = local_player.character:FindFirstChild("CharacterHandler");
			local feint_release = character_handler and character_handler:FindFirstChild("FeintRelease", true);
			local feint_click = KeyHandler:get_key("FeintClick");

			if effect.Class ~= "LightAttack" then
				task.wait(effect.DebrisTime - (Latency:get_ping() * 1.2))
			end;

			if not feint_release or not feint_click then return end
						
			feint_click:FireServer({
			    A = false,
			    Left = false,
			    S = false,
			    NOAERIALS = false,
			    Space = false,
			    Right = true,
			    W = false,
			    D = false
			})
				
			feint_release:FireServer({
			    A = false,
			    Left = false,
			    S = false,
			    NOAERIALS = false,
			    Space = false,
			    Right = false,
			    W = false,
			    D = false
			})
		end

		return	
end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;
end;

return feature