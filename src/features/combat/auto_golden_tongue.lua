
local feature = Feature:new("auto_golden_tongue");
local last_update = 0;

function feature:enable()
	self.added_hook = EffectReplicatorHandler:hook("added", function(effect)
		if os.clock() - last_update < 1 then return end;
		if not aztup.flags.auto_golden_tongue then return end

		local character = local_player.character;
		local passives = character:GetAttribute("ssv_Passives");
		if passives and not passives:find("Golden Tongue") then return end

		local replicator = getgenv().EffectReplicator;
		if not replicator then return end; 

		if not replicator:FindEffect("Danger") then return end
		if replicator:FindEffect("GoldCool") then
			return		
end;

		local textservice = game:GetService("TextChatService");
		local channels = textservice:FindFirstChild("TextChannels");
		local general = channels and channels:FindFirstChild("RBXGeneral");
		local system = channels and channels:FindFirstChild("RBXSystem");
		local mode = aztup_options.auto_golden_tongue_mode.Value;

		if system and mode == "Blatant" then
			last_update = os.clock();
			system:SendAsync("/e");
		elseif general and mode == "Legit" then
			local key = ({
				[0] = "w",
				[1] = "a",
				[2] = "s",
				[3] = "d",
			})[math.random(0,3)];

			last_update = os.clock();
			general:SendAsync(key);
		end;
		
		return nil	
end);
end;

function feature:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;
end;

return feature