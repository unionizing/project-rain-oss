local custom_name = not LPH_OBFUSCATED and isfile("custom_name.txt") and readfile("custom_name.txt") or nil;
local Window = Library:CreateWindow({ 
	Title = (string.format(LPH_ENCSTR("not loaded"), Library.AccentColor:ToHex())),
	Center = true,
	AutoShow = not aztup.silent_mode and not fflags:get("dont_auto_show_ui") and not aztup.automation:has_any(),
	MenuFadeTime = 0,
	TabPadding = 0
})
Library.PRWindow = Window;

Library:AddToRegistry(Library.WindowLabel, {
	Text = function()
		if custom_name then
			return string.format(LPH_ENCSTR("%s"), custom_name:gsub("|ACCENT", "<font color=\"#" .. Library.AccentColor:ToHex() .. "\">"))		
end
		return string.format(LPH_ENCSTR("pr <font color=\"#%s\">nextgen</font>"), Library.AccentColor:ToHex())
	end
})

local DependencyBox = {} 
do
    DependencyBox.__index = DependencyBox

    function DependencyBox:new(rawBox)
        local self_dep = {
            Box = rawBox
        }
        setmetatable(self_dep, DependencyBox) 
        return self_dep
    end
 
    function DependencyBox:newRiskyToggle(ID, Text, Default, Tip, Callback)
        aztup.flags[ID] = Default

        return self.Box:AddToggle(ID, {
            Text = Text,
            Default = Default,
            Tooltip = Tip,
			Risky = true,
            Callback = function(Value)
                aztup.flags[ID] = Value
                if Callback then
                    xpcall(function()
                        Callback(Value, ID)
                    end, warn)
                end
            end,
        })
    end

    function DependencyBox:newToggle(ID, Text, Default, Tip, Callback)
        aztup.flags[ID] = Default

        return self.Box:AddToggle(ID, {
            Text = Text,
            Default = Default,
            Tooltip = Tip,
            Callback = function(Value)
                aztup.flags[ID] = Value
                if Callback then
                    xpcall(function()
                        Callback(Value, ID)
                    end, warn)
                end
            end,
        })
    end

	function DependencyBox:newDivider()
		return self.Box:AddDivider()	
end;

    function DependencyBox:newRiskyToggleWithKeybind(ID, Text, Default, Tip, Callback, ShowUI)
        aztup.flags[ID] = Default

        local t = self.Box:AddToggle(ID, {
            Text = Text,
            Default = Default,
			Risky = true,
            Tooltip = Tip,
            Callback = function(Value)
                aztup.flags[ID] = Value
                if Callback then
                    xpcall(function()
                        Callback(Value, ID)
                    end, warn)
                end
            end,
        })
		t:AddKeyPicker(
			ID.."Keybind",  
			{ 
				Default = 'None', 
				NoUI = not ShowUI, 
				SyncToggleState = true, 
				Text = Text
			}
		);
		return t    
end

    function DependencyBox:newToggleWithKeybind(ID, Text, Default, Tip, Callback, ShowUI, Type)
        aztup.flags[ID] = Default

        local t = self.Box:AddToggle(ID, {
            Text = Text,
            Default = Default,
            Tooltip = Tip,
            Callback = function(Value)
                aztup.flags[ID] = Value
                if Callback then
                    xpcall(function()
                        Callback(Value, ID)
                    end, warn)
                end
            end,
        })
		t:AddKeyPicker(
			ID.."Keybind",  
			{ 
				Default = 'None', 
				NoUI = not ShowUI,  
				SyncToggleState = true, 
				Text = Text,
				Mode = Type
			}
		); 

		return t    
