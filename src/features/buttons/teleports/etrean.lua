return function()
    require("@src/features/buttons/generic_teleport").new(CFrame.new(-528.434814, 704.674194, -4760.4292), function()
        local valley_exit = workspace:FindFirstChild("ValleyExit")
        return valley_exit and valley_exit:FindFirstChild("RealmTeleport")    
end):run();
end
