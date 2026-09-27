return {
    id = "EthironPointSpikes",

    run = function(action, data)
        local ethiron;
        for _, entity in workspace:WaitForChild("Live"):GetChildren() do
            if entity.Name:match(".avatar") then
                ethiron = entity;
                break            
end;
        end;

        for _, point in next, data.points do
            if (point.pos - local_player.root_part.Position).Magnitude < 20 then
                action.ignore_hitbox = true;
                action.offset = CFrame.new();
                action.type = "Dodge";
                action.when = 0.6;
                action.user = ethiron;
                action:play();                  
                break
            end
        end

        return action    
end;
} 