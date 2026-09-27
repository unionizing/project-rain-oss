local tbl = {}
tbl['ArdourSlicer'] = (function() 
return {
    id = "ArdourSlicer",
    name = "ArdourSlicer",
    is = function(part)
        return part.Name:find("ArdourSlash_")
    end,
    
    run = function(action, part)
        local name = part.Name:split("ArdourSlash_")[2]
        local user do
            local player = game:GetService("Players")[name]
            user = player and player.Character
        end;
 
        if not user or user == local_player.instance then return end
        
        while task.wait(0.00) do
            if not part.Parent then break end
            if  
                not general:in_hitbox(Vector3.new(10, 8, 50 + part.Velocity.Magnitude), CFrame.new(0,0,-7.5 + part.Velocity.Magnitude), local_player.root_part.CFrame, part.CFrame, false, false)
            then
                continue            
end;

            action.ignore_hitbox = true;
            action.when = 0;
            action.user = user;
            action:play();  
            return        
end;             
    end;
}   
 end)();
tbl['ArrowM1'] = (function() 
return {
    id = "ArrowM1",
    name = "ArrowM1",
    is = function(part)
        return part.Name:find("ArrowModel_")
    end,
    
    run = function(action, part)
        local name = part.Name:split("ArrowModel_")[2]
        local user do
            local player = game:GetService("Players")[name]
            user = player and player.Character
        end;
 
        if not user or user == local_player.instance then return end
        
        while task.wait(0.03) do
            if not part.Parent then break end
            if  
                not general:in_hitbox(Vector3.new(10, 8, 30 + part.Velocity.Magnitude), CFrame.new(0,0,-7.5 + part.Velocity.Magnitude), local_player.root_part.CFrame, part.CFrame, false, false)
            then
                continue            
end;

            action.ignore_hitbox = true;
            action.when = 0;
            action.user = user;
            action:play();  
            return        
end;             
    end;
}   
 end)();
tbl['BloodOrb'] = (function() 
return {
    id = "BloodOrb",
    name = "BloodOrb",
    is = function(part)
        return part.Name:find("BloodBall_")
    end,
    
    run = function(action, part)
        local name = part.Name:split("BloodBall_")[2]
        local user do
            local player = game:GetService("Players")[name]
            user = player and player.Character
        end;
 
        if not user or user == local_player.instance then return end
        
        action.hitbox = Vector3.new(10, 10, 40);
        action.when = 0;
        action.user = user;
        action:play(); 
        if  
            general:in_hitbox(Vector3.new(40, 10, 40), CFrame.identity, local_player.root_part.CFrame, part.CFrame, false, false)
        then
            return        
end;

        while task.wait(0.00) do
            if not part.Parent then break end

            local compensation = (10 * Latency:get_ping());
            if  
                not general:in_hitbox(Vector3.new(30 + compensation, 10, 30 + compensation), CFrame.identity, local_player.root_part.CFrame, part.CFrame, false, false)
            then
                continue            
end;

            action.ignore_hitbox = true;
            action.when = 0;
            action.user = user;
            action:play();  
            return        
end;             
    end;
}   
 end)();
tbl['CrimsonRain'] = (function() 
return {
    id = "CrimsonRainDagger",
    name = "CrimsonRainDagger",
    is = function(part)
        return part.Name:find("BloodDagger_")
    end,
    
    run = function(action, part)
        local name = part.Name:split("BloodDagger_")[2]
        local user do
            local player = game:GetService("Players")[name]
            user = player and player.Character
        end;
 
        if not user or user == local_player.instance then return end
        
        while task.wait(0.00) do
            if not part.Parent then break end
            if  
                not general:in_hitbox(Vector3.new(5, 8, 20 + part.Velocity.Magnitude), CFrame.new(0,0,-7.5 + part.Velocity.Magnitude), local_player.root_part.CFrame, part.CFrame, false, false)
            then
                continue            
end;

            action.ignore_hitbox = true;
            action.when = 0;
            action.user = user;
            action:play();  
            return        
end;             
    end;
}   
 end)();
tbl['FireDagger'] = (function() 
return {
    id = "FireDagger",
    name = "FireDagger",
    is = function(part)
        return part.Name:find("FireDagger_")
    end,
    
    run = function(action, part)
        local name = part.Name:split("FireDagger_")[2]
        local user do
            local player = game:GetService("Players")[name]
            user = player and player.Character
        end;
 
        if not user or user == local_player.instance then return end
        
        while task.wait(0.00) do
            if not part.Parent then break end
            if  
                not general:in_hitbox(Vector3.new(5, 15, 3 + part.Velocity.Magnitude), CFrame.new(0,0,0 + part.Velocity.Magnitude), local_player.root_part.CFrame, part.CFrame, false, false)
            then
                continue            
end;

            action.ignore_hitbox = true;
            action.when = 0;
            action.user = user;
            action:play();  
            return        
end;             
    end;
}   
 end)();
