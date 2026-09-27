if is_regular then
    return {
        run = function()
            local_player.instance:Kick("Attempted to start a beta-only automation whilst not on beta.");
            persistent_data:wipe();
        end
    }
end;

local automation_struct = require("@src/automation/struct");
local struct;

local VIM = Instance.new("VirtualInputManager");

local eastern_lum = 6473861193;
local dungeon = 8668476218;

local autotitus = {
    playerCheck = function(mag, custom)
        for _, player in services.Players:GetPlayers() do
            if not player.Character then continue end
            if player == local_player.instance then continue end
            
            local hrp = player.Character:FindFirstChild("HumanoidRootPart");
            if not hrp then continue end
            
            local dist = ((custom or local_player.root_part.Position) - hrp.Position).Magnitude;
            if dist <= mag then
                return true;
            end
        end
        return false;
    end,
    
    serverHop = function()
        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:hop(slot, "any", true);
    end,
    
    tempTween = function(cf, speed)
        Tween.new(cf, true, speed or 150).wait();
    end,
    
    player_safe_tween = function(self, cf, speed)
        if self.playerCheck(200) then
            self.serverHop();
            while task.wait() do end
        end
        
        local root = local_player.root_part;
        if not root then return end
        
        local y = math.random(8000, 10000);
        root.CFrame = root.CFrame + Vector3.new(0, y, 0);
        
        self.tempTween(cf + Vector3.new(0, y, 0), speed);
        
        if self.playerCheck(200, cf.Position) then
            self.serverHop();
            while task.wait() do end
        end
        
        root.CFrame = cf;
    end,
    
    find_chests = function(max_distance)
        local chests = {}

        local thrown = workspace:FindFirstChild('Thrown')
        if not thrown then return chests end

        for _, object in thrown:GetDescendants() do
            if object.Name ~= 'Lid' then continue end
            if not object:IsA('BasePart') then continue end

            local dist = (local_player.root_part.Position - object.Position).Magnitude
            if max_distance and dist > max_distance then continue end

            table.insert(chests, object.Parent)
        end

        return chests
    end,

    get_nearest_banker = function()
        local closest = nil
        
        for _, banker in workspace.NPCs:GetChildren() do
            if not banker.Name:match('Banker') then continue end
            
            if closest == nil then
                closest = banker
                continue
            end
            
            if closest then
                local closestDist = (local_player.root_part.Position - closest.HumanoidRootPart.Position).Magnitude
                local bankerDist = (local_player.root_part.Position - banker.HumanoidRootPart.Position).Magnitude
                
                if closestDist > bankerDist then
                    closest = banker
                end
            end
        end
        
        return closest
    end,
    
    need_food = function()
        local water = local_player.character:FindFirstChild('Water')
        local stomach = local_player.character:FindFirstChild('Stomach')
        return (water.Value <= (water.MaxValue * 0.3)) and (stomach.Value <= (stomach.MaxValue * 0.3))
    end
};

function autotitus.cnt(nam)
    local qty = 0
    for _, itm in local_player.instance.Backpack:GetChildren() do
        if itm.Name == nam then qty = qty + 1 end
    end
    return qty
end

autotitus.bnk = 0

function autotitus.sub()
    local cp = local_player.instance.PlayerGui:FindFirstChild("ChoicePrompt")
    if not cp then return false end
    local mx = cp:GetAttribute("Max")
    local ch = cp:FindFirstChild("Choice")
    if mx and ch then
        task.spawn(function() pcall(function() ch:InvokeServer(mx) end) end)
        return true
    end
    return false
end

function autotitus.ful()
    local cp = local_player.instance.PlayerGui:FindFirstChild("ChoicePrompt")
    if not cp then return false end
    local ds = cp:FindFirstChild("DescSheet", true)
    if not ds or not ds:FindFirstChild("Ok") then return false end
    local dc = ds:FindFirstChild("Desc", true)
    return dc ~= nil and dc.Text == "You don't have any bank slots free."
end

function autotitus.mnu()
    local plr = local_player.instance
    local st = tick()
    while plr.Character and tick() - st < 15 do
        pcall(function() services.ReplicatedStorage.Requests.ReturnToMenu:FireServer() end)
        game:GetService("RunService").PreRender:Wait()
        local cp = plr.PlayerGui:FindFirstChild("ChoicePrompt")
        if cp then
            pcall(function() cp.Enabled = false end)
            pcall(function() cp.Choice:FireServer(true) end)
        end
        pcall(function() services.ReplicatedStorage.Requests.TeleportFailed:FireServer() end)
    end
end

