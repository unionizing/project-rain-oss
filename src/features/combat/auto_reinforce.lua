
local feature = Feature:new("auto_reinforce");

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if effect.Class == "ParrySuccess" then
			local backpack = local_player.instance:FindFirstChild("Backpack");
			if not backpack then return end;

			local reinforce = backpack:FindFirstChild("Mantra:ReinforceFortitude{{Reinforce}}");
			if not reinforce then return end;
			
			local character_handler = local_player.character:FindFirstChild("CharacterHandler");
			local requests = character_handler and character_handler:FindFirstChild("Requests");
			local activate_mantra = requests and requests:FindFirstChild("ActivateMantra");

			activate_mantra:FireServer(reinforce)			
		end 

		return nil	
end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;
end;

return feature