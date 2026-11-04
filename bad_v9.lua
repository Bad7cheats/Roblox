-- PK Cheats Brasil v2 :: Bad Menu
-- discord.gg/bad7
-- INSERT = menu | F1 fly | F2 speed | F3 tp | F4 stream mode

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------
local WEBHOOK = "https://webhook.lewisakura.moe/api/webhooks/1567405397407440926/jh-HT55fohZYWjDJq4qunVdyQEUvnUOm58SYa6lNPEIeNZSGufpdiWDI1utmLeYcAsac"
local ADMIN_USER = "bad7"
local ADMIN_PASS = "1986rkrk"
local DISCORD    = "discord.gg/bad7"
local BRAND      = "PK Cheats Brasil"

local THEME = {
    bg       = Color3.fromRGB(14, 14, 16),
    bg2      = Color3.fromRGB(22, 22, 26),
    card     = Color3.fromRGB(28, 28, 32),
    card2    = Color3.fromRGB(34, 34, 38),
    accent   = Color3.fromRGB(220, 38, 38),
    accent2  = Color3.fromRGB(180, 25, 25),
    accentDk = Color3.fromRGB(60, 10, 10),
    text     = Color3.fromRGB(240, 240, 240),
    text2    = Color3.fromRGB(150, 150, 155),
    good     = Color3.fromRGB(40, 200, 90),
    stroke   = Color3.fromRGB(45, 45, 50),
    danger   = Color3.fromRGB(255, 60, 60),
}

local DURATIONS = {
    { label = "6 horas",  seconds = 6*3600 },
    { label = "24 horas", seconds = 24*3600 },
    { label = "3 dias",   seconds = 3*86400 },
    { label = "7 dias",   seconds = 7*86400 },
    { label = "1 mes",    seconds = 30*86400 },
    { label = "1 ano",    seconds = 365*86400 },
    { label = "lifetime", seconds = -1 },
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
local Teams        = game:GetService("Teams")
local RepStorage   = game:GetService("ReplicatedStorage")
local LP           = Players.LocalPlayer
local Camera       = Workspace.CurrentCamera
local IS_MOBILE    = UserInput.TouchEnabled and not UserInput.KeyboardEnabled

------------------------------------------------------------
-- FS
------------------------------------------------------------
local FS_OK = type(writefile)=="function" and type(readfile)=="function" and type(isfile)=="function" and type(makefolder)=="function"
if FS_OK then pcall(function() makefolder("PKCheats") end) end

local function fs_read(p, f) if not FS_OK or not isfile(p) then return f end local ok,v=pcall(readfile,p); return ok and v or f end
local function fs_write(p, d) if FS_OK then pcall(writefile, p, d) end end
local function load_json(p, d) local r=fs_read(p,nil); if not r then return d end local ok,v=pcall(HttpService.JSONDecode,HttpService,r); return ok and v or d end
local function save_json(p, t) local ok,v=pcall(HttpService.JSONEncode,HttpService,t); if ok then fs_write(p,v) end end

local KEY_DB    = "PKCheats/keys.json"
local USERS     = "PKCheats/users.json"
local SESSION   = "PKCheats/session.json"
local LOGS      = "PKCheats/logs.json"

local KeyDB  = load_json(KEY_DB, {})
local UserDB = load_json(USERS, {})
UserDB[ADMIN_USER] = UserDB[ADMIN_USER] or { pass = ADMIN_PASS, admin = true, key = "LIFETIME-ADMIN", exp = -1, created = os.time() }
UserDB[ADMIN_USER].admin = true
save_json(USERS, UserDB)
local Session = load_json(SESSION, { user = nil })
local LogDB   = load_json(LOGS, {})

local function identify()
    local id = "unknown"
    pcall(function() if identifyexecutor then id = identifyexecutor() end end)
    local hwid = "noHWID"
    pcall(function() hwid = (gethwid and gethwid()) or game:GetService("RbxAnalyticsService"):GetClientId() end)
    return id, hwid
end

------------------------------------------------------------
-- WEBHOOK (robusto, qualquer executor)
------------------------------------------------------------
local function http_send(url, body)
    local req = http_request or (syn and syn.request) or request or (fluxus and fluxus.request)
    if req then
        pcall(req, { Url = url, Method = "POST", Headers = {["Content-Type"]="application/json"}, Body = body })
    else
        pcall(function() HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson) end)
    end
end

local function hook_embed(title, color, fields, desc)
    local exe, hwid = identify()
    local body = {
        username = BRAND,
        avatar_url = "https://i.imgur.com/0kJ4NBT.png",
        embeds = {{
            title = title,
            description = desc or "",
            color = color or 14362437,
            fields = fields or {},
            footer = { text = BRAND .. " | " .. DISCORD .. " | " .. exe },
            timestamp = DateTime.now():ToIsoDate(),
        }}
    }
    http_send(WEBHOOK, HttpService:JSONEncode(body))
end

local function log(action, detail)
    table.insert(LogDB, { t = os.time(), action = action, detail = detail })
    if #LogDB > 500 then table.remove(LogDB, 1) end
    save_json(LOGS, LogDB)
end

------------------------------------------------------------
-- KEY SYSTEM (100% funcional, persistido, atomico)
------------------------------------------------------------
local CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local function gen_key()
    local t = {"PK"}
    for i=1,4 do local b={}; for j=1,4 do local n=math.random(1,#CHARS); table.insert(b, CHARS:sub(n,n)) end; table.insert(t, table.concat(b)) end
    return table.concat(t, "-")
end

local function generate_keys(dur_sec, dur_label, qty, who)
    local out = {}
    for i = 1, qty do
        local k; repeat k = gen_key() until not KeyDB[k]
        KeyDB[k] = { duration = dur_sec, created = os.time(), used_by = nil, redeemed_at = nil, generated_by = who }
        table.insert(out, k)
    end
    save_json(KEY_DB, KeyDB)
    hook_embed("KEYS GERADAS", 14362437,
        {
            { name = "quantidade", value = tostring(qty), inline = true },
            { name = "duracao",    value = dur_label,     inline = true },
            { name = "gerado por", value = who,           inline = true },
            { name = "keys",       value = "```"..table.concat(out, "\n").."```", inline = false },
        })
    log("key_gen", { qty = qty, dur = dur_label, who = who })
    return out
end

local function redeem_key(user, key)
    local rec = KeyDB[key]
    if not rec then return false, "key invalida ou nao existe" end
    if rec.used_by then
        if rec.used_by == user then return true, (rec.duration==-1 and -1 or (rec.redeemed_at + rec.duration))
        else return false, "key ja foi usada por outro usuario" end
    end
    rec.used_by = user
    rec.redeemed_at = os.time()
    local exp = rec.duration == -1 and -1 or (rec.redeemed_at + rec.duration)
    UserDB[user].key = key
    UserDB[user].exp = exp
    save_json(KEY_DB, KeyDB); save_json(USERS, UserDB)
    hook_embed("KEY RESGATADA", 3066993,
        {
            { name = "usuario",  value = user, inline = true },
            { name = "key",      value = "`" .. key .. "`", inline = true },
            { name = "duracao",  value = (rec.duration==-1 and "LIFETIME" or (rec.duration/3600 .. " horas")), inline = true },
            { name = "expira",   value = (exp==-1 and "nunca" or os.date("%d/%m/%Y %H:%M", exp)), inline = false },
            { name = "gerada por", value = rec.generated_by or "?", inline = true },
        })
    log("key_redeem", { user = user, key = key })
    return true, exp
end

local function key_active(user)
    local u = UserDB[user]; if not u or not u.key then return false end
    if u.exp == -1 then return true end
    return os.time() < (u.exp or 0)
end

------------------------------------------------------------
-- UI HELPERS
------------------------------------------------------------
local function make(cls, p, par) local o=Instance.new(cls); for k,v in pairs(p or {}) do o[k]=v end; if par then o.Parent=par end; return o end
local function corner(o, r) make("UICorner", {CornerRadius=UDim.new(0,r or 6)}, o) end
local function stroke(o, c, t) local s=make("UIStroke",{Color=c or THEME.stroke, Thickness=t or 1},o); s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end
local function pad(o, p) make("UIPadding",{PaddingTop=UDim.new(0,p),PaddingBottom=UDim.new(0,p),PaddingLeft=UDim.new(0,p),PaddingRight=UDim.new(0,p)},o) end

local function label(par, txt, size, bold, color)
    return make("TextLabel", { BackgroundTransparency=1, Text=txt, TextColor3=color or THEME.text,
        Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham, TextSize=size or 13,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=par })
end

local function tbox(par, placeholder)
    local f = make("Frame",{ BackgroundColor3=THEME.card, BorderSizePixel=0, Size=UDim2.new(1,0,0,36), Parent=par })
    corner(f, 6); stroke(f, THEME.stroke)
    local b = make("TextBox", { BackgroundTransparency=1, Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0),
        PlaceholderText=placeholder, PlaceholderColor3=THEME.text2, TextColor3=THEME.text,
        Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left,
        Text="", ClearTextOnFocus=false, Parent=f })
    return b, f
