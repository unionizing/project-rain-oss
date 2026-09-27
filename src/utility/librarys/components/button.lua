



return function(Library, context)
	local Component = {}

	local function processButtonParams(target, ...)
		local props = select(1, ...)
		if type(props) == 'table' then
			target.Text = props.Text
			target.Func = props.Func
			target.DoubleClick = props.DoubleClick
			target.Tooltip = props.Tooltip
		else
			target.Text = select(1, ...)
			target.Func = select(2, ...)
		end

		assert(type(target.Func) == 'function', 'AddButton: `Func` callback is missing.')
	end

	local function createBaseButton(button)
		local outer = Library:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, 20);
			ZIndex = 5;
		})

		local inner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = outer;
		})

		local label = Library:CreateLabel({
			Size = UDim2.new(1, 0, 1, 0);
			TextSize = 14;
			Text = button.Text;
			ZIndex = 6;
			Parent = inner;
		})

		
		
		
		
		
		
		
		

		Library:AddToRegistry(outer, { BorderColor3 = 'Black' })
		Library:AddToRegistry(inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' })

		Library:OnHighlight(outer, outer,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		)

		return outer, inner, label
	end

	local function initEvents(button)
		local function waitForEvent(event, timeout, validator)
			local bindable = Instance.new('BindableEvent')
			local connection = event:Once(function(...)
				if type(validator) == 'function' and validator(...) then
					bindable:Fire(true)
				else
					bindable:Fire(false)
				end
			end)
			task.delay(timeout, function()
				connection:disconnect()
				bindable:Fire(false)
			end)
			return bindable.Event:Wait()
		end

		local function validateClick(input)
			if not Library.Toggled then
				return false
			end
			
			if Library:MouseIsOverOpenedFrame() then
				return false
			end

			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return false
			end

			return true
		end

		button.Outer.InputBegan:Connect(function(input)
			if not validateClick(input) or button.Locked then
				return
			end

			if button.DoubleClick then
				Library:RemoveFromRegistry(button.Label)
				Library:AddToRegistry(button.Label, { TextColor3 = 'AccentColor' })

				
				button.Label.Text = 'Are you sure?'
				button.Locked = true

				services.TweenService:Create(button.Label, TweenInfo.new(0.125), {
					TextColor3 = Library.AccentColor
				}):Play();

				task.wait(0.125);

				local clicked = waitForEvent(button.Outer.InputBegan, 2, validateClick)

				Library:RemoveFromRegistry(button.Label)
				Library:AddToRegistry(button.Label, { TextColor3 = 'FontColor' })

				button.Label.TextColor3 = Library.FontColor
				button.Label.Text = button.Text
				task.defer(rawset, button, 'Locked', false)

				if clicked then
					Library:SafeCallback(button.Func)
				end

				return
			end

			Library:SafeCallback(button.Func)
		end)
	end

	function Component.AddButton(self, ...)
		local button = {}
		processButtonParams(button, ...)

		if self.Objects then
			table.insert(self.Objects, {
				internal_name = "button_" .. tostring(#self.Objects + 1), settings = {
					Text = button.Text;
					Tooltip = button.Tooltip;
				}, Type = "Button"
			})
		end

		local groupbox = self
		local container = groupbox.Container

		button.Outer, button.Inner, button.Label = createBaseButton(button)
		button.Outer.Parent = container

		initEvents(button)

		function button:AddTooltip(tooltip)
			if type(tooltip) == 'string' then
				Library:AddToolTip(tooltip, self.Outer)
			end
			return self
		end

		function button:AddButton(...)
			local subButton = {}
			processButtonParams(subButton, ...)

			self.Outer.Size = UDim2.new(0.5, -2, 0, 20)

			subButton.Outer, subButton.Inner, subButton.Label = createBaseButton(subButton)
			subButton.Outer.Position = UDim2.new(1, 3, 0, 0)
			subButton.Outer.Size = UDim2.fromOffset(self.Outer.AbsoluteSize.X / Library:GetUIScale() - 2, self.Outer.AbsoluteSize.Y / Library:GetUIScale())
			subButton.Outer.Parent = self.Outer

			function subButton:AddTooltip(tooltip)
				if type(tooltip) == 'string' then
					Library:AddToolTip(tooltip, self.Outer)
				end
				return subButton
			end

			Library:RegisterSearchEntry(groupbox, {
				Kind = 'Button';
				Text = subButton.Text;
				Target = subButton.Outer;
			})

			if type(subButton.Tooltip) == 'string' then
				subButton:AddTooltip(subButton.Tooltip)
			end

			initEvents(subButton)
			return subButton
		end

		if type(button.Tooltip) == 'string' then
			button:AddTooltip(button.Tooltip)
		end

		groupbox:AddBlank(5)
		groupbox:Resize()

		return button
	end

	function Component.AddDivider(self)
		local groupbox = self
		local container = self.Container

		groupbox:AddBlank(2)
		local dividerOuter = Library:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, 5);
			ZIndex = 5;
			Parent = container;
		})

		local dividerInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = dividerOuter;
		})

		Library:AddToRegistry(dividerOuter, { BorderColor3 = 'Black' })
		Library:AddToRegistry(dividerInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor' })

		groupbox:AddBlank(9)
		groupbox:Resize()
end

	return Component
end