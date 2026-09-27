



local Converted = {
	["_ScreenGui"] = Instance.new("ScreenGui");
	["_Frame"] = Instance.new("Frame");
	["_ScrollingFrame"] = Instance.new("ScrollingFrame");
	["_TextLabel"] = Instance.new("TextLabel");
	["_TextLabel1"] = Instance.new("TextLabel");
	["_UIStroke"] = Instance.new("UIStroke");
	["_Accept"] = Instance.new("TextButton");
	["_UIStroke1"] = Instance.new("UIStroke");
	["_Deny"] = Instance.new("TextButton");
	["_UIStroke2"] = Instance.new("UIStroke");
	["_Frame1"] = Instance.new("Frame");
	["_MuteMusic"] = Instance.new("TextButton");
	["_UIStroke3"] = Instance.new("UIStroke");
}

local Music = Instance.new("Sound");
Music.Name = "ElevatorMusic";
Music.SoundId = "rbxassetid://130336104979993"; 
Music.Looped = true;
Music.Volume = 0.4;

pcall(function()
    services.RunService:SetRobloxGuiFocused(true)
end);

xpcall(function()
    aztup.ui = require(("@src/utility/librarys/ui"));

    local ThemeManager = require("@src/utility/librarys/managers/ThemeManager");
    ThemeManager:SetLibrary(aztup.ui);
    ThemeManager:SetFolder('Project Rain/Deepwoken-Config')
    ThemeManager:LoadDefault()
end, warn);

Converted._ScreenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None;
Converted._ScreenGui.ScreenInsets = Enum.ScreenInsets.None;
Converted._ScreenGui.OnTopOfCoreBlur = true;


