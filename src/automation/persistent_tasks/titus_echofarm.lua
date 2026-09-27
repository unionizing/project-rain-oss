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
        server_utility:hop(slot, true, true);
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

        root.CFrame = CFrame.new(root.CFrame.X, 0, root.CFrame.Z);

        self.tempTween(CFrame.new(cf.X, 0, cf.Z), speed);

        if self.playerCheck(200, cf.Position) then
            self.serverHop();
            while task.wait() do end
        end

        root.CFrame = cf;
    end,
};


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
    aztup_options.loot_options:SetValue({
        'Loot All'
    }) --this breaks user auto loot which we want gone

    local maxDistance = 1000
    local closest = nil
    local findStart = tick()

    repeat
        for _, chest in workspace.Thrown:GetChildren() do
            if not chest:FindFirstChild('Lid') then continue end

            local distance = (local_player.root_part.Position - chest.Lid.Position).Magnitude;
            if distance > maxDistance then continue end

            if not closest or distance < (local_player.root_part.Position - closest.Lid.Position).Magnitude then
                closest = chest
            end
        end
        task.wait()
    until closest or not aztup.automation:has_any() or (tick() - findStart > 15)

    if not closest then
        return
    end

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

    if not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') then
        return
    end

    local time = tick()

    repeat
        task.wait()
        if local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') then
            pcall(function()
                local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt'):FindFirstChild('Choice'):FireServer("LOOT_ALL")
            end)
        end
    until not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or not aztup.automation:has_any() or (tick() - time >= 3)

    if local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') then
        pcall(function(...)
            local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt'):FindFirstChild('Choice'):FireServer('EXIT')
        end)
    end

    self.tempTween(CFrame.new(closest.Lid.CFrame.X, 0, closest.Lid.CFrame.Z), 150)
end

