local feat = Feature:new("apply_fflags");
local old_flags;

function feat:enable()
    if not isfile("fflags.json") then
        return Logger:long_notify("fflags.json not found, please paste your fflags into the executor workspace under that name.")    
end

    local applying_flags_file = readfile("fflags.json");
    if not applying_flags_file then
        return Logger:long_notify("failed to read file.")    
end

    local success, applying_flags = pcall(function() return services.HttpService:JSONDecode(applying_flags_file) end);
    if not success then
        return Logger:long_notify("failed to decode json, make sure it's valid: " .. applying_flags)    
end

    if persistent_data:get("old_fflags", nil) then
        old_flags = persistent_data:get("old_fflags", nil); 
    else
        old_flags = {};
    end

    for flag, value in old_flags do
        pcall(function() 
            setfflag(flag, value);
        end)
    end

    for flag, value in applying_flags do
        pcall(function() 
            local old_flag = getfflag(flag);
            old_flags[flag] = old_flag;
            setfflag(flag, value);
        end)
    end

    return true
end;

function feat:disable()
    if old_flags then
        for flag, value in pairs(old_flags) do
            pcall(function() setfflag(flag, value) end);
        end
    end
end;

return feat