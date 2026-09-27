--!nocheck

local automation_struct = require("@src/automation/struct");
local echofarm = {
    playerCheck = function(mag, custom)
         for _, player in services.Players:GetPlayers() do
            if not player.Character then continue end
            if not player.Character:FindFirstChild('HumanoidRootPart') then continue end
            if player == local_player.instance then continue end

            local hmrp = player.Character.HumanoidRootPart

            local dist = ((custom or local_player.root_part.Position) - hmrp.Position).Magnitude

            if (dist <= mag) then
                return true
            end
        end

        return false
    end,
    
    serverHop = function(expiry)
        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:hop(slot, true, false, expiry)
    end,

    player_safe_tween = function(self, cf, speed)
        -- Check for players
        if self.playerCheck(300) then
            -- Serverhop to small server, will kick for now
            self.serverHop()
            while task.wait() do end
        end

        --local ylevel = math.random(400, 600)
        local ylevel = -20


        -- Tween up
        local_player.root_part.CFrame = CFrame.new(local_player.root_part.CFrame.X, 0, local_player.root_part.CFrame.Z);
        --self.tempTween(local_player.root_part.CFrame + Vector3.new(0, local_player.root_part.CFrame.Y + ylevel, 0), speed)

        -- Tween to target location
        self.tempTween(CFrame.new(cf.X, 0, cf.Z), speed)

        -- Check for players
        if self.playerCheck(300, cf.Position) then
            -- Serverhop to small server, will kick for now
            self.serverHop()
            while task.wait() do end
        end

        -- Tween down
        local_player.root_part.CFrame = cf
        --self.tempTween(cf, speed)
    end,

    tempTween = function(cf, speed)
        Tween.new(cf, true, speed).wait();
        --local distance = (Vector3.new(cf.X, 0, cf.Z) - Vector3.new(local_player.root_part.Position.X, 0, local_player.root_part.Position.Z)).Magnitude
        --local tween = services.TweenService:Create(local_player.root_part, TweenInfo.new(distance / (speed or 150), Enum.EasingStyle.Linear,Enum.EasingDirection.InOut), {
        --    CFrame = CFrame.new(cf.Position),
        --})
--
        --tween:Play();
        --tween.Completed:Wait();
    end,
}

function echofarm:craft_soup()
    local finished = false

    local function has_pair_or_soup()
        if local_player.instance:FindFirstChild("Backpack"):FindFirstChild("Mushroom Soup") then return true end

        local hasGobletto  = local_player.instance.Backpack:FindFirstChild("Gobletto") ~= nil
        local hasDentifilo = local_player.instance.Backpack:FindFirstChild("Dentifilo") ~= nil
        local hasBrowncap  = local_player.instance.Backpack:FindFirstChild("Browncap") ~= nil

        local count = (hasGobletto and 1 or 0)
                    + (hasDentifilo and 1 or 0)
                    + (hasBrowncap and 1 or 0)
        return count >= 2
    end

    task.spawn(function()
        task.wait(45)
        -- Safety valve for getting stuck, but never wipe before the pair is actually secured
        while not finished and not has_pair_or_soup() do
            task.wait(1)
        end

        if finished then return end

        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:obliteration(slot)
    end);
    local i = 0;
    local function collect_ingredient(ing)
        self.player_safe_tween(self, ing.CFrame, i == 0 and 250 or 280)
        i += 1;
        local cf = ing.CFrame;

        repeat
            Tween.new(cf, true).wait();

            pcall(function(...)  
                fireproximityprompt(ing:FindFirstChildOfClass('ProximityPrompt'))
            end)
            task.wait()
        until ing.Parent == nil
    end

    local function get_closest_ing(ing)
        local closest = nil

        for _, ingredient in workspace:FindFirstChild('Ingredients'):GetChildren() do
            if ingredient.Name:match(ing) then
                if closest == nil then closest = ingredient; continue; end
                if closest then
                    local closestDist = (local_player.root_part.Position - closest.Position).Magnitude
                    local ingredientDist = (local_player.root_part.Position - ingredient.Position).Magnitude
                    if ingredientDist > 1000 then continue; end
                    if ingredientDist < closestDist then closest = ingredient; continue; end
                end
            end
        end

        return closest
    end

    -- Collect Ingredients
    local function get_ing_pos(name)
        local ing = get_closest_ing(name)
        if ing then
            return ing.Position
        end
        return nil
    end

    local function estimate_pair_cost(a, b)
        local posA = get_ing_pos(a)
        local posB = get_ing_pos(b)
        if not posA or not posB then
            return math.huge
        end

        --local closest_campfire = get_closest_campfire(posB);
        --local closest_campfire_magnitude = closest_campfire and (closest_campfire.Position - posB).Magnitude or 0
        return (local_player.root_part.Position - posA).Magnitude
             + (posA - posB).Magnitude-- + closest_campfire_magnitude
    end
    local hasGobletto  = local_player.instance.Backpack:FindFirstChild("Gobletto") ~= nil
    local hasDentifilo = local_player.instance.Backpack:FindFirstChild("Dentifilo") ~= nil
    local hasBrowncap  = local_player.instance.Backpack:FindFirstChild("Browncap") ~= nil

    local count = (hasGobletto and 1 or 0)
                + (hasDentifilo and 1 or 0)
                + (hasBrowncap and 1 or 0)
    if not local_player.instance.Backpack:FindFirstChild("Mushroom Soup", true) and count < 2 then
        local bestPair, bestCost


        repeat 
            task.wait() 
            consider_pair("Dentifilo", "Gobletto")
            consider_pair("Browncap", "Gobletto")
            consider_pair("Browncap", "Dentifilo")
        until bestPair and #bestPair == 2;

        if bestPair then
            local runs = 0;
            
            local function update_count()
                hasGobletto  = local_player.instance.Backpack:FindFirstChild("Gobletto") ~= nil
                hasDentifilo = local_player.instance.Backpack:FindFirstChild("Dentifilo") ~= nil
                hasBrowncap  = local_player.instance.Backpack:FindFirstChild("Browncap") ~= nil

                count = (hasGobletto and 1 or 0)
                    + (hasDentifilo and 1 or 0)
                    + (hasBrowncap and 1 or 0)
            end

        end
    end

    -- Craft Soup
    --craft()
    finished = true
