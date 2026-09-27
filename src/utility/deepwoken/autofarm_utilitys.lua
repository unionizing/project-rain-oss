

local autofarm_utilities = {}

function autofarm_utilities:ReadyWeapon(toggle: boolean)
    if not local_player.character then return end
    if local_player.character and local_player.character:FindFirstChild('Weapon') then return end
    
    local character_handler = local_player.character:FindFirstChild("CharacterHandler");
    character_handler.Requests.DrawWeapon:FireServer(toggle);
end

function autofarm_utilities:ServerHop()
    local slot = local_player.instance:GetAttribute("DataSlot");
    server_utility:hop(slot, "any", true);
end

function autofarm_utilities:Auto_M1(toggle)
    if not aztup.maid.AU_AutoM1 then
        aztup.maid.AU_AutoM1_Toggle = toggle
        aztup.maid.AU_AutoM1 = services.RunService.Heartbeat:Connect(function() 
            aztup.features.m1_hold.held = aztup.maid.AU_AutoM1_Toggle
            aztup.flags.no_aerials = aztup.maid.AU_AutoM1_Toggle
        end)
    end
    
    aztup.maid.AU_AutoM1_Toggle = toggle
end

function autofarm_utilities:Tween(location: CFrame | Vector3 | BasePart, speed: number?, ping_based: boolean?)
    local loc_type = type(location)
    if loc_type == 'Vector3' then
        location = CFrame.new(location)
    elseif loc_type == 'BasePart' then
        location = location:GetPivot()
    end

    Tween.new(location, ping_based or true, speed or 250).wait()
end

function autofarm_utilities:NeedFood(percent): boolean
    if not percent then percent = 0.25; end
    
    local water = local_player.character:FindFirstChild('Water')
    local stomach = local_player.character:FindFirstChild('Stomach')
    return (water.Value <= (water.MaxValue * percent)) or (stomach.Value <= (stomach.MaxValue * percent))
end

function autofarm_utilities:RefillFood()
    if is_eastern then

    elseif is_etrean then
        
    end
end

function autofarm_utilities:HealthCheck(percent): boolean
    return local_player.humanoid and local_player.humanoid.Health <= (local_player.humanoid.MaxHealth * percent)
end

function autofarm_utilities:GetClosestMob(name, max_magnitude): Model
    local closest: Model = nil
    
    for _, mob: Model in workspace.Live:GetChildren() do
        if not mob:IsA('Model') then continue end
        if name and not mob.Name:find(name) then continue end
        if services.Players:GetPlayerFromCharacter(mob) then continue end
        
        if not closest then
            local dist = (local_player.root_part.Position - mob:GetPivot().Position).Magnitude
            if max_magnitude and dist > max_magnitude then continue end
            closest = mob
            continue
        end
        
        if closest then
            local mobDist = (local_player.root_part.Position - mob:GetPivot().Position).Magnitude
            local closestDist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
            
            if mobDist < closestDist then
                closest = mob
            end
        end
    end
    
    return nil
end

function autofarm_utilities:GetClosestNPC(name: string, wait: boolean): Model
    local function closest_npc()
        local closest: Model = nil
        
        for _, npc: Model in workspace.NPCs:GetChildren() do
            if not npc.Name:match(name) then continue end
            
            if not closest then
                closest = npc
                continue
            end
            
            if closest then
                local closestDist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
                local npcDist = (local_player.root_part.Position - npc:GetPivot().Position).Magnitude
                
                if closestDist > npcDist then
                    closest = npc
                end
            end
        end
        
        return closest
    end
    
    local closest = closest_npc()
    
    if wait and not closest then
        repeat closest = closest_npc(); task.wait(); until closest
    end
    
    return closest
end 

function autofarm_utilities:GetClosestCampfire(backup_location: CFrame, wait: boolean): Model
    local function closest_campfire(): Model
        local closest: Model = nil
        
        for _, campfire: Model in workspace.Thrown:GetChildren() do
            if not campfire.Name:match('Campfire') then continue end
            
            if not closest then
                closest = campfire
                continue
            end
            
            if closest then
                local closestDist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
                local campfireDist = (local_player.root_part.Position - campfire:GetPivot().Position).Magnitude
                
                if closestDist > campfireDist then
                    closest = campfire
                end
            end
        end
        
        return closest
    end
    
    local closest = closest_campfire()
    
    if not closest and backup_location then
        Tween.new(backup_location, true, 250).wait()
        closest = closest_campfire()
        
        if wait and not closest then
            repeat closest = closest_campfire(); task.wait(); until closest
        end
    end
    
    return closest
