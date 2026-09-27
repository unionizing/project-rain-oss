


local signal = require("@src/utility/signal");
local curr_mode_select;
return function(Library, context)
	local InputService = context.InputService
	local Mouse = context.Mouse
	local RenderStepped = context.RenderStepped
	local BaseAddons = context.BaseAddons

	local Component = {}

	function Component.AddToggle(self, Idx, Info)
		assert(Info.Text, 'AddInput: Missing `Text` string.')
		if self.Objects then
			table.insert(self.Objects, {
				internal_name = Idx, settings = Info
			})
		else
			print(self)
		end;
		
		local Toggle = {
			Value = Info.Default or false;
			Type = 'Toggle';
			Flag = Idx,
			Name = Info.Text,
			
			Callback = Info.Callback or function(Value) end;
			Addons = {};
			Risky = Info.Risky;
		}

		local Groupbox = self;
		local Container = Groupbox.Container;

		local ToggleOuter = Library:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(0, 13, 0, 13);
			ZIndex = 5;
			Parent = Container;
		})

		Library:AddToRegistry(ToggleOuter, {
			BorderColor3 = 'Black';
		})

		local ToggleInner = Library:Create('Frame', {
			BackgroundColor3 = Library.MainColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 6;
			Parent = ToggleOuter;
		})

		Library:AddToRegistry(ToggleInner, {
			BackgroundColor3 = 'MainColor';
			BorderColor3 = 'OutlineColor';
		})

		local ToggleLabel = Library:CreateLabel({
			Size = UDim2.new(0, 236, 1, 0);
			Position = UDim2.new(1, 6, 0, 0);
			TextSize = 14;
			Text = Info.Text;
			TextXAlignment = Enum.TextXAlignment.Left;
			ZIndex = 6;
			Parent = ToggleInner;
		})

		Library:Create('UIListLayout', {
			Padding = UDim.new(0, 4);
			FillDirection = Enum.FillDirection.Horizontal;
			HorizontalAlignment = Enum.HorizontalAlignment.Right;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = ToggleLabel;
		})

		local ToggleRegion = Library:Create('Frame', {
			BackgroundTransparency = 1;
			Size = UDim2.new(0, 170, 1, 0);
			ZIndex = 8;
			Parent = ToggleOuter;
		})

		Library:OnHighlight(ToggleRegion, ToggleOuter,
			{ BorderColor3 = 'AccentColor' },
			{ BorderColor3 = 'Black' }
		)

		function Toggle:UpdateColors()
			Toggle:Display();
		end;

		if type(Info.Tooltip) == 'string' then
			Library:AddToolTip(Info.Tooltip, ToggleRegion)
		end

		function Toggle:Display()
			ToggleInner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.MainColor;
			ToggleInner.BorderColor3 = Toggle.Value and Library.AccentColorDark or Library.OutlineColor;

			Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor';
			Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor';
		end;
		Toggle.__internal = signal.new();

		function Toggle:OnChanged(Func)
			Toggle.Changed = Func;
			pcall(Func,Toggle.Value);
		end;

		function Toggle:SetValue(Bool)
			Bool = (not not Bool);

			Toggle.Value = Bool;
			Toggle:Display();

			for _, Addon in next, Toggle.Addons do
				if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
					Addon.Toggled = Bool
					Addon:Update()
				end
			end
			pcall(function()
				Library:SafeCallback(Toggle.Callback, Toggle.Value);
				Library:SafeCallback(Toggle.Changed, Toggle.Value);

				aztup_options.OnlyShowEnabledKeybinds.__internal:fire()
			end)
			Library:UpdateDependencyBoxes();
		end;

		ToggleRegion.InputBegan:Connect(function(Input)
			
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
				Toggle:SetValue(not Toggle.Value)
				Library:AttemptSave();
			end;
		end);

		if Toggle.Risky then
			Library:RemoveFromRegistry(ToggleLabel)
			ToggleLabel.TextColor3 = Library.RiskColor
			Library:AddToRegistry(ToggleLabel, { TextColor3 = 'RiskColor' })
		end

		Toggle:Display();
		if type(Info.Text) == 'string' and Info.Text ~= '' then
			Library:RegisterSearchEntry(Groupbox, {
				Kind = 'Toggle';
				Text = Info.Text;
				Tab = Groupbox.Tab or Groupbox;
				Target = ToggleOuter;
				Focus = function()
					Library:FocusSearchTarget(ToggleOuter)
				end;
			})
		end
		Groupbox:AddBlank(Info.BlankSize or 5 + 2);
		Groupbox:Resize();

		Toggle.TextLabel = ToggleLabel;
		Toggle.Container = Container;
		setmetatable(Toggle, BaseAddons or {})

		aztup_toggles[Idx] = Toggle;

		Library:UpdateDependencyBoxes();

		return Toggle	
