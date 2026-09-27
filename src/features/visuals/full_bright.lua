
return Feature:new("full_bright", scheduler:add_task(1), LPH_NO_VIRTUALIZE(function()
    local level = 255 * (aztup.flags.fullbright_intensity / 100);
    services.Lighting.Ambient = Color3.fromRGB(level, level, level);
    
    
end))