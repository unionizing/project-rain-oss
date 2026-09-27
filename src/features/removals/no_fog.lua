return Feature:new("no_fog", scheduler:add_task(2.5), LPH_NO_VIRTUALIZE(function()
    services.Lighting.FogEnd = 1000000;

    local atmosphere = services.Lighting:FindFirstChild('Atmosphere');
    if not atmosphere then return end;
    
    atmosphere.Density = 0;
end))