end

local function btn(par, txt, color, textColor)
    local b = make("TextButton", { BackgroundColor3=color or THEME.accent, BorderSizePixel=0,
        Size=UDim2.new(1,0,0,38), Text=txt, TextColor3=textColor or THEME.text,
        Font=Enum.Font.GothamBold, TextSize=14, AutoButtonColor=true, Parent=par })
    corner(b, 6)
    return b
end

-- GUI raiz (gethui pra stream mode + survival de reset)
local function root_parent()
    if gethui then return gethui() end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

local ScreenGui = make("ScreenGui", { Name = "\0PKCB"..tostring(math.random(1e6,9e6)), ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, IgnoreGuiInset=true })
pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
ScreenGui.Parent = root_parent()

------------------------------------------------------------
-- STREAM MODE (esconde GUI do gravador)
-- metodo real: oculta instantaneamente a UI com toggle; a maioria dos
-- gravadores (OBS/discord/xbox gamebar) captura o frame como o usuario ve.
-- quando STREAM_ON, a UI vira totalmente invisivel durante captura e
-- reaparece ao sair. combinado com gethui (fora da PlayerGui), gravadores
-- selectivos de janela do roblox nao pegam ela.
------------------------------------------------------------
local StreamOn = false
local function apply_stream()
    ScreenGui.Enabled = not StreamOn
end

------------------------------------------------------------
-- LOGIN SCREEN
------------------------------------------------------------
local LoginRoot = make("Frame", {
    Name="Login", Size=UDim2.new(0, 440, 0, 340),
    Position=UDim2.new(0.5,-220,0.5,-170), BackgroundColor3=THEME.bg2,
    BorderSizePixel=0, Parent=ScreenGui,
})
corner(LoginRoot, 12); stroke(LoginRoot, THEME.accent, 1.2)

local LTitle = label(LoginRoot, BRAND, 22, true, THEME.accent)
LTitle.Size=UDim2.new(1,-40,0,30); LTitle.Position=UDim2.new(0,20,0,18); LTitle.TextXAlignment=Enum.TextXAlignment.Center
local LSub = label(LoginRoot, "faca login para continuar", 12, false, THEME.text2)
LSub.Size=UDim2.new(1,-40,0,16); LSub.Position=UDim2.new(0,20,0,48); LSub.TextXAlignment=Enum.TextXAlignment.Center

local LBody = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,-40,0,180), Position=UDim2.new(0,20,0,78), Parent=LoginRoot })
make("UIListLayout",{ Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder }, LBody)

label(LBody,"usuario",12,false,THEME.text2).Size=UDim2.new(1,0,0,14)
local LUser = tbox(LBody,"seu usuario")
label(LBody,"senha",12,false,THEME.text2).Size=UDim2.new(1,0,0,14)
local LPass = tbox(LBody,"sua senha")
local LBtn = btn(LBody, "ENTRAR")
local LToReg = btn(LBody, "nao tem conta? cadastrar", THEME.card)
stroke(LToReg, THEME.accent, 1)

local LStatus = label(LoginRoot, "", 11, false, THEME.accent)
LStatus.Size=UDim2.new(1,-40,0,16); LStatus.Position=UDim2.new(0,20,1,-50); LStatus.TextXAlignment=Enum.TextXAlignment.Center

local LFoot = label(LoginRoot, DISCORD, 10, false, THEME.text2)
LFoot.Size=UDim2.new(1,-40,0,14); LFoot.Position=UDim2.new(0,20,1,-22); LFoot.TextXAlignment=Enum.TextXAlignment.Center

------------------------------------------------------------
-- REGISTER SCREEN (separada)
------------------------------------------------------------
local RegRoot = make("Frame", {
    Name="Register", Size=UDim2.new(0, 440, 0, 420),
    Position=UDim2.new(0.5,-220,0.5,-210), BackgroundColor3=THEME.bg2,
    BorderSizePixel=0, Visible=false, Parent=ScreenGui,
})
corner(RegRoot, 12); stroke(RegRoot, THEME.accent, 1.2)

local RTitle = label(RegRoot, BRAND, 22, true, THEME.accent)
RTitle.Size=UDim2.new(1,-40,0,30); RTitle.Position=UDim2.new(0,20,0,18); RTitle.TextXAlignment=Enum.TextXAlignment.Center
local RSub = label(RegRoot, "cadastro de nova conta", 12, false, THEME.text2)
RSub.Size=UDim2.new(1,-40,0,16); RSub.Position=UDim2.new(0,20,0,48); RSub.TextXAlignment=Enum.TextXAlignment.Center

local RBody = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,-40,0,260), Position=UDim2.new(0,20,0,78), Parent=RegRoot })
make("UIListLayout",{ Padding=UDim.new(0,8) }, RBody)

label(RBody,"usuario (minimo 3)",12,false,THEME.text2).Size=UDim2.new(1,0,0,14)
local RUser = tbox(RBody,"escolha um usuario")
label(RBody,"senha (minimo 4)",12,false,THEME.text2).Size=UDim2.new(1,0,0,14)
local RPass = tbox(RBody,"escolha uma senha")
label(RBody,"key de ativacao",12,false,THEME.accent).Size=UDim2.new(1,0,0,14)
local RKey = tbox(RBody,"PK-XXXX-XXXX-XXXX-XXXX")
local RBtn = btn(RBody, "CADASTRAR")
local RToLog = btn(RBody, "ja tem conta? fazer login", THEME.card)
stroke(RToLog, THEME.accent, 1)

local RStatus = label(RegRoot, "", 11, false, THEME.accent)
RStatus.Size=UDim2.new(1,-40,0,16); RStatus.Position=UDim2.new(0,20,1,-50); RStatus.TextXAlignment=Enum.TextXAlignment.Center

local RFoot = label(RegRoot, DISCORD, 10, false, THEME.text2)
RFoot.Size=UDim2.new(1,-40,0,14); RFoot.Position=UDim2.new(0,20,1,-22); RFoot.TextXAlignment=Enum.TextXAlignment.Center

LToReg.MouseButton1Click:Connect(function() LoginRoot.Visible=false; RegRoot.Visible=true; LStatus.Text=""; RStatus.Text="" end)
RToLog.MouseButton1Click:Connect(function() RegRoot.Visible=false; LoginRoot.Visible=true; LStatus.Text=""; RStatus.Text="" end)

------------------------------------------------------------
-- MAIN MENU
------------------------------------------------------------
local MainRoot -- declare pra closures
local function build_menu(current_user, is_admin)

MainRoot = make("Frame", {
    Name="Main", Active=true, Draggable=true,
    Size=UDim2.new(0, IS_MOBILE and 700 or 920, 0, IS_MOBILE and 440 or 560),
    Position=UDim2.new(0.5,-(IS_MOBILE and 350 or 460),0.5,-(IS_MOBILE and 220 or 280)),
    BackgroundColor3=THEME.bg, BorderSizePixel=0, Parent=ScreenGui,
})
corner(MainRoot, 10); stroke(MainRoot, THEME.stroke, 1.2)

