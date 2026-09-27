


local OriginalStore = {}
OriginalStore.__index = OriginalStore
function OriginalStore.new()
    return setmetatable({stored = false}, OriginalStore)
end
function OriginalStore:mark(data, index)
    if not self.stored then
        self.data, self.index, self.value, self.stored = data, index, data[index], true
    end
end
function OriginalStore:set(data, index, value)
    self:mark(data, index)
    data[index] = value
end
function OriginalStore:restore()
    if self.stored then
        pcall(function() self.data[self.index] = self.value end)
        self.stored = false
    end
end

local OriginalStoreManager = {}
OriginalStoreManager.__index = OriginalStoreManager
function OriginalStoreManager.new()
    return setmetatable({inner = {}}, OriginalStoreManager)
end
function OriginalStoreManager:add(data, index, value)
    local object = self.inner[data] or OriginalStore.new()
    object:set(data, index, value)
    self.inner[data] = object
end
function OriginalStoreManager:restore()
    for _, store in next, self.inner do
        store:restore()
    end
    self.inner = {}
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local TalentPickerData = nil
local TalentsData = nil
local talentHighlighterMap = OriginalStoreManager.new()
local virtualElements = {}
local isRefreshing = false

local nameCache = {}
local buildLookup = {}
local lastUpdate = 0
local UPDATE_INTERVAL = 0.5 

local function cleanName(str)
    if not str or str == "" then return "" end
    if nameCache[str] then return nameCache[str] end
    local cleaned = str:gsub(" [HVY]", ""):gsub(" [LHT]", ""):gsub(" [MED]", ""):lower():gsub("%s*%[.-%]%s*", " "):gsub("^%d+", ""):gsub("z%w+divider", ""):gsub("[^%a%d]", "")
    nameCache[str] = cleaned
    return cleaned
end

local function checkReqs(talent, stats)
    if not talent or not stats then return false end
    if talent.requirements and talent.requirements.stats then
        for stat, required in pairs(talent.requirements.stats) do
            local current = stats[stat] or 0
            if current < required then
                return false
            end
        end
        return true
    end
    if talent.reqs then
        for _, cat in ipairs({"base", "weapon", "attunement"}) do
            local catReqs = talent.reqs[cat]
            if catReqs then
                for stat, required in pairs(catReqs) do
                    if required > 0 then
                        local current = stats[stat] or 0
                        if current < required then
                            return false
                        end
                    end
                end
            end
        end
        return true
    end
    return false
end

local function getTableLength(t)
    local count = 0
    for _ in pairs(t or {}) do count = count + 1 end
    return count
end

local function flattenAttributes(attrs)
    if not attrs then return {} end
    local flattened = {}
    if attrs.weapon then
        for k, v in pairs(attrs.weapon) do
            flattened[k] = v
        end
    end
    if attrs.attunement then
        for k, v in pairs(attrs.attunement) do
            flattened[k] = v
        end
    end
    if attrs.base then
        for k, v in pairs(attrs.base) do
            flattened[k] = v
        end
    end
    return flattened
end

local function normalizeBuildData(data)
    if not data then return nil end
    return {
        talents = data.talents or {},
        mantras = data.mantras or {},
        attributes = flattenAttributes(data.attributes),
        preShrine = flattenAttributes(data.preShrine),
    }
end

local function refreshMissingTalents()
    if not TalentPickerData or isRefreshing then return end
    isRefreshing = true
    
    local backpack = LocalPlayer.PlayerGui:FindFirstChild("BackpackGui")
    if not backpack then isRefreshing = false return end
    
    local talentScroll = backpack.RightFrame.TalentSheet.Container.TalentScroll
    if not talentScroll then isRefreshing = false return end
    
    for _, el in pairs(virtualElements) do if el then el:Destroy() end end
    table.clear(virtualElements)
    
    local template = nil
    for _, child in ipairs(talentScroll:GetDescendants()) do
        if (child:IsA("Frame") or child:IsA("TextButton")) and not child.Name:find("Missing_") then
            if child:FindFirstChild("Title") and child:FindFirstChild("Icon") then
                template = child
                break
            end
        end
    end
    
    if not template then isRefreshing = false return end
    
    local par = talentScroll
    for _, item in ipairs(talentScroll:GetDescendants()) do
        if item.Name == "Outfit" or item.Name == "Quest" or item.Name == "Race" then
            par = item
            break
        end
    end
    
    local ownedNames = {}
    for _, item in ipairs(talentScroll:GetDescendants()) do
        local title = item:FindFirstChild("Title")
        if title and not item.Name:find("Missing_") then 
            ownedNames[cleanName(title.Text)] = true 
        end
    end
    
    for _, plannedName in ipairs(TalentPickerData.talents or {}) do
        local cleanedPlanned = cleanName(plannedName)
        if not ownedNames[cleanedPlanned] then
            local clone = template:Clone()
            clone.Name = "Missing_" .. cleanedPlanned
            clone.BackgroundColor3 = Color3.new(1, 1, 1)
            clone.BackgroundTransparency = 0.95
            
            local title = clone:FindFirstChild("Title")
            if title then
                title.Text = plannedName
                title.TextColor3 = Library.AccentColor
                title.TextTransparency = 0
            end
            
            local icon = clone:FindFirstChild("Icon")
            if icon then icon.Visible = false end
            
            local stroke = clone:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", clone)
            stroke.Enabled, stroke.Transparency, stroke.Thickness = true, 0.8, 1
            stroke.Color = Color3.new(1, 1, 1)
            
            table.insert(virtualElements, clone)
            clone.Parent = par
        end
    end
    
    task.delay(0.5, function() isRefreshing = false end)
