-- PK Cheats Brasil v9 ESTÁVEL
-- discord.gg/bad7
-- hotkeys: K ou Insert = menu

local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local THEME = {
    bg = Color3.fromRGB(14, 14, 18),
    bg2 = Color3.fromRGB(22, 22, 28),
    card = Color3.fromRGB(28, 28, 34),
    accent = Color3.fromRGB(220, 38, 38),
    text = Color3.fromRGB(240, 240, 240),
    text2 = Color3.fromRGB(150, 150, 155),
    good = Color3.fromRGB(45, 200, 95),
}

local LOGO = "rbxassetid://93685935272917"
local DISCORD = "discord.gg/bad7"

-- destrói GUI antiga se existir
pcall(function()
    local gui = (gethui and gethui()) or game:GetService("CoreGui")
    for _, c in ipairs(gui:GetChildren()) do
        if c.Name == "PKCheatsBrasil" then c:Destroy() end
    end
end)

-- cria ScreenGui
local function get_parent()
    if gethui then local ok, g = pcall(gethui); if ok then return g end end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    return (ok and cg) or LP:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PKCheatsBrasil"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999
pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
ScreenGui.Parent = get_parent()

print("[PK Cheats] GUI criada em", ScreenGui.Parent:GetFullName())

-- STATE
local S = {
    esp = false,
    fly = false,
    speed = 16,
    jumpInf = false,
    noclip = false,
    aim = false,
    aim_lock = false,
}

-- UTILS
local function hrp() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end

-- NOTIFY
local function notify(title, msg, color)
    local n = Instance.new("Frame")
    n.Size = UDim2.new(0, 280, 0, 60)
    n.Position = UDim2.new(1, -300, 0, 20)
    n.BackgroundColor3 = THEME.bg2
    n.BorderSizePixel = 0
    n.Parent = ScreenGui
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 8)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0); bar.BackgroundColor3 = color or THEME.accent; bar.BorderSizePixel = 0; bar.Parent = n
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -16, 0, 20); t.Position = UDim2.new(0, 14, 0, 8); t.BackgroundTransparency = 1
    t.Text = title; t.TextColor3 = color or THEME.accent; t.Font = Enum.Font.GothamBold; t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = n
    local m = Instance.new("TextLabel")
    m.Size = UDim2.new(1, -16, 0, 20); m.Position = UDim2.new(0, 14, 0, 28); m.BackgroundTransparency = 1
    m.Text = msg; m.TextColor3 = THEME.text; m.Font = Enum.Font.Gotham; m.TextSize = 12
    m.TextXAlignment = Enum.TextXAlignment.Left; m.Parent = n
    task.delay(3, function() n:Destroy() end)
end

-- MAIN FRAME
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 680, 0, 440)
Main.Position = UDim2.new(0.5, -340, 0.5, -220)
Main.BackgroundColor3 = THEME.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", Main); stroke.Color = THEME.accent; stroke.Thickness = 1.5

-- SIDEBAR
local Side = Instance.new("Frame")
Side.Size = UDim2.new(0, 170, 1, 0)
Side.BackgroundColor3 = THEME.bg2
Side.BorderSizePixel = 0
Side.Parent = Main
Instance.new("UICorner", Side).CornerRadius = UDim.new(0, 10)

local logo = Instance.new("ImageLabel")
logo.BackgroundTransparency = 1
logo.Image = LOGO
logo.Size = UDim2.new(0, 110, 0, 110)
logo.Position = UDim2.new(0.5, -55, 0, 10)
logo.ScaleType = Enum.ScaleType.Fit
logo.Parent = Side

-- TITLE / CLOSE
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -180, 0, 40)
TopBar.Position = UDim2.new(0, 175, 0, 5)
TopBar.BackgroundTransparency = 1
TopBar.Parent = Main
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "PK Cheats Brasil"
Title.TextColor3 = THEME.accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Parent = TopBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30); Close.Position = UDim2.new(1, -36, 0, 5)
Close.BackgroundColor3 = THEME.card; Close.Text = "×"; Close.TextColor3 = THEME.accent
Close.Font = Enum.Font.GothamBold; Close.TextSize = 20; Close.BorderSizePixel = 0; Close.Parent = TopBar
Instance.new("UICorner", Close).CornerRadius = UDim.new(1, 0)

-- PAGE AREA
local Page = Instance.new("ScrollingFrame")
Page.Size = UDim2.new(1, -195, 1, -60)
Page.Position = UDim2.new(0, 180, 0, 50)
Page.BackgroundTransparency = 1
Page.BorderSizePixel = 0
Page.CanvasSize = UDim2.new(0, 0, 0, 0)
Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
Page.ScrollBarThickness = 3
Page.ScrollBarImageColor3 = THEME.accent
Page.Parent = Main
local layout = Instance.new("UIListLayout", Page); layout.Padding = UDim.new(0, 8)
local pad = Instance.new("UIPadding", Page); pad.PaddingTop = UDim.new(0, 4); pad.PaddingLeft = UDim.new(0, 4); pad.PaddingRight = UDim.new(0, 4)

