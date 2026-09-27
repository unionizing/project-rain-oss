

return function(Library, context)
	local ScreenGui = context.ScreenGui or Library.ScreenGui
	local Mouse = context.Mouse
	local TweenService = context.TweenService or game:GetService('TweenService')

	local Component = {}

	local NotificationArea = Library:Create('Frame', {
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new(0, 0, 0, 40);
		Size = UDim2.fromOffset(320, 0);
		ZIndex = 90;
		Parent = ScreenGui;
	})

	Library.NotificationArea = NotificationArea
	Library:AddUIScale(NotificationArea)

	Library:Create('UIListLayout', {
		Padding = UDim.new(0, 4);
		FillDirection = Enum.FillDirection.Vertical;
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = NotificationArea;
	})

	local WatermarkOuter = Library:Create('Frame', {
		Position = UDim2.new(0, 24, 1, -48);
		Size = UDim2.new(0, 120, 0, 28);
		BackgroundColor3 = Library.AccentColor;
		BorderSizePixel = 1;
		ZIndex = 200;
		Visible = false;
		Parent = ScreenGui;
	})

	Library:AddUIScale(WatermarkOuter)

	WatermarkOuter.MouseEnter:Connect(function()
		Library.RequestingMouse = true
	end)

	WatermarkOuter.MouseLeave:Connect(function()
		Library.RequestingMouse = false
	end)

	Library:AddToRegistry(WatermarkOuter, {
		BackgroundColor3 = 'AccentColor';
	}, true)

	local WatermarkInner = Library:Create('Frame', {
		Size = UDim2.new(1, -2, 1, -2);
		Position = UDim2.new(0, 1, 0, 1);
		BackgroundColor3 = Library.MainColor;
		BorderSizePixel = 0;
		ZIndex = 201;
		Parent = WatermarkOuter;
	})

	Library:AddToRegistry(WatermarkInner, {
		BackgroundColor3 = 'MainColor';
	}, true)

	local WatermarkText = Library:Create('TextLabel', {
		Position = UDim2.new(0, 6, 0, 0);
		Size = UDim2.new(1, -10, 1, 0);
		BorderSizePixel = 0;
		BackgroundTransparency = 1;
		Text = '';
		TextColor3 = Library.FontColor;
		TextSize = 16;
		TextXAlignment = Enum.TextXAlignment.Left;
		TextStrokeTransparency = 1;
		AutoLocalize = false;
		RichText = true;
		ZIndex = 202;
		Parent = WatermarkInner;
	})

	task.spawn(function()
		WatermarkText.FontFace = lexend.regular;
	end);

	Library:ApplyTextStroke(WatermarkText)

	Library:AddToRegistry(WatermarkText, {
		TextColor3 = 'FontColor';
	}, true)

	Library.Watermark = WatermarkOuter
	Library.WatermarkText = WatermarkText
	Library:MakeDraggable(Library.Watermark)

	function Library:SetWatermarkVisibility(Bool)
		Library.Watermark.Visible = Bool
	end

	function Library:SetWatermark(Text, RText)
		if not Library.Watermark.Visible then
			return
		end

		
		local Scale = Library:GetUIScale()
		local X = Library:GetLexendTextBounds(RText, lexend.regular, 16 * Scale) / Scale
		Library.Watermark.Size = UDim2.new(0, X + 12, 0, 28)
		Library.WatermarkText.Text = Text
			
		local old_pos = Library.Watermark.Position;

		if old_pos.X.Scale > 0.4 and old_pos.X.Scale < 0.6 then
			Library.Watermark.Position = UDim2.new(old_pos.X.Scale, -((X + 12) / 2), old_pos.Y.Scale, old_pos.Y.Offset);
		end;

	end

	function Library:Notify(Text, Time)
		
		local Scale = Library:GetUIScale()
		local XSize, YSize = Library:GetLexendTextBounds(Text, lexend.regular, 14 * Scale)
		XSize, YSize = XSize / Scale, YSize / Scale + 6
		local TweenDuration = 0.4

		local NotifyOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			BackgroundTransparency = 1;
			Position = UDim2.new(0, 100, 0, 10);
			Size = UDim2.new(0, 0, 0, YSize);
			ClipsDescendants = true;
			ZIndex = 100;
			Parent = NotificationArea;
		})

		local NotifyInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BackgroundTransparency = 1;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 101;
			Parent = NotifyOuter;
		})

		Library:AddToRegistry(NotifyInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		}, true)

		local InnerFrame = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 1, 0, 1);
			Size = UDim2.new(1, -2, 1, -2);
			ZIndex = 102;
			Parent = NotifyInner;
		})

		Library:AddToRegistry(InnerFrame, {
			BackgroundColor3 = Library.MainColor
		})
		local NotifyLabel, NotifyStroke = Library:CreateLabel({
			Position = UDim2.new(0, 4, 0, 0);
			Size = UDim2.new(1, -4, 1, 0);
			Text = Text;
			TextTransparency = 1;
			TextXAlignment = Enum.TextXAlignment.Left;
			TextSize = 14;
			ZIndex = 103;
			Parent = InnerFrame;
		})

		task.spawn(function()
			NotifyLabel.FontFace = lexend.regular;
		end);

		local LeftColor = Library:Create('Frame', {
			BackgroundColor3 = Library.AccentColor;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new(0, -1, 0, -1);
			Size = UDim2.new(0, 3, 1, 2);
			ZIndex = 104;
			Parent = NotifyOuter;
		})

		Library:AddToRegistry(LeftColor, {
			BackgroundColor3 = 'AccentColor';
		}, true)

		local destroyed = false

		local function destroyObject()
			if destroyed then
				return
			end

			destroyed = true
			pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', TweenDuration, true)
			TweenService:Create(NotifyOuter, TweenInfo.new(TweenDuration), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(NotifyInner, TweenInfo.new(TweenDuration), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(InnerFrame, TweenInfo.new(TweenDuration), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(NotifyLabel, TweenInfo.new(TweenDuration), { TextTransparency = 1 }):Play()
			TweenService:Create(LeftColor, TweenInfo.new(TweenDuration), { BackgroundTransparency = 1 }):Play()

			task.wait(TweenDuration)
			NotifyOuter:Destroy()
		end

		local function inputBegan()
			pcall(destroyObject)
		end

		InnerFrame.MouseEnter:Connect(destroyObject)
		InnerFrame.InputBegan:Connect(inputBegan)
		pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize + 8 + 4, 0, YSize), 'Out', 'Quad', TweenDuration, true)

		TweenService:Create(NotifyOuter, TweenInfo.new(TweenDuration), { BackgroundTransparency = 0 }):Play()
		TweenService:Create(NotifyInner, TweenInfo.new(TweenDuration), { BackgroundTransparency = 0 }):Play()
		TweenService:Create(InnerFrame, TweenInfo.new(TweenDuration), { BackgroundTransparency = 0 }):Play()
		TweenService:Create(NotifyLabel, TweenInfo.new(TweenDuration), { TextTransparency = 0 }):Play()
		TweenService:Create(LeftColor, TweenInfo.new(TweenDuration), { BackgroundTransparency = 0 }):Play()
        TweenService:Create(NotifyStroke, TweenInfo.new(TweenDuration), { Transparency = 0 }):Play()


		task.spawn(function() 
			task.wait(Time or 5) 
			destroyObject()
		end) 
	end

	function Library:NotifyWithSound(Text, Time)
		if aztup and aztup_toggles and aztup_toggles.notification_sound and aztup_toggles.notification_sound.Value and not aztup.silent_mode then
			xpcall(function()
				local sound = Instance.new('Sound', game:GetService('CoreGui'))
				game:GetService('Debris'):AddItem(sound, 6)
				sound.Volume = aztup_options.NotificationVolume.Value
				sound.SoundId = getcustomasset('Project Rain/assets/notification.mp3')
				sound:Play()
			end, warn)
		end

		Library:Notify(Text, Time)
	end

	return Component
end