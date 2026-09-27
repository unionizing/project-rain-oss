if identifyexecutor() ~= "Opiumware" then return end

Logger:long_notify("You are on a unsupported executor (they have a issue they refuse to fix) & we have applied a semi-fix")
Logger:long_notify("Interactable objects may have special issues.")
game:GetService("ProximityPromptService").PromptTriggered:Connect(function(v632, v633) 
    if v633 ~= game:GetService("Players").LocalPlayer then
            return    
end

    game:GetService("ReplicatedStorage").Requests.InteractPrompt:FireServer(v632);
end);