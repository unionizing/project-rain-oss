local ReplicatedStorage = game:GetService("ReplicatedStorage")
local automation = {};

function automation:make_general()
    local automation_tabbox = self.tab:newTabbox("Automation", false);
    local general = automation_tabbox:newTab("General");
    local options = automation_tabbox:newTab("Options");
 
    general:newToggleGroup({
        {"auto_decline_squad_invites", "Auto Decline Squad Invites", false, "Automatically declines squad invites for you, will notify you in the top left when it does.", NoKeybind = true},
        {"auto_decline_guild_invites", "Auto Decline Guild Invites", false, "Automatically declines guild invites for you.", NoKeybind = true},
        {"auto_fight",                 "Auto Fight Mobs [WIP]", false, "Automatically fights mobs for you, very limited, meant for to1 atm", nil, false},
        {"auto_ragdoll_cancel",        "Auto Ragdoll Cancel", false, "Automatically cancels any ragdolls you happen to be in.", NoKeybind = true},
        {"auto_equip_weapon",          "Auto Equip Weapon", false, "Automatically equips your weapon when it's not in your hands.", NoKeybind = true},
        {"auto_chime_requeue",         "Auto Chime Requeue", false, "Automatically re-enters chime after you win a match, Only Queues 1v1s.", NoKeybind = true},
        {"auto_charisma",              "Auto Charisma Book", false, "Automate How To Make Friends", NoKeybind = true},
        {"auto_math_book",             "Auto Math Textbook", false, "Automate Math Textbook", NoKeybind = true},
        {"auto_golden_tongue",         "Auto Golden Tongue", false, "Automatically uses Golden Tongue for you when off cooldown. (deepwarden does it silently so this is safe)", nil, false},
        {"auto_roll_cancel",           "Auto Roll Cancel", false, "Automatically cancels your rolls by M2ing.", NoKeybind = true},
        {"auto_air_counter",           "Auto Air Counter", false, "Automatically air counters for you."},
        {"auto_flow_state",            "Auto Flow State", false, "Automatically uses Flow State for Silentheart moves.", nil, false},
        {"auto_reinforce",             "Auto Reinforce", false, "Automatically reinforces on parry for you, Insignia Gem recommended.", nil, false},
        {"auto_uppercut",              "Auto Uppercut", false, "Automatically uppercuts when you crouch.", NoKeybind = true},
        {"auto_sprint",                "Auto Sprint", false, "Automatically sprints for you."},
        {"auto_brutus",                "Auto Brutus", false, "Automate Brutus Interaction", NoKeybind = true},
        {"auto_train_agility",         "Auto Train Agility", false, "Equips Ankle Weights (if you have them) and spam roll-cancels to train Agility. Stops rolling if a player is nearby.", NoKeybind = true},
        {"auto_ardour",                "Auto Ardour", false, "Automatically enables Ardour for you.", nil, false},
        {"auto_fish",                  "Auto Fish", false, "Automatically throws fishing rod and catches fish for you.", NoKeybind = true},
        {"auto_wisp",                  "Auto Wisp", false, "Automatically casts wisps"},
    });

    options:newDropdown("auto_golden_tongue_mode", "Golden Tongue Mode", {
        "Blatant",
        "Legit"
    }, "Blatant", false, "Should auto golden tongue be used blatantly (no message), or send a legit message (W/A/S/D)?.");
    options:newSlider("auto_sprint_delay",        "Sprint Delay", 0, 0, 1, 1);
    options:newSlider("auto_wisp_delay",          "Wisp Delay", 0, 0, 1, 1);
    options:newKeybind("hide_sprint_state_bind", "Hide Auto Sprint State (hold)", 'None', function(on)
        aztup.features.auto_sprint.hide_held = on;
    end, "Hold", true, true); 

    options:newToggleGroup({
        {"air_counter_ally_check", "Air Counter Ally Check", false, "Checks if the target is an ally before using air counter.", NoKeybind = true},
        {"air_counter_on_ground",  "Air Counter On Ground", false, "Automatically uses air counter on the ground, Unintended game behavior.", NoKeybind = true, Risky = true},
    });
    options:newSlider("air_counter_range",          "Air Counter Range", 60, 1, 100, 0, true, nil, nil, "The range you will air counter in, above 60 is blatant (non game expected behavior)");

end

function automation:make_webhooks()
    local webhooks = self.tab:newGroupBox("Webhooks", true);
    webhooks:newTextbox("automation_webhook", "Automation Webhook", false, "", nil, "Webhook URL for automation notifications (saramed, echofarms, etc)")
    webhooks:newButton("Set Webhook", function()
        local webhook_url = aztup_options.automation_webhook.Value
        if not webhook_url:find("discord.com/api/webhooks", 1, true) then
            Logger:notify_sound("Invalid webhook URL!")
            return
        end
        
        persistent_data:set("automation_webhook", webhook_url)
    end, true, "Sets the webhook for automation notifications.")
end

