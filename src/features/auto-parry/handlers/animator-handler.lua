local profiler = require("@src/utility/profiler")
local anti_ap_breaker = require("@src/features/auto-parry/handlers/anti-ap-breaker")

local random = Random.new();
local cached = {};
function getInfo(id)
    local success, info = pcall(function()
        if not cached[id] then
            cached[id] = game:GetService("MarketplaceService"):GetProductInfo(id);
        end
        return cached[id]
    end)
    if success then
        return info
    end
    return {Name=''}
end

local encrypted_timing_data = require("@src/features/auto-parry/data/encrypted_timing_data");
local custom_timings = require("@src/features/auto-parry/data/custom_timings");
local ap_breaker_tracks = setmetatable({}, { __mode = "k" });

break_anims = function(track, time, data, action_type, self)
    if not data then return end
    if track:HasTag("PR_BREAKER_IGNORE") then return end

    if aztup.flags.ap_breaker and aztup_options.ap_breaker_type.Value == "Tester Aggressive 1 (Blatant)" and not track.Looped and track.Speed > 0.1 then
        while track.IsPlaying do
            
            
            
            
            
            

            track:AdjustWeight(0, 50);
            
            task.wait();
        end;
    end;

    if aztup.flags.ap_breaker and aztup_options.ap_breaker_type.Value == "Aggressive 3 (Blatant)" and not track.Looped and track.Speed > 0.1 then
        ap_breaker_tracks[track] = true;
        track.Priority = Enum.AnimationPriority.Movement;
        
        
        track:Stop(9e9);
        task.wait((track.Length / track.Speed) - Latency:half_ping());
        track.TimePosition = track.Length;
        track:Play(0.1,0,0)
        track:AdjustWeight(0, 0.1);
        ap_breaker_tracks[track] = nil;
    end;
end;

process = function(timing_data)
    for index, item in encrypted_timing_data.keys do
        if timing_data[item] or not timing_data[index] then continue end
        timing_data[item] = timing_data[index];
        timing_data[index] = nil;
    end

    timing_data.actions = table.clone(timing_data.actions);
    for timing_number, action in timing_data.actions do
        if not action then continue end
        
        action = table.clone(action);
        for index, item in encrypted_timing_data.action_keys do
            if action[item] or not action[index] then continue end
            action[item] = action[index];
            action[index] = nil;
        end

        if action.when then
            action.when = action.when - encrypted_timing_data.key;
        end

        timing_data.actions[timing_number] = action;
    end

    timing_data.enc = false;
    return timing_data 
end

local track_still_active

track_still_active = LPH_JIT_MAX(function(track: AnimationTrack, entity)
    if ap_breaker_tracks[track] then
        return true    
end;

    return track.IsPlaying or anti_ap_breaker:is_fully_dead(track, entity) == false
end)

