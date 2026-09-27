local feature = Feature:new("auto_charisma", local_player.instance.PlayerGui.ChildAdded, LPH_NO_VIRTUALIZE(function(choice_prompt)
    if choice_prompt.Name ~= "ChoicePrompt" or not choice_prompt:FindFirstChild("ChoiceFrame") then
        return
    end

    if choice_prompt then
        local ChoiceFrame = choice_prompt:FindFirstChild("ChoiceFrame")
        local Desc = ChoiceFrame:FindFirstChild("Desc")
        if not Desc then return end
        local Text = string.split(Desc.Text, "\n")
        local RealText = string.sub(Text[2], 2, -2)
        task.wait()
        if not choice_prompt:FindFirstChild("ChatChoice") then return end
        choice_prompt.ChatChoice:InvokeServer(RealText)
    end
end))

return feature