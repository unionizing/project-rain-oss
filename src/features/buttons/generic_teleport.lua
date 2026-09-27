local GenericTeleport = {}
GenericTeleport.__index = GenericTeleport

function GenericTeleport.new(destination, destinationPartGetter, stop_condition)
    local self = setmetatable({}, GenericTeleport)

    self.last_stream_request = 0;
    self.destination = destination;
    self.destinationPartGetter = destinationPartGetter;
    self.stop_condition = stop_condition;

    return self
end

function GenericTeleport:requestStreamAroundDestination()
    if not workspace.StreamingEnabled then return end

    if tick() - self.last_stream_request > 1/30 then
        self.last_stream_request = tick();
        local_player.instance:RequestStreamAroundAsync(Vector3.new(self.destination.X, self.destination.Y, self.destination.Z));
    end
end

function GenericTeleport:run()
    local set_for_user;
    if not aztup.flags.noclip then
        set_for_user = true;
        aztup_toggles.noclip:SetValue(true);
    end;

    self.conn = services.RunService.PostSimulation:Connect(function()
        self:requestStreamAroundDestination();

        if self.stop_condition and self:stop_condition() then
            self.conn:Disconnect();

            if set_for_user then
                aztup_toggles.noclip:SetValue(false);
            end;
        end;

        local destinationPart = self:destinationPartGetter();
        if destinationPart and destinationPart:FindFirstChild("TouchInterest") and local_player.root_part.Parent then 
            local_player.root_part.AssemblyLinearVelocity = Vector3.one * (math.random() / 100);
            local_player.root_part.CFrame = self.destination * CFrame.new(math.random() / 100, math.random() / 100, math.random() / 100);
            
            xpcall(function()
                
                firetouchinterest(local_player.root_part, destinationPart, true);
                firetouchinterest(local_player.root_part, destinationPart, false);
            end, print);
        end;

        if local_player.humanoid then
            sethiddenproperty(local_player.humanoid, "MoveDirectionInternal", Vector3.one);
        end
    end); 
end;

return GenericTeleport