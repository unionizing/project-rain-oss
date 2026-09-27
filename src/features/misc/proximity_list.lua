if is_chime then return end



local Converted = {
	["_ScreenGui"] = Instance.new("ScreenGui");
	["_Frame"] = Instance.new("Frame");
	["_TextLabel"] = Instance.new("TextLabel");
	["_UIStroke"] = Instance.new("UIStroke");
	["_Frame1"] = Instance.new("Frame");
	["_TextLabel1"] = Instance.new("TextLabel");
	["_UIStroke1"] = Instance.new("UIStroke");
}

local getasset = getcustomasset;
local sound = {} do
    function sound.new(filePath, speed, volume, isLink, link)
        local self = setmetatable(sound, {});
        
        self.soundAsset = getasset(filePath);
        self.speed = speed;
        self.volume = volume;
        self.sound = Instance.new("Sound", services.CoreGui)
        return self    
end;
    function sound:play()
        self.sound.SoundId = self.soundAsset
        self.sound.PlaybackSpeed = self.speed
        self.sound.Volume = 0;
        game:GetService("TweenService"):Create(self.sound, TweenInfo.new(0.1), {
            Volume = self.volume
        }):Play();
        self.sound:Play();
        game:GetService("Debris"):AddItem(self.sound, 1.5);
    end;
end;

function exit_sound()
    if not aztup.flags.notify_with_sound then return end
    
    sound.new("Project Rain/Assets/proximity.mp3", 0.9, aztup.flags.player_proximity_vol, true):play();
end;

function enter_sound()
    if not aztup.flags.notify_with_sound then return end

    sound.new("Project Rain/Assets/proximity.mp3", 1.1, aztup.flags.player_proximity_vol, true):play();
end;



