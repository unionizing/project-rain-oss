local tabs = {};

local spotify_widget = require("@src/features/misc/spotify_widget");


function tabs:create_fast_flags(tab)
	local groupbox = tab:newGroupBox("Script Toggles", false);
	groupbox:newLabel("ALL FEATURES HERE REQUIRE A REJOIN!");

	if identifyexecutor() == "Synapse Z" then
		groupbox:newButton("[syn z] faster limited esp", function()
			fflags:set("faster_limited_esp", not fflags:get("faster_limited_esp"));
			Logger:long_notify_sound("now set to:", fflags:get("faster_limited_esp"))
		end);	
	end;

	groupbox:newButton("new task scheduler", function()
		fflags:set("new_task_scheduler", not fflags:get("new_task_scheduler"));
		Logger:long_notify_sound("now set to:", fflags:get("new_task_scheduler"))
	end);	

	groupbox:newButton("silent mode load notif", function()
		fflags:set("dont_notify_on_first_exec", not fflags:get("dont_notify_on_first_exec"));
		Logger:long_notify_sound("now set to:", fflags:get("dont_notify_on_first_exec"))
	end);	

	groupbox:newButton("disable auto showing ui", function()
		fflags:set("dont_auto_show_ui", not fflags:get("dont_auto_show_ui"));
		Logger:long_notify_sound("auto show ui now set to:", not fflags:get("dont_auto_show_ui"))
	end);	

	groupbox:newButton("auto load", function()
		fflags:set("auto_load", not fflags:get("auto_load"));
		Logger:long_notify_sound("now set to:", fflags:get("auto_load"))
	end)
end

function tabs:create_ally_system(tab)
	local groupbox = tab:newGroupBox("Ally Filtering", true);

	groupbox:newToggle("ally_system", "Enable Ally Filtering", false, "Allows you to designate players as allies, preventing certain interactions with them.", function() end);

	local ally_system_dependency_box = groupbox:newDependencyBox("ally_system");
	ally_system_dependency_box:newDropdown('ally_settings', 'Ally Filters', {
		"Deepwoken Allys",
		"Roblox Friends",
		"Custom Players",
		"Custom Guilds",
		"Same Guild",
	}, {}, true, "Targets to desginate as allies.", function() end, true);

	local ally_players_dependency, raw_ap = groupbox:newDependencyBox();
	ally_players_dependency:newTextbox('ally_players_input', 'Ally Players', false, '', nil, '(semicolon separated list of player names to designate as allies) Ex: "Player1;Player2;Player3"');
	raw_ap:SetupDependencies({
		{ aztup_toggles.ally_system, true },
		{ aztup_options.ally_settings, "Custom Players" }
	});
	
	local ally_guilds_dependency, raw_ag = groupbox:newDependencyBox();
	ally_guilds_dependency:newTextbox('ally_guilds_input', 'Ally Guilds', false, '', nil, '(semicolon separated list of guild names to designate as allies) Ex: "Guild1;Guild2;Guild3"');
	raw_ag:SetupDependencies({
		{ aztup_toggles.ally_system, true },
		{ aztup_options.ally_settings, "Custom Guilds" }
	});
end

local setup = function(tab)
	tabs:create_fast_flags(tab)
	tabs:create_ally_system(tab);
end;

local new_cc_func = function(...)
	task.spawn(pcall, setup, ...);
end;

return new_cc_func, {
    name = "Config"
}