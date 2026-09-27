

local feature = Feature:new("auto_math_book", local_player.instance.PlayerGui.ChildAdded, LPH_NO_VIRTUALIZE(function(Child)
    if Child.Name ~= "ChoicePrompt" or not Child:FindFirstChild("ChoiceFrame") then
        return
    end

    if local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') then
        local ChoiceFrame = Child:FindFirstChild("ChoiceFrame")
        local DescSheet = ChoiceFrame:FindFirstChild("DescSheet")
        local ChoiceEvent = Child:FindFirstChild("Choice")
    
        if DescSheet then
            local Operation
            local Desc = DescSheet:WaitForChild("Desc")
            if string.match(Desc.Text:lower(), "plus") then
                Operation = "plus"
            elseif string.match(Desc.Text:lower(), "divided") then
                Operation = "div"
            elseif string.match(Desc.Text:lower(), "minus") then
                Operation = "min"
            elseif string.match(Desc.Text:lower(), "times") then
                Operation = "mult"
            end
    
            local Text = string.split(Desc.Text, " ")
            if not Text[5] then return end
            local Num1, Num2 = Text[3], string.gsub(Text[5], "?", "")
            local Solved
            if Operation == "mult" then
                Solved = tonumber(Num1) * tonumber(Num2)
            elseif Operation == "min" then
                Solved = tonumber(Num1) - tonumber(Num2)
            elseif Operation == "plus" then
                Solved = tonumber(Num1) + tonumber(Num2)
            elseif Operation == "div" then
                if not Text[6] then return end

                Num1, Num2 = Text[3], string.gsub(Text[6], "?", "")
                Solved = tonumber(Num1) / tonumber(Num2)
            end
            
            local options = ChoiceFrame:WaitForChild("Options")
            task.wait()

            for i, v in pairs(options:GetChildren()) do
                if v:IsA('TextButton') then
                    if tonumber(v.Name) and (math.abs(tonumber(v.Name)-Solved)<=1) then
                        ChoiceEvent:FireServer(v.Name)
                        break
                    end
                end
            end
        end;
    end
end))

return feature