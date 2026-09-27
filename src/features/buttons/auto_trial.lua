local autofarm_util = require("@src/utility/deepwoken/autofarm_utilitys");

local SpawnPosition = CFrame.new(114.923668, 1120.30823, 256.767151)

local CombatOffset = {
    Megalodaunt = CFrame.new(0, -20, 0),
    StoneKnight = CFrame.new(0, 8, 8),
    Crocco = CFrame.new(0, -6, 8),
    Angel = CFrame.new(0, -5, 2),
    Enforcer = CFrame.new(0, -6, 0),
    StoneKnight = CFrame.new(0, 8, 8),
    Nomad = CFrame.new(0, 0, 0),
    Megalodaunt_Alpha = CFrame.new(0, -20, 0),
}

local tween;
function attachToBack(Toggle, Target, Custom)
    if not Toggle then
        aztup.maid.UtilAttachToBack = nil
        if tween then
            tween.stop()
        end
        return
    end

    local start = tick();
    aztup.maid.UtilAttachToBack = services.RunService.Heartbeat:Connect(function(dt)
        if Target and Target:FindFirstChild("HumanoidRootPart") and Target.Parent then
            local mobCFrame = Target.HumanoidRootPart.CFrame

            if mobCFrame.Y < -10 then
                local_player.root_part.Velocity = Vector3.zero;
                return            
end

            local offset = Custom or CFrame.new(0, 0, 5)
            local target_position = (mobCFrame * offset).Position

            
            
            

            local target_cframe = CFrame.lookAt(target_position, mobCFrame.Position)
            if (mobCFrame.Position - local_player.root_part.Position).Magnitude > 50 then
                if tween then
                    tween.stop()
                end
                tween = Tween.new(target_cframe, true, 150)
                return            
end

            local_player.root_part.Velocity = Vector3.zero;
            local_player.root_part.CFrame = target_cframe
        elseif tween then
            tween.stop()
        end
    end)
end

function FindMob(Name)
    for _, Mob in pairs(workspace.Live:GetChildren()) do
        if Mob.Name:lower():find(Name:lower()) then
            return Mob
        end
    end
    return false
end

function InitiateCombat(MobName, Offset)
    local Target = FindMob(MobName)
    if not Target then return false end

    if MobName == "Megalodaunt" then
        repeat task.wait() until workspace.Live[Target.Name]:FindFirstChild("HumanoidRootPart")
    
    
    elseif MobName == "Angel" then
        aztup_toggles.void_mobs:SetValue(true)

        aztup_toggles.mob_ai_breaker:SetValue(true)
        task.wait(0.3)
    elseif MobName == "Enforcer" then
        aztup_toggles.void_mobs:SetValue(false)
        aztup_toggles.mob_ai_breaker:SetValue(false)
        task.wait(0.3);
        aztup_toggles.mob_ai_breaker:SetValue(true)
    elseif MobName == "StoneKnight" then
        aztup_toggles.mob_ai_breaker:SetValue(false)
    elseif MobName == "Crocco" then
        task.wait(0.3);
    else
        task.wait(0.3)
    end

    repeat
        if MobName == "Megalodaunt" or MobName == "Megalodaunt_Alpha" then
            attachToBack(true, Target, Offset)
            task.wait(0.2)
        
        

        
        
        
        
        else
            attachToBack(true, Target, Offset)
            task.wait(0.2)
        end

        aztup.features.m1_hold.held = true;
    until not FindMob(MobName)
        aztup.features.m1_hold.held = false;

    return true
end


function HandleTrial()
    game.Players.LocalPlayer.Character:FindFirstChild("DrawWeapon", true):FireServer(true)

    local Backpack = local_player.instance.Backpack
    local_player.humanoid:UnequipTools()
    task.wait(0.1)
    local_player.humanoid:EquipTool(Backpack.Weapon)

    firetouchinterest(workspace.One.OneStartTrigger, local_player.character.Head, 0)
    firetouchinterest(workspace.One.OneStartTrigger, local_player.character.Head, 1)

    Tween.new(SpawnPosition, true, 200).wait();
    local_player.root_part.CFrame = SpawnPosition
  
    while not FindMob("Nomad") do
        task.wait(0.3)
        firetouchinterest(workspace.One.OneTrigger, local_player.character.Head, 0)
        firetouchinterest(workspace.One.OneTrigger, local_player.character.Head, 1)
    end
    Tween.new(CFrame.new(76, 1257, 255), true, 200).wait();

    repeat 
        task.wait()
    until FindMob("Nomad")
    task.wait(0.25);
    game:GetService("Players").LocalPlayer.Character:WaitForChild("CharacterHandler"):WaitForChild("Requests"):WaitForChild("Carry"):FireServer()

    repeat 
        task.wait()
    until not FindMob("Nomad")

   
    local_player.root_part.Velocity = Vector3.new(0,10,0);
    local_player.root_part.CFrame = SpawnPosition + Vector3.new(0,10,0)


    local Bosses = {
        {Name = "Megalodaunt", Offset = CombatOffset.Megalodaunt},
        {Name = "Golem", Offset = CombatOffset.Golem}, 
        {Name = "Crocco", Offset = CombatOffset.Crocco}, 
        {Name = "Angel", Offset = CombatOffset.Angel}, 
        {Name = "Enforcer", Offset = CombatOffset.Enforcer}, 
        {Name = "StoneKnight", Offset = CombatOffset.StoneKnight}, 
        {Name = "Nomad", Offset = CombatOffset.StoneKnight},  
        {Name = "Megalodaunt_Alpha", Offset = CombatOffset.Megalodaunt_Alpha}, 
    }

    for _, Boss in ipairs(Bosses) do
        repeat task.wait() until FindMob(Boss.Name)
        if Boss.Name == "Nomad" then
                Tween.new(CFrame.new(76, 1257, 255), true, 200).wait();

            repeat 
                task.wait()
            until FindMob("Nomad")
            task.wait(0.25);
            game:GetService("Players").LocalPlayer.Character:WaitForChild("CharacterHandler"):WaitForChild("Requests"):WaitForChild("Carry"):FireServer()
            local old_cf = local_player.root_part.CFrame
            task.wait(2.5);
            local_player.root_part.CFrame = CFrame.new(old_cf.X, 0, old_cf.Z);
            task.wait(1);
            game:GetService("Players").LocalPlayer.Character:WaitForChild("CharacterHandler"):WaitForChild("Requests"):WaitForChild("Carry"):FireServer()
            task.wait(1);
            local_player.root_part.CFrame = old_cf + Vector3.new(0, 10, 0);
            continue        
end;
        InitiateCombat(Boss.Name, Boss.Offset)

        attachToBack(false, nil)
        
        if Boss.Name == "Angel" then
            Tween.new(CFrame.new(76, 1257, 255), true, 200).wait();
        end
        Tween.new(SpawnPosition, true, 150).wait();
        local_player.root_part.CFrame = SpawnPosition
    end 
end


return HandleTrial