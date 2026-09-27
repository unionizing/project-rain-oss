





local dev_file = getgenv().dev_file or string.format("Project Rain/logs/client-%s", tostring(tick()))

if not LPH_OBFUSCATED then
    if not isfolder("Project Rain/logs") then
        makefolder("Project Rain/logs");
    end;

    if not getgenv().dev_file then
        getgenv().dev_file = dev_file;
        writefile(dev_file, "");
    end;
end;

local Logger = {} do
    function Logger:short_notify(...)
        if aztup and aztup.silent_mode then return end

        local args = {...};
        for i, arg in args do
            args[i] = tostring(arg);
        end; 
        local message = table.concat(args, " ");
        Library:Notify(message, 2.5);
    end

    function Logger:notify(...)
        if aztup and aztup.silent_mode then return end

        local args = {...};
        for i, arg in args do
            args[i] = tostring(arg);
        end;
        local message = table.concat(args, " ");
        Library:Notify(message, 5);
    end
    
    function Logger:notify_sound(...)
        if aztup and aztup.silent_mode then return end

        local args = {...};
        for i, arg in args do
            args[i] = tostring(arg);
        end;
        local message = table.concat(args, " ");
        Library:NotifyWithSound(message, 5);
    end

    function Logger:long_notify_sound(...)
        if aztup and aztup.silent_mode then return end

        local args = {...};
        for i, arg in args do
            args[i] = tostring(arg);
        end;
        local message = table.concat(args, " ");
        Library:Notify(message, 60);
    end

    function Logger:long_notify(...)
        if aztup and aztup.silent_mode then return end

        local args = {...};
        for i, arg in args do
            args[i] = tostring(arg);
        end;
        local message = table.concat(args, " ");
        Library:Notify(message, 60);
    end

    function Logger.log_for_devs(...)
        if LPH_OBFUSCATED then return end
        
        local args = {...};
        for i, arg in args do
            args[i] = tostring(arg);
        end;
        local message = table.concat(args, " ");
        
        appendfile(dev_file, "\n[l] " .. message);
    end;

    function Logger.log(...)
        local args = {...};
        for i, arg in args do
            args[i] = tostring(arg);
        end;
        local message = table.concat(args, " ");
        if Library then
            Library:AddTextToInfoLogger("[I]: " .. message, "[I]: " .. message, nil)
        elseif not (aztup and aztup.silent_mode) then
            print("[I]: " .. message)
        end;
    end

    function Logger.warn(...)
        local args = {...};
        for i, arg in args do
            args[i] = tostring(arg);
        end;
        local message = table.concat(args, " ");
        if Library then
            Library:AddTextToInfoLogger("[W]: " .. message, "[W]: " .. message)
        elseif not (aztup and aztup.silent_mode) then
            warn("[W]: " .. message)
        end;
    end

    function Logger.error(...)
        local args = {...};
        for i, arg in args do
            args[i] = tostring(arg);
        end;
        local message = table.concat(args, " ");
        if Library then
            Library:AddTextToInfoLogger("[E]: " .. message, "[E]: " .. message)
        elseif not (aztup and aztup.silent_mode) then
            warn("[E]: " .. message)
        end;
    end
end

return Logger