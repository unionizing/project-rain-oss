



local Converted = {
	["_ChoiceFrameUI"] = Instance.new("ScreenGui");
	["_Frame"] = Instance.new("Frame");
	["_TextLabel"] = Instance.new("TextLabel");
	["_Yes"] = Instance.new("TextButton");
	["_UIGradient"] = Instance.new("UIGradient");
	["_No"] = Instance.new("TextButton");
	["_UIGradient1"] = Instance.new("UIGradient");
	["_UIPadding"] = Instance.new("UIPadding");
	["_UIGradient2"] = Instance.new("UIGradient");
	["_UIStroke"] = Instance.new("UIStroke");
}



Converted["_ChoiceFrameUI"].IgnoreGuiInset = true
Converted["_ChoiceFrameUI"].SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
Converted["_ChoiceFrameUI"].ScreenInsets = Enum.ScreenInsets.None
Converted["_ChoiceFrameUI"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Converted["_ChoiceFrameUI"].Name = "ChoiceFrameUI"
Converted["_ChoiceFrameUI"].Parent = game:GetService("CoreGui")

Converted["_Frame"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Frame"].BackgroundColor3 = Color3.fromRGB(22.000000588595867, 35.00000171363354, 42.000001296401024)
Converted["_Frame"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame"].BorderSizePixel = 2
Converted["_Frame"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_Frame"].Size = UDim2.new(0, 200, 0, 150)
Converted["_Frame"].Parent = Converted["_ChoiceFrameUI"]

Converted["_TextLabel"].Font = Enum.Font.Code
Converted["_TextLabel"].Text = "Would you like to use a default pre-made config?"
Converted["_TextLabel"].TextColor3 = Color3.fromRGB(216, 222, 233)
Converted["_TextLabel"].TextSize = 14
Converted["_TextLabel"].TextStrokeTransparency = 0
Converted["_TextLabel"].TextWrapped = true
Converted["_TextLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel"].BackgroundTransparency = 1
Converted["_TextLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel"].BorderSizePixel = 0
Converted["_TextLabel"].Size = UDim2.new(1, 0, 1, -20)
Converted["_TextLabel"].Parent = Converted["_Frame"]

Converted["_Yes"].Font = Enum.Font.Code
Converted["_Yes"].Text = "yes"
Converted["_Yes"].TextColor3 = Color3.fromRGB(216.00000232458115, 222.00000196695328, 233.00000131130219)
Converted["_Yes"].TextSize = 14
Converted["_Yes"].BackgroundColor3 = Color3.fromRGB(27.000000290572643, 43.00000123679638, 52.000000700354576)
Converted["_Yes"].BorderColor3 = Color3.fromRGB(52.000000700354576, 61.00000016391277, 70.00000342726707)
Converted["_Yes"].Position = UDim2.new(0, 0, 1, -20)
Converted["_Yes"].Size = UDim2.new(0.5, -4, 0, 20)
Converted["_Yes"].Name = "Yes"
Converted["_Yes"].Parent = Converted["_Frame"]

Converted["_UIGradient"].Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(212.00000256299973, 212.00000256299973, 212.00000256299973))
}
Converted["_UIGradient"].Rotation = 90
Converted["_UIGradient"].Parent = Converted["_Yes"]

Converted["_No"].Font = Enum.Font.Code
Converted["_No"].Text = "no"
Converted["_No"].TextColor3 = Color3.fromRGB(216.00000232458115, 222.00000196695328, 233.00000131130219)
Converted["_No"].TextSize = 14
Converted["_No"].BackgroundColor3 = Color3.fromRGB(27.000000290572643, 43.00000123679638, 52.000000700354576)
Converted["_No"].BorderColor3 = Color3.fromRGB(52.000000700354576, 61.00000016391277, 70.00000342726707)
Converted["_No"].Position = UDim2.new(0.5, 4, 1, -20)
Converted["_No"].Size = UDim2.new(0.5, -4, 0, 20)
Converted["_No"].Name = "No"
Converted["_No"].Parent = Converted["_Frame"]

Converted["_UIGradient1"].Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(212.00000256299973, 212.00000256299973, 212.00000256299973))
}
Converted["_UIGradient1"].Rotation = 90
Converted["_UIGradient1"].Parent = Converted["_No"]

Converted["_UIPadding"].PaddingBottom = UDim.new(0, 4)
Converted["_UIPadding"].PaddingLeft = UDim.new(0, 4)
Converted["_UIPadding"].PaddingRight = UDim.new(0, 4)
Converted["_UIPadding"].PaddingTop = UDim.new(0, 4)
Converted["_UIPadding"].Parent = Converted["_Frame"]

Converted["_UIGradient2"].Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(212.00000256299973, 212.00000256299973, 212.00000256299973))
}
Converted["_UIGradient2"].Rotation = 90
Converted["_UIGradient2"].Parent = Converted["_Frame"]

Converted["_UIStroke"].Color = Color3.fromRGB(102.00000151991844, 153.00000607967377, 204.00000303983688)
Converted["_UIStroke"].LineJoinMode = Enum.LineJoinMode.Miter
Converted["_UIStroke"].ZIndex = 0
Converted["_UIStroke"].Parent = Converted["_Frame"]

if Library then
    Library:AddToRegistry(Converted["_Frame"], {
        BackgroundColor3 = "MainColor"
    })
    
    Library:AddToRegistry(Converted["_TextLabel"], {
        TextColor3 = "FontColor"
    })

    Library:AddToRegistry(Converted["_No"], {
        BackgroundColor3 = "MainColor",
        BorderColor3 = "OutlineColor",
        TextColor3 = "FontColor"
    })

    Library:AddToRegistry(Converted["_Yes"], {
        BackgroundColor3 = "MainColor",
        BorderColor3 = "OutlineColor",
        TextColor3 = "FontColor"
    })

    Library:AddToRegistry(Converted["_UIStroke"], {
        Color = "AccentColor"
    })

    Library:UpdateColorsUsingRegistry();
end;

return {
    set = function(t, yes, no, y_t, n_t)
        local ready = false;
        Converted["_TextLabel"].Text = t or "Would you like to use a default pre-made config?"
        Converted["_No"].Text = n_t or "no"
        Converted["_Yes"].Text = y_t or "yes"

        Converted["_No"].Activated:Connect(function()
            task.spawn(xpcall, no or function() end, warn);
            Converted["_ChoiceFrameUI"]:Destroy();
            ready = true;
        end);

        Converted["_Yes"].Activated:Connect(function()
            task.spawn(xpcall, yes or function() end, warn);
            Converted["_ChoiceFrameUI"]:Destroy();
            ready = true;
        end);

        repeat task.wait() until ready;
    end
}