Converted["_ScreenGui"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Converted["_ScreenGui"].Parent = game:GetService("CoreGui")

Converted["_Frame"].AnchorPoint = Vector2.new(0.5, 0.5) 
Converted["_Frame"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Frame"].BackgroundTransparency = 1
Converted["_Frame"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame"].BorderSizePixel = 0
Converted["_Frame"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_Frame"].Size = UDim2.new(0, 750, 0, 570)
Converted["_Frame"].Parent = Converted["_ScreenGui"]
 
Converted["_ScrollingFrame"].ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
Converted["_ScrollingFrame"].ScrollBarImageTransparency = 1
Converted["_ScrollingFrame"].ScrollBarThickness = 0
Converted["_ScrollingFrame"].Active = true
Converted["_ScrollingFrame"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_ScrollingFrame"].BackgroundColor3 = Color3.fromHex("1b2b34")
Converted["_ScrollingFrame"].BorderColor3 = Color3.fromHex("343d46")
Converted["_ScrollingFrame"].Position = UDim2.new(0.5, 0, 0.5, 0)
Converted["_ScrollingFrame"].Size = UDim2.new(1, 0, 1, 0)
Converted["_ScrollingFrame"].CanvasSize = UDim2.new(0, 0, 0, 0)
Converted["_ScrollingFrame"].ScrollingDirection = Enum.ScrollingDirection.Y
Converted["_ScrollingFrame"].Parent = Converted["_Frame"]

local accentHex = (Library and Library.AccentColor or Color3.fromHex("6699cc")):ToHex();

Converted["_TextLabel"].Font = Enum.Font.Code
Converted["_TextLabel"].RichText = true
Converted["_TextLabel"].Text = ([[
By accessing or using our service ("<font color="#%s">Project Rain</font>"), you agree to be bound by these Terms of Service.

<b>Updates to this Agreement</b>
<font color="rgb(116, 118, 125)"><b>We may revise this Agreement and its content at any time with a notice and all such revisions are effective immediately upon acceptance by when you click "Agree".</b></font>

<b>Prohibited Activities</b>
<font color="rgb(116, 118, 125)"><b>Sharing your account/key will cause your key to be permanently revoked.</b></font>
<font color="rgb(116, 118, 125)"><b>Reverse Engineering.</b></font>

<b>Action we will take</b>
<font color="rgb(116, 118, 125)"><b>Suspending your access.</b></font>

<b>Disclaimer</b>
<font color="rgb(116, 118, 125)"><b>The Service is provided "as is" without warranties of any kind. We are not responsible for any damages arising from use or inability to use the Service.</b></font>
<font color="rgb(116, 118, 125)"><b>The product can be discontinued at any time.</b></font>

The privacy policy & TOS of the third party provider luarmor apply, which you can read at https://luarmor.net/tos
Last updated on January 25 2026 7:52 PM UTC-0

<b>Privacy</b>
We log the following information as of August 21 2026 8:14 AM UTC-0:
<font color="rgb(116, 118, 125)"><b>IP ASN, City, Continent, Country, Currency & General Data (e.g: vpn/mobile/residential), used for anti keysharing measures</b></font>
<font color="rgb(116, 118, 125)"><b>Players in executed server (shared with a third party, binwoken.sh - never logged, for server sniping)</b></font>
<font color="rgb(116, 118, 125)"><b>Deepwoken Server Name & Region (along with all servers when used in the main menu)</b></font>
<font color="rgb(116, 118, 125)"><b>File names & Folder names inside your executor workspace/ folder</b></font>
<font color="rgb(116, 118, 125)"><b>HWID and User-Agent headers (non sensitive, executor specific)</b></font>
<font color="rgb(116, 118, 125)"><b>Timestamps (when you executed the script)</b></font>
<font color="rgb(116, 118, 125)"><b>GPU Memory</b></font>
<font color="rgb(116, 118, 125)"><b>HWID</b></font>
]]):format(accentHex)
Converted["_TextLabel"].TextColor3 = Color3.fromHex("d8dee9")
Converted["_TextLabel"].TextScaled = false
Converted["_TextLabel"].TextSize = 16
Converted["_TextLabel"].TextWrapped = true
Converted["_TextLabel"].TextXAlignment = Enum.TextXAlignment.Left
Converted["_TextLabel"].TextYAlignment = Enum.TextYAlignment.Top
Converted["_TextLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextLabel"].BackgroundTransparency = 1
Converted["_TextLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_TextLabel"].BorderSizePixel = 0
Converted["_TextLabel"].Position = UDim2.new(0, 4, 0, 24)
Converted["_TextLabel"].Size = UDim2.new(1, -8, 0, 0)
Converted["_TextLabel"].AutomaticSize = Enum.AutomaticSize.Y
Converted["_TextLabel"].Parent = Converted["_ScrollingFrame"]

Converted["_TextLabel1"].Font = Enum.Font.Code
Converted["_TextLabel1"].Text = "Terms Of Service (TOS)"
Converted["_TextLabel1"].TextColor3 = Color3.fromHex("d8dee9")
Converted["_TextLabel1"].TextSize = 14
Converted["_TextLabel1"].AnchorPoint = Vector2.new(0.5, 0.5)
Converted["_TextLabel1"].BackgroundColor3 = Color3.fromHex("16232a")
Converted["_TextLabel1"].BorderColor3 = Color3.fromHex("343d46")
Converted["_TextLabel1"].Position = UDim2.new(0.5, 0, 0, 10)
Converted["_TextLabel1"].Size = UDim2.new(1, 0, 0, 20)
Converted["_TextLabel1"].Parent = Converted["_Frame"]
Converted["_TextLabel1"].TextStrokeColor3 = Color3.fromHex("343d46")
Converted["_TextLabel1"].TextStrokeTransparency = 0;

Converted["_Accept"].Font = Enum.Font.Code
Converted["_Accept"].Text = "Scroll to read (8)"
Converted["_Accept"].TextColor3 = Color3.fromHex("57606f")
Converted["_Accept"].TextSize = 14
Converted["_Accept"].BackgroundColor3 = Color3.fromHex("1b2b34")
Converted["_Accept"].BorderColor3 = Color3.fromHex("343d46")
Converted["_Accept"].Position = UDim2.new(0, 0, 1, -1)
Converted["_Accept"].Size = UDim2.new(0.5, 0, 0, 24)
Converted["_Accept"].ZIndex = 0
Converted["_Accept"].Name = "Accept"
Converted["_Accept"].AutoButtonColor = false
Converted["_Accept"].Active = false
Converted["_Accept"].Parent = Converted["_Frame"]

Converted["_UIStroke1"].Color = Color3.fromHex("343d46")
Converted["_UIStroke1"].Parent = Converted["_Accept"]

Converted["_Deny"].Font = Enum.Font.Code
Converted["_Deny"].Text = "Deny"
Converted["_Deny"].TextColor3 = Color3.fromHex("d8dee9")
Converted["_Deny"].TextSize = 14
Converted["_Deny"].BackgroundColor3 = Color3.fromHex("1b2b34")
Converted["_Deny"].BorderColor3 = Color3.fromHex("343d46")
Converted["_Deny"].Position = UDim2.new(0.5, 0, 1, -1)
Converted["_Deny"].Size = UDim2.new(0.5, 0, 0, 24)
Converted["_Deny"].ZIndex = 0
Converted["_Deny"].Name = "Deny"
Converted["_Deny"].Parent = Converted["_Frame"]

Converted["_UIStroke2"].Color = Color3.fromHex("343d46")
Converted["_UIStroke2"].Parent = Converted["_Deny"]

Converted["_Frame1"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame1"].BackgroundTransparency = 0.8
Converted["_Frame1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
Converted["_Frame1"].BorderSizePixel = 0
Converted["_Frame1"].Size = UDim2.new(1, 0, 1, 0)
Converted["_Frame1"].ZIndex = -1
Converted["_Frame1"].Parent = Converted["_ScreenGui"]

Music.Parent = Converted["_ScreenGui"];
Music:Play();

Converted["_MuteMusic"].Font = Enum.Font.Code
Converted["_MuteMusic"].Text = "Mute Music"
Converted["_MuteMusic"].TextColor3 = Color3.fromHex("d8dee9")
Converted["_MuteMusic"].TextSize = 14
Converted["_MuteMusic"].BackgroundColor3 = Color3.fromHex("1b2b34")
Converted["_MuteMusic"].BorderColor3 = Color3.fromHex("343d46")
Converted["_MuteMusic"].AnchorPoint = Vector2.new(0.5, 1)
Converted["_MuteMusic"].Position = UDim2.new(0.5, 0, 0.5, -297)
Converted["_MuteMusic"].Size = UDim2.new(0, 160, 0, 28)
Converted["_MuteMusic"].Name = "MuteMusic"
Converted["_MuteMusic"].Parent = Converted["_ScreenGui"]

Converted["_UIStroke3"].Color = Color3.fromHex("343d46")
Converted["_UIStroke3"].Parent = Converted["_MuteMusic"]

if Library then
    Library:AddToRegistry(Converted["_ScrollingFrame"], {
        BackgroundColor3 = "MainColor",
        BorderColor3 = "OutlineColor"
    })

    Library:AddToRegistry(Converted["_TextLabel"], {
        TextColor3 = "FontColor"
    })

    Library:AddToRegistry(Converted["_TextLabel1"], {
        BackgroundColor3 = "BackgroundColor",
        BorderColor3 = "OutlineColor",
        TextColor3 = "FontColor",
        TextStrokeColor3 = "OutlineColor"
    })

    Library:AddToRegistry(Converted["_Accept"], {
        BackgroundColor3 = "MainColor",
        BorderColor3 = "OutlineColor"
    })

    Library:AddToRegistry(Converted["_UIStroke1"], {
        Color = "OutlineColor"
    })

    Library:AddToRegistry(Converted["_Deny"], {
        BackgroundColor3 = "MainColor",
        BorderColor3 = "OutlineColor",
        TextColor3 = "FontColor"
    })

    Library:AddToRegistry(Converted["_UIStroke2"], {
        Color = "OutlineColor"
    })

    Library:AddToRegistry(Converted["_MuteMusic"], {
        BackgroundColor3 = "BackgroundColor",
        BorderColor3 = "OutlineColor",
        TextColor3 = "FontColor"
    })

    Library:AddToRegistry(Converted["_UIStroke3"], {
        Color = "OutlineColor"
    })

    Library:UpdateColorsUsingRegistry();
end;

local musicMuted = false;
Converted._MuteMusic.MouseButton1Click:Connect(function()
    musicMuted = not musicMuted;
    Music.Volume = musicMuted and 0 or 0.4;
    Converted._MuteMusic.Text = musicMuted and "Unmute Music" or "Mute Music";
end)

local accepted = false;
local hasScrolledToBottom = false;
local minReadSeconds = LPH_OBFUSCATED and 45 or 5;
local secondsLeft = minReadSeconds;

local function acceptIsReady()
    return hasScrolledToBottom and secondsLeft <= 0
end

local function refreshAcceptButton()
    if acceptIsReady() then
        Converted._Accept.Text = "Accept";
        Converted._Accept.TextColor3 = Library and Library.AccentColor or Color3.fromHex("6699cc");
        Converted._Accept.AutoButtonColor = true;
        Converted._Accept.Active = true;
    elseif not hasScrolledToBottom then
        Converted._Accept.Text = string.format("Scroll to read (%d)", secondsLeft);
    else
        Converted._Accept.Text = string.format("Please wait... (%d)", secondsLeft);
    end
end

local function updateCanvasSize()
    local sf = Converted._ScrollingFrame;
    local textLabel = Converted._TextLabel;
    sf.CanvasSize = UDim2.new(0, 0, 0, textLabel.AbsoluteSize.Y + textLabel.Position.Y.Offset * 2);
end

local function checkScrolledToBottom()
    local sf = Converted._ScrollingFrame;
    local maxScroll = math.max(sf.AbsoluteCanvasSize.Y - sf.AbsoluteWindowSize.Y, 0);
    if maxScroll <= 0 or sf.CanvasPosition.Y >= maxScroll - 5 then
        hasScrolledToBottom = true;
        refreshAcceptButton();
    end
end

Converted._TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    updateCanvasSize();
    checkScrolledToBottom();
end)
Converted._ScrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(checkScrolledToBottom);
task.defer(function()
    updateCanvasSize();
    checkScrolledToBottom();
end)

task.spawn(function()
    while secondsLeft > 0 and not accepted do
        task.wait(1);
        secondsLeft -= 1;
        refreshAcceptButton();
    end
end)

Converted._Accept.MouseButton1Click:Connect(function()
    if not acceptIsReady() then
        return    
end

    game:GetService("TweenService"):Create(Converted._Frame1, TweenInfo.new(1), { BackgroundTransparency = 0 }):Play();

    task.wait(1);

    services.RunService:SetRobloxGuiFocused(false)

    for _, object in Converted do
        if object:IsA("TextLabel") or object:IsA("TextButton") then

            game:GetService("TweenService"):Create(object, TweenInfo.new(2), {
                BackgroundTransparency = 1,
                TextTransparency = 1
            }):Play();
        elseif object:IsA("Frame") or object:IsA("ScrollingFrame") then

            game:GetService("TweenService"):Create(object, TweenInfo.new(2), {
                BackgroundTransparency = 1
            }):Play();
        elseif object:IsA("UIStroke") then
            game:GetService("TweenService"):Create(object, TweenInfo.new(2), {
                Transparency = 1
            }):Play();
        end;
    end;

    game:GetService("TweenService"):Create(Music, TweenInfo.new(2), { Volume = 0 }):Play();
    game:GetService("Debris"):AddItem(Music, 2);
    game:GetService("Debris"):AddItem(Converted["_ScreenGui"], 2);
    accepted = true;
    writefile("Project Rain/tos_accepted_82126_0822UTC0.txt", "yes");
end)

Converted._Deny.MouseButton1Click:Connect(function()
    for _, object in Converted do
        if object:IsA("TextLabel") or object:IsA("TextButton") then
 
            game:GetService("TweenService"):Create(object, TweenInfo.new(2), {
                BackgroundTransparency = 1,
                TextTransparency = 1
            }):Play();
        elseif object:IsA("Frame") or object:IsA("ScrollingFrame") then

            game:GetService("TweenService"):Create(object, TweenInfo.new(2), {
                BackgroundTransparency = 1
            }):Play();
        elseif object:IsA("UIStroke") then
            game:GetService("TweenService"):Create(object, TweenInfo.new(2), {
                Transparency = 1
            }):Play();
        end;
    end;
    game:GetService("TweenService"):Create(Music, TweenInfo.new(2), { Volume = 0 }):Play();
    game:GetService("Debris"):AddItem(Music, 2);
    game:GetService("Debris"):AddItem(Converted["_ScreenGui"], 2);
    game.Players.LocalPlayer:Kick("You must accept the Terms of Service to use PR.");
    task.wait()
           
    local roblox_prompt_gui = services.CoreGui:FindFirstChild("RobloxPromptGui")
    if not roblox_prompt_gui then
        return
    end

    roblox_prompt_gui.promptOverlay.ErrorPrompt.TitleFrame.ErrorTitle.TextColor3 = Color3.fromRGB(125, 196, 228)
    roblox_prompt_gui.promptOverlay.ErrorPrompt.TitleFrame.ErrorTitle.Text = "Project Rain"
    roblox_prompt_gui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text = "You must accept the Terms of Service to use PR"
end)

repeat task.wait() until accepted;
task.wait(2);