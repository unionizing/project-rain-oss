


































return function(tab)
    local movement_tabbox = tab:newTabbox("Movement", false);
    local movement = movement_tabbox:newTab("Movement");
    local options = movement_tabbox:newTab("Options");

    
    movement:newToggleGroup({
        {"multiply_s",     "Walkspeed Multiplier", false, "Multiplys your walkspeed.", nil, true},
        {"infinite_jump",  "Infinite Jump", false, "Lets you hold space to jump in the air.", nil, true},
        {"vehicle_noclip", "Boat Noclip", false, "Requires boat speed. Very likely to get your boat stuck.", nil, true},
        {"vehicle_speed",  "Boat Speed", false, "Makes your boat move faster, Breaks if others emote on the boat. Dinghy is the most fast & consistent.", nil, true},
        {"noclip",         "Noclip", false, "Makes your character able to phase thru walls.", nil, true},
        {"tickrate",       "Timer", false, "Increases Physics Rate, This does not step your anims for others (that only appears on the client-side)", nil, true},
        {"speed",          "Speed", false, "Makes your character move faster.", nil, true},
        {"fly",            "Fly", false, "Makes your character able to fly", nil, true},
    });

    options:newToggleGroup({
        {"pull_to_ground", "Pull to Ground", false, "Makes your character fall to the ground", nil},
        {"ignore_ground",  "Ignore Ground", false, "Fly skips if you are on ground", nil},
        
    });

    
    
    
    
    
    

    options:newDropdown('multiplier_type', 'Walkspeed Multiplier Type', {
        "CFrame (blatant)",
        "CFrame (legit)",
        "Walkspeed",
    }, "Walkspeed", false, "What type walkspeed multiplier uses to boost speed.")    

    options:newSlider("min_speed_mult", "Minimum Speed Boost", 1, 1, 200, 1, true, "%");
    options:newSlider("max_speed_mult", "Maximum Speed Boost", 1, 1, 200, 1, true, "%");

    options:newSlider("min_tick_rate", "Minimum Timer Boost", 1, 1, 200, 1, true, "%");
    options:newSlider("max_tick_rate", "Maximum Timer Boost", 1, 1, 200, 1, true, "%");
    options:newSlider("jump_power", "Jump Power", 50, 1, 500, 1, true);

    options:newSlider("boat_speed", "Boat Speed", 1000, 1, 1750, 1, true);
    options:newSlider("walk_speed", "Walk Speed", 175, 1, 250, 1, true);
    options:newSlider("fly_speed", "Fly Speed", 175, 1, 350, 1, true); 
    
    options:newToggle("dont_noclip_while_knocked", "Disable Noclip When Knocked", false, "Disables noclip if your knocked.");

    local removal_groupbox = tab:newGroupBox("Removals", true);
    removal_groupbox:newToggleGroup({
        {"knocked_ownership",     "No Knocked Restrictions", false, "Allows for fly & speed while knocked. Previously titled 'Knocked Ownership' & 'Move While Knocked' in other scripts.", nil, true},
        {"no_depths_trial_voices","No Depths Trial Voices", false, "Removes all voices from the depths trial."},
        {"no_respawn_time",       "No Respawn Timer & CD", false, "Overrides the ESC + R in the roblox menu."},
        {"no_castle_light_gate",  "No Castle Light Gate", false, "Removes the Castle Light gate."},
        {"mantra_revealer",       "No Mystery Mantras", false, "Reveals 'mystery mantras' in the talent picker."},
        {"roll2_revealer",        "No Mystery Roll 2s", false, "Reveals 'roll 2' cards in the talent picker."},
        {"harrow_remover",        "No Harrowed Effect", false, "Reveals your HP when hit with the harrowed effect."},
        {"no_mob_encounters",     "No Mob Encounters", false, "Removes certain mob encounters from L2 along with random kaido encounters."},
        {"no_status_effects",     "No Status Effects", false, "Removes all effects from the game, WILL break the game.", Risky = true},
        {"no_enforcer_pull",      "No Enforcer Pull", false, "Removes the Pull Effect from Enforcers."},
        {"no_yun_shul_gate",      "No Yun Shul Gate", false, "Removes the Yun Shul gate."},
        {"no_speed_debuff",       "No Speed Debuff", false, "Removes speed debuffs."},
        {"no_roll_fatigue",       "No Roll Fatigue", false, "Removes fatigue when roll cancelling allowing you to roll again faster."},
        {"no_kill_bricks",        "No Kill Bricks", false, "Removes Killbricks & the ragdoll bricks @ L2."},
        {"no_fall",               "No Fall Damage", false, "Prevents fall damage."},
        {"no_echo_screen",        "No Echo Screen", false, "Removes the wait from the Echo Screen, Makes manually farming echoes faster."},
        {"no_flame_blind",        "No Flame Blind", false, "Removes the flame blind effect from the game."},
        {"no_rosen_fire",         "No Rosen Fire", false, "BLATANT, Removes Rosens critical fire."},
        {"no_sanity_vfx",         "No Sanity VFX", false, "Removes sanity FX from the game."},
        {"no_hive_gate",          "No Hive Gate", false, "Removes the Hive gate."},
        {"anti_afk",              "No AFK Kick", false, "Prevents you from being kicked do to afk detections."},
        {"no_one_bit",            "No One Bit", false, "Removes the Echo Modifier 'One Bit'."},
        {"no_shadows",            "No Shadows", false, "Removes all shadows from the game, Increases performance."},
        {"no_clouds",             "No Clouds", false, "Removes all clouds from the game, Increases performance."},
        {"no_blind",              "No Blind", false, "Removes the blindness effect from the game."},
        {"no_fire",               "No Fire", false, "Sets you out of fire when on fire."},
        {"no_wind",               "No Wind", false, "Automatically rotates to the wind direction & removes pushers."},
        {"no_blur",               "No Blur", false, "Removes blur effects from the game."},
        {"no_sea",                "No Sea", false, "Removes the sea."},
        {"no_fog",                "No Fog", false, "Removes fog from the game."},
    });

    local safety_groupbox = tab:newGroupBox("Safety", true);
    
    safety_groupbox:newToggleGroup({
        {"chime_safety",  "Chime Safe Mode", true, "Prevents movement features from being used in chime.", NoKeybind = true},
        {"girl_detector", "Gender Detector", false, "Notifies you when a player's Roblox bio directly states a gender you've selected below.", NoKeybind = true},
        {"combosser_detector", "Combosser Detector", false, "Notifies you when a player's avatar contains an item with 'vkei', 'moe', 'scary' in its name.", NoKeybind = true},
        {"mod_detector",  "Mod Detector", false, "Detects Moderators in your game.", NoKeybind = true},
    });

    local gender_detector_dependency_box = safety_groupbox:newDependencyBox("girl_detector");
    gender_detector_dependency_box:newDropdown("gender_detector_genders", "Genders to Detect", {
        "Girl",
        "Boy",
        "Non-binary",
    }, {
        "Girl",
    }, true, "Only triggers when a player's bio directly states one of these genders themselves - never inferred from pronouns.");

    local other_groupbox = tab:newGroupBox("Other", false);

    
    
    
    

    other_groupbox:newButton("Serverhop", function()
        local slot = local_player.instance:GetAttribute("DataSlot");
        if aztup_options.hop_type.Value == "Custom" then
            local server_id = aztup_options.custom_server_id.Value;
            server_utility:custom(slot, server_id);
        else
            server_utility:hop(slot, aztup_options.hop_type.Value == "Small", true)
        end;
    end, true, "Joins you into another server."):AddButton({
        Text = "Rejoin",
        Func = function()
            local slot = local_player.instance:GetAttribute("DataSlot");
            server_utility:rejoin(slot)
        end,
        DoubleClick = true,
        Tooltip = "Joins you back into your current server.",
    });
    other_groupbox:newDropdown("hop_type", "Serverhop Type", {
        "Custom",
        "Small",
        "Big",
    }, "Big", false, "Server type to hop into.");
    other_groupbox:newDivider();

    local custom_server_hop_dependency_box, raw = other_groupbox:newDependencyBox("hop_type", "Custom");
    custom_server_hop_dependency_box:newTextbox("custom_server_id", "Custom Server ID", false, "", false, "The server ID of the server you want to hop to.");
    custom_server_hop_dependency_box:newButton("Copy Custom Server Hop ID", function()
        setclipboard(game.JobId);
    end, false, "Copys your current server's ID to your clipboard.");

    raw:SetupDependencies({
        {aztup_options.hop_type, "Custom"}
    })

    other_groupbox:newToggleGroup({
        {"mob_ai_breaker", "Humanoid Pathfind Breaker", false, "Breaks the pathfinding on humanoids. !! BLATANT TO PLAYERS NEAR YOU", nil, true, Risky = true},
        {"ap_breaker",     "AP Breaker", false, "Breaks certain autoparrys.", nil, true},
    });

    
    
    
    

    local ap_breaker_dependency_box = other_groupbox:newDependencyBox("ap_breaker");
    local types = {
        "Aggressive 3 (Blatant)",
        "Aggressive 2 (Blatant)",
        "Aggressive", 
        "Passive",
    }

    if LRM_ScriptName == "testing" or not LPH_OBFUSCATED then
        table.insert(types, "Tester Aggressive 1 (Blatant)");
    end;

    ap_breaker_dependency_box:newDropdown("ap_breaker_type", "AP Breaker Type", types, "Passive", false, "Aggressive will cause you to shake - Use with caution.");
    
    ap_breaker_dependency_box:newDropdown("aggressive_3_break_on", "Break On", {
        "Criticals",
        "Untagged",
        "Spells",
        "Bells",
        "M1s",
    }, {
        "Spells",
        "M1s",
    }, true, "Types of anims that the breaker will affect, Some anims are currently untagged.")

    if identifyexecutor() == "Volt" and env.raknet then
        other_groupbox:newRiskyToggleWithKeybind("fakelag", "Fakelag", false, "!! MUST HAVE RAKNET ON IN EXEC !! Desyncs your position updates to other clients.", nil, true);

        local new_dependency_box = other_groupbox:newDependencyBox("fakelag");
        new_dependency_box:newSlider("fakelag_amount", "Fakelag Amount", 2, 2, 10, 0, true, " packets", function() end, "66ms per packet.");
    end

    other_groupbox:newToggleWithKeybind("anchor", "Anchor", false, "Freezes your character.", nil, true);
    
    local ap_breaker_dependency_box = other_groupbox:newDependencyBox("ap_breaker");
    ap_breaker_dependency_box:newSlider("ap_breaker_intensity", "Breaker Intensity", 4, 1, 500, 1, true, "a/s", function() end, "Past 10 may cause your anims to break for other players.");
    ap_breaker_dependency_box:newToggleWithKeybind("varying_anims", "Varying Animations", false, "Use random animations from the AP data to AP break.", nil, true);

    local mob_ai_breaker_dependency_box = other_groupbox:newDependencyBox("mob_ai_breaker");
    mob_ai_breaker_dependency_box:newDropdown("breaker_type", "Breaker Type", {
        "Aggressive", 
        "Circular",
        "OPassive",
        "Passive"
    }, "Passive", false, "Breaker type. Aggressive is better but may cause them to fling.");


    local qol_groupbox = tab:newGroupBox("QOL", false);
    qol_groupbox:newToggleGroup({
        {"experimental_bug_fixes",  "Experimental Game Bug Fixes", false, "Attempts to fix DW bugs, May cause issues. Currently fixes the health bar issue.", NoKeybind = true},
        {"give_animation_gamepass", "Give Animation Gamepass", false, "Lets you use any emote of your choice.", NoKeybind = true},
        {"steal_dropped_items", "Steal Dropped Items", false, "Lets you grab dropped items out of range."},
    });
    qol_groupbox:newToggle("build_stealer",     "Build Stealer", false, "Allows you to steal builds from other players. Select a target below and press 'P' to steal their build", nil, true)
    local steal_dropped_itemsbox = qol_groupbox:newDependencyBox("steal_dropped_items")
    steal_dropped_itemsbox:newSlider("drop_range", "Dropped Item Range", 30, 1, 35, 0, true, " studs", function() end, "How far items will be picked up from.");

    local build_stealerbox = qol_groupbox:newDependencyBox("build_stealer")
    build_stealerbox.Box:AddDropdown("build_stealer_target", {
        Text = "Build Stealer Target",
        Values = {
            ""
        },
        Default = "",
        AllowNull = true
    })

    build_stealerbox:newButton("Refresh Player List", function()
	    local PlayerList = services.Players:GetPlayers();

	    for i = 1, #PlayerList do
	    	PlayerList[i] = PlayerList[i].Name;
	    end;

	    table.sort(PlayerList, function(str1, str2) return str1 < str2 end);
        aztup_options.build_stealer_target:SetValues(PlayerList)
    end, false, "Refreshes the player list for the build stealer target dropdown.");

    
    qol_groupbox:newToggle("hair_id_stealer",     "Hair ID Stealer", false, "Allows you to steal Hair IDs from other players.", nil, true)
    local hair_id_stealerbox = qol_groupbox:newDependencyBox("hair_id_stealer")
    hair_id_stealerbox.Box:AddDropdown("hair_id_stealer_target", {
        Text = "Hair ID Stealer Target",
        Values = {
            ""
        },
        Default = "",
        AllowNull = true
    })

    hair_id_stealerbox:newButton("Refresh Player List", function()
	    local PlayerList = services.Players:GetPlayers();

	    for i = 1, #PlayerList do
	    	PlayerList[i] = PlayerList[i].Name;
	    end;

	    table.sort(PlayerList, function(str1, str2) return str1 < str2 end);
        aztup_options.hair_id_stealer_target:SetValues(PlayerList)
    end, false, "Refreshes the player list for the hair id stealer target dropdown.");
    qol_groupbox:newToggle("talent_highlighter",     "Build Highlighter", false, "Highlights talents inside of your builder link, Orange means preshrine, Purple means post shrine");    
    local talent_highlighterbox = qol_groupbox:newDependencyBox("talent_highlighter");
    talent_highlighterbox:newTextbox("talent_highlighter_url", "Talent Highlighter URL", false, ""); 
     
    
    local misc_qol_toggles = {
        {"extend_prompts", "Extend Prompts", false, "Extends your interacting range by 2x."},
        {"optimize_game", "Optimize Game", false, "Optimizes your game, Do not use in clips as this will make certain game functionality not look right. (e.g: boats & others)", Risky = true},
        {"aggressive_optimize_game", "Aggressive Game Optimization", false, "THIS IS NOT MEANT TO BE USED BY PEOPLE WITH PHOTOSENSITIVE EPILEPSY AS IT CAN CAUSE FLICKERING ON CERTAIN EXECUTORS. Aggressively optimizes the game, This may make some parts of the game jarring. (e.g: weather & the moonseye)", Risky = true},
    };

    if getfflag and setfflag then
        table.insert(misc_qol_toggles, {"apply_fflags", "Apply FFlags", false, "Executor reliant - May be detected on certain executors, FFlags go to workspace/fflags.json, Allowlist is skipped & not instant.", NoKeybind = true});
    end;

    qol_groupbox:newToggleGroup(misc_qol_toggles);

    qol_groupbox:newToggle(           "parry_sounds", "Parry Sounds", false, "Lets you customize how your parrys sound.");

    local parry_sound_box = qol_groupbox:newDependencyBox("parry_sounds");
    parry_sound_box:newDropdown("parry_sound_type", "Sound", { 
        "Ultrakill Parry",
    }, "Ultrakill Parry", true, "Sound to use, mp3 only stored in workspace @ Project Rain/Assets/Parry Sounds.");
    local game_qol_toggles = {
        {"minesweeper", "Minesweeper", false, "Play a game of minesweeper in a draggable widget. Left click to reveal, right click to flag.", nil, true},
        {"bring_mobs",  "Bring Mobs", false, "Brings nearby mobs to your location abusing network ownership.", nil, true},
        {"void_mobs",   "Void Mobs", false, "Abuses Network Ownership to instant kill mobs by sending them to the void", nil, true},
        {"tetris",      "Tetris", false, "Play a game of tetris in a draggable widget. Arrow keys to move/rotate/drop.", nil, true},
        {"jesus",       "Jesus", false, "Lets you walk on water.", nil, false},
        {"snake_game",  "Snake", false, "Play a game of snake in a draggable widget. Controlled with the arrow keys. Press F5 for autoplay.", nil, true},
        {"brayden",     "Brayden", false, "Tomodachi style minigame. Feed, talk to and gift Brayden, and click him when he has a \"!\" to solve his problems. Progress is saved.", nil, true},
    };

    if is_depths then
        table.insert(game_qol_toggles, {"fake_void", "Fake Void", false, "Allows you to jump in the void and teleport to the roof.", nil, false});
    end;

    qol_groupbox:newToggleGroup(game_qol_toggles);
    qol_groupbox:newDropdown("snake_difficulty", "Snake Difficulty", {
        "Easy",
        "Normal",
        "Hard",
        "Extreme",
        "Lord Regent",
    }, "Normal", false, "How quickly Snake speeds up as your score rises.");

    qol_groupbox:newSlider("dmg_amount", "Damage Amount", 100, 20, 500, 1, true, "hp");
    parry_sound_box:newSlider("parry_sound_volume", "Volume", 1, 0.1, 5, 1);

    qol_groupbox:newButton("Respawn", require("@src/features/buttons/respawn"), true, "Respawns your character."):AddButton({
        Text = "Suicide",
        Func = require("@src/features/buttons/suicide"),
        DoubleClick = true,
        Tooltip = "Instantly kills your character.",
    });
    qol_groupbox:newButton("Damage Self", require("@src/features/buttons/damage_self"), true, "Respawns your character."):AddButton({
        Text = "Knock Self",
        Func = require("@src/features/buttons/knock_self"),
        DoubleClick = true,
        Tooltip = "Instantly knocks yourw character.",
    });
    wipe_button = qol_groupbox:newButton("Wipe", function()  
        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:obliteration(slot)
    end, true, "Wipes your character.")

    if not LPH_OBFUSCATED then
        wipe_button:AddButton({
            Text = "Refresh",
            Func = require("@src/features/buttons/refresh"),
            DoubleClick = true,
            Risky = true,
            Tooltip = "Respawns you at your same spot, Not usable in combat, Breaks menus.",
        });
    end
    qol_groupbox:newKeybind("offset_floor", "TP To Floor", "", require("@src/features/buttons/tp_to_floor"), "Toggle", false, true);
    qol_groupbox:newKeybind("tp_to_objectives", "TP To Objectives", "", require("@src/features/buttons/tp_to_objectives"), "Toggle", false, true); 
    
    if is_depths then
        qol_groupbox:newKeybind("offset_up", "TP To Roof", "", require("@src/features/buttons/tp_to_roof"), "Toggle", false, true);
        qol_groupbox:newKeybind("offset_down", "TP To Void", "", require("@src/features/buttons/tp_to_void"), "Toggle", false, true);
    end;

    local function refresh_sounds() 
        local sound_list = {}

        for _, file in listfiles("Project Rain/Assets/Parry Sounds") do
            table.insert(sound_list, tostring(file:gsub("/", "\\"):gsub(".mp3", ""):gsub("Project Rain\\Assets\\Parry Sounds\\", "")));
        end;

		aztup_options.parry_sound_type:SetValues(sound_list)
    end;

    parry_sound_box:newButton("Refresh List", refresh_sounds);
    pcall(refresh_sounds);

    
    local talents_groupbox = tab:newGroupBox("Talents", false);
    talents_groupbox:newToggleGroup({
        {"kongas_spoof",           "Give Konga Clutch Ring", false, "Spoofs Konga's Clutch Ring", NoKeybind = true},
        {"freestylers_band_spoof", "Give Freestyler's Band", false, "Spoofs Freestyler's Band", NoKeybind = true},
        {"endurance_runner_spoof", "Give Endurance Runner", false, "Spoofs Endurance Runner", NoKeybind = true},
        {"lightweight_spoof",      "Give Lightweight", false, "Spoofs Lightweight talent", NoKeybind = true},
    });

    local spoofing_groupbox = tab:newGroupBox("Spoofing", true);

    spoofing_groupbox:newToggleGroup({
        {"max_momentum_spoof", "Force Max Momentum", false, "Spoofs momentum to max", NoKeybind = true},
        {"agility_spoofer",    "Agility Spoofer", false, "Spoof your agility to climb higher and slider further", NoKeybind = true},
        {"fall_multiplier",    "Fall Multiplier", false, "Lets you multiply your fall damage.", NoKeybind = true},
    });

    local agility_spoofing_groupbox = spoofing_groupbox:newDependencyBox("agility_spoofer");
    agility_spoofing_groupbox:newToggle("agility_spoof_health", "Change Scaling", false, "Change the agility from scaling with your health.");
    agility_spoofing_groupbox:newSlider("agility_spoof_amount", "Agility Value", 5, 1, 300, 0);
    
    local disallow_scaling_groupbox, raw_ds_groupbox = spoofing_groupbox:newDependencyBox();
    disallow_scaling_groupbox:newSlider("disallow_scaling_multiplier", "Scaling Multiplier", 2, 1, 8, 2, false, "x", nil, "Multiplier for the agility scaling when health is low.");
    raw_ds_groupbox:SetupDependencies({
        {aztup_toggles.agility_spoofer, true},
        {aztup_toggles.agility_spoof_health, true}
    })

    local fall_dmg_groupbox = spoofing_groupbox:newDependencyBox("fall_multiplier");
    fall_dmg_groupbox:newSlider("fall_multiplier_slider", "Fall Value", 100, 1, 300, 0);
    fall_dmg_groupbox:newToggleGroup({
        {"only_minimum_fall_dmg", "Only Minimum Fall Damage", false, "Forces your fall damage to be the minimum amount to make a sound.", NoKeybind = true},
        {"only_near_players",     "Only Fall Near Players", false, "Only triggers fall damage near players.", NoKeybind = true},
    });

    local teleport_tabbox = tab:newTabbox("Teleports", true);
    local teleport_groupbox = teleport_tabbox:newTab("Main");
    local guildbase = teleport_tabbox:newTab("Guildbase");  

    guildbase:newDropdown("guildbase_teleport_type", "Base", {}, "", false, "Teleports you to your guildbase, Must be near the exit.");
    guildbase:newButton("TP To Guildbase", require("@src/features/buttons/tp_to_guildbase"));
    guildbase:newButton("Refresh List", function() 
        local bases = {};

        for _, guild_door in workspace:GetChildren() do
            if guild_door.Name:match("GuildDoor_") then
                table.insert(bases, guild_door:GetAttribute("GuildName") or guild_door.Name);
            end
        end

        aztup_options.guildbase_teleport_type:SetValues(bases);
    end)
    local in_etrean = game.PlaceId == 6032399813;
    local in_eastern = game.PlaceId == 6473861193;

    local teleport_toggles = {
        {"kamui_teleport", "Kamui Teleport", false, "Teleport to where you click in the ingame map (M by default) in kamui.", NoKeybind = true},
    };

    if game.PlaceId == 86761619761103 then 
        table.insert(teleport_toggles, {"voi_teleport", "VOI Teleport", false, "Teleport to where you click in the ingame map (M by default), Must be near a boundary, May fail.", NoKeybind = true});
    end

    teleport_groupbox:newToggleGroup(teleport_toggles);

    if in_etrean then
        teleport_groupbox:newButton("Teleport to Eastern", require("@src/features/buttons/teleports/eastern"), true, "Teleports you to the 'Eastern Luminant' gate."); 
        teleport_groupbox:newButton("Teleport to Trial", require("@src/features/buttons/teleports/trial"), true, "Teleports you to Trial Of One");
    elseif in_eastern then
        teleport_groupbox:newButton("Teleport to Etrean", require("@src/features/buttons/teleports/etrean"), true, "Teleports you to the 'Etrean Luminant' gate.");
    end;

    if in_eastern or in_etrean then
        teleport_groupbox:newButton("Teleport to Voidheart", function()
            require("@src/features/buttons/generic_teleport").new(CFrame.new(-20000, 19713.9609, -20000), function()
                local vh = workspace:FindFirstChild("Voidheart");
                if not vh then return end
            
                return vh:FindFirstChild("VoidheartVoidWarp")
            end, function()
                if not local_player.root_part then return end
                return local_player.root_part.CFrame.Y > 19990            
end):run();
        end, true, "Teleports you to the 'Voidheart'");
    end;

    if game.PlaceId == 86761619761103 or in_etrean or in_eastern then
        teleport_groupbox:newButton("Teleport to Depths", require("@src/features/buttons/teleports/depths"), true, "Teleports you to the 'Depths'");
    end;
end, {
    name = "Main"
}