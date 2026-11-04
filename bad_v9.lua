-- PK Cheats Brasil v3 :: Bad Menu :: built by olivia
-- discord.gg/bad7
-- hotkeys: INSERT = menu | F1 fly | F2 speed | F3 tp | F4 stream | F5 silent aim

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------
local WH_KEYS = "https://webhook.lewisakura.moe/api/webhooks/1567405397407440926/jh-HT55fohZYWjDJq4qunVdyQEUvnUOm58SYa6lNPEIeNZSGufpdiWDI1utmLeYcAsac"
local WH_LOGS = "https://webhook.lewisakura.moe/api/webhooks/1567420040909955122/GwqHbupriadtx8DKZeosFBfOm_KMFshSwpbJbZQ2rq9EYvPUruLjknEgIygeNbi_Vbfz"
local ADMIN_USER = "bad7"
local ADMIN_PASS = "1986rkrk"
local DISCORD    = "discord.gg/bad7"
local BRAND      = "PK Cheats Brasil"

local THEME = {
    bg       = Color3.fromRGB(12, 12, 14),
    bg2      = Color3.fromRGB(20, 20, 24),
    card     = Color3.fromRGB(26, 26, 30),
    card2    = Color3.fromRGB(32, 32, 36),
    accent   = Color3.fromRGB(220, 38, 38),
    accent2  = Color3.fromRGB(170, 20, 20),
    text     = Color3.fromRGB(240, 240, 240),
    text2    = Color3.fromRGB(150, 150, 155),
    good     = Color3.fromRGB(45, 200, 95),
    warn     = Color3.fromRGB(255, 180, 40),
    danger   = Color3.fromRGB(255, 60, 60),
    stroke   = Color3.fromRGB(40, 40, 46),
}

-- icones padrao do roblox (asset do catalogo de icones da propria plataforma)
local ICON = {
    home    = "rbxassetid://7733960981",  -- casa
    eye     = "rbxassetid://7733715400",  -- olho
    bolt    = "rbxassetid://7733658133",  -- raio (movimento)
    target  = "rbxassetid://7734042071",  -- mira
    tp      = "rbxassetid://7733955511",  -- seta/foguete
    gun     = "rbxassetid://7733954964",  -- arma
    skull   = "rbxassetid://7743870375",  -- caveira (trolls)
    shield  = "rbxassetid://7733909095",  -- escudo (bypass)
    gear    = "rbxassetid://7733964719",  -- engrenagem
    key     = "rbxassetid://7743878235",  -- chave
    doc     = "rbxassetid://7733996732",  -- documento (logs)
    bomb    = "rbxassetid://7743869054",  -- bomba (admin leak)
    close   = "rbxassetid://7743878857",  -- x
    check   = "rbxassetid://7733715400",
    plr     = "rbxassetid://7733964850",
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
local Lighting     = game:GetService("Lighting")
local CAS          = game:GetService("ContextActionService")
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

local P_KEYS   = "PKCheats/keys.json"
local P_USERS  = "PKCheats/users.json"
local P_SESS   = "PKCheats/session.json"
local P_LOGS   = "PKCheats/logs.json"

local KeyDB  = load_json(P_KEYS, {})
local UserDB = load_json(P_USERS, {})
UserDB[ADMIN_USER] = UserDB[ADMIN_USER] or { pass=ADMIN_PASS, admin=true, key="LIFETIME-ADMIN", exp=-1, created=os.time() }
UserDB[ADMIN_USER].admin = true
save_json(P_USERS, UserDB)
local Session = load_json(P_SESS, { user=nil })
local LogDB   = load_json(P_LOGS, {})

local function identify()
    local id = "unknown"; pcall(function() if identifyexecutor then id = identifyexecutor() end end)
    local hwid = "noHWID"; pcall(function() hwid = (gethwid and gethwid()) or game:GetService("RbxAnalyticsService"):GetClientId() end)
    return id, hwid
end

------------------------------------------------------------
-- WEBHOOKS
------------------------------------------------------------
local function http_send(url, body)
    local req = http_request or (syn and syn.request) or request or (fluxus and fluxus.request)
    if req then pcall(req, { Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body })
    else pcall(function() HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson) end) end
end
local function hook_embed(url, title, color, fields, desc)
    local exe = identify()
    local body = { username=BRAND, embeds={{ title=title, description=desc or "", color=color or 14362437,
        fields=fields or {}, footer={ text=BRAND.." | "..DISCORD.." | "..exe },
        timestamp=DateTime.now():ToIsoDate() }} }
    http_send(url, HttpService:JSONEncode(body))
end
local function log(action, detail, color)
    table.insert(LogDB, { t=os.time(), action=action, detail=detail })
    if #LogDB > 500 then table.remove(LogDB, 1) end
    save_json(P_LOGS, LogDB)
    -- replica no webhook de logs
    local fields = {}
    if type(detail)=="table" then for k,v in pairs(detail) do table.insert(fields, { name=tostring(k), value="`"..tostring(v).."`", inline=true }) end
    else table.insert(fields, { name="detalhe", value=tostring(detail), inline=false }) end
    hook_embed(WH_LOGS, action, color or 5793266, fields)
end

------------------------------------------------------------
-- KEY SYSTEM
------------------------------------------------------------
local CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local function gen_key()
    local t = {"PK"}; for i=1,4 do local b={}; for j=1,4 do local n=math.random(1,#CHARS); table.insert(b,CHARS:sub(n,n)) end; table.insert(t,table.concat(b)) end
    return table.concat(t,"-")
end

local function generate_keys(dur_sec, dur_label, qty, who)
    local out = {}
    for i=1,qty do local k; repeat k=gen_key() until not KeyDB[k]
        KeyDB[k] = { duration=dur_sec, created=os.time(), used_by=nil, redeemed_at=nil, generated_by=who }
        table.insert(out, k)
    end
    save_json(P_KEYS, KeyDB)
    hook_embed(WH_KEYS, "KEYS GERADAS", 14362437,
        { { name="quantidade", value=tostring(qty), inline=true },
          { name="duracao", value=dur_label, inline=true },
          { name="gerado por", value=who, inline=true },
          { name="keys", value="```"..table.concat(out,"\n").."```", inline=false } })
    log("key_gen", { qty=qty, dur=dur_label, who=who }, 14362437)
    return out
end

local function redeem_key(user, key)
    local rec = KeyDB[key]
    if not rec then return false, "key invalida" end
    if rec.used_by and rec.used_by ~= user then return false, "key ja usada" end
    rec.used_by = user
    rec.redeemed_at = rec.redeemed_at or os.time()
    local exp = rec.duration==-1 and -1 or (rec.redeemed_at + rec.duration)
    UserDB[user].key = key; UserDB[user].exp = exp
    save_json(P_KEYS, KeyDB); save_json(P_USERS, UserDB)
    hook_embed(WH_LOGS, "KEY RESGATADA", 3066993,
        { { name="usuario", value=user, inline=true },
          { name="key", value="`"..key.."`", inline=true },
          { name="expira", value=(exp==-1 and "nunca" or os.date("%d/%m/%Y %H:%M", exp)), inline=false } })
    log("key_redeem", { user=user, key=key }, 3066993)
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
local function corner(o,r) make("UICorner",{CornerRadius=UDim.new(0,r or 6)},o) end
local function stroke(o,c,t) local s=make("UIStroke",{Color=c or THEME.stroke, Thickness=t or 1},o); s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end
local function pad(o,p) make("UIPadding",{PaddingTop=UDim.new(0,p),PaddingBottom=UDim.new(0,p),PaddingLeft=UDim.new(0,p),PaddingRight=UDim.new(0,p)},o) end
local function label(par,txt,size,bold,col)
    return make("TextLabel",{ BackgroundTransparency=1, Text=txt, TextColor3=col or THEME.text,
        Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham, TextSize=size or 13,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=par })
end
local function icon(par, assetid, size)
    return make("ImageLabel",{ BackgroundTransparency=1, Image=assetid, Size=UDim2.new(0,size or 18,0,size or 18), ImageColor3=THEME.text, Parent=par })
end

-- anima botao no hover + click
local function animate_btn(b)
    local orig = b.BackgroundColor3
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = orig:Lerp(THEME.text, 0.15) }):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = orig }):Play() end)
    b.MouseButton1Down:Connect(function() TweenService:Create(b, TweenInfo.new(0.08), { Size = b.Size - UDim2.new(0,4,0,2) }):Play() end)
    b.MouseButton1Up:Connect(function() TweenService:Create(b, TweenInfo.new(0.08), { Size = b.Size + UDim2.new(0,4,0,2) }):Play() end)
end

------------------------------------------------------------
-- ANTI-RASTRO (parent gui em gethui + nome ofuscado + protect)
------------------------------------------------------------
local function root_parent()
    if gethui then local ok,g=pcall(gethui); if ok then return g end end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end
local SG_NAME = "\0"..string.char(math.random(32,126))..string.char(math.random(32,126))..tostring(math.random(1e8,9e8))
local ScreenGui = make("ScreenGui",{ Name=SG_NAME, ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, IgnoreGuiInset=true })
pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
pcall(function() if protect_gui then protect_gui(ScreenGui) end end)
ScreenGui.Parent = root_parent()