Converted["_ScreenGui"].Parent = game:GetService("CoreGui")
Converted["_ScreenGui"].DisplayOrder = -1000
Converted["_ScreenGui"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Converted["_ScreenGui"].OnTopOfCoreBlur = true;

Converted["_Frame"].ZIndex = 0;
Converted["_Frame"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Frame"].BackgroundColor3 = Library.MainColor
Converted["_Frame"].BorderSizePixel = 2;
Converted["_Frame"].Position = UDim2.new(0.5, 0, 0.15, 0)
Converted["_Frame"].Size = UDim2.new(0, 150, 0, 42)
Converted["_Frame"].Parent = Converted["_ScreenGui"] 
Converted["_Frame"].ClipsDescendants = true;
Library:AddUIScale(Converted["_Frame"]);

local stroke = Instance.new("UIStroke", Converted["_Frame"]);
stroke.Thickness = 1;
stroke.ZIndex = 999;
stroke.Name = "THIS";
stroke.Color = Library.AccentColor; 
stroke.LineJoinMode = Enum.LineJoinMode.Miter;
task.spawn(function()
    repeat task.wait() until lexend.regular;
Converted["_TextLabel"].FontFace = lexend.regular
end);
Converted["_TextLabel"].ZIndex = 1
stroke.ZIndex = Converted["_TextLabel"].ZIndex + 1;
Converted["_TextLabel"].Text = "proximity"
Converted["_TextLabel"].TextColor3 = Library.FontColor
Converted["_TextLabel"].TextSize = 16
Converted["_TextLabel"].TextWrapped = true
Converted["_TextLabel"].BorderSizePixel = 1;
 
Converted["_TextLabel"].BackgroundColor3 = Library.BackgroundColor
Converted["_TextLabel"].BorderColor3 = Library.OutlineColor
Converted["_TextLabel"].Size = UDim2.new(1, 0, 0, 22)
Converted["_TextLabel"].Parent = Converted["_Frame"]

Converted["_UIStroke"].Color = Color3.fromRGB(0, 0, 0)
Converted["_UIStroke"].Parent = Converted["_TextLabel"]


Converted["_Frame1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Frame1"].BackgroundTransparency = 1
Converted["_Frame1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame1"].BorderSizePixel = 0
Converted["_Frame1"].Position = UDim2.new(0, 0, 0, 22)
Converted["_Frame1"].Size = UDim2.new(1, 0, 1, -22)
Converted["_Frame1"].Parent = Converted["_Frame"]

Converted["_TextLabel1"].FontFace = lexend.regular
Converted["_TextLabel1"].Text = "Ace Yuset - 30m"
Converted["_TextLabel1"].TextColor3 = Library.FontColor
Converted["_TextLabel1"].TextSize = 14
Converted["_TextLabel1"].BackgroundTransparency = 1
Converted["_TextLabel1"].BorderSizePixel = 0
Converted["_TextLabel1"].Size = UDim2.new(1, 0, 0, 20)
Converted["_TextLabel1"].Visible = false;

Converted["_UIStroke1"].Color = Color3.fromRGB(0, 0, 0)
Converted["_UIStroke1"].Parent = Converted["_TextLabel1"]

local character_holder = Converted["_Frame1"];
local sample_label = Converted["_TextLabel1"]:Clone();
local labelMap = {}
local ui_list_layout = Instance.new("UIListLayout", character_holder);
ui_list_layout.FillDirection = Enum.FillDirection.Vertical;
ui_list_layout.SortOrder = Enum.SortOrder.LayoutOrder;

for _, item in Converted do
    if not item:IsA("Frame") and not item:IsA("TextLabel") then continue end
    
    item.InputChanged:Connect(function(input, t)
        if t or input.UserInputType ~= Enum.UserInputType.MouseWheel then return end

        local direction = input.Position.Z > 0 and 1 or -1
        
        for _, item in Converted do
            if not item:IsA("Frame") and not item:IsA("TextLabel") and not item:IsA("UIStroke") then continue end

            if item:IsA("UIStroke") then
                item.Transparency = math.clamp(item.Transparency - (direction * 0.1), 0, 0.9)
                continue            
end

            if item.BackgroundTransparency <= 0.7 then
                item.BackgroundTransparency = math.clamp(item.BackgroundTransparency - (direction * 0.1), 0, 0.7)
            end;
            
            if item.BackgroundTransparency <= 0.7 then
                item.BackgroundTransparency = math.clamp(item.BackgroundTransparency - (direction * 0.1), 0, 0.7)
            end;
            
            if item:IsA("TextLabel") then
                item.TextTransparency = math.clamp(item.TextTransparency - (direction * 0.1), 0, 0.7)
            end
        end; 

        if stroke.Transparency <= 0.7 then
            stroke.Transparency = math.clamp(stroke.Transparency - (direction * 0.1), 0, 0.7)
        end
    end)
end

function clear_objects()
    for _, object in pairs(character_holder:GetChildren()) do
        if object ~= ui_list_layout then
            object:Destroy();
        end;
    end;
end;

function get_in_range()
    local in_range = {};
    for _, player in pairs(services.Players:GetPlayers()) do
        if player == local_player.instance then continue end

        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local distance = (local_player.root_part.Position - player.Character.HumanoidRootPart.Position).Magnitude;
            if distance <= aztup.flags.player_proximity_range then
                table.insert(in_range, {player = player, distance = distance});
            end;
        end;
    end;

    return in_range
end;

function update_size()
    
    local size = Vector2.new(130, 22);
    for _, label in character_holder:GetChildren() do
        if label:IsA("UIListLayout") then continue end
        if not label.Visible then
            label:Destroy();
            continue        
end;
        local text_size = label.TextBounds / Library:GetUIScale()

        if size.X < text_size.X then
            size = Vector2.new(text_size.X, size.Y)
        end

        size += Vector2.new(0, 20)
    end;

    if size.Y <= 23 then
        Converted._ScreenGui.Enabled = false;
    end;

    Converted._Frame.Size = UDim2.new(0, size.X + 20, 0, size.Y);
    
end;

local function format_distance(distance)
	return aztup_options.distance_naming.Value == "studs" and ("%is"):format(distance) or (distance > 1000 and ("%.1fkm"):format(distance / 1000) or ("%im"):format(distance))
end;

function add_object(name, distance, voidwalker, char)
    local new_label: TextLabel = sample_label:Clone();
    new_label.Text = name .. " (" .. format_distance(distance) .. ")";
    new_label.TextTransparency = 0;
    new_label.TextColor3 = voidwalker and Library.AccentColor or Library.FontColor;
    new_label.Visible = true;
    new_label.Parent = character_holder;
    update_size();

    local clicked = new_label.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        aztup.features.leaderboard_spectate:force_spectate(char)
    end)

    new_label:GetPropertyChangedSignal("Parent"):Once(function() 
        clicked:Disconnect();
    end);
    
    return new_label
end;

Library:AddToRegistry(Converted["_Frame"], {
    BackgroundColor3 = "MainColor"
})

Library:AddToRegistry(stroke, {
    Color = "AccentColor"
}, true)

Library:AddToRegistry(Converted["_TextLabel"], {
    BackgroundColor3 = "BackgroundColor",
    TextColor3 = "FontColor",
})

Library:AddToRegistry(sample_label, {
    TextColor3 = "FontColor"
})    

Library:MakeDraggableScale(Converted["_Frame"], 22, true); 
aztup.proximity = Converted["_Frame"];
aztup.maid:give_task(Converted["_ScreenGui"]);
Converted["_ScreenGui"].Enabled = false;

clear_objects();



local function sync_labels(currently_in_range)
    
    table.sort(currently_in_range, function(a, b)
        
        
        return a.distance < b.distance    
end)

    local seen = {}
    local updated = false
    local order = 0

    for _, data in ipairs(currently_in_range) do
        local plr = data.player
        local key = plr.UserId
        seen[key] = true

        local label = labelMap[key]
        local txt = (plr:GetAttribute("CharacterName") or plr.Name) .. " (" .. format_distance(data.distance) .. ")"

        if not label or not label.Parent then
            enter_sound()

            local is_voidwalker = plr:FindFirstChild("Backpack") and (plr.Backpack:FindFirstChild("Talent:Voideye") or plr.Backpack:FindFirstChild("Talent:Grasp of Eylis"));
            if aztup.flags.notify_in_range then
                Logger:notify((plr:GetAttribute("CharacterName") or "") .. " [" .. plr.Name .. "]" .. " has entered your proximity range" .. (is_voidwalker and not is_depths and ", User is a voidwalker." or "."));
            end;

            label = add_object(plr:GetAttribute("CharacterName") or plr.Name, data.distance, is_voidwalker and not is_depths, plr)
            labelMap[key] = label
            updated = true
        else
            if label.Text ~= txt then
                label.Text = txt
                updated = true
            end
        end

        
        label.LayoutOrder = order
        order += 1
    end

    for key, label in pairs(labelMap) do
        if not seen[key] then
            
            if aztup.flags.notify_in_range then 
                
                local plr = services.Players:GetPlayerByUserId(key)
                if not plr then 
                    Logger:notify("A logged out player has left your proximity range."); 
                else
                    Logger:notify((plr:GetAttribute("CharacterName") or "") .. " [" .. plr.Name .. "]" .. " has left your proximity range.");
                end;
                
                
            end;

            exit_sound();
            label:Destroy()
            labelMap[key] = nil
            updated = true
        end
    end

    if updated then
        update_size()
    end
end

local feature = Feature:new("proximity_list", scheduler:add_task(0.15), function()
    if not local_player.character or not local_player.root_part then return end
    local frame = Converted["_Frame"];
    local y_scale = frame.Position.Y.Scale;
    
    local y_offset = frame.AbsoluteSize.Y / 2;

    if y_scale >= 0.5 then
        y_offset = -y_offset;
    end
    Converted["_Frame"].Position = UDim2.new(frame.Position.X.Scale, 0, y_scale, y_offset)

    if Library.Toggled or Converted._Frame.Size.Y.Offset >= 23 then
        Converted._ScreenGui.Enabled = aztup.flags.show_list;
    elseif Converted._Frame.Size.Y.Offset <= 23 then
        Converted._ScreenGui.Enabled = false;
    end

    local currently_in_range = get_in_range()
    sync_labels(currently_in_range)
end);


function feature:enable()
    table.clear(labelMap);
    clear_objects();
    update_size();

    Converted["_ScreenGui"].Enabled = true;
end;

function feature:disable()
    Converted["_ScreenGui"].Enabled = false;
end;

function feature:set_transparency(trans)
    for _, item in Converted do
        if not item:IsA("Frame") and not item:IsA("TextLabel") and not item:IsA("UIStroke") then continue end

        if item:IsA("UIStroke") then
            item.Transparency = math.clamp(trans, 0, 0.9)
            continue        
end

        if item.BackgroundTransparency <= 0.7 then
            item.BackgroundTransparency = math.clamp(trans, 0, 0.7)
        end;
        
        if item.BackgroundTransparency <= 0.7 then
            item.BackgroundTransparency = math.clamp(trans, 0, 0.7)
        end;
        
        if item:IsA("TextLabel") then
            item.TextTransparency = math.clamp(trans, 0, 0.7)
        end
    end; 

    if stroke.Transparency <= 0.7 then
        stroke.Transparency = math.clamp(trans, 0, 0.7)
    end
end

return feature