return LPH_NO_VIRTUALIZE(function()
    local last_mid_attack_delay = 0;
    local AnimatorHandler = {};
    AnimatorHandler.__index = AnimatorHandler;
    local Keybinds = base_require(game:GetService("ReplicatedStorage"):WaitForChild("KeyBinds"..""));
    local data = require("@src/features/auto-parry/data/base");
    local timing_data = {};
    for index, timing in data do
        if typeof(timing) ~= "table" then continue end
        timing_data[timing.name or index] = timing;
    end; 

    local function debug_print(...)
        if not (aztup and aztup.flags and aztup.flags.auto_parry_debug) then return end
        setthreadidentity(8)
        Logger:short_notify(string.format(...))
    end

    local in_parry_frames = false;
    local in_dodge_frames = false;
    local self_anim_data = {};  

    local allAnimations = {};
    local mobsAnims = {};
    do
        local animsFolder = services.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Anims");
        local mobsAnimsFolder = animsFolder:WaitForChild("Mobs");

        local match, format = string.match, string.format;

        
        local mobAnimObjects = mobsAnimsFolder:QueryDescendants("Animation");
        local allAnimObjects = animsFolder:QueryDescendants("Animation");

        
        
        local isMobAnim = {};
        for _, v in mobAnimObjects do
            isMobAnim[v] = true;
        end;

        local mobIds, nonMobIds = {}, {};

        for _, v in allAnimObjects do
            local animationId = match(v.AnimationId, '%d+');
            if not animationId then continue end;

            allAnimations[animationId] = format('%s-%s', v.Parent.Name, v.Name);

            if isMobAnim[v] then
                mobIds[animationId] = true;
            else
                nonMobIds[animationId] = true;
            end;
        end;

        
        local n = 0;
        for animationId in mobIds do
            if nonMobIds[animationId] then continue end;
            n += 1;
            mobsAnims[animationId] = true;
        end;

        mobsAnims["11508725111"] = true;
        mobsAnims["11710290503"] = true;
        mobsAnims["6428519131"] = true;
	    mobsAnims["129800120542781"] = true;
	    mobsAnims["6501497627"] = true;
	    mobsAnims["82335285372711"] = true;
	    mobsAnims["106886961189983"] = true;
    end;

    local last_payback_delay_time = 0;

    local fast_timing_lookup_table = {};

    local function create_fast_timing_lookup_table()
        table.clear(fast_timing_lookup_table);
        
        
        for pass = 1, 2 do
            for index, timing in timing_data do
                if not timing.ids or (timing.run ~= nil) ~= (pass == 1) then continue end;
                for _, id in next, timing.ids do
                    fast_timing_lookup_table[id] = index; 
                end;
            end;
        end;

        ap_breaker_tbl = fast_timing_lookup_table;
    end
    ap_breaker_tbl = fast_timing_lookup_table;

    if not LPH_OBFUSCATED then
        getgenv().mob_anims = mobsAnims;
    end;

    if can_edit_internal_timings then
        getgenv().fast_timing_lookup_table = fast_timing_lookup_table;
        getgenv().timings = timing_data;
        
        getgenv().remove_timing = function(name)
            timing_data[name] = nil;
            create_fast_timing_lookup_table();
        end;
    end;

    
    getgenv().timing_names = function()
        local list = {};
        for index, timing in timing_data do
            local str = typeof(index) == "string" and index or timing.name or timing.actions and timing.actions[1] and timing.actions[1].name;
            if str then table.insert(list, str); end;
        end;
        for name in custom_timings:sync() do
            table.insert(list, name);
        end;
        return list    
end;
    
    getgenv().load_timings = function(b)
        (aztup and aztup.silent_mode and function() end or debug.profilebegin)("reload timings");
        local a = 0;
        for _, file in ipairs(listfiles("rw_timings")) do
            if not isfile(file) then continue end 
            local src = readfile(file);
            local old_file = file; 
            file = file:gsub("rw_timings", ""):gsub("/",""):gsub("\\", ""):gsub(".lua", ""):gsub(".json", "");
            if timing_data[file] and timing_data[file].src == src then continue end
    
            if old_file:match(".lua") then
                local func, reason = loadstring(src, file);
                if not func then 
                    warn("Failed to load timing file: "..file, reason);
                    continue                
end
            
                local success, result = pcall(func);
                if not success then
                    warn("Failed to run timing file XPCALL: "..file, result);
                    continue                
end
            
                timing_data[file] = result
            elseif old_file:match(".json") then
                timing_data[file] = services.HttpService:JSONDecode(src);
            end;
    
            timing_data[file].src = src;
            a += 1;
        end
        (aztup and aztup.silent_mode and function() end or debug.profileend)();
        create_fast_timing_lookup_table();
    end
    
    pcall(function()
        if not isfolder("rw_timings") then
            makefolder("rw_timings");
        end;

        if not can_edit_internal_timings and not getgenv().allowed_to_load_timings then return create_fast_timing_lookup_table()end
        
        return getgenv().load_timings(true)    
end);
    
    if not LPH_OBFUSCATED and not is_chime then
        local last_update = tick();
        aztup.maid:give_task(services.RunService.RenderStepped:Connect(function()   
            if tick() - last_update <= 0.5 then return end
            if not getgenv().dev_tools_data or not getgenv().dev_tools_data["hot-reload-timings"] then return end
            if not services.UserInputService:IsKeyDown(Enum.KeyCode.Backquote) then return end

            Logger:notify_sound("Reloaded timings.");
            last_update = tick();
            xpcall(getgenv().load_timings, warn);
            last_update = tick();
        end));   
    end;

    function debug_print(...)
        if not aztup.flags.auto_parry_debug then return end
        
        setthreadidentity(8);
        Logger:short_notify(string.format(...));
    end;
    
    local added = {};
    function AnimatorHandler.new(entity: Model)
        local self = setmetatable({}, AnimatorHandler);
        if added[entity] then
            
            added[entity].ancestry:Disconnect();
            added[entity].ancestry = nil;
            
            added[entity].played:Disconnect();
            added[entity].played = nil;
            
            added[entity].descendant_added:Disconnect();
            added[entity].descendant_added = nil;

            if added[entity].feint_playing then
                added[entity].feint_playing:Disconnect();
                added[entity].feint_playing = nil; 
            end;
 
            added[entity] = nil;
        end
        self.animator = entity:FindFirstChild("Animator", true);
        self.entity = entity;
        self.humanoid = self.entity:FindFirstChild("Humanoid");
        self.evaluation_data = {};
        self.flag = self.entity.Name:sub(1,1) == "." and "pve_" or "pvp_"
        self.is_player = services.Players:GetPlayerFromCharacter(entity) ~= nil;
        self.player = services.Players:GetPlayerFromCharacter(entity);
        self.running_tracks = setmetatable({}, { __mode = "k" }); 
        self.last_feint_at = 0;
        added[entity] = self;
        self.ancestry = entity.AncestryChanged:Connect(function(_, parent)
            if not parent then
                added[entity] = nil;
                self.ancestry:Disconnect();
                self.ancestry = nil;
                
                self.played:Disconnect();
                self.played = nil;
                
                self.descendant_added:Disconnect(); 
                self.descendant_added = nil;

                if self.feint_playing then
                    self.feint_playing:Disconnect();
                    self.feint_playing = nil;
                end;
            end;
        end);

        self.hits = {};
        self.descendant_added = self.entity.DescendantAdded:Connect(function(child)
            if child.Name == "PunchBlood" or child.Name == "PunchEffect" or child.Name == "BloodSpray" or (child:IsA("ParticleEmitter") and child.Texture == "rbxassetid://7216855595") then	
                local id = table.insert(self.hits, {})
                task.delay(0.2, function()
                    table.remove(self.hits, id)
                end)
                return            
end

            if child.Name == "REP_SOUND_1241766316" then
                self:cancel_gale_feinted_tracks(self.entity.Humanoid:GetPlayingAnimationTracks());
            end

            if child.Name == "Feint" and child:IsA("Sound") then
                if self.feint_playing then
                    self.feint_playing:Disconnect();
                    self.feint_playing = nil;
                end;

                self.feint_playing = child:GetPropertyChangedSignal("Playing"):Connect(function()
                    if child.IsPlaying then
                        self:cancel_feinted_tracks(self.animator:GetPlayingAnimationTracks());
                    end;
                end);
                aztup.maid[services.HttpService:GenerateGUID(false)] = self.feint_playing;
                return            
end;

            local fake_strike = child.Name == "REP_SOUND_5115545256" and tostring(child.PlaybackSpeed) == "2";
            if child.Name ~= "REP_SOUND_4954198253" and not fake_strike then return end;

            self:cancel_feinted_tracks(self.animator:GetPlayingAnimationTracks());
        end);

        self.played = self.animator.AnimationPlayed:Connect(profiler.wrap("animator_handler::run", function(track)
            self:run(track);
        end));
    
        aztup.maid[services.HttpService:GenerateGUID(false)] = self.played;
        aztup.maid[services.HttpService:GenerateGUID(false)] = self.descendant_added;
        aztup.maid[services.HttpService:GenerateGUID(false)] = self.ancestry;

        return self    
end

    
    
    
    
    
    
    function AnimatorHandler:track_cleanup(track, fn)
        local state = self.running_tracks[track];
        if not state then return end
        table.insert(state.cleanups, fn);
    end

    function AnimatorHandler:track_feint_thread(track, thread)
        local state = self.running_tracks[track];
        if not state then return end
        table.insert(state.feint_threads, thread);
    end

    function AnimatorHandler:untrack_feint_thread(track, thread)
        local state = self.running_tracks[track];
        if not state then return end
        local index = table.find(state.feint_threads, thread);
        if index then
            table.remove(state.feint_threads, index);
        end
    end

    
    
    function AnimatorHandler:cancel_running_track(track)
        local state = self.running_tracks[track];
        if not state then return end
        self.running_tracks[track] = nil;

        for _, cleanup in state.cleanups do
            pcall(cleanup);
        end

        if state.thread and coroutine.status(state.thread) ~= "dead" then
            task.cancel(state.thread);
        end

        for _, thread in state.feint_threads do
            if coroutine.status(thread) ~= "dead" then
                task.cancel(thread);
            end
        end
    end

    
    
    
    
    function AnimatorHandler:cancel_feinted_tracks(playing_tracks)
        self.last_feint_at = tick();

        for _, track in playing_tracks do
            local state = self.running_tracks[track];
            if not state then continue end

            local action = state.action;
            if action and action.ignore_feints then continue end

            if state.action_type == "M1" and aztup.flags.ap_randomization and math.random() * 100 <= aztup.flags.bluff_feint_chance then
                debug_print("[Auto Feint] Bluffing through a detected feint.");
                continue            
end

            self:cancel_running_track(track);
        end
    end

    
    
    function AnimatorHandler:cancel_gale_feinted_tracks(playing_tracks)
        for _, track in playing_tracks do
            local state = self.running_tracks[track];
            if not state or not state.action or not state.action.detect_gale_feint then continue end

            self:cancel_running_track(track);
        end
    end

    function AnimatorHandler:in_hitbox_with_pos(root_pos: CFrame, enemy_pos: CFrame, hitbox: Vector3, offset: CFrame, hidden: boolean?)
        return general:in_hitbox_with_pos(root_pos, enemy_pos, hitbox, offset, hidden, self.ball)
    end


    local position_prediction_service = require("@src/features/auto-parry/services/position_prediction_service");
    function AnimatorHandler:in_hitbox(hitbox: Vector3, offset: CFrame, hidden: boolean?, predict, predict_time, predict_rotation, base_predict)  
        local predicted_pos_us = position_prediction_service.our_predicted_position(); 
        local predicted_other_pos, dbg = position_prediction_service.predict(self.player, (Latency:get_ping() + (predict_time and typeof(predict_time) == "number" and predict_time or 0)) + 0.5, {
            predict_rotation = predict_rotation
        })

        local other_pos = predicted_other_pos or self.entity:FindFirstChild("HumanoidRootPart") and self.entity.HumanoidRootPart.CFrame or CFrame.new();

        if not predict then
            return general:in_hitbox_with_pos(local_player.root_part.CFrame, self.entity.HumanoidRootPart.CFrame, hitbox, offset, hidden, self.ball)
        end;

        local predicted = general:in_hitbox_with_pos(predicted_pos_us, other_pos, hitbox, offset, hidden, self.ball, Color3.fromRGB(205, 119, 255), Color3.fromRGB(255, 165, 130));
        local base = base_predict and general:in_hitbox_with_pos(local_player.root_part.CFrame, self.entity.HumanoidRootPart.CFrame, hitbox, offset, hidden, self.ball);

        return base or predicted 
        
    end;
    local tasks = 0;

    local action_builder = require("@src/features/auto-parry/data/action")

    
    
    
    
    

    
    
    
    
    







































































































local function create_block_input_task(self, track, action, data, action_type, name, time, alotted, ignore_anim_early_end, blocked_bi, start, in_hitbox)
        if not (data.allow_block_input and not aztup_options.blocked_safe_input_moves.Value["Animations"] and not blocked_bi) then
            return { remove = function() end }        
end

        return BlockInputManager:add_task(
            name,
            self.entity,
            function()
                if not action.ignore_early_end and not track_still_active(track, self.entity) and not ignore_anim_early_end then return end
                if EffectReplicator:FindEffect("Knocked") then return end;

                if not action.ignore_hitbox and not in_hitbox(true) then
                    return                
end;

                if
                    not data.dont_skip_mob_block_break
                    and self.entity:FindFirstChild("MegalodauntBroken", true)
                    and not services.Players:GetPlayerFromCharacter(self.entity)
                    and aztup_options.filters.Value["Dont Parry If Mob Block Broken"]
                then
                    return                
end

                if aztup_options.filters.Value["Dont Parry If Not Mob Target"] and self.entity.Name:sub(1, 1) == "." and self.entity:FindFirstChild("Target") then
                    if self.entity:FindFirstChild("Target").Value ~= local_player.character and not action.ignore_other_target then
                        return                    
end;
                end;

                if EffectReplicator:FindEffect("Knocked") and aztup_options.filters.Value["Dont Parry If Knocked"] then
                    return                
end;

                local type = aztup_options.bi_punishable_type.Value;

                if type == "Custom" then
                    return tick() - start >= (time - alotted) - (aztup.flags.bi_punishable_time / 1000)                
elseif type == "Dynamic" then
                    
                    return tick() - start >= (time - alotted) - (last_mid_attack_delay + (aztup.flags.extra_bi_punishable_time / 1000))                
end

                return true            
end
        )    
end

    
    
    
    
    local function check_action_preconditions_auto_feint(self, track, action, data, action_type, name, index, in_hitbox)
        if not action.ignore_hitbox and not in_hitbox(true) then
            return true        
end;

        if action.cancelled then
            return true        
end

        if
            not data.dont_skip_mob_block_break
            and self.entity:FindFirstChild("MegalodauntBroken", true)
            and not services.Players:GetPlayerFromCharacter(self.entity)
            and aztup_options.filters.Value["Dont Parry If Mob Block Broken"]
        then
            return true        
end

        if aztup_options.filters.Value["Dont Parry If Not Mob Target"] and self.entity.Name:sub(1, 1) == "." and self.entity:FindFirstChild("Target") then
            if self.entity:FindFirstChild("Target").Value ~= local_player.character and not action.ignore_other_target then
                return true            
end;
        end;

        if EffectReplicator:FindEffect("Knocked") and aztup_options.filters.Value["Dont Parry If Knocked"] then
            return true        
end;

        return false    
end

    
    
    
    
    local function check_action_preconditions(self, track, action, data, action_type, name, index, in_hitbox)
        if not action.ignore_hitbox and not in_hitbox(false) then
            return true        
end;

        if action.cancelled then
            debug_print("[%s] skipping action %s due to module-based cancellation", name, action_type);
            return true        
end

        if
            not data.dont_skip_mob_block_break
            and self.entity:FindFirstChild("MegalodauntBroken", true)
            and not services.Players:GetPlayerFromCharacter(self.entity)
            and aztup_options.filters.Value["Dont Parry If Mob Block Broken"]
        then
            debug_print("[%s] Entity is block broken, skipping action %s", name, action_type);
            return true        
end

        if aztup_options.filters.Value["Dont Parry If Not Mob Target"] and self.entity.Name:sub(1, 1) == "." and self.entity:FindFirstChild("Target") then
            if self.entity:FindFirstChild("Target").Value ~= local_player.character and not action.ignore_other_target then
                debug_print("[%s] Mob is targeting someone else, skipping action %s", name, action_type);
                return true            
end;
        end;

        if EffectReplicator:FindEffect("Knocked") and aztup_options.filters.Value["Dont Parry If Knocked"] then
            debug_print("[%s] Knocked, Skipping action %s", name, action_type);
            return true        
end;

        return false    
end

    
    
    
    
    
    local function check_action_situation_filters(self, track, action, action_type, name, index)
        if aztup_options.filters.Value["Dont Parry If Holding Block"] and Keybinds.IsActionHeld("Block") then
            setthreadidentity(8);
            debug_print("[%s] Skipping action, Holding F.", name);
            return "continue"        
end;

        if aztup_options.filters.Value["Dont Parry If In Payback"] and (EffectReplicator:FindEffect("PaybackHealTally") and tick() - last_payback_delay_time > 60 or EffectReplicator:FindEffect("DelayedPayback")) then
            debug_print("[%s] Skipping action, In Payback.", name);
            return "continue"        
end;

        if aztup_options.filters.Value["Dont Parry If Off Roblox"] and not aztup.automation:has_any() then
            if not isrbxactive() then
                debug_print("[%s] Skipping action %i, User is not tabbed in.", name, index);
                return "continue"            
end
        end

        if self.entity:GetAttribute("Owner") and self.entity:GetAttribute("Owner") == local_player.instance.Name then
            debug_print("[%s] Skipping timing due to us owning the entity.", name)
            return "break"        
end;

        if aztup_options.filters.Value["Dont Parry If Off Screen"] and not aztup.automation:has_any() then
            local _, vis = workspace.CurrentCamera:WorldToViewportPoint(self.entity.HumanoidRootPart.Position);
            if not vis then
                debug_print("[%s] Skipping action %i, Entity is off screen.", name, index);
                return "continue"            
end
        end

        if #self.hits > 0 and (
            action_type == "M1" or
            action_type == "Critical" and aztup_options.filters.Value["Dont Parry If Enemy Hit In Criticals"]
        ) then
            debug_print("[%s] Skipping action %i, Enemy hit in %s.", name, index, action_type);
            return "break"        
