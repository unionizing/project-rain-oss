


if game.PlaceId == 4111023553 then return true end

Logger.log_for_devs("beginning anticheat bypass...");

task.spawn(pcall, function()
    

    local client_manager = game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("ClientActor"):WaitForChild("ClientManager")

    client_manager.Enabled = false;
    Logger.log_for_devs("disabled client manager/error check (1)");
end);
local pi = (function() 
    return 0.125 + tonumber(STR_TBL_SF_INVOKE("3"))
end)();
local heaven_key = 2754 * (72 % (0.6769230769205024 * 7 * 7 % 5 % 64 % 41 / 66 + 12) / 54 / (4 / 36 + 5.3655660377358485) + 1 * 4 % 52 * 21 / 4 % 35 / 3) / 35 * 38 + (66 + (8 + 4 + 5 + 2 + 19035.52631578947) / 34 + 40 % 41 / 56 % 65 * 57 + 3381) + 420 + 35 * (0.3150684931506849 + 69 + 14 / 56 + 28 + 36) + (pi);
local KeyHandlerClass = {} do
    KeyHandlerClass.__index = KeyHandlerClass;
    
    KeyHandlerClass[STR_TBL_SF_INVOKE("get_key_internal")] = function(self, remote)
        if self.cache[remote] then
            return self[STR_TBL_SF_INVOKE("remotes")][self.cache[remote] ]        
end

        if not self[STR_TBL_SF_INVOKE("remotes")] or not self[STR_TBL_SF_INVOKE("enc_f")] then
            repeat task.wait() until self[STR_TBL_SF_INVOKE("remotes")] and self[STR_TBL_SF_INVOKE("enc_f")];
        end

        local encoded_remote = self.cache[remote] or self[STR_TBL_SF_INVOKE("enc_f")](remote); 
        self.cache[remote] = encoded_remote;

        return encoded_remote and self[STR_TBL_SF_INVOKE("remotes")][encoded_remote] or nil        
        
        
        
    
end;

    KeyHandlerClass[STR_TBL_SF_INVOKE("get_key")] = function(self, remote)
        local success, res = pcall(KeyHandlerClass[STR_TBL_SF_INVOKE("get_key_internal")], self, remote);
        if success then
            return res        
else
            
            return        
end
    end

    KeyHandlerClass[STR_TBL_SF_INVOKE("get_cache")] = function(self, remote)
        local encoded_remote = self.cache[remote];
        if not encoded_remote then
            return nil        
end

        return self[STR_TBL_SF_INVOKE("remotes")][encoded_remote]    
end;

    KeyHandlerClass[STR_TBL_SF_INVOKE("handle_gk")] = function(self)
        local attempts = 0;
        repeat
            for _, tbl in next, getgc(true) do
                if typeof(tbl) ~= "table" then continue end
                if getrawmetatable(tbl) then continue end
                if #tbl ~= 13 or tbl[9] ~= heaven_key then continue end

                self[STR_TBL_SF_INVOKE("remotes")] = tbl[12];
                self[STR_TBL_SF_INVOKE("enc_f")] = tbl[13];
                break            
end

            if self[STR_TBL_SF_INVOKE("remotes")] and self[STR_TBL_SF_INVOKE("enc_f")] then
                break            
end

            attempts += 1;
            task.wait(attempts / 20);
        until self[STR_TBL_SF_INVOKE("remotes")] and self[STR_TBL_SF_INVOKE("enc_f")];
        if shared.b then return Logger.log_for_devs("[kh] already bypassed this session")end
        Logger.log_for_devs("[kh] grabbed remotes & enc_f");

        
        local key_handler_module = require(services.ReplicatedStorage:WaitForChild(STR_TBL_SF_INVOKE("Modules")):WaitForChild(STR_TBL_SF_INVOKE("ClientManager")):WaitForChild(STR_TBL_SF_INVOKE("KeyHandler")));
        local generate_guid = game:GetService("HttpService").GenerateGUID;

        local L_231 = function()
            local L_223 = generate_guid(game:GetService("HttpService"), false):lower():gsub("[%-]*", "");
            local L_224 = math.random(8, 16);
            local L_225 = L_223:sub(1, L_224);
            local L_226 = false;
            for L_227 = 1, L_224, 1 do
                local L_228 = L_225:sub(1, L_227 - 1);
                local L_229 = L_225:sub(L_227, L_227);
                local L_230 = L_225:sub(L_227 + 1);
                local n = tonumber(L_229)
                if n then
                    L_229 = string.char(103 + n);
                end;
                if L_227 == 1 or math.random(1, 6) == 1 and not L_226 and not (L_227 >= L_224) then
                    L_229 = L_229:upper();
                    L_226 = true;
                else
                    L_226 = false;
                end;
                L_225 = L_228 .. L_229 .. L_230;
            end;
            return (L_225:sub(1, L_224))        
