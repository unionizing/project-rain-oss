services.RunService.RenderStepped:Connect(function()
    if not Library.Toggled then return end
    
    services.UserInputService.MouseIconEnabled = Library.Toggled or Library.RequestingMouse;
end);

return