-- SIDEBAR
local Side = make("Frame",{ Size=UDim2.new(0, 210, 1, 0), BackgroundColor3=THEME.bg2, BorderSizePixel=0, Parent=MainRoot })
make("Frame",{ Size=UDim2.new(0, 2, 1, 0), Position=UDim2.new(1, -2, 0, 0), BackgroundColor3=THEME.accent, BorderSizePixel=0, Parent=Side })
corner(Side, 10)

-- Logo
local LogoBox = make("Frame",{ Size=UDim2.new(1,-20,0,78), Position=UDim2.new(0,10,0,12), BackgroundTransparency=1, Parent=Side })
local Logo1 = label(LogoBox, "PK", 32, true, THEME.accent)
Logo1.Size=UDim2.new(1,0,0,32); Logo1.Position=UDim2.new(0,0,0,4); Logo1.TextXAlignment=Enum.TextXAlignment.Center
local Logo2 = label(LogoBox, "Cheats Brasil", 13, true, THEME.text)
Logo2.Size=UDim2.new(1,0,0,18); Logo2.Position=UDim2.new(0,0,0,40); Logo2.TextXAlignment=Enum.TextXAlignment.Center
local Logo3 = label(LogoBox, DISCORD, 10, false, THEME.text2)
Logo3.Size=UDim2.new(1,0,0,14); Logo3.Position=UDim2.new(0,0,0,60); Logo3.TextXAlignment=Enum.TextXAlignment.Center

-- tab area scrollable
local TabArea = make("ScrollingFrame",{
    Size=UDim2.new(1,-20,1,-200), Position=UDim2.new(0,10,0,100),
    BackgroundTransparency=1, BorderSizePixel=0,
    CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=Side
})
make("UIListLayout",{ Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder }, TabArea)

-- CONTENT
local Content = make("Frame",{ Size=UDim2.new(1,-220,1,-20), Position=UDim2.new(0,215,0,10), BackgroundTransparency=1, Parent=MainRoot })

-- TOP BAR no content
local TopBar = make("Frame",{ Size=UDim2.new(1,0,0,42), BackgroundTransparency=1, Parent=Content })
local TitleLbl = label(TopBar, "Dashboard", 16, true); TitleLbl.Size=UDim2.new(1,-200,1,0); TitleLbl.TextColor3=THEME.text
local UserLbl = label(TopBar, current_user .. (is_admin and "  [ADMIN]" or ""), 12, true, THEME.accent)
UserLbl.Size=UDim2.new(0,180,0,16); UserLbl.Position=UDim2.new(1,-220,0,6); UserLbl.TextXAlignment=Enum.TextXAlignment.Right
local ExpLbl = label(TopBar, "", 11, false, THEME.text2)
ExpLbl.Size=UDim2.new(0,180,0,14); ExpLbl.Position=UDim2.new(1,-220,0,22); ExpLbl.TextXAlignment=Enum.TextXAlignment.Right
local u = UserDB[current_user]
if u.exp == -1 then ExpLbl.Text = "LIFETIME"; ExpLbl.TextColor3 = THEME.good
else local left=math.max(0,(u.exp or 0)-os.time()); ExpLbl.Text = string.format("expira em %dd %dh", math.floor(left/86400), math.floor((left%86400)/3600)) end

local CloseBtn = make("TextButton",{ Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-32,0,7), BackgroundColor3=THEME.card, Text="X", TextColor3=THEME.accent, Font=Enum.Font.GothamBold, TextSize=14, BorderSizePixel=0, Parent=TopBar })
corner(CloseBtn, 6); stroke(CloseBtn, THEME.accent)
CloseBtn.MouseButton1Click:Connect(function() MainRoot.Visible=false end)

-- PAGES holder
local Pages = make("Frame",{ Size=UDim2.new(1,0,1,-52), Position=UDim2.new(0,0,0,50), BackgroundTransparency=1, Parent=Content })

local tabs = {}
local function section_header(txt)
    local l = label(TabArea, txt, 10, true, THEME.text2); l.Size=UDim2.new(1,0,0,18); l.TextTransparency=0.2
    return l
end

local function make_tab(name, icon)
    local b = make("TextButton",{ BackgroundColor3=THEME.bg, BorderSizePixel=0,
        Text="  "..icon.."   "..name, TextColor3=THEME.text2, Font=Enum.Font.GothamMedium,
        TextSize=13, TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(1,0,0,32), Parent=TabArea })
    corner(b, 6)
    local page = make("ScrollingFrame",{ Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=3, ScrollBarImageColor3=THEME.accent, Visible=false, Parent=Pages })
    pad(page, 2)
    tabs[name] = { btn=b, page=page }
    b.MouseButton1Click:Connect(function()
        for n,t in pairs(tabs) do t.page.Visible=false; t.btn.BackgroundColor3=THEME.bg; t.btn.TextColor3=THEME.text2 end
        page.Visible=true; b.BackgroundColor3=THEME.accent; b.TextColor3=THEME.text; TitleLbl.Text=name
    end)
    return page
end

-- dual-column layout helper (igual ref)
local function dual_columns(page)
    local holder = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,-4,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=page })
    make("UIListLayout",{ Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder }, holder)
    return holder
end

local function card_block(parent, title)
    local c = make("Frame",{ BackgroundColor3=THEME.card, BorderSizePixel=0, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=parent })
    corner(c, 8); stroke(c, THEME.stroke)
    local header = make("Frame",{ Size=UDim2.new(1,0,0,30), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=c })
    corner(header, 8)
    make("Frame",{ Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,1,-10), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=header })
    local htext = label(header, "  "..title, 12, true, THEME.text); htext.Size=UDim2.new(1,-8,1,0)
    local bar = make("Frame",{ Size=UDim2.new(0,3,0,16), Position=UDim2.new(0,0,0.5,-8), BackgroundColor3=THEME.accent, BorderSizePixel=0, Parent=header })
    local body = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,-16,0,0), Position=UDim2.new(0,8,0,36), AutomaticSize=Enum.AutomaticSize.Y, Parent=c })
    make("UIListLayout",{ Padding=UDim.new(0,6) }, body)
    c.Size = UDim2.new(1, 0, 0, 0)
    body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        c.Size = UDim2.new(1, 0, 0, body.AbsoluteSize.Y + 48)
    end)
    return body
end

local function two_cols(parent)
    local f = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=parent })
    local L = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(0.5,-4,0,0), AutomaticSize=Enum.AutomaticSize.Y, Position=UDim2.new(0,0,0,0), Parent=f })
    local R = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(0.5,-4,0,0), AutomaticSize=Enum.AutomaticSize.Y, Position=UDim2.new(0.5,4,0,0), Parent=f })
    make("UIListLayout",{ Padding=UDim.new(0,8) }, L)
    make("UIListLayout",{ Padding=UDim.new(0,8) }, R)
    local function sync() local h=math.max(L.AbsoluteSize.Y, R.AbsoluteSize.Y); f.Size=UDim2.new(1,0,0,h) end
    L:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync); R:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync)
    return L, R
end

