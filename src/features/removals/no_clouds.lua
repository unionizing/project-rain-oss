local self = Feature:new("no_clouds");

function self:remove_clouds()
    local weather_markers = services.ReplicatedStorage:WaitForChild("MarkerWorkspace"):WaitForChild("WeatherMarkers", math.huge);
    for _, item in weather_markers:GetChildren() do
        item:Destroy();
    end;

    for _, conn in getconnections(weather_markers.ChildAdded) do
        conn:Disable();
    end;
end

self.enable = function()
    return task.spawn(self.remove_clouds)
end;

return self