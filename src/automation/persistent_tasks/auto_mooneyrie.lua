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
local moonseyrie = {
    player_near = function()
        for _, player in services.Players:GetPlayers() do
            if local_player.instance == player then continue end
            if not player.Character then continue end
            if not player.Character:FindFirstChild('HumanoidRootPart') then continue end
            
            local dist = (local_player.root_part.Position - player.Character:GetPivot().Position).Magnitude
            if dist <= 200 then return true end
        end
        
        return false
    end,
    players_near = function(target, mag)
        for _, player in services.Players:GetPlayers() do
            if not player.Character then continue end
            if not player.Character:FindFirstChild('HumanoidRootPart') then continue end
            if player == local_player.instance then continue end
            
            local hmrp = player.Character.HumanoidRootPart
            
            local dist = (target - player.Character:GetPivot().Position).Magnitude
            
            if (dist <= mag) then
                return true
            end
        end
        
        return false
    end,
    player_safe_tween = function(self, cf, speed)
        if self.player_near() then
            -- Serverhop to small server, will kick for now
            self.server_hop()
            while task.wait() do end
        end
        
        local ylevel = math.random(8000, 10000)
        
        -- Tween up
        local_player.root_part.CFrame = local_player.root_part.CFrame + Vector3.new(0, ylevel, 0)
        --self.tempTween(local_player.root_part.CFrame + Vector3.new(0, local_player.root_part.CFrame.Y + ylevel, 0), speed)
        
        -- Tween to target location
        self.temp_tween(self, cf + Vector3.new(0, ylevel, 0), speed)
        
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
    server_hop = function()
        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:hop(slot, 'any', true)
    end,
    temp_tween = function(self, cf, speed)
        Tween.new(cf, true, speed).wait();
    end,
    ready_weapon = function()
        local character_handler = local_player.character:FindFirstChild("CharacterHandler");
        character_handler.Requests.DrawWeapon:FireServer(true);
    end,
    hold_m1 = false,
    auto_m1 = function(self, toggle)
        self.hold_m1 = toggle
    end,
    health_check = function(percent)
        return local_player.humanoid and local_player.humanoid.Health <= (local_player.humanoid.MaxHealth * percent)
    end,
    get_closest_mob = function(name, mag)
        local closest = nil
        
        for _, mob in workspace.Live:GetChildren() do
            if not mob:IsA('Model') then continue end
            if not mob.Name:find(name) then continue end
            
            if not closest then
                
                if mag then 
                    local dist = (local_player.root_part.Position - mob.HumanoidRootPart.Position).Magnitude
                    if dist < mag then
                        closest = mob
                    end
                    
                    continue
                end
                
                closest = mob
                continue
            end
            
            if closest then
                local closestDist = (local_player.root_part.Position - closest.HumanoidRootPart.Position).Magnitude
                local mobDist = (local_player.root_part.Position - mob.HumanoidRootPart.Position).Magnitude
                
                if closestDist > mobDist then
                    closest = mob
                end
            end
        end 
        
        return closest
    end,
    grab_chest = function(self)
        local time = 3
        local secondsWaited = 0
        
        for _, chest in pairs(workspace.Thrown:GetChildren()) do
            if not chest:FindFirstChild("Lid") then continue; end
            
            self.temp_tween(self, chest.Lid.CFrame, 170)
            local moreTime = 3
            local moreSecondsWaited = 0
            
            repeat 
                task.wait(.5) 
                pcall(function()
                    fireproximityprompt(chest:FindFirstChildWhichIsA("ProximityPrompt"));
                end);
                pcall(function(...) 
                    self.temp_tween(self, chest.Lid.CFrame, 170)
                end)
                moreSecondsWaited += .5
            until local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or not aztup.automation:has_any() or moreSecondsWaited >= moreTime or self.player_near()
            
            if self.player_near() then break end
            
            if not self.player_near() then
                repeat task.wait(1); secondsWaited += 1; until not local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt') or not aztup.automation:has_any() or secondsWaited >= time or self.player_near()
            end
            
            break;
        end
    end,
    get_closest_campfire = function()
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
                local closestDist = (local_player.root_part.Position - closest.Position).Magnitude
                local campfireDist = (local_player.root_part.Position - campfirePart.Position).Magnitude
                
                if closestDist > campfireDist then
                    closest = campfirePart
                end
            end
        end
        
        return closest
    end
}

function moonseyrie:kill(target)
    if self.player_near() then return end
    if not target then return end
    if not target:IsA('Model') then return; end
    
    if target.Name:match(local_player.instance.Name) then return; end
    
    local kick_anim_listener = targetAnimator.AnimationPlayed:Connect(function(track)
        if track.Animation.AnimationId:match("106711913879378") or track.Animation.AnimationId:match("111024000122473") and not foundKickAnim then
            foundKickAnim = true
            task.delay(2, function()
                foundKickAnim = false
            end)
        end
    end)
    
    -- Attach to back
    local atb = task.spawn(function()
    end)
    
    local healthTick = tick()
    local healthLastChecked = nil
    
    -- Status Check
    local status = task.spawn(function()
        while task.wait() do
            pcall(function(...)  
                if healthLastChecked == nil then
                    healthTick = tick()
                    healthLastChecked = target.Humanoid.Health
                end
                
                if healthLastChecked then
                    if healthLastChecked ~= target.Humanoid.Health then
                        healthTick = tick()
                        healthLastChecked = target.Humanoid.Health
                    end
                end
            end)
        end
    end)
    
    self:auto_m1(true)
    repeat task.wait(); until not target or target.Parent == nil or not aztup.automation:has_any() or self.player_near() or self.health_check(0.35) or ((tick() - healthTick) >= 20)
    pcall(function(...)  
        kick_anim_listener:Disconnect()
    end)
    xpcall(function() task.cancel(atb); end, Logger.error)
    pcall(function() task.cancel(status); end)
    self:auto_m1(false)
    
    
    if self.health_check(.35) then return end
    if self.player_near() then return true end
    if not aztup.automation:has_any() then return true end
    
    return false
