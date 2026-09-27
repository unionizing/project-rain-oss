local KEYWORDS = { 
    "vkei", 
    
    "moe",
    "scary"
};

local function name_mentions_combosser(name)
    if not name or name == "" then
        return false    
end;

    local lowered = name:lower();
    for _, word in KEYWORDS do
        if lowered:find(word, 1, true) then
            return true        
end;
    end;

    return false
end;

local feature do
    feature = Feature:new("combosser_detector", services.Players.PlayerAdded, function(player)
        feature:check(player);
    end);

    feature.avatar_cache = {};

    function feature:get_avatar_items(player)
        local user_id = tostring(player.UserId);
        if self.avatar_cache[user_id] ~= nil then
            return self.avatar_cache[user_id]        
end;

        local success, data = pcall(services.Players.GetCharacterAppearanceInfoAsync, services.Players, player.UserId);
        if not success or not data or not data.assets then
            self.avatar_cache[user_id] = false;
            return false        
end;

        self.avatar_cache[user_id] = data.assets;
        return data.assets    
end;

    function feature:check(player)
        if player == local_player.instance then
            return        
end;

        task.spawn(function()
            local assets = self:get_avatar_items(player);
            if not assets then
                return            
end;

            for _, asset in assets do
                if name_mentions_combosser(asset.name) then
                    Logger:long_notify_sound(string.format("%s' might be a combosser due to their avatar.", player.Name));
                    break                
end;
            end;
        end);
    end;

    function feature:enable()
        for _, player in pairs(services.Players:GetPlayers()) do
            task.spawn(self.check, self, player);
        end;
    end;

    function feature:disable()
        self.avatar_cache = {};
    end;
end;

return feature