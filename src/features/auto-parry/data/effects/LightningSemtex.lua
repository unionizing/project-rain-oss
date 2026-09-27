return {
    id = "LightningSemtex",

    run = function(action, data)
        if data.command ~= "startAttack" then return end
        
        local l_char_2 = data.char;
        local l_dur_6 = data.dur;
        local l_size_4 = data.size;

        if l_char_2 ~= local_player.character then
            return        
end;

        local user;
        for _, player in services.Players:GetPlayers() do
            if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Mantra:CarveLightning{{Electro Carve}}", true) and player.Backpack:FindFirstChild("Mantra:CarveLightning{{Electro Carve}}", true):GetAttribute("RichStats"):match("Magnet") then
                user = player.Character;
                break            
end;
        end;

        if not user then return end;
        
        local t = 0.1 - Latency:get_ping();
        task.wait(t);
        
        l_dur_6 -= t * 2;

        local start = tick();
        repeat
            if not general:in_hitbox(local_player.root_part.CFrame, local_player.root_part.CFrame, Vector3.new(l_size_4, l_size_4, l_size_4), CFrame.new(), aztup.flags.view_hitboxes) then
                continue            
end;

            action.ignore_hitbox = true;
            action.offset = CFrame.new();
            action.type = "Parry";
            action.when = 0;
            action.user = user;
            action:play();            
            task.wait(0.1);
        until tick() - start > l_dur_6;

        return action    
end;
} 