end

        if aztup_options.filters.Value["Dont Parry If Typing"] and not aztup.automation:has_any() then
            local l_ChatInputBarConfiguration_0 = services.TextChatService:FindFirstChild("ChatInputBarConfiguration");
            if services.UserInputService:GetFocusedTextBox() or l_ChatInputBarConfiguration_0 and l_ChatInputBarConfiguration_0.IsFocused then
                debug_print("[%s] Skipping action %i, Input box is focused.", name, index);
                return "continue"            
end
        end

        return nil    
end

    
    
    
    
    local function check_chime_and_gale(self, track, action, name, index)
        if aztup_options.filters.Value["Dont Parry In Chime Countdown"] and is_chime then
            local simple_prompt = local_player.instance:FindFirstChild("SimplePrompt", true);
            if simple_prompt then
                if simple_prompt:GetAttribute("CurPrompt") and simple_prompt:GetAttribute("CurPrompt") > 1 and simple_prompt:GetAttribute("CurPrompt") < 15 then
                    debug_print("[%s] In chime countdown for %i & %i, skipping action %i", name, simple_prompt:GetAttribute("CurPrompt"), workspace.DistributedGameTime, index);
                    return "continue"                
end
            end
        end

        return nil    
end

    local function fire_feint(hold_time)
        local character_handler = local_player.character:FindFirstChild("CharacterHandler");
        local feint_release = character_handler and character_handler:FindFirstChild("FeintRelease", true);
        local feint_click = KeyHandler:get_key("FeintClick");

        if not feint_release or not feint_click then
            return false        
