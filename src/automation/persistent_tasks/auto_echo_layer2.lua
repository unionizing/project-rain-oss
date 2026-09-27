local automation_struct = require("@src/automation/struct");
local autofarm_util = require('@src/utility/deepwoken/autofarm_utilitys');
local safety = require('@src/utility/safety');
local struct;

local auto_echo_layer2 = {
    temp_tween = function(cf, speed)
        Tween.new(cf, true, speed or 175).wait();
    end,

    server_hop = function()
        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:hop(slot, true, true);
    end,

    player_check = function(mag, custom)
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

    send_dialogue = function(text, exit)
        local args = exit and { { exit = true } } or { { choice = text } };
        game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue"):FireServer(unpack(args));
        if not exit then task.wait(0.5); end
    end,
};

function auto_echo_layer2:pass_fragments()
	task.spawn(function()
		while task.wait() do
			if safety:PlayerNear(100) then
				self.server_hop();
			end
		end
	end);

	task.delay(40, function()
		self.serverHop();
	end);
	local frag_handler;
	frag_handler = function()
		if not workspace.NPCs:FindFirstChild('Self') then
			require("@src/features/buttons/respawn")()
			repeat
				task.wait()
			until local_player.character and workspace.NPCs:FindFirstChild('Self')
		end
		xpcall(handleFrag, function()
			task.wait(0.1);
			frag_handler();
		end);
	end
	frag_handler();
end

function auto_echo_layer2:enter_void()
    local is_fragments = local_player.instance:GetAttribute('CurrentArea') and local_player.instance:GetAttribute('CurrentArea'):match('Fragments of Self')
    if is_fragments then
        return auto_echo_layer2:pass_fragments()            
    end

    local function get_closest_kill_plane()
        local part;
        local dist = 9e9;

        for _, item in workspace:QueryDescendants("#KillPlane") do
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

    local start = tick();
    local plane = get_closest_kill_plane();
    repeat plane = get_closest_kill_plane(); task.wait(); until plane or tick() - start > 15;

    local playercheck = task.spawn(function()
        while task.wait() do
            if safety:PlayerNear(300) then
                self.server_hop();
            end
        end
    end);

    aztup_toggles.fly:SetValue(false);

    local tween;
    while tick() - start < 60 do
        if not plane then break; end
        if tween then tween.stop(); end;
        tween = Tween.new(plane.CFrame, false, 200);
        local_player.root_part.Velocity = Vector3.new(0, -999, 0);
        task.wait();
    end;

    pcall(task.cancel, playercheck);
    return
end

function auto_echo_layer2:get_key()
    autofarm_util:ReadyWeapon(true);

    repeat
        pcall(function()
            self.temp_tween(workspace.NPCs:FindFirstChild('TheKey'):GetPivot(), 250);
        end);
        pcall(function()
            fireproximityprompt(workspace.NPCs.TheKey.InteractPrompt);
        end);
        task.wait(0.5);
    until local_player.instance.PlayerGui.DialogueGui.Enabled;

    self.send_dialogue(nil, true);

    self.temp_tween(workspace.NPCs:FindFirstChild('TheDoor'):GetPivot(), 250);

    repeat
        self.temp_tween(workspace.NPCs:FindFirstChild('TheDoor'):GetPivot(), 250);
        pcall(function()
            fireproximityprompt(workspace.NPCs:FindFirstChild('TheDoor').InteractPrompt);
        end);
        task.wait(0.5);
    until local_player.instance.PlayerGui.DialogueGui.Enabled;

    self.send_dialogue(nil, true);
end

function auto_echo_layer2:spawn_keeper()
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

function auto_echo_layer2:go_to_generator()
    self.temp_tween(CFrame.new(-5555, 529, -6475), 250);

    repeat
        self.temp_tween(CFrame.new(-5555, 529, -6475), 250);
        task.wait(0.5);
        pcall(function()
            fireproximityprompt(workspace.NPCs.TheGenerator.InteractPrompt);
        end);
    until local_player.instance.PlayerGui.DialogueGui.Enabled;

    self.send_dialogue('[Restart it]');
    self.send_dialogue(nil, true);
    aztup_toggles.void_mobs:SetValue(false);
end

