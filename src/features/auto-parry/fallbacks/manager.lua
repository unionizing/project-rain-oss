local fallbacks = {};
local manager = {};

function manager.register_fallback(fallback)
    table.insert(fallbacks, fallback);
end

function manager.new()
    return setmetatable({}, {__index = manager})
end

function manager:execute()
    for _, fallback in fallbacks do
        if fallback.shouldExecute() then
            fallback.execute();
            return true        
end
    end

    return false
end

for _, object in list_modules("features/auto-parry/fallbacks/objects/*") do
    local success, fallback = pcall(require, object);
    if success and fallback then
        table.insert(fallbacks, fallback);
    else
        print("failed to get fallback from " .. object);
    end
end

return manager.new()