
return function(tab)

    local pvp = tab:newGroupBox("Assistance", true);
    
        pvp:newToggle("easy_roll_cancel", "Easy Roll Cancel", false, "Allows you to press M1 mid dash to cancel it.", nil);
    pvp:newToggleWithKeybind("auto_dustlunge", "Auto Assassination", false, "Allows you to hold M1 to attack, Doesn't follow the No Aerial Logic.", nil);
    pvp:newKeybind("auto_dustlunge_bind", "Auto Assassination Bind (hold)", 'V', function(on)
        aztup.features.auto_dustlunge.held = on;
    end, "Hold", true, false); 

    local auto_dustlunge_dependency_box = pvp:newDependencyBox("auto_dustlunge");
    auto_dustlunge_dependency_box:newToggle("auto_dustlunge_debug", "Auto Assassination Debug", false, "Displays the dustlunge hitbox.", nil);

    pvp:newToggle("m1_hold", "M1 Hold", false, "Allows you to hold M1 to attack, Doesn't follow the No Aerial Logic.", nil);

    local no_stun = tab:newGroupBox("No Stun", true);
    no_stun:newToggle(           "fast_swing",           "Remove Weapon Endlag", false, "Removes endlag & stuff from swinging (same effect can be done with no stun)", nil);
    no_stun:newRiskyToggleWithKeybind("no_stun",              "No Stun", false, "Removes all stun from the game."); 

    local attach_to_back = tab:newGroupBox("Attach to Back", true); 
    attach_to_back:newToggleWithKeybind("attach_to_back", "Attach to Back", false, "Allows you to attach to the back of your target, M1/M2 to select a target.", nil);
    attach_to_back:newSlider("atb_x_offset", "X Offset", 0, -150, 150, 1, true, "s");
    attach_to_back:newSlider("atb_y_offset", "Y Offset", 0, -150, 150, 1, true, "s");
    attach_to_back:newSlider("atb_z_offset", "Z Offset", 5, -150, 150, 1, true, "s");
    attach_to_back:newToggle("atb_lock_rotation",   "Ignore Rotation", false, "Forces you to be looking at the mob.", nil);
    attach_to_back:newToggle("atb_prevent_voiding", "Prevent Voiding Self", false, "Prevents attach to back from voiding you.", nil);
    attach_to_back:newToggle("atb_rotate",   "Rotate Towards", false, "Forces you to be looking at the mob.", nil);
    attach_to_back:newSlider("atb_speed",    "Control Speed", 16.5, 1, 100, 1, true, "st/s");

    attach_to_back:newDropdown('allowed_atb_targets', 'Allowed Targets', {
        "Guildmates",
        "Players",
        "Mobs" 
    },{
        "Guildmates",
        "Players",
        "Mobs"
    }, true, "Allowed targets to attach to back of.");

    local stun_effects = {
        "LightningStun",
        "PreventAction",
        "OffhandAttack",
        "UsingCritical",
        "MobileAction",
        "MediumAttack",
        "CarryObject",
        "PreventRoll",
        "LightAttack",
        "HeavyAttack",
        "InDialogue",
        "UsingSpell",
        "NoParkour",
        "NoJumpAlt",
        "Blocking",
        "NoAttack",
        "Carried",
        "Falling",
        "Chilled",
        "Pinned",
        "Action",
        "Dodged",
        "NoJump",
        "NoRoll",
        "NoMove",
        "Stun",
    };

    no_stun:newDropdown('no_stun_items', 'Removed Effects', stun_effects, stun_effects, true, 'Effects that No Stun will remove');


    local m1_hold_dependency_box = pvp:newDependencyBox("m1_hold");
    m1_hold_dependency_box:newToggle("no_aerials", "Spoof No Air", false, "Never Aerials when holding M1.", nil);

    
    
    
    
    
    
    

    local autoparry_tabbox = tab:newTabbox("Auto Parry", false);
    local ap_main = autoparry_tabbox:newTab("Main");

    ap_main:newToggleWithKeybind("auto_parry", "Auto Parry", false, "Automatically parry/defend incoming attacks.", function(val) 
        task.delay(1, function()
            if aztup.flags.aggressive_validation and val then
                Logger:long_notify_sound("It is not recommended to keep aggressive anti ap breaker on unless you are being broken, It will heavily affect timings.")
            end;

            if val and not next(aztup_options.allowed_targets.Value) then
                Logger:long_notify_sound("Please select at least 1 allowed target for Auto Parry to work.");
            end
    
            repeat task.wait() until local_player.instance:GetAttribute("EnablePingCompensation") ~= nil;
            if not local_player.instance:GetAttribute("EnablePingCompensation") then
                Logger:long_notify_sound("For the best experience, please enable Ping Compensation in the deepwoken settings.");
            end
        end)
    end, true);

    local auto_parry_dependency_box = ap_main:newDependencyBox("auto_parry");
    auto_parry_dependency_box:newDivider();
    auto_parry_dependency_box:newSlider("dont_process_players_over_studs", "Dont Process Players Over", 500, 1, 10000, 1, true, "s");
    auto_parry_dependency_box:newSlider("dont_process_mobs_over_studs", "Dont Process Mobs Over", 2000, 1, 10000, 1, true, "s");
    auto_parry_dependency_box:newSlider("task_concurrency", "Task Concurrency", 20, 15, 750, 0, true, " actions");
    auto_parry_dependency_box:newToggleWithKeybind("basic_validation",       "Anti AP Breaker", true, "", nil, true);
    local anti_ap_breaker, raw_anti_ap_breaker = ap_main:newDependencyBox();

    raw_anti_ap_breaker:SetupDependencies({
        {aztup_toggles.basic_validation, true},
        {aztup_toggles.auto_parry, true}
    })

    anti_ap_breaker:newToggleWithKeybind("aggressive_validation",       "More Aggressive Checks", false, "", nil, true);
    anti_ap_breaker:newToggle("anti_ap_breaker_debug",       "Validation Notifications", false, "", nil, false);
    anti_ap_breaker:newToggleWithKeybind("reveal_animations",       "Reveal Animations", true, "", nil, true);

    anti_ap_breaker:newDropdown('validation_filters', 'Validation Filters', {
        
        
        "WT <= X (WT = WeightTarget)",
        "S >= X (S = Speed)",
        "Priority Hiding",
        "Core Priority",
        "Idle Priority",
        "Length <= Xms",
        "Fadetime",
    },{
        "WT <= X (WT = WeightTarget)",
        "Core Priority",
        "Idle Priority",
        "Priority Hiding",
        "S >= X (S = Speed)",
        "Fadetime"
    }, true, 'Filters for AP breaker.')

    anti_ap_breaker:newDropdown('validation_log_filters', 'Validation Log Filters', {
        
        
        "WT <= X (WT = WeightTarget)",
        "S >= X (S = Speed)",
        "Priority Hiding",
        "Core Priority",
        "Idle Priority",
        "Length <= Xms",
        "Fadetime",
    },{
        "WT <= X (WT = WeightTarget)",
        "Core Priority",
        "Idle Priority",
        "Priority Hiding",
        "S >= X (S = Speed)"
    }, true, 'Logging Filters for AP breaker.')

    auto_parry_dependency_box:newToggleWithKeybind("auto_parry_debug",      "Debug Notifications", false, "Gives debug notifications.", function(val)
        if not val then return end
        if not aztup.silent_mode then return end

        messagebox("You have 'Silent Mode' enabled, You cannot use Debug Notifications with 'Silent Mode'.", "Project Rain", 0) 
        aztup_toggles.auto_parry_debug:SetValue(false);
    end, false);    
    auto_parry_dependency_box:newToggleWithKeybind("log_speed_changes",     "Debug Speed Changes", false, "Gives AP debug notifs on speed changes.", nil, false);    

    auto_parry_dependency_box:newToggleWithKeybind("ap_randomization", "Humanization", false, "Adds extra randomization to actions.", function(val) end, false);
    
    auto_parry_dependency_box:newToggleWithKeybind("auto_feint", "Auto Feint", false, "Automatically feint attacks when Auto Parry wants to parry.");
    auto_parry_dependency_box:newDivider();

    auto_parry_dependency_box:newDropdown('fallbacks', 'Fallbacks', {
        "Curse of the Unbidden",
        "Prediction",
        "Block",
        "Vent",
    },{
        "Curse of the Unbidden"
    }, true, 'Fallbacks for Auto Parry')

    auto_parry_dependency_box:newDropdown('filters', 'Filters', {
        "Dont Parry If Enemy Hit In Criticals",
        "Dont Parry If Mob Block Broken",
        "Dont Parry In Chime Countdown",
        "Dont Parry If Not Mob Target",
        "Dont Parry If Not In Combat",
        "Dont Parry If Holding Block",
        "Dont Parry If In Payback",
        "Dont Parry If Off Roblox",
        "Dont Parry If Off Screen",
        "Dont Parry If Guildmate",
        
    	"Dont Parry In AP Frames",
        "Dont Parry If Knocked",
        "Dont Parry If Typing",
        "Dont Parry If Ally",
        "Dont Roll",
    },{
        ""
    }, true, 'Filters for Auto Parry')

    auto_parry_dependency_box:newDropdown('allowed_targets', 'Allowed Targets', {
        "Unknown",
    	"PVE",
        "PVP",
        "All"
    },{
        "Unknown",
    	"PVE",
        "PVP",
        "All"
    }, true, 'Allowed targets that Auto Parry will Parry')

    local feint_chance_dependency_box, raw_feint_chance = ap_main:newDependencyBox();
    
    
    

    
    
    
    
    
    
    
    
    
    feint_chance_dependency_box:newDropdown('blocked_auto_feint_moves', 'Dont Against Types', {
        "Critical",
        "Untagged",
        "Spell",
        "M1",
    },{}, true, "Blocked Auto Feint Types, Some moves are currently untagged or skip.");

    feint_chance_dependency_box:newDropdown('auto_feint_own_tags', 'Auto Feint Our Move Types', {
        "M1",
        "Spell",
    },{"M1", "Spell"}, true, "Only feint our own attack if it's one of these move types.");
    feint_chance_dependency_box:newDivider();

    feint_chance_dependency_box:newSlider("feint_chance", "Feint Chance", 100, 0, 100, 1, true, "%");

    raw_feint_chance:SetupDependencies({
        {aztup_toggles.auto_feint, true},
        {aztup_toggles.auto_parry, true}
    })

    local speed_max, raw_speed_max = ap_main:newDependencyBox("validation_filters", "S >= X (S = Speed)", true);
    speed_max:newSlider("anti_ap_breaker_max_speed", "Max Speed", 5, 1, 100, 1, true, "x");
    raw_speed_max:SetupDependencies({{ 
        aztup_options.validation_filters, "S >= X (S = Speed)"
    }, { 
        aztup_toggles.basic_validation, true
    }}); 

    local weight_target_selector, raw_weight_target = ap_main:newDependencyBox("validation_filters", "WT <= X (WT = WeightTarget)", true);
    weight_target_selector:newSlider("anti_ap_breaker_minimum_wt", "Minimum WT", 10, 10, 100, 1, true, "x Weight");
    raw_weight_target:SetupDependencies({{ 
        aztup_options.validation_filters, "WT <= X (WT = WeightTarget)"
    }, { 
        aztup_toggles.basic_validation, true
    }});

    local time_x_ms, raw_time_x_ms = ap_main:newDependencyBox("validation_filters", "Length <= Xms", true);
    time_x_ms:newSlider("anti_ap_breaker_length_ms", "Minimum Length", 50, 1, 500, 1, true, "ms");
    raw_time_x_ms:SetupDependencies({{ 
        aztup_options.validation_filters, "Length <= Xms"
    }, { 
        aztup_toggles.basic_validation, true
    }});

    local randomization_dependency_box = ap_main:newDependencyBox("ap_randomization");

    randomization_dependency_box:newSlider("parry_to_dodge_chance_undefined",    "Force Dodge Chance (Untagged)", 0, 0, 100, 1, true, "%");
    randomization_dependency_box:newSlider("parry_to_dodge_chance_spells",      "Force Dodge Chance (Spells)", 0, 0, 100, 1, true, "%");
    randomization_dependency_box:newSlider("parry_to_dodge_chance_critical",   "Force Dodge Chance (Crits)", 0, 0, 100, 1, true, "%");
    randomization_dependency_box:newSlider("parry_to_dodge_chance_m1",          "Force Dodge Chance (M1)", 0, 0, 100, 1, true, "%");
    randomization_dependency_box:newSlider("parry_to_fallback_chance",   "Parry -> Fallback Chance", 0, 0, 100, 1, true, "%");

    randomization_dependency_box:newSlider("bluff_feint_chance", "Bluff Feint Chance", 0, 0, 100, 1, true, "%");
    randomization_dependency_box:newToggle("only_convert_dodge_if_possible", "Only Convert Dodge If Possible", false, "Only converts parries to dodges if the dodge is possible.", nil);

    local function create_settings_page(tab, id)
        tab:newToggle(id.."blatant_roll_with_anims","Blatant Roll w/ Anims", false, "Plays a anim while using blatant roll.", nil);
        tab:newToggle(id.."roll_if_unequipped",     "Roll If Unequipped", false, "Rolls if you have no weapon equipped.", nil);
        
        tab:newToggle(id.."blatant_crouch",         "Blatant Crouch", false, "Fires the crouch remote & skips any animation.", nil);
        tab:newToggle(id.."blatant_roll",           "Blatant Roll", false, "Fires the remote instead of going thru the client.", nil);

        tab:newToggle(id.."roll_cancel",            "Roll Cancel", false, "Automatically cancels your rolls by M2ing.", nil);
        tab:newToggle(id.."auto_equip",             "Auto Equip", false, "Automatically will equip your weapon.", nil);

        tab:newSlider(id.."max_roll_cancel_delay", "Max Cancel Delay", 150, 1, 200, 1, true, "ms");
        tab:newSlider(id.."min_roll_cancel_delay", "Min Cancel Delay", 70, 1, 200, 1, true, "ms");
        tab:newSlider(id.."roll_cancel_chance", "Cancel Chance", 90, 1, 100, 1, true, "%");
        tab:newSlider(id.."parry_chance", "Parry Chance", 100, 1, 100, 1, true, "%");

        
        
        
        
        
        
        
        
        
    end

    create_settings_page(autoparry_tabbox:newTab("PVE"), "pve_")
    create_settings_page(autoparry_tabbox:newTab("PVP"), "pvp_")

    local anim_speed_changer = tab:newGroupBox("Anim Speed Changer", true); 
    anim_speed_changer:newToggleWithKeybind("anim_speed_changer", "Anim Speed Changer", false, "Changes the speed of your animations, Only affects auto parry timings", nil, true);
    anim_speed_changer:newToggleWithKeybind("switch_speeds", "Switch Speed", false, "Instead of randomly generating a value between your min/max, Switch between them.", nil, true);

    local type_dependency_box = anim_speed_changer:newDependencyBox("anim_speed_changer");
    type_dependency_box:newDropdown("anim_speed_changer_types", "Affected Anim Types", {
        "Criticals",
        "Untagged",
        "Spells",
        "Bells",
        "M1s",
    },{}, true, "Types of anims that the speed changer will affect, Some anims are currently untagged.");
    
    local function make_speed_slider(flag, display)
        local slider_dependency_box, raw_slider = anim_speed_changer:newDependencyBox();

        slider_dependency_box:newMinMaxSlider(flag, display, { Min = 0.9, Max = 1.10 }, 0.1, 2.10, 2, true, "x");

        raw_slider:SetupDependencies({{ 
            aztup_toggles.anim_speed_changer, true
        }, { 
            aztup_options.anim_speed_changer_types, display:gsub(" Speed", "")
        }});
    end
    make_speed_slider("anim_critical_speed", "Criticals");
    make_speed_slider("anim_untagged_speed", "Untagged");
    make_speed_slider("anim_spell_speed", "Spells");
    make_speed_slider("anim_bell_speed", "Bells");
    make_speed_slider("anim_m1_speed", "M1s");

    

    







