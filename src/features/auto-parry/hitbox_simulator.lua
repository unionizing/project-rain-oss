local feature = Feature:new("show_hitbox_simulation");

local runService = game:GetService("RunService")
local players = game:GetService("Players")
local currentSimulationPart = nil
local isFeatureEnabled = false

local defaultConfig = {
    hitboxType = "Block",
    sizeX = 4, sizeY = 4, sizeZ = 4,
    shiftOffset = 0
}

local function getCurrentConfig()
    local function get(opt)
        return (opt and opt.Value ~= nil) and opt.Value or nil
    end
    return {
        hitboxType = get(aztup_options.HS_HitboxType) or defaultConfig.hitboxType,
        sizeX = get(aztup_options.HS_HitboxSizeX) or defaultConfig.sizeX,
        sizeY = get(aztup_options.HS_HitboxSizeY) or defaultConfig.sizeY,
        sizeZ = get(aztup_options.HS_HitboxSizeZ) or defaultConfig.sizeZ,
        shiftOffset = get(aztup_options.HS_ShiftOffset) or defaultConfig.shiftOffset
    }
end

local function cleanupSimulation()
    if currentSimulationPart then
        currentSimulationPart:Destroy()
        currentSimulationPart = nil
    end
end

local function runSimulationStep()
    if not isFeatureEnabled then return end

    local character = players.LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local config = getCurrentConfig()
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
        currentSimulationPart.Transparency = 0.5
    end

    currentSimulationPart.Size = size
    if config.hitboxType == "Block" then
        currentSimulationPart.Shape = Enum.PartType.Block
        currentSimulationPart.CFrame = usedCFrame
    elseif config.hitboxType == "Ball" then
        currentSimulationPart.Shape = Enum.PartType.Ball
        currentSimulationPart.CFrame = usedCFrame
    elseif config.hitboxType == "Cylinder" then
        currentSimulationPart.Shape = Enum.PartType.Cylinder
        currentSimulationPart.CFrame = usedCFrame * CFrame.Angles(0, 0, math.rad(90))
    end
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

    if #instances > 0 then
        local params = OverlapParams.new()
        params.FilterDescendantsInstances = instances
        params.FilterType = Enum.RaycastFilterType.Include
        local ok, parts = pcall(function()
            return workspace:GetPartsInPart(currentSimulationPart, params)
        end)
        currentSimulationPart.Color = (ok and parts and #parts > 0) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
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

aztup.maid:give_task(runService.RenderStepped:Connect(runSimulationStep))

return feature