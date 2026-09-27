
local notified = {};
local auto_loot = {
    stat_maximums  = {
        weapons = {
            damage = 7,
            penetration = 15,
            weight = 10
        },

        headwear = {
            health = 30,
            ether = 30,
            monsterdmg = 15,
            phyarmor = 15,
            elearmor = 15,
            monsterarmor = 15
        },

        facewear = {
            ether = 30,
            sanity = 30,
            monsterdmg = 15
        },

        earrings = {
            ether = 30,
            sanity = 30,
            monsterdmg = 15
        },

        neckwear = {
            health = 30,
            ether = 10,
            monsterdmg = 7
        },

        rings = {
            health = 30,
            ether = 30,
            sanity = 10,
            posture = 5,
            monsterdmg = 15
        },

        arms = {
            health = 30,
            ether = 30,
            monsterdmg = 15,
            phyarmor = 15,
            elearmor = 15,
            monsterarmor = 15
        },

        legs = {
            health = 30,
            ether = 30,
            monsterdmg = 15
        }
    },
    icon_offsets   = {
        weapons = 140,
		headwear = 60,
		facewear = 80,
		earrings = 100,
		neckwear = 180,
		schematics = 120,
		arms = 20,
		footwear = 40,
		treasure = 200,
		rings = 0 
    },
    color_rarities = {
        common = "40504c",
		uncommon = "a38e65",
		rare = "885353",
		enchant = "e2ffe7",
		legendary = "9058AC",
		mythic = "47ccaf",
		relic = "96f58f",
		unique = "952269"
    },
    enchants       = {
        "Astral",
		"Blazing",
		"Chilling",
		"Deferred",
		"Detonation",
		"Elastic",
		"Gluttony",
		"Grim",
		"Harrowing",
		"Heroism",
		"Metal",
		"Nemesis",
		"Obfuscation",
		"Providence\'s Thorns",
		"Sear",
		"Solar",
		"Stone",
		"Storm",
		"Stormbreaker",
		"Tears of the Edenkite",
		"Umbral Knight",
		"Vampirism",
		"Wild",
		"Curse of the Bloodthirsty",
		"Curse of the No Life King",
		"Curse of the Unbidden",
		"Curse of Yun\'Shul",
		"Curse Of Repulsion",
		"Curse of Rhaemen\'s Ember",
		"Adhesive",
		"Allure",
		"Bounce",
		"Displacement",
		"Drowned",
		"Entanglement",
		"Ferocity",
		"Multiplicity",
		"Stench",
		"Viscoity"
    },

    get_closest_chest = function()
        local pos = local_player.root_part.Position
        local closest_distance = math.huge

        for _, chest in pairs(workspace.Thrown:GetChildren()) do
            if chest:FindFirstChild('Lid') and chest:FindFirstChild('InteractPrompt') then
                local dist = (chest.Lid.Position - pos).Magnitude
                if (dist <= closest_distance and dist <= 10) then
                    closest_distance = dist
                    return chest
                end
            end
        end

        return nil
    end,

    fire_loot_all = function(remote)
        remote:FireServer("LOOT_ALL")
    end,

    identify_color = function(self, hex_color, tolerance)
        local function hex_to_rgb(hex_color)
            hex_color = hex_color:gsub("#", "")

            local r = tonumber(hex_color:sub(1,2), 16) or 0
            local g = tonumber(hex_color:sub(3,4), 16) or 0
            local b = tonumber(hex_color:sub(5,6), 16) or 0
            
            return math.min(r, 255), math.min(g, 255), math.min(b, 255)
        end

        local function colors_are_similar(color1, color2, tolerance)
            local r1, g1, b1 = hex_to_rgb(color1)
            local r2, g2, b2 = hex_to_rgb(color2)

            local diffR = math.abs(r1 - r2)
            local diffG = math.abs(g1 - g2)
            local diffB = math.abs(b1 - b2)

            return diffR <= tolerance and diffG <= tolerance and diffB <= tolerance
        end

        for name, hex in pairs(self.color_rarities) do
            if colors_are_similar(hex, hex_color, tolerance) then
                return name
            end
        end

        return nil
    end,

    info_loot = function(remote, loot)
        local WEBHOOKEXISTS = false
        if WEBHOOKEXISTS then end

        pcall(function()
            if aztup.flags.notify_on_loot and not notified[loot] then
                notified[loot] = true;
                task.delay(10, function()
                    notified[loot] = nil;
                end);
                if aztup.flags.play_sound_noti then
                    Logger:notify_sound("Looted: " .. loot.Title.Text)
                else
                    Logger:notify("Looted: " .. loot.Title.Text)
                end;
            end;
        end);

        remote:FireServer(loot.Name)
        task.wait(0.01)
    end,

    is_overweight = function()
        local current_carry_load = local_player.character.Humanoid:GetAttribute('CarryLoad')
        local max_carry_load     = local_player.character.Humanoid:GetAttribute('CarryMax')

        local obesity = max_carry_load + (max_carry_load * 0.2)

        return current_carry_load >= obesity
    end,

    chest_check = function(loot_object_container)
        local function options_true(options, specific_option)
            for option, boolean in pairs(options) do

                if specific_option == nil and boolean then
                    return true
                end

                if option == specific_option and boolean then
                    return true
                end
            end

            return false
		end

        local function found_kyrsan_medallion(loot_objects)
            for _, object in pairs(loot_objects) do
                if object:IsA('TextButton') and object.Name:find('Kyrsan Medallion') then
                    return true
                end
            end

            return false
        end

        local loot_all_no_filter            = aztup_options.loot_options.Value['Loot All'] and not options_true(aztup_options.loot_all_rarities.Value)
        local always_loot_krysan_medallions = aztup_options.loot_options.Value['Always Loot Items'] and (aztup_options.always_loot_dropdown.Value['Kyrsan Medallions'])

        return loot_all_no_filter or (always_loot_krysan_medallions and found_kyrsan_medallion(loot_object_container:GetChildren()))
    end,

    is_loot_container = function(choice_prompt)
        local title = choice_prompt:FindFirstChild('ChoiceFrame'):FindFirstChild('Title')
        return title.Text:lower():find('treasure chest') or title.Text:lower():find('loot')
    end
}