-- stream mode
local StreamOn = false
local function apply_stream() ScreenGui.Enabled = not StreamOn end

------------------------------------------------------------
-- NOTIFICATIONS (FiveM style)
------------------------------------------------------------
local NotifHolder = make("Frame",{ Size=UDim2.new(0,320,1,-40), Position=UDim2.new(1,-336,0,20), BackgroundTransparency=1, Parent=ScreenGui })
make("UIListLayout",{ Padding=UDim.new(0,8), HorizontalAlignment=Enum.HorizontalAlignment.Right, VerticalAlignment=Enum.VerticalAlignment.Top, SortOrder=Enum.SortOrder.LayoutOrder }, NotifHolder)

local notify_counter = 0
local function notify(title, msg, kind, duration)
    notify_counter += 1
    local col = kind=="success" and THEME.good or kind=="warn" and THEME.warn or kind=="error" and THEME.danger or THEME.accent
    local n = make("Frame",{ LayoutOrder=-notify_counter, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundColor3=THEME.bg2, BorderSizePixel=0, Parent=NotifHolder,
        Position=UDim2.new(1,40,0,0), BackgroundTransparency=0 })
    corner(n, 6); stroke(n, THEME.stroke)
    make("Frame",{ Size=UDim2.new(0,4,1,0), BackgroundColor3=col, BorderSizePixel=0, Parent=n })
    local body = make("Frame",{ Size=UDim2.new(1,-20,0,0), Position=UDim2.new(0,14,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Parent=n })
    pad(body, 10)
    make("UIListLayout",{ Padding=UDim.new(0,4) }, body)
    local t = label(body, title, 13, true, col); t.Size=UDim2.new(1,0,0,16)
    local m = label(body, msg, 12, false, THEME.text); m.Size=UDim2.new(1,0,0,0); m.AutomaticSize=Enum.AutomaticSize.Y; m.TextWrapped=true

    -- barra de progresso
    local barBg = make("Frame",{ Size=UDim2.new(1,-20,0,2), Position=UDim2.new(0,14,1,-6), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=n })
    corner(barBg, 1)
    local bar = make("Frame",{ Size=UDim2.new(1,0,1,0), BackgroundColor3=col, BorderSizePixel=0, Parent=barBg })
    corner(bar, 1)

    -- animação slide-in
    TweenService:Create(n, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0,0,0,0) }):Play()
    TweenService:Create(bar, TweenInfo.new(duration or 4, Enum.EasingStyle.Linear), { Size = UDim2.new(0,0,1,0) }):Play()
    task.delay(duration or 4, function()
        local tw = TweenService:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1,40,0,0), BackgroundTransparency = 1 })
        tw:Play(); tw.Completed:Connect(function() n:Destroy() end)
    end)
end

------------------------------------------------------------
-- LOGIN / REGISTER (com botao X)
------------------------------------------------------------
local function new_close_btn(parent, onClick)
    local x = make("TextButton",{ Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-38,0,10),
        BackgroundColor3=THEME.card, BorderSizePixel=0, Text="✕", TextColor3=THEME.accent,
        Font=Enum.Font.GothamBold, TextSize=14, Parent=parent })
    corner(x, 14); stroke(x, THEME.accent)
    x.MouseButton1Click:Connect(onClick)
    animate_btn(x)
    return x
end

local function tbox(par, placeholder)
    local f = make("Frame",{ BackgroundColor3=THEME.card, BorderSizePixel=0, Size=UDim2.new(1,0,0,36), Parent=par })
    corner(f, 6); stroke(f, THEME.stroke)
    local b = make("TextBox",{ BackgroundTransparency=1, Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0),
        PlaceholderText=placeholder, PlaceholderColor3=THEME.text2, TextColor3=THEME.text,
        Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left,
        Text="", ClearTextOnFocus=false, Parent=f })
    return b
end

local function auth_btn(par, txt, primary)
    local b = make("TextButton",{ BackgroundColor3 = primary and THEME.accent or THEME.card, BorderSizePixel=0,
        Size=UDim2.new(1,0,0,40), Text=txt, TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=14, Parent=par })
    corner(b, 6); if not primary then stroke(b, THEME.accent) end
    animate_btn(b)
    return b
end

local LoginRoot = make("Frame",{ Name="Login", Size=UDim2.new(0,440,0,360), Position=UDim2.new(0.5,-220,0.5,-180),
    BackgroundColor3=THEME.bg2, BorderSizePixel=0, Parent=ScreenGui })
corner(LoginRoot, 12); stroke(LoginRoot, THEME.accent, 1.5)
new_close_btn(LoginRoot, function() ScreenGui:Destroy() end)

local LT = label(LoginRoot, BRAND, 24, true, THEME.accent); LT.Size=UDim2.new(1,-60,0,30); LT.Position=UDim2.new(0,30,0,22); LT.TextXAlignment=Enum.TextXAlignment.Center
local LS = label(LoginRoot, "faça login com sua conta", 12, false, THEME.text2); LS.Size=UDim2.new(1,-60,0,16); LS.Position=UDim2.new(0,30,0,54); LS.TextXAlignment=Enum.TextXAlignment.Center

local LBody = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,-60,0,200), Position=UDim2.new(0,30,0,88), Parent=LoginRoot })
make("UIListLayout",{ Padding=UDim.new(0,8) }, LBody)
label(LBody,"usuario",11,false,THEME.text2).Size=UDim2.new(1,0,0,14)
local LUser = tbox(LBody,"seu usuario")
label(LBody,"senha",11,false,THEME.text2).Size=UDim2.new(1,0,0,14)
local LPass = tbox(LBody,"sua senha")
local LBtn = auth_btn(LBody, "ENTRAR", true)
local LToReg = auth_btn(LBody, "ainda não tenho conta — cadastrar", false)

local LStat = label(LoginRoot, "", 11, false, THEME.accent); LStat.Size=UDim2.new(1,-60,0,16); LStat.Position=UDim2.new(0,30,1,-40); LStat.TextXAlignment=Enum.TextXAlignment.Center
local LFt = label(LoginRoot, DISCORD, 10, false, THEME.text2); LFt.Size=UDim2.new(1,-60,0,14); LFt.Position=UDim2.new(0,30,1,-22); LFt.TextXAlignment=Enum.TextXAlignment.Center

local RegRoot = make("Frame",{ Name="Register", Size=UDim2.new(0,440,0,440), Position=UDim2.new(0.5,-220,0.5,-220),
    BackgroundColor3=THEME.bg2, BorderSizePixel=0, Visible=false, Parent=ScreenGui })
corner(RegRoot, 12); stroke(RegRoot, THEME.accent, 1.5)
new_close_btn(RegRoot, function() ScreenGui:Destroy() end)

local RT = label(RegRoot, BRAND, 24, true, THEME.accent); RT.Size=UDim2.new(1,-60,0,30); RT.Position=UDim2.new(0,30,0,22); RT.TextXAlignment=Enum.TextXAlignment.Center
local RS = label(RegRoot, "crie sua conta com uma key válida", 12, false, THEME.text2); RS.Size=UDim2.new(1,-60,0,16); RS.Position=UDim2.new(0,30,0,54); RS.TextXAlignment=Enum.TextXAlignment.Center

local RBody = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,-60,0,280), Position=UDim2.new(0,30,0,88), Parent=RegRoot })
make("UIListLayout",{ Padding=UDim.new(0,8) }, RBody)
label(RBody,"usuario (mínimo 3 caracteres)",11,false,THEME.text2).Size=UDim2.new(1,0,0,14)
local RUser = tbox(RBody,"escolha um usuario")
label(RBody,"senha (mínimo 4 caracteres)",11,false,THEME.text2).Size=UDim2.new(1,0,0,14)
local RPass = tbox(RBody,"escolha uma senha")
label(RBody,"key de ativação",11,false,THEME.accent).Size=UDim2.new(1,0,0,14)
local RKey = tbox(RBody,"PK-XXXX-XXXX-XXXX-XXXX")
local RBtn = auth_btn(RBody, "CADASTRAR", true)
local RToLog = auth_btn(RBody, "já tenho conta — entrar", false)

local RStat = label(RegRoot, "", 11, false, THEME.accent); RStat.Size=UDim2.new(1,-60,0,16); RStat.Position=UDim2.new(0,30,1,-40); RStat.TextXAlignment=Enum.TextXAlignment.Center
local RFt = label(RegRoot, DISCORD, 10, false, THEME.text2); RFt.Size=UDim2.new(1,-60,0,14); RFt.Position=UDim2.new(0,30,1,-22); RFt.TextXAlignment=Enum.TextXAlignment.Center

LToReg.MouseButton1Click:Connect(function() LoginRoot.Visible=false; RegRoot.Visible=true; LStat.Text=""; RStat.Text="" end)
RToLog.MouseButton1Click:Connect(function() RegRoot.Visible=false; LoginRoot.Visible=true; LStat.Text=""; RStat.Text="" end)