end

    function DependencyBox:newSlider(ID, Text, Default, Min, Max, Rounding, Compact, Suffix, Callback, Tooltip)
        aztup.flags[ID] = Default

        return self.Box:AddSlider(ID, {
            Text = Text,
            Default = Default,
            Min = Min,
            Max = Max,
			Tooltip = Tooltip,
            Rounding = Rounding,
            Compact = Compact,
            Suffix = Suffix,
            Callback = Callback or function(val)
                aztup.flags[ID] = val
            end, 
        })
    end

	function DependencyBox:newMinMaxSlider(ID, Text, Default, Min, Max, Rounding, Compact, Suffix, Callback, Tooltip)
		local defaultRange = Default or { Min = Min, Max = Max }
		local minDefault = defaultRange.Min or defaultRange[1] or Min
		local maxDefault = defaultRange.Max or defaultRange[2] or Max

		aztup.flags[ID] = {
			min = minDefault,
			max = maxDefault,
		}

		return self.Box:AddMinMaxSlider(ID, {
			Text = Text,
			Default = {
				Min = minDefault,
				Max = maxDefault,
			},
			Min = Min,
			Max = Max,
			Tooltip = Tooltip,
			Rounding = Rounding,
			Compact = Compact,
			Suffix = Suffix,
			Callback = Callback or function(val)
				aztup.flags[ID] = {
					min = val.Min,
					max = val.Max,
				}
			end,
		})
	end

    function DependencyBox:newDropdown(ID, Text, Values, Default, Multi, Tip, Callback, Compact)
        return self.Box:AddDropdown(ID, {
            Values = Values,
			Compact = Compact,
            Default = Default,
            Multi = Multi,
            Text = Text,
            Tooltip = Tip,
            Callback = Callback,
        })
    end

    function DependencyBox:newTextbox(ID, Text, Numeric, Default, Finished, Tip, Placeholder, Callback)
        return self.Box:AddInput(ID, {
            Default = Default,
            Numeric = Numeric,
            Finished = Finished,
            Text = Text,
            Tooltip = Tip,
            Placeholder = Placeholder,
            Callback = Callback,
        })
    end

    function DependencyBox:newButton(Text, Func, DoubleClick, Tip)
        return self.Box:AddButton({
            Text = Text,
            Func = Func,
            DoubleClick = DoubleClick,
            Tooltip = Tip,
        })
    end

    function DependencyBox:newLabel(Text, Wraps)
        return self.Box:AddLabel(Text, Wraps)
    end

    
    




function DependencyBox:newToggleGroup(Toggles)
        local Widths = {}
        for _, Info in ipairs(Toggles) do
            Widths[Info] = Library:GetLexendTextBounds(Info[2] or Info.Text, Library.Font, 14)
        end

        table.sort(Toggles, function(a, b)
            return Widths[a] > Widths[b]
        end)

        for _, Info in ipairs(Toggles) do
            local MethodName = (Info.Risky and "newRiskyToggle" or "newToggle") .. (Info.NoKeybind and "" or "WithKeybind")
            local Constructor = self[MethodName]
            Constructor(self, Info[1] or Info.ID, Info[2] or Info.Text, Info[3] or Info.Default or false, Info[4] or Info.Tip, Info[5] or Info.Callback, Info[6] or Info.ShowUI)
        end
    end
end


local Groupbox = {}
do
	Groupbox.__index = Groupbox
	function Groupbox:new(Name, Right)
		local self_groupbox = {}
		if not Right then
			self_groupbox.Groupbox = self.Tab:AddLeftGroupbox(Name)
		else
			self_groupbox.Groupbox = self.Tab:AddRightGroupbox(Name)
		end
		setmetatable(self_groupbox, Groupbox)

		return self_groupbox
	end

	function Groupbox:newDependencyBox(val, req, dont)
		local rawDependency = self.Groupbox:AddDependencyBox(dont)
		local wrapped = DependencyBox:new(rawDependency)

		if val then
			rawDependency:SetupDependencies({{ 
				aztup_toggles[val] or aztup_options[val], req == nil and true or req  
			}});
		end;

		return wrapped, rawDependency
	end
	
	function Groupbox:newTabbox(Name, Right)
		
		
		
		
		
		
		

		local tabbox = Right and self.Tab:AddRightTabbox(Name) or self.Tab:AddLeftTabbox(Name);
		local tabbox_wrapped = {};

		function tabbox_wrapped:newTab(name)
			local self_groupbox = {}
			self_groupbox.Groupbox = tabbox:AddTab(name)
			setmetatable(self_groupbox, Groupbox)

			return self_groupbox		
end;

		return tabbox_wrapped
	end

	function Groupbox:newDivider()
		return self.Groupbox:AddDivider()	
