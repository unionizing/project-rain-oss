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
local is_saramed = game.PlaceId == 8668476218

aztup.flags.aa_bypass = not is_saramed

local autosaramed = {
    isCarnivore = function()
        local character = local_player.character;
        local passives = character:GetAttribute("ssv_Passives");
        return passives and passives:find("Carnivore")
    end,
    
    lowHunger = function()
        local stomach = local_player.character:FindFirstChild('Stomach')
        return (stomach.Value <= (stomach.MaxValue * 0.25))
    end,
    
    lowThirst = function()
        local water = local_player.character:FindFirstChild('Water')
        return (water.Value <= (water.MaxValue * 0.25))
    end,
    
    lowBlood = function()
        local blood = local_player.character:FindFirstChild('Blood')
        return (blood.Value <= (blood.MaxValue * 0.25))
    end,
    
    serverHop = function()
        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:hop(slot, true, true)
    end,
    
    refillFood = function(self)
        local stomach = local_player.character:FindFirstChild('Stomach')
        local water   = local_player.character:FindFirstChild('Water')
        
        local ingredients = workspace:FindFirstChild('Ingredients')
        
        local function collectIngredient(self, ing)
            self.playerSafeTween(self, ing.CFrame, 170)
            
            repeat
                pcall(function(...)  
                    local_player.root_part.CFrame = ing.CFrame
                end)
                
                pcall(function() 
                    fireproximityprompt(ing.InteractPrompt)
                end)
                
                task.wait()
            until not ing:FindFirstChild('InteractPrompt')
        end
        
        -- Ill be cleaning up this ugly mess
        local function craftFood(recipe)
            if recipe:match('Bread') then
                local args = {
                    {
                        ['Gathered Wheat'] = local_player.instance:FindFirstChild("Gathered Wheat", true) ~= nil,
                    }
                }
                local requests = services.ReplicatedStorage:WaitForChild("Requests")
                local craftRemote = requests:WaitForChild("Craft") :: RemoteFunction
                
                local gatheredWheat = local_player.instance.Backpack:FindFirstChild('Gathered Wheat')
                local gatheredWheatQuantity = gatheredWheat and gatheredWheat:FindFirstChild('Quantity') and gatheredWheat:FindFirstChild('Quantity').Value
                
                repeat
                    task.spawn(function()
                        pcall(function(...)  
                            craftRemote:InvokeServer(unpack(args))
                        end)
                    end)
                    
                    task.spawn(function()
                        pcall(function(...)  
                            local args = {
                                99
                            }
                            
                            local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt'):FindFirstChild('Choice'):InvokeServer(unpack(args))
                        end)
                    end)
                    task.wait(0.5)
                until local_player.instance.Backpack:FindFirstChild('Bread')
                
                return
            end
        end
        
        local function hungerSatiated()
            return stomach.Value >= (stomach.MaxValue * 0.95)
        end
        
        local function thirstQuenched()
            return water.Value >= (water.Value * 0.95)
        end
        
        local function toNearestCampfire(self)
            local campfire = CFrame.new(-2819.03516, 145.119858, 3001.22266, 0.350389659, -1.64259885e-19, -0.936604023, -4.44767584e-20, 1, -1.92017197e-19, 0.936604023, 1.08937955e-19, 0.350389659)
            self.playerSafeTween(self, campfire, 170)
            task.wait(0.5)
        end
        
        local function eat()
            -- Check inventory for pomars
            if not hungerSatiated() and not thirstQuenched() then
                if local_player.instance.Backpack:FindFirstChild('Pomar') then
                    if local_player.instance.Backpack.Pomar:FindFirstChild('Quantity') then
                        local pomarQuantity = local_player.instance.Backpack.Pomar:FindFirstChild('Quantity').Value
                        
                        local_player.instance.Backpack['Pomar'].Parent = local_player.character
                        
                        for i = 0, pomarQuantity do
                            pcall(function(...)  
                                local_player.character['Pomar']:Activate()
                                task.wait(1)
                            end)
                            
                            if hungerSatiated() then break; end
                        end
                    end 
                end
            end
            
            -- Check inventory for soup
            if not hungerSatiated() and not thirstQuenched() then
                if local_player.instance.Backpack:FindFirstChild('Mushroom Soup') then
                    if local_player.instance.Backpack['Mushroom Soup']:FindFirstChild('Quantity') then
                        local msQuantity = local_player.instance.Backpack['Mushroom Soup']:FindFirstChild('Quantity').Value
                        
                        local_player.instance.Backpack['Mushroom Soup'].Parent = local_player.character
                        
                        for i = 0, msQuantity do
                            pcall(function(...)  
                                local_player.character['Mushroom Soup']:Activate()
                                task.wait(1)
                            end)
                            
                            if hungerSatiated() then break; end
                        end
                    end 
                end
            end
            
            -- Check inventory for bread
            if not hungerSatiated() then
                if local_player.instance.Backpack:FindFirstChild('Bread') then
                    if local_player.instance.Backpack['Bread']:FindFirstChild('Quantity') then
                        local breadQuantity = local_player.instance.Backpack['Bread']:FindFirstChild('Quantity').Value
                        
                        local_player.instance.Backpack['Bread'].Parent = local_player.character
                        
                        for i = 0, breadQuantity do
                            pcall(function(...)  
                                local_player.character['Bread']:Activate()
                                task.wait(1)
                            end)
                            
                            if hungerSatiated() then break; end
                        end
                    end 
                end
            end
        end
        
        eat()
        
        if is_saramed then return; end
        
        -- Search for pomars
        if not hungerSatiated() then
            for _, pomar in ingredients:GetChildren() do
                if not pomar.Name:match('Pomar') then continue end
                if not pomar:FindFirstChild('InteractPrompt') then continue end
                if not pomar:IsA('MeshPart') then continue end
                
                collectIngredient(self, pomar)
                if hungerSatiated() then break; end    
            end
            
            eat()
        end
        
        -- Search for ingredients and craft bread
        if not hungerSatiated() then
            local amountCollected = 0
            
            for _, wheat in ingredients:GetChildren() do
                if not wheat.Name:match('Wheat') then continue; end
                if not wheat:FindFirstChild('InteractPrompt') then continue; end
                if not wheat:IsA('MeshPart') then continue; end
                
                collectIngredient(self, wheat)
                amountCollected += 1
                if amountCollected >= 36 then break end
            end
            
            toNearestCampfire(self)
            
            craftFood('Bread')
            
            eat()
        end
        
        if not thirstQuenched() then
            -- Tween to well and drink nigga drink
            local wellCF = CFrame.new(-2814.17163, 145.319962, 3119.74023, 0.61084187, 1.76499301e-19, -0.791752636, -8.8454953e-20, 1, 1.54678768e-19, 0.791752636, -2.44498239e-20, 0.61084187)
            self.playerSafeTween(self, wellCF, 170)
            
            local VIM = Instance.new('VirtualInputManager')
            
    end,
    
    readyWeapon = function()
        --character.CharacterHandler.Requests.DrawWeapon:FireServer(false);
        local character_handler = local_player.character:FindFirstChild("CharacterHandler");
        character_handler.Requests.DrawWeapon:FireServer(true);
    end,
    
    foundMobs = function()
        local mobsExist = false
        for _, mobModel in pairs(workspace:WaitForChild("Live"):GetChildren()) do
            if mobModel:GetAttribute('MOB_rich_name') then
                mobsExist = true
            end
        end
        
        return mobsExist
    end,
    
    clampCFrame = function(cf)
        return CFrame.new(Vector3.new(cf.Position.X, math.clamp(cf.Position.Y, 0, 1000), cf.Position.Z))
    end,
    
    killTarget = function(self, target)
        if not target then return end
        if not target:IsA('Model') then return; end
        
        if target.Name:match(local_player.instance.Name) then return; end
        
        self.readyWeapon()
        self.tempTween(target.HumanoidRootPart.CFrame, 170)
        
        -- Attach to back
        local attach_tween;
        local atb = task.spawn(function()

            if attach_tween then attach_tween.stop() end
        end)
        
        self.autoM1(true)
        repeat 
            task.wait();
            aztup.features.m1_hold.held = true;
        until self.healthCheck(tonumber('0.' .. aztup.flags.auto_saramed_minimum_health)) or target.Parent == nil or not aztup.automation:has_any()
        xpcall(function() task.cancel(atb); end, Logger.error)
        self.autoM1(false)
        
        return self.healthCheck(tonumber('0.' .. aztup.flags.auto_saramed_minimum_health))
    end,
    
    autoM1 = function(toggle)
        if not toggle then
            aztup.features.m1_hold.held = false
            aztup.flags.no_aerials = false;
            
            return
        end
        
        aztup.features.m1_hold.held = true;
        aztup.flags.no_aerials = true;
    end,
    
    
    getClosestOre = function()
        local closest = nil
        
        for _, magmaOre in workspace:GetDescendants() do
            if not magmaOre then continue; end
            if magmaOre.Parent == nil then continue; end
            if not magmaOre:IsA('MeshPart') then continue; end
            if not magmaOre.Name:match('MagmaOre') then continue; end
            if not magmaOre:FindFirstChild('InteractPrompt') then continue; end
            
            if closest == nil then closest = magmaOre; continue; end
            if closest then
                local closestDist = (local_player.root_part.Position - closest.Position).Magnitude
                local magmaOreDist = (local_player.root_part.Position - magmaOre.Position).Magnitude
                
                if magmaOreDist < closestDist then
                    closest = magmaOre
                end
            end
        end
        
        return closest
    end,
    
    depositOre = function(self)
        local deepdrill = workspace:FindFirstChild('Deepdrill')
        local dungeondrill = deepdrill and deepdrill:FindFirstChild('DungeonDrill')
        local fuelport = dungeondrill and dungeondrill:FindFirstChild('FuelPort')
        local hit = fuelport and fuelport:FindFirstChild('Hit')
        
        self.tempTween(hit.CFrame, 170)
        task.wait(1)
    end,
    
    healthCheck = function(percent)
        return local_player.humanoid and local_player.humanoid.Health <= (local_player.humanoid.MaxHealth * percent)
    end,
    
    tempGetClosest = function()
        local live = workspace:FindFirstChild("Live")
        if not live then return nil end
        
        local closest = nil
        local shortestDistance = math.huge
        
        for _, model in live:GetChildren() do
            if not model:IsA("Model") then continue end
            if model == local_player.character then continue end
            
            if model.Name:sub(1,1) ~= "." then continue end
            
            local root = model:FindFirstChild("HumanoidRootPart") 
            or model.PrimaryPart
            if not root then continue end
            
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if not humanoid then continue end
            
            if humanoid.Health <= 0 then continue end
            if model:FindFirstChild("Torso") and model.Torso:FindFirstChild("RagdollAttach") then continue end
            
            local distance = (root.Position - local_player.root_part.Position).Magnitude
            
            if distance < shortestDistance then
                shortestDistance = distance
                closest = model
            end
        end
        
        return closest
    end,
    
    tempTween = function(cf, speed)
        Tween.new(cf, true, speed).wait();
    end,
    
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
    
    playerSafeTween = function(self, cf, speed)
        -- Check for players
        if self.playerCheck(200) then
            -- Serverhop to small server, will kick for now
            self.serverHop()
            while task.wait() do end
        end
        
        local ylevel = math.random(10000, 30000)
        
        -- Tween up
        local_player.root_part.CFrame = local_player.root_part.CFrame + Vector3.new(0, local_player.root_part.CFrame.Y + ylevel, 0)
        --self.tempTween(local_player.root_part.CFrame + Vector3.new(0, local_player.root_part.CFrame.Y + ylevel, 0), speed)
        
        -- Tween to target location
        self.tempTween(cf + Vector3.new(0, cf.Y + ylevel, 0), speed)
        
        -- Check for players
        if self.playerCheck(200, Vector3.new(cf.X, cf.Y, cf.Z)) then
            -- Serverhop to small server, will kick for now
            self.serverHop()
            while task.wait() do end
        end
        
        -- Tween down
        local_player.root_part.CFrame = cf
        --self.tempTween(cf, speed)
        task.wait(0.3)

        local landed_dist = (local_player.root_part.Position - cf.Position).Magnitude
        if landed_dist > 15 then
            local restore_aa_bypass = aztup.flags.aa_bypass
            aztup.flags.aa_bypass = false

            local_player.root_part.CFrame = cf
            task.wait(0.3)

            aztup.flags.aa_bypass = restore_aa_bypass
        end
    end,
    
    grabChest = function(self)
        local time = 5
        local secondsWaited = 0
        
        for _, chest in pairs(workspace.Thrown:GetChildren()) do
            if not chest:FindFirstChild("Lid") then continue; end
            
            self.tempTween(chest.Lid.CFrame, 170)
            local moreTime = 5
            local moreSecondsWaited = 0
            
            repeat 
                task.wait(.1) 
                pcall(function()
                    fireproximityprompt(chest:FindFirstChildWhichIsA("ProximityPrompt"));
                end);
                pcall(function(...) 
                    self.tempTween(chest.Lid.CFrame, 170)
                end)
                moreSecondsWaited += .1
            until local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or not aztup.automation:has_any() or moreSecondsWaited >= moreTime
            
            repeat task.wait(.1); secondsWaited += .1; until not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or not aztup.automation:has_any() or secondsWaited >= time
            
            break;
        end
    end,
}

