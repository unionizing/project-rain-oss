

local GRID_SIZE = 14;
local GRID_WIDTH = 16;
local GRID_HEIGHT = 16;
local MINE_COUNT = 40;
local TITLE_HEIGHT = 22;

local BOARD_WIDTH = GRID_WIDTH * GRID_SIZE;
local BOARD_HEIGHT = GRID_HEIGHT * GRID_SIZE;
local TOTAL_SAFE_CELLS = (GRID_WIDTH * GRID_HEIGHT) - MINE_COUNT;

local Converted = {
    ["_ScreenGui"] = Instance.new("ScreenGui");
    ["_Frame"] = Instance.new("Frame");
    ["_TitleLabel"] = Instance.new("TextLabel");
    ["_MineLabel"] = Instance.new("TextLabel");
    ["_Board"] = Instance.new("Frame");
    ["_GameOverLabel"] = Instance.new("TextLabel");
}



Converted["_ScreenGui"].Name = "MinesweeperGui";
Converted["_ScreenGui"].Parent = game:GetService("CoreGui");
Converted["_ScreenGui"].DisplayOrder = 500;
Converted["_ScreenGui"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
Converted["_ScreenGui"].OnTopOfCoreBlur = true;
Converted["_ScreenGui"].Enabled = false;

Converted["_Frame"].AnchorPoint = Vector2.new(0.5, 0.5);
Converted["_Frame"].BackgroundColor3 = Library.MainColor;
Converted["_Frame"].BorderSizePixel = 2;
Converted["_Frame"].Position = UDim2.new(0.3, 0, 0.4, 0);
Converted["_Frame"].Size = UDim2.new(0, BOARD_WIDTH + 4, 0, BOARD_HEIGHT + TITLE_HEIGHT + 2);
Converted["_Frame"].Parent = Converted["_ScreenGui"];
Converted["_Frame"].ClipsDescendants = true;

local stroke = Instance.new("UIStroke", Converted["_Frame"]);
stroke.Thickness = 1;
stroke.ZIndex = 999;
stroke.Color = Library.AccentColor;
stroke.LineJoinMode = Enum.LineJoinMode.Miter;

Converted["_TitleLabel"].FontFace = lexend.regular;
Converted["_TitleLabel"].ZIndex = 2;
Converted["_TitleLabel"].Text = "minesweeper";
Converted["_TitleLabel"].TextColor3 = Library.FontColor;
Converted["_TitleLabel"].TextSize = 14;
Converted["_TitleLabel"].TextXAlignment = Enum.TextXAlignment.Left;
Converted["_TitleLabel"].BackgroundColor3 = Library.BackgroundColor;
Converted["_TitleLabel"].BorderSizePixel = 1;
Converted["_TitleLabel"].BorderColor3 = Library.OutlineColor;
Converted["_TitleLabel"].Size = UDim2.new(1, 0, 0, TITLE_HEIGHT);
Converted["_TitleLabel"].Parent = Converted["_Frame"];

local title_padding = Instance.new("UIPadding", Converted["_TitleLabel"]);
title_padding.PaddingLeft = UDim.new(0, 6);

Converted["_MineLabel"].FontFace = lexend.regular;
Converted["_MineLabel"].ZIndex = 2;
Converted["_MineLabel"].Text = tostring(MINE_COUNT);
Converted["_MineLabel"].TextColor3 = Library.AccentColor;
Converted["_MineLabel"].TextSize = 14;
Converted["_MineLabel"].TextXAlignment = Enum.TextXAlignment.Right;
Converted["_MineLabel"].BackgroundTransparency = 1;
Converted["_MineLabel"].Size = UDim2.new(0, 60, 1, 0);
Converted["_MineLabel"].Position = UDim2.new(1, -66, 0, 0);
Converted["_MineLabel"].Parent = Converted["_TitleLabel"];

Converted["_Board"].BackgroundColor3 = Library.MainColor;
Converted["_Board"].BorderSizePixel = 0;
Converted["_Board"].Position = UDim2.new(0, 2, 0, TITLE_HEIGHT);
Converted["_Board"].Size = UDim2.new(0, BOARD_WIDTH, 0, BOARD_HEIGHT);
Converted["_Board"].ClipsDescendants = true;
Converted["_Board"].Parent = Converted["_Frame"];

Converted["_GameOverLabel"].FontFace = lexend.regular;
Converted["_GameOverLabel"].ZIndex = 6;
Converted["_GameOverLabel"].Text = "game over - r to restart";
Converted["_GameOverLabel"].TextColor3 = Library.FontColor;
Converted["_GameOverLabel"].TextSize = 13;
Converted["_GameOverLabel"].TextWrapped = true;
Converted["_GameOverLabel"].BackgroundTransparency = 1;
Converted["_GameOverLabel"].Size = UDim2.new(1, -8, 0, 32);
Converted["_GameOverLabel"].Position = UDim2.new(0, 4, 0.5, -16);
Converted["_GameOverLabel"].Visible = false;
Converted["_GameOverLabel"].Parent = Converted["_Board"];

local game_over_stroke = Instance.new("UIStroke", Converted["_GameOverLabel"]);
game_over_stroke.Color = Color3.fromRGB(0, 0, 0);

Library:AddToolTip("Left click to reveal, right click to flag. R to restart. Drag the title bar to reposition.", Converted["_TitleLabel"]);



local board = {};
local cell_frames = {};
local game_over = false;
local mines_placed = false;
local revealed_count = 0;
local flags_placed = 0;

local on_reveal_click, on_flag_click;

local function update_cell_visual(x, y)
    local state = board[x][y];
    local inst = cell_frames[x][y];

    if not state.revealed then
        inst.frame.BackgroundColor3 = Library.AccentColorDark;
        inst.label.TextColor3 = Library.RiskColor;
        inst.label.Text = state.flagged and "F" or "";
        return    
end;

    if state.is_mine then
        inst.frame.BackgroundColor3 = state.exploded and Library.RiskColor or Library.MainColor;
        inst.label.TextColor3 = state.exploded and Library.FontColor or Library.RiskColor;
        inst.label.Text = "*";
        return    
end;

    inst.frame.BackgroundColor3 = Library.MainColor;
    inst.label.TextColor3 = Library.FontColor;
    inst.label.Text = state.adjacent > 0 and tostring(state.adjacent) or "";
end;

for x = 0, GRID_WIDTH - 1 do
    board[x] = {};
    cell_frames[x] = {};

    for y = 0, GRID_HEIGHT - 1 do
        board[x][y] = { is_mine = false, revealed = false, flagged = false, exploded = false, adjacent = 0 };

        local cell = Instance.new("Frame");
        cell.BorderSizePixel = 0;
        cell.BackgroundColor3 = Library.AccentColorDark;
        cell.Size = UDim2.fromOffset(GRID_SIZE - 1, GRID_SIZE - 1);
        cell.Position = UDim2.fromOffset(x * GRID_SIZE, y * GRID_SIZE);
        cell.ZIndex = 3;
        cell.Active = true;
        cell.Parent = Converted["_Board"];

        local label = Instance.new("TextLabel");
        label.FontFace = lexend.regular;
        label.ZIndex = 4;
        label.Text = "";
        label.TextColor3 = Library.FontColor;
        label.TextSize = 12;
        label.BackgroundTransparency = 1;
        label.Size = UDim2.fromScale(1, 1);
        label.Parent = cell;

        cell_frames[x][y] = { frame = cell, label = label };

        cell.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                on_reveal_click(x, y);
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                on_flag_click(x, y);
            end;
        end);
    end;
