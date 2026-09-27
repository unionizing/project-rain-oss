local function toggle_if(object)
    task.spawn(function()
        if workspace:WaitForChild(object, 10) then
            local done = false;
            repeat 
                task.wait()
                for _, feature in aztup.features do
                    if feature.id == "no_sea" then
                        feature:enable();
                        done = true;
                    end; 
                end;
            until done;

            local sea_floor = workspace:FindFirstChild("SeaFloor", true);
            local holder_sea = workspace:FindFirstChild("HolderSea", true);

            if sea_floor then
                sea_floor:Destroy();
            end;

            if holder_sea then
                holder_sea:Destroy();
            end;
        end;
    end);
end;

if game.PlaceId == 8668476218 then
    toggle_if("One");
    toggle_if("Bathysphere");
    toggle_if("DepthsTrial");
    toggle_if("DukeErisia")
    toggle_if("Deepdrill")
    toggle_if("GauntTrial")
    
end;
return