function auto_loot:item_loot(remote, loot)
    local item_loot = aztup_options.loot_options.Value['Item Loot']

    local function input_parse(input)
        local item_names = {}

        for segment in string.gmatch(input, "([^;]*)") do
            local trimmed_segment = segment:match("^%s*(.-)%s*$")
            if trimmed_segment ~= "" then
                table.insert(item_names, trimmed_segment)
            end
        end

        return item_names
    end

    if item_loot then
        for _, name in pairs(input_parse(aztup_options.item_loot_input.Value)) do
            if loot.Name:lower():find(name:lower()) then
                self.info_loot(remote, loot)
                return true
            end
        end
    end

    return false
end

function auto_loot:loot_all(remote, loot)
    local selected_rarities = aztup_options.loot_all_rarities.Value
    local item_rarity = self.identify_color(self, loot.BackgroundColor3:ToHex(), 1)

    local function rarities_selected()
        for rarity, boolean in pairs(selected_rarities) do
            if boolean then
                return true
            end
        end

        return false
    end

    local function is_selected_rarity(item_rarity)
        for rarity, boolean in pairs(selected_rarities) do
            if item_rarity:lower() == rarity:lower() and boolean then
                return true
            end
        end

        return false
    end

    if aztup_options.loot_options.Value['Loot All'] and rarities_selected() and is_selected_rarity(item_rarity) then
        self.info_loot(remote, loot)
        return true
    end

    return false
end

