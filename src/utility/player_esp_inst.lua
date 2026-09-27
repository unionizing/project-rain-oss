




local Converted = {
	["_BillboardGui"] = Instance.new("BillboardGui");
	["_Box"] = Instance.new("Frame");
	["_UIStroke"] = Instance.new("UIStroke");
	["_Health"] = Instance.new("Frame");
	
	["_Dividers"] = Instance.new("Folder");
	["_Frame"] = Instance.new("Frame");
	["_Frame1"] = Instance.new("Frame");
	["_Frame2"] = Instance.new("Frame");
	["_Frame3"] = Instance.new("Frame");
	["_FillBar"] = Instance.new("Frame");
	["_Posture"] = Instance.new("Frame");
	["_FillBar1"] = Instance.new("Frame");
	
	["_BottomBars"] = Instance.new("Frame");
	["_Blood"] = Instance.new("Frame");
	
	["_FillBar2"] = Instance.new("Frame");
	["_Sanity"] = Instance.new("Frame");
	
	["_FillBar3"] = Instance.new("Frame");
	["_UIListLayout"] = Instance.new("UIListLayout");
	["_Hunger"] = Instance.new("Frame");
	
	["_FillBar4"] = Instance.new("Frame");
	["_Water"] = Instance.new("Frame");
	
	["_FillBar5"] = Instance.new("Frame");
	["_Armor"] = Instance.new("Frame");
	["_FillBar6"] = Instance.new("Frame");
	["_UIStroke11"] = Instance.new("UIStroke");
}



