local env = getgenv();
local lph = "LPH";

env[lph .. "_" .. "JIT_MAX"] = function(f)
    return f
end
  
env["LRM" .. "_" .. "INIT_SCRIPT"] = function(f)
    return f()
end 
env[lph .. "_" .. "JIT"] = function(f)
    return f
end 

env[lph .. "_" .. "NO_VIRTUALIZE"] = function(f)
    return f
end

env[lph .. "_ENCSTR"] = function(f)
    return f
end;

env["AUTH_GET_CONSTANT"] = function(...)
    return ...
end 

local services;
LPH_NO_VIRTUALIZE(function()
    local service_cache = {}
    local gs = game.GetService;

    local function cache_service(index)
        service_cache[index] = gs(game,index)
        return service_cache[index]
    end

    services = setmetatable({}, {
        __index = function(_, index)
            return service_cache[index] or cache_service(index)        
end
    });
    
    getgenv().services = services;
end)(); 
 

env["PROT_OBF" .. "_" .. "STR_SAFE_MACRO"] = function(...)
    return ...
end 


local is_eastern = game.PlaceId == 6473861193;
local is_depths = game.PlaceId == 5735553160;
local is_etrean = game.PlaceId == 6032399813;
local is_chime = game.PlaceId == 6832944305;
local is_dungeon =  game.PlaceId == 8668476218;

local parallel_hooks_allowed = identifyexecutor() == "Volt" or identifyexecutor() == "Synapse Z";

local safe_fireserver_func, safe_json_decode;

if not LPH_OBFUSCATED then
    getgenv().script_require = builder_require;
end

local lexend;
local sf_isnetworkowner;
local ap_breaker_tbl;
local chance_store;
local loaded_signal;

local is_regular = LRM_ScriptName == "Project Rain"
local old_fpp = fireproximityprompt;
local fireproximityprompt = function(...)
    local prompt = ...;
    local called = false;
    local triggered_conn = game:GetService("ProximityPromptService").PromptTriggered:Once(function()
        called = true;
    end);
    local res = old_fpp(...)
    triggered_conn:Disconnect();
    
    if not called then 
        firesignal(game:GetService("ProximityPromptService").PromptTriggered, prompt, game:GetService("Players").LocalPlayer);
    end;
    return res
end

local user_service;
local place_name = ({
    [5735553160] = "The Depths",
    [6032399813] = "Etrean Luminant",
    [6473861193] = "Eastern Luminant",
    [6832944305] = "Arena",
    [8668476218] = "Dungeon",
})[game.PlaceId];