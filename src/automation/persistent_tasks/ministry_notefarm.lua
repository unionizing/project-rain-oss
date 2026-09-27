--!nocheck
--todo:
-- FIX CHARACTER CREATION ON LAGGY SERVERS MAKES THE WHOLE AUTOFARM BREAKS (u stay in the inn flying)
-- USE GUILD DONT WORK
-- FALLBACKS IN CASE LAG
-- ADDING A TOGGLE FOR GUILD TREASURE FUNDS

local automation_struct = require("@src/automation/struct");

local notefarm = {
    playerCheck = function(self, mag, custom)
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
    
    serverHop = function(self)
        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:hop(slot, 'any', false)
    end,
    
    player_safe_tween = function(self, cf, speed, level)
        if self:playerCheck(200) then
            self:serverHop()
        end
        
        local_player.root_part.CFrame = cf
    end,
    
    tempTween = function(self, cf, speed)
        Tween.new(cf, true, speed).wait();
    end,
    
    players_near = function(self, target, mag)
        for _, player in services.Players:GetPlayers() do
            if player == local_player.instance then continue end
            
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hmrp = player.Character:FindFirstChild("HumanoidRootPart")
                
                local dist = (hmrp.Position - target.Position).Magnitude
                if (dist <= mag) then
                    return true
                end
            end
        end
        
        return false
    end,
    
    -- dialogue functions ty temp
    sendDialogue_choice = function(self, value)
        local args = {
            {
                choice = value
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
    end,
    
    sendDialogue_exit = function(self)
        local args = {
            {
                exit = true
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args))
    end,
    
    click = function(self, btn)
        if btn then 
            firesignal(btn.MouseButton1Click) -- https://docs.voltbz.net/docs
            task.wait(0.2) 
        end
    end,
    
    getCurrentNotesAmount = function(self)
        local notesText = local_player.instance.PlayerGui.CurrencyGui.CurrencyFrame.Notes.Amount.Text:gsub("%D", "")
        return tonumber(notesText) or 0
    end,
    
    setBankAmountAndConfirm = function(self, amount)
        repeat task.wait(0.1) until local_player.instance.PlayerGui:FindFirstChild("ChoicePrompt")
        
        local choicePrompt = local_player.instance.PlayerGui.ChoicePrompt
        local sliderFrame = choicePrompt:FindFirstChild("ChoiceFrame", true):FindFirstChild("DescSheet", true):FindFirstChild("SliderSheet", true)
        
        if sliderFrame then
            local genericSlider = sliderFrame:FindFirstChild("GenericSlider")
            if genericSlider then
                local numberBox = genericSlider:FindFirstChild("Number")
                if numberBox and numberBox:IsA("TextBox") then
                    numberBox.Text = tostring(amount)
                    task.wait(0.2)
                    numberBox:CaptureFocus()
                    task.wait(0.1)
                    numberBox:ReleaseFocus()
                    task.wait(0.2)
                end
            end
            
            local buttons = sliderFrame:FindFirstChild("Buttons")
            if buttons then
                local submitButton = buttons:FindFirstChild("Submit")
                if submitButton then
                    self:click(submitButton)
                    return true
                end
            end
        end
        
        return false
    end,
    
    depositAllNotes = function(self)
        local currentNotes = self:getCurrentNotesAmount()
        if currentNotes == 0 then
            return false
        end
        
        local bankGui = local_player.instance.PlayerGui:FindFirstChild("BankGui")
        if not bankGui then return false end
        
        bankGui:WaitForChild("Choice"):FireServer("notes_deposit")
        task.wait(1)
        
        return self:setBankAmountAndConfirm(currentNotes)
    end,
    
    closeBankGuiFunc = function(self)
        local bankGui = local_player.instance.PlayerGui:FindFirstChild("BankGui")
        if bankGui then
            local closeButton = bankGui:FindFirstChild("Close")
            if closeButton then
                self:click(closeButton)
            end
        end
    end,
    
    openBankAndDeposit = function(self)
        local banker = workspace.NPCs:FindFirstChild("Banker")
        if not banker then 
            return false 
        end
        
        game:GetService("ReplicatedStorage").Requests.InteractPrompt:FireServer(banker.InteractPrompt)
        task.wait(1)
        repeat task.wait(0.1) until local_player.instance.PlayerGui:FindFirstChild("DialogueGui") and local_player.instance.PlayerGui.DialogueGui.Enabled
        self:sendDialogue_choice('Can I access my account?')
        task.wait(1)
        repeat 
            task.wait(0.5) 
        until local_player.instance.PlayerGui:FindFirstChild("BankGui")
        
        task.wait(1)
        
        local success = self:depositAllNotes()
        
        self:closeBankGuiFunc()
        self:sendDialogue_exit()
        
        return success
    end,
    
    placeGuildDoor = function(self)
        local guild_placement_pos = {
            CFrame.new(-996.915771, 998.557617, -7053.39062, 0.20362483, 3.06991864e-20, -0.979048967, -3.81919831e-21, 1, 3.05618033e-20, 0.979048967, -2.48395997e-21, 0.20362483),
            CFrame.new(-376.312347, 1109.97266, -6917.1875, 0.830629528, 3.56421993e-19, 0.556825459, -6.59231309e-19, 1, 3.43294301e-19, -0.556825459, -6.52227105e-19, 0.830629528),
            CFrame.new(237.318726, 1135.56323, -7003.09619, 0.981070876, 2.48859064e-20, 0.193649009, -6.12415687e-21, 1, -9.74839719e-20, -0.193649009, 9.44527492e-20, 0.981070876)
        }
        
        for _, location in pairs(guild_placement_pos) do
            local guild_door_near = false
            
            for _, guild_door in workspace:GetChildren() do
                if guild_door_near then continue end
                if not (guild_door:IsA('Part')) or (guild_door:IsA('Part') and not guild_door.Name:find('Guild')) then continue end
                
                local dist = (location.Position - guild_door.Position).Magnitude
                if dist <= 50 or self:players_near(location, 400) then
                    guild_door_near = true
                    continue
                end
            end
            
            if not guild_door_near then
                self:player_safe_tween(location, 250)
                break
            end
        end
        
        task.wait(1)
        
        local_player.instance.Backpack['Chime of Dwelling'].Parent = local_player.character
        local_player.character['Chime of Dwelling']:Activate()
        
        local closest = nil
        
        repeat
            for _, guild_door in workspace:GetChildren() do
                if not guild_door:IsA('Part') then continue end
                if not guild_door.Name:find('GuildDoor') then continue end
                if not guild_door:FindFirstChild('InteractPrompt') then continue end
                
                local dist = (local_player.root_part.Position - guild_door.Position).Magnitude
                if not (dist <= 5) then continue end
                
                closest = guild_door
                break
            end
            
            task.wait()
        until closest
        
        repeat
            pcall(function(...)  
                fireproximityprompt(closest:FindFirstChild('InteractPrompt'))
            end)
            task.wait(.5)
        until local_player.instance:GetAttribute('CurrentArea') and local_player.instance:GetAttribute('CurrentArea'):find('Base')
        
        task.wait(1)
    end
}

function notefarm:overworld() 
    local function hasKnowledge()
        local knowledge = local_player.instance.PlayerGui.CurrencyGui.CurrencyFrame.ShrinePoints.Amount.Text
        return tonumber(knowledge) and (tonumber(knowledge) > 0)
    end
    
    local function hasNotes()
        local notes = local_player.instance.PlayerGui.CurrencyGui.CurrencyFrame.Notes.Amount.Text:gsub("%D", "")
        return tonumber(notes) > 0
    end
    
    repeat task.wait() until local_player.character

    
    if hasNotes() then
        if persistent_data:get('use_guild') then
            self:placeGuildDoor()
            
            local guild_name = local_player.instance:GetAttribute('Guild'):lower():gsub("%s*%[.-%]%s*", " "):gsub("^%d+", ""):gsub("z%w+divider", ""):gsub("[^%a%d]", "")
            local banker = nil
            local treasurer = nil
            
            
            if banker and not persistent_data:get('max_notes', false) then
                self:tempTween(banker.HumanoidRootPart.CFrame * CFrame.new(5, 0, 0), 170)
                notefarm:openBankAndDeposit()
                task.wait(3.5);
                if hasNotes() then
                    persistent_data:set('max_notes', true)
                end 
            end
            
            if hasNotes() then
                self:tempTween(treasurer.HumanoidRootPart.CFrame * CFrame.new(5, 0, 0), 170)
                
                repeat
                    pcall(function(...)  
                        fireproximityprompt(treasurer:FindFirstChildOfClass('ProximityPrompt'))
                    end)
                    task.wait(.5)
                until local_player.instance.PlayerGui.DialogueGui.Enabled
                
                self:sendDialogue_choice("I'd like to add money to the treasury. [Add to Treasury]")
                task.wait(0.5)
                self:sendDialogue_choice(20000)
                task.wait(0.5)
                self:sendDialogue_exit()
            end
            self:player_safe_tween(banker * CFrame.new(0, -5, 0), 170, math.random(10000, 30000))
            
            local closestBanker = nil
            
            repeat
                for _, npc in workspace.NPCs:GetChildren() do
                    if not npc.Name:match('Banker') then continue end
                    
                    if closestBanker == nil then
                        closestBanker = npc
                        continue
                    end
                    
                    if closestBanker then
                        local closestDist = (local_player.root_part.Position - closestBanker.HumanoidRootPart.Position).Magnitude
                        local currentDist = (local_player.root_part.Position - npc.HumanoidRootPart.Position).Magnitude
                        
                        if closestDist > currentDist then
                            closestBanker = npc
                        end
                    end
                end
                
                task.wait()
            until closestBanker
            
            notefarm:openBankAndDeposit()
            task.wait(3.5);
            if hasNotes() then
                persistent_data:set('max_notes', true)
            end 
        end
        
        if persistent_data:get('max_notes', false) then
            self:stop()
        end
    end
end

function notefarm:stop()
    aztup.automation:set('ministry_notefarm', not persistent_data:get('ministry_notefarm', false))
    persistent_data:remove('max_notes')
end

local struct;
struct = automation_struct:construct({
    persistent_data_store = 'ministry_notefarm_store',
    persistent_data_flag = 'ministry_notefarm',
    id = 'ministry_notefarm',
    
    state_machine = StateMachine.create({
        initial = "idle",
        events = {
            {name = 'start', from = 'idle', to = '_check_area'},
            
            {name = 'is_etrean', from ='_check_area', to = '_suicide'}, -- how do i use this
            {name = 'overworld', from = '_check_area', to ='_overworld'},
            {name = 'fragments', from = '_check_area', to ='_handle_fragments'},
            {name = 'depths', from = '_check_area', to = '_die'},
            
            {name = 'cc', from = '_check_area', to = '_create_character'},
            {name = 'continuation', from = '_create_character', to = '_check_area'},
        },
        callbacks = {
            onenter_check_area = function(self)
                pcall(function(...)  
                    local is_fragments = local_player.instance:GetAttribute('CurrentArea') and local_player.instance:GetAttribute('CurrentArea'):match('Fragments of Self')
                    if is_fragments then
                        self:fragments()
                        return
                    end
                end)
                
                pcall(function(...)  
                    local is_character_creation = workspace:FindFirstChild('CharacterCreator') and local_player.character.Parent == workspace.CharacterCreator
                    if is_character_creation then
                        self:cc()
                        task.wait();
                        return;
                    end
                end)
                
                pcall(function(...)  
                    local is_to1 = local_player.instance:GetAttribute('CurrentArea') and local_player.instance:GetAttribute('CurrentArea'):match('Trial of One')
                    if is_to1 then
                        self:to1()
                        return
                    end
                end) 
                
                local is_depths = local_player.instance:GetAttribute('CurrentArea') and local_player.instance:GetAttribute('CurrentArea'):match('The Depths')
                if is_depths then
                    self:depths()
                    return
                end
                
                if is_etrean then
                    if local_player.instance:GetAttribute('CurrentArea') and local_player.instance:GetAttribute('CurrentArea'):find('Base') then
                        require("@src/features/buttons/respawn")()
                        repeat task.wait() until local_player.instance.PlayerGui:FindFirstChild('SpawnPrompt')
                        local_player.instance.PlayerGui.SpawnPrompt.Choice:FireServer('Inn')
                        repeat task.wait() until local_player.character
                    end
                    
                    self:overworld()
                    return
                end
            end,
            
            onenter_create_character = function(self)
                struct:create_character()
                self:continuation()
            end,
            
            onenter_suicide = function(self)
                require("@src/features/buttons/respawn")()
                
                repeat 
                    task.wait() 
                until local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt')
                
                local_player.instance.PlayerGui.ChoicePrompt.Choice:FireServer('Death')
            end,
            
            onenter_handle_fragments = function(self)
                local function handleFrag()
                    local tpLocation = (workspace.NPCs.Self:GetPivot() - Vector3.new(0,15.7,0)) * CFrame.Angles(math.rad(180), math.rad(90), math.rad(180))
                    
                    if notefarm:playerCheck(200, tpLocation.Position) then
                        notefarm:serverHop()
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
                        get_score:FireServer();
                    end);
                    
                    while task.wait() do
                        local_player.root_part.CFrame = tpLocation;
                        if notefarm:playerCheck(200, tpLocation.Position) then
                            notefarm:serverHop()
                            while task.wait() do end
                        end
                        
                        fireproximityprompt(workspace:WaitForChild("NPCs"):WaitForChild("Self"):WaitForChild("InteractPrompt"))
                        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer({
                            choice = '[The End]',
                        })
                    end;
                end
                
                task.delay(40, function()
                    self:serverHop();
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
            
            onenter_overworld = function(self)
                notefarm:overworld();
                
                local slot = local_player.instance:GetAttribute("DataSlot");
                server_utility:obliteration(slot)
            end,
        }
    }),
    features = {
        "no_fall",
        "noclip",
        "mod_detector",
        "fly",
        "auto_equip_weapon",
    },
    not_allowed = function()
        return false;
    end,
    character_creator_handler_used = true,
    character_creator_handler_opts = {
        gamemode = "Pathfinder",
        origin = "Etris",
    }
})

return struct