local silent_aim = tab:newGroupBox("Silent Aim", true); 
    silent_aim:newToggle("silent_aim", "Silent Aim", false, "Automatically aims for you.", nil);
    silent_aim:newToggle("force_chime_opponent", "Force Chime (solo) Opponent", false, "Forces silent aim to be on the chime opponent with no FOV check.", nil);

    silent_aim:newToggle("show_fov", "Show FOV", false, "Displays your silent aim FOV.", nil);
    silent_aim:newToggle("fov_filled", "Fill FOV", false, "Displays your silent aim FOV.", nil);
    silent_aim:newSlider("fov_transparency", "Transparency", 0.1, 0, 1, 2, true, "");
    silent_aim:newSlider("prediction", "Prediction", 15, 0, 200, 2, true, "%");
    silent_aim:newSlider("fov_radius", "FOV", 90, 1, 2000, 1, true, "px");
    silent_aim:newDropdown('allowed_sa_targets', 'Allowed Targets', {
        "Guildmates",
        "Players",
        "Mobs"
    },{
        "Players",
        "Mobs"
    }, true, "Allowed targets to silent aim at.");


    local safe_input = tab:newGroupBox("Safe Input", false);
    safe_input:newLabel("Safe Input requires M1 Hold & AP.", true);
    safe_input:newLabel("Some moves arent tagged.", true);
    safe_input:newToggle("block_input", "Block Input [WIP]", false, "Blocks input when doing a action, Also known as 'Safe Input', Requires 'M1 Hold' to block M1s.", nil);
         
    local punishable_time_box, raw_punishable = safe_input:newDependencyBox(); 
    punishable_time_box:newSlider("bi_punishable_time", "Punishable Time", 650, 1, 1000, 1, true, "ms");
    
    local dynamic_extra_punishable_time_box, raw_extra_punishable = safe_input:newDependencyBox();
    dynamic_extra_punishable_time_box:newSlider("extra_bi_punishable_time", "Extra Punishable Time", 0, -500, 500, 1, true, "ms");
     
    safe_input:newDropdown('bi_punishable_type', 'Punishable Type', {
        "Dynamic",
        "Custom",
        "Always"
    }, "Custom", false, "What block input will use for the time frame when you can be punished, Dynamic may be inconsistent on certain weapons (e.g: rifle)")    
    safe_input:newDropdown('allowed_bi_targets', 'Allowed Targets', {
        "PVE",
        "PVP"
    },{
        "PVE",
        "PVP"
    }, true, "What block input will trigger on.")
    
    safe_input:newDropdown('blocked_safe_input_user_moves', 'Blocked Moves', {
        "Criticals",
        "M1s", 
        "M2s",
    },{ 
        "M1s"
    }, true, "Safe Input Triggers, Some moves are currently untagged or skip.");

    safe_input:newDropdown('blocked_safe_input_moves', 'Dont Against', {
        "Animations",
        "Critical",
        "Untagged",
        "Effects",
        "Spell",
        "Parts",
        "Bell",
        "M1",
    },{}, true, "Block Input Triggers, Some moves are currently untagged or skip.");
    raw_punishable:SetupDependencies({{ 
        aztup_options.bi_punishable_type, "Custom"
    }});

    raw_extra_punishable:SetupDependencies({{ 
        aztup_options.bi_punishable_type, "Dynamic"
    }});

    local mantra_sliding = tab:newGroupBox("Mantra Slidecast");
    mantra_sliding:newToggleWithKeybind("mantra_slidecasting", "Mantra Slidecasting", false, "Automatically slides after doing certain actions.", nil);
    local mantra_sliding_dependency_box = mantra_sliding:newDependencyBox("mantra_slidecasting");
    mantra_sliding_dependency_box:newSlider("mantra_slidecasting_chance", "Trigger Chance", 70, 1, 100, 0, true, "%");

    mantra_sliding_dependency_box:newDropdown('mantra_slidecasting_mantras', 'Trigger Mantras', {}, {}, true, "Mantras that trigger action sliding.");
    mantra_sliding_dependency_box:newButton("Load Mantras", function()
        local mantras = {};
        for _, mantra in local_player.instance.Backpack:GetChildren() do
            if not mantra.Name:find("Mantra:") or mantra.Name:find("RecalledMantra:") then continue end        

            table.insert(mantras, mantra:GetAttribute("DefaultName"));
        end

        aztup_options.mantra_slidecasting_mantras:SetValues(mantras);
    end);
    local action_rolling = tab:newGroupBox("Mantra Rolling", true);
    action_rolling:newToggleWithKeybind("action_rolling", "Mantra Rolling", false, "Automatically rolls after doing certain actions.", nil, false);
    local action_rolling_dependency_box = action_rolling:newDependencyBox("action_rolling");

    action_rolling_dependency_box:newSlider("action_rolling_chance", "Trigger Chance", 70, 1, 100, 0, true, "%");
    action_rolling_dependency_box:newDropdown('action_rolling_mantras', 'Trigger Mantras', {}, {}, true, "Mantras that trigger action rolling.");
    action_rolling_dependency_box:newButton("Load Mantras", function()
        local mantras = {};
        for _, mantra in local_player.instance.Backpack:GetChildren() do
            if not mantra.Name:find("Mantra:") or mantra.Name:find("RecalledMantra:") then continue end        

            table.insert(mantras, mantra:GetAttribute("DefaultName"));
        end

        aztup_options.action_rolling_mantras:SetValues(mantras);
    end);

    local backstab_movestacker = tab:newGroupBox("Backstab Movestacker", true);
    backstab_movestacker:newToggleWithKeybind("backstab_movestacker", "Backstab Movestacker", false, "Automatically casts in a Authority Ensign backstab ('Backstabber' tal req).", nil);
    local backstab_movestacker_dependency_box = backstab_movestacker:newDependencyBox("backstab_movestacker");
    backstab_movestacker_dependency_box:newDropdown('backstab_movestacker_mantras', 'Trigger Mantras', {}, {}, true, "Mantras that will trigger during a backstab.");
    backstab_movestacker_dependency_box:newButton("Load Mantras", function()
        local mantras = {};
        for _, mantra in local_player.instance.Backpack:GetChildren() do
            if not mantra.Name:find("Mantra:") or mantra.Name:find("RecalledMantra:") then continue end        
            
            table.insert(mantras, mantra:GetAttribute("DefaultName"));
        end

        aztup_options.backstab_movestacker_mantras:SetValues(mantras);
    end);

    local other = autoparry_tabbox:newTab("Other");
    other:newToggle("view_hitboxes", "View hitboxes", false, "Log anims to console.", nil);
    other:newSlider("max_boxes", "Max Hitboxes", 5, 1, 100, 0, true, "hbs");
    other:newSlider("hb_trans", "Hitbox Transparency", 100, 1, 100, 1, true, "%");
    other:newToggle("show_hitbox_simulation", "View hitbox simulation", false, "Show hitbox simulation.", nil);
    local hitbox_dependency = other:newDependencyBox("show_hitbox_simulation");
    hitbox_dependency:newDropdown("HS_HitboxType", "Hitbox Type", {
        "Block",
        "Ball", 
        "Cylinder"
    }, "Block", false, "Type of hitbox shape to visualize.", nil);

    hitbox_dependency:newSlider("HS_HitboxSizeX", "Hitbox Size X", 4, 0.1, 250, 1, true, "studs", nil);
    hitbox_dependency:newSlider("HS_HitboxSizeY", "Hitbox Size Y", 4, 0.1, 250, 1, true, "studs", nil);
    hitbox_dependency:newSlider("HS_HitboxSizeZ", "Hitbox Size Z", 4, 0.1, 250, 1, true, "studs", nil);
    hitbox_dependency:newSlider("HS_ShiftOffset", "Shift Offset", 0, -250, 30, 1, true, "studs", nil);


    local function get_list()
        local list = {};

        for _, name in getgenv().timing_names and getgenv().timing_names() or {} do
            table.insert(list, name);
        end;

        for _, name in getgenv().effect_names or {} do
            table.insert(list, name);
        end

        return list    
