return {
    id = "ShadowEncircle",

    run = function(action, data) 
        local l_target_0 = data.target;
        if not l_target_0 or l_target_0 ~= local_player.character then return end;
        local user;
        for _, player in services.Players:GetPlayers() do
            if player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Mantra:EncircleShadow{{Encircle}}", true) then
                user = player.Character;
                break            
end;
        end;
        if not user then return end;

        action.ignore_hitbox = true;
        action.offset = CFrame.new();
        action.type = "Parry";
        action.when = 0.75;
        action.user = user;
        action:play();                  
        
        return action    
end;
} 