end;

        feint_click:FireServer({
            A = false,
            Left = false,
            S = false,
            NOAERIALS = false,
            Space = false,
            Right = true,
            W = false,
            D = false
        })

        task.wait(hold_time or 0.05);

        feint_release:FireServer({
            A = false,
            Left = false,
            S = false,
            NOAERIALS = false,
            Space = false,
            Right = false,
            W = false,
            D = false
        })

        return true    
end

    local feint_cooldown_effects = {
        M1 = "FeintCool",
        Spell = "SpellFeintCooldown",
    };

    local function on_feint_cooldown(own_action_type)
        local effect_name = feint_cooldown_effects[own_action_type];
        return effect_name ~= nil and EffectReplicator:FindEffect(effect_name) ~= nil    
end

    local function feint_own_attack_before_parry()
        if not aztup.flags.auto_feint then
            return        
end;

        if not EffectReplicator:FindEffect("LightAttack") and not EffectReplicator:FindEffect("MidAttack") then
            return        
end;

        local own_action_type = self_anim_data.timing and self_anim_data.timing.action_type;
        if not own_action_type or not aztup_options.auto_feint_own_tags.Value[own_action_type] then
            return        
end;

        if on_feint_cooldown(own_action_type) then
            return        
end;

        debug_print("[Auto Feint] Mid-swing while trying to parry, feinting first.");
        fire_feint();
    end

    
    
    
    
    local function execute_resolved_action(self, type, action, data)
        if type == "Parry" then
            feint_own_attack_before_parry();

            if (action.allow_parry_to_roll or data.allow_parry_to_roll) and not aztup_options.filters.Value["Dont Roll"] then
                DefendActionManager:queue_generic_parry_task(self.entity);
            else
                DefendActionManager:queue_generic_parry_task_no_convert(self.entity);
            end;
        elseif type == "Dodge" then
            DefendActionManager:add_action(self.entity, "dodge", tick());
        elseif type == "Forced Full Dodge" then
            DefendActionManager:defend_action_dodge({
                mob = self.entity,
                type = "dodge",
                full = true,
                when = tick()
            });
        elseif type == "Jump" or type == "Legit Jump" and not self.is_player then
            local Safety = require("@src/utility/safety");
            if #services.Players:GetPlayers() == 1 and type ~= "Legit Jump" then
                local_player.character.CharacterHandler.Requests.Jump:FireServer()
                local_player.root_part.CFrame *= CFrame.new(0, 50, 0)
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
                    local_player.character.CharacterHandler.Requests.Jump:FireServer()

                    local jump_anim = local_player.humanoid:LoadAnimation(local_player.character.CharacterHandler.InputClient.Jump);
                    jump_anim:Play(0.05);

                    task.delay(0.4, function()
                        jump_anim:AdjustSpeed(0.5);
                        jump_anim:Stop(0.1);
                    end);
                end;
            end
        elseif type == "Start Block" then
            DefendActionManager:add_action(self.entity, "block", tick());
            self.blocked = true;
        elseif type == "Crouch" then
            task.spawn(function()
                local_player.character:WaitForChild("CharacterHandler"):WaitForChild("Requests"):WaitForChild("ServerCrouch"):FireServer(true)
                task.wait(1);
                local_player.character:WaitForChild("CharacterHandler"):WaitForChild("Requests"):WaitForChild("ServerCrouch"):FireServer(false);
            end)
        end;
    end

    
    
    
    
    local function lookup_timing_data(id)
        
        local custom, custom_name = custom_timings:lookup(id);
        if custom then
            return custom, custom_name        
