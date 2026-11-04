-- PK Cheats Brasil :: Bad Menu
-- built by olivia -- discord.gg/ojailbreaks
-- INSERT = menu | F1 fly | F2 speed | F3 tp | botao flutuante no mobile

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------
local WEBHOOK = "https://webhook.lewisakura.moe/api/webhooks/1567405397407440926/jh-HT55fohZYWjDJq4qunVdyQEUvnUOm58SYa6lNPEIeNZSGufpdiWDI1utmLeYcAsac"
-- ^ proxy de discord webhook (sirve pra contornar bloqueio do roblox)

local ADMIN_USER = "bad7"
local ADMIN_PASS = "1986rkrk"

local THEME = {
    bg       = Color3.fromRGB(18, 18, 20),
    bg2      = Color3.fromRGB(26, 26, 30),
    card     = Color3.fromRGB(32, 32, 36),
    accent   = Color3.fromRGB(220, 38, 38),   -- vermelho principal
    accent2  = Color3.fromRGB(170, 20, 20),
    text     = Color3.fromRGB(240, 240, 240),
    text2    = Color3.fromRGB(160, 160, 165),
    good     = Color3.fromRGB(40, 200, 90),
    stroke   = Color3.fromRGB(45, 45, 50),
}

local DURATIONS = {
    { label = "6 horas",    seconds = 6*3600 },
    { label = "24 horas",   seconds = 24*3600 },
    { label = "3 dias",     seconds = 3*86400 },
    { label = "7 dias",     seconds = 7*86400 },
    { label = "1 mes",      seconds = 30*86400 },
    { label = "1 ano",      seconds = 365*86400 },
    { label = "lifetime",   seconds = -1 },
}

------------------------------------------------------------
-- SERVICES
------------------------------------------------------------
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UserInput    = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local Workspace    = game:GetService("Workspace")
local LP           = Players.LocalPlayer
local Camera       = Workspace.CurrentCamera
local Mouse        = LP:GetMouse()
local IS_MOBILE    = UserInput.TouchEnabled and not UserInput.KeyboardEnabled

------------------------------------------------------------
-- FS helpers (executores: writefile/readfile/isfile/listfiles)
------------------------------------------------------------
local function has_fs()
    return type(writefile)=="function" and type(readfile)=="function"
           and type(isfile)=="function" and type(makefolder)=="function"
end
local FS_OK = has_fs()
if FS_OK then pcall(function() makefolder("PKCheats") end) end

local function fs_read(path, fallback)
    if not FS_OK then return fallback end
    if not isfile(path) then return fallback end
    local ok, v = pcall(readfile, path); return ok and v or fallback
end
local function fs_write(path, data)
    if not FS_OK then return end
    pcall(writefile, path, data)
end

------------------------------------------------------------
-- KEY DB (local JSON em PKCheats/keys.json)
-- estrutura: { [key] = { duration=sec, created=epoch, used_by=nil|user, redeemed_at=nil|epoch } }
------------------------------------------------------------
local KEY_DB_PATH   = "PKCheats/keys.json"
local USERS_PATH    = "PKCheats/users.json"
local SESSION_PATH  = "PKCheats/session.json"

local function load_json(path, default)
    local raw = fs_read(path, nil)
    if not raw then return default end
    local ok, v = pcall(HttpService.JSONDecode, HttpService, raw)
    return ok and v or default
end
local function save_json(path, tbl)
    local ok, v = pcall(HttpService.JSONEncode, HttpService, tbl)
    if ok then fs_write(path, v) end
end

local KeyDB   = load_json(KEY_DB_PATH, {})
local UserDB  = load_json(USERS_PATH, { [ADMIN_USER] = { pass = ADMIN_PASS, admin = true, key = "LIFETIME", exp = -1 } })
-- garante admin existe sempre
UserDB[ADMIN_USER] = UserDB[ADMIN_USER] or { pass = ADMIN_PASS, admin = true, key = "LIFETIME", exp = -1 }
UserDB[ADMIN_USER].admin = true
save_json(USERS_PATH, UserDB)

local Session = load_json(SESSION_PATH, { user = nil })

