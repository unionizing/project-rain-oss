return {
    id = "GenericTelegraph",
    
    run = function(action, data)
        local l_char_0 = data.char;
        local l_part_0 = data.part;
        local l_telegraph_0 = data.telegraph;

        if l_part_0 == local_player.root_part and l_char_0 == local_player.character then 
            local dur = data.dur or 0.5;

            if dur ~= 1 then
                return action            
end

            if not table.find({
                "dodge_only",
                "block_only",
                "parry_only"
            }, l_telegraph_0) then return action end
            
            action.ignore_hitbox = true;
            action.offset = CFrame.new();
            action.type = l_telegraph_0 == "dodge_only" and "Dodge" or "Parry";
            action.when = 0.95;
            action.user = l_char_0;
            action:play();                  
        end
        
        return action    
end;
} 