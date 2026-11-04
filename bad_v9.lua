-- PK Cheats Brasil v5 :: Bad Menu :: built by olivia
-- discord.gg/bad7 | hotkeys: K=menu | F1 fly | F2 speed | F3 tp | F4 stream | F5 silent

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------
local WH_KEYS   = "https://webhook.lewisakura.moe/api/webhooks/1567405397407440926/jh-HT55fohZYWjDJq4qunVdyQEUvnUOm58SYa6lNPEIeNZSGufpdiWDI1utmLeYcAsac"
local WH_LOGS   = "https://webhook.lewisakura.moe/api/webhooks/1567420040909955122/GwqHbupriadtx8DKZeosFBfOm_KMFshSwpbJbZQ2rq9EYvPUruLjknEgIygeNbi_Vbfz"
local WH_STATUS = "https://webhook.lewisakura.moe/api/webhooks/1567427417948033074/qgX3IXyzajz1PIMXsUmVereVhFgW9NDgx3EB-N7tkzYB-fqeFAuOt-UMbStoibp5dgqP"
local ADMIN_USER, ADMIN_PASS = "bad7", "1986rkrk"
local DISCORD, BRAND = "discord.gg/bad7", "PK Cheats Brasil"
local LOGO_ID = "rbxassetid://93685935272917" -- logo oficial do olivia

local THEME = {
    bg=Color3.fromRGB(10,10,12), bg2=Color3.fromRGB(18,18,22),
    card=Color3.fromRGB(24,24,28), card2=Color3.fromRGB(32,32,36),
    accent=Color3.fromRGB(220,38,38), accent2=Color3.fromRGB(170,20,20),
    accent3=Color3.fromRGB(120,10,10),
    text=Color3.fromRGB(240,240,240), text2=Color3.fromRGB(145,145,150),
    good=Color3.fromRGB(45,200,95), warn=Color3.fromRGB(255,180,40),
    danger=Color3.fromRGB(255,60,60), stroke=Color3.fromRGB(38,38,44),
}

-- lucide icons pack (IDs confirmados renderizando em qualquer executor)
local ICON = {
    home   = "rbxassetid://10709791437", -- house
    eye    = "rbxassetid://10709791768", -- eye
    bolt   = "rbxassetid://10709757998", -- zap
    target = "rbxassetid://10734950309", -- crosshair
    tp     = "rbxassetid://10709810948", -- send
    gun    = "rbxassetid://10734893493", -- sword (próximo de arma)
    skull  = "rbxassetid://10723346959", -- skull
    shield = "rbxassetid://10709769992", -- shield
    gear   = "rbxassetid://10734950070", -- settings
    key    = "rbxassetid://10709783990", -- key
    doc    = "rbxassetid://10723363268", -- file-text
    bomb   = "rbxassetid://10709757798", -- flame
    close  = "rbxassetid://10747384394", -- x
    min    = "rbxassetid://10709768513", -- minus
    chev   = "rbxassetid://10709790644", -- chevron-down
    plus   = "rbxassetid://10709768482", -- plus
    radio  = "rbxassetid://10734895698", -- radio
    sparkle= "rbxassetid://10723417871", -- sparkles
}

local DURATIONS = {{label="6 horas",seconds=6*3600},{label="24 horas",seconds=24*3600},{label="3 dias",seconds=3*86400},{label="7 dias",seconds=7*86400},{label="1 mes",seconds=30*86400},{label="1 ano",seconds=365*86400},{label="lifetime",seconds=-1}}

------------------------------------------------------------
-- SERVICES
------------------------------------------------------------
local Players=game:GetService("Players"); local RunService=game:GetService("RunService")
local UserInput=game:GetService("UserInputService"); local TweenService=game:GetService("TweenService")
local HttpService=game:GetService("HttpService"); local Workspace=game:GetService("Workspace")
local Teams=game:GetService("Teams"); local RepStorage=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting"); local CAS=game:GetService("ContextActionService")
local VirtualUser=game:GetService("VirtualUser"); local TeleportService=game:GetService("TeleportService")
local LP=Players.LocalPlayer; local Camera=Workspace.CurrentCamera
local IS_MOBILE = UserInput.TouchEnabled and not UserInput.KeyboardEnabled

local function get_hwid() local h="unknown"; pcall(function() if gethwid then h=gethwid() end end); if h=="unknown" then pcall(function() h=game:GetService("RbxAnalyticsService"):GetClientId() end) end; return tostring(h) end
local HWID=get_hwid(); local EXE="unknown"; pcall(function() if identifyexecutor then EXE=identifyexecutor() end end)

------------------------------------------------------------
-- FS + DB
------------------------------------------------------------
local FS_OK = type(writefile)=="function" and type(readfile)=="function" and type(isfile)=="function" and type(makefolder)=="function"
if FS_OK then pcall(function() makefolder("PKCheats") end) end
local function fs_read(p,f) if not FS_OK or not isfile(p) then return f end local ok,v=pcall(readfile,p); return ok and v or f end
local function fs_write(p,d) if FS_OK then pcall(writefile,p,d) end end
local function load_json(p,d) local r=fs_read(p,nil); if not r then return d end local ok,v=pcall(HttpService.JSONDecode,HttpService,r); return ok and v or d end
local function save_json(p,t) local ok,v=pcall(HttpService.JSONEncode,HttpService,t); if ok then fs_write(p,v) end end

local P_KEYS,P_USERS,P_SESS,P_LOGS,P_CFG="PKCheats/keys.json","PKCheats/users.json","PKCheats/session.json","PKCheats/logs.json","PKCheats/cfg.json"
local KeyDB=load_json(P_KEYS,{})
local UserDB=load_json(P_USERS,{})
UserDB[ADMIN_USER]=UserDB[ADMIN_USER] or {pass=ADMIN_PASS,admin=true,key="LIFETIME-ADMIN",exp=-1,created=os.time(),hwid=HWID}
UserDB[ADMIN_USER].admin=true; UserDB[ADMIN_USER].hwid=HWID; save_json(P_USERS,UserDB)
local Session=load_json(P_SESS,{user=nil})
local LogDB=load_json(P_LOGS,{})
local CfgDB=load_json(P_CFG,{accent={220,38,38},transparency=0.12})
THEME.accent=Color3.fromRGB(table.unpack(CfgDB.accent))

------------------------------------------------------------
-- WEBHOOK
------------------------------------------------------------
local function http_send(url,body)
    local req=http_request or (syn and syn.request) or request or (fluxus and fluxus.request)
    if req then pcall(req,{Url=url,Method="POST",Headers={["Content-Type"]="application/json"},Body=body})
    else pcall(function() HttpService:PostAsync(url,body,Enum.HttpContentType.ApplicationJson) end) end
end
local function hook_embed(url,title,color,fields,desc)
    http_send(url,HttpService:JSONEncode({username=BRAND,embeds={{title=title,description=desc or "",color=color or 14362437,fields=fields or {},footer={text=BRAND.." • "..DISCORD.." • "..EXE},timestamp=DateTime.now():ToIsoDate()}}}))
end
local function log(action,detail,color)
    table.insert(LogDB,{t=os.time(),action=action,detail=detail}); if #LogDB>500 then table.remove(LogDB,1) end; save_json(P_LOGS,LogDB)
    local fields={}
    if type(detail)=="table" then for k,v in pairs(detail) do table.insert(fields,{name=tostring(k),value="`"..tostring(v).."`",inline=true}) end
    else table.insert(fields,{name="detalhe",value=tostring(detail),inline=false}) end
    hook_embed(WH_LOGS,action,color or 5793266,fields)
end

------------------------------------------------------------
-- KEY SYSTEM
------------------------------------------------------------
local CHARS="ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local function gen_key() local t={"PK"}; for i=1,4 do local b={}; for j=1,4 do local n=math.random(1,#CHARS); table.insert(b,CHARS:sub(n,n)) end; table.insert(t,table.concat(b)) end; return table.concat(t,"-") end

local function generate_keys(sec,lbl,qty,who)
    local out={}; for i=1,qty do local k; repeat k=gen_key() until not KeyDB[k]; KeyDB[k]={duration=sec,created=os.time(),used_by=nil,redeemed_at=nil,generated_by=who,bound_hwid=nil}; table.insert(out,k) end
    save_json(P_KEYS,KeyDB)
    hook_embed(WH_KEYS,"🔑 KEYS GERADAS",14362437,{{name="quantidade",value=tostring(qty),inline=true},{name="duracao",value=lbl,inline=true},{name="gerado por",value=who,inline=true},{name="keys",value="```"..table.concat(out,"\n").."```",inline=false}})
    log("key_gen",{qty=qty,dur=lbl,who=who},14362437)
    return out
end

local function redeem_key(user,key)
    local rec=KeyDB[key]; if not rec then return false,"key inexistente" end
    if rec.used_by and rec.used_by~=user then return false,"key ja usada por outro" end
    rec.used_by=user; rec.redeemed_at=rec.redeemed_at or os.time(); rec.bound_hwid=rec.bound_hwid or HWID
    local exp=rec.duration==-1 and -1 or (rec.redeemed_at+rec.duration)
    UserDB[user].key=key; UserDB[user].exp=exp; UserDB[user].hwid=HWID
    save_json(P_KEYS,KeyDB); save_json(P_USERS,UserDB)
    hook_embed(WH_LOGS,"✅ KEY RESGATADA",3066993,{{name="usuario",value=user,inline=true},{name="key",value="`"..key.."`",inline=true},{name="hwid",value="`"..HWID:sub(1,16).."...`",inline=false}})
    log("key_redeem",{user=user,key=key},3066993)
    return true,exp
end

local function key_active(user)
    local u=UserDB[user]; if not u or not u.key then return false,"NO_KEY" end
    if u.hwid and u.hwid~=HWID then return false,"HWID_MISMATCH" end
    if u.exp==-1 then return true end
    if os.time()>=(u.exp or 0) then return false,"EXPIRED" end
    return true
end

local function delete_expired_user(user)
    if UserDB[user] and not UserDB[user].admin then
        local key = UserDB[user].key
        UserDB[user] = nil
        if key and KeyDB[key] then KeyDB[key] = nil end
        save_json(P_USERS,UserDB); save_json(P_KEYS,KeyDB)
        hook_embed(WH_LOGS,"🗑️ CONTA DELETADA (key expirada)",15844367,{{name="usuario",value=user,inline=true},{name="motivo",value="key expirou — nick liberado",inline=true}})
        log("account_expired_delete",{user=user},15844367)
    end
end

local function admin_reset_hwid(target)
    local u=UserDB[target]; if not u then return false,"usuario nao existe" end
    u.hwid=nil; save_json(P_USERS,UserDB)
    if u.key and KeyDB[u.key] then KeyDB[u.key].bound_hwid=nil; save_json(P_KEYS,KeyDB) end
    hook_embed(WH_LOGS,"🔓 HWID RESETADO",15844367,{{name="usuario",value=target,inline=true}})
    return true
end

------------------------------------------------------------
-- UI HELPERS
------------------------------------------------------------
local function make(cls,p,par) local o=Instance.new(cls); for k,v in pairs(p or {}) do o[k]=v end; if par then o.Parent=par end; return o end
local function corner(o,r) make("UICorner",{CornerRadius=UDim.new(0,r or 6)},o) end
local function stroke(o,c,t) local s=make("UIStroke",{Color=c or THEME.stroke,Thickness=t or 1},o); s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end
local function pad(o,p) make("UIPadding",{PaddingTop=UDim.new(0,p),PaddingBottom=UDim.new(0,p),PaddingLeft=UDim.new(0,p),PaddingRight=UDim.new(0,p)},o) end

