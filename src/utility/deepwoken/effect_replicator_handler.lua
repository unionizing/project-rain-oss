





if not getloadedmodules then
    return game:GetService(STR_TBL_SF_INVOKE("Players")).LocalPlayer:Kick(STR_TBL_SF_INVOKE("Executor is unsupported. [missing getloadedmodules, effect_replicator_handler]"))
end;


local Maid = require("@src/utility/maid");
local EffectReplicatorHandler = {};
EffectReplicatorHandler.__index = EffectReplicatorHandler;
EffectReplicatorHandler.hooks = {};
EffectReplicatorHandler.maid = Maid.new();

function EffectReplicatorHandler:hook(type, func)
    local hook = {};
    function hook:remove()
        table.remove(EffectReplicatorHandler.hooks, self.index);
    end; 

    hook.type = type;
    hook.call = func;
    hook.index = table.insert(EffectReplicatorHandler.hooks, hook);

    return hook
end;

function EffectReplicatorHandler:connect()
    self.maid:do_cleaning();

    local RawEffectReplicator = game:GetService("ReplicatedStorage"):WaitForChild("EffectReplicator");
    if not table.find(getloadedmodules(), RawEffectReplicator) then
        repeat task.wait(0.06) warn("getloadedmodules might be failing!") until table.find(getloadedmodules(), RawEffectReplicator);
    end;
    local EffectReplicator = base_require(game:GetService("ReplicatedStorage"):WaitForChild("EffectReplicator"));
    getgenv().EffectReplicator = EffectReplicator;

    self.maid:give_task(EffectReplicator.EffectAdded:Connect(function(effect)
        setthreadidentity(8);
        for _, hook in pairs(EffectReplicatorHandler.hooks) do
            if hook.type == "added" and hook.call then
                task.spawn(xpcall, function()
                    hook.call(effect);
                end, function(err)
                    Logger.error(string.format("effectreplicator added hook: %s", err));
                end);
            end;
        end;
    end));
    
    self.maid:give_task(EffectReplicator.EffectRemoved:Connect(function(effect)
        for _, hook in pairs(EffectReplicatorHandler.hooks) do
            if hook.type == "removed" then
                xpcall(function()
                    hook.call(effect);
                end, function(err) 
                    Logger.error(string.format("effectreplicator removed hook: %s", err));
                end);
            end;
        end;  
    end));
end;

task.spawn(pcall, function()
    while not pcall(function() aztup.maid:give_task(EffectReplicatorHandler.maid); end) do task.wait() end;
end);

task.spawn(pcall, function()
    local update = game:GetService("ReplicatedStorage"):WaitForChild("Requests"):WaitForChild("EffectReplication"):WaitForChild("_update");
    update.OnClientEvent:Connect(function(effect)
        if effect.updateType == "clear" or effect.updateType == "updatecontainer" then
            EffectReplicatorHandler:connect();  
        end;
    end);

    EffectReplicatorHandler:connect();
end);
return EffectReplicatorHandler