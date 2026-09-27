return {
    id = "SilentheartWarn",

    run = function(action, data)
        local hrp = local_player.character and local_player.character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return
        end

        local user = data and data.caster
        if not user then return end

        local recolor = nil
        repeat
            task.wait()
            for _, child in next, hrp:GetChildren() do
                if child:IsA("Attachment") then
                    local found = child:FindFirstChild("Recolor")
                    if found and found:IsA("ParticleEmitter") then
                        recolor = found
                        break
                    end
                end
            end
        until recolor

        action.user = user
        action.ignore_hitbox = true
        action.offset = CFrame.new()
        action.type = "Parry"
        action.when = 0.25
        action.name = "Silentheart Relentless Hunt"
        action.allow_parry_to_roll = true
        action:play()

        return action
    end
}