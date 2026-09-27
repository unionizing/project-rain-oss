

local GRID_SIZE = 14;
local GRID_WIDTH = 10;
local GRID_HEIGHT = 20;
local TITLE_HEIGHT = 22;

local BOARD_WIDTH = GRID_WIDTH * GRID_SIZE;
local BOARD_HEIGHT = GRID_HEIGHT * GRID_SIZE;

local PREVIEW_PANEL_WIDTH = 64;
local PREVIEW_PANEL_HEIGHT = 90;
local PREVIEW_GRID_OFFSET_X = 4;
local PREVIEW_GRID_OFFSET_Y = 24;
local PANEL_GAP = 4;

local FRAME_WIDTH = 2 + BOARD_WIDTH + PANEL_GAP + PREVIEW_PANEL_WIDTH + 2;
local FRAME_HEIGHT = TITLE_HEIGHT + BOARD_HEIGHT + 2;

local SOFT_DROP_INTERVAL = 0.1;
local LINE_SCORES = { [1] = 100, [2] = 300, [3] = 500, [4] = 800 };
local ROTATION_KICKS = { 0, -1, 1, -2, 2 };



local SHAPES = {
    I = {
        [1] = { { 0, 1 }, { 1, 1 }, { 2, 1 }, { 3, 1 } };
        [2] = { { 2, 0 }, { 2, 1 }, { 2, 2 }, { 2, 3 } };
        [3] = { { 0, 2 }, { 1, 2 }, { 2, 2 }, { 3, 2 } };
        [4] = { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 1, 3 } };
    };
    O = {
        [1] = { { 1, 0 }, { 2, 0 }, { 1, 1 }, { 2, 1 } };
        [2] = { { 1, 0 }, { 2, 0 }, { 1, 1 }, { 2, 1 } };
        [3] = { { 1, 0 }, { 2, 0 }, { 1, 1 }, { 2, 1 } };
        [4] = { { 1, 0 }, { 2, 0 }, { 1, 1 }, { 2, 1 } };
    };
    T = {
        [1] = { { 1, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 } };
        [2] = { { 1, 0 }, { 1, 1 }, { 2, 1 }, { 1, 2 } };
        [3] = { { 0, 1 }, { 1, 1 }, { 2, 1 }, { 1, 2 } };
        [4] = { { 1, 0 }, { 0, 1 }, { 1, 1 }, { 1, 2 } };
    };
    S = {
        [1] = { { 1, 0 }, { 2, 0 }, { 0, 1 }, { 1, 1 } };
        [2] = { { 1, 0 }, { 1, 1 }, { 2, 1 }, { 2, 2 } };
        [3] = { { 1, 1 }, { 2, 1 }, { 0, 2 }, { 1, 2 } };
        [4] = { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 1, 2 } };
    };
    Z = {
        [1] = { { 0, 0 }, { 1, 0 }, { 1, 1 }, { 2, 1 } };
        [2] = { { 2, 0 }, { 1, 1 }, { 2, 1 }, { 1, 2 } };
        [3] = { { 0, 1 }, { 1, 1 }, { 1, 2 }, { 2, 2 } };
        [4] = { { 1, 0 }, { 0, 1 }, { 1, 1 }, { 0, 2 } };
    };
    J = {
        [1] = { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 } };
        [2] = { { 1, 0 }, { 2, 0 }, { 1, 1 }, { 1, 2 } };
        [3] = { { 0, 1 }, { 1, 1 }, { 2, 1 }, { 2, 2 } };
        [4] = { { 1, 0 }, { 1, 1 }, { 0, 2 }, { 1, 2 } };
    };
    L = {
        [1] = { { 2, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 } };
        [2] = { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 2, 2 } };
        [3] = { { 0, 1 }, { 1, 1 }, { 2, 1 }, { 0, 2 } };
        [4] = { { 0, 0 }, { 1, 0 }, { 1, 1 }, { 1, 2 } };
    };
};

local PIECE_TYPES = { "I", "O", "T", "S", "Z", "J", "L" };