tbl['FiringLineBlast'] = (function() 
return {
	id = "CannonBullet",
	name = "CannonBullet",

	is = function(part)
		return part.Name == "CannonBullet"
	end,

	run = function(action, part)
		local minDist = math.huge

		repeat
			task.wait()
			if part.Parent then
				local dist = (local_player.root_part.Position - part.Position).Magnitude
				if dist < minDist then
					minDist = dist
				end
			end
		until not part.Parent or minDist <= 50

		if not part.Parent then
			return
		end

		action.type = "Parry"
		action.when = 0.1
		action.name = string.format("CannonBullet-%.2f", minDist)
		action.hitbox = Vector3.new(10, 10, 10)
		action.ignore_hitbox = true
		action.user = part
		action.allow_parry_to_roll = true
		action:play()

		return action
	end,
}

 end)();
tbl['RisingShadowPart'] = (function() 
return {
	id = "RisingShadowPart",
	name = "RisingShadowPart",

	is = function(part)
		return part.Name == "TRACKER"
	end,

	run = function(action, part)
		local minDist = math.huge

		repeat
			task.wait()
			if part.Parent then
				local dist = (local_player.root_part.Position - part.Position).Magnitude
				if dist < minDist then
					minDist = dist
				end
			end
		until not part.Parent or minDist <= 50

		if not part.Parent then
			return
		end

		action.type = "Parry"
		action.when = 0.5
		action.name = string.format("RisingShadowPart-%.2f", minDist)
		action.hitbox = Vector3.new(10, 10, 10)
		action.ignore_hitbox = true
		action.user = part
		action.allow_parry_to_roll = true
		action:play()

		return action
	end,
}

 end)();
tbl['Scrapsingerbullet'] = (function() 
return {
    id = "ScrapsingerBullet",
    name = "ScrapsingerBullet",
    is = function(part)
        return part.Name:find("ScrapsingerBullet_")
    end,
    
    run = function(action, part)
        local name = part.Name:split("ScrapsingerBullet_")[2]
        local user do
            local player = game:GetService("Players")[name]
            user = player and player.Character
        end;
 
        if not user or user == local_player.instance then return end
        
        while task.wait(0.00) do
            if not part.Parent then break end
            if  
                not general:in_hitbox(Vector3.new(10, 8, 50 + part.Velocity.Magnitude), CFrame.new(0,0,-7.5 + part.Velocity.Magnitude), local_player.root_part.CFrame, part.CFrame, false, false)
            then
                continue            
end;

            action.ignore_hitbox = true;
            action.when = 0.1;
            action.user = user;
            action:play();  
            return        
end;             
    end;
}   
 end)();
tbl['SpearPartSplinter'] = (function() 
return {
	id = "SpearPartSplinter",
	name = "SpearPartSplinter",

	is = function(part)
		return part.Name == "SpearPartSplinter"
	end,

	run = function(action, part)
		local minDist = math.huge

		repeat
			task.wait()
			if part.Parent then
				local dist = (local_player.root_part.Position - part.Position).Magnitude
				if dist < minDist then
					minDist = dist
				end
			end
		until not part.Parent or minDist <= 50

		if not part.Parent then
			return
		end

		action.type = "Parry"
		action.when = 0
		action.name = string.format("Grand Spark Splinter (%.1f)", minDist)
		action.hitbox = Vector3.new(20, 20, 70)
		action.ignore_hitbox = true
		action.user = part
		action.allow_parry_to_roll = true
		action:play()

		return action
	end,
}

 end)();
tbl['StrikeIndicator'] = (function() 
return {
	id = "StrikeIndicator",
	name = "Lightning Strike",

	is = function(part)
		if part.Name ~= "StrikeIndicator" then
			return false
		end

		
		for _, player in game:GetService("Players"):GetPlayers() do
			if player == game:GetService("Players").LocalPlayer then
				continue
			end
			local character = player.Character
			if not character then
				continue
			end
			local animator = character:FindFirstChild("Animator", true)
			if not animator then
				continue
			end
			for _, track in animator:GetPlayingAnimationTracks() do
				local id = track.Animation.AnimationId:match("%d+")
				if id == "8857099063" then 
					return false
				end
			end
		end

		return true
	end,

	run = function(action, part)
		action.type = "Parry"
		action.when = 0.35
		action.name = "Lightning Strike"
		action.ignore_hitbox = false
        action.hitbox = Vector3.new(0, 0, 10)
		action.user = part
		action.allow_parry_to_roll = true
		action:play()

		return action
	end,
}

 end)();
return tbl