function automation:make_autoloot()
    
    local auto_loot_groupbox = self.tab:newGroupBox("Auto Loot", false)
    
    
    auto_loot_groupbox:newToggle('auto_loot', 'Auto Loot', false, '', function(value) end)
    auto_loot_groupbox:newToggle('notify_on_loot', 'Notify On Loot', false, '', function(value) end)
    
    local auto_loot_box = auto_loot_groupbox:newDependencyBox("notify_on_loot");
    auto_loot_box:newToggle('play_sound_noti', 'Play Sound Noti', false, '');
    auto_loot_groupbox:newDivider();
    auto_loot_groupbox:newDropdown('loot_options', 'Loot Options', {
        'Item Loot',
        'Always Loot Items',
        'Stat Loot',
        'Loot All',
    }, '', true, '', function() end, true, true)
    
    aztup_options.loot_options:OnChanged(function()
        pcall(function() 
            aztup_options.stat_editor:SetValue(nil);
        end);
    end);
    
    
    local loot_all_box = auto_loot_groupbox:newDependencyBox("loot_options", "Loot All");
    loot_all_box:newDropdown('loot_all_rarities', 'Loot All Options', {
        'Common',
        'Uncommon',
        'Rare',
        'Enchant',
        'Legendary',
        'Mythic',
        'Relic',
        'Unique'
    }, '', true, 'Loots all of this rarity, doesnt skip filters if stat loot is on', function() end, true, true)
    
    
    local always_loot_box = auto_loot_groupbox:newDependencyBox("loot_options", "Always Loot Items");
    always_loot_box:newDropdown('always_loot_dropdown', 'Always Loot Options', {
        'Relics',
        'Enchant Stones',
        'Legendary Weapons',
        'Deep Gems',
        'Kyrsan Medallions'
    }, '', true, 'Always loots these filtered items, skips filters if stat loot is on', function() end, true, true)
    
    
    local item_loot_box = auto_loot_groupbox:newDependencyBox("loot_options", "Item Loot");
    item_loot_box:newTextbox('item_loot_input', 'Items', false, '', nil, '(loots items by name, semicolon sep), Ex: "Stilleto;Gobletto;Mushroom Omelette"')
    
    local stat_loot_box = auto_loot_groupbox:newDependencyBox("loot_options", "Stat Loot");
    
    
    
    stat_loot_box:newDropdown('stat_loot_dropdown', 'Stat Loot', {
        'Headwear',
        'Facewear',
        'Earrings',
        'Neckwear',
        'Weapons',
        'Rings',
        'Arms',
        'Legs'
    }, '', true, '', function() end, true, true)
    
    stat_loot_box:newDropdown('precise_stat_loot', 'Require Exact Stats', {
        'Headwear',
        'Facewear',
        'Earrings',
        'Neckwear',
        'Weapons',
        'Rings',
        'Arms',
        'Legs'
    }, '', true, '', function() end, true, true)
    
    stat_loot_box:newDropdown('stat_editor', 'Stat Editor', {
        'Headwear',
        'Facewear',
        'Earrings',
        'Neckwear',
        'Weapons',
        'Rings',
        'Arms',
        'Legs'
    }, '', false, '', function() end, true, true)
    
    local stat_loot_arms_box = auto_loot_groupbox:newDependencyBox("stat_editor", "Arms");
    local stat_loot_rings_box = auto_loot_groupbox:newDependencyBox("stat_editor", "Rings");
    local stat_loot_neckwear_box = auto_loot_groupbox:newDependencyBox("stat_editor", "Neckwear");
    local stat_loot_earrings_box = auto_loot_groupbox:newDependencyBox("stat_editor", "Earrings");
    local stat_loot_facewear_box = auto_loot_groupbox:newDependencyBox("stat_editor", "Facewear");
    local stat_loot_headwear_box = auto_loot_groupbox:newDependencyBox("stat_editor", "Headwear");
    local stat_loot_weapons_box = auto_loot_groupbox:newDependencyBox("stat_editor", "Weapons");
    local stat_loot_legs_box = auto_loot_groupbox:newDependencyBox("stat_editor", "Legs");
    
    stat_loot_weapons_box:newSlider('stat_loot_weapons_penetration', 'Penetration', 1, 0, 7, 0, true, '')
    stat_loot_weapons_box:newSlider('stat_loot_weapons_damage', 'Damage', 1, 0, 15, 0, true, '')
    stat_loot_weapons_box:newSlider('stat_loot_weapons_weight', 'Weight', 1, 0, 10, 0, true, '')
    stat_loot_headwear_box:newSlider('stat_loot_headwear_health', 'Health', 1, 0, 30, 0, true, '')
    stat_loot_headwear_box:newSlider('stat_loot_headwear_ether', 'Ether', 1, 0, 30, 0, true, '')
    stat_loot_headwear_box:newSlider('stat_loot_headwear_monsterdamage', 'Monster Damage', 1, 0, 15, 0, true, '')
    stat_loot_headwear_box:newSlider('stat_loot_headwear_physicalarmour', 'Physical Armour', 1, 0, 15, 0, true, '')
    stat_loot_headwear_box:newSlider('stat_loot_headwear_elearmour', 'Elemental Armour', 1, 0, 15, 0, true, '')
    stat_loot_headwear_box:newSlider('stat_loot_headwear_monsterarmour', 'Monster Armour', 1, 0, 15, 0, true, '')
    stat_loot_facewear_box:newSlider('stat_loot_facewear_ether', 'Ether', 1, 0, 30, 0, true, '')
    stat_loot_facewear_box:newSlider('stat_loot_facewear_sanity', 'Sanity', 1, 0, 30, 0, true, '')
    stat_loot_facewear_box:newSlider('stat_loot_facewear_monsterdamage', 'Monster Damage', 1, 0, 15, 0, true, '')
    stat_loot_earrings_box:newSlider('stat_loot_earrings_ether', 'Ether', 1, 0, 30, 0, true, '')
    stat_loot_earrings_box:newSlider('stat_loot_earrings_sanity', 'Sanity', 1, 0, 30, 0, true, '')
    stat_loot_earrings_box:newSlider('stat_loot_earrings_monsterdamage', 'Monster Damage',  1, 0, 15, 0, true, '')
    stat_loot_neckwear_box:newSlider('stat_loot_neckwear_health', 'Health', 1, 0, 30, 0, true, '')
    stat_loot_neckwear_box:newSlider('stat_loot_neckwear_ether', 'Ether', 1, 0, 10, 0, true, '')
    stat_loot_neckwear_box:newSlider('stat_loot_neckwear_monsterdamage', 'Monster Damage', 1, 0, 7, 0, true, '')
    stat_loot_rings_box:newSlider('stat_loot_rings_health', 'Health', 1, 0, 30, 0, true, '')
    stat_loot_rings_box:newSlider('stat_loot_rings_ether', 'Ether', 1, 0, 30, 0, true, '')
    stat_loot_rings_box:newSlider('stat_loot_rings_sanity', 'Sanity', 1, 0, 10, 0, true, '')
    stat_loot_rings_box:newSlider('stat_loot_rings_posture', 'Posture', 1, 0, 5, 0, true, '')
    stat_loot_rings_box:newSlider('stat_loot_rings_monsterdamage', 'Monster Damage', 1, 0, 15, 0, true, '')
    stat_loot_arms_box:newSlider('stat_loot_arms_health', 'Health', 1, 0, 30, 0, true, '')
    stat_loot_arms_box:newSlider('stat_loot_arms_ether', 'Ether', 1, 0, 30, 0, true, '')
    stat_loot_arms_box:newSlider('stat_loot_arms_monsterdamage', 'Monster Damage', 1, 0, 15, 0, true, '')
    stat_loot_arms_box:newSlider('stat_loot_arms_physicalarmour', 'Physical Armour', 1, 0, 15, 0, true, '')
    stat_loot_arms_box:newSlider('stat_loot_arms_elementalarmour', 'Elemental Armour', 1, 0, 15, 0, true, '')
    stat_loot_arms_box:newSlider('stat_loot_arms_monsterarmour', 'Monster Armour', 1, 0, 15, 0, true, '')
    stat_loot_legs_box:newSlider('stat_loot_legs_health', 'Health', 1, 0, 30, 0, true, '')
    stat_loot_legs_box:newSlider('stat_loot_legs_ether', 'Ether', 1, 0, 30, 0, true, '')
    stat_loot_legs_box:newSlider('stat_loot_legs_monsterdamage', 'Monster Damage', 1, 0, 15, 0, true, '')