------------------------------------------------------------
-- STATE
------------------------------------------------------------
local S = {
    esp = { on=false, box=true, name=true, hp=true, tracer=false, team=false, max_dist=2000 },
    fly = { on=false, speed=60 },
    speed = { on=false, value=50 },
    jump = { on=false, value=80 },
    noclip = { on=false },
    inf_jump = { on=false },
    anti_afk = { on=false },
    fullbright = { on=false },
    zoom = { on=false, value=120 },
    tp = { target="" },
    aim = { on=false, silent=false, fov=120, smooth=0.3, team_check=false, visible_only=false, show_fov=true },
    troll = { god=false, invisible=false, spin=false, big=false, follow_target="" },
}

------------------------------------------------------------
-- SILENT AIM (hookmetamethod)
------------------------------------------------------------
local function get_nearest_head(use_fov)
    local best, bd = nil, (use_fov and S.aim.fov or math.huge)
    local mx,my = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _,plr in ipairs(Players:GetPlayers()) do
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
    return best
end

if hookmetamethod then
    local mt = getrawmetatable(game)
    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if S.aim.silent and not checkcaller() then
            local head = get_nearest_head(true)
            if head then
                if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
                    local origin = Camera.CFrame.Position
                    local dir = (head.Position - origin).Unit * 1000
                    args[1] = Ray.new(origin, dir)
                    return old(self, table.unpack(args))
                elseif method == "Raycast" and typeof(args[1])=="Vector3" and typeof(args[2])=="Vector3" then
                    local origin = args[1]
                    local dir = (head.Position - origin).Unit * (args[2].Magnitude > 0 and args[2].Magnitude or 1000)
                    args[2] = dir
                    return old(self, table.unpack(args))
                elseif method == "ScreenPointToRay" or method == "ViewportPointToRay" then
                    local ray = old(self, table.unpack(args))
                    if typeof(ray)=="Ray" then
                        return Ray.new(ray.Origin, (head.Position - ray.Origin).Unit * 1000)
                    end
                end
            end
        end
        return old(self, ...)
    end)
end

------------------------------------------------------------
-- AIMBOT (fix: mousemoverel em vez de lerp cfram)
------------------------------------------------------------
local hasMouseRel = type(mousemoverel) == "function"

RunService.RenderStepped:Connect(function()
    if not S.aim.on then return end
    if not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local head = get_nearest_head(true); if not head then return end

    if hasMouseRel then
        local vp, on = Camera:WorldToViewportPoint(head.Position); if not on then return end
        local mx,my = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
        local dx = (vp.X - mx) * S.aim.smooth
        local dy = (vp.Y - my) * S.aim.smooth
        pcall(mousemoverel, dx, dy)
    else
        -- fallback cframe com cap de rotacao pra n flipar
        local cur = Camera.CFrame
        local want = CFrame.lookAt(cur.Position, head.Position)
        local _, _, _, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cur:components()
        local newCF = cur:Lerp(want, math.clamp(S.aim.smooth, 0.05, 0.4))
        -- valida: delta grande (>1 rad) significa flip, pula
        local lookA = cur.LookVector; local lookB = newCF.LookVector
        local dot = lookA:Dot(lookB)
        if dot > 0.3 then Camera.CFrame = newCF end
    end
end)

------------------------------------------------------------
-- FOV CIRCLE
------------------------------------------------------------
local fovCircle
if type(Drawing)=="table" and Drawing.new then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.3; fovCircle.NumSides = 60
    fovCircle.Color = THEME.accent; fovCircle.Filled = false; fovCircle.Transparency = 1; fovCircle.Visible = false
end
RunService.RenderStepped:Connect(function()
    if not fovCircle then return end
    if (S.aim.on or S.aim.silent) and S.aim.show_fov then
        fovCircle.Radius = S.aim.fov
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Visible = true
    else fovCircle.Visible = false end
end)

------------------------------------------------------------
-- ESP
------------------------------------------------------------
local USE_DRAW = (type(Drawing)=="table" and Drawing.new)
local ESPData = {}
local function new_esp(plr)
    if ESPData[plr] then return end
    if USE_DRAW then
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
        local nm = label(bb,plr.Name,12,true); nm.Size=UDim2.new(1,0,0,16); nm.TextXAlignment=Enum.TextXAlignment.Center
        local bx = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(0,80,0,100), Position=UDim2.new(0.5,-40,0,18), Parent=bb }); stroke(bx,THEME.accent,1.5)
        ESPData[plr] = { fallback=true, bb=bb, nm=nm, bx=bx }
    end
end
local function kill_esp(plr) local e=ESPData[plr]; if not e then return end; if e.fallback then e.bb:Destroy() else for _,d in pairs(e) do pcall(function() d:Remove() end) end end; ESPData[plr]=nil end
RunService.RenderStepped:Connect(function()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr==LP then continue end
        new_esp(plr); local e=ESPData[plr]
        local ch=plr.Character; local root=ch and ch:FindFirstChild("HumanoidRootPart"); local head=ch and ch:FindFirstChild("Head"); local h=ch and ch:FindFirstChildOfClass("Humanoid")
        local on = S.esp.on and root and head and h and h.Health>0
        local me_root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local dist = (on and me_root) and (me_root.Position-root.Position).Magnitude or 999999
        if on and dist > S.esp.max_dist then on=false end
        if e.fallback then
            e.bb.Adornee = on and head or nil
            e.nm.Text = on and (plr.Name.." ["..math.floor(dist).."m]") or ""
            e.bx.Visible = on and S.esp.box or false
        else
            if not on then for _,d in pairs(e) do d.Visible=false end
            else
                local vp_r, vis = Camera:WorldToViewportPoint(root.Position); local vp_h = Camera:WorldToViewportPoint(head.Position+Vector3.new(0,0.6,0))
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
-- FEATURES: fly / speed / jump / noclip / inf jump / fullbright / zoom
------------------------------------------------------------
local function hrp() local c=LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c=LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local bg, bv
local function stop_fly() if bg then bg:Destroy(); bg=nil end; if bv then bv:Destroy(); bv=nil end end
local function start_fly() stop_fly(); local r=hrp(); if not r then return end
    bg=Instance.new("BodyGyro",r); bg.Name="_"; bg.P=9e4; bg.MaxTorque=Vector3.new(9e9,9e9,9e9); bg.CFrame=r.CFrame
    bv=Instance.new("BodyVelocity",r); bv.Name="_"; bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero end
RunService.Heartbeat:Connect(function()
    if S.fly.on and bg and bv then
        bg.CFrame = Camera.CFrame
        local mv = Vector3.zero
        if UserInput:IsKeyDown(Enum.KeyCode.W) then mv+=Camera.CFrame.LookVector end
        if UserInput:IsKeyDown(Enum.KeyCode.S) then mv-=Camera.CFrame.LookVector end
        if UserInput:IsKeyDown(Enum.KeyCode.D) then mv+=Camera.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.A) then mv-=Camera.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.Space) then mv+=Vector3.new(0,1,0) end
        if UserInput:IsKeyDown(Enum.KeyCode.Q) then mv-=Vector3.new(0,1,0) end
        if mv.Magnitude>0 then mv=mv.Unit*S.fly.speed end
        bv.Velocity = mv
    end
    if S.speed.on then local h=hum(); if h and h.WalkSpeed~=S.speed.value then h.WalkSpeed=S.speed.value end end
    if S.jump.on then local h=hum(); if h and h.JumpPower~=S.jump.value then h.JumpPower=S.jump.value end end
end)
RunService.Stepped:Connect(function()
    if S.noclip.on then local c=LP.Character; if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end
end)
UserInput.JumpRequest:Connect(function() if S.inf_jump.on then local h=hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)

-- fullbright
local origLighting = { Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient, FogEnd=Lighting.FogEnd, Brightness=Lighting.Brightness }
local function apply_fullbright(v)
    if v then Lighting.Ambient=Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255); Lighting.FogEnd=1e6; Lighting.Brightness=3
    else Lighting.Ambient=origLighting.Ambient; Lighting.OutdoorAmbient=origLighting.OutdoorAmbient; Lighting.FogEnd=origLighting.FogEnd; Lighting.Brightness=origLighting.Brightness end
end

-- zoom (altera FOV camera)
RunService.RenderStepped:Connect(function() if S.zoom.on then Camera.FieldOfView = S.zoom.value end end)

-- anti-afk
LP.Idled:Connect(function() if S.anti_afk.on then local vu = game:GetService("VirtualUser"); vu:CaptureController(); vu:ClickButton2(Vector2.new()) end end)

-- tp
local function tp_to(cf) local r=hrp(); if r then r.CFrame=cf end end
local function tp_player(name)
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Name:lower():find(name:lower(),1,true) then
            local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if r then tp_to(r.CFrame+Vector3.new(2,0,0)); notify("Teleporte", "você teleportou pra "..p.Name, "success", 2) end
            return
        end
    end
    notify("Teleporte", "player não encontrado: "..name, "error", 3)
end

