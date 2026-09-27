return {
    allow_block_input = true,
    id = "BlueStun",
    name = "Vent",

    run = function(action, data)
        if (data.CH == local_player.character) then return end

        action.hitbox = Vector3.new(15,15,15);
        action.offset = CFrame.new();
        action.type = "Parry";
        action.when = 0;
        action.user = data.CH;
        action:play(); 

        return    
end;
}  