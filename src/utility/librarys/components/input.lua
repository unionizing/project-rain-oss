



return function(Library, context)
	local TextService = context.TextService
	local Component = {}

	function Component.AddInput(self, Idx, Info)
		assert(Info.Text, 'AddInput: Missing `Text` string.')

		local Textbox = {
			Value = Info.Default or '';
			Numeric = Info.Numeric or false;
			Finished = Info.Finished or false;
			Type = 'Input';
			Callback = Info.Callback or function(Value) end;
		}

		local Groupbox = self
		local Container = Groupbox.Container

		if not Info.NoLabel then
			Library:CreateLabel({
				Size = UDim2.new(1, 0, 0, 15);
				TextSize = 14;
				Text = Info.Text;
				TextXAlignment = Enum.TextXAlignment.Left;
				ZIndex = 5;
				Parent = Container;
			})
		end

		Groupbox:AddBlank(1)

		local TextBoxOuter = Library:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(1, -4, 0, 20);
			ZIndex = 5;
			Parent = Container;
		})

		local TextBoxInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = TextBoxOuter;
		})

		Library:AddToRegistry(TextBoxInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		})

		Library:OnHighlight(TextBoxOuter, TextBoxOuter,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		)

		if type(Info.Tooltip) == 'string' then
			Library:AddToolTip(Info.Tooltip, TextBoxOuter)
		end

		
		
		
		
		
		
		
		

		local ContainerFrame = Library:Create('Frame', {
			BackgroundTransparency = 1;
			ClipsDescendants = true;

			Position = UDim2.new(0, 5, 0, 0);
			Size = UDim2.new(1, -5, 1, 0);

			ZIndex = 7;
			Parent = TextBoxInner;
		})

		local Box = Library:Create('TextBox', {
			BackgroundTransparency = 1;

			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromScale(5, 1),

			FontFace = Library.Font;
			PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
			PlaceholderText = Info.Placeholder or '';

			Text = Info.Default or '';
			TextColor3 = Library.FontColor;
			TextSize = 14;
			TextStrokeTransparency = 0;
			TextXAlignment = Enum.TextXAlignment.Left;
			ClearTextOnFocus = false;

			ZIndex = 7;
			Parent = ContainerFrame;
		})

		Library:ApplyTextStroke(Box)

		function Textbox:SetValue(Text)
			if Info.MaxLength and #Text > Info.MaxLength then
				Text = Text:sub(1, Info.MaxLength)
			end

			if Textbox.Numeric then
				if (not tonumber(Text)) and Text:len() > 0 then
					Text = Textbox.Value
				end
			end

			Textbox.Value = Text
			Box.Text = Text

			Library:SafeCallback(Textbox.Callback, Textbox.Value)
			Library:SafeCallback(Textbox.Changed, Textbox.Value)
		end

		if Textbox.Finished then
			Box.FocusLost:Connect(function(enter)
				if not enter then return end

				Textbox:SetValue(Box.Text)
				Library:AttemptSave()
			end)
		else
			Box:GetPropertyChangedSignal('Text'):Connect(function()
				Textbox:SetValue(Box.Text)
				Library:AttemptSave()
			end)
		end

		local function Update()
			local PADDING = 2
			
			local reveal = ContainerFrame.AbsoluteSize.X / Library:GetUIScale()

			if not Box:IsFocused() or Box.TextBounds.X / Library:GetUIScale() <= reveal - 2 * PADDING then
				Box.Position = UDim2.new(0, PADDING, 0, 0)
			else
				local cursor = Box.CursorPosition
				if cursor ~= -1 then
					local subtext = string.sub(Box.Text, 1, cursor - 1)
					local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X
					local currentCursorPos = Box.Position.X.Offset + width

					if currentCursorPos < PADDING then
						Box.Position = UDim2.fromOffset(PADDING - width, 0)
					elseif currentCursorPos > reveal - PADDING - 1 then
						Box.Position = UDim2.fromOffset(reveal - width - PADDING - 1, 0)
					end
				end
			end
		end

		task.spawn(function() pcall(Update) end)

		Box:GetPropertyChangedSignal('Text'):Connect(Update)
		Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)
		Box.FocusLost:Connect(Update)
		Box.Focused:Connect(Update)

		Library:AddToRegistry(Box, { TextColor3 = 'FontColor' })

		function Textbox:OnChanged(Func)
			Textbox.Changed = Func
			Func(Textbox.Value)
		end

		Groupbox:AddBlank(5)
		Groupbox:Resize()

		aztup_options[Idx] = Textbox

		return Textbox
	end

	return Component
end