end






































function automation:make_farms()
    
    local missions_tabbox = self.tab:newTabbox("Missions", true)
    local missions = missions_tabbox:newTab("Missions")
    local missions_options = missions_tabbox:newTab("Options")

    missions:newButton('Auto Authority Missions', function()
        task.spawn(function()
            persistent_data:set('auto_authority_do_hostage', aztup_options.auto_authority_missions_enabled.Value['Hostage'] == true)
            persistent_data:set('auto_authority_do_barrels', aztup_options.auto_authority_missions_enabled.Value['Armament Sabotage'] == true)
            persistent_data:set('auto_authority_do_secure', aztup_options.auto_authority_missions_enabled.Value['Secure the Perimeter'] == true)
            aztup.automation:set('auto_authority_missions', not persistent_data:get('auto_authority_missions', false))
            Logger:notify('Auto Authority Missions [' .. persistent_data:get('auto_authority_missions', false) .. ']')
        end)
    end, true, 'Start in Eastern Luminant as Authority Origin.')

    missions_options:newDropdown('auto_authority_missions_enabled', 'Missions', {
        'Hostage',
        'Armament Sabotage',
        'Secure the Perimeter',
    }, {'Hostage', 'Armament Sabotage', 'Secure the Perimeter'}, true, 'Choose what missions you want to do. (unselected means skip/serverhop)', function() end, true, true)
    

    
    local saramed_tabbox = self.tab:newTabbox("Saramed", true)
    local saramed = saramed_tabbox:newTab("Saramed")
    local saramed_options = saramed_tabbox:newTab("Options")

    saramed:newButton("Auto Saramed", function()
        task.spawn(function()
            aztup.automation:set("auto_saramed", not persistent_data:get("auto_saramed", false));
        end)
    end, true, "Start anywhere in overworld. Will handle hunger / thirst.");

    saramed_options:newSlider("auto_saramed_minimum_health", 'Minimum Health', 25, 0, 100, 0, true, '%')
    saramed_options:newSlider("auto_saramed_attach_to_mob_distance", "Attach To Mob Distance", 8, 0, 10, 1, true, '')

    
    local ministry_tabbox = self.tab:newTabbox("Notes")
    local ministry = ministry_tabbox:newTab("Notes")
    local ministry_options = ministry_tabbox:newTab("Options")

    ministry:newButton('Ministry Note Farm', function()
        if game:GetService("ReplicatedStorage").Requests.Get:InvokeServer().MetaProg.Knowledge == 0 then
            return Logger:notify_sound("You need extra starting knowledge for this")
        end;

        task.spawn(function()
            aztup.automation:set('ministry_notefarm', not persistent_data:get('ministry_notefarm', false))

            if persistent_data:get('ministry_notefarm', false) then
                
                persistent_data:remove('max_notes')
            end
        end)
    end, true, 'Start at Character Creation, Wipes you.')

    ministry_options:newDropdown('note_farm_options', 'Options', {
        "Use Guild"
    }, '', true, 'Select the options you would like for this autofarm.', function() end, true, true)

    local autoprogression_tabbox = self.tab:newTabbox("Auto Progression", true)
    local autoprogression = autoprogression_tabbox:newTab("Auto Progression")
    local autoprogression_options = autoprogression_tabbox:newTab("Options")

    autoprogression:newTextbox("auto_progress_url", "Build URL", false, "", nil, 'Builder link to the auto progreession build.');

    autoprogression_options:newDropdown("auto_progress_method", "Method", {
        "Ferryman",
        "Saramed",
    }, "Ferryman", false, "Choose the method to use while progging out the build.", function() end, true, true)

    autoprogression_options:newToggle("auto_progress_shrined", "Start Shrined", false, "Starts auto progression at a shrined state.")

    autoprogression:newButton("Auto Progress", function()
        task.spawn(function()
            if aztup.silent_mode then
                local_player.instance:Kick("You can't use auto progression in silent mode.");
                return
            end;

            local starting = not persistent_data:get('auto_progress', false)

            if starting then
                local shrined = aztup.flags.auto_progress_shrined == true;
                local state = shrined and "DOING_AUTO_FERRYMAN" or "JUST_STARTED";
                local data = { shrined = shrined, farm_method = aztup_options.auto_progress_method.Value };

                local auto_progress_module = aztup.farms['auto_progress'];
                if auto_progress_module and auto_progress_module.initialize then
                    auto_progress_module.initialize(state, data);
                else
                    persistent_data:set("auto_progression_internal", { state = state, data = data });
                end;

                persistent_data:set("auto_progress_url", aztup_options.auto_progress_url.Value);
                persistent_data:set("auto_builder_url", aztup_options.auto_progress_url.Value);
            end

            aztup.automation:set('auto_progress', starting)
        end)
    end, true, "Start in Character Creation.")

    autoprogression:newButton("Auto VOI", function()
        task.spawn(function()
            if aztup.silent_mode then
                local_player.instance:Kick("You can't use auto voi in silent mode.");
                return
            end;

            local starting = not persistent_data:get('auto_voi', false)
            if starting then persistent_data:wipe(); end
            aztup.automation:set('auto_voi', starting)
        end)
    end, true, "Start after spawning in VOI.")

    
    local builder_tabbox = self.tab:newTabbox("Builder", true)
    local builder_tab = builder_tabbox:newTab("Builder")
    local builder_options = builder_tabbox:newTab("Options")

    builder_options:newTextbox("auto_builder_url", "Build URL", false, "", nil, 'Builder Link')

    builder_options:newToggle("auto_builder_shrined", "Shrined", false, "Force the post shrine stats. Turn this on if you already shrined.", function(value)
        ab_builder.shrined = value;
        ab_builder.logged_targets = false;
    end)

    builder_tab:newButton("Auto Builder", function()
        task.spawn(function()
            persistent_data:set("auto_builder_url", aztup_options.auto_builder_url.Value);

            if ab_builder.running then
                ab_builder:killswitch()
                return
            end

            if not ab_builder:build() then
                Logger:notify_sound("Couldn't load that build, check your builder link.")
            end
        end)
    end, true, "Start anywhere. Picks talents & mantras from the build.")

    builder_tab:newButton("Auto Points", function()
        task.spawn(function()
            persistent_data:set("auto_builder_url", aztup_options.auto_builder_url.Value);

            if ab_builder.points_running then
                ab_builder:points_killswitch()
                return
            end

            if not ab_builder:put_points() then
                Logger:notify_sound("Couldn't load that build, check your builder link.")
            end
        end)
    end, true, "Start anywhere. Spends your attribute points to match the build.")

    
    local moons_tabbox = self.tab:newTabbox("Astral")
    local moons = moons_tabbox:newTab("Astral")
    local moons_options = moons_tabbox:newTab("Options")

    moons:newButton('Moons Eyrie Farm', function()
        task.spawn(function()
            aztup.automation:set('auto_moonseyrie', not persistent_data:get('auto_moonseyrie', false))
        end)
    end, true, 'This will kill you eventually due to a bug. If this happens, record it.')

    moons_options:newLabel("Unsupported for this task.")

    
    local resources_tabbox = self.tab:newTabbox("Resources", true)
    local resources = resources_tabbox:newTab("Resources")
    local resources_options = resources_tabbox:newTab("Options")

    resources:newButton("Titus Relic Farm", function()
        task.spawn(function()
            persistent_data:set('auto_titus_bank_moonseye', aztup_options.relic_farm_relics.Value['Moonseye Tome'])
            persistent_data:set('auto_titus_bank_idol', aztup_options.relic_farm_relics.Value["Idol of Yun'Shul"])
            persistent_data:set('auto_titus_bank_needle', aztup_options.relic_farm_relics.Value["Armorer's Needle"])
            persistent_data:set('auto_titus_bank_smiths', aztup_options.relic_farm_relics.Value["Smith's Alloy"])
            aztup.automation:set("auto_titus", not persistent_data:get("auto_titus", false))
        end)
    end, true, "Start anywhere.")

    resources_options:newDropdown('relic_farm_options', 'Options', {
        "Wipe Character"
    }, '', true, 'Select the options you would like for this autofarm.', function() end, true, true)

    resources_options:newDropdown('relic_farm_relics', 'Relics', {
        "Moonseye Tome",
        "Idol of Yun'Shul",
        "Armorer's Needle",
        "Smith's Alloy"
    }, "Idol of Yun'Shul", true, 'What relics you would like the farm to loot.', function() end, true, true)

    resources_options:newDropdown('relic_farm_bank_items', 'Bank At 25', {
        "Moonseye Tome",
        "Idol of Yun'Shul",
        "Armorer's Needle",
        "Smith's Alloy"
    }, "Idol of Yun'Shul", true, 'When you hold 25+ of these, the farm tweens to the Banker and deposits them.', function() end, true, true)

    
    local echo_tabbox = self.tab:newTabbox("Echoes", true)
    local echofarms = echo_tabbox:newTab("Echoes")
    local echo_options = echo_tabbox:newTab("Options")

    echofarms:newButton("Titus Echo Farm", function()
        task.spawn(function()
            persistent_data:set("started_farm_at", tick());
            persistent_data:set("cycle_count", 0)
            persistent_data:set("echoes_gained", 0)
            
            aztup.automation:set("autoecho_titus", not persistent_data:get("autoecho_titus", false))
        end)
    end, true, "Start in Etrean/Fragments & Character Creator, Must have the 'Authority Ensign' origin unlocked, 10-25e/m")

    echofarms:newButton("Soup Echo Farm", function()
        task.spawn(function()
            persistent_data:set('soup_echo_farm_origin', aztup_options.soup_echofarm_origin.Value)
            persistent_data:set("started_farm_at", tick());
            persistent_data:set("cycle_count", 0)
            persistent_data:set("echoes_gained", 0)

            aztup.automation:set("soup_echofarm", not persistent_data:get("soup_echofarm", false))
        end)
    end, true, "Start anywhere, Automatically creates soup for echoes @ 3-4/m.")

    echofarms:newButton("Auto Echo Layer 2", function()
        task.spawn(function()
            persistent_data:set("started_farm_at", tick());
            persistent_data:set("cycle_count", 0)
            persistent_data:set("echoes_gained", 0)

            aztup.automation:set("auto_echo_layer2", not persistent_data:get("auto_echo_layer2", false))
        end)
    end, true, "Start in Character Creator on a Deepbound origin - creates the character, gets the key, spawns the bonekeeper, and void chasers on repeat.")

    echo_options:newDropdown('soup_echofarm_origin', 'Soup Echo Farm Origin', {
        'Etris',
        'Vigil'
    }, 'Etris', false, 'The origin the "Soup" echo farm should start at.', function() end, true, true)

    
    local bosses_tabbox = self.tab:newTabbox("Bosses")
    local bosses_tab = bosses_tabbox:newTab("Bosses")
    local bosses_options = bosses_tabbox:newTab("Options")
    bosses_tab:newButton("Auto Layer 2", function()
        task.spawn(function()
            persistent_data:set("auto_layertwo_void_chaser", aztup_options.auto_layertwo_options.Value["Void Chaser (No EXP, only loot)"])
            persistent_data:set("auto_layertwo_kill_chaser", aztup_options.auto_layertwo_bosses.Value['Chaser'])
            persistent_data:set("auto_layertwo_kill_ethiron", aztup_options.auto_layertwo_bosses.Value['Ethiron'])
            persistent_data:set('auto_layertwo_killed_chaser', aztup_options.auto_layertwo_options.Value["Use Skip (requires chaser kills)"])
            persistent_data:set("auto_layertwo_allow_loops", aztup_options.auto_layertwo_options.Value["Allow Loops"])

            if aztup_options.auto_layertwo_options.Value["Void Chaser (No EXP, only loot)"] and not local_player.instance.Backpack:FindFirstChild("Mantra:ChokeIce{{Frost Grab}}") then
                return Logger:notify_sound("You need Frost Grab to use this void chaser!!")
            end;

            
            aztup.automation:set("auto_layertwo", not persistent_data:get("auto_layertwo", false))
        end)
    end, true, 'Automatically does layer two - only start in layer 2')
    bosses_tab:newButton("Auto Duke", function()
        task.spawn(function()
            persistent_data:set("auto_duke_voids", aztup_options.auto_duke_options.Value["Void Duke (No EXP, only loot)"])

            if aztup_options.auto_duke_options.Value["Void Duke (No EXP, only loot)"] and not local_player.instance.Backpack:FindFirstChild("Mantra:ChokeIce{{Frost Grab}}") then
                return Logger:notify_sound("You need Frost Grab to use this void duke!!")
            end;

            aztup.automation:set("auto_duke", not persistent_data:get("auto_duke", false));
        end)
    end, true, "Start anywhere in overworld. Unsafe on Low HP/DMG slots. Will not handle hunger / thirst, Note - Will combat log if players go near you in the first stage & WIP.");

    bosses_tab:newButton('Auto Ferryman', function()
        local backpack = local_player.instance:FindFirstChild("Backpack")
        local start = tick();
        local skipped = false;
        if not backpack or not backpack:FindFirstChild("Pickaxe") and not backpack:FindFirstChild("Umbral Flint") then
            Logger:notify_sound("You need a pickaxe in your inventory to use this feature!, Press Y in the next 5 seconds to ignore this warning.")
            while tick() - start < 5 do
                task.wait(0.1)
                skipped = skipped or services.UserInputService:IsKeyDown(Enum.KeyCode.Y)
                
                if skipped then
                    break
                end
            end
            
            if not skipped then
                return
            end
        end

        start = tick();
        skipped = false;

        if not backpack or not backpack:FindFirstChild("Lumber Axe") then
            Logger:notify_sound("You need a lumber axe in your inventory to use this feature!, Press Y in the next 5 seconds to ignore this warning.")
            while tick() - start < 5 do
                task.wait(0.1)
                skipped = skipped or services.UserInputService:IsKeyDown(Enum.KeyCode.Y)

                if skipped then
                    break
                end
            end

            if not skipped then
                return
            end
        end

        task.spawn(function()
            aztup.automation:set('auto_ferryman', not persistent_data:get('auto_ferryman', false))
        end)
    end, true, 'Start anywhere.')
    bosses_options:newDropdown('auto_layertwo_options', 'Options', {
        "Void Chaser (No EXP, only loot)",
        "Use Skip (requires chaser kills)",
        "Allow Loops",
        
    }, '', true, 'Select the options you would like for the "Auto L2" autofarm.', function() end, true, true)

    bosses_options:newDropdown('auto_layertwo_bosses', 'Bosses', {
        'Chaser',   
        'Ethiron', 
        
    }, 'Chaser', true, 'Select the bosses you wish to farm for the "Auto L2" autofarm.', function() end, true, true)
    bosses_options:newDropdown('auto_duke_options', 'Options', {
        "Void Duke (No EXP, only loot)"
    }, '', true, 'Select the bosses you wish to farm for the "Auto Duke" autofarm.', function() end, true, true)

    
    local utility_tabbox = self.tab:newTabbox("Utility")
    local utility = utility_tabbox:newTab("Utility")
    local utility_options = utility_tabbox:newTab("Options")

    if is_depths then
        utility:newButton("Escape Depths", function()
            task.spawn(function()
                persistent_data:set('escape_depths_hard_trial', aztup_options.escape_depths_difficulty.Value == "Hard Trial")
                aztup.automation:set('auto_escape_depths', not persistent_data:get('auto_escape_depths', false))
            end)
        end, true, "Does the Depths Trial to escape the Depths.")
    end;



    