------------------------------------------------------------
-- ARMAS (tool grabber)
------------------------------------------------------------
local function scan_tools()
    local out={}; local roots={ RepStorage, Workspace }
    for _,t in ipairs(Teams:GetChildren()) do table.insert(roots,t) end
    for _,p in ipairs(Players:GetPlayers()) do if p.Backpack then table.insert(roots, p.Backpack) end end
    for _,root in ipairs(roots) do for _,d in ipairs(root:GetDescendants()) do if d:IsA("Tool") then table.insert(out,d) end end end
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
            if v then orig_trans[p]=orig_trans[p] or p.Transparency; p.Transparency=1
            else if orig_trans[p] then p.Transparency=orig_trans[p]; orig_trans[p]=nil end end
        end
    end
end
local godConn
local function god_mode(v)
    if godConn then godConn:Disconnect(); godConn=nil end
    if v then godConn=RunService.Heartbeat:Connect(function() local h=hum(); if h then h.Health=h.MaxHealth end end) end
end
local spinBV
local function do_spin(v)
    if spinBV then spinBV:Destroy(); spinBV=nil end
    if not v then return end
    local r=hrp(); if not r then return end
    spinBV = Instance.new("BodyAngularVelocity", r); spinBV.Name="_"; spinBV.MaxTorque=Vector3.new(0,math.huge,0); spinBV.AngularVelocity=Vector3.new(0,20,0)
end
local function big_head(v)
    local c=LP.Character; if not c then return end
    local head=c:FindFirstChild("Head"); local mesh = head and head:FindFirstChildOfClass("SpecialMesh")
    if mesh then mesh.Scale = v and Vector3.new(5,5,5) or Vector3.new(1.25,1.25,1.25) end
end
local function fling_self()
    local r=hrp(); if not r then return end
    local bv2=Instance.new("BodyVelocity", r); bv2.Name="_"; bv2.MaxForce=Vector3.new(9e9,9e9,9e9); bv2.Velocity=Vector3.new(math.random(-500,500), 500, math.random(-500,500))
    task.delay(0.3, function() bv2:Destroy() end)
end
RunService.Heartbeat:Connect(function()
    if S.troll.follow_target=="" then return end
    local tgt
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Name:lower():find(S.troll.follow_target:lower(),1,true) then tgt=p; break end end
    if not tgt then return end
    local tr=tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart"); local r=hrp()
    if tr and r then r.CFrame = tr.CFrame*CFrame.new(0,0,3) end
end)

------------------------------------------------------------
-- ADMIN: saveinstance leak + crash attempt
------------------------------------------------------------
local function try_saveinstance()
    local fn = saveinstance or (syn and syn.saveinstance) or (writecustomasset and nil)
    if fn then
        local ok, err = pcall(fn, { mode="optimized", noscripts=false, savenonkeyinstances=true })
        if ok then return true, "saveinstance disparado — arquivo gerado na pasta do executor"
        else return false, "erro no saveinstance: "..tostring(err) end
    else
        return false, "seu executor não tem saveinstance (precisa Synapse X, Wave, Xeno, Fluxus recente)"
    end
end
local function crash_server_attempt()
    -- NÃO é crash real de player específico (impossível client-side).
    -- É spam de remotes pra tentar estressar o servidor
    local sent = 0
    for _, r in ipairs(RepStorage:GetDescendants()) do
        if r:IsA("RemoteEvent") then
            for i=1,50 do pcall(function() r:FireServer(string.rep("A",1000)) end); sent+=1 end
        end
    end
    return sent
end

------------------------------------------------------------
-- BYPASS / DESINJETAR (apaga rastros)
------------------------------------------------------------
local function wipe_traces()
    -- desliga tudo
    S.esp.on=false; S.fly.on=false; S.speed.on=false; S.jump.on=false; S.noclip.on=false
    S.inf_jump.on=false; S.aim.on=false; S.aim.silent=false; S.troll.god=false; S.troll.invisible=false; S.troll.spin=false
    S.troll.follow_target=""; S.fullbright.on=false; S.zoom.on=false
    stop_fly(); god_mode(false); do_spin(false); set_invisible(false); apply_fullbright(false)
    Camera.FieldOfView = 70
    for p,_ in pairs(ESPData) do kill_esp(p) end
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    -- limpa qualquer bodymover remanescente com nossa marca
    local c=LP.Character; if c then for _,d in ipairs(c:GetDescendants()) do if d:IsA("BodyMover") or d:IsA("BodyGyro") or d:IsA("BodyVelocity") or d:IsA("BodyAngularVelocity") then if d.Name=="_" then d:Destroy() end end end end
    -- apaga arquivos locais do cheat
    if FS_OK then pcall(function() delfile(P_KEYS) end); pcall(function() delfile(P_USERS) end); pcall(function() delfile(P_SESS) end); pcall(function() delfile(P_LOGS) end) end
    -- destroi GUI
    ScreenGui:Destroy()
end

------------------------------------------------------------
-- MAIN MENU
------------------------------------------------------------
local MainRoot
local function build_menu(current_user, is_admin)

MainRoot = make("Frame",{ Name="Main", Active=true, Draggable=true,
    Size=UDim2.new(0, IS_MOBILE and 720 or 940, 0, IS_MOBILE and 460 or 580),
    Position=UDim2.new(0.5,-(IS_MOBILE and 360 or 470),0.5,-(IS_MOBILE and 230 or 290)),
    BackgroundColor3=THEME.bg, BorderSizePixel=0, Parent=ScreenGui })
corner(MainRoot, 12); stroke(MainRoot, THEME.stroke, 1.5)

-- SIDEBAR
local Side = make("Frame",{ Size=UDim2.new(0,210,1,0), BackgroundColor3=THEME.bg2, BorderSizePixel=0, Parent=MainRoot })
corner(Side, 12)
make("Frame",{ Size=UDim2.new(0,2,1,0), Position=UDim2.new(1,-2,0,0), BackgroundColor3=THEME.accent, BorderSizePixel=0, Parent=Side })

local LogoBox = make("Frame",{ Size=UDim2.new(1,-20,0,78), Position=UDim2.new(0,10,0,12), BackgroundTransparency=1, Parent=Side })
local L1 = label(LogoBox,"PK",34,true,THEME.accent); L1.Size=UDim2.new(1,0,0,36); L1.TextXAlignment=Enum.TextXAlignment.Center
local L2 = label(LogoBox,"Cheats Brasil",13,true,THEME.text); L2.Size=UDim2.new(1,0,0,18); L2.Position=UDim2.new(0,0,0,38); L2.TextXAlignment=Enum.TextXAlignment.Center
local L3 = label(LogoBox,DISCORD,10,false,THEME.text2); L3.Size=UDim2.new(1,0,0,14); L3.Position=UDim2.new(0,0,0,58); L3.TextXAlignment=Enum.TextXAlignment.Center

local TabArea = make("ScrollingFrame",{ Size=UDim2.new(1,-20,1,-200), Position=UDim2.new(0,10,0,100),
    BackgroundTransparency=1, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=Side })
make("UIListLayout",{ Padding=UDim.new(0,4) }, TabArea)

local Content = make("Frame",{ Size=UDim2.new(1,-220,1,-20), Position=UDim2.new(0,215,0,10), BackgroundTransparency=1, Parent=MainRoot })

local TopBar = make("Frame",{ Size=UDim2.new(1,0,0,46), BackgroundTransparency=1, Parent=Content })
local TitleLbl = label(TopBar,"Início",18,true); TitleLbl.Size=UDim2.new(1,-200,1,0); TitleLbl.TextColor3=THEME.text
local UserLbl = label(TopBar,current_user..(is_admin and "  [ADMIN]" or ""),12,true,THEME.accent); UserLbl.Size=UDim2.new(0,180,0,16); UserLbl.Position=UDim2.new(1,-220,0,8); UserLbl.TextXAlignment=Enum.TextXAlignment.Right
local ExpLbl = label(TopBar,"",11,false,THEME.text2); ExpLbl.Size=UDim2.new(0,180,0,14); ExpLbl.Position=UDim2.new(1,-220,0,26); ExpLbl.TextXAlignment=Enum.TextXAlignment.Right
local u = UserDB[current_user]
if u.exp == -1 then ExpLbl.Text = "lifetime"; ExpLbl.TextColor3 = THEME.good
else local left=math.max(0,(u.exp or 0)-os.time()); ExpLbl.Text=string.format("expira em %dd %dh", math.floor(left/86400), math.floor((left%86400)/3600)) end
local CloseBtn = make("TextButton",{ Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-34,0,8), BackgroundColor3=THEME.card, Text="✕", TextColor3=THEME.accent, Font=Enum.Font.GothamBold, TextSize=14, BorderSizePixel=0, Parent=TopBar })
corner(CloseBtn, 15); stroke(CloseBtn, THEME.accent); animate_btn(CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() MainRoot.Visible=false end)

local Pages = make("Frame",{ Size=UDim2.new(1,0,1,-56), Position=UDim2.new(0,0,0,54), BackgroundTransparency=1, Parent=Content })

local tabs = {}
local function section_header(txt)
    local l = label(TabArea, "  "..txt, 10, true, THEME.text2); l.Size=UDim2.new(1,0,0,18); l.TextTransparency=0.2