end;

    function Groupbox:newRiskyToggleWithKeybind(ID, Text, Default, Tip, Callback, ShowUI)
        aztup.flags[ID] = Default

        local t = self.Groupbox:AddToggle(ID, {
            Text = Text,
            Default = Default,
			Risky = true,
            Tooltip = Tip,
			Callback = function(Value)
				if aztup.flags[ID] == Value then
					return				
end

				aztup.flags[ID] = Value

				task.spawn(xpcall, function()
					if Callback then
						Callback(Value, ID)
					end
				end, warn)

				if not aztup.features then
					return
				end

                local feature = aztup.features[ID];
				if not feature then
					return
				end

				if feature.conn then 
					if not feature.current_connection and Value then
						
						feature.current_connection = feature.conn:Connect(function(...)
							
							xpcall(feature.update, function(data) 
								Logger.warn(string.format("%s | %s", ID, data));
							end, ...);
							
						end);
						aztup.maid:give_task(feature.current_connection);
					elseif feature.current_connection and not Value then
						
						feature.current_connection:Disconnect()
						feature.current_connection = nil
					end
				end

				task.spawn(xpcall, function() 
					if Value then
						feature:enable();
					else
						feature:disable();
					end;
				end, Logger.warn);
			end,
        })
		t:AddKeyPicker(
			ID.."Keybind",  
			{ 
				Default = 'None', 
				NoUI = not ShowUI, 
				SyncToggleState = true, 
				Text = Text
			}
		);
		return t    
end

	function Groupbox:newRiskyToggle(ID, Text, Default, Tip, Callback)
		aztup.flags[ID] = Default;
		return self.Groupbox:AddToggle(ID, {
			Text = Text,
			Default = Default,
			Tooltip = Tip,
			Callback = function(Value)
				if aztup.flags[ID] == Value then
					return				
end

				aztup.flags[ID] = Value

				task.spawn(xpcall, function()
					if Callback then
						Callback(Value, ID)
					end
				end, warn)

				if not aztup.features then
					return
				end

                local feature = aztup.features[ID];
				if not feature then
					return
				end

				if feature.conn then 
					if not feature.current_connection and Value then
						
						feature.current_connection = feature.conn:Connect(function(...)
							
							xpcall(feature.update, function(data) 
								Logger.warn(string.format("%s | %s", ID, data));
							end, ...);
							
						end);
						aztup.maid:give_task(feature.current_connection);
					elseif feature.current_connection and not Value then
						
						feature.current_connection:Disconnect()
						feature.current_connection = nil
					end
				end

				task.spawn(xpcall, function() 
					if Value then
						feature:enable();
					else
						feature:disable();
					end;
				end, Logger.warn);
			end,
		})
	end

	function Groupbox:newToggle(ID, Text, Default, Tip, Callback)
		aztup.flags[ID] = Default;
		return self.Groupbox:AddToggle(ID, {
			Text = Text,
			Default = Default,
			Tooltip = Tip,
			Callback = function(Value)
				if aztup.flags[ID] == Value then
					return				
end

				aztup.flags[ID] = Value

				task.spawn(xpcall, function()
					if Callback then
						Callback(Value, ID)
					end
				end, warn)

				if not aztup.features then
					return
				end

                local feature = aztup.features[ID];
				if not feature then
					return
				end

				if feature.conn then 
					if not feature.current_connection and Value then
						
						feature.current_connection = feature.conn:Connect(function(...)
							
							xpcall(feature.update, function(data) 
								Logger.warn(string.format("%s | %s", ID, data));
							end, ...);
							
						end);
						aztup.maid:give_task(feature.current_connection);
					elseif feature.current_connection and not Value then
						
						feature.current_connection:Disconnect()
						feature.current_connection = nil
					end
				end

				task.spawn(xpcall, function() 
					if Value then
						feature:enable();
					else
						feature:disable();
					end;
				end, Logger.warn);
			end,
		})
	end
	function Groupbox:newSlider(ID, Text, Default, Min, Max, Rounding, Compact, Suffix, Callback, Tip)
		aztup.flags[ID] = Default;
		return self.Groupbox:AddSlider(ID, {
			Text = Text,
			Default = Default,
			Min = Min,
			Suffix = Suffix,
			Max = Max,
			Rounding = Rounding,
			Compact = Compact,
			Tooltip = Tip,
			Callback = Callback or function(val)
				aztup.flags[ID] = val;
			end,
		})
	end
	function Groupbox:newMinMaxSlider(ID, Text, Default, Min, Max, Rounding, Compact, Suffix, Callback)
		local defaultRange = Default or { Min = Min, Max = Max }
		local minDefault = defaultRange.Min or defaultRange[1] or Min
		local maxDefault = defaultRange.Max or defaultRange[2] or Max

		aztup.flags[ID] = {
			Min = minDefault,
			Max = maxDefault,
		};

		return self.Groupbox:AddMinMaxSlider(ID, {
			Text = Text,
			Default = {
				Min = minDefault,
				Max = maxDefault,
			},
			Min = Min,
			Suffix = Suffix,
			Max = Max,
			Rounding = Rounding,
			Compact = Compact,
			Callback = Callback or function(val)
				aztup.flags[ID] = {
					Min = val.Min,
					Max = val.Max,
				};
			end,
		})
	end
	function Groupbox:newDropdown(ID, Text, Values, Default, Multi, Tip, Callback, Searchable, Compact)

		local dropdown = self.Groupbox:AddDropdown(ID, {
			Values = Values,
			Default = Default,
			Multi = Multi,
			Text = Text,
			Tooltip = Tip,
			Callback = Callback,
			Searchable = Searchable,
			Compact = Compact
		});

		return dropdown
	end
	function Groupbox:newTextbox(ID, Text, Numeric, Default, Finished, Tip, Placeholder, Callback, NoLabel)
		self.Groupbox:AddInput(ID, {
			Default = Default,
			Numeric = Numeric,
			Finished = Finished,
			Text = Text,
			Tooltip = Tip,
			Placeholder = Placeholder,
			Callback = Callback,
			NoLabel = NoLabel
		})
	end
	function Groupbox:newButton(Text, Func, DoubleClick, Tip)
		return self.Groupbox:AddButton({
			Text = Text,
			Func = Func,
			DoubleClick = DoubleClick,
			Tooltip = Tip,
		})
	end
	function Groupbox:newKeybind(ID, Text, Default, ToggleID, Mode, no_ui, keybind_only)
		return self.Groupbox:AddLabel(Text):AddKeyPicker(ID, {
			Default = Default,
			NoUI = no_ui,
			Text = Text,
			Mode = Mode,
			KeybindOnly = keybind_only,
			Callback = ToggleID and typeof(ToggleID) == "function" and ToggleID or function()
				if not ToggleID then return end
				if typeof(ToggleID) == "function" then
					ToggleID()
				else
					aztup_toggles[ToggleID]:SetValue(not aztup_toggles[ToggleID].Value)
				end
			end,
		})
	end

	function Groupbox:newToggleWithKeybind(ID, Text, Default, Tip, Callback,ShowUI)
		local toggle = self:newToggle(ID, Text, Default, Tip, Callback)
		toggle:AddKeyPicker(
			ID.."Keybind",  
			{ 
				Default = 'None', 
				NoUI = not ShowUI, 
				SyncToggleState = true, 
				Text = Text
			}
		);
		return toggle	
