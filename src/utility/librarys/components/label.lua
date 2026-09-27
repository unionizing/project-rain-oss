

return function(Library, context)
	local BaseAddons = context.BaseAddons

	local Component = {}

	function Component.AddLabel(self, Text, DoesWrap, RichText)
		local Label = {}

		if self.Objects then
			table.insert(self.Objects, {
				internal_name = "label_" .. tostring(#self.Objects + 1), settings = {
					Text = RichText or Text;
				}, Type = "Label"
			})
		end

		local Groupbox = self
		local Container = Groupbox.Container

		local TextLabel = Library:CreateLabel({
			Size = UDim2.new(1, -4, 0, 15);
			TextSize = 14;
			Text = Text;
			TextWrapped = DoesWrap or false,
			RichText = RichText or false,
			TextXAlignment = Enum.TextXAlignment.Left;
			ZIndex = 5;
			AutoLocalize = false;
			Parent = Container;
		})

		if DoesWrap then
			local Y = select(2, Library:GetLexendTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
			TextLabel.Size = UDim2.new(1, -4, 0, Y)
		else
			Library:Create('UIListLayout', {
				Padding = UDim.new(0, 4);
				FillDirection = Enum.FillDirection.Horizontal;
				HorizontalAlignment = Enum.HorizontalAlignment.Right;
				SortOrder = Enum.SortOrder.LayoutOrder;
				Parent = TextLabel;
			})
		end

		Label.TextLabel = TextLabel
		Label.Container = Container
		Label.ObjectType = "Label";

		local blank = Groupbox:AddBlank(5)

		function Label:SetText(newText, Override)
			TextLabel.Text = newText

			if DoesWrap then
				local Y = select(2, Library:GetLexendTextBounds(Override or newText, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
				TextLabel.Size = UDim2.new(1, -4, 0, Y)
			end
			blank.Visible = #TextLabel.Text ~= 0
			Groupbox:Resize()
		end

		function Label:Destroy()
			TextLabel:Destroy()
			blank:Destroy()
			Groupbox:Resize()
		end

		function Label:Show()
			TextLabel.Visible = true
			blank.Visible = #TextLabel.Text ~= 0
			Groupbox:Resize()
		end

		function Label:Hide()
			TextLabel.Visible = false
			blank.Visible = false
			Groupbox:Resize()
		end

		function Label:SetColor(color)
			TextLabel.TextColor3 = color
		end

		if not DoesWrap then
			setmetatable(Label, BaseAddons)
		end
		blank.Visible = #TextLabel.Text ~= 0

		Groupbox:Resize()

		return Label
	end

	return Component
end