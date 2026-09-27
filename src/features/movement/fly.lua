local current_bv;
local bv = Instance.new("BodyVelocity");
bv.Name = "SlideVel";
bv.MaxForce = Vector3.new(1000000, 1000000, 1000000);
bv:AddTag("AllowedBM");
local collision_utils = base_require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("CollisionUtils"));
    local spoofing = false;
    local old_y;

local function with_y(cframe, y)
    return CFrame.new(cframe.X, y, cframe.Z) * (cframe - cframe.Position)
end

local last_cap_artist_time = 0;
local last_knocked_time = 0;
local function is_aa_bypass_mode_activated(type)
    return aztup.flags.aa_bypass and not aztup.automation.requesting_aa_bypass_stop and aztup_options.aa_bypass_mode.Value == type
end;

local function do_cap_artist_bypass()
    local character_handler = local_player.character:FindFirstChild("CharacterHandler");
    if not character_handler then return end

    local server_crouch = character_handler.Requests.ServerCrouch;
    if not server_crouch then return end     

    local cap_artist = character_handler.Requests.CapArtist;
    if not cap_artist then return end    

    local has_knocked_ownership_enabled = aztup.flags.knocked_ownership
    if not has_knocked_ownership_enabled then
        aztup_toggles.knocked_ownership:SetValue(true);
    end;

    server_crouch:FireServer(true)

    task.delay(0.1, function()
        cap_artist:FireServer()
    end);

    task.delay(0.2, function() 
        server_crouch:FireServer(false)
    end);

    task.delay(2.5, function()
        cap_artist:FireServer()
                
        if not has_knocked_ownership_enabled then
            aztup_toggles.knocked_ownership:SetValue(false);
        end;
    end);
end;

local function do_exploit_bypass()
    Latency:force_lag(0.3);
end;

local feature;
local function do_knocked_bypass()
    if not EffectReplicator:FindEffect("Knocked") and tick() - last_knocked_time > 5 then
        if local_player.humanoid.Health > 20 then
            KeyHandler:get_key("FallDamage"):FireServer((local_player.humanoid.MaxHealth / 2.5) + math.random(), false)
        else
            KeyHandler:get_key("FallDamage"):FireServer(20, false)
        end;

        if feature.toggled_knocked_owner_for_user then
            aztup_toggles.knocked_ownership:SetValue(false);
        end;
    elseif EffectReplicator:FindEffect("Knocked") then
        last_knocked_time = tick();

        if not aztup.flags.knocked_ownership then
            feature.toggled_knocked_owner_for_user = true;
            aztup_toggles.knocked_ownership:SetValue(true);
        end;
    end;    
end;