end

local function applyHighlight(item, talentScroll)
    if not TalentPickerData or not TalentsData then return end
    
    local title = item:FindFirstChild("Title")
    local border = item:FindFirstChild("Border")
    
    local innerCard = item:FindFirstChild("CardFrame")
    if innerCard then
        border = border or innerCard:FindFirstChild("Border")
        title = title or innerCard:FindFirstChild("Title")
    end
    
    if not border then
        for _, child in ipairs(item:GetChildren()) do
            if child:IsA("ImageLabel") and child.Name ~= "Icon" then
                border = child
                break
            end
        end
    end
    
    if title or border then
        local nameText = (title and title.Text ~= "") and title.Text or item.Name
        local cleanedLabel = cleanName(nameText)
        local cleanedUncleaned = nameText:lower()
        
        if cleanedLabel:match('roll2') or cleanedLabel:match('fold') then return end
        
        local targetColor = Color3.fromRGB(255, 0, 100)
        
        for _, mantraName in ipairs(TalentPickerData.mantras or {}) do
            if cleanName(mantraName):match(cleanedLabel) then
                targetColor = Color3.fromRGB(0, 255, 120)
                break
            end
        end
        
        if buildLookup[cleanedLabel] then
            local talentObj = TalentsData.talents and TalentsData.talents[cleanedUncleaned]
            if talentObj then
                local preCheck = checkReqs(talentObj, TalentPickerData.preShrine)
                local postCheck = checkReqs(talentObj, TalentPickerData.attributes)
                local isPre = preCheck and not postCheck
                if isPre then
                    targetColor = Color3.fromRGB(255, 187, 0)
                else
                    targetColor = Color3.fromRGB(0, 255, 120)
                end
            else
                targetColor = Color3.fromRGB(0, 255, 120)
            end
        end
        
        if item.Name:find('Missing_') then
            local talentObj = TalentsData.talents and TalentsData.talents[cleanedUncleaned]
            if talentObj then
                local preCheck = checkReqs(talentObj, TalentPickerData.preShrine)
                local postCheck = checkReqs(talentObj, TalentPickerData.attributes)
                local isPre = preCheck and not postCheck
                if isPre then
                    targetColor = Color3.fromRGB(247, 0, 255)
                else
                    targetColor = Color3.fromRGB(255, 187, 0)
                end
            else
                targetColor = Color3.fromRGB(255, 187, 0)
            end
        end
        
        if title and talentScroll and title:IsDescendantOf(talentScroll) then
            talentHighlighterMap:add(title, "TextColor3", targetColor)
            talentHighlighterMap:add(title, "TextTransparency", 0.25)
            local stroke = title:FindFirstChildOfClass("UIStroke")
            if stroke then
                talentHighlighterMap:add(stroke, "Color", targetColor)
                talentHighlighterMap:add(stroke, "Transparency", 0.25)
            end
        end
        
        if border and border:IsA("ImageLabel") and border.Name ~= "Icon" then
            talentHighlighterMap:add(border, "ImageColor3", targetColor)
        end
    end
end