function autotitus:refillfood()
    local function nearest_well()
        local closest = nil
        
        for _, well in workspace.Terrain.Water:GetChildren() do
            if not well.Name:match('DrinkingWater') then continue end
            
            if closest == nil then
                closest = well
                continue
            end
            
            local closestdist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
            local dist        = (local_player.root_part.Position - well:GetPivot().Position).Magnitude
            
            if dist < closestdist then
                closest = well
            end
        end
        
        return closest
    end
    
    local water = local_player.character:FindFirstChild('Water')    
    if not (water.Value >= (water.MaxValue * 0.75)) then
        -- Go to nearest well and drink
        local well = nearest_well()
        self.player_safe_tween(self, well:GetPivot(), 250)
        
        repeat
            well = nearest_well()
            task.wait()
        until well
        
        repeat
            pcall(function(...)  
                fireproximityprompt(well.InteractPrompt)
            end)
            task.wait(0.2)
        until (water.Value >= (water.MaxValue * 0.75))
    end
end

function autotitus:attachToTitus()
    local titus;

    repeat
        for _, ent in workspace.Live:GetChildren() do
            if ent.Name:lower():find("titus") and ent.Name:find(".") then
                titus = ent;
                break;
            end
        end
        task.wait() 
    until titus or not aztup.automation:has_any();
    if not titus then return end
    local torso = titus:WaitForChild("Torso")
    if not torso then return end

    local playerRoot = local_player.root_part;
    local activeTween;

    task.spawn(function()
        while titus and titus.Parent and aztup.automation:has_any() do
            VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game);
            task.wait(0.05); 
            VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game);
            task.wait(0.3); 
        end
    end);

    task.spawn(function()
        
        local targetCF = CFrame.new(torso.CFrame.X, 288, torso.CFrame.Z);
        playerRoot.AssemblyLinearVelocity = Vector3.zero;

        Tween.new(targetCF, true, 250).wait();
        task.wait(0.5);
        Tween.new(targetCF, true, 250).wait();

    end);
end

function autotitus:grabChest()
    local maxDistance = 1000
    local closest = nil
    local findStart = tick()

    repeat
        for _, chest in self.find_chests(maxDistance) do
            if not closest or (local_player.root_part.Position - chest.Lid.Position).Magnitude < (local_player.root_part.Position - closest.Lid.Position).Magnitude then
                closest = chest
            end
        end
        task.wait()
    until closest or not aztup.automation:has_any() or (tick() - findStart > 15)

    if not closest then return end

    local promptStart = tick()
    repeat
        pcall(function(...)
            self.tempTween(closest.Lid.CFrame, 150)
        end)
        pcall(function()
            fireproximityprompt(closest:FindFirstChildWhichIsA("ProximityPrompt"));
        end);
        task.wait(0.1)
    until local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or not aztup.automation:has_any() or (tick() - promptStart > 15)

    if not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') then return end

    local time = tick()

    repeat
        task.wait()
    until (tick() - time >= 3) or not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt');

    if local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') then
        pcall(function(...)  
            local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt'):FindFirstChild('Choice'):FireServer('EXIT')
        end)
    end
    
    self.tempTween(CFrame.new(closest.Lid.CFrame.X, 0, closest.Lid.CFrame.Z), 150)
end


function autotitus:runDungeon()
    local startTime = tick();

    repeat task.wait(0.2)
    until (local_player.instance:GetAttribute("CurrentArea") and local_player.instance:GetAttribute("CurrentArea"):match("Detainment"))
        or not aztup.automation:has_any();

    task.wait(1); 
    self:attachToTitus();

    local_player.humanoid.Died:Connect(function(...)
        server_utility:hop(local_player.instance:GetAttribute("DataSlot"), false, true);
    end)

    local finished = false;
    local conn = workspace:WaitForChild("DetainmentCore").ChildAdded:Connect(function(child)
        if child.Name == "DungeonExitFinal" then
            finished = true; 
        end
    end);

    repeat task.wait(0.2)
        if tick() - startTime > 30 then
            if conn then conn:Disconnect(); end
            self.serverHop();
            while task.wait() do end
        end
    until finished or not aztup.automation:has_any();

    if conn then conn:Disconnect(); end
    
    task.wait(0.5)
    
    xpcall(function(...)
        struct.active_features['mob_ai_breaker'].current_connection:Disconnect()
        struct.active_features['mob_ai_breaker']:disable()  
        self:grabChest();
        local_player.root_part.CFrame = local_player.root_part.CFrame * CFrame.new(0, 8000, 0)
    end, Logger.log)
    
    --task.wait(3.75) 
    
    --workspace.Thrown.ChildAdded:Wait()
    --self:grabChest();