end;

        local function create_key(remote)
            self[STR_TBL_SF_INVOKE("remotes")][self[STR_TBL_SF_INVOKE("enc_f")](remote.Name)] = remote;
            remote.Name = L_231();
        end

        local function get_key(remote)
            if typeof(remote) ~= "string" then
                return            
end

            return self[STR_TBL_SF_INVOKE("remotes")][self[STR_TBL_SF_INVOKE("enc_f")](remote)]        
end

        hookfunction(key_handler_module, function() 
            return {
                [1] = get_key,
                [2] = create_key,
                [3] = "made with <3 from uni, hon, temped, soggy!!!",
            }
        end)

        for _, tbl in getgc(true) do
            if typeof(tbl) ~= "table" then continue end
            if getrawmetatable(tbl) then continue end
            if #tbl ~= 2 then continue end
            if typeof(tbl[1]) ~= "function" or typeof(tbl[2]) ~= "function" then continue end

            local create = tbl[2];
            local get = tbl[1];

            if getinfo(get).source:find("KeyHandler") and getinfo(create).source:find("KeyHandler") then
                hookfunction(get, get_key);
                hookfunction(create, create_key);
                tbl[1] = get_key;
                tbl[2] = create_key; 
                break            
end 
        end

        
        shared.b = true;
    end; 

    function KeyHandlerClass.new()
        local self = setmetatable({}, KeyHandlerClass);
        self.cache = {};

        local start = tick();
        task.spawn(function()
            Logger.log_for_devs("[kh] starting bypass");
            self[STR_TBL_SF_INVOKE("handle_gk")](self);
            Logger.log_for_devs("[kh] finished");
            
        end); 

        return self    
end;
end;


local old_hmm = hookmetamethod;
local parallel_hooks_allowed = parallel_hooks_allowed;
local hookmetamethod = not parallel_hooks_allowed and function(t, method, hook)
    local old;

    local mt = getrawmetatable(t)
    setreadonly(mt, false);
    old = mt[method];
    mt[method] = hook;
    setreadonly(mt, true);

    return old
end or hookmetamethod;


getgenv().KeyHandler = KeyHandlerClass.new();


local requests = services.ReplicatedStorage:WaitForChild("Requests")
local ban_remotes = 0
local bans = {};

Logger.log_for_devs("[hooking] grabbing ban_remotes");

for _, remote in requests:GetChildren() do
    local changed_connections = #getconnections(remote.Changed)
    if changed_connections <= 0 then
        continue
    end

    ban_remotes = ban_remotes + 1
    bans[remote] = true
end

























if not requests:FindFirstChild("ReportGoogleAnalyticsEvent") then
    return local_player.instance:Kick("Failed to get BanRemote[3]")
end;

bans[requests.ReportGoogleAnalyticsEvent] = true;

Logger.log_for_devs("[hooking] hooking remote_event.fire_server");
local old_fireserver;
old_fireserver = hookfunction(Instance.new("RemoteEvent").FireServer, (function(self, ...)
    if bans[self] then
        
        return coroutine.yield()    
end

    return old_fireserver(self, ...)
end));

local animations = {} do
    for _, v in next, services.ReplicatedStorage:WaitForChild(STR_TBL_SF_INVOKE("Assets")):WaitForChild(STR_TBL_SF_INVOKE("Anims")):WaitForChild(STR_TBL_SF_INVOKE("Gestures")):GetChildren() do
        if v:FindFirstChild(STR_TBL_SF_INVOKE("Pack1")) or v:FindFirstChild(STR_TBL_SF_INVOKE("Pack2")) or v:FindFirstChild(STR_TBL_SF_INVOKE("MetalPromo")) then
            animations[v.Name] = v
        end
    end
end

