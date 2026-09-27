--[[
    suup twan
]]

local auto_start_flags = {
    "auto_saramed",
    "soup_echofarm",
    "flask_echofarm",

    "autoecho_titus",
    "auto_titus",
    "auto_echo_layer2",
    "ministry_notefarm",
    "auto_moonseyrie",
    'auto_layertwo',
    'auto_ferryman',
    'auto_authority_missions',
    'auto_duke',
    'auto_escape_depths',
    'auto_progress',
    'auto_voi'
}
    
local loader = {
    initialize = function()
        for _, farm in list_modules("automation/persistent_tasks/*") do
            local farm_module = require(farm);
    
            if farm_module and typeof(farm_module) == "table" and farm_module.persistent_data_flag then
                aztup.farms[farm_module.id] = farm_module;
                continue;
            end;
        end;
    end,
    
    should_auto_start = function(self)
        for _, flag in pairs(auto_start_flags) do
            if persistent_data:get(flag, false) == true then
                return true;
            end;
        end;
     
        return false;
    end,

    has_any = function(self)
        for _, farm in pairs(aztup.farms) do
            if persistent_data:get(farm.persistent_data_flag, false) ~= true then
                continue;
            end;
    
            return true;
        end;
    
        return false;
    end,
    
    set = function(self, flag, on)
        persistent_data:set(flag, on)
        self:start();
    end,

    start = function(self)
        if not services.NetworkClient:FindFirstChild("ClientReplicator") then
            return server_utility:quick_hop()
        end;
        
        local hopping = false;
        services.GuiService.ErrorMessageChanged:Connect(function()	
            if hopping or getgenv().dont_auto_hop_pls then return; end
            if not aztup.automation:has_any() then return; end
			local Code = services.GuiService:GetErrorCode().Value
	
			if Code >= Enum.ConnectionError.DisconnectErrors.Value then
                task.wait(60);
                hopping = true;
	            return server_utility:quick_hop()
			end
		end);

        local should_anti_afk;
        for _, farm in pairs(aztup.farms) do
            if not persistent_data:get(farm.persistent_data_flag, false) then
                continue;
            end;

            if farm.not_allowed and farm:not_allowed() then
                continue;
            end;
            
            should_anti_afk = true;
            task.spawn(function()
                farm:run();
            end);
        end;

        if should_anti_afk then
            task.spawn(function()
                local vim = Instance.new('VirtualInputManager') 

                while task.wait(120) do
                    vim:SendKeyEvent(true, Enum.KeyCode.Unknown, false, game)
                    task.wait(0.1)
                    vim:SendKeyEvent(false, Enum.KeyCode.Unknown, false, game)
                    task.wait(0.1)
                end
            end)
            require("@src/automation/exit_ui");
        end
    end
};

return loader;