end
local struct;
local state_machine = StateMachine.create({
    initial = "idle",
    events = {
        {name = 'start', from = 'idle', to = '_check_area'},
        {name = 'continuation', from = '_create_character', to = '_check_area'},

        {name = 'fragments', from = '_check_area', to = '_handle_fragments'},
        {name = 'soup', from = '_check_area', to = '_craft_soup'},
        {name = 'die', from = '_check_area', to = '_die'},
        {name = 'die', from = '_craft_soup', to = '_die'},

        {name = 'cc', from = '_check_area', to = '_create_character'},
    },
    callbacks = {
        onenter_check_area = function(self)
            local is_character_creation = workspace:FindFirstChild('CharacterCreator') and local_player.character.Parent == workspace.CharacterCreator
            task.delay(60, function() --if not done by 60 seconds, serverhop to avoid potential issues
                echofarm.serverHop();
            end)
            if is_character_creation then
                self:cc()
                repeat 
                    task.wait() 
                    is_character_creation = workspace:FindFirstChild('CharacterCreator') and local_player.character.Parent == workspace.CharacterCreator
                until not is_character_creation;
                return;
            end

            if is_eastern then
                -- Hop
                self:die()
                return
            end

            if is_etrean then
                if local_player.instance:GetAttribute('CurrentArea') and local_player.instance:GetAttribute('CurrentArea'):find('Base') then
                    require("@src/features/buttons/respawn")()
                    repeat task.wait() until local_player.instance.PlayerGui:FindFirstChild('SpawnPrompt')
                    local_player.instance.PlayerGui.SpawnPrompt.Choice:FireServer('Inn')
                    repeat task.wait() until local_player.character
                end

                self:soup()
                return
            end
            
            repeat task.wait() until local_player.instance:GetAttribute('CurrentArea');
            local is_fragments = local_player.instance:GetAttribute('CurrentArea'):match('Fragments of Self')
            if is_fragments then
                self:fragments()
                return
            end
        end,

        onenter_create_character = function(self)
            struct:create_character()
            self:continuation()
        end,

        onenter_die = function(self)
            local slot = local_player.instance:GetAttribute("DataSlot");
            server_utility:obliteration(slot)
        end,

        onenter_craft_soup = function(self)
            local hasGobletto  = local_player.instance.Backpack:FindFirstChild("Gobletto") ~= nil
            local hasDentifilo = local_player.instance.Backpack:FindFirstChild("Dentifilo") ~= nil
            local hasBrowncap  = local_player.instance.Backpack:FindFirstChild("Browncap") ~= nil

            local count = (hasGobletto and 1 or 0)
                        + (hasDentifilo and 1 or 0)
                        + (hasBrowncap and 1 or 0)

            while count < 2 do
                echofarm:craft_soup()
                hasGobletto  = local_player.instance.Backpack:FindFirstChild("Gobletto") ~= nil
                hasDentifilo = local_player.instance.Backpack:FindFirstChild("Dentifilo") ~= nil
                hasBrowncap  = local_player.instance.Backpack:FindFirstChild("Browncap") ~= nil
                count = (hasGobletto and 1 or 0)
                    + (hasDentifilo and 1 or 0)
                    + (hasBrowncap and 1 or 0);
                task.wait()
            end;
            --server_utility:rejoin(local_player.instance:GetAttribute("DataSlot"));
            self:die()
        end,

        onenter_handle_fragments = function(self)
            
            local function handleFrag()
                local tpLocation = (workspace.NPCs.Self:GetPivot() - Vector3.new(0,15.7,0)) * CFrame.Angles(math.rad(-45), 0, 0)

                local function get_closest_campfire(pos)
                    local closest = nil 
                
                    for _, campfire in workspace.Thrown:GetChildren() do
                        if not campfire.Name:match('Campfire') then continue end
                        if not campfire:IsA('Model') then continue end
                    
                        local campfirePart = campfire:FindFirstChildOfClass('Part')
                    
                        if closest == nil then
                            closest = campfirePart
                            continue
                        end
                    
                        if closest then
                            local closestDist = ((pos or local_player.root_part.Position) - closest.Position).Magnitude
                            local campfireDist = ((pos or local_player.root_part.Position) - campfirePart.Position).Magnitude
                        
                            if closestDist > campfireDist then
                                closest = campfirePart
                            end
                        end
                    end
                
                    return closest
                end
            
                local function craft()
                    -- Tween to campfire
                    local campfire = get_closest_campfire()
                    repeat task.wait(); campfire = get_closest_campfire(); until campfire;
                    print("got campfire");
                    campfire = campfire.CFrame
                    echofarm:player_safe_tween(campfire, 2800);
                    task.wait();
                
                    local replicatedStorage = game:GetService("ReplicatedStorage")
                    local requests = replicatedStorage:WaitForChild("Requests")
                    local craftRemote = requests:WaitForChild("Craft") :: RemoteFunction

                    local start = tick();
                    repeat 
                        local hasGobletto  = local_player.instance.Backpack:FindFirstChild("Gobletto") ~= nil
                        local hasDentifilo = local_player.instance.Backpack:FindFirstChild("Dentifilo") ~= nil
                        local hasBrowncap  = local_player.instance.Backpack:FindFirstChild("Browncap") ~= nil

                        if echofarm.playerCheck(130, tpLocation.Position) or echofarm.playerCheck(130, local_player.root_part.Position) then
                            -- Serverhop to small server, will kick for now
                            echofarm.serverHop(300)
                            while task.wait() do end
                        end
                        task.wait()
                        if local_player.instance:FindFirstChild("Backpack") and local_player.instance:FindFirstChild("Backpack"):FindFirstChild("Mushroom Soup", true) then break; end
                        Tween.new(campfire, true, 2000).wait();
                        task.spawn(pcall, function()
                            craftRemote:InvokeServer({
                                Gobletto  = hasGobletto,
                                Dentifilo = hasDentifilo,
                                Browncap  = hasBrowncap,
                            })    
                        end);
                    
                        task.wait();
                    until tick() - start > 10 or local_player.instance:FindFirstChild("Backpack") and local_player.instance:FindFirstChild("Backpack"):FindFirstChild("Mushroom Soup", true);
                end
            
                if not local_player.instance:FindFirstChild("Backpack"):FindFirstChild("Mushroom Soup") and (
                    local_player.instance.Backpack:FindFirstChild("Gobletto") ~= nil or
                    local_player.instance.Backpack:FindFirstChild("Dentifilo") ~= nil or
                    local_player.instance.Backpack:FindFirstChild("Browncap") ~= nil
                ) then
                    craft();
                end;

                if echofarm.playerCheck(230, tpLocation.Position) or echofarm.playerCheck(230, local_player.root_part.Position) then
                    -- Serverhop to small server, will kick for now
                    echofarm.serverHop(300)
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

                pcall(function()
                    for _, anim in game:GetService("ReplicatedStorage").Assets.Anims.Mobs.Monky:GetChildren() do
                        local a: AnimationTrack = local_player.humanoid:LoadAnimation(anim);
                        a:Play(0,1,0)
                    end;
                end);

                while task.wait() do
                    local_player.root_part.CFrame = tpLocation;
                    if echofarm.playerCheck(100, tpLocation.Position) then
                        -- Serverhop to small server, will kick for now
                        echofarm.serverHop(300)
                        while task.wait() do end
                    end

                    fireproximityprompt(workspace:WaitForChild("NPCs"):WaitForChild("Self"):WaitForChild("InteractPrompt"))
                    game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer({
                        choice = '[The End]',
                    })
                end;
            end

            xpcall(function(...)  
                handleFrag()
            end, 
            function(...)  
                if not workspace.NPCs:FindFirstChild('Self') then
                    require("@src/features/buttons/respawn")()

                    repeat task.wait() until local_player.character
                    repeat task.wait() until workspace.NPCs:FindFirstChild('Self')
                end

                warn(...);
                handleFrag()
            end)
        end
    }
});
struct = automation_struct:construct({
    persistent_data_store = 'soup_echofarm_store',
    persistent_data_flag = 'soup_echofarm',
    id = 'soup_echofarm',
    rand_attunement = true,

    state_machine = state_machine,
    features = {
        "no_fall",
        "noclip",
        "mod_detector",
        "jesus",
        "fly",
        "auto_equip_weapon",
    },
    not_allowed = function()
        return false;
    end,
    character_creator_handler_used = true,
    character_creator_handler_opts = {
        --gamemode = "Pathfinder",
        origin = persistent_data:get("soup_echo_farm_origin", 'Etris'), -- why?
        modifiers = {"All"},
        attributes = 'Random'
    },
    on_run = function()

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
        Converted["_title"].Text = "Soup Echo Farm"
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
})

return struct;