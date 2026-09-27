

local GRID_SIZE = 14;
local GRID_WIDTH = 16;
local GRID_HEIGHT = 16;
local TITLE_HEIGHT = 22;
local SNAKE_DIFFICULTIES = {
    ["Easy"] = { start = 0.15, min = 0.08, max_speed_score = 200 };
    ["Normal"] = { start = 0.15, min = 0.035, max_speed_score = 140 };
    ["Hard"] = { start = 0.07, min = 0.03, max_speed_score = 50 };
    ["Extreme"] = { start = 0.05, min = 0.02, max_speed_score = 50 };
    ["Lord Regent"] = { start = 0.05, min = 1 / 45, max_speed_score = 200 };
};

local BOARD_WIDTH = GRID_WIDTH * GRID_SIZE;
local BOARD_HEIGHT = GRID_HEIGHT * GRID_SIZE;

local Converted = {
    ["_ScreenGui"] = Instance.new("ScreenGui");
    ["_Frame"] = Instance.new("Frame");
    ["_TitleLabel"] = Instance.new("TextLabel");
    ["_ScoreLabel"] = Instance.new("TextLabel");
    ["_Board"] = Instance.new("Frame");
    ["_GameOverLabel"] = Instance.new("TextLabel");
}



Converted["_ScreenGui"].Name = "SnakeGameGui";
Converted["_ScreenGui"].Parent = game:GetService("CoreGui");
Converted["_ScreenGui"].DisplayOrder = 500;
Converted["_ScreenGui"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
Converted["_ScreenGui"].OnTopOfCoreBlur = true;
Converted["_ScreenGui"].Enabled = false;

Converted["_Frame"].AnchorPoint = Vector2.new(0.5, 0.5);
Converted["_Frame"].BackgroundColor3 = Library.MainColor;
Converted["_Frame"].BorderSizePixel = 2;
Converted["_Frame"].Position = UDim2.new(0.7, 0, 0.4, 0);
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
Converted["_TitleLabel"].Text = "snake";
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

Converted["_Board"].BackgroundColor3 = Library.MainColor;
Converted["_Board"].BorderSizePixel = 0;
Converted["_Board"].Position = UDim2.new(0, 2, 0, TITLE_HEIGHT);
Converted["_Board"].Size = UDim2.new(0, BOARD_WIDTH, 0, BOARD_HEIGHT);
Converted["_Board"].ClipsDescendants = true;
Converted["_Board"].Parent = Converted["_Frame"];

Converted["_GameOverLabel"].FontFace = lexend.regular;
Converted["_GameOverLabel"].ZIndex = 6;
Converted["_GameOverLabel"].Text = "game over - space to restart";
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

Library:AddToolTip("Arrow keys to move, Space to restart. Drag the title bar to reposition.", Converted["_TitleLabel"]);



local snake = {};
local snake_frames = {};
local direction = Vector2.new(1, 0);
local queued_direction = direction;
local food_pos = nil;
local food_frame = nil;
local game_over = false;
local score = 0;
local move_accum = 0;
local bot_enabled = false;

local DIRECTIONS = {
    [Enum.KeyCode.Up] = Vector2.new(0, -1);
    [Enum.KeyCode.Down] = Vector2.new(0, 1);
    [Enum.KeyCode.Left] = Vector2.new(-1, 0);
    [Enum.KeyCode.Right] = Vector2.new(1, 0);
};

local function make_cell(color)
    local cell = Instance.new("Frame");
    cell.BorderSizePixel = 0;
    cell.BackgroundColor3 = color;
    cell.Size = UDim2.fromOffset(GRID_SIZE - 1, GRID_SIZE - 1);
    cell.ZIndex = 3;
    cell.Parent = Converted["_Board"];
    return cell
end;

local function set_cell_pos(cell, x, y)
    cell.Position = UDim2.fromOffset(x * GRID_SIZE, y * GRID_SIZE);
end;

local function get_move_interval()
    local difficulty = aztup_options.snake_difficulty and aztup_options.snake_difficulty.Value or "Normal";
    local settings = SNAKE_DIFFICULTIES[difficulty] or SNAKE_DIFFICULTIES["Normal"];
    local speedup_per_point = (settings.start - settings.min) / settings.max_speed_score;

    return math.max(settings.min, settings.start - score * speedup_per_point)
end;

local function point_in_snake(x, y, exclude_tail)
    local count = #snake;
    for i, seg in ipairs(snake) do
        if exclude_tail and i == count then continue end;
        if seg.x == x and seg.y == y then return true end;
    end;
    return false
end;

local function random_empty_cell()
    while true do
        local x = math.random(0, GRID_WIDTH - 1);
        local y = math.random(0, GRID_HEIGHT - 1);

        if not point_in_snake(x, y, false) then
            return x, y        
end;
    end;
end;

local function spawn_food()
    local x, y = random_empty_cell();
    food_pos = Vector2.new(x, y);

    if not food_frame then
        food_frame = make_cell(Library.RiskColor);
        food_frame.ZIndex = 4;
    end;

    food_frame.Visible = true;
    set_cell_pos(food_frame, x, y);
end;

local function on_game_over()
    game_over = true;
    Converted["_GameOverLabel"].Text = "game over - space to restart";
    Converted["_GameOverLabel"].Visible = true;
end;

local function on_game_won()
    game_over = true;
    if food_frame then
        food_frame.Visible = false;
    end;
    Converted["_GameOverLabel"].Text = "you win! space to restart";
    Converted["_GameOverLabel"].Visible = true;
end;

local function place_snake(head_segment, mid_segment, tail_segment, initial_direction)
    for _, cell in snake_frames do
        cell:Destroy();
    end;
    table.clear(snake_frames);
    table.clear(snake);

    table.insert(snake, { x = head_segment.X, y = head_segment.Y });
    table.insert(snake, { x = mid_segment.X, y = mid_segment.Y });
    table.insert(snake, { x = tail_segment.X, y = tail_segment.Y });

    for i, seg in ipairs(snake) do
        local cell = make_cell(i == 1 and Library.AccentColor or Library.AccentColorDark);
        set_cell_pos(cell, seg.x, seg.y);
        table.insert(snake_frames, cell);
    end;

    direction = initial_direction;
    queued_direction = direction;
    score = 0;
    game_over = false;
    move_accum = 0;

    Converted["_ScoreLabel"].Text = "0";
    Converted["_GameOverLabel"].Visible = false;

    spawn_food();
end;

local function reset_game()
    local start_x = math.floor(GRID_WIDTH / 2);
    local start_y = math.floor(GRID_HEIGHT / 2);

    place_snake(
        Vector2.new(start_x, start_y),
        Vector2.new(start_x - 1, start_y),
        Vector2.new(start_x - 2, start_y),
        Vector2.new(1, 0)
    );
end;

local function step()
    if game_over then return end;

    direction = queued_direction;

    local head = snake[1];
    local new_x = head.x + direction.X;
    local new_y = head.y + direction.Y;

    if new_x < 0 or new_x >= GRID_WIDTH or new_y < 0 or new_y >= GRID_HEIGHT then
        return on_game_over()    
end;

    local growing = food_pos and new_x == food_pos.X and new_y == food_pos.Y;

    if point_in_snake(new_x, new_y, not growing) then
        return on_game_over()    
end;

    table.insert(snake, 1, { x = new_x, y = new_y });

    local head_frame;
    local board_filled = false;
    if growing then
        head_frame = make_cell(Library.AccentColor);
        table.insert(snake_frames, 1, head_frame);

        score += 10;
        Converted["_ScoreLabel"].Text = tostring(score);

        if #snake >= GRID_WIDTH * GRID_HEIGHT then
            board_filled = true;
            food_pos = nil;
        else
            spawn_food();
        end;
    else
        table.remove(snake);
        head_frame = table.remove(snake_frames);
        head_frame.BackgroundColor3 = Library.AccentColor;
        table.insert(snake_frames, 1, head_frame);
    end;

    set_cell_pos(head_frame, new_x, new_y);

    if snake_frames[2] then
        snake_frames[2].BackgroundColor3 = Library.AccentColorDark;
    end;

    if board_filled then
        return on_game_won()    
end;
end;








local MOORE_ORDER = 3;
local MOORE_RULES = {
    L = "-RF+LFL+FR-";
    R = "+LF-RFR-FL+";
};

local function build_hamilton_cycle()
    local sequence = "LFL+F+LFL";
    for _ = 1, MOORE_ORDER do
        local expanded = {};
        for i = 1, #sequence do
            local ch = sequence:sub(i, i);
            table.insert(expanded, MOORE_RULES[ch] or ch);
        end;
        sequence = table.concat(expanded);
    end;

    local step_dirs = { Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(-1, 0), Vector2.new(0, -1) };
    local heading = 0;
    local x, y = 0, 0;
    local cells = { Vector2.new(0, 0) };

    for i = 1, #sequence do
        local ch = sequence:sub(i, i);
        if ch == "F" then
            local dir = step_dirs[heading + 1];
            x += dir.X;
            y += dir.Y;
            table.insert(cells, Vector2.new(x, y));
        elseif ch == "+" then
            heading = (heading + 1) % 4;
        elseif ch == "-" then
            heading = (heading - 1) % 4;
        end;
    end;

    local min_x, min_y = math.huge, math.huge;
    for _, cell in ipairs(cells) do
        min_x = math.min(min_x, cell.X);
        min_y = math.min(min_y, cell.Y);
    end;
    for i, cell in ipairs(cells) do
        cells[i] = Vector2.new(cell.X - min_x, cell.Y - min_y);
    end;

    return cells
end;

local HAMILTON_CYCLE = build_hamilton_cycle();
local HAMILTON_INDEX = {};
for i, cell in ipairs(HAMILTON_CYCLE) do
    HAMILTON_INDEX[cell.X .. "," .. cell.Y] = i;
end;




local function find_bot_spawn()
    local count = #HAMILTON_CYCLE;
    local function at(i)
        return HAMILTON_CYCLE[((i - 1) % count) + 1]    
end;

    for i = 1, count do
        local tail, mid, head = at(i), at(i + 1), at(i + 2);
        local step_a = Vector2.new(mid.X - tail.X, mid.Y - tail.Y);
        local step_b = Vector2.new(head.X - mid.X, head.Y - mid.Y);
        if step_a == step_b then
            return head, mid, tail, step_a        
end;
    end;
end;

local BOT_SPAWN_HEAD, BOT_SPAWN_MID, BOT_SPAWN_TAIL, BOT_SPAWN_DIRECTION = find_bot_spawn();
assert(BOT_SPAWN_HEAD, "Snake: Hamiltonian loop has no straight 3-cell run to spawn the bot on");

local function align_snake_to_bot_spawn()
    place_snake(BOT_SPAWN_HEAD, BOT_SPAWN_MID, BOT_SPAWN_TAIL, BOT_SPAWN_DIRECTION);
end;

local function get_bot_move()
    local head = snake[1];
    local index = HAMILTON_INDEX[head.x .. "," .. head.y];
    if not index then return nil end;

    local next_cell = HAMILTON_CYCLE[(index % #HAMILTON_CYCLE) + 1];
    return Vector2.new(next_cell.X - head.x, next_cell.Y - head.y)
end;

local feature = Feature:new("snake_game", services.RunService.Heartbeat, function(dt)
    if bot_enabled and game_over then
        align_snake_to_bot_spawn();
    end;

    if game_over then return end;

    move_accum += dt;
    local move_interval = get_move_interval();
    if move_accum < move_interval then return end;
    move_accum -= move_interval;

    if bot_enabled then
        local move = get_bot_move();
        if move then
            queued_direction = move;
        end;
    end;

    step();
end);

local SNAKE_ACTION = "SnakeGameInput";

local function handle_action(_, state, input)
    if state ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end;
    if services.UserInputService:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end;

    if game_over then
        if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return then
            reset_game();
        end;
        return Enum.ContextActionResult.Sink    
end;

    local new_direction = DIRECTIONS[input.KeyCode];
    if new_direction and new_direction ~= -direction then
        queued_direction = new_direction;
    end;

    return Enum.ContextActionResult.Sink
end;

local BOT_ACTION = "SnakeGameBotToggle";

local function handle_bot_action(_, state)
    if state ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end;

    bot_enabled = not bot_enabled;
    Converted["_TitleLabel"].Text = bot_enabled and "snake (bot)" or "snake";

    if bot_enabled then
        
        
        align_snake_to_bot_spawn();
    end;

    return Enum.ContextActionResult.Sink
end;

function feature:enable()
    Converted["_ScreenGui"].Enabled = true;
    reset_game();

    services.ContextActionService:BindActionAtPriority(
        SNAKE_ACTION,
        handle_action,
        false,
        Enum.ContextActionPriority.High.Value,
        Enum.KeyCode.Up,
        Enum.KeyCode.Down,
        Enum.KeyCode.Left,
        Enum.KeyCode.Right,
        Enum.KeyCode.Space,
        Enum.KeyCode.Return
    );

    services.ContextActionService:BindActionAtPriority(
        BOT_ACTION,
        handle_bot_action,
        false,
        Enum.ContextActionPriority.High.Value,
        Enum.KeyCode.F5
    );
end;

function feature:disable()
    Converted["_ScreenGui"].Enabled = false;
    services.ContextActionService:UnbindAction(SNAKE_ACTION);
    services.ContextActionService:UnbindAction(BOT_ACTION);

    bot_enabled = false;
    Converted["_TitleLabel"].Text = "snake";
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

Library:AddToRegistry(Converted["_Board"], {
    BackgroundColor3 = "MainColor"
});

Library:AddToRegistry(Converted["_GameOverLabel"], {
    TextColor3 = "FontColor"
});

Library:MakeDraggableScale(Converted["_Frame"], TITLE_HEIGHT, true);
aztup.maid:give_task(Converted["_ScreenGui"]);

return feature