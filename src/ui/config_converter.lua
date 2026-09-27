return function()
    if isfile("Project Rain/converted.txt") then
        return    
else
        writefile("Project Rain/converted.txt", "true");
    end;

    if isfolder("ProjectRainRewrite") and isfolder("ProjectRainRewrite/settings") then
        for _, file in listfiles("ProjectRainRewrite/settings") do
            if file:match("autoload.txt") then continue end
            if not pcall(function()
                return game:GetService("HttpService"):JSONDecode(readfile(file))            
end) then
                continue            
end;

            local config_decoded = game:GetService("HttpService"):JSONDecode(readfile(file));

            local toggle_id_map = {}

            toggle_id_map["KeybindShower"] = "KeybindShower"; 
            toggle_id_map["full_bright"] = "full_bright";
            toggle_id_map["player_esp"] = "player_esp";
            toggle_id_map["mob_esp"] = "mob_esp";
            toggle_id_map["area_esp"] = "area_esp";
            toggle_id_map["m1_hold"] = "m1_hold";
            toggle_id_map["inf_zoom"] = "inf_zoom";
            toggle_id_map["OnlyShowEnabledKeybinds"] = "OnlyShowEnabledKeybinds";

            toggle_id_map["noKillBricks"] = "no_kill_bricks";

            toggle_id_map["no_stun"] = "no_stun";
            toggle_id_map["fast_swing"] = "fast_swing";
            toggle_id_map["void_mobs_the_sequel"] = "void_mobs";

            toggle_id_map["no_fog"] = "no_fog";

            toggle_id_map["no_fire"] = "no_fire";
            toggle_id_map["fly"] = "fly";
            toggle_id_map["speed"] = "speed";
            toggle_id_map["noclip"] = "noclip";
            toggle_id_map["inf_jump"] = 'infinite_jump';
            toggle_id_map["anti_ap"] = "ap_breaker";
            toggle_id_map["autoWisp"] = "auto_wisp";

            local converted_config = {
                objects = {},
                keybindPosition = config_decoded.keybindPosition
            }

            for _, object in config_decoded.objects do
                if object.type == "Toggle" and object.idx and toggle_id_map[object.idx] then
                    table.insert(converted_config.objects, {
                        idx = toggle_id_map[object.idx],
                        type = "Toggle",
                        value = object.value
                    })
                end;
            
                local str = object.idx and object.idx:gsub("keybind", "");
                if object.type == "KeyPicker" and object.idx and toggle_id_map[str] then
                    table.insert(converted_config.objects, {
                        idx = toggle_id_map[str] .. "Keybind",
                        type = "KeyPicker",
                        key = object.key,
                        mode = object.mode
                    })
                end;
            end;

            local name = file:gsub("/", "\\"):split("ProjectRainRewrite\\settings\\")[2]:gsub(".json", "");
            if isfile("Project Rain\\Deepwoken-Config\\settings\\PRLegacyConvert-" .. name .. ".json") then continue end
            Logger:long_notify("Converted config: " .. name);
            writefile("Project Rain\\Deepwoken-Config\\settings\\PRLegacyConvert-" .. name .. ".json", game:GetService("HttpService"):JSONEncode(converted_config));
        end;
    end;
end