Logger.log_for_devs("[hooking] hooking game_mt.__namecall");
local safety = require("@src/utility/safety");
local is_a = game.IsA;
local old_namecall;
old_namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod();
    if checkcaller() and method ~= "GetAttribute" or not aztup or not aztup.flags then
        if method ~= "FireServer" or self and self.Name ~= "DrawWeapon" then
            return old_namecall(self, ...)
        end;
    end;

    local flags = aztup.flags

    if method == "GetAttribute" and (flags.optimize_game or flags.streamer_mode) then
        local attr_name = ...;
        if flags.optimize_game and table.find({
            "SailLength",
            "ClientC1",
            "ClientCF"
        }, attr_name) then
            return        
elseif flags.streamer_mode then
            if attr_name == "FirstName" then
                return ""            
elseif attr_name == "CharacterName" then
                return ""            
elseif attr_name == "GuildColor" then
                return Color3.new(0.752941, 0.854902, 0.87451)            
elseif attr_name == "GuildEmblemA" or attr_name == "GuildEmblemB" then
                return 0            
end
        end;
    elseif method == "Raycast" then
        local _, _, params = ...;
        local caller = getcallingscript();

        if caller.Name == "ClientPhysics" and general and general.collision_utils and params == general.collision_utils.geomParams then
            return
        end;
    elseif method == "FindFirstChild" then
        local looking_for = ...;
        local caller = getcallingscript();

        if looking_for == "CharacterHandler" and caller.Name == "KeyHandler" then
            warn("CharacterHandler reparent attempt from KeyHandler");
            return coroutine.yield()        
end
    elseif method == "Create" and self == services.TweenService then
        local instance, info, data = ...;
        local new_args = {...};

        if instance == services.Lighting then
            if flags.no_fog and rawget(data, "FogEnd") then
                rawset(data, "FogEnd", nil);
            end

            if flags.full_bright and (rawget(data, "Brightness") or rawget(data, "Ambient")) then
                rawset(data, "Ambient", nil);
                rawset(data, "Brightness", nil);
            end

            new_args[3] = data;
        elseif is_a(instance, "Atmosphere") then
            if flags.no_fog and rawget(data, "Density") then
                rawset(data, "Density", 0);
            end

            new_args[3] = data;
        end;

        return old_namecall(self, unpack(new_args))    
elseif method == "FireServer" then
        if flags.block_input and self then

            local critical_click = KeyHandler:get_cache("CriticalClick");
            if critical_click and self == critical_click and BlockInputManager:should_block_input() and aztup_options.blocked_safe_input_user_moves.Value.Criticals then
                return            
end;
        end
        
        if flags.give_animation_gamepass and self then
            local anim = ...;
            if self.Name == "Gesture" and animations[anim] then
                task.spawn(function()  
                    local fake_anim = local_player.humanoid:LoadAnimation(animations[anim]);
                    local listener;
                    listener = local_player.humanoid.AnimationPlayed:Connect(function(animation_track)
                        if animation_track.Animation.AnimationId == "rbxassetid://6291247414" then
                            animation_track:Stop();
                            fake_anim:Play();
                            
                            local_player.humanoid:GetPropertyChangedSignal("MoveDirection"):Once(function()
                                fake_anim:Stop();
                                listener:Disconnect();
                            end);
                        end
                    end);
                end)

                return old_namecall(self, "Thinking")            
end
        end

        if self.Name == "ClientEffectBatch" then
            return        
end;

        if self.Name == "ActivateMantra" and local_player and local_player.tracker then
            local mantra = ...;
            task.defer(function()
                local_player.tracker:activate_request(mantra);
            end);
        end

        if self.Name == "DrawWeapon" and local_player and local_player.tracker then
            local hold = ...;
            task.defer(function()
                local_player.tracker.last_equip_call = hold;
            end);
        end;

        if self.Name == "UpdateMouse" and flags.silent_aim then
            return        
end;

        if aztup.flags.fall_multiplier and self == aztup.features.fall_multiplier.fall_remote then
            if aztup.flags.only_near_players then
                local players_are_near = false;
                for _, player in services.Players.GetPlayers(services.Players) do
                    if player == local_player.instance then continue end
                    if not player.Character then continue end
                    local pivot = player.Character.GetPivot(player.Character);
                    if not pivot then continue end

                    local dist = (local_player.root_part.Position - pivot.Position).Magnitude
                    if dist <= 550 then
                        players_are_near = true;
                    end
                end

                if not players_are_near then return end
            end

            local first_argument = ...;
            if aztup.flags.only_minimum_fall_dmg and first_argument >= 21 then
                local arguments = {...};
                arguments[1] = 20 + math.random();

                return old_namecall(self, unpack(arguments))            