-- gradient 3-stop profissional
local function gradient_pro(obj, c1, c2, c3, rot)
    local keys = { ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(0.5, c2 or c1:Lerp(c3 or c1, 0.5)), ColorSequenceKeypoint.new(1, c3 or c2 or c1) }
    return make("UIGradient",{ Color=ColorSequence.new(keys), Rotation=rot or 90 },obj)
end

local function label(par,txt,size,bold,col)
    return make("TextLabel",{BackgroundTransparency=1,Text=txt,TextColor3=col or THEME.text,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,TextSize=size or 13,TextXAlignment=Enum.TextXAlignment.Left,Parent=par})
end
local function imgIcon(par,id,size) return make("ImageLabel",{BackgroundTransparency=1,Image=id,Size=UDim2.new(0,size or 18,0,size or 18),ImageColor3=THEME.text,Parent=par}) end

local function animate_btn(b)
    local orig=b.BackgroundColor3
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=orig:Lerp(Color3.new(1,1,1),0.12)}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=orig}):Play() end)
end

-- LOGO oficial como ImageLabel
local function build_logo(parent, size)
    local box = make("ImageLabel",{
        BackgroundTransparency=1, Image=LOGO_ID, Size=UDim2.new(0,size,0,size),
        ScaleType=Enum.ScaleType.Fit, Parent=parent
    })
    return box
end

------------------------------------------------------------
-- SCREEN GUI
------------------------------------------------------------
local function root_parent() if gethui then local ok,g=pcall(gethui); if ok then return g end end; local ok,cg=pcall(function() return game:GetService("CoreGui") end); if ok and cg then return cg end; return LP:WaitForChild("PlayerGui") end
local SG_NAME="\0"..string.char(math.random(32,126))..tostring(math.random(1e8,9e8))
local ScreenGui=make("ScreenGui",{Name=SG_NAME,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,DisplayOrder=9999})
pcall(function() if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end end)
pcall(function() if protect_gui then protect_gui(ScreenGui) end end)
ScreenGui.Parent=root_parent()

local StreamOn=false
local function apply_stream() ScreenGui.Enabled=not StreamOn end

------------------------------------------------------------
-- CONEXÕES RASTREADAS (pra wipe desligar tudo)
------------------------------------------------------------
local Connections = {}
local function track(conn) table.insert(Connections, conn); return conn end

------------------------------------------------------------
-- NOTIFICAÇÕES
------------------------------------------------------------
local NotifHolder=make("Frame",{Size=UDim2.new(0,340,1,-40),Position=UDim2.new(1,-356,0,20),BackgroundTransparency=1,Parent=ScreenGui})
make("UIListLayout",{Padding=UDim.new(0,8),HorizontalAlignment=Enum.HorizontalAlignment.Right,SortOrder=Enum.SortOrder.LayoutOrder},NotifHolder)
local nCount=0
local function notify(title,msg,kind,dur)
    nCount+=1
    local col = kind=="success" and THEME.good or kind=="warn" and THEME.warn or kind=="error" and THEME.danger or THEME.accent
    local n=make("Frame",{LayoutOrder=-nCount,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=THEME.bg2,BorderSizePixel=0,Parent=NotifHolder,Position=UDim2.new(1,40,0,0)})
    corner(n,8); stroke(n,THEME.stroke)
    make("Frame",{Size=UDim2.new(0,4,1,0),BackgroundColor3=col,BorderSizePixel=0,Parent=n})
    local body=make("Frame",{Size=UDim2.new(1,-20,0,0),Position=UDim2.new(0,14,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=n})
    pad(body,10); make("UIListLayout",{Padding=UDim.new(0,4)},body)
    local t=label(body,title,13,true,col); t.Size=UDim2.new(1,0,0,16)
    local m=label(body,msg,12,false,THEME.text); m.Size=UDim2.new(1,0,0,0); m.AutomaticSize=Enum.AutomaticSize.Y; m.TextWrapped=true
    local barBg=make("Frame",{Size=UDim2.new(1,-20,0,2),Position=UDim2.new(0,14,1,-6),BackgroundColor3=THEME.card2,BorderSizePixel=0,Parent=n}); corner(barBg,1)
    local bar=make("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=col,BorderSizePixel=0,Parent=barBg}); corner(bar,1)
    TweenService:Create(n,TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)}):Play()
    TweenService:Create(bar,TweenInfo.new(dur or 4,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(dur or 4,function() local tw=TweenService:Create(n,TweenInfo.new(0.3),{Position=UDim2.new(1,40,0,0),BackgroundTransparency=1}); tw:Play(); tw.Completed:Connect(function() n:Destroy() end) end)
end

------------------------------------------------------------
-- SPLASH 5s
------------------------------------------------------------
local Splash=make("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=THEME.bg,BorderSizePixel=0,Parent=ScreenGui,ZIndex=1000})
gradient_pro(Splash, THEME.bg, THEME.bg2, THEME.bg, 90)
local sLogo=build_logo(Splash, 220); sLogo.Position=UDim2.new(0.5,-110,0.5,-160)
local sTxt=label(Splash,"carregando sistema...",14,false,THEME.text2); sTxt.Size=UDim2.new(0,300,0,20); sTxt.Position=UDim2.new(0.5,-150,0.5,100); sTxt.TextXAlignment=Enum.TextXAlignment.Center
local sBg=make("Frame",{Size=UDim2.new(0,300,0,4),Position=UDim2.new(0.5,-150,0.5,130),BackgroundColor3=THEME.card,BorderSizePixel=0,Parent=Splash}); corner(sBg,2)
local sBar=make("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=THEME.accent,BorderSizePixel=0,Parent=sBg}); corner(sBar,2); gradient_pro(sBar, THEME.accent, THEME.accent2, THEME.accent3, 0)
local sPct=label(Splash,"0%",11,false,THEME.text2); sPct.Size=UDim2.new(0,300,0,16); sPct.Position=UDim2.new(0.5,-150,0.5,140); sPct.TextXAlignment=Enum.TextXAlignment.Center

local function run_splash(cb)
    local phases={"verificando executor...","carregando módulos...","conectando ao backend...","aplicando anti-trace...","pronto!"}
    task.spawn(function()
        for i=1,5 do
            sTxt.Text=phases[i]
            TweenService:Create(sBar,TweenInfo.new(1,Enum.EasingStyle.Quint),{Size=UDim2.new(i/5,0,1,0)}):Play()
            for p=i*20-20,i*20 do sPct.Text=p.."%"; task.wait(0.05) end
        end
        task.wait(0.3)
        local tw=TweenService:Create(Splash,TweenInfo.new(0.5),{BackgroundTransparency=1}); tw:Play(); tw.Completed:Connect(function() Splash:Destroy(); cb() end)
    end)
end

------------------------------------------------------------
-- STATE (features) + CONNECTIONS
------------------------------------------------------------
local S = {
    esp = {on=false,box=true,name=true,hp=true,tracer=false,team=false,chams=false,max_dist=2000},
    fly = {on=false,speed=60},
    speed = {on=false,value=50},
    jump = {on=false,value=80},
    noclip = {on=false}, inf_jump={on=false}, anti_afk={on=false}, fullbright={on=false}, zoom={on=false,value=120},
    anti_slip = {on=false},
    hitbox = {on=false, size=10},
    freecam = {on=false, speed=1},
    crosshair = {on=false},
    click_tp = {on=false},
    tp = {target=""},
    aim = {on=false,silent=false,fov=120,smooth=0.3,team_check=false,visible_only=false,show_fov=true},
    troll = {god=false,invisible=false,spin=false,big=false,follow_target=""},
}

------------------------------------------------------------
-- SILENT AIM
------------------------------------------------------------
local function get_nearest_head(use_fov)
    local best,bd=nil,(use_fov and S.aim.fov or math.huge)
    local mx,my=Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr==LP then continue end
        if S.aim.team_check and plr.Team==LP.Team then continue end
        local ch=plr.Character; local head=ch and ch:FindFirstChild("Head"); local h=ch and ch:FindFirstChildOfClass("Humanoid")
        if not head or not h or h.Health<=0 then continue end
        local vp,on=Camera:WorldToViewportPoint(head.Position); if not on then continue end
        local d=math.sqrt((vp.X-mx)^2+(vp.Y-my)^2)
        if d<bd then
            if S.aim.visible_only then local ray=Workspace:Raycast(Camera.CFrame.Position,head.Position-Camera.CFrame.Position); if ray and not ray.Instance:IsDescendantOf(ch) then continue end end
            best,bd=head,d
        end
    end
    return best
end

if hookmetamethod then
    local old; old=hookmetamethod(game,"__namecall",function(self,...)
        local method=getnamecallmethod(); local args={...}
        if S.aim.silent and not checkcaller() then
            local head=get_nearest_head(true)
            if head then
                if method=="FindPartOnRayWithIgnoreList" or method=="FindPartOnRay" then
                    local o=Camera.CFrame.Position; args[1]=Ray.new(o,(head.Position-o).Unit*1000); return old(self,table.unpack(args))
                elseif method=="Raycast" and typeof(args[1])=="Vector3" and typeof(args[2])=="Vector3" then
                    local o=args[1]; local mag=args[2].Magnitude>0 and args[2].Magnitude or 1000; args[2]=(head.Position-o).Unit*mag; return old(self,table.unpack(args))
                elseif method=="ScreenPointToRay" or method=="ViewportPointToRay" then
                    local r=old(self,table.unpack(args)); if typeof(r)=="Ray" then return Ray.new(r.Origin,(head.Position-r.Origin).Unit*1000) end
                end
            end
        end
        return old(self,...)
    end)
end

------------------------------------------------------------
-- AIMBOT
------------------------------------------------------------
local hasMR=type(mousemoverel)=="function"
track(RunService.RenderStepped:Connect(function()
    if not S.aim.on then return end
    if not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local head=get_nearest_head(true); if not head then return end
    if hasMR then
        local vp=Camera:WorldToViewportPoint(head.Position); local mx,my=Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2
        pcall(mousemoverel,(vp.X-mx)*S.aim.smooth,(vp.Y-my)*S.aim.smooth)
    else
        local cur=Camera.CFrame; local want=CFrame.lookAt(cur.Position,head.Position); local n=cur:Lerp(want,math.clamp(S.aim.smooth,0.05,0.4))
        if cur.LookVector:Dot(n.LookVector)>0.3 then Camera.CFrame=n end
    end
end))

-- FOV CIRCLE
local fovCircle
if type(Drawing)=="table" and Drawing.new then
    fovCircle=Drawing.new("Circle"); fovCircle.Thickness=1.3; fovCircle.NumSides=60; fovCircle.Color=THEME.accent; fovCircle.Filled=false; fovCircle.Transparency=1; fovCircle.Visible=false
end
track(RunService.RenderStepped:Connect(function()
    if not fovCircle then return end
    if (S.aim.on or S.aim.silent) and S.aim.show_fov then
        fovCircle.Radius=S.aim.fov; fovCircle.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2); fovCircle.Visible=true
    else fovCircle.Visible=false end
end))

------------------------------------------------------------
-- CROSSHAIR CUSTOM
------------------------------------------------------------
local chLines = {}
if type(Drawing)=="table" and Drawing.new then
    for i=1,4 do local l=Drawing.new("Line"); l.Thickness=1.5; l.Color=THEME.accent; l.Visible=false; table.insert(chLines,l) end
end
track(RunService.RenderStepped:Connect(function()
    if #chLines==0 then return end
    local cx,cy=Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2; local gap,len=5,8
    for _,l in ipairs(chLines) do l.Visible=S.crosshair.on end
    if S.crosshair.on then
        chLines[1].From=Vector2.new(cx,cy-gap-len); chLines[1].To=Vector2.new(cx,cy-gap)
        chLines[2].From=Vector2.new(cx,cy+gap);     chLines[2].To=Vector2.new(cx,cy+gap+len)
        chLines[3].From=Vector2.new(cx-gap-len,cy); chLines[3].To=Vector2.new(cx-gap,cy)
        chLines[4].From=Vector2.new(cx+gap,cy);     chLines[4].To=Vector2.new(cx+gap+len,cy)
    end
end))

------------------------------------------------------------
-- ESP + CHAMS
------------------------------------------------------------
local USE_DRAW=(type(Drawing)=="table" and Drawing.new)
local ESPData={}
local function new_esp(plr) if ESPData[plr] then return end
    local e={}
    if USE_DRAW then
        e.box=Drawing.new("Square"); e.box.Thickness=1.5; e.box.Filled=false; e.box.Color=THEME.accent; e.box.Visible=false
        e.name=Drawing.new("Text"); e.name.Size=14; e.name.Center=true; e.name.Outline=true; e.name.Color=THEME.text; e.name.Font=2; e.name.Visible=false
        e.hp_bg=Drawing.new("Square"); e.hp_bg.Thickness=1; e.hp_bg.Filled=true; e.hp_bg.Color=Color3.fromRGB(0,0,0); e.hp_bg.Visible=false
        e.hp_fg=Drawing.new("Square"); e.hp_fg.Thickness=1; e.hp_fg.Filled=true; e.hp_fg.Color=THEME.good; e.hp_fg.Visible=false
        e.tracer=Drawing.new("Line"); e.tracer.Thickness=1.2; e.tracer.Color=THEME.accent; e.tracer.Visible=false
    end
    -- chams: Highlight nativo (atravessa parede)
    e.chams = make("Highlight",{ FillColor=THEME.accent, FillTransparency=0.7, OutlineColor=THEME.text, OutlineTransparency=0, Enabled=false, DepthMode=Enum.HighlightDepthMode.AlwaysOnTop, Parent=ScreenGui })
    ESPData[plr]=e
end
local function kill_esp(plr) local e=ESPData[plr]; if not e then return end
    if e.box then for _,d in pairs({e.box,e.name,e.hp_bg,e.hp_fg,e.tracer}) do pcall(function() d:Remove() end) end end
    if e.chams then e.chams:Destroy() end
    ESPData[plr]=nil
end
track(RunService.RenderStepped:Connect(function()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr==LP then continue end
        new_esp(plr); local e=ESPData[plr]
        local ch=plr.Character; local root=ch and ch:FindFirstChild("HumanoidRootPart"); local head=ch and ch:FindFirstChild("Head"); local h=ch and ch:FindFirstChildOfClass("Humanoid")
        local alive = S.esp.on and root and head and h and h.Health>0
        local me_root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local dist = (alive and me_root) and (me_root.Position-root.Position).Magnitude or 999999
        if alive and dist>S.esp.max_dist then alive=false end
        -- chams
        if e.chams then e.chams.Adornee = (alive and S.esp.chams) and ch or nil; e.chams.Enabled = alive and S.esp.chams or false; if alive and S.esp.chams then e.chams.FillColor = S.esp.team and plr.TeamColor and plr.TeamColor.Color or THEME.accent end end
        -- drawings
        if not e.box then continue end
        if not alive then for _,d in pairs({e.box,e.name,e.hp_bg,e.hp_fg,e.tracer}) do d.Visible=false end
        else
            local vp_r,vis=Camera:WorldToViewportPoint(root.Position); local vp_h=Camera:WorldToViewportPoint(head.Position+Vector3.new(0,0.6,0))
            if not vis then for _,d in pairs({e.box,e.name,e.hp_bg,e.hp_fg,e.tracer}) do d.Visible=false end
            else
                local height=(vp_r.Y-vp_h.Y)*2; local width=height*0.45; local x,y=vp_r.X-width/2,vp_h.Y
                local col = S.esp.team and plr.TeamColor and plr.TeamColor.Color or THEME.accent
                e.box.Size=Vector2.new(width,height); e.box.Position=Vector2.new(x,y); e.box.Color=col; e.box.Visible=S.esp.box
                e.name.Text=plr.Name.." ["..math.floor(dist).."m]"; e.name.Position=Vector2.new(vp_r.X,y-16); e.name.Visible=S.esp.name
                if S.esp.hp then local frac=math.clamp(h.Health/h.MaxHealth,0,1); local bx=x-6
                    e.hp_bg.Size=Vector2.new(3,height); e.hp_bg.Position=Vector2.new(bx,y); e.hp_bg.Visible=true
                    e.hp_fg.Size=Vector2.new(3,height*frac); e.hp_fg.Position=Vector2.new(bx,y+height*(1-frac)); e.hp_fg.Color=Color3.fromRGB(math.floor(255*(1-frac)),math.floor(255*frac),40); e.hp_fg.Visible=true
                else e.hp_bg.Visible=false; e.hp_fg.Visible=false end
                if S.esp.tracer then e.tracer.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y); e.tracer.To=Vector2.new(vp_r.X,vp_r.Y+height/2); e.tracer.Color=col; e.tracer.Visible=true
                else e.tracer.Visible=false end
            end
        end
    end
end))
track(Players.PlayerRemoving:Connect(kill_esp))

------------------------------------------------------------
-- FLY / SPEED / JUMP / NOCLIP / FULLBRIGHT / ZOOM / ANTI SLIP / HITBOX
------------------------------------------------------------
local function hrp() local c=LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c=LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local bg,bv
local function stop_fly() if bg then bg:Destroy(); bg=nil end; if bv then bv:Destroy(); bv=nil end end
local function start_fly() stop_fly(); local r=hrp(); if not r then return end
    bg=Instance.new("BodyGyro",r); bg.Name="_"; bg.P=9e4; bg.MaxTorque=Vector3.new(9e9,9e9,9e9); bg.CFrame=r.CFrame
    bv=Instance.new("BodyVelocity",r); bv.Name="_"; bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero end

track(RunService.Heartbeat:Connect(function()
    if S.fly.on and bg and bv then
        bg.CFrame=Camera.CFrame; local mv=Vector3.zero
        if UserInput:IsKeyDown(Enum.KeyCode.W) then mv+=Camera.CFrame.LookVector end
        if UserInput:IsKeyDown(Enum.KeyCode.S) then mv-=Camera.CFrame.LookVector end
        if UserInput:IsKeyDown(Enum.KeyCode.D) then mv+=Camera.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.A) then mv-=Camera.CFrame.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.Space) then mv+=Vector3.new(0,1,0) end
        if UserInput:IsKeyDown(Enum.KeyCode.Q) then mv-=Vector3.new(0,1,0) end
        if mv.Magnitude>0 then mv=mv.Unit*S.fly.speed end
        bv.Velocity=mv
    end
    if S.speed.on then local h=hum(); if h and h.WalkSpeed~=S.speed.value then h.WalkSpeed=S.speed.value end end
    if S.jump.on then local h=hum(); if h and h.JumpPower~=S.jump.value then h.JumpPower=S.jump.value end end
    if S.hitbox.on then for _,p in ipairs(Players:GetPlayers()) do if p~=LP then local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if r then r.Size=Vector3.new(S.hitbox.size,S.hitbox.size,S.hitbox.size); r.Transparency=0.7; r.CanCollide=false end end end end
end))

