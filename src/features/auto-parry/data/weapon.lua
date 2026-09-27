
local Weapon = {}



function Weapon.data(entity)
	
	local lh = entity:FindFirstChild("LeftHand")
	local rh = entity:FindFirstChild("RightHand")
	local attach = workspace.Thrown and workspace.Thrown:FindFirstChild("Attach_" .. entity.Name)
	local hw = attach and attach:FindFirstChild("HandWeapon") or (lh and lh:FindFirstChild("HandWeapon")) or (rh and rh:FindFirstChild("HandWeapon"))

	if not hw then
		return
	end
 
	local hwstats = hw:FindFirstChild("Stats")
	if not hwstats then
		return
	end

	local ssv = hwstats:FindFirstChild("SwingSpeed")
	if not ssv then
		return
	end

	local lv = hwstats:FindFirstChild("Length")
	if not lv then
		return
	end

	local type = hw:FindFirstChild("Type")
	if not type then
		return
	end

	local nemesis = false

	for _, inst in next, hw:GetChildren() do
		if not inst:IsA("ParticleEmitter") then
			continue
		end

		if inst.Texture ~= "rbxassetid://11889781532" then
			continue
		end

		nemesis = true
		break
	end

	return {
		hw = hw,
		ss = ssv.Value,
		oss = ssv:GetAttribute("OldValue") or ssv.Value,
		length = lv.Value,
		type = type.Value or "N/A",
		nemesis = nemesis,
	}
end


return Weapon