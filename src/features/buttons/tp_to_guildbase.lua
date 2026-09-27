return function()
    local target = aztup_options.guildbase_teleport_type.Value;
    if not target then
        return Library:Notify("Invalid teleport selection.", 15)    
end

    local guild_door do 
        for _, door in workspace:GetChildren() do
            if door.Name:match("GuildDoor_") and (door:GetAttribute("GuildName") or door.Name) == target then
                guild_door = door
                break
            end
        end
    end;

    if not guild_door then
        return Library:Notify("Failed to find guildbase.", 15)    
end;

    local guild_exit = workspace:FindFirstChild(guild_door.Name:gsub("GuildDoor", "GuildExitDoor"));

    if not guild_exit then
        return Library:Notify("Failed to find guildbase.", 15)    
end;

    return LoopUtil.run_for(25, function()
        if not local_player.root_part then return end

        if guild_door and (local_player.root_part.Position - guild_door.Position).Magnitude < 20 then
            LoopUtil.run_for(0.5, function()
                local_player.root_part.AssemblyLinearVelocity = Vector3.zero;
            end)
            return true        
end;

        local_player.root_part.CFrame = guild_exit.CFrame;
        return fireproximityprompt(guild_exit.InteractPrompt)    
end)
end 