end;

        local data, pot_name;
        local index = fast_timing_lookup_table[id];
        local timing = index and timing_data[index];
        if timing and id and typeof(id) == "string" and #id > 0 and timing.ids and table.find(timing.ids, id) then
            data = timing;

            if typeof(index) ~= "number" then
                pot_name = index;
            end;
        end
        return data, pot_name    
end


    
    local function process_actions(self, track, data, pot_name, to_evaluate_actions, action_type, blocked_bi, blocked_af)
        local current_rtt = Latency:get_ping()
        local alotted = 0
        local forced_roll_next

        local track_state = self.running_tracks[track];
        if track_state then
            track_state.action_type = action_type;
        end;

        local root = self.entity:FindFirstChild("HumanoidRootPart")
        if not root then
            return
        end

        local magnitude = (root.Position - local_player.root_part.Position).Magnitude;
        if self.is_player and magnitude > aztup.flags.dont_process_players_over_studs or not self.is_player and magnitude > aztup.flags.dont_process_mobs_over_studs then
            return        
end;

        if self.entity.Name:match("squidward") or self.entity.Name:match("nautilodaunt") and tick() - self.last_feint_at <= 0.5 then
            forced_roll_next = true;
        end;

        table.sort(to_evaluate_actions, function(a, b)
            local a_time = a.when and a.when or 0
            local b_time = b.when and b.when or 0
            return a_time < b_time
        end)

        for index, action in to_evaluate_actions do
            if track_state then
                track_state.action = action;
            end;

            local starting_speed = track.Speed;
            local hitbox = action.hitbox or Vector3.zero;
            local offset = action.offset or CFrame.new();
            local type = action.type or "Parry";
            local ignore_anim_early_end = action.ignore_animation_early_end or data.ignore_animation_early_end;
            local time = action.when or 0;
            local name = action.name or data.name or pot_name or "Unidentified " .. track.Animation.AnimationId;

            if data.ignore_hitbox_check or data.ignore_hitbox or action.ignore_hitbox_check then
                action.ignore_hitbox = true;
            end
            
            if action.half_size_offset then
                offset -= Vector3.new(0, 0, hitbox.Z / 2)
            end;
            
            if type == "End Block" and self.blocked then
                local wait_time = (time - alotted) - current_rtt
                task.wait(wait_time);
                DefendActionManager:add_action(self.entity, "unblock", tick());
                self.blocked = false;
                continue            