track(RunService.Stepped:Connect(function()
    if S.noclip.on then local c=LP.Character; if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end
    if S.anti_slip.on then local c=LP.Character; if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CustomPhysicalProperties = PhysicalProperties.new(0.7,10,0.5,100,100) end end end end
end))

track(UserInput.JumpRequest:Connect(function() if S.inf_jump.on then local h=hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end))

local origLighting={Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient,FogEnd=Lighting.FogEnd,Brightness=Lighting.Brightness}
local function apply_fullbright(v) if v then Lighting.Ambient=Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255); Lighting.FogEnd=1e6; Lighting.Brightness=3
    else Lighting.Ambient=origLighting.Ambient; Lighting.OutdoorAmbient=origLighting.OutdoorAmbient; Lighting.FogEnd=origLighting.FogEnd; Lighting.Brightness=origLighting.Brightness end end

track(RunService.RenderStepped:Connect(function() if S.zoom.on then Camera.FieldOfView=S.zoom.value end end))
track(LP.Idled:Connect(function() if S.anti_afk.on then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end end))

------------------------------------------------------------
-- FREECAM (independente do personagem)
------------------------------------------------------------
local freecam_cf = nil
local freecam_was_type = nil
local function toggle_freecam(v)
    S.freecam.on = v
    if v then
        freecam_was_type = Camera.CameraType
        Camera.CameraType = Enum.CameraType.Scriptable
        freecam_cf = Camera.CFrame
    else
        if freecam_was_type then Camera.CameraType = freecam_was_type end
        freecam_cf = nil
    end
end
track(RunService.RenderStepped:Connect(function(dt)
    if not S.freecam.on or not freecam_cf then return end
    local mv = Vector3.zero
    if UserInput:IsKeyDown(Enum.KeyCode.W) then mv+=freecam_cf.LookVector end
    if UserInput:IsKeyDown(Enum.KeyCode.S) then mv-=freecam_cf.LookVector end
    if UserInput:IsKeyDown(Enum.KeyCode.D) then mv+=freecam_cf.RightVector end
    if UserInput:IsKeyDown(Enum.KeyCode.A) then mv-=freecam_cf.RightVector end
    if UserInput:IsKeyDown(Enum.KeyCode.E) then mv+=Vector3.new(0,1,0) end
    if UserInput:IsKeyDown(Enum.KeyCode.Q) then mv-=Vector3.new(0,1,0) end
    freecam_cf = freecam_cf + mv*S.freecam.speed*50*dt
    Camera.CFrame = freecam_cf
end))

------------------------------------------------------------
-- CLICK TP
------------------------------------------------------------
track(UserInput.InputBegan:Connect(function(input,gpe)
    if not S.click_tp.on or gpe then return end
    if input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    local m = LP:GetMouse(); local hit = m.Hit
    if hit then local r=hrp(); if r then r.CFrame=CFrame.new(hit.Position+Vector3.new(0,3,0)) end end
end))

------------------------------------------------------------
-- TP / TOOLS / TROLLS (compactos)
------------------------------------------------------------
local function tp_to(cf) local r=hrp(); if r then r.CFrame=cf end end
local function tp_player(name) for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Name:lower():find(name:lower(),1,true) then local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if r then tp_to(r.CFrame+Vector3.new(2,0,0)); notify("TP","você teleportou pra "..p.Name,"success",2) end; return end end; notify("TP","player não encontrado","error") end

local function scan_tools() local out={}; local roots={RepStorage,Workspace}; for _,t in ipairs(Teams:GetChildren()) do table.insert(roots,t) end; for _,p in ipairs(Players:GetPlayers()) do if p.Backpack then table.insert(roots,p.Backpack) end end; for _,root in ipairs(roots) do for _,d in ipairs(root:GetDescendants()) do if d:IsA("Tool") then table.insert(out,d) end end end; return out end
local function grab(t) local bp=LP:FindFirstChildOfClass("Backpack"); if bp and t.Parent~=bp then pcall(function() t.Parent=bp end) end end