end

	function Component.AddKeyPicker(self, Idx, Info)
		local ParentObj = self;
		local ToggleLabel = self.TextLabel;
		local Container = self.Container;
		
		
		

		assert(Info.Default, 'AddKeyPicker: Missing default value.');

		local KeyPicker = {
			Value = Info.Default;
			Toggled = false;
			Mode = Info.Mode or 'Toggle'; 
			Type = 'KeyPicker';
			Callback = Info.Callback or function(Value) end;
			ChangedCallback = Info.ChangedCallback or function(New) end;

			SyncToggleState = Info.SyncToggleState or false;
		};

		local Modes = Info.Modes or { 'Toggle', 'Hold' };

		self.KeyPicker = {
			Flag = Idx;
			Value = KeyPicker.Value
		}

		if not table.find(Modes, KeyPicker.Mode) then
			KeyPicker.Mode = Modes[1]
		end

		local ContainerLabelTransparencyTween
		local ContainerStrokeTransparencyTween

		local PickOuter = Library:Create('Frame', {
			BackgroundColor3 = Color3.new(0, 0, 0);
			BorderColor3 = Color3.new(0, 0, 0);
			Size = UDim2.new(0, 28, 0, 15);
			ZIndex = 6;
			Parent = ToggleLabel;
		});

		local PickInner = Library:Create('Frame', {
			BackgroundColor3 = Library.BackgroundColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 7;
			Parent = PickOuter;
		});

		Library:AddToRegistry(PickInner, {
			BackgroundColor3 = 'BackgroundColor';
			BorderColor3 = 'OutlineColor';
		});

		local DisplayLabel = Library:CreateLabel({
			Size = UDim2.new(1, 0, 1, 0);
			TextSize = 13;
			Text = Info.Default;
			TextWrapped = true;
			ZIndex = 8;
			Parent = PickInner;
			Name = "DisplayLabelKeybind";
		});

		local ModeSelectOuter = Library:Create('Frame', {
			BorderColor3 = Color3.new(0, 0, 0);
			Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
			Size = UDim2.new(0, 60, 0, (((#Modes)+1) * 15) + 2);
			Visible = false;
			ZIndex = 14;
			Parent = Library.ScreenGui;
		});

		Library:AddUIScale(ModeSelectOuter);

		ToggleLabel:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
			ModeSelectOuter.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
		end);

		local ModeSelectInner = Library:Create('Frame', {
			BackgroundColor3 = Library.BackgroundColor;
			BorderColor3 = Library.OutlineColor;
			BorderMode = Enum.BorderMode.Inset;
			Size = UDim2.new(1, 0, 1, 0);
			ZIndex = 15;
			Parent = ModeSelectOuter;
		});

		Library:AddToRegistry(ModeSelectInner, {
			BackgroundColor3 = 'BackgroundColor';
			BorderColor3 = 'OutlineColor';
		});

		Library:Create('UIListLayout', {
			FillDirection = Enum.FillDirection.Vertical;
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = ModeSelectInner;
		});

		local ContainerLabel, ContainerStroke = Library:CreateLabel({
			TextXAlignment = Enum.TextXAlignment.Left;
			Size = UDim2.new(1, 0, 0, 18);
			TextSize = 16;
			Visible = false;
			ZIndex = 110;
			Parent = Library.KeybindContainer;
		}, true);
		
		task.spawn(function()
			ContainerLabel.FontFace = lexend.regular;
		end);

		local ModeButtons = {};

		local function GetKeybindFrameResizeBaseline()
			local ResizeTarget = Library.KeybindFrameResizeTarget

			if Library.KeybindFrameResizeTween and ResizeTarget then
				return ResizeTarget.Height, ResizeTarget.PositionY, ResizeTarget.CenterY
			end

			local CurrentHeight = Library.KeybindFrame.AbsoluteSize.Y / Library:GetUIScale()
			local CurrentPositionY = Library.KeybindFrame.Position.Y.Offset
			local CurrentCenterY = Library.KeybindFrame.AbsolutePosition.Y + (Library.KeybindFrame.AbsoluteSize.Y * 0.5)

			return CurrentHeight, CurrentPositionY, CurrentCenterY
		end

		for Idx, Mode in next, Modes do
			local ModeButton = {};

			local Label = Library:CreateLabel({
				Active = false;
				Size = UDim2.new(1, 0, 0, 15);
				TextSize = 13;
				Text = Mode;
				ZIndex = 16;
				Parent = ModeSelectInner;
			});

			function ModeButton:Select()
				for _, Button in next, ModeButtons do
					Button:Deselect();
				end;

				KeyPicker.Mode = Mode;

				Label.TextColor3 = Library.AccentColor;
				Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor';
				curr_mode_select = nil;
				ModeSelectOuter.Visible = false;
			end;

			function ModeButton:Deselect()
				KeyPicker.Mode = nil;

				Label.TextColor3 = Library.FontColor;
				Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor';
			end;

			Label.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					ModeButton:Select();
					Library:AttemptSave();
				end;
			end);

			if Mode == KeyPicker.Mode then
				ModeButton:Select();
			end;

			ModeButtons[Mode] = ModeButton;
		end;

		(function()

			local ModeButton = {};

			local Label = Library:CreateLabel({
				Active = false;
				Size = UDim2.new(1, 0, 0, 15);
				TextSize = 13;
				Text = "Unbind";
				ZIndex = 16;
				Parent = ModeSelectInner;
			});

			function ModeButton:Deselect() end;

			function ModeButton:Select()
				local Key = "None";
				
				DisplayLabel.Text = Key == "None" and "N/A" or Key;
				KeyPicker.Value = Key;
				Library:SafeCallback(KeyPicker.ChangedCallback, Enum.KeyCode.Unknown)
				if KeyPicker.Changed then
					Library:SafeCallback(KeyPicker.Changed, Enum.KeyCode.Unknown)
				end;
				curr_mode_select = nil;
				ModeSelectOuter.Visible = false;
				Library:AttemptSave();
			end;

			Label.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					ModeButton:Select();
					Library:AttemptSave();
				end;
			end);

			ModeButtons.Unbind = ModeButton;
		end)();

		local function UpdateKeybindFrameSize()
			Library.KeybindFrameResizeQueued = false

			if Info.NoUI then return end

			local YSize = 0
			local XSize = 0
			for _, Label in next, Library.KeybindContainer:GetChildren() do
				if Label:IsA('TextLabel') then
					if Label.Visible and not Label:GetAttribute('KeybindFadingOut') then
						YSize = YSize + 18
					end

					local LabelWidth = Label.TextBounds.X / Library:GetUIScale()
					if Label.Visible and (LabelWidth > XSize) then
						XSize = LabelWidth
					end
				end
			end

			local OldHeight, BaselinePositionY, BaselineCenterY = GetKeybindFrameResizeBaseline()
			local NewHeight = YSize == 0 and 24 or YSize + 32
			local NewWidth = math.max(XSize + 34, 220)
			local TargetPositionY = BaselinePositionY
			local TargetCenterY = BaselineCenterY

			local properties = {
				Size = UDim2.new(0, NewWidth, 0, NewHeight);
				Position = UDim2.fromOffset(Library.KeybindFrame.Position.X.Offset, TargetPositionY);
			}
			if NewHeight ~= OldHeight then 
				local Camera = workspace.CurrentCamera
				local ViewportY = (Camera and Camera.ViewportSize.Y) or 1080
				local CenterY = ViewportY * 0.5
				local NormalizedDistance = math.abs(BaselineCenterY - CenterY) / ViewportY

				if NormalizedDistance > 0.10 then
					
					local HeightDelta = (NewHeight - OldHeight) * Library:GetUIScale()
					local Direction = (BaselineCenterY < CenterY) and 1 or -1
					TargetPositionY = BaselinePositionY + (HeightDelta * 0.5 * Direction)
					TargetCenterY = BaselineCenterY + (HeightDelta * 0.5 * Direction)
					properties.Position = UDim2.fromOffset(Library.KeybindFrame.Position.X.Offset, TargetPositionY)
				end
			end

			if Library.KeybindFrameResizeTween then
				Library.KeybindFrameResizeTween:Cancel()
				Library.KeybindFrameResizeTween = nil
			end

			local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local Tween = services.TweenService:Create(Library.KeybindFrame, tweenInfo, properties)
			Library.KeybindFrameResizeTween = Tween
			Library.KeybindFrameResizeTarget = {
				Height = NewHeight;
				PositionY = TargetPositionY;
				CenterY = TargetCenterY;
			}

			Tween.Completed:Connect(function()
				if Library.KeybindFrameResizeTween == Tween then
					Library.KeybindFrameResizeTween = nil
				end
			end)

			Tween:Play()
		end

		local function QueueKeybindFrameSize()
			if Library.KeybindFrameResizeQueued then
				return
			end

			Library.KeybindFrameResizeQueued = true
			task.defer(UpdateKeybindFrameSize)
		end

		function KeyPicker:Update()
		    if Info.NoUI then return end

		    local State = KeyPicker:GetState()
		    local shouldHide = (not State and aztup_toggles.OnlyShowEnabledKeybinds and aztup_toggles.OnlyShowEnabledKeybinds.Value)
		                   or (KeyPicker.Value == "None")

			if Info.KeybindOnly then
				State = false;
				shouldHide = (KeyPicker.Value == "None")
			end;

			if #tostring(KeyPicker.Value) == 0 then
			   	shouldHide = true
			end;

		    
		    ContainerLabel.Text = string.format('[%s]: %s', KeyPicker.Value, Info.Text)
		    local x, _ = Library:GetLexendTextBounds(ContainerLabel.Text, lexend.regular, 16)
		    ContainerLabel.LayoutOrder = -x
		    ContainerLabel.TextColor3 = State and Library.AccentColor or Library.FontColor
		    Library.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor'

		    if shouldHide then
		        
		        if ContainerLabel.Visible and not ContainerLabel:GetAttribute('KeybindFadingOut') then
		            if ContainerLabelTransparencyTween then
		                ContainerLabelTransparencyTween:Cancel()
		                ContainerLabelTransparencyTween = nil
		            end

		            if ContainerStrokeTransparencyTween then
		                ContainerStrokeTransparencyTween:Cancel()
		                ContainerStrokeTransparencyTween = nil
		            end

		            ContainerLabel:SetAttribute('KeybindFadingOut', true)

		            local fadeOut = services.TweenService:Create(ContainerLabel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		                TextTransparency = 1
		            })
		            ContainerLabelTransparencyTween = fadeOut
		            fadeOut:Play()

				local strokeFadeOut = services.TweenService:Create(ContainerStroke, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		                Transparency = 1
				})
				ContainerStrokeTransparencyTween = strokeFadeOut
				strokeFadeOut:Play()
				fadeOut.Completed:Connect(function(playbackState)
					if ContainerLabelTransparencyTween ~= fadeOut then
						return
					end

					ContainerLabelTransparencyTween = nil
					ContainerStrokeTransparencyTween = nil

						if playbackState ~= Enum.PlaybackState.Completed or not ContainerLabel.Visible or KeyPicker:GetState() then
						ContainerLabel:SetAttribute('KeybindFadingOut', nil)
							return
						end

						ContainerLabel.Visible = false
					ContainerLabel:SetAttribute('KeybindFadingOut', nil)
						KeyPicker:Update()
		            end)
		        end
		        
		    else
				if ContainerLabel:GetAttribute('KeybindFadingOut') then
					ContainerLabel:SetAttribute('KeybindFadingOut', nil)
				end

				if ContainerLabelTransparencyTween then
					ContainerLabelTransparencyTween:Cancel()
					ContainerLabelTransparencyTween = nil
				end

				if ContainerStrokeTransparencyTween then
					ContainerStrokeTransparencyTween:Cancel()
					ContainerStrokeTransparencyTween = nil
				end

		        
		        if not ContainerLabel.Visible then
		            ContainerLabel.Visible = true
		            ContainerLabel.TextTransparency = 1
		            ContainerStroke.Transparency = 1
		            local fadeIn = services.TweenService:Create(ContainerLabel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		                TextTransparency = 0
		            })
		            ContainerLabelTransparencyTween = fadeIn
		            fadeIn:Play()
					
				local strokeFadeIn = services.TweenService:Create(ContainerStroke, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		                Transparency = 0
				})
				ContainerStrokeTransparencyTween = strokeFadeIn
				strokeFadeIn:Play()
		        else
		            
					ContainerStroke.Transparency = 0
		            ContainerLabel.TextTransparency = 0
		        end
		    end

			Library.RegistryMap[ContainerLabel].KEYBINDLABEL = true;
			Library.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor';

			QueueKeybindFrameSize()
		end;

		function KeyPicker:GetState()
			if KeyPicker.Mode == 'Always' then
				return true			
