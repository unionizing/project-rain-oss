return LPH_NO_VIRTUALIZE(function()
    local chance_store = {} do
        chance_store.__index = chance_store;

        local OUTCOME_ORDER = { "Parry", "Dodge", "Skip" }
        local OUTCOME_LOOKUP = {
            ["Parry"] = true,
            ["Dodge"] = true,
            ["Skip"] = true,
        }

        local function clamp_chance(value)
            local num = tonumber(value)
            if not num then
                return 100
            end

            if num < 0 then
                return 0
            end

            if num > 100 then
                return 100 
            end

            return num 
        end
 
        function chance_store.new()
            local instance = setmetatable({}, chance_store)
            instance.chances = {}

            if isfile("Project Rain/post-rc-260421-parry-chances.json") then
                local data = game:GetService("HttpService"):JSONDecode(readfile("Project Rain/post-rc-260421-parry-chances.json"))
                instance:load_chances(data)
            end

            return instance
        end

        function chance_store:normalize_outcome_actions(actions)
            local selected = {}

            if typeof(actions) == "string" then
                if OUTCOME_LOOKUP[actions] then
                    selected[actions] = true
                end
            elseif typeof(actions) == "table" then
                if #actions > 0 then
                    for _, action in ipairs(actions) do
                        if OUTCOME_LOOKUP[action] then
                            selected[action] = true
                        end
                    end
                else 
                    for action, enabled in pairs(actions) do
                        if enabled and OUTCOME_LOOKUP[action] then
                            selected[action] = true
                        end
                    end
                end
            end

            local normalized = {}
            for _, action in ipairs(OUTCOME_ORDER) do
                if selected[action] then
                    table.insert(normalized, action)
                end
            end

            if #normalized == 0 then
                normalized = { "Skip" }
            end

            return normalized
        end

        function chance_store:normalize_outcome_weights(weights)
            local normalized = {}

            if typeof(weights) == "string" then
                if OUTCOME_LOOKUP[weights] then
                    normalized[weights] = 100
                end
            elseif typeof(weights) == "table" then
                if #weights > 0 then
                    for _, action in ipairs(weights) do
                        if OUTCOME_LOOKUP[action] then
                            local current = normalized[action]
                            if current == nil then
                                current = 0
                            end

                            normalized[action] = current + 1
                        end
                    end
                else
                    for action, amount in pairs(weights) do
                        if not OUTCOME_LOOKUP[action] then
                            continue
                        end

                        if typeof(amount) == "number" then
                            normalized[action] = math.max(0, amount)
                        elseif amount then
                            normalized[action] = 1
                        end
                    end
                end
            end

            local total = 0
            for _, action in ipairs(OUTCOME_ORDER) do
                local amount = normalized[action]
                if amount == nil then
                    amount = 0
                end

                total = total + amount
            end

            if total <= 0 then
                normalized = { Skip = 100 }
            end

            return normalized
        end

        function chance_store:legacy_to_outcome_weights(chance, fail_weights)
            local safe_chance = clamp_chance(chance)
            local normalized_fail_weights = self:normalize_outcome_weights(fail_weights)
            local total_fail = 0

            for _, action in ipairs(OUTCOME_ORDER) do
                if action ~= "Parry" then
                    local amount = normalized_fail_weights[action]
                    if amount == nil then
                        amount = 0
                    end

                    total_fail = total_fail + amount
                end
            end

            local parry_weight = safe_chance
            local remainder = math.max(0, 100 - parry_weight)
            local outcome_weights = {
                Parry = parry_weight,
                Dodge = 0,
                Skip = 0,
            }

            if total_fail <= 0 then
                outcome_weights.Skip = remainder
                return self:normalize_outcome_weights(outcome_weights)
            end

            for _, action in ipairs(OUTCOME_ORDER) do
                if action ~= "Parry" then
                    local part = normalized_fail_weights[action]
                    if part == nil then
                        part = 0
                    end

                    if part > 0 then
                        outcome_weights[action] = remainder * (part / total_fail)
                    end
                end
            end

            return self:normalize_outcome_weights(outcome_weights)
        end

        function chance_store:normalize_entry(entry)
            if typeof(entry) == "number" then
                local outcome_weights = self:legacy_to_outcome_weights(entry, { Skip = 100 })
                return {
                    chance = clamp_chance(entry),
                    fail_actions = { "Skip" },
                    fail_weights = { Skip = 100 },
                    outcome_weights = outcome_weights,
                }
            end

            if typeof(entry) ~= "table" then
                local outcome_weights = self:legacy_to_outcome_weights(100, { Skip = 100 })
                return {
                    chance = 100,
                    fail_actions = { "Skip" },
                    fail_weights = { Skip = 100 },
                    outcome_weights = outcome_weights,
                }
            end

            local chance = clamp_chance(entry.chance or entry.value or entry.percent)
            local fail_actions = self:normalize_outcome_actions(entry.fail_actions or entry.on_fail)
            local fail_weights = self:normalize_outcome_weights(entry.fail_weights or fail_actions)
            local outcome_weights = self:normalize_outcome_weights(entry.outcome_weights)

            if not entry.outcome_weights then
                outcome_weights = self:legacy_to_outcome_weights(chance, fail_weights)
            end

            fail_actions = {}
            for _, action in ipairs(OUTCOME_ORDER) do
                local weight = fail_weights[action]
                if weight ~= nil and weight > 0 then
                    table.insert(fail_actions, action)
                end
            end

            if #fail_actions == 0 then
                fail_actions = { "Skip" }
            end

            return {
                chance = chance,
                fail_actions = fail_actions,
                fail_weights = fail_weights,
                outcome_weights = outcome_weights,
            }
        end

        function chance_store:add_chance(id: string, chance_or_outcome_weights, fail_actions_or_weights)
            local payload = {}

            if typeof(chance_or_outcome_weights) == "table" then
                payload.outcome_weights = chance_or_outcome_weights
            else
                payload.chance = clamp_chance(chance_or_outcome_weights)

                if typeof(fail_actions_or_weights) == "table" and #fail_actions_or_weights == 0 then
                    payload.fail_weights = fail_actions_or_weights
                else
                    payload.fail_actions = fail_actions_or_weights
                end
            end

            self.chances[id] = self:normalize_entry(payload)
        end

        function chance_store:get_entry(id: string)
            local entry = self.chances[id]
            if entry == nil then
                return nil
            end

            local normalized = self:normalize_entry(entry)
            self.chances[id] = normalized

            return normalized
        end

        function chance_store:get_chance(id: string): number?
            local entry = self:get_entry(id)
            return entry and entry.chance or nil
        end

        function chance_store:get_fail_actions(id: string)
            local entry = self:get_entry(id)
            return entry and entry.fail_actions or nil
        end

        function chance_store:get_fail_weights(id: string)
            local entry = self:get_entry(id)
            return entry and entry.fail_weights or nil
        end

        function chance_store:get_outcome_weights(id: string)
            local entry = self:get_entry(id)
            return entry and entry.outcome_weights or nil
        end

        function chance_store:load_chances(data)
            for id, entry in pairs(data) do
                self.chances[id] = self:normalize_entry(entry)
            end

            self.loaded = true;
            if self.on_load_function then
                self:on_load_function();
            end;
        end

        function chance_store:save_chances()
            local data = game:GetService("HttpService"):JSONEncode(self.chances)
            writefile("Project Rain/post-rc-260421-parry-chances.json", data)
        end

        function chance_store:on_load(f)
            f();

            self.on_load_function = f;
        end;
    end;

    return chance_store.new()
end)()