local orig_trans={}
local function set_invisible(v) local c=LP.Character; if not c then return end; for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then if v then orig_trans[p]=orig_trans[p] or p.Transparency; p.Transparency=1 else if orig_trans[p] then p.Transparency=orig_trans[p]; orig_trans[p]=nil end end end end end
local godConn; local function god_mode(v) if godConn then godConn:Disconnect(); godConn=nil end; if v then godConn=RunService.Heartbeat:Connect(function() local h=hum(); if h then h.Health=h.MaxHealth end end) end end
local spinBV; local function do_spin(v) if spinBV then spinBV:Destroy(); spinBV=nil end; if not v then return end; local r=hrp(); if not r then return end; spinBV=Instance.new("BodyAngularVelocity",r); spinBV.Name="_"; spinBV.MaxTorque=Vector3.new(0,math.huge,0); spinBV.AngularVelocity=Vector3.new(0,20,0) end
local function big_head(v) local c=LP.Character; if not c then return end; local head=c:FindFirstChild("Head"); local mesh=head and head:FindFirstChildOfClass("SpecialMesh"); if mesh then mesh.Scale=v and Vector3.new(5,5,5) or Vector3.new(1.25,1.25,1.25) end end
local function fling_self() local r=hrp(); if not r then return end; local b=Instance.new("BodyVelocity",r); b.Name="_"; b.MaxForce=Vector3.new(9e9,9e9,9e9); b.Velocity=Vector3.new(math.random(-500,500),500,math.random(-500,500)); task.delay(0.3,function() b:Destroy() end) end
track(RunService.Heartbeat:Connect(function() if S.troll.follow_target=="" then return end; local tgt; for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Name:lower():find(S.troll.follow_target:lower(),1,true) then tgt=p; break end end; if not tgt then return end; local tr=tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart"); local r=hrp(); if tr and r then r.CFrame=tr.CFrame*CFrame.new(0,0,3) end end))

------------------------------------------------------------
-- REMOTE SPY (exploit real de stats server-side)
------------------------------------------------------------
local function scan_remotes()
    local out={}
    for _,d in ipairs(RepStorage:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            table.insert(out,{ ref=d, name=d.Name, type=d.ClassName, path=d:GetFullName() })
        end
    end
    for _,d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            table.insert(out,{ ref=d, name=d.Name, type=d.ClassName, path=d:GetFullName() })
        end
    end
    return out
end
local function fire_remote(rem, args_str)
    -- parse args_str: "100" ou "100,abc" ou "true"
    local args = {}
    for part in args_str:gmatch("[^,]+") do
        part = part:match("^%s*(.-)%s*$")
        if tonumber(part) then table.insert(args, tonumber(part))
        elseif part=="true" then table.insert(args, true)
        elseif part=="false" then table.insert(args, false)
        else table.insert(args, part) end
    end
    local ok, err = pcall(function()
        if rem:IsA("RemoteEvent") then rem:FireServer(table.unpack(args))
        else return rem:InvokeServer(table.unpack(args)) end
    end)
    return ok, err
end

------------------------------------------------------------
-- LEADERSTATS SCAN
------------------------------------------------------------
local function scan_leaderstats()
    local out={}
    local function scan_folder(f,prefix) if not f then return end; for _,v in ipairs(f:GetChildren()) do if v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue") then table.insert(out,{name=prefix..v.Name,ref=v,type=v.ClassName}) end end end
    scan_folder(LP:FindFirstChild("leaderstats"),"leaderstats/")
    scan_folder(LP:FindFirstChild("PlayerStats"),"PlayerStats/")
    scan_folder(LP:FindFirstChild("Stats"),"Stats/")
    scan_folder(LP:FindFirstChild("Data"),"Data/")
    return out
end

------------------------------------------------------------
-- SERVER HOP / REJOIN
------------------------------------------------------------
local function rejoin_server() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end
local function server_hop()
    task.spawn(function()
        local ok, data = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if not ok or not data or not data.data then notify("Server Hop","não achou servidores","error"); return end
        for _,srv in ipairs(data.data) do
            if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LP) end)
                return
            end
        end
        notify("Server Hop","nenhum servidor livre","warn")
    end)
end

------------------------------------------------------------
-- LEAK safe + STATUS
------------------------------------------------------------
local function try_saveinstance() local fn=saveinstance or (syn and syn.saveinstance); if not fn then return false,"executor sem saveinstance" end
    task.spawn(function() pcall(function() pcall(fn,{mode="optimized",noscripts=false}) end) end); return true,"disparado em background — roblox não vai travar" end

local function send_status(current_user, is_admin)
    local active={}; for k,cat in pairs(S) do if type(cat)=="table" and cat.on then table.insert(active,k) end; if type(cat)=="table" and cat.silent then table.insert(active,"silent_aim") end end
    local risk = (S.aim.silent or S.aim.on) and "RISCO ALTO" or (S.fly.on or S.speed.on or S.noclip.on) and "RISCO MÉDIO" or "SAFE"
    local col = risk=="SAFE" and 3066993 or risk=="RISCO MÉDIO" and 15844367 or 14362437
    hook_embed(WH_STATUS,"📊 STATUS DO CHEAT",col,
        {{name="👤 Usuário",value="`"..current_user.."`"..(is_admin and " **[ADMIN]**" or ""),inline=true},
         {name="🎮 Place",value="`"..game.PlaceId.."`",inline=true},
         {name="🛡️ Status",value="**"..risk.."**",inline=true},
         {name="⚙️ Features ativas",value=#active>0 and ("```"..table.concat(active,", ").."```") or "`nenhuma`",inline=false},
         {name="🖥️ Executor",value="`"..EXE.."`",inline=true},
         {name="📱 Plataforma",value="`"..(IS_MOBILE and "mobile" or "pc").."`",inline=true},
         {name="🆔 HWID",value="`"..HWID:sub(1,16).."...`",inline=true}},
        "monitoramento automático")
end

------------------------------------------------------------
-- WIPE (desliga TUDO + conexões)
------------------------------------------------------------
local function wipe_traces()
    for k,cat in pairs(S) do if type(cat)=="table" then if cat.on~=nil then cat.on=false end; if cat.silent~=nil then cat.silent=false end end end
    S.troll.follow_target=""
    stop_fly(); god_mode(false); do_spin(false); set_invisible(false); apply_fullbright(false); toggle_freecam(false)
    Camera.FieldOfView=70
    -- desliga conexões
    for _,c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    Connections = {}
    -- mata ESP
    for p,_ in pairs(ESPData) do kill_esp(p) end
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    for _,l in ipairs(chLines) do pcall(function() l:Remove() end) end
    -- limpa bodymovers
    local c=LP.Character; if c then for _,d in ipairs(c:GetDescendants()) do if (d:IsA("BodyGyro") or d:IsA("BodyVelocity") or d:IsA("BodyAngularVelocity")) and d.Name=="_" then d:Destroy() end end end
    if FS_OK then for _,p in ipairs({P_KEYS,P_USERS,P_SESS,P_LOGS,P_CFG}) do pcall(function() delfile(p) end) end end
    pcall(function() CAS:UnbindAction("pkMenu"); CAS:UnbindAction("pkFly"); CAS:UnbindAction("pkSpd"); CAS:UnbindAction("pkTp"); CAS:UnbindAction("pkStr"); CAS:UnbindAction("pkSil"); CAS:UnbindAction("pkBlock") end)
    ScreenGui:Destroy()
end

------------------------------------------------------------
-- MENU
------------------------------------------------------------
local MainRoot, InputBlocker, menuVisible
local function build_menu(current_user, is_admin)

InputBlocker = make("Frame",{ Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Active=true, Visible=false, ZIndex=1, Parent=ScreenGui })
local blockKeys = { Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Space,Enum.KeyCode.LeftShift,Enum.KeyCode.LeftControl,Enum.KeyCode.E,Enum.KeyCode.Q,Enum.KeyCode.R,Enum.KeyCode.F,Enum.KeyCode.T,Enum.KeyCode.G,Enum.KeyCode.H,Enum.KeyCode.Z,Enum.KeyCode.X,Enum.KeyCode.C,Enum.KeyCode.V,Enum.KeyCode.B,Enum.KeyCode.N,Enum.KeyCode.M }
local function set_input_block(on) InputBlocker.Visible=on; if on then pcall(function() CAS:BindActionAtPriority("pkBlock",function() return Enum.ContextActionResult.Sink end,false,3000,table.unpack(blockKeys)) end) else pcall(function() CAS:UnbindAction("pkBlock") end) end end

MainRoot = make("Frame",{ Name="Main", Active=true, Draggable=true,
    Size=UDim2.new(0, IS_MOBILE and 740 or 960, 0, IS_MOBILE and 480 or 600),
    Position=UDim2.new(0.5,-(IS_MOBILE and 370 or 480),0.5,-(IS_MOBILE and 240 or 300)),
    BackgroundColor3=THEME.bg, BorderSizePixel=0, BackgroundTransparency=CfgDB.transparency, Parent=ScreenGui })
corner(MainRoot,12); stroke(MainRoot,THEME.accent,1.5); gradient_pro(MainRoot, THEME.bg, THEME.bg2, THEME.bg, 90)

local Side = make("Frame",{ Size=UDim2.new(0,220,1,0), BackgroundColor3=THEME.bg2, BorderSizePixel=0, BackgroundTransparency=CfgDB.transparency*0.5, Parent=MainRoot })
corner(Side,12); gradient_pro(Side, THEME.bg2, THEME.bg, THEME.bg2, 180)
make("Frame",{ Size=UDim2.new(0,2,1,0), Position=UDim2.new(1,-2,0,0), BackgroundColor3=THEME.accent, BorderSizePixel=0, Parent=Side })

-- logo oficial no sidebar
local sideLogo = build_logo(Side, 130); sideLogo.Position = UDim2.new(0.5,-65,0,8)

local TabArea = make("ScrollingFrame",{ Size=UDim2.new(1,-20,1,-170), Position=UDim2.new(0,10,0,150), BackgroundTransparency=1, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=Side })
make("UIListLayout",{ Padding=UDim.new(0,4) }, TabArea)

local Content = make("Frame",{ Size=UDim2.new(1,-230,1,-20), Position=UDim2.new(0,225,0,10), BackgroundTransparency=1, Parent=MainRoot })

local TopBar = make("Frame",{ Size=UDim2.new(1,0,0,46), BackgroundTransparency=1, Parent=Content })
local TitleLbl = label(TopBar,"Início",18,true); TitleLbl.Size=UDim2.new(1,-220,1,0); TitleLbl.TextColor3=THEME.text
local UserLbl = label(TopBar,current_user..(is_admin and "  [ADMIN]" or ""),12,true,THEME.accent); UserLbl.Size=UDim2.new(0,180,0,16); UserLbl.Position=UDim2.new(1,-260,0,8); UserLbl.TextXAlignment=Enum.TextXAlignment.Right
local ExpLbl = label(TopBar,"",11,false,THEME.text2); ExpLbl.Size=UDim2.new(0,180,0,14); ExpLbl.Position=UDim2.new(1,-260,0,26); ExpLbl.TextXAlignment=Enum.TextXAlignment.Right
local u=UserDB[current_user]
if u.exp==-1 then ExpLbl.Text="lifetime"; ExpLbl.TextColor3=THEME.good
else local left=math.max(0,(u.exp or 0)-os.time()); ExpLbl.Text=string.format("expira em %dd %dh",math.floor(left/86400),math.floor((left%86400)/3600)) end

-- minimizar com logo
local MinBtn = make("ImageButton",{ Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-74,0,8), BackgroundColor3=THEME.card, Image=ICON.min, ImageColor3=THEME.warn, BorderSizePixel=0, Parent=TopBar })
corner(MinBtn,15); stroke(MinBtn,THEME.warn); animate_btn(MinBtn)
local CloseBtn = make("ImageButton",{ Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-38,0,8), BackgroundColor3=THEME.card, Image=ICON.close, ImageColor3=THEME.accent, BorderSizePixel=0, Parent=TopBar })
corner(CloseBtn,15); stroke(CloseBtn,THEME.accent); animate_btn(CloseBtn)

local minBubble
MinBtn.MouseButton1Click:Connect(function()
    MainRoot.Visible=false; menuVisible=false; set_input_block(false)
    minBubble = make("ImageButton",{ Size=UDim2.new(0,64,0,64), Position=UDim2.new(0,20,0.5,-32), BackgroundTransparency=1, Image=LOGO_ID, Parent=ScreenGui })
    minBubble.MouseButton1Click:Connect(function() minBubble:Destroy(); MainRoot.Visible=true; menuVisible=true; set_input_block(true) end)
end)
CloseBtn.MouseButton1Click:Connect(function() MainRoot.Visible=false; menuVisible=false; set_input_block(false) end)

