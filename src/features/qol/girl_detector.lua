local HttpService = game:GetService("HttpService");




local GENDER_KEYWORDS = {
    ["Girl"] = { "girl", "woman", "female" },
    ["Boy"] = { "boy", "man", "male" },
    ["Non-binary"] = { "non-binary", "nonbinary", "non binary", "enby" },
};

local function bio_states_gender(lowered, gender)
    local keywords = GENDER_KEYWORDS[gender];
    if not keywords then
        return false    
end;

    for _, word in keywords do
        if word:find("[%s%-]") then
            if lowered:find(word, 1, true) then
                return true            
end;
        elseif lowered:find("%f[%a]" .. word .. "%f[%A]") then
            return true        
end;
    end;

    return false
end;

local function bio_states_any_gender(bio, selected_genders)
    if not bio or bio == "" then
        return nil    
end;

    local lowered = bio:lower();
    for gender, is_selected in selected_genders do
        if is_selected and bio_states_gender(lowered, gender) then
            return gender        
end;
    end;

    return nil
end;

local feature do
    feature = Feature:new("girl_detector", services.Players.PlayerAdded, function(player)
        feature:check(player);
    end);

    feature.bio_cache = {};

    function feature:get_bio(player)
        local user_id = tostring(player.UserId);
        if self.bio_cache[user_id] ~= nil then
            return self.bio_cache[user_id]        
end;

        local success, response = pcall(game.HttpGet, game, "https://users.roblox.com/v1/users/" .. user_id);
        if not success then
            self.bio_cache[user_id] = false;
            return false        
end;

        local decode_success, data = pcall(HttpService.JSONDecode, HttpService, response);
        if not decode_success or not data then
            self.bio_cache[user_id] = false;
            return false        
end;

        self.bio_cache[user_id] = data.description or false;
        return self.bio_cache[user_id]    
end;

    function feature:get_selected_genders()
        local option = aztup_options.gender_detector_genders;
        return option and option.Value or { ["Girl"] = true }    
end;

    function feature:check(player)
        if player == local_player.instance then
            return        
end;

        task.spawn(function()
            local bio = self:get_bio(player);
            local matched_gender = bio_states_any_gender(bio, self:get_selected_genders());
            if matched_gender then
                Logger:long_notify_sound(string.format("%s's bio states they're a %s.", player.Name, matched_gender:lower()));
            end;
        end);
    end;

    function feature:enable()
        for _, player in pairs(services.Players:GetPlayers()) do
            task.spawn(self.check, self, player);
        end;
    end;

    function feature:disable()
        self.bio_cache = {};
    end;
end;

return feature