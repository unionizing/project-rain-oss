
local feature = Feature:new("mantra_slidecasting");
local Keybinds = base_require(game:GetService("ReplicatedStorage"):WaitForChild("KeyBinds"));

function feature:enable()
	self.on_mantra_req = local_player.tracker.on_mantra_request.Event:Connect(function(mantra)
		local backpack = local_player.instance:FindFirstChild("Backpack");
		if not backpack then return nil end;

		local ether = local_player.character:FindFirstChild("Ether");
		if not ether or ether.Value <= mantra:GetAttribute("SpellCost") then
			return nil		
end

		if math.random() > aztup.flags.mantra_slidecasting_chance / 100 then
			return nil		
end

		if EffectReplicator:HasAny(
			"AirCombo",
			"NoSlide",
			"Action",
			"MobileAction",
			"UsingAbility",
			"LightAttack",
			"Blocking",
			"Parried",
			"ClientSlide2",
			"ClientSwim"
		) then
			return		
end;
		
        local v298 = Ray.new(local_player.root_part.Position, (Vector3.new(0, -10, 0)));
        local l_workspace_PartOnRayWithIgnoreList_1, _, _ = workspace:FindPartOnRayWithIgnoreList(v298, {
            workspace:WaitForChild("Live"), 
            workspace:WaitForChild("NPCs"), 
            workspace:WaitForChild("Thrown")
        });

		local l_MoveDirection_0 = local_player.humanoid.MoveDirection;
        if l_MoveDirection_0.Magnitude <= 0.1 then
			return nil        
end

		if not l_workspace_PartOnRayWithIgnoreList_1 then
			return nil		
end;

		if not EffectReplicator:FindEffect("Sprinting") then
			return nil		
end;

		if mantra and aztup_options.mantra_slidecasting_mantras.Value[mantra:GetAttribute("DefaultName")] then
			if not EffectReplicator:FindEffect("CastingSpell") then
				local casting_spell = EffectReplicator:CreateEffect("CastingSpell");
				if casting_spell then
					casting_spell:Debris(0.05); 
				end;
			end;

			Keybinds.ForceActionDown("Crouch")
			Keybinds.ForceActionUp("Crouch")
			
		end

		return nil	
end)
end;

function feature:disable()
	if self.on_mantra_req then
		self.on_mantra_req:Disconnect();
	end;
end;

return feature