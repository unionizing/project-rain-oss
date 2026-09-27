
local httpService = game:GetService('HttpService')
local aztup_options = getgenv().aztup_options;
local ThemeManager = {} do
	ThemeManager.Folder = 'LinoriaLibSettings'
	

	ThemeManager.Library = nil
	ThemeManager.BuiltInThemes = {
		['PR']            = { 1, httpService:JSONDecode('{"FontColor":"d8dee9","MainColor":"1b2b34","AccentColor":"6699cc","BackgroundColor":"16232a","OutlineColor":"343d46"}')},

		['Old PR 1']      = { 2, httpService:JSONDecode('{"MainColor":"24273a","AccentColor":"7dc4e4","OutlineColor":"363a4f","BackgroundColor":"1e2030","FontColor":"e9edfa"}')},
		['Old PR 2']      = { 3, httpService:JSONDecode('{"MainColor":"181825","AccentColor":"03b2fd","OutlineColor":"323232","BackgroundColor":"181825","FontColor":"ffe3e3"}') },
		['Linoria']       = { 4, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"0055ff","BackgroundColor":"141414","OutlineColor":"323232"}') },
		['BBot']          = { 5, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}') },
		['Fatality']      = { 6, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"3c355d"}') },
		['Jester']        = { 7, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Mint']          = { 8, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Tokyo Night']   = { 9, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}') },
		['Ubuntu']        = { 10, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"191919"}') },
		['Quartz']        = { 11, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}') },
		['Dracula']       = { 12, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232533","AccentColor":"6271a5","BackgroundColor":"1b1c27","OutlineColor":"7c82a7"}') },
		["Scarlet Hook"]  = { 13, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"343446","AccentColor":"a23636","BackgroundColor":"211e2b","OutlineColor":"000000"}') },
		["maple.software"]= { 14, httpService:JSONDecode('{"MainColor":"292c3c","AccentColor":"f288b7","OutlineColor":"303446","BackgroundColor":"232634","FontColor":"c6d0f5"}')},

		["Nord"]          = { 15, httpService:JSONDecode('{"FontColor":"e5e9f0","MainColor":"2e3440","AccentColor":"88c0d0","BackgroundColor":"242933","OutlineColor":"3b4252"}') },
		["Midnight"]      = { 16, httpService:JSONDecode('{"FontColor":"f5f7ff","MainColor":"151826","AccentColor":"4f7dff","BackgroundColor":"10121b","OutlineColor":"272c3f"}') },
		["Forest"]        = { 19, httpService:JSONDecode('{"FontColor":"e8f5e9","MainColor":"1b3124","AccentColor":"66bb6a","BackgroundColor":"15261c","OutlineColor":"294334"}') },
		["Crimson Night"] = { 20, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"2a0f1f","AccentColor":"e53935","BackgroundColor":"1a0a13","OutlineColor":"4b1f33"}') },
		["Iceberg"]       = { 21, httpService:JSONDecode('{"FontColor":"e0f4ff","MainColor":"1f2933","AccentColor":"5bc0eb","BackgroundColor":"151a23","OutlineColor":"324154"}') },
		["Lavender"]      = { 23, httpService:JSONDecode('{"FontColor":"f5e9ff","MainColor":"2a233a","AccentColor":"c792ea","BackgroundColor":"211a33","OutlineColor":"3a3150"}') }
	}

	local count = 0;

	for name, catppuchin_macchiato_color in {
		["Rosewater"] = "f4dbd6",
		["Flamingo"] = "f0c6c6",
		["Yellow"] = "eed49f",
		["Maroon"] = "ee99a0",
		["Green"] = "a6da95",
		["Peach"] = "f5a97f",
		["Mauve"] = "c6a0f6",
		["Pink"] = "f5bde6",
		["Teal"] = "8bd5ca",
		["Blue"] = "8aadf4",
		["Red"] = "ed8796",
		["Sky"] = "91d7e3",
	} do
		count += 1;
		ThemeManager.BuiltInThemes[name] = { 	
			23 + count, 
			{
				MainColor = "24273a",
				AccentColor = catppuchin_macchiato_color,
				OutlineColor="363a4f",
				BackgroundColor="1e2030",
				FontColor="e9edfa"
			} 
		};
	end;

	function ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local data = customThemeData or self.BuiltInThemes[theme]

		if not data then return end

		

		local scheme = data[2]
		for idx, col in next, customThemeData or scheme do
			self.Library[idx] = Color3.fromHex(col)
			
			if aztup_options[idx] then
				aztup_options[idx]:SetValueRGB(Color3.fromHex(col))
			end
		end

		self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()
		
		local aztup_options = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
		for i, field in next, aztup_options do
			if aztup_options and aztup_options[field] then
				self.Library[field] = aztup_options[field].Value
			end
		end

		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		self.Library:UpdateColorsUsingRegistry()
	end

	function ThemeManager:LoadDefault()		
		local theme = 'PR'
		local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')

		local isDefault = true
		if content then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isDefault = false;
			end
		elseif self.BuiltInThemes[self.DefaultTheme] then
		 	theme = self.DefaultTheme
		end

		if isDefault then
			aztup_options.ThemeManager_ThemeList:SetValue(theme)
		else
			self:ApplyTheme(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
		writefile(self.Folder .. '/themes/default.txt', theme)
	end

	function ThemeManager:CreateThemeManager(groupbox)
		groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
		groupbox:AddLabel('Main color')	:AddColorPicker('MainColor', { Default = self.Library.MainColor });
		groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor });
		groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor });
		groupbox:AddLabel('Font color')	:AddColorPicker('FontColor', { Default = self.Library.FontColor });

		local ThemesArray = {}
		for Name, Theme in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1, Searchable = true })

		groupbox:AddButton('Set as default', function()
			self:SaveDefault(aztup_options.ThemeManager_ThemeList.Value)
			self.Library:NotifyWithSound(string.format('Set default theme to %q', aztup_options.ThemeManager_ThemeList.Value))
		end)

		aztup_options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(aztup_options.ThemeManager_ThemeList.Value)
		end)

		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1, Searchable = true })
		groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })

		groupbox:AddButton('Load custom theme', function() 
			self:ApplyTheme(aztup_options.ThemeManager_CustomThemeList.Value) 
		end)

		groupbox:AddButton('Save custom theme', function() 
			self:SaveCustomTheme(aztup_options.ThemeManager_CustomThemeName.Value)

			aztup_options.ThemeManager_CustomThemeList.Values = self:ReloadCustomThemes()
			aztup_options.ThemeManager_CustomThemeList:SetValues()
			aztup_options.ThemeManager_CustomThemeList:SetValue(nil)
		end)
		local refresh_list_theme = function()
			aztup_options.ThemeManager_CustomThemeList.Values = self:ReloadCustomThemes()
			aztup_options.ThemeManager_CustomThemeList:SetValues()
			aztup_options.ThemeManager_CustomThemeList:SetValue(nil)
		end
		
		groupbox:AddButton('Refresh list', refresh_list_theme)
		getgenv().refresh_list_theme = refresh_list_theme;
		groupbox:AddButton('Set as default', function()
			if aztup_options.ThemeManager_CustomThemeList.Value ~= nil and aztup_options.ThemeManager_CustomThemeList.Value ~= '' then
				self:SaveDefault(aztup_options.ThemeManager_CustomThemeList.Value)
				self.Library:NotifyWithSound(string.format('Set default theme to %q', aztup_options.ThemeManager_CustomThemeList.Value))
			end
		end)

		ThemeManager:LoadDefault()

		local function UpdateTheme()
			self.Library.BackgroundColor = aztup_options.BackgroundColor.Value
			self.Library.OutlineColor = aztup_options.OutlineColor.Value
			self.Library.AccentColor = aztup_options.AccentColor.Value
			self.Library.FontColor = aztup_options.FontColor.Value
			self.Library.MainColor = aztup_options.MainColor.Value
			self:ThemeUpdate()
		end

		aztup_options.BackgroundColor:OnChanged(UpdateTheme)
		aztup_options.MainColor:OnChanged(UpdateTheme)
		aztup_options.AccentColor:OnChanged(UpdateTheme)
		aztup_options.OutlineColor:OnChanged(UpdateTheme)
		aztup_options.FontColor:OnChanged(UpdateTheme)
	end

	function ThemeManager:GetCustomTheme(file)
		local path = self.Folder .. '/themes/' .. file
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		local success, decoded = pcall(httpService.JSONDecode, httpService, data)
		
		if not success then
			return nil
		end

		return decoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(' ', '') == '' then
			return self.Library:Notify('Invalid file name for theme (empty)', 3)
		end

		local theme = {}
		local fields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }

		for _, field in next, fields do
			theme[field] = aztup_options[field].Value:ToHex()
		end

		writefile(self.Folder .. '/themes/' .. file .. '.json', httpService:JSONEncode(theme))
	end

	function ThemeManager:ReloadCustomThemes()
		local list = listfiles(self.Folder .. '/themes')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				

				local pos = file:find('.json', 1, true)
				local char = file:sub(pos, pos)

				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1))
				end
			end
		end

		return out
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib
	end

	function ThemeManager:BuildFolderTree()
		local paths = {}

		
		

		local parts = self.Folder:split('/')
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, '/', 1, idx)
		end

		table.insert(paths, self.Folder .. '/themes')
		table.insert(paths, self.Folder .. '/settings')

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		return tab:AddLeftGroupbox('Themes')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	ThemeManager:BuildFolderTree()
end
return ThemeManager