function auto_echo_layer2:chaser_route()
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

    self.temp_tween(foundchaser:GetPivot(), 250);

    repeat
        self.temp_tween(foundchaser:GetPivot(), 250);
        pcall(function()
            fireproximityprompt(foundchaser.InteractPrompt);
        end);
        task.wait(0.5);
    until local_player.instance.PlayerGui.DialogueGui.Enabled;

    task.spawn(function() 
        while task.wait() do
            if not EffectReplicator:FindEffect("Blocking") then
                DefendActionManager.block:FireServer()
            end;
        end;
    end);

    if not EffectReplicator:FindEffect("Equipped") then
        local character_handler = local_player.character:FindFirstChild("CharacterHandler");
        character_handler.Requests.DrawWeapon:FireServer(true);
    end;

    self.send_dialogue('Ethiron\'s Wake?');
    self.send_dialogue('What happened here?');
    aztup.features.attach_to_back.state = "attaching";
    aztup_toggles.mob_ai_breaker:SetValue(true);
    aztup_options.breaker_type.Value = "Aggressive";

    repeat
        task.wait();
        pcall(function()
            fireproximityprompt(chaser.InteractPrompt);
        end);
    until local_player.instance.PlayerGui.DialogueGui.Enabled or chaser.Parent == nil;


    aztup.features.m1_hold.held = false;
    aztup_toggles.mob_ai_breaker:SetValue(false);
    aztup_toggles.attach_to_back:SetValue(false);
end

local state_machine = StateMachine.create({
    initial = "idle",
    events = {
        { name = "start",        from = "idle",             to = "_check_area" },
        { name = "cc",           from = "_check_area",       to = "_create_character" },
        { name = "continuation", from = "_create_character", to = "_check_area" },
        { name = "enter_void",   from = "_check_area",       to = "_enter_void" },
        { name = "run_route",    from = "_check_area",       to = "_run_route" },
    },

    callbacks = {
        onenter_check_area = function(self)
            --if persistent_data:get("auto_echo_layer2_wiping", false) then
            --    local ok, area = pcall(function()
            --        return local_player.instance:GetAttribute("CurrentArea");
            --    end);
--
            --    if ok and area and area:match("Fragments of Self") then
            --        auto_echo_layer2:pass_fragments();
            --    end
--
            --    local character_creator = workspace:WaitForChild('CharacterCreator', 30);
            --    persistent_data:set("auto_echo_layer2_wiping", false);
--
            --    if character_creator and local_player.character and local_player.character.Parent == character_creator then
            --        self:cc();
            --        return;
            --    end
            --end

            local requests = services.ReplicatedStorage:WaitForChild("Requests");
            local start = requests:WaitForChild("StartMenu"):WaitForChild("Start")
            repeat
                start:FireServer()
                task.wait(0.5)
            until local_player.character;
            local is_character_creation = workspace:FindFirstChild('CharacterCreator') and local_player.character.Parent == workspace.CharacterCreator

            if is_character_creation then
                self:cc();
                return;
            end

            local ok, dungeon = pcall(function()
                return local_player.instance:GetAttribute('Dungeon');
            end);

            if ok and dungeon and dungeon:match('Layer2Floor1') then
                self:run_route();
                return;
            end

            repeat task.wait() until local_player.instance:GetAttribute('CurrentArea');
            self:enter_void();
        end,

        onenter_create_character = function(self)
            struct:create_character();
            self:continuation();
        end,

        onenter_enter_void = function(self)
            auto_echo_layer2:enter_void();
        end,

        onenter_run_route = function(self)
            auto_echo_layer2:get_key();
            auto_echo_layer2:spawn_keeper();
            auto_echo_layer2:go_to_generator();
            local chaser = auto_echo_layer2:chaser_route();
            auto_echo_layer2:void_chaser(chaser);

            task.wait(5);
            persistent_data:set("auto_echo_layer2_wiping", true);
            server_utility:obliteration(local_player.instance:GetAttribute("DataSlot"));
        end,
    }
});

struct = automation_struct:construct({
    persistent_data_store = "auto_echo_layer2_store",
    persistent_data_flag  = "auto_echo_layer2",
    id = "auto_echo_layer2",
    state_machine = state_machine,

    features = {
        "no_fall",
        "noclip",
        "fly",
        "no_kill_bricks",
        "m1_hold",
        "auto_equip_weapon",
    },

    character_creator_handler_used = true,
    character_creator_handler_opts = {
        origin = "DiluvianMechanism",
        modifiers = {
            "All"
        },
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
        Converted["_title"].Text = "Layer2 Echo Farm"
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
