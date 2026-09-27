local last_update = 0;
local feature;
local last_spawn = 0;

feature = Feature:new("sanity_indicator", services.RunService.RenderStepped, LPH_NO_VIRTUALIZE(function()
    if not feature.current then
        return tick() - last_spawn > 5 and feature:spawn() or nil    
end

    if tick() - last_update < 1 then 
        return    
end
    
    last_update = tick();


    if not local_player.character:FindFirstChild("Sanity") then
        return
    end

    local sanity = local_player.character:FindFirstChild("Sanity");
    if not feature.current:FindFirstChild("Amount") then
        return feature:spawn()
    end;

    feature.current.Amount.Text = string.format("%d%%", (sanity.Value / sanity.MaxValue) * 100);
    return
end));

function feature:spawn()
    local starter_gui = game:GetService("ReplicatedStorage"):FindFirstChild("ClientStarterGui");
    local currency_gui = starter_gui and starter_gui:FindFirstChild("CurrencyGui");
    if not currency_gui then
        return    
end

    local currency_frame = currency_gui:FindFirstChild("CurrencyFrame");
    if not currency_frame then
        return    
end

    local shrine_points: ImageLabel = currency_frame:FindFirstChild("ShrinePoints");
    if not shrine_points then
        return    
end


    local icon = shrine_points:Clone();

    icon.Name = "SanityIndicator";
    icon.Icon.ImageRectOffset = Vector2.new(0, 0);
    icon.Icon.ImageRectSize = Vector2.new(0, 0);
    icon.Icon.ResampleMode = Enum.ResamplerMode.Pixelated;
    icon.Icon.ScaleType = Enum.ScaleType.Fit;
    icon.Icon.Image = "rbxassetid://95682547336441";
    icon.Amount.TextColor3 = Color3.fromRGB(244, 184, 228);
    icon.LayoutOrder = 5;
    icon:SetAttribute("HideEmpty", false);
    icon:SetAttribute("Tip_Title", "Sanity");
    icon:SetAttribute("Tip_Desc", [[Insanity builds passively in hostile environments, especially in the Depths, and can also be increased by certain attacks or abilities. As your sanity declines, youll experience negative effects such as shivering, scratching, and other disruptive debuffs, Managing your sanity is crucial in the Depths, where it drains rapidly.
    
    To recover sanity, return to the surface or visit Castle Light, which is especially important for Deepbounds.]]);
    local pg = local_player.instance:FindFirstChild("PlayerGui");
    icon.Parent = pg:WaitForChild("CurrencyGui", 9e9):WaitForChild("CurrencyFrame", 9e9);
    last_spawn = tick();

    if feature.current then
        feature.current:Destroy();
    end;
    feature.current = icon;
end;

function feature:disable()
    if not feature.current then
        return    
end
    
    feature.current:Destroy();
    feature.current = nil;
end;

function feature:enable()
    self:spawn();
end;

return feature