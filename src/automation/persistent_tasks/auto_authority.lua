if is_regular then
    return {
        run = function()
            local_player.instance:Kick("Attempted to start a beta-only automation whilst not on beta.");
            persistent_data:wipe();
        end
    }
end;
local Safety = require('@src/utility/safety')
local automation_struct = require("@src/automation/struct");

local struct;
struct = automation_struct:construct({
    persistent_data_store = 'auto_authority_missions_store',
    persistent_data_flag = 'auto_authority_missions',
    id = 'auto_authority_missions',
    
    state_machine = StateMachine.create({
        initial = "idle",
        events = {
            {name = 'start',    from = 'idle', to = '_check_area'},
            {name = 'continuation', from = '_check_area', to = '_check_area'}  
        },
        callbacks = {
            onenter_check_area = function(self)
                if is_etrean then
                    -- Hop to eastern
                    return
                end
                
                if is_eastern then
                    local args = {
                        "FriendlyFire",
                        true
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("UpdateUXSettings"):FireServer(unpack(args))

                    aztup.flags.aa_bypass = true

                    local current_tween;
                    
                    local send_dialogue = game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue");
                    local destructibles = workspace:WaitForChild("Destructibles");
                    local npc_folder = workspace:WaitForChild("NPCs");
                    local terrain = workspace:WaitForChild("Terrain");
                    local live = workspace:WaitForChild("Live");
                    
                    local got = false;
                    local fc = 0;
                    send_dialogue.OnClientEvent:Connect(function(v273) 
                        got = not v273.exit;
                        fc += 1;
                    end);
                    
                    repeat 
                        task.wait()
                        current_tween = Tween.new(CFrame.new(-7502, 2000, 3481), true, 225).wait();
                        current_tween = Tween.new(CFrame.new(-7502, 11, 3481), true, 225).wait();
                        fireproximityprompt(npc_folder:WaitForChild("Captain Trist"):WaitForChild("InteractPrompt"))
                    until got;
                    local starting_fc = fc;
                    repeat 
                        task.wait()
                        send_dialogue:FireServer({
                            choice = "Yes, Sir."
                        })
                    until starting_fc ~= fc;
                    
                    task.spawn(function()
                        while got do
                            send_dialogue:FireServer({
                                exit = true
                            });
                            task.wait();
                        end;
                    end);
                    
                    local identified_job do
                        
                    end;
                    
                    local object;
                    
                    task.wait(2.5);
                    
                    local mission_dropdown = {
                        hostage = persistent_data:get('auto_authority_do_hostage', false),
                        barrels = persistent_data:get('auto_authority_do_barrels', false),
                        secure = persistent_data:get('auto_authority_do_secure', false),
                    };

                    if not identified_job or not mission_dropdown[identified_job] then
                        --Note: Rejoining is faster due to the fact we don't lose time on doing missions
                        local slot = local_player.instance:GetAttribute("DataSlot") or "A"
                        return server_utility:hop(slot);
                    end;
                    
                    local missions = {
                        hostage = function()
                            repeat
                                task.wait(0.5)
                                local args = {
                                    {
                                        exit = true
                                    }
                                }
                                game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
                            until not local_player.instance.PlayerGui.DialogueGui.Enabled
                            
                            current_tween = Tween.new(object * CFrame.new(0, 2000, 0), true, 225).wait();
                            current_tween = Tween.new(object, true, 225).wait();
                            
                            local hostage;
                            repeat task.wait()
                                for _, entity in live:GetChildren() do
                                    if not entity.Name:find(".hostage") then continue; end
                                    if not entity:FindFirstChild("HumanoidRootPart") then continue; end
                                    if (entity.HumanoidRootPart.Position - local_player.root_part.Position).Magnitude > 1000 then continue; end
                                    
                                    current_tween = Tween.new(entity.HumanoidRootPart.CFrame, true, 225).wait();
                                    hostage = entity;
                                    break;
                                end;
                            until hostage;
                            
                            current_tween = Tween.new(hostage.HumanoidRootPart.CFrame, true, 225).wait();
                            
                            local last_carry = 0;
                            local carrying_since = nil;
                            repeat
                                if EffectReplicator:FindEffect('Carrying') then
                                    carrying_since = carrying_since or tick();
                                else
                                    -- we dropped his ahh
                                    carrying_since = nil;
                                    local character_handler = local_player.character:FindFirstChild("CharacterHandler");
                                    local requests = character_handler and character_handler:FindFirstChild("Requests");
                                    local carry = requests and requests:FindFirstChild("Carry");

                                    if carry and tick() - last_carry > 0.75 then
                                        last_carry = tick();
                                        carry:FireServer();
                                    end;
                                end;
                                current_tween = Tween.new(hostage.HumanoidRootPart.CFrame, true, 225).wait();
                                task.wait();
                            until carrying_since and tick() - carrying_since >= 2;
                            
                            if EffectReplicator:FindEffect('Carrying') then
                                current_tween = Tween.new(CFrame.new(local_player.root_part.Position.X, 2000, local_player.root_part.Position.Z), true, 225).wait()
                            end
                            
                            repeat 
                                task.wait()
                                current_tween = Tween.new(CFrame.new(-7502, 2000, 3481), true, 225).wait();
                                current_tween = Tween.new(CFrame.new(-7502, 11, 3481), true, 225).wait();            
                                fireproximityprompt(npc_folder:WaitForChild("Captain Trist"):WaitForChild("InteractPrompt"))
                            until got;
                        end;
                        barrels = function()
                            repeat
                                task.wait(0.5)
                                local args = {
                                    {
                                        exit = true
                                    }
                                }
                                game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
                            until not local_player.instance.PlayerGui.DialogueGui.Enabled
                                end;
                                
                                local crates = {};
                                for _, crate in destructibles:GetChildren() do
                                    if crate.Name:find("KhanCrate") and crate:IsA("Model") and (Vector3.new(crate:GetPivot().X, 0, crate:GetPivot().Z) - Vector3.new(local_player.root_part.Position.X, 0, local_player.root_part.Position.Z)).Magnitude < 1200 then
                                        table.insert(crates, crate);
                                    end;
                                end;
                                
                                table.sort(crates, function(a,b)
                                    return (a:GetPivot().Position - local_player.root_part.Position).Magnitude < (b:GetPivot().Position - local_player.root_part.Position).Magnitude
                                end);
                                
                                for _, crate in crates do
                                    while crate:GetAttribute("StructureHealth") and crate:GetAttribute("StructureHealth") > 0 do
                                        aztup.features.m1_hold.held = true;
                                        current_tween = Tween.new(CFrame.new((crate:GetPivot() * CFrame.new(0,-5,0)).Position) * CFrame.Angles(math.rad(90), 0, 0), true, 225).wait();
                                        
                                        task.wait();
                                    end;
                                    aztup.features.m1_hold.held = false;
                                end;
                            end;
                            
                            repeat 
                                task.wait()
                                current_tween = Tween.new(CFrame.new(-7502, 2000, 3481), true, 225).wait();
                                current_tween = Tween.new(CFrame.new(-7502, 11, 3481), true, 225).wait();
                                fireproximityprompt(npc_folder:WaitForChild("Captain Trist"):WaitForChild("InteractPrompt"))
                            until got;
                        end,
                        secure = function()
                            current_tween = Tween.new(object * CFrame.new(0,1500,0), true, 225).wait();
                            current_tween = Tween.new(object, true, 225).wait();
                    
                            local current_banner;
                            repeat task.wait()
                                for _, banner in workspace:GetChildren() do
                                    if banner.Name == "Authority Checkpoint" and banner:IsA("Model") and (Vector3.new(banner:GetPivot().X, 0, banner:GetPivot().Z) - Vector3.new(local_player.root_part.Position.X, 0, local_player.root_part.Position.Z)).Magnitude < 1200 then
                                        current_banner = banner;
                                    end;
                                end;
                            until current_banner;
                            while task.wait() do
                                Tween.new(current_banner:GetPivot() * CFrame.new(0, 8, 0), true, 225).wait();
                                local start = tick();
                                local stop = false;
                                repeat task.wait() 
                                    local splash_gui = local_player.instance.PlayerGui:FindFirstChild("SplashGui");
                                    local time_frame = splash_gui and splash_gui:FindFirstChild("TimeFrame");
                                    local time_label = time_frame and time_frame:FindFirstChild("TimeText");
                                    if time_label and time_label.Text:lower():find("report back") then
                                        stop = true;
                                        break;
                                    end;
                                until tick() - start > 35;
                                if stop then break; end;
                                repeat task.wait()
                                    local splash_gui = local_player.instance.PlayerGui:FindFirstChild("SplashGui");
                                    local time_frame = splash_gui and splash_gui:FindFirstChild("TimeFrame");
                                    local time_label = time_frame and time_frame:FindFirstChild("TimeText");
                                    if time_label and time_label.Text:lower():find("report back") then
                                        stop = true;
                                        break;
                                    end;
                                    Tween.new(current_banner:GetPivot() * CFrame.new(0, 3000, 0), true, 225).wait();
                                until tick() - start > 90 + 35;
                                if stop then break; end;
                                repeat task.wait()
                                    local splash_gui = local_player.instance.PlayerGui:FindFirstChild("SplashGui");
                                    local time_frame = splash_gui and splash_gui:FindFirstChild("TimeFrame");
                                    local time_label = time_frame and time_frame:FindFirstChild("TimeText");
                                    if time_label and time_label.Text:lower():find("report back") then
                                        stop = true;
                                        break;
                                    end;
                    
                                    Tween.new(current_banner:GetPivot() * CFrame.new(0, 8, 0), true, 225).wait();
                                until tick() - start > 120 + 35;
                                if stop then break; end;
                    
                                local splash_gui = local_player.instance.PlayerGui:FindFirstChild("SplashGui");
                                local time_frame = splash_gui and splash_gui:FindFirstChild("TimeFrame");
                                local time_label = time_frame and time_frame:FindFirstChild("TimeText");
                                current_tween = Tween.new(CFrame.new(-7502, 11, 3481), true, 225).wait();
                                fireproximityprompt(npc_folder:WaitForChild("Captain Trist"):WaitForChild("InteractPrompt"))
                            until got;
                        end
                    }
                    
                    missions[identified_job]();
                    
                    repeat
                        task.wait(0.5)
                        local args = {
                            {
                                exit = true
                            }
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
                    until not local_player.instance.PlayerGui.DialogueGui.Enabled
                    
                    self:continuation()
                end
            end
        }
    }),
    features = {
        'fly',
        'noclip',
        'no_fall',
        'no_kill_bricks',
        'm1_hold',
        'no_fire',
        'auto_equip_weapon',

    },
    not_allowed = function()
        return false;
    end,
    character_creator_handler_used = false,
    character_creator_handler_opts = {}
})

return struct;