if is_dungeon then
        task.spawn(function() 
            if workspace:FindFirstChild("One") or workspace:WaitForChild("One", 10) then
                utility:newButton("Auto Trial", function() 
                    task.spawn(pcall, function() aztup_toggles["no_fall"]:SetValue(true); end);
                    task.spawn(pcall, function() aztup_toggles["noclip"]:SetValue(true); end);
                    task.spawn(pcall, function() aztup_toggles["fly"]:SetValue(true); end);
                    task.spawn(pcall, function() aztup_toggles["no_fire"]:SetValue(true); end);
                    task.spawn(pcall, function() aztup_toggles["m1_hold"]:SetValue(true); end);
                    task.spawn(pcall, function() aztup_toggles["no_stun"]:SetValue(true); end);
                    task.spawn(pcall, function() aztup_toggles["fast_swing"]:SetValue(true); end);
                    task.spawn(pcall, function() aztup_toggles["auto_decline_guild_invites"]:SetValue(true); end);
                    task.spawn(pcall, function() aztup_toggles["auto_decline_squad_invites"]:SetValue(true); end);
                    task.spawn(pcall, function() aztup_toggles["auto_train_agility"]:SetValue(true); end);
                    task.spawn(pcall, function() aztup_toggles["knocked_ownership"]:SetValue(true); end);
                    require("@src/features/buttons/auto_trial")();
                end, true, "Does the Depths Trial to escape the Depths.")
            end;
        end);
    end;

    utility_options:newDropdown('escape_depths_difficulty', 'Trial Difficulty', {
        "Normal Trial",
        
    }, "Normal Trial", false, 'Automatically Escapes Depths', function() end)