end

local function make_tab(name, iconid)
    local b = make("TextButton",{ BackgroundColor3=THEME.bg, BorderSizePixel=0, Text="", AutoButtonColor=false, Size=UDim2.new(1,0,0,34), Parent=TabArea })
    corner(b, 6)
    local ic = icon(b, iconid, 16); ic.Position = UDim2.new(0,12,0.5,-8); ic.ImageColor3 = THEME.text2
    local lb = label(b, name, 13, false, THEME.text2); lb.Size=UDim2.new(1,-40,1,0); lb.Position=UDim2.new(0,36,0,0); lb.Font=Enum.Font.GothamMedium
    local page = make("ScrollingFrame",{ Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=3, ScrollBarImageColor3=THEME.accent, Visible=false, Parent=Pages })
    pad(page, 2)
    tabs[name] = { btn=b, page=page, lb=lb, ic=ic }
    b.MouseButton1Click:Connect(function()
        for n,t in pairs(tabs) do t.page.Visible=false; t.btn.BackgroundColor3=THEME.bg; t.lb.TextColor3=THEME.text2; t.ic.ImageColor3=THEME.text2 end
        page.Visible=true; TweenService:Create(b, TweenInfo.new(0.2),{BackgroundColor3=THEME.accent}):Play()
        lb.TextColor3=THEME.text; ic.ImageColor3=THEME.text; TitleLbl.Text=name
    end)
    b.MouseEnter:Connect(function() if not page.Visible then TweenService:Create(b, TweenInfo.new(0.15),{BackgroundColor3=THEME.card}):Play() end end)
    b.MouseLeave:Connect(function() if not page.Visible then TweenService:Create(b, TweenInfo.new(0.15),{BackgroundColor3=THEME.bg}):Play() end end)
    return page
end

-- widgets
local function card_block(parent, title)
    local c = make("Frame",{ BackgroundColor3=THEME.card, BorderSizePixel=0, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=parent })
    corner(c, 8); stroke(c, THEME.stroke)
    local header = make("Frame",{ Size=UDim2.new(1,0,0,32), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=c })
    corner(header, 8); make("Frame",{ Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,1,-10), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=header })
    make("Frame",{ Size=UDim2.new(0,3,0,18), Position=UDim2.new(0,0,0.5,-9), BackgroundColor3=THEME.accent, BorderSizePixel=0, Parent=header })
    local ht = label(header, "   "..title, 12, true); ht.Size=UDim2.new(1,-8,1,0)
    local body = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,-20,0,0), Position=UDim2.new(0,10,0,40), AutomaticSize=Enum.AutomaticSize.Y, Parent=c })
    make("UIListLayout",{ Padding=UDim.new(0,6) }, body)
    body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() c.Size=UDim2.new(1,0,0,body.AbsoluteSize.Y+52) end)
    return body
end
local function two_cols(parent)
    local f = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=parent })
    local L = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(0.5,-4,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=f })
    local R = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(0.5,-4,0,0), AutomaticSize=Enum.AutomaticSize.Y, Position=UDim2.new(0.5,4,0,0), Parent=f })
    make("UIListLayout",{ Padding=UDim.new(0,8) }, L); make("UIListLayout",{ Padding=UDim.new(0,8) }, R)
    local function sync() f.Size=UDim2.new(1,0,0,math.max(L.AbsoluteSize.Y,R.AbsoluteSize.Y)) end
    L:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync); R:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync)
    return L, R
end
local function dual(parent)
    local h = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,-4,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=parent })
    make("UIListLayout",{ Padding=UDim.new(0,8) }, h); return h
end
local function toggle(parent, name, def, cb, sub)
    local h = sub and 50 or 36
    local c = make("Frame",{ BackgroundColor3=THEME.card2, BorderSizePixel=0, Size=UDim2.new(1,0,0,h), Parent=parent })
    corner(c, 6)
    local lb = label(c,name,12,true); lb.Position=UDim2.new(0,10,0,sub and 6 or 0); lb.Size=UDim2.new(1,-70,0,16); if not sub then lb.Size=UDim2.new(1,-70,1,0); lb.TextYAlignment=Enum.TextYAlignment.Center end
    if sub then local s=label(c,sub,10,false,THEME.text2); s.Position=UDim2.new(0,10,0,26); s.Size=UDim2.new(1,-70,0,14) end
    local sw = make("TextButton",{ Size=UDim2.new(0,42,0,22), Position=UDim2.new(1,-52,0.5,-11), BackgroundColor3=def and THEME.accent or THEME.bg, BorderSizePixel=0, Text="", AutoButtonColor=false, Parent=c })
    corner(sw, 11)
    local k = make("Frame",{ Size=UDim2.new(0,16,0,16), Position=UDim2.new(def and 1 or 0, def and -19 or 3, 0.5, -8), BackgroundColor3=THEME.text, BorderSizePixel=0, Parent=sw })
    corner(k, 8)
    local v = def
    sw.MouseButton1Click:Connect(function()
        v = not v
        TweenService:Create(sw, TweenInfo.new(0.2, Enum.EasingStyle.Quint),{ BackgroundColor3 = v and THEME.accent or THEME.bg }):Play()
        TweenService:Create(k, TweenInfo.new(0.2, Enum.EasingStyle.Quint),{ Position = UDim2.new(v and 1 or 0, v and -19 or 3, 0.5, -8) }):Play()
        if cb then cb(v) end
    end)
    return c
end
local function slider(parent,name,mn,mx,def,cb)
    local c = make("Frame",{ BackgroundColor3=THEME.card2, BorderSizePixel=0, Size=UDim2.new(1,0,0,52), Parent=parent })
    corner(c, 6)
    label(c,name,12).Position=UDim2.new(0,10,0,6); label(c,name,12).Size=UDim2.new(1,-60,0,16)
    local lb=c:GetChildren()[#c:GetChildren()-1]
    local vl = label(c,tostring(def),12,true,THEME.accent); vl.Size=UDim2.new(0,50,0,16); vl.Position=UDim2.new(1,-60,0,6); vl.TextXAlignment=Enum.TextXAlignment.Right
    local bar = make("Frame",{ Size=UDim2.new(1,-20,0,6), Position=UDim2.new(0,10,0,32), BackgroundColor3=THEME.bg, BorderSizePixel=0, Parent=c })
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
        local rel = math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
        TweenService:Create(fill, TweenInfo.new(0.08),{Size=UDim2.new(rel,0,1,0)}):Play()
        TweenService:Create(k, TweenInfo.new(0.08),{Position=UDim2.new(rel,-7,0.5,-7)}):Play()
        local v = math.floor(mn+(mx-mn)*rel+0.5); vl.Text=tostring(v)
        if cb then cb(v) end
    end)
