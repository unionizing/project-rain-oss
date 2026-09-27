
aztup_options = getgenv().aztup_options;
local cloneref = cloneref or function(a) return a end;
local httpService = cloneref(game:GetService('HttpService'));

local auto_loading = false;
local SaveManager = {} do
	SaveManager.Folder = 'LinoriaLibSettings'
	SaveManager.Ignore = {}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = 'Toggle', idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if aztup_toggles[idx] and aztup_toggles[idx].Value ~= data.value then 
					task.spawn(function()
						aztup_toggles[idx]:SetValue(data.value)
					end);
				end
			end,
		},
		MinMaxSlider = {
			Save = function(idx, object)
				return { 
					type = 'MinMaxSlider', 
					idx = idx,
					Min = string.format("%.2f", object.Value.Min),
					Max = string.format("%.2f", object.Value.Max),
				}
			end,
			Load = function(idx, data)
				if aztup_options[idx] then  
					task.spawn(function()
						aztup_options[idx]:SetValue({
							Min = data.Min,
							Max = data.Max
						})
					end)
				end
			end,
		},
		Slider = {
			Save = function(idx, object) 
				return { type = 'Slider', idx = idx, value = tostring(object.Value) }
			end,
			Load = function(idx, data)
				if aztup_options[idx] then  
					task.spawn(function()
						aztup_options[idx]:SetValue(data.value)
					end)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = 'Dropdown', idx = idx, value = object.Value, multi = object.Multi }
			end,
			Load = function(idx, data)
				if aztup_options[idx] then 
					if auto_loading then
						aztup_options[idx]:SetValue(data.value, true)
					else
						aztup_options[idx]:SetValue(data.value)
					end
				end
			end,
		},
		ColorPicker = {
			Save = function(idx, object)
				return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
			end,
			Load = function(idx, data)
				if aztup_options[idx] then 
					aztup_options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		KeyPicker = {
			Save = function(idx, object)
				return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if aztup_options[idx] then 
					aztup_options[idx]:SetValue({ data.key, data.mode })
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = 'Input', idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if aztup_options[idx] and type(data.text) == 'string' then
					aztup_options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

	function SaveManager:Save(name)
		if not name then
			return false, "no config file is selected"
		end

		local fullPath = self.Folder .. "/Settings/" .. name .. ".json"

		local function udimToTable(udim)
			return {
				["S"] = udim.Scale,
				["O"] = udim.Offset,
			}
		end


		local function udim2ToTable(udim2)
			return {
				["X"] = udimToTable(udim2.X),
				["Y"] = udimToTable(udim2.Y),
				["W"] = udimToTable(udim2.Width),
				["H"] = udimToTable(udim2.Height),
			}
		end

		local function udim2NoOffset(udim2: UDim2)
			return {
				["X"] = udimToTable(udim2.X),
				["Y"] = udimToTable(udim2.Y),
				["W"] = udimToTable(udim2.Width),
				["H"] = udimToTable(udim2.Height),
			}
		end

		local data = {
			objects = {},
			infoLoggerPosition = udim2ToTable(Library.InfoLoggerFrame.Position),
			keybindPosition = udim2ToTable(Library.KeybindFrame.Position),
			watermarkPosition = udim2ToTable(Library.Watermark.Position),
		}

		if aztup and aztup.proximity then
			data.proximityPosition = udim2NoOffset(aztup.proximity.Position);
			data.proximityTrans = aztup.proximity.BackgroundTransparency;
		end;

		pcall(function() 
			if aztup and aztup.spotify_widget then
				data.spotifyWidgetPosition = udim2ToTable(aztup.spotify_widget.Position);
			end;
		end);

		for idx, toggle in next, aztup_toggles do
			if self.Ignore[idx] then
				continue
			end

			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end

		for idx, option in next, aztup_options do
			if not self.Parser[option.Type] then
				continue
			end
			if self.Ignore[idx] then
				continue
			end

			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, "failed to encode data"
		end

		writefile(fullPath, encoded)
		return true
	end

	function SaveManager:Load(name)
		if not name then
			return false, "no config file is selected"
		end

		local file = self.Folder .. "/Settings/" .. name .. ".json"
		if not isfile(file) then
			return false, "invalid file"
		end 

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then
			return false, "decode error"
		end

		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				Logger.log_for_devs(("[save-manager] loading %s with option type of %s and value of %s"):format(option.type, option.idx, tostring(option.value)));
				self.Parser[option.type].Load(option.idx, option)
			end
		end

		local function tableToUdim(table)
			return UDim.new(table["S"], table["O"])
		end

		local function tableToUdim2(table)
			return UDim2.new(
				tableToUdim(table["X"]),
				tableToUdim(table["Y"]),
				tableToUdim(table["W"]),
				tableToUdim(table["H"])
			)
		end

		local function tableToUdim2_no_offset(table)
			return UDim2.new(
				tableToUdim(table["X"]),
				0,
				
				tableToUdim(table["W"]),
				0
				
			)
		end

		local function tableToUdim2_no_scale(table)
			return UDim2.new(
				tableToUdim(table["X"]),
				tableToUdim(table["Y"]),
				tableToUdim(table["W"]),
				tableToUdim(table["H"])
			)
		end

		if decoded.watermarkPosition then
			Library.Watermark.Position = tableToUdim2(decoded.watermarkPosition)
		end

		if aztup and aztup.proximity and decoded.proximityPosition then
			aztup.proximity.Position = tableToUdim2(decoded.proximityPosition);
			pcall(function()
				aztup.features.proximity_list:set_transparency(decoded.proximityTrans);
			end)

		end;

		pcall(function() 
			if aztup and aztup.spotify_widget and decoded.spotifyWidgetPosition then
				aztup.spotify_widget.Position = tableToUdim2(decoded.spotifyWidgetPosition);
			end;
		end);

		if decoded.keybindPosition and decoded.infoLoggerPosition then
			Library.KeybindFrame.Position = tableToUdim2(decoded.keybindPosition)
			Library.InfoLoggerFrame.Position = tableToUdim2(decoded.infoLoggerPosition)
			if decoded.chatLoggerSize and game:GetService("CoreGui"):FindFirstChild("thisisachatloggerpleasebanme") then
				local chat_logger = game:GetService("CoreGui"):FindFirstChild("thisisachatloggerpleasebanme");
				chat_logger.Frame.Size = tableToUdim2(decoded.chatLoggerSize);
				chat_logger.Frame.Position = tableToUdim2(decoded.chatLoggerPosition);
			end;
		end

		pcall(function() 
			if not persistent_data:get("automation_webhook") then return end

        	local webhook_url = aztup_options.automation_webhook.Value
        	if not webhook_url:find("discord.com/api/webhooks", 1, true) then
        	    
        	    return
        	end
		
        	persistent_data:set("automation_webhook", webhook_url)
		end);

		return true
	end
	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", 
			"ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName', 
		})
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. '/themes',
			self.Folder .. '/settings'
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function SaveManager:RefreshConfigList()
		local list = listfiles(self.Folder .. '/settings')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				

				local pos = file:find('.json', 1, true)
				local start = pos

				local char = file:sub(pos, pos)
				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1, start - 1))
				end
			end
		end
		
		return out
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
	end

	function SaveManager:LoadAutoloadConfig()
		if isfile(("%s/settings/autoload-%i.txt"):format(self.Folder, game.PlaceId)) then
			local name = readfile(("%s/settings/autoload-%i.txt"):format(self.Folder, game.PlaceId))

			auto_loading = true;
			local success, err = self:Load(name)
			auto_loading = false;
			if isfile("Project Rain/silent_mode_toggle") then return end

			if not success then
				return self.Library:NotifyWithSound('Failed to load autoload config: ' .. err, 50)
			end

			return self.Library:Notify(string.format('Auto loaded config %q', name))
		end

		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')

			auto_loading = true;
			local success, err = self:Load(name)
			auto_loading = false;
			if isfile("Project Rain/silent_mode_toggle") then return end

			if not success then
				return self.Library:NotifyWithSound('Failed to load autoload config: ' .. err, 50)
			end

			return self.Library:Notify(string.format('Auto loaded config %q', name))
		end
	end

	function SaveManager:BuildOtherSection(tab)
		local section = tab:AddRightGroupbox('Other')

		section:AddLabel("Build ID __BUILD__")

		section:AddButton({
			Text = "Switch to Nightly Branch (reexec needed)",
			Func = function()
				writefile("Project Rain/nightliy-branch", "true");
			end,
			DoubleClick = true
		})
		
		section:AddToggle('OnlyShowEnabledKeybinds', {
			Text = 'Only Show Enabled Keybinds',
			false,
			'Only Show Enabled Keybinds'
		})

		section:AddToggle('WatermarkShowsMem', {
			Text = 'Show Memory On Watermark',
			true,
			'Displays the memory data on the watermark.'
		})

		section:AddToggle('notification_sound', {
			Text = 'UI Sounds',
			true,
			'UI Sounds'
		})

		section:AddToggle('KeybindShower', {
			Text = 'Show Keybinds',
			false,
			'Shows Keybinds'
		})

		section:AddToggle('auto_hide_hud', {
			Text = 'Auto Hide HUD',
			false,
			'Auto hides the HUD when the backpack is open.'
		})

		section:AddToggle('BlurWhileOpen', {
			Text = "Blur Game",
			false,
			"Blurs the game whilst the ui is open."
		})

		section:AddToggle('Watermark', {
			Text = 'Watermark',
			true,
			'Displays the script being used.'
		})

		section:AddToggle('Console', {
			Text = 'Console',
			false,
			'Console'
		})
		
		section:AddSlider('NotificationVolume', {
			Text = "Notification Volume",
			Default = 1.3,
			Min = 0.1,
			Suffix = "vol", 
			Max = 10,
			Rounding = 1,
			Compact = false
		})

		local pendingScale;
		section:AddSlider('UIScale', {
			Text = "UI Scale",
			Default = 100,
			Min = 50,
			Max = 200,
			Suffix = "%",
			Rounding = 0,
			Compact = false,
			Tooltip = "Scales the menu and widgets. Applied when you release the slider.",
			Callback = function(value)
				
				local waiting = pendingScale ~= nil;
				pendingScale = value;
				if waiting then return end

				task.spawn(function()
					local InputService = game:GetService('UserInputService');
					while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
						task.wait();
					end

					local target = pendingScale;
					pendingScale = nil;
					self.Library:SetUIScale(target / 100);
					pcall(writefile, self.Folder .. '/settings/ui_scale.txt', tostring(target));
				end)
			end
		})

		
		self:SetIgnoreIndexes({ 'UIScale' });
		local savedScale = isfile(self.Folder .. '/settings/ui_scale.txt') and tonumber(readfile(self.Folder .. '/settings/ui_scale.txt'));
		if savedScale then
			aztup_options.UIScale:SetValue(savedScale);
			self.Library:SetUIScale(savedScale / 100);
		end

		aztup_toggles.OnlyShowEnabledKeybinds:OnChanged(function()
			for _, option in aztup_options do
				if option.Type == 'KeyPicker' and option.Update then
					option:Update();
				end
			end
		end)
		
		aztup_toggles.Watermark:OnChanged(function()
			Library:SetWatermarkVisibility(aztup_toggles.Watermark.Value)
		end)

		aztup_toggles.Console:OnChanged(function()
			Library:SetInfoLoggerVisibility(aztup_toggles.Console.Value)
			Library:UpdateInfoLoggerSize()
		end)
		
		aztup_toggles.KeybindShower:OnChanged(function()
			self.Library.KeybindFrame.Visible = aztup_toggles.KeybindShower.Value;
		end)

		section:AddButton({
			Text = 'Unload Script Instance',
			Func = function()
				if env.aztup then
					if env.Markers then   
						for _, marker in env.Markers:get() do
							marker:Destroy(); 
						end;
						table.clear(env.Markers._marked_instances);
						table.clear(env.Markers);
						getgenv().Markers = nil;
					end;
				
					pcall(function()
						env.aztup:detach();
					end);
					env.aztup = nil;
				end;
			end,
			DoubleClick = true
		})

		   
		local silent_val = isfile("Project Rain/silent_mode_toggle"); 
		section:AddButton({
			Text = 'Toggle Silent Mode', 
			Func = function()
				silent_val = not silent_val;
				if not silent_val then
					pcall(delfile, "Project Rain/silent_mode_toggle")
				else
					pcall(writefile, "Project Rain/silent_mode_toggle", "lmao")
				end;

				if silent_val then
					Logger:long_notify("Delete 'workspace/Project Rain/silent_mode_toggle' to turn this off.");
				    messagebox("You have 'Silent Mode' enabled, Which means you wont see the UI until you open it with the keybind & have extra anti PC check features, If you would like to disable this, Go to UI settings and disable it, This notification is disablable in the fast flags area of UI", "Project Rain", 0)
					messagebox("'Silent Mode' will invalidate any bug reports or support, It will disable notifications (including mod detector) which are a core part of the script as a extra side effect.", "Project Rain", 0)
				else
					aztup.silent_mode = false;
					Logger:long_notify("Disabled silent mode. I now have a voice outside of popups.");
				end;
			end,
			DoubleClick = true
		});

	end;

	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, 'Must set SaveManager.Library')
		
		local section = tab:AddRightGroupbox('Configuration')
		SaveManager:BuildOtherSection(tab);
		local silent_val = isfile("Project Rain/silent_mode_toggle");
		
        section:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightAlt', NoUI = true, Text = 'Menu keybind' })

        self.Library.ToggleKeybind = aztup_options.MenuKeybind 

		section:AddInput('SaveManager_ConfigName',    { Text = 'Config name' })
		section:AddDropdown('SaveManager_ConfigList', { Text = 'Config list', Values = self:RefreshConfigList(), AllowNull = true, Searchable = true })

		section:AddDivider()

		section:AddButton('Create config', function()
			local name = aztup_options.SaveManager_ConfigName.Value

			if name:gsub(' ', '') == '' then 
				return self.Library:Notify('Invalid config name (empty)', 2)
			end

			local success, err = self:Save(name)
			if not success then
				return self.Library:NotifyWithSound('Failed to save config: ' .. err)
			end

			self.Library:NotifyWithSound(string.format('Created config %q', name))

			aztup_options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			aztup_options.SaveManager_ConfigList:SetValue(nil)
		end):AddButton('Load config', function()
			local name = aztup_options.SaveManager_ConfigList.Value

			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load config: ' .. err)
			end

			self.Library:NotifyWithSound(string.format('Loaded config %q', name))
		end)

		section:AddButton('Overwrite config', function()
			local name = aztup_options.SaveManager_ConfigList.Value

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to overwrite config: ' .. err)
			end

			self.Library:NotifyWithSound(string.format('Overwrote config %q', name))
		end)


		local refresh_list_save = function()
			aztup_options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			aztup_options.SaveManager_ConfigList:SetValue(nil)
		end
		
		section:AddButton('Refresh list', refresh_list_save)
		getgenv().refresh_list_save = refresh_list_save;

		section:AddButton('Set as autoload (Global)', function()
			local name = aztup_options.SaveManager_ConfigList.Value
			writefile(self.Folder .. '/settings/autoload.txt', name)
			self.AutoloadLabel:SetText('Current autoload config: ' .. name)
			self.Library:NotifyWithSound(string.format('Set %q to auto load', name))
		end)
		
		section:AddButton(('Set as autoload (%s)'):format(place_name or "place"), function()
			local name = aztup_options.SaveManager_ConfigList.Value
			writefile(("%s/settings/autoload-%i.txt"):format(self.Folder, game.PlaceId), name)
			
			self.Library:NotifyWithSound(string.format('Set %q to auto load in %s', name, place_name or tostring(game.PlaceId)))
		end)

		section:AddButton('Remove Autoload (Global)', function() 
			pcall(delfile, ("%s/settings/autoload.txt"):format(self.Folder))
		end)
		
		section:AddButton(('Remove Autoload (%s)'):format(place_name or "place"), function()
			pcall(delfile, ("%s/settings/autoload-%i.txt"):format(self.Folder, game.PlaceId))
		end)


		SaveManager.AutoloadLabel = section:AddLabel('Current autoload config: none', true)
		

		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
		end

		if isfile(("%s/settings/autoload-%i.txt"):format(self.Folder, game.PlaceId)) then
			local name = readfile(("%s/settings/autoload-%i.txt"):format(self.Folder, game.PlaceId))
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
		end

		SaveManager:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })
	end

	SaveManager:BuildFolderTree()
end

return SaveManager