end

local bank_ran = false;

struct = automation_struct:construct({
    persistent_data_store = "auto_titus_store",
    persistent_data_flag  = "auto_titus",
    id = "auto_titus",
    
    state_machine = StateMachine.create({
        initial = "idle",
        events = {
            { name = "start", from = "idle", to = "_check_area" },
            { name = 'continuation', from = '_create_character', to = '_check_area'},
            { name = "bank", from = '_check_area', to = '_bank_relics'},
            { name = "die", from = '_bank_relics', to = '_die'},
            { name = 'die', from = '_check_area', to = '_die'},
            { name = 'fragments', from = '_check_area', to = '_handle_fragments'},
            { name = "cc",    from = "_check_area", to = "_create_character" },
            { name = 'continuation', from = '_bank_relics', to = '_check_area'},
            { name = "enter", from = "_check_area", to = "_enter_dungeon" },
            { name = "run",   from = "_check_area", to = "_run_dungeon" },
            { name = "exit",  from = "_run_dungeon", to = "_exit" },
        },
        
        callbacks = {
            onenter_check_area = function(self)
                local is_character_creation = workspace:FindFirstChild('CharacterCreator') and local_player.character.Parent == workspace.CharacterCreator
                
                if is_character_creation then
                    self:cc()
                    return;
                end
                
                if game.PlaceId == eastern_lum then
                    local bko = aztup_options.relic_farm_bank_items
                    if bko and tick() - autotitus.bnk > 45 then
                        for bkn, bks in bko.Value do
                            if bks and autotitus.cnt(bkn) >= 25 then
                                autotitus.bnk = tick()
                                return self:bank()
                            end
                        end
                    end
                    if persistent_data:get('auto_titus_wipe_char', false) then
                        --if not bank_ran then
                        --    return self:bank();
                        --end
                        return self:enter();
                    else
                        struct.active_features['mob_ai_breaker'].current_connection:Disconnect()
                        struct.active_features['mob_ai_breaker']:disable()

                        -- Needs work
                        if autotitus.need_food() then autotitus:refillfood(); end
                        --if not bank_ran then
                        --    return self:bank();
                        --end
                        return self:enter();
                    end
                end
                
                if game.PlaceId == dungeon then
                    self:run();
                    return
                end
                
                pcall(function(...)  
                    local is_fragments = local_player.instance:GetAttribute('CurrentArea'):match('Fragments of Self')
                    if is_fragments then
                        self:fragments()
                        return
                    end
                end)
                
                if is_depths then
                    local_player.instance:Kick("in depths.");
                    getgenv().dont_auto_hop_pls = true;
                    return
                end
            end,
            
            onenter_create_character = function(self)
                struct:create_character()
                self:continuation()
            end,
            
            onenter_enter_dungeon = function(self)
                autotitus:enterDungeon();
                task.defer(self.loop, self);
                
                if local_player.humanoid:GetAttribute("DangerExpiration") and local_player.humanoid:GetAttribute("DangerExpiration") > 0 then
                    repeat task.wait() until not (local_player.humanoid:GetAttribute("DangerExpiration") and local_player.humanoid:GetAttribute("DangerExpiration") > 0)
                end
                
                task.defer(self.exit, self);
            end,
            
            onenter_handle_fragments = function(self)
                local function handleFrag()
                    local tpLocation = (workspace.NPCs.Self:GetPivot() - Vector3.new(0,15.7,0)) * CFrame.Angles(math.rad(180), math.rad(90), math.rad(180))
                    
                    if autotitus.playerCheck(200, tpLocation.Position) then
                        -- Serverhop to small server, will kick for now
                        autotitus.serverHop()
                        while task.wait() do end
                    end
                    
                    local_player.root_part.CFrame = tpLocation;
                    
                    local slot = local_player.instance:GetAttribute("DataSlot");
                    local chooseSlot = [[
                        if not game:IsLoaded() then
                            game.Loaded:Wait();
                        end;
                        if game.PlaceId ~= 4111023553 then return; end
                        local server = '%s';
                        local slot = "%s";
                    
                        queueonteleport('if game.PlaceId == 4111023553 then return; end; xpcall(function() local sound = Instance.new("Sound", game:GetService("CoreGui")); game:GetService("Debris"):AddItem(sound, 6); sound.Volume = 1.3; sound.SoundId = getcustomasset("Project Rain/assets/notification.mp3"); sound:Play(); end, warn);')
                    
                        local args = {
                            slot
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("WipeSlot"):InvokeServer(unpack(args))
                    
                        task.wait(0.5)
                    ]]
                    queue_on_teleport(string.format(chooseSlot, game.JobId, slot or "A"))
                    
                    local get_score = services.ReplicatedStorage:WaitForChild("Requests"):WaitForChild("GetScore");
                    get_score.OnClientEvent:Connect(function(v)
                        local last_wiped_at = persistent_data:get("wiped_at", nil);
                        local wiped_at = tick();
                        persistent_data:set("echoes_gained", persistent_data:get("echoes_gained", 0) + (v and typeof(v) == "table" and v.Echoes or 0))
                        persistent_data:set("cycle_count", persistent_data:get("cycle_count", 0) + 1)
                        persistent_data:set("wiped_at", wiped_at);
                        task.spawn(pcall, function()
                        
                            if last_wiped_at then
                                task.spawn(xpcall, function()
                                    local webhook = persistent_data:get("automation_webhook", nil);
                                
                                    if webhook then
                                        
                                        request({
                                            Url = webhook,
                                            Method = "POST",
                                            Headers = {
                                                ["Content-Type"] = "application/json"
                                            },
                                            Body = game:GetService("HttpService"):JSONEncode({
                                                content = " ",
                                                embeds = {
                                                    {
                                                        title = "Echo Farm",
                                                        description = string.format("Finished cycle in %.2fs, Gained %i echoes.", wiped_at - last_wiped_at, math.floor(v.Echoes or 0)),
                                                        color = 6724044,
                                                        author = {
                                                            name = ".gg/project-rain",
                                                            icon_url = "https://cdn.discordapp.com/attachments/1211502078200127529/1464075011550613588/PRLOGO.png"
                                                        }
                                                    }
                                                },
                                                username = "Project Rain",
                                                avatar_url = "https://cdn.discordapp.com/attachments/1211502078200127529/1464075011550613588/PRLOGO.png",
                                                attachments = {},
                                                flags = 4096
                                            })
                                        })
                                        
                                    end;
                                end, warn);
                            end;
                        end);
                        get_score:FireServer();
                    end);
                    
                    while task.wait() do
                        local_player.root_part.CFrame = tpLocation;
                        
                        fireproximityprompt(workspace:WaitForChild("NPCs"):WaitForChild("Self"):WaitForChild("InteractPrompt"))
                        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer({
                            choice = '[The End]',
                        })
                    end;
                end
                
                xpcall(function(...)  
                    handleFrag()
                end, 
                function()  
                    if not workspace.NPCs:FindFirstChild('Self') then
                        require("@src/features/buttons/respawn")()
                        
                        repeat task.wait() until local_player.character
                        repeat task.wait() until workspace.NPCs:FindFirstChild('Self')
                    end
                    
                    handleFrag()
                end)
            end,
            
            onenter_bank_relics = function(self)
                local bkr = workspace.NPCs:WaitForChild("Banker")
                pcall(function() autotitus.player_safe_tween(autotitus, bkr.HumanoidRootPart.CFrame * CFrame.new(0, -6, 0), 150) end)
                pcall(function() local_player.root_part.CFrame = bkr.HumanoidRootPart.CFrame * CFrame.new(0, -6, 0) end)
                local dl = tick()
                repeat
                    local dg = local_player.instance.PlayerGui:FindFirstChild("DialogueGui")
                    if dg and dg.Enabled then
                        services.ReplicatedStorage.Requests.SendDialogue:FireServer({choice = "Can I access my account?"})
                    else
                        fireproximityprompt(bkr.InteractPrompt)
                    end
                    task.wait(0.5)
                until local_player.instance.PlayerGui:FindFirstChild("BankGui") or tick() - dl > 15
                local bg = local_player.instance.PlayerGui:FindFirstChild("BankGui")
                local bko = aztup_options.relic_farm_bank_items
                if bg and bko then
                    for bkn, bks in bko.Value do
                        if bks and autotitus.cnt(bkn) >= 25 then
                            local n = 0
                            while autotitus.cnt(bkn) > 0 and n < 6 do
                                n = n + 1
                                local c0 = autotitus.cnt(bkn)
                                local dep = {}
                                for _, itm in local_player.instance.Backpack:GetChildren() do
                                    if itm.Name == bkn then dep[#dep + 1] = itm end
                                end
                                if #dep == 0 then break end
                                bg:WaitForChild("Choice"):FireServer("deposit", dep)
                                local bt = tick()
                                repeat
                                    if autotitus.ful() then
                                        pcall(function() Logger:short_notify("Bank full, Titus farm stopped.") end)
                                        pcall(function() aztup.automation:set("auto_titus", false) end)
                bank_ran = true;
                local done_banking = false;
                function start_bank()
                
                    local limit = {
                        ["Moonseye Tome"] = 5,
                        ["Idol of Yun'Shul"] = 5,
                        ["Armorer's Needle"] = 5,
                        ["Smith's Alloy"] = 5
                    }
                
                    local should_bank = false;
                    local to_bank = {};
                
                    for _, item in {
                        "Moonseye Tome",
                        "Idol of Yun'Shul",
                        "Armorer's Needle",
                        "Smith's Alloy"
                    } do
                        local quantity = 0;
                        for _, item_instance in local_player.instance.Backpack:GetChildren() do
                            if item_instance.Name:find(item) then
                                quantity = quantity + 1;
                            end
                        end
                    
                        if quantity >= limit[item] then
                            table.clear(to_bank);
                            should_bank = true;
                        
                            for _, item_instance in local_player.instance.Backpack:GetChildren() do
                                if item_instance.Name:find(item) then
                                    table.insert(to_bank, item);
                                    if #to_bank > 10 then break; end
                                    print("banking", item);
                                end
                            end 
                        end
                    end
                
                    if should_bank then
                        local bankGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("BankGui");
                        local args = {
                        	"deposit",
                        	to_bank
                        }
                        bankGui:WaitForChild("Choice"):FireServer(unpack(args))
                        task.spawn(function()
                            task.wait(2.5);
                            game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ChoicePrompt"):WaitForChild("Choice"):InvokeServer(#to_bank);
                        end)
                        task.wait(4);
                        local start_bank = tick();
                        while bankGui:GetAttribute("BankBusy") == false and tick() - start_bank <= 20 do
                            task.wait(0.1)
                        end
                        while bankGui:GetAttribute("BankBusy") == true do
                            task.wait(0.1)
                        end
                        task.wait(3.5);
                        done_banking = true;
                    end;
                end;
                
                if local_player.instance.Backpack:FindFirstChild("Moonseye Tome") then

                    local knowledge = local_player.instance.PlayerGui.CurrencyGui.CurrencyFrame.ShrinePoints.Amount.Text
                    local maximum_knowledge = tonumber(knowledge) >= 200
                
                    if not maximum_knowledge then
                        local_player.instance.Backpack:FindFirstChild("Moonseye Tome").Parent = local_player.character
                        task.wait();
                        local_player.character["Moonseye Tome"]:Activate();
                    end;
                end

                task.spawn(function()
                    while task.wait() do
                        if autotitus.playerCheck(200) then
                            autotitus.serverHop();
                            while task.wait() do end
                        end
                    end;
                end)
                Tween.new(workspace.NPCs:WaitForChild("Banker"):GetPivot() * CFrame.new(0, -6, 0), true, 150).wait();
                
                local start = tick()
                while not game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("BankGui") or tick() - start >= 15 do
                    fireproximityprompt(workspace.NPCs:WaitForChild("Banker").InteractPrompt)
                    local args = {
                    	{
                    		choice = "Can I access my account?"
                    	}
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
                    task.wait();
                end

                if not game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("BankGui") then return; end

                task.spawn(start_bank);
                task.delay(90, function()
                    done_banking = true;
                end)

                start = tick();
                while not done_banking and tick() - start <= 120 do
                    if autotitus.playerCheck(200) then
                        autotitus.serverHop();
                        while task.wait() do end
                    end
                    Tween.new(workspace.NPCs:WaitForChild("Banker"):GetPivot() * CFrame.new(0, -6, 0), true, 150).wait();
                    task.wait();
                end

                if not done_banking then
                    local slot = local_player.instance:GetAttribute("DataSlot")
                    server_utility:hop(slot, true, false);
                end

                self:continuation()]]
            end,
            
            onenter_die = function(self)
                local slot = local_player.instance:GetAttribute("DataSlot");
                server_utility:hop(slot)
            end,
            
            onenter_exit = function(self)
                -- Just respawn, faster way of getting out
                if replicatesignal then
                    replicatesignal(local_player.instance.Kill)
                    task.delay(1, function()
                        if local_player.humanoid.Health <= 1 then return; end
                        
                        local_player.root_part.CFrame *= CFrame.new(0,9e9,0);
                    end);
                else
                    local_player.root_part.CFrame *= CFrame.new(0,9e9,0);
                end
            end
        }
    }),
    
    features = {
        "no_fall",
        "noclip",
        "fly",
        "mob_ai_breaker",
        "auto_loot",
        "auto_equip_weapon",
    },
    
    character_creator_handler_used = true,
    character_creator_handler_opts = {
        gamemode = "Pathfinder",
        origin = "Merit",
        attributes = 'Random'
    }
});

return struct;