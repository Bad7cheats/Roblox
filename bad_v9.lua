-- Bad.lua :: cheat universal roblox para executores
-- built by olivia -- discord.gg/ojailbreaks
-- cola no executor e executa. INSERT abre/fecha a UI.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInput     = game:GetService("UserInputService")
local Workspace     = game:GetService("Workspace")
local LP            = Players.LocalPlayer
local Camera        = Workspace.CurrentCamera

local State = {
    esp         = { on = false, box = true, name = true, hp = true, tracer = false, team = false, max_dist = 2000 },
    fly         = { on = false, speed = 60 },
    speed       = { on = false, value = 50, base = 16 },
    noclip      = { on = false },
    inf_jump    = { on = false },
    tp          = { target_name = "", saved = {} },
    aimbot      = { on = false, fov = 100, smooth = 0.25, team_check = false, visible_only = false },
}

----------------------------------------------------------------
-- helpers
----------------------------------------------------------------
local function char()    return LP.Character end
local function hrp()     local c = char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function hum()     local c = char(); return c and c:FindFirstChildOfClass("Humanoid") end

local function notify(title, msg, dur)
    Rayfield:Notify({ Title = title, Content = msg, Duration = dur or 3 })
end

----------------------------------------------------------------
-- ESP (drawing api)
----------------------------------------------------------------
local ESPData = {}

local function new_esp(plr)
    if ESPData[plr] then return end
    local box    = Drawing.new("Square"); box.Thickness = 1.5; box.Filled = false; box.Visible = false; box.Color = Color3.fromRGB(255, 60, 60)
    local name   = Drawing.new("Text");   name.Size = 14; name.Center = true; name.Outline = true; name.Visible = false; name.Color = Color3.fromRGB(255,255,255); name.Font = 2
    local hp_bg  = Drawing.new("Square"); hp_bg.Thickness = 1; hp_bg.Filled = true; hp_bg.Color = Color3.fromRGB(0,0,0); hp_bg.Visible = false
    local hp_fg  = Drawing.new("Square"); hp_fg.Thickness = 1; hp_fg.Filled = true; hp_fg.Color = Color3.fromRGB(40,255,40); hp_fg.Visible = false
    local tracer = Drawing.new("Line");   tracer.Thickness = 1.2; tracer.Visible = false; tracer.Color = Color3.fromRGB(255, 60, 60)
    ESPData[plr] = { box = box, name = name, hp_bg = hp_bg, hp_fg = hp_fg, tracer = tracer }
end

local function kill_esp(plr)
    local e = ESPData[plr]; if not e then return end
    for _, d in pairs(e) do pcall(function() d:Remove() end) end
    ESPData[plr] = nil
end

local function hide_esp(e)
    e.box.Visible = false; e.name.Visible = false
    e.hp_bg.Visible = false; e.hp_fg.Visible = false
    e.tracer.Visible = false
end

RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        new_esp(plr)
        local e = ESPData[plr]
        if not State.esp.on then hide_esp(e); continue end

        local ch = plr.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        local head = ch and ch:FindFirstChild("Head")
        local h    = ch and ch:FindFirstChildOfClass("Humanoid")
        if not root or not head or not h or h.Health <= 0 then hide_esp(e); continue end

        local vp_root, on_root = Camera:WorldToViewportPoint(root.Position)
        local vp_head, _       = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
        if not on_root then hide_esp(e); continue end

        local dist_me = hrp() and (hrp().Position - root.Position).Magnitude or 0
        if dist_me > State.esp.max_dist then hide_esp(e); continue end

        local height = (vp_root.Y - vp_head.Y) * 2
        local width  = height * 0.45
        local x = vp_root.X - width * 0.5
        local y = vp_head.Y

        local team_col = State.esp.team and plr.TeamColor and plr.TeamColor.Color or Color3.fromRGB(255,60,60)

        if State.esp.box then
            e.box.Size     = Vector2.new(width, height)
            e.box.Position = Vector2.new(x, y)
            e.box.Color    = team_col
            e.box.Visible  = true
        else e.box.Visible = false end

        if State.esp.name then
            e.name.Text     = plr.Name .. "  [" .. math.floor(dist_me) .. "m]"
            e.name.Position = Vector2.new(vp_root.X, y - 16)
            e.name.Visible  = true
        else e.name.Visible = false end

        if State.esp.hp then
            local frac = math.clamp(h.Health / h.MaxHealth, 0, 1)
            local bx = x - 6
            e.hp_bg.Size     = Vector2.new(3, height)
            e.hp_bg.Position = Vector2.new(bx, y)
            e.hp_bg.Visible  = true
            e.hp_fg.Size     = Vector2.new(3, height * frac)
            e.hp_fg.Position = Vector2.new(bx, y + height * (1 - frac))
            e.hp_fg.Color    = Color3.fromRGB(math.floor(255*(1-frac)), math.floor(255*frac), 40)
            e.hp_fg.Visible  = true
        else e.hp_bg.Visible = false; e.hp_fg.Visible = false end

        if State.esp.tracer then
            e.tracer.From    = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
            e.tracer.To      = Vector2.new(vp_root.X, vp_root.Y + height * 0.5)
            e.tracer.Color   = team_col
            e.tracer.Visible = true
        else e.tracer.Visible = false end
    end
