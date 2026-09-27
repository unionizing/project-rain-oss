

local general = {}; 
local collision_utils = base_require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("CollisionUtils"));
general.collision_utils = collision_utils;

function general:in_air()
    local sensor = local_player.root_part:FindFirstChild("GroundSensor");
    if EffectReplicator:HasEffect("Swimming") then
        return false    
elseif EffectReplicator:HasEffect("AirBorne") then
        return true    
elseif sensor and not sensor.SensedPart then
        if not collision_utils.solidParams then return false end
        return not collision_utils:Raycast(local_player.root_part.Position, Vector3.new(0, -(sensor.SearchDistance + 3), 0), collision_utils.solidParams)    
end

    return false
end;

function general:get_highest_point(x: number, z: number)
    local filter = {};
    local live = workspace:FindFirstChild("Live");
    local npcs = workspace:FindFirstChild("NPCs");
    if live then table.insert(filter, live); end
    if npcs then table.insert(filter, npcs); end

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = filter
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local floor = workspace:Raycast(Vector3.new(x, 5000, z), Vector3.new(0, -10000, 0), params);
    if floor and floor.Instance then
        return floor.Position.Y + 1.3    
end;

    local holder_sea = workspace:FindFirstChild("HolderSea", true);
    if holder_sea then
        return holder_sea.Position.Y + 1.3    
end;

    return 50000
end;

function general:is_teammate(player)
    local myGuild = local_player.instance:GetAttribute('Guild') or '';
    local playerGuild = player:GetAttribute('Guild') or '';
    if myGuild == '' then return end

    return myGuild == playerGuild
end;

local current_boxes = {};

local function trim_boxes()
    local max_boxes = (aztup and aztup.flags and aztup.flags.max_boxes) or 0
    if max_boxes <= 0 then return end
    while #current_boxes > max_boxes do
        local pair = table.remove(current_boxes, 1)
        if pair then
            for _, part in pair do
                if part and part.Parent then
                    part:Destroy()
                end
            end
        end
    end
end
local function draw_hitbox(hitbox: Vector3, root_pos: CFrame, enemy_pos: CFrame, offset: CFrame, is_ball: boolean?, ok: boolean, too_far: boolean, hidden: boolean?, hit_color: Color3?, miss_color: Color3?)
    local camera: Camera = workspace.CurrentCamera or {Position = Vector3.zero};
    if (enemy_pos.Position - camera.CFrame.Position).Magnitude > 300 then
        return
    end

    trim_boxes()

    local fake_root = nil
    if ok then
        fake_root = Instance.new("Part")
        fake_root.Size = Vector3.new(2, 2, 1)
        fake_root.CFrame = root_pos
        fake_root.Anchored = true
        fake_root.CanCollide = false
        fake_root.Material = Enum.Material.ForceField
        fake_root.CastShadow = false
    end

    local hitbox_part = Instance.new("Part")
    hitbox_part.Size = hitbox
    hitbox_part.CFrame = enemy_pos * (offset or CFrame.new())
    hitbox_part.Anchored = true
    hitbox_part.CanCollide = false
    hitbox_part.Material = Enum.Material.ForceField
    hitbox_part.Shape = is_ball and Enum.PartType.Ball or Enum.PartType.Block
    hitbox_part.CastShadow = false

    if fake_root then
        table.insert(current_boxes, { hitbox_part, fake_root })
    else
        table.insert(current_boxes, { hitbox_part })
    end

    local trans = 1 - (((aztup and aztup.flags and aztup.flags.hb_trans) or 0) / 100)
    hitbox_part.Transparency = trans
    if fake_root then
        fake_root.Transparency = trans
    end

    hitbox_part.Parent = workspace
    if fake_root then
        fake_root.Parent = workspace
    end

    local lifetime = (hidden or not aztup.flags.view_hitboxes or too_far) and 0 or 1
    services.Debris:AddItem(hitbox_part, lifetime)
    if fake_root then
        services.Debris:AddItem(fake_root, lifetime)
    end

    hitbox_part.Color = ok and (hit_color or Color3.new(0, 1, 0)) or (miss_color or Color3.new(1, 0, 0))
    if fake_root then
        fake_root.Color = hit_color or Color3.new(0, 1, 0)
    end

    if hidden or not aztup.flags.view_hitboxes or too_far then
        hitbox_part.Transparency = 1
        if fake_root then
            fake_root.Transparency = 1
        end
    else
        services.TweenService:Create(hitbox_part, TweenInfo.new(1), { Transparency = 1 }):Play()
        if fake_root then
            services.TweenService:Create(fake_root, TweenInfo.new(1), { Transparency = 1 }):Play()
        end
    end
end