end

function automation:make_config()
    local config_groupbox = self.tab:newGroupBox("Config", true);
    local label; 

    config_groupbox:newToggleGroup({
        {"allow_automation_use_solar",        "Allow Solar Enchant", true, "Allows automation to vent & properly use solar.", NoKeybind = true},
        {"allow_automation_use_attunements",  "Use Attunements", true, "Allows automation to cast your attunement mantra so the attunement trains.", NoKeybind = true},
    });
    

    
    

    config_groupbox:newButton("Wipe Current", function()
        persistent_data:wipe();
    end, "Your current automation will gracefully stop at its next cycle after running this.")

    config_groupbox:newButton("Create", function()
        local persistent_data_items = {
            ['auto_layertwo_turn_in_medallions'] = aztup_options.auto_layertwo_options.Value["Turn In Medallions"],
            ['auto_layertwo_killed_chaser'] = aztup_options.auto_layertwo_options.Value["Use Skip (requires chaser kills)"],
            ['auto_layertwo_allow_loops'] = aztup_options.auto_layertwo_options.Value["Allow Loops"],
            ["auto_titus_wipe_char"] = aztup_options.relic_farm_options.Value["Wipe Character"],
            ["use_guild"] = aztup_options.note_farm_options.Value["Use Guild"],
            ["auto_duke_voids"] = aztup_options.auto_duke_options.Value["Void Duke (No EXP, only loot)"],
        }

        for key, value in pairs(persistent_data_items) do
            persistent_data:set(key, value);
        end

        if not isfolder("Project Rain/automation_configs") then
            makefolder("Project Rain/automation_configs")
        end

        if aztup_options.automation_config_mode.Value == "File" then
            if not aztup_options.automation_config_name.Value or aztup_options.automation_config_name.Value == "" then
                Logger:notify_sound("Please enter a valid config name!")
                return
            end

            local config_name = aztup_options.automation_config_name.Value;
            local success, err = pcall(function()
                writefile("Project Rain/automation_configs/" .. config_name .. ".json", game:GetService("HttpService"):JSONEncode(persistent_data_items));
            end)

            if success then
                persistent_data:set("automation_config", config_name);
                label:SetText(string.format("Currently set to: %s", persistent_data:get("automation_config", "persistent")));
                Logger:notify_sound("Config saved successfully!")
            else
                Logger:notify_sound("Error saving config: " .. tostring(err))
            end
        else
            persistent_data:set("automation_config", "persistent");
            label:SetText(string.format("Currently set to: %s", persistent_data:get("automation_config", "persistent")));
            Logger:notify_sound("Config set to session successfully!")
        end
    end)

    local function load_config(config_name)
        local success, data = pcall(function()
            return readfile("Project Rain/automation_configs/" .. config_name .. ".json")        
end) 
        
        if success then
            persistent_data:set("automation_config", config_name);
            for key, value in pairs(services.HttpService:JSONDecode(data)) do
                persistent_data:set(key, value);
            end
        end;

        return success    