end;

local function place_mines(safe_x, safe_y)
    local placed = 0;

    while placed < MINE_COUNT do
        local x = math.random(0, GRID_WIDTH - 1);
        local y = math.random(0, GRID_HEIGHT - 1);

        if math.abs(x - safe_x) <= 1 and math.abs(y - safe_y) <= 1 then continue end;
        if board[x][y].is_mine then continue end;

        board[x][y].is_mine = true;
        placed += 1;
    end;

    for x = 0, GRID_WIDTH - 1 do
        for y = 0, GRID_HEIGHT - 1 do
            if not board[x][y].is_mine then
                local count = 0;

                for dx = -1, 1 do
                    for dy = -1, 1 do
                        if not (dx == 0 and dy == 0) then
                            local nx, ny = x + dx, y + dy;
                            if nx >= 0 and nx < GRID_WIDTH and ny >= 0 and ny < GRID_HEIGHT and board[nx][ny].is_mine then
                                count += 1;
                            end;
                        end;
                    end;
                end;

                board[x][y].adjacent = count;
            end;
        end;
    end;
end;

local function reveal_cell(start_x, start_y)
    local queue = { { start_x, start_y } };
    local head = 1;

    while queue[head] do
        local cx, cy = queue[head][1], queue[head][2];
        head += 1;

        local state = board[cx][cy];
        if state.revealed or state.flagged then continue end;

        state.revealed = true;
        revealed_count += 1;
        update_cell_visual(cx, cy);

        if state.adjacent == 0 then
            for dx = -1, 1 do
                for dy = -1, 1 do
                    if not (dx == 0 and dy == 0) then
                        local nx, ny = cx + dx, cy + dy;
                        if nx >= 0 and nx < GRID_WIDTH and ny >= 0 and ny < GRID_HEIGHT
                            and not board[nx][ny].revealed and not board[nx][ny].is_mine then
                            table.insert(queue, { nx, ny });
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

local function reveal_all_mines(exploded_x, exploded_y)
    for x = 0, GRID_WIDTH - 1 do
        for y = 0, GRID_HEIGHT - 1 do
            local state = board[x][y];
            if state.is_mine and not state.revealed then
                state.revealed = true;
                state.exploded = (x == exploded_x and y == exploded_y);
                update_cell_visual(x, y);
            end;
        end;
    end;
