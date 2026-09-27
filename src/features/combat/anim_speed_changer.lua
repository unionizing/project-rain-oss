local feature = Feature:new("anim_speed_changer", services.RunService.PreAnimation);
local random = Random.new();

feature.toggle_conversion_map = {
    ["Critical"] = "Criticals",
    ["Untagged"] = "Untagged",
    ["Spell"] = "Spells",
    ["Bell"] = "Bells",
    ["M1"] = "M1s"
}

feature.slider_conversion_map = {
    ["Critical"] = "anim_critical_speed", 
    ["Untagged"] = "anim_untagged_speed",
    ["Spell"] = "anim_spell_speed",
    ["Bell"] = "anim_bell_speed",
    ["M1"] = "anim_m1_speed"
}

feature.last_seen_at = {};
feature.stepping = {};

function feature:handle(track: AnimationTrack, data: any)
    if not aztup.flags.anim_speed_changer then 
        return    
end;

    local action_type = data.action_type;    
    if not aztup_options.anim_speed_changer_types.Value[self.toggle_conversion_map[action_type] ] then
        return    
end

    local multiplier = aztup.flags[self.slider_conversion_map[action_type] ];
    local chosen;

    if aztup.flags.switch_speeds then
        chosen = random:NextNumber() < 0.5 and multiplier.min or multiplier.max;
    else
        chosen = random:NextNumber(multiplier.min, multiplier.max);
    end

    local at = table.insert(self.stepping, {
        track = track,
        speed = chosen
    });

    track.Ended:Once(function() 
        table.remove(self.stepping, table.find(self.stepping, at));
    end)
end;    

function feature.update()
    local self = feature;
    for index, item in self.stepping do
        local track: AnimationTrack = item.track;
        local speed = item.speed;

        if not track.IsPlaying then
            table.remove(self.stepping, index);
            continue        
end

        if self.last_seen_at[track] == track.Speed then continue end

        track:AdjustSpeed(track.Speed * speed);
        self.last_seen_at[track] = track.Speed;
    end
end

feature.func = feature.update; 
return feature