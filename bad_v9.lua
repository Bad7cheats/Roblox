-- PK Cheats Brasil v7.1 :: discord.gg/bad7 | built by olivia
-- [K] toggle menu (rebindável em Config) | F1 fly | F2 speed | F3 tp | F4 stream | F5 silent
-- ICONS: rbxassetid sistema Roblox — sem emoji, tudo ImageLabel nativo

local WH_KEYS   = "https://discord.com/api/webhooks/1567420040909955122/GwqHbupriadtx8DKZeosFBfOm_KMFshSwpbJbZQ2rq9EYvPUruLjknEgIygeNbi_Vbfz"
local WH_STATUS = "https://webhook.lewisakura.moe/api/webhooks/1567427417948033074/qgX3IXyzajz1PIMXsUmVereVhFgW9NDgx3EB-N7tkzYB-fqeFAuOt-UMbStoibp5dgqP"
local ADMIN_USER, ADMIN_PASS = "bad7", "1986rkrk"
local DISCORD, BRAND = "discord.gg/bad7", "PK Cheats Brasil"
local LOGO_ID   = "rbxassetid://93685935272917"

-- ══════════════════════════════════════════════════════
-- ICON TABLE — rbxassetid apenas, sem emoji
-- IDs do catálogo Roblox (assets públicos estáveis)
-- ══════════════════════════════════════════════════════
local ICO = {
    -- UI chrome
    close    = "rbxassetid://9243051060",   -- X branco em círculo escuro
    hide     = "rbxassetid://115907727716783",   -- olho fechado / hide
    -- tabs
    home     = "rbxassetid://74834108605061",   -- casa
    eye_open = "rbxassetid://124075081627345",   -- olho aberto  → ESP
    target   = "rbxassetid://90533003192128",   -- mira circular → Aimbot
    misc     = "rbxassetid://16717281575",   -- engrenagem movimento → Misc (antes Movimento)
    tp       = "rbxassetid://6723742952",   -- pin localização
    gun      = "rbxassetid://15000720478",   -- revólver
    server   = "rbxassetid://9692125126",   -- antena / sinal
    money    = "rbxassetid://98856250331656",   -- moeda / cifrão
    spy      = "rbxassetid://99346474524663",   -- rádio / radar
    bypass   = "rbxassetid://128516936776932",   -- globo / escudo
    gear     = "rbxassetid://98211971158539",   -- engrenagem config
    key      = "rbxassetid://7072718939",   -- chave
    doc      = "rbxassetid://7072718940",   -- documento / clipboard
}

local THEME = {
    bg      = Color3.fromRGB(10,10,12),
    bg2     = Color3.fromRGB(18,18,22),
    card    = Color3.fromRGB(24,24,28),
    card2   = Color3.fromRGB(32,32,36),
    accent  = Color3.fromRGB(220,38,38),
    accent2 = Color3.fromRGB(170,20,20),
    accent3 = Color3.fromRGB(120,10,10),
    text    = Color3.fromRGB(240,240,240),
    text2   = Color3.fromRGB(145,145,150),
    good    = Color3.fromRGB(45,200,95),
    warn    = Color3.fromRGB(255,180,40),
    danger  = Color3.fromRGB(255,60,60),
    stroke  = Color3.fromRGB(38,38,44),
}

local DURATIONS = {
    {label="6 horas",  seconds=6*3600},
    {label="24 horas", seconds=24*3600},
    {label="3 dias",   seconds=3*86400},
    {label="7 dias",   seconds=7*86400},
    {label="1 mes",    seconds=30*86400},
    {label="1 ano",    seconds=365*86400},
    {label="lifetime", seconds=-1},
}

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UserInput   = game:GetService("UserInputService")
local TweenService= game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace   = game:GetService("Workspace")
local Teams       = game:GetService("Teams")
local RepStorage  = game:GetService("ReplicatedStorage")
local Lighting    = game:GetService("Lighting")
local CAS         = game:GetService("ContextActionService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local IS_MOBILE   = UserInput.TouchEnabled and not UserInput.KeyboardEnabled

-- ══════════════════════════════════════════════════════
-- HWID / EXECUTOR
-- ══════════════════════════════════════════════════════
local function get_hwid()
    local h = "unknown"
    pcall(function() if gethwid then h = gethwid() end end)
    if h == "unknown" then
        pcall(function() h = game:GetService("RbxAnalyticsService"):GetClientId() end)
    end
    return tostring(h)
end
local HWID = get_hwid()
local EXE  = "unknown"
pcall(function() if identifyexecutor then EXE = identifyexecutor() end end)

-- ══════════════════════════════════════════════════════
-- FILESYSTEM
-- ══════════════════════════════════════════════════════
local FS_OK = type(writefile) == "function" and type(readfile) == "function"
           and type(isfile)   == "function" and type(makefolder) == "function"
if FS_OK then pcall(function() makefolder("PKCheats") end) end

local function fs_read(p, f)
    if not FS_OK or not isfile(p) then return f end
    local ok, v = pcall(readfile, p)
    return ok and v or f
end
local function fs_write(p, d)
    if FS_OK then pcall(writefile, p, d) end
end
local function load_json(p, d)
    local r = fs_read(p, nil)
    if not r then return d end
    local ok, v = pcall(HttpService.JSONDecode, HttpService, r)
    return ok and v or d
end
local function save_json(p, t)
    local ok, v = pcall(HttpService.JSONEncode, HttpService, t)
    if ok then fs_write(p, v) end
end

local P_KEYS  = "PKCheats/keys.json"
local P_USERS = "PKCheats/users.json"
local P_SESS  = "PKCheats/session.json"
local P_CFG   = "PKCheats/cfg.json"

local KeyDB   = load_json(P_KEYS,  {})
local UserDB  = load_json(P_USERS, {})
UserDB[ADMIN_USER] = UserDB[ADMIN_USER] or {
    pass=ADMIN_PASS, admin=true, key="LIFETIME-ADMIN", exp=-1, hwid=HWID, created=os.time()
}
UserDB[ADMIN_USER].admin = true
UserDB[ADMIN_USER].hwid  = HWID
save_json(P_USERS, UserDB)

local Session = load_json(P_SESS, {user=nil})
local CfgDB   = load_json(P_CFG,  {accent={220,38,38}, transparency=0.12, aim_whitelist={}, toggle_key="K"})
THEME.accent  = Color3.fromRGB(table.unpack(CfgDB.accent))

-- ══════════════════════════════════════════════════════
-- KEYBIND
-- ══════════════════════════════════════════════════════
local CurrentToggleKey = Enum.KeyCode[CfgDB.toggle_key] or Enum.KeyCode.K
local RebindingKey     = false

local function save_keybind(kc)
    CurrentToggleKey   = kc
    CfgDB.toggle_key   = kc.Name
    save_json(P_CFG, CfgDB)
end

-- ══════════════════════════════════════════════════════
-- HTTP / WEBHOOK
-- ══════════════════════════════════════════════════════
local function http_send(url, body)
    local req = http_request or (syn and syn.request) or request or (fluxus and fluxus.request)
    if req then
        pcall(req, {Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body})
    else
        pcall(function() HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson) end)
    end
end

local function hook_embed(url, title, color, fields, desc)
    http_send(url, HttpService:JSONEncode({
        username = BRAND,
        embeds   = {{
            title       = title,
            description = desc or "",
            color       = color or 14362437,
            fields      = fields or {},
            footer      = {text = BRAND .. " • " .. DISCORD},
            timestamp   = DateTime.now():ToIsoDate(),
        }},
    }))
end

-- ══════════════════════════════════════════════════════
-- KEY SYSTEM
-- ══════════════════════════════════════════════════════
local CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

local function gen_key()
    local t = {"PK"}
    for _ = 1, 4 do
        local b = {}
        for _ = 1, 4 do
            local n = math.random(1, #CHARS)
            table.insert(b, CHARS:sub(n, n))
        end
        table.insert(t, table.concat(b))
    end
    return table.concat(t, "-")
end

local function generate_keys(sec, lbl, qty, who)
    local out = {}
    for _ = 1, qty do
        local k
        repeat k = gen_key() until not KeyDB[k]
        KeyDB[k] = {duration=sec, created=os.time(), used_by=nil, redeemed_at=nil, generated_by=who, bound_hwid=nil}
        table.insert(out, k)
    end
    save_json(P_KEYS, KeyDB)
    -- log vai pra WH_KEYS (canal #logs de key)
    hook_embed(WH_KEYS, "🔑 KEYS GERADAS", 14362437, {
        {name="Quantidade",  value=tostring(qty),              inline=true},
        {name="Duração",     value=lbl,                        inline=true},
        {name="Gerado por",  value=who,                        inline=true},
        {name="Keys",        value="```"..table.concat(out,"\n").."```", inline=false},
    })
    return out
end

local function redeem_key(user, key)
    local rec = KeyDB[key]
    if not rec then return false, "key inexistente" end
    if rec.used_by and rec.used_by ~= user then return false, "key ja usada" end
    rec.used_by      = user
    rec.redeemed_at  = rec.redeemed_at or os.time()
    rec.bound_hwid   = rec.bound_hwid or HWID
    local exp = rec.duration == -1 and -1 or (rec.redeemed_at + rec.duration)
    UserDB[user].key  = key
    UserDB[user].exp  = exp
    UserDB[user].hwid = HWID
    save_json(P_KEYS, KeyDB)
    save_json(P_USERS, UserDB)
    hook_embed(WH_KEYS, "✅ KEY RESGATADA", 3066993, {
        {name="Usuário",  value="`"..user.."`",                   inline=true},
        {name="Key",      value="`"..key.."`",                    inline=true},
        {name="Validade", value=exp==-1 and "LIFETIME" or os.date("%d/%m/%Y",exp), inline=true},
        {name="HWID",     value="`"..HWID.."`",                   inline=false},
    })
    return true, exp
end

local function key_active(user)
    local u = UserDB[user]
    if not u or not u.key then return false, "NO_KEY" end
    if u.hwid and u.hwid ~= HWID then return false, "HWID_MISMATCH" end
    if u.exp == -1 then return true end
    if os.time() >= (u.exp or 0) then return false, "EXPIRED" end
    return true
end

local function is_lifetime(user)
    local u = UserDB[user]
    return u and u.exp == -1
end

local function delete_expired(user)
    if UserDB[user] and not UserDB[user].admin then
        local k = UserDB[user].key
        UserDB[user] = nil
        if k and KeyDB[k] then KeyDB[k] = nil end
        save_json(P_USERS, UserDB)
        save_json(P_KEYS, KeyDB)
    end
end

local function admin_reset_hwid(t)
    local u = UserDB[t]
    if not u then return false, "nao existe" end
    u.hwid = nil
    save_json(P_USERS, UserDB)
    if u.key and KeyDB[u.key] then KeyDB[u.key].bound_hwid = nil; save_json(P_KEYS, KeyDB) end
    return true
end

-- ══════════════════════════════════════════════════════
-- ANTICHEAT DETECTOR
-- ══════════════════════════════════════════════════════
local ACDetector = {}
do
    local signatures = {
        {name="Byfron / Hyperion", level="🔴 ALTO", check=function()
            return game:FindFirstChild("HyperionDetect") ~= nil or (typeof(checkcaller) == "function")
        end},
        {name="EasyAntiCheat", level="🔴 ALTO", check=function()
            for _, v in ipairs(game:GetDescendants()) do
                if v.Name:lower():find("eac") then return true end
            end
            return false
        end},
        {name="FairPlay (Roblox)", level="🟡 MÉDIO", check=function()
            local ok, _ = pcall(function() return game:GetService("FairplayService") end)
            return ok
        end},
        {name="Anti-Cheat Script Custom", level="🟡 MÉDIO", check=function()
            for _, v in ipairs(game:GetDescendants()) do
                local n = v.Name:lower()
                if n:find("anticheat") or n:find("anti_cheat") or n:find("accheck") or n:find("kicksystem") then return true end
            end
            return false
        end},
        {name="Server-Side Kick Monitor", level="🟡 MÉDIO", check=function()
            local count = 0
            for _, v in ipairs(RepStorage:GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    local n = v.Name:lower()
                    if n:find("kick") or n:find("ban") or n:find("flag") or n:find("cheat") then count += 1 end
                end
            end
            return count >= 2
        end},
        {name="Nenhum detectado", level="🟢 BAIXO", check=function() return true end},
    }
    function ACDetector.scan()
        for _, sig in ipairs(signatures) do
            local ok, result = pcall(sig.check)
            if ok and result then return sig.name, sig.level end
        end
        return "Desconhecido", "⚪ N/D"
    end
end

-- ══════════════════════════════════════════════════════
-- STATUS PREMIUM
-- ══════════════════════════════════════════════════════
local function send_status_premium(current_user, is_admin)
    local active = {}
    for k, cat in pairs(S or {}) do
        if type(cat) == "table" and cat.on then table.insert(active, k) end
    end
    local risk, dot, title_color
    if (S and S.aim and (S.aim.silent or S.aim.on)) or (S and S.fly and S.fly.on) then
        risk, dot, title_color = "Risky / Unstable", "🟡", 16763904
    else
        risk, dot, title_color = "Fully Working", "🟢", 3066993
    end
    hook_embed(WH_STATUS, "Status [Premium]", title_color, {
        {name="Usuário",  value="`"..current_user.."`"..(is_admin and " **[ADMIN]**" or ""), inline=true},
        {name="Place",    value="`"..game.PlaceId.."`",                                       inline=true},
        {name="Features", value=#active>0 and ("`"..table.concat(active,", ").."`") or "`nenhuma`", inline=false},
    }, dot.." **PK Cheats Brasil** — "..risk.."\n\n🔴 **=** Down\n🟡 **=** Risky\n🟢 **=** Working")
end

-- ══════════════════════════════════════════════════════
-- GUI ROOT
-- ══════════════════════════════════════════════════════
local function root_parent()
    if gethui then local ok, g = pcall(gethui); if ok then return g end end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end
local SG_NAME = "\0" .. string.char(math.random(32,126)) .. tostring(math.random(1e8,9e8))
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = SG_NAME
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder   = 9999
pcall(function() if syn and syn.protect_gui   then syn.protect_gui(ScreenGui)   end end)
pcall(function() if protect_gui               then protect_gui(ScreenGui)        end end)
ScreenGui.Parent = root_parent()

-- ══════════════════════════════════════════════════════
-- UI HELPERS
-- ══════════════════════════════════════════════════════
local function make(c, p, par)
    local o = Instance.new(c)
    for k, v in pairs(p or {}) do o[k] = v end
    if par then o.Parent = par end
    return o
end
local function corner(o, r)
    make("UICorner", {CornerRadius=UDim.new(0, r or 6)}, o)
end
local function stroke(o, c, t)
    local s = make("UIStroke", {Color=c or THEME.stroke, Thickness=t or 1}, o)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end
local function pad(o, p)
    make("UIPadding", {
        PaddingTop=UDim.new(0,p), PaddingBottom=UDim.new(0,p),
        PaddingLeft=UDim.new(0,p), PaddingRight=UDim.new(0,p),
    }, o)
end
local function gradient_pro(o, c1, c2, c3, r)
    return make("UIGradient", {
        Color    = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   c1),
            ColorSequenceKeypoint.new(0.5, c2 or c1:Lerp(c3 or c1, 0.5)),
            ColorSequenceKeypoint.new(1,   c3 or c2 or c1),
        }),
        Rotation = r or 90,
    }, o)
end
local function label(p, t, s, b, c)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Text           = t,
        TextColor3     = c or THEME.text,
        Font           = b and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextSize       = s or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent         = p,
    })
