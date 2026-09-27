-- TODO: Add a way to detect if its the players first time doing the deep drill ( because the dialouge changes depending on that )

local automation_struct = require("@src/automation/struct");
local autofarm_util = require('@src/utility/deepwoken/autofarm_utilitys');
local struct;

local drill_npc_position = CFrame.new(-5217, 117, -5610);
local nest_waypoint = CFrame.new(-5312, 283, -4793);
local drill_site = CFrame.new(-4651.23877, 202.903076, -4486.12012, 0.939700544, -0, -0.341998369, 0, 1, -0, 0.341998369, 0, 0.939700544);

local auto_deepdrill = {
    temp_tween = function(cf, speed)
        Tween.new(cf, true, speed or 200).wait();
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

    player_safe_tween = function(self, cf, speed)
        if self.player_check(200) then
            self.server_hop();
            while task.wait() do end
        end

        self.temp_tween(cf, speed);

        if self.player_check(200, cf.Position) then
            self.server_hop();
            while task.wait() do end
        end
    end,

    send_dialogue = function(text, exit)
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("SendDialogue");
        local args = exit and { { exit = true } } or { { choice = text } };

        local acked = false;
        local conn = remote.OnClientEvent:Connect(function()
            acked = true;
        end);
        conn:Disconnect();
    end,

    closest_npc = function()
        local npcs = workspace:FindFirstChild("NPCs");
        if not npcs then return nil end

        local closest, shortest = nil, math.huge;
        for _, npc in npcs:GetChildren() do
            if not npc:IsA("Model") then continue end

            local ok, position = pcall(function()
                return npc:GetPivot().Position;
            end);
            if not ok then continue end

            local dist = (position - local_player.root_part.Position).Magnitude;
            if dist < shortest then
                shortest = dist;
                closest = npc;
            end
        end

        return closest;
    end,
};

function auto_deepdrill:get_key()
    autofarm_util:ReadyWeapon(true);

    repeat
        pcall(function()
            self.temp_tween(workspace.NPCs:FindFirstChild('TheKey'):GetPivot(), 200);
        end);
        pcall(function()
            fireproximityprompt(workspace.NPCs.TheKey.InteractPrompt);
        end);
        task.wait(0.5);
    until local_player.instance.PlayerGui.DialogueGui.Enabled;

    self.send_dialogue(nil, true);

    self.temp_tween(workspace.NPCs:FindFirstChild('TheDoor'):GetPivot(), 200);

    repeat
        self.temp_tween(workspace.NPCs:FindFirstChild('TheDoor'):GetPivot(), 200);
        pcall(function()
            fireproximityprompt(workspace.NPCs:FindFirstChild('TheDoor').InteractPrompt);
        end);
        task.wait(0.5);
    until local_player.instance.PlayerGui.DialogueGui.Enabled;

    self.send_dialogue(nil, true);
end


function auto_deepdrill:turn_on_generator()
    self.temp_tween(CFrame.new(-5555, 529, -6475), 200);

    repeat
        self.temp_tween(CFrame.new(-5555, 529, -6475), 200);
        task.wait(0.5);
        pcall(function()
            fireproximityprompt(workspace.NPCs.TheGenerator.InteractPrompt);
        end);
    until local_player.instance.PlayerGui.DialogueGui.Enabled;

    self.send_dialogue('[Restart it]');
    self.send_dialogue(nil, true);
    aztup_toggles.void_mobs:SetValue(false);
end


function auto_deepdrill:enter_drill_site()
    self.player_safe_tween(self, nest_waypoint, 200);
    task.wait(0.5);
    self.player_safe_tween(self, drill_site, 200);
end

function auto_deepdrill:wait_for_teleport_out()
    repeat
        task.wait(1);
    until not local_player.root_part
end

local state_machine = StateMachine.create({
    initial = "idle",
    events = {
        { name = "start",       from = "idle",              to = "_get_key" },

            if aztup.automation:has_any() then
                self:generator();
            end;
        end,

        onenter_turn_on_generator = function(self)
            auto_deepdrill:turn_on_generator();

            if aztup.automation:has_any() then
                self:talk();
            end;
        end,

        onenter_talk_to_npc = function(self)
            local ok = auto_deepdrill:talk_to_drill_guy();

            if ok and aztup.automation:has_any() then
                self:enter();
            end;
        end,

        onenter_enter_site = function(self)
            auto_deepdrill:enter_drill_site();

            if aztup.automation:has_any() then
                self:arrived();
            end;
        end,

        onenter_arrived = function(self)
            auto_deepdrill:wait_for_teleport_out();

            if aztup.automation:has_any() then
                self:restart();
            end;
        end,
    }
});

struct = automation_struct:construct({
    persistent_data_store = "auto_deepdrill_store",
    persistent_data_flag  = "auto_deepdrill",
    id = "auto_deepdrill",

    state_machine = state_machine,

    features = {
        "no_fall",
        "noclip",
        "fly",
        "auto_equip_weapon",
        "void_mobs",
        "no_kill_bricks"
    },

    not_allowed = function()
        return false;
    end,

    on_run = function()
        if is_depths then
            persistent_data:wipe();
            local_player.instance:Kick("done :)");
        end;
    end,

    character_creator_handler_used = false,
    character_creator_handler_opts = {},
});

return struct;
