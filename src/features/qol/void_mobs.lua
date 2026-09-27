

local feature = {};

local clientPart = Instance.new('Part', workspace)
local peer = gethiddenproperty(clientPart, "NetworkOwnerV3")
clientPart:Destroy()

function feature:owner(part)
    local success, ID = pcall(function()
        return gethiddenproperty(part, "NetworkOwnerV3")
    end)
    if success then
        return ID == peer
    end
    return false
end

sf_isnetworkowner = function(part)
    return feature:owner(part)
end

local old_destroy_point = workspace:GetAttribute("OriginalFPDH") or workspace.FallenPartsDestroyHeight;
workspace.FallenPartsDestroyHeight = 0/0;
workspace:SetAttribute("OriginalFPDH", old_destroy_point);

function feature:run()
	sethiddenproperty(local_player.instance, "MaxSimulationRadius", 3000);
	sethiddenproperty(local_player.instance, "SimulationRadius", 3000);

    for _, mob in pairs(workspace.Live:GetChildren()) do
        if mob.Name:sub(1,1) ~= "." then continue end
        if mob.Name:find("chaser") and aztup.automation:has_any() and not aztup.features.void_mobs.let_me_void_chaser then continue end

        local root = mob:FindFirstChild("HumanoidRootPart");
        if not root then continue end

        for _, part in pairs(mob:GetChildren()) do
            if part:IsA("BasePart") and (self:owner(part)) then
                part.CFrame = CFrame.new(root.Position.X, old_destroy_point - 50, root.Position.Z);
                part.Velocity = Vector3.new(0, -12500, 0)
            end 
        end
    end
end

local feat = Feature:new("void_mobs", game:GetService("RunService").Heartbeat, function()
    feature:run()
end);
return feat