end
local function animate_btn(b)
    local o = b.BackgroundColor3
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3=o:Lerp(Color3.new(1,1,1), 0.12)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3=o}):Play()
    end)
end
local function build_logo(p, s)
    return make("ImageLabel", {
        BackgroundTransparency = 1,
        Image     = LOGO_ID,
        Size      = UDim2.new(0, s, 0, s),
        ScaleType = Enum.ScaleType.Fit,
        Parent    = p,
    })
end

-- Ícone genérico — ImageLabel compacto para tabs/botões
local function ico_img(parent, asset_id, sz, pos)
    return make("ImageLabel", {
        BackgroundTransparency = 1,
        Image     = asset_id,
        Size      = UDim2.new(0, sz or 18, 0, sz or 18),
        Position  = pos or UDim2.new(0, 6, 0.5, -(sz or 18)/2),
        ScaleType = Enum.ScaleType.Fit,
        Parent    = parent,
    })
end

-- ══════════════════════════════════════════════════════
-- NOTIFY
-- ══════════════════════════════════════════════════════
local NH = make("Frame", {
    Size               = UDim2.new(0,340,1,-40),
    Position           = UDim2.new(1,-356,0,20),
    BackgroundTransparency = 1,
    Parent             = ScreenGui,
})
make("UIListLayout", {Padding=UDim.new(0,8), HorizontalAlignment=Enum.HorizontalAlignment.Right, SortOrder=Enum.SortOrder.LayoutOrder}, NH)
local nC = 0
local function notify(t, m, k, d)
    nC += 1
    local c = k=="success" and THEME.good or k=="warn" and THEME.warn or k=="error" and THEME.danger or THEME.accent
    local n = make("Frame", {
        LayoutOrder            = -nC,
        Size                   = UDim2.new(1,0,0,0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundColor3       = THEME.bg2,
        BorderSizePixel        = 0,
        Parent                 = NH,
        Position               = UDim2.new(1,40,0,0),
    })
    corner(n, 8); stroke(n, THEME.stroke)
    make("Frame", {Size=UDim2.new(0,4,1,0), BackgroundColor3=c, BorderSizePixel=0, Parent=n})
    local b = make("Frame", {Size=UDim2.new(1,-20,0,0), Position=UDim2.new(0,14,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Parent=n})
    pad(b, 10); make("UIListLayout", {Padding=UDim.new(0,4)}, b)
    local tl = label(b, t, 13, true, c); tl.Size = UDim2.new(1,0,0,16)
    local ml = label(b, m, 12, false, THEME.text); ml.Size = UDim2.new(1,0,0,0); ml.AutomaticSize = Enum.AutomaticSize.Y; ml.TextWrapped = true
    local bg = make("Frame", {Size=UDim2.new(1,-20,0,2), Position=UDim2.new(0,14,1,-6), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=n}); corner(bg,1)
    local bar = make("Frame", {Size=UDim2.new(1,0,1,0), BackgroundColor3=c, BorderSizePixel=0, Parent=bg}); corner(bar,1)
    TweenService:Create(n, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Position=UDim2.new(0,0,0,0)}):Play()
    TweenService:Create(bar, TweenInfo.new(d or 4, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(d or 4, function()
        local tw = TweenService:Create(n, TweenInfo.new(0.3), {Position=UDim2.new(1,40,0,0), BackgroundTransparency=1})
        tw:Play(); tw.Completed:Connect(function() n:Destroy() end)
    end)
end

-- ══════════════════════════════════════════════════════
-- SPLASH
-- ══════════════════════════════════════════════════════
local Splash = make("Frame", {Size=UDim2.new(1,0,1,0), BackgroundColor3=THEME.bg, BorderSizePixel=0, Parent=ScreenGui, ZIndex=1000})
gradient_pro(Splash, THEME.bg, THEME.bg2, THEME.bg, 90)
local sL = build_logo(Splash, 220); sL.Position = UDim2.new(0.5,-110,0.5,-160)
local sT = label(Splash, "carregando...", 14, false, THEME.text2); sT.Size = UDim2.new(0,300,0,20); sT.Position = UDim2.new(0.5,-150,0.5,100); sT.TextXAlignment = Enum.TextXAlignment.Center
local sBg = make("Frame", {Size=UDim2.new(0,300,0,4), Position=UDim2.new(0.5,-150,0.5,130), BackgroundColor3=THEME.card, BorderSizePixel=0, Parent=Splash}); corner(sBg,2)
local sBar = make("Frame", {Size=UDim2.new(0,0,1,0), BackgroundColor3=THEME.accent, BorderSizePixel=0, Parent=sBg}); corner(sBar,2); gradient_pro(sBar, THEME.accent, THEME.accent2, THEME.accent3, 0)
local sP = label(Splash, "0%", 11, false, THEME.text2); sP.Size = UDim2.new(0,300,0,16); sP.Position = UDim2.new(0.5,-150,0.5,140); sP.TextXAlignment = Enum.TextXAlignment.Center
local function run_splash(cb)
    local ph = {"verificando executor...", "carregando módulos...", "conectando backend...", "aplicando anti-trace...", "pronto!"}
    task.spawn(function()
        for i = 1, 5 do
            sT.Text = ph[i]
            TweenService:Create(sBar, TweenInfo.new(1, Enum.EasingStyle.Quint), {Size=UDim2.new(i/5,0,1,0)}):Play()
            for p = i*20-20, i*20 do sP.Text = p.."%"; task.wait(0.05) end
        end
        task.wait(0.3)
        local tw = TweenService:Create(Splash, TweenInfo.new(0.5), {BackgroundTransparency=1})
        tw:Play(); tw.Completed:Connect(function() Splash:Destroy(); cb() end)
    end)
end

-- ══════════════════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════════════════
S = {
    esp      = {on=false, box=true, name=true, hp=true, tracer=false, team=false, chams=false, team_check=true, max_dist=2000},
    fly      = {on=false, speed=60},
    speed    = {on=false, value=50},
    jump     = {on=false, value=80},
    noclip   = {on=false},
    inf_jump = {on=false},
    anti_afk = {on=false},
    fullbright={on=false},
    zoom     = {on=false, value=120},
    anti_slip= {on=false},
    hitbox   = {on=false, size=10},
    freecam  = {on=false, speed=1},
    crosshair= {on=false},
    click_tp = {on=false},
    tp       = {target=""},
    aim      = {on=false, silent=false, fov=120, smooth=0.3, team_check=true, visible_only=false, show_fov=true},
    aim2     = {on=false},
    norecoil = {on=false, threshold=0.018},
    troll    = {follow_target=""},
}

-- ══════════════════════════════════════════════════════
-- NO RECOIL — safe pitch-lock via RenderStepped
-- Intercepta delta de pitch entre frames.
-- threshold=0.018 rad ≈ 1° — ignora input normal do mouse,
-- só cancela spikes de recoil (geralmente 0.05–0.15 rad por frame).
-- ══════════════════════════════════════════════════════
local NoRecoil = {}
do
    local _lastCF = CFrame.new()
    local _conn   = nil

    function NoRecoil.start()
        if _conn then return end
        _conn = RunService.RenderStepped:Connect(function()
            if not S.norecoil.on then return end
            local cf           = Camera.CFrame
            local px, cy, cz   = cf:ToEulerAnglesYXZ()
            local pp, _, _     = _lastCF:ToEulerAnglesYXZ()
            local delta        = math.abs(px - pp)
            if delta > (S.norecoil.threshold or 0.018) then
                -- restaura pitch anterior mantendo yaw+roll
                Camera.CFrame = CFrame.new(cf.Position)
                    * CFrame.fromEulerAnglesYXZ(pp, cy, cz)
            else
                _lastCF = cf
            end
        end)
    end

    function NoRecoil.stop()
        if _conn then _conn:Disconnect(); _conn = nil end
    end

    function NoRecoil.toggle(v)
        S.norecoil.on = v
        if v then NoRecoil.start() else NoRecoil.stop() end
    end
end

-- ══════════════════════════════════════════════════════
-- SILENT AIM
-- ══════════════════════════════════════════════════════
local function in_whitelist(plr_name)
    for _, n in ipairs(CfgDB.aim_whitelist) do if n == plr_name then return true end end
    return false
end

local function get_nearest_head(use_fov)
    local best, bd = nil, (use_fov and S.aim.fov or math.huge)
    local mx, my   = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if S.aim.team_check and plr.Team == LP.Team then continue end
        if in_whitelist(plr.Name) then continue end
        local ch   = plr.Character
        local head = ch and ch:FindFirstChild("Head")
        local h    = ch and ch:FindFirstChildOfClass("Humanoid")
        if not head or not h or h.Health <= 0 then continue end
        local vp, on = Camera:WorldToViewportPoint(head.Position)
        if not on then continue end
        local d = math.sqrt((vp.X-mx)^2 + (vp.Y-my)^2)
        if d < bd then
            if S.aim.visible_only then
                local r = Workspace:Raycast(Camera.CFrame.Position, head.Position - Camera.CFrame.Position)
                if r and not r.Instance:IsDescendantOf(ch) then continue end
            end
            best, bd = head, d
        end
    end
    return best
end

local function get_nearest_visible()
    local best, bd = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local ch   = plr.Character
        local head = ch and ch:FindFirstChild("Head")
        local h    = ch and ch:FindFirstChildOfClass("Humanoid")
        if not head or not h or h.Health <= 0 then continue end
        local ray = Workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 3000)
        if ray and ray.Instance and ray.Instance:IsDescendantOf(ch) then
            local d = (Camera.CFrame.Position - head.Position).Magnitude
            if d < bd then best, bd = head, d end
        end
    end
    return best
end

if hookmetamethod then
    local old; old = hookmetamethod(game, "__namecall", function(self, ...)
        local m    = getnamecallmethod()
        local args = {...}
        if S.aim.silent and not checkcaller() then
            local head = get_nearest_head(true)
            if head then
                if m == "FindPartOnRayWithIgnoreList" or m == "FindPartOnRay" then
                    local o = Camera.CFrame.Position
                    args[1] = Ray.new(o, (head.Position-o).Unit*1000)
                    return old(self, table.unpack(args))
                elseif m == "Raycast" and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                    local o   = args[1]
                    local mag = args[2].Magnitude > 0 and args[2].Magnitude or 1000
                    args[2]   = (head.Position-o).Unit * mag
                    return old(self, table.unpack(args))
                elseif m == "ScreenPointToRay" or m == "ViewportPointToRay" then
                    local r = old(self, table.unpack(args))
                    if typeof(r) == "Ray" then
                        return Ray.new(r.Origin, (head.Position-r.Origin).Unit*1000)
                    end
                end
            end
        end
        return old(self, ...)
    end)
end

local hasMR      = type(mousemoverel) == "function"
local Connections = {}
local function track(c) table.insert(Connections, c); return c end

-- AIM smooth
track(RunService.RenderStepped:Connect(function()
    if not S.aim.on then return end
    local pressing = IS_MOBILE and true or UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if not pressing then return end
    local head = get_nearest_head(true); if not head then return end
    if IS_MOBILE then
        local cur  = Camera.CFrame
        local want = CFrame.lookAt(cur.Position, head.Position)
        local n    = cur:Lerp(want, math.clamp(S.aim.smooth, 0.05, 0.5))
        if cur.LookVector:Dot((head.Position-cur.Position).Unit) > 0.1 then Camera.CFrame = n end
    else
        if hasMR then
            local vp     = Camera:WorldToViewportPoint(head.Position)
            local mx, my = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
            pcall(mousemoverel, (vp.X-mx)*S.aim.smooth, (vp.Y-my)*S.aim.smooth)
        else
            local cur  = Camera.CFrame
            local want = CFrame.lookAt(cur.Position, head.Position)
            local n    = cur:Lerp(want, math.clamp(S.aim.smooth, 0.05, 0.4))
            if cur.LookVector:Dot(n.LookVector) > 0.3 then Camera.CFrame = n end
        end
    end
end))

-- AIM2 lock-on
track(RunService.RenderStepped:Connect(function()
    if not S.aim2.on then return end
    local head = get_nearest_visible(); if not head then return end
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, head.Position)
end))

-- FOV circle
local fovCircle
if type(Drawing) == "table" and Drawing.new then
    fovCircle             = Drawing.new("Circle")
    fovCircle.Thickness   = 1.3
    fovCircle.NumSides    = 60
    fovCircle.Color       = THEME.accent
    fovCircle.Filled      = false
    fovCircle.Transparency= 1
    fovCircle.Visible     = false
end
track(RunService.RenderStepped:Connect(function()
    if not fovCircle then return end
    if (S.aim.on or S.aim.silent) and S.aim.show_fov then
        fovCircle.Radius   = S.aim.fov
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Visible  = true
    else
        fovCircle.Visible = false
    end
end))

-- Crosshair
local chLines = {}
if type(Drawing) == "table" and Drawing.new then
    for _ = 1, 4 do
        local l = Drawing.new("Line"); l.Thickness = 1.5; l.Color = THEME.accent; l.Visible = false
        table.insert(chLines, l)
    end
end
track(RunService.RenderStepped:Connect(function()
    if #chLines == 0 then return end
    local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _, l in ipairs(chLines) do l.Visible = S.crosshair.on end
    if S.crosshair.on then
        local g, ln = 5, 8
        chLines[1].From=Vector2.new(cx,cy-g-ln); chLines[1].To=Vector2.new(cx,cy-g)
        chLines[2].From=Vector2.new(cx,cy+g);    chLines[2].To=Vector2.new(cx,cy+g+ln)
        chLines[3].From=Vector2.new(cx-g-ln,cy); chLines[3].To=Vector2.new(cx-g,cy)
        chLines[4].From=Vector2.new(cx+g,cy);    chLines[4].To=Vector2.new(cx+g+ln,cy)
    end
end))

-- ══════════════════════════════════════════════════════
-- ESP
-- ══════════════════════════════════════════════════════
local ESPData  = {}
local USE_DRAW = type(Drawing) == "table" and Drawing.new

local function new_esp(plr)
    if ESPData[plr] then return end
    local e = {}
    if USE_DRAW then
        e.box      = Drawing.new("Square"); e.box.Thickness=1.5; e.box.Filled=false; e.box.Color=THEME.accent; e.box.Visible=false
        e.name     = Drawing.new("Text");   e.name.Size=14; e.name.Center=true; e.name.Outline=true; e.name.Color=THEME.text; e.name.Font=2; e.name.Visible=false
        e.hp_bg    = Drawing.new("Square"); e.hp_bg.Thickness=1; e.hp_bg.Filled=true; e.hp_bg.Color=Color3.fromRGB(0,0,0); e.hp_bg.Visible=false
        e.hp_fg    = Drawing.new("Square"); e.hp_fg.Thickness=1; e.hp_fg.Filled=true; e.hp_fg.Color=THEME.good; e.hp_fg.Visible=false
        e.tracer   = Drawing.new("Line");   e.tracer.Thickness=1.2; e.tracer.Color=THEME.accent; e.tracer.Visible=false
    end
    e.chams = make("Highlight", {
        FillColor=THEME.accent, FillTransparency=0.7,
        OutlineColor=THEME.text, OutlineTransparency=0,
        Enabled=false, DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,
        Parent=ScreenGui,
    })
    ESPData[plr] = e
end

local function kill_esp(plr)
    local e = ESPData[plr]; if not e then return end
    if e.box then for _, d in pairs({e.box,e.name,e.hp_bg,e.hp_fg,e.tracer}) do pcall(function() d:Remove() end) end end
    if e.chams then e.chams:Destroy() end
    ESPData[plr] = nil
end

track(RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end; new_esp(plr)
        local e    = ESPData[plr]
        local ch   = plr.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        local head = ch and ch:FindFirstChild("Head")
        local h    = ch and ch:FindFirstChildOfClass("Humanoid")
        local alive = S.esp.on and root and head and h and h.Health > 0
        if S.esp.team_check and plr.Team == LP.Team then alive = false end
        local me_root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local dist    = (alive and me_root) and (me_root.Position-root.Position).Magnitude or 999999
        if alive and dist > S.esp.max_dist then alive = false end
        if e.chams then e.chams.Adornee = (alive and S.esp.chams) and ch or nil; e.chams.Enabled = alive and S.esp.chams or false end
        if not e.box then continue end
        if not alive then
            for _, d in pairs({e.box,e.name,e.hp_bg,e.hp_fg,e.tracer}) do d.Visible = false end
        else
            local vp_r, vis = Camera:WorldToViewportPoint(root.Position)
            local vp_h      = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.6,0))
            if not vis then
                for _, d in pairs({e.box,e.name,e.hp_bg,e.hp_fg,e.tracer}) do d.Visible = false end
            else
                local height = (vp_r.Y - vp_h.Y) * 2
                local width  = height * 0.45
                local x, y  = vp_r.X - width/2, vp_h.Y
                local col    = S.esp.team and plr.TeamColor and plr.TeamColor.Color or THEME.accent
                e.box.Size     = Vector2.new(width, height); e.box.Position = Vector2.new(x,y); e.box.Color = col; e.box.Visible = S.esp.box
                e.name.Text    = plr.Name.." ["..math.floor(dist).."m]"; e.name.Position = Vector2.new(vp_r.X, y-16); e.name.Visible = S.esp.name
                if S.esp.hp then
                    local frac = math.clamp(h.Health/h.MaxHealth, 0, 1)
                    local bx   = x - 6
                    e.hp_bg.Size=Vector2.new(3,height); e.hp_bg.Position=Vector2.new(bx,y); e.hp_bg.Visible=true
                    e.hp_fg.Size=Vector2.new(3,height*frac); e.hp_fg.Position=Vector2.new(bx,y+height*(1-frac))
                    e.hp_fg.Color   = Color3.fromRGB(math.floor(255*(1-frac)), math.floor(255*frac), 40); e.hp_fg.Visible=true
                else
                    e.hp_bg.Visible=false; e.hp_fg.Visible=false
                end
                if S.esp.tracer then
                    e.tracer.From    = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    e.tracer.To      = Vector2.new(vp_r.X, vp_r.Y+height/2)
                    e.tracer.Color   = col; e.tracer.Visible = true
                else
                    e.tracer.Visible = false
                end
            end
        end
    end
