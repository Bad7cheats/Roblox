-- ============================================================
-- Bad v9 — Roblox FPS Hub (ONLINE backend + HWID lock)
-- Loader: loadstring(game:HttpGet("https://SEU_GIST/raw/bad_v9.lua"))()
-- INS = abrir/fechar . Admin: bad7 / 1986rkrk (bypass offline)
-- ============================================================
if _G.BadGui and _G.BadGui.Parent then _G.BadGui:Destroy() end

-- ================== CONFIG ==================
local API_BASE = "https://SEU_BACKEND.up.railway.app"  -- TROQUE pela URL Railway
-- ============================================

local Players, RunService, UIS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService")
local TweenService, HttpService = game:GetService("TweenService"), game:GetService("HttpService")
local CoreGui, Workspace, Lighting = game:GetService("CoreGui"), game:GetService("Workspace"), game:GetService("Lighting")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage
pcall(function() ServerStorage = game:GetService("ServerStorage") end)
local LP, Camera = Players.LocalPlayer, Workspace.CurrentCamera

local http_request = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)
local has_fs = (writefile ~= nil) and (readfile ~= nil) and (isfile ~= nil)
local setclipboard = setclipboard or (syn and syn.write_clipboard) or toclipboard

if has_fs then pcall(function() if not isfolder("Bad") then makefolder("Bad") end end) end

-- ================== API CLIENT ==================
local function apiCall(path, body)
    if not http_request then return nil, "executor sem http_request" end
    local ok, res = pcall(http_request, {
        Url = API_BASE..path, Method="POST",
        Headers = {["Content-Type"]="application/json"},
        Body = HttpService:JSONEncode(body or {}),
    })
    if not ok or not res then return nil, "request failed" end
    local data
    pcall(function() data = HttpService:JSONDecode(res.Body or "{}") end)
    if (res.StatusCode or 0) >= 400 then return nil, (data and data.error) or "erro http "..(res.StatusCode or "?") end
    return data, nil
end

-- ================== HWID ==================
local function getHWID()
    local f = "Bad/hwid.txt"
    if has_fs and isfile(f) then return readfile(f) end
    local id = ""
    for i=1,32 do id = id .. string.format("%x", math.random(0,15)) end
    if has_fs then pcall(function() writefile(f, id) end) end
    return id
end
local HWID = getHWID()

-- ================== SESSION ==================
local SessFile = "Bad/session.json"
local function loadSess()
    if not has_fs or not isfile(SessFile) then return nil end
    local ok, v = pcall(function() return HttpService:JSONDecode(readfile(SessFile)) end)
    return ok and v or nil
end
local function saveSess(t) if has_fs then pcall(function() writefile(SessFile, HttpService:JSONEncode(t)) end) end end
local function clearSess() if has_fs and isfile(SessFile) then pcall(function() writefile(SessFile, "") end) end end

-- ================== CFG / THEME ==================
local CFG = {
    Version="v9.0",
    Theme = {
        bg=Color3.fromRGB(13,13,17), bgDeep=Color3.fromRGB(9,9,12),
        panel=Color3.fromRGB(22,22,28), panel2=Color3.fromRGB(32,32,40),
        side=Color3.fromRGB(17,17,22), row=Color3.fromRGB(26,26,32),
        rowHover=Color3.fromRGB(38,38,46),
        accent=Color3.fromRGB(235,40,45), accentHi=Color3.fromRGB(255,80,85),
        accentLo=Color3.fromRGB(150,22,27), accentDk=Color3.fromRGB(70,10,13),
        text=Color3.fromRGB(245,245,245), textDim=Color3.fromRGB(180,180,190),
        muted=Color3.fromRGB(125,125,135),
        stroke=Color3.fromRGB(55,15,18), strokeHi=Color3.fromRGB(95,28,32),
        ok=Color3.fromRGB(80,220,120), err=Color3.fromRGB(255,90,90),
    },
    Admin={ user="bad7", pass="1986rkrk" }, -- bypass offline
    Toggle=Enum.KeyCode.Insert,
}

-- ================== STATE ==================
local State = {
    silentAim=false, aimbot=false, aimFOV=120, aimSmooth=0.25, aimPart="Head",
    aimTeamCheck=false, aimVisibleOnly=false, aimDrawFOV=false,
    espBox=false, espName=false, espHealth=false, espDistance=false, espTracer=false, espChams=false,
    walkspeed=16, walkspeedDirty=false,
    jumppower=50, jumppowerDirty=false,
    gravity=196.2, gravityDirty=false,
    noclip=false, inf_jump=false, fly=false, flySpeed=50,
    pullWeapons=false, pullWorkspace=true, pullServerStorage=false, pullReplicated=false, pullTeams=false, pullOthers=false,
    fullbright=false, noFog=false,
}

-- ================== ROOT ==================
local Root = Instance.new("ScreenGui")
Root.Name = "_"..tostring(math.random(1e7,9e7))
Root.ResetOnSpawn=false; Root.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
Root.IgnoreGuiInset = true; Root.DisplayOrder = 999999
_G.BadGui = Root
pcall(function()
    if gethui then Root.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(Root); Root.Parent=CoreGui
    else Root.Parent=CoreGui end
end)
if not Root.Parent then Root.Parent = LP:WaitForChild("PlayerGui") end

-- ================== UI HELPERS ==================
local function corner(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 8); return c end
local function stroke(p,c,t,tr) local s=Instance.new("UIStroke",p); s.Color=c or CFG.Theme.stroke; s.Thickness=t or 1; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end
local function pad(p,x,y) local u=Instance.new("UIPadding",p); u.PaddingLeft=UDim.new(0,x); u.PaddingRight=UDim.new(0,x); u.PaddingTop=UDim.new(0,y or x); u.PaddingBottom=UDim.new(0,y or x); return u end
local function solid(parent,size,pos,color) local f=Instance.new("Frame",parent); f.Size=size; f.Position=pos or UDim2.new(); f.BackgroundColor3=color; f.BorderSizePixel=0; return f end
local function grad(parent, c1, c2, rot) local g=Instance.new("UIGradient",parent); g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,c1), ColorSequenceKeypoint.new(1,c2)}; g.Rotation=rot or 90; return g end
local function txt(parent,t,size,color,font,align)
    local l=Instance.new("TextLabel",parent); l.BackgroundTransparency=1; l.Text=t; l.TextSize=size or 13; l.TextColor3=color or CFG.Theme.text; l.Font=font or Enum.Font.Gotham; l.TextXAlignment=align or Enum.TextXAlignment.Left; return l
end
local function drag(top, frame)
    local dragging, start, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; start=input.Position; startPos=frame.Position
            input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local d = input.Position - start
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end

