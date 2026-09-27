local old_y;
local feature;
local last_restream = tick();
local safe_spot = false;
feature = Feature:new("free_cam", services.RunService.RenderStepped, function() 
    if not local_player.character then return end
    
    feature.freecam.set_speed(aztup.flags.free_cam_speed or 1);
    if not aztup.flags.safe_spot then return end
    safe_spot = true;
    if tick() - last_restream > 2.5 then
        last_restream = tick();
        task.spawn(pcall, function() 
            local_player.instance:RequestStreamAroundAsync(workspace.CurrentCamera.CFrame.Position, 1000);
        end)
    end;

    
    
    
    
    
    
    local_player.root_part.AssemblyLinearVelocity = Vector3.zero;
    local_player.root_part.CFrame = CFrame.new(local_player.root_part.Position.X, old_y + 100000, local_player.root_part.Position.Z);
end);

function feature:enable()
    old_y = local_player.root_part and local_player.root_part.Position.Y or 0;
    
    feature.freecam = require("@src/utility/freecam");
    feature.freecam.enter();
    
    feature.was_in = true;
    safe_spot = false;
    local_player.instance:SetAttribute("Freecam", true);
end;

function feature:disable()
    if not self.was_in then return end
    local_player.instance:SetAttribute("Freecam", false);

    if safe_spot then 
        local_player.root_part.CFrame = CFrame.new(local_player.root_part.Position.X, old_y, local_player.root_part.Position.Z);
    end

    feature.freecam.exit();
end;

return feature