end))
track(Players.PlayerRemoving:Connect(kill_esp))

-- ══════════════════════════════════════════════════════
-- FEATURES / MISC  (antigo Movimento)
-- ══════════════════════════════════════════════════════
local function hrp() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local bg_fly, bv_fly
local function stop_fly() if bg_fly then bg_fly:Destroy(); bg_fly=nil end; if bv_fly then bv_fly:Destroy(); bv_fly=nil end end
local function start_fly()
    stop_fly(); local r = hrp(); if not r then return end
    bg_fly = Instance.new("BodyGyro", r); bg_fly.Name="_"; bg_fly.P=9e4; bg_fly.MaxTorque=Vector3.new(9e9,9e9,9e9); bg_fly.CFrame=r.CFrame
    bv_fly = Instance.new("BodyVelocity", r); bv_fly.Name="_"; bv_fly.MaxForce=Vector3.new(9e9,9e9,9e9); bv_fly.Velocity=Vector3.zero
end

track(RunService.Heartbeat:Connect(function()
    if S.fly.on and bg_fly and bv_fly then
        bg_fly.CFrame = Camera.CFrame
        local mv = Vector3.zero
        if UserInput:IsKeyDown(Enum.KeyCode.W)     then mv += Camera.CFrame.LookVector  end
        if UserInput:IsKeyDown(Enum.KeyCode.S)     then mv -= Camera.CFrame.LookVector  end
        if UserInput:IsKeyDown(Enum.KeyCode.D)     then mv += Camera.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.A)     then mv -= Camera.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.Space) then mv += Vector3.new(0,1,0) end
        if UserInput:IsKeyDown(Enum.KeyCode.Q)     then mv -= Vector3.new(0,1,0) end
        if mv.Magnitude > 0 then mv = mv.Unit * S.fly.speed end
        bv_fly.Velocity = mv
    end
    if S.speed.on  then local h=hum(); if h and h.WalkSpeed~=S.speed.value then h.WalkSpeed=S.speed.value end end
    if S.jump.on   then local h=hum(); if h and h.JumpPower~=S.jump.value  then h.JumpPower=S.jump.value  end end
    if S.hitbox.on then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if r then r.Size=Vector3.new(S.hitbox.size,S.hitbox.size,S.hitbox.size); r.Transparency=0.7; r.CanCollide=false end
            end
        end
    end
end))

track(RunService.Stepped:Connect(function()
    if S.noclip.on then
        local c = LP.Character; if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
    end
end))
track(UserInput.JumpRequest:Connect(function()
    if S.inf_jump.on then local h=hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end))

local origL = {Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient, FogEnd=Lighting.FogEnd, Brightness=Lighting.Brightness}
local function apply_fullbright(v)
    if v then Lighting.Ambient=Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255); Lighting.FogEnd=1e6; Lighting.Brightness=3
    else Lighting.Ambient=origL.Ambient; Lighting.OutdoorAmbient=origL.OutdoorAmbient; Lighting.FogEnd=origL.FogEnd; Lighting.Brightness=origL.Brightness end
end
track(RunService.RenderStepped:Connect(function() if S.zoom.on then Camera.FieldOfView=S.zoom.value end end))
track(LP.Idled:Connect(function()
    if S.anti_afk.on then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end
end))

local fc_cf, fc_type
local function toggle_freecam(v)
    S.freecam.on = v
    if v then fc_type=Camera.CameraType; Camera.CameraType=Enum.CameraType.Scriptable; fc_cf=Camera.CFrame
    else if fc_type then Camera.CameraType=fc_type end; fc_cf=nil end
end
track(RunService.RenderStepped:Connect(function(dt)
    if not S.freecam.on or not fc_cf then return end
    local mv = Vector3.zero
    if UserInput:IsKeyDown(Enum.KeyCode.W) then mv+=fc_cf.LookVector  end
    if UserInput:IsKeyDown(Enum.KeyCode.S) then mv-=fc_cf.LookVector  end
    if UserInput:IsKeyDown(Enum.KeyCode.D) then mv+=fc_cf.RightVector end
    if UserInput:IsKeyDown(Enum.KeyCode.A) then mv-=fc_cf.LookVector  end
    if UserInput:IsKeyDown(Enum.KeyCode.E) then mv+=Vector3.new(0,1,0) end
    if UserInput:IsKeyDown(Enum.KeyCode.Q) then mv-=Vector3.new(0,1,0) end
    fc_cf = fc_cf + mv * S.freecam.speed * 50 * dt; Camera.CFrame = fc_cf
end))

track(UserInput.InputBegan:Connect(function(input, gpe)
    if not S.click_tp.on or gpe then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    local m = LP:GetMouse(); if m.Hit then local r=hrp(); if r then r.CFrame=CFrame.new(m.Hit.Position+Vector3.new(0,3,0)) end end
end))