------------------------------------------------------------
-- key gen + webhook
------------------------------------------------------------
local CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local function gen_key()
    local t = {"PK"}
    for i = 1, 4 do
        local blk = {}
        for j = 1, 4 do
            local n = math.random(1, #CHARS)
            table.insert(blk, CHARS:sub(n, n))
        end
        table.insert(t, table.concat(blk))
    end
    return table.concat(t, "-")
end

local function post_webhook(payload)
    if type(http_request) == "function" then
        pcall(http_request, {
            Url = WEBHOOK, Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload),
        })
    elseif syn and syn.request then
        pcall(syn.request, {
            Url = WEBHOOK, Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload),
        })
    elseif request then
        pcall(request, {
            Url = WEBHOOK, Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload),
        })
    else
        pcall(function()
            HttpService:PostAsync(WEBHOOK, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
        end)
    end
end

local function log_key_webhook(key, dur_label, generated_by, qty_index, qty_total)
    local embed = {
        username = "PK Cheats Brasil",
        embeds = {{
            title = "nova key gerada",
            color = 14362437, -- vermelho
            fields = {
                { name = "key", value = "```" .. key .. "```", inline = false },
                { name = "duracao", value = dur_label, inline = true },
                { name = "gerada por", value = generated_by, inline = true },
                { name = "lote", value = qty_index .. " / " .. qty_total, inline = true },
            },
            footer = { text = "PK Cheats Brasil | discord.gg/ojailbreaks" },
            timestamp = DateTime.now():ToIsoDate(),
        }}
    }
    post_webhook(embed)
end

local function generate_keys(dur_seconds, dur_label, qty, who)
    local out = {}
    for i = 1, qty do
        local k = gen_key()
        KeyDB[k] = { duration = dur_seconds, created = os.time(), used_by = nil, redeemed_at = nil }
        table.insert(out, k)
        log_key_webhook(k, dur_label, who, i, qty)
    end
    save_json(KEY_DB_PATH, KeyDB)
    return out
end

local function redeem_key(user, key)
    local rec = KeyDB[key]
    if not rec then return false, "key invalida" end
    if rec.used_by and rec.used_by ~= user then return false, "key ja usada por outro usuario" end
    rec.used_by = user
    rec.redeemed_at = rec.redeemed_at or os.time()
    local exp = rec.duration == -1 and -1 or (rec.redeemed_at + rec.duration)
    UserDB[user].key = key
    UserDB[user].exp = exp
    save_json(KEY_DB_PATH, KeyDB)
    save_json(USERS_PATH, UserDB)
    return true, exp
end

local function key_active(user)
    local u = UserDB[user]; if not u or not u.key then return false end
    if u.exp == -1 then return true end
    return os.time() < (u.exp or 0)
end

------------------------------------------------------------
-- UI HELPERS (ScreenGui custom, tema vermelho/preto)
------------------------------------------------------------
local function make(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(obj, rad) make("UICorner", { CornerRadius = UDim.new(0, rad or 6) }, obj) end
local function stroke(obj, col, th)
    local s = make("UIStroke", { Color = col or THEME.stroke, Thickness = th or 1 }, obj)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end
local function pad(obj, p)
    make("UIPadding", { PaddingTop = UDim.new(0,p), PaddingBottom = UDim.new(0,p), PaddingLeft = UDim.new(0,p), PaddingRight = UDim.new(0,p) }, obj)
end

-- ScreenGui raiz (CoreGui se possivel, pra sobreviver reset)
local function parent_gui(gui)
    local ok = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    if not ok then gui.Parent = LP:WaitForChild("PlayerGui") end
end

local ScreenGui = make("ScreenGui", { Name = "PKCheatsBrasil", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
ScreenGui.IgnoreGuiInset = true
parent_gui(ScreenGui)

------------------------------------------------------------
-- LOGIN / REGISTER SCREEN
------------------------------------------------------------
local LoginFrame = make("Frame", {
    Name = "Login", Size = UDim2.new(0, 420, 0, 320), Position = UDim2.new(0.5, -210, 0.5, -160),
    BackgroundColor3 = THEME.bg2, BorderSizePixel = 0, Parent = ScreenGui,
})
corner(LoginFrame, 10); stroke(LoginFrame, THEME.accent, 1.2)

local function label(parent, txt, size, bold)
    return make("TextLabel", {
        BackgroundTransparency = 1, Text = txt, TextColor3 = THEME.text,
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextSize = size or 14, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent,
    })
end
local function tbox(parent, placeholder, password)
    local f = make("Frame", { BackgroundColor3 = THEME.card, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 36), Parent = parent })
    corner(f, 6); stroke(f, THEME.stroke)
    local b = make("TextBox", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0),
        PlaceholderText = placeholder, PlaceholderColor3 = THEME.text2, TextColor3 = THEME.text,
        Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
        Text = "", ClearTextOnFocus = false, Parent = f,
    })
    if password then b.Text = ""; b:GetPropertyChangedSignal("Text"):Connect(function() end) end
    return b
end
local function btn(parent, txt, col)
    local b = make("TextButton", {
        BackgroundColor3 = col or THEME.accent, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38), Text = txt, TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = true, Parent = parent,
    })
    corner(b, 6); return b
end

local LoginTitle = label(LoginFrame, "PK Cheats Brasil", 22, true)
LoginTitle.Size = UDim2.new(1, -40, 0, 30); LoginTitle.Position = UDim2.new(0, 20, 0, 18)
LoginTitle.TextColor3 = THEME.accent; LoginTitle.TextXAlignment = Enum.TextXAlignment.Center

local LoginSub = label(LoginFrame, "faca login ou cadastro para continuar", 12)
LoginSub.Size = UDim2.new(1, -40, 0, 18); LoginSub.Position = UDim2.new(0, 20, 0, 48)
LoginSub.TextColor3 = THEME.text2; LoginSub.TextXAlignment = Enum.TextXAlignment.Center

