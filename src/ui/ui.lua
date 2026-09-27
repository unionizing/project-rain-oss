 
local tab, _ = require("@src/utility/ui/wrapper");

return {
    initialize = function()
        local creation_order = {
            "Main",
            "Visuals",
            "Combat",
            "Automation"
        };
 
        for _, tab_name in pairs(creation_order) do
            aztup.tabs[tab_name] = tab.new(tab_name); 
        end

        for _, module in list_modules("ui/tabs/*") do
            local func, data = require(module);
            
            if not aztup.tabs[data.name] then 
                continue            
end;
            
            xpcall(func, warn, aztup.tabs[data.name]);   
        end

        local ThemeManager = require("@src/utility/librarys/managers/ThemeManager");
        local SaveManager = require("@src/utility/librarys/managers/SaveManager");
        
        aztup.tabs.UI = tab.new("UI");

        SaveManager:SetLibrary(aztup.ui)
        SaveManager:IgnoreThemeSettings() 
        ThemeManager:SetLibrary(aztup.ui);

        SaveManager:SetIgnoreIndexes({
            "fly",
            "noclip",
            "speed",
            "infinite_jump",
            "spotify_redirect_url",
            
        })
        SaveManager:SetFolder('Project Rain/Deepwoken-Config')
        ThemeManager:SetFolder('Project Rain/Deepwoken-Config')
        SaveManager:BuildConfigSection(aztup.tabs.UI.Tab);
        ThemeManager:ApplyToTab(aztup.tabs.UI.Tab);

        task.spawn(pcall, require("@src/ui/config_converter"));
        task.spawn(xpcall, require("@src/ui/tabs/ui"), warn, aztup.tabs.UI);

        task.spawn(function()
            aztup_toggles.mod_detector:SetValue(true);
        end);
        
        local start = tick();
        if aztup.automation:has_any() then
            task.spawn(pcall, function()
                SaveManager:LoadAutoloadConfig()
            end);
        else
            SaveManager:LoadAutoloadConfig()
        end;
        local custom_name = not LPH_OBFUSCATED and isfile("custom_name.txt") and readfile("custom_name.txt") or nil;
        Library.PRWindow:SetWindowTitle((function()
		    if custom_name then
		    	return string.format(LPH_ENCSTR("%s"), custom_name:gsub("|ACCENT", "<font color=\"#" .. Library.AccentColor:ToHex() .. "\">"))		    
end
		    return string.format(LPH_ENCSTR("pr <font color=\"#%s\">nextgen</font>"), Library.AccentColor:ToHex())
	    end)())

        aztup.auto_loaded = true;
    end;
} 