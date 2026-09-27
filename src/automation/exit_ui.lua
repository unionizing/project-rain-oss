if getgenv().added_exit_ui then 
    pcall(function() 
        getgenv().added_exit_ui.Visible = true;
    end);
    return true; 
end
local Converted = {
	["_stop_signal"] = Instance.new("ScreenGui");
	["_Frame"] = Instance.new("Frame");
	["_UICorner"] = Instance.new("UICorner");
	["_Frame1"] = Instance.new("Frame");
	["_UICorner1"] = Instance.new("UICorner");
	["_Objects"] = Instance.new("Frame");
	["_UIListLayout"] = Instance.new("UIListLayout");
	["_TextButton"] = Instance.new("TextButton");
	["_title"] = Instance.new("TextLabel");
	["_UIPadding"] = Instance.new("UIPadding");
	["_ui notes"] = Instance.new("ModuleScript");
}

-- Properties:

Converted["_stop_signal"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Converted["_stop_signal"].Name = "stop_signal"
Converted["_stop_signal"].Parent = game:GetService("CoreGui")
Converted["_stop_signal"].ScreenInsets = Enum.ScreenInsets.None;
Converted["_stop_signal"].OnTopOfCoreBlur = true; 

Converted["_Frame"].AnchorPoint = Vector2.new(0.5, 0)
Converted["_Frame"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame"].BackgroundTransparency = 0.800000011920929
Converted["_Frame"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame"].BorderSizePixel = 0
Converted["_Frame"].Position = UDim2.new(0.5, 0, 0, 20)
Converted["_Frame"].Size = UDim2.new(0, 150, 0, 46)
Converted["_Frame"].Parent = Converted["_stop_signal"]
getgenv().added_exit_ui = Converted["_Frame"];

Converted["_UICorner"].CornerRadius = UDim.new(0, 2)
Converted["_UICorner"].Parent = Converted["_Frame"]

Converted["_Frame1"].BackgroundColor3 = Color3.fromRGB(160.00000566244125, 195.0000035762787, 229.00000154972076)
Converted["_Frame1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame1"].BorderSizePixel = 0
Converted["_Frame1"].Position = UDim2.new(0, 0, 0, -2)
Converted["_Frame1"].Size = UDim2.new(1, 0, 0, 4)
Converted["_Frame1"].Parent = Converted["_Frame"]

Converted["_UICorner1"].CornerRadius = UDim.new(0, 2)
Converted["_UICorner1"].Parent = Converted["_Frame1"]

Converted["_Objects"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Objects"].BackgroundTransparency = 1
Converted["_Objects"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Objects"].BorderSizePixel = 0
Converted["_Objects"].Size = UDim2.new(1, 0, 1, 0)
Converted["_Objects"].Name = "Objects"
Converted["_Objects"].Parent = Converted["_Frame"]

Converted["_UIListLayout"].Padding = UDim.new(0, 5)
Converted["_UIListLayout"].SortOrder = Enum.SortOrder.LayoutOrder
Converted["_UIListLayout"].Parent = Converted["_Objects"]

Converted["_TextButton"].FontFace = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.SemiBold,
            Enum.FontStyle.Normal
        )
Converted["_TextButton"].Text = "Stop Current"
Converted["_TextButton"].TextColor3 = Color3.fromRGB(216.00000232458115, 222.00000196695328, 233.00000131130219)
Converted["_TextButton"].TextSize = 16
Converted["_TextButton"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextButton"].BackgroundTransparency = 1
Converted["_TextButton"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextButton"].BorderSizePixel = 0
Converted["_TextButton"].LayoutOrder = 1
Converted["_TextButton"].Size = UDim2.new(1, 0, 0, 20)
Converted["_TextButton"].Parent = Converted["_Objects"]

Converted["_title"].FontFace = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.Bold,
            Enum.FontStyle.Normal
        )
Converted["_title"].Text = "Automation"
Converted["_title"].TextColor3 = Color3.fromRGB(160.00000566244125, 195.0000035762787, 229.00000154972076)
Converted["_title"].TextSize = 16
Converted["_title"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_title"].BackgroundTransparency = 1
Converted["_title"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_title"].BorderSizePixel = 0
Converted["_title"].Size = UDim2.new(1, 0, 0, 16)
Converted["_title"].Name = "title"
Converted["_title"].Parent = Converted["_Objects"]

Converted["_UIPadding"].PaddingTop = UDim.new(0, 4)
Converted["_UIPadding"].Parent = Converted["_Objects"]

Converted._TextButton.MouseButton1Click:Connect(function()
    persistent_data:wipe();
    Tween.stop_all();
    for _, farm in pairs(aztup.farms) do
        for _, thread in farm.threads do
            pcall(task.cancel, thread);
        end;

        for name, _ in farm.active_features do
            if name ~= "mod_detector" then continue; end
            
            xpcall(function() 
                aztup_toggles[name]:SetValue(false);
            end, warn);
        end;

        persistent_data:set(farm.persistent_data_flag, false)
    end;

    local stop_signal = Converted["_stop_signal"]
    local frame = stop_signal:FindFirstChild("Frame")
    if frame then
        frame.Visible = false;
    end
end) 

return false;