end
local function wbutton(parent, name, color, cb, sub)
    local h = sub and 46 or 36
    local b = make("TextButton",{ BackgroundColor3=color or THEME.accent, BorderSizePixel=0,
        Size=UDim2.new(1,0,0,h), Text="", AutoButtonColor=false, Parent=parent })
    corner(b, 6)
    local lb = label(b,name,13,true); lb.Size=UDim2.new(1,-20,0,16); lb.Position=UDim2.new(0,10,0,sub and 6 or 0)
    if not sub then lb.Size=UDim2.new(1,-20,1,0); lb.TextXAlignment=Enum.TextXAlignment.Center end
    if sub then local s=label(b,sub,10,false,Color3.fromRGB(230,230,230)); s.Size=UDim2.new(1,-20,0,14); s.Position=UDim2.new(0,10,0,26) end
    b.MouseButton1Click:Connect(cb)
    animate_btn(b)
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
local function dropdown(parent,name,options,cb)
    local c = make("Frame",{ BackgroundColor3=THEME.card2, BorderSizePixel=0, Size=UDim2.new(1,0,0,40), Parent=parent })
    corner(c, 6)
    label(c,name,12).Position=UDim2.new(0,10,0,0); c:GetChildren()[#c:GetChildren()].Size=UDim2.new(1,-170,1,0)
    local cur = options[1].label
    local b = make("TextButton",{ Size=UDim2.new(0,150,0,26), Position=UDim2.new(1,-160,0.5,-13), BackgroundColor3=THEME.bg, BorderSizePixel=0, Text=cur, TextColor3=THEME.text, Font=Enum.Font.Gotham, TextSize=12, Parent=c })
    corner(b, 4); stroke(b, THEME.stroke)
    local list
    b.MouseButton1Click:Connect(function()
        if list then list:Destroy(); list=nil; return end
        list = make("Frame",{ Size=UDim2.new(0,150,0,#options*26+4), Position=UDim2.new(1,-160,1,4), BackgroundColor3=THEME.bg, BorderSizePixel=0, ZIndex=50, Parent=c })
        corner(list, 4); stroke(list, THEME.accent)
        make("UIListLayout",{ Padding=UDim.new(0,2) }, list); pad(list, 2)
        for _, opt in ipairs(options) do
            local ob = make("TextButton",{ Size=UDim2.new(1,0,0,22), BackgroundColor3=THEME.card2, BorderSizePixel=0, Text=opt.label, TextColor3=THEME.text, Font=Enum.Font.Gotham, TextSize=12, ZIndex=51, Parent=list })
            corner(ob, 3)
            ob.MouseButton1Click:Connect(function() b.Text=opt.label; if cb then cb(opt) end; list:Destroy(); list=nil end)
        end
    end)
end

------------------------------------------------------------
-- TABS (ordem e nomes novos)
------------------------------------------------------------
section_header("JOGO")
local pInicio = make_tab("Início",     ICON.home)
local pESP    = make_tab("ESP",        ICON.eye)
local pMove   = make_tab("Movimento",  ICON.bolt)
local pAim    = make_tab("Aimbot",     ICON.target)
local pTP     = make_tab("Teleporte",  ICON.tp)
section_header("EXTRAS")
local pArmas  = make_tab("Armas",      ICON.gun)
local pTroll  = make_tab("Trolls",     ICON.skull)
section_header("SEGURANÇA")
local pBypass = make_tab("Bypass",     ICON.shield)
local pCfg    = make_tab("Config",     ICON.gear)

local pKeys, pLogs, pLeak
if is_admin then
    section_header("ADMIN")
    pKeys = make_tab("Keys", ICON.key)
    pLogs = make_tab("Logs", ICON.doc)
    pLeak = make_tab("Leak + Crash", ICON.bomb)
end

------------------------------------------------------------
-- INÍCIO (foto Roblox + nick + display + ações)
------------------------------------------------------------
do
    local list = dual(pInicio)
    local L, R = two_cols(list)
    local userCard = card_block(L, "Conta Roblox")
    local avatarHolder = make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,0,0,100), Parent=userCard })
    local avatar = make("ImageLabel",{ BackgroundColor3=THEME.bg, BorderSizePixel=0, Size=UDim2.new(0,90,0,90), Position=UDim2.new(0,0,0,5), Parent=avatarHolder })
    corner(avatar, 45); stroke(avatar, THEME.accent, 2)
    task.spawn(function()
        local ok, content = pcall(function()
            return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if ok then avatar.Image = content end
    end)
    local nick = label(avatarHolder, "@"..LP.Name, 14, true, THEME.text); nick.Size=UDim2.new(1,-110,0,18); nick.Position=UDim2.new(0,105,0,10)
    local display = label(avatarHolder, LP.DisplayName, 12, false, THEME.text2); display.Size=UDim2.new(1,-110,0,16); display.Position=UDim2.new(0,105,0,30)
    local uid = label(avatarHolder, "ID: "..LP.UserId, 11, false, THEME.text2); uid.Size=UDim2.new(1,-110,0,14); uid.Position=UDim2.new(0,105,0,48)
    local age = label(avatarHolder, "Conta tem "..LP.AccountAge.." dias", 11, false, THEME.text2); age.Size=UDim2.new(1,-110,0,14); age.Position=UDim2.new(0,105,0,66)

    local plan = card_block(L, "Seu plano")
    label(plan, "Usuário: "..current_user, 12, true).Size=UDim2.new(1,0,0,16)
    label(plan, "Key: "..(UserDB[current_user].key or "nenhuma"), 11, false, THEME.text2).Size=UDim2.new(1,0,0,16)
    label(plan, "Validade: "..(UserDB[current_user].exp==-1 and "LIFETIME" or (UserDB[current_user].exp and os.date("%d/%m/%Y",UserDB[current_user].exp) or "?")), 11, false, THEME.text2).Size=UDim2.new(1,0,0,16)

    local quick = card_block(R, "Ações rápidas")
    wbutton(quick, "Ativar ESP + Fly + Speed", nil, function()
        S.esp.on=true; S.fly.on=true; start_fly(); S.speed.on=true
        notify("Combo ativado", "ESP, Fly e Speed ligados — bom jogo", "success")
    end, "ativa o pacote básico num clique só")
    wbutton(quick, "Desligar tudo", THEME.card2, function()
        S.esp.on=false; S.fly.on=false; stop_fly(); S.speed.on=false; local h=hum(); if h then h.WalkSpeed=16 end
        notify("Tudo desligado", "cheat em modo passivo", "warn")
    end)
    wbutton(quick, "Resetar personagem", THEME.card2, function() local h=hum(); if h then h.Health=0 end end)

    local stats = card_block(R, "Servidor")
    local srv1 = label(stats, "Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers, 12); srv1.Size=UDim2.new(1,0,0,16)
    local srv2 = label(stats, "Place: "..game.PlaceId, 12, false, THEME.text2); srv2.Size=UDim2.new(1,0,0,16)
    local srv3 = label(stats, "Job: "..game.JobId:sub(1,8).."...", 11, false, THEME.text2); srv3.Size=UDim2.new(1,0,0,14)
    task.spawn(function() while MainRoot.Parent do srv1.Text = "Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers; task.wait(3) end end)
end

------------------------------------------------------------
-- ESP
------------------------------------------------------------
do
    local list = dual(pESP)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Visualização")
    toggle(c1,"ESP ligado",false,function(v) S.esp.on=v end,"renderiza as marcações")
    toggle(c1,"Caixa",true,function(v) S.esp.box=v end)
    toggle(c1,"Nome + distância",true,function(v) S.esp.name=v end)
    toggle(c1,"Barra de HP",true,function(v) S.esp.hp=v end)
    toggle(c1,"Tracer",false,function(v) S.esp.tracer=v end,"linha do centro até o alvo")
    toggle(c1,"Cor por time",false,function(v) S.esp.team=v end)
    local c2 = card_block(R, "Filtros")
    slider(c2,"Distância máxima (studs)",100,10000,2000,function(v) S.esp.max_dist=v end)
end

------------------------------------------------------------
-- MOVE
------------------------------------------------------------
do
    local list = dual(pMove)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Fly (F1)")
    toggle(c1,"Fly ligado",false,function(v) S.fly.on=v; if v then start_fly() else stop_fly() end end,"use WASD + Espaço + Q")
    slider(c1,"Velocidade",10,500,60,function(v) S.fly.speed=v end)
    local c2 = card_block(R, "Speed (F2)")
    toggle(c2,"Speed ligado",false,function(v) S.speed.on=v; if not v then local h=hum(); if h then h.WalkSpeed=16 end end end,"desligado = ACS controla o shift normal")
    slider(c2,"Walkspeed",16,500,50,function(v) S.speed.value=v end)
    local c3 = card_block(L, "Pulo")
    toggle(c3,"Jump customizado",false,function(v) S.jump.on=v; if not v then local h=hum(); if h then h.JumpPower=50 end end end)
    slider(c3,"Jump power",50,500,80,function(v) S.jump.value=v end)
    toggle(c3,"Pulo infinito",false,function(v) S.inf_jump.on=v end)
    local c4 = card_block(R, "Extras")
    toggle(c4,"Noclip",false,function(v) S.noclip.on=v end,"atravessa paredes")
    toggle(c4,"Fullbright",false,function(v) S.fullbright.on=v; apply_fullbright(v) end,"ilumina o mapa todo")
    toggle(c4,"Zoom hack (FOV)",false,function(v) S.zoom.on=v; if not v then Camera.FieldOfView=70 end end)
    slider(c4,"FOV",30,120,90,function(v) S.zoom.value=v end)
    toggle(c4,"Anti-AFK",false,function(v) S.anti_afk.on=v end,"não te chutam por inatividade")
end

------------------------------------------------------------
-- AIM
------------------------------------------------------------
do
    local list = dual(pAim)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Aimbot (segurar botão direito)")
    toggle(c1,"Aimbot ligado",false,function(v) S.aim.on=v end,"mira na cabeça do mais próximo no FOV")
    slider(c1,"FOV (pixels)",30,500,120,function(v) S.aim.fov=v end)
    slider(c1,"Smoothness",5,100,30,function(v) S.aim.smooth=v/100 end)
    local c2 = card_block(R, "Silent Aim (F5)")
    toggle(c2,"Silent aim ligado",false,function(v)
        S.aim.silent=v
        notify(v and "Silent Aim ativado" or "Silent Aim desligado", v and "sua bala vai na cabeça do alvo mesmo sem mirar" or "mira voltou ao normal", v and "success" or "warn")
    end, hookmetamethod and "redireciona raycast das armas pra cabeça do alvo" or "seu executor não suporta hookmetamethod (precisa de executor sério)")
    local c3 = card_block(L, "Visual")
    toggle(c3,"Mostrar círculo do FOV",true,function(v) S.aim.show_fov=v end)
    local c4 = card_block(R, "Filtros")
    toggle(c4,"Não mirar em time",false,function(v) S.aim.team_check=v end)
    toggle(c4,"Só alvos visíveis",false,function(v) S.aim.visible_only=v end)
end

------------------------------------------------------------
-- TP
------------------------------------------------------------
do
    local list = dual(pTP)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Teleporte por nome")
    local inp = winput(c1,"nome do player (parcial)")
    inp:GetPropertyChangedSignal("Text"):Connect(function() S.tp.target=inp.Text end)
    wbutton(c1,"Teleportar (F3)",nil,function() if S.tp.target~="" then tp_player(S.tp.target) end end)
    local saved
    wbutton(c1,"Salvar posição atual",THEME.card2,function() local r=hrp(); if r then saved=r.CFrame; notify("Posição salva","você pode voltar depois com um clique","success",2) end end)
    wbutton(c1,"TP pra posição salva",THEME.card2,function() if saved then tp_to(saved) end end)

    local c2 = card_block(R, "Lista de players")
    local lst = make("ScrollingFrame",{ Size=UDim2.new(1,0,0,220), BackgroundColor3=THEME.bg, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=c2 })
    corner(lst, 6); make("UIListLayout",{ Padding=UDim.new(0,2) }, lst); pad(lst,4)
    local function refresh()
        for _,x in ipairs(lst:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP then
            local row = make("Frame",{ Size=UDim2.new(1,-4,0,28), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=lst }); corner(row,4)
            label(row,"  "..p.Name.." ("..p.DisplayName..")",11).Size=UDim2.new(1,-70,1,0)
            local gb = make("TextButton",{ Size=UDim2.new(0,60,0,22), Position=UDim2.new(1,-66,0.5,-11), BackgroundColor3=THEME.accent, BorderSizePixel=0, Text="TP", TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=11, Parent=row }); corner(gb,3)
            gb.MouseButton1Click:Connect(function() tp_player(p.Name) end)
        end end
    end
    wbutton(c2,"Atualizar lista",THEME.card2,refresh)
    refresh()
end

------------------------------------------------------------
-- ARMAS
------------------------------------------------------------
do
    local list = dual(pArmas)
    label(list,"ServerStorage é visível só pro servidor. O scanner varre onde armas realmente ficam acessíveis pro cliente: ReplicatedStorage, Workspace, Teams, e as mochilas dos outros players.",11,false,THEME.text2).Size=UDim2.new(1,0,0,32)
    local c = card_block(list, "Armas encontradas no servidor")
    local lst = make("ScrollingFrame",{ Size=UDim2.new(1,0,0,240), BackgroundColor3=THEME.bg, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=c })
    corner(lst, 6); make("UIListLayout",{ Padding=UDim.new(0,3) }, lst); pad(lst,4)
    local function refresh()
        for _,x in ipairs(lst:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
        for _,t in ipairs(scan_tools()) do
            local row = make("Frame",{ Size=UDim2.new(1,-4,0,28), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=lst }); corner(row,4)
            label(row,"  "..t.Name.."  < "..t.Parent.Name.." >",11).Size=UDim2.new(1,-70,1,0)
            local gb = make("TextButton",{ Size=UDim2.new(0,60,0,22), Position=UDim2.new(1,-66,0.5,-11), BackgroundColor3=THEME.accent, BorderSizePixel=0, Text="pegar", TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=11, Parent=row }); corner(gb,3)
            gb.MouseButton1Click:Connect(function() grab(t); notify("Arma pega",t.Name.." foi pra sua mochila","success",2) end)
        end
    end
    wbutton(c,"Atualizar lista",THEME.card2,refresh)
    wbutton(c,"Pegar TODAS",nil,function() local n=0; for _,t in ipairs(scan_tools()) do pcall(grab,t); n+=1 end; notify("Armas pegas",n.." armas na mochila","success") end)
    refresh()
end

------------------------------------------------------------
-- TROLLS
------------------------------------------------------------
do
    local list = dual(pTroll)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Trolls em você mesmo")
    toggle(c1,"God Mode local",false,function(v) S.troll.god=v; god_mode(v); notify("God Mode",v and "você é invencível (client-side)" or "god desativado",v and "success" or "warn",2) end)
    toggle(c1,"Invisível",false,function(v) S.troll.invisible=v; set_invisible(v) end,"vira transparente — só pra você")
    toggle(c1,"Rodar no eixo",false,function(v) S.troll.spin=v; do_spin(v) end)
    toggle(c1,"Cabeça gigante",false,function(v) S.troll.big=v; big_head(v) end)
    wbutton(c1,"Fling (jogar longe)",nil,fling_self,"se joga em velocidade absurda")
    local c2 = card_block(R, "Em outros players")
    local inp = winput(c2,"nome pra perseguir")
    wbutton(c2,"Grudar nas costas do alvo",nil,function() S.troll.follow_target=inp.Text; notify("Perseguindo","você tá colado no "..inp.Text,"success",2) end)
    wbutton(c2,"Parar de perseguir",THEME.card2,function() S.troll.follow_target=""; notify("Parou","perseguição cancelada","warn",2) end)
    label(c2,"OBS: animar outros players requer server-side (impossível client only). Esses trolls se limitam ao seu personagem e perseguição.",10,false,THEME.text2).Size=UDim2.new(1,0,0,32)
end

------------------------------------------------------------
-- BYPASS
------------------------------------------------------------
do
    local list = dual(pBypass)
    local c1 = card_block(list, "Anti-rastro")
    label(c1,"A GUI do cheat já tá com nome ofuscado e parentada em gethui (fora do PlayerGui). BodyMovers são renomeados pra passar por script normal. Sua sessão não escreve nada que seja fácil detectar depois.",11,false,THEME.text2).Size=UDim2.new(1,0,0,48)
    local c2 = card_block(list, "Desinjetar + Limpar")
    label(c2,"Esse botão desliga TODAS as features, remove todos os BodyMovers, apaga os arquivos locais do cheat (keys.json, users.json, session.json, logs.json) e destrói a interface. Usa isso antes de deixar alguém pegar sua tela.",11,false,THEME.text2).Size=UDim2.new(1,0,0,48)
    wbutton(c2,"DESINJETAR AGORA",THEME.accent2,function()
        notify("Desinjetando...","apagando rastros e fechando o cheat","warn",2)
        task.wait(0.5)
        wipe_traces()
    end, "cheat fecha e nenhum arquivo fica pra trás")
    wbutton(c2,"Reset personagem (limpa BodyMovers)",THEME.card2,function() local h=hum(); if h then h.Health=0 end end)
end

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------
do
    local list = dual(pCfg)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Interface")
    toggle(c1,"Stream Mode (F4)",false,function(v) StreamOn=v; apply_stream(); notify("Stream Mode",v and "GUI invisível pra gravadores" or "GUI visível novamente",v and "success" or "warn") end,"esconde o menu de OBS/Discord/XboxBar")
    wbutton(c1,"Deslogar",THEME.card2,function() Session.user=nil; save_json(P_SESS,Session); ScreenGui:Destroy() end)
    local c2 = card_block(R, "Hotkeys")
    label(c2,"INSERT  —  abre/fecha o menu",12).Size=UDim2.new(1,0,0,16)
    label(c2,"F1  —  fly on/off",12).Size=UDim2.new(1,0,0,16)
    label(c2,"F2  —  speed on/off",12).Size=UDim2.new(1,0,0,16)
    label(c2,"F3  —  tp pro player do campo",12).Size=UDim2.new(1,0,0,16)
    label(c2,"F4  —  stream mode",12).Size=UDim2.new(1,0,0,16)
    label(c2,"F5  —  silent aim",12).Size=UDim2.new(1,0,0,16)
end

------------------------------------------------------------
-- ADMIN: KEYS
------------------------------------------------------------
if pKeys then
    local list = dual(pKeys)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Gerar keys")
    local sel = DURATIONS[1]
    local opts={}; for _,d in ipairs(DURATIONS) do table.insert(opts,{label=d.label, data=d}) end
    dropdown(c1,"duração",opts,function(o) sel=o.data end)
    local qty = winput(c1,"quantidade (1 a 500)")
    local result = label(c1,"",10,false,THEME.text2); result.Size=UDim2.new(1,0,0,120); result.TextWrapped=true; result.Font=Enum.Font.Code; result.TextYAlignment=Enum.TextYAlignment.Top
    wbutton(c1,"Gerar + enviar pro Discord",nil,function()
        local q = tonumber(qty.Text) or 0
        if q<1 or q>500 then notify("Erro","quantidade inválida (1-500)","error"); return end
        local ks = generate_keys(sel.seconds, sel.label, q, current_user)
        result.Text = ("gerou %d keys (%s)\n\n%s"):format(q,sel.label,table.concat(ks,"\n"))
        notify("Keys geradas",q.." keys de "..sel.label.." enviadas pro webhook","success")
    end)
    local c2 = card_block(R, "Estatísticas")
    local total,used=0,0
    for _,r in pairs(KeyDB) do total+=1; if r.used_by then used+=1 end end
    local stat = label(c2,("total: %d  |  resgatadas: %d  |  livres: %d"):format(total,used,total-used),12,true); stat.Size=UDim2.new(1,0,0,20)
    wbutton(c2,"Atualizar",THEME.card2,function() total,used=0,0; for _,r in pairs(KeyDB) do total+=1; if r.used_by then used+=1 end end; stat.Text=("total: %d  |  resgatadas: %d  |  livres: %d"):format(total,used,total-used) end)
end

------------------------------------------------------------
-- ADMIN: LOGS
------------------------------------------------------------
if pLogs then
    local list = dual(pLogs)
    local c = card_block(list, "Logs recentes (últimos 100)")
    local lb = make("ScrollingFrame",{ Size=UDim2.new(1,0,0,340), BackgroundColor3=THEME.bg, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=c })
    corner(lb, 6); make("UIListLayout",{ Padding=UDim.new(0,2) }, lb); pad(lb,4)
    local function refresh()
        for _,x in ipairs(lb:GetChildren()) do if x:IsA("TextLabel") then x:Destroy() end end
        local start=math.max(1,#LogDB-100)
        for i=start,#LogDB do local e=LogDB[i]; local when=os.date("%d/%m %H:%M:%S",e.t); local det=type(e.detail)=="table" and HttpService:JSONEncode(e.detail) or tostring(e.detail)
            local l = label(lb,"["..when.."] "..e.action.." — "..det,10,false,THEME.text2); l.Size=UDim2.new(1,0,0,14); l.Font=Enum.Font.Code
        end
    end
    refresh()
    wbutton(c,"Atualizar",THEME.card2,refresh)
    wbutton(c,"Limpar logs locais",THEME.accent2,function() LogDB={}; save_json(P_LOGS,LogDB); refresh(); notify("Logs limpos","histórico local zerado","warn") end)
end

------------------------------------------------------------
-- ADMIN: LEAK + CRASH
------------------------------------------------------------
if pLeak then
    local list = dual(pLeak)
    local L,R = two_cols(list)
    local c1 = card_block(L, "Save Instance (leak do mapa)")
    label(c1,"saveinstance clona o place inteiro pra um .rbxl na pasta Workspace do seu executor. Funciona em Synapse X, Wave, Xeno, Fluxus recentes. Scripts locais incluídos.",11,false,THEME.text2).Size=UDim2.new(1,0,0,48)
    wbutton(c1,"Dumpar place.rbxl",nil,function()
        local ok,msg = try_saveinstance()
        notify(ok and "Leak em execução" or "Leak falhou", msg, ok and "success" or "error", 6)
        log("admin_leak", { user=current_user, success=ok, msg=msg }, ok and 15844367 or 14362437)
    end,"salva o place todo na pasta do executor")

    local c2 = card_block(R, "Crash server attempt")
    label(c2,"Spama todos os RemoteEvents do ReplicatedStorage com payload grande pra tentar sobrecarregar o servidor. OBS: crashar UM player específico do lado cliente é impossível — isso tenta derrubar o server inteiro, nem sempre funciona dependendo do rate-limit.",11,false,THEME.text2).Size=UDim2.new(1,0,0,64)
    wbutton(c2,"Tentar crashar servidor",THEME.accent2,function()
        local sent = crash_server_attempt()
        notify("Payload enviado",sent.." requests disparados","warn",4)
        log("admin_crash", { user=current_user, sent=sent }, 14362437)
    end,"usa com responsabilidade — você também pode ser kickado")

    local c3 = card_block(R, "Info do place")
    label(c3,"PlaceId: "..game.PlaceId,11).Size=UDim2.new(1,0,0,14)
    label(c3,"GameId: "..game.GameId,11).Size=UDim2.new(1,0,0,14)
    label(c3,"JobId: "..game.JobId,10,false,THEME.text2).Size=UDim2.new(1,0,0,14)
end

-- seleciona Início
tabs["Início"].btn.MouseButton1Click:Fire()

------------------------------------------------------------
-- HOTKEYS via ContextActionService (priority alta ignora gpe)
------------------------------------------------------------
local function toggle_menu() MainRoot.Visible = not MainRoot.Visible end

CAS:BindActionAtPriority("pkMenu", function(_, state) if state==Enum.UserInputState.Begin then toggle_menu() end return Enum.ContextActionResult.Pass end, false, 2000, Enum.KeyCode.Insert)
CAS:BindActionAtPriority("pkFly",  function(_, state) if state==Enum.UserInputState.Begin then S.fly.on=not S.fly.on; if S.fly.on then start_fly(); notify("Fly","voo ligado","success",1.5) else stop_fly(); notify("Fly","voo desligado","warn",1.5) end end return Enum.ContextActionResult.Pass end, false, 2000, Enum.KeyCode.F1)
CAS:BindActionAtPriority("pkSpd",  function(_, state) if state==Enum.UserInputState.Begin then S.speed.on=not S.speed.on; if not S.speed.on then local h=hum(); if h then h.WalkSpeed=16 end end; notify("Speed", S.speed.on and "ligado" or "desligado", S.speed.on and "success" or "warn", 1.5) end return Enum.ContextActionResult.Pass end, false, 2000, Enum.KeyCode.F2)
CAS:BindActionAtPriority("pkTp",   function(_, state) if state==Enum.UserInputState.Begin then if S.tp.target~="" then tp_player(S.tp.target) end end return Enum.ContextActionResult.Pass end, false, 2000, Enum.KeyCode.F3)
CAS:BindActionAtPriority("pkStr",  function(_, state) if state==Enum.UserInputState.Begin then StreamOn=not StreamOn; apply_stream() end return Enum.ContextActionResult.Pass end, false, 2000, Enum.KeyCode.F4)
CAS:BindActionAtPriority("pkSil",  function(_, state) if state==Enum.UserInputState.Begin then S.aim.silent=not S.aim.silent; notify("Silent Aim", S.aim.silent and "ligado" or "desligado", S.aim.silent and "success" or "warn", 1.5) end return Enum.ContextActionResult.Pass end, false, 2000, Enum.KeyCode.F5)

LP.CharacterAdded:Connect(function()
    task.wait(0.5); if S.fly.on then start_fly() end
    orig_trans = {}
    if S.troll.invisible then set_invisible(true) end
end)

-- mobile fab
if IS_MOBILE then
    local fab = make("TextButton",{ Size=UDim2.new(0,56,0,56), Position=UDim2.new(0,16,0.5,-28), BackgroundColor3=THEME.accent, BorderSizePixel=0, Text="PK", TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=18, Parent=ScreenGui })
    corner(fab,28); stroke(fab,THEME.text,1.5)
    fab.MouseButton1Click:Connect(toggle_menu)
    local drag,dStart,sPos
    fab.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=true; dStart=i.Position; sPos=fab.Position end end)
    fab.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    UserInput.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-dStart; fab.Position=UDim2.new(sPos.X.Scale,sPos.X.Offset+d.X,sPos.Y.Scale,sPos.Y.Offset+d.Y) end end)
end

notify("PK Cheats Brasil", "login bem-sucedido, "..current_user, "success", 3)
log("login", { user=current_user, admin=is_admin, platform=IS_MOBILE and "mobile" or "pc" }, 3447003)

end -- build_menu

------------------------------------------------------------
-- LOGIN / REGISTER LOGIC
------------------------------------------------------------
local function do_login(u,p)
    local rec = UserDB[u]; if not rec then return false, "usuário não existe" end
    if rec.pass ~= p then return false, "senha errada" end
    if not rec.admin and not key_active(u) then return false, "sua key expirou ou não existe" end
    Session.user = u; save_json(P_SESS, Session)
    return true
end
local function do_register(u,p,k)
    if UserDB[u] then return false, "esse usuário já existe" end
    if #u < 3 then return false, "usuário muito curto" end
    if #p < 4 then return false, "senha muito curta" end
    if not KeyDB[k] then return false, "key inválida" end
    if KeyDB[k].used_by then return false, "essa key já foi usada" end
    UserDB[u] = { pass=p, admin=false, key=nil, exp=nil, created=os.time() }
    save_json(P_USERS, UserDB)
    local ok, msg = redeem_key(u, k)
    if not ok then UserDB[u]=nil; save_json(P_USERS, UserDB); return false, msg end
    return true
end

LBtn.MouseButton1Click:Connect(function()
    local u,p = LUser.Text, LPass.Text
    local ok,msg = do_login(u,p)
    if ok then LoginRoot:Destroy(); RegRoot:Destroy(); build_menu(u, UserDB[u].admin==true); notify("Entrou com sucesso","bem-vindo, "..u,"success",3)
    else LStat.Text=msg; LStat.TextColor3=THEME.danger; notify("Falha no login",msg,"error") end
end)

RBtn.MouseButton1Click:Connect(function()
    local u,p,k = RUser.Text, RPass.Text, RKey.Text
    local ok,msg = do_register(u,p,k)
    if ok then
        RStat.Text="conta criada! redirecionando..."; RStat.TextColor3=THEME.good
        notify("Cadastro concluído", "sua key foi resgatada — agora faça login", "success", 4)
        task.wait(1.3)
        RegRoot.Visible=false; LoginRoot.Visible=true
        LUser.Text=u; LPass.Text=""
        LStat.Text="conta criada — digite sua senha"; LStat.TextColor3=THEME.good
    else RStat.Text=msg; RStat.TextColor3=THEME.danger; notify("Falha no cadastro",msg,"error") end
end)

-- auto-login
if Session.user and UserDB[Session.user] then
    local u = Session.user; local rec = UserDB[u]
    if rec.admin or key_active(u) then LoginRoot:Destroy(); RegRoot:Destroy(); build_menu(u, rec.admin==true) end
end