function general:in_hitbox_with_pos(root_pos: CFrame, enemy_pos: CFrame, hitbox: Vector3, offset: CFrame, hidden: boolean?, is_ball: boolean?, hit_color: Color3?, miss_color: Color3?)  
    local too_far = false
    if local_player and local_player.root_part then
        too_far = (root_pos.Position - local_player.root_part.Position).Magnitude > 200
    end

    if (root_pos.Position - local_player.root_part.Position).Magnitude > (200 + (hitbox.Magnitude * 2)) then
        return false
    end

    local ok = false
    if is_ball then
        local probe = Instance.new("Part")
        probe.Size = hitbox
        probe.CFrame = enemy_pos * (offset or CFrame.new())
        probe.Anchored = true
        probe.Shape = Enum.PartType.Ball
        probe.CanCollide = false
        probe.Transparency = 1
        probe.CanQuery = true
        probe.Parent = workspace

        local overlap = OverlapParams.new()
        overlap.FilterType = Enum.RaycastFilterType.Include
        overlap.FilterDescendantsInstances = { 
            (function()
                local pr = Instance.new("Part")
                pr.Size = Vector3.new(2, 2, 1)
                pr.CFrame = root_pos
                pr.Anchored = true
                pr.CanCollide = false
                pr.Transparency = 1
                pr.CanQuery = true
                pr.Parent = workspace
                return pr
            end)()
        }

        local parts = services.Workspace:GetPartsInPart(probe, overlap)
        ok = #parts > 0

        
        for _, inst in overlap.FilterDescendantsInstances do
            inst:Destroy()
        end
        probe:Destroy()
    else

        local root_probe = Instance.new("Part")
        root_probe.Size = Vector3.new(2, 2, 1)
        root_probe.CFrame = root_pos
        root_probe.Anchored = true
        root_probe.CanCollide = false
        root_probe.Transparency = 1
        root_probe.CanQuery = true
        root_probe.Parent = workspace

        local overlap = OverlapParams.new()
        overlap.FilterType = Enum.RaycastFilterType.Include
        overlap.FilterDescendantsInstances = { root_probe }

        local parts = services.Workspace:GetPartBoundsInBox(enemy_pos * (offset or CFrame.new()), hitbox, overlap)
        ok = #parts > 0

        services.Debris:AddItem(root_probe, 0);
    end

    
    if aztup and aztup.flags and aztup.flags.view_hitboxes and not hidden and not too_far then
        draw_hitbox(hitbox, root_pos, enemy_pos, offset, is_ball, ok, too_far, hidden, hit_color, miss_color)
    end

    return ok
end
function general:in_hitbox(
    a: any,
    b: any,
    c: any,
    d: any,
    e: any?,
    f: any?
)
    
    
    
    
    

    local hitbox: Vector3
    local offset: CFrame
    local root_pos: CFrame
    local enemy_pos: CFrame
    local hidden: boolean?
    local is_ball: boolean? 

    if typeof(a) == "Vector3" and typeof(b) == "CFrame" then
        
        hitbox = a
        offset = b
        root_pos = c
        enemy_pos = d
        hidden = e
        is_ball = f
    else
        
        root_pos = a
        enemy_pos = b
        hitbox = c
        offset = d
        local show = e

        
        
        hidden = (show == false)
        is_ball = nil
    end

    return self:in_hitbox_with_pos(root_pos, enemy_pos, hitbox, offset, hidden, is_ball)
end;

function general:is_ap_anim(id)
    local data;
    for _, timing in timings do
        if timing.ids and table.find(timing.ids, tostring(id:match("%d+"))) then
            data = timing;
        end;
    end;   

    return data ~= nil
end;

function general:playing_ap_anims(entity, ids)
    for _, track in entity.Humanoid:GetPlayingAnimationTracks() do
        if ids then
            if table.find(ids, track.Animation.AnimationId) then
                continue            
end;
        end

        local data;
        for _, timing in timings do
            if timing.ids and table.find(timing.ids, tostring(track.Animation.AnimationId:match("%d+"))) then
                data = timing;
            end;
        end;   
        
        if data then
            return true        
end;
    end;

    return false
end;

local Keybinds = base_require(game:GetService("ReplicatedStorage"):WaitForChild("KeyBinds"..""));
function general:generic_parry_ap_task(entity: Model)
    if aztup_options.filters.Value["Dont Parry If Holding Block"] and Keybinds.IsActionHeld("Block") then
        return pcall(function()
            setthreadidentity(8);
            Logger:notify_sound("Holding F.");
        end)    
end;

    DefendActionManager:queue_generic_parry_task(entity);
end;

function general:raw_is_holding_f()
    return Keybinds.IsActionHeld("Block")
end;

function general:is_holding_f()
    return aztup_options.filters.Value["Dont Parry If Holding Block"] and Keybinds.IsActionHeld("Block")
end;

general.friends = {};
function general:is_friends_with_sync(plr)
    return general.friends[plr.UserId]
end

task.spawn(function() 
    for _, plr in services.Players:GetPlayers() do
        pcall(function() 
            local is_friends = local_player.instance:IsFriendsWithAsync(plr.UserId);
            if is_friends then
                general.friends[plr.UserId] = local_player.instance:IsFriendsWithAsync(plr.UserId);
            end;
        end)
    end

    services.Players.PlayerAdded:Connect(function(plr)
        if general.friends[plr.UserId] ~= nil then return end

        local is_friends = local_player.instance:IsFriendsWithAsync(plr.UserId);
        if not is_friends then return end

        general.friends[plr.UserId] = local_player.instance:IsFriendsWithAsync(plr.UserId);
    end);
end)

return general