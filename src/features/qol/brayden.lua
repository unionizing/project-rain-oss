







local HttpService = services.HttpService;

local WIDTH = 260;
local TITLE_HEIGHT = 22;
local STAGE_HEIGHT = 178;
local STATS_HEIGHT = 58;
local ROW_HEIGHT = 24;
local HEIGHT = TITLE_HEIGHT + STAGE_HEIGHT + STATS_HEIGHT + ROW_HEIGHT * 2 + 12;

local SAVE_PATH = "Project Rain/brayden.json";
local PORTRAIT_PATH = "Project Rain/Assets/brayden.png";

local FOODS = { "Burger", "Sushi", "Pizza", "Salad", "Tacos", "Curry", "Donut", "Natto", "Ramen", "Cake", "Steak", "Eel" };
local GIFTS = { "Cap", "Hoodie", "Guitar", "Game", "Sunglasses", "Plushie", "Skateboard", "Houseplant" };
local FOOD_ROW_SIZE = 6;

local IDLE_LINES = {
    "What a nice day on the island...",
    "I wonder what's for dinner.",
    "Do you ever think about birds?",
    "I had the weirdest dream last night.",
    "I'm Brayden. Nice to meet you!",
    "Hey hey hey!",
    "La la laaa~",
    "I should call my mom.",
    "Is it just me or is it warm today?",
};

local TALK_LINES = {
    "You know, you're my best friend.",
    "I've been practicing my dance moves!",
    "I want to go to the beach someday.",
    "Do you think I'd look good with a mustache?",
    "Someone on the island keeps staring at me...",
    "I tried cooking yesterday. The fire department came.",
    "If I were a vegetable I'd be a cool cucumber.",
    "My catchphrase is getting popular, I think.",
    "I think I'm in love... with sleeping in.",
};

local DREAMS = {
    "I dreamt I was a giant floating in space, eating the moon like a rice cake.",
    "I dreamt my hair turned into spaghetti and everyone wanted a bite.",
    "I dreamt I was the king of the island, but my crown was a bucket.",
    "I dreamt I was a penguin trying to get a job interview.",
    "I dreamt you and I were both potatoes. It was nice.",
};

local CATCHPHRASES = { "dude!", "no way!", "sheesh", "bruh", "let's gooo", "yippee", "big chungus", "wowza" };

local Converted = {
    ["_ScreenGui"] = Instance.new("ScreenGui");
    ["_Frame"] = Instance.new("Frame");
    ["_TitleLabel"] = Instance.new("TextLabel");
    ["_LevelLabel"] = Instance.new("TextLabel");
    ["_Stage"] = Instance.new("Frame");
    ["_Portrait"] = Instance.new("ImageButton");
    ["_Bubble"] = Instance.new("TextLabel");
    ["_Alert"] = Instance.new("TextLabel");
    ["_Stats"] = Instance.new("Frame");
    ["_FoodRow"] = Instance.new("Frame");
    ["_ActionRow"] = Instance.new("Frame");
}



