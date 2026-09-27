return {
    allow_block_input = true,
    id = "DisplayThornsRed",
    name = "UmbralKnightEffect",

    run = function(action, data)
        if (data.Character ~= local_player.character) then return end;

        action.ignore_hitbox = true;
        action.offset = CFrame.new();
        action.type = "Parry";
        action.when = data.Time - data.Window;
        action.user = data.Wep:FindFirstAncestorWhichIsA("Model");
        action:play(); 

        return    
end;
} 