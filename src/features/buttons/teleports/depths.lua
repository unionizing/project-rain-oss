return game.PlaceId == 86761619761103 and function() 
    local whirlpool;
    if not workspace:FindFirstChild("DepthsWhirlpool") then
        task.spawn(function()
            while not whirlpool and task.wait(0.25) do
                local_player.instance:RequestStreamAroundAsync(Vector3.new(-11771.1172, -0.0431976318, 2849.19189, 0.550822735, -0, -0.834622264, 0, 1, -0, 0.834622264, 0, 0.550822735), 1000);
            end;
            
            while not whirlpool:FindFirstChild("Part") and task.wait(0.25) do
                local_player.instance:RequestStreamAroundAsync(Vector3.new(-11771.1172, -0.0431976318, 2849.19189, 0.550822735, -0, -0.834622264, 0, 1, -0, 0.834622264, 0, 0.550822735), 1000);
            end;
        end);
    end;

    whirlpool = workspace:WaitForChild("DepthsWhirlpool", 9e9);
    whirlpool:WaitForChild("Part", 9e9);

    local whirlpool_part = whirlpool:WaitForChild("Part", 9e9);
    while task.wait() do
        if not local_player.root_part then continue end
        local_player.root_part.AssemblyLinearVelocity = Vector3.one * math.random();
        local_player.root_part.CFrame = whirlpool_part.CFrame * CFrame.new(math.random(1, 10), 0, math.random(1, 10));

        firetouchinterest(whirlpool.Part, local_player.root_part, 1)
        firetouchinterest(whirlpool.Part, local_player.root_part, 0)
    end;
end or function()
    require("@src/features/buttons/generic_teleport").new(CFrame.new(39911.3672, 39980.9375, 39708.3203), function()
        local mod_office = workspace:FindFirstChild("ModOffice");
        if not mod_office then return end

        return mod_office:FindFirstChild("OfficePit")
    end):run();
end