local Pages = make("Frame",{ Size=UDim2.new(1,0,1,-56), Position=UDim2.new(0,0,0,54), BackgroundTransparency=1, Parent=Content })

local tabs={}
local function section_header(txt) local l=label(TabArea,"  "..txt,10,true,THEME.text2); l.Size=UDim2.new(1,0,0,18); l.TextTransparency=0.2 end
local function make_tab(name,iconid)
    local b=make("TextButton",{ BackgroundColor3=THEME.bg, BorderSizePixel=0, Text="", AutoButtonColor=false, Size=UDim2.new(1,0,0,34), Parent=TabArea }); corner(b,6)
    local ic=imgIcon(b,iconid,16); ic.Position=UDim2.new(0,12,0.5,-8); ic.ImageColor3=THEME.text2
    local lb=label(b,name,13,false,THEME.text2); lb.Size=UDim2.new(1,-40,1,0); lb.Position=UDim2.new(0,36,0,0); lb.Font=Enum.Font.GothamMedium
    local page=make("ScrollingFrame",{ Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=3, ScrollBarImageColor3=THEME.accent, Visible=false, Parent=Pages }); pad(page,2)
    tabs[name]={ btn=b, page=page, lb=lb, ic=ic }
    b.MouseButton1Click:Connect(function()
        for n,t in pairs(tabs) do t.page.Visible=false; t.btn.BackgroundColor3=THEME.bg; t.lb.TextColor3=THEME.text2; t.ic.ImageColor3=THEME.text2 end
        page.Visible=true; TweenService:Create(b,TweenInfo.new(0.2),{BackgroundColor3=THEME.accent}):Play(); lb.TextColor3=THEME.text; ic.ImageColor3=THEME.text; TitleLbl.Text=name
    end)
    b.MouseEnter:Connect(function() if not page.Visible then TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=THEME.card}):Play() end end)
    b.MouseLeave:Connect(function() if not page.Visible then TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=THEME.bg}):Play() end end)
    return page
end

-- widgets
local function card(parent,title)
    local c=make("Frame",{ BackgroundColor3=THEME.card, BorderSizePixel=0, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=parent, BackgroundTransparency=CfgDB.transparency*0.3 }); corner(c,8); stroke(c,THEME.stroke)
    local head=make("Frame",{ Size=UDim2.new(1,0,0,32), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=c }); corner(head,8); make("Frame",{ Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,1,-10), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=head })
    make("Frame",{ Size=UDim2.new(0,3,0,18), Position=UDim2.new(0,0,0.5,-9), BackgroundColor3=THEME.accent, BorderSizePixel=0, Parent=head })
    label(head,"   "..title,12,true).Size=UDim2.new(1,-8,1,0)
    local body=make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,-20,0,0), Position=UDim2.new(0,10,0,40), AutomaticSize=Enum.AutomaticSize.Y, Parent=c }); make("UIListLayout",{ Padding=UDim.new(0,6) },body)
    body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() c.Size=UDim2.new(1,0,0,body.AbsoluteSize.Y+52) end)
    return body
end
local function two(parent)
    local f=make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=parent })
    local L=make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(0.5,-4,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=f })
    local R=make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(0.5,-4,0,0), AutomaticSize=Enum.AutomaticSize.Y, Position=UDim2.new(0.5,4,0,0), Parent=f })
    make("UIListLayout",{ Padding=UDim.new(0,8) },L); make("UIListLayout",{ Padding=UDim.new(0,8) },R)
    local function sync() f.Size=UDim2.new(1,0,0,math.max(L.AbsoluteSize.Y,R.AbsoluteSize.Y)) end
    L:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync); R:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync)
    return L,R
end
local function dual(parent) local h=make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,-4,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=parent }); make("UIListLayout",{ Padding=UDim.new(0,8) },h); return h end
local function tgl(parent,name,def,cb,sub)
    local h=sub and 50 or 36
    local c=make("Frame",{ BackgroundColor3=THEME.card2, BorderSizePixel=0, Size=UDim2.new(1,0,0,h), Parent=parent }); corner(c,6)
    local lb=label(c,name,12,true); lb.Position=UDim2.new(0,10,0,sub and 6 or 0); lb.Size=UDim2.new(1,-70,0,16); if not sub then lb.Size=UDim2.new(1,-70,1,0) end
    if sub then local s=label(c,sub,10,false,THEME.text2); s.Position=UDim2.new(0,10,0,26); s.Size=UDim2.new(1,-70,0,14) end
    local sw=make("TextButton",{ Size=UDim2.new(0,42,0,22), Position=UDim2.new(1,-52,0.5,-11), BackgroundColor3=def and THEME.accent or THEME.bg, BorderSizePixel=0, Text="", AutoButtonColor=false, Parent=c }); corner(sw,11)
    local k=make("Frame",{ Size=UDim2.new(0,16,0,16), Position=UDim2.new(def and 1 or 0, def and -19 or 3,0.5,-8), BackgroundColor3=THEME.text, BorderSizePixel=0, Parent=sw }); corner(k,8)
    local v=def
    sw.MouseButton1Click:Connect(function() v=not v; TweenService:Create(sw,TweenInfo.new(0.2),{BackgroundColor3=v and THEME.accent or THEME.bg}):Play(); TweenService:Create(k,TweenInfo.new(0.2),{Position=UDim2.new(v and 1 or 0,v and -19 or 3,0.5,-8)}):Play(); if cb then cb(v) end end)
    return c
end
local function sld(parent,name,mn,mx,def,cb)
    local c=make("Frame",{ BackgroundColor3=THEME.card2, BorderSizePixel=0, Size=UDim2.new(1,0,0,52), Parent=parent }); corner(c,6)
    local n=label(c,name,12); n.Position=UDim2.new(0,10,0,6); n.Size=UDim2.new(1,-60,0,16)
    local vl=label(c,tostring(def),12,true,THEME.accent); vl.Size=UDim2.new(0,50,0,16); vl.Position=UDim2.new(1,-60,0,6); vl.TextXAlignment=Enum.TextXAlignment.Right
    local bar=make("Frame",{ Size=UDim2.new(1,-20,0,6), Position=UDim2.new(0,10,0,32), BackgroundColor3=THEME.bg, BorderSizePixel=0, Parent=c }); corner(bar,3)
    local fill=make("Frame",{ Size=UDim2.new((def-mn)/(mx-mn),0,1,0), BackgroundColor3=THEME.accent, BorderSizePixel=0, Parent=bar }); corner(fill,3); gradient_pro(fill, THEME.accent, THEME.accent2, THEME.accent3, 0)
    local k=make("TextButton",{ Size=UDim2.new(0,14,0,14), Position=UDim2.new((def-mn)/(mx-mn),-7,0.5,-7), BackgroundColor3=THEME.text, BorderSizePixel=0, Text="", AutoButtonColor=false, Parent=bar }); corner(k,7)
    local drag=false
    k.MouseButton1Down:Connect(function() drag=true end)
    k.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=true end end)
    UserInput.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    UserInput.InputChanged:Connect(function(i) if not drag then return end; if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
        local rel=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        TweenService:Create(fill,TweenInfo.new(0.08),{Size=UDim2.new(rel,0,1,0)}):Play(); TweenService:Create(k,TweenInfo.new(0.08),{Position=UDim2.new(rel,-7,0.5,-7)}):Play()
        local v=math.floor(mn+(mx-mn)*rel+0.5); vl.Text=tostring(v); if cb then cb(v) end end)
end
local function wbtn(parent,name,color,cb,sub)
    local h=sub and 46 or 36
    local b=make("TextButton",{ BackgroundColor3=color or THEME.accent, BorderSizePixel=0, Size=UDim2.new(1,0,0,h), Text="", AutoButtonColor=false, Parent=parent }); corner(b,6)
    if color==nil or color==THEME.accent then gradient_pro(b, THEME.accent, THEME.accent2, THEME.accent3, 90) end
    local lb=label(b,name,13,true); lb.Size=UDim2.new(1,-20,0,16); lb.Position=UDim2.new(0,10,0,sub and 6 or 0); if not sub then lb.Size=UDim2.new(1,-20,1,0); lb.TextXAlignment=Enum.TextXAlignment.Center end
    if sub then local s=label(b,sub,10,false,Color3.fromRGB(230,230,230)); s.Size=UDim2.new(1,-20,0,14); s.Position=UDim2.new(0,10,0,26) end
    b.MouseButton1Click:Connect(cb); animate_btn(b); return b
end
local function winp(parent,ph)
    local c=make("Frame",{ BackgroundColor3=THEME.card2, BorderSizePixel=0, Size=UDim2.new(1,0,0,36), Parent=parent }); corner(c,6)
    local b=make("TextBox",{ BackgroundTransparency=1, Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,10,0,0), PlaceholderText=ph, PlaceholderColor3=THEME.text2, TextColor3=THEME.text, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Text="", ClearTextOnFocus=false, Parent=c })
    return b