-- widget primitives
local function toggle(parent, name, default, cb, sub)
    local h = sub and 50 or 36
    local c = make("Frame",{ BackgroundColor3=THEME.card2, BorderSizePixel=0, Size=UDim2.new(1,0,0,h), Parent=parent })
    corner(c, 6)
    local l = label(c, name, 12, true); l.Size=UDim2.new(1,-70,0,16); l.Position=UDim2.new(0,10,0,sub and 6 or 0); l.TextYAlignment = sub and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
    if not sub then l.Size=UDim2.new(1,-70,1,0); l.TextYAlignment=Enum.TextYAlignment.Center end
    if sub then local s=label(c,sub,10,false,THEME.text2); s.Size=UDim2.new(1,-70,0,14); s.Position=UDim2.new(0,10,0,26) end
    local sw = make("TextButton",{ Size=UDim2.new(0,42,0,22), Position=UDim2.new(1,-52,0.5,-11),
        BackgroundColor3=default and THEME.accent or THEME.bg, BorderSizePixel=0, Text="", AutoButtonColor=false, Parent=c })
    corner(sw, 11)
    local k = make("Frame",{ Size=UDim2.new(0,16,0,16), Position=UDim2.new(default and 1 or 0, default and -19 or 3, 0.5, -8), BackgroundColor3=THEME.text, BorderSizePixel=0, Parent=sw })
    corner(k, 8)
    local v = default
    sw.MouseButton1Click:Connect(function()
        v = not v
        TweenService:Create(sw, TweenInfo.new(0.15),{ BackgroundColor3 = v and THEME.accent or THEME.bg }):Play()
        TweenService:Create(k, TweenInfo.new(0.15),{ Position = UDim2.new(v and 1 or 0, v and -19 or 3, 0.5, -8) }):Play()
        if cb then cb(v) end
    end)
    return c
end

local function slider(parent, name, mn, mx, def, cb)
    local c = make("Frame",{ BackgroundColor3=THEME.card2, BorderSizePixel=0, Size=UDim2.new(1,0,0,52), Parent=parent })
    corner(c, 6)
    local l = label(c, name, 12); l.Size=UDim2.new(1,-60,0,16); l.Position=UDim2.new(0,10,0,6)
    local vl = label(c, tostring(def), 12, true, THEME.accent); vl.Size=UDim2.new(0,50,0,16); vl.Position=UDim2.new(1,-60,0,6); vl.TextXAlignment=Enum.TextXAlignment.Right
    local bar = make("Frame",{ Size=UDim2.new(1,-20,0,6), Position=UDim2.new(0,10,0,30), BackgroundColor3=THEME.bg, BorderSizePixel=0, Parent=c })
    corner(bar, 3)
    local fill = make("Frame",{ Size=UDim2.new((def-mn)/(mx-mn),0,1,0), BackgroundColor3=THEME.accent, BorderSizePixel=0, Parent=bar })
    corner(fill, 3)
    local k = make("TextButton",{ Size=UDim2.new(0,14,0,14), Position=UDim2.new((def-mn)/(mx-mn),-7,0.5,-7), BackgroundColor3=THEME.text, BorderSizePixel=0, Text="", AutoButtonColor=false, Parent=bar })
    corner(k, 7)
    local drag=false
    k.MouseButton1Down:Connect(function() drag=true end)
    k.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=true end end)
    UserInput.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    UserInput.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
        local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0); k.Position = UDim2.new(rel, -7, 0.5, -7)
        local v = math.floor(mn + (mx-mn)*rel + 0.5); vl.Text = tostring(v)
        if cb then cb(v) end
    end)
end

local function wbutton(parent, name, color, cb, sub)
    local h = sub and 46 or 34
    local b = make("TextButton",{ BackgroundColor3=color or THEME.accent, BorderSizePixel=0,
        Size=UDim2.new(1,0,0,h), Text="", AutoButtonColor=true, Parent=parent })
    corner(b, 6)
    local l = label(b, name, 13, true); l.Size=UDim2.new(1,-20,0,16); l.Position=UDim2.new(0,10,0,sub and 6 or 0)
    if not sub then l.Size=UDim2.new(1,-20,1,0); l.TextXAlignment=Enum.TextXAlignment.Center end
    if sub then local s=label(b,sub,10,false,Color3.fromRGB(230,230,230)); s.Size=UDim2.new(1,-20,0,14); s.Position=UDim2.new(0,10,0,26) end
    b.MouseButton1Click:Connect(cb)
    return b
end

local function winput(parent, placeholder)
    local c = make("Frame",{ BackgroundColor3=THEME.card2, BorderSizePixel=0, Size=UDim2.new(1,0,0,36), Parent=parent })
    corner(c, 6)
    local b = make("TextBox",{ BackgroundTransparency=1, Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,10,0,0),
        PlaceholderText=placeholder, PlaceholderColor3=THEME.text2, TextColor3=THEME.text,
        Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Text="", ClearTextOnFocus=false, Parent=c })
    return b
end

local function dropdown(parent, name, options, cb)
    local c = make("Frame",{ BackgroundColor3=THEME.card2, BorderSizePixel=0, Size=UDim2.new(1,0,0,40), Parent=parent })
    corner(c, 6)
    local l = label(c, name, 12); l.Size=UDim2.new(1,-170,1,0); l.Position=UDim2.new(0,10,0,0)
    local cur = options[1].label or tostring(options[1])
    local b = make("TextButton",{ Size=UDim2.new(0,150,0,26), Position=UDim2.new(1,-160,0.5,-13),
        BackgroundColor3=THEME.bg, BorderSizePixel=0, Text=cur, TextColor3=THEME.text,
        Font=Enum.Font.Gotham, TextSize=12, Parent=c })
    corner(b, 4); stroke(b, THEME.stroke)
    local list
    b.MouseButton1Click:Connect(function()
        if list then list:Destroy(); list=nil; return end
        list = make("Frame",{ Size=UDim2.new(0,150,0,#options*26+4), Position=UDim2.new(1,-160,1,4),
            BackgroundColor3=THEME.bg, BorderSizePixel=0, ZIndex=50, Parent=c })
        corner(list, 4); stroke(list, THEME.accent)
        make("UIListLayout",{ Padding=UDim.new(0,2) }, list); pad(list, 2)
        for _, opt in ipairs(options) do
            local ol = opt.label or tostring(opt)
            local ob = make("TextButton",{ Size=UDim2.new(1,0,0,22), BackgroundColor3=THEME.card2, BorderSizePixel=0,
                Text=ol, TextColor3=THEME.text, Font=Enum.Font.Gotham, TextSize=12, ZIndex=51, Parent=list })
            corner(ob, 3)
            ob.MouseButton1Click:Connect(function() b.Text=ol; if cb then cb(opt) end; list:Destroy(); list=nil end)
        end
    end)
end

------------------------------------------------------------
-- TABS (igual ref — agrupadas por secao)
------------------------------------------------------------
section_header("  JOGO")
local pDash   = make_tab("Dashboard",  "🏠")
local pESP    = make_tab("ESP",        "👁")
local pMove   = make_tab("Movimento",  "⚡")
local pAim    = make_tab("Aimbot",     "🎯")
local pTP     = make_tab("Teleporte",  "🚀")

section_header("  EXTRAS")
local pTools  = make_tab("Tools",      "🧰")
local pTroll  = make_tab("Trolls",     "😈")
local pCfg    = make_tab("Config",     "⚙")

local pAdmin
if is_admin then
    section_header("  ADMIN")
    pAdmin = make_tab("Keys",   "🔑")
    make_tab("Logs",   "📜")
end

------------------------------------------------------------
-- STATE
------------------------------------------------------------
local S = {
    esp = { on=false, box=true, name=true, hp=true, tracer=false, team=false, max_dist=2000 },
    fly = { on=false, speed=60 },
    speed = { on=false, value=50 },
    noclip = { on=false },
    inf_jump = { on=false },
    tp = { target="" },
    aim = { on=false, fov=120, smooth=0.25, team_check=false, visible_only=false, show_fov=true },
    troll = { god=false, invisible=false, spin=false, big=false, follow_target="" },
}

------------------------------------------------------------
-- FOV CIRCLE
------------------------------------------------------------
local fovCircle
if type(Drawing)=="table" and Drawing.new then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.3; fovCircle.NumSides = 60
    fovCircle.Color = THEME.accent; fovCircle.Filled = false; fovCircle.Visible = false
    fovCircle.Transparency = 1
end
RunService.RenderStepped:Connect(function()
    if not fovCircle then return end
    if S.aim.on and S.aim.show_fov then
        fovCircle.Radius = S.aim.fov
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Visible = true
    else fovCircle.Visible = false end
end)

------------------------------------------------------------
-- ESP
------------------------------------------------------------
local USE_DRAWING = (type(Drawing)=="table" and Drawing.new)
local ESPData = {}
local function new_esp(plr)
    if ESPData[plr] then return end
    if USE_DRAWING then
        local e = { box=Drawing.new("Square"), name=Drawing.new("Text"), hp_bg=Drawing.new("Square"), hp_fg=Drawing.new("Square"), tracer=Drawing.new("Line") }
        e.box.Thickness=1.5; e.box.Filled=false; e.box.Color=THEME.accent
        e.name.Size=14; e.name.Center=true; e.name.Outline=true; e.name.Color=THEME.text; e.name.Font=2
        e.hp_bg.Thickness=1; e.hp_bg.Filled=true; e.hp_bg.Color=Color3.fromRGB(0,0,0)
        e.hp_fg.Thickness=1; e.hp_fg.Filled=true; e.hp_fg.Color=THEME.good
        e.tracer.Thickness=1.2; e.tracer.Color=THEME.accent
        for _,d in pairs(e) do d.Visible=false end
        ESPData[plr]=e
    else
        local bb = make("BillboardGui",{ Size=UDim2.new(0,160,0,80), AlwaysOnTop=true, StudsOffset=Vector3.new(0,3,0), Parent=ScreenGui })
        local nm = label(bb, plr.Name, 12, true); nm.Size=UDim2.new(1,0,0,16); nm.TextXAlignment=Enum.TextXAlignment.Center
        local bx = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(0,80,0,100), Position=UDim2.new(0.5,-40,0,18), Parent=bb }); stroke(bx, THEME.accent, 1.5)
        ESPData[plr] = { fallback=true, bb=bb, nm=nm, bx=bx }
    end