end;
    local chance_label;

    other:newDropdown('m1_timing_hitbox_type', 'M1 Hitbox Type', {
        "Square",
        "Ball"
    }, {
        "Ball"
    }, false, "M1 Timings & their hitbox type.", function() end, true);
    other:newDropdown('blocked_timings', 'Blocked Timings', {}, {}, true, "Disallowed Timings.", function() end, true);
    other:newDropdown('chance_timings', 'Chance Editor', {}, {}, false, "Change Timing Chances.", function() end, true);
    other:newSlider("chance_parry_weight", "Parry Chance", 100, 0, 100, 0, true, "%");
    other:newSlider("chance_dodge_weight", "Dodge Chance", 0, 0, 100, 0, true, "%");
    other:newSlider("chance_skip_weight", "Skip Chance", 0, 0, 100, 0, true, "%");

    other:newButton("Load List", function()
        local list = get_list();
        aztup_options.blocked_timings:SetValues(list);
        aztup_options.chance_timings:SetValues(list);
    end);

    other:newButton("Normalize Chances", function()
        local buckets = {
            { key = "Parry", option = aztup_options.chance_parry_weight },
            { key = "Dodge", option = aztup_options.chance_dodge_weight },
            { key = "Skip", option = aztup_options.chance_skip_weight },
        };

        local total = 0;
        for _, bucket in ipairs(buckets) do
            bucket.value = math.max(0, tonumber(bucket.option.Value) or 0);
            total += bucket.value;
        end;

        if total <= 0 then
            aztup_options.chance_parry_weight:SetValue(100);
            aztup_options.chance_dodge_weight:SetValue(0);
            aztup_options.chance_skip_weight:SetValue(0);
            Logger:notify("all 0, set parry back to 100", 4);
            return        
end;

        local used = 0;
        for _, bucket in ipairs(buckets) do
            local exact = (bucket.value / total) * 100;
            bucket.normalized = math.floor(exact);
            bucket.frac = exact - bucket.normalized;
            used += bucket.normalized;
        end;

        local remaining = 100 - used;
        table.sort(buckets, function(a, b)
            if a.frac == b.frac then
                return a.key < b.key            
end;

            return a.frac > b.frac        
end);

        for i = 1, remaining do
            buckets[i].normalized += 1;
        end;

        for _, bucket in ipairs(buckets) do
            bucket.option:SetValue(bucket.normalized);
        end;
    end);
    
    other:newButton("Set", function()
        local timing_name = aztup_options.chance_timings.Value;
        local outcome_weights = {
            ["Parry"] = aztup_options.chance_parry_weight.Value,
            ["Dodge"] = aztup_options.chance_dodge_weight.Value,
            ["Skip"] = aztup_options.chance_skip_weight.Value,
        };
        if not timing_name or timing_name == "" then
            Logger:notify("no timing selected!", 5);
            return        
end;
        
        chance_store:add_chance(timing_name, outcome_weights);
        chance_store:save_chances();
        if chance_store.on_load_function then
            chance_store.on_load_function();
        end;
    end);

    other:newButton("Clear", function()
        table.clear(chance_store.chances);
        if chance_store.on_load_function then
            chance_store.on_load_function();
        end;
        chance_store:save_chances();
    end, true);

    chance_label = other:newLabel("", true, true);
    chance_label:Hide();

    chance_store:on_load(function()
        local store = {"Current Chances:"};
        local override_store = {"Current Chances:"};
    
        for t, _ in pairs(chance_store.chances) do
            local entry = chance_store:get_entry(t);
            local outcome_weights = entry and (entry.outcome_weights or entry.fail_weights) or { Parry = 100 };
            local total_weight = 0;
            for _, amount in pairs(outcome_weights) do
                total_weight += typeof(amount) == "number" and math.max(0, amount) or 0;
            end;

            if total_weight <= 0 then
                outcome_weights = { Skip = 100 };
                total_weight = 100;
            end;

            local chance_parts = {};
            local colored_parts = {};
            for _, action_name in {
                "Parry",
                "Dodge",
                "Skip"
            } do
                local amount = outcome_weights[action_name] or 0;
                if amount == 0 then continue end
                local pct = math.floor((amount / total_weight) * 100 + 0.5);
                local fmt_action_name = ({
                    ["Parry"] = "Parry",
                    ["Dodge"] = "Dodge",
                    ["Skip"] = "Skip",
                })[action_name];
                local color = Color3.fromRGB(255, 85, 88):Lerp(Color3.new(0.403922, 1, 0.403922), pct / 100):ToHex();

                table.insert(chance_parts, string.format('%s %d%%', fmt_action_name, pct));
                table.insert(colored_parts, string.format('<font color="#%s">%s %d%%</font>', color, fmt_action_name, pct));
            end;

            local chance_text = #chance_parts > 0 and table.concat(chance_parts, ", ") or "Skip 100%";
            local chance_text_colored = #colored_parts > 0 and table.concat(colored_parts, ", ") or '<font color="#FF5558">Skip 100%</font>';
            table.insert(override_store, string.format('%s: %s', t, chance_text));
            table.insert(store, string.format('%s: %s', t, chance_text_colored));
        end;
        
        if #store == 1 then
            table.clear(store);
            table.clear(override_store);
            chance_label:Hide();
        else
            chance_label:Show();
        end;

        chance_label:SetText(table.concat(store, "\n"), table.concat(override_store, "\n"));    
    end);

    other:newToggle("info_logger", "Timing Logger", false, "Log anims to console.", nil);
    other:newSlider("info_logger_range", "Timing Logger Range", 1, 1, 500, 0, true, "s");
    local timing_builder = require("@src/features/auto-parry/builder");
    local timings = tab:newGroupBox("Timing Builder", true);
    timings:newToggleWithKeybind("show_timing_builder", "Show Timing Builder", false, "Make your own parry timings. Pick an animation it watched (or click one in the Timing Logger), place actions on the timeline, then Save.", function(val)
        timing_builder:set_visible(val);
    end);
    timing_builder.on_close = function()
        aztup_toggles.show_timing_builder:SetValue(false);
    end;

    timings:newButton("Reload Timings", function()
        xpcall(getgenv().load_timings, warn); 
    end);

    timings:newButton("Auto Hot Reload Timings [slow]", function()
        local last_update = tick();
        aztup.maid:give_task(services.RunService.RenderStepped:Connect(function()   
            if tick() - last_update <= 5 then return end
            if not getgenv().dev_tools_data or not getgenv().dev_tools_data["hot-reload-timings"] then return end

            last_update = tick();
            xpcall(getgenv().load_timings, warn);
        end));   
    end);

    if can_edit_internal_timings or isfile("builder.rbxm") then
        local debug = tab:newGroupBox("Debug", true);

        local function play_action(type)
            local DefendActionManager = getgenv().DefendActionManager;
            if not DefendActionManager then
                return warn("turn ap on stupid HON")            
