local function unequip_all()
    local requests = services.ReplicatedStorage:FindFirstChild("Requests");
    local unequip = requests and requests:FindFirstChild("Unequip");
    if not unequip then return end;

    local data;
    pcall(function()
        data = require(services.ReplicatedStorage.Info.DataReplication).GetData();
    end);

    if not data or not data.Equipment then return end;

    for slot in pairs(data.Equipment) do
        pcall(function()
            unequip:InvokeServer(slot, true);
        end);

        task.wait(0.05);
    end;
end

return function()
    unequip_all();

    require("@src/features/buttons/generic_teleport").new(CFrame.new(-959.787659, 146.996887, -6659.63037, 5.91874123e-05, 0.88701129, -0.461747706, 1, -5.91278076e-05, 1.44988298e-05, -1.44988298e-05, -0.461747706, -0.88701129), function()
                return workspace:FindFirstChild("OneEntrance")    
end):run();
end
