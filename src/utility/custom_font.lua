local custom_font = {}




function custom_font.make_lexend_font()
    local font_custom_asset = getcustomasset("Project Rain/fonts/Lexend.ttf")
    local font_custom_asset_bold = getcustomasset("Project Rain/fonts/Lexend-Bold.ttf")
    local font_custom_asset_medium = getcustomasset("Project Rain/fonts/Lexend-Medium.ttf")

    writefile("Project Rain/fonts/Lexend.json", game:GetService("HttpService"):JSONEncode({
        name = "Lexend",
        faces = {
            {
                name = "Regular",
                weight = 400,      
                style = "normal",
                assetId = font_custom_asset
            },
            {
                name = "Medium",
                weight = 500,
                style = "normal",
                assetId = font_custom_asset_medium
            },
            {
                name = "Bold",
                weight = 700,
                style = "normal",
                assetId = font_custom_asset_bold
            }
        }
    }))

    local path_asset = getcustomasset("Project Rain/fonts/Lexend.json");
    local fonts = {
        regular = Font.new(
            path_asset,
            Enum.FontWeight.Regular,
            Enum.FontStyle.Normal
        ),
        medium = Font.new(
            path_asset,
            Enum.FontWeight.Medium,
            Enum.FontStyle.Normal
        ),
        bold = Font.new(
            path_asset,
            Enum.FontWeight.Bold,
            Enum.FontStyle.Normal
        )
    };

    
    
    local done = 0;
    for _, font in pairs(fonts) do
        task.spawn(function()
            local params = Instance.new("GetTextBoundsParams")
            params.Text = "Preload"
            params.Font = font
            params.Size = 16
            game:GetService("TextService"):GetTextBoundsAsync(params)
            params:Destroy()
            done += 1;
        end)
    end

    repeat task.wait() until done == 3;
    return fonts
end

return custom_font.make_lexend_font()