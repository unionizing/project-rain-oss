
local data_replication = require(services.ReplicatedStorage.Info.DataReplication);

local builder = {
    loaded_url = nil,
    url_override = nil,
    build_config = nil,
    running = false,
    points_running = false,
    shrined = false
}

local to_burn = {
    "Risky Moves",
    "Observation",
    "Safety Dance",
    "Neuroplasticity",
    "Return to the Dark Ages",
    "Eruption Path: Lava Serpent",
    "The Final Act",
    "Orbital Ice",
    "Fists of Fortitude",
    "Singularity",
    "Sightless Still",
    "Million Ton Piercer",
    "Ether Overdrive",
    "Bulldozer",
    "Dazing Finisher",
    "Wraith Path: Twisted Puppets",
    "Azure Flames",
    "Everchanging Aegis"
}


local last_notified = {};
function long_notify_sound(text)
    if last_notified[text] then return end
    last_notified[text] = true;
    task.delay(10, function() 
        last_notified[text] = nil;
    end)
    return Logger:long_notify_sound(text)
end

local function extract_Word_And_Numeral(str)
    local words = {
        vitality = true,
        songchant = true,
        erudition = true,
        proficiency = true,
    }
    
    local romans = {
        { "vi", 6 },
        { "v", 5 },
        { "iv", 4 },
        { "iii", 3 },
        { "ii", 2 },
        { "i", 1 },
    }
    
    local lower = str:lower()
    
    for word in pairs(words) do
        local start = lower:find(word, 1, true)
        if start then
            local after = lower:sub(start + #word)
            
            for _, r in ipairs(romans) do
                local roman, value = r[1], r[2]
                if after:sub(1, #roman) == roman then
                    return word, value
                end
            end
        end
    end
    
    return nil, nil
end

local function clean_name(str)
    if not str or str == "" then return "" end
    local cleaned = str:lower():gsub("%s*%[.-%]%s*", " "):gsub("^%d+", ""):gsub("z%w+divider", ""):gsub("[^%a%d]", "")
    return cleaned
end

local function flatten_attributes(attrs)
    if not attrs then return {} end

    local flattened = {}
    for _, category in ipairs({"weapon", "attunement", "base"}) do
        local categoryStats = attrs[category]
        if categoryStats then
            for stat, value in pairs(categoryStats) do
                flattened[stat] = value
            end
        end
    end

    return flattened
end

local function normalize_build_data(data)
    if not data then return nil end

    return {
        talents = data.talents or {},
        mantras = data.mantras or {},
        attributes = flatten_attributes(data.attributes),
        preShrine = flatten_attributes(data.preShrine),
        stats = data.stats or {},
    }
end

local function check_reqs(talent, stats)
    if not talent or not stats then return false end

    if talent.requirements and talent.requirements.stats then
        for stat, required in pairs(talent.requirements.stats) do
            if (stats[stat] or 0) < required then return false end
        end
        return true
    end

    if talent.reqs then
        for _, cat in ipairs({"base", "weapon", "attunement"}) do
            local catReqs = talent.reqs[cat]
            if catReqs then
                for stat, required in pairs(catReqs) do
                    if required > 0 and (stats[stat] or 0) < required then return false end
                end
            end
        end
        return true
    end

    return false
end

local function get_build_id(url)
    if not url then return nil end
    return url:match("id=([%w%d]+)")
end

local function get_build_url()
    if builder.url_override and builder.url_override ~= "" then
        return builder.url_override    
end

    local url = aztup_options.auto_builder_url and aztup_options.auto_builder_url.Value;
    if url and url ~= "" then return url end

    return persistent_data:get("auto_builder_url", "")
end


local attribute_requests = {
    ["Heavy Wep."]   = "WeaponHeavy",
    ["Medium Wep."]  = "WeaponMedium",
    ["Light Wep."]   = "WeaponLight",
    ["Strength"]     = "Strength",
    ["Fortitude"]    = "Fortitude",
    ["Agility"]      = "Agility",
    ["Intelligence"] = "Intelligence",
    ["Willpower"]    = "Willpower",
    ["Charisma"]     = "Charisma",
    ["Flamecharm"]   = "ElementFire",
    ["Frostdraw"]    = "ElementIce",
    ["Thundercall"]  = "ElementLightning",
    ["Galebreathe"]  = "ElementWind",
    ["Shadowcast"]   = "ElementShadow",
    ["Ironsing"]     = "ElementMetal",
    ["Bloodrend"]    = "ElementBlood",
}

local function resolve_attribute(name)
    if not name then return nil end
    if attribute_requests[name] then return attribute_requests[name] end

    local cleaned = clean_name(name)

    for label, request_name in pairs(attribute_requests) do
        if clean_name(label) == cleaned or clean_name(request_name) == cleaned then
            return request_name
        end
    end

    return nil
end

local function is_player_data(data)
    return typeof(data) == "table" and typeof(data.StatStrength) == "number"
end

local function get_player_data()
    for attempt = 1, 2 do
        local ok, data = pcall(function()
            return data_replication.GetData()        
end);

        if ok and is_player_data(data) then return data end

        local requests = services.ReplicatedStorage:FindFirstChild("Requests");
        local get = requests and requests:FindFirstChild("Get");
        if get then
            ok, data = pcall(function()
                return get:InvokeServer()            
end);

            if ok and is_player_data(data) then return data end
        end;

        if attempt < 2 then task.wait(0.2); end;
    end;

    return nil
end

local function stat_of(data, request_name)
    return tonumber(data["Stat" .. request_name]) or 0
end

local function available_points(data)
    return (tonumber(data.AvailableAttributePoints) or 0)
        + (tonumber(data.FullAttributePoints) or 0)
        + (tonumber(data.FreeAttributePoints) or 0)
end

local increase_attribute = nil
local function raise_attribute(request_name)
    if not increase_attribute then
        local requests = services.ReplicatedStorage:FindFirstChild("Requests");
        increase_attribute = requests and requests:FindFirstChild("IncreaseAttribute");
    end

    if not increase_attribute then return false end

    return (pcall(function()
        increase_attribute:InvokeServer(request_name)
    end))
end

local function request_build_data(builder_id)
    if not builder_id then return nil end

    local response = request({
        Url = "https://new.deepwoken.co/api/proxy/builds/" .. builder_id,
        Method = "GET",
        Headers = {

            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json",
            ["Origin"] = "https://deepwoken.co",
            ["Referer"] = "https://deepwoken.co/builder",
            ["Sec-Fetch-Site"] = "same-origin",
            ["Sec-Fetch-Mode"] = "cors",
            ["Sec-Fetch-Dest"] = "empty"        }
    })

    if not response or response.StatusCode ~= 200 or not response.Body then
        return nil
    end

    return services.HttpService:JSONDecode(response.Body)
end

local function request_talent_data()
    local response = request({
        Url = "https://new.deepwoken.co/api/proxy/get?type=all",
        Method = "GET",
        Headers = {

            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json",
            ["Origin"] = "https://deepwoken.co",
            ["Referer"] = "https://deepwoken.co/builder",
            ["Sec-Fetch-Site"] = "same-origin",
            ["Sec-Fetch-Mode"] = "cors",
            ["Sec-Fetch-Dest"] = "empty",        }
    })

    if not response or response.StatusCode ~= 200 or not response.Body then
        return nil
    end

    return services.HttpService:JSONDecode(response.Body)
end

local function setup_config()
    local url = get_build_url()
    local builderId = get_build_id(url)
    if not builderId then return end
    
    local buildData = request_build_data(builderId)
    if buildData then 
        builder.build_config = normalize_build_data(buildData)
        builder.build_config.preShrine_talents = {}
        builder.build_config.postShrine_talents = {}
        builder.loaded_url = url
        
        
        local talent_data = request_talent_data()
        if talent_data and builder.build_config then 
            local talent_lookup = {}
            for _, talent in ipairs(talent_data.talents or {}) do
                if talent and talent.name then
                    talent_lookup[talent.name:lower()] = talent
                end
            end

            for _, name in ipairs(builder.build_config.talents or {}) do
                local talentobj = talent_lookup[name:lower()]
                if not talentobj then continue end

                local isPre = check_reqs(talentobj, builder.build_config.preShrine) and not check_reqs(talentobj, builder.build_config.attributes)
                table.insert(isPre and builder.build_config.preShrine_talents or builder.build_config.postShrine_talents, (name:gsub(" [HVY]", ""):gsub(" [LHT]", ""):gsub(" [MED]", "")))
            end
        end
    end
end

function builder:ensure_config()
    if not self.build_config or self.loaded_url ~= get_build_url() then
        for attempt = 1, 3 do
            setup_config()
            if self.build_config then break end

            task.wait(1.5);
        end

        if self.build_config then
            local id = get_build_id(self.loaded_url) or "?";

            print("[auto builder] loaded build " .. tostring(self.loaded_url));
            Logger:notify("Auto Builder: using build " .. id);
        end
    end

    if self.build_config then return true end

    return false
end


function builder:shrine_ready()
    if not self.build_config then return false, 0 end

    local data = get_player_data()
    if not data then return false, 0 end

    local wanted, missing = 0, 0

    for label, target in pairs(self.build_config.preShrine or {}) do
        target = tonumber(target) or 0

        if target > 0 then
            local request_name = resolve_attribute(label)
            if request_name then
                wanted += target
                missing += math.max(0, target - stat_of(data, request_name))
            end
        end
    end

    if wanted == 0 then return false, 0 end

    return missing == 0, missing
end

local shrine_button;

function builder:manual_shrine()
    if shrine_button then return end

    pcall(function()
        Library:Notify("Please click this button when you have shrined and finished up.", 9e9)
    end)

    shrine_button = Instance.new("TextButton", services.CoreGui.RobloxGui);
    shrine_button.Size = UDim2.fromOffset(200, 50)
    shrine_button.Position = UDim2.fromScale(0.1, 0.5)
    shrine_button.AnchorPoint = Vector2.new(0.5, 0.5)

    shrine_button.BackgroundTransparency = 0.5
    shrine_button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

    shrine_button.TextColor3 = Color3.fromRGB(255, 255, 255)
    shrine_button.Text = "I have shrined."

    shrine_button.Activated:Connect(function()
        self.shrined = true;
        self.logged_targets = false;

        pcall(function()
            aztup_toggles.auto_builder_shrined:SetValue(true);
        end)

        shrine_button:Destroy();
        shrine_button = nil;
    end)
end

function builder:shrine_check()
    if self.shrined then return end
    if persistent_data:get('auto_progress', false) then return end

    if not self:shrine_ready() then return end

    self:manual_shrine()
end


function builder:finished()
    if not self.build_config then return false, 0 end
    if not self.shrined then return false, 0 end

    local data = get_player_data()
    if not data then return false, 0 end

    local wanted, missing = 0, 0

    for label, target in pairs(self.build_config.attributes or {}) do
        target = tonumber(target) or 0

        if target > 0 then
            local request_name = resolve_attribute(label)
            if request_name then
                wanted += target
                missing += math.max(0, target - stat_of(data, request_name))
            end
        end
    end

    if wanted == 0 then return false, 0 end

    return missing == 0, missing
end

function builder:missing_for(label)
    if not self.build_config then return 0 end

    local data = get_player_data()
    if not data then return 0 end

    local targets = self:_attribute_targets(data)
    if not targets then return 0 end

    local target = tonumber(targets[label]) or 0
    if target <= 0 then return 0 end

    local request_name = resolve_attribute(label)
    if not request_name then return 0 end

    return math.max(0, target - stat_of(data, request_name))
end

function builder:_attribute_targets(data)
    local config = self.build_config;
    if not config then return nil end

    local pre = config.preShrine or {};
    if not data then return pre end
    if not builder.shrined then return pre end;

    local post = config.attributes;
    if not post or not next(post) then return pre end;

    return post
end

function builder:spend_points()
    if not self.build_config then
        return
    end

    local data = get_player_data()
    if not data then
        return
    end

    local targets = self:_attribute_targets(data)
    if not targets or not next(targets) then
        return
    end

    local spendable = available_points(data);

    local wanted = {};

    for label, target in pairs(targets) do
        local request_name = resolve_attribute(label)

        if request_name then
            local goal = tonumber(target) or 0;

            table.insert(wanted, {
                label = label,
                request = request_name,
                target = goal,
                misses = 0,
                budget = math.max(0, goal - stat_of(data, request_name)),
            });
        end
    end

    table.sort(wanted, function(a, b)
        return a.request < b.request
    end);

    if not self.logged_targets then
        self.logged_targets = true;

        local lines = {};
        for _, entry in ipairs(wanted) do
            table.insert(lines, string.format("    %s -> %s  now %i, target %i, budget %i",
                entry.label, entry.request, stat_of(data, entry.request), entry.target, entry.budget));
        end

        print(string.format("[auto builder] %s spread from %s | %i points to spend\n%s",
            self.shrined and "POST shrine" or "PRE shrine",
            tostring(self.loaded_url),
            spendable,
            table.concat(lines, "\n")));
    end

    if spendable <= 0 then return end

    local raised = true;

    while raised do
        raised = false;

        for _, entry in ipairs(wanted) do
            if not self.points_running then return end
            if available_points(data) <= 0 then return end

            if entry.misses < 2 and entry.budget > 0 and stat_of(data, entry.request) < entry.target then
                local before = stat_of(data, entry.request);
                if not raise_attribute(entry.request) then return end

                entry.budget -= 1;

                task.wait(0.35)
                data = get_player_data() or data;

                if stat_of(data, entry.request) > before then
                    print(string.format("[auto builder] %s %i -> %i (target %i)",
                        entry.request, before, stat_of(data, entry.request), entry.target));

                    entry.misses = 0;
                    raised = true;
                else
                    entry.misses += 1;
                end
            end
        end
    end
end

function builder._choose_talent(card)
    firesignal(card.MouseButton1Click, card)
    long_notify_sound("Talent chosen: " .. card.Name)
end

local function get_choice()
    local data = get_player_data()
    if not data then return nil end

    local special = data.SpecialChoice
    if special and special.Type and special.Selection and #special.Selection > 0 then
        return special.Selection, special.Type, true
    end

    local choice = data.TalentChoice
    if choice and choice.Type and choice.Selection and #choice.Selection > 0 then
        return choice.Selection, choice.Type, false
    end

    return nil
end

local mystery_mantras = nil
pcall(function()
    mystery_mantras = require("@src/features/removals/mantra_revealer/mantras".."");
end)

local function card_is_mystery(card)
    return card.Mystery == true
end

local function card_label(card)
    if card_is_mystery(card) then
        return (mystery_mantras and mystery_mantras[card.Name]) or card.MantraName or card.RichName or card.Name
    end

    return card.MantraName or card.RichName or (mystery_mantras and mystery_mantras[card.Name]) or card.Name
end

local function build_elements()
    local config = builder.build_config
    if not config then return {} end

    local elements = {}

    for _, spread in ipairs({config.preShrine or {}, config.attributes or {}}) do
        for label, value in pairs(spread) do
            if (tonumber(value) or 0) > 0 then
                local request_name = resolve_attribute(label)
                if request_name and request_name:find("^Element") then
                    elements[(request_name:gsub("^Element", ""))] = request_name
                end
            end
        end
    end

    return elements
end

local function points_left_per_attunement(data)
    local points_left = {}
    if not data then return points_left end

    local targets = builder:_attribute_targets(data)
    if not targets then return points_left end

    for label, value in pairs(targets) do
        local request_name = resolve_attribute(label)
        if not request_name or not request_name:find("^Element") then continue end

        local element = request_name:gsub("^Element", "")
        points_left[element] = math.max(0, (tonumber(value) or 0) - stat_of(data, request_name))
    end

    return points_left
end

local function most_needed_mantra(cards, data, allowed)
    local points_left = points_left_per_attunement(data)
    local best, most_needed = nil, -1

    for _, card in ipairs(cards) do
        if not allowed(card) then continue end

        local needed = (card.Element and points_left[card.Element]) or 0
        if needed > most_needed then
            best, most_needed = card, needed
        end
    end

    return best
end

local function owns_element_mantra(data, element)
    for _, mantra in pairs(data.Mantras or {}) do
        if typeof(mantra) == "table" then
            if mantra.Element == element then return true end
            if typeof(mantra.Name) == "string" and mantra.Name:match(":(%w+)$") == element then return true end
        elseif typeof(mantra) == "string" and mantra:match(":(%w+)$") == element then
            return true
        end
    end

    return false
end

local train_mantras = {
    Fire = {
        ["Squad:Fire"]      = true, 
        ["Blade:Fire"]      = true, 
    },
    Ice = {
        ["Dice:Ice"]        = true, 
        ["Beam:Ice"]        = true, 
        ["Squad:Ice"]       = true, 
    },
    Lightning = {
        ["Beam:Lightning"]  = true, 
        ["Blade:Lightning"] = true, 
    },
    Wind = {
        ["Blade:Wind"]      = true, 
        ["HeavyKick:Wind"]  = true, 
    },
    Shadow = {
        ["Blade:Shadow"]    = true, 
        ["Choke:Shadow"]    = true, 
    },
    Blood = {
        ["Forge:Blood"]     = true, 
    },
    Metal = {
        ["Eruption:Metal"]  = true, 
        ["Toss:Metal"]      = true, 
    },
    Charisma = {
        ["Taunt:Charisma"] = true
    }
}

function builder:strain_mantra(cards)
    local elements = build_elements()
    if not next(elements) then return nil end

    local data = get_player_data()
    if not data then return nil end

    local training = data.AttributeTrainingMet or {}

    local function needs(element)
        local request_name = element and elements[element]

        return request_name
            and not training[request_name]
            and not owns_element_mantra(data, element)
    end

    return most_needed_mantra(cards, data, function(card)
        local trains = card.Element and train_mantras[card.Element]

        return (trains and trains[card.Name] and needs(card.Element)) == true
    end)
end

function builder._pick_card(card, is_special)
    local requests = services.ReplicatedStorage:FindFirstChild("Requests")
    local talent_choice = requests and requests:FindFirstChild("TalentChoice")
    if not talent_choice then return false end

    local ok = pcall(function()
        talent_choice:InvokeServer(card.Name, is_special == true)
    end)

    if ok then
        long_notify_sound("Talent chosen: " .. tostring(card_label(card)))
    end

    return ok
end

function builder._choose_favour(card)
    if game.ReplicatedStorage.Requests.Cards.FavourCard:InvokeServer(card.Name) then
        long_notify_sound("Favour card chosen: " .. card.Name)
    end
end

function builder._wants(name, alt_name)
    if not name or not builder.build_config then return false end

    local cleanedLabel = clean_name(alt_name or name)

    
    if cleanedLabel:find('vitality') or cleanedLabel:find('songchant') or cleanedLabel:find('erudition') or cleanedLabel:find('proficiency') then
        local numerals = {
            'i',
            'ii',
            'iii',
            'iv',
            'v',
            'vi'
        }
        
        local b, r = extract_Word_And_Numeral(cleanedLabel)
        
        local traits = builder.build_config.stats and builder.build_config.stats.traits

        if b and r and traits then
            local cKey = b:gsub("^%l", string.upper)
            if traits[cKey] then
                local indexNum = tonumber(traits[cKey])
                r = tonumber(r)

                if indexNum > 0 and numerals[indexNum]:match(numerals[r]) or tonumber(traits[cKey]) > r then
                    return true                
end
            end
        end
    end

    if cleanedLabel ~= "" then
        for _, mantraName in ipairs(builder.build_config.mantras) do
            if clean_name(mantraName) == cleanedLabel then
                return true            
end
        end
    end

    
    for _, talentname in ipairs(builder.build_config.preShrine_talents) do
        if (name:lower() == talentname:lower()) then
            return true        
end
    end

    for _, talentname in ipairs(builder.build_config.postShrine_talents) do
        if (name:lower() == talentname:lower()) then
            return true        
end
    end

    return false
end

function builder._talent_decision(card)
    local title = card:FindFirstChild("Title")
    local name = (title and title.Text ~= "") and title.Text or card.Name

    if not builder._wants(name) then return false end

    builder._choose_talent(card)
    return true
end

function builder:talent_handler()
    local playergui = local_player.instance.PlayerGui
    local backpackgui = playergui:FindFirstChild('BackpackGui')
    local deckgui = backpackgui and backpackgui:FindFirstChild('LeftFrame').DeckFrame
    local choiceprompt = playergui:FindFirstChild('ChoicePrompt')


    local cards, _, is_special = get_choice()

    if cards then
        local picked = false

        local strain = self:strain_mantra(cards)
        if strain then
            picked = self._pick_card(strain, is_special)
        end

        if not picked then
            for _, card in ipairs(cards) do
                if self._wants(card.Name, card_label(card)) then
                    picked = self._pick_card(card, is_special)
                    if picked then break end
                end
            end
        end

        if not picked then
            for _, card in ipairs(cards) do
                if card.Name == "Fold" then
                    picked = self._pick_card(card, is_special)
                    break
                end
            end
        end

        if not picked then
            local elements = build_elements()
            local data = get_player_data()

            local fallback = most_needed_mantra(cards, data, function(card)
                if table.find(to_burn, card.Name) then return false end

                return card.Type == "Mantra" and card.Element ~= nil and elements[card.Element] ~= nil
            end)

            if not fallback then
                for _, card in ipairs(cards) do
                    if table.find(to_burn, card.Name) then continue end

                    fallback = card
                    break
                end
            end

            if fallback then
                picked = self._pick_card(fallback, is_special)
            end
        end
    end

    if deckgui and deckgui.Visible then
        for _, card in ipairs(deckgui.TalentScroll:GetChildren()) do
            if not card:IsA('TextButton') then continue end
            self._talent_decision(card)
        end
    end

    if choiceprompt then
        local scrollFrame = choiceprompt:FindFirstChild("ScrollingFrame", true) 
        if scrollFrame then
            for _, child in ipairs(scrollFrame:GetChildren()) do
                local cardFrame = child:FindFirstChild("CardFrame")
                if cardFrame then
                    self._talent_decision(cardFrame)
                end
            end
        end
    end
end

function builder:build()
    if self.running then return true end
    if not self:ensure_config() then return false end

    self.running = true;

    aztup.maid.auto_builder = task.spawn(function()
        while self.running and task.wait(0.1) do
            xpcall(function()
                self:talent_handler()
            end, Logger.warn)
        end
    end)

    return true
end

function builder:put_points()
    if self.points_running then return true end
    if not self:ensure_config() then return false end

    self.points_running = true;
    self.logged_targets = false;

    aztup.maid.auto_builder_attributes = task.spawn(function()
        while self.points_running and task.wait(2) do
            xpcall(function()
                self:shrine_check()
                self:spend_points()
            end, Logger.warn)
        end
    end)

    return true
end

function builder:killswitch()
    self.running = false;
    aztup.maid:clean_task('auto_builder')
end

function builder:points_killswitch()
    self.points_running = false;
    aztup.maid:clean_task('auto_builder_attributes')

    if shrine_button then
        shrine_button:Destroy();
        shrine_button = nil;
    end
end

return builder