Converted["_ScreenGui"].Name = "BraydenGui";
Converted["_ScreenGui"].Parent = game:GetService("CoreGui");
Converted["_ScreenGui"].DisplayOrder = 500;
Converted["_ScreenGui"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
Converted["_ScreenGui"].OnTopOfCoreBlur = true;
Converted["_ScreenGui"].Enabled = false;

Converted["_Frame"].AnchorPoint = Vector2.new(0.5, 0.5);
Converted["_Frame"].BackgroundColor3 = Library.MainColor;
Converted["_Frame"].BorderSizePixel = 2;
Converted["_Frame"].Position = UDim2.new(0.7, 0, 0.4, 0);
Converted["_Frame"].Size = UDim2.new(0, WIDTH, 0, HEIGHT);
Converted["_Frame"].Parent = Converted["_ScreenGui"];
Converted["_Frame"].ClipsDescendants = true;
Library:AddUIScale(Converted["_Frame"]);

local stroke = Instance.new("UIStroke", Converted["_Frame"]);
stroke.Thickness = 1;
stroke.ZIndex = 999;
stroke.Color = Library.AccentColor;
stroke.LineJoinMode = Enum.LineJoinMode.Miter;

Converted["_TitleLabel"].FontFace = lexend.regular;
Converted["_TitleLabel"].ZIndex = 2;
Converted["_TitleLabel"].Text = "brayden";
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

Converted["_LevelLabel"].FontFace = lexend.regular;
Converted["_LevelLabel"].ZIndex = 2;
Converted["_LevelLabel"].Text = "lv 1";
Converted["_LevelLabel"].TextColor3 = Library.AccentColor;
Converted["_LevelLabel"].TextSize = 14;
Converted["_LevelLabel"].TextXAlignment = Enum.TextXAlignment.Right;
Converted["_LevelLabel"].BackgroundTransparency = 1;
Converted["_LevelLabel"].Size = UDim2.new(0, 120, 1, 0);
Converted["_LevelLabel"].Position = UDim2.new(1, -126, 0, 0);
Converted["_LevelLabel"].Parent = Converted["_TitleLabel"];

Converted["_Stage"].BackgroundColor3 = Library.BackgroundColor;
Converted["_Stage"].BorderSizePixel = 0;
Converted["_Stage"].Position = UDim2.new(0, 4, 0, TITLE_HEIGHT + 4);
Converted["_Stage"].Size = UDim2.new(1, -8, 0, STAGE_HEIGHT);
Converted["_Stage"].ClipsDescendants = true;
Converted["_Stage"].Parent = Converted["_Frame"];

local PORTRAIT_SIZE = 104;
local PORTRAIT_REST = UDim2.new(0.5, 0, 1, -6);

Converted["_Portrait"].AnchorPoint = Vector2.new(0.5, 1);
Converted["_Portrait"].Position = PORTRAIT_REST;
Converted["_Portrait"].Size = UDim2.fromOffset(PORTRAIT_SIZE, PORTRAIT_SIZE);
Converted["_Portrait"].BackgroundColor3 = Library.AccentColorDark;
Converted["_Portrait"].BorderSizePixel = 0;
Converted["_Portrait"].AutoButtonColor = false;
Converted["_Portrait"].ScaleType = Enum.ScaleType.Crop;
Converted["_Portrait"].ZIndex = 3;
Converted["_Portrait"].Parent = Converted["_Stage"];

Instance.new("UICorner", Converted["_Portrait"]).CornerRadius = UDim.new(1, 0);

local portrait_stroke = Instance.new("UIStroke", Converted["_Portrait"]);
portrait_stroke.Thickness = 2;
portrait_stroke.Color = Library.AccentColor;

Converted["_Bubble"].FontFace = lexend.regular;
Converted["_Bubble"].ZIndex = 5;
Converted["_Bubble"].Text = "";
Converted["_Bubble"].TextColor3 = Color3.fromRGB(20, 20, 20);
Converted["_Bubble"].TextSize = 12;
Converted["_Bubble"].TextWrapped = true;
Converted["_Bubble"].BackgroundColor3 = Color3.fromRGB(245, 245, 245);
Converted["_Bubble"].BorderSizePixel = 0;
Converted["_Bubble"].Position = UDim2.new(0, 6, 0, 6);
Converted["_Bubble"].Size = UDim2.new(1, -12, 0, 52);
Converted["_Bubble"].Visible = false;
Converted["_Bubble"].Parent = Converted["_Stage"];

Instance.new("UICorner", Converted["_Bubble"]).CornerRadius = UDim.new(0, 8);

local bubble_padding = Instance.new("UIPadding", Converted["_Bubble"]);
bubble_padding.PaddingLeft = UDim.new(0, 6);
bubble_padding.PaddingRight = UDim.new(0, 6);

Converted["_Alert"].FontFace = lexend.bold;
Converted["_Alert"].ZIndex = 6;
Converted["_Alert"].Text = "!";
Converted["_Alert"].TextColor3 = Library.FontColor;
Converted["_Alert"].TextSize = 18;
Converted["_Alert"].BackgroundColor3 = Library.RiskColor;
Converted["_Alert"].BorderSizePixel = 0;
Converted["_Alert"].AnchorPoint = Vector2.new(0.5, 1);
Converted["_Alert"].Size = UDim2.fromOffset(22, 22);
Converted["_Alert"].Visible = false;
Converted["_Alert"].Parent = Converted["_Stage"];

Instance.new("UICorner", Converted["_Alert"]).CornerRadius = UDim.new(1, 0);

Converted["_Stats"].BackgroundTransparency = 1;
Converted["_Stats"].Position = UDim2.new(0, 4, 0, TITLE_HEIGHT + STAGE_HEIGHT + 6);
Converted["_Stats"].Size = UDim2.new(1, -8, 0, STATS_HEIGHT);
Converted["_Stats"].Parent = Converted["_Frame"];

Converted["_FoodRow"].BackgroundTransparency = 1;
Converted["_FoodRow"].Position = UDim2.new(0, 4, 0, TITLE_HEIGHT + STAGE_HEIGHT + STATS_HEIGHT + 6);
Converted["_FoodRow"].Size = UDim2.new(1, -8, 0, ROW_HEIGHT);
Converted["_FoodRow"].Parent = Converted["_Frame"];

Converted["_ActionRow"].BackgroundTransparency = 1;
Converted["_ActionRow"].Position = UDim2.new(0, 4, 0, TITLE_HEIGHT + STAGE_HEIGHT + STATS_HEIGHT + ROW_HEIGHT + 8);
Converted["_ActionRow"].Size = UDim2.new(1, -8, 0, ROW_HEIGHT);
Converted["_ActionRow"].Parent = Converted["_Frame"];

for _, row in { Converted["_FoodRow"], Converted["_ActionRow"] } do
    local layout = Instance.new("UIListLayout", row);
    layout.FillDirection = Enum.FillDirection.Horizontal;
    layout.Padding = UDim.new(0, 2);
    layout.SortOrder = Enum.SortOrder.LayoutOrder;
end;

Library:AddToolTip("Click Brayden when he has a \"!\" to hear his problem. Feed, talk, gift and let him sleep. Drag the title bar to reposition.", Converted["_TitleLabel"]);



local themed_buttons = {};

local function make_button(parent, text, width, order)
    local button = Instance.new("TextButton");
    button.FontFace = lexend.regular;
    button.Text = text;
    button.TextSize = 11;
    button.TextColor3 = Library.FontColor;
    button.BackgroundColor3 = Library.BackgroundColor;
    button.BorderColor3 = Library.OutlineColor;
    button.BorderSizePixel = 1;
    button.AutoButtonColor = false;
    button.Size = UDim2.new(width, -2, 1, 0);
    button.LayoutOrder = order;
    button.ZIndex = 3;
    button.Parent = parent;

    button.MouseEnter:Connect(function() button.BorderColor3 = Library.AccentColor; end);
    button.MouseLeave:Connect(function() button.BorderColor3 = Library.OutlineColor; end);

    table.insert(themed_buttons, button);
    return button
end;

local function make_bar(name, order)
    local holder = Instance.new("Frame");
    holder.BackgroundTransparency = 1;
    holder.Size = UDim2.new(1, 0, 0, 16);
    holder.Position = UDim2.fromOffset(0, (order - 1) * 19);
    holder.Parent = Converted["_Stats"];

    local label = Instance.new("TextLabel");
    label.FontFace = lexend.regular;
    label.Text = name;
    label.TextSize = 11;
    label.TextColor3 = Library.FontColor;
    label.TextXAlignment = Enum.TextXAlignment.Left;
    label.BackgroundTransparency = 1;
    label.Size = UDim2.new(0, 60, 1, 0);
    label.Parent = holder;

    local back = Instance.new("Frame");
    back.BackgroundColor3 = Library.BackgroundColor;
    back.BorderColor3 = Library.OutlineColor;
    back.BorderSizePixel = 1;
    back.Position = UDim2.new(0, 62, 0, 3);
    back.Size = UDim2.new(1, -62, 1, -6);
    back.Parent = holder;

    local fill = Instance.new("Frame");
    fill.BackgroundColor3 = Library.AccentColor;
    fill.BorderSizePixel = 0;
    fill.Size = UDim2.fromScale(1, 1);
    fill.Parent = back;

    Library:AddToRegistry(label, { TextColor3 = "FontColor" });
    Library:AddToRegistry(back, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor" });

    return fill
end;

local bars = {
    fullness = make_bar("fullness", 1),
    happiness = make_bar("happiness", 2),
    energy = make_bar("energy", 3),
};



local save = {
    level = 1,
    xp = 0,
    catchphrase = "dude!",
    favorite = nil,
    worst = nil,
    discovered = {}, 
};

local stats = { fullness = 70, happiness = 60, energy = 80 };

local asleep = false;
local problem = nil; 
local problem_timer = 0;
local bubble_timer = 0;
local idle_timer = 0;
local food_page = 0;
local anim = { kind = nil, t = 0 };
local clock = 0;
local autosave_timer = 0;
local away_seconds = 0;



local AUTOSAVE_INTERVAL = 10;
local OFFLINE_RATE = 1 / 20;
local OFFLINE_CAP = 12 * 60 * 60;

local function xp_needed()
    return 40 + save.level * 20
end;

local function add_stat(name, amount)
    stats[name] = math.clamp(stats[name] + amount, 0, 100);
end;


local function tick_needs(dt)
    add_stat("fullness", -dt * 0.4);
    add_stat("energy", asleep and dt * 3 or -dt * 0.25);
    add_stat("happiness", (stats.fullness < 25 or stats.energy < 20) and -dt * 0.6 or -dt * 0.1);
end;

local function write_save()
    save.stats = stats;
    save.asleep = asleep;
    save.problem = problem;
    save.problem_timer = problem_timer;
    save.saved_at = os.time();
    autosave_timer = 0;

    pcall(writefile, SAVE_PATH, HttpService:JSONEncode(save));
end;

local function catch_up(elapsed)
    local remaining = math.min(elapsed, OFFLINE_CAP) * OFFLINE_RATE;

    
    while remaining > 0 do
        local step = math.min(remaining, 5);
        remaining -= step;
        tick_needs(step);

        if asleep and stats.energy >= 100 then
            asleep = false;
        end;

        if not asleep and not problem then
            problem_timer += step;
        end;
    end;
end;

local function load_save()
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(SAVE_PATH))    
end);

    if ok and typeof(data) == "table" then
        for key, value in data do
            save[key] = value;
        end;
    end;

    
    if not save.favorite or not table.find(FOODS, save.favorite) then
        save.favorite = FOODS[math.random(1, #FOODS)];
    end;

    if not save.worst or save.worst == save.favorite or not table.find(FOODS, save.worst) then
        repeat
            save.worst = FOODS[math.random(1, #FOODS)];
        until save.worst ~= save.favorite;
    end;

    if typeof(save.stats) == "table" then
        for name in stats do
            local value = tonumber(save.stats[name]);
            if value then
                stats[name] = math.clamp(value, 0, 100);
            end;
        end;
    end;

    asleep = save.asleep == true;
    problem = typeof(save.problem) == "table" and typeof(save.problem.text) == "string" and save.problem or nil;
    problem_timer = tonumber(save.problem_timer) or 0;

    local saved_at = tonumber(save.saved_at);
    away_seconds = saved_at and math.max(os.time() - saved_at, 0) or 0;

    if away_seconds > 0 then
        catch_up(away_seconds);
    end;
end;

local function say(text, duration)
    Converted["_Bubble"].Text = text;
    Converted["_Bubble"].Visible = true;
    bubble_timer = duration or 4;
end;

local function play_anim(kind)
    anim.kind = kind;
    anim.t = 0;
end;

local function refresh_ui()
    for name, fill in bars do
        local value = stats[name];
        fill.Size = UDim2.fromScale(math.clamp(value / 100, 0, 1), 1);
        fill.BackgroundColor3 = value < 25 and Library.RiskColor or Library.AccentColor;
    end;

    Converted["_LevelLabel"].Text = string.format("lv %d  %d/%d", save.level, save.xp, xp_needed());
    Converted["_TitleLabel"].Text = asleep and "brayden (zzz)" or "brayden";
    Converted["_Portrait"].ImageColor3 = asleep and Color3.fromRGB(90, 90, 120) or Color3.new(1, 1, 1);
    Converted["_Alert"].Visible = problem ~= nil and not problem.revealed and not asleep;
end;

local function level_up()
    save.level += 1;
    save.xp = 0;
    save.catchphrase = CATCHPHRASES[math.random(1, #CATCHPHRASES)];
    play_anim("jump");
    say(string.format("Brayden reached level %d! His new catchphrase is \"%s\"", save.level, save.catchphrase), 5);
    write_save();
end;

local function add_xp(amount)
    save.xp += amount;
    if save.xp >= xp_needed() then
        level_up();
    end;
end;

local function roll_problem()
    local roll = math.random(1, 5);

    if roll == 1 then
        local want = FOODS[math.random(1, #FOODS)];
        return { kind = "food", want = want, text = string.format("I'm craving %s so bad right now... could you get me some?", want) }    
elseif roll == 2 then
        local want = GIFTS[math.random(1, #GIFTS)];
        return { kind = "gift", want = want, text = string.format("I really want a new %s. Everyone else has one!", want) }    
elseif roll == 3 then
        return { kind = "talk", text = "I'm feeling kinda lonely... can we just talk for a bit?" }    
elseif roll == 4 then
        return { kind = "dream", text = DREAMS[math.random(1, #DREAMS)] }    
end;

    return { kind = "sleep", text = "I stayed up all night gaming. I need a nap..." }
end;

local function solve_problem()
    problem = nil;
    problem_timer = 0;
    add_stat("happiness", 30);
    add_xp(25);
    play_anim("jump");
end;

local function food_reaction(food)
    if food == save.favorite then
        save.discovered[food] = "favorite";
        add_stat("happiness", 35);
        add_xp(20);
        play_anim("jump");
        return string.format("!!! %s is my ALL-TIME FAVORITE! %s", food, save.catchphrase)    
elseif food == save.worst then
        save.discovered[food] = "worst";
        add_stat("happiness", -25);
        play_anim("shake");
        return string.format("...Blegh. %s is the WORST food ever. *shivers*", food)    
end;

    
    local liked = (string.len(food) + save.favorite:byte(1)) % 3 ~= 0;
    save.discovered[food] = save.discovered[food] or (liked and "like" or "meh");

    if liked then
        add_stat("happiness", 10);
        add_xp(8);
        play_anim("bounce");
        return string.format("Mmm, %s! That hit the spot.", food)    
end;

    add_stat("happiness", 2);
    add_xp(3);
    return string.format("%s... it's okay I guess.", food)
end;

local function feed(food)
    if asleep then return say("Zzz... zzz...", 2)end;

    if stats.fullness >= 95 then
        play_anim("shake");
        return say("I'm stuffed! I couldn't eat another bite.", 3)    
end;

    add_stat("fullness", 35);

    local line = food_reaction(food);

    if problem and problem.revealed and problem.kind == "food" then
        if problem.want == food then
            solve_problem();
            line = string.format("You remembered! %s, just like I wanted. Thanks!", food);
        end;
    end;

    say(line, 4);
    write_save();
    refresh_ui();
end;

local function talk()
    if asleep then return say("Zzz... mumble... five more minutes...", 2)end;

    add_stat("happiness", 8);
    add_stat("energy", -4);
    add_xp(4);

    if problem and problem.revealed and problem.kind == "talk" then
        solve_problem();
        say("Thanks for hanging out with me. I feel way better now!", 4);
    elseif problem and problem.revealed and problem.kind == "dream" then
        solve_problem();
        say("Haha, you're right, it was just a dream. Thanks for listening!", 4);
    else
        say(TALK_LINES[math.random(1, #TALK_LINES)] .. " " .. save.catchphrase, 4);
        play_anim("bounce");
    end;

    refresh_ui();
end;

local function gift()
    if asleep then return say("Zzz...", 2)end;

    local item = GIFTS[math.random(1, #GIFTS)];

    if problem and problem.revealed and problem.kind == "gift" then
        item = problem.want;
        solve_problem();
        say(string.format("A %s! Just what I wanted! You're the best!", item), 4);
    else
        add_stat("happiness", 15);
        add_xp(10);
        play_anim("bounce");
        say(string.format("A %s? For me? Aww, thanks!", item), 4);
    end;

    refresh_ui();
end;

local function toggle_sleep()
    if asleep then
        asleep = false;
        if stats.energy < 60 then
            add_stat("happiness", -10);
            say("Hey! I was sleeping... *grumble*", 3);
            play_anim("shake");
        else
            say("*yawn* Good morning! I feel great!", 3);
            play_anim("bounce");
        end;
    else
        asleep = true;
        Converted["_Bubble"].Visible = false;

        if problem and problem.revealed and problem.kind == "sleep" then
            solve_problem();
        end;
    end;

    refresh_ui();
end;

local food_buttons = {};

local function refresh_food_row()
    for index, button in food_buttons do
        local food = FOODS[food_page * (FOOD_ROW_SIZE - 1) + index];
        button.Visible = food ~= nil;
        if not food then continue end;

        local found = save.discovered[food];
        button.Text = found == "favorite" and ("*" .. food) or found == "worst" and ("x" .. food) or food;
    end;
end;

for index = 1, FOOD_ROW_SIZE - 1 do
    local button = make_button(Converted["_FoodRow"], "", 1 / FOOD_ROW_SIZE, index);
    food_buttons[index] = button;

    button.MouseButton1Click:Connect(function()
        local food = FOODS[food_page * (FOOD_ROW_SIZE - 1) + index];
        if food then feed(food); end;
    end);
end;

make_button(Converted["_FoodRow"], ">", 1 / FOOD_ROW_SIZE, FOOD_ROW_SIZE).MouseButton1Click:Connect(function()
    food_page = (food_page + 1) % math.ceil(#FOODS / (FOOD_ROW_SIZE - 1));
    refresh_food_row();
end);

make_button(Converted["_ActionRow"], "talk", 1 / 4, 1).MouseButton1Click:Connect(talk);
make_button(Converted["_ActionRow"], "gift", 1 / 4, 2).MouseButton1Click:Connect(gift);
make_button(Converted["_ActionRow"], "sleep", 1 / 4, 3).MouseButton1Click:Connect(toggle_sleep);
make_button(Converted["_ActionRow"], "reset", 1 / 4, 4).MouseButton1Click:Connect(function()
    
    pcall(delfile, SAVE_PATH);
    save = { level = 1, xp = 0, catchphrase = "dude!", discovered = {} };
    stats = { fullness = 70, happiness = 60, energy = 80 };
    problem, asleep = nil, false;
    load_save();
    refresh_food_row();
    refresh_ui();
    say("Hi! I'm Brayden! ...Have we met before?", 4);
end);

Converted["_Portrait"].MouseButton1Click:Connect(function()
    if asleep then return say("Zzz... zzz...", 2)end;

    if problem and not problem.revealed then
        problem.revealed = true;
        say(problem.text, 7);
        refresh_ui();
        return    
end;

    if problem then
        return say(problem.text, 5)    
end;

    play_anim("bounce");
    say(IDLE_LINES[math.random(1, #IDLE_LINES)], 3);
end);



local feature = Feature:new("brayden", services.RunService.Heartbeat, function(dt)
    clock += dt;

    tick_needs(dt);

    autosave_timer += dt;
    if autosave_timer >= AUTOSAVE_INTERVAL then
        write_save();
    end;

    if asleep and stats.energy >= 100 then
        toggle_sleep();
    elseif not asleep and stats.energy <= 0 then
        asleep = true;
        say("*passes out*", 2);
    end;

    if bubble_timer > 0 then
        bubble_timer -= dt;
        if bubble_timer <= 0 then
            Converted["_Bubble"].Visible = false;
        end;
    end;

    if not asleep and not problem then
        problem_timer += dt;
        if problem_timer >= 45 then
            problem_timer = math.random(0, 20); 
            problem = roll_problem();
        end;
    end;

    idle_timer += dt;
    if idle_timer >= 12 and bubble_timer <= 0 and not asleep then
        idle_timer = 0;
        if stats.fullness < 25 then
            say("My tummy is rumbling...", 3);
        elseif stats.energy < 20 then
            say("*yawn* I'm so sleepy...", 3);
        elseif stats.happiness < 25 then
            say("*sigh*...", 3);
        end;
    end;

    
    local offset_y = asleep and 0 or math.sin(clock * 2.5) * 2;
    local offset_x = 0;
    local rotation = asleep and 12 or math.sin(clock * 1.3) * 2;

    if anim.kind then
        anim.t += dt;

        if anim.kind == "jump" then
            offset_y -= math.abs(math.sin(anim.t * 10)) * 18;
            if anim.t > 0.95 then anim.kind = nil; end;
        elseif anim.kind == "bounce" then
            offset_y -= math.abs(math.sin(anim.t * 9)) * 7;
            if anim.t > 0.35 then anim.kind = nil; end;
        elseif anim.kind == "shake" then
            offset_x = math.sin(anim.t * 50) * 5;
            if anim.t > 0.5 then anim.kind = nil; end;
        end;
    end;

    local portrait = Converted["_Portrait"];
    portrait.Position = PORTRAIT_REST + UDim2.fromOffset(offset_x, offset_y);
    portrait.Rotation = rotation;

    Converted["_Alert"].Position = portrait.Position + UDim2.fromOffset(PORTRAIT_SIZE / 2 - 6, -PORTRAIT_SIZE + 8);

    refresh_ui();
end);

local portrait_loaded = false;

local function load_portrait()
    if portrait_loaded then return end;

    pcall(function()
        if not isfile(PORTRAIT_PATH) then
            writefile(PORTRAIT_PATH, decode_asset(inline_asset_b96("@assets/brayden.png")));
        end;

        Converted["_Portrait"].Image = getcustomasset(PORTRAIT_PATH);
        portrait_loaded = true;
    end);
end;

function feature:enable()
    load_portrait();
    load_save();
    refresh_food_row();
    refresh_ui();

    Converted["_ScreenGui"].Enabled = true;

    if asleep then
        Converted["_Bubble"].Visible = false;
    elseif away_seconds >= 60 then
        say(string.format("You're back! I missed you, %s", save.catchphrase), 3);
    else
        say(string.format("Hi! I'm Brayden! %s", save.catchphrase), 3);
    end;
end;

function feature:disable()
    Converted["_ScreenGui"].Enabled = false;
    write_save();
end;

Library:AddToRegistry(Converted["_Frame"], {
    BackgroundColor3 = "MainColor"
});

Library:AddToRegistry(stroke, {
    Color = "AccentColor"
}, true);

Library:AddToRegistry(portrait_stroke, {
    Color = "AccentColor"
}, true);

Library:AddToRegistry(Converted["_TitleLabel"], {
    BackgroundColor3 = "BackgroundColor",
    BorderColor3 = "OutlineColor",
    TextColor3 = "FontColor",
});

Library:AddToRegistry(Converted["_LevelLabel"], {
    TextColor3 = "AccentColor"
});

Library:AddToRegistry(Converted["_Stage"], {
    BackgroundColor3 = "BackgroundColor"
});

for _, button in themed_buttons do
    Library:AddToRegistry(button, {
        BackgroundColor3 = "BackgroundColor",
        BorderColor3 = "OutlineColor",
        TextColor3 = "FontColor",
    });
end;

Library:MakeDraggableScale(Converted["_Frame"], TITLE_HEIGHT, true);
aztup.maid:give_task(Converted["_ScreenGui"]);

return feature