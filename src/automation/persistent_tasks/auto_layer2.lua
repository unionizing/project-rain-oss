--!nocheck
if is_regular then
    return {
        run = function()
            local_player.instance:Kick("Attempted to start a beta-only automation whilst not on beta.");
            persistent_data:wipe();
        end
    }
end;
local autofarm_util = require('@src/utility/deepwoken/autofarm_utilitys')
local safety = require('@src/utility/safety')
local automation_struct = require("@src/automation/struct");
local layertwo = {
    temp_tween = function(cf, speed)
        Tween.new(cf, true, speed).wait();
    end,
    m1_hold = function(toggle)
        if not toggle then
            aztup.features.m1_hold.held = false;
            return
        end
        
        aztup.features.m1_hold.held = true
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
    get_blood_jar = function(target)
        local hrp = target:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bloodJar = hrp:FindFirstChild("BloodJar")
            if bloodJar and bloodJar.Value then
                return bloodJar.Value
            end
        end
        
        return nil
    end,
    get_position = function(self, instance)
        if instance:IsA("BasePart") then
            return instance.Position
        end
        
        if instance:IsA("Model") then
            if instance.GetPivot then
                return instance:GetPivot().Position
            elseif instance.PrimaryPart then
                return instance.PrimaryPart.Position
            else
                warn("model or pivot not available")
                return nil
            end
        end
        if instance:IsA("ObjectValue") and instance.Value then
            return self.get_position(self, instance.Value)
        end
        return nil
    end,
    get_nearest = function(self, list, filter)
        local closestObject = nil
        local closest = 9e9;
        for i, v in pairs(list) do
            if filter(v) and (self.get_position(self, v) - local_player.root_part.Position).Magnitude < closest then
                closest = (self.get_position(self, v) - local_player.root_part.Position).Magnitude
                closestObject = v
            end
        end
        return closestObject
    end,

    server_hop = function()
        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:hop(slot, true, true)
    end,
    ready_weapon = function()
        local character_handler = local_player.character:FindFirstChild("CharacterHandler");
        character_handler.Requests.DrawWeapon:FireServer(true);
    end,
    grab_target_chest = function(self, targetchest)
        local time = 3
        local secondsWaited = 0
        
        if targetchest == nil then
            for _, chest in pairs(workspace.Thrown:GetChildren()) do
                if not chest:FindFirstChild("Lid") then continue; end
                
                self.temp_tween(chest.Lid.CFrame, 170)
                local moreTime = 3
                local moreSecondsWaited = 0
                
                repeat 
                    task.wait(.1) 
                    pcall(function()
                        fireproximityprompt(chest:FindFirstChildWhichIsA("ProximityPrompt"));
                    end);
                    pcall(function(...) 
                        self.temp_tween(chest.Lid.CFrame, 170)
                    end)
                    moreSecondsWaited += .1
                until local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or moreSecondsWaited >= moreTime
                
                repeat task.wait(.1); secondsWaited += .1; until not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or secondsWaited >= time
                
                break;
            end
        else
            self.temp_tween(targetchest.Lid.CFrame, 170)
            local moreTime = 3
            local moreSecondsWaited = 0
            
            repeat 
                task.wait(.1) 
                pcall(function()
                    fireproximityprompt(targetchest:FindFirstChildWhichIsA("ProximityPrompt"));
                end);
                pcall(function(...) 
                    self.temp_tween(targetchest.Lid.CFrame, 170)
                end)
                moreSecondsWaited += .1
                local closestDist = (local_player.root_part.Position - closest.Lid.Position).Magnitude
                local chestDist = (local_player.root_part.Position - chest.Lid.Position).Magnitude
                
                if closestDist > chestDist then
                    closest = chest
                end
            end
        end
        
        if closest then
            self.grab_target_chest(self, closest)
        end
    end,
    avatar_exists = function()
        for _, avatar in workspace.Live:GetChildren() do
            if not avatar.Name:match('.avatar') then continue end
            return true
        end
        
        return false
    end,
    detect_bomb_fully_charged = function()
        while task.wait() do
            local specsCount = 0
            
            for _, projectiles in workspace.Thrown:GetChildren() do
                if not projectiles.Name:lower():find('bombspec') then continue end
                specsCount += 1
            end
            
            if specsCount > 7 then
                return
            end
        end
    end,
    detect_bomb_fired = function()
        while task.wait() do
            local specsCount = 0
            
            for _, projectiles in workspace.Thrown:GetChildren() do
                if projectiles.Name:lower():find('bombspec') then
                    specsCount += 1
                end
            end
            
            if specsCount <= 5 then
                return
            end
        end
    end,
    get_highest_point = function()
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = { workspace.Live, workspace.NPCs }
        params.FilterType = Enum.RaycastFilterType.Blacklist
        
        
        local floor = workspace:Raycast(Vector3.new(local_player.root_part.Position.X, 5000, local_player.root_part.Position.Z), Vector3.new(0, -10000, 0), params)
        if not floor or not floor.Instance then
            return 50000
        end
        
        return floor.Position.Y + 1.3;
    end,
    get_nearest_bonespear = function()
        local closest = nil
        
        for _, object in workspace.Thrown:GetChildren() do
            if not object.Name:match('BoneSpear') then continue end
            if not object:FindFirstChild('InteractPrompt') then continue end
            
            if closest == nil then
                closest = object
                continue
            end
            
            if closest then
                local closestDist = (local_player.root_part.Position - closest.Position).Magnitude
                local objectDist = (local_player.root_part.Position - object.Position).Magnitude
                
                if closestDist > objectDist then
                    closest = object
                end
            end
        end 
        
        return closest
    end,
    found_flying_bonespear = function()
        local flyingbonespear = false
        
        for _, spear in workspace.Thrown:GetChildren() do
            if not spear.Name:match('BoneSpear') then continue end
            if not spear:FindFirstChild('InteractPrompt') then
                flyingbonespear = true
                break
            end
        end
        
        return flyingbonespear
    end,
    get_nearest_altar = function()
        local floor_one_done   = true
        local floor_two_done   = true
        
        local closest = nil
        
        for _, altar in workspace.TrueAvatarBossRoom.Floor1Stuff:GetChildren() do
            if not altar.Name:match('Altar') then continue end
            if altar:FindFirstChild('BoneSpear') then continue end
            
            floor_one_done = false
            
            if closest == nil then
                closest = altar
                continue
            end
            
            if closest then
                local closestDist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
                local altarDist = (local_player.root_part.Position - altar:GetPivot().Position).Magnitude
                
                if closestDist > altarDist then
                    closest = altar
                end
            end
        end
        
        if floor_one_done then
            for _, altar in workspace.TrueAvatarBossRoom.Floor2Stuff:GetChildren() do
                if not altar.Name:match('Altar') then continue end
                if altar:FindFirstChild('BoneSpear') then continue end
                
                floor_two_done = false
                
                if closest == nil then
                    closest = altar
                    continue
                end
                
                if closest then
                    local closestDist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
                    local altarDist = (local_player.root_part.Position - altar:GetPivot().Position).Magnitude
                    
                    if closestDist > altarDist then
                        closest = altar
                    end
                end
            end
        end
        
        if floor_two_done then
            for _, altar in workspace.TrueAvatarBossRoom.Floor3Stuff:GetChildren() do
                if not altar.Name:match('Altar') then continue end
                if altar:FindFirstChild('BoneSpear') then continue end
                
                floor_three_done = false
                
                if closest == nil then
                    closest = altar
                    continue
                end
                
                if closest then
                    local closestDist = (local_player.root_part.Position - closest:GetPivot().Position).Magnitude
                    local altarDist = (local_player.root_part.Position - altar:GetPivot().Position).Magnitude
                    
                    if closestDist > altarDist then
                        closest = altar
                    end
                end
            end
        end
        
        return closest
    end,
    send_dialogue = function(text, exit)
        if exit then
            local args = {
                {
                    exit = true
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
            
            return
        end
        
        local args = {
            {
                choice = text
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
        task.wait(0.5)
    end,
}

local struct;
function layertwo:handle_medallions()
    local function initiate_dialogue(character)
        repeat
            pcall(function(...)  
                fireproximityprompt(character.InteractPrompt)
            end)
            task.wait(0.5)
        until local_player.instance.PlayerGui.DialogueGui.Enabled
    end
    
    local medallions = local_player.instance.PlayerGui.CurrencyGui.CurrencyFrame:FindFirstChild('KyrsanMedallions')
    local amount = medallions and medallions.Amount
    
    if not amount or amount and tonumber(amount.Text) < 5 then return end
    repeat task.wait() until local_player.character

    -- Safe player tween behind klaris
    safety:PlayerSafeTween(CFrame.new(5211.48926, -1889.79028, -498.766296, -0.0895125493, 0.000309288444, 0.995985627, 1.03505154e-05, 0.99999994, -0.000309604802, -0.995985687, -1.74045508e-05, -0.0895125493), 250, math.random(3000, 4000))

    local player_check = task.spawn(function()
        while task.wait() do
            if safety:PlayerNear(300) then
                autofarm_util:ServerHop()
            end
        end
    end)
    
    task.wait(1)

    local klaris = workspace.NPCs:FindFirstChild('Klaris')
    
    repeat
        Tween.new(CFrame.new(5211.48926, -1889.79028, -498.766296, -0.0895125493, 0.000309288444, 0.995985627, 1.03505154e-05, 0.99999994, -0.000309604802, -0.995985687, -1.74045508e-05, -0.0895125493), true, 175).wait()
        klaris = workspace.NPCs:FindFirstChild('Klaris')
        task.wait()
    until klaris
    
    initiate_dialogue(klaris)
    
    self.send_dialogue('Why do you need competent people?', nil)
    self.send_dialogue('So where does that leave me?', nil)
    self.send_dialogue("Light Hook? What's that?", nil)
    self.send_dialogue(nil, true)
        
    task.wait(0.5)
        
    initiate_dialogue(klaris)
        
    self.send_dialogue('What do you have to offer?', nil)
    self.send_dialogue('What can you offer for Medallions?')
            
    -- Wait for shop ui to be enabled
    repeat 
        task.wait()
    until local_player.instance.PlayerGui.DialogueGui.DialogueExtents.ShopFrame.Visible and local_player.instance.PlayerGui.DialogueGui.DialogueExtents.ShopFrame:FindFirstChild("Category_Medallion Exchange")
    
    repeat
        local knowledge = local_player.instance.PlayerGui.CurrencyGui.CurrencyFrame.ShrinePoints.Amount.Text
        local maximum_knowledge = tonumber(knowledge) >= 999
        
        if not maximum_knowledge then
            -- Trade medallions for knowledge
            self.send_dialogue('Knowledge [1 Medallion]')
            self.send_dialogue(100)
            self.send_dialogue(nil, true)
            task.wait(0.5)
            initiate_dialogue(klaris)
            
            self.send_dialogue('What do you have to offer?')
            self.send_dialogue('What can you offer for Medallions?')
                
            -- Wait for shop ui to be enabled
            repeat 
                task.wait()
            until local_player.instance.PlayerGui.DialogueGui.DialogueExtents.ShopFrame.Visible and local_player.instance.PlayerGui.DialogueGui.DialogueExtents.ShopFrame:FindFirstChild("Category_Medallion Exchange") or not medallions.Parent or tonumber(amount.Text) < 5
        elseif maximum_knowledge then
            -- Trade medallions for enchant stones / grease
            local choices = {
                '.EnchantStone',
                '.EnchantGrease'
            }
                
            local random_choice = choices[math.random(1, 2)]
                
            local args = {
                {
                    shopchoice = random_choice
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
            task.wait(.5)
        end 
        task.wait()
    until not medallions.Parent or tonumber(amount.Text) < 5
        
    task.wait(0.5)
    self.send_dialogue(nil, true)
    pcall(function(...) task.cancel(player_check) end)
end

function layertwo:floorone()
    local function handle_door()
        autofarm_util:ReadyWeapon(true)
        
        repeat
            pcall(function(...)  
                Tween.new(workspace.NPCs:FindFirstChild('TheKey'):GetPivot(), true, 250).wait()
            end)
            
            pcall(function(...)  
                fireproximityprompt(workspace.NPCs.TheKey.InteractPrompt)
            end)
            task.wait(.5)
        until local_player.instance.PlayerGui.DialogueGui.Enabled
        
        self.send_dialogue(nil, true)
        
        Tween.new(workspace.NPCs:FindFirstChild('TheDoor'):GetPivot(), true, 250).wait()
        
        repeat
            pcall(function(...)  
                fireproximityprompt(workspace.NPCs:FindFirstChild('TheDoor').InteractPrompt)
            end)
            task.wait(.5)
        until local_player.instance.PlayerGui.DialogueGui.Enabled
        
        self.send_dialogue(nil, true)
    end
    
    local function handle_bonekeeper()
        local bonekeeper_location = CFrame.new(-5747, 459, -6357);
        self.temp_tween(bonekeeper_location, 250);
        aztup_toggles.void_mobs:SetValue(true);

        local bonekeeper = nil;
        local real_bonekeeper = nil;

        repeat
            if not bonekeeper then
                self.temp_tween(CFrame.new(-5889, 459, -6308));
            end

            if real_bonekeeper and real_bonekeeper.Parent == nil and not bonekeeper then
                bonekeeper = nil;
                real_bonekeeper = nil;
                break;
            end

            for _, v in workspace.Live:GetChildren() do
                if v == local_player.character then continue end
                if not v.Name:find(".boneboy") then continue end
                real_bonekeeper = v;
                --if not v:FindFirstChild("Target") or not v.Target.Value then continue end
                bonekeeper = v;
            end

            if not bonekeeper then
                self.temp_tween(bonekeeper_location);
            end

            task.wait();
        until bonekeeper;

        self.temp_tween(CFrame.new(-5788, 563, -6351), 250);

        repeat
            task.wait();
        until not workspace.EncounterTriggers:FindFirstChild('BonekeeperBridge')
            or (workspace.EncounterTriggers:FindFirstChild('BoneKeeperBridge') and not workspace.EncounterTriggers.BoneKeeperBridge:FindFirstChild('Barrier'));
    end
    
    local function handle_generator()
        Tween.new(CFrame.new(-5555, 529, -6475), true, 175).wait()
        
        repeat
            task.wait(.5)
            pcall(function(...)  
                fireproximityprompt(workspace.NPCs.TheGenerator.InteractPrompt)
            end)
        until local_player.instance.PlayerGui.DialogueGui.Enabled
        
        self.send_dialogue('[Restart it]')
        self.send_dialogue(nil, true)
    end
    
    local function handle_spawn_chaser(): Model
        self.temp_tween(CFrame.new(-5361, 5000, -4801), 250); -- so we dont get ragdolled and hit our head (ow) or get snow
        local foundchaser = nil;
        repeat
            self.temp_tween(CFrame.new(-5361, 285, -4801), 250);
            task.wait();

            for _, v in workspace.Live:GetChildren() do
                if v == local_player.character then continue end
                if v.Name:find('chaser') then
                    foundchaser = v;
                    break;
                end
            end

            self.temp_tween(CFrame.new(-5224.36523, 194.26561, -4633.03223, -0.803056717, -9.8259835e-20, -0.595902622, -3.56286109e-20, 1, -1.16878229e-19, 0.595902622, -7.26286614e-20, -0.803056717), 250);
            task.wait();
        until foundchaser;

        return foundchaser
    end
    
    local function init_chaser_fight(foundchaser: Model)
        Tween.new(foundchaser:GetPivot(), true, 250).wait()
        
        repeat
            pcall(function(...) 
                fireproximityprompt(foundchaser.InteractPrompt)
            end)
            task.wait(.5)
        until local_player.instance.PlayerGui.DialogueGui.Enabled
        
        self.send_dialogue('Ethiron\'s Wake?')
        self.send_dialogue('What happened here?')
        self.send_dialogue('They mutinied?')
        self.send_dialogue('The City?')
    end
    
    local function handle_chaser_fight(foundchaser: Model): CFrame
        local initchaserlocation = foundchaser.HumanoidRootPart.CFrame
        
        local atb;
        local time = tick()
        local last_frost_grab_use = 0;
            local tween;


        pcall(function(...)         
            repeat
                local bloodjar = self.get_blood_jar(foundchaser)
                local foundDroppables = false
                local chaserdown = foundchaser.HumanoidRootPart:FindFirstChild('REP_SOUND_10463439228')
                local waves = foundchaser.HumanoidRootPart:FindFirstChild('TelegraphAttach') and foundchaser.HumanoidRootPart.TelegraphAttach:FindFirstChild('Ring')
                
                if tick() - time >= 250 and local_player.character.Torso:FindFirstChild('NewSnowClump') then 
                    autofarm_util:Auto_M1(false)
                    repeat
                        Tween.new(CFrame.new(-5898, 479, -5921), true, 190).wait()
                        
                        local closest = nil
                        
                        for _, v in workspace.Layer2Floor1:GetChildren() do
                            if not v:IsA('Model') then continue end
                            if not v:FindFirstChild('BurnOff') then continue end
                            if not v.BurnOff:FindFirstChild('InteractPrompt') then continue end
                            
                            if closest == nil then
                                closest = v.BurnOff
                                continue
                            end
                            
                            if closest then
                                local closestDist = (local_player.root_part.Position - closest.Position).Magnitude
                                local vDist = (local_player.root_part.Position - v.BurnOff.Position).Magnitude
                                
                                if closestDist > vDist then
                                    closest = v.BurnOff
                                end
                            end
                        end
                        
                        pcall(function(...)  
                            fireproximityprompt(closest.InteractPrompt)
                        end)
                        
                        task.wait(1)
                    until not local_player.character.Torso:FindFirstChild('NewSnowClump')
                    
                    time = tick()
                end
                
                for _, v in workspace.SpecialSpikeTrap:GetChildren() do
                    if not v.Name:match('SpikeMod') then continue end
                    if not v:FindFirstChild('Stalagmite') then continue end
                    if not (#v.Stalagmite:GetChildren() > 0) then continue end
                    
                    foundDroppables = true
                end
                
                aztup.features.void_mobs.let_me_void_chaser = true;
                if not (foundchaser.Parent == nil) then
                    local voiding_mode = persistent_data:get("auto_layertwo_void_chaser", false);
                    aztup_toggles.void_mobs:SetValue(voiding_mode and chaserdown);
                    --[[if (foundDroppables or waves) and not foundchaser.HumanoidRootPart:FindFirstChild('REP_SOUND_10463439228') then
                        autofarm_util:Auto_M1(false)
                        Tween.new(CFrame.new(-4708, 633, -5199), true, 115).wait()
                        if not foundchaser.HumanoidRootPart:FindFirstChild('REP_SOUND_10463439228') then
                            task.wait(0.8)
                        end;
                    else]]if bloodjar and not waves and not foundDroppables then
                        Tween.new(CFrame.new(self.get_position(self, bloodjar)), true, 250).wait()
                        if not workspace:FindFirstChild("SpikeStabEff", true) or workspace:FindFirstChild("HitTendril", true) then
                            autofarm_util:Auto_M1(true)
                            task.wait(.1);
                            autofarm_util:Auto_M1(false)
                            task.wait(.1);
                        end;
                    elseif chaserdown then
                        if voiding_mode then
                            autofarm_util:Auto_M1(tick() - last_frost_grab_use > 2 and tick() - last_frost_grab_use < 3)    
                        else
                            autofarm_util:Auto_M1(true)
                        end;

                        -- Attach to head
                        atb = task.spawn(function()
                        end)
                        
                        table.insert(struct.threads, atb);
                        repeat task.wait() until not foundchaser.HumanoidRootPart:FindFirstChild('REP_SOUND_10463439228') or (foundchaser.Parent == nil)
                        task.wait(0.25);
                        pcall(function() task.cancel(atb) end)
                    --[[elseif (foundchaser.Humanoid.Health <= (foundchaser.Humanoid.MaxHealth * 0.20)) then
                        autofarm_util:Auto_M1(false)
                        Tween.new(CFrame.new(-4523, 745, -5069), true, 125).wait()
                    ]]else
                        autofarm_util:Auto_M1(false)
                        Tween.new(CFrame.new(-4523, 745, -5069), true, 125).wait()
                    end
                end
                task.wait()
            until foundchaser.Parent == nil
        end)
        
        pcall(function() task.cancel(atb) end)
        if tween then
            tween.stop();
            tween = nil;
        end;

        autofarm_util:Auto_M1(false)
        
        return initchaserlocation
    end
    
    local function handle_chest(initchaserlocation: CFrame)
        local chaserchest = nil 
        
        repeat
            Tween.new(initchaserlocation * CFrame.new(0, 40, 0), true, 175).wait()
            
            for _, chest in workspace.Thrown:GetChildren() do
                if not chest:FindFirstChild('Lid') then continue end
                
                local dist = (local_player.root_part.Position - chest.Lid.Position).Magnitude
                
                if dist > 400 then continue end
                chaserchest = chest
                break
            end
            
            task.wait()
        until chaserchest
        
        -- Grab chest
        self.grab_target_chest(self, chaserchest)
    end
    
    local function puzzle_skip()
        Tween.new(CFrame.new(-5538.2334, 43.929615, -5194.18164, 0.383664161, 9.29316303e-14, -0.923472703, -8.4064537e-14, 1, 6.57074967e-14, 0.923472703, 5.242169e-14, 0.383664161), true, 175).wait()
        
        local one   = nil
        local two   = nil
        local three = nil
        local four  = nil
        
        for _, puzzlepart in workspace.Layer2Floor1:GetChildren() do
            if not puzzlepart.Name:match('PuzzlePart') then continue end
            if not puzzlepart:FindFirstChild('Requires') then continue end
            
            local req = puzzlepart:FindFirstChild("Requires").Value
            
            if req:match('AShape') then one = puzzlepart; continue; end
            if req:match('DShape') then two = puzzlepart; continue; end
            if req:match('CShape') then three = puzzlepart; continue; end
            if req:match('BShape') then four = puzzlepart; continue; end
            
            if one and two and three and four then break; end
        end
        
        -- Tween to both areas until you find interactprompts in the puzzleparts
        repeat
            Tween.new(CFrame.new(-5579.28174, 6.74480486, -5203.97754, 0.490061522, 4.77236426e-19, 0.871687829, -2.21196962e-19, 1, -4.23128888e-19, -0.871687829, 1.4544488e-20, 0.490061522), true, 175).wait()
            firetouchinterest(local_player.root_part, workspace.EncounterTriggers.TrapDoorPuzzle.Spawner, 0)
            firetouchinterest(local_player.root_part, workspace.EncounterTriggers.TrapDoorPuzzle.Spawner, 1)
            task.wait(1)

            Tween.new(CFrame.new(-5510.97363, 5.74480391, -5181.09619, -0.191880465, -1.82673041e-19, -0.981418312, -1.15571244e-20, 1, -1.83872104e-19, 0.981418312, -2.39390916e-20, -0.191880465), true, 175).wait()
            firetouchinterest(local_player.root_part, workspace.EncounterTriggers.TrapDoorPuzzle.Spawner, 0)
            firetouchinterest(local_player.root_part, workspace.EncounterTriggers.TrapDoorPuzzle.Spawner, 1)
            task.wait(1)
        until one:FindFirstChild('InteractPrompt', true)
        
        Tween.new(one:GetPivot() * CFrame.new(0, 4, 0), true, 175).wait()
        for i = 1, 2 do
            repeat
                pcall(function(...)  
                    fireproximityprompt(one:FindFirstChild('InteractPrompt', true))
                end) 
                task.wait() 
            until one:FindFirstChild('Shifting', true)
            repeat task.wait() until not one:FindFirstChild('Shifting', true)
        end
        
        Tween.new(two:GetPivot() * CFrame.new(0, 4, 0), true, 175).wait()
        repeat
            pcall(function(...)  
                fireproximityprompt(two:FindFirstChild('InteractPrompt', true))
            end) 
            task.wait() 
        until two:FindFirstChild('Shifting', true)
        repeat task.wait() until not two:FindFirstChild('Shifting', true)
        
        Tween.new(three:GetPivot() * CFrame.new(0, 4, 0), true, 175).wait()
        for i = 1, 3 do
            repeat
                pcall(function(...)  
                    fireproximityprompt(three:FindFirstChild('InteractPrompt', true))
                end)
                task.wait() 
            until three:FindFirstChild('Shifting', true)
            repeat task.wait() until not three:FindFirstChild('Shifting', true)
        end
        
        Tween.new(four:GetPivot() * CFrame.new(0, 4, 0), true, 175).wait()
        for i = 1, 4 do
            repeat
                pcall(function(...)  
                    fireproximityprompt(four:FindFirstChild('InteractPrompt', true))
                end) 
                task.wait() 
            until four:FindFirstChild('Shifting', true)
            repeat task.wait() until not four:FindFirstChild('Shifting', true)
        end
        
        Tween.new(workspace.Layer2Floor1.WindPortal.CFrame, true, 175).wait()
        firetouchinterest(local_player.root_part, workspace.Layer2Floor1.WindPortal, 0);
        firetouchinterest(local_player.root_part, workspace.Layer2Floor1.WindPortal, 1);
        firetouchinterest(local_player.root_part, workspace.Layer2Floor1.WindPortal, 0);
        firetouchinterest(local_player.root_part, workspace.Layer2Floor1.WindPortal, 1);
    end
    
    -- Main
    if not persistent_data:get('auto_layertwo_kill_chaser', false) and persistent_data:get('auto_layertwo_killed_chaser', false) then
        puzzle_skip()
        while task.wait() do end
    end
    
    handle_door()
    handle_bonekeeper()
    handle_generator()
    aztup_toggles.void_mobs:SetValue(false);

    local foundchaser = handle_spawn_chaser()
    init_chaser_fight(foundchaser)
    local initchaserlocation = handle_chaser_fight(foundchaser)
    handle_chest(initchaserlocation)
    
    if persistent_data:get('auto_layertwo_kill_ethiron', false) then
        Tween.new(workspace.SecondStage, true, 175).wait()
        return
    end
    
    Tween.new(workspace.InGameLightHook.CFrame, true, 175).wait()
    while task.wait() do end
end

function layertwo:floortwo()
    local function handle_obelisks()
        repeat
            local obelisk = self.get_nearest(self, game.CollectionService:GetTagged('BuzzObelisk'), function(self)
                return self.Name:match('Buzz')
            end)
            if obelisk then
                Tween.new(obelisk.CFrame, true, 175).wait()
                pcall(function(...) 
                    fireproximityprompt(obelisk.InteractPrompt)
                end)
            end
            task.wait()
        until not (#game.CollectionService:GetTagged('BuzzObelisk') > 0)
    end
    
    local function handle_krysan_chests()
        local medallions = local_player.instance.PlayerGui.CurrencyGui.CurrencyFrame:FindFirstChild('KyrsanMedallions')
        local amount = medallions and medallions.Amount
        
        if not amount or amount and not (amount.Text == '250') then
            local chests = {}
            
            for _, chest in workspace.Thrown:GetChildren() do
                if not chest:FindFirstChild('Lid') then continue end
                table.insert(chests, chest)
            end
            
            repeat
                
                local closest = nil
                local currentindex = nil
                
                for index, chest in chests do
                    if not closest then
                        closest = chest
                        currentindex = index
                        continue
                    end
                    
                    if closest then
                        local closestDist = (local_player.root_part.Position - closest.Lid.Position).Magnitude
                        local chestDist = (local_player.root_part.Position - chest.Lid.Position).Magnitude
                        
                        if closestDist > chestDist then
                            closest = chest
                            currentindex = index
                        end
                    end
                end
                
                if closest then
                    Tween.new(closest.Lid.CFrame, true, 175).wait()
                    self.grab_target_chest(self, closest)
                    table.remove(chests, currentindex)
                end
                
                task.wait()
            until #chests == nil or #chests <= 0
        end
    end
    
    local function handle_miserables()
        local miserablesToggled = true
        if miserablesToggled or persistent_data:get('auto_layertwo_kill_champion', false) then
            Tween.new(CFrame.new(263.157104, 1013.80902, 5536.84668, 0.984595954, 2.55551505e-20, 0.174845025, -5.52093428e-20, 1, 1.64738719e-19, -0.174845025, -1.71854152e-19, 0.984595954), true, 175).wait()
            
            local miserables = workspace.NPCs:FindFirstChild('Miserables')
            
            repeat
                miserables = workspace.NPCs:FindFirstChild('Miserables')
                task.wait()
            until miserables
            
            repeat
                pcall(function(...)  
                    fireproximityprompt(miserables.InteractPrompt)
                end)
                task.wait(0.5)
            until local_player.instance.PlayerGui.DialogueGui.Enabled
            
            self.send_dialogue('Rose')
            self.send_dialogue('Relax')
            self.send_dialogue('Peace of mind, friend.')
            self.send_dialogue('I seek power in my upcoming battles.')
            self.send_dialogue("I'm interested.")
            self.send_dialogue('Here are the coins.')
            self.send_dialogue(nil, true)
            
            if persistent_data:get('auto_layertwo_kill_champion', false) then
                Tween.new(CFrame.new(1259.44861, 1189.7738, 5303.23584, 0.0604383796, 0.000191673607, 0.998171926, -0.000752008054, 0.999999702, -0.000146491191, -0.998171628, -0.00074177963, 0.0604385063), true, 175).wait()
                
                local purge_shrine = workspace.NPCs:FindFirstChild('Purge Shrine')
                repeat
                    purge_shrine = workspace.NPCs:FindFirstChild('Purge Shrine')
                    task.wait()
                until purge_shrine
                
                repeat
                    pcall(function(...)  
                        fireproximityprompt(purge_shrine.InteractPrompt)
                    end)
                    task.wait(0.5)
                until local_player.instance.PlayerGui.DialogueGui.Enabled
                
                self.send_dialogue('[Call out]')
                self.send_dialogue(nil, true)
            end
        end
    end
     
    local function handle_ethiron_spawn()
        Tween.new(CFrame.new(787.787598, 1311.22559, 7324.95801), true, 175).wait()
        Tween.new(workspace.NPCs.EthironSummonPodium:GetPivot(), true, 175).wait()
        
        repeat
            pcall(function(...) 
                fireproximityprompt(workspace.NPCs.EthironSummonPodium.InteractPrompt)
            end)
            task.wait(.5)
        until local_player.instance.PlayerGui.DialogueGui.Enabled
        
        self.send_dialogue('[Resist it]')
        self.send_dialogue('[Resist further]')
        self.send_dialogue('[Resist with all that you are]')
        self.send_dialogue('[Breathe out]')
    end
    
    local function handle_ethiron_fight()
        local ultimatedetected = false
        local bonetweenactive = false
        local ethironstunned = false
        
        workspace.DescendantAdded:Connect(function(descendant)
            if descendant.Name:lower():find('bombcharge') then
                if not self.avatar_exists() then return end
                ultimatedetected = true
                
                if bonetweenactive then
                    repeat
                        task.wait()
                    until not bonetweenactive
                end
                
                Tween.new(CFrame.new(787.787598, 1380, 7324.95801), true, 175).wait()
                self.detect_bomb_fully_charged()
                self.detect_bomb_fired()
                Tween.new(CFrame.new(774.600281, 2000, 7465.85791), true, 175).wait()
                ultimatedetected = false
            end
        end)
        
        local avatar = nil
        
        repeat
            for i, v in workspace.Live:GetChildren() do
                if v.Name:find('.avatar') then
                    avatar = v
                    break
                end
            end
            task.wait()
        until avatar
        
        local initavatarheadcf = nil
        
        repeat
            pcall(function(...) 
                initavatarheadcf = avatar:FindFirstChild('Head').CFrame
            end)
            task.wait()
        until initavatarheadcf
        
        avatar.Humanoid.Animator.AnimationPlayed:Connect(function(anim)
            --print(anim.Animation.AnimationId)
            if anim.Animation.AnimationId:match('rbxassetid://10880826811') then
                ethironstunned = true
            end 
            
            if anim.Animation.AnimationId:match('rbxassetid://10978735338') then
                ethironstunned = false
            end
        end)
        
        repeat
            xpcall(function()
                repeat
                    local bonespear = self.get_nearest_bonespear()
                    local bonealtar = self.get_nearest_altar()
                    
                    
                    task.wait()
                until (avatar.Parent == nil)
                
            end, Logger.log)
            task.wait()
        until avatar.Parent == nil
        
        autofarm_util:Auto_M1(false)
    end
    
    local function handle_ethiron_chest()
        Tween.new(CFrame.new(791.660889, 563.343811, 7120.29248), true, 175).wait()
        self.grab_nearest_chest(self)
    end
    
    local function handle_champion_fight()
        if not persistent_data:get('auto_layertwo_kill_champion', false) then return end
        while task.wait() do end
    end
    
    local function handle_champion_chest()
    end
    
    -- Main
    
    autofarm_util:ReadyWeapon(true)
    handle_obelisks()
    handle_krysan_chests()
    handle_miserables()
    handle_ethiron_spawn()
    handle_ethiron_fight()
    handle_ethiron_chest()
    handle_champion_fight()
    handle_champion_chest()
    
    Tween.new(CFrame.new(944.20166, 850.517029, 4173.19775), true, 175).wait()
    firetouchinterest(local_player.root_part, workspace.InGameLightHook, 0);
    firetouchinterest(local_player.root_part, workspace.InGameLightHook, 1);
    firetouchinterest(local_player.root_part, workspace.InGameLightHook, 0);
    firetouchinterest(local_player.root_part, workspace.InGameLightHook, 1);
end

function layertwo:go_to_layer_two()
    local function get_closest_kill_plane()
        local part;
        local dist = 9e9;

        for _, item in workspace:QueryDescendants("#KillPlane") do
            print(item)
            local current_dist = (item.Position - local_player.root_part.Position).Magnitude;

            if current_dist < dist then
                dist = current_dist;
                part = item;
            end;
        end;

        return part;
    end;

    if aztup.flags.no_kill_bricks then
        aztup_toggles.no_kill_bricks:SetValue(false);
    end;

    if local_player.humanoid.Health <= local_player.humanoid.MaxHealth / 2 then
        return local_player.instance:Kick("Too low of health.");
    end;

    local start = tick();
    local plane = get_closest_kill_plane();
    repeat plane = get_closest_kill_plane(); task.wait(); until plane or tick() - start > 15;


    local is_fragments = local_player.instance:GetAttribute('CurrentArea') and local_player.instance:GetAttribute('CurrentArea'):match('Fragments of Self')
    if is_fragments then
        getgenv().dont_auto_hop_pls = true;
        persistent_data:wipe();
        return local_player.instance:Kick("Auto L2 wiped your slot....");
    end

    local playercheck = task.spawn(function()
        while task.wait() do
            if self.player_near() then
                self.server_hop()
            end
        end
    end)
    
    aztup_toggles.fly:SetValue(false);

    local tween;
    while tick() - start < 60 do
        if not plane then break; end
        if tween then tween.stop(); end;
        tween = Tween.new(plane.CFrame, false, 200);
        local_player.root_part.Velocity = Vector3.new(0, -999, 0);
        task.wait();
    end;    

    return local_player.instance:Kick("Failed to enter plane somehow.");
end;

struct = automation_struct:construct({
    persistent_data_store = 'auto_layertwo_store',
    persistent_data_flag = 'auto_layertwo',
    id = 'auto_layertwo',
    
    state_machine = StateMachine.create({
        initial = "idle",
        events = {
            {name = 'start', from = 'idle', to = '_check_area'}, 
            {name = 'todepths', from = '_check_area', to = '_to_layer_two_floor_one'},
            {name = 'depths', from = '_check_area', to = '_to_layer_two_floor_one'},
            {name = 'floorone', from = '_check_area', to = '_floor_one'},
            {name = 'floortwo', from = '_check_area', to = '_floor_two'}
        },
        callbacks = {
            onenter_check_area = function(self)
                if is_eastern or is_etrean then
                    self:todepths()
                    return
                end
                
                pcall(function(...) 
                    local is_floor_one = local_player.instance:GetAttribute('Dungeon'):match('Layer2Floor1')
                    if is_floor_one then
                        self:floorone()
                        return
                    end
                end)
                
                pcall(function(...)  
                    local is_floor_two = local_player.instance:GetAttribute('Dungeon'):match('Layer2Floor2')
                    if is_floor_two then
                        self:floortwo()
                        return
                    end
                end)
                
                if is_depths then
                    self:depths()
                    return
                end
                
                pcall(function(...)  
                    local is_fragments = local_player.instance:GetAttribute('CurrentArea'):match('Fragments of Self')
                    if is_fragments then
                        return
                    end
                end)
            end,
            onenter_to_layer_two_floor_one = function(self)

                if persistent_data:get("auto_layertwo_allow_loops") then return layertwo:go_to_layer_two(); end
                aztup.automation:set("auto_layertwo", false)
                persistent_data:wipe();
                getgenv().dont_auto_hop_pls = true;
                local_player.instance:Kick("Escaped layer 2 successfully - You are in scyphozia/l1f1/depths.");
            end,
            onenter_floor_one = function(self)
                layertwo:floorone()
            end,
            onenter_floor_two = function(self)
                layertwo:floortwo()
            end
        }
    }),
    features = {
        "no_fall",
        "noclip",
        'no_kill_bricks',
        "mod_detector",
        "fly",
        "anti_afk",
        "no_wind",
        "m1_hold",
        "auto_equip_weapon"
    },
    not_allowed = function()
        if not aztup.flags.auto_parry then
            task.delay(1, function() 
                Logger:notify_sound("Skipped running Auto L2 because Auto Parry is not on, Please setup auto parry on your auto load configuration.")
            end)
        end
        return not aztup.flags.auto_parry;
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