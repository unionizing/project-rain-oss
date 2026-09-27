

local feature = Feature:new("auto_brutus", services.RunService.RenderStepped, LPH_JIT(function(choice_prompt)
    if not workspace.NPCs:FindFirstChild("Brutus") then return end
    local brutus = workspace.NPCs.Brutus
    if not brutus:FindFirstChild("InteractPrompt") or not brutus:FindFirstChild("HumanoidRootPart") then return end

    local interact_prompt = brutus.InteractPrompt
    if (brutus.HumanoidRootPart.Position - local_player.root_part.Position).Magnitude > interact_prompt.MaxActivationDistance then return end
    fireproximityprompt(interact_prompt);
    services.ReplicatedStorage.Requests.SendDialogue:FireServer({
        ["exit"] = true
    });    
end))

return feature