local NG = Instance.new("Frame", Root)
NG.Size=UDim2.new(0,320,1,0); NG.Position=UDim2.new(1,-340,0,20); NG.BackgroundTransparency=1
local nlL = Instance.new("UIListLayout", NG); nlL.Padding=UDim.new(0,8)
local function notify(title, msg, kind, dur)
    local color = kind=="ok" and CFG.Theme.ok or (kind=="err" and CFG.Theme.err or CFG.Theme.accent)
    local c = Instance.new("Frame", NG); c.BackgroundColor3=CFG.Theme.panel; c.Size=UDim2.new(1,0,0,64); corner(c,10); stroke(c,color,1,0.3)
    solid(c, UDim2.new(0,4,1,0), nil, color)
    local tl = txt(c, title or "Bad", 14, color, Enum.Font.GothamBold); tl.Position=UDim2.new(0,14,0,8); tl.Size=UDim2.new(1,-20,0,18)
    local ml = txt(c, msg or "", 12, CFG.Theme.text); ml.Position=UDim2.new(0,14,0,28); ml.Size=UDim2.new(1,-20,0,34); ml.TextWrapped=true; ml.TextYAlignment=Enum.TextYAlignment.Top
    task.delay(dur or 4, function() TweenService:Create(c, TweenInfo.new(0.3),{BackgroundTransparency=1}):Play(); task.wait(0.3); c:Destroy() end)
end

local function pwdBox(parent)
    local tb = Instance.new("TextBox", parent); tb.BackgroundTransparency=1; tb.Text=""; tb.ClearTextOnFocus=false
    local real = ""
    tb:GetPropertyChangedSignal("Text"):Connect(function()
        if tb.Text == string.rep("*", #real) then return end
        local nt = tb.Text
        if #nt < #real then real = real:sub(1, #nt) else real = real .. nt:sub(#real+1) end
        tb.Text = string.rep("*", #real); tb.CursorPosition = #tb.Text + 1
    end)
    function tb:GetReal() return real end
    return tb
end

-- ================== FOV ==================
local FovCircle
pcall(function() FovCircle = Drawing.new("Circle"); FovCircle.Thickness=1.5; FovCircle.NumSides=64; FovCircle.Radius=120; FovCircle.Filled=false; FovCircle.Color=CFG.Theme.accent; FovCircle.Transparency=1; FovCircle.Visible=false end)

-- ================== CORE FUNCS ==================
local function rootPart(plr) local c=plr and plr.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function humOf(plr)   local c=plr and plr.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function alive(plr)   local h=humOf(plr); return h and h.Health>0 and rootPart(plr) end
local function teamCheck(plr) if not State.aimTeamCheck then return true end; if not plr.Team or not LP.Team then return true end; return plr.Team ~= LP.Team end
local function w2s(pos) local v,vis=Camera:WorldToViewportPoint(pos); return Vector2.new(v.X,v.Y), vis and v.Z>0 end
local function raycastVisible(fromPos, toPos)
    local p = RaycastParams.new(); p.FilterType=Enum.RaycastFilterType.Exclude; p.FilterDescendantsInstances={LP.Character}
    return not Workspace:Raycast(fromPos, toPos-fromPos, p)
end
local function getTarget()
    local best, bestD = nil, State.aimFOV
    local mp = UIS:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and alive(plr) and teamCheck(plr) then
            local part = plr.Character:FindFirstChild(State.aimPart) or rootPart(plr)
            if part then
                local s, ok = w2s(part.Position)
                if ok then
                    local dx, dy = s.X-mp.X, s.Y-mp.Y
                    local d = math.sqrt(dx*dx + dy*dy)
                    if d < bestD then
                        if not State.aimVisibleOnly or raycastVisible(Camera.CFrame.Position, part.Position) then
                            best, bestD = plr, d
                        end
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if FovCircle then
        if State.aimbot and State.aimDrawFOV then
            local mp = UIS:GetMouseLocation()
            FovCircle.Position = Vector2.new(mp.X, mp.Y); FovCircle.Radius = State.aimFOV; FovCircle.Visible = true
        else FovCircle.Visible = false end
    end
    if State.aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = getTarget()
        if t then
            local part = t.Character and (t.Character:FindFirstChild(State.aimPart) or t.Character:FindFirstChild("HumanoidRootPart"))
            if part then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), math.clamp(1 - State.aimSmooth, 0.01, 1)) end
        end
    end
end)

-- silent aim hook lazy
local silentInstalled = false
local function installSilent()
    if silentInstalled then return end
    local nm = getnamecallmethod or get_namecall_method
    if not (hookmetamethod and nm and checkcaller) then notify("Silent","Executor nao suporta hooks.","err",3); return end
    pcall(function()
        local oldIdx
        oldIdx = hookmetamethod(game, "__index", function(self, k)
            if State.silentAim and not checkcaller() then
                if typeof(self)=="Instance" and self:IsA("Mouse") then
                    if k=="Hit" or k=="hit" then
                        local t = getTarget(); if t and t.Character then local p = t.Character:FindFirstChild(State.aimPart) or rootPart(t); if p then return p.CFrame end end
                    elseif k=="Target" or k=="target" then
                        local t = getTarget(); if t and t.Character then return t.Character:FindFirstChild(State.aimPart) or rootPart(t) end
                    end
                end
            end
            return oldIdx(self, k)
        end)
    end)
    silentInstalled = true
end

-- ESP
local ESP = {}
local function mkd(k, p) local ok, d = pcall(function() return Drawing.new(k) end); if ok then for a, b in pairs(p) do d[a] = b end; return d end end
local function buildESP(plr)
    if ESP[plr] then return end
    ESP[plr] = {
        box=mkd("Square",{Thickness=1,Filled=false,Color=CFG.Theme.accent,Transparency=1,Visible=false,ZIndex=2}),
        boxOut=mkd("Square",{Thickness=3,Filled=false,Color=Color3.new(0,0,0),Transparency=1,Visible=false,ZIndex=1}),
        name=mkd("Text",{Size=14,Center=true,Outline=true,Color=CFG.Theme.text,Font=2,Visible=false}),
        health=mkd("Text",{Size=12,Center=true,Outline=true,Color=Color3.new(0,1,0),Font=2,Visible=false}),
        dist=mkd("Text",{Size=12,Center=true,Outline=true,Color=CFG.Theme.muted,Font=2,Visible=false}),
        tracer=mkd("Line",{Thickness=1,Color=CFG.Theme.accent,Transparency=1,Visible=false}),
        highlight=nil,
    }
end
local function clearESP(plr)
    local d = ESP[plr]; if not d then return end
    for _, v in pairs(d) do if typeof(v)=="table" and v.Remove then pcall(v.Remove, v) elseif typeof(v)=="Instance" then v:Destroy() end end
    ESP[plr] = nil
