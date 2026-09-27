

local last_update = tick();
local custom_name = not LPH_OBFUSCATED and isfile("custom_name.txt") and readfile("custom_name.txt") or nil;
aztup.maid:give_task(scheduler:add_task(0.5):Connect(function()
    if not Latency then return end
    last_update = tick();

    if not services.Stats:FindFirstChild("FrameRateManager") then return end
    
    local frame_rate_manager = services.Stats.FrameRateManager;
    local performance_stats = services.Stats.PerformanceStats;
    local memory_val = performance_stats and performance_stats.Memory;

    local fps = 1000 / frame_rate_manager.RenderAverage:GetValue();
    local color_in_hex = Library.AccentColor:ToHex()

    local show_mem_data = aztup_toggles.WatermarkShowsMem and aztup_toggles.WatermarkShowsMem.Value;

    local watermark, raw_watermark = ('project rain <font color=\"#%s\">nextgen</font> %i<font color="#%s">fps</font> %i<font color="#%s">ms</font>'):format(
        color_in_hex,
        math.floor(fps),
        color_in_hex,
        math.floor(Latency:get_ping() * 1000),
        color_in_hex
    ), ('%s %ifps %ims'):format(
        "project rain nextgen",
        math.floor(fps),
        math.floor(Latency:get_ping() * 1000)
    );

    if memory_val and show_mem_data then
        watermark ..= (' %.2f<font color="#%s">gb</font>'):format(
            memory_val:GetValue() / 1000,
            color_in_hex
        )

        raw_watermark ..= (' %.2fgb'):format(
            memory_val:GetValue() / 1000
        )
    end

    Library:SetWatermark(watermark, raw_watermark); 
end));

return nil