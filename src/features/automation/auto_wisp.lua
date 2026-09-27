

local feature = Feature:new("auto_wisp")

local WISP_INPUT_MAP = { Z = 1, X = 2, C = 3, V = 4 }

function feature:enable()
	local ritualSpellInput = game:GetService("ReplicatedStorage")
		:WaitForChild("Requests")
		:WaitForChild("Mantras")
		:WaitForChild("RitualSpellInput")

	local cws = nil
	local cwp = nil
	local locked = false
	local lastShift = nil
	local lastUpdate = nil

	self.eventConnection = ritualSpellInput.OnClientEvent:Connect(function(name, data)
		if name == "start" then
			cws = data
			cwp = 1
			locked = false
			lastShift = nil
			lastUpdate = nil
		elseif name == "shift" and cws and cwp then
			cwp = cwp + 1
			lastShift = os.clock()
			locked = false
		elseif name == "close" then
			cws = nil
			cwp = nil
			locked = false
			lastShift = nil
			lastUpdate = nil
		end
	end)

	self.renderConnection = game:GetService("RunService").RenderStepped:Connect(function()
		if not cws or not cwp then
			return
		end
		if cwp > #cws then
			return
		end
		if locked then
			return
		end

		local delay = aztup_options.auto_wisp_delay and aztup_options.auto_wisp_delay.Value or 0
		if lastShift and os.clock() - lastShift <= 0.15 + delay then
			return
		end

		local letter = cws:sub(cwp, cwp)
		if letter ~= "Z" and letter ~= "X" and letter ~= "C" and letter ~= "V" then
			return
		end

		if not EffectReplicator:HasEffect("RitualCastingSpell") then
			return
		end
		if EffectReplicator:HasEffect("Knocked") then
			return
		end

		locked = true
		lastUpdate = os.clock()

		pcall(function()
			ritualSpellInput:FireServer(WISP_INPUT_MAP[letter])
		end)

		task.delay(0.5 + delay, function()
			locked = false
		end)
	end)
end

function feature:disable()
	if self.eventConnection then
		self.eventConnection:Disconnect()
		self.eventConnection = nil
	end
	if self.renderConnection then
		self.renderConnection:Disconnect()
		self.renderConnection = nil
	end
end

return feature
