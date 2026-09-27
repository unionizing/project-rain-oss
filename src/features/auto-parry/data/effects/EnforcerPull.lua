return {
    id = "EnforcerPull",
    
    run = function(action, data)
        if not (string.find(data.char.Name, '.enforcer')) then return end;
        if (data.targ ~= local_player.character) then return end;
        if not aztup.flags.no_enforcer_pull then return end

        task.spawn(function()
            local bp = local_player.root_part:WaitForChild("BodyPosition", 1);
            if bp then
                bp:Destroy();
            end;
        end);

        return    
end;
} 