elseif KeyPicker.Mode == 'Hold' then
				if KeyPicker.Value == 'None' then
					return false				
end

				local Key = KeyPicker.Value;

				if Key == 'MB1' or Key == 'MB2' then
					return Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
						or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)				
else
					return InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value])				
end;
			else
				return KeyPicker.Toggled			
end;
		end;

		function KeyPicker:SetValue(Data)
			local Key, Mode = Data[1], Data[2];
			DisplayLabel.Text = Key == "None" and "N/A" or Key;
			KeyPicker.Value = Key;
			ModeButtons[Mode]:Select();
			KeyPicker:Update();
		end;

		function KeyPicker:OnClick(Callback)
			KeyPicker.Clicked = Callback
		end

		function KeyPicker:OnChanged(Callback)
			KeyPicker.Changed = Callback
			Callback(KeyPicker.Value)
		end

		if ParentObj.Addons then
			table.insert(ParentObj.Addons, KeyPicker)
		end

		function KeyPicker:DoClick()
			if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
				if KeyPicker.Mode == 'Hold' then
					ParentObj:SetValue(KeyPicker.Toggled)
				else
					ParentObj:SetValue(not ParentObj.Value)
				end
			end

			Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
			Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)
			self:Update()
		end

		local Picking = false;

		PickOuter.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
				xpcall(function()
					Picking = true;
					DisplayLabel.Text = '';
					local Break;
					local Text = '';
					task.spawn(function()
						pcall(function()
							while (not Break) do
								if Text == '...' then
									Text = '';
								end;
								Text = Text .. '.';
								DisplayLabel.Text = Text;
								wait(0.4);
							end;
						end)
					end);
					wait(0.2);
					local Event;
					Event = InputService.InputBegan:Connect(function(Input)
						local Key;
						local kc = Input.KeyCode;
						if Input.UserInputType == Enum.UserInputType.Keyboard then
							Key = Input.KeyCode.Name;
							if kc == Enum.KeyCode.Backspace or kc == Enum.KeyCode.Escape then
								Key = 'None'
								kc = Enum.KeyCode.Unknown;
							end;
						elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
							Key = 'MB1';
						elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
							Key = 'MB2';
						end;
						Break = true;
						Picking = false;

						Event:Disconnect();
						DisplayLabel.Text = Key == "None" and "N/A" or Key;
						KeyPicker.Value = Key;
						Library:SafeCallback(KeyPicker.ChangedCallback, kc or Input.UserInputType)
						Library:SafeCallback(KeyPicker.Changed, kc or Input.UserInputType)
						Library:AttemptSave();
					end);
				end, print);
			elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
				if curr_mode_select then
					curr_mode_select.Visible = false;
					curr_mode_select = nil;
				end

				curr_mode_select = ModeSelectOuter;
				ModeSelectOuter.Visible = true;
			end;
		end);

		local function IsBoundInput(Input, Processed)
			local Key = KeyPicker.Value;

			if Key == 'None' then
				return false
			end

			if Key == 'MB1' then
				return Input.UserInputType == Enum.UserInputType.MouseButton1
		elseif Key == 'MB2' then
				return Input.UserInputType == Enum.UserInputType.MouseButton2
		end

			return Input.UserInputType == Enum.UserInputType.Keyboard and not Processed and Input.KeyCode.Name == Key
		end

		local function IsBoundInputEnded(Input)
			local Key = KeyPicker.Value;

			if Key == 'None' then
				return false
			end

			if Key == 'MB1' then
				return Input.UserInputType == Enum.UserInputType.MouseButton1
			elseif Key == 'MB2' then
				return Input.UserInputType == Enum.UserInputType.MouseButton2
			end

			return Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key
		end

		Library:GiveSignal(InputService.InputBegan:Connect(function(Input,t)
			if (not Picking) then
				if KeyPicker.Mode == 'Toggle' then
					if IsBoundInput(Input, t) then
						KeyPicker.Toggled = not KeyPicker.Toggled
						KeyPicker:DoClick();
						KeyPicker:Update();
					end;
				elseif KeyPicker.Mode == 'Hold' then
					if IsBoundInput(Input, t) then
						if not KeyPicker.Toggled then
							KeyPicker.Toggled = true
							KeyPicker:DoClick();
						end
						KeyPicker:Update();
					end
				end;
			end;

			if not Library.Toggled then
				return			
end;
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;

				if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
					or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then
					curr_mode_select = nil;
					ModeSelectOuter.Visible = false;
				end;
			end;
		end))

		Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
			if (not Picking) then
				if KeyPicker.Mode == 'Hold' and KeyPicker.Toggled and IsBoundInputEnded(Input) then
					KeyPicker.Toggled = false
					KeyPicker:DoClick();
				end
			end;
		end))

		loaded_signal:connect(function()
			KeyPicker:Update()
		end)
		KeyPicker:Update();

		aztup_options[Idx] = KeyPicker;

		return self	
end

	return Component
end