end
local function ddn(parent,name,options,cb)
    local c=make("Frame",{ BackgroundColor3=THEME.card2, BorderSizePixel=0, Size=UDim2.new(1,0,0,40), Parent=parent }); corner(c,6)
    local n=label(c,name,12); n.Position=UDim2.new(0,10,0,0); n.Size=UDim2.new(1,-170,1,0)
    local b=make("TextButton",{ Size=UDim2.new(0,150,0,26), Position=UDim2.new(1,-160,0.5,-13), BackgroundColor3=THEME.bg, BorderSizePixel=0, Text=options[1].label, TextColor3=THEME.text, Font=Enum.Font.Gotham, TextSize=12, Parent=c }); corner(b,4); stroke(b,THEME.stroke)
    local list
    b.MouseButton1Click:Connect(function() if list then list:Destroy(); list=nil; return end
        list=make("Frame",{ Size=UDim2.new(0,150,0,#options*26+4), Position=UDim2.new(1,-160,1,4), BackgroundColor3=THEME.bg, BorderSizePixel=0, ZIndex=50, Parent=c }); corner(list,4); stroke(list,THEME.accent); make("UIListLayout",{ Padding=UDim.new(0,2) },list); pad(list,2)
        for _,opt in ipairs(options) do local ob=make("TextButton",{ Size=UDim2.new(1,0,0,22), BackgroundColor3=THEME.card2, BorderSizePixel=0, Text=opt.label, TextColor3=THEME.text, Font=Enum.Font.Gotham, TextSize=12, ZIndex=51, Parent=list }); corner(ob,3)
            ob.MouseButton1Click:Connect(function() b.Text=opt.label; if cb then cb(opt) end; list:Destroy(); list=nil end) end end)
end

-- TABS
section_header("JOGO")
local pInicio=make_tab("Início",ICON.home)
local pESP   =make_tab("ESP",ICON.eye)
local pMove  =make_tab("Movimento",ICON.bolt)
local pAim   =make_tab("Aimbot",ICON.target)
local pTP    =make_tab("Teleporte",ICON.tp)
section_header("EXTRAS")
local pArmas =make_tab("Armas",ICON.gun)
local pTroll =make_tab("Trolls",ICON.skull)
local pSpy   =make_tab("Remote Spy",ICON.radio)
section_header("SEGURANÇA")
local pBypass=make_tab("Bypass",ICON.shield)
local pCfg   =make_tab("Config",ICON.gear)
local pKeys,pLogs,pLeak
if is_admin then section_header("ADMIN")
    pKeys=make_tab("Keys",ICON.key); pLogs=make_tab("Logs",ICON.doc); pLeak=make_tab("Leak",ICON.bomb)
end

-- INÍCIO
do local list=dual(pInicio); local L,R=two(list)
    local uc=card(L,"Conta Roblox")
    local hol=make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,0,0,100), Parent=uc })
    local av=make("ImageLabel",{ BackgroundColor3=THEME.bg, BorderSizePixel=0, Size=UDim2.new(0,90,0,90), Position=UDim2.new(0,0,0,5), Parent=hol }); corner(av,45); stroke(av,THEME.accent,2)
    task.spawn(function() local ok,c=pcall(function() return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end); if ok then av.Image=c end end)
    local nm=label(hol,"@"..LP.Name,14,true); nm.Size=UDim2.new(1,-110,0,18); nm.Position=UDim2.new(0,105,0,10)
    local dn=label(hol,LP.DisplayName,12,false,THEME.text2); dn.Size=UDim2.new(1,-110,0,16); dn.Position=UDim2.new(0,105,0,30)
    local id=label(hol,"ID: "..LP.UserId,11,false,THEME.text2); id.Size=UDim2.new(1,-110,0,14); id.Position=UDim2.new(0,105,0,48)
    local ag=label(hol,LP.AccountAge.." dias",11,false,THEME.text2); ag.Size=UDim2.new(1,-110,0,14); ag.Position=UDim2.new(0,105,0,66)

    local pl=card(L,"Plano")
    label(pl,"Usuário: "..current_user,12,true).Size=UDim2.new(1,0,0,16)
    label(pl,"Key: "..(u.key or "—"),11,false,THEME.text2).Size=UDim2.new(1,0,0,16)
    label(pl,"Validade: "..(u.exp==-1 and "LIFETIME" or (u.exp and os.date("%d/%m/%Y",u.exp) or "?")),11,false,THEME.text2).Size=UDim2.new(1,0,0,16)
    label(pl,"HWID: "..HWID:sub(1,16).."...",10,false,THEME.text2).Size=UDim2.new(1,0,0,14)

    local q=card(R,"Ações rápidas")
    wbtn(q,"Combo (ESP+Fly+Speed)",nil,function() S.esp.on=true; S.fly.on=true; start_fly(); S.speed.on=true; notify("Combo ativado","3 features ligadas","success") end)
    wbtn(q,"Desligar tudo",THEME.card2,function() S.esp.on=false; S.fly.on=false; stop_fly(); S.speed.on=false; local h=hum(); if h then h.WalkSpeed=16 end; notify("Desligado","modo passivo","warn") end)
    wbtn(q,"Rejoin servidor",THEME.card2,rejoin_server)
    wbtn(q,"Server Hop",THEME.card2,server_hop)
    wbtn(q,"Resetar personagem",THEME.card2,function() local h=hum(); if h then h.Health=0 end end)

    local st=card(R,"Servidor")
    local s1=label(st,"Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers,12); s1.Size=UDim2.new(1,0,0,16)
    label(st,"Place: "..game.PlaceId,11,false,THEME.text2).Size=UDim2.new(1,0,0,14)
    label(st,"Executor: "..EXE,11,false,THEME.text2).Size=UDim2.new(1,0,0,14)
    task.spawn(function() while MainRoot.Parent do s1.Text="Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers; task.wait(3) end end)
end

-- ESP
do local list=dual(pESP); local L,R=two(list)
    local c=card(L,"Visualização")
    tgl(c,"ESP ligado",false,function(v) S.esp.on=v end)
    tgl(c,"Caixa",true,function(v) S.esp.box=v end)
    tgl(c,"Nome + distância",true,function(v) S.esp.name=v end)
    tgl(c,"Barra de HP",true,function(v) S.esp.hp=v end)
    tgl(c,"Tracer",false,function(v) S.esp.tracer=v end)
    tgl(c,"CHAMS (atravessa parede)",false,function(v) S.esp.chams=v end,"Highlight que passa por paredes")
    tgl(c,"Cor por time",false,function(v) S.esp.team=v end)
    local c2=card(R,"Filtros")
    sld(c2,"Distância máxima",100,10000,2000,function(v) S.esp.max_dist=v end)
end

-- MOVE
do local list=dual(pMove); local L,R=two(list)
    local c=card(L,"Fly (F1)")
    tgl(c,"Fly ligado",false,function(v) S.fly.on=v; if v then start_fly() else stop_fly() end end,"WASD + Espaço + Q")
    sld(c,"Velocidade",10,500,60,function(v) S.fly.speed=v end)
    tgl(c,"Freecam (E=sobe Q=desce)",false,toggle_freecam,"câmera livre independente do personagem")
    sld(c,"Vel freecam",1,10,1,function(v) S.freecam.speed=v end)
    local c2=card(R,"Speed (F2)")
    tgl(c2,"Speed ligado",false,function(v) S.speed.on=v; if not v then local h=hum(); if h then h.WalkSpeed=16 end end end)
    sld(c2,"Walkspeed",16,500,50,function(v) S.speed.value=v end)
    tgl(c2,"Click TP",false,function(v) S.click_tp.on=v end,"click esquerdo teleporta pra onde o mouse tá")
    local c3=card(L,"Pulo + Noclip")
    tgl(c3,"Jump custom",false,function(v) S.jump.on=v; if not v then local h=hum(); if h then h.JumpPower=50 end end end)
    sld(c3,"Jump power",50,500,80,function(v) S.jump.value=v end)
    tgl(c3,"Pulo infinito",false,function(v) S.inf_jump.on=v end)
    tgl(c3,"Noclip",false,function(v) S.noclip.on=v end)
    tgl(c3,"Anti slip",false,function(v) S.anti_slip.on=v end,"não escorrega mais em superfícies")
    local c4=card(R,"Visual + Combate")
    tgl(c4,"Fullbright",false,function(v) S.fullbright.on=v; apply_fullbright(v) end)
    tgl(c4,"Zoom hack (FOV)",false,function(v) S.zoom.on=v; ifl(c4,"Hitbox expander",false,function(v) S.hitbox.on=v end,"aumenta hitbox dos outros players")
    sld(c4,"Tamanho hitbox",2,30,10,function(v) S.hitbox.size=v end)
    tgl(c4,"Anti-AFK",false,function(v) S.anti_afk.on=v end)
end

-- AIM
do local list=dual(pAim); local L,R=two(list)
    local c=card(L,"Aimbot")
    tgl(c,"Aimbot ligado",false,function(v) S.aim.on=v end,"segura botão direito")
    sld(c,"FOV",30,500,120,function(v) S.aim.fov=v end)
    sld(c,"Smooth",5,100,30,function(v) S.aim.smooth=v/100 end)
    local c2=card(R,"Silent Aim (F5)")
    tgl(c2,"Silent aim",false,function(v) S.aim.silent=v; notify("Silent Aim",v and "ligado" or "desligado",v and "success" or "warn") end,hookmetamethod and "redireciona raycast pra cabeça" or "executor sem hookmetamethod")
    local c3=card(L,"Visual"); tgl(c3,"Mostrar FOV",true,function(v) S.aim.show_fov=v end)
    local c4=card(R,"Filtros"); tgl(c4,"Não mirar em time",false,function(v) S.aim.team_check=v end); tgl(c4,"Só visíveis",false,function(v) S.aim.visible_only=v end)
end

-- TP
do local list=dual(pTP); local L,R=two(list)
    local c=card(L,"Teleporte")
    local inp=winp(c,"nome do player"); inp:GetPropertyChangedSignal("Text"):Connect(function() S.tp.target=inp.Text end)
    wbtn(c,"TP (F3)",nil,function() if S.tp.target~="" then tp_player(S.tp.target) end end)
    local sv; wbtn(c,"Salvar posição",THEME.card2,function() local r=hrp(); if r then sv=r.CFrame; notify("Salvo","ok","success",2) end end)
    wbtn(c,"TP pra salva",THEME.card2,function() if sv then tp_to(sv) end end)
    local c2=card(R,"Players online")
    local lst=make("ScrollingFrame",{ Size=UDim2.new(1,0,0,220), BackgroundColor3=THEME.bg, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=c2 }); corner(lst,6); make("UIListLayout",{ Padding=UDim.new(0,2) },lst); pad(lst,4)
    local function ref() for _,x in ipairs(lst:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP then
            local row=make("Frame",{ Size=UDim2.new(1,-4,0,28), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=lst }); corner(row,4)
            label(row,"  "..p.Name,11).Size=UDim2.new(1,-70,1,0)
            local g=make("TextButton",{ Size=UDim2.new(0,60,0,22), Position=UDim2.new(1,-66,0.5,-11), BackgroundColor3=THEME.accent, BorderSizePixel=0, Text="TP", TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=11, Parent=row }); corner(g,3); gradient_pro(g, THEME.accent, THEME.accent2, THEME.accent3, 90)
            g.MouseButton1Click:Connect(function() tp_player(p.Name) end)
        end end end
    wbtn(c2,"Atualizar",THEME.card2,ref); ref()
end

-- ARMAS
do local list=dual(pArmas); local c=card(list,"Armas disponíveis")
    label(c,"Scanner acha Tools em ReplicatedStorage, Workspace, Teams e Backpacks. ServerStorage não é acessível pelo cliente.",10,false,THEME.text2).Size=UDim2.new(1,0,0,28)
    local lst=make("ScrollingFrame",{ Size=UDim2.new(1,0,0,260), BackgroundColor3=THEME.bg, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=c }); corner(lst,6); make("UIListLayout",{ Padding=UDim.new(0,3) },lst); pad(lst,4)
    local function ref() for _,x in ipairs(lst:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
        for _,t in ipairs(scan_tools()) do local row=make("Frame",{ Size=UDim2.new(1,-4,0,28), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=lst }); corner(row,4)
            label(row,"  "..t.Name.."  < "..t.Parent.Name.." >",11).Size=UDim2.new(1,-70,1,0)
            local g=make("TextButton",{ Size=UDim2.new(0,60,0,22), Position=UDim2.new(1,-66,0.5,-11), BackgroundColor3=THEME.accent, BorderSizePixel=0, Text="pegar", TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=11, Parent=row }); corner(g,3)
            g.MouseButton1Click:Connect(function() grab(t); notify("Pego",t.Name,"success",2) end) end end
    wbtn(c,"Atualizar",THEME.card2,ref); wbtn(c,"Pegar TODAS",nil,function() local n=0; for _,t in ipairs(scan_tools()) do pcall(grab,t); n+=1 end; notify("Pegou",n.." armas","success") end); ref()
end

-- TROLLS
do local list=dual(pTroll); local L,R=two(list)
    local c=card(L,"Em você")
    tgl(c,"God Mode",false,function(v) S.troll.god=v; god_mode(v) end)
    tgl(c,"Invisível",false,function(v) S.troll.invisible=v; set_invisible(v) end)
    tgl(c,"Girar",false,function(v) S.troll.spin=v; do_spin(v) end)
    tgl(c,"Cabeça gigante",false,function(v) S.troll.big=v; big_head(v) end)
    wbtn(c,"Fling",nil,fling_self)
    local c2=card(R,"Em outros")
    local inp=winp(c2,"nome pra perseguir")
    wbtn(c2,"Grudar nas costas",nil,function() S.troll.follow_target=inp.Text; notify("Perseguindo",inp.Text,"success",2) end)
    wbtn(c2,"Parar",THEME.card2,function() S.troll.follow_target="" end)

    -- leaderstats visual (só mostra)
    local c3=card(L,"📊 Leaderstats (só leitura visual)")
    label(c3,"Mostra suas stats. Pra EDITAR server-side use a aba Remote Spy.",10,false,THEME.text2).Size=UDim2.new(1,0,0,22)
    local sh=make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=c3 }); make("UIListLayout",{ Padding=UDim.new(0,3) },sh)
    local function refresh_ls() for _,x in ipairs(sh:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
        local ls=scan_leaderstats()
        if #ls==0 then local e=label(sh,"nenhuma leaderstat neste jogo",10,false,THEME.text2); e.Size=UDim2.new(1,0,0,16); return end
        for _,s in ipairs(ls) do local row=make("Frame",{ Size=UDim2.new(1,0,0,22), BackgroundColor3=THEME.bg, BorderSizePixel=0, Parent=sh }); corner(row,4)
            local lb=label(row,"  "..s.name,11); lb.Size=UDim2.new(0.6,0,1,0)
            local vl=label(row,tostring(s.ref.Value),11,true,THEME.accent); vl.Size=UDim2.new(0.4,-8,1,0); vl.Position=UDim2.new(0.6,0,0,0); vl.TextXAlignment=Enum.TextXAlignment.Right
            s.ref:GetPropertyChangedSignal("Value"):Connect(function() vl.Text=tostring(s.ref.Value) end)
        end
    end
    wbtn(c3,"Scan leaderstats",THEME.card2,refresh_ls); refresh_ls()
end

-- REMOTE SPY (exploit real)
do local list=dual(pSpy)
    local info=card(list,"⚡ Remote Spy — exploit real de stats")
    label(info,"Lista TODOS RemoteEvents/RemoteFunctions do jogo. Dá pra firar com argumentos custom pra tentar mexer em stats server-side (money, kills, xp). Teste os remotes que parecem ser de stats (ex: AddCash, SetKills, GiveXP). Cada jogo tem nomes diferentes.",10,false,THEME.text2).Size=UDim2.new(1,0,0,64)
    local filterInp = winp(info, "filtrar por nome (ex: cash, kill, money)")
    local argsInp = winp(info, "args (ex: 999999 ou 100,true)")
    local remoteList = make("ScrollingFrame",{ Size=UDim2.new(1,0,0,280), BackgroundColor3=THEME.bg, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=info }); corner(remoteList,6); make("UIListLayout",{ Padding=UDim.new(0,2) },remoteList); pad(remoteList,4)
    local function refresh_remotes()
        for _,x in ipairs(remoteList:GetChildren()) do if x:IsA("Frame") then x:Destroy() end end
        local f = filterInp.Text:lower()
        local all = scan_remotes()
        for _,r in ipairs(all) do
            if f~="" and not r.name:lower():find(f,1,true) then continue end
            local row=make("Frame",{ Size=UDim2.new(1,-4,0,38), BackgroundColor3=THEME.card2, BorderSizePixel=0, Parent=remoteList }); corner(row,4)
            local lb=label(row,"  "..r.name,11,true); lb.Size=UDim2.new(1,-80,0,16); lb.Position=UDim2.new(0,4,0,4)
            local tp=label(row,"  "..r.type.."  |  "..r.path:sub(1,60),9,false,THEME.text2); tp.Size=UDim2.new(1,-80,0,14); tp.Position=UDim2.new(0,4,0,20)
            local b=make("TextButton",{ Size=UDim2.new(0,70,0,26), Position=UDim2.new(1,-76,0.5,-13), BackgroundColor3=THEME.accent, BorderSizePixel=0, Text="FIRE", TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=11, Parent=row }); corner(b,4); gradient_pro(b, THEME.accent, THEME.accent2, THEME.accent3, 90)
            b.MouseButton1Click:Connect(function()
                local ok,err = fire_remote(r.ref, argsInp.Text)
                notify(ok and "Fire enviado" or "Fire falhou", r.name.." ← ["..argsInp.Text.."]", ok and "success" or "error", 3)
                log("remote_fire",{remote=r.name, args=argsInp.Text, ok=ok})
            end)
        end
    end
    wbtn(info,"🔍 Scan + aplicar filtro",THEME.card2,refresh_remotes)
    wbtn(info,"⚡ Fire em TODOS os remotes filtrados (cuidado!)",nil,function()
        local f=filterInp.Text:lower(); local n=0
        for _,r in ipairs(scan_remotes()) do if f=="" or r.name:lower():find(f,1,true) then pcall(function() fire_remote(r.ref, argsInp.Text) end); n+=1 end end
        notify("Mass fire",n.." remotes disparados","warn",4)
    end,"spam em tudo que bater o filtro")
    refresh_remotes()
end

-- BYPASS
do local list=dual(pBypass)
    local c=card(list,"Anti-rastro ativo")
    label(c,"✓ GUI ofuscada e em gethui()\n✓ BodyMovers renomeados\n✓ syn.protect_gui aplicado\n✓ Silent aim ignora próprias chamadas\n✓ Conexões rastreadas pra cleanup",11,false,THEME.text).Size=UDim2.new(1,0,0,78)
    local c2=card(list,"Desinjetar + limpar")
    label(c2,"Desliga TODAS as features (ESP para na hora), remove BodyMovers, apaga arquivos locais e destrói a GUI. Nada sobra.",11,false,THEME.text2).Size=UDim2.new(1,0,0,32)
    wbtn(c2,"🛡️ DESINJETAR AGORA",THEME.accent2,function() notify("Desinjetando...","apagando rastros","warn",2); task.wait(0.5); wipe_traces() end)
end

-- CONFIG
do local list=dual(pCfg); local L,R=two(list)
    local c=card(L,"Interface")
    tgl(c,"Stream Mode (F4)",false,function(v) StreamOn=v; apply_stream() end)
    sld(c,"Transparência do fundo",0,80,math.floor(CfgDB.transparency*100),function(v) CfgDB.transparency=v/100; save_json(P_CFG,CfgDB); MainRoot.BackgroundTransparency=CfgDB.transparency end)
    wbtn(c,"Deslogar",THEME.card2,function() Session.user=nil; save_json(P_SESS,Session); ScreenGui:Destroy() end)
    local c2=card(L,"Cor do menu")
    local colors={{label="Vermelho",rgb={220,38,38}},{label="Azul",rgb={38,120,220}},{label="Verde",rgb={38,180,90}},{label="Roxo",rgb={150,60,220}},{label="Laranja",rgb={255,140,30}},{label="Rosa",rgb={255,80,180}},{label="Ciano",rgb={0,200,220}}}
    ddn(c2,"cor accent",colors,function(o) THEME.accent=Color3.fromRGB(o.rgb[1],o.rgb[2],o.rgb[3]); CfgDB.accent=o.rgb; save_json(P_CFG,CfgDB); notify("Cor alterada","recarregue pra aplicar em tudo","warn",3) end)

    local c3=card(R,"Status do cheat")
    wbtn(c3,"📤 Enviar status agora pro Discord",nil,function() send_status(current_user, is_admin); notify("Status enviado","embed no webhook","success",2) end,"manda embed com features ativas e risco")
    local c4=card(R,"Hotkeys")
    for _,h in ipairs({"K  —  abre/fecha menu","F1  —  fly","F2  —  speed","F3  —  tp","F4  —  stream mode","F5  —  silent aim"}) do label(c4,h,12).Size=UDim2.new(1,0,0,16) end
end

-- ADMIN KEYS
if pKeys then local list=dual(pKeys); local L,R=two(list)
    local c=card(L,"Gerar keys")
    local sel=DURATIONS[1]; local opts={}; for _,d in ipairs(DURATIONS) do table.insert(opts,{label=d.label,data=d}) end
    ddn(c,"duração",opts,function(o) sel=o.data end)
    local qty=winp(c,"quantidade (1-500)")
    local res=label(c,"",10,false,THEME.text2); res.Size=UDim2.new(1,0,0,100); res.TextWrapped=true; res.Font=Enum.Font.Code; res.TextYAlignment=Enum.TextYAlignment.Top
    wbtn(c,"Gerar keys",nil,function() local q=tonumber(qty.Text) or 0; if q<1 or q>500 then notify("Erro","1-500","error"); return end; local ks=generate_keys(sel.seconds,sel.label,q,current_user); res.Text=("gerou %d keys (%s)\n\n%s"):format(q,sel.label,table.concat(ks,"\n")); notify("Keys geradas",q.." enviadas pro webhook","success") end)
    local c2=card(R,"Reset HWID")
    local uinp=winp(c2,"usuário")
    wbtn(c2,"Resetar HWID do usuário",nil,function() local ok,msg=admin_reset_hwid(uinp.Text); notify(ok and "HWID resetado" or "Falhou", ok and (uinp.Text.." liberado") or tostring(msg), ok and "success" or "error") end)
    local c3=card(R,"Estatísticas")
    local t,us=0,0; for _,r in pairs(KeyDB) do t+=1; if r.used_by then us+=1 end end
    local st=label(c3,("total: %d | usadas: %d | livres: %d"):format(t,us,t-us),12,true); st.Size=UDim2.new(1,0,0,20)
    wbtn(c3,"Atualizar",THEME.card2,function() t,us=0,0; for _,r in pairs(KeyDB) do t+=1; if r.used_by then us+=1 end end; st.Text=("total: %d | usadas: %d | livres: %d"):format(t,us,t-us) end)
end

-- LOGS
if pLogs then local list=dual(pLogs); local c=card(list,"Logs recentes")
    local lb=make("ScrollingFrame",{ Size=UDim2.new(1,0,0,340), BackgroundColor3=THEME.bg, BorderSizePixel=0, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=THEME.accent, Parent=c }); corner(lb,6); make("UIListLayout",{ Padding=UDim.new(0,2) },lb); pad(lb,4)
    local function ref() for _,x in ipairs(lb:GetChildren()) do if x:IsA("TextLabel") then x:Destroy() end end
        local start=math.max(1,#LogDB-100); for i=start,#LogDB do local e=LogDB[i]; local w=os.date("%d/%m %H:%M:%S",e.t); local d=type(e.detail)=="table" and HttpService:JSONEncode(e.detail) or tostring(e.detail); local l=label(lb,"["..w.."] "..e.action.." — "..d,10,false,THEME.text2); l.Size=UDim2.new(1,0,0,14); l.Font=Enum.Font.Code end end
    ref(); wbtn(c,"Atualizar",THEME.card2,ref); wbtn(c,"Limpar",THEME.accent2,function() LogDB={}; save_json(P_LOGS,LogDB); ref() end)
end

-- LEAK
if pLeak then local list=dual(pLeak); local c=card(list,"Save Instance")
    label(c,"Dispara saveinstance em background com triple pcall — NÃO trava o roblox.",11,false,THEME.text2).Size=UDim2.new(1,0,0,32)
    wbtn(c,"Dumpar place (SAFE)",nil,function() local ok,msg=try_saveinstance(); notify(ok and "Leak iniciado" or "Falhou",msg,ok and "success" or "error",6); log("admin_leak",{ok=ok,msg=msg}) end)
    local c2=card(list,"Info do place")
    label(c2,"PlaceId: "..game.PlaceId,11).Size=UDim2.new(1,0,0,14)
    label(c2,"GameId: "..game.GameId,11).Size=UDim2.new(1,0,0,14)
    label(c2,"JobId: "..game.JobId,10,false,THEME.text2).Size=UDim2.new(1,0,0,14)
end

tabs["Início"].btn.MouseButton1Click:Fire()
menuVisible = true

------------------------------------------------------------
-- HOTKEYS (TECLA K pro menu agora)
------------------------------------------------------------
local function toggle_menu() menuVisible = not menuVisible; MainRoot.Visible=menuVisible; set_input_block(menuVisible); if minBubble then minBubble:Destroy(); minBubble=nil end end

local function bind_action(name,key,cb)
    pcall(function() CAS:BindActionAtPriority(name,function(_,state) if state==Enum.UserInputState.Begin then cb() end; return Enum.ContextActionResult.Pass end,false,2000,key) end)
end
bind_action("pkMenu",Enum.KeyCode.K,toggle_menu)
bind_action("pkFly",Enum.KeyCode.F1,function() S.fly.on=not S.fly.on; if S.fly.on then start_fly() else stop_fly() end; notify("Fly",S.fly.on and "ligado" or "desligado",S.fly.on and "success" or "warn",1.5) end)
bind_action("pkSpd",Enum.KeyCode.F2,function() S.speed.on=not S.speed.on; if not S.speed.on then local h=hum(); if h then h.WalkSpeed=16 end end; notify("Speed",S.speed.on and "ligado" or "desligado",S.speed.on and "success" or "warn",1.5) end)
bind_action("pkTp",Enum.KeyCode.F3,function() if S.tp.target~="" then tp_player(S.tp.target) end end)
bind_action("pkStr",Enum.KeyCode.F4,function() StreamOn=not StreamOn; apply_stream() end)
bind_action("pkSil",Enum.KeyCode.F5,function() S.aim.silent=not S.aim.silent; notify("Silent Aim",S.aim.silent and "ligado" or "desligado",S.aim.silent and "success" or "warn",1.5) end)

-- fallback InputBegan (caso CAS falhe)
track(UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        -- só toggla se NÃO estiver em TextBox
        local focused = UserInput:GetFocusedTextBox()
        if not focused then toggle_menu() end
    end
end))

track(LP.CharacterAdded:Connect(function() task.wait(0.5); if S.fly.on then start_fly() end; orig_trans={}; if S.troll.invisible then set_invisible(true) end end))

-- mobile fab com LOGO
if IS_MOBILE then
    local fab=make("ImageButton",{ Size=UDim2.new(0,64,0,64), Position=UDim2.new(0,16,0.5,-32), BackgroundTransparency=1, Image=LOGO_ID, Parent=ScreenGui })
    fab.MouseButton1Click:Connect(toggle_menu)
    local drag,dS,sP
    fab.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=true; dS=i.Position; sP=fab.Position end end)
    fab.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    UserInput.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-dS; fab.Position=UDim2.new(sP.X.Scale,sP.X.Offset+d.X,sP.Y.Scale,sP.Y.Offset+d.Y) end end)
end

send_status(current_user, is_admin)
task.spawn(function() while MainRoot.Parent do task.wait(300); send_status(current_user, is_admin) end end)

notify("PK Cheats Brasil","bem-vindo, "..current_user.." — tecla K abre o menu","success",4)
log("login",{user=current_user,admin=is_admin,hwid=HWID:sub(1,16)},3447003)
set_input_block(true)

end

------------------------------------------------------------
-- LOGIN / REGISTER
------------------------------------------------------------
local function build_auth()
local LoginRoot = make("Frame",{ Name="Login", Size=UDim2.new(0,480,0,520), Position=UDim2.new(0.5,-240,0.5,-260), BackgroundColor3=THEME.bg2, BorderSizePixel=0, Parent=ScreenGui })
corner(LoginRoot,14); stroke(LoginRoot,THEME.accent,1.5); gradient_pro(LoginRoot, THEME.bg2, THEME.bg, THEME.bg2, 90)
local lClose=make("ImageButton",{ Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-40,0,12), BackgroundColor3=THEME.card, Image=ICON.close, ImageColor3=THEME.accent, BorderSizePixel=0, Parent=LoginRoot }); corner(lClose,15); stroke(lClose,THEME.accent); animate_btn(lClose)
lClose.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
local lLogo=build_logo(LoginRoot,140); lLogo.Position=UDim2.new(0.5,-70,0,20)
local LSub=label(LoginRoot,"bem-vindo de volta",13,false,THEME.text2); LSub.Size=UDim2.new(1,-60,0,16); LSub.Position=UDim2.new(0,30,0,170); LSub.TextXAlignment=Enum.TextXAlignment.Center

local LBody=make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,-60,0,240), Position=UDim2.new(0,30,0,200), Parent=LoginRoot }); make("UIListLayout",{ Padding=UDim.new(0,10) },LBody)
local function ainp(parent,ph) local wrap=make("Frame",{ BackgroundColor3=THEME.card, BorderSizePixel=0, Size=UDim2.new(1,0,0,42), Parent=parent }); corner(wrap,8); stroke(wrap,THEME.stroke)
    local b=make("TextBox",{ BackgroundTransparency=1, Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,14,0,0), PlaceholderText=ph, PlaceholderColor3=THEME.text2, TextColor3=THEME.text, Font=Enum.Font.Gotham, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Text="", ClearTextOnFocus=false, Parent=wrap })
    b.Focused:Connect(function() TweenService:Create(wrap:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{Color=THEME.accent}):Play() end)
    b.FocusLost:Connect(function() TweenService:Create(wrap:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{Color=THEME.stroke}):Play() end)
    return b end
