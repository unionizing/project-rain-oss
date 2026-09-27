local feature = Feature:new("auto_fight");

function feature:enable()
    local target, closest_distance;
    local live = workspace:FindFirstChild("Live");

    closest_distance = math.huge;

    for _, mob in live:GetChildren() do
        if mob.Name:sub(1,1) ~= "." or (
            not mob.Name:match("megalodaunt")
            and not mob.Name:match("golem")
            and not mob.Name:match("crocco")
            and not mob.Name:match("stoneknight")
        ) then
            continue
        end

        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
        if mobRoot then
            local distance = (mobRoot.Position - local_player.root_part.Position).Magnitude
            if distance < closest_distance then
                closest_distance = distance
                target = mob
            end
        end
    end

    if closest_distance > 250 then
        target = nil
    end

    if not target then
        Logger:notify_sound("No target found.");

        return aztup_toggles.auto_fight:SetValue(false)    
end;

    self.conn = services.RunService.Heartbeat:Connect(function()
        if target.Parent == nil or not target:FindFirstChild('HumanoidRootPart') then 
            Logger:notify_sound("Finished fighting target.");

            return aztup_toggles.auto_fight:SetValue(false)        
end
        
        if not general:playing_ap_anims(target) or target.Name:match("golem") then
            KeyHandler:get_key("LeftClick"):FireServer(not aztup.flags.no_aerials and general:in_air(), local_player.instance:GetMouse().Hit, {
                S = false,
                NOAERIALS = false,
                Space = false,
                Right = false,
                W = false,
                Left = true
            }); 
        end;

        local offset = CFrame.new(0, 7, 0);

        if target.Name:match("crocco") then
            offset = CFrame.new(0, 4, 0);
        end;

        local cf = target.HumanoidRootPart.CFrame * offset * CFrame.Angles(math.rad(-90), 0, 0)
        local_player.root_part.AssemblyLinearVelocity = Vector3.zero;

        if (local_player.root_part.Position - cf.Position).Magnitude > 80  then
            if self.tween then self.tween.stop() end
            self.tween = Tween.new(cf, true, 100);
        else
            if self.tween then self.tween.stop() end
            local_player.root_part.CFrame = cf;
        end;

        return    
end);

    return
end;

function feature:disable()
    if self.conn then
        pcall(function()
            self.conn:Disconnect();
        end);
        self.conn = nil;
    end;

    if self.tween then
        self.tween.stop();
        self.tween = nil;
    end;
end;

return feature