end

    local function set_bools()
        local bools = {
            'auto_layertwo_turn_in_medallions',
            'auto_layertwo_killed_chaser',
            "auto_titus_wipe_char",
            "use_guild",
            "auto_duke_voids",
            "auto_layertwo_allow_loops"
        }

        for _, bool in pairs(bools) do
            if persistent_data:get(bool, false) then
                if bool == "auto_layertwo_turn_in_medallions" then
                    aztup_options.auto_layertwo_options.Value["Turn In Medallions"] = true;
                    aztup_options.auto_layertwo_options:SetValue(aztup_options.auto_layertwo_options.Value)
                elseif bool == "auto_layertwo_killed_chaser" then
                    aztup_options.auto_layertwo_options.Value["Use Skip (requires chaser kills)"] = true;
                    aztup_options.auto_layertwo_options:SetValue(aztup_options.auto_layertwo_options.Value)
                elseif bool == "auto_layertwo_allow_loops" then
                    aztup_options.auto_layertwo_options.Value["Allow Loops"] = true;
                    aztup_options.auto_layertwo_options:SetValue(aztup_options.auto_layertwo_options.Value)
                elseif bool == "auto_titus_wipe_char" then
                    aztup_options.relic_farm_options.Value["Wipe Character"] = true;
                    aztup_options.relic_farm_options:SetValue(aztup_options.relic_farm_options.Value)
                elseif bool == "use_guild" then
                    aztup_options.note_farm_options.Value["Use Guild"] = true;
                    aztup_options.note_farm_options:SetValue(aztup_options.note_farm_options.Value)
                elseif bool == "auto_duke_voids" then
                    aztup_options.auto_duke_options.Value["Void Duke (No EXP, only loot)"] = true;
                    aztup_options.auto_duke_options:SetValue(aztup_options.auto_duke_options.Value)
                end
            end
        end
    end
    
    config_groupbox:newButton("Load", function()
        local config_name = aztup_options.automation_config_name.Value;
        local success, data = pcall(function()
            return readfile("Project Rain/automation_configs/" .. config_name .. ".json")        
end)

        if success then
            load_config(config_name);
            set_bools()
            Logger:notify_sound("Config loaded successfully!")
        else
            Logger:notify_sound("Error loading config: " .. tostring(data))
        end
    end)
    
    config_groupbox:newDropdown('automation_config_mode', 'Type', {
        'Session',
        'File',
    }, 'Session', false, 'Which type "Set" will use.')

    config_groupbox:newToggle("force_tween_speed", "Force Tween Speed", false, "Forces the tween speed to your preference.");
    config_groupbox:newToggle("force_no_tween_ping_comp", "Force No Tween Ping Compensation", false, "Forces the tween speed to not slowdown based on ping..");
    config_groupbox:newSlider("force_tween_speed_value", "Tween Speed", 250, 16, 250, 1, true, "studs/second");

    local item_loot_box = config_groupbox:newDependencyBox("automation_config_mode", "File");
    item_loot_box:newTextbox('automation_config_name', 'Name', false, '', nil, "What the automation config will set to, Stored @ 'workspace/Project Rain/automation_configs")
    
    label = config_groupbox:newLabel(string.format("Currently set to: %s", persistent_data:get("automation_config", "persistent"))); 
    xpcall(set_bools, function(...)
        warn("[set bools bad wtf]",...);
    end);