local function applyAttributes()
    local preshrineLabels = {
        ["Heavy Wep."] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.WeaponSheet.Container.WeaponHeavy.Abbrev,
        ["Medium Wep."] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.WeaponSheet.Container.WeaponMedium.Abbrev,
        ["Light Wep."] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.WeaponSheet.Container.WeaponLight.Abbrev,
        ["Strength"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.LeftSheets.AttrSheet.Container.Strength.Abbrev,
        ["Fortitude"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.LeftSheets.AttrSheet.Container.Fortitude.Abbrev,
        ["Agility"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.LeftSheets.AttrSheet.Container.Agility.Abbrev,
        ["Intelligence"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.LeftSheets.AttrSheet.Container.Intelligence.Abbrev,
        ["Willpower"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.LeftSheets.AttrSheet.Container.Willpower.Abbrev,
        ["Charisma"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.LeftSheets.AttrSheet.Container.Charisma.Abbrev,
        ["Flamecharm"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementFire.Abbrev,
        ["Frostdraw"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementIce.Abbrev,
        ["Thundercall"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementLightning.Abbrev,
        ["Galebreathe"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementWind.Abbrev,
        ["Shadowcast"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementShadow.Abbrev,
        ["Ironsing"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementMetal.Abbrev,
        ["Bloodrend"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementBlood.Abbrev,
    }
    
    local postshrineLabels = {
        ["Heavy Wep."] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.WeaponSheet.Container.WeaponHeavy.Label,
        ["Medium Wep."] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.WeaponSheet.Container.WeaponMedium.Label,
        ["Light Wep."] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.WeaponSheet.Container.WeaponLight.Label,
        ["Strength"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.LeftSheets.AttrSheet.Container.Strength.Label,
        ["Fortitude"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.LeftSheets.AttrSheet.Container.Fortitude.Label,
        ["Agility"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.LeftSheets.AttrSheet.Container.Agility.Label,
        ["Intelligence"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.LeftSheets.AttrSheet.Container.Intelligence.Label,
        ["Willpower"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.LeftSheets.AttrSheet.Container.Willpower.Label,
        ["Charisma"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.LeftSheets.AttrSheet.Container.Charisma.Label,
        ["Flamecharm"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementFire.Label,
        ["Frostdraw"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementIce.Label,
        ["Thundercall"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementLightning.Label,
        ["Galebreathe"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementWind.Label,
        ["Shadowcast"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementShadow.Label,
        ["Ironsing"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementMetal.Label,
        ["Bloodrend"] = local_player.instance.PlayerGui.BackpackGui.RightFrame.JournalFrame.Panels.AttributeFrame.Sheets.RightSheets.ElementSheet.Container.ElementBlood.Label,
    }
    
    if not TalentPickerData then return end
    
    for attrKey, attrValue in pairs(TalentPickerData.preShrine or {}) do
        if preshrineLabels[attrKey] then
            preshrineLabels[attrKey].Text = 'Pre: ' .. attrValue
        end
    end
    
    for attrKey, attrValue in pairs(TalentPickerData.attributes or {}) do
        if postshrineLabels[attrKey] then
            postshrineLabels[attrKey].Text = 'Post: ' .. attrValue
        end
    end
end

local feat
feat = Feature:new("talent_highlighter", RunService.Heartbeat, function()
    if not TalentPickerData and not TalentsData then return end
    
    local now = tick()
    if now - lastUpdate < UPDATE_INTERVAL then return end
    lastUpdate = now
    
    local backpack = LocalPlayer.PlayerGui:FindFirstChild("BackpackGui")
    if not backpack then return end
    
    local talentSheet = backpack.RightFrame:FindFirstChild("TalentSheet")
    if talentSheet and talentSheet.Visible then
        local scroll = talentSheet.Container.TalentScroll
        for _, child in ipairs(scroll:GetChildren()) do
            applyHighlight(child, scroll)
        end
        
        local card = talentSheet.TalentDisplay:FindFirstChild("CardFrame")
        if card then applyHighlight(card, scroll) end
        
        local ownedSection = scroll:FindFirstChild("Owned")
        if ownedSection then
            for _, ownedTalent in ipairs(ownedSection:GetChildren()) do
                local title = ownedTalent:FindFirstChild("Title")
                local nameText = title and title.Text or ownedTalent.Name
                local cleanedLabel = cleanName(nameText)
                local inBuild = false
                for _, plannedName in ipairs(TalentPickerData.talents or {}) do
                    if cleanName(plannedName) == cleanedLabel then
                        inBuild = true
                        break
                    end
                end
                local color = inBuild and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,0,100)
                if title then
                    talentHighlighterMap:add(title, "TextColor3", color)
                    talentHighlighterMap:add(title, "TextTransparency", 0.25)
                    local stroke = title:FindFirstChildOfClass("UIStroke")
                    if stroke then
                        talentHighlighterMap:add(stroke, "Color", color)
                        talentHighlighterMap:add(stroke, "Transparency", 0.25)
                    end
                end
                local border = ownedTalent:FindFirstChild("Border")
                if border and border:IsA("ImageLabel") and border.Name ~= "Icon" then
                    talentHighlighterMap:add(border, "ImageColor3", color)
                end
            end
        end
    end
    
    local talentGui = LocalPlayer.PlayerGui:FindFirstChild("TalentGui")
    if talentGui then
        local choiceFrame = talentGui:FindFirstChild("ChoiceFrame")
        if choiceFrame and choiceFrame.Visible then
            for _, card in ipairs(choiceFrame:GetChildren()) do
                if not card:IsA("UIComponent") then
                    applyHighlight(card, nil)
                end
            end
        end
    end
    
    local deckGui = backpack and backpack:FindFirstChild('LeftFrame') and backpack.LeftFrame:FindFirstChild("DeckFrame")
    if deckGui and deckGui.Visible then
        for _, card in ipairs(deckGui.TalentScroll:GetChildren()) do
            if card:IsA('TextButton') then
                applyHighlight(card.CardFrame, nil)
            end
        end
        
        local mantraScroll = deckGui:FindFirstChild("MantraScroll")
        if mantraScroll then
            for _, mantraCard in ipairs(mantraScroll:GetChildren()) do
                applyHighlight(mantraCard, nil)
            end
        end
    end
    
    local choicePrompt = LocalPlayer.PlayerGui:FindFirstChild("ChoicePrompt")
    if choicePrompt then
        local scrollFrame = choicePrompt:FindFirstChild("ScrollingFrame", true)
        if scrollFrame then
            for _, child in ipairs(scrollFrame:GetChildren()) do
                local cardFrame = child:FindFirstChild("CardFrame")
                if cardFrame then
                    applyHighlight(cardFrame, nil)
                end
            end
        end
    end
    
    applyAttributes()
end)

function feat:enable()
    repeat task.wait() until not aztup.flags.talent_highlighter or aztup_options.talent_highlighter_url.Value and aztup_options.talent_highlighter_url.Value:match("id=([%w%d]+)")
    if not aztup.flags.talent_highlighter then return end
    
    local url = aztup_options.talent_highlighter_url.Value
    local builderId = url:match("id=([%w%d]+)")
    if not builderId then return end
    
    local backpack = LocalPlayer.PlayerGui:WaitForChild("BackpackGui")
    local talentScroll = backpack.RightFrame.TalentSheet.Container.TalentScroll
    
    aztup.maid:give_task(talentScroll.ChildAdded:Connect(function(c)
        if not c.Name:find("Missing_") then 
            task.delay(0.2, refreshMissingTalents)
        end
    end))
    
    task.spawn(function()
        local commonHeaders = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json",
            ["Origin"] = "https://deepwoken.co",
            ["Referer"] = "https://deepwoken.co/builder",
            ["Sec-Fetch-Site"] = "same-origin",
            ["Sec-Fetch-Mode"] = "cors",
            ["Sec-Fetch-Dest"] = "empty",
        }
        
        local buildRes = request({
            Url = "https://new.deepwoken.co/api/proxy/builds/" .. builderId,
            Method = "GET",
            Headers = commonHeaders
        })
        
        if buildRes and buildRes.StatusCode == 200 then
            local rawData = HttpService:JSONDecode(buildRes.Body)
            TalentPickerData = normalizeBuildData(rawData)
        else
            return Logger:short_notify(string.format("failed to get data from deepwoken.co: %s", buildRes and buildRes.StatusCode or "???"))
        end
        
        local talentRes = request({
            Url = "https://new.deepwoken.co/api/proxy/get?type=all",
            Method = "GET",
            Headers = commonHeaders
        })
        
        if talentRes and talentRes.StatusCode == 200 then
            local data = HttpService:JSONDecode(talentRes.Body)
            local talentsDict = {}
            for _, talent in ipairs(data.talents or {}) do
                if talent and talent.name then
                    talentsDict[talent.name:lower()] = talent
                end
            end
            TalentsData = { talents = talentsDict }
        else
            TalentsData = { talents = {} }
        end
        
        table.clear(buildLookup)
        for _, bName in ipairs(TalentPickerData.talents or {}) do
            buildLookup[cleanName(bName)] = true
        end
        
        refreshMissingTalents()
    end)
end

function feat:disable()
    talentHighlighterMap:restore()
    for _, el in pairs(virtualElements) do if el then el:Destroy() end end
    table.clear(virtualElements)
    table.clear(nameCache)
    table.clear(buildLookup)
    TalentPickerData, TalentsData = nil, nil
end

return feat