local function tp_to(cf) local r=hrp(); if r then r.CFrame=cf end end
local function tp_player(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Name:lower():find(name:lower(), 1, true) then
            local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if r then tp_to(r.CFrame+Vector3.new(2,0,0)); notify("TP","teleportou pra "..p.Name,"success",2) end
            return
        end
    end
    notify("TP","não encontrado","error")
end

local function scan_tools()
    local out = {}; local roots = {RepStorage, Workspace}
    for _, t in ipairs(Teams:GetChildren()) do table.insert(roots, t) end
    for _, p in ipairs(Players:GetPlayers()) do if p.Backpack then table.insert(roots, p.Backpack) end end
    for _, root in ipairs(roots) do
        for _, d in ipairs(root:GetDescendants()) do if d:IsA("Tool") then table.insert(out,d) end end
    end
    return out
end
local function grab(t) local bp=LP:FindFirstChildOfClass("Backpack"); if bp and t.Parent~=bp then pcall(function() t.Parent=bp end) end end

local orig_trans = {}
local function set_invisible(v)
    local c = LP.Character; if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
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
    local r = hrp(); if not r then return end
    spinBV = Instance.new("BodyAngularVelocity", r); spinBV.Name="_"; spinBV.MaxTorque=Vector3.new(0,math.huge,0); spinBV.AngularVelocity=Vector3.new(0,20,0)
end

local function fling_player(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Name:lower():find(name:lower(), 1, true) then
            local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local b = Instance.new("BodyVelocity", r); b.Name="_"; b.MaxForce=Vector3.new(9e9,9e9,9e9)
                b.Velocity = Vector3.new(math.random(-2000,2000), 3000, math.random(-2000,2000))
                task.delay(0.5, function() b:Destroy() end)
                notify("Fling", p.Name.." foi arremessado","success",2)
            end
            return
        end
    end
    notify("Fling","player não encontrado","error")
end

-- Follow
track(RunService.Heartbeat:Connect(function()
    if S.troll.follow_target == "" then return end
    local tgt
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Name:lower():find(S.troll.follow_target:lower(), 1, true) then tgt=p; break end
    end
    if not tgt then return end
    local tr = tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart")
    local r  = hrp()
    if tr and r then r.CFrame = tr.CFrame * CFrame.new(0,0,3) end
end))

-- ══════════════════════════════════════════════════════
-- REMOTES
-- ══════════════════════════════════════════════════════
local function scan_remotes()
    local out = {}
    local function scan(root)
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                table.insert(out, {ref=d, name=d.Name, type=d.ClassName, path=d:GetFullName()})
            end
        end
    end
    scan(RepStorage); scan(Workspace)
    return out
end

local function fire_remote(rem, args_str)
    local args = {}
    for part in args_str:gmatch("[^,]+") do
        part = part:match("^%s*(.-)%s*$")
        if tonumber(part)    then table.insert(args, tonumber(part))
        elseif part=="true"  then table.insert(args, true)
        elseif part=="false" then table.insert(args, false)
        else                      table.insert(args, part) end
    end
    local ok, err = pcall(function()
        if rem:IsA("RemoteEvent") then rem:FireServer(table.unpack(args))
        else return rem:InvokeServer(table.unpack(args)) end
    end)
    return ok, err
end

-- ══════════════════════════════════════════════════════
-- MONEY
-- ══════════════════════════════════════════════════════
local MONEY_WORDS = {"money","cash","coin","gold","gem","dollar","credit","bux","robux","token","diamond","bank","wallet","buy","purchase","reward","claim","give","add","grant","earn"}

local function auto_money_exploit(value)
    local tried=0; local names={}
    for _, r in ipairs(scan_remotes()) do
        local low = r.name:lower()
        for _, w in ipairs(MONEY_WORDS) do
            if low:find(w, 1, true) then
                pcall(function() fire_remote(r.ref, tostring(value)) end)
                pcall(function() if r.ref:IsA("RemoteEvent") then r.ref:FireServer(value) end end)
                pcall(function() if r.ref:IsA("RemoteEvent") then r.ref:FireServer(LP,value) end end)
                pcall(function() if r.ref:IsA("RemoteEvent") then r.ref:FireServer("add",value) end end)
                pcall(function() if r.ref:IsA("RemoteFunction") then r.ref:InvokeServer(value) end end)
                tried+=1; table.insert(names, r.name); break
            end
        end
    end
    return tried, names
end

local function direct_money_set(value)
    local changed = 0
    local function try_set(folder)
        if not folder then return end
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then pcall(function() v.Value=value; changed+=1 end) end
        end
    end
    try_set(LP:FindFirstChild("leaderstats")); try_set(LP:FindFirstChild("PlayerStats"))
    try_set(LP:FindFirstChild("Stats")); try_set(LP:FindFirstChild("Data"))
    return changed
end

local function scan_leaderstats()
    local out={}
    local function sf(f,p)
        if not f then return end
        for _, v in ipairs(f:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue") then
                table.insert(out, {name=p..v.Name, ref=v, type=v.ClassName})
            end
        end
    end
    sf(LP:FindFirstChild("leaderstats"),"leaderstats/"); sf(LP:FindFirstChild("PlayerStats"),"PlayerStats/")
    sf(LP:FindFirstChild("Stats"),"Stats/"); sf(LP:FindFirstChild("Data"),"Data/")
    return out
end

-- ══════════════════════════════════════════════════════
-- SERVER / ANTICHEAT ANALYZER
-- ══════════════════════════════════════════════════════
local ANALYZER_CHECKS = {
    {name="Fly",              fn=function() return true end,           note="BodyVelocity disponível"},
    {name="Speed",            fn=function() return true end,           note="via Humanoid.WalkSpeed"},
    {name="Noclip",           fn=function() return true end,           note="via CanCollide local"},
    {name="Silent Aim",       fn=function() return hookmetamethod~=nil end, note=hookmetamethod and "hookmetamethod disponível" or "executor sem hookmetamethod"},
    {name="ESP Drawing",      fn=function() return type(Drawing)=="table" and Drawing.new~=nil end, note=type(Drawing)=="table" and "Drawing API ok" or "sem Drawing"},
    {name="Anti-AFK",         fn=function() local ok,_=pcall(function() return game:GetService("VirtualUser") end); return ok end, note="VirtualUser acessível"},
    {name="Remote Spy/Money", fn=function() local ok=pcall(function() RepStorage:GetDescendants() end); return ok end, note="acesso a RepStorage ok"},
    {name="Direct Money Set", fn=function() local ls=LP:FindFirstChild("leaderstats"); if not ls then return false end; local v=ls:GetChildren()[1]; if not v then return false end; local ok=pcall(function() v.Value=v.Value end); return ok end, note="leaderstats writable"},
    {name="Filesystem",       fn=function() return FS_OK end,          note=FS_OK and "writefile/readfile ok" or "executor sem fs"},
    {name="SaveInstance",     fn=function() return type(saveinstance)=="function" or (syn and type(syn.saveinstance)=="function") end, note="saveinstance disponível"},
    {name="Chams (Highlight)",fn=function() local ok,_=pcall(function() local h=Instance.new("Highlight"); h:Destroy() end); return ok end, note="Highlight instanciável"},
}

local function run_server_analysis(statusLabel, resultContainer)
    statusLabel.Text = "calculando compatibilidade..."
    for _, c in ipairs(resultContainer:GetChildren()) do if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end end
    task.spawn(function()
        local acName, acLevel = ACDetector.scan()
        local acRow = make("Frame",{BackgroundColor3=Color3.fromRGB(15,15,30),BorderSizePixel=0,Size=UDim2.new(1,0,0,38),Parent=resultContainer}); corner(acRow,4)
        local acl = label(acRow,"  AntiCheat: "..acName,12,true, acLevel:find("ALTO") and THEME.danger or acLevel:find("MÉDIO") and THEME.warn or THEME.good)
        acl.Position=UDim2.new(0,4,0,4); acl.Size=UDim2.new(1,-8,0,16)
        local acll = label(acRow,"  Nível de risco: "..acLevel,11,false,THEME.text2); acll.Position=UDim2.new(0,4,0,22); acll.Size=UDim2.new(1,-8,0,14)
        local pass, fail = 0, 0
        for _, chk in ipairs(ANALYZER_CHECKS) do
            task.wait(0.08)
            local ok=false; pcall(function() ok=chk.fn() end)
            if ok then pass+=1 else fail+=1 end
            local row=make("Frame",{BackgroundColor3=ok and Color3.fromRGB(20,40,20) or Color3.fromRGB(40,15,15),BorderSizePixel=0,Size=UDim2.new(1,0,0,26),Parent=resultContainer}); corner(row,4)
            local dot=make("Frame",{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,8,0.5,-4),BackgroundColor3=ok and THEME.good or THEME.danger,BorderSizePixel=0,Parent=row}); corner(dot,4)
            local nm=label(row,chk.name,11,true,ok and THEME.good or THEME.danger); nm.Position=UDim2.new(0,24,0,2); nm.Size=UDim2.new(0,120,0,14)
            local nt=label(row,chk.note,10,false,THEME.text2); nt.Position=UDim2.new(0,150,0,2); nt.Size=UDim2.new(1,-158,1,0); nt.TextWrapped=true
        end
        statusLabel.Text = pass.." compatíveis   "..fail.." indisponíveis"
        statusLabel.TextColor3 = fail==0 and THEME.good or (pass>fail and THEME.warn or THEME.danger)
    end)
end

-- ══════════════════════════════════════════════════════
-- MISC / WIPE
-- ══════════════════════════════════════════════════════
local function rejoin() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end
local function server_hop()
    task.spawn(function()
        local ok, data = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if not ok or not data or not data.data then notify("Hop","sem servidores","error"); return end
        for _, s in ipairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP) end)
                return
            end
        end
        notify("Hop","nenhum livre","warn")
    end)
end

local function try_saveinstance()
    local fn = saveinstance or (syn and syn.saveinstance); if not fn then return false,"executor sem saveinstance" end
    task.spawn(function() pcall(function() pcall(fn, {mode="optimized",noscripts=false}) end) end)
    return true,"disparado em background"
end

local function wipe_traces()
    for _, cat in pairs(S) do
        if type(cat)=="table" then
            if cat.on~=nil      then cat.on=false end
            if cat.silent~=nil  then cat.silent=false end
        end
    end
    S.troll.follow_target=""
    stop_fly(); god_mode(false); do_spin(false); set_invisible(false); apply_fullbright(false); toggle_freecam(false)
    Camera.FieldOfView=70; NoRecoil.stop()
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end; Connections={}
    for p in pairs(ESPData) do kill_esp(p) end
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    for _, l in ipairs(chLines) do pcall(function() l:Remove() end) end
    local c = LP.Character
    if c then for _, d in ipairs(c:GetDescendants()) do
        if (d:IsA("BodyGyro") or d:IsA("BodyVelocity") or d:IsA("BodyAngularVelocity")) and d.Name=="_" then d:Destroy() end
    end end
    if FS_OK then for _, p in ipairs({P_KEYS,P_USERS,P_SESS,P_CFG}) do pcall(function() delfile(p) end) end end
    pcall(function()
        for _, n in ipairs({"pkMenu","pkFly","pkSpd","pkTp","pkStr","pkSil","pkBlock","pkMenuK"}) do CAS:UnbindAction(n) end
    end)
    ScreenGui:Destroy()
end

local StreamOn = false
local function apply_stream() ScreenGui.Enabled = not StreamOn end

-- ══════════════════════════════════════════════════════
-- MENU BUILD
-- ══════════════════════════════════════════════════════
local MainRoot, InputBlocker, menuVisible, minBubble

local function build_menu(current_user, is_admin)

InputBlocker = make("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Active=true,Visible=false,ZIndex=1,Parent=ScreenGui})
local blockKeys={Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Space,Enum.KeyCode.E,Enum.KeyCode.Q,Enum.KeyCode.R,Enum.KeyCode.F,Enum.KeyCode.T,Enum.KeyCode.G,Enum.KeyCode.H}
local function set_input_block(on)
    InputBlocker.Visible=on
    if on then pcall(function() CAS:BindActionAtPriority("pkBlock",function() return Enum.ContextActionResult.Sink end,false,3000,table.unpack(blockKeys)) end)
    else pcall(function() CAS:UnbindAction("pkBlock") end) end
end

MainRoot = make("Frame",{
    Name="Main", Active=true, Draggable=true,
    Size      = UDim2.new(0, IS_MOBILE and 740 or 960, 0, IS_MOBILE and 480 or 600),
    Position  = UDim2.new(0.5,-(IS_MOBILE and 370 or 480), 0.5,-(IS_MOBILE and 240 or 300)),
    BackgroundColor3 = THEME.bg, BorderSizePixel=0, BackgroundTransparency=CfgDB.transparency,
    Parent=ScreenGui,
})
corner(MainRoot,12); stroke(MainRoot,THEME.accent,1.5); gradient_pro(MainRoot,THEME.bg,THEME.bg2,THEME.bg,90)

local Side = make("Frame",{Size=UDim2.new(0,220,1,0),BackgroundColor3=THEME.bg2,BorderSizePixel=0,BackgroundTransparency=CfgDB.transparency*0.5,Parent=MainRoot})
corner(Side,12); gradient_pro(Side,THEME.bg2,THEME.bg,THEME.bg2,180)
make("Frame",{Size=UDim2.new(0,2,1,0),Position=UDim2.new(1,-2,0,0),BackgroundColor3=THEME.accent,BorderSizePixel=0,Parent=Side})
local sLogo = build_logo(Side,130); sLogo.Position = UDim2.new(0.5,-65,0,8)

local TabArea = make("ScrollingFrame",{
    Size=UDim2.new(1,-20,1,-170), Position=UDim2.new(0,10,0,150),
    BackgroundTransparency=1, BorderSizePixel=0,
    CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=Side,
})
make("UIListLayout",{Padding=UDim.new(0,4)},TabArea)

local Content = make("Frame",{Size=UDim2.new(1,-230,1,-20),Position=UDim2.new(0,225,0,10),BackgroundTransparency=1,Parent=MainRoot})
local TopBar  = make("Frame",{Size=UDim2.new(1,0,0,46),BackgroundTransparency=1,Parent=Content})
local TitleLbl = label(TopBar,"Início",18,true); TitleLbl.Size=UDim2.new(1,-220,1,0); TitleLbl.TextColor3=THEME.text
local UserLbl  = label(TopBar,current_user..(is_admin and "  [ADMIN]" or ""),12,true,THEME.accent); UserLbl.Size=UDim2.new(0,180,0,16); UserLbl.Position=UDim2.new(1,-260,0,8); UserLbl.TextXAlignment=Enum.TextXAlignment.Right
local ExpLbl   = label(TopBar,"",11,false,THEME.text2); ExpLbl.Size=UDim2.new(0,180,0,14); ExpLbl.Position=UDim2.new(1,-260,0,26); ExpLbl.TextXAlignment=Enum.TextXAlignment.Right
local u = UserDB[current_user]
if u.exp == -1 then ExpLbl.Text="lifetime"; ExpLbl.TextColor3=THEME.good
else
    local left = math.max(0,(u.exp or 0)-os.time())
    ExpLbl.Text = string.format("expira em %dd %dh", math.floor(left/86400), math.floor((left%86400)/3600))
end

-- ── BOTÃO MINIMIZAR — ImageLabel olho fechado (hide) ──
local MinBtn = make("ImageButton",{
    Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-74,0,8),
    BackgroundColor3=THEME.card, Image=ICO.hide,
    BorderSizePixel=0, AutoButtonColor=false, Parent=TopBar,
}); corner(MinBtn,15); stroke(MinBtn,THEME.warn); animate_btn(MinBtn)

-- ── BOTÃO FECHAR — ImageLabel X Roblox ──
local CloseBtn = make("ImageButton",{
    Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-38,0,8),
    BackgroundColor3=THEME.card, Image=ICO.close,
    BorderSizePixel=0, AutoButtonColor=false, Parent=TopBar,
}); corner(CloseBtn,15); stroke(CloseBtn,THEME.accent); animate_btn(CloseBtn)

MinBtn.MouseButton1Click:Connect(function()
    MainRoot.Visible=false; menuVisible=false; set_input_block(false)
    minBubble = make("ImageButton",{Size=UDim2.new(0,64,0,64),Position=UDim2.new(0,20,0.5,-32),BackgroundTransparency=1,Image=LOGO_ID,Parent=ScreenGui})
    minBubble.MouseButton1Click:Connect(function()
        minBubble:Destroy(); minBubble=nil; MainRoot.Visible=true; menuVisible=true; set_input_block(true)
    end)
end)
CloseBtn.MouseButton1Click:Connect(function() MainRoot.Visible=false; menuVisible=false; set_input_block(false) end)

local Pages = make("Frame",{Size=UDim2.new(1,0,1,-56),Position=UDim2.new(0,0,0,54),BackgroundTransparency=1,Parent=Content})
local tabs  = {}

local function section_header(txt)
    local l = label(TabArea,"  "..txt,10,true,THEME.text2); l.Size=UDim2.new(1,0,0,18)
end

