local last_update = tick();


return Feature:new("roll2_revealer", scheduler:add_task(2.75), function()
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
        if not title or title.Text ~= "Roll 2" then continue end 

        for _, item in game:GetService("ReplicatedStorage").Requests.Get:InvokeServer().TalentChoice.Selection do
            if item.Name == "Roll 2" then
                title.Text = "Revealed Roll 2";
                card_frame.Details.Desc.Text = "\nwill be a mix of these:\n" .. item.Selection[1].Name .. ", " .. item.Selection[2].Name.. ", " .. item.Selection[3].Name.. ", " .. item.Selection[4].Name;
            end
        end;
    end;
end)