end

function automation:make_non_locked_farms()
    
    local ministry_tabbox = self.tab:newTabbox("Notes")
    local ministry = ministry_tabbox:newTab("Notes")
    local ministry_options = ministry_tabbox:newTab("Options")

    ministry:newButton('Ministry Note Farm', function()
        if services.ReplicatedStorage.Requests.Get:InvokeServer().MetaProg.Knowledge == 0 then
            return Logger:notify_sound("You need extra starting knowledge for this")
        end;

        return task.spawn(function()
            aztup.automation:set('ministry_notefarm', not persistent_data:get('ministry_notefarm', false))

            if persistent_data:get('ministry_notefarm', false) then
                
                persistent_data:remove('max_notes')
            end
        end)
    end, true, 'Start at Character Creation, Wipes you.')

    ministry_options:newDropdown('note_farm_options', 'Options', {
        "Use Guild"
    }, '', true, 'Select the options you would like for this autofarm.', function() end, true, true)

    
    local echo_tabbox = self.tab:newTabbox("Echoes", true)
    local echofarms = echo_tabbox:newTab("Echoes")
    local echo_options = echo_tabbox:newTab("Options")

    
    
    
    
    
    
    
    
    

    echofarms:newButton("Soup Echo Farm", function()
        task.spawn(function()
            persistent_data:set('soup_echo_farm_origin', aztup_options.soup_echofarm_origin.Value)
            persistent_data:set("started_farm_at", tick());
            persistent_data:set("cycle_count", 0)
            persistent_data:set("echoes_gained", 0)

            aztup.automation:set("soup_echofarm", not persistent_data:get("soup_echofarm", false))
        end)
    end, true, "Start anywhere, Automatically creates soup for echoes @ 3-4/m.")

    echo_options:newDropdown('soup_echofarm_origin', 'Soup Echo Farm Origin', {
        'Etris',
        'Vigil'
    }, 'Etris', false, 'The origin the "Soup" echo farm should start at.', function() end, true, true)
end;

function automation:create()
    self:make_general();
    self:make_webhooks();
    self:make_autoloot();
    self:make_config();

    if not is_regular then
        self:make_farms();
    else
        self:make_non_locked_farms();
    end;
end

return function(tab, groupbox)
    automation.tab = tab;
    automation.groupbox = groupbox;
    automation:create();
end, {
    name = "Automation"
}