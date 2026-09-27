return {
    allow_block_input = true,
    id = "GolemLaserFire",

    run = function(action, data)
        
        local l_mob_0 = data.mob;
        local l_aimPos_0 = data.aimPos;
        
        
        if not l_mob_0 or not l_aimPos_0 then return end;
        local distance = local_player.root_part.Position - l_aimPos_0;

        if distance.Magnitude > 30 or l_mob_0:FindFirstChild("Target") and l_mob_0:FindFirstChild("Target").Value ~= local_player.character then return end;

        action.ignore_hitbox = true;
        action.offset = CFrame.new();
        action.type = "Dodge";
        action.when = 0.2;
        action.user = l_mob_0;
        action:play();                  
        
        return action    
end;
} 