--!nocheck
if is_regular then
    return {
        run = function()
            local_player.instance:Kick("Attempted to start a beta-only automation whilst not on beta.");
            persistent_data:wipe();
        end
    }
end;
local automation_struct = require("@src/automation/struct");

local hold_m1 = false

local autoduke = {
    temp_tween = function(cf, speed)
        Tween.new(cf, true, speed).wait();
    end,
    player_safe_tween = function(self, cf, speed)
        if self.player_near() then
            -- Serverhop to small server, will kick for now
            self.server_hop()
            while task.wait() do end
        end
        
        local ylevel = math.random(8000, 10000)
        
        -- Tween up
        local_player.root_part.CFrame = local_player.root_part.CFrame + Vector3.new(0, local_player.root_part.CFrame.Y + ylevel, 0)
        --self.tempTween(local_player.root_part.CFrame + Vector3.new(0, local_player.root_part.CFrame.Y + ylevel, 0), speed)
        
        -- Tween to target location
        self.temp_tween(cf + Vector3.new(0, cf.Y + ylevel, 0), speed)
        
        -- Check for players
        if self.players_near(Vector3.new(cf.X, cf.Y, cf.Z), 200) then
            -- Serverhop to small server, will kick for now
            self.server_hop()
            while task.wait() do end
        end
        
        -- Tween down
        local_player.root_part.CFrame = cf
        task.wait(1)
    end,
    player_near = function()
        for _, player in services.Players:GetPlayers() do
            if local_player.instance == player then continue end
            if not player.Character then continue end
            if not player.Character:FindFirstChild('HumanoidRootPart') then continue end
            
            local dist = (local_player.root_part.Position - player.Character:GetPivot().Position).Magnitude
            if dist <= 1000 then return true end
        end
        
        return false
    end,
    players_near = function(target, mag)
        mag = mag or 1000;
        target = target or local_player.root_part.Position;
        for _, player in services.Players:GetPlayers() do
            if not player.Character then continue end
            if not player.Character:FindFirstChild('HumanoidRootPart') then continue end
            if player == local_player.instance then continue end
            
            local hmrp = player.Character.HumanoidRootPart
            
            local dist = (target - player.Character:GetPivot().Position).Magnitude
            
    m1_hold = function(toggle)
        if not toggle then
            hold_m1 = false
            return
        end
        
        hold_m1 = true
    end,
    ready_weapon = function()
        local character_handler = local_player.character:FindFirstChild("CharacterHandler");
        character_handler.Requests.DrawWeapon:FireServer(true);
    end,
    grab_chests = function(self)
        local looted = false;
        local time = 3
        local secondsWaited = 0
        
        for _, chest in pairs(workspace.Thrown:GetChildren()) do
            if not chest:FindFirstChild("Lid") then continue; end
            if services.CollectionService:HasTag(chest, 'looted') then continue end
            
            self.temp_tween(chest.Lid.CFrame, 170)
            local moreTime = 3
            local moreSecondsWaited = 0
            
            repeat 
                task.wait(1) 
                pcall(function()
                    fireproximityprompt(chest:FindFirstChildWhichIsA("ProximityPrompt"));
                end);
                pcall(function(...) 
                    self.temp_tween(chest.Lid.CFrame, 170)
                end)
                moreSecondsWaited += 1
            until local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or not aztup.automation:has_any() or moreSecondsWaited >= moreTime
            if local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') then
                looted = true;
            end;

            repeat task.wait(1); secondsWaited += 1; until not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or not aztup.automation:has_any() or secondsWaited >= time
            
            if local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') then
                looted = true;
                pcall(function(...)  
                    local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt'):FindFirstChild('Choice'):FireServer('EXIT')
                end)
            end

            services.CollectionService:AddTag(chest, 'looted')
        end
        return looted;
    end,
}

