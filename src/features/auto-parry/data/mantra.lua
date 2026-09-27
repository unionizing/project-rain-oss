
local Mantra = {}





function Mantra.data(entity, name)
	local player = game:GetService("Players"):GetPlayerFromCharacter(entity)
	local backpack = player and player:FindFirstChild("Backpack")

	local mantra = backpack and backpack:FindFirstChild(name)

	local rs = mantra and mantra:GetAttribute("RichStats")
	local bsp = rs and string.match(rs, "%[Blast%]")
	local msp = rs and string.match(rs, "%[Multiplying%]")

	local dsc = rs and string.match(rs, "(%d+)%s*[xX]%s*Drift Shard")
	local rsc = rs and string.match(rs, "(%d+)%s*[xX]%s*Rush Shard")
	local plc = rs and string.match(rs, "(%d+)%s*[xX]%s*Perfect Lens")
	local clc = rs and string.match(rs, "(%d+)%s*[xX]%s*Crystal Lens")
	local stc = rs and string.match(rs, "(%d+)%s*[xX]%s*Stratus Stone")
	local csc = rs and string.match(rs, "(%d+)%s*[xX]%s*Cloudstone")
	local gsc = rs and string.match(rs, "(%d+)%s*[xX]%s*Glass Stone")
	local msc = rs and string.match(rs, "(%d+)%s*[xX]%s*Magnifying Stone")

	return {
		blast = bsp and true or false,
		drift = dsc and tonumber(dsc) or 0,
		rush = rsc and tonumber(rsc) or 0,
		perfect = plc and tonumber(plc) or 0,
		crystal = clc and tonumber(clc) or 0,
		stratus = stc and tonumber(stc) or 0,
		cloud = csc and tonumber(csc) or 0,
		glass = gsc and tonumber(gsc) or 0,
		magnifying = msc and tonumber(msc) or 0,
		spring = rs and rs:find("Spring Spark") or false,
		multiplying = msp and true or false,
		mantra = mantra
	}
end


return Mantra
