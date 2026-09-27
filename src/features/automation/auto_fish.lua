
local feature = Feature:new("auto_fish");
local dontrun = false
local lastSend
local maid = {}
local connection

function feature:enable()
    dontrun = false
    lastSend = tick()

    local RunService = game:GetService("RunService")

    connection = RunService.RenderStepped:Connect(function()
        if dontrun then return end
        if not local_player or not local_player.character then return end
        local character = local_player.character

        local fishingGui = local_player.instance and local_player.instance.PlayerGui and local_player.instance.PlayerGui:FindFirstChild("FishingGui")
        if not fishingGui or not fishingGui.Enabled then
            local rod = character:FindFirstChild("Fishing Rod") or (local_player.instance and local_player.instance.Backpack and local_player.instance.Backpack:FindFirstChild("Fishing Rod"))
            if tick() - lastSend > 2.5 and rod and workspace:FindFirstChild("Thrown") and not workspace.Thrown:FindFirstChild("Bobby_" .. local_player.instance.Name) then
                rod:Activate()
                task.wait(0.25)
                rod:Deactivate()
            end
            return
        end

        local mainFrame = fishingGui:FindFirstChild("MainFrame")
        if mainFrame then
            local holdA = mainFrame:FindFirstChild("HoldA") and mainFrame.HoldA.Visible
            local holdD = mainFrame:FindFirstChild("HoldD") and mainFrame.HoldD.Visible
            local holdS = mainFrame:FindFirstChild("HoldS") and mainFrame.HoldS.Visible

            local args = {
                {
                    a = holdA,
                    d = holdD,
                    s = holdS
                }
            }

            pcall(function()
                local fishingRod = local_player.instance and local_player.instance.Backpack and local_player.instance.Backpack:FindFirstChild("Fishing Rod")
                if fishingRod and fishingRod:FindFirstChild("InputUpdate") then
                    fishingRod.InputUpdate:FireServer(unpack(args))
                end
            end)

            pcall(function()
                local fishingRod = character:FindFirstChild("Fishing Rod")
                if fishingRod and fishingRod:FindFirstChild("InputUpdate") then
                    fishingRod.InputUpdate:FireServer(unpack(args))
                end
            end)
        end

        lastSend = tick()
    end)
    maid.auto_fish = connection
end

function feature:disable()
    dontrun = false
    if connection then
        connection:disconnect()
        connection = nil
    end
    if maid.auto_fish then
        maid.auto_fish = nil
    end
end

return feature