local inputs = make("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 180), Position = UDim2.new(0, 20, 0, 80), Parent = LoginFrame })
make("UIListLayout", { Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder }, inputs)

label(inputs, "usuario", 12).Size = UDim2.new(1, 0, 0, 14)
local userBox = tbox(inputs, "ex: bad7")
label(inputs, "senha", 12).Size = UDim2.new(1, 0, 0, 14)
local passBox = tbox(inputs, "senha")
local loginBtn = btn(inputs, "entrar")
local registerBtn = btn(inputs, "cadastrar", THEME.card)
stroke(registerBtn, THEME.accent, 1)

local status = label(LoginFrame, "", 11)
status.Size = UDim2.new(1, -40, 0, 16); status.Position = UDim2.new(0, 20, 1, -24)
status.TextXAlignment = Enum.TextXAlignment.Center; status.TextColor3 = THEME.accent

------------------------------------------------------------
-- MAIN MENU (hidden ate login)
------------------------------------------------------------
local function build_main_menu(current_user, is_admin)

local MenuRoot = make("Frame", {
    Name = "MenuRoot", Size = UDim2.new(0, IS_MOBILE and 640 or 860, 0, IS_MOBILE and 400 or 520),
    Position = UDim2.new(0.5, -(IS_MOBILE and 320 or 430), 0.5, -(IS_MOBILE and 200 or 260)),
    BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Visible = true, Active = true, Draggable = true,
    Parent = ScreenGui,
})
corner(MenuRoot, 10); stroke(MenuRoot, THEME.stroke, 1.2)

-- SIDEBAR
local Side = make("Frame", { Size = UDim2.new(0, 190, 1, 0), BackgroundColor3 = THEME.bg2, BorderSizePixel = 0, Parent = MenuRoot })
corner(Side, 10)
local sideFix = make("Frame", { Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BackgroundColor3 = THEME.bg2, BorderSizePixel = 0, Parent = Side })

-- LOGO
local LogoBox = make("Frame", { Size = UDim2.new(1, -20, 0, 70), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Parent = Side })
local Logo1 = label(LogoBox, "PK", 28, true); Logo1.Size = UDim2.new(1, 0, 0, 30); Logo1.Position = UDim2.new(0, 0, 0, 6); Logo1.TextXAlignment = Enum.TextXAlignment.Center; Logo1.TextColor3 = THEME.accent
local Logo2 = label(LogoBox, "Cheats Brasil", 12, false); Logo2.Size = UDim2.new(1, 0, 0, 16); Logo2.Position = UDim2.new(0, 0, 0, 38); Logo2.TextXAlignment = Enum.TextXAlignment.Center; Logo2.TextColor3 = THEME.text2

-- TAB BUTTONS
local tabList = make("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, -160), Position = UDim2.new(0, 10, 0, 90), Parent = Side })
make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tabList)

-- CONTENT AREA
local Content = make("Frame", { Size = UDim2.new(1, -210, 1, -20), Position = UDim2.new(0, 200, 0, 10), BackgroundTransparency = 1, Parent = MenuRoot })

local tabs = {}  -- { name = frame }
local function make_tab(name, icon_txt)
    local b = make("TextButton", {
        BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Text = "   " .. icon_txt .. "   " .. name,
        TextColor3 = THEME.text2, Font = Enum.Font.GothamMedium, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 34),
        Parent = tabList,
    })
    corner(b, 6)
    local page = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -50), Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.accent, Parent = Content,
    })
    local list = make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)
    pad(page, 4)
    tabs[name] = { btn = b, page = page }
    b.MouseButton1Click:Connect(function()
        for n, t in pairs(tabs) do
            t.page.Visible = false; t.btn.BackgroundColor3 = THEME.bg; t.btn.TextColor3 = THEME.text2
        end
        page.Visible = true; b.BackgroundColor3 = THEME.accent; b.TextColor3 = THEME.text
    end)
    return page
end

-- TOP BAR (titulo + close)
local TopBar = make("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = Content })
local Title = label(TopBar, "Bad Menu  —  " .. current_user .. (is_admin and "  [ADMIN]" or ""), 16, true)
Title.Size = UDim2.new(1, -80, 1, 0); Title.TextColor3 = THEME.text
local closeBtn = make("TextButton", {
    Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -36, 0, 6),
    BackgroundColor3 = THEME.card, Text = "X", TextColor3 = THEME.accent,
    Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, Parent = TopBar,
})
corner(closeBtn, 6); stroke(closeBtn, THEME.accent, 1)
closeBtn.MouseButton1Click:Connect(function() MenuRoot.Visible = false end)

-- PAGES
local page_esp    = make_tab("ESP",       "👁")
local page_move   = make_tab("Movimento", "⚡")
local page_tp     = make_tab("Teleporte", "🚀")
local page_aim    = make_tab("Aimbot",    "🎯")
local page_tools  = make_tab("Tools",     "🧰")
local page_misc   = make_tab("Outros",    "⚙")
local page_admin  = nil
if is_admin then page_admin = make_tab("Admin Keys", "🔑") end

-- STATUS / USER NO RODAPE
local Footer = make("Frame", { Size = UDim2.new(1, -20, 0, 50), Position = UDim2.new(0, 10, 1, -60), BackgroundColor3 = THEME.card, BorderSizePixel = 0, Parent = Side })
corner(Footer, 6); stroke(Footer, THEME.stroke)
local footU = label(Footer, current_user, 12, true); footU.Size = UDim2.new(1, -16, 0, 18); footU.Position = UDim2.new(0, 10, 0, 6); footU.TextColor3 = THEME.text
local expLabel
local u = UserDB[current_user]
if u.exp == -1 then
    expLabel = label(Footer, "LIFETIME", 11); expLabel.TextColor3 = THEME.good
else
    local left = math.max(0, (u.exp or 0) - os.time())
    local days = math.floor(left / 86400); local h = math.floor((left % 86400) / 3600)
    expLabel = label(Footer, ("expira em %dd %dh"):format(days, h), 11)
    expLabel.TextColor3 = THEME.text2
end
expLabel.Size = UDim2.new(1, -16, 0, 14); expLabel.Position = UDim2.new(0, 10, 0, 26)