-- WIDGETS
local function toggle(name, default, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -8, 0, 40); f.BackgroundColor3 = THEME.card; f.BorderSizePixel = 0; f.Parent = Page
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -60, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.BackgroundTransparency = 1
    l.Text = name; l.TextColor3 = THEME.text; l.Font = Enum.Font.GothamBold; l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
    local sw = Instance.new("TextButton")
    sw.Size = UDim2.new(0, 42, 0, 22); sw.Position = UDim2.new(1, -50, 0.5, -11)
    sw.BackgroundColor3 = default and THEME.accent or Color3.fromRGB(50, 50, 55)
    sw.BorderSizePixel = 0; sw.Text = ""; sw.AutoButtonColor = false; sw.Parent = f
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
    local k = Instance.new("Frame")
    k.Size = UDim2.new(0, 16, 0, 16); k.Position = UDim2.new(default and 1 or 0, default and -19 or 3, 0.5, -8)
    k.BackgroundColor3 = THEME.text; k.BorderSizePixel = 0; k.Parent = sw
    Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
    local v = default
    sw.MouseButton1Click:Connect(function()
        v = not v
        TweenService:Create(sw, TweenInfo.new(0.2), { BackgroundColor3 = v and THEME.accent or Color3.fromRGB(50, 50, 55) }):Play()
        TweenService:Create(k, TweenInfo.new(0.2), { Position = UDim2.new(v and 1 or 0, v and -19 or 3, 0.5, -8) }):Play()
        if cb then cb(v) end
    end)
end

local function button(name, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 36); b.BackgroundColor3 = THEME.accent; b.BorderSizePixel = 0
    b.Text = name; b.TextColor3 = THEME.text; b.Font = Enum.Font.GothamBold; b.TextSize = 13
    b.AutoButtonColor = true; b.Parent = Page
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
end

local function header(txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -8, 0, 24); l.BackgroundTransparency = 1
    l.Text = txt; l.TextColor3 = THEME.text2; l.Font = Enum.Font.GothamBold; l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = Page
end

local function slider_input(name, placeholder, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -8, 0, 40); f.BackgroundColor3 = THEME.card; f.BorderSizePixel = 0; f.Parent = Page
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, 0, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.BackgroundTransparency = 1
    l.Text = name; l.TextColor3 = THEME.text; l.Font = Enum.Font.Gotham; l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
    local b = Instance.new("TextBox")
    b.Size = UDim2.new(0.5, -20, 0, 26); b.Position = UDim2.new(0.5, 12, 0.5, -13)
    b.BackgroundColor3 = THEME.bg; b.Text = ""; b.PlaceholderText = placeholder
    b.PlaceholderColor3 = THEME.text2; b.TextColor3 = THEME.text
    b.Font = Enum.Font.Gotham; b.TextSize = 12; b.ClearTextOnFocus = false; b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.FocusLost:Connect(function() if cb then cb(b.Text) end end)
    return b
end

-- POPULATE PAGE
header("MOVIMENTO")
toggle("Fly", false, function(v) S.fly = v end)
toggle("Speed (vel alta)", false, function(v) S.speed = v and 50 or 16; local h = hum(); if h then h.WalkSpeed = S.speed end end)
toggle("Pulo infinito", false, function(v) S.jumpInf = v end)
toggle("Noclip", false, function(v) S.noclip = v end)

header("COMBATE")
toggle("ESP (todos players)", false, function(v) S.esp = v end)
toggle("Aimbot (botão direito)", false, function(v) S.aim = v end)
toggle("🔒 Lock-On (gruda na cabeça)", false, function(v) S.aim_lock = v end)

header("TELEPORTE")
local tpTarget = ""
slider_input("Nome do player", "ex: bad7", function(t) tpTarget = t end)
button("Teleportar", function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Name:lower():find(tpTarget:lower(), 1, true) then
            local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if r and hrp() then hrp().CFrame = r.CFrame + Vector3.new(2, 0, 0); notify("TP", "pra " .. p.Name, THEME.good) end
            return
        end
    end
    notify("TP", "player não achado", THEME.accent)
end)

header("OUTROS")
button("Resetar personagem", function() local h = hum(); if h then h.Health = 0 end end)
button("Fechar cheat", function() ScreenGui:Destroy() end)

-- FEATURES
local bg_fly, bv_fly
local function start_fly() if bg_fly then bg_fly:Destroy() end; if bv_fly then bv_fly:Destroy() end
    local r = hrp(); if not r then return end
    bg_fly = Instance.new("BodyGyro", r); bg_fly.P = 9e4; bg_fly.MaxTorque = Vector3.new(9e9,9e9,9e9); bg_fly.CFrame = r.CFrame
    bv_fly = Instance.new("BodyVelocity", r); bv_fly.MaxForce = Vector3.new(9e9,9e9,9e9); bv_fly.Velocity = Vector3.zero
