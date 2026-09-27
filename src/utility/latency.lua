local latency = {};
local ping = services.Stats:FindFirstChild("Data Ping", true);
local notified = false;

function latency:get_ping()
    if not ping then
        if not notified then
            notified = true;
            Logger:short_notify("Cant find ping stat, Ignore this if kicked.");
        end
        return 0    
end

    local val;
    local old = getthreadidentity();
    setthreadidentity(8);
    val = ping:GetValue();
    setthreadidentity(old);
    return val / 1000
end;

function latency:half_ping()
    return latency:get_ping() / 2
end;

return latency