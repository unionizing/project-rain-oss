local RunService = game:GetService("RunService")
local last_update = 0;
local random = Random.new();
local speed_mult = 1;

local self;
self = Feature:new("multiply_s", RunService.RenderStepped, LPH_NO_VIRTUALIZE(function(dt)
    local min = math.min(aztup.flags.min_speed_mult, aztup.flags.max_speed_mult);
    local max = math.max(aztup.flags.min_speed_mult, aztup.flags.max_speed_mult);

    speed_mult = random:NextInteger(min, max);

    if tick() - last_update > 0.1 and not (aztup_options.multiplier_type.Value == "CFrame (legit)" or aztup_options.multiplier_type.Value == "CFrame (blatant)")  then
        last_update = tick();
            
        self.speed_mult = speed_mult;
    elseif (aztup_options.multiplier_type.Value == "CFrame (legit)" or aztup_options.multiplier_type.Value == "CFrame (blatant)") and local_player.humanoid.WalkSpeed > 5 then
        if aztup_options.multiplier_type.Value == "CFrame (legit)" and local_player.humanoid.WalkSpeed < 6 or local_player.humanoid.MoveDirection.Magnitude <= 0 then
            return        
end;

        local_player.root_part.CFrame += (local_player.humanoid.MoveDirection.Unit * dt) * (speed_mult / 10);
        self.speed_mult = 0;
    end;
end));

function self:enable()
    last_update = 0;
end;

return self