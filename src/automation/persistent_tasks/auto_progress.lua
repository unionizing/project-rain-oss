if is_regular then
    return {
        run = function()
            local_player.instance:Kick("Attempted to start a beta-only automation whilst not on beta.");
            persistent_data:wipe();
        end
    }
end;

local webhook = require("@src/utility/webhook");
local AutoProgression = {};
AutoProgression.__index = AutoProgression;
AutoProgression.internal_state = persistent_data:get("auto_progression_internal", {
    state = "JUST_STARTED",
    data = {}
});
AutoProgression.internal_struct = {};
AutoProgression.current = setmetatable({}, {
    __index = function(_, key)
        return AutoProgression.internal_state[key];
    end,
    __newindex = function(_, key, value)
        AutoProgression.internal_state[key] = value;
    end,
    __call = function(type)
        if type == "wipe" then
            AutoProgression.internal_state = { 
                state = "NULL",
                data = {}
            };
        end
    end
})

AutoProgression.player_near = function()
    for _, player in services.Players:GetPlayers() do
        if local_player.instance == player then continue end
        if not player.Character then continue end
        if not player.Character:FindFirstChild('HumanoidRootPart') then continue end
        
        local dist = (local_player.root_part.Position - player.Character:GetPivot().Position).Magnitude
        if dist <= 400 then return true end
    end
    
    return false
end;

AutoProgression.server_hop = function()
    local axe = local_player.character and local_player.character:FindFirstChild('Lumber Axe');
    if axe then
        axe.Parent = local_player.instance.Backpack;
        task.wait(0.4);
    end
    local slot = local_player.instance:GetAttribute("DataSlot");
    server_utility:hop(slot, true, true)
end

function AutoProgression:set_state(state)
    local curr = AutoProgression.internal_state;
    curr.state = state;
    AutoProgression.internal_state = curr;
        
    persistent_data:set("auto_progression_internal", AutoProgression.internal_state);
end

function AutoProgression:set_data(data)
    local curr = AutoProgression.internal_state;
    curr.data = data;
    AutoProgression.internal_state = curr; 

    persistent_data:set("auto_progression_internal", AutoProgression.internal_state);
end

function AutoProgression:read_state()
    return AutoProgression.current.state;
end

function AutoProgression:read_data()
    return AutoProgression.current.data;
end

function AutoProgression:farm_tag()
    if not ab_builder.build_config then
        local wait_start = tick();
        repeat task.wait(0.5) until ab_builder.build_config or tick() - wait_start >= 15;
    end;

    local data = self:read_data();
end

function AutoProgression:set_farm(active)
    local flag = self:farm_tag();

    if active then
        aztup.automation:set(self:other_farm_tag(), false);
    end;

    aztup.automation:set(flag, active);
end

function AutoProgression:persist_farm(active)
    local flag = self:farm_tag();

    if active then
        persistent_data:set(self:other_farm_tag(), false);
    end;

    persistent_data:set(flag, active);
end

function AutoProgression:heal_at_campfire()
    local function equip_campfire()
        local equipped = local_player.character and local_player.character:FindFirstChild('Campfire Pit');
        if equipped then return equipped end;

        local stored = local_player.instance.Backpack:FindFirstChild('Campfire Pit');
        if not stored or not local_player.character then return nil end;

        stored.Parent = local_player.character;

        local start = tick();
        repeat task.wait() until (local_player.character and local_player.character:FindFirstChild('Campfire Pit')) or tick() - start >= 3;

        return local_player.character and local_player.character:FindFirstChild('Campfire Pit');
    end;

    local tool = equip_campfire();
    if tool then
        pcall(function() tool:Activate(); end);
        task.wait(1);
    end;

    local start = tick();
    repeat
        task.wait(0.3);

        local destructibles = workspace:FindFirstChild('Destructibles');
        local campfire, closest_dist = nil, math.huge;

        if destructibles then
            for _, c in destructibles:GetChildren() do
                if not c.Name:match('Campfire') then continue; end;

                local pivot = (c:IsA("Model") and c:GetPivot() or c).Position;
                local dist = (pivot - local_player.root_part.Position).Magnitude;

                if dist < closest_dist then
                    closest_dist = dist;
                    campfire = c;
                end;
            end;
        end;

        if campfire then
            local prompt = campfire:IsA("Model") and campfire:FindFirstChildWhichIsA("ProximityPrompt", true) or campfire:FindFirstChildWhichIsA("ProximityPrompt");
            if prompt then
                pcall(function() fireproximityprompt(prompt); end);
            end;
        end;
    until (local_player.humanoid and local_player.humanoid.Health >= local_player.humanoid.MaxHealth * 0.89)
        or tick() - start >= 60
        or not persistent_data:get('auto_progress', false);