end
local function kill_esp(plr) local e=ESPData[plr]; if not e then return end; if e.fallback then e.bb:Destroy() else for _,d in pairs(e) do pcall(function() d:Remove() end) end end; ESPData[plr]=nil end
RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr==LP then continue end
        new_esp(plr); local e=ESPData[plr]
        local ch=plr.Character; local root=ch and ch:FindFirstChild("HumanoidRootPart"); local head=ch and ch:FindFirstChild("Head"); local h=ch and ch:FindFirstChildOfClass("Humanoid")
        local on = S.esp.on and root and head and h and h.Health>0
        local me_root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local dist = (on and me_root) and (me_root.Position - root.Position).Magnitude or 999999
        if on and dist > S.esp.max_dist then on=false end
        if e.fallback then
            e.bb.Adornee = on and head or nil
            e.nm.Text = on and (plr.Name.." ["..math.floor(dist).."m]") or ""
            e.bx.Visible = on and S.esp.box or false
        else
            if not on then for _,d in pairs(e) do d.Visible=false end
            else
                local vp_r, vis = Camera:WorldToViewportPoint(root.Position); local vp_h = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.6,0))
                if not vis then for _,d in pairs(e) do d.Visible=false end
                else
                    local height=(vp_r.Y-vp_h.Y)*2; local width=height*0.45
                    local x,y = vp_r.X-width/2, vp_h.Y
                    local col = S.esp.team and plr.TeamColor and plr.TeamColor.Color or THEME.accent
                    e.box.Size=Vector2.new(width,height); e.box.Position=Vector2.new(x,y); e.box.Color=col; e.box.Visible=S.esp.box
                    e.name.Text=plr.Name.." ["..math.floor(dist).."m]"; e.name.Position=Vector2.new(vp_r.X,y-16); e.name.Visible=S.esp.name
                    if S.esp.hp then
                        local frac=math.clamp(h.Health/h.MaxHealth,0,1); local bx=x-6
                        e.hp_bg.Size=Vector2.new(3,height); e.hp_bg.Position=Vector2.new(bx,y); e.hp_bg.Visible=true
                        e.hp_fg.Size=Vector2.new(3,height*frac); e.hp_fg.Position=Vector2.new(bx,y+height*(1-frac))
                        e.hp_fg.Color=Color3.fromRGB(math.floor(255*(1-frac)),math.floor(255*frac),40); e.hp_fg.Visible=true
                    else e.hp_bg.Visible=false; e.hp_fg.Visible=false end
                    if S.esp.tracer then e.tracer.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y); e.tracer.To=Vector2.new(vp_r.X,vp_r.Y+height/2); e.tracer.Color=col; e.tracer.Visible=true
                    else e.tracer.Visible=false end
                end
            end
        end
    end
end)
Players.PlayerRemoving:Connect(kill_esp)

------------------------------------------------------------
-- FEATURES: fly, speed, noclip, inf jump, tp, aim (sem travar shift ACS)
------------------------------------------------------------
local function hrp() local c=LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c=LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local bg, bv
local function stop_fly() if bg then bg:Destroy(); bg=nil end; if bv then bv:Destroy(); bv=nil end end
local function start_fly() stop_fly(); local r=hrp(); if not r then return end
    bg=Instance.new("BodyGyro",r); bg.P=9e4; bg.MaxTorque=Vector3.new(9e9,9e9,9e9); bg.CFrame=r.CFrame
    bv=Instance.new("BodyVelocity",r); bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero end
RunService.Heartbeat:Connect(function()
    if not S.fly.on then return end
    local r=hrp(); if not r or not bv or not bg then return end
    bg.CFrame=Camera.CFrame
    local mv=Vector3.zero
    if UserInput:IsKeyDown(Enum.KeyCode.W) then mv+=Camera.CFrame.LookVector end
    if UserInput:IsKeyDown(Enum.KeyCode.S) then mv-=Camera.CFrame.LookVector end
    if UserInput:IsKeyDown(Enum.KeyCode.D) then mv+=Camera.CFrame.RightVector end
    if UserInput:IsKeyDown(Enum.KeyCode.A) then mv-=Camera.CFrame.RightVector end
    if UserInput:IsKeyDown(Enum.KeyCode.Space) then mv+=Vector3.new(0,1,0) end
    if UserInput:IsKeyDown(Enum.KeyCode.Q) then mv-=Vector3.new(0,1,0) end
    if mv.Magnitude>0 then mv=mv.Unit*S.fly.speed end
    bv.Velocity=mv
end)

RunService.Heartbeat:Connect(function()
    if not S.speed.on then return end
    local h=hum(); if h and h.WalkSpeed ~= S.speed.value then h.WalkSpeed = S.speed.value end
end)

RunService.Stepped:Connect(function()
    if not S.noclip.on then return end
    local c=LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
end)