end;

            local function in_hitbox(hide)
                local inside;
                if not action.ignore_hitbox then         
                    if aztup.flags.mob_ai_breaker then
                        action.extrapolate = false;
                    end; 
                    
                    self.ball = action.shape == "ball";
                    
                    
                    
                    inside = self:in_hitbox(hitbox, offset or CFrame.new(), hide, action.predict, action.predict_time, action.predict_rotation, action.base_and_predict);
                    
                    self.ball = false;
                end

                return inside            
end;

            if typeof(hitbox) == "table" then
                hitbox = Vector3.new(
                    hitbox.X or 0,
                    hitbox.Y or 0,
                    hitbox.Z or 0
                );
            end;
    
            if typeof(offset) == "table" then
                offset = CFrame.new(
                    offset.X or 0,
                    offset.Y or 0,
                    offset.Z or 0
                );
            end;

            

            if action.delay_until_in_hitbox then
                repeat
                    task.wait();
                until in_hitbox(true) or not action.ignore_early_end and not track_still_active(track, self.entity) and not ignore_anim_early_end;
            end;

            local start = tick();
            local input_task = create_block_input_task(self, track, action, data, action_type, name, time, alotted, ignore_anim_early_end, blocked_bi, start, in_hitbox);
            self:track_cleanup(track, function()
                if not input_task.removed then
                    input_task:remove();
                end;
            end);

            if track.Speed > 50 then
                input_task:remove();
                break            
end;

            local chance_entry = chance_store:get_entry(data.name or pot_name or action.name);
            local continue_with_parry = true;

            local variation_weights = chance_entry and (chance_entry.outcome_weights or chance_entry.fail_weights or chance_entry.fail_actions);
            local variation_result = variation_weights and DefendActionManager:execute_failed_parry_variation(self.entity, variation_weights) or "Parry";
            continue_with_parry = variation_result == "Parry" or variation_result == "Dodge";

            if not continue_with_parry then
                debug_print("[%s] Action %i chance roll -> %s.", name, index, variation_result);
                input_task:remove();
                continue            
end;
            
            if math.random() >= (aztup.flags[self.flag .. "parry_chance"] / 100) then
                if not action.ignore_hitbox and in_hitbox(true) or action.ignore_hitbox then
                    debug_print("[%s] Skipping action %i due to global parry chance.", name, index);
                end;                

                input_task:remove();
                continue            
end;

            local wait_time = (time - alotted) - current_rtt

            local notifs = {};
            if wait_time > 0 and wait_time == wait_time and wait_time < 60000 then
                    task.delay(wait_time - (1 / 15), function()
                        if aztup.flags.auto_feint and not blocked_af then
                            if check_action_preconditions_auto_feint(self, track, action, data, action_type, name, index, in_hitbox) then
                                return                            
end;

                            if check_action_situation_filters(self, track, action, action_type, name, index) then
                                return                            
end;

                            if not action.ignore_early_end and not track_still_active(track, self.entity) and not ignore_anim_early_end then
                                return                            
end

                            if anti_ap_breaker:final_check(self, track) then
                                return                            
end

                            if not EffectReplicator:FindEffect("LightAttack") and not EffectReplicator:FindEffect("MidAttack") then
                                if not notifs.b then
                                    debug_print("[Auto Feint] Skipping because not in a attack.");
                                    notifs.b = true;
                                end;
                                return                            
elseif not notifs.a then
                                notifs.a = true;
                                debug_print("[Auto Feint] Attempting to feint.");
                            end;

                            local own_action_type = self_anim_data.timing and self_anim_data.timing.action_type;
                            if not own_action_type or not aztup_options.auto_feint_own_tags.Value[own_action_type] then
                                return debug_print("[Auto Feint] Skipping, our move type '%s' isn't selected.", tostring(own_action_type))                            
end;

                            if on_feint_cooldown(own_action_type) then
                                return debug_print("[Auto Feint] Skipping, '%s' feint is on cooldown.", own_action_type)                            
end;

                            fire_feint();
                        end;
                    end);

                task.wait(wait_time)
                alotted += wait_time
            elseif wait_time ~= wait_time or wait_time > 0 then
                return debug_print("[%s] Skipping action %i, wait time invalid: %.2f", name, index, wait_time)            
end;

            if not input_task.removed then
                input_task:remove();
            end;

            if anti_ap_breaker:final_check(self, track) then
                tasks = math.max(0, tasks - 1);
                return            
end

            
            
            
            
            

            if not action.ignore_early_end and not track_still_active(track, self.entity) and not ignore_anim_early_end then
                debug_print("[%s] Skipping action %i, animation ended early.", name, index);
                continue            
end

            if type == "RPUE Parry" then
                local blocked = false;
                while action.condition() do
                    if action.should() then
                        blocked = true;
                        DefendActionManager.block:FireServer();
                        task.delay(0, function()
                            DefendActionManager.unblock:FireServer();
                        end)
                    end;
                    action.wait();
                end;

                if blocked then
                    task.wait();
                    DefendActionManager.unblock:FireServer();
                end;
                continue            
end;

            if check_action_preconditions(self, track, action, data, action_type, name, index, in_hitbox) then
                continue            
