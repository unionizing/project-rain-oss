local self;
self = Feature:new("inf_zoom", services.RunService.RenderStepped, function()
    if tick() - (self.last_update or 0) < 1 then return end
    
    self.last_update = tick();
    local_player.instance.CameraMaxZoomDistance = 500;
end);
function self:disable()
    if not self.last then return end
    local_player.instance.CameraMaxZoomDistance = self.last;
end;

function self:enable()
    self.last = local_player.instance.CameraMaxZoomDistance;
end;

return self