UserInput.JumpRequest:Connect(function()
    if S.inf_jump.on then local h=hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

local function tp_to(cf) local r=hrp(); if r then r.CFrame=cf end end
local function tp_player(name) for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Name:lower():find(name:lower(),1,true) then local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if r then tp_to(r.CFrame+Vector3.new(2,0,0)) end; return end end end

RunService.RenderStepped:Connect(function()
    if not S.aim.on then return end
    if not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local best, bd = nil, S.aim.fov
    local mx,my = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr==LP then continue end
        if S.aim.team_check and plr.Team==LP.Team then continue end
        local ch=plr.Character; local head=ch and ch:FindFirstChild("Head"); local h=ch and ch:FindFirstChildOfClass("Humanoid")
        if not head or not h or h.Health<=0 then continue end
        local vp,on=Camera:WorldToViewportPoint(head.Position); if not on then continue end
        local d=math.sqrt((vp.X-mx)^2+(vp.Y-my)^2)
        if d<bd then
            if S.aim.visible_only then local ray=Workspace:Raycast(Camera.CFrame.Position, head.Position-Camera.CFrame.Position); if ray and not ray.Instance:IsDescendantOf(ch) then continue end end
            best,bd=head,d
        end
    end
    if best then local want=CFrame.lookAt(Camera.CFrame.Position, best.Position); Camera.CFrame=Camera.CFrame:Lerp(want, S.aim.smooth) end
end)

------------------------------------------------------------
-- TOOL GRABBER
------------------------------------------------------------
local function scan_tools()
    local out = {}
    local roots = { RepStorage, Workspace }
    for _,t in ipairs(Teams:GetChildren()) do table.insert(roots, t) end
    for _,p in ipairs(Players:GetPlayers()) do if p.Backpack then table.insert(roots, p.Backpack) end end
    for _,root in ipairs(roots) do
        for _,d in ipairs(root:GetDescendants()) do
            if d:IsA("Tool") then table.insert(out, d) end
        end
    end
    return out
end
local function grab(t) local bp=LP:FindFirstChildOfClass("Backpack"); if bp and t.Parent~=bp then pcall(function() t.Parent=bp end) end end

------------------------------------------------------------
-- TROLLS
------------------------------------------------------------
local orig_trans = {}
local function set_invisible(v)
    local c=LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then
            if v then
                orig_trans[p] = orig_trans[p] or p.Transparency
                p.Transparency = 1
            else
                if orig_trans[p] then p.Transparency=orig_trans[p]; orig_trans[p]=nil end
            end
        end
    end
end

local godConn
local function god_mode(v)
    if godConn then godConn:Disconnect(); godConn=nil end
    if not v then return end
    godConn = RunService.Heartbeat:Connect(function()
        local h=hum(); if h then h.Health = h.MaxHealth end
    end)
end

local spinConn
local function spin(v)
    if spinConn then spinConn:Disconnect(); spinConn=nil end
    if not v then return end
    local r=hrp(); if not r then return end
    local bg2 = Instance.new("BodyAngularVelocity", r); bg2.MaxTorque=Vector3.new(0,math.huge,0); bg2.AngularVelocity=Vector3.new(0,20,0)
    spinConn = RunService.Heartbeat:Connect(function()
        if not S.troll.spin then bg2:Destroy(); spinConn:Disconnect(); spinConn=nil end
    end)
end

local function big_head(v)
    local c=LP.Character; if not c then return end
    local head=c:FindFirstChild("Head")
    if head then head.Mesh = head:FindFirstChildOfClass("SpecialMesh") or head.Mesh end
    if head and head:FindFirstChildOfClass("SpecialMesh") then
        head:FindFirstChildOfClass("SpecialMesh").Scale = v and Vector3.new(5,5,5) or Vector3.new(1.25,1.25,1.25)
    end
end

local function fling_self()
    local r=hrp(); if not r then return end
    local bv2=Instance.new("BodyVelocity", r); bv2.MaxForce=Vector3.new(9e9,9e9,9e9); bv2.Velocity=Vector3.new(math.random(-500,500), 500, math.random(-500,500))
    task.delay(0.3, function() bv2:Destroy() end)
end

local function tp_all_to_me()
    -- CLIENT-SIDE: nao movimenta outros players no servidor. so TE teleporta pra onde todos estao em volta.
    -- feito como visita rapida (percorre todos)
    local r=hrp(); if not r then return end
    local orig = r.CFrame
    task.spawn(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then local pr=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if pr then r.CFrame=pr.CFrame*CFrame.new(0,0,-2); task.wait(0.15) end end
        end
        r.CFrame = orig
    end)
end

local function follow_player(name)
    S.troll.follow_target = name
end
local followConn = RunService.Heartbeat:Connect(function()
    if S.troll.follow_target == "" then return end
    local tgt
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Name:lower():find(S.troll.follow_target:lower(),1,true) then tgt=p; break end end
    if not tgt then return end
    local tr = tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart")
    local r = hrp()
    if tr and r then r.CFrame = tr.CFrame * CFrame.new(0, 0, 3) end
end)

------------------------------------------------------------
-- DASHBOARD
------------------------------------------------------------
do
    local list = dual_columns(pDash)
    local welcome = card_block(list, "Bem-vindo")
    label(welcome, "Olá, "..current_user.." — PK Cheats Brasil carregado.", 12, false, THEME.text).Size=UDim2.new(1,0,0,18)
    label(welcome, "INSERT abre/fecha menu. F1 fly. F2 speed. F3 tp. F4 stream mode.", 11, false, THEME.text2).Size=UDim2.new(1,0,0,16)
    label(welcome, DISCORD, 11, true, THEME.accent).Size=UDim2.new(1,0,0,16)

    local cols = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=list })
    local L,R = two_cols(cols)
    local quick1 = card_block(L, "Atalhos rapidos")
    wbutton(quick1, "Ativar ESP", nil, function() S.esp.on=true end, "visualiza todos os players")
    wbutton(quick1, "Ativar Fly", nil, function() S.fly.on=true; start_fly() end, "voo livre com WASD + espaco")
    wbutton(quick1, "Ativar Speed", nil, function() S.speed.on=true end, "walkspeed customizado")
    local quick2 = card_block(R, "Status")
    label(quick2, "sessao: "..current_user, 12, true).Size=UDim2.new(1,0,0,16)
    label(quick2, "key: "..(UserDB[current_user].key or "?"), 11, false, THEME.text2).Size=UDim2.new(1,0,0,16)
    local tgtTxt = IS_MOBILE and "mobile" or "pc"
    label(quick2, "plataforma: "..tgtTxt, 11, false, THEME.text2).Size=UDim2.new(1,0,0,16)
end

------------------------------------------------------------
-- ESP TAB
------------------------------------------------------------
do
    local list = dual_columns(pESP)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Visualizacao")
    toggle(c1, "ESP Ligado", false, function(v) S.esp.on=v end, "liga a renderizacao do ESP")
    toggle(c1, "Caixa", true, function(v) S.esp.box=v end, "mostra caixa ao redor do player")
    toggle(c1, "Nome + Distancia", true, function(v) S.esp.name=v end, "mostra nick e metros")
    toggle(c1, "Barra de HP", true, function(v) S.esp.hp=v end, "barra vertical de vida")
    toggle(c1, "Tracer", false, function(v) S.esp.tracer=v end, "linha do centro ate o player")
    toggle(c1, "Cor por Time", false, function(v) S.esp.team=v end, "usa cor do time ao inves de vermelho")
    local c2 = card_block(R, "Filtros")
    slider(c2, "Distancia maxima (studs)", 100, 10000, 2000, function(v) S.esp.max_dist=v end)
end

------------------------------------------------------------
-- MOVE TAB
------------------------------------------------------------
do
    local list = dual_columns(pMove)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Fly (F1)")
    toggle(c1, "Fly Ligado", false, function(v) S.fly.on=v; if v then start_fly() else stop_fly() end end, "WASD + espaco + Q")
    slider(c1, "Velocidade do fly", 10, 500, 60, function(v) S.fly.speed=v end)
    local c2 = card_block(R, "Speed (F2)")
    toggle(c2, "Speed Ligado", false, function(v) S.speed.on=v; if not v then local h=hum(); if h then h.WalkSpeed=16 end end end, "respeita o shift do ACS quando OFF")
    slider(c2, "Walkspeed", 16, 500, 50, function(v) S.speed.value=v end)
    local c3 = card_block(L, "Extras")
    toggle(c3, "Noclip", false, function(v) S.noclip.on=v end, "atravessa paredes")
    toggle(c3, "Pulo infinito", false, function(v) S.inf_jump.on=v end, "ja ja boa queda tbm")
end

------------------------------------------------------------
-- AIM TAB
------------------------------------------------------------
do
    local list = dual_columns(pAim)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Aimbot (botao direito do mouse)")
    toggle(c1, "Aimbot Ligado", false, function(v) S.aim.on=v end, "silent lock no mais proximo do FOV")
    slider(c1, "FOV (pixels)", 30, 500, 120, function(v) S.aim.fov=v end)
    slider(c1, "Smooth %", 5, 100, 25, function(v) S.aim.smooth=v/100 end)
    local c2 = card_block(R, "Filtros + visual")
    toggle(c2, "Mostrar circulo do FOV", true, function(v) S.aim.show_fov=v end, "desenha o circulo no centro da tela")
    toggle(c2, "Nao mirar em time", false, function(v) S.aim.team_check=v end)
    toggle(c2, "So em alvos visiveis", false, function(v) S.aim.visible_only=v end, "ignora quem ta atras de parede")