end

	function Groupbox:newColorPicker(ID, Text, Default, Callback)
		return self.Groupbox:AddLabel(Text .. " Color"):AddColorPicker(ID, {
			Default = Default or Color3.fromRGB(255, 255, 255),
			Title = Text,
			Transparency = 0,
			Callback = Callback,
		})
	end
	function Groupbox:newLabel(Text, Wraps, RichText)
		return self.Groupbox:AddLabel(Text, Wraps, RichText)
	end

	
	




function Groupbox:newToggleGroup(Toggles)
		local Widths = {}
		for _, Info in ipairs(Toggles) do
			Widths[Info] = Library:GetLexendTextBounds(Info[2] or Info.Text, Library.Font, 14)
		end

		table.sort(Toggles, function(a, b)
			return Widths[a] > Widths[b]
		end)

		for _, Info in ipairs(Toggles) do
			local MethodName = (Info.Risky and "newRiskyToggle" or "newToggle") .. (Info.NoKeybind and "" or "WithKeybind")
			local Constructor = self[MethodName]
			Constructor(self, Info[1] or Info.ID, Info[2] or Info.Text, Info[3] or Info.Default or false, Info[4] or Info.Tip, Info[5] or Info.Callback, Info[6] or Info.ShowUI)
		end
	end
end

local Tab = {}
do
	Tab.__index = Tab
	function Tab:newGroupBox(Name, Right)
		self.GroupBoxes[Name] = Groupbox.new(self, Name, Right)
		return self.GroupBoxes[Name]
	end

	function Tab:newTabbox(Name, Right)
		self.GroupBoxes[Name] = Groupbox.newTabbox(self, Name, Right)
		return self.GroupBoxes[Name]
	end

	function Tab.new(Name)
		local self = setmetatable({}, Tab)
		self.GroupBoxes = {}
		self.Tab = Window:AddTab(Name)
		return self
	end
end
return Tab, Groupbox