end

function autofarm_utilities:GetClosestWell(backup_location: CFrame, wait: boolean): Model
    local function closest_well(): Model
        local closest: Model = nil
        
        for _, well: Model in workspace.Map:GetChildren() do
            if not well.Name:match('Well') then continue end
            
            if closest == nil then
                closest = well
                continue
            end
            
            local closestdist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
            local dist        = (local_player.root_part.Position - well:GetPivot().Position).Magnitude
            
            if dist < closestdist then
                closest = well
            end
        end
        
        return closest
    end
    
    local closest: Model = closest_well()
    
    if not closest and backup_location then
        Tween.new(backup_location, true, 250).wait()
        closest = closest_well()
        
        if wait and not closest then
            repeat closest = closest_well(); task.wait(); until closest
        end
    end
    
    return closest
end

function autofarm_utilities:GetClosestChest(wait: boolean, max_distance: number): Model    
    local function search()
        local closest: Model = nil
        
        for _, chest: Model in workspace.Thrown:GetChildren() do
            if chest:HasTag('looted') then continue end
            if not chest:FindFirstChild('Lid') then continue end
            
            if not closest then
                local dist = (local_player.root_part.Position - chest:GetPivot().Position).Magnitude
                if max_distance and dist > max_distance then continue end
                closest = chest
                continue
            end
            
            if closest then
                local chestDist = (local_player.root_part.Position - chest:GetPivot().Position).Magnitude
                local closestDist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
                
                if chestDist < closestDist then
                    closest = chest
                end
            end
        end
        
        return closest
    end
    
    local closest: Model = search()
    
    if wait and not closest then
        repeat search(); task.wait(); until closest
    end
    
    return closest
end


function autofarm_utilities:GrabChest(struct, using_mob_breaker: boolean, wait_time: number, max_distance: number)
    local closest: Model = self:GetClosestChest(true, max_distance or nil)
    if not closest then return end
    
    closest:AddTag('looted')
    
    if using_mob_breaker then
        pcall(function(...)  
            struct.active_features['mob_ai_breaker'].current_connection:Disconnect()
            struct.active_features['mob_ai_breaker']:disable()
        end)
    end
    
    local time_waited = tick()
    
    repeat
        pcall(function(...)  
            Tween.new(closest:GetPivot(), true, 250).wait()
        end)
        
        if not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') then
            pcall(function(...)  
                fireproximityprompt(closest.InteractPrompt)
            end)
        end
        
        task.wait(0.2)
    until local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or ((tick() - time_waited) > (10))
    
    time_waited = tick()
    
    repeat task.wait() until not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or ((tick() - time_waited) > (wait_time or 3))
    if local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') then
        pcall(function(...)  
            local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt'):FindFirstChild('Choice'):FireServer('EXIT')
        end)
    end
end


function autofarm_utilities:GrabChests(struct, using_mod_breaker: boolean, wait_time: number, max_distance: number)
    local chest = self:GetClosestChest(false, max_distance or nil)
    repeat
        local dist = (local_player.root_part.Position - chest:GetPivot().Position).Magnitude
        if max_distance and dist > max_distance then continue end
        
        local time_waited = tick()
        
        repeat
            pcall(function(...)  
                Tween.new(chest:GetPivot(), true, 250).wait()
            end)
            
            if not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') then
                pcall(function(...)  
                    fireproximityprompt(chest.InteractPrompt)
                end)
            end
            
            task.wait(0.2)
        until local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or ((tick() - time_waited) > (10))
        
        time_waited = tick()
        
        repeat task.wait() until not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or ((tick() - time_waited) > (wait_time or 3))
        if local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') then
            pcall(function(...)  
                local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt'):FindFirstChild('Choice'):FireServer('EXIT')
            end)
        end
        
        chest = self:GetClosestChest(false, max_distance or nil)
        task.wait()
    until not chest
end

return autofarm_utilities