local PIECE_COLORS = {
    I = Color3.fromRGB(0, 240, 240);
    O = Color3.fromRGB(240, 240, 0);
    T = Color3.fromRGB(160, 0, 240);
    S = Color3.fromRGB(0, 240, 0);
    Z = Color3.fromRGB(240, 0, 0);
    J = Color3.fromRGB(0, 0, 240);
    L = Color3.fromRGB(240, 160, 0);
};

local Converted = {
    ["_ScreenGui"] = Instance.new("ScreenGui");
    ["_Frame"] = Instance.new("Frame");
    ["_TitleLabel"] = Instance.new("TextLabel");
    ["_ScoreLabel"] = Instance.new("TextLabel");
    ["_LevelLabel"] = Instance.new("TextLabel");
    ["_Board"] = Instance.new("Frame");
    ["_PreviewPanel"] = Instance.new("Frame");
    ["_PreviewLabel"] = Instance.new("TextLabel");
    ["_GameOverLabel"] = Instance.new("TextLabel");
}



Converted["_ScreenGui"].Name = "TetrisGui";
Converted["_ScreenGui"].Parent = game:GetService("CoreGui");
Converted["_ScreenGui"].DisplayOrder = 500;
Converted["_ScreenGui"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
Converted["_ScreenGui"].OnTopOfCoreBlur = true;
Converted["_ScreenGui"].Enabled = false;

Converted["_Frame"].AnchorPoint = Vector2.new(0.5, 0.5);
Converted["_Frame"].BackgroundColor3 = Library.MainColor;
Converted["_Frame"].BorderSizePixel = 2;
Converted["_Frame"].Position = UDim2.new(0.5, 0, 0.4, 0);
Converted["_Frame"].Size = UDim2.new(0, FRAME_WIDTH, 0, FRAME_HEIGHT);
Converted["_Frame"].Parent = Converted["_ScreenGui"];
Converted["_Frame"].ClipsDescendants = true;

local stroke = Instance.new("UIStroke", Converted["_Frame"]);
stroke.Thickness = 1;
stroke.ZIndex = 999;
stroke.Color = Library.AccentColor;
stroke.LineJoinMode = Enum.LineJoinMode.Miter;

Converted["_TitleLabel"].FontFace = lexend.regular;
Converted["_TitleLabel"].ZIndex = 2;
Converted["_TitleLabel"].Text = "tetris";
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

Converted["_ScoreLabel"].FontFace = lexend.regular;
Converted["_ScoreLabel"].ZIndex = 2;
Converted["_ScoreLabel"].Text = "0";
Converted["_ScoreLabel"].TextColor3 = Library.AccentColor;
Converted["_ScoreLabel"].TextSize = 14;
Converted["_ScoreLabel"].TextXAlignment = Enum.TextXAlignment.Right;
Converted["_ScoreLabel"].BackgroundTransparency = 1;
Converted["_ScoreLabel"].Size = UDim2.new(0, 60, 1, 0);
Converted["_ScoreLabel"].Position = UDim2.new(1, -66, 0, 0);
Converted["_ScoreLabel"].Parent = Converted["_TitleLabel"];

Converted["_LevelLabel"].FontFace = lexend.regular;
Converted["_LevelLabel"].ZIndex = 2;
Converted["_LevelLabel"].Text = "Lv 1";
Converted["_LevelLabel"].TextColor3 = Library.AccentColorDark;
Converted["_LevelLabel"].TextSize = 14;
Converted["_LevelLabel"].TextXAlignment = Enum.TextXAlignment.Right;
Converted["_LevelLabel"].BackgroundTransparency = 1;
Converted["_LevelLabel"].Size = UDim2.new(0, 50, 1, 0);
Converted["_LevelLabel"].Position = UDim2.new(1, -120, 0, 0);
Converted["_LevelLabel"].Parent = Converted["_TitleLabel"];

Converted["_Board"].BackgroundColor3 = Library.MainColor;
Converted["_Board"].BorderSizePixel = 0;
Converted["_Board"].Position = UDim2.new(0, 2, 0, TITLE_HEIGHT);
Converted["_Board"].Size = UDim2.new(0, BOARD_WIDTH, 0, BOARD_HEIGHT);
Converted["_Board"].ClipsDescendants = true;
Converted["_Board"].Parent = Converted["_Frame"];

Converted["_PreviewPanel"].BackgroundColor3 = Library.MainColor;
Converted["_PreviewPanel"].BorderSizePixel = 0;
Converted["_PreviewPanel"].Position = UDim2.new(0, 2 + BOARD_WIDTH + PANEL_GAP, 0, TITLE_HEIGHT);
Converted["_PreviewPanel"].Size = UDim2.new(0, PREVIEW_PANEL_WIDTH, 0, PREVIEW_PANEL_HEIGHT);
Converted["_PreviewPanel"].ClipsDescendants = true;
Converted["_PreviewPanel"].Parent = Converted["_Frame"];

local panel_stroke = Instance.new("UIStroke", Converted["_PreviewPanel"]);
panel_stroke.Thickness = 1;
panel_stroke.Color = Library.OutlineColor;
panel_stroke.LineJoinMode = Enum.LineJoinMode.Miter;

Converted["_PreviewLabel"].FontFace = lexend.medium;
Converted["_PreviewLabel"].ZIndex = 2;
Converted["_PreviewLabel"].Text = "next";
Converted["_PreviewLabel"].TextColor3 = Library.FontColor;
Converted["_PreviewLabel"].TextSize = 12;
Converted["_PreviewLabel"].TextXAlignment = Enum.TextXAlignment.Center;
Converted["_PreviewLabel"].BackgroundTransparency = 1;
Converted["_PreviewLabel"].Size = UDim2.new(1, 0, 0, 16);
Converted["_PreviewLabel"].Position = UDim2.new(0, 0, 0, 4);
Converted["_PreviewLabel"].Parent = Converted["_PreviewPanel"];

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

Library:AddToolTip("Left/Right to move, Up or X to rotate, Down to soft drop, Space to hard drop, R to restart. Drag the title bar to reposition.", Converted["_TitleLabel"]);



local board = {};
local cell_frames = {};

for x = 0, GRID_WIDTH - 1 do
    board[x] = {};
    cell_frames[x] = {};

    for y = 0, GRID_HEIGHT - 1 do
        board[x][y] = nil;

        local cell = Instance.new("Frame");
        cell.BorderSizePixel = 0;
        cell.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        cell.BackgroundTransparency = 1;
        cell.Size = UDim2.fromOffset(GRID_SIZE - 1, GRID_SIZE - 1);
        cell.Position = UDim2.fromOffset(x * GRID_SIZE, y * GRID_SIZE);
        cell.ZIndex = 3;
        cell.Parent = Converted["_Board"];

        cell_frames[x][y] = cell;
    end;
end;

local preview_frames = {};

for x = 0, 3 do
    preview_frames[x] = {};

    for y = 0, 3 do
        local cell = Instance.new("Frame");
        cell.BorderSizePixel = 0;
        cell.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        cell.BackgroundTransparency = 1;
        cell.Size = UDim2.fromOffset(GRID_SIZE - 1, GRID_SIZE - 1);
        cell.Position = UDim2.fromOffset(PREVIEW_GRID_OFFSET_X + x * GRID_SIZE, PREVIEW_GRID_OFFSET_Y + y * GRID_SIZE);
        cell.ZIndex = 4;
        cell.Parent = Converted["_PreviewPanel"];

        preview_frames[x][y] = cell;
    end;
end;



local current = nil;
local next_type = nil;
local game_over = false;
local score = 0;
local total_lines = 0;
local level = 1;
local drop_accum = 0;
local soft_drop_held = false;

local function random_piece_type()
    return PIECE_TYPES[math.random(1, #PIECE_TYPES)]
end;

local function render_cell(x, y)
    local color = board[x][y];
    local frame = cell_frames[x][y];

    if color then
        frame.BackgroundTransparency = 0;
        frame.BackgroundColor3 = color;
    else
        frame.BackgroundTransparency = 1;
    end;
end;

local function redraw_board()
    for x = 0, GRID_WIDTH - 1 do
        for y = 0, GRID_HEIGHT - 1 do
            render_cell(x, y);
        end;
    end;
end;

local function get_piece_cells(piece)
    local cells = {};
    for _, c in ipairs(SHAPES[piece.type][piece.rot]) do
        table.insert(cells, { c[1] + piece.x, c[2] + piece.y });
    end;
    return cells
end;

local function collides(cells)
    for _, c in ipairs(cells) do
        local x, y = c[1], c[2];
        if x < 0 or x >= GRID_WIDTH or y >= GRID_HEIGHT then return true end;
        if y >= 0 and board[x][y] then return true end;
    end;
    return false
end;

local function draw_active()
    local color = PIECE_COLORS[current.type];

    for _, c in ipairs(get_piece_cells(current)) do
        local x, y = c[1], c[2];
        if y >= 0 and y < GRID_HEIGHT and x >= 0 and x < GRID_WIDTH then
            local frame = cell_frames[x][y];
            frame.BackgroundTransparency = 0;
            frame.BackgroundColor3 = color;
        end;
    end;
end;

local function erase_active()
    for _, c in ipairs(get_piece_cells(current)) do
        local x, y = c[1], c[2];
        if y >= 0 and y < GRID_HEIGHT and x >= 0 and x < GRID_WIDTH then
            render_cell(x, y);
        end;
    end;
end;

local function update_preview()
    for x = 0, 3 do
        for y = 0, 3 do
            preview_frames[x][y].BackgroundTransparency = 1;
        end;
    end;

    local color = PIECE_COLORS[next_type];
    for _, c in ipairs(SHAPES[next_type][1]) do
        local frame = preview_frames[c[1] ][c[2] ];
        frame.BackgroundTransparency = 0;
        frame.BackgroundColor3 = color;
    end;
end;

local function try_move(dx, dy)
    local candidate = { type = current.type, rot = current.rot, x = current.x + dx, y = current.y + dy };

    if collides(get_piece_cells(candidate)) then
        return false    
end;

    erase_active();
    current = candidate;
    draw_active();
    return true
end;

local function try_rotate()
    local new_rot = current.rot % 4 + 1;

    for _, dx in ipairs(ROTATION_KICKS) do
        local candidate = { type = current.type, rot = new_rot, x = current.x + dx, y = current.y };

        if not collides(get_piece_cells(candidate)) then
            erase_active();
            current = candidate;
            draw_active();
            return true        
end;
    end;

    return false
end;

local function clear_lines()
    local cleared = 0;
    local y = GRID_HEIGHT - 1;

    while y >= 0 do
        local full = true;
        for x = 0, GRID_WIDTH - 1 do
            if not board[x][y] then full = false; break end;
        end;

        if full then
            cleared += 1;

            for yy = y, 1, -1 do
                for x = 0, GRID_WIDTH - 1 do
                    board[x][yy] = board[x][yy - 1];
                end;
            end;

            for x = 0, GRID_WIDTH - 1 do
                board[x][0] = nil;
            end;
        else
            y -= 1;
        end;
    end;

    return cleared
end;

local function spawn_piece()
    current = { type = next_type, rot = 1, x = math.floor((GRID_WIDTH - 4) / 2), y = 0 };
    next_type = random_piece_type();
    update_preview();

    if collides(get_piece_cells(current)) then
        game_over = true;
        Converted["_GameOverLabel"].Visible = true;
        return    
end;

    draw_active();
end;

local function lock_current()
    for _, c in ipairs(get_piece_cells(current)) do
        local x, y = c[1], c[2];
        if y >= 0 and y < GRID_HEIGHT and x >= 0 and x < GRID_WIDTH then
            board[x][y] = PIECE_COLORS[current.type];
        end;
    end;

    local cleared = clear_lines();
    redraw_board();

    if cleared > 0 then
        score += (LINE_SCORES[cleared] or 0) * level;
        total_lines += cleared;
        level = math.floor(total_lines / 10) + 1;
        Converted["_ScoreLabel"].Text = tostring(score);
        Converted["_LevelLabel"].Text = "Lv " .. tostring(level);
    end;

    drop_accum = 0;
    spawn_piece();
end;

local function hard_drop()
    while try_move(0, 1) do end;
    lock_current();
end;

local function get_drop_interval()
    return math.max(0.1, 0.8 - (level - 1) * 0.05)
end;

local function reset_game()
    game_over = false;
    score = 0;
    total_lines = 0;
    level = 1;
    drop_accum = 0;
    soft_drop_held = false;

    for x = 0, GRID_WIDTH - 1 do
        for y = 0, GRID_HEIGHT - 1 do
            board[x][y] = nil;
        end;
    end;

    redraw_board();

    Converted["_ScoreLabel"].Text = "0";
    Converted["_LevelLabel"].Text = "Lv 1";
    Converted["_GameOverLabel"].Visible = false;

    next_type = random_piece_type();
    spawn_piece();
end;

local feature = Feature:new("tetris", services.RunService.Heartbeat, function(dt)
    if game_over then return end;

    local interval = soft_drop_held and SOFT_DROP_INTERVAL or get_drop_interval();
    drop_accum += dt;
    if drop_accum < interval then return end;
    drop_accum -= interval;

    if not try_move(0, 1) then
        lock_current();
    end;
end);

local TETRIS_ACTION = "TetrisGameInput";

local function handle_action(_, state, input)
    if services.UserInputService:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end;

    if input.KeyCode == Enum.KeyCode.Down then
        if state == Enum.UserInputState.Begin then
            soft_drop_held = true;
        elseif state == Enum.UserInputState.End then
            soft_drop_held = false;
        end;
        return Enum.ContextActionResult.Sink    
end;

    if state ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end;
    if game_over then return Enum.ContextActionResult.Sink end;

    if input.KeyCode == Enum.KeyCode.Left then
        try_move(-1, 0);
    elseif input.KeyCode == Enum.KeyCode.Right then
        try_move(1, 0);
    elseif input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.X then
        try_rotate();
    elseif input.KeyCode == Enum.KeyCode.Space then
        hard_drop();
    end;

    return Enum.ContextActionResult.Sink
end;




local RESTART_ACTION = "TetrisRestart";

local function handle_restart(_, state, input)
    if state ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end;
    if not game_over then return Enum.ContextActionResult.Pass end;
    if services.UserInputService:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end;

    if input.KeyCode == Enum.KeyCode.R then
        reset_game();
        return Enum.ContextActionResult.Sink    
end;

    return Enum.ContextActionResult.Pass
end;

function feature:enable()
    Converted["_ScreenGui"].Enabled = true;
    reset_game();

    services.ContextActionService:BindActionAtPriority(
        TETRIS_ACTION,
        handle_action,
        false,
        Enum.ContextActionPriority.High.Value,
        Enum.KeyCode.Left,
        Enum.KeyCode.Right,
        Enum.KeyCode.Down,
        Enum.KeyCode.Up,
        Enum.KeyCode.X,
        Enum.KeyCode.Space
    );

    services.ContextActionService:BindActionAtPriority(
        RESTART_ACTION,
        handle_restart,
        false,
        Enum.ContextActionPriority.High.Value,
        Enum.KeyCode.R
    );
end;

function feature:disable()
    Converted["_ScreenGui"].Enabled = false;
    soft_drop_held = false;
    services.ContextActionService:UnbindAction(TETRIS_ACTION);
    services.ContextActionService:UnbindAction(RESTART_ACTION);
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

Library:AddToRegistry(Converted["_ScoreLabel"], {
    TextColor3 = "AccentColor"
});

Library:AddToRegistry(Converted["_LevelLabel"], {
    TextColor3 = "AccentColorDark"
});

Library:AddToRegistry(Converted["_Board"], {
    BackgroundColor3 = "MainColor"
});

Library:AddToRegistry(Converted["_PreviewPanel"], {
    BackgroundColor3 = "MainColor"
});

Library:AddToRegistry(panel_stroke, {
    Color = "OutlineColor"
}, true);

Library:AddToRegistry(Converted["_PreviewLabel"], {
    TextColor3 = "FontColor"
});

Library:AddToRegistry(Converted["_GameOverLabel"], {
    TextColor3 = "FontColor"
});

Library:MakeDraggableScale(Converted["_Frame"], TITLE_HEIGHT, true);
aztup.maid:give_task(Converted["_ScreenGui"]);

return feature