function autoduke:refill()
    local function collect_ingredient(ing)
        self.player_safe_tween(self, ing.CFrame, 200)
        local cf = ing.CFrame;

        repeat
            Tween.new(cf, true).wait();

            pcall(function(...)  
                fireproximityprompt(ing:FindFirstChildOfClass('ProximityPrompt'))
            end)
            task.wait()
        until ing.Parent == nil
    end
    
    local function eat_food(food)
        local food_item = local_player.instance.Backpack:FindFirstChild(food);
        if not food_item then return end

        local_player.character.Humanoid:EquipTool(food_item)
        food_item:Activate();
        task.wait(0.5);
        local_player.character.Humanoid:UnequipTools();
    end
    
    local function isSatiated()
        local water = local_player.character:FindFirstChild('Water')
        return (water.Value >= (water.MaxValue * 0.5))
    end
    
    local function get_closest_ingredient(ing)
        local closest = nil
        
        for _, ingredient in workspace.Ingredients:GetChildren() do
            if not ingredient.Name:match(ing) then continue end
            
            if closest == nil then
                closest = ingredient
                continue
            end
            
            if closest then
                local closestDist = (local_player.root_part.Position - closest.Position).Magnitude
                local ingDist = (local_player.root_part.Position - ingredient.Position).Magnitude
                
                if closestDist > ingDist then
                    closest = ingredient
                end
            end
        end
        
        return closest
    end
    
    --why is TEMPED SO FUCKING GOATED?, i dunno G!!!!!!
    
    local start_tick = tick();
    local has_carnivore = local_player.character:GetAttribute("ssv_Passives") and local_player.character:GetAttribute("ssv_Passives"):find("Carnivore")
    if not has_carnivore then
        if not isSatiated() then
            while not isSatiated() and tick() - start_tick <= 45 do
                local ing = get_closest_ingredient('Dentifilo') or get_closest_ingredient('Calabash');
                if ing then
                    collect_ingredient(ing) -- probably the safest food in the etrean luminant
                    eat_food(ing.Name)
                else
                    break;
                end

                task.wait();
            end;
        end
    end
end

function autoduke:create_instance()
    local backpack = local_player.instance:FindFirstChild("Backpack");
    if not backpack then return; end

    local manor_key = backpack:WaitForChild("Manor Key", 10) or local_player.character:WaitForChild("Manor Key", 10) 
    if not manor_key then return Logger:notify_sound("need manor key"); end

    manor_key.Parent = local_player.character;

    local handle = manor_key:WaitForChild("Handle", 10);
    if not handle then return local_player.instance:Kick("failsafe [1]"); end

    --run this in a seperate routine - we really do not actually care about the end result
    if handle.Color.R < 0.99 or handle.Color.G < 0.99 or handle.Color.B < 0.99 then
        local start = tick();
        local old = handle.Color;
        repeat task.wait() until handle.Color ~= old or tick() - start > 10;
        if handle.Color.R < 0.99 or handle.Color.G < 0.99 or handle.Color.B < 0.99 then 
            return self.server_hop();
        end
    end
    
    self:player_safe_tween(CFrame.new(1460, 74, 3069), 200);
    
    local started = false;
    task.delay(20, function() 
        if started then return; end

        local slot = local_player.instance:GetAttribute("DataSlot");
        return server_utility:hop(slot, true);
    end)

    workspace.Live.ChildAdded:Connect(function(entity)
        if not (entity.Name:find("brainsucker") or entity.Name:find("dukecultist")) then return; end
        if (entity:GetPivot().Position - local_player.root_part.Position).Magnitude > 400 then return; end
        started = true;
    end)

    while task.wait() and not started do    
        sethiddenproperty(local_player.humanoid, "MoveDirectionInternal", Vector3.one)
        fireproximityprompt(workspace:WaitForChild("Doors"):WaitForChild("ErisiaDungeonGate"):WaitForChild("Main"):WaitForChild("InteractPrompt"));
        task.wait();
    end;

    services.RunService.Heartbeat:Connect(function() 
        aztup.features.m1_hold.held = hold_m1
    end)

    self:ready_weapon();
    self:m1_hold(true);
    
    local done = false;
    self:m1_hold(false);

    task.delay(30, function() 
        local slot = local_player.instance:GetAttribute("DataSlot");
        return server_utility:hop(slot, true);
    end)

    self:player_safe_tween(CFrame.new(1470, 84, 3586), 200);
    for i = 1, 300 do
        if self.player_near() then
            -- Serverhop to small server, will kick for now
            self.server_hop()
            while task.wait() do end
        end

        Tween.new(CFrame.new(1470, 84, 3586), true, 250).wait();
        fireproximityprompt(workspace.ErisiaElevator.Switch.InteractPrompt);
        task.wait(0.1);
    end;
    return true;
end

function autoduke:kill_duke()
    services.RunService.Heartbeat:Connect(function() 
        aztup.features.m1_hold.held = hold_m1
    end)

    self:ready_weapon();
    self:m1_hold(true);

    local client_effect;
    repeat 
        client_effect = services.ReplicatedStorage:FindFirstChild("ClientEffect", true)

        if not client_effect then
            task.wait()
        else break; end
    until client_effect;

    local nope_tf_out = false;
    client_effect.OnClientEvent:Connect(function(effectName, effectData)
        if effectName == "GolemLaserFire" then
            nope_tf_out = true;
            task.delay(0.4, function() 
                nope_tf_out = false;
            end)
        end
    end)

    local done = false;

                task.wait();
            end

            done = false;
        end
        if not persistent_data:get("auto_duke") then break; end

    end
            if not persistent_data:get("auto_duke") then return; end

    self:m1_hold(false);

    --if voiding_mode then you have to do the fight for him to void lol
    --    Tween.new(CFrame.new(2495, 139, 1926), true, 200).wait();
    --    task.delay(30, function()
    --        repeat 
    --            task.wait() 
    --            Tween.new(CFrame.new(2495, 139, 1926), true, 200).wait();
    --        until not EffectReplicator:FindEffect("Danger");
    --        require("@src/features/buttons/respawn")();
    --    end)
