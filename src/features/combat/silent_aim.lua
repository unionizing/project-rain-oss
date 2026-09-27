

local outline = Drawing.new('Circle')
local fov = Drawing.new('Circle')
local self = Feature:new("silent_aim", services.RunService.PreRender);



fov.Visible = false
fov.ZIndex = 2
fov.NumSides = 100
fov.Thickness = 1
fov.Transparency = 0.3;
outline.Visible = false
outline.Thickness = 2
outline.ZIndex = 1
fov.Filled = true;
outline.NumSides = 100

aztup.maid:give_task(function()
    outline.Visible = false
    fov.Visible = false

    pcall(function()
        outline:Remove();
        fov:Remove();
    end);

    pcall(function()
        outline:Destroy();
        fov:Destroy();
    end);
end);


local safeNAN;
safeNAN = function(v369)  
    
    if v369 == v369 then
        return v369    
elseif typeof(v369) == "Vector3" then
        local l_v369_0 = v369;
        return (Vector3.new(safeNAN(l_v369_0.X), safeNAN(l_v369_0.Y), safeNAN(l_v369_0.Z)))    
elseif typeof(v369) == "CFrame" then
        local l_v369_1 = v369;
        local v372 = safeNAN(l_v369_1.Position);
        local l_Rotation_0 = l_v369_1.Rotation;
        if l_Rotation_0 ~= l_Rotation_0 then
            l_Rotation_0 = CFrame.identity;
        end;
        return CFrame.new(v372) * l_Rotation_0    
elseif typeof(v369) == "number" then
        return v369 == v369 and v369 or 0    
else
        return v369    
end;
end;

function self:enable()
    self.character_added_conn = local_player.instance.CharacterAdded:Connect(function(character)
        self:add_hooks();
    end);

    task.spawn(xpcall, self.add_hooks, Logger.error);
end;

function self:get_gctm(target)
    

    local velocity = target and target.PrimaryPart.Velocity;
    local predicted = target and (velocity * Latency:get_ping()) * (aztup.flags.prediction / 100);
    return safeNAN(CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, target.PrimaryPart.Position + predicted))
end;

function self:get_character_bounding_box(character, orientation)
	
	local minx, miny, minz = math.huge, math.huge, math.huge
	local maxx, maxy, maxz = -math.huge, -math.huge, -math.huge

	
	
	for _, obj in next, character:GetChildren() do
		
		if not obj:IsA("Part") and not obj:IsA("MeshPart") then
			continue
		end

		
		if obj.Name == "HumanoidRootPart" then
			continue
		end

		
		if #obj:GetJoints() <= 0 then
			continue
		end

		
		local cf = orientation:ToObjectSpace(obj.CFrame)
		local size = obj.Size
		local sx, sy, sz = size.X, size.Y, size.Z

		
		local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:GetComponents()

		
		local wsx = 0.5 * (math.abs(R00) * sx + math.abs(R01) * sy + math.abs(R02) * sz)
		local wsy = 0.5 * (math.abs(R10) * sx + math.abs(R11) * sy + math.abs(R12) * sz)
		local wsz = 0.5 * (math.abs(R20) * sx + math.abs(R21) * sy + math.abs(R22) * sz)

		
		local neg_relative_x = x - wsx
		local neg_relative_y = y - wsy
		local neg_relative_z = z - wsz

		
		minx = minx > neg_relative_x and neg_relative_x or minx
		miny = miny > neg_relative_y and neg_relative_y or miny
		minz = minz > neg_relative_z and neg_relative_z or minz

		
		local pos_relative_x = x + wsx
		local pos_relative_y = y + wsy
		local pos_relative_z = z + wsz

		
		maxx = maxx < pos_relative_x and pos_relative_x or maxx
		maxy = maxy < pos_relative_y and pos_relative_y or maxy
		maxz = maxz < pos_relative_z and pos_relative_z or maxz
	end

	
	local omin, omax = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)

	
	return (omax - omin)
end

function self:get_target()
    local live = workspace:FindFirstChild("Live");
    if not live then return nil end;

    if aztup.flags.force_chime_opponent then
        if is_chime and #services.Players:GetPlayers() == 2 then
            local plr = services.Players:GetPlayers()[2];
            local char = plr.Character;
            
            if char and char.PrimaryPart then
                return char            
