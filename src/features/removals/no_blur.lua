local feature = Feature:new("no_blur", services.RunService.PreRender, LPH_NO_VIRTUALIZE(function()
    for _, object in services.Lighting:GetChildren() do
        if not object:IsA("BlurEffect") then continue end

        object.Size = 0;
    end;
end));

return feature