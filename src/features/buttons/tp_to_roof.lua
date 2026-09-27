return function()
    local character = local_player.character;
    if not character then return end

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {workspace:FindFirstChild("Map")}
    params.FilterType = Enum.RaycastFilterType.Include
    
    if not local_player.root_part or not local_player.root_part.Parent then
        return
    end
    
    local floor = workspace:Raycast(Vector3.new(local_player.root_part.Position.X, -600, local_player.root_part.Position.Z), Vector3.new(0, -1000, 0), params)
    if not floor or not floor.Instance then
        local_player.root_part.CFrame = CFrame.new(local_player.root_part.CFrame.X, -600, local_player.root_part.CFrame.Z);
        local_player.root_part.AssemblyLinearVelocity = local_player.root_part.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
        return
    end
    
    local pos = (local_player.root_part.Position.Y - floor.Position.Y)
    local_player.root_part.CFrame = local_player.root_part.CFrame * CFrame.new(0, -pos + 3, 0)
    local_player.root_part.AssemblyLinearVelocity = local_player.root_part.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
end