local feature = Feature:new("fast_mode", services.RunService.PreRender, function() end);

function feature:enable()
    services.Lighting.LightingStyle = Enum.LightingStyle.Soft;
    sethiddenproperty(services.Lighting, "Technology", Enum.Technology.Compatibility)
end;

return