--
    --    while not self:grab_chests() do
    --        Tween.new(CFrame.new(2495, 139, 1926), true, 200).wait();
    --        local_player.root_part.Veloicty = Vector3.zero;
    --        task.wait(1);
    --    end;
    --    return;
    --end

    local send_dialogue = game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue");
    local got = false;
    local fc = 0;
    send_dialogue.OnClientEvent:Connect(function(v273) 
        got = not v273.exit;
        fc += 1;
    end);

    if not shared.a then
        repeat 
            Instance.new("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
            task.wait() 
            Tween.new(workspace.Live:WaitForChild(".theduke11"):WaitForChild("HumanoidRootPart").CFrame * CFrame.new(0, 0, 3), true, 250).wait();
            fireproximityprompt(workspace.Live[".theduke11"]:WaitForChild("InteractPrompt"));
            Instance.new("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
        until got;
    end;

    shared.a = true;
    while got do 
        Instance.new("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
        task.wait() 
        Instance.new("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
        task.wait() 
    end;
    
    repeat task.wait() until workspace.Live[".theduke11"]:FindFirstChild("Target") and workspace.Live[".theduke11"]:FindFirstChild("Target").Value;
    self:ready_weapon();
    task.delay(5, function()
        workspace.Live:FindFirstChild(".theduke11").Humanoid.AnimationPlayed:Connect(function(anim)
            if anim.Animation.AnimationId:find("8275408994") or anim.Animation.AnimationId:find("8290899374") or anim.Animation.AnimationId:find("8294560344") then
                nope_tf_out = true;
                task.delay(anim.Animation.AnimationId:find("8294560344") and 7.5 or 2.5, function() 
                    nope_tf_out = false;
                end)
            end
        end)
    end)

    local voiding_mode = persistent_data:get("auto_duke_voids", false);
    aztup_toggles.void_mobs:SetValue(voiding_mode);

    local duke = workspace.Live[".theduke11"]
    print("done");
    self:m1_hold(false)

    task.delay(60 * 5, function()
        repeat 
            task.wait() 
            Tween.new(CFrame.new(2495, 139, 1926), true, 160).wait();
        until not EffectReplicator:FindEffect("Danger");
        require("@src/features/buttons/respawn")();
    end)

    while true do
        local suc, res = pcall(function() 
            return self:grab_chests()
        end);

        if suc and res then break; end
        task.wait(1);
    end
    
    repeat 
        task.wait() 
        Tween.new(CFrame.new(2495, 139, 1926), true, 160).wait();
    until not EffectReplicator:FindEffect("Danger");
    require("@src/features/buttons/respawn")();
end

local struct;
struct = automation_struct:construct({
    persistent_data_store = 'auto_duke_store',
    persistent_data_flag = 'auto_duke',
    id = 'auto_duke',
    
    state_machine = StateMachine.create({
        initial = "idle",
        events = {
            {name = 'start',    from = 'idle', to = '_check_area'},
            {name = 'refill',   from = '_check_area', to = '_refill'},
            {name = 'initiate', from = '_check_area', to = '_initiate'},
            {name = 'initiate', from = '_refill', to = '_initiate'},
            {name = 'kill',     from = '_check_area', to ='_kill'}         
        },
        callbacks = {
            onenter_check_area = function(self)
                if is_etrean then  
                    self:refill()
                    self:initiate()
                    return
                end
                
                if is_eastern then
                    require("@src/features/buttons/teleports/etrean")()
                    return
                end
                
                pcall(function(...)  
                    local is_dungeon = local_player.instance:GetAttribute('Dungeon'):match('Duke')
                    if is_dungeon then
                        self:kill()
                        return
                    end
                end)
                
                if is_depths then
                    aztup.automation:set('auto_duke', not persistent_data:get('auto_duke', false))
                    getgenv().dont_auto_hop_pls = true;
                    local_player.instance:Kick('Somehow ended up in depths.')
                    return
                end
            end,
            onenter_refill = function(self)
                autoduke:refill()
                self:initiate()
            end,
            onenter_initiate = function(self)
                autoduke:create_instance()
            end,
            onenter_kill = function(self)
                autoduke:kill_duke()
            end
        }
    }),
    features = {
        "no_fall",
        "noclip",
        'no_kill_bricks',
        "mod_detector",
        "fly",
        "m1_hold",
        'auto_wisp',
        "auto_equip_weapon"
    },
    not_allowed = function()
        return false;
    end,
    character_creator_handler_used = false,
    character_creator_handler_opts = {}
})

return struct;