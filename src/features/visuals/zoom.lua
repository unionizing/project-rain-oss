








local old_fov;
local self;

self = Feature:new("zoom", services.RunService.RenderStepped, function()
    if not local_player.character then return end

    if (aztup.flags.zoom_apply_mouse_sens) then
        services.UserInputService.MouseDeltaSensitivity = 0.5 * aztup.flags.zoom_sens_mult;
    else
        services.UserInputService.MouseDeltaSensitivity = 1;
    end

    local_player.instance:SetAttribute("FieldOfView", old_fov * aztup.flags.zoom_sens_mult);
end);

function self:enable()
    old_fov = local_player.instance:GetAttribute("FieldOfView");
    self.was_enabled = true;
end

function self:disable()
    if not self.was_enabled then return end

    services.UserInputService.MouseDeltaSensitivity = 1;
    local_player.instance:SetAttribute("FieldOfView", old_fov);
end

return self