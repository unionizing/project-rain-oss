return {
    id = "WindCarve",

    run = function(action, data)
        if data.command ~= "startAttack" then return end
        local range = data.range;
        local size = data.size;
        local char = data.char;
        local dur = data.dur;
        if char == local_player.character or not char then
            return        
end;

        local root = char:FindFirstChild("HumanoidRootPart");
        if not root then return end;
        local start = tick();
        repeat task.wait()
            local v315 = root.CFrame * CFrame.new(0, 0.5, -(7 + size / 2 + range));
            if general:in_hitbox(local_player.root_part.CFrame, v315, Vector3.one * (11.5 + size), CFrame.new(), aztup.flags.view_hitboxes) then
                action.ignore_hitbox = true;
                action.offset = CFrame.new();
                action.type = "Parry";
                action.when = 0;
                action.user = char;
                action:play();          
            end;
            if not char:FindFirstChild("StopCarve") then
                task.wait(0.2);
            else
                break            
end;
        until tick() - start > dur + 0.2;
        
        return action    
end;
} 