function autotitus:getechoes()
    local player = local_player.instance
    local backpack = player.Backpack
    local character = local_player.character
    
    local function equipWeapon(weaponName)
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:match(weaponName) then
                character.Humanoid:EquipTool(tool)
                task.wait(0.1)
                tool:Activate()
                return true
            end
        end
        return false
    end

    local idol = backpack:FindFirstChild("Idol of Yun'Shul")
    if idol and aztup.automation:has_any() then
        character.Humanoid:EquipTool(idol)
        task.wait(0.3)
        for i = 1, 3 do
            idol:Activate()
            task.wait(0.1);
            if player.PlayerGui:FindFirstChild("ChoicePrompt") then break; end
        end
        
        local prompt = player.PlayerGui:WaitForChild("ChoicePrompt", 5)
        if prompt and prompt:FindFirstChild("Choice") then
            prompt.Choice:FireServer("Give me relief from my Flaws.")
            local start = tick()
            repeat task.wait(0.1) until not player.PlayerGui:FindFirstChild("ChoicePrompt") or tick() - start > 5
        end
    end

    local enchantStone = nil
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:match("Enchant") then
            enchantStone = tool
            break
        end
    end

    if enchantStone and aztup.automation:has_any() then
        local current_weapon = local_player.instance.Backpack:FindFirstChild("Weapon") and local_player.instance.Backpack:FindFirstChild("Weapon").Weapon.Value;
        pcall(function()
            services.ReplicatedStorage:WaitForChild("Requests"):WaitForChild("Unequip"):InvokeServer("Weapon", true)
        end)
        task.wait(0.5)

        equipWeapon(current_weapon); -- i don car
        --if equipWeapon(current_weapon or "Silversix") then
        --    local choicePrompt = player.PlayerGui:WaitForChild('ChoicePrompt', 2)
        --    if choicePrompt and choicePrompt:Fi   ndFirstChild("Choice") then
        --        choicePrompt.Choice:FireServer("Main Weapon")
        --        task.wait(0.2)
        --    end
        --end
        end
        pcall(function() 
            base_require(services.ReplicatedStorage.Info.RealmInfo).IsDepths = true;
        end)
        while task.wait(5) do
            pcall(function() 
                base_require(services.ReplicatedStorage.Info.RealmInfo).IsDepths = true;
            end)
        end
    end);
    local startTime = tick();

    repeat task.wait()
    until (local_player.instance:GetAttribute("CurrentArea") and local_player.instance:GetAttribute("CurrentArea"):match("Detainment"))
        or not aztup.automation:has_any();

    self:attachToTitus();

    local_player.humanoid.Died:Connect(function(...)
        server_utility:obliteration(local_player.instance:GetAttribute("DataSlot"))
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

local state_machine = StateMachine.create({
    initial = "idle",
    events = {
        { name = "start", from = "idle", to = "_check_area" },
        { name = 'continuation', from = '_create_character', to = '_check_area'},
        { name = 'die', from = '_check_area', to = '_die'},
        { name = 'fragments', from = '_check_area', to = '_handle_fragments'},
        { name = "cc",    from = "_check_area", to = "_create_character" },
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

            if is_etrean then
                return self:die();
            end

            if game.PlaceId == eastern_lum then
                return self:enter();
            end

            if game.PlaceId == dungeon then
                self:run();
                return
            end

            repeat task.wait() until local_player.instance:GetAttribute('CurrentArea');
            local is_fragments = local_player.instance:GetAttribute('CurrentArea') and local_player.instance:GetAttribute('CurrentArea'):match('Fragments of Self')
            if is_fragments then
                self:fragments()
                return
            end

            local is_depths = local_player.instance:GetAttribute('CurrentArea') and local_player.instance:GetAttribute('CurrentArea'):match('The Depths')
            if is_depths then
                self:die()
                return
            end
        end,

        onenter_create_character = function(self)
            struct:create_character()
            self:continuation()
        end,

        onenter_enter_dungeon = function(self)
            autotitus:enterDungeon();
        end,

        onenter_run_dungeon = function(self)
            autotitus:runDungeon();
            task.wait(1);

            local_player.root_part.CFrame = local_player.root_part.CFrame * CFrame.new(0, 10000, 0)

            if local_player.humanoid:GetAttribute("DangerExpiration") and local_player.humanoid:GetAttribute("DangerExpiration") > 0 then
                repeat task.wait() until not (local_player.humanoid:GetAttribute("DangerExpiration") and local_player.humanoid:GetAttribute("DangerExpiration") > 0)
            end

            task.defer(self.die, self);
        end,

        onenter_handle_fragments = function(self)
            local function handleFrag()
                local tpLocation = (workspace.NPCs.Self:GetPivot() - Vector3.new(0,15.7,0)) * CFrame.Angles(math.rad(180), math.rad(90), math.rad(180))

                if autotitus.playerCheck(200, tpLocation.Position) then
                    autotitus.serverHop()
                    while task.wait() do end
                end

                local_player.root_part.CFrame = tpLocation;

                local slot = local_player.instance:GetAttribute("DataSlot");
                local chooseSlot = [[
                    if not game:IsLoaded() then game.Loaded:Wait(); end;
                    if game.PlaceId ~= 4111023553 then return; end
                    local slot = "%s";
                    queueonteleport('if game.PlaceId == 4111023553 then return; end; xpcall(function() local sound = Instance.new("Sound", game:GetService("CoreGui")); game:GetService("Debris"):AddItem(sound, 6); sound.Volume = 1.3; sound.SoundId = getcustomasset("Project Rain/assets/notification.mp3"); sound:Play(); end, warn);')
                    game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("WipeSlot"):InvokeServer(slot)
                    task.wait(0.5)
                ]]
                queue_on_teleport(string.format(chooseSlot, slot or "A"))
                
                local get_score = services.ReplicatedStorage:WaitForChild("Requests"):WaitForChild("GetScore");
                get_score.OnClientEvent:Connect(function(v)
                    local wiped_at = tick();
                    persistent_data:set("echoes_gained", persistent_data:get("echoes_gained", 0) + (v and typeof(v) == "table" and v.Echoes or 0))
                    persistent_data:set("cycle_count", persistent_data:get("cycle_count", 0) + 1)
                    persistent_data:set("wiped_at", wiped_at); 
                    get_score:FireServer(); 
                end);

                while task.wait() do
                    local_player.root_part.CFrame = tpLocation;
                    fireproximityprompt(workspace:WaitForChild("NPCs"):WaitForChild("Self"):WaitForChild("InteractPrompt"))
                    game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer({ choice = '[The End]' })
                end;
            end

            task.delay(40, function()
                self.serverHop();
            end);
            local frag_handler;
            frag_handler = function()
                if not workspace.NPCs:FindFirstChild('Self') then
                    require("@src/features/buttons/respawn")()
                    repeat task.wait() until local_player.character and workspace.NPCs:FindFirstChild('Self')
                end

                xpcall(handleFrag, function()
                    task.wait(0.1); 
                    frag_handler();
                end);
            end

            frag_handler();
        end,

        onenter_die = function(self)
            local slot = local_player.instance:GetAttribute("DataSlot");
            server_utility:obliteration(slot)
        end,

        onenter_exit = function(self)
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
});

struct = automation_struct:construct({
    persistent_data_store = "autoecho_titus_store",
    persistent_data_flag  = "autoecho_titus",
    id = "autoecho_titus",
    rand_attunement = true,
    state_machine = state_machine,

    features = {
        "no_fall",
        "noclip",
        "fly",
        "no_one_bit",
        "mob_ai_breaker",
        "jesus",
        "auto_loot",
        "auto_equip_weapon"
    },

    character_creator_handler_used = true,
    character_creator_handler_opts = {
        gamemode = "Pathfinder",
        origin = "Merit",
        weapon = "Sword",
        modifiers = {
            "All"
        },
        attributes = 'Random'
    },
    on_run = function()
        if aztup_toggles.chime_safety then
            aztup_toggles.chime_safety:SetValue(false);
        end

        task.spawn(xpcall, function()
            repeat task.wait(0.1) until aztup_options and aztup_options.loot_options;
        end, warn)
        local Converted = {
            ["_ScreenGui"] = Instance.new("ScreenGui");
            ["_Frame"] = Instance.new("Frame");
            ["_UICorner"] = Instance.new("UICorner");
            ["_UISizeConstraint"] = Instance.new("UISizeConstraint");
            ["_Frame1"] = Instance.new("Frame");
            ["_UICorner1"] = Instance.new("UICorner");
            ["_Objects"] = Instance.new("Frame");
            ["_UIListLayout"] = Instance.new("UIListLayout");
            ["_title"] = Instance.new("TextLabel");
            ["_UIGradient"] = Instance.new("UIGradient");
            ["_Frame2"] = Instance.new("Frame");
            ["_echo_count"] = Instance.new("TextLabel");
            ["_time"] = Instance.new("TextLabel");
            ["_echoes_a_min"] = Instance.new("TextLabel");
            ["_cycles"] = Instance.new("TextLabel");
            ["_stage"] = Instance.new("TextLabel");
            ["_ui notes"] = Instance.new("ModuleScript");
        }
        
        Converted["_ScreenGui"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        Converted["_ScreenGui"].Parent = game:GetService("CoreGui")
        Converted["_ScreenGui"].ScreenInsets = Enum.ScreenInsets.None;
        Converted["_ScreenGui"].OnTopOfCoreBlur = true;

        Converted["_Frame"].AnchorPoint = Vector2.new(1, 0)
        Converted["_Frame"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_Frame"].BackgroundTransparency = 0.800000011920929
        Converted["_Frame"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_Frame"].BorderSizePixel = 0
        Converted["_Frame"].Position = UDim2.new(1, -20, 0, 20)
        Converted["_Frame"].Size = UDim2.new(0, 350, 0, 98)
        Converted["_Frame"].Parent = Converted["_ScreenGui"]
        
        Converted["_UICorner"].CornerRadius = UDim.new(0, 2)
        Converted["_UICorner"].Parent = Converted["_Frame"]
        
        Converted["_UISizeConstraint"].MinSize = Vector2.new(300, 0)
        Converted["_UISizeConstraint"].Parent = Converted["_Frame"]
        
        Converted["_Frame1"].BackgroundColor3 = Color3.fromRGB(160.00000566244125, 195.0000035762787, 229.00000154972076)
        Converted["_Frame1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_Frame1"].BorderSizePixel = 0
        Converted["_Frame1"].Position = UDim2.new(0, 0, 0, -2)
        Converted["_Frame1"].Size = UDim2.new(1, 0, 0, 4)
        Converted["_Frame1"].Parent = Converted["_Frame"]
        
        Converted["_UICorner1"].CornerRadius = UDim.new(0, 2)
        Converted["_UICorner1"].Parent = Converted["_Frame1"]
        
        Converted["_Objects"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_Objects"].BackgroundTransparency = 1
        Converted["_Objects"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_Objects"].BorderSizePixel = 0
        Converted["_Objects"].Position = UDim2.new(0, 0, 0, 4)
        Converted["_Objects"].Size = UDim2.new(1, 0, 1, -4)
        Converted["_Objects"].Name = "Objects"
        Converted["_Objects"].Parent = Converted["_Frame"]
        
        Converted["_UIListLayout"].Padding = UDim.new(0, 10)
        Converted["_UIListLayout"].SortOrder = Enum.SortOrder.LayoutOrder
        Converted["_UIListLayout"].Parent = Converted["_Objects"]
        
        Converted["_title"].FontFace = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.Bold,
            Enum.FontStyle.Normal
        )
        Converted["_title"].Text = "Titus Echo Farm"
        Converted["_title"].TextColor3 = Color3.fromRGB(160.00000566244125, 195.0000035762787, 229.00000154972076)
        Converted["_title"].TextSize = 16
        Converted["_title"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_title"].BackgroundTransparency = 1
        Converted["_title"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_title"].BorderSizePixel = 0
        Converted["_title"].Size = UDim2.new(1, 0, 0, 16)
        Converted["_title"].Name = "title"
        Converted["_title"].Parent = Converted["_Objects"]
        
        Converted["_UIGradient"].Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(0.3499999940395355, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.6499999761581421, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
        }
        Converted["_UIGradient"].Parent = Converted["_title"]
        
        Converted["_Frame2"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_Frame2"].BackgroundTransparency = 1
        Converted["_Frame2"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_Frame2"].BorderSizePixel = 0
        Converted["_Frame2"].Size = UDim2.new(1, 0, 0, 40)
        Converted["_Frame2"].Parent = Converted["_Objects"]
        
        Converted["_echo_count"].FontFace = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.SemiBold,
            Enum.FontStyle.Normal
        )
        Converted["_echo_count"].Text = "got 124 echoes"
        Converted["_echo_count"].TextColor3 = Color3.fromRGB(216.00000232458115, 222.00000196695328, 233.00000131130219)
        Converted["_echo_count"].TextSize = 16
        Converted["_echo_count"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_echo_count"].BackgroundTransparency = 1
        Converted["_echo_count"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_echo_count"].BorderSizePixel = 0
        Converted["_echo_count"].Size = UDim2.new(0.449999988, 0, 0, 16)
        Converted["_echo_count"].Name = "echo_count"
        Converted["_echo_count"].Parent = Converted["_Frame2"]
        
        Converted["_time"].FontFace = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.SemiBold,
            Enum.FontStyle.Normal
        )
        Converted["_time"].Text = "1 hour 2 minutes"
        Converted["_time"].TextColor3 = Color3.fromRGB(153.00000607967377, 199.0000033378601, 148.000006377697)
        Converted["_time"].TextSize = 16
        Converted["_time"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_time"].BackgroundTransparency = 1
        Converted["_time"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_time"].BorderSizePixel = 0
        Converted["_time"].Position = UDim2.new(0.550000012, 0, 0, 0)
        Converted["_time"].Size = UDim2.new(0.449999988, 0, 0, 16)
        Converted["_time"].Name = "time"
        Converted["_time"].Parent = Converted["_Frame2"]
        
        Converted["_echoes_a_min"].FontFace = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.SemiBold,
            Enum.FontStyle.Normal
        )
        Converted["_echoes_a_min"].Text = "4.12e/m"
        Converted["_echoes_a_min"].TextColor3 = Color3.fromRGB(216.00000232458115, 222.00000196695328, 233.00000131130219)
        Converted["_echoes_a_min"].TextSize = 16
        Converted["_echoes_a_min"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_echoes_a_min"].BackgroundTransparency = 1
        Converted["_echoes_a_min"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_echoes_a_min"].BorderSizePixel = 0
        Converted["_echoes_a_min"].Position = UDim2.new(0, 0, 0, 20)
        Converted["_echoes_a_min"].Size = UDim2.new(0.449999988, 0, 0, 16)
        Converted["_echoes_a_min"].Name = "echoes_a_min"
        Converted["_echoes_a_min"].Parent = Converted["_Frame2"]
        
        Converted["_cycles"].FontFace = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.SemiBold,
            Enum.FontStyle.Normal
        )
        Converted["_cycles"].TextColor3 = Color3.fromRGB(216.00000232458115, 222.00000196695328, 233.00000131130219)
        Converted["_cycles"].TextSize = 16
        Converted["_cycles"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_cycles"].BackgroundTransparency = 1
        Converted["_cycles"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_cycles"].BorderSizePixel = 0
        Converted["_cycles"].Position = UDim2.new(0.550000012, 0, 0, 20)
        Converted["_cycles"].Size = UDim2.new(0.449999988, 0, 0, 16)
        Converted["_cycles"].Name = "cycles"
        Converted["_cycles"].Parent = Converted["_Frame2"]
        
        Converted["_stage"].FontFace = Font.new(
            "rbxassetid://12187365364",
            Enum.FontWeight.SemiBold,
            Enum.FontStyle.Normal
        )
        Converted["_stage"].Text = "stage: ???"
        Converted["_stage"].TextColor3 = Color3.fromRGB(216.00000232458115, 222.00000196695328, 233.00000131130219)
        Converted["_stage"].TextSize = 16
        Converted["_stage"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Converted["_stage"].BackgroundTransparency = 1
        Converted["_stage"].BorderColor3 = Color3.fromRGB(0, 0, 0)
        Converted["_stage"].BorderSizePixel = 0
        Converted["_stage"].Size = UDim2.new(1, 0, 0, 16)
        Converted["_stage"].Name = "stage"
        Converted["_stage"].Parent = Converted["_Objects"]

        local function fmt_time(totalSeconds)
            totalSeconds = math.floor(totalSeconds)
        
            if totalSeconds < 60 then
                return totalSeconds .. "s"
            end
        
            local minutes = math.floor(totalSeconds / 60)
            local seconds = totalSeconds % 60
        
            if totalSeconds < 3600 then
                return minutes .. "m " .. seconds .. "s"
            end
        
            local hours = math.floor(minutes / 60)
            local remMinutes = minutes % 60
        
            return hours .. "h " .. remMinutes .. "m"
        end
        local_player.instance:GetAttribute("ShowLeaderboard", false);
        while true do
            Converted["_cycles"].Text = persistent_data:get("cycle_count", 0) .. " cycles"
            Converted["_time"].Text = fmt_time(tick() - persistent_data:get("started_farm_at", tick()));
            
            local echoes_gained = persistent_data:get("echoes_gained", 0)
            local started_at = persistent_data:get("started_farm_at", tick())
            local minutes = math.max(1 / 60, (tick() - started_at) / 60)

            local per_min = echoes_gained / minutes
            Converted["_echoes_a_min"].Text = string.format("%.2f", per_min) .. "e/m"
            Converted["_echo_count"].Text = "got " .. persistent_data:get("echoes_gained", 0) .. " echoes";
            Converted["_stage"].Text = "stage: " .. (state_machine.current:sub(1,1) == "_" and state_machine.current:sub(2) or state_machine.current);

            task.wait(0.2)
        end;
    end
});

return struct;