
local feature = Feature:new("auto_chime_requeue");

function feature:enable()
    self.current_connection = local_player.instance:WaitForChild("PlayerGui").ChildAdded:Connect(function(inst)
        if inst.Name ~= "RatingGui" then
            return        
end

        task.wait(0.25)
        local chime = game:GetService("Players").LocalPlayer:FindFirstChild("Chime of Conflict", true);
        chime.Parent = local_player.character;
        task.wait()
        chime:Activate();
        local choice = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ChoicePrompt"):WaitForChild("Choice")
        choice:FireServer("Chime Solos (1v1)")
    end)
end

return feature