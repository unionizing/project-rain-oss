local feature = Feature:new("auto_dustlunge");

local runService = game:GetService("RunService")
local players = game:GetService("Players")
local currentSimulationPart = nil
local isFeatureEnabled = false

local defaultConfig = {
    hitboxType = "Block",
    sizeX = 2, sizeY = 6, sizeZ = 10,
    shiftOffset = -5
}


local function cleanupSimulation()
    if currentSimulationPart then
        currentSimulationPart:Destroy()
        currentSimulationPart = nil
    end
end

local function runSimulationStep()
    if not isFeatureEnabled then return end
    if not aztup.features.auto_dustlunge.held or EffectReplicator:FindEffect("GrabCD") then 
        if currentSimulationPart then currentSimulationPart:Destroy() end
        return    
end

    local character = players.LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local config = defaultConfig
    local size = Vector3.new(config.sizeX, config.sizeY, config.sizeZ)
    local usedCFrame = root.CFrame

    if config.shiftOffset ~= 0 then
        usedCFrame = usedCFrame * CFrame.new(0, 0, config.shiftOffset)
    end

    if not currentSimulationPart or currentSimulationPart.Parent ~= workspace then
        if currentSimulationPart then currentSimulationPart:Destroy() end
        currentSimulationPart = Instance.new("Part")
        currentSimulationPart.Name = "HitboxSimulationPart"
        currentSimulationPart.Anchored = true
        currentSimulationPart.CanCollide = false
        currentSimulationPart.CanQuery = false
        currentSimulationPart.CanTouch = false
        currentSimulationPart.Material = Enum.Material.ForceField
        currentSimulationPart.CastShadow = false
        currentSimulationPart.Transparency = aztup.flags.auto_dustlunge_debug and 0.5 or 1.0
    end

    currentSimulationPart.Size = size
    if config.hitboxType == "Block" then
        currentSimulationPart.Shape = Enum.PartType.Block
        currentSimulationPart.CFrame = usedCFrame
    end;

    currentSimulationPart.Parent = workspace

    local live = workspace:FindFirstChild("Live")
    local instances = {}
    if live then
        for _, child in next, live:GetChildren() do
            if child ~= character then
                table.insert(instances, child)
            end
        end
    end

    local sprinting = EffectReplicator:FindEffect("Sprinting");
    if #instances > 0 then
        local params = OverlapParams.new()
        params.FilterDescendantsInstances = instances
        params.FilterType = Enum.RaycastFilterType.Include
        local ok, parts = pcall(function()
            return workspace:GetPartsInPart(currentSimulationPart, params)
        end)
        currentSimulationPart.Color = (ok and parts and #parts > 0) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)

        if (ok and parts and #parts > 0) then
            local char = parts[1]:FindFirstAncestorWhichIsA("Model");
            if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then return end

			local dotProduct = (char.HumanoidRootPart.Position - local_player.root_part.Position):Dot(local_player.root_part.CFrame.LookVector);
			if (dotProduct <= 0) then return end; 
            if sprinting then
                local_player.character:WaitForChild("CharacterHandler"):WaitForChild("Requests").ServerSprint:FireServer(false);
                task.wait(1 / 20);
            end;

            local script_crouched = false;
            if not EffectReplicator:FindEffect("Crouching") then
                local_player.character:WaitForChild("CharacterHandler"):WaitForChild("Requests"):WaitForChild("ServerCrouch"):FireServer(true);
                script_crouched = true;
            end;

            local start = tick();
            repeat task.wait() until EffectReplicator:FindEffect("Crouching") or tick() - start > Latency:get_ping() * 2;
            if tick() - start > Latency:get_ping() * 2 then
                local_player.character:WaitForChild("CharacterHandler"):WaitForChild("Requests"):WaitForChild("ServerCrouch"):FireServer(false);
                if sprinting then
                    local_player.character:WaitForChild("CharacterHandler"):WaitForChild("Requests").ServerSprint:FireServer(true);
                end;
                return            
end;
            task.spawn(function()
                local remote = KeyHandler:get_cache("LeftClick") or KeyHandler:get_key("LeftClick");
                if not remote or not remote:IsDescendantOf(local_player.character) or not remote.Parent then
                    remote = KeyHandler:get_key("LeftClick");
                end


                if not remote then return end
                remote:FireServer(false, local_player.instance:GetMouse().Hit, {
                	S = false,
                	NOAERIALS = true, 
                	Space = false,
                	Right = services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2),
                	W = false,
                	Left = true,
                    ctrl = false
                }); 
            end);
            task.wait(1 / 20);
            if script_crouched then
                local_player.character:WaitForChild("CharacterHandler"):WaitForChild("Requests"):WaitForChild("ServerCrouch"):FireServer(false);
            else
                local VIM = Instance.new("VirtualInputManager");
                VIM:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game);
                VIM:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game);
            end;

            if sprinting then
                local_player.character:WaitForChild("CharacterHandler"):WaitForChild("Requests").ServerSprint:FireServer(true);
            end;
        end;
    else
        currentSimulationPart.Color = Color3.fromRGB(255,0,0)
    end
end

function feature:enable()
    cleanupSimulation()
    isFeatureEnabled = true
end

function feature:disable()
    isFeatureEnabled = false
    cleanupSimulation()
end

function feature:refresh()
    if isFeatureEnabled then
        cleanupSimulation()
    end
end

aztup.maid:give_task(scheduler:add_task(1 / 5):Connect(runSimulationStep))

return feature