feature = Feature:new("fly", game:GetService("RunService").PreSimulation, LPH_NO_VIRTUALIZE(function(dt)
    if is_chime and aztup.flags.chime_safety then
        return aztup_toggles.fly:SetValue(false)    
end;
    if not local_player.character then return end

    
    
    
    
    

    
    

    
    
    
    
    
    
    
    
    

    
    
    

    
    
    

    
    
    
    
    

    
    
    
    

    local direction = Vector3.new();
    local direction_keys = {
        [Enum.KeyCode.W] = workspace.CurrentCamera.CFrame.LookVector.Unit,
        [Enum.KeyCode.S] = -workspace.CurrentCamera.CFrame.LookVector.Unit,
        [Enum.KeyCode.A] = Vector3.new(workspace.CurrentCamera.CFrame.LookVector.Unit.Z, 0, -workspace.CurrentCamera.CFrame.LookVector.Unit.X),
        [Enum.KeyCode.D] = Vector3.new(-workspace.CurrentCamera.CFrame.LookVector.Unit.Z, 0, workspace.CurrentCamera.CFrame.LookVector.Unit.X),
        [Enum.KeyCode.Space] = Vector3.new(0, 1, 0),
        [Enum.KeyCode.LeftControl] = Vector3.new(0, -1, 0),
    }

    for key, vec in pairs(direction_keys) do
        if services.UserInputService:IsKeyDown(key) then
            direction = direction + vec;
        end
    end

    if direction.Magnitude > 0 then
        direction = direction.Unit;
    else
        direction = Vector3.zero;
    end

    for _, bv in local_player.character:QueryDescendants("BasePart > BodyVelocity") do
        services.Debris:AddItem(bv, 0);
    end

    current_bv = bv:Clone();
	if (not services.CollectionService:HasTag(current_bv, 'AllowedBM')) then
		services.CollectionService:AddTag(current_bv, 'AllowedBM');
	end
    
    local speed = aztup.flags.fly_speed;
    local root_attachment = local_player.root_part:FindFirstChild("RootAttachment");
    local align_position = root_attachment and root_attachment:FindFirstChild("AlignPosition");
    if align_position then
        if not aztup.automation:has_any() and not aztup.automation:should_auto_start() then
            align_position.Attachment0 = nil;
            align_position.Attachment1 = nil;
        end;
        speed = math.min(160, speed);

        Tween.register_lagback();
    end

    speed = math.min(EffectReplicator:FindEffect("Knocked") and 350 or 250, speed)

    if aztup.flags.pull_to_ground and not aztup.flags.noclip then
        if not services.UserInputService:IsKeyDown(Enum.KeyCode.Space) and not services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and not EffectReplicator:HasEffect("Swimming") then
            local close_to_ground = collision_utils:Raycast(local_player.root_part.Position, Vector3.new(0, -7.5, 0), collision_utils.solidParams);
            local getting_close_to_ground = collision_utils:Raycast(local_player.root_part.Position, Vector3.new(0, -25, 0), collision_utils.solidParams);

            direction = direction + Vector3.new(0, close_to_ground and -1 or (getting_close_to_ground and -0.75 or -0.3), 0);
        end;
    end

    local ground_controller_should_be_used = false;
    current_bv.MaxForce = Vector3.new(1000000, 1000000, 1000000);
    if aztup.flags.ignore_ground and not general:in_air() and not EffectReplicator:HasEffect("Swimming") and not aztup.flags.noclip then
        current_bv.MaxForce = Vector3.new(1000000, 0, 1000000);
        ground_controller_should_be_used = true;
    end

	current_bv.Parent = local_player.root_part;
    current_bv.Velocity = direction * speed; 
    
    local ground_sensor = local_player.root_part:FindFirstChild("GroundSensor")
    if not ground_sensor then
        return
    end

    local controller_manager = local_player.character:FindFirstChild("ControllerManager")
    if not controller_manager then
        return
    end

    local ground_controller = controller_manager:FindFirstChild("GroundController")
    if not ground_controller then
        return
    end

    local air_controller = controller_manager:FindFirstChild("AirController")
    if not air_controller then
        return
    end

    controller_manager.ActiveController = ground_controller_should_be_used and ground_controller or air_controller

    if not ground_controller_should_be_used and aztup.flags.noclip then
        ground_sensor.SensorMode = Enum.SensorMode.ClassicLadder;
        ground_sensor.UpdateType = Enum.SensorUpdateType.OnRead;
    else 
        ground_sensor.SensorMode = Enum.SensorMode.Floor;
        ground_sensor.UpdateType = Enum.SensorUpdateType.Manual;
    end

    return
end));

function feature:enable()
    EffectReplicator:CreateEffect("OverrideSpeedCap");
    self.w = true;
    self.start = tick();

    self.highlight = Instance.new("Highlight");
    self.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
    self.highlight.FillColor = Library.AccentColor;
    self.highlight.OutlineColor = Library.AccentColor;
    self.highlight.FillTransparency = 1;
    self.highlight.OutlineTransparency = 1;
    self.highlight.Adornee = local_player.character;
    self.highlight.Parent = local_player.character;

    
    
    

    
    
    

    
    

    
    

    
    

    
    
    
    
    

    
    
    

    
    

    
    
    
    
    
    
    
end;

function feature:disable()
    if not self.w then return end

    if feature.toggled_knocked_owner_for_user then
        aztup_toggles.knocked_ownership:SetValue(false);
    end;
    
    

    
    
    
    
    
    

    if self.highlight then
        self.highlight:Destroy();
    end;

    if old_y and spoofing then
        local_player.root_part.CFrame = with_y(local_player.root_part.CFrame, old_y);
        spoofing = nil;
        old_y = nil;
    end;

    self.w = false 
    if current_bv then
        current_bv:Destroy();
        current_bv = nil;
    end;

    local effect = EffectReplicator:FindEffect("OverrideSpeedCap");
    if effect then
        effect:Debris(1);
    end;
    
    local ground_sensor = local_player.root_part:FindFirstChild("GroundSensor")
    if not ground_sensor then
        return
    end

    ground_sensor.SensorMode = Enum.SensorMode.Floor;
    ground_sensor.UpdateType = Enum.SensorUpdateType.Manual;
end;

return feature