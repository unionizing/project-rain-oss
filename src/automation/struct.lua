--[[
AutoFarm.construct({
persistent_data_store = "saramed_store",
persistent_data_flag = "auto_saramed",
state_machine = StateMachine.create({
events = {

}
}),
features = {
"optimize_game",
"mod_detector",
"full_bright",
"no_fall",
"no_fog",
},

character_creator_handler_used = false,
character_creator_handler_opts = {
all_echo_modifiers = true,
origin = "Vigils",

},
}) 
]]

local automation_struct = {};
automation_struct.__index = automation_struct;

automation_struct.construct = function(self, opts)
    local obj = {};
    setmetatable(obj, automation_struct);
    
    obj.persistent_data_store = opts.persistent_data_store;
    obj.persistent_data_flag = opts.persistent_data_flag;
    obj.state_machine = opts.state_machine;
    obj.not_allowed = opts.not_allowed;
    obj.features = opts.features;
    obj.id = opts.id;
    obj.on_run = opts.on_run;
    
    obj.character_creator_handler_used = opts.character_creator_handler_used or false;
    obj.character_creator_handler_opts = opts.character_creator_handler_opts or {};
    obj.active_features = {}
	obj.threads = {};
	obj.toggled_for_user = {};
    return obj;
end;

automation_struct.run = LPH_NO_VIRTUALIZE(function(self)
	self.threads = {};
	self.toggled_for_user = {};
    for _, feature in pairs(self.features) do
		if aztup.flags[feature] then
			continue
		end
        
        aztup.flags[feature] = true;
        
        local feat = aztup.features[feature];
		if not feat then
			continue
		end
        
        if feat.conn then 
			if not feat.current_connection then
				--Logger.log("enabling feature: " .. ID)
				feat.current_connection = feat.conn:Connect(function(...)
					--(aztup and aztup.silent_mode and function() end or debug.profilebegin)(ID);
					xpcall(feat.update, function(data) 
						Logger.warn(string.format("%s | %s", feature, data));
					end, ...);
					--(aztup and aztup.silent_mode and function() end or debug.profileend)();
				end);
				aztup.maid:give_task(feat.current_connection);
			end
		end

		task.spawn(xpcall, function() --yields the WHOLE fucking ui loading.
			feat:enable();
		end, Logger.warn);

		if aztup_toggles[feature] then
			aztup_toggles[feature].Value = true;
			aztup_toggles[feature]:Display();
		end;

        self.active_features[feature] = feat;
    end;
    
    if self.on_run then
        task.spawn(self.on_run);
    end
    
	table.insert(self.threads, task.spawn(function()
		self.state_machine:start();
	end));
end);

automation_struct.create_character = function(self)
    local options = self.character_creator_handler_opts
	local requests = services.ReplicatedStorage:WaitForChild("Requests")
	local characterCreator = requests:WaitForChild("CharacterCreator")
	local pickSpawn = characterCreator:WaitForChild("PickSpawn")
	local changeWeapon = characterCreator:WaitForChild("ChangeWeapon")
	local finishCreation = characterCreator:WaitForChild("FinishCreation")
	local toggleMetaModifier = requests:WaitForChild("ToggleMetaModifier", 20)
	local playerGui = local_player.instance:WaitForChild("PlayerGui")
	local characterGui = playerGui:WaitForChild("CharacterCreator")
	local gameMode = characterGui:WaitForChild("GameMode"):WaitForChild("Options")
	local standard = gameMode:WaitForChild("Standard"):WaitForChild("Element")
	local suc;

	pcall(function()
		if persistent_data and persistent_data:get("auto_progress") then return; end
		
		for _ = 1, 5 do
			firesignal(standard.MouseButton1Click)
			task.wait(0.1)
		end
	end)

    if options.origin then
	    for _ = 1, 10 do
	    	suc = pickSpawn:InvokeServer(options.origin)
	    	if suc then
	    		break
	    	end
	    	task.wait(0.1)
	    end
    end;

    if options.weapon then
	    for _ = 1, 10 do
	    	suc = changeWeapon:InvokeServer(options.weapon)
	    	if suc then
	    		break
	    	end
	    	task.wait(0.1)
	    end
    end


    if options.modifiers and toggleMetaModifier then
        for _, modifier in options.modifiers do
            local args = {
                modifier
            }
            toggleMetaModifier:FireServer(unpack(args))
            
            if (#options.modifiers == 1) then break end
            task.wait(1)
        end
    end

	local pickBoon = characterCreator:WaitForChild("PickBoon")
	local pickFlaw = characterCreator:WaitForChild("PickFlaw")
	local dataReplication = require(game:GetService("ReplicatedStorage"):WaitForChild("Info"):WaitForChild("DataReplication")).GetData()

	for _, flaw in next, dataReplication.Flaws do
		pickFlaw:InvokeServer(tostring(flaw))
	end

	for _, boon in next, dataReplication.Boons do
		pickBoon:InvokeServer(tostring(boon))
	end

	pickBoon:InvokeServer("Autodidact")
	task.wait(1.5)
	pickFlaw:InvokeServer("Obvious")

	task.spawn(function()
		finishCreation:InvokeServer()
	end) 
    
    task.spawn(function()
	    local choicePrompt = playerGui:WaitForChild("ChoicePrompt")
	    local choice = choicePrompt:WaitForChild("Choice", 30)

		if not choice then return; end

	    choice:FireServer(true)
    end)

    while true do
        task.wait()

        if local_player.character and local_player.character.Parent and local_player.character.Parent.Name == "Live" then
            break;
        end
    end

    local_player.character:WaitForChild("HumanoidRootPart")
    local_player.character:WaitForChild("Humanoid")
end
 
return automation_struct; 