end
local function stop_fly() if bg_fly then bg_fly:Destroy(); bg_fly = nil end; if bv_fly then bv_fly:Destroy(); bv_fly = nil end end

-- FLY LOOP
RunService.Heartbeat:Connect(function()
    if S.fly then
        if not bg_fly then start_fly() end
        if bg_fly and bv_fly then
            bg_fly.CFrame = Camera.CFrame
            local mv = Vector3.zero
            if UserInput:IsKeyDown(Enum.KeyCode.W) then mv = mv + Camera.CFrame.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.S) then mv = mv - Camera.CFrame.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.A) then mv = mv - Camera.CFrame.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.D) then mv = mv + Camera.CFrame.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0, 1, 0) end
            if mv.Magnitude > 0 then mv = mv.Unit * 60 end
            bv_fly.Velocity = mv
        end
    else
        if bg_fly then stop_fly() end
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if S.noclip then
        local c = LP.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- INF JUMP
UserInput.JumpRequest:Connect(function()
    if S.jumpInf then local h = hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

-- ESP (billboard, simples, funciona em qualquer executor)
local ESP = {}
local function esp_add(p)
    if ESP[p] then return end
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 100, 0, 30); bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0, 3, 0); bb.Parent = ScreenGui
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
    l.Text = p.Name; l.TextColor3 = THEME.accent; l.Font = Enum.Font.GothamBold; l.TextSize = 14
    l.TextStrokeTransparency = 0; l.Parent = bb
    ESP[p] = bb
end
local function esp_remove(p) if ESP[p] then ESP[p]:Destroy(); ESP[p] = nil end end

RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            if S.esp then
                esp_add(p)
                local head = p.Character and p.Character:FindFirstChild("Head")
                ESP[p].Adornee = head
            else
                esp_remove(p)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(esp_remove)

-- AIMBOT
RunService.RenderStepped:Connect(function()
    if not (S.aim or S.aim_lock) then return end
    local pressing = UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if UserInput.TouchEnabled and not pressing then
        -- mobile: qualquer touch ativo
        for _, t in ipairs(UserInput:GetMouseButtonsPressed()) do
            if t.UserInputType == Enum.UserInputType.Touch then pressing = true; break end
        end
    end
    if not pressing then return end

    -- acha alvo
    local best, bd = nil, math.huge
    local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local ch = p.Character
            local head = ch and ch:FindFirstChild("Head")
            local h = ch and ch:FindFirstChildOfClass("Humanoid")
            if head and h and h.Health > 0 then
                local vp, on = Camera:WorldToViewportPoint(head.Position)
                if on then
                    local d = math.sqrt((vp.X-cx)^2 + (vp.Y-cy)^2)
                    if d < bd and (S.aim_lock or d < 200) then
                        best, bd = head, d
                    end
                end
            end
        end
    end
    if best then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, best.Position)
    end
end)

-- CLOSE
local menuVisible = true
local function toggle_menu() menuVisible = not menuVisible; Main.Visible = menuVisible end
Close.MouseButton1Click:Connect(toggle_menu)

-- HOTKEY via polling (sempre funciona)
local lastKey = { K = false, Insert = false }
local lastTick = 0
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.05)
        for keyName, _ in pairs(lastKey) do
            local keyCode = Enum.KeyCode[keyName]
            local down = UserInput:IsKeyDown(keyCode)
            if down and not lastKey[keyName] then
                if tick() - lastTick > 0.3 and not UserInput:GetFocusedTextBox() then
                    lastTick = tick()
                    toggle_menu()
                end
            end
            lastKey[keyName] = down
        end
    end
end)

-- BOTÃO FLUTUANTE (sempre disponível)
local Float = Instance.new("ImageButton")
Float.Size = UDim2.new(0, 56, 0, 56)
Float.Position = UDim2.new(0, 16, 0.5, -28)
Float.BackgroundTransparency = 1
Float.Image = LOGO
Float.Parent = ScreenGui
Float.ZIndex = 100
local fs = Instance.new("UIStroke", Float); fs.Color = THEME.accent; fs.Thickness = 2
Instance.new("UICorner", Float).CornerRadius = UDim.new(1, 0)
Float.MouseButton1Click:Connect(toggle_menu)

-- arrastar
local fD, fS, fP
Float.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fD = true; fS = i.Position; fP = Float.Position end end)
Float.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fD = false end end)
UserInput.InputChanged:Connect(function(i) if fD and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - fS; Float.Position = UDim2.new(fP.X.Scale, fP.X.Offset + d.X, fP.Y.Scale, fP.Y.Offset + d.Y) end end)

notify("PK Cheats Brasil", "carregado — tecla K ou Insert pra menu", THEME.good)
print("[PK Cheats Brasil] v9 ESTÁVEL carregado com sucesso")