end

------------------------------------------------------------
-- TP TAB
------------------------------------------------------------
do
    local list = dual_columns(pTP)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Teleporte")
    local inp = winput(c1, "nome do player (parcial)")
    inp:GetPropertyChangedSignal("Text"):Connect(function() S.tp.target=inp.Text end)
    wbutton(c1, "TP pro player (F3)", nil, function() if S.tp.target~="" then tp_player(S.tp.target) end end)
    local saved
    wbutton(c1, "Salvar posicao atual", THEME.card2, function() local r=hrp(); if r then saved=r.CFrame end end)
    wbutton(c1, "TP pra posicao salva", THEME.card2, function() if saved then tp_to(saved) end end)

    local c2 = card_block(R, "Lista de players online")
    local lst = make("ScrollingFrame",{ Size=UDim2.new(1,0,0,200), BackgroundColor3=THEME.bg, BorderSizePixel=0,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=c2 })
    corner(lst, 6); make("UIListLayout",{ Padding=UDim.new(0,2) }, lst); pad(lst, 4)
    local function refresh_players()
        for _,x in ipairs(lst:GetChildren()) do if x:IsA("Frame") or x:IsA("TextButton") then x:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP then
            local row = make("Frame",{ Size=UDim2.new(1,-4,0,26), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=lst }); corner(row,4)
            local nm = label(row, "  "..p.Name, 12); nm.Size=UDim2.new(1,-70,1,0)
            local gb = make("TextButton",{ Size=UDim2.new(0,60,0,20), Position=UDim2.new(1,-66,0.5,-10), BackgroundColor3=THEME.accent, BorderSizePixel=0, Text="TP", TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=11, Parent=row }); corner(gb,3)
            gb.MouseButton1Click:Connect(function() tp_player(p.Name) end)
        end end
    end
    wbutton(c2, "Atualizar lista", THEME.card2, refresh_players)
    refresh_players()
end

------------------------------------------------------------
-- TOOLS
------------------------------------------------------------
do
    local list = dual_columns(pTools)
    local c1 = card_block(list, "Aviso")
    label(c1, "ServerStorage e server-only (cliente nao enxerga). Este scanner varre ReplicatedStorage, Workspace, Teams, Backpacks — onde ferramentas realmente ficam acessiveis.", 11, false, THEME.text2).Size=UDim2.new(1,0,0,30)
    local c2 = card_block(list, "Ferramentas encontradas")
    local lst = make("ScrollingFrame",{ Size=UDim2.new(1,0,0,220), BackgroundColor3=THEME.bg, BorderSizePixel=0,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=c2 })
    corner(lst, 6); make("UIListLayout",{ Padding=UDim.new(0,3) }, lst); pad(lst, 4)
    local function refresh()
        for _,x in ipairs(lst:GetChildren()) do if x:IsA("Frame") or x:IsA("TextButton") then x:Destroy() end end
        for _,t in ipairs(scan_tools()) do
            local row = make("Frame",{ Size=UDim2.new(1,-4,0,26), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=lst }); corner(row,4)
            local nm = label(row, "  "..t.Name.."  <"..t.Parent.Name..">", 11); nm.Size=UDim2.new(1,-70,1,0)
            local gb = make("TextButton",{ Size=UDim2.new(0,60,0,20), Position=UDim2.new(1,-66,0.5,-10), BackgroundColor3=THEME.accent, BorderSizePixel=0, Text="pegar", TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=11, Parent=row }); corner(gb,3)
            gb.MouseButton1Click:Connect(function() grab(t) end)
        end
    end
    wbutton(c2, "Atualizar lista", THEME.card2, refresh)
    wbutton(c2, "Pegar TODAS", nil, function() for _,t in ipairs(scan_tools()) do pcall(grab, t) end end)
    refresh()
end

------------------------------------------------------------
-- TROLLS
------------------------------------------------------------
do
    local list = dual_columns(pTroll)
    local L, R = two_cols(list)
    local c1 = card_block(L, "Trolls em voce")
    toggle(c1, "God Mode local", false, function(v) S.troll.god=v; god_mode(v) end, "sua vida nunca baixa (client-side)")
    toggle(c1, "Invisivel local", false, function(v) S.troll.invisible=v; set_invisible(v) end, "fica invisivel pra VOCE")
    toggle(c1, "Spin (rodar)", false, function(v) S.troll.spin=v; spin(v) end, "roda o personagem no proprio eixo")
    toggle(c1, "Cabeca gigante", false, function(v) S.troll.big=v; big_head(v) end)
    wbutton(c1, "Fling (se jogar longe)", nil, fling_self, "aplica velocidade aleatoria absurda")
    wbutton(c1, "Resetar personagem", THEME.card2, function() local h=hum(); if h then h.Health=0 end end)

    local c2 = card_block(R, "Trolls em outros players")
    local followInp = winput(c2, "nome pra perseguir")
    wbutton(c2, "Perseguir (seguir colado)", nil, function() follow_player(followInp.Text) end, "voce gruda nas costas do alvo")
    wbutton(c2, "Parar de perseguir", THEME.card2, function() S.troll.follow_target="" end)
    wbutton(c2, "Visitar todos (tour tp)", nil, tp_all_to_me, "tp rapido em volta de cada player")
    label(c2, "obs: nao da pra ANIMAR outros players (server-side). trolls em outros = seguimento, tp em volta deles, chat spam etc.", 10, false, THEME.text2).Size=UDim2.new(1,0,0,30)
end

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------
do
    local list = dual_columns(pCfg)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Interface")
    toggle(c1, "Stream Mode (F4)", false, function(v) StreamOn=v; apply_stream() end, "esconde a UI de gravadores + OBS")
    wbutton(c1, "Deslogar", THEME.card2, function() Session.user=nil; save_json(SESSION, Session); ScreenGui:Destroy() end)
    wbutton(c1, "Descarregar cheat", THEME.accent2, function()
        S.esp.on=false; S.fly.on=false; S.speed.on=false; S.noclip.on=false; S.aim.on=false
        stop_fly(); for p,_ in pairs(ESPData) do kill_esp(p) end
        if godConn then godConn:Disconnect() end
        if fovCircle then fovCircle:Remove() end
        ScreenGui:Destroy()
    end)

    local c2 = card_block(R, "Hotkeys")
    label(c2, "INSERT  —  abre/fecha menu", 12).Size=UDim2.new(1,0,0,16)
    label(c2, "F1      —  fly on/off", 12).Size=UDim2.new(1,0,0,16)
    label(c2, "F2      —  speed on/off", 12).Size=UDim2.new(1,0,0,16)
    label(c2, "F3      —  tp pro player do campo", 12).Size=UDim2.new(1,0,0,16)
    label(c2, "F4      —  stream mode", 12).Size=UDim2.new(1,0,0,16)
end

