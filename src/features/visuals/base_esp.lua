return LPH_NO_VIRTUALIZE(function()
	local settings_updated = false
	local limited_esp_cache_result = false
	local deepwoken_mesh_ids = require("@src/utility/deepwoken/deepwoken_meshes" .. "")
	local stored_damage_registry = require("@src/utility/stored_damage_registry")
	local root_part_pos = Vector3.new(0, 0, 0)

	
	
	
	local esp_billboard = Instance.new("BillboardGui")
	do
		esp_billboard.LightInfluence = 0
		esp_billboard.StudsOffset = Vector3.new(0, 0, 0)
		esp_billboard.Active = true
		esp_billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		esp_billboard.ClipsDescendants = true
		esp_billboard.AlwaysOnTop = true
		esp_billboard.Size = UDim2.new(0, 400, 0, 400)
	end

	local esp_label = Instance.new("TextLabel", esp_billboard)
	do
		esp_label.Font = Enum.Font.SourceSans
		esp_label.Size = UDim2.new(1, 0, 1, 0)
		esp_label.TextColor3 = Color3.new(1, 1, 1)
		esp_label.BackgroundTransparency = 1
		esp_label.BackgroundColor3 = Color3.new(1, 1, 1)
		esp_label.Text = ""
		esp_label.AutoLocalize = false
		esp_label.RichText = false
		esp_label.TextSize = 18
		esp_label.TextTransparency = 0.2
		esp_label.ZIndex = 3

		local stroke = Instance.new("UIStroke", esp_label)
		stroke.Thickness = 1
		stroke.Color = Color3.new(0, 0, 0)
		stroke.Name = "stroke"
	end

	
	
	
	local mob_health_color_low = Color3.fromRGB(255, 112, 112)
	local mob_health_color_high = Color3.fromRGB(187, 255, 181)
	local mob_healthbar_bg_transparency = 0.5
	local mob_healthbar_stroke_transparency = 0.3
	local mob_healthbar_fade_start = 250
	local mob_healthbar_fade_end = 500

	local esp_healthbar_template = Instance.new("Frame")
	do
		esp_healthbar_template.Name = "HealthBar"
		esp_healthbar_template.AnchorPoint = Vector2.new(0.5, 0)
		esp_healthbar_template.Position = UDim2.new(0.5, 0, 0.5, 12)
		esp_healthbar_template.Size = UDim2.new(0, 50, 0, 6)
		esp_healthbar_template.BackgroundColor3 = Color3.new(0, 0, 0)
		esp_healthbar_template.BackgroundTransparency = mob_healthbar_bg_transparency
		esp_healthbar_template.BorderSizePixel = 0
		esp_healthbar_template.ZIndex = 2
		esp_healthbar_template.Visible = false

		local stroke = Instance.new("UIStroke", esp_healthbar_template)
		stroke.Thickness = 1
		stroke.Color = Color3.new(0, 0, 0)
		stroke.Transparency = mob_healthbar_stroke_transparency

		local fill = Instance.new("Frame", esp_healthbar_template)
		fill.Name = "FillBar"
		fill.BorderSizePixel = 0
		fill.Size = UDim2.new(1, 0, 1, 0)
		fill.ZIndex = 2
		fill.BackgroundColor3 = mob_health_color_high

		local gradient = Instance.new("UIGradient", fill)
		gradient.Rotation = -90
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(175, 175, 175)),
		})

		local stored_damage_bar = Instance.new("Frame", esp_healthbar_template)
		stored_damage_bar.Name = "StoredDamageBar"
		stored_damage_bar.BorderSizePixel = 0
		stored_damage_bar.ZIndex = 3
		stored_damage_bar.BackgroundColor3 = Color3.fromRGB(137, 180, 250)
		stored_damage_bar.Visible = false

		local stored_damage_gradient = Instance.new("UIGradient", stored_damage_bar)
		stored_damage_gradient.Rotation = -90
		stored_damage_gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(175, 175, 175)),
		})
	end

	
	
	
	local all_esp_tags = {
		mantra_obelisk_esp = true,
		dropped_item_esp = true,
		obelisk_rare_esp = true,
		heal_brick_esp = true,
		jetty_post_esp = true,
		whirlpool_esp = true,
		voi_weapon_esp = true,
		boundary_esp = true,
		ingredient_esp = true,
		br_weapon_esp = true,
		campfire_esp = true,
		artifact_esp = true,
		obelisk_esp = true,
		banner_esp = true,
		meteor_esp = true,
		chest_esp = true,
		cache_esp = true,
		crate_esp = true,
		shop_esp = true,
		area_esp = true,
		bag_esp = true,
		npc_esp = true,
		job_esp = true,
		mob_esp = true,
		owl_esp = true,
	}

	local function format_distance(self)
		return aztup_options.distance_naming.Value == "studs" and ("%is"):format(self.distance) or (self.distance > 1000 and ("%.1fkm"):format(self.distance / 1000) or ("%im"):format(self.distance))	
