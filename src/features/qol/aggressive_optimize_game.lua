local self = Feature:new("aggressive_optimize_game");

local function is_on()
    return aztup.flags.aggressive_optimize_game
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

    self:opti_world_client();
    return
end;

return self