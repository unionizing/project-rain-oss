local automation_struct = require("@src/automation/struct");
local autofarm_util = require("@src/utility/deepwoken/autofarm_utilitys");
local struct;

-- A lot of this is ported from other automations, It works.
-- DONT PUSH hard mode until we test momma croco and bonekeeper.

local switch_pos = CFrame.new(2997, -2265, 1581);
local buff_pos = CFrame.new(84, 1007, -1);

local autoescape = {
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

    autoM1 = function(toggle)
        if not toggle then
            aztup.features.m1_hold.held = false;
            aztup.flags.no_aerials = false;
            return;
        end

        aztup.features.m1_hold.held = true;
        aztup.flags.no_aerials = true;
    end,

    healthCheck = function(percent)
        return local_player.humanoid and local_player.humanoid.Health <= (local_player.humanoid.MaxHealth * percent);
    end,

    healPosition = function()
        local arena = workspace:FindFirstChild("DepthTrialArena");
        local elevator = arena and arena:FindFirstChild("TrialElevator");
        local platform = elevator and elevator:FindFirstChild("PlatformWood");

        if not platform then return nil end

        return CFrame.new(platform:GetPivot().Position + Vector3.new(0, 100, 0));
    end,

    healCheck = function(self, percent)
        if not self.healthCheck(percent or 0.35) then return false end

        local heal_cf = self.healPosition();
        if not heal_cf then return false end

        self.autoM1(false);

        repeat
            self.autoM1(false);
            self.tempTween(heal_cf, 125);
            task.wait();
        until not local_player.humanoid
            or local_player.humanoid.Health >= local_player.humanoid.MaxHealth
            or not aztup.automation:has_any();

        return true;
    end,

    foundMobs = function()
        for _, mob in workspace:WaitForChild("Live"):GetChildren() do
            if mob:GetAttribute("MOB_rich_name") then
                return true;
            end
        end
        return false;
    end,


    killTarget = function(self, target)
        if not target or not target:IsA("Model") then return end
        if target.Name:find(local_player.instance.Name) then return end

        autofarm_util:ReadyWeapon(true);
        self.tempTween(target.HumanoidRootPart.CFrame, 170);

        local chase_tween;
        local atb = task.spawn(function()

            if chase_tween then chase_tween.stop() end
        end);

        table.insert(struct.threads, atb);

        self.autoM1(true);
        repeat
            task.wait();
            aztup.features.m1_hold.held = true;
        until target.Parent == nil or self.healthCheck(0.25) or not aztup.automation:has_any();
        pcall(task.cancel, atb);
        self.autoM1(false);
    end,
};

function autoescape:enterTrial()
    task.spawn(function()
        while task.wait() do
            if self.playerCheck(200) then
                self.serverHop();
                while task.wait() do end
                break;
            end
        end
    end);
    self.player_safe_tween(self, switch_pos, 225);

    local elevator = workspace:WaitForChild("TrialElevator", 5);
    local start = tick();

    repeat
        if self.playerCheck(200, switch_pos.Position) then
            self.serverHop();
            while task.wait() do end
        end

        self.tempTween(switch_pos, 200);

        local switch = elevator and elevator:FindFirstChild("Switch") and elevator.Switch:FindFirstChild("InteractPrompt");
        if switch then
            pcall(function()
                fireproximityprompt(switch);
            end);
        end

        task.wait(0.5);
    until not is_depths
        or tick() - start > 30
        or not aztup.automation:has_any();

    if is_depths then
        self.serverHop();
        while task.wait() do end
    end
end

function autoescape:beginTrial()
    local hard = persistent_data:get("escape_depths_hard_trial", false);

    autofarm_util:ReadyWeapon(true);

    local dialogue = game:GetService("ReplicatedStorage").Requests.SendDialogue;
        if buff_prompt then
            pcall(function()
                fireproximityprompt(buff_prompt);
            end);
            task.wait(1);

            pcall(function()
                dialogue:FireServer({ choice = "[Prove yourself]" });
            end);
            task.wait(1);
            pcall(function()
                dialogue:FireServer({ exit = true });
            end);
            task.wait(2.5);
        end
    end

    local start = tick();
    local fired = false;

    repeat
        local trial = workspace:FindFirstChild("DepthsTrial");
        local platform = trial and trial:FindFirstChild("CircularPlatform");
        local dungeon_lever = platform and platform:FindFirstChild("DepthsTrialDungeonLever");
        local lever = dungeon_lever and dungeon_lever:FindFirstChild("InteractPrompt");

        if lever then
            pcall(function()
                fireproximityprompt(lever);
            end);
            fired = true;
        elseif fired then
            break;
        end

        task.wait(0.5);
    until tick() - start > 15
        or not aztup.automation:has_any();

    self:fightTrial();
end

function autoescape:fightTrial()
    task.spawn(function()
        while task.wait() do
            if self.playerCheck(200) then
                self.serverHop();
                while task.wait() do end
                break;
            end
        end
    end);

            self:healCheck();

            pcall(function()
                self.killTarget(self, self.closestMob());
            end);
            task.wait();
        until not self.foundMobs() or not aztup.automation:has_any();
    end

    self.autoM1(false);
end

local state_machine = StateMachine.create({
    initial = "idle",
    events = {
        { name = "start",    from = "idle", to = "_check_area" },
        { name = "enter",    from = "_check_area", to = "_enter_trial" },
        { name = "begin",    from = "_check_area", to = "_begin_trial" },
        { name = "complete", from = "_check_area", to = "_complete" },
        { name = "skip",     from = "_check_area", to = "idle" },
    },
    callbacks = {
        onenter_check_area = function(self)
            local current_area = local_player.instance:GetAttribute("CurrentArea");
            if current_area and current_area:match("Fragments of Self") then
                    persistent_data:wipe();
                    local_player.instance:Kick("auto escape depths: you somehow got into fragments of self");
                return
            end
            if is_depths then
                self:enter();
                return
            end

            if is_dungeon and workspace:WaitForChild("DepthsTrial", 9e9) then
                self:begin();
                return
            end

            if is_eastern or is_etrean then
                self:complete();
                return
            end

            self:skip();
        end,

        onenter_enter_trial = function(self)
            autoescape:enterTrial();
        end,

        onenter_begin_trial = function(self)
            autoescape:beginTrial();
        end,

        onenter_complete = function(self)
            aztup.automation:set("auto_escape_depths", false);
            Logger:long_notify_sound("Successfully escaped the depths.")

            local auto_progress = aztup.farms and aztup.farms.auto_progress;
            if auto_progress and auto_progress.resume_from_depths and persistent_data:get("auto_progress", false) then
                pcall(auto_progress.resume_from_depths);
            end;

            local slot = local_player.instance:GetAttribute("DataSlot") ;
            server_utility:rejoin(slot or "A");
        end,
    }
});

struct = automation_struct:construct({
    persistent_data_store = "auto_escape_depths_store",
    persistent_data_flag  = "auto_escape_depths",
    id = "auto_escape_depths",

    state_machine = state_machine,

    features = {
        "no_fall",
        "noclip",
        "fly",
        "no_fire",
        "m1_hold",
        "no_stun",
        "fast_swing",
        "mob_ai_breaker",
        "auto_equip_weapon"
    },

    not_allowed = function()
        return false;
    end,

    character_creator_handler_used = false,
    character_creator_handler_opts = {}
});

-- Auto progression thingy
struct.logic = autoescape;

return struct;
