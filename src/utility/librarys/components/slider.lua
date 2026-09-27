

return function(Library, context)
	local InputService = context.InputService
	local Mouse = context.Mouse
	local RenderStepped = context.RenderStepped
	local TweenService = game:GetService('TweenService')

	local Component = {}

	local function createRounder(rounding)
		return function(value)
			if rounding == 0 then
				return math.floor(value)
			end
			return tonumber(string.format('%.' .. tostring(rounding) .. 'f', value))
		end
	end

	local function createSizeTweener()
		local activeTween

		return function(frame, size)
			if frame.Size == size then
				return
			end

			if activeTween then
				activeTween:Cancel()
				activeTween = nil
			end

			local tween = TweenService:Create(frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = size;
			}) 
			activeTween = tween
			tween.Completed:Connect(function()
				if activeTween == tween then
					activeTween = nil
				end
			end)
			tween:Play()
		end
	end

	function Component.AddSlider(self, Idx, Info)
		assert(Info.Default ~= nil, 'AddSlider: Missing default value.')
		assert(Info.Text,    'AddSlider: Missing slider text.')
		assert(Info.Min ~= nil,     'AddSlider: Missing minimum value.')
		assert(Info.Max ~= nil,     'AddSlider: Missing maximum value.')
		assert(Info.Rounding ~= nil, 'AddSlider: Missing rounding value.')

		local Slider = {
			Value    = Info.Default;
			Min      = Info.Min;
			Max      = Info.Max;
			Rounding = Info.Rounding;
			MaxSize  = 232;
			Type     = 'Slider';

			Text     = Info.Text;
			Prefix   = type(Info.Prefix) == "string" and Info.Prefix or "";
			Suffix   = type(Info.Suffix) == "string" and Info.Suffix or "";

			Visible  = (type(Info.Visible)  == "boolean") and Info.Visible  or true;
			Disabled = (type(Info.Disabled) == "boolean") and Info.Disabled or false;

			Callback = Info.Callback or function(_) end;
			Changed  = Info.Changed  or function(_) end;
			Compact  = not not Info.Compact;
			HideMax  = not not Info.HideMax;
			Tooltip  = Info.Tooltip;
		}

		if self.Objects then
			table.insert(self.Objects, {
				internal_name = Idx, settings = Info, Type = "Slider"
			})
		end

		local Groupbox  = self
		local Container = Groupbox.Container

		if not Slider.Compact then
			Library:CreateLabel({
				Size = UDim2.new(1, 0, 0, 10);
				TextSize = 14;
				Text = Slider.Text;
				TextXAlignment = Enum.TextXAlignment.Left;
				TextYAlignment = Enum.TextYAlignment.Bottom;
				Visible = Slider.Visible;
				ZIndex = 5;
				Parent = Container;
			})
			Groupbox:AddBlank(3, Slider.Visible);
		end

		local SliderOuter = Library:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, 13);
			Visible = Slider.Visible;
			ZIndex = 5;
			Parent = Container;
		})

		Library:RegisterSearchEntry(Groupbox, {
			Kind = 'Slider';
			Text = Slider.Text;
			Target = SliderOuter;
		})

		SliderOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
			Slider.MaxSize = math.max(0, math.floor(SliderOuter.AbsoluteSize.X / Library:GetUIScale() + 0.5) - 2)
		end)

		Library:AddToRegistry(SliderOuter, { BorderColor3 = 'Black' })

		local SliderInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = SliderOuter;
		})

		Library:AddToRegistry(SliderInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		})

		local Fill = Library:Create('Frame', {
			BackgroundColor3 = Library.AccentColor;
			BorderColor3 = Library.AccentColorDark;
			Size = UDim2.new(0, 0, 1, 0);
			ZIndex = 7;
			Parent = SliderInner;
		})

		Library:AddToRegistry(Fill, {
			BackgroundColor3 = 'AccentColor';
			BorderColor3 = 'AccentColorDark';
		})

		local HideBorderRight = Library:Create('Frame', {
			BackgroundColor3 = Library.AccentColor;
			BorderSizePixel = 0;
			Position = UDim2.new(1, 0, 0, 0);
			Size = UDim2.new(0, 1, 1, 0);
			ZIndex = 8;
			Parent = Fill;
		})

		Library:AddToRegistry(HideBorderRight, { BackgroundColor3 = 'AccentColor' })

		local DisplayLabel = Library:CreateLabel({
			Size = UDim2.new(1, 0, 1, 0);
			TextSize = 14;
			Text = 'Infinite';
			ZIndex = 9;
			Parent = SliderInner;
		})

		local ValueBox = Library:Create('TextBox', {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			ClearTextOnFocus = false;
			FontFace = Library.Font;
			Position = UDim2.new(0, 0, 0, 0);
			PlaceholderText = '';
			Size = UDim2.new(1, 0, 1, 0);
			Text = '';
			TextColor3 = Library.FontColor;
			TextSize = 14;
			TextStrokeTransparency = 0;
			TextXAlignment = Enum.TextXAlignment.Center;
			TextYAlignment = Enum.TextYAlignment.Center;
			Visible = false;
			ZIndex = 10;
			Parent = SliderInner;
		})

		Library:AddToRegistry(ValueBox, { TextColor3 = 'FontColor' })

		local IsTypingValue = false
		local UpdateDisplay
		local ApplyValue
		local TweenFillSize = createSizeTweener()

		local Round = createRounder(Slider.Rounding)

		local function FinishTyping(commit)
			if not IsTypingValue then return end
			IsTypingValue = false
			ValueBox.Visible = false
			DisplayLabel.Visible = true

			if commit then
				local typedValue = tonumber(ValueBox.Text)
				if typedValue then
					ApplyValue(typedValue)
				else
					UpdateDisplay()
				end
			else
				UpdateDisplay()
			end

			Library:AttemptSave()
		end

		local function BeginTyping()
			if Slider.Disabled or IsTypingValue then return end
			IsTypingValue = true
			ValueBox.Text = tostring(Slider.Value)
			ValueBox.Visible = true
			DisplayLabel.Visible = false
			pcall(function()
				ValueBox:CaptureFocus()
				ValueBox.CursorPosition = #ValueBox.Text + 1
			end)
		end

		ValueBox.FocusLost:Connect(function(enterPressed)
			FinishTyping(enterPressed)
		end)

		UpdateDisplay = function()
			local left = (Slider.Prefix or "")
			local right = (Slider.Suffix or "")

			local value = tostring(Round(Slider.Value))
			if not IsTypingValue then
				if Slider.Compact then
					DisplayLabel.Text = string.format('%s%s%s', Slider.Text .. ': ', value, right)
				elseif Slider.HideMax then
					DisplayLabel.Text = string.format('%s%s', value, right)
				else
					DisplayLabel.Text = string.format('%s%s/%s%s', left, value, tostring(Slider.Max), right)
				end
			else
				ValueBox.Text = tostring(Slider.Value)
			end

			local X = math.ceil(Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Slider.MaxSize))
			
			TweenFillSize(Fill, UDim2.new(0, X, 1, 0))
			HideBorderRight.Visible = not (X == Slider.MaxSize or X == 0)

			SliderInner.Visible = Slider.Visible
			SliderOuter.Visible = Slider.Visible
			DisplayLabel.Visible = Slider.Visible and not IsTypingValue
			ValueBox.Visible = Slider.Visible and IsTypingValue
		end

		ApplyValue = function(numOrStr)
			local Num = tonumber(numOrStr)
			if not Num then return end
			Num = math.clamp(Num, Slider.Min, Slider.Max)
			local old = Slider.Value
			Slider.Value = Num
			UpdateDisplay()
			if not Slider.Disabled and Num ~= old then
				Library:SafeCallback(Slider.Callback, Slider.Value)
				Library:SafeCallback(Slider.Changed, Slider.Value)
			end
		end

		Library:OnHighlight(SliderOuter, SliderOuter,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		)

		if type(Slider.Tooltip) == 'string' then
			Library:AddToolTip(Slider.Tooltip, SliderOuter)
		end

		function Slider:UpdateColors()
			Fill.BackgroundColor3 = Library.AccentColor
			Fill.BorderColor3     = Library.AccentColorDark
		end

		function Slider:GetValueFromXScale(scale)
			return Round(Library:MapValue(scale, 0, 1, Slider.Min, Slider.Max))
		end

		function Slider:GetValueFromXOffset(px)
			return Round(Library:MapValue(px, 0, Slider.MaxSize, Slider.Min, Slider.Max))
		end

		function Slider:Display()
			UpdateDisplay()
		end

		function Slider:SetValue(numOrStr)
			ApplyValue(numOrStr)
		end

		function Slider:SetText(t) if type(t) == "string" then Slider.Text = t; Slider:Display() end end
		function Slider:SetPrefix(p) if type(p) == "string" then Slider.Prefix = p; Slider:Display() end end
		function Slider:SetSuffix(s) if type(s) == "string" then Slider.Suffix = s; Slider:Display() end end
		function Slider:SetVisible(v) Slider.Visible = not not v; Slider:Display(); Groupbox:Resize() end
		function Slider:SetDisabled(d) Slider.Disabled = not not d; Slider:UpdateColors() end

		function Slider:OnChanged(Func)
			Slider.Changed = Func
			pcall(Func, Slider.Value)
		end

		SliderInner.InputBegan:Connect(function(Input)
			if Slider.Disabled then return end
			if Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
				BeginTyping()
			elseif Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() and not IsTypingValue then
				local FillStartX = Fill.AbsolutePosition.X

				while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local nX = math.clamp((Mouse.X - FillStartX) / Library:GetUIScale(), 0, Slider.MaxSize)
					local nValue = Slider:GetValueFromXOffset(nX)
					local old = Slider.Value
					Slider.Value = nValue

					Slider:Display()

					if nValue ~= old then
						Library:SafeCallback(Slider.Callback, Slider.Value)
						Library:SafeCallback(Slider.Changed, Slider.Value)
					end

					RenderStepped:Wait()
				end

				Library:AttemptSave()
			end
		end)

		Slider:Display()
		Groupbox:AddBlank(Info.BlankSize or 6)
		Groupbox:Resize()

		aztup_options[Idx] = Slider
		Library:UpdateDependencyBoxes()
		return Slider
	end

	function Component.AddMinMaxSlider(self, Idx, Info)
		assert(Info.Text, 'AddMinMaxSlider: Missing slider text.')
		assert(Info.Min ~= nil, 'AddMinMaxSlider: Missing minimum value.')
		assert(Info.Max ~= nil, 'AddMinMaxSlider: Missing maximum value.')
		assert(Info.Rounding ~= nil, 'AddMinMaxSlider: Missing rounding value.')

		local defaultMin, defaultMax
		if type(Info.Default) == 'table' then
			defaultMin = Info.Default.Min or Info.Default[1]
			defaultMax = Info.Default.Max or Info.Default[2]
		end
		if defaultMin == nil then
			defaultMin = Info.DefaultMin
		end
		if defaultMax == nil then
			defaultMax = Info.DefaultMax
		end

		local minVal = tonumber(defaultMin) or Info.Min
		local maxVal = tonumber(defaultMax) or Info.Max

		minVal = math.clamp(minVal, Info.Min, Info.Max)
		maxVal = math.clamp(maxVal, Info.Min, Info.Max)
		if minVal > maxVal then
			minVal, maxVal = maxVal, minVal
		end

		local rangeValue = {
			Min = minVal;
			Max = maxVal;
		}

		local MinMaxSlider = {
			Value = rangeValue;
			Min = Info.Min;
			Max = Info.Max;
			Rounding = Info.Rounding;
			MaxSize = 232;
			Type = 'MinMaxSlider';

			Text = Info.Text;
			Prefix = type(Info.Prefix) == "string" and Info.Prefix or "";
			Suffix = type(Info.Suffix) == "string" and Info.Suffix or "";

			Visible = (type(Info.Visible) == "boolean") and Info.Visible or true;
			Disabled = (type(Info.Disabled) == "boolean") and Info.Disabled or false;

			Callback = Info.Callback or function(_) end;
			Changed = Info.Changed or function(_) end;
			Compact = not not Info.Compact;
			Tooltip = Info.Tooltip;
		}

		local Groupbox = self
		local Container = Groupbox.Container

		if not MinMaxSlider.Compact then
			Library:CreateLabel({
				Size = UDim2.new(1, 0, 0, 10);
				TextSize = 14;
				Text = MinMaxSlider.Text;
				TextXAlignment = Enum.TextXAlignment.Left;
				TextYAlignment = Enum.TextYAlignment.Bottom;
				Visible = MinMaxSlider.Visible;
				ZIndex = 5;
				Parent = Container;
			})
			Groupbox:AddBlank(3, MinMaxSlider.Visible);
		end

		local SliderOuter = Library:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, 13);
			Visible = MinMaxSlider.Visible;
			ZIndex = 5;
			Parent = Container;
		})

		Library:RegisterSearchEntry(Groupbox, {
			Kind = 'MinMaxSlider';
			Text = MinMaxSlider.Text;
			Target = SliderOuter;
		})

		SliderOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
			MinMaxSlider.MaxSize = math.max(0, math.floor(SliderOuter.AbsoluteSize.X / Library:GetUIScale() + 0.5) - 2)
		end)

		Library:AddToRegistry(SliderOuter, { BorderColor3 = 'Black' })

		local SliderInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = SliderOuter;
		})

		Library:AddToRegistry(SliderInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		})

		local RangeFill = Library:Create('Frame', {
			BackgroundColor3 = Library.AccentColor;
			BorderColor3 = Library.AccentColorDark;
			Size = UDim2.new(0, 0, 1, 0);
			ZIndex = 7;
			Parent = SliderInner;
		})

		Library:AddToRegistry(RangeFill, {
			BackgroundColor3 = 'AccentColor';
			BorderColor3 = 'AccentColorDark';
		})

		local HideBorderLeft = Library:Create('Frame', {
			BackgroundColor3 = Library.AccentColor;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 0, 0, 0);
			Size = UDim2.new(0, 1, 1, 0);
			ZIndex = 8;
			Parent = RangeFill;
		})

		local HideBorderRight = Library:Create('Frame', {
			BackgroundColor3 = Library.AccentColor;
			BorderSizePixel = 0;
			Position = UDim2.new(1, 0, 0, 0);
			Size = UDim2.new(0, 1, 1, 0);
			ZIndex = 8;
			Parent = RangeFill;
		})

		Library:AddToRegistry(HideBorderLeft, { BackgroundColor3 = 'AccentColor' })
		Library:AddToRegistry(HideBorderRight, { BackgroundColor3 = 'AccentColor' })

		local MinHandle = Library:Create('Frame', {
			BackgroundColor3 = Library.AccentColorDark;
			BorderSizePixel = 0;
			AnchorPoint = Vector2.new(0.5, 0);
			Size = UDim2.new(0, 2, 1, 0);
			ZIndex = 9;
			Parent = SliderInner;
		})

		local MaxHandle = Library:Create('Frame', {
			BackgroundColor3 = Library.AccentColorDark;
			BorderSizePixel = 0;
			AnchorPoint = Vector2.new(0.5, 0);
			Size = UDim2.new(0, 2, 1, 0);
			ZIndex = 9;
			Parent = SliderInner;
		})

		Library:AddToRegistry(MinHandle, { BackgroundColor3 = 'AccentColorDark' })
		Library:AddToRegistry(MaxHandle, { BackgroundColor3 = 'AccentColorDark' })

		local DisplayLabel = Library:CreateLabel({
			Size = UDim2.new(1, 0, 1, 0);
			TextSize = 14;
			Text = 'Infinite';
			ZIndex = 9;
			Parent = SliderInner;
		})

		Library:OnHighlight(SliderOuter, SliderOuter,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		)

		if type(MinMaxSlider.Tooltip) == 'string' then
			Library:AddToolTip(MinMaxSlider.Tooltip, SliderOuter)
		end

		function MinMaxSlider:UpdateColors()
			RangeFill.BackgroundColor3 = Library.AccentColor
			RangeFill.BorderColor3 = Library.AccentColorDark
			MinHandle.BackgroundColor3 = Library.AccentColorDark
			MaxHandle.BackgroundColor3 = Library.AccentColorDark
		end

		local Round = createRounder(MinMaxSlider.Rounding)
		local TweenRangeFillSize = createSizeTweener()

		function MinMaxSlider:GetValueFromXOffset(px)
			return Round(Library:MapValue(px, 0, MinMaxSlider.MaxSize, MinMaxSlider.Min, MinMaxSlider.Max))
		end

		function MinMaxSlider:Display()
			local left = (MinMaxSlider.Prefix or "")
			local right = (MinMaxSlider.Suffix or "")
			local minText = string.format('%s%s%s', left, tostring(MinMaxSlider.Value.Min), right)
			local maxText = string.format('%s%s%s', left, tostring(MinMaxSlider.Value.Max), right)

			if MinMaxSlider.Compact then
				DisplayLabel.Text = string.format('%s%s - %s', MinMaxSlider.Text .. ': ', minText, maxText)
			else
				DisplayLabel.Text = string.format('%s - %s', minText, maxText)
			end

			local minX = math.ceil(Library:MapValue(MinMaxSlider.Value.Min, MinMaxSlider.Min, MinMaxSlider.Max, 0, MinMaxSlider.MaxSize))
			local maxX = math.ceil(Library:MapValue(MinMaxSlider.Value.Max, MinMaxSlider.Min, MinMaxSlider.Max, 0, MinMaxSlider.MaxSize))

			if maxX < minX then
				minX, maxX = maxX, minX
			end

			local width = math.max(0, maxX - minX)
			RangeFill.Position = UDim2.new(0, minX, 0, 0)
			RangeFill.Size =  UDim2.new(0, width, 1, 0)
			HideBorderLeft.Visible = not (minX == 0 or width == 0)
			HideBorderRight.Visible = not (maxX == MinMaxSlider.MaxSize or width == 0)

			MinHandle.Position = UDim2.new(0, minX, 0, 0)
			MaxHandle.Position = UDim2.new(0, maxX, 0, 0)

			SliderInner.Visible = MinMaxSlider.Visible
			SliderOuter.Visible = MinMaxSlider.Visible
		end

		function MinMaxSlider:SetValue(range)
			if type(range) ~= 'table' then return end
			local newMin = tonumber(range.Min or range[1])
			local newMax = tonumber(range.Max or range[2])
			if not newMin or not newMax then return end
			newMin = math.clamp(newMin, MinMaxSlider.Min, MinMaxSlider.Max)
			newMax = math.clamp(newMax, MinMaxSlider.Min, MinMaxSlider.Max)
			if newMin > newMax then
				newMin, newMax = newMax, newMin
			end
			local oldMin, oldMax = MinMaxSlider.Value.Min, MinMaxSlider.Value.Max
			MinMaxSlider.Value.Min = newMin
			MinMaxSlider.Value.Max = newMax
			MinMaxSlider:Display()
			if not MinMaxSlider.Disabled and (newMin ~= oldMin or newMax ~= oldMax) then
				Library:SafeCallback(MinMaxSlider.Callback, MinMaxSlider.Value)
				Library:SafeCallback(MinMaxSlider.Changed, MinMaxSlider.Value)
			end
		end

		function MinMaxSlider:SetText(t) if type(t) == "string" then MinMaxSlider.Text = t; MinMaxSlider:Display() end end
		function MinMaxSlider:SetPrefix(p) if type(p) == "string" then MinMaxSlider.Prefix = p; MinMaxSlider:Display() end end
		function MinMaxSlider:SetSuffix(s) if type(s) == "string" then MinMaxSlider.Suffix = s; MinMaxSlider:Display() end end
		function MinMaxSlider:SetVisible(v) MinMaxSlider.Visible = not not v; MinMaxSlider:Display(); Groupbox:Resize() end
		function MinMaxSlider:SetDisabled(d) MinMaxSlider.Disabled = not not d; MinMaxSlider:UpdateColors() end

		function MinMaxSlider:OnChanged(Func)
			MinMaxSlider.Changed = Func
			pcall(Func, MinMaxSlider.Value)
		end

		SliderInner.InputBegan:Connect(function(Input)
			if MinMaxSlider.Disabled then return end
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
				local innerX = SliderInner.AbsolutePosition.X
				local minX = math.ceil(Library:MapValue(MinMaxSlider.Value.Min, MinMaxSlider.Min, MinMaxSlider.Max, 0, MinMaxSlider.MaxSize))
				local maxX = math.ceil(Library:MapValue(MinMaxSlider.Value.Max, MinMaxSlider.Min, MinMaxSlider.Max, 0, MinMaxSlider.MaxSize))
				local mouseX = math.clamp((Mouse.X - innerX) / Library:GetUIScale(), 0, MinMaxSlider.MaxSize)
				local dragTarget = (math.abs(mouseX - minX) <= math.abs(mouseX - maxX)) and 'Min' or 'Max'

				while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local nX = math.clamp((Mouse.X - innerX) / Library:GetUIScale(), 0, MinMaxSlider.MaxSize)
					local nValue = MinMaxSlider:GetValueFromXOffset(nX)
					local oldMin, oldMax = MinMaxSlider.Value.Min, MinMaxSlider.Value.Max

					if dragTarget == 'Min' then
						if nValue > MinMaxSlider.Value.Max then
							MinMaxSlider.Value.Min = MinMaxSlider.Value.Max
							MinMaxSlider.Value.Max = nValue
							dragTarget = 'Max'
						else
							MinMaxSlider.Value.Min = nValue
						end
					else
						if nValue < MinMaxSlider.Value.Min then
							MinMaxSlider.Value.Max = MinMaxSlider.Value.Min
							MinMaxSlider.Value.Min = nValue
							dragTarget = 'Min'
						else
							MinMaxSlider.Value.Max = nValue
						end
					end

					MinMaxSlider:Display()

					if MinMaxSlider.Value.Min ~= oldMin or MinMaxSlider.Value.Max ~= oldMax then
						Library:SafeCallback(MinMaxSlider.Callback, MinMaxSlider.Value)
						Library:SafeCallback(MinMaxSlider.Changed, MinMaxSlider.Value)
					end

					RenderStepped:Wait()
				end

				Library:AttemptSave()
			end
		end)

		MinMaxSlider:Display()
		Groupbox:AddBlank(Info.BlankSize or 6)
		Groupbox:Resize()

		aztup_options[Idx] = MinMaxSlider
		Library:UpdateDependencyBoxes()
		return MinMaxSlider
	end

	return Component
end  