local LUser=ainp(LBody,"usuário"); local LPass=ainp(LBody,"senha")
local LBtn=make("TextButton",{ BackgroundColor3=THEME.accent, BorderSizePixel=0, Size=UDim2.new(1,0,0,46), Text="ENTRAR", TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=15, AutoButtonColor=false, Parent=LBody }); corner(LBtn,8); gradient_pro(LBtn, THEME.accent, THEME.accent2, THEME.accent3, 90); animate_btn(LBtn)
make("Frame",{ BackgroundColor3=THEME.stroke, BorderSizePixel=0, Size=UDim2.new(1,0,0,1), Parent=LBody })
local LToReg=make("TextButton",{ BackgroundColor3=THEME.card, BorderSizePixel=0, Size=UDim2.new(1,0,0,42), Text="criar conta nova", TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=13, AutoButtonColor=false, Parent=LBody }); corner(LToReg,8); stroke(LToReg,THEME.accent); animate_btn(LToReg)
local LStat=label(LoginRoot,"",11,false,THEME.danger); LStat.Size=UDim2.new(1,-60,0,16); LStat.Position=UDim2.new(0,30,1,-52); LStat.TextXAlignment=Enum.TextXAlignment.Center
label(LoginRoot,DISCORD.." • v5.0",10,false,THEME.text2).Size=UDim2.new(1,-60,0,14); LoginRoot:GetChildren()[#LoginRoot:GetChildren()].Position=UDim2.new(0,30,1,-26); LoginRoot:GetChildren()[#LoginRoot:GetChildren()].TextXAlignment=Enum.TextXAlignment.Center

local RegRoot=make("Frame",{ Name="Register", Size=UDim2.new(0,480,0,600), Position=UDim2.new(0.5,-240,0.5,-300), BackgroundColor3=THEME.bg2, BorderSizePixel=0, Visible=false, Parent=ScreenGui }); corner(RegRoot,14); stroke(RegRoot,THEME.accent,1.5); gradient_pro(RegRoot, THEME.bg2, THEME.bg, THEME.bg2, 90)
local rClose=make("ImageButton",{ Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-40,0,12), BackgroundColor3=THEME.card, Image=ICON.close, ImageColor3=THEME.accent, BorderSizePixel=0, Parent=RegRoot }); corner(rClose,15); stroke(rClose,THEME.accent); animate_btn(rClose)
rClose.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
local rLogo=build_logo(RegRoot,140); rLogo.Position=UDim2.new(0.5,-70,0,20)
local RSub=label(RegRoot,"crie sua conta com uma key válida",13,false,THEME.text2); RSub.Size=UDim2.new(1,-60,0,16); RSub.Position=UDim2.new(0,30,0,170); RSub.TextXAlignment=Enum.TextXAlignment.Center
local RBody=make("Frame",{ BackgroundTransparency=1, Size=UDim2.new(1,-60,0,320), Position=UDim2.new(0,30,0,200), Parent=RegRoot }); make("UIListLayout",{ Padding=UDim.new(0,10) },RBody)
local RUser=ainp(RBody,"usuário (min 3)"); local RPass=ainp(RBody,"senha (min 4)"); local RKey=ainp(RBody,"PK-XXXX-XXXX-XXXX-XXXX")
local RBtn=make("TextButton",{ BackgroundColor3=THEME.accent, BorderSizePixel=0, Size=UDim2.new(1,0,0,46), Text="CADASTRAR", TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=15, AutoButtonColor=false, Parent=RBody }); corner(RBtn,8); gradient_pro(RBtn, THEME.accent, THEME.accent2, THEME.accent3, 90); animate_btn(RBtn)
make("Frame",{ BackgroundColor3=THEME.stroke, BorderSizePixel=0, Size=UDim2.new(1,0,0,1), Parent=RBody })
local RToLog=make("TextButton",{ BackgroundColor3=THEME.card, BorderSizePixel=0, Size=UDim2.new(1,0,0,42), Text="já tenho conta — entrar", TextColor3=THEME.text, Font=Enum.Font.GothamBold, TextSize=13, AutoButtonColor=false, Parent=RBody }); corner(RToLog,8); stroke(RToLog,THEME.accent); animate_btn(RToLog)
local RStat=label(RegRoot,"",11,false,THEME.danger); RStat.Size=UDim2.new(1,-60,0,16); RStat.Position=UDim2.new(0,30,1,-26); RStat.TextXAlignment=Enum.TextXAlignment.Center
LToReg.MouseButton1Click:Connect(function() LoginRoot.Visible=false; RegRoot.Visible=true; LStat.Text=""; RStat.Text="" end)
RToLog.MouseButton1Click:Connect(function() RegRoot.Visible=false; LoginRoot.Visible=true; LStat.Text=""; RStat.Text="" end)