end;

	local function format_over_thousand(number)
		return number > 1000 and string.format("%.1fk", number / 1000) or string.format("%i", number)	
end;

	
	
	
	local esp_name_formatters = {
		mob_esp = function(self)
			local name = self.character:GetAttribute("MOB_rich_name") or self.character.Name
			local lower_name = name:lower()

			if
				aztup_options.mob_filter.Value.Guards
				and (lower_name:find("guard") or lower_name:find("peacekeeper"))
				and not lower_name:match("guardian")
				and not lower_name:match("shogun")
			then
				return ""
			end

			if aztup_options.mob_filter.Value.Gigameds and lower_name:find("gigamed") then
				return ""
			end

			if not self.humanoid then
				self.humanoid = self.character:FindFirstChildOfClass("Humanoid")
				return ("[%s] %s\n(no humanoid)"):format(format_distance(self), name)
			end

			self.max_health = math.floor(self.humanoid.MaxHealth)
			self.health = math.floor(self.humanoid.Health)

			local health_format;
			local health_format_type = aztup_options.mob_health_format.Value;

			if health_format_type == "hp%" then
				health_format = string.format(
					"%i%%", 
					(self.health / self.max_health) * 100
				)
			elseif health_format_type == "hp/max" then
				health_format = string.format(
					"%s/%s", 
					format_over_thousand(self.health),
					format_over_thousand(self.max_health)
				)
			else
				health_format = string.format(
					"%s/%s, %i%%", 
					format_over_thousand(self.health),
					format_over_thousand(self.max_health),
					(self.health / self.max_health) * 100
				)
			end;


			return ("[%s] %s (%s)"):format(
				format_distance(self),
				name,
				health_format
			)
		end,

		job_esp = function(self)
			local name = "Job"
			local jobTracker = self.character:FindFirstChild("JobTrackerGui")
			if jobTracker then
				if aztup.flags.hide_game_esp then
					jobTracker.Enabled = false
				end

				local textLabel = jobTracker:FindFirstChild("TextLabel")
				if textLabel then
					name = textLabel.Text
				end
			end

			return ("[%s] %s"):format(format_distance(self), name)
		end,

		banner_esp = function(self)
			local owner = self.character:GetAttribute("Owner")
			local banner_name = "Banner"

			if owner and #owner > 0 then
				banner_name ..= " | Owner: " .. owner
			end

			return ("[%s] %s"):format(format_distance(self), banner_name)
		end,
	}

	local static_name_map = {
		artifact_esp = "Artifact",
		whirlpool_esp = "Whirlpool",
		chest_esp = "Chest",
		bag_esp = "Bag",
		crate_esp = "Explosive Crate",
		cache_esp = "Ministry Cache",
		campfire_esp = "Campfire",
		meteor_esp = "Bell Meteor",
		jetty_post_esp = "Jetty Post",
		obelisk_esp = "Obelisk",
		obelisk_rare_esp = "Rare Obelisk",
		heal_brick_esp = "Heal Brick",
		owl_esp = "Owl",
		mantra_obelisk_esp = "Mantra Obelisk",
	}

	local static_map = {
		artifact_esp = "Artifact",
		whirlpool_esp = "Whirlpool",
		chest_esp = "Chest",
		bag_esp = "Bag",
		crate_esp = "Explosive Crate",
		cache_esp = "Ministry Cache",
		campfire_esp = "Campfire",
		meteor_esp = "Bell Meteor",
		obelisk_esp = "Obelisk",
		obelisk_rare_esp = "Rare Obelisk",
		heal_brick_esp = "Heal Brick",
		mantra_obelisk_esp = "Mantra Obelisk",
		dropped_item_esp = true,
		area_esp = true,
		ingredient_esp = true,
		npc_esp = true,
		shop_esp = true,
		jetty_post_esp = true,
		boundary_esp = true,
		owl_esp = true,
		voi_weapon_esp = true,
		br_weapon_esp = true,
	}

	local function get_static(tag)
		return static_map[tag]
	end

	local function get_static_tag(self)
		if static_name_map[self.tag] then
			return static_name_map[self.tag]
		elseif self.area_esp then
			return self.character.Parent.Name
		elseif self.boundary_esp then
			return self.character.Name
		elseif self.voi_weapon_esp then
			local rarity = self.character:GetAttribute("Rarity") or "Unknown"
			return string.format("%s [%s]", self.character.Name, rarity)
		elseif self.br_weapon_esp then
			return self.character.Name
		elseif self.ingredient_esp or self.npc_esp or self.shop_esp then
			return self.character.Name
		elseif self.dropped_item_esp then
			local mesh = self.character:IsA("MeshPart") and self.character or self.character:WaitForChild("Mesh", 0.5)

			if mesh and pcall(function()
				return mesh.MeshId
			end) then
				return deepwoken_mesh_ids[tostring(mesh.MeshId:match("%d+"))] or "Dropped Item"
			else
				return "Dropped Item"
			end
		end
		return "None [esp::get_static_tag]"
	end

	local function get_name(self)
		if esp_name_formatters[self.tag] then
			return esp_name_formatters[self.tag](self)
		end

		return ("[%s] %s"):format(
			format_distance(self),
			self.static and self.static_tag
				or self.character.Name
					.. string.format(
						" [esp::get_name() %s %s %s]",
						self.static or "nil",
						self.static_tag or "nil",
						self.tag or "nil"
					)
		)
	end

	
	
	local ESP_UPDATE_SPREAD_BUCKETS = 30

	local function get_position(self)
		if self.job_esp then
			return self.character.WorldPosition
		else
			return self.use_pivot and self.character:GetPivot().Position or self.character.Position
		end
	end

	
	
	
	local billboard_esp = {}
	do
		billboard_esp.__index = billboard_esp
		billboard_esp.__objects = {}
		billboard_esp.__registry = {}
		billboard_esp.last_update = 0
		billboard_esp.last_sett_update = 0
		billboard_esp.__spawn_counter = 0

		function billboard_esp.new(character, tag, vis_check)
			if billboard_esp.__registry[character] then
				billboard_esp.__registry[character]:destroy()
			end

			local self = setmetatable({}, billboard_esp)

			self.character = character
			self.use_pivot = character:IsA("Model")
			self.root = self.use_pivot and character:FindFirstChild("HumanoidRootPart")
				or character:FindFirstChildWhichIsA("BasePart")
				or character
			self.billboard = esp_billboard:Clone()
			self.billboard.Enabled = false
			self.billboard.Adornee = self.root
			self.billboard.Parent = services.CoreGui

			self.label = self.billboard:FindFirstChildOfClass("TextLabel")
			self.stroke = self.label:FindFirstChild("stroke")
			self.humanoid = character:FindFirstChildOfClass("Humanoid")
			self[tag] = true
			self.tag = tag
			self.vis_check = vis_check

			billboard_esp.__spawn_counter += 1
			local phase = (billboard_esp.__spawn_counter % ESP_UPDATE_SPREAD_BUCKETS) / ESP_UPDATE_SPREAD_BUCKETS
			self.last_update = tick() - phase * (1 / aztup.flags.esp_update_rate)

			if not all_esp_tags[tag] then
				return warn("register your tags, ", tag, " is not registered.")
			end

			task.delay(0.1, function()
				self:update_settings(true)
				if local_player.root_part then
					self:update()
				end
			end)

			if self.mob_esp or self.npc_esp then
				self.billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
			end

			if self.mob_esp then
				self.healthbar = esp_healthbar_template:Clone()
				self.healthbar.Parent = self.billboard
				self.healthbar_fill = self.healthbar.FillBar
				self.healthbar_stroke = self.healthbar:FindFirstChildOfClass("UIStroke")
				self.healthbar_stored = self.healthbar:FindFirstChild("StoredDamageBar")

				local last_health = 0;
				
				task.spawn(function()
					local humanoid = self.character:WaitForChild("Humanoid", 30);
					if not humanoid then return end

					self.healthbar_update_conn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
						if math.abs(last_health - humanoid.Health) < 5 then
							return						
end;

						self:update(); 
						last_health = humanoid.Health;
					end);
				end);
			end

			Markers:mark(self.billboard)

			billboard_esp.__objects[tag] = billboard_esp.__objects[tag] or {}
			self.inserted_at = #billboard_esp.__objects[tag]
			table.insert(billboard_esp.__objects[tag], self)

			self.ancestry = character.AncestryChanged:Connect(function()
				if
					not character.Parent
					or (
						self.area_esp and not character:IsDescendantOf(services.ReplicatedStorage)
						or not character:IsDescendantOf(workspace)
					)
				then
					self:destroy()
				end
			end)

			self.static_tag = get_static_tag(self)
			self.static = get_static(self.tag)
			billboard_esp.__registry[character] = self

			return self
		end

		function billboard_esp:destroy()
			if self._destroyed then
				return
			end
			self._destroyed = true

			if self.mob_esp and self.character then
				stored_damage_registry[self.character] = nil
			end

			if self.billboard then
				self.billboard:Destroy()
				self.billboard = nil
			end

			if self.ancestry then
				if self.ancestry.Connected ~= nil then
					if self.ancestry.Connected then
						self.ancestry:Disconnect()
					end
				else
					pcall(function()
						self.ancestry:Disconnect()
					end)
				end
				self.ancestry = nil
			end

			if self.character and billboard_esp.__registry[self.character] == self then
				billboard_esp.__registry[self.character] = nil
			end

			if self.tag and billboard_esp.__objects[self.tag] then
				local objects = billboard_esp.__objects[self.tag]
				if self.inserted_at and objects[self.inserted_at] == self then
					table.remove(objects, self.inserted_at)
				else
					for i, obj in ipairs(objects) do
						if obj == self then
							table.remove(objects, i)
							break
						end
					end
				end
			end
		end

		billboard_esp.get_name = get_name

		function billboard_esp:update()
			if not self.billboard then
				return
			end

			local flag_visible = aztup.flags[self.tag]
			if not flag_visible or self.vis_check and not self:vis_check() then
				self.billboard.Enabled = false
				return
			end

			local position = get_position(self)
			if not position then
				return
			end

			local diff = root_part_pos - position
			local dist_sq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
			self.distance = math.floor(math.sqrt(dist_sq))

			local name = self:get_name()
			local shouldnt_be_visible = name == "";

			self.billboard.Enabled = not shouldnt_be_visible;
			if not shouldnt_be_visible then
				self.label.Text = name
			end;

			if self.healthbar then
				
				if aztup.flags.mob_esp_healthbar and self.distance < mob_healthbar_fade_end and not shouldnt_be_visible and self.humanoid and self.max_health and self.max_health > 0 then
					local ratio = math.clamp(self.health / self.max_health, 0, 1)
					self.healthbar.Visible = true
					self.healthbar_fill.Size = UDim2.new(ratio, 0, 1, 0)
					self.healthbar_fill.BackgroundColor3 = mob_health_color_low:Lerp(mob_health_color_high, ratio)
					self.healthbar.Size = UDim2.new(0, self.label.TextBounds.X, 0, 6)

					local fade_alpha = math.clamp(
						(self.distance - mob_healthbar_fade_start) / (mob_healthbar_fade_end - mob_healthbar_fade_start),
						0,
						1
					)
					self.healthbar.BackgroundTransparency = mob_healthbar_bg_transparency
						+ (1 - mob_healthbar_bg_transparency) * fade_alpha
					self.healthbar_fill.BackgroundTransparency = fade_alpha
					if self.healthbar_stroke then
						self.healthbar_stroke.Transparency = mob_healthbar_stroke_transparency
							+ (1 - mob_healthbar_stroke_transparency) * fade_alpha
					end

					if self.healthbar_stored then
						local stored_damage = aztup.flags.show_stored_damage and stored_damage_registry[self.character]
						local stored_ratio = stored_damage and math.clamp(stored_damage / self.max_health, 0, ratio) or 0
						self.healthbar_stored.Visible = stored_ratio > 0
						if stored_ratio > 0 then
							self.healthbar_stored.Position = UDim2.new(ratio - stored_ratio, 0, 0, 0)
							self.healthbar_stored.Size = UDim2.new(stored_ratio, 0, 1, 0)
							self.healthbar_stored.BackgroundColor3 = aztup_options.show_stored_damage_color.Value
							self.healthbar_stored.BackgroundTransparency = fade_alpha
						end
					end
				else
					self.healthbar.Visible = false
					if self.healthbar_stored then
						self.healthbar_stored.Visible = false
					end
				end
			end
		end

		function billboard_esp:get_font()
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
		end

		function billboard_esp:update_settings(force)
			if settings_updated and aztup.flags[self.tag] or force then
				local font, ff = self:get_font()
				local label = self.label
				if ff then
					label.FontFace = font;
				else
					label.Font = font
				end;
				label.TextSize = aztup.flags[self.tag .. "_text_size"]
				local color = aztup_options[self.tag .. "_color"]
				label.TextColor3 = color.Value
				label.TextTransparency = color.Transparency
				self.stroke.Transparency = color.Transparency
			end

			if self.billboard then
				self.billboard.MaxDistance = aztup.flags[self.tag .. "_max_dist"]
			end
		end
	end

	
	
	
	local dynamic_esp = {}
	do
		dynamic_esp.__index = dynamic_esp
		dynamic_esp.__objects = {}
		dynamic_esp.__registry = {}
		dynamic_esp.last_update = 0
		dynamic_esp.last_sett_update = 0
		dynamic_esp.__spawn_counter = 0

		function dynamic_esp.new(character, tag, vis_check)
			if dynamic_esp.__registry[character] then
				dynamic_esp.__registry[character]:destroy()
			end

			local self = setmetatable({}, dynamic_esp)

			self.character = character
			self.use_pivot = character:IsA("Model")
			self.root = self.use_pivot and character:FindFirstChild("HumanoidRootPart")
				or character:FindFirstChildWhichIsA("BasePart")
				or character
			self.humanoid = character:FindFirstChildOfClass("Humanoid")
			self[tag] = true
			self.tag = tag
			self.vis_check = vis_check

			dynamic_esp.__spawn_counter += 1
			local phase = (dynamic_esp.__spawn_counter % ESP_UPDATE_SPREAD_BUCKETS) / ESP_UPDATE_SPREAD_BUCKETS
			self.last_update = tick() - phase * (1 / aztup.flags.esp_update_rate)

			if not all_esp_tags[tag] then
				return warn("register your tags, ", tag, " is not registered.")
			end

			local offset_y = (self.mob_esp or self.npc_esp) and 3 or 0

			self.point = PointInstance.new(self.root)
			self.point.Offset = CFrame.new(0, offset_y, 0)

			self.text_dynamic = TextDynamic.new(self.point)
			self.text_dynamic.Visible = false
			self.text_dynamic.Text = ""
			self.text_dynamic.XAlignment = XAlignment.Center
			self.text_dynamic.YAlignment = YAlignment.Center
			self.text_dynamic.Size = 18
			self.text_dynamic.Color = Color3.new(1, 1, 1)
			self.text_dynamic.Opacity = 0.8
			self.text_dynamic.Outlined = true
			self.text_dynamic.OutlineColor = Color3.new(0, 0, 0)
			self.text_dynamic.OutlineOpacity = 0.8
			self.text_dynamic.OutlineThickness = 1
			self.text_dynamic.ZIndex = 3

			task.delay(0.1, function()
				self:update_settings(true)
				if local_player.root_part then
					self:update()
				end
			end)

			dynamic_esp.__objects[tag] = dynamic_esp.__objects[tag] or {}
			self.inserted_at = #dynamic_esp.__objects[tag]
			table.insert(dynamic_esp.__objects[tag], self)

			self.ancestry = character.AncestryChanged:Connect(function()
				if
					not character.Parent
					or (
						self.area_esp and not character:IsDescendantOf(services.ReplicatedStorage)
						or not character:IsDescendantOf(workspace)
					)
				then
					self:destroy()
				end
			end)

			self.static_tag = get_static_tag(self)
			self.static = get_static(self.tag)
			dynamic_esp.__registry[character] = self

			aztup.maid:give_task(function()
				self:destroy()
			end)

			return self
		end

		function dynamic_esp:destroy()
			if self._destroyed then
				return
			end
			self._destroyed = true

			if self.text_dynamic then
				self.text_dynamic.Visible = false
				self.text_dynamic:Destroy()
				self.text_dynamic = nil
			end

			if self.point then
				self.point = nil
			end

			if self.ancestry then
				if self.ancestry.Connected ~= nil then
					if self.ancestry.Connected then
						self.ancestry:Disconnect()
					end
				else
					pcall(function()
						self.ancestry:Disconnect()
					end)
				end
				self.ancestry = nil
			end

			if self.character and dynamic_esp.__registry[self.character] == self then
				dynamic_esp.__registry[self.character] = nil
			end

			if self.tag and dynamic_esp.__objects[self.tag] then
				local objects = dynamic_esp.__objects[self.tag]
				if self.inserted_at and objects[self.inserted_at] == self then
					table.remove(objects, self.inserted_at)
				else
					for i, obj in ipairs(objects) do
						if obj == self then
							table.remove(objects, i)
							break
						end
					end
				end
			end
		end

		dynamic_esp.get_name = get_name

		function dynamic_esp:update()
			if not self.text_dynamic then
				return
			end

			local flag_visible = aztup.flags[self.tag]
			if not flag_visible or self.vis_check and not self:vis_check() then
				self.text_dynamic.Visible = false
				return
			end

			local position = get_position(self)
			if not position then
				return
			end

			local diff = root_part_pos - position
			local dist_sq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
			self.distance = math.floor(math.sqrt(dist_sq))

			local max_dist = aztup.flags[self.tag .. "_max_dist"]
			if max_dist then
				local max_dist_sq = max_dist * max_dist
				if dist_sq > max_dist_sq then
					self.text_dynamic.Visible = false
					return
				end
			end

			local font = Drawing.Fonts[aztup_options.SynZ_Font.Value] or Drawing.Fonts.UI
			if self.text_dynamic.Font ~= font then
				self.text_dynamic.Font = font
			end

			local name = self:get_name()
			if self.text_dynamic.Text ~= name then
				self.text_dynamic.Text = name
			end
			self.text_dynamic.Visible = true
		end

		function dynamic_esp:update_settings(force)
			if not self.text_dynamic then
				return
			end

			if settings_updated and aztup.flags[self.tag] or force then
				self.text_dynamic.Size = aztup.flags[self.tag .. "_text_size"]
				local color = aztup_options[self.tag .. "_color"]
				self.text_dynamic.Font = Drawing.Fonts[aztup_options.SynZ_Font.Value] or Drawing.Fonts.UI
				self.text_dynamic.Color = color.Value
				self.text_dynamic.Opacity = 1 - color.Transparency
				self.text_dynamic.OutlineOpacity = 1 - color.Transparency
			end
		end
	end

	
	
	
	local esp = {}
	do
		function esp.get_backend()
			if limited_esp_cache_result then
				return dynamic_esp
			end
			return billboard_esp
		end

		function esp.new(character, tag, vis_check)
			return esp.get_backend().new(character, tag, vis_check)
		end

		esp.billboard = billboard_esp
		esp.dynamic = dynamic_esp
	end

	
	
	

	
	if game.PlaceId == 13891478131 then
		InstanceWatcher.new(workspace, function(entity)
			return entity.Name == "RareObelisk"
		end, function(entity)
			esp.new(entity, "obelisk_rare_esp")
		end)

		InstanceWatcher.new(workspace, function(entity)
			return entity.Name == "HealBrick"
		end, function(entity)
			esp.new(entity, "heal_brick_esp")
		end)

		for _, child in workspace:GetChildren() do
			if child:IsA("MeshPart") and child:GetAttribute("Rarity") ~= nil and not child.Name:match("ArmorBrick") then
				esp.new(child, "voi_weapon_esp")
			end
		end

		InstanceWatcher.new(workspace, function(entity)
			return entity:IsA("MeshPart")
				and entity:GetAttribute("Rarity") ~= nil
				and not entity.Name:match("ArmorBrick")
		end, function(entity)
			esp.new(entity, "voi_weapon_esp")
		end)

		InstanceWatcher.new(workspace, function(entity)
			return entity.Name:match("MantraObelisk")
		end, function(entity)
			esp.new(entity, "mantra_obelisk_esp")
		end)
	end

	InstanceWatcher.new(workspace:WaitForChild("Thrown"), function(entity)
		return entity.Name == "BigArtifact" and #entity:GetChildren() > 0
	end, function(entity)
		esp.new(entity, "artifact_esp")
	end, true)
	
	InstanceWatcher.new(workspace:WaitForChild("Thrown"), function(entity)
		return entity.Name == "EventFeatherRef"
	end, function(entity)
		esp.new(entity, "owl_esp")
	end, true)

	InstanceWatcher.new(workspace:WaitForChild("Thrown"), function(entity)
		return entity.Name == "Chest" or entity:WaitForChild("Lid", 2.5)
	end, function(entity)
		esp.new(entity, "chest_esp")
	end, true)

	InstanceWatcher.new(workspace:WaitForChild("Thrown"), function(entity)
		local names = { "BagDrop", "ExplodeCrate", "MinistryCacheIndicator", "Campfire", "BellMeteor" }
		return table.find(names, entity.Name) ~= nil
	end, function(entity)
		local flags = {
			BagDrop = "bag_esp",
			ExplodeCrate = "crate_esp",
			MinistryCacheIndicator = "cache_esp",
			Campfire = "campfire_esp",
			BellMeteor = "meteor_esp",
		}
		esp.new(entity, flags[entity.Name])
	end, true)

	InstanceWatcher.new(workspace:WaitForChild("Destructibles"), function(entity)
		return entity.Name == "Campfire"
	end, function(entity)
		esp.new(entity, "campfire_esp")
	end, true)

	InstanceWatcher.new(workspace:WaitForChild("Mechanisms"), function(entity)
		return entity.Name == "JettyPost"
	end, function(entity)
		esp.new(entity, "jetty_post_esp")
	end, true)

	InstanceWatcher.new(workspace:WaitForChild("Shops"), function(entity)
		return entity:IsA("BasePart")
	end, function(entity)
		esp.new(entity, "shop_esp")
	end, true)

	InstanceWatcher.new(workspace, function(entity)
		return entity.Name:match("GuildBanner")
	end, function(entity)
		esp.new(entity, "banner_esp")
	end, true)

	InstanceWatcher.new(workspace:WaitForChild("Live"), function(entity)
		return entity.Name:sub(1, 1) == "." and not entity.Name:match("watcher")
	end, function(entity)
		esp.new(entity, "mob_esp")
	end, true)

	InstanceWatcher.new(workspace:WaitForChild("NPCs", 9e9), function(entity)
		return true
	end, function(entity)
		esp.new(entity, "npc_esp")
	end, true)

	local connected
	aztup_toggles.ingredient_esp:OnChanged(function()
		if not aztup_toggles.ingredient_esp.Value or connected then
			return
		end

		connected = true
		InstanceWatcher.new(workspace:WaitForChild("Ingredients", 9e9), function(entity)
			return entity ~= nil
		end, function(entity)
			esp.new(entity, "ingredient_esp", function(self)
				local ingredient_filters = aztup_options.ingredient_filter.Value
				return ingredient_filters["All Ingredients"] or ingredient_filters[self.character.Name]
			end)
		end)
	end, true)

	InstanceWatcher.new(workspace:WaitForChild("Terrain", 9e9), function(entity)
		return entity:IsA("Attachment") and entity:WaitForChild("JobTrackerGui", 5)
	end, function(entity)
		esp.new(entity, "job_esp")
	end, true)

	InstanceWatcher.new(workspace, function(entity)
		return entity.Name:find("Boundary") and entity:WaitForChild("BoundaryFX", 0.3)
	end, function(entity)
		esp.new(entity, "boundary_esp")
	end, true)

	InstanceWatcher.new(workspace, function(entity)
		return entity.Name == "DepthsWhirlpool"
	end, function(entity)
		esp.new(entity, "whirlpool_esp")
	end, true)

	local function dropped_item_added(item)
		local mesh = item:IsA("MeshPart") and item or item:WaitForChild("Mesh", 0.5)

		if not mesh or not pcall(function()
			return mesh.MeshId
		end) then
			return
		end

		esp.new(item, "dropped_item_esp")
	end

	services.CollectionService:GetInstanceAddedSignal("LootDrop"):Connect(dropped_item_added)

	for _, item in services.CollectionService:GetTagged("LootDrop") do
		dropped_item_added(item)
	end

	if workspace:FindFirstChild("Layer2Floor2") then
		InstanceWatcher.new(workspace:FindFirstChild("Layer2Floor2"), function(entity)
			return entity.Name == "Obelisk"
		end, function(entity)
			esp.new(entity, "obelisk_esp")
		end)
	end

	for _, v in
		pairs(services.ReplicatedStorage:WaitForChild("MarkerWorkspace"):WaitForChild("AreaMarkers"):GetChildren())
	do
		if v.Name:match("'s Base") or not v:FindFirstChild("AreaMarker") then
			continue
		end
		esp.new(v:FindFirstChild("AreaMarker"), "area_esp")
	end


	local profiler = require("@src/utility/profiler");
	
	
	
	
	aztup.maid:give_task(services.RunService.PreRender:Connect(profiler.wrap("base_esp::update", function()
		if local_player.root_part then
			root_part_pos = local_player.root_part.Position
		end

		local now = tick()

		
		do
			local be = billboard_esp
			local is_active_backend = not limited_esp_cache_result

			if not is_active_backend then
				for tag, objects in pairs(be.__objects) do
					for i = 1, #objects do
						local obj = objects[i]
						if obj.billboard then
							obj.billboard.Enabled = false
						end
					end
				end
			else
				local interval = 1 / aztup.flags.esp_update_rate
				local should_update_settings = now - (be.last_sett_update or 0) > 1
				if should_update_settings then
					be.last_sett_update = now
				end

				for tag, objects in pairs(be.__objects) do
					if not aztup.flags[tag] then
						for i = 1, #objects do
							local obj = objects[i]
							if obj.billboard then
								obj.billboard.Enabled = false
							end
						end
					else
						for i = 1, #objects do
							local obj = objects[i]
							if should_update_settings then
								obj:update_settings()
							end
							if now - (obj.last_update or 0) >= interval then
								obj.last_update = now
								obj:update()
							end
						end
					end
				end
			end
		end

		
		do
			local be = dynamic_esp
			local is_active_backend = limited_esp_cache_result

			if not is_active_backend then
				for tag, objects in pairs(be.__objects) do
					for i = 1, #objects do
						local obj = objects[i]
						if obj.text_dynamic then
							obj.text_dynamic.Visible = false
						end
					end
				end
			else
				local interval = 1 / aztup.flags.esp_update_rate
				local should_update_settings = now - (be.last_sett_update or 0) > 1
				if should_update_settings then
					be.last_sett_update = now
				end

				for tag, objects in pairs(be.__objects) do
					if not aztup.flags[tag] then
						for i = 1, #objects do
							local obj = objects[i]
							if obj.text_dynamic then
								obj.text_dynamic.Visible = false
							end
						end
					else
						for i = 1, #objects do
							local obj = objects[i]
							if should_update_settings then
								obj:update_settings()
							end
							if now - (obj.last_update or 0) >= interval then
								obj.last_update = now
								obj:update()
							end
						end
					end
				end
			end
		end
	end)))

	
	
	
	local function set_update_callback()
		settings_updated = true
		task.delay(3, function()
			settings_updated = false
		end)
	end

	aztup_options.Font:OnChanged(set_update_callback)

	for tag, _ in all_esp_tags do
		pcall(function()
			aztup_options[tag .. "_text_size"]:OnChanged(set_update_callback)
			aztup_options[tag .. "_max_dist"]:OnChanged(set_update_callback)
			aztup_options[tag .. "_color"]:OnChanged(set_update_callback)
		end)
	end

	return esp
end)
