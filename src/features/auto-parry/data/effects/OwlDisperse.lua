return {
    id = "OwlDisperse",

    run = function(action, data)
        local char = data.Character;
        if not char then return end;

        local target = char:FindFirstChild('Target');
        if (not target or target.Value ~= local_player.character) then return end;

        local startedAt = tick();
        local duration = data.Duration or data.dur or 0;

        task.wait(duration / 3);

        while (tick() - startedAt <= duration + 0.3) do
            action.ignore_hitbox = true;
            action.offset = CFrame.new();
            action.type = "Parry";
            action.when = 0;
            action.user = char;
            action.allow_parry_to_roll = true;
            action:play();
            task.wait(0.2);
        end;

        return action    
end;
} 