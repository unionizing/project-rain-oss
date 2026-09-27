local feature = Feature:new("build_stealer")

local toggled = false
local players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local function getSelectedPlayer()
    local playerName = aztup_options.build_stealer_target.Value
    if playerName and playerName ~= "" then
        return players:FindFirstChild(playerName)
    end
    return nil
end

local function onBuildStealPlayer(player, clipboard)
    if not player then
        return
    end
    
    local character = player.Character
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    local backpack = player:FindFirstChild("Backpack")
    if not backpack then
        return
    end

    local AttributePoints = 0
    local Power = 0 
    for i, v in pairs(character:GetAttributes()) do
        if i:match("Stat") then
            AttributePoints = AttributePoints + v
        end
    end
    for i = 1, 20 do
        if AttributePoints <= 15 then
            break        
end
        AttributePoints = AttributePoints - 15
        Power = Power + 1
    end

    local level = math.min(20, math.max(1, Power));

    
    local data = {
        version = 3,
        stats = {
            buildName = string.format("%s %s's Stolen Build", os.date("%B %d %Y"), player.Name),
            buildDescription = "Talents are not stealable anymore - This is just the opponents stats.",
            buildAuthor = "project-rain.net",
            power = level,
            pointsUntilNextPower = 67,
            points = 67,
            pointSpent = 67,
            traitPoints = 0,
            traits = {
                Vitality = character:GetAttribute("Trait_Health"),
                Erudition = character:GetAttribute("Trait_Ether"),
                Songchant = character:GetAttribute("Trait_MantraDamage"),
                Proficiency = character:GetAttribute("Trait_WeaponDamage"),
            },
            meta = {
                Race = "None",
                Oath = "None",
                Murmur = "None",
                Bell = "None",
                Origin = "Castaway",
                Outfit = "None",
            },
        },
        attributes = {
            weapon = {
                ["Heavy Wep."] = character:GetAttribute("Stat_WeaponHeavy"),
                ["Medium Wep."] = character:GetAttribute("Stat_WeaponMedium"),
                ["Light Wep."] = character:GetAttribute("Stat_WeaponLight"),
            },
            base = {
                Strength = character:GetAttribute("Stat_Strength"),
                Fortitude = character:GetAttribute("Stat_Fortitude"),
                Agility = character:GetAttribute("Stat_Agility"),
                Intelligence = character:GetAttribute("Stat_Intelligence"),
                Willpower = character:GetAttribute("Stat_Willpower"),
                Charisma = character:GetAttribute("Stat_Charisma"),
            },
            attunement = {
                Flamecharm = character:GetAttribute("Stat_ElementFire"),
                Frostdraw = character:GetAttribute("Stat_ElementIce"),
                Thundercall = character:GetAttribute("Stat_ElementLightning"),
                Galebreathe = character:GetAttribute("Stat_ElementWind"),
                Shadowcast = character:GetAttribute("Stat_ElementShadow"),
                Ironsing = character:GetAttribute("Stat_ElementMetal"),
                Bloodrend = character:GetAttribute("Stat_ElementBlood"),
            },
        },
        content = {
            mantraModifications = {},
            notes = "",
        },
        meta = {
            tags = {},
            isPrivate = true,
        },
        talents = {},
        mantras = {},
        weapons = "",
        enchant = "",
        motif = "",
        preShrine = {
            base = {
                Strength = 100,
                Fortitude = 100,
                Agility = 100,
                Intelligence = 100,
                Willpower = 100,
                Charisma = 100,
            },
            weapon = {
                ["Heavy Wep."] = 100,
                ["Medium Wep."] = 100,
                ["Light Wep."] = 100,
            },
            attunement = {
                Flamecharm = 100,
                Frostdraw = 100,
                Thundercall = 100,
                Galebreathe = 100,
                Shadowcast = 100,
                Ironsing = 100,
                Bloodrend = 100,
            },
        },
        postShrine = nil,
        favoritedTalents = {},
    }

    data.postShrine = data.attributes

    local meta = data.stats.meta
    local notes = {}

    for _, child in next, backpack:GetChildren() do
        if child.Name:match("Resonance:") then
            meta.Bell = child.Name:gsub("Resonance:", "")
        end

        if child.Name:match("Mantra") and child:GetAttribute("DisplayName") then
            local isRecalled = child.Name:match("RecalledMantra")
            notes[#notes + 1] = (isRecalled and "[RECALLED MANTRA]" or "[USED MANTRA]")
                .. " "
                .. (child:GetAttribute("RichStats") and child:GetAttribute("RichStats"):gsub("\n", " | ") or "NO RICH STATS?")

            if not isRecalled then
                data.mantras[#data.mantras + 1] = child:GetAttribute("DisplayName")
                data.content.mantraModifications[child:GetAttribute("DisplayName")] = {}
            end
        end

        if child.Name == "Weapon" then
            notes[#notes + 1] = "[USED WEAPON] " .. (child:GetAttribute("RichStats") and child:GetAttribute("RichStats"):gsub("\n", " | ") or child.Name)
        end
    end
    for _, instance in next, character:GetChildren() do
        if instance.Name == "Ring" then
            local ringName = instance:GetAttribute("DisplayName")
                or instance:GetAttribute("EquipmentRef")
                or instance.Name
            notes[#notes + 1] = string.format("[EQUIPPED RING] %s\n", ringName)
                .. (instance:GetAttribute("RichStats") and instance:GetAttribute("RichStats"):gsub("\n", " | ") or instance.Name)
        end

        if instance.Name == "Shirt" then
            notes[#notes + 1] = "[EQUIPPED SHIRT ID] " .. instance.ShirtTemplate
        end

        if instance.Name == "Pants" then
            notes[#notes + 1] = "[EQUIPPED PANTS ID] " .. instance.PantsTemplate
        end

        if
            instance.Name:match("Equipment")
            and instance:GetAttribute("RichStats")
            and instance:GetAttribute("DisplayName")
        then
            notes[#notes + 1] = string.format(
                "[EQUIPPED EQUIPMENT] [%s] %s",
                instance.Name,
                instance:GetAttribute("DisplayName")
            ) .. (instance:GetAttribute("RichStats") and instance:GetAttribute("RichStats"):gsub("\n", " | "))
        end
    end

    notes[#notes + 1] = string.format("[HEALTH] %.2f/%.2f", humanoid.Health, humanoid.MaxHealth)

    data.content.notes = table.concat(notes, "\n\n")

    
    local response = request({
        Url = "https://deepwoken.co/api/proxy/builds",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json",
            ["Origin"] = "https://deepwoken.co",
            ["Referer"] = "https://deepwoken.co/builder",
            ["Sec-Fetch-Site"] = "same-origin",
            ["Sec-Fetch-Mode"] = "cors",
            ["Sec-Fetch-Dest"] = "empty",
        },
        Body = HttpService:JSONEncode(data)
    })

    if not response then
        return
    end

    if not response.Success then
        return
    end

    if not response.Body then
        return
    end

    local decoded = HttpService:JSONDecode(response.Body)

    if not decoded or not decoded.id then
        return
    end

    
    local buildUrl = string.format("https://deepwoken.co/builder?id=%s", decoded.id)
    
    if clipboard then
        setclipboard(buildUrl)
    end

    local path = string.format("%s %s Stolen Build", os.date("%B %d %Y"), player.Name);
    Logger:notify_sound(string.format("Successfully stole %s's build, %s & saved to file.", player.Name, buildUrl))

    if not isfolder("Project Rain/Stolen Builds") then
        makefolder("Project Rain/Stolen Builds")
    end
    writefile("Project Rain/Stolen Builds/" .. path .. ".txt", string.format([[https://project-rain.net
stolen on %s
build url: %s
%s]], os.date("%B %d %Y"), buildUrl, data.content.notes));
end

function feature:enable()
    if toggled then 
        return 
    end
    
    toggled = true
    aztup_options.build_stealer_target:OnChanged(function()
        local player = getSelectedPlayer()
        if player then
            onBuildStealPlayer(player,true)
        end
    end)

    if is_chime then
        local stolen = false;
        for _, player in services.Players:GetPlayers() do
            if player ~= services.Players.LocalPlayer then
                onBuildStealPlayer(player)
                stolen = true;
                break            
end
        end

        if not stolen then
            services.Players.PlayerAdded:Connect(function(player)
                if stolen then return end
                task.wait(15);
                onBuildStealPlayer(player)
            end)
        end
    end
    
end

function feature:disable()
    if not toggled then
        return
    end
    
    toggled = false
end

return feature