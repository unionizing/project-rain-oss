local automation_struct = require("@src/automation/struct");
local autofarm_util = require("@src/utility/deepwoken/autofarm_utilitys");
local struct;

local auto_voi = {
    playerCheck = function(mag, custom)
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

    mobsCheck = function(mag, custom)
        for _, mob in workspace.Live:GetChildren() do
            if not mob:FindFirstChild("HumanoidRootPart") then continue; end;

            local dist = ((custom or local_player.root_part.Position) - mob:GetPivot().Position).Magnitude;
            if dist <= mag then
                return true;
            end
        end
        return false;
    end,

    serverHop = function()
        local slot = local_player.instance:GetAttribute("DataSlot");
        server_utility:hop(slot, "any", true);
    end,

    tempTween = function(cf, speed)
        Tween.new(cf, true, speed or 150).wait();
    end,

    player_safe_tween = function(self, cf, speed)
        if self.playerCheck(200) then
            self.serverHop();
            while task.wait() do end
        end

        local x, _, z = select(1, cf:GetComponents());
        self.tempTween(CFrame.new(x, -1050, z), speed);
        self.tempTween(cf, speed);

        if self.playerCheck(200, cf.Position) then
            self.serverHop();
            while task.wait() do end
        end

        local root = local_player.root_part;
        if not root then return end

        root.CFrame = cf;
        root.AssemblyLinearVelocity = Vector3.zero;
    end,

    repeat task.wait() until workspace.Live:FindFirstChild(name);
    repeat task.wait() until workspace.Live:FindFirstChild(name) and workspace.Live:FindFirstChild(name):FindFirstChild("HumanoidRootPart");

    aztup.flags.atb_x_offset = 4
    aztup.flags.atb_y_offset = -7
    aztup.flags.atb_z_offset = 0
    aztup_toggles.attach_to_back:SetValue(true);
    aztup.features.attach_to_back.target = workspace.Live:FindFirstChild(name);
    aztup.features.attach_to_back.state = "attaching";
    aztup.flags.atb_rotate = true;
    aztup_toggles.noclip:SetValue(true);

    aztup_toggles.mob_ai_breaker:SetValue(true);
    aztup_options.breaker_type.Value = "Aggressive"
    workspace.Live:FindFirstChild(name):WaitForChild("HumanoidRootPart");

    while task.wait() and not workspace:FindFirstChild("DungeonExit") do
        pcall(function()
            if not EffectReplicator:FindEffect("Equipped") then
                local_player.character.CharacterHandler.Requests.DrawWeapon:FireServer(true);
            end;
        end);

        self:autoM1(true);
    end;

    self:autoM1(false);

    persistent_data:set(flag, true);
    Tween.new(workspace:FindFirstChild("DungeonExit").CFrame, false, 150);
end;

function auto_voi:rat_king()
    if game.PlaceId == 86761619761103 then
        repeat 
            task.spawn(function()
                local_player.instance:RequestStreamAroundAsync(Vector3.new(-2829.87646, 56.4980431, -3300.2854));
            end);
            task.wait(0.1) 
        until workspace:FindFirstChild("GoldenRatBoundary");

        local boundary = workspace:FindFirstChild("GoldenRatBoundary");
        while task.wait() do
            xpcall(function() 
                local_player.root_part.AssemblyLinearVelocity = Vector3.zero;
                local_player.root_part.CFrame = boundary.CFrame;
                firetouchinterest(boundary, local_player.root_part, 1);
                firetouchinterest(boundary, local_player.root_part, 0);
            end, warn);
        end;
    else    
        self:generic_humanoid_fight(".ratking1", "done_rat_king");
    end;
end;

function auto_voi:enmity()
    if game.PlaceId == 86761619761103 then
        require("@src/features/buttons/teleports/depths")();
    elseif game.PlaceId == 8668476218 then
        aztup.flags.atb_x_offset = 0
        aztup.flags.atb_y_offset = 6
        aztup.flags.atb_z_offset = 0
        aztup_toggles.attach_to_back:SetValue(true);
        aztup.features.attach_to_back.target = workspace.Live:WaitForChild(".enmity_true1");
        aztup.features.attach_to_back.state = "attaching";
        aztup.flags.atb_rotate = true;
        if not aztup.flags.m1_hold then
            aztup_toggles.m1_hold:SetValue(true);
        end;

aztup_toggles.mob_ai_breaker:SetValue(true);
aztup_options.breaker_type.Value = "Aggressive"
            local_player.character.CharacterHandler.Requests.DrawWeapon:FireServer(true);

    else
        Logger:long_notify("You will have to manually reach enmity :3")
    end;
end;

function auto_voi:shogun()
    if game.PlaceId == 86761619761103 then
        repeat 
            task.spawn(function()
                local_player.instance:RequestStreamAroundAsync(Vector3.new(-8983.13, 560.461121, -4054.68));
            end);
            task.wait(0.1) 
        until workspace:FindFirstChild("ShogunBoundary");

        local boundary = workspace:FindFirstChild("ShogunBoundary");
        while task.wait() do
            xpcall(function() 
                local_player.root_part.AssemblyLinearVelocity = Vector3.zero;
                local_player.root_part.CFrame = boundary.CFrame;
                firetouchinterest(boundary, local_player.root_part, 1);
                firetouchinterest(boundary, local_player.root_part, 0);
            end, warn);
        end;
    else    
        self:generic_humanoid_fight(".shogun1", "done_shogun");
    end;
end;

local state_machine = StateMachine.create({
    initial = "idle",
    events = {
        { name = "start",    from = "idle", to = "_check_area" },
        { name = "shogun",    from = "_check_area", to = "_do_shogun" },
        { name = "rat_king",    from = "_check_area", to = "_do_rat_king" },
        { name = "do_enmity", from = "_check_area", to = "_do_enmity" },
        { name = "do_complete", from = "_check_area", to = "_do_complete" },

        { name = "skip",     from = "_check_area", to = "idle" },
    },
    callbacks = {
        onenter_check_area = function(self)
            aztup.flags.block_input = true;
            aztup_options.blocked_safe_input_user_moves.Value.M1s = true;
            aztup_options.bi_punishable_type.Value = "Always";
        end,

        shogun = function(self)
            auto_voi:shogun();
        end,

        rat_king = function(self)            
            auto_voi:rat_king();
        end,

        enmity = function(self)
            auto_voi:enmity();
        end,

        onenter_complete = function(self)
            aztup.automation:set("auto_voi", false);
            Logger:long_notify_sound("Successfully finished voi.")

            if true then return; end
        end,
    }
});

struct = automation_struct:construct({
    persistent_data_store = "auto_voi_store",
    persistent_data_flag  = "auto_voi",
    id = "auto_voi",

    state_machine = state_machine,
});

-- Auto progression thingy
struct.logic = auto_voi;

return struct;
