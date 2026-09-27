return LPH_NO_VIRTUALIZE(function()
    local PlayerESPBillboard = require("@src/utility/player_esp_inst");
    local maid = require("@src/utility/maid");
    local stored_damage_registry = require("@src/utility/stored_damage_registry");
    local PlayerESPRegistry = {};
    local red = Color3.fromRGB(255, 112, 112);
    local green = Color3.fromRGB(187, 255, 181);
    local mouse_pos = services.UserInputService:GetMouseLocation();
    local camera;
    local function profile_begin(message)
        if aztup and aztup.silent_mode then
            return        
end;

        debug.profilebegin(message);
    end;

    local function profile_end()
        if aztup and aztup.silent_mode then
            return        
end;

        debug.profileend();
    end;

    local health_tween_info = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
    local top_tags_sorted = {
        "Roblox Display Name",
    	"Roblox Player Name",
        "Character Name",
        "Danger Time",
        "Health %",
        "HP/Max",
    };
    local bottom_tags_sorted = {
        "Level",
        "Agility",
        "Ping",
    };
    local bar_names = {
        "posture",
        "sanity",
        "hunger",
        "water",
        "blood",
        "armor",
    };
    
    
    
    local bottom_bar_names = {
        "sanity",
        "hunger",
        "water",
        "blood",
    };
    
    
    
    
    
    
    local bottom_tag_billboard_height = 18;

    local PlayerESPTagBillboard = Instance.new("BillboardGui") do
        PlayerESPTagBillboard.LightInfluence = 0;
        PlayerESPTagBillboard.StudsOffset = Vector3.new(0,2.5,0);
        PlayerESPTagBillboard.Active = true;
        PlayerESPTagBillboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        PlayerESPTagBillboard.ClipsDescendants = true;
        PlayerESPTagBillboard.AlwaysOnTop = true;
        PlayerESPTagBillboard.Size = UDim2.new(0,400,0,200);
    end
    
    local PlayerESPLabel = Instance.new("TextLabel", PlayerESPTagBillboard) do
        PlayerESPLabel.Font = Enum.Font.SourceSans;
        PlayerESPLabel.Size = UDim2.new(1,0,0.5,0);
        PlayerESPLabel.TextColor3 = Color3.new(0,0,0);
        PlayerESPLabel.BackgroundTransparency = 1;
        PlayerESPLabel.BackgroundColor3 = Color3.new(1,1,1);
        PlayerESPLabel.Text = '';
        PlayerESPLabel.AutoLocalize = false;
        PlayerESPLabel.RichText = false;
        PlayerESPLabel.TextYAlignment = Enum.TextYAlignment.Bottom;
        
        PlayerESPLabel.TextSize = 18;
        PlayerESPLabel.TextTransparency = 0.2;
        PlayerESPLabel.ZIndex = 3;
    
        local stroke = Instance.new("UIStroke", PlayerESPLabel);
        stroke.Thickness = 1;
        stroke.Transparency = 0.5;
        stroke.Color = Color3.new(0,0,0);
        stroke.Name = "stroke";
    end;

    
    
    
    
    
    local PlayerESPBottomTagBillboard = PlayerESPTagBillboard:Clone() do
        PlayerESPBottomTagBillboard.StudsOffset = Vector3.new(0, 0, 0);
        PlayerESPBottomTagBillboard.Size = UDim2.new(8.5, 0, bottom_tag_billboard_height, 0);
        PlayerESPBottomTagBillboard.ClipsDescendants = false;

        local label = PlayerESPBottomTagBillboard.TextLabel;
        label.AnchorPoint = Vector2.new(0.5, 0);
        label.Size = UDim2.new(1, 0, 0.15, 0);
        label.Position = UDim2.new(0.5, 0, 0.5 + (0.9 / bottom_tag_billboard_height), 0);
        label.TextYAlignment = Enum.TextYAlignment.Top;
    end;

    local PlayerESP = {} do
       PlayerESP.__index = PlayerESP;
    
       local player_container = services.CoreGui:FindFirstChild("PR_PLAYER_CONTAINER");
        if player_container then
            player_container:Destroy();
        end;
    
        local pr_player_container = Instance.new("Folder", game:GetService("CoreGui"));
        pr_player_container.Name = "PR_PLAYER_CONTAINER";

        local character_map = {};
    
        function PlayerESP.new(character, player)
            if character_map[character] then
                return            
end;

            if not player then
                return            
end;

            local self = setmetatable({}, PlayerESP);
            self.entity = character;
            self.player = player;
            self.last_update = 0;
            self.maid = maid.new();
            self.health_tween = nil;
            self.maid:give_task(function()
                local tween_fields = {
                    "health_tween",
                    "HUN_tween",
                    "SAN_tween",
                    "BLD_tween",
                    "WTR_tween",
                    "ARM_tween",
                    "POS_tween",
                };

                for _, tween_field in ipairs(tween_fields) do
                    local tween = self[tween_field];
                    if tween then
                        pcall(function()
                            tween:Cancel();
                            tween:Destroy();
                        end);
                        self[tween_field] = nil;
                    end;
                end;
            end);
            character_map[character] = true;

            self.nametag_billboard = PlayerESPTagBillboard:Clone();
            self.bottom_tag_billboard = PlayerESPBottomTagBillboard:Clone();
            self.billboard = PlayerESPBillboard:Clone();
    
            self.healthbar = self.billboard.Health;
            self.dividers = self.healthbar.Dividers;
            self.stored_damage_bar = self.healthbar:FindFirstChild("StoredDamage");
            self.box = self.billboard.Box;
            self.armor = self.billboard.Armor;
    
            self.blood = self.billboard.BottomBars.Blood;
            self.hunger = self.billboard.BottomBars.Hunger;
            self.sanity = self.billboard.BottomBars.Sanity;
            self.water = self.billboard.BottomBars.Water;
            self.posture = self.billboard.Posture;
    
            self.nametag = self.nametag_billboard.TextLabel;
            self.stroke = self.nametag:FindFirstChildWhichIsA("UIStroke");

            self.bottom_tag = self.bottom_tag_billboard.TextLabel;
            self.bottom_stroke = self.bottom_tag:FindFirstChildWhichIsA("UIStroke");

            self.last_text = nil;
            self.last_color = nil;
            self.last_font = nil;
            self.last_text_size = nil;
            self.last_text_color = nil;
            self.last_transparency = nil;

            self.last_bottom_text = nil;
            self.last_bottom_offset = nil;

            
            
            
            
            
            
            
            self.box_stroke = self.box.UIStroke;
            self.strokes = {
                
                
                
                
                
                
                
                self.box_stroke,
            };

            PlayerESPRegistry[self.player] = self;
            self:connect();
            return self        
end
    
        function PlayerESP:destroy()
            if self.destroyed then
                return            
end;

            self.destroyed = true;
            stored_damage_registry[self.entity] = nil;
            profile_begin("PlayerESP::destroy");
            if self.maid then
                self.maid:do_cleaning();
            end;
            if self.health_tween then
                pcall(function()
                    self.health_tween:Cancel();
                end);
                self.health_tween = nil;
            end;
            self.billboard:Destroy();
            for index, object in self do
                pcall(function()
                    object:Disconnect();
                end);
    
                if typeof(object) == "Instance" and index ~= "player" and index ~= "entity" and index ~= "root" and index ~= "humanoid" then
                    object:Destroy();
                end;
            end;
            profile_end();
    
            PlayerESPRegistry[self.player] = nil;
            character_map[self.entity] = nil;
        end;
    
        function PlayerESP:get_nametag()
            local text_parts = {};
            local tag_count = 0
            local current_camera = camera or workspace.CurrentCamera;

            local tag_value = aztup_options.ESP_TAGS.Value;

            if aztup_options.ESP_TAGS.Value["Distance"] then
                if not current_camera then
                    return table.concat(text_parts)                
end;

                if #text_parts == 0 or text_parts[#text_parts] ~= "\n" then
                    text_parts[#text_parts + 1] = "\n"
                end
        
                local magnitude = (self.root.Position - current_camera.CFrame.Position).Magnitude
                
                text_parts[#text_parts + 1] = string.format(
                    "[%s] ",
                    aztup_options.distance_naming.Value == "studs" and ("%is"):format(magnitude) or (magnitude > 1000 and ("%.1fkm"):format(magnitude / 1000) or ("%im"):format(magnitude))
                )
            end        

            for _, tag in ipairs(top_tags_sorted) do 
                if not tag_value[tag] then
                    continue
                end
        
                local appended = false
        
                if tag == "Roblox Player Name" then
                    text_parts[#text_parts + 1] = string.format("%s%s", self.player.Name, aztup.flags.new_line_after_name and " \n" or " ")    
                elseif tag == "Roblox Display Name" then
                    text_parts[#text_parts + 1] = string.format("%s%s", self.player.DisplayName, aztup.flags.new_line_after_name and " \n" or " ")    
                elseif tag == "Character Name" then
                    text_parts[#text_parts + 1] = string.format(
                        "%s ",
                        self.player:GetAttribute("CharacterName") or "Unknown"
                    )    
                















elseif tag == "Health %" then
                    text_parts[#text_parts + 1] = string.format(
                        "(%d%%) ",
                        math.floor((self.humanoid.Health / math.max(self.humanoid.MaxHealth, 1)) * 100)
                    )
                    appended = true
    
                elseif tag == "HP/Max" then
                    text_parts[#text_parts + 1] = string.format(
                        "(%d/%dhp) ",
                        self.humanoid.Health,
                        math.max(self.humanoid.MaxHealth, 1)
                    )
                    appended = true
        
                
                






elseif tag == "Danger Time"
                    and self.humanoid:GetAttribute("DangerExpiration")
                    and self.humanoid:GetAttribute("DangerExpiration") > 0
                    and self.humanoid:GetAttribute("DangerExpiration") - workspace:GetServerTimeNow() > 0
                then
                    text_parts[#text_parts + 1] = string.format(
                        "(%ds tag) ",
                        self.humanoid:GetAttribute("DangerExpiration") - workspace:GetServerTimeNow()
                    )
                    appended = true
                end
        
                if appended then
                    tag_count += 1
        
                    
                    
                    
                end
            end
        
            return table.concat(text_parts)
        end
        
        function PlayerESP:get_tags()
            local text_parts = {};
            local tag_count = 0

            local tag_value = aztup_options.ESP_TAGS.Value;

            for _, tag in ipairs(bottom_tags_sorted) do 
                if not tag_value[tag] then
                    continue
                end
        
                local appended = false
        
                if tag == "Level" then

                    if not self.level then
                        local AttributePoints = 0
                        local Power = 0 
                        for i, v in pairs(self.entity:GetAttributes()) do
                            if i:match("Stat") then
                                AttributePoints = AttributePoints + v
                            end
                        end
                        for i = 1, 20 do
                            if AttributePoints <= 15 then
                                break                            
end
                            AttributePoints = AttributePoints - 15
                            Power = Power + 1
                        end
                    
                        self.level = math.min(20, math.max(1, Power));
                    end;

                    text_parts[#text_parts + 1] = string.format(
                        "[Power %d] ",
                        self.level
                    )
                    appended = true
                elseif tag == "Agility" then
                    local passive_agility = self.entity:FindFirstChild("PassiveAgility");
                    if passive_agility and passive_agility.Value > 0 then
                        text_parts[#text_parts + 1] = string.format(
                            "[%i agil] ",
                            passive_agility.Value
                        )
                        appended = true;
                    end

                elseif tag == "Ping" and self.entity:GetAttribute("AveragePing") then
                    local ping = tonumber(self.entity:GetAttribute("AveragePing")) or 0;
                    local format = ping > 1000 and "s" or "ms";

                    if ping > 1000 then
                        ping /= 1000;
                    end;

                    text_parts[#text_parts + 1] = string.format(
                        "[%d%s] ",
                        ping, format
                    )
                    appended = true
                end;
        
                if appended then
                    tag_count += 1
        
                    
                    
                    
                end
            end
        
            return table.concat(text_parts)
        end

        function PlayerESP:get_font()
			local fv = aztup_options.Font.Value;
			local custom_font = ({
				["Lexend"] = lexend.regular,
				["Lexend Bold"] = lexend.bold,
				["Lexend Medium"] = lexend.medium,
			})[fv]
            if custom_font then
                return custom_font, true            
end;

			return Enum.Font[fv] or Enum.Font.SourceSans
        end;
    
        function PlayerESP:update()
            self.last_update = tick();
    
            local entity = self.entity;
            local humanoid = self.humanoid;
            if not humanoid or humanoid.Health <= 0 or not entity.Parent then
                return self:destroy()            
end;

            if entity.Parent.Name ~= "Live" or not self.root then
                self.nametag_billboard.Enabled = false;
                self.bottom_tag_billboard.Enabled = false;
                self.billboard.Enabled = false;
                return            
end;

            local current_camera = camera or workspace.CurrentCamera;
            if not current_camera then
                self.nametag_billboard.Enabled = false;
                self.bottom_tag_billboard.Enabled = false;
                self.billboard.Enabled = false;
                return            
end;

            local distance = (current_camera.CFrame.Position - self.root.Position).Magnitude;
            local visible = distance < aztup.flags.max_player_distance;

            if visible and aztup.flags.esp_fadeout and distance > (aztup.flags.player_fadeout_distance * 2) then
                visible = false;
            end;

            local name_visible = aztup.flags.esp_nametags;
            local bar_value = aztup_options.ESP_BARS.Value;
            local dist_under_500 = distance < 500;

            self.nametag_billboard.Enabled = name_visible and visible;
            self.bottom_tag_billboard.Enabled = name_visible and visible;
            self.billboard.Enabled = visible and dist_under_500;
            self.box.Visible = dist_under_500 and aztup.flags.esp_boxes;
            self.healthbar.Visible = dist_under_500 and aztup.flags.esp_healthbar;
            
            if not visible then
                return            
end;

            if dist_under_500 and aztup.flags.esp_healthbar then
                local dividers = self.dividers;
                local health = 1 - (humanoid.Health / humanoid.MaxHealth);

                for _, divider in dividers:GetChildren() do
                    divider.BackgroundColor3 = health <= tonumber(divider.Name) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(127, 127, 127)
                end;

                if self.stored_damage_bar then
                    local stored_damage = aztup.flags.show_stored_damage and stored_damage_registry[self.entity];
                    local health_ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1);
                    local stored_ratio = stored_damage and math.clamp(stored_damage / math.max(humanoid.MaxHealth, 1), 0, health_ratio) or 0;

                    self.stored_damage_bar.Visible = stored_ratio > 0;
                    if stored_ratio > 0 then
                        self.stored_damage_bar.Position = UDim2.new(0, 0, health_ratio - stored_ratio, 0);
                        self.stored_damage_bar.Size = UDim2.new(1, 0, stored_ratio, 0);
                        self.stored_damage_bar.BackgroundColor3 = aztup_options.show_stored_damage_color.Value;
                    end;
                end;
            elseif self.stored_damage_bar then
                self.stored_damage_bar.Visible = false;
            end;

            local bottom_bar_count = 0;
            for _, value in ipairs(bar_names) do
                self[value].Visible = bar_value[value] and dist_under_500;
            end
            for _, value in ipairs(bottom_bar_names) do
                if bar_value[value] and dist_under_500 then
                    bottom_bar_count += 1;
                end;
            end

            
            
            
            
            
            
            
            
            local bottom_offset_studs = 0.9;
            if bottom_bar_count > 0 and dist_under_500 then
                bottom_offset_studs = 3.2 + (4.6 - 3.2) * (bottom_bar_count / #bottom_bar_names);
            elseif dist_under_500 then
                bottom_offset_studs = 3.2;
            end;
            
            local bottom_position = UDim2.new(0.5, 0, 0.5 + (bottom_offset_studs / bottom_tag_billboard_height), 0);
            if self.last_bottom_offset ~= bottom_position then
                self.bottom_tag.Position = bottom_position;
                self.last_bottom_offset = bottom_position;
            end;

            local nametag, stroke = self.nametag, self.stroke;
            local current_transparency = 0.2;

            nametag.Visible = name_visible;

            if aztup.flags.esp_fadeout then
                if distance > aztup.flags.player_fadeout_distance then
                    
                    local baseFade = math.min(
                        1,
                        (distance - aztup.flags.player_fadeout_distance) / aztup.flags.player_fadeout_distance
                    ) * 0.8

                    local screenPos, onScreen;
                    if aztup.flags.esp_fadeout_hover then
                        screenPos, onScreen = current_camera:WorldToViewportPoint(self.root.Position)
                        if onScreen then
                            local dx = screenPos.X - mouse_pos.X
                            local dy = screenPos.Y - mouse_pos.Y

                            local mouseDistSq = dx * dx + dy * dy
                            local farFactor = math.min(1, mouseDistSq / (100 * 100))

                            local totalFade = baseFade * farFactor

                            current_transparency = math.clamp(0.2 + totalFade, 0.2, 1)
                        end;
                    end;

                    if not onScreen then
                        current_transparency = math.clamp(0.2 + baseFade, 0.2, 1)
                    end;
                end
            end

            local bottom_tag, bottom_stroke = self.bottom_tag, self.bottom_stroke;

            if self.last_transparency ~= current_transparency then
                nametag.TextTransparency = current_transparency;
                stroke.Transparency = current_transparency;
                bottom_tag.TextTransparency = current_transparency;
                bottom_stroke.Transparency = current_transparency;
                self.last_transparency = current_transparency;
            end;

            local color = self:get_color();
            if self.last_color ~= color then
                for _, object in ipairs(self.strokes) do
                    object.Color = color;
                end;
                self.last_color = color;
            end;


            if name_visible then
                local text = self:get_nametag();
                local bottom_text = self:get_tags();

                if dist_under_500 then
                    
                    
                    if self.last_text ~= text then
                        nametag.Text = text;
                        self.last_text = text;
                    end;

                    if self.last_bottom_text ~= bottom_text then
                        bottom_tag.Text = bottom_text;
                        self.last_bottom_text = bottom_text;
                    end;
                    self.bottom_tag_billboard.Enabled = bottom_text ~= "";
                else
                    
                    
                    
                    
                    local merged_text = bottom_text ~= "" and (text .. "\n" .. bottom_text) or text;
                    if self.last_text ~= merged_text then
                        nametag.Text = merged_text;
                        self.last_text = merged_text;
                    end;

                    self.bottom_tag_billboard.Enabled = false;
                    self.last_bottom_text = nil;
                end;
            end;

            if self.last_text_color ~= color then
                nametag.TextColor3 = color;
                bottom_tag.TextColor3 = color;
                self.last_text_color = color;
            end;

            if self.last_text_size ~= aztup.flags.text_size then
                nametag.TextSize = aztup.flags.text_size;
                bottom_tag.TextSize = aztup.flags.text_size;
                self.last_text_size = aztup.flags.text_size;
            end;


            local font, fontface = self:get_font();
            if self.last_font ~= font then
                if fontface then
                    nametag.FontFace = font;
                    bottom_tag.FontFace = font;
                else
                    nametag.Font = font;
                    bottom_tag.Font = font;
                end;

                self.last_font = font;
            end;

            return        
end;
    
        function PlayerESP:setup_bar(value, bar, title)
            if not value or not bar or not bar:FindFirstChild("FillBar") or not value.MaxValue or value.MaxValue <= 0 then
                if bar then
                    bar.Visible = false;
                end;
                return nil            
end;

            local function set_bar_size()
                if self.destroyed or not bar:FindFirstChild("FillBar") then
                    return                
end;

                local ratio = math.clamp(value.Value / math.max(value.MaxValue, 1), 0, 1);
 
                if title == "POS" or title == "ARM" then
                    bar.FillBar.Size = UDim2.new(1, 0, ratio, 0);
                else
                    bar.FillBar.Size = UDim2.new(ratio, 0, 1, 0);
                end
            end;

            set_bar_size();
            return self.maid:give_task(value:GetPropertyChangedSignal("Value"):Connect(set_bar_size))        
end;
    
        function PlayerESP:get_color()
            if aztup.flags.gm_color and self.guild_mate then
                return aztup_options.guildmate_esp_color.Value            
end;
    
            if aztup.flags.vw_color and self.voidwalker and not is_depths then
                return aztup_options.voidwalker_esp_color.Value            
end;
                
            return aztup_options.player_esp_color.Value        
end;
    
        function PlayerESP:connect()
            self.humanoid = self.entity:WaitForChild("Humanoid", 1000);
            self.root = self.entity:WaitForChild("HumanoidRootPart", 9e9);
    
            self.billboard.Adornee = self.root;
            self.billboard.Parent = pr_player_container;
            
            self.nametag_billboard.Adornee = self.root;
            self.nametag_billboard.Parent = pr_player_container;

            self.bottom_tag_billboard.Adornee = self.root;
            self.bottom_tag_billboard.Parent = pr_player_container;

            self.maid:give_task(self.humanoid.HealthChanged:Connect(function()
                if not self.healthbar:FindFirstChild("FillBar") then return end;
                local ratio = math.clamp(self.humanoid.Health / math.max(self.humanoid.MaxHealth, 1), 0, 1);
                if self.health_tween then
                    pcall(function()
                        self.health_tween:Cancel();
                        self.health_tween:Destroy();
                    end);
                end;
                self.healthbar.FillBar.BackgroundColor3 = red:Lerp(green, ratio);
                self.health_tween = services.TweenService:Create(self.healthbar.FillBar, health_tween_info, {
                    Size = UDim2.new(1, 0, ratio, 0)
                });
                self.health_tween:Play();
            end));
    
    
            if not self.entity:IsDescendantOf(workspace) then
                return self:destroy()            
end;

            self.maid:give_task(self.entity.AncestryChanged:Connect(function()
                if not self.entity:IsDescendantOf(workspace) then
                    self:destroy();
                end;
            end));

            task.spawn(function()
                local sanity = self.entity:WaitForChild("Sanity", 20);
                local stomach = self.entity:WaitForChild("Stomach", 5);
                local water = self.entity:WaitForChild("Water", 5);
                local blood = self.entity:WaitForChild("Blood", 5);
                local posture = self.entity:WaitForChild("BreakMeter", 5);
                local armor = self.entity:WaitForChild("Armor", 5);
                
                self.stomach_changed = self:setup_bar(stomach, self.hunger, "HUN")
                self.sanity_changed = self:setup_bar(sanity, self.sanity, "SAN")
                self.blood_changed = self:setup_bar(blood, self.blood, "BLD")
                self.water_changed = self:setup_bar(water, self.water, "WTR")
                
                self.armor_changed = self:setup_bar(armor, self.armor, "ARM")
                
                self.posture_changed = self:setup_bar(posture, self.posture, "POS")

            end);
    
            return task.spawn(function()
                if self.destroyed then
                    return                
end;
                self.guild_mate = general:is_teammate(self.player);
                if self.player and self.player.Backpack then
                    self.voidwalker = self.player.Backpack:WaitForChild("Talent:Voideye", 7.5) or self.player.Backpack:WaitForChild("Talent:Grasp of Eylis", 7.5);
                end;
            end)        
end;
    end;

	local profiler = require("@src/utility/profiler");
    local last_update = 0;
    aztup.maid:give_task(services.RunService.PreRender:Connect(profiler.wrap("player_esp::update", function(...)
        if not aztup.flags.player_esp then 
            for player, esp_object in PlayerESPRegistry do
                esp_object.nametag_billboard.Enabled = false;
                esp_object.billboard.Enabled = false;
            end;
            return        
end
        mouse_pos = services.UserInputService:GetMouseLocation();
        local now = tick();
        if not aztup.flags.esp_update_rate or now - last_update < 1 / (aztup.flags.esp_update_rate) then return end
        last_update = now;
        camera = workspace.CurrentCamera;
        
        for player, esp_object in PlayerESPRegistry do
            if not player.Parent then
                esp_object:destroy();
                continue            
end;
    
            esp_object:update();
        end;
        

    end)));
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    InstanceWatcher.new(workspace:WaitForChild("Live"), function(entity)
        return entity.Name:sub(1,1) ~= "." and entity.Name ~= services.Players.LocalPlayer.Name
    end, function(entity)   
        local player;
        player = services.Players:GetPlayerFromCharacter(entity);
        if not player then
            repeat
                task.wait(0.1);
                player = services.Players:GetPlayerFromCharacter(entity);
            until player or not entity.Parent;
        end;
        task.spawn(PlayerESP.new, entity, player);
    end);

    
    aztup.maid:give_task(function()
        for _, object in PlayerESPRegistry do
            object:destroy();
        end;
    end);
    
    return PlayerESP
end)