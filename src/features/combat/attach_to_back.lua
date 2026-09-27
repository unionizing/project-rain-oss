
local self = Feature:new("attach_to_back", services.RunService.PostSimulation);

function self:get_target()
    local live = workspace:FindFirstChild("Live");
    if not live then return nil end;
    
    local targets = aztup_options.allowed_atb_targets.Value;

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
                if screen_point.X > mouse_x - 90 and screen_point.X < mouse_x + 90 then
                    if screen_point.Y > mouse_y - 90 and screen_point.Y < mouse_y + 90 then
                        return entity                    
end
                end
            end
        end
    end;

    return nil
end;

function self:getting_target()
    local target = self:get_target();

    if target then
        self.highlight.Adornee = target;
        self.highlight.Parent = target;
    else
        self.highlight.Adornee = nil;
        self.highlight.Parent = nil;
    end

    if target and (services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
        self.target = target;
        self.state = "attaching";
    end
end

function self:attaching(dt)
    if not self.target or not self.target:FindFirstChild("HumanoidRootPart") or not self.target.Parent then
        self.state = "getting_target";
        return    
end 

    self.x_offset = math.clamp(self.x_offset,-150, 150)
    self.y_offset = math.clamp(self.y_offset,-150, 150)
    self.z_offset = math.clamp(self.z_offset,-150, 150)

    if self.orig_x_offset ~= aztup.flags.atb_x_offset then
        self.orig_x_offset = aztup.flags.atb_x_offset;
        self.x_offset = aztup.flags.atb_x_offset;
    elseif self.x_offset ~= aztup.flags.atb_x_offset then
        aztup_options.atb_x_offset:SetValue(self.x_offset);
    end

    if self.orig_z_offset ~= aztup.flags.atb_z_offset then
        self.orig_z_offset = aztup.flags.atb_z_offset;
        self.z_offset = aztup.flags.atb_z_offset;
    elseif self.z_offset ~= aztup.flags.atb_z_offset then 
        aztup_options.atb_z_offset:SetValue(self.z_offset);
    end
    
    if self.orig_y_offset ~= aztup.flags.atb_y_offset then
        self.orig_y_offset = aztup.flags.atb_y_offset;
        self.y_offset = aztup.flags.atb_y_offset;
    elseif self.y_offset ~= aztup.flags.atb_y_offset then
        aztup_options.atb_y_offset:SetValue(self.y_offset);
    end

    if services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
        self.x_offset = self.x_offset - (aztup.flags.atb_speed * dt);
    end 

    if services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
        self.x_offset = self.x_offset + (aztup.flags.atb_speed * dt);
    end

    if services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
        self.z_offset = self.z_offset + (aztup.flags.atb_speed * dt);
    end 
    
    if services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
        self.z_offset = self.z_offset - (aztup.flags.atb_speed * dt);
    end

    if services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        self.y_offset = self.y_offset - (aztup.flags.atb_speed * dt);
    end
    
    if services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        self.y_offset = self.y_offset + (aztup.flags.atb_speed * dt);
    end

    local target_cframe = self.target.HumanoidRootPart.CFrame;
    if aztup.flags.atb_lock_rotation then
        target_cframe = CFrame.new(target_cframe.Position);
    end;

    local void_point = workspace:FindFirstChild("Layer2Floor1") and 18.5 or 0;
    if aztup.flags.atb_prevent_voiding and target_cframe.Y < void_point then
        target_cframe = CFrame.new(target_cframe.X, void_point, target_cframe.Z);
    end;

    local back_cframe = target_cframe * CFrame.new(self.x_offset, self.y_offset, self.z_offset);
    local distance = ((back_cframe.Position - local_player.root_part.Position) * Vector3.new(1,0,1)).Magnitude;

    self.highlight.Adornee = self.target;
    self.highlight.Parent = self.target;

    if distance > 30 then
        self.current_tween = Tween.new(back_cframe, true, 150);
    else
        local_player.root_part.CFrame = back_cframe;

        if aztup.flags.atb_rotate then
            local look_cframe = CFrame.new(local_player.root_part.Position, target_cframe.Position);
            local_player.root_part.CFrame = look_cframe;
        end
    end
end

function self.update(dt)
    if self.current_tween then
        self.current_tween.stop();
    end

    self[self.state](self, dt);
end

function self:enable()
    self.x_offset = aztup.flags.atb_x_offset;
    self.z_offset = aztup.flags.atb_z_offset;
    self.y_offset = aztup.flags.atb_y_offset;

    self.orig_x_offset = aztup.flags.atb_x_offset;
    self.orig_z_offset = aztup.flags.atb_z_offset;
    self.orig_y_offset = aztup.flags.atb_y_offset;

    self.state = "getting_target";
    self.target = nil;
    self.highlight = Instance.new("Highlight");
    self.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
    self.highlight.FillColor = Library.AccentColor;
    self.highlight.OutlineColor = Library.AccentColor;
    self.highlight.FillTransparency = 0.9;
    self.highlight.OutlineTransparency = 0;
end

function self:disable()
    if self.current_tween then
        self.current_tween.stop();
    end

    if self.highlight then 
        self.highlight:Destroy();
        self.highlight = nil;
    end
end

self.func = self.update;
return self