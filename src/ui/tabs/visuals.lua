
return function(tab, groupbox)
	local modifiers_groupbox = tab:newGroupBox("Modifiers", false);
	
    
	local modifier_toggles = {
		{"leaderboard_spectate", "Leaderboard Spectate", false, "Allows you to spectate players using the leaderboard by clicking on them.", NoKeybind = true},
		{"sanity_indicator",     "Sanity Indicator", false, "Makes a currency icon for your sanity. Similar to how 'Knowledge' & 'Notes' have one.", NoKeybind = true},
		{"proximity_list",       "Player Proximity", false, "Displays a list of players in your vicinity.", NoKeybind = true},
		{"show_all_on_map",      "Show All On Map", false, "Allows you to see everyone on the map.", NoKeybind = true},
		{"streamer_mode",        "Streamer Mode", false, "Hides your name.", NoKeybind = true},
		{"chain_counter",        "Chain Counter", false, "Displays a bottom ring under your shiftlock counting how many 'Chain Of Perfection' Stacks you have.", NoKeybind = true},
		{"noclip_camera",        "Noclip Camera", false, "Lets your camera clip thru walls - Enabled with noclip by default, This toggle was added for automation.", NoKeybind = true},
		{"full_bright",          "Full Bright", false, "Brightens your game", NoKeybind = true},

        {"show_chat", "Show Chat", false, "Unhides the roblox chat.", NoKeybind = true},
        {"inf_zoom",  "Inf Zoom", false, "Infinite Zoom.", NoKeybind = true},
        {"free_cam",  "Freecam", false, "Free camera movement."},
		{"zoom", "Zoom", false, "Allows you to zoom in on objects in your game"}
	};

	table.insert(modifier_toggles, {"race_morph_menu", "Race Morph Menu", false, "Opens the Deepwoken race/face/enchant customization menu (same as its F4 shortcut).", NoKeybind = true});

	modifiers_groupbox:newToggleGroup(modifier_toggles);

    
	
	
	
	
	
	
	
    

    
    

	
	
	
	

    local zoom_box = modifiers_groupbox:newDependencyBox("zoom")
	zoom_box:newToggle("apply_mouse_sens", "Apply Mouse Sensitivity", false, "Applies the zoom mouse sensitivity.")
	zoom_box:newSlider("zoom_sens_mult", "Zoom Multiplier", 0.5, 0.1, 1, 1, true, "x");

    local full_bright_dependency_box = modifiers_groupbox:newDependencyBox("full_bright");
	full_bright_dependency_box:newSlider("fullbright_intensity", "Intensity", 100, 0, 100, 0, true, "%");

    local player_proxim_box = modifiers_groupbox:newDependencyBox("proximity_list");
	player_proxim_box:newToggle("show_list", "Proximity List", false, "Allows the actual list to be displayed.");
	player_proxim_box:newToggle("notify_in_range", "Proximity Notifications", false, "Notifys you when a player enters your set range.");
    player_proxim_box:newSlider("player_proximity_range", "Proximity Range", 1000, 5, 10000, 0, true);
	player_proxim_box:newToggle("notify_with_sound", "Proximity Sounds", false, "Plays a sound when a player enters your set range.");
    player_proxim_box:newSlider("player_proximity_vol", "Proximity Volume", 1.5, 0.1, 10, 1, true);

    local free_cam_box = modifiers_groupbox:newDependencyBox("free_cam");
	free_cam_box:newToggle("safe_spot", "Freecam @ Safespot", false, "Free camera movement.");
    free_cam_box:newSlider("free_cam_speed", "Freecam Speed", 4, 1, 30, 0, true);
	local esp_tabbox = tab:newTabbox("ESP", true);
	local esp_groupbox = esp_tabbox:newTab("Player");
	local main_esp_groupbox = esp_tabbox:newTab("Global");

    esp_groupbox:newToggleWithKeybind("player_esp", "Player ESP", not aztup.silent_mode, "Displays Players", nil, false):AddColorPicker("player_esp_color", {
		Default = Color3.fromRGB(205, 214, 244),
		Title = "Color"
	});
	
    esp_groupbox:newToggle("vw_color", "Voidwalker Color", true, "Displays a different color for voidwalkers."):AddColorPicker("voidwalker_esp_color", {
		Default = Color3.fromRGB(203, 166, 247),  
		Title = "Color"
	});

    esp_groupbox:newToggle("gm_color", "Guildmate Color", true, "Displays a different color for guildmates."):AddColorPicker("guildmate_esp_color", {
		Default = Color3.fromRGB(148, 226, 213),
		Title = "Color"
	});
	
    