end
RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if not alive(plr) then
            if ESP[plr] then for _, v in pairs(ESP[plr]) do if typeof(v)=="table" and v.Visible~=nil then v.Visible=false end end; if ESP[plr].highlight then ESP[plr].highlight.Enabled=false end end
            continue
        end
        if not ESP[plr] then buildESP(plr) end
        local d = ESP[plr]; local char = plr.Character; local hrp = rootPart(plr); local hd = humOf(plr); local head = char:FindFirstChild("Head")
        local s, vis = w2s(hrp.Position)
        local show = State.espBox or State.espName or State.espHealth or State.espDistance or State.espTracer
        if not vis or not show then
            for _, v in pairs(d) do if typeof(v)=="table" and v.Visible~=nil then v.Visible=false end end
        else
            local topS = head and select(1, w2s(head.Position + Vector3.new(0,0.5,0))) or s
            local botS = select(1, w2s(hrp.Position - Vector3.new(0,3,0)))
            local h = math.abs(botS.Y - topS.Y); local w = h/2; local x = s.X - w/2; local y = topS.Y
            if d.box then d.box.Visible=State.espBox; d.box.Size=Vector2.new(w,h); d.box.Position=Vector2.new(x,y); d.boxOut.Visible=State.espBox; d.boxOut.Size=Vector2.new(w,h); d.boxOut.Position=Vector2.new(x,y) end
            if d.name then d.name.Visible=State.espName; d.name.Text=plr.DisplayName; d.name.Position=Vector2.new(s.X, y-16) end
            if d.health and hd then d.health.Visible=State.espHealth; d.health.Text=string.format("HP %d/%d", math.floor(hd.Health), math.floor(hd.MaxHealth)); d.health.Position=Vector2.new(s.X, y+h+2); d.health.Color=Color3.fromRGB(math.floor(255*(1-hd.Health/hd.MaxHealth)), math.floor(255*(hd.Health/hd.MaxHealth)), 50) end
            if d.dist then local dist = (Camera.CFrame.Position - hrp.Position).Magnitude; d.dist.Visible=State.espDistance; d.dist.Text=string.format("[%dm]", math.floor(dist)); d.dist.Position=Vector2.new(s.X, y+h+(State.espHealth and 14 or 2)) end
            if d.tracer then d.tracer.Visible=State.espTracer; d.tracer.From=Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); d.tracer.To=Vector2.new(s.X, s.Y) end
            if State.espChams then
                if not d.highlight then d.highlight = Instance.new("Highlight"); d.highlight.FillColor=CFG.Theme.accent; d.highlight.OutlineColor=Color3.new(1,1,1); d.highlight.FillTransparency=0.5; d.highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; d.highlight.Parent=char end
                d.highlight.Enabled=true; d.highlight.Adornee=char
            elseif d.highlight then d.highlight.Enabled=false end
        end
    end
end)
Players.PlayerRemoving:Connect(clearESP)

RunService.Stepped:Connect(function()
    local h = humOf(LP)
    if h then
        if State.walkspeedDirty and math.abs(h.WalkSpeed - State.walkspeed) > 0.5 then h.WalkSpeed = State.walkspeed end
        if State.jumppowerDirty and math.abs(h.JumpPower - State.jumppower) > 0.5 then h.JumpPower = State.jumppower end
    end
    if State.gravityDirty then Workspace.Gravity = State.gravity end
    if State.noclip and LP.Character then for _, p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    if State.fullbright then Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.GlobalShadows=false; Lighting.Ambient=Color3.fromRGB(180,180,180) end
    if State.noFog then Lighting.FogEnd=1e6 end
end)
UIS.JumpRequest:Connect(function() if State.inf_jump then local h=humOf(LP); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)

local flyBV, flyBG
local function startFly() local hrp = rootPart(LP); if not hrp then return end; flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1e5,1e5,1e5); flyBV.Velocity=Vector3.zero; flyBV.Parent=hrp; flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5); flyBG.P=1e4; flyBG.Parent=hrp end
local function stopFly() if flyBV then flyBV:Destroy(); flyBV=nil end; if flyBG then flyBG:Destroy(); flyBG=nil end end
RunService.Heartbeat:Connect(function()
    if State.fly and flyBV then
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
        flyBV.Velocity = dir.Magnitude>0 and dir.Unit*State.flySpeed or Vector3.zero
        flyBG.CFrame = Camera.CFrame
    end
end)

local function tryGive(tool, isClone)
    local ok = false
    pcall(function()
        if tool:IsA("Tool") and LP:FindFirstChild("Backpack") then
            if LP.Backpack:FindFirstChild(tool.Name) and isClone then return end
            tool.Parent = LP.Backpack; ok = true
        end
    end)
    if not ok and not isClone then
        local hrp = rootPart(LP)
        if hrp then
            local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
            if handle then pcall(function() handle.CFrame = hrp.CFrame * CFrame.new(0,0,-2) end); ok = true end
        end
    end
    return ok
end
local function pullAll()
    local n = 0
    if State.pullWorkspace then for _, obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("Tool") and obj.Parent and not obj.Parent:IsA("Backpack") and not obj.Parent:IsA("Player") then if tryGive(obj) then n=n+1 end end end end
    if State.pullTeams then for _, team in ipairs(Teams:GetTeams()) do for _, obj in ipairs(team:GetDescendants()) do if obj:IsA("Tool") then if tryGive(obj) then n=n+1 end end end end end
    if State.pullServerStorage and ServerStorage then pcall(function() for _, obj in ipairs(ServerStorage:GetDescendants()) do if obj:IsA("Tool") then if tryGive(obj) then n=n+1 end end end end) end
    if State.pullReplicated then pcall(function() for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do if obj:IsA("Tool") then if LP:FindFirstChild("Backpack") and not LP.Backpack:FindFirstChild(obj.Name) then local c = obj:Clone(); if tryGive(c, true) then n=n+1 else c:Destroy() end end end end end) end
    if State.pullOthers then for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP then if plr:FindFirstChild("Backpack") then for _, t in ipairs(plr.Backpack:GetChildren()) do if t:IsA("Tool") then if tryGive(t) then n=n+1 end end end end; if plr.Character then for _, t in ipairs(plr.Character:GetChildren()) do if t:IsA("Tool") then if tryGive(t) then n=n+1 end end end end end end end
    return n
end
task.spawn(function() while task.wait(2) do if State.pullWeapons then pullAll() end end end)