end

function AutoProgression:has_ankle_weights_equipped()
    local character = local_player.character;
    if not character then return false end;

    local leg = character:FindFirstChild("Left Leg");
    if not leg then return false end;

    return leg:FindFirstChild("AnkleWeight") ~= nil;
end

function AutoProgression:equip_ankle_weights()
    if self:has_ankle_weights_equipped() then return end;
    if ab_builder:missing_for("Agility") <= 0 then return end;

    local character = local_player.character;
    if not character then return end;

    local backpack = local_player.instance:FindFirstChild('Backpack');
    local weights = (backpack and backpack:FindFirstChild('Ankle Weights')) or character:FindFirstChild('Ankle Weights');
    if not weights then return end;

    pcall(function()
        local_player.humanoid:EquipTool(weights);
        weights:Activate();

        task.wait(0.2);
        local_player.humanoid:UnequipTools();
    end);
end

function AutoProgression:points_awaiting()
    local ok, data = pcall(function()
        return require(services.ReplicatedStorage.Info.DataReplication).GetData();
    end);

    if not ok or not data then return 0 end;

    return tonumber(data.AttributePoints) or 0;
end

function AutoProgression:hit_nearest_mob_once()
    local live = workspace:FindFirstChild("Live");
    if not live then return end;
    if not local_player.character or not local_player.root_part then return end;

    local brutus_position = Vector3.new(-6985, 336, 3060);

    if (local_player.root_part.Position - brutus_position).Magnitude > 150 then return end;

    local players = {};
    for _, player in services.Players:GetPlayers() do
        if player.Character then
            players[player.Character] = true;
        end;
    end;

    local closest, closest_dist = nil, math.huge;

    if not closest then return end;

    local root = closest:FindFirstChild("HumanoidRootPart") or closest.PrimaryPart;

    pcall(function()
        local character_handler = local_player.character:FindFirstChild("CharacterHandler");
        if character_handler then
            character_handler.Requests.DrawWeapon:FireServer(true);
        end;
    end);

    Tween.new(root.CFrame, true, 200).wait();
    local_player.root_part.CFrame = root.CFrame;

    -- we gotta hit the mob because exp gets desynced lol - try twice since we just teleported in and the first swing can whiff
    for i = 1, 2 do
        local_player.root_part.CFrame = root.CFrame;

        aztup.features.m1_hold.held = true;
        task.wait(0.3);
        aztup.features.m1_hold.held = false;

        task.wait(0.3);
    end;

    -- we moved to the mob to hit it, so head back to brutus before continuing
    Tween.new(CFrame.new(brutus_position), true, 200).wait();
    local_player.root_part.CFrame = CFrame.new(brutus_position);
end

function AutoProgression:train_fortitude()
    aztup_toggles.noclip:SetValue(true);
    aztup_toggles.knocked_ownership:SetValue(true);
    aztup_toggles.jesus:SetValue(true);

    local playercheck = task.spawn(function()
        while task.wait() do
            if self.player_near() then
                self.server_hop()
            end
        end
    end)
    
    self:equip_ankle_weights();
        
    Tween.new(CFrame.new(-6985, 336, 3060), true, 200).wait();

    self:hit_nearest_mob_once();

    if self:points_awaiting() <= 0 then return end;

    aztup_toggles.auto_brutus:SetValue(true);

    local start = tick();
    repeat
        self:equip_ankle_weights(); 
        task.wait(1);
    until self:points_awaiting() <= 0
        or ab_builder:missing_for("Fortitude") <= 0
        or tick() - start >= 120
        or not persistent_data:get('auto_progress', false);

    aztup_toggles.auto_brutus:SetValue(false);

    if not persistent_data:get('auto_progress', false) then return; end;

    self:equip_ankle_weights();
    Tween.new(CFrame.new(-6698, 914, 3576), true, 200).wait();

    self:heal_at_campfire();

    return playercheck;
end

function AutoProgression:maybe_train_fortitude(force)
    local flag = self:farm_tag();
    if flag ~= "auto_ferryman" then return false end;
    if is_dungeon then return false end;

    local missing = ab_builder:missing_for("Fortitude");
    if not force and missing <= 0 then return false end;
    if self:points_awaiting() <= 0 then return false end;

    self:persist_farm(false);
    self:set_state("DOING_AUTO_BRUTUS");

    server_utility:rejoin(local_player.instance:GetAttribute("DataSlot") or "A");

    return true;