end;

            if aztup.flags[self.flag .. "roll_if_unequipped"] and not EffectReplicator:FindEffect("Equipped") and type == "Parry" then
                type = "Dodge";
            end;

            if forced_roll_next and type == "Parry" then
                type = "Dodge";
                forced_roll_next = false;
            end;

            if aztup.flags[self.flag .. "auto_equip"] and not EffectReplicator:FindEffect("Equipped") then
                local character_handler = local_player.character:FindFirstChild("CharacterHandler");
                local requests = character_handler and character_handler:FindFirstChild("Requests");
                local equip_weapon = requests and requests:FindFirstChild("DrawWeapon");

                if equip_weapon then
                    task.delay(0.1 + (math.random() / 1000), function()
                        equip_weapon:FireServer(true);
                    end);
                else
                    debug_print("failed to find 'DrawWeapon'");
                end;
            end;

            local situation_skip = check_action_situation_filters(self, track, action, action_type, name, index)
            if situation_skip == "continue" then
                continue            
elseif situation_skip == "break" then
                break            
end;

            local chime_gale_skip = check_chime_and_gale(self, track, action, name, index)
            if chime_gale_skip == "continue" then
                continue            
elseif chime_gale_skip == "return" then
                return            
end;

            if aztup.flags.log_speed_changes then
                if starting_speed == track.Speed then
                    debug_print("[%s] Performing action %i: %s (%.2fs srtt -> %.2fs, %.2f speed)", name, index, type, current_rtt, Latency:get_ping(), starting_speed); 
                else
                    debug_print("[%s] Performing action %i: %s (%.2fs srtt -> %.2fs, %.2f -> %.2f speed)", name, index, type, current_rtt, Latency:get_ping(), starting_speed, track.Speed);
                end
            else
                debug_print("[%s] Performing action %i: %s (%.2fs srtt -> %.2fs)", name, index, type, current_rtt, Latency:get_ping()); 
            end;

            if variation_result ~= "Parry" then
                debug_print("[%s] Action %i chance roll -> %s.", name, index, variation_result);
            end

            if variation_result == "Dodge" then
                type = "Dodge";
                debug_print("[%s] switched action %i to dodge.", name, index);
            end

            if type == "Parry" and (not action.ignore_auto_parry_frames and in_parry_frames) and aztup_options.filters.Value["Dont Parry In AP Frames"] then
                debug_print("[%s] In parry frames. Skipping action %i", name, index);
                continue            
end;

            
            
            
            

            if aztup.flags.ap_randomization and type == "Parry" then
                local chance = aztup.flags["parry_to_dodge_chance_" .. (data.action_type or "undefined"):lower()] or 0
                local can = not aztup.flags.only_convert_dodge_if_possible or aztup.flags.only_convert_dodge_if_possible and local_player.tracker:can_dodge()

                if random:NextNumber() <= chance / 100 and can then
                    type = "Dodge";
                    debug_print("[%s] Randomized action %i to dodge.", name, index);
                end;
            end;

            if action.prefer_dodge and local_player.tracker:can_dodge() then
                type = "Dodge";
                debug_print("[%s] Action %i prefers dodge.", name, index);
            end;

            if (action.allow_parry_to_roll or data.allow_parry_to_roll) and not local_player.tracker:can_parry() then
                if local_player.tracker:can_dodge() then
                    type = "Dodge";
                    debug_print("[%s] Parry on CD, rolling instead.", name);
                end;
            end

            if aztup_options.filters.Value["Dont Roll"] and (type == "Dodge" or type == "Forced Full Dodge") then
                debug_print("[%s] Skipping action %i, Roll is disabled.", name, index);
                continue            
end;

            if aztup_options.filters.Value["Dont Parry If Not In Combat"] and not EffectReplicator:FindEffect("Danger") then
                debug_print("[%s] Skipping action %i, Not in danger.");
                continue            
end;
            
            execute_resolved_action(self, type, action, data);

            if action.no_more_actions then break end
        end
    end
    
    
    
    
    local function log_info_if_enabled(self, track)
        if not (aztup.flags.info_logger and self.entity:FindFirstChild("HumanoidRootPart") and self.entity.Name ~= local_player.character.Name) then
            return        
end

        local dist = (local_player.root_part.Position - self.entity.HumanoidRootPart.Position).Magnitude;
        if dist > aztup.flags.info_logger_range then
            return        
end

        task.spawn(function()
            local name = getInfo(track.Animation.AnimationId:match("%d+")).Name
            if name:lower():match("parried") then return end
            if name:lower():match("idle") then return end

            local disallowed = false;
            local assets = game:GetService("ReplicatedStorage"):FindFirstChild("Assets");
            for _, anim in assets.Anims.Movement:GetDescendants() do
                if anim:IsA("Animation") and anim.AnimationId == track.Animation.AnimationId then
                    disallowed = true;
                    break                
end;
            end

            if disallowed then return end

            Library:AddTextToInfoLogger(string.format("%s %s %s", name, tostring(track.Animation.AnimationId:match("%d+")), self.entity.Name), tostring(track.Animation.AnimationId:match("%d+")), function()
                if getgenv().timing_builder then getgenv().timing_builder:load_track(track, self.entity); end;
            end, 60);
        end);
    end

    local asset_id = require("@src/utility/asset_id");
    function AnimatorHandler:run(track: AnimationTrack)
        local ap = aztup.flags.auto_parry
        local breaker = aztup.flags.ap_breaker
        local asc = aztup.features.anim_speed_changer

        if not ap and not breaker and not asc then return end
        if not track or not track.Animation then return end
        if not EffectReplicator then return end
        if not local_player.character then return end

        if self.entity.Name ~= local_player.character.Name and not ap then return end

        local id, err = asset_id.get_id(track.Animation.AnimationId);
        if (self.is_player and mobsAnims[id]) or err or not id then
            return        
