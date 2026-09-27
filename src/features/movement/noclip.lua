local modified_parts = {};
local feature = Feature:new("noclip", game:GetService("RunService").Stepped, LPH_NO_VIRTUALIZE(function()
    if is_chime and aztup.flags.chime_safety then
        return aztup_toggles.noclip:SetValue(false)    
end;
    
    if not local_player.character then
        return    
end;

    if aztup.flags.dont_noclip_while_knocked and EffectReplicator:HasEffect("Knocked") then
        for _, modified_part in modified_parts do
            modified_part.CanCollide = true;
        end;
    
        table.clear(modified_parts);
        return    
end;

    if not EffectReplicator:FindEffect("TPSafe") then
        EffectReplicator:CreateEffect("TPSafe");
    end;

    for _, part in local_player.character:QueryDescendants('BasePart[CanCollide = true]') do
        part.CanCollide = false;
        
        if not table.find(modified_parts, part) then
            table.insert(modified_parts, part);
        end;
    end;

    return
end));

function feature:disable()
    for _, modified_part in modified_parts do
        modified_part.CanCollide = true;
    end;

    table.clear(modified_parts);
end;

return feature