function auto_loot:stat_loot(remote, loot)
    local function stat_parse(input, word)
        local function safe_number_convert(str)
            local num = tonumber(str)
            return num ~= nil and num or 0
        end

        local total_value = 0

        if input then
            for value in input:gmatch("%+(%d+)%s*" .. word) do
                total_value = total_value + safe_number_convert(value)
            end

            for value in input:gmatch("%+(%d+)%%%s*" .. word) do
                total_value = total_value + safe_number_convert(value)
            end
        end 

        if word == 'Physical Armor' then
            total_value = total_value + stat_parse(input, 'PHY Armor')
        end

        if word == 'Elemental Armor' then
            total_value = total_value + stat_parse(input, 'ELM Armor')
        end

        return total_value
    end

    local function precise_stats(stats_to_check, stats)
        local all_stats_meet_criteria = true

        for _, stat in ipairs(stats_to_check) do
            local stat_value = stat_parse(stats, stat[1])

            if stat_value < stat[2] then
                all_stats_meet_criteria = false
                break
            end
        end

        return all_stats_meet_criteria
    end

    local function stats(stats_to_check, stats)
        for _, stat in ipairs(stats_to_check) do
            if stat[2] > 0 and stat_parse(stats, stat[1]) >= stat[2] then
                return true
            end
        end

        return false
    end

    local stats_text        = loot:FindFirstChild('Stats') and loot:FindFirstChild('Stats').Text
    local image_rect_offset = 1000

    if loot:FindFirstChild('Icon') then image_rect_offset = loot:FindFirstChild('Icon').ImageRectOffset.X; end

    local item_types = {
        weapons = function(loot)
			local stat_loot_weapons = aztup_options.stat_loot_dropdown.Value['Weapons']
			local stat_loot_weapons_precise = aztup_options.precise_stat_loot.Value['Weapons']
			local stats_to_check = {
				{"PEN", aztup.flags.stat_loot_weapons_penetration},
				{"Weight", aztup.flags.stat_loot_weapons_weight},
				{"Damage", aztup.flags.stat_loot_weapons_damage}
			}

			if stat_loot_weapons and image_rect_offset == self.icon_offsets.weapons then
				if stat_loot_weapons_precise then
					if precise_stats(stats_to_check, stats_text) then return true end
				else
					if stats(stats_to_check, stats_text) then return true end
				end
			end

			return false
		end,

		headwear = function(loot)
			local stat_loot_headwear = aztup_options.stat_loot_dropdown.Value['Headwear']
			local stat_loot_headwear_precise = aztup_options.precise_stat_loot.Value['Headwear']
			local stats_to_check = {
				{"HP", aztup.flags.stat_loot_headwear_health},
				{"ETH", aztup.flags.stat_loot_headwear_ether},
				{"Monster DMG", aztup.flags.stat_loot_headwear_monsterdamage},
				{"Physical Armor", aztup.flags.stat_loot_headwear_physicalarmour},
				{"Elemental Armor", aztup.flags.stat_loot_headwear_elementalarmour},
				{"Monster Armor", aztup.flags.stat_loot_headwear_monsterarmour}
			}

			if stat_loot_headwear and image_rect_offset == self.icon_offsets_headwear then
				if stat_loot_headwear_precise then
					if precise_stats(stats_to_check, stats_text) then return true end
				else
					if stats(stats_to_check, stats_text) then return true end
				end
			end

			return false
		end,

		facewear = function(loot)
			local stat_loot_facewear = aztup_options.stat_loot_dropdown.Value['Facewear']
			local stat_loot_facewear_precise = aztup_options.precise_stat_loot.Value['Facewear']
			local stats_to_check = {
				{"ETH", aztup.flags.stat_loot_facewear_ether},
				{"SAN", aztup.flags.stat_loot_facewear_sanity},
				{"Monster DMG", aztup.flags.stat_loot_facewear_monsterdamage}
			}

			if stat_loot_facewear and image_rect_offset == self.icon_offsets.facewear then
				if stat_loot_facewear_precise then
					if precise_stats(stats_to_check, stats_text) then return true end
				else
					if stats(stats_to_check, stats_text) then return true end
				end
			end

			return false
		end,

		earrings = function(loot)
			local stat_loot_earrings = aztup_options.stat_loot_dropdown.Value['Earrings']
			local stat_loot_earrings_precise = aztup_options.precise_stat_loot.Value['Earrings']
			local stats_to_check = {
				{"ETH", aztup.flags.stat_loot_earrings_ether},
				{"SAN", aztup.flags.stat_loot_earrings_sanity},
				{"Monster DMG", aztup.flags.stat_loot_earrings_monsterdamage}
			}

			if stat_loot_earrings and image_rect_offset == self.icon_offsets.earrings then
				if stat_loot_earrings_precise then
					if precise_stats(stats_to_check, stats_text) then return true end
				else
					if stats(stats_to_check, stats_text) then return true end
				end
			end

			return false
		end,

		neckwear = function(loot)
			local stat_loot_neckwear = aztup_options.stat_loot_dropdown.Value['Neckwear']
			local stat_loot_neckwear_precise = aztup_options.precise_stat_loot.Value['Neckwear']
			local stats_to_check = {
				{"HP", aztup.flags.stat_loot_neckwear_health},
				{"ETH", aztup.flags.stat_loot_neckwear_ether},
				{"Monster DMG", aztup.flags.stat_loot_neckwear_monsterdamage}
			}

			if stat_loot_neckwear and image_rect_offset == self.icon_offsets.neckwear then
				if stat_loot_neckwear_precise then
					if precise_stats(stats_to_check, stats_text) then return true end
				else
					if stats(stats_to_check, stats_text) then return true end
				end
			end

			return false
		end,

		rings = function(loot)
			local stat_loot_rings = aztup_options.stat_loot_dropdown.Value['Rings']
			local stat_loot_rings_precise = aztup_options.precise_stat_loot.Value['Rings']
			local stats_to_check = {
				{"HP", aztup.flags.stat_loot_rings_health},
				{"ETH", aztup.flags.stat_loot_rings_ether},
				{"SAN", aztup.flags.stat_loot_rings_sanity},
				{"Posture", aztup.flags.stat_loot_rings_posture},
				{"Monster Dmg", aztup.flags.stat_loot_rings_monsterdamage}
			}

			if stat_loot_rings and image_rect_offset == self.icon_offsets.rings or image_rect_offset == self.icon_offsets.treasure or loot.Name:lower():find("ring") or loot.Name:lower():find("band") and not loot.Name:lower():find('bandana') then
				if stat_loot_rings_precise then
					if precise_stats(stats_to_check, stats_text) then return true end
				else
					if stats(stats_to_check, stats_text) then return true end
				end
			end

			return false
		end,

		arms = function(loot)
			local stat_loot_arms = aztup_options.stat_loot_dropdown.Value['Arms']
			local stat_loot_arms_precise = aztup_options.precise_stat_loot.Value['Arms']
			local stats_to_check = {
				{"HP", aztup.flags.stat_loot_arms_health},
				{"ETH", aztup.flags.stat_loot_arms_ether},
				{"Monster Dmg", aztup.flags.stat_loot_arms_monsterdamage},
				{"Physical Armor", aztup.flags.stat_loot_arms_physicalarmour},
				{"Elemental Armor", aztup.flags.stat_loot_arms_elementalarmour},
				{"Monster Armor", aztup.flags.stat_loot_arms_monsterarmour}
			}

			if stat_loot_arms and image_rect_offset == self.icon_offsets.arms then
				if stat_loot_arms_precise then
					if precise_stats(stats_to_check, stats_text) then return true end
				else
					if stats(stats_to_check, stats_text) then return true end
				end
			end

			return false
		end,

		legs = function(loot)
			local stat_loot_legs = aztup_options.stat_loot_dropdown.Value['Legs']
			local stat_loot_legs_precise = aztup_options.precise_stat_loot.Value['Legs']
			local stats_to_check = {
				{"HP", aztup.flags.stat_loot_arms_health},
				{"ETH", aztup.flags.stat_loot_arms_ether},
				{"Monster DMG", aztup.flags.stat_loot_arms_monsterdamage}
			}

			if stat_loot_legs and image_rect_offset == self.icon_offsets.legs then
				if stat_loot_legs_precise then
					if precise_stats(stats_to_check, stats_text) then return true end
				else
					if stats(stats_to_check, stats_text) then return true end
				end
			end

			return false
		end
    }

    for item_type, func in pairs(item_types) do
        if aztup_options.loot_options.Value['Stat Loot'] and func(loot) then
            self.info_loot(remote, loot)
            return true
        end
    end

    return false