esp_groupbox:newToggleWithKeybind("esp_healthbar", "Player Healthbars", false, "Displays Healthbars on Players.", nil, false);
    esp_groupbox:newToggleWithKeybind("esp_boxes", 	   "Player Boxes", false, "Displays Boxes on Players.", nil, false);
	esp_groupbox:newToggleWithKeybind("esp_nametags", 	   "Player Names", true, "Displays Names on Players.", nil, false);
    esp_groupbox:newToggle("esp_fadeout", "Player Fadeout", false, "Fades out players based on distance, increases if hovered. Performance heavy due to a roblox bug.");
    esp_groupbox:newToggle("esp_fadeout_hover", "Player Fadeout Hovering", true, "Changes transparency if you are hovering over a label.");

    esp_groupbox:newSlider("text_size", "Text Size", 12, 6, 60, 0, true, "px");

	esp_groupbox:newSlider("player_fadeout_distance", "Fadeout Divisor", 5000, 100, 50000, 0, true, "s");
    esp_groupbox:newSlider("max_player_distance", "Player ESP Distance", 20000, 100, 50000, 0, true, "s");
	
	
    esp_groupbox:newDropdown('ESP_TAGS', 'ESP Tags', {
		"Roblox Display Name",
    	"Roblox Player Name",
    	"Character Name",
    	"Health %",
    	"HP/Max",

    	"Level",
    	"Danger Time",
    	"Ping",
    	"Distance",
		"Agility"
    },{
    	"Character Name",
    	"Health %",
    	"HP/Max",
    	"Level",
    	"Danger Time",
    	"Ping",
    	"Distance"
    }, true, 'Tags for ESP', function() end, true)
    esp_groupbox:newDropdown('ESP_BARS', 'ESP Bars', {
    	"posture", 
    	"sanity", 
    	"hunger", 
    	"water", 
    	"blood", 
    	"armor"
    }, {
    	"sanity",
    	"blood",
    	"posture"
    }, true, 'Bars for ESP', function() end, true)

	local vals = {
		"Lexend",
		"Lexend Bold",
		"Lexend Medium",
	};
	
	for i, v in Enum.Font:GetEnumItems() do
		table.insert(vals, v.Name);
	end	

	if fflags:get("faster_limited_esp") then
		local syn_z_fonts = {};

		for i, v in Drawing.Fonts do
			if i == "new" then continue end
			
			table.insert(syn_z_fonts, i);
		end	

		main_esp_groupbox:newDropdown('SynZ_Font', 'Fast ESP Font', syn_z_fonts, "UI", false, 'Font for ESP', function() end, true);
	end

    main_esp_groupbox:newDropdown('Font', 'Fonts', vals, "Arial", false, 'Font for ESP', function() end, true);
	main_esp_groupbox:newDropdown('distance_naming', 'Distance Terminology', {
		"meters & km",
		"studs"
	}, "meters & km", false, 'Font for ESP', function() end, true);
    main_esp_groupbox:newSlider("esp_update_rate", "ESP Label Update Rate", 2, 1, 1000, 0, true, "fps");

	main_esp_groupbox:newToggle("show_stored_damage", "Show Stored Damage", false, "Displays pending Poser stack damage as a colored overlay on Player/Mob healthbars."):AddColorPicker("show_stored_damage_color", {
		Default = Color3.fromRGB(137, 180, 250),
		Title = "Color",
	});

	
	
	
	
	
	
	

	local function mk_esp(name, flag, description, color, right)  

		local movement_tabbox = tab:newTabbox("Visuals", right);
		local group = movement_tabbox:newTab(name:gsub(" ESP", "") .. "s");
		local options = movement_tabbox:newTab("Options");
		group:newToggleWithKeybind(flag, name, false, description):AddColorPicker(flag.."_color", {
			Default = color or Color3.fromRGB(255, 255, 255),
			Title = name .. " Color",
			Transparency = 0, 
		});

		options:newSlider(flag .. "_text_size", "Text Size", 15, 6, 60, 0, true, "px");
		options:newSlider(flag .. "_max_dist", "Max Dist", 2000, 1, 50000, 0, true, "px");
		return group, options	
