
local feature = Feature:new("auto_flow_state")

local dontrun = false
local maid = {}
local connection


local TARGET_ANIMATION_IDS = {
    "rbxassetid://110691694093015",
    "rbxassetid://85523657178401",
    "rbxassetid://100709561068031",
    "rbxassetid://139465383955578",
    "rbxassetid://82111969749817",
    "rbxassetid://101880653361558",
    "rbxassetid://132164383275060",
    "rbxassetid://72748965289041",
    "rbxassetid://12564120372",
}

local function isTargetAnimation(animId)
    for _, id in ipairs(TARGET_ANIMATION_IDS) do
        if animId == id then return true end
    end
    return false
end

function feature:enable()
    dontrun = false
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer and LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then return end

    if maid.animConn then maid.animConn:Disconnect() end
    maid.animConn = Humanoid.AnimationPlayed:Connect(function(track)
        if dontrun then return end
        if not track or not track.Animation or not track.Animation.AnimationId then return end
        local animId = track.Animation.AnimationId
        if isTargetAnimation(animId) then
            
            local flow = LocalPlayer.Backpack:FindFirstChild("Talent:Flow State") or Character:FindFirstChild("Talent:Flow State")
            if flow then
                local activateRt = flow:FindFirstChild("ActivateRt")
                if activateRt then
                    activateRt:FireServer()
                end
            end
        end
    end)
    maid.auto_flow_state = maid.animConn
end

function feature:disable()
    dontrun = false
    if maid.animConn then
        maid.animConn:Disconnect()
        maid.animConn = nil
    end
    if maid.auto_flow_state then
        maid.auto_flow_state = nil
    end
end

return feature