return LoginRoot, RegRoot, LUser, LPass, LBtn, LStat, RUser, RPass, RKey, RBtn, RStat
end

------------------------------------------------------------
-- MAIN FLOW
------------------------------------------------------------
run_splash(function()
    local LoginRoot, RegRoot, LUser, LPass, LBtn, LStat, RUser, RPass, RKey, RBtn, RStat = build_auth()

    local function do_login(u,p)
        local rec=UserDB[u]; if not rec then return false,"usuário não existe" end
        if rec.pass~=p then return false,"senha errada" end
        if not rec.admin then
            local ok,why=key_active(u)
            if not ok then
                if why=="HWID_MISMATCH" then return false,"conta travada em outro device — peça reset HWID pro admin" end
                if why=="EXPIRED" or why=="NO_KEY" then
                    delete_expired_user(u)
                    return false,"sua key expirou — a conta foi liberada, cadastre novamente"
                end
                return false,"key inválida"
            end
        end
        Session.user=u; save_json(P_SESS,Session); return true
    end
    local function do_register(u,p,k)
        if UserDB[u] then return false,"usuário já existe" end
        if #u<3 then return false,"usuário muito curto" end
        if #p<4 then return false,"senha muito curta" end
        if not KeyDB[k] then return false,"key inválida" end
        if KeyDB[k].used_by then return false,"key já usada" end
        UserDB[u]={pass=p,admin=false,key=nil,exp=nil,created=os.time()}
        save_json(P_USERS,UserDB)
        local ok,msg=redeem_key(u,k); if not ok then UserDB[u]=nil; save_json(P_USERS,UserDB); return false,msg end
        return true
    end

    LBtn.MouseButton1Click:Connect(function()
        local u,p=LUser.Text,LPass.Text
        local ok,msg=do_login(u,p)
        if ok then LoginRoot:Destroy(); RegRoot:Destroy(); build_menu(u,UserDB[u].admin==true); notify("Entrou","bem-vindo, "..u,"success",3)
        else LStat.Text=msg; notify("Falha",msg,"error") end
    end)
    RBtn.MouseButton1Click:Connect(function()
        local u,p,k=RUser.Text,RPass.Text,RKey.Text
        local ok,msg=do_register(u,p,k)
        if ok then RStat.Text="cadastrado!"; RStat.TextColor3=THEME.good; notify("Ok","faça login","success",4); task.wait(1.3); RegRoot.Visible=false; LoginRoot.Visible=true; LUser.Text=u; LPass.Text=""
        else RStat.Text=msg; notify("Falha",msg,"error") end
    end)

    if Session.user and UserDB[Session.user] then
        local u=Session.user; local rec=UserDB[u]
        if rec.admin or key_active(u) then LoginRoot:Destroy(); RegRoot:Destroy(); build_menu(u,rec.admin==true) end
    end
end)
