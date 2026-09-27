

return function(Library, context)
	local ScreenGui = context.ScreenGui or Library.ScreenGui

	local Component = {}

	function Component.CreatePanel(Title, Size, Position, Anchor)
		local Outer: Frame = Library:Create('Frame', {
			AnchorPoint = Anchor or Vector2.zero;
			Position = Position;
			Size = Size;
			BackgroundColor3 = Library.AccentColor;
			BorderSizePixel = 1;
			Visible = false;
			ZIndex = Title == 'Console' and 100 or 101;
			Parent = ScreenGui;
		});

		Library:AddUIScale(Outer);

		Outer.MouseEnter:Connect(function()
			Library.RequestingMouse = true;
		end)

		Outer.MouseLeave:Connect(function()
			Library.RequestingMouse = false;
		end)

		Library:AddToRegistry(Outer, {
			BackgroundColor3 = 'AccentColor';
		}, true)

		local Inner = Library:Create('Frame', {
			Size = UDim2.new(1, -2, 1, -2);
			Position = UDim2.new(0, 1, 0, 1);
			BackgroundColor3 = Library.MainColor;
			BorderSizePixel = 0;
			ClipsDescendants = true;
			ZIndex = 101;
			Parent = Outer;
		});

		Library:AddToRegistry(Inner, {
			BackgroundColor3 = 'MainColor';
		}, true)

		local Header = Library:Create('Frame', {
			Size = UDim2.new(1, 0, 0, 22);
			BackgroundColor3 = Library.BackgroundColor;
			BorderSizePixel = 0;
			ZIndex = 102;
			Parent = Inner;
		});

		Library:AddToRegistry(Header, {
			BackgroundColor3 = 'BackgroundColor';
		}, true)

		local HeaderLabel = Library:CreateLabel({
			Position = UDim2.new(0, 5, 0, 0);
			Size = UDim2.new(1, -16, 1, 0);
			Text = Title;
			TextSize = 16;
			TextXAlignment = Enum.TextXAlignment.Center;
			TextStrokeTransparency = 1;
			ZIndex = 103;
			Parent = Header;
		})

		task.spawn(function()
			HeaderLabel.FontFace = lexend.regular;
		end);

		Library:AddToRegistry(HeaderLabel, {
			TextColor3 = 'FontColor';
		}, true)

		local Divider = Library:Create('Frame', {
			Size = UDim2.new(1, 0, 0, 1);
			Position = UDim2.new(0, 0, 0, 22);
			BackgroundColor3 = Library.OutlineColor;
			BorderSizePixel = 0;
			ZIndex = 102;
			Parent = Inner;
		});

		Library:AddToRegistry(Divider, {
			BackgroundColor3 = 'OutlineColor';
		}, true)

		local Content = Library:Create('Frame', {
			BackgroundTransparency = 1;
			Size = UDim2.new(1, 0, 1, -23);
			Position = UDim2.new(0, 0, 0, 23);
			ZIndex = 101;
			Parent = Inner;
		});

		return Outer, Content	
end

	return Component
end