end)

Players.PlayerRemoving:Connect(kill_esp)

----------------------------------------------------------------
-- fly (BodyGyro + BodyVelocity attach)
----------------------------------------------------------------
local bg, bv
local function stop_fly()
    if bg then bg:Destroy(); bg = nil end
    if bv then bv:Destroy(); bv = nil end
end

local function start_fly()
    stop_fly()
    local r = hrp(); if not r then return end
    bg = Instance.new("BodyGyro", r)
    bg.P = 9e4; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = r.CFrame
    bv = Instance.new("BodyVelocity", r)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.zero
end

RunService.Heartbeat:Connect(function()
    if not State.fly.on then return end
    local r = hrp(); if not r or not bv or not bg then return end
    bg.CFrame = Camera.CFrame
    local move = Vector3.zero
    if UserInput:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
    if UserInput:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
    if UserInput:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
    if UserInput:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
    if UserInput:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
    if UserInput:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
    if move.Magnitude > 0 then move = move.Unit * State.fly.speed end
    bv.Velocity = move
end)

----------------------------------------------------------------
-- speed
----------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    local h = hum(); if not h then return end
    h.WalkSpeed = State.speed.on and State.speed.value or State.speed.base
end)

----------------------------------------------------------------
-- noclip + inf jump
----------------------------------------------------------------
RunService.Stepped:Connect(function()
    if not State.noclip.on then return end
    local c = char(); if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

UserInput.JumpRequest:Connect(function()
    if State.inf_jump.on then
        local h = hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

----------------------------------------------------------------
-- teleport
----------------------------------------------------------------
local function tp_to(cf)
    local r = hrp(); if r then r.CFrame = cf end
end

local function tp_to_player(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Name:lower():find(name:lower(), 1, true) then
            local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if r then tp_to(r.CFrame + Vector3.new(2, 0, 0)); notify("Bad", "tp pra " .. p.Name) return end
        end
    end
    notify("Bad", "player nao achado: " .. name)
end

----------------------------------------------------------------
-- aimbot (silent locking do mais proximo visivel no FOV)
----------------------------------------------------------------
local function closest_target()
    local best, best_dist = nil, State.aimbot.fov
    local mx, my = Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if State.aimbot.team_check and plr.Team == LP.Team then continue end
        local ch = plr.Character
        local head = ch and ch:FindFirstChild("Head")
        local h = ch and ch:FindFirstChildOfClass("Humanoid")
        if not head or not h or h.Health <= 0 then continue end
        local vp, onscreen = Camera:WorldToViewportPoint(head.Position)
        if not onscreen then continue end
        local d = math.sqrt((vp.X - mx)^2 + (vp.Y - my)^2)
        if d < best_dist then
            if State.aimbot.visible_only then
                local ray = Workspace:Raycast(Camera.CFrame.Position, head.Position - Camera.CFrame.Position)
                if ray and not ray.Instance:IsDescendantOf(ch) then continue end
            end
            best, best_dist = head, d
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not State.aimbot.on then return end
    if not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local t = closest_target(); if not t then return end
    local dir = (t.Position - Camera.CFrame.Position).Unit
    local want = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + dir)
    Camera.CFrame = Camera.CFrame:Lerp(want, State.aimbot.smooth)
end)

----------------------------------------------------------------
-- UI (Rayfield)
----------------------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "Bad :: universal cheat",
    LoadingTitle = "Bad",
    LoadingSubtitle = "built by olivia",
    ConfigurationSaving = { Enabled = true, FolderName = "Bad", FileName = "config" },
    KeySystem = false,
})

local TabESP   = Window:CreateTab("esp", 4483362458)
local TabMove  = Window:CreateTab("movimento", 4483362458)
local TabTP    = Window:CreateTab("teleporte", 4483362458)
local TabAim   = Window:CreateTab("aimbot", 4483362458)
local TabCfg   = Window:CreateTab("config", 4483362458)

-- ESP
TabESP:CreateToggle({ Name = "esp on", CurrentValue = false, Flag = "esp_on", Callback = function(v) State.esp.on = v end })
TabESP:CreateToggle({ Name = "caixa", CurrentValue = true,  Flag = "esp_box",  Callback = function(v) State.esp.box = v end })
TabESP:CreateToggle({ Name = "nome + distancia", CurrentValue = true, Flag = "esp_name", Callback = function(v) State.esp.name = v end })
TabESP:CreateToggle({ Name = "barra de hp", CurrentValue = true, Flag = "esp_hp", Callback = function(v) State.esp.hp = v end })
TabESP:CreateToggle({ Name = "tracer", CurrentValue = false, Flag = "esp_tr", Callback = function(v) State.esp.tracer = v end })
TabESP:CreateToggle({ Name = "cor por time", CurrentValue = false, Flag = "esp_team", Callback = function(v) State.esp.team = v end })
TabESP:CreateSlider({ Name = "distancia max", Range = {100, 10000}, Increment = 50, CurrentValue = 2000, Flag = "esp_dist", Callback = function(v) State.esp.max_dist = v end })

