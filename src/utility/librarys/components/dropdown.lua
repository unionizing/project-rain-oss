



return function(Library, context)
	local InputService = context.InputService
	local Mouse = context.Mouse
	local ScreenGui = context.ScreenGui or Library.ScreenGui
	local TweenService = game:GetService('TweenService')

	local Component = {}

	local function getPlayersString()
		local PlayerList = game:GetService('Players'):GetPlayers()

		for i = 1, #PlayerList do
			PlayerList[i] = PlayerList[i].Name
		end

		table.sort(PlayerList, function(str1, str2) return str1 < str2 end)

		return PlayerList
	end

	local function getTeamsString()
		local TeamList = game:GetService('Teams'):GetTeams()

		for i = 1, #TeamList do
			TeamList[i] = TeamList[i].Name
		end

		table.sort(TeamList, function(str1, str2) return str1 < str2 end)

		return TeamList
	end

	function Component.AddDropdown(self, Idx, Info)
		Info.Searchable = if typeof(Info.Searchable) == 'boolean' then Info.Searchable else false
		if Info.SpecialType == 'Player' then
			Info.Values = getPlayersString()
			Info.AllowNull = true
		elseif Info.SpecialType == 'Team' then
			Info.Values = getTeamsString()
			Info.AllowNull = true
		end

		assert(Info.Values, 'AddDropdown: Missing dropdown value list.')
		assert(Info.AllowNull or Info.Default, 'AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.')

		if not Info.Text then
			Info.Compact = true
		end
		
		if self.Objects then
			table.insert(self.Objects, {
				internal_name = Idx, settings = Info
			})
		end;

		local Dropdown = {
			Values = Info.Values;
			Value = Info.Multi and {};
			Multi = Info.Multi;
			Type = 'Dropdown';
			Flag = Idx;
			SpecialType = Info.SpecialType;
			Callback = Info.Callback or function(_) end;
			Name = Info.Text
		}

		local Groupbox = self
		local Container = Groupbox.Container
		local RelativeOffset = 0

		if not Info.Compact then
			Library:CreateLabel({
				Size = UDim2.new(1, 0, 0, 10);
				TextSize = 14;
				Text = Info.Text;
				TextXAlignment = Enum.TextXAlignment.Left;
				TextYAlignment = Enum.TextYAlignment.Bottom;
				ZIndex = 5;
				Parent = Container;
			})

			Groupbox:AddBlank(3)
		end

		for _, Element in next, Container:GetChildren() do
			if not Element:IsA('UIListLayout') then
				RelativeOffset = RelativeOffset + Element.Size.Y.Offset
			end
		end

		
		
		
		
		
		local DropdownOuter = Library:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, -4, 0, 20);
			ZIndex = 5;
			Parent = Container;
		})

		Library:AddToRegistry(DropdownOuter, {
			BorderColor3 = 'Black';
		})

		local DropdownInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = DropdownOuter;
		})

		if type(Info.Text) == 'string' and Info.Text ~= '' then
			Library:RegisterSearchEntry(Groupbox, {
				Kind = 'Dropdown';
				Text = Info.Text;
				Tab = Groupbox.Tab or Groupbox;
				Target = DropdownOuter;
				Focus = function()
					Library:FocusSearchTarget(DropdownOuter)
				end;
			})
		end

		Library:AddToRegistry(DropdownInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		})

		local function SetChromeHidden(Hidden)
			DropdownOuter.BackgroundTransparency = Hidden and 1 or 0
			DropdownOuter.BorderSizePixel = Hidden and 0 or 1
			DropdownInner.BackgroundTransparency = Hidden and 1 or 0
			DropdownInner.BorderSizePixel = Hidden and 0 or 1
		end

		local MAX_DROPDOWN_ITEMS = 8
		local BUTTON_HEIGHT = 20

		local Overlay = Library:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			BorderMode = Enum.BorderMode.Inset;
			Visible = false;
			ZIndex = 20;
			Parent = ScreenGui;
		})

		Library:AddUIScale(Overlay)

		Library:AddToRegistry(Overlay, {
			BorderColor3 = 'Black';
		})

		local OverlayInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 21;
			Parent = Overlay;
		})

		Library:AddToRegistry(OverlayInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		})

		local ListOpened = false
		local ListContentHeight = MAX_DROPDOWN_ITEMS * 20

		local function RecalculateOverlay()
			local Height = BUTTON_HEIGHT + (ListOpened and ListContentHeight or 0)
			Overlay.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y)
			Overlay.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X / Library:GetUIScale(), ListOpened and Height - 3 or Height)
		end

		RecalculateOverlay()

		
		
		
		
		
		local DropdownInnerSearch
		if Info.Searchable then
			DropdownInnerSearch = Library:Create('TextBox', {
				BackgroundTransparency = 1;
				Visible = false;
				Position = UDim2.new(0, 5, 0, 0);
				Size = UDim2.new(0.9, -5, 0, BUTTON_HEIGHT);
				FontFace = Library.Font;
				PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
				PlaceholderText = 'Search...';
				Text = '';
				TextColor3 = Library.FontColor;
				TextSize = 14;
				TextStrokeTransparency = 0;
				TextXAlignment = Enum.TextXAlignment.Left;
				ClearTextOnFocus = false;
				ZIndex = 23;
				Parent = DropdownInner;
			})

			Library:ApplyTextStroke(DropdownInnerSearch)

			Library:AddToRegistry(DropdownInnerSearch, {
				TextColor3 = 'FontColor';
			})
		end

		local DropdownArrow = Library:Create('ImageLabel', {
			AnchorPoint = Vector2.new(0, 0.5);
			BackgroundTransparency = 1;
			Position = UDim2.new(1, -16, 0, BUTTON_HEIGHT / 2);
			Size = UDim2.new(0, 12, 0, 12);
			Image = 'http://www.roblox.com/asset/?id=6282522798';
			ZIndex = 7;
			Parent = DropdownInner;
		})

		local ItemList = Library:CreateLabel({
			Position = UDim2.new(0, 1, 0, 2);
			Size = UDim2.new(1, -1, 0, BUTTON_HEIGHT - 2);
			TextSize = 14;
			Text = 'Select...';
			TextXAlignment = Enum.TextXAlignment.Left;
			TextYAlignment = Enum.TextYAlignment.Top;
			TextWrapped = true;
			ZIndex = 8;
			Parent = DropdownInner;
		})

		if type(Info.Tooltip) == 'string' then
			Library:AddToolTip(Info.Tooltip, DropdownOuter)
		end

		local ListInner = Library:Create('Frame', {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 0, 0, BUTTON_HEIGHT);
			Size = UDim2.new(1, 0, 1, -BUTTON_HEIGHT);
			Visible = false;
			ZIndex = 21;
			Parent = OverlayInner;
		})

		DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
			RecalculateOverlay()
		end)

		DropdownOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
			RecalculateOverlay()
		end)

		Library:OnHighlight(DropdownOuter, DropdownOuter,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		)

		Library:OnHighlight(DropdownOuter, Overlay,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		)

		Library:OnHighlight(ListInner, Overlay,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		)

		local Scrolling = Library:Create('ScrollingFrame', {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			CanvasSize = UDim2.new(0, 0, 0, 0);
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 21;
			Parent = ListInner;

			TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
			BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',

			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Library.AccentColor,
		})

		Library:AddToRegistry(Scrolling, {
			ScrollBarImageColor3 = 'AccentColor'
		})

		Library:Create('UIListLayout', {
			Padding = UDim.new(0, 0);
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = Scrolling;
		})

		function Dropdown:Display()
			local Values = Dropdown.Values
			local Str = ''

			if Info.Multi then
				for _, Value in next, Values do
					if Dropdown.Value[Value] then
						Str = Str .. Value .. ', '
					end
				end

				Str = Str:sub(1, #Str - 2)
			else
				Str = Dropdown.Value or ''
			end

			ItemList.Text = (Str == '' and 'Select...' or Str)
			Library:UpdateDependencyBoxes()
		end

		function Dropdown:GetActiveValues()
			if Info.Multi then
				local T = {}
				for Value, _ in next, Dropdown.Value do
					table.insert(T, Value)
				end
				return T
			end

			return Dropdown.Value and 1 or 0
		end

		local built = false;
		function Dropdown:BuildDropdownList()
			local Values = Dropdown.Values
			local Buttons = {}

			for _, Element in next, Scrolling:GetChildren() do
				if not Element:IsA('UIListLayout') then
					Element:Destroy()
				end
			end

			local Count = 0
			local searchTerm = DropdownInnerSearch and string.lower(DropdownInnerSearch.Text)

			for _, Value in next, Values do
				if Info.Searchable and #searchTerm > 0 then
					local StringValue = typeof(Value) == 'Instance' and Value.Name or Value
					if not string.lower(StringValue):find(searchTerm, 1, true) then
						continue
					end
				end

				local ButtonState = {}
				Count = Count + 1

				local Button = Library:Create('Frame', {
					BackgroundColor3 = Library.OutlineColor;
					BackgroundTransparency = 1;
					BorderSizePixel = 0;
					Size = UDim2.new(1, -1, 0, 20);
					ZIndex = 23;
					Active = true;
					Parent = Scrolling;
				})

				Library:AddToRegistry(Button, {
					BackgroundColor3 = 'OutlineColor';
				})

				local ButtonLabel = Library:CreateLabel({
					Active = false;
					Size = UDim2.new(1, -6, 1, 0);
					Position = UDim2.new(0, 6, 0, 0);
					TextSize = 14;
					Text = Value;
					TextXAlignment = Enum.TextXAlignment.Left;
					ZIndex = 24;
					Parent = Button;
				})

				Library:OnHighlight(Button, Button,
					{ BackgroundTransparency = 0 },
					{ BackgroundTransparency = 1 }
				)

				local Selected = Info.Multi and Dropdown.Value[Value] or (Dropdown.Value == Value)

				function ButtonState:UpdateButton()
					if Info.Multi then
						Selected = Dropdown.Value[Value]
					else
						Selected = Dropdown.Value == Value
					end

					ButtonLabel.TextColor3 = Selected and Library.AccentColor or Library.FontColor
					Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or 'FontColor'
				end

				ButtonLabel.InputBegan:Connect(function(Input)
					if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end

					local Try = not Selected

					if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
						return
					end

					if Info.Multi then
						Selected = Try

						if Selected then
							Dropdown.Value[Value] = true
						else
							Dropdown.Value[Value] = nil
						end
					else
						Selected = Try

						if Selected then
							Dropdown.Value = Value
						else
							Dropdown.Value = nil
						end

						for _, OtherButton in next, Buttons do
							OtherButton:UpdateButton()
						end
					end

					ButtonState:UpdateButton()
					Dropdown:Display()

					Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
					Library:SafeCallback(Dropdown.Changed, Dropdown.Value)

					Library:AttemptSave()
				end)

				ButtonState:UpdateButton()
				Buttons[Button] = ButtonState
			end

			Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20) + 1)
			ListContentHeight = math.clamp(Count * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 8
			RecalculateOverlay()
			Dropdown:Display()
		end

		function Dropdown:SetValues(NewValues)
			if NewValues then
				Dropdown.Values = NewValues
			end

			
			Dropdown:BuildDropdownList()
		end

		function Dropdown:OpenDropdown()
			if Info.Searchable then
				ItemList.Visible = false
				DropdownInnerSearch.Text = ''
				DropdownInnerSearch.Visible = true
				DropdownInnerSearch.Parent = OverlayInner
			end

			DropdownArrow.Parent = OverlayInner
			ItemList.Parent = OverlayInner
			SetChromeHidden(true)

			ListOpened = true
			ListInner.Visible = true
			Overlay.Visible = true
			RecalculateOverlay()
			Library.OpenedFrames[ListInner] = true
			DropdownArrow.Rotation = 180
			ItemList.ZIndex = 22;
			DropdownArrow.ZIndex = 22;

			if not built then
				Dropdown:BuildDropdownList()
				built = true;
			end
		end

		function Dropdown:CloseDropdown()
			if Info.Searchable then
				DropdownInnerSearch.Text = ''
				DropdownInnerSearch.Visible = false
				ItemList.Visible = true
				DropdownInnerSearch.Parent = DropdownInner
			end
			ItemList.ZIndex = 7;
			DropdownArrow.ZIndex = 7;
			DropdownArrow.Parent = DropdownInner
			ItemList.Parent = DropdownInner
			SetChromeHidden(false)

			ListOpened = false
			ListInner.Visible = false
			Overlay.Visible = false
			RecalculateOverlay()
			Library.OpenedFrames[ListInner] = nil
			DropdownArrow.Rotation = 0
		end

		function Dropdown:OnChanged(Func)
			Dropdown.Changed = Func
			Func(Dropdown.Value)
		end

		function Dropdown:SetValue(Val, Skip)
			if Dropdown.Multi then
				local nTable = {}

				local is_skip = (
					Idx == 'blocked_timings' or
					Idx == 'automation_usage_mantras' or
					Idx == 'mantra_slidecasting_mantras' or
					Idx == 'action_rolling_mantras' or
					Idx == 'backstab_movestacker_mantras'
				)
				for Value, _ in next, Val do
					if is_skip or table.find(Dropdown.Values, Value) then
						if is_skip and not table.find(Dropdown.Values, Value) then
							table.insert(Dropdown.Values, Value)
						end
						nTable[Value] = true
					end
				end

				Dropdown.Value = nTable
			else
				if not Val then
					Dropdown.Value = nil
				elseif table.find(Dropdown.Values, Val) then
					Dropdown.Value = Val
				end
			end

			Dropdown:Display()
			Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
			Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
		end

		DropdownOuter.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
				if ListOpened then
					Dropdown:CloseDropdown()
				else
					Dropdown:OpenDropdown()
				end
			end
		end)

		if Info.Searchable then
			DropdownInnerSearch:GetPropertyChangedSignal('Text'):Connect(function()
				Dropdown:BuildDropdownList()
			end)
		end

		Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
			if not Library.Toggled or not ListOpened then
				return
			end

			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				local AbsPos, AbsSize = Overlay.AbsolutePosition, Overlay.AbsoluteSize
				if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
					or Mouse.Y < AbsPos.Y or Mouse.Y > AbsPos.Y + AbsSize.Y then
					Dropdown:CloseDropdown()
				end
			end
		end))

		local Defaults = {}

		if type(Info.Default) == 'string' then
			local defaultIndex = table.find(Dropdown.Values, Info.Default)
			if defaultIndex then
				table.insert(Defaults, defaultIndex)
			end
		elseif type(Info.Default) == 'table' then
			for _, Value in next, Info.Default do
				local defaultIndex = table.find(Dropdown.Values, Value)
				if defaultIndex then
					table.insert(Defaults, defaultIndex)
				end
			end
		elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
			table.insert(Defaults, Info.Default)
		end

		if next(Defaults) then
			for i = 1, #Defaults do
				local Index = Defaults[i]
				if Info.Multi then
					Dropdown.Value[Dropdown.Values[Index] ] = true
				else
					Dropdown.Value = Dropdown.Values[Index]
				end

				if not Info.Multi then
					break
				end
			end

			
			
		end

		Dropdown:BuildDropdownList()

		Groupbox:AddBlank(Info.BlankSize or 5)
		Groupbox:Resize()

		aztup_options[Idx] = Dropdown
		Library:UpdateDependencyBoxes()
		return Dropdown
	end

	return Component
end