end;

        local data, pot_name = lookup_timing_data(id);

        log_info_if_enabled(self, track);

        if not data or tasks >= (aztup.flags.task_concurrency or 25) then
            return        
end;

        task.wait(1 / 60); 
        if anti_ap_breaker:initial_check(self, track) then 
            tasks = math.max(0, tasks - 1);
            return 
        end
        
        if is_chime then
            local alive = track.IsPlaying or not anti_ap_breaker:is_fully_dead(track, self.entity);
            if track.WeightTarget <= 0.050 and (track.WeightCurrent < 0.050 or not alive) then
                return            
end;
        end;

        if data.enc then
            
            

data = table.clone(data);
            data = process(data);

        end

        local str = pot_name or data.name or data.actions and data.actions[1] and data.actions[1].name;
        if str and aztup_options.blocked_timings.Value[str] then return end
    
        if self.entity.Name == local_player.character.Name then


            local action_type = data.action_type or "Undefined";
            if action_type == "M1" then
                aztup.features.ap_breaker.last_m1_anim = track.Animation.AnimationId;
            end;
    
            if aztup.features.tester_ap_breaker and aztup.features.tester_ap_breaker.handle and aztup.flags.tester_ap_breaker then
                aztup.features.tester_ap_breaker:handle(track, data);
            end

            if aztup.features.anim_speed_changer then
                aztup.features.anim_speed_changer:handle(track, data);
            end
                
            if aztup_options.aggressive_3_break_on.Value[({
                ["Critical"] = "Criticals",
                ["Untagged"] = "Untagged",
                ["Spell"] = "Spells",
                ["Bell"] = "Bells",
                ["M1"] = "M1s"
            })[action_type] ] then
                break_anims(track, data, action_type, self); 
            end

            self_anim_data = { 
                timing = data,
                track = track,
                when = tick()
            };
            return        
end;
    
        if not TargetFilter.is_allowed(self.entity, aztup_options.allowed_targets.Value) then
            return
        end
    
        if aztup_options.filters.Value["Dont Parry If Guildmate"] then
            local player = services.Players:GetPlayerFromCharacter(self.entity);
            if player and general:is_teammate(player) then
                return            
end
        end

        self.running_tracks[track] = { thread = coroutine.running(), feint_threads = {}, cleanups = {} };

        local actions = action_builder.new({ signal = true })
        local to_evaluate_actions

        tasks += 1;
        task.delay(1, function()
            tasks -= 1;
        end);
        if data.run then
            
            
            
    
            local base_env = getfenv(data.run)
            local signal_actions = {} 
    
            actions:get_signal():connect(function(aid)
                local a = actions.actions[aid]
                if not a then 
                    return 
                end
    
                
                table.insert(signal_actions, a)
    
                
                local single = { a }
    
                local action_type = data.action_type or "Undefined"
                local blocked_bi = aztup_options.blocked_safe_input_moves.Value[action_type]
                local blocked_af = aztup_options.blocked_auto_feint_moves.Value[action_type]
    
                process_actions(self, track, data, pot_name, single, action_type, blocked_bi, blocked_af)
            end)
    
            local fake_env = setmetatable({
                track = track,
                defender = self,
                self = {
                    distance = function()
                        return (local_player.root_part.Position - self.entity.HumanoidRootPart.Position).Magnitude
                    end,
                    is_playing = function()
                        return track_still_active(track, self.entity)
                    end,
                },
                weapon = require("@src/features/auto-parry/data/weapon").data(self.entity) or {},
                mantra = require("@src/features/auto-parry/data/mantra"),
                thrown = workspace:FindFirstChild("Thrown"),
            }, {
                __index = base_env,
            })
            setfenv(data.run, fake_env)
            data.run(actions, self)
            setfenv(data.run, base_env)
    
            
            
            
            to_evaluate_actions = actions:get()
            if #to_evaluate_actions > 0 then
                local action_type = data.action_type or "Undefined"
                local blocked_bi = aztup_options.blocked_safe_input_moves.Value[action_type]
                local blocked_af = aztup_options.blocked_auto_feint_moves.Value[action_type]
    
                process_actions(self, track, data, pot_name, to_evaluate_actions, action_type, blocked_bi, blocked_af)
            end

            self.running_tracks[track] = nil;
            return
        else
            for _, action in data.actions do
                actions.pending_action = action
                actions:push()
            end
            to_evaluate_actions = data.actions or actions:get()
        end
    
        local action_type = data.action_type or "Undefined"
        local blocked_bi = aztup_options.blocked_safe_input_moves.Value[action_type]
        local blocked_af = aztup_options.blocked_auto_feint_moves.Value[action_type]
    
        process_actions(self, track, data, pot_name, to_evaluate_actions, action_type, blocked_bi, blocked_af)

        self.running_tracks[track] = nil;
    end;

    local last_mid_attack = tick();
    EffectReplicatorHandler:hook("added", function(effect)
        if effect.Class == "MidAttack" then
            last_mid_attack = tick();
        elseif effect.Class == "DelayedPayback" then
            last_payback_delay_time = tick();
        end;

        return nil    
end);

    EffectReplicatorHandler:hook("removed", function(effect)
        if effect.Class == "MidAttack" then
            last_mid_attack_delay = (tick() - last_mid_attack) - Latency:half_ping()
        end 

        return nil    
end);

    InstanceWatcher.new(workspace:WaitForChild("Live"), function(entity)
        local start = tick();
    
        repeat task.wait() until entity:FindFirstChild("Animator", true) or tick() - start > 5;
        return entity:FindFirstChild("Animator", true)    
end, function(entity)   
        if not entity:IsA("Model") then return end
        AnimatorHandler.new(entity);
    end);
end)()