end

function AutoProgression:resume_from_depths()
    local data = self:read_data();
    local return_to = data.escape_depths_return_to;

    if not return_to or return_to == "JUST_STARTED" or return_to == "ESCAPING_DEPTHS" then
        return_to = "DOING_AUTO_FERRYMAN";
    end;

    data.escape_depths_return_to = nil;
    self:set_data(data);
    self:set_state(return_to);

    return return_to;
end

function AutoProgression:power()
    local character = local_player.character;
    if not character then return nil end

    local points = 0;
    for name, value in character:GetAttributes() do
        if typeof(value) == "number" and name:match("Stat") then
            points += value;
        end;
    end;

    local power = 0;
    for _ = 1, 20 do
        if points <= 15 then break end;

        points -= 15;
        power += 1;
    end;

    return math.min(20, math.max(1, power));
end

function AutoProgression:should_do_trial()
    if is_eastern then return false end;

    local origin;
    pcall(function()
        origin = game:GetService("ReplicatedStorage").Requests.Get:InvokeServer().Origin;
    end);

    if origin == "Deepbound" then return false end;

    local power = self:power();
    if not power then return false end;

    return power <= 1;
end

function AutoProgression:import_build()
    local url = persistent_data:get("auto_progress_url", "");
    if url == "" then
        return false;
    end

    local requests = services.ReplicatedStorage:FindFirstChild("Requests");
    local build_maker = requests and requests:FindFirstChild("BuildMaker");
    local import_build = build_maker and build_maker:FindFirstChild("ImportBuild");

    if not import_build then
        return false;
    end

    local ok, result = pcall(function()
        return import_build:InvokeServer(url);
    end);

    if ok then
        self:unlock_attributes();
    end;

    return ok;
end

function AutoProgression:unlock_attributes()
    local requests = services.ReplicatedStorage:FindFirstChild("Requests");
    if not requests then return false end;

    local lock_attribute = requests:FindFirstChild("LockAttribute");
    local limit_attribute = requests:FindFirstChild("LimitAttribute");

    if not lock_attribute and not limit_attribute then return false end;

    local data;
    pcall(function()
        data = base_require(services.ReplicatedStorage.Info.DataReplication).GetData();
    end);

    local locked = (data and data.LockedAttributes) or {};
    local limits = (data and data.AttributeLimits) or {};

    for _, attribute in {
        "Strength",
        "Fortitude",
        "Agility",
        "Intelligence",
        "Willpower",
        "Charisma",
        "WeaponHeavy",
        "WeaponMedium",
        "WeaponLight",
        "ElementFire",
        "ElementIce",
        "ElementLightning",
        "ElementWind",
        "ElementShadow",
        "ElementMetal",
        "ElementBlood",
    } do
        if lock_attribute and locked[attribute] then
            pcall(function()
                lock_attribute:InvokeServer(attribute, false);
            end);

            task.wait(0.05);
        end;
    end;

    return true;
end

function AutoProgression:manual_shrine()
    Library:Notify("Please click this button when you have shrined and finished up.", 9e9)
    local button = Instance.new("TextButton", services.CoreGui.RobloxGui);
    button.Size = UDim2.fromOffset(200, 50)
    button.Position = UDim2.fromScale(0.1, 0.5)
    button.AnchorPoint = Vector2.new(0.5, 0.5)
            
    button.BackgroundTransparency = 0.5
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = "I have shrined."
    button.Activated:Wait();

    local data = self:read_data();
    data.shrined = true;
    self:set_data(data)
    self:set_state("DOING_AUTO_FERRYMAN");
    local stored = persistent_data:get("auto_progression_internal", {});
    Logger.log(string.format("[auto progression] shrined saved as %s", tostring(stored.data and stored.data.shrined)));
    print(string.format("[auto progression] shrined saved as %s", tostring(stored.data and stored.data.shrined)));
    
    self:set_farm(true);

    server_utility:rejoin(local_player.instance:GetAttribute("DataSlot") or "A");
end;

