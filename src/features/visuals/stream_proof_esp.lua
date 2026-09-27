
if identifyexecutor() ~= "Volt" then return end
local self = Feature:new("stream_proof_esp");
self.font = DrawFont.Register(readfile("Project Rain/fonts/lexend.ttf"), {
    PixelSize = 16
});

local live: Folder = workspace:WaitForChild("Live");
self.draw = LPH_NO_VIRTUALIZE(function()
    local camera_cframe = workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new();
    local left_healthbar = camera_cframe:VectorToWorldSpace(Vector3.new(-4, 3, 0)) 
    local right_healthbar = camera_cframe:VectorToWorldSpace(Vector3.new(-3.5, -3, 0));
    local centroid_healthbar = camera_cframe:VectorToWorldSpace(Vector3.new(-3.4, 3, 0));
    local color = aztup_options.stream_proof_esp_color.Value;

    for _, object in live:GetChildren() do
        if object.Name:sub(1,1) == "." then continue end
        if object == local_player.character then continue end

        local torso = object:FindFirstChild("Torso");
        if not torso then continue end

        local humanoid = object:FindFirstChild("Humanoid");
        if not humanoid then continue end

        local left_healthbar_pos = torso.Position + left_healthbar;
        local right_healthbar_pos = torso.Position + right_healthbar;
        local centroid_healthbar_pos = torso.Position + centroid_healthbar;

        local left_healthbar_screen_pos, left_healthbar_on_screen = workspace.CurrentCamera:WorldToViewportPoint(left_healthbar_pos);
        if left_healthbar_on_screen then
            local right_healthbar_screen_pos, right_healthbar_on_screen = workspace.CurrentCamera:WorldToViewportPoint(right_healthbar_pos); 
            if right_healthbar_on_screen then
                local centroid_healthbar_screen_pos = workspace.CurrentCamera:WorldToViewportPoint(centroid_healthbar_pos);
                local percent = humanoid.Health / humanoid.MaxHealth;
                local healthbar_color = Color3.new(0, 1, 0):Lerp(Color3.new(1, 0, 0), 1 - percent);

                local p1 = left_healthbar_screen_pos
                local p2 = Vector2.new(right_healthbar_screen_pos.X, left_healthbar_screen_pos.Y)
                local p3 = right_healthbar_screen_pos
                local p4 = Vector2.new(left_healthbar_screen_pos.X, right_healthbar_screen_pos.Y)

                DrawingImmediate.Quad(p1, p2, p3, p4, color, 0.8, 2)
                DrawingImmediate.OutlinedText(centroid_healthbar_screen_pos, self.font, 20, color, 1, Color3.fromRGB(0, 0, 0), 1, string.format("%i", percent * 100) .. "%", true);

                local height = (p3.Y - p1.Y)
                local fill_height = height * percent

                local filled_p1 = Vector2.new(p4.X, p4.Y - fill_height)
                local filled_p2 = Vector2.new(p3.X, p3.Y - fill_height)

                DrawingImmediate.FilledQuad(filled_p1, filled_p2, p3, p4, healthbar_color, 0.5)
            end;
        end;
    end
end);

function self:enable()
    self.current = DrawingImmediate.GetPaint():Connect(self.draw);
end

function self:disable()
    if not self.current then return end

    self.current:Disconnect();
end

return self