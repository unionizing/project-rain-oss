local ingredients = workspace:FindFirstChild("Ingredients");
local npcs = workspace:FindFirstChild("NPCs");
local live = workspace:FindFirstChild("Live");

local requests = services.ReplicatedStorage:WaitForChild("Requests");
local send_dialogue = requests and requests:WaitForChild("SendDialogue");

function safe_tween(tween)
    if aztup.maid.objective_tween then aztup.maid.objective_tween.stop() end
    aztup.maid.objective_tween = tween
    aztup.maid.objective_tween.wait()
    aztup.maid.objective_tween = nil
end
function close_prompt()
    local start = tick();

    while tick() - start < 2 do
        send_dialogue:FireServer({exit=true});
        task.wait();
    end
end
function getPosition(instance)
    if instance:IsA("BasePart") then
        return instance.Position
    end

    if instance:IsA("Model") then
        if instance.GetPivot then
            return instance:GetPivot().Position
        elseif instance.PrimaryPart then
            return instance.PrimaryPart.Position
        else
            return nil
        end
    end

    if instance:IsA("ObjectValue") and instance.Value then
        return getPosition(instance.Value)
    end
    return nil
end

function getNearest(list, filter)
    local closestObject;
    local closest = 9e9;
    for i, v in pairs(list) do
        local pos = getPosition(v)
        if filter(v) and pos and (pos - local_player.root_part.Position).Magnitude < closest then
            closest = (pos - local_player.root_part.Position).Magnitude;
            closestObject = v;
        end
    end
    return closestObject
end;

return function()
    print("got call")
    local layer2_floor1_object = workspace:FindFirstChild("Layer2Floor1");
    local door_key = layer2_floor1_object and layer2_floor1_object:FindFirstChild("DoorKey");
    local door = npcs:FindFirstChild("TheDoor");
    local key = npcs:FindFirstChild("TheKey");

    local door_prompt = door and door:FindFirstChild("InteractPrompt");
    local key_prompt = key and key:FindFirstChild("InteractPrompt");

    local has_chaser do
        for _, live_entity in live:GetChildren() do
            if live_entity.Name:match(".chaser") then
                has_chaser = true;
                break            
end;
        end;
    end;

    if door_prompt and key_prompt then
        safe_tween(Tween.new(door_key.CFrame, true, 200))
        task.wait((Latency:get_ping() * 2) + 0.05);

        if key_prompt and key_prompt.Parent then
            fireproximityprompt(key_prompt);
            task.spawn(close_prompt);
        end;

        safe_tween(Tween.new(door:GetPivot(), true, 200))

        task.wait((Latency:get_ping() * 2) + 0.05);

        if door_prompt and door_prompt.Parent then
            fireproximityprompt(door_prompt);
            task.spawn(close_prompt);
        end;
    end;

    if layer2_floor1_object and not has_chaser and not key_prompt then
        local galewax = getNearest(ingredients:GetChildren(), function(self)
            return self.Name == "Galewax"
        end); 

        if galewax then
            safe_tween(Tween.new(galewax.CFrame, true, 200))
        end;
    end;

    if has_chaser then
        local jar = getNearest(services.CollectionService:GetTagged("BloodJar"), function(self)
            return self:FindFirstChild('JarLight', true)
        end);

        if jar then
            safe_tween(Tween.new(CFrame.new(getPosition(jar)), true, 200))
        end;
    end;

    if #services.CollectionService:GetTagged('BuzzObelisk') > 0 then
        local obelisk = getNearest(services.CollectionService:GetTagged('BuzzObelisk'), function(self)
            return self.Name:match('BuzzPart')
        end)
        if obelisk then
            safe_tween(Tween.new(obelisk.CFrame, true, 200))
            pcall(function(...) 
                fireproximityprompt(obelisk.InteractPrompt)
            end)
        end
    elseif not local_player.character:FindFirstChild("BoneSpear") and workspace:FindFirstChild("Layer2Floor2") then
        local closest = nil
        
        for _, object in workspace.Thrown:GetChildren() do
            if not object.Name:match('BoneSpear') then continue end
            if not object:FindFirstChild('InteractPrompt') then continue end
            
            if closest == nil then
                closest = object
                continue
            end
            
            if closest then
                local closestDist = (local_player.root_part.Position - closest.Position).Magnitude
                local objectDist = (local_player.root_part.Position - object.Position).Magnitude
                
                if closestDist > objectDist then
                    closest = object
                end
            end
        end 
        
        if closest then
            safe_tween(Tween.new(closest.CFrame, true, 200))

            pcall(function(...) 
                task.wait(0.2);
                fireproximityprompt(closest.InteractPrompt)
            end)
        end;
    elseif local_player.character:FindFirstChild("BoneSpear") and workspace:FindFirstChild("Layer2Floor2") then
        local floor_one_done   = true
        local floor_two_done   = true
        
        local closest = nil
        
        for _, altar in workspace.TrueAvatarBossRoom.Floor1Stuff:GetChildren() do
            if not altar.Name:match('Altar') or not altar:IsA("Model") then continue end
            if altar:FindFirstChild('BoneSpear', true) then continue end
            
            floor_one_done = false
            
            if closest == nil then
                closest = altar
                continue
            end
            
            if closest then
                local closestDist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
                local altarDist = (local_player.root_part.Position - altar:GetPivot().Position).Magnitude
                
                if closestDist > altarDist then
                    closest = altar
                end
            end
        end
        
        if floor_one_done then
            for _, altar in workspace.TrueAvatarBossRoom.Floor2Stuff:GetChildren() do
                if not altar.Name:match('Altar') or not altar:IsA("Model") then continue end
                if altar:FindFirstChild('BoneSpear', true) then continue end
                
                floor_two_done = false
                
                if closest == nil then
                    closest = altar
                    continue
                end
                
                if closest then
                    local closestDist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
                    local altarDist = (local_player.root_part.Position - altar:GetPivot().Position).Magnitude
                    
                    if closestDist > altarDist then
                        closest = altar
                    end
                end
            end
        end
        
        if floor_two_done then
            for _, altar in workspace.TrueAvatarBossRoom.Floor3Stuff:GetChildren() do
                if not altar.Name:match('Altar') then continue end
                if altar:FindFirstChild('BoneSpear', true) then continue end
                
                floor_three_done = false
                
                if closest == nil then
                    closest = altar
                    continue
                end
                
                if closest then
                    local closestDist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
                    local altarDist = (local_player.root_part.Position - altar:GetPivot().Position).Magnitude
                    
                    if closestDist > altarDist then
                        closest = altar
                    end
                end
            end
        end

        if closest:FindFirstChild("BoneSpear") then return end
        safe_tween(Tween.new(closest:FindFirstChild("Center") and closest:FindFirstChild("Center").CFrame or closest:GetPivot(), true, 200))
    end
end