-- make_tab: usa ImageLabel ao invés de emoji
local function make_tab(name, icon_id)
    local b = make("TextButton",{BackgroundColor3=THEME.bg,BorderSizePixel=0,Text="",AutoButtonColor=false,Size=UDim2.new(1,0,0,36),Parent=TabArea}); corner(b,6)
    local ico = ico_img(b, icon_id, 18, UDim2.new(0,8,0.5,-9))
    local lb  = label(b, name, 13, false, THEME.text2); lb.Size=UDim2.new(1,-38,1,0); lb.Position=UDim2.new(0,32,0,0); lb.Font=Enum.Font.GothamMedium
    local page= make("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=THEME.accent,Visible=false,Parent=Pages}); pad(page,2)
    tabs[name] = {btn=b, page=page, lb=lb, ico=ico}
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.page.Visible=false; t.btn.BackgroundColor3=THEME.bg
            t.lb.TextColor3=THEME.text2
            t.ico.ImageColor3=Color3.fromRGB(145,145,150)
        end
        page.Visible=true
        TweenService:Create(b,TweenInfo.new(0.2),{BackgroundColor3=THEME.accent}):Play()
        lb.TextColor3=THEME.text; ico.ImageColor3=THEME.text; TitleLbl.Text=name
    end)
    b.MouseEnter:Connect(function() if not page.Visible then TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=THEME.card}):Play() end end)
    b.MouseLeave:Connect(function() if not page.Visible then TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=THEME.bg}):Play() end end)
    return page
end

-- ══ WIDGETS ══
local function card(parent, title)
    local c = make("Frame",{BackgroundColor3=THEME.card,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=parent,BackgroundTransparency=CfgDB.transparency*0.3}); corner(c,8); stroke(c,THEME.stroke)
    local head=make("Frame",{Size=UDim2.new(1,0,0,32),BackgroundColor3=THEME.card2,BorderSizePixel=0,Parent=c}); corner(head,8)
    make("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BackgroundColor3=THEME.card2,BorderSizePixel=0,Parent=head})
    make("Frame",{Size=UDim2.new(0,3,0,18),Position=UDim2.new(0,0,0.5,-9),BackgroundColor3=THEME.accent,BorderSizePixel=0,Parent=head})
    label(head,"   "..title,12,true).Size=UDim2.new(1,-8,1,0)
    local body=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-20,0,0),Position=UDim2.new(0,10,0,40),AutomaticSize=Enum.AutomaticSize.Y,Parent=c}); make("UIListLayout",{Padding=UDim.new(0,6)},body)
    body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() c.Size=UDim2.new(1,0,0,body.AbsoluteSize.Y+52) end)
    return body
end
local function two(parent)
    local f=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=parent})
    local L=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=f})
    local R=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(0.5,4,0,0),Parent=f})
    make("UIListLayout",{Padding=UDim.new(0,8)},L); make("UIListLayout",{Padding=UDim.new(0,8)},R)
    local function sync() f.Size=UDim2.new(1,0,0,math.max(L.AbsoluteSize.Y,R.AbsoluteSize.Y)) end
    L:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync); R:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync)
    return L, R
end
local function dual(parent)
    local h=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=parent}); make("UIListLayout",{Padding=UDim.new(0,8)},h); return h
end
local function tgl(parent, name, def, cb, sub)
    local h = sub and 50 or 36
    local c = make("Frame",{BackgroundColor3=THEME.card2,BorderSizePixel=0,Size=UDim2.new(1,0,0,h),Parent=parent}); corner(c,6)
    local lb= label(c,name,12,true); lb.Position=UDim2.new(0,10,0,sub and 6 or 0); lb.Size=UDim2.new(1,-70,0,16)
    if not sub then lb.Size=UDim2.new(1,-70,1,0) end
    if sub then local s=label(c,sub,10,false,THEME.text2); s.Position=UDim2.new(0,10,0,26); s.Size=UDim2.new(1,-70,0,14) end
    local sw=make("TextButton",{Size=UDim2.new(0,42,0,22),Position=UDim2.new(1,-52,0.5,-11),BackgroundColor3=def and THEME.accent or THEME.bg,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=c}); corner(sw,11)
    local k=make("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(def and 1 or 0,def and -19 or 3,0.5,-8),BackgroundColor3=THEME.text,BorderSizePixel=0,Parent=sw}); corner(k,8)
    local v=def
    sw.MouseButton1Click:Connect(function()
        v=not v
        TweenService:Create(sw,TweenInfo.new(0.2),{BackgroundColor3=v and THEME.accent or THEME.bg}):Play()
        TweenService:Create(k,TweenInfo.new(0.2),{Position=UDim2.new(v and 1 or 0,v and -19 or 3,0.5,-8)}):Play()
        if cb then cb(v) end
    end)
    return c
end
local function sld(parent, name, mn, mx, def, cb)
    local c=make("Frame",{BackgroundColor3=THEME.card2,BorderSizePixel=0,Size=UDim2.new(1,0,0,52),Parent=parent}); corner(c,6)
    local n=label(c,name,12); n.Position=UDim2.new(0,10,0,6); n.Size=UDim2.new(1,-60,0,16)
    local vl=label(c,tostring(def),12,true,THEME.accent); vl.Size=UDim2.new(0,50,0,16); vl.Position=UDim2.new(1,-60,0,6); vl.TextXAlignment=Enum.TextXAlignment.Right
    local bar=make("Frame",{Size=UDim2.new(1,-20,0,6),Position=UDim2.new(0,10,0,32),BackgroundColor3=THEME.bg,BorderSizePixel=0,Parent=c}); corner(bar,3)
    local fill=make("Frame",{Size=UDim2.new((def-mn)/(mx-mn),0,1,0),BackgroundColor3=THEME.accent,BorderSizePixel=0,Parent=bar}); corner(fill,3); gradient_pro(fill,THEME.accent,THEME.accent2,THEME.accent3,0)
    local kk=make("TextButton",{Size=UDim2.new(0,14,0,14),Position=UDim2.new((def-mn)/(mx-mn),-7,0.5,-7),BackgroundColor3=THEME.text,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=bar}); corner(kk,7)
    local drag=false
    kk.MouseButton1Down:Connect(function() drag=true end)
    kk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=true end end)
    UserInput.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    UserInput.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
        local rel=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        TweenService:Create(fill,TweenInfo.new(0.08),{Size=UDim2.new(rel,0,1,0)}):Play()
        TweenService:Create(kk,TweenInfo.new(0.08),{Position=UDim2.new(rel,-7,0.5,-7)}):Play()
        local v2=math.floor(mn+(mx-mn)*rel+0.5); vl.Text=tostring(v2); if cb then cb(v2) end
    end)
end
local function wbtn(parent, name, color, cb, sub)
    local h = sub and 46 or 36
    local b=make("TextButton",{BackgroundColor3=color or THEME.accent,BorderSizePixel=0,Size=UDim2.new(1,0,0,h),Text="",AutoButtonColor=false,Parent=parent}); corner(b,6)
    if color==nil then gradient_pro(b,THEME.accent,THEME.accent2,THEME.accent3,90) end
    local lb=label(b,name,13,true); lb.Size=UDim2.new(1,-20,0,16); lb.Position=UDim2.new(0,10,0,sub and 6 or 0)
    if not sub then lb.Size=UDim2.new(1,-20,1,0); lb.TextXAlignment=Enum.TextXAlignment.Center end
    if sub then local s=label(b,sub,10,false,Color3.fromRGB(230,230,230)); s.Size=UDim2.new(1,-20,0,14); s.Position=UDim2.new(0,10,0,26) end
    b.MouseButton1Click:Connect(cb); animate_btn(b); return b
end
local function winp(parent, ph)
    local c=make("Frame",{BackgroundColor3=THEME.card2,BorderSizePixel=0,Size=UDim2.new(1,0,0,36),Parent=parent}); corner(c,6)
    local b=make("TextBox",{BackgroundTransparency=1,Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,10,0,0),PlaceholderText=ph,PlaceholderColor3=THEME.text2,TextColor3=THEME.text,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Text="",ClearTextOnFocus=false,Parent=c})
    return b
end
local function ddn(parent, name, options, cb)
    local c=make("Frame",{BackgroundColor3=THEME.card2,BorderSizePixel=0,Size=UDim2.new(1,0,0,40),Parent=parent}); corner(c,6)
    local n=label(c,name,12); n.Position=UDim2.new(0,10,0,0); n.Size=UDim2.new(1,-170,1,0)
    local b=make("TextButton",{Size=UDim2.new(0,150,0,26),Position=UDim2.new(1,-160,0.5,-13),BackgroundColor3=THEME.bg,BorderSizePixel=0,Text=options[1].label,TextColor3=THEME.text,Font=Enum.Font.Gotham,TextSize=12,Parent=c}); corner(b,4); stroke(b,THEME.stroke)
    local list
    b.MouseButton1Click:Connect(function()
        if list then list:Destroy(); list=nil; return end
        list=make("Frame",{Size=UDim2.new(0,150,0,#options*26+4),Position=UDim2.new(1,-160,1,4),BackgroundColor3=THEME.bg,BorderSizePixel=0,ZIndex=50,Parent=c}); corner(list,4); stroke(list,THEME.accent)
        make("UIListLayout",{Padding=UDim.new(0,2)},list); pad(list,2)
        for _,opt in ipairs(options) do
            local ob=make("TextButton",{Size=UDim2.new(1,0,0,22),BackgroundColor3=THEME.card2,BorderSizePixel=0,Text=opt.label,TextColor3=THEME.text,Font=Enum.Font.Gotham,TextSize=12,ZIndex=51,Parent=list}); corner(ob,3)
            ob.MouseButton1Click:Connect(function() b.Text=opt.label; if cb then cb(opt) end; list:Destroy(); list=nil end)
        end
    end)
end

-- ══ TABS ══
section_header("JOGO")
local pInicio  = make_tab("Início",    ICO.home)
local pAim     = make_tab("Aimbot",    ICO.target)
local pESP     = make_tab("ESP",       ICO.eye_open)
local pMisc    = make_tab("Misc",      ICO.misc)       -- antigo "Movimento"
local pTP      = make_tab("Teleporte", ICO.tp)
section_header("EXTRAS")
local pArmas   = make_tab("Armas",     ICO.gun)
local pServidor= make_tab("Servidor",  ICO.server)
local pMoney   = make_tab("Money",     ICO.money)
local pSpy     = make_tab("Remote Spy",ICO.spy)
section_header("SEGURANÇA")
local pBypass  = make_tab("Bypass",    ICO.bypass)
local pCfg     = make_tab("Config",    ICO.gear)
local pKeys, pLogs
if is_admin then
    section_header("ADMIN")
    pKeys = make_tab("Keys", ICO.key)
    pLogs = make_tab("Logs", ICO.doc)
end

-- ══════════════════════════════════════════════════════
-- PAGE: INÍCIO
-- ══════════════════════════════════════════════════════
do
    local list=dual(pInicio); local L,R=two(list)
    local uc=card(L,"Conta Roblox")
    local hol=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,100),Parent=uc})
    local av=make("ImageLabel",{BackgroundColor3=THEME.bg,BorderSizePixel=0,Size=UDim2.new(0,90,0,90),Position=UDim2.new(0,0,0,5),Parent=hol}); corner(av,45); stroke(av,THEME.accent,2)
    task.spawn(function()
        local ok,c=pcall(function() return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end)
        if ok then av.Image=c end
    end)
    local nm=label(hol,"@"..LP.Name,14,true); nm.Size=UDim2.new(1,-110,0,18); nm.Position=UDim2.new(0,105,0,10)
    local dn=label(hol,LP.DisplayName,12,false,THEME.text2); dn.Size=UDim2.new(1,-110,0,16); dn.Position=UDim2.new(0,105,0,30)
    local idl=label(hol,"ID: "..LP.UserId,11,false,THEME.text2); idl.Size=UDim2.new(1,-110,0,14); idl.Position=UDim2.new(0,105,0,48)
    local agl=label(hol,LP.AccountAge.." dias",11,false,THEME.text2); agl.Size=UDim2.new(1,-110,0,14); agl.Position=UDim2.new(0,105,0,66)
    local pl=card(L,"Plano")
    label(pl,"Usuário: "..current_user,12,true).Size=UDim2.new(1,0,0,16)
    label(pl,"Key: "..(u.key or "—"),11,false,THEME.text2).Size=UDim2.new(1,0,0,16)
    label(pl,"Validade: "..(u.exp==-1 and "LIFETIME" or (u.exp and os.date("%d/%m/%Y",u.exp) or "?")),11,false,THEME.text2).Size=UDim2.new(1,0,0,16)
    local q=card(R,"Ações rápidas")
    wbtn(q,"Combo (ESP+Fly+Speed)",nil,function() S.esp.on=true; S.fly.on=true; start_fly(); S.speed.on=true; notify("Combo","3 features ligadas","success") end)
    wbtn(q,"Desligar tudo",THEME.card2,function() S.esp.on=false; S.fly.on=false; stop_fly(); S.speed.on=false; local h=hum(); if h then h.WalkSpeed=16 end end)
    wbtn(q,"Rejoin",THEME.card2,rejoin)
    wbtn(q,"Server Hop",THEME.card2,server_hop)
    local st=card(R,"Servidor")
    local s1=label(st,"Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers,12); s1.Size=UDim2.new(1,0,0,16)
    label(st,"Executor: "..EXE,11,false,THEME.text2).Size=UDim2.new(1,0,0,14)
    task.spawn(function() while MainRoot.Parent do s1.Text="Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers; task.wait(3) end end)
    if is_admin then
        local stCard=card(R,"Status Premium")
        wbtn(stCard,"Enviar status agora",nil,function()
            send_status_premium(current_user,is_admin)
            notify("Status","embed Premium enviado","success",2)
        end,"formato verde/amarelo/vermelho igual canal #status")
        label(stCard,"Visível apenas para Admin",10,false,THEME.warn).Size=UDim2.new(1,0,0,14)
    end
end

-- ══════════════════════════════════════════════════════
-- PAGE: AIMBOT  — inclui No Recoil
-- ══════════════════════════════════════════════════════
do
    local list=dual(pAim); local L,R=two(list)

    -- Aimbot smooth
    local c=card(L,"Aimbot Smooth")
    tgl(c,"Aimbot ligado",false,function(v) S.aim.on=v end, IS_MOBILE and "mobile: ativo quando ligado" or "segurar botão direito")
    sld(c,"FOV",30,500,120,function(v) S.aim.fov=v end)
    sld(c,"Smooth",5,100,30,function(v) S.aim.smooth=v/100 end)

    -- No Recoil — agora em Aimbot
    local cNR=card(L,"No Recoil")
    tgl(cNR,"No Recoil ligado",false,function(v) NoRecoil.toggle(v) end,"pitch-lock via RenderStepped — safe, sem kernel")
    sld(cNR,"Threshold (sensibilidade)",10,80,18,function(v) S.norecoil.threshold=v/1000 end)
    local nrDesc=label(cNR,"Quanto menor o threshold, mais agressivo (pode afetar mira manual).",10,false,THEME.warn)
    nrDesc.Size=UDim2.new(1,0,0,30); nrDesc.TextWrapped=true

    -- Lock-On
    local c2=card(R,"Lock-On (sem config)")
    tgl(c2,"Lock-On direto",false,function(v) S.aim2.on=v end,"gruda câmera na cabeça mais próxima visível")
    local cdesc=label(c2,"Muito notável. Prende câmera direto na cabeça mais próxima. Sem FOV/smooth.",10,false,THEME.warn); cdesc.Size=UDim2.new(1,0,0,32); cdesc.TextWrapped=true

    -- Silent Aim
    local c3=card(L,"Silent Aim (F5)")
    tgl(c3,"Silent aim",false,function(v) S.aim.silent=v end, hookmetamethod and "redireciona raycast pra cabeça" or "executor sem hookmetamethod")

    -- Filtros
    local c4=card(R,"Filtros")
    tgl(c4,"Não mirar em time",true,function(v) S.aim.team_check=v end)
    tgl(c4,"Só alvos visíveis",false,function(v) S.aim.visible_only=v end)
    tgl(c4,"Mostrar FOV",true,function(v) S.aim.show_fov=v end)

    -- Whitelist
    local c5=card(list,"Whitelist Aimbot")
    label(c5,"Players marcados não são mirados. Click na row pra alternar.",10,false,THEME.text2).Size=UDim2.new(1,0,0,22)
    local plist=make("ScrollingFrame",{Size=UDim2.new(1,0,0,180),BackgroundColor3=THEME.bg,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=THEME.accent,Parent=c5}); corner(plist,6); make("UIListLayout",{Padding=UDim.new(0,2)},plist); pad(plist,4)
    local function refresh_wl()
        for _,x in ipairs(plist:GetChildren()) do if x:IsA("TextButton") then x:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local on=in_whitelist(p.Name)
            local row=make("TextButton",{Size=UDim2.new(1,-4,0,28),BackgroundColor3=on and THEME.good or THEME.card2,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=plist}); corner(row,4)
            local nm=label(row,"  "..(on and "v " or "  ")..p.Name.." ("..p.DisplayName..")",11,true); nm.Size=UDim2.new(1,-8,1,0)
            row.MouseButton1Click:Connect(function()
                if on then for i,n in ipairs(CfgDB.aim_whitelist) do if n==p.Name then table.remove(CfgDB.aim_whitelist,i); break end end
                else table.insert(CfgDB.aim_whitelist,p.Name) end
                save_json(P_CFG,CfgDB); refresh_wl()
            end)
        end
    end
    local wrow=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,36),Parent=c5})
    local wL=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,-4,1,0),Parent=wrow})
    local wR=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,-4,1,0),Position=UDim2.new(0.5,4,0,0),Parent=wrow})
    wbtn(wL,"Atualizar",THEME.card2,refresh_wl); wbtn(wR,"Limpar",THEME.accent2,function() CfgDB.aim_whitelist={}; save_json(P_CFG,CfgDB); refresh_wl() end)
    task.spawn(refresh_wl)
    track(Players.PlayerAdded:Connect(refresh_wl))
    track(Players.PlayerRemoving:Connect(function() task.wait(0.3); if MainRoot.Parent then refresh_wl() end end))