-- ============================================================
-- AUTH SCREEN (chama backend)
-- ============================================================
local function openAuth(onPass)
    local overlay = Instance.new("Frame", Root); overlay.Size=UDim2.new(1,0,1,0); overlay.BackgroundColor3=Color3.fromRGB(5,5,8); overlay.BackgroundTransparency=0.4; overlay.Active=true
    local W, H = 720, 460
    local win = Instance.new("Frame", Root); win.Size=UDim2.new(0,W,0,H); win.Position=UDim2.new(0.5,-W/2,0.5,-H/2); win.BackgroundColor3=CFG.Theme.bg; win.Active=true
    corner(win, 14); stroke(win, CFG.Theme.strokeHi, 1.5, 0.2)

    local art = Instance.new("Frame", win); art.Size=UDim2.new(0,280,1,0); art.BackgroundColor3=CFG.Theme.bgDeep; corner(art,14)
    local clip = Instance.new("Frame", art); clip.Size=UDim2.new(1,0,1,0); clip.BackgroundColor3=CFG.Theme.bgDeep; clip.BorderSizePixel=0; clip.ClipsDescendants=true; corner(clip,14)
    grad(clip, CFG.Theme.accentDk, CFG.Theme.bgDeep, 135)
    local bl = txt(clip, "BAD", 64, CFG.Theme.accent, Enum.Font.GothamBlack); bl.Position=UDim2.new(0,24,0,36); bl.Size=UDim2.new(0,232,0,70)
    local tag = txt(clip, "ROBLOX FPS HUB", 11, CFG.Theme.textDim, Enum.Font.GothamBold); tag.Position=UDim2.new(0,26,0,110); tag.Size=UDim2.new(0,230,0,16)
    local pill = Instance.new("Frame", clip); pill.Size=UDim2.new(0,78,0,22); pill.Position=UDim2.new(0,24,0,132); pill.BackgroundColor3=CFG.Theme.panel2; corner(pill,11); stroke(pill, CFG.Theme.accent, 1, 0.3)
    solid(pill, UDim2.new(0,8,0,8), UDim2.new(0,10,0.5,-4), CFG.Theme.accent)
    local pt = txt(pill, "ONLINE", 10, CFG.Theme.accent, Enum.Font.GothamBold); pt.Position=UDim2.new(0,24,0,0); pt.Size=UDim2.new(1,-24,1,0)
    local pitch = txt(clip, "Aimbot + FOV\nESP completo\nSilent Aim\nFly + Noclip\nPull Weapons\nTeleport Players", 13, CFG.Theme.textDim); pitch.Position=UDim2.new(0,24,0,170); pitch.Size=UDim2.new(0,232,0,120); pitch.TextWrapped=true
    solid(clip, UDim2.new(0,232,0,1), UDim2.new(0,24,1,-100), CFG.Theme.strokeHi)
    local foot1 = txt(clip, "discord.gg/ojailbreaks", 11, CFG.Theme.muted, Enum.Font.GothamSemibold); foot1.Position=UDim2.new(0,24,1,-92); foot1.Size=UDim2.new(0,232,0,16)
    local foot2 = txt(clip, CFG.Version.." . backend online", 10, CFG.Theme.muted); foot2.Position=UDim2.new(0,24,1,-74); foot2.Size=UDim2.new(0,232,0,14)

    local form = Instance.new("Frame", win); form.Size=UDim2.new(1,-280,1,0); form.Position=UDim2.new(0,280,0,0); form.BackgroundColor3=CFG.Theme.bg; form.Active=true
    local topBar = Instance.new("Frame", form); topBar.Size=UDim2.new(1,0,0,36); topBar.BackgroundTransparency=1; topBar.Active=true
    drag(topBar, win)
    local closeB = Instance.new("TextButton", topBar); closeB.Size=UDim2.new(0,30,0,30); closeB.Position=UDim2.new(1,-40,0.5,-15); closeB.BackgroundColor3=CFG.Theme.panel2; closeB.Text="X"; closeB.TextColor3=CFG.Theme.text; closeB.Font=Enum.Font.GothamBold; closeB.TextSize=14; closeB.AutoButtonColor=false; corner(closeB,6); stroke(closeB, CFG.Theme.stroke,1,0.3)
    closeB.MouseButton1Click:Connect(function() Root:Destroy() end)

    local segmWrap = Instance.new("Frame", form); segmWrap.Size=UDim2.new(1,-48,0,40); segmWrap.Position=UDim2.new(0,24,0,46); segmWrap.BackgroundColor3=CFG.Theme.panel; corner(segmWrap,10)
    local segInner = Instance.new("Frame", segmWrap); segInner.Size=UDim2.new(1,-8,1,-8); segInner.Position=UDim2.new(0,4,0,4); segInner.BackgroundTransparency=1
    local segW = (W-280-48-8)/3
    local function segBtn(name, i) local b = Instance.new("TextButton", segInner); b.Size=UDim2.new(0,segW,1,0); b.Position=UDim2.new(0,segW*(i-1),0,0); b.BackgroundColor3=CFG.Theme.panel; b.Text=name; b.Font=Enum.Font.GothamBold; b.TextSize=12; b.TextColor3=CFG.Theme.muted; b.AutoButtonColor=false; corner(b,8); return b end
    local tLogin = segBtn("LOGIN", 1)
    local tReg   = segBtn("REGISTRAR", 2)
    local tAdm   = segBtn("ADMIN", 3)
    local body = Instance.new("Frame", form); body.Position=UDim2.new(0,24,0,102); body.Size=UDim2.new(1,-48,1,-142); body.BackgroundTransparency=1

    local function field(parent, y, labelText, placeholder, isPwd)
        local wrap = Instance.new("Frame", parent); wrap.Size=UDim2.new(1,0,0,58); wrap.Position=UDim2.new(0,0,0,y); wrap.BackgroundTransparency=1
        local lb = txt(wrap, labelText, 10, CFG.Theme.muted, Enum.Font.GothamBold); lb.Size=UDim2.new(1,0,0,14)
        local box = Instance.new("Frame", wrap); box.Size=UDim2.new(1,0,0,38); box.Position=UDim2.new(0,0,0,18); box.BackgroundColor3=CFG.Theme.panel; corner(box,8); stroke(box, CFG.Theme.stroke, 1, 0)
        local tb
        if isPwd then tb = pwdBox(box) else tb = Instance.new("TextBox", box); tb.BackgroundTransparency=1; tb.Text=""; tb.ClearTextOnFocus=false; function tb:GetReal() return self.Text end end
        tb.Size=UDim2.new(1,-24,1,0); tb.Position=UDim2.new(0,14,0,0); tb.PlaceholderText=placeholder; tb.PlaceholderColor3=CFG.Theme.muted; tb.TextColor3=CFG.Theme.text; tb.Font=Enum.Font.Gotham; tb.TextSize=13; tb.TextXAlignment=Enum.TextXAlignment.Left
        local s = box:FindFirstChildOfClass("UIStroke")
        tb.Focused:Connect(function() TweenService:Create(s,TweenInfo.new(0.15),{Color=CFG.Theme.accent, Transparency=0.1}):Play() end)
        tb.FocusLost:Connect(function() TweenService:Create(s,TweenInfo.new(0.15),{Color=CFG.Theme.stroke, Transparency=0}):Play() end)
        function wrap:GetReal() return tb:GetReal() end
        return wrap
    end
    local function bigBtn(parent, y, label, cb)
        local b = Instance.new("TextButton", parent); b.Size=UDim2.new(1,0,0,44); b.Position=UDim2.new(0,0,0,y); b.BackgroundColor3=CFG.Theme.accent; b.Text=label; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=14; b.AutoButtonColor=false; corner(b,8); stroke(b, CFG.Theme.accentHi, 1, 0.5)
        b.MouseButton1Click:Connect(cb); return b
    end

    local pLogin = Instance.new("Frame", body); pLogin.Size=UDim2.new(1,0,1,0); pLogin.BackgroundTransparency=1
    txt(pLogin, "Bem-vindo de volta", 18, CFG.Theme.text, Enum.Font.GothamBold).Size=UDim2.new(1,0,0,24)
    local h2 = txt(pLogin, "Entre com sua conta online.", 12, CFG.Theme.textDim); h2.Position=UDim2.new(0,0,0,24); h2.Size=UDim2.new(1,0,0,16)
    local fU = field(pLogin, 54,  "USUARIO", "seu usuario", false)
    local fP = field(pLogin, 118, "SENHA",   "sua senha",   true)
    local mL = txt(pLogin, "", 11, CFG.Theme.err); mL.Position=UDim2.new(0,0,0,182); mL.Size=UDim2.new(1,0,0,14)
    bigBtn(pLogin, 204, "ENTRAR", function()
        local u, p = fU:GetReal(), fP:GetReal()
        if u=="" or p=="" then mL.Text="Preencha usuario e senha."; return end
        mL.Text = "Entrando..."
        local data, err = apiCall("/login", {u=u, p=p, hwid=HWID})
        if data and data.ok then
            saveSess({user=u, token=data.token, exp=data.exp, admin=false})
            overlay:Destroy(); win:Destroy(); onPass({admin=false, user=u, exp=data.exp})
        else mL.Text = "Falha: "..tostring(err) end
    end)

    local pReg = Instance.new("Frame", body); pReg.Size=UDim2.new(1,0,1,0); pReg.BackgroundTransparency=1; pReg.Visible=false
    txt(pReg, "Criar conta com KEY", 18, CFG.Theme.text, Enum.Font.GothamBold).Size=UDim2.new(1,0,0,24)
    local r2 = txt(pReg, "Resgate sua KEY online.", 12, CFG.Theme.textDim); r2.Position=UDim2.new(0,0,0,24); r2.Size=UDim2.new(1,0,0,16)
    local fK  = field(pReg, 50,  "KEY",     "BAD-XXXXX-XXXXX-XXXXX-XXXXX", false)
    local fU2 = field(pReg, 112, "USUARIO", "3-16 caracteres", false)
    local fP2 = field(pReg, 174, "SENHA",   "minimo 6 caracteres", true)
    local mR = txt(pReg, "", 11, CFG.Theme.err); mR.Position=UDim2.new(0,0,0,236); mR.Size=UDim2.new(1,0,0,14)
    bigBtn(pReg, 258, "REGISTRAR E ENTRAR", function()
        local k, u, p = fK:GetReal(), fU2:GetReal(), fP2:GetReal()
        if k=="" or u=="" or p=="" then mR.Text="Preencha todos os campos."; return end
        mR.Text = "Registrando..."
        local data, err = apiCall("/register", {u=u, p=p, k=k, hwid=HWID})
        if data and data.ok then
            local lg, err2 = apiCall("/login", {u=u, p=p, hwid=HWID})
            if lg and lg.ok then
                saveSess({user=u, token=lg.token, exp=lg.exp, admin=false})
                overlay:Destroy(); win:Destroy(); onPass({admin=false, user=u, exp=lg.exp})
            else mR.Text = "Registrado mas login falhou: "..tostring(err2) end
        else mR.Text = "Falha: "..tostring(err) end
    end)

    local pAdm = Instance.new("Frame", body); pAdm.Size=UDim2.new(1,0,1,0); pAdm.BackgroundTransparency=1; pAdm.Visible=false
    txt(pAdm, "Acesso administrativo", 18, CFG.Theme.text, Enum.Font.GothamBold).Size=UDim2.new(1,0,0,24)
    local a2 = txt(pAdm, "Bypass offline do sistema de key.", 12, CFG.Theme.textDim); a2.Position=UDim2.new(0,0,0,24); a2.Size=UDim2.new(1,0,0,16)
    local fAU = field(pAdm, 54,  "USUARIO ADMIN", "admin", false)
    local fAP = field(pAdm, 118, "SENHA ADMIN",   "senha", true)
    local mA = txt(pAdm, "", 11, CFG.Theme.err); mA.Position=UDim2.new(0,0,0,182); mA.Size=UDim2.new(1,0,0,14)
    bigBtn(pAdm, 204, "ENTRAR COMO ADMIN", function()
        local u, p = fAU:GetReal(), fAP:GetReal()
        if u==CFG.Admin.user and p==CFG.Admin.pass then
            saveSess({user=CFG.Admin.user, admin=true, time=os.time()})
            overlay:Destroy(); win:Destroy(); onPass({admin=true, user=CFG.Admin.user})
        else mA.Text = "Credenciais invalidas." end
    end)

    local pages = {[tLogin]=pLogin, [tReg]=pReg, [tAdm]=pAdm}
    local function setTab(t) for tb, pg in pairs(pages) do pg.Visible=(tb==t); tb.BackgroundColor3=(tb==t) and CFG.Theme.accent or CFG.Theme.panel; tb.TextColor3=(tb==t) and Color3.new(1,1,1) or CFG.Theme.muted end end
    tLogin.MouseButton1Click:Connect(function() setTab(tLogin) end)
    tReg.MouseButton1Click:Connect(function() setTab(tReg) end)
    tAdm.MouseButton1Click:Connect(function() setTab(tAdm) end)
    setTab(tLogin)