end;

	mk_esp("Dropped Item ESP", "dropped_item_esp", "Displays Dropped Items", Color3.fromRGB(175, 255, 215), false);
	mk_esp("Owl Feather ESP", "owl_esp", "Displays Owl Feathers", Color3.fromRGB(106, 25, 206), true);
	local ingredient_esp_group = mk_esp("Ingredient ESP", "ingredient_esp", "Displays Ingredients", Color3.fromRGB(137, 180, 250), false);
	mk_esp("Jetty Post ESP", "jetty_post_esp", "Displays Ship Spawners/Jetty Posts", Color3.fromRGB(243, 181, 156), false);

	mk_esp("Whirlpool ESP", "whirlpool_esp", "Displays Areas", Color3.fromRGB(137, 180, 250), false);
	mk_esp("Artifact ESP", "artifact_esp", "Displays Artifacts", Color3.fromRGB(203, 166, 247), true);
	if game.PlaceId == 86761619761103 then 
	mk_esp("Boundary ESP", "boundary_esp", "Displays Boundarys", Color3.fromRGB(233, 214, 244), true);
	end;
	mk_esp("Campfire ESP", "campfire_esp", "Displays Campfires", Color3.fromRGB(243, 181, 156), true);
	mk_esp("Obelisk ESP", "obelisk_esp", "Displays Obelisks", Color3.fromRGB(255, 255, 255), false);
	mk_esp("Banner ESP", "banner_esp", "Displays Banners", Color3.fromRGB(156, 243, 185), true);
	mk_esp("Meteor ESP", "meteor_esp", "Displays Bell Meteors", Color3.fromRGB(238, 153, 160), true);
	local chest_esp_group = mk_esp("Chest ESP", "chest_esp", "Displays Chests", Color3.fromRGB(249, 226, 175), false);
	mk_esp("Crate ESP", "crate_esp", "Displays Crates", Color3.fromRGB(237, 135, 150), true);
	mk_esp("Cache ESP", "cache_esp", "Displays Caches", Color3.fromRGB(183, 189, 248), true);

	mk_esp("Shop ESP", "shop_esp", "Displays Shops", Color3.fromRGB(216, 221, 233), false);
	mk_esp("Area ESP", "area_esp", "Displays Areas", Color3.fromRGB(205, 214, 244), false);
	mk_esp("Bag ESP", "bag_esp", "Displays Bags", Color3.fromRGB(249, 226, 175), true);
	mk_esp("NPC ESP", "npc_esp", "Displays NPCs", Color3.fromRGB(244, 219, 214), true);
	
	if game.PlaceId == 13891478131 then
		mk_esp("Weapon ESP", "voi_weapon_esp", "Displays Weapons on ground", Color3.fromRGB(203, 166, 247), true)
		mk_esp("Rare Obelisk ESP", "obelisk_rare_esp", "Displays Rare Obelisks", Color3.fromRGB(255, 200, 100), false)
		mk_esp("Heal Brick ESP", "heal_brick_esp", "Displays Heal Bricks", Color3.fromRGB(150, 255, 150), true)
		mk_esp("Mantra Obelisk ESP", "mantra_obelisk_esp", "Displays Mantra Obelisks", Color3.fromRGB(203, 166, 247), false)
	end

	local job_esp_group = mk_esp("Job ESP", "job_esp", "Displays Jobs", Color3.fromRGB(242, 213, 207), true)
	job_esp_group:newToggle("hide_game_esp", "Hide Ingame Job ESP", true, "")

	chest_esp_group:newToggle("chest_esp_show_opened", "Show Opened Chests", false, "Shows opened chests on ESP.");
	local mob_esp_tab, mob_esp_options = mk_esp("Mob ESP", "mob_esp", "Displays Mobs", Color3.fromRGB(243, 139, 168), false);
	
	mob_esp_options:newDropdown('mob_filter', 'Blacklist Mobs', {
		"Gigameds",
		"Guards" 
	}, {
		"Gigameds",
		"Guards"
	}, true, 'Blacklist mobs on ESP');

	mob_esp_options:newDropdown('mob_health_format', 'Mob Health Format', {
		"hp%, hp/max",
		"hp/max",
		"hp%" 
	}, {
		"hp/max",
	}, false, 'Blacklist mobs on ESP');
	mob_esp_options:newToggle("mob_esp_healthbar", "Mob Healthbars", false, "Displays healthbars on mobs.");


	local ingredientArray = {"All Ingredients"}

	ingredient_esp_group:newDropdown('ingredient_filter', 'Filter Ingredients', ingredientArray, {
		'All Ingredients'
	}, true, 'Filter which ingredients to show in ESP', function() end, true)
	ingredient_esp_group:newButton("Refresh List", function()
	    local foundIngredients = {}
	    for i, v in pairs(workspace:WaitForChild("Ingredients"):GetChildren()) do
	        if not table.find(foundIngredients, v.Name) then
	            table.insert(foundIngredients, v.Name)
	        end
	    end
	
		table.clear(ingredientArray);
		table.insert(ingredientArray, "All Ingredients");
	    for _, ingredientName in pairs(foundIngredients) do
	        table.insert(ingredientArray, ingredientName)
	    end

		aztup_options.ingredient_filter:SetValues(ingredientArray);
	end)

end, {
    name = "Visuals"
}