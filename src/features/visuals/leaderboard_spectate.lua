

local feature = Feature:new("leaderboard_spectate"); 
local camera = workspace.CurrentCamera
local maid = require(("@src/utility/maid"));

local currentSpectatedLabel: TextLabel? = nil
local defaultTextColor = Color3.new(1, 1, 1)
feature.conns = {};
feature.unique_id = services.HttpService:GenerateGUID(); 


local function is_player_frame_map(map): boolean
    if type(map) ~= "table" then return false end

    for key, value in pairs(map) do
        if typeof(key) == "Instance" and key:IsA("Player") and typeof(value) == "Instance" then
            return true
        end
    end
    return false
end

local warned_no_map = false


local function get_player_frame_map()
    local ok, result = pcall(function()
        local signal = services.CollectionService:GetInstanceRemovedSignal("ChatBlocked_" .. local_player.instance.UserId)
        local conns = getconnections(signal)
        if not conns or #conns == 0 then
            error("no connections on ChatBlocked_ signal yet");
        end

        local fn = conns[1].Function
        
        for i = 1, 20 do
            local ok_uv, value = pcall(getupvalue, fn, i)
            if not ok_uv or value == nil then break end
            if is_player_frame_map(value) then
                return value
            end
        end

        error("no upvalue on ChatBlocked_ connection matched the player frame map shape");
    end)

    if ok then
        warned_no_map = false;
        return result
    end

    if not warned_no_map then
        
        warned_no_map = true;
    end
    return nil
end

local function get_player_from_frame(frame: Instance): Player?
    local map = get_player_frame_map()
    if not map then return nil end

    for plr, player_frame in pairs(map) do
        if player_frame == frame then
            return plr
        end
    end
    return nil
end

local function get_frame_from_player(plr: Player): Instance?
    local map = get_player_frame_map()
    return map and map[plr]
end


local function wait_for_player_frame_map(): { [Player]: Instance }
    while true do
        local map = get_player_frame_map()
        if map then return map end
        task.wait();
    end
end

function feature:handle(frame: Frame)
    if frame.Name ~= "PlayerFrame" then return end

    local mouse_enter, mouse_leave, input_began, inside;
    local frame_maid = maid.new();

    mouse_enter = frame.MouseEnter:Connect(function()
        inside = true
    end);

    mouse_leave = frame.MouseLeave:Connect(function()
        inside = false
    end);

    input_began = frame.InputBegan:Connect(function(input)
        if not inside then
            return 
        end

        if aztup.features.leaderboard_spectate.unique_id ~= self.unique_id then
            return
        end

        local player_frame = frame:FindFirstChild("PlayerFrame") :: Frame?
        if not player_frame then
            return
        end

        local player_label = player_frame:FindFirstChild("Player") :: TextLabel?
        if not player_label or player_label.Transparency == 0 then
            return
        end

        local plr = get_player_from_frame(frame)
        if not plr or not plr.Character then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton2 then
			local ray = Ray.new(plr.Character:GetPivot().p, Vector3.new(0,5000,0))
            local marker = services.ReplicatedStorage:FindFirstChild("MarkerWorkspace");
			if marker then
				local found = marker:FindPartOnRayWithWhitelist(ray, {marker:FindFirstChild("AreaMarkers")})
				Logger:notify_sound(plr:GetAttribute("CharacterName") or plr.Name, "is in", found and found.Parent and found.Parent.Name or "Unidentified")
			end
        end

        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        if currentSpectatedLabel == player_label then
            self:stop_spectate();
            return
        end

        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return
        end

        if currentSpectatedLabel then
            currentSpectatedLabel.TextColor3 = defaultTextColor
        end

        local_player.instance:AddTag("ForcedSubject")
        player_label.TextColor3 = Library.AccentColor
        currentSpectatedLabel = player_label

        while currentSpectatedLabel == player_label do
            if not local_player.instance:HasTag("ForcedSubject") then
                local_player.instance:AddTag("ForcedSubject")
            end
            camera.CameraSubject = humanoid

            task.wait();
        end
    end);

    local last_update = tick();
    local streaming_update_conn = services.RunService.RenderStepped:Connect(function()
        if tick() - last_update < 0.25 or not currentSpectatedLabel then
            return        
end;

        last_update = tick();
        
        local subject = workspace.CurrentCamera.CameraSubject;
        if subject == local_player.humanoid or not subject then return end
        
        pcall(function()
            local_player.instance:RequestStreamAroundAsync(subject.RootPart.Position, 1000);
        end);
    end);

    table.insert(self.conns, mouse_enter)
    table.insert(self.conns, mouse_leave)
    table.insert(self.conns, input_began)
    table.insert(self.conns, streaming_update_conn)

    frame_maid:give_task(mouse_enter);
    frame_maid:give_task(mouse_leave);
    frame_maid:give_task(input_began);
    frame_maid:give_task(streaming_update_conn);
    frame_maid:give_task(frame.AncestryChanged:Connect(function()
        if not frame:IsDescendantOf(local_player.instance) then
            frame_maid:do_cleaning();
        end;
    end));

    aztup.maid:give_task(frame_maid);
