
local time_waited = tick()
local toggled = false
local vim = Instance.new('VirtualInputManager')
aztup.maid:give_task(vim)

local feature = Feature:new('anti_afk', game:GetService('RunService').Heartbeat, LPH_NO_VIRTUALIZE(function(...)  
    if (tick() - time_waited) >= 120 and toggled then
        vim:SendKeyEvent(true, Enum.KeyCode.Unknown, false, game)
        vim:SendKeyEvent(false, Enum.KeyCode.Unknown, false, game)
        time_waited = tick()
    end
end))

function feature:enable()
    toggled = true;
end

function feature:disable()
    toggled = false;
end

return feature