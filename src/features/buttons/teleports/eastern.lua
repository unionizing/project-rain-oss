return function()
    require("@src/features/buttons/generic_teleport").new(CFrame.new(-2637.4563, 721.632935, -6722.51953, -0.757481456, 0, -0.652856648, 0, 1, 0, 0.652856648, 0, -0.757481456), function()
        local exit = workspace:FindFirstChild("ValleyExit");
        return exit and exit:FindFirstChild("RealmTeleport")    
end):run();
end
