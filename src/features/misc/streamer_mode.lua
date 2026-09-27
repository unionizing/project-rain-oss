
local server_region;
local server_name;
local server_age;

local feat = Feature:new("streamer_mode", services.RunService.Stepped, function() 
    local_player.instance:SetAttribute("Hidden", true);
end);

function feat:get_name(str)
	local hash = 0

	for i = 1, #str do
		hash = bit32.band(hash * 31 + string.byte(str, i), 0xFFFFFFFF)
	end

	if hash >= 0x80000000 then
		hash -= 0x100000000
	end

	return string.format("%08x", hash)
end

function feat:enable()
    server_region = game:GetService("ReplicatedStorage"):WaitForChild("SERVER_REGION");
    server_name = game:GetService("ReplicatedStorage"):WaitForChild("SERVER_NAME");
    server_age = game:GetService("ReplicatedStorage"):WaitForChild("SERVER_AGE");

    for _, object in local_player.instance:GetDescendants() do
        if object.Name == "Slot" and object.Parent.Name == "CharacterInfo" then
            object.Text = object.Text:gsub(local_player.instance.UserId, "0");
        elseif object.Name == "Character" and object.Parent.Name == "CharacterInfo" then
            object.Text = "";
        end 
    end;

    if not server_region.Value:find("USA") then
        server_region.Value = server_region.Value:split(", ")[#server_region.Value:split(", ")]
    end
    server_name.Value = game.JobId:sub(1,8)
    server_age.Value = "0d 0h 0m";

    self.server_age_connection = server_age.Changed:Connect(function()
        if server_age.Value == "0d 0h 0m" then return end
        server_age.Value = "0d 0h 0m";
    end);
end;

function feat:disable()
    if self.server_age_connection then
        self.server_age_connection:Disconnect();
        self.server_age_connection = nil;
    end
end;

return feat