-- MOVE
TabMove:CreateToggle({ Name = "fly (F1)", CurrentValue = false, Flag = "fly_on", Callback = function(v)
    State.fly.on = v
    if v then start_fly() else stop_fly() end
end })
TabMove:CreateSlider({ Name = "velocidade fly", Range = {10, 500}, Increment = 5, CurrentValue = 60, Flag = "fly_sp", Callback = function(v) State.fly.speed = v end })
TabMove:CreateToggle({ Name = "speed (F2)", CurrentValue = false, Flag = "sp_on", Callback = function(v) State.speed.on = v end })
TabMove:CreateSlider({ Name = "walkspeed", Range = {16, 500}, Increment = 1, CurrentValue = 50, Flag = "sp_val", Callback = function(v) State.speed.value = v end })
TabMove:CreateToggle({ Name = "noclip (atravessa paredes)", CurrentValue = false, Flag = "nc_on", Callback = function(v) State.noclip.on = v end })
TabMove:CreateToggle({ Name = "pulo infinito", CurrentValue = false, Flag = "ij_on", Callback = function(v) State.inf_jump.on = v end })

-- TP
TabTP:CreateInput({ Name = "nome do player", PlaceholderText = "ex: pakau", RemoveTextAfterFocusLost = false, Flag = "tp_name", Callback = function(v) State.tp.target_name = v end })
TabTP:CreateButton({ Name = "teleportar pro player (F3)", Callback = function()
    if State.tp.target_name ~= "" then tp_to_player(State.tp.target_name) end
end })
TabTP:CreateButton({ Name = "salvar posicao atual", Callback = function()
    local r = hrp(); if not r then return end
    local n = "ponto_" .. (#State.tp.saved + 1)
    table.insert(State.tp.saved, { name = n, cf = r.CFrame })
    notify("Bad", "salvo: " .. n)
end })
TabTP:CreateButton({ Name = "tp pro ultimo salvo", Callback = function()
    local last = State.tp.saved[#State.tp.saved]
    if last then tp_to(last.cf); notify("Bad", "tp pra " .. last.name) end
end })

-- AIMBOT
TabAim:CreateToggle({ Name = "aimbot on (segura botao direito)", CurrentValue = false, Flag = "aim_on", Callback = function(v) State.aimbot.on = v end })
TabAim:CreateSlider({ Name = "FOV (pixels)", Range = {20, 500}, Increment = 10, CurrentValue = 100, Flag = "aim_fov", Callback = function(v) State.aimbot.fov = v end })
TabAim:CreateSlider({ Name = "smooth (menor = mais rapido)", Range = {0.05, 1}, Increment = 0.05, CurrentValue = 0.25, Flag = "aim_sm", Callback = function(v) State.aimbot.smooth = v end })
TabAim:CreateToggle({ Name = "nao mirar em time", CurrentValue = false, Flag = "aim_team", Callback = function(v) State.aimbot.team_check = v end })
TabAim:CreateToggle({ Name = "so visivel", CurrentValue = false, Flag = "aim_vis", Callback = function(v) State.aimbot.visible_only = v end })

-- CFG
TabCfg:CreateLabel("hotkeys:")
TabCfg:CreateLabel("INSERT  -> abre/fecha menu")
TabCfg:CreateLabel("F1      -> fly")
TabCfg:CreateLabel("F2      -> speed")
TabCfg:CreateLabel("F3      -> tp pro player no campo")
TabCfg:CreateButton({ Name = "destruir / unload", Callback = function()
    State.esp.on = false; State.fly.on = false; State.speed.on = false
    State.noclip.on = false; State.inf_jump.on = false; State.aimbot.on = false
    stop_fly()
    for p, _ in pairs(ESPData) do kill_esp(p) end
    Rayfield:Destroy()
end })

----------------------------------------------------------------
-- hotkeys
----------------------------------------------------------------
UserInput.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Rayfield:Toggle()
    elseif input.KeyCode == Enum.KeyCode.F1 then
        State.fly.on = not State.fly.on
        if State.fly.on then start_fly() else stop_fly() end
        notify("Bad", "fly: " .. (State.fly.on and "ON" or "OFF"), 1.5)
    elseif input.KeyCode == Enum.KeyCode.F2 then
        State.speed.on = not State.speed.on
        notify("Bad", "speed: " .. (State.speed.on and "ON" or "OFF"), 1.5)
    elseif input.KeyCode == Enum.KeyCode.F3 then
        if State.tp.target_name ~= "" then tp_to_player(State.tp.target_name) end
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if State.fly.on then start_fly() end
end)

notify("Bad", "carregado. INSERT pra menu.", 4)