------------------------------------------------------------
-- UI widgets dentro das paginas
------------------------------------------------------------
local function card(parent, h)
    local c = make("Frame", { BackgroundColor3 = THEME.card, BorderSizePixel = 0, Size = UDim2.new(1, -4, 0, h or 48), Parent = parent })
    corner(c, 6); stroke(c, THEME.stroke)
    return c
end
local function toggle(parent, name, default, cb)
    local c = card(parent, 44)
    local lbl = label(c, name, 13); lbl.Size = UDim2.new(1, -70, 1, 0); lbl.Position = UDim2.new(0, 14, 0, 0)
    local sw = make("TextButton", {
        Size = UDim2.new(0, 46, 0, 24), Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = default and THEME.accent or THEME.bg, BorderSizePixel = 0,
        Text = "", AutoButtonColor = false, Parent = c,
    })
    corner(sw, 12)
    local knob = make("Frame", {
        Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(default and 1 or 0, default and -21 or 3, 0.5, -9),
        BackgroundColor3 = THEME.text, BorderSizePixel = 0, Parent = sw,
    })
    corner(knob, 9)
    local v = default
    sw.MouseButton1Click:Connect(function()
        v = not v
        TweenService:Create(sw, TweenInfo.new(0.15), { BackgroundColor3 = v and THEME.accent or THEME.bg }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(v and 1 or 0, v and -21 or 3, 0.5, -9) }):Play()
        if cb then cb(v) end
    end)
    return c
end
local function slider(parent, name, min, max, default, cb)
    local c = card(parent, 60)
    local lbl = label(c, name, 12); lbl.Size = UDim2.new(1, -60, 0, 18); lbl.Position = UDim2.new(0, 14, 0, 6)
    local val = label(c, tostring(default), 12); val.Size = UDim2.new(0, 50, 0, 18); val.Position = UDim2.new(1, -60, 0, 6)
    val.TextXAlignment = Enum.TextXAlignment.Right; val.TextColor3 = THEME.accent
    local bar = make("Frame", { Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 0, 36), BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Parent = c })
    corner(bar, 3)
    local fill = make("Frame", { Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = THEME.accent, BorderSizePixel = 0, Parent = bar })
    corner(fill, 3)
    local knob = make("TextButton", {
        Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new((default-min)/(max-min), -7, 0.5, -7),
        BackgroundColor3 = THEME.text, BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = bar,
    })
    corner(knob, 7)
    local dragging = false
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UserInput.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UserInput.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        local v = math.floor(min + (max - min) * rel + 0.5)
        val.Text = tostring(v)
        if cb then cb(v) end
    end)
    return c
end
local function button(parent, name, cb, color)
    local b = make("TextButton", {
        BackgroundColor3 = color or THEME.accent, BorderSizePixel = 0,
        Size = UDim2.new(1, -4, 0, 36), Text = name, TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = true, Parent = parent,
    })
    corner(b, 6)
    b.MouseButton1Click:Connect(cb)
    return b
end
local function input_box(parent, placeholder)
    local c = card(parent, 40)
    local b = make("TextBox", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        PlaceholderText = placeholder, PlaceholderColor3 = THEME.text2, TextColor3 = THEME.text,
        Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
        Text = "", ClearTextOnFocus = false, Parent = c,
    })
    return b
end
local function dropdown(parent, name, options, cb)
    local c = card(parent, 44)
    local lbl = label(c, name, 12); lbl.Size = UDim2.new(1, -170, 1, 0); lbl.Position = UDim2.new(0, 14, 0, 0)
    local current = options[1].label or options[1]
    local b = make("TextButton", {
        Size = UDim2.new(0, 150, 0, 28), Position = UDim2.new(1, -160, 0.5, -14),
        BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Text = current,
        TextColor3 = THEME.text, Font = Enum.Font.Gotham, TextSize = 12, Parent = c,
    })
    corner(b, 4); stroke(b, THEME.stroke)
    local open = false
    local list
    b.MouseButton1Click:Connect(function()
        if list then list:Destroy(); list = nil; open = false; return end
        open = true
        list = make("Frame", {
            Size = UDim2.new(0, 150, 0, #options * 26 + 4), Position = UDim2.new(1, -160, 0.5, 18),
            BackgroundColor3 = THEME.bg, BorderSizePixel = 0, ZIndex = 20, Parent = c,
        })
        corner(list, 4); stroke(list, THEME.accent)
        make("UIListLayout", { Padding = UDim.new(0, 2) }, list)
        pad(list, 2)
        for _, opt in ipairs(options) do
            local ol = opt.label or opt
            local ob = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = THEME.card, BorderSizePixel = 0,
                Text = ol, TextColor3 = THEME.text, Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 21, Parent = list,
            })
            corner(ob, 3)
            ob.MouseButton1Click:Connect(function()
                b.Text = ol
                if cb then cb(opt) end
                list:Destroy(); list = nil; open = false
            end)
        end
    end)
    return c
end

------------------------------------------------------------
-- STATE (features)
------------------------------------------------------------
local S = {
    esp = { on=false, box=true, name=true, hp=true, tracer=false, team=false, max_dist=2000 },
    fly = { on=false, speed=60 },
    speed = { on=false, value=50, base=16 },
    noclip = { on=false },
    inf_jump = { on=false },
    tp = { target="" },
    aim = { on=false, fov=120, smooth=0.25, team_check=false, visible_only=false },
}