end

function auto_loot:always_loot(remote, loot)
    local color = loot.BackgroundColor3

    local function loot_relics(loot)
        local option_selected = aztup_options.always_loot_dropdown.Value['Relics']
        local is_relic_rarity = self.identify_color(self, color:ToHex(), 1):lower() == 'relic'
        return option_selected and is_relic_rarity
    end

    local function loot_enchant_stones(loot)
        local function found_enchant(loot)
            for _, name in pairs(auto_loot.enchants) do
                if loot.Name:find(name) then
                    return true
                end
            end

            return false
        end

        local option_selected = aztup_options.always_loot_dropdown.Value['Enchant Stones']
        local is_legendary_rarity = self.identify_color(self, color:ToHex(), 1):lower() == 'legendary'

        return option_selected and is_legendary_rarity and found_enchant(loot)
    end

    local function loot_legendary_weapons(loot)
        local option_selected = aztup_options.always_loot_dropdown.Value['Legendary Weapons']
		local is_weapon = loot:FindFirstChild('Icon') and loot:FindFirstChild("Icon").ImageRectOffset.X == auto_loot.icon_offsets.weapons
		local is_legendary_rarity = self.identify_color(self, color:ToHex(), 1):lower() == "legendary"
		return option_selected and is_weapon and is_legendary_rarity and not self.is_overweight()
    end

    local function loot_deep_gems(loot)
        local function is_gem(loot)
            if loot:FindFirstChild('Title') then
                local name = loot.Title.Text
                if name:lower():match('gem') and not name:lower():match('vibrant gem') then
                    return true
                end
            end

            return false
        end

        local option_selected = aztup_options.always_loot_dropdown.Value['Deep Gems']
        local is_mythic_rarity = self.identify_color(self, color:ToHex(), 1):lower() == 'mythic'

        return option_selected and is_mythic_rarity and not self.is_overweight() and is_gem(loot)
    end

    if aztup_options.loot_options.Value['Always Loot Items'] and (loot_relics(loot) or loot_enchant_stones(loot) or loot_legendary_weapons(loot) or loot_deep_gems(loot)) then
        self.info_loot(remote, loot)
        return true
    end

    return false