end;

            local entity = local_player.character

            if type == "Parry" then
                DefendActionManager:queue_generic_parry_task_no_convert(entity);
            elseif type == "Dodge" then
                DefendActionManager:add_action(entity, "dodge", tick());
            elseif type == "Forced Full Dodge" then
                DefendActionManager:defend_action_dodge({
                    mob = entity,
                    type = "dodge",
                    full = true,
                    when = tick()
                });
            elseif type == "Start Block" then
                DefendActionManager:add_action(entity, "block", tick());
            elseif type == "End Block" then
                DefendActionManager:add_action(entity, "unblock", tick());
            elseif type == "Crouch" then
                task.spawn(function()
                    local_player.character:WaitForChild("CharacterHandler"):WaitForChild("Requests"):WaitForChild("ServerCrouch"):FireServer(true);
                    task.wait(1);
                    local_player.character:WaitForChild("CharacterHandler"):WaitForChild("Requests"):WaitForChild("ServerCrouch"):FireServer(false);
                end);
            elseif type == "Jump" or type == "Legit Jump" then
                if #services.Players:GetPlayers() == 1 and type ~= "Legit Jump" then
                    local_player.character.CharacterHandler.Requests.Jump:FireServer();
                    local_player.root_part.CFrame *= CFrame.new(0, 50, 0);
                else
                    local jump_func = nil;
                    local upvalues = getupvalues(base_require(game:GetService("ReplicatedStorage").Modules.CharacterControllers.Human));

                    for _, upvalue in upvalues do
                        if typeof(upvalue) == "table" and rawget(upvalue, "Jump") then
                            jump_func = rawget(upvalue, "Jump");
                        end;
                    end;

                    if jump_func({
                        Humanoid = local_player.humanoid,
                        RootPart = local_player.root_part,
                        GroundSensor = local_player.root_part:FindFirstChild("GroundSensor")
                    }) then
                        local_player.character.CharacterHandler.Requests.Jump:FireServer();

                        local jump_anim = local_player.humanoid:LoadAnimation(local_player.character.CharacterHandler.InputClient.Jump);
                        jump_anim:Play(0.05);

                        task.delay(0.4, function()
                            jump_anim:AdjustSpeed(0.5);
                            jump_anim:Stop(0.1);
                        end);
                    end;
                end;
            end;
        end;

        for _, action_type in {
            "Parry",
            "Dodge",
            "Forced Full Dodge",
            "Start Block",
            "End Block",
            "Jump",
            "Legit Jump",
            "Crouch"
        } do
            debug:newButton("Play " .. action_type, function()
                xpcall(play_action, warn, action_type);
            end);
        end;
    end;
    
end, {
    name = "Combat"
}