end

-- ============================================================
-- HUD (full) — mesmo do v8, adaptado
-- ============================================================
local function buildHUD(sess)
    local isAdmin = sess.admin == true
    local W, H = 640, 420
    local win = Instance.new("Frame", Root); win.Size=UDim2.new(0,W,0,H); win.Position=UDim2.new(0.5,-W/2,0.5,-H/2); win.BackgroundColor3=CFG.Theme.bg; win.Active=true
    corner(win, 12); stroke(win, CFG.Theme.strokeHi, 1.5, 0.3)
    local hdr = Instance.new("Frame", win); hdr.Size=UDim2.new(1,0,0,48); hdr.BackgroundColor3=CFG.Theme.panel; hdr.Active=true; corner(hdr,12)
    solid(hdr, UDim2.new(1,0,0.5,0), UDim2.new(0,0,0.5,0), CFG.Theme.panel)
    local al = solid(hdr, UDim2.new(1,0,0,2), UDim2.new(0,0,1,-2), CFG.Theme.accent); grad(al, CFG.Theme.accentLo, CFG.Theme.accent, 0)
    local logo = txt(hdr, "BAD", 22, CFG.Theme.accent, Enum.Font.GothamBlack); logo.Position=UDim2.new(0,16,0,0); logo.Size=UDim2.new(0,60,1,0)
    local ver = txt(hdr, CFG.Version, 10, CFG.Theme.muted); ver.Position=UDim2.new(0,78,0,17); ver.Size=UDim2.new(0,40,0,14)
    local pill = Instance.new("Frame", hdr); pill.AnchorPoint=Vector2.new(0.5,0.5); pill.Position=UDim2.new(0.5,0,0.5,0); pill.Size=UDim2.new(0,220,0,28); pill.BackgroundColor3=CFG.Theme.panel2; corner(pill,14); stroke(pill, CFG.Theme.stroke,1,0.3)
    solid(pill, UDim2.new(0,8,0,8), UDim2.new(0,14,0.5,-4), isAdmin and CFG.Theme.accent or CFG.Theme.ok)
    local userTxt = txt(pill, (isAdmin and "ADMIN . " or "USER . ") .. (sess.user or "-"), 12, isAdmin and CFG.Theme.accent or CFG.Theme.text, Enum.Font.GothamBold); userTxt.Position=UDim2.new(0,28,0,0); userTxt.Size=UDim2.new(1,-32,1,0)
    local function ibtn(ts, x, cb) local b = Instance.new("TextButton", hdr); b.Size=UDim2.new(0,30,0,30); b.Position=UDim2.new(1,x,0.5,-15); b.BackgroundColor3=CFG.Theme.panel2; b.Text=ts; b.TextColor3=CFG.Theme.text; b.Font=Enum.Font.GothamBold; b.TextSize=14; b.AutoButtonColor=false; corner(b,8); stroke(b, CFG.Theme.stroke,1,0.3); b.MouseButton1Click:Connect(cb); return b end
    ibtn("-", -82, function() win.Visible=false end)
    ibtn("X", -44, function() Root:Destroy() end)
    drag(hdr, win)

    local side = Instance.new("Frame", win); side.Size=UDim2.new(0,150,1,-56); side.Position=UDim2.new(0,8,0,52); side.BackgroundColor3=CFG.Theme.side; side.Active=true; corner(side,10); stroke(side, CFG.Theme.stroke,1,0.5)
    local ll = Instance.new("UIListLayout", side); ll.Padding=UDim.new(0,4); pad(side, 8)
    local content = Instance.new("Frame", win); content.Size=UDim2.new(1,-166,1,-56); content.Position=UDim2.new(0,162,0,52); content.BackgroundColor3=CFG.Theme.panel; content.Active=true; corner(content,10); stroke(content, CFG.Theme.stroke,1,0.5)

    local pages = {}
    local function makePage(name) local p = Instance.new("ScrollingFrame", content); p.Visible=false; p.Active=true; p.Size=UDim2.new(1,0,1,0); p.BackgroundTransparency=1; p.BorderSizePixel=0; p.ScrollBarThickness=4; p.ScrollBarImageColor3=CFG.Theme.accent; p.CanvasSize=UDim2.new(0,0,0,0); p.AutomaticCanvasSize=Enum.AutomaticSize.Y; local uil = Instance.new("UIListLayout", p); uil.Padding=UDim.new(0,8); pad(p, 12); pages[name]=p; return p end
    local activeTab
    local function tabBtn(name, order) local b = Instance.new("TextButton", side); b.Size=UDim2.new(1,0,0,32); b.BackgroundColor3=CFG.Theme.side; b.Text=""; b.AutoButtonColor=false; b.LayoutOrder=order; corner(b,8); local ab = solid(b, UDim2.new(0,3,0.6,0), UDim2.new(0,0,0.2,0), CFG.Theme.accent); ab.Visible=false; corner(ab,2); local tx = txt(b, name, 12, CFG.Theme.text, Enum.Font.GothamSemibold); tx.Position=UDim2.new(0,16,0,0); tx.Size=UDim2.new(1,-20,1,0); b.MouseButton1Click:Connect(function() for n, pg in pairs(pages) do pg.Visible=(n==name) end; if activeTab then activeTab.BackgroundColor3=CFG.Theme.side; local ob = activeTab:FindFirstChild("Frame"); if ob then ob.Visible=false end end; b.BackgroundColor3=CFG.Theme.panel2; ab.Visible=true; activeTab=b end); return b end

    local function section(page, label) local w = Instance.new("Frame", page); w.Size=UDim2.new(1,0,0,22); w.BackgroundTransparency=1; local bar = solid(w, UDim2.new(0,3,0,14), UDim2.new(0,0,0.5,-7), CFG.Theme.accent); corner(bar,2); local l = txt(w, string.upper(label), 11, CFG.Theme.accent, Enum.Font.GothamBold); l.Position=UDim2.new(0,10,0,0); l.Size=UDim2.new(1,-10,1,0); return w end
    local function row(page, h) local r = Instance.new("Frame", page); r.Size=UDim2.new(1,0,0,h or 32); r.BackgroundColor3=CFG.Theme.row; corner(r,8); stroke(r, CFG.Theme.stroke, 1, 0.5); return r end
    local function toggle(page, label, def, cb)
        local r = row(page, 32); local l = txt(r, label, 12); l.Position=UDim2.new(0,14,0,0); l.Size=UDim2.new(1,-60,1,0)
        local sw = Instance.new("TextButton", r); sw.Size=UDim2.new(0,38,0,20); sw.Position=UDim2.new(1,-48,0.5,-10); sw.BackgroundColor3=Color3.fromRGB(50,50,55); sw.Text=""; sw.AutoButtonColor=false; corner(sw,10)
        local dot = Instance.new("Frame", sw); dot.Size=UDim2.new(0,16,0,16); dot.Position=UDim2.new(0,2,0.5,-8); dot.BackgroundColor3=Color3.new(1,1,1); corner(dot,8)
        local st = def and true or false
        local function render() if st then TweenService:Create(sw,TweenInfo.new(0.15),{BackgroundColor3=CFG.Theme.accent}):Play(); TweenService:Create(dot,TweenInfo.new(0.15),{Position=UDim2.new(0,20,0.5,-8)}):Play() else TweenService:Create(sw,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(50,50,55)}):Play(); TweenService:Create(dot,TweenInfo.new(0.15),{Position=UDim2.new(0,2,0.5,-8)}):Play() end end
        render(); sw.MouseButton1Click:Connect(function() st=not st; render(); cb(st) end)
    end
    local function slider(page, label, mn, mx, def, cb)
        local r = row(page, 50); local l = txt(r, label, 12); l.Position=UDim2.new(0,14,0,6); l.Size=UDim2.new(1,-70,0,18)
        local val = txt(r, tostring(def), 12, CFG.Theme.accent, Enum.Font.GothamBold, Enum.TextXAlignment.Right); val.Position=UDim2.new(1,-62,0,6); val.Size=UDim2.new(0,50,0,18)
        local track = solid(r, UDim2.new(1,-28,0,5), UDim2.new(0,14,1,-14), Color3.fromRGB(40,40,45)); corner(track,3)
        local fill = solid(track, UDim2.new((def-mn)/(mx-mn),0,1,0), nil, CFG.Theme.accent); corner(fill,3)
        local dragging = false
        track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
        UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local rel = math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1); local v = math.floor(mn + (mx-mn)*rel + 0.5); fill.Size = UDim2.new(rel,0,1,0); val.Text = tostring(v); cb(v) end end)
    end
    local function button(page, label, cb, kind) local b = Instance.new("TextButton", page); b.Size=UDim2.new(1,0,0,34); b.BackgroundColor3=(kind=="primary") and CFG.Theme.accent or CFG.Theme.accentLo; b.Text=label; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=12; b.AutoButtonColor=false; corner(b,8); stroke(b, CFG.Theme.accent, 1, (kind=="primary") and 1 or 0.3); b.MouseButton1Click:Connect(cb); return b end
    local function dropdown(page, label, opts, def, cb) local r = row(page, 32); local l = txt(r, label, 12); l.Position=UDim2.new(0,14,0,0); l.Size=UDim2.new(1,-120,1,0); local b = Instance.new("TextButton", r); b.Size=UDim2.new(0,100,0,22); b.Position=UDim2.new(1,-110,0.5,-11); b.BackgroundColor3=CFG.Theme.panel2; b.Text=def; b.TextColor3=CFG.Theme.accent; b.Font=Enum.Font.GothamBold; b.TextSize=11; b.AutoButtonColor=false; corner(b,6); stroke(b, CFG.Theme.accent, 1, 0.4); local idx = 1; for i, v in ipairs(opts) do if v==def then idx=i end end; b.MouseButton1Click:Connect(function() idx=idx%#opts+1; b.Text=opts[idx]; cb(opts[idx]) end) end
    local function labelLine(page, t, color) local l = txt(page, t, 11, color or CFG.Theme.textDim); l.Size=UDim2.new(1,0,0,16); l.TextWrapped=true; return l end

    local pJog = makePage("Jogador"); tabBtn("Jogador", 1)
    local pVis = makePage("Visual");  tabBtn("Visual", 2)
    local pAim = makePage("Aim");     tabBtn("Aim", 3)
    local pArm = makePage("Armas");   tabBtn("Armas", 4)
    local pOn  = makePage("Online");  tabBtn("Online", 5)
    local pCfg = makePage("Config");  tabBtn("Config", 6)
    local pKey; if isAdmin then pKey = makePage("Gerar Key"); tabBtn("Gerar Key", 7) end

    -- JOGADOR
    section(pJog, "Movimento")
    labelLine(pJog, "Sliders so aplicam quando VOCE os move.")
    slider(pJog, "WalkSpeed", 16, 500, 16, function(v) State.walkspeed=v; State.walkspeedDirty=true end)
    slider(pJog, "JumpPower", 50, 500, 50, function(v) State.jumppower=v; State.jumppowerDirty=true end)
    slider(pJog, "Gravity",    0, 196, 196, function(v) State.gravity=v; State.gravityDirty=true end)
    button(pJog, "Devolver controle ao jogo", function()
        State.walkspeedDirty=false; State.jumppowerDirty=false; State.gravityDirty=false
        local h = humOf(LP); if h then h.WalkSpeed=16; h.JumpPower=50 end; Workspace.Gravity=196.2
        notify("Jogador", "Sprint devolvido ao ACS.", "ok", 3)
    end)
    section(pJog, "Toggles")
    toggle(pJog, "Noclip", false, function(v) State.noclip=v end)
    toggle(pJog, "Infinite Jump", false, function(v) State.inf_jump=v end)
    toggle(pJog, "Fly (WASD + Space/Ctrl)", false, function(v) State.fly=v; if v then startFly() else stopFly() end end)
    slider(pJog, "Fly Speed", 20, 300, 50, function(v) State.flySpeed=v end)
    button(pJog, "Respawn", function() if LP.Character then LP.Character:BreakJoints() end end)

    -- VISUAL
    section(pVis, "ESP")
    toggle(pVis, "Box 2D", false, function(v) State.espBox=v end)
    toggle(pVis, "Nome", false, function(v) State.espName=v end)
    toggle(pVis, "Vida", false, function(v) State.espHealth=v end)
    toggle(pVis, "Distancia", false, function(v) State.espDistance=v end)
    toggle(pVis, "Tracer", false, function(v) State.espTracer=v end)
    toggle(pVis, "Chams (Highlight)", false, function(v) State.espChams=v end)
    section(pVis, "Ambiente")
    toggle(pVis, "Fullbright", false, function(v) State.fullbright=v end)
    toggle(pVis, "Remover Neblina", false, function(v) State.noFog=v end)

    -- AIM
    section(pAim, "Aimbot")
    toggle(pAim, "Aimbot (botao direito)", false, function(v) State.aimbot=v end)
    toggle(pAim, "Desenhar circulo FOV", false, function(v) State.aimDrawFOV=v end)
    slider(pAim, "FOV (px)", 20, 500, 120, function(v) State.aimFOV=v end)
    slider(pAim, "Smooth %", 0, 99, 25, function(v) State.aimSmooth=v/100 end)
    dropdown(pAim, "Mirar em", {"Head","HumanoidRootPart","UpperTorso"}, "Head", function(v) State.aimPart=v end)
    toggle(pAim, "Team Check", false, function(v) State.aimTeamCheck=v end)
    toggle(pAim, "Apenas visivel", false, function(v) State.aimVisibleOnly=v end)
    section(pAim, "Silent Aim")
    toggle(pAim, "Silent Aim", false, function(v) State.silentAim=v; if v then installSilent() end end)

    -- ARMAS
    section(pArm, "Fontes")
    toggle(pArm, "Workspace (dropadas)", true, function(v) State.pullWorkspace=v end)
    toggle(pArm, "ServerStorage", false, function(v) State.pullServerStorage=v end)
    toggle(pArm, "ReplicatedStorage (CLONA)", false, function(v) State.pullReplicated=v end)
    toggle(pArm, "Tools dos Times", false, function(v) State.pullTeams=v end)
    toggle(pArm, "Tools de outros", false, function(v) State.pullOthers=v end)
    section(pArm, "Ativar")
    toggle(pArm, "Puxar auto (2s)", false, function(v) State.pullWeapons=v end)
    button(pArm, "PUXAR AGORA", function() local n=pullAll(); notify("Armas", "Puxou "..n.." arma(s).", "ok", 3) end, "primary")

    -- ONLINE
    section(pOn, "Jogadores")
    local listFrame = Instance.new("Frame", pOn); listFrame.Size=UDim2.new(1,0,0,0); listFrame.AutomaticSize=Enum.AutomaticSize.Y; listFrame.BackgroundTransparency=1
    local function refresh()
        for _, c in ipairs(listFrame:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        if not listFrame:FindFirstChildOfClass("UIListLayout") then local lll = Instance.new("UIListLayout", listFrame); lll.Padding=UDim.new(0,4) end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local rrow = Instance.new("Frame", listFrame); rrow.Size=UDim2.new(1,0,0,30); rrow.BackgroundColor3=CFG.Theme.row; corner(rrow,6); stroke(rrow, CFG.Theme.stroke,1,0.6)
                local teamDot = solid(rrow, UDim2.new(0,8,0,8), UDim2.new(0,10,0.5,-4), plr.TeamColor and plr.TeamColor.Color or CFG.Theme.muted); corner(teamDot,8)
                local n = txt(rrow, plr.DisplayName.." (@"..plr.Name..")", 11); n.Position=UDim2.new(0,24,0,0); n.Size=UDim2.new(1,-120,1,0)
                local tp = Instance.new("TextButton", rrow); tp.Size=UDim2.new(0,52,0,22); tp.Position=UDim2.new(1,-114,0.5,-11); tp.BackgroundColor3=CFG.Theme.accentLo; tp.Text="TP"; tp.TextColor3=Color3.new(1,1,1); tp.Font=Enum.Font.GothamBold; tp.TextSize=10; corner(tp,4)
                tp.MouseButton1Click:Connect(function() local a=rootPart(LP); local b=rootPart(plr); if a and b then a.CFrame = b.CFrame * CFrame.new(0,0,3) end end)
                local look = Instance.new("TextButton", rrow); look.Size=UDim2.new(0,52,0,22); look.Position=UDim2.new(1,-58,0.5,-11); look.BackgroundColor3=CFG.Theme.panel2; look.Text="SPY"; look.TextColor3=CFG.Theme.accent; look.Font=Enum.Font.GothamBold; look.TextSize=10; corner(look,4)
                look.MouseButton1Click:Connect(function() if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then Camera.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid") end end)
            end
        end
    end
    refresh(); Players.PlayerAdded:Connect(refresh); Players.PlayerRemoving:Connect(refresh)
    button(pOn, "Atualizar", refresh)
    button(pOn, "Resetar Camera", function() Camera.CameraSubject = humOf(LP) end)

    -- CONFIG
    section(pCfg, "Atalhos")
    labelLine(pCfg, "INS = mostrar/esconder menu")
    labelLine(pCfg, "Botao direito = aimbot")
    labelLine(pCfg, "WASD + Espaco/Ctrl = fly")
    section(pCfg, "Sessao")
    button(pCfg, "LOGOUT", function() clearSess(); Root:Destroy(); notify("Logout", "Rode o loader de novo.", "ok", 3) end)
    button(pCfg, "DESCARREGAR", function() Root:Destroy() end)
    section(pCfg, "Sobre")
    labelLine(pCfg, "Bad "..CFG.Version.." . Backend: "..API_BASE)
    labelLine(pCfg, "HWID: "..HWID:sub(1,16).."...")

    -- ADMIN GEN KEY
    if isAdmin and pKey then
        section(pKey, "Gerar KEY no backend")
        local dur = "24h"
        dropdown(pKey, "Duracao", {"24h","3d","7d","1mes"}, "24h", function(v) dur=v end)
        local tokenField = field(pKey, 0, "ADMIN TOKEN (do .env)", "cole o ADMIN_TOKEN aqui", true)
        local out = Instance.new("TextBox", pKey); out.Size=UDim2.new(1,0,0,34); out.BackgroundColor3=CFG.Theme.row; out.TextColor3=CFG.Theme.accent; out.Font=Enum.Font.Code; out.TextSize=13; out.PlaceholderText="A key gerada aparece aqui..."; out.PlaceholderColor3=CFG.Theme.muted; out.Text=""; out.ClearTextOnFocus=false; corner(out,8); stroke(out, CFG.Theme.stroke,1,0.5)
        button(pKey, "GERAR KEY", function()
            if not http_request then notify("Admin","Sem http_request.","err",3); return end
            local body = HttpService:JSONEncode({dur=dur})
            local ok, res = pcall(http_request, {Url=API_BASE.."/key/gen", Method="POST", Headers={["Content-Type"]="application/json", ["x-admin-token"]=tokenField:GetReal()}, Body=body})
            if ok and res and res.StatusCode == 200 then
                local data; pcall(function() data = HttpService:JSONDecode(res.Body) end)
                if data and data.ok then
                    out.Text = data.key
                    if setclipboard then pcall(setclipboard, data.key) end
                    notify("Admin","Key gerada e enviada ao Discord.","ok",4)
                else notify("Admin","Resposta invalida.","err",3) end
            else notify("Admin","Falha (token errado?).","err",3) end
        end, "primary")
    end

    local first = side:FindFirstChildOfClass("TextButton")
    if first then first.BackgroundColor3 = CFG.Theme.panel2; local b = first:FindFirstChild("Frame"); if b then b.Visible = true end; activeTab = first; pages["Jogador"].Visible = true end

    UIS.InputBegan:Connect(function(input, gp) if gp then return end; if input.KeyCode == CFG.Toggle then win.Visible = not win.Visible end end)
    notify("Bad", isAdmin and "ADMIN logado. INS esconde." or ("Logado como "..sess.user..". INS esconde."), "ok", 4)
end

-- ============ BOOT ============
local sess = loadSess()
if sess and sess.admin then
    buildHUD({admin=true, user=sess.user or CFG.Admin.user})
elseif sess and sess.user and sess.token then
    -- revalida online
    local data, err = apiCall("/validate", {u=sess.user, token=sess.token})
    if data and data.ok then buildHUD({admin=false, user=sess.user, exp=data.exp})
    else clearSess(); openAuth(function(info) buildHUD(info) end) end
else
    openAuth(function(info) buildHUD(info) end)
end
