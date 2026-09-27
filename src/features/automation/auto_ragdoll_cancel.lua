
local feature = Feature:new("auto_ragdoll_cancel");

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if effect.Class == "Knocked" or effect.Class == "Ragdoll" then
            task.defer(function()
                local character_handler = local_player.character:FindFirstChild("CharacterHandler");
                local feint_release = character_handler and character_handler:FindFirstChild("FeintRelease", true);
                local feint_click = KeyHandler:get_key("FeintClick");

                for i = 1, 4 do
                    task.wait() 
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
            end)
        end
	end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;
end;

return feature