end

-- ══════════════════════════════════════════════════════
-- PAGE: ESP
-- ══════════════════════════════════════════════════════
do
    local list=dual(pESP); local L,R=two(list)
    local c=card(L,"Visualização")
    tgl(c,"ESP ligado",false,function(v) S.esp.on=v end)
    tgl(c,"Caixa",true,function(v) S.esp.box=v end)
    tgl(c,"Nome + distância",true,function(v) S.esp.name=v end)
    tgl(c,"Barra de HP",true,function(v) S.esp.hp=v end)
    tgl(c,"Tracer",false,function(v) S.esp.tracer=v end)
    tgl(c,"CHAMS (atravessa parede)",false,function(v) S.esp.chams=v end)
    tgl(c,"Cor por time",false,function(v) S.esp.team=v end)
    local c2=card(R,"Filtros")
    tgl(c2,"Não mostrar aliados",true,function(v) S.esp.team_check=v end)
    sld(c2,"Distância máxima",100,10000,2000,function(v) S.esp.max_dist=v end)
end

-- ══════════════════════════════════════════════════════
-- PAGE: MISC  (antigo Movimento)
-- ══════════════════════════════════════════════════════
do
    local list=dual(pMisc); local L,R=two(list)
    local c=card(L,"Fly (F1)")
    tgl(c,"Fly",false,function(v) S.fly.on=v; if v then start_fly() else stop_fly() end end,"WASD + Espaço + Q")
    sld(c,"Velocidade",10,500,60,function(v) S.fly.speed=v end)
    tgl(c,"Freecam (E sobe, Q desce)",false,toggle_freecam)
    sld(c,"Vel freecam",1,10,1,function(v) S.freecam.speed=v end)
    local c2=card(R,"Speed (F2)")
    tgl(c2,"Speed",false,function(v) S.speed.on=v; if not v then local h=hum(); if h then h.WalkSpeed=16 end end end)
    sld(c2,"Walkspeed",16,500,50,function(v) S.speed.value=v end)
    tgl(c2,"Click TP",false,function(v) S.click_tp.on=v end,"click esquerdo teleporta")
    local c3=card(L,"Pulo + Noclip")
    tgl(c3,"Jump custom",false,function(v) S.jump.on=v; if not v then local h=hum(); if h then h.JumpPower=50 end end end)
    sld(c3,"Jump power",50,500,80,function(v) S.jump.value=v end)
    tgl(c3,"Pulo infinito",false,function(v) S.inf_jump.on=v end)
    tgl(c3,"Noclip",false,function(v) S.noclip.on=v end)
    local c4=card(R,"Visual + Combate")
    tgl(c4,"Fullbright",false,function(v) S.fullbright.on=v; apply_fullbright(v) end)
    tgl(c4,"Zoom (FOV)",false,function(v) S.zoom.on=v; if not v then Camera.FieldOfView=70 end end)
    sld(c4,"FOV",30,120,90,function(v) S.zoom.value=v end)
    tgl(c4,"Crosshair",false,function(v) S.crosshair.on=v end)
    tgl(c4,"Hitbox expander",false,function(v) S.hitbox.on=v end)
    sld(c4,"Tamanho hitbox",2,30,10,function(v) S.hitbox.size=v end)
    tgl(c4,"Anti-AFK",false,function(v) S.anti_afk.on=v end)
end

