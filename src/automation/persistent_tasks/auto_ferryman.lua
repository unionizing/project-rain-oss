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

local function get_choice_prompt()
    local player_gui = local_player.instance:FindFirstChild("PlayerGui");
    return player_gui and player_gui:FindFirstChild("ChoicePrompt");
end

local function get_choice_remote(prompt)
    prompt = prompt or get_choice_prompt();
    return prompt and prompt:FindFirstChild("Choice");
end

local function fire_choice(prompt, value)
    local choice = get_choice_remote(prompt);
    if not choice or not choice:IsA("RemoteEvent") then return false end

    return pcall(function()
        choice:FireServer(value);
    end);
end

local function invoke_choice(prompt, value)
    local choice = get_choice_remote(prompt);
    if not choice or not choice:IsA("RemoteFunction") then return false end

    return pcall(function()
        choice:InvokeServer(value);
    end);
end
    local desc_sheet = choice_frame and choice_frame:FindFirstChild("DescSheet");
    local slider_sheet = desc_sheet and desc_sheet:FindFirstChild("SliderSheet");
    local slider = slider_sheet and slider_sheet:FindFirstChild("GenericSlider");
    if not slider then return nil end

    local number = slider:FindFirstChild("Number");
    if not number then return nil end

    local set = slider:FindFirstChild("Set");
    if not set then return tonumber(number.Text) end

    set:Fire(amount);
    task.wait()

    return tonumber(number.Text);
end

local function craft_from_prompt(item, amount)
    local prompt = get_choice_prompt();
    if not prompt then return false end

    local title = prompt_title(prompt);
    if title and title:find("Craft") then
        fire_choice(prompt, item);
    end

    local quantity = set_choice_slider(prompt, amount);
    if quantity then
        invoke_choice(prompt, quantity);
    end

    return true;
end

local function points_awaiting()
    local ok, data = pcall(function()
        return require(services.ReplicatedStorage.Info.DataReplication).GetData();
    end);

    if not ok or not data then return 0 end;

    return tonumber(data.AttributePoints) or 0;
end

local function get_math_textbook()
    local character = local_player.character;
    local backpack = local_player.instance:FindFirstChild('Backpack');

    return (character and character:FindFirstChild('Math Textbook'))
        or (backpack and backpack:FindFirstChild('Math Textbook'));
end

local function needs_book_training()
    return ab_builder:missing_for("Intelligence") > 0
        or ab_builder:missing_for("Willpower") > 0
        or ab_builder:missing_for("Charisma") > 0
end

local function train_math_textbook()
    if not persistent_data:get('auto_progress', false) then
        return
    end;

    if not ab_builder.build_config then
        local wait_start = tick();
        repeat task.wait(0.5) until ab_builder.build_config or tick() - wait_start >= 15;
    end;

    local needed = false;
    for attempt = 1, 3 do
        if needs_book_training() then
            needed = true;
            break;
        end;

        task.wait(1);
    end;

    if not needed then
        return
    end;

    local book = get_math_textbook();
    if not book then
        return
    end;

    aztup_toggles.auto_math_book:SetValue(true);

    local start = tick();
    repeat
        pcall(function()
            local_player.humanoid:EquipTool(book);
            book:Activate();
        end);

        task.wait(1);
    until points_awaiting() <= 0
        or not needs_book_training()
        or tick() - start >= 90
        or not persistent_data:get('auto_progress', false);

    aztup_toggles.auto_math_book:SetValue(false);

    pcall(function() local_player.humanoid:UnequipTools(); end);

end

local hold_m1 = false
local bypassed = false;

local boatmans_watch_path = {
    CFrame.new(-3993 + math.random(1, 5), math.random(10000, 99999), 7901 + math.random(1, 5)),
    CFrame.new(-4005 + math.random(1, 5), math.random(10000, 99999), 9022 + math.random(1, 5)),
    CFrame.new(-4095 + math.random(1, 5), math.random(10000, 99999), 9276 + math.random(1, 5))
};

