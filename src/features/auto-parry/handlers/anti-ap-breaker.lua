local anti_ap_breaker = {}

local dead_tracks = setmetatable({}, { __mode = "k" })
local track_seen_at = setmetatable({}, { __mode = "k" })
local priority_cache = {};

function anti_ap_breaker:on()
    return aztup.flags.basic_validation
end

function anti_ap_breaker:compatibility()
    return aztup.flags.compatibility_mode_anti_ap_breaker
end

function anti_ap_breaker:is_filter_on(flag)
    return aztup_options.validation_filters.Value[flag]
end;

function anti_ap_breaker:is_filter_log_on(flag)
    return aztup_options.validation_log_filters.Value[flag]
end;

function anti_ap_breaker:log(type, ...)
    
    if not aztup.flags.anti_ap_breaker_debug then return end
    if not self:is_filter_log_on(type) then return end

    setthreadidentity(8)
    Logger:short_notify("[Anti AP]", string.format(...))
end

function anti_ap_breaker:initial_check(defender, track)
    if not defender.is_player or not self:on() then
        return false    
end

    
    if track.Speed >= aztup.flags.anti_ap_breaker_max_speed and self:is_filter_on("S >= X (S = Speed)") then
        self:log("S >= X (S = Speed)", "Speed is too high, Speed: %.1f", track.Speed)
        return true
    end;

    if track.Length / track.Speed <= (aztup.flags.anti_ap_breaker_length_ms / 1000) and self:is_filter_on("Length <= Xms") then
        self:log("Length <= Xms", "Length is too short, Length: %.1f", track.Length)
        return true
    end;

    if track.Priority == Enum.AnimationPriority.Core and self:is_filter_on("Core Priority") then
        self:log("Core Priority", "Track is core priority")
        return true
    end;

    if track.Priority == Enum.AnimationPriority.Idle and self:is_filter_on("Idle Priority") then
        self:log("Idle Priority", "Track is idle priority")
        return true
    end;

    if track.Speed == 0 and self:is_filter_on("Speed == 0") then 
        return self:log("Speed == 0", "Track is frozen")    
end

    track_seen_at[track] = tick();
    priority_cache[track] = track.Priority;

    task.delay(30, function()
        priority_cache[track] = nil;
    end);

    return false
end;

function clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end

    return val
end;

function anti_ap_breaker:handle_fadetime(track)
    return track.WeightCurrent < clamp(clamp(track.WeightTarget / 2, 1 / 120, tick() - (track_seen_at[track] or 0)), 0, 0.2)
end;

local asset_id = require("@src/utility/asset_id")
function anti_ap_breaker:handle_priority_hiding(defender, track)
    local humanoid = defender.entity:FindFirstChild("Humanoid");
    local hidden_count = 0;
    local highest_priority = 1000;
    
    for _, other_track in humanoid:GetPlayingAnimationTracks() do
        if track == other_track then continue end
        if other_track.Priority.Value == 1000 then continue end
        if track.Priority.Value >= other_track.Priority.Value then continue end;
        if other_track.WeightCurrent <= track.WeightCurrent / 2 then continue end
        if other_track.WeightTarget <= 0.3 then continue end
        if other_track.Speed == 0 and other_track.TimePosition >= track.Length - 0.01 or other_track.TimePosition <= 0.01 then continue end;
        if not asset_id.get_id(other_track.Animation.AnimationId) then continue end
        if self:final_check(defender, other_track, true) then continue end
        hidden_count += 1;
        
        if highest_priority > other_track.Priority.Value then
            highest_priority = other_track.Priority.Value;
        end; 
    end

    return highest_priority ~= 1000 and highest_priority > track.Priority.Value
end;

function anti_ap_breaker:final_check(defender, track, skip)
    if not self:on() then
        return false    
end
    
        
    local alive = self:is_playing(track, defender.entity);
    if alive and self:handle_fadetime(track) and self:is_filter_on("Fadetime") then 
        if not skip then
            self:log("Fadetime", "Track is faded", track.WeightCurrent)
        end;
        return true
    end;
    
    if track.WeightTarget <= (aztup.flags.anti_ap_breaker_minimum_wt / 100) and self:is_filter_on("WT <= X (WT = WeightTarget)") then 
        if track.WeightCurrent < (aztup.flags.anti_ap_breaker_minimum_wt / 100) or not alive then
            if not skip then
                self:log("WT <= X (WT = WeightTarget)", "Track is too lightweight. WT - %.2f, WC - %.2f", track.WeightTarget, track.WeightCurrent)
            end;
            return true
        end;
    end;

    if self:is_filter_on("Priority Hiding") and not skip and self:handle_priority_hiding(defender, track) then
        if not skip then
            self:log("Priority Hiding", "Track is hidden behind another anims priority.");
        end;
        return true
    end
    
    return false
end;

function anti_ap_breaker:is_fully_dead(track, entity)
    return not table.find(entity:FindFirstChild("Humanoid"):GetPlayingAnimationTracks(), track)
end;

function anti_ap_breaker:is_playing(track, entity)
    return track.IsPlaying or table.find(entity:FindFirstChild("Humanoid"):GetPlayingAnimationTracks(), track)
end;

return anti_ap_breaker