end;
        end
    end

    local targets = aztup_options.allowed_sa_targets.Value;

    local mouse = local_player.instance:GetMouse();
    local mouse_x = mouse.X;
    local mouse_y = mouse.Y + services.GuiService:GetGuiInset().Y;

    for _, entity in live:GetChildren() do
        local is_mob = entity.Name:sub(1, 1) == ".";
        local is_plr = not is_mob;
        if is_mob and not targets.Mobs then
            continue        
end;

        if is_plr and not targets.Players then
            continue        
end;

        local plr = is_plr and services.Players:GetPlayerFromCharacter(entity);
        local is_gld = is_plr and general:is_teammate(plr);
        if is_gld and not targets.Guildmates then
            continue        
end;

        if not entity.PrimaryPart then
            continue        
end;

        if entity == local_player.character then
            continue        
end;

        local size = Vector3.new(4, 5, 6)
        local floored_position = entity.PrimaryPart.CFrame - (size / 2)
	    local maxs = (floored_position + size).Position
	    local mins = floored_position.Position


	    local points = {
	    	Vector3.new(mins.X, mins.Y, mins.Z),
	    	Vector3.new(mins.X, maxs.Y, mins.Z),
	    	Vector3.new(maxs.X, maxs.Y, mins.Z),
	    	Vector3.new(maxs.X, mins.Y, mins.Z),
	    	Vector3.new(maxs.X, maxs.Y, maxs.Z),
	    	Vector3.new(mins.X, maxs.Y, maxs.Z),
	    	Vector3.new(mins.X, mins.Y, maxs.Z),
	    	Vector3.new(maxs.X, mins.Y, maxs.Z),
	    }

        for idx, point in next, points do
            local screen_point, on_screen = workspace.CurrentCamera:WorldToViewportPoint(point)
            if on_screen then
                if screen_point.X > mouse_x - aztup.flags.fov_radius and screen_point.X < mouse_x + aztup.flags.fov_radius then
                    if screen_point.Y > mouse_y - aztup.flags.fov_radius and screen_point.Y < mouse_y + aztup.flags.fov_radius then
                        return entity                    
end
                end
            end
        end
    end;
    return nil
end;

function self.add_hooks()
    repeat task.wait() until local_player.character
    local character_handler = local_player.character:WaitForChild("CharacterHandler", 9e9);
    character_handler:WaitForChild("InputClient", 9e9);

    task.wait(1);

    local requests = services.ReplicatedStorage:WaitForChild("Requests");
    local get_camera_to_mouse = requests.GetCameraToMouse;

    
    

    

    get_camera_to_mouse.OnClientInvoke = function()
        local target = self:get_target();
        return target and self:get_gctm(target) or safeNAN(CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, local_player.instance:GetMouse().Hit.Position)), EffectReplicator:HasEffect("CameraLock") or false    
end;
end;

function self.update()
    fov.Visible = aztup.flags.show_fov;
    outline.Visible = aztup.flags.show_fov;

    fov.Radius = aztup.flags.fov_radius;
    fov.Filled = aztup.flags.fov_filled;
    fov.Transparency = (1 - aztup.flags.fov_transparency);

    local mouse = local_player.instance:GetMouse();
    fov.Position = Vector2.new(mouse.X, mouse.Y + services.GuiService:GetGuiInset().Y);
    outline.Position = Vector2.new(mouse.X, mouse.Y + services.GuiService:GetGuiInset().Y);

    if tick() - (self.last_target_update or 0) > 1 / 8 then
        self.target = self:get_target();
    end;

    local mouse_pos = mouse.Hit.Position;
    if self.target then
        fov.Color = Library.AccentColor

        local velocity = self.target.PrimaryPart.Velocity;
        local predicted = (velocity * Latency:get_ping()) * (aztup.flags.prediction / 100);
        mouse_pos = self.target.PrimaryPart.Position + predicted;
    else
        fov.Color = Library:GetDarkerColor(Library.AccentColor);
    end

    if not self.last_update_pos or (mouse_pos - self.last_update_pos).Magnitude > 0.1 then
        local v809 = buffer.create(24);
        buffer.writef64(v809, 0, mouse_pos.X);
        buffer.writef64(v809, 8, mouse_pos.Y);
        buffer.writef64(v809, 16, mouse_pos.Z);
        local requests = services.ReplicatedStorage:FindFirstChild("Requests");
        local update_mouse = requests and requests:FindFirstChild("UpdateMouse");

        if update_mouse then
            update_mouse:FireServer(v809);
        end;

        self.last_update_pos = mouse_pos;
    end;
end

function self:disable()
	if self.added_hook then
		self.added_hook:remove();
	end;

    self.target = nil;

    outline.Visible = false
    fov.Visible = false
end;

return self