Converted["_BillboardGui"].Active = true
Converted["_BillboardGui"].AlwaysOnTop = true
Converted["_BillboardGui"].ClipsDescendants = true
Converted["_BillboardGui"].Size = UDim2.new(8.5, 0, 9, 0)
Converted["_BillboardGui"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Converted["_Box"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Box"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Box"].BackgroundTransparency = 1
Converted["_Box"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Box"].BorderSizePixel = 0
Converted["_Box"].Position = UDim2.new(0.5, 0, 0.550000012, 0)
Converted["_Box"].Size = UDim2.new(0.519999981, -2, 0.600000024, -2)
Converted["_Box"].Name = "Box"
Converted["_Box"].Parent = Converted["_BillboardGui"]

Converted["_UIStroke"].Color = Color3.fromRGB(255, 255, 255)
Converted["_UIStroke"].LineJoinMode = Enum.LineJoinMode.Miter
Converted["_UIStroke"].Parent = Converted["_Box"]
Converted["_UIStroke"].Thickness = 2;

Converted["_Health"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Health"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Health"].BackgroundTransparency = 0.5
Converted["_Health"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Health"].BorderSizePixel = 0
Converted["_Health"].Position = UDim2.new(0.19 + 0.02, 0, 0.550000012, 0)
Converted["_Health"].Rotation = 180
Converted["_Health"].Size = UDim2.new(0.0524999984 / 2, 0, 0.600000024, 2)
Converted["_Health"].Name = "Health"
Converted["_Health"].Parent = Converted["_BillboardGui"]






Converted["_Dividers"].Name = "Dividers"
Converted["_Dividers"].Parent = Converted["_Health"]

Converted["_Frame"].AnchorPoint = Vector2.new(0, 0.5)
Converted["_Frame"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Frame"].BackgroundTransparency = 0.5
Converted["_Frame"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame"].BorderSizePixel = 0
Converted["_Frame"].Position = UDim2.new(0, 0, 0.200000003, 0)
Converted["_Frame"].Size = UDim2.new(1, 0, 0, 2)
Converted["_Frame"].Parent = Converted["_Dividers"]
Converted["_Frame"].Name = "0.8";

Converted["_Frame1"].AnchorPoint = Vector2.new(0, 0.5)
Converted["_Frame1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Frame1"].BackgroundTransparency = 0.5
Converted["_Frame1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame1"].BorderSizePixel = 0
Converted["_Frame1"].Position = UDim2.new(0, 0, 0.400000006, 0)
Converted["_Frame1"].Size = UDim2.new(1, 0, 0, 2)
Converted["_Frame1"].Parent = Converted["_Dividers"]
Converted["_Frame1"].Name = "0.6";

Converted["_Frame2"].AnchorPoint = Vector2.new(0, 0.5)
Converted["_Frame2"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Frame2"].BackgroundTransparency = 0.5
Converted["_Frame2"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame2"].BorderSizePixel = 0
Converted["_Frame2"].Position = UDim2.new(0, 0, 0.600000024, 0)
Converted["_Frame2"].Size = UDim2.new(1, 0, 0, 2)
Converted["_Frame2"].Parent = Converted["_Dividers"]
Converted["_Frame2"].Name = "0.4";

Converted["_Frame3"].AnchorPoint = Vector2.new(0, 0.5)
Converted["_Frame3"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Frame3"].BackgroundTransparency = 0.5
Converted["_Frame3"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame3"].BorderSizePixel = 0
Converted["_Frame3"].Position = UDim2.new(0, 0, 0.800000012, 0)
Converted["_Frame3"].Size = UDim2.new(1, 0, 0, 2)
Converted["_Frame3"].Parent = Converted["_Dividers"]
Converted["_Frame3"].Name = "0.2";

Converted["_FillBar"].BackgroundColor3 = Color3.fromRGB(187.00000405311584, 255, 181.0000044107437)
Converted["_FillBar"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_FillBar"].BorderSizePixel = 0
Converted["_FillBar"].Size = UDim2.new(1, 0, 1, 0)
Converted["_FillBar"].ZIndex = 0
Converted["_FillBar"].Name = "FillBar"
Converted["_FillBar"].Parent = Converted["_Health"]

local gradient = Instance.new("UIGradient");
gradient.Color =  ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    
    ColorSequenceKeypoint.new(1, Color3.fromRGB(175, 175, 175))
})
gradient.Parent = Converted["_FillBar"];
gradient.Rotation = -90

local StoredDamage = Instance.new("Frame");
StoredDamage.Name = "StoredDamage";
StoredDamage.BackgroundColor3 = Color3.fromRGB(137, 180, 250);
StoredDamage.BorderSizePixel = 0;
StoredDamage.ZIndex = 1;
StoredDamage.Visible = false;
StoredDamage.Parent = Converted["_Health"];

local stored_damage_gradient = Instance.new("UIGradient");
stored_damage_gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(175, 175, 175))
})
stored_damage_gradient.Parent = StoredDamage;
stored_damage_gradient.Rotation = -90;


Converted["_Posture"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Posture"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Posture"].BackgroundTransparency = 0.5
Converted["_Posture"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Posture"].BorderSizePixel = 0
Converted["_Posture"].Position = UDim2.new(0.790000021, 0, 0.550000012, 0)
Converted["_Posture"].Rotation = 180
Converted["_Posture"].Size = UDim2.new(0.00999999978, 0, 0.600000024, 0)
Converted["_Posture"].Name = "Posture"
Converted["_Posture"].Parent = Converted["_BillboardGui"]

Converted["_FillBar1"].BackgroundColor3 = Color3.fromRGB(249.0000155568123, 226.00001692771912, 175.00000476837158)
Converted["_FillBar1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_FillBar1"].BorderSizePixel = 0
Converted["_FillBar1"].Size = UDim2.new(1, 0, 1, 0)
Converted["_FillBar1"].ZIndex = 0
Converted["_FillBar1"].Name = "FillBar"
Converted["_FillBar1"].Parent = Converted["_Posture"]





Converted["_BottomBars"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_BottomBars"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_BottomBars"].BackgroundTransparency = 1
Converted["_BottomBars"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_BottomBars"].BorderSizePixel = 0
Converted["_BottomBars"].Position = UDim2.new(0.5, 0, 0.935000002, 0)
Converted["_BottomBars"].Size = UDim2.new(1, 0, 0.150000006, 0)
Converted["_BottomBars"].Name = "BottomBars"
Converted["_BottomBars"].Parent = Converted["_BillboardGui"]

Converted["_Blood"].AnchorPoint = Vector2.new(0.5, 0.8999999761581421)
Converted["_Blood"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Blood"].BackgroundTransparency = 0.5
Converted["_Blood"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Blood"].BorderSizePixel = 0
Converted["_Blood"].Position = UDim2.new(0.5, 0, 0.939999998, 0)
Converted["_Blood"].Size = UDim2.new(0.519999981, 0, 0.165999994, 0)
Converted["_Blood"].Name = "Blood"
Converted["_Blood"].Parent = Converted["_BottomBars"]





Converted["_FillBar2"].BackgroundColor3 = Color3.fromRGB(243.00000071525574, 139.0000069141388, 168.0000051856041)
Converted["_FillBar2"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_FillBar2"].BorderSizePixel = 0
Converted["_FillBar2"].Size = UDim2.new(1, 0, 1, 0)
Converted["_FillBar2"].ZIndex = 0
Converted["_FillBar2"].Name = "FillBar"
Converted["_FillBar2"].Parent = Converted["_Blood"]

Converted["_Sanity"].AnchorPoint = Vector2.new(0.5, 0.8999999761581421)
Converted["_Sanity"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Sanity"].BackgroundTransparency = 0.5
Converted["_Sanity"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Sanity"].BorderSizePixel = 0
Converted["_Sanity"].Position = UDim2.new(0.5, 0, 0.889999986, 0)
Converted["_Sanity"].Size = UDim2.new(0.519999981, 0, 0.165999994, 0)
Converted["_Sanity"].Name = "Sanity"
Converted["_Sanity"].Parent = Converted["_BottomBars"]





Converted["_FillBar3"].BackgroundColor3 = Color3.fromRGB(106.00000888109207, 59.00000408291817, 172.00000494718552)
Converted["_FillBar3"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_FillBar3"].BorderSizePixel = 0
Converted["_FillBar3"].Size = UDim2.new(1, 0, 1, 0)
Converted["_FillBar3"].ZIndex = 0
Converted["_FillBar3"].Name = "FillBar"
Converted["_FillBar3"].Parent = Converted["_Sanity"]

Converted["_UIListLayout"].Padding = UDim.new(0, 5)
Converted["_UIListLayout"].HorizontalAlignment = Enum.HorizontalAlignment.Center
Converted["_UIListLayout"].SortOrder = Enum.SortOrder.LayoutOrder
Converted["_UIListLayout"].Parent = Converted["_BottomBars"]

Converted["_Hunger"].AnchorPoint = Vector2.new(0.5, 0.8999999761581421)
Converted["_Hunger"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Hunger"].BackgroundTransparency = 0.5
Converted["_Hunger"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Hunger"].BorderSizePixel = 0
Converted["_Hunger"].Position = UDim2.new(0.63499999, 0, 0.99000001, 0)
Converted["_Hunger"].Size = UDim2.new(0.519999981, 0, 0.165999994, 0)
Converted["_Hunger"].Name = "Hunger"
Converted["_Hunger"].Parent = Converted["_BottomBars"]





Converted["_FillBar4"].BackgroundColor3 = Color3.fromRGB(250.00000029802322, 179.000004529953, 135.00000715255737)
Converted["_FillBar4"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_FillBar4"].BorderSizePixel = 0
Converted["_FillBar4"].Size = UDim2.new(1, 0, 1, 0)
Converted["_FillBar4"].ZIndex = 0
Converted["_FillBar4"].Name = "FillBar"
Converted["_FillBar4"].Parent = Converted["_Hunger"]

Converted["_Water"].AnchorPoint = Vector2.new(0.5, 0.8999999761581421)
Converted["_Water"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Water"].BackgroundTransparency = 0.5
Converted["_Water"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Water"].BorderSizePixel = 0
Converted["_Water"].Position = UDim2.new(0.36500001, 0, 0.99000001, 0)
Converted["_Water"].Size = UDim2.new(0.519999981, 0, 0.165999994, 0)
Converted["_Water"].Name = "Water"
Converted["_Water"].Parent = Converted["_BottomBars"]





Converted["_FillBar5"].BackgroundColor3 = Color3.fromRGB(97.00000181794167, 122.00000032782555, 172.00000494718552)
Converted["_FillBar5"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_FillBar5"].BorderSizePixel = 0
Converted["_FillBar5"].Size = UDim2.new(1, 0, 1, 0)
Converted["_FillBar5"].ZIndex = 0
Converted["_FillBar5"].Name = "FillBar"
Converted["_FillBar5"].Parent = Converted["_Water"]

Converted["_Armor"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_Armor"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Armor"].BackgroundTransparency = 0.5
Converted["_Armor"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Armor"].BorderSizePixel = 0
Converted["_Armor"].Position = UDim2.new(0.810000002, 0, 0.550000012, 0)
Converted["_Armor"].Rotation = 180
Converted["_Armor"].Size = UDim2.new(0.00999999978, 0, 0.600000024, 0)
Converted["_Armor"].Name = "Armor"
Converted["_Armor"].Parent = Converted["_BillboardGui"]

Converted["_FillBar6"].BackgroundColor3 = Color3.fromRGB(147.00000643730164, 153.00000607967377, 178.00000458955765)
Converted["_FillBar6"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_FillBar6"].BorderSizePixel = 0
Converted["_FillBar6"].Size = UDim2.new(1, 0, 1, 0)
Converted["_FillBar6"].ZIndex = 0
Converted["_FillBar6"].Name = "FillBar"
Converted["_FillBar6"].Parent = Converted["_Armor"]

local function make_gradient(bar, rot)
	local gradient = Instance.new("UIGradient");
	gradient.Color =  ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	    
	    ColorSequenceKeypoint.new(1, Color3.fromRGB(175, 175, 175))       
	})
	gradient.Rotation = rot;
	gradient.Name = "test_grad"
	gradient.Parent = bar;
end;

local function pad(bar)
	local pad = Instance.new("UIPadding")
	pad.PaddingBottom = UDim.new(0, 1);
	pad.PaddingTop = UDim.new(0, 1);
	pad.PaddingLeft = UDim.new(0, 1);
	pad.PaddingRight = UDim.new(0, 1);

	pad.Parent = bar
end;

make_gradient(Converted._FillBar1, -90)
make_gradient(Converted._FillBar2, -180)
make_gradient(Converted._FillBar3, -180)
make_gradient(Converted._FillBar4, -180)
make_gradient(Converted._FillBar5, -180)
make_gradient(Converted._FillBar6, -90)

pad(Converted._Armor);
pad(Converted._Blood);
pad(Converted._Water);
pad(Converted._Hunger);
pad(Converted._Sanity)
pad(Converted._Posture)
pad(Converted._Health);





for _, stroke in Converted do
    if stroke:IsA("UIStroke") and stroke.Color ~= Color3.fromRGB(255, 255, 255) then
        stroke.Name = "Outline";
    end
end;

return Converted["_BillboardGui"]