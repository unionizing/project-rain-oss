local servers = {};

local function decode_asset(asset)
    local decoded = services.EncodingService:Base64Decode(buffer.fromstring(asset));
    local decompress = services.EncodingService:DecompressBuffer(decoded, Enum.CompressionAlgorithm.Zstd);
    return buffer.tostring(decompress)
end;

local hop_script = decode_asset(inline_asset_b96("@assets/hopper.lua"));

function kick_window(message)
    task.spawn(pcall, function()
        local_player.instance:Kick("Serverhopping...");
        task.wait();
        
        local roblox_prompt_gui = services.CoreGui:FindFirstChild("RobloxPromptGui")
        if not roblox_prompt_gui then
            return
        end
    
        roblox_prompt_gui.promptOverlay.ErrorPrompt.TitleFrame.ErrorTitle.TextColor3 = Color3.fromRGB(125, 196, 228)
        roblox_prompt_gui.promptOverlay.ErrorPrompt.TitleFrame.ErrorTitle.Text = "Project Rain"
        roblox_prompt_gui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text = message
    end);
    while task.wait() do
        game:GetService("TeleportService"):Teleport(4111023553);
    end;
end;

return { 
    hop = function(_, slot, small, do_sound, expiry)
        local hop_script = string.format(hop_script, slot or "A", small ~= nil and tostring(small) or 'false', tostring(do_sound), 'false')

        if game.PlaceId ~= 4111023553 then 
            xpcall(function()
                local blacklisted_servers = isfile("Project Rain/hopper blacklisted servers.json") and game:GetService("HttpService"):JSONDecode(readfile("Project Rain/hopper blacklisted servers.json")) or {};
                
                for id, server in blacklisted_servers do
                    if server.expiry < tick() then
                        blacklisted_servers[id] = nil;
                    end;
                end;

                local function blacklist(server, expiry)
                    blacklisted_servers[server] = {
                        expiry = tick() + (expiry or 900)
                    }
                
                    writefile("Project Rain/hopper blacklisted servers.json", game:GetService("HttpService"):JSONEncode(blacklisted_servers));
                end;

                blacklist(game.JobId, expiry or (10 * 60))
            end, warn);

            writefile("hopper.lua", hop_script);
            queue_on_teleport(hop_script);
            kick_window("Serverhopping...");
        end;
    end,
    rejoin = function(self, slot)
        self:custom(slot, game.JobId);
    end,
    custom = function(_, slot, id)
        local rejoin_script = string.format([[
        if not game:IsLoaded() then
            game.Loaded:Wait();
        end;
        if game.PlaceId ~= 4111023553 then return; end
        local server = '%s';
        local slot = "%s";

        queueonteleport('if game.PlaceId == 4111023553 then return; end; xpcall(function() local sound = Instance.new("Sound", game:GetService("CoreGui")); game:GetService("Debris"):AddItem(sound, 6); sound.Volume = 1.3; sound.SoundId = getcustomasset("Project Rain/assets/notification.mp3"); sound:Play(); end, warn);')

        while task.wait() do
            game:GetService("ReplicatedStorage").Requests:WaitForChild("StartMenu"):WaitForChild("PickSlot"):FireServer(slot, {
                PrivateTest = false
            });
            task.wait(0.3);
            game:GetService("ReplicatedStorage").Requests.StartMenu:WaitForChild("PickServer"):FireServer(server);
        end;
        ]], id, slot or "A");
        if game.PlaceId ~= 4111023553 then  
            queue_on_teleport(rejoin_script); 
            
            kick_window("rejoining...")
            return        
else
            print("cant be called here");
        end;
    end,
    obliteration = function(_, slot, small, sound)
        local obl_script = string.format(hop_script, slot or "A", small ~= nil and tostring(small) or 'false', tostring(sound), 'true')
        if game.PlaceId ~= 4111023553 then 
            queue_on_teleport(obl_script);
            kick_window("wiping...");
            return        
else
            print("cant be called here");
        end;
    end,
    quick_hop = function(self)
        self:hop(local_player.instance:GetAttribute("DataSlot") or "A", 'false', 'false')
    end;
}