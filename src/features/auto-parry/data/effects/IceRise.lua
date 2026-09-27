return {
    id = "IceRise",

    run = function(action, data)
        local char;
        for _, entity in workspace.Live:GetChildren() do
            if entity.Name:find(".kyrsgarde_champion") then
                char = entity;
                break            
end;
        end

        if not char then return end
        
        action.ignore_hitbox = true;
        action.offset = CFrame.new();
        action.type = "Parry";
        action.when = 0.35;
        action.user = char;
        action.allow_parry_to_roll = true;
        action:play();
        return action    
end;
} 