end

function feature:stop_spectate()
    if currentSpectatedLabel then
        currentSpectatedLabel.TextColor3 = defaultTextColor
    end;
    currentSpectatedLabel = nil

    local_player.instance:RemoveTag("ForcedSubject")
    camera.CameraSubject = local_player.humanoid;
end;

function feature:force_spectate(query: string | Player)
    local target_player: Player?

    if typeof(query) == "Instance" and query:IsA("Player") then
        target_player = query
    elseif type(query) == "string" and query ~= "" then
        for _, player in services.Players:GetPlayers() do
            if player:GetAttribute("CharacterName") == query or player.Name == query then
                target_player = player;
                break            
end;
        end;
    end

    if not target_player or not target_player.Character then return end

    local target_frame = get_frame_from_player(target_player)
    if not target_frame then return end

    local target_player_frame = target_frame:FindFirstChild("PlayerFrame") :: Frame?
    local target_label = target_player_frame and target_player_frame:FindFirstChild("Player") :: TextLabel?
    if not target_label then return end

    local humanoid = target_player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if currentSpectatedLabel == target_label then
        self:stop_spectate();
        return
    end

    if currentSpectatedLabel then
        currentSpectatedLabel.TextColor3 = defaultTextColor
    end

    local_player.instance:AddTag("ForcedSubject")
    target_label.TextColor3 = Library.AccentColor
    currentSpectatedLabel = target_label

    task.spawn(function()
        while currentSpectatedLabel == target_label do
            if not local_player.instance:HasTag("ForcedSubject") then
                local_player.instance:AddTag("ForcedSubject")
            end
            camera.CameraSubject = humanoid

            task.wait();
        end
    end)
end;

function feature:disable()
    if not self.was_on then return end
    self.was_on = false;

    for _, conn in self.conns do
        conn:Disconnect();
    end;
    table.clear(self.conns);

    if self.last_conn then
        self.last_conn:Disconnect();
        self.last_conn = nil;
    end;

    if self.gui_added_conn then
        self.gui_added_conn:Disconnect();
        self.gui_added_conn = nil;
    end;

    self:stop_spectate();
end;

function feature:connect()
    if self.last_conn then
        self.last_conn:Disconnect();
    end;

    local player_gui = local_player.instance:WaitForChild("PlayerGui");
    player_gui:WaitForChild("LeaderboardGui", 9e9):WaitForChild("MainFrame", 9e9):WaitForChild("ScrollingFrame", 9e9);

    wait_for_player_frame_map();

    for _, frame in player_gui.LeaderboardGui.MainFrame.ScrollingFrame:GetChildren() do
        self:handle(frame)
    end

    self.last_conn = player_gui.LeaderboardGui.MainFrame.ScrollingFrame.ChildAdded:Connect(function(frame)
        self:handle(frame)
    end)
    aztup.maid:give_task(self.last_conn)
end;

function feature:enable()
    self.was_on = true;

    task.spawn(xpcall, function()
        local player_gui = local_player.instance:WaitForChild("PlayerGui");

        if self.gui_added_conn then
            self.gui_added_conn:Disconnect();
        end;

        self.gui_added_conn = player_gui.ChildAdded:Connect(function(child)
            if child.Name ~= "LeaderboardGui" then
                return
            end;
            self:connect();
        end);

        self:connect();
    end, warn);
end; 

return feature