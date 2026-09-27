local feature = Feature:new("no_kill_bricks");
feature.saved = {};
feature.fakers = {};
feature.cleanup_conns = {};
feature.touched_fake = Instance.new("BindableEvent");

function feature:is_kill_brick(part)
    if not part or not part.Parent then return end
    
    return part and (table.find({
        "KillBrick",
        "KillPlane",
        "LifeField",
        "ChasmBrick",
        "SuperWall",
        game.PlaceId == 6032399813 and "ThronePart" or ""
    }, part.Name) ~= nil or part.Parent.Name == "Layer2KillbrickModel")
end;

function feature:check(child)
    if self:is_kill_brick(child) then
        self.saved[child.Parent] = self.saved[child.Parent] or {};
        table.insert(self.saved[child.Parent], child);
        child.Parent = nil;
        child.CanTouch = false;

        if child.Name ~= "KillPlane" and child.Name ~= "ThronePart" then return end

        local fake_killbrick = Instance.new("Part", workspace.Terrain);
        fake_killbrick.Size = child.Size; 
        fake_killbrick.Anchored = true;
        fake_killbrick.CFrame = child.CFrame;
        fake_killbrick.Material = Enum.Material.ForceField;
        fake_killbrick.Color = Library.AccentColor;
        fake_killbrick.Transparency = 0.5;
        fake_killbrick.CanCollide = false;
        Library:AddToRegistry(fake_killbrick, {
            Color = "AccentColor"
        })


        table.insert(self.fakers, fake_killbrick);

        if child.Name == "ThronePart" then
            return        
end

        table.insert(feature.cleanup_conns, fake_killbrick.Touched:Connect(function(part)
            if not part:IsDescendantOf(local_player.character) then return end
            
            self.touched_fake:Fire(fake_killbrick);
        end));
    end;
end

function feature:enumerate_instances(instance)
    if not instance then return end

    for _, child in instance:GetChildren() do
        pcall(function() 
            self:check(child);
        end)
    end;

    table.insert(feature.cleanup_conns, instance.ChildAdded:Connect(function(child)
        self:check(child);
    end));
end;

function feature:enable()
    self:enumerate_instances(workspace:FindFirstChild("Layer2KillbrickModel", true));
    self:enumerate_instances(workspace:FindFirstChild("Layer2Floor1"));
    if game.PlaceId == 6032399813 then
        self:enumerate_instances(workspace:FindFirstChild("Thrown"));
    end;
    self:enumerate_instances(workspace);
end

function feature:disable()
    for parent, parts in pairs(self.saved) do
        for _, part in parts do
            part.Parent = parent;
            part.CanTouch = true;
        end;
    end;

    for _, conn in self.cleanup_conns do
        conn:Disconnect();
    end;
    for _, part in self.fakers do
        part:Destroy();
    end;
        
    table.clear(self.saved);
end

return feature