local autoferryman = {
    temp_tween = function(cf, speed)
        Tween.new(cf, true, bypassed and 999 or speed).wait();
    end,
    has_ankle_weights_equipped = function()
        local character = local_player.character
        if not character then return false end

        local leg = character:FindFirstChild("Left Leg")
        if not leg then return false end

        return leg:FindFirstChild("AnkleWeight") ~= nil
    end,
    equip_ankle_weights = function(self)
        if self.has_ankle_weights_equipped() then return end
        if ab_builder:missing_for("Agility") <= 0 then return end

        local character = local_player.character
        if not character then return end

        local backpack = local_player.instance:FindFirstChild('Backpack')
        local weights = (backpack and backpack:FindFirstChild('Ankle Weights')) or character:FindFirstChild('Ankle Weights')
        if not weights then return end

        pcall(function()
            local_player.humanoid:EquipTool(weights)
            weights:Activate()

            task.wait(0.2)
            local_player.humanoid:UnequipTools()
        end)
    end,
    player_safe_tween = function(self, cf, speed, skip_training, path)
        local use_path = path and (local_player.root_part.Position - cf.Position).Magnitude > 1750

        local training = not skip_training
        task.spawn(function()
            while training do
                self.equip_ankle_weights(self)
                task.wait(1)
            end
        end)

        if self.player_near() then
            -- Serverhop to small server, will kick for now
            self.server_hop()
            while task.wait() do end
        end

        if use_path then
            aztup.automation.requesting_aa_bypass_stop = false;
            
            for _, waypoint in path do
                self.temp_tween(waypoint, speed)

                if self.players_near(waypoint.Position, 300) then
                    self.server_hop()
                    while task.wait() do end
                end
            end
        else
            self.temp_tween(cf, bypassed and 999 or speed)
        end
        -- Check for players
        if self.players_near(Vector3.new(cf.X, cf.Y, cf.Z), 200) then
            -- Serverhop to small server, will kick for now
            self.server_hop()
            while task.wait() do end
        end

        -- Tween down
        local_player.root_part.CFrame = cf
        task.wait(0.4)

        if use_path then
            aztup.automation.requesting_aa_bypass_stop = true;
        end

        training = false
    end,
    player_near = function()
        for _, player in services.Players:GetPlayers() do
            if local_player.instance == player then continue end
            if not player.Character then continue end
            if not player.Character:FindFirstChild('HumanoidRootPart') then continue end
            
            local dist = (local_player.root_part.Position - player.Character:GetPivot().Position).Magnitude
            if dist <= 400 then return true end
        end
        
        return false
    end,
    players_near = function(target, mag)
        for _, player in services.Players:GetPlayers() do
            if not player.Character then continue end
            --if not player.Character:FindFirstChild('HumanoidRootPart') then continue end
            if player == local_player.instance then continue end
                        
            local dist = (target - player.Character:GetPivot().Position).Magnitude
            
            if (dist <= mag) then
                return true
            end
        end
        
        return false
    end,
    server_hop = function()
        local axe = local_player.character and local_player.character:FindFirstChild('Lumber Axe');
        if axe then
            axe.Parent = local_player.instance.Backpack;
            task.wait(0.4);
        end

        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:hop(slot, true, true)
    end,
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
    equip_axe = function()
        local equipped = local_player.character and local_player.character:FindFirstChild('Lumber Axe')
        if equipped then return equipped end

        local stored = local_player.instance.Backpack:FindFirstChild('Lumber Axe')
        if not stored then
            getgenv().dont_auto_hop_pls = true;

            local_player.instance:Kick("No Lumber Axe - auto ferryman needs one to chop wood for campfires.");
            while task.wait() do end
        end

        stored.Parent = local_player.character

        local start = tick()
        repeat task.wait() until (local_player.character and local_player.character:FindFirstChild('Lumber Axe')) or tick() - start >= 3

        return local_player.character and local_player.character:FindFirstChild('Lumber Axe')
    end,
    attunement_elements = {
        Fire = true,
        Ice = true,
        Lightning = true,
        Wind = true,
        Shadow = true,
        Metal = true,
        Blood = true,
        Charisma = true
        --Life = true, this isn't out yet :(
    },
    -- Only these. Anything else can void ferryman (also they're 0 star soooo)
    safe_attunement_mantras = {
        ["Burning Servants"] = true,
        ["Fire Blade"]       = true,
        ["Warden's Blades"]  = true,
        ["Ice Beam"]         = true,
        ["Frozen Servants"]  = true,
        ["Lightning Beam"]   = true,
        ["Lightning Blade"]  = true,
        ["Wind Blade"]       = true,
        ["Tornado Kick"]     = true,
        ["Dark Blade"]       = true,
        ["Clutching Shadow"] = true,
        ["Blood Orb"]        = true,
        ["Metal Eruption"]   = true,
        ["Needle Barrage"]   = true,
        ["Master's Flourish"] = true,
        ["Slice 'n' Dice"] = true,
        ["Taunt"]   = true,
    },
    get_attunement_mantra = function(self)
        local backpack = local_player.instance:FindFirstChild("Backpack");
        if not backpack then return nil end

        for _, item in backpack:GetChildren() do
            if not item.Name:match("^Mantra:") then continue end

            local element = item:GetAttribute("Element");
            if not element or not self.attunement_elements[element] then continue end

            local name = item:GetAttribute("DefaultName") or item.Name:match("{{(.-)}}");
            if name and self.safe_attunement_mantras[name] then
                return item;
            end
        end

        return nil
    end,
    use_attunement = function(self)
        local mantra = self.get_attunement_mantra(self);
        if not mantra then return false end

        local ether = local_player.character:FindFirstChild("Ether");
        if ether and ether.Value <= (mantra:GetAttribute("SpellCost") or 0) then return false end

        local character_handler = local_player.character:FindFirstChild("CharacterHandler");
        local requests = character_handler and character_handler:FindFirstChild("Requests");
        local activate_mantra = requests and requests:FindFirstChild("ActivateMantra");
        if not activate_mantra then return false end

        for _, effect in EffectReplicator:GetEffects() do
            if effect.Class == "ToolLockCD" then
                if effect.Value == mantra.Name then
                    return;
                end
            end
        end
        
        activate_mantra:FireServer(mantra);
        return true
    end,
    loot_from_prompt = function(wanted)
        local choice_prompt = local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt')
        local choice_frame = choice_prompt and choice_prompt:FindFirstChild('ChoiceFrame')
        local options = choice_frame and choice_frame:FindFirstChild('Options')
        local remote = choice_prompt and choice_prompt:FindFirstChild('Choice')

        if not options or not remote then return false end

        local looted = false
        for _, option in options:GetChildren() do
            if not option:IsA('TextButton') then continue end

            local title = option:FindFirstChild('Title')
            local label = ((title and title.Text) or option.Name):lower()

            for _, want in wanted do
                if not label:find(want:lower(), 1, true) then continue end

                remote:FireServer(option.Name)
                looted = true
                task.wait(0.1)
                break
            end
        end

        return looted
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
    grab_chests = function(self, force, wanted, max_distance)
        local time = 3

        local chests = self.find_chests(max_distance or 2000)
        if #chests == 0 then return end

        for _, chest in chests do
            if not force and services.CollectionService:HasTag(chest, 'looted') then continue end

            self.temp_tween(chest.Lid.CFrame, 170)
            local secondsWaited = 0
            local moreTime = 3
            local moreSecondsWaited = 0

            repeat
                task.wait(1)
                pcall(function()
                    fireproximityprompt(chest:FindFirstChildWhichIsA("ProximityPrompt", true));
                end);
                pcall(function(...)
                    self.temp_tween(chest.Lid.CFrame, 170)
                end)
                moreSecondsWaited += 1
            until local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or not aztup.automation:has_any() or moreSecondsWaited >= moreTime

            if wanted then
                pcall(function()
                    self.loot_from_prompt(wanted)
                end)
            end

            repeat task.wait(1); secondsWaited += 1; until not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or not aztup.automation:has_any() or secondsWaited >= time
            
            do
                local prompt = get_choice_prompt();
                local title = prompt and prompt_title(prompt);
                if title and title:find("Craft") then
                    fire_choice(prompt, 'Campfire Pit');
                end;
            end
            
            services.CollectionService:AddTag(chest, 'looted')
        end
    end,
}

function autoferryman:bypass_ac()
    local part = Instance.new("Part", workspace);
    part.Anchored = true;
    part.CanCollide = false;
    part.Transparency = 1;
    Logger:notify("Bypassing Server Anticheat.. may take 10 seconds to 1 minute...")

    local_player.instance:AddTag("ForcedSubject")
    local start = tick();
    while task.wait() and tick() - start < 2 do
        workspace.CurrentCamera.CameraSubject = part;
        local_player.root_part.CFrame = CFrame.new(local_player.root_part.CFrame.X, -1000, local_player.root_part.CFrame.Z);
    end;

    while task.wait() and tick() - start < 2.5 do
        workspace.CurrentCamera.CameraSubject = part;
        local_player.root_part.CFrame = CFrame.new(-2923.05, 50000, 3415.34);
    end;
    Logger:notify("Finished bypassing")
    local_player.instance:RemoveTag("ForcedSubject")
    task.wait(0.5);
    bypassed = true;
end;

function autoferryman:refill()
    --autoferryman:bypass_ac()

    local function collect_ingredient(ing)
    end
    
    local function craft_bread()
    end
    
    local function eat_food(food)
    end
    
    local function isSatiated()
    end
    
    local function get_max_uses()
        local totaluses = 0
        
        if local_player.instance.Backpack:FindFirstChild('Flint') then
            totaluses += local_player.instance.Backpack.Flint.Uses.Value
        end
        
        if local_player.instance.Backpack:FindFirstChild('Umbral Flint') then
            totaluses += local_player.instance.Backpack['Umbral Flint'].Uses.Value
        end
        
        return totaluses
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
    
    -- Destructibles -> Tree
    local function get_closest_tree()
        local closest = nil
        
        for _, tree in workspace.Destructibles:GetChildren() do
            if not tree.Name:match('Tree') then continue end
            if not tree:GetAttribute('StructureHealth') then continue end
            if tree:GetAttribute('StructureHealth') <= 0 then continue end
            
            if closest == nil then
                closest = tree
                continue
            end
            
            if closest then
                local closestDist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
                local treeDist = (local_player.root_part.Position - tree:GetPivot().Position).Magnitude
                
                if closestDist > treeDist then
                    closest = tree
                                    
                    if treeDist > 1000 then
                        closest = nil;
                    end;
                end
            end
        end
        
        return closest
    end
    
    local has_carnivore = local_player.character:GetAttribute("ssv_Passives") and local_player.character:GetAttribute("ssv_Passives"):find("Carnivore")
    if not has_carnivore then
        if not isSatiated() then
            collect_ingredient('Pomar')
            eat_food('Pomar')
        end
        
        if not isSatiated() then
            collect_ingredient('Wheat')
            craft_bread()
            eat_food('Bread')
        end
    end
    
    local boatmans_watch = services.ReplicatedStorage.MarkerWorkspace.AreaMarkers["Boatman's Watch"].AreaMarker.CFrame
    boatmans_watch = CFrame.new(boatmans_watch.X, -2, boatmans_watch.Z);
    
    -- Refill on flint, campfires
    local has_produce_spark     = false
    local has_discovery_of_fire = false
    local has_enough_flint      = (get_max_uses() >= 2)
    local has_enough_campfires  = (local_player.instance.Backpack:FindFirstChild('Campfire Pit') and local_player.instance.Backpack['Campfire Pit'].Quantity.Value >= 4)
    
    local ore_location_water = CFrame.new(-3580.20435, 0, 2956.3147, -0.986956, 1.81373873e-20, 0.160990193, -1.15104129e-20, 1, -1.83226438e-19, -0.160990193, -1.82689495e-19, -0.986956)
    local ore_location = CFrame.new(-3580.20435, 113.092957, 2956.3147, -0.986956, 1.81373873e-20, 0.160990193, -1.15104129e-20, 1, -1.83226438e-19, -0.160990193, -1.82689495e-19, -0.986956)
    
    local playercheck = task.spawn(function()
        while task.wait() do
            if self.player_near() then
                self.server_hop()
            end
        end
    end)
    aztup.automation.requesting_aa_bypass_stop = true;
    if not has_enough_flint and not (has_discovery_of_fire or has_produce_spark) then
        local has_umbral_obsidian = local_player.instance.Backpack:FindFirstChild('Umbral Obsidian')
        local has_coal = local_player.instance.Backpack:FindFirstChild('Coal')
        local has_iron = local_player.instance.Backpack:FindFirstChild('Iron')
        local has_rock = local_player.instance.Backpack:FindFirstChild('Rock')

        if not has_umbral_obsidian then
            self.grab_chests(self, true, { 'Umbral Obsidian', 'Coal' })

            has_umbral_obsidian = local_player.instance.Backpack:FindFirstChild('Umbral Obsidian')
            has_coal = local_player.instance.Backpack:FindFirstChild('Coal')
            has_iron = local_player.instance.Backpack:FindFirstChild('Iron')
            has_rock = local_player.instance.Backpack:FindFirstChild('Rock')
        end
        
        if has_umbral_obsidian and has_coal then
            task.spawn(function()
                local args = {
                    {
                        Coal = true,
                        ["Umbral Obsidian"] = true
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("Craft"):InvokeServer(unpack(args))
            end)
            task.wait(1)
        elseif has_iron and has_coal then
            task.spawn(function()
                local args = {
                    {
                        Coal = true,
                        Iron = true
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("Craft"):InvokeServer(unpack(args))
            end)
            task.wait(1)
        elseif has_rock and has_coal then
            task.spawn(function()
                local args = {
                    {
                        Coal = true,
                        Rock = true
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("Craft"):InvokeServer(unpack(args))
            end)
            task.wait(1)
        else
            --ore_location_water
            self.player_safe_tween(self, ore_location_water, 170)
            self.player_safe_tween(self, ore_location, 170)
            
            repeat
                local nearest_rock = get_closest_ingredient('Rock')
                local nearest_coal = get_closest_ingredient('Coal')
                
                --Mine rock
                if not has_umbral_obsidian then
                    self.temp_tween(nearest_rock.CFrame, 170)
                    for i = 0, 60 do
                        pcall(function(...)  
                            fireproximityprompt(nearest_rock.InteractPrompt)
                        end)
                        
                        if self.player_near() then
                            self.server_hop() 
                            break
                        end
                        task.wait();
                    end
                end

                task.wait(5)
                
                --Mine coal
                if not has_coal then
                    self.temp_tween(nearest_coal.CFrame, 170)
                    for i = 0, 60 do
                        pcall(function(...)  
                            fireproximityprompt(nearest_coal.InteractPrompt)
                        end)
                        
                        if self.player_near() then
                            self.server_hop()
                            break
                        end
                        task.wait();
                    end
                end
                
                if local_player.instance.Backpack:FindFirstChild('Rock') and local_player.instance.Backpack:FindFirstChild('Coal') then
                    task.spawn(function()
                        pcall(function(...)  
                            local args = {
                                {
                                    Coal = true,
                                    Rock = true
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("Craft"):InvokeServer(unpack(args))
                        end)
                    end)
                    --task.wait(1)
                elseif local_player.instance.Backpack:FindFirstChild('Umbral Obsidian') and local_player.instance.Backpack:FindFirstChild('Coal') then
                    task.spawn(function()
                        pcall(function(...)  
                            local args = {
                                {
                                    Coal = true,
                                    ['Umbral Obsidian'] = true
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("Craft"):InvokeServer(unpack(args))
                        end)
                    end)
                    --task.wait(1)
                end
                task.wait(1)
            until get_max_uses() >= 4 or self.player_near()
        end
    end
    
    if not has_enough_campfires then
        -- Tween to Boatmans and Chop trees
        self.player_safe_tween(self, boatmans_watch, 170, false, boatmans_watch_path)

        task.wait(5);
        self.equip_axe()
        local nearest_tree = get_closest_tree()
        
        function has_enough_for_campfire(amount)
            local wood_quantity = local_player.instance.Backpack:FindFirstChild('Wood') and local_player.instance.Backpack.Wood.Quantity.Value or 0;
            local stick_quantity = local_player.instance.Backpack:FindFirstChild('Stick') and local_player.instance.Backpack.Stick.Quantity.Value or 0;
            local campfire_quantity = local_player.instance.Backpack:FindFirstChild('Campfire Pit') and local_player.instance.Backpack:FindFirstChild('Campfire Pit').Quantity.Value or 0;

            local campfires = wood_quantity + campfire_quantity;
            campfires += math.floor(stick_quantity / 3);

            return campfires >= amount;
        end;
    
        -- Go chop some wood if needed and craft campfire pits
        --if not has_enough_for_campfire(4) then
        --local_player.instance.Backpack:FindFirstChild('Lumber Axe').Parent = local_player.character
            local nearest_tree = get_closest_tree()
            self.player_safe_tween(self, nearest_tree:GetPivot(), 170, true)

            repeat
                if nearest_tree.Parent == nil then
                    nearest_tree = get_closest_tree()
                    self.player_safe_tween(self, nearest_tree:GetPivot(), 170, true)
                end

                self.temp_tween(nearest_tree:GetPivot(), 170)
                self.equip_axe():Activate()
                task.wait(.5)
            until has_enough_for_campfire(4)
        self.player_safe_tween(self, boatmans_watch, 170)


            xpcall(function()
                if not game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Stick") or game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Stick").Quantity.Value < 4 then return; end
                task.spawn(function()
                    local args = {
                        {
                            Stick = true
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("Craft"):InvokeServer(unpack(args))
                end)
                local start = tick();
                repeat task.wait() until get_choice_prompt() or tick() - start > 4;
                repeat
                    craft_from_prompt('Campfire Pit', 25);
                    task.wait(1)
                until not get_choice_prompt() or tick() - start >= 30
            end, function()end)

            xpcall(function()
                if not game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Wood") then return; end
                task.spawn(function()
                    local args = {
                        {
                            Wood = true
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("Craft"):InvokeServer(unpack(args))
                end)
                local start = tick();
                repeat task.wait() until get_choice_prompt() or tick() - start > 4;
                repeat
                    craft_from_prompt('Campfire Pit', 25);
                    task.wait(1)
                until (local_player.instance.Backpack:FindFirstChild('Campfire Pit') and local_player.instance.Backpack['Campfire Pit'].Quantity.Value >= 4) or tick() - start >= 30
            end, function()end)    
        --else
        --    repeat
        --        if nearest_tree.Parent == nil then
        --            nearest_tree = get_closest_tree()
        --        end
        --        
        --        self.temp_tween(nearest_tree:GetPivot(), 170)
        --        local_player.character['Lumber Axe']:Activate()
        --        task.wait(.5)
        --    until has_enough_for_campfire(4)
        --    
        --    xpcall(function()
        --        task.spawn(function()
        --            local args = {
        --                {
        --                    Wood = true
        --                }
        --            }
        --            game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("Craft"):InvokeServer(unpack(args))
        --        end)
        --                        local start = tick();
--
        --        repeat
        --            task.spawn(function()
        --                pcall(function(...)  
--
        --                    local title = game:GetService("Players").LocalPlayer.PlayerGui.ChoicePrompt:FindFirstChild("Title", true);
        --                    if title and title.Text:find("Craft") then -- SOME BITCH 
        --                        game:GetService("Players").LocalPlayer.PlayerGui.ChoicePrompt.Choice:FireServer('Campfire Pit')
        --                    end;                        
        --                end)
        --            end)
        --            task.spawn(function()
        --                pcall(function(...)  
        --                    game:GetService("Players").LocalPlayer.PlayerGui.ChoicePrompt.Choice:InvokeServer(4)
        --                end)
        --            end)
        --            task.wait(1)
        --        until (local_player.instance.Backpack:FindFirstChild('Campfire Pit') and local_player.instance.Backpack['Campfire Pit'].Quantity.Value >= 4) or tick() - start >= 30
        --    end, print)
        --end
    end
    
    pcall(function() task.cancel(playercheck) end)
end

function autoferryman:create_instance()
    --autoferryman:bypass_ac()
    local function firestarter()
        local flint = local_player.instance.Backpack:FindFirstChild('Flint')
        local umbral_flint = local_player.instance.Backpack:FindFirstChild('Umbral Flint')
        
        if flint then
            return flint.ActivateRt
        elseif umbral_flint then
            return umbral_flint.ActivateRt
        end
        
        return nil
    end
    
    local area_location = services.ReplicatedStorage.MarkerWorkspace.AreaMarkers["Boatman's Watch"].AreaMarker.CFrame
    
    local dist = (local_player.root_part.Position - area_location.Position).Magnitude
    if dist >= 700 then
        task.spawn(train_math_textbook);
        self.player_safe_tween(self, area_location, bypassed and 999 or 250, false, boatmans_watch_path)
        local_player.root_part.CFrame = CFrame.new(area_location.X, 0, area_location.Z);
    end

    task.wait(1);

    local playercheck = task.spawn(function()
        while task.wait() do
            if self.player_near() then
                self.server_hop()
            end
        end
    end)

    if not workspace:FindFirstChild('MakeFires') then
        Tween.new(area_location, true, bypassed and 999 or 250).wait()
        repeat task.wait() until  workspace:FindFirstChild('MakeFires')
    end
    
    local campfire_locations = workspace:FindFirstChild('MakeFires'):GetChildren()

    repeat task.wait() until local_player.character
    
    services.RunService.Heartbeat:Connect(function() 
        aztup.features.m1_hold.held = hold_m1
    end)

    for _, campfire in workspace.Destructibles:GetChildren() do
        if not campfire.Name:match('Campfire') then continue end
        
        for _, location in campfire_locations do
            local dist = ((campfire:IsA("Model") and campfire:GetPivot() or campfire).Position - location.Position).Magnitude
            if dist <= 200 then 
                self.ready_weapon()
                local t;
                while campfire.Parent do
                    if t then
                        t.stop();
                    end;
                    
                    if not campfire:IsA("Model") and not campfire.Anchored then
                        break;
                    end;

                    if campfire:IsA("Model") and campfire:FindFirstChild("Campfire") and not campfire:FindFirstChild("Campfire").Anchored then
                        break;
                    end;

                    t = Tween.new(CFrame.new((campfire:IsA("Model") and campfire:GetPivot() or campfire).Position), true, bypassed and 999 or 250);
                    self.m1_hold(true)
                    task.wait();
                end;
                self.m1_hold(false)
            end
        end
    end

    local character_handler = local_player.character:FindFirstChild("CharacterHandler");
    character_handler.Requests.DrawWeapon:FireServer(false);
    
    local spoofing = false;
    local spoof_at;

    task.spawn(function() 
        aztup.flags.silent_aim = true;
        while task.wait(1 / 30) do
            if not spoofing then continue end;

            local v809 = buffer.create(24);
            buffer.writef64(v809, 0, spoof_at.X);
            buffer.writef64(v809, 8, spoof_at.Y);
            buffer.writef64(v809, 16, spoof_at.Z);
            local requests = services.ReplicatedStorage:FindFirstChild("Requests");
            local update_mouse = requests and requests:FindFirstChild("UpdateMouse");

            if update_mouse then
                update_mouse:FireServer(v809);
            end;
        end;
    end);

    task.wait(1.5) -- so we dont lagspike and place incorrectly

    local function campfire_count()
        local destructibles = workspace:FindFirstChild('Destructibles')
        if not destructibles then return 0 end

        local count = 0
        for _, campfire in destructibles:GetChildren() do
            if not campfire.Name:match('Campfire') then continue end

            local pivot = (campfire:IsA("Model") and campfire:GetPivot() or campfire).Position
            for _, location in campfire_locations do
                if (pivot - location.Position).Magnitude <= 200 then
                    count += 1
                    break
                end
            end
        end

        return count
    end

    local function campfire_exists_near(position, radius)
        local destructibles = workspace:FindFirstChild('Destructibles')
        if not destructibles then return false end

        for _, campfire in destructibles:GetChildren() do
            if not campfire.Name:match('Campfire') then continue end

            local pivot = (campfire:IsA("Model") and campfire:GetPivot() or campfire).Position
            if (pivot - position).Magnitude <= radius then
                return true
            end
        end

        return false
    end

    local function equip_campfire()
        local equipped = local_player.character and local_player.character:FindFirstChild('Campfire Pit')
        if equipped then return equipped end

        local stored = local_player.instance.Backpack:FindFirstChild('Campfire Pit')
        if not stored or not local_player.character then return nil end

        stored.Parent = local_player.character

        local start = tick()
        repeat task.wait() until (local_player.character and local_player.character:FindFirstChild('Campfire Pit')) or tick() - start >= 3

        return local_player.character and local_player.character:FindFirstChild('Campfire Pit')
    end

    local function place_campfire(location)
        local before = campfire_count()

        for attempt = 1, 16 do
            spoofing = true;
            spoof_at = location.MouseCF;

            self.temp_tween(location.CFrame, 250)
            if local_player.root_part then
                local_player.root_part.AssemblyLinearVelocity = Vector3.zero;
            end
            task.wait(0.5);

            local pit = equip_campfire()
            if not pit then
                if not local_player.instance.Backpack:FindFirstChild('Campfire Pit') then
                    return false
                end

                continue
            end

            pcall(function()
                pit:Activate()
            end)

            local start = tick()
            repeat task.wait() until campfire_count() > before or tick() - start >= 4

            if campfire_count() > before then return true end
        end

        return false
    end

    for _, location in {
        {
            MouseCF = CFrame.new(-4092.21118, 62.9762077, 9410.96094),
            CFrame =  CFrame.new(-4091.36743, 65.8562164, 9406.87793)
        },
        {
            MouseCF =  CFrame.new(-4108.79053, 62.763382, 9421.04004),
            CFrame = CFrame.new(-4109.85938, 65.8506699, 9417.92773)
        },
        {
            MouseCF = CFrame.new(-4096.95654, 62.7243958, 9440.11621),
            CFrame =  CFrame.new(-4098.92334, 65.8594055, 9440.22363),
        },
        {
            MouseCF = CFrame.new(-4080.64844, 62.9762077, 9428.41309),
            CFrame =  CFrame.new(-4078.77832, 65.7046738, 9424.35156),
        }
    } do
        if not campfire_exists_near(location.CFrame.Position, 12) then
            place_campfire(location)
        end
    end
    --aztup.flags.silent_aim = false;

    self.temp_tween(CFrame.new(-4103.17822, 65.7434998, 9413.24609), false, 200);
    task.wait(.5);
    pcall(function(...)  
        firestarter():FireServer()
    end)
    task.wait(3);
    self.temp_tween(CFrame.new(-4086.92041, 65.7434998, 9437.04395), false, 200);
    task.wait(.5);
    pcall(function(...)  
        firestarter():FireServer()
    end)
    task.wait(3);

    --pcall(function() task.cancel(playercheck) end)

    local time_wait = tick()
    repeat task.wait() until ((tick() - time_wait) >= 20)
    self.server_hop()
end

function autoferryman:kill_ferryman()
    if #services.Players:GetPlayers() ~= 1 then
        task.delay(5, function()
            server_utility:hop(local_player.instance:GetAttribute("DataSlot") or "A", true);
        end);

        return local_player.instance:Kick("AAAA WTF GUY IN OUR GAME !!!");
    end;

    services.Players.PlayerAdded:Connect(function() 
        task.delay(5, function()
            server_utility:hop(local_player.instance:GetAttribute("DataSlot") or "A", true);
        end);
        return local_player.instance:Kick("AAAA WTF GUY IN OUR GAME !!!");
    end);

    local function get_closest_tree()
        local closest = nil
        
        for _, tree in workspace.Destructibles:GetChildren() do
            if not tree.Name:match('Tree') then continue end
            if not tree:GetAttribute('StructureHealth') then continue end
            if tree:GetAttribute('StructureHealth') <= 0 then continue end
            
            if closest == nil then
                closest = tree
                continue
            end
            
            if closest then
                local closestDist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
                local treeDist = (local_player.root_part.Position - tree:GetPivot().Position).Magnitude
                
                if closestDist > treeDist then
                    closest = tree
                end
            end
        end
        
        return closest
    end

    
    -- temp until i add anti_afk
    task.spawn(function()
        local vim = Instance.new('VirtualInputManager')
        
        while task.wait(120) do
            vim:SendKeyEvent(true, Enum.KeyCode.Unknown, false, game)
            task.wait(0.1)
            vim:SendKeyEvent(false, Enum.KeyCode.Unknown, false, game)
            task.wait(0.1)
        end
    end)
    
    
    services.RunService.Heartbeat:Connect(function() 
        aztup.features.m1_hold.held = hold_m1
    end)
    
    local initcf = CFrame.new(-4094, 66, 9421)
    local heal_cf = CFrame.new(-3799, -1, 7788)

    aztup.automation.requesting_mob_ai_breaker_stop = true;

    train_math_textbook();

    pcall(function(...)
        self.temp_tween(workspace.NPCs['The Ferryman'].HumanoidRootPart.CFrame, 125)
        
        repeat
            pcall(function(...)  
                fireproximityprompt(workspace.NPCs['The Ferryman'].InteractPrompt)
            end)
            task.wait(.5)
        until local_player.instance.PlayerGui.DialogueGui.Enabled
        
        local args = {
            {
                choice = "Who are you?"
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
        
        task.wait(0.5)
        
        local args = {
            {
                choice = "[Tell him your name]"
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
        
        task.wait(0.5)
        
        local args = {
            {
                choice = "A wager?"
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
        
        task.wait(0.5)
        
        local args = {
            {
                choice = "Deal."
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
        
    end)
    
    local ferryman = nil
    
    repeat 
        for _, target in workspace.Live:GetChildren() do
            if target == local_player.character then continue end
            if not target.Name:lower():find('ferryman') then continue end
            
            ferryman = target
            break
        end
        task.wait()
    until ferryman


    -- Add anim detections
    local tripleattack = false
    local lastassualt = tick()
    local assualtlistener = nil
    
    local javelinattack = false
    local lastjavelin = tick()
    local javelinlistener = nil
    
    ferryman.Humanoid.Animator.AnimationPlayed:Connect(function(anim)
        
        if anim.Animation.AnimationId:match('rbxassetid://5968288116') then
            tripleattack = true
            lastassualt = tick()
            self.m1_hold(false)
            
            if assualtlistener == nil then
                assualtlistener = task.spawn(function()
                    repeat task.wait() until (tick() - lastassualt >= 1.5)
                    self.m1_hold(true)
                    tripleattack = false
                    assualtlistener = nil
                end)
            end
            
            return
        end
        
        if anim.Animation.AnimationId:match('rbxassetid://8183996606') then
            javelinattack = true
            lastjavelin = tick()
            
            if javelinlistener == nil then
                javelinlistener = task.spawn(function()
                    repeat task.wait() until (tick() - lastjavelin >= 1)
                    javelinattack = false
                    javelinlistener = nil
                end)
            end
            
            return
        end
    end)
    
    self.ready_weapon()
    self.m1_hold(true)
    
    local atb = nil
    local tween;
    local last = 0;
    local last_attunement = 0;
    local started_tweening = false;
    xpcall(function()
        repeat
                if (local_player.humanoid.Health <= (local_player.humanoid.MaxHealth * .35)) then
                    self.m1_hold(false)

                    repeat
                        self.m1_hold(false)
                        self.temp_tween(heal_cf, 125)
                        task.wait()
                    until (local_player.humanoid.Health >= (local_player.humanoid.MaxHealth * .85))

                    if not tripleattack then
                        self.m1_hold(true)
                    end
            elseif javelinattack then
                self.temp_tween(CFrame.new(local_player.root_part.CFrame.X, 0, local_player.root_part.CFrame.Z), 125)
                task.wait()
            elseif tripleattack then
                task.wait()
            else
                local start = 0;
                atb = task.spawn(function()
                    while task.wait() do
                        if not aztup.automation:has_any() then break; end
                        if ferryman.Parent == nil then break; end
                        if not ferryman:FindFirstChild('HumanoidRootPart') then break; end
                        if EffectReplicator:FindEffect("Knocked") or EffectReplicator:FindEffect("Ragdoll") then continue; end

                        --* CFrame.Angles(math.rad(-90), 0, 0) 
                        local cf = ferryman.HumanoidRootPart.CFrame * CFrame.new(0, -7, 4) 
                        local target_position = cf.Position
                        local target_cframe = CFrame.lookAt(target_position, ferryman.HumanoidRootPart.Position)
                        local got = false;
                        local_player.root_part.AssemblyLinearVelocity = Vector3.zero; 
                        local_player.root_part.Velocity = Vector3.zero; 

 
                        if not got then
                            last = tick();
                        end

                        if got or (ferryman.HumanoidRootPart.Position - Vector3.new(-4095.33, 68.5, 9425.35)).Magnitude > 13.5 then
                            started_tweening = true;
                        end;

                        aztup.automation.requesting_mob_ai_breaker_stop = not started_tweening or (not got and tick() - last >= 0.2);

                        if aztup.flags.allow_automation_use_solar and EffectReplicator.Passives and EffectReplicator.Passives.Solar and got and start > 0 and tick() - start > 0.5 and tick() - start < 2 then
                            local_player.character.CharacterHandler.Requests.Vent:FireServer()
                        end;

                        if aztup.flags.allow_automation_use_attunements and got and tick() - last_attunement >= 4 then
                            if self.use_attunement(self) then
                                last_attunement = tick();
                            end
                        end;
                    end
                end)
                --table.insert(automation_struct.threads, atb);
                
                repeat task.wait() until tripleattack or javelinattack or ferryman.Parent == nil or (local_player.humanoid.Health <= (local_player.humanoid.MaxHealth * .25))
                
                pcall(function(...) task.cancel(atb) end)
                if tween then
                    tween.stop();
                    tween = nil;
                end;
                aztup.automation.requesting_mob_ai_breaker_stop = true; 
            end
            task.wait()
        until ferryman.Parent == nil
    end, Logger.log)
    aztup.automation.requesting_mob_ai_breaker_stop = true;

    self.m1_hold(false)
    
    repeat task.wait() until workspace.Thrown:FindFirstChild('Model')
    
    task.wait(1)
    
    -- Loot chests nigga
    if aztup.flags.auto_loot then
        self.grab_chests(self)
    end;
    
    -- Talk to ferryman
    self.temp_tween(workspace.NPCs['The Ferryman, Defeated'].HumanoidRootPart.CFrame, 125)
    
    repeat
        pcall(function(...)     
            fireproximityprompt(workspace.NPCs['The Ferryman, Defeated'].InteractPrompt)
        end)
        task.wait(0.5)
    until local_player.instance.PlayerGui.DialogueGui.Enabled
    
    local args = {
        {
            choice = "Who are you?"
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
    
    task.wait(0.5)
    
    local args = {
        {
            exit = true
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
    
    task.wait(0.5)

    persistent_data:set('ferryman_rounds_completed', (persistent_data:get('ferryman_rounds_completed', 0) or 0) + 1);

    -- Leave instance
            {name = 'refill',   from = '_check_area', to = '_refill'},
            {name = 'initiate', from = '_check_area', to = '_initiate'},
            {name = 'initiate', from = '_refill', to = '_initiate'},
            {name = 'kill',     from = '_check_area', to ='_kill'}         
        },
        callbacks = {
            onenter_check_area = function(self)
                aztup.automation.requesting_mob_ai_breaker_stop = true;
                aztup.automation.requesting_aa_bypass_stop = true;
                aztup_options.breaker_type.Value = "Aggressive"
                if is_eastern then  
                    self:refill()
                    self:initiate()
                    return
                end
                
                if is_etrean then
                    -- Teleport to eastern
                    require("@src/features/buttons/teleports/eastern")()
                    return
                end
                
                pcall(function(...)  
                    local is_dungeon = local_player.instance:GetAttribute('Dungeon'):match('Ferryman')
                    if is_dungeon then
                        aztup.automation.requesting_aa_bypass_stop = true;
                        if #services.Players:GetPlayers() > 1 then
                            local_player.instance:Kick('Somehow ended up in another players instance.')
                        end
                        
                        services.Players.PlayerAdded:Connect(function() 
                            local_player.instance:Kick('Somehow ended up in another players instance.')
                        end)
                        self:kill()
                        return
                    end
                end)
                
                if is_depths then
                    aztup.automation:set('auto_ferryman', not persistent_data:get('auto_ferryman', false))
                    local_player.instance:Kick('Somehow ended up in depths.')
                    return
                end
            end,
            onenter_refill = function(self)
                autoferryman:refill()
                self:initiate()
            end,
            onenter_initiate = function(self)
                aztup.automation.requesting_aa_bypass_stop = true;
                autoferryman:create_instance()
            end,
            onenter_kill = function(self)
                autoferryman:kill_ferryman()
            end
        }
    }),
    features = {
        "no_fall",
        "noclip",
        'no_kill_bricks',
        "mod_detector",
        "fly",
        "aa_bypass",
        "m1_hold",
        "anti_fire",
        'auto_wisp',
        "mob_ai_breaker",
        "jesus",
        "auto_decline_guild_invites",
        "auto_decline_squad_invites",
        "auto_train_agility",
        "auto_parry",
        "block_input"
    },
    not_allowed = function()
        return is_depths and persistent_data:get("auto_progress")
    end,
    character_creator_handler_used = false,
    character_creator_handler_opts = {},

    on_run = function()
        aztup.flags.block_input = true;
        aztup_options.blocked_safe_input_user_moves.Value.M1s = true;
        aztup_options.bi_punishable_type.Value = "Always";
    end
})

return struct;