function autosaramed:checkArea()
    pcall(function(...)  
        if is_etrean then
            require("@src/features/buttons/teleports/eastern")()
        end
        
        if is_depths then
            task.spawn(function()
                aztup.automation:set("auto_saramed", not persistent_data:get("auto_saramed", false));
            end)
            local_player.instance:Kick("You somehow got into the Depths while auto saramed is enabled.");
            getgenv().dont_auto_hop_pls = true;
        end
    end)
end

function autosaramed:pathTosaramed()
    if is_saramed then return; end
    
    if is_eastern then
        local saramedNpc = CFrame.new(-2856.81104, 135.674957, 3375.38403, 0.541101158, 3.91375053e-19, -0.840957522, -3.07401254e-19, 1, 2.67599571e-19, 0.840957522, 1.13712971e-19, 0.541101158)
        
        if self.lowHunger() or self.lowThirst() and not self.isCarnivore() then self.refillFood(self); end
        self.playerSafeTween(self, saramedNpc, 170)
        
        task.wait(0.5)
        
        repeat task.wait() until workspace.NPCs:FindFirstChild('Malisae')
        
        fireproximityprompt(workspace.NPCs.Malisae.InteractPrompt)
        
        task.wait(3)
        
        local args = {
            {
                choice = 'Enter alone.',
            }
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
        
        task.wait(5)
    end
end

function autosaramed:checkPlayerStatus()
    if not is_saramed then return end
    
    if self.lowHunger() or self.lowThirst() and not self.isCarnivore() then
        local deepdrill = workspace:FindFirstChild('Deepdrill')
        local dungeonExit = deepdrill:FindFirstChild('DungeonExit')
        
        self.refillFood(self)
        
        if not self.lowHunger() and not self.lowThirst() then return; end
        
        self.tempTween(dungeonExit.CFrame, 170)
        -- Fire touchinterest if there is one
        task.wait(3)
        
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
end

function autosaramed:startDungeon()
    if not is_saramed then return; end
    
    repeat task.wait() until local_player.character
    
    if not local_player.instance.Backpack:FindFirstChild('Pickaxe') and not local_player.character:FindFirstChild('Pickaxe') then
        Logger:notify('[AUTO SARAMED] - Please buy a pickaxe.')
        repeat task.wait() until local_player.instance.Backpack:FindFirstChild('Pickaxe') or local_player.character:FindFirstChild('Pickaxe')
    end
    
    local deepdrill = workspace:FindFirstChild('Deepdrill')
    
    local deepDrillDist = (deepdrill.DungeonDrill.Switch.Case.Position - local_player.root_part.Position).Magnitude
    local deepEvatorDist = (deepdrill.Drillevator.Switch.Case.Position - local_player.root_part.Position).Magnitude
    
    if deepDrillDist < deepEvatorDist then
        -- Go to deepdrill
        local_player.root_part.CFrame = CFrame.new(local_player.root_part.CFrame.X, deepdrill.DungeonDrill.Switch.Case.CFrame.Y, local_player.root_part.CFrame.Z);
        self.tempTween(deepdrill.DungeonDrill.Switch.Case.CFrame, 170);
        task.wait(1);
        fireproximityprompt(deepdrill.DungeonDrill.Switch.InteractPrompt);
        task.wait(2);
    elseif deepEvatorDist < deepDrillDist then
        --Go to evator
        local_player.root_part.CFrame = CFrame.new(local_player.root_part.CFrame.X, deepdrill.Drillevator.Switch.Case.CFrame.Y, local_player.root_part.CFrame.Z);
        self.tempTween(deepdrill.Drillevator.Switch.Case.CFrame, 170);
        task.wait(1);
        fireproximityprompt(deepdrill.Drillevator.Switch.InteractPrompt);
        task.wait(2);
    end
end

function autosaramed:completeDungeon()
    if not is_saramed then return; end
    
    repeat task.wait(); until self.foundMobs()
    
    repeat
        pcall(function(...)  
            self.killTarget(self, self.tempGetClosest())
        end)
        
        if self.healthCheck(tonumber('0.' .. aztup.flags.auto_saramed_minimum_health)) then break end
        if not aztup.automation:has_any() then break; end
        task.wait()
    until not self.foundMobs()
    
    if not aztup.automation:has_any() then return; end
    
    if self.healthCheck(tonumber('0.' .. aztup.flags.auto_saramed_minimum_health)) then return end
    
    for i = 0, 5 do
        local closestOre = nil
        repeat
            closestOre = self.getClosestOre()
            task.wait()
        until closestOre ~= nil or not aztup.automation:has_any()
        
        if aztup.automation:has_any() then
            self.mineOre(self, closestOre)
        else
            break
        end
    end
    
    if not aztup.automation:has_any() then return; end
    
    self.depositOre(self)
    
    
    -- This is needed because sometimes the fucking sanity causes the player to itch and does not mine the ore or drops it?? I believe i saw it drop the ore when it itched.
    if workspace:FindFirstChild('Deepdrill').DungeonDrill.FuelPort.Display.SurfaceGui.Bar.BackgroundColor3:ToHex() ~= Color3.fromRGB(141, 239, 112):ToHex() then
        repeat
            for _, ore in workspace:GetDescendants() do
                if not ore:IsA('MeshPart') then continue; end
                if not ore.Name:match('MagmaOre') then continue; end
                if not aztup.automation:has_any() then break end
                
                self.mineOre(self, ore)
                break;
            end
            
            self.depositOre(self)
            
            task.wait()
        until workspace:FindFirstChild('Deepdrill').DungeonDrill.FuelPort.Display.SurfaceGui.Bar.BackgroundColor3:ToHex() == Color3.fromRGB(141, 239, 112):ToHex() or not aztup.automation:has_any()
    end
    
    if not aztup.automation:has_any() then return; end
    
    self.grabChest(self)
end

function autosaramed:resetDungeon()
    if not is_saramed then return; end
    if not aztup.automation:has_any() then return; end
    
    local deepdrill = workspace:FindFirstChild('Deepdrill')
    local dungeondrill = deepdrill and deepdrill:FindFirstChild('DungeonDrill')
    local switch = dungeondrill and dungeondrill:FindFirstChild('Switch')
    local radio = dungeondrill and dungeondrill:FindFirstChild('Radio')
    local destructibles = workspace:FindFirstChild("Destructibles");
    
    -- Tween to switch
    self.tempTween(switch.Case.CFrame, 170)
    
    -- Interact prompt
    repeat
        task.wait()
        pcall(function() 
            fireproximityprompt(radio.InteractPrompt)
        end)
        self.tempTween(switch.Case.CFrame, 170)
    until local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt')
    
    local prompt = local_player.instance.PlayerGui:FindFirstChild("ChoicePrompt");
    prompt.Choice:FireServer(true)
    
    -- Wait until fireplace is detected
    local dist = math.huge
    
    repeat
        task.wait()
        dist = (destructibles.Campfire:FindFirstChildWhichIsA('Part').Position - local_player.root_part.Position).Magnitude
    until dist <= 150
    
    -- If health is above 50% just skip healing and go back down
    if not self.healthCheck(0.5) then return; end
    
    repeat
        self.tempTween(destructibles.Campfire.Part.CFrame, 170)
        local_player.root_part.CFrame = destructibles.Campfire.Part.CFrame * CFrame.new(0, 1, 0)
        
        task.wait(1)
        
        fireproximityprompt(destructibles.Campfire.InteractPrompt)
        
        task.wait(1)
    until EffectReplicator:FindEffect("Resting") or not aztup.automation:has_any()
    
    repeat task.wait() until local_player.humanoid.Health >= (local_player.humanoid.MaxHealth * 0.5);
    
    local VIM = Instance.new('VirtualInputManager')
    
    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game);
    task.wait(0.1);
    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game);
    
    task.wait(1)
    persistent_data_flag = 'auto_saramed',
    id = 'auto_saramed',
    
    state_machine = StateMachine.create({
        initial = "idle",
        events = {
            {name = 'start',               from = 'idle',                 to = '_check_Area'},
            
            {name = 'path',                from = '_check_Area',          to = '_path_To_saramed'},
            
            {name = 'status',              from = '_path_To_saramed',    to = '_check_Player_Status'},
            
            {name = 'dungeonStart',        from = '_check_Player_Status', to = '_start_Dungeon'},
            
            {name = 'dungeonComplete',     from = '_start_Dungeon',       to = '_complete_Dungeon'},
            
            {name = 'dungeonContinuation', from = '_complete_Dungeon',    to = '_start_Dungeon'},
            {name = 'dungeonReset',        from = '_complete_Dungeon',    to = '_reset_Dungeon'},
            
            {name = 'fullReset',           from = '_reset_Dungeon',       to = '_check_Area'},
            
            {name = 'endFarm',             from = '_check_Area',          to = 'idle'},
            {name = 'endFarm',             from = '_path_To_saramed',    to = 'idle'},
            {name = 'endFarm',             from = '_start_Dungeon',       to = 'idle'},
            {name = 'endFarm',             from = '_check_Player_Status', to = 'idle'},
            {name = 'endFarm',             from = '_reset_Dungeon',       to = 'idle'},
            
            
        },
        callbacks = {
            onenter_check_Area = function(self)
                
                if not aztup.maid.disconnect_handler_saramed then
                    aztup.maid.disconnect_handler_saramed = services.GuiService.ErrorMessageChanged:Connect(function()    
                        local Code = services.GuiService:GetErrorCode().Value
                        
                        if Code >= Enum.ConnectionError.DisconnectErrors.Value then
                            local dataSlot = local_player.instance:GetAttribute('DataSlot');
                            services["MemStorageService"]:SetItem('DataSlot', dataSlot);
                            while task.wait() do
                                pcall(function()
                                    autosaramed.serverHop()
                                end);
                            end;
                        end
                    end);
                end
                
                if not aztup.maid.autoDepositOre and is_saramed then
                    aztup.maid.autoDepositOre = task.spawn(function()
                        while task.wait(0.2) do
                            if local_player.character:FindFirstChild("MagmaOre") then
                                local hit = workspace.Deepdrill.DungeonDrill.FuelPort.Hit;
                                firetouchinterest(local_player.character.MagmaOre, hit, 0)
                                firetouchinterest(local_player.character.MagmaOre, hit, 1)
                            end;
                        end;
                    end);
                    
                end
                
                autosaramed:checkArea()
                
                if aztup.automation:has_any() then
                    self:path()
                else
                    self:endFarm()
                end
            end,
            
            onenter_path_To_saramed = function(self)
                autosaramed:pathTosaramed()
                
                if aztup.automation:has_any() then
                    self:status()
                else
                    self:endFarm()
                end
            end,
            
            onenter_check_Player_Status = function(self)
                autosaramed:checkPlayerStatus()
                
                if aztup.automation:has_any() then
                    self:dungeonStart()
                else
                    self:endFarm()
                end
            end,
            
            onenter_start_Dungeon = function(self)
                autosaramed:startDungeon()
                
                if aztup.automation:has_any() then
                    self:dungeonComplete()
                else
                    self:endFarm()
                end
            end,
            
            onenter_complete_Dungeon = function(self)
                autosaramed:completeDungeon()
                
                if not autosaramed.healthCheck(tonumber('0.' .. aztup.flags.auto_saramed_minimum_health)) and not workspace.Deepdrill.DungeonDrill.DepthDisplay.SurfaceGui.TextLabel.Text:find("2.00") then
                    task.defer(self.dungeonContinuation, self)
                else
                    task.defer(self.dungeonReset, self)
                end
            end,
            
            onenter_reset_Dungeon = function(self)
                autosaramed:resetDungeon()
                self:fullReset()
                
                if aztup.automation:has_any() then
                    self:dungeonStart()
                else
                    self:endFarm()
                end
            end,
        },
    }),
    features = {
        "no_fall",
        "noclip",
        "fly",
        "no_fire",
        "no_stun",
        "fast_swing",
        "m1_hold",
        "auto_equip_weapon",
    },
    
    not_allowed = function()
        return false; --todo
    end,
    
    character_creator_handler_used = false,
    character_creator_handler_opts = {
    }
})