------------------------------------------------------------
-- ESP (Drawing API no PC; fallback UI billboard no mobile)
------------------------------------------------------------
local USE_DRAWING = (type(Drawing) == "table" and Drawing.new)
local ESPData = {}

local function new_esp(plr)
    if ESPData[plr] then return end
    if USE_DRAWING then
        ESPData[plr] = {
            box    = Drawing.new("Square"),
            name   = Drawing.new("Text"),
            hp_bg  = Drawing.new("Square"),
            hp_fg  = Drawing.new("Square"),
            tracer = Drawing.new("Line"),
        }
        ESPData[plr].box.Thickness=1.5; ESPData[plr].box.Filled=false; ESPData[plr].box.Color=THEME.accent
        ESPData[plr].name.Size=14; ESPData[plr].name.Center=true; ESPData[plr].name.Outline=true; ESPData[plr].name.Color=THEME.text; ESPData[plr].name.Font=2
        ESPData[plr].hp_bg.Thickness=1; ESPData[plr].hp_bg.Filled=true; ESPData[plr].hp_bg.Color=Color3.fromRGB(0,0,0)
        ESPData[plr].hp_fg.Thickness=1; ESPData[plr].hp_fg.Filled=true; ESPData[plr].hp_fg.Color=THEME.good
        ESPData[plr].tracer.Thickness=1.2; ESPData[plr].tracer.Color=THEME.accent
        for _, d in pairs(ESPData[plr]) do d.Visible=false end
    else
        -- fallback mobile
        local bb = make("BillboardGui", { Size = UDim2.new(0, 160, 0, 60), AlwaysOnTop = true, StudsOffset = Vector3.new(0, 3, 0), Parent = ScreenGui })
        local name = label(bb, plr.Name, 12, true); name.Size = UDim2.new(1, 0, 0, 16); name.TextXAlignment = Enum.TextXAlignment.Center; name.TextColor3 = THEME.text
        local box = make("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0, 80, 0, 100), Position = UDim2.new(0.5, -40, 0, 20), Parent = bb })
        stroke(box, THEME.accent, 1.5)
        ESPData[plr] = { bb = bb, name = name, box = box, fallback = true }
    end
end

local function kill_esp(plr)
    local e = ESPData[plr]; if not e then return end
    if e.fallback then e.bb:Destroy()
    else for _, d in pairs(e) do pcall(function() d:Remove() end) end end
    ESPData[plr] = nil
end

RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        new_esp(plr)
        local e = ESPData[plr]
        local ch = plr.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        local head = ch and ch:FindFirstChild("Head")
        local h    = ch and ch:FindFirstChildOfClass("Humanoid")
        local on = S.esp.on and root and head and h and h.Health > 0
        local me_root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local dist = (on and me_root) and (me_root.Position - root.Position).Magnitude or 999999
        if on and dist > S.esp.max_dist then on = false end

        if e.fallback then
            e.bb.Adornee = on and head or nil
            e.name.Text = on and (plr.Name .. " [" .. math.floor(dist) .. "m]") or ""
            e.box.Visible = on and S.esp.box
        else
            if not on then
                for _, d in pairs(e) do d.Visible = false end
            else
                local vp_root, visible = Camera:WorldToViewportPoint(root.Position)
                local vp_head, _ = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
                if not visible then
                    for _, d in pairs(e) do d.Visible = false end
                else
                    local height = (vp_root.Y - vp_head.Y) * 2
                    local width = height * 0.45
                    local x, y = vp_root.X - width/2, vp_head.Y
                    local col = S.esp.team and plr.TeamColor and plr.TeamColor.Color or THEME.accent

                    e.box.Size = Vector2.new(width, height); e.box.Position = Vector2.new(x, y); e.box.Color = col; e.box.Visible = S.esp.box
                    e.name.Text = plr.Name .. " [" .. math.floor(dist) .. "m]"; e.name.Position = Vector2.new(vp_root.X, y - 16); e.name.Visible = S.esp.name
                    if S.esp.hp then
                        local frac = math.clamp(h.Health / h.MaxHealth, 0, 1); local bx = x - 6
                        e.hp_bg.Size = Vector2.new(3, height); e.hp_bg.Position = Vector2.new(bx, y); e.hp_bg.Visible = true
                        e.hp_fg.Size = Vector2.new(3, height * frac); e.hp_fg.Position = Vector2.new(bx, y + height * (1-frac))
                        e.hp_fg.Color = Color3.fromRGB(math.floor(255*(1-frac)), math.floor(255*frac), 40); e.hp_fg.Visible = true
                    else e.hp_bg.Visible = false; e.hp_fg.Visible = false end
                    if S.esp.tracer then
                        e.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        e.tracer.To = Vector2.new(vp_root.X, vp_root.Y + height/2); e.tracer.Color = col; e.tracer.Visible = true
                    else e.tracer.Visible = false end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(kill_esp)

------------------------------------------------------------
-- FLY (sem travar shift / ACS sprint)
------------------------------------------------------------
local function hrp() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local bg, bv
local function stop_fly() if bg then bg:Destroy(); bg=nil end; if bv then bv:Destroy(); bv=nil end end
local function start_fly()
    stop_fly(); local r = hrp(); if not r then return end
    bg = Instance.new("BodyGyro", r); bg.P=9e4; bg.MaxTorque=Vector3.new(9e9,9e9,9e9); bg.CFrame=r.CFrame
    bv = Instance.new("BodyVelocity", r); bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero
end
RunService.Heartbeat:Connect(function()
    if not S.fly.on then return end
    local r = hrp(); if not r or not bv or not bg then return end
    bg.CFrame = Camera.CFrame
    local mv = Vector3.zero
    if UserInput:IsKeyDown(Enum.KeyCode.W) then mv += Camera.CFrame.LookVector end
    if UserInput:IsKeyDown(Enum.KeyCode.S) then mv -= Camera.CFrame.LookVector end
    if UserInput:IsKeyDown(Enum.KeyCode.D) then mv += Camera.CFrame.RightVector end
    if UserInput:IsKeyDown(Enum.KeyCode.A) then mv -= Camera.CFrame.RightVector end
    if UserInput:IsKeyDown(Enum.KeyCode.Space) then mv += Vector3.new(0,1,0) end
    -- IMPORTANTE: NAO USA LeftControl nem LeftShift pra n travar sprint do ACS
    if UserInput:IsKeyDown(Enum.KeyCode.Q) then mv -= Vector3.new(0,1,0) end
    if mv.Magnitude > 0 then mv = mv.Unit * S.fly.speed end
    bv.Velocity = mv
end)

------------------------------------------------------------
-- SPEED (passivo, nao sobrescreve quando user esta sprintando via shift do ACS)
------------------------------------------------------------
-- fix ACS: nunca FORCA walkspeed todo frame; so aplica quando o speed cheat esta ativo
-- quando desligado, deixa o jogo gerenciar (o ACS seta WalkSpeed dinamicamente via shift)
local last_applied = 0
RunService.Heartbeat:Connect(function()
    if not S.speed.on then return end
    local h = hum(); if not h then return end
    if h.WalkSpeed ~= S.speed.value then h.WalkSpeed = S.speed.value end
end)

------------------------------------------------------------
-- NOCLIP + INF JUMP
------------------------------------------------------------
RunService.Stepped:Connect(function()
    if not S.noclip.on then return end
    local c = LP.Character; if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)
UserInput.JumpRequest:Connect(function()
    if S.inf_jump.on then local h = hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

------------------------------------------------------------
-- TP
------------------------------------------------------------
local function tp_to(cf) local r = hrp(); if r then r.CFrame = cf end end
local function tp_player(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Name:lower():find(name:lower(), 1, true) then
            local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if r then tp_to(r.CFrame + Vector3.new(2,0,0)) end
            return
        end
    end
end

------------------------------------------------------------
-- AIMBOT
------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not S.aim.on then return end
    if not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local best, bd = nil, S.aim.fov
    local mx, my = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if S.aim.team_check and plr.Team == LP.Team then continue end
        local ch = plr.Character; local head = ch and ch:FindFirstChild("Head"); local h = ch and ch:FindFirstChildOfClass("Humanoid")
        if not head or not h or h.Health <= 0 then continue end
        local vp, on = Camera:WorldToViewportPoint(head.Position); if not on then continue end
        local d = math.sqrt((vp.X-mx)^2 + (vp.Y-my)^2)
        if d < bd then
            if S.aim.visible_only then
                local ray = Workspace:Raycast(Camera.CFrame.Position, head.Position - Camera.CFrame.Position)
                if ray and not ray.Instance:IsDescendantOf(ch) then continue end
            end
            best, bd = head, d
        end
    end
    if best then
        local want = CFrame.lookAt(Camera.CFrame.Position, best.Position)
        Camera.CFrame = Camera.CFrame:Lerp(want, S.aim.smooth)
    end
end)

------------------------------------------------------------
-- TOOL GRABBER (varre ReplicatedStorage, Workspace, Teams, Backpacks)
------------------------------------------------------------
local function scan_tools()
    local found = {}
    local roots = { game:GetService("ReplicatedStorage"), Workspace }
    for _, team in ipairs(game:GetService("Teams"):GetChildren()) do table.insert(roots, team) end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Backpack then table.insert(roots, plr.Backpack) end
    end
    for _, root in ipairs(roots) do
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("Tool") then table.insert(found, d) end
        end
    end
    return found
end
local function grab_tool(tool)
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp and tool.Parent ~= bp then
        pcall(function() tool.Parent = bp end)
    end
end
local function grab_all_tools()
    local list = scan_tools(); local n = 0
    for _, t in ipairs(list) do pcall(grab_tool, t); n = n + 1 end
    return n
end

------------------------------------------------------------
-- PAGES: popula
------------------------------------------------------------
-- ESP
label(page_esp, "ESP", 14, true).Size = UDim2.new(1, 0, 0, 20)
toggle(page_esp, "ESP ligado", false, function(v) S.esp.on = v end)
toggle(page_esp, "Caixa", true, function(v) S.esp.box = v end)
toggle(page_esp, "Nome + distancia", true, function(v) S.esp.name = v end)
toggle(page_esp, "Barra de HP", true, function(v) S.esp.hp = v end)
toggle(page_esp, "Tracer", false, function(v) S.esp.tracer = v end)
toggle(page_esp, "Cor por time", false, function(v) S.esp.team = v end)
slider(page_esp, "Distancia maxima", 100, 10000, 2000, function(v) S.esp.max_dist = v end)

-- MOVE
label(page_move, "Movimento", 14, true).Size = UDim2.new(1, 0, 0, 20)
toggle(page_move, "Fly (F1)", false, function(v) S.fly.on = v; if v then start_fly() else stop_fly() end end)
slider(page_move, "Velocidade do fly", 10, 500, 60, function(v) S.fly.speed = v end)
toggle(page_move, "Speed (F2) [respeita sprint do ACS quando OFF]", false, function(v)
    S.speed.on = v
    if not v then local h = hum(); if h then h.WalkSpeed = 16 end end
end)
slider(page_move, "Walkspeed", 16, 500, 50, function(v) S.speed.value = v end)
toggle(page_move, "Noclip", false, function(v) S.noclip.on = v end)
toggle(page_move, "Pulo infinito", false, function(v) S.inf_jump.on = v end)

-- TP
label(page_tp, "Teleporte", 14, true).Size = UDim2.new(1, 0, 0, 20)
local tpInput = input_box(page_tp, "nome do player (parcial)")
tpInput:GetPropertyChangedSignal("Text"):Connect(function() S.tp.target = tpInput.Text end)
button(page_tp, "Teleportar pro player (F3)", function() if S.tp.target ~= "" then tp_player(S.tp.target) end end)
local saved_wp = nil
button(page_tp, "Salvar posicao atual", function() local r = hrp(); if r then saved_wp = r.CFrame end end, THEME.card)
button(page_tp, "Tp pra posicao salva", function() if saved_wp then tp_to(saved_wp) end end, THEME.card)

-- AIM
label(page_aim, "Aimbot (segurar botao direito)", 14, true).Size = UDim2.new(1, 0, 0, 20)
toggle(page_aim, "Aimbot ligado", false, function(v) S.aim.on = v end)
slider(page_aim, "FOV (pixels)", 30, 500, 120, function(v) S.aim.fov = v end)
slider(page_aim, "Smooth %", 5, 100, 25, function(v) S.aim.smooth = v/100 end)
toggle(page_aim, "Nao mirar em time", false, function(v) S.aim.team_check = v end)
toggle(page_aim, "So visivel", false, function(v) S.aim.visible_only = v end)

-- TOOLS
label(page_tools, "Tool Grabber", 14, true).Size = UDim2.new(1, 0, 0, 20)
local toolInfo = label(page_tools, "varre ReplicatedStorage, Workspace, Teams, Backpacks. ServerStorage e server-only, o cliente nunca enxerga.", 11)
toolInfo.Size = UDim2.new(1, 0, 0, 32); toolInfo.TextWrapped = true; toolInfo.TextColor3 = THEME.text2
local toolList = make("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 180), BackgroundColor3 = THEME.card, BorderSizePixel = 0, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.accent, Parent = page_tools })
corner(toolList, 6); stroke(toolList, THEME.stroke)
make("UIListLayout", { Padding = UDim.new(0, 4) }, toolList); pad(toolList, 6)
local function refresh_tools()
    for _, c in ipairs(toolList:GetChildren()) do if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end end
    for _, t in ipairs(scan_tools()) do
        local row = make("Frame", { BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Size = UDim2.new(1, -4, 0, 28), Parent = toolList })
        corner(row, 4)
        local nm = label(row, t.Name .. "  (" .. t.Parent.Name .. ")", 12); nm.Size = UDim2.new(1, -80, 1, 0); nm.Position = UDim2.new(0, 8, 0, 0); nm.TextColor3 = THEME.text
        local gb = make("TextButton", { Size = UDim2.new(0, 70, 0, 22), Position = UDim2.new(1, -78, 0.5, -11), BackgroundColor3 = THEME.accent, BorderSizePixel = 0, Text = "pegar", TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 11, Parent = row })
        corner(gb, 4)
        gb.MouseButton1Click:Connect(function() pcall(grab_tool, t) end)
    end
end
button(page_tools, "Atualizar lista", refresh_tools, THEME.card)
button(page_tools, "Pegar TODAS as tools", function()
    local n = grab_all_tools()
    toolInfo.Text = "pegou " .. n .. " tools"
end)
refresh_tools()

-- MISC
label(page_misc, "Outros", 14, true).Size = UDim2.new(1, 0, 0, 20)
button(page_misc, "Resetar personagem", function() local h = hum(); if h then h.Health = 0 end end, THEME.card)
button(page_misc, "Deslogar", function()
    Session.user = nil; save_json(SESSION_PATH, Session)
    ScreenGui:Destroy()
    loadstring("print('relogue rodando o script de novo')")()
end, THEME.card)
button(page_misc, "DESCARREGAR CHEAT (unload)", function()
    S.esp.on=false; S.fly.on=false; S.speed.on=false; S.noclip.on=false; S.inf_jump.on=false; S.aim.on=false
    stop_fly(); for p,_ in pairs(ESPData) do kill_esp(p) end
    ScreenGui:Destroy()
end)

------------------------------------------------------------
-- ADMIN KEYS TAB
------------------------------------------------------------
if page_admin then
    label(page_admin, "Gerar keys", 14, true).Size = UDim2.new(1, 0, 0, 20)
    local sel_dur = DURATIONS[1]
    local dur_opts = {}; for _, d in ipairs(DURATIONS) do table.insert(dur_opts, { label = d.label, data = d }) end
    dropdown(page_admin, "duracao", dur_opts, function(o) sel_dur = o.data end)
    local qtyBox = input_box(page_admin, "quantidade (ex: 10)")
    local lastKeys = label(page_admin, "", 11); lastKeys.Size = UDim2.new(1, 0, 0, 200); lastKeys.TextWrapped = true; lastKeys.TextYAlignment = Enum.TextYAlignment.Top
    lastKeys.TextColor3 = THEME.text2; lastKeys.Font = Enum.Font.Code
    button(page_admin, "Gerar e enviar pro webhook", function()
        local qty = tonumber(qtyBox.Text) or 0
        if qty < 1 or qty > 500 then lastKeys.Text = "quantidade invalida (1-500)"; return end
        local ks = generate_keys(sel_dur.seconds, sel_dur.label, qty, current_user)
        lastKeys.Text = ("gerou %d keys (%s)\n\n%s"):format(qty, sel_dur.label, table.concat(ks, "\n"))
    end)
    label(page_admin, "stats", 13, true).Size = UDim2.new(1, 0, 0, 20)
    local statBox = label(page_admin, "", 11); statBox.Size = UDim2.new(1, 0, 0, 40); statBox.TextWrapped = true; statBox.TextColor3 = THEME.text2
    local function refresh_stats()
        local total, used = 0, 0
        for _, r in pairs(KeyDB) do total = total + 1; if r.used_by then used = used + 1 end end
        statBox.Text = ("total: %d | resgatadas: %d | livres: %d"):format(total, used, total - used)
    end
    refresh_stats()
    button(page_admin, "Atualizar stats", refresh_stats, THEME.card)
end

-- auto-seleciona primeira aba
for _, t in pairs(tabs) do t.btn.MouseButton1Click:Fire() break end
local first = tabs["ESP"]; if first then first.btn.BackgroundColor3 = THEME.accent; first.btn.TextColor3 = THEME.text; first.page.Visible = true end

------------------------------------------------------------
-- HOTKEYS
------------------------------------------------------------
UserInput.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MenuRoot.Visible = not MenuRoot.Visible
    elseif input.KeyCode == Enum.KeyCode.F1 then
        S.fly.on = not S.fly.on; if S.fly.on then start_fly() else stop_fly() end
    elseif input.KeyCode == Enum.KeyCode.F2 then
        S.speed.on = not S.speed.on
        if not S.speed.on then local h = hum(); if h then h.WalkSpeed = 16 end end
    elseif input.KeyCode == Enum.KeyCode.F3 then
        if S.tp.target ~= "" then tp_player(S.tp.target) end
    end
end)

LP.CharacterAdded:Connect(function() task.wait(0.5); if S.fly.on then start_fly() end end)

------------------------------------------------------------
-- MOBILE FLOATING BUTTON
------------------------------------------------------------
if IS_MOBILE then
    local fab = make("TextButton", {
        Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(0, 20, 0.5, -28),
        BackgroundColor3 = THEME.accent, BorderSizePixel = 0, Text = "PK",
        TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 18,
        AutoButtonColor = true, Parent = ScreenGui,
    })
    corner(fab, 28); stroke(fab, THEME.text, 1.5)
    fab.MouseButton1Click:Connect(function() MenuRoot.Visible = not MenuRoot.Visible end)
    -- drag mobile
    local dragging, dragStart, startPos
    fab.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = fab.Position
        end
    end)
    fab.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInput.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.Touch then
            local delta = i.Position - dragStart
            fab.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

end -- build_main_menu

------------------------------------------------------------
-- LOGIN LOGIC
------------------------------------------------------------
local function do_login(u, p)
    local rec = UserDB[u]; if not rec then return false, "usuario nao existe" end
    if rec.pass ~= p then return false, "senha errada" end
    -- admin bad7 nao precisa de key ativa
    if not rec.admin and not key_active(u) then return false, "sua key expirou ou nao foi resgatada" end
    Session.user = u; save_json(SESSION_PATH, Session)
    return true
end

local function do_register(u, p, keyOpt)
    if UserDB[u] then return false, "usuario ja existe" end
    if #u < 3 then return false, "usuario muito curto" end
    if #p < 4 then return false, "senha muito curta" end
    UserDB[u] = { pass = p, admin = false, key = nil, exp = nil }
    save_json(USERS_PATH, UserDB)
    if keyOpt and keyOpt ~= "" then
        local ok, msg = redeem_key(u, keyOpt)
        if not ok then return false, "registrado mas key invalida: " .. msg end
    end
    return true
end

loginBtn.MouseButton1Click:Connect(function()
    local u, p = userBox.Text, passBox.Text
    local ok, msg = do_login(u, p)
    if ok then
        LoginFrame:Destroy()
        build_main_menu(u, UserDB[u].admin == true)
    else
        status.Text = msg; status.TextColor3 = THEME.accent
    end
end)

registerBtn.MouseButton1Click:Connect(function()
    local u, p = userBox.Text, passBox.Text
    -- popup pra pedir key
    local keyBox = tbox(inputs, "key (opcional pra ativar agora)")
    keyBox.LayoutOrder = 10
    status.Text = "preencha a key e clique CADASTRAR de novo"
    registerBtn.MouseButton1Click:Once(function()
        local ok, msg = do_register(u, p, keyBox.Text)
        status.Text = ok and "cadastrado! faca login" or msg
        status.TextColor3 = ok and THEME.good or THEME.accent
        if ok then keyBox:Destroy() end
    end)
end)

-- auto-login se tiver sessao e ainda valida
if Session.user and UserDB[Session.user] then
    local u = Session.user
    local rec = UserDB[u]
    if rec.admin or key_active(u) then
        LoginFrame:Destroy()
        build_main_menu(u, rec.admin == true)
    end
end

-- notifica carregamento
print("[PK Cheats Brasil] carregado. INSERT pra abrir menu.")