end

function auto_loot:main()
    local choice_prompt = local_player.instance.PlayerGui:FindFirstChild('ChoicePrompt')
    local choice_frame = choice_prompt and choice_prompt:FindFirstChild('ChoiceFrame')
    local options = choice_frame and choice_frame:FindFirstChild('Options')
    local remote = choice_prompt and choice_prompt:FindFirstChild('Choice')

    if not choice_prompt then return end
    if not choice_frame then return end
    if not self.is_loot_container(choice_prompt) then return end

    if not self.chest_check(options) then
        local count = 0

        for _, loot_object in options:GetChildren() do
            if not loot_object:IsA('TextButton') then continue end
            if not loot_object.AutoButtonColor then count += 1; continue end

            if not aztup.flags.auto_loot then break end

            if self:always_loot(remote, loot_object) then count += 1; continue end
            if self.is_overweight() then continue end

            if self:item_loot(remote, loot_object) then count += 1; continue end
            if self:stat_loot(remote, loot_object) then count += 1; continue end
            if self:loot_all(remote, loot_object) then count += 1; continue end
        end

        if not (count == 0) then return end
    else
        self.fire_loot_all(remote)
    end
end

local last_time = 0;
return Feature:new("auto_loot", services.RunService.RenderStepped, function() 
    if tick() - last_time < 1 / 10 then return end
    last_time = tick()
    pcall(function(...)  
        auto_loot:main()
    end)
end)