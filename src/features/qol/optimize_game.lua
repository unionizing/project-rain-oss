local self = Feature:new("optimize_game");

local function is_on()
    return aztup.flags.optimize_game
end

self.opti_sea = LPH_NO_VIRTUALIZE(function()
    local sea_client_func;
    local function do_loop(objects)
        for _, object in objects do
            if typeof(object) ~= "function" or not getinfo(object).source:find("SeaClient") then continue end
            if not table.find(getconstants(object), "stitched_bones") then continue end
            if not table.find(getconstants(object), "meshID") then continue end
            if not table.find(getconstants(object), "Color") then continue end

            sea_client_func = object;
            break        
end
    end;
    
    if filtergc then
        pcall(function() 
            do_loop(filtergc("function", {
                IgnoreExecutor = true,
                Constants = {
                    "stitched_bones",
                    "meshID",
                    "Color"
                }
            }))
        end);
    end;

    if not sea_client_func then
        do_loop(getgc(false));
    end;

    if not sea_client_func then
        if not LPH_OBFUSCATED then
            return print("failed to get sea_cl_func")        
else
            return        
end
    end

    local last_allowed_call = tick();
    local old;
    old = hookfunction(sea_client_func, function() 
        local delta = tick() - last_allowed_call;
        if delta < 1 / 30 and is_on() then
            return        
end

        last_allowed_call = tick();
        debug.profilebegin("Forced Sea Call"); 
        local data = old(delta);
        debug.profileend();
        return data    
end)

    return true
end);

function self:opti_clouds()
    local rep_func;
    for _, conn in getconnections(services.RunService.RenderStepped) do
        if not conn.Function then continue end
        if not debug.getinfo(conn.Function).source:find("PlayerScripts.Replication") then continue end
            
        conn:Disable()
        rep_func = conn.Function;
    end

    local last_update = tick();
    services.RunService.RenderStepped:Connect(function()
        if not rep_func then return end
        if tick() - last_update < 1 / 10 then return end

        return rep_func(tick() - last_update)    
end);
end
 
function self:opti_world_client()
    local last_world_client_func;
    local function apply()
        task.wait(1);

        local hi = "WorldClient";
        local cns = getconnections(services.RunService.PreRender);
        return LPH_NO_VIRTUALIZE(function() 
            local conn;
            for _, object in cns do
                local func = object.Function;
                if not func or not getinfo(func).source:find(hi) then
                    continue                
end
            
                if last_world_client_func == func then
                    return task.delay(1, apply)                
end
            
                last_world_client_func = func;
                object:Disable();
                conn = object;
            end
        
            local last_update = tick();
        
            return services.RunService.PreRender:Connect(function()
                if tick() - last_update < 1 / 15 or not conn then return end
                last_update = tick();

                return conn:Fire(tick() - last_update)
            end)
        end)()    
end;

    apply();
    local_player.instance.PlayerGui.ChildAdded:Connect(function(object) 
        if not is_on() then return end
        if object.Name ~= "WorldClient" then return end

        apply();
    end)
end


self.enable = function()
    
    if aztup.automation:has_any() or aztup.automation:should_auto_start() then return end

    
    
    
    
    
    
    
    
    
    

    
    
    
    
    

    
    

    
    

    
    
    
    
    
    
    
    
    

    
    

    
    task.spawn(function()
        self:opti_sea();
    end)
    
    
    

    task.spawn(function()
        self:opti_clouds()
    end)

    return
end;

return self