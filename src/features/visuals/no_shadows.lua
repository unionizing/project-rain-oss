
return Feature:new("no_shadows", scheduler:add_task(2.5), LPH_NO_VIRTUALIZE(function()
    services.Lighting.GlobalShadows = false;
end))