end;

local function flag_all_mines()
    for x = 0, GRID_WIDTH - 1 do
        for y = 0, GRID_HEIGHT - 1 do
            local state = board[x][y];
            if state.is_mine and not state.flagged then
                state.flagged = true;
                flags_placed += 1;
                update_cell_visual(x, y);
            end;
        end;
    end;

    Converted["_MineLabel"].Text = tostring(MINE_COUNT - flags_placed);
end;

local function on_loss(x, y)
    game_over = true;
    reveal_all_mines(x, y);
    Converted["_GameOverLabel"].Text = "you lose - r to restart";
    Converted["_GameOverLabel"].Visible = true;
end;

local function on_win()
    game_over = true;
    flag_all_mines();
    Converted["_GameOverLabel"].Text = "you win! - r to restart";
    Converted["_GameOverLabel"].Visible = true;
end;

on_reveal_click = function(x, y)
    if game_over then return end;

    local state = board[x][y];
    if state.flagged or state.revealed then return end;

    if not mines_placed then
        place_mines(x, y);
        mines_placed = true;
    end;

    if board[x][y].is_mine then
        board[x][y].revealed = true;
        board[x][y].exploded = true;
        update_cell_visual(x, y);
        return on_loss(x, y)    
end;

    reveal_cell(x, y);

    if revealed_count >= TOTAL_SAFE_CELLS then
        on_win();
    end;
end;

on_flag_click = function(x, y)
    if game_over then return end;

    local state = board[x][y];
    if state.revealed then return end;

    state.flagged = not state.flagged;
    flags_placed += state.flagged and 1 or -1;

    Converted["_MineLabel"].Text = tostring(MINE_COUNT - flags_placed);
    update_cell_visual(x, y);
end;

local function reset_game()
    game_over = false;
    mines_placed = false;
    revealed_count = 0;
    flags_placed = 0;

    for x = 0, GRID_WIDTH - 1 do
        for y = 0, GRID_HEIGHT - 1 do
            board[x][y].is_mine = false;
            board[x][y].revealed = false;
            board[x][y].flagged = false;
            board[x][y].exploded = false;
            board[x][y].adjacent = 0;
            update_cell_visual(x, y);
        end;
    end;

    Converted["_MineLabel"].Text = tostring(MINE_COUNT);
    Converted["_GameOverLabel"].Visible = false;
end;

local feature = Feature:new("minesweeper");




local RESTART_ACTION = "MinesweeperRestart";

local function handle_restart(_, state, input)
    if state ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end;
    if not game_over then return Enum.ContextActionResult.Pass end;
    if services.UserInputService:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end;

    if input.KeyCode == Enum.KeyCode.R or input.KeyCode == Enum.KeyCode.Return then
        reset_game();
        return Enum.ContextActionResult.Sink    
end;

    return Enum.ContextActionResult.Pass
end;





local MB2_SINK_ACTION = "MinesweeperMB2Sink";

local function sink_mb2()
    return Enum.ContextActionResult.Sink
end;

Converted["_Board"].MouseEnter:Connect(function()
    services.ContextActionService:BindActionAtPriority(
        MB2_SINK_ACTION,
        sink_mb2,
        false,
        Enum.ContextActionPriority.High.Value,
        Enum.UserInputType.MouseButton2
    );
end);

Converted["_Board"].MouseLeave:Connect(function()
    services.ContextActionService:UnbindAction(MB2_SINK_ACTION);
end);

function feature:enable()
    Converted["_ScreenGui"].Enabled = true;
    reset_game();

    services.ContextActionService:BindActionAtPriority(
        RESTART_ACTION,
        handle_restart,
        false,
        Enum.ContextActionPriority.High.Value,
        Enum.KeyCode.R,
        Enum.KeyCode.Return
    );
end;

function feature:disable()
    Converted["_ScreenGui"].Enabled = false;
    services.ContextActionService:UnbindAction(RESTART_ACTION);
    services.ContextActionService:UnbindAction(MB2_SINK_ACTION);
end;

Library:AddToRegistry(Converted["_Frame"], {
    BackgroundColor3 = "MainColor"
});

Library:AddToRegistry(stroke, {
    Color = "AccentColor"
}, true);

Library:AddToRegistry(Converted["_TitleLabel"], {
    BackgroundColor3 = "BackgroundColor",
    BorderColor3 = "OutlineColor",
    TextColor3 = "FontColor",
});

Library:AddToRegistry(Converted["_MineLabel"], {
    TextColor3 = "AccentColor"
});

Library:AddToRegistry(Converted["_Board"], {
    BackgroundColor3 = "MainColor"
});

Library:AddToRegistry(Converted["_GameOverLabel"], {
    TextColor3 = "FontColor"
});

Library:MakeDraggableScale(Converted["_Frame"], TITLE_HEIGHT, true);
aztup.maid:give_task(Converted["_ScreenGui"]);

return feature