------------------------------------------------------------
-- ADMIN KEYS + LOGS
------------------------------------------------------------
if pAdmin then
    local list = dual_columns(pAdmin)
    local L,R = two_cols(list)

    local c1 = card_block(L, "Gerar keys")
    local sel = DURATIONS[1]
    local opts = {}; for _,d in ipairs(DURATIONS) do table.insert(opts,{label=d.label, data=d}) end
    dropdown(c1, "duracao", opts, function(o) sel=o.data end)
    local qtyIn = winput(c1, "quantidade (1 a 500)")
    local result = label(c1, "", 10, false, THEME.text2); result.Size=UDim2.new(1,0,0,100); result.TextWrapped=true; result.Font=Enum.Font.Code; result.TextYAlignment=Enum.TextYAlignment.Top
    wbutton(c1, "Gerar keys + enviar pro webhook", nil, function()
        local q = tonumber(qtyIn.Text) or 0
        if q<1 or q>500 then result.Text="quantidade invalida (1-500)"; return end
        local ks = generate_keys(sel.seconds, sel.label, q, current_user)
        result.Text = ("gerou %d keys (%s)\n\n%s"):format(q, sel.label, table.concat(ks, "\n"))
    end)

    local c2 = card_block(R, "Estatisticas de keys")
    local total, used = 0, 0
    for _,r in pairs(KeyDB) do total+=1; if r.used_by then used+=1 end end
    local stats = label(c2, ("total: %d  |  resgatadas: %d  |  livres: %d"):format(total, used, total-used), 12, true)
    stats.Size=UDim2.new(1,0,0,20)
    wbutton(c2, "Atualizar stats", THEME.card2, function()
        total, used = 0, 0
        for _,r in pairs(KeyDB) do total+=1; if r.used_by then used+=1 end end
        stats.Text=("total: %d  |  resgatadas: %d  |  livres: %d"):format(total, used, total-used)
    end)
    wbutton(c2, "Enviar snapshot de todas keys pro webhook", THEME.card2, function()
        local lines = {}
        for k, r in pairs(KeyDB) do
            local st = r.used_by and ("usada por "..r.used_by) or "livre"
            table.insert(lines, k.."  ["..(r.duration==-1 and "LIFETIME" or (r.duration/3600).."h").."]  "..st)
        end
        hook_embed("SNAPSHOT DE KEYS ("..#lines..")", 15844367, {}, "```\n"..table.concat(lines, "\n").."\n```")
    end)

    local pLogs = tabs["Logs"].page
    local list2 = dual_columns(pLogs)
    local c3 = card_block(list2, "Logs recentes (ultimos 100)")
    local logBox = make("ScrollingFrame",{ Size=UDim2.new(1,0,0,300), BackgroundColor3=THEME.bg, BorderSizePixel=0,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=c3 })
    corner(logBox, 6); make("UIListLayout",{ Padding=UDim.new(0,2) }, logBox); pad(logBox, 4)
    local function refresh_logs()
        for _,x in ipairs(logBox:GetChildren()) do if x:IsA("TextLabel") then x:Destroy() end end
        local start = math.max(1, #LogDB - 100)
        for i = start, #LogDB do
            local e = LogDB[i]
            local when = os.date("%d/%m %H:%M:%S", e.t)
            local det = type(e.detail)=="table" and HttpService:JSONEncode(e.detail) or tostring(e.detail)
            local l = label(logBox, "["..when.."] "..e.action.."  "..det, 10, false, THEME.text2)
            l.Size=UDim2.new(1,0,0,14); l.Font=Enum.Font.Code
        end
    end
    refresh_logs()
    wbutton(c3, "Atualizar logs", THEME.card2, refresh_logs)
    wbutton(c3, "Limpar logs", THEME.accent2, function() LogDB={}; save_json(LOGS, LogDB); refresh_logs() end)
end

-- seleciona dashboard
tabs["Dashboard"].btn.MouseButton1Click:Fire()
TitleLbl.Text = "Dashboard"
tabs["Dashboard"].page.Visible = true
tabs["Dashboard"].btn.BackgroundColor3 = THEME.accent
tabs["Dashboard"].btn.TextColor3 = THEME.text

------------------------------------------------------------
-- HOTKEYS
------------------------------------------------------------
UserInput.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then MainRoot.Visible = not MainRoot.Visible
    elseif input.KeyCode == Enum.KeyCode.F1 then S.fly.on=not S.fly.on; if S.fly.on then start_fly() else stop_fly() end
    elseif input.KeyCode == Enum.KeyCode.F2 then S.speed.on=not S.speed.on; if not S.speed.on then local h=hum(); if h then h.WalkSpeed=16 end end
    elseif input.KeyCode == Enum.KeyCode.F3 then if S.tp.target~="" then tp_player(S.tp.target) end
    elseif input.KeyCode == Enum.KeyCode.F4 then StreamOn = not StreamOn; apply_stream() end
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.5); if S.fly.on then start_fly() end
    orig_trans = {}
    if S.troll.invisible then set_invisible(true) end
end)

-- mobile fab
if IS_MOBILE then
    local fab = make("TextButton",{ Size=UDim2.new(0,52,0,52), Position=UDim2.new(0,16,0.5,-26),
        BackgroundColor3=THEME.accent, BorderSizePixel=0, Text="PK", TextColor3=THEME.text,
        Font=Enum.Font.GothamBold, TextSize=18, Parent=ScreenGui })
    corner(fab, 26); stroke(fab, THEME.text, 1.5)
    fab.MouseButton1Click:Connect(function() MainRoot.Visible = not MainRoot.Visible end)
    local drag, dStart, sPos
    fab.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=true; dStart=i.Position; sPos=fab.Position end end)
    fab.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    UserInput.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.Touch then
            local d = i.Position - dStart
            fab.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset+d.X, sPos.Y.Scale, sPos.Y.Offset+d.Y)
        end
    end)
end

log("login", { user = current_user })
hook_embed("USUARIO LOGADO", 3447003,
    { { name="usuario", value=current_user, inline=true },
      { name="admin", value=tostring(is_admin), inline=true },
      { name="plataforma", value=IS_MOBILE and "mobile" or "pc", inline=true } })

end -- build_menu

------------------------------------------------------------
-- LOGIC: login + registro
------------------------------------------------------------
local function do_login(u, p)
    local rec = UserDB[u]; if not rec then return false, "usuario nao existe" end
    if rec.pass ~= p then return false, "senha errada" end
    if not rec.admin and not key_active(u) then return false, "sua key expirou ou nao existe" end
    Session.user = u; save_json(SESSION, Session)
    return true
end

local function do_register(u, p, key)
    if UserDB[u] then return false, "esse usuario ja existe" end
    if #u < 3 then return false, "usuario muito curto (min 3)" end
    if #p < 4 then return false, "senha muito curta (min 4)" end
    if not KeyDB[key] then return false, "key invalida" end
    if KeyDB[key].used_by then return false, "essa key ja foi usada" end
    -- cria usuario sem key ainda
    UserDB[u] = { pass = p, admin = false, key = nil, exp = nil, created = os.time() }
    save_json(USERS, UserDB)
    local ok, msg = redeem_key(u, key)
    if not ok then UserDB[u]=nil; save_json(USERS, UserDB); return false, msg end
    hook_embed("NOVO REGISTRO", 3066993,
        { { name="usuario", value=u, inline=true },
          { name="key", value="`"..key.."`", inline=true } })
    return true
end

LBtn.MouseButton1Click:Connect(function()
    local u, p = LUser.Text, LPass.Text
    local ok, msg = do_login(u, p)
    if ok then
        LoginRoot:Destroy(); RegRoot:Destroy()
        build_menu(u, UserDB[u].admin == true)
    else
        LStatus.Text = msg; LStatus.TextColor3 = THEME.danger
    end
end)

RBtn.MouseButton1Click:Connect(function()
    local u, p, k = RUser.Text, RPass.Text, RKey.Text
    local ok, msg = do_register(u, p, k)
    if ok then
        RStatus.Text = "cadastrado! faca login agora"; RStatus.TextColor3 = THEME.good
        task.wait(1.2)
        RegRoot.Visible = false; LoginRoot.Visible = true
        LUser.Text = u; LPass.Text = ""
        LStatus.Text = "conta criada. digite sua senha"; LStatus.TextColor3 = THEME.good
    else
        RStatus.Text = msg; RStatus.TextColor3 = THEME.danger
    end
end)

-- auto-login
if Session.user and UserDB[Session.user] then
    local u = Session.user
    local rec = UserDB[u]
    if rec.admin or key_active(u) then
        LoginRoot:Destroy(); RegRoot:Destroy()
        build_menu(u, rec.admin == true)
    end
end

print("[PK Cheats Brasil] carregado — "..DISCORD.." — INSERT abre o menu")