-- ══════════════════════════════════════════════════════
-- PAGE: TELEPORTE
-- ══════════════════════════════════════════════════════
do
    local list=dual(pTP); local L,R=two(list)
    local c=card(L,"Teleporte")
    local inp=winp(c,"nome do player"); inp:GetPropertyChangedSignal("Text"):Connect(function() S.tp.target=inp.Text end)
    wbtn(c,"TP (F3)",nil,function() if S.tp.target~="" then tp_player(S.tp.target) end end)
    local sv; wbtn(c,"Salvar posição",THEME.card2,function() local r=hrp(); if r then sv=r.CFrame; notify("Salvo","ok","success",2) end end)
    wbtn(c,"TP pra salva",THEME.card2,function() if sv then tp_to(sv) end end)
    local c2=card(R,"Players")
    local lst=make("ScrollingFrame",{Size=UDim2.new(1,0,0,220),BackgroundColor3=THEME.bg,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=THEME.accent,Parent=c2}); corner(lst,6); make("UIListLayout",{Padding=UDim.new(0,2)},lst); pad(lst,4)
    local function ref()
        for _,x in ipairs(lst:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then
                local row=make("Frame",{Size=UDim2.new(1,-4,0,28),BackgroundColor3=THEME.card2,BorderSizePixel=0,Parent=lst}); corner(row,4)
                label(row,"  "..p.Name,11).Size=UDim2.new(1,-70,1,0)
                local g=make("TextButton",{Size=UDim2.new(0,60,0,22),Position=UDim2.new(1,-66,0.5,-11),BackgroundColor3=THEME.accent,BorderSizePixel=0,Text="TP",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=11,Parent=row}); corner(g,3)
                g.MouseButton1Click:Connect(function() tp_player(p.Name) end)
            end
        end
    end
    wbtn(c2,"Atualizar",THEME.card2,ref); ref()
end

-- ══════════════════════════════════════════════════════
-- PAGE: ARMAS
-- ══════════════════════════════════════════════════════
do
    local list=dual(pArmas)
    local c=card(list,"Armas disponíveis")
    label(c,"Scanner acha Tools em ReplicatedStorage, Workspace, Teams e Backpacks.",10,false,THEME.text2).Size=UDim2.new(1,0,0,22)
    local lst=make("ScrollingFrame",{Size=UDim2.new(1,0,0,260),BackgroundColor3=THEME.bg,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=THEME.accent,Parent=c}); corner(lst,6); make("UIListLayout",{Padding=UDim.new(0,3)},lst); pad(lst,4)
    local function ref()
        for _,x in ipairs(lst:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
        for _,t in ipairs(scan_tools()) do
            local row=make("Frame",{Size=UDim2.new(1,-4,0,28),BackgroundColor3=THEME.card2,BorderSizePixel=0,Parent=lst}); corner(row,4)
            label(row,"  "..t.Name.."  < "..t.Parent.Name.." >",11).Size=UDim2.new(1,-70,1,0)
            local g=make("TextButton",{Size=UDim2.new(0,60,0,22),Position=UDim2.new(1,-66,0.5,-11),BackgroundColor3=THEME.accent,BorderSizePixel=0,Text="pegar",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=11,Parent=row}); corner(g,3)
            g.MouseButton1Click:Connect(function() grab(t); notify("Pego",t.Name,"success",2) end)
        end
    end
    wbtn(c,"Atualizar",THEME.card2,ref)
    wbtn(c,"Pegar TODAS",nil,function() local n=0; for _,t in ipairs(scan_tools()) do pcall(grab,t); n+=1 end; notify("Pegou",n.." armas","success") end)
    ref()
end

-- ══════════════════════════════════════════════════════
-- PAGE: SERVIDOR
-- ══════════════════════════════════════════════════════
do
    local list=dual(pServidor); local L,R=two(list)
    local cFling=card(L,"Fling")
    local inpF=winp(cFling,"nome do player alvo")
    wbtn(cFling,"Fling Player",nil,function() if inpF.Text~="" then fling_player(inpF.Text) end end,"arremessa o player pra longe")
    wbtn(cFling,"Grudar em player",THEME.card2,function() S.troll.follow_target=inpF.Text; notify("Seguindo",inpF.Text,"success",2) end)
    wbtn(cFling,"Parar de seguir",THEME.card2,function() S.troll.follow_target="" end)
    local cAnalyzer=card(R,"Analisador do Servidor")
    local quickInfo=make("Frame",{BackgroundColor3=THEME.bg,BorderSizePixel=0,Size=UDim2.new(1,0,0,52),Parent=cAnalyzer}); corner(quickInfo,4)
    local qi1=label(quickInfo,"Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers,11,true); qi1.Position=UDim2.new(0,8,0,4); qi1.Size=UDim2.new(1,-16,0,14)
    local qi2=label(quickInfo,"Place: "..tostring(game.PlaceId),10,false,THEME.text2); qi2.Position=UDim2.new(0,8,0,20); qi2.Size=UDim2.new(1,-16,0,14)
    local qi3=label(quickInfo,"Job: "..(game.JobId~="" and game.JobId:sub(1,20).."..." or "N/A"),10,false,THEME.text2); qi3.Position=UDim2.new(0,8,0,36); qi3.Size=UDim2.new(1,-16,0,14)
    local statusLbl=label(cAnalyzer,"Clique em Analisar para verificar compatibilidade + AntiCheat",11,false,THEME.text2); statusLbl.Size=UDim2.new(1,0,0,22); statusLbl.TextWrapped=true
    local resultScroll=make("ScrollingFrame",{Size=UDim2.new(1,0,0,320),BackgroundColor3=THEME.bg,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=THEME.accent,Parent=cAnalyzer}); corner(resultScroll,6); make("UIListLayout",{Padding=UDim.new(0,2)},resultScroll); pad(resultScroll,4)
    wbtn(cAnalyzer,"Analisar Servidor",nil,function() run_server_analysis(statusLbl,resultScroll) end)
    task.spawn(function() while MainRoot.Parent do qi1.Text="Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers; task.wait(5) end end)
end

-- ══════════════════════════════════════════════════════
-- PAGE: MONEY
-- ══════════════════════════════════════════════════════
do
    local list=dual(pMoney)
    local c=card(list,"Auto Money — Exploit via Remotes")
    label(c,"Varre todos RemoteEvents/RemoteFunctions buscando palavras-chave de dinheiro.",11,false,THEME.text).Size=UDim2.new(1,0,0,30)
    local valInp=winp(c,"valor (padrão: 999999)")
    wbtn(c,"EXECUTAR AUTO MONEY (Remote)",nil,function()
        local v=tonumber(valInp.Text) or 999999
        notify("Money Exploit","varrendo remotes...","warn",2)
        task.spawn(function()
            local n,names=auto_money_exploit(v)
            notify("Money Exploit",n.." remotes testados: "..table.concat(names,", "):sub(1,80),n>0 and "success" or "error",6)
        end)
    end,"via RemoteEvent/RemoteFunction")
    local c2=card(list,"Direct Money Set (Leaderstats Local)")
    label(c2,"Tenta setar diretamente os valores de leaderstats/Stats/Data do player local.",11,false,THEME.text).Size=UDim2.new(1,0,0,30)
    local val2Inp=winp(c2,"valor (padrão: 999999)")
    wbtn(c2,"SETAR DIRETO (Leaderstats)",nil,function()
        local v=tonumber(val2Inp.Text) or 999999
        local changed=direct_money_set(v)
        notify("Direct Set",changed.." valores alterados",changed>0 and "success" or "error",4)
    end,"seta leaderstats diretamente sem remote")
    local c3=card(list,"Stats detectadas")
    local sh=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=c3}); make("UIListLayout",{Padding=UDim.new(0,3)},sh)
    local function refresh_ls()
        for _,x in ipairs(sh:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
        local ls=scan_leaderstats(); if #ls==0 then local e=label(sh,"nenhuma leaderstat neste jogo",10,false,THEME.text2); e.Size=UDim2.new(1,0,0,16); return end
        for _,s in ipairs(ls) do
            local row=make("Frame",{Size=UDim2.new(1,0,0,22),BackgroundColor3=THEME.bg,BorderSizePixel=0,Parent=sh}); corner(row,4)
            local lb2=label(row,"  "..s.name,11); lb2.Size=UDim2.new(0.6,0,1,0)
            local vl=label(row,tostring(s.ref.Value),11,true,THEME.accent); vl.Size=UDim2.new(0.4,-8,1,0); vl.Position=UDim2.new(0.6,0,0,0); vl.TextXAlignment=Enum.TextXAlignment.Right
            s.ref:GetPropertyChangedSignal("Value"):Connect(function() vl.Text=tostring(s.ref.Value) end)
        end
    end
    wbtn(c3,"Scan leaderstats",THEME.card2,refresh_ls); refresh_ls()
end

-- ══════════════════════════════════════════════════════
-- PAGE: REMOTE SPY
-- ══════════════════════════════════════════════════════
do
    local list=dual(pSpy)
    local info=card(list,"Remote Spy")
    label(info,"Lista todos os remotes. Filtra por nome, dispara com args custom.",10,false,THEME.text2).Size=UDim2.new(1,0,0,16)
    local filterInp=winp(info,"filtrar (ex: cash, kill)"); local argsInp=winp(info,"args (ex: 999999 ou 100,true)")
    local rl=make("ScrollingFrame",{Size=UDim2.new(1,0,0,280),BackgroundColor3=THEME.bg,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=THEME.accent,Parent=info}); corner(rl,6); make("UIListLayout",{Padding=UDim.new(0,2)},rl); pad(rl,4)
    local function ref()
        for _,x in ipairs(rl:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
        local f=filterInp.Text:lower()
        for _,r in ipairs(scan_remotes()) do
            if f~="" and not r.name:lower():find(f,1,true) then continue end
            local row=make("Frame",{Size=UDim2.new(1,-4,0,38),BackgroundColor3=THEME.card2,BorderSizePixel=0,Parent=rl}); corner(row,4)
            local lb2=label(row,"  "..r.name,11,true); lb2.Size=UDim2.new(1,-80,0,16); lb2.Position=UDim2.new(0,4,0,4)
            local tp2=label(row,"  "..r.type.." | "..r.path:sub(1,60),9,false,THEME.text2); tp2.Size=UDim2.new(1,-80,0,14); tp2.Position=UDim2.new(0,4,0,20)
            local b=make("TextButton",{Size=UDim2.new(0,70,0,26),Position=UDim2.new(1,-76,0.5,-13),BackgroundColor3=THEME.accent,BorderSizePixel=0,Text="FIRE",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=11,Parent=row}); corner(b,4)
            b.MouseButton1Click:Connect(function() local ok,_=fire_remote(r.ref,argsInp.Text); notify(ok and "Fire" or "Falhou",r.name,ok and "success" or "error",3) end)
        end
    end
    wbtn(info,"Scan",THEME.card2,ref); ref()
end

-- ══════════════════════════════════════════════════════
-- PAGE: BYPASS
-- ══════════════════════════════════════════════════════
do
    local list=dual(pBypass)
    local c=card(list,"Anti-rastro")
    label(c,"GUI ofuscada em gethui()\nBodyMovers renomeados\nprotect_gui aplicado\nConexoes rastreadas\nSilent aim ignora proprias chamadas",11,false,THEME.text).Size=UDim2.new(1,0,0,78)
    local c2=card(list,"Desinjetar")
    label(c2,"Desliga TUDO, remove BodyMovers, apaga arquivos locais e fecha a GUI.",11,false,THEME.text2).Size=UDim2.new(1,0,0,32)
    wbtn(c2,"DESINJETAR",THEME.accent2,function() notify("Desinjetando...","apagando rastros","warn",2); task.wait(0.5); wipe_traces() end)
    if is_admin or is_lifetime(current_user) then
        local c3=card(list,"SaveInstance / Dump  [Admin / Key Lifetime]")
        label(c3,"Visível apenas para Admin e Keys Lifetime.",10,false,THEME.warn).Size=UDim2.new(1,0,0,14)
        wbtn(c3,"Dumpar place",nil,function() local ok,msg=try_saveinstance(); notify(ok and "Leak" or "Falhou",msg,ok and "success" or "error",5) end)
    end
end

-- ══════════════════════════════════════════════════════
-- PAGE: CONFIG
-- ══════════════════════════════════════════════════════
do
    local list=dual(pCfg); local L,R=two(list)
    local c=card(L,"Interface")
    tgl(c,"Stream Mode (F4)",false,function(v) StreamOn=v; apply_stream() end)
    sld(c,"Transparência",0,80,math.floor(CfgDB.transparency*100),function(v) CfgDB.transparency=v/100; save_json(P_CFG,CfgDB); MainRoot.BackgroundTransparency=CfgDB.transparency end)
    wbtn(c,"Deslogar",THEME.card2,function() Session.user=nil; save_json(P_SESS,Session); ScreenGui:Destroy() end)
    local c2=card(L,"Cor do menu")
    local cols={{label="Vermelho",rgb={220,38,38}},{label="Azul",rgb={38,120,220}},{label="Verde",rgb={38,180,90}},{label="Roxo",rgb={150,60,220}},{label="Laranja",rgb={255,140,30}},{label="Rosa",rgb={255,80,180}},{label="Ciano",rgb={0,200,220}}}
    ddn(c2,"accent",cols,function(o) THEME.accent=Color3.fromRGB(o.rgb[1],o.rgb[2],o.rgb[3]); CfgDB.accent=o.rgb; save_json(P_CFG,CfgDB); notify("Cor","recarregue","warn",3) end)

    -- KEYBIND
    local cKey=card(R,"Tecla de toggle do menu")
    label(cKey,"Clique no botão e pressione a tecla desejada.",11,false,THEME.text2).Size=UDim2.new(1,0,0,22)
    local keyBtn=make("TextButton",{BackgroundColor3=THEME.card2,BorderSizePixel=0,Size=UDim2.new(1,0,0,42),Text="",AutoButtonColor=false,Parent=cKey}); corner(keyBtn,8); stroke(keyBtn,THEME.accent)
    local keyNameLbl=label(keyBtn,"Tecla atual: ["..CurrentToggleKey.Name.."]",13,true,THEME.text); keyNameLbl.Position=UDim2.new(0,42,0,4); keyNameLbl.Size=UDim2.new(1,-50,0,16)
    local keySubLbl=label(keyBtn,"Clique aqui, depois pressione a nova tecla",10,false,THEME.text2); keySubLbl.Position=UDim2.new(0,42,0,24); keySubLbl.Size=UDim2.new(1,-50,0,14)
    -- ícone teclado em ImageLabel
    ico_img(keyBtn, ICO.gear, 20, UDim2.new(0,10,0.5,-10))
    local rebinding_conn
    keyBtn.MouseButton1Click:Connect(function()
        if RebindingKey then return end; RebindingKey=true
        keyNameLbl.Text="Pressione uma tecla..."; keyNameLbl.TextColor3=THEME.warn
        keySubLbl.Text="Pressione qualquer tecla para definir o toggle"
        TweenService:Create(keyBtn:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{Color=THEME.warn}):Play()
        if rebinding_conn then rebinding_conn:Disconnect() end
        rebinding_conn=UserInput.InputBegan:Connect(function(inp,gp)
            if gp then return end
            if inp.UserInputType~=Enum.UserInputType.Keyboard then return end
            if inp.KeyCode==Enum.KeyCode.Escape then
                RebindingKey=false; keyNameLbl.Text="Tecla atual: ["..CurrentToggleKey.Name.."]"; keyNameLbl.TextColor3=THEME.text
                keySubLbl.Text="Clique aqui, depois pressione a nova tecla"
                TweenService:Create(keyBtn:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{Color=THEME.accent}):Play()
                rebinding_conn:Disconnect(); return
            end
            save_keybind(inp.KeyCode); RebindingKey=false
            keyNameLbl.Text="Tecla atual: ["..inp.KeyCode.Name.."]"; keyNameLbl.TextColor3=THEME.good
            keySubLbl.Text="Salvo! Clique aqui para mudar"
            TweenService:Create(keyBtn:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{Color=THEME.good}):Play()
            task.delay(1.5,function()
                if keyBtn.Parent then
                    TweenService:Create(keyBtn:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{Color=THEME.accent}):Play()
                    keyNameLbl.TextColor3=THEME.text; keySubLbl.Text="Clique aqui, depois pressione a nova tecla"
                end
            end)
            rebinding_conn:Disconnect()
            pcall(function() CAS:UnbindAction("pkMenuK") end)
            pcall(function()
                CAS:BindActionAtPriority("pkMenuK",function(_,state)
                    if state==Enum.UserInputState.Begin then
                        if RebindingKey then return Enum.ContextActionResult.Pass end
                        local now=tick(); if now-lastToggle<0.3 then return Enum.ContextActionResult.Pass end
                        lastToggle=now; toggle_menu()
                    end
                    return Enum.ContextActionResult.Pass
                end,false,3500,CurrentToggleKey)
            end)
        end)
    end)

    local c3=card(R,"Hotkeys fixas")
    for _,h in ipairs({"F1  —  fly","F2  —  speed","F3  —  tp","F4  —  stream mode","F5  —  silent aim"}) do
        label(c3,h,12).Size=UDim2.new(1,0,0,16)
    end
    local dynHotkey=label(c3,"[?]  —  toggle menu",12); dynHotkey.Size=UDim2.new(1,0,0,16)
    task.spawn(function() while MainRoot.Parent do dynHotkey.Text="["..CurrentToggleKey.Name.."]  —  toggle menu"; task.wait(1) end end)

    if is_admin then
        local cStatus=card(R,"Status Premium")
        label(cStatus,"Visível apenas para Admins.",10,false,THEME.warn).Size=UDim2.new(1,0,0,14)
        wbtn(cStatus,"Enviar status agora",nil,function()
            send_status_premium(current_user,is_admin)
            notify("Status","embed Premium enviado","success",2)
        end,"formato verde/amarelo/vermelho igual canal #status")
    end
end

-- ══════════════════════════════════════════════════════
-- PAGE: ADMIN — KEYS
-- ══════════════════════════════════════════════════════
if pKeys then
    local list=dual(pKeys); local L,R=two(list)
    local c=card(L,"Gerar keys"); local sel=DURATIONS[1]; local opts={}
    for _,d in ipairs(DURATIONS) do table.insert(opts,{label=d.label,data=d}) end
    ddn(c,"duração",opts,function(o) sel=o.data end)
    local qty=winp(c,"qty (1-500)")
    local res=label(c,"",10,false,THEME.text2); res.Size=UDim2.new(1,0,0,100); res.TextWrapped=true; res.Font=Enum.Font.Code; res.TextYAlignment=Enum.TextYAlignment.Top
    wbtn(c,"Gerar",nil,function()
        local q=tonumber(qty.Text) or 0
        if q<1 or q>500 then notify("Erro","1-500","error"); return end
        local ks=generate_keys(sel.seconds,sel.label,q,current_user)
        res.Text=table.concat(ks,"\n")
        notify("Keys",q.." geradas + log no DC","success")
    end)
    local c2=card(R,"Reset HWID"); local ui=winp(c2,"usuário")
    wbtn(c2,"Resetar",nil,function() local ok,msg=admin_reset_hwid(ui.Text); notify(ok and "OK" or "Falhou",tostring(msg or ui.Text),ok and "success" or "error") end)
    local c3=card(R,"Usuários")
    local ulf=make("ScrollingFrame",{Size=UDim2.new(1,0,0,200),BackgroundColor3=THEME.bg,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=THEME.accent,Parent=c3}); corner(ulf,6); make("UIListLayout",{Padding=UDim.new(0,2)},ulf); pad(ulf,4)
    local function ref_users()
        for _,x in ipairs(ulf:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
        for name,ud in pairs(UserDB) do
            local row=make("Frame",{Size=UDim2.new(1,-4,0,22),BackgroundColor3=ud.admin and Color3.fromRGB(40,20,10) or THEME.card2,BorderSizePixel=0,Parent=ulf}); corner(row,3)
            label(row,"  "..(ud.admin and "[A] " or "")..name.." — "..(ud.exp==-1 and "LIFETIME" or (ud.exp and os.date("%d/%m",ud.exp) or "?")),10).Size=UDim2.new(1,0,1,0)
        end
    end
    wbtn(c3,"Atualizar",THEME.card2,ref_users); ref_users()
end

-- ══════════════════════════════════════════════════════
-- PAGE: ADMIN — LOGS
-- ══════════════════════════════════════════════════════
if pLogs then
    local list=dual(pLogs)
    local info=card(list,"Logs via Discord")
    label(info,"Logs são enviados em tempo real pro webhook #logs (WH_KEYS).\nKeys geradas e keys resgatadas.",11,false,THEME.text2).Size=UDim2.new(1,0,0,32)
    local c2=card(list,"Usuários locais")
    local lb=make("ScrollingFrame",{Size=UDim2.new(1,0,0,340),BackgroundColor3=THEME.bg,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=THEME.accent,Parent=c2}); corner(lb,6); make("UIListLayout",{Padding=UDim.new(0,2)},lb); pad(lb,4)
    local function ref()
        for _,x in ipairs(lb:GetChildren()) do if x:IsA("TextLabel") then x:Destroy() end end
        for name,ud in pairs(UserDB) do
            local w=ud.created and os.date("%d/%m",ud.created) or "?"
            local exp=ud.exp==-1 and "LIFETIME" or (ud.exp and os.date("%d/%m/%Y",ud.exp) or "sem key")
            local l=label(lb,"["..w.."] "..name.." — "..exp..(ud.admin and " [ADMIN]" or "").." — "..(ud.hwid and ud.hwid:sub(1,12).."..." or "sem hwid"),10,false,THEME.text2)
            l.Size=UDim2.new(1,0,0,14); l.Font=Enum.Font.Code; l.TextWrapped=true
        end
    end
    ref(); wbtn(c2,"Atualizar",THEME.card2,ref)
end

-- ══════════════════════════════════════════════════════
-- ACTIVATE + HOTKEYS
-- ══════════════════════════════════════════════════════
tabs["Início"].btn.MouseButton1Click:Fire()
menuVisible = true

local lastToggle = 0
local function toggle_menu()
    menuVisible = not menuVisible; MainRoot.Visible=menuVisible; set_input_block(menuVisible)
    if minBubble then minBubble:Destroy(); minBubble=nil end
end

track(UserInput.InputBegan:Connect(function(input, gpe)
    if gpe and input.UserInputType==Enum.UserInputType.Keyboard then return end
    if RebindingKey then return end
    if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==CurrentToggleKey then
        local now=tick(); if now-lastToggle<0.3 then return end; lastToggle=now; toggle_menu()
    elseif input.KeyCode==Enum.KeyCode.F1 then
        S.fly.on=not S.fly.on; if S.fly.on then start_fly() else stop_fly() end
        notify("Fly",S.fly.on and "ligado" or "desligado",S.fly.on and "success" or "warn",1.5)
    elseif input.KeyCode==Enum.KeyCode.F2 then
        S.speed.on=not S.speed.on; if not S.speed.on then local h=hum(); if h then h.WalkSpeed=16 end end
        notify("Speed",S.speed.on and "ligado" or "desligado",S.speed.on and "success" or "warn",1.5)
    elseif input.KeyCode==Enum.KeyCode.F3 then
        if S.tp.target~="" then tp_player(S.tp.target) end
    elseif input.KeyCode==Enum.KeyCode.F4 then
        StreamOn=not StreamOn; apply_stream()
    elseif input.KeyCode==Enum.KeyCode.F5 then
        S.aim.silent=not S.aim.silent
        notify("Silent",S.aim.silent and "ligado" or "desligado",S.aim.silent and "success" or "warn",1.5)
    end
end))

pcall(function()
    CAS:BindActionAtPriority("pkMenuK",function(_,state)
        if state==Enum.UserInputState.Begin then
            if RebindingKey then return Enum.ContextActionResult.Pass end
            local now=tick(); if now-lastToggle<0.3 then return Enum.ContextActionResult.Pass end
            lastToggle=now; toggle_menu()
        end
        return Enum.ContextActionResult.Pass
    end,false,3500,CurrentToggleKey)
end)

track(LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if S.fly.on then start_fly() end
    orig_trans={}
end))

-- Mobile FAB
if IS_MOBILE then
    local fab=make("ImageButton",{Size=UDim2.new(0,64,0,64),Position=UDim2.new(0,16,0.5,-32),BackgroundTransparency=1,Image=LOGO_ID,Parent=ScreenGui})
    fab.MouseButton1Click:Connect(toggle_menu)
    local drag,dS,sP
    fab.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=true; dS=i.Position; sP=fab.Position end end)
    fab.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    UserInput.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-dS; fab.Position=UDim2.new(sP.X.Scale,sP.X.Offset+d.X,sP.Y.Scale,sP.Y.Offset+d.Y)
        end
    end)
end

send_status_premium(current_user, is_admin)
task.spawn(function() while MainRoot.Parent do task.wait(300); send_status_premium(current_user,is_admin) end end)
notify("PK Cheats Brasil","["..CurrentToggleKey.Name.."] abre o menu","success",4)
set_input_block(true)
end -- build_menu

-- ══════════════════════════════════════════════════════
-- AUTH
-- ══════════════════════════════════════════════════════
local function build_auth()
    local LoginRoot=make("Frame",{Name="Login",Size=UDim2.new(0,480,0,520),Position=UDim2.new(0.5,-240,0.5,-260),BackgroundColor3=THEME.bg2,BorderSizePixel=0,Parent=ScreenGui}); corner(LoginRoot,14); stroke(LoginRoot,THEME.accent,1.5); gradient_pro(LoginRoot,THEME.bg2,THEME.bg,THEME.bg2,90)

    -- X de fechar — ImageLabel
    local lClose=make("ImageButton",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-40,0,12),BackgroundColor3=THEME.card,Image=ICO.close,BorderSizePixel=0,Parent=LoginRoot}); corner(lClose,15); stroke(lClose,THEME.accent); animate_btn(lClose); lClose.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local lLogo=build_logo(LoginRoot,140); lLogo.Position=UDim2.new(0.5,-70,0,20)
    local lt=label(LoginRoot,"bem-vindo de volta",13,false,THEME.text2); lt.Size=UDim2.new(1,-60,0,16); lt.Position=UDim2.new(0,30,0,170); lt.TextXAlignment=Enum.TextXAlignment.Center
    local LBody=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-60,0,240),Position=UDim2.new(0,30,0,200),Parent=LoginRoot}); make("UIListLayout",{Padding=UDim.new(0,10)},LBody)
    local function ainp(parent,ph)
        local wrap=make("Frame",{BackgroundColor3=THEME.card,BorderSizePixel=0,Size=UDim2.new(1,0,0,42),Parent=parent}); corner(wrap,8); stroke(wrap,THEME.stroke)
        local b=make("TextBox",{BackgroundTransparency=1,Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,14,0,0),PlaceholderText=ph,PlaceholderColor3=THEME.text2,TextColor3=THEME.text,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Text="",ClearTextOnFocus=false,Parent=wrap})
        b.Focused:Connect(function() TweenService:Create(wrap:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{Color=THEME.accent}):Play() end)
        b.FocusLost:Connect(function() TweenService:Create(wrap:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{Color=THEME.stroke}):Play() end)
        return b
    end
    local LUser=ainp(LBody,"usuário"); local LPass=ainp(LBody,"senha")
    local LBtn=make("TextButton",{BackgroundColor3=THEME.accent,BorderSizePixel=0,Size=UDim2.new(1,0,0,46),Text="ENTRAR",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=15,AutoButtonColor=false,Parent=LBody}); corner(LBtn,8); gradient_pro(LBtn,THEME.accent,THEME.accent2,THEME.accent3,90); animate_btn(LBtn)
    make("Frame",{BackgroundColor3=THEME.stroke,BorderSizePixel=0,Size=UDim2.new(1,0,0,1),Parent=LBody})
    local LToReg=make("TextButton",{BackgroundColor3=THEME.card,BorderSizePixel=0,Size=UDim2.new(1,0,0,42),Text="criar conta nova",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=13,AutoButtonColor=false,Parent=LBody}); corner(LToReg,8); stroke(LToReg,THEME.accent); animate_btn(LToReg)
    local LStat=label(LoginRoot,"",11,false,THEME.danger); LStat.Size=UDim2.new(1,-60,0,16); LStat.Position=UDim2.new(0,30,1,-52); LStat.TextXAlignment=Enum.TextXAlignment.Center
    local lFooter=label(LoginRoot,DISCORD.." • v7.1",10,false,THEME.text2); lFooter.Size=UDim2.new(1,-60,0,14); lFooter.Position=UDim2.new(0,30,1,-26); lFooter.TextXAlignment=Enum.TextXAlignment.Center

    local RegRoot=make("Frame",{Name="Register",Size=UDim2.new(0,480,0,600),Position=UDim2.new(0.5,-240,0.5,-300),BackgroundColor3=THEME.bg2,BorderSizePixel=0,Visible=false,Parent=ScreenGui}); corner(RegRoot,14); stroke(RegRoot,THEME.accent,1.5); gradient_pro(RegRoot,THEME.bg2,THEME.bg,THEME.bg2,90)
    local rClose=make("ImageButton",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-40,0,12),BackgroundColor3=THEME.card,Image=ICO.close,BorderSizePixel=0,Parent=RegRoot}); corner(rClose,15); stroke(rClose,THEME.accent); animate_btn(rClose); rClose.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    local rLogo=build_logo(RegRoot,140); rLogo.Position=UDim2.new(0.5,-70,0,20)
    local rt=label(RegRoot,"crie sua conta com uma key válida",13,false,THEME.text2); rt.Size=UDim2.new(1,-60,0,16); rt.Position=UDim2.new(0,30,0,170); rt.TextXAlignment=Enum.TextXAlignment.Center
    local RBody=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-60,0,320),Position=UDim2.new(0,30,0,200),Parent=RegRoot}); make("UIListLayout",{Padding=UDim.new(0,10)},RBody)
    local RUser=ainp(RBody,"usuário (min 3)"); local RPass=ainp(RBody,"senha (min 4)"); local RKey=ainp(RBody,"PK-XXXX-XXXX-XXXX-XXXX")
    local RBtn=make("TextButton",{BackgroundColor3=THEME.accent,BorderSizePixel=0,Size=UDim2.new(1,0,0,46),Text="CADASTRAR",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=15,AutoButtonColor=false,Parent=RBody}); corner(RBtn,8); gradient_pro(RBtn,THEME.accent,THEME.accent2,THEME.accent3,90); animate_btn(RBtn)
    make("Frame",{BackgroundColor3=THEME.stroke,BorderSizePixel=0,Size=UDim2.new(1,0,0,1),Parent=RBody})
    local RToLog=make("TextButton",{BackgroundColor3=THEME.card,BorderSizePixel=0,Size=UDim2.new(1,0,0,42),Text="já tenho conta — entrar",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=13,AutoButtonColor=false,Parent=RBody}); corner(RToLog,8); stroke(RToLog,THEME.accent); animate_btn(RToLog)
    local RStat=label(RegRoot,"",11,false,THEME.danger); RStat.Size=UDim2.new(1,-60,0,16); RStat.Position=UDim2.new(0,30,1,-26); RStat.TextXAlignment=Enum.TextXAlignment.Center

    LToReg.MouseButton1Click:Connect(function() LoginRoot.Visible=false; RegRoot.Visible=true end)
    RToLog.MouseButton1Click:Connect(function() RegRoot.Visible=false; LoginRoot.Visible=true end)
    return LoginRoot,RegRoot,LUser,LPass,LBtn,LStat,RUser,RPass,RKey,RBtn,RStat