end

function moonseyrie:handle()
    if self.health_check(.35) then
        self.player_safe_tween(self, CFrame.new(-7632.27881, 980.369873, 421.907501, -0.95457083, 1.47911251e-20, 0.297984123, -4.46200836e-20, 1, -1.92574548e-19, -0.297984123, -1.97122129e-19, -0.95457083), 170)
        task.wait(1)
        
        local campfire = self.get_closest_campfire()
        
        repeat
            local_player.root_part.CFrame = campfire.CFrame * CFrame.new(0, 1, 0)
            
            task.wait(1)
            
            fireproximityprompt(campfire.Parent.InteractPrompt)
            
            task.wait(1)
        until EffectReplicator:FindEffect("Resting") or not aztup.automation:has_any()
        
        repeat task.wait() until local_player.humanoid.Health >= (local_player.humanoid.MaxHealth * 0.5);
        
        local VIM = Instance.new('VirtualInputManager')
        
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game);
        task.wait(0.1);
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game);
    
    repeat task.wait(); moons_eye_door = workspace:FindFirstChild('MoonseyeDoor') until moons_eye_door
    
    self.ready_weapon()
    self.player_safe_tween(self, moons_eye_door.CFrame * CFrame.new(0, -5, 0), 170)
    
    repeat
        pcall(function(...)  
            fireproximityprompt(workspace.NPCs:FindFirstChild('MoonDoor'):FindFirstChild('InteractPrompt'))
        end)
        task.wait(.5)
    until local_player.instance.PlayerGui.DialogueGui.Enabled or not aztup.automation:has_any()
    
    local args = {
        {
            choice = "[Interact]"
        }
    }
    services.ReplicatedStorage:WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
    
    self.temp_tween(self, moons_eye_door.CFrame * CFrame.new(0, 0, -100), 170)
    
    local timeWaited = 0
    
    repeat
        task.wait(0.1)
        timeWaited += 0.1
    until timeWaited > 3 or self.player_near() or self.get_closest_mob('moonknight', 60)
    
    if self.player_near() then return end
    
    local knight = self.get_closest_mob('moonknight', 60)
    local knightNil = knight == nil
    
    services.RunService.Heartbeat:Connect(function()
        if self.hold_m1 then
            aztup.features.m1_hold.held = true;
            aztup.flags.no_aerials = true;
        else
            aztup.features.m1_hold.held = false;
            aztup.flags.no_aerials = false;
        end
    end)
    
    self:kill(knight)
    
    -- Look for chest and loot that shit
    if not self.player_near() and not self.health_check(.35) and not knightNil then
        task.wait(0.5)
        self.grab_chest(self)
    end
    
    local knight = self.get_closest_mob('moonknight', 3000)
    local knightNil = knight == nil
    
    if not knightNil then
        self:kill(knight)
    end
end

function moonseyrie:tosafety()
    repeat
        local_player.root_part.CFrame = local_player.root_part.CFrame * CFrame.new(0, math.random(8000, 10000), 0) 
        task.wait() 
    until not self:indanger()
end

function moonseyrie:indanger()
    return local_player.humanoid:GetAttribute("DangerExpiration") and local_player.humanoid:GetAttribute("DangerExpiration") > 0
end

return automation_struct:construct({
    persistent_data_store = 'auto_moonseyrie_store',
    persistent_data_flag = 'auto_moonseyrie',
    id = 'auto_moonseyrie',
    
    state_machine = StateMachine.create({
        initial = "idle",
        events = {
            {name = 'start', from = 'idle', to = '_check_area'},
            {name = 'continuation', from = '_hide', to = '_mooonseyrie'},
            
            {name = 'moons', from = '_check_area', to = '_moonseyrie'},
            
            {name = 'hide', from = '_check_area', to = '_hide'},
            {name = 'hide', from = '_moonseyrie', to = '_hide'},
            
            {name = 'hop', from = '_moonseyrie', to = '_hop'},
            {name = 'hop', from = '_hide', to = '_hop'}
        },
        callbacks = {
            onenter_check_area = function(self)
                if is_depths then
                    aztup.automation:set('auto_moonseyrie', not persistent_data:get('auto_moonseyrie', false))
                    local_player.instance:Kick('Somehow ended up in depths?')
                    getgenv().dont_auto_hop_pls = true;
                    return
                end
                
                if is_eastern then
                    self:moons()
                    return
                end
            end,
            
            onenter_moonseyrie = function(self)
                moonseyrie:handle()
                
                if moonseyrie.player_near() or moonseyrie:indanger() then
                    self:hide()
                    return
                end
                
                self:hop()
            end,
            
            onenter_hide = function(self)
                moonseyrie:tosafety()
                self:hop()
            end,
            
            onenter_hop = function(self)
                moonseyrie.server_hop()
                while task.wait() do end
            end,
        },
    }),
    features = {
        "no_fall",
        "noclip",
        "fly",
        "no_fire",
        "m1_hold",
        "no_stun",
        "fast_swing",
        "auto_equip_weapon"
    },
    
    not_allowed = function()
        return false; --todo
    end,
    
    character_creator_handler_used = false,
    character_creator_handler_opts = {
    }
})