function AutoProgression:start()
    local state = self:read_state();
    local data = self:read_data();
    Logger.log("[auto progression] starting with state: " .. state);

    if aztup.flags.auto_progress_shrined and not data.shrined then
        data.shrined = true;
        self:set_data(data);
    end;

    ab_builder.shrined = data.shrined == true;
    print(string.format("[auto progression] state %s | shrined %s", state, tostring(ab_builder.shrined)));

    self:unlock_attributes();

    task.spawn(function()
        if state == 'JUST_STARTED' then return; end

        if state == 'WAITING_MANUAL_SHRINE' then return; end

        ab_builder.url_override = persistent_data:get("auto_progress_url", "");

        ab_builder:build();
        ab_builder:put_points();
    end);

    if is_depths then
        aztup.automation:set('auto_escape_depths', true)
        if state ~= "ESCAPING_DEPTHS" then
            data.escape_depths_return_to = state;
            self:set_data(data)
            self:set_state("ESCAPING_DEPTHS")
        end;

        return;
    elseif state == "ESCAPING_DEPTHS" then
        state = self:resume_from_depths();
    end;
    if is_etrean and state == "DOING_AUTO_FERRYMAN" then
        self:persist_farm(true);
        require("@src/features/buttons/teleports/eastern")();
        return true;
    end;

    if state == "JUST_STARTED" then
        --check if the user is in character creation, if not we will be stuck in the JUST_STARTED state and not progress at all, therefor cancelling
        local character_creator = workspace:FindFirstChild('CharacterCreator');
        local character_parent = local_player.character and local_player.character.Parent;
        local game_loaded = local_player.instance:GetAttribute("GameLoaded");

        local in_character_creation = character_creator and character_parent == character_creator or game_loaded == "CharacterCreation";


        self:set_state("WAITING_ON_TRIAL_OF_ONE");
        --AutoProgression.internal_struct:create_character();
        Logger:long_notify_sound("Please create your character.");

        local waited = 0;
        repeat
            task.wait(1)
            waited += 1;

            if waited % 10 == 0 then
                print(string.format("[auto progression] waiting on character | parent %s | GameLoaded %s",
                    tostring(local_player.character and local_player.character.Parent and local_player.character.Parent.Name),
                    tostring(local_player.instance:GetAttribute("GameLoaded"))));
            end
        until (local_player.character
            and local_player.character.Parent
            and local_player.character.Parent.Name == "Live")
            or not persistent_data:get('auto_progress', false);

        if not persistent_data:get('auto_progress', false) then return true; end
        task.spawn(pcall, function() --note: SOMETIMES WE GET STUCK HERE, MAYBE THE USER DIDNT SELECT TRIAL OF ONE?
            repeat
                task.wait(1)
            until (local_player.character
                and local_player.character.Parent
                and local_player.character.Parent.Name == "Live")
                or not persistent_data:get('auto_progress', false);

            if not persistent_data:get('auto_progress', false) then return; end

            self:import_build();
            if self:should_do_trial() then
                require("@src/features/buttons/teleports/trial")()
            else
                self:set_state("DOING_AUTO_FERRYMAN");
                self:set_farm(true);
            end;
        end)
    elseif state == "WAITING_ON_TRIAL_OF_ONE" and is_dungeon then
        self:set_state("DOING_TRIAL_OF_ONE");
        require("@src/features/buttons/auto_trial")();
    elseif state == "WAITING_ON_TRIAL_OF_ONE" then
        require("@src/features/buttons/teleports/trial")();

        local waiting_since = tick();
        repeat
            task.wait(1)
        until tick() - waiting_since >= 30 or not persistent_data:get('auto_progress', false);

        if persistent_data:get('auto_progress', false) then
            print("[auto progression] couldnt reach the trial, doing the ferryman instead");

            self:set_state("DOING_AUTO_FERRYMAN");
            self:persist_farm(true);
            server_utility:rejoin(local_player.instance:GetAttribute("DataSlot") or "A");
        end;
    elseif state == "DOING_TRIAL_OF_ONE" and is_etrean then
        self:set_state("DOING_AUTO_FERRYMAN");
        self:set_farm(true);
    elseif state == "DOING_AUTO_BRUTUS" then
        data.brutus_attempts = (data.brutus_attempts or 0) + 1;
        self:set_data(data);

        if data.brutus_attempts <= 3 then
            self:train_fortitude();
        end;

        data.brutus_attempts = 0;
        self:set_data(data);

        self:set_state("DOING_AUTO_FERRYMAN");
        self:set_farm(true);
    elseif state == "DOING_AUTO_FERRYMAN" then
        if not persistent_data:get(self:farm_tag(), false) then
            self:set_farm(true);
        end;

        --boilerplate
        task.wait(2);
        local waiting_since = tick();
        repeat task.wait(0.5) until ab_builder.build_config or tick() - waiting_since >= 15;

        if self:farm_tag() == "auto_ferryman" and not self.ferryman_watch_started then
            self.ferryman_watch_started = true;

            if not data.ferryman_baseline then
                data.ferryman_baseline = persistent_data:get('ferryman_rounds_completed', 0);
                self:set_data(data);
            end;

            task.spawn(function()
        
                while persistent_data:get('auto_progress', false) and self:read_state() == "DOING_AUTO_FERRYMAN" do
                    task.wait(3);
--
                    if self:farm_tag() ~= "auto_ferryman" then break; end;
--
                    local baseline = self:read_data().ferryman_baseline or 0;
                    local completed = persistent_data:get('ferryman_rounds_completed', 0) - baseline;
--
                    if completed >= 2 then
                        local d = self:read_data();
                        d.ferryman_baseline = persistent_data:get('ferryman_rounds_completed', 0);
                        self:set_data(d);
--
                        self:maybe_train_fortitude(false);
                    end;
                end;
--
                self.ferryman_watch_started = false;
            end);
        end;--

        if ab_builder:shrine_ready() and not ab_builder.shrined then
            self:set_farm(false);
            
            webhook:send_webhook("Auto Progression", "Ready for shrine. Please manually use your shrines & grab what you need.", "@everyone");
            local_player.instance:Kick("Ready for shrine. Please manually use your shrines & grab what you need.");
            getgenv().dont_auto_hop_pls = true;
            self:set_state("WAITING_MANUAL_SHRINE")
        elseif not ab_builder.shrined and not self.shrine_watch_started then
            self.shrine_watch_started = true;

            task.spawn(function()
                while persistent_data:get('auto_progress', false) and self:read_state() == "DOING_AUTO_FERRYMAN" do
                    task.wait(3);

                    if ab_builder.shrined then break; end;

                    if ab_builder:shrine_ready() then
                        self:set_farm(false);
                        local_player.instance:Kick("Ready for shrine. Please manually use your shrines & grab what you need.");
                        self:set_state("WAITING_MANUAL_SHRINE");
                        break;
                    end;
                end;

                self.shrine_watch_started = false;
            end);
        end;

        local finished, missing = ab_builder:finished();
        if finished then
            self:set_farm(false);
            self:set_state("DONE");
            persistent_data:wipe();

            webhook:send_webhook("Auto Progression", "@everyone Auto progression has finished up. :), Clean up using shrines.");
            local_player.instance:Kick("Auto progression has finished up. :), Clean up using shrines.");
            getgenv().dont_auto_hop_pls = true;
        elseif missing > 0 then
            print(string.format("[auto progression] %i stat points left on the build", missing));
        end;
    elseif state == "WAITING_MANUAL_SHRINE" then
        ab_builder:points_killswitch();

        self:manual_shrine();
    else
        local edge_case_warn = string.format("Reached possible edge-case @ %i | %s (do not restart the auto progression this way...)", game.PlaceId, state);
        Logger.warn(edge_case_warn);
        Logger:long_notify(edge_case_warn);
    end

    return true;