end
        end
    end;

    if bans[self] then
        
        return coroutine.yield()    
end
    
    return old_namecall(self, ...)
end)

Logger.log_for_devs("[hooking] hooking game_mt.__newindex");

if isfunctionhooked(getrawmetatable(game).__newindex) then
    restorefunction(getrawmetatable(game).__newindex);
end

local old_newindex;
old_newindex = hookmetamethod(game, "__newindex", (function(self, key, value, ...)
    if checkcaller() or not (key == "Ambient" or key == "Velocity" or key == "Text" or key == "ActiveController" or key == "WalkSpeed") then
        return old_newindex(self, key, value, ...)
    elseif aztup then
        local flags = aztup.flags;
        if flags.full_bright and self == services.Lighting then
            local level = 255 * (aztup.flags.fullbright_intensity / 100);
            return old_newindex(self, key, key == "Ambient" and Color3.fromRGB(level,level,level) or value)        
elseif flags.mob_ai_breaker and key == "Velocity" then
            if value.Magnitude < 0.2 then
                return            
end;
        elseif flags.streamer_mode and key == "Text" and (self.Name == "Character" or self.Name == "Slot") and self.Parent.Name == "CharacterInfo" then
            if self.Name == "Character" then
                return old_newindex(self, key, "", ...)            
else
                value = value:gsub(services.Players.LocalPlayer.UserId, "0");
                return old_newindex(self, key, value, ...)            
end
        elseif 
            (flags.fly or flags.noclip)
            and key == "ActiveController"
            and self.Parent == local_player.character
        then
            local airController = self.Parent:FindFirstChild("AirController")

            return old_newindex(self, key, airController or value)
        elseif  
            flags.multiply_s 
            and key == "WalkSpeed"
            and (function() 
                local caller = getcallingscript();
                return caller and caller.Name == "EffectsClient"
            end)()
        then
            local mult = aztup.features.multiply_s;
            mult = mult and mult.speed_mult or 0;
            mult /= 100;
            mult += 1;
            return old_newindex(self, key, mult and value and value * mult or value)        
end
        
    end;

    return old_newindex(self, key, value, ...)
end))

Logger.log_for_devs("[hooking] hooking unreliable_remote.fire_server");

local old_fireserver;
old_fireserver = hookfunction(Instance.new(STR_TBL_SF_INVOKE("UnreliableRemoteEvent"))[STR_TBL_SF_INVOKE("FireServer")], (function(self, ...)
    if bans[self] then
        
        return coroutine.yield()    
end
    
    if aztup and aztup.flags.no_one_bit and aztup.features.no_one_bit.removed and self == aztup.features.no_one_bit.server_swim then
        return    
end;

    if aztup and aztup.flags and aztup.flags.block_input and self then
        if (
            self == KeyHandler:get_cache(STR_TBL_SF_INVOKE("OffhandAttack")) and aztup_options.blocked_safe_input_user_moves.Value.M2s or
            self == KeyHandler:get_cache(STR_TBL_SF_INVOKE("LeftClick")) and aztup_options.blocked_safe_input_user_moves.Value.M1s
        ) and BlockInputManager:should_block_input() then
            return        
end;
    end

    return old_fireserver(self, ...)
end));

Logger.log_for_devs("[hooking] hooking tostring");

local old_to_string; 
old_to_string = hookfunction(tostring, function(str)
	if str == STR_TBL_SF_INVOKE("EEKEWAEJIWAJDOIWAJDIOJAWDIOJAWODJOAIW") then
		game:GetService("Players").LocalPlayer:Kick(STR_TBL_SF_INVOKE("[ac bypass] saturn (trapped-ts)"));
        warn(STR_TBL_SF_INVOKE("[saturn trapped-ts info]"), debug.traceback());
		return coroutine.yield()	
end;

	return old_to_string(str)
end);

env.unhooked_newindex = old_newindex;
env.unhooked_namecall = old_namecall;

task.spawn(function() 
    Logger.log_for_devs("[hooking] hooking camera popper");

    local old_popper;
    old_popper = hookfunction(require(services.StarterPlayer:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("ZoomController"):WaitForChild("Popper")), function(...) 
        return (aztup and (aztup.flags.noclip or aztup.flags.noclip_camera)) and math.huge or old_popper(...)    
end);
end);

Logger.log_for_devs("[hooking] finished...");

return true