return function()
    local character = local_player.character;
    if not character then return end

    if not local_player.root_part or not local_player.root_part.Parent then
        return
    end

    local highest_point = general:get_highest_point(local_player.root_part.Position.X, local_player.root_part.Position.Z);
    if highest_point >= 50000 then
        return
    end

    local_player.root_part.CFrame = CFrame.new(local_player.root_part.Position.X, highest_point, local_player.root_part.Position.Z);
    local_player.root_part.AssemblyLinearVelocity = local_player.root_part.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
end