end

run_splash(function()
    local LoginRoot,RegRoot,LUser,LPass,LBtn,LStat,RUser,RPass,RKey,RBtn,RStat = build_auth()

    -- ── AUTH LOGIC ──
    -- do_login: verifica senha, key ativa, HWID.
    -- Após login bem-sucedido, Session.user = username e é salvo em disco.
    -- Na próxima execução, Session.user já preenchido → auto-login sem pedir senha.
    local function do_login(uu, pp)
        local rec = UserDB[uu]
        if not rec then return false, "usuário não existe" end
        if rec.pass ~= pp then return false, "senha errada" end
        if not rec.admin then
            local ok, why = key_active(uu)
            if not ok then
                if why == "HWID_MISMATCH" then return false, "conta travada em outro device" end
                if why == "EXPIRED" or why == "NO_KEY" then delete_expired(uu); return false, "key expirada — recadastre" end
                return false, "key inválida"
            end
        end
        -- persiste sessão em disco — próximo load abre direto
        Session.user = uu
        save_json(P_SESS, Session)
        return true
    end

    local function do_register(uu, pp, kk)
        if UserDB[uu]  then return false, "usuário já existe" end
        if #uu < 3     then return false, "muito curto" end
        if #pp < 4     then return false, "senha curta" end
        if not KeyDB[kk] then return false, "key inválida" end
        if KeyDB[kk].used_by then return false, "key já usada" end
        UserDB[uu] = {pass=pp, admin=false, key=nil, exp=nil, created=os.time()}
        save_json(P_USERS, UserDB)
        local ok, msg = redeem_key(uu, kk)
        if not ok then UserDB[uu]=nil; save_json(P_USERS,UserDB); return false, msg end
        return true
    end

    LBtn.MouseButton1Click:Connect(function()
        local uu, pp = LUser.Text, LPass.Text
        local ok, msg = do_login(uu, pp)
        if ok then
            LoginRoot:Destroy(); RegRoot:Destroy()
            build_menu(uu, UserDB[uu].admin == true)
            notify("Entrou","bem-vindo, "..uu,"success",3)
        else
            LStat.Text = msg; notify("Falha", msg, "error")
        end
    end)

    RBtn.MouseButton1Click:Connect(function()
        local uu, pp, kk = RUser.Text, RPass.Text, RKey.Text
        local ok, msg = do_register(uu, pp, kk)
        if ok then
            RStat.Text="cadastrado!"; RStat.TextColor3=THEME.good
            notify("OK","faça login","success",4)
            task.wait(1.3); RegRoot.Visible=false; LoginRoot.Visible=true
            LUser.Text=uu; LPass.Text=""
        else
            RStat.Text=msg; notify("Falha",msg,"error")
        end
    end)

    -- Auto-login: se Session.user existe, UserDB tem o registro, e key ainda válida
    -- → pula a tela de login completamente
    if Session.user and UserDB[Session.user] then
        local uu  = Session.user
        local rec = UserDB[uu]
        local can_autologin = false
        if rec.admin then
            can_autologin = true
        else
            local ok, why = key_active(uu)
            if ok then
                can_autologin = true
            elseif why == "EXPIRED" then
                delete_expired(uu)
                -- session inválida, apaga e mostra login
                Session.user = nil; save_json(P_SESS, Session)
            elseif why == "HWID_MISMATCH" then
                -- device diferente — deixa cair pro login normal
                Session.user = nil; save_json(P_SESS, Session)
            end
        end
        if can_autologin then
            LoginRoot:Destroy(); RegRoot:Destroy()
            build_menu(uu, rec.admin == true)
        end
    end
end)