end

local started = false;
AutoProgression.internal_struct = require("@src/automation/struct"):construct({
    persistent_data_flag = 'auto_progress',
    id = 'auto_progress',
    
    state_machine = {
        start = function()
            if started then return; end

            started = true;
            AutoProgression:start();
        end
    },
    features = {
        "no_fall",
        "noclip",
        "fly",
        "no_fire",
        "m1_hold",
        "no_stun",
        "fast_swing",
        "auto_decline_guild_invites",
        "auto_decline_squad_invites",
        "auto_train_agility",
        "knocked_ownership",
        "auto_equip_weapon"
    },
    
    not_allowed = function()
        local state = AutoProgression:read_state();
        local data = AutoProgression:read_data();

        if state == "WAITING_MANUAL_SHRINE" then
            task.spawn(function() 
                AutoProgression:manual_shrine();
            end);

            return true;
        end;

        return started;
    end,
    
    character_creator_handler_used = true,
    character_creator_handler_opts = {
        gamemode = "Pathfinder"
        -- We shouldn't decide on the origin.
    },

    on_run = function()
        aztup.flags.block_input = true;
        aztup_options.blocked_safe_input_user_moves.Value.M1s = true;
        aztup_options.bi_punishable_type.Value = "Always";
    end
})

AutoProgression.internal_struct.resume_from_depths = function()
    if AutoProgression:read_state() ~= "ESCAPING_DEPTHS" then
        return;
    end;

    return AutoProgression:resume_from_depths();
end;

AutoProgression.internal_struct.initialize = function(state, data)
    AutoProgression:set_data(data);
    AutoProgression:set_state(state);
end;

return AutoProgression.internal_struct;