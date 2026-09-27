local last_update = tick();
local mantras = require("@src/features/removals/mantra_revealer/mantras".."");





























local function dynamic_get_mystery_mantra() 
    local requests = services.ReplicatedStorage:FindFirstChild("Requests");
    local get = requests:FindFirstChild("Get");
    local Data = get:InvokeServer();

    local TalentChoice = Data and Data.TalentChoice
    if not TalentChoice then return nil end

    local MantraName = nil
    if TalentChoice.Selection and type(TalentChoice.Selection) == "table" then
        for _, obj in ipairs(TalentChoice.Selection) do
            if obj.Mystery then
                MantraName = obj.MantraName
                break
            end
        end
    end

    return MantraName
end

return Feature:new("mantra_revealer", scheduler:add_task(2.5), function()
    last_update = tick();

    local player_gui = local_player.instance:FindFirstChild("PlayerGui")
    if not player_gui then return end
    local talent_gui = player_gui:FindFirstChild("TalentGui");
    if not talent_gui then return end
    local choice_frame = talent_gui:FindFirstChild("ChoiceFrame");
    if not choice_frame then return end


    for _, choice in choice_frame:GetChildren() do
        local card_frame = choice:FindFirstChild("CardFrame");
        if not card_frame then continue end
        local title = card_frame:FindFirstChild("Title"); 
        if not title or title.Text ~= "Mystery Mantra" then continue end
        local mantra